class Collection < ApplicationRecord
  belongs_to :parent, class_name: "Collection", optional: true
  has_many :children, class_name: "Collection", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent
  has_many :paper_collections, dependent: :destroy
  has_many :papers, through: :paper_collections
  has_many :latex_documents, as: :sourceable, dependent: :nullify

  validates :name, presence: true

  scope :roots, -> { where(parent_id: nil) }

  def ancestors
    result = []
    current = parent
    depth = 0
    while current && depth < 10
      result.unshift(current)
      current = current.parent
      depth += 1
    end
    result
  end
end
