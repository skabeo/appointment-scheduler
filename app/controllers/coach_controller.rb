# frozen_string_literal: true

class CoachController < ApplicationController
  def index
    @coaches = Coach.all # TODO: Skip fully booked coaches!
  end

  def show
    @coach = Coach.includes(:availabilities).find(params[:id])
    @student = Student.find(session[:student_id])
    @slots = Slot.all_with_availabilities(@coach.availabilities.ids)
  end
end
