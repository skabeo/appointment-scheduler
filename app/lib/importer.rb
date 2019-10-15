# frozen_string_literal: true

require 'csv'

# Open a CSV file, loop it, and add the results
# to the appropriate Database tables.
#
# Assumptions:
#
# 1. The CSV file is small, has headers, and the
#    data contained within it is generally correct.
#    The data is always formatted the same and
#    always using the same case.
#
# 2. Any errors hit during the import will simply
#    be skipped, there is no retrying.
#
# 3. We are never going to be dealing with BIG DATA
#    so our looping shouldn't have any negative
#    side effects.
#
# 4. However the data exists today in the CSV is how
#    the data will exist in the future. For example,
#    there are only Available At times on the hour,
#    never on the half hour or quarter hour. The Day
#    of Week values are all Capitalized, etc...
#
class Importer
  class << self
    def from_csv(path)
      counter = 0
      CSV.foreach(path, headers: true, return_headers: false,
                        header_converters: :symbol, converters: :all) do |row|
        ActiveRecord::Base.transaction do
          # No duplicate coaches shall be added!
          coach = Coach.create_with(time_zone: row[:timezone]).find_or_create_by!(name: row[:name])

          # Translate the String into an Integer based upon the index value
          day_of_week = Availability::DAYS_OF_WEEK.index(row[:day_of_week])

          # Housekeeping
          start_time = row[:available_at].strip
          finish_time = row[:available_until].strip

          # Create all coach availabilities
          availability = coach.availabilities.create!(day_of_week: day_of_week,
                                                      start: start_time, end: finish_time)

          # Array of generated times
          slots_array = Slot.new.generate_time_slots(start_time: start_time, finish_time: finish_time)

          # Create all slots in DB
          slots_array.map { |slot_time| Slot.create!(availability: availability, start: slot_time) }

          counter += 1
        end
      end

      counter
    end
  end
end
