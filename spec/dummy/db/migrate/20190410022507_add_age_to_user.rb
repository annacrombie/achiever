class AddAgeToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :age, :integer, default: 0
  end
end
