module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_company

    def connect
      self.current_company = find_verified_company
    end

    protected

    def find_verified_company
      if current_company = Company.find_by(id: cookies.signed[:company_id])
        current_company
      else
        reject_unauthorized_connection
      end
    end
  end
end
