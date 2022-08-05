class Requests::CopyItemsController < ApplicationController
  before_action :set_request
  authorize_resource Request

  def show
    @user_requests = current_user.requests.visible.where('id <> ?', @request.id)
  end

  def new
    @from_request = if params[:from_request_id]
                      current_user.requests.find_by_id(params[:from_request_id])
                    else
                      Request.find_by_id(params[:custom_id])
                    end

    @items = @from_request.nil? ? [] : @from_request.items.active
  end

  def create
    from_request = Request.find_by_id(params[:from_request_id])

    @item_copier = Item::Copy.new

    @item_copier.copy_items(from_request, @request)

    redirect_to @request, notice: 'Copied items to this request'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:request_id])
  end
end
