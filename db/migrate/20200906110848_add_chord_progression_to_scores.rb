# frozen_string_literal: true

class AddChordProgressionToScores < ActiveRecord::Migration[6.0]
  def change
    add_column :scores, :chord_progression, :string
  end
end
