# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
    # Include default devise modules.

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :tasks
  has_many :accepted_tasks, class_name: "Task", foreign_key: "provider_id"
end
