class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  scope :active, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }
  scope :latest_order, -> { order(created_at: :desc) }

  class << self
    def attribute_columns
      column_names.map { |column| to_s.downcase.pluralize + '.' + column.to_s }.join(', ')
    end
  end

  def logical_delete
    update(deleted: true)
  end

  def enabled?(data)
    ActiveRecord::Type::Boolean.new.cast(data)
  end
end
