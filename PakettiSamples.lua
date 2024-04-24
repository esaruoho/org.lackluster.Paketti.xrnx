



function selectedSampleInit()
renoise.song().instruments[renoise.song().selected_instrument_index].macros_visible=true
renoise.song().instruments[renoise.song().selected_instrument_index].macros[1].name="PitchCtrl"
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].autofade=true
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].interpolation_mode=4
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].oversample_enabled=true
end

renoise.tool():add_keybinding{name="Global:Paketti:Init Selected Sample (Autofade,Interpolation,Oversample)", invoke=function() 
selectedSampleInit() end}


function addSampleSlot(amount)
for i=1,amount do
renoise.song().instruments[renoise.song().selected_instrument_index]:insert_sample_at(i)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Add Sample Slot to Instrument", invoke=function() addSampleSlot(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Add 84 Sample Slots to Instrument", invoke=function() addSampleSlot(84) end}
-------------------------------------------------------------------------------------------------------------------------------
function LoopState(number)
renoise.song().selected_sample.loop_mode=number
end

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 1 Off",invoke=function() LoopState(1) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 2 Forward",invoke=function() LoopState(2) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 3 Reverse",invoke=function() LoopState(3) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 4 PingPong",invoke=function() LoopState(4) end}

function slicerough(changer)
    local s=renoise.song()
    s.selected_sample_index=1
    local currInst=s.selected_instrument_index
    local currSamp=s.selected_sample_index
    local number=(table.count(s.instruments[currInst].samples[currSamp].slice_markers))
    currSamp=1
    s.instruments[currInst].samples[currSamp].loop_mode = preferences.WipeSlicesLoopSetting.value
    s.instruments[currInst].samples[currSamp].new_note_action=1
    s.instruments[currInst].samples[currSamp].oneshot = preferences.WipeSlicesOneShot.value
    s.instruments[currInst].samples[currSamp].autofade=true
    s.instruments[currInst].samples[currSamp].autoseek = preferences.WipeSlicesAutoseek.value
    s.instruments[currInst].samples[currSamp].mute_group=1
    s.instruments[currInst].samples[currSamp].interpolation_mode=4
    s.instruments[currInst].samples[currSamp].beat_sync_mode = preferences.WipeSlicesBeatSyncMode.value
    s.instruments[currInst].samples[currSamp].oversample_enabled=true

    for i=1,number do 
        s.instruments[currInst].samples[currSamp]:delete_slice_marker((s.instruments[currInst].samples[currSamp].slice_markers[1]))
    end
    
    local tw=s.selected_sample.sample_buffer.number_of_frames/changer
    s.instruments[currInst].samples[currSamp]:insert_slice_marker(1)
    for i=1,changer do
        s.instruments[currInst].samples[currSamp]:insert_slice_marker(tw*i)
        s.instruments[currInst].samples[currSamp].autofade=true
    end

    s.selected_sample.beat_sync_enabled=true
    s.instruments[currInst].samples[currSamp].autofade=true
end
--
--Wipe all slices
function wipeslices()
local currInst=renoise.song().selected_instrument_index
local currSamp=renoise.song().selected_sample_index
local number=(table.count(renoise.song().instruments[currInst].samples[currSamp].slice_markers))

  for i=1,number do renoise.song().instruments[currInst].samples[currSamp]:delete_slice_marker((renoise.song().instruments[currInst].samples[currSamp].slice_markers[1]))
  end
  renoise.song().selected_sample.loop_mode=1
renoise.song().selected_sample.beat_sync_enabled=false
end

renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (004) x[Toggle]",invoke=function() slicerough(4) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (008) x[Toggle]",invoke=function() slicerough(8) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (016) x[Toggle]",invoke=function() slicerough(16) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (032) x[Toggle]",invoke=function() slicerough(32) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (064) x[Toggle]",invoke=function() slicerough(64) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (128) x[Toggle]",invoke=function() slicerough(128) end}

renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (128)",invoke=function() slicerough(128) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Slices",invoke=function() wipeslices() end}

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (128)",invoke=function() slicerough(128) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe Slices",invoke=function() wipeslices() end}

