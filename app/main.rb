def tick(args)
  sprite_width = 50

  args.state.rotation ||= 0
  args.state.x ||= 576
  args.state.y ||= 100
  args.state.block_arr ||= []

  if args.inputs.mouse.click
    x_place_at = args.inputs.mouse.click.point.x - sprite_width / 2
    y_place_at = args.inputs.mouse.click.point.y - sprite_width / 2
    # Add a new block to the array on click
    # args.state.block_arr << {
    #   x: args.state.x,
    #   y: args.state.y,
    # }

    args.state.block_arr << {
      x: x_place_at,
      y: y_place_at
    }
  end

  args.outputs.labels << [580, 400, 'Hello World!']

  # Draw all blocks from block_arr
  args.state.block_arr.each do |block|
    if block.y.positive?

      collision = false
      args.state.block_arr.each do |other_block|
        next if other_block.equal?(block)
        # Check if the rectangles overlap
        if [block.x, block.y, sprite_width, sprite_width].intersect_rect?([other_block.x, other_block.y, sprite_width, sprite_width])
          collision = true
          break
        end
      end

      puts collision
    block.y -= 1 unless collision
    elsif block.y.negative?
      block.y = 0
    end

    args.outputs.sprites << [block[:x], block[:y], sprite_width, sprite_width, 'sprites/blocks4.png', block[:rotation]]
  end

  args.state.rotation -= 1
end
