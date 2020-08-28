class AddNotNullToTitleAndContent < ActiveRecord::Migration[6.0]
  def change
    change_column_null :scores, :title, false
    change_column_null :scores, :content, false
  end
end
