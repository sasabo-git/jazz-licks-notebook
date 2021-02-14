# frozen_string_literal: true

class CreatePrivateScores < ActiveRecord::Migration[6.1]
  def change
    create_table :private_scores, id: :string do |t|
      t.integer :saved_id
      t.text :title
      t.text :body
      t.string :key
      t.string :meter
      t.string :chord_progression
      t.text :memo
      t.integer :bpm

      t.timestamps
    end
  end
end
