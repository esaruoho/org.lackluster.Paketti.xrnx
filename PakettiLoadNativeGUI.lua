local vb -- ViewBuilder will be initialized within the function scope

local addedKeyBindings = {}
local preferencesFile = renoise.tool().bundle_path .. "preferences_deviceLoaders.xml"
local checkboxes = {}  -- Initialize the checkboxes table
local deviceReadableNames = {}  -- Initialize the deviceReadableNames table

-- Function to add keybindings and MIDI mappings
function addAsShortcut()
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local keyBindingName = "Global:Track Devices:Load Device (Native) " .. cb_info.name
      local midiMappingName = "Tools:Track Devices:Load Device (Native) " .. cb_info.name

      -- Check if we've already attempted to add this keybinding
      if not addedKeyBindings[keyBindingName] then
        print("Adding shortcut for: " .. cb_info.name)

        -- Attempt to add the keybinding, using pcall to catch any errors gracefully
        local success, err = pcall(function()
          renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadnative(cb_info.path) end}
          renoise.tool():add_midi_mapping{name=midiMappingName, invoke=function() loadnative(cb_info.path) end}
        end)

        -- Check if the keybinding was added successfully
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

-- Function to save keybinding and MIDI mapping to PreferencesLoaders.xml
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

-- Function to load keybindings and MIDI mappings from PreferencesLoaders.xml
function loadFromPreferencesFile()
  local file, err = io.open(preferencesFile, "r")
  if not file then
    print("Error opening preferences file: " .. err)
    return
  end

  local content = file:read("*all")
  file:close()

  -- Parse the XML content to add keybindings and MIDI mappings
  for keyBindingName, path in content:gmatch('<KeyBinding name="(.-)">.-<Path>(.-)</Path>.-</KeyBinding>') do
    renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadnative(path) end}
  end

  for midiMappingName, path in content:gmatch('<MIDIMapping name="(.-)">.-<Path>(.-)</Path>.-</MIDIMapping>') do
    renoise.tool():add_midi_mapping{name=midiMappingName, invoke=function() loadnative(path) end}
  end
end

-- Ensure PreferencesLoaders.xml exists and is properly formatted
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

-- Initialize preferences file and load keybindings and MIDI mappings
initializePreferencesFile()
loadFromPreferencesFile()

function create_scrollable_native_list(vb)
    local left_column = vb:column {}
    local right_column = vb:column {}
    local num_devices = #deviceReadableNames
    local mid_point = math.ceil(num_devices / 2)

    for i, device in ipairs(deviceReadableNames) do
        local checkbox = vb:checkbox { value = false, id = "checkbox_native_" .. tostring(i) }
        checkboxes[#checkboxes + 1] = { checkbox = checkbox, path = device.path, name = device.name }
        local device_row = vb:row {checkbox, vb:text { text = device.name }}

        if i <= mid_point then
            left_column:add_child(device_row)
        else
            right_column:add_child(device_row)
        end
    end

    return vb:horizontal_aligner {mode = "left",
        spacing = 20,
        left_column,
        right_column}
end

function loadSelectedNativeDevices()
    local track_index = renoise.song().selected_track_index
    local track_type = renoise.song().tracks[track_index].type
    local notAllowedDevices = {}

    if track_type == renoise.Track.TRACK_TYPE_MASTER then
        notAllowedDevices = notAllowedInMaster
    elseif track_type == renoise.Track.TRACK_TYPE_SEND then
        notAllowedDevices = notAllowedInSend
    elseif track_type == renoise.Track.TRACK_TYPE_GROUP then
        notAllowedDevices = notAllowedInGroup
    end

    for _, cb_info in ipairs(checkboxes) do
        if cb_info.checkbox.value then
            local canLoad = not notAllowedDevices[cb_info.name]
            if canLoad then
                local pluginPath = cb_info.path
                print("Loading Native Device:", pluginPath)
                loadnative(pluginPath)
            else
                print("Device not allowed on this track type:", cb_info.name)
            end
        end
    end
end

function resetSelection()
    for _, cb_info in ipairs(checkboxes) do
        cb_info.checkbox.value = false
    end
end

function randomizeSelection()
    resetSelection()  -- Clear previous selections

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

function PakettiShowDeviceListDialog()
    vb = renoise.ViewBuilder()  -- Create a new instance of ViewBuilder
    checkboxes = {}  -- Reinitialize the checkboxes table to avoid carrying over previous states
    local track_index = renoise.song().selected_track_index
    local available_devices = renoise.song().tracks[track_index].available_devices
    deviceReadableNames = {}

    for i, device_path in ipairs(available_devices) do
        if device_path:find("Native/") then
            local device_name = device_path:match("([^/]+)$")
            deviceReadableNames[#deviceReadableNames + 1] = {name = device_name, path = device_path}
        end
    end

    table.sort(deviceReadableNames, function(a, b) return a.name < b.name end)

    local custom_dialog

    -- Define the action buttons and their behaviors
    local button_height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
    local button_spacing = renoise.ViewBuilder.DEFAULT_DIALOG_SPACING
    local action_buttons = vb:column {
        uniform = true,
        width = "100%",
        vb:horizontal_aligner {vb:button {text = "Load Device(s)",
                width = "50%",
                height = button_height,
                notifier = function()
                    loadSelectedNativeDevices()
                end},
            vb:button {text = "Load Device(s) & Close",
                width = "50%",
                height = button_height,
                notifier = function()
                    loadSelectedNativeDevices()
                    custom_dialog:close()
                end}},
        vb:button {text = "Add Device(s) as Shortcut(s)",
            height = button_height,
            notifier = addAsShortcut},
        vb:button {text = "Randomize Selection",
            height = button_height,
            notifier = randomizeSelection},
        vb:button {text = "Reset Selection",
            height = button_height,
            notifier = resetSelection},
        vb:button {text = "Cancel",
            height = button_height,
            notifier = function()
                custom_dialog:close()
            end}}

    local dialog_content = vb:column {
        margin = 10,
        spacing = 5,
        create_scrollable_native_list(vb),
        action_buttons}

    custom_dialog = renoise.app():show_custom_dialog("Load Native Device(s)", dialog_content)
end

