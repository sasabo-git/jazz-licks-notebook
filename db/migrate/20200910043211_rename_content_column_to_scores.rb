# frozen_string_literal: true

class RenameContentColumnToScores < ActiveRecord::Migration[6.0]
  def change
    rename_column :scores, :content, :body
  end
end
