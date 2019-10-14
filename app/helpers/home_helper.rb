# frozen_string_literal: true

module HomeHelper
  def get_route(student_id)
    if student_id
      coaches_path
    else
      student_new_path
    end
  end
end
