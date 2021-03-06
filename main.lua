function love.load(arg)
  input_filename = arg[2] or "input.gif"
  output_filename = arg[3] or "output.png"
  tile_size = arg[4] or 16
  spritesheet_row_width = arg[5] or 8
  pixel_value_reduction_factor = math.min(math.max(1, 2^(arg[6] or 7)), 255) -- min 1 (2^0) max 255 (2^8-1)

  if love.filesystem.isFile(input_filename) then
    input = love.image.newImageData(input_filename)
  else
    print("Error: Input file "..input_filename.." not found.")
    love.event.quit()
    return
  end

  tiles_wide = input:getWidth() / tile_size
  tiles_high = input:getHeight() / tile_size

  image_is_divisible_by_width = tiles_wide == math.floor(tiles_wide)
  image_is_divisible_by_height = tiles_high == math.floor(tiles_high)

  if not image_is_divisible_by_width or not image_is_divisible_by_height then
    if not image_is_divisible_by_width then
      print("Error: Image width is not divisible by "..tile_size)
    end
    if not image_is_divisible_by_height then
      print("Error: Image height is not divisible by "..tile_size)
    end
    love.event.quit()
    return
  else
    print("Image is "..tiles_wide.." tiles wide.")
    print("Image is "..tiles_high.." tiles high.")
  end

  tile_table = {}

  cycles_per_one_percent = input:getWidth() * input:getHeight() / 100
  cycle_counter = 0
  percentage_complete = 0

  print("Building tile table...")
  io.write("0%")

  for tile_x = 0, tiles_wide - 1 do
    for tile_y = 0, tiles_high - 1 do

      tile_index = ""

      for pixel_x = 0, tile_size - 1 do
        for pixel_y = 0, tile_size - 1 do
          cycle_counter = cycle_counter + 1
          if cycle_counter >= cycles_per_one_percent then
            cycle_counter = 0
            percentage_complete = percentage_complete + 1
            io.write("\r"..percentage_complete.."%")
          end
          r, g, b, a = input:getPixel(tile_x * tile_size + pixel_x, tile_y * tile_size + pixel_y)
          tile_index = tile_index.."r"..math.floor(r/pixel_value_reduction_factor)..
                                   "g"..math.floor(g/pixel_value_reduction_factor)..
                                   "b"..math.floor(b/pixel_value_reduction_factor)..
                                   "a"..math.floor(a/pixel_value_reduction_factor)
        end
      end

      tile_table[tile_index] = {x = tile_x, y = tile_y}
    end
  end

  print("\r100%")

  unique_tiles = 0
  for _, _ in pairs(tile_table) do
    unique_tiles = unique_tiles + 1
  end

  print("Unique tiles: "..unique_tiles)

  spritesheet_column_height = math.ceil(unique_tiles / spritesheet_row_width)

  print("Creating spritesheet: "..spritesheet_row_width.."x"..spritesheet_column_height..
        " ("..spritesheet_row_width * tile_size.."x"..spritesheet_column_height * tile_size..")")

  spritesheet = love.image.newImageData(spritesheet_row_width * tile_size, spritesheet_column_height * tile_size)
  spritesheet_row = 0
  spritesheet_column = 0

  for _, tile in pairs(tile_table) do
    spritesheet:paste(input,
    spritesheet_row * tile_size, spritesheet_column * tile_size,
    tile.x * tile_size, tile.y * tile_size,
    tile_size, tile_size)

    spritesheet_row = spritesheet_row + 1
    if spritesheet_row == spritesheet_row_width then
      spritesheet_row = 0
      spritesheet_column = spritesheet_column + 1
    end
  end

  spritesheet:encode(output_filename)

  print("Done!")

  image = love.graphics.newImage(spritesheet)
  love.graphics.setMode(image:getWidth(), image:getHeight())
end

function love.draw()
  love.graphics.draw(image, 0, 0)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

