require 'spec_helper'

describe "importdata/show" do
  before(:each) do
    @importdatum = assign(:importdatum, stub_model(Importdatum,
      :maxscheduler_id => "Maxscheduler",
      :site_id => "Site",
      :user_id => "User",
      :data => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Maxscheduler/)
    rendered.should match(/Site/)
    rendered.should match(/User/)
    rendered.should match(/MyText/)
  end
end
