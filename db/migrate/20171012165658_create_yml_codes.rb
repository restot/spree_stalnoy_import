class CreateYmlCodes <  SpreeExtension::Migration[5.1]
  def self.up
    create_table :spree_yml_codes do |t|
      t.string :name
      t.string :link
      t.string :cron
      t.timestamps
    end
  end

  def self.down
    drop_table :spree_yml_codes
  end

end
