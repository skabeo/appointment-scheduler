class HomeController < ApplicationController
  def index
    @student_id = session[:student_id]
  end
end
