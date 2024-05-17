



function voloff()
local s = renoise.song()
local currColumn = renoise.song().selected_note_column_index

if renoise.song().selected_effect_column == nil 
then renoise.song().selected_effect_column_index=1
else end

local efc = s.selected_effect_column
local currTrak=s.selected_track_index
local currLine=s.selected_line_index
local currPatt=s.selected_pattern_index

local ns=efc.number_string
local as=efc.amount_string
if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then 
  return
  else
 --     if s.selected_effect_column=="" then
if renoise.song().selected_effect_column.number_string=="0L" then
renoise.song().selected_effect_column.number_string ="00"
else
renoise.song().selected_effect_column.number_string ="0L"
renoise.song().selected_effect_column.amount_string ="00"
     end
end
renoise.song().selected_note_column_index = 1
end
renoise.tool():add_keybinding{name="Global:Paketti:Insert 0L00 to Pattern Editor",invoke=function() voloff() end}

---------------
function RecordFollowOffPattern()
local t=renoise.song().transport
local w = renoise.app().window
--w.active_middle_frame = 1
if t.edit_mode == false then t.edit_mode=true else t.edit_mode=false end
if t.follow_player == false then return else t.follow_player=false end end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Record+Follow Off",invoke=function() RecordFollowOffPattern() end}


-- Set Delay +1 / -1 / +10 / -10 on current_row, display delay column
function delay(chg)
 local s=renoise.song()
 local d=s.selected_note_column.delay_value
 local nc=s.selected_note_column
 local currTrak=s.selected_track_index

 s.tracks[currTrak].delay_column_visible=true
 --nc.delay_value=(d+chg)
 --if nc.delay_value == 0 and chg < 0 then
  --move_up(chg)
 --elseif nc.delay_value == 255 and chg > 0 then
  --move_down(chg)
 --else
 -- nc.delay_value 
 nc.delay_value = math.max(0, math.min(255, d + chg))
 --end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Increase Delay +1",invoke=function() delay(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Decrease Delay -1",invoke=function() delay(-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Increase Delay +10",invoke=function() delay(10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Decrease Delay -10",invoke=function() delay(-10) end}


----
--Quantize +1 / -1
function adjust_quantize(quant_delta)
  local t = renoise.song().transport
  local counted = nil
  counted=t.record_quantize_lines+quant_delta
  if counted == 0 then
  t.record_quantize_enabled=false return end
  
  if t.record_quantize_enabled==false and t.record_quantize_lines == 1 then
  t.record_quantize_lines = 1
  t.record_quantize_enabled=true
  return end  
    t.record_quantize_lines=math.max(1, math.min(32, t.record_quantize_lines + quant_delta))
    t.record_quantize_enabled=true
renoise.app():show_status("Record Quantize Lines : " .. t.record_quantize_lines)
end
renoise.tool():add_keybinding{name="Global:Paketti:Quantization Decrease (-1)",invoke=function() adjust_quantize(-1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:Quantization Increase (+1)",invoke=function() adjust_quantize(1, 0) end}
-------
-- +1/-1 on Metronome LPB and Metronome BPB (loads of help from dblue)
function adjust_metronome(lpb_delta, bpb_delta)
  -- Local reference to transport
  local t = renoise.song().transport
  t.metronome_lines_per_beat = math.max(1, math.min(16, t.metronome_lines_per_beat + lpb_delta))
  t.metronome_beats_per_bar = math.max(1, math.min(16, t.metronome_beats_per_bar + bpb_delta))
-- Show status
  t.metronome_enabled = true
  renoise.app():show_status("Metronome LPB: " .. t.metronome_lines_per_beat .. " BPB : " .. t.metronome_beats_per_bar) end

--dblue modified to be lpb/tpl  
function adjust_lpb_bpb(lpb_delta, tpl_delta)
  local t = renoise.song().transport
  t.lpb = math.max(1, math.min(256, t.lpb + lpb_delta))
  t.tpl = math.max(1, math.min(16, t.tpl + tpl_delta))
--  renoise.song().transport.metronome_enabled = true
  renoise.app():show_status("LPB: " .. t.lpb .. " TPL : " .. t.tpl) end

renoise.tool():add_keybinding{name="Global:Paketti:Metronome LPB Decrease (-1)",invoke=function() adjust_metronome(-1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:Metronome LPB Increase (+1)",invoke=function() adjust_metronome(1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:Metronome BPB Decrease (-1)",invoke=function() adjust_metronome(0, -1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Metronome BPB Increase (+1)",invoke=function() adjust_metronome(0, 1) end}
renoise.tool():add_keybinding{name="Global:Paketti:LPB Decrease (-1)",invoke=function() adjust_lpb_bpb(-1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:LPB Increase (+1)",invoke=function() adjust_lpb_bpb(1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:TPL Decrease (-1)",invoke=function() adjust_lpb_bpb(0, -1) end}
renoise.tool():add_keybinding{name="Global:Paketti:TPL Increase (+1)",invoke=function() adjust_lpb_bpb(0, 1) end}

---------------------------
function soloKey()
local s=renoise.song()
  s.tracks[renoise.song().selected_track_index]:solo()
    if s.transport.playing==false then renoise.song().transport.playing=true end
  s.transport.follow_player=true  
    if renoise.app().window.active_middle_frame~=1 then renoise.app().window.active_middle_frame=1 end
end

renoise.tool():add_keybinding{name="Global:Paketti:Solo Channel + Play + Follow", invoke=function() soloKey() end}


--This script uncollapses everything (all tracks, master, send trax)
function Uncollapser()
local send_track_counter=nil
local s=renoise.song()

   send_track_counter=s.sequencer_track_count+1+s.send_track_count

   for i=1,send_track_counter do
   s.tracks[i].collapsed=false
   end
end

--This script collapses everything (all tracks, master, send trax)
function Collapser()
local send_track_counter=nil
local s=renoise.song()
   send_track_counter=s.sequencer_track_count+1+s.send_track_count

   for i=1,send_track_counter do
   s.tracks[i].collapsed=true end
end

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Collapser",invoke=function() Collapser() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Uncollapser",invoke=function() Uncollapser() end}
--Global keyboard shortcuts
renoise.tool():add_keybinding{name="Global:Paketti:Uncollapser",invoke=function() Uncollapser() end}
renoise.tool():add_keybinding{name="Global:Paketti:Collapser",invoke=function() Collapser() end}
--Menu entries for Pattern Editor and Mixer
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Uncollapser",invoke=function() Uncollapser() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Uncollapser",invoke=function() Uncollapser() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Collapser",invoke=function() Collapser() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Collapser",invoke=function() Collapser() end}

-- Toggle CapsLock Note Off "===" On / Off.
function CapsLok()
local s=renoise.song()
  local currLine=s.selected_line_index
  local currPatt=s.selected_pattern_index
  local currTrak=s.selected_track_index
  local currPhra=s.selected_phrase_index
  local currInst=s.selected_instrument_index
 
 
 if renoise.app().window.active_middle_frame==1 then
    if renoise.song().selected_note_column_index==nil or renoise.song().selected_note_column_index == 0 then return 
      else 
        if renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=="OFF" then 
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=""
       else
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string="OFF"
       end
end
 
else if renoise.app().window.active_middle_frame==3 then return
-- i just cut out the phrase writing since it doesn't seem to want to work
end
--local phra=renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index]
if renoise.song().selected_phrase == nil then return else
local phra=renoise.song().selected_phrase

phra.sample_effects_column_visible=false
phra.panning_column_visible=false
phra.delay_column_visible=false
phra.visible_note_columns=1
phra.instrument_column_visible=false

if renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=="OFF"
then
renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=""
else
renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string="OFF"
end
end 
 
 
end
end
renoise.tool():add_keybinding{name="Global:Paketti:KapsLock CapsLock Caps Lock Note Off",invoke=function() CapsLok() end}
----------------------------------------------------------------------------------------------------
function ptnLength(number) local rs=renoise.song() rs.patterns[rs.selected_pattern_index].number_of_lines=number end

function phrLength(number) local s=renoise.song() 
renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index].number_of_lines=number end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 001",invoke=function() ptnLength(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 004",invoke=function() ptnLength(4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 008",invoke=function() ptnLength(8) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 016",invoke=function() ptnLength(16) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 032",invoke=function() ptnLength(32) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 048",invoke=function() ptnLength(48) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 064",invoke=function() ptnLength(64) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 096",invoke=function() ptnLength(96) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 128",invoke=function() ptnLength(128) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 192",invoke=function() ptnLength(192) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 256",invoke=function() ptnLength(256) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 384",invoke=function() ptnLength(384) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 512",invoke=function() ptnLength(512) end}

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 001",invoke=function() phrLength(1) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 004",invoke=function() phrLength(4) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 008",invoke=function() phrLength(8) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 016",invoke=function() phrLength(16) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 032",invoke=function() phrLength(32) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 048",invoke=function() phrLength(48) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 064",invoke=function() phrLength(64) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 096",invoke=function() phrLength(96) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 128",invoke=function() phrLength(128) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 192",invoke=function() phrLength(192) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 256",invoke=function() phrLength(256) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 384",invoke=function() phrLength(384) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 512",invoke=function() phrLength(512) end}

renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 001",invoke=function() ptnLength(1) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 004",invoke=function() ptnLength(4) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 008",invoke=function() ptnLength(8) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 016",invoke=function() ptnLength(16) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 032",invoke=function() ptnLength(32) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 048",invoke=function() ptnLength(48) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 064",invoke=function() ptnLength(64) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 096",invoke=function() ptnLength(96) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 128",invoke=function() ptnLength(128) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 192",invoke=function() ptnLength(192) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 256",invoke=function() ptnLength(256) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 384",invoke=function() ptnLength(384) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 512",invoke=function() ptnLength(512) end}
--------------
function Deselect_All() renoise.song().selection_in_pattern=nil end
function Deselect_Phr() renoise.song().selection_in_phrase =nil end

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Paketti Unmark Selection (ALT-U)",invoke=function() Deselect_All() end}
renoise.tool():add_keybinding{name="Pattern Editor:Selection:Paketti Unmark Selection (CTRL-U) (2nd)",invoke=function() Deselect_All() end}

renoise.tool():add_keybinding{name="Phrase Editor:Selection:Paketti Unmark Selection (ALT-U)",invoke=function() Deselect_Phr() end}
renoise.tool():add_keybinding{name="Phrase Editor:Selection:Paketti Unmark Selection (CTRL-U) (2nd)",invoke=function() Deselect_Phr() end}


function efxwrite(effect,x,y)
local s=renoise.song()
local counter=nil 
local currentamount=nil
local old_x=nil
local old_y=nil
local new_x=nil
local new_y=nil

for i=s.selection_in_pattern.start_line,renoise.song().selection_in_pattern.end_line 
do 
if 
s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value == 0 and (x < 0 or y < 0)
then s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).number_string="" 
else
s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).number_string=effect
old_y=s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value % 16
old_x=math.floor (s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value/16)

new_x=old_x+x
new_y=old_y+y
--print ("new_x: " .. new_x)
--print ("new_y: " .. new_y)
if new_x > 15 then new_x = 15 end
if new_y > 15 then new_y = 15 end
if new_y < 1 then new_y = 0 end
if new_x < 1 then new_x = 0 end

counter=(16*new_x)+new_y  

s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value=counter 
end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:AXx Arp Amount Xx -1",invoke=function() efxwrite("0A",-1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:AXx Arp Amount Xx +1",invoke=function() efxwrite("0A",1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:AxY Arp Amount xY -1",invoke=function() efxwrite("0A",0,-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:AxY Arp Amount xY +1",invoke=function() efxwrite("0A",0,1) end}

renoise.tool():add_keybinding{name="Global:Paketti:VXy Vibrato Amount Xy -1",invoke=function() efxwrite("0V",-1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:VXy Vibrato Amount Xy +1",invoke=function() efxwrite("0V",1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:VxY Vibrato Amount xY -1",invoke=function() efxwrite("0V",0,-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:VxY Vibrato Amount xY +1",invoke=function() efxwrite("0V",0,1) end}

renoise.tool():add_keybinding{name="Global:Paketti:TXy Tremolo Amount Xy -1",invoke=function() efxwrite("0T",-1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:TXy Tremolo Amount Xy +1",invoke=function() efxwrite("0T",1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:TxY Tremolo Amount xY -1",invoke=function() efxwrite("0T",0,-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:TxY Tremolo Amount xY +1",invoke=function() efxwrite("0T",0,1) end}

renoise.tool():add_keybinding{name="Global:Paketti:RXy Retrig Amount Xy -1",invoke=function() efxwrite("0R",-1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:RXy Retrig Amount Xy +1",invoke=function() efxwrite("0R",1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:RxY Retrig Amount xY -1",invoke=function() efxwrite("0R",0,-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:RxY Retrig Amount xY +1",invoke=function() efxwrite("0R",0,1) end}

renoise.tool():add_keybinding{name="Global:Paketti:CXy Cut Volume Amount Xy -1",invoke=function() efxwrite("0C",-1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:CXy Cut Volume Amount Xy +1",invoke=function() efxwrite("0C",1,0) end}
renoise.tool():add_keybinding{name="Global:Paketti:CxY Cut Volume Amount xY -1",invoke=function() efxwrite("0C",0,-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:CxY Cut Volume Amount xY +1",invoke=function() efxwrite("0C",0,1) end}
-----------
function GlobalLPB(number)
renoise.song().transport.lpb=number end

for glpb=1,16 do
    renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Global LPB to " .. glpb,invoke=function() GlobalLPB(glpb) end}
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Global LPB to 24",invoke=function() GlobalLPB(24) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Global LPB to 32",invoke=function() GlobalLPB(32) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Global LPB to 48",invoke=function() GlobalLPB(48) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Global LPB to 64",invoke=function() GlobalLPB(64) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Global LPB to 128",invoke=function() GlobalLPB(128) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Global LPB to 256",invoke=function() GlobalLPB(256) end}


function PhraseLPB(number)
renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index].lpb=number end

for plpb=1,16 do
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase LPB to " .. plpb,invoke=function() PhraseLPB(plpb) end}
end

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase LPB to 24",invoke=function() PhraseLPB(24) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase LPB to 32",invoke=function() PhraseLPB(32) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase LPB to 48",invoke=function() PhraseLPB(48) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase LPB to 64",invoke=function() PhraseLPB(64) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase LPB to 128",invoke=function() PhraseLPB(128) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase LPB to 256",invoke=function() PhraseLPB(256) end}

----------------------------------------------------------------------------------------------------
function computerKeyboardVolChange(number)
local s=renoise.song();if s.transport.keyboard_velocity_enabled==false then s.transport.keyboard_velocity_enabled=true end
local addtovelocity=nil
addtovelocity=s.transport.keyboard_velocity+number
if addtovelocity > 127 then addtovelocity=127 end
if addtovelocity < 1 then s.transport.keyboard_velocity_enabled=false return end
s.transport.keyboard_velocity=addtovelocity
end

renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity -1",invoke=function() computerKeyboardVolChange(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity +1",invoke=function() computerKeyboardVolChange(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity -10",invoke=function() computerKeyboardVolChange(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity +10",invoke=function() computerKeyboardVolChange(10) end}


--BPM +1 / -1
function adjust_bpm(bpm_delta)
  local t = renoise.song().transport
  t.bpm = math.max(32, math.min(999, t.bpm + bpm_delta))
renoise.app():show_status("BPM : " .. t.bpm)
end

renoise.tool():add_keybinding{name="Global:Paketti:BPM Decrease (-1)",invoke=function() adjust_bpm(-1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Increase (+1)",invoke=function() adjust_bpm(1, 0) end}



function pakettiPatternDoubler()
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local old_patternlength = song.selected_pattern.number_of_lines
  local new_patternlength = old_patternlength * 2

  if new_patternlength <= 512 then
    song.selected_pattern.number_of_lines = new_patternlength

    -- Loop through each track in the selected pattern
    for track_index, pattern_track in ipairs(song.selected_pattern.tracks) do
      -- Copy notes in the pattern
      if not pattern_track.is_empty then
        for line_index = 1, old_patternlength do
          local line = pattern_track:line(line_index)
          local new_line = pattern_track:line(line_index + old_patternlength)
          new_line:copy_from(line)
        end
      end

      -- Handle automation duplication
      local track_automations = song.patterns[pattern_index].tracks[track_index].automation
      for param, automation in pairs(track_automations) do
        local points = automation.points
        local new_points = {} -- Store new points to be added

        -- Collect new points to add, adjusting time by old pattern length
        for _, point in ipairs(points) do
          table.insert(new_points, {time = point.time + old_patternlength, value = point.value})
        end

        -- Add the new points to the automation
        for _, new_point in ipairs(new_points) do
          automation:add_point_at(new_point.time, new_point.value)
        end
      end
    end

    song.selected_line_index = old_patternlength + 1
    print("Pattern doubled successfully.")
  else
    print("New pattern length exceeds 512 lines, operation cancelled.")
  end
end


function pakettiPatternHalver()
  local s = renoise.song()
  local old_patternlength = s.selected_pattern.number_of_lines
  local resultlength = math.floor(old_patternlength / 2)

  -- Check if the result length is less than 1, which would be invalid
  if resultlength < 1 then
    print("Resulting pattern length is too small, operation cancelled.")
    return
  end

  -- Set the new pattern length
  s.selected_pattern.number_of_lines = resultlength

  -- Adjust automation for each track
  for track_index, track in ipairs(s.selected_pattern.tracks) do
    local track_automations = s.patterns[s.selected_pattern_index].tracks[track_index].automation
    for _, automation in pairs(track_automations) do
      local points = automation.points
      local new_points = {}

      -- Collect new points, scaling down the time values
      for _, point in ipairs(points) do
        local new_time = math.floor((point.time / old_patternlength) * resultlength)
        if new_time >= 1 and new_time <= resultlength then
          table.insert(new_points, {time = new_time, value = point.value})
        end
      end

      -- Clear existing points and add scaled points
      automation:clear_points()
      for _, point in ipairs(new_points) do
        automation:add_point_at(point.time, point.value)
      end
    end
  end
end



-- Add menu entries and keybindings for the tool
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}
renoise.tool():add_keybinding{name="Mixer:Paketti:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}

-- The function can be bound to a menu item or a keybinding within Renoise to make it easily accessible
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Paketti Pattern Halver", invoke = pakettiPatternHalver}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Paketti Pattern Halver", invoke = pakettiPatternHalver}
renoise.tool():add_keybinding{name="Mixer:Paketti:Paketti Pattern Halver", invoke = pakettiPatternHalver}

function get_master_track_index()
  for k,v in ripairs(renoise.song().tracks)
    do if v.type == renoise.Track.TRACK_TYPE_MASTER then return k end  
  end
end

function write_bpm()
  if renoise.song().transport.bpm < 256 then -- safety check
    local column_index = renoise.song().selected_effect_column_index
    local t=renoise.song().transport
  renoise.song().tracks[get_master_track_index()].visible_effect_columns = 2  
    
    if renoise.song().selected_effect_column_index <= 1 then column_index = 2 end
    
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].number_string = "ZT"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].amount_value  = t.bpm
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].number_string = "ZL"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].amount_value  = t.lpb
  end
end

renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Write Current BPM&LPB to Master column",invoke=function() write_bpm() end}

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
    if renoise.tool().preferences.RandomBPM.value then
        write_bpm()
    end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:Renoise Random BPM & Write BPM/LPB to Master",
    invoke = function()
        local randombpm = {80, 100, 115, 123, 128, 132, 135, 138, 160}
        math.randomseed(os.time())
        local prefix = randombpm[math.random(#randombpm)]
        renoise.song().transport.bpm = prefix

        if renoise.tool().preferences.RandomBPM.value then 
      
            write_bpm()
        end
    end
}




function playat75()
 renoise.song().transport.bpm=renoise.song().transport.bpm*0.75
 write_bpm()
 renoise.app():show_status("BPM set to 75% (" .. renoise.song().transport.bpm .. "BPM)") 
end

function returnbackto100()
 renoise.song().transport.bpm=renoise.song().transport.bpm/0.75
 write_bpm()
 renoise.app():show_status("BPM set back to 100% (" .. renoise.song().transport.bpm .. "BPM)") 
end

renoise.tool():add_keybinding{name="Global:Paketti:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_keybinding{name="Global:Paketti:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75()  end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}


renoise.tool():add_keybinding{name="Global:Paketti:Random BPM from List",
    invoke = function()
        -- Define a list of possible BPM values
        local bpmList = {80, 100, 115, 123, 128, 132, 135, 138, 160}
        
        -- Get the current BPM
        local currentBPM = renoise.song().transport.bpm
        
        -- Filter the list to exclude the current BPM
        local newBpmList = {}
        for _, bpm in ipairs(bpmList) do
            if bpm ~= currentBPM then
                table.insert(newBpmList, bpm)
            end
        end

        -- Select a random BPM from the filtered list
        if #newBpmList > 0 then
            local selectedBPM = newBpmList[math.random(#newBpmList)]
            renoise.song().transport.bpm = selectedBPM
            print("Random BPM set to: " .. selectedBPM) -- Debug output to the console
        else
            print("No alternative BPM available to switch to.")
        end

        -- Optional: write the BPM to a file or apply other logic
        if renoise.tool().preferences.RandomBPM and renoise.tool().preferences.RandomBPM.value then
            write_bpm() -- Ensure this function is defined elsewhere in your tool
            print("BPM written to file or handled additionally.")
        end
    end
}
-------------------------
function WipeEfxFromSelection()
--thanks to joule for assistance1+2(2018)!
local s = renoise.song()

if s.selection_in_pattern==nil then return end

local ecvisible = s:track(s.selected_track_index).visible_effect_columns
local pattern_track = s:pattern(s.selected_pattern_index):track(s.selected_track_index)

for line_index = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
    local line = pattern_track:line(line_index)
    if not line.is_empty then
      for effect_column_index = 1, ecvisible do
        line:effect_column(effect_column_index):clear()
      end
    end
  end
end
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Effects From Selection",invoke=function() WipeEfxFromSelection() end}
----------------
--rescued from ImpulseBuddy by Protman! I have no idea how many of these were originally a part of Paketti, or something else, but
--hey, more crosspollination, more features.
function delete_effect_column()
local s=renoise.song()
local currTrak = s.selected_track_index
local currPatt = s.selected_pattern_index

local iter = s.pattern_iterator:effect_columns_in_pattern_track(currPatt,currTrak)
  for _,line in iter do
   if not line.is_empty then
   line:clear()
   end
  end 
end

renoise.tool():add_keybinding{name="Global:Paketti:Delete/Wipe/Clear Effect Column Content from Current Track",invoke=function() delete_effect_column() end}
---------------------------
function GenerateDelayValue() 
local counter=nil
local s=renoise.song()
s.tracks[s.selected_track_index].delay_column_visible=true

for i=1,s.tracks[s.selected_track_index].visible_note_columns do
counter=256/s.tracks[s.selected_track_index].visible_note_columns*(i-1)
DEC_HEX(counter)
print (counter)
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[i].delay_value=counter end
s.selected_note_column_index=1 end

renoise.tool():add_keybinding{name="Global:Paketti:Generate Delay Value on Note Columns",invoke=function() GenerateDelayValue() end}
----------------------------------------------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------------------------------------------


-- originally created by joule + danoise
-- http://forum.renoise.com/index.php/topic/47664-new-tool-31-better-column-navigation/
-- ripped into Paketti without their permission. tough cheese.
local cached_note_column_index = nil
local cached_effect_column_index = nil
 
function toggle_column_type()
  local s = renoise.song()
  if s.selected_track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
    if s.selected_note_column_index ~= 0 then
      local col_idx = (cached_effect_column_index ~= 0) and 
        cached_effect_column_index or 1
      if (col_idx <= s.selected_track.visible_effect_columns) then
        s.selected_effect_column_index = col_idx
      elseif (s.selected_track.visible_effect_columns > 0) then
        s.selected_effect_column_index = s.selected_track.visible_effect_columns
      else
        -- no effect columns available
      end
    else
      local col_idx = (cached_note_column_index ~= 0) and 
        cached_note_column_index or 1
      if (col_idx <= s.selected_track.visible_note_columns) then
        s.selected_note_column_index = col_idx
      else -- always one note column
        s.selected_note_column_index = s.selected_track.visible_note_columns
      end end end end
 
function cache_columns()
  -- access song only once renoise is ready
  if not pcall(renoise.song) then return end
  local s = renoise.song()
  if (s.selected_note_column_index > 0) then
    cached_note_column_index = s.selected_note_column_index
  end
  if (s.selected_effect_column_index > 0) then
    cached_effect_column_index = s.selected_effect_column_index end end

function cycle_column(direction)
local s = renoise.song()
 if direction == "next" then

  if (s.selected_note_column_index > 0) and (s.selected_note_column_index < s.selected_track.visible_note_columns) then -- any note column but not the last
   s.selected_note_column_index = s.selected_note_column_index + 1
  elseif (s.selected_track.visible_note_columns > 0) and (s.selected_note_column_index == s.selected_track.visible_note_columns) and (s.selected_track.visible_effect_columns > 0) then -- last note column when effect columns are available
   s.selected_effect_column_index = 1
  elseif (s.selected_effect_column_index < s.selected_track.visible_effect_columns) then -- any effect column but not the last
   s.selected_effect_column_index = s.selected_effect_column_index + 1
  elseif (s.selected_effect_column_index == s.selected_track.visible_effect_columns) and (s.selected_track_index < #s.tracks) then -- last effect column but not the last track
   s.selected_track_index = s.selected_track_index + 1
  else -- last column in last track
   s.selected_track_index = 1 end

 elseif direction == "prev" then
  if (s.selected_note_column_index > 0) and (s.selected_sub_column_type > 2 and s.selected_sub_column_type < 8) then -- any sample effects column
   s.selected_note_column_index = s.selected_note_column_index
  elseif (s.selected_note_column_index > 1) then -- any note column but not the first
   s.selected_note_column_index = s.selected_note_column_index - 1
  elseif (s.selected_effect_column_index > 1) then -- any effect column but not the first
   s.selected_effect_column_index = s.selected_effect_column_index - 1
  elseif (s.selected_effect_column_index == 1) and (s.selected_track.visible_note_columns > 0) then -- first effect column and note columns exist
   s.selected_note_column_index = s.selected_track.visible_note_columns
  elseif (s.selected_effect_column_index == 1) and (s.selected_track.visible_note_columns == 0) then -- first effect column and note columns do not exist (group/send/master)
   s.selected_track_index = s.selected_track_index - 1
   if s.selected_track.visible_effect_columns > 0 then s.selected_effect_column_index = s.selected_track.visible_effect_columns
   else s.selected_note_column_index = s.selected_track.visible_note_columns
   end
  elseif (s.selected_note_column_index == 1) and (s.selected_track_index == 1) then -- first note column in first track
  local rns=renoise.song()
   s.selected_track_index = #rns.tracks
   s.selected_effect_column_index = s.selected_track.visible_effect_columns
  elseif (s.selected_note_column_index == 1) then -- first note column
   s.selected_track_index = s.selected_track_index - 1
   if s.selected_track.visible_effect_columns > 0 then s.selected_effect_column_index = s.selected_track.visible_effect_columns
   else s.selected_note_column_index = s.selected_track.visible_note_columns
   end end end end
 
renoise.tool():add_keybinding{name="Pattern Editor:Navigation:Paketti Switch between Note/FX columns",invoke=toggle_column_type}
renoise.tool():add_keybinding{name="Pattern Editor:Navigation:Paketti Jump to Next Column (Note/FX)",invoke=function() cycle_column("next") end}
renoise.tool():add_keybinding{name="Pattern Editor:Navigation:Paketti Jump to Previous Column (Note/FX)",invoke=function() cycle_column("prev") end}
renoise.tool().app_idle_observable:add_notifier(cache_columns)

-- Pattern Resizer by dblue. some minor modifications.
function resize_pattern(pattern, new_length, patternresize)
  
  -- We need a valid pattern object
  if (pattern == nil) then
    renoise.app():show_status('Need a valid pattern object!')
    return
  end
  
  -- Rounding function
  local function round(value)
    return math.floor(value + 0.5)
  end
  
  -- Shortcut to the song object
  local rs = renoise.song()
  
  -- Get the current pattern length
  local src_length = pattern.number_of_lines 
  
  -- Make sure new_length is within valid limits
  local dst_length = math.min(512, math.max(1, new_length))
   
  -- If the new length is the same as the old length, then we have nothing to do.
  if (dst_length == src_length) then
    return
  end
  
  -- Set conversation ratio
  local ratio = dst_length / src_length
  
  -- Change pattern length
  if patternresize==1 then 
 pattern.number_of_lines = dst_length
end
   
  -- Source
  local src_track = nil
  local src_line = nil
  local src_note_column = nil
  local src_effect_column = nil
  
  -- Insert a new track as a temporary work area
  rs:insert_track_at(1)
  
  -- Destination
  local dst_track = pattern:track(1)
  local dst_line_index = 0
  local dst_delay = 0
  local dst_line = nil
  local dst_note_column = nil
  local dst_effect_column = nil
  
  -- Misc
  local tmp_line_index = 0
  local tmp_line_delay = 0
  local delay_column_used = false   
  local track = nil

  -- Iterate through each track
  for src_track_index = 2, #rs.tracks, 1 do
  
    track = rs:track(src_track_index)

    -- Set source track
    src_track = pattern:track(src_track_index)
    
    -- Reset delay check
    delay_column_used = false
 
    -- Iterate through source lines
    for src_line_index = 0, src_length - 1, 1 do
    
      -- Set source line
      src_line = src_track:line(src_line_index + 1)
      
      -- Only process source line if it contains data
      if (not src_line.is_empty) then
           
        -- Store temporary line index and delay
        tmp_line_index = math.floor(src_line_index * ratio)
        tmp_line_delay = math.floor(((src_line_index * ratio) - tmp_line_index) * 256)
         
        -- Process note columns
        for note_column_index = 1, track.visible_note_columns, 1 do
        
          -- Set source note column
          src_note_column = src_line:note_column(note_column_index)
          
          -- Only process note column if it contains data 
          if (not src_note_column.is_empty) then
          
            -- Calculate destination line and delay
            dst_line_index = tmp_line_index
            dst_delay = math.ceil(tmp_line_delay + (src_note_column.delay_value * ratio))
            
            -- Wrap note to next line if necessary
            while (dst_delay >= 256) do
              dst_delay = dst_delay - 256
              dst_line_index = dst_line_index + 1
            end
            
            -- Keep track of whether the delay column is used
            -- so that we can make it visible later if necessary.
            if (dst_delay > 0) then
              delay_column_used = true
            end
            dst_line = dst_track:line(dst_line_index + 1)
            dst_note_column = dst_line:note_column(note_column_index)
            
            -- Note prioritisation 
            if (dst_note_column.is_empty) then
            
              -- Destination is empty. Safe to copy
              dst_note_column:copy_from(src_note_column)
              dst_note_column.delay_value = dst_delay   
              
            else
              -- Destination contains data. Try to prioritise...
            
              -- If destination contains a note-off...
              if (dst_note_column.note_value == 120) then
                -- Source note takes priority
                dst_note_column:copy_from(src_note_column)
                dst_note_column.delay_value = dst_delay
                
              else
              
                -- If the source is louder than destination...
                if (src_note_column.volume_value > dst_note_column.volume_value) then
                  -- Louder source note takes priority
                  dst_note_column:copy_from(src_note_column)
                  dst_note_column.delay_value = dst_delay
                  
                -- If source note is less delayed than destination...
                elseif (src_note_column.delay_value < dst_note_column.delay_value) then
                  -- Less delayed source note takes priority
                  dst_note_column:copy_from(src_note_column)
                  dst_note_column.delay_value = dst_delay 
                  
                end
                
              end      
              
            end -- End: Note prioritisation 
          
          end -- End: Only process note column if it contains data 
         
        end -- End: Process note columns
          
        -- Process effect columns     
        for effect_column_index = 1, track.visible_effect_columns, 1 do
          src_effect_column = src_line:effect_column(effect_column_index)
          if (not src_effect_column.is_empty) then
            dst_effect_column = dst_track:line(round(src_line_index * ratio) + 1):effect_column(effect_column_index)
            if (dst_effect_column.is_empty) then
              dst_effect_column:copy_from(src_effect_column)
            end
          end
        end
      
      end -- End: Only process source line if it contains data

    end -- End: Iterate through source lines
    
    -- If there is automation to process...
    if (#src_track.automation > 0) then
    
      -- Copy processed lines from temporary track back to original track
      -- We can't simply use copy_from here, since it will erase the automation
      for line_index = 1, dst_length, 1 do
        dst_line = dst_track:line(line_index)
        src_line = src_track:line(line_index)
        src_line:copy_from(dst_line)
      end
    
      -- Process automation
      for _, automation in ipairs(src_track.automation) do
        local points = {}
        for _, point in ipairs(automation.points) do
          if (point.time <= src_length) then
            table.insert(points, { time = math.min(dst_length - 1, math.max(0, round((point.time - 1) * ratio))), value = point.value })
          end
          automation:remove_point_at(point.time)
        end
        for _, point in ipairs(points) do
          if (not automation:has_point_at(point.time + 1)) then
            automation:add_point_at(point.time + 1, point.value)
          end
        end
      end
    
    else
    
      -- No automation to process. We can save time and just copy_from
      src_track:copy_from(dst_track)
    
    end
       
    -- Clear temporary track for re-use
    dst_track:clear()
     
    -- Show the delay column if any note delays have been used
    if (rs:track(src_track_index).type == 1) then
      if (delay_column_used) then
        rs:track(src_track_index).delay_column_visible = true
      end
    end
               
  end -- End: Iterate through each track
 
  -- Remove temporary track
  rs:delete_track_at(1)
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:dblue Shrink",invoke=function()
local pattern = renoise.song().selected_pattern
resize_pattern(pattern, pattern.number_of_lines * 0.5, 0) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:dblue Expand",invoke=function()
local pattern = renoise.song().selected_pattern
resize_pattern(pattern, pattern.number_of_lines * 2, 0 ) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:dblue Shrink + Resize Pattern",invoke=function()
local pattern = renoise.song().selected_pattern
resize_pattern(pattern, pattern.number_of_lines * 0.5,1 ) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:dblue Expand + Resize Pattern",invoke=function()
local pattern = renoise.song().selected_pattern
resize_pattern(pattern, pattern.number_of_lines * 2,1) end}
-------------------


function bend(amount)
local counter=nil 
local s=renoise.song()

for i=s.selection_in_pattern.start_line,s.selection_in_pattern.end_line 
do 
counter=s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[i].effect_columns[1].amount_value+amount 

if counter > 255 then counter=255 end
if counter < 1 then counter=0 end
s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[i].effect_columns[1].amount_value=counter end
end

function effectamount(amount,effectname)
-- massive thanks to pandabot for the optimization tricks!
local s=renoise.song()
local counter=nil
for i=s.selection_in_pattern.start_line,s.selection_in_pattern.end_line 
do 
s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).number_string=effectname
counter=s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value+amount 
if counter > 255 then counter=255 end
if counter < 1 then counter=0 end
s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value=counter 
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Bend -1",invoke=function() bend(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend -10",invoke=function() bend(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend -1 (2nd)",invoke=function() bend(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend -10 (2nd)",invoke=function() bend(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend -1 (3rd)",invoke=function() bend(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend -10 (3rd)",invoke=function() bend(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend +1",invoke=function() bend(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend +10",invoke=function() bend(10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend +1 (2nd)",invoke=function() bend(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend +10 (2nd)",invoke=function() bend(10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend +1 (3rd)",invoke=function() bend(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Bend +10 (3rd)",invoke=function() bend(10) end}

renoise.tool():add_keybinding{name="Global:Paketti:Glide Amount -1",invoke=function() effectamount(-1,"0G") end}
renoise.tool():add_keybinding{name="Global:Paketti:Glide Amount +1",invoke=function() effectamount(1,"0G") end}
renoise.tool():add_keybinding{name="Global:Paketti:Glide Amount -10",invoke=function() effectamount(-10,"0G") end}
renoise.tool():add_keybinding{name="Global:Paketti:Glide Amount 10",invoke=function() effectamount(10,"0G") end}

renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up +1",invoke=function() effectamount(1,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up -1",invoke=function() effectamount(-1,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up +10",invoke=function() effectamount(10,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up -10",invoke=function() effectamount(-10,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down +1",invoke=function() effectamount(1,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down -1",invoke=function() effectamount(-1,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down +10",invoke=function() effectamount(10,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down -10",invoke=function() effectamount(-10,"0D") end}

renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up +1 (2nd)",invoke=function() effectamount(1,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up -1 (2nd)",invoke=function() effectamount(-1,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up +10 (2nd)",invoke=function() effectamount(10,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up -10 (2nd)",invoke=function() effectamount(-10,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down +1 (2nd)",invoke=function() effectamount(1,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down -1 (2nd)",invoke=function() effectamount(-1,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down +10 (2nd)",invoke=function() effectamount(10,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down -10 (2nd)",invoke=function() effectamount(-10,"0D") end}

renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up +1 (3rd)",invoke=function() effectamount(1,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up -1 (3rd)",invoke=function() effectamount(-1,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up +10 (3rd)",invoke=function() effectamount(10,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Uxx Slide Pitch Up -10 (3rd)",invoke=function() effectamount(-10,"0U") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down +1 (3rd)",invoke=function() effectamount(1,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down -1 (3rd)",invoke=function() effectamount(-1,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down +10 (3rd)",invoke=function() effectamount(10,"0D") end}
renoise.tool():add_keybinding{name="Global:Paketti:Dxx Slide Pitch Down -10 (3rd)",invoke=function() effectamount(-10,"0D") end}

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:Clear Effect Columns",invoke=function() delete_effect_column() end}
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Effect Columns..:(Uxx) Selection Slide Pitch Up +1",invoke=function() effectamount(1,"0U") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Uxx) Selection Slide Pitch Up +10",invoke=function() effectamount(10,"0U") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Uxx) Selection Slide Pitch Up -1",invoke=function() effectamount(-1,"0U") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Uxx) Selection Slide Pitch Up -10",invoke=function() effectamount(-10,"0U") end}
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Effect Columns..:(Dxx) Selection Slide Pitch Down +1",invoke=function() effectamount(1,"0D") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Dxx) Selection Slide Pitch Down +10",invoke=function() effectamount(10,"0D") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Dxx) Selection Slide Pitch Down -1",invoke=function() effectamount(-1,"0D") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Dxx) Selection Slide Pitch Down -10",invoke=function() effectamount(-10,"0D") end}
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Effect Columns..:(Gxx) Selection Glide +1",invoke=function() effectamount(1,"0G") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Gxx) Selection Glide +10",invoke=function() effectamount(10,"0G") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Gxx) Selection Glide -1",invoke=function() effectamount(-1,"0G") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(Gxx) Selection Glide -10",invoke=function() effectamount(-10,"0G") end}

--Switch between Effect and Note Column
function switchcolumns()
  local s = renoise.song()
  local w = renoise.app().window
if s.selected_note_column_index==nil then return end

  if s.selected_note_column_index==nil then return
    else if s.selected_effect_column_index==1 then s.selected_note_column_index=1
          w.active_middle_frame=1
          w.lock_keyboard_focus=true
          else s.selected_effect_column_index=1
           w.active_middle_frame=1
             w.lock_keyboard_focus=true end
  end
end
renoise.tool():add_keybinding{name="Global:Paketti:Switch Effect Column/Note Column",invoke=function() switchcolumns() end}
--------
function ClearRow()
 local s=renoise.song()
 local currTrak=s.selected_track_index
 local currPatt=s.selected_pattern_index
 local currLine=s.selected_line_index
 
 -- Check if phrase editor is visible to avoid unintended clearing
 if renoise.app().window.active_middle_frame ~= 1 or not s.instruments[s.selected_instrument_index].phrase_editor_visible then
  if currLine < 1 then currLine = 1 end
  for i=1,8 do
   s.patterns[currPatt].tracks[currTrak].lines[currLine].effect_columns[i]:clear()
  end
  for i=1,12 do
   s.patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[i]:clear()
  end
 end
end

renoise.tool():add_keybinding{name="Global:Paketti:Clear Current Row", invoke=function() ClearRow() end}
renoise.tool():add_keybinding{name="Global:Paketti:Clear Current Row 2nd", invoke=function() ClearRow() end}
-------------
--Select specific track:

function select_specific_track(number)
  if number > renoise.song().sequencer_track_count  then 
     number=renoise.song().sequencer_track_count
     renoise.song().selected_track_index=number
  else renoise.song().selected_track_index=number  end
end

for st=1,16 do
  renoise.tool():add_keybinding{name="Global:Paketti:Select Specific Track " .. st, 
    invoke=function() select_specific_track(st) end}
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
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

renoise.tool():add_keybinding{name="Global:Paketti:Write Jump To Next Row (ZBxx)", invoke=function() JumpToNextRow() end}
--------------------
--Clone Current Pattern to Current Sequence and maintain pattern line index.
--Heaps of help from KMaki
function clonePTN()
local rs=renoise.song()
local currline=rs.selected_line_index
local n_patterns = #rs.patterns
local src_pat_i = rs.selected_pattern_index
local src_pat = rs:pattern(src_pat_i)
rs.selected_pattern_index = n_patterns + 1
rs.patterns[rs.selected_pattern_index].number_of_lines=renoise.song().patterns[rs.selected_pattern_index-1].number_of_lines
rs.selected_pattern:copy_from(src_pat)
rs.selected_line_index=currline
end

renoise.tool():add_keybinding{name="Global:Paketti:Clone Current Pattern to Current Sequence",invoke=function() clonePTN() end}
renoise.tool():add_keybinding{name="Global:Paketti:Clone Current Pattern to Current Sequence (2nd)",invoke=function() clonePTN() end}
renoise.tool():add_keybinding{name="Global:Paketti:Clone Current Pattern to Current Sequence (3rd)",invoke=function() clonePTN() end}
------------------------------
-- Destructive 0B01 adder/disabler
function revnoter()
local s = renoise.song()
local efc = s.selected_effect_column

if efc==nil then
  return
  else
  if efc.number_value==11 then
     efc.number_value=00
     efc.amount_value=00
  else
     efc.number_value=11
     efc.amount_value=01
  end
end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Reverse Sample effect 0B01 on/off",invoke=function()
local s=renoise.song()
local nci=s.selected_note_column_index 
s.selected_effect_column_index=1
revnoter() 
if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then 
  return
else 
s.selected_note_column_index=nci
--s.selected_note_column_index=1 
end end}


-- Destructive 0B00 adder/disabler
function revnote()
local s = renoise.song()
local efc = s.selected_effect_column

if efc==nil then
  return
  else
  if efc.number_value==11 then
     efc.number_value=00
     efc.amount_value=00
  else
     efc.number_value=11
     efc.amount_value=00
  end
end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Reverse Sample effect 0B00 on/off",invoke=function()
local nci=renoise.song().selected_note_column_index 
renoise.song().selected_effect_column_index=1
revnote() 
if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=nci
--renoise.song().selected_note_column_index=1 
end end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Reverse Sample effect 0B00 on/off (2nd)",invoke=function() 
renoise.song().selected_effect_column_index=1
revnote() 
if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=1 end end}


renoise.tool():add_midi_mapping{name="Pattern Editor:Paketti:Reverse Sample effect 0B00 on/off",invoke=function() 
renoise.song().selected_effect_column_index=1
revnote() 
if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=1 end end}
----------------------------------------------------------------------------------------------------------------------------------
function displayEffectColumn(number) local rs=renoise.song() rs.tracks[rs.selected_track_index].visible_effect_columns=number end

for dec=1,8 do
  renoise.tool():add_keybinding{name="Global:Paketti:Display Effect Column " .. dec,invoke=function() displayEffectColumn(dec) end}
end
-- Display user-specific amount of note columns or effect columns:
function displayNoteColumn(number) local rs=renoise.song() if rs.tracks[rs.selected_track_index].visible_note_columns == 0 then return else rs.tracks[rs.selected_track_index].visible_note_columns=number end end

for dnc=1,12 do
  renoise.tool():add_keybinding{name="Global:Paketti:Display Note Column " .. dnc,invoke=function() displayNoteColumn(dnc) end}
end
---------
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Reset Panning in Current Column & Row",invoke=function()
local s=renoise.song()
local nc=s.selected_note_column
local currTrak=s.selected_track_index
s.selected_track.panning_column_visible=true
if renoise.song().selected_note_column == nil then return else 
renoise.song().selected_note_column.panning_value = 0xFF
end
end}

function write_effect(incoming)
  local s = renoise.song()
  local efc = s.selected_effect_column

    if efc==nil then
         s.selected_effect_column.number_string=incoming
         s.selected_effect_column.amount_value=00
      else
      if efc.number_string==incoming and efc.amount_string=="00" then
         s.selected_effect_column.number_string=incoming
         s.selected_effect_column.amount_string="C0"
      else
         s.selected_effect_column.number_string=incoming
         s.selected_effect_column.amount_value=00
      end
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Volume effect 0L00 On/Off", invoke=function() 
renoise.song().selected_effect_column_index=1
write_effect("0L") 

  if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=1 end end} 
------------------------------
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
         renoise.song().selected_effect_column.amount_value=00 end end end

renoise.tool():add_keybinding{name="Global:Paketti:Retrig 0RLPB On/Off", invoke=function() 
renoise.song().selected_effect_column_index=1
writeretrig() 
  if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=1 end end} 



----------



function previousEffectColumn()
  -- Fetch the currently selected track
  local selected_track = renoise.song().selected_track
  local num_effect_columns = selected_track.visible_effect_columns

  -- Proceed only if there are visible effect columns
  if num_effect_columns > 0 then
    -- Check if there is a currently selected effect column
    if renoise.song().selected_effect_column == nil then
      -- No effect column selected, select the last one
      renoise.song().selected_effect_column_index = num_effect_columns
    else
      -- Find the index of the currently selected effect column
      local current_index = renoise.song().selected_effect_column_index

      -- If the current column is the first one, or there's only one, go to the previous track's last column
      if current_index == 1 or num_effect_columns == 1 then
        -- Find and select the last track with visible effect columns
        local song = renoise.song()
        local current_track_index = song.selected_track_index
        local track_count = #song.tracks

        -- Loop through tracks starting from the previous track
        local found = false
        for i = current_track_index - 1, 1, -1 do
          if song.tracks[i].visible_effect_columns > 0 then
            song.selected_track_index = i
            song.selected_effect_column_index = song.tracks[i].visible_effect_columns
            found = true
            break
          end
        end

        -- If no previous track with visible columns was found, loop from the end
        if not found then
          for i = track_count, current_track_index + 1, -1 do
            if song.tracks[i].visible_effect_columns > 0 then
              song.selected_track_index = i
              song.selected_effect_column_index = song.tracks[i].visible_effect_columns
              break
            end
          end
        end
      else
        -- Move to the previous effect column in the current track
        renoise.song().selected_effect_column_index = current_index - 1
      end
    end
  else
    print("The selected track has no visible effect columns.")
  end
end



function nextEffectColumn()
  local selected_track = renoise.song().selected_track
  local num_effect_columns = selected_track.visible_effect_columns

  -- Proceed only if there are visible effect columns
  if num_effect_columns > 0 then
    -- Check if there is a currently selected effect column
    if renoise.song().selected_effect_column == nil then
      -- No effect column selected, select the first one
      renoise.song().selected_effect_column_index = 1
    else
      -- Find the index of the currently selected effect column
      local current_index = renoise.song().selected_effect_column_index
      
      -- If the current column is the last one, or there's only one, go to the next track's first column
      if current_index == num_effect_columns or num_effect_columns == 1 then
        -- Find and select the first track with visible effect columns
        local song = renoise.song()
        local current_track_index = song.selected_track_index
        local track_count = #song.tracks

        -- Loop through tracks starting from the next track
        local found = false
        for i = current_track_index + 1, track_count do
          if song.tracks[i].visible_effect_columns > 0 then
            song.selected_track_index = i
            song.selected_effect_column_index = 1
            found = true
            break
          end
        end

        if not found then
          for i = 1, current_track_index - 1 do
            if song.tracks[i].visible_effect_columns > 0 then
              song.selected_track_index = i
              song.selected_effect_column_index = 1
              break
            end
          end
        end
      else
        renoise.song().selected_effect_column_index = current_index + 1
      end
    end
  else
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Select Previous Effect Column", invoke=function() previousEffectColumn() end}
renoise.tool():add_keybinding{name="Global:Paketti:Select Next Effect Column", invoke=function() nextEffectColumn() end}



--------------------------------------------------------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Clone and Expand Pattern to LPB*2",invoke=function()
local number=nil
local numbertwo=nil
local rs=renoise.song()
write_bpm()
clonePTN()
local nol=nil
      nol=renoise.song().selected_pattern.number_of_lines+renoise.song().selected_pattern.number_of_lines
      renoise.song().selected_pattern.number_of_lines=nol

number=renoise.song().transport.lpb*2
if number == 1 then number = 2 end
if number > 128 then number=128 
renoise.song().transport.lpb=number
  write_bpm()
  Deselect_All()
  MarkTrackMarkPattern()
  MarkTrackMarkPattern()
  ExpandSelection()
  Deselect_All()
  return end
renoise.song().transport.lpb=number
  write_bpm()
  Deselect_All()
  MarkTrackMarkPattern()
  MarkTrackMarkPattern()
  ExpandSelection()
  Deselect_All()
end}

renoise.tool():add_keybinding{name="Global:Paketti:Clone and Shrink Pattern to LPB/2",invoke=function()
local number=nil
local numbertwo=nil
local rs=renoise.song()
write_bpm()
clonePTN()
Deselect_All()
MarkTrackMarkPattern()
MarkTrackMarkPattern()
ShrinkSelection()
Deselect_All()
local nol=nil
      nol=renoise.song().selected_pattern.number_of_lines/2
      renoise.song().selected_pattern.number_of_lines=nol

number=renoise.song().transport.lpb/2
if number == 1 then number = 2 end
if number > 128 then number=128 
renoise.song().transport.lpb=number
  write_bpm()
return end
renoise.song().transport.lpb=number
  write_bpm()
end}
-----------------

-- Columnizer, +1 / -1 / +10 / -10 on current_row, display needed column
function columns(chg,thing)
local song=renoise.song()
local s=renoise.song()
local snci=song.selected_note_column_index
local seci=song.selected_effect_column_index
local sst=s.selected_track
local columns={}

if ( snci > 0 ) then 
columns[1] = s.selected_note_column.delay_value
columns[2] = s.selected_note_column.panning_value
columns[3] = s.selected_note_column.volume_value
elseif ( seci > 0 ) then
columns[4] = s.selected_effect_column.number_value
columns[5] = s.selected_effect_column.amount_value
end

 local nc = s.selected_note_column
 local nci = s.selected_note_column_index
 local currPatt = s.selected_pattern_index
 local currTrak = s.selected_track_index
 local currLine = s.selected_line_index
 
if thing == 1 then --if delay columning
        sst.delay_column_visible=true
        nc.delay_value = math.max(0, math.min(255, columns[thing] + chg))
elseif thing == 2 then --if panning
        local center_out_of_bounds=false
        changepan(chg, center_out_of_bounds)
elseif thing == 3 then --if volume columning
        sst.volume_column_visible=true
        nc.volume_value = math.max(0, math.min(128, columns[thing] + chg))
elseif thing == 4 then --if effect number columning
        s.selected_line.effect_columns[seci].number_value = math.max(0, math.min(255, columns[thing] + chg)) 
elseif thing == 5 then --if effect amount columning
        -- renoise.song().tracks[currTrak].sample_effects_column_visible=true
        s.selected_line.effect_columns[seci].amount_value = math.max(0, math.min(255, columns[thing] + chg)) 
else
-- default, shows panning, delay, volume columns.
        sst.delay_column_visible=true
        sst.panning_column_visible=true
        sst.volume_column_visible=true
end
 --nc.delay_value=(d+chg)
 --if nc.delay_value == 0 and chg < 0 then
  --move_up(chg)
 --elseif nc.delay_value == 255 and chg > 0 then
  --move_down(chg)
 --else
 -- nc.delay_value
--end
end

----------
--Shortcut for setting Panning +1/+10/-10/-1 on current_row - automatically displays the panning column.
--Lots of help from Joule, Raul/ulneiz, Ledger, dblue! 
function changepan(change,center_out_of_bounds)
-- Set the behaviour when going out of bounds.
-- If centering (to 0x40) then pan < 0 or > 0x80 will reset the new value back to center.
-- Else just clip to the valid pan range 0x00 to 0x80. (Default behaviour)
center_out_of_bounds = center_out_of_bounds or false
 
-- Local reference to the song.
local s = renoise.song()
  
-- Local reference to the selected note column.
local nc = s.selected_note_column
  
-- If no valid note column is selected...
if nc == nil then return false end
  
-- When triggering the function - always make panning column visible.
s.selected_track.panning_column_visible=true
  
-- Store the current pan value
local pan = nc.panning_value
  
-- If the pan value is empty, set the default center value (0x40)
if pan == renoise.PatternLine.EMPTY_PANNING then pan=0x40 end
  
-- Apply the pan change.
pan = pan + change

-- If wrapping to center and out of bounds, reset to center.
if center_out_of_bounds and (pan < 0x00 or pan > 0x80) then pan=0x40
  
-- Else...
  else

-- Clip to valid pan range.
pan=math.min(0x80, math.max(0x00, pan))    
end
  
-- If the final value ends up back at exact center then show an empty panning column instead.
if pan==0x40 then
   pan = renoise.PatternLine.EMPTY_PANNING end  
  
-- Finally shove the new value back into the note column.
nc.panning_value = pan 
end

function columnspart2(chg,thing)
local columns = {[4] = renoise.song().selected_effect_column.number_value,
                 [5] = renoise.song().selected_effect_column.amount_value}

 local nc = renoise.song().selected_note_column
 local nci = renoise.song().selected_note_column_index

 local currPatt = renoise.song().selected_pattern_index
 local currTrak = renoise.song().selected_track_index
 local currLine = renoise.song().selected_line_index

if thing == 4 then --effect number column
 renoise.song().patterns[currPatt].tracks[currTrak].lines[currLine].effect_columns[1].number_value = math.max(0, math.min(255, columns[thing] + chg)) 
elseif thing == 5 then --effect amount column
 renoise.song().patterns[currPatt].tracks[currTrak].lines[currLine].effect_columns[1].amount_value = math.max(0, math.min(255, columns[thing] + chg)) 
else end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Delay +1",invoke=function() columns(1,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Delay -1",invoke=function() columns(-1,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Delay +10",invoke=function() columns(10,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Delay -10",invoke=function() columns(-10,1) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Delay +1 (2nd)",invoke=function() columns(1,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Delay -1 (2nd)",invoke=function() columns(-1,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Delay +10 (2nd)",invoke=function() columns(10,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Delay -10 (2nd)",invoke=function() columns(-10,1) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning +1",invoke=function() columns(1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning -1",invoke=function() columns(-1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning +10",invoke=function() columns(10,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning -10",invoke=function() columns(-10,2) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning +1 (2nd)",invoke=function() columns(1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning -1 (2nd)",invoke=function() columns(-1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning +10 (2nd)",invoke=function() columns(10,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning -10 (2nd)",invoke=function() columns(-10,2) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Volume +1",invoke=function() columns(1,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Volume -1",invoke=function() columns(-1,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Volume +10",invoke=function() columns(10,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Volume -10",invoke=function() columns(-10,3) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Number +1",invoke=function() columns(1,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Number -1",invoke=function() columnspart2(-1,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Number +10",invoke=function() columnspart2(10,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Number -10",invoke=function() columnspart2(-10,4) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Amount +1",invoke=function() columnspart2(1,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Amount -1",invoke=function() columnspart2(-1,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Amount +10",invoke=function() columnspart2(10,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Amount -10",invoke=function() columnspart2(-10,5) end}

