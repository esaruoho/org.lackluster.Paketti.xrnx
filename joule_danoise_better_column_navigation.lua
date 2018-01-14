-- originally created by joule + danoise
-- http://forum.renoise.com/index.php/topic/47664-new-tool-31-better-column-navigation/
-- ripped into Paketti without their permission. tough cheese.

local cached_note_column_index = nil
local cached_effect_column_index = nil
 
function toggle_column_type()
  local rns = renoise.song()
  if rns.selected_track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
    if rns.selected_note_column_index ~= 0 then
      local col_idx = (cached_effect_column_index ~= 0) and 
        cached_effect_column_index or 1
      if (col_idx <= rns.selected_track.visible_effect_columns) then
        rns.selected_effect_column_index = col_idx
      elseif (rns.selected_track.visible_effect_columns > 0) then
        rns.selected_effect_column_index = rns.selected_track.visible_effect_columns
      else
        -- no effect columns available
      end
    else
      local col_idx = (cached_note_column_index ~= 0) and 
        cached_note_column_index or 1
      if (col_idx <= rns.selected_track.visible_note_columns) then
        rns.selected_note_column_index = col_idx
      else -- always one note column
        rns.selected_note_column_index = rns.selected_track.visible_note_columns
      end
 
    end
  end
end
 
function cache_columns()
  -- access song only once renoise is ready
  if not pcall(renoise.song) then return end
  local rns = renoise.song()
  if (rns.selected_note_column_index > 0) then
    cached_note_column_index = rns.selected_note_column_index
  end
  if (rns.selected_effect_column_index > 0) then
    cached_effect_column_index = rns.selected_effect_column_index
  end
end


function cycle_column(direction)

local rns = renoise.song()

 if direction == "next" then

  if (rns.selected_note_column_index > 0) and (rns.selected_note_column_index < rns.selected_track.visible_note_columns) then -- any note column but not the last
   rns.selected_note_column_index = rns.selected_note_column_index + 1
  elseif (rns.selected_track.visible_note_columns > 0) and (rns.selected_note_column_index == rns.selected_track.visible_note_columns) and (rns.selected_track.visible_effect_columns > 0) then -- last note column when effect columns are available
   rns.selected_effect_column_index = 1
  elseif (rns.selected_effect_column_index < rns.selected_track.visible_effect_columns) then -- any effect column but not the last
   rns.selected_effect_column_index = rns.selected_effect_column_index + 1
  elseif (rns.selected_effect_column_index == rns.selected_track.visible_effect_columns) and (rns.selected_track_index < #rns.tracks) then -- last effect column but not the last track
   rns.selected_track_index = rns.selected_track_index + 1
  else -- last column in last track
   rns.selected_track_index = 1
 end

 elseif direction == "prev" then
  if (rns.selected_note_column_index > 0) and (rns.selected_sub_column_type > 2 and rns.selected_sub_column_type < 8) then -- any sample effects column
   rns.selected_note_column_index = rns.selected_note_column_index
  elseif (rns.selected_note_column_index > 1) then -- any note column but not the first
   rns.selected_note_column_index = rns.selected_note_column_index - 1
  elseif (rns.selected_effect_column_index > 1) then -- any effect column but not the first
   rns.selected_effect_column_index = rns.selected_effect_column_index - 1
  elseif (rns.selected_effect_column_index == 1) and (rns.selected_track.visible_note_columns > 0) then -- first effect column and note columns exist
   rns.selected_note_column_index = rns.selected_track.visible_note_columns
  elseif (rns.selected_effect_column_index == 1) and (rns.selected_track.visible_note_columns == 0) then -- first effect column and note columns do not exist (group/send/master)
   rns.selected_track_index = rns.selected_track_index - 1
   if rns.selected_track.visible_effect_columns > 0 then rns.selected_effect_column_index = rns.selected_track.visible_effect_columns
   else rns.selected_note_column_index = rns.selected_track.visible_note_columns
   end
  elseif (rns.selected_note_column_index == 1) and (rns.selected_track_index == 1) then -- first note column in first track
   rns.selected_track_index = #rns.tracks
   rns.selected_effect_column_index = rns.selected_track.visible_effect_columns
  elseif (rns.selected_note_column_index == 1) then -- first note column
   rns.selected_track_index = rns.selected_track_index - 1
   if rns.selected_track.visible_effect_columns > 0 then rns.selected_effect_column_index = rns.selected_track.visible_effect_columns
   else rns.selected_note_column_index = rns.selected_track.visible_note_columns
   end   
  end
 end
end
 
renoise.tool():add_keybinding {
  name = "Pattern Editor:Navigation:Joule Toggle between note/fx columns",
 invoke = toggle_column_type }

renoise.tool():add_keybinding {
  name = "Pattern Editor:Navigation:Joule Jump to next column (note/fx)",
 invoke = function() cycle_column("next") end }

renoise.tool():add_keybinding {
  name = "Pattern Editor:Navigation:Joule Jump to previous column (note/fx)",
 invoke = function() cycle_column("prev") end }

renoise.tool().app_idle_observable:add_notifier(cache_columns)
