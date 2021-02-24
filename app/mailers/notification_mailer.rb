class NotificationMailer < ApplicationMailer
  default from: 'system.hideandseek@gmail.com'

  def send_to_company_about_reseller(company, reseller_list)
    @company = company
    @lists = reseller_list
    mail(subject: '転売に関して',
         to: @company.email,
         template_path: 'notification_mailer',
         template_name: 'send_to_company_about_reseller')
  end
end
