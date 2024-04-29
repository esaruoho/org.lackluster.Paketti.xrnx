------------------------------------------------------
--[[ Thanks so much to everyone who helped. dblue, cortex, joule, avaruus, astu/flo, 
mmd(mr mark dollin) syflom, protman, pandabot, Raul (ulneiz), ViZiON, ghostwerk, vV,
Bantai, danoise, Snowrobot, mxb, jenoki, kmaki, mantrakid, aleksip, Connor_Bw and the whole 
Renoise community.

Biggest thanks to Brothomstates for suggesting that I could pick up and learn LUA, 
that it would not be beyond me. Really appreciate you having faith in me.
]]--
-------------------------------------------------------
require "Paketti0G01_Loader"
require "PakettiExperimental_Verify"
require "PakettiImpulseTracker"
require "PakettiInstrumentBox"
require "PakettiLoaders"
require "PakettiLoadNativeGUI"
require "PakettiMainMenuEntries"
require "PakettiMidi"
require "PakettiPatternEditor"
require "PakettiPatternEditorCheatSheet"
require "PakettiPatternMatrix"
require "PakettiPhraseEditor"
require "PakettiSamples"
require "PakettiRecorder" 
-- These were requested via GitHub / Renoise Forum / Renoise Discord - always get in touch with me (esaruoho@icloud.com)
-- Or post a feature on https://github.com/esaruoho/org.lackluster.Paketti.xrnx/issues/new
require "PakettiRequests"

-- Autoexec.bat
-- everytime a new Renoise song is created, run this
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


if not renoise.tool().app_new_document_observable:has_notifier(startup)   
  then renoise.tool().app_new_document_observable:add_notifier(startup)
  else renoise.tool().app_new_document_observable:remove_notifier(startup) end  
  
--local s=nil  

  
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
function upbyn()
if renoise.song().transport.playing == true then
    if renoise.song().transport.follow_player == false then return end
    upby(4)
    renoise.app().window.active_middle_frame = 1
    renoise.app().window.lock_keyboard_focus = true
    if renoise.song().tracks[renoise.song().selected_track_index].max_note_columns == 0 then return end
    if renoise.song().selected_track.name == "Mst" then return
    else renoise.song().selected_note_column_index = 1 end
end
end


renoise.tool():add_keybinding{name="Global:Paketti:Up By Number", invoke=function() upbyn(1)
end
}

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
-------------
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


-- Metronome On/Off for keyboard shortcut and midibind.
function MetronomeOff()
if renoise.song().transport.metronome_enabled then renoise.song().transport.metronome_enabled = false else renoise.song().transport.metronome_enabled=true end end

renoise.tool():add_keybinding{name="Global:Paketti:Toggle Metronome On/Off",invoke=function() MetronomeOff() end}


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
--------------------------------------------------------------------------------------------------------------------
--Note, does not currently work because Phrase Line Index is not read.
function Phrplusdelay(chg)
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

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +1",invoke=function() Phrplusdelay(1) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -1",invoke=function() Phrplusdelay(-1) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +10",invoke=function() Phrplusdelay(10) end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -10",invoke=function() Phrplusdelay(-10) end}
-----------------------------
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
-----------------------------------------------------------------------------------------------------------
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

