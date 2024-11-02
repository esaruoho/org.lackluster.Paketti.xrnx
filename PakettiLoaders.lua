-------------------------------------------------------------------------------------------------
-- Dump list of plugins, fx available to Terminal
renoise.tool():add_keybinding{name="Global:Paketti:AU/VST/VST3/Native Plugins/Effects Lister Dump", invoke=function()
local plugins = renoise.song().selected_instrument.plugin_properties.available_plugins
  for key, value in ipairs(plugins) do
    print(key, value)
  end
local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices
  for key, value in ipairs (devices) do 
    print(key, value)
  end end}

renoise.tool():add_keybinding{name="Global:Paketti:Dump Current Instrument parameters", invoke=function() 
local instpara = renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.plugin_device.parameters
--oprint (renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.plugin_device.parameters[26].name)
  for key, value in ipairs (instpara) do 
    print(key, value)
  end
  
  for i =1,712 do 
  oprint (i .. " " .. renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.plugin_device.parameters[i].name)
end
end}


-- Open Instrument External Editor
function inst_open_editor()
local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
local w=renoise.app().window
    if renoise.song().selected_instrument.plugin_properties.plugin_loaded==false then
    w.pattern_matrix_is_visible = false
    w.sample_record_dialog_is_visible = false
    w.upper_frame_is_visible = true
    w.lower_frame_is_visible = true
    w.active_upper_frame = 1
    w.active_middle_frame= 4
    w.active_lower_frame = 1 -- TrackDSP
    w.lock_keyboard_focus=true
    else
     if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
     end
end

renoise.tool():add_keybinding{name="Global:Paketti:Open External Editor for Plugin",invoke=function() inst_open_editor() end}
renoise.tool():add_keybinding{name="Global:Paketti:Open External Editor for Plugin (2nd)",invoke=function() inst_open_editor() end}
----------------------------------------------------------------------------------------------------
-- This sets up an AutoFilter - i.e. a LFO followed by a Filter, with the LFO affecting the Cutoff filter.
-- Simple, but effective.
function AutoFilter()
local ss=renoise.song().selected_track
local raw=renoise.app().window
raw.active_lower_frame=1
raw.lower_frame_is_visible=true
    loadnative("Audio/Effects/Native/Filter")
    loadnative("Audio/Effects/Native/*LFO")
-- TODO: but you see, if you have anything before it, it's just not gonna work. you need to make sure those are the ones that
-- were added.
  ss.devices[2].parameters[2].value=2
  ss.devices[2].parameters[3].value=1
end
renoise.tool():add_keybinding{name="Global:Paketti:Add Filter & LFO (AutoFilter)", invoke=function() AutoFilter() end}

----------------
function read_file(path)
    local file = io.open(path, "r")  -- Open the file in read mode
    if not file then
        error("File not found: " .. path)
    end
    local content = file:read("*a")  -- Read the entire content of the file into a string
    file:close()
    return content
end

-----------------------------------------------------------------------------------------------------------------------------------
function checkline(effect)
end

function instrument_is_empty(instrument)
 local s=renoise.song()
 local inst = s.instruments[instrument]
 local has_sample_data = false
 for sample in ipairs(inst.samples) do
  has_sample_data = has_sample_data or inst.samples[sample].sample_buffer.has_sample_data
 end
 if inst.plugin_properties.plugin_loaded or inst.midi_output_properties.device_name ~= "" or has_sample_data then return false else return true end
end

function search_empty_instrument()
  local proc = renoise.song()
  for empty_instrument = 1, #proc.instruments do
    local samples = false
                
      for i = 1,#proc.instruments[empty_instrument].samples do
        local temp_buffer = proc.instruments[empty_instrument].samples[i].sample_buffer
          if temp_buffer.has_sample_data then samples = true break
          end
      end
  local plugin = proc.instruments[empty_instrument].plugin_properties.plugin_loaded
  local midi_device = proc.instruments[empty_instrument].midi_output_properties.device_name
    if ((samples == false) and (plugin == false) and 
        (midi_device == nil or midi_device == "")) then
    return empty_instrument
    end
    end
   proc:insert_instrument_at(#proc.instruments+1)
  return #proc.instruments
end
------------------------------------------------------------------------------------------------------------
function LoadRhino()
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
s.selected_instrument.plugin_properties:load_plugin("Audio/Generators/AU/aumu:RNB4:VSTA")
if s.selected_instrument.plugin_properties.plugin_loaded
 then
 local pd=s.selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
 end
renoise.app().window.active_lower_frame=3
s.selected_instrument.active_tab=2 
end

renoise.tool():add_keybinding{name="Global:Paketti:Load Rhino 2.1 AU", invoke=function() LoadRhino() end}
------------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Load FabFilter One", invoke=function() renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties:load_plugin("Audio/Generators/AU/aumu:FOne:FabF")
local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true end end}
------------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Load Surge (VST)", invoke=function() renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties:load_plugin("Audio/Generators/VST/Surge")
local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true end 
 
renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
renoise.app().window.lock_keyboard_focus=true
end}
------------------------------------------------------------------------------------------------------------
function LoadZebra()
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
s.selected_instrument.plugin_properties:load_plugin("Audio/Generators/VST/Zebra2")
if s.selected_instrument.plugin_properties.plugin_loaded then
 local pd=s.selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
end
--renoise.app().window.active_lower_frame=3
renoise.app().window.active_middle_frame=3
s.selected_instrument.active_tab=2 end

renoise.tool():add_keybinding{name="Global:Paketti:Load U-He Zebra (VST)", invoke=function() LoadZebra() end}

------------------------------------------------------------------------------------------------------------
-- Function to read XML file contents
function readXMLfile(file_path)
  local file = io.open(file_path, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

-- Function to read the preset XML from the provided file path and return its contents
function providePresetXML(preset_file_path)
  local preset_xml = readXMLfile(preset_file_path)
  
  -- Check if the XML file was read successfully
  if not preset_xml or preset_xml == "" then
    renoise.app():show_warning("Failed to read preset XML or file is empty: " .. preset_file_path)
    return nil
  end
  
  return preset_xml
end

-- Example usage
function LoadPPG()
  local s = renoise.song()

local currentView = renoise.app().window.active_middle_frame

  
  -- Ensure an empty instrument slot is selected
  s.selected_instrument_index = search_empty_instrument()
  
  -- Load the plugin
  s.selected_instrument.plugin_properties:load_plugin("Audio/Generators/VST/PPG Wave 2.V")
  
  -- Check if the plugin is loaded and toggle the external editor visibility
  if s.selected_instrument.plugin_properties.plugin_loaded then
    local pd = s.selected_instrument.plugin_properties.plugin_device
    pd.external_editor_visible = not pd.external_editor_visible
    
    -- Load the preset XML file into the plugin device
    local preset_xml = providePresetXML("Presets/PPG_Arpeg.xml")
    
    if preset_xml then
      pd.active_preset_data = preset_xml
      renoise.app():show_status("Preset successfully loaded from: Presets/PPG_Arpeg.xml")
    else
      renoise.app():show_warning("Preset loading failed.")
      return
    end
  else
    renoise.app():show_warning("Failed to load the plugin.")
    return
  end
  
  -- Set the active frame and tab for the UI
  -- renoise.app().window.active_lower_frame = 3
--  renoise.app().window.active_middle_frame = 3
renoise.app().window.active_middle_frame = currentView

--  s.selected_instrument.active_tab = storedTab
  
  -- Example commented code
  -- renoise.song().selected_track.devices[checkline].parameters[1].value = 0.474 -- Mix 

  -- Example commented code
  -- loadnative("Audio/Effects/Native/*Instr. Automation")
  -- s.selected_track.devices[2].parameters[2].value = 0.0 -- delay
end
renoise.tool():add_keybinding{name="Global:Paketti:Load Waldorf PPG v2 (VST)",invoke=function() LoadPPG() end}


-----------------------------------------------------------------------------------------------------
function LoadAttack()
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
s.selected_instrument.plugin_properties:load_plugin("Audio/Generators/VST/Attack")
if s.selected_instrument.plugin_properties.plugin_loaded
 then
 local pd=s.selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
 end
renoise.app().window.active_middle_frame=3
s.selected_instrument.active_tab=2 
end
renoise.tool():add_keybinding{name="Global:Paketti:Load Waldorf Attack (VST)",invoke=function() LoadAttack() end}
-----------------------------------------------------------------------------------------------------
function loadnative(effect)
  local checkline=nil
  local s=renoise.song()
  local w=renoise.app().window

  -- Define blacklists for different track types
  local master_blacklist={"Audio/Effects/Native/*Key Tracker", "Audio/Effects/Native/*Velocity Tracker", "Audio/Effects/Native/#Send", "Audio/Effects/Native/#Multiband Send", "Audio/Effects/Native/#Sidechain"}
  local send_blacklist={"Audio/Effects/Native/*Key Tracker", "Audio/Effects/Native/*Velocity Tracker"}
  local group_blacklist={"Audio/Effects/Native/*Key Tracker", "Audio/Effects/Native/*Velocity Tracker"}
  local samplefx_blacklist={"Audio/Effects/Native/#ReWire Input", "Audio/Effects/Native/*Instr. Macros", "Audio/Effects/Native/*Instr. MIDI Control", "Audio/Effects/Native/*Instr. Automation"}

  -- Helper function to extract device name from the effect string
  local function get_device_name(effect)
    return effect:match("([^/]+)$")
  end

  -- Helper function to check if a device is in the blacklist
  local function is_blacklisted(effect, blacklist)
    for _, blacklisted in ipairs(blacklist) do
      if effect == blacklisted then
        return true
      end
    end
    return false
  end

  if w.active_middle_frame == 6 then
    w.active_middle_frame = 7
  end

  if w.active_middle_frame == 7 then
    local chain = s.selected_sample_device_chain
    local chain_index = s.selected_sample_device_chain_index

    if chain == nil or chain_index == 0 then
      s.selected_instrument:insert_sample_device_chain_at(1)
      chain = s.selected_sample_device_chain
      chain_index = 1
    end

    if chain then
      local sample_devices = chain.devices
      checkline = (table.count(sample_devices)) < 2 and 2 or (sample_devices[2] and sample_devices[2].name == "#Line Input" and 3 or 2)
      checkline = math.min(checkline, #sample_devices + 1)

      if is_blacklisted(effect, samplefx_blacklist) then
        renoise.app():show_status("The device " .. get_device_name(effect) .. " cannot be added to a Sample FX chain.")
        return
      end

      -- Adjust checkline for #Send and #Multiband Send devices
      local device_name = get_device_name(effect)
      if device_name == "#Send" or device_name == "#Multiband Send" then
        checkline = #sample_devices + 1
      end

      chain:insert_device_at(effect, checkline)
      sample_devices = chain.devices

      if sample_devices[checkline] then
        local device = sample_devices[checkline]
        if device.name == "Maximizer" then device.parameters[1].show_in_mixer = true end
        if device.name == "DC Offset" then device.parameters[2].value = 1 end
        if device.name == "#Multiband Send" then 
          device.parameters[1].show_in_mixer = false
          device.parameters[3].show_in_mixer = false
          device.parameters[5].show_in_mixer = false 
          device.active_preset_data = read_file("Presets/PakettiMultiSend.xml")
        end
        if device.name == "#Line Input" then device.parameters[2].show_in_mixer = true end
        if device.name == "#Send" then 
          device.parameters[2].show_in_mixer = false
          device.active_preset_data = read_file("Presets/PakettiSend.xml")
        end
        renoise.song().selected_sample_device_index = checkline
      end
    else
      renoise.app():show_status("No sample selected.")
    end
  else
    local sdevices = s.selected_track.devices
    checkline = (table.count(sdevices)) < 2 and 2 or (sdevices[2] and sdevices[2].name == "#Line Input" and 3 or 2)
    checkline = math.min(checkline, #sdevices + 1)

    w.lower_frame_is_visible = true
    w.active_lower_frame = 1

    local track_type = renoise.song().selected_track.type
    local device_name = get_device_name(effect)

    if track_type == 2 and is_blacklisted(effect, master_blacklist) then
      renoise.app():show_status("The device " .. device_name .. " cannot be added to a Master track.")
      return
    elseif track_type == 3 and is_blacklisted(effect, send_blacklist) then
      renoise.app():show_status("The device " .. device_name .. " cannot be added to a Send track.")
      return
    elseif track_type == 4 and is_blacklisted(effect, group_blacklist) then
      renoise.app():show_status("The device " .. device_name .. " cannot be added to a Group track.")
      return
    end

    -- Adjust checkline for #Send and #Multiband Send devices
    if device_name == "#Send" or device_name == "#Multiband Send" then
      checkline = #sdevices + 1
    end

    s.selected_track:insert_device_at(effect, checkline)
    s.selected_device_index = checkline
    sdevices = s.selected_track.devices

    if sdevices[checkline] then
      local device = sdevices[checkline]
      if device.name == "DC Offset" then device.parameters[2].value = 1 end
      if device.name == "Maximizer" then device.parameters[1].show_in_mixer = true end
      if device.name == "#Multiband Send" then 
        device.parameters[1].show_in_mixer = false
        device.parameters[3].show_in_mixer = false
        device.parameters[5].show_in_mixer = false 
        device.active_preset_data = read_file("Presets/PakettiMultiSend.xml")
      end
      if device.name == "#Line Input" then device.parameters[2].show_in_mixer = true end
      if device.name == "#Send" then 
        device.parameters[2].show_in_mixer = false
        device.active_preset_data = read_file("Presets/PakettiSend.xml")
      end
    end
  end
end





renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Analog Filter",
invoke=function() loadnative("Audio/Effects/Native/Analog Filter") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Bus Compressor",
invoke=function() loadnative("Audio/Effects/Native/Bus Compressor") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Cabinet Simulator",
invoke=function() loadnative("Audio/Effects/Native/Cabinet Simulator") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Chorus",
invoke=function() loadnative("Audio/Effects/Native/Chorus") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Chorus 2",
invoke=function() loadnative("Audio/Effects/Native/Chorus 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Comb Filter 2",
invoke=function() loadnative("Audio/Effects/Native/Comb Filter 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Compressor",
invoke=function() loadnative("Audio/Effects/Native/Compressor") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Convolver",
invoke=function() loadnative("Audio/Effects/Native/Convolver") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise DC Offset",
invoke=function() loadnative("Audio/Effects/Native/DC Offset") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Delay",
invoke=function() loadnative("Audio/Effects/Native/Delay") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Digital Filter",
invoke=function() loadnative("Audio/Effects/Native/Digital Filter") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Distortion 2",
invoke=function() loadnative("Audio/Effects/Native/Distortion 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Doofer",
invoke=function() loadnative("Audio/Effects/Native/Doofer") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise EQ 5",
invoke=function() loadnative("Audio/Effects/Native/EQ 5") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise EQ 10",
invoke=function() loadnative("Audio/Effects/Native/EQ 10") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Exciter",
invoke=function() loadnative("Audio/Effects/Native/Exciter") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Flanger 2",
invoke=function() loadnative("Audio/Effects/Native/Flanger 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Gainer",
invoke=function() loadnative("Audio/Effects/Native/Gainer") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Gate 2",
invoke=function() loadnative("Audio/Effects/Native/Gate 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise LofiMat 2",
invoke=function() loadnative("Audio/Effects/Native/LofiMat 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Maximizer",
invoke=function() loadnative("Audio/Effects/Native/Maximizer") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Mixer EQ",
invoke=function() loadnative("Audio/Effects/Native/Mixer EQ") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise mpReverb 2",
invoke=function() loadnative("Audio/Effects/Native/mpReverb 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Multitap",
invoke=function() loadnative("Audio/Effects/Native/Multitap") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Phaser 2",
invoke=function() loadnative("Audio/Effects/Native/Phaser 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Repeater",
invoke=function() loadnative("Audio/Effects/Native/Repeater") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Reverb",
invoke=function() loadnative("Audio/Effects/Native/Reverb") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise RingMod 2",
invoke=function() loadnative("Audio/Effects/Native/RingMod 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise Stereo Expander",
invoke=function() loadnative("Audio/Effects/Native/Stereo Expander") end}
------- #
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise #Line Input",
invoke=function() loadnative("Audio/Effects/Native/#Line Input") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise #Multiband Send",
invoke=function() loadnative("Audio/Effects/Native/#Multiband Send") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise #ReWire Input",
invoke=function() loadnative("Audio/Effects/Native/#ReWire Input") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise #Send",
invoke=function() loadnative("Audio/Effects/Native/#Send") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise #Sidechain", invoke=function() loadnative("Audio/Effects/Native/#Sidechain") end}
-------- *
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Formula",
invoke=function() loadnative("Audio/Effects/Native/*Formula") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Hydra",
invoke=function() loadnative("Audio/Effects/Native/*Hydra") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Instr. Automation",
invoke=function() loadnative("Audio/Effects/Native/*Instr. Automation") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Instr. Macros",
invoke=function() loadnative("Audio/Effects/Native/*Instr. Macros") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Instr. MIDI Control",
invoke=function() loadnative("Audio/Effects/Native/*Instr. MIDI Control") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Key Tracker",
invoke=function() loadnative("Audio/Effects/Native/*Key Tracker") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *LFO",
invoke=function() loadnative("Audio/Effects/Native/*LFO") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Meta Mixer",
invoke=function() loadnative("Audio/Effects/Native/*Meta Mixer") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Signal Follower",
invoke=function() loadnative("Audio/Effects/Native/*Signal Follower") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *Velocity Tracker",
invoke=function() loadnative("Audio/Effects/Native/*Velocity Tracker") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise *XY Pad",
invoke=function() loadnative("Audio/Effects/Native/*XY Pad") end}
--- Hidden / Deprecated Renoise Native Devices

renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Chorus",invoke=function() loadnative("Audio/Effects/Native/Chorus") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Comb Filter",invoke=function() loadnative("Audio/Effects/Native/Comb Filter") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Distortion",invoke=function() loadnative("Audio/Effects/Native/Distortion") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Filter",invoke=function() loadnative("Audio/Effects/Native/Filter") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Filter 2",invoke=function() loadnative("Audio/Effects/Native/Filter 2") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Filter 3",invoke=function() loadnative("Audio/Effects/Native/Filter 3") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Flanger",invoke=function() loadnative("Audio/Effects/Native/Flanger") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Gate",invoke=function() loadnative("Audio/Effects/Native/Gate") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) LofiMat",invoke=function() loadnative("Audio/Effects/Native/LofiMat") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) mpReverb",invoke=function() loadnative("Audio/Effects/Native/mpReverb") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Phaser",invoke=function() loadnative("Audio/Effects/Native/Phaser") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) RingMod",invoke=function() loadnative("Audio/Effects/Native/RingMod") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Scream Filter",invoke=function() loadnative("Audio/Effects/Native/Scream Filter") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Shaper",invoke=function() loadnative("Audio/Effects/Native/Shaper") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Renoise (Hidden) Stutter",invoke=function() loadnative("Audio/Effects/Native/Stutter") end}



------------------------------------------------------------------------------------------------------
-- Paketti-specific VST/AU EFX loading. Specific parameters set, such as:
-- Pro-Q always boots up with Pre-Post visualization on
-- TAL Reverb 4 Plugin opens with massive-ish Reverb
-- ValhallaDSP ValhallaVintageVerb opens with 50% Wet instead of 100% Wet, and a long tail
-- And each line input will become first.
function loadvst(vstname)

  local checkline=nil
  local s=renoise.song()
  local slt=s.selected_track
  local raw=renoise.app().window
  local devices=s.selected_track.devices

  if (table.count(s.selected_track.devices))<2 then checkline=2
  else 
    if s.selected_track.devices[2].name=="#Line Input" then checkline=3
    else checkline=2
    end
  end

  if raw.lower_frame_is_visible==false then raw.lower_frame_is_visible=false
  else raw.lower_frame_is_visible=true end

if raw.active_middle_frame == 6 then
raw.active_middle_frame = 7 end

if raw.active_middle_frame==7 then
  -- Check if the selected sample device chain exists, and create one if it doesn't
  local chain=s.selected_sample_device_chain
  local chain_index=s.selected_sample_device_chain_index

  if chain==nil or chain_index==0 then
    local instrument=s.selected_instrument
    instrument:insert_sample_device_chain_at(1)
    chain=s.selected_sample_device_chain
    chain_index=1
  end

  if chain then
    -- Determine the valid index for inserting the device
    if (table.count(chain.devices))<2 then checkline=2
    else 
      if chain.devices[2].name=="#Line Input" then checkline=3
      else checkline=2
      end
    end
    
    -- Ensure checkline is within the valid range
    checkline=math.min(checkline, #chain.devices + 1)

    chain:insert_device_at(vstname, checkline)
    local inserted_device=chain.devices[checkline]

    -- Insert the rest of your logic for handling the inserted device here
    if inserted_device.name=="AU: Koen Tanghe @ Smartelectronix: KTGranulator" then 
    
    return
    end
    inserted_device.external_editor_visible=true 
        inserted_device.is_maximized=false


    -- Additional device-specific parameter adjustments
    if inserted_device.name=="AU: Schaack Audio Technologies: TransientShaper" then 
      inserted_device.parameters[1].show_in_mixer=true
      inserted_device.parameters[2].show_in_mixer=true
      inserted_device.parameters[4].show_in_mixer=true
      inserted_device.parameters[7].show_in_mixer=true
      inserted_device.is_maximized=false
    end 

    if inserted_device.name=="VST: FabFilter: Pro-Q" then 
      inserted_device.parameters[206].value=1 
    end 

    if inserted_device.name=="AU: TAL-Togu Audio Line: TAL Reverb 4 Plugin" then 
      inserted_device.parameters[2].value=0.0
      inserted_device.parameters[3].value=0.30
      inserted_device.parameters[4].value=0.88
      inserted_device.parameters[5].value=0.9
      inserted_device.parameters[6].value=1
      inserted_device.parameters[7].value=0.4
      inserted_device.parameters[9].value=0.7
    end 

    if inserted_device.name=="AU: Valhalla DSP, LLC: ValhallaVintageVerb" then 
      inserted_device.parameters[1].value=0.474
      inserted_device.parameters[3].value=0.688
      inserted_device.parameters[15].value=0.097
    end 

    if inserted_device.name=="AU: Koen Tanghe @ Smartelectronix: KTGranulator" then 
      inserted_device.is_maximized=true
      inserted_device.parameters[31].value=1
      inserted_device.parameters[16].value=0.75
      inserted_device.parameters[2].value=0.50
      inserted_device.parameters[3].value=0.35
      inserted_device.parameters[6].value=0.75
      raw.lower_frame_is_visible=true
      raw.active_lower_frame=1
    end 

    if inserted_device.name=="AU: George Yohng: W1 Limiter" then
      inserted_device.is_maximized=true
      inserted_device.parameters[1].show_in_mixer=true
      inserted_device.parameters[2].show_in_mixer=true
    end
    renoise.song().selected_sample_device_index=checkline
  end
else
  -- Original functionality for selected track
  s.selected_track:insert_device_at(vstname, checkline)
  local inserted_device=s.selected_track.devices[checkline]

  if inserted_device.name=="AU: Koen Tanghe @ Smartelectronix: KTGranulator" then return
  else inserted_device.external_editor_visible=true end
  inserted_device.is_maximized=false
  renoise.song().selected_device_index=checkline

  -- Additional device-specific parameter adjustments
  if inserted_device.name=="AU: Schaack Audio Technologies: TransientShaper" then 
    inserted_device.parameters[1].show_in_mixer=true
    inserted_device.parameters[2].show_in_mixer=true
    inserted_device.parameters[4].show_in_mixer=true
    inserted_device.parameters[7].show_in_mixer=true
    inserted_device.is_maximized=false
  end 

  if inserted_device.name=="VST: FabFilter: Pro-Q" then 
    inserted_device.parameters[206].value=1 
  end 

  if inserted_device.name=="AU: TAL-Togu Audio Line: TAL Reverb 4 Plugin" then 
    inserted_device.parameters[2].value=0.0
    inserted_device.parameters[3].value=0.30
    inserted_device.parameters[4].value=0.88
    inserted_device.parameters[5].value=0.9
    inserted_device.parameters[6].value=1
    inserted_device.parameters[7].value=0.4
    inserted_device.parameters[9].value=0.7
  end 

  if inserted_device.name=="AU: Valhalla DSP, LLC: ValhallaVintageVerb" then 
    inserted_device.parameters[1].value=0.474
    inserted_device.parameters[3].value=0.688
    inserted_device.parameters[15].value=0.097
  end 

  if inserted_device.name=="AU: Koen Tanghe @ Smartelectronix: KTGranulator" then 
    inserted_device.is_maximized=true
    inserted_device.parameters[31].value=1
    inserted_device.parameters[16].value=0.75
    inserted_device.parameters[2].value=0.50
    inserted_device.parameters[3].value=0.35
    inserted_device.parameters[6].value=0.75
    raw.lower_frame_is_visible=true
    raw.active_lower_frame=1
  end 

  if inserted_device.name=="AU: George Yohng: W1 Limiter" then
    inserted_device.is_maximized=true
    inserted_device.parameters[1].show_in_mixer=true
    inserted_device.parameters[2].show_in_mixer=true
  end
end
end
--Audio/Effects/AU/aufx:cHL1:TOGU
--Audio/Effects/AU/aumf:58h8:TOGU
--73  Audio/Effects/AU/aumf:676v:TOGU
--- AU
-- Audio/Effects/AU/aufx:sdly:appl

renoise.tool():add_keybinding{name="Global:Track Devices:Load U-He Colour Copy", invoke=function() loadvst("Audio/Effects/AU/aumf:uLyr:UHfX") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Koen KTGranulator (AU)", invoke=function() loadvst("Audio/Effects/AU/aufx:KTGr:KTfx") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Uhbik U-He Runciter", invoke=function() loadvst("Audio/Effects/AU/aumf:Rc17:UHfX") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load SphereDelay Maybe?", invoke=function() loadvst("Audio/Effects/AU/aufx:SpDl:No1z") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load D16 Syntorus 2", invoke=function() loadvst("Audio/Effects/AU/aumf:Sn8R:d16g") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load D16 Toraverb", invoke=function() loadvst("Audio/Effects/AU/aufx:T4V8:d16g") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load D16 Frontier", invoke=function() loadvst("Audio/Effects/AU/aumf:FRn7:d16g") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load D16 Toraverb 2", invoke=function() loadvst("Audio/Effects/AU/aumf:T4V9:d16g") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load D16 Repeater", invoke=function() loadvst("Audio/Effects/AU/aumf:RP78:d16g") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load D16 Repeater (2nd)", invoke=function() loadvst("Audio/Effects/AU/aumf:RP78:d16g") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load George Yohng's W1 1", invoke=function() loadvst("Audio/Effects/AU/aufx:4Fwl:Yhng") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load George Yohng's W1 2", invoke=function() loadvst("Audio/Effects/AU/aufx:4FwL:4FNT") end}

renoise.tool():add_keybinding{name="Global:Track Devices:Load OhmForce Predatohm", invoke=function() loadvst("Audio/Effects/AU/aumf:Opdh:OmFo") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load OhmForce Hematohm", invoke=function() loadvst("Audio/Effects/AU/aumf:OHmt:OmFo") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load OhmForce OhmBoyz", invoke=function() loadvst("Audio/Effects/AU/aumf:OByZ:OmFo") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load QuikQuak FusionField", invoke=function() loadvst("Audio/Effects/AU/aumf:FuFi:QkQk") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load Schaack Transient Shaper (VST)", invoke=function() loadvst("Audio/Effects/VST/TransientShaper") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load FabFilter Pro-Q 3", invoke=function() loadvst("Audio/Effects/AU/aumf:FQ3p:FabF") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load FabFilter Pro-Q 3 (VST)", invoke=function() loadvst("Audio/Effects/VST/FabFilter Pro-Q 3") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TAL-Reverb 4", invoke=function() loadvst("Audio/Effects/AU/aufx:reV4:TOGU") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TAL-Dub 3 AU", invoke=function() loadvst("Audio/Effects/AU/aumf:xg70:TOGU") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TAL-Chorus LX", invoke=function() loadvst("Audio/Effects/AU/aufx:cHL1:TOGU") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TAL-Chorus", invoke=function() loadvst("Audio/Effects/AU/aufx:Chor:Togu") end}

-- ValhallaDSP (AU)
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaRoom", invoke=function() loadvst("Audio/Effects/AU/aufx:Ruum:oDin") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaShimmer", invoke=function() loadvst("Audio/Effects/AU/aufx:shmr:oDin") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaFreqEchoMkI", invoke=function() loadvst("Audio/Effects/AU/aufx:FqEh:oDin") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaDelay", invoke=function() loadvst("Audio/Effects/AU/aufx:dLay:oDin") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaVintageVerb", invoke=function() loadvst("Audio/Effects/AU/aufx:vee3:oDin") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaSpaceModulator (AU)", invoke=function() loadvst("Audio/Effects/AU/aufx:SpMd:oDi") end}
-- ValhallaDSP (VST)
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaRoom (VST)", invoke=function() loadvst("Audio/Effects/VST/ValhallaRoom") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaShimmer (VST)", invoke=function() loadvst("Audio/Effects/VST/ValhallaShimmer") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaFreqEchoMkI (VST)", invoke=function() loadvst("Audio/Effects/VST/ValhallaFreqEcho") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaDelay (VST)", invoke=function() loadvst("Audio/Effects/VST/ValhallaDelay") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaVintageVerb (VST)", invoke=function() loadvst("Audio/Effects/VST/ValhallaVintageVerb") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load ValhallaSpaceModulator (VST)", invoke=function() loadvst("Audio/Effects/VST/ValhallaSpaceModulator") end}
----------------------------------------------------------------------------------------------------------------------------------------------- VST
renoise.tool():add_keybinding{name="Global:Track Devices:Load FabFilter Pro-Q (VST)", invoke=function() loadvst("Audio/Effects/VST/FabFilter Pro-Q") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load GRM PitchAccum Stereo (VST)", invoke=function() loadvst("Audio/Effects/VST/GRM PitchAccum Stereo") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load GRM Delays Stereo (VST)", invoke=function() loadvst("Audio/Effects/VST/GRM Delays Stereo") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load GRM Reson Stereo (VST)", invoke=function() loadvst("Audio/Effects/VST/GRM Reson Stereo") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TAL-Dub 3 (VST)", invoke=function() loadvst("Audio/Effects/VST/TAL-Dub-3") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load WatKat (VST)", invoke=function() loadvst("Audio/Effects/VST/WatKat") end}
---------------------------------------------------------------------------------------
--- Combinations
renoise.tool():add_keybinding{name="Global:Track Devices:Load EQ10+Schaack Transient Shaper (VST)", invoke=function() 
loadvst("Audio/Effects/VST/TransientShaper")
loadnative("Audio/Effects/Native/EQ 10") end}

renoise.tool():add_midi_mapping{name="Track Devices:Paketti:Load DC Offset", invoke=function(message) if message:is_trigger() then 
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().selected_track:insert_device_at("Audio/Effects/Native/DC Offset",2)
renoise.song().selected_device_index=2
renoise.song().selected_track.devices[2].parameters[2].value=1
end end}


nativeDevices = {
  "Analog Filter", "Bus Compressor", "Cabinet Simulator", "Chorus", "Chorus 2",
  "Comb Filter 2", "Compressor", "Convolver", "DC Offset", "Delay", "Digital Filter",
  "Distortion 2", "Doofer", "EQ 5", "EQ 10", "Exciter", "Flanger 2", "Gainer", 
  "Gate 2", "LofiMat 2", "Maximizer", "Mixer EQ", "mpReverb 2", "Multitap",
  "Phaser 2", "Repeater", "Reverb", "RingMod 2", "Stereo Expander", "#Line Input",
  "#Multiband Send", "#ReWire Input", "#Send", "*Formula", "*Hydra", "*Instr. Automation",
  "*Instr. Macros", "*Instr. MIDI Control", "*Key Tracker", "*LFO", "*Meta Mixer",
  "*Signal Follower", "*Velocity Tracker", "*XY Pad"
}

nativeDeprecatedDevices = {
  "Chorus", "Comb Filter", "Distortion", "Filter", "Filter 2", "Filter 3", 
  "Flanger", "Gate", "LofiMat", "mpReverb", "Phaser", "RingMod", "Scream Filter", 
  "Shaper", "Stutter"
}

-- Generate menu entries for native devices
for i, device in ipairs(nativeDevices) do
  local device_path = "Audio/Effects/Native/" .. device:gsub(" ", " ")
  renoise.tool():add_menu_entry{
    name = "DSP Device:Paketti..:Load Renoise Native:" .. device, 
    invoke = function() loadnative(device_path) end
  }
end

for i, device in ipairs(nativeDevices) do
  local device_path = "Audio/Effects/Native/" .. device:gsub(" ", " ")
  renoise.tool():add_menu_entry{
    name = "Mixer:Paketti..:Load Renoise Native:" .. device, 
    invoke = function() loadnative(device_path) end
  }
end

-- Generate menu entries for deprecated devices
for i, device in ipairs(nativeDeprecatedDevices) do
  local device_path = "Audio/Effects/Native/" .. device:gsub(" ", " ")
  local separator = i == 1 and "-- " or ""
  renoise.tool():add_menu_entry{
    name = separator .. "DSP Device:Paketti..:Load Renoise Native:(Hidden) " .. device, 
    invoke = function() loadnative(device_path) end
  }
end

for i, device in ipairs(nativeDeprecatedDevices) do
  local device_path = "Audio/Effects/Native/" .. device:gsub(" ", " ")
  local separator = i == 1 and "-- " or ""
  renoise.tool():add_menu_entry{
    name = separator .. "Mixer:Paketti..:Load Renoise Native:(Hidden) " .. device, 
    invoke = function() loadnative(device_path) end
  }
end



--renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:writeToClipboard",invoke=function() 
--writeToClipboard(for key, value in ipairs (devices) do  print(key, value)
--end}

--renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Dump VST/AU/Native Effects to Clipboard", invoke=function() 



--) end}

----------------------
function OpenSelectedEffectExternalEditor()
local s=renoise.song()
local devices=s.selected_track.devices
if not devices[s.selected_device_index].external_editor_visible then
       devices[s.selected_device_index].external_editor_visible=true
  else devices[s.selected_device_index].external_editor_visible=false
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Open External Editor of Selected Effect",invoke=function() OpenSelectedEffectExternalEditor() end}
-----------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Hide Track DSP Device External Editors",invoke=function()

  -- Function to hide all devices in a given device chain
  local function hide_devices(device_chain)
    if #device_chain.devices > 1 then
      for i = 2, #device_chain.devices do
        if device_chain.devices[i].external_editor_available == true then
          device_chain.devices[i].external_editor_visible = false
        end
      end
    end
  end

  -- Hide track devices if there are any
  if renoise.song().selected_track and #renoise.song().selected_track.devices > 1 then
    hide_devices(renoise.song().selected_track)
  end

  -- Hide sample effect chains for the selected instrument if there are any
  local instrument = renoise.song().selected_instrument
  if instrument and #instrument.sample_device_chains > 0 then
    for _, device_chain in ipairs(instrument.sample_device_chains) do
      if #device_chain.devices > 1 then
        hide_devices(device_chain)
      end
    end
  end

  -- Hide plugin device editor if present
  if instrument and instrument.plugin_properties.plugin_device then
    local pd = instrument.plugin_properties.plugin_device
    if pd.external_editor_available == true then
      pd.external_editor_visible = false
    end
  end

end}

--------------------------
-- Function to inspect the selected plugin
function inspectPlugin()
  local s = renoise.song()
  local plugin = s.selected_instrument.plugin_properties.plugin_device

  -- Check if there is a plugin in the selected instrument
  if not plugin then
    renoise.app():show_status("No plugin in this instrument")
    return
  end

  -- Iterate over the plugin parameters and print their details
  for i = 1, #plugin.parameters do
    oprint(
      plugin.name .. ": " .. i .. ": " .. plugin.parameters[i].name .. ": " ..
      "renoise.song().selected_instrument.plugin_properties.plugin_device.parameters[" .. i .. "].value=" .. plugin.parameters[i].value
    )
  end
end

-- Adding keybinding for the inspectPlugin function
renoise.tool():add_keybinding{name="Global:Paketti:Inspect Plugin", invoke=function() inspectPlugin() end}

-- Function to inspect the effect in device slot 2
function inspectEffect()
  local devices = renoise.song().selected_track.devices

  -- Check if there is an effect in device slot 2
  if not devices[2] then
    renoise.app():show_status("No effect in device slot 2")
    return
  end

  -- Print details of the effect in device slot 2
  oprint("Effect Displayname: " .. devices[2].display_name)
  oprint("Effect Name: " .. devices[2].name)
  oprint("Effect Path: " .. devices[2].device_path)

  -- Iterate over the effect parameters and print their details
  for i = 1, #devices[2].parameters do
    oprint(
      devices[2].name .. ": " .. i .. ": " .. devices[2].parameters[i].name .. ": " ..
      "renoise.song().selected_track.devices[2].parameters[" .. i .. "].value=" .. devices[2].parameters[i].value
    )
  end
end

-- Adding keybinding for the inspectEffect function
renoise.tool():add_keybinding{name="Global:Paketti:Inspect Device in Slot 2", invoke=function() inspectEffect() end}
------------------------------------------------------------------------------------------------------
-- Add the menu entry to show plugin details
-- Add the menu entry to show plugin details
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices..:Debug..:Show Plugin Details",invoke=function() show_plugin_details_gui() end}

-- Declare the customdialog variable at the beginning
customdialog = nil

-- Utility function to fetch, sort, and group available plugins by type
function get_sorted_and_grouped_plugin_infos()
  local audio_units = {}
  local vsts = {}
  local vst3s = {}
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if instrument.plugin_properties and #instrument.plugin_properties.available_plugin_infos > 0 then
    for _, plugin_info in ipairs(instrument.plugin_properties.available_plugin_infos) do
      local plugin_type = determine_plugin_type(plugin_info.path)
      local entry = {
        name=plugin_type .. ": " .. (plugin_info.name or "Unnamed Plugin"),
        details = plugin_info
      }
      if plugin_type == "AU" then
        table.insert(audio_units, entry)
      elseif plugin_type == "VST3" then
        table.insert(vst3s, entry)
      else
        table.insert(vsts, entry)
      end
    end
  end

  -- Sort each group alphabetically by name
  local sorter = function(a, b) return a.name < b.name end
  table.sort(audio_units, sorter)
  table.sort(vsts, sorter)
  table.sort(vst3s, sorter)

  -- Combine groups in order: Audio Units, VSTs, VST3s
  return table_concat(audio_units, vsts, vst3s)
end

-- Utility function to determine plugin type from path
function determine_plugin_type(path)
  if path and path:lower():find("/au/") then
    return "AU"
  elseif path and path:lower():find("/vst3/") then
    return "VST3"
  elseif path and path:lower():find("/vst/") then
    return "VST"
  else
    return "Unknown Type"
  end
end

-- Utility function to concatenate tables
function table_concat(...)
  local result = {}
  for _, list in ipairs({...}) do
    for _, v in ipairs(list) do
      table.insert(result, v)
    end
  end
  return result
end

-- Function to display selected plugin details
function display_selected_plugin_details(index, available_plugin_infos)
  local plugin_info = available_plugin_infos[index - 1]  -- Adjust for the placeholder
  if plugin_info then
    local details = {
      "Name: " .. plugin_info.details.name,
      "Path: " .. plugin_info.details.path,
      "Favorite: " .. (plugin_info.details.is_favorite and "Yes" or "No")
    }
    return table.concat(details, "\n")
  else
    return "Please select a plugin to see details."
  end
end

-- Function to show the plugin details GUI
function show_plugin_details_gui()
  local vb = renoise.ViewBuilder()
  local available_plugin_infos = get_sorted_and_grouped_plugin_infos()

  local dialog_content = vb:column {
    margin = 10,
    spacing = 5,
    vb:row {
      vb:column {
        width = 300,
        vb:text {
          text = "Available Plugins:"
        },
        vb:popup {
          id = "plugins_list",
          items = {"--Select a Plugin--"}, -- Placeholder at index 1
          width = 300,
          notifier = function(index)
            vb.views.plugin_details.text = display_selected_plugin_details(index, available_plugin_infos)
          end
        }
      },
      vb:column {
        spacing = 5,
        vb:text {
          text = "Plugin Details:"
        },
        vb:multiline_textfield {
          id = "plugin_details",
          text = "After you select a Plugin Instrument, you will get some additional data here for said Plugin.", -- Default text
          font = "mono",
          width = 400,
          height = 300
        },
      },
    },
    vb:button {
      text = "Close",
      released = function()
        if customdialog and customdialog.visible then
          customdialog:close()
        end
      end
    }
  }

  -- Fetch and sort plugin infos, then update the popup list
  local popup_items = vb.views.plugins_list.items
  for _, plugin_info in ipairs(available_plugin_infos) do
    table.insert(popup_items, plugin_info.name)
  end
  vb.views.plugins_list.items = popup_items

  -- Dialog management
  customdialog = renoise.app():show_custom_dialog("Plugin Details", dialog_content, myPluginDetailskeyhandlerfunc)
end

function myPluginDetailskeyhandlerfunc(dialog,key)

local closer = preferences.pakettiDialogClose.value
  if key.modifiers == "" and key.name == closer then
dialog:close()
dialog=nil
return nil
else

    return key
end
end

-----

-- Add the menu entry to show effect details
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices..:Debug..:Show Effect Details",invoke=function() show_effect_details_gui() end}

-- Declare the customdialog variable at the beginning
customdialog = nil

-- Utility function to fetch, sort, and group available device effects by type
function get_sorted_and_grouped_device_infos()
  local audio_units = {}
  local vsts = {}
  local vst3s = {}
  local unique_devices = {}
  local tracks = renoise.song().tracks

  for _, track in ipairs(tracks) do
    for _, device_info in ipairs(track.available_device_infos) do
      if not unique_devices[device_info.name .. device_info.path] and not device_info.path:lower():find("/native/") then
        unique_devices[device_info.name .. device_info.path] = true
        local device_type = determine_device_type(device_info.path)
        local entry = {
          name = device_type .. ": " .. (device_info.name or "Unnamed Device"),
          details = device_info
        }
        if device_type == "AU" then
          table.insert(audio_units, entry)
        elseif device_type == "VST3" then
          table.insert(vst3s, entry)
        else
          table.insert(vsts, entry)
        end
      end
    end
  end

  -- Sort each group alphabetically by name
  local sorter = function(a, b) return a.name < b.name end
  table.sort(audio_units, sorter)
  table.sort(vsts, sorter)
  table.sort(vst3s, sorter)

  -- Combine groups in order: Audio Units, VSTs, VST3s
  return table_concat(audio_units, vsts, vst3s)
end

-- Utility function to determine device type from path
function determine_device_type(path)
  if path and path:lower():find("/au/") then
    return "AU"
  elseif path and path:lower():find("/vst3/") then
    return "VST3"
  elseif path and path:lower():find("/vst/") then
    return "VST"
  else
    return "Unknown Type"
  end
end

-- Utility function to concatenate tables
function table_concat(...)
  local result = {}
  for _, list in ipairs({...}) do
    for _, v in ipairs(list) do
      table.insert(result, v)
    end
  end
  return result
end

-- Function to display selected device details
function display_selected_device_details(index, available_device_infos)
  local device_info = available_device_infos[index]  -- Use the correct index without adjustment
  if device_info then
    local details = {
      "Name: " .. device_info.details.name,
      "Path: " .. device_info.details.path,
      "Bridged: " .. (device_info.details.is_bridged and "Yes" or "No"),
      "Favorite: " .. (device_info.details.is_favorite and "Yes" or "No")
    }
    return table.concat(details, "\n")
  else
    return "Please select a device to see details."
  end
end

-- Function to show the effect details GUI
function show_effect_details_gui()
  local vb = renoise.ViewBuilder()
  local available_device_infos = get_sorted_and_grouped_device_infos()
  local device_names = {}
  for _, info in ipairs(available_device_infos) do
    table.insert(device_names, info.name)
  end

  local dialog_content = vb:column {
    margin = 10,
    spacing = 5,
    vb:row {
      vb:column {
        width = 300,
        vb:text {
          text = "Available Devices:"
        },
        vb:popup {
          id = "devices_list",
          items = {"--Select a Device--", unpack(device_names)},
          width = 300,
          notifier = function(index)
            vb.views.device_details.text = display_selected_device_details(index - 1, available_device_infos)
          end
        }
      },
      vb:column {
        spacing = 5,
        vb:text {
          text = "Device Details:"
        },
        vb:multiline_textfield {
          id = "device_details",
          text = "Select a Device to see its details.", -- Default text
          font = "mono",
          width = 400,
          height = 300
        }
      },
    },
    vb:button {
      text = "Close",
      released = function()
        if customdialog and customdialog.visible then
          customdialog:close()
        end
      end
    }
  }

  -- Show dialog
  customdialog = renoise.app():show_custom_dialog("Effect Details", dialog_content)
end


-- Modulation Device Loader Shortcut Generator
local moddevices = {
  "AHDSR", "Envelope", "Fader", "Key Tracking", "LFO", "Operand", "Stepper", "Velocity Tracking"}

local modtargets = {
  {name= "01 Volume", target = renoise.SampleModulationDevice.TARGET_VOLUME},
  {name= "02 Panning", target = renoise.SampleModulationDevice.TARGET_PANNING},
  {name= "03 Pitch", target = renoise.SampleModulationDevice.TARGET_PITCH},
  {name= "04 Cutoff", target = renoise.SampleModulationDevice.TARGET_CUTOFF},
  {name= "05 Resonance", target = renoise.SampleModulationDevice.TARGET_RESONANCE},
  {name= "06 Drive", target = renoise.SampleModulationDevice.TARGET_DRIVE}}

function loadModulationDevice(devicename, device_target)
  local song = renoise.song()
  local instrument = song.selected_instrument
  local sample_index = song.selected_sample_index
  local mod_set_index

  if #instrument.samples < 1 then
    instrument:insert_sample_at(1)
    sample_index = 1
  end


  local w = renoise.app().window
  w.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION
  
  local i = renoise.song().selected_instrument_index
  local mod_set_index = renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].modulation_set_index
  local insert_index = 1
  
if renoise.song().instruments[renoise.song().selected_instrument_index].sample_modulation_sets[renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].modulation_set_index].filter_type == "None" then  
  
if device_target == renoise.SampleModulationDevice.TARGET_CUTOFF or device_target == renoise.SampleModulationDevice.TARGET_RESONANCE or device_target == renoise.SampleModulationDevice.TARGET_DRIVE
then renoise.song().instruments[renoise.song().selected_instrument_index].sample_modulation_sets[renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].modulation_set_index].filter_type="LP Clean"
else end
else end

  renoise.song().instruments[i].sample_modulation_sets[renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].modulation_set_index]:insert_device_at(
    "Modulation/" .. devicename, device_target, insert_index)
renoise.song().selected_sample_modulation_set.devices[1].operator=1
end

for _, device in ipairs(moddevices) do
  for _, target in ipairs(modtargets) do
    local keybinding_name=string.format("Global:Paketti:Load Modulation Device (%s) %s", target.name, device)
    renoise.tool():add_keybinding{name=keybinding_name, invoke = function() loadModulationDevice(device, target.target)
      end
    }
  end
end
local targets = {
  {number = "01", display = "Volume", target = renoise.SampleModulationDevice.TARGET_VOLUME},
  {number = "02", display = "Panning", target = renoise.SampleModulationDevice.TARGET_PANNING},
  {number = "03", display = "Pitch", target = renoise.SampleModulationDevice.TARGET_PITCH},
  {number = "04", display = "Cutoff", target = renoise.SampleModulationDevice.TARGET_CUTOFF},
  {number = "05", display = "Resonance", target = renoise.SampleModulationDevice.TARGET_RESONANCE},
  {number = "06", display = "Drive", target = renoise.SampleModulationDevice.TARGET_DRIVE}
}
-- Generate menu entries dynamically with numbering and structure
for _, target in ipairs(targets) do
  for _, device in ipairs(moddevices) do
    -- Check if target.display and device are not nil
    if target.display and device then
      local menu_entry_name = string.format("Sample Modulation Matrix:Paketti..:%s %s:%s", target.number, target.display, device)
      renoise.tool():add_menu_entry{
        name = menu_entry_name,
        invoke = function()
          loadModulationDevice(device, target.target)
          
        end
      }
    else
     -- print("Error: Missing display name or device for target")
    end
  end
end

for _, target in ipairs(targets) do
  for _, device in ipairs(moddevices) do
    -- Check if target.display and device are not nil
    if target.display and device then
      local menu_entry_name = string.format("Modulation Set:Paketti..:%s %s:%s", target.number, target.display, device)
      renoise.tool():add_menu_entry{
        name = menu_entry_name,
        invoke = function()
          loadModulationDevice(device, target.target)
        end
      }
    else
      print("Error: Missing display name or device for target")
    end
  end
end

renoise.tool():add_menu_entry{name="Modulation Matrix:Paketti..:Bla",invoke= function() jaa() end}

--------------
function exposeHideParametersInMixer()

if renoise.song().selected_device == nil then return else
local parameterCount=#renoise.song().selected_device.parameters

if renoise.song().selected_device.parameters[1].show_in_mixer == true then

for i=1,parameterCount do
  renoise.song().selected_device.parameters[i].show_in_mixer=false
end
else 
for i=1,parameterCount do
  renoise.song().selected_device.parameters[i].show_in_mixer=true
end
end
end
end
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices..:Expose/Hide Selected Device Parameters in Mixer",invoke = function() exposeHideParametersInMixer() end}
renoise.tool():add_menu_entry{name="--Mixer:Paketti..:Expose/Hide Selected Device Parameters",invoke = function() exposeHideParametersInMixer() end}
renoise.tool():add_keybinding{name="Global:Paketti:Expose/Hide Selected Device Parameters in Mixer", invoke=function() exposeHideParametersInMixer() end}  

function exposeHideAllParametersInMixer()

--#renoise.song().selected_track.devices
if #renoise.song().selected_track.devices == 1 then return
else
if renoise.song().selected_track.devices[2].parameters[1].show_in_mixer == true
then 
for i=2,#renoise.song().selected_track.devices do
for y=1,#renoise.song().selected_track.devices[i].parameters do
renoise.song().selected_track.devices[i].parameters[y].show_in_mixer=false
end
end

else
for i=2,#renoise.song().selected_track.devices do
for y=1,#renoise.song().selected_track.devices[i].parameters do
renoise.song().selected_track.devices[i].parameters[y].show_in_mixer=true
end
end
end
end
end
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices..:Expose/Hide Selected Track ALL Device Parameters",invoke = function() exposeHideParametersInMixer() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Expose/Hide Selected Track ALL Device Parameters",invoke = function() exposeHideAllParametersInMixer() end}
renoise.tool():add_keybinding{name="Global:Paketti:Expose/Hide Selected Track ALL Device Parameters", invoke=function() exposeHideParametersInMixer() end}  


--[[
function launchApp(appName)
os.execute(appName)
end

function terminalApp(scriptPath)
 local command = 'open -a Terminal "' .. scriptPath .. '"'
    os.execute(command)
end

renoise.tool():add_menu_entry{name="Disk Browser Files:Paketti..:Run Experimental Script",invoke=function() terminalApp("/Users/esaruoho/macOS_EnableScriptingTools.sh") end}
renoise.tool():add_menu_entry{name="Disk Browser Files:Paketti..:Open macOS Terminal",invoke=function() launchApp("open -a Terminal.app") end}
]]--

function effectbypass()
local number = (table.count(renoise.song().selected_track.devices))
for i=2,number do renoise.song().selected_track.devices[i].is_active=false
 end
 renoise.app():show_status("Disabled all Track DSP Devices on Selected Track")
end

function effectenable()
local number = (table.count(renoise.song().selected_track.devices))
for i=2,number do renoise.song().selected_track.devices[i].is_active=true
end
renoise.app():show_status("Enabled all Track DSP Devices on Selected Track")
end

renoise.tool():add_keybinding{name="Global:Paketti:Bypass All Devices on Track", invoke=function() effectbypass() end}
renoise.tool():add_keybinding{name="Global:Paketti:Enable All Devices on Track", invoke=function() effectenable() end}

renoise.tool():add_menu_entry{name="--Mixer:Paketti..:Bypass All Devices on Track", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Enable All Devices on Track", invoke=function() effectenable() end}
renoise.tool():add_menu_entry {name="Mixer:Paketti..:Bypass All Devices on All Tracks",invoke=function() PakettiAllDevices(false) end}
renoise.tool():add_menu_entry {name="Mixer:Paketti..:Enable All Devices on All Tracks",invoke=function() PakettiAllDevices(true) end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Bypass/Enable All Other Track DSP Devices (Toggle)",invoke=function() toggle_bypass_selected_device() end}
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Devices..:Bypass All Devices on Track", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Devices..:Enable All Devices on Track", invoke=function() effectenable() end}


function PakettiAllDevices(state)
  local song = renoise.song()
  local total_tracks = song.sequencer_track_count + 1 + song.send_track_count

  for i = 1, total_tracks do
    local track = song.tracks[i]
    if #track.devices > 1 then
      for j = 2, #track.devices do
        track.devices[j].is_active = state
      end
    end
  end

  local status_message = state and "Enabled" or "Bypassed"
  renoise.app():show_status("All devices " .. status_message .. " from device[2] onward for all tracks")
end

renoise.tool():add_keybinding {name="Global:Paketti:Bypass All Devices on All Tracks",invoke=function() PakettiAllDevices(false) end}
renoise.tool():add_keybinding {name="Global:Paketti:Enable All Devices on All Tracks",invoke=function() PakettiAllDevices(true) end}

renoise.tool():add_midi_mapping {name="Paketti:Bypass All Devices on All Tracks",invoke=function(message) if message:is_trigger() then PakettiAllDevices(false) end end}
renoise.tool():add_midi_mapping {name="Paketti:Enable All Devices on All Tracks",invoke=function(message) if message:is_trigger() then PakettiAllDevices(true) end end}

renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Bypass All Devices on All Tracks",invoke=function() PakettiAllDevices(false) end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Enable All Devices on All Tracks",invoke=function() PakettiAllDevices(true) end}


-- Utility function to print a formatted list from the provided items
function printItems(items)
    -- Sort items alphabetically by name
    table.sort(items, function(a, b) return a.name < b.name end)
    for _, item in ipairs(items) do
        print(item.name .. ": " .. item.path)
    end
end

-- Function to list available plugins by type
function listAvailablePluginsByType(typeFilter)
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
function listByPluginType(typeFilter)
    print(typeFilter .. " Plugins:")
    listAvailablePluginsByType(typeFilter)
end


-- Function to list devices (effects) by type, remains unchanged as it's working correctly
function listDevicesByType(typeFilter)
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

function insertMonoToEnd()
    local track = renoise.song().selected_track
    local mono_device_index = nil

    -- Check for existing "Mono" device in the track
    for i = 2, #track.devices do
        if track.devices[i].display_name == "Mono" then
            mono_device_index = i
            break
        end
    end

    if mono_device_index then
        -- Check if Mono is at the end
        if mono_device_index == #track.devices then
            -- Toggle Mono device state
            local mono_device = track:device(mono_device_index)
            mono_device.is_active = not mono_device.is_active
            print("Mono device at the end is now " .. (mono_device.is_active and "on" or "off"))
        else
            -- Insert Gainer device at the end
            print("Inserting Gainer at the end")
            track:insert_device_at("Audio/Effects/Native/Gainer", #track.devices + 1)
            print("Gainer inserted at the end")

            -- Swap Mono device with Gainer device
            print("Swapping Mono device at position " .. mono_device_index .. " with Gainer at the end")
            track:swap_devices_at(mono_device_index, #track.devices)
            print("Swap completed")

            -- Remove the Gainer device which is now at the original mono_device_index position
            print("Removing Gainer device at position " .. mono_device_index)
            track:delete_device_at(mono_device_index)
            print("Gainer device removed")
        end
    else
        -- Insert Mono device at the end
        print("No Mono device found, inserting Mono at the end")
        local mono_device = track:insert_device_at("Audio/Effects/Native/Stereo Expander", #track.devices + 1)
        mono_device.display_name = "Mono"
        mono_device.parameters[1].value = 0
        mono_device.is_maximized = false
        print("Mono device inserted at the end")
    end

    -- Select the Mono device
    for i = 2, #track.devices do
        if track.devices[i].display_name == "Mono" then
            renoise.song().selected_track_device_index = i
            print("Mono device selected at position " .. i)
            break
        end
    end
end

function insertMonoToBeginning()
    local track = renoise.song().selected_track
    local mono_device_index = nil

    -- Check for existing "Mono" device in the track
    for i = 2, #track.devices do
        if track.devices[i].display_name == "Mono" then
            mono_device_index = i
            break
        end
    end

    if mono_device_index then
        -- Check if Mono is at the beginning
        if mono_device_index == 2 then
            -- Toggle Mono device state
            local mono_device = track:device(mono_device_index)
            mono_device.is_active = not mono_device.is_active
            print("Mono device at the beginning is now " .. (mono_device.is_active and "on" or "off"))
        else
            -- Insert Gainer device at position 2
            print("Inserting Gainer at position 2")
            local gainer_device = track:insert_device_at("Audio/Effects/Native/Gainer", 2)
            print("Gainer inserted at position 2")

            -- Adjust Mono device index after insertion
            if mono_device_index > 2 then
                mono_device_index = mono_device_index + 1
            end

            -- Swap Mono device with Gainer device
            print("Swapping Mono device at position " .. mono_device_index .. " with Gainer at position 2")
            track:swap_devices_at(mono_device_index, 2)
            print("Swap completed")

            -- Remove the Gainer device which is now at the original mono_device_index position
            print("Removing Gainer device at position " .. mono_device_index)
            track:delete_device_at(mono_device_index)
            print("Gainer device removed")
        end
    else
        -- Insert Mono device at position 2
        print("No Mono device found, inserting Mono at position 2")
        local mono_device = track:insert_device_at("Audio/Effects/Native/Stereo Expander", 2)
        mono_device.display_name = "Mono"
        mono_device.parameters[1].value = 0
        mono_device.is_maximized = false
        print("Mono device inserted at position 2")
    end

    -- Select the Mono device
    for i = 2, #track.devices do
        if track.devices[i].display_name == "Mono" then
            renoise.song().selected_track_device_index = i
            print("Mono device selected at position " .. i)
            break
        end
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Insert Stereo -> Mono device to Beginning of DSP Chain",invoke=function() insertMonoToBeginning() end}
renoise.tool():add_keybinding{name="Global:Paketti:Insert Stereo -> Mono device to End of DSP Chain",invoke=function() insertMonoToEnd() end}


function insertMonoToMasterEnd()
    local track = renoise.song().tracks[renoise.song().sequencer_track_count+1]
    local mono_device_index = nil

    -- Check for existing "Mono" device in the track
    for i = 2, #track.devices do
        if track.devices[i].display_name == "Mono" then
            mono_device_index = i
            break
        end
    end

    if mono_device_index then
        -- Check if Mono is at the end
        if mono_device_index == #track.devices then
            -- Toggle Mono device state
            local mono_device = track:device(mono_device_index)
            mono_device.is_active = not mono_device.is_active
            print("Mono device at the end is now " .. (mono_device.is_active and "on" or "off"))
        else
            -- Insert Gainer device at the end
            print("Inserting Gainer at the end")
            track:insert_device_at("Audio/Effects/Native/Gainer", #track.devices + 1)
            print("Gainer inserted at the end")

            -- Swap Mono device with Gainer device
            print("Swapping Mono device at position " .. mono_device_index .. " with Gainer at the end")
            track:swap_devices_at(mono_device_index, #track.devices)
            print("Swap completed")

            -- Remove the Gainer device which is now at the original mono_device_index position
            print("Removing Gainer device at position " .. mono_device_index)
            track:delete_device_at(mono_device_index)
            print("Gainer device removed")
        end
    else
        -- Insert Mono device at the end
        print("No Mono device found, inserting Mono at the end")
        local mono_device = track:insert_device_at("Audio/Effects/Native/Stereo Expander", #track.devices + 1)
        mono_device.display_name = "Mono"
        mono_device.parameters[1].value = 0
        mono_device.is_maximized = false
        print("Mono device inserted at the end")
    end

    -- Select the Mono device
    for i = 2, #track.devices do
        if track.devices[i].display_name == "Mono" then
            print("Mono device selected at position Master")
            break
        end
    end
end

function insertMonoToMasterBeginning()
    local track = renoise.song().tracks[renoise.song().sequencer_track_count+1]
    local mono_device_index = nil

    -- Check for existing "Mono" device in the track
    for i = 2, #track.devices do
        if track.devices[i].display_name == "Mono" then
            mono_device_index = i
            break
        end
    end

    if mono_device_index then
        -- Check if Mono is at the beginning
        if mono_device_index == 2 then
            -- Toggle Mono device state
            local mono_device = track:device(mono_device_index)
            mono_device.is_active = not mono_device.is_active
            print("Mono device at the beginning is now " .. (mono_device.is_active and "on" or "off"))
        else
            -- Insert Gainer device at position 2
            print("Inserting Gainer at position 2")
            local gainer_device = track:insert_device_at("Audio/Effects/Native/Gainer", 2)
            print("Gainer inserted at position 2")

            -- Adjust Mono device index after insertion
            if mono_device_index > 2 then
                mono_device_index = mono_device_index + 1
            end

            -- Swap Mono device with Gainer device
            print("Swapping Mono device at position " .. mono_device_index .. " with Gainer at position 2")
            track:swap_devices_at(mono_device_index, 2)
            print("Swap completed")

            -- Remove the Gainer device which is now at the original mono_device_index position
            print("Removing Gainer device at position " .. mono_device_index)
            track:delete_device_at(mono_device_index)
            print("Gainer device removed")
        end
    else
        -- Insert Mono device at position 2
        print("No Mono device found, inserting Mono at position 2")
        local mono_device = track:insert_device_at("Audio/Effects/Native/Stereo Expander", 2)
        mono_device.display_name = "Mono"
        mono_device.parameters[1].value = 0
        mono_device.is_maximized = false
        print("Mono device inserted at position 2")
    end

    -- Select the Mono device
    for i = 2, #track.devices do
        if track.devices[i].display_name == "Mono" then
            print("Mono device selected at Master")
            break
        end
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Insert Stereo -> Mono device to Beginning of Master",invoke=function() insertMonoToMasterBeginning() end}
renoise.tool():add_keybinding{name="Global:Paketti:Insert Stereo -> Mono device to End of Master",invoke=function() insertMonoToMasterEnd() end}


-- Function to hide all visible external editors of Devices
function hide_all_external_editors()
  local song = renoise.song()
  local num_tracks = #song.tracks
  local num_instruments = #song.instruments

  local any_editor_closed = false

  -- Hide external editors for all track devices
  for track_index = 1, num_tracks do
    local track = song:track(track_index)
    local num_devices = #track.devices

    for device_index = 2, num_devices do
      local device = track:device(device_index)

      if device.external_editor_available and device.external_editor_visible then
        device.external_editor_visible = false
        any_editor_closed = true
      end
    end
  end

  -- Hide external editors for all instrument plugins
  for instrument_index = 1, num_instruments do
    local instrument = song:instrument(instrument_index)
    
    -- Hide sample effect chain devices
    for _, device_chain in ipairs(instrument.sample_device_chains) do
      for device_index = 2, #device_chain.devices do
        local device = device_chain:device(device_index)
        
        if device.external_editor_available and device.external_editor_visible then
          device.external_editor_visible = false
          any_editor_closed = true
        end
      end
    end
    
    -- Hide plugin device editor
    if instrument.plugin_properties.plugin_device then
      local plugin_device = instrument.plugin_properties.plugin_device
      if plugin_device.external_editor_available and plugin_device.external_editor_visible then
        plugin_device.external_editor_visible = false
        any_editor_closed = true
      end
    end
  end

  if any_editor_closed then
    renoise.app():show_status("All open External Editors for Track DSP & Sample FX Chain Devices have been closed.")
  else
    renoise.app():show_status("No Track DSP or Sample FX Chain Device External Editors were open, did nothing.")
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Hide Track DSP Device External Editors for All Tracks",invoke=function() hide_all_external_editors() end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices..:Hide Track DSP Device External Editors for All Tracks",invoke=function() hide_all_external_editors() end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices..:Bypass All Devices on Track", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices..:Enable All Devices on Track", invoke=function() effectenable() end}


renoise.tool():add_midi_mapping{name="Paketti:Hide Track DSP Device External Editors for All Tracks",invoke=function(message) if message:is_trigger() then  hide_all_external_editors() end end}

---------
-- Table to keep track of added menu entries
local added_menu_entries = {}

-- Global function to launch the applications
function appSelectionLaunchApp(app_path)
  local os_name = os.platform()
  local command

  if os_name == "WINDOWS" then
    command = 'start "" "' .. app_path .. '"'
  elseif os_name == "MACINTOSH" then
    command = 'open -a "' .. app_path .. '"'
  else
    command = 'exec "' .. app_path .. ' &"'
  end

  os.execute(command)
  renoise.app():show_status("Launched app " .. app_path:match("([^/\\]+)%.app$"))
end

-- Function to remove existing menu entries
function appSelectionRemoveMenuEntries()
  for _, entry in ipairs(added_menu_entries) do
    if renoise.tool():has_menu_entry(entry) then
      renoise.tool():remove_menu_entry(entry)
    end
  end
  -- Clear the tracking table
  added_menu_entries = {}
end
function appSelectionCreateMenuEntries()
  local preferences = renoise.tool().preferences
  local app_selections = {
    preferences.AppSelection.AppSelection1 and preferences.AppSelection.AppSelection1.value or "",
    preferences.AppSelection.AppSelection2 and preferences.AppSelection.AppSelection2.value or "",
    preferences.AppSelection.AppSelection3 and preferences.AppSelection.AppSelection3.value or "",
    preferences.AppSelection.AppSelection4 and preferences.AppSelection.AppSelection4.value or "",
    preferences.AppSelection.AppSelection5 and preferences.AppSelection.AppSelection5.value or "",
    preferences.AppSelection.AppSelection6 and preferences.AppSelection.AppSelection6.value or ""
  }

  local apps_present = false

  -- Create menu entries for each app selection
  for i, app_path in ipairs(app_selections) do
    if app_path ~= "" then
      apps_present = true
--      local app_name = app_path:match("([^/\\]+)%.app$")
local app_name = app_path:match("([^/\\]+)%.app$") or app_path:match("([^/\\]+)$")
      local menu_entry_name = "Instrument Box:Paketti..:Launch App..:Launch App "..i.." "..app_name
      if not renoise.tool():has_menu_entry(menu_entry_name) then
        renoise.tool():add_menu_entry{name=menu_entry_name, invoke=function() appSelectionLaunchApp(app_path) end}
        table.insert(added_menu_entries, menu_entry_name)
      end

      menu_entry_name = "Main Menu:Tools:Paketti..:Launch App..:Launch App "..i.." "..app_name
      if not renoise.tool():has_menu_entry(menu_entry_name) then
        renoise.tool():add_menu_entry{
          name=menu_entry_name,
          invoke=function() appSelectionLaunchApp(app_path) end
        }
        table.insert(added_menu_entries, menu_entry_name)
      end
      menu_entry_name = "Sample Navigator:Paketti..:Launch App..:Launch App "..i.." "..app_name
      if not renoise.tool():has_menu_entry(menu_entry_name) then
        renoise.tool():add_menu_entry{
          name=menu_entry_name,
          invoke=function() appSelectionLaunchApp(app_path) end
        }
        table.insert(added_menu_entries, menu_entry_name)
      end
      menu_entry_name = "Sample Editor:Paketti..:Launch App..:Launch App "..i.." "..app_name
      if not renoise.tool():has_menu_entry(menu_entry_name) then
        renoise.tool():add_menu_entry{
          name=menu_entry_name,
          invoke=function() appSelectionLaunchApp(app_path) end
        }
        table.insert(added_menu_entries, menu_entry_name)
      end

    end
  end

  -- If no app selections are set, show the app selection dialog
  if not apps_present then
    renoise.app():show_status("No apps have been configured in Paketti..:Launch App..:Configure Launch App Selection, cannot populate Menu.")
  end

  -- Add static menu entry for configuring app selections
  local configure_entry_name = "--Instrument Box:Paketti..:Launch App..:Configure Launch App Selection..."
  if not renoise.tool():has_menu_entry(configure_entry_name) then
    renoise.tool():add_menu_entry{
      name=configure_entry_name,
      invoke=show_app_selection_dialog
    }
    table.insert(added_menu_entries, configure_entry_name)
  end

  configure_entry_name = "--Main Menu:Tools:Paketti..:Launch App..:Configure Launch App Selection..."
  if not renoise.tool():has_menu_entry(configure_entry_name) then
    renoise.tool():add_menu_entry{
      name=configure_entry_name,
      invoke=show_app_selection_dialog
    }
    table.insert(added_menu_entries, configure_entry_name)
  end

  configure_entry_name = "--Sample Navigator:Paketti..:Launch App..:Configure Launch App Selection..."
  if not renoise.tool():has_menu_entry(configure_entry_name) then
    renoise.tool():add_menu_entry{
      name=configure_entry_name,
      invoke=show_app_selection_dialog
    }
    table.insert(added_menu_entries, configure_entry_name)
  end  
  configure_entry_name = "--Sample Editor:Paketti..:Launch App..:Configure Launch App Selection..."
  if not renoise.tool():has_menu_entry(configure_entry_name) then
    renoise.tool():add_menu_entry{
      name=configure_entry_name,
      invoke=show_app_selection_dialog
    }
    table.insert(added_menu_entries, configure_entry_name)


  end  
  
  
end

function appSelectionUpdateMenuEntries()
  if renoise.song() == nil then return end
  appSelectionRemoveMenuEntries()
  appSelectionCreateMenuEntries()
end

-- Idle notifier function
local function handle_idle_notifier()
  if renoise.song() then
    appSelectionUpdateMenuEntries()
    -- Remove this notifier to prevent repeated execution
    renoise.tool().app_idle_observable:remove_notifier(handle_idle_notifier)
  end
end

-- Ensure menu entries are created only after renoise.song() is initialized
local function handle_new_document()
  if not renoise.tool().app_idle_observable:has_notifier(handle_idle_notifier) then
    renoise.tool().app_idle_observable:add_notifier(handle_idle_notifier)
  end
end

renoise.tool().app_new_document_observable:add_notifier(handle_new_document)

-- Ensure menu entries are created only after renoise.song() is initialized (initial load)
if not renoise.tool().app_idle_observable:has_notifier(handle_idle_notifier) then
  renoise.tool().app_idle_observable:add_notifier(handle_idle_notifier)
end

---------
-- Function to toggle external editors for all devices in a given device chain
function ToggleDeviceExternalEditors(device_chain)
  if #device_chain.devices > 1 then
    for i = 2, #device_chain.devices do
      if device_chain.devices[i].external_editor_available == true then
        device_chain.devices[i].external_editor_visible = not device_chain.devices[i].external_editor_visible
      end
    end
  end
end

-- Function to hide external editors for all devices in a given device chain
function HideDeviceExternalEditors(device_chain)
  if #device_chain.devices > 1 then
    for i = 2, #device_chain.devices do
      if device_chain.devices[i].external_editor_available == true then
        device_chain.devices[i].external_editor_visible = false
      end
    end
  end
end

-- Keybinding to show/hide track DSP and FX chain devices
renoise.tool():add_keybinding{name="Global:Paketti:Show/Hide Track DSP and FX Chain Device External Editors",invoke=function()

  -- Check the middle layer
  local w = renoise.app().window
  local instrument = renoise.song().selected_instrument
  local selected_track = renoise.song().selected_track

  if w.active_middle_frame==7 then
    -- Hide track DSP devices
    if selected_track and #selected_track.devices > 1 then
      HideDeviceExternalEditors(selected_track)
    end

    -- Toggle FX chain device external editors for the selected instrument
    if instrument and #instrument.sample_device_chains > 0 then
      for _, device_chain in ipairs(instrument.sample_device_chains) do
        if #device_chain.devices > 1 then
          ToggleDeviceExternalEditors(device_chain)
        end
      end
    end
  else
    -- Hide FX chain devices
    if instrument and #instrument.sample_device_chains > 0 then
      for _, device_chain in ipairs(instrument.sample_device_chains) do
        if #device_chain.devices > 1 then
          HideDeviceExternalEditors(device_chain)
        end
      end
    end

    -- Toggle track DSP device external editors for the selected track
    if selected_track and #selected_track.devices > 1 then
      ToggleDeviceExternalEditors(selected_track)
    end
  end

end}
---------------------
-- Adding menu entries and keybinding for the combined randomizer dialog
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices..:Randomize Devices and Plugins Dialog",invoke=function() openCombinedRandomizerDialog() end}
renoise.tool():add_menu_entry{name="DSP Device:Paketti..:Randomize Devices and Plugins Dialog",invoke=function() openCombinedRandomizerDialog() end}
renoise.tool():add_menu_entry{name="--Mixer:Paketti..:Randomize Devices and Plugins Dialog",invoke=function() openCombinedRandomizerDialog() end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Devices and Plugins Dialog",invoke=function() openCombinedRandomizerDialog() end}

-- Adding keybindings for user preferences for the selected device
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Device with User1 (%)",invoke=function() randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference1.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Device with User2 (%)",invoke=function() randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference2.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Device with User3 (%)",invoke=function() randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference3.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Device with User4 (%)",invoke=function() randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference4.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Device with User5 (%)",invoke=function() randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference5.value) end}

-- Adding keybindings for user preferences for all devices on the selected track
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Devices of Track with User1 (%)",invoke=function() randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference1.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Devices of Track with User2 (%)",invoke=function() randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference2.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Devices of Track with User3 (%)",invoke=function() randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference3.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Devices of Track with User4 (%)",invoke=function() randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference4.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Devices of Track with User5 (%)",invoke=function() randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference5.value) end}

-- Adding keybindings for user preferences for the selected instrument plugin
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Plugin with User1 (%)",invoke=function() randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference1.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Plugin with User2 (%)",invoke=function() randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference2.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Plugin with User3 (%)",invoke=function() randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference3.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Plugin with User4 (%)",invoke=function() randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference4.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Plugin with User5 (%)",invoke=function() randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference5.value) end}

-- Adding keybindings for user preferences for all plugins in the song
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Plugins in Song with User1 (%)",invoke=function() randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference1.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Plugins in Song with User2 (%)",invoke=function() randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference2.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Plugins in Song with User3 (%)",invoke=function() randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference3.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Plugins in Song with User4 (%)",invoke=function() randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference4.value) end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize All Plugins in Song with User5 (%)",invoke=function() randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference5.value) end}

-- Function to randomize parameters of the selected device by a given intensity
function randomizeSelectedDeviceFromGUI(intensity)
  local song = renoise.song()
  local device = song.selected_device

  if not device then
    renoise.app():show_status("No DSP Device has been selected, cannot randomize parameters. Select a Track DSP Device and try again.")
    return
  end

  local parameter_count = #device.parameters
  local device_name = device.display_name
  for i = 1, parameter_count do
    local parameter = device:parameter(i)
    local min = parameter.value_min
    local max = parameter.value_max
    local current_value = parameter.value
    if intensity > 0 then
      local random_value = math.random() * (max - min) + min
      parameter.value = current_value + (random_value - current_value) * intensity / 100
    end
  end

  renoise.app():show_status("Randomized " .. parameter_count .. " parameters for device: " .. device_name .. " with " .. intensity .. "% intensity")
end

-- Function to randomize parameters of all devices on the selected track by a given intensity
function randomizeAllDevicesOnTrack(intensity)
  local song = renoise.song()
  local track = song.selected_track

  if not track then
    renoise.app():show_status("No track has been selected, cannot randomize devices. Select a track and try again.")
    return
  end

  local device_count = #track.devices
  for d = 2, device_count do -- Start from 2 to skip the Track Volume/Pan device
    local device = track:device(d)
    local parameter_count = #device.parameters
    for i = 1, parameter_count do
      local parameter = device:parameter(i)
      local min = parameter.value_min
      local max = parameter.value_max
      local current_value = parameter.value
      if intensity > 0 then
        local random_value = math.random() * (max - min) + min
        parameter.value = current_value + (random_value - current_value) * intensity / 100
      end
    end
  end

  renoise.app():show_status("Randomized all devices on the selected track with " .. intensity .. "% intensity")
end

-- Function to randomize parameters of the selected instrument plugin by a given intensity
function randomizeSelectedPluginFromGUI(intensity)
  local song = renoise.song()
  local instrument = song.selected_instrument

  if not instrument.plugin_properties.plugin_loaded then
    renoise.app():show_status("No plugin has been loaded in the selected instrument.")
    return
  end

  local device = instrument.plugin_properties
  local parameter_count = #device.plugin_device.parameters
  local plugin_name = device.plugin_device.name
  for i = 1, parameter_count do
    local parameter = device.plugin_device.parameters[i]
    local min = parameter.value_min
    local max = parameter.value_max
    local current_value = parameter.value
    if intensity > 0 then
      local random_value = math.random() * (max - min) + min
      parameter.value = current_value + (random_value - current_value) * intensity / 100
    end
  end

  renoise.app():show_status("Randomized " .. parameter_count .. " parameters for plugin: " .. plugin_name .. " with " .. intensity .. "% intensity")
end

-- Function to randomize parameters of all plugins in the song by a given intensity
function randomizeAllPluginsInSong(intensity)
  local song = renoise.song()
  for _, instrument in ipairs(song.instruments) do
    if instrument.plugin_properties.plugin_loaded then
      local device = instrument.plugin_properties
      local parameter_count = #device.plugin_device.parameters
      for i = 1, parameter_count do
        local parameter = device.plugin_device.parameters[i]
        local min = parameter.value_min
        local max = parameter.value_max
        local current_value = parameter.value
        if intensity > 0 then
          local random_value = math.random() * (max - min) + min
          parameter.value = current_value + (random_value - current_value) * intensity / 100
        end
      end
    end
  end

  renoise.app():show_status("Randomized all plugins in the song with " .. intensity .. "% intensity")
end

-- Function to show/hide the external editor of the selected device
function toggleExternalEditor()
  local song = renoise.song()
  local device = song.selected_device

  if device and device.external_editor_available then
    device.external_editor_visible = not device.external_editor_visible
    local status = device.external_editor_visible and "Opened" or "Hid"
    renoise.app():show_status(status .. " external editor for: " .. device.display_name)
  else
    renoise.app():show_status("No external editor available for the selected device.")
  end
end

-- Function to show/hide all external editors on the selected track
function toggleAllExternalEditorsOnTrack()
  local song = renoise.song()
  local track = song.selected_track

  if not track then
    renoise.app():show_status("No track has been selected. Select a track and try again.")
    return
  end

  local function toggle_devices(device_chain)
    if #device_chain.devices > 1 then
      for i = 2, #device_chain.devices do
        if device_chain.devices[i].external_editor_available then
          device_chain.devices[i].external_editor_visible = not device_chain.devices[i].external_editor_visible
        end
      end
    end
  end

  toggle_devices(track)
  renoise.app():show_status("Toggled all external editors in the selected track")
end

-- Function to show/hide the external editor of the selected instrument plugin
function toggleExternalPluginEditor()
  local song = renoise.song()
  local instrument = song.selected_instrument

  if instrument.plugin_properties.plugin_loaded and instrument.plugin_properties.plugin_device.external_editor_available
 then
    instrument.plugin_properties.plugin_device.external_editor_visible = not instrument.plugin_properties.plugin_device.external_editor_visible
    local status = instrument.plugin_properties.plugin_device.external_editor_visible and "Opened" or "Hid"
    renoise.app():show_status(status .. " external editor for: " .. instrument.plugin_properties.plugin_device.name)
  else
    renoise.app():show_status("No external editor available for the selected plugin.")
  end
end

-- Function to show/hide all external editors for all plugins in the song
function toggleAllExternalPluginEditorsInSong()
  local song = renoise.song()

  for _, instrument in ipairs(song.instruments) do
    if instrument.plugin_properties.plugin_loaded and instrument.plugin_properties.plugin_device.external_editor_available then
      instrument.plugin_properties.plugin_device.external_editor_visible = not instrument.plugin_properties.plugin_device.external_editor_visible
    end
  end

  renoise.app():show_status("Toggled all external editors for all plugins in the song")
end

  -- Keyhandler to close the dialog with exclamation mark
  function my_RandomizeDeviceskeyhandler_func(dialog, key)
 local closer = preferences.pakettiDialogClose.value
  if key.modifiers == "" and key.name == closer then
dialog:close()
dialog=nil
return nil
else

    return key
  end
end 


-- Function to show the combined randomizer dialog
function openCombinedRandomizerDialog()
  local vb = renoise.ViewBuilder()
  local song = renoise.song()
  local device = song.selected_device
  local track = song.selected_track
  local instrument = song.selected_instrument
  local device_short_name = device and device.display_name or "Select a Device"
  local track_name = track and track.name or "Select a Track"
--  local instrument_plugin_name = instrument.plugin_properties.plugin_device.name or "Instrument has no Plugin"
local instrument_plugin_name = instrument.plugin_properties.plugin_device and instrument.plugin_properties.plugin_device.name or "Instrument has no Plugin"




  local function save_current_intensity()
    preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentage.value = vb.views["randomize_slider_device"].value
    preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentage.value = vb.views["randomize_slider_track"].value
    preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentage.value = vb.views["randomize_slider_plugin"].value
    preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentage.value = vb.views["randomize_slider_all_plugins"].value
  end

  local function set_user_preference(preference_slot, slider_id, text_id)
    local value = vb.views[slider_id].value
    preferences.RandomizeSettings[preference_slot].value = value
    vb.views[text_id].text = string.format("%.1f%%", value)
  end

  local function load_user_preference(preference_slot, slider_id, text_id)
    local value = preferences.RandomizeSettings[preference_slot].value
    vb.views[slider_id].value = value
    vb.views[text_id].text = string.format("%.1f%%", value)
  end

  local dialog_content = vb:row{
    margin = 10,
    vb:column{
      margin = 10,
      vb:text{font = "bold", text = "Selected Device"},
      vb:text{id = "device_short_name", font = "bold", text = device_short_name},
      vb:horizontal_aligner{mode = "center", vb:text{text = "Randomization Intensity (%)"}},
      vb:slider{id = "randomize_slider_device", min = 0, max = 100, value = preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentage.value, width = 200, notifier = function()
        local slider_value = vb.views["randomize_slider_device"].value
        vb.views["slider_value_text_device"].text = string.format("%.1f%%", slider_value)
      end},
      vb:horizontal_aligner{mode = "center", vb:text{id = "slider_value_text_device", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentage.value)}},
      vb:horizontal_aligner{mode = "center", vb:button{text = "Randomize Selected Device", width = 200, notifier = function()
        local slider_value = vb.views["randomize_slider_device"].value
        randomizeSelectedDeviceFromGUI(slider_value)
        save_current_intensity()
      end}},
      vb:horizontal_aligner{mode = "center", 
      vb:text{text="User1:"}, vb:text{id = "user_preference1_text_device", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference1.value), width = 50}, 
      vb:button{text="Run", width=50, notifier=function()
      randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference1.value) end},
      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeSelectedDevicePercentageUserPreference1", "randomize_slider_device", "user_preference1_text_device")
      end}},
      vb:horizontal_aligner{mode = "center", 
      vb:text{text="User2:"}, vb:text{id = "user_preference2_text_device", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference2.value), width = 50}, 
      vb:button{text="Run", width=50, notifier=function()
      randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference2.value) end},
      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeSelectedDevicePercentageUserPreference2", "randomize_slider_device", "user_preference2_text_device")
      end}},
      vb:horizontal_aligner{mode = "center", vb:text{text="User3:"}, vb:text{id = "user_preference3_text_device", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference3.value), width = 50}, 
      vb:button{text="Run", width=50, notifier=function()
      randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference3.value) end},
      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeSelectedDevicePercentageUserPreference3", "randomize_slider_device", "user_preference3_text_device")
      end}},
      vb:horizontal_aligner{mode = "center", vb:text{text="User4:"}, vb:text{id = "user_preference4_text_device", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference4.value), width = 50}, 
      vb:button{text="Run", width=50, notifier=function()
      randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference4.value) end},
      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeSelectedDevicePercentageUserPreference4", "randomize_slider_device", "user_preference4_text_device")
      end}},
      vb:horizontal_aligner{mode = "center", vb:text{text="User5:"}, vb:text{id = "user_preference5_text_device", text= string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference5.value), width = 50}, 
      vb:button{text="Run", width=50, notifier=function()
      randomizeSelectedDeviceFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedDevicePercentageUserPreference5.value) end},

      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeSelectedDevicePercentageUserPreference5", "randomize_slider_device", "user_preference5_text_device")
      end}},
      vb:horizontal_aligner{mode = "center", vb:button{text = "Show/Hide Track Device External Editor", width = 200, notifier = function()
        toggleExternalEditor()
      end}}
    },
    vb:column{
      margin = 10,
      vb:text{font = "bold", text = "Selected Track"},
      vb:text{id = "track_name_text", font = "bold", text = track_name},
      vb:horizontal_aligner{mode = "center", vb:text{text = "Randomization Intensity (%)"}},
      vb:slider{id = "randomize_slider_track", min = 0, max = 100, value = preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentage.value, width = 200, notifier = function()
        local slider_value = vb.views["randomize_slider_track"].value
        vb.views["slider_value_text_track"].text = string.format("%.1f%%", slider_value)
      end},
      vb:horizontal_aligner{mode = "center", vb:text{id = "slider_value_text_track", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentage.value)}},
      vb:horizontal_aligner{mode = "center", vb:button{text = "Randomize All Devices", width = 200, notifier = function()
        local slider_value = vb.views["randomize_slider_track"].value
        randomizeAllDevicesOnTrack(slider_value)
        save_current_intensity()
      end}},


      vb:horizontal_aligner{mode = "center", vb:text{text="User1:"}, vb:text{id = "user_preference1_text_track", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference1.value), width = 50},
vb:button{text="Run", width=50, notifier=function()
  randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference1.value) end},

vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeAllDevicesPercentageUserPreference1", "randomize_slider_track", "user_preference1_text_track")
      end}},
      vb:horizontal_aligner{mode = "center", vb:text{text="User2:"}, vb:text{id = "user_preference2_text_track", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference2.value), width = 50},

vb:button{text="Run", width=50, notifier=function()
  randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference2.value) end},

      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeAllDevicesPercentageUserPreference2", "randomize_slider_track", "user_preference2_text_track")
      end}},
      vb:horizontal_aligner{mode = "center", vb:text{text="User3:"}, vb:text{id = "user_preference3_text_track", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference3.value), width = 50},
vb:button{text="Run", width=50, notifier=function()
  randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference3.value) end},
      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeAllDevicesPercentageUserPreference3", "randomize_slider_track", "user_preference3_text_track")
      end}},
      vb:horizontal_aligner{mode = "center", vb:text{text="User4:"}, vb:text{id = "user_preference4_text_track", text=string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference4.value), width=50},
vb:button{text="Run", width=50, notifier=function()
  randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference4.value) end},
      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeAllDevicesPercentageUserPreference4", "randomize_slider_track", "user_preference4_text_track")
      end}},
      vb:horizontal_aligner{mode = "center", vb:text{text="User5:"}, vb:text{id = "user_preference5_text_track", text=string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference5.value), width=50},
  vb:button{text="Run", width=50, notifier=function()
  randomizeAllDevicesOnTrack(preferences.RandomizeSettings.pakettiRandomizeAllDevicesPercentageUserPreference5.value) end},
      vb:button{text = "Set", width = 50, notifier = function()
        set_user_preference("pakettiRandomizeAllDevicesPercentageUserPreference5", "randomize_slider_track", "user_preference5_text_track")
      end}},
      vb:horizontal_aligner{mode = "center", vb:button{text = "Show/Hide All Devices on Track External Editor", width = 200, notifier = function()
        toggleAllExternalEditorsOnTrack()
      end}}
    },
    vb:column{
      margin = 10,
      vb:text{font = "bold", text = "Selected Instrument Plugin"},
      vb:text{id = "plugin_name_text", font = "bold", text = instrument_plugin_name},
      vb:horizontal_aligner{mode = "center", vb:text{text = "Randomization Intensity (%)"}},
      vb:slider{id = "randomize_slider_plugin", min = 0, max = 100, value = preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentage.value, width = 200, notifier = function()
        local slider_value = vb.views["randomize_slider_plugin"].value
        vb.views["slider_value_text_plugin"].text = string.format("%.1f%%", slider_value)
      end},
      vb:horizontal_aligner{mode = "center", vb:text{id = "slider_value_text_plugin", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentage.value)}},
      vb:horizontal_aligner{mode = "center", vb:button{text = "Randomize Selected Plugin", width = 200, notifier = function()
        local slider_value = vb.views["randomize_slider_plugin"].value
        randomizeSelectedPluginFromGUI(slider_value)
        save_current_intensity()
      end}},
vb:horizontal_aligner{mode = "center", vb:text{text="User1:"},vb:text{id = "user_preference1_text_plugin", text=string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference1.value),width=50}, 
vb:button{text="Run", width=50, notifier=function()
randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference1.value) end},
vb:button{text = "Set", width = 50, notifier = function() set_user_preference("pakettiRandomizeSelectedPluginPercentageUserPreference1", "randomize_slider_plugin", "user_preference1_text_plugin")
end}},
vb:horizontal_aligner{mode = "center", vb:text{text="User2:"},vb:text{id = "user_preference2_text_plugin", text=string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference2.value),width=50}, 
vb:button{text="Run", width=50, notifier=function()
randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference2.value) end},
vb:button{text = "Set", width = 50, notifier = function() set_user_preference("pakettiRandomizeSelectedPluginPercentageUserPreference2", "randomize_slider_plugin", "user_preference2_text_plugin")
end}},
vb:horizontal_aligner{mode = "center", vb:text{text="User3:"},vb:text{id = "user_preference3_text_plugin", text=string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference3.value),width=50}, 
vb:button{text="Run", width=50, notifier=function()
randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference3.value) end},
vb:button{text = "Set", width = 50, notifier = function() set_user_preference("pakettiRandomizeSelectedPluginPercentageUserPreference3", "randomize_slider_plugin", "user_preference3_text_plugin")
end}},
vb:horizontal_aligner{mode = "center", vb:text{text="User4:"},vb:text{id = "user_preference4_text_plugin", text=string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference4.value),width=50},
vb:button{text="Run", width=50, notifier=function()
randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference4.value) end},
vb:button{text = "Set", width = 50, notifier = function() set_user_preference("pakettiRandomizeSelectedPluginPercentageUserPreference4", "randomize_slider_plugin", "user_preference4_text_plugin")
end}},
vb:horizontal_aligner{mode = "center", vb:text{text="User5:"},vb:text{id = "user_preference5_text_plugin", text=string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference5.value),width=50}, 
vb:button{text="Run", width=50, notifier=function()
randomizeSelectedPluginFromGUI(preferences.RandomizeSettings.pakettiRandomizeSelectedPluginPercentageUserPreference5.value) end},
vb:button{text = "Set", width = 50, notifier = function() set_user_preference("pakettiRandomizeSelectedPluginPercentageUserPreference5", "randomize_slider_plugin", "user_preference5_text_plugin")
end}},

      vb:horizontal_aligner{mode = "center", vb:button{text = "Show/Hide Plugin External Editor", width = 200, notifier = function()
        toggleExternalPluginEditor()
      end}}
    },
    vb:column{
      margin = 10,
      vb:text{font = "bold", text = "All Plugins in Song"},
      vb:space{height = 18},
      vb:horizontal_aligner{mode = "center", vb:text{text = "Randomization Intensity (%)"}},
      vb:slider{id = "randomize_slider_all_plugins", min = 0, max = 100, value = preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentage.value, width = 200, notifier = function()
        local slider_value = vb.views["randomize_slider_all_plugins"].value
        vb.views["slider_value_text_all_plugins"].text = string.format("%.1f%%", slider_value)
      end},
      vb:horizontal_aligner{mode = "center", vb:text{id = "slider_value_text_all_plugins", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentage.value)}},
      vb:horizontal_aligner{mode = "center", vb:button{text = "Randomize All Plugins", width = 200, notifier = function()
        local slider_value = vb.views["randomize_slider_all_plugins"].value
 local song = renoise.song()
          local has_plugins = false
          
          for _, track in ipairs(song.tracks) do
            for _, device in ipairs(renoise.song().instruments) do
              if device.plugin_properties.plugin_device then
                has_plugins = true
                break
              end
            end
            if has_plugins then break end
          end

          if not has_plugins then
            renoise.app():show_status("There are no instrument plugins used in this song.")
          else        
        randomizeAllPluginsInSong(slider_value)
        end
        save_current_intensity()
      end}},
vb:horizontal_aligner{
  mode = "center",
  vb:text{text = "User1:"},
  vb:text{id = "user_preference1_text_all_plugins", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference1.value), width = 50},
  vb:button{text = "Run", width = 50, notifier = function() 
    randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference1.value)
  end},
  vb:button{text = "Set", width = 50, notifier = function() 
    set_user_preference("pakettiRandomizeAllPluginsPercentageUserPreference1", "randomize_slider_all_plugins", "user_preference1_text_all_plugins") 
  end}
},
vb:horizontal_aligner{
  mode = "center",
  vb:text{text = "User2:"},
  vb:text{id = "user_preference2_text_all_plugins", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference2.value), width = 50},
  vb:button{text = "Run", width = 50, notifier = function() 
    randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference2.value)
  end},
  vb:button{text = "Set", width = 50, notifier = function() 
    set_user_preference("pakettiRandomizeAllPluginsPercentageUserPreference2", "randomize_slider_all_plugins", "user_preference2_text_all_plugins") 
  end}
},

vb:horizontal_aligner{
  mode = "center",
  vb:text{text = "User3:"},
  vb:text{id = "user_preference3_text_all_plugins", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference3.value), width = 50},
  vb:button{text = "Run", width = 50, notifier = function() 
    randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference3.value)
  end},
  vb:button{text = "Set", width = 50, notifier = function() 
    set_user_preference("pakettiRandomizeAllPluginsPercentageUserPreference3", "randomize_slider_all_plugins", "user_preference3_text_all_plugins") 
  end}
},

vb:horizontal_aligner{
  mode = "center",
  vb:text{text = "User4:"},
  vb:text{id = "user_preference4_text_all_plugins", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference4.value), width = 50}, 
  vb:button{text = "Run", width = 50, notifier = function() 
    randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference4.value)
  end},
  vb:button{text = "Set", width = 50, notifier = function() 
    set_user_preference("pakettiRandomizeAllPluginsPercentageUserPreference4", "randomize_slider_all_plugins", "user_preference4_text_all_plugins") 
  end}
},

vb:horizontal_aligner{
  mode = "center",
  vb:text{text = "User5:"},
  vb:text{id = "user_preference5_text_all_plugins", text = string.format("%.1f%%", preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference5.value), width = 50},
  vb:button{text = "Run", width = 50, notifier = function() 
    randomizeAllPluginsInSong(preferences.RandomizeSettings.pakettiRandomizeAllPluginsPercentageUserPreference5.value)
  end},
  vb:button{text = "Set", width = 50, notifier = function() 
    set_user_preference("pakettiRandomizeAllPluginsPercentageUserPreference5", "randomize_slider_all_plugins", "user_preference5_text_all_plugins") 
  end}
},



      vb:horizontal_aligner{mode = "center", vb:button{text = "Show/Hide All Plugin External Editors", width = 200, notifier = function()
      
      local song = renoise.song()
      local has_plugins = false

      for _, track in ipairs(song.tracks) do
        for _, device in ipairs(renoise.song().instruments) do
          if device.plugin_properties.plugin_device then
            has_plugins = true
            break
          end
        end
        if has_plugins then break end
      end

      if not has_plugins then
        renoise.app():show_status("There are no instrument plugins used in this song.")
      else
      
      
      
        toggleAllExternalPluginEditorsInSong()
      end 
      end}}
    }
  }

  -- Key handler function to toggle keyboard focus
  local function my_keyhandler_func(dialog, key)
    renoise.app().window.lock_keyboard_focus = not renoise.app().window.lock_keyboard_focus
    renoise.app().window.lock_keyboard_focus = not renoise.app().window.lock_keyboard_focus
    return key
  end

  local dialog = renoise.app():show_custom_dialog("Randomize Devices and Plugins", dialog_content, my_RandomizeDeviceskeyhandler_func)

song.selected_instrument_observable:add_notifier(function()
  local new_instrument = song.selected_instrument
  if dialog and dialog.visible then
    if new_instrument and renoise.song().instruments[renoise.song().selected_instrument_index].name ~= "" then
      -- Ensure plugin_properties exist and the plugin is loaded
      if new_instrument.plugin_properties and new_instrument.plugin_properties.plugin_loaded then
        if new_instrument.plugin_properties.plugin_device then
          vb.views["plugin_name_text"].text = new_instrument.plugin_properties.plugin_device.name
        else
          vb.views["plugin_name_text"].text = "Instrument plugin device missing"
        end
      else
        vb.views["plugin_name_text"].text = "Instrument has no Plugin"
      end
    else
      vb.views["plugin_name_text"].text = "No Instrument Selected"
    end
  end
end)
end


---------


renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Randomize Selected Instrument Plugin Parameters",invoke=function()randomizeSelectedPlugin()end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Plugin",invoke=function()randomizeSelectedPlugin()end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices..:Randomize Selected Instrument Plugin Parameters",invoke=function()randomizeSelectedPlugin()end}

-- Function to randomize parameters of the selected plugin
function randomizeSelectedPlugin()
  local song = renoise.song()
  local instrument = renoise.song().selected_instrument 

  if not instrument or not instrument.plugin_properties then
    renoise.app():show_status("The currently selected Instrument does not have a plugin loaded.")
    return
  end

  local plugin_name = renoise.song().selected_instrument.plugin_properties.plugin_device.name
  renoise.app():show_status("Randomizing parameters for plugin: " .. plugin_name)

  local parameter_count = #instrument.plugin_properties.plugin_device.parameters
  
  for i = 1, parameter_count do
    local parameter = instrument.plugin_properties.plugin_device.parameters[i]
    local min = parameter.value_min
    local max = parameter.value_max
    local random_value = math.random() * (max - min) + min
    parameter.value = random_value
  end
  
  renoise.app():show_status("Randomized " .. parameter_count .. " parameters for plugin: " .. plugin_name)
end




-- Tool Registration
renoise.tool():add_menu_entry{name="DSP Device:Paketti..:Randomize Selected Device Parameters",invoke=function()randomize_selected_device()end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices..:Randomize Selected Device Parameters",invoke=function()randomize_selected_device()end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Device",invoke=function()randomize_selected_device()end}

-- Function to randomize parameters of the selected device
function randomize_selected_device()
  local song = renoise.song()
  local device = nil

  if renoise.app().window.active_middle_frame == 7 and song.selected_sample_device ~= nil then
    device = song.selected_sample_device
  else
    device = song.selected_device
  end
  
  if not device then
    renoise.app():show_status("No Track DSP or Sample FX Device has been selected, cannot randomize parameters. Select a Track DSP or Sample FX Device and try again.")
    return
  end

  local parameter_count = #device.parameters
  local device_name = device.display_name
  for i=1, parameter_count do
    local parameter = device:parameter(i)
    local min = parameter.value_min
    local max = parameter.value_max
    local random_value = math.random()*(max-min)+min
    parameter.value = random_value
  end
  
  renoise.app():show_status("Randomized "..parameter_count.." parameters for device: "..device_name)
end





-------
local function show_available_plugins_dialog()

  -- Declare my_dialog before use
  local my_dialog

  -- Avoid multiple dialogs
  if my_dialog and my_dialog.visible then my_dialog:close() end

  -- Access available devices and device infos directly
  local devices = renoise.song().selected_track.available_devices
  local device_infos = renoise.song().selected_track.available_device_infos

  -- Convert these to strings for the textfield
  local devices_text = ""
  for i, device in ipairs(devices) do
    -- Format the index to 3 digits with leading zeros (e.g., 001, 002)
    local index = string.format("%03d", i)
    devices_text = devices_text .. index .. ": " .. tostring(device) .. "\n"
  end

  -- Separator for readability
  local separator = "-----------////////////------------------------------------////////////------------------------------------////////////------------------------------------////////////------------------------------------////////////------------------------------------////////////------------------------------------////////////-------------------------"

  local device_infos_text = ""
  for i, info in ipairs(device_infos) do
    -- Format the index to 3 digits with leading zeros
    local index = string.format("%03d", i)
    device_infos_text = device_infos_text .. "Device Info " .. index .. ":\n"
    device_infos_text = device_infos_text .. "Name: " .. info.name .. "\n"
    device_infos_text = device_infos_text .. 'Path: "' .. info.path .. '"\n'
    device_infos_text = device_infos_text .. "Short Name: " .. info.short_name .. "\n"
    device_infos_text = device_infos_text .. "Is Favorite: " .. tostring(info.is_favorite) .. "\n"
    device_infos_text = device_infos_text .. "Favorite Name: " .. info.favorite_name .. "\n"
    device_infos_text = device_infos_text .. "Is Bridged: " .. tostring(info.is_bridged) .. "\n"
    device_infos_text = device_infos_text .. "\n"
  end

  -- Combine everything for the multiline textfield
  local combined_text = devices_text .. separator .. "\n" .. device_infos_text

 
 
  -- Function to save the textfield content to a file
  local vb = renoise.ViewBuilder()
  local multiline_field = vb:multiline_textfield { text = combined_text, width = 900, height = 700 }

  local function save_to_file()
    local filename = renoise.app():prompt_for_filename_to_write(".txt", "Available Plugins Saver")
    if filename then
      local file, err = io.open(filename, "w")
      if file then
        file:write(multiline_field.text)  -- Correct reference to multiline_field's text
        file:close()
        renoise.app():show_status("File saved successfully")
      else
        renoise.app():show_status("Error saving file: " .. err)
      end
    end
  end

  -- Create the save button
  local save_button = vb:button { text = "Save as textfile", notifier = save_to_file }

  -- Create the dialog
  my_dialog = renoise.app():show_custom_dialog("Debug: Available Plugin Information", vb:column {
    multiline_field,
    save_button
  }, my_AvailPlugkeyhandler_func)

end

function my_AvailPlugkeyhandler_func(dialog,key)

local closer = preferences.pakettiDialogClose.value
  if key.modifiers == "" and key.name == closer then
dialog:close()
dialog=nil
return nil
else

    return key
end
end

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices..:Debug..:Dump VST/VST3/AU/LADSPA/DSSI/Native Effects to Dialog", invoke=function() show_available_plugins_dialog() end}



---
renoise.tool():add_keybinding{name="Global:Paketti:Clear All TrackDSPs from Current Track",
  invoke=function()
    local track = renoise.song().selected_track
    if #track.devices <= 1 then
      renoise.app():show_status("There were no Track DSPs to clear, doing nothing.")
    else
      -- Loop to delete devices from position 2 until only one device remains
      while #track.devices > 1 do
        track:delete_device_at(2)
      end
      renoise.app():show_status("All Track DSPs cleared from the current track.")
    end end}

----------
-- TODO: make this use loadnative("name",XML) okay?
function PakettiInvertDeviceTrackDSP()
  loadnative("Audio/Effects/Native/Gainer")
  
  -- Load the preset XML file into the plugin device
  local preset_xml = providePresetXML("Presets/PakettiGainerInverter.xml")
  
  if not preset_xml then
    renoise.app():show_status("Preset loading failed.")
    return
  end
  local device 
  if renoise.app().window.active_middle_frame == 7 or renoise.app().window.active_middle_frame == 6 then 
  device = renoise.song().selected_sample_device
  else
  device = renoise.song().selected_device
  end 
  
  if device then
    device.active_preset_data = preset_xml
    device.display_name = "Inverter"
    renoise.app():show_status("Preset successfully loaded from: Presets/PakettiGainerInverter.xml")
  else
    renoise.app():show_status("No device found to apply the preset.")
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Insert Inverter Device to TrackDSP/SampleFX",invoke=function() PakettiInvertDeviceTrackDSP() end}

renoise.tool():add_midi_mapping{name="Paketti:Insert Inverter Device to TrackDSP/SampleFX",invoke=function(message) if message:is_trigger() then PakettiInvertDeviceTrackDSP() end end}

