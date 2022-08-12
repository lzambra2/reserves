# frozen_string_literal: true

class AddLocationIdToAcquisitionRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :acquisition_requests, :location_id, :integer
  end
end
