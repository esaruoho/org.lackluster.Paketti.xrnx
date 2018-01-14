-----------------------------------------------------------------------------------------------------------------------------------------

renoise.tool():add_keybinding  {name="Global:Paketti:VSTLister Dump", invoke=function()
local plugins = renoise.song().selected_instrument.plugin_properties.available_plugins
  for key, value in ipairs(plugins) do
    print(key, value)
  end
local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices
  for key, value in ipairs (devices) do 
    print(key, value)
  end end}

renoise.tool():add_keybinding {name="Global:Paketti:Dump Instruments to Console", invoke=function() 
local plugins = renoise.song().selected_instrument.plugin_properties.available_plugins
  for key, value in ipairs(plugins) do
    print(key, value)
  end
end}

renoise.tool():add_keybinding {name="Global:Paketti:Dump Effects to Console", invoke=function() 
local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices
  for key, value in ipairs (devices) do 
    print(key, value)
  end
end}


-----------------------------------------------------------------------------------------------------------------------------------------
function checkline(effect)
end

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
        for empty_instrument = 1, #proc.instruments do
                local samples = false

                for i = 1,#proc.instruments[empty_instrument].samples do
                        local temp_buffer = proc.instruments[empty_instrument].samples[i].sample_buffer
                        if temp_buffer.has_sample_data then
                                samples = true
                                break
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
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function LoadZebra()
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
renoise.song().selected_instrument.plugin_properties:load_plugin("Audio/Generators/VST/Zebra2")
if renoise.song().selected_instrument.plugin_properties.plugin_loaded
 then
 local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
 end
--renoise.app().window.active_lower_frame=3
--renoise.song().selected_instrument.active_tab=2 
end
renoise.tool():add_keybinding {name="Global:Paketti:Load U-He Zebra", invoke=function() LoadZebra() end}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function LoadPPG()
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
renoise.song().selected_instrument.plugin_properties:load_plugin("Audio/Generators/VST/PPG Wave 2.V")
if renoise.song().selected_instrument.plugin_properties.plugin_loaded
 then
 local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
 end
--renoise.app().window.active_lower_frame=3
--renoise.song().selected_instrument.active_tab=2 
end
renoise.tool():add_keybinding {name="Global:Paketti:Load Waldorf PPG v2", invoke=function() LoadPPG() end}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function LoadAttack()
local s=renoise.song()
s.selected_instrument_index = search_empty_instrument()
renoise.song().selected_instrument.plugin_properties:load_plugin("Audio/Generators/VST/Attack")
if renoise.song().selected_instrument.plugin_properties.plugin_loaded
 then
 local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
 if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
 end
--renoise.app().window.active_lower_frame=3
--renoise.song().selected_instrument.active_tab=2 
end
renoise.tool():add_keybinding  {name="Global:Paketti:Load Waldorf Attack", invoke=function() LoadAttack() end}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function loadnative(effect)
--This loads whichever thing you put inside (effect). See below for examples.
local checkline=nil
   if (table.count(renoise.song().selected_track.devices)) <2 then checkline=2
   else 
    if renoise.song().selected_track.devices[2].name=="#Line Input" then checkline=3
    else checkline=2
    end
   end
 renoise.app().window.lower_frame_is_visible=true
 renoise.app().window.active_lower_frame=1
 renoise.song().selected_track:insert_device_at(effect,checkline)
 renoise.song().selected_device_index = 2
end

renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Analog Filter",
invoke=function() loadnative("Audio/Effects/Native/Analog Filter") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Bus Compressor",
invoke=function() loadnative("Audio/Effects/Native/Bus Compressor") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Cabinet Simulator",
invoke=function() loadnative("Audio/Effects/Native/Cabinet Simulator") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Chorus",
invoke=function() loadnative("Audio/Effects/Native/Chorus") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Chorus 2",
invoke=function() loadnative("Audio/Effects/Native/Chorus 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Comb Filter 2",
invoke=function() loadnative("Audio/Effects/Native/Comb Filter 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Compressor",
invoke=function() loadnative("Audio/Effects/Native/Compressor") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Convolver",
invoke=function() loadnative("Audio/Effects/Native/Convolver") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise DC Offset",
invoke=function() loadnative("Audio/Effects/Native/DC Offset") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Delay",
invoke=function() loadnative("Audio/Effects/Native/Delay") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Digital Filter",
invoke=function() loadnative("Audio/Effects/Native/Digital Filter") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Distortion 2",
invoke=function() loadnative("Audio/Effects/Native/Distortion 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Doofer",
invoke=function() loadnative("Audio/Effects/Native/Doofer") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise EQ 5",
invoke=function() loadnative("Audio/Effects/Native/EQ 5") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise EQ 10",
invoke=function() loadnative("Audio/Effects/Native/EQ 10") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Exciter",
invoke=function() loadnative("Audio/Effects/Native/Exciter") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Flanger 2",
invoke=function() loadnative("Audio/Effects/Native/Flanger 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Gainer",
invoke=function() loadnative("Audio/Effects/Native/Gainer")
renoise.song().selected_track.devices[2].parameters[1].show_in_mixer=false end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Gate 2",
invoke=function() loadnative("Audio/Effects/Native/Gate 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise LofiMat 2",
invoke=function() loadnative("Audio/Effects/Native/LofiMat 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Maximizer",
invoke=function() loadnative("Audio/Effects/Native/Maximizer") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Mixer EQ",
invoke=function() loadnative("Audio/Effects/Native/Mixer EQ") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise mpReverb 2",
invoke=function() loadnative("Audio/Effects/Native/mpReverb 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Multitap",
invoke=function() loadnative("Audio/Effects/Native/Multitap") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Phaser 2",
invoke=function() loadnative("Audio/Effects/Native/Phaser 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Repeater",
invoke=function() loadnative("Audio/Effects/Native/Repeater") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Reverb",
invoke=function() loadnative("Audio/Effects/Native/Reverb") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise RingMod 2",
invoke=function() loadnative("Audio/Effects/Native/RingMod 2") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise Stereo Expander",
invoke=function() loadnative("Audio/Effects/Native/Stereo Expander") end}
-------#
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise #Line Input",
invoke=function() loadnative("Audio/Effects/Native/#Line Input")
renoise.song().selected_track.devices[2].parameters[2].show_in_mixer=true end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise #Multiband Send",
invoke=function() loadnative("Audio/Effects/Native/#Multiband Send")
renoise.song().selected_track.devices[2].parameters[1].show_in_mixer=false
renoise.song().selected_track.devices[2].parameters[3].show_in_mixer=false
renoise.song().selected_track.devices[2].parameters[5].show_in_mixer=false 
end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise #ReWire Input",
invoke=function() loadnative("Audio/Effects/Native/#ReWire Input") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise #Send",
invoke=function() loadnative("Audio/Effects/Native/#Send") end}
--------*
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Formula",
invoke=function() loadnative("Audio/Effects/Native/*Formula") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Hydra",
invoke=function() loadnative("Audio/Effects/Native/*Hydra") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Instr. Automation",
invoke=function() loadnative("Audio/Effects/Native/*Instr. Automation") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Instr. Macros",
invoke=function() loadnative("Audio/Effects/Native/*Instr. Macros") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Instr. MIDI Control",
invoke=function() loadnative("Audio/Effects/Native/*Instr. MIDI Control") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Key Tracker",
invoke=function() loadnative("Audio/Effects/Native/*Key Tracker") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *LFO",
invoke=function() loadnative("Audio/Effects/Native/*LFO") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Meta Mixer",
invoke=function() loadnative("Audio/Effects/Native/*Meta Mixer") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Signal Follower",
invoke=function() loadnative("Audio/Effects/Native/*Signal Follower") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *Velocity Tracker",
invoke=function() loadnative("Audio/Effects/Native/*Velocity Tracker") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Renoise *XY Pad",
invoke=function() loadnative("Audio/Effects/Native/*XY Pad") end}
----------------------------------------------------------------------------------------------------------------
--User-specific VST/AU efx loading. These are with very specific settings, so use at your own peril!
--Oct17th modification: Loadvst can be used to load the vst/au/native fx of your choice. Enjoy.
function loadvst(vstname)
local checkline=nil
  if (table.count(renoise.song().selected_track.devices)) <2 then checkline=2
  else 
   if renoise.song().selected_track.devices[2].name=="#Line Input" then checkline=3
   else checkline=2
   end
  end

local checkline=nil
if (table.count(renoise.song().selected_track.devices)) <2 then checkline=2
else if renoise.song().selected_track.devices[2].name=="#Line Input" then checkline=3
else checkline=2 end end
--renoise.tool():add_keybinding {name="Global:Track Devices:Load FabFilter Pro-Q", invoke=function() loadvst("Audio/Effects/VST/FabFilter Pro-Q")
--renoise.song().selected_track.devices[2].parameters[206].value=1 end}

  if renoise.app().window.lower_frame_is_visible==false then renoise.app().window.lower_frame_is_visible=false
else renoise.app().window.lower_frame_is_visible=true end

-- renoise.app().window.active_lower_frame=1
 renoise.song().selected_track:insert_device_at(vstname, checkline)
 renoise.song().selected_track.devices[checkline].external_editor_visible=true
 renoise.song().selected_track.devices[checkline].is_maximized=false
 
 renoise.song().selected_device_index= checkline
 
  if renoise.song().selected_track.devices[checkline].name=="VST: FabFilter: Pro-Q" then 
     renoise.song().selected_track.devices[checkline].parameters[206].value=1 
  else 
  end 
  
  if renoise.song().selected_track.devices[checkline].name=="AU: TAL-Togu Audio Line: TAL Reverb 4 Plugin" then 
     renoise.song().selected_track.devices[checkline].parameters[2].value=0.6 
     renoise.song().selected_track.devices[checkline].parameters[5].value=0.9
     renoise.song().selected_track.devices[checkline].parameters[6].value=1
     renoise.song().selected_track.devices[checkline].parameters[7].value=0.4
  else  end 
end

--Audio/Effects/AU/aufx:cHL1:TOGU
--Audio/Effects/AU/aumf:58h8:TOGU
--73  Audio/Effects/AU/aumf:676v:TOGU
--- AU
renoise.tool():add_keybinding {name="Global:Track Devices:Load D16 Syntorus", invoke=function() loadvst("Audio/Effects/AU/aufx:Sn7R:d16g") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load D16 Toraverb", invoke=function() loadvst("Audio/Effects/AU/aufx:T4V8:d16g") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load George Yohng's W1 1", invoke=function() loadvst("Audio/Effects/AU/aufx:4Fwl:Yhng") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load George Yohng's W1 2", invoke=function() 
renoise.song().selected_track:insert_device_at("Audio/Effects/AU/aufx:4FwL:4FNT", 2) end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load OhmForce Predatohm", invoke=function() loadvst("Audio/Effects/AU/aumf:Opdh:OmFo")end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load OhmForce Hematohm", invoke=function() loadvst("Audio/Effects/AU/aumf:OHmt:OmFo")end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load OhmForce OhmBoyz", invoke=function() loadvst("Audio/Effects/AU/aumf:OByZ:OmFo") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load QuikQuak FusionField", invoke=function() loadvst("Audio/Effects/AU/aumf:FuFi:QkQk") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load Schaack Transient Shaper", invoke=function() loadvst("Audio/Effects/VST/TransientShaper") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TAL-Reverb 4", invoke=function() loadvst("Audio/Effects/AU/aufx:reV4:TOGU") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TAL-Dub 3 AU", invoke=function() loadvst("Audio/Effects/AU/aumf:xg70:TOGU") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TAL-Chorus LX", invoke=function() loadvst("Audio/Effects/AU/aufx:cHL1:TOGU") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TAL-Chorus", invoke=function() loadvst("Audio/Effects/AU/aufx:Chor:Togu") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load ValhallaRoom", invoke=function() loadvst("Audio/Effects/AU/aufx:Ruum:oDin") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load ValhallaShimmer", invoke=function() loadvst("Audio/Effects/AU/aufx:shmr:oDin") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load ValhallaFreqEchoMkI", invoke=function() loadvst("Audio/Effects/AU/aufx:FqEh:oDin") end}
----------------------------------------------------------------------------------------------------------------------------------------------- VST
renoise.tool():add_keybinding {name="Global:Track Devices:Load FabFilter Pro-Q", invoke=function() loadvst("Audio/Effects/VST/FabFilter Pro-Q") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load GRM PitchAccum Stereo", invoke=function() loadvst("Audio/Effects/VST/GRM PitchAccum Stereo") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load GRM Delays Stereo", invoke=function() loadvst("Audio/Effects/VST/GRM Delays Stereo") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load GRM Reson Stereo", invoke=function() loadvst("Audio/Effects/VST/GRM Reson Stereo") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load TAL-Dub 3 VST", invoke=function() loadvst("Audio/Effects/VST/TAL-Dub-3") end}
renoise.tool():add_keybinding {name="Global:Track Devices:Load WatKat", invoke=function() loadvst("Audio/Effects/VST/WatKat") end}
---------------------------------------------------------------------------------------
--- Combinations
renoise.tool():add_keybinding {name="Global:Track Devices:Load EQ10+Schaack Transient Shaper", invoke=function() 
loadvst("Audio/Effects/VST/TransientShaper")
renoise.song().selected_track:insert_device_at("Audio/Effects/Native/EQ 10",2)
renoise.song().selected_device_index= 2 end}

renoise.tool():add_midi_mapping {name="Global:Track Devices:Load DC Offset", invoke=function()
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().selected_track:insert_device_at("Audio/Effects/Native/DC Offset",2)
renoise.song().selected_device_index = 2
renoise.song().selected_track.devices[2].parameters[2].value=1
end}

-- renoise.tool():add_midi_mapping {name="Global:Track Devices:Load #Send", invoke=function() loadnative("Audio/Effects/Native/#Send") end}
