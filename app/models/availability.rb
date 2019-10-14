# frozen_string_literal: true

class Availability < ApplicationRecord
  belongs_to :user
  has_many :slots

  DAYS_OF_WEEK = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
end
