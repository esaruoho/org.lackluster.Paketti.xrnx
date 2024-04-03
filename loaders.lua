------------------------------------------------------------------------------------------------------------------
-- Dump list of plugins, fx available to Terminal
renoise.tool():add_keybinding{name="Global:Paketti:VSTLister Dump", invoke=function()
local plugins = renoise.song().selected_instrument.plugin_properties.available_plugins
  for key, value in ipairs(plugins) do
    print(key, value)
  end
local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices
  for key, value in ipairs (devices) do 
    print(key, value)
  end end}

renoise.tool():add_keybinding{name="Global:Paketti:Dump Instruments to Console", invoke=function() 
local plugins = renoise.song().selected_instrument.plugin_properties.available_plugins
  for key, value in ipairs(plugins) do
    print(key, value)
  end
end}

renoise.tool():add_keybinding{name="Global:Paketti:Dump VST/AU/Native Effects to Console", invoke=function() 
local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices
  for key, value in ipairs (devices) do 
    print(key, value)
  end
end}

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Dump VST/AU/Native Effects to Console", invoke=function() 
local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices
  for key, value in ipairs (devices) do 
    print(key, value)
  end
end}






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
renoise.tool():add_keybinding{name = "Global:Paketti:Load FabFilter One", invoke=function() renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties:load_plugin("Audio/Generators/AU/aumu:FOne:FabF")
local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true end end}
------------------------------------------------------------------------------------------------------------
renoise.tool():add_keybinding{name = "Global:Paketti:Load Surge (VST)", invoke=function() renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties:load_plugin("Audio/Generators/VST/Surge")
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
function LoadPPG()
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
s.selected_instrument.plugin_properties:load_plugin("Audio/Generators/VST/PPG Wave 2.V")
if s.selected_instrument.plugin_properties.plugin_loaded
 then
 local pd=s.selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
 end
--renoise.app().window.active_lower_frame=3
renoise.app().window.active_middle_frame=3
s.selected_instrument.active_tab=2 
--     renoise.song().selected_track.devices[checkline].parameters[1].value=0.474 -- Mix 

renoise.song().instruments[renoise.song().selected_instrument_index].plugin_properties.plugin_device.active_preset_data="PPG_Arpeg.XML"
--loadnative("Audio/Effects/Native/*Instr. Automation")
--     s.selected_track.devices[2].parameters[2].value=0.0 -- delay

end

renoise.tool():add_keybinding{name="Global:Paketti:Load Waldorf PPG v2 (VST)", invoke=function() LoadPPG() end}
------------------------------------------------------------------------------------------------------------
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
renoise.tool():add_keybinding{name="Global:Paketti:Load Waldorf Attack (VST)", invoke=function() LoadAttack() end}
------------------------------------------------------------------------------------------------------------
function loadnative(effect)
local checkline=nil
local s=renoise.song()
local w=renoise.app().window
local sdevices=s.selected_track.devices
   if (table.count(s.selected_track.devices)) <2 then checkline=2
   else 
    if s.selected_track.devices[2].name=="#Line Input" then checkline=3
    else checkline=2
    end
   end
   
 w.lower_frame_is_visible=true
 w.active_lower_frame=1
 s.selected_track:insert_device_at(effect,checkline)
 s.selected_device_index = 2
 
  if s.selected_track.devices[checkline].name=="DC Offset" then 
    s.selected_track.devices[checkline].parameters[2].value=1
  else end 
  
  if s.selected_track.devices[checkline].name=="#Multiband Send" then 
  s.selected_track.devices[checkline].parameters[1].show_in_mixer=false
  s.selected_track.devices[checkline].parameters[3].show_in_mixer=false
  s.selected_track.devices[checkline].parameters[5].show_in_mixer=false 
  else end
  
  if s.selected_track.devices[checkline].name=="Gainer" then 
  -- As of 1st April 2020 I do want to see the Gain parameter in Mixer. Remove comments if you change opinion
  -- renoise.song().selected_track.devices[checkline].parameters[1].show_in_mixer=false
  else end  
  
  if s.selected_track.devices[checkline].name=="#Line Input" then 
  s.selected_track.devices[2].parameters[2].show_in_mixer=true
  else end

  if s.selected_track.devices[checkline].name=="#Send" then 
  s.selected_track.devices[2].parameters[2].show_in_mixer=true
  -- This loads "#SendPakettiInit"
  renoise.song().selected_track.devices[2].active_preset=2
  else end

    
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
----------------------------------------------------------------------------------------------------------------
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

  if (table.count(s.selected_track.devices)) <2 then checkline=2
    else 
      if s.selected_track.devices[2].name=="#Line Input" then checkline=3
       else checkline=2
      end
  end

  if raw.lower_frame_is_visible==false then raw.lower_frame_is_visible=false
else raw.lower_frame_is_visible=true end

-- raw.active_lower_frame=1
 s.selected_track:insert_device_at(vstname, checkline)
   if s.selected_track.devices[checkline].name=="AU: Koen Tanghe @ Smartelectronix: KTGranulator" then return
   else s.selected_track.devices[checkline].external_editor_visible=true end
  s.selected_track.devices[checkline].is_maximized=false
-- devices[checkline].plugin_properties.auto_suspend=false
-- the one above is just for plugins :( not available for actual track devices
 
 renoise.song().selected_device_index=checkline
 
  if s.selected_track.devices[checkline].name=="AU: Schaack Audio Technologies: TransientShaper" then 
     s.selected_track.devices[checkline].parameters[1].show_in_mixer=true
     s.selected_track.devices[checkline].parameters[2].show_in_mixer=true
     s.selected_track.devices[checkline].parameters[4].show_in_mixer=true
     s.selected_track.devices[checkline].parameters[7].show_in_mixer=true
     s.selected_track.devices[checkline].is_maximized=false
  end 
 
  if s.selected_track.devices[checkline].name=="VST: FabFilter: Pro-Q" then 
     s.selected_track.devices[checkline].parameters[206].value=1 
  end 

--  if s.selected_track.devices[checkline].name=="AU: FabFilter: Pro-Q 3" then 
--     s.selected_track.devices[checkline].parameters[206].value=1 
--  end 
  
  
  if s.selected_track.devices[checkline].name=="AU: TAL-Togu Audio Line: TAL Reverb 4 Plugin" then 
     s.selected_track.devices[checkline].parameters[2].value=0.0 -- delay
     s.selected_track.devices[checkline].parameters[3].value=0.30 -- High Cut
     s.selected_track.devices[checkline].parameters[4].value=0.88 -- Size
     s.selected_track.devices[checkline].parameters[5].value=0.9 -- Diffuse
     s.selected_track.devices[checkline].parameters[6].value=1 -- Dry
     s.selected_track.devices[checkline].parameters[7].value=0.4 -- low cut
     s.selected_track.devices[checkline].parameters[9].value=0.7 -- wet
-- slt.devices[renoise.song().selected_device_index].parameters[7].value=0.4
  end 

  if s.selected_track.devices[checkline].name=="AU: Valhalla DSP, LLC: ValhallaVintageVerb" then 
     s.selected_track.devices[checkline].parameters[1].value=0.474 -- Mix 
     s.selected_track.devices[checkline].parameters[3].value=0.688 -- Decay 
     s.selected_track.devices[checkline].parameters[15].value=0.097 -- low cut
  end 

  if s.selected_track.devices[checkline].name=="AU: Koen Tanghe @ Smartelectronix: KTGranulator" then 
     s.selected_track.devices[checkline].is_maximized=true
     s.selected_track.devices[checkline].parameters[31].value=1 --SplitPitch
     s.selected_track.devices[checkline].parameters[16].value=0.75 --maxTransp
     s.selected_track.devices[checkline].parameters[2].value=0.50 --Mix
     s.selected_track.devices[checkline].parameters[3].value=0.35 --Mix
     s.selected_track.devices[checkline].parameters[6].value=0.75 --Mix
     raw.lower_frame_is_visible=true
     raw.active_lower_frame=1
  end 
 
  if s.selected_track.devices[checkline].name=="AU: George Yohng: W1 Limiter" then
     s.selected_track.devices[checkline].is_maximized=true
     s.selected_track.devices[checkline].parameters[1].show_in_mixer=true
     s.selected_track.devices[checkline].parameters[2].show_in_mixer=true
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

renoise.tool():add_midi_mapping{name="Global:Track Devices:Load DC Offset", invoke=function()
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().selected_track:insert_device_at("Audio/Effects/Native/DC Offset",2)
renoise.song().selected_device_index=2
renoise.song().selected_track.devices[2].parameters[2].value=1
end}



function writeToClipboard(text)
local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices

    local command = 'echo "' .. text .. '" | pbcopy'
    os.execute(command)
end

function launchApp(appName)
os.execute(appName)
end

--renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:writeToClipboard",invoke=function() 
--writeToClipboard(for key, value in ipairs (devices) do  print(key, value)
--end}

--renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Dump VST/AU/Native Effects to Clipboard", invoke=function() 



--) end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Ableton Live..:Launch Ableton Live 12",invoke=function() launchApp("open -a 'Ableton\ Live\ 12\ Suite\.app'") end}

--local command = 'open -a "/Applications\ Live\ 12\ Suite.app"' .. renoise.song().selected_instrument_sample .. "'
--os.execute(command)





--function() launchApp("open -a 'Ableton\ Live\ 12\ Suite.app' .. renoise.song().selected_instrument.sample") end}

renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Pure Data..:Launch Pure Data",invoke=function() launchApp("open -a 'Pd-0.54-1.app'") end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Logic Pro..:Launch Logic Pro",invoke=function() launchApp("open -a 'Logic\ Pro.app'") end}

function saveSamplesToLogicSmartFolder()
local s=renoise.song()
--local additionalname=os.clock
for i = 1, #renoise.song().instruments do
--instruments[i].samples[1]
renoise.app():show_status("Saving")
  s.instruments[i].samples[1].sample_buffer:save_as(path .. path2 .. i .. ".wav", "wav")
os.execute("sox " .. path .. path2 .. i .. " -b 24 " .. path .. path2 .. i .. i .. ".wav")

--os.execute("open -a Logic\ Pro.app /Users/esaruoho/Music/Logic/abs4/abs4/abs4.logic")
end
renoise.app():show_status("32Bit to 24Bit Conversion From Tmp-folder to Logic Smart Folder Done")
os.execute("cd /Users/esaruoho/Music/samples/LogicSmartFolder;open .") end

renoise.tool():add_keybinding{name="Global:Paketti:Save All Samples to Logic Smart Folder", invoke=function() saveSamplesToLogicSmartFolder() end}
----

function saveSamplesToLiveSmartFolder()
local s=renoise.song()
--local additionalname=os.clock
for i = 1, #renoise.song().instruments do
--instruments[i].samples[1]
renoise.app():show_status("Saving")
  s.instruments[i].samples[1].sample_buffer:save_as(path .. path2 .. i .. ".wav", "wav")
os.execute("sox " .. path .. path2 .. i .. " -b 24 " .. path .. path2 .. i .. i .. ".wav")

--os.execute("open -a Logic\ Pro.app /Users/esaruoho/Music/Logic/abs4/abs4/abs4.logic")
end
renoise.app():show_status("32Bit to 24Bit Conversion From Tmp-folder to Logic Smart Folder Done")
os.execute("cd /Users/esaruoho/Music/samples/LiveSmartFolder;open .") end

renoise.tool():add_keybinding{name="Global:Paketti:Save All Samples to Live Smart Folder", invoke=function() saveSamplesToLiveSmartFolder() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Logic Pro..:Save All Samples to Logic Smart Folder", invoke=function() saveSamplesToLogicSmartFolder() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Ableton Live..:Save All Samples to Live Smart Folder", invoke=function() saveSamplesToLiveSmartFolder() end}


----















