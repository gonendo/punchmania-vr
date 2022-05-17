buttons = {}
for tag, port in pairs(manager.machine.ioport.ports) do
  for field_name, field in pairs(manager.machine.ioport.ports[tag].fields) do
    if field_name == "Coin 1" or
       field_name == "1 Player Start" or
       field_name == "Select L" or
       field_name == "Select R" or
       field_name == "Top Left" or
       field_name == "Middle Left" or
       field_name == "Bottom Left" or
       field_name == "Top Right" or
       field_name == "Middle Right" or
       field_name == "Bottom Right" or
       field_name == "Skip Check" then
        buttons[field_name] = field
      end
  end
end

socket = emu.file("", 7)
socket:open("socket.127.0.0.1:5555")

function send_game_state()
  left_top = manager.machine.output:get_value("left top pad")
  left_middle = manager.machine.output:get_value("left middle pad")
  left_bottom = manager.machine.output:get_value("left bottom pad")
  right_top = manager.machine.output:get_value("right top pad")
  right_middle = manager.machine.output:get_value("right middle pad")
  right_bottom = manager.machine.output:get_value("right bottom pad")

  left_top_lamp = manager.machine.output:get_value("left top lamp")
  left_middle_lamp = manager.machine.output:get_value("left middle lamp")
  left_bottom_lamp = manager.machine.output:get_value("left bottom lamp")
  right_top_lamp = manager.machine.output:get_value("right top lamp")
  right_middle_lamp = manager.machine.output:get_value("right middle lamp")
  right_bottom_lamp = manager.machine.output:get_value("right bottom lamp")

  socket:write(
  left_top .. "," .. left_middle .. "," .. left_bottom .. "," ..
  right_top .. "," .. right_middle .. "," .. right_bottom .. "," ..
  left_top_lamp .. "," .. left_middle_lamp .. "," .. left_bottom_lamp .. "," ..
  right_top_lamp .. "," .. right_middle_lamp .. "," .. right_bottom_lamp
  )
end

emu.register_frame_done(function ()
  manager.machine.video:snapshot()
end)

emu.register_periodic(function ()
  local data = ""
  repeat
    local res = socket:read(100)
    data = data .. res
  until #res == 0

  if string.find(data, "button_coin_pressed") then
    buttons["Skip Check"]:set_value(1)
    buttons["Coin 1"]:set_value(1)
  elseif string.find(data, "button_coin_release") then
    buttons["Skip Check"]:set_value(0)
    buttons["Coin 1"]:set_value(0)
  elseif string.find(data, "button_start_pressed") then
    buttons["1 Player Start"]:set_value(1)
  elseif string.find(data, "button_start_release") then
    buttons["1 Player Start"]:set_value(0)
  elseif string.find(data, "button_select_left_pressed") then
    buttons["Select L"]:set_value(1)
  elseif string.find(data, "button_select_left_release") then
    buttons["Select L"]:set_value(0)
  elseif string.find(data, "button_select_right_pressed") then
    buttons["Select R"]:set_value(1)
  elseif string.find(data, "button_select_right_release") then
    buttons["Select R"]:set_value(0)
  elseif string.find(data, "button_left_top_pressed") then
    buttons["Top Left"]:set_value(1)
  elseif string.find(data, "button_left_top_release") then
    buttons["Top Left"]:set_value(0)
  elseif string.find(data, "button_left_middle_pressed") then
    buttons["Middle Left"]:set_value(1)
  elseif string.find(data, "button_left_middle_release") then
    buttons["Middle Left"]:set_value(0)
  elseif string.find(data, "button_left_bottom_pressed") then
    buttons["Bottom Left"]:set_value(1)
  elseif string.find(data, "button_left_bottom_release") then
    buttons["Bottom Left"]:set_value(0)
  elseif string.find(data, "button_right_top_pressed") then
    buttons["Top Right"]:set_value(1)
  elseif string.find(data, "button_right_top_release") then
    buttons["Top Right"]:set_value(0)
  elseif string.find(data, "button_right_middle_pressed") then
    buttons["Middle Right"]:set_value(1)
  elseif string.find(data, "button_right_middle_release") then
    buttons["Middle Right"]:set_value(0)
  elseif string.find(data, "button_right_bottom_pressed") then
    buttons["Bottom Right"]:set_value(1)
  elseif string.find(data, "button_right_bottom_release") then
    buttons["Bottom Right"]:set_value(0)
  end

  send_game_state()
end)
