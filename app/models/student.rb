class Student < User
  using Refinements
  validates :name, presence: true

  def to_coaches_time_zone(time:, coach:)
    localized = "#{time} #{coach.parse_time_zone}"
    localized.in_time_zone(self.parse_time_zone).no_dst
  end
end
