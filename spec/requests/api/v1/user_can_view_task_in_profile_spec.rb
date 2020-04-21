# frozen_string_literal: true

RSpec.describe "Api::V1::ProfilesController", type: :request do
  # let(:user) { create(:user) }



  # let(:another_provider) { create(:user) }
  # let(:another_provider_credentials) { another_provider.create_new_auth_token }
  # let(:another_provider_headers) { { HTTP_ACCEPT: "application/json" }.merge!(another_provider_credentials) }

  # let!(:task_items) { 5.times { create(:task_item, task: task) } }

  # let!(:another_task) { create(:task, status: "delivered", provider: provider, user: user) }
  # let!(:another_task_items) { 5.times { create(:task_item, task: another_task) } }

  # let!(:another_task_2) { create(:task, status: "confirmed", provider: provider, user: user) }
  # let!(:another_task_items_2) { 5.times { create(:task_item, task: another_task_2) } }

  # let(:another_task_3) { create(:task, status: "claimed", provider: another_provider) }
  # let!(:task_items) { 5.times { create(:task_item, task: another_task_3) } }

  describe "Successfully" do
    describe "Provider can see request he claimed in his profile" do
      let(:provider) { create(:user) }
      let(:provider_credentials) { provider.create_new_auth_token }
      let(:provider_headers) { { HTTP_ACCEPT: "application/json" }.merge!(provider_credentials) }
      
      let(:task) { create(:task, provider: provider) }

      before do
        get "/api/v1/profiles",
          headers: provider_headers
      end

      it "returns a 200 response status" do
        expect(response).to have_http_status 200
      end

      it "returns a list of claimed tasks" do
        expect(response_json.count).to eq 2
      end

      it "returns the correct provider id" do
        expect(response_json.first["provider_id"]).to eq provider.id
        expect(response_json.last["provider_id"]).to eq provider.id
      end
    end

    describe "Requester can view his ongoing requests" do
      let(:requester) { create(:user) }
      let(:requester_credentials) { requester.create_new_auth_token }
      let(:requester_headers) { { HTTP_ACCEPT: "application/json" }.merge!(requester_credentials) }
    
      let!(:task) { create(:task, user: requester) }
      
      before do
        get "/api/v1/profiles",
          headers: requester_headers
      end

      it "returns a 200 response status" do
        expect(response).to have_http_status 200
      end

      it "returns a list of claimed tasks" do
        expect(response_json.count).to eq 1
      end
    end
  end

  describe "Unsuccessfully" do
    describe "Visitor cannot see another users ongoing task" do
      let(:empty_user) { create(:user) }
      let(:empty_user_credentials) { empty_user.create_new_auth_token }
      let(:empty_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(empty_user_credentials) }  

      before do
        get "/api/v1/profiles",
          headers: empty_user_headers
      end

      it "returns a 200 response status" do
        expect(response).to have_http_status 200
      end

      it "returns a message no ongoing tasks" do
        binding.pry
        expect(response_json['message']).to eq "You don't have any ongoing tasks."
      end
    end
  end
end
