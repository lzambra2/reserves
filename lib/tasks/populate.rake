# frozen_string_literal: true

namespace :db do
  desc 'Database Populate Tasks, Test Data'

  task populate: :environment do
    require 'populator'
    require 'faker'

    puts 'Deleting previous data'
    [Request, Item, Course, Location, LoanPeriod, User].each(&:delete_all)

    index = 0

    puts 'Prefil Locations'
    locations = ['Scott Library', 'Bronfman', 'Steacie', 'Frost', 'Osgoode', 'ERC', 'SMIL']
    location_address = ['Central Square', 'Schulich Building', 'Steacie Building', 'Glendon Campus', 'Osgood Building',
                        'Ross Building', 'Scott Library']

    Location.populate 8 do |loc, index|
      loc.name = locations[index - 1]
      loc.contact_email = Faker::Internet.email
      loc.contact_phone = Faker::PhoneNumber.extension
      loc.address = location_address[index - 1]
      loc.is_deleted = false
      loc.id = index
    end

    puts 'Prefil Loan Periods'
    LoanPeriod.populate 5 do |lp, index|
      lp.duration = "#{index + 1} hours"
    end

    puts 'Prefil Users and Staff + Instructor'
    roles = User::STAFF_ROLES + [User::INSTRUCTOR_ROLE]

    User::STAFF_ROLES.each_with_index do |role, index|
      u = User.new
      u.role = role
      u.user_type = User::STAFF
      u.admin = true
      u.name = "#{Faker::Name.first_name} #{role.humanize}"
      u.email = "#{role}@testing.com"
      u.library_uid = "29000#{Faker::PhoneNumber.extension}"
      u.uid = role.downcase
      u.active = true
      u.created_by_id = 1
      u.location_id = index + 1
      u.save(validate: false)
    end

    type_index = 0
    User.populate User::TYPES.size do |u, _id|
      u.user_type = User::TYPES[type_index]
      u.name = "#{Faker::Name.name} #{u.user_type}"
      u.email = Faker::Internet.email
      u.phone = Faker::PhoneNumber.extension
      u.department = %w[History Anthropology CompSci PoliSci Mathematics Philosophy Sociology Physics BioInformatics
                        Biology Chemistry]
      u.office = ['Ross South 54', 'Vari Hall 2010', 'Vari Hall 1010', 'Stong 111', 'Stong 123', 'Calumet 102',
                  'Calumet 202', 'Founders 304', 'Winters 210', 'Tel 108', 'Tel 109', 'Winters 300', 'BSB 405', 'Petrie 324', 'Petrie 376']
      u.role = User::INSTRUCTOR_ROLE
      u.library_uid = "290000#{Faker::PhoneNumber.extension}"
      u.admin = false
      u.active = true
      u.created_by_id = 1
      u.uid = "#{u.user_type}_dev"
      type_index += 1
    end

    user_ids = User.all.collect(&:id)

    puts 'Prefil Requests, Items and Courses'

    Course.populate 70..90 do |course, index|
      course.name = ['Physics', 'History of Man', 'Calculus', 'Polictics Of Fools', 'Infinite Algebra', 'Informatics',
                     'BioChemistry', 'Chemistry', 'Kinestetics']
      # YEAR_FACULTY_SUBJECT_TERM_COURSEID__CREDITS_SECTION
      course.code = "2014_FC_DK_W_#{index}#{index + 1}0__9_A"
      course.instructor = ['John Grisham', 'Henry Ford', 'Lee Child']
      course.student_count = 10..60

      Request.populate 1 do |request, requests_counter|
        request.reserve_location_id = 1..7
        request.course_id = course.id
        request.status = Request::STATUSES # pick from one
        request.requester_id = user_ids

        case request.status
        when Request::COMPLETED
          request.completed_date = 3.days.ago
        when Request::CANCELLED
          request.cancelled_date = 1.week.ago
        end

        request.reserve_start_date = 1.month.from_now
        request.reserve_end_date = 6.months.from_now

        request.created_at = 3.months.ago..1.days.ago

        Item.populate 1..4 do |item, items_counter|
          item.title = Populator.words(3..9)
          item.author = Faker::Name.name
          item.isbn = 10_000_000..20_000_000
          item.callnumber = "AB #{items_counter + 1} 2009 P#{requests_counter}"
          item.description = Populator.words(10..15)
          item.edition = '1st Edition'
          item.publisher = ['Thompson', 'Bantam', 'Oxford University Press', 'Yale Press', 'York U Press']
          item.publication_date = 1999..2014
          item.provided_by_requestor = [true, false]
          item.loan_period = LoanPeriod.all.collect(&:duration)
          item.request_id = request.id
          item.status = [Item::STATUS_READY, Item::STATUS_NOT_READY]
          item.metadata_source = [Item::METADATA_MANUAL, Item::METADATA_SOLR, Item::METADATA_WORLDCAT]
          item.metadata_source_id = 1000..1_000_000
          item.item_type = [Item::TYPE_BOOK, Item::TYPE_EBOOK, Item::TYPE_MULTIMEDIA, Item::TYPE_COURSE_KIT,
                            Item::TYPE_PHOTOCOPY, Item::TYPE_MAP]
        end
      end
    end
  end
end
