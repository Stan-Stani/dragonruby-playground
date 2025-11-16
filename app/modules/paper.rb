# Render target text at higher resolution
# to make it as crisp as possible
SCALE_FACTOR = 2
module Paper
  @id = 0

  def self.make_document(
    args:,
    text: "Haxx0r ipsum foo Trojan horse new all your base are belong to us ip error private shell fopen semaphore epoch char packet sniffer segfault gurfle bypass. Memory leak bubble sort injection leet malloc brute force double xss mega sudo mountain dew void echo win emacs linux piggyback bin. I'm compiling float bang case cat infinite loop Donald Knuth unix for /dev/null machine code then chown d00dz worm gnu crack packet bar eof while.

  Lib void brute force bypass nak concurrently all your base are belong to us break leapfrog bit default packet sniffer Linus Torvalds. Man pages packet stack trace Starcraft Donald Knuth pwned worm hello world public giga frack gurfle. Irc fork malloc fopen script kiddies flood blob fail hexadecimal while access semaphore loop mega Trojan horse foo gobble.

  Bang spoof *.* headers Dennis Ritchie pragma bubble sort mutex d00dz firewall wombat snarf. Win L0phtCrack back door big-endian tera injection flush suitably small values interpreter class hello world client segfault. Boolean buffer emacs highjack concurrently boolean I'm compiling malloc finally char protected void fopen ascii var cd Trojan horse public.
  ",
    # .25 * (8.5 by 11) standard north american printer paper
    w: 212.5, h: 275,
    fontsize_in_pixels: 20,
    x: 20, y: nil, raise_on_overflow: true, **other_sprite_methods
  )
    # default Y: top of document starts 20 pixels from top of screen
    y = args.grid.h - 20 - h if y.nil?
    target_w = w * SCALE_FACTOR
    target_h = h * SCALE_FACTOR
    fontsize_in_pixels_scaled = fontsize_in_pixels * SCALE_FACTOR

    args.outputs[:"document_texture_#{@id}"].width = target_w
    args.outputs[:"document_texture_#{@id}"].height = target_h
    args.outputs[:"document_texture_#{@id}"].background_color = [241, 233, 210, 255] # parchment rgb

    args.outputs[:"shadow_texture_#{@id}"].width = target_w
    args.outputs[:"shadow_texture_#{@id}"].height = target_h
    args.outputs[:"shadow_texture_#{@id}"].background_color = [241, 233, 210, 255] # parchment rgb

    # only will work with monospace
    # # currently does not force break really long groups of chars with no spaces
    char_w, = GTK.calcstringbox 'a',
                                size_px: fontsize_in_pixels_scaled

    top_bottom_margin_in_fraction_of_height = 0.05
    left_right_margin_in_fraction_of_width = 0.05

    exact_horizontal_margin_width = target_w * left_right_margin_in_fraction_of_width
    width_available_for_text = target_w - 2 * exact_horizontal_margin_width

    max_line_char_length = (width_available_for_text / char_w).to_i

    long_strings_split = String.wrapped_lines text,
                                              max_line_char_length

    line_count = nil
    args.outputs[:"document_texture_#{@id}"].labels << long_strings_split.map_with_index do |s, i|
      line_count = i
      {
        # want them to be the same so not using percentage of width right now
        # @todo clean this up
        # x: left_right_margin_in_fraction_of_width * target_w,
        x: target_h * top_bottom_margin_in_fraction_of_height,
        y: target_h - target_h * top_bottom_margin_in_fraction_of_height -
          # anchor seems to be bottom left for labels
          # so have to adjust by height of label here
          fontsize_in_pixels_scaled,
        text: s,
        size_px: fontsize_in_pixels_scaled,
        alignment_enum: 0,
        anchor_y: i,
        font: 'fonts/font.ttf'
      }
    end

    if raise_on_overflow && line_count * fontsize_in_pixels > h
      raise 'Rendered text exceeds document height'
    end

    shadow_offset_x = 5
    shadow_offset_y = -5
    
    current_id = @id
    @id += 1

    # return sprites
    [
      # box-shadow
      {
        x: x + shadow_offset_x,
        y: y + shadow_offset_y,
        w: w,
        h: h,
        r: 128, g: 128, b: 128, a: 192,
        path: :"shadow_texture_#{current_id}",
        scale_quality_enum: 2, # Enable anti-aliasing
        **other_sprite_methods,
        custom_data: { type: 'document.shadow',
                       shadow_offset: { x: shadow_offset_x,
                                        y: shadow_offset_y } }

      },
      # document
      {
        x: x,
        y: y,
        w: w,
        h: h,
        path: :"document_texture_#{current_id}",
        scale_quality_enum: 2, # Enable anti-aliasing
        **other_sprite_methods,
        custom_data: { type: 'document.document' }

      }
    ]
  end
end
