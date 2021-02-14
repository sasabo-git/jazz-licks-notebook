# frozen_string_literal: true

require "securerandom"

class PrivateScore < ApplicationRecord
  has_many :scores
  before_create :set_id

  private
    def set_id
      while self.id.blank? || PrivateScore.find_by(id: self.id).present? do
        self.id = SecureRandom.urlsafe_base64
      end
    end
end
