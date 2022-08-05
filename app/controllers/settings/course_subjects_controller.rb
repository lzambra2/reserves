class Settings::CourseSubjectsController < ApplicationController
  authorize_resource Setting

  before_action :set_course_subject, only: %i[edit update destroy]

  # GET /settings/course_subjects
  # GET /settings/course_subjects.json
  def index
    @subjects = Courses::Subject.all
  end

  # GET /settings/course_subjects/new
  def new
    @subject = Courses::Subject.new
  end

  # GET /settings/course_subjects/1/edit
  def edit; end

  # POST /settings/course_subjects
  # POST /settings/course_subjects.json
  def create
    @subject = Courses::Subject.new(subject_params)

    respond_to do |format|
      if @subject.save
        format.html { redirect_to settings_subjects_path, notice: "#{@subject.code} suject was created!" }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /settings/course_subjects/1
  # PATCH/PUT /settings/course_subjects/1.json
  def update
    respond_to do |format|
      if @subject.update(subject_params)
        format.html { redirect_to settings_subjects_path, notice: "#{@subject.code} suject was updated!" }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /settings/course_subjects/1
  # DELETE /settings/course_subjects/1.json
  def destroy
    @subject.destroy
    respond_to do |format|
      format.html { redirect_to settings_subjects_path, notice: "#{@subject.code} suject was removed!" }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course_subject
    @subject = Courses::Subject.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subject_params
    params.require(:courses_subject).permit(:name, :code)
  end
end
