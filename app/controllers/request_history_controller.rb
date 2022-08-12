# frozen_string_literal: true

class RequestHistoryController < ApplicationController
  before_action :set_request
  authorize_resource User
  # skip_authorization_check

  def index
    @audits = @request.audits | @request.associated_audits # | @request.course.audits
    @audits.sort! { |a, b| a.created_at <=> b.created_at }

    @audits_grouped = @audits.reverse.group_by { |a| a.created_at.at_beginning_of_day }

    @users = User.all
    @locations = Location.active

    render partial: 'history_log', layout: false if request.xhr?
  end

  def create
    # @aud = Audited::Adapters::ActiveRecord::Audit.new
    @aud = Audited::Audit.new
    @aud.action = 'note'
    @aud.user = current_user
    @aud.auditable = @request
    @aud.audited_changes = 'Note Added'
    @aud.comment = params[:audit_comment]

    respond_to do |format|
      if @aud.comment.blank?
        format.html { redirect_to history_request_path(@request), alert: 'Note is blank. Nothing updated' }
        format.js
      elsif @aud.comment.length > 255
        format.html { redirect_to history_request_path(@request), alert: 'Note is more than 255 characters!' }
        format.js
      elsif @aud.save
        format.html { redirect_to history_request_path(@request), notice: 'Note saved' }
        format.js
      else
        format.html do
          redirect_to history_request_path(@request), alert: 'Note not saved. Please contact application administrator'
        end
      end
    end
  end

  private

  def set_request
    @request = Request.find(params[:id])
  end
end
