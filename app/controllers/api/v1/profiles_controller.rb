# frozen_string_literal: true

class Api::V1::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def index
    # ongoing_tasks = Task.where(status: %w[claimed delivered])
    # .where(provider_id: current_user.id)
    # .or(Task.where(status: %w[claimed delivered])
    # .where(user_id: current_user.id))

    claimed_tasks = current_user.accepted_tasks.empty? ? "You don't have any claimed tasks." : current_user.accepted_tasks 
    created_tasks = current_user.tasks.empty? ?  "You don't have any ongoing tasks." : current_user.tasks
    render json: { claimed_tasks: claimed_tasks, created_tasks: created_tasks}
  end
end
