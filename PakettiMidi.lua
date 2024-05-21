-------------------------------------------------------------------------------------------------------------------------------
--Groove Settings, re-written and simplified by mxb
--Control Grooves with a slider
renoise.tool():add_midi_mapping{name="Paketti:Groove Settings Groove #1 x[Knob]",
  invoke=function(midi_message)
  local ga=renoise.song().transport.groove_amounts
    if not renoise.song().transport.groove_enabled then renoise.song().transport.groove_enabled=true end
    renoise.app().window.active_lower_frame=1
    renoise.song().transport.groove_amounts = {midi_message.int_value/127, ga[2], ga[3], ga[4]}
    end}

renoise.tool():add_midi_mapping{name="Paketti:Groove Settings Groove #2 x[Knob]",
  invoke=function(midi_message)
  local ga=renoise.song().transport.groove_amounts
    if not renoise.song().transport.groove_enabled then renoise.song().transport.groove_enabled=true end    
    renoise.app().window.active_lower_frame=1
    renoise.song().transport.groove_amounts = {ga[1], midi_message.int_value/127, ga[3], ga[4]}
    end}

renoise.tool():add_midi_mapping{name="Paketti:Groove Settings Groove #3 x[Knob]",
  invoke=function(midi_message)
  local ga=renoise.song().transport.groove_amounts
    if not renoise.song().transport.groove_enabled then renoise.song().transport.groove_enabled=true end
    renoise.app().window.active_lower_frame=1
    renoise.song().transport.groove_amounts = {ga[1], ga[2], midi_message.int_value/127, ga[4]}
    end}

renoise.tool():add_midi_mapping{name="Paketti:Groove Settings Groove #4 x[Knob]",
  invoke=function(midi_message)
  local ga=renoise.song().transport.groove_amounts
    if not renoise.song().transport.groove_enabled then renoise.song().transport.groove_enabled=true end
    renoise.app().window.active_lower_frame=1
    renoise.song().transport.groove_amounts = {ga[1], ga[2], ga[3], midi_message.int_value/127}
    end}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Control Computer Keyboard Velocity with a slider.
renoise.tool():add_midi_mapping{name="Paketti:Computer Keyboard Velocity Slider x[Knob]",
  invoke=function(midi_message) 
  local s=renoise.song().transport
  if t.keyboard_velocity_enabled==false then t.keyboard_velocity_enabled=true end
     t.keyboard_velocity=midi_message.int_value end}

-- Destructively control Sample volume with a slider
renoise.tool():add_midi_mapping{name="Global:Paketti:Change Selected Sample Volume x[Slider]",invoke=function(midi_message)
renoise.app().window.active_middle_frame=5
renoise.song().selected_sample.volume=midi_message.int_value/127
end}

renoise.tool():add_midi_mapping{name="Global:Paketti:Delay Column x[Slider]",invoke=function(midi_message)
renoise.app().window.active_middle_frame=1
local results = nil

results=midi_message.int_value/127
renoise.app():show_status("haloo" .. results)
renoise.song().selected_note_column.delay_value = math.max(0, math.min(257, midi_message.int_value * 2))

-- if midi_message.int_value > 64 then columns(1,1)
-- else if midi_message.int_value < 64 then columns(-1,1)
-- end
-- end

end}
-------------------------------------------------------------------------------------------------------------------------------------
--Midi Mapping for Metronome On/Off Toggle
renoise.tool():add_midi_mapping{name="Global:Paketti:Metronome On/Off x[Toggle]",invoke=function() MetronomeOff() end}
--Midi Mapping for Expand/Collapse
renoise.tool():add_midi_mapping{name="Global:Paketti:Uncollapser",invoke=function() Uncollapser() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Collapser",invoke=function() Collapser() end} 
-------------------------------------------------------------------------------------------------------------------------------------
--- Show or hide pattern matrix
function showhidepatternmatrix()
local pmi=renoise.app().window.pattern_matrix_is_visible
  if pmi==true then pmi=false else pmi=true end
end

renoise.tool():add_midi_mapping{name="Global:Paketti:Show/Hide Pattern Matrix x[Toggle]", invoke=function() showhidepatternmatrix() end}
-----------------------------------------------------------------------------------------------------------------------------------------
renoise.tool():add_midi_mapping{name="Global:Paketti:Record and Follow On/Off x[Knob]", invoke=function(midi_message) 
--Aided by dblue
local t=renoise.song().transport
local w=renoise.app().window
if (midi_message.int_value == 127) then t.edit_mode = true t.follow_player = true t.playing = true
  w.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR 
  w.lock_keyboard_focus = true
else end
if (midi_message.int_value == 0) then t.edit_mode = false t.follow_player = false t.playing = false
else end

    if (midi_message.int_value >= 100) then
      t.edit_mode = true
      t.follow_player = true 
      w.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR 
      w.lock_keyboard_focus = true      
    else 
      t.edit_mode = false
      t.follow_player = false
    end
end}
---------------------------------------------------------------------------------------------------------------------------
--Record Quantize On/Off for Midi_Mapping
renoise.tool():add_midi_mapping{name="Global:Paketti:Record Quantize On/Off x[Toggle]",
invoke=function()
  if renoise.song().transport.record_quantize_enabled==true then
     renoise.song().transport.record_quantize_enabled=false
  else
     renoise.song().transport.record_quantize_enabled=true
   end
end}
-----------------------------------------------------------------------------------------------------------------------------------------
-- //TODO check that these work
renoise.tool():add_midi_mapping{name="Global:Paketti:Start Playback from Cursor Row x[Toggle]",  invoke=function() ImpulseTrackerPlaySong() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Stop Playback (Panic) x[Toggle]",  invoke=function() ImpulseTrackerStop() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Play Current Line & Advance by EditStep x[Toggle]",  invoke=function() PlayCurrentLine() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Record and Follow On/Off x[Toggle]", invoke=function() RecordFollowToggle() 
renoise.app().window.active_middle_frame=1 end}
renoise.tool():add_midi_mapping{name="Global:Tools:Delay +1 Increase x[Toggle]", invoke=function() plusdelay(1) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Delay -1 Increase x[Toggle]", invoke=function() plusdelay(-1) end}

--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 0 x[Toggle]",  invoke=function() selectplay(0) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 1 x[Toggle]",  invoke=function() selectplay(1) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 2 x[Toggle]",  invoke=function() selectplay(2) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 3 x[Toggle]",  invoke=function() selectplay(3) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 4 x[Toggle]",  invoke=function() selectplay(4) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 5 x[Toggle]",  invoke=function() selectplay(5) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 6 x[Toggle]",  invoke=function() selectplay(6) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 7 x[Toggle]",  invoke=function() selectplay(7) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 8 x[Toggle]",  invoke=function() selectplay(8) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end} 
renoise.tool():add_midi_mapping{name="Global:Paketti:Simple Play",invoke=function() simpleplay() end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Delay +1 x[Toggle]",invoke=function() columns(1,1) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Delay -1 x[Toggle]",invoke=function() columns(-1,1) end}

renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Panning +1 x[Toggle]",invoke=function() columns(1,2) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Panning -1 x[Toggle]",invoke=function() columns(-1,2) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Volume +1 x[Toggle]",invoke=function() columns(1,3) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Volume -1 x[Toggle]",invoke=function() columns(-1,3) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Effect Number +1 x[Toggle]",invoke=function() columnspart2(1,4) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Effect Number -1 x[Toggle]",invoke=function() columnspart2(-1,4) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Effect Amount +1 x[Toggle]",invoke=function() columnspart2(1,5) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Effect Amount -1 x[Toggle]",invoke=function() columnspart2(-1,5) end}

renoise.tool():add_midi_mapping{name="Global:Paketti:Impulse Tracker Next Pattern x[Toggle]", invoke=function() ImpulseTrackerNextPattern() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Impulse Tracker Previous Pattern x[Toggle]", invoke=function() ImpulseTrackerPrevPattern() end}

--renoise.tool():add_midi_mapping{name="Global:Paketti:Start Playback from Cursor Row x[Toggle]",  invoke=function() ImpulseTrackerPlaySong() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Start Playback x[Toggle]",  invoke=function() ImpulseTrackerPlaySong() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Impulse Tracker F8 Stop Playback (Panic) x[Toggle]",  invoke=function() ImpulseTrackerStop() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Switch to Automation",invoke=function() 
  local w=renoise.app().window
  local raw=renoise.ApplicationWindow
if raw.MIDDLE_FRAME_MIXER == false and w.active_lower_frame == raw.LOWER_FRAME_TRACK_AUTOMATION 
then w.active_middle_frame=raw.MIDDLE_FRAME_MIXER return
else w.active_middle_frame=raw.MIDDLE_FRAME_MIXER end
showAutomation() end}

renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (004) x[Toggle]",invoke=function() slicerough(4) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (008) x[Toggle]",invoke=function() slicerough(8) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (016) x[Toggle]",invoke=function() slicerough(16) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (032) x[Toggle]",invoke=function() slicerough(32) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (064) x[Toggle]",invoke=function() slicerough(64) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (128) x[Toggle]",invoke=function() slicerough(128) end}

renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Disk Browser Focus",invoke=function()
renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(7) end}

renoise.tool():add_midi_mapping{name="Pattern Editor:Paketti:Disk Browser Focus",invoke=function() renoise.app().window:select_preset(8) end}

renoise.tool():add_midi_mapping{name="Global:Paketti:Change Selected Sample Loop Mode [x]Knob",
  invoke = function(midi_message)
    local value = midi_message.int_value
    local loop_modes = {
      [0] = 1,   -- No Loop
      [1] = 2,   -- Forward Loop
      [2] = 3,   -- Backward Loop
      [3] = 4    -- PingPong Loop
    }
    if value == 0 then
      renoise.song().selected_sample.loop_mode = loop_modes[0] -- No Loop
    elseif value >= 1 and value <= 63 then
      renoise.song().selected_sample.loop_mode = loop_modes[1] -- Forward Loop
    elseif value >= 64 and value <= 126 then
      renoise.song().selected_sample.loop_mode = loop_modes[2] -- Backward Loop
    elseif value == 127 then
      renoise.song().selected_sample.loop_mode = loop_modes[3] -- PingPong Loop
    end
  end
}

function selectedSampleLoopTo(loopMode)
renoise.song().selected_sample.loop_mode=loopMode
end

function toggleSelectedSampleLoopTo(loopMode)
      if renoise.song().selected_sample.loop_mode==loopMode
      then renoise.song().selected_sample.loop_mode = 1
      else renoise.song().selected_sample.loop_mode=loopMode
      end
end

renoise.tool():add_midi_mapping{name="Global:Paketti:Selected Sample Loop to 1 No Loop x[On]", invoke=function() selectedSampleLoopTo(1) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Selected Sample Loop to 2 Forward x[On]", invoke=function() selectedSampleLoopTo(2) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Selected Sample Loop to 3 Backward x[On]", invoke=function() selectedSampleLoopTo(3) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Selected Sample Loop to 4 PingPong x[On]", invoke=function() selectedSampleLoopTo(4) end}

renoise.tool():add_midi_mapping{name="Global:Paketti:Selected Sample Loop to 1 No Loop x[Toggle]", invoke=function() toggleSelectedSampleLoopTo(1) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Selected Sample Loop to 2 Forward x[Toggle]", invoke=function() toggleSelectedSampleLoopTo(2) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Selected Sample Loop to 3 Backward x[Toggle]", invoke=function() toggleSelectedSampleLoopTo(3) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Selected Sample Loop to 4 PingPong x[Toggle]", invoke=function() toggleSelectedSampleLoopTo(4) end}

renoise.tool():add_midi_mapping{name="Paketti:Record to Current Track x[Toggle]", invoke=function() 
  recordtocurrenttrack()
  local t=renoise.song().transport
  if t.playing==false then t.playing=true end
  t.loop_block_enabled=false
  t.follow_player=true
  renoise.app().window.active_lower_frame=2
  renoise.app().window.lower_frame_is_visible=true
  -- Uncomment and refine these for specific playback position control if needed:
  -- local startpos = t.playback_pos  
  -- startpos.line = renoise.song().selected_line_index
  -- startpos.sequence = renoise.song().selected_sequence_index
  -- t.playback_pos = startpos
  -- t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
end}

renoise.tool():add_midi_mapping{name="Global:Paketti:Simple Play Record Follow",invoke=function() simpleplayrecordfollow() end}

--------------
function midiEnableDSP(deviceNumber,onOrOff)
if #renoise.song().selected_track.devices < 2 then return
else 
local deviceNumberActual = deviceNumber+1
if #renoise.song().selected_track.devices < deviceNumberActual then return
else
renoise.song().selected_track.devices[deviceNumberActual].is_active = onOrOff
end
end
end

function midiToggleDSP(deviceNumber)

if #renoise.song().selected_track.devices < 2 then return
else 
local deviceNumberActual = deviceNumber+1
if #renoise.song().selected_track.devices < deviceNumberActual then return
else
if renoise.song().selected_track.devices[deviceNumberActual].is_active == true then
renoise.song().selected_track.devices[deviceNumberActual].is_active = false
else
renoise.song().selected_track.devices[deviceNumberActual].is_active = true
end
end
end
end

for i = 1, 9 do 
renoise.tool():add_midi_mapping{name="Global:Paketti:Enable Track DSP Device 0" .. i, invoke=function() midiEnableDSP(i, true) end}
end

for i = 10, 32 do 
renoise.tool():add_midi_mapping{name="Global:Paketti:Enable Track DSP Device " .. i, invoke=function() midiEnableDSP(i, true) end}
end


for i = 1, 9 do 
renoise.tool():add_midi_mapping{name="Global:Paketti:Disable Track DSP Device 0" .. i, invoke=function() midiEnableDSP(i, false) end}
end

for i = 10, 32 do 
renoise.tool():add_midi_mapping{name="Global:Paketti:Disable Track DSP Device " .. i, invoke=function() midiEnableDSP(i, false) end}
end

for i = 1, 9 do 
renoise.tool():add_midi_mapping{name="Global:Paketti:Toggle Track DSP Device 0" .. i, invoke=function() midiToggleDSP(i) end}
end

for i = 10, 32 do 
renoise.tool():add_midi_mapping{name="Global:Paketti:Toggle Track DSP Device " .. i, invoke=function() midiToggleDSP(i) end}
end

-------
renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Change EditStep 1-64 x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
      -- Pass the actual property object, not just the value
      midiValues(1, 64, renoise.song().transport, 'edit_step', message.int_value)
    end
  end}

renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change EditStep 0-64 x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
      -- Pass the actual property object, not just the value
      midiValues(0, 64, renoise.song().transport, 'edit_step', message.int_value)
    end
  end}

-- A function to handle MIDI input and map it to a specified range and property
function midiValues(minValue, maxValue, object, propertyName, midiInput)
  local scaledValue = scaleValue(midiInput, 0, 127, minValue, maxValue)
  -- Set the property on the object using propertyName
  object[propertyName] = math.floor(math.max(minValue, math.min(scaledValue, maxValue)))
end

-- Scales an input value from a given input range to a specified output range
function scaleValue(input, inputMin, inputMax, outputMin, outputMax)
  local scale = (outputMax - outputMin) / (inputMax - inputMin)
  local output = (input - inputMin) * scale + outputMin
  return output
end


function midiMappedEditStep(stepNumber)
renoise.song().transport.edit_step = stepNumber
end

for i=0,9 do
renoise.tool():add_midi_mapping{name="Global:Paketti:Set EditStep to 0" .. i, invoke=function() midiMappedEditStep(i) end}
end

for i=10,64 do
renoise.tool():add_midi_mapping{name="Global:Paketti:Set EditStep to " .. i, invoke=function() midiMappedEditStep(i) end}
end
------
renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Select Group Next",invoke=function(message)
  if message.int_value == 127 then selectNextGroupTrack() end end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Select Group Previous",invoke=function(message)   if message.int_value == 127 then selectPreviousGroupTrack() end end}




renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Select Track Next",invoke=function(message)
  if message.int_value == 127 then selectNextTrack() end end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Select Track Previous",invoke=function(message)   if message.int_value == 127 then selectPreviousTrack() end end}

-----
-- Retrieve all group track indices
function groupTrackIndices()
    local song = renoise.song()
    local indices = {}
    for i = 1, #song.tracks do
        if song.tracks[i].type == renoise.Track.TRACK_TYPE_GROUP then
            table.insert(indices, i)
        end
    end
    return indices
end

-- Function to select a group track by index
function selectGroupTrackByIndex(index)
    local song = renoise.song()
    local groups = groupTrackIndices()
    if #groups > 0 and index >= 1 and index <= #groups then
        song.selected_track_index = groups[index]
    end
end

-- Handle MIDI input and map it to group track selection
function changeGroupTrackWithMidi(message)
    if message:is_abs_value() then
        local group_count = #groupTrackIndices()
        local index = scaleValue(message.int_value, 0, 127, 1, group_count)
        selectGroupTrackByIndex(math.floor(index))
    end
end


renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Select Group Tracks x[Knob]", invoke=changeGroupTrackWithMidi}
--------
renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change 02 Panning Value x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
    renoise.song().selected_track.panning_column_visible=true
      midiValues(0, 128, renoise.song().selected_note_column, 'panning_value', message.int_value)
    end
end}

renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change 03 Delay Value x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
    renoise.song().selected_track.delay_column_visible=true
      midiValues(0, 255, renoise.song().selected_note_column, 'delay_value', message.int_value)
    end
end}

renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change 04 Effect Value x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
      midiValues(0, 255, renoise.song().selected_note_column, 'effect_amount_value', message.int_value)
    end
end}

renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change 01 Volume Value x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
    renoise.song().selected_track.volume_column_visible=true
      midiValues(0, 128, renoise.song().selected_note_column, 'volume_value', message.int_value)
    end
end}
--
renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change Octave x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
      midiValues(0, 8, renoise.song().transport, 'octave', message.int_value)
    end
end}

renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change Selected Track x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
    local trackCount = #renoise.song().tracks
      midiValues(1, trackCount, renoise.song(), 'selected_track_index', message.int_value)
    end
end}

renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change Selected Track DSP Device x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
    local deviceCount = #renoise.song().selected_track.devices
    if deviceCount < 2 then 
    renoise.app():show_status("There are no Track DSP Devices on this channel.")
    else
      midiValues(2, deviceCount, renoise.song(), 'selected_device_index', message.int_value)
    end
    end
end}

renoise.tool():add_midi_mapping {name="Global:Paketti:Midi Change Selected Instrument x[Knob]",
  invoke = function(message)
    if message:is_abs_value() then
    local instrumentCount = #renoise.song().instruments
      midiValues(1, instrumentCount, renoise.song(), 'selected_instrument_index', message.int_value)
    end
end}

