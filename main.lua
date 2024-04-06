require "CheatSheet"
require "impulsetracker"
require "loaders"
require "midi"
require "numpad"
require "recorder" 
require "utils"
require "joule_danoise_better_column_navigation"
require "plugin_gui"
require "pluginfunction"
-- These were requested via GitHub / Renoise Forum / Renoise Discord - always get in touch with me 
require "requests"

-- Autoexec.bat
-- everytime a new Renoise song is created, run this
--
function startup()  
 local s=renoise.song()
 local t=s.transport
 
 renoise.app().window:select_preset(1)
 ---- Example of creating dynamic shortcuts for setting output routing, starting index at 00
--local available_output_routings = renoise.song().tracks[renoise.song().selected_track_index].available_output_routings

 s.sequencer.keep_sequence_sorted=false
 t.groove_enabled=true

-- Set playing and set random BPM - but only if filename is "Untitled" aka "" 
 --if renoise.song().file_name == "" then renoise.song().transport.playing=true randobpm()  end

 
-- I disabled all of these notifiers because they messed up with selecting samples in the Mixer
-- if s.selected_sample == nil then s.selected_sample_observable:add_notifier(sample_loaded_change_to_sample_editor)
-- renoise.app():show_error("hello")
-- else  
 
--if renoise.song().selected_sample_observable:has_notifier(sample_loaded_change_to_sample_editor)  then return 
-- renoise.song().selected_instrument_observable:remove_notifier(sample_loaded_change_to_sample_editor) 
--else renoise.song().selected_sample_observable:add_notifier(sample_loaded_change_to_sample_editor) end

--if renoise.song().selected_sample_observable:has_notifier(sample_loaded_change_to_sample_editor) then
--renoise.song().selected_sample_observable:remove_notifier(sample_loaded_change_to_sample_editor)
--else renoise.song().selected_sample_observable:add_notifier(sample_loaded_change_to_sample_editor) end
-- end
end

-- if s.selected_sample.sample_buffer_observable:has_notifier(sample_loaded_change_to_sample_editor) then   
-- s.selected_sample.sample_buffer_observable:remove_notifier(sample_loaded_change_to_sample_editor)  
-- else  
-- s.selected_sample.sample_buffer_observable:add_notifier(sample_loaded_change_to_sample_editor) return  
-- end  
-- end
--end  

-- Show or hide pattern matrix
function showhidepatternmatrix()
if renoise.app().window.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
then renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR 
renoise.app().window.pattern_matrix_is_visible = true
return
end
if renoise.app().window.pattern_matrix_is_visible == true
then renoise.app().window.pattern_matrix_is_visible = false
else renoise.app().window.pattern_matrix_is_visible = true
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Show/Hide Pattern Matrix",invoke=function() showhidepatternmatrix() end}




function randobpm()
renoise.song().transport.bpm=math.random(60,180)
end 

if not renoise.tool().app_new_document_observable:has_notifier(startup)   
  then renoise.tool().app_new_document_observable:add_notifier(startup)
  else renoise.tool().app_new_document_observable:remove_notifier(startup) end  
  
--local s=nil  


renoise.tool():add_keybinding{name="Global:Paketti:Random BPM (60-180)",invoke=function() randobpm() end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Random BPM (60-180)",invoke=function() randobpm() end}
  
function sample_loaded_change_to_sample_editor()

-- if renoise.app().window.lock_keyboard_focus == true then return end

--disabled these so that i can get renoise to work the same way it should
-- renoise should never change to the sample that was used in the channel you're on.
--if renoise.song().selected_sample == nil then 
--if not renoise.song().selected_sample_observable:has_notifier(sample_loaded_change_to_sample_editor)
--then renoise.song().selected_sample_observable:add_notifier(sample_loaded_change_to_sample_editor)
--else return
-- renoise.song().selected_sample_observable:remove_notifier(sample_loaded_change_to_sample_editor)
--end

--else

 if renoise.app().window.active_middle_frame==1 then 
renoise.song().selected_sample.autofade=true
renoise.song().selected_sample.autoseek=true
renoise.song().selected_sample.interpolation_mode=4
return 
 end

renoise.song().selected_sample.autofade=true
renoise.song().selected_sample.autoseek=true
renoise.song().selected_sample.interpolation_mode=4
renoise.app().window.active_middle_frame=5

--  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].autofade=true
--  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].interpolation_mode=4
-- renoise.app().window.active_middle_frame=5  end  
--end
end
  

--renoise.song().instruments[renoise.song().selected_instrument_index].active_tab=1 == Sampler
--renoise.song().instruments[renoise.song().selected_instrument_index].active_tab=1 == Plugin
--renoise.song().instruments[renoise.song().selected_instrument_index].active_tab=1 == Midi

-- auto-suspend plugin off:
function autosuspendOFF()
--renoise.tool():add_menu_entry
renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.auto_suspend = false end

renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Switch Plugin AutoSuspend Off",invoke=function() autosuspendOFF() end}

function createPhrase()
local s=renoise.song() 
  s.instruments[s.selected_instrument_index]:insert_phrase_at(1) 
  renoise.app().window.active_middle_frame=3
  s.instruments[s.selected_instrument_index].phrase_editor_visible=true
  s.selected_phrase_index=1
  
--  renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index].instrument_column_visible=true
s.instruments[s.selected_instrument_index].phrases[s.selected_phrase_index].volume_column_visible=true
s.instruments[s.selected_instrument_index].phrases[s.selected_phrase_index].panning_column_visible=true
s.instruments[s.selected_instrument_index].phrases[s.selected_phrase_index].delay_column_visible=true
s.instruments[s.selected_instrument_index].phrases[s.selected_phrase_index].sample_effects_column_visible=true
end

renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Create Phrase",invoke=function() createPhrase() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Create Phrase",invoke=function() createPhrase() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Create Phrase",invoke=function() createPhrase() end}


renoise.tool():add_keybinding{name="Global:Paketti:Whats My Song",invoke=function() renoise.app():show_status(renoise.song().file_name) end}

----
function G01()
local s=renoise.song()
  local currTrak=s.selected_track_index
  local currPatt=s.selected_pattern_index
local rightinstrument=nil
local rightinstrument=renoise.song().selected_instrument_index-1
s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"
end

----
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Reset Panning in Current Column",invoke=function()
local s=renoise.song()
local nc=s.selected_note_column
local currTrak=s.selected_track_index
s.selected_track.panning_column_visible=true
nc.panning_value = 0xFF
end}

renoise.tool():add_keybinding{name="Global:Paketti:Global Edit Mode Toggle",invoke=function() 
 if  renoise.song().transport.edit_mode then renoise.song().transport.edit_mode=false
else renoise.song().transport.edit_mode=true end
end}

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Disk Browser Focus",invoke=function()
renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(7) end}

renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Disk Browser Focus",invoke=function()
renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(7) end}

renoise.tool():add_keybinding{name="Global:Paketti:Disk Browser Focus",invoke=function()
renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(8) end}

renoise.tool():add_keybinding{name="Global:Paketti:Disk Browser Focus (2nd)",invoke=function()
renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(8) end}

function voloff()
local s = renoise.song()
local efc = s.selected_effect_column
local currTrak=s.selected_track_index
local currLine=s.selected_line_index
local currPatt=s.selected_pattern_index

local ns=efc.number_string
local as=efc.amount_string

      if s.selected_effect_column=="0000" then
      ns="0L"
      as="00"
      end
end

function write_effect()
  local s = renoise.song()
  local efc = s.selected_effect_column

    if efc==nil then
         s.selected_effect_column.number_string="0L"
         s.selected_effect_column.amount_value=00
      else
      if efc.number_string=="0L" and efc.amount_string=="00" then
         s.selected_effect_column.number_string="0L"
         s.selected_effect_column.amount_string="C0"
      else
         s.selected_effect_column.number_string="0L"
         s.selected_effect_column.amount_value=00
      end
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Volume effect 0L00 On/Off", invoke=function() 
renoise.song().selected_effect_column_index=1
write_effect() 
  if renoise.song().selected_track.name=="Mst" then return
else renoise.song().selected_note_column_index=1 end end} 

function upby(number)
    local result = nil
    local pos = renoise.song().transport.edit_pos
    result = pos.line - number
    if result < 1 then
        result = 1
    else
        print(result)
    end
    pos.line = result
    renoise.song().transport.edit_pos = pos
    renoise.song().transport.playback_pos = pos
end

if renoise.song().transport.playing == true then
    if renoise.song().transport.follow_player == false then return end
    upby(4)
    renoise.app().window.active_middle_frame = 1
    renoise.app().window.lock_keyboard_focus = true
    if renoise.song().tracks[renoise.song().selected_track_index].max_note_columns == 0 then return end
    if renoise.song().selected_track.name == "Mst" then return
    else renoise.song().selected_note_column_index = 1 end
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
         renoise.song().selected_effect_column.amount_value=00 end end end

renoise.tool():add_keybinding{name="Global:Paketti:Retrig 0RLPB On/Off", invoke=function() 
renoise.song().selected_effect_column_index=1
writeretrig() 
  if renoise.song().selected_track.name=="Mst" then return
else renoise.song().selected_note_column_index=1 end end} 






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

renoise.tool():add_keybinding{name="Global:Paketti:Contour Shuttle Disk Browser Focus",invoke=function() renoise.app().window:select_preset(8) end}

-- Keyboard Octave Up/Down switch
function KeybOctave(amount)
local t = renoise.song().transport
t.octave= (t.octave + amount) % 9
end

renoise.tool():add_keybinding{name="Global:Paketti:KeybOctave Up", invoke=function() KeybOctave(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:KeybOctave Down", invoke=function() KeybOctave(-1) end}

function OctTranspose(UpOrDown)
local note_column = renoise.song().selected_note_column 
note_column.note_value = (note_column.note_value +UpOrDown) % 120
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose Octave Up", invoke=function() OctTranspose(12) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Transpose Octave Down", invoke=function() OctTranspose(-12) end}



renoise.tool():add_midi_mapping{name="Pattern Editor:Paketti:Disk Browser Focus",invoke=function()
renoise.app().window:select_preset(8) end}

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Init Phrase Settings",invoke=function()
local selphra=renoise.song().selected_phrase
selphra.visible_note_columns=1
selphra.visible_effect_columns=0
selphra.volume_column_visible=false
selphra.panning_column_visible=false
selphra.delay_column_visible=false
selphra.sample_effects_column_visible=false

local renamephrase_to_index=tostring(renoise.song().selected_phrase_index)
selphra.name=renamephrase_to_index
--selphra.name=renoise.song().selected_phrase_index
end}


-- Show automation (via Pattern Matrix/Pattern Editor)
function showAutomation()
  local w=renoise.app().window
  local raw=renoise.ApplicationWindow
  local wamf = renoise.app().window.active_middle_frame
  if wamf==1 and renoise.app().window.lower_frame_is_visible==false then w.active_lower_frame = raw.LOWER_FRAME_TRACK_AUTOMATION return else end
 
  if (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR) 
  then renoise.app().window.active_middle_frame=1 
  w.active_lower_frame = raw.LOWER_FRAME_TRACK_AUTOMATION
  return else end
if w.active_lower_frame == raw.LOWER_FRAME_TRACK_AUTOMATION 
then w.active_lower_frame = raw.LOWER_FRAME_TRACK_DSPS return end  
    w.active_lower_frame = raw.LOWER_FRAME_TRACK_AUTOMATION
    w.lock_keyboard_focus=true
    renoise.song().transport.follow_player=false end

renoise.tool():add_menu_entry{name="--Pattern Matrix:Paketti..:Switch to Automation",invoke=function() showAutomation() end}
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Switch to Automation",invoke=function() showAutomation() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Switch to Automation",invoke=function() showAutomation() end}
renoise.tool():add_keybinding{name="Pattern Matrix:Paketti:Switch to Automation",invoke=function() showAutomation() end}
renoise.tool():add_keybinding{name="Mixer:Paketti:Switch to Automation",invoke=function() showAutomation() end}


renoise.tool():add_midi_mapping{name="Global:Paketti:Switch to Automation",invoke=function() 
  local w=renoise.app().window
  local raw=renoise.ApplicationWindow
if raw.MIDDLE_FRAME_MIXER == false and w.active_lower_frame == raw.LOWER_FRAME_TRACK_AUTOMATION 
then w.active_middle_frame=raw.MIDDLE_FRAME_MIXER return
else w.active_middle_frame=raw.MIDDLE_FRAME_MIXER end
showAutomation() end}

function DSPFXChain()
--renoise.app().window.active_middle_frame=2
renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS end

renoise.tool():add_keybinding{name="Global:Paketti:DSP FX Chain",invoke=function() DSPFXChain() end}

function midi_imm()
 if renoise.app().window.active_middle_frame==renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR 
 then renoise.app().window.active_middle_frame=1 
 else renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR end
end

renoise.tool():add_keybinding{name="Global:Paketti:F4 Shift Midi Immediately",invoke=function() midi_imm() end}

function simpleplay()
if renoise.song().transport.playing == true
then renoise.song().transport.playing = false
else renoise.song().transport.playing = true end end

renoise.tool():add_keybinding{name="Global:Paketti:Simple Play",invoke=function() simpleplay() end}
renoise.tool():add_midi_mapping  {name="Global:Paketti:Simple Play",invoke=function() simpleplay() end}

function recordfollow()
local w=renoise.app().window
local t=renoise.song().transport
local pe=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
local raw=renoise.ApplicationWindow

if t.playing == false then t.playing = true else end

w.active_middle_frame=raw.MIDDLE_FRAME_PATTERN_EDITOR

if t.edit_mode==false and t.follow_player
then t.edit_mode=true
t.follow_player=false
return
else end

if t.edit_mode and t.follow_player
then
t.follow_player=false
return
else
t.edit_mode=true
t.follow_player=true
w.active_middle_frame=raw.MIDDLE_FRAME_PATTERN_EDITOR
w.lower_frame_is_visible=true
w.upper_frame_is_visible=true
return
end

if t.follow_player then t.follow_player=false t.edit_mode=true
w.active_middle_frame=raw.MIDDLE_FRAME_PATTERN_EDITOR
w.lower_frame_is_visible=true
w.upper_frame_is_visible=true

else
t.follow_player=true
t.edit_mode=true
w.active_middle_frame=raw.MIDDLE_FRAME_PATTERN_EDITOR
w.lower_frame_is_visible=true
w.upper_frame_is_visible=true

end
end

renoise.tool():add_keybinding{name="Global:Paketti:Record Follow",invoke=function() recordfollow() end}



function simpleplayrecordfollow()
local w=renoise.app().window
local t=renoise.song().transport
local pe=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
-- w.upper_frame_is_visible=false
-- w.active_middle_frame=1
-- w.lower_frame_is_visible=true  -- if lower frame is hidden, don't reshow it. 

  if t.playing and t.follow_player and t.edit_mode and w.active_middle_frame==pe
then t.follow_player=false
     t.edit_mode=false return
else t.follow_player=true
     t.edit_mode=true
     w.active_middle_frame=pe end

  if t.playing==true -- if playback is on, continue playback and follow player, toggle edit, display pattern editor
then t.follow_player=true
     t.edit_mode=true
     w.active_middle_frame=pe
else t.playing=true -- if playback is off, start playback and follow player, toggle edit, display pattern editor
     t.follow_player=true
     t.edit_mode=true
     w.active_middle_frame=pe end
end

renoise.tool():add_keybinding{name="Global:Paketti:Simple Play Record Follow",invoke=function() simpleplayrecordfollow() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Simple Play Record Follow",invoke=function() simpleplayrecordfollow() end}
renoise.tool():add_keybinding{name="Global:Paketti:Simple Play Record Follow (2nd)",invoke=function() simpleplayrecordfollow() end}

--2nd Save Song bind
function saveSong()
  renoise.app():save_song()
  renoise.app():show_status("Song saved: " .. "'"..renoise.app().current_song.file_name.."'")
end

renoise.tool():add_keybinding{name="Global:Paketti:Save Song (2nd)",invoke=function() saveSong() end}

function slicerough(changer)
local s=renoise.song()  
  s.selected_sample_index=1
local currInst=s.selected_instrument_index
local currSamp=s.selected_sample_index
local number=(table.count(renoise.song().instruments[currInst].samples[currSamp].slice_markers))
  currSamp=1
  s.instruments[currInst].samples[currSamp].loop_mode=2
  s.instruments[currInst].samples[currSamp].new_note_action=1
  s.instruments[currInst].samples[currSamp].autofade=true
  s.instruments[currInst].samples[currSamp].interpolation_mode=4

for i=1,number do 
s.instruments[currInst].samples[currSamp]:delete_slice_marker((s.instruments[currInst].samples[currSamp].slice_markers[1]))
end
  
local tw=s.selected_sample.sample_buffer.number_of_frames/changer
  s.instruments[currInst].samples[currSamp]:insert_slice_marker(1)
  for i=1,changer do
  s.instruments[currInst].samples[currSamp]:insert_slice_marker(tw*i)
  s.instruments[currInst].samples[currSamp].autofade=true end

s.selected_sample.beat_sync_enabled=true
s.instruments[currInst].samples[currSamp].autofade=true
end
--
--Wipe all slices
function wipeslices()
local currInst=renoise.song().selected_instrument_index
local currSamp=renoise.song().selected_sample_index
local number=(table.count(renoise.song().instruments[currInst].samples[currSamp].slice_markers))

  for i=1,number do renoise.song().instruments[currInst].samples[currSamp]:delete_slice_marker((renoise.song().instruments[currInst].samples[currSamp].slice_markers[1]))
  end
renoise.song().selected_sample.beat_sync_enabled=false
end

renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (16) x[Toggle]",invoke=function() slicerough(16) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Slices",invoke=function() wipeslices() end}

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe Slices",invoke=function() wipeslices() end}

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Sample Preferences - Autofade True, Interpolation 4, Oversample True",invoke=function() 
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].autofade=true
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].interpolation_mode=4
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].oversample_enabled=true

end}
-- Metronome On/Off for keyboard shortcut and midibind.
function MetronomeOff()
if renoise.song().transport.metronome_enabled then renoise.song().transport.metronome_enabled = false else renoise.song().transport.metronome_enabled=true end end

renoise.tool():add_midi_mapping{name="Global:Paketti:Metronome On/Off x[Toggle]",invoke=function() MetronomeOff() end}
renoise.tool():add_keybinding{name="Global:Paketti:Toggle Metronome On/Off",invoke=function() MetronomeOff() end}


function phraseEditorVisible()
  local s=renoise.song()
--If no Phrase in instrument, create phrase, otherwise do nothing.
if s.instruments[s.selected_instrument_index]:can_insert_phrase_at(1) == true then
s.instruments[s.selected_instrument_index]:insert_phrase_at(1) end

--Select created phrase.
s.selected_phrase_index=1

--Check to make sure the Phrase Editor is Visible
if not s.instruments[s.selected_instrument_index].phrase_editor_visible then
renoise.app().window.active_middle_frame =3
s.instruments[s.selected_instrument_index].phrase_editor_visible=true
--If Phrase Editor is already visible, go back to pattern editor.
else s.instruments[s.selected_instrument_index].phrase_editor_visible=false 
renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end end

renoise.tool():add_keybinding{name="Global:Paketti:PhraseEditorVisible",invoke=function() phraseEditorVisible() end}

--[[renoise.tool():add_keybinding{name="Sample Editor:Paketti:PhraseEditorVisible",invoke=function() phraseEditorVisible() end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:PhraseEditorVisible",invoke=function() phraseEditorVisible() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:PhraseEditorVisible",invoke=function() phraseEditorVisible() end}
--]]

--[[
function phraseadd()
renoise.song().instruments[renoise.song().selected_instrument_index]:insert_phrase_at(1)
end

renoise.tool():add_keybinding{name="Global:Paketti:Add new Phrase",invoke=function() 
phraseadd() end}--]]

function oneshotcontinue()
  local s=renoise.song()
  local sli=s.selected_instrument_index
  local ssi=s.selected_sample_index

  if s.instruments[sli].samples[ssi].oneshot
then s.instruments[sli].samples[ssi].oneshot=false
     s.instruments[sli].samples[ssi].new_note_action=1
else s.instruments[sli].samples[ssi].oneshot=true
     s.instruments[sli].samples[ssi].new_note_action=3 end end

renoise.tool():add_keybinding{name="Global:Paketti:Set to One-Shot + NNA Continue",invoke=function() oneshotcontinue() end}

-------------
----------------------------------------------------------------------------------------------------------------------------------------
function displayNoteColumn(number) local s=renoise.song() s.tracks[s.selected_track_index].visible_note_columns=number end --here

function pattern_line_notifier(pos) --here
  local colnumber=nil
  local countline=nil
  local tulos=nil
  local count=nil
--  print (pos.pattern)
--  print (pos.track)
--  print (pos.line)

local s=renoise.song() 
local t=s.transport
if t.edit_step==0 then 
count=s.selected_note_column_index+1

if count == s.tracks[s.selected_track_index].visible_note_columns then s.selected_note_column_index=count return end
if count > s.tracks[s.selected_track_index].visible_note_columns then 
local slicount=nil
slicount=s.selected_line_index+1 
if slicount > s.patterns[s.selected_pattern_index].number_of_lines
then 
s.selected_line_index=s.patterns[s.selected_pattern_index].number_of_lines end
count=1 
s.selected_note_column_index=count return
else s.selected_note_column_index=count return end
end

countline=s.selected_line_index+1---1+renoise.song().transport.edit_step
   if t.edit_step>1 then
   countline=countline-1
   else countline=s.selected_line_index end
   --print ("countline is selected line index +1" .. countline)
   --print ("editstep" .. renoise.song().transport.edit_step)
   if countline > s.patterns[s.selected_pattern_index].number_of_lines
   then countline=1
   end
   s.selected_line_index=countline
 
   colnumber=s.selected_note_column_index+1
   if colnumber > s.tracks[s.selected_track_index].visible_note_columns then
   s.selected_note_column_index=1
   return end
  s.selected_note_column_index=colnumber end
  
function startcolumncycling(number) -- here
local s=renoise.song()
  if s.patterns[s.selected_pattern_index]:has_line_notifier(pattern_line_notifier) 
then s.patterns[s.selected_pattern_index]:remove_line_notifier(pattern_line_notifier)
 renoise.app():show_status(number .. " Column Cycle Keyjazz Off")
else s.patterns[s.selected_pattern_index]:add_line_notifier(pattern_line_notifier)
 renoise.app():show_status(number .. " Column Cycle Keyjazz On") end
end

for cck=1,12 do
renoise.tool():add_keybinding{name="Global:Paketti:Column Cycle Keyjazz " .. cck,invoke=function() displayNoteColumn(cck) startcolumncycling(cck) end}
end

renoise.tool():add_keybinding{name="Global:Paketti:Start/Stop Column Cycling",invoke=function() startcolumncycling() 
  if renoise.song().patterns[renoise.song().selected_pattern_index]:has_line_notifier(pattern_line_notifier)
then renoise.app():show_status("Column Cycle Keyjazz On")
else renoise.app():show_status("Column Cycle Keyjazz Off") end end}

renoise.tool():add_keybinding{name="Global:Paketti:Column Cycle Keyjazz 01_Special",invoke=function() 
displayNoteColumn(12) 
GenerateDelayValue()
renoise.song().transport.edit_mode=true
renoise.song().transport.edit_step=0
renoise.song().selected_note_column_index=1
startcolumncycling(12) end}

--------------------------------------------------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------------------------------------------------
function RecordToggle()
local t=renoise.song().transport
local w=renoise.app().window
w.active_middle_frame=1

if not t.edit_mode then t.edit_mode=true else t.edit_mode=false end
if not t.follow_player then return else t.follow_player=false end end

renoise.tool():add_keybinding{name="Global:Paketti:Toggle EditMode (2nd)",invoke=function() RecordToggle() end}
renoise.tool():add_keybinding{name="Global:Paketti:Toggle EditMode (3rd)",invoke=function() RecordToggle() end}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------------------------------------------------
function RecordFollowOffPattern()
local t=renoise.song().transport
local w = renoise.app().window
--w.active_middle_frame = 1
if t.edit_mode == false then t.edit_mode=true else t.edit_mode=false end
if t.follow_player == false then return else t.follow_player=false end end

function RecordFollowOffPhrase()
local t=renoise.song().transport
t.follow_player=false
if t.edit_mode == false then 
t.edit_mode=true else
t.edit_mode=false end end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Record+Follow Off",invoke=function() RecordFollowOffPattern() end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Record+Follow Off",invoke=function() RecordFollowOffPhrase() end}

--------------------------------------------------------------------------------------------------------------------------------------------------------
function emptyslices()
local si=renoise.song().selected_instrument
local ss=renoise.song().selected_sample
local ssi=renoise.song().selected_sample_index
  ssi=1
   for i=1,64 do si:insert_sample_at(i) end

   for i=1,64 do renoise.song().selected_instrument.samples[i].name="empty_sampleslot" .. i end

 renoise.song().selected_instrument.name=("multiloopersampler_instrument" .. renoise.song().selected_instrument_index)
 w.active_middle_frame= 3 end

renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Create Empty Sample Slices", invoke=function() emptyslices() end}
--------------------------------------------------------------------------------------------------------------------------------------------------------
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
----------------
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

--------------------------------------------------------------------------------------------------------------------------------------------------------
--BPM +1 / -1
function adjust_bpm(bpm_delta)
  local t = renoise.song().transport
  t.bpm = math.max(32, math.min(999, t.bpm + bpm_delta))
renoise.app():show_status("BPM : " .. t.bpm)
end

renoise.tool():add_keybinding{name="Global:Paketti:BPM Decrease (-1)",invoke=function() adjust_bpm(-1, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Increase (+1)",invoke=function() adjust_bpm(1, 0) end}
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
--------------------------------------------------------------------------------------------------------------------------------------------------------
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

--renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Increase Delay +1",invoke=function() delay(1) end}
--renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Decrease Delay -1",invoke=function() delay(-1) end}
--renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Increase Delay +10",invoke=function() delay(10) end}
--renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Decrease Delay -10",invoke=function() delay(-10) end}

--renoise.tool():add_midi_mapping{name="Global:Tools:Delay +1 Increase x[Toggle]",invoke=function() delay(1) end}
--renoise.tool():add_midi_mapping{name="Global:Tools:Delay -1 Increase x[Toggle]",invoke=function() delay(-1) end}

--------------
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
--------------------------------------------------------------------------------------------------------------------------------------------------------
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
local columns = 
    {
      [4] = renoise.song().selected_effect_column.number_value,
      [5] = renoise.song().selected_effect_column.amount_value
    }

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

renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Delay +1 x[Toggle]",invoke=function() columns(1,1) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Delay -1 x[Toggle]",invoke=function() columns(-1,1) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning +1",invoke=function() columns(1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning -1",invoke=function() columns(-1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning +10",invoke=function() columns(10,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning -10",invoke=function() columns(-10,2) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning +1 (2nd)",invoke=function() columns(1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning -1 (2nd)",invoke=function() columns(-1,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Panning +10 (2nd)",invoke=function() columns(10,2) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Panning -10 (2nd)",invoke=function() columns(-10,2) end}

renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Panning +1 x[Toggle]",invoke=function() columns(1,2) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Panning -1 x[Toggle]",invoke=function() columns(-1,2) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Volume +1",invoke=function() columns(1,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Volume -1",invoke=function() columns(-1,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Volume +10",invoke=function() columns(10,3) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Volume -10",invoke=function() columns(-10,3) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Volume +1 x[Toggle]",invoke=function() columns(1,3) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Volume -1 x[Toggle]",invoke=function() columns(-1,3) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Number +1",invoke=function() columns(1,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Number -1",invoke=function() columnspart2(-1,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Number +10",invoke=function() columnspart2(10,4) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Number -10",invoke=function() columnspart2(-10,4) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Effect Number +1 x[Toggle]",invoke=function() columnspart2(1,4) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Effect Number -1 x[Toggle]",invoke=function() columnspart2(-1,4) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Amount +1",invoke=function() columnspart2(1,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Amount -1",invoke=function() columnspart2(-1,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Increase Effect Amount +10",invoke=function() columnspart2(10,5) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Columnizer Decrease Effect Amount -10",invoke=function() columnspart2(-10,5) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Increase Effect Amount +1 x[Toggle]",invoke=function() columnspart2(1,5) end}
renoise.tool():add_midi_mapping{name="Global:Tools:Columnizer Decrease Effect Amount -1 x[Toggle]",invoke=function() columnspart2(-1,5) end}

function switchcasetest(columns)
columns = {}
print(columns)
rprint(columns[1])
oprint(columns)
local solution = nil
solution = ("renoise.song()" .. columns[1])
rprint (solution)
local columns = switch({
[0] = delay_value,
[1] = panning_value,
[2] = volume_value})
rprint (columns[0])
end

----------------------------------------------------------------------------------------------------------------------------------------
-- 2nd Fullscreen toggle
function SecondFullscreen()
local w=renoise.app().window
  if w.fullscreen==true then w.fullscreen=false else w.fullscreen=true end end
renoise.tool():add_keybinding{name="Global:Paketti:Fullscreen (2nd)",invoke=function() SecondFullscreen() end}

------------------------
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

--------------------------------------------------------------------------------------------------------------------
--Note, does not currently work because Phrase Line Index is not read.
function Phraplusdelay(chg)
 local d = renoise.song().selected_note_column.delay_value
 local nc = renoise.song().selected_note_column
 local currTrak = renoise.song().selected_track_index
 local currInst = renoise.song().selected_instrument_index
 local currPhra = renoise.song().selected_phrase_index
 local sli = renoise.song().selected_line_index
 local snci = renoise.song().selected_note_column_index
renoise.song().instruments[currInst].phrases[currPhra].delay_column_visible=true
 local Phrad = renoise.song().selected_instrument:phrase(currPhra):line(sli):note_column(snci).delay_value
 renoise.song().tracks[currTrak].delay_column_visible=true
renoise.song().selected_instrument:phrase(currPhra):line(sli):note_column(snci).delay_value = math.max(0, math.min(255, Phrad + chg))

 --[[nc.delay_value=(d+chg)
 if nc.delay_value == 0 and chg < 0 then
  move_up(chg)
 elseif nc.delay_value == 255 and chg > 0 then
  move_down(chg)
 else
 end--]]
end

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +1",invoke=function() Phraplusdelay(1) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -1",invoke=function() Phraplusdelay(-1) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +10",invoke=function() Phraplusdelay(10) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -10",invoke=function() Phraplusdelay(-10) end}
----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Toggle CapsLock Note Off "===" On / Off.
function CapsLok()
local s=renoise.song()
  local currLine=s.selected_line_index
  local currPatt=s.selected_pattern_index
  local currTrak=s.selected_track_index
  local currPhra=s.selected_phrase_index
  local currInst=s.selected_instrument_index
 
 
 if renoise.app().window.active_middle_frame==1 then
    if s.selected_note_column_index==nil then return 
      else 
        if  renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=="OFF" then 
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=""
       else
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string="OFF"
       end
end
 
else if renoise.app().window.active_middle_frame==3 then

--local phra=renoise.song().instruments[renoise.song().selected_instrument_index].phrases[renoise.song().selected_phrase_index]
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
--------------------------------------------------------------------------------------------------------------------------------------------------------
--Record Quantize On/Off for Midi_Mapping
renoise.tool():add_midi_mapping{
name = "Global:Paketti:Record Quantize On/Off x[Toggle]",
invoke=function()
  if renoise.song().transport.record_quantize_enabled==true then
     renoise.song().transport.record_quantize_enabled=false
  else
     renoise.song().transport.record_quantize_enabled=true
   end
end}


-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

function ptnLength(number) local rs=renoise.song() rs.patterns[rs.selected_pattern_index].number_of_lines=number end
function phraseLength(number) local s=renoise.song() 
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

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 001",invoke=function() phraseLength(1) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 004",invoke=function() phraseLength(4) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 008",invoke=function() phraseLength(8) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 016",invoke=function() phraseLength(16) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 032",invoke=function() phraseLength(32) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 048",invoke=function() phraseLength(48) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 064",invoke=function() phraseLength(64) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 096",invoke=function() phraseLength(96) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 128",invoke=function() phraseLength(128) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 192",invoke=function() phraseLength(192) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 256",invoke=function() phraseLength(256) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 384",invoke=function() phraseLength(384) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Set Phrase Length to 512",invoke=function() phraseLength(512) end}

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

---------------------------------------------------------------------------------------------------------------------------------------------------
function Deselect_All() renoise.song().selection_in_pattern=nil end
function Deselect_Phr() renoise.song().selection_in_phrase =nil end

renoise.tool():add_keybinding{name="Pattern Editor:Selection:Paketti Unmark Selection (ALT-U)",invoke=function() Deselect_All() end}
renoise.tool():add_keybinding{name="Pattern Editor:Selection:Paketti Unmark Selection (CTRL-U) (2nd)",invoke=function() Deselect_All() end}

renoise.tool():add_keybinding{name="Phrase Editor:Selection:Paketti Unmark Selection (ALT-U)",invoke=function() Deselect_Phr() end}
renoise.tool():add_keybinding{name="Phrase Editor:Selection:Paketti Unmark Selection (CTRL-U) (2nd)",invoke=function() Deselect_Phr() end}

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------------------------------------------
function DuplicateInstrumentAndSelectNewInstrument()
local rs=renoise.song()
local i=rs.selected_instrument_index;rs:insert_instrument_at(i+1):copy_from(rs.selected_instrument);rs.selected_instrument_index=i+1
end

renoise.tool():add_keybinding{name="Global:Paketti:DuplicateInstrumentAndSelectNewInstrument",invoke=function() DuplicateInstrumentAndSelectNewInstrument() end}
renoise.tool():add_keybinding{name="Global:Paketti:DuplicateInstrumentAndSelectNewInstrument (2nd)",invoke=function() DuplicateInstrumentAndSelectNewInstrument() end}
renoise.tool():add_keybinding{name="Global:Paketti:DuplicateInstrumentAndSelectNewInstrument (3rd)",invoke=function() DuplicateInstrumentAndSelectNewInstrument() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Duplicate Instrument and Select New Instrument",invoke=function() DuplicateInstrumentAndSelectNewInstrument() end}

--------------------------------------------------------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Hide Track DSP Devices",invoke=function()
  if table.count(renoise.song().selected_track.devices) >1 then
     for i=2,(table.count(renoise.song().selected_track.devices)) do 
      if renoise.song().selected_track.devices[i].external_editor_available==true
       then
       renoise.song().selected_track.devices[i].external_editor_visible=false
      end
     end
  end
end}
---------------------------------------------------------------------------------------


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


-----------------------------------------------------------------
function LoopState(number)
renoise.song().selected_sample.loop_mode=number
end

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 1 Off",invoke=function() LoopState(1) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 2 Forward",invoke=function() LoopState(2) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 3 Reverse",invoke=function() LoopState(3) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 4 PingPong",invoke=function() LoopState(4) end}
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Open Instrument External Editor
function inst_open_editor()
local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
local w=renoise.app().window
    if renoise.song().selected_instrument.plugin_properties.plugin_loaded==false then
    w.pattern_matrix_is_visible = false
    w.sample_record_dialog_is_visible = false
    w.upper_frame_is_visible = true
    w.lower_frame_is_visible = true
    w.active_upper_frame = 1
    w.active_middle_frame= 4
    w.active_lower_frame = 1 -- TrackDSP
    w.lock_keyboard_focus=true
    else
     if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
     end
end

renoise.tool():add_keybinding{name="Global:Paketti:Open External Editor for Plugin",invoke=function() inst_open_editor() end}
renoise.tool():add_keybinding{name="Global:Paketti:Open External Editor for Plugin (2nd)",invoke=function() inst_open_editor() end}
----------------------------------------------------------------------------------------------------------------------------------
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
  renoise.song().tracks[get_master_track_index()].visible_effect_columns = 2  
    
    if renoise.song().selected_effect_column_index <= 1 then column_index = 2 end
    
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].number_string = "ZT"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].amount_value  = t.bpm
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].number_string = "ZL"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].amount_value  = t.lpb
  end
end
-- † --

renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Write Current BPM&LPB to Master column",invoke=function() write_bpm() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Write Current BPM&LPB to Master column",invoke=function() write_bpm() end}


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

renoise.tool():add_keybinding{name="Global:Paketti:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_keybinding{name="Global:Paketti:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100() end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75()  end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}


------------------------------------------------------------------------------------------------------------------------------------
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

function joulepatterndoubler()
 local s=renoise.song()
 local old_patternlength = s.selected_pattern.number_of_lines
 local resultlength = nil

 resultlength = old_patternlength*2

if not (resultlength > 512) then
  s.selected_pattern.number_of_lines = resultlength

  for track_index, patterntrack in ipairs(s.selected_pattern.tracks) do
    if not patterntrack.is_empty then
      for line_index, line in ipairs(patterntrack.lines) do
        if line_index <= old_patternlength then
          if not line.is_empty then
            patterntrack:line(line_index+old_patternlength):copy_from(line)
          else
            patterntrack:line(line_index+old_patternlength):clear()
          end
        end
      end
    end
  end
else
  return
end

--Modification, cursor is placed to "start of "clone""
--renoise.song().selected_line_index = old_patternlength+1
 s.selected_line_index = old_patternlength+s.selected_line_index
-- s.transport.edit_step=0
end

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Joule Pattern Doubler",invoke=function() joulepatterndoubler() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Joule Pattern Doubler",invoke=function() joulepatterndoubler() end}  
renoise.tool():add_keybinding{name="Mixer:Paketti:Joule Pattern Doubler",invoke=function() joulepatterndoubler() end}  

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Joule Pattern Halver",invoke=function() joulepatternhalver() end}  

function joulepatternhalver()
 local s=renoise.song()
 local old_patternlength = s.selected_pattern.number_of_lines
 local resultlength = nil

 resultlength = old_patternlength/2

if not (resultlength < 1) then
  s.selected_pattern.number_of_lines = resultlength

  for track_index, patterntrack in ipairs(s.selected_pattern.tracks) do
    if not patterntrack.is_empty then
      for line_index, line in ipairs(patterntrack.lines) do
        if line_index <= old_patternlength then
          if not line.is_empty then
            patterntrack:line(line_index+old_patternlength):copy_from(line)
          else
            patterntrack:line(line_index+old_patternlength):clear()
          end
        end
      end
    end
  end
else
  return
end

--Modification, cursor is placed to "start of "clone""
--renoise.song().selected_line_index = old_patternlength+1
-- s.selected_line_index = old_patternlength+s.selected_line_index
-- s.transport.edit_step=0
end


-----


function joulephrasedoubler()
  local old_phraselength = renoise.song().selected_phrase.number_of_lines
  local s=renoise.song()
  local resultlength = nil
--Note, when doubling up a 512 pattern, this will shoot a "can't change number_of_lines to 1024" error. fix.
--Note: tried to fix, still shoots 1024 error in Terminal.
  resultlength = old_phraselength*2
if resultlength > 512 then return else s.selected_phrase.number_of_lines=resultlength

if old_phraselength >256 then return else 
for line_index, line in ipairs(s.selected_phrase.lines) do
   if not line.is_empty then
     if line_index <= old_phraselength then
       s.selected_phrase:line(line_index+old_phraselength):copy_from(line)
     end
   end
 end
end
--Modification, cursor is placed to "start of "clone""
--commented away because there is no way to set current_phrase_index.
  -- renoise.song().selected_line_index = old_patternlength+1
  -- renoise.song().selected_line_index = old_phraselength+renoise.song().selected_line_index
  -- renoise.song().transport.edit_step=0
end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Joule Phrase Doubler (2nd)",invoke=function() joulepatterndoubler() end}    
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Joule Phrase Doubler",invoke=function() joulephrasedoubler() end}  
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Joule Phrase Halver",invoke=function() joulephrasehalver() end}  

function joulephrasehalver()
  local old_phraselength = renoise.song().selected_phrase.number_of_lines
  local s=renoise.song()
  local resultlength = nil
--Note, when doubling up a 512 pattern, this will shoot a "can't change number_of_lines to 1024" error. fix.
--Note: tried to fix, still shoots 1024 error in Terminal.
  resultlength = old_phraselength/2
if resultlength > 512 or resultlength < 1 then return else s.selected_phrase.number_of_lines=resultlength

if old_phraselength >256 then return else 
for line_index, line in ipairs(s.selected_phrase.lines) do
   if not line.is_empty then
     if line_index <= old_phraselength then
       s.selected_phrase:line(line_index+old_phraselength):copy_from(line)
     end
   end
 end
end

--Modification, cursor is placed to "start of "clone""
--commented away because there is no way to set current_phrase_index.
  -- renoise.song().selected_line_index = old_patternlength+1
  -- renoise.song().selected_line_index = old_phraselength+renoise.song().selected_line_index
  -- renoise.song().transport.edit_step=0
end
end

------------------------------------------------------------------------------------------------------
--cortex.scripts.CaptureOctave
--[[
program: CaptureOctave v1.1
author: cortex
]]--
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end}
renoise.tool():add_keybinding{name="Mixer:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Capture Nearest Instrument and Octave", invoke=function(repeated) capture_ins_oct() end} 

function capture_ins_oct()
   local closest_note = {}  
   local current_track=renoise.song().selected_track_index
   local current_pattern=renoise.song().selected_pattern_index
   
   for pos,line in renoise.song().pattern_iterator:lines_in_pattern_track(current_pattern,current_track) do
      if (not line.is_empty) then
   local t={}
   if (renoise.song().selected_note_column_index==0) then
      for i=1,renoise.song().tracks[current_track].visible_note_columns do
         table.insert(t,i) end
   else table.insert(t,renoise.song().selected_note_column_index)   end  
   
   for i,v in ipairs(t) do local notecol=line.note_columns[v]
      
      if ( (not notecol.is_empty) and (notecol.note_string~="OFF")) then
         if (closest_note.oct==nil) then
      closest_note.oct=math.min(math.floor(notecol.note_value/12),8)
      closest_note.line=pos.line
      closest_note.ins=notecol.instrument_value+1
         elseif ( math.abs(pos.line-renoise.song().transport.edit_pos.line) < math.abs(closest_note.line-renoise.song().transport.edit_pos.line)  ) then
      closest_note.oct=math.min(math.floor(notecol.note_value/12),8)
      closest_note.line=pos.line
      closest_note.ins=notecol.instrument_value+1
         end         
      end end end end      
   if (closest_note.oct~=nil) then 
      renoise.song().selected_instrument_index=closest_note.ins
      renoise.song().transport.octave=closest_note.oct end
   
local w = renoise.app().window
-- w.lower_frame_is_visible=true
w.active_middle_frame=1
-- w.active_lower_frame=1 
-- w.upper_frame_is_visible=false
end

----------------------------------------------------------------------------------------------------
function markdollins_keyboardvolchange(number)
local s=renoise.song();if s.transport.keyboard_velocity_enabled==false then s.transport.keyboard_velocity_enabled=true end
local addtovelocity=nil
addtovelocity=s.transport.keyboard_velocity+number
if addtovelocity > 127 then addtovelocity=127 end
if addtovelocity < 1 then s.transport.keyboard_velocity_enabled=false return end
s.transport.keyboard_velocity=addtovelocity
end

renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity -1",invoke=function() markdollins_keyboardvolchange(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity +1",invoke=function() markdollins_keyboardvolchange(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity -10",invoke=function() markdollins_keyboardvolchange(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity +10",invoke=function() markdollins_keyboardvolchange(10) end}
-----------------------------------------------------------------------------------------------------------
-- Display user-specific amount of note columns or effect columns:
function displayNoteColumn(number) local rs=renoise.song() if rs.tracks[rs.selected_track_index].visible_note_columns == 0 then return else rs.tracks[rs.selected_track_index].visible_note_columns=number end end

for dnc=1,12 do
  renoise.tool():add_keybinding{name="Global:Paketti:Display Note Column " .. dnc,invoke=function() displayNoteColumn(dnc) end}
end
-----------------------------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------------------------------------
function displayEffectColumn(number) local rs=renoise.song() rs.tracks[rs.selected_track_index].visible_effect_columns=number end

for dec=1,8 do
  renoise.tool():add_keybinding{name="Global:Paketti:Display Effect Column " .. dec,invoke=function() displayEffectColumn(dec) end}
end

--Select specific track:

function select_specific_track(number)
  if number > renoise.song().sequencer_track_count  then 
     number=renoise.song().sequencer_track_count
     renoise.song().selected_track_index=number
  else renoise.song().selected_track_index=number  end
end

for st=1,16 do
  renoise.tool():add_keybinding{
    name = "Global:Paketti:Select Specific Track " .. st, 
    invoke=function() select_specific_track(st) end}
end

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
if s.selected_track.name=="Mst" then 
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
if renoise.song().selected_track.name=="Mst" then return
else renoise.song().selected_note_column_index=nci
--renoise.song().selected_note_column_index=1 
end end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Reverse Sample effect 0B00 on/off (2nd)",invoke=function() 
renoise.song().selected_effect_column_index=1
revnote() 
if renoise.song().selected_track.name=="Mst" then return
else renoise.song().selected_note_column_index=1 end end}


renoise.tool():add_midi_mapping{name="Pattern Editor:Paketti:Reverse Sample effect 0B00 on/off",invoke=function() 
renoise.song().selected_effect_column_index=1
revnote() 
if renoise.song().selected_track.name=="Mst" then return
else renoise.song().selected_note_column_index=1 end end}

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

function OpenSelectedEffectExternalEditor()
local s=renoise.song()
local devices=s.selected_track.devices
if not devices[s.selected_device_index].external_editor_visible then
       devices[s.selected_device_index].external_editor_visible=true
  else devices[s.selected_device_index].external_editor_visible=false
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Open Ext.Editor of Selected Effect",invoke=function() OpenSelectedEffectExternalEditor() end}
-----------------------------------------------------------------------------------------------------------
function inspectPlugin()
local s=renoise.song()
local devices=s.selected_track.devices
for i=1,(table.count(devices[2].parameters)) 
do oprint (devices[2].name .. " " .. i .. " " .. devices[2].parameters[i].name) end end

renoise.tool():add_keybinding{name="Global:Paketti:Inspect Plugin",invoke=function() inspectPlugin() end}

function inspectEffect()
local devices=renoise.song().selected_track.devices
oprint("Effect displayname: " .. devices[2].display_name)
oprint("Effect name: " .. devices[2].name)
oprint("Effect path: " .. devices[2].device_path)
for i=1,(table.count(devices[2].parameters)) 
do oprint (devices[2].name .. " " .. i .. " " .. devices[2].parameters[i].name .. devices[2].parameters[i].value) end
 end

renoise.tool():add_keybinding{name="Global:Paketti:Inspect Effect Slot 2",invoke=function() inspectEffect() end}
------------------------------------------------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------------------------------------------------
-- // TODO: requires fixing (WipeRetain no longer works)
local tmpvariable=nil

function WipeRetain()
tmpvariable=os.tmpname("wav")
local s=renoise.song()

s.instruments[s.selected_instrument_index].samples[1].sample_buffer:save_as(tmpvariable, "wav")

if not renoise.tool().app_new_document_observable:has_notifier(WipeRetainFinish)
  then renoise.tool().app_new_document_observable:add_notifier(WipeRetainFinish)
  else renoise.tool().app_new_document_observable:remove_notifier(WipeRetainFinish) end
renoise.app():new_song()
end

function WipeRetainFinish()
local s=renoise.song()

s.instruments[s.selected_instrument_index].samples[1].sample_buffer:load_from(tmpvariable)
renoise.app().window.active_middle_frame=4
renoise.app():show_status(tmpvariable)
os.remove(tmpvariable)
renoise.tool().app_new_document_observable:remove_notifier(WipeRetainFinish)
end

renoise.tool():add_keybinding{name="Global:Paketti:Wipe Song Retain Sample",invoke=function() WipeRetain() end}
------------------------------------------------------------------------------------------------------------------------------------
function PakettiCapsLockPattern()
  local s=renoise.song()
  local currLine=s.selected_line_index
  local currPatt=s.selected_pattern_index
  local currTrak=s.selected_track_index
  local snci=s.selected_note_column_index
  
  currLine=currLine+2
    s.patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+3].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+5].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+8].note_columns[snci].note_string="OFF"
  currLine=currLine+8
    s.patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+3].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+5].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+8].note_columns[snci].note_string="OFF"
  currLine=currLine+8
    s.patterns[currPatt].tracks[currTrak].lines[currLine].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+3].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+5].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+8].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+11].note_columns[snci].note_string="OFF"
    s.patterns[currPatt].tracks[currTrak].lines[currLine+13].note_columns[snci].note_string="OFF"
  s.transport.edit_step=3
end

renoise.tool():add_keybinding{name="Global:Paketti:CapsLockChassis",invoke=function() PakettiCapsLockPattern() end}

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

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Collapser",invoke=function() Collapser() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Uncollapser",invoke=function() Uncollapser() end}
--Global keyboard shortcuts
renoise.tool():add_keybinding{name="Global:Paketti:Uncollapser",invoke=function() Uncollapser() end}
renoise.tool():add_keybinding{name="Global:Paketti:Collapser",invoke=function() Collapser() end}
--Menu entries for Pattern Editor and Mixer
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Uncollapser",invoke=function() Uncollapser() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Uncollapser",invoke=function() Uncollapser() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Collapser",invoke=function() Collapser() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Collapser",invoke=function() Collapser() end}
--Midi Mapping for Expand/Collapse
renoise.tool():add_midi_mapping{name="Global:Paketti:Uncollapser",invoke=function() Uncollapser() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Collapser",invoke=function() Collapser() end} 
---------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Keep Sequence Sorted False",invoke=function() renoise.song().sequencer.keep_sequence_sorted=false end}

renoise.tool():add_menu_entry{name="Track Automation:Paketti..:Start/Stop Pattern Follow",invoke=function()
local fp=renoise.song().transport.follow_player
if not fp then fp=true else fp=false end end}

renoise.tool():add_menu_entry{name="DSP Device Automation:Follow Off",invoke=function() renoise.song().transport.follow_player=false end}  
---------------------------------------------------------------------------------------------------------
---------------------------------------------------
-- Hiding and showing Disk Browser + Instrument Box
--renoise.app().window.disk_browser_is_visible=false
--renoise.app().window.disk_browser_is_visible=true
--renoise.app().window.instrument_box_is_visible=false
--renoise.app().window.instrument_box_is_visible=true
_AUTO_RELOAD_DEBUG = function() startup()
end

-- Debug print  
function dbug(msg)  
 local base_types = {  
 ["nil"]=true, ["boolean"]=true, ["number"]=true,  
 ["string"]=true, ["thread"]=true, ["table"]=true  
 }  
 if not base_types[type(msg)] then oprint(msg)  
 elseif type(msg) == 'table' then rprint(msg)  
 else print(msg) end  
end  
------------------------------------------------------
--[[ Thanks so much to everyone who helped. dblue, cortex, joule, avaruus, astu/flo, 
mmd(mr mark dollin) syflom, protman, pandabot, Raul (ulneiz), ViZiON, ghostwerk, vV,
Bantai, danoise, Snowrobot, mxb, jenoki, kmaki, mantrakid, aleksip, Connor_Bw and the whole 
Renoise community.

Biggest thanks to Brothomstates for suggesting that I could pick up and learn LUA, 
that it would not be beyond me. Really appreciate you having faith in me.
]]--
-------------------------------------------------------
