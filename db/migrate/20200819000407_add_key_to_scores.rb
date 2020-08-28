class AddKeyToScores < ActiveRecord::Migration[6.0]
  def change
    add_column :Scores, :key, :string, atfer: :title
  end
end
