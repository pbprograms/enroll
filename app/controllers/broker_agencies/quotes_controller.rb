class BrokerAgencies::QuotesController < ApplicationController

  def index
    @quotes = Quote.all
    @plans = Plan.where("active_year" => 2016).limit(15)

    if params['plans'].count > 1
      #binding.pry
      @q = Quote.find(params['quote'])

      @quote_results = Hash.new

      unless @q.nil?
        params['plans'].each do |plan_id|
          p = Plan.find(plan_id)
          detailCost = Array.new

          @q.quote_households.each do |hh|
            pcd = PlanCostDecorator.new(p, hh, @q, p)
            detailCost << pcd.get_family_details_hash
          end
          @quote_results[p.name] = detailCost

        end
      end

    end

  end

end
