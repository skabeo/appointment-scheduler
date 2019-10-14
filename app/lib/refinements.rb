# frozen_string_literal: true

# MonkeyPatch++
# Localize the Monkey Patch via Refinements to avoid global conflicts.
# More: https://ruby-doc.org/core-2.5.0/doc/syntax/refinements_rdoc.html
module Refinements
  refine String do
    def remove_all_spaces!
      gsub!(/\s+/, '')
    end
  end

  refine Time do
    def to_formatted_string
      strftime('%l:%M%p').strip
    end
  end

  # Overcomes limitations with Ruby/Rails
  # Time. If we are in daylight savings
  # time then the '.utc' Time conversion
  # will be offset by 1 hour. Oooof!
  refine ActiveSupport::TimeWithZone do
    def no_dst
      dst? ? (self - 1.hour) : self
    end
  end
end
