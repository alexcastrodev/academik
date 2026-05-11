class Annotation < ApplicationRecord
  belongs_to :paper

  COLORS = %w[yellow green blue red purple].freeze

  validates :page, presence: true, numericality: { greater_than: 0 }
  validates :selected_text, presence: true
  validates :color, inclusion: { in: COLORS }, allow_nil: true

  before_save -> { self.color ||= "yellow" }
end
