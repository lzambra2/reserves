# frozen_string_literal: true

class RequestsController < ApplicationController
  before_action :set_request,
                only: %i[show edit update destroy change_status change_owner assign rollover
                         rollover_confirm archive]
  authorize_resource

  def index
    if current_user.admin?
      @requests = Request.all.limit(200)
    else
      redirect_to requests_user_url(current_user)
    end
  end

  def show
    @admin_users = User.admin.active.where(location_id: @request.reserve_location.id).to_a
    @admin_users.push(current_user) unless @admin_users.include?(current_user)
  end

  def edit; end

  def update
    @request.audit_comment = 'Request Updated'
    respond_to do |format|
      if params[:request][:user]
        @request.requester.update(office: params[:request][:user][:office],
                                  department: params[:request][:user][:department], phone: params[:request][:user][:phone])
      end
      # params[:audit_comment] = "Updated Request"
      if @request.update(request_params)
        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @request.audit_comment = 'Request Deleted'
    @request.destroy
    respond_to do |format|
      format.html { redirect_to requests_url }
      format.json { head :no_content }
    end
  end

  ## ADDITIONAL ACTIONS ##
  def change_status
    status = params[:status]
    @request.audit_comment = "Request status changed to #{status}"

    notice = "Status changed to #{status}"
    case status
    when Request::OPEN
      # ret = @request.updates()
      if @request.assigned_to
        @request.audit_comment = "Request has been Re-opened, status changed to #{status} and request has been unassigned"
        @request.update(status: status)
        @request.update(assigned_to: nil)
        notice = "Status changed to #{status} and request has been unassigned"
      else
        @request.update(status: status)
      end
      RequestMailer.status_change(@request, current_user).deliver_later
    when Request::INPROGRESS
      @request.update(status: status, assigned_to_id: current_user.id)
      # RequestMailer.status_change(@request, current_user).deliver_later
    when Request::COMPLETED
      @request.update(status: status, completed_date: Date.today) if @request.status != Request::CANCELLED
      RequestMailer.status_change(@request, current_user).deliver_later
    when Request::CANCELLED
      if @request.status != Request::COMPLETED
        @request.status = status
        @request.cancelled_date = Date.today
        @request.save(validate: false)
      end
      # RequestMailer.status_change(@request, current_user).deliver_later
    when Request::REMOVED
      if @request.status != Request::OPEN
        @request.status = status
        @request.removed_at = Date.today
        @request.removed_by_id = current_user.id
        @request.save(validate: false)

        # RequestMailer.status_change(@request, current_user).deliver_later
      end
    else
      # nothing is changed
      notice = "Status hasn't changed"
    end

    if @request.errors.size.zero?
      redirect_to request_path(@request), notice: notice
    else
      render :edit, notice: 'There are required fields missing, please fill them in'
    end
  end

  def change_owner
    new_owner = User.find(params[:requester_id])
    @request.audit_comment = "Requester changed from #{@request.requester.name} to #{new_owner.name}"
    @request.requester = new_owner
    @request.save(validate: false)

    redirect_to request_path(@request)
  end

  def archive
    if @request.status == Request::COMPLETED
      @request.status = Request::REMOVED
      @request.removed_at = Date.today
      @request.removed_by_id = current_user.id
      @request.audit_comment = "Request has been removed #{status}"
      @request.save(validate: false)
      # RequestMailer.status_change(@request, current_user).deliver_later
    end

    redirect_to request_path(@request), notice: 'Your item(s) will be removed from reserve.'
  end

  def assign
    id = params[:who]
    u = User.find_by_id(id)

    name = u.nil? ? 'Unassigned' : u.name
    @request.audit_comment = "Request assigned to #{name}"
    @request.update(assigned_to_id: id)
    redirect_to request_path(@request), notice: "Assigned to #{name}"
  end

  def rollover_confirm; end

  def rollover
    course_year = params[:rollover] ? params[:rollover][:course_year] : ''
    course_term = params[:rollover] ? params[:rollover][:course_term] : ''
    course_section = params[:rollover] ? params[:rollover][:course_section] : ''
    course_credits = params[:rollover] ? params[:rollover][:course_credits] : ''
    course_student_count = params[:rollover] ? params[:rollover][:course_student_count] : ''
    @new_request = @request.rollover(course_year, course_term, course_section, course_credits)
    @new_request.course.update(student_count: course_student_count)

    redirect_to edit_request_path(@new_request), notice: 'Your item(s) will be kept on reserve.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    course_attributes = %i[id name code instructor student_count _destroy year faculty subject
                           term credits section term course_id]

    params.require(:request).permit(:requested_date, :reserve_start_date, :reserve_end_date, :status, :reserve_location_id, :course_id, :reserve_location, :audit_comment, :requester_email,
                                    course_attributes: course_attributes)
  end
end
