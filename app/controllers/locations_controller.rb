class LocationsController < ApplicationController
  before_action :set_location, only: %i[show edit update destroy]
  authorize_resource

  def index
    @locations = Location.active
  end

  def show
    set_location
  end

  def new
    @location = Location.new
  end

  def edit; end

  def create
    @location = Location.new(location_params)
    @location.is_deleted = false

    respond_to do |format|
      if @location.save
        format.html { redirect_to locations_path, notice: 'Location was successfully created.' }
        # format.json { render action: 'show', status: :created, location: @location }
      else
        format.html { render action: 'new' }
        # format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to locations_path, notice: 'Location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # @location.destroy
    # @location = Location.find(params[:id])
    @location.is_deleted = true

    respond_to do |format|
      if @location.save
        format.html do
          redirect_to locations_path, notice: 'Location was successfully flagged as deleted and removed from the list.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params[:location][:disallowed_item_types].reject! { |t| t == '' } if params[:location][:disallowed_item_types]
    params.require(:location).permit(:name, :contact_email, :contact_phone,
                                     :setting_bcc_location_on_new_item, :setting_bcc_request_status_change, :acquisitions_email,
                                     :ils_location_name, :address, disallowed_item_types: [])
  end
end
