# frozen_string_literal: true

class StudentController < ApplicationController
  before_action :setup_student, :setup_time_zones, only: [:new]

  def new; end

  def create
    student = Student.new(name: student_params[:name], time_zone: student_params[:time_zone])
    if student.save
      session[:student_id] = student.id
      redirect_to coaches_path
    else
      @student = student
      setup_time_zones
      render action: :new
    end
  end

  def logout
    session[:student_id] = nil
    redirect_to root_path
  end

  private

  def student_params
    params.require(:student).permit(:name, :time_zone)
  end

  def setup_student
    @student = Student.new
  end

  def setup_time_zones
    @time_zones = ActiveSupport::TimeZone.us_zones
  end
end
