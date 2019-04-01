class AddTagsColumnToScheduledAchievement < ActiveRecord::Migration[5.2]
  def change
    add_column :achiever_scheduled_achievements, :tags, :string
  end
end
