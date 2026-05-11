class AppSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.get(key)
    find_by(key: key)&.value
  end

  def self.set(key, value)
    find_or_create_by!(key: key).update!(value: value)
  end
end
