class CreateUniverses < ActiveRecord::Migration
  def change
    create_table :universes do |t|
      t.string :name
      t.float :entropy
      t.integer :light_years

      t.timestamps
    end
  end
end
