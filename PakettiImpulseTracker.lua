----------------------------------------------------------------------------------------------------------------
-- F2
function F2()
local w=renoise.app().window
local raw=renoise.ApplicationWindow
w.lock_keyboard_focus=true

if w.active_middle_frame==raw.MIDDLE_FRAME_PATTERN_EDITOR and w.lower_frame_is_visible then
--renoise.app().window:select_preset(8)
  w.lower_frame_is_visible=false
    renoise.app().window.pattern_advanced_edit_is_visible=false
  w.upper_frame_is_visible=false
  w.pattern_advanced_edit_is_visible=false
  w.instrument_box_is_visible=true
  w.disk_browser_is_visible=true
  w.pattern_matrix_is_visible=false
else w.active_middle_frame=raw.MIDDLE_FRAME_PATTERN_EDITOR
  w.lower_frame_is_visible=true
  w.upper_frame_is_visible=true
    renoise.app().window.pattern_advanced_edit_is_visible=false
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
    renoise.app().window.pattern_advanced_edit_is_visible=true
--renoise.app().window:select_preset(8)
return end 

--if preferences.upperFramePreference ~= 0 then  w.active_upper_frame = preferences.upperFramePreference else end


end

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
-- F3
function F3()
  local w = renoise.app().window
  local raw = renoise.ApplicationWindow

if w.active_middle_frame == raw.MIDDLE_FRAME_MIXER and w.upper_frame_is_visible == false then
w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
w.upper_frame_is_visible = true
return else end
  if w.active_middle_frame == raw.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR or 
     w.active_middle_frame == raw.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR or 
     w.active_middle_frame == raw.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR or 
     w.active_middle_frame == raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES or
     w.active_middle_frame == raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION 
     then
    w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
    w.lock_keyboard_focus = true
    w.disk_browser_is_visible = true
    w.instrument_box_is_visible = true
    return
  end

  if w.active_middle_frame == 5 then
    w.active_middle_frame = 7
    return
  elseif w.active_middle_frame == 7 then
    w.active_middle_frame = 5
    return
  end

  -- Rest of the original logic remains unchanged
  w.pattern_matrix_is_visible = false
  w.pattern_advanced_edit_is_visible = false

  if w.active_middle_frame == 1 then
    w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
    w.lock_keyboard_focus = true
    w.disk_browser_is_visible = true
    w.instrument_box_is_visible = true

    if w.upper_frame_is_visible == true then
      w.active_upper_frame = 2
    else
      return
    end

    w.upper_frame_is_visible = true
    w.active_upper_frame = 2
    return
  else
  end

  if w.upper_frame_is_visible == true then
  else
    return
  end

  if w.active_middle_frame == raw.MIDDLE_FRAME_PATTERN_EDITOR and w.lower_frame_is_visible == false and w.pattern_advanced_edit_is_visible == false and w.upper_frame_is_visible == false then
    w.upper_frame_is_visible = true
    w.disk_browser_is_visible = true
    return
  else
  end

  local s = renoise.song()
  s.selected_instrument.active_tab = 1
  w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end


renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F3 Sample Editor", invoke=function() F3() end}

---


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
--if preferences.upperFramePreference ~= 0 then 
-- w.active_upper_frame = preferences.upperFramePreference
--else end

--w.active_upper_frame=1 -- Force-sets to Track Scopes.
--w.active_lower_frame =3 -- Set to Instrument Settings
--w.lock_keyboard_focus=true
--w.pattern_matrix_is_visible=false
--w.pattern_advanced_edit_is_visible=false
--w.disk_browser_is_expanded=true
if w.active_middle_frame == raw.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR then
w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR
w.active_middle_frame = raw.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR
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
  while (os.clock() - start_time < 0.225) do
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

if renoise.song().transport.playing == false then
renoise.song().selected_sequence_index = 1
renoise.song().selected_line_index = 1
else 
t.follow_player=false
t:panic()
t.loop_pattern=false
t.loop_block_enabled=false
renoise.song().selected_line_index = 1
end
end

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
w.active_lower_frame=raw.LOWER_FRAME_TRACK_AUTOMATION
else w.pattern_matrix_is_visible=false
w.active_lower_frame=raw.LOWER_FRAME_TRACK_DSPS
end

--    if preferences and preferences.upperFramePreference and preferences.upperFramePreference ~= 0 then 
--        w.active_upper_frame = preferences.upperFramePreference
--    end
    
--w.active_upper_frame=raw.UPPER_FRAME_TRACK_SCOPES
w.active_middle_frame=raw.MIDDLE_FRAME_MIXER
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
  local w = renoise.app().window
  local s = renoise.song()
  local raw = renoise.ApplicationWindow

  w.pattern_matrix_is_visible = false
  
  if renoise.app().window.active_middle_frame==8 or renoise.app().window.active_middle_frame==9 or renoise.app().window.active_middle_frame == 5 or renoise.app().window.active_middle_frame == 7 or renoise.app().window.active_middle_frame == 1 then
      s.selected_track_index = s.sequencer_track_count + 1
    w.active_middle_frame = raw.MIDDLE_FRAME_MIXER
    w.active_lower_frame = raw.LOWER_FRAME_TRACK_DSPS
  w.upper_frame_is_visible = true

  return else end
  -- Check if the Mixer is not visible and Track Automation is displaying
  if w.active_middle_frame ~= raw.MIDDLE_FRAME_MIXER and w.active_lower_frame == raw.LOWER_FRAME_TRACK_AUTOMATION then
    s.selected_track_index = s.sequencer_track_count + 1
    w.active_middle_frame = raw.MIDDLE_FRAME_MIXER
    w.active_lower_frame = raw.LOWER_FRAME_TRACK_DSPS
    return
  end

  w.lower_frame_is_visible = true
  w.upper_frame_is_visible = true

  -- Ensure the Master track is selected
  if s.selected_track_index ~= s.sequencer_track_count + 1 then
    s.selected_track_index = s.sequencer_track_count + 1
    w.active_lower_frame = raw.LOWER_FRAME_TRACK_DSPS
    return
  end

  -- Cycle through Track DSPs and Track Automation when the Master track is selected
  if w.active_lower_frame == raw.LOWER_FRAME_TRACK_DSPS and s.selected_track_index == s.sequencer_track_count + 1 then
    w.active_lower_frame = raw.LOWER_FRAME_TRACK_AUTOMATION
    return
  end

  -- Default case: set the lower frame to Track DSPs and upper frame to Track Scopes
  w.active_lower_frame = raw.LOWER_FRAME_TRACK_DSPS
  w.active_upper_frame = raw.UPPER_FRAME_TRACK_SCOPES
  w.lock_keyboard_focus = true
  w.pattern_advanced_edit_is_visible = false
end

-- Add the keybinding to ensure the function can be invoked using F12
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker F12 Master", invoke=function() F12() end}

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Impulse Tracker Next / Previous Pattern (Keyboard + Midi)
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

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker Pattern (Next)", invoke=function() ImpulseTrackerNextPattern() end}
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker Pattern (Previous)", invoke=function() ImpulseTrackerPrevPattern() end}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--IT: ALT-D (whole track) Double-select
function DoubleSelect()
 
 local s = renoise.song()
 local lpb = s.transport.lpb
 local sip = s.selection_in_pattern
 local last_column = s.selected_track.visible_effect_columns + s.selected_track.visible_note_columns
 local protectrow= lpb + s.selected_line_index - 1
 if protectrow > s.selected_pattern.number_of_lines then
 protectrow = s.selected_pattern.number_of_lines end
 
 if sip == nil or sip.start_track ~= s.selected_track_index or s.selected_line_index ~= s.selection_in_pattern.start_line then 
 
  s.selection_in_pattern = { 
    start_line = s.selected_line_index, 
--      end_line = lpb + s.selected_line_index - 1,
      end_line = protectrow,
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

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Impulse Tracker ALT-D Double Select", invoke=function() DoubleSelect() end}
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
  renoise.tool():add_keybinding{name = "Pattern Editor:Paketti:Set Note to Octave " .. oct,
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

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker PageUp Jump Lines", invoke=function() Jump(-1) end  }
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker PageDown Jump Lines", invoke=function() Jump(1) end  }
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
  if s.selection_in_pattern == nil then
  return
  else  
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
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker ALT-F Expand Selection", invoke=function() ExpandSelection() end}
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
  if s.selection_in_pattern == nil then
  return
  else
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
end
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker ALT-G Shrink Selection", invoke=function() ShrinkSelection() end}
--------------------------------------------------------
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

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker ALT-S Set Selection to Instrument", invoke=function() SetInstrument() end} 
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
function MarkTrackMarkPattern()
--Known bug: Has no idea as to what to do with Groups.
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
  local totalTrackCount=s.sequencer_track_count + 1 + s.send_track_count
  if st == et and st == s.selected_track_index then
    if sl == 1 and el == sp.number_of_lines then
      s.selection_in_pattern = {
        start_track = 1,
        end_track = totalTrackCount,
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

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Impulse Tracker ALT-L Mark Track/Mark Pattern", invoke=function() MarkTrackMarkPattern() end}  
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

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Impulse Tracker DoubleSelectColumnOnly (Protman)", invoke=function() DoubleSelectColumnOnly() end}
renoise.tool():add_keybinding{name="Pattern Editor:Selection:Impulse Tracker DoubleSelectPattern (Protman)", invoke=function() DoubleSelectPattern() end}
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

  -- Disable follow player and loop block
  s.transport.follow_player = false
  s.transport.loop_block_enabled = false

  -- Always set to pattern editor
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  -- Check if we are in the last row
  if song_pos.line == number then
    -- Move to the last row of the last track before the master track
    song_pos.line = number
    s.selected_track_index = renoise.song().sequencer_track_count
  else
    -- Move to the last row of the current note column
    song_pos.line = number
  end

  -- Update the edit position
  s.transport.edit_pos = song_pos
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
  while (os.clock() - start_time < 0.4) do
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

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker 8 Play Current Line & Advance by EditStep", invoke=function() PlayCurrentLine() end}
-----------------
-- alt-f9 - solo / unsolo selected track. if not in Pattern Editor or in Mixer, transport to Pattern Editor.
function impulseTrackerSoloKey()
local s=renoise.song()
  s.tracks[renoise.song().selected_track_index]:solo()
    if renoise.app().window.active_middle_frame~=1 and renoise.app().window.active_middle_frame~=2 then renoise.app().window.active_middle_frame=1 end
end

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker ALT-F10 (Solo Toggle)", invoke=function() impulseTrackerSoloKey() end}
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
-----------
local vb = renoise.ViewBuilder()
local dialog = nil  -- Declare dialog variable

-- Variables to store the state of each section
local patterns_state = "Keep"
local instruments_state = "Keep"
local pattern_sequence_state = "Keep"
local instrument_midi_outs_state = "Keep"
local instrument_samples_state = "Keep"
local instrument_plugins_state = "Keep"
local track_dsps_state = "Keep"

-- Functions to clear patterns, instruments, pattern sequence, MIDI outs, samples, plugins, and Track DSPs
function patternClear()
  local song = renoise.song()
  for i = 1, #song.patterns do
    song.patterns[i]:clear()
  end
end

function instrumentsClear()
  local song = renoise.song()
  for i = 1, #song.instruments do
    song.instruments[i]:clear()
  end
end

function patternSequenceClear()
  local song = renoise.song()
  local sequence_length = #song.sequencer.pattern_sequence
  for i = sequence_length, 2, -1 do
    song.sequencer:delete_sequence_at(i)
  end
end

function instrumentMidiOutsClear()
  local song = renoise.song()
  for i = 1, #song.instruments do
    song.instruments[i].midi_output_properties.device_name = ""
  end
end

function instrumentSamplesClear()
  local song = renoise.song()
  for i = 1, #song.instruments do
    local instrument = song.instruments[i]
    if #instrument.samples > 1 then
      instrument:delete_sample_at(1)
      if #instrument.samples > 1 then
        for j = #instrument.samples, 1, -1 do
          instrument:delete_sample_at(j)
        end
      end
    elseif #instrument.samples == 1 then
      instrument:delete_sample_at(1)
    end
  end
end

function instrumentPluginsClear()
  local song = renoise.song()
  for i = 1, #song.instruments do
    song.instruments[i].plugin_properties:load_plugin("")
  end
end

function trackDspsClear()
  local song = renoise.song()
  for _, track in ipairs(song.tracks) do
    for i = #track.devices, 2, -1 do
      track:delete_device_at(i)
    end
  end
end

-- Function to clear all registered views
local function clear_registered_views()
  for id, _ in pairs(vb.views) do
    vb.views[id] = nil
  end
end

-- Function to handle the "Set all to" switch change
function handle_set_all_switch_change(value)
  local state = value == 1 and "Keep" or "Clear"
  
  patterns_state = state
  instruments_state = state
  pattern_sequence_state = state
  instrument_midi_outs_state = state
  instrument_samples_state = state
  instrument_plugins_state = state
  track_dsps_state = state

  -- Update all switches in the UI
  vb.views.patterns_switch.value = value
  vb.views.instruments_switch.value = value
  vb.views.pattern_sequence_switch.value = value
  vb.views.instrument_midi_outs_switch.value = value
  vb.views.instrument_samples_switch.value = value
  vb.views.instrument_plugins_switch.value = value
  vb.views.track_dsps_switch.value = value
end

-- Function to handle switch changes
function handle_switch_change(value, section)
  local state = value == 1 and "Keep" or "Clear"
  if section == "Patterns" then
    patterns_state = state
  elseif section == "Instruments" then
    instruments_state = state
  elseif section == "Pattern Sequence" then
    pattern_sequence_state = state
  elseif section == "Instrument MIDI Outs" then
    instrument_midi_outs_state = state
  elseif section == "Instrument Samples" then
    instrument_samples_state = state
  elseif section == "Instrument Plugins" then
    instrument_plugins_state = state
  elseif section == "Track DSPs" then
    track_dsps_state = state
  end
end

-- Function to handle the OK button click
function handle_ok_click()
  return function()
    local actions = {}
    if patterns_state == "Clear" and instruments_state == "Clear" and pattern_sequence_state == "Clear" and 
       instrument_midi_outs_state == "Clear" and instrument_samples_state == "Clear" and instrument_plugins_state == "Clear" and
       track_dsps_state == "Clear" then  -- Check Track DSPs state
      renoise.app():new_song()
    else
      if patterns_state == "Clear" then
        patternClear()
        table.insert(actions, "Patterns")
      end
      if instruments_state == "Clear" then
        instrumentsClear()
        table.insert(actions, "Instruments")
      end
      if pattern_sequence_state == "Clear" then
        patternSequenceClear()
        table.insert(actions, "Pattern Sequence")
      end
      if instrument_midi_outs_state == "Clear" then
        instrumentMidiOutsClear()
        table.insert(actions, "Instrument MIDI Outs")
      end
      if instrument_samples_state == "Clear" then
        instrumentSamplesClear()
        table.insert(actions, "Instrument Samples")
      end
      if instrument_plugins_state == "Clear" then
        instrumentPluginsClear()
        table.insert(actions, "Instrument Plugins")
      end
      if track_dsps_state == "Clear" then  -- Clear Track DSPs
        trackDspsClear()
        table.insert(actions, "Track DSPs")
      end
    end 

    local status_message = ""
    if #actions == 0 then
      status_message = "Kept all"
    else
      local kept = {}
      if patterns_state == "Keep" then table.insert(kept, "Patterns") end
      if instruments_state == "Keep" then table.insert(kept, "Instruments") end
      if pattern_sequence_state == "Keep" then table.insert(kept, "Pattern Sequence") end
      if instrument_midi_outs_state == "Keep" then table.insert(kept, "Instrument MIDI Outs") end
      if instrument_samples_state == "Keep" then table.insert(kept, "Instrument Samples") end
      if instrument_plugins_state == "Keep" then table.insert(kept, "Instrument Plugins") end
      if track_dsps_state == "Keep" then table.insert(kept, "Track DSPs") end  -- Handle Track DSPs in the status message
      if #kept > 0 then
        status_message = "Kept " .. table.concat(kept, ", ") .. "; "
      end
      status_message = status_message .. "Cleared " .. table.concat(actions, ", ")
    end
    renoise.app():show_status(status_message)
    dialog:close()
    clear_registered_views()  -- Clear registered views after dialog close
  end
end

-- Function to handle the Cancel button click
function handle_cancel_click()
  return function()
    dialog:close()
    clear_registered_views()  -- Clear registered views after dialog close
  end
end

-- Function to show the dialog
function show_new_song_dialog()
  -- Close any existing dialog before opening a new one
  if dialog and dialog.visible then
    dialog:close()
    clear_registered_views()  -- Ensure the reference is cleared
  end

  -- Resetting the ViewBuilder instance to ensure IDs are not reused
  vb = renoise.ViewBuilder()

  local dialog_content = vb:column {
    margin = 10,
    vb:text {text = "New Song ... with", font = "bold", align = "center"},
   
    -- "Set all to" switch   
    vb:space { height = 10 },
    vb:column {
      style = "border",
      margin = 10,
   vb:row {
      vb:text { text = "Set all to: ", width = 180 },
      vb:switch {
        id = "set_all_switch",
        items = { "Keep", "Clear" },
        value = 1,
        width = 100,
        notifier = handle_set_all_switch_change
      }
    },
    vb:space { height = 10 },
      vb:row {
        vb:text { text = "Patterns", width = 180 },
        vb:switch {
          id = "patterns_switch",
          items = { "Keep", "Clear" },
          value = patterns_state == "Keep" and 1 or 2,
          width = 100,
          notifier = function(value)
            handle_switch_change(value, "Patterns")
          end
        }
      },
      vb:row {
        vb:text { text = "Pattern Sequence", width = 180 },
        vb:switch {
          id = "pattern_sequence_switch",
          items = { "Keep", "Clear" },
          value = pattern_sequence_state == "Keep" and 1 or 2,
          width = 100,
          notifier = function(value)
            handle_switch_change(value, "Pattern Sequence")
          end
        }
      },
      vb:row {
        vb:text { text = "Instruments", width = 180 },
        vb:switch {
          id = "instruments_switch",
          items = { "Keep", "Clear" },
          value = instruments_state == "Keep" and 1 or 2,
          width = 100,
          notifier = function(value)
            handle_switch_change(value, "Instruments")
          end
        }
      },
      vb:row {
        vb:text { text = "Instrument Samples", width = 180 },
        vb:switch {
          id = "instrument_samples_switch",
          items = { "Keep", "Clear" },
          value = instrument_samples_state == "Keep" and 1 or 2,
          width = 100,
          notifier = function(value)
            handle_switch_change(value, "Instrument Samples")
          end
        }
      },
      vb:row {
        vb:text { text = "Instrument MIDI Outs", width = 180 },
        vb:switch {
          id = "instrument_midi_outs_switch",
          items = { "Keep", "Clear" },
          value = instrument_midi_outs_state == "Keep" and 1 or 2,
          width = 100,
          notifier = function(value)
            handle_switch_change(value, "Instrument MIDI Outs")
          end
        }
      },
      vb:row {
        vb:text { text = "Instrument Plugins", width = 180 },
        vb:switch {
          id = "instrument_plugins_switch",
          items = { "Keep", "Clear" },
          value = instrument_plugins_state == "Keep" and 1 or 2,
          width = 100,
          notifier = function(value)
            handle_switch_change(value, "Instrument Plugins")
          end
        }
      },
      vb:row {
        vb:text { text = "Track DSPs", width = 180 },
        vb:switch {
          id = "track_dsps_switch",
          items = { "Keep", "Clear" },
          value = track_dsps_state == "Keep" and 1 or 2,
          width = 100,
          notifier = function(value)
            handle_switch_change(value, "Track DSPs")
          end
        }
      },
      vb:space { height = 10 },
      vb:row {
        vb:button {text="OK", width=100, notifier=handle_ok_click()},
        vb:button {text="Cancel", width=100, notifier=handle_cancel_click(), color={1, 0, 0}}
      }
    }
  }

  -- Open the new dialog and assign it to the 'dialog' variable
  dialog = renoise.app():show_custom_dialog("New Song", dialog_content)
end

renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker CTRL-N New Song Dialog", invoke=function() show_new_song_dialog() end}


-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

----ALT-U
function Deselect_All() renoise.song().selection_in_pattern=nil end
function Deselect_Phr() renoise.song().selection_in_phrase =nil end

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Impulse Tracker ALT-U Unmark Selection",invoke=function() Deselect_All() end}
renoise.tool():add_keybinding{name="Pattern Editor:Selection:Impulse Tracker ALT-U Unmark Selection (2nd)",invoke=function() Deselect_All() end}

renoise.tool():add_keybinding{name="Phrase Editor:Selection:Impulse Tracker ALT-U Unmark Selection",invoke=function() Deselect_Phr() end}
renoise.tool():add_keybinding{name="Phrase Editor:Selection:Impulse Tracker ALT-U Unmark Selection (2nd)",invoke=function() Deselect_Phr() end}
------------
function PakettiImpulseTrackerSwapBlock()
  local song = renoise.song()
  local selection = song.selection_in_pattern

  if not selection then
    renoise.app():show_status("No selection in pattern.")
    return
  end

  local start_line = selection.start_line
  local end_line = selection.end_line
  local num_lines = end_line - start_line + 1
  local start_column = selection.start_column
  local end_column = selection.end_column
  local start_track = selection.start_track
  local end_track = selection.end_track
  local num_columns = end_column - start_column + 1

  local cursor_pos = song.transport.edit_pos
  local cursor_track = song.selected_track_index
  local cursor_line = cursor_pos.line
  local cursor_column = song.selected_note_column_index

  -- Ensure there are enough lines from the cursor position to swap
  if cursor_line + num_lines - 1 > #song:pattern(cursor_pos.sequence).tracks[cursor_track].lines then
    renoise.app():show_status("Not enough lines from cursor position to swap.")
    return
  end

  -- Adjust the number of visible note columns if necessary
  if song:track(cursor_track).visible_note_columns < cursor_column + num_columns then
    song:track(cursor_track).visible_note_columns = cursor_column + num_columns
  end

  -- Collect data from the selection in its original note columns and track
  local selection_data = {}
  for line = start_line, end_line do
    local line_data = {}
    for column = start_column, start_column + num_columns - 1 do
      local pattern_line = song:pattern(song.selected_pattern_index).tracks[start_track].lines[line]
      local note_column = pattern_line.note_columns[column]
      table.insert(line_data, {
        note_value = note_column.note_value,
        instrument_value = note_column.instrument_value,
        volume_value = note_column.volume_value,
        panning_value = note_column.panning_value,
        delay_value = note_column.delay_value,
        effect_number_value = note_column.effect_number_value,
        effect_amount_value = note_column.effect_amount_value
      })
    end
    table.insert(selection_data, line_data)
  end

  -- Collect data from the cursor block in its current note columns and track
  local cursor_data = {}
  for line = 0, num_lines - 1 do
    local line_data = {}
    for column = 0, num_columns - 1 do
      local pattern_line = song:pattern(song.selected_pattern_index).tracks[cursor_track].lines[cursor_line + line]
      local note_column = pattern_line.note_columns[cursor_column + column]
      table.insert(line_data, {
        note_value = note_column.note_value,
        instrument_value = note_column.instrument_value,
        volume_value = note_column.volume_value,
        panning_value = note_column.panning_value,
        delay_value = note_column.delay_value,
        effect_number_value = note_column.effect_number_value,
        effect_amount_value = note_column.effect_amount_value
      })
    end
    table.insert(cursor_data, line_data)
  end

  -- Print debug details
  print("Selection Data:")
  for i, line_data in ipairs(selection_data) do
    print("Line", i + start_line - 1)
    for j, column_data in ipairs(line_data) do
      print("  Column", j + start_column - 1, column_data)
    end
  end

  print("Cursor Data:")
  for i, line_data in ipairs(cursor_data) do
    print("Line", i + cursor_line - 1)
    for j, column_data in ipairs(line_data) do
      print("  Column", j + cursor_column, column_data)
    end
  end

  -- Swap the blocks between the selected note columns and the cursor note columns across tracks
  for line = 0, num_lines - 1 do
    for column = 0, num_columns - 1 do
      local pattern_line_at_cursor = song:pattern(song.selected_pattern_index).tracks[cursor_track].lines[cursor_line + line]
      local pattern_line_at_selection = song:pattern(song.selected_pattern_index).tracks[start_track].lines[start_line + line]

      local note_column_at_cursor = pattern_line_at_cursor.note_columns[cursor_column + column]
      local note_column_at_selection = pattern_line_at_selection.note_columns[start_column + column]

      local selection_column_data = selection_data[line + 1][column + 1]
      local cursor_column_data = cursor_data[line + 1][column + 1]

      -- Swap data between the selected note columns and the cursor note columns
      note_column_at_cursor.note_value = selection_column_data.note_value
      note_column_at_cursor.instrument_value = selection_column_data.instrument_value
      note_column_at_cursor.volume_value = selection_column_data.volume_value
      note_column_at_cursor.panning_value = selection_column_data.panning_value
      note_column_at_cursor.delay_value = selection_column_data.delay_value
      note_column_at_cursor.effect_number_value = selection_column_data.effect_number_value
      note_column_at_cursor.effect_amount_value = selection_column_data.effect_amount_value

      note_column_at_selection.note_value = cursor_column_data.note_value
      note_column_at_selection.instrument_value = cursor_column_data.instrument_value
      note_column_at_selection.volume_value = cursor_column_data.volume_value
      note_column_at_selection.panning_value = cursor_column_data.panning_value
      note_column_at_selection.delay_value = cursor_column_data.delay_value
      note_column_at_selection.effect_number_value = cursor_column_data.effect_number_value
      note_column_at_selection.effect_amount_value = cursor_column_data.effect_amount_value
    end
  end

  renoise.app():show_status("Blocks swapped successfully.")
end

-- Add the keybinding for the ALT-Y action
renoise.tool():add_keybinding{name="Global:Paketti:Impulse Tracker ALT-Y Swap Block",invoke=PakettiImpulseTrackerSwapBlock}
-----------

-- Move to the next track, maintaining column type, with wrapping.
function PakettiImpulseTrackerMoveForwardsTrackWrap()
  local song = renoise.song()
  local current_index = song.selected_track_index
  local is_effect_column = song.selected_effect_column_index > 0
  
  if current_index < #song.tracks then
    song.selected_track_index = current_index + 1
  else
    song.selected_track_index = 1
  end
  
  if is_effect_column then
    song.selected_effect_column_index = 1
  else
    song.selected_note_column_index = 1
  end
end

-- Move to the previous track, maintaining column type, with wrapping.
function PakettiImpulseTrackerMoveBackwardsTrackWrap()
  local song = renoise.song()
  local current_index = song.selected_track_index
  local is_effect_column = song.selected_effect_column_index > 0
  
  if current_index > 1 then
    song.selected_track_index = current_index - 1
  else
    song.selected_track_index = #song.tracks
  end
  
  if is_effect_column then
    song.selected_effect_column_index = 1
  else
    song.selected_note_column_index = 1
  end
end

-- Move to the next track, maintaining column type, no wrapping.
function PakettiImpulseTrackerMoveForwardsTrack()
  local song = renoise.song()
  local current_index = song.selected_track_index
  local is_effect_column = song.selected_effect_column_index > 0
  
  if current_index < #song.tracks then
    song.selected_track_index = current_index + 1
  else
    renoise.app():show_status("You are on the last track.")
  end
  
  if is_effect_column then
    song.selected_effect_column_index = 1
  else
    song.selected_note_column_index = 1
  end
end

-- Move to the previous track, maintaining column type, no wrapping.
function PakettiImpulseTrackerMoveBackwardsTrack()
  local song = renoise.song()
  local current_index = song.selected_track_index
  local is_effect_column = song.selected_effect_column_index > 0
  
  if current_index > 1 then
    song.selected_track_index = current_index - 1
  else
    renoise.app():show_status("You are on the first track.")
  end
  
  if is_effect_column then
    song.selected_effect_column_index = 1
  else
    song.selected_note_column_index = 1
  end
end

-- Add keybindings for Pattern Editor
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Alt-Right Move Forwards One Channel (Wrap)", invoke=PakettiImpulseTrackerMoveForwardsTrackWrap}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Alt-Left Move Backwards One Channel (Wrap)", invoke=PakettiImpulseTrackerMoveBackwardsTrackWrap}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Alt-Right Move Forwards One Channel", invoke=PakettiImpulseTrackerMoveForwardsTrack}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Alt-Left Move Backwards One Channel", invoke=PakettiImpulseTrackerMoveBackwardsTrack}

-- Add keybindings for Mixer
renoise.tool():add_keybinding{name="Mixer:Paketti:Impulse Tracker Alt-Right Move Forwards One Channel (Wrap)", invoke=PakettiImpulseTrackerMoveForwardsTrackWrap}
renoise.tool():add_keybinding{name="Mixer:Paketti:Impulse Tracker Alt-Left Move Backwards One Channel (Wrap)", invoke=PakettiImpulseTrackerMoveBackwardsTrackWrap}
renoise.tool():add_keybinding{name="Mixer:Paketti:Impulse Tracker Alt-Right Move Forwards One Channel", invoke=PakettiImpulseTrackerMoveForwardsTrack}
renoise.tool():add_keybinding{name="Mixer:Paketti:Impulse Tracker Alt-Left Move Backwards One Channel", invoke=PakettiImpulseTrackerMoveBackwardsTrack}

-- Add MIDI mappings
renoise.tool():add_midi_mapping{name="Paketti:Move to Next Track (Wrap) [Knob]", invoke=function(message)
  if message:is_abs_value() then
    PakettiImpulseTrackerMoveForwardsTrackWrap()
  end
end}

renoise.tool():add_midi_mapping{name="Paketti:Move to Previous Track (Wrap) [Knob]", invoke=function(message)
  if message:is_abs_value() then
    PakettiImpulseTrackerMoveBackwardsTrackWrap()
  end
end}

renoise.tool():add_midi_mapping{name="Paketti:Move to Next Track [Knob]", invoke=function(message)
  if message:is_abs_value() then
    PakettiImpulseTrackerMoveForwardsTrack()
  end
end}

renoise.tool():add_midi_mapping{name="Paketti:Move to Previous Track [Knob]", invoke=function(message)
  if message:is_abs_value() then
    PakettiImpulseTrackerMoveBackwardsTrack()
  end
end}
