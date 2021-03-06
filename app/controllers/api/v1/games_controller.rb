class Api::V1::GamesController < ApplicationController

 before_action :game_exists?, only: [:roll_ball, :get_score]

  DEFAULT_FRAME = {
    strike: false,
    spare: false,
    throws: 2,
    score: 0
  }

  def create
    frames =  []
    10.times { |i| frames << {frame_id: i}.merge(DEFAULT_FRAME) }
    new_game = Game.create(
      name: name,
      frames: frames
    )
    render json: { game_id: new_game.id }
  end

  def roll_ball
    render json: current_game.record_roll(knocked_pins)
  end

  def get_score
    render json: {
      frames: current_game.frames,
      total_score: current_game.total_score
    }
  end

  private

  def name
    @name ||= params[:name]
  end

  def game_id
    @game_id ||= params[:game_id]
  end

  def knocked_pins
    @knocked_pins ||= params[:knocked_pins].to_i
  end

  def current_game
    @current_game ||= Game.find_by_id(game_id)
  end

  def game_exists?
    if current_game.nil?
      render json: { errors: ["No game exists"]}
    end
  end
end
