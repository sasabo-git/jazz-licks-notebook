# frozen_string_literal: true

class Score < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  belongs_to :user
  belongs_to :private_score, optional: true
end
