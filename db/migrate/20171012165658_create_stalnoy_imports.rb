class CreateStalnoyImports <  SpreeExtension::Migration[5.1]
  def self.up
    create_table :spree_stalnoy_imports do |t|
      t.string :name
      t.string :cols
      t.string :rows
      t.text :data
      t.text :data_prepared
      t.integer :last_row


      t.timestamps
    end
  end

  def self.down
    drop_table :spree_stalnoy_imports
  end

end
