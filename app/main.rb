# frozen_string_literal: true

def random_hex_color
  '#' + 3.times.map { Numeric.rand(0..255).to_s(16).rjust(2, '0') }.join
end

def tick(args)
  # GTK.slowmo! 60

  block_width = 50
  # Initialize state
  args.state.rotation ||= 0
  args.state.x ||= 576
  args.state.y ||= 100
  args.state.block_arr ||= []
  args.state.just_right_mouse_downed_rect = nil
  args.state.block_relative_grab_anchor = nil
  handle_mouse_click(args, block_width)
  handle_right_mouse_down(args)
  handle_right_mouse_held(args)
  args.outputs.labels << [580, 400, "#{args.state.grabbed_block}"]
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
    h: block_width,
    customData: { id: random_hex_color }
  }
end

def handle_right_mouse_down(args)
  return unless args.inputs.mouse.buttons.right.down

  args.state.just_right_mouse_downed_rect = {
    x: args.inputs.mouse.buttons.right.down.x,
    y: args.inputs.mouse.buttons.right.down.y,
    w: 1,
    h: 1
  }
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
    if args.state.grabbed_block
      puts "grabbed_block_id: #{args.state.grabbed_block.customData.id}"
    end
    args.outputs.labels << [block.x, block.y, block.customData.id]

    handle_block_drag(args, block)
    handle_block_collision_and_position(args, block)
    next if args.state.grabbed_block == block

    block[:w] = block_width
    block[:h] = block_width
    block[:path] = 'sprites/blocks4.png'
    # block[:angle] = block[:angle]
    # block[:a] = block[:a]
    # block[:r] = block[:r]
  end

  if args.state.grabbed_block

    args.state.grabbed_block[:w] = block_width
    args.state.grabbed_block[:h] = block_width
    args.state.grabbed_block[:path] = 'sprites/blocks4.png'
    args.state.grabbed_block[:angle] = 45
    args.state.grabbed_block[:r] = 128
    puts "added grabbd block #{args.state.grabbed_block}"
    args.state.block_arr.delete(args.state.grabbed_block)
    args.state.block_arr.push(args.state.grabbed_block)
    args.outputs.sprites << args.state.grabbed_block
    args.outputs.labels << [580, 350,
                            "last grabbed #{args.state.grabbed_block}"]
  end
  args.outputs.sprites << args.state.block_arr
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

    return block
  end
  nil
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
    args.state.block_arr.each do |other_block|
      next if other_block.equal?(block)

      if block.intersect_rect?(other_block)
        # collision = true
        break
      end
    end
    # block.y -= 1 unless collision
  elsif block.y.negative?
    block.y = 0
  end
end
