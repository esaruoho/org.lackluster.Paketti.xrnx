

function cycle_middle_frame()
  -- dBlue's cycle middle frame -explanation system thing
  -- Populate this table with all the frames you wish to cycle through.
  -- Reference: Renoise.Application.API.lua
  local frames = {  
    -- renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR,
    -- renoise.ApplicationWindow.MIDDLE_FRAME_MIXER,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR,
  }
  -- Get the active frame ID.
  local active_frame = renoise.app().window.active_middle_frame
  
  -- Try to locate the frame ID within our table.
  local index = -1
  for i = 1, #frames do
    if frames[i] == active_frame then
      index = i
      break
    end
  end
  
  -- If the frame ID is in our list, cycle to the next one.
  if index > -1 then
    index = index + 1
    if index > #frames then
      index = 1
    end
  -- Else, default to the first one.
  else
    index = 1
  end
  
  -- Show the frame.
  renoise.app().window.active_middle_frame = frames[index]
end

function cycle_upper_frame()
  -- dBlue's cycle middle frame -explanation system thing
  -- Populate this table with all the frames you wish to cycle through.
  -- Reference: Renoise.Application.API.lua
  local frames = {
    renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES,
    renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM
  }
  -- Get the active frame ID.
  local active_frame = renoise.app().window.active_upper_frame
  
  -- Try to locate the frame ID within our table.
  local index = -1
  for i = 1, #frames do
    if frames[i] == active_frame then
      index = i
      break
    end
  end
  
  -- If the frame ID is in our list, cycle to the next one.
  if index > -1 then
    index = index + 1
    if index > #frames then
      index = 1
    end
  -- Else, default to the first one.
  else
    index = 1
  end
  
  -- Show the frame.
  renoise.app().window.active_upper_frame = frames[index]
end

function cycle_lower_frame()
  -- dBlue's cycle middle frame -explanation system thing
  -- Populate this table with all the frames you wish to cycle through.
  -- Reference: Renoise.Application.API.lua
  local frames = {
    renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS,
    renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
  }
  -- Get the active frame ID.
  local active_frame = renoise.app().window.active_lower_frame
  
  -- Try to locate the frame ID within our table.
  local index = -1
  for i = 1, #frames do
    if frames[i] == active_frame then
      index = i
      break
    end
  end
  
  -- If the frame ID is in our list, cycle to the next one.
  if index > -1 then
    index = index + 1
    if index > #frames then
      index = 1
    end
  -- Else, default to the first one.
  else
    index = 1
  end
  
  -- Show the frame.
  renoise.app().window.active_lower_frame = frames[index]
end

renoise.tool():add_keybinding{name="Global:Paketti:dBlue Cycle Middle Frame", invoke=function() cycle_middle_frame() end}
renoise.tool():add_keybinding{name="Global:Paketti:dBlue Cycle Upper Frame", invoke=function() cycle_upper_frame() end}
renoise.tool():add_keybinding{name="Global:Paketti:dBlue Cycle Lower Frame", invoke=function() cycle_lower_frame() end}



require "FormulaDeviceManual"

renoise.tool():add_keybinding{name="Global:Paketti:FormulaDevice", invoke=function()  
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().tracks[renoise.song().selected_track_index]:insert_device_at("Audio/Effects/Native/*Formula", 2)  
local infile = io.open( "FormulaDeviceXML.txt", "rb" )
local indata = infile:read( "*all" )
renoise.song().tracks[renoise.song().selected_track_index].devices[2].active_preset_data = indata
infile:close()

show_manual (
    "Formula Device Documentation", -- manual dialog title
    "FormulaDevice.txt" -- the textfile which contains the manual
  )
end}

-- :::::Automation ExpCurve
-- For some strange reason this keeps putting the information into the channel, not in the automation
function drawVol()
local pos = renoise.song().transport.edit_pos
local pos1 = renoise.song().transport.edit_pos
local edit = renoise.song().transport.edit_mode
local length = renoise.song().selected_pattern.number_of_lines
local curve = 1.105
loadnative("Audio/Effects/Native/Gainer")
renoise.song().selected_track.devices[2].is_maximized=false
for i=1, length do
renoise.song().transport.edit_mode = true
pos.line = i
renoise.song().transport.edit_pos = pos
renoise.song().selected_track.devices[2].parameters[1]:record_value(math.pow(curve, i) / math.pow(curve, length))
end

renoise.song().transport.edit_mode = edit
renoise.song().transport.edit_pos = pos1
end
renoise.tool():add_keybinding {name = "Global:Paketti:ExpCurveVol", invoke=function() drawVol() end}
renoise.tool():add_menu_entry {name = "Pattern Editor:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
renoise.tool():add_menu_entry {name = "Pattern Matrix:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
--renoise.tool():add_keybinding {name = "Global:Paketti:ExpCurveVol", invoke=function() drawVol() end}

-- Track Automation
renoise.tool():add_menu_entry{name="Track Automation:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
renoise.tool():add_menu_entry{name="Track Automation List:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
---------------------------
function PakettiDeleteCombined()   
    local s = renoise.song()
    
    if s.selected_note_column_index == 0 then 
        -- Clearing effect column if no note column is selected
        s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[s.selected_effect_column_index].amount_value = 0
        s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[s.selected_effect_column_index].number_value = 0
    else
        -- Clearing note and its properties if a note column is selected
        local line = s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index]
        local noteCol = line.note_columns[s.selected_note_column_index]
        noteCol.note_string = "---"
        noteCol.instrument_string = ".."
        noteCol.panning_string = ".."
        noteCol.delay_string = ".."
        noteCol.volume_string = ".."
    end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delete Combined", invoke=function() PakettiDeleteCombined() end}
---------------------------
function soloKey()
local s=renoise.song()
  s.tracks[renoise.song().selected_track_index]:solo()
    if s.transport.playing==false then renoise.song().transport.playing=true end
  s.transport.follow_player=true  
    if renoise.app().window.active_middle_frame~=1 then renoise.app().window.active_middle_frame=1 end
end

renoise.tool():add_keybinding{name="Global:Paketti:SoloKey", invoke=function() soloKey() end}



--vV's wonderful sample keyzone noteon/noteoff copier + octave transposition for note-off:
local NOTE_ON = renoise.Instrument.LAYER_NOTE_ON
local NOTE_OFF = renoise.Instrument.LAYER_NOTE_OFF

local function copy_note_layers(source_layer,target_layer,offset)
  local instrument = renoise.song().selected_instrument_index
  
  --delete target layers prior to copying (to prevent overlays)
  if #renoise.song().instruments[instrument].sample_mappings[target_layer] > 0 then
    --Note that when using the delete_sample_mapping, the index is changing on-the-fly
    --So you have to remove the mappings from the last to the first entry instead of vice versa.
    --Else you get errors half-way.
    for i = #renoise.song().instruments[instrument].sample_mappings[target_layer],1,-1  do
      renoise.song().instruments[instrument]:delete_sample_mapping_at(target_layer, i)
    end
  end
  
  for i = 1,#renoise.song().instruments[instrument].sample_mappings[source_layer] do

    local base_note = renoise.song().instruments[instrument].sample_mappings[source_layer][i].base_note
    local map_velocity_to_volume = renoise.song().instruments[instrument].sample_mappings[source_layer][i].map_velocity_to_volume
    local note_range = renoise.song().instruments[instrument].sample_mappings[source_layer][i].note_range
    local sample_index = renoise.song().instruments[instrument].sample_mappings[source_layer][i].sample
--    local use_envelopes = renoise.song().instruments[instrument].sample_mappings[source_layer][i].use_envelopes
    local velocity_range = renoise.song().instruments[instrument].sample_mappings[source_layer][i].velocity_range
    local oct_base_note=nil
    oct_base_note=base_note+offset
    renoise.song().instruments[instrument]:insert_sample_mapping(target_layer, sample_index,oct_base_note,note_range,velocity_range)
   end
end

local function norm() copy_note_layers(NOTE_ON, NOTE_OFF, 0) end
local function octdn() copy_note_layers(NOTE_ON, NOTE_OFF, 12) end
local function octup() copy_note_layers(NOTE_ON, NOTE_OFF, -12) end
local function octdntwo() copy_note_layers(NOTE_ON, NOTE_OFF, 24) end
local function octuptwo() copy_note_layers(NOTE_ON, NOTE_OFF, -24) end

renoise.tool():add_menu_entry{name="--Sample Mappings:Paketti..:Copy Note-On to Note-Off Layer +12", invoke = octup}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Note-On to Note-Off Layer +24", invoke = octuptwo}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Note-On to Note-Off Layer", invoke = norm}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Note-On to Note-Off Layer -12", invoke = octdn}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Note-On to Note-Off Layer -24", invoke = octdntwo}



local NOTE_ON = renoise.Instrument.LAYER_NOTE_ON
local NOTE_OFF = renoise.Instrument.LAYER_NOTE_OFF

local function copy_note_layers(source_layer, target_layer, offset)
  local instrument_index = renoise.song().selected_instrument_index
  local instrument = renoise.song():instrument(instrument_index) -- Get the instrument object
  
  -- Delete target layers prior to copying
  if #instrument.sample_mappings[target_layer] > 0 then
    for i = #instrument.sample_mappings[target_layer], 1, -1 do
      instrument:delete_sample_mapping_at(target_layer, i)
    end
  end
  
  -- Copy mappings from source to target layer
  for _, mapping in ipairs(instrument.sample_mappings[source_layer]) do
    local oct_base_note = mapping.base_note + offset
    instrument:insert_sample_mapping(target_layer, mapping.sample, oct_base_note, mapping.note_range, mapping.velocity_range)
  end
end

-- Utility functions for different offsets
function norm() copy_note_layers(NOTE_ON, NOTE_OFF, 0) end
function octdn() copy_note_layers(NOTE_ON, NOTE_OFF, 12) end
function octup() copy_note_layers(NOTE_ON, NOTE_OFF, -12) end
function octdntwo() copy_note_layers(NOTE_ON, NOTE_OFF, 24) end
function octuptwo() copy_note_layers(NOTE_ON, NOTE_OFF, -24) end

-- Adding menu entries
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy1 Note-On to Note-Off Layer", invoke = function() norm() 
end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy1 Note-On to Note-Off Layer +12", invoke = function() octup() 
end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy1 Note-On to Note-Off Layer +24", invoke = function() octuptwo() end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy1 Note-On to Note-Off Layer -12", invoke = function() octdn() end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy1 Note-On to Note-Off Layer -24", invoke = function() octdntwo() end}


------ inspect
function inspectLayers()
print("InspectLayers function called")
local instrument_index = renoise.song().selected_instrument_index
local instrument = renoise.song():instrument(instrument_index)

-- Iterate over all sample mappings in the instrument
for _, mapping in ipairs(instrument.sample_mappings) do
    -- Check if the mapping is for the NOTE_ON layer
    if mapping.layer == renoise.Instrument.LAYER_NOTE_ON then
        print("Found a NOTE_ON mapping:")
        print("  Sample Index: " .. mapping.sample_index)
        print("  Base Note: " .. mapping.base_note)
        print("  Note Range: " .. table.concat(mapping.note_range, ", "))
        print("  Velocity Range: " .. table.concat(mapping.velocity_range, ", "))
    end
    
    -- Check if the mapping is for the NOTE_OFF layer
    if mapping.layer == renoise.Instrument.LAYER_NOTE_OFF then
        print("Found a NOTE_OFF mapping:")
        print("  Sample Index: " .. mapping.sample_index)
        print("  Base Note: " .. mapping.base_note)
        print("  Note Range: " .. table.concat(mapping.note_range, ", "))
        print("  Velocity Range: " .. table.concat(mapping.velocity_range, ", "))
    end
end
end
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Inspect NoteON NoteOFF", invoke = function() inspectLayers()
end
}










