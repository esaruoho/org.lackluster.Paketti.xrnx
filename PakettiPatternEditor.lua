

























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


