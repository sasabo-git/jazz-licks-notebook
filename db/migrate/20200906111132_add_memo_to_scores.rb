# frozen_string_literal: true

class AddMemoToScores < ActiveRecord::Migration[6.0]
  def change
    add_column :scores, :memo, :text
  end
end
