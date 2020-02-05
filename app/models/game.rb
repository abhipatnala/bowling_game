class Game < ApplicationRecord
  serialize :frames, Array

  def record_roll knocked_pins
    frame_index = frames.index{|frame| frame[:throws] > 0 }
    frame = frames[frame_index]

    if frame_index == 9 and frame[:throws] == 2 and frame[:score] == 10
      if frames[8][:is_strike]
        frames[8][:score] += knocked_pins
      end
    elsif frame_index == 9 and frame[:throws] == 1 and spare_or_strike(frame)
    else
       update_previous_frames(frame_index, knocked_pins)
    end

    if knocked_pins == 10 && frame[:throws] == 2
      mark_strike(frames[frame_index])
    elsif frames[frame_index][:score] + knocked_pins == 10
      mark_spare(frames[frame_index])
    else
      frames[frame_index][:score] += knocked_pins
      frames[frame_index][:throws] -= 1
    end
    save
  end

  def total_score
    frames.pluck(:score).sum
  end

  private

  def mark_strike frame
    if frame[:frame_id] == 9
      handle_last_frame_strike(frame)
    else
      frame[:throws] = 0
      frame[:is_strike] = true
      frame[:score] = 10
    end
  end

  def mark_spare frame
    frame[:throws] = frame[:frame_id] == 9 ? 1 : 0
    frame[:is_spare] = true
    frame[:score] = 10
  end

  def handle_last_frame_strike frame
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
      frame[:is_strike] = true
    end
  end

  def update_previous_frames index, knocked_pins
    if index-1 > -1
      previous_frame = frames[index-1]
      if spare_or_strike(previous_frame) && frames[index][:throws] == 2
        previous_frame[:score] += knocked_pins
      elsif previous_frame[:is_strike] && frames[index][:throws] == 1
        previous_frame[:score] += knocked_pins
      end
    end

    if index-2 > -1
      second_previous = frames[index-2]
      if previous_frame[:is_strike] && second_previous[:is_strike]
        second_previous[:score] += knocked_pins
      end
    end
  end

  def spare_or_strike frame
    frame[:is_spare] || frame[:is_strike]
  end
end
