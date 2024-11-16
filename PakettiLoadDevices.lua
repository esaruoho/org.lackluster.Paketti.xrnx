local vb
local checkboxes = {}
local deviceReadableNames = {}
local addedKeyBindings = {}
local preferencesFile = renoise.tool().bundle_path .. "preferences_deviceLoaders.xml"
local current_device_type = "Native"
local device_types = {"Native", "VST", "VST3", "AudioUnit", "LADSPA", "DSSI"}
local custom_dialog
local dialog_content_view
local device_list_view
local current_device_list_content = nil

local DEVICES_PER_COLUMN = 39
local random_select_percentage = 0

-- Initialize Preferences File
function initializePreferencesFile()
  local file, err = io.open(preferencesFile, "r")
  if not file then
    file, err = io.open(preferencesFile, "w")
    if not file then
      print("Error creating preferences file: " .. err)
      return
    end
    file:write("<preferences_deviceLoaders>\n</preferences_deviceLoaders>\n")
    file:close()
  else
    file:close()
  end
end

initializePreferencesFile()

-- Function to check if a keybinding exists
function doesKeybindingExist(keyBindingName)
  for _, binding in ipairs(renoise.tool().keybindings) do
    if binding.name == keyBindingName then
      return true
    end
  end
  return false
end

-- Save to Preferences File
function saveToPreferencesFile(keyBindingName, midiMappingName, path)
  local file, err = io.open(preferencesFile, "a")
  if not file then
    print("Error opening preferences file: " .. err)
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

-- Load from Preferences File
function loadFromPreferencesFile()
  local file, err = io.open(preferencesFile, "r")
  if not file then
    print("Error opening preferences file: " .. err)
    return
  end

  local entries = {}
  local current_entry = nil
  for line in file:lines() do
    local keybinding_start = line:match('<KeyBinding name="(.-)">')
    if keybinding_start then
      current_entry = {type = "KeyBinding", name = keybinding_start}
    end

    local midimapping_start = line:match('<MIDIMapping name="(.-)">')
    if midimapping_start then
      current_entry = {type = "MIDIMapping", name = midimapping_start}
    end

    local path_line = line:match('<Path>(.-)</Path>')
    if path_line and current_entry then
      current_entry.path = path_line
      table.insert(entries, current_entry)
      current_entry = nil
    end
  end
  file:close()

  for _, entry in ipairs(entries) do
    local device_type = entry.name:match("Load Device %((.-)%)")
    local path = entry.path

    if entry.type == "KeyBinding" then
      -- Re-add keybinding
      local success, err = pcall(function()
        local device_type_copy = device_type
        local path_copy = path
        renoise.tool():add_keybinding{
          name = entry.name,
          invoke = function()
            if device_type_copy == "Native" then
              loadnative(path_copy)
            else
              loadvst(path_copy)
            end
          end
        }
      end)
      if not success then
        print("Could not add keybinding for " .. entry.name .. ": " .. err)
      end
    elseif entry.type == "MIDIMapping" then
      -- Re-add midi mapping
      local success, err = pcall(function()
        local device_type_copy = device_type
        local path_copy = path
        renoise.tool():add_midi_mapping{
          name = entry.name,
          invoke = function(message)
            if message:is_trigger() then
              if device_type_copy == "Native" then
                loadnative(path_copy)
              else
                loadvst(path_copy)
              end
            end
          end
        }
      end)
      if not success then
        print("Could not add midi mapping for " .. entry.name .. ": " .. err)
      end
    end
  end
end

function isAnyDeviceSelected()
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      return true
    end
  end
  return false
end

function loadSelectedDevices()
  if not isAnyDeviceSelected() then
    renoise.app():show_status("Nothing was selected, doing nothing.")
    return false
  end

  local track_index = renoise.song().selected_track_index
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local pluginPath = cb_info.path
      print("Loading Device:", pluginPath)
      if current_device_type == "Native" then
        loadnative(pluginPath)
      else
        loadvst(pluginPath)
      end
    end
  end
  return true
end

function addAsShortcut()
  if not isAnyDeviceSelected() then
    renoise.app():show_status("Nothing was selected, doing nothing.")
    return
  end

  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local keyBindingName = "Global:Paketti:Load Device (" .. current_device_type .. ") " .. cb_info.name
      local midiMappingName = "Track Devices:Paketti:Load Device (" .. current_device_type .. ") " .. cb_info.name

      local device_type = current_device_type
      local path = cb_info.path

      if not addedKeyBindings[keyBindingName] then
        print("Adding shortcut for: " .. cb_info.name)

        local success, err = pcall(function()
          renoise.tool():add_keybinding{
            name = keyBindingName,
            invoke = function()
              if device_type == "Native" then
                loadnative(path)
              else
                loadvst(path)
              end
            end
          }
          renoise.tool():add_midi_mapping{
            name = midiMappingName,
            invoke = function(message)
              if message:is_trigger() then
                if device_type == "Native" then
                  loadnative(path)
                else
                  loadvst(path)
                end
              end
            end
          }
        end)

        if success then
          addedKeyBindings[keyBindingName] = true
          saveToPreferencesFile(keyBindingName, midiMappingName, cb_info.path)
        else
          print("Could not add keybinding for " .. cb_info.name .. ". It might already exist.")
        end
      else
        print("Keybinding for " .. cb_info.name .. " already added.")
      end
    end
  end
  renoise.app():show_status("Devices added. Open Settings -> Keys, search for 'Load Device' or Midi Mappings and search for 'Load Device'")
end

function resetSelection()
  for _, cb_info in ipairs(checkboxes) do
    cb_info.checkbox.value = false
  end
end

function updateRandomSelection()
  if #checkboxes == 0 then
    renoise.app():show_status("Nothing to randomize from.")
    return
  end

  resetSelection()

  local numDevices = #checkboxes
  local percentage = random_select_percentage
  local numSelections = math.floor((percentage / 100) * numDevices + 0.5)

  local percentage_text_view = vb.views["random_percentage_text"]

  if numSelections == 0 then
    percentage_text_view.text = "None"
    return
  elseif numSelections >= numDevices then
    percentage_text_view.text = "All"
    for _, cb_info in ipairs(checkboxes) do
      cb_info.checkbox.value = true
    end
    return
  else
    percentage_text_view.text = tostring(math.floor(percentage + 0.5)) .. "%"
  end

  local indices = {}
  for i = 1, numDevices do
    indices[i] = i
  end

  for i = numDevices, 2, -1 do
    local j = math.random(1, i)
    indices[i], indices[j] = indices[j], indices[i]
  end

  for i = 1, numSelections do
    local idx = indices[i]
    checkboxes[idx].checkbox.value = true
  end
end

function createDeviceList(plugins, title)
  if #plugins == 0 then
    return vb:column{vb:text{text="No Devices found for this type.", font="italic", height=20}}
  end

  -- Determine number of columns based on DEVICES_PER_COLUMN
  local num_devices = #plugins
  local devices_per_column = DEVICES_PER_COLUMN
  local num_columns = math.ceil(num_devices / devices_per_column)

  local columns = {}
  for i = 1, num_columns do
    columns[i] = vb:column{spacing=2}
  end

  -- Split devices into columns sequentially
  local device_index = 1

  for col = 1, num_columns do
    for row = 1, devices_per_column do
      if device_index > num_devices then break end
      local plugin = plugins[device_index]
      local checkbox_id = "checkbox_" .. title .. "_" .. tostring(device_index) .. "_" .. tostring(math.random(1000000))
      local checkbox = vb:checkbox{value=false, id=checkbox_id}
      checkboxes[#checkboxes + 1] = {checkbox=checkbox, path=plugin.path, name=plugin.name}
      local plugin_row = vb:row{spacing=4,checkbox,vb:text{text=plugin.name}}
      columns[col]:add_child(plugin_row)
      device_index = device_index + 1
    end
  end

  local column_container = vb:row{spacing=20}
  for _, column in ipairs(columns) do
    column_container:add_child(column)
  end

  return vb:column{
    vb:horizontal_aligner{mode="center",column_container}}
end

function updateDeviceList()
  checkboxes = {}
  deviceReadableNames = {}
  local track_index = renoise.song().selected_track_index
  local available_devices = renoise.song().tracks[track_index].available_devices
  local available_device_infos = renoise.song().tracks[track_index].available_device_infos

  local pluginReadableNames = {}
  for i, plugin_info in ipairs(available_device_infos) do
    pluginReadableNames[available_devices[i]] = plugin_info.short_name
  end

  local device_list_content

  if current_device_type == "Native" then
    -- Collect Native devices
    local native_devices = {}
    local hidden_devices = {
      {name = "(Hidden) Chorus", path = "Audio/Effects/Native/Chorus"},
      {name = "(Hidden) Comb Filter", path = "Audio/Effects/Native/Comb Filter"},
      {name = "(Hidden) Distortion", path = "Audio/Effects/Native/Distortion"},
      {name = "(Hidden) Filter", path = "Audio/Effects/Native/Filter"},
      {name = "(Hidden) Filter 2", path = "Audio/Effects/Native/Filter 2"},
      {name = "(Hidden) Filter 3", path = "Audio/Effects/Native/Filter 3"},
      {name = "(Hidden) Flanger", path = "Audio/Effects/Native/Flanger"},
      {name = "(Hidden) Gate", path = "Audio/Effects/Native/Gate"},
      {name = "(Hidden) LofiMat", path = "Audio/Effects/Native/LofiMat"},
      {name = "(Hidden) mpReverb", path = "Audio/Effects/Native/mpReverb"},
      {name = "(Hidden) Phaser", path = "Audio/Effects/Native/Phaser"},
      {name = "(Hidden) RingMod", path = "Audio/Effects/Native/RingMod"},
      {name = "(Hidden) Scream Filter", path = "Audio/Effects/Native/Scream Filter"},
      {name = "(Hidden) Shaper", path = "Audio/Effects/Native/Shaper"},
      {name = "(Hidden) Stutter", path = "Audio/Effects/Native/Stutter"}}

    for i, device_path in ipairs(available_devices) do
      if device_path:find("Native/") then
        local device_name = device_path:match("([^/]+)$")
        table.insert(native_devices, {name = device_name, path = device_path})
      end
    end

    table.sort(native_devices, function(a, b)
      return a.name:lower() < b.name:lower()
    end)

    for _, hidden_device in ipairs(hidden_devices) do
      table.insert(native_devices, hidden_device)
    end

    device_list_content = createDeviceList(native_devices, "Native Devices")

  elseif current_device_type == "VST" then
    local vst_devices = {}
    for i, device_path in ipairs(available_devices) do
      if device_path:find("VST") and not device_path:find("VST3") then
        local device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
        table.insert(vst_devices, {name = device_name, path = device_path})
      end
    end
    device_list_content = createDeviceList(vst_devices, "VST Devices")

  elseif current_device_type == "VST3" then
    local vst3_devices = {}
    for i, device_path in ipairs(available_devices) do
      if device_path:find("VST3") then
        local device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
        table.insert(vst3_devices, {name = device_name, path = device_path})
      end
    end

    table.sort(vst3_devices, function(a, b)
      return a.name:lower() < b.name:lower()
    end)

    device_list_content = createDeviceList(vst3_devices, "VST3 Devices")

  elseif current_device_type == "AudioUnit" then
    local au_devices = {}
    for i, device_path in ipairs(available_devices) do
      if device_path:find("AU") then
        local device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
        table.insert(au_devices, {name = device_name, path = device_path})
      end
    end

    table.sort(au_devices, function(a, b)
      return a.name:lower() < b.name:lower()
    end)

    device_list_content = createDeviceList(au_devices, "AudioUnit Devices")

  elseif current_device_type == "LADSPA" then
    local ladspa_devices = {}
    for i, device_path in ipairs(available_devices) do
      if device_path:find("LADSPA") then
        local device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
        device_name = device_name:match("([^:]+)$")
        device_name = device_name:match("([^/]+)$")
        table.insert(ladspa_devices, {name = device_name, path = device_path})
      end
    end

    -- Sort the LADSPA devices by name
    table.sort(ladspa_devices, function(a, b)
      return a.name:lower() < b.name:lower()
    end)

    device_list_content = createDeviceList(ladspa_devices, "LADSPA Devices")

  elseif current_device_type == "DSSI" then
    local dssi_devices = {}
    for i, device_path in ipairs(available_devices) do
      if device_path:find("DSSI") then
        local device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
        device_name = device_name:match("([^:]+)$")  -- Extract after the last colon
        table.insert(dssi_devices, {name = device_name, path = device_path})
      end
    end

    table.sort(dssi_devices, function(a, b)
      return a.name:lower() < b.name:lower()
    end)

    device_list_content = createDeviceList(dssi_devices, "DSSI Devices")
  end

  if current_device_list_content then
    device_list_view:remove_child(current_device_list_content)
  end

  device_list_view:add_child(device_list_content)
  current_device_list_content = device_list_content
end

function showDeviceListDialog()
  current_device_list_content = nil

  vb = renoise.ViewBuilder()
  checkboxes = {}
  local track_index = renoise.song().selected_track_index

  local dropdown = vb:popup{
    items = device_types,
    value = 1,
    notifier = function(index)
      current_device_type = device_types[index]
      updateDeviceList()
    end}

  local random_selection_controls = vb:row{
    vb:text{text = "Random Select:", width = 80, style="strong",font="bold"},
    vb:slider{
      id = "random_select_slider",
      min = 0,
      max = 100,
      value = 0,
      width = 200,
      notifier = function(value)
        random_select_percentage = value
        updateRandomSelection()
      end},
    vb:text{id="random_percentage_text",text="None",width=40,
      align="center"},
    vb:button{text="All",width=20,
      notifier = function()
        for _, cb_info in ipairs(checkboxes) do
          cb_info.checkbox.value = true
        end
        vb.views["random_select_slider"].value = 100
        vb.views["random_percentage_text"].text = "All"
      end},
    vb:button{text="None",width=20,
      notifier = function()
        resetSelection()
        vb.views["random_select_slider"].value = 0
        vb.views["random_percentage_text"].text = "None"
      end}}

  local button_height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
  local action_buttons = vb:column{
    vb:horizontal_aligner{width="100%",
      vb:button{text="Load Device(s)",width=60,
        notifier = function()
          if loadSelectedDevices() then
            renoise.app():show_status("Devices loaded.")
          end
        end
      },
      vb:button{text="Add Device(s) as Shortcut(s) & MidiMappings",width=140,
        notifier = addAsShortcut},
      vb:button{text="Cancel",width=30,
        notifier = function() custom_dialog:close() end}}}
  device_list_view = vb:column{}
  dialog_content_view = vb:column{margin = 10,spacing = 5,device_list_view,}

  -- Wrap in a column to include the dropdown
  local dialog_content = vb:column{
    vb:horizontal_aligner{
      vb:text{text = "Device Type: ", font="bold",style="strong"},
      dropdown,action_buttons,random_selection_controls},dialog_content_view}

  custom_dialog = renoise.app():show_custom_dialog("Load Device(s)", dialog_content, my_Devicekeyhandler_func)

  updateDeviceList()
end

function my_Devicekeyhandler_func(custom_dialog, key)
  local closer = preferences.pakettiDialogClose.value
  if key.modifiers == "" and key.name == closer then
    custom_dialog:close()
    custom_dialog = nil
    return nil
  else
    return key
  end
end

loadFromPreferencesFile()

