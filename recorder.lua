---------------------------------------------------------------------------------------------------------------
--Set the next ReWire channel - shortcut. If you have a pre-configured 32 input rewire master host
--running, you can just press a shortcut and get it to play in the track of your choice (on your
--master host that is). This is a really simple thing, but it works after a fashion and does
--what I wanted it to do.
function next_rewire()
local s=renoise.song()
local current=s.selected_track.output_routing
local st=s.selected_track
if current=="Master Track" then st.output_routing="Bus 01 L/R"
elseif current=="Bus 01 L/R" then st.output_routing="Bus 02 L/R"
elseif current=="Bus 02 L/R" then st.output_routing="Bus 03 L/R"
elseif current=="Bus 03 L/R" then st.output_routing="Bus 04 L/R"
elseif current=="Bus 04 L/R" then st.output_routing="Bus 05 L/R"
elseif current=="Bus 05 L/R" then st.output_routing="Bus 06 L/R"
elseif current=="Bus 06 L/R" then st.output_routing="Bus 07 L/R"
elseif current=="Bus 07 L/R" then st.output_routing="Bus 08 L/R"
elseif current=="Bus 08 L/R" then st.output_routing="Bus 09 L/R"
elseif current=="Bus 09 L/R" then st.output_routing="Bus 10 L/R"
elseif current=="Bus 10 L/R" then st.output_routing="Bus 11 L/R"
elseif current=="Bus 11 L/R" then st.output_routing="Bus 12 L/R"
elseif current=="Bus 12 L/R" then st.output_routing="Bus 13 L/R"
elseif current=="Bus 13 L/R" then st.output_routing="Bus 14 L/R"
elseif current=="Bus 14 L/R" then st.output_routing="Bus 15 L/R"
elseif current=="Bus 15 L/R" then st.output_routing="Bus 16 L/R"
elseif current=="Bus 16 L/R" then st.output_routing="Bus 17 L/R"
elseif current=="Bus 17 L/R" then st.output_routing="Bus 18 L/R"
elseif current=="Bus 18 L/R" then st.output_routing="Bus 19 L/R"
elseif current=="Bus 19 L/R" then st.output_routing="Bus 20 L/R"
elseif current=="Bus 20 L/R" then st.output_routing="Bus 21 L/R"
elseif current=="Bus 21 L/R" then st.output_routing="Bus 22 L/R"
elseif current=="Bus 22 L/R" then st.output_routing="Bus 23 L/R"
elseif current=="Bus 23 L/R" then st.output_routing="Bus 24 L/R"
elseif current=="Bus 24 L/R" then st.output_routing="Bus 25 L/R"
elseif current=="Bus 25 L/R" then st.output_routing="Bus 26 L/R"
elseif current=="Bus 26 L/R" then st.output_routing="Bus 27 L/R"
elseif current=="Bus 27 L/R" then st.output_routing="Bus 28 L/R"
elseif current=="Bus 28 L/R" then st.output_routing="Bus 29 L/R"
elseif current=="Bus 29 L/R" then st.output_routing="Bus 30 L/R"
elseif current=="Bus 30 L/R" then st.output_routing="Bus 31 L/R"
elseif current=="Bus 31 L/R" then st.output_routing="Master Track"
end
renoise.app():show_status("Current Track output set to: " .. st.output_routing) 
end

renoise.tool():add_keybinding {name="Global:Paketti:Set Next ReWire channel", invoke=function() next_rewire() end  }
----------------------------------------------------------------------------------------------------------

function contourShuttleRecordPrototype()
if not renoise.app().window.sample_record_dialog_is_visible
then renoise.app().window.sample_record_dialog_is_visible=true
else end
renoise.song().transport:start_stop_sample_recording()
end

renoise.tool():add_keybinding {name="Global:Paketti:Contour Shuttle Record Prototype", invoke = function() contourShuttleRecordPrototype() end}



-------
----------------------------------------------------------------------------------------------------------
-- Set current tempo to 75% of current tempo. Set current tempo back to the original 100% tempo.
-- Writes the currently set (75% or 100%) BPM / LPB to the Master effect_column. Takes effect immediately.
function get_master_track_index()
  for k,v in ripairs(renoise.song().tracks)
    do if v.type == renoise.Track.TRACK_TYPE_MASTER then return k end  
  end
end

function WriteToMaster()
 local column_index = renoise.song().selected_effect_column_index
 local t=renoise.song().transport
 if renoise.song().transport.bpm < 256 then -- safety check
 renoise.song().tracks[get_master_track_index()].visible_effect_columns = 2  
    
    if renoise.song().selected_effect_column_index <= 1 then column_index = 2 end
    
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].number_string = "ZT"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[1].amount_value  = t.bpm
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].number_string = "ZL"
    renoise.song().selected_pattern.tracks[get_master_track_index()].lines[1].effect_columns[2].amount_value  = t.lpb
    end
-- † --
 end

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

renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_menu_entry {name="Pattern Matrix:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}
renoise.tool():add_keybinding {name="Global:Paketti:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_keybinding {name="Global:Paketti:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100() end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75()  end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}

