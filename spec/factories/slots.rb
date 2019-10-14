# frozen_string_literal: true

FactoryBot.define do
  factory :slot do
    available { true }
    start { '9:00AM' }
  end
end
