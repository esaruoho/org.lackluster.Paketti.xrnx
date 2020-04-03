------------------------------------------------
--This makes sure that when you start Renoise, it switches to preset#1. 
--You will have to actually feed information to Config.XML to get to the specified settings. The settings go like this
--Upper Layer = visible.
--Disk Browser = visible.
--Disk Browser = set to Sample. 
--Cursor Focus is on Disk Browser
--
--Also, this segment makes sure that when you load a sample, and are in Disk Browser Expanded-mode, you are transported
--to the Sample Editor. It's actually fairly buggy so either it works or it doesn't, sometimes it does, mostly it doesn't.
--This is all heavily work in progress.
--------------------------------------------------------------------------------
--Wipes the pattern data, but not the samples or instruments.
--WARNING: Does not reset current filename.
function wipesong()
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
renoise.tool():add_keybinding {name = "Global:Paketti:WipeSong", invoke=function() wipesong() end}
------------------------------------------------------------------------------------------------------------------------------------------
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


--renoise.tool():add_keybinding {name = "Global:Paketti:Stair RecordToCurrent", invoke=function() 
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
--renoise.tool():add_keybinding {name = "Global:Paketti:Stair", invoke=function() stairs() end}
------------------------------------------------------------------------------------------------------------------------------------------------
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
return else end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"
then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00"  
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return end

if renoise.song().transport.edit_mode==true then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"  
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="CF"
return end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"

then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00" 
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return end

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

-----------------------------------------------------------------------------------------------------------------------------------------------
function PakettiCapsLockNoteOff()   
local s=renoise.song()
local wrapping=s.transport.wrapped_pattern_edit
local editstep=s.transport.edit_step

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

renoise.tool():add_keybinding {name="Global:Paketti:Note Off / Caps Lock replacement", invoke=function() 
if renoise.song().transport.wrapped_pattern_edit == false then PakettiCapsLockNoteOffNextPtn() 
else PakettiCapsLockNoteOff() end
end}

------------------------------------------------------------------------------------------------------------------------------------------------
function instrument_is_empty(instrument)
 local inst = renoise.song().instruments[instrument]
 local has_sample_data = false
 for sample in ipairs(inst.samples) do
  has_sample_data = has_sample_data or inst.samples[sample].sample_buffer.has_sample_data
 end
 if inst.plugin_properties.plugin_loaded or inst.midi_output_properties.device_name ~= "" or has_sample_data then return false else return true end
end

function search_empty_instrument()
        local proc = renoise.song()
        for empty_instrument = 1, #proc.instruments do
                local samples = false

                for i = 1,#proc.instruments[empty_instrument].samples do
                        local temp_buffer = proc.instruments[empty_instrument].samples[i].sample_buffer
                        if temp_buffer.has_sample_data then
                                samples = true
                                break
                        end
                end
                local plugin = proc.instruments[empty_instrument].plugin_properties.plugin_loaded
                local midi_device = proc.instruments[empty_instrument].midi_output_properties.device_name
                if ((samples == false) and (plugin == false) and 
                        (midi_device == nil or midi_device == "")) then
                        return empty_instrument
                end
        end
        proc:insert_instrument_at(#proc.instruments+1)
        return #proc.instruments
end
------------------------------------------------------------------------------------------------------------
--This records to currently selected track and outputs 0501 and the c-4 and the selected_instrument
function recordtocurrenttrack()
 local s=renoise.song()
 local ss=s.selected_sample
 local t=renoise.song().transport
 local w=renoise.app().window 
  w.active_lower_frame=2
 local currTrak=s.selected_track_index
 local currSamp=renoise.song().selected_sample_index
    if renoise.song().transport.playing==false then
    renoise.song().transport.playing=true end
    
 local name = nil
    if renoise.song().selected_track_index<10 then 
    name="Track 0"..renoise.song().selected_track_index
    else
    name="Track "..renoise.song().selected_track_index
    end
    
     if renoise.song().tracks[currTrak].name==name
     then renoise.song().tracks[currTrak].name=" 1"
     end
     
       if  renoise.song().tracks[currTrak].name==" 12" then 
 local nexttrack=renoise.song().selected_track_index+1
           renoise.song():insert_track_at(nexttrack)
           renoise.song().selected_track_index=renoise.song().selected_track_index+1
           renoise.song().tracks[renoise.song().selected_track_index].name=" 1"
       end

s.selected_instrument_index = search_empty_instrument()

 w.sample_record_dialog_is_visible=true   
 t:start_stop_sample_recording()
  if ss.sample_buffer_observable:has_notifier(finalrecord) == false then 
     ss.sample_buffer_observable:add_notifier(finalrecord)
     else
     ss.sample_buffer_observable:remove_notifier(finalrecord)
  end
--  delay(3)
--  renoise.song().transport:trigger_sequence(1)
end
------------------------------------------------------------------------------------------------------------------------------------------------
function finalrecord()
  local s=renoise.song()
  local ss=s.selected_sample
  local currTrak=s.selected_track_index
  local currPatt=s.selected_pattern_index
  local currSamp=renoise.song().selected_sample_index
  local currInst=s.selected_instrument_index

  local w=renoise.app().window
  local rightinstrument=nil
  local place=nil 
  local zero=nil
  local o=nil
  local rightinstrument=renoise.song().selected_instrument_index-1
  local nc=s.patterns[currPatt].tracks[currTrak].lines[1].note_columns
  local selnotcol=renoise.song().selected_note_column_index
  local vnc=renoise.song().tracks[currTrak].visible_note_columns

      w.sample_record_dialog_is_visible=false 
      w.active_lower_frame=2
      ss.autoseek=true
      s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
      s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"
              
    for o = 1,12 do 
      if nc[o].note_string=="---" then 
        s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[o].note_string="C-4"
        s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[o].instrument_value=rightinstrument
         if vnc < o then
          s.tracks[currTrak].visible_note_columns=o
          renoise.song().tracks[currTrak].name=" " .. o
         end
        break
      end 
    end
  local t=renoise.song().transport
  local seq=renoise.song().selected_sequence_index
  local startpos = renoise.song().transport.playback_pos  
--t:panic()
--t:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
--  startpos.line = renoise.song().selected_line_index
--  startpos.sequence = renoise.song().selected_sequence_index
--  renoise.song().transport.playback_pos = startpos
--  t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
--  ss.sample_buffer_observable:remove_notifier(finalrecord) 
  if ss.sample_buffer_observable:has_notifier(finalrecord) then 
     ss.sample_buffer_observable:remove_notifier(finalrecord)
     return
  end
  end

renoise.tool():add_midi_mapping{name="Paketti:Record to Current Track x[Toggle]", invoke=function() recordtocurrenttrack() 
   if renoise.song().transport.playing==false then renoise.song().transport.playing=true end
  local seq=renoise.song().selected_sequence_index
  local startpos = renoise.song().transport.playback_pos  
  local t=renoise.song().transport
  t.loop_block_enabled=false
  --t:panic()
  --startpos.line = renoise.song().selected_line_index
  --startpos.sequence = renoise.song().selected_sequence_index
  --renoise.song().transport.playback_pos = startpos
  --t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
 renoise.song().transport.follow_player=true
 renoise.app().window.active_lower_frame=2
 renoise.app().window.lower_frame_is_visible=true
end}

--renoise.tool():add_menu_entry  {name="Pattern Editor:Record To Current", invoke=function() recordtocurrenttrack() end}
--renoise.tool():add_menu_entry  {name="Mixer:RecordToCurrent", invoke=function() recordtocurrenttrack() end}
--renoise.tool():add_menu_entry  {name="Instrument Box:Record To Current", invoke=function() recordtocurrenttrack() end}
--renoise.tool():add_menu_entry  {name="Sample Editor:Record To Current", invoke=function() recordtocurrenttrack() end}
renoise.tool():add_menu_entry  {name="Sample Mappings:Record To Current", invoke=function() recordtocurrenttrack() end}
renoise.tool():add_keybinding  {name="Global:Paketti:Record to Current Track", invoke=function() recordtocurrenttrack() 
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
  if renoise.song().transport.playing==false then renoise.song().transport.playing=true end
 local seq=renoise.song().selected_sequence_index
 local startpos = renoise.song().transport.playback_pos  
 local t=renoise.song().transport
  renoise.song().transport.follow_player=true
 t.loop_block_enabled=false
 renoise.song().transport.follow_player=true
 renoise.app().window.lower_frame_is_visible=true
 renoise.app().window.active_lower_frame=2
 end}



renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:Start Sampling", invoke=function()
if not renoise.song().transport.playing  then renoise.song().transport.playing=true
else end
--------------------------------------------------------------------------------------------------------------------------------------------------------------

recordtocurrenttrack() 
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
  if renoise.song().transport.playing==false then renoise.song().transport.playing=true end
 local seq=renoise.song().selected_sequence_index
 local startpos = renoise.song().transport.playback_pos  
 local t=renoise.song().transport
  renoise.song().transport.follow_player=true
 t.loop_block_enabled=false
 renoise.song().transport.follow_player=true
 renoise.app().window.lower_frame_is_visible=true
 renoise.app().window.active_lower_frame=2
end}

renoise.tool():add_keybinding  {name="Global:Paketti:Record to Current Track w/Metronome", invoke=function() 
if renoise.song().transport.metronome_enabled==false then renoise.song().transport.metronome_enabled=true
else
renoise.song().transport.metronome_enabled=false
end
recordtocurrenttrack() 
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
  if renoise.song().transport.playing==false then renoise.song().transport.playing=true end
 local seq=renoise.song().selected_sequence_index
 local startpos = renoise.song().transport.playback_pos  
 local t=renoise.song().transport
  renoise.song().transport.follow_player=true
--t:panic()
 t.loop_block_enabled=false
 --startpos.line = renoise.song().selected_line_index
 --startpos.sequence = renoise.song().selected_sequence_index
 --renoise.song().transport.playback_pos = startpos
 --t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
 renoise.song().transport.follow_player=true
 renoise.app().window.lower_frame_is_visible=true
 renoise.app().window.active_lower_frame=2
 end}

--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------
--Impulse Tracker "End End" behaviour. If you press End, it takes you to current track's last line,
--If you press End again, it takes you to current_song's last_audio_track's last line.
--Now also obeys Home & End  even if in Master Track
function endend()
local song_pos = renoise.song().transport.edit_pos
local last = renoise.song().sequencer_track_count
if (song_pos.line < renoise.song().selected_pattern.number_of_lines) then
 renoise.song().transport.follow_player = false
 renoise.song().transport.loop_block_enabled=false
 song_pos.line = renoise.song().selected_pattern.number_of_lines
 renoise.song().transport.edit_pos = song_pos
 return
 end
if (renoise.song().selected_track_index < renoise.song().sequencer_track_count) then
renoise.song().transport.follow_player = false
renoise.song().selected_track_index= last
return
end
 renoise.song().transport.follow_player = false
 renoise.song().transport.loop_block_enabled=false
end
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
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

function randombpm()
local prefix=nil
local randombpm = {80, 100, 115, 123, 128, 132, 135, 138, 160}
 math.randomseed(os.time())
  for i = 1, 9 do
      prefix = math.random(1, #randombpm)
      prefix = randombpm[prefix]
      print(prefix)
  end
 renoise.song().transport.bpm=prefix
 WriteToMaster()
end
---------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------
--Four things, two enable all and disable all track dsps on selected channel.
--The other two of the four write 8 effect column's worth of bypass, or enable  the first 8 DSPs to
--Pattern Editor. It's destructive and does not take into consideration anything that is already in
--the effect columns, but might save you some hassle with cpu-hungry multi-part songs :)
function effectbypass()
local number = (table.count(renoise.song().selected_track.devices))
 for i=2,number  do 
  renoise.song().selected_track.devices[i].is_active=false
 end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------

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
--this would be 01 for enabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="00"
 end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function effectenable()
local number = (table.count(renoise.song().selected_track.devices))
for i=2,number  do 
renoise.song().selected_track.devices[i].is_active=true
end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------

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
------------------------------------------------------------------------------------------------------------------------------------------------
function emptyslices()
local si=renoise.song().selected_instrument
local ss=renoise.song().selected_sample
local ssi=renoise.song().selected_sample_index
  ssi=1
   for i=1,64 do si:insert_sample_at(i) end

   for i=1,64 do renoise.song().selected_instrument.samples[i].name="empty_sampleslot" .. i end

 renoise.song().selected_instrument.name=("multiloopersampler_instrument" .. renoise.song().selected_instrument_index)
 w.active_middle_frame= 3 end

renoise.tool():add_menu_entry {name = "Instrument Box:Create empty sample slices", invoke=function() emptyslices()  end}
----------------------------------------------------------------------------------------------------------
--moveup
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
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
------Sampler which returns to sample editor.
function sample_and_to_sample_editor()
  local w=renoise.app().window
  local t=renoise.song().transport
 if w.sample_record_dialog_is_visible==false then
 w.sample_record_dialog_is_visible=true
 t:start_stop_sample_recording()
 else
-- delay(1)
 t:start_stop_sample_recording()
    w.active_upper_frame = 1
    w.active_middle_frame = 5
    w.active_lower_frame = 3
    w.lock_keyboard_focus=true
 end
end
renoise.tool():add_menu_entry {name = "Instrument Box:Start Sampling", invoke=function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible = true end}  
renoise.tool():add_menu_entry {name = "Sample Editor:Start Sampling", invoke=function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible=true end}  
renoise.tool():add_menu_entry {name = "Pattern Editor:Paketti..:Start Sampling", invoke=function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible=true end}  


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Insert 0B00 to first effect_column (destructive)
-- Oct 9th improvement:  If playback on, then step back by 3 rows to let the 0b00 play. if playback off
-- or if follow_off, then just input 0b00 to current_row. You can change the number by anything you like,
-- if you go below edit_pos 1 it will default to edit_pos1 (and playback_pos=1
function upby(number)
local result=nil
local pos = renoise.song().transport.edit_pos
result = pos.line-number
 if result <1 then result = 1
  else print (result)
 end
pos.line = result
renoise.song().transport.edit_pos = pos
renoise.song().transport.playback_pos = pos
end



if renoise.song().transport.playing == true and renoise.song().transport.follow_player==false then
return
elseif renoise.song().transport.playing == true and renoise.song().transport.follow_player==true then
upby(4)
end
 renoise.app().window.active_middle_frame = 1
 renoise.app().window.lock_keyboard_focus=true


if renoise.song().tracks[renoise.song().selected_track_index].max_note_columns==0 then return end

if renoise.song().selected_track.name=="Mst" then 
return
else
renoise.song().selected_note_column_index=1
end

end

function write_effect()
  local s = renoise.song()
  local efc = s.selected_effect_column

    if efc==nil then
         renoise.song().selected_effect_column.number_string="0L"
         renoise.song().selected_effect_column.amount_value=00
      else
      if efc.number_string=="0L" and efc.amount_string=="00" then
         renoise.song().selected_effect_column.number_string="0L"
         renoise.song().selected_effect_column.amount_string="C0"
      else
         renoise.song().selected_effect_column.number_string="0L"
         renoise.song().selected_effect_column.amount_value=00
      end
    end
end

function writeretrig()
  local s = renoise.song()
  local efc = s.selected_effect_column
  local av = renoise.song().transport.lpb * 2
    if efc==nil then
         renoise.song().selected_effect_column.number_string="0R"
         renoise.song().selected_effect_column.amount_value=av
      else
      if efc.number_string=="0R" and efc.amount_value==av then
         renoise.song().selected_effect_column.number_string="00"
         renoise.song().selected_effect_column.amount_string="00"
      else
         renoise.song().selected_effect_column.number_string="00"
         renoise.song().selected_effect_column.amount_value=00
      end
    end
end

renoise.tool():add_keybinding {name = "Global:Paketti:Retrig 0RLPB On/Off", invoke=function() 
renoise.song().selected_effect_column_index=1
writeretrig() 
if renoise.song().selected_track.name=="Mst" then 
return
else
renoise.song().selected_note_column_index=1
end

end} 
--------------------------------------------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------------------------------function soloKey()
local s=renoise.song()
  s.tracks[renoise.song().selected_track_index]:solo()
    if s.transport.playing==false then renoise.song().transport.playing=true end
  s.transport.follow_player=true  
    if renoise.app().window.active_middle_frame~=1 then renoise.app().window.active_middle_frame=1
    end
end

renoise.tool():add_keybinding {name = "Global:Paketti:SoloKey", invoke=function() soloKey() end}

function voloff()
local s = renoise.song()
local efc = s.selected_effect_column
local currTrak=s.selected_track_index
local currLine=s.selected_line_index
local currPatt=s.selected_pattern_index

local ns=efc.number_string
local as=efc.amount_string

      if renoise.song().selected_effect_column=="0000" then
      ns="0L"
      as="00"
      end      
end

renoise.tool():add_keybinding {name = "Global:Paketti:Volume effect 0L00 On/Off", invoke=function() 
renoise.song().selected_effect_column_index=1
write_effect() 
if renoise.song().selected_track.name=="Mst" then return
else renoise.song().selected_note_column_index=1 end
end}
---------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
--esa- 2nd keybind for Record Toggle ON/OFF  with effect_column reading
function RecordToggle()
 local a=renoise.app()
 local s=renoise.song()
 local t=s.transport
 local currentstep=t.edit_step
--if has notifier, dump notifier, if no notifier, add notifier
 if t.edit_mode then
    t.edit_mode = false
 if t.edit_step==0 then
    t.edit_step=1
 else
  return
 end 
 else
      t.edit_mode = true
   if s.selected_effect_column_index == 1  then
      t.edit_step=0
   elseif s.selected_effect_column_index == 0 then
      t.edit_step=currentstep
   return
   end
end
end
----------------------------------------------------------------------------------------------------------

--customized------------------------------------------------------------------------------------------------------------------------

renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Reverb", invoke=function() loadvst("Audio/Effects/AU/aumf:676v:TOGU") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Chorus", invoke=function() loadvst("Audio/Effects/AU/aufx:Chor:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Ultra Simple EQ", invoke=function() loadvst("Audio/Effects/AU/aufx:TILT:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Dub-Delay I", invoke=function() loadvst("Audio/Effects/AU/aumf:aumf:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Dub-Delay II", invoke=function() loadvst("Audio/Effects/AU/aumf:dub2:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Dub-Delay III",invoke=function() loadvst("Audio/Effects/AU/aumf:xg70:TOGU") end}

----------------------------------------------------------------------------------------------------------
-- :::::Automation ExpCurve
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


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-- In which we bind things together for all time
----------------------------------------------------------------------------------------------------------
-- Midi
renoise.tool():add_midi_mapping {name="Global:Paketti:Start Playback from Cursor Row x[Toggle]",  invoke=function() ImpulseTrackerPlaySong() end}
renoise.tool():add_midi_mapping {name="Global:Paketti:Play Current Line & Advance by EditStep x[Toggle]",  invoke=function() PlayCurrentLine() end}
--------------------------------------------------------------------------------------------------------------------------------------------
-- Menu Entries
renoise.tool():add_menu_entry {name="Track Automation:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
renoise.tool():add_menu_entry {name="Track Automation List:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
renoise.tool():add_menu_entry {name="DSP Device Automation:Follow Off", invoke=function() renoise.song().transport.follow_player=false end}  
-- Track Automation
renoise.tool():add_menu_entry {name="Track Automation:Paketti..:Start Pattern Follow", invoke=function() renoise.song().transport.follow_player=true end}  
renoise.tool():add_menu_entry {name="Track Automation:Paketti..:Stop Pattern Follow", invoke=function() renoise.song().transport.follow_player=false end}  
-- Pattern Matrix
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Bypass EFX", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Enable EFX", invoke=function() effectenable() end}
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Bypass EFX (Write to Pattern)", invoke=function() effectbypasspattern()  end}
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Enable EFX (Write to Pattern)", invoke=function() effectenablepattern() end}
-- Pattern Sequencer
renoise.tool():add_menu_entry {name="Pattern Sequencer:Show/Hide Pattern Matrix", invoke=function() showhidepatternmatrix() end}
-- Pattern Editor
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Renoise Random BPM & Write BPM/LPB to Master",   invoke=function() randombpm()  end}
renoise.tool():add_menu_entry {name="--Pattern Editor:Paketti..:Bypass EFX", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Enable EFX", invoke=function() effectenable() end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Bypass EFX (Write to Pattern)", invoke=function() effectbypasspattern() end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Enable EFX (Write to Pattern)", invoke=function() effectenablepattern()  end}
--------------------------------------------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding {name="Global:Paketti:Sample NOW then F3", invoke=function() sample_and_to_sample_editor()   end  }

renoise.tool():add_keybinding {name="Global:Paketti:Loop Block Backwards", invoke=function() loopblockback() end}
renoise.tool():add_keybinding {name="Global:Paketti:Loop Block Forwards", invoke=function() loopblockforward() end}
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-- Esa Ruoho http://www.lackluster.org esaruoho@gmail.com
-- 2011 October-November-December
function mapsample()

end

renoise.tool():add_menu_entry {name = "Sample Editor:Map Sample to All Keyzones", invoke=function() mapsample() end}
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function something()
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
renoise.tool():add_menu_entry {name = "Sample Editor:Ding", invoke=function() something() end}
------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

function WipeEfxFromSelection()
local ecvisible=nil

if renoise.song().selection_in_pattern==nil then return
else end
ecvisible=renoise.song().tracks[renoise.song().selected_track_index].visible_effect_columns

for i=renoise.song().selection_in_pattern.start_line,renoise.song().selection_in_pattern.end_line do renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[ecvisible].number_string="" 
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[ecvisible].amount_string=""
end
end
--renoise.tool():add_keybinding {name = "Pattern Editor:Paketti:Delete/Wipe Effects From Selection", invoke=function() WipeEfxFromSelection() end} <- confirmed as not working
----------------------------------------------------------------------------------------------------------------------------------------
function muteUnmuteNoteColumn()
local s = renoise.song()
local sti = s.selected_track_index
local snci = s.selected_note_column_index

if s.selected_note_column_index == 0 
  then return else
if s:track(sti):column_is_muted(snci) == true
  then s:track(sti):mute_column(snci, false)
else s:track(sti):mute_column(snci, true) end end
end

--renoise.tool():add_keybinding {name = "Global:Paketti:Mute Unmute Notecolumn", invoke=function() muteUnmuteNoteColumn() end} <- confirmed as not working
----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------

--[[
function PakettiDelete()   
local s=renoise.song()

if s.selected_note_column_index == 0 then 
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[s.selected_effect_column_index].amount_value=0
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[s.selected_effect_column_index].number_value=0
return
else end

if s.selected_note_column_index > 0 then

s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="---"
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].instrument_string=".."
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].panning_string=".."
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].delay_string=".."
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].volume_string=".."
else
end
end

renoise.tool():add_keybinding {name="Pattern Editor:Paketti:Delete replacement", invoke=function() PakettiDelete() end}
renoise.tool():add_keybinding {name="Pattern Editor:Paketti:Delete replacement 2nd", invoke=function() PakettiDelete() end}
-----------------------------------------------------------------------------------------------------------------------------------------
function ClearRow()
 local s=renoise.song()
 local currTrak=s.selected_track_index
 local currPatt=s.selected_pattern_index
 local currLine=nil

-- this does not work with phrase editor so stop using it altogether
if renoise.app().window.active_middle_frame == 1 and not renoise.song().instruments[s.selected_instrument_index].phrase_editor_visible then
 currLine = renoise.song().selected_line_index -- -1  
 if currLine < 1 then currLine = 1 end
 for i=1,8 do
 renoise.song().patterns[currPatt].tracks[currTrak].lines[currLine].effect_columns[i]:clear()
 end
 for i=1,12 do
 renoise.song().patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[i]:clear()
 end
else end 

end

renoise.tool():add_keybinding {name = "Global:Paketti:Clear Current Row", invoke=function() ClearRow() end}
renoise.tool():add_keybinding {name = "Global:Paketti:Clear Current Row 2nd", invoke=function() ClearRow() end}
--]]
-----------------------------------------------------------------------------------------------------------------------------------------
