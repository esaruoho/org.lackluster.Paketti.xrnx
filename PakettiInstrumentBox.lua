


function DuplicateInstrumentAndSelectNewInstrument()
local rs=renoise.song()
local i=rs.selected_instrument_index;rs:insert_instrument_at(i+1):copy_from(rs.selected_instrument);rs.selected_instrument_index=i+1
end

renoise.tool():add_keybinding{name="Global:Paketti:Duplicate Instrument and Select New Instrument",invoke=function() DuplicateInstrumentAndSelectNewInstrument() end}
renoise.tool():add_keybinding{name="Global:Paketti:Duplicate Instrument and Select New Instrument (2nd)",invoke=function() DuplicateInstrumentAndSelectNewInstrument() end}
renoise.tool():add_keybinding{name="Global:Paketti:Duplicate Instrument and Select New Instrument (3rd)",invoke=function() DuplicateInstrumentAndSelectNewInstrument() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Duplicate Instrument and Select New Instrument",invoke=function() DuplicateInstrumentAndSelectNewInstrument() end}

function duplicateSelectInstrumentToLastInstrument()
local rs=renoise.song()
local n_instruments = #rs.instruments
local src_inst_i = rs.selected_instrument_index
local src_inst = rs:instrument(src_inst_i)

rs:insert_instrument_at(n_instruments)
rs.selected_instrument_index = n_instruments

rs.selected_instrument:copy_from(src_inst)
end

renoise.tool():add_keybinding{name="Global:Paketti:Duplicate Instrument and Select Last Instrument",invoke=function() duplicateSelectInstrumentToLastInstrument() end}


-- auto-suspend plugin off:
function autosuspendOFF()
renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.auto_suspend=false
end

renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Switch Plugin AutoSuspend Off",invoke=function() autosuspendOFF() end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Switch Plugin AutoSuspend Off",invoke=function() autosuspendOFF() end}

-------------------------
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

------------------------------------------------------------------------------------------------------
--cortex.scripts.CaptureOctave v1.1 by cortex
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end}
renoise.tool():add_keybinding{name="Mixer:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end}

function capture_ins_oct()
   local closest_note = {}  
   local current_track=renoise.song().selected_track_index
   local current_pattern=renoise.song().selected_pattern_index
   
   for pos,line in renoise.song().pattern_iterator:lines_in_pattern_track(current_pattern,current_track) do
      if (not line.is_empty) then
   local t={}
   if (renoise.song().selected_note_column_index==0) then
      for i=1,renoise.song().tracks[current_track].visible_note_columns do
         table.insert(t,i) end
   else table.insert(t,renoise.song().selected_note_column_index)   end  
   
   for i,v in ipairs(t) do local notecol=line.note_columns[v]
      
      if ( (not notecol.is_empty) and (notecol.note_string~="OFF")) then
         if (closest_note.oct==nil) then
      closest_note.oct=math.min(math.floor(notecol.note_value/12),8)
      closest_note.line=pos.line
      closest_note.ins=notecol.instrument_value+1
         elseif ( math.abs(pos.line-renoise.song().transport.edit_pos.line) < math.abs(closest_note.line-renoise.song().transport.edit_pos.line)  ) then
      closest_note.oct=math.min(math.floor(notecol.note_value/12),8)
      closest_note.line=pos.line
      closest_note.ins=notecol.instrument_value+1
         end         
      end end end end      
   if (closest_note.oct~=nil) then 
      renoise.song().selected_instrument_index=closest_note.ins
      renoise.song().transport.octave=closest_note.oct end
   
local w = renoise.app().window
-- w.lower_frame_is_visible=true
w.active_middle_frame=1
-- w.active_lower_frame=1 
-- w.upper_frame_is_visible=false
end

-----------------------------------------------------------------------------------------------------------
function emptyslices()
local w=renoise.app().window
local si=renoise.song().selected_instrument
local ss=renoise.song().selected_sample
local ssi=renoise.song().selected_sample_index
  ssi=1
   for i=1,64 do si:insert_sample_at(i) end

   for i=1,64 do renoise.song().selected_instrument.samples[i].name="empty_sampleslot" .. i end

 renoise.song().selected_instrument.name=("multiloopersampler_instrument" .. renoise.song().selected_instrument_index)
 w.active_middle_frame= 2 end

renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Create Empty Sample Slices", invoke=function() emptyslices() end}
--------------------------------------------------------------------------------------------------------------------------------------------------------


