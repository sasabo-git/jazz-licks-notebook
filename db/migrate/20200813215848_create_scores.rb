# frozen_string_literal: true

class CreateScores < ActiveRecord::Migration[6.0]
  def change
    create_table :scores do |t|
      t.text :title
      t.text :content

      t.timestamps
    end
  end
end
