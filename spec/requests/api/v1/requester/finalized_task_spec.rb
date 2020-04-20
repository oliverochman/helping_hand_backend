# frozen_string_literal: true

RSpec.describe 'PUT api/v1/tasks/:id', type: :request do
  let(:user) { create(:user) }
  let(:user_credentials) { user.create_new_auth_token }
  let(:user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials) }

  let(:provider) { create(:user) }
  let(:provider_credentials) { provider.create_new_auth_token }
  let(:provider_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(provider_credentials) }


  let(:task) { create(:task, status: 'delivered', provider: provider, user: user) }
  let!(:task_items) { 5.times { create(:task_item, task: task) } }

  describe 'Succesfully finalizes the task' do
    before do
      put "/api/v1/tasks/#{task.id}",
          params: { activity: 'finalized' },
          headers: user_headers
    end

    it 'returns a 200 response status' do
      expect(response).to have_http_status 200
    end

    it 'response with success message' do
      expect(response_json['message']).to eq 'You finalized the delivery'
    end
  end

  describe 'Unsuccesfully finalizes the task' do
    describe 'provider tries to finalize the otder' do
      before do
        put "/api/v1/tasks/#{task.id}",
            params: { activity: 'finalized' },
            headers: provider_headers
      end

      it 'returns a 500 response status' do
        expect(response).to have_http_status 500
      end

      it 'response with an error message' do
        expect(response_json['error_message']).to eq 'We are experiencing internal errors. Please refresh the page and contact support. No activity specified'
      end
    end

    describe 'Another user tries to finalize the task' do
      let!(:another_user) { create(:user) }
      let!(:another_user_credentials) { another_user.create_new_auth_token }
      let!(:another_user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(another_user_credentials) }  

      before do
        put "/api/v1/tasks/#{task.id}",
            params: { activity: 'finalized' },
            headers: another_user_headers
      end

      it 'returns a 500 response status' do
        expect(response).to have_http_status 500
      end

      it 'response with an error message' do
        expect(response_json['error_message']).to eq 'We are experiencing internal errors. Please refresh the page and contact support. No activity specified'
      end
    end
  end
end
