require 'rake'
require 'csv'

class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, with: :handle404

  def handle400
    render html: '400 bad request'
  end

  def handle403
    html = <<-"EOS"
    403 You do not have permission to access that <br>
    #{view_context.link_to('Sign out?', destroy_company_session_path)}
    EOS
    render html: html.html_safe
  end

  def handle404
    render html: '404 not found'
  end

  def after_sign_in_path_for(company)
    if company.admin?
      admin_index_path
    else
      products_path
    end
  end

  def after_sign_out_path_for(_company)
    new_company_session_path
  end

  def check_sidekiq_process
    unless Rails.env.development?
      system("RAILS_ENV=#{Rails.env} bundle exec rake sidekiq:restart") unless system('ps aux | grep [s]idekiq')
    end
  end
end
