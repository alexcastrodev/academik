class Summary < ApplicationRecord
  belongs_to :paper

  enum :status, { pending: 0, generating: 1, complete: 2, failed: 3 }, default: :pending
end
