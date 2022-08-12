# frozen_string_literal: true

class AddSettingsToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :setting_bcc_request_status_change, :boolean, default: false
  end
end
