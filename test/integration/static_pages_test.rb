require 'test_helper'

class StaticPagesTest < ActionDispatch::IntegrationTest
  
describe "Static pages" do

  describe "Home page" do

    it "should have the content 'Sample App'" do
      visit '/index2.html'
      page.should have_content('Welcome aboard')
    end
  end
end

end
