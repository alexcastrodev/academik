class LatexDocument < ApplicationRecord
  belongs_to :sourceable, polymorphic: true, optional: true

  enum :generation_type, { single_paper: 0, collection: 1, manual: 2 }, default: :manual

  validates :title, presence: true
end
