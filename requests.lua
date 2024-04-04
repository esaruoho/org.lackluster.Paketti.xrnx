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

-- From tkna91
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

renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose -1",invoke=function() selectedSampleTranspose(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose +1",invoke=function() selectedSampleTranspose(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose -12",invoke=function() selectedSampleTranspose(-12) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose +12",invoke=function() selectedSampleTranspose(12) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose 0",invoke=function() renoise.song().selected_sample.transpose=0 end}

function selectedSampleFinetune(amount)
local currentSampleFinetune = renoise.song().selected_sample.fine_tune
local changedSampleFinetune = currentSampleFinetune + amount
if changedSampleFinetune > 127 then changedSampleFinetune = 127
else if changedSampleFinetune < -127 then changedSampleFinetune = -127 end end
renoise.song().selected_sample.fine_tune=changedSampleFinetune
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune -1",invoke=function() selectedSampleFinetune(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune +1",invoke=function() selectedSampleFinetune(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune -10",invoke=function() selectedSampleFinetune(-10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune +10",invoke=function() selectedSampleFinetune(10) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Finetune 0",invoke=function() renoise.song().selected_sample.fine_tune=0 end}

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
 
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning +0.01",invoke=function() selectedSamplePanning(0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Panning -0.01",invoke=function() selectedSamplePanning(-0.01) end}

function selectedSampleVolume(amount)
local currentSampleVolume = renoise.song().selected_sample.volume
local changedSampleVolume = currentSampleVolume + amount
if changedSampleVolume > 4.0 then changedSampleVolume = 4.0
else if changedSampleVolume < 0.0 then changedSampleVolume = 0.0 end end
renoise.song().selected_sample.volume=changedSampleVolume
end
 
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Volume +0.01",invoke=function() selectedSampleVolume(0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Volume -0.01",invoke=function() selectedSampleVolume(-0.01) end}
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
renoise.song().selected_sample.beat_sync_mode = number
renoise.song().selected_sample.beat_sync_enabled = true
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync On/Off 1 (Repitch)",invoke=function() selectedSampleBeatsyncAndToggleOn(1) end }
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync On/Off 2 (Time-Stretch Percussion)",invoke=function() selectedSampleBeatsyncAndToggleOn(2) end }
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync On/Off 3 (Time-Stretch Texture)",invoke=function() selectedSampleBeatsyncAndToggleOn(3) end }


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Beatsync On/Off",invoke=function()
if renoise.song().selected_sample.beat_sync_enabled then
 renoise.song().selected_sample.beat_sync_enabled = false else
 renoise.song().selected_sample.beat_sync_enabled = true
end end }

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



renoise.tool():add_menu_entry{name="---Main Menu:Tools:Paketti..:Available Routings for Track",invoke=function() showAvailableRoutings() end}

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






