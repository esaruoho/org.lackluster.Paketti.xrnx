-- Declare variables at the beginning of the script to ensure they're available globally
local vb = renoise.ViewBuilder()
local checkboxes = {}
local deviceReadableNames = { VST = {}, VST3 = {}, AU = {} }
local addedKeyBindings = {}
local preferencesFile = renoise.tool().bundle_path .. "preferences_pluginLoaders.xml"

-- Initialize LoaderPreferences.xml file if it does not exist
local function initializePreferencesFile()
  local file, err = io.open(preferencesFile, "r")
  if not file then
    file, err = io.open(preferencesFile, "w")
    if not file then
      print("Error creating preferences file: " .. err)
      return
    end
    file:write("<preferencesPluginLoaders>\n</preferencesPluginLoaders>\n")
    file:close()
  else
    file:close()
  end
end

-- Function to save keybinding and MIDI mapping to LoaderPreferences.xml
local function saveToPreferencesFile(keyBindingName, midiMappingName, path)
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

-- Function to load keybindings and MIDI mappings from LoaderPreferences.xml
local function loadFromPreferencesFile()
  local file, err = io.open(preferencesFile, "r")
  if not file then
    print("Error opening preferences file: " .. err)
    return
  end

  local content = file:read("*all")
  file:close()

  -- Parse the XML content to add keybindings and MIDI mappings
  for keyBindingName, path in content:gmatch('<KeyBinding name="(.-)">.-<Path>(.-)</Path>.-</KeyBinding>') do
    renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadPlugin(path) end}
    addedKeyBindings[keyBindingName] = true
  end

  for midiMappingName, path in content:gmatch('<MIDIMapping name="(.-)">.-<Path>(.-)</Path>.-</MIDIMapping>') do
    renoise.tool():add_midi_mapping{name=midiMappingName, invoke=function() loadPlugin(path) end}
    addedKeyBindings[midiMappingName] = true
  end
end

-- Function to load the selected plugin into a new instrument and make the external editor visible
function loadPlugin(pluginPath)
  local selected_index = renoise.song().selected_instrument_index
  renoise.song():insert_instrument_at(selected_index + 1)
  renoise.song().selected_instrument_index = selected_index + 1
  local new_instrument = renoise.song().selected_instrument
  new_instrument.plugin_properties:load_plugin(pluginPath)
  if new_instrument.plugin_properties.plugin_device and new_instrument.plugin_properties.plugin_device.external_editor_available then
    new_instrument.plugin_properties.plugin_device.external_editor_visible = true
  end
  openVisiblePagesToFitParameters()  
end

-- Function to add a plugin as a shortcut
local function addAsShortcut()
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local plugin_type = ""
      if cb_info.path:find("/VST/") then
        plugin_type = " (VST)"
      elseif cb_info.path:find("/VST3/") then
        plugin_type = " (VST3)"
      elseif cb_info.path:find("/AU/") then
        plugin_type = " (AU)"
      end

      local keyBindingName="Global:Paketti:Load Plugin" .. plugin_type .. " " .. cb_info.name
      local midiMappingName="Tools:Paketti:Load Plugin" .. plugin_type .. " " .. cb_info.name

      -- Debug: Print the keybinding name
      print("Attempting to add keybinding:", keyBindingName)

      -- Check if we've already attempted to add this keybinding
      if not addedKeyBindings[keyBindingName] then
        print("Adding shortcut for:", cb_info.name .. plugin_type)

        -- Attempt to add the keybinding, using pcall to catch any errors gracefully
        local success, err = pcall(function()
          renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadPlugin(cb_info.path) end}
          renoise.tool():add_midi_mapping{name=midiMappingName, invoke=function() loadPlugin(cb_info.path) end}
        end)

        -- Check if the keybinding was added successfully
        if success then
          addedKeyBindings[keyBindingName] = true
          saveToPreferencesFile(keyBindingName, midiMappingName, cb_info.path)
        else
          print("Could not add keybinding for", cb_info.name, "Error:", err)
        end
      else
        print("Keybinding for", cb_info.name .. plugin_type, "already added.")
      end
    end
  end
  
  renoise.app():show_status("Plugins added. Open Settings -> Keys, search for 'Load Plugin' or Midi Mappings and search for 'Load Plugin'")
end

-- Function to create a scrollable list of plugins
local function createScrollableList(plugins, title)
  -- Sort the plugins alphabetically, case-insensitive
  table.sort(plugins, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  local columns = { vb:column {}, vb:column {} }
  local num_plugins = #plugins
  local num_columns = 2

  if num_plugins > 2 * 15 then  -- Assuming each column can hold 15 plugins
    num_columns = math.ceil(num_plugins / 15)
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
    local plugin_row = vb:row {checkbox, vb:text {text=plugin.name}}

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

-- Function to load the selected plugins
local function loadSelectedPlugins()
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local pluginPath = cb_info.path
      print("Loading Plugin:", pluginPath)
      loadPlugin(pluginPath)
    end
  end
end

-- Function to reset the selection
local function resetSelection()
  for _, cb_info in ipairs(checkboxes) do
    cb_info.checkbox.value = false
  end
end

-- Function to show the plugin list dialog
local function showPluginListDialog()
  checkboxes = {}  -- Reinitialize the checkboxes table to avoid carrying over previous states
  local available_plugins = renoise.song().selected_instrument.plugin_properties.available_plugins
  local available_plugin_infos = renoise.song().selected_instrument.plugin_properties.available_plugin_infos
  deviceReadableNames = { VST = {}, VST3 = {}, AU = {} }

  -- Debug: Print the available plugins
  print("Available plugins:")
  rprint(available_plugins)

  for i, plugin_path in ipairs(available_plugins) do
    local plugin_info = available_plugin_infos[i]
    if plugin_info then
      local short_name = plugin_info.short_name or "Unknown"
      print(string.format("Processing plugin: %s, path: %s", short_name, plugin_path))
      if plugin_path:find("/VST/") then
        table.insert(deviceReadableNames.VST, { name = short_name, path = plugin_path })
      elseif plugin_path:find("/VST3/") then
        table.insert(deviceReadableNames.VST3, { name = short_name, path = plugin_path })
      elseif plugin_path:find("/AU/") then
        table.insert(deviceReadableNames.AU, { name = short_name, path = plugin_path })
      end
    else
      print(string.format("Skipping plugin at index %d due to missing info", i))
    end
  end

  local custom_dialog

  -- Define the action buttons and their behaviors
  local button_height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
  local button_spacing = renoise.ViewBuilder.DEFAULT_DIALOG_SPACING
  local action_buttons = vb:column {
    uniform = true,
    width = "100%",
    vb:horizontal_aligner {
      vb:button {
        text = "Load Plugin(s)",
        width = "50%",
        height = button_height,
        notifier = function()
          loadSelectedPlugins()
        end
      },
      vb:button {
        text="Load Plugin(s) & Close",
        width="50%",
        height=button_height,
        notifier=function()
          loadSelectedPlugins()
          custom_dialog:close()
        end
      }
    },
    vb:button{text="Add Plugin(s) as Shortcut(s)",height=button_height,notifier=addAsShortcut},
    vb:button{text="Reset Selection", height=button_height, notifier=function() resetSelection() end},
    vb:button{text="Cancel", height=button_height, notifier=function() custom_dialog:close() end}
  }

  -- Check if there are any plugins available, if not, show a message
  local dialog_content
  if #deviceReadableNames.AU == 0 and #deviceReadableNames.VST == 0 and #deviceReadableNames.VST3 == 0 then
    dialog_content = vb:column {
      margin = 10,
      spacing = 5,
      vb:text { text = "No AudioUnit Plugins found on this computer.", font = "bold", height = 20 },
      vb:text { text = "No VST Plugins found on this computer.", font = "bold", height = 20 },
      vb:text { text = "No VST3 Plugins found on this computer.", font = "bold", height = 20 },
      action_buttons
    }
  else
    dialog_content = vb:column {
      margin = 10,
      spacing = 5,
      createScrollableList(deviceReadableNames.AU, "AudioUnit"),
      createScrollableList(deviceReadableNames.VST, "VST"),
      createScrollableList(deviceReadableNames.VST3, "VST3"),
      action_buttons
    }
  end

  custom_dialog = renoise.app():show_custom_dialog("Load Plugin(s)", dialog_content)
end

-- Initialize preferences file and load keybindings and MIDI mappings
initializePreferencesFile()
loadFromPreferencesFile()

-- Register the menu entry to show the plugin list dialog
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Load AU/VST/VST3 Plugins Dialog",invoke=function() showPluginListDialog() end}

