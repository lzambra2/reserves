# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :set_request
  before_action :set_item, except: %i[index new create]
  authorize_resource

  def index
    @items = if params[:status] == Item::STATUS_DELETED
               @request.items.deleted
             else
               @request.items.active
             end
  end

  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @item = @request.items.new
    type = Item::TYPE_BOOK
    type = params[:type].downcase unless params[:type].nil?

    @item.item_type = type

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @item = @request.items.new(item_params)
    @item.status = Item::STATUS_NOT_READY
    @item.audit_comment = "Added Item: #{@item.title}"

    respond_to do |format|
      if @item.save
        @request.update(status: Request::OPEN)
        RequestMailer.new_item_notification(@request, @item).deliver_later

        format.html { redirect_to [@request, @item], notice: 'Item was successfully created.' }
        format.js
      else
        format.html { render action: 'new' }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      @item.audit_comment = "Updated Item: #{@item.title}"

      if @item.update(item_params)
        format.html { redirect_to [@request, @item], notice: 'Item was successfully updated.' }
        format.js
      else
        format.html { render action: 'edit' }
        format.js
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.audit_comment = "Item #{@item.title} removed from request"
    @item.destroy
    respond_to do |format|
      format.html { redirect_to @request }
      format.js
    end
  end

  ## ADDITIONAL ACTIONS ##
  def change_status
    status = params[:status]
    @item.status = Item::STATUS_NOT_READY if @item.status.blank?

    # Toggle between ready or not ready.
    case @item.status
    when Item::STATUS_NOT_READY
      @item.status = Item::STATUS_READY
    when Item::STATUS_READY
      @item.status = Item::STATUS_NOT_READY
    end

    @item.status = Item::STATUS_DELETED if status == Item::STATUS_DELETED && @request.status == Request::REMOVED

    @item.audit_comment = "#{@item.title} status changed to #{@item.status}"

    @item.save(validate: false)
    respond_to do |format|
      format.html { redirect_to @request, noitce: "Item status changed to #{status}" }
      format.js
    end
  end

  def barcode; end

  private

  def set_request
    @request = Request.find(params[:request_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = @request.items.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    item_attributes = %i[id title author description callnumber isbn publication_date edition publisher loan_period provided_by_requestor
                         metadata_source metadata_source_id _destroy request_id item_type copyright_options other_copyright_options url format map_index_num
                         page_number physical_copy_required journal_title issue volume ils_barcode]

    params.require(:item).permit(item_attributes)
  end
end
