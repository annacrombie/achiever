class AddIndexToAchievements < ActiveRecord::Migration[5.2]
  def change
    add_index :achiever_achievements, [:user_id, :name], unique: true
  end
end
