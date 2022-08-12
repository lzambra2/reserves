# frozen_string_literal: true

class HomeController < ApplicationController
  authorize_resource User
  before_action :redirect_if_regular_user

  def index
    ### check which status we're extrating
    @which = params[:which] || Request::OPEN

    @requests = case @which
                when Request::INPROGRESS
                  Request.in_progress
                when Request::COMPLETED
                  Request.completed.order('completed_date desc')
                when Request::CANCELLED
                  Request.cancelled.order('cancelled_date desc')
                when Request::REMOVED
                  Request.removed.order('removed_at desc')
                when Request::UPCYCLED
                  Request.upcycled.order('created_at desc')
                when Request::INCOMPLETE
                  Request.incomplete.order('created_at desc')
                when 'expiring'
                  Request.expiring_soon
                else
                  Request.open
                end

    ## location, nil is all locations
    location_id = params[:location] || nil

    if location_id.nil?
      ## home location
      @location = Location.find_by_id(current_user.location.id)
      @admin_users = User.admin.active.where(location_id: @location.id)
      @requests = @requests.where(reserve_location_id: @location.id)

    elsif location_id == 'all'
      @location = Location.new(name: 'All Locations')
      @admin_users = User.admin.active
      # no need to filter by location
    else
      @location = Location.find_by_id(location_id) # for admin and supervisors

      @location = current_user.location if current_user.role == User::STAFF_ROLE # for regular users
      @admin_users = User.admin.active.where(location_id: @location.id)

      @requests = @requests.where(reserve_location_id: @location.id)
    end

    if params[:assigned_to] == 'unassigned'
      @requests = @requests.where(assigned_to_id: nil)
      @assigned_to = User.new(name: 'Nobody')
    elsif !params[:assigned_to].nil?
      @requests = @requests.where(assigned_to_id: params[:assigned_to])
      @assigned_to = User.admin.active.find(params[:assigned_to])
    end

    ## paginate
    @requests = @requests.page(params[:page]).per(50)

    @locations = Location.active
  end

  private

  def redirect_if_regular_user
    redirect_to requests_user_url(current_user) unless current_user.admin?
  end
end
