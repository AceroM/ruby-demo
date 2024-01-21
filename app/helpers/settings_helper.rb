module SettingsHelper
  def settings_link(text, paths)
    active = paths.any? { |path| current_page?(path) }
    content_tag :li, class: "tabs__trigger", "data-state": active ? "active" : "" do
      link_to text, paths.first
    end
  end

  def subscription_badge(status)
    status_mapping = {
      "active" => ["Active", "badge badge--success"],
      "paused" => ["Paused", "badge badge--info"],
      "trialing" => ["Trialing", "badge badge--info"],
      "canceled" => ["Canceled", "badge badge--danger"],
      "unpaid" => ["Unpaid", "badge badge--danger"]
    }
    badge_info = status_mapping[status] || [status, "badge badge--gray"]
    content_tag :span, badge_info.first, class: badge_info.last
  end

  def card_brand(brand)
    brand_mapping = {
      "Visa" => "visa",
      "Mastercard" => "mastercard",
      "Japan Credit Bureau (JCB)" => "jcb",
      "Discover & Diners Club" => "discover"
    }
    brand_mapping[brand] || "stripe"
  end
end
