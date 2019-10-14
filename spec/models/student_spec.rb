# frozen_string_literal: false

require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'Validations' do
    subject { described_class.new }

    context 'validates name is present' do
      it 'succeeds w/name' do
        subject.name = 'Charlie Chan'
        expect(subject.save).to be_truthy
      end

      it 'fails without name' do
        subject.name = ''
        expect(subject.save).to be_falsey
      end
    end
  end

  describe '#to_coaches_time_zone' do
    subject { described_class.new }

    context 'successfully converts a students time zone to a coaches time zone' do
      let(:start) { '9:30AM' }
      let(:finish) { '5:00PM' }
      let(:day_of_week) { Availability::DAYS_OF_WEEK.index('Monday') }
      let(:student) { create :student }
      let(:coach) { create :coach }

      before :each do
        slots = Slot.new.generate_time_slots(start_time: start, finish_time: finish)
        availability = coach.availabilities.create!(day_of_week: day_of_week, start: start, end: finish)
        slots.map { |slot_time| create :slot, availability: availability, start: slot_time }
      end

      it 'Eastern to Central Time' do
        student.update!(time_zone: '(GMT-05:00) Eastern Time (US & Canada)')
        coach.update!(time_zone: '(GMT-06:00) Central Time (US & Canada)')

        slot = Slot.first
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('9:30AM')
        expect(local_time.strftime('%l:%M').strip).to eq('10:30')
      end

      it 'Central to Eastern Time' do
        student.update!(time_zone: '(GMT-06:00) Central Time (US & Canada)')
        coach.update!(time_zone: '(GMT-05:00) Eastern Time (US & Canada)')

        slot = Slot.first
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('9:30AM')
        expect(local_time.strftime('%l:%M').strip).to eq('8:30')
      end

      it 'Central to Pacific Time' do
        student.update!(time_zone: '(GMT-06:00) Central Time (US & Canada)')
        coach.update!(time_zone: '(GMT-07:00) Pacific Time (US & Canada)')

        slot = Slot.first
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('9:30AM')
        expect(local_time.strftime('%l:%M').strip).to eq('11:30')
      end

      it 'Pacific to Central Time' do
        student.update!(time_zone: '(GMT-07:00) Pacific Time (US & Canada)')
        coach.update!(time_zone: '(GMT-06:00) Central Time (US & Canada)')

        slot = Slot.where(start: '11:30AM').first
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('11:30AM')
        expect(local_time.strftime('%l:%M').strip).to eq('9:30')
      end

      it 'Pacific to Eastern Time' do
        student.update!(time_zone: '(GMT-07:00) Pacific Time (US & Canada)')
        coach.update!(time_zone: '(GMT-05:00) Eastern Time (US & Canada)')

        slot = Slot.last
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('5:00PM')
        expect(local_time.strftime('%l:%M').strip).to eq('2:00')
      end

      it 'Eastern to Pacific Time' do
        student.update!(time_zone: '(GMT-05:00) Eastern Time (US & Canada)')
        coach.update!(time_zone: '(GMT-07:00) Pacific Time (US & Canada)')

        slot = Slot.first
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('9:30AM')
        expect(local_time.strftime('%l:%M').strip).to eq('12:30')
      end

      it 'Eastern to Eastern Time will be unchanged' do
        student.update!(time_zone: '(GMT-05:00) Eastern Time (US & Canada)')
        coach.update!(time_zone: '(GMT-05:00) Eastern Time (US & Canada)')

        slot = Slot.first
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('9:30AM')
        expect(local_time.strftime('%l:%M').strip).to eq('9:30')
      end

      it 'Pacific to Pacific Time will be unchanged' do
        student.update!(time_zone: '(GMT-07:00) Pacific Time (US & Canada)')
        coach.update!(time_zone: '(GMT-07:00) Pacific Time (US & Canada)')

        slot = Slot.first
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('9:30AM')
        expect(local_time.strftime('%l:%M').strip).to eq('9:30')
      end

      it 'Central to Central Time will be unchanged' do
        student.update!(time_zone: '(GMT-06:00) Central Time (US & Canada)')
        coach.update!(time_zone: '(GMT-06:00) Central Time (US & Canada)')

        slot = Slot.first
        local_time = student.to_coaches_time_zone(time: slot.start, coach: coach)
        expect(slot.start).to eq('9:30AM')
        expect(local_time.strftime('%l:%M').strip).to eq('9:30')
      end
    end
  end
end
