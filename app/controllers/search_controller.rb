# frozen_string_literal: true

class SearchController < ApplicationController
  include ApplicationHelper

  authorize_resource Request

  def index
    @query = q = params[:q]
    @type = params[:type]

    if @type == 'users'
      @users = search_users(q)
    else
      @requests = search_requests(q)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def search_users(q)
    if q.blank?
      @users = User.active.all
    else
      begin
        @users = User.search(q).records.records
      rescue StandardError
        @users = User.active.all
      end
    end
  end

  def search_requests(q)
    if is_number?(q)
      requests = Request.where(id: q)
    elsif q.starts_with?('i:')
      item_id = q.split('i:').last.strip
      i = Item.includes(:request).find(item_id)
      requests = [i.request]
    elsif Setting.search_elastic_enabled.to_s == 'true'
      # s = "%#{q}%"
      # @requests = Request.joins(:course, :requester)
      #         .where("courses.name LIKE ? OR courses.code LIKE ? OR courses.instructor LIKE ? OR users.name LIKE ?","#{s}","#{s}", "#{s}", "#{s}")
      #
      #
      begin
        requests = Request.search(q, size: 40).page(params[:page]).records
      rescue StandardError
        requests = []
      end
    else
      s = "%#{q}%"
      requests = Request.joins(:course, :requester)
                        .where('courses.name LIKE ? OR courses.code LIKE ? OR courses.instructor LIKE ? OR users.name LIKE ?', s.to_s, s.to_s, s.to_s, s.to_s)
                        .page(params[:page])
    end

    requests
  end
end
