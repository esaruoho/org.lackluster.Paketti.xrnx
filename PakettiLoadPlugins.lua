-- Plugin Loader Dialog with Randomize Slider and Separate Dropdowns

local vb -- ViewBuilder will be initialized within the function scope
local checkboxes = {}
local deviceReadableNames = {}
local addedKeyBindings = {}
local preferencesFile = renoise.tool().bundle_path .. "preferences_pluginLoaders.xml"
local current_plugin_type = "VST"
local plugin_types = { "VST", "VST3", "AU", "LADSPA", "DSSI" }
local plugin_type_display_names = {
  VST = "VST",
  VST3 = "VST3",
  AU = "AudioUnit",
  LADSPA = "LADSPA",
  DSSI = "DSSI"
}
local custom_dialog = nil  -- Reference to the custom dialog
local plugin_list_view = nil
local current_plugin_list_content = nil  -- Variable to keep track of current content

-- Variable for random selection percentage
local random_select_percentage = 0  -- Initialized to 0%

-- Initialize Preferences File
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

-- Save to Preferences File
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

-- Load from Preferences File
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
    renoise.tool():add_keybinding{
      name = keyBindingName,
      invoke = function() loadPlugin(path) end
    }
    addedKeyBindings[keyBindingName] = true
  end

  for midiMappingName, path in content:gmatch('<MIDIMapping name="(.-)">.-<Path>(.-)</Path>.-</MIDIMapping>') do
    renoise.tool():add_midi_mapping{
      name = midiMappingName,
      invoke = function(message)
        if message:is_trigger() then
          loadPlugin(path)
        end
      end
    }
    addedKeyBindings[midiMappingName] = true
  end
end

-- Load Plugin Function
function loadPlugin(pluginPath)
  local selected_index = renoise.song().selected_instrument_index
local currentView = renoise.app().window.active_middle_frame
  renoise.song():insert_instrument_at(renoise.song().selected_instrument_index + 1)
  renoise.song().selected_instrument_index = selected_index + 1

if currentView == renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR
then 
renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR
renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR
else
renoise.app().window.active_middle_frame = currentView
end
  local new_instrument = renoise.song().selected_instrument
  new_instrument.plugin_properties:load_plugin(pluginPath)
  if new_instrument.plugin_properties.plugin_device and new_instrument.plugin_properties.plugin_device.external_editor_available then
    new_instrument.plugin_properties.plugin_device.external_editor_visible = true
  end
  -- openVisiblePagesToFitParameters()  -- Uncomment if you have this function defined elsewhere

end

-- Check if any plugins are selected
local function isAnyPluginSelected()
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      return true
    end
  end
  return false
end

-- Load Selected Plugins
local function loadSelectedPlugins()
  if not isAnyPluginSelected() then
    renoise.app():show_status("Nothing was selected, doing nothing.")
    return false  -- Indicate that no plugins were loaded
  end

  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local pluginPath = cb_info.path
      print("Loading Plugin:", pluginPath)
      loadPlugin(pluginPath)
    end
  end
  return true  -- Indicate that plugins were loaded
end

-- Add as Shortcut
local function addAsShortcut()
  if not isAnyPluginSelected() then
    renoise.app():show_status("Nothing was selected, doing nothing.")
    return
  end

  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local plugin_type = ""
      if cb_info.path:find("/VST/") then
        plugin_type = " (VST)"
      elseif cb_info.path:find("/VST3/") then
        plugin_type = " (VST3)"
      elseif cb_info.path:find("/AU/") then
        plugin_type = " (AU)"
      elseif cb_info.path:find("/LADSPA/") then
        plugin_type = " (LADSPA)"
      elseif cb_info.path:find("/DSSI/") then
        plugin_type = " (DSSI)"
      end

      local keyBindingName = "Global:Paketti:Load Plugin" .. plugin_type .. " " .. cb_info.name
      local midiMappingName = "Paketti:Load Plugin" .. plugin_type .. " " .. cb_info.name

      -- Check if we've already attempted to add this keybinding
      if not addedKeyBindings[keyBindingName] then
        -- Attempt to add the keybinding, using pcall to catch any errors gracefully
        local success, err = pcall(function()
          renoise.tool():add_keybinding{
            name = keyBindingName,
            invoke = function() loadPlugin(cb_info.path) end
          }
          renoise.tool():add_midi_mapping{
            name = midiMappingName,
            invoke = function(message)
              if message:is_trigger() then
                loadPlugin(cb_info.path)
              end
            end
          }
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

-- Reset Selection
local function resetSelection()
  for _, cb_info in ipairs(checkboxes) do
    cb_info.checkbox.value = false
  end
end

-- Update Random Selection based on Slider
local function updateRandomSelection()
  if #checkboxes == 0 then
    renoise.app():show_status("Nothing to randomize from.")
    return
  end

  resetSelection()  -- Clear previous selections

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

  -- Shuffle indices
  for i = numDevices, 2, -1 do
    local j = math.random(1, i)
    indices[i], indices[j] = indices[j], indices[i]
  end

  -- Select the first numSelections devices
  for i = 1, numSelections do
    local idx = indices[i]
    checkboxes[idx].checkbox.value = true
  end
end

-- Create Plugin List
local function createPluginList(plugins, title)
  if #plugins == 0 then
    return vb:column{
      vb:text{text=title, font="bold", height=20},
      vb:text{text="No Plugins found for this type.", font="italic", height=20}
    }
  end

  -- Sort the plugins alphabetically, case-insensitive
  table.sort(plugins, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  -- Determine number of columns based on plugins per column
  local num_plugins = #plugins
  local plugins_per_column = 28
  local num_columns = math.ceil(num_plugins / plugins_per_column)

  local columns = {}
  for i = 1, num_columns do
    columns[i] = vb:column{spacing=2}
  end

  -- Split plugins into columns sequentially
  local plugin_index = 1

  for col = 1, num_columns do
    for row = 1, plugins_per_column do
      if plugin_index > num_plugins then break end
      local plugin = plugins[plugin_index]
      local checkbox_id = "checkbox_" .. title .. "_" .. tostring(plugin_index) .. "_" .. tostring(math.random(1000000))
      local checkbox = vb:checkbox{value=false, id=checkbox_id}
      checkboxes[#checkboxes + 1] = {checkbox=checkbox, path=plugin.path, name=plugin.name}
      local plugin_row = vb:row{
        spacing=4,
        checkbox,
        vb:text{text=plugin.name}
      }
      columns[col]:add_child(plugin_row)
      plugin_index = plugin_index + 1
    end
  end

  local column_container = vb:row{spacing=20}
  for _, column in ipairs(columns) do
    column_container:add_child(column)
  end

  return vb:column{
    vb:text{text=title, font="bold", height=20},
    vb:horizontal_aligner{
      mode = "center",
      column_container
    }
  }
end

-- Update Plugin List
local function updatePluginList()
  checkboxes = {}  -- Clear previous checkboxes

  local available_plugins = renoise.song().selected_instrument.plugin_properties.available_plugins
  local available_plugin_infos = renoise.song().selected_instrument.plugin_properties.available_plugin_infos

  local plugins = {}

  for i, plugin_path in ipairs(available_plugins) do
    local plugin_info = available_plugin_infos[i]
    if plugin_info then
      local short_name = plugin_info.short_name or "Unknown"
      if plugin_path:find("/" .. current_plugin_type .. "/") then
        table.insert(plugins, {name = short_name, path = plugin_path})
      end
    end
  end

  local display_title = plugin_type_display_names[current_plugin_type] .. " Plugins"
  local plugin_list_content = createPluginList(plugins, display_title)

  -- Remove existing content from plugin_list_view
  if current_plugin_list_content then
    plugin_list_view:remove_child(current_plugin_list_content)
  end

  -- Add new content
  plugin_list_view:add_child(plugin_list_content)
  current_plugin_list_content = plugin_list_content
end

-- Show Plugin List Dialog
function showPluginListDialog()
  -- Close the dialog if it's already open
  if custom_dialog and custom_dialog.visible then
    custom_dialog:close()
    custom_dialog = nil
    current_plugin_list_content = nil  -- Reset current content
    return
  end

  vb = renoise.ViewBuilder()
  checkboxes = {}
  deviceReadableNames = {}
  random_select_percentage = 0  -- Reset the random selection percentage
  current_plugin_list_content = nil  -- Reset current content

  -- Dropdown Menu
  local dropdown_items = {}
  for _, plugin_type in ipairs(plugin_types) do
    table.insert(dropdown_items, plugin_type_display_names[plugin_type])
  end

  local dropdown = vb:popup{
    items = dropdown_items,
    value = 1,
    notifier = function(index)
      current_plugin_type = plugin_types[index]
      updatePluginList()
    end
  }

  -- Random Selection Slider
  local random_selection_controls = vb:row{
    spacing = 10,
    vb:text{text = "Random Select:", width = 100},
    vb:slider{
      id = "random_select_slider",
      min = 0,
      max = 100,
      value = 0,
      width = 200,
      notifier = function(value)
        random_select_percentage = value
        updateRandomSelection()
      end
    },
    vb:text{
      id = "random_percentage_text",
      text = "None",
      width = 40,
      align = "center"
    }
  }

  -- Action Buttons
  local button_height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
  local action_buttons = vb:column{
    uniform = true,
    width = "100%",
    vb:button{
      text = "Add Plugin(s) as Shortcut(s) & MidiMappings",
      height = button_height,
      width = "100%",
      notifier = addAsShortcut
    },
    vb:horizontal_aligner{
      width = "100%",
      vb:button{
        text = "Select All",
        height = button_height,
        width = "50%",
        notifier = function()
          for _, cb_info in ipairs(checkboxes) do
            cb_info.checkbox.value = true
          end
          vb.views["random_select_slider"].value = 100
          vb.views["random_percentage_text"].text = "All"
        end
      },
      vb:button{
        text = "Reset Selection",
        height = button_height,
        width = "50%",
        notifier = function()
          resetSelection()
          vb.views["random_select_slider"].value = 0
          vb.views["random_percentage_text"].text = "None"
        end
      }
    },
    vb:horizontal_aligner{
      width = "100%",
      vb:button{
        text = "Load Plugin(s)",
        width = "33%",
        height = button_height,
        notifier = function()
          if loadSelectedPlugins() then
            renoise.app():show_status("Plugins loaded.")
          else
            renoise.app():show_status("Nothing was selected, doing nothing.")
          end
        end
      },
      vb:button{
        text = "Load Plugin(s) & Close",
        width = "33%",
        height = button_height,
        notifier = function()
          if loadSelectedPlugins() then
            custom_dialog:close()
            custom_dialog = nil
            current_plugin_list_content = nil
          else
            renoise.app():show_status("Nothing was selected, doing nothing.")
          end
        end
      },
      vb:button{
        text = "Cancel",
        height = button_height,
        width = "34%",
        notifier = function()
          custom_dialog:close()
          custom_dialog = nil
          current_plugin_list_content = nil
        end
      }
    }
  }

  -- Placeholder for Plugin List
  plugin_list_view = vb:column{}

  -- Main Dialog Content
  local dialog_content_view = vb:column{
    margin = 10,
    spacing = 5,
    plugin_list_view,
    random_selection_controls,
    action_buttons
  }

  -- Wrap in a column to include the dropdown
  local dialog_content = vb:column{
    vb:horizontal_aligner{
      mode = "center",
      vb:text{text = "Select Plugin Type: "},
      dropdown
    },
    dialog_content_view
  }

  custom_dialog = renoise.app():show_custom_dialog("Load Plugin(s)", dialog_content, my_pluginLoaderkeyhandlerfunc)

  -- Initial Update
  updatePluginList()
end

function my_pluginLoaderkeyhandlerfunc(dialog, key)

local closer = preferences.pakettiDialogClose.value
  if key.modifiers == "" and key.name == closer then
    custom_dialog:close()
    custom_dialog = nil
    current_plugin_list_content = nil  -- Reset current content
    return nil
else
return key
end
end

-- Initialize preferences file and load keybindings and MIDI mappings
initializePreferencesFile()
loadFromPreferencesFile()

-- Register the menu entry to show the plugin list dialog
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Load Plugins Dialog",invoke=function() showPluginListDialog() end}

