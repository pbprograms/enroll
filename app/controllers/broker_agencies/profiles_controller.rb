class BrokerAgencies::ProfilesController < ApplicationController
  before_action :check_broker_agency_staff_role, only: [:new, :create]
  before_action :check_admin_staff_role, only: [:index]
  before_action :find_hbx_profile, only: [:index]
  before_action :find_broker_agency_profile, only: [:show, :edit, :update, :employers]
  before_action :set_current_person, only: [:staff_index]

  def index
    @broker_agency_profiles = BrokerAgencyProfile.all
  end

  def new
    @organization = ::Forms::BrokerAgencyProfile.new
  end

  def create
    params.permit!
    @organization = ::Forms::BrokerAgencyProfile.new(params[:organization])

    if @organization.save(current_user)
      flash[:notice] = "Successfully created Broker Agency Profile"
      redirect_to broker_agencies_profile_path(@organization.broker_agency_profile)
    else
      flash[:error] = "Failed to create Broker Agency Profile"
      render "new"
    end
  end

  def show
    session[:person_id] = nil
     @provider = current_user.person
     @staff_role = current_user.has_broker_agency_staff_role?
     @id=params[:id]
  end

  def edit
    @organization = Forms::BrokerAgencyProfile.find(@broker_agency_profile.id)
  end

  def update
    sanitize_broker_profile_params
    params.permit!

    # lookup by the origanization and not BrokerAgencyProfile
    #@organization = Forms::BrokerAgencyProfile.find(@broker_agency_profile.id)

    @organization = Organization.find(params[:organization][:id])

    @organization_dup = @organization.office_locations.as_json

    #clear office_locations, don't worry, we will recreate
    @organization.assign_attributes(:office_locations => [])
    @organization.save(validate: false)



    if @organization.update_attributes(broker_profile_params)
      flash[:notice] = "Successfully Update Broker Agency Profile"
      redirect_to broker_agencies_profile_path(@broker_agency_profile)
    else

      @organization.assign_attributes(:office_locations => @organization_dup)
      @organization.save(validate: false)

      flash[:error] = "Failed to Update Broker Agency Profile"
      #render "edit"
      redirect_to broker_agencies_profile_path(@broker_agency_profile)

    end
  end

  def broker_profile_params
    params.require(:organization).permit(
      #:employer_profile_attributes => [ :entity_kind, :dba, :legal_name],
      :office_locations_attributes => [
        :address_attributes => [:kind, :address_1, :address_2, :city, :state, :zip],
        :phone_attributes => [:kind, :area_code, :number, :extension],
        :email_attributes => [:kind, :address]
      ]
    )
  end

  def sanitize_broker_profile_params
    params[:organization][:office_locations_attributes].each do |key, location|
      params[:organization][:office_locations_attributes].delete(key) unless location['address_attributes']
      location.delete('phone_attributes') if (location['phone_attributes'].present? && location['phone_attributes']['number'].blank?)
    end
  end

  def staff_index
    @q = params.permit(:q)[:q]
    @staff = eligible_brokers
    @page_alphabets = page_alphabets(@staff, "last_name")
    page_no = cur_page_no(@page_alphabets.first)
    if @q.nil?
      @staff = @staff.where(last_name: /^#{page_no}/i)
    else
      @staff = @staff.where(last_name: @q)
    end
  end

  def family_index
    @q = params.permit(:q)[:q]
    id = params.permit(:id)[:id]
    page = params.permit([:page])[:page]
    if current_user.has_broker_role?
      broker_agency_profile = BrokerAgencyProfile.find(current_user.person.broker_role.broker_agency_profile_id)
    elsif current_user.has_hbx_staff_role?
      broker_agency_profile = BrokerAgencyProfile.find(BSON::ObjectId.from_string(id))
    else
      redirect_to new_broker_agencies_profile_path
      return
    end

    total_families = broker_agency_profile.families
    @total = total_families.count
    @page_alphabets = total_families.map{|f| f.primary_applicant.person.last_name[0]}.uniq.map(&:capitalize)
    if page.present?
      @families = total_families.select{|v| v.primary_applicant.person.last_name =~ /^#{page}/i }
    elsif @q
       @families = total_families.select{|v| v.primary_applicant.person.last_name =~ /^#{@q}/i }
    else
      @families = total_families[0..20]
     end

    @family_count = @families.count
    respond_to do |format|
      format.js {}
    end
  end

  def employers
    if current_user.has_broker_agency_staff_role? || current_user.has_hbx_staff_role?
      @orgs = Organization.by_broker_agency_profile(@broker_agency_profile._id)
    else
      broker_role_id = current_user.person.broker_role.id
      @orgs = Organization.by_broker_role(broker_role_id)
    end
    @page_alphabets = page_alphabets(@orgs, "legal_name")
    page_no = cur_page_no(@page_alphabets.first)
    @organizations = @orgs.where("legal_name" => /^#{page_no}/i)
    @employer_profiles = @organizations.map {|o| o.employer_profile}
  end

  def messages
    @sent_box = true
    @provider = current_user.person
  end

  def agency_messages
    @sent_box = true
    @broker_agency_profile = current_user.person.broker_agency_staff_roles.first.broker_agency_profile
  end

  def inbox
    @sent_box = true
    id = params["id"]||params['profile_id']
    @broker_agency_provider = BrokerAgencyProfile.find(id)
    @folder = (params[:folder] || 'Inbox').capitalize
    if current_user.person._id.to_s == id
      @provider = current_user.person
    else
      @provider = @broker_agency_provider
    end
  end

  private

  def find_hbx_profile
    @profile = current_user.person.hbx_staff_role.hbx_profile
  end

  def find_broker_agency_profile
    @broker_agency_profile = BrokerAgencyProfile.find(params[:id])
  end

  def check_admin_staff_role
    if current_user.has_hbx_staff_role? || current_user.has_csr_role?
    elsif current_user.has_broker_agency_staff_role?
      redirect_to broker_agencies_profile_path(:id => current_user.person.broker_agency_staff_roles.first.broker_agency_profile_id)
    else
      redirect_to new_broker_agencies_profile_path
    end
  end

  def check_broker_agency_staff_role
    if current_user.has_broker_agency_staff_role?
      redirect_to broker_agencies_profile_path(:id => current_user.person.broker_agency_staff_roles.first.broker_agency_profile_id)
    elsif current_user.has_broker_role?
      redirect_to broker_agencies_profile_path(id: current_user.person.broker_role.broker_agency_profile_id.to_s)
    else
      flash[:notice] = "You don't have a Broker Agency Profile associated with your Account!! Please register your Broker Agency first."
    end
  end

  def eligible_brokers
    Person.where('broker_role.broker_agency_profile_id': {:$exists => true}).where(:'broker_role.aasm_state'=> 'active').any_in(:'broker_role.market_kind'=>[person_market_kind, "both"])
  end

  def person_market_kind
    if @person.has_active_consumer_role?
      "individual"
    elsif @person.has_active_employee_role?
      "shop"
    end
  end
end
