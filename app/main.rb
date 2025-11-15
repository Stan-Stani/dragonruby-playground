# frozen_string_literal: true

def tick(args)
  block_width = 50

  # Initialize state
  args.state.rotation ||= 0
  args.state.x ||= 576
  args.state.y ||= 100
  args.state.block_arr ||= []
  args.state.just_right_mouse_downed_rect ||= nil
  args.state.block_relative_grab_anchor = nil

  handle_mouse_click(args, block_width)
  handle_right_mouse_down(args)
  handle_right_mouse_held(args)

  args.outputs.labels << [580, 400, 'Hello World!']

  draw_and_update_blocks(args, block_width)

  args.state.just_right_mouse_downed_rect = nil
end

def handle_mouse_click(args, block_width)
  return unless args.inputs.mouse.click

  x_place_at = args.inputs.mouse.click.point.x - block_width / 2
  y_place_at = args.inputs.mouse.click.point.y - block_width / 2

  args.state.block_arr << {
    x: x_place_at,
    y: y_place_at,
    w: block_width,
    h: block_width
  }
end

def handle_right_mouse_down(args)
  if args.inputs.mouse.buttons.right.down
    args.state.just_right_mouse_downed_rect = {
      x: args.inputs.mouse.buttons.right.down.x,
      y: args.inputs.mouse.buttons.right.down.y,
      w: 1,
      h: 1
    }
  end
end

def handle_right_mouse_held(args)
  if args.inputs.mouse.buttons.right.held
    # This hash is not used, so we don't assign it
    # {
    #   x: args.inputs.mouse.buttons.right.held.x,
    #   y: args.inputs.mouse.buttons.right.held.y,
    #   w: 1,
    #   h: 1
    # }
  else
    args.state.grabbed_block = nil
  end
end

def draw_and_update_blocks(args, block_width)
  args.state.block_arr.each do |block|
    handle_block_grab(args, block)
    handle_block_drag(args, block)
    handle_block_collision_and_position(args, block)
    args.outputs.sprites << [
      block[:x], block[:y], block_width, block_width,
      'sprites/blocks4.png', block[:rotation]
    ]
  end
end

def handle_block_grab(args, block)
  if args.state.just_right_mouse_downed_rect &&
     block.intersect_rect?(args.state.just_right_mouse_downed_rect)
    args.state.block_relative_grab_anchor_rect = {
      x: args.state.just_right_mouse_downed_rect.x - block.x,
      y: args.state.just_right_mouse_downed_rect.y - block.y,
      w: 1,
      h: 1
    }
    args.state.grabbed_block = block
  end
end

def handle_block_drag(args, block)
  if args.state.block_relative_grab_anchor_rect &&
     args.inputs.mouse.buttons.right.held &&
     block == args.state.grabbed_block
    block.x = args.inputs.mouse.buttons.right.held.x -
              args.state.block_relative_grab_anchor_rect.x
    block.y = args.inputs.mouse.buttons.right.held.y -
              args.state.block_relative_grab_anchor_rect.y
  end
end

def handle_block_collision_and_position(args, block)
  if block.y.positive?
    collision = false
    args.state.block_arr.each do |other_block|
      next if other_block.equal?(block)
      if block.intersect_rect?(other_block)
        collision = true
        break
      end
    end
    # block.y -= 1 unless collision
  elsif block.y.negative?
    block.y = 0
  end
end
