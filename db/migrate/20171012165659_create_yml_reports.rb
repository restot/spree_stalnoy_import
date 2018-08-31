class CreateYmlReports <  SpreeExtension::Migration[5.1]
  def self.up
    create_table :spree_yml_reports do |t|
      t.string :name
      t.string :link
      t.string :count
      t.string :in_store_count
      t.integer :identical
      t.integer :various
      t.text :various_array
      t.integer :not_in_store
      t.text :not_in_store_array
      t.string :hash
      t.string :repeat_at
      t.boolean :done



      t.timestamps
    end
  end

  def self.down
    drop_table :spree_yml_reports
  end

end
