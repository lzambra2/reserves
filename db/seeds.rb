if Rails.env.development?
  loc = Location.new
  loc.name = 'Main Location'
  loc.contact_email = 'email@email.com'
  loc.contact_phone = '123 234'
  loc.address = 'some address'
  loc.is_deleted = false
  loc.save

  u = User.new
  u.role = User::MANAGER_ROLE
  u.user_type = User::STAFF
  u.admin = true
  u.name = 'Manager User'
  u.email = 'manager@testing.com'
  u.library_uid = '29000234113232'
  u.uid = u.role.downcase
  u.active = true
  u.created_by_id = 1
  u.location_id = loc.id
  u.save(validate: false)
end
