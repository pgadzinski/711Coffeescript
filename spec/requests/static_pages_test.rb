require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the content" do
      #visit "/index2.html"	
      get "/index2.html"
      response.should contain("Getting started")
      #page.should have_content('a')
    end
  end
end