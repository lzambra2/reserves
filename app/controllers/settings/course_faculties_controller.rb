# frozen_string_literal: true

class Settings::CourseFacultiesController < ApplicationController
  authorize_resource Setting

  before_action :set_course_faculty, only: %i[edit update destroy]

  # GET /settings/course_faculties
  # GET /settings/course_faculties.json
  def index
    @faculties = Courses::Faculty.all
  end

  # GET /settings/course_faculties/new
  def new
    @faculty = Courses::Faculty.new
  end

  # GET /settings/course_faculties/1/edit
  def edit; end

  # POST /settings/course_faculties
  # POST /settings/course_faculties.json
  def create
    @faculty = Courses::Faculty.new(faculty_params)

    respond_to do |format|
      if @faculty.save
        format.html { redirect_to settings_faculties_path, notice: "#{@faculty.code} suject was created!" }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /settings/course_faculties/1
  # PATCH/PUT /settings/course_faculties/1.json
  def update
    respond_to do |format|
      if @faculty.update(faculty_params)
        format.html { redirect_to settings_faculties_path, notice: "#{@faculty.code} suject was updated!" }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /settings/course_faculties/1
  # DELETE /settings/course_faculties/1.json
  def destroy
    @faculty.destroy
    respond_to do |format|
      format.html { redirect_to settings_faculties_path, notice: "#{@faculty.code} suject was removed!" }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course_faculty
    @faculty = Courses::Faculty.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def faculty_params
    params.require(:courses_faculty).permit(:name, :code)
  end
end
