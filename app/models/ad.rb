class Ad < ApplicationRecord
  belongs_to :keyword, optional: true

  enum status: { initial: 0, again: 1, gone: 2 }
  enum engine: { google: 0, yahoo: 1 }

  def domain
    /(https?:\/\/(.*?))\// =~ url ? $1 : nil
  end

  class << self
    def initial?
      status == :initial
    end

    def again?
      status == :again
    end

    def gone?
      status == :gone
    end

    def public_statuses
      puts statues
      statuses
    end

    def public_engines
      engines
    end
  end
end
