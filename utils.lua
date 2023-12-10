function cycle_middle_frame()
  -- dBlue's cycle middle frame -explanation system thing
  -- Populate this table with all the frames you wish to cycle through.
  -- Reference: Renoise.Application.API.lua
  local frames = {  
    -- renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR,
    -- renoise.ApplicationWindow.MIDDLE_FRAME_MIXER,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR,
    renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR,
  }
  -- Get the active frame ID.
  local active_frame = renoise.app().window.active_middle_frame
  
  -- Try to locate the frame ID within our table.
  local index = -1
  for i = 1, #frames do
    if frames[i] == active_frame then
      index = i
      break
    end
  end
  
  -- If the frame ID is in our list, cycle to the next one.
  if index > -1 then
    index = index + 1
    if index > #frames then
      index = 1
    end
  -- Else, default to the first one.
  else
    index = 1
  end
  
  -- Show the frame.
  renoise.app().window.active_middle_frame = frames[index]
end

function cycle_upper_frame()
  -- dBlue's cycle middle frame -explanation system thing
  -- Populate this table with all the frames you wish to cycle through.
  -- Reference: Renoise.Application.API.lua
  local frames = {
    renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES,
    renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM
  }
  -- Get the active frame ID.
  local active_frame = renoise.app().window.active_upper_frame
  
  -- Try to locate the frame ID within our table.
  local index = -1
  for i = 1, #frames do
    if frames[i] == active_frame then
      index = i
      break
    end
  end
  
  -- If the frame ID is in our list, cycle to the next one.
  if index > -1 then
    index = index + 1
    if index > #frames then
      index = 1
    end
  -- Else, default to the first one.
  else
    index = 1
  end
  
  -- Show the frame.
  renoise.app().window.active_upper_frame = frames[index]
end

function cycle_lower_frame()
  -- dBlue's cycle middle frame -explanation system thing
  -- Populate this table with all the frames you wish to cycle through.
  -- Reference: Renoise.Application.API.lua
  local frames = {
    renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS,
    renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
  }
  -- Get the active frame ID.
  local active_frame = renoise.app().window.active_lower_frame
  
  -- Try to locate the frame ID within our table.
  local index = -1
  for i = 1, #frames do
    if frames[i] == active_frame then
      index = i
      break
    end
  end
  
  -- If the frame ID is in our list, cycle to the next one.
  if index > -1 then
    index = index + 1
    if index > #frames then
      index = 1
    end
  -- Else, default to the first one.
  else
    index = 1
  end
  
  -- Show the frame.
  renoise.app().window.active_lower_frame = frames[index]
end

renoise.tool():add_keybinding {name="Global:Paketti:dBlue Cycle Middle Frame", invoke=function() cycle_middle_frame() end}
renoise.tool():add_keybinding {name="Global:Paketti:dBlue Cycle Upper Frame", invoke=function() cycle_upper_frame() end}
renoise.tool():add_keybinding {name="Global:Paketti:dBlue Cycle Lower Frame", invoke=function() cycle_lower_frame() end}
