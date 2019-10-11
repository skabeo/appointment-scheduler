#
# MonkeyPatch++
# 
# Localize the Monkey Patch via Refinements to avoid global conflicts.
# 
# More info:
# https://ruby-doc.org/core-2.5.0/doc/syntax/refinements_rdoc.html
#
module Refinements

  refine String do
    def remove_all_spaces!
      self.gsub!(/\s+/, '')
    end
  end

  refine Time do
    def to_formatted_string
      self.strftime("%l:%M%p").strip
    end
  end

end