class Game < ApplicationRecord
  serialize :frames, Array

  def record_roll knocked_pins
    frame = frames.find {|frame| frame[:throws] > 0 }

    return { errors: "Game is completed" } if frame.nil?

    calculate_previous_frame_scores(knocked_pins, frame)
    calculate_frame_score(knocked_pins, frame)

    save

    return { message: "Thats a great ball roll" }
  end

  def total_score
    frames.pluck(:score).sum
  end

  private

  def mark_strike frame
    if frame[:frame_id] == 9
      handle_tenth_frame_strike(frame)
    else
      frame[:throws] = 0
      frame[:strike] = true
      frame[:score] = 10
    end
  end

  def mark_spare frame
    frame[:throws] = frame[:frame_id] == 9 ? 1 : 0
    frame[:spare] = true
    frame[:score] = 10
  end

  def handle_tenth_frame_strike frame
    if frame[:score] == 10 && frame[:throws] == 1
      frame[:throws] = 0
      frame[:score] += 10
    elsif frame[:score] == 10 && frame[:throws] == 2
      frame[:throws] = 1
      frame[:score] = 20
    elsif frame[:score] == 20 && frame[:throws] == 1
      frame[:throws] = 0
      frame[:score] = 30
    elsif frame[:score] == 0
      frame[:throws] = 2
      frame[:score] = 10
      frame[:strike] = true
    end
  end

  def calculate_previous_frame_scores(knocked_pins, frame)
    if strike_on_first_throw_in_tenth_frame? frame
      if frames[8][:strike]
        frames[8][:score] += knocked_pins
      end
    else
      unless skip_update_of_previous_frames? frame
        update_previous_frames(frame, knocked_pins)
      end
    end
  end

  def update_previous_frames frame, knocked_pins
    update_first_previous(frame, knocked_pins) if frame[:frame_id]-1 > -1

    update_second_previous(frame, knocked_pins) if frame[:frame_id]-2 > -1
  end

  def update_first_previous(frame, knocked_pins)
    previous_frame = frames[frame[:frame_id]-1]
    if spare_or_strike(previous_frame) && frame[:throws] == 2
      previous_frame[:score] += knocked_pins
    elsif previous_frame[:strike] && frame[:throws] == 1
      previous_frame[:score] += knocked_pins
    end
  end

  def update_second_previous(frame, knocked_pins)
    second_previous = frames[frame[:frame_id]-2]
    previous_frame = frames[frame[:frame_id]-1]
    if previous_frame[:strike] && second_previous[:strike]
      second_previous[:score] += knocked_pins
    end
  end

  def calculate_frame_score(knocked_pins, frame)
    if is_strike?(knocked_pins, frame[:throws])
      mark_strike(frame)
    elsif is_spare?(knocked_pins, frame[:score])
      mark_spare(frame)
    else
      frame[:score] += knocked_pins
      frame[:throws] -= 1
    end
  end

  def spare_or_strike frame
    frame[:spare] || frame[:strike]
  end

  def is_strike?(knocked_pins, throws)
    knocked_pins == 10 && throws == 2
  end

  def is_spare?(knocked_pins, current_score)
    knocked_pins + current_score == 10
  end

  def strike_on_first_throw_in_tenth_frame? frame
    frame[:frame_id] == 9 && frame[:throws] == 2 && frame[:score] == 10
  end

  def skip_update_of_previous_frames? frame
    frame[:frame_id] == 9 && frame[:throws] == 1 && spare_or_strike(frame)
  end
end
