------------------------------------------------------
--[[ Thanks so much to everyone who helped. dBlue, cortex, joule, avaruus, astu/flo, mmd(mr mark dollin) syflom, protman, pandabot, 
Raul (ulneiz), ViZiON, ghostwerk, vV, Bantai, danoise, Snowrobot, mxb, jenoki, kmaki, mantrakid, aleksip, Connor_Bw, Casiino, tkna91, 
James_Britt, Satoi and the whole Renoise community.

Biggest thanks to Brothomstates for suggesting that I could pick up and learn LUA, that it would not be beyond me. Really appreciate you
having faith in me.

Thanks for everything.
]]--
-------------------------------------------------------
require "Paketti0G01_Loader"
require "PakettiAutomation"
require "PakettiControls"
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
------------------------------------------------
-- Autoexec.bat
-- everytime a new Renoise song is created, run this
function startup()  
   local s=renoise.song()
   local t=s.transport
      renoise.app().window:select_preset(1)
      s.sequencer.keep_sequence_sorted=false
      t.groove_enabled=true
    
-- Set playing and set random BPM - but only if filename is "Untitled" aka "" 
-- if renoise.song().file_name == "" then renoise.song().transport.playing=true randobpm()  end
 
-- I disabled all of these notifiers because they messed up with selecting samples in the Mixer
-- if s.selected_sample == nil then s.selected_sample_observable:add_notifier(sample_loaded_change_to_sample_editor)
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
  
--renoise.song().instruments[renoise.song().selected_instrument_index].active_tab=1 --== Sample Editor
--renoise.song().instruments[renoise.song().selected_instrument_index].active_tab=2 --== Plugin
--renoise.song().instruments[renoise.song().selected_instrument_index].active_tab=3 --== Midi
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
then t.follow_player=false
return
else t.edit_mode=true
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
----------------------------------------------------------------------------------------------------------------------------------------
function displayNoteColumn(number) local s=renoise.song() s.tracks[s.selected_track_index].visible_note_columns=number end --here

function pattern_line_notifier(pos) --here
  local colnumber=nil
  local countline=nil
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
