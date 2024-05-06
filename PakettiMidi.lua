-------------------------------------------------------------------------------------------------------------------------------
--Groove Settings, re-written and simplified by mxb
--Control Grooves with a slider
renoise.tool():add_midi_mapping{name = "Paketti:Groove Settings Groove #1 x[Knob]",
  invoke=function(midi_message)
  local ga=renoise.song().transport.groove_amounts
    if not renoise.song().transport.groove_enabled then renoise.song().transport.groove_enabled=true end
    renoise.app().window.active_lower_frame=1
    renoise.song().transport.groove_amounts = {midi_message.int_value/127, ga[2], ga[3], ga[4]}
    end}

renoise.tool():add_midi_mapping{name = "Paketti:Groove Settings Groove #2 x[Knob]",
  invoke=function(midi_message)
  local ga=renoise.song().transport.groove_amounts
    if not renoise.song().transport.groove_enabled then renoise.song().transport.groove_enabled=true end    
    renoise.app().window.active_lower_frame=1
    renoise.song().transport.groove_amounts = {ga[1], midi_message.int_value/127, ga[3], ga[4]}
    end}

renoise.tool():add_midi_mapping{name = "Paketti:Groove Settings Groove #3 x[Knob]",
  invoke=function(midi_message)
  local ga=renoise.song().transport.groove_amounts
    if not renoise.song().transport.groove_enabled then renoise.song().transport.groove_enabled=true end
    renoise.app().window.active_lower_frame=1
    renoise.song().transport.groove_amounts = {ga[1], ga[2], midi_message.int_value/127, ga[4]}
    end}

renoise.tool():add_midi_mapping{name = "Paketti:Groove Settings Groove #4 x[Knob]",
  invoke=function(midi_message)
  local ga=renoise.song().transport.groove_amounts
    if not renoise.song().transport.groove_enabled then renoise.song().transport.groove_enabled=true end
    renoise.app().window.active_lower_frame=1
    renoise.song().transport.groove_amounts = {ga[1], ga[2], ga[3], midi_message.int_value/127}
    end}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Control Computer Keyboard Velocity with a slider.
renoise.tool():add_midi_mapping{name = "Paketti:Computer Keyboard Velocity Slider x[Knob]",
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

renoise.tool():add_midi_mapping {name="Global:Paketti:Show/Hide Pattern Matrix x[Toggle]", invoke=function() showhidepatternmatrix() end}
-----------------------------------------------------------------------------------------------------------------------------------------
renoise.tool():add_midi_mapping {name="Global:Paketti:Record and Follow On/Off x[Knob]", invoke=function(midi_message) 
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
renoise.tool():add_midi_mapping{
name = "Global:Paketti:Record Quantize On/Off x[Toggle]",
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
renoise.tool():add_midi_mapping  {name="Global:Paketti:Simple Play",invoke=function() simpleplay() end}
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


