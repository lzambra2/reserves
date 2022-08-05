module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def page_header(&block)
    content_for(:page_header) do
      yield block
    end
  end

  def sidebar(&block)
    content_for(:sidebar) do
      yield block
    end
  end

  def link_active_if?(c, a = nil)
    if !a.nil?
      return 'active' if controller.controller_name == c && controller.action_name == a
    elsif controller.controller_name == c || c.include?(controller.controller_name)
      return 'active'
    end

    ''
  end

  def blank_slate(list = nil, title: 'No items found', description: 'Click on new button to add new item.', icon: nil)
    if list.nil? || list.size == 0
      fa = icon.nil? ? '' : content_tag(:i, '', class: "fa fa-#{icon}")
      h4 = content_tag(:h4, title.html_safe)
      p = content_tag(:p, description.html_safe)
      content_tag(:div, fa.html_safe + h4 + p, class: 'blank-slate')
    end
  end
end
