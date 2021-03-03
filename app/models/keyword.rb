class Keyword < ApplicationRecord
  has_many :ads
  has_many :scraping_histories

  enum status: { active: 0, disabled: 1 }

  class << self
    def active?
      status == :active
    end

    def disabled?
      status == :disabled
    end

    def public_statuses
      statuses
    end
  end
end
