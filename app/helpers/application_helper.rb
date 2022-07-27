module ApplicationHelper
  def app_version
    Reserves::Version.new.version
  end

  def app_name
    'Reserves'
  end

  def link_to_add_fields(name, f, association, css_classes = '')
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + 's/form_fields', f: builder)
    end
    link_to(name, '#', class: "add_fields #{css_classes}", data: { id: id, fields: fields.gsub("\n", '') })
  end

  def is_number?(obj)
    obj.to_s == obj.to_i.to_s
  end

  def pp(object)
    (ap object).html_safe
  rescue StandardError
  end
end
