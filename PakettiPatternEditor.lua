























function pakettiPatternDoubler()
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local old_patternlength = song.selected_pattern.number_of_lines
  local new_patternlength = old_patternlength * 2

  if new_patternlength <= 512 then
    song.selected_pattern.number_of_lines = new_patternlength

    -- Loop through each track in the selected pattern
    for track_index, pattern_track in ipairs(song.selected_pattern.tracks) do
      if not pattern_track.is_empty then
        -- Copy notes in the pattern
        for line_index = 1, old_patternlength do
          local line = pattern_track:line(line_index)
          local new_line = pattern_track:line(line_index + old_patternlength)
          if not line.is_empty then
            new_line:copy_from(line)
          else
            new_line:clear()
          end
        end
      end

      -- Handle automation duplication with detailed debug output
      local track_automations = song.patterns[pattern_index].tracks[track_index].automation
      if next(track_automations) ~= nil then -- Check if there's any automation
        for param, automation in pairs(track_automations) do
          print("Processing automation for parameter:", param)
          local points = automation.points
          for i, point in ipairs(points) do
            local new_time = point.time + old_patternlength
            if new_time <= new_patternlength then
              automation:add_point_at(new_time, point.value)
              print("Duplicating point:", point.time, point.value, "to", new_time)
            end
          end
        end
      else
        print("No automation found in track", track_index)
      end
    end

    song.selected_line_index = old_patternlength + 1
    print("Pattern doubled successfully.")
  else
    print("New pattern length exceeds 512 lines, operation cancelled.")
  end
end

function pakettiPatternHalver()
  local s = renoise.song()
  local old_patternlength = s.selected_pattern.number_of_lines
  local resultlength = math.floor(old_patternlength / 2)

  -- Check if the result length is less than 1, which would be invalid
  if resultlength < 1 then
    print("Resulting pattern length is too small, operation cancelled.")
    return
  end

  -- Set the new pattern length
  s.selected_pattern.number_of_lines = resultlength

  -- Adjust automation for each track
  for track_index, track in ipairs(s.selected_pattern.tracks) do
    local track_automations = s.patterns[s.selected_pattern_index].tracks[track_index].automation
    for _, automation in pairs(track_automations) do
      local points = automation.points
      local new_points = {}

      -- Collect new points, scaling down the time values
      for _, point in ipairs(points) do
        local new_time = math.floor((point.time / old_patternlength) * resultlength)
        if new_time >= 1 and new_time <= resultlength then
          table.insert(new_points, {time = new_time, value = point.value})
        end
      end

      -- Clear existing points and add scaled points
      automation:clear_points()
      for _, point in ipairs(new_points) do
        automation:add_point_at(point.time, point.value)
      end
    end
  end
end

-- The function can be bound to a menu item or a keybinding within Renoise to make it easily accessible
renoise.tool():add_menu_entry{
    name = "Main Menu:Tools:Paketti..:Paketti Pattern Halver",
    invoke = pakettiPatternHalver
}

renoise.tool():add_keybinding{
    name = "Pattern Editor:Paketti:Paketti Pattern Halver",
    invoke = pakettiPatternHalver
}

renoise.tool():add_keybinding{
    name = "Mixer:Paketti:Paketti Pattern Halver",
    invoke = pakettiPatternHalver
}


-- Add menu entries and keybindings for the tool
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}
renoise.tool():add_keybinding{name="Mixer:Paketti:Paketti Pattern Doubler", invoke=pakettiPatternDoubler}



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

renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Write Current BPM&LPB to Master column",invoke=function() write_bpm() end}

function randombpm()
local prefix=nil
local randombpm = {80, 100, 115, 123, 128, 132, 135, 138, 160}
 math.randomseed(os.time())
  for i = 1, 9 do
      prefix = math.random(1, #randombpm)
      prefix = randombpm[prefix]
      print(prefix)
  end
 renoise.song().transport.bpm=prefix
    if renoise.tool().preferences.RandomBPM.value then
        write_bpm()
    end
end

renoise.tool():add_keybinding{
    name = "Pattern Editor:Paketti..:Renoise Random BPM & Write BPM/LPB to Master",
    invoke = function()
        local randombpm = {80, 100, 115, 123, 128, 132, 135, 138, 160}
        math.randomseed(os.time())
        local prefix = randombpm[math.random(#randombpm)]
        renoise.song().transport.bpm = prefix

        if renoise.tool().preferences.RandomBPM.value then 
      
            write_bpm()
        end
    end
}




function playat75()
 renoise.song().transport.bpm=renoise.song().transport.bpm*0.75
 write_bpm()
 renoise.app():show_status("BPM set to 75% (" .. renoise.song().transport.bpm .. "BPM)") 
end

function returnbackto100()
 renoise.song().transport.bpm=renoise.song().transport.bpm/0.75
 write_bpm()
 renoise.app():show_status("BPM set back to 100% (" .. renoise.song().transport.bpm .. "BPM)") 
end

renoise.tool():add_keybinding{name="Global:Paketti:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_keybinding{name="Global:Paketti:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75()  end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}




-- This Requires Preferences so that you can define minBPM maxBPM and also whether it imprints the BPM LPB to the Master
renoise.tool():add_keybinding{name="Global:Paketti:Random BPM (60-180)",invoke=function()
renoise.song().transport.bpm=math.random(60,180) end}




-- originally created by joule + danoise
-- http://forum.renoise.com/index.php/topic/47664-new-tool-31-better-column-navigation/
-- ripped into Paketti without their permission. tough cheese.
local cached_note_column_index = nil
local cached_effect_column_index = nil
 
function toggle_column_type()
  local ss = renoise.song()
  if s.selected_track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
    if s.selected_note_column_index ~= 0 then
      local col_idx = (cached_effect_column_index ~= 0) and 
        cached_effect_column_index or 1
      if (col_idx <= s.selected_track.visible_effect_columns) then
        s.selected_effect_column_index = col_idx
      elseif (s.selected_track.visible_effect_columns > 0) then
        s.selected_effect_column_index = s.selected_track.visible_effect_columns
      else
        -- no effect columns available
      end
    else
      local col_idx = (cached_note_column_index ~= 0) and 
        cached_note_column_index or 1
      if (col_idx <= s.selected_track.visible_note_columns) then
        s.selected_note_column_index = col_idx
      else -- always one note column
        s.selected_note_column_index = s.selected_track.visible_note_columns
      end end end end
 
function cache_columns()
  -- access song only once renoise is ready
  if not pcall(renoise.song) then return end
  local s = renoise.song()
  if (s.selected_note_column_index > 0) then
    cached_note_column_index = s.selected_note_column_index
  end
  if (s.selected_effect_column_index > 0) then
    cached_effect_column_index = s.selected_effect_column_index end end

function cycle_column(direction)
local s = renoise.song()
 if direction == "next" then

  if (s.selected_note_column_index > 0) and (s.selected_note_column_index < s.selected_track.visible_note_columns) then -- any note column but not the last
   s.selected_note_column_index = s.selected_note_column_index + 1
  elseif (s.selected_track.visible_note_columns > 0) and (s.selected_note_column_index == s.selected_track.visible_note_columns) and (s.selected_track.visible_effect_columns > 0) then -- last note column when effect columns are available
   s.selected_effect_column_index = 1
  elseif (s.selected_effect_column_index < s.selected_track.visible_effect_columns) then -- any effect column but not the last
   s.selected_effect_column_index = s.selected_effect_column_index + 1
  elseif (s.selected_effect_column_index == s.selected_track.visible_effect_columns) and (s.selected_track_index < #s.tracks) then -- last effect column but not the last track
   s.selected_track_index = s.selected_track_index + 1
  else -- last column in last track
   s.selected_track_index = 1 end

 elseif direction == "prev" then
  if (s.selected_note_column_index > 0) and (s.selected_sub_column_type > 2 and s.selected_sub_column_type < 8) then -- any sample effects column
   s.selected_note_column_index = s.selected_note_column_index
  elseif (s.selected_note_column_index > 1) then -- any note column but not the first
   s.selected_note_column_index = s.selected_note_column_index - 1
  elseif (s.selected_effect_column_index > 1) then -- any effect column but not the first
   s.selected_effect_column_index = s.selected_effect_column_index - 1
  elseif (s.selected_effect_column_index == 1) and (s.selected_track.visible_note_columns > 0) then -- first effect column and note columns exist
   s.selected_note_column_index = s.selected_track.visible_note_columns
  elseif (s.selected_effect_column_index == 1) and (s.selected_track.visible_note_columns == 0) then -- first effect column and note columns do not exist (group/send/master)
   s.selected_track_index = s.selected_track_index - 1
   if s.selected_track.visible_effect_columns > 0 then s.selected_effect_column_index = s.selected_track.visible_effect_columns
   else s.selected_note_column_index = s.selected_track.visible_note_columns
   end
  elseif (s.selected_note_column_index == 1) and (s.selected_track_index == 1) then -- first note column in first track
  local rns=renoise.song()
   s.selected_track_index = #rns.tracks
   s.selected_effect_column_index = s.selected_track.visible_effect_columns
  elseif (s.selected_note_column_index == 1) then -- first note column
   s.selected_track_index = s.selected_track_index - 1
   if s.selected_track.visible_effect_columns > 0 then s.selected_effect_column_index = s.selected_track.visible_effect_columns
   else s.selected_note_column_index = s.selected_track.visible_note_columns
   end end end end
 
renoise.tool():add_keybinding{name="Pattern Editor:Navigation:Paketti Joule Toggle between note/fx columns",invoke=toggle_column_type}
renoise.tool():add_keybinding{name="Pattern Editor:Navigation:Paketti Joule Jump to next column (note/fx)",invoke=function() cycle_column("next") end}
renoise.tool():add_keybinding{name="Pattern Editor:Navigation:Paketti Joule Jump to previous column (note/fx)",invoke=function() cycle_column("prev") end}
renoise.tool().app_idle_observable:add_notifier(cache_columns)


