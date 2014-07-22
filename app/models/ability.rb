class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)    
    if user.has_role? :admin # admin user
      can :manage, ServicesController
      can :manage, ProjectsController
      can :manage, LocationsController
      can :manage, ClientsController
      can :manage, BrandAmbassadorsController
      can :manage, IsmpController
      can :manage, DefaultValuesController
      can :manage, ReportsController
    elsif user.has_role? :ismp
      can :manage, ServicesController
      can :manage, ProjectsController
      can :manage, LocationsController
      can :manage, ClientsController
      can :manage, BrandAmbassadorsController
      can :manage, ReportsController
    elsif user.has_role? :ba
      can :manage, AvailableDatesController
      can :manage, AssignmentsController
    # elsif user.has_role? :client
    end
  end
end
