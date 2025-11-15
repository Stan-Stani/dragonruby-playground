def tick(args)
  block_width = 50

  args.state.rotation ||= 0
  args.state.x ||= 576
  args.state.y ||= 100
  args.state.block_arr ||= []
  args.state.just_right_mouse_downed_rect ||= nil
  args.state.block_relative_grab_anchor = nil

  if args.inputs.mouse.click
    x_place_at = args.inputs.mouse.click.point.x - block_width / 2
    y_place_at = args.inputs.mouse.click.point.y - block_width / 2
    # Add a new block to the array on click
    # args.state.block_arr << {
    #   x: args.state.x,
    #   y: args.state.y,
    # }

    args.state.block_arr << {
      x: x_place_at,
      y: y_place_at,
      w: block_width,
      h: block_width
    }
  end




  if args.inputs.mouse.buttons.right.down
   args.state.just_right_mouse_downed_rect = {
       x:  args.inputs.mouse.buttons.right.down.x,
       y: args.inputs.mouse.buttons.right.down.y,
       w: 1,
       h: 1
     }
  end



  if args.inputs.mouse.buttons.right.held
   click_right_rect = {
      x:  args.inputs.mouse.buttons.right.held.x,
      y: args.inputs.mouse.buttons.right.held.y,
      w: 1,
      h: 1
    }


  else
    args.state.grabbed_block = nil
  end


  args.outputs.labels << [580, 400, 'Hello World!']

  # Draw all blocks from block_arr
  args.state.block_arr.each do |block|


    if args.state.just_right_mouse_downed_rect && block.intersect_rect?(args.state.just_right_mouse_downed_rect )
      args.state.block_relative_grab_anchor_rect = {
        x: args.state.just_right_mouse_downed_rect.x - block.x,
        y: args.state.just_right_mouse_downed_rect.y - block.y,
        w: 1,
        h: 1
      }
      args.state.grabbed_block = block
    end

    if args.state.block_relative_grab_anchor_rect && args.inputs.mouse.buttons.right.held && block == args.state.grabbed_block
puts "hello"
      block.x = args.inputs.mouse.buttons.right.held.x - args.state.block_relative_grab_anchor_rect.x
      block.y = args.inputs.mouse.buttons.right.held.y - args.state.block_relative_grab_anchor_rect.y


      puts block.y == nil
    end

    if block.y.positive?

      collision = false
      args.state.block_arr.each do |other_block|
        next if other_block.equal?(block)
        # Check if the rectangles overlap
        if block.intersect_rect?(other_block)
          collision = true
          break
        end
      end
    # block.y -= 1 unless collision
    elsif block.y.negative?
      block.y = 0
    end

    args.outputs.sprites << [block[:x], block[:y], block_width, block_width, 'sprites/blocks4.png', block[:rotation]]
  end

  args.state.just_right_mouse_downed_rect = nil

end
