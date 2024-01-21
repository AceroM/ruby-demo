module ApplicationHelper
  include Pagy::Frontend

  def title(page_title)
    content_for(:title) { page_title + " | Ruby" }
  end

  def headline(headline)
    content_for(:headline) { headline } if headline
  end

  def dashboard_link(text, paths, icon = "house", enabled = Current.onboarded?)
    active = paths.any? { |path| current_page?(path) || request.url.include?(path) }
    content_tag :li, class: "sidebar__item" do
      link_to paths.first, disabled: !enabled, class: ["header__link", ("header__link--active" if active), ("header__link--disabled" unless enabled)] do
        concat(content_tag(:i, nil, class: "fa-light#{icon ? " fa-#{icon}" : ""}").html_safe)
        concat(content_tag(:span, text, class: "sidebar__text"))
      end
    end
  end

  def format_date(date_string, format = "%b %d, %Y")
    date = date_string.is_a?(String) ? Date.parse(date_string) : date_string
    date.strftime(format)
  rescue ArgumentError
    date_string
  end

  def format_date_with_time(date_string, format = "%b %d, %Y, at %l:%M%P")
    date = date_string.is_a?(String) ? DateTime.parse(date_string) : date_string
    date.strftime(format)
  rescue ArgumentError
    date_string
  end

  def format_stripe_dollar(num)
    if num.to_f < 0
      content_tag(:span, number_to_currency(num / 100, unit: "$"), class: "negative-dollar")
    else
      content_tag(:span, number_to_currency(num / 100, unit: "$"))
    end
  end

  def format_dollar(num)
    if num.to_f < 0
      content_tag(:span, number_to_currency(num, unit: "$"), class: "negative-dollar")
    else
      content_tag(:span, number_to_currency(num, unit: "$"))
    end
  end

  def td(value:, max_char_length: 30, max_width: 150, popover_width: 150)
    style = case popover_width
    when "fit-content"
      "width: fit-content;"
    else
      "width: #{popover_width}px"
    end
    if value && value.length > max_char_length
      content_tag :td, class: "ellipsis-container popover", style: "max-width: #{max_width}px;", data: { controller: "popover", action: "mouseenter->popover#show mouseleave->popover#hide" } do
        concat(content_tag(:p, value, class: "ellipsis-container__text"))
        concat(content_tag(:div, value, class: "d-none popover__container", style:, data: { popover_target: "container" }))
      end
    else
      content_tag :td, value
    end
  end
end
