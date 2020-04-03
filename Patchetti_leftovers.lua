local function has_line_input()
-- Write some code to find the line input in the correct place
local tr = renoise.song().selected_track
 if tr.devices[2] and tr.devices[2].device_path=="Audio/Effects/Native/#Line Input" 
  then return true
 else
  return false
 end
end

local function add_line_input()
-- Write some code to add the line input in the correct place
 loadnative("Audio/Effects/Native/#Line Input")
end

local function remove_line_input()
-- Write some code to remove the line input if it's in the correct place
 renoise.song().selected_track:delete_device_at(2)
end


local function recordamagig9000(running)
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

renoise.tool():add_keybinding {name="Global:Paketti:Recordamajig9000",
invoke = function()
 if has_line_input() then
    recordtocurrenttrack()    
    G01()
 else
    add_line_input()
    recordtocurrenttrack()
 end
end}

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

else
renoise.app().window.sample_record_dialog_is_visible=false
  if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  end
end

end

renoise.tool():add_keybinding {name = "Global:Paketti:Display Sample Recorder with #Line Input", invoke = function() SampleRecorderOn() end}

function recOffFollowOn()
  renoise.song().transport.edit_mode=false
  renoise.song().transport.follow_player=true
  renoise.song().transport.playing=true
end

function recOnFollowOff()
renoise.song().transport.edit_mode=true
renoise.song().transport.follow_player=false
renoise.song().transport.wrapped_pattern_edit=true
renoise.app().window.active_middle_frame=1
end

renoise.tool():add_keybinding {name = "Global:Paketti:Contour Shuttle Record Off", invoke = function() recOffFollowOn() end}
renoise.tool():add_keybinding {name = "Global:Paketti:Contour Shuttle Record On", invoke = function() recOnFollowOff() end}


function KeybOctave(amount)
local t = renoise.song().transport
t.octave= (t.octave + amount) % 9
end

renoise.tool():add_keybinding {name = "Global:Paketti:KeybOctave Up", invoke = function() KeybOctave(1) end}
renoise.tool():add_keybinding {name = "Global:Paketti:KeybOctave Down", invoke = function() KeybOctave(-1) end}

function OctTranspose(UpOrDown)
local note_column = renoise.song().selected_note_column 
note_column.note_value = (note_column.note_value +UpOrDown) % 120
end
renoise.tool():add_keybinding {name = "Pattern Editor:Paketti:Transpose Octave Up", invoke = function() OctTranspose(12) end}
renoise.tool():add_keybinding {name = "Pattern Editor:Paketti:Transpose Octave Down", invoke = function() OctTranspose(-12) end}

function AutoFilter()
--renoise.song().tracks[get_master_track_index()].visible_effect_columns = 4  
renoise.app().window.active_lower_frame=1
renoise.app().window.lower_frame_is_visible=true
  loadnative("Audio/Effects/Native/Filter")
  loadnative("Audio/Effects/Native/*LFO")
  renoise.song().selected_track.devices[2].parameters[2].value=2
  renoise.song().selected_track.devices[2].parameters[3].value=1
end

function AutoGapper()
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

renoise.tool():add_keybinding {name = "Global:Paketti:Add Filter & LFO (AutoFilter)", invoke = function() AutoFilter() end}
renoise.tool():add_keybinding {name = "Global:Paketti:Add Filter & LFO (AutoGapper)", invoke = function() AutoGapper() end}


function JumpToNextRow()
local LineGoTo = nil

LineGoTo = renoise.song().selected_line_index


renoise.song().tracks[get_master_track_index()].visible_effect_columns = 4
if renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[3].number_string == "ZB"
then
renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[3].number_string = ""
renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[3].amount_string  = ""
return
end


renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[3].number_string = "ZB"

if renoise.song().selected_line_index > 255 then LineGoTo = 00 end

renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[3].amount_value  = LineGoTo
end

renoise.tool():add_keybinding {name = "Global:Paketti:Write Jump To Next Row (ZBxx)", invoke = function() JumpToNextRow() end}

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

--from http://lua-users.org/lists/lua-l/2004-09/msg00054.html thax!
function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end
--from http://lua-users.org/lists/lua-l/2004-09/msg00054.html thax!

function ploo()
local rs=renoise.song()
local n_instruments = #rs.instruments
local src_inst_i = rs.selected_instrument_index
local src_inst = rs:instrument(src_inst_i)

rs:insert_instrument_at(n_instruments)
rs.selected_instrument_index = n_instruments

rs.selected_instrument:copy_from(src_inst)
end

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
local s = nil

function startup_()
  local s=renoise.song()
   renoise.app().window:select_preset(1)
   
 
   renoise.song().instruments[s.selected_instrument_index].active_tab=1
    if renoise.app().window.active_middle_frame==0 and s.selected_sample.sample_buffer_observable:has_notifier(sample_loaded_change_to_sample_editor) then 
    s.selected_sample.sample_buffer_observable:remove_notifier(sample_loaded_change_to_sample_editor)
    else
  --jep  --s.selected_sample.sample_buffer_observable:add_notifier(sample_loaded_change_to_sample_editor)

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
renoise.tool():add_keybinding {name = "Global:Paketti:WipeSong", invoke = function() wipesong() end}

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


--renoise.tool():add_keybinding {name = "Global:Paketti:Stair RecordToCurrent", invoke = function() 
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
--renoise.tool():add_keybinding {name = "Global:Paketti:Stair", invoke = function() stairs() end}

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

renoise.tool():add_keybinding {name="Global:Paketti:Note Off / Caps Lock replacement", invoke = function() 
if renoise.song().transport.wrapped_pattern_edit == false then PakettiCapsLockNoteOffNextPtn() 
else PakettiCapsLockNoteOff() end
end}

function PakettiDelete()   
local s=renoise.song()
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="---"
end

renoise.tool():add_keybinding {name="Global:Paketti:Delete replacement", invoke = function() PakettiDelete() end}

---------------------------------
function instrument_is_empty(instrument)
 local inst = renoise.song().instruments[instrument]
 local has_sample_data = false
 for sample in ipairs(inst.samples) do
  has_sample_data = has_sample_data or inst.samples[sample].sample_buffer.has_sample_data
 end
 if inst.plugin_properties.plugin_loaded or inst.midi_output_properties.device_name ~= "" or has_sample_data then return false else return true end
end

------------------------------------------------------------------------------------------------------------
function recordtocurrenttrack()
 local s=renoise.song()
 local ss=s.selected_sample
 
 local t=renoise.song().transport
 local w=renoise.app().window 
  w.active_lower_frame=1
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
     then renoise.song().tracks[currTrak].name=" 1" end
     
       if renoise.song().tracks[currTrak].name==" 12" then 
 local nexttrack=renoise.song().selected_track_index+1
           renoise.song():insert_track_at(nexttrack)
           renoise.song().selected_track_index=renoise.song().selected_track_index+1
           renoise.song().tracks[renoise.song().selected_track_index].name=" 1"
       end

  s.selected_instrument_index = search_empty_instrument() -- make sure this function is available
  w.sample_record_dialog_is_visible=true   
  t:start_stop_sample_recording()
  
  if ss.sample_buffer_observable:has_notifier(finalrecord) == false then 
     ss.sample_buffer_observable:add_notifier(finalrecord)
     else
     ss.sample_buffer_observable:remove_notifier(finalrecord)     
  end
end
  
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
      remove_line_input()
      -- error if nil
      w.active_lower_frame=1
      ss.autoseek=true

  local rightinstrument=renoise.song().selected_instrument_index-1
      ss.autoseek=true
      
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

  if ss.sample_buffer_observable:has_notifier(finalrecord) then 
     ss.sample_buffer_observable:remove_notifier(finalrecord) end
end

renoise.tool():add_keybinding  {name="Global:Paketti:Record to Current Track+plus", 
invoke = function() 
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
end

end
end}

---------------


renoise.tool():add_midi_mapping{name="Paketti:Record to Current Track x[Toggle]", invoke = function() recordtocurrenttrack() 
 if renoise.song().transport.playing==false then renoise.song().transport.playing=true end
 renoise.song().transport.loop_block_enabled=false
 renoise.song().transport.follow_player=true
 renoise.app().window.active_lower_frame=2
 renoise.app().window.lower_frame_is_visible=true
end}

renoise.tool():add_menu_entry  {name="Sample Mappings:Record To Current", invoke = function() recordtocurrenttrack() end}

renoise.tool():add_keybinding  {name="Global:Paketti:Record to Current Track", invoke = function() recordtocurrenttrack() 
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

renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:Start Sampling", invoke = function()
if not renoise.song().transport.playing  then renoise.song().transport.playing=true
else end
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



renoise.tool():add_keybinding  {name="Global:Paketti:Record to Current Track w/Metronome", invoke = function() 
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

----------------------------------------------------------------------------------------------------------
-- Set current tempo to 75% of current tempo. Set current tempo back to the original 100% tempo.
-- Writes the currently set (75% or 100%) BPM / LPB to the Master effect_column. Takes effect immediately.
function get_master_track_index()
  for k,v in ripairs(renoise.song().tracks)
    do if v.type == renoise.Track.TRACK_TYPE_MASTER then return k end  
  end
end

function WriteToMaster()
 local column_index = renoise.song().selected_effect_column_index
 local t=renoise.song().transport
 if renoise.song().transport.bpm < 256 then -- safety check
 renoise.song().tracks[get_master_track_index()].visible_effect_columns = 4
    
    if renoise.song().selected_effect_column_index <= 1 then column_index = 2 end
    
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].number_string = "ZT"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].amount_value  = t.bpm
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].number_string = "ZL"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].amount_value  = t.lpb
    end
-- † --
 end

function playat75()
 renoise.song().transport.bpm=renoise.song().transport.bpm*0.75
 WriteToMaster()
 renoise.app():show_status("BPM set to 75% (" .. renoise.song().transport.bpm .. "BPM)") 
end

function returnbackto100()
 renoise.song().transport.bpm=renoise.song().transport.bpm/0.75
 WriteToMaster()
 renoise.app():show_status("BPM set back to 100% (" .. renoise.song().transport.bpm .. "BPM)") 
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

renoise.tool():add_menu_entry {name = "Pattern Matrix:Paketti..:Play at 75% Speed (Song BPM)", invoke = function() playat75() end}
renoise.tool():add_menu_entry {name = "Pattern Matrix:Paketti..:Play at 100% Speed (Song BPM)", invoke = function() returnbackto100()  end}
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

function effectenable()
local number = (table.count(renoise.song().selected_track.devices))
for i=2,number  do 
renoise.song().selected_track.devices[i].is_active=true
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
---------------------------------------------------------------------------------------------------------------
renoise.tool():add_menu_entry {name = "Instrument Box:Create empty sample slices", invoke = function() emptyslices()  end}

function emptyslices()
local si=renoise.song().selected_instrument
local ss=renoise.song().selected_sample
local ssi=renoise.song().selected_sample_index
local w=renoise.app().window
  ssi=1
   for i=1,64 do
    si:insert_sample_at(i)
   end

   for i=1,64 do 
    renoise.song().selected_instrument.samples[i].name="empty_sampleslot" .. i
   end

 renoise.song().selected_instrument.name=("multiloopersampler_instrument" .. renoise.song().selected_instrument_index)
 w.active_middle_frame= 3
end
---------------------------------------------------------------------------------------------------------------
--Set the next ReWire channel - shortcut. If you have a pre-configured 32 input rewire master host
--running, you can just press a shortcut and get it to play in the track of your choice (on your
--master host that is). This is a really simple thing, but it works after a fashion and does
--what I wanted it to do.
function next_rewire()
local current=renoise.song().selected_track.output_routing
local st=renoise.song().selected_track
if current=="Master Track" then renoise.song().selected_track.output_routing="Bus 01 L/R"
elseif current=="Bus 01 L/R" then st.output_routing="Bus 02 L/R"
elseif current=="Bus 02 L/R" then st.output_routing="Bus 03 L/R"
elseif current=="Bus 03 L/R" then st.output_routing="Bus 04 L/R"
elseif current=="Bus 04 L/R" then st.output_routing="Bus 05 L/R"
elseif current=="Bus 05 L/R" then st.output_routing="Bus 06 L/R"
elseif current=="Bus 06 L/R" then st.output_routing="Bus 07 L/R"
elseif current=="Bus 07 L/R" then st.output_routing="Bus 08 L/R"
elseif current=="Bus 08 L/R" then st.output_routing="Bus 09 L/R"
elseif current=="Bus 09 L/R" then st.output_routing="Bus 10 L/R"
elseif current=="Bus 10 L/R" then st.output_routing="Bus 11 L/R"
elseif current=="Bus 11 L/R" then st.output_routing="Bus 12 L/R"
elseif current=="Bus 12 L/R" then st.output_routing="Bus 13 L/R"
elseif current=="Bus 13 L/R" then st.output_routing="Bus 14 L/R"
elseif current=="Bus 14 L/R" then st.output_routing="Bus 15 L/R"
elseif current=="Bus 15 L/R" then st.output_routing="Bus 16 L/R"
elseif current=="Bus 16 L/R" then st.output_routing="Bus 17 L/R"
elseif current=="Bus 17 L/R" then st.output_routing="Bus 18 L/R"
elseif current=="Bus 18 L/R" then st.output_routing="Bus 19 L/R"
elseif current=="Bus 19 L/R" then st.output_routing="Bus 20 L/R"
elseif current=="Bus 20 L/R" then st.output_routing="Bus 21 L/R"
elseif current=="Bus 21 L/R" then st.output_routing="Bus 22 L/R"
elseif current=="Bus 22 L/R" then st.output_routing="Bus 23 L/R"
elseif current=="Bus 23 L/R" then st.output_routing="Bus 24 L/R"
elseif current=="Bus 24 L/R" then st.output_routing="Bus 25 L/R"
elseif current=="Bus 25 L/R" then st.output_routing="Bus 26 L/R"
elseif current=="Bus 26 L/R" then st.output_routing="Bus 27 L/R"
elseif current=="Bus 27 L/R" then st.output_routing="Bus 28 L/R"
elseif current=="Bus 28 L/R" then st.output_routing="Bus 29 L/R"
elseif current=="Bus 29 L/R" then st.output_routing="Bus 30 L/R"
elseif current=="Bus 30 L/R" then st.output_routing="Bus 31 L/R"
elseif current=="Bus 31 L/R" then st.output_routing="Master Track"
end
renoise.app():show_status("Current Track output set to: " .. st.output_routing) 
end
----------------------------------------------------------------------------------------------------------
--Record Quantize On/Off for Midi_Mapping
renoise.tool():add_midi_mapping{
name = "Global:Paketti:Record Quantize On/Off x[Toggle]",
invoke = function()
  if renoise.song().transport.record_quantize_enabled==true then
     renoise.song().transport.record_quantize_enabled=false
  else
     renoise.song().transport.record_quantize_enabled=true
   end
end}
----------------------------------------------------------------------------------------------------------
--BPM +1 / -1
function adjust_bpm(bpm_delta)
  local t = renoise.song().transport
  t.bpm = math.max(32, math.min(999, t.bpm + bpm_delta))
renoise.app():show_status("BPM : " .. t.bpm)
end
----------------------------------------------------------------------------------------------------------
--Quantize +1 / -1
function adjust_quantize(quant_delta)
  local t = renoise.song().transport
  local counted = nil
  counted=t.record_quantize_lines+quant_delta
  if counted == 0 then
  t.record_quantize_enabled=false return else end
  
  if t.record_quantize_enabled==false and t.record_quantize_lines == 1 then
  t.record_quantize_lines = 1
  t.record_quantize_enabled=true
  return
  else end  
    t.record_quantize_lines=math.max(1, math.min(32, t.record_quantize_lines + quant_delta))
    t.record_quantize_enabled=true
renoise.app():show_status("Record Quantize Lines : " .. t.record_quantize_lines)
end
----------------------------------------------------------------------------------------------------------
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
-- Write BPM. version 2.7.0 -syflom -LPB alteration on 15th June 2011 -esaruoho
function get_master_track_index()
  for k,v in ripairs(renoise.song().tracks)
    do if v.type == renoise.Track.TRACK_TYPE_MASTER then return k end  
  end
end

function write_bpm()
  if renoise.song().transport.bpm < 256 then -- safety check
    local column_index = renoise.song().selected_effect_column_index
    local t=renoise.song().transport
  renoise.song().tracks[get_master_track_index()].visible_effect_columns = 4  
    
    if renoise.song().selected_effect_column_index <= 1 then column_index = 2 end
    
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].number_string = "ZT"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].amount_value  = t.bpm
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].number_string = "ZL"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].amount_value  = t.lpb
  end
end
-- † --
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
    w.active_middle_frame = 4
    w.active_lower_frame = 3
    w.lock_keyboard_focus=true
 end
end
renoise.tool():add_menu_entry {name = "Instrument Box:Start Sampling", invoke = function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible = true end}  
renoise.tool():add_menu_entry {name = "Sample Editor:Start Sampling", invoke = function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible=true end}  
renoise.tool():add_menu_entry {name = "Pattern Editor:Paketti..:Start Sampling", invoke = function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible=true end}  
----------------------------------------------------------------------------------------------------------
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

renoise.tool():add_keybinding {name = "Global:Paketti:Retrig 0RLPB On/Off", invoke = function() 
renoise.song().selected_effect_column_index=1
writeretrig() 
if renoise.song().selected_track.name=="Mst" then 
return
else
renoise.song().selected_note_column_index=1
end

end} 

renoise.tool():add_keybinding {name = "Global:Paketti:SoloKey", invoke = function() soloKey() end}


renoise.tool():add_keybinding {name = "Global:Paketti:Volume effect 0L00 On/Off", invoke = function() 
renoise.song().selected_effect_column_index=1
write_effect() 
if renoise.song().selected_track.name=="Mst" then 
return
else
renoise.song().selected_note_column_index=1 end end} 

function soloKey()
local s=renoise.song()
  s.tracks[renoise.song().selected_track_index]:solo()
    if s.transport.playing==false then renoise.song().transport.playing=true
    end
       s.transport.follow_player=true
    
    if renoise.app().window.active_middle_frame~=1 then renoise.app().window.active_middle_frame=1
    end
end

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
-- Show or hide pattern matrix
function showhidepatternmatrix()
local w=renoise.app().window
      if w.pattern_matrix_is_visible==true then 
      w.pattern_matrix_is_visible=false else
      w.pattern_matrix_is_visible=true
      end
end
---------------------------------------------------------------------------------------------------------
function delete_effect_column()
local s=renoise.song()
local currTrak = s.selected_track_index
local currPatt = s.selected_pattern_index
local reksult = s.selected_pattern.number_of_lines
local iter = s.pattern_iterator:effect_columns_in_pattern_track(currPatt,currTrak)
  for _,line in iter do
   if not line.is_empty then
   line:clear()
   end
  end
end
----------------------------------------------------------------------------------------------------------
function LoopSet(number)
local loop_modet = renoise.song().selected_sample.loop_mode
  if renoise.song().selected_sample.loop_mode==number then renoise.song().selected_sample.loop_mode=1 else loop_modet = number
  renoise.song().selected_sample.loop_mode=loop_modet
  end
end

function OpenSelectedEffectExternalEditor()
local s=renoise.song()
if not s.selected_track.devices[s.selected_device_index].external_editor_visible then
       s.selected_track.devices[s.selected_device_index].external_editor_visible=true
  else s.selected_track.devices[s.selected_device_index].external_editor_visible=false
end
end
----------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Reverb", invoke = function() loadvst("Audio/Effects/AU/aumf:676v:TOGU") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Chorus", invoke = function() loadvst("Audio/Effects/AU/aufx:Chor:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Ultra Simple EQ", invoke = function() loadvst("Audio/Effects/AU/aufx:TILT:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Dub-Delay I", invoke=function() loadvst("Audio/Effects/AU/aumf:aumf:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Dub-Delay II", invoke=function() loadvst("Audio/Effects/AU/aumf:dub2:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TOGU Audioline Dub-Delay III",invoke=function() loadvst("Audio/Effects/AU/aumf:xg70:TOGU") end}

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

--EZMaximizeSpectrum
--December 15, 2011, Renoise 2.8 B2
--esaruoho
function EZMaximizeSpectrum()
local s=renoise.song()
local t=s.transport
local w=renoise.app().window
  if t.playing==false then
     t.playing=true
  end

w.disk_browser_is_expanded=true
w.active_upper_frame=4
w.upper_frame_is_visible=true
w.lower_frame_is_visible=false

renoise.app():show_status("Current BPM: " .. renoise.song().transport.bpm .. " Current LPB: " .. renoise.song().transport.lpb .. ". You are feeling fine. Playback started.")
end

renoise.tool():add_keybinding {name="Global:Paketti:EZ Maximize Spectrum", invoke = function() EZMaximizeSpectrum() end}
renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:EZ Maximize Spectrum", invoke = function() EZMaximizeSpectrum() end}
renoise.tool():add_menu_entry {name="Mixer:EZ Maximize Spectrum", invoke = function() EZMaximizeSpectrum() end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:EZ Maximize Spectrum", invoke = function() EZMaximizeSpectrum() end}
--------------------------------------
----------------------------------------------------------------------------------------------------------
-- Midi
renoise.tool():add_midi_mapping {name="Global:Paketti:Start Playback from Cursor Row x[Toggle]",  invoke = function() ImpulseTrackerPlaySong() end}
renoise.tool():add_midi_mapping {name="Global:Paketti:Stop Playback (Panic) x[Toggle]",  invoke = function() ImpulseTrackerStop() end}
renoise.tool():add_midi_mapping {name="Global:Paketti:Play Current Line & Advance by EditStep x[Toggle]",  invoke = function() PlayCurrentLine() end}
renoise.tool():add_midi_mapping {name="Global:Paketti:Show/Hide Pattern Matrix x[Toggle]", invoke = function() showhidepatternmatrix() end}
renoise.tool():add_midi_mapping {name="Global:Paketti:Record and Follow On/Off x[Toggle]", invoke = function() RecordFollowToggle() 
renoise.app().window.active_middle_frame=1 end}
renoise.tool():add_midi_mapping {name="Global:Paketti:Metronome On/Off x[Toggle]", invoke = function() MetronomeOff() end}
renoise.tool():add_midi_mapping {name="Global:Tools:Delay +1 Increase x[Toggle]", invoke = function() plusdelay(1) end}
renoise.tool():add_midi_mapping {name="Global:Tools:Delay -1 Increase x[Toggle]", invoke = function() plusdelay(-1) end}
------------------------------------------------------------------------------------------------------
-- Menu Entries
-- Pattern Matrix
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Bypass EFX", invoke = function() effectbypass() end}
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Enable EFX", invoke = function() effectenable() end}
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Bypass EFX (Write to Pattern)", invoke = function() effectbypasspattern()  end}
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Enable EFX (Write to Pattern)", invoke = function() effectenablepattern() end}
-- Pattern Sequencer
renoise.tool():add_menu_entry {name="Pattern Sequencer:Show/Hide Pattern Matrix", invoke = function() showhidepatternmatrix() end}
-- Pattern Editor
renoise.tool():add_menu_entry {name="--Pattern Editor:Paketti..:Write Current BPM&LPB to Master column",   invoke = function() write_bpm() end }
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Renoise Random BPM & Write BPM/LPB to Master",   invoke = function() randombpm()  end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Play at 75% Speed (Song BPM)", invoke = function() playat75()  end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Play at 100% Speed (Song BPM)", invoke = function() returnbackto100()  end}
renoise.tool():add_menu_entry {name="--Pattern Editor:Paketti..:Bypass EFX", invoke = function() effectbypass() end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Enable EFX", invoke = function() effectenable() end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Bypass EFX (Write to Pattern)", invoke = function() effectbypasspattern() end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Enable EFX (Write to Pattern)", invoke = function() effectenablepattern()  end}
------------------------------------------------------------------------------------------------
--- Keybinds
renoise.tool():add_keybinding {name="Global:Paketti:Play Current Line & Advance by EditStep",  invoke = function() PlayCurrentLine() end}
renoise.tool():add_keybinding {name="Global:Paketti:Record+Follow+Metronome Toggle", invoke = function() RecordFollowMetronomeToggle() end}

renoise.tool():add_keybinding {name="Global:Paketti:Set Next ReWire channel", invoke = function() next_rewire() end  }
renoise.tool():add_keybinding {name="Global:Paketti:Sample NOW then F3", invoke = function() sample_and_to_sample_editor()   end  }
renoise.tool():add_keybinding {name="Global:Paketti:Play at 75% Speed (Song BPM)",  invoke = function() playat75() end}
renoise.tool():add_keybinding {name="Global:Paketti:Play at 100% Speed (Song BPM)", invoke = function() returnbackto100() end}
renoise.tool():add_keybinding {name="Global:Paketti:Set LPB -1", invoke = function() adjust_lpb_bpb(-1, 0) end   }
renoise.tool():add_keybinding {name="Global:Paketti:Set LPB +1", invoke = function() adjust_lpb_bpb(1, 0) end   }
renoise.tool():add_keybinding {name="Global:Paketti:Set TPL -1", invoke = function() adjust_lpb_bpb(0, -1) end   }
renoise.tool():add_keybinding {name="Global:Paketti:Set TPL +1", invoke = function() adjust_lpb_bpb(0, 1) end   }
renoise.tool():add_keybinding {name="Global:Paketti:Open External Editor for Plugin", invoke = function() inst_open_editor()   end}
renoise.tool():add_keybinding {name="Global:Paketti:Set Current Sample to Forward Loop", invoke = function() LoopSet(2) end}
renoise.tool():add_keybinding {name="Global:Paketti:Set Current Sample to Backward Loop", invoke = function() LoopSet(3) end}
renoise.tool():add_keybinding {name="Global:Paketti:Set Current Sample to Pingpong Loop", invoke = function() LoopSet(4) end}
renoise.tool():add_keybinding {name="Global:Paketti:Set Current Sample to No Loop", invoke = function() LoopSet(1) end}
renoise.tool():add_keybinding {name="Global:Paketti:Delete Effectcolumn content from current track", invoke = function() delete_effect_column() end }
renoise.tool():add_keybinding {name="Global:Paketti:Loop Block Backwards", invoke = function() loopblockback() end}
renoise.tool():add_keybinding {name="Global:Paketti:Loop Block Forwards", invoke = function() loopblockforward() end}

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
renoise.tool():add_menu_entry {name = "Sample Editor:Ding", invoke = function() something() end}
