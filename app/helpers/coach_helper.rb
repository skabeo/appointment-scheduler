# frozen_string_literal: true

module CoachHelper
  def time_format(date_time)
    date_time.strftime('%l:%M %p').strip
  end

  def appointment_confirmation(slot, time, duration)
    "#{Availability::DAYS_OF_WEEK[slot.availability.day_of_week]} at #{time} for #{duration} minutes."
  end
end
