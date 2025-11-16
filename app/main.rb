# frozen_string_literal: true

require 'app/modules/paper'

def random_hex_color
  '#' + 3.times.map { Numeric.rand(0..255).to_s(16).rjust(2, '0') }.join
end

def tick(args)
  # GTK.slowmo! 60
  args.outputs.background_color = [0, 0, 0]
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
  args.outputs.labels << { x: 580, y: 400, text: "#{args.state.grabbed_block}",
                           r: 256, g: 256, b: 256 }
  draw_and_update_blocks(args, block_width)
  args.state.just_right_mouse_downed_rect = nil

  handle_documents(args)
end

def handle_documents(args)
  args.state.are_docus_initialized ||= false
  args.state.shadow_and_docu_tuple_arr ||= []

  # manage each document's associated shadow
  if args.state.are_docus_initialized

    args.state.shadow_and_docu_tuple_arr.each do |shadow, document|
      shadow.x = document.x + shadow.custom_data.shadow_offset.x
      shadow.y = document.y + shadow.custom_data.shadow_offset.y
      shadow.angle = document.angle if document.angle

      # keep shadow just behind document but over anything else
      document_index = args.state.block_arr.index(document)
      next unless document_index + 1 != args.state.block_arr.index(shadow)

      args.state.block_arr.delete(shadow)
      args.state.block_arr.insert(args.state.block_arr.index(document),
                                  shadow)
    end
  else

    add_document(args, { x: args.grid.w / 4,
                         y: 100 })

    add_document(args, { text:
   "\
Doggy Daycare

Fido
$75

THANK YOU
\
",
                         x: args.grid.w / 4,
                         y: 100 })

    add_document(args, { text:
   "\
Don't forget it this time!

Your password is the first letter of your pets' names \
in alphabetical order.\
",
                         x: args.grid.w / 4,
                         y: 100 })

    add_document(args, { text:
   "\
 Bird Baths R US


 - Gold-inlaid bath: $200
 - Plaque \"Loulou's Bath\": $100

THANK YOU\
",
                         x: args.grid.w / 4,
                         y: 100 })

    add_document(args, { x: args.grid.w / 4,
                         y: 100 })
    add_document(args, { x: args.grid.w / 4,
                         y: 100 })

    add_document(args, { text:
   "\
Tongue of the Cat Grooming

- Sylvestra $100

THANK YOU
",
                         x: args.grid.w / 4,
                         y: 100 })

    add_document(args, { x: args.grid.w / 4,
                         y: 100 })
    add_document(args, { x: args.grid.w / 4,
                         y: 100 })

    args.state.are_docus_initialized = true
  end
end

def add_document(args, make_document_args)
  args.state.shadow_and_docu_tuple_arr << Paper.make_document(
    args: args,
    raise_on_overflow: false,
    **make_document_args
  )
  args.state.block_arr.push(*args.state.shadow_and_docu_tuple_arr.flatten)
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
    path: 'sprites/blocks4.png',
    custom_data: { id: random_hex_color }
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

def draw_and_update_blocks(args, _block_width)
  args.state.block_arr.each do |block|
    handle_block_grab(args, block)

    block[:custom_data] ||= {}
    if args.state.grabbed_block
      puts "grabbed_block_id: #{args.state.grabbed_block.custom_data.id}"
    end
    args.outputs.labels << { x: block.x, y: block.y, text: block.custom_data.id,
                             r: 256, g: 256, b: 256 }

    handle_block_drag(args, block)
    handle_block_collision_and_position(args, block)
    next if args.state.grabbed_block == block

    # block[:angle] = block[:angle]
    # block[:a] = block[:a]
    # block[:r] = block[:r]
  end

  if args.state.grabbed_block

    puts "added grabbd block #{args.state.grabbed_block}"
    args.state.block_arr.delete(args.state.grabbed_block)
    args.state.block_arr.push(args.state.grabbed_block)
    args.outputs.sprites << args.state.grabbed_block
    args.outputs.labels << { x: 580, y: 350,
                             text: "last grabbed #{args.state.grabbed_block}", r: 256, g: 256, b: 256 }
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
    block.angle = [1, 2, -1, -2].sample

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
