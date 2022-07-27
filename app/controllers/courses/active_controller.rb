class Courses::ActiveController < ApplicationController
  authorize_resource Course

  def index
    @requests = Request.where('reserve_end_date >= ?', Date.today)
    @active_courses = Course.where('id in (?)',
                                   @requests.pluck(:id)).includes(:requests).includes(:reserve_locations).includes(requests: [:reserve_location])
    # @active_courses = Course.active_courses.includes(:requests).includes(:reserve_locations).includes(requests: [:reserve_location])

    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="active_courses.xlsx"'
      end
    end
  end

  def show
    @course = Course.find(params[:id])
    @items = @course.items

    code = @course.code.delete(' ')
    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] = "attachment; filename=\"course_items_#{code}.xlsx\""
      end
    end
  end
end
