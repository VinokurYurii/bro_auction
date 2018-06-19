# frozen_string_literal: true

class LotsController < ApiController
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  protect_from_forgery

  def index
    @is_my = params[:my]
    current_user = 1
    if @is_my
      render json: Lot.findUserLots(current_user)
    end

    render json: Lot.where(status: 1)
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end
end
