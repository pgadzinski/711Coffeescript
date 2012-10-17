require "spec_helper"

describe ImportdataController do
  describe "routing" do

    it "routes to #index" do
      get("/importdata").should route_to("importdata#index")
    end

    it "routes to #new" do
      get("/importdata/new").should route_to("importdata#new")
    end

    it "routes to #show" do
      get("/importdata/1").should route_to("importdata#show", :id => "1")
    end

    it "routes to #edit" do
      get("/importdata/1/edit").should route_to("importdata#edit", :id => "1")
    end

    it "routes to #create" do
      post("/importdata").should route_to("importdata#create")
    end

    it "routes to #update" do
      put("/importdata/1").should route_to("importdata#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/importdata/1").should route_to("importdata#destroy", :id => "1")
    end

  end
end
