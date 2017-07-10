module ApplicationHelper
  # Returns the full title on a per-page basis
  def full_title(page_title = '')
    base_title = 'Ruby on Rails Tutorial Sample App'
    return base_title unless page_title.present?
    "#{page_title} | #{base_title}"
  end
end
