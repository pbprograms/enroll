class BrokerAgencies::QuotesController < ApplicationController

  before_action :find_quote , :only => [:destroy ,:show]


  def index
    @quotes = Quote.where("broker_role_id" => current_user.person.broker_role.id)
    @plans =  Plan.shop_health_by_active_year(2016)
    @plan_quote_criteria  = []
    if !params['plans'].nil? && params['plans'].count > 0

      @q =  Quote.find(params[:quote]) #Quote.find(Quote.first.id)

      @quote_results = Hash.new

      unless @q.nil?
        params['plans'].each do |plan_id|
          p = Plan.find(plan_id)
          detailCost = Array.new

          @q.quote_households.each do |hh|
            pcd = PlanCostDecorator.new(p, hh, @q, p)
            detailCost << pcd.get_family_details_hash.sort_by { |m| [m[:family_id], -m[:age], -m[:employee_contribution]] }
          end
          @quote_results[p.name] = detailCost
        end
      end
    else
      #CACHE ME PLEASE
      #TODO
      @plans.each{|p| @plan_quote_criteria << [p.metal_level, p.carrier_profile.organization.legal_name, p.plan_type,
       p.deductible.gsub(/\$/,'').gsub(/,/,'').to_i, p.id.to_s, p.carrier_profile.abbrev, p.nationwide, p.dc_in_network]
      }
      @metals =      @plan_quote_criteria.map{|p| p[0]}.uniq.append('any')
      @carriers =    @plan_quote_criteria.map{|p| [ p[1], p[5] ] }.uniq.append(['any','any'])
      @plan_types =  @plan_quote_criteria.map{|p| p[2]}.uniq.append('any')
      @dc_network =  ['true', 'false', 'any']
      @nationwide =  ['true', 'false', 'any']
      @select_detail = @plan_quote_criteria.to_json
    end

  end

  def edit
    @quote = Quote.find(params[:id])

    qhh = QuoteHousehold.new
    qm = QuoteMember.new

    qhh.quote_members << qm
    @quote.quote_households << qhh
  end

  def update

    @quote = Quote.find(params[:id])

    sanitize_quote_roster_params

    params.permit!

    if (@quote.update_attributes(params[:quote].permit(
      #:employer_profile_attributes => [ :entity_kind, :dba, :legal_name],
      :quote_name,
      :quote_households_attributes => [
        :id,
        :family_id,
        :quote_members_attributes => [:id, :first_name, :dob, :employee_relationship]]
    )))
      puts "Saved!"
    else
      puts "Error!"
      puts @quote.errors.messages.inspect
    end

    redirect_to edit_broker_agencies_quote_path(@quote)

  end

  def create
  	quote = Quote.new(params.permit(:quote_name))
    quote.build_relationship_benefits
    quote.broker_role_id= current_user.person(:try).broker_role.id
    employee_roster = employee_roster_group_by_family_id
  	employee_roster.each do |family_id, family_members|
      house_hold = QuoteHousehold.new
      family_members.each do |family_member|
  		  house_hold.quote_members << QuoteMember.new(family_member.permit(:family_id,:employee_relationship,:dob))
  		end
      quote.quote_households<< house_hold
    end
    if quote.save
      redirect_to  broker_agencies_quotes_root_path ,  :flash => { :notice => "Successfully saved the employee roster" }
    else
      render "new" , :flash => {:error => "Unable to save the employee roster" }
    end
  end


  def show
    @quote = Quote.find(params[:id])
    @employee_roster = @quote.quote_households.map(&:quote_members).flatten
  end

	def build_employee_roster
    @employee_roster = parse_employee_roster_file
    render "new"
  end

  def upload_employee_roster
	end

  def download_employee_roster
    @quote = Quote.find(params[:id])
    @employee_roster = @quote.quote_households.map(&:quote_members).flatten
    send_data(csv_for(@employee_roster), :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=Employee_Roster.csv")
  end

  def destroy
    if @quote.destroy
      respond_to do |format|
        format.js { flash.now[:notice] = "Deleted the quote Successfully" }
      end
    end
  end

 private

 def sanitize_quote_roster_params
   params[:quote][:quote_households_attributes].each do |key, fid|
     params[:quote][:quote_households_attributes].delete(key) if fid['family_id'].blank?
   end
 end

  def employee_roster_group_by_family_id
    params[:employee_roster].inject({}) do  |new_hash,e|
      new_hash[e[1][:family_id]].nil? ? new_hash[e[1][:family_id]] = [e[1]]  : new_hash[e[1][:family_id]] << e[1]
      new_hash
    end
  end

  def find_quote
    @quote = Quote.find(params[:id])
  end

  def parse_employee_roster_file
    begin
      CSV.parse(params[:employee_roster_file].read) if params[:employee_roster_file].present?
    rescue Exception => e
      redirect_to build_employee_roster_broker_agencies_profiles_path, :flash => { :error => "Unable to parse the csv file" }
    end
  end

  def csv_for(employee_roster)
    (output = "").tap do
      CSV.generate(output) do |csv|
        csv << ["FamilyID", "Relationship", "DOB"]
        employee_roster.each do |employee|
          csv << [  employee.family_id,
                    employee.employee_relationship,
                    employee.dob
                  ]
        end
      end
    end
  end


end
