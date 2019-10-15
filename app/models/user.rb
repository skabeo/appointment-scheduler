# frozen_string_literal: true

class User < ApplicationRecord
  has_many :availabilities

  # TODO: Think about storing this with it pre-parsed
  # To successfully work with String '.in_time_zone'
  def parse_time_zone
    time_zone.gsub(/\(GMT.*?\)\s/, '')
  end
end
