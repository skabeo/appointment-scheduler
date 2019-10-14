# frozen_string_literal: false

require 'rails_helper'

RSpec.describe Availability, type: :model do
  describe 'Associations' do
    it 'belongs_to user' do
      coach = create :coach, name: 'Bob Smithe', time_zone: '(GMT-06:00) Central Time (US & Canada)'
      availability = coach.availabilities.create!(day_of_week: 1, start: '9:00am', end: '12:00pm')
      expect(availability.user_id).to eq coach.id
    end

    it 'has_many slots' do
      coach = create :coach, name: 'Bob Smithe', time_zone: '(GMT-06:00) Central Time (US & Canada)'
      availability = coach.availabilities.create!(day_of_week: 1, start: '8:00am', end: '9:00pm')
      slots = Slot.new.generate_time_slots(start_time: '8:00am', finish_time: '9:00pm')
      slots.map { |slot| Slot.create!(availability: availability, start: slot) }
      expect(availability.slots.count).to be > 1
    end
  end

  describe 'Constants' do
    context 'DAYS_OF_WEEK' do
      let(:days_of_week) { %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday] }

      describe 'Succeeds' do
        it 'is an Array' do
          expect(described_class::DAYS_OF_WEEK.is_a?(Array)).to be_truthy
          expect(described_class::DAYS_OF_WEEK.is_a?(String)).to be_falsey
        end

        it 'contains all 7 days of the week' do
          expect(described_class::DAYS_OF_WEEK).to eq days_of_week
        end

        it 'contains days of the week in correct order' do
          expect(described_class::DAYS_OF_WEEK).to eq days_of_week
          expect(described_class::DAYS_OF_WEEK).to_not eq days_of_week.reverse
        end

        it 'each day of the week is capitalized' do
          days_of_week.each_with_index do |day, index|
            expect(described_class::DAYS_OF_WEEK[index][0]).to eq day[0].upcase
            expect(described_class::DAYS_OF_WEEK[index][0]).to_not eq day[0].downcase
          end
        end
      end

      describe 'Fails' do
        it 'when mixed case' do
          mixed_case = %w[SunDAY Monday Tuesday Wednesday Thursday Friday Saturday]
          expect(described_class::DAYS_OF_WEEK).to_not eq(mixed_case)

          mixed_case = %w[SuNday MondaY TUESDAy WedNesday tHursday friDay satUrday]
          expect(described_class::DAYS_OF_WEEK).to_not eq(mixed_case)
        end

        it 'when not capitalized' do
          not_capitalized = %w[sunday Monday Tuesday Wednesday Thursday Friday Saturday]
          expect(described_class::DAYS_OF_WEEK).to_not eq(not_capitalized)

          not_capitalized = %w[Sunday Monday Tuesday wednesday Thursday Friday Saturday]
          expect(described_class::DAYS_OF_WEEK).to_not eq(not_capitalized)

          not_capitalized = %w[Sunday Monday Tuesday Wednesday Thursday Friday saturday]
          expect(described_class::DAYS_OF_WEEK).to_not eq(not_capitalized)
        end
      end
    end
  end
end
