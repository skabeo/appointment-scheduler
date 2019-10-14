# frozen_string_literal: true

class User < ApplicationRecord
  has_many :availabilities

  # to successfully work
  # with String '.in_time_zone'
  def parse_time_zone
    time_zone.gsub(/\(GMT.*?\)\s/, '')
  end
end
