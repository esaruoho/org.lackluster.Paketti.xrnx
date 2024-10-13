
-- Function to mute or unmute the selected note column
function muteUnmuteNoteColumn()
  -- Access the song object
  local s = renoise.song()
  -- Get the selected track and note column indices
  local sti = s.selected_track_index
  local snci = s.selected_note_column_index

  -- Check if a note column is selected
  if snci == 0 then
    return
  else
    -- Access the selected track
    local track = s:track(sti)
    -- Check if the note column is muted and toggle its state
    if track:column_is_muted(snci) then
      track:set_column_is_muted(snci, false)
    else
      track:set_column_is_muted(snci, true)
    end
  end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Mute/Unmute Note Column", invoke=function() muteUnmuteNoteColumn() end}




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
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column L00 Track Volume Level 0 On/Off",invoke=function() voloff() end}

---------------
function RecordFollowOffPattern()
local t=renoise.song().transport
local w = renoise.app().window
--w.active_middle_frame = 1
if t.edit_mode == false then t.edit_mode=true else t.edit_mode=false end
if t.follow_player == false then return else t.follow_player=false end end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Record+Follow Off",invoke=function() RecordFollowOffPattern() end}

-- Set Delay +1 / -1 / +10 / -10 on current_row, display delay column
function delayInput(chg)
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delay Column Increase (+1)",invoke=function() delayInput(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delay Column Decrease (-1)",invoke=function() delayInput(-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delay Column Increase (+10)",invoke=function() delayInput(10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delay Column Decrease (-10)",invoke=function() delayInput(-10) end}

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

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Collapse All Tracks",invoke=function() Collapser() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Uncollapse All Tracks",invoke=function() Uncollapser() end}
--Global keyboard shortcuts
renoise.tool():add_keybinding{name="Global:Paketti:Uncollapse All Tracks",invoke=function() Uncollapser() end}
renoise.tool():add_keybinding{name="Global:Paketti:Collapse All Tracks",invoke=function() Collapser() end}
--Menu entries for Pattern Editor and Mixer
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Uncollapse All Tracks",invoke=function() Uncollapser() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Collapse All Tracks",invoke=function() Collapser() end}
renoise.tool():add_menu_entry{name="--Mixer:Paketti..:Uncollapse All Tracks",invoke=function() Uncollapser() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Collapse All Tracks",invoke=function() Collapser() end}

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
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:KapsLock CapsLock Caps Lock Note Off",invoke=function() CapsLok() end}
----------------------------------------------------------------------------------------------------
function ptnLength(number) local rs=renoise.song() rs.patterns[rs.selected_pattern_index].number_of_lines=number end

function phrLength(number) local s=renoise.song() 
renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index].number_of_lines=number end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 001 (001)",invoke=function() ptnLength(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 004 (004)",invoke=function() ptnLength(4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 006 (006)",invoke=function() ptnLength(6) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 008 (008)",invoke=function() ptnLength(8) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 012 (00C)",invoke=function() ptnLength(12) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 016 (010)",invoke=function() ptnLength(16) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 024 (018)",invoke=function() ptnLength(24) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 032 (020)",invoke=function() ptnLength(32) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 048 (030)",invoke=function() ptnLength(48) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 064 (040)",invoke=function() ptnLength(64) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 096 (060)",invoke=function() ptnLength(96) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 128 (080)",invoke=function() ptnLength(128) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 192 (0C0)",invoke=function() ptnLength(192) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 256 (100)",invoke=function() ptnLength(256) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 384 (180)",invoke=function() ptnLength(384) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to 512 (200)",invoke=function() ptnLength(512) end}

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 001 (001)",invoke=function() phrLength(1) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 004 (004)",invoke=function() phrLength(4) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 006 (006)",invoke=function() phrLength(6) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 008 (008)",invoke=function() phrLength(8) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 012 (00C)",invoke=function() phrLength(12) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 016 (010)",invoke=function() phrLength(16) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 024 (018)",invoke=function() phrLength(24) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 032 (020)",invoke=function() phrLength(32) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 048 (030)",invoke=function() phrLength(48) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 064 (040)",invoke=function() phrLength(64) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 096 (060)",invoke=function() phrLength(96) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 128 (080)",invoke=function() phrLength(128) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 192 (0C0)",invoke=function() phrLength(192) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 256 (100)",invoke=function() phrLength(256) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 384 (180)",invoke=function() phrLength(384) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 512 (200)",invoke=function() phrLength(512) end}

renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 001 (001)",invoke=function() ptnLength(1) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 004 (004)",invoke=function() ptnLength(4) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 006 (006)",invoke=function() ptnLength(6) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 008 (008)",invoke=function() ptnLength(8) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 012 (00C)",invoke=function() ptnLength(12) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 016 (010)",invoke=function() ptnLength(16) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 024 (018)",invoke=function() ptnLength(24) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 032 (020)",invoke=function() ptnLength(32) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 048 (030)",invoke=function() ptnLength(48) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 064 (040)",invoke=function() ptnLength(64) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 096 (060)",invoke=function() ptnLength(96) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 128 (080)",invoke=function() ptnLength(128) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 192 (0C0)",invoke=function() ptnLength(192) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 256 (100)",invoke=function() ptnLength(256) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 384 (180)",invoke=function() ptnLength(384) end}
renoise.tool():add_midi_mapping{name="Paketti:Set Pattern Length to 512 (200)",invoke=function() ptnLength(512) end}
--------------
function efxwrite(effect, x, y)
  local s = renoise.song()
  local counter = nil 
  local currentamount = nil
  local old_x = nil
  local old_y = nil
  local new_x = nil
  local new_y = nil

  if s.selection_in_pattern == nil then
    -- If no selection is set, output to the row that the cursor is on
    local current_line_index = s.selected_line_index
    
    if s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).amount_value == 0 and (x < 0 or y < 0) then
      s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).number_string = ""
    else
      s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).number_string = effect
      old_y = s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).amount_value % 16
      old_x = math.floor(s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).amount_value / 16)
      
      new_x = old_x + x
      new_y = old_y + y
      
      if new_x > 15 then new_x = 15 end
      if new_y > 15 then new_y = 15 end
      if new_y < 1 then new_y = 0 end
      if new_x < 1 then new_x = 0 end
      
      counter = (16 * new_x) + new_y
      s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).amount_value = counter
    end
  else
    -- If a selection is set, process the selection range
    for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
      if s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value == 0 and (x < 0 or y < 0) then
        s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).number_string = ""
      else
        s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).number_string = effect
        old_y = s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value % 16
        old_x = math.floor(s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value / 16)
        
        new_x = old_x + x
        new_y = old_y + y
        
        if new_x > 15 then new_x = 15 end
        if new_y > 15 then new_y = 15 end
        if new_y < 1 then new_y = 0 end
        if new_x < 1 then new_x = 0 end
        
        counter = (16 * new_x) + new_y
        s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(i):effect_column(1).amount_value = counter
      end
    end
  end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column AXx Arp Amount Xx (-1)",invoke=function() efxwrite("0A",-1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column AXx Arp Amount Xx (+1)",invoke=function() efxwrite("0A",1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column AxY Arp Amount xY (-1)",invoke=function() efxwrite("0A",0,-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column AxY Arp Amount xY (+1)",invoke=function() efxwrite("0A",0,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column VXy Vibrato Amount Xy (-1)",invoke=function() efxwrite("0V",-1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column VXy Vibrato Amount Xy (+1)",invoke=function() efxwrite("0V",1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column VxY Vibrato Amount xY (-1)",invoke=function() efxwrite("0V",0,-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column VxY Vibrato Amount xY (+1)",invoke=function() efxwrite("0V",0,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column TXy Tremolo Amount Xy (-1)",invoke=function() efxwrite("0T",-1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column TXy Tremolo Amount Xy (+1)",invoke=function() efxwrite("0T",1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column TxY Tremolo Amount xY (-1)",invoke=function() efxwrite("0T",0,-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column TxY Tremolo Amount xY (+1)",invoke=function() efxwrite("0T",0,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column RXy Retrig Amount Xy (-1)",invoke=function() efxwrite("0R",-1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column RXy Retrig Amount Xy (+1)",invoke=function() efxwrite("0R",1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column RxY Retrig Amount xY (-1)",invoke=function() efxwrite("0R",0,-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column RxY Retrig Amount xY (+1)",invoke=function() efxwrite("0R",0,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column CXy Cut Volume Amount Xy (-1)",invoke=function() efxwrite("0C",-1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column CXy Cut Volume Amount Xy (+1)",invoke=function() efxwrite("0C",1,0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column CxY Cut Volume Amount xY (-1)",invoke=function() efxwrite("0C",0,-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column CxY Cut Volume Amount xY (+1)",invoke=function() efxwrite("0C",0,1) end}
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

renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity (-1)",invoke=function() computerKeyboardVolChange(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity (+1)",invoke=function() computerKeyboardVolChange(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity (-10)",invoke=function() computerKeyboardVolChange(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity (+10)",invoke=function() computerKeyboardVolChange(10) end}

--BPM +1 / -1 / +0.1 / -0.1 (2024 update)
function adjust_bpm(bpm_delta)
  local t = renoise.song().transport
  t.bpm = math.max(20, math.min(999, t.bpm + bpm_delta))
renoise.app():show_status("BPM: " .. t.bpm)
end

renoise.tool():add_keybinding{name="Global:Paketti:BPM Decrease (-1)",invoke=function() adjust_bpm(-1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Increase (+1)",invoke=function() adjust_bpm(1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Decrease (-0.1)",invoke=function() adjust_bpm(-0.1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Increase (+0.1)",invoke=function() adjust_bpm(0.1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Decrease (-0.5)",invoke=function() adjust_bpm(-0.5, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Increase (+0.5)",invoke=function() adjust_bpm(0.5, 0) end}

renoise.tool():add_midi_mapping{name="Paketti:BPM Decrease (-1)",invoke=function(message) if message:is_trigger() then adjust_bpm(-1, 0) end end}
renoise.tool():add_midi_mapping{name="Paketti:BPM Increase (+1)",invoke=function(message) if message:is_trigger() then adjust_bpm(1, 0) end end}
renoise.tool():add_midi_mapping{name="Paketti:BPM Decrease (-0.1)",invoke=function(message) if message:is_trigger() then adjust_bpm(-0.1, 0) end end}
renoise.tool():add_midi_mapping{name="Paketti:BPM Increase (+0.1)",invoke=function(message) if message:is_trigger() then adjust_bpm(0.1, 0) end end}
renoise.tool():add_midi_mapping{name="Paketti:BPM Decrease (-0.5)",invoke=function(message) if message:is_trigger() then adjust_bpm(-0.5, 0) end end}
renoise.tool():add_midi_mapping{name="Paketti:BPM Increase (+0.5)",invoke=function(message) if message:is_trigger() then adjust_bpm(0.5, 0) end end}



function pakettiPatternDoubler()
  -- Retrieve the current song object
  local song = renoise.song()
  
  -- Get the currently selected pattern index
  local pattern_index = song.selected_pattern_index
  
  -- Get the number of lines in the selected pattern
  local old_patternlength = song.selected_pattern.number_of_lines
  
  -- Calculate the new pattern length by doubling the old length
  local new_patternlength = old_patternlength * 2
  
  -- Get the currently selected line index
  local current_line = song.selected_line_index

  -- Check if the new pattern length is within the allowed limit
  if new_patternlength <= renoise.Pattern.MAX_NUMBER_OF_LINES then
    -- Set the new pattern length
    song.selected_pattern.number_of_lines = new_patternlength

    -- Loop through each track in the selected pattern
    for track_index, pattern_track in ipairs(song.selected_pattern.tracks) do
      -- Copy notes in the pattern
      if not pattern_track.is_empty then
        for line_index = 1, old_patternlength do
          -- Copy each line to the corresponding new position
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
          local new_time = point.time + old_patternlength
          -- Ensure new time does not exceed the new pattern length
          if new_time <= new_patternlength then
            table.insert(new_points, {time = new_time, value = point.value})
          end
        end

        -- Add the new points to the automation
        for _, new_point in ipairs(new_points) do
          automation:add_point_at(new_point.time, new_point.value)
        end
      end
    end

    -- Adjust the selected line index
    song.selected_line_index = current_line + old_patternlength
    renoise.app():show_status("Pattern doubled successfully.")
  else
    -- Print a message if the new pattern length exceeds the limit
    renoise.app():show_status("New pattern length exceeds " .. renoise.Pattern.MAX_NUMBER_OF_LINES .. " lines, operation cancelled.")
  end
end

function pakettiPatternHalver()
  local song = renoise.song()
  local old_patternlength = song.selected_pattern.number_of_lines
  local resultlength = math.floor(old_patternlength / 2)
  local current_line = song.selected_line_index

  -- Check if the result length is less than 1, which would be invalid
  if resultlength < 1 then
    print("Resulting pattern length is too small, operation cancelled.")
    return
  end

  -- Set the new pattern length
  song.selected_pattern.number_of_lines = resultlength

  -- Adjust automation for each track
  for track_index, track in ipairs(song.selected_pattern.tracks) do
    local track_automations = song.patterns[song.selected_pattern_index].tracks[track_index].automation
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

  -- Adjust the cursor position to maintain the same relative distance from the end
  local relative_distance_from_end = old_patternlength - current_line
  local new_line = resultlength - relative_distance_from_end

  -- Ensure the new line is within the valid range
  if new_line < 1 then new_line = 1 end
  if new_line > resultlength then new_line = resultlength end

  song.selected_line_index = new_line
end



-- Add menu entries and keybindings for the tool
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}

renoise.tool():add_keybinding{name="Mixer:Paketti:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}

-- The function can be bound to a menu item or a keybinding within Renoise to make it easily accessible
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Paketti Pattern Halver", invoke = pakettiPatternHalver}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Paketti Pattern Halver", invoke = pakettiPatternHalver}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Paketti Pattern Halver", invoke = pakettiPatternHalver}
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

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:BPM&LPB..:Write Current BPM&LPB to Master Column",invoke=function() write_bpm() end}

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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Renoise Random BPM & Write BPM/LPB to Master",
    invoke = function()
        local randombpm = {80, 100, 115, 123, 128, 132, 135, 138, 160}
        math.randomseed(os.time())
        local prefix = randombpm[math.random(#randombpm)]
        renoise.song().transport.bpm = prefix

        if renoise.tool().preferences.RandomBPM.value then 
      
            write_bpm()
        end
    end}


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
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:BPM&LPB..:Play at 75% Speed (Song BPM)", invoke=function() playat75()  end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:BPM&LPB..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}

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
  local s = renoise.song()
  if s.selection_in_pattern == nil then return end

  local start_track = s.selection_in_pattern.start_track
  local end_track = s.selection_in_pattern.end_track
  local start_line = s.selection_in_pattern.start_line
  local end_line = s.selection_in_pattern.end_line
  local start_column = s.selection_in_pattern.start_column
  local end_column = s.selection_in_pattern.end_column

  -- Iterate through each selected track
  for track_index = start_track, end_track do
    local track = s:track(track_index)
    local pattern_track = s:pattern(s.selected_pattern_index):track(track_index)

    local visible_note_columns = track.visible_note_columns
    local visible_effect_columns = track.visible_effect_columns

    -- Determine column range to clear for this track
    local track_column_start, track_column_end

    if track_index == start_track then
      -- If it's the first track in the selection, use start_column
      track_column_start = start_column
    else
      -- For subsequent tracks, start at column 1
      track_column_start = 1
    end

    if track_index == end_track then
      -- If it's the last track in the selection, use end_column
      track_column_end = end_column
    else
      -- For previous tracks, end at the maximum number of columns
      track_column_end = visible_note_columns + visible_effect_columns
    end

    -- Calculate which effect columns are selected for this track
    local effect_column_start = math.max(1, track_column_start - visible_note_columns)
    local effect_column_end = math.min(visible_effect_columns, track_column_end - visible_note_columns)

    -- Skip if no effect columns are selected for this track
    if effect_column_end >= 1 then
      -- Iterate through selected lines
      for line_index = start_line, end_line do
        local line = pattern_track:line(line_index)

        if not line.is_empty then
          -- Iterate through the selected effect columns and clear them
          for effect_column_index = effect_column_start, effect_column_end do
            line:effect_column(effect_column_index):clear()
          end
        end
      end
    end
  end
end




renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Wipe Effects From Selection",invoke=function() WipeEfxFromSelection() end}
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delete/Wipe/Clear Effect Column Content from Current Track",invoke=function() delete_effect_column() end}
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Generate Delay Value on Note Columns",invoke=function() GenerateDelayValue() end}
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
renoise.tool():add_keybinding{name="Pattern Editor:Navigation:Paketti Jump to Column (Next) (Note/FX)",invoke=function() cycle_column("next") end}
renoise.tool():add_keybinding{name="Pattern Editor:Navigation:Paketti Jump to Column (Previous) (Note/FX)",invoke=function() cycle_column("prev") end}
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Pattern Shrink (dBlue)",invoke=function()
local pattern = renoise.song().selected_pattern
resize_pattern(pattern, pattern.number_of_lines * 0.5, 0) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Pattern Expand (dBlue)",invoke=function()
local pattern = renoise.song().selected_pattern
resize_pattern(pattern, pattern.number_of_lines * 2, 0 ) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Pattern Shrink + Resize (dBlue)",invoke=function()
local pattern = renoise.song().selected_pattern
resize_pattern(pattern, pattern.number_of_lines * 0.5,1 ) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Pattern Expand + Resize (dBlue)",invoke=function()
local pattern = renoise.song().selected_pattern
resize_pattern(pattern, pattern.number_of_lines * 2,1) end}
-------------------
function bend(amount)
  local counter = nil 
  local s = renoise.song()

  if s.selection_in_pattern == nil then
    -- If no selection is set, output to the row that the cursor is on
    local current_line_index = s.selected_line_index
    
    counter = s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[current_line_index].effect_columns[1].amount_value + amount

    if counter > 255 then counter = 255 end
    if counter < 1 then counter = 0 end
    s.patterns[s.selected_pattern_index].tracks[s.selected_track_index].lines[current_line_index].effect_columns[1].amount_value = counter
  else
    -- If a selection is set, process the selection range
    local start_track = s.selection_in_pattern.start_track
    local end_track = s.selection_in_pattern.end_track
    for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
      for t = start_track, end_track do
        counter = s.patterns[s.selected_pattern_index].tracks[t].lines[i].effect_columns[1].amount_value + amount 

        if counter > 255 then counter = 255 end
        if counter < 1 then counter = 0 end
        s.patterns[s.selected_pattern_index].tracks[t].lines[i].effect_columns[1].amount_value = counter
      end
    end
  end
end

function effectamount(amount, effectname)
  -- Massive thanks to pandabot for the optimization tricks!
  local s = renoise.song()
  local counter = nil

  if s.selection_in_pattern == nil then
    -- If no selection is set, output to the row that the cursor is on
    local current_line_index = s.selected_line_index
    
    s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).number_string = effectname
    counter = s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).amount_value + amount

    if counter > 255 then counter = 255 end
    if counter < 1 then counter = 0 end
    s:pattern(s.selected_pattern_index):track(s.selected_track_index):line(current_line_index):effect_column(1).amount_value = counter
  else
    -- If a selection is set, process the selection range
    local start_track = s.selection_in_pattern.start_track
    local end_track = s.selection_in_pattern.end_track
    for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
      for t = start_track, end_track do
        s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(1).number_string = effectname
        counter = s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(1).amount_value + amount

        if counter > 255 then counter = 255 end
        if counter < 1 then counter = 0 end
        s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(1).amount_value = counter
      end
    end
  end
end



renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (-1)",invoke=function() bend(-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (-10)",invoke=function() bend(-10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (-1) (2nd)",invoke=function() bend(-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (-10) (2nd)",invoke=function() bend(-10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (-1) (3rd)",invoke=function() bend(-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (-10) (3rd)",invoke=function() bend(-10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (+1)",invoke=function() bend(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (+10)",invoke=function() bend(10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (+1) (2nd)",invoke=function() bend(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (+10) (2nd)",invoke=function() bend(10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (+1) (3rd)",invoke=function() bend(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Infobyte (+10) (3rd)",invoke=function() bend(10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Gxx Glide (-1)",invoke=function() effectamount(-1,"0G") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Gxx Glide (-10)",invoke=function() effectamount(-10,"0G") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Gxx Glide (+1)",invoke=function() effectamount(1,"0G") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Gxx Glide (+10)",invoke=function() effectamount(10,"0G") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (+1)",invoke=function() effectamount(1,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (-1)",invoke=function() effectamount(-1,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (+10)",invoke=function() effectamount(10,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (-10)",invoke=function() effectamount(-10,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (+1)",invoke=function() effectamount(1,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (-1)",invoke=function() effectamount(-1,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (+10)",invoke=function() effectamount(10,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (-10)",invoke=function() effectamount(-10,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (+1) (2nd)",invoke=function() effectamount(1,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (-1) (2nd)",invoke=function() effectamount(-1,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (+10) (2nd)",invoke=function() effectamount(10,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (-10) (2nd)",invoke=function() effectamount(-10,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (+1) (2nd)",invoke=function() effectamount(1,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (-1) (2nd)",invoke=function() effectamount(-1,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (+10) (2nd)",invoke=function() effectamount(10,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (-10) (2nd)",invoke=function() effectamount(-10,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (+1) (3rd)",invoke=function() effectamount(1,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (-1) (3rd)",invoke=function() effectamount(-1,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (+10) (3rd)",invoke=function() effectamount(10,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Uxx Slide Pitch Up (-10) (3rd)",invoke=function() effectamount(-10,"0U") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (+1) (3rd)",invoke=function() effectamount(1,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (-1) (3rd)",invoke=function() effectamount(-1,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (+10) (3rd)",invoke=function() effectamount(10,"0D") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column Dxx Slide Pitch Down (-10) (3rd)",invoke=function() effectamount(-10,"0D") end}

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:(L00) Set Track Volume Level",invoke=function() voloff() end}


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
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Switch Effect Column/Note Column",invoke=function() switchcolumns() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:Switch Effect Column/Note Column",invoke=function() switchcolumns() end}
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Clear Current Row", invoke=function() ClearRow() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Clear Current Row 2nd", invoke=function() ClearRow() end}
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column ZBxx Jump To Row (Next)", invoke=function() JumpToNextRow() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:ZBxx Jump To Row (Next)", invoke=function() JumpToNextRow() end}

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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column B01 Reverse Sample Effect On/Off",invoke=function()
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


renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Effect Columns..:B01 Reverse Sample Effect On/Off",invoke=function()
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

function effectColumnB00()
local nci=renoise.song().selected_note_column_index 
renoise.song().selected_effect_column_index=1
revnote() 
if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=nci
--renoise.song().selected_note_column_index=1 
end 
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column B00 Reverse Sample Effect On/Off",invoke=function() effectColumnB00()end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column B00 Reverse Sample Effect On/Off (2nd)",invoke=function() effectColumnB00()end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:B00 Reverse Sample Effect On/Off",invoke=function() effectColumnB00()end}


renoise.tool():add_midi_mapping{name="Paketti:Effect Column B00 Reverse Sample Effect On/Off",invoke=function() 
renoise.app().window.active_middle_frame=1
renoise.song().selected_effect_column_index=1
revnote() 
if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=1 end end}
----------------------------------------------------------------------------------------------------------------------------------
function displayEffectColumn(number) local rs=renoise.song() rs.tracks[rs.selected_track_index].visible_effect_columns=number end

for dec=1,8 do
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Display Effect Column " .. dec,invoke=function() 
  renoise.app().window.active_middle_frame=1
  displayEffectColumn(dec) end}
end
-- Display user-specific amount of note columns or effect columns:
function displayNoteColumn(number) local rs=renoise.song() if rs.tracks[rs.selected_track_index].visible_note_columns == 0 then return else rs.tracks[rs.selected_track_index].visible_note_columns=number end end

for dnc=1,12 do
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Display Note Column " .. dnc,invoke=function() displayNoteColumn(dnc) end}
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column L00/LC0 Volume Effect Switch", invoke=function() 
renoise.song().selected_effect_column_index=1
write_effect("0L") 

  if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=1 end end} 
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:L00/LC0 Volume Effect Switch", invoke=function() 
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Effect Column 0R(LPB) Retrig On/Off", invoke=function() 
renoise.song().selected_effect_column_index=1
writeretrig() 
  if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
else renoise.song().selected_note_column_index=1 end end} 

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:0R(LPB) Retrig On/Off", invoke=function() 
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Select Effect Column (Previous)", invoke=function() previousEffectColumn() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Select Effect Column (Next)", invoke=function() nextEffectColumn() end}


function cloneAndExpandPatternToLPBDouble()
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


end


--------------------------------------------------------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Clone and Expand Pattern to LPB*2",invoke=function() cloneAndExpandPatternToLPBDouble()
end}


function cloneAndShrinkPatternToLPBHalve()
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
end


renoise.tool():add_keybinding{name="Global:Paketti:Clone and Shrink Pattern to LPB/2",invoke=function()
cloneAndShrinkPatternToLPBHalve()
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
    local song = renoise.song()
local effect_column_index
    -- Handle nil for selected_effect_column_index, default to 1

if renoise.song().selected_effect_column_index == nil or renoise.song().selected_effect_column_index == 0 then
effect_column_index = 1
else 
effect_column_index = song.selected_effect_column_index
end

    local currPatt = song.selected_pattern_index
    local currTrak = song.selected_track_index
    local currLine = song.selected_line_index
    local track = song.patterns[currPatt].tracks[currTrak]
    
    -- Ensure the effect column exists
    if effect_column_index > renoise.song().tracks[currTrak].visible_effect_columns then
        renoise.app():show_status("Effect column index out of range")
        return
    end
    
    local effect_column = track.lines[currLine].effect_columns[effect_column_index]
    if not effect_column then
        renoise.app():show_status("No effect column available at index " .. tostring(effect_column_index))
        return
    end

    -- Fetch the current values for the selected effect column
    local columns = {
        [4] = effect_column.number_value,
        [5] = effect_column.amount_value
    }

    -- Adjust the values based on the `thing` parameter
    if thing == 4 then
        effect_column.number_value = math.max(0, math.min(255, columns[thing] + chg))
    elseif thing == 5 then
        effect_column.amount_value = math.max(0, math.min(255, columns[thing] + chg))
    end
end


renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Delay (+1)",invoke=function() columns(1,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Delay (+10)",invoke=function() columns(10,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Delay (-1)",invoke=function() columns(-1,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Delay (-10)",invoke=function() columns(-10,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Delay (+1) (2nd)",invoke=function() columns(1,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Delay (+10) (2nd)",invoke=function() columns(10,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Delay (-1) (2nd)",invoke=function() columns(-1,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Delay (-10) (2nd)",invoke=function() columns(-10,1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning (+1)",invoke=function() columns(1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning (+10)",invoke=function() columns(10,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning (-1)",invoke=function() columns(-1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning (-10)",invoke=function() columns(-10,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning (+1) (2nd)",invoke=function() columns(1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning (+10) (2nd)",invoke=function() columns(10,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning (-1) (2nd)",invoke=function() columns(-1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning (-10) (2nd)",invoke=function() columns(-10,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Volume (+1)",invoke=function() columns(1,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Volume (+10)",invoke=function() columns(10,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Volume (-1)",invoke=function() columns(-1,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Volume (-10)",invoke=function() columns(-10,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Number (+1)",invoke=function() columns(1,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Number (+10)",invoke=function() columnspart2(10,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Number (-1)",invoke=function() columnspart2(-1,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Number (-10)",invoke=function() columnspart2(-10,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Amount (+1)",invoke=function() columnspart2(1,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Amount (+10)",invoke=function() columnspart2(10,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Amount (-1)",invoke=function() columnspart2(-1,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Amount (-10)",invoke=function() columnspart2(-10,5) end}

--------
-- Global variables to store the last track index and color
lastTrackIndex=nil
lastTrackColor=nil
trackNotifierAdded=false -- Flag to track if the notifier was added

-- Function to set color blend for all tracks
function pakettiEditModeSignalerSetAllTracksColorBlend(value)
  for i=1,#renoise.song().tracks do
    renoise.song().tracks[i].color_blend=value
  end
end

-- Function to set color blend for a specific track
function pakettiEditModeSignalerSetTrackColorBlend(index,value)
  renoise.song().tracks[index].color_blend=value
end

-- Function to handle edit mode enabled
function pakettiEditModeSignalerOnEditModeEnabled()
  local song=renoise.song()
  local selectedTrackIndex=song.selected_track_index

  lastTrackIndex=selectedTrackIndex
  lastTrackColor=song.tracks[selectedTrackIndex].color_blend

  local pakettiEditMode=preferences.pakettiEditMode.value

  if pakettiEditMode==3 then
    pakettiEditModeSignalerSetAllTracksColorBlend(40)
  elseif pakettiEditMode==2 then
    pakettiEditModeSignalerSetTrackColorBlend(selectedTrackIndex,40)
  end

  -- Add selected track index notifier if not already added
  if not trackNotifierAdded then
    song.selected_track_index_observable:add_notifier(pakettiEditModeSignalerTrackIndexNotifier)
    trackNotifierAdded=true
  end
end

-- Function to handle edit mode disabled
function pakettiEditModeSignalerOnEditModeDisabled()
  local song=renoise.song()
  local pakettiEditMode=preferences.pakettiEditMode.value

  if lastTrackIndex and pakettiEditMode~=1 then
    pakettiEditModeSignalerSetTrackColorBlend(lastTrackIndex,lastTrackColor)
  end

  -- Set all tracks' color blend to 0
  pakettiEditModeSignalerSetAllTracksColorBlend(0)

  -- Remove selected track index notifier if it was added
  if trackNotifierAdded then
    pcall(function()
      song.selected_track_index_observable:remove_notifier(pakettiEditModeSignalerTrackIndexNotifier)
    end)
    trackNotifierAdded=false
  end
end

-- Notifier for edit mode change
function pakettiEditModeSignalerEditModeNotifier()
  local transport=renoise.song().transport
  if transport.edit_mode then
    pakettiEditModeSignalerOnEditModeEnabled()
  else
    pakettiEditModeSignalerOnEditModeDisabled()
  end
end

-- Notifier for track selection change
function pakettiEditModeSignalerTrackIndexNotifier()
  local song=renoise.song()
  local selectedTrackIndex=song.selected_track_index
  local pakettiEditMode=preferences.pakettiEditMode.value

  if song.transport.edit_mode then
    if pakettiEditMode==3 then
      pakettiEditModeSignalerSetAllTracksColorBlend(40)
    else
      if lastTrackIndex and lastTrackIndex~=selectedTrackIndex and pakettiEditMode~=1 then
        pakettiEditModeSignalerSetTrackColorBlend(lastTrackIndex,lastTrackColor)
      end
      lastTrackIndex=selectedTrackIndex
      lastTrackColor=song.tracks[selectedTrackIndex].color_blend
      if pakettiEditMode==2 then
        pakettiEditModeSignalerSetTrackColorBlend(selectedTrackIndex,40)
      end
    end
  end
end

-- Add notifiers for edit mode change and initial track selection
renoise.tool().app_new_document_observable:add_notifier(function()
  local song=renoise.song()
  song.transport.edit_mode_observable:add_notifier(pakettiEditModeSignalerEditModeNotifier)
  pakettiEditModeSignalerEditModeNotifier() -- Call once to ensure the state is consistent
end)

-- Keybinding and MIDI mapping
function recordTint()
  renoise.song().transport.edit_mode=not renoise.song().transport.edit_mode
end

renoise.tool():add_keybinding{name="Global:Paketti:Toggle Edit Mode and Tint Track",invoke=recordTint}
renoise.tool():add_midi_mapping{name="Paketti:Toggle Edit Mode and Tint Track",invoke=recordTint}


------------------
function pakettiDuplicateEffectColumnToPatternOrSelection()
  -- Obtain the currently selected song and pattern
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local pattern = song.patterns[pattern_index]
  
  -- Obtain the current track and line index
  local track_index = song.selected_track_index
  local line_index = song.selected_line_index
  
  -- Obtain the current effect column command from the selected line
  local current_effects = song:pattern(pattern_index):track(track_index):line(line_index).effect_columns
  
  -- Check if there is a selection in the pattern
  local selection = song.selection_in_pattern
  local start_line, end_line
  
  if selection then
    -- There is a selection, use the selection range
    start_line = selection.start_line
    end_line = selection.end_line
  else
    -- No selection, use the entire pattern
    start_line = 1
    end_line = pattern.number_of_lines
  end
  
  -- Iterate through each line in the range and copy the effect column command
  for i = start_line, end_line do
    local line = song:pattern(pattern_index):track(track_index):line(i)
    for j = 1, #current_effects do
      line.effect_columns[j].number_string = current_effects[j].number_string
      line.effect_columns[j].amount_string = current_effects[j].amount_string
    end
  end
  
  -- Inform the user that the operation was successful
  renoise.app():show_status("Effect column command duplicated to selected rows in the pattern.")
end

-- Add a menu entry to trigger the function
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Duplicate Effect Column Content to Pattern or Selection",invoke=pakettiDuplicateEffectColumnToPatternOrSelection}
renoise.tool():add_keybinding{name="Global:Paketti:Duplicate Effect Column Content to Pattern or Selection",invoke=pakettiDuplicateEffectColumnToPatternOrSelection}
renoise.tool():add_midi_mapping{name="Paketti:Duplicate Effect Column Content to Pattern or Selection",invoke=pakettiDuplicateEffectColumnToPatternOrSelection}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:Duplicate Effect Column Content to Pattern or Selection",invoke=pakettiDuplicateEffectColumnToPatternOrSelection}


------------
-- Function to randomize effect column parameters
function pakettiRandomizeEffectColumnParameters()
  -- Obtain the currently selected song and pattern
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local pattern = song.patterns[pattern_index]
  
  -- Obtain the current track index
  local track_index = song.selected_track_index
  
  -- Check if there is a selection in the pattern
  local selection = song.selection_in_pattern
  local start_line, end_line
  
  if selection then
    -- There is a selection, use the selection range
    start_line = selection.start_line
    end_line = selection.end_line
  else
    -- No selection, use the entire pattern
    start_line = 1
    end_line = pattern.number_of_lines
  end

  -- Randomize effect parameters
  for line_index = start_line, end_line do
    local line = song:pattern(pattern_index):track(track_index):line(line_index)
    for i = 1, #line.effect_columns do
      local effect_type = line.effect_columns[i].number_string
      if effect_type ~= "" then
        local random_value = math.random(0, 255)
        line.effect_columns[i].amount_value = random_value
      end
    end
  end
  
  renoise.app():show_status("Effect column parameters randomized.")
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Randomize Effect Column Parameters",invoke=pakettiRandomizeEffectColumnParameters}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Effect Column Parameters",invoke=pakettiRandomizeEffectColumnParameters}
renoise.tool():add_midi_mapping{name="Paketti:Randomize Effect Column Parameters",invoke=pakettiRandomizeEffectColumnParameters}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:Randomize Effect Column Parameters",invoke=pakettiRandomizeEffectColumnParameters}

--------
function pakettiInterpolateEffectColumnParameters()
  -- Obtain the currently selected song and pattern
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local pattern = song.patterns[pattern_index]
  
  -- Obtain the current track index
  local track_index = song.selected_track_index
  
  -- Check if there is a selection in the pattern
  local selection = song.selection_in_pattern
  local start_line, end_line
  
  if selection then
    -- There is a selection, use the selection range
    start_line = selection.start_line
    end_line = selection.end_line
  else
    -- No selection, use the entire pattern
    start_line = 1
    end_line = pattern.number_of_lines
  end

  -- Interpolate effect parameters
  local first_effect_line = song:pattern(pattern_index):track(track_index):line(start_line).effect_columns
  local last_effect_line = song:pattern(pattern_index):track(track_index):line(end_line).effect_columns

  for i = 1, #first_effect_line do
    local first_value = tonumber(first_effect_line[i].amount_value)
    local last_value = tonumber(last_effect_line[i].amount_value)
    if first_value and last_value then
      for line_index = start_line, end_line do
        local line = song:pattern(pattern_index):track(track_index):line(line_index)
        local t = (line_index - start_line) / (end_line - start_line)
        local interpolated_value = math.floor(first_value + t * (last_value - first_value))
        line.effect_columns[i].number_value = first_effect_line[i].number_value
        line.effect_columns[i].amount_value = interpolated_value
      end
    end
  end
  
  -- Inform the user that the operation was successful
  renoise.app():show_status("Effect column parameters interpolated.")
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Interpolate Effect Column Parameters",invoke=pakettiInterpolateEffectColumnParameters}
renoise.tool():add_keybinding{name="Global:Paketti:Interpolate Effect Column Parameters",invoke=pakettiInterpolateEffectColumnParameters}
renoise.tool():add_midi_mapping{name="Paketti:Interpolate Effect Column Parameters",invoke=pakettiInterpolateEffectColumnParameters}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Effect Columns..:Interpolate Effect Column Parameters",invoke=pakettiInterpolateEffectColumnParameters}

--------
-- Function to flood fill the track with the current note and instrument
function pakettiFloodFill()
  -- Obtain the currently selected song and pattern
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local pattern = song.patterns[pattern_index]
  
  -- Obtain the current track and line index
  local track_index = song.selected_track_index
  local line_index = song.selected_line_index
  local current_note_column = nil
  -- Obtain the current note column from the selected line
if renoise.song().selected_note_column_index ~=  nil then  
  local current_note_column = song:pattern(pattern_index):track(track_index):line(line_index).note_columns[renoise.song().selected_note_column_index]
  else 
  local current_note_column = song:pattern(pattern_index):track(track_index):line(line_index).note_columns[1]
  end
local note_value = song:pattern(pattern_index):track(track_index):line(line_index).note_columns[renoise.song().selected_note_column_index].note_value
local instrument_value = song:pattern(pattern_index):track(track_index):line(line_index).note_columns[renoise.song().selected_note_column_index].instrument_value
--  local note_value = current_note_column.note_value
--  local instrument_value = current_note_column.instrument_value

  -- Check if there is a selection in the pattern
  local selection = song.selection_in_pattern
  local start_line, end_line
  
  if selection then
    -- There is a selection, use the selection range
    start_line = selection.start_line
    end_line = selection.end_line
  else
    -- No selection, use from current onwards
    start_line = renoise.song().selected_line_index
    end_line = pattern.number_of_lines
  end

  -- Iterate through each line in the range and fill with the current note and instrument
  for i = start_line, end_line do
    local line = song:pattern(pattern_index):track(track_index):line(i)
    local note_column = line.note_columns[1]
    note_column.note_value = note_value
    note_column.instrument_value = instrument_value
  end
  
  -- Inform the user that the operation was successful
  renoise.app():show_status("Track or Selection filled with the Current Note and Instrument.")
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Flood Fill Note and Instrument",invoke=pakettiFloodFill}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Flood Fill Note and Instrument",invoke=pakettiFloodFill}
renoise.tool():add_midi_mapping{name="Paketti:Flood Fill Note and Instrument",invoke=pakettiFloodFill}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Flood Fill Note and Instrument",invoke=pakettiFloodFill}
-----------
-- Function to Flood Fill the track with the current note and instrument with an edit step
function pakettiFloodFillWithEditStep()
  -- Obtain the currently selected song and pattern
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local pattern = song.patterns[pattern_index]

  -- Obtain the current track and line index
  local track_index = song.selected_track_index
  local line_index = song.selected_line_index

  -- Obtain the current edit step
  local edit_step = song.transport.edit_step

  -- Obtain the current note column index
  local note_column_index = song.selected_note_column_index

  -- Get the selection in the pattern
  local selection = song.selection_in_pattern
  local start_line, end_line, start_track, end_track, start_column, end_column

  if selection then
    -- There is a selection, use the selection range
    start_line = selection.start_line
    end_line = selection.end_line
    start_track = selection.start_track
    end_track = selection.end_track
    start_column = selection.start_column
    end_column = selection.end_column
  else
    -- No selection, use from the current row onwards in the current track and note column
    start_line = line_index
    end_line = pattern.number_of_lines
    start_track = track_index
    end_track = track_index
    start_column = note_column_index
    end_column = note_column_index
  end

  -- Check if the edit step is larger than the number of lines in the pattern
  if edit_step > (end_line - start_line + 1) then
    renoise.app():show_status("Did not apply Flood Fill with EditStep because EditStep is larger than Amount of Lines in Pattern")
    return
  end

  local found_note = false
  local note_values = {}
  local instrument_values = {}
  local clear_columns = {}

  -- Read the current row's note and instrument values for each track and column in the selection
  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    if track.type ~= renoise.Track.TRACK_TYPE_GROUP and track.type ~= renoise.Track.TRACK_TYPE_SEND and track.type ~= renoise.Track.TRACK_TYPE_MASTER then
      note_values[track_idx] = {}
      instrument_values[track_idx] = {}
      clear_columns[track_idx] = {}
      local first_column = (track_idx == start_track) and start_column or 1
      local last_column = (track_idx == end_track) and end_column or track.visible_note_columns
      for column_index = first_column, last_column do
        local current_note_column = song:pattern(pattern_index):track(track_idx):line(line_index).note_columns[column_index]
        if current_note_column and not current_note_column.is_empty then
          note_values[track_idx][column_index] = current_note_column.note_value
          instrument_values[track_idx][column_index] = current_note_column.instrument_value
          clear_columns[track_idx][column_index] = true
          found_note = true
          -- Debug message to track the note and instrument values
          print(string.format("Read note %d and instrument %d from Track %d, Column %d", current_note_column.note_value, current_note_column.instrument_value, track_idx, column_index))
        elseif current_note_column then
          clear_columns[track_idx][column_index] = false
        end
      end
    end
  end

  if not found_note then
    renoise.app():show_status("There was nothing to Flood Fill with EditStep with.")
    return
  end

  -- Clear all selected note columns except the current row (or start line if selection exists)
  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    if track.type ~= renoise.Track.TRACK_TYPE_GROUP and track.type ~= renoise.Track.TRACK_TYPE_SEND and track.type ~= renoise.Track.TRACK_TYPE_MASTER then
      local first_column = (track_idx == start_track) and start_column or 1
      local last_column = (track_idx == end_track) and end_column or track.visible_note_columns
      for column_index = first_column, last_column do
        if clear_columns[track_idx][column_index] then
          for i = start_line, end_line do
            if selection then
              if i ~= start_line then
                local line = song:pattern(pattern_index):track(track_idx):line(i)
                local note_column = line.note_columns[column_index]
                note_column:clear()
              end
            else
              if i ~= line_index then
                local line = song:pattern(pattern_index):track(track_idx):line(i)
                local note_column = line.note_columns[column_index]
                note_column:clear()
              end
            end
          end
          -- Debug message to track the clearing of rows
          print(string.format("Cleared Track %d, Column %d from Row %d to Row %d", track_idx, column_index, start_line, end_line))
        end
      end
    end
  end

  -- Apply Flood Fill with edit step
  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    if track.type ~= renoise.Track.TRACK_TYPE_GROUP and track.type ~= renoise.Track.TRACK_TYPE_SEND and track.type ~= renoise.Track.TRACK_TYPE_MASTER then
      local first_column = (track_idx == start_track) and start_column or 1
      local last_column = (track_idx == end_track) and end_column or track.visible_note_columns
      for column_index = first_column, last_column do
        if note_values[track_idx][column_index] then
          local note_value = note_values[track_idx][column_index]
          local instrument_value = instrument_values[track_idx][column_index]

          -- Debug message to track the note and instrument values being applied
          print(string.format("Applying Flood Fill to Selection In Pattern, with EditStep %d to Track %d, Column %d using note %d and instrument %d", edit_step, track_idx, column_index, note_value, instrument_value))

          for i = start_line, end_line do
            if edit_step == 0 or (i - start_line) % edit_step == 0 then
              local line = song:pattern(pattern_index):track(track_idx):line(i)
              local note_column = line.note_columns[column_index]
              note_column.note_value = note_value
              note_column.instrument_value = instrument_value
            end
          end
        end
      end
    end
  end

  -- Inform the user that the operation was successful
  renoise.app():show_status("Track / Selection filled with the Current Note and Instrument with EditStep.")
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Flood Fill Note and Instrument with EditStep",invoke=pakettiFloodFillWithEditStep}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Flood Fill Note and Instrument with EditStep",invoke=pakettiFloodFillWithEditStep}
renoise.tool():add_midi_mapping{name="Paketti:Flood Fill Note and Instrument with EditStep",invoke=pakettiFloodFillWithEditStep}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Flood Fill Note and Instrument with EditStep",invoke=pakettiFloodFillWithEditStep}


--------------------
-- Function to Flood Fill the track with the current note, instrument, volume, delay, panning, and sample FX with an edit step
function pakettiFloodFillWithNotReallyEditStep(notstep)
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local pattern = song.patterns[pattern_index]

  local track_index = song.selected_track_index
  local line_index = song.selected_line_index
  local edit_step = notstep
  local note_column_index = song.selected_note_column_index

  local selection = song.selection_in_pattern
  local start_line, end_line, start_track, end_track, start_column, end_column

  if selection then
    start_line = selection.start_line
    end_line = selection.end_line
    start_track = selection.start_track
    end_track = selection.end_track
    start_column = selection.start_column
    end_column = selection.end_column
  else
    start_line = line_index
    end_line = pattern.number_of_lines
    start_track = track_index
    end_track = track_index
    start_column = note_column_index
    end_column = note_column_index
  end

  if notstep > (end_line - start_line + 1) then
    renoise.app():show_status("EditStep is larger than the number of lines in the pattern.")
    return
  end

  local found_note = false
  local note_values = {}
  local instrument_values = {}
  local volume_values = {}
  local delay_values = {}
  local panning_values = {}
  local samplefx_values = {}

  local effect_number_values = {}
  local effect_amount_values = {}
  local clear_columns = {}
  local clear_effect_columns = {}

  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    if track.type ~= renoise.Track.TRACK_TYPE_GROUP and track.type ~= renoise.Track.TRACK_TYPE_SEND and track.type ~= renoise.Track.TRACK_TYPE_MASTER then
      note_values[track_idx] = {}
      instrument_values[track_idx] = {}
      volume_values[track_idx] = {}
      delay_values[track_idx] = {}
      panning_values[track_idx] = {}
      samplefx_values[track_idx] = {}
      clear_columns[track_idx] = {}

      effect_number_values[track_idx] = {}
      effect_amount_values[track_idx] = {}
      clear_effect_columns[track_idx] = {}

      local first_column = (track_idx == start_track) and start_column or 1
      local last_column = (track_idx == end_track) and end_column or track.visible_note_columns

      -- Read Note Columns
      for column_index = first_column, last_column do
        local current_note_column = song:pattern(pattern_index):track(track_idx):line(line_index).note_columns[column_index]
        if current_note_column and not current_note_column.is_empty then
          note_values[track_idx][column_index] = current_note_column.note_value
          instrument_values[track_idx][column_index] = current_note_column.instrument_value
          volume_values[track_idx][column_index] = current_note_column.volume_value
          delay_values[track_idx][column_index] = current_note_column.delay_value
          panning_values[track_idx][column_index] = current_note_column.panning_value
          samplefx_values[track_idx][column_index] = current_note_column.effect_number_value
          clear_columns[track_idx][column_index] = true
          found_note = true
        else
          clear_columns[track_idx][column_index] = false
        end
      end

      -- Read Effect Columns
      for effect_idx = 1, track.visible_effect_columns do
        local effect_column = song:pattern(pattern_index):track(track_idx):line(line_index).effect_columns[effect_idx]
        if effect_column and not effect_column.is_empty then
          effect_number_values[track_idx][effect_idx] = effect_column.number_value
          effect_amount_values[track_idx][effect_idx] = effect_column.amount_value
          clear_effect_columns[track_idx][effect_idx] = true
          found_note = true
        else
          clear_effect_columns[track_idx][effect_idx] = false
        end
      end
    end
  end

  if not found_note then
    renoise.app():show_status("There was nothing to Flood Fill with EditStep with.")
    return
  end

  -- Clear note columns and effect columns if needed
  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    if track.type ~= renoise.Track.TRACK_TYPE_GROUP and track.type ~= renoise.Track.TRACK_TYPE_SEND and track.type ~= renoise.Track.TRACK_TYPE_MASTER then
      local first_column = (track_idx == start_track) and start_column or 1
      local last_column = (track_idx == end_track) and end_column or track.visible_note_columns

      -- Clear Note Columns
      for column_index = first_column, last_column do
        if clear_columns[track_idx][column_index] then
          for i = start_line, end_line do
            if selection then
              if i ~= start_line then
                local line = song:pattern(pattern_index):track(track_idx):line(i)
                local note_column = line.note_columns[column_index]
                note_column:clear()
              end
            else
              if i ~= line_index then
                local line = song:pattern(pattern_index):track(track_idx):line(i)
                local note_column = line.note_columns[column_index]
                note_column:clear()
              end
            end
          end
        end
      end

      -- Clear Effect Columns
      for effect_idx = 1, track.visible_effect_columns do
        if clear_effect_columns[track_idx][effect_idx] then
          for i = start_line, end_line do
            if selection then
              if i ~= start_line then
                local effect_column = song:pattern(pattern_index):track(track_idx):line(i).effect_columns[effect_idx]
                effect_column:clear()
              end
            else
              if i ~= line_index then
                local effect_column = song:pattern(pattern_index):track(track_idx):line(i).effect_columns[effect_idx]
                effect_column:clear()
              end
            end
          end
        end
      end
    end
  end

  -- Apply note columns and effect columns values with EditStep
  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    if track.type ~= renoise.Track.TRACK_TYPE_GROUP and track.type ~= renoise.Track.TRACK_TYPE_SEND and track.type ~= renoise.Track.TRACK_TYPE_MASTER then
      local first_column = (track_idx == start_track) and start_column or 1
      local last_column = (track_idx == end_track) and end_column or track.visible_note_columns

      -- Apply Note Columns
      for column_index = first_column, last_column do
        if note_values[track_idx][column_index] then
          local note_value = note_values[track_idx][column_index]
          local instrument_value = instrument_values[track_idx][column_index]
          local volume_value = volume_values[track_idx][column_index]
          local delay_value = delay_values[track_idx][column_index]
          local panning_value = panning_values[track_idx][column_index]
          local samplefx_value = samplefx_values[track_idx][column_index]

          for i = start_line, end_line do
            if edit_step == 0 or (i - start_line) % edit_step == 0 then
              local line = song:pattern(pattern_index):track(track_idx):line(i)
              local note_column = line.note_columns[column_index]
              note_column.note_value = note_value
              note_column.instrument_value = instrument_value
              note_column.volume_value = volume_value
              note_column.delay_value = delay_value
              note_column.panning_value = panning_value
              note_column.effect_number_value = samplefx_value
            end
          end
        end
      end

      -- Apply Effect Columns
      for effect_idx = 1, track.visible_effect_columns do
        if effect_number_values[track_idx][effect_idx] then
          local effect_number = effect_number_values[track_idx][effect_idx]
          local effect_amount = effect_amount_values[track_idx][effect_idx]

          for i = start_line, end_line do
            if edit_step == 0 or (i - start_line) % edit_step == 0 then
              local effect_column = song:pattern(pattern_index):track(track_idx):line(i).effect_columns[effect_idx]
              effect_column.number_value = effect_number
              effect_column.amount_value = effect_amount
            end
          end
        end
      end
    end
  end

  renoise.app():show_status("Track/Selection filled with Note, Instrument, Volume, Delay, Panning, Sample FX, and Effect Columns every " .. notstep .. " step(s).")
end


for i=1,64 do
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Flood Fill Note and Instrument every " .. i .. " step",invoke=function() pakettiFloodFillWithNotReallyEditStep(i) end}
end














-----------
local dialog
local track_index = 1
local selected_tracks = {}
local vb = renoise.ViewBuilder()

-- Function to show the track renamer dialog
function PakettiTrackRenamerDialog()
  -- Get the current selection in the pattern
  local selection = renoise.song().selection_in_pattern
  selected_tracks = {}

  -- Check if there is a selection
  if selection then
    for i = selection.start_track, selection.end_track do
      table.insert(selected_tracks, i)
    end
  else
    -- If no selection, use the currently selected track
    table.insert(selected_tracks, renoise.song().selected_track_index)
  end

  -- Reset track index
  track_index = 1

  -- Debugging: print selected tracks
  print("Selected tracks: ", table.concat(selected_tracks, ", "))

  -- Show the dialog for the first track in the selection
  ShowRenameDialogForTrack(track_index)
end

-- Function to show the renaming dialog for a specific track
function ShowRenameDialogForTrack(index)
  local track_index = selected_tracks[index]
  local selected_track = renoise.song().tracks[track_index]
  local initial_name = selected_track.name

  local function close_dialog()
    if dialog and dialog.visible then
      dialog:close()
    end
  end

  local function rename_track_and_close(new_name)
    selected_track.name = new_name
    close_dialog()
    -- Move to the next track in the selection
    index = index + 1
    if index <= #selected_tracks then
      ShowRenameDialogForTrack(index)
    end
  end

  -- Create a new ViewBuilder instance
  vb = renoise.ViewBuilder()
  local text_field = vb:textfield{
    id = "track_name_field",
    text = initial_name,
    width = 200,
    edit_mode = true,
    notifier = function(new_name)
      if new_name ~= initial_name then
        rename_track_and_close(new_name)
      end
    end
  }

  -- Key handler for the text field
  local function key_handler(dialog, key)
    local closer = preferences.pakettiDialogClose.value
  
    if key.name == "return" and not key.repeated then
      rename_track_and_close(vb.views.track_name_field.text)
      return
    elseif key.modifiers == "" and key.name == closer then
      close_dialog()
      return
    else
      return key
    end
  end

  local dialog_content = vb:column{
    margin = 10,
    vb:row{
      vb:text{
        text = "Track Name:"
      },
      text_field
    },
    vb:row{
      margin = 10,
      vb:button{
        text = "OK",
        width = 50,
        notifier = function() rename_track_and_close(vb.views.track_name_field.text) end
      },
      vb:button{
        text = "Cancel",
        width = 50,
        notifier = close_dialog
      }
    }
  }

  -- Show the dialog
  dialog = renoise.app():show_custom_dialog("Paketti Track Renamer", dialog_content, key_handler)
end

renoise.tool():add_keybinding{name="Mixer:Paketti:Paketti Track Renamer Dialog...",invoke=PakettiTrackRenamerDialog}
renoise.tool():add_keybinding{name="Pattern Matrix:Paketti:Paketti Track Renamer Dialog...",invoke=PakettiTrackRenamerDialog}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Paketti Track Renamer Dialog...",invoke=PakettiTrackRenamerDialog}
renoise.tool():add_midi_mapping{name="Paketti:Paketti Track Renamer",invoke=PakettiTrackRenamerDialog}

-----
function effectbypasspattern()
local currTrak = renoise.song().selected_track_index
local number = (table.count(renoise.song().selected_track.devices))
 for i=2,number  do 
  --renoise.song().selected_track.devices[i].is_active=false
  renoise.song().selected_track.visible_effect_columns=(table.count(renoise.song().selected_track.devices)-1)
--This would be (1-8F)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[1].number_string="10"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[2].number_string="20"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[3].number_string="30"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[4].number_string="40"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[5].number_string="50"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[6].number_string="60"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[7].number_string="70"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[8].number_string="80"
--this would be 00 for disabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="00"
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
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[1].number_string="10"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[2].number_string="20"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[3].number_string="30"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[4].number_string="40"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[5].number_string="50"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[6].number_string="60"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[7].number_string="70"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[8].number_string="80"

--this would be 01 for enabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="01"
end
end
------
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Devices..:Bypass 8 Track DSP Devices (Write to Pattern)", invoke=function() effectbypasspattern() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Devices..:Enable 8 Track DSP Devices (Write to Pattern)", invoke=function() effectenablepattern()  end}
-----
function patternEditorSelectedLastTrack()
renoise.song().selected_track_index=#renoise.song().tracks
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Select Last Track",invoke=function() patternEditorSelectedLastTrack() end}
----------
function wipeSelectedTrackTrackDSPs()

    for i = #renoise.song().selected_track.devices, 2, -1 do
      renoise.song().selected_track:delete_device_at(i)
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Wipe Selected Track TrackDSPs",invoke=function() wipeSelectedTrackTrackDSPs() end}
------



renoise.tool():add_keybinding{
  name="Pattern Editor:Paketti:Toggle Note Off in All Visible Note Columns",
  invoke=function() 
    local song=renoise.song()
    local track=song.selected_track
    local line=song.selected_line
    local count=track.visible_note_columns
    
    -- Check if all visible note columns are set to "OFF"
    local all_off=true
    for i=1,count do
      if line.note_columns[i].note_string~="OFF" then
        all_off=false
        break
      end
    end
    
    -- Set or clear "OFF" depending on the result
    for i=1,count do
      line.note_columns[i].note_string=all_off and "" or "OFF"
    end
  end
}

renoise.tool():add_keybinding{
  name="Pattern Editor:Paketti:Toggle Note Off on All Tracks on Current Row",
  invoke=function()
    local song=renoise.song()
    local cursor_pos=song.selected_line_index
    
    -- Iterate over all tracks
    for t=1,#song.tracks do
      local track=song:track(t)
      
      -- Skip group, master, and send tracks
      if not (track.type==renoise.Track.TRACK_TYPE_GROUP or track.type==renoise.Track.TRACK_TYPE_MASTER or track.type==renoise.Track.TRACK_TYPE_SEND) then
        local line=song.patterns[song.selected_pattern_index]:track(t):line(cursor_pos)
        local count=track.visible_note_columns
        
        -- Check if all visible note columns are set to "OFF"
        local all_off=true
        for i=1,count do
          if line.note_columns[i].note_string~="OFF" then
            all_off=false
            break
          end
        end
        
        -- Set or clear "OFF" depending on the result
        for i=1,count do
          line.note_columns[i].note_string=all_off and "" or "OFF"
        end
      end
    end
  end
}


-------
function PhrasingRandom()

    local song=renoise.song()
    local track=song.selected_track
    local line=song.selected_line
    local count=track.visible_note_columns
    local adjustments={-36, -24, -12, 12, 24, 36}
    
    for i=1,count do
      local note=line.note_columns[i]
      if not note.is_empty then
        -- Pick a random adjustment and apply it to the note_value
        local adjustment=adjustments[math.random(#adjustments)]
        local new_value=note.note_value+adjustment
        
        -- Ensure new_value is within the 13 to 106 range
        new_value=math.max(13, math.min(106, new_value))
        
        -- Update the note value
        note.note_value=new_value
      end
    end
    end



renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Randomize Phrasing for Notes in Current Row",
  invoke=function() PhrasingRandom() end}
renoise.tool():add_midi_mapping{name="Paketti:Randomize Phrasing for Notes in Current Row",
  invoke=function() PhrasingRandom() end}

--------------
local function insert_random_value(mode)
  local song = renoise.song()
  local selection = song.selection_in_pattern
  local pattern = song.selected_pattern
  local pattern_tracks = pattern.tracks

  -- Print the current selection_in_pattern
  if selection then
    print("Selection details: start_track =", selection.start_track, "end_track =", selection.end_track,
          "start_line =", selection.start_line, "end_line =", selection.end_line,
          "start_column =", selection.start_column, "end_column =", selection.end_column)
  else
    print("No selection, processing current row.")
  end

  -- If no selection, apply to the current row in the selected track
  if selection == nil then
    local track = song.selected_track
    local line_index = song.selected_line_index
    local pattern_track = pattern_tracks[song.selected_track_index]

    -- Check if the track is Group, Master, or Send
    if song.tracks[song.selected_track_index].type == renoise.Track.TRACK_TYPE_GROUP or 
       song.tracks[song.selected_track_index].type == renoise.Track.TRACK_TYPE_MASTER or 
       song.tracks[song.selected_track_index].type == renoise.Track.TRACK_TYPE_SEND then
      renoise.app():show_status("There are no Note Columns on a Track of this type")
      print("Skipped Group/Master/Send track:", song.selected_track_index)
      return
    end

    -- Print track details
    print("Processing track:", song.selected_track_index, "with", track.visible_note_columns, "note columns and",
          track.visible_effect_columns, "effect columns")

    -- Ensure corresponding columns are visible
    if mode == "delay" and not track.delay_column_visible then
      track.delay_column_visible = true
    elseif mode == "panning" and not track.panning_column_visible then
      track.panning_column_visible = true
    elseif mode == "volume" and not track.volume_column_visible then
      track.volume_column_visible = true
    end

    -- Insert random values into the selected line's visible note columns
    for col = selection.start_column, selection.start_column do
      local note_column = pattern_track.lines[line_index].note_columns[col]
      if note_column then
        if mode == "delay" then
          note_column.delay_value = math.random(0, 255)
          print("Inserted random delay value to track:", song.selected_track_index, "line:", line_index, "column:", col)
        elseif mode == "panning" then
          note_column.panning_value = math.random(0, 127)
          print("Inserted random panning value to track:", song.selected_track_index, "line:", line_index, "column:", col)
        elseif mode == "volume" then
          note_column.volume_value = math.random(0, 127)
          print("Inserted random volume value to track:", song.selected_track_index, "line:", line_index, "column:", col)
        end
      end
    end

    renoise.app():show_status("Inserted random " .. mode .. " values to selected row")
    print("Finished processing track:", song.selected_track_index)

  else
    -- Fix the selection column order (in case start_column is greater than end_column)
    local fixed_start_column = math.min(selection.start_column, selection.end_column)
    local fixed_end_column = math.max(selection.start_column, selection.end_column)

    -- Apply across the selection in the pattern
    for track_idx = selection.start_track, selection.end_track do
      local song_track = song.tracks[track_idx]
      local pattern_track = pattern_tracks[track_idx]

      -- Print track details
      print("Processing track:", track_idx, "with", song_track.visible_note_columns, "note columns and",
            song_track.visible_effect_columns, "effect columns")

      -- Skip Group, Master, and Send tracks
      if song_track.type == renoise.Track.TRACK_TYPE_GROUP or 
         song_track.type == renoise.Track.TRACK_TYPE_MASTER or 
         song_track.type == renoise.Track.TRACK_TYPE_SEND then
        print("Skipped Group/Master/Send track:", track_idx)
      else
        -- Ensure the corresponding columns are visible
        if mode == "delay" and not song_track.delay_column_visible then
          song_track.delay_column_visible = true
        elseif mode == "panning" and not song_track.panning_column_visible then
          song_track.panning_column_visible = true
        elseif mode == "volume" and not song_track.volume_column_visible then
          song_track.volume_column_visible = true
        end

        -- Track-specific column bounds, adjusted for each track's visible note columns
        local track_start_column = (track_idx == selection.start_track) and fixed_start_column or 1
        local track_end_column = (track_idx == selection.end_track) and fixed_end_column or song_track.visible_note_columns

        -- Print selected columns in this track
        print("Selected note columns in track:", track_idx, "from", track_start_column, "to", track_end_column)

        -- Apply random values within the selected columns and lines
        for line_idx = selection.start_line, selection.end_line do
          local line = pattern_track.lines[line_idx]

          -- Process note columns within the per-track selection range
          for col = track_start_column, track_end_column do
            local note_column = line.note_columns[col]
            if note_column then
              if mode == "delay" then
                note_column.delay_value = math.random(0, 255)
                print("Inserted random delay value to track:", track_idx, "line:", line_idx, "column:", col)
              elseif mode == "panning" then
                note_column.panning_value = math.random(0, 127)
                print("Inserted random panning value to track:", track_idx, "line:", line_idx, "column:", col)
              elseif mode == "volume" then
                note_column.volume_value = math.random(0, 127)
                print("Inserted random volume value to track:", track_idx, "line:", line_idx, "column:", col)
              end
            else
              print("No note column found in track:", track_idx, "line:", line_idx, "column:", col)
            end
          end
        end
      end
    end

    renoise.app():show_status("Inserted random " .. mode .. " values across selection")
    print("Finished processing selection")
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Insert Random Delay to Selected Row",invoke=function()insert_random_value("delay")end}
renoise.tool():add_keybinding{name="Global:Paketti:Insert Random Panning to Selected Row",invoke=function()insert_random_value("panning")end}
renoise.tool():add_keybinding{name="Global:Paketti:Insert Random Volume to Selected Row",invoke=function()insert_random_value("volume")end}

renoise.tool():add_midi_mapping{name="Paketti:Insert Random Delay to Selected Row",invoke=function()insert_random_value("delay")end}
renoise.tool():add_midi_mapping{name="Paketti:Insert Random Panning to Selected Row",invoke=function()insert_random_value("panning")end}
renoise.tool():add_midi_mapping{name="Paketti:Insert Random Volume to Selected Row",invoke=function()insert_random_value("volume")end}



-------
-- Main function to replicate content
local function PakettiReplicateAtCursor(transpose, tracks_option, row_option)
  local song = renoise.song()
  local pattern = song.selected_pattern
  local cursor_row = song.selected_line_index
  local pattern_length = pattern.number_of_lines

  -- Check if there is content to replicate
  if (cursor_row == 1 and row_option == "above_current") or (cursor_row == pattern_length and row_option == "above_and_current") then
    renoise.app():show_status("No rows to replicate.")
    return
  end

  -- Determine the repeat_length and starting row based on row_option
  local repeat_length, start_row
  if row_option == "above_current" then
    if cursor_row == 1 then
      renoise.app():show_status("You are on the first row, nothing to replicate.")
      return
    end
    repeat_length = cursor_row - 1
    start_row = cursor_row
  elseif row_option == "above_and_current" then
    repeat_length = cursor_row
    start_row = cursor_row + 1
    if cursor_row == pattern_length then
      renoise.app():show_status("You are on the last row, nothing to replicate.")
      return
    end
  else
    renoise.app():show_status("Invalid row option: " .. tostring(row_option))
    return
  end

  if repeat_length == 0 then
    renoise.app():show_status("No rows to replicate.")
    return
  end

  transpose = transpose or 0

  local function transpose_note(note_value, transpose_amount)
    local min_note = 0
    local max_note = 119

    if note_value >= min_note and note_value <= max_note then
      local new_note = note_value + transpose_amount
      if new_note > max_note then
        new_note = max_note
      elseif new_note < min_note then
        new_note = min_note
      end
      return new_note
    else
      return note_value
    end
  end

  -- Function to replicate content on a track
  local function replicate_on_track(track_index)
    for row = start_row, pattern_length do
      local source_row = ((row - start_row) % repeat_length) + 1
      local source_line = pattern:track(track_index):line(source_row)
      local dest_line = pattern:track(track_index):line(row)

      for col = 1, #source_line.note_columns do
        local source_note = source_line.note_columns[col]
        local dest_note = dest_line.note_columns[col]

        dest_note.note_value = transpose_note(source_note.note_value, transpose)
        dest_note.instrument_value = source_note.instrument_value
        dest_note.volume_value = source_note.volume_value
        dest_note.panning_value = source_note.panning_value
        dest_note.delay_value = source_note.delay_value
        dest_note.effect_number_value = source_note.effect_number_value
        dest_note.effect_amount_value = source_note.effect_amount_value
      end

      for col = 1, #source_line.effect_columns do
        local source_effect = source_line.effect_columns[col]
        local dest_effect = dest_line.effect_columns[col]

        dest_effect.number_value = source_effect.number_value
        dest_effect.amount_value = source_effect.amount_value
      end
    end
  end

  if tracks_option == "all_tracks" then
    for track_index = 1, #pattern.tracks do
      replicate_on_track(track_index)
    end
  elseif tracks_option == "selected_track" then
    local selected_track_index = song.selected_track_index
    replicate_on_track(selected_track_index)
  else
    renoise.app():show_status("Invalid tracks option: " .. tostring(tracks_option))
    return
  end

  renoise.app():show_status("Replicated content with transpose: " .. transpose)
end

-- Helper function to create menu entries, keybindings, and MIDI mappings
local function create_replicate_function(transpose, tracks_option, row_option)
  return function()
    PakettiReplicateAtCursor(transpose, tracks_option, row_option)
  end
end

-- Options for transpose, tracks, and rows
local transpose_options = {
  {value = -12, name = "(-12)"},
  {value = -1, name = "(-1)"},
  {value = 0, name = ""},
  {value = 1, name = "(+1)"},
  {value = 12, name = "(+12)"},
}

local tracks_options = {
  {value = "selected_track", name = "Selected Track"},
  {value = "all_tracks", name = "All"},
}

local row_options = {
  {value = "above_current", name = "Above Current Row"},
  {value = "above_and_current", name = "Above + Current"},
}

-- Generate menu entries, keybindings, and MIDI mappings for all combinations
for _, tracks_opt in ipairs(tracks_options) do
  for _, row_opt in ipairs(row_options) do
    for _, transpose_opt in ipairs(transpose_options) do

      local menu_entry_name = "Pattern Editor:Paketti..:Replicate..:Replicate " .. tracks_opt.name .. " " .. row_opt.name .. " " .. transpose_opt.name

      local replicate_function = create_replicate_function(transpose_opt.value, tracks_opt.value, row_opt.value)

      -- Add the menu entry
      renoise.tool():add_menu_entry{
        name = menu_entry_name,
        invoke = replicate_function
      }

      -- Add the keybinding
      local keybinding_name = "Pattern Editor:Paketti:Replicate " .. tracks_opt.name .. " " .. row_opt.name .. " " .. transpose_opt.name
      renoise.tool():add_keybinding{
        name = keybinding_name,
        invoke = replicate_function
      }

      -- Add the MIDI mapping
      local midi_mapping_name = "Paketti:Replicate " .. tracks_opt.name .. " " .. row_opt.name .. " " .. transpose_opt.name
      renoise.tool():add_midi_mapping{
        name = midi_mapping_name,
        invoke = function(message)
          if message:is_trigger() then
            replicate_function()
          end
        end
      }

    end
  end
end
------------




-- Function to adjust the delay column within the selected area or current note column
function PakettiDelayColumnModifier(amount)
  -- Get the current song
  local song = renoise.song()
  if not song then
    renoise.app():show_status("No active song found.")
    return
  end

  -- Get the selection in the pattern editor
  local selection = song.selection_in_pattern

  if selection then
    -- There is a selection; adjust the delay values within the selection
    for track_index = selection.start_track, selection.end_track do
      local track = song:track(track_index)
      -- Ensure the delay column is visible
      if not track.delay_column_visible then
        track.delay_column_visible = true
      end

      local max_note_columns = track.visible_note_columns
      for line_index = selection.start_line, selection.end_line do
        local pattern_index = song.selected_pattern_index
        local pattern = song:pattern(pattern_index)
        local line = pattern:track(track_index):line(line_index)
        for note_column_index = selection.start_column, selection.end_column do
          -- Ensure the note column index is within the track's note columns
          if note_column_index <= max_note_columns then
            local note_column = line:note_column(note_column_index)
            if note_column then
              -- Adjust the delay value
              local new_value = math.min(0xFF, math.max(0, note_column.delay_value + amount))
              note_column.delay_value = new_value
            end
          end
        end
      end
    end
    renoise.app():show_status("Delay Column adjustment (" .. amount .. ") applied to selection.")
  else
    -- No selection; adjust the current note column
    local selected_track_index = song.selected_track_index
    local selected_line_index = song.selected_line_index
    local selected_note_column_index = song.selected_note_column_index
    local track = song:track(selected_track_index)

    -- Check if the cursor is in a note column
    if selected_note_column_index == 0 then
      renoise.app():show_status("Not in a note column. No delay adjustment made.")
      return
    end

    -- Ensure the delay column is visible
    if not track.delay_column_visible then
      track.delay_column_visible = true
    end

    local pattern_index = song.selected_pattern_index
    local pattern = song:pattern(pattern_index)
    local line = pattern:track(selected_track_index):line(selected_line_index)
    local note_column = line:note_column(selected_note_column_index)
    if note_column then
      -- Adjust the delay value
      local new_value = math.min(0xFF, math.max(0, note_column.delay_value + amount))
      note_column.delay_value = new_value
      renoise.app():show_status("Delay Column adjustment (" .. amount .. ") applied to current note column.")
    else
      renoise.app():show_status("No note column found at index " .. selected_note_column_index .. ". No delay adjustment made.")
    end
  end
end


renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delay Column Increase Selection/Row (+1)",invoke=function() PakettiDelayColumnModifier(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delay Column Decrease Selection/Row (-1)",invoke=function() PakettiDelayColumnModifier(-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Delay Column Increase Selection/Row (+10)",invoke=function() PakettiDelayColumnModifier(10) end}
renoise.tool():add_keybinding{name= "Pattern Editor:Paketti:Delay Column Decrease Selection/Row (-10)", invoke = function() PakettiDelayColumnModifier(-10) end}

------
function ExposeAndSelectColumn(number)
  local song = renoise.song()
  local track = song.selected_track

  -- Get the track type
  local track_type = track.type

  if track_type == renoise.Track.TRACK_TYPE_SEQUENCER then
    -- It's a normal track that can have note and effect columns

    -- Detect if we're on a note column or an effect column
    if song.selected_note_column ~= nil then
      -- We're on a Note Column
      local visNoteCol = track.visible_note_columns
      local newVisNoteCol = visNoteCol + number

      if newVisNoteCol > 12 then
        renoise.app():show_status("All 12 Note Columns are already visible for the selected track, cannot add more.")
        return
      elseif newVisNoteCol < 1 then
        renoise.app():show_status("Cannot have less than 1 Note Column visible.")
        return
      end

      -- Update the track's visible note columns
      track.visible_note_columns = newVisNoteCol
      -- Select the new note column
      song.selected_note_column_index = newVisNoteCol

    elseif song.selected_effect_column ~= nil then
      -- We're on an Effect Column
      local visEffectCol = track.visible_effect_columns
      local newVisEffectCol = visEffectCol + number

      if newVisEffectCol > 8 then
        renoise.app():show_status("All 8 Effect Columns are already visible for the selected track, cannot add more.")
        return
      elseif newVisEffectCol < 0 then
        renoise.app():show_status("Cannot have less than 0 Effect Columns visible.")
        return
      end

      -- Update the track's visible effect columns
      track.visible_effect_columns = newVisEffectCol

      if newVisEffectCol > 0 then
        -- Select the new effect column
        song.selected_effect_column_index = newVisEffectCol
      else
        -- No effect columns visible, deselect any effect column
     --   song.selected_effect_column_index = nil
      end

    else
      renoise.app():show_status("You are not on a Note or Effect Column, doing nothing.")
    end

  else
    -- The track cannot have note columns, handle effect columns only
    local visEffectCol = track.visible_effect_columns
    local newVisEffectCol = visEffectCol + number

    if newVisEffectCol > 8 then
      renoise.app():show_status("All 8 Effect Columns are already visible for the selected track, cannot add more.")
      return
    elseif newVisEffectCol < 0 then
      renoise.app():show_status("Cannot have less than 0 Effect Columns visible.")
      return
    end

    -- Update the track's visible effect columns
    track.visible_effect_columns = newVisEffectCol

    if newVisEffectCol > 0 then
      -- Select the new effect column
      song.selected_effect_column_index = newVisEffectCol
    else
      -- No effect columns visible, deselect any effect column
      song.selected_effect_column_index = nil
    end
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Expose and Select Next Column",invoke=function() ExposeAndSelectColumn(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Hide Current and Select Previous Column",invoke=function() ExposeAndSelectColumn(-1) end}
renoise.tool():add_midi_mapping{name="Paketti:Expose and Select Next Column",invoke=function(message) if message:is_trigger() then ExposeAndSelectColumn(1) end end}
renoise.tool():add_midi_mapping{name="Paketti:Hide Current and Select Previous Column",invoke=function(message) if message:is_trigger() then xposeAndSelectColumn(-1) end end}









--------









function setPatternLengthByLPB(multiplier)
  local rs=renoise.song()
  local lpb=rs.transport.lpb
  local new_length=lpb*multiplier
  if new_length>512 then new_length=512 end
  rs.patterns[rs.selected_pattern_index].number_of_lines=new_length
  renoise.app():show_status("Pattern Length set to "..new_length.." (LPB*"..string.format("%03d", multiplier)..")")
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*001",invoke=function() setPatternLengthByLPB(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*002",invoke=function() setPatternLengthByLPB(2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*004",invoke=function() setPatternLengthByLPB(4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*008",invoke=function() setPatternLengthByLPB(8) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*016",invoke=function() setPatternLengthByLPB(16) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*032",invoke=function() setPatternLengthByLPB(32) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*064",invoke=function() setPatternLengthByLPB(64) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*128",invoke=function() setPatternLengthByLPB(128) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*256",invoke=function() setPatternLengthByLPB(256) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Pattern Length to LPB*512",invoke=function() setPatternLengthByLPB(512) end}








----------
-- Initialize variables
local last_line_index = nil
local match_editstep_enabled = false

-- Function to find the next note line
function find_next_note_line(start_line)
  local song = renoise.song()
  local pattern = song.selected_pattern
  local num_lines = pattern.number_of_lines
  local current_track = song.selected_pattern_track
  local max_note_columns = renoise.song().selected_track.visible_note_columns

  -- Flag to check if any notes exist in the track
  local notes_exist = false
  for line_index = 1, num_lines do
    local track_line = current_track:line(line_index)
    for note_col_index = 1, max_note_columns do
      local note_column = track_line:note_column(note_col_index)
      if not note_column.is_empty then
        notes_exist = true
        break
      end
    end
    if notes_exist then break end
  end

  if not notes_exist then
    renoise.app():show_status("No notes found in this track.")  -- Added for immediate feedback
    return nil  -- No notes found in the entire track
  end

  -- Search from start_line +1 to num_lines
  for line_index = start_line + 1, num_lines do
    local track_line = current_track:line(line_index)
    for note_col_index = 1, max_note_columns do
      local note_column = track_line:note_column(note_col_index)
      if not note_column.is_empty then
        return line_index
      end
    end
  end

  -- Wrap around: Search from line 1 to start_line
  for line_index = 1, start_line do
    local track_line = current_track:line(line_index)
    for note_col_index = 1, max_note_columns do
      local note_column = track_line:note_column(note_col_index)
      if not note_column.is_empty then
        return line_index
      end
    end
  end

  return nil  -- This shouldn't happen, but return nil just in case
end

-- Function to adjust the editstep
function match_editstep_with_next_note()
  local song = renoise.song()
  local current_line_index = song.selected_line_index
  local num_lines = song.selected_pattern.number_of_lines

  -- Check if the line index has changed
  if last_line_index ~= current_line_index then
    last_line_index = current_line_index

    -- Only adjust if in the effect column
    if song.selected_note_column_index == 0 and song.selected_effect_column_index > 0 then
      local next_note_line = find_next_note_line(current_line_index)
      if next_note_line then
        local editstep = 0
        if next_note_line > current_line_index then
          editstep = next_note_line - current_line_index
        elseif next_note_line < current_line_index then
          -- Wrap around case
          editstep = (num_lines - current_line_index) + next_note_line
        else
          -- The next note is on the same line
          editstep = 0
        end
        song.transport.edit_step = editstep
      else
        -- No notes in the track
        renoise.app():show_status("There are no notes on this track. Doing nothing.")
        -- Do not change editstep
      end
    end
  end
end

-- Function to immediately adjust the editstep when toggling on
function set_initial_editstep()
  local song = renoise.song()
  local current_line_index = song.selected_line_index
  local next_note_line = find_next_note_line(current_line_index)
  if next_note_line then
    local editstep = 0
    if next_note_line > current_line_index then
      editstep = next_note_line - current_line_index
    elseif next_note_line < current_line_index then
      editstep = (song.selected_pattern.number_of_lines - current_line_index) + next_note_line
    else
      editstep = 0  -- Same line
    end
    song.transport.edit_step = editstep
    renoise.app():show_status("Initial EditStep set to " .. tostring(editstep))
  else
    renoise.app():show_status("No notes found to adjust EditStep.")
  end
end

-- Idle notifier functions
function attach_idle_notifier()
  if not renoise.tool().app_idle_observable:has_notifier(match_editstep_with_next_note) then
    renoise.tool().app_idle_observable:add_notifier(match_editstep_with_next_note)
  end
end

function detach_idle_notifier()
  if renoise.tool().app_idle_observable:has_notifier(match_editstep_with_next_note) then
    renoise.tool().app_idle_observable:remove_notifier(match_editstep_with_next_note)
  end
end

-- Function to handle new songs
function attach_to_song()
  detach_idle_notifier()
  if match_editstep_enabled then
    attach_idle_notifier()
  end
end

-- Observe when a new song is loaded
renoise.tool().app_new_document_observable:add_notifier(attach_to_song)

-- Toggle function
function toggle_match_editstep()
  match_editstep_enabled = not match_editstep_enabled
  if match_editstep_enabled then
    last_line_index = renoise.song().selected_line_index  -- Initialize the last_line_index
    attach_idle_notifier()
    set_initial_editstep()  -- Immediately adjust the editstep upon activation
    renoise.app():show_status("Match EditStep: ON")
  else
    detach_idle_notifier()
    renoise.app():show_status("Match EditStep: OFF")
  end
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Match Effect Column EditStep with Note Placement",invoke=function() toggle_match_editstep() end}
renoise.tool():add_keybinding{name="Global:Tools:Toggle Match EditStep with Note Placement",invoke=function() toggle_match_editstep() end}


