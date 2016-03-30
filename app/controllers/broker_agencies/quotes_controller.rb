class BrokerAgencies::QuotesController < ApplicationController

  def index
    @quotes = Quote.all
    @plans = Plan.where("active_year" => 2016).limit(15)

    if !params['plans'].nil? && params['plans'].count > 0
      #binding.pry
      @q =  Quote.first #Quote.find(Quote.first.id)

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
    end
  end

  def new
  end

  def create
  	quote = Quote.new(params.dup.permit(:quote_name))
    quote.build_relationship_benefits
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

 private

 def employee_roster_group_by_family_id
    params[:employee_roster].inject({}) do  |new_hash,e|
      new_hash[e[1][:family_id]].nil? ? new_hash[e[1][:family_id]] = [e[1]]  : new_hash[e[1][:family_id]] << e[1]
      new_hash
    end
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
        employee_roster.each do |id,employee|
          csv << [  employee[:family_id],
                    employee[:relationship],
                    employee[:dob]
                  ]
        end
      end
    end
  end


end
