----------------------------------------------------------------------------------------------------------------
-- F2
function F2()
local w=renoise.app().window
local raw=renoise.ApplicationWindow
w.lock_keyboard_focus=true

if w.active_middle_frame==raw.MIDDLE_FRAME_PATTERN_EDITOR and w.lower_frame_is_visible then
--renoise.app().window:select_preset(8)
  w.lower_frame_is_visible=false
  w.upper_frame_is_visible=false
  w.pattern_advanced_edit_is_visible=false
  w.instrument_box_is_visible=true
  w.disk_browser_is_visible=true
  w.pattern_matrix_is_visible=false
else w.active_middle_frame=raw.MIDDLE_FRAME_PATTERN_EDITOR
  w.lower_frame_is_visible=true
  w.upper_frame_is_visible=true
  w.active_lower_frame=raw.LOWER_FRAME_TRACK_DSPS
--w.pattern_advanced_edit_is_visible=true
  w.instrument_box_is_visible=true
  w.disk_browser_is_visible=true
-- w.pattern_matrix_is_visible = true
return end

if w.disk_browser_is_visible then
  w.active_middle_frame=raw.MIDDLE_FRAME_PATTERN_EDITOR
  w.lower_frame_is_visible=false
  w.upper_frame_is_visible=false
  w.pattern_advanced_edit_is_visible=false
  w.disk_browser_is_visible=false
--renoise.app().window:select_preset(8)
return end end
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F2 Pattern Editor", invoke=function() F2() end}

-- F2
function F2Only()
local w=renoise.app().window
local raw=renoise.ApplicationWindow
w.active_middle_frame=raw.MIDDLE_FRAME_PATTERN_EDITOR
w.lower_frame_is_visible=true
w.upper_frame_is_visible=true
w.active_lower_frame=raw.LOWER_FRAME_TRACK_DSPS
end
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F2 Pattern Editor ONLY", invoke=function() F2Only() end}

----------------------------------------------------------------------------------------------------------------
function MixerToF2()
local w=renoise.app().window
if w.active_middle_frame == 2 then F2() else w.active_middle_frame=2 end
w.pattern_matrix_is_visible=false
w.pattern_advanced_edit_is_visible=false
w.instrument_box_is_visible=true
w.disk_browser_is_visible=true
end

renoise.tool():add_keybinding{name="Mixer:Paketti:To Pattern Editor", invoke=function() MixerToF2() end}
----------------------------------------------------------------------------------------------------------------
function F2mini()
local w=renoise.app().window
w.lock_keyboard_focus=true
w.active_middle_frame = 1
w.lower_frame_is_visible=false 
w.upper_frame_is_visible=false 
w.pattern_advanced_edit_is_visible=false 
w.instrument_box_is_visible=false
w.disk_browser_is_visible=false
w.pattern_matrix_is_visible=false
end
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F2 Pattern Editor Mini", invoke=function() F2mini() end}

----------------------------------------------------------------------------------------------------------------
--- F3
function F3()
local w=renoise.app().window
local s=renoise.song()
local raw=renoise.ApplicationWindow

if w.active_middle_frame==5 then w.active_middle_frame=3
    else w.active_middle_frame=5 end

w.pattern_matrix_is_visible=false
w.pattern_advanced_edit_is_visible=false

if w.active_middle_frame == 1 then
w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
w.lock_keyboard_focus=true
w.disk_browser_is_visible=true
w.instrument_box_is_visible=true

  if w.upper_frame_is_visible==true then 
     w.active_upper_frame=2 else return end
w.upper_frame_is_visible=true
w.active_upper_frame=2
return else  end

if w.upper_frame_is_visible == true then w.active_upper_frame = raw.UPPER_FRAME_TRACK_SCOPES 
else return end

if w.active_middle_frame==raw.MIDDLE_FRAME_PATTERN_EDITOR and w.lower_frame_is_visible==false and w.pattern_advanced_edit_is_visible==false and w.upper_frame_is_visible==false then
w.upper_frame_is_visible=true
w.active_upper_frame=raw.UPPER_FRAME_TRACK_SCOPES
w.disk_browser_is_visible=true return
else end

if w.active_upper_frame == raw.UPPER_FRAME_TRACK_SCOPES and w.upper_frame_is_visible==true then 
--w.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM 
--switching between trackscopes + master spectrum is not preferred anymore by this user
return 
else w.active_upper_frame = raw.UPPER_FRAME_TRACK_SCOPES end

s.selected_instrument.active_tab=1
--w.active_upper_frame =renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES
w.active_middle_frame=raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR

--renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_PHRASE_EDITOR
end

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F3 Sample Editor", invoke=function() F3() end}
-- F3 Only
function F3Only()
local w=renoise.app().window
local s=renoise.song()
local raw=renoise.ApplicationWindow
w.pattern_matrix_is_visible=false
w.pattern_advanced_edit_is_visible=false
w.upper_frame_is_visible = true
w.disk_browser_is_visible=true
s.selected_instrument.active_tab=1
w.active_middle_frame=raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F3 Sample Editor Only", invoke=function() F3Only() end}

----------------------------------------------------------------------------------------------------------------
-- F4, or "Impulse Tracker Shortcut F4 display-change", "Instrument Editor".
-- Hides Pattern Matrix, Hides Advanced Edit.
-- Changes to Sample Keyzones, Disk Browser, Instrument Settings.
-- Sample Recorder will stay open, if Sample Recorder is already open.
function F4()
local w=renoise.app().window
local raw=renoise.ApplicationWindow
--if w.active_upper_frame == 1  and  w.active_middle_frame == 3  and w.active_lower_frame == 3 and w.disk_browser_is_expanded==false
--then w.disk_browser_is_expanded=true return
--end
--w.lower_frame_is_visible=true
--w.upper_frame_is_visible=true
w.active_upper_frame=1 -- Set to Disk Browser
--w.active_lower_frame =3 -- Set to Instrument Settings
--w.lock_keyboard_focus=true
--w.pattern_matrix_is_visible=false
--w.pattern_advanced_edit_is_visible=false
--w.disk_browser_is_expanded=true
if w.active_middle_frame == raw.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR then
w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR
else w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR end
--if renoise.app().window.active_middle_frame==renoise.Instrument.TAB_PLUGIN then renoise.app().window.active_middle_frame=5 else
--renoise.app().window.active_middle_frame=renoise.Instrument.TAB_PLUGIN end
end

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F4 Instrument Editor", invoke=function() F4() end}
----------------------------------------------------------------------------------------------------------------
-- F5
function ImpulseTrackerPlaySong()
local s = renoise.song()
local t = s.transport
local startpos = t.playback_pos

if t.playing then t:panic() else end
  t:panic()
  startpos.sequence = 1
  startpos.line = 1
  t.playback_pos = startpos
local start_time = os.clock()
  while (os.clock() - start_time < 0.4) do
        -- Delay the start after panic. Don't go below 0.2 seconds 
        -- or you might tempt some plugins to crash and take Renoise in the fall!!    
        -- ^^^ I don't know or remember who wrote the above comments but it wasn't me -Esa  
  end
t.follow_player=true
t.edit_mode=false
t.metronome_enabled=false
t.loop_block_enabled=false
t.loop_pattern = false
t.loop_block_enabled=false
t:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
end
--renoise.tool():add_midi_mapping{name="Global:Paketti:Start Playback from Cursor Row x[Toggle]",  invoke=function() ImpulseTrackerPlaySong() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Start Playback x[Toggle]",  invoke=function() ImpulseTrackerPlaySong() end}
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F5 Start Playback", invoke=function() ImpulseTrackerPlaySong() end}
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F5 Start Playback (2nd)", invoke=function() ImpulseTrackerPlaySong() end}

----------------------------------------------------------------------------------------------------------------
-- F6, or Impulse Tracker Play Pattern.
-- There is currently no need for this, but if there one day is, this'll be where it will reside :)
-- You can map F6 to Global:Transport:Play Pattern.
----------------------------------------------------------------------------------------------------------------
-- F7, or Impulse Tracker Play from line.
function ImpulseTrackerPlayFromLine()
 local s = renoise.song()
 local t = s.transport
 local startpos = t.playback_pos  
 if t.playing == true  then 
 t.loop_pattern=false
   t:panic()
  t.loop_pattern=false
  t.loop_block_enabled=false
  t.edit_mode=true
 startpos.line = s.selected_line_index
 startpos.sequence = s.selected_sequence_index
 t.playback_pos = startpos
  t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
 return
 else
  t:panic()
  t.loop_pattern=false
  t.loop_block_enabled=false
  t.edit_mode=true
 startpos.line = s.selected_line_index
 startpos.sequence = s.selected_sequence_index
 t.playback_pos = startpos
  t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F7 Start Playback from Cursor Row", invoke=function() ImpulseTrackerPlayFromLine() end}
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F7 Start Playback from Cursor Row (2nd)", invoke=function() ImpulseTrackerPlayFromLine() end}
------------------------------------------------------------------------------------------------------------------------------------------- F8
function ImpulseTrackerStop()
local t=renoise.song().transport
t.follow_player=false
t:panic()
t.loop_pattern=false
t.loop_block_enabled=false
end

renoise.tool():add_midi_mapping{name="Global:Paketti:Impulse Tracker F8 Stop Playback (Panic) x[Toggle]",  invoke=function() ImpulseTrackerStop() end}
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F8 Stop Playback (Panic)", invoke=function() ImpulseTrackerStop()  end}
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F8 Stop Playback (Panic) (2nd)", invoke=function() ImpulseTrackerStop() end}

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F8 Stop/Start Playback (Panic)", invoke=function() 
local t = renoise.song().transport
local startpos = t.playback_pos

if t.playing then ImpulseTrackerStop() 
   t.edit_mode=true
else
  startpos.sequence = 1
  startpos.line = 1
  t.playback_pos = startpos
      t.playing=true
   -- ImpulseTrackerPlaySong()
   t.edit_mode=false end
end}
----------------------------------------------------------------------------------------------------------------
-- F11, or "Impulse Tracker Shortcut F11 display-change", "Order List",
-- Hides Pattern Matrix, Hides Advanced Edit.
-- Changes to Mixer, Track Scopes, Track DSPs.
-- Second press makes Pattern Matrix visible and changes to Automation.
-- Sample Recorder will stay open, if Sample Recorder is already open.
function F11() 
local  w=renoise.app().window
local raw=renoise.ApplicationWindow
if w.upper_frame_is_visible==true and w.pattern_matrix_is_visible==false and w.active_middle_frame==2 and w.active_lower_frame==1 then
w.pattern_matrix_is_visible=true
w.active_lower_frame=raw.LOWER_FRAME_TRACK_AUTOMATION -- Set to Automation.
else w.pattern_matrix_is_visible=false
w.active_lower_frame=raw.LOWER_FRAME_TRACK_DSPS -- Set to Track DSPs.
end
w.active_upper_frame=raw.UPPER_FRAME_TRACK_SCOPES -- Set to Track Scopes
w.active_middle_frame=raw.MIDDLE_FRAME_MIXER -- Set to Mixer
w.lower_frame_is_visible=true
w.upper_frame_is_visible=true
w.lock_keyboard_focus=true
w.pattern_advanced_edit_is_visible=false
--w.instrument_box_is_visible=false
--w.disk_browser_is_visible=false
end

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F11 Order List", invoke=function() F11() end}
----------------------------------------------------------------------------------------------------------------
-- F12, or "Not really IT F11, not really IT F12 either".
-- Hides Pattern Matrix, Hides Advanced Edit.
-- Changes to Mixer, Track DSPs, Master Spectrum.
-- Changes to Master track.
-- Second press switches to Song Settings.
-- Sample Recorder will stay open, if Sample Recorder is already open.
function F12()
local w=renoise.app().window
local s=renoise.song()
local raw=renoise.ApplicationWindow
w.pattern_matrix_is_visible = false
s.selected_track_index=s.sequencer_track_count+1 -- Hard-set selected_track to Master
w.lower_frame_is_visible=true
w.upper_frame_is_visible=true

if not s.selected_track_index == s.sequencer_track_count+1 then
s.selected_track_index = s.sequencer_track_count+1
w.active_lower_frame=raw.LOWER_FRAME_TRACK_DSPS
return
else end

if w.active_lower_frame==raw.LOWER_FRAME_TRACK_DSPS and w.active_middle_frame==raw.MIDDLE_FRAME_MIXER and w.pattern_advanced_edit_is_visible==false and w.pattern_matrix_is_visible==false then w.pattern_matrix_is_visible = false 
w.active_lower_frame=raw.LOWER_FRAME_TRACK_AUTOMATION
else w.active_lower_frame=raw.LOWER_FRAME_TRACK_DSPS -- Set to Track DSPs
end
w.active_upper_frame=raw.UPPER_FRAME_TRACK_SCOPES -- Set to Track Scopes
w.active_middle_frame=raw.MIDDLE_FRAME_MIXER -- Set to Mixer
w.lock_keyboard_focus=true
w.pattern_advanced_edit_is_visible=false
end
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F12 Master", invoke=function() F12() end}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Impulse Tracker Next / Previous Pattern (keyboard + midi)
function ImpulseTrackerNextPattern()
local s=renoise.song()
if s.transport.follow_player==false then s.transport.follow_player=true end
  if s.transport.playing==false then 
   if s.selected_sequence_index==(table.count(s.sequencer.pattern_sequence)) then return 
  else
  s.selected_sequence_index=s.selected_sequence_index+1 end

  else if s.selected_sequence_index==(table.count(s.sequencer.pattern_sequence)) then
s.transport:trigger_sequence(1) else s.transport:trigger_sequence(s.selected_sequence_index+1) end
  end
end

function ImpulseTrackerPrevPattern()
local s=renoise.song()
local t=s.transport
if t.follow_player==false then t.follow_player=true end
    if t.playing==false then 
    if s.selected_sequence_index==1 then return 
    else s.selected_sequence_index=s.selected_sequence_index-1 end
else
  if s.selected_sequence_index==1 then t:trigger_sequence(s.selected_sequence_index) else
t:trigger_sequence(s.selected_sequence_index-1) end
  end
end

renoise.tool():add_midi_mapping{name="Global:Paketti:Impulse Tracker Next Pattern x[Toggle]", invoke=function() ImpulseTrackerNextPattern() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Impulse Tracker Previous Pattern x[Toggle]", invoke=function() ImpulseTrackerPrevPattern() end}

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker Next Pattern", invoke=function() ImpulseTrackerNextPattern() end}
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker Previous Pattern", invoke=function() ImpulseTrackerPrevPattern() end}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--IT: ALT-D (whole track) Double-select
function DoubleSelect()
 
 local s = renoise.song()
 local lpb = s.transport.lpb
 local sip = s.selection_in_pattern
 local last_column = s.selected_track.visible_effect_columns + s.selected_track.visible_note_columns

 if sip == nil or sip.start_track ~= s.selected_track_index or s.selected_line_index ~= s.selection_in_pattern.start_line then 
 
  s.selection_in_pattern = { 
    start_line = s.selected_line_index, 
      end_line = lpb + s.selected_line_index - 1,
   start_track = s.selected_track_index, 
     end_track = s.selected_track_index, 
  start_column = 1, 
    end_column = last_column }
 else 

  local endline = sip.end_line
  local startline = sip.start_line
  local new_endline = (endline - startline) * 2 + (startline + 1)

  if new_endline > s.selected_pattern.number_of_lines then
   new_endline = s.selected_pattern.number_of_lines
  end

  s.selection_in_pattern = { 
    start_line = startline, 
      end_line = new_endline, 
   start_track = s.selected_track_index, 
     end_track = s.selected_track_index, 
  start_column = 1, 
    end_column = last_column }
 end
end

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Paketti DoubleSelect (ALT-D)", invoke=function() DoubleSelect() end}
--------------------------------------------------------------------------------------------------------------------------------
-- Protman's set octave
-- Protman: Thanks to suva for the function per octave declaration loop :)
-- http://www.protman.com
function Octave(new_octave)
  local new_pos = 0
  local s = renoise.song()
  local editstep = s.transport.edit_step

  new_pos = s.transport.edit_pos
  if ((s.selected_note_column ~= nil) and (s.selected_note_column.note_value < 120)) then
    s.selected_note_column.note_value = s.selected_note_column.note_value  % 12 + (12 * new_octave)
  end
  new_pos.line = new_pos.line + editstep
  if new_pos.line <= s.selected_pattern.number_of_lines then
     s.transport.edit_pos = new_pos
  end
end

for oct=0,9 do
  renoise.tool():add_keybinding{
    name = "Pattern Editor:Paketti:Set Note to Octave " .. oct,
    invoke=function() Octave(oct) end }
end
-------------------------------------------------------------------------------------------------------------------------------------
------Protman PageUp PageDn
--PageUp / PageDown ImpulseTracker behaviour (reads according to LPB, and disables
--Pattern Follow to "eject" you out of playback back to editing step-by-step)
function Jump(Dir)
  local new_pos = 0
  local s=renoise.song()
  local lpb = s.transport.lpb
  local pat_lines = s.selected_pattern.number_of_lines
    new_pos = s.transport.edit_pos
    new_pos.line = new_pos.line + lpb * 2 * Dir
    if (new_pos.line < 1) then
    s.transport.follow_player = false
      new_pos.line = 1
      else if (new_pos.line > pat_lines) then
    s.transport.follow_player = false
        new_pos.line = pat_lines
      end
    end
    if ((Dir == -1) and (new_pos.line == pat_lines - ((lpb * 2)))) then
      new_pos.line = (pat_lines - (lpb*2) + 1)
    s.transport.follow_player = false
    end
    s.transport.edit_pos = new_pos
    s.transport.follow_player = false
end  

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker Jump Lines PageUp", invoke=function() Jump(-1) end  }
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker Jump Lines PageDown", invoke=function() Jump(1) end  }
-----------------------------------------------------------------------------------------------------------------
---------Protman's Expand Selection
function cpclex_line(track, from_line, to_line)
  local s=renoise.song()
  local cur_track = s:pattern(s.selected_pattern_index):track(track)
  cur_track:line(to_line):copy_from(cur_track:line(from_line))
  cur_track:line(from_line):clear()
  cur_track:line(to_line+1):clear()
end

function ExpandSelection()
  local s = renoise.song()
  local sl = s.selection_in_pattern.start_line
  local el = s.selection_in_pattern.end_line
  local st = s.selection_in_pattern.start_track
  local et = s.selection_in_pattern.end_track
  local nl = s.selected_pattern.number_of_lines
  local tr
  
  for tr=st,et do
    for l =el,sl,-1 do
      if l ~= sl and l*2-sl <= nl
        then
        cpclex_line(tr,l,l*2-sl)
      end
    end
  end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Expand Selection (Protman)", invoke=function() ExpandSelection() end}
------------------------------------------------------------------------------------------------------------------------------------
-------Protman's Shrink Selection
function cpclsh_line(track, from_line, to_line)
  local cur_track = renoise.song():pattern(renoise.song().selected_pattern_index):track(track)
  cur_track:line(to_line):copy_from(cur_track:line(from_line))
  cur_track:line(from_line):clear()
  cur_track:line(from_line+1):clear()
end

function ShrinkSelection()
  local s = renoise.song()
  local sl = s.selection_in_pattern.start_line
  local el = s.selection_in_pattern.end_line
  local st = s.selection_in_pattern.start_track
  local et = s.selection_in_pattern.end_track
  local tr
  
  for tr=st,et do
    for l =sl,el,2 do
      if l ~= sl
        then
        cpclsh_line(tr,l,l/2+sl/2)
      end
    end
  end
end
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Shrink Selection (Protman)", invoke=function() ShrinkSelection() end}

-----------------------------------------------------------------------------------------------------------------------------------------
--Protman's Set Instrument
function SetInstrument()
local s=renoise.song()
local EMPTY_INSTRUMENT = renoise.PatternTrackLine.EMPTY_INSTRUMENT
local pattern_iter = s.pattern_iterator
local pattern_index = s.selected_pattern_index
for _,line in pattern_iter:lines_in_pattern(pattern_index) do
  -- will be nil when a send or the master track is iterated
for i=0,s.tracks[s.selected_track_index].visible_note_columns do

 local first_note_column = line.note_columns[i]
  if (first_note_column and 
      first_note_column.instrument_value ~= EMPTY_INSTRUMENT and 
      first_note_column.is_selected) 
  then
    first_note_column.instrument_value = s.selected_instrument_index - 1 end
end  
end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Selection to Current Instrument (Protman)", invoke=function() SetInstrument() end} 
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
function MarkTrackMarkPattern()
--Known bug: If you're on Send, and press Alt-L, it selects all effect columns of Send. 
--Second press of Alt-L will select all the channels in the track, but deselect Master + Send tracks.
--Known bug: Has no idea as to what to do with Groups. Impulse Tracker
local st=nil
local et=nil
local sl=nil
local el=nil
local s=renoise.song()
local sip=s.selection_in_pattern
local sp=s.selected_pattern
if sip ~= nil then 
  st = sip.start_track
  et = sip.end_track
  sl = sip.start_line
  el = sip.end_line

  if st == et and st == s.selected_track_index then
    if sl == 1 and el == sp.number_of_lines then
      s.selection_in_pattern = {
        start_track = 1,
        end_track = s.sequencer_track_count,
          start_line=1,
        end_line=sp.number_of_lines
      }
    else
        s.selection_in_pattern = {
        start_track = st,
          end_track = et,
          start_line = 1, 
       end_line = sp.number_of_lines}
    end
  else
      s.selection_in_pattern = {
      start_track = s.selected_track_index,
        end_track = s.selected_track_index,
        start_line = 1, 
        end_line = sp.number_of_lines}  end
else
  s.selection_in_pattern ={
      start_track = s.selected_track_index,
        end_track = s.selected_track_index,
        start_line = 1, 
        end_line = sp.number_of_lines} end
end

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Paketti Mark Track/Mark Pattern (ALT-L)", invoke=function() MarkTrackMarkPattern() end}  
-------------------------------------------------------------------------------------------------------------------------------------------Protman's Alt-D except patternwide
function DoubleSelectPattern()
 local s = renoise.song()
 local lpb = s.transport.lpb
 local sip = s.selection_in_pattern
-- local last_column = s.selected_track.visible_effect_columns + s.selected_track.visible_note_columns
 local last_column = s.selected_track.visible_note_columns

 if sip == nil or sip.start_track ~= s.selected_track_index or s.selected_line_index ~= s.selection_in_pattern.start_line then 
 
  s.selection_in_pattern = { 
    start_line = s.selected_line_index, 
      end_line = lpb + s.selected_line_index - 1,
   start_track = 1, 
     end_track = renoise.song().sequencer_track_count+1, 
  start_column = 1, 
    end_column = last_column }
 else 
  local endline = sip.end_line
  local startline = sip.start_line
  local new_endline = (endline - startline) * 2 + (startline + 1)

  if new_endline > s.selected_pattern.number_of_lines then
   new_endline = s.selected_pattern.number_of_lines
  end

print ("new_endline " .. new_endline)
  s.selection_in_pattern = { 
    start_line = startline, 
      end_line = new_endline, 
   start_track = 1, 
     end_track = renoise.song().sequencer_track_count+1, 
  start_column = 1, 
    end_column = last_column }
 end
end
-------------------------------------------------------------------------------------------------------------------------------------------IT: Alt-D except Current Column only
function DoubleSelectColumnOnly()
 local s = renoise.song()
 local lpb = s.transport.lpb
 local sip = s.selection_in_pattern
 local last_column = s.selected_track.visible_effect_columns + s.selected_track.visible_note_columns
 local currTrak=s.selected_track_index
 local selection=nil
 
 if s.selected_note_column_index==0 then selection=renoise.song().tracks[currTrak].visible_note_columns+s.selected_effect_column_index
 else selection=s.selected_note_column_index
end 
 if sip == nil or sip.start_track ~= s.selected_track_index or s.selected_line_index ~= s.selection_in_pattern.start_line then 
 
  s.selection_in_pattern = { 
    start_line = s.selected_line_index, 
      end_line = lpb + s.selected_line_index - 1,
   start_track = s.selected_track_index, 
     end_track = s.selected_track_index, 
  start_column = selection, 
    end_column = selection }
 else 

  local endline = sip.end_line
  local startline = sip.start_line
  local new_endline = (endline - startline) * 2 + (startline + 1)

  if new_endline > s.selected_pattern.number_of_lines then
   new_endline = s.selected_pattern.number_of_lines
  end

  s.selection_in_pattern = { 
    start_line = startline, 
      end_line = new_endline, 
   start_track = s.selected_track_index, 
     end_track = s.selected_track_index, 
  start_column = selection, 
    end_column = selection }
 end
end

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Paketti DoubleSelectColumnOnly (Protman)", invoke=function() DoubleSelectColumnOnly() end}
renoise.tool():add_keybinding{name="Pattern Editor:Selection:Paketti DoubleSelectPattern (Protman)", invoke=function() DoubleSelectPattern() end}
--------------------------------------------------------------------------------------------------------------------------------------
--IT "Home Home Home" behaviour. First Home takes to current column first_line. Second Home takes to current track first_line. 
--Third home takes to first track first_line.
function homehome()
  local s = renoise.song()
  local song_pos = s.transport.edit_pos
  local selcol = s.selected_note_column_index
  s.transport.follow_player = false
  s.transport.loop_block_enabled=false
  local w = renoise.app().window
  
-- Always set to pattern editor
renoise.app().window.active_middle_frame=1

-- If on Master or Send-track, detect and go to first effect column.
if s.selected_note_column_index==0 and s.selected_effect_column_index > 1 and song_pos.line == 1 and renoise.song().tracks[renoise.song().selected_track_index].visible_note_columns==0 then
s.selected_effect_column_index = 1 return end

-- If on Master or Send-track, detect and go to 1st track and first note column.
if s.selected_note_column_index==0 and song_pos.line == 1 and renoise.song().tracks[renoise.song().selected_track_index].visible_note_columns==0 then
s.selected_track_index = 1
s.selected_note_column_index = 1 return end

-- If Effect-columns chosen, take you to current effect column's first row.
if s.selected_note_column_index==0 and song_pos.line == 1 then
s.selected_note_column_index=1 return end

if s.selected_note_column_index==0 then 
song_pos.line = 1
s.transport.edit_pos = song_pos return end

-- If Song Position Line is already First Line - but Selected Note Column is not 1
-- Then go to Selected Note Column 1 First Line. Return outside of script immediately.
if song_pos.line == 1 and s.selected_note_column_index > 1 then
s.selected_note_column_index = 1 return end

-- If Song Position Line is not 1, and Selected Note Column is not 1
-- Then go to Selected Note Column's First Line. Return outside of script immediately.
if (s.selected_note_column_index > 1) then
s.selected_note_column_index = selcol
song_pos.line = 1
s.transport.edit_pos = song_pos return end

  if (song_pos.line > 1) then
    song_pos.line = 1          
    s.transport.edit_pos = song_pos   
      if s.selected_note_column_index==0 then 
      s.selected_effect_column_index=1 
      else s.selected_note_column_index=1
      end
    return    
  end  
-- Go to first track
  if (s.selected_track_index > 1) then
    s.selected_track_index = 1
    s.selected_note_column_index=1 return end
  s.selected_note_column_index=1
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Home *2 behaviour", invoke=function()
renoise.app().window.active_middle_frame=1
homehome() end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Home *2 behaviour (2nd)", invoke=function()
renoise.app().window.active_middle_frame=1
homehome() end}

renoise.tool():add_keybinding{name="Mixer:Paketti:Impulse Tracker Home *2 behaviour", invoke=function()
renoise.app().window.active_middle_frame=1
homehome() end}
---------------------------------------------------------------------------------------------------------------------------------------IT EndEnd
function endend()
  local s = renoise.song()
  local number = s.patterns[s.selected_pattern_index].number_of_lines
  local song_pos = s.transport.edit_pos
  local selcol = s.selected_note_column_index
  s.transport.follow_player = false
  s.transport.loop_block_enabled=false
  
-- always set to pattern editor
renoise.app().window.active_middle_frame=1
  
--  s.selected_note_column_index=1 
song_pos.line = number
s.transport.edit_pos = song_pos

--[[if song_pos.line == 1 then song_pos.line = number else song_pos.line = number s.selected_track_index = renoise.song().sequencer_track_count
return
end  
--]]  
--  s.selected_track_index = 7
--  song_pos.line = 64
--song_pos.line = 2
  
--[[

-- If on Master or Send-track, detect and go to first effect column.
if s.selected_note_column_index==0 and s.selected_effect_column_index > 1 and song_pos.line == 1 and renoise.song().tracks[renoise.song().selected_track_index].visible_note_columns==0 then
s.selected_effect_column_index = 1
return end

-- If on Master or Send-track, detect and go to 1st track and first note column.
if s.selected_note_column_index==0 and song_pos.line == 1 and renoise.song().tracks[renoise.song().selected_track_index].visible_note_columns==0 then
s.selected_track_index = renoise.song().sequencer_track_count
s.selected_note_column_index = 0
return end

-- If Effect-columns chosen, take you to current effect column's first row.
if s.selected_note_column_index==0 and song_pos.line == number then
s.selected_note_column_index=renoise.song().sequencer_track_count+1
return end
--]]
if s.selected_note_column_index==0 then 
  song_pos.line = number
  s.transport.edit_pos = song_pos return end

--[[--
-- If Song Position Line is already First Line - but Selected Note Column is not 1
-- Then go to Selected Note Column 1 First Line. Return outside of script immediately.
if song_pos.line == number and s.selected_note_column_index > 1 then
s.selected_note_column_index = 1
return
else end

-- If Song Position Line is not 1, and Selected Note Column is not 1
-- Then go to Selected Note Column's First Line. Return outside of script immediately.
if (s.selected_note_column_index > 1) then
s.selected_note_column_index = selcol
song_pos.line = number
s.transport.edit_pos = song_pos 
return
else 
end

  if (song_pos.line > number) then
    song_pos.line = number          
    s.transport.edit_pos = song_pos   
      if s.selected_note_column_index==0 then 
      s.selected_effect_column_index=1 
      else s.selected_note_column_index=1
      end
    return    
  end  
-- Go to first track
  if (s.selected_track_index > 1) then
    s.selected_track_index = 1
    s.selected_note_column_index=1
    return
  end
  s.selected_note_column_index=1
  --]]
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker End *2 behaviour", invoke=function() 
renoise.app().window.active_middle_frame=1
endend() end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker End *2 behaviour (2nd)", invoke=function() 
renoise.app().window.active_middle_frame=1
endend() end}

renoise.tool():add_keybinding{name="Mixer:Paketti:Impulse Tracker End *2 behaviour", invoke=function()
renoise.app().window.active_middle_frame=1
endend() end}
-----------------------------------------------------------------------------------------------------------------------------------------
--8.  "8" in Impulse Tracker "Plays Current Line" and "Advances by EditStep".
function PlayCurrentLine()
local s=renoise.song()
local currpos=s.transport.edit_pos
local sli=s.selected_line_index
local t=s.transport
local result=nil
t:start_at(sli)
local start_time = os.clock()
  while (os.clock() - start_time < 0.2) do
        -- Delay the start after panic. Don't go below 0.2 seconds 
        -- or you might tempt some plugins to crash and take Renoise in the fall!!      
  end
  t:stop()
    if s.selected_line_index == s.selected_pattern.number_of_lines then
    s.selected_line_index = 1
    else
    
      if s.selected_pattern.number_of_lines <  s.selected_line_index+s.transport.edit_step
      then s.selected_line_index=s.selected_pattern.number_of_lines
      else s.selected_line_index=s.selected_line_index+s.transport.edit_step end
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Play Current Line & Advance by EditStep", invoke=function() PlayCurrentLine() end}
