# encoding: utf-8

require 'spec_helper'

describe DoubleEntry::TimeRange::Quarter do

  describe '.new' do
    subject(:range) do
      DoubleEntry::TimeRange::Quarter.new(:year => 2013, :quarter => 2)
    end

    it { should be_a DoubleEntry::TimeRange::Quarter }
    its(:year)    { should eq 2013 }
    its(:quarter) { should eq 2 }
    its(:start)   { should eq Time.parse('2013-04-01') }
    its(:finish)  { should eq Time.parse('2013-06-30 23:59:59').end_of_day }
  end

  describe '.current' do
    subject(:range) do
      Timecop.freeze(Time.mktime(2009, 3, 27)) do
        DoubleEntry::TimeRange::Quarter.current
      end
    end

    it { should be_a DoubleEntry::TimeRange::Quarter }
    its(:year)    { should eq 2009 }
    its(:quarter) { should eq 1 }
  end

  describe '.from_time' do
    let(:time) { Time.mktime(2015, 12, 3) }

    subject(:range) { DoubleEntry::TimeRange::Quarter.from_time(time) }

    it { should be_a DoubleEntry::TimeRange::Quarter }
    its(:year)    { should eq 2015 }
    its(:quarter) { should eq 4 }
  end

  describe '#==' do
    subject(:range) { DoubleEntry::TimeRange::Quarter.new(:year => 2013, :quarter => 2) }

    context 'with an equal range' do
      let(:other) { DoubleEntry::TimeRange::Quarter.new(:year => 2013, :quarter => 2) }

      it 'returns true' do
        expect(range == other).to be true
      end
    end

    context 'with an equal range' do
      let(:other) { DoubleEntry::TimeRange::Quarter.new(:year => 2012, :quarter => 3) }

      it 'returns true' do
        expect(range == other).to be false
      end
    end
  end

  # describe '#previous' do
  #   let(:previous_range) { DoubleEntry::TimeRange::Quarter.new(:year => 2013, :quarter => 1) }

  #   subject(:range) { DoubleEntry::TimeRange::Quarter.new(:year => 2013, :quarter => 2) }

  #   its(:previous) { should eq previous_range }
  # end

  # describe '#next' do
  #   let(:next_range) { DoubleEntry::TimeRange::Quarter.new(:year => 2014, :quarter => 1) }

  #   subject(:range) { DoubleEntry::TimeRange::Quarter.new(:year => 2013, :quarter => 4) }

  #   its(:next) { should eq next_range }
  # end

  describe '#to_s' do
    subject(:range) { DoubleEntry::TimeRange::Quarter.new(:year => 2008, :quarter => 2) }

    its(:to_s) { should eq '2008::Q2' }
  end
end
