local vb = renoise.ViewBuilder()
local dialog = nil
local slider1_value_text
local slider2_value_text
local xy_value_text
local position
local reopen_dialog_flag = false

-- Key handler function
local function PakettiPluginEditorPositionControlKeyHandlerFunc(dialog, key)
  if key.modifiers == "" and key.name == "exclamation" then
    print("Exclamation key pressed, closing dialog.")
    dialog:close()
  else
    return key
  end
end

-- Check if selected instrument has a plugin loaded
local function PakettiPluginEditorPositionControlGetPluginEditorPosition()
  local song = renoise.song()
  local instr = song.selected_instrument
  if not instr.plugin_properties.plugin_loaded then
    return nil
  end
  local xml_data = instr.plugin_properties.plugin_device.active_preset_data
  local pos = xml_data:match("<PluginEditorWindowPosition>%d+,%d+</PluginEditorWindowPosition>")
  return pos and {x = tonumber(pos:match("(%d+),")), y = tonumber(pos:match(",(%d+)"))} or {x = 0, y = 0}
end

-- Update XML data with new position
local function PakettiPluginEditorPositionControlSetPluginEditorPosition(x, y)
  local song = renoise.song()
  local instr = song.selected_instrument
  local xml_data = instr.plugin_properties.plugin_device.active_preset_data

  -- Clamp the values to the maximum limits
  x = math.min(math.floor(x or 0), 1500)
  y = math.min(math.floor(y or 0), 850)

  -- Extract and print the relevant line
  local position_line = xml_data:match("<PluginEditorWindowPosition>%d+,%d+</PluginEditorWindowPosition>")
  print("Current XML Data: ", position_line)
  print("Setting new position: x = " .. tostring(x) .. ", y = " .. tostring(y))

  local new_xml = xml_data:gsub("<PluginEditorWindowPosition>%d+,%d+</PluginEditorWindowPosition>",
    ("<PluginEditorWindowPosition>%d,%d</PluginEditorWindowPosition>"):format(x, y))

  -- Extract and print the relevant line from the new XML
  local new_position_line = new_xml:match("<PluginEditorWindowPosition>%d+,%d+</PluginEditorWindowPosition>")
  print("New XML Data: ", new_position_line)

  instr.plugin_properties.plugin_device.active_preset_data = new_xml
end

-- Timer function to update the external editor position
local function update_external_editor_position()
  local song = renoise.song()
  local instr = song.selected_instrument
  instr.plugin_properties.plugin_device.external_editor_visible = true
  if renoise.tool():has_timer(update_external_editor_position) then
    renoise.tool():remove_timer(update_external_editor_position)
  end
  reopen_dialog_flag = true
end

-- Function to set position and update external editor
local function set_position_and_update(x, y)
  local song = renoise.song()
  local instr = song.selected_instrument
  instr.plugin_properties.plugin_device.external_editor_visible = false

  if renoise.tool():has_timer(update_external_editor_position) then
    renoise.tool():remove_timer(update_external_editor_position)
  end

  PakettiPluginEditorPositionControlSetPluginEditorPosition(x, y)

  renoise.tool():add_timer(update_external_editor_position, 250)
  print("Set position to: x = " .. tostring(math.floor(x)) .. ", y = " .. tostring(math.floor(y)))
end

-- Function to dump the current position from sliders and update external editor
local function dump_position(sliders)
  local new_x = sliders[1].value
  local new_y = sliders[2].value
  local song = renoise.song()
  local instr = song.selected_instrument
  instr.plugin_properties.plugin_device.external_editor_visible = false

  if renoise.tool():has_timer(update_external_editor_position) then
    renoise.tool():remove_timer(update_external_editor_position)
  end

  PakettiPluginEditorPositionControlSetPluginEditorPosition(new_x, new_y)

  renoise.tool():add_timer(update_external_editor_position, 250)
  print("Dumped position from sliders: x = " .. tostring(math.floor(new_x)) .. ", y = " .. tostring(math.floor(new_y)))
end

-- Function to dump the current position from XY pad and update external editor
local function dump_position_xy(xypad)
  local value = xypad.value
  local new_x = value.x * 1500
  local new_y = (1 - value.y) * 850
  local song = renoise.song()
  local instr = song.selected_instrument
  instr.plugin_properties.plugin_device.external_editor_visible = false

  if renoise.tool():has_timer(update_external_editor_position) then
    renoise.tool():remove_timer(update_external_editor_position)
  end

  PakettiPluginEditorPositionControlSetPluginEditorPosition(new_x, new_y)

  renoise.tool():add_timer(update_external_editor_position, 250)
  print("Dumped position from XY pad: x = " .. tostring(math.floor(new_x)) .. ", y = " .. tostring(math.floor(new_y)))
end

-- Function to create the dialog
local function PakettiPluginEditorPositionControlCreateDialog()
  local sliders
  local xypad = vb:xypad{
    min = {x = 0, y = 0},
    max = {x = 1, y = 1},
    value = {x = 0.75, y = 0.75},
    notifier = function(value)
      local x = math.floor(value.x * 1500)
      local y = math.floor((1 - value.y) * 850)
      xy_value_text.text = "XY Value: x = " .. tostring(x) .. ", y = " .. tostring(y)
    end
  }

  sliders = {
    vb:slider{
      min = 0,
      max = 1500,
      value = position.x,
      width = 200,
      notifier = function(value)
        slider1_value_text.text = "Slider1 Value: " .. tostring(math.floor(value))
        print("Slider 1 Value: " .. tostring(math.floor(value)))
      end
    },
    vb:slider{
      min = 0,
      max = 850,
      value = position.y,
      width = 200,
      notifier = function(value)
        slider2_value_text.text = "Slider2 Value: " .. tostring(math.floor(value))
        print("Slider 2 Value: " .. tostring(math.floor(value)))
      end
    }
  }

  slider1_value_text = vb:text{
    text = "Slider1 Value: " .. tostring(position.x)
  }
  
  slider2_value_text = vb:text{
    text = "Slider2 Value: " .. tostring(position.y)
  }
  
  xy_value_text = vb:text{
    text = "XY Value: x = " .. tostring(xypad.value.x * 1500) .. ", y = " .. tostring((1 - xypad.value.y) * 850)
  }

  local dump_button = vb:button{
    text = "Slider Dump to External Editor Position",
    notifier = function()
      dump_position(sliders)
    end
  }

  local dump_xy_button = vb:button{
    text = "XY Dump to External Editor Position",
    notifier = function()
      dump_position_xy(xypad)
    end
  }

  local set_button_200 = vb:button{
    text = "Set Position to 200",
    notifier = function()
      set_position_and_update(200, 200)
    end
  }

  local set_button_500 = vb:button{
    text = "Set Position to 500",
    notifier = function()
      set_position_and_update(500, 500)
    end
  }

  local position_text = vb:text{
    text = "Current Position: x = " .. tostring(position.x) .. ", y = " .. tostring(position.y)
  }

  return vb:column{
    vb:row{
      vb:column{
        style = "border",
        margin = 4,
        xypad
      },
      xy_value_text
    },
    vb:row{
      vb:column{
        sliders[1],
        slider1_value_text
      },
      vb:column{
        sliders[2],
        slider2_value_text
      }
    },
    vb:row{dump_button, dump_xy_button, set_button_200, set_button_500},
    vb:row{position_text}
  }
end

-- Function to show the dialog
local function PakettiPluginEditorPositionControlShowDialog()
  if dialog and dialog.visible then
    dialog:close()
  end
  
  position = PakettiPluginEditorPositionControlGetPluginEditorPosition() or {x = 0, y = 0}

  dialog = renoise.app():show_custom_dialog("Plugin Editor Position", PakettiPluginEditorPositionControlCreateDialog(), PakettiPluginEditorPositionControlKeyHandlerFunc)
end

local function PakettiPluginEditorPositionControlShowInitialDialog()
  local song = renoise.song()
  local instr = song.selected_instrument
  if instr.plugin_properties.plugin_loaded and not instr.plugin_properties.plugin_device.external_editor_visible then
    instr.plugin_properties.plugin_device.external_editor_visible = true
  end

  PakettiPluginEditorPositionControlShowDialog()
end

-- Add a periodic timer to handle reopening the dialog if needed
local function periodic_check()
  if reopen_dialog_flag then
    reopen_dialog_flag = false
    PakettiPluginEditorPositionControlShowDialog()
  end
end

renoise.tool():add_timer(periodic_check, 100)

PakettiPluginEditorPositionControlShowInitialDialog()



