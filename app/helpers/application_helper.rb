module ApplicationHelper
  # デバイスのエラーメッセージ出力メソッド
  def devise_error_messages
    return '' if resource.errors.empty?

    html = ''
    messages = resource.errors.full_messages.each do |msg|
      html += <<-EOF
        <div class="error_field alert alert-danger" role="alert">
          <p class="error_msg">#{msg}</p>
        </div>
      EOF
    end
    html.html_safe
  end

  def form_url(controller, model)
    options = { controller: controller, action: :create }
    options = options.merge(action: :update, id: model.id) if model.id.present?
    url_for(options)
  end
end
