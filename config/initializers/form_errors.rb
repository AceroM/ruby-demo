ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  fragment = Nokogiri::HTML.fragment(html_tag)
  field = fragment.at("input:not([type='checkbox']),select,textarea,label[class='checkbox']")
  html = if field
    html = <<-HTML
              #{fragment}
              <p class="field__error">#{instance_tag.error_message.first}</p>
    HTML
    html
  else
    html_tag
  end
  html.html_safe
end
