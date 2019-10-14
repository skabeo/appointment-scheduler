# frozen_string_literal: false

require 'rails_helper'
RSpec.describe Slot, type: :model do
  let(:subject) { described_class.new }

  describe 'Associations' do
    context 'belongs_to availability' do
      it 'succeeds' do
        coach = create :coach, name: 'Bob Smithe', time_zone: '(GMT-06:00) Central Time (US & Canada)'
        availability = coach.availabilities.create!(day_of_week: 1, start: '9:00AM', end: '12:00PM')
        slots = subject.generate_time_slots(start_time: availability.start, finish_time: availability.end)
        slots.map { |slot| described_class.create!(availability: availability, start: slot) }

        expect(described_class.first.availability).to eq availability
        expect(described_class.last.availability).to eq availability
      end
    end
  end

  describe '.all_with_availabilities' do
    let(:start1) { '9:00AM' }
    let(:finish1) { '12:00PM' }
    let(:start2) { '1:00PM' }
    let(:finish2) { '4:00PM' }
    let!(:coach) { create :coach, name: 'Bob Smithe', time_zone: '(GMT-06:00) Central Time (US & Canada)' }
    let!(:availability1) { coach.availabilities.create!(day_of_week: 1, start: start1, end: finish1) }
    let!(:availability2) { coach.availabilities.create!(day_of_week: 1, start: start2, end: finish2) }

    before do
      slots1 = subject.generate_time_slots(start_time: start1, finish_time: finish1)
      slots1.map { |slot1| Slot.create!(availability: availability1, start: slot1) }

      slots2 = subject.generate_time_slots(start_time: start2, finish_time: finish2)
      slots2.map { |slot2| Slot.create!(availability: availability2, start: slot2) }
    end

    # TODO: More testing of this to assert/challenge N + 1 issue
    context 'successful' do
      it 'only 1 db request' do
        expect { described_class.all_with_availabilities(coach.availabilities.ids) }
          .to make_database_queries(count: 1)
      end

      it 'returns 2 Availabilities' do
        slots = described_class.all_with_availabilities(coach.availabilities.ids)
        expect(slots.first.availability.id).to eq availability1.id
        expect(slots.last.availability.id).to eq availability2.id
      end

      it 'returns 12 Slots' do
        slots = described_class.all_with_availabilities(coach.availabilities.ids)
        expect(slots.count).to eq 12
      end

      it 'returns the correct Array of Slots' do
        times = ['9:00AM', '9:30AM', '10:00AM', '10:30AM', '11:00AM', '11:30AM',
                 '1:00PM', '1:30PM', '2:00PM', '2:30PM', '3:00PM', '3:30PM']
        slots = described_class.all_with_availabilities(coach.availabilities.ids)
        expect(slots.map(&:start)).to eq times
      end

      it 'returns the correct start and finish times' do
        start = '9:00AM'
        finish = '3:30PM'
        slots = described_class.all_with_availabilities(coach.availabilities.ids)
        expect(slots.first.start).to eq start
        expect(slots.last.start).to eq finish
      end
    end
  end

  describe '.regex_match_by_time_format' do
    it 'succeeds with different formatted times' do
      times = ['9:00PM', '10:00AM', '10:00am', '10:00Am', '10:00aM']
      times.each do |time|
        expect(subject.send(:regex_match_by_time_format, time)).to be_a_kind_of(MatchData)
      end
    end

    context 'fails with misformatted times' do
      it 'with no meridian' do
        time = '9:00'
        expect(subject.send(:regex_match_by_time_format, time)).to be_falsy
      end

      it 'with no : separator' do
        time = '900AM'
        expect(subject.send(:regex_match_by_time_format, time)).to be_falsy
      end

      it 'with space in meridian' do
        time = '9:00A M'
        expect(subject.send(:regex_match_by_time_format, time)).to be_falsy
      end

      it 'with space in the minutes' do
        time = '10:0 0am'
        expect(subject.send(:regex_match_by_time_format, time)).to be_falsy
      end

      it 'with no time at all' do
        time = 'asdfasdf'
        expect(subject.send(:regex_match_by_time_format, time)).to be_falsy
      end

      it 'with 3 digits in the hour' do
        time = '123:00AM'
        expect(subject.send(:regex_match_by_time_format, time)).to be_falsy
      end

      it 'with 3 digits in the minute' do
        time = '12:123'
        expect(subject.send(:regex_match_by_time_format, time)).to be_falsy
      end
    end
  end

  describe '.validate_duration_in_minutes' do
    it 'succeeds with 15, 30, or 60 only' do
      minutes = [15, 30, 60]
      minutes.each do |minute|
        stub_const('Slot::DURATION_IN_MINUTES', minute)
        expect { subject.send(:validate_duration_in_minutes) }.to_not raise_error
      end
    end

    it 'fails without a value of 15, 30, or 60' do
      minutes = [[1, 14], [16, 29], [31, 59], [61, 70]]
      minutes.each do |minute|
        minute.first.upto(minute.last) do |duration|
          stub_const('Slot::DURATION_IN_MINUTES', duration)
          expect { subject.send(:validate_duration_in_minutes) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '.validate_times' do
    it 'succeeds with properly formatted times' do
      times = [['9:00AM', '3:00PM'], ['10:00am', '9:00pm']]
      times.each do |time|
        expect { subject.send(:validate_times, time.first, time.last) }.to_not raise_error
      end
    end

    it 'fails with badly formatted times' do
      times = [['9:00A M', '3:0 0PM'], ['10:0 0am', '9 :00pm'], ['', '']]
      times.each do |time|
        expect { subject.send(:validate_times, time.first, time.last) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.compile_and_return_time_slots' do
    let(:start) { Time.parse('9:00AM') }
    let(:finish) { Time.parse('1:00PM') }

    context 'succeeds' do
      it 'returns correct time slots for every 60 minutes' do
        stub_const('Slot::DURATION_IN_MINUTES', 60)
        expect(subject.send(:compile_and_return_time_slots, start, finish))
          .to eq(['9:00AM', '10:00AM', '11:00AM', '12:00PM'])
      end

      it 'returns correct time slots for every 30 minutes' do
        stub_const('Slot::DURATION_IN_MINUTES', 30)
        expect(subject.send(:compile_and_return_time_slots, start, finish))
          .to eq(['9:00AM', '9:30AM', '10:00AM', '10:30AM', '11:00AM', '11:30AM', '12:00PM', '12:30PM'])
      end

      it 'returns correct time slots for every 15 minutes' do
        stub_const('Slot::DURATION_IN_MINUTES', 15)
        expect(subject.send(:compile_and_return_time_slots, start, finish))
          .to eq(['9:00AM', '9:15AM', '9:30AM', '9:45AM', '10:00AM', '10:15AM', '10:30AM', '10:45AM',
                  '11:00AM', '11:15AM', '11:30AM', '11:45AM', '12:00PM', '12:15PM', '12:30PM', '12:45PM'])
      end
    end

    context 'fails' do
      describe 'returns [] for DURATION_IN_MINUTES > 60' do
        it 'with 61 minutes' do
          stub_const('Slot::DURATION_IN_MINUTES', 61)
          expect(subject.send(:compile_and_return_time_slots, start, finish)).to eq([])
        end
      end

      describe 'raises error or returns [] for DURATION_IN_MINUTES < 1' do
        it 'with 0 minutes' do
          stub_const('Slot::DURATION_IN_MINUTES', 0)
          expect { subject.send(:compile_and_return_time_slots, start, finish) }
            .to raise_error(ZeroDivisionError)
        end

        it 'with -10 minutes' do
          stub_const('Slot::DURATION_IN_MINUTES', -10)
          expect(subject.send(:compile_and_return_time_slots, start, finish)).to eq([])
        end
      end
    end
  end

  describe '.generate_time_slots' do
    context 'succeeds' do
      let(:results) { %w[9:00AM 9:30AM 10:00AM 10:30AM 11:00AM 11:30AM 12:00PM 12:30PM 1:00PM 1:30PM] }

      it 'with expected arguments' do
        expect(subject.generate_time_slots(start_time: '9:00am', finish_time: '2:00pm')).to eq results
      end

      it 'with arguments containing spaces' do
        times = [['9:00 am', '2:00 pm'], ['9 :00 am', ' 2:00 pm'], ['9: 0 0 am', '2: 00 pm    ']]
        times.each do |time|
          expect(subject.generate_time_slots(start_time: time.first, finish_time: time.last)).to eq results
        end
      end

      it 'with mixed capitalization' do
        times = [['9:00Am', '2:00pM'], ['9:00AM', '2:00PM']]
        times.each do |time|
          expect(subject.generate_time_slots(start_time: time.first, finish_time: time.last)).to eq results
        end
      end

      it 'with mixed capitalization and spacing' do
        times = [['9:0 0Am', '2 :00pM'], ['9:00A M', '2:00P M']]
        times.each do |time|
          expect(subject.generate_time_slots(start_time: time.first, finish_time: time.last)).to eq results
        end
      end
    end

    context 'fails' do
      it 'without a proper time arguments' do
        times = [['900am', '2:00pm'], ['9:00am', '200pm'], ['9:00', '2:00pm'], ['9:00qw', '2:00pm'],
                 ['9:00am', '200pm'], ['999999:00am', '2:00pm'], ['9:11111100am', '2:00pm'],
                 ['9:00am', '1111113:00pm'], ['9:00am', '2:99999900pm'], ['9:00am', '2:00'],
                 ['9:00am', '2:00qw'], ['asdfasdfasdf', '2:00pm'], ['9:00am', 'asdfasdfasdf'],
                 ['', '8'], ['8:', ''], ['9:00am', '']]

        times.each do |time|
          expect { subject.generate_time_slots(start_time: time.first, finish_time: time.last) }
            .to raise_error(ArgumentError)
        end
      end
    end
  end
end
