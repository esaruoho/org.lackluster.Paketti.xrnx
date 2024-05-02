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
