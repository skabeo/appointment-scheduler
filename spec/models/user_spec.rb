# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Associations' do
    context 'has_many availailbities' do
      it 'succeeds' do
        coach = create :coach, name: 'Bob Smithe', time_zone: '(GMT-06:00) Central Time (US & Canada)'
        coach.availabilities.create!(day_of_week: 1, start: '9:00AM', end: '11:30AM')
        coach.availabilities.create!(day_of_week: 3, start: '1:00PM', end: '3:00PM')
        expect(coach.availabilities.count).to eq 2
      end
    end
  end

  describe '.parse_time_zone' do
    subject { described_class.new }

    it 'successfully returns time zone without GMT' do
      subject.time_zone = '(GMT-06:00) Central Time (US & Canada)'
      expect(subject.parse_time_zone).to eq 'Central Time (US & Canada)'

      subject.time_zone = '(GMT-09:00) America/Yakutat'
      expect(subject.parse_time_zone).to eq 'America/Yakutat'
    end

    it 'successfully returns time zone if nothing found to parse' do
      subject.time_zone = 'Central Time (US & Canada)'
      expect(subject.parse_time_zone).to eq 'Central Time (US & Canada)'

      subject.time_zone = 'America/Yakutat'
      expect(subject.parse_time_zone).to eq 'America/Yakutat'
    end
  end
end
