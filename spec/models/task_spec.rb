require 'rails_helper'

RSpec.describe Task, type: :model do

  it "should have valid factory" do
    expect(create(:task)).to be_valid
  end
  
  describe "Database table" do
    it { is_expected.to have_db_column :status }
    it { is_expected.to have_db_column :provider_id }
  end
  
  it { is_expected.to have_many :task_items }
  it { is_expected.to belong_to :user }
end

