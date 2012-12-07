require 'spec_helper'

describe "importdata/index" do
  before(:each) do
    assign(:importdata, [
      stub_model(Importdatum,
        :maxscheduler_id => "Maxscheduler",
        :site_id => "Site",
        :user_id => "User",
        :data => "MyText"
      ),
      stub_model(Importdatum,
        :maxscheduler_id => "Maxscheduler",
        :site_id => "Site",
        :user_id => "User",
        :data => "MyText"
      )
    ])
  end

  it "renders a list of importdata" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Maxscheduler".to_s, :count => 2
    assert_select "tr>td", :text => "Site".to_s, :count => 2
    assert_select "tr>td", :text => "User".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
