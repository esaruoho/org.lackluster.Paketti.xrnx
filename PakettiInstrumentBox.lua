


function DuplicateInstrumentAndSelectNewInstrument()
local rs=renoise.song()
if renoise.app().window.active_middle_frame==3 then 
local i=rs.selected_instrument_index;rs:insert_instrument_at(i+1):copy_from(rs.selected_instrument);rs.selected_instrument_index=i+1
renoise.app().window.active_middle_frame=3
else
if renoise.app().window.active_middle_frame == 9 then
local i=rs.selected_instrument_index;rs:insert_instrument_at(i+1):copy_from(rs.selected_instrument);rs.selected_instrument_index=i+1
renoise.app().window.active_middle_frame=9
else
local i=rs.selected_instrument_index;rs:insert_instrument_at(i+1):copy_from(rs.selected_instrument);rs.selected_instrument_index=i+1
end
end
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
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Duplicate Instrument and Select Last Instrument",invoke=function() duplicateSelectInstrumentToLastInstrument() end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Duplicate and Reverse Instrument", invoke=function() PakettiDuplicateAndReverseInstrument() end}

-- auto-suspend plugin off:
function autosuspendOFF()
renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.auto_suspend=false
end

renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Switch Plugin AutoSuspend Off",invoke=function() autosuspendOFF() end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices..:Switch Plugin AutoSuspend Off",invoke=function() autosuspendOFF() end}

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

if renoise.song().transport.edit_mode==false then return end

-- Check if a note column is selected
if currColumn==0 then
    renoise.app():show_status("Please Select a Note Column.")
    return
end

    currSample=s.selected_instrument_index-1
    s.patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[currColumn].note_string="C-4"
    s.patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[currColumn].instrument_value=currSample

  if renoise.song().transport.follow_player==false 
    then 
resultant=renoise.song().selected_line_index+renoise.song().transport.edit_step
    if renoise.song().selected_pattern.number_of_lines<resultant
    then renoise.song().selected_line_index=renoise.song().selected_pattern.number_of_lines
    else renoise.song().selected_line_index=renoise.song().selected_line_index+renoise.song().transport.edit_step
    end
  else return
  end

end

for i = 0,9 do
renoise.tool():add_keybinding{name="Global:Paketti:Numpad SelectPlay " .. i,invoke=function() selectPlay(i) end}
end

------------------------------------------------------------------------------------------------------
--cortex.scripts.CaptureOctave v1.1 by cortex
renoise.tool():add_keybinding{name="Global:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end}
renoise.tool():add_keybinding{name="Mixer:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end}
function capture_ins_oct()
renoise.app():show_status("YO!!!")
   local closest_note = {}  
   local current_track=renoise.song().selected_track_index
   local current_pattern=renoise.song().selected_pattern_index
   
   for pos,line in renoise.song().pattern_iterator:lines_in_pattern_track(current_pattern,current_track) do
      if (not line.is_empty) then
         local t={}
         if (renoise.song().selected_note_column_index==0) then
            for i=1,renoise.song().tracks[current_track].visible_note_columns do
               table.insert(t,i)
            end
         else 
            table.insert(t,renoise.song().selected_note_column_index)
         end  
         
         for i,v in ipairs(t) do 
            local notecol=line.note_columns[v]
            
            if ( (not notecol.is_empty) and (notecol.note_string~="OFF")) then
               if (closest_note.oct==nil) then
                  closest_note.oct=math.min(math.floor(notecol.note_value/12),8)
                  closest_note.line=pos.line
                  closest_note.ins=notecol.instrument_value+1
               elseif ( math.abs(pos.line-renoise.song().transport.edit_pos.line) < math.abs(closest_note.line-renoise.song().transport.edit_pos.line) ) then
                  closest_note.oct=math.min(math.floor(notecol.note_value/12),8)
                  closest_note.line=pos.line
                  closest_note.ins=notecol.instrument_value+1
               end         
            end 
         end 
      end 
   end




   if (closest_note.oct~=nil) then 
      if renoise.song().selected_instrument_index == closest_note.ins then
if renoise.app().window.active_middle_frame == 1 and renoise.app().window.active_lower_frame == 2 then
renoise.app().window.active_lower_frame = 1 return end

if renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
then renoise.app().window.active_middle_frame = 1 
renoise.app().window.active_lower_frame = 2 return end


         renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
         return
--         renoise.app().window.active_middle_frame = 1
      else
         -- Set instrument and octave if not already selected
         renoise.song().selected_instrument_index = closest_note.ins
         renoise.song().transport.octave = closest_note.oct
      end
   end

   -- Focus on the pattern editor in the middle frame
   local w = renoise.app().window
   w.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end


-----------------------------------------------------------------------------------------------------------
--[[function emptyslices()
local w=renoise.app().window
local si=renoise.song().selected_instrument
local ss=renoise.song().selected_sample
local ssi=renoise.song().selected_sample_index
  ssi=1
   for i=1,64 do si:insert_sample_at(i) end

   for i=1,64 do renoise.song().selected_instrument.samples[i].name="empty_sampleslot" .. i end

 renoise.song().selected_instrument.name=("Empty Sample Slices" .. renoise.song().selected_instrument_index)
 w.active_middle_frame= 3 end

renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:Create 64 Empty Sample Slots", invoke=function() emptyslices() end}
renoise.tool():add_menu_entry{name="Sample List:Paketti..:Create 64 Empty Sample Slots", invoke=function() emptyslices() end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Create 64 Empty Sample Slots", invoke=function() emptyslices() end}
]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Helper function to ensure the required number of instruments exist, with a max limit of 255 (FE)
local function ensure_instruments_count(count)
  local song = renoise.song()
  local max_instruments = 255  -- Allow creation up to 255 instruments (FE in hex)

  while #song.instruments < count and #song.instruments <= max_instruments do
    song:insert_instrument_at(#song.instruments + 1)
  end
end

-- Function to select the next chunk, properly handling the maximum chunk of FE
local function select_next_chunk()
  local song = renoise.song()
  local current_index = song.selected_instrument_index
  local next_chunk_index = math.floor((current_index - 1) / 16) * 16 + 16 + 1  -- Calculate the next chunk, ensuring alignment

  -- Ensure the next chunk index does not exceed the maximum of 256 (index 255)
  next_chunk_index = math.min(next_chunk_index, 255)

  ensure_instruments_count(next_chunk_index)
  song.selected_instrument_index = next_chunk_index
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Function to select the previous chunk, properly handling lower bounds and correct chunk stepping
local function select_previous_chunk()
  local song = renoise.song()
  local current_index = song.selected_instrument_index

  -- Correctly calculate the previous chunk, ensuring it does not get stuck or fail to decrement
  local previous_chunk_index = math.max(1, math.floor((current_index - 2) / 16) * 16 + 1)

  song.selected_instrument_index = previous_chunk_index
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Function to directly select a specific chunk, limited to FE as the maximum chunk
local function select_chunk(chunk_index)
  local target_index = chunk_index + 1
  ensure_instruments_count(target_index)
  renoise.song().selected_instrument_index = target_index
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Keybindings and MIDI mappings for chunk navigation with your exact naming convention
renoise.tool():add_keybinding { name = "Global:Paketti:Select Next Chunk (00..F0)", invoke = select_next_chunk }
renoise.tool():add_keybinding { name = "Global:Paketti:Select Previous Chunk (00..F0)", invoke = select_previous_chunk }

renoise.tool():add_midi_mapping {
  name = "Paketti:Select Next Chunk (00..FE)",
  invoke = function(message) if message:is_trigger() then select_next_chunk() end end
}

renoise.tool():add_midi_mapping {
  name = "Paketti:Select Previous Chunk (00..FE)",
  invoke = function(message) if message:is_trigger() then select_previous_chunk() end end
}

-- Keybindings and MIDI mappings for selecting specific chunks (00 to F0), with FE as the max chunk
for i = 0, 15 do
  local chunk_hex = string.format("%02X", i * 16)
  local chunk_index = i * 16

  renoise.tool():add_keybinding {
    name = "Global:Paketti:Select Chunk " .. chunk_hex,
    invoke = function() select_chunk(chunk_index) end
  }

  renoise.tool():add_midi_mapping {
    name = "Paketti:Select Chunk " .. chunk_hex,
    invoke = function(message) if message:is_trigger() then select_chunk(chunk_index) end end
  }
end


