class RequestWizardController < ApplicationController
  before_action :set_request, only: %i[step_two finish]
  authorize_resource :request

  def step_one
    if current_user.valid?
      @request = Request.new
      @request.course = Course.new
      @request.requester = current_user
    else
      redirect_to edit_user_path(current_user)
    end
  end

  def save
    @request = Request.new(request_params)
    @request.status = Request::INCOMPLETE
    current_user.update_attributes(office: params[:request][:user][:office], department: params[:request][:user][:department],
                                   phone: params[:request][:user][:phone])

    @request.requester_id = current_user.id

    @request.audit_comment = 'Request Step One Completed'
    if @request.save
      redirect_to new_request_step_two_path(@request), notice: 'Proceeding to Step 2.'
    else
      render action: 'step_one'
    end
  end

  def step_two
    @items = @request.items.recent_first # if any
  end

  def finish
    if @request.items.size > 0
      @request.audit_comment = 'Request Step Two Completed'
      @request.status = Request::OPEN
      @request.requested_date = Date.today.to_date

      if @request.save
        RequestMailer.status_change(@request, current_user).deliver_later
        redirect_to @request
      else
        redirect_to edit_request_path(@request), alert: 'There are fields missing in this request'
      end

    else
      redirect_to new_request_step_two_path(@request),
                  alert: 'You must add at least one item for this request to be submitted!'
    end
  end

  #### PRIVATE METHODS ###
  private

  def set_request
    @request = Request.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    course_attributes = %i[id name code instructor student_count _destroy year faculty subject term
                           credits section term course_id]

    params.require(:request).permit(:requested_date, :reserve_start_date, :reserve_end_date, :status, :reserve_location_id, :course_id, :reserve_location, :requester_email,
                                    course_attributes: course_attributes)
  end
end
