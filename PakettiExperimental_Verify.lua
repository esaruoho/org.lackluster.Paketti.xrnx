local vb = renoise.ViewBuilder()
local midi_input_devices, midi_output_devices, plugin_dropdown_items, available_plugins
local dialog_content
local custom_dialog

-- Preferences for storing selected values
local midi_input_device = {}
local midi_input_channel = {}
local midi_output_device = {}
local midi_output_channel = {}
local selected_plugin = {}
local open_external_editor = false

-- Initialize variables when needed
local function initialize_variables()
  midi_input_devices = {"<None>"}
  for _, device in ipairs(renoise.Midi.available_input_devices()) do
    table.insert(midi_input_devices, device)
  end

  midi_output_devices = {"<None>"}
  for _, device in ipairs(renoise.Midi.available_output_devices()) do
    table.insert(midi_output_devices, device)
  end

  plugin_dropdown_items = {"<None>"}
  available_plugins = renoise.song().selected_instrument.plugin_properties.available_plugin_infos
  for _, plugin_info in ipairs(available_plugins) do
    if plugin_info.path:find("/AU/") then
      table.insert(plugin_dropdown_items, "AU: " .. plugin_info.short_name)
    elseif plugin_info.path:find("/VST/") then
      table.insert(plugin_dropdown_items, "VST: " .. plugin_info.short_name)
    elseif plugin_info.path:find("/VST3/") then
      table.insert(plugin_dropdown_items, "VST3: " .. plugin_info.short_name)
    end
  end
  
  for i = 1, 16 do
    midi_input_device[i] = midi_input_devices[1]
    midi_input_channel[i] = i
    midi_output_device[i] = midi_output_devices[1]
    midi_output_channel[i] = i
    selected_plugin[i] = plugin_dropdown_items[1]
  end
end

local note_columns_switch, effect_columns_switch, delay_column_switch, volume_column_switch, panning_column_switch, sample_effects_column_switch, collapsed_switch, incoming_audio_switch, populate_sends_switch, external_editor_switch

local function simplifiedSendCreationNaming()
  local send_tracks = {}
  local count = 0

  -- Collect all send tracks
  for i = 1, #renoise.song().tracks do
    if renoise.song().tracks[i].type == renoise.Track.TRACK_TYPE_SEND then
      -- Store the index and name of each send track
      table.insert(send_tracks, {index = count, name = renoise.song().tracks[i].name, track_number = i - 1})
      count = count + 1
    end
  end

  -- Create the appropriate number of #Send devices
  for i = 1, count do
    loadnative("Audio/Effects/Native/#Send")
  end

  local sendcount = 2  -- Start after existing devices

  -- Assign parameters and names in correct order
  for i = 1, count do
    local send_device = renoise.song().selected_track.devices[sendcount]
    local send_track = send_tracks[i]
    send_device.parameters[3].value = send_track.index
    send_device.display_name = send_track.name
    sendcount = sendcount + 1
  end
end

local function MidiInitChannelTrackInstrument(track_index)
  local midi_in_device = midi_input_device[track_index]
  local midi_in_channel = midi_input_channel[track_index]
  local midi_out_device = midi_output_device[track_index]
  local midi_out_channel = midi_output_channel[track_index]
  local plugin = selected_plugin[track_index]
  local note_columns = note_columns_switch.value
  local effect_columns = effect_columns_switch.value
  local delay_column = (delay_column_switch.value == 2)
  local volume_column = (volume_column_switch.value == 2)
  local panning_column = (panning_column_switch.value == 2)
  local sample_effects_column = (sample_effects_column_switch.value == 2)
  local collapsed = (collapsed_switch.value == 2)
  local incoming_audio = (incoming_audio_switch.value == 2)
  local populate_sends = (populate_sends_switch.value == 2)
  local open_ext_editor = (external_editor_switch.value == 2)

  -- Create a new track
  renoise.song():insert_track_at(track_index)
  local new_track = renoise.song():track(track_index)
  new_track.name = "CH" .. string.format("%02d", midi_in_channel) .. " " .. midi_in_device
  renoise.song().selected_track_index = track_index

  -- Set track column settings
  new_track.visible_note_columns = note_columns
  new_track.visible_effect_columns = effect_columns
  new_track.delay_column_visible = delay_column
  new_track.volume_column_visible = volume_column
  new_track.panning_column_visible = panning_column
  new_track.sample_effects_column_visible = sample_effects_column
  new_track.collapsed = collapsed

  -- Populate send devices
  if populate_sends then
    simplifiedSendCreationNaming()
  end

  -- Load *Line Input device if incoming audio is set to ON
  local checkline = #new_track.devices + 1
  if incoming_audio then
    loadnative("Audio/Effects/Native/#Line Input", checkline)
    checkline = checkline + 1
  end

  -- Create a new instrument
  renoise.song():insert_instrument_at(track_index)
  local new_instrument = renoise.song():instrument(track_index)
  new_instrument.name = "CH" .. string.format("%02d", midi_in_channel) .. " " .. midi_in_device

  -- Set MIDI input properties for the new instrument
  new_instrument.midi_input_properties.device_name = midi_in_device
  new_instrument.midi_input_properties.channel = midi_in_channel
  new_instrument.midi_input_properties.assigned_track = track_index

  -- Set the output device for the new track
  if midi_out_device ~= "<None>" then
    new_instrument.midi_output_properties.device_name = midi_out_device
    new_instrument.midi_output_properties.channel = midi_out_channel
  end

  -- Load the selected plugin for the new instrument
  if plugin and plugin ~= "<None>" then
    local plugin_path
    for _, plugin_info in ipairs(available_plugins) do
      if plugin_info.short_name == plugin:sub(5) then
        plugin_path = plugin_info.path
        break
      end
    end
    if plugin_path then
      new_instrument.plugin_properties:load_plugin(plugin_path)
      -- Rename the instrument
      new_instrument.name = "CH" .. string.format("%02d", midi_in_channel) .. " " .. midi_in_device .. " (" .. plugin:sub(5) .. ")"

      -- Select the instrument to ensure devices are mapped correctly
      renoise.song().selected_instrument_index = track_index
      
      -- Add *Instr. Automation and *Instr. MIDI Control to the track immediately after the plugin is loaded
      local instr_automation_device = loadnative("Audio/Effects/Native/*Instr. Automation", checkline)
      if instr_automation_device then
        instr_automation_device.parameters[1].value = track_index - 1
        checkline = checkline + 1
      end

      local instr_midi_control_device = loadnative("Audio/Effects/Native/*Instr. MIDI Control", checkline)
      if instr_midi_control_device then
        instr_midi_control_device.parameters[1].value = track_index - 1
        checkline = checkline + 1
      end

      -- Open external editor if the option is enabled
      if open_ext_editor and new_instrument.plugin_properties.plugin_device then
        new_instrument.plugin_properties.plugin_device.external_editor_visible = true
      end
    end
  end
end

local function on_ok_button_pressed(dialog_content)
  for i = 1, 16 do
    MidiInitChannelTrackInstrument(i)
  end
  renoise.song().selected_track_index = 1 -- Select the first track
  custom_dialog:close()
end

local function on_midi_input_switch_changed(value)
  for i = 1, 16 do
    midi_input_device[i] = midi_input_devices[value]
  end
  -- Update the GUI
  for i = 1, 16 do
    local popup = vb.views["midi_input_popup_" .. i]
    if popup then
      popup.value = value
    end
  end
end

local function on_midi_output_switch_changed(value)
  for i = 1, 16 do
    midi_output_device[i] = midi_output_devices[value]
  end
  -- Update the GUI
  for i = 1, 16 do
    local popup = vb.views["midi_output_popup_" .. i]
    if popup then
      popup.value = value
    end
  end
end

-- Randomize plugin selection
local function randomize_plugin_selection(plugin_type)
  local plugins = {}
  for _, plugin_info in ipairs(available_plugins) do
    if plugin_info.path:find(plugin_type) then
      table.insert(plugins, plugin_info.short_name)
    end
  end

  for i = 1, 16 do
    if #plugins > 0 then
      local random_plugin = plugins[math.random(#plugins)]
      for j, item in ipairs(plugin_dropdown_items) do
        if item:find(plugin_type:sub(2, -2)) and item:find(random_plugin) then
          selected_plugin[i] = item
          vb.views["plugin_popup_" .. i].value = j
          break
        end
      end
    end
  end
end

local function randomize_au_plugins()
  randomize_plugin_selection("/AU/")
end

local function randomize_vst_plugins()
  randomize_plugin_selection("/VST/")
end

local function randomize_vst3_plugins()
  randomize_plugin_selection("/VST3/")
end

local function clear_plugin_selection()
  for i = 1, 16 do
    selected_plugin[i] = plugin_dropdown_items[1]
    vb.views["plugin_popup_" .. i].value = 1
  end
end

-- Function to show the custom dialog
function generaMIDISetupShowCustomDialog()
  -- Initialize variables
  initialize_variables()

  -- Clear the ViewBuilder to prevent duplicate view IDs
  vb = renoise.ViewBuilder()

  -- Initialize the GUI elements
  local rows = {}
  for i = 1, 16 do
    rows[i] = vb:horizontal_aligner{
      mode = "right",
      vb:text{text = "Track " .. i .. ":", width = 100},
      vb:popup{items = midi_input_devices, width = 200, notifier = function(value) midi_input_device[i] = midi_input_devices[value] end, id = "midi_input_popup_" .. i},
      vb:popup{items = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16"}, width = 50, notifier = function(value) midi_input_channel[i] = tonumber(value) end, value = i},
      vb:popup{items = midi_output_devices, width = 200, notifier = function(value) midi_output_device[i] = midi_output_devices[value] end, id = "midi_output_popup_" .. i},
      vb:popup{items = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16"}, width = 50, notifier = function(value) midi_output_channel[i] = tonumber(value) end, value = i},
      vb:popup{items = plugin_dropdown_items, width = 200, notifier = function(value) selected_plugin[i] = plugin_dropdown_items[value] end, id = "plugin_popup_" .. i}
    }
  end

  note_columns_switch = vb:switch{items = {"1","2","3","4","5","6","7","8","9","10","11","12"}, width = 300, value = 1}
  effect_columns_switch = vb:switch{items = {"1","2","3","4","5","6","7","8"}, width = 300, value = 1}
  delay_column_switch = vb:switch{items = {"Off","On"}, width = 300, value = 1}
  volume_column_switch = vb:switch{items = {"Off","On"}, width = 300, value = 1}
  panning_column_switch = vb:switch{items = {"Off","On"}, width = 300, value = 1}
  sample_effects_column_switch = vb:switch{items = {"Off","On"}, width = 300, value = 1}
  collapsed_switch = vb:switch{items = {"Not Collapsed","Collapsed"}, width = 300, value = 1}
  incoming_audio_switch = vb:switch{items = {"Off","On"}, width = 300, value = 1}
  populate_sends_switch = vb:switch{items = {"Off","On"}, width = 300, value = 1}
  external_editor_switch = vb:switch{items = {"Off","On"}, width = 300, value = 1}

  dialog_content = vb:column{
    margin = 10, spacing = 10,
    vb:horizontal_aligner{mode = "right", vb:row{
      vb:text{text = "MIDI Input Device:"},
      vb:switch{items = midi_input_devices, value = 1, width = 700, notifier = on_midi_input_switch_changed}
    }},
    vb:horizontal_aligner{mode = "right", vb:row{
      vb:text{text = "MIDI Output Device:"},
      vb:switch{items = midi_output_devices, value = 1, width = 700, notifier = on_midi_output_switch_changed}
    }},
    vb:row{
      vb:button{text = "Randomize AU Plugin Selection", width = 200, notifier = randomize_au_plugins},
      vb:button{text = "Randomize VST Plugin Selection", width = 200, notifier = randomize_vst_plugins},
      vb:button{text = "Randomize VST3 Plugin Selection", width = 200, notifier = randomize_vst3_plugins},
      vb:button{text = "Clear Plugin Selection", width = 200, notifier = clear_plugin_selection}
    },
    vb:column(rows),
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Note Columns:"}, note_columns_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Effect Columns:"}, effect_columns_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Delay Column:"}, delay_column_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Volume Column:"}, volume_column_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Panning Column:"}, panning_column_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Sample Effects Column:"}, sample_effects_column_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Track State:"}, collapsed_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Incoming Audio:"}, incoming_audio_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Populate Track with Sends:"}, populate_sends_switch}},
    vb:horizontal_aligner{mode = "right", vb:row{vb:text{text = "Open External Editor:"}, external_editor_switch}},
    vb:row{
      vb:button{text = "OK", width = 100, notifier = function() on_ok_button_pressed(dialog_content) end},
      vb:button{text = "Close", width = 100, notifier = function() custom_dialog:close() end}
    }
  }

  custom_dialog = renoise.app():show_custom_dialog("Paketti MIDI Populator", dialog_content)
end

-- Add menu entry to show the custom dialog
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Paketti MIDI Populator",invoke=generaMIDISetupShowCustomDialog}

























-----------
function hackysack()
renoise.song().selected_instrument.name="IAC Driver (Bus 1) Channel 01"
renoise.song().selected_instrument.midi_input_properties.device_name="IAC Driver (Bus 1)"
renoise.song().selected_instrument.midi_input_properties.channel=1
renoise.song().selected_instrument.midi_input_properties.assigned_track=1

renoise.song().selected_instrument.midi_output_properties.device_name=blaa
renoise.song().selected_instrument.midi_output_properties.channel=blee

end


renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Prepare 16 channels",invoke = function() hackysack() end}

------------

--------
function Experimental()
    function read_file(path)
        local file = io.open(path, "r")  -- Open the file in read mode
        if not file then
            print("Failed to open file")
            return nil
        end
        local content = file:read("*a")  -- Read the entire content
        file:close()
        return content
    end

    function check_and_execute(xml_path, bash_script)
        local xml_content = read_file(xml_path)
        if not xml_content then
            return
        end

        local pattern = "<ShowScriptingDevelopmentTools>(.-)</ShowScriptingDevelopmentTools>"
        local current_value = xml_content:match(pattern)

        if current_value == "false" then  -- Check if the value is false
            print("Scripting tools are disabled. Executing the bash script to enable...")
            local command = 'open -a Terminal "' .. bash_script .. '"'
            os.execute(command)
        elseif current_value == "true" then
            print("Scripting tools are already enabled. No need to execute the bash script.")
          local bash_script = "/Users/esaruoho/macOS_DisableScriptingTools.sh"
            local command = 'open -a Terminal "' .. bash_script .. '"'
            os.execute(command)
        else
            print("Could not find the <ShowScriptingDevelopmentTools> tag in the XML.")
        end
    end

    local config_path = "/Users/esaruoho/Library/Preferences/Renoise/V3.4.3/Config.xml"
    local bash_script = "/Users/esaruoho/macOS_EnableScriptingTools.sh" -- Ensure this path is correct

    check_and_execute(config_path, bash_script)
end

renoise.tool():add_menu_entry {name = "Main Menu:Tools:Experimental",invoke = function() Experimental() end}

--Wipes the pattern data, but not the samples or instruments.
--WARNING: Does not reset current filename.
function wipeSongPattern()
local s=renoise.song()
  for i=1,300 do
    if s.patterns[i].is_empty==false then
    s.patterns[i]:clear()
    renoise.song().patterns[i].number_of_lines=64
    else 
    print ("Encountered empty pattern, not deleting")
    renoise.song().patterns[i].number_of_lines=64
    end
  end
end
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Song Patterns", invoke=function() wipeSongPattern() end}

function AutoGapper()
-- Something has changed with the Filter-device:
--*** ./Experimental_Verify.lua:30: attempt to index field '?' (a nil value)
--*** stack traceback:
--***   ./Experimental_Verify.lua:30: in function 'AutoGapper'
--***   ./Experimental_Verify.lua:37: in function <./Experimental_Verify.lua:37>

--renoise.song().tracks[get_master_track_index()].visible_effect_columns = 4  
local gapper=nil
renoise.app().window.active_lower_frame=1
renoise.app().window.lower_frame_is_visible=true
  loadnative("Audio/Effects/Native/Filter")
  loadnative("Audio/Effects/Native/*LFO")
  renoise.song().selected_track.devices[2].parameters[2].value=2
  renoise.song().selected_track.devices[2].parameters[3].value=1
  renoise.song().selected_track.devices[2].parameters[7].value=2
  renoise.song().selected_track.devices[3].parameters[5].value=0.0074
local gapper=renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines*2*4
  renoise.song().selected_track.devices[2].parameters[6].value_string=tostring(gapper)
--renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[4].number_string = "18"
end

renoise.tool():add_keybinding{name="Global:Paketti:Add Filter & LFO (AutoGapper)", invoke=function() AutoGapper() end}


--2nd keybind for LoopBlock forward/backward
function loopblockback()
local t = renoise.song().transport
      t.loop_block_enabled=true
      t:loop_block_move_backwards()
      t.follow_player = true
end

function loopblockforward()
local t = renoise.song().transport
      t.loop_block_enabled=true
      t:loop_block_move_forwards()
      t.follow_player = true
end

renoise.tool():add_keybinding{name="Global:Paketti:Loop Block Backwards", invoke=function() loopblockback() end}
renoise.tool():add_keybinding{name="Global:Paketti:Loop Block Forwards", invoke=function() loopblockforward() end}

------------
function start_stop_sample_and_loop_oh_my()
local w=renoise.app().window
local s=renoise.song()
local t=s.transport
local ss=s.selected_sample
local currTrak=s.selected_track_index
local currPatt=s.selected_pattern_index

if w.sample_record_dialog_is_visible then
    -- we are recording, stop
    t:start_stop_sample_recording()
    -- write note
     ss.autoseek=true
     s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
     s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"

for i= 1,12 do
if s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].is_empty==true then
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].note_string="C-4"
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].instrument_value=s.selected_instrument_index-1
else
 if i == renoise.song().tracks[currTrak].visible_note_columns and i == 12
  then renoise.song():insert_track_at(renoise.song().selected_track_index)
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[1].note_string="C-4"
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[1].instrument_value=s.selected_instrument_index-1
end
end
end
    -- hide dialog
    w.sample_record_dialog_is_visible = false
  else
    -- not recording. show dialog, start recording.
    w.sample_record_dialog_is_visible = true
    t:start_stop_sample_recording()
  end
end

--renoise.tool():add_keybinding{name="Global:Paketti:Stair RecordToCurrent", invoke=function() 
--if renoise.song().transport.playing==false then
    --renoise.song().transport.playing=true end
--start_stop_sample_and_loop_oh_my() end}
--
--function stairs()
--local currCol=nil
--local addCol=nil
--currCol=renoise.song().selected_note_column_index
---
--if renoise.song().selected_track.visibile_note_columns and renoise.song().selected_note_column_index == 12   then 
--renoise.song().selected_note_column_index = 1
--end
--
--
--if currCol == renoise.song().selected_track.visible_note_columns
--then renoise.song().selected_track.visible_note_columns = addCol end
--
--renoise.song().selected_note_column_index=currCol+1
--
--end
--renoise.tool():add_keybinding{name="Global:Paketti:Stair", invoke=function() stairs() end}

function effectbypasspattern()
local currTrak = renoise.song().selected_track_index
local number = (table.count(renoise.song().selected_track.devices))
local tablee={"1F","2F","3F","4F","5F","6F","7F","8F"}
 for i=2,number  do 
  --renoise.song().selected_track.devices[i].is_active=false
  renoise.song().selected_track.visible_effect_columns=(table.count(renoise.song().selected_track.devices)-1)
--This would be (1-8F)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[1].number_string="1F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[2].number_string="2F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[3].number_string="3F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[4].number_string="4F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[5].number_string="5F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[6].number_string="6F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[7].number_string="7F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[8].number_string="8F"
--this would be 00 for disabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="00"
 end
end

function effectenablepattern()
local currTrak = renoise.song().selected_track_index
local number = (table.count(renoise.song().selected_track.devices))
for i=2,number  do 
--enable all plugins on selected track right now
--renoise.song().selected_track.devices[i].is_active=true
--display max visible effects
local helper=(table.count(renoise.song().selected_track.devices)-1)
renoise.song().selected_track.visible_effect_columns=helper
--This would be (1-8F)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[1].number_string="1F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[2].number_string="2F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[3].number_string="3F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[4].number_string="4F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[5].number_string="5F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[6].number_string="6F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[7].number_string="7F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[8].number_string="8F"

--this would be 01 for enabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="01"
end
end
------
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Bypass EFX (Write to Pattern)", invoke=function() effectbypasspattern() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Enable EFX (Write to Pattern)", invoke=function() effectenablepattern()  end}
----------------------------

-- has-line-input + add-line-input
function has_line_input()
-- Write some code to find the line input in the correct place
local tr = renoise.song().selected_track
 if tr.devices[2] and tr.devices[2].device_path=="Audio/Effects/Native/#Line Input" 
  then return true
 else
  return false
 end
end

function add_line_input()
-- Write some code to add the line input in the correct place
 loadnative("Audio/Effects/Native/#Line Input")
end

function remove_line_input()
-- Write some code to remove the line input if it's in the correct place
 renoise.song().selected_track:delete_device_at(2)
end

-- recordamajic
function recordamajic9000(running)
    if running then
    renoise.song().transport.playing=true
        -- start recording code here
renoise.app().window.sample_record_dialog_is_visible=true
renoise.app().window.lock_keyboard_focus=true
renoise.song().transport:start_stop_sample_recording()
    else
    -- Stop recording here
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Recordammajic9000",
invoke=function() if has_line_input() then 
      recordtocurrenttrack()    
      G01()
 else add_line_input()
      recordtocurrenttrack()
      G01()
 end end}

-- turn samplerecorder ON
function SampleRecorderOn()
local howmany = table.count(renoise.song().selected_track.devices)

if renoise.app().window.sample_record_dialog_is_visible==false then
renoise.app().window.sample_record_dialog_is_visible=true 

  if howmany == 1 then 
    loadnative("Audio/Effects/Native/#Line Input")
    return
  else
    if renoise.song().selected_track.devices[2].name=="#Line Input" then
    renoise.song().selected_track:delete_device_at(2)
    renoise.app().window.sample_record_dialog_is_visible=false
    else
    loadnative("Audio/Effects/Native/#Line Input")
    return
end    
  end  

else renoise.app().window.sample_record_dialog_is_visible=false
  if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Display Sample Recorder with #Line Input", invoke=function() SampleRecorderOn() end}

function glideamount(amount)
local counter=nil 
for i=renoise.song().selection_in_pattern.start_line,renoise.song().selection_in_pattern.end_line 
do renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].number_string="0G" 
counter=renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].amount_value+amount 

if counter > 255 then counter=255 end
if counter < 1 then counter=0 
end
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].amount_value=counter 
end
end

local s = nil

function startup_()
  local s=renoise.song()
   renoise.app().window:select_preset(1)
   
   renoise.song().instruments[s.selected_instrument_index].active_tab=1
    if renoise.app().window.active_middle_frame==0 and s.selected_sample.sample_buffer_observable:has_notifier(sample_loaded_change_to_sample_editor) then 
    s.selected_sample.sample_buffer_observable:remove_notifier(sample_loaded_change_to_sample_editor)
    else
  --s.selected_sample.sample_buffer_observable:add_notifier(sample_loaded_change_to_sample_editor)

    return
    end
end

  function sample_loaded_change_to_sample_editor()
--    renoise.app().window.active_middle_frame=4
  end

if not renoise.tool().app_new_document_observable:has_notifier(startup_) 
   then renoise.tool().app_new_document_observable:add_notifier(startup_)
   else renoise.tool().app_new_document_observable:remove_notifier(startup_)
end
--------------------------------------------------------------------------------
function PakettiCapsLockNoteOffNextPtn()   
local s=renoise.song()
local wrapping=s.transport.wrapped_pattern_edit
local editstep=s.transport.edit_step

local currLine=s.selected_line_index
local currPatt=s.selected_pattern_index

local counter=nil
local addlineandstep=nil
local counting=nil
local seqcount=nil
local resultPatt=nil

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="FF"
then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=""
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=""
return
else
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"
then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00"  
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return
end

if renoise.song().transport.edit_mode==true then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"  
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="CF"
return
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"

then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00" 
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string~=nil then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="FF"
return
else 
if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=="OFF" then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
return
else
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
end

--s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
end

addlineandstep=currLine+editstep
seqcount = currPatt+1

if addlineandstep > s.patterns[currPatt].number_of_lines then
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
counting=addlineandstep-s.patterns[currPatt].number_of_lines
 if seqcount > (table.count(renoise.song().sequencer.pattern_sequence)) then 
 seqcount = (table.count(renoise.song().sequencer.pattern_sequence))
 s.selected_sequence_index=seqcount
 end
 
resultPatt=currPatt+1 
 if resultPatt > #renoise.song().sequencer.pattern_sequence then 
 resultPatt = (table.count(renoise.song().sequencer.pattern_sequence))
s.selected_sequence_index=resultPatt
s.selected_line_index=counting
end
else 
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
--s.selected_sequence_index=currPatt+1
s.selected_line_index=addlineandstep

counter = addlineandstep-1

renoise.app():show_status("Now on: " .. counter .. "/" .. s.patterns[currPatt].number_of_lines .. " In Pattern: " .. currPatt)
end
end
----
function PakettiCapsLockNoteOff()   
local s=renoise.song()
local st=s.transport
local wrapping=st.wrapped_pattern_edit
local editstep=st.edit_step

local currLine=s.selected_line_index
local currPatt=s.selected_sequence_index

local counter=nil
local addlineandstep=nil
local counting=nil
local seqcount=nil

if renoise.song().patterns[renoise.song().selected_sequence_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=="OFF" then 

s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
return
else end

if not s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=="OFF"
then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
else s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
end

addlineandstep=currLine+editstep
seqcount = currPatt+1

if addlineandstep > s.patterns[currPatt].number_of_lines then
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
counting=addlineandstep-s.patterns[currPatt].number_of_lines
 if seqcount > (table.count(renoise.song().sequencer.pattern_sequence)) then 
 seqcount = (table.count(renoise.song().sequencer.pattern_sequence))
 s.selected_sequence_index=seqcount
 end
--s.selected_sequence_index=currPatt+1
s.selected_line_index=counting
else 
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
--s.selected_sequence_index=currPatt+1
s.selected_line_index=addlineandstep

counter = addlineandstep-1

renoise.app():show_status("Now on: " .. counter .. "/" .. s.patterns[currPatt].number_of_lines .. " In Pattern: " .. currPatt)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Note Off / Caps Lock replacement", invoke=function() 
if renoise.song().transport.wrapped_pattern_edit == false then PakettiCapsLockNoteOffNextPtn() 
else PakettiCapsLockNoteOff() end
end}
--------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Record to Current Track+Plus", 
invoke=function() 
      renoise.app().window.active_lower_frame=1
local howmany = table.count(renoise.song().selected_track.devices)

if howmany == 1 then 
loadnative("Audio/Effects/Native/#Line Input")
recordtocurrenttrack()
return
else
if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  recordtocurrenttrack()
  return
else
  loadnative("Audio/Effects/Native/#Line Input")
  recordtocurrenttrack()
  return
end end end}

renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Record To Current", invoke=function() recordtocurrenttrack() end}
----------------------------------------------------------------------------------------------------------
--esa- 2nd keybind for Record Toggle ON/OFF with effect_column reading
function RecordToggle()
 local a=renoise.app()
 local s=renoise.song()
 local t=s.transport
 local currentstep=t.edit_step
--if has notifier, dump notifier, if no notifier, add notifier
 if t.edit_mode then
    t.edit_mode=false
 if t.edit_step==0 then
    t.edit_step=1
 else
  return
 end 
 else
      t.edit_mode = true
   if s.selected_effect_column_index == 1 then t.edit_step=0
   elseif s.selected_effect_column_index == 0 then t.edit_step=currentstep return
   end
end
end
----------------------------------------
require "Research/FormulaDeviceManual"

renoise.tool():add_keybinding{name="Global:Paketti:FormulaDevice", invoke=function()  
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().tracks[renoise.song().selected_track_index]:insert_device_at("Audio/Effects/Native/*Formula", 2)  
local infile = io.open( "Research/FormulaDeviceXML.txt", "rb" )
local indata = infile:read( "*all" )
renoise.song().tracks[renoise.song().selected_track_index].devices[2].active_preset_data = indata
infile:close()

show_manual (
    "Formula Device Documentation", -- manual dialog title
    "Research/FormulaDevice.txt" -- the textfile which contains the manual
  )
end}
---------------------------
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Disk Browser Focus",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(7) end}

renoise.tool():add_keybinding{name="Global:Paketti:Disk Browser Focus",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(8) end}

renoise.tool():add_keybinding{name="Global:Paketti:Disk Browser Focus (2nd)",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(8) end}

renoise.tool():add_keybinding{name="Global:Paketti:Contour Shuttle Disk Browser Focus",invoke=function() renoise.app().window:select_preset(8) end}
------------------------------------------------------------------------------------------------
function G01()
local s=renoise.song()
  local currTrak=s.selected_track_index
  local currPatt=s.selected_pattern_index
local rightinstrument=nil
local rightinstrument=renoise.song().selected_instrument_index-1
  if not preferences._0G01_Loader.value then return end

local line=s.patterns[currPatt].tracks[currTrak].lines[1]
    line.note_columns[1].note_string="C-4"
    line.note_columns[1].instrument_value=rightinstrument
    s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
    s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"
end
--------- inspect

function writeToClipboard(text)
    -- Using AppleScript to handle clipboard operations
    local safe_text = text:gsub('"', '\\"')  -- Escape double quotes for AppleScript
    local command = 'osascript -e \'set the clipboard to "' .. safe_text .. '"\''

    -- Execute the command and check for errors
    local success, exit_code, exit_reason = os.execute(command)
    if success then
        print("Successfully copied to clipboard: " .. text)
    else
        print("Failed to copy to clipboard:", exit_reason, "(exit code " .. tostring(exit_code) .. ")")
    end
end
---------
function move_up(chg)
local sindex=renoise.song().selected_line_index
local s= renoise.song()
local note=s.selected_note_column
--This switches currently selected row but doesn't 
--move the note
--s.selected_line_index = (sindex+chg)
-- moving note up, applying correct delay value and moving cursor up goes here
end
--movedown
function move_down(chg)
local sindex=renoise.song().selected_line_index
local s= renoise.song()
--This switches currently selected row but doesn't 
--move the note
--s.selected_line_index = (sindex+chg)
-- moving note down, applying correct delay value and moving cursor down goes here
end


-- Function to adjust the delay value of the selected note column within the current phrase
-- TODO: missing API for reading phrase.selected_line_index. can't work
function Phrplusdelay(chg)
  local song = renoise.song()
  local nc = song.selected_note_column

  -- Check if a note column is selected
  if not nc then
    local message = "No note column is selected!"
    renoise.app():show_status(message)
    print(message)
    return
  end

  local currTrak = song.selected_track_index
  local currInst = song.selected_instrument_index
  local currPhra = song.selected_phrase_index
  local sli = song.selected_line_index
  local snci = song.selected_note_column_index

  -- Check if a phrase is selected
  if currPhra == 0 then
    local message = "No phrase is selected!"
    renoise.app():show_status(message)
    print(message)
    return
  end

  -- Ensure delay columns are visible in both track and phrase
  song.instruments[currInst].phrases[currPhra].delay_column_visible = true
  song.tracks[currTrak].delay_column_visible = true

  -- Get current delay value from the selected note column in the phrase
  local phrase = song.instruments[currInst].phrases[currPhra]
  local line = phrase:line(sli)
  local note_column = line:note_column(snci)
  local Phrad = note_column.delay_value

  -- Adjust delay value, ensuring it stays within 0-255 range
  note_column.delay_value = math.max(0, math.min(255, Phrad + chg))

  -- Show and print status message
  local message = "Delay value adjusted by " .. chg .. " at line " .. sli .. ", column " .. snci
  renoise.app():show_status(message)
  print(message)

  -- Show and print visible note columns and effect columns
  local visible_note_columns = phrase.visible_note_columns
  local visible_effect_columns = phrase.visible_effect_columns
  local columns_message = string.format("Visible Note Columns: %d, Visible Effect Columns: %d", visible_note_columns, visible_effect_columns)
  renoise.app():show_status(columns_message)
  print(columns_message)
end

-- Add keybindings for adjusting the delay value
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +1",invoke=function() Phrplusdelay(1) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -1",invoke=function() Phrplusdelay(-1) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +10",invoke=function() Phrplusdelay(10) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -10",invoke=function() Phrplusdelay(-10) end}


---------------------------------------------------------------------------------------------------------

----------

function delay(seconds)
    local command = "sleep " .. tonumber(seconds)
    os.execute(command)
end


----------
function pattern_line_notifier(pos) --here
  local colnumber=nil
  local countline=nil
  local count=nil
--  print (pos.pattern)
--  print (pos.track)
--  print (pos.line)

local s=renoise.song() 
local t=s.transport
if t.edit_step==0 then 
count=s.selected_note_column_index+1

if count == s.tracks[s.selected_track_index].visible_note_columns then s.selected_note_column_index=count return end
if count > s.tracks[s.selected_track_index].visible_note_columns then 
local slicount=nil
slicount=s.selected_line_index+1 
if slicount > s.patterns[s.selected_pattern_index].number_of_lines
then 
s.selected_line_index=s.patterns[s.selected_pattern_index].number_of_lines end
count=1 
s.selected_note_column_index=count return
else s.selected_note_column_index=count return end
end

countline=s.selected_line_index+1---1+renoise.song().transport.edit_step
   if t.edit_step>1 then
   countline=countline-1
   else countline=s.selected_line_index end
   --print ("countline is selected line index +1" .. countline)
   --print ("editstep" .. renoise.song().transport.edit_step)
   if countline > s.patterns[s.selected_pattern_index].number_of_lines
   then countline=1
   end
   s.selected_line_index=countline
 
   colnumber=s.selected_note_column_index+1
   if colnumber > s.tracks[s.selected_track_index].visible_note_columns then
   s.selected_note_column_index=1
   return end
  s.selected_note_column_index=colnumber end
  
function startcolumncycling(number) -- here
local s=renoise.song()
  if s.patterns[s.selected_pattern_index]:has_line_notifier(pattern_line_notifier) 
then s.patterns[s.selected_pattern_index]:remove_line_notifier(pattern_line_notifier)
 renoise.app():show_status(number .. " Column Cycle Keyjazz Off")
else s.patterns[s.selected_pattern_index]:add_line_notifier(pattern_line_notifier)
 renoise.app():show_status(number .. " Column Cycle Keyjazz On") end
end

for cck=1,12 do
renoise.tool():add_keybinding{name="Global:Paketti:Column Cycle Keyjazz " .. cck,invoke=function() displayNoteColumn(cck) startcolumncycling(cck) end}
end

renoise.tool():add_keybinding{name="Global:Paketti:Start/Stop Column Cycling",invoke=function() startcolumncycling() 
  if renoise.song().patterns[renoise.song().selected_pattern_index]:has_line_notifier(pattern_line_notifier)
then renoise.app():show_status("Column Cycle Keyjazz On")
else renoise.app():show_status("Column Cycle Keyjazz Off") end end}

renoise.tool():add_keybinding{name="Global:Paketti:Column Cycle Keyjazz 01_Special",invoke=function() 
displayNoteColumn(12) 
GenerateDelayValue()
renoise.song().transport.edit_mode=true
renoise.song().transport.edit_step=0
renoise.song().selected_note_column_index=1
startcolumncycling(12) end}

---------------------------
function Ding()
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.enabled=true
--LFO1
--1 = Off, 2 = Sin, 3 = Saw, 4 = Pulse, 5 = Random
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.lfo1.mode=2
--LFO1 amount
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.lfo1.amount=99
--LFO1 Frequency
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.lfo1.frequency=13
--LFO1 Phase
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.lfo1.phase=30
end
renoise.tool():add_menu_entry{name="Sample Editor:Ding", invoke=function() Ding() end}

-------------------
---------------------------
----------------------------



