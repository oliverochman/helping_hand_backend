# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PUT api/v1/tasks/:id', type: :request do
  let(:user) { create(:user) }
  let(:user_credentials) { user.create_new_auth_token }
  let(:user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials) }

  let(:task) { create(:task, user: user) }
  let!(:task_items) { 5.times { create(:task_item, task: task) } }

  describe 'Succesfully' do
    before do
      put "/api/v1/tasks/#{task.id}",
          params: { activity: 'confirmed' },
          headers: user_headers
    end

    it 'response with success message' do
      expect(response_json['message']).to eq 'Your task has been confirmed'
    end

    it 'sets task attribute confirmed to true' do
      task.reload
      expect(task.status).to eq 'confirmed'
    end
  end

  describe 'unsuccessfull when' do
    describe 'user is not logged in' do
      before do
        put "/api/v1/tasks/#{task.id}",
            params: { activity: 'confirmed' }
      end

      it 'response with error message' do
        expect(response_json['errors'].first).to eq 'You need to sign in or sign up before continuing.'
      end

      it 'returns 401 status' do
        expect(response.status).to eq 401
      end
    end

    describe 'no activity param' do
      before do
        put "/api/v1/tasks/#{task.id}",
            params: { activity: nil },
            headers: user_headers
      end

      it 'response with error message' do
        expect(response_json['error_message']).to eq "We are experiencing internal errors. Please refresh the page and contact support. Couldn't find Product without an ID"
      end

      it 'returns 400 status' do
        expect(response.status).to eq 400
      end
    end

    describe 'wrong activity param' do
      before do
        put "/api/v1/tasks/#{task.id}",
            params: { activity: 'wrong string' },
            headers: user_headers
      end

      it 'response with error message' do
        expect(response_json['error_message']).to eq "We are experiencing internal errors. Please refresh the page and contact support. Couldn't find Product without an ID"
      end

      it 'returns 400 status' do
        expect(response.status).to eq 400
      end
    end

    describe 'to many task items in task' do
      let!(:additional_task_items) { 36.times { create(:task_item, task: task) } }

      before do
        task.reload
        put "/api/v1/tasks/#{task.id}",
            params: { activity: 'confirmed' },
            headers: user_headers
      end

      it 'response with error message' do
        expect(response_json['error_message']).to eq 'You have selected too many products.'
      end

      it 'returns 400 status' do
        expect(response.status).to eq 400
      end
    end

    describe 'not enough task items in task' do
      let(:empty_task) { create(:task, user: user) }

      before do
        put "/api/v1/tasks/#{empty_task.id}",
            params: { activity: 'confirmed' },
            headers: user_headers
      end

      it 'response with error message' do
        expect(response_json['error_message']).to eq 'You have to pick at least 5 products.'
      end

      it 'returns 400 status' do
        expect(response.status).to eq 400
      end
    end

    describe 'wrong task id param sent in' do
      before do
        put '/api/v1/tasks/1234567',
            params: { activity: 'confirmed' },
            headers: user_headers
      end

      it 'response with error message' do
        expect(response_json['error_message']).to eq "We are experiencing internal errors. Please refresh the page and contact support. Couldn't find Task with 'id'=1234567"
      end

      it 'returns 400 status' do
        expect(response.status).to eq 400
      end
    end
  end
end
