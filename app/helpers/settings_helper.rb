module SettingsHelper
  def settings_link(text, paths)
    active = paths.any? { |path| current_page?(path) }
    content_tag :li, class: "tabs__trigger", "data-state": active ? "active" : "" do
      link_to text, paths.first
    end
  end
end
