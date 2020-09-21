# frozen_string_literal: true

class ChangeDataBodyToScores < ActiveRecord::Migration[6.0]
  def change
    change_column :scores, :body, :text
  end
end
