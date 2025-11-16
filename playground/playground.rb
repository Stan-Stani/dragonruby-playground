def tick(args)
  args.state.score ||= 0
  args.state.score += 1 if args.state.tick_count % 60 == 0

  # Render target text at higher resolution
  scale_factor = 2
  target_w = 200 * scale_factor
  target_h = 100 * scale_factor

  args.outputs[:my_texture].width = target_w
  args.outputs[:my_texture].height = target_h
  args.outputs[:my_texture].background_color = [241, 233, 210, 255] # parchment rgb

  args.outputs[:my_texture].labels << {
    x: target_w / 2,
    y: target_h / 2,
    text: "Score: #{args.state.score}",
    size_px: 20 * scale_factor,
    alignment_enum: 1,
    font: 'fonts/font.ttf'
  }

  # Display with anti-aliasing enabled
  args.outputs.sprites << {
    x: 300,
    y: 400,
    w: 200,
    h: 100,
    path: :my_texture,
    scale_quality_enum: 2, # Enable anti-aliasing
    angle: 45
  }

  # Direct screen text (identical settings)
  args.outputs.labels << {
    x: 700,
    y: 450,
    text: "Score: #{args.state.score}",
    size_px: 20,
    alignment_enum: 1,
    font: 'fonts/font.ttf',
    angle: 70
  }

  # Labels to show which is which
  args.outputs.labels << {
    x: 400, y: 380,
    text: 'Render Target',
    size_enum: -1
  }

  args.outputs.labels << {
    x: 700, y: 380,
    text: 'Direct Render',
    size_enum: -1
  }
end
