require 'spec_helper'

describe "importdata/edit" do
  before(:each) do
    @importdatum = assign(:importdatum, stub_model(Importdatum,
      :maxscheduler_id => "MyString",
      :site_id => "MyString",
      :user_id => "MyString",
      :data => "MyText"
    ))
  end

  it "renders the edit importdatum form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => importdata_path(@importdatum), :method => "post" do
      assert_select "input#importdatum_maxscheduler_id", :name => "importdatum[maxscheduler_id]"
      assert_select "input#importdatum_site_id", :name => "importdatum[site_id]"
      assert_select "input#importdatum_user_id", :name => "importdatum[user_id]"
      assert_select "textarea#importdatum_data", :name => "importdatum[data]"
    end
  end
end
