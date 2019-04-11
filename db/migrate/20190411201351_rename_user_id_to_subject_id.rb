class RenameUserIdToSubjectId < ActiveRecord::Migration[5.2]
  def change
    rename_column :achiever_achievements, :user_id, :subject_id
  end
end
