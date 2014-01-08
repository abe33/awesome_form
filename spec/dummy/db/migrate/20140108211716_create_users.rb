class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.belongs_to :universe, index: true
      t.boolean :dead
      t.datetime :born_at

      t.timestamps
    end
  end
end
