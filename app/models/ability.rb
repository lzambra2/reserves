# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user, params)
    if user&.admin?

      case user.role
      when User::MANAGER_ROLE
        can :manage, :all
      when User::SUPERVISOR_ROLE
        can :manage, [Request, Item, Course]
        can %i[read requests], User

        can :manage, AcquisitionRequest

        cannot :change_owner, Request do |r|
          r.reserve_location_id != user.location_id
        end

        can :login_as, :requestor
      else
        can [:manage], [Request, Item]
        can %i[read requests], [User, Course, LoanPeriod, Location]
        can [:create], AcquisitionRequest
        can %i[read show update change_status], AcquisitionRequest

        cannot :change_owner, Request do |r|
          r.reserve_location_id != user.location_id
        end
      end

      can :login_as, :requestor
      can :search, :requests
    elsif user
      can %i[read rollover_confirm rollover archive], Request, requester_id: user.id

      can :destroy, Request do |r|
        r.requester_id == user.id && r.status == Request::INCOMPLETE
      end

      can [:change_status], Request do |r|
        r.requester_id == user.id && r.status == Request::COMPLETED && params[:status] == 'open'
      end

      can :update, Request do |r|
        r.requester_id == user.id && (r.status == Request::OPEN || r.status == Request::INCOMPLETE)
      end

      can %i[read create], Item, request: { requester_id: user.id }
      can [:update, :destroy], Item do |i|
        i.request.requester_id == user.id && (i.request.status == Request::OPEN || i.request.status == Request::INCOMPLETE)
      end
      can %i[read update requests], User, id: user.id

      cannot :change_owner, Request
    end

    ##################### COMMON TO ALL ######################

    ## ADD NEW REQUEST
    can %i[step_one save step_two finish], :request

    # can get back to login
    can :back_to_login, :requestor

    ### CANNOTS
    cannot [:update, :destroy, :assign], Request do |r|
      r.status == Request::CANCELLED || r.status == Request::COMPLETED
    end

    cannot [:update, :destroy, :change_status], Item do |i|
      i.request.status == Request::CANCELLED || i.request.status == Request::COMPLETED
    end
  end
end
