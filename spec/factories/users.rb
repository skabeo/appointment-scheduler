# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    name { 'Charles Student' }
    type { 'Student' }
    time_zone { '(GMT-06:00) Central Time (US & Canada)' }
  end

  factory :coach do
    name { 'Bob Coach' }
    type { 'Coach' }
    time_zone { '(GMT-06:00) Central Time (US & Canada)' }
  end
end
