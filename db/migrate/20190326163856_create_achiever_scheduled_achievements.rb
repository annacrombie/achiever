class CreateAchieverScheduledAchievements < ActiveRecord::Migration[5.2]
  def change
    create_table :achiever_scheduled_achievements do |t|
      t.integer :achievement_id
      t.integer :payload
      t.timestamp :due

      t.timestamps
    end
  end
end
