# frozen_string_literal: true

class AddMeterToScores < ActiveRecord::Migration[6.0]
  def change
    add_column :scores, :meter, :string, after: :key
  end
end
