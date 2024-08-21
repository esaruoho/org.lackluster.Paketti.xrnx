local vb = renoise.ViewBuilder()
local checkboxes = {}
local deviceReadableNames = { VST3 = {}, AU = {} }
local addedKeyBindings = {}
local preferencesFile = renoise.tool().bundle_path .. "preferences_deviceLoaders.xml"

function vst3AddAsShortcut()
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local keyBindingName = "Global:Track Devices:Load Device (VST3/AU) " .. cb_info.name
      local midiMappingName = "Track Devices:Paketti:Load Device (VST3/AU) " .. cb_info.name

      if not addedKeyBindings[keyBindingName] then
        print("Adding shortcut for: " .. cb_info.name)

        local success, err = pcall(function()
          renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadvst(cb_info.path) end}
          renoise.tool():add_midi_mapping{name=midiMappingName, invoke=function(message) if message:is_trigger() then  loadvst(cb_info.path) end end}
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

-- Initialize preferences file
initializePreferencesFile()

function createScrollableList(plugins, title)
    table.sort(plugins, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    local columns = { vb:column {}, vb:column {} }
    local num_plugins = #plugins
    local num_columns = 2

    if num_plugins > 2 * 20 then  -- Assuming each column can hold 15 plugins
        num_columns = math.ceil(num_plugins / 20)
        for i = 3, num_columns do
            table.insert(columns, vb:column {})
        end
    end

    local plugins_per_column = math.ceil(num_plugins / num_columns)

    for i, plugin in ipairs(plugins) do
        local column_index = math.floor((i - 1) / plugins_per_column) + 1
        local checkbox_id = "checkbox_" .. title .. "_" .. tostring(i) .. "_" .. tostring(math.random(1000000))
        local checkbox = vb:checkbox { value = false, id = checkbox_id }
        checkboxes[#checkboxes + 1] = { checkbox = checkbox, path = plugin.path, name = plugin.name }
        local plugin_row = vb:row {
            checkbox,
            vb:text { text = plugin.name }
        }

        columns[column_index]:add_child(plugin_row)
    end

    local column_container = vb:row { spacing = 20 }
    for _, column in ipairs(columns) do
        column_container:add_child(column)
    end

    return vb:column {
        vb:text { text = title, font = "bold", height = 20 },
        column_container
    }
end

function vst3LoadSelectedDevices()
    local track_index = renoise.song().selected_track_index
    for _, cb_info in ipairs(checkboxes) do
        if cb_info.checkbox.value then
            local pluginPath = cb_info.path
            print("Loading Device:", pluginPath)
            loadvst(pluginPath)
        end
    end
end

function vst3ResetSelection()
    for _, cb_info in ipairs(checkboxes) do
        cb_info.checkbox.value = false
    end
end

function vst3RandomizeSelection()
    vst3ResetSelection()  -- Clear previous selections

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

function vst3ShowPluginListDialog()
    checkboxes = {}  -- Reinitialize the checkboxes table to avoid carrying over previous states
    local track_index = renoise.song().selected_track_index
    local available_plugins = renoise.song().tracks[track_index].available_devices
    local available_device_infos = renoise.song().tracks[track_index].available_device_infos
    deviceReadableNames = { VST3 = {}, AU = {} }

    local pluginReadableNames = {}
    for i, plugin_info in ipairs(available_device_infos) do
        pluginReadableNames[available_plugins[i]] = plugin_info.short_name
    end

    for i, device_path in ipairs(available_plugins) do
        if device_path:find("VST3") then
            local device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
            table.insert(deviceReadableNames.VST3, { name = device_name, path = device_path })
        elseif device_path:find("AU") then
            local device_name = pluginReadableNames[device_path] or device_path:match("([^/]+)$")
            table.insert(deviceReadableNames.AU, { name = device_name, path = device_path })
        end
    end

    local custom_dialog

    local button_height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
    local button_spacing = renoise.ViewBuilder.DEFAULT_DIALOG_SPACING
    local action_buttons = vb:column {
        uniform = true,
        width = "100%",
   
        vb:button {
            text = "Add Device(s) as Shortcut(s) & MidiMappings",
            height = button_height,
            width="100%",
            notifier = vst3AddAsShortcut
        },
        vb:horizontal_aligner { width="100%",
        vb:button {
            text = "Randomize Selection",
            height = button_height,
            width="33%",
            notifier = function()
                vst3RandomizeSelection()
            end
        },
        vb:button { text="Select All",
        height=button_height,
        width="33%",
        notifier=function()
        
    for _, cb_info in ipairs(checkboxes) do
        cb_info.checkbox.value = true
    end
end},
            vb:button {
            text = "Reset Selection",
            height = button_height,
            width="34%",
            notifier = function()
                vst3ResetSelection()
            end
        }},
     vb:horizontal_aligner {
            vb:button {
                text = "Load Device(s)",
                width = "33%",
                height = button_height,
                notifier = function()
                    vst3LoadSelectedDevices()
                end
            },
            vb:button {
                text = "Load Device(s) & Close",
                width = "33%",
                height = button_height,
                notifier = function()
                    vst3LoadSelectedDevices()
                    custom_dialog:close()
                end
            },
             
        vb:button {
            text = "Cancel",
            height = button_height,
            width="34%",
            notifier = function()
                custom_dialog:close()
            end
        }},   
    }

    local dialog_content = vb:column {
        margin = 10,
        spacing = 5,
        createScrollableList(deviceReadableNames.AU, "AudioUnit"),
        createScrollableList(deviceReadableNames.VST3, "VST3"),
        action_buttons
    }

    custom_dialog = renoise.app():show_custom_dialog("Load VST3/AU Device(s)", dialog_content)
end

