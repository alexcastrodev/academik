module ApplicationHelper
  def tag_pill(tag)
    content_tag :span, tag.name,
      class: "tag-pill",
      style: "background:#{tag.color}18;border-color:#{tag.color};color:#{tag.color}"
  end

  def color_swatch(color, css_class: "")
    content_tag :span, "",
      class: "inline-block rounded-full w-3 h-3 flex-shrink-0 #{css_class}",
      style: "background:#{color}"
  end

  def status_badge(paper)
    content_tag :span, paper.reading_status.humanize,
      class: "status-badge status-#{paper.reading_status}"
  end

  def lib_link(path, icon, label, active: false, count: nil, indent: false)
    base = "flex items-center gap-2 px-2 py-1.5 rounded-md text-sm transition-colors"
    state = active ? "bg-blue-50 text-blue-700 font-medium" : "text-gray-700 hover:bg-gray-100"
    pl = indent ? "pl-6" : ""
    link_to path, class: "#{base} #{state} #{pl}" do
      concat content_tag(:i, "", data: { lucide: icon }, class: "w-3.5 h-3.5 flex-shrink-0")
      concat content_tag(:span, label, class: "flex-1 truncate")
      concat content_tag(:span, count.to_s, class: "text-[10px] text-gray-400") if count
    end
  end
end
