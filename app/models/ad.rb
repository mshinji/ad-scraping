class Ad < ApplicationRecord
  belongs_to :keyword, optional: true

  enum engine: { google: 0, yahoo: 1 }

  def domain
    /(https?:\/\/(.*?))\// =~ url ? $1 : nil
  end

  class << self
    def public_engines
      engines
    end
  end
end
