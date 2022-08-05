class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy reactivate change_role]
  authorize_resource

  skip_before_action :user_information_validity_check, only: %i[show edit update]

  def index
    @users = if params[:inactive]
               User.inactive.users.order(:name)
             else
               User.active.users.order(:name)
             end

    # @user_groups = @users.group_by { |u| u.role }

    if params[:term]
      @query = params[:term]
      @users = @users.where('name like ?', "%#{@query}%").limit(30) # , "%#{@query}%")

    else
      @users = @users.order(created_at: :desc).limit(100)
    end

    respond_to do |format|
      format.html
      format.json { render json: @users.map { |u| { label: "#{u.name} - [#{u.uid}]", value: u.id } } }
    end
  end

  def requests
    if !params[:removed].nil?
      @requests = current_user.requests.removed
      @requests_groups = @requests.group_by { |r| r.status }
    else
      @requests = current_user.requests
      @requests_groups = @requests.group_by { |r| r.status }
    end
  end

  def admin_users
    @users = User.active.admin
    @inactive_users = User.inactive.admin
    @user_groups = @users.group_by { |u| u.role }
    @staff_list = true
    render :index
  end

  def show
    @audits = @user.audits | @user.associated_audits
    @audits.sort! { |a, b| a.created_at <=> b.created_at }

    @audits_grouped = @audits.reverse.group_by { |a| a.created_at.at_beginning_of_day }
  end

  def new
    @user = User.new
    @user.admin = false
  end

  def new_admin_user
    @user = User.new
    @user.admin = true
    render :new
  end

  def edit; end

  def create
    @user = User.new(user_params)
    @user.name = @user.name.sub(/\(.*\)/, '')
    @user.role == User::INSTRUCTOR_ROLE unless @user.admin?
    @user.audit_comment = "Created User #{@user.name}"
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    email_nil = @user.email.blank?
    @user.audit_comment = "Updated User #{@user.name}"
    if @user.update(user_params)
      UserMailer.welcome(@user).deliver_later if email_nil # if email was nil, then we signed up with extracting details
      redirect_to @user, notice: "User #{@user.name} was successfully updated."
    else
      render action: 'edit'
    end
  end

  def destroy
    if current_user.id != @user.id
      @user.active = false
      @user.audit_comment = "User #{@user.name} Changed to Inactive"
      @user.save(validate: false)
    end

    redirect_to users_url, notice: 'Successfully deactivated this user.' unless @user.admin?
    redirect_to admin_users_users_url, notice: 'Successfully deactivated this user.' if @user.admin?
  end

  def reactivate
    @user.active = true
    @user.audit_comment = "User #{@user.name} Changed to Active"
    @user.save(validate: false)
    redirect_to users_url, notice: 'Successfully reactivate this user' unless @user.admin?
    redirect_to admin_users_users_url, notice: 'Successfully reactivate this user' if @user.admin?
  end

  def change_role
    if params[:admin] == 'true'
      @user.admin = true
      @user.role = User::STAFF_ROLE
      @user.audit_comment = "User #{@user.name} role changed to #{@user.role}"
      @user.save(validate: false)
      if @user.valid?
        redirect_to admin_users_users_url, notice: 'Successfully made this user an admin'
      else
        redirect_to edit_user_url(@user), notice: 'You must add a few more details first'
      end
    else
      @user.admin = false
      @user.role = User::INSTRUCTOR_ROLE
      @user.audit_comment = "User #{@user.name} role changed to #{@user.role}"
      @user.save(validate: false)
      redirect_to users_url, notice: 'Successfully made this user a regular user'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :uid, :library_uid, :email, :phone, :office, :department, :role, :user_type,
                                 :admin, :location_id)
  end
end
