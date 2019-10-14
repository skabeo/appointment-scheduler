# frozen_string_literal: true

class AppointmentController < ApplicationController
  def show; end

  def create
    slot = Slot.find(appointment_params[:slot_id])
    appointment = Appointment.new(slot_id: slot.id, coach_id: slot.availability.user.id,
                                  student_id: session[:student_id])

    if appointment.save
      slot.update_attributes(available: false)
      redirect_to action: :show, id: appointment.id
    else
      render controller: :coach, action: :show, id: slot.availability.user.id
    end
  end

  private

  def appointment_params
    params.permit(:slot_id)
  end
end
