# encoding: utf-8
module DoubleEntry
  # Lock financial accounts to ensure consistency.
  #
  # In order to ensure financial transactions always keep track of balances
  # consistently, database-level locking is needed. This module takes care of
  # it.
  #
  # See DoubleEntry.lock_accounts and DoubleEntry.transfer for the public interface
  # to this stuff.
  #
  # Locking is done on DoubleEntry::AccountBalance records. If an AccountBalance
  # record for an account doesn't exist when you try to lock it, the locking
  # code will create one.
  #
  # script/jack_hammer can be used to run concurrency tests on double_entry to
  # validates that locking works properly.
  module Locking
    include Configurable

    class Configuration
      # Set this in your tests if you're using transactional_fixtures, so we know
      # not to complain about a containing transaction when you call lock_accounts.
      attr_accessor :running_inside_transactional_fixtures

      def initialize #:nodoc:
        @running_inside_transactional_fixtures = false
      end
    end

    # Run the passed in block in a transaction with the given accounts locked for update.
    #
    # The transaction must be the outermost transaction to ensure data integrity. A
    # LockMustBeOutermostTransaction will be raised if it isn't.
    def self.lock_accounts(*accounts, &block)
      lock = Lock.new(accounts)

      if lock.in_a_locked_transaction?
        lock.ensure_locked!
        block.call
      else
        lock.perform_lock(&block)
      end

    rescue ActiveRecord::StatementInvalid => exception
      if exception.message =~ /lock wait timeout/i
        raise LockWaitTimeout
      else
        raise
      end
    end

    # Return the account balance record for the given account if there's a
    # lock on it, or raise a LockNotHeld if there isn't.
    def self.balance_for_locked_account(account)
      Lock.new([account]).ensure_locked!
      AccountBalance.find_by_account(account, lock: true)
    end

    class Lock
      def initialize(accounts)
        # Make sure we always lock in the same order, to avoid deadlocks.
        @accounts = accounts.flatten.sort
      end

      # Lock the given accounts, creating account balance records for them if
      # needed.
      def perform_lock(&block)
        ensure_outermost_transaction!
        ensure_account_balances_exist
        lock_and_execute(&block)
      end

      # Return true if we're inside a lock_accounts block.
      def in_a_locked_transaction?
        !Thread.current[:double_entry_locked_accounts].nil?
      end

      def ensure_locked!
        locked = Thread.current[:double_entry_locked_accounts]
        @accounts.each do |account|
          unless locked&.include?(account)
            fail LockNotHeld, "No lock held for account: #{account.identifier}, scope #{account.scope}"
          end
        end
      end

    private

      # Raise an exception unless we're outside any transactions.
      def ensure_outermost_transaction!
        minimum_transaction_level = Locking.configuration.running_inside_transactional_fixtures ? 1 : 0
        unless AccountBalance.connection.open_transactions <= minimum_transaction_level
          fail LockMustBeOutermostTransaction
        end
      end

      # Create any missing account_balance records before locking.
      def ensure_account_balances_exist
        @accounts.each do |account|
          next if AccountBalance.find_by_account(account)
          balance = account.balance
          AccountBalance.create_ignoring_duplicates!(account: account, balance: balance)
        end
      end

      # Start a transaction, grab locks on all accounts, then call the block.
      def lock_and_execute(&block)
        AccountBalance.restartable_transaction do
          AccountBalance.with_restart_on_deadlock do
            @accounts.each { |account| AccountBalance.find_by_account(account, lock: true) }
          end
          begin
            Thread.current[:double_entry_locked_accounts] = @accounts
            yield
          ensure
            Thread.current[:double_entry_locked_accounts] = nil
          end
        end
      end
    end

    # Raised when lock_accounts is called inside an existing transaction.
    class LockMustBeOutermostTransaction < RuntimeError
    end

    # Raised when attempting a transfer on an account that's not locked.
    class LockNotHeld < RuntimeError
    end

    # Raised if things go horribly, horribly wrong. This should never happen.
    class LockDisaster < RuntimeError
    end

    # Raised if waiting for locks times out.
    class LockWaitTimeout < RuntimeError
    end
  end
end
