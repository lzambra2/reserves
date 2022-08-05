class SettingsController < ApplicationController
  authorize_resource Setting

  def edit; end

  def cat_search; end

  def elastic_search; end

  def email; end

  def item_request; end

  def help; end

  def acquisition_requests; end

  def update
    settings = params[:setting]

    settings.each do |key, value|
      Setting.send("#{key}=", value)
    end

    case params[:return_to]
    when 'email'
      redirect_to email_settings_path, notice: 'Saved Email Settings'
    when 'cat_search'
      redirect_to cat_search_settings_path, notice: 'Saved Catalog Search Settings'
    when 'item_request'
      redirect_to item_request_settings_path, notice: 'Saved Request and Item Settings'
    when 'help'
      redirect_to help_settings_path, notice: 'Saved Help Settings'
    when 'acquisition_requests'
      redirect_to acquisition_requests_settings_path, notice: 'Saved Acquisition Requests Settings'
    when 'elastic_search'
      redirect_to elastic_search_settings_path, notice: 'Saved Elastic Search Settings'
    when 'primo_alma'
      redirect_to primo_alma_settings_path, notice: 'Saved Primo and Alma Settings'
    else
      redirect_to edit_settings_path
    end
  end
end
