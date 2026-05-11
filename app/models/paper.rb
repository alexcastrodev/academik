class Paper < ApplicationRecord
  has_one_attached :pdf
  has_many :paper_collections, dependent: :destroy
  has_many :collections, through: :paper_collections
  has_many :paper_tags, dependent: :destroy
  has_many :tags, through: :paper_tags
  has_many :summaries, dependent: :destroy
  has_many :latex_documents, as: :sourceable, dependent: :nullify
  has_many :annotations, dependent: :destroy

  enum :reading_status, { unread: 0, reading: 1, read: 2, to_cite: 3 }, default: :unread

  validates :title, presence: true

  def latest_summary
    summaries.order(created_at: :desc).first
  end

  scope :by_status, ->(status) { where(reading_status: reading_statuses[status]) if status.present? }
  scope :search, ->(q) { where("title LIKE :q OR authors LIKE :q OR abstract LIKE :q", q: "%#{sanitize_sql_like(q)}%") if q.present? }
end
