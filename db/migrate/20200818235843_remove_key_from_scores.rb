class RemoveKeyFromScores < ActiveRecord::Migration[6.0]
  def change
    remove_column :scores, :key, :string
  end
end
