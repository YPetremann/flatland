require "defines"
function print_all(message) for _, player in pairs(game.players) do player.print(message) end end
function bootstrap(event)
  if not global.run_once then
    global.run_once = true
    local player = game.players[1]
    local window = player.gui.center.add{type="frame", caption="Flatland : Which material as floor ?", name="flatland_window",direction="horizontal"}
    window.add{type="button", caption="Grass", name="flatland_choose{'grass'}"}
    window.add{type="button", caption="Concrete", name="flatland_choose{'concrete'}"}
    window.add{type="button", caption="Don't use", name="flatland_choose{false}"}
  end
end
script.on_init(bootstrap)
script.on_load(bootstrap)
script.on_event(defines.events.on_player_created, bootstrap)

script.on_event(defines.events.on_player_created, function(event)
  if not global.run_once then
    global.run_once = true
    local player = game.players[event.player_index]
    local window = player.gui.center.add{type="frame", caption="Flatland : Which material as floor ?", name="flatland_window",direction="horizontal"}
    window.add{type="button", caption="Grass", name="flatland_choose{'grass'}"}
    window.add{type="button", caption="Concrete", name="flatland_choose{'concrete'}"}
    window.add{type="button", caption="Concrete", name="flatland_choose{''}"}
  end
end)
function on_gui_click_flatland_choose(event, params) 
  global.material = params[1]
  local player = game.players[event.player_index]
  player.gui.center.flatland_window.destroy()
  chunk_flush()
end

function chunk_flush() 
  if global.material then
    while #global.chunks > 0 do
      chunk = table.remove(global.chunks, 1)
      if #global.material > 0 then
        for key, entity in pairs(chunk.surface.find_entities_filtered({area=chunk.area, type="decorative"})) do entity.destroy() end
        for key, entity in pairs(chunk.surface.find_entities_filtered({area=chunk.area, name="dead-dry-hairy-tree"})) do entity.destroy() end
        for key, entity in pairs(chunk.surface.find_entities_filtered({area=chunk.area, name="dead-grey-trunk"})) do entity.destroy() end
        for key, entity in pairs(chunk.surface.find_entities_filtered({area=chunk.area, name="dead-tree"})) do entity.destroy() end
        for key, entity in pairs(chunk.surface.find_entities_filtered({area=chunk.area, name="dry-hairy-tree"})) do entity.destroy() end
        for key, entity in pairs(chunk.surface.find_entities_filtered({area=chunk.area, name="dry-tree"})) do entity.destroy() end
        for key, entity in pairs(chunk.surface.find_entities_filtered({area=chunk.area, name="stone-rock"})) do entity.destroy() end
        local array = {}
        for x=chunk.area.left_top.x, chunk.area.right_bottom.x, 1 do
          for y=chunk.area.left_top.y, chunk.area.right_bottom.y, 1 do
            tile = chunk.surface.get_tile(x, y)
            if not (tile and tile.valid) then
            elseif tile.name == 'out-of-map' then      
            elseif tile.name == 'water' or tile.name == 'water-green' or tile.name == 'deepwater' or tile.name == 'deepwater-green' then
              table.insert(array, {name="water",position={x,y}})
            else
              table.insert(array, {name=global.material,position={x,y}})
            end
          end
        end
        chunk.surface.set_tiles(array)
      end
    end
  end
end

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element.name
  local function_name = element
  local function_params = {}
  if string.find(element, "%{") then
    function_name = string.sub(element, 0, string.find(element, "%{")-1)
    function_params = assert(loadstring("return "..string.sub(element, string.find(element, "%{")+0)))()
  end
  callback = _G["on_gui_click_"..function_name]
  if type(callback)=="function" then 
    callback(event, function_params)
  end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
  if not global.chunks then global.chunks = {} end
  table.insert(global.chunks, {area=event.area, surface=event.surface})
  chunk_flush()
end)
