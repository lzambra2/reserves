# frozen_string_literal: true

class AddIlsLocationNameToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :ils_location_name, :string
  end
end
