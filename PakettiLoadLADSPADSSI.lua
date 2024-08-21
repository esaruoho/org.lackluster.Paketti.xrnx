local vb = renoise.ViewBuilder()
local checkboxes = {}
local deviceReadableNames = { LADSPA = {}, DSSI = {} }
local addedKeyBindings = {}
local preferencesFile = renoise.tool().bundle_path.."preferences_deviceLoaders.xml"

function LADSPADSSIAddAsShortcut()
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local keyBindingName = "Global:Track Devices:Load Device (LADSPA/DSSI) "..cb_info.name
      local midiMappingName = "Track Devices:Paketti:Load Device (LADSPA/DSSI) "..cb_info.name

      if not addedKeyBindings[keyBindingName] then
        print("Adding shortcut for: "..cb_info.name)

        local success, err = pcall(function()
          renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadvst(cb_info.path) end}
          renoise.tool():add_midi_mapping{name=midiMappingName, invoke=function() loadvst(cb_info.path) end}
        end)

        if success then
          addedKeyBindings[keyBindingName] = true
          LADSPADSSISaveToPreferencesFile(keyBindingName, midiMappingName, cb_info.path)
        else
          print("Could not add keybinding for "..cb_info.name..". It might already exist.")
        end
      else
        print("Keybinding for "..cb_info.name.." already added.")
      end
    end
  end
  renoise.app():show_status("Devices added. Open Settings -> Keys, search for 'Load Device' or Midi Mappings and search for 'Load Device'")
end

-- Function to save keybinding and MIDI mapping to PreferencesLoaders.xml
function LADSPADSSISaveToPreferencesFile(keyBindingName, midiMappingName, path)
  local file, err = io.open(preferencesFile, "a")
  if not file then
    print("Error opening preferences file: "..err)
    return
  end

  local keybindingEntry = string.format(
    '<KeyBinding name="%s">\n  <Path>%s</Path>\n</KeyBinding>\n',
    keyBindingName, path
  )

  local midiMappingEntry = string.format(
    '<MIDIMapping name="%s">\n  <Path>%s</Path>\n</MIDIMapping>\n',
    midiMappingName, path
  )

  file:write(keybindingEntry)
  file:write(midiMappingEntry)
  file:close()
end

-- Ensure PreferencesLoaders.xml exists and is properly formatted
function LADSPADSSIInitializePreferencesFile()
  local file, err = io.open(preferencesFile, "r")
  if not file then
    file, err = io.open(preferencesFile, "w")
    if not file then
      print("Error creating preferences file: "..err)
      return
    end
    file:write("<preferences_deviceLoaders>\n</preferences_deviceLoaders>\n")
    file:close()
  else
    file:close()
  end
end

-- Initialize preferences file
LADSPADSSIInitializePreferencesFile()

function LADSPADSSICreateScrollableList(plugins, title)
  if #plugins == 0 then
    return vb:column{
      vb:text{text=title, font="bold", height=20},
      vb:text{text="No LADSPA/DSSI Devices found on this computer.", font="italic", height=20}
    }
  end

  table.sort(plugins, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  local columns = { vb:column{}, vb:column{} }
  local num_plugins = #plugins
  local num_columns = 2

  if num_plugins > 2 * 30 then  -- Assuming each column can hold 30 plugins
    num_columns = math.ceil(num_plugins / 30)
    for i = 3, num_columns do
      table.insert(columns, vb:column{})
    end
  end

  local plugins_per_column = math.ceil(num_plugins / num_columns)

  for i, plugin in ipairs(plugins) do
    local column_index = math.floor((i - 1) / plugins_per_column) + 1
    local checkbox_id = "checkbox_"..title.."_"..tostring(i).."_"..tostring(math.random(1000000))
    local checkbox = vb:checkbox{value=false, id=checkbox_id}
    checkboxes[#checkboxes + 1] = {checkbox=checkbox, path=plugin.path, name=plugin.name}
    local plugin_row = vb:row{
      checkbox,
      vb:text{text=plugin.name}
    }

    columns[column_index]:add_child(plugin_row)
  end

  local column_container = vb:row{spacing=20}
  for _, column in ipairs(columns) do
    column_container:add_child(column)
  end

  return vb:column{
    vb:text{text=title, font="bold", height=20},
    column_container
  }
end

function LADSPADSSILoadSelectedDevices()
  local track_index = renoise.song().selected_track_index
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local pluginPath = cb_info.path
      print("Loading Device:", pluginPath)
      loadvst(pluginPath)
    end
  end
end

function LADSPADSSIResetSelection()
  for _, cb_info in ipairs(checkboxes) do
    cb_info.checkbox.value = false
  end
end

function LADSPADSSIRandomizeSelection()
  LADSPADSSIResetSelection()  -- Clear previous selections

  local numDevices = #checkboxes
  local numSelections = math.random(1, numDevices)

  local selectedIndices = {}
  while #selectedIndices < numSelections do
    local randIndex = math.random(1, numDevices)
    if not selectedIndices[randIndex] then
      selectedIndices[randIndex] = true
      checkboxes[randIndex].checkbox.value = true
    end
  end
end

function LADSPADSSIShowPluginListDialog()
  checkboxes = {}  -- Reinitialize the checkboxes table to avoid carrying over previous states
  local track_index = renoise.song().selected_track_index
  local available_plugins = renoise.song().tracks[track_index].available_devices
  local available_device_infos = renoise.song().tracks[track_index].available_device_infos
  deviceReadableNames = { LADSPA = {}, DSSI = {} }

  local pluginReadableNames = {}
  for i, plugin_info in ipairs(available_device_infos) do
    pluginReadableNames[available_plugins[i]] = plugin_info.short_name
  end

  for i, device_path in ipairs(available_plugins) do
    local device_name
    if device_path:find("LADSPA") then
      device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
      device_name = device_name:gsub("lsp%-plugins%-ladspa%.so:http://lsp%-plug%.in/plugins/ladspa/", "")
      table.insert(deviceReadableNames.LADSPA, {name=device_name, path=device_path})
    elseif device_path:find("DSSI") then
      device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
      table.insert(deviceReadableNames.DSSI, {name=device_name, path=device_path})
    end
  end

  local custom_dialog

  local button_height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
  local button_spacing = renoise.ViewBuilder.DEFAULT_DIALOG_SPACING
  local action_buttons = vb:column{
    uniform=true,
    width="100%",
    vb:horizontal_aligner{
      vb:button{
        text="Load Device(s)",
        width="50%",
        height=button_height,
        notifier=function()
          LADSPADSSILoadSelectedDevices()
        end
      },
      vb:button{
        text="Load Device(s) & Close",
        width="50%",
        height=button_height,
        notifier=function()
          LADSPADSSILoadSelectedDevices()
          custom_dialog:close()
        end
      }
    },
    vb:button{
      text="Add Device(s) as Shortcut(s) & MidiMappings",
      height=button_height,
      notifier=LADSPADSSIAddAsShortcut
    },
    vb:button{
      text="Randomize Selection",
      height=button_height,
      notifier=function()
        LADSPADSSIRandomizeSelection()
      end
    },
            vb:button { text="Select All",
        height=button_height,
        notifier=function()
        
    for _, cb_info in ipairs(checkboxes) do
        cb_info.checkbox.value = true
    end
end},
    vb:button{
      text="Reset Selection",
      height=button_height,
      notifier=function()
        LADSPADSSIResetSelection()
      end
    },
    vb:button{
      text="Cancel",
      height=button_height,
      notifier=function()
        custom_dialog:close()
      end
    }
  }

  local dialog_content = vb:column{
    margin=10,
    spacing=5,
    LADSPADSSICreateScrollableList(deviceReadableNames.LADSPA, "LADSPA"),
    LADSPADSSICreateScrollableList(deviceReadableNames.DSSI, "DSSI"),
    action_buttons
  }

  custom_dialog = renoise.app():show_custom_dialog("Load LADSPA/DSSI Device(s)", dialog_content)
end

