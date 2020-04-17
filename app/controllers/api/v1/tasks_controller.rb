class Api::V1::TasksController < ApplicationController
  before_action :authenticate_user!, only: %i[create update]
  before_action :restrict_user_to_have_one_active_task, only: %i[create]
  before_action :get_task, only: :update

  def index
    tasks = Task.where(status: :confirmed)
    render json: tasks
  end

  def create
    task = Task.create(user_id: params[:user_id])
    task.task_items.create(product_id: params[:product_id])
    render json: create_json_response(task)
  end

  def update
    case params[:activity]
    when 'confirmed'
      if @task.is_confirmable?(current_user)
        @task.update_attribute(:status, params[:activity])
        render json: { message: "Your task has been confirmed" }
      else
        render_error_message(@task)
      end
    when 'claimed'
      if @task.is_claimable?(current_user)
        @task.update_attributes(status: params[:activity], provider: current_user)
        render json: { message: 'Success' }
      else
        render_error_message(@task)
      end
    else
      product = Product.find(params[:product_id])
      user_task = current_user.tasks.find(params[:id])

      user_task.task_items.create(product: product)
      render json: create_json_response(@task)
    end
  end

  private

  def get_task
    @task = Task.find(params[:id])
  end

  def restrict_user_to_have_one_active_task
    if current_user.tasks.any?{|task| task.status ==  'confirmed'}
      render json: { error: "You can only have one active task at a time." }, status: 403
      return
    end
  end

  def render_error_message(task)
    case
    when params[:activity] == 'claimed' && task.claimed? 
      message = 'You cannot claim a claimed task'
    when params[:activity] == 'claimed' && task.user == current_user
      message = 'You cant claim your own task'
    when task.task_items.count >= 40 && task.user == current_user
      message = "You have selected too many products."
    when task.task_items.count < 5 && task.user == current_user
      message = "You have to pick at least 5 products."
    else
      message = "We are experiencing internal errors. Please refresh the page and contact support. No activity specified"
    end

    render json: { error_message: message }, status: 400
  end

  def create_json_response(task)
    json = { task: TaskSerializer.new(task) }
    json.merge!(message: "The product has been added to your request")
  end
end
