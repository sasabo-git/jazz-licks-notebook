class ChangeDataBodyToScores < ActiveRecord::Migration[6.0]
  def change
    change_column :scores, :body, :text
  end
end
