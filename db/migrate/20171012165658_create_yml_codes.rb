class CreateYmlCodes <  SpreeExtension::Migration[5.1]
  def self.up
    create_table :spree_yml_codes do |t|
      t.string :name
      t.string :link
      t.date :last_update
      t.string :count
      t.string :in_store_count
      t.integer :identical
      t.integer :various
      t.text :various_array
      t.integer :not_in_store
      t.text :not_in_store_array
      t.boolean :initialized
      t.string :checksum
      t.string :repeat_at
      t.boolean :update_price
      t.boolean :update_available
      t.string :report_id
      t.string :cron




      t.timestamps
    end
  end

  def self.down
    drop_table :spree_yml_codes
  end

end
