class Tag < ApplicationRecord
  has_many :paper_tags, dependent: :destroy
  has_many :papers, through: :paper_tags

  validates :name, presence: true, uniqueness: true
  validates :color, presence: true
end
