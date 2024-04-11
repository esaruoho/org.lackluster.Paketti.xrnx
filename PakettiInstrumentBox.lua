function selectplay(number)
local s=renoise.song()
local currPatt=renoise.song().selected_pattern_index
local currTrak=renoise.song().selected_track_index
local currColumn=renoise.song().selected_note_column_index
local currLine=renoise.song().selected_line_index
local currSample=nil 
local resultant=nil

    s.selected_instrument_index=number+1

if renoise.song().transport.edit_mode == false then return else end

    currSample=s.selected_instrument_index-1
    s.patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[currColumn].note_string="C-4"
    s.patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[currColumn].instrument_value=currSample

  if renoise.song().transport.follow_player==false 
    then 
resultant = renoise.song().selected_line_index+renoise.song().transport.edit_step
    if renoise.song().selected_pattern.number_of_lines < resultant
    then renoise.song().selected_line_index = renoise.song().selected_pattern.number_of_lines
    else renoise.song().selected_line_index = renoise.song().selected_line_index+renoise.song().transport.edit_step
    end
  else return
  end

end

renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 0",invoke=function() selectplay(0) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 1",invoke=function() selectplay(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 2",invoke=function() selectplay(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 3",invoke=function() selectplay(3) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 4",invoke=function() selectplay(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 5",invoke=function() selectplay(5) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 6",invoke=function() selectplay(6) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 7",invoke=function() selectplay(7) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 8",invoke=function() selectplay(8) end}
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay 9",invoke=function() selectplay(9) end}

--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 0 x[Toggle]",  invoke=function() selectplay(0) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 1 x[Toggle]",  invoke=function() selectplay(1) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 2 x[Toggle]",  invoke=function() selectplay(2) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 3 x[Toggle]",  invoke=function() selectplay(3) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 4 x[Toggle]",  invoke=function() selectplay(4) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 5 x[Toggle]",  invoke=function() selectplay(5) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 6 x[Toggle]",  invoke=function() selectplay(6) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 7 x[Toggle]",  invoke=function() selectplay(7) end}
--renoise.tool():add_midi_mapping{name="Global:Paketti:Numpad SelectPlay 8 x[Toggle]",  invoke=function() selectplay(8) end}


