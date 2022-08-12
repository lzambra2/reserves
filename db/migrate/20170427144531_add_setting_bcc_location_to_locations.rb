# frozen_string_literal: true

class AddSettingBccLocationToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :setting_bcc_location_on_new_item, :boolean, default: false
  end
end
