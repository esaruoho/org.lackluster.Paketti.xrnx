




function RecordFollowOffPhrase()
local t=renoise.song().transport
t.follow_player=false
if t.edit_mode == false then 
t.edit_mode=true else
t.edit_mode=false end end

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Record+Follow Off",invoke=function() RecordFollowOffPhrase() end}


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
renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Create Phrase",invoke=function() createPhrase() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Create Phrase",invoke=function() createPhrase() end}

--------
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

renoise.tool():add_keybinding{name="Global:Paketti:Phrase Editor Visible",invoke=function() phraseEditorVisible() end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Phrase Editor Visible",invoke=function() phraseEditorVisible() end}
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Phrase Editor Visible",invoke=function() phraseEditorVisible() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Phrase Editor Visible",invoke=function() phraseEditorVisible() end}

function phraseadd()
renoise.song().instruments[renoise.song().selected_instrument_index]:insert_phrase_at(1)
end

renoise.tool():add_keybinding{name="Global:Paketti:Add New Phrase",invoke=function()  phraseadd() end}

----
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

renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Joule Phrase Doubler",invoke=function() joulephrasedoubler() end}  
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Joule Phrase Doubler (2nd)",invoke=function() joulepatterndoubler() end}    


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




renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Joule Phrase Halver",invoke=function() joulephrasehalver() end}  
renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Joule Phrase Halver (2nd)",invoke=function() joulephrasehalver() end}  

