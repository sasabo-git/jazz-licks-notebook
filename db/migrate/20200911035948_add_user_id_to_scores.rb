class AddUserIdToScores < ActiveRecord::Migration[6.0]
  def change
    add_column :scores, :user_id, :integer
  end
end
