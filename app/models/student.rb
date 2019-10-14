# frozen_string_literal: true

class Student < User
  using Refinements
  validates :name, presence: true

  def to_coaches_time_zone(time:, coach:)
    coaches_time_zone = "#{time} #{coach.parse_time_zone}"
    coaches_time_zone.in_time_zone(parse_time_zone).no_dst
  end
end
