class NamespaceAchievements < ActiveRecord::Migration[5.2]
  def change
    rename_table :achievements, :achiever_achievements
  end
end
