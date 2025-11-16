def tick(args)
  args.state.rotation ||= 0

  args.outputs.sprites <<
    make_document(args: args, x: args.grid.w / 4, y: 100,
                  raise_on_overflow: false, angle: args.state.rotation)

  args.state.rotation += 0.25
end

# Render target text at higher resolution
# to make it as crisp as possible
SCALE_FACTOR = 2
def make_document(args:, text: "Haxx0r ipsum foo Trojan horse new all your base are belong to us ip error private shell fopen semaphore epoch char packet sniffer segfault gurfle bypass. Memory leak bubble sort injection leet malloc brute force double xss mega sudo mountain dew void echo win emacs linux piggyback bin. I'm compiling float bang case cat infinite loop Donald Knuth unix for /dev/null machine code then chown d00dz worm gnu crack packet bar eof while.

Lib void brute force bypass nak concurrently all your base are belong to us break leapfrog bit default packet sniffer Linus Torvalds. Man pages packet stack trace Starcraft Donald Knuth pwned worm hello world public giga frack gurfle. Irc fork malloc fopen script kiddies flood blob fail hexadecimal while access semaphore loop mega Trojan horse foo gobble.

Bang spoof *.* headers Dennis Ritchie pragma bubble sort mutex d00dz firewall wombat snarf. Win L0phtCrack back door big-endian tera injection flush suitably small values interpreter class hello world client segfault. Boolean buffer emacs highjack concurrently boolean I'm compiling malloc finally char protected void fopen ascii var cd Trojan horse public.
", w: 425, h: 550, fontsize_in_pixels: 20, x: 20, y: nil, raise_on_overflow: true, **other_sprite_methods)
  # default Y: top of document starts 20 pixels from top of screen
  y = args.grid.h - 20 - h if y.nil?
  target_w = w * SCALE_FACTOR
  target_h = h * SCALE_FACTOR
  fontsize_in_pixels_scaled = fontsize_in_pixels * SCALE_FACTOR

  args.outputs[:document_texture].width = target_w
  args.outputs[:document_texture].height = target_h
  args.outputs[:document_texture].background_color = [241, 233, 210, 255] # parchment rgb

  args.outputs[:shadow_texture].width = target_w
  args.outputs[:shadow_texture].height = target_h
  args.outputs[:shadow_texture].background_color = [241, 233, 210, 255] # parchment rgb

  # only will work with monospace
  # # currently does not force break really long groups of chars with no spaces
  char_w, = GTK.calcstringbox 'a',
                              fontsize_in_pixels_scaled: fontsize_in_pixels_scaled

  top_bottom_margin_in_fraction_of_height = 0.05
  left_right_margin_in_fraction_of_width = 0.05

  exact_horizontal_margin_width = target_w * left_right_margin_in_fraction_of_width
  width_available_for_text = target_w - 2 * exact_horizontal_margin_width

  max_line_char_length = (width_available_for_text / char_w).to_i

  long_strings_split = String.wrapped_lines text,
                                            max_line_char_length

  line_count = nil
  args.outputs[:document_texture].labels << long_strings_split.map_with_index do |s, i|
    line_count = i
    {
      # want them to be the same so not using percentage of width right now
      # @todo clean this up
      # x: left_right_margin_in_fraction_of_width * target_w,
      x: target_h * top_bottom_margin_in_fraction_of_height,
      y: target_h - target_h * top_bottom_margin_in_fraction_of_height -
        # anchor seems to be bottom left for labels
        # so have to adjust by height of label here
        fontsize_in_pixels,
      text: s,
      fontsize_in_pixels_scaled: fontsize_in_pixels_scaled,
      alignment_enum: 0,
      anchor_y: i,
      font: 'fonts/font.ttf'
    }
  end

  if raise_on_overflow && line_count * fontsize_in_pixels > h
    raise 'Rendered text exceeds document height'
  end

  # string_w, = GTK.calcstringbox scaled_up_label.text,
  #                               size_px: scaled_up_label.size_px

  # return sprites
  [
    # box-shadow
    {
      x: x + 5,
      y: y - 5,
      w: w,
      h: h,
      r: 128, g: 128, b: 128, a: 192,
      path: :shadow_texture,
      scale_quality_enum: 2, # Enable anti-aliasing
      **other_sprite_methods
    },
    # document
    {
      x: x,
      y: y,
      w: w,
      h: h,
      path: :document_texture,
      scale_quality_enum: 2, # Enable anti-aliasing
      **other_sprite_methods
    }
  ]
end
