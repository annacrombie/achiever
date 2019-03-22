# frozen_string_literal: true

class CreateAchievement < ActiveRecord::Migration[5.2]
  def change
    create_table :achievements do |t|
      t.string :name, null: false
      t.integer :user_id, null: false
      t.integer :progress, default: 0, null: false
      t.integer :notified_progress, default: 0, null: false

      t.timestamps
    end
  end
end
