module ItemsHelper
  def link_to_item_type_fields(name, type, f, association, css_classes = '')
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "s/types/#{type}_form_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields #{css_classes}",
                       data: { id: id, fields: fields.gsub("\n", ''), attach_to: ".#{association}" })
  end

  def format(field, simple_format = false)
    # If field is blank, print out blank message
    if field.blank?
      content_tag(:span, 'Not filled in...', class: 'empty-field')
    elsif field.is_a? Date
      field.strftime('%B %d, %Y')
    else
      simple_format ? simple_format(field) : field
    end
  end

  def show_field?(item, field, &block)
    field_map = {
      Item::TYPE_BOOK => %w[title author callnumber isbn publisher publication_date edition
                            provided_by loan_period physical_copy_required],
      Item::TYPE_EBOOK => %w[title author callnumber isbn publisher publication_date edition
                             provided_by url],
      Item::TYPE_MULTIMEDIA => %w[title author callnumber publisher publication_date edition
                                  provided_by loan_period format url],
      Item::TYPE_MAP => %w[title map_index_num loan_period provided_by],
      Item::TYPE_PHOTOCOPY => %w[title author provided_by loan_period description copyright_options],
      Item::TYPE_COURSE_KIT => %w[title author provided_by loan_period description],
      Item::TYPE_EJOURNAL => %w[title author page_number volume issue journal_title
                                publication_date url loan_period provided_by],
      Item::TYPE_PRINT_PERIODICAL => %w[title author page_number volume issue journal_title
                                        publication_date loan_period provided_by]
    }
    if field_map[item.item_type].include?(field)
      yield block
    else
      content_tag(:span, 'Not applicable', class: 'empty-field')
    end
  end
end
