-------------------
function cycle_middle_frame()
  -- dBlue's cycle middle frame -explanation system thing
  -- Populate this table with all the frames you wish to cycle through.
  -- Reference: Renoise.Application.API.lua
  local frames = {
    -- renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR,
    -- renoise.ApplicationWindow.MIDDLE_FRAME_MIXER,
    -- renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_OVERVIEW,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR,
    -- renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION,
    -- renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS,
    -- renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR,
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

renoise.tool():add_keybinding {name="Global:Paketti:dBlue Cycle Middle Frame", invoke=function() cycle_middle_frame()   end}

---------------------------
--vV's wonderful sample keyzone noteon/noteoff copier + octave transposition for note-off:
local NOTE_ON = renoise.Instrument.LAYER_NOTE_ON
local NOTE_OFF = renoise.Instrument.LAYER_NOTE_OFF

local function copy_note_layers(source_layer,target_layer, offset)
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
    local sample_index = renoise.song().instruments[instrument].sample_mappings[source_layer][i].sample_index
    local use_envelopes = renoise.song().instruments[instrument].sample_mappings[source_layer][i].use_envelopes
    local velocity_range = renoise.song().instruments[instrument].sample_mappings[source_layer][i].velocity_range
    local oct_base_note=nil
    oct_base_note= base_note + offset
    renoise.song().instruments[instrument]:insert_sample_mapping(target_layer, sample_index,oct_base_note,note_range,velocity_range)
   end
end

local function norm() copy_note_layers(NOTE_ON, NOTE_OFF, 0) end
local function octdn() copy_note_layers(NOTE_ON, NOTE_OFF, 12) end
local function octup() copy_note_layers(NOTE_ON, NOTE_OFF, -12) end
local function octdntwo() copy_note_layers(NOTE_ON, NOTE_OFF, 24) end
local function octuptwo() copy_note_layers(NOTE_ON, NOTE_OFF, -24) end

renoise.tool():add_menu_entry {name="--Sample Mappings:Copy note-on to note-off layer +12", invoke = octup}
renoise.tool():add_menu_entry {name="Sample Mappings:Copy note-on to note-off layer +24", invoke = octuptwo}
renoise.tool():add_menu_entry {name="Sample Mappings:Copy note-on to note-off layer", invoke = norm}
renoise.tool():add_menu_entry {name="Sample Mappings:Copy note-on to note-off layer -12", invoke = octdn}
renoise.tool():add_menu_entry {name="Sample Mappings:Copy note-on to note-off layer -24", invoke = octdntwo}
-------------------
