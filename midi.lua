---------------------------------------------------------------------------------------------------------------------------------------------------
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

  local s=renoise.song()
  if s.transport.keyboard_velocity_enabled==false then
     s.transport.keyboard_velocity_enabled=true end
     s.transport.keyboard_velocity= midi_message.int_value end}
     
------------------------------------------------------------------------------------------------------------------------------------------- Show or hide pattern matrix
function showhidepatternmatrix()
local w=renoise.app().window
      if w.pattern_matrix_is_visible==true then 
      w.pattern_matrix_is_visible=false else
      w.pattern_matrix_is_visible=true
      end
end

renoise.tool():add_midi_mapping {name="Global:Paketti:Show/Hide Pattern Matrix x[Toggle]", invoke=function() showhidepatternmatrix() end}
-----------------------------------------------------------------------------------------------------------------------------------------
renoise.tool():add_midi_mapping {name="Global:Paketti:Record and Follow On/Off x[Knob]", invoke=function(midi_message) 
--Aided by dblue
 local t=renoise.song().transport

if (midi_message.int_value == 127) then t.edit_mode = true t.follow_player = true t.playing = true
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR 
  renoise.app().window.lock_keyboard_focus = true
else end
if (midi_message.int_value == 0) then t.edit_mode = false t.follow_player = false t.playing = false
else end

    if (midi_message.int_value >= 100) then
      t.edit_mode = true
      t.follow_player = true 
      renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR 
      renoise.app().window.lock_keyboard_focus = true      
    else 
      t.edit_mode = false
      t.follow_player = false
    end
end}
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

