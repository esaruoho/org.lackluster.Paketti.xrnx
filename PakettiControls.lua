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
function RecordToggle()
local t=renoise.song().transport
local w=renoise.app().window
w.active_middle_frame=1

if not t.edit_mode then t.edit_mode=true else t.edit_mode=false end
if not t.follow_player then return else t.follow_player=false end end

renoise.tool():add_keybinding{name="Global:Paketti:Toggle EditMode (2nd)",invoke=function() RecordToggle() end}
renoise.tool():add_keybinding{name="Global:Paketti:Toggle EditMode (3rd)",invoke=function() RecordToggle() end}
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






