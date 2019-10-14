# frozen_string_literal: true

# Coaching Availabilities
# represented as starting time slots
class Slot < ApplicationRecord
  belongs_to :availability

  using Refinements
  DURATION_IN_MINUTES = 30

  def generate_time_slots(start_time:, finish_time:)
    start_time.remove_all_spaces! # TODO: move this to the importer
    finish_time.remove_all_spaces! # TODO: move this to the importer
    validate_duration_in_minutes
    validate_times(start_time, finish_time)
    compile_and_return_time_slots(Time.parse(start_time), Time.parse(finish_time))
  end

  class << self
    # N + 1 fix
    def all_with_availabilities(ids)
      includes(:availability).where('availability_id IN (?)', ids).references(:availability)
    end
  end

  private

  def validate_duration_in_minutes
    error_message = "DURATION_IN_MINUTES '#{DURATION_IN_MINUTES}' failed validation."
    raise ArgumentError, error_message unless [15, 30, 60].include? DURATION_IN_MINUTES
  end

  def validate_times(*times)
    times.each do |time|
      raise(ArgumentError, "Time '#{time}' failed validation.") unless regex_match_by_time_format(time)
    end
  end

  def regex_match_by_time_format(time)
    time.match(/^[0-9]{1,2}\:[0-9]{2}?[AP][M]/i)
  end

  # FIXME: Fix 'start_time' bug...
  #
  # ...when start_time is on the half hour (9:30AM),
  # we incorrectly get 1 extra time slot.
  #
  # Formula:
  #
  #   (finish_time - start_time) * (60 / DURATION_IN_MINUTES)
  #
  # Examples:
  #
  #   => start time = 9:00
  #   => finish time = 15:00
  #   => DURATION_IN_MINUTES = 30
  #
  #   60 / 30 = 2 (half hour)
  #   (15 - 9) * 2 = 12 time slots
  #
  #   Doubling the number of iterations, giving us the ability to
  #   fill time slots for every 30 minutes.
  #
  #   => DURATION_IN_MINUTES = 15
  #
  #   60 / 15 = 4 (quarter hour)
  #   (15 - 9) * 4 = 24 time slots
  #
  #   Quadrupling the number of iterations, giving us the ability
  #   to fill time slots for every 15 minutes.
  #
  def compile_and_return_time_slots(start, finish)
    slots = []
    total = num_slots(start, finish)
    1.upto(total) do
      slots << start.to_formatted_string
      start += (DURATION_IN_MINUTES * 60)
    end
    slots
  end

  def num_slots(start, finish)
    (finish.hour - start.hour) * (60 / DURATION_IN_MINUTES)
  end
end
