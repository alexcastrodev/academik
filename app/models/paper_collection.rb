class PaperCollection < ApplicationRecord
  belongs_to :paper
  belongs_to :collection

  validates :paper_id, uniqueness: { scope: :collection_id }
end
