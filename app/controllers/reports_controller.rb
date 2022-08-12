# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :retrieve_params
  authorize_resource User

  def show
    # shows a list of presets (lifetime)
    @lt_requests_count = Request.all.count
    @lt_items_count = Item.all.count
    @lt_courses_count = Course.all.count
    @lt_requestors_count = User.active.users.count
    @lt_staff_count = User.active.admin.count

    # fiscal year to date
    @ytd_requests_count = Request.where('created_at >= ?', Setting.fiscal_date).count
    @ytd_items_count = Item.where('created_at >= ?', Setting.fiscal_date).count
    @ytd_courses_count = Course.where('created_at >= ?', Setting.fiscal_date).count
    @ytd_requestors_count = User.where('created_at >= ?', Setting.fiscal_date).active.users.count
    @ytd_staff_count = User.where('created_at >= ?', Setting.fiscal_date).active.admin.count
  end

  def requests
    @expiring_before = @report_params[:expiring_before]

    @requests = Request.all

    if @department.present? || @term.present? || @faculty.present?
      @courses = Course.all
      @courses = @courses.where(code_term: @term) if @term.present?
      @courses = @courses.where(code_subject: @department) if @department.present?
      @courses = @courses.where(code_faculty: @faculty) if @faculty.present?
      c_ids = @courses.collect(&:id).join(',')
      @requests = @requests.where("course_id IN (#{c_ids})")
    end

    @requests = @requests.where(status: @status) unless @status.blank?

    @requests = @requests.where(reserve_location_id: @location) unless @location.blank?

    @requests = @requests.expiring_soon(@expiring_before) unless @expiring_before.blank?

    @requests = @requests.where('created_at <= ?', @created_before) unless @created_before.blank?
    @requests = @requests.where('created_at >= ?', @created_after) unless @created_after.blank?

    @requests_grouped = @requests.group_by(&:reserve_location_id)

    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="requests_reports.xlsx"'
      end
    end
  end

  def items
    @item_types = @report_params[:item_types]

    @items = Item.includes(:request).all

    @items = @items.by_type(@item_types) unless @item_types.blank?

    if @department.present? || @term.present? || @faculty.present?
      @courses = Course.all
      @courses = @courses.where(code_term: @term) if @term.present?
      @courses = @courses.where(code_subject: @department) if @department.present?
      @courses = @courses.where(code_faculty: @faculty) if @faculty.present?
      c_ids = @courses.collect(&:id).join(',')
      @requests = Request.where("course_id IN (#{c_ids})")

      r_ids = @requests.collect(&:id).join(',')
      @items = @items.where("request_id IN(#{r_ids})")

    end

    # if !@department.blank?
    #   @courses = Course.where("code LIKE ?", "%_#{@department}_%")
    #   c_ids = @courses.collect{ |c| c.id }.join(",")
    #   @requests = Request.where("course_id IN (#{c_ids})")
    #   r_ids = @requests.collect { |r| r.id }.join(",")
    #   @items = @items.where("request_id IN(#{r_ids})")
    # end

    unless @location.blank?
      @requests = Request.where(reserve_location_id: @location)
      r_ids = @requests.collect(&:id).join(',')
      @items = @items.where("request_id IN(#{r_ids})")
    end

    @items = @items.where('created_at <= ?', @created_before) unless @created_before.blank?
    @items = @items.where('created_at >= ?', @created_after) unless @created_after.blank?

    @items_grouped = @items.group_by(&:item_type)
    @items_grouped_by_location = @items.group_by { |i| i.request&.reserve_location_id }

    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="items_reports.xlsx"'
      end
    end
  end

  private

  def retrieve_params
    @report_params = params[:r] || {}

    @location = @report_params[:location]
    @department = @report_params[:department]
    @created_before = @report_params[:created_before]
    @created_after = @report_params[:created_after]
    @status = @report_params[:status]
    @faculty = @report_params[:faculty]
    @term = @report_params[:term]
  end
end
