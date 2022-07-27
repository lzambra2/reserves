class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.integer :request_id
      t.string :metadata_source
      t.string :metadata_source_id
      t.string :title
      t.string :author
      t.string :isbn
      t.string :callnumber
      t.string :publication_date
      t.string :publisher
      t.string :description
      t.string :edition
      t.string :loan_period
      t.boolean :provided_by_requestor, default: false
      t.string  :item_type
      t.string  :copyright_options
      t.text    :other_copyright_options
      t.string  :format
      t.text    :url
      t.string  :status
      t.string  :map_index_num
      t.string  :journal_title
      t.string  :volume
      t.string  :page_number
      t.string  :issue

      t.timestamps
    end
  end
end
