-- Shortcuts 2nd / 3rds
--2nd Save Song bind
function saveSong()
  renoise.app():save_song()
  renoise.app():show_status("Song saved: " .. "'"..renoise.app().current_song.file_name.."'")
end

renoise.tool():add_keybinding{name="Global:Paketti:Save Song (2nd)",invoke=function() saveSong() end}

function RecordFollowToggle()
local s=renoise.song()
local t=s.transport
local w=renoise.app().window
w.active_middle_frame=1
if t.edit_mode == true and t.follow_player == true then t.edit_mode=false t.follow_player=false return end
if t.edit_mode == false and t.follow_player == false then t.edit_mode=true t.follow_player=true return else t.edit_mode=false t.follow_player=false end

if t.follow_player == false and t.edit_mode == false then t.follow_player=true t.edit_mode=true else t.follow_player=false t.edit_mode=false end
w.active_middle_frame=1
end

renoise.tool():add_keybinding{name="Global:Paketti:Record+Follow Toggle (2nd)",invoke=function() RecordFollowToggle() end}
renoise.tool():add_keybinding{name="Global:Paketti:Record+Follow Toggle (3rd)",invoke=function() RecordFollowToggle() end}
renoise.tool():add_keybinding{name="Global:Paketti:Record+Follow Toggle (4th)",invoke=function() RecordFollowToggle() end}
--------------------------------------------------------------------------------------------------------------------------------------------------------
--esa- 2nd keybind for Record Toggle ON/OFF with effect_column reading
previous_edit_step = nil

function RecordToggleg()
  local s = renoise.song()
  local t = s.transport

  -- Output the current edit_step
  print("Current edit_step: " .. t.edit_step)

  -- Toggle edit mode
  t.edit_mode = not t.edit_mode

  if t.edit_mode then
    -- If turning edit_mode on
    if s.selected_effect_column_index and s.selected_effect_column_index > 0 then
      -- Store current edit_step before changing it to 0
      previous_edit_step = t.edit_step
      print("Stored previous_edit_step: " .. previous_edit_step)
      t.edit_step = 0
    else
      -- If no effect column is selected, do nothing with edit_step
      print("No effect column selected")
    end
  else
    -- If turning edit_mode off
    if s.selected_effect_column_index and s.selected_effect_column_index > 0 then
      -- Restore previous edit_step if it was saved
      if previous_edit_step then
        t.edit_step = previous_edit_step
        print("Restored edit_step to: " .. t.edit_step)
        previous_edit_step = nil
      else
        print("No previous_edit_step saved")
      end
    else
      -- If no effect column is selected and we are in note column
      if not s.selected_effect_column_index or s.selected_effect_column_index == 0 then
        -- Restore previous edit_step if edit_step is 0 and previous_edit_step is not 0
        if t.edit_step == 0 and previous_edit_step and previous_edit_step ~= 0 then
          t.edit_step = previous_edit_step
          print("Restored edit_step to: " .. t.edit_step)
          previous_edit_step = nil
        end
      else
        print("No effect column selected and not in note column")
      end
    end
  end

 -- -- Toggle follow_player mode
--  t.follow_player = not t.follow_player
end

renoise.tool():add_keybinding{name="Global:Paketti:Toggle EditMode (2nd)",invoke=function() RecordToggleg() end}
renoise.tool():add_keybinding{name="Global:Paketti:Toggle EditMode (3rd)",invoke=function() RecordToggleg() end}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RecordFollowMetronomeToggle()
local w=renoise.app().window
local t=renoise.song().transport
w.active_middle_frame=1
w.lock_keyboard_focus=true

if t.edit_mode==false and t.follow_player==false and t.metronome_enabled==false then
   t.edit_mode=true
   t.follow_player=true
   t.metronome_enabled=true else
   t.edit_mode=false
   t.follow_player=false
   t.metronome_enabled=false end
if t.playing==false then t.playing=true t.metronome_enabled=true t.follow_player=true t.edit_mode=true end
end

renoise.tool():add_keybinding{name="Global:Paketti:Record+Follow+Metronome Toggle",invoke=function() RecordFollowMetronomeToggle() end}
--------------------------------------------------------------------------------------------------------------------------------------------------------
function FollowPatternToggle()
local a=renoise.app()
local t=renoise.song().transport
local w=renoise.app().window
local pe=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR 
  if t.follow_player==true and w.active_middle_frame==pe
then t.follow_player=false
else t.follow_player = true
     w.active_middle_frame=pe end end

renoise.tool():add_keybinding{name="Global:Paketti:Toggle Follow Pattern (2nd)",invoke=function() FollowPatternToggle() end}

-- 2nd Fullscreen toggle
function SecondFullscreen()
local w=renoise.app().window
  if w.fullscreen==true then w.fullscreen=false else w.fullscreen=true end end
renoise.tool():add_keybinding{name="Global:Paketti:Fullscreen (2nd)",invoke=function() SecondFullscreen() end}
------
renoise.tool():add_menu_entry{name="Track Automation:Paketti..:Start/Stop Pattern Follow",invoke=function()
local fp=renoise.song().transport.follow_player
if not fp then fp=true else fp=false end end}

renoise.tool():add_menu_entry{name="DSP Device Automation:Follow Off",invoke=function() renoise.song().transport.follow_player=false end}  
-------
function KeybOctave(amount)
local t = renoise.song().transport
t.octave= (t.octave + amount) % 9
end

renoise.tool():add_keybinding{name="Global:Paketti:KeybOctave Up", invoke=function() KeybOctave(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:KeybOctave Down", invoke=function() KeybOctave(-1) end}
-----
function PakettiTranspose(steps)
  local song = renoise.song()
  local selection = song.selection_in_pattern
  local pattern = song.selected_pattern

  local start_track, end_track, start_line, end_line, start_column, end_column

  if selection ~= nil then
    start_track = selection.start_track
    end_track = selection.end_track
    start_line = selection.start_line
    end_line = selection.end_line
    start_column = selection.start_column
    end_column = selection.end_column
  else
    start_track = song.selected_track_index
    end_track = song.selected_track_index
    start_line = 1
    end_line = pattern.number_of_lines
    start_column = 1
    end_column = song.tracks[start_track].visible_note_columns
  end

  local is_valid_track = false
  for track_index = start_track, end_track do
    local track = song:track(track_index)
    if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
      is_valid_track = true
      break
    end
  end

  if not is_valid_track then
    renoise.app():show_status("The selected track is a Group / Master or Send, and doesn't have Note Columns. Doing nothing.")
    return
  end

  for track_index = start_track, end_track do
    local track = song:track(track_index)

    if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
      local track_pattern = pattern:track(track_index)

      for line_index = start_line, end_line do
        local line = track_pattern:line(line_index)

        for column_index = start_column, end_column do
          local note_column = line:note_column(column_index)
          if not note_column.is_empty then

            if note_column.note_value < 120 then
              note_column.note_value = (note_column.note_value + steps) % 120
            end
          end
        end
      end
    end
  end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose Octave Up (Selection/Track)",invoke=function() PakettiTranspose(12) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose Octave Down (Selection/Track)",invoke=function() PakettiTranspose(-12) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose +1 (Selection/Track)",invoke=function() PakettiTranspose(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose -1 (Selection/Track)",invoke=function() PakettiTranspose(-1) end}
--------------
function PakettiTransposeNoteColumn(steps)
  local song = renoise.song()
  local selection = song.selection_in_pattern
  local pattern = song.selected_pattern

  local start_track, end_track, start_line, end_line, start_column, end_column

  if selection ~= nil then
    start_track = selection.start_track
    end_track = selection.end_track
    start_line = selection.start_line
    end_line = selection.end_line
    start_column = selection.start_column
    end_column = selection.end_column
  else
    start_track = song.selected_track_index
    end_track = song.selected_track_index
    start_line = 1
    end_line = pattern.number_of_lines
    start_column = song.selected_note_column_index
    end_column = song.selected_note_column_index
  end

  for track_index = start_track, end_track do
    local track = song:track(track_index)
    local track_pattern = pattern:track(track_index)

    local first_column = (track_index == start_track) and start_column or 1
    local last_column = (track_index == end_track) and end_column or track.visible_note_columns

    for line_index = start_line, end_line do
      local line = track_pattern:line(line_index)

      for column_index = first_column, last_column do
        local note_column = line:note_column(column_index)
        if not note_column.is_empty then
          if note_column.note_value < 120 then
            note_column.note_value = (note_column.note_value + steps) % 120
          end
        end
      end
    end
  end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose Octave Up Note Column (Selection/Note Column)",invoke=function() PakettiTransposeNoteColumn(12) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose Octave Down Note Column (Selection/Note Column)",invoke=function() PakettiTransposeNoteColumn(-12) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose +1 Note Column (Selection/Note Column)",invoke=function() PakettiTransposeNoteColumn(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose -1 Note Column (Selection/Note Column)",invoke=function() PakettiTransposeNoteColumn(-1) end}

---------
function simpleplay()
if renoise.song().transport.playing 
then renoise.song().transport.playing=false
else renoise.song().transport.playing=true end end

renoise.tool():add_keybinding{name="Global:Paketti:Simple Play",invoke=function() simpleplay() end}
---------
function MetronomeOff()
if renoise.song().transport.metronome_enabled then renoise.song().transport.metronome_enabled = false else renoise.song().transport.metronome_enabled=true end end

renoise.tool():add_keybinding{name="Global:Paketti:Toggle Metronome On/Off",invoke=function() MetronomeOff() end}
---------
renoise.tool():add_keybinding{name="Global:Paketti:Song Details (Filename, BPM, LPB)",invoke=function() 
local filename = nil
if renoise.song().file_name == ("") then filename = "(Not Yet Saved)" 
else filename = renoise.song().file_name
end
renoise.app():show_status("File: " .. filename .. ", BPM: " .. renoise.song().transport.bpm .. ", LPB: " .. renoise.song().transport.lpb) end}
-------------
-- RecordFollowOn / Off / ContourShuttle
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

renoise.tool():add_keybinding{name="Global:Paketti:Contour Shuttle Record Off", invoke=function() recOffFollowOn() end}
renoise.tool():add_keybinding{name="Global:Paketti:Contour Shuttle Record On", invoke=function() recOnFollowOff() end}
-------
renoise.tool():add_keybinding{name="Global:Paketti:Global Edit Mode Toggle",invoke=function() 
 if  renoise.song().transport.edit_mode then renoise.song().transport.edit_mode=false
else renoise.song().transport.edit_mode=true end
end}
---------------
function upby(number)
    local result = nil
    local pos = renoise.song().transport.edit_pos
    result = pos.line - number
    if result < 1 then
        result = 1
    else
        -- print(result)
    end
    pos.line = result
    renoise.song().transport.edit_pos = pos
    renoise.song().transport.playback_pos = pos
end
function upbyn(number)
if renoise.song().transport.playing == true then
    if renoise.song().transport.follow_player == false then return end
    upby(number)
    renoise.app().window.active_middle_frame = 1
    renoise.app().window.lock_keyboard_focus = true
    if renoise.song().tracks[renoise.song().selected_track_index].max_note_columns == 0 then return end
    if renoise.song().selected_track.type==2 or renoise.song().selected_track.type==3 or renoise.song().selected_track.type==4 then return
    else renoise.song().selected_note_column_index = 1 end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Rewind Playback by 4 steps", invoke=function() upbyn(4) end}
---------
function midi_imm()
 if renoise.app().window.active_middle_frame==renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR 
 then renoise.app().window.active_middle_frame=1 
 else renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR end
end

renoise.tool():add_keybinding{name="Global:Paketti:Pattern Editor <-> Midi Editor Switcher",invoke=function() midi_imm() end}
-----------
function selectNextTrack()
local nextTrack= renoise.song().selected_track_index+1
if nextTrack > #renoise.song().tracks then
nextTrack=1 else end
renoise.song().selected_track_index=nextTrack
end

function selectPreviousTrack()
local previousTrack= renoise.song().selected_track_index-1
if previousTrack < 1
then previousTrack=#renoise.song().tracks 
renoise.song().selected_track_index=previousTrack return else

if previousTrack > #renoise.song().tracks then
previousTrack=1 else end
end
renoise.song().selected_track_index=previousTrack
end

renoise.tool():add_keybinding{name="Global:Paketti:Select Track (Next)",invoke=function() selectNextTrack() end}
renoise.tool():add_keybinding{name="Global:Paketti:Select Track (Previous)",invoke=function() selectPreviousTrack() end}


function createNewTrack()
renoise.song():insert_track_at(renoise.song().selected_track_index)
end
renoise.tool():add_keybinding{name="Global:Paketti:Insert Track (2nd)", invoke=function() createNewTrack() end}

---------
-- Define a table with the middle frame constants
local middle_frames = {
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR
}

-- Function to switch the middle frame based on the tab number
function sampleEditorTabSwitcher(tabNumber)
  if tabNumber >= 1 and tabNumber <= #middle_frames then
    renoise.app().window.active_middle_frame = middle_frames[tabNumber]
  else
    renoise.app():show_status("Invalid tab number: " .. tostring(tabNumber))
  end
end

-- Function to cycle through middle frames based on MIDI input value (0-127)
function cycleMiddleFrames(midiValue)
  local index = math.floor(midiValue / 127 * (#middle_frames - 1)) + 1
  renoise.app().window.active_middle_frame = middle_frames[index]
end

renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (01 Phrases)",invoke=function() sampleEditorTabSwitcher(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (02 Keyzones)",invoke=function() sampleEditorTabSwitcher(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (03 Waveform)",invoke=function() sampleEditorTabSwitcher(3) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (04 Modulation)",invoke=function() sampleEditorTabSwitcher(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (05 Effects)",invoke=function() sampleEditorTabSwitcher(5) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (06 Plugin Editor)",invoke=function() sampleEditorTabSwitcher(6) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (07 Midi Editor)",invoke=function() sampleEditorTabSwitcher(7) end}
renoise.tool():add_midi_mapping{name="Paketti:Cycle Sample Editor Tabs x[Knob]",invoke=function(midiMessage) cycleMiddleFrames(midiMessage.int_value) end}

----------
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

renoise.tool():add_keybinding{name="Global:Paketti:Select LoopBlock Backwards (Previous)", invoke=function() loopblockback() end}
renoise.tool():add_keybinding{name="Global:Paketti:Select LoopBlock Forwards (Next)", invoke=function() loopblockforward() end}
--------
---------

local function PakettiSetEditStep(value)
  renoise.song().transport.edit_step=value
--  renoise.app():show_status("Edit Step set to " .. tostring(value))
end

-- Keybinding definitions from 00 to 64
for i=0,64 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set EditStep to " .. formatDigits(2,i),
    invoke=function() PakettiSetEditStep(i) end}
end

----
--esa- 2nd keybind for Record Toggle ON/OFF with effect_column reading
function RecordToggle()
 local a=renoise.app()
 local s=renoise.song()
 local t=s.transport
 local currentstep=t.edit_step
--if has notifier, dump notifier, if no notifier, add notifier
 if t.edit_mode then
    t.edit_mode=false
 if t.edit_step==0 then
    t.edit_step=1
 else
  return
 end 
 else
      t.edit_mode = true
   if s.selected_effect_column_index == 1 then t.edit_step=0
   elseif s.selected_effect_column_index == 0 then t.edit_step=currentstep return
   end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Record Toggle with EditStep Reading (2nd)", invoke=function() RecordToggle() end}




---------
function loadRecentlySavedSong()
renoise.app():load_song(renoise.app().recently_saved_song_files[1])
end

renoise.tool():add_keybinding{name="Global:Paketti:Load Recently Saved Song",invoke=function() loadRecentlySavedSong() end}
renoise.tool():add_menu_entry{name="Main Menu:File:Paketti..:Load Recently Saved Song",invoke=function() loadRecentlySavedSong() end}



