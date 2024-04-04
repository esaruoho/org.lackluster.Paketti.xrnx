---------------------------------------------------------------------------------------------------------------
--Set the next ReWire channel - shortcut. If you have a pre-configured 32 input ReWire master host
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

renoise.tool():add_keybinding{name="Global:Paketti:Set Next ReWire channel", invoke=function() next_rewire() end  }
----------------------------------------------------------------------------------------------------------

-- //TODO: since notifiers do not work, how to find a workaround??
function contourShuttleRecordPrototype()
if not renoise.app().window.sample_record_dialog_is_visible
then renoise.app().window.sample_record_dialog_is_visible=true
end
renoise.song().transport:start_stop_sample_recording()
end

renoise.tool():add_keybinding{name="Global:Paketti:Contour Shuttle Record Prototype", invoke=function() contourShuttleRecordPrototype() end}
----
--Sampler which returns to sample editor.
function sample_and_to_sample_editor()
  local w=renoise.app().window
  local t=renoise.song().transport
 if w.sample_record_dialog_is_visible==false then
 w.sample_record_dialog_is_visible=true
 t:start_stop_sample_recording()
 else
-- delay(1)
 t:start_stop_sample_recording()
    w.active_upper_frame = 1
    w.active_middle_frame = 3
 --   w.active_lower_frame = 3
    w.lock_keyboard_focus=true
 end


end

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Start Sampling (Record)", invoke=function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible=true end}  

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Start Sampling (Record)", invoke=function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible=true end}  

renoise.tool():add_keybinding{name="Global:Paketti:Sample NOW then F3 (Record)", invoke=function() sample_and_to_sample_editor()
F3() end}
-------
local lsfvariable=nil
lsfvariable=os.tmpname("wav")

local tmpvariable=nil
tmpvariable=os.tmpname("wav")
--local path="/Users/esaruoho/Music/samples/LogicSmartFolder/"
--local path3="/Users/esaruoho/Music/samples/LogicSmartFolder/file.wav"
--concatpath=path tmpvariable

function SampleToLiveSF()
local lsfvariable=nil
lsfvariable=os.tmpname("wav")
local path="/Users/esaruoho/Music/samples/LiveSmartFolder/"
local path2="SmartFolderFile" 
local s=renoise.song()
renoise.app():show_status("Saving")
local randoseed = nil
local instboxname = renoise.song().selected_instrument.name
randoseed = math.random()
s.instruments[s.selected_instrument_index].samples[1].sample_buffer:save_as(path .. instboxname .. randoseed .. ".wav", "wav")
--s.instruments[s.selected_instrument_index].samples[1].sample_buffer:save_as(lsfvariable, "wav")
renoise.app():show_status("Saved")
--renoise.app():show_status("Moving")
--renoise.app():show_status("32Bit to 24Bit Converting")
--os.execute("beep")
--os.execute("sox " .. lsfvariable .. " -b 24 " .. path .. "LSF_a" .. s.selected_instrument_index .. "_opbab.wav")
--renoise.app():show_status("32Bit to 24Bit Conversion From Tmp-folder to Logic Smart Folder Done")
--os.execute("cd /Users/esaruoho/Music/samples/LogicSmartFolder;open .")
--renoise.app():show_status("Temporary File Name was " .. lsfvariable )
end

renoise.tool():add_keybinding{name="Global:Paketti:Save Sample to Live Smart Folder",invoke=function() SampleToLiveSF() end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Ableton Live..:Save Sample to Live Smart Folder",invoke=function() SampleToLiveSF() end}

function SampleToLogicSF()
local lsfvariable=nil
lsfvariable=os.tmpname("wav")
local path="/Users/esaruoho/Music/samples/LogicSmartFolder/"
local path2="SmartFolderFile" 
local s=renoise.song()
renoise.app():show_status("Saving")
s.instruments[s.selected_instrument_index].samples[1].sample_buffer:save_as(path .. path2 .. ".wav", "wav")
renoise.app():show_status("Saved")
end

renoise.tool():add_keybinding{name="Global:Paketti:Save Sample to Logic Smart Folder",invoke=function() SampleToLogicSF() end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Logic Pro..:Save Sample to Logic Smart Folder",invoke=function() SampleToLogicSF() end}

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

renoise.tool():add_keybinding{name="Global:Paketti:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_keybinding{name="Global:Paketti:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100() end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75()  end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}

-----
function instrument_is_empty(instrument)
 local inst = renoise.song().instruments[instrument]
 local has_sample_data = false
 for sample in ipairs(inst.samples) do
  has_sample_data = has_sample_data or inst.samples[sample].sample_buffer.has_sample_data
 end
 if inst.plugin_properties.plugin_loaded or inst.midi_output_properties.device_name ~= "" or has_sample_data then return false else return true end
end

function search_empty_instrument()
  local proc = renoise.song()
    for empty_instrument = 1, #proc.instruments do local samples = false
    
    for i = 1,#proc.instruments[empty_instrument].samples do
      local temp_buffer = proc.instruments[empty_instrument].samples[i].sample_buffer
        if temp_buffer.has_sample_data then samples = true break end
    end
    
    local plugin = proc.instruments[empty_instrument].plugin_properties.plugin_loaded
    local midi_device = proc.instruments[empty_instrument].midi_output_properties.device_name
      if ((samples == false) and (plugin == false) and (midi_device == nil or midi_device == "")) then
        return empty_instrument end
      end
  proc:insert_instrument_at(#proc.instruments+1)
  return #proc.instruments
end
------------------------------------------------------------------------------------------------------------
--This records to currently selected track and outputs 0G01 and c-4 and selected_instrument
function recordtocurrenttrack()
renoise.song().transport.edit_mode=false
 local s=renoise.song()
 local ss=s.selected_sample
 local t=renoise.song().transport
 local w=renoise.app().window 
  w.active_lower_frame=2
 local currTrak=s.selected_track_index
 local currSamp=s.selected_sample_index
    if t.playing==false then
    t.playing=true end
    
 local name = nil
    if s.selected_track_index<10 then 
    name="Track 0".. s.selected_track_index
    else
    name="Track ".. s.selected_track_index
    end
    
     if s.tracks[currTrak].name==name
     then s.tracks[currTrak].name=" 1"
     end
     
       if  s.tracks[currTrak].name==" 12" then 
 local nexttrack=s.selected_track_index+1
           s:insert_track_at(nexttrack)
           s.selected_track_index=s.selected_track_index+1
           s.tracks[s.selected_track_index].name=" 1"
       end

s.selected_instrument_index = search_empty_instrument()

 w.sample_record_dialog_is_visible=true   
 t:start_stop_sample_recording()
 if s.selected_sample == nil then return else 
  if s.selected_sample.sample_buffer_observable:has_notifier(finalrecord) == false then 
     s.selected_sample.sample_buffer_observable:add_notifier(finalrecord)
     oprint ("kukkuu")
     else
     ss.sample_buffer_observable:remove_notifier(finalrecord)
     oprint ("kikkii")
  end
  end
--  delay(3)
--  renoise.song().transport:trigger_sequence(1)
end
------------------------------------------------------------------------------------------------------------------------------------------------
function finalrecord()
  local s=renoise.song()
  local ss=s.selected_sample
  local currTrak=s.selected_track_index
  local currPatt=s.selected_pattern_index
  local currSamp=renoise.song().selected_sample_index
  local currInst=s.selected_instrument_index

  local w=renoise.app().window
  local rightinstrument=nil
  local place=nil 
  local zero=nil
  local o=nil
  local rightinstrument=renoise.song().selected_instrument_index-1
  local nc=s.patterns[currPatt].tracks[currTrak].lines[1].note_columns
  local selnotcol=renoise.song().selected_note_column_index
  local vnc=renoise.song().tracks[currTrak].visible_note_columns

      w.sample_record_dialog_is_visible=false 
      w.active_lower_frame=2
      ss.autoseek=true
      s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
      s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"
              
    for o = 1,12 do 
      if nc[o].note_string=="---" then 
        s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[o].note_string="C-4"
        s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[o].instrument_value=rightinstrument
         if vnc < o then
          s.tracks[currTrak].visible_note_columns=o
          renoise.song().tracks[currTrak].name=" " .. o
         end
        break
      end 
    end
  local t=renoise.song().transport
  local seq=renoise.song().selected_sequence_index
  local startpos = renoise.song().transport.playback_pos  
--t:panic()
--t:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
--  startpos.line = renoise.song().selected_line_index
--  startpos.sequence = renoise.song().selected_sequence_index
--  renoise.song().transport.playback_pos = startpos
--  t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
--  ss.sample_buffer_observable:remove_notifier(finalrecord) 
  if ss.sample_buffer_observable:has_notifier(finalrecord) then 
     ss.sample_buffer_observable:remove_notifier(finalrecord)
     return
  end
  end

renoise.tool():add_midi_mapping{name="Paketti:Record to Current Track x[Toggle]", invoke=function() recordtocurrenttrack() 
  local t=renoise.song().transport
   if t.playing==false then t.playing=true end
  local seq=renoise.song().selected_sequence_index
  local startpos = t.playback_pos  
  t.loop_block_enabled=false
  --t:panic()
  --startpos.line = renoise.song().selected_line_index
  --startpos.sequence = renoise.song().selected_sequence_index
  --t.playback_pos = startpos
  --t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
  t.follow_player=true
  renoise.app().window.active_lower_frame=2
  renoise.app().window.lower_frame_is_visible=true
end}

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Record to Current Track", invoke=function() recordtocurrenttrack() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Record to Current Track", invoke=function() recordtocurrenttrack() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Record to Current Track", invoke=function() recordtocurrenttrack() end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Record to Current Track", invoke=function() recordtocurrenttrack() end}
renoise.tool():add_keybinding{name="Global:Paketti:Record to Current Track Track", invoke=function() recordtocurrenttrack() 
local s=renoise.song()
 local t=renoise.song().transport

s.selected_instrument_index = search_empty_instrument()
  if t.playing==false then t.playing=true end
 local seq=s.selected_sequence_index
 local startpos = s.transport.playback_pos  
 t.follow_player=true
 t.loop_block_enabled=false
 t.follow_player=true
 renoise.app().window.lower_frame_is_visible=true
 renoise.app().window.active_lower_frame=2 end}

 renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Start Sampling (Record)", invoke=function()
local s=renoise.song()
local t=s.transport
if not t.playing then t.playing=true end

recordtocurrenttrack() 
s.selected_instrument_index = search_empty_instrument()
  if t.playing==false then t.playing=true end
 local seq=renoise.song().selected_sequence_index
 local startpos = renoise.song().transport.playback_pos  
 t.follow_player=true
 t.loop_block_enabled=false
 t.follow_player=true
 renoise.app().window.lower_frame_is_visible=true
 renoise.app().window.active_lower_frame=2 end}

renoise.tool():add_keybinding{name="Global:Paketti:Record to Current Track w/Metronome", invoke=function() 
local s=renoise.song()
local t=s.transport

if t.metronome_enabled==false then t.metronome_enabled=true
else
t.metronome_enabled=false
end
recordtocurrenttrack() 
s.selected_instrument_index = search_empty_instrument()
 if t.playing==false then t.playing=true end
 local seq=s.selected_sequence_index
 local startpos = t.playback_pos  
 t.follow_player=true
--t:panic()
 t.loop_block_enabled=false
 --startpos.line = renoise.song().selected_line_index
 --startpos.sequence = renoise.song().selected_sequence_index
 --renoise.song().transport.playback_pos = startpos
 --t:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
 t.follow_player=true
 renoise.app().window.lower_frame_is_visible=true
 renoise.app().window.active_lower_frame=2 end}






renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Record to Current Track", invoke=function() recordtocurrenttrack() end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Start Sampling (Record)", invoke=function() sample_and_to_sample_editor()
renoise.app().window.sample_record_dialog_is_visible=true end}  







