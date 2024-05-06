function noteOnToNoteOff(noteoffPitch)
  -- Check if the instrument has no samples and return if so
  if #renoise.song().instruments[renoise.song().selected_instrument_index].samples == 0 then
    return
  end

renoise.song().instruments[renoise.song().selected_instrument_index]:insert_sample_at(2)
renoise.song().selected_sample_index = 2
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index]:copy_from(renoise.song().instruments[renoise.song().selected_instrument_index].samples[1])
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].sample_mapping.layer=2
renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[2][1].sample.transpose=noteoffPitch
renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[2][1].sample.name = renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[1][1].sample.name

renoise.song().selected_sample_index=1
end

renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer +24",invoke=function() noteOnToNoteOff(24) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer +12",invoke=function() noteOnToNoteOff(12) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer",invoke=function() noteOnToNoteOff(0) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer -12",invoke=function() noteOnToNoteOff(-12) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer -24",invoke=function() noteOnToNoteOff(-24) end}

renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer +24",invoke=function() noteOnToNoteOff(24) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer +12",invoke=function() noteOnToNoteOff(12) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer",invoke=function() noteOnToNoteOff(0) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer -12",invoke=function() noteOnToNoteOff(-12) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer -24",invoke=function() noteOnToNoteOff(-24) end}


--------

function Experimental()
    local function read_file(path)
        local file = io.open(path, "r")  -- Open the file in read mode
        if not file then
            print("Failed to open file")
            return nil
        end
        local content = file:read("*a")  -- Read the entire content
        file:close()
        return content
    end

    local function check_and_execute(xml_path, bash_script)
        local xml_content = read_file(xml_path)
        if not xml_content then
            return
        end

        local pattern = "<ShowScriptingDevelopmentTools>(.-)</ShowScriptingDevelopmentTools>"
        local current_value = xml_content:match(pattern)

        if current_value == "false" then  -- Check if the value is false
            print("Scripting tools are disabled. Executing the bash script to enable...")
            local command = 'open -a Terminal "' .. bash_script .. '"'
            os.execute(command)
        elseif current_value == "true" then
            print("Scripting tools are already enabled. No need to execute the bash script.")
          local bash_script = "/Users/esaruoho/macOS_DisableScriptingTools.sh"
            local command = 'open -a Terminal "' .. bash_script .. '"'
            os.execute(command)
        else
            print("Could not find the <ShowScriptingDevelopmentTools> tag in the XML.")
        end
    end

    local config_path = "/Users/esaruoho/Library/Preferences/Renoise/V3.4.3/Config.xml"
    local bash_script = "/Users/esaruoho/macOS_EnableScriptingTools.sh" -- Ensure this path is correct

    check_and_execute(config_path, bash_script)
end

renoise.tool():add_menu_entry {name = "Main Menu:Tools:Experimental",invoke = function() Experimental() end}





function effectbypass()
local number = (table.count(renoise.song().selected_track.devices))
 for i=2,number  do 
  renoise.song().selected_track.devices[i].is_active=false
 end
end

function effectenable()
local number = (table.count(renoise.song().selected_track.devices))
for i=2,number  do 
renoise.song().selected_track.devices[i].is_active=true
end
end

renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Bypass All Devices on Channel", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Enable All Devices on Channel", invoke=function() effectenable() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Bypass All Devices on Channel", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Enable All Devices on Channel", invoke=function() effectenable() end}








--Wipes the pattern data, but not the samples or instruments.
--WARNING: Does not reset current filename.
function wipeSongPattern()
local s=renoise.song()
  for i=1,300 do
    if s.patterns[i].is_empty==false then
    s.patterns[i]:clear()
    renoise.song().patterns[i].number_of_lines=64
    else 
    print ("Encountered empty pattern, not deleting")
    renoise.song().patterns[i].number_of_lines=64
    end
  end
end
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Song Patterns", invoke=function() wipeSongPattern() end}














function AutoGapper()
-- Something has changed with the Filter-device:
--*** ./Experimental_Verify.lua:30: attempt to index field '?' (a nil value)
--*** stack traceback:
--***   ./Experimental_Verify.lua:30: in function 'AutoGapper'
--***   ./Experimental_Verify.lua:37: in function <./Experimental_Verify.lua:37>

--renoise.song().tracks[get_master_track_index()].visible_effect_columns = 4  
local gapper=nil
renoise.app().window.active_lower_frame=1
renoise.app().window.lower_frame_is_visible=true
  loadnative("Audio/Effects/Native/Filter")
  loadnative("Audio/Effects/Native/*LFO")
  renoise.song().selected_track.devices[2].parameters[2].value=2
  renoise.song().selected_track.devices[2].parameters[3].value=1
  renoise.song().selected_track.devices[2].parameters[7].value=2
  renoise.song().selected_track.devices[3].parameters[5].value=0.0074
local gapper=renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines*2*4
  renoise.song().selected_track.devices[2].parameters[6].value_string=tostring(gapper)
--renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[4].number_string = "18"
end

renoise.tool():add_keybinding{name="Global:Paketti:Add Filter & LFO (AutoGapper)", invoke=function() AutoGapper() end}















--2nd keybind for LoopBlock forward/backward
function loopblockback()
local t = renoise.song().transport
      t.loop_block_enabled=true
      t:loop_block_move_backwards()
      t.follow_player = true
end

function loopblockforward()
local t = renoise.song().transport
      t.loop_block_enabled=true
      t:loop_block_move_forwards()
      t.follow_player = true
end

renoise.tool():add_keybinding{name="Global:Paketti:Loop Block Backwards", invoke=function() loopblockback() end}
renoise.tool():add_keybinding{name="Global:Paketti:Loop Block Forwards", invoke=function() loopblockforward() end}

function midiprogram(change)  
local midi=renoise.song().selected_instrument.midi_output_properties  
local currentprg=midi.program  
 currentprg = math.max(1, math.min(128, currentprg + change))  
 rprint (currentprg)  
renoise.song().selected_instrument.midi_output_properties.program = currentprg  
renoise.song().transport:panic()  
end  
  
-->>> oprint (renoise.song().selected_instrument.midi_output_properties)  
--class: InstrumentMidiOutputProperties  
 --properties:  
 --bank  
 --bank_observable  
 --channel  
 --channel_observable  
 --delay  
 --delay_observable  
 --device_name  
 --device_name_observable  
 --duration  
 --duration_observable  
 --instrument_type  
 --instrument_type_observable  
 --program  
 --program_observable  
 --transpose  
 --transpose_observable  
renoise.tool():add_keybinding{name="Global:Impulse:Next/Prev Midi Program +1", invoke=function() midiprogram(1) end}  
renoise.tool():add_keybinding{name="Global:Impulse:Next/Prev Midi Program -1", invoke=function() midiprogram(-1) end}  

renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Reverb", invoke=function() loadvst("Audio/Effects/AU/aumf:676v:TOGU") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Chorus", invoke=function() loadvst("Audio/Effects/AU/aufx:Chor:Togu") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Ultra Simple EQ", invoke=function() loadvst("Audio/Effects/AU/aufx:TILT:Togu") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Dub-Delay I", invoke=function() loadvst("Audio/Effects/AU/aumf:aumf:Togu") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Dub-Delay II", invoke=function() loadvst("Audio/Effects/AU/aumf:dub2:Togu") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Dub-Delay III",invoke=function() loadvst("Audio/Effects/AU/aumf:xg70:TOGU") end}

function muteUnmuteNoteColumn()
local s = renoise.song()
local sti = s.selected_track_index
local snci = s.selected_note_column_index

if s.selected_note_column_index == 0 
  then return else
if s:track(sti):column_is_muted(snci) == true
  then s:track(sti):mute_column(snci, false)
else s:track(sti):mute_column(snci, true) end end
end

--renoise.tool():add_keybinding{name="Global:Paketti:Mute Unmute Notecolumn", invoke=function() muteUnmuteNoteColumn() end} <- confirmed as not working
----------------------------------------------------------------------------------------------------------------------------------------







-- Utility function to print a formatted list from the provided items
local function printItems(items)
    -- Sort items alphabetically by name
    table.sort(items, function(a, b) return a.name < b.name end)
    for _, item in ipairs(items) do
        print(item.name .. ": " .. item.path)
    end
end

-- Function to list available plugins by type
local function listAvailablePluginsByType(typeFilter)
    local availablePlugins = renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.available_plugins
    local availablePluginInfos = renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.available_plugin_infos
    local pluginItems = {}

    for index, pluginPath in ipairs(availablePlugins) do
        -- Adjusting to exclude VST3 content from VST listing
        if typeFilter == "VST" and pluginPath:find("/VST/") and not pluginPath:find("/VST3/") then
            local pluginInfo = availablePluginInfos[index]
            if pluginInfo then
                table.insert(pluginItems, {name = pluginInfo.name, path = pluginInfo.path})
            end
        elseif typeFilter ~= "VST" and pluginPath:find("/" .. typeFilter .. "/") then
            local pluginInfo = availablePluginInfos[index]
            if pluginInfo then
                table.insert(pluginItems, {name = pluginInfo.name, path = pluginInfo.path})
            end
        end
    end

    printItems(pluginItems)
end

-- Adjusted function to handle only plugin listing
local function listByPluginType(typeFilter)
    print(typeFilter .. " Plugins:")
    listAvailablePluginsByType(typeFilter)
end


-- Function to list devices (effects) by type, remains unchanged as it's working correctly
local function listDevicesByType(typeFilter)
    local devices = renoise.song().tracks[renoise.song().selected_track_index].available_device_infos
    local deviceItems = {}
     print(typeFilter .. " Devices:")
    for _, deviceInfo in ipairs(devices) do
        if deviceInfo.path:find("/" .. typeFilter .. "/") and not deviceInfo.path:find("/Native/") then
            table.insert(deviceItems, {name = deviceInfo.name, path = deviceInfo.path})
        end
    end
    printItems(deviceItems)
end

function start_stop_sample_and_loop_oh_my()
local w=renoise.app().window
local s=renoise.song()
local t=s.transport
local ss=s.selected_sample
local currTrak=s.selected_track_index
local currPatt=s.selected_pattern_index

if w.sample_record_dialog_is_visible then
    -- we are recording, stop
    t:start_stop_sample_recording()
    -- write note
     ss.autoseek=true
     s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
     s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"

for i= 1,12 do
if s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].is_empty==true then
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].note_string="C-4"
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].instrument_value=s.selected_instrument_index-1
else
 if i == renoise.song().tracks[currTrak].visible_note_columns and i == 12
  then renoise.song():insert_track_at(renoise.song().selected_track_index)
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[1].note_string="C-4"
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[1].instrument_value=s.selected_instrument_index-1
end
end
end
    -- hide dialog
    w.sample_record_dialog_is_visible = false
  else
    -- not recording. show dialog, start recording.
    w.sample_record_dialog_is_visible = true
    t:start_stop_sample_recording()
  end
end


--renoise.tool():add_keybinding{name="Global:Paketti:Stair RecordToCurrent", invoke=function() 
--if renoise.song().transport.playing==false then
    --renoise.song().transport.playing=true end
--start_stop_sample_and_loop_oh_my() end}
--
--function stairs()
--local currCol=nil
--local addCol=nil
--currCol=renoise.song().selected_note_column_index
---
--if renoise.song().selected_track.visibile_note_columns and renoise.song().selected_note_column_index == 12   then 
--renoise.song().selected_note_column_index = 1
--end
--
--
--if currCol == renoise.song().selected_track.visible_note_columns
--then renoise.song().selected_track.visible_note_columns = addCol end
--
--renoise.song().selected_note_column_index=currCol+1
--
--end
--renoise.tool():add_keybinding{name="Global:Paketti:Stair", invoke=function() stairs() end}

function effectbypasspattern()
local currTrak = renoise.song().selected_track_index
local number = (table.count(renoise.song().selected_track.devices))
local tablee={"1F","2F","3F","4F","5F","6F","7F","8F"}
 for i=2,number  do 
  --renoise.song().selected_track.devices[i].is_active=false
  renoise.song().selected_track.visible_effect_columns=(table.count(renoise.song().selected_track.devices)-1)
--This would be (1-8F)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[1].number_string="1F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[2].number_string="2F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[3].number_string="3F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[4].number_string="4F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[5].number_string="5F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[6].number_string="6F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[7].number_string="7F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[8].number_string="8F"
--this would be 00 for disabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="00"
 end
end

function effectenablepattern()
local currTrak = renoise.song().selected_track_index
local number = (table.count(renoise.song().selected_track.devices))
for i=2,number  do 
--enable all plugins on selected track right now
--renoise.song().selected_track.devices[i].is_active=true
--display max visible effects
local helper=(table.count(renoise.song().selected_track.devices)-1)
renoise.song().selected_track.visible_effect_columns=helper
--This would be (1-8F)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[1].number_string="1F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[2].number_string="2F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[3].number_string="3F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[4].number_string="4F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[5].number_string="5F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[6].number_string="6F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[7].number_string="7F"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[8].number_string="8F"

--this would be 01 for enabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="01"
end
end



-- Menu Entries
-- Pattern Matrix
-- Pattern Sequencer
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Bypass EFX (Write to Pattern)", invoke=function() effectbypasspattern() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Enable EFX (Write to Pattern)", invoke=function() effectenablepattern()  end}
----------------------------

-- has-line-input + add-line-input
local function has_line_input()
-- Write some code to find the line input in the correct place
local tr = renoise.song().selected_track
 if tr.devices[2] and tr.devices[2].device_path=="Audio/Effects/Native/#Line Input" 
  then return true
 else
  return false
 end
end

local function add_line_input()
-- Write some code to add the line input in the correct place
 loadnative("Audio/Effects/Native/#Line Input")
end

local function remove_line_input()
-- Write some code to remove the line input if it's in the correct place
 renoise.song().selected_track:delete_device_at(2)
end

-- recordamajic
local function recordamajic9000(running)
    if running then
    renoise.song().transport.playing=true
        -- start recording code here
renoise.app().window.sample_record_dialog_is_visible=true
renoise.app().window.lock_keyboard_focus=true
renoise.song().transport:start_stop_sample_recording()
    else
    -- Stop recording here
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Recordammajic9000",
invoke=function() if has_line_input() then 
      recordtocurrenttrack()    
      G01()
 else add_line_input()
      recordtocurrenttrack()
      G01()
 end end}

-- turn samplerecorder ON
function SampleRecorderOn()
local howmany = table.count(renoise.song().selected_track.devices)

if renoise.app().window.sample_record_dialog_is_visible==false then
renoise.app().window.sample_record_dialog_is_visible=true 

  if howmany == 1 then 
    loadnative("Audio/Effects/Native/#Line Input")
    return
  else
    if renoise.song().selected_track.devices[2].name=="#Line Input" then
    renoise.song().selected_track:delete_device_at(2)
    renoise.app().window.sample_record_dialog_is_visible=false
    else
    loadnative("Audio/Effects/Native/#Line Input")
    return
end    
  end  

else renoise.app().window.sample_record_dialog_is_visible=false
  if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Display Sample Recorder with #Line Input", invoke=function() SampleRecorderOn() end}

function glideamount(amount)
local counter=nil 
for i=renoise.song().selection_in_pattern.start_line,renoise.song().selection_in_pattern.end_line 
do renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].number_string="0G" 
counter=renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].amount_value+amount 

if counter > 255 then counter=255 end
if counter < 1 then counter=0 
end
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].amount_value=counter 
end
end

function ploo()
local rs=renoise.song()
local n_instruments = #rs.instruments
local src_inst_i = rs.selected_instrument_index
local src_inst = rs:instrument(src_inst_i)

rs:insert_instrument_at(n_instruments)
rs.selected_instrument_index = n_instruments

rs.selected_instrument:copy_from(src_inst)
end

--This makes sure that when you start Renoise, it switches to preset#1. 
--You will have to actually feed information to Config.XML to get to the specified settings. The settings go like this
--Upper Layer = visible.
--Disk Browser = visible.
--Disk Browser = set to Sample. 
--Cursor Focus is on Disk Browser
--
--Also, this segment makes sure that when you load a sample, and are in Disk Browser Expanded-mode, you are transported
--to the Sample Editor. It's actually fairly buggy so either it works or it doesn't, sometimes it does, mostly it doesn't.
--This is all heavily work in progress.
local s = nil

function startup_()
  local s=renoise.song()
   renoise.app().window:select_preset(1)
   
   renoise.song().instruments[s.selected_instrument_index].active_tab=1
    if renoise.app().window.active_middle_frame==0 and s.selected_sample.sample_buffer_observable:has_notifier(sample_loaded_change_to_sample_editor) then 
    s.selected_sample.sample_buffer_observable:remove_notifier(sample_loaded_change_to_sample_editor)
    else
  --jep  --s.selected_sample.sample_buffer_observable:add_notifier(sample_loaded_change_to_sample_editor)

    return
    end
end

  function sample_loaded_change_to_sample_editor()
--    renoise.app().window.active_middle_frame=4
  end

if not renoise.tool().app_new_document_observable:has_notifier(startup_) 
   then renoise.tool().app_new_document_observable:add_notifier(startup_)
   else renoise.tool().app_new_document_observable:remove_notifier(startup_)
end
--------------------------------------------------------------------------------

function PakettiCapsLockNoteOffNextPtn()   
local s=renoise.song()
local wrapping=s.transport.wrapped_pattern_edit
local editstep=s.transport.edit_step

local currLine=s.selected_line_index
local currPatt=s.selected_pattern_index

local counter=nil
local addlineandstep=nil
local counting=nil
local seqcount=nil
local resultPatt=nil

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="FF"
then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=""
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=""
return
else
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"
then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00"  
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return
end

if renoise.song().transport.edit_mode==true then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"  
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="CF"
return
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"

then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00" 
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string~=nil then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="FF"
return
else 
if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=="OFF" then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
return
else
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
end

--s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
end

addlineandstep=currLine+editstep
seqcount = currPatt+1

if addlineandstep > s.patterns[currPatt].number_of_lines then
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
counting=addlineandstep-s.patterns[currPatt].number_of_lines
 if seqcount > (table.count(renoise.song().sequencer.pattern_sequence)) then 
 seqcount = (table.count(renoise.song().sequencer.pattern_sequence))
 s.selected_sequence_index=seqcount
 end
 
resultPatt=currPatt+1 
 if resultPatt > #renoise.song().sequencer.pattern_sequence then 
 resultPatt = (table.count(renoise.song().sequencer.pattern_sequence))
s.selected_sequence_index=resultPatt
s.selected_line_index=counting
end
else 
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
--s.selected_sequence_index=currPatt+1
s.selected_line_index=addlineandstep

counter = addlineandstep-1

renoise.app():show_status("Now on: " .. counter .. "/" .. s.patterns[currPatt].number_of_lines .. " In Pattern: " .. currPatt)
end
end

function PakettiCapsLockNoteOff()   
local s=renoise.song()
local st=s.transport
local wrapping=st.wrapped_pattern_edit
local editstep=st.edit_step

local currLine=s.selected_line_index
local currPatt=s.selected_sequence_index

local counter=nil
local addlineandstep=nil
local counting=nil
local seqcount=nil

if renoise.song().patterns[renoise.song().selected_sequence_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=="OFF" then 

s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
return
else end

if not s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=="OFF"
then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
else s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
end

addlineandstep=currLine+editstep
seqcount = currPatt+1

if addlineandstep > s.patterns[currPatt].number_of_lines then
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
counting=addlineandstep-s.patterns[currPatt].number_of_lines
 if seqcount > (table.count(renoise.song().sequencer.pattern_sequence)) then 
 seqcount = (table.count(renoise.song().sequencer.pattern_sequence))
 s.selected_sequence_index=seqcount
 end
--s.selected_sequence_index=currPatt+1
s.selected_line_index=counting
else 
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
--s.selected_sequence_index=currPatt+1
s.selected_line_index=addlineandstep

counter = addlineandstep-1

renoise.app():show_status("Now on: " .. counter .. "/" .. s.patterns[currPatt].number_of_lines .. " In Pattern: " .. currPatt)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Note Off / Caps Lock replacement", invoke=function() 
if renoise.song().transport.wrapped_pattern_edit == false then PakettiCapsLockNoteOffNextPtn() 
else PakettiCapsLockNoteOff() end
end}
--------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Record to Current Track+Plus", 
invoke=function() 
      renoise.app().window.active_lower_frame=1
local howmany = table.count(renoise.song().selected_track.devices)

if howmany == 1 then 
loadnative("Audio/Effects/Native/#Line Input")
recordtocurrenttrack()
return
else
if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  recordtocurrenttrack()
  return
else
  loadnative("Audio/Effects/Native/#Line Input")
  recordtocurrenttrack()
  return
end end end}

renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Record To Current", invoke=function() recordtocurrenttrack() end}
----------------------------------------------------------------------------------------------------------
--esa- 2nd keybind for Record Toggle ON/OFF  with effect_column reading
function RecordToggle()
 local a=renoise.app()
 local s=renoise.song()
 local t=s.transport
 local currentstep=t.edit_step
--if has notifier, dump notifier, if no notifier, add notifier
 if t.edit_mode then
    t.edit_mode=false
 if t.edit_step==0 then
    t.edit_step=1
 else
  return
 end 
 else
      t.edit_mode = true
   if s.selected_effect_column_index == 1 then t.edit_step=0
   elseif s.selected_effect_column_index == 0 then t.edit_step=currentstep return
   end
end
end
----------------------------------------
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
----------------------------------------

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
----------------------------------------
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

renoise.tool():add_keybinding{name="Global:Paketti:dBlue Cycle Middle Frame", invoke=function() cycle_middle_frame() end}
renoise.tool():add_keybinding{name="Global:Paketti:dBlue Cycle Upper Frame", invoke=function() cycle_upper_frame() end}
renoise.tool():add_keybinding{name="Global:Paketti:dBlue Cycle Lower Frame", invoke=function() cycle_lower_frame() end}
--------------------------------------------------------------------------------------------
require "FormulaDeviceManual"

renoise.tool():add_keybinding{name="Global:Paketti:FormulaDevice", invoke=function()  
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().tracks[renoise.song().selected_track_index]:insert_device_at("Audio/Effects/Native/*Formula", 2)  
local infile = io.open( "FormulaDeviceXML.txt", "rb" )
local indata = infile:read( "*all" )
renoise.song().tracks[renoise.song().selected_track_index].devices[2].active_preset_data = indata
infile:close()

show_manual (
    "Formula Device Documentation", -- manual dialog title
    "FormulaDevice.txt" -- the textfile which contains the manual
  )
end}


---------------------------
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

renoise.tool():add_keybinding{name="Global:Paketti:Contour Shuttle Disk Browser Focus",invoke=function() renoise.app().window:select_preset(8) end}
renoise.tool():add_midi_mapping{name="Pattern Editor:Paketti:Disk Browser Focus",invoke=function() renoise.app().window:select_preset(8) end}
------------------------------------------------------------------------------------------------
------ inspect

function writeToClipboard(text)
    -- Using AppleScript to handle clipboard operations
    local safe_text = text:gsub('"', '\\"')  -- Escape double quotes for AppleScript
    local command = 'osascript -e \'set the clipboard to "' .. safe_text .. '"\''

    -- Execute the command and check for errors
    local success, exit_code, exit_reason = os.execute(command)
    if success then
        print("Successfully copied to clipboard: " .. text)
    else
        print("Failed to copy to clipboard:", exit_reason, "(exit code " .. tostring(exit_code) .. ")")
    end
end
---------
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

----------

function delay(seconds)
    local command = "sleep " .. tonumber(seconds)
    os.execute(command)
end

-- Add keybinding and menu entry in a more compact format
renoise.tool():add_keybinding{name="Global:Paketti:∿ Squiggly Sinewave to Clipboard (macOS)", invoke=function() writeToClipboard("∿") 
writeToClipboard("∿")
writeToClipboard("∿")
writeToClipboard("∿")
delay(5)
writeToClipboard("∿") end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:∿ Squiggly Sinewave to Clipboard (macOS)", invoke=function() 
writeToClipboard("∿")
writeToClipboard("∿")
writeToClipboard("∿")
delay(5)
writeToClipboard("∿") end}

----------
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

---------------------------
function Ding()
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.enabled=true
--LFO1
--1 = Off, 2 = Sin, 3 = Saw, 4 = Pulse, 5 = Random
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.lfo1.mode=2
--LFO1 amount
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.lfo1.amount=99
--LFO1 Frequency
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.lfo1.frequency=13
--LFO1 Phase
renoise.song().instruments[renoise.song().selected_instrument_index].sample_envelopes.pitch.lfo1.phase=30
end
renoise.tool():add_menu_entry{name="Sample Editor:Ding", invoke=function() Ding() end}


