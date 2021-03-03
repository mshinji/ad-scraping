class ScrapingHistory < ApplicationRecord
  belongs_to :keyword, optional: true

  enum scraping_type: { one_keyword: 0, all_keywords: 1 }
  enum status: { exec: 0, completed: 1, failed: 2, pending: 3 }

  def completed_scraping(note = nil)
    update(status: :completed, end_at: Time.zone.now, note: note)
  end

  def failed_scraping(note = nil)
    update(status: :failed, end_at: Time.zone.now, note: note)
  end

  class << self
    def exec_scraping(scraping_type: :one_scraping, keyword_id: nil, job_id: nil)
      create(scraping_type: scraping_type, status: :exec, keyword_id: keyword_id, job_id: job_id)
    end

    def present_exec_one_keyword?
      find_by(status: :exec, scraping_type: :one_keyword).present?
    end

    def present_exec_all_keywords?
      find_by(status: :exec, scraping_type: :all_keywords).present?
    end
  end
end
