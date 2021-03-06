require "rails_helper"

RSpec.describe "Api::V1::TasksController", type: :request do
  let!(:product)  { create(:product) } 
  let!(:task_1) { create(:task, confirmed: true) } 

  before do
    post "/api/v1/tasks", params: { product_id: product.id }
    @task_id = (response_json)["task"]["id"]
    @task = Task.find(@task_id)
    put "/api/v1/tasks/#{@task.id}", params: { activity: "confirmed" }
  end

  describe "GET /tasks" do
    before do
      get "/api/v1/tasks"
    end

    it "returns a 200 response status" do
      expect(response).to have_http_status 200
    end

    it "returns correct number of tasks" do
      expect(response_json.count).to eq 2
    end

    it "task contains a product" do
      expect(response_json[1]["products"][0]["amount"]).to eq 1
    end
  end
end
