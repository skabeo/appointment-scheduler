require 'rails_helper'
# TODO: Flush out more specs
# TODO: Add Factory Girl/Bot
RSpec.describe Slot, type: :model do

  describe 'Associations' do
    context 'belongs_to availability' do
      it 'succeeds' do
        # TODO: Add Factory Girl (Factory Bot)
        coach = Coach.create!(name: 'Bob Smithe', time_zone: '(GMT-06:00) Central Time (US & Canada)')
        availability_1 = coach.availabilities.create!(day_of_week: 1, start: '9:00AM', end: '12:00PM')
        slots = described_class.generate(availability_1.start, availability_1.end)
        slots.map {|slot| described_class.create!(availability: availability_1, start: slot)}
        expect(described_class.first.availability).to eq availability_1
        expect(described_class.last.availability).to eq availability_1
      end
    end
  end

  describe '#localize' do

    subject {described_class.new}

    context 'successfully converts localities' do
      it 'Central to Eastern Time' do
        allow(subject).to receive(:start).and_return('9:30AM')
        allow_any_instance_of(Coach).to receive(:parse_time_zone).and_return('Central Time (US & Canada)')
        allow_any_instance_of(Student).to receive(:parse_time_zone).and_return('Eastern Time (US & Canada)')
        time = subject.localize(Coach.new, Student.new)
        expect(time.strftime("%l:%M").strip).to eq('10:30')
      end

      it 'Eastern to Central Time' do
        allow(subject).to receive(:start).and_return('9:30AM')
        allow_any_instance_of(Coach).to receive(:parse_time_zone).and_return('Eastern Time (US & Canada)')
        allow_any_instance_of(Student).to receive(:parse_time_zone).and_return('Central Time (US & Canada)')
        time = subject.localize(Coach.new, Student.new)
        expect(time.strftime("%l:%M").strip).to eq('8:30')
      end

    end

    context 'does not convert the same localities' do
      it 'Pacific to Pacific Time' do
        allow(subject).to receive(:start).and_return('9:30AM')
        allow_any_instance_of(Coach).to receive(:parse_time_zone).and_return('Pacific Time (US & Canada)')
        allow_any_instance_of(Student).to receive(:parse_time_zone).and_return('Pacific Time (US & Canada)')
        time = subject.localize(Coach.new, Student.new)
        expect(time.strftime("%l:%M").strip).to eq('9:30')
      end
    end
  end

  describe '.get_duration' do
    it 'succeeds when DURATION_IN_MINUTES <= 60' do
      stub_const('Slot::DURATION_IN_MINUTES', 60)
      expect(described_class.get_duration).to eq 60
      stub_const('Slot::DURATION_IN_MINUTES', 30)
      expect(described_class.get_duration).to eq 30
    end

    it 'default to 60 when DURATION_IN_MINUTES > 60' do
      stub_const('Slot::DURATION_IN_MINUTES', 61)
      expect(described_class.get_duration).to eq 60
      stub_const('Slot::DURATION_IN_MINUTES', 120)
      expect(described_class.get_duration).to eq 60
    end
  end

  describe '.all_with_availabilities' do
    # TODO: Use Factory Girl/Bot!
    # TODO: This is insane (and slow) to setup like this and should be fixed!
    before :each do
      start = '9:00AM'
      finish = '12:00PM'
      @coach = Coach.create!(name: 'Bob Smithe', time_zone: '(GMT-06:00) Central Time (US & Canada)')
      @availability_1 = @coach.availabilities.create!(day_of_week: 1, start: start, end: finish)
      slots = Slot.generate(start, finish)
      slots.map {|slot| Slot.create!(availability: @availability_1, start: slot)}

      start = '1:00PM'
      finish = '4:00PM'
      @availability_2 = @coach.availabilities.create!(day_of_week: 1, start: start, end: finish)
      slots = Slot.generate(start, finish)
      slots.map {|slot| Slot.create!(availability: @availability_2, start: slot)}
    end

    # TODO: More testing of this to assert/challenge N + 1 issue
    context 'successful' do
      it 'only 1 db request' do
        expect {described_class.all_with_availabilities(@coach.availabilities.ids)}.to make_database_queries(count: 1)
      end

      it 'returns 2 Availabilities' do
        slots = described_class.all_with_availabilities(@coach.availabilities.ids)
        expect(slots.first.availability.id).to eq @availability_1.id
        expect(slots.last.availability.id).to eq @availability_2.id
      end

      it 'returns 12 Slots' do
        slots = described_class.all_with_availabilities(@coach.availabilities.ids)
        expect(slots.count).to eq 12
      end

      it 'returns the correct Array of Slots' do
        times = ['9:00AM', '9:30AM', '10:00AM', '10:30AM', '11:00AM', '11:30AM', '1:00PM', '1:30PM', '2:00PM', '2:30PM', '3:00PM', '3:30PM']
        slots = described_class.all_with_availabilities(@coach.availabilities.ids)
        expect(slots.map(&:start)).to eq times
      end

      it 'returns the correct start and finish times' do
        start = '9:00AM'
        finish = '3:30PM'
        slots = described_class.all_with_availabilities(@coach.availabilities.ids)
        expect(slots.first.start).to eq start
        expect(slots.last.start).to eq finish
      end
    end

  end

  describe '.match' do

    # TODO: Think about a global Array of properly formatted times to iterate through
    it 'succeeds with different formatted times' do
      time = '9:00PM'
      expect(described_class.match(time)).to be_a_kind_of(MatchData)
      time = '10:00AM'
      expect(described_class.match(time)).to be_a_kind_of(MatchData)
      time = '10:00am'
      expect(described_class.match(time)).to be_a_kind_of(MatchData)
      time = '10:00Am'
      expect(described_class.match(time)).to be_a_kind_of(MatchData)
      time = '10:00aM'
      expect(described_class.match(time)).to be_a_kind_of(MatchData)
    end

    # TODO: Think about a global Array of poorly formatted times to iterate through
    context 'fails with misformatted times' do
      it 'with no meridian' do
        time = '9:00'
        expect(described_class.match(time)).to be_falsy
      end

      it 'with no : separator' do
        time = '900AM'
        expect(described_class.match(time)).to be_falsy
      end

      it 'with space in meridian' do
        time = '9:00A M'
        expect(described_class.match(time)).to be_falsy
      end

      it 'with space in the minutes' do
        time = '10:0 0am'
        expect(described_class.match(time)).to be_falsy
      end

      it 'with no time at all' do
        time = 'asdfasdf'
        expect(described_class.match(time)).to be_falsy
      end

      it 'with 3 digits in the hour' do
        time = '123:00AM'
        expect(described_class.match(time)).to be_falsy
      end

      it 'with 3 digits in the minute' do
        time = '12:123'
        expect(described_class.match(time)).to be_falsy
      end
    end
  end

  describe '.validate_times' do

    it 'succeeds with properly formatted times' do
      start = '9:00AM'
      finish = '3:00PM'
      expect {described_class.validate_times(start, finish)}.to_not raise_error
      start = '10:00am'
      finish = '9:00pm'
      expect {described_class.validate_times(start, finish)}.to_not raise_error
    end

    it 'fails with badly formatted times' do
      start = '9:00A M'
      finish = '3:0 0PM'
      expect {described_class.validate_times(start, finish)}.to raise_error(ArgumentError)
      start = '10:0 0am'
      finish = '9 :00pm'
      expect {described_class.validate_times(start, finish)}.to raise_error(ArgumentError)
    end
  end

  describe '.total_iterations' do

    let(:start) {Time.parse('9:00AM')}
    let(:finish) {Time.parse('3:00PM')}

    context 'succeeds' do
      it 'returns 6 for every 60 minutes' do
        stub_const('Slot::DURATION_IN_MINUTES', 60)
        expect(described_class.get_duration).to eq 60
        expect(described_class.total_iterations(start, finish)).to eq 6
      end

      it 'returns 12 for every 30 minutes' do
        stub_const('Slot::DURATION_IN_MINUTES', 30)
        expect(described_class.get_duration).to eq 30
        expect(described_class.total_iterations(start, finish)).to eq 12
      end

      it 'returns 24 for every 15 minutes' do
        stub_const('Slot::DURATION_IN_MINUTES', 15)
        expect(described_class.get_duration).to eq 15
        expect(described_class.total_iterations(start, finish)).to eq 24
      end
    end

    context 'fails' do
      describe "to return anything other than 6" do
        context 'for DURATION_IN_MINUTES > 60' do
          it 'fails with 61 minutes' do
            stub_const('Slot::DURATION_IN_MINUTES', 61)
            expect(described_class.get_duration).to eq 60
            expect(described_class.total_iterations(start, finish)).to eq 6
          end

          it 'fails with 120 minutes' do
            stub_const('Slot::DURATION_IN_MINUTES', 120)
            expect(described_class.get_duration).to eq 60
            expect(described_class.total_iterations(start, finish)).to eq 6
          end
        end
      end
    end
  end

  describe '.generate' do
    context 'succeeds' do

      let(:results) {%w(9:00AM 9:30AM 10:00AM 10:30AM 11:00AM 11:30AM 12:00PM 12:30PM 1:00PM 1:30PM 2:00PM 2:30PM)}

      it 'with expected arguments' do
        expect(described_class.generate('9:00am', '3:00pm')).to eq results
      end

      it 'with arguments containing spaces' do
        expect(described_class.generate('9:00 am', '3:00 pm')).to eq results
        expect(described_class.generate('9 :00 am', ' 3:00 pm')).to eq results
        expect(described_class.generate('9: 0 0 am', '3: 00 pm    ')).to eq results
      end

      it 'with different capitalization' do
        expect(described_class.generate('9:00Am', '3:00pM')).to eq results
        expect(described_class.generate('9:00AM', '3:00PM')).to eq results
      end

      it 'with different capitalization and spacing' do
        expect(described_class.generate('9:0 0Am', '3 :00pM')).to eq results
        expect(described_class.generate('9:00A M', '3:00P M')).to eq results
      end
    end

    context 'fails' do
      it 'without the first argument' do
        expect {described_class.generate('', '3:00pm')}.to raise_error(ArgumentError)
        expect {described_class.generate(nil, '3:00pm')}.to raise_error(NoMethodError)
      end

      it 'without the second argument' do
        expect {described_class.generate('9:00am', '')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00am', nil)}.to raise_error(NoMethodError)
      end

      it 'without both arguments' do
        expect {described_class.generate()}.to raise_error(ArgumentError)
        expect {described_class.generate('', '')}.to raise_error(ArgumentError)
        expect {described_class.generate(nil, nil)}.to raise_error(NoMethodError)
      end

      it 'without a properly formatted time String' do
        # TODO: Think about a global Array of poorly formatted times to iterate through
        expect {described_class.generate('900am', '3:00pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00am', '300pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00', '3:00pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00qw', '3:00pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00am', '300pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('999999:00am', '3:00pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:11111100am', '3:00pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00am', '1111113:00pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00am', '3:99999900pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00am', '3:00')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00am', '3:00qw')}.to raise_error(ArgumentError)
        expect {described_class.generate('asdfasdfasdf', '3:00pm')}.to raise_error(ArgumentError)
        expect {described_class.generate('9:00am', 'asdfasdfasdf')}.to raise_error(ArgumentError)
      end
    end
  end
end
