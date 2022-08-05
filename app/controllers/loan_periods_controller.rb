class LoanPeriodsController < ApplicationController
  before_action :set_loan_period, only: %i[show edit update destroy]
  authorize_resource

  # GET /loan_periods
  # GET /loan_periods.json
  def index
    @loan_periods = LoanPeriod.all
  end

  # GET /loan_periods/1
  # GET /loan_periods/1.json
  def show; end

  # GET /loan_periods/new
  def new
    @loan_period = LoanPeriod.new
  end

  # GET /loan_periods/1/edit
  def edit; end

  # POST /loan_periods
  # POST /loan_periods.json
  def create
    @loan_period = LoanPeriod.new(loan_period_params)

    respond_to do |format|
      if @loan_period.save
        format.html { redirect_to loan_periods_path, notice: 'Loan period was successfully created.' }
        format.json { render action: 'show', status: :created, location: @loan_period }
      else
        format.html { render action: 'new' }
        format.json { render json: @loan_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loan_periods/1
  # PATCH/PUT /loan_periods/1.json
  def update
    respond_to do |format|
      if @loan_period.update(loan_period_params)
        format.html { redirect_to loan_periods_path, notice: 'Loan period was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @loan_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loan_periods/1
  # DELETE /loan_periods/1.json
  def destroy
    @loan_period.destroy
    respond_to do |format|
      format.html { redirect_to loan_periods_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_loan_period
    @loan_period = LoanPeriod.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def loan_period_params
    params.require(:loan_period).permit(:duration)
  end
end
