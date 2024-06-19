-- Shortcuts 2nd / 3rds
-- 
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Keep Sequence Sorted False",invoke=function() renoise.song().sequencer.keep_sequence_sorted=false end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Keep Sequence Sorted True",invoke=function() renoise.song().sequencer.keep_sequence_sorted=true end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Keep Sequence Sorted Toggle",invoke=function() 
if renoise.song().sequencer.keep_sequence_sorted==false then renoise.song().sequencer.keep_sequence_sorted=true else
renoise.song().sequencer.keep_sequence_sorted=false end end}

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
-- Keyboard Octave Up/Down switch
function KeybOctave(amount)
local t = renoise.song().transport
t.octave= (t.octave + amount) % 9
end

renoise.tool():add_keybinding{name="Global:Paketti:KeybOctave Up", invoke=function() KeybOctave(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:KeybOctave Down", invoke=function() KeybOctave(-1) end}
-----
function OctTranspose(UpOrDown)
local note_column = renoise.song().selected_note_column 
note_column.note_value = (note_column.note_value +UpOrDown) % 120
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose Octave Up", invoke=function() OctTranspose(12) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose Octave Down", invoke=function() OctTranspose(-12) end}
---------
function simpleplay()
if renoise.song().transport.playing == true
then renoise.song().transport.playing = false
else renoise.song().transport.playing = true end end

renoise.tool():add_keybinding{name="Global:Paketti:Simple Play",invoke=function() simpleplay() end}
---------
-- Metronome On/Off for keyboard shortcut and midibind.
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

renoise.tool():add_keybinding{name="Global:Paketti:Select Track (Next)", invoke=function() selectNextTrack() end}
renoise.tool():add_keybinding{name="Global:Paketti:Select Track (Previous)", invoke=function() selectPreviousTrack() end}


function createNewTrack()
renoise.song():insert_track_at(renoise.song().selected_track_index)
end
renoise.tool():add_keybinding{name="Global:Paketti:Insert Track (2nd)", invoke=function() createNewTrack() end}


--------
-- Function to clone the currently selected pattern sequence row
function clone_current_sequence()
  -- Access the Renoise song
  local song = renoise.song()
  
  -- Retrieve the currently selected sequence index
  local current_sequence_pos = song.selected_sequence_index
  -- Get the total number of sequences
  local total_sequences = #song.sequencer.pattern_sequence

  -- Debug information
  print("Current Sequence Index:", current_sequence_pos)
  print("Total Sequences:", total_sequences)

  -- Clone the sequence range, appending it right after the current position
  if current_sequence_pos <= total_sequences then
    song.sequencer:clone_range(current_sequence_pos, current_sequence_pos)
    -- Debug information
    print("Cloned Sequence Index:", current_sequence_pos)
    -- Select the newly created sequence
    song.selected_sequence_index = current_sequence_pos + 1
  else
    renoise.app():show_status("Cannot clone the sequence: The current sequence is the last one.")
  end
end

renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Clone Current Sequence",invoke=clone_current_sequence}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Clone Current Sequence",invoke=clone_current_sequence}
renoise.tool():add_keybinding{name="Global:Tools:Clone Current Sequence",invoke=clone_current_sequence}
renoise.tool():add_midi_mapping{name="Global:Tools:Clone Current Sequence",invoke=clone_current_sequence}

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

-- Add keybindings for each tab switch
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (01 Phrases)",invoke=function() sampleEditorTabSwitcher(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (02 Keyzones)",invoke=function() sampleEditorTabSwitcher(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (03 Waveform)",invoke=function() sampleEditorTabSwitcher(3) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (04 Modulation)",invoke=function() sampleEditorTabSwitcher(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (05 Effects)",invoke=function() sampleEditorTabSwitcher(5) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (06 Plugin Editor)",invoke=function() sampleEditorTabSwitcher(6) end}
renoise.tool():add_keybinding{name="Global:Paketti:Sample Editor Tab Switcher (07 Midi Editor)",invoke=function() sampleEditorTabSwitcher(7) end}

-- Add MIDI mapping to cycle through middle frames
renoise.tool():add_midi_mapping{name="Global:Paketti:Cycle Sample Editor Tabs",invoke=function(midiMessage) cycleMiddleFrames(midiMessage.int_value) end}


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

