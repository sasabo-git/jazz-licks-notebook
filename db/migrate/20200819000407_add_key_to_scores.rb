# frozen_string_literal: true

class AddKeyToScores < ActiveRecord::Migration[6.0]
  def change
    add_column :scores, :key, :string, atfer: :title
  end
end
