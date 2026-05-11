class PaperTag < ApplicationRecord
  belongs_to :paper
  belongs_to :tag

  validates :paper_id, uniqueness: { scope: :tag_id }
end
