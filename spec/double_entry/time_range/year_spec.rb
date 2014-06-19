# encoding: utf-8

require 'spec_helper'

describe DoubleEntry::TimeRange::Year do

  describe '.new' do
    let(:year) { 2013 }

    subject(:range) { DoubleEntry::TimeRange::Year.new(:year => year) }

    it { should be_a DoubleEntry::TimeRange::Year }
    its(:year)   { should eq 2013 }
    its(:start)  { should eq Time.parse('2013-01-01') }
    its(:finish) { should eq Time.parse('2013-12-31 23:59:59') }
  end

  describe '.current' do
    subject(:range) do
      Timecop.freeze(Time.mktime(2009, 3, 27)) do
        DoubleEntry::TimeRange::Year.current
      end
    end

    it { should be_a DoubleEntry::TimeRange::Year }
    its(:year) { should eq 2009 }
  end

  describe '.from_time' do
    let(:time) { Time.mktime(2015, 12, 3) }

    subject(:range) { DoubleEntry::TimeRange::Year.from_time(time) }

    it { should be_a DoubleEntry::TimeRange::Year }
    its(:year) { should eq 2015 }
  end

  describe '#==' do
    subject(:range) { DoubleEntry::TimeRange::Year.new(:year => 2007) }

    context 'with an equal range' do
      let(:other) { DoubleEntry::TimeRange::Year.new(:year => 2007) }

      it 'returns true' do
        expect(range == other).to be true
      end
    end

    context 'with an equal range' do
      let(:other) { DoubleEntry::TimeRange::Year.new(:year => 2010) }

      it 'returns true' do
        expect(range == other).to be false
      end
    end
  end

  describe '#previous' do
    let(:previous_range) { DoubleEntry::TimeRange::Year.new(:year => 1986) }

    subject(:range) { DoubleEntry::TimeRange::Year.new(:year => 1987) }

    its(:previous) { should eq previous_range }
  end

  describe '#next' do
    let(:next_range) { DoubleEntry::TimeRange::Year.new(:year => 1700) }

    subject(:range) { DoubleEntry::TimeRange::Year.new(:year => 1699) }

    its(:next) { should eq next_range }
  end

  describe '#to_s' do
    subject(:range) { DoubleEntry::TimeRange::Year.new(:year => 2008) }

    its(:to_s) { should eq '2008' }
  end
end
