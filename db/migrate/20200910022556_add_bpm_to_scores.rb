# frozen_string_literal: true

class AddBpmToScores < ActiveRecord::Migration[6.0]
  def change
    add_column :scores, :bpm, :integer
  end
end
