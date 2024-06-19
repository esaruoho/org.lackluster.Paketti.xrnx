-- From Jenoki

function jenokiSystem(bpl,lpb,rowcount)
-- Set Transport LPB and Metronome LPB to x (lpb)
renoise.song().transport.lpb = lpb
renoise.song().transport.metronome_lines_per_beat = lpb
-- Set Transport TPL and Metronome Beats Ber Bar to y (bpl)
renoise.song().transport.tpl = bpl
renoise.song().transport.metronome_beats_per_bar = bpl
-- Set Pattern Row length to z (rowcount)
renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines=rowcount
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Time Signature 3/4 and 48 rows @ LPB 4",invoke=function() jenokiSystem(3,4,48) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Time Signature 7/8 and 56 rows @ LPB 8",invoke=function() jenokiSystem(7,8,56) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Set Time Signature 6/8 and 48 rows @ LPB 8",invoke=function() jenokiSystem(6,8,48) end}

-- All of these have been requested by tkna91 via 
-- https://github.com/esaruoho/org.lackluster.Paketti.xrnx/issues/
-- Please send requests if you're interested in obscure stuff that Renoise does not support (but really, should)

function loopReleaseToggle()
if renoise.song().selected_sample.loop_release
then renoise.song().selected_sample.loop_release=false 
else renoise.song().selected_sample.loop_release=true end
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Loop Release On/Off",invoke=function() loopReleaseToggle() end}

function oneShotToggle()
if renoise.song().selected_sample.oneshot 
then renoise.song().selected_sample.oneshot=false 
else renoise.song().selected_sample.oneshot=true end
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample One-Shot On/Off",invoke=function() oneShotToggle() end}

function selectedSampleLoopSet(number)
renoise.song().selected_sample.oneshot=false
local loop_modet = renoise.song().selected_sample.loop_mode
  if renoise.song().selected_sample.loop_mode==number then renoise.song().selected_sample.loop_mode=1 else loop_modet = number
  renoise.song().selected_sample.loop_mode=loop_modet
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Loop 1 (Off)",invoke=function() selectedSampleLoopSet(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Loop 2 (Forward)",invoke=function() selectedSampleLoopSet(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Loop 3 (Backward)",invoke=function() selectedSampleLoopSet(3) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Loop 4 (PingPong)",invoke=function() selectedSampleLoopSet(4) end}

function selectedSampleTranspose(amount)
local currentSampleTranspose = renoise.song().selected_sample.transpose
local changedSampleTranspose = currentSampleTranspose + amount
if changedSampleTranspose > 120 then changedSampleTranspose = 120
else if changedSampleTranspose < -120 then changedSampleTranspose = -120 end end
renoise.song().selected_sample.transpose=changedSampleTranspose
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Transpose (-1)",invoke=function() selectedSampleTranspose(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Transpose (+1)",invoke=function() selectedSampleTranspose(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Transpose (-12)",invoke=function() selectedSampleTranspose(-12) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Transpose (+12)",invoke=function() selectedSampleTranspose(12) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose (0)",invoke=function() renoise.song().selected_sample.transpose=0 end}

function selectedSampleFinetune(amount)
local currentSampleFinetune = renoise.song().selected_sample.fine_tune
local changedSampleFinetune = currentSampleFinetune + amount
if changedSampleFinetune > 127 then changedSampleFinetune = 127
else if changedSampleFinetune < -127 then changedSampleFinetune = -127 end end
renoise.song().selected_sample.fine_tune=changedSampleFinetune
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune (-1)",invoke=function() selectedSampleFinetune(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune (+1)",invoke=function() selectedSampleFinetune(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune (-10)",invoke=function() selectedSampleFinetune(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune (+10)",invoke=function() selectedSampleFinetune(10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune (0)",invoke=function() renoise.song().selected_sample.fine_tune=0 end}

function selectedSamplePanning(amount)
local currentSamplePanning = renoise.song().selected_sample.panning
local changedSamplePanning = currentSamplePanning + amount
if changedSamplePanning > 1.0 then changedSamplePanning = 1.0
else if changedSamplePanning < 0.0 then changedSamplePanning = 0.0 end end
renoise.song().selected_sample.panning=changedSamplePanning
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning 0.5 (Center)",invoke=function() renoise.song().selected_sample.panning=0.5 end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning 0.0 (Left)",invoke=function() renoise.song().selected_sample.panning=0.0 end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning 1.0 (Right)",invoke=function() renoise.song().selected_sample.panning=1.0 end}
 
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning (+0.01)",invoke=function() selectedSamplePanning(0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning (-0.01)",invoke=function() selectedSamplePanning(-0.01) end}

function selectedSampleVolume(amount)
local currentSampleVolume = renoise.song().selected_sample.volume
local changedSampleVolume = currentSampleVolume + amount
if changedSampleVolume > 4.0 then changedSampleVolume = 4.0
else if changedSampleVolume < 0.0 then changedSampleVolume = 0.0 end end
renoise.song().selected_sample.volume=changedSampleVolume
end
 
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Volume (+0.01)",invoke=function() selectedSampleVolume(0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Volume (-0.01)",invoke=function() selectedSampleVolume(-0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Volume Reset (0.0dB)",invoke=function() renoise.song().selected_sample.volume=1 end }

function selectedSampleInterpolation(amount)
renoise.song().selected_sample.interpolation_mode=amount
end

function selectedSampleOversampleOn()
renoise.song().selected_sample.oversample_enabled=true
end

function selectedSampleOversampleOff()
renoise.song().selected_sample.oversample_enabled=false
end

function selectedSampleOversampleToggle()
if renoise.song().selected_sample.oversample_enabled then
 renoise.song().selected_sample.oversample_enabled = false else
 renoise.song().selected_sample.oversample_enabled = true
end end

function selectedSampleAutoseekToggle()
if renoise.song().selected_sample.autoseek then
 renoise.song().selected_sample.autoseek = false else
 renoise.song().selected_sample.autoseek = true
end end

function selectedSampleAutofadeToggle()
if renoise.song().selected_sample.autofade then
 renoise.song().selected_sample.autofade = false else
 renoise.song().selected_sample.autofade = true
end end

function selectedSampleNNA(number)
renoise.song().selected_sample.new_note_action = number
end


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Interpolation to 1 (None)",invoke=function() selectedSampleInterpolation(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Interpolation to 2 (Linear)",invoke=function() selectedSampleInterpolation(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Interpolation to 3 (Cubic)",invoke=function() selectedSampleInterpolation(3) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Interpolation to 4 (Sinc)",invoke=function() selectedSampleInterpolation(4) end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Oversample On",invoke=function() selectedSampleOversampleOn() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Oversample Off",invoke=function() selectedSampleOversampleOff() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Oversample On/Off",invoke=function() selectedSampleOversampleToggle() end}

function selectedSampleBeatsync(number)
renoise.song().selected_sample.beat_sync_mode = number
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync 1 (Repitch)",invoke=function() selectedSampleBeatsync(1) end }
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync 2 (Time-Stretch Percussion)",invoke=function() selectedSampleBeatsync(2) end }
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync 3 (Time-Stretch Texture)",invoke=function() selectedSampleBeatsync(3) end }

function selectedSampleBeatsyncAndToggleOn(number)
if renoise.song().selected_sample == nil then return else

if renoise.song().selected_sample.beat_sync_enabled and renoise.song().selected_sample.beat_sync_mode ~= number then
renoise.song().selected_sample.beat_sync_mode = number
return end
renoise.song().selected_sample.beat_sync_mode = number


if renoise.song().selected_sample.beat_sync_enabled == false then
renoise.song().selected_sample.beat_sync_enabled = true
renoise.song().selected_sample.beat_sync_mode = number
else 
renoise.song().selected_sample.beat_sync_enabled = false
end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync On/Off 1 (Repitch)",invoke=function() selectedSampleBeatsyncAndToggleOn(1) end }
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync On/Off 2 (Time-Stretch Percussion)",invoke=function() selectedSampleBeatsyncAndToggleOn(2) end }
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync On/Off 3 (Time-Stretch Texture)",invoke=function() selectedSampleBeatsyncAndToggleOn(3) end }


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync On/Off",invoke=function()
if renoise.song().selected_sample == nil then return else

if renoise.song().selected_sample.beat_sync_enabled then
 renoise.song().selected_sample.beat_sync_enabled = false else
 renoise.song().selected_sample.beat_sync_enabled = true
end end end}

function selectedSampleBeatsyncLine(number)
local currentBeatsyncLine = renoise.song().selected_sample.beat_sync_lines
local changedBeatsyncLine = currentBeatsyncLine + number
if changedBeatsyncLine > 512 then changedBeatsyncLine = 512
else if changedBeatsyncLine < 1 then -- renoise.song().selected_sample.beat_sync_enabled = false 
return end end
renoise.song().selected_sample.beat_sync_lines=changedBeatsyncLine
renoise.song().selected_sample.beat_sync_enabled = true
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync Line (+1)",invoke=function() selectedSampleBeatsyncLine(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync Line (-1)",invoke=function() selectedSampleBeatsyncLine(-1) end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Autofade On/Off",invoke=function() selectedSampleAutofadeToggle() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Autoseek On/Off",invoke=function() selectedSampleAutoseekToggle() end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample NNA to 1 (Cut)",invoke=function() selectedSampleNNA(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample NNA to 2 (Note-Off)",invoke=function() selectedSampleNNA(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample NNA to 3 (Continue)",invoke=function() selectedSampleNNA(3) end}

function selectedSampleMuteGroup(number)
if renoise.song().selected_sample == nil then return else 
renoise.song().selected_sample.mute_group = number end
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 0 (Off)",invoke=function() selectedSampleMuteGroup(0) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 1",invoke=function() selectedSampleMuteGroup(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 2",invoke=function() selectedSampleMuteGroup(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 3",invoke=function() selectedSampleMuteGroup(3) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 4",invoke=function() selectedSampleMuteGroup(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 5",invoke=function() selectedSampleMuteGroup(5) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 6",invoke=function() selectedSampleMuteGroup(6) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 7",invoke=function() selectedSampleMuteGroup(7) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 8",invoke=function() selectedSampleMuteGroup(8) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to 9",invoke=function() selectedSampleMuteGroup(9) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to A",invoke=function() selectedSampleMuteGroup(10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to B",invoke=function() selectedSampleMuteGroup(11) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to C",invoke=function() selectedSampleMuteGroup(12) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to D",invoke=function() selectedSampleMuteGroup(13) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to E",invoke=function() selectedSampleMuteGroup(14) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mute Group to F",invoke=function() selectedSampleMuteGroup(15) end}

-- Change Output Routing per Selected Track
function set_output_routing_by_index(number)
    local available_output_routings = renoise.song().tracks[renoise.song().selected_track_index].available_output_routings

    if number >= 1 and number <= #available_output_routings then
        renoise.song().tracks[renoise.song().selected_track_index].output_routing = available_output_routings[number]
    else
        print("Index out of range. Please use an index between 1 and " .. #available_output_routings)
    end
end

function find_current_routing_index(available_routings, current_routing)
    for index, routing in ipairs(available_routings) do
        if routing == current_routing then
            return index
        end
    end
    return nil -- Return nil if the current routing is not found
end

function apply_selected_routing(selected_index)
    local selected_track_index = renoise.song().selected_track_index
    local available_output_routings = renoise.song().tracks[selected_track_index].available_output_routings

    if selected_index and selected_index >= 1 and selected_index <= #available_output_routings then
        renoise.song().tracks[selected_track_index].output_routing = available_output_routings[selected_index]
    else
        print("Index out of range. Please use an index between 1 and " .. #available_output_routings)
    end
end

-- Function to open a dialog with the list of available output routings using a popup
function showAvailableRoutings()
    local selected_track_index = renoise.song().selected_track_index
    local available_output_routings = renoise.song().tracks[selected_track_index].available_output_routings
    local current_routing = renoise.song().tracks[selected_track_index].output_routing
    local selected_routing_index = find_current_routing_index(available_output_routings, current_routing)

    -- Create a ViewBuilder object
    local vb = renoise.ViewBuilder()

    local dialog -- Pre-declare the dialog variable so it can be referenced inside button callbacks

    -- Define the content of the dialog
    local dialog_content = vb:column {
        margin = 10,
        spacing = 5,
        vb:text {
            text = "Select Output Routing:"
        },
        vb:popup {
            id = "popup_output_routings",
            items = available_output_routings,
            value = selected_routing_index or 1, -- Set the popup to the current routing, or default to the first item
            width = 300,
            notifier = function(index)
                -- Update the selected index when a new item is selected
                selected_routing_index = index
            end
        },
        vb:row {
            spacing = 10,
            vb:button {
                text = "OK",
                notifier = function()
                    apply_selected_routing(selected_routing_index)
                    dialog:close()
                end
            },
            vb:button {
                text = "Cancel",
                notifier = function()
                    dialog:close()
                end
            }
        }
    }

    -- Show the dialog
    dialog = renoise.app():show_custom_dialog("Output Routings", dialog_content)
end




function simpleOutputRoute(output)
  -- Get the selected track from the current song
  local track = renoise.song().tracks[renoise.song().selected_track_index]
  
  -- Check if the desired output index is within the range of available output routings
  if output <= #track.available_output_routings then
    -- If the index is valid, set the output routing
    track.output_routing = track.available_output_routings[output]
  else
    -- If the index is invalid (i.e., the output doesn't exist), do nothing.
  end
end


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 00 Master" ,invoke=function() simpleOutputRoute(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 01" ,invoke=function() simpleOutputRoute(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 02" ,invoke=function() simpleOutputRoute(3) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 03" ,invoke=function() simpleOutputRoute(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 04" ,invoke=function() simpleOutputRoute(5) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 05" ,invoke=function() simpleOutputRoute(6) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 06" ,invoke=function() simpleOutputRoute(7) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 07" ,invoke=function() simpleOutputRoute(8) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 08" ,invoke=function() simpleOutputRoute(9) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 09" ,invoke=function() simpleOutputRoute(10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 10" ,invoke=function() simpleOutputRoute(11) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 11" ,invoke=function() simpleOutputRoute(12) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 12" ,invoke=function() simpleOutputRoute(13) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 13" ,invoke=function() simpleOutputRoute(14) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 14" ,invoke=function() simpleOutputRoute(15) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 15" ,invoke=function() simpleOutputRoute(16) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Output Routing 16" ,invoke=function() simpleOutputRoute(17) end}

function setBeatsyncLineAbove()
    local currentBeatsyncLine = renoise.song().selected_sample.beat_sync_lines
    -- Calculate the next higher power of 2
    local power = math.ceil(math.log(currentBeatsyncLine) / math.log(2))
    local nextPowerOfTwo = 2 ^ power
    if nextPowerOfTwo <= currentBeatsyncLine then -- Ensure we actually move up
        nextPowerOfTwo = nextPowerOfTwo * 2
    end
    -- Clamp to maximum allowed value
    if nextPowerOfTwo > 512 then nextPowerOfTwo = 512 end
    renoise.song().selected_sample.beat_sync_lines = nextPowerOfTwo
    renoise.song().selected_sample.beat_sync_enabled = true
end

function setBeatsyncLineBelow()
    local currentBeatsyncLine = renoise.song().selected_sample.beat_sync_lines
    if currentBeatsyncLine <= 1 then -- Prevent going below 1
        return
    end
    local power = math.floor(math.log(currentBeatsyncLine) / math.log(2))
    local prevPowerOfTwo = 2 ^ power
    if prevPowerOfTwo >= currentBeatsyncLine then -- Ensure we actually move down
        prevPowerOfTwo = prevPowerOfTwo / 2
    end
    renoise.song().selected_sample.beat_sync_lines = prevPowerOfTwo
    renoise.song().selected_sample.beat_sync_enabled = true
end


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync Line (Power of Two Above)",invoke=function() setBeatsyncLineAbove() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync Line (Power of Two Below)",invoke=function() setBeatsyncLineBelow() end}

-- Shortcuts as requested by Casiino
-- 
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity (-16)",invoke=function() computerKeyboardVolChange(-16) end}
renoise.tool():add_keybinding{name="Global:Paketti:Computer Keyboard Velocity (+16)",invoke=function() computerKeyboardVolChange(16) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Decrease (-5)",invoke=function() adjust_bpm(-5, 0) end}
renoise.tool():add_keybinding{name="Global:Paketti:BPM Increase (+5)",invoke=function() adjust_bpm(5, 0) end}

function loopExitToggle()
  if 
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].loop_release 
  then 
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].loop_release=false
  else
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].loop_release=true
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Exit Loop Note-Off Toggle",invoke=function() loopExitToggle() end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Exit Loop Note-Off Off",invoke=function() 
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].loop_release=false
 end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Exit Loop Note-Off On",invoke=function() 
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].loop_release=true
 end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Autofade On",invoke=function() renoise.song().selected_sample.autofade=true end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Autofade Off",invoke=function() renoise.song().selected_sample.autofade=false end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune (-5)",invoke=function() selectedSampleFinetune(-5) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune (+5)",invoke=function() selectedSampleFinetune(5) end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Volume (+0.05)",invoke=function() selectedSampleVolume(0.05) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Volume (-0.05)",invoke=function() selectedSampleVolume(-0.05) end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning (+0.05)",invoke=function() selectedSamplePanning(0.05) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning (-0.05)",invoke=function() selectedSamplePanning(-0.05) end}


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Transpose (-5)",invoke=function() selectedSampleTranspose(-5) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Transpose (+5)",invoke=function() selectedSampleTranspose(5) end}

-- Function to assign a modulation set to the selected sample based on a given index
function selectedSampleMod(number)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]
  
  -- Check if there are any modulation sets
  if not instrument or #instrument.sample_modulation_sets == 0 then
    print("No modulation sets available or no instrument selected.")
    return
  end
  
  -- Get the number of available modulation sets
  local num_modulation_sets = #instrument.sample_modulation_sets
  
  -- Check if the provided index is within the valid range
  -- Adjusting to include 0 in the check, as it represents no modulation set assigned
  if number < 0 or number > num_modulation_sets then
    -- print("Invalid modulation_set_index value '" .. number .. "'. Valid values are (0 to " .. num_modulation_sets .. ").")
    return
  end

  -- Assign the modulation set index to the selected sample
  -- This assignment now confidently allows setting the index to 0
  instrument.samples[renoise.song().selected_sample_index].modulation_set_index = number
end

-- Function to assign an FX chain to the selected sample based on a given index
function selectedSampleFX(number)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]
  
  -- Check if there are any FX chains
  if not instrument or #instrument.sample_device_chains == 0 then
    print("No FX chains available or no instrument selected.")
    return
  end
  
  -- Get the number of available FX chains
  local num_fx_sets = #instrument.sample_device_chains
  
  -- Check if the provided index is within the valid range
  -- Adjusting to include 0 in the check, as it represents no FX chain assigned
  if number < 0 or number > num_fx_sets then
    -- print("Invalid device_chain_index value '" .. number .. "'. Valid values are (0 to " .. num_fx_sets .. ").")
    return
  end

  -- Assign the FX chain index to the selected sample
  -- This assignment confidently allows setting the index to 0
  instrument.samples[renoise.song().selected_sample_index].device_chain_index = number
end

for i = 0, 9 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mod to 0" .. i,
    invoke = function() selectedSampleMod(i) end}
end

for i = 10, 32 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mod to " .. i,
    invoke = function() selectedSampleMod(i) end}
end


for i = 0, 9 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample FX to 0" .. i,invoke=function() selectedSampleFX(i) end}
end

for i = 10, 32 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample FX to " .. i,invoke=function() selectedSampleFX(i) end}
end

-- Function to assign a modulation set index to all samples in the selected instrument
function selectedInstrumentAllMod(number)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if the instrument and samples are valid
  if not instrument or #instrument.samples == 0 then
    print("No samples are available or no instrument selected.")
    return
  end

  -- Get the number of available modulation sets
  local num_modulation_sets = #instrument.sample_modulation_sets

  -- Check if the provided index is within the valid range
  if number < 0 or number > num_modulation_sets then
    print("Invalid modulation_set_index value '" .. number .. "'. Valid values are (0 to " .. num_modulation_sets .. ").")
    return
  end

  -- Assign the modulation set index to each sample in the instrument
  for i, sample in ipairs(instrument.samples) do
    sample.modulation_set_index = number
  end
end


for i = 0, 9 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument All Mod to 0" .. i,invoke=function() selectedInstrumentAllMod(i) end}
end
for i = 10, 32 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument All Mod to " .. i,invoke=function() selectedInstrumentAllMod(i) end}
end

-- Function to assign an FX chain index to all samples in the selected instrument
function selectedInstrumentAllFx(number)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if the instrument and samples are valid
  if not instrument or #instrument.samples == 0 then
    print("No samples are available or no instrument selected.")
    return
  end

  -- Get the number of available FX chains
  local num_fx_sets = #instrument.sample_device_chains

  -- Check if the provided index is within the valid range
  if number < 0 or number > num_fx_sets then
    print("Invalid device_chain_index value '" .. number .. "'. Valid values are (0 to " .. num_fx_sets .. ").")
    return
  end

  -- Assign the FX chain index to each sample in the instrument
  for i, sample in ipairs(instrument.samples) do
    sample.device_chain_index = number
  end
end

for i = 1, 9 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument All Fx to 0" .. i,invoke=function() selectedInstrumentAllFx(i) end}
end

for i = 10, 32 do
  renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument All Fx to " .. i,invoke=function() selectedInstrumentAllFx(i) end}
end


-- Function to toggle the autofade setting for all samples in the selected instrument
function selectedInstrumentAllAutofadeToggle()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if the instrument and samples are valid
  if not instrument or #instrument.samples == 0 then
    print("No samples are available or no instrument selected.")
    return
  end

  -- Iterate through each sample in the instrument and toggle the autofade setting
  for i, sample in ipairs(instrument.samples) do
    sample.autofade = not sample.autofade
  end
end

-- Function to set the autofade setting for all samples in the selected instrument based on a given state
function selectedInstrumentAllAutofadeControl(state)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if the instrument and samples are valid
  if not instrument or #instrument.samples == 0 then
    --print("No samples are available or no instrument selected.")
    return
  end

  -- Convert numerical state to boolean for autofade
  local autofadeState = (state == 1)

  -- Iterate through each sample in the instrument and set the autofade setting
  for i, sample in ipairs(instrument.samples) do
    sample.autofade = autofadeState
  end
end




renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument All Autofade On/Off",invoke=function() selectedInstrumentAllAutofadeToggle() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument All Autofade On",invoke=function() selectedInstrumentAllAutofadeControl(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument All Autofade Off",invoke=function() selectedInstrumentAllAutofadeControl(0) end}

function halveBeatSyncLines()
    local s = renoise.song()
    local currInst = s.selected_instrument_index
    local samples = s.instruments[currInst].samples
    if #samples < 2 then
        print("Not enough samples to perform operation.")
        return
    end

    -- Starting the check from the second sample
    local reference_sync_lines = samples[2].beat_sync_lines
    for i = 2, #samples do
        if samples[i].beat_sync_lines ~= reference_sync_lines then
            print("Not all samples (excluding the first) have the same beat_sync_lines.")
            return
        end
    end

    local new_sync_lines = reference_sync_lines * 2
    new_sync_lines = math.min(new_sync_lines, 512)  -- Ensure it does not exceed 512
    for i = 2, #samples do
        samples[i].beat_sync_lines = new_sync_lines
    end

    renoise.app():show_status("Beat sync lines halved for all samples (excluding the first) from " .. reference_sync_lines .. " to " .. new_sync_lines)
end



function doubleBeatSyncLines()
    local s = renoise.song()
    local currInst = s.selected_instrument_index
    local samples = s.instruments[currInst].samples
    if #samples < 2 then
        print("Not enough samples to perform operation.")
        return
    end

    -- Starting the check from the second sample
    local reference_sync_lines = samples[2].beat_sync_lines
    for i = 2, #samples do
        if samples[i].beat_sync_lines ~= reference_sync_lines then
            print("Not all samples (excluding the first) have the same beat_sync_lines.")
            return
        end
    end

    local new_sync_lines = reference_sync_lines / 2
    new_sync_lines = math.max(new_sync_lines, 1)  -- Ensure it does not fall below 1
    for i = 2, #samples do
        samples[i].beat_sync_lines = new_sync_lines
    end

    renoise.app():show_status("Beat sync lines doubled for all samples (excluding the first) from " .. reference_sync_lines .. " to " .. new_sync_lines)
end





renoise.tool():add_keybinding{name="Global:Paketti:Halve Beat Sync Lines",invoke=function() halveBeatSyncLines() end}

renoise.tool():add_keybinding{name="Global:Paketti:Double Beat Sync Lines",invoke=function() doubleBeatSyncLines() end}

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Instruments:Beat Sync Lines Halve",invoke=function() halveBeatSyncLines() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Beat Sync Lines Double",invoke=function() doubleBeatSyncLines() end}



function pitchedInstrument(st)
renoise.app():load_instrument("Presets/" .. st .. "st_Pitchbend.xrni")
renoise.song().selected_instrument.name=(st .. "st_Pitchbend Instrument")
renoise.song().instruments[renoise.song().selected_instrument_index].macros_visible = true
renoise.song().instruments[renoise.song().selected_instrument_index].sample_modulation_sets[1].name=(st .. "st_Pitchbend")
end

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Instruments:12st PitchBend Instrument Init",invoke=function() pitchedInstrument(12) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:24st PitchBend Instrument Init",invoke=function() pitchedInstrument(24) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:36st PitchBend Instrument Init",invoke=function() pitchedInstrument(36) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:48st PitchBend Instrument Init",invoke=function() pitchedInstrument(48) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:64st PitchBend Instrument Init",invoke=function() pitchedInstrument(64) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:96st PitchBend Instrument Init",invoke=function() pitchedInstrument(96) end}

renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Initialize..:12st PitchBend Instrument Init",invoke=function() pitchedInstrument(12) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:24st PitchBend Instrument Init",invoke=function() pitchedInstrument(24) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:36st PitchBend Instrument Init",invoke=function() pitchedInstrument(36) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:48st PitchBend Instrument Init",invoke=function() pitchedInstrument(48) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:64st PitchBend Instrument Init",invoke=function() pitchedInstrument(64) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:96st PitchBend Instrument Init",invoke=function() pitchedInstrument(96) end}

renoise.tool():add_keybinding{name="Global:Paketti:12st PitchBend Instrument Init", invoke=function() pitchedInstrument(12) end}
renoise.tool():add_keybinding{name="Global:Paketti:24st PitchBend Instrument Init", invoke=function() pitchedInstrument(24) end}
renoise.tool():add_keybinding{name="Global:Paketti:36st PitchBend Instrument Init", invoke=function() pitchedInstrument(36) end}
renoise.tool():add_keybinding{name="Global:Paketti:48st PitchBend Instrument Init", invoke=function() pitchedInstrument(48) end}
renoise.tool():add_keybinding{name="Global:Paketti:64st PitchBend Instrument Init", invoke=function() pitchedInstrument(64) end}
renoise.tool():add_keybinding{name="Global:Paketti:96st PitchBend Instrument Init", invoke=function() pitchedInstrument(96) end}


function transposeAllSamplesInInstrument(amount)
    -- Access the currently selected instrument in Renoise
    local instrument = renoise.song().selected_instrument
    -- Iterate through all samples in the instrument
    for i = 1, #instrument.samples do
        -- Access each sample's transpose property
        local currentTranspose = instrument.samples[i].transpose
        local newTranspose = currentTranspose + amount
        -- Clamp the transpose value to be within the valid range of -120 to 120
        if newTranspose > 120 then
            newTranspose = 120
        elseif newTranspose < -120 then
            newTranspose = -120
        end
        -- Apply the new transpose value to the sample
        instrument.samples[i].transpose = newTranspose
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Transpose (-1)",
    invoke = function() transposeAllSamplesInInstrument(-1) end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Transpose (+1)",
    invoke = function() transposeAllSamplesInInstrument(1) end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Transpose (-12)",
    invoke = function() transposeAllSamplesInInstrument(-12) end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Transpose (+12)",
    invoke = function() transposeAllSamplesInInstrument(12) end}

function resetInstrumentTranspose(amount)
    -- Access the currently selected instrument in Renoise
    local instrument = renoise.song().selected_instrument
    -- Iterate through all samples in the instrument
    for i = 1, #instrument.samples do
        -- Apply the new transpose value to the sample
        instrument.samples[i].transpose = 0
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Transpose 0 (Reset)",
invoke=function() resetInstrumentTranspose(0) end}

---
--another from casiino:
-- Access the Renoise song API
-- Jump to Group experimental


--another from casiino
-- Velocity Tracking On/Off for each Sample in the Instrument:
function selectedInstrumentVelocityTracking(enable)
  -- Access the selected instrument
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Determine the new state based on the passed argument
  local newState = (enable == 1)

  -- Iterate over all sample mapping groups
  for group_index, sample_mapping_group in ipairs(instrument.sample_mappings) do
    -- Iterate over each mapping in the group
    for mapping_index, mapping in ipairs(sample_mapping_group) do
      -- Set the map_velocity_to_volume based on newState
      mapping.map_velocity_to_volume = newState
      -- Optionally output the change to the terminal for confirmation
      print(string.format("Mapping Group %d, Mapping %d: map_velocity_to_volume set to %s", group_index, mapping_index, tostring(mapping.map_velocity_to_volume)))
    end
  end
end



renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Velocity Tracking On",
invoke=function() selectedInstrumentVelocityTracking(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Velocity Tracking Off",
invoke=function() selectedInstrumentVelocityTracking(0) end}


function selectedSampleVelocityTracking(enable)
  -- Access the selected instrument
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]
  -- Get the selected sample index
  local selected_sample_index = renoise.song().selected_sample_index

  -- Determine the new state based on the passed argument
  local newState = (enable == 1)

  -- Iterate over all mappings in the selected instrument
  for _, mapping in ipairs(instrument.sample_mappings[1]) do  -- Assuming [1] is the correct layer, adjust if needed
    -- Check if the mapping corresponds to the selected sample
    if mapping.sample_index == selected_sample_index then
      -- Set the map_velocity_to_volume based on newState
      mapping.map_velocity_to_volume = newState
      -- Optionally output the change to the terminal for confirmation
      print(string.format("Mapping for Sample %d: map_velocity_to_volume set to %s", selected_sample_index, tostring(mapping.map_velocity_to_volume)))
    end
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Toggle Selected Sample Velocity Tracking",
invoke=function() 
if
renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[1][renoise.song().selected_sample_index].map_velocity_to_volume==true
then renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[1][renoise.song().selected_sample_index].map_velocity_to_volume=false
else renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[1][renoise.song().selected_sample_index].map_velocity_to_volume=true
 end
 end}

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Velocity Tracking On",
invoke=function() 
renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[1][renoise.song().selected_sample_index].map_velocity_to_volume=true
end}


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Velocity Tracking Off",
invoke=function() 
renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[1][renoise.song().selected_sample_index].map_velocity_to_volume=false
end}



-------------
function selectInstrumentShortcut(instrumentNumber)
local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

local instCount = #renoise.song().instruments
  
if  instCount < instrumentNumber then 
renoise.app():show_status("This Instrument Number does not exist: " .. instrumentNumber)

else
renoise.song().selected_instrument_index = instrumentNumber
end
end


for i = 0, 32 do 
renoise.tool():add_keybinding{name="Global:Paketti:Select Instrument " .. i,invoke=function() selectInstrumentShortcut(i) end}
end
------
function selectNextGroupTrack()
    local song = renoise.song()
    local current_index = song.selected_track_index
    local num_tracks = #song.tracks

    -- Start from the next track of the currently selected one and loop around if necessary
    for i = current_index + 1, num_tracks + current_index do
        -- Use modulo operation to wrap around the track index when it exceeds the number of tracks
        local track_index = (i - 1) % num_tracks + 1
        if song.tracks[track_index].type == renoise.Track.TRACK_TYPE_GROUP then
            song.selected_track_index = track_index
            print("Moved to next group track: " .. song.tracks[track_index].name)
            return -- Exit after finding and moving to the next group track
        end
    end
end

function selectPreviousGroupTrack()
    local song = renoise.song()
    local current_index = song.selected_track_index
    local num_tracks = #song.tracks

    -- Start from the track just before the currently selected one and loop around if necessary
    for i = current_index - 1, current_index - num_tracks, -1 do
        -- Use modulo operation to wrap around the track index when it goes below 1
        local track_index = (i - 1) % num_tracks + 1
        if song.tracks[track_index].type == renoise.Track.TRACK_TYPE_GROUP then
            song.selected_track_index = track_index
            print("Moved to previous group track: " .. song.tracks[track_index].name)
            return -- Exit after finding and moving to the previous group track
        end
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Select Group (Next)", invoke=function() selectNextGroupTrack() end}
renoise.tool():add_keybinding{name="Global:Paketti:Select Group (Previous)", invoke=function() selectPreviousGroupTrack() end}



renoise.tool():add_keybinding{name="Global:Paketti:Delete / Clear / Wipe Entire Row", invoke=function() renoise.song().selected_line:clear() end}
-----
renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Set Selected Instrument Velocity Tracking On",invoke=function()  selectedInstrumentVelocityTracking(1) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Set Selected Instrument Velocity Tracking Off",invoke=function() selectedInstrumentVelocityTracking(0) end}

renoise.tool():add_menu_entry{name="--Sample Mappings:Paketti..:Set Selected Instrument Velocity Tracking On",invoke=function()  selectedInstrumentVelocityTracking(1) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Set Selected Instrument Velocity Tracking Off",invoke=function() selectedInstrumentVelocityTracking(0) end}

function setInstrumentVolume(amount)
    -- Access the currently selected instrument in Renoise
    local instrument = renoise.song().selected_instrument

    -- Iterate through all samples in the instrument
    for i = 1, #instrument.samples do
        -- Access each sample's volume property
        local currentVolume = instrument.samples[i].volume
        local newVolume = currentVolume + amount

        -- Clamp the volume value to be within the valid range of 0.0 to 4.0
        if newVolume > 4.0 then
            newVolume = 4.0
        elseif newVolume < 0.0 then
            newVolume = 0.0
        end

        -- Apply the new volume value to the sample
        instrument.samples[i].volume = newVolume
    end
end

-- Keybindings to adjust the volume of all samples in the selected instrument
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Volume (+0.01)",invoke=function() setInstrumentVolume(0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Volume (-0.01)",invoke=function() setInstrumentVolume(-0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Volume Reset (0.0dB)",invoke=function()
    local instrument = renoise.song().selected_instrument
    for i = 1, #instrument.samples do
        instrument.samples[i].volume = 1
    end
end}

function setInstrumentPanning(amount)
    -- Access the currently selected instrument in Renoise
    local instrument = renoise.song().selected_instrument

    -- Iterate through all samples in the instrument
    for i = 1, #instrument.samples do
        -- Access each sample's panning property
        local currentPanning = instrument.samples[i].panning
        local newPanning = currentPanning + amount

        -- Clamp the panning value to be within the valid range of 0.0 to 1.0
        if newPanning > 1.0 then
            newPanning = 1.0
        elseif newPanning < 0.0 then
            newPanning = 0.0
        end

        -- Apply the new panning value to the sample
        instrument.samples[i].panning = newPanning
    end
end

function setInstrumentPanningValue(value)
    -- Access the currently selected instrument in Renoise
    local instrument = renoise.song().selected_instrument

    -- Iterate through all samples in the instrument
    for i = 1, #instrument.samples do
        -- Set the panning value to the sample
        instrument.samples[i].panning = value
    end
end

-- Keybindings to adjust the panning of all samples in the selected instrument
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Panning (+0.01)",invoke=function() setInstrumentPanning(0.01) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Panning (-0.01)",invoke=function() setInstrumentPanning(-0.01) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Panning Reset (Center)",invoke=function() setInstrumentPanningValue(0.5) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Panning 0.0 (Left)",invoke=function() setInstrumentPanningValue(0.0) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Panning 1.0 (Right)",invoke=function() setInstrumentPanningValue(1.0) end}

---------
-- Global flag to track whether the Catch Octave notifier is enabled
catch_octave_enabled = false

-- Function to update the octave based on the note string of the currently selected note column
function update_octave_from_selected_note_column()
  -- Check if renoise.song() is not nil
  if not renoise.song() then
    return
  end

  local song = renoise.song()
  local window = renoise.app().window

  -- Only proceed if the active middle frame is the Pattern Editor
  if window.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR then
    return
  end

  local selected_line = song.selected_line
  local selected_note_column_index = song.selected_note_column_index
  local selected_effect_column_index = song.selected_effect_column_index

  -- Check if the current selection is a note column and not an effect column
  if selected_note_column_index > 0 and selected_effect_column_index == 0 then
    local note_column = selected_line.note_columns[selected_note_column_index]

    -- Check if the note string is not empty
    if note_column.note_string ~= "" then
      -- Extract the octave part from the note string (last character)
      local note_string = note_column.note_string
      local octave = tonumber(note_string:sub(-1))

      -- Clamp the octave value to the range 0-8
      if octave then
        if octave > 8 then
          octave = 8
        end
        song.transport.octave = octave
      end
    end
  end
end

-- Function to add notifiers
function add_notifiers()
  -- Check if renoise.song() is not nil
  if not renoise.song() then
    return
  end

  -- Add notifiers to trigger the function when the selected track or pattern changes
  local song = renoise.song()
  song.selected_track_index_observable:add_notifier(update_octave_from_selected_note_column)
  song.selected_pattern_observable:add_notifier(update_octave_from_selected_note_column)

  -- Periodic check for changes in the selected line index
  renoise.tool().app_idle_observable:add_notifier(update_octave_from_selected_note_column)
end

-- Function to remove notifiers
function remove_notifiers()
  -- Check if renoise.song() is not nil
  if not renoise.song() then
    return
  end

  -- Remove the notifiers
  local song = renoise.song()
  pcall(function() song.selected_track_index_observable:remove_notifier(update_octave_from_selected_note_column) end)
  pcall(function() song.selected_pattern_observable:remove_notifier(update_octave_from_selected_note_column) end)
  pcall(function() renoise.tool().app_idle_observable:remove_notifier(update_octave_from_selected_note_column) end)
end

-- Function to toggle the Catch Octave state
function toggle_catch_octave()
  if catch_octave_enabled then
    remove_notifiers()
    catch_octave_enabled = false
    renoise.app():show_status("Catch Octave disabled")
  else
    add_notifiers()
    catch_octave_enabled = true
    renoise.app():show_status("Catch Octave enabled")
  end
end

-- Add a menu entry and key binding for toggling Catch Octave
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Catch Octave",invoke = toggle_catch_octave}

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Clone Current Sequence",invoke=clone_current_sequence}


renoise.tool():add_keybinding{name="Global:Paketti:Catch Octave",invoke=toggle_catch_octave}

-- Initial call to add notifiers if enabled
if catch_octave_enabled then
  add_notifiers()
end


-----
-- Function to adjust the slice marker by a specified delta
function adjustSliceKeyshortcut(slice_index, delta)
    local song = renoise.song()
    local sample = song.selected_sample

    -- Ensure there is a selected sample and enough slice markers
    if not sample or #sample.slice_markers < slice_index then
        return
    end

    local slice_markers = sample.slice_markers
    local min_pos, max_pos

    -- Calculate the bounds for the slice marker movement
    if slice_index == 1 then
        min_pos = 1
        max_pos = (slice_markers[slice_index + 1] or sample.sample_buffer.number_of_frames) - 1
    elseif slice_index == #slice_markers then
        min_pos = slice_markers[slice_index - 1] + 1
        max_pos = sample.sample_buffer.number_of_frames - 1
    else
        min_pos = slice_markers[slice_index - 1] + 1
        max_pos = slice_markers[slice_index + 1] - 1
    end

    -- Get the current position of the slice marker and calculate new position
    local current_pos = slice_markers[slice_index]
    local new_pos = current_pos + delta

    -- Ensure the new position is within the allowed bounds
    if new_pos < min_pos then
        new_pos = min_pos
    elseif new_pos > max_pos then
        new_pos = max_pos
    end

    -- Move the slice marker
    sample:move_slice_marker(slice_markers[slice_index], new_pos)
end

-- List of deltas with their corresponding keybinding names
local deltas = {["+1"] = 1, ["-1"] = -1, ["+10"] = 10, ["-10"] = -10, ["+16"] = 16, ["-16"] = -16, ["+32"] = 32, ["-32"] = -32}

-- Create key bindings for each slice and each delta
for i = 1, 32 do
    for name, delta in pairs(deltas) do
        renoise.tool():add_keybinding{name="Sample Editor:Paketti:Nudge Slice " .. i .. " by (" .. name .. ")",invoke=function() adjustSliceKeyshortcut(i, delta) end}
    end
end
-----------
-- Function to set the interpolation mode for all samples within the selected instrument
function setSelectedInstrumentInterpolation(amount)
  local instrument = renoise.song().selected_instrument
  for _, sample in ipairs(instrument.samples) do
    sample.interpolation_mode = amount
  end
end

-- Adding key bindings for setting interpolation modes for all samples in the selected instrument
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Interpolation to 1 (None)",invoke=function() setSelectedInstrumentInterpolation(1) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Interpolation to 2 (Linear)",invoke=function() setSelectedInstrumentInterpolation(2) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Interpolation to 3 (Cubic)",invoke=function() setSelectedInstrumentInterpolation(3) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Selected Instrument Interpolation to 4 (Sinc)",invoke=function() setSelectedInstrumentInterpolation(4) end}



function selectedInstrumentFinetune(amount)
local currentSampleFinetune = renoise.song().selected_sample.fine_tune
local changedSampleFinetune = currentSampleFinetune + amount
if changedSampleFinetune > 127 then changedSampleFinetune = 127
else if changedSampleFinetune < -127 then changedSampleFinetune = -127 end end
renoise.song().selected_sample.fine_tune=changedSampleFinetune
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Finetune (-1)",invoke=function()  selectedInstrumentFinetune(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Finetune (+1)",invoke=function()  selectedInstrumentFinetune(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Finetune (-10)",invoke=function() selectedInstrumentFinetune(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Finetune (+10)",invoke=function() selectedInstrumentFinetune(10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Finetune (0)",invoke=function() renoise.song().selected_sample.fine_tune=0 end}


-- Function to assign a modulation set to the selected sample based on a given index
function selectedSampleMod(number)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if there are any modulation sets
  if not instrument or #instrument.sample_modulation_sets == 0 then
    print("No modulation sets available or no instrument selected.")
    return
  end

  -- Get the number of available modulation sets
  local num_modulation_sets = #instrument.sample_modulation_sets

  -- Check if the provided index is within the valid range
  -- Adjusting to include 0 in the check, as it represents no modulation set assigned
  if number < 0 or number > num_modulation_sets then
    return
  end

  -- Assign the modulation set index to the selected sample
  -- This assignment now confidently allows setting the index to 0
  instrument.samples[renoise.song().selected_sample_index].modulation_set_index = number
end

-- Function to assign an FX chain to the selected sample based on a given index
function selectedSampleFX(number)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if there are any FX chains
  if not instrument or #instrument.sample_device_chains == 0 then
    print("No FX chains available or no instrument selected.")
    return
  end

  -- Get the number of available FX chains
  local num_fx_sets = #instrument.sample_device_chains

  -- Check if the provided index is within the valid range
  -- Adjusting to include 0 in the check, as it represents no FX chain assigned
  if number < 0 or number > num_fx_sets then
    return
  end

  -- Assign the FX chain index to the selected sample
  -- This assignment confidently allows setting the index to 0
  instrument.samples[renoise.song().selected_sample_index].device_chain_index = number
end

-- Function to select the next modulation set
function selectNextModGroup()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if not instrument or #instrument.sample_modulation_sets == 0 then
    print("No modulation sets available or no instrument selected.")
    return
  end

  local selected_sample = instrument.samples[renoise.song().selected_sample_index]
  local current_index = selected_sample.modulation_set_index
  local next_index = (current_index % #instrument.sample_modulation_sets) + 1

  selectedSampleMod(next_index)
end

-- Function to select the previous modulation set
function selectPreviousModGroup()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if not instrument or #instrument.sample_modulation_sets == 0 then
    print("No modulation sets available or no instrument selected.")
    return
  end

  local selected_sample = instrument.samples[renoise.song().selected_sample_index]
  local current_index = selected_sample.modulation_set_index
  local previous_index = (current_index - 2 + #instrument.sample_modulation_sets) % #instrument.sample_modulation_sets + 1

  selectedSampleMod(previous_index)
end

-- Function to select the next FX chain
function selectNextFXGroup()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if not instrument or #instrument.sample_device_chains == 0 then
    print("No FX chains available or no instrument selected.")
    return
  end

  local selected_sample = instrument.samples[renoise.song().selected_sample_index]
  local current_index = selected_sample.device_chain_index
  local next_index = (current_index % #instrument.sample_device_chains) + 1

  selectedSampleFX(next_index)
end

-- Function to select the previous FX chain
function selectPreviousFXGroup()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if not instrument or #instrument.sample_device_chains == 0 then
    print("No FX chains available or no instrument selected.")
    return
  end

  local selected_sample = instrument.samples[renoise.song().selected_sample_index]
  local current_index = selected_sample.device_chain_index
  local previous_index = (current_index - 2 + #instrument.sample_device_chains) % #instrument.sample_device_chains + 1

  selectedSampleFX(previous_index)
end

-- Adding keybindings for next and previous mod and FX groups
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mod Group (Next)",invoke=function() selectNextModGroup() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Mod Group (Previous)",invoke=function() selectPreviousModGroup() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample FX Group (Next)",invoke=function() selectNextFXGroup() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample FX Group (Previous)",invoke=function() selectPreviousFXGroup() end}


-- Function to assign a modulation set to all samples based on a given index
function selectedInstrumentSampleMod(number)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if there are any modulation sets
  if not instrument or #instrument.sample_modulation_sets == 0 then
    print("No modulation sets available or no instrument selected.")
    return
  end

  -- Get the number of available modulation sets
  local num_modulation_sets = #instrument.sample_modulation_sets

  -- Check if the provided index is within the valid range
  if number < 0 or number > num_modulation_sets then
    return
  end

  -- Assign the modulation set index to all samples
  for i = 1, #instrument.samples do
    instrument.samples[i].modulation_set_index = number
  end
end

-- Function to assign an FX chain to all samples based on a given index
function selectedInstrumentSampleFX(number)
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if there are any FX chains
  if not instrument or #instrument.sample_device_chains == 0 then
    print("No FX chains available or no instrument selected.")
    return
  end

  -- Get the number of available FX chains
  local num_fx_sets = #instrument.sample_device_chains

  -- Check if the provided index is within the valid range
  if number < 0 or number > num_fx_sets then
    return
  end

  -- Assign the FX chain index to all samples
  for i = 1, #instrument.samples do
    instrument.samples[i].device_chain_index = number
  end
end

-- Function to select the next modulation set for all samples
function selectedInstrumentNextModGroup()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if not instrument or #instrument.sample_modulation_sets == 0 then
    print("No modulation sets available or no instrument selected.")
    return
  end

  local selected_sample = instrument.samples[renoise.song().selected_sample_index]
  local current_index = selected_sample.modulation_set_index
  local next_index = (current_index % #instrument.sample_modulation_sets) + 1

  selectedInstrumentSampleMod(next_index)
end

-- Function to select the previous modulation set for all samples
function selectedInstrumentPreviousModGroup()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if not instrument or #instrument.sample_modulation_sets == 0 then
    print("No modulation sets available or no instrument selected.")
    return
  end

  local selected_sample = instrument.samples[renoise.song().selected_sample_index]
  local current_index = selected_sample.modulation_set_index
  local previous_index = (current_index - 2 + #instrument.sample_modulation_sets) % #instrument.sample_modulation_sets + 1

  selectedInstrumentSampleMod(previous_index)
end

-- Function to select the next FX chain for all samples
function selectedInstrumentNextFXGroup()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if not instrument or #instrument.sample_device_chains == 0 then
    print("No FX chains available or no instrument selected.")
    return
  end

  local selected_sample = instrument.samples[renoise.song().selected_sample_index]
  local current_index = selected_sample.device_chain_index
  local next_index = (current_index % #instrument.sample_device_chains) + 1

  selectedInstrumentSampleFX(next_index)
end

-- Function to select the previous FX chain for all samples
function selectedInstrumentPreviousFXGroup()
  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  if not instrument or #instrument.sample_device_chains == 0 then
    print("No FX chains available or no instrument selected.")
    return
  end

  local selected_sample = instrument.samples[renoise.song().selected_sample_index]
  local current_index = selected_sample.device_chain_index
  local previous_index = (current_index - 2 + #instrument.sample_device_chains) % #instrument.sample_device_chains + 1

  selectedInstrumentSampleFX(previous_index)
end

-- Adding keybindings for next and previous mod and FX groups
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Mod Group (Next)",invoke=function() selectedInstrumentNextModGroup() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Mod Group (Previous)",invoke=function() selectedInstrumentPreviousModGroup() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument FX Group (Next)",invoke=function() selectedInstrumentNextFXGroup() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument FX Group (Previous)",invoke=function() selectedInstrumentPreviousFXGroup() end}


---
-- Function to print debug information
function debug_print(message)
  renoise.app():show_status(message)
  print(message)
end

-- Function to halve the selection range
function halve_selection_range()
  local song = renoise.song()
  if not song then 
    debug_print("No song available")
    return 
  end

  local instrument = song.selected_instrument
  if not instrument then 
    debug_print("No instrument selected")
    return 
  end

  local sample = song.selected_sample
  if not sample then 
    debug_print("No sample selected")
    return 
  end

  local sample_buffer = sample.sample_buffer
  if not sample_buffer or not sample_buffer.has_sample_data then 
    debug_print("No sample buffer or no sample data")
    return 
  end

  local selection = sample_buffer.selection_range
  if #selection == 2 then
    local start_pos = selection[1]
    local end_pos = selection[2]
    if start_pos == end_pos then
      debug_print("Selection range is of zero length: " .. start_pos .. "-" .. end_pos)
      return
    end
    local new_end_pos = start_pos + math.floor((end_pos - start_pos) / 2)

    sample_buffer.selection_range = {start_pos, new_end_pos}
    debug_print("Halved selection range from " .. start_pos .. "-" .. end_pos .. " to " .. start_pos .. "-" .. new_end_pos)
  else
    debug_print("Selection range is not valid: " .. #selection)
  end
end

-- Function to double the selection range
function double_selection_range()
  local song = renoise.song()
  if not song then 
    debug_print("No song available")
    return 
  end

  local instrument = song.selected_instrument
  if not instrument then 
    debug_print("No instrument selected")
    return 
  end

  local sample = song.selected_sample
  if not sample then 
    debug_print("No sample selected")
    return 
  end

  local sample_buffer = sample.sample_buffer
  if not sample_buffer or not sample_buffer.has_sample_data then 
    debug_print("No sample buffer or no sample data")
    return 
  end

  local selection = sample_buffer.selection_range
  local total_frames = sample_buffer.number_of_frames
  if #selection == 2 then
    local start_pos = selection[1]
    local end_pos = selection[2]
    local selection_length = end_pos - start_pos
    local new_end_pos

    if selection_length == 0 then
      new_end_pos = start_pos + 1
    else
      new_end_pos = start_pos + selection_length * 2
    end

    if new_end_pos > total_frames then
      new_end_pos = total_frames
    end

    sample_buffer.selection_range = {start_pos, new_end_pos}
    debug_print("Doubled selection range from " .. start_pos .. "-" .. end_pos .. " to " .. start_pos .. "-" .. new_end_pos)
  else
    debug_print("Selection range is not valid: " .. #selection)
  end
end

-- Adding keybindings
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Sample Buffer Selection Halve",invoke=halve_selection_range}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Sample Buffer Selection Double",invoke=double_selection_range}

-- Adding MIDI mappings
renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Sample Buffer Selection Halve",invoke=halve_selection_range}
renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Sample Buffer Selection Double",invoke=double_selection_range}
-----------
-- Import the necessary modules
local vb = renoise.ViewBuilder()
local dialog = nil

-- Function to create a vertical ruler that matches the height of the columns
function trackOutputRoutingsGUI_vertical_rule(height)
  return vb:vertical_aligner{
    mode="center",
    vb:space{height=2},
    vb:column{
      width=2,
      style="panel",
      height=height
    },
    vb:space{height=2}
  }
end

-- Function to create a horizontal rule
function trackOutputRoutingsGUI_horizontal_rule()
  return vb:horizontal_aligner{
    mode="justify", 
    width="100%", 
    vb:space{width=2}, 
    vb:row{
      height=2, 
      style="panel", 
      width="100%"
    }, 
    vb:space{width=2}
  }
end

-- Function to create the GUI
function trackOutputRoutingsGUI_create()
  -- Get the number of tracks
  local num_tracks = #renoise.song().tracks
  local tracks_per_column = 18
  local num_columns = math.ceil(num_tracks / tracks_per_column)
  local track_row_height = 24 -- Approximate height of each track row
  local column_height = tracks_per_column * track_row_height

  -- Create a view for the dialog content
  local content = vb:row{
    margin = 10,
    spacing = 10
  }

  -- Table to store dropdown elements
  local dropdowns = {}

  -- Loop through each column
  for col = 1, num_columns do
    -- Create a column to hold up to 18 tracks
    local column_content = vb:column{
      margin = 5,
      spacing = 5,
      width = 200 -- Set column width to accommodate track name and dropdown
    }

    -- Add tracks to the column
    for i = 1, tracks_per_column do
      local track_index = (col - 1) * tracks_per_column + i
      if track_index > num_tracks then break end

      local track = renoise.song().tracks[track_index]
      local track_name = track.name
      local available_output_routings = track.available_output_routings
      local current_output_routing = track.output_routing

      -- Determine if the track is a group
      local is_group = track.type == renoise.Track.TRACK_TYPE_GROUP

      -- Create the dropdown
      local dropdown = vb:popup{
        items = available_output_routings,
        value = table.find(available_output_routings, current_output_routing),
        width = 120 -- Set width to 200% of 60 to be 120
      }
      
      -- Store the dropdown element
      table.insert(dropdowns, {dropdown = dropdown, track_index = track_index})

      -- Add the track name and dropdown in the same row, align dropdown to the right
      column_content:add_child(vb:row{
        vb:text{
          text = track_name,
          font = is_group and "bold" or "normal",
          style = is_group and "strong" or "normal",
          width = 140 -- Allocate 70% width for track name
        },
        dropdown
      })
    end

    -- Add the column to the content
    content:add_child(column_content)

    -- Add a vertical rule between columns, but not after the last column
    if col < num_columns then
      content:add_child(trackOutputRoutingsGUI_vertical_rule(column_height))
    end
  end

  -- Add a horizontal rule
  content:add_child(trackOutputRoutingsGUI_horizontal_rule())

  -- OK and Cancel buttons
  content:add_child(vb:row{
    spacing = 5,
    vb:button{
      text = "OK",
      width = "50%", -- Set OK button width to 50%
      notifier = function()
        -- Apply changes to the output routings
        for _, entry in ipairs(dropdowns) do
          local dropdown = entry.dropdown
          local track_index = entry.track_index
          local track = renoise.song().tracks[track_index]
          local selected_routing = dropdown.items[dropdown.value]
          if selected_routing ~= track.output_routing then
            track.output_routing = selected_routing
          end
        end
        dialog:close()
      end
    },
    vb:button{
      text = "Cancel",
      width = "50%", -- Set Cancel button width to 50%
      notifier = function()
        dialog:close()
      end
    }
  })

  -- Show the dialog
  dialog = renoise.app():show_custom_dialog("Track Output Routings", content)
end

-- Add a menu entry to show the GUI
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Track Routings Dialog",invoke=trackOutputRoutingsGUI_create}
------------

-- Function to adjust the delay, panning, or volume column within the selected area in the pattern editor
function adjust_column(column_type, adjustment)
  -- Check if there's a valid song
  local song = renoise.song()
  if not song then
    renoise.app():show_status("No active song found.")
    return
  end
  
  -- Get the current selection in the pattern editor
  local selection = song.selection_in_pattern
  if not selection then
    renoise.app():show_status("No selection in the pattern editor.")
    return
  end

  -- Loop through the selected tracks
  for track_index = selection.start_track, selection.end_track do
    local track = song:track(track_index)
    
    -- Make the appropriate column visible if it's not already
    if column_type == "delay" and not track.delay_column_visible then
      track.delay_column_visible = true
    elseif column_type == "panning" and not track.panning_column_visible then
      track.panning_column_visible = true
    elseif column_type == "volume" and not track.volume_column_visible then
      track.volume_column_visible = true
    end
    
    -- Loop through the selected lines
    for line_index = selection.start_line, selection.end_line do
      local pattern_index = song.selected_pattern_index
      local pattern = song:pattern(pattern_index)
      local line = pattern:track(track_index):line(line_index)
      
      -- Loop through the columns in the selected line
      for note_column_index = selection.start_column, selection.end_column do
        local note_column = line:note_column(note_column_index)
        if note_column then
          -- Adjust or reset the appropriate column value
          if adjustment == 0 then
            -- Wipe the column content
            if column_type == "delay" then
              note_column.delay_value = 0
            elseif column_type == "panning" then
              note_column.panning_string = ".."
            elseif column_type == "volume" then
              note_column.volume_string = ".."
            end
          else
            -- Adjust the column value
            if column_type == "delay" then
              local new_value = math.min(0xFF, math.max(0, note_column.delay_value + adjustment))
              note_column.delay_value = new_value
            elseif column_type == "panning" then
              local new_value = note_column.panning_value + adjustment
              if new_value < 0 then
                note_column.panning_string = ".."
              else
                note_column.panning_value = math.min(0x80, new_value)
              end
            elseif column_type == "volume" then
              local new_value = note_column.volume_value + adjustment
              if new_value < 0 then
                note_column.volume_string = ".."
              else
                note_column.volume_value = math.min(0x80, new_value)
              end
            end
          end
        end
      end
    end
  end
  
  -- Show a status message indicating the operation was successful
  renoise.app():show_status(column_type:gsub("^%l", string.upper) .. " Column adjustment (" .. adjustment .. ") applied successfully.")
end

-- Function to wipe the volume column within the selected area in the pattern editor
function wipe_volume_column()
  adjust_column("volume", 0)
end

-- Function to wipe the panning column within the selected area in the pattern editor
function wipe_panning_column()
  adjust_column("panning", 0)
end

-- Define the menu entries, keybindings, and MIDI mappings for the different adjustments
local function add_tool_entries(column_type, adjustment)
  local adj_str = (adjustment > 0) and "+" .. adjustment or tostring(adjustment)
  renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Column:Adjust Selection " .. column_type:gsub("^%l", string.upper) .. " Column " .. adj_str, invoke=function() adjust_column(column_type, adjustment) end}
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Adjust Selection " .. column_type:gsub("^%l", string.upper) .. " Column (" .. adj_str .. ")", invoke=function() adjust_column(column_type, adjustment) end}
  renoise.tool():add_midi_mapping{name="Pattern Editor:Paketti:Adjust Selection " .. column_type:gsub("^%l", string.upper) .. " Column (" .. adj_str .. ")", invoke=function() adjust_column(column_type, adjustment) end}
end

-- Define the menu entries, keybindings, and MIDI mappings for wiping the columns
local function add_wipe_entries(column_type)
  renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Column:Wipe Selection " .. column_type:gsub("^%l", string.upper) .. " Column", invoke=function() adjust_column(column_type, 0) end}
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Wipe Selection " .. column_type:gsub("^%l", string.upper) .. " Column", invoke=function() adjust_column(column_type, 0) end}
  renoise.tool():add_midi_mapping{name="Pattern Editor:Paketti:Wipe Selection " .. column_type:gsub("^%l", string.upper) .. " Column", invoke=function() adjust_column(column_type, 0) end}
end

-- Adding menu entries, keybindings, and MIDI mappings for delay, panning, and volume columns adjustments
for _, column_type in ipairs({"delay", "panning", "volume"}) do
  for _, adjustment in ipairs({1, -1, 10, -10}) do
    add_tool_entries(column_type, adjustment)
  end
end

-- Adding menu entries, keybindings, and MIDI mappings for wiping the columns
for _, column_type in ipairs({"delay", "panning", "volume"}) do
  add_wipe_entries(column_type)
end


-- Function to convert mono sample to specified channels with blank opposite channel
function mono_to_blank(left_channel, right_channel)
  -- Ensure a song exists
  if not renoise.song() then
    renoise.app():show_status("No song is currently loaded.")
    return
  end

  -- Ensure an instrument is selected
  local song = renoise.song()
  local instrument = song.selected_instrument
  if not instrument then
    renoise.app():show_status("No instrument is selected.")
    return
  end

  -- Ensure a sample is selected
  local sample = instrument:sample(song.selected_sample_index)
  if not sample then
    renoise.app():show_status("No sample is selected.")
    return
  end

  -- Ensure the sample is mono
  if sample.sample_buffer.number_of_channels ~= 1 then
    renoise.app():show_status("Selected sample is not mono.")
    return
  end

  -- Get the sample buffer and its properties
  local sample_buffer = sample.sample_buffer
  local sample_rate = sample_buffer.sample_rate
  local bit_depth = sample_buffer.bit_depth
  local number_of_frames = sample_buffer.number_of_frames
  local sample_name = sample.name
  local original_sample_index = song.selected_sample_index

  -- Create a new sample slot
  local new_sample_index = #instrument.samples + 1
  instrument:insert_sample_at(new_sample_index)
  local new_sample = instrument:sample(new_sample_index)
  local new_sample_buffer = new_sample.sample_buffer
  
  -- Prepare the new sample buffer with the same sample rate and bit depth as the original
  new_sample_buffer:create_sample_data(sample_rate, bit_depth, 2, number_of_frames)
  new_sample_buffer:prepare_sample_data_changes()

  -- Copy the sample data to the specified channels
  for frame = 1, number_of_frames do
    local sample_value = sample_buffer:sample_data(1, frame)
    new_sample_buffer:set_sample_data(1, frame, sample_value * left_channel)
    new_sample_buffer:set_sample_data(2, frame, sample_value * right_channel)
  end

  -- Finalize changes
  new_sample_buffer:finalize_sample_data_changes()
  
  -- Name the new sample and delete the original sample
  new_sample.name = sample_name
  instrument:delete_sample_at(original_sample_index)

  -- Provide feedback
  renoise.app():show_status("Mono sample successfully converted.")
end



-- Function to convert a mono sample to stereo
function convert_mono_to_stereo()
  -- Ensure a song exists
  if not renoise.song() then
    renoise.app():show_status("No song is currently loaded.")
    return
  end

  -- Ensure an instrument is selected
  local song = renoise.song()
  local instrument = song.selected_instrument
  if not instrument then
    renoise.app():show_status("No instrument is selected.")
    return
  end

  -- Ensure a sample is selected
  local sample = instrument:sample(song.selected_sample_index)
  if not sample then
    renoise.app():show_status("No sample is selected.")
    return
  end

  -- Ensure the sample is mono
  if sample.sample_buffer.number_of_channels ~= 1 then
    renoise.app():show_status("Selected sample is not mono.")
    return
  end

  -- Get the sample buffer and its properties
  local sample_buffer = sample.sample_buffer
  local sample_rate = sample_buffer.sample_rate
  local bit_depth = sample_buffer.bit_depth
  local number_of_frames = sample_buffer.number_of_frames
  local sample_name = sample.name
  local original_sample_index = song.selected_sample_index

  -- Create a new sample slot
  local new_sample_index = #instrument.samples + 1
  instrument:insert_sample_at(new_sample_index)
  local new_sample = instrument:sample(new_sample_index)
  local new_sample_buffer = new_sample.sample_buffer
  
  -- Prepare the new sample buffer with the same sample rate and bit depth as the original
  new_sample_buffer:create_sample_data(sample_rate, bit_depth, 2, number_of_frames)
  new_sample_buffer:prepare_sample_data_changes()

  -- Copy the sample data
  for frame = 1, number_of_frames do
    local sample_value = sample_buffer:sample_data(1, frame)
    new_sample_buffer:set_sample_data(1, frame, sample_value)
    new_sample_buffer:set_sample_data(2, frame, sample_value)
  end

  -- Finalize changes
  new_sample_buffer:finalize_sample_data_changes()
  
  -- Name the new sample and delete the original sample
  new_sample.name = sample_name
  instrument:delete_sample_at(original_sample_index)

  -- Provide feedback
  renoise.app():show_status("Mono sample successfully converted to stereo.")
end

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}

renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}


renoise.tool():add_keybinding{name="Sample Editor:Paketti:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}

renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}
renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Convert Mono to Stereo",invoke=convert_mono_to_stereo}



-----------

-- Function to duplicate the current track and set notes to the selected instrument
function setToSelectedInstrument_DuplicateTrack()
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local track_index = song.selected_track_index
  local selected_instrument_index = song.selected_instrument_index

  -- Insert a new track
  song:insert_track_at(track_index + 1)
  song.selected_track_index = track_index + 1

  local new_track = song.tracks[track_index + 1]
  local old_track = song.tracks[track_index]

  -- Copy the content of the current track to the new track
  for i = 1, #song.patterns do
    local old_pattern_track = song.patterns[i].tracks[track_index]
    local new_pattern_track = song.patterns[i].tracks[track_index + 1]

    for line = 1, #old_pattern_track.lines do
      new_pattern_track:line(line):copy_from(old_pattern_track:line(line))
    end

    -- Change pattern data to use the selected instrument
    for line = 1, #new_pattern_track.lines do
      for _, note_column in ipairs(new_pattern_track:line(line).note_columns) do
        if note_column.instrument_value ~= 255 then
          note_column.instrument_value = selected_instrument_index - 1
        end
      end
    end
  end

  -- Copy Track DSPs and handle Instr. Automation
  local has_instr_automation = false
  local old_instr_automation_device = nil
  for dsp_index = 2, #old_track.devices do
    local old_device = old_track.devices[dsp_index]

    if old_device.device_path:find("Instr. Automation") then
      has_instr_automation = true
      old_instr_automation_device = old_device
    else
      local new_device = new_track:insert_device_at(old_device.device_path, dsp_index)
      for parameter_index = 1, #old_device.parameters do
        new_device.parameters[parameter_index].value = old_device.parameters[parameter_index].value
      end
      new_device.is_maximized = old_device.is_maximized
    end
  end

  -- Create a new Instr. Automation device if the original track had one
  if has_instr_automation then
    local new_device = new_track:insert_device_at("Audio/Effects/Native/*Instr. Automation", #new_track.devices + 1)

    -- Extract XML from the old device
    local old_device_xml = old_instr_automation_device.active_preset_data
    -- Modify the XML to update the instrument references
    local new_device_xml = old_device_xml:gsub("<instrument>(%d+)</instrument>", function(instr_index)
      return string.format("<instrument>%d</instrument>", selected_instrument_index - 1)
    end)
    -- Apply the modified XML to the new device
    new_device.active_preset_data = new_device_xml
    new_device.is_maximized = old_instr_automation_device.is_maximized
  end

  -- Adjust visibility settings for the new track
  new_track.visible_note_columns = old_track.visible_note_columns
  new_track.visible_effect_columns = old_track.visible_effect_columns
  new_track.volume_column_visible = old_track.volume_column_visible
  new_track.panning_column_visible = old_track.panning_column_visible
  new_track.delay_column_visible = old_track.delay_column_visible

  -- Handle automation duplication after fixing XML
  for i = 1, #song.patterns do
    local old_pattern_track = song.patterns[i].tracks[track_index]
    local new_pattern_track = song.patterns[i].tracks[track_index + 1]

    for _, automation in ipairs(old_pattern_track.automation) do
      local new_automation = new_pattern_track:create_automation(automation.dest_parameter)
      for _, point in ipairs(automation.points) do
        new_automation:add_point_at(point.time, point.value)
      end
    end
  end

  -- Select the new track
  song.selected_track_index = track_index + 1

  -- Ready the new track for transposition (select all notes)
  Deselect_All()
  MarkTrackMarkPattern()
end

-- Add menu entry for the function
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Duplicate Track, set to Selected Instrument",invoke=function() setToSelectedInstrument_DuplicateTrack() end}
renoise.tool():add_menu_entry{name="--Mixer:Paketti..:Duplicate Track, set to Selected Instrument",invoke=function() setToSelectedInstrument_DuplicateTrack() end}

-- Add keybinding for the function
renoise.tool():add_keybinding{name="Global:Paketti..:Duplicate Track, set to Selected Instrument",invoke=function() setToSelectedInstrument_DuplicateTrack() end}

----------


-- Function to duplicate the current track and instrument, then copy notes and prepare the new track for editing
function duplicateTrackDuplicateInstrument()
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local track_index = song.selected_track_index

  -- Detect the instrument used in the current track and select it
  local found_instrument_index = nil
  for _, line in ipairs(song.patterns[pattern_index].tracks[track_index].lines) do
    for _, note_column in ipairs(line.note_columns) do
      if note_column.instrument_value ~= 255 then
        found_instrument_index = note_column.instrument_value + 1
        break
      end
    end
    if found_instrument_index then break end
  end

  if found_instrument_index then
    song.selected_instrument_index = found_instrument_index
  else
    song.selected_instrument_index = 1
  end

  local instrument_index = song.selected_instrument_index
  local external_editor_open = false

  -- Check if the external editor is open and close it if necessary
  if song.instruments[instrument_index].plugin_properties.plugin_device then
    external_editor_open = song.instruments[instrument_index].plugin_properties.plugin_device.external_editor_visible
    if external_editor_open then
      song.instruments[instrument_index].plugin_properties.plugin_device.external_editor_visible = false
    end
  end

  -- Duplicate the current instrument
  song:insert_instrument_at(instrument_index + 1)
  local new_instrument_index = instrument_index + 1
  song.instruments[new_instrument_index]:copy_from(song.instruments[instrument_index])

  -- Handle phrases
  if #song.instruments[instrument_index].phrases > 0 then
    for phrase_index = 1, #song.instruments[instrument_index].phrases do
      song.instruments[new_instrument_index]:insert_phrase_at(phrase_index)
      song.instruments[new_instrument_index].phrases[phrase_index]:copy_from(song.instruments[instrument_index].phrases[phrase_index])
    end
  end

  -- Insert a new track
  song:insert_track_at(track_index + 1)
  song.selected_track_index = track_index + 1

  local new_track = song.tracks[track_index + 1]
  local old_track = song.tracks[track_index]

  -- Copy the content of the current track to the new track
  for i = 1, #song.patterns do
    local old_pattern_track = song.patterns[i].tracks[track_index]
    local new_pattern_track = song.patterns[i].tracks[track_index + 1]

    for line = 1, #old_pattern_track.lines do
      new_pattern_track:line(line):copy_from(old_pattern_track:line(line))
    end

    -- Change pattern data to use the new instrument
    for line = 1, #new_pattern_track.lines do
      for _, note_column in ipairs(new_pattern_track:line(line).note_columns) do
        if note_column.instrument_value == instrument_index - 1 then
          note_column.instrument_value = new_instrument_index - 1
        end
      end
    end
  end

  -- Copy Track DSPs and handle Instr. Automation
  local has_instr_automation = false
  local old_instr_automation_device = nil
  for dsp_index = 2, #old_track.devices do
    local old_device = old_track.devices[dsp_index]

    if old_device.device_path:find("Instr. Automation") then
      has_instr_automation = true
      old_instr_automation_device = old_device
    else
      local new_device = new_track:insert_device_at(old_device.device_path, dsp_index)
      for parameter_index = 1, #old_device.parameters do
        new_device.parameters[parameter_index].value = old_device.parameters[parameter_index].value
      end
      new_device.is_maximized = old_device.is_maximized
    end
  end

  -- Create a new Instr. Automation device if the original track had one
  if has_instr_automation then
    -- Select the new instrument
    song.selected_instrument_index = new_instrument_index

    local new_device = new_track:insert_device_at("Audio/Effects/Native/*Instr. Automation", #new_track.devices + 1)

    -- Extract XML from the old device
    local old_device_xml = old_instr_automation_device.active_preset_data
    -- Modify the XML to update the instrument references
    local new_device_xml = old_device_xml:gsub("<instrument>(%d+)</instrument>", function(instr_index)
      return string.format("<instrument>%d</instrument>", new_instrument_index - 1)
    end)
    -- Apply the modified XML to the new device
    new_device.active_preset_data = new_device_xml
    new_device.is_maximized = old_instr_automation_device.is_maximized
  end

  -- Adjust visibility settings for the new track
  new_track.visible_note_columns = old_track.visible_note_columns
  new_track.visible_effect_columns = old_track.visible_effect_columns
  new_track.volume_column_visible = old_track.volume_column_visible
  new_track.panning_column_visible = old_track.panning_column_visible
  new_track.delay_column_visible = old_track.delay_column_visible

  -- Handle automation duplication after fixing XML
  for i = 1, #song.patterns do
    local old_pattern_track = song.patterns[i].tracks[track_index]
    local new_pattern_track = song.patterns[i].tracks[track_index + 1]

    for _, automation in ipairs(old_pattern_track.automation) do
      local new_automation = new_pattern_track:create_automation(automation.dest_parameter)
      for _, point in ipairs(automation.points) do
        new_automation:add_point_at(point.time, point.value)
      end
    end
  end

  -- Select the new instrument
  song.selected_instrument_index = new_instrument_index

  -- Select the new track
  song.selected_track_index = track_index + 1

  -- Ready the new track for transposition (select all notes)
  Deselect_All()
  MarkTrackMarkPattern()

  -- Reopen the external editor if it was open
  if external_editor_open then
    song.instruments[new_instrument_index].plugin_properties.plugin_device.external_editor_visible = true
  end
end

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Duplicate Track Duplicate Instrument",invoke=function() duplicateTrackDuplicateInstrument() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Duplicate Track Duplicate Instrument",invoke=function() duplicateTrackDuplicateInstrument() end}
renoise.tool():add_keybinding{name="Global:Paketti..:Duplicate Track Duplicate Instrument",invoke=function() duplicateTrackDuplicateInstrument() end}
------------





renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Note Interpolation",invoke=function() note_interpolation() end}
renoise.tool():add_midi_mapping{name="Paketti:Note Interpolation",invoke=function() note_interpolation() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Note Interpolation",invoke=function() note_interpolation() end}

-- Main function for note interpolation
function note_interpolation()
  -- Get the current pattern and pattern sequence
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local pattern = song.patterns[pattern_index]
  local pattern_length = pattern.number_of_lines

  -- Get selection start and end lines
  local start_line, end_line
  if song.selection_in_pattern == nil then
    start_line = 1
    end_line = pattern_length
  else
    start_line = song.selection_in_pattern.start_line
    end_line = song.selection_in_pattern.end_line
  end

  -- Ensure there is a difference between start and end lines
  if start_line == end_line then
    renoise.app():show_error("The selection must span at least two lines.")
    return
  end

  -- Retrieve note columns from start and end lines
  local start_note = song:pattern(pattern_index):track(song.selected_track_index):line(start_line):note_column(1)
  local end_note = song:pattern(pattern_index):track(song.selected_track_index):line(end_line):note_column(1)

  if not start_note.is_empty and not end_note.is_empty then
    -- Calculate note difference and step
    local note_diff = end_note.note_value - start_note.note_value
    local steps = end_line - start_line
    local step_size = note_diff / steps

    -- Interpolate notes between start and end lines
    for i = 1, steps - 1 do
      local interpolated_note_value = math.floor(start_note.note_value + (i * step_size))
      local line_index = start_line + i
      local line = song:pattern(pattern_index):track(song.selected_track_index):line(line_index)
      line:note_column(1):copy_from(start_note)
      line:note_column(1).note_value = interpolated_note_value
    end
  else
    renoise.app():show_error("Both start and end lines must contain notes.")
  end
end

----------------------

-- Function to select the first track in the next or previous group
function select_first_track_in_next_group(direction)
  local song = renoise.song()
  local current_index = song.selected_track_index
  local group_indices = {}

  -- Collect all group indices
  for i = 1, song.sequencer_track_count do
    if song.tracks[i].type == renoise.Track.TRACK_TYPE_GROUP then
      local members = song.tracks[i].members
      local theCorrectIndex = i - #members
      table.insert(group_indices, theCorrectIndex)
    end
  end

  -- Check if there are no groups in the song
  if #group_indices == 0 then
    renoise.app():show_status("There are no Groups in this Song")
    return
  end

  -- Determine the next group index
  if direction == 1 then
    for _, index in ipairs(group_indices) do
      if current_index < index then
        song.selected_track_index = index
        return
      end
    end
    -- If no group found, wrap around to the first group
    song.selected_track_index = group_indices[1]
  elseif direction == 0 then
    for i = #group_indices, 1, -1 do
      if current_index > group_indices[i] then
        song.selected_track_index = group_indices[i]
        return
      end
    end
    -- If no group found, wrap around to the last group
    song.selected_track_index = group_indices[#group_indices]
  end
end

-- Add menu entries, keybindings, and MIDI mappings
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Jump to First Track In Next Group",invoke=function() select_first_track_in_next_group(1) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Jump to First Track In Previous Group",invoke=function() select_first_track_in_next_group(0) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Jump to First Track In Next Group",invoke=function() select_first_track_in_next_group(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Jump to First Track In Previous Group",invoke=function() select_first_track_in_next_group(0) end}
renoise.tool():add_keybinding{name="Pattern Matrix:Paketti:Jump to First Track In Next Group",invoke=function() select_first_track_in_next_group(1) end}
renoise.tool():add_keybinding{name="Pattern Matrix:Paketti:Jump to First Track In Previous Group",invoke=function() select_first_track_in_next_group(0) end}


renoise.tool():add_keybinding{name="Mixer:Paketti:Jump to First Track In Next Group",invoke=function() select_first_track_in_next_group(1) end}
renoise.tool():add_keybinding{name="Mixer:Paketti:Jump to First Track In Previous Group",invoke=function() select_first_track_in_next_group(0) end}
renoise.tool():add_midi_mapping{name="Paketti:Jump to First Track in Next Group",invoke=function() select_first_track_in_next_group(1) end}
renoise.tool():add_midi_mapping{name="Paketti:Jump to First Track in Previous Group",invoke=function() select_first_track_in_next_group(0) end}
----------

function toggle_bypass_selected_device()
  local song = renoise.song()
  local selected_device = song.selected_device
  local selected_track = song.selected_track

  if selected_device == nil then
    renoise.app():show_status("No Track DSP Device is Selected, Doing Nothing.")
    return
  end

  local selected_device_index = song.selected_device_index
  local selected_device_name = selected_device.name
  local all_others_active = true
  local any_other_active = false

  for i = 2, #selected_track.devices do
    if i ~= selected_device_index then
      if selected_track.devices[i].is_active then
        any_other_active = true
      else
        all_others_active = false
      end
    end
  end

  if selected_device.is_active then
    if all_others_active then
      for i = 2, #selected_track.devices do
        if i ~= selected_device_index then
          selected_track.devices[i].is_active = false
        end
      end
      renoise.app():show_status("Device " .. selected_device_name .. " activated, all other track DSP devices deactivated.")
    else
      selected_device.is_active = false
      for i = 2, #selected_track.devices do
        if i ~= selected_device_index then
          selected_track.devices[i].is_active = true
        end
      end
      renoise.app():show_status("Device " .. selected_device_name .. " deactivated, all other track DSP devices activated.")
    end
  else
    selected_device.is_active = true
    for i = 2, #selected_track.devices do
      if i ~= selected_device_index then
        selected_track.devices[i].is_active = false
      end
    end
    renoise.app():show_status("Device " .. selected_device_name .. " activated, all other track DSP devices deactivated.")
  end
end

renoise.tool():add_menu_entry{name="DSP Device:Paketti..:Bypass/Enable All Other Track DSP Devices (Toggle)",invoke=function() toggle_bypass_selected_device() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Bypass/Enable All Other Track DSP Devices (Toggle)",invoke=function() toggle_bypass_selected_device() end}
renoise.tool():add_keybinding{name="Global:Paketti:Bypass All Other Track DSP Devices (Toggle)",invoke=function() toggle_bypass_selected_device() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Bypass All Other Track DSP Devices (Toggle)",invoke=function() toggle_bypass_selected_device() end}











------------

function globalToggleVisibleColumnState(columnName)
  -- Get the current state of the specified column from the selected track
  local currentState = false
  local selected_track = renoise.song().selected_track

  if columnName == "delay" then
    currentState = selected_track.delay_column_visible
  elseif columnName == "volume" then
    currentState = selected_track.volume_column_visible
  elseif columnName == "panning" then
    currentState = selected_track.panning_column_visible
  elseif columnName == "sample_effects" then
    currentState = selected_track.sample_effects_column_visible
  else
    renoise.app():show_status("Invalid column name: " .. columnName)
    return
  end

  -- Toggle the state for all tracks of type 1
  for i=1, renoise.song().sequencer_track_count do
    if renoise.song().tracks[i].type == 1 then
      if columnName == "delay" then
        renoise.song().tracks[i].delay_column_visible = not currentState
      elseif columnName == "volume" then
        renoise.song().tracks[i].volume_column_visible = not currentState
      elseif columnName == "panning" then
        renoise.song().tracks[i].panning_column_visible = not currentState
      elseif columnName == "sample_effects" then
        renoise.song().tracks[i].sample_effects_column_visible = not currentState
      end
    end
  end
end

-- Add menu entries for toggling column visibility

renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Global Visible Column (All)",invoke=function() globalChangeVisibleColumnState("volume")
globalChangeVisibleColumnState("panning") globalChangeVisibleColumnState("delay") globalChangeVisibleColumnState("sample_effects") end}

renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Toggle Visible Column (Volume) Globally",invoke=function() globalToggleVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Toggle Visible Column (Panning) Globally",invoke=function() globalToggleVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Toggle Visible Column (Delay) Globally",invoke=function() globalToggleVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Toggle Visible Column (Sample Effects) Globally",invoke=function() globalToggleVisibleColumnState("sample_effects") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Global Visible Column (Volume)",invoke=function() globalChangeVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Global Visible Column (Panning)",invoke=function() globalChangeVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Global Visible Column (Delay)",invoke=function() globalChangeVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Global Visible Column (Sample Effects)",invoke=function() globalChangeVisibleColumnState("sample_effects") end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Visible Column (All)",invoke=function() globalChangeVisibleColumnState("volume")
globalChangeVisibleColumnState("panning") globalChangeVisibleColumnState("delay") globalChangeVisibleColumnState("sample_effects") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Toggle Visible Column (Volume)",invoke=function() globalToggleVisibleColumnState("volume") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Toggle Visible Column (Panning)",invoke=function() globalToggleVisibleColumnState("panning") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Toggle Visible Column (Delay)",invoke=function() globalToggleVisibleColumnState("delay") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Toggle Visible Column (Sample Effects)",invoke=function() globalToggleVisibleColumnState("sample_effects") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Set Visible Column (Volume)",invoke=function() globalChangeVisibleColumnState("volume") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Set Visible Column (Panning)",invoke=function() globalChangeVisibleColumnState("panning") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Set Visible Column (Delay)",invoke=function() globalChangeVisibleColumnState("delay") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Set Visible Column (Sample Effects)",invoke=function() globalChangeVisibleColumnState("sample_effects") end}

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Global Visible Column (All)",invoke=function() globalChangeVisibleColumnState("volume")
globalChangeVisibleColumnState("panning") globalChangeVisibleColumnState("delay") globalChangeVisibleColumnState("sample_effects") end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Toggle Visible Column (Volume) Globally",invoke=function() globalToggleVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Toggle Visible Column (Panning) Globally",invoke=function() globalToggleVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Toggle Visible Column (Delay) Globally",invoke=function() globalToggleVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Toggle Visible Column (Sample Effects)Globally",invoke=function() globalToggleVisibleColumnState("sample_effects") end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Global Visible Column (Volume)",invoke=function() globalChangeVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Global Visible Column (Panning)",invoke=function() globalChangeVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Global Visible Column (Delay)",invoke=function() globalChangeVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Global Visible Column (Sample Effects)",invoke=function() globalChangeVisibleColumnState("sample_effects") end}

renoise.tool():add_menu_entry{name="--Main Menu:View:Paketti..:Pattern Editor:Global Visible Column (All)",invoke=function() globalChangeVisibleColumnState("volume")
globalChangeVisibleColumnState("panning") globalChangeVisibleColumnState("delay") globalChangeVisibleColumnState("sample_effects") end}
renoise.tool():add_menu_entry{name="--Main Menu:View:Paketti..:Pattern Editor:Toggle Visible Column (Volume) Globally",invoke=function() globalToggleVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Toggle Visible Column (Panning) Globally",invoke=function() globalToggleVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Toggle Visible Column (Delay) Globally",invoke=function() globalToggleVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Toggle Visible Column (Sample Effects)Globally",invoke=function() globalToggleVisibleColumnState("sample_effects") end}
renoise.tool():add_menu_entry{name="--Main Menu:View:Paketti..:Pattern Editor:Global Visible Column (Volume)",invoke=function() globalChangeVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Global Visible Column (Panning)",invoke=function() globalChangeVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Global Visible Column (Delay)",invoke=function() globalChangeVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Global Visible Column (Sample Effects)",invoke=function() globalChangeVisibleColumnState("sample_effects") end}


