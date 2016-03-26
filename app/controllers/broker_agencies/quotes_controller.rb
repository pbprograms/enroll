class BrokerAgencies::QuotesController < ApplicationController

  def index
    @quotes = Quote.all
    @plans = Plan.where("active_year" => 2016).limit(15)


  end

end
