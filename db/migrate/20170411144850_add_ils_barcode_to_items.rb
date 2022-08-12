# frozen_string_literal: true

class AddIlsBarcodeToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :ils_barcode, :string
  end
end
