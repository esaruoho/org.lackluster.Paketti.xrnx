-- from Jalex
function JalexAdd(number)
if renoise.song().selected_note_column_index == renoise.song().selected_track.visible_note_columns then 
if renoise.song().selected_track.visible_note_columns == 12 then 
renoise.song().selected_line_index=renoise.song().selected_line_index+1
renoise.song().selected_note_column_index = 1

return
end

renoise.song().selected_track.visible_note_columns = renoise.song().selected_track.visible_note_columns+1 
end

local originalNote=renoise.song().selected_note_column.note_value
local originalInstrument=renoise.song().selected_note_column.instrument_value

if originalNote == 120 or originalNote == 121 then 
renoise.app():show_status("You are not on a note.")
return else

if originalNote + number > 120 then
renoise.app():show_status("Cannot go higher than B-9") return end
end
renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index + 1].note_value = originalNote + number
renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index + 1].instrument_value = originalInstrument

renoise.song().selected_note_column_index = renoise.song().selected_note_column_index +1
end

for i=1,12 do
  renoise.tool():add_keybinding{
    name=string.format("Pattern Editor:Paketti:Chordsplus (Add %02d)", i),
    invoke=function() JalexAdd(i) end
  }
end

for i=1,12 do
  renoise.tool():add_keybinding{
    name=string.format("Pattern Editor:Paketti:Chordsplus (Sub %02d)", i),
    invoke=function() JalexAdd(-i) end
  }
end

renoise.tool():add_keybinding{
  name="Pattern Editor:Paketti:Selection in Pattern to Group",
  invoke=function()
    if renoise.song().selection_in_pattern ~= nil then
      local selection = renoise.song().selection_in_pattern
      local groupPos = selection.end_track + 1
      
      -- Ensure the group position is valid
      if groupPos > renoise.song().sequencer_track_count then
        groupPos = renoise.song().sequencer_track_count + 1
      end
      
      -- Insert the group at the adjusted position
      renoise.song():insert_group_at(groupPos)

      -- Add tracks to the group one by one, skipping Master and Send tracks
      for i = selection.start_track, selection.end_track do
        if i <= renoise.song().sequencer_track_count then
          renoise.song():add_track_to_group(selection.start_track, groupPos)
        end
      end
    end
  end
}


renoise.tool():add_keybinding{
  name="Pattern Matrix:Paketti:Selection in Pattern Matrix to Group",
  invoke=function()
    local song = renoise.song()
    local selected_tracks = {}

    -- Function to read selected tracks in the pattern matrix
    local function read_pattern_matrix_selection()
      local sequencer = song.sequencer
      local total_tracks = song.sequencer_track_count
      local total_patterns = #sequencer.pattern_sequence

      -- Iterate over all tracks and patterns to find selected tracks
      for track_index = 1, total_tracks do
        for sequence_index = 1, total_patterns do
          if sequencer:track_sequence_slot_is_selected(track_index, sequence_index) then
            if not selected_tracks[track_index] then
              table.insert(selected_tracks, track_index)
            end
            break -- Stop checking this track, as we already know it's selected
          end
        end
      end
    end

    -- Read selection from the Pattern Matrix
    read_pattern_matrix_selection()

    -- Fallback to the currently selected track if no valid selection exists
    if #selected_tracks == 0 then
      table.insert(selected_tracks, song.selected_track_index)
    end

    -- Remove any invalid tracks (Send or Master Tracks)
    for i = #selected_tracks, 1, -1 do
      if selected_tracks[i] > song.sequencer_track_count then
        table.remove(selected_tracks, i)
      end
    end

    -- Ensure there are valid tracks to group
    if #selected_tracks == 0 then return end

    -- Insert the group after the last selected track
    local groupPos = selected_tracks[#selected_tracks] + 1
    if groupPos > song.sequencer_track_count then
      groupPos = song.sequencer_track_count + 1
    end
    song:insert_group_at(groupPos)

    -- Add selected tracks to the group in their original order
    for _, track_index in ipairs(selected_tracks) do
      -- Track position needs to be adjusted as we add to the group
      local adjusted_group_pos = groupPos
      song:add_track_to_group(track_index, adjusted_group_pos)
      groupPos = groupPos + 1
    end
  end
}








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


for i=0,63 do
  renoise.tool():add_keybinding{
    name="Global:Paketti:Set Selected Track Output Routing "..string.format("%02d",i),
    invoke=function() simpleOutputRoute(i+1) end
  }
end
--------

function pakettiMasterOutputRoutings(output)
  local song=renoise.song()
  local masterTrack=song:track(song.sequencer_track_count+1)
  if output<=#masterTrack.available_output_routings then
    masterTrack.output_routing=masterTrack.available_output_routings[output]
  else
    renoise.app():show_status("This Master Output Routing Channel is not available on the selected sound device.")
  end
end

for i=0,63 do
  renoise.tool():add_keybinding{
    name="Global:Paketti:Set Master Track Output Routing "..string.format("%02d",i),
    invoke=function() pakettiMasterOutputRoutings(i+1) end
  }
end







-----
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
-----------

function halveBeatsyncLinesAll()
    local s = renoise.song()
    local currInst = s.selected_instrument_index
    if currInst == nil or not s.instruments[currInst] then
        print("No instrument selected.")
        return
    end
    local samples = s.instruments[currInst].samples
    if #samples < 1 then
        print("No samples available in the selected instrument.")
        return
    end

    local start_index = 1
    if #samples > 1 and #samples[1].slice_markers > 0 then
        start_index = 2
    end

    local reference_sync_lines = samples[start_index].beat_sync_lines
    if not samples[start_index].beat_sync_enabled then
        samples[start_index].beat_sync_enabled = true
        reference_sync_lines = samples[start_index].beat_sync_lines
    end
    if not reference_sync_lines then
        print("No valid samples found to reference for beatsync lines.")
        return
    end

    local new_sync_lines = math.max(math.floor(reference_sync_lines / 2), 1)

    -- Apply new sync lines
    for i = start_index, #samples do
        if samples[i].sample_buffer and samples[i].sample_buffer.has_sample_data then
            if not samples[i].beat_sync_enabled then
                samples[i].beat_sync_enabled = true
            end
            samples[i].beat_sync_lines = new_sync_lines
        end
    end
    renoise.app():show_status("Beatsync lines halved for all applicable samples from " .. reference_sync_lines .. " to " .. new_sync_lines)
end

function halveBeatsyncLinesSelected()
    local s = renoise.song()
    local currInst = s.selected_instrument_index
    if currInst == nil or not s.instruments[currInst] then
        print("No instrument selected.")
        return
    end
    local samples = s.instruments[currInst].samples
    local currSample = s.selected_sample_index
    if currSample == nil or currSample < 1 or currSample > #samples then
        print("Selected sample is invalid or does not exist.")
        return
    end
    if not samples[currSample].sample_buffer or not samples[currSample].sample_buffer.has_sample_data then
        print("Selected sample slot contains no sample data.")
        return
    end
    if not samples[currSample].beat_sync_enabled then
        samples[currSample].beat_sync_enabled = true
    end
    local reference_sync_lines = samples[currSample].beat_sync_lines
    local new_sync_lines = math.max(math.floor(reference_sync_lines / 2), 1)
    samples[currSample].beat_sync_lines = new_sync_lines
    renoise.app():show_status("Beatsync lines halved for the selected sample from " .. reference_sync_lines .. " to " .. new_sync_lines)
end

function doubleBeatsyncLinesAll()
    local s = renoise.song()
    local currInst = s.selected_instrument_index
    if currInst == nil or not s.instruments[currInst] then
        print("No instrument selected.")
        return
    end
    local samples = s.instruments[currInst].samples
    if #samples < 1 then
        print("No samples available in the selected instrument.")
        return
    end

    local start_index = 1
    if #samples > 1 and #samples[1].slice_markers > 0 then
        start_index = 2
    end

    local reference_sync_lines = samples[start_index].beat_sync_lines
    if not samples[start_index].beat_sync_enabled then
        samples[start_index].beat_sync_enabled = true
        reference_sync_lines = samples[start_index].beat_sync_lines
    end
    if not reference_sync_lines then
        print("No valid samples found to reference for beatsync lines.")
        return
    end
    if reference_sync_lines >= 512 then
        renoise.app():show_status("Maximum Beatsync line amount is 512, cannot go higher.")
        return
    end
    local new_sync_lines = math.min(reference_sync_lines * 2, 512)
    if reference_sync_lines == 1 then new_sync_lines = 2 end

    -- Apply new sync lines
    for i = start_index, #samples do
        if samples[i].sample_buffer and samples[i].sample_buffer.has_sample_data then
            if not samples[i].beat_sync_enabled then
                samples[i].beat_sync_enabled = true
            end
            samples[i].beat_sync_lines = new_sync_lines
        end
    end
    renoise.app():show_status("Beatsync lines doubled for all applicable samples from " .. reference_sync_lines .. " to " .. new_sync_lines)
end

function doubleBeatsyncLinesSelected()
    local s = renoise.song()
    local currInst = s.selected_instrument_index
    if currInst == nil or not s.instruments[currInst] then
        print("No instrument selected.")
        return
    end
    local samples = s.instruments[currInst].samples
    local currSample = s.selected_sample_index
    if currSample == nil or currSample < 1 or currSample > #samples then
        print("Selected sample is invalid or does not exist.")
        return
    end
    if not samples[currSample].sample_buffer or not samples[currSample].sample_buffer.has_sample_data then
        print("Selected sample slot contains no sample data.")
        return
    end
    if not samples[currSample].beat_sync_enabled then
        samples[currSample].beat_sync_enabled = true
    end
    local reference_sync_lines = samples[currSample].beat_sync_lines
    if reference_sync_lines >= 512 then
        renoise.app():show_status("Maximum Beatsync line amount is 512, cannot go higher.")
        return
    end
    local new_sync_lines = math.min(reference_sync_lines * 2, 512)
    if reference_sync_lines == 1 then new_sync_lines = 2 end
    samples[currSample].beat_sync_lines = new_sync_lines
    renoise.app():show_status("Beatsync lines doubled for the selected sample from " .. reference_sync_lines .. " to " .. new_sync_lines)
end

-- Main Menu Entries
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Beatsync Lines Halve (All)", invoke=function() halveBeatsyncLinesAll() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Beatsync Lines Halve (Selected Sample)", invoke=function() halveBeatsyncLinesSelected() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Beatsync Lines Double (All)", invoke=function() doubleBeatsyncLinesAll() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Beatsync Lines Double (Selected Sample)", invoke=function() doubleBeatsyncLinesSelected() end}

-- Sample Editor Menu Entries
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Beatsync Lines Halve (All)", invoke=function() halveBeatsyncLinesAll() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Beatsync Lines Halve (Selected Sample)", invoke=function() halveBeatsyncLinesSelected() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Beatsync Lines Double (All)", invoke=function() doubleBeatsyncLinesAll() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Beatsync Lines Double (Selected Sample)", invoke=function() doubleBeatsyncLinesSelected() end}

-- Sample Navigator Menu Entries
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Beatsync Lines Halve (All)", invoke=function() halveBeatsyncLinesAll() end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Beatsync Lines Halve (Selected Sample)", invoke=function() halveBeatsyncLinesSelected() end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Beatsync Lines Double (All)", invoke=function() doubleBeatsyncLinesAll() end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Beatsync Lines Double (Selected Sample)", invoke=function() doubleBeatsyncLinesSelected() end}

-- Keybindings
renoise.tool():add_keybinding{name="Global:Paketti:Halve Beatsync Lines (All)", invoke=function() halveBeatsyncLinesAll() end}
renoise.tool():add_keybinding{name="Global:Paketti:Halve Beatsync Lines (Selected Sample)", invoke=function() halveBeatsyncLinesSelected() end}
renoise.tool():add_keybinding{name="Global:Paketti:Double Beatsync Lines (All)", invoke=function() doubleBeatsyncLinesAll() end}
renoise.tool():add_keybinding{name="Global:Paketti:Double Beatsync Lines (Selected Sample)", invoke=function() doubleBeatsyncLinesSelected() end}






function pitchedInstrument(st)
renoise.app():load_instrument("Presets/" .. st .. "st_Pitchbend.xrni")
renoise.song().selected_instrument.name=(st .. "st_Pitchbend Instrument")
renoise.song().instruments[renoise.song().selected_instrument_index].macros_visible = true
renoise.song().instruments[renoise.song().selected_instrument_index].sample_modulation_sets[1].name=(st .. "st_Pitchbend")
end

function pitchedDrumkit()
renoise.app():load_instrument("Presets/12st_Pitchbend_Drumkit_C0.xrni")
renoise.song().selected_instrument.name="Pitchbend Drumkit"
renoise.song().instruments[renoise.song().selected_instrument_index].macros_visible = true
renoise.song().instruments[renoise.song().selected_instrument_index].sample_modulation_sets[1].name=("Pitchbend Drumkit")


end

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Instruments:12st PitchBend Instrument Init",invoke=function() pitchedInstrument(12) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:24st PitchBend Instrument Init",invoke=function() pitchedInstrument(24) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:36st PitchBend Instrument Init",invoke=function() pitchedInstrument(36) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:48st PitchBend Instrument Init",invoke=function() pitchedInstrument(48) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:64st PitchBend Instrument Init",invoke=function() pitchedInstrument(64) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:96st PitchBend Instrument Init",invoke=function() pitchedInstrument(96) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:PitchBend Drumkit Instrument Init",invoke=function() pitchedDrumkit() end}

renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Initialize..:12st PitchBend Instrument Init",invoke=function() pitchedInstrument(12) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:24st PitchBend Instrument Init",invoke=function() pitchedInstrument(24) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:36st PitchBend Instrument Init",invoke=function() pitchedInstrument(36) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:48st PitchBend Instrument Init",invoke=function() pitchedInstrument(48) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:64st PitchBend Instrument Init",invoke=function() pitchedInstrument(64) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:96st PitchBend Instrument Init",invoke=function() pitchedInstrument(96) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Initialize..:PitchBend Drumkit Instrument Init",invoke=function() pitchedDrumkit() end}

renoise.tool():add_keybinding{name="Global:Paketti:12st PitchBend Instrument Init", invoke=function() pitchedInstrument(12) end}
renoise.tool():add_keybinding{name="Global:Paketti:24st PitchBend Instrument Init", invoke=function() pitchedInstrument(24) end}
renoise.tool():add_keybinding{name="Global:Paketti:36st PitchBend Instrument Init", invoke=function() pitchedInstrument(36) end}
renoise.tool():add_keybinding{name="Global:Paketti:48st PitchBend Instrument Init", invoke=function() pitchedInstrument(48) end}
renoise.tool():add_keybinding{name="Global:Paketti:64st PitchBend Instrument Init", invoke=function() pitchedInstrument(64) end}
renoise.tool():add_keybinding{name="Global:Paketti:96st PitchBend Instrument Init", invoke=function() pitchedInstrument(96) end}
renoise.tool():add_keybinding{name="Global:Paketti:PitchBend Drumkit Instrument Init", invoke=function() pitchedDrumkit() end}


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
renoise.tool():add_keybinding{
  name = "Global:Paketti:Delete / Clear / Wipe Selected Note Column with EditStep", 
  invoke = function()
    local song = renoise.song()
    local pattern = song.selected_pattern
    local num_lines = pattern.number_of_lines
    local edit_step = song.transport.edit_step
    local line_index = song.selected_line_index
    local note_column = song.selected_note_column

    -- Ensure we have a selected note column
    if note_column then
      -- Wipe the selected note column contents (note, instrument, volume, panning, delay, samplefx)
      note_column:clear()
    end

    -- Calculate the next line index
    local next_line_index = line_index + edit_step
    if next_line_index > num_lines then
      next_line_index = next_line_index - num_lines
    end

    -- Move to the next line
    song.selected_line_index = next_line_index

    -- Show status to notify the action performed
    renoise.app():show_status("Wiped selected note column and moved by edit step")
  end
}



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
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Volume (All) (+0.01)",invoke=function() setInstrumentVolume(0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Volume (All) (-0.01)",invoke=function() setInstrumentVolume(-0.01) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Volume Reset (All) (0.0dB)",invoke=function()
    local instrument = renoise.song().selected_instrument
    for i=1, #instrument.samples do instrument.samples[i].volume=1 end end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Volume (All) (-INF dB)",invoke=function()
    local instrument = renoise.song().selected_instrument
    for i=1, #instrument.samples do instrument.samples[i].volume=0 end end}

function setActualInstrumentVolume(amount)
  local instrument = renoise.song().selected_instrument
  
  if not instrument then
    renoise.app():show_status("Cannot set volume: No instrument selected.")
    return
  end
  
  local currentVolume = instrument.volume
  local newVolume = currentVolume + amount
  
  -- Clamp the volume value to be within the valid range of 0.0 to 1.99526
  if newVolume > 1.99526 then
    newVolume = 1.99526
  elseif newVolume < 0.0 then
    newVolume = 0.0
  end
  
  -- Apply the new volume value to the instrument
  instrument.volume = newVolume
  renoise.app():show_status("Instrument volume set to " .. newVolume)
end

renoise.tool():add_keybinding{name = "Global:Paketti:Set Selected Instrument Global Volume (+0.01)",invoke = function() setActualInstrumentVolume(0.01) end}

renoise.tool():add_keybinding{name = "Global:Paketti:Set Selected Instrument Global Volume (-0.01)",invoke = function() setActualInstrumentVolume(-0.01) end}


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Global Volume (0.0dB)",invoke=function()
    renoise.song().selected_instrument.volume=1 end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Instrument Global Volume (-INF dB)",invoke=function()
    renoise.song().selected_instrument.volume=0 end}

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
  local sample_index = song.selected_sample_index
  local sample = instrument:sample(sample_index)
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

  -- Store the sample mapping properties
  local sample_mapping = sample.sample_mapping
  local base_note = sample_mapping.base_note
  local note_range = sample_mapping.note_range
  local velocity_range = sample_mapping.velocity_range
  local map_key_to_pitch = sample_mapping.map_key_to_pitch
  local map_velocity_to_volume = sample_mapping.map_velocity_to_volume

  -- Create a new temporary sample slot
  local temp_sample_index = #instrument.samples + 1
  instrument:insert_sample_at(temp_sample_index)
  local temp_sample = instrument:sample(temp_sample_index)
  local temp_sample_buffer = temp_sample.sample_buffer
  
  -- Prepare the temporary sample buffer with the same sample rate and bit depth as the original
  temp_sample_buffer:create_sample_data(sample_rate, bit_depth, 2, number_of_frames)
  temp_sample_buffer:prepare_sample_data_changes()

  -- Copy the sample data to the specified channels
  for frame = 1, number_of_frames do
    local sample_value = sample_buffer:sample_data(1, frame)
    if left_channel == 1 then
      temp_sample_buffer:set_sample_data(1, frame, sample_value)
      temp_sample_buffer:set_sample_data(2, frame, 0)
    else
      temp_sample_buffer:set_sample_data(1, frame, 0)
      temp_sample_buffer:set_sample_data(2, frame, sample_value)
    end
  end

  -- Finalize changes
  temp_sample_buffer:finalize_sample_data_changes()

  -- Name the new temporary sample
  temp_sample.name = sample_name
  
  -- Delete the original sample and insert the stereo sample into the same slot
  instrument:delete_sample_at(sample_index)
  instrument:insert_sample_at(sample_index)
  local new_sample = instrument:sample(sample_index)
  new_sample.name = sample_name

  -- Copy the stereo data from the temporary sample buffer to the new sample buffer
  local new_sample_buffer = new_sample.sample_buffer
  new_sample_buffer:create_sample_data(sample_rate, bit_depth, 2, number_of_frames)
  new_sample_buffer:prepare_sample_data_changes()

  for frame = 1, number_of_frames do
    local left_value = temp_sample_buffer:sample_data(1, frame)
    local right_value = temp_sample_buffer:sample_data(2, frame)
    new_sample_buffer:set_sample_data(1, frame, left_value)
    new_sample_buffer:set_sample_data(2, frame, right_value)
  end

  new_sample_buffer:finalize_sample_data_changes()

  -- Restore the sample mapping properties
  new_sample.sample_mapping.base_note = base_note
  new_sample.sample_mapping.note_range = note_range
  new_sample.sample_mapping.velocity_range = velocity_range
  new_sample.sample_mapping.map_key_to_pitch = map_key_to_pitch
  new_sample.sample_mapping.map_velocity_to_volume = map_velocity_to_volume

  -- Delete the temporary sample
  instrument:delete_sample_at(temp_sample_index)

  -- Provide feedback
  renoise.app():show_status("Mono sample successfully converted to specified channels with blank opposite channel.")
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
  local sample_index = song.selected_sample_index
  local sample = instrument:sample(sample_index)
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

  -- Store the sample mapping properties
  local sample_mapping = sample.sample_mapping
  local base_note = sample_mapping.base_note
  local note_range = sample_mapping.note_range
  local velocity_range = sample_mapping.velocity_range
  local map_key_to_pitch = sample_mapping.map_key_to_pitch
  local map_velocity_to_volume = sample_mapping.map_velocity_to_volume

  -- Create a new temporary sample slot
  local temp_sample_index = #instrument.samples + 1
  instrument:insert_sample_at(temp_sample_index)
  local temp_sample = instrument:sample(temp_sample_index)
  local temp_sample_buffer = temp_sample.sample_buffer
  
  -- Prepare the temporary sample buffer with the same sample rate and bit depth as the original
  temp_sample_buffer:create_sample_data(sample_rate, bit_depth, 2, number_of_frames)
  temp_sample_buffer:prepare_sample_data_changes()

  -- Copy the sample data
  for frame = 1, number_of_frames do
    local sample_value = sample_buffer:sample_data(1, frame)
    temp_sample_buffer:set_sample_data(1, frame, sample_value)
    temp_sample_buffer:set_sample_data(2, frame, sample_value)
  end

  -- Finalize changes
  temp_sample_buffer:finalize_sample_data_changes()

  -- Name the new temporary sample
  temp_sample.name = sample_name
  
  -- Delete the original sample and insert the stereo sample into the same slot
  instrument:delete_sample_at(sample_index)
  instrument:insert_sample_at(sample_index)
  local new_sample = instrument:sample(sample_index)
  new_sample.name = sample_name

  -- Copy the stereo data from the temporary sample buffer to the new sample buffer
  local new_sample_buffer = new_sample.sample_buffer
  new_sample_buffer:create_sample_data(sample_rate, bit_depth, 2, number_of_frames)
  new_sample_buffer:prepare_sample_data_changes()

  for frame = 1, number_of_frames do
    local sample_value = temp_sample_buffer:sample_data(1, frame)
    new_sample_buffer:set_sample_data(1, frame, sample_value)
    new_sample_buffer:set_sample_data(2, frame, sample_value)
  end

  new_sample_buffer:finalize_sample_data_changes()

  -- Restore the sample mapping properties
  new_sample.sample_mapping.base_note = base_note
  new_sample.sample_mapping.note_range = note_range
  new_sample.sample_mapping.velocity_range = velocity_range
  new_sample.sample_mapping.map_key_to_pitch = map_key_to_pitch
  new_sample.sample_mapping.map_velocity_to_volume = map_velocity_to_volume

  -- Delete the temporary sample
  instrument:delete_sample_at(temp_sample_index)

  -- Provide feedback
  renoise.app():show_status("Mono sample successfully converted to stereo and preserved in the same slot with keymapping settings.")
end

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}

renoise.tool():add_menu_entry{name="--Sample Mappings:Paketti..:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}


renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}


renoise.tool():add_keybinding{name="Sample Editor:Paketti:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}

renoise.tool():add_keybinding{name="Sample Keyzones:Paketti:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_keybinding{name="Sample Keyzones:Paketti:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
renoise.tool():add_keybinding{name="Sample Keyzones:Paketti:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}


renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Convert Mono to Stereo",invoke=convert_mono_to_stereo}
renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Mono to Right with Blank Left",invoke=function() mono_to_blank(0, 1) end}
renoise.tool():add_midi_mapping{name="Sample Editor:Paketti:Mono to Left with Blank Right",invoke=function() mono_to_blank(1, 0) end}
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
renoise.tool():add_keybinding{name="Global:Paketti:Duplicate Track, set to Selected Instrument",invoke=function() setToSelectedInstrument_DuplicateTrack() end}

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
renoise.tool():add_keybinding{name="Global:Paketti:Duplicate Track Duplicate Instrument",invoke=function() duplicateTrackDuplicateInstrument() end}
------------
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Note Interpolation",invoke=function() note_interpolation() end}
renoise.tool():add_midi_mapping{name="Paketti:Note Interpolation",invoke=function() note_interpolation() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Note Interpolation",invoke=function() note_interpolation() end}

-- Main function for note interpolation
function note_interpolation()
  -- Get the current song, pattern, and track
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local track_index = song.selected_track_index
  local pattern = song:pattern(pattern_index)
  local track = pattern:track(track_index)
  local pattern_length = pattern.number_of_lines

  -- Determine the number of visible note columns in the track
  local visible_note_columns = renoise.song().selected_track.visible_note_columns

  -- Variables for start and end lines
  local start_line, end_line
  local start_column, end_column

  -- Determine start and end lines and columns based on selection in pattern
  if song.selection_in_pattern then
    local selection = song.selection_in_pattern
    start_line = selection.start_line
    end_line = selection.end_line
    start_column = selection.start_column
    end_column = selection.end_column

    -- Clip the end_column to the number of visible note columns
    if end_column > visible_note_columns then
      end_column = visible_note_columns
    end
  else
    start_column = song.selected_note_column_index
    end_column = start_column
    start_line = 1
    end_line = pattern_length
  end

  -- Debug output for selection
  print("Selection in Pattern:")
  print("Start Line:", start_line)
  print("End Line:", end_line)
  print("Start Column:", start_column)
  print("End Column:", end_column)
  print("Visible Note Columns:", visible_note_columns)

  -- Ensure that a note column is selected
  if start_column == 0 then
    renoise.app():show_error("No note column selected.")
    return
  end

  -- Ensure there is a difference between start and end lines
  if start_line == end_line then
    renoise.app():show_error("The selection must span at least two lines.")
    return
  end

  -- Iterate over each note column in the range
  for note_column_index = start_column, end_column do
    -- Retrieve note columns from start and end lines
    local start_note = track:line(start_line):note_column(note_column_index)
    local end_note = track:line(end_line):note_column(note_column_index)

    -- Debug output for start and end notes
    print("Note Column Index:", note_column_index)
    print("Start Note:", start_note)
    print("End Note:", end_note)

    -- Check if start and end notes are not empty
    if not start_note.is_empty and not end_note.is_empty then
      -- Calculate note difference and step
      local note_diff = end_note.note_value - start_note.note_value
      local steps = end_line - start_line
      local step_size = note_diff / steps

      -- Interpolate notes between start and end lines
      for i = 1, steps - 1 do
        local interpolated_note_value = math.floor(start_note.note_value + (i * step_size))
        local line_index = start_line + i
        local line = track:line(line_index)
        local note_column = line:note_column(note_column_index)
        note_column:copy_from(start_note)
        note_column.note_value = interpolated_note_value
      end
    else
      renoise.app():show_status("Both start and end lines must contain notes in column " .. note_column_index .. ".")
    end
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
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Jump to First Track In Next Group",invoke=function() select_first_track_in_next_group(1) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Jump to First Track In Previous Group",invoke=function() select_first_track_in_next_group(0) end}
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
renoise.tool():add_midi_mapping{name="Paketti:Bypass All Other Track DSP Devices (Toggle)",invoke=function() toggle_bypass_selected_device() end}

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

function globalChangeVisibleColumnState(columnName,toggle)
  for i=1, renoise.song().sequencer_track_count do
    if renoise.song().tracks[i].type == 1 and columnName == "delay" then
      renoise.song().tracks[i].delay_column_visible = toggle
    elseif renoise.song().tracks[i].type == 1 and columnName == "volume" then
      renoise.song().tracks[i].volume_column_visible = toggle
    elseif renoise.song().tracks[i].type == 1 and columnName == "panning" then
      renoise.song().tracks[i].panning_column_visible = toggle
    elseif renoise.song().tracks[i].type == 1 and columnName == "sample_effects" then
      renoise.song().tracks[i].sample_effects_column_visible = toggle
    else
      renoise.app():show_status("Invalid column name: " .. columnName)
    end
  end
end

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Global Visible Column (All)",invoke=function() globalChangeVisibleColumnState("volume",true)
globalChangeVisibleColumnState("panning",true) globalChangeVisibleColumnState("delay",true) globalChangeVisibleColumnState("sample_effects",true) end}

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Global Visible Column (None)",invoke=function() globalChangeVisibleColumnState("volume",false)
globalChangeVisibleColumnState("panning",false) globalChangeVisibleColumnState("delay",false) globalChangeVisibleColumnState("sample_effects",false) end}


renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Visible Columns..:Toggle Visible Column (Volume) Globally",invoke=function() globalToggleVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Toggle Visible Column (Panning) Globally",invoke=function() globalToggleVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Toggle Visible Column (Delay) Globally",invoke=function() globalToggleVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Toggle Visible Column (Sample Effects) Globally",invoke=function() globalToggleVisibleColumnState("sample_effects") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Global Visible Column (Volume)",invoke=function() globalChangeVisibleColumnState("volume",true) end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Global Visible Column (Panning)",invoke=function() globalChangeVisibleColumnState("panning",true) end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Global Visible Column (Delay)",invoke=function() globalChangeVisibleColumnState("delay",true) end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Visible Columns..:Global Visible Column (Sample Effects)",invoke=function() globalChangeVisibleColumnState("sample_effects",true) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Visible Column (All)",invoke=function() globalChangeVisibleColumnState("volume",true)
globalChangeVisibleColumnState("panning",true) globalChangeVisibleColumnState("delay",true) globalChangeVisibleColumnState("sample_effects",true) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Visible Column (None)",invoke=function() globalChangeVisibleColumnState("volume",false)
globalChangeVisibleColumnState("panning",false) globalChangeVisibleColumnState("delay",false) globalChangeVisibleColumnState("sample_effects",false) end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Toggle Visible Column (Volume)",invoke=function() globalToggleVisibleColumnState("volume") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Toggle Visible Column (Panning)",invoke=function() globalToggleVisibleColumnState("panning") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Toggle Visible Column (Delay)",invoke=function() globalToggleVisibleColumnState("delay") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Toggle Visible Column (Sample Effects)",invoke=function() globalToggleVisibleColumnState("sample_effects") end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Set Visible Column (Volume)",invoke=function() globalChangeVisibleColumnState("volume",true) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Set Visible Column (Panning)",invoke=function() globalChangeVisibleColumnState("panning",true) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Set Visible Column (Delay)",invoke=function() globalChangeVisibleColumnState("delay",true) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Global Set Visible Column (Sample Effects)",invoke=function() globalChangeVisibleColumnState("sample_effects",true) end}

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (All)",invoke=function() globalChangeVisibleColumnState("volume",true)
globalChangeVisibleColumnState("panning",true) globalChangeVisibleColumnState("delay",true) globalChangeVisibleColumnState("sample_effects",true) end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (None)",invoke=function() globalChangeVisibleColumnState("volume",false)
globalChangeVisibleColumnState("panning",false) globalChangeVisibleColumnState("delay",false) globalChangeVisibleColumnState("sample_effects",false) end}


renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Toggle Visible Column (Volume) Globally",invoke=function() globalToggleVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Toggle Visible Column (Panning) Globally",invoke=function() globalToggleVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Toggle Visible Column (Delay) Globally",invoke=function() globalToggleVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Toggle Visible Column (Sample Effects) Globally",invoke=function() globalToggleVisibleColumnState("sample_effects") end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (Volume)",invoke=function() globalChangeVisibleColumnState("volume",true) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (Panning)",invoke=function() globalChangeVisibleColumnState("panning",true) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (Delay)",invoke=function() globalChangeVisibleColumnState("delay",true) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (Sample Effects)",invoke=function() globalChangeVisibleColumnState("sample_effects",true) end}

renoise.tool():add_menu_entry{name="--Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (All)",invoke=function() globalChangeVisibleColumnState("volume",true)
globalChangeVisibleColumnState("panning",true) globalChangeVisibleColumnState("delay",true) globalChangeVisibleColumnState("sample_effects",true) end}
renoise.tool():add_menu_entry{name="--Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (None)",invoke=function() globalChangeVisibleColumnState("volume",false)
globalChangeVisibleColumnState("panning",false) globalChangeVisibleColumnState("delay",false) globalChangeVisibleColumnState("sample_effects",false) end}


renoise.tool():add_menu_entry{name="--Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Toggle Visible Column (Volume) Globally",invoke=function() globalToggleVisibleColumnState("volume") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Toggle Visible Column (Panning) Globally",invoke=function() globalToggleVisibleColumnState("panning") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Toggle Visible Column (Delay) Globally",invoke=function() globalToggleVisibleColumnState("delay") end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Toggle Visible Column (Sample Effects)Globally",invoke=function() globalToggleVisibleColumnState("sample_effects") end}
renoise.tool():add_menu_entry{name="--Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (Volume)",invoke=function() globalChangeVisibleColumnState("volume",true) end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (Panning)",invoke=function() globalChangeVisibleColumnState("panning",true) end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (Delay)",invoke=function() globalChangeVisibleColumnState("delay",true) end}
renoise.tool():add_menu_entry{name="Main Menu:View:Paketti..:Pattern Editor:Visible Columns..:Global Visible Column (Sample Effects)",invoke=function() globalChangeVisibleColumnState("sample_effects",true) end}

-----------
-- Create Identical Track Function
function create_identical_track()
  -- Get the current song
  local song = renoise.song()
  -- Get the selected track index
  local selected_track_index = song.selected_track_index
  -- Get the selected track
  local selected_track = song:track(selected_track_index)
  
  -- Check if the selected track type is 1 (Sequencer Track)
  if selected_track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
    -- Create a new track next to the selected track
    song:insert_track_at(selected_track_index + 1)
    -- Get the new track
    local new_track = song:track(selected_track_index + 1)
    
    -- Copy note and effect column visibility settings
    new_track.visible_note_columns = selected_track.visible_note_columns
    new_track.visible_effect_columns = selected_track.visible_effect_columns
    
    -- Copy volume, panning, delay, and sample effects column visibility settings
    new_track.volume_column_visible = selected_track.volume_column_visible
    new_track.panning_column_visible = selected_track.panning_column_visible
    new_track.delay_column_visible = selected_track.delay_column_visible
    new_track.sample_effects_column_visible = selected_track.sample_effects_column_visible
    
    -- Copy track collapsed state
    new_track.collapsed = selected_track.collapsed
    
    -- Select the new track
    song.selected_track_index = selected_track_index + 1
  else
    -- If the selected track is not of type 1, show an error message
    renoise.app():show_error("Selected track is not a sequencer track (type 1).")
  end
end

-- Adding the function to the menu
renoise.tool():add_keybinding{name="Global:Paketti:Create Identical Track",invoke=create_identical_track}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Create Identical Track",invoke=create_identical_track}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Create Identical Track",invoke=create_identical_track}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Create Identical Track",invoke=create_identical_track}

-------


-- Function to toggle solo state for note columns in the selected track
function noteColumnSoloToggle()
  local song = renoise.song()
  local selected_track = song.tracks[song.selected_track_index]

  -- Check if any note column is muted in the selected track
  local any_muted = false
  for i = 1, selected_track.max_note_columns do
    if selected_track:column_is_muted(i) then
      any_muted = true
      break
    end
  end

  -- Toggle mute state for all note columns in the selected track
  for i = 1, selected_track.max_note_columns do
    selected_track:set_column_is_muted(i, not any_muted)
  end

  -- Show status message for the selected track
  renoise.app():show_status(any_muted and "Unmuted all note columns in the selected track" or "Muted all note columns in the selected track")
end

-- Function to toggle mute state for note columns in all tracks within the same group, except the selected track
function groupTracksNoteColumnSoloToggle()
  local song = renoise.song()
  local selected_track_index = song.selected_track_index
  local selected_track = song.tracks[selected_track_index]
  local selected_track_group = selected_track.group_parent

  -- Debug: Log selected track information
  print("Selected Track Index: ", selected_track_index)
  if selected_track_group then
    print("Selected Track Group Name: ", selected_track_group.name)
  else
    print("Selected Track Group: None")
  end

  -- Check if the selected track is part of a group
  if not selected_track_group then
    renoise.app():show_status("Selected track is not part of any group")
    return
  end

  -- Collect indices of all tracks in the group except the selected track
  local group_member_indices = {}
  for i, track in ipairs(song.tracks) do
    if track.group_parent and track.group_parent.name == selected_track_group.name and i ~= selected_track_index then
      table.insert(group_member_indices, i)
    end
  end

  -- Check if any note column is muted in any of the group tracks except the selected track
  local any_muted = false
  for _, member_index in ipairs(group_member_indices) do
    local track = song.tracks[member_index]
    for i = 1, track.max_note_columns do
      if track:column_is_muted(i) then
        any_muted = true
        break
      end
    end
    if any_muted then break end
  end

  -- Toggle mute state for all note columns in the group tracks
  for _, member_index in ipairs(group_member_indices) do
    local track = song.tracks[member_index]
    for i = 1, track.max_note_columns do
      track:set_column_is_muted(i, not any_muted)
    end
  end

  -- Show status message for the group tracks
  renoise.app():show_status(any_muted and "Unmuted all note columns in the group tracks" or "Muted all note columns in the group tracks")
end

-- Add keybinding for the note column solo toggle function
renoise.tool():add_keybinding{name="Global:Paketti:Note Column Solo Toggle",invoke=function() noteColumnSoloToggle() end}

-- Add keybinding for the group tracks note column solo toggle function
renoise.tool():add_keybinding{name="Global:Paketti:Group Tracks Note Column Solo Toggle",invoke=function() groupTracksNoteColumnSoloToggle() end}
------------------------
-- Function to check if the selected sample is a slice
function is_slice_selected()
  local song = renoise.song()
  local instrument = song.selected_instrument
  if not instrument or #instrument.samples == 0 then
    return false
  end
  
  local sample = instrument.samples[1]
  if not sample or #sample.slice_markers == 0 then
    return false
  end
  
  return true
end

-- Function to log messages for debugging
function debug_log(message)
  renoise.app():show_status(message)
  print(message)
end

-- Function to move slice marker by a given amount
function move_slice_marker(slice_index, amount)
  if not is_slice_selected() then 
    debug_log("No slice selected or no slice markers available.")
    return 
  end

  local sample = renoise.song().selected_instrument.samples[1]
  if slice_index <= 0 or slice_index > #sample.slice_markers then
    debug_log("Invalid slice index: " .. string.format("%X", slice_index))
    return
  end

  local old_marker_pos = sample.slice_markers[slice_index]
  local new_marker_pos = old_marker_pos + amount

  if new_marker_pos < 1 then new_marker_pos = 1 end
  if new_marker_pos > sample.sample_buffer.number_of_frames - 1 then
    new_marker_pos = sample.sample_buffer.number_of_frames - 1
  end

  sample:move_slice_marker(old_marker_pos, new_marker_pos)
  debug_log(string.format("Moved slice marker #%X from %d to %d", slice_index, old_marker_pos, new_marker_pos))
end

-- Keybinding functions
function move_slice_start_left_10() move_slice_marker(renoise.song().selected_sample_index - 1, -10) end
function move_slice_start_right_10() move_slice_marker(renoise.song().selected_sample_index - 1, 10) end
function move_slice_end_left_10() move_slice_marker(renoise.song().selected_sample_index, -10) end
function move_slice_end_right_10() move_slice_marker(renoise.song().selected_sample_index, 10) end
function move_slice_start_left_100() move_slice_marker(renoise.song().selected_sample_index - 1, -100) end
function move_slice_start_right_100() move_slice_marker(renoise.song().selected_sample_index - 1, 100) end
function move_slice_end_left_100() move_slice_marker(renoise.song().selected_sample_index, -100) end
function move_slice_end_right_100() move_slice_marker(renoise.song().selected_sample_index, 100) end
function move_slice_start_left_300() move_slice_marker(renoise.song().selected_sample_index - 1, -300) end
function move_slice_start_right_300() move_slice_marker(renoise.song().selected_sample_index - 1, 300) end
function move_slice_end_left_300() move_slice_marker(renoise.song().selected_sample_index, -300) end
function move_slice_end_right_300() move_slice_marker(renoise.song().selected_sample_index, 300) end
function move_slice_start_left_500() move_slice_marker(renoise.song().selected_sample_index - 1, -500) end
function move_slice_start_right_500() move_slice_marker(renoise.song().selected_sample_index - 1, 500) end
function move_slice_end_left_500() move_slice_marker(renoise.song().selected_sample_index, -500) end
function move_slice_end_right_500() move_slice_marker(renoise.song().selected_sample_index, 500) end



-- Register keybindings
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice Start Left by 10",invoke=move_slice_start_left_10}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice Start Right by 10",invoke=move_slice_start_right_10}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice End Left by 10",invoke=move_slice_end_left_10}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice End Right by 10",invoke=move_slice_end_right_10}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice Start Left by 100",invoke=move_slice_start_left_100}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice Start Right by 100",invoke=move_slice_start_right_100}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice End Left by 100",invoke=move_slice_end_left_100}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice End Right by 100",invoke=move_slice_end_right_100}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice Start Left by 300",invoke=move_slice_start_left_300}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice Start Right by 300",invoke=move_slice_start_right_300}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice End Left by 300",invoke=move_slice_end_left_300}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice End Right by 300",invoke=move_slice_end_right_300}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice Start Left by 500",invoke=move_slice_start_left_500}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice Start Right by 500",invoke=move_slice_start_right_500}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice End Left by 500",invoke=move_slice_end_left_500}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Move Slice End Right by 500",invoke=move_slice_end_right_500}

renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice Start Left by 10",invoke=move_slice_start_left_10}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice Start Right by 10",invoke=move_slice_start_right_10}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice End Left by 10",invoke=move_slice_end_left_10}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice End Right by 10",invoke=move_slice_end_right_10}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice Start Left by 100",invoke=move_slice_start_left_100}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice Start Right by 100",invoke=move_slice_start_right_100}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice End Left by 100",invoke=move_slice_end_left_100}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice End Right by 100",invoke=move_slice_end_right_100}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice Start Left by 300",invoke=move_slice_start_left_300}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice Start Right by 300",invoke=move_slice_start_right_300}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice End Left by 300",invoke=move_slice_end_left_300}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice End Right by 300",invoke=move_slice_end_right_300}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice Start Left by 500",invoke=move_slice_start_left_500}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice Start Right by 500",invoke=move_slice_start_right_500}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice End Left by 500",invoke=move_slice_end_left_500}
renoise.tool():add_keybinding{name="Sample Navigator:Paketti:Move Slice End Right by 500",invoke=move_slice_end_right_500}

renoise.tool():add_keybinding{name="Global:Paketti:Move Slice Start Left by 10",invoke=move_slice_start_left_10}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice Start Right by 10",invoke=move_slice_start_right_10}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice End Left by 10",invoke=move_slice_end_left_10}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice End Right by 10",invoke=move_slice_end_right_10}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice Start Left by 100",invoke=move_slice_start_left_100}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice Start Right by 100",invoke=move_slice_start_right_100}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice End Left by 100",invoke=move_slice_end_left_100}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice End Right by 100",invoke=move_slice_end_right_100}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice Start Left by 300",invoke=move_slice_start_left_300}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice Start Right by 300",invoke=move_slice_start_right_300}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice End Left by 300",invoke=move_slice_end_left_300}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice End Right by 300",invoke=move_slice_end_right_300}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice Start Left by 500",invoke=move_slice_start_left_500}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice Start Right by 500",invoke=move_slice_start_right_500}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice End Left by 500",invoke=move_slice_end_left_500}
renoise.tool():add_keybinding{name="Global:Paketti:Move Slice End Right by 500",invoke=move_slice_end_right_500}


----------
-- Main function to isolate slices or samples into new instruments
function PakettiIsolateSlices()
  local song = renoise.song()
  local selected_instrument_index = song.selected_instrument_index
  local instrument = song.selected_instrument
  local selected_sample_index = song.selected_sample_index

  if not instrument or #instrument.samples == 0 then
    renoise.app():show_status("No valid instrument with samples selected.")
    return
  end

  -- Helper function to create a new instrument with given sample data
  local function create_new_instrument(sample, start_frame, end_frame, name_suffix, index)
    song:insert_instrument_at(index)
    song.selected_instrument_index = index
    pakettiPreferencesDefaultInstrumentLoader()
    local new_instrument = song.instruments[index]
    new_instrument.name = instrument.name .. " (" .. sample.name .. ")" .. name_suffix

    new_instrument:insert_sample_at(1)
    local new_sample = new_instrument.samples[1]
    new_sample.name = sample.name .. name_suffix

    local slice_length = end_frame - start_frame + 1
    new_sample.sample_buffer:create_sample_data(
      sample.sample_buffer.sample_rate,
      sample.sample_buffer.bit_depth,
      sample.sample_buffer.number_of_channels,
      slice_length
    )
    new_sample.sample_buffer:prepare_sample_data_changes()

    for ch = 1, sample.sample_buffer.number_of_channels do
      for frame = 1, slice_length do
        new_sample.sample_buffer:set_sample_data(ch, frame, sample.sample_buffer:sample_data(ch, start_frame + frame - 1))
      end
    end

    new_sample.sample_buffer:finalize_sample_data_changes()
  end

  local sample = instrument.samples[1]
  local insert_index = selected_instrument_index + 1

  if #sample.slice_markers > 0 then
    for i, slice_start in ipairs(sample.slice_markers) do
      local slice_end = (i == #sample.slice_markers) and sample.sample_buffer.number_of_frames or sample.slice_markers[i + 1] - 1
      local slice_length = slice_end - slice_start + 1

      if slice_length > 0 then
        create_new_instrument(sample, slice_start, slice_end, " (S#" .. string.format("%02X", i) .. ")", insert_index)
        insert_index = insert_index + 1
      else
        renoise.app():show_status("Invalid slice length calculated.")
        return
      end
    end
    song.selected_instrument_index = selected_instrument_index + selected_sample_index - 1
  else
    for i = 1, #instrument.samples do
      local sample = instrument.samples[i]
      create_new_instrument(sample, 1, sample.sample_buffer.number_of_frames, " (Sample " .. string.format("%02X", i) .. ")", insert_index)
      insert_index = insert_index + 1
    end
    song.selected_instrument_index = selected_instrument_index + selected_sample_index
  end

  song.transport.octave = 4
  renoise.app():show_status(#sample.slice_markers > 0 and #sample.slice_markers .. " Slices isolated to new Instruments" or #instrument.samples .. " Samples isolated to new Instruments")
end

renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Isolate Slices or Samples to New Instruments",invoke=PakettiIsolateSlices}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Instruments:Isolate Slices or Samples to New Instruments",invoke=PakettiIsolateSlices}
renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Isolate Slices or Samples to New Instruments",invoke=PakettiIsolateSlices}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Isolate Slices or Samples to New Instruments",invoke=PakettiIsolateSlices}
renoise.tool():add_menu_entry{name="--Sample Mappings:Paketti..:Isolate Slices or Samples to New Instruments",invoke=PakettiIsolateSlices}
renoise.tool():add_keybinding{name="Global:Paketti:Isolate Slices or Samples to New Instruments",invoke=PakettiIsolateSlices}
renoise.tool():add_midi_mapping{name="Paketti:Isolate Slices or Samples to New Instruments",invoke=PakettiIsolateSlices}
---------
--[[
  This script reverses the notes and their associated data in the selected pattern range.
  It reads the selected notes, reverses their order, and writes them back to the original selection.
]]

function PakettiReverseNotesInSelection()
  local song = renoise.song()
  local selection = song.selection_in_pattern

  if not selection then
    renoise.app():show_status("No selection in the pattern.")
    return
  end

  local start_line = selection.start_line
  local end_line = selection.end_line
  local start_track = selection.start_track
  local end_track = selection.end_track

  local notes = {}
  local origin_track = song.tracks[start_track]

  -- Collect notes and effect columns from the selection
  for line = start_line, end_line do
    for track = start_track, end_track do
      local pattern_track = song.selected_pattern.tracks[track]
      local note_columns = pattern_track:line(line).note_columns
      local effect_columns = pattern_track:line(line).effect_columns
      local line_data = {note_columns = {}, effect_columns = {}}

      for column_index, column in ipairs(note_columns) do
        line_data.note_columns[column_index] = {
          note_value = column.note_value,
          instrument_value = column.instrument_value,
          volume_value = column.volume_value,
          panning_value = column.panning_value,
          delay_value = column.delay_value,
          is_empty = column.is_empty
        }
      end

      for column_index, column in ipairs(effect_columns) do
        line_data.effect_columns[column_index] = {
          number_value = column.number_value,
          amount_value = column.amount_value,
          is_empty = column.is_empty
        }
      end

      table.insert(notes, {line = line, track = track, line_data = line_data})
    end
  end

  -- Debug output for collected notes and effect columns
  print("Collected Notes and Effect Columns:")
  for _, note in ipairs(notes) do
    for column_index, column in ipairs(note.line_data.note_columns) do
      if not column.is_empty then
        print(string.format("Line: %d, Track: %d, Note Column: %d, Note: %d, Instrument: %d, Volume: %d, Panning: %d, Delay: %d",
          note.line, note.track, column_index, column.note_value, column.instrument_value, column.volume_value, column.panning_value, column.delay_value))
      else
        print(string.format("Line: %d, Track: %d, Note Column: %d is empty", note.line, note.track, column_index))
      end
    end
    for column_index, column in ipairs(note.line_data.effect_columns) do
      if not column.is_empty then
        print(string.format("Line: %d, Track: %d, Effect Column: %d, Number: %d, Amount: %d",
          note.line, note.track, column_index, column.number_value, column.amount_value))
      else
        print(string.format("Line: %d, Track: %d, Effect Column: %d is empty", note.line, note.track, column_index))
      end
    end
  end

  -- Reverse the collected notes and effect columns
  local reversed_notes = {}
  for i = #notes, 1, -1 do
    table.insert(reversed_notes, notes[i])
  end

  -- Debug output for reversed notes and effect columns
  print("Reversed Notes and Effect Columns:")
  for _, note in ipairs(reversed_notes) do
    for column_index, column in ipairs(note.line_data.note_columns) do
      if not column.is_empty then
        print(string.format("Line: %d, Track: %d, Note Column: %d, Note: %d, Instrument: %d, Volume: %d, Panning: %d, Delay: %d",
          note.line, note.track, column_index, column.note_value, column.instrument_value, column.volume_value, column.panning_value, column.delay_value))
      else
        print(string.format("Line: %d, Track: %d, Note Column: %d is empty", note.line, note.track, column_index))
      end
    end
    for column_index, column in ipairs(note.line_data.effect_columns) do
      if not column.is_empty then
        print(string.format("Line: %d, Track: %d, Effect Column: %d, Number: %d, Amount: %d",
          note.line, note.track, column_index, column.number_value, column.amount_value))
      else
        print(string.format("Line: %d, Track: %d, Effect Column: %d is empty", note.line, note.track, column_index))
      end
    end
  end

  -- Write reversed notes and effect columns back to the original selection
  for i, note in ipairs(reversed_notes) do
    local line_index = start_line + (i - 1)
    for column_index, column in ipairs(note.line_data.note_columns) do
      local note_column = song.selected_pattern.tracks[note.track]:line(line_index).note_columns[column_index]
      
      note_column.note_value = column.note_value
      note_column.instrument_value = column.instrument_value
      note_column.volume_value = column.volume_value
      note_column.panning_value = column.panning_value
      note_column.delay_value = column.delay_value

      -- Debug output before writing note
      print(string.format("Writing Note to Line: %d, Track: %d, Note Column: %d, Note: %d, Instrument: %d, Volume: %d, Panning: %d, Delay: %d",
        line_index, note.track, column_index, column.note_value, column.instrument_value, column.volume_value, column.panning_value, column.delay_value))
    end
    for column_index, column in ipairs(note.line_data.effect_columns) do
      local effect_column = song.selected_pattern.tracks[note.track]:line(line_index).effect_columns[column_index]
      
      effect_column.number_value = column.number_value
      effect_column.amount_value = column.amount_value

      -- Debug output before writing effect
      print(string.format("Writing Effect to Line: %d, Track: %d, Effect Column: %d, Number: %d, Amount: %d",
        line_index, note.track, column_index, column.number_value, column.amount_value))
    end
  end

  -- Debug output after writing back reversed notes and effect columns
  print("Reversed notes and effect columns written back to pattern in the original selection.")

  renoise.app():show_status("Notes and effect columns in the selection have been reversed.")
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Reverse Notes in Selection",invoke=PakettiReverseNotesInSelection}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Reverse Notes in Selection",invoke=PakettiReverseNotesInSelection}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Reverse Notes in Selection",invoke=PakettiReverseNotesInSelection}

-------



-- Define the function to lower the base note
function PakettiOctaveBaseNoteUp()
  -- Get the current instrument
  local instrument = renoise.song().selected_instrument
  
  -- Check if there is no instrument or no samples in the instrument
  if not instrument or #instrument.samples == 0 then
    renoise.app():show_status("There was no sample")
    return
  end

  -- Iterate over each sample in the instrument
  for i, sample in ipairs(instrument.samples) do
    if sample.sample_mapping ~= nil then
      -- Get the current base note
      local base_note = sample.sample_mapping.base_note
      
      -- Check if the base note is already at C-0
      if base_note <= 0 then
        renoise.app():show_status("Base note is at C-0, cannot go lower")
        return
      end
      
      -- Lower the base note by 12 semitones (1 octave)
      sample.sample_mapping.base_note = math.max(0, base_note - 12)
    end
  end
  renoise.app():show_status("Base note lowered by one octave for all samples")
end

-- Define the function to raise the base note
function PakettiOctaveBaseNoteDown()
  -- Get the current instrument
  local instrument = renoise.song().selected_instrument
  
  -- Check if there is no instrument or no samples in the instrument
  if not instrument or #instrument.samples == 0 then
    renoise.app():show_status("There was no sample")
    return
  end

  -- Iterate over each sample in the instrument
  for i, sample in ipairs(instrument.samples) do
    if sample.sample_mapping ~= nil then
      -- Get the current base note
      local base_note = sample.sample_mapping.base_note
      
      -- Check if the base note is already at C-9
      if base_note >= 108 then -- C-9 is MIDI note number 108
        renoise.app():show_status("Base note is at C-9, cannot go higher")
        return
      end
      
      -- Raise the base note by 12 semitones (1 octave)
      sample.sample_mapping.base_note = math.min(108, base_note + 12)
    end
  end
  renoise.app():show_status("Base note raised by one octave for all samples")
end

-- Add the functions to the menu entries
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Octave Basenote Up",invoke=PakettiOctaveBaseNoteUp}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Octave Basenote Down",invoke=PakettiOctaveBaseNoteDown}

-- Add keybindings for the functions
renoise.tool():add_keybinding{name="Global:Paketti:Octave Basenote Up",invoke=PakettiOctaveBaseNoteUp}
renoise.tool():add_keybinding{name="Global:Paketti:Octave Basenote Down",invoke=PakettiOctaveBaseNoteDown}

-- Add MIDI mappings for the functions
renoise.tool():add_midi_mapping{name="Paketti:Octave Basenote Up",invoke=PakettiOctaveBaseNoteUp}
renoise.tool():add_midi_mapping{name="Paketti:Octave Basenote Down",invoke=PakettiOctaveBaseNoteDown}
---------

-- Utility function to read file contents
local function PakettiSendPopulatorReadFile(file_path)
  local file = io.open(file_path, "r")
  if not file then
    error("Could not open file at: " .. file_path)
  end
  local content = file:read("*all")
  file:close()
  return content
end

-- Function to create and configure send devices for all tracks in the song
function PakettiPopulateSendTracksAllTracks()
  local song = renoise.song()
  local send_tracks = {}
  local count = 0

  -- Collect all send tracks
  for i = 1, #song.tracks do
    if song.tracks[i].type == renoise.Track.TRACK_TYPE_SEND then
      table.insert(send_tracks, {index = count, name = song.tracks[i].name, track_number = i - 1})
      count = count + 1
    end
  end

  -- Path to the XML preset file
  local PakettiSend_xml_file_path = "Presets/PakettiSend.XML"
  local PakettiSend_xml_data = PakettiSendPopulatorReadFile(PakettiSend_xml_file_path)

  -- Create the appropriate number of #Send devices in each track
  for _, track in ipairs(song.tracks) do
    if track.type == renoise.Track.TRACK_TYPE_SEQUENCER or track.type == renoise.Track.TRACK_TYPE_GROUP then
      local num_existing_devices = #track.devices

      for i = 1, count do
        local device_index = num_existing_devices + i
        track:insert_device_at("Audio/Effects/Native/#Send", device_index)
        track.devices[device_index].active_preset_data = PakettiSend_xml_data
      end

      local sendcount = num_existing_devices + 1 -- Start after existing devices

      -- Assign parameters and names in correct order
      for i = 1, count do
        local send_device = track.devices[sendcount]
        local send_track = send_tracks[i]
        send_device.parameters[3].value = send_track.index
        send_device.display_name = send_track.name
        sendcount = sendcount + 1
      end
    end
  end
end

-- Function to create and configure send devices for the selected track
function PakettiPopulateSendTracksSelectedTrack()
  local song = renoise.song()
  local current_track = song.selected_track

  if current_track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER and current_track.type ~= renoise.Track.TRACK_TYPE_GROUP then
    error("Selected track does not support adding send devices.")
    return
  end

  local send_tracks = {}
  local count = 0

  -- Collect all send tracks
  for i = 1, #song.tracks do
    if song.tracks[i].type == renoise.Track.TRACK_TYPE_SEND then
      table.insert(send_tracks, {index = count, name = song.tracks[i].name, track_number = i - 1})
      count = count + 1
    end
  end

  -- Path to the XML preset file
  local PakettiSend_xml_file_path = "Presets/PakettiSend.XML"
  local PakettiSend_xml_data = PakettiSendPopulatorReadFile(PakettiSend_xml_file_path)

  -- Create the appropriate number of #Send devices
  local num_existing_devices = #current_track.devices

  for i = 1, count do
    local device_index = num_existing_devices + i
    current_track:insert_device_at("Audio/Effects/Native/#Send", device_index)
    current_track.devices[device_index].active_preset_data = PakettiSend_xml_data
  end

  local sendcount = num_existing_devices + 1 -- Start after existing devices

  -- Assign parameters and names in correct order
  for i = 1, count do
    local send_device = current_track.devices[sendcount]
    local send_track = send_tracks[i]
    send_device.parameters[3].value = send_track.index
    send_device.display_name = send_track.name
    sendcount = sendcount + 1
  end
end

-- Add keybindings for the new functions
renoise.tool():add_keybinding{name="Global:Paketti:Populate Send Tracks for All Tracks",invoke=PakettiPopulateSendTracksAllTracks}
renoise.tool():add_keybinding{name="Global:Paketti:Populate Send Tracks for Selected Track",invoke=PakettiPopulateSendTracksSelectedTrack}

-- Add menu entries for the new functions under Main Menu:Tools
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Populate Send Tracks for All Tracks",invoke=PakettiPopulateSendTracksAllTracks}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Populate Send Tracks for Selected Track",invoke=PakettiPopulateSendTracksSelectedTrack}

-- Add menu entries for the new functions under Pattern Editor
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Populate Send Tracks for All Tracks",invoke=PakettiPopulateSendTracksAllTracks}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Populate Send Tracks for Selected Track",invoke=PakettiPopulateSendTracksSelectedTrack}

-- Add menu entries for the new functions under Mixer
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Populate Send Tracks for All Tracks",invoke=PakettiPopulateSendTracksAllTracks}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Populate Send Tracks for Selected Track",invoke=PakettiPopulateSendTracksSelectedTrack}

-- Add menu entries for the new functions under DSP Chain
renoise.tool():add_menu_entry{name="DSP Chain:Paketti..:Populate Send Tracks for All Tracks",invoke=PakettiPopulateSendTracksAllTracks}
renoise.tool():add_menu_entry{name="DSP Chain:Paketti..:Populate Send Tracks for Selected Track",invoke=PakettiPopulateSendTracksSelectedTrack}

-- Add menu entries for the new functions under DSP Device
renoise.tool():add_menu_entry{name="DSP Device:Paketti..:Populate Send Tracks for All Tracks",invoke=PakettiPopulateSendTracksAllTracks}
renoise.tool():add_menu_entry{name="DSP Device:Paketti..:Populate Send Tracks for Selected Track",invoke=PakettiPopulateSendTracksSelectedTrack}
--------
-- Function to fully update the Convolver preset XML
function full_update_convolver_preset_data(left_sample_data, right_sample_data, sample_rate, sample_name, stereo, sample_directory_path)
  print("Full updating Convolver preset data")
  local xml_template = [==[
<?xml version="1.0" encoding="UTF-8"?>
<FilterDevicePreset doc_version="13">
  <DeviceSlot type="ConvolverDevice">
    <IsMaximized>true</IsMaximized>
    <Gain>
      <Value>0.501187205</Value>
    </Gain>
    <Start>
      <Value>0.0</Value>
    </Start>
    <Length>
      <Value>1.0</Value>
    </Length>
    <Resample>
      <Value>0.5</Value>
    </Resample>
    <PreDelay>
      <Value>0.0</Value>
    </PreDelay>
    <Color>
      <Value>0.5</Value>
    </Color>
    <Dry>
      <Value>1.0</Value>
    </Dry>
    <Wet>
      <Value>0.25</Value>
    </Wet>
    <Stereo>%s</Stereo>
    <ImpulseDataLeft><![CDATA[%s]]></ImpulseDataLeft>
    <ImpulseDataRight><![CDATA[%s]]></ImpulseDataRight>
    <ImpulseDataSampleRate>%d</ImpulseDataSampleRate>
    <SampleName>%s</SampleName>
    <SampleDirectoryPath>%s</SampleDirectoryPath>
  </DeviceSlot>
</FilterDevicePreset>
]==]
  return string.format(xml_template, stereo and "true" or "false", left_sample_data, right_sample_data, sample_rate, sample_name, sample_directory_path)
end

-- Function to update specific fields in the Convolver preset XML
function soft_update_convolver_preset_data(current_xml, left_sample_data, right_sample_data, sample_rate, sample_name, stereo, sample_directory_path)
  print("Soft updating Convolver preset data")
  print("Current XML:", current_xml)
  if stereo then
    print(string.format("New data - Left: %d, Right: %d, Sample Rate: %d, Name: %s, Stereo: true, Path: %s",
      #left_sample_data, #right_sample_data, sample_rate, sample_name, sample_directory_path))
  else
    print(string.format("New data - Left: %d, Sample Rate: %d, Name: %s, Stereo: false, Path: %s",
      #left_sample_data, sample_rate, sample_name, sample_directory_path))
  end

  local updated_xml = current_xml
  updated_xml = updated_xml:gsub("<ImpulseDataLeft><!%[CDATA%[(.-)%]%]></ImpulseDataLeft>", 
    string.format("<ImpulseDataLeft><![CDATA[%s]]></ImpulseDataLeft>", left_sample_data))
  updated_xml = updated_xml:gsub("<ImpulseDataRight><!%[CDATA%[(.-)%]%]></ImpulseDataRight>", 
    string.format("<ImpulseDataRight><![CDATA[%s]]></ImpulseDataRight>", right_sample_data))
  updated_xml = updated_xml:gsub("<ImpulseDataSampleRate>(%d+)</ImpulseDataSampleRate>", 
    string.format("<ImpulseDataSampleRate>%d</ImpulseDataSampleRate>", sample_rate))
  updated_xml = updated_xml:gsub("<SampleName>(.-)</SampleName>", 
    string.format("<SampleName>%s</SampleName>", sample_name))
  updated_xml = updated_xml:gsub("<Stereo>(.-)</Stereo>", 
    string.format("<Stereo>%s</Stereo>", stereo and "true" or "false"))
  updated_xml = updated_xml:gsub("<SampleDirectoryPath>(.-)</SampleDirectoryPath>", 
    string.format("<SampleDirectoryPath>%s</SampleDirectoryPath>", sample_directory_path))

  print("Updated XML:", updated_xml)
  return updated_xml
end

function get_channel_data_as_b64(sample_buffer, channel)
  local data = {}
  for frame = 1, sample_buffer.number_of_frames do
    data[#data + 1] = sample_buffer:sample_data(channel, frame)
  end
  return renderb64(data)
end

-- Function to save the current instrument's sample buffer to a Convolver preset
function save_instrument_to_convolver(convolver_device, track_index, device_index)
  print(string.format("Saving instrument to Convolver at track %d, device %d", track_index, device_index))
  local selected_instrument = renoise.song().selected_instrument
  if #selected_instrument.samples == 0 then
    print("No sample data available in the selected instrument.")
    renoise.app():show_status("No sample data available in the selected instrument.")
    return
  end
  local selected_sample = selected_instrument:sample(1)
  local sample_buffer = selected_sample.sample_buffer
  if not sample_buffer.has_sample_data then
    print("No sample data available in the selected instrument.")
    renoise.app():show_status("No sample data available in the selected instrument.")
    return
  end
  local sample_name = selected_instrument.name
  local left_data = get_channel_data_as_b64(sample_buffer, 1)
  local right_data = sample_buffer.number_of_channels == 2 and get_channel_data_as_b64(sample_buffer, 2) or ""
  local sample_rate = sample_buffer.sample_rate
  local stereo = sample_buffer.number_of_channels == 2
  local sample_directory_path = "Custom/Path/To/Sample" -- Customize this path as needed
  local current_xml = convolver_device.active_preset_data
  print(string.format("Active preset data before update: %s", current_xml))
  print(string.format("Updating Convolver preset data with sample name: %s, sample rate: %d, stereo: %s, sample path: %s", sample_name, sample_rate, tostring(stereo), sample_directory_path))
  
  local is_init = current_xml:match("<SampleName>(.-)</SampleName>") == "No impulse loaded"
  local is_default = current_xml:match("<ImpulseDataSampleRate>(%d+)</ImpulseDataSampleRate>") == "0"

  local updated_xml
  if is_init or is_default then
    updated_xml = full_update_convolver_preset_data(left_data, right_data, sample_rate, sample_name, stereo, sample_directory_path)
  else
    updated_xml = soft_update_convolver_preset_data(current_xml, left_data, right_data, sample_rate, sample_name, stereo, sample_directory_path)
  end

  convolver_device.active_preset_data = updated_xml
  print(string.format("Active preset data after update: %s", convolver_device.active_preset_data))
  local length_left = string.len(left_data)
  local length_right = string.len(right_data)
  renoise.app():show_status(string.format("Added '%s' of length %d (left), %d (right), sample rate %d to Convolver %d", sample_name, length_left, length_right, sample_rate, device_index))
end

-- Function to create a new instrument and load sample data into the sample buffer
function create_instrument_from_convolver(convolver_device, track_index, device_index)
  print(string.format("Creating instrument from Convolver at track %d, device %d", track_index, device_index))
  local current_xml = convolver_device.active_preset_data
  if not current_xml or current_xml == "" then
    print(string.format("No preset data found in the selected device at track %d, device %d.", track_index, device_index))
    renoise.app():show_status("No preset data found in the selected device.")
    return
  end

  print("Active preset data before extraction:", current_xml)

  local left_sample_data = current_xml:match("<ImpulseDataLeft><!%[CDATA%[(.-)%]%]></ImpulseDataLeft>")
  local right_sample_data = current_xml:match("<ImpulseDataRight><!%[CDATA%[(.-)%]%]></ImpulseDataRight>")
  local sample_rate = tonumber(current_xml:match("<ImpulseDataSampleRate>(%d+)</ImpulseDataSampleRate>"))
  local sample_name = current_xml:match("<SampleName>(.-)</SampleName>")
  local stereo = right_sample_data and right_sample_data:match("%S") and true or false

  print(string.format("Sample rate: %d, Stereo: %s", sample_rate, tostring(stereo)))
  print(string.format("Left sample data length: %d", left_sample_data and #left_sample_data or 0))
  print(string.format("Right sample data length: %d", right_sample_data and #right_sample_data or 0))

  if not left_sample_data or left_sample_data == "" then
    print(string.format("No sample data available in the Convolver at track %d, device %d", track_index, device_index))
    renoise.app():show_status("No sample data available in the Convolver.")
    return
  end

  print("Sample data found, creating instrument...")

  local left_samples = parseb64(left_sample_data)
  local right_samples = stereo and parseb64(right_sample_data) or nil
  local selected_instrument_index = renoise.song().selected_instrument_index
  local new_instrument = renoise.song():insert_instrument_at(selected_instrument_index + 1)
  new_instrument.name = sample_name or "Loaded Convolver IR"
  local new_sample = new_instrument:insert_sample_at(1)
  local new_buffer = new_sample.sample_buffer
  new_sample.name = sample_name or "Loaded Convolver IR"
  local num_channels = stereo and 2 or 1
  local num_frames = #left_samples
  new_buffer:create_sample_data(sample_rate, 16, num_channels, num_frames)
  new_buffer:prepare_sample_data_changes()
  for frame = 1, num_frames do
    new_buffer:set_sample_data(1, frame, left_samples[frame])
  end
  if stereo and right_samples then
    for frame = 1, num_frames do
      new_buffer:set_sample_data(2, frame, right_samples[frame])
    end
  end
  new_buffer:finalize_sample_data_changes()
  renoise.song().selected_instrument_index = selected_instrument_index + 1
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  renoise.app():show_status("Convolver IR loaded into new instrument and Sample Editor opened.")
  print(string.format("Exported '%s' of length %d, sample rate %d, stereo: %s to new instrument", sample_name, num_frames, sample_rate, tostring(stereo)))
end

-- Key handler function
local function my_keyhandler_func(dialog, key)
  if not (key.modifiers == "" and key.name == "exclamation") then
    return key
  end
end

-- Function to show the GUI for selecting or adding a Convolver device
function show_convolver_selection_dialog(callback)
  print("Showing Convolver selection dialog")
  local vb = renoise.ViewBuilder()
  local dialog
  local function create_dialog_content()
    local dialog_content = vb:column {}
    local sample_name_text = vb:text {
      text = "Selected Sample: " .. (renoise.song().selected_sample and renoise.song().selected_sample.name or "None"),
      style = "strong"
    }
    dialog_content:add_child(sample_name_text)
    dialog_content:add_child(vb:button {
      text = "Refresh",
      notifier = function()
        dialog:close()
        show_convolver_selection_dialog(callback)
      end
    })
    renoise.song().selected_sample_observable:add_notifier(function()
      sample_name_text.text = "Selected Sample: " .. (renoise.song().selected_sample and renoise.song().selected_sample.name or "None")
    end)
    for t = 1, #renoise.song().tracks do
      local track = renoise.song().tracks[t]
      local track_type = "Unknown"
      if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then track_type = "Track"
      elseif track.type == renoise.Track.TRACK_TYPE_SEND then track_type = "Send"
      elseif track.type == renoise.Track.TRACK_TYPE_GROUP then track_type = "Group"
      elseif track.type == renoise.Track.TRACK_TYPE_MASTER then track_type = "Master"
      end
      local row = vb:row {}
      row:add_child(vb:column { width = 200, vb:text { text = string.format("%s, %s", track_type, track.name) } })
      local button_column = vb:row { width = "100%" }
      local convolver_count = 0
      for d = 1, #track.devices do
        local device = track.devices[d]
        if device.name == "Convolver" then
          convolver_count = convolver_count + 1
          button_column:add_child(vb:button {
            text = string.format("Convolver #%d Import", convolver_count),
            notifier = function()
              renoise.song().selected_track_index = t
              renoise.song().selected_device_index = d
              print(string.format("Importing Convolver IR from track %d, device %d", t, d))
              callback(device, t, d, "import")
            end
          })
          button_column:add_child(vb:button {
            text = string.format("Convolver #%d Export", convolver_count),
            notifier = function()
              renoise.song().selected_track_index = t
              renoise.song().selected_device_index = d
              print(string.format("Exporting Convolver IR from track %d, device %d", t, d))
              callback(device, t, d, "export")
            end
          })
        end
      end
      row:add_child(button_column)
      row:add_child(vb:button {
        text = "Insert Convolver as First",
        notifier = function()
          local device = track:insert_device_at("Audio/Effects/Native/Convolver", 2)
          renoise.song().selected_track_index = t
          renoise.song().selected_device_index = 2
          dialog:close()
          show_convolver_selection_dialog(callback)
        end
      })
      row:add_child(vb:button {
        text = "Insert Convolver as Last",
        notifier = function()
          local device_position = #renoise.song().tracks[t].devices + 1
          local device = track:insert_device_at("Audio/Effects/Native/Convolver", device_position)
          renoise.song().selected_track_index = t
          renoise.song().selected_device_index = device_position
          dialog:close()
          show_convolver_selection_dialog(callback)
        end
      })
      dialog_content:add_child(row)
    end
    return dialog_content
  end
  dialog = renoise.app():show_custom_dialog("Select or Add Convolver Device", create_dialog_content(), my_keyhandler_func)
end

-- Function to handle import and export actions
function handle_convolver_action(device, track_index, device_index, action)
  if action == "import" then
    save_instrument_to_convolver(device, track_index, device_index)
  elseif action == "export" then
    create_instrument_from_convolver(device, track_index, device_index)
  end
end

-- Adding menu entries
renoise.tool():add_menu_entry { name = "--Main Menu:Tools:Paketti..:Show Convolver Selection Dialog...", invoke = function()
  show_convolver_selection_dialog(handle_convolver_action)
end }

renoise.tool():add_menu_entry { name = "Main Menu:Tools:Paketti..:Import Selected Sample to Selected Convolver", invoke = function()
  print("Importing selected sample to Convolver via menu entry")
  local selected_device = renoise.song().selected_device
  local selected_track_index = renoise.song().selected_track_index
  local selected_device_index = renoise.song().selected_device_index
  if not selected_device or selected_device.name ~= "Convolver" then
    show_convolver_selection_dialog(handle_convolver_action)
    return
  end
  save_instrument_to_convolver(selected_device, selected_track_index, selected_device_index)
end }

renoise.tool():add_menu_entry { name = "--DSP Device:Paketti..:Import Selected Sample to Convolver", invoke = function()
  print("Importing selected sample to Convolver via DSP menu entry")
  local selected_device = renoise.song().selected_device
  local selected_track_index = renoise.song().selected_track_index
  local selected_device_index = renoise.song().selected_device_index
  if not selected_device or selected_device.name ~= "Convolver" then
    show_convolver_selection_dialog(handle_convolver_action)
    return
  end
  save_instrument_to_convolver(selected_device, selected_track_index, selected_device_index)
end }

renoise.tool():add_menu_entry { name = "--Mixer:Paketti..:Import Selected Sample to Convolver", invoke = function()
  print("Importing selected sample to Convolver via Mixer menu entry")
  local selected_device = renoise.song().selected_device
  local selected_track_index = renoise.song().selected_track_index
  local selected_device_index = renoise.song().selected_device_index
  if not selected_device or selected_device.name ~= "Convolver" then
    show_convolver_selection_dialog(handle_convolver_action)
    return
  end
  save_instrument_to_convolver(selected_device, selected_track_index, selected_device_index)
end }

renoise.tool():add_menu_entry { name = "--Sample Editor:Paketti..:Import Selected Sample to Convolver", invoke = function()
  print("Importing selected sample to Convolver via Sample Editor menu entry")
  local selected_device = renoise.song().selected_device
  local selected_track_index = renoise.song().selected_track_index
  local selected_device_index = renoise.song().selected_device_index
  if not selected_device or selected_device.name ~= "Convolver" then
    show_convolver_selection_dialog(handle_convolver_action)
    return
  end
  save_instrument_to_convolver(selected_device, selected_track_index, selected_device_index)
end }

renoise.tool():add_menu_entry { name = "Mixer:Paketti..:Export Convolver IR into New Instrument", invoke = function()
  print("Exporting Convolver IR into New Instrument via menu entry")
  local selected_device = renoise.song().selected_device
  local selected_track_index = renoise.song().selected_track_index
  local selected_device_index = renoise.song().selected_device_index
  if not selected_device or selected_device.name ~= "Convolver" then
    show_convolver_selection_dialog(handle_convolver_action)
    return
  end
  create_instrument_from_convolver(selected_device, selected_track_index, selected_device_index)
end }

renoise.tool():add_menu_entry { name = "Main Menu:Tools:Paketti..:Export Convolver IR into New Instrument", invoke = function()
  print("Exporting Convolver IR into New Instrument via menu entry")
  local selected_device = renoise.song().selected_device
  local selected_track_index = renoise.song().selected_track_index
  local selected_device_index = renoise.song().selected_device_index
  if not selected_device or selected_device.name ~= "Convolver" then
    show_convolver_selection_dialog(handle_convolver_action)
    return
  end
  create_instrument_from_convolver(selected_device, selected_track_index, selected_device_index)
end }

renoise.tool():add_menu_entry { name = "DSP Device:Paketti..:Export Convolver IR into New Instrument", invoke = function()
  print("Exporting Convolver IR into New Instrument via DSP menu entry")
  local selected_device = renoise.song().selected_device
  local selected_track_index = renoise.song().selected_track_index
  local selected_device_index = renoise.song().selected_device_index
  if not selected_device or selected_device.name ~= "Convolver" then
    show_convolver_selection_dialog(handle_convolver_action)
    return
  end
  create_instrument_from_convolver(selected_device, selected_track_index, selected_device_index)
end }


renoise.tool():add_menu_entry { name = "Mixer:Paketti..:Show Convolver Selection Dialog", invoke = function()
  print("Showing Convolver Selection Dialog via Mixer menu")
  show_convolver_selection_dialog(handle_convolver_action)
end }

renoise.tool():add_menu_entry { name = "DSP Device:Paketti..:Show Convolver Selection Dialog", invoke = function()
  print("Showing Convolver Selection Dialog via DSP menu")
  show_convolver_selection_dialog(handle_convolver_action)
end }

renoise.tool():add_menu_entry { name = "Sample Editor:Paketti..:Show Convolver Selection Dialog", invoke = function()
  print("Showing Convolver Selection Dialog via Sample Editor menu")
  show_convolver_selection_dialog(handle_convolver_action)
end }





------------
function tknaMidiSelectedTrackOutputRoutings(midi_value)
  local track=renoise.song().selected_track
  local routings=#track.available_output_routings
  local output=math.floor((midi_value/127)*routings)+1
  if output<=routings then
    track.output_routing=track.available_output_routings[output]
    renoise.app():show_status("Selected Track Output Routing set to "..output)
  else
    renoise.app():show_status("Selected Track Output Routing value out of range.")
  end
end

function tknaMidiMasterOutputRoutings(midi_value)
  local song=renoise.song()
  local masterTrack=song:track(song.sequencer_track_count+1)
  local routings=#masterTrack.available_output_routings
  local output=math.floor((midi_value/127)*routings)+1
  if output<=routings then
    masterTrack.output_routing=masterTrack.available_output_routings[output]
    renoise.app():show_status("Master Track Output Routing set to "..output)
  else
    renoise.app():show_status("Master Track Output Routing value out of range.")
  end
end

renoise.tool():add_midi_mapping{name="Paketti:Midi Change Selected Track Output Routings",
  invoke=function(midi_message)
    local midi_value=midi_message.int_value
    tknaMidiSelectedTrackOutputRoutings(midi_value)
  end
}

renoise.tool():add_midi_mapping{name="Paketti:Midi Change Master Output Routings",
  invoke=function(midi_message)
    local midi_value=midi_message.int_value
    tknaMidiMasterOutputRoutings(midi_value)
  end
}

--------
function pakettiMidiSimpleOutputRoute(output)
  local track=renoise.song().selected_track
  if output<=#track.available_output_routings then
    track.output_routing=track.available_output_routings[output]
    renoise.app():show_status("Selected Track Output Routing set to "..output)
  else
    renoise.app():show_status("Selected Track Output Routing value out of range.")
  end
end

function pakettiMidiMasterOutputRoutings(output)
  local song=renoise.song()
  local masterTrack=song:track(song.sequencer_track_count+1)
  if output<=#masterTrack.available_output_routings then
    masterTrack.output_routing=masterTrack.available_output_routings[output]
    renoise.app():show_status("Master Track Output Routing set to "..output)
  else
    renoise.app():show_status("Master Track Output Routing value out of range.")
  end
end

for i=0,63 do renoise.tool():add_midi_mapping{name="Paketti:Midi Set Selected Track Output Routing "..string.format("%02d",i),
    invoke=function(midi_message)
      pakettiMidiSimpleOutputRoute(i+1)
    end
  }
end

for i=0,63 do renoise.tool():add_midi_mapping{name="Paketti:Midi Set Master Track Output Routing "..string.format("%02d",i),
    invoke=function(midi_message)
      pakettiMidiMasterOutputRoutings(i+1)
    end
  }
end
----------------------
-- Function to toggle the MuteSource value in the XML data
function sendTest()
  -- Define the XML data with MuteSource as false
  local xml_data_false = [[
  <?xml version="1.0" encoding="UTF-8"?>
  <FilterDevicePreset doc_version="13">
    <DeviceSlot type="SendDevice">
      <IsMaximized>true</IsMaximized>
      <SendAmount>
        <Value>0.0</Value>
      </SendAmount>
      <SendPan>
        <Value>0.5</Value>
      </SendPan>
      <DestSendTrack>
        <Value>0.0</Value>
      </DestSendTrack>
      <MuteSource>false</MuteSource>
      <SmoothParameterChanges>true</SmoothParameterChanges>
      <ApplyPostVolume>true</ApplyPostVolume>
    </DeviceSlot>
  </FilterDevicePreset>
  ]]

  -- Define the XML data with MuteSource as true
  local xml_data_true = [[
  <?xml version="1.0" encoding="UTF-8"?>
  <FilterDevicePreset doc_version="13">
    <DeviceSlot type="SendDevice">
      <IsMaximized>true</IsMaximized>
      <SendAmount>
        <Value>0.0</Value>
      </SendAmount>
      <SendPan>
        <Value>0.5</Value>
      </SendPan>
      <DestSendTrack>
        <Value>0.0</Value>
      </DestSendTrack>
      <MuteSource>true</MuteSource>
      <SmoothParameterChanges>true</SmoothParameterChanges>
      <ApplyPostVolume>true</ApplyPostVolume>
    </DeviceSlot>
  </FilterDevicePreset>
  ]]

  -- Read the current active preset data
  local active_preset_data = renoise.song().selected_track.devices[2].active_preset_data

  -- Determine the current state of MuteSource in active_preset_data
  local mute_source_current = string.match(active_preset_data, "<MuteSource>(.-)</MuteSource>")

  -- Toggle the MuteSource value
  if mute_source_current == "true" then
    active_preset_data = xml_data_false
  else
    active_preset_data = xml_data_true
  end

  -- Set the modified XML data back to the active preset
  renoise.song().selected_track.devices[2].active_preset_data = active_preset_data
end

-- Add the keybinding to toggle the MuteSource value
renoise.tool():add_keybinding{name="Global:Paketti:Send Reverser",invoke=function() sendTest() end}
------
function tknaSelectedTrackVolume0to1Toggle(number)
renoise.song().tracks[renoise.song().selected_track_index].postfx_volume.value=number
end


renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Volume to -INF dB", invoke = function() tknaSelectedTrackVolume0to1Toggle(0) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Track Volume to 0.0dB", invoke = function() tknaSelectedTrackVolume0to1Toggle(1) end}

function tknaMasterTrackVolume0to1Toggle(number)
local masterTrackIndex=renoise.song().sequencer_track_count+1
renoise.song().tracks[masterTrackIndex].postfx_volume.value=number
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Master Track Volume to -INF dB", invoke = function() tknaMasterTrackVolume0to1Toggle(0) end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Master Track Volume to 0.0dB", invoke = function() tknaMasterTrackVolume0to1Toggle(1) end}
-------------



function tknaChangeMasterTrackVolumeBy(dB_change)
  local masterTrackIndex=renoise.song().sequencer_track_count+1
  local masterTrack=renoise.song().tracks[masterTrackIndex]
  local currentVolumeString=masterTrack.postfx_volume.value_string
  local currentVolumeValue=masterTrack.postfx_volume.value

  -- Debug: Current state
  print("-----")
  print("Starting with dB change: "..dB_change.." dB")
  print("Current Volume String: "..currentVolumeString)
  print("Current Volume Value: "..currentVolumeValue)

  -- Extract the numeric value from the value_string
  local currentdB=tonumber(currentVolumeString:match("[-]?%d+%.?%d*")) or -200

  -- Debug: Extracted current dB
  print("Current dB: "..currentdB)

  -- Handle the case where the volume is at -INF
  if currentVolumeString=="-INF dB" then
    if dB_change>0 then
      currentdB=-48 -- Jump to -48dB when increasing from -INF
      print("New dB set to: "..currentdB.." because current volume is at -INF and change is positive")
    else
      renoise.app():show_status("Master Track Volume is already at -INF, cannot go lower.")
      return
    end
  end

  local newdB=currentdB+dB_change
  print("New dB after change: "..newdB)

  -- Correctly handle the transitions
  if newdB>3 then
    newdB=3
    renoise.app():show_status("Master Track Volume is already at 3.0dB, cannot go higher.")
  elseif newdB>=2.9 and newdB<3 and currentdB<2.9 then
    newdB=math.floor((currentdB+dB_change)*100+0.5)/100
  elseif newdB==3.0 and dB_change<0 then
    newdB=math.floor((currentdB+dB_change)*100+0.5)/100
  elseif newdB<=-48 and dB_change<0 then
    newdB=-200 -- Transition to -INF
  elseif newdB<=-47.9 and newdB>-48.1 and dB_change>0 then
    newdB=math.floor((currentdB+dB_change)*100+0.5)/100
  end

  newdB=math.floor(newdB*100+0.5)/100 -- Reduce to 2 decimals
  local newVolumeString
  if newdB<=-200 then
    newVolumeString="-INF dB"
  else
    newVolumeString=string.format("%.2f dB", newdB)
  end

  -- Debug: What we are going to do
  print("Setting New Volume String: "..newVolumeString)
  print("Setting New Volume Value: "..newdB)

  masterTrack.postfx_volume.value_string=newVolumeString

  -- Debug: New state
  print("New Volume String: "..masterTrack.postfx_volume.value_string)
  print("New Volume Value: "..masterTrack.postfx_volume.value)

  renoise.app():show_status("Master Track Volume: "..masterTrack.postfx_volume.value_string)
end

renoise.tool():add_keybinding{name="Global:Paketti:Change Master Track Volume by +0.1dB", invoke=function() tknaChangeMasterTrackVolumeBy(0.1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Change Master Track Volume by -0.1dB", invoke=function() tknaChangeMasterTrackVolumeBy(-0.1) end}
-------


local function pakettiResizeAndFill(patternSize)
  local song = renoise.song()
  local pattern = song.selected_pattern
  local current_length = pattern.number_of_lines
  local filled = false

  if current_length == patternSize then
    renoise.app():show_status("Pattern is already " .. patternSize .. " rows.")
    return
  end

  if current_length > patternSize then
    pattern.number_of_lines = patternSize
    renoise.app():show_status("Resized to " .. patternSize)
    return
  end

  while current_length < patternSize do
    local new_length = current_length * 2

    if new_length > renoise.Pattern.MAX_NUMBER_OF_LINES then
      renoise.app():show_status("Cannot resize pattern beyond the maximum limit of " .. renoise.Pattern.MAX_NUMBER_OF_LINES .. " lines.")
      return
    end

    pattern.number_of_lines = new_length

    for track_index, pattern_track in ipairs(pattern.tracks) do
      if not pattern_track.is_empty then
        for line_index = 1, current_length do
          local line = pattern_track:line(line_index)
          local new_line = pattern_track:line(line_index + current_length)
          new_line:copy_from(line)
        end
      end

      local track_automations = song.patterns[song.selected_pattern_index].tracks[track_index].automation
      for _, automation in pairs(track_automations) do
        local points = automation.points
        local new_points = {}
        for _, point in ipairs(points) do
          local new_time = point.time + current_length
          if new_time <= new_length then
            table.insert(new_points, {time = new_time, value = point.value})
          end
        end
        for _, new_point in ipairs(new_points) do
          automation:add_point_at(new_point.time, new_point.value)
        end
      end
    end

    current_length = new_length
    filled = true
  end

  if filled then
    renoise.app():show_status("Resized to " .. patternSize .. " and filled with pattern length " .. (patternSize / 2) .. " content")
  else
    renoise.app():show_status("Resized to " .. patternSize)
  end
end

renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:Pattern Editor:Resize&Fill:Paketti Pattern Resize and Fill 032",invoke=function() pakettiResizeAndFill(32) end}
renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:Pattern Editor:Resize&Fill:Paketti Pattern Resize and Fill 064",invoke=function() pakettiResizeAndFill(64) end}
renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:Pattern Editor:Resize&Fill:Paketti Pattern Resize and Fill 128",invoke=function() pakettiResizeAndFill(128) end}
renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:Pattern Editor:Resize&Fill:Paketti Pattern Resize and Fill 256",invoke=function() pakettiResizeAndFill(256) end}
renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:Pattern Editor:Resize&Fill:Paketti Pattern Resize and Fill 512",invoke=function() pakettiResizeAndFill(512) end}

renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Resize&Fill:Paketti Pattern Resize and Fill 032",invoke=function() pakettiResizeAndFill(32) end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Resize&Fill:Paketti Pattern Resize and Fill 064",invoke=function() pakettiResizeAndFill(64) end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Resize&Fill:Paketti Pattern Resize and Fill 128",invoke=function() pakettiResizeAndFill(128) end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Resize&Fill:Paketti Pattern Resize and Fill 256",invoke=function() pakettiResizeAndFill(256) end}
renoise.tool():add_menu_entry {name="Pattern Editor:Paketti..:Resize&Fill:Paketti Pattern Resize and Fill 512",invoke=function() pakettiResizeAndFill(512) end}

renoise.tool():add_keybinding {name="Global:Paketti:Pattern Resize and Fill 032",invoke=function() pakettiResizeAndFill(32) end}
renoise.tool():add_keybinding {name="Global:Paketti:Pattern Resize and Fill 064",invoke=function() pakettiResizeAndFill(64) end}
renoise.tool():add_keybinding {name="Global:Paketti:Pattern Resize and Fill 128",invoke=function() pakettiResizeAndFill(128) end}
renoise.tool():add_keybinding {name="Global:Paketti:Pattern Resize and Fill 256",invoke=function() pakettiResizeAndFill(256) end}
renoise.tool():add_keybinding {name="Global:Paketti:Pattern Resize and Fill 512",invoke=function() pakettiResizeAndFill(512) end}

-----



-- Define the function to flood fill with the selection
function floodfill_with_selection()
  -- Get the current song within the function
  local song = renoise.song()
  
  -- Ensure there's a selection in the pattern
  local selection = song.selection_in_pattern
  if not selection then
    renoise.app():show_status("No selection in pattern.")
    return
  end

  local start_row = selection.start_line
  local end_row = selection.end_line
  local num_lines = song.selected_pattern.number_of_lines

  -- Determine the length of the selection
  local selection_length = end_row - start_row + 1

  -- Get the track indices in the selection
  local start_track = selection.start_track
  local end_track = selection.end_track

  -- Store the selected data
  local selection_data = {}

  -- Iterate over the selected tracks
  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    local pattern_track = song:pattern(song.selected_pattern_index):track(track_idx)
    local num_note_columns = track.visible_note_columns
    local num_effect_columns = track.visible_effect_columns
    local total_columns = num_note_columns + num_effect_columns

    -- Determine start and end columns for the current track
    local track_start_column = track_idx == start_track and selection.start_column or 1
    local track_end_column = track_idx == end_track and selection.end_column or total_columns

    -- Debug: print track info
    rprint({
      track_idx = track_idx,
      track_start_column = track_start_column,
      track_end_column = track_end_column,
      num_note_columns = num_note_columns,
      num_effect_columns = num_effect_columns
    })

    -- Store the data for this track
    selection_data[track_idx] = {}

    -- Iterate over the selected rows and columns to capture data
    for row = start_row, end_row do
      selection_data[track_idx][row] = {}
      for col_idx = track_start_column, track_end_column do
        if col_idx <= num_note_columns then
          -- Capture note column data
          local note_column = pattern_track:line(row).note_columns[col_idx]
          selection_data[track_idx][row][col_idx] = {
            note = note_column.note_value,
            instrument = note_column.instrument_value,
            volume = note_column.volume_value,
            panning = note_column.panning_value,
            delay = note_column.delay_value
          }
        elseif col_idx > num_note_columns and col_idx <= total_columns then
          -- Capture effect column data
          local effect_col_idx = col_idx - num_note_columns
          local effect_column = pattern_track:line(row).effect_columns[effect_col_idx]
          selection_data[track_idx][row][col_idx] = {
            effect_number = effect_column.number_value,
            effect_amount = effect_column.amount_value
          }
        end
      end
    end

    -- Debug: print selection data for current track
    rprint(selection_data[track_idx])
  end

  -- Repeat the selection data throughout the pattern
  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    local pattern_track = song:pattern(song.selected_pattern_index):track(track_idx)
    local num_note_columns = track.visible_note_columns
    local num_effect_columns = track.visible_effect_columns
    local total_columns = num_note_columns + num_effect_columns

    -- Determine start and end columns for the current track
    local track_start_column = track_idx == start_track and selection.start_column or 1
    local track_end_column = track_idx == end_track and selection.end_column or total_columns

    for i = 0, math.floor((num_lines - end_row - 1) / selection_length) do
      for row = start_row, end_row do
        for col_idx = track_start_column, track_end_column do
          local target_row = end_row + (i * selection_length) + (row - start_row) + 1
          if target_row > num_lines then break end

          if col_idx <= num_note_columns then
            -- Copy the note data to the new position
            local note_data = selection_data[track_idx][row][col_idx]
            local target_note_column = pattern_track:line(target_row).note_columns[col_idx]

            target_note_column.note_value = note_data.note
            target_note_column.instrument_value = note_data.instrument
            target_note_column.volume_value = note_data.volume
            target_note_column.panning_value = note_data.panning
            target_note_column.delay_value = note_data.delay

          elseif col_idx > num_note_columns and col_idx <= total_columns then
            -- Copy the effect data to the new position
            local effect_data = selection_data[track_idx][row][col_idx]
            local effect_col_idx = col_idx - num_note_columns
            local target_effect_column = pattern_track:line(target_row).effect_columns[effect_col_idx]

            target_effect_column.number_value = effect_data.effect_number
            target_effect_column.amount_value = effect_data.effect_amount
          end

          -- Debug: print copied data
          print(string.format("Copied data from track %d, row %d, col %d to row %d", track_idx, row, col_idx, target_row))
        end
      end
    end
  end

  renoise.app():show_status("Flood fill with selection completed.")
end

-- Add a keybinding to trigger the function
renoise.tool():add_keybinding {
  name = "Pattern Editor:Paketti:Flood Fill with Selection",
  invoke = floodfill_with_selection
}


-----



-- Define the function to rotate track content
function rotate_track_content_to_selection_start_first()
  -- Get the current song
  local song = renoise.song()
  
  -- Check if there's a selection in the pattern
  local selection = song.selection_in_pattern
  local start_line
  local num_lines = song.selected_pattern.number_of_lines

  if selection then
    start_line = selection.start_line
  else
    start_line = song.selected_line_index
  end

  -- Determine the range of tracks to rotate
  local start_track = selection and selection.start_track or song.selected_track_index
  local end_track = selection and selection.end_track or song.selected_track_index

  -- Store the data to be rotated (Part 1 and Part 2)
  local part1_data = {}
  local part2_data = {}

  -- Iterate over the selected tracks
  for track_idx = start_track, end_track do
    local track = song:track(track_idx)
    local pattern_track = song:pattern(song.selected_pattern_index):track(track_idx)
    local num_note_columns = track.visible_note_columns
    local num_effect_columns = track.visible_effect_columns
    local total_columns = num_note_columns + num_effect_columns

    -- Determine start and end columns for the current track
    local track_start_column = (selection and track_idx == start_track) and selection.start_column or 1
    local track_end_column = (selection and track_idx == end_track) and selection.end_column or total_columns

    -- Store the data for this track
    part1_data[track_idx] = {}
    part2_data[track_idx] = {}

    -- Capture data from `start_line` to the end of the pattern (Part 1)
    for line = start_line, num_lines do
      part1_data[track_idx][line] = {}
      for col_idx = track_start_column, track_end_column do
        if col_idx <= num_note_columns then
          local note_column = pattern_track:line(line).note_columns[col_idx]
          part1_data[track_idx][line][col_idx] = {
            note = note_column.note_value,
            instrument = note_column.instrument_value,
            volume = note_column.volume_value,
            panning = note_column.panning_value,
            delay = note_column.delay_value
          }
        elseif col_idx > num_note_columns and col_idx <= total_columns then
          local effect_col_idx = col_idx - num_note_columns
          local effect_column = pattern_track:line(line).effect_columns[effect_col_idx]
          part1_data[track_idx][line][col_idx] = {
            effect_number = effect_column.number_value,
            effect_amount = effect_column.amount_value
          }
        end
      end
    end

    -- Capture data from the start of the pattern to `start_line - 1` (Part 2)
    for line = 1, start_line - 1 do
      part2_data[track_idx][line] = {}
      for col_idx = track_start_column, track_end_column do
        if col_idx <= num_note_columns then
          local note_column = pattern_track:line(line).note_columns[col_idx]
          part2_data[track_idx][line][col_idx] = {
            note = note_column.note_value,
            instrument = note_column.instrument_value,
            volume = note_column.volume_value,
            panning = note_column.panning_value,
            delay = note_column.delay_value
          }
        elseif col_idx > num_note_columns and col_idx <= total_columns then
          local effect_col_idx = col_idx - num_note_columns
          local effect_column = pattern_track:line(line).effect_columns[effect_col_idx]
          part2_data[track_idx][line][col_idx] = {
            effect_number = effect_column.number_value,
            effect_amount = effect_column.amount_value
          }
        end
      end
    end
  end

  -- Apply the rotation
  for track_idx = start_track, end_track do
    local pattern_track = song:pattern(song.selected_pattern_index):track(track_idx)
    local num_note_columns = song:track(track_idx).visible_note_columns
    local num_effect_columns = song:track(track_idx).visible_effect_columns
    local total_columns = num_note_columns + num_effect_columns
    local track_start_column = (selection and track_idx == start_track) and selection.start_column or 1
    local track_end_column = (selection and track_idx == end_track) and selection.end_column or total_columns

    -- Part 1: Move data to the top
    local line_counter = 1
    for line = start_line, num_lines do
      for col_idx = track_start_column, track_end_column do
        if col_idx <= num_note_columns then
          local note_data = part1_data[track_idx][line][col_idx]
          local target_note_column = pattern_track:line(line_counter).note_columns[col_idx]

          target_note_column.note_value = note_data.note
          target_note_column.instrument_value = note_data.instrument
          target_note_column.volume_value = note_data.volume
          target_note_column.panning_value = note_data.panning
          target_note_column.delay_value = note_data.delay
        elseif col_idx > num_note_columns and col_idx <= total_columns then
          local effect_data = part1_data[track_idx][line][col_idx]
          local effect_col_idx = col_idx - num_note_columns
          local target_effect_column = pattern_track:line(line_counter).effect_columns[effect_col_idx]

          target_effect_column.number_value = effect_data.effect_number
          target_effect_column.amount_value = effect_data.effect_amount
        end
      end
      line_counter = line_counter + 1
    end

    -- Part 2: Move data after Part 1
    for line = 1, start_line - 1 do
      for col_idx = track_start_column, track_end_column do
        if col_idx <= num_note_columns then
          local note_data = part2_data[track_idx][line][col_idx]
          local target_note_column = pattern_track:line(line_counter).note_columns[col_idx]

          target_note_column.note_value = note_data.note
          target_note_column.instrument_value = note_data.instrument
          target_note_column.volume_value = note_data.volume
          target_note_column.panning_value = note_data.panning
          target_note_column.delay_value = note_data.delay
        elseif col_idx > num_note_columns and col_idx <= total_columns then
          local effect_data = part2_data[track_idx][line][col_idx]
          local effect_col_idx = col_idx - num_note_columns
          local target_effect_column = pattern_track:line(line_counter).effect_columns[effect_col_idx]

          target_effect_column.number_value = effect_data.effect_number
          target_effect_column.amount_value = effect_data.effect_amount
        end
      end
      line_counter = line_counter + 1
    end
  end

  renoise.app():show_status(string.format("Set Line %d as First Line", start_line))
end

-- Add a keybinding to trigger the function
renoise.tool():add_keybinding {
  name = "Pattern Editor:Paketti:Rotate Track Content to SelectionStart First",
  invoke = rotate_track_content_to_selection_start_first
}

-----
local vb = renoise.ViewBuilder()
local rs = math.random
local strategies
local dialog -- Holds the reference to the dialog
local message
local img_path = "External/catinhat.png"
local file_path = "External/obliquestrategies.txt"

local function load_strategies()
  local file, err = io.open(file_path, "r")
  if not file then
    renoise.app():show_message("Failed to open file: "..err)
    return
  end
  strategies = {}
  for line in file:lines() do
    table.insert(strategies, line)
  end
  file:close()
end

local function get_random_message()
  if #strategies > 0 then
    return strategies[rs(#strategies)]
  else
    return "No strategies found."
  end
end

function create_oblique_strategies_dialog()
  -- Check if dialog is already visible
  if dialog and dialog.visible then
    dialog:close()
    dialog = nil
    return
  end

  load_strategies()
  message = get_random_message()
  
  local message_text = vb:text{width = 300, font="big", style="strong", align = "center", text = message}

  local dialog_content = vb:column{
    margin = 20,
    spacing = 10,
    vb:horizontal_aligner{
      mode = "center",
      vb:text{style="strong", align = "center", text="Click Image to Roll Again"}
    },
    vb:horizontal_aligner{
      mode = "center",
      vb:bitmap{
        mode="body_color",
        bitmap=img_path,
        notifier=function()
          message = get_random_message()
          message_text.text = message
        end
      }
    },
    vb:horizontal_aligner{
      mode = "center",
      message_text
    },
    vb:horizontal_aligner{
      mode = "center",
      vb:space{
        width = 320,
        height = 2,
      }
    },
    vb:horizontal_aligner{
      mode = "center",
      spacing = 10,
      vb:button{text = "OK", released = function()
        renoise.app():show_status("Oblique Strategies: " .. message)
        dialog:close()
      end},
      vb:button{text = "Cancel", released = function()
        dialog:close()
      end},
      vb:button{text = "Next", released = function()
        message = get_random_message()
        message_text.text = message
      end}
    }
  }
  
  dialog = renoise.app():show_custom_dialog("Oblique Strategies", dialog_content)
end

function shuffle_oblique_strategies()
  load_strategies()
  message = get_random_message()
  renoise.app():show_status("Oblique Strategies: " .. message)
end

-- Add keybinding for opening/closing the dialog
renoise.tool():add_keybinding{name="Global:Paketti:Open Oblique Strategies Dialog...",invoke=function() 
  create_oblique_strategies_dialog() 
end}

-- Add keybinding for shuffling cards without opening the dialog
renoise.tool():add_keybinding{name="Global:Paketti:Shuffle Oblique Strategies Cards",invoke=shuffle_oblique_strategies}
-------


local dialog
local vb = renoise.ViewBuilder()
local default_file_path = "External/wordlist.txt" -- Default file path
local selected_file_path = default_file_path -- Initial file path
local use_dash_format = false
local no_date = false
local text_format = 1 -- 1=Off, 2=lowercase, 3=Capital, 4=UPPERCASE, 5=eLiTe
local before_name_text = ""
local prefs_path = renoise.tool().bundle_path .. "preferencesSave.xml"

-- Function to apply the selected text format
local function apply_text_format(text)
  if text_format == 3 then
    return text:gsub("(%a)(%w*)", function(a, b) return string.upper(a) .. string.lower(b) end)
  elseif text_format == 4 then
    return string.upper(text)
  elseif text_format == 5 then
    return text:gsub("%a", function(c)
      if c:lower():match("[aeiouåäöéèêëòóôöüûú]") then
        return c:lower()
      else
        return c:upper()
      end
    end)
  elseif text_format == 2 then
    return text:lower() -- Include all modified vowels
  else
    return text -- "Off" leaves the text unchanged
  end
end

-- Function to generate a random string
local function generate_random_string(length)
  local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  local result = {}
  for i = 1, length do
    local index = math.random(1, #charset)
    result[i] = charset:sub(index, index)
  end
  return table.concat(result)
end

-- Function to randomize from a textfile
local function randomize_from_textfile(file_path, count)
  local words = {}
  for line in io.lines(file_path) do
    for word in line:gmatch("%w+") do
      table.insert(words, word)
    end
  end
  local selected_words = {}
  for i = 1, count do
    table.insert(selected_words, words[math.random(#words)])
  end
  return table.concat(selected_words, " ")
end

-- Function to format the current date based on the selected format
local function get_formatted_date()
  local date = os.date("*t")
  if no_date then
    return ""
  elseif use_dash_format then
    return string.format("%04d-%02d-%02d", date.year, date.month, date.day)
  else
    return string.format("%04d_%02d_%02d", date.year, date.month, date.day)
  end
end

-- Function to split a string by a given separator
local function split_string(input, separator)
  if separator == nil then
    separator = "%s"
  end
  local t = {}
  for str in string.gmatch(input, "([^" .. separator .. "]+)") do
    table.insert(t, str)
  end
  return t
end

-- Function to save the song with the generated filename
local function save_song_with_title(title)
  local date = get_formatted_date()
  local separator = use_dash_format and "-" or "_"
  local filename = (no_date and "" or date .. separator)
  if before_name_text ~= "" then
    filename = filename .. apply_text_format(before_name_text) .. separator
  end
  filename = filename .. apply_text_format(title) .. ".xrns"
  local folder = renoise.app():prompt_for_path("Save Current Song (" .. filename .. ") to Folder")
  if folder and folder ~= "" then
    local full_path = folder .. "/" .. filename
    renoise.app():save_song_as(full_path)
    renoise.app():show_status("Song Saved as: " .. full_path)
  else
    renoise.app():show_status("Did not Save " .. filename .. ", saving operation canceled.")
  end
end

-- Function to update the full filename display
local function update_filename_display()
  local date = get_formatted_date()
  local title = vb.views.title_field.text
  local separator = use_dash_format and "-" or "_"
  local full_filename = (no_date and "" or date .. separator)
  if before_name_text ~= "" then
    full_filename = full_filename .. apply_text_format(before_name_text) .. separator
  end
  full_filename = full_filename .. apply_text_format(title) .. ".xrns"
  vb.views.filename_display.text = full_filename
end

-- Function to load preferences from XML
local function load_preferences()
  local prefs = renoise.Document.create("preferences") { textfile_path = default_file_path }
  prefs:load_from(prefs_path)
  return prefs.textfile_path.value
end

-- Function to save preferences to XML
local function save_preferences(textfile_path)
  local prefs = renoise.Document.create("preferences") { textfile_path = textfile_path }
  prefs:save_as(prefs_path)
end

-- Function to show the date & title dialog
function PakettiTrackDaterTitlerDialog()
  vb = renoise.ViewBuilder()
  local date = get_formatted_date()
  local default_title = ""

  local function close_dialog()
    if dialog and dialog.visible then
      dialog:close()
    end
  end

  local function handle_save()
    local title = vb.views.title_field.text
    save_song_with_title(title)
  end

  local function random_string()
    local random_string = generate_random_string(8)
    vb.views.title_field.text = random_string
    update_filename_display()
  end

  local function browse_textfile()
    selected_file_path = renoise.app():prompt_for_filename_to_read({"*.txt"}, "Browse Textfile")
    if selected_file_path and selected_file_path ~= "" then
      save_preferences(selected_file_path) -- Save the selected file path
      vb.views.textfile_display.text = "Path: " .. selected_file_path -- Display the file path
    else
      selected_file_path = default_file_path
      vb.views.textfile_display.text = "Path: " .. default_file_path -- Revert to default
    end
  end

  local function random_words()
    -- Check if file exists before using it
    local file = io.open(selected_file_path, "r")
    if not file then
      renoise.app():show_status("Error: No valid textfile selected or file does not exist.")
      browse_textfile()
      return
    end
    file:close()
    local count = vb.views.word_count.value
    local random_title = randomize_from_textfile(selected_file_path, count)
    vb.views.title_field.text = random_title
    update_filename_display()
  end

  local function switch_date_format(value)
    use_dash_format = (value == 2)
    update_filename_display()
  end

  local function handle_no_date(value)
    no_date = value
    update_filename_display()
  end

  local function handle_before_name_change(new_value)
    before_name_text = new_value
    update_filename_display()
  end

  local function handle_text_format(value)
    text_format = value
    -- Update the filename display based on the new format
    update_filename_display()
  end

  -- Function to shift words to the left
  local function shift_words_left()
    local words = split_string(vb.views.title_field.text, " ")
    if #words > 1 then
      table.insert(words, table.remove(words, 1)) -- Move first word to the end
      vb.views.title_field.text = table.concat(words, " ")
      update_filename_display()
    end
  end

  -- Function to shift words to the right
  local function shift_words_right()
    local words = split_string(vb.views.title_field.text, " ")
    if #words > 1 then
      table.insert(words, 1, table.remove(words)) -- Move last word to the beginning
      vb.views.title_field.text = table.concat(words, " ")
      update_filename_display()
    end
  end

  -- Load preferences
  selected_file_path = load_preferences()

  local dialog_content = vb:column{
    margin = 10,
    width = 580, -- Set the dialog width
    vb:row{
      vb:text{text = "Before Name:", font = "mono"},
      vb:textfield{
        id = "before_name_field",
        text = before_name_text,
        width = 200, -- Double the previous width
        notifier = function(text)
          before_name_text = text
          update_filename_display() -- Always refresh the filename display
        end
      }
    },
    vb:row{
      vb:text{text = "Actual Name:", font = "mono"},
      vb:textfield{
        id = "title_field",
        text = default_title,
        width = 400, -- Double the previous width
        edit_mode = true,
        notifier = function(text)
          update_filename_display() -- Always refresh the filename display
        end
      },
      vb:text{text = ".xrns"}
    },
    vb:row{
      vb:text{
        id = "filename_display",
        text = "",
        font = "bold",
        width = 800 -- Double the previous width
      }
    },
    vb:row{
      vb:button{text = "Save As", width = 135, notifier = handle_save},
      vb:button{text = "Cancel", width = 135, notifier = close_dialog}
    },
    vb:row{
      vb:button{text = "Random String", width = 135, notifier = random_string},
      vb:button{text = "Browse Textfile", width = 135, notifier = browse_textfile}
    },
    vb:row{
      vb:text{id = "textfile_display", text = "Path: " .. selected_file_path}
    },
    vb:row{
      vb:button{text = "Random Words", width = 135, notifier = random_words},
      vb:button{text = "Shift Left", width = 135, notifier = shift_words_left},
      vb:button{text = "Shift Right", width = 135, notifier = shift_words_right}
    },
    vb:row{
      vb:text{text = "Wordcount:"},
      vb:valuebox{
        id = "word_count",
        min = 1,
        max = 16,
        value = 2,
        notifier = random_words -- Update the title if value changes
      }
    },
    vb:row{
      vb:checkbox{
        id = "no_date_checkbox",
        value = no_date,
        notifier = handle_no_date
      },
      vb:text{text = "No Date"}
    },
    vb:row{
      vb:text{text = "Date Format:"},
      vb:switch{
        id = "date_format_switch",
        items = {"_", "-"},
        width = 50,
        value = 1,
        notifier = switch_date_format
      }
    },
    vb:row{
      vb:text{text = "Text Format:"},
      vb:switch{
        id = "text_format_switch",
        items = {"Off", "lowercase", "Capital", "UPPERCASE", "eLiTe"},
        width = 350,
        value = text_format,
        notifier = handle_text_format -- Handle text format change
      }
    }
  }

  -- Initialize filename display
  update_filename_display()

  dialog = renoise.app():show_custom_dialog("Paketti Track Dater & Titler", dialog_content)
end

-- Adding the menu entries
renoise.tool():add_menu_entry{name = "Main Menu:File:Paketti..:Paketti Track Dater & Titler...", invoke = PakettiTrackDaterTitlerDialog}
renoise.tool():add_keybinding{name = "Global:Paketti:Paketti Track Dater & Titler", invoke = PakettiTrackDaterTitlerDialog}

renoise.tool():add_menu_entry{name = "Main Menu:File:Save (Paketti Track Dater & Titler)...", invoke = PakettiTrackDaterTitlerDialog}

------
renoise.tool():add_keybinding{
  name="Global:Paketti:Set Selected Sample Volume to -INF dB",
  invoke=function() 
    local song = renoise.song()
    local instrument = song.selected_instrument
    local sample = song.selected_sample

    if instrument and sample and sample.sample_buffer then
      sample.volume = 0
      renoise.app():show_status("Sample volume set to -INF dB.")
    else
      renoise.app():show_status("Cannot set volume: No valid sample selected.")
    end
  end
}


function sampleVolumeSwitcharoo()
local ing=renoise.song().selected_instrument
local s=renoise.song().selected_sample

s.volume=1
for i=1,#ing.samples do
ing.samples[i].volume = 0
end
s.volume=1
renoise.app():show_status("Current Sample " .. renoise.song().selected_sample_index .. ":" .. renoise.song().selected_sample.name .. " set to 0.0dB, all other Samples in Selected Instrument set to -INF dB.")
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample Volume 0.0dB, others -INF",invoke=function() sampleVolumeSwitcharoo() end}

------



function PakettiRecordFollowMetronomePrecountPatternEditor(bars)
renoise.app().window.active_middle_frame=1
renoise.song().transport.edit_mode=true
renoise.song().transport.follow_player=true
renoise.song().transport.playback_pos.line=1
renoise.song().transport.metronome_precount_enabled=true
renoise.song().transport.metronome_precount_bars=bars
renoise.song().transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
--renoise.song().transport.playing=true

end

renoise.tool():add_keybinding{name="Global:Paketti:Record+Follow+Metronome Precount 1 Bar",invoke=function()
PakettiRecordFollowMetronomePrecountPatternEditor(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Record+Follow+Metronome Precount 2 Bar",invoke=function()
PakettiRecordFollowMetronomePrecountPatternEditor(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Record+Follow+Metronome Precount 3 Bar",invoke=function()
PakettiRecordFollowMetronomePrecountPatternEditor(3) end}
renoise.tool():add_keybinding{name="Global:Paketti:Record+Follow+Metronome Precount 4 Bar",invoke=function()
PakettiRecordFollowMetronomePrecountPatternEditor(4) end}
------







-- Main function to adjust sample velocity range
function pakettiSampleVelocityRangeChoke(sample_index)
  local song = renoise.song()
  local ing = song.selected_instrument

  -- Edge case: no instrument or no samples
  if not ing or #ing.samples == 0 then
    renoise.app():show_status("No instrument or samples available.")
    return
  end

  -- Set all samples' velocity ranges to {0, 0}, except the selected one
  for i = 1, #ing.samples do
    if i ~= sample_index then
      local mapping = ing.sample_mappings[1][i]
      if mapping then
        mapping.velocity_range = {0, 0} -- Disable all other samples
      end
    end
  end

  -- Set the selected sample's velocity range to {0, 127}
  local selected_mapping = ing.sample_mappings[1][sample_index]
  if selected_mapping then
    selected_mapping.velocity_range = {0, 127} -- Enable selected sample
  end
  
  renoise.song().selected_sample_index=sample_index
renoise.app():show_status("Sample " .. sample_index .. ": " .. renoise.song().selected_sample.name .. " selected.")
  -- Update status
  --renoise.app():show_status("Sample " .. sample_index .. " set to velocity range 00-7F, all other samples set to 00-00.")
end

-- MIDI Mapping: Adjust velocity ranges based on MIDI knob
function midi_sample_velocity_switcharoo(value)
  local song = renoise.song()
  local ing = song.selected_instrument

  -- Edge case: no instrument or no samples
  if not ing or #ing.samples == 0 then
    renoise.app():show_status("No instrument or samples available.")
    return
  end

  -- Map the MIDI knob value (0-127) to the sample index
  local selected_sample_index = math.floor((value / 127) * (#ing.samples - 1)) + 1


  -- Set velocity ranges for all samples based on the selected sample
  pakettiSampleVelocityRangeChoke(selected_sample_index)
end

-- "One-up" keybinding: Decreases selected_sample_index by 1
function sample_one_up()
  local song = renoise.song()
  local ing = song.selected_instrument
  local current_index = song.selected_sample_index

  -- Ensure boundary conditions
  if current_index > 1 then
    song.selected_sample_index = current_index - 1
    pakettiSampleVelocityRangeChoke(song.selected_sample_index)
  end
  end

-- "One-down" keybinding: Increases selected_sample_index by 1
function sample_one_down()
  local song = renoise.song()
  local ing = song.selected_instrument
  local current_index = song.selected_sample_index

  -- Ensure boundary conditions
  if current_index < #ing.samples then
    song.selected_sample_index = current_index + 1
    pakettiSampleVelocityRangeChoke(song.selected_sample_index)
  end
  end

-- "Random" keybinding: Selects a random sample and mutes others
function sample_random()
  local song = renoise.song()
  local ing = song.selected_instrument

  -- Edge case: no instrument or no samples
  if not ing or #ing.samples == 0 then
    renoise.app():show_status("No instrument or samples available.")
    return
  end

  -- Pick a random sample index
  local random_index = math.random(1, #ing.samples)
  song.selected_sample_index = random_index

  -- Set velocity ranges accordingly
  pakettiSampleVelocityRangeChoke(random_index)
end

-- Add MIDI mapping for knob control in one line
renoise.tool():add_midi_mapping{name="Paketti:Midi Set Selected Sample Velocity Range", invoke=function(midi_message) midi_sample_velocity_switcharoo(midi_message.int_value) end}

-- Add keybindings for moving up, down, and random sample selection, all in one line
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample (+1) Velocity Range 7F others 00", invoke=function() sample_one_down() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample (-1) Velocity Range 7F others 00", invoke=function() sample_one_up() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample (Random) Velocity Range 7F others 00", invoke=function() sample_random() end}

-----
-- Resize all non-empty patterns to 96 lines
function resize_all_non_empty_patterns_to_96()
  local song = renoise.song()
  for i = 1, #song.patterns do
    if not song.patterns[i].is_empty then
      song.patterns[i].number_of_lines = 96
    end
  end
  renoise.app():show_status("Resized all non-empty patterns to 96 lines.")
end

-- Resize all non-empty patterns to the current pattern's length
function resize_all_non_empty_patterns_to_current_pattern_length()
  local song = renoise.song()
  local current_pattern_length = song.patterns[song.selected_pattern_index].number_of_lines
  for i = 1, #song.patterns do
    if not song.patterns[i].is_empty then
      song.patterns[i].number_of_lines = current_pattern_length
    end
  end
  renoise.app():show_status("Resized all non-empty patterns to the current pattern's length (" .. song.patterns[song.selected_pattern_index].number_of_lines .. ")")
end

-- Add the menu entries to the Global:Paketti section
renoise.tool():add_keybinding{name="Global:Paketti:Resize all non-empty Patterns to 96",invoke = resize_all_non_empty_patterns_to_96}
renoise.tool():add_keybinding{name="Global:Paketti:Resize all non-empty Patterns to current Pattern length",invoke = resize_all_non_empty_patterns_to_current_pattern_length}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Resize all non-empty Patterns to 96",invoke = resize_all_non_empty_patterns_to_96}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Resize all non-empty Patterns to current Pattern length",invoke = resize_all_non_empty_patterns_to_current_pattern_length}
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Resize all non-empty Patterns to 96",invoke = resize_all_non_empty_patterns_to_96}
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Resize all non-empty Patterns to current Pattern length",invoke = resize_all_non_empty_patterns_to_current_pattern_length}

-------
-- Function to copy sample settings from one sample to another
local function DuplicateSampleRangeMuteOriginalCopySampleSettings(from_sample, to_sample)
  to_sample.volume = 1.0 -- Set volume to 1.0 (0 dB) for the duplicated sample
  to_sample.panning = from_sample.panning
  to_sample.transpose = from_sample.transpose
  to_sample.fine_tune = from_sample.fine_tune
  to_sample.beat_sync_enabled = from_sample.beat_sync_enabled
  to_sample.beat_sync_lines = from_sample.beat_sync_lines
  to_sample.beat_sync_mode = from_sample.beat_sync_mode
  to_sample.oneshot = from_sample.oneshot
  to_sample.loop_release = from_sample.loop_release
  to_sample.loop_mode = from_sample.loop_mode
  to_sample.mute_group = from_sample.mute_group
  to_sample.new_note_action = from_sample.new_note_action
  to_sample.autoseek = from_sample.autoseek
  to_sample.autofade = from_sample.autofade
  to_sample.oversample_enabled = from_sample.oversample_enabled
  to_sample.interpolation_mode = from_sample.interpolation_mode
  to_sample.name = from_sample.name
end

-- Function to duplicate the selected sample range and mute the original sample
function duplicate_sample_range_and_mute_original()
  local song = renoise.song()
  local selected_sample = song.selected_sample
  if not selected_sample or not selected_sample.sample_buffer.has_sample_data then
    renoise.app():show_status("No valid sample selected")
    return
  end

  -- Get the selection range
  local selection_start, selection_end = selected_sample.sample_buffer.selection_range[1], selected_sample.sample_buffer.selection_range[2]
  if selection_start == selection_end then
    renoise.app():show_status("No selection range is defined")
    return
  end

  -- Set the original sample's volume to -INF dB
  selected_sample.volume = 0.0

  -- Create a new sample in the same instrument
  local new_sample = song.selected_instrument:insert_sample_at(#song.selected_instrument.samples + 1)

  -- Copy the sample settings from the original sample to the new one, with volume set to 1.0
  DuplicateSampleRangeMuteOriginalCopySampleSettings(selected_sample, new_sample)

  -- Copy the selected range to the new sample buffer
  local sample_buffer = selected_sample.sample_buffer
  new_sample.sample_buffer:create_sample_data(
    sample_buffer.sample_rate, 
    sample_buffer.bit_depth, 
    sample_buffer.number_of_channels, 
    selection_end - selection_start + 1
  )
  new_sample.sample_buffer:prepare_sample_data_changes()
  
  -- Copy sample data
  for c = 1, sample_buffer.number_of_channels do
    for f = selection_start, selection_end do
      new_sample.sample_buffer:set_sample_data(c, f - selection_start + 1, sample_buffer:sample_data(c, f))
    end
  end
  new_sample.sample_buffer:finalize_sample_data_changes()

  -- Select the new sample
  song.selected_sample_index = #song.selected_instrument.samples
  renoise.app():show_status("Sample range duplicated and original muted")
end

renoise.tool():add_keybinding{name = "Sample Editor:Paketti:Duplicate Sample Range, Mute Original",invoke = duplicate_sample_range_and_mute_original}
renoise.tool():add_menu_entry{name = "Sample Editor:Paketti..:Duplicate Sample Range, Mute Original",invoke = duplicate_sample_range_and_mute_original}

------
-- Define the function for randomizing pitch and finetune with custom ranges
local function randomize_sample_pitch_and_finetune(random_range_pitch, random_range_finetune)
  local sample=renoise.song().selected_sample

  -- Check if a sample is selected
  if sample then
    -- Randomize the transpose value within the specified limited range
    local transpose_delta=math.random(-random_range_pitch,random_range_pitch)
    local new_transpose=math.max(-6,math.min(6,sample.transpose+transpose_delta))
    sample.transpose=new_transpose
    
    -- Randomize the fine_tune value within the full range if specified
    local fine_tune_delta=math.random(-random_range_finetune,random_range_finetune)
    local new_fine_tune=math.max(-127,math.min(127,sample.fine_tune+fine_tune_delta))
    sample.fine_tune=new_fine_tune
    
    -- Show status in Renoise
    renoise.app():show_status("Randomized Sample " .. sample.name .. " to finetune " .. new_fine_tune .. " and pitch " .. new_transpose)
  else
    renoise.app():show_status("No sample selected.")
  end
end



renoise.tool():add_keybinding {name="Global:Paketti:Randomize Selected Sample Finetune/Transpose +6/-6",invoke=function() randomize_sample_pitch_and_finetune(6,6) end}
renoise.tool():add_menu_entry {name="Sample Editor:Paketti..:Randomize Selected Sample Finetune/Transpose +6/-6",invoke=function() randomize_sample_pitch_and_finetune(6,6) end}
renoise.tool():add_midi_mapping {name="Global:Paketti:Randomize Selected Sample Finetune/Transpose +6/-6",invoke=function() randomize_sample_pitch_and_finetune(6,6) end}
renoise.tool():add_keybinding {name="Global:Paketti:Randomize Selected Sample Transpose +6/-6 Finetune +127/-127",invoke=function() randomize_sample_pitch_and_finetune(6,127) end}
renoise.tool():add_menu_entry {name="Sample Editor:Paketti..:Randomize Selected Sample Transpose +6/-6 Finetune +127/-127",invoke=function() randomize_sample_pitch_and_finetune(6,127) end}
renoise.tool():add_midi_mapping {name="Global:Paketti:Randomize Selected Sample Transpose +6/-6 Finetune +127/-127",invoke=function() randomize_sample_pitch_and_finetune(6,127) end}
----------
function DuplicateMaximizeConvertAndSave(format)
  local song = renoise.song()
  local selected_sample = song.selected_sample
  
  if selected_sample == nil or not selected_sample.sample_buffer.has_sample_data then
    renoise.app():show_error("No sample selected or no sample data available.")
    return
  end
  
  -- Step 1: Create a New Instrument Below the Selected Instrument Index
  local selected_instrument_index = song.selected_instrument_index
  local new_instrument = song:insert_instrument_at(selected_instrument_index + 1)
  
  if new_instrument == nil then
    renoise.app():show_error("Failed to create a new instrument.")
    return
  else
    renoise.app():show_status("New instrument created below the selected instrument.")
  end
  
  -- Set the new instrument's name to match the selected sample's name
  new_instrument.name = selected_sample.name
  
  -- Step 2: Copy the Original Sample to the New Instrument and Set Sample Name
  local new_sample = new_instrument:insert_sample_at(1)
  local original_sample_buffer = selected_sample.sample_buffer
  new_sample.name = selected_sample.name -- Copy the sample name
  
  new_sample.sample_buffer:create_sample_data(
    original_sample_buffer.sample_rate,
    original_sample_buffer.bit_depth,
    original_sample_buffer.number_of_channels,
    original_sample_buffer.number_of_frames
  )
  
  new_sample.sample_buffer:prepare_sample_data_changes()
  
  for c = 1, original_sample_buffer.number_of_channels do
    for i = 1, original_sample_buffer.number_of_frames do
      new_sample.sample_buffer:set_sample_data(c, i, original_sample_buffer:sample_data(c, i))
    end
  end
  
  new_sample.sample_buffer:finalize_sample_data_changes()
  
  if new_sample.sample_buffer.has_sample_data then
    renoise.app():show_status("Sample successfully copied to the new instrument.")
  else
    renoise.app():show_error("Failed to copy the sample to the new instrument.")
    return
  end
  
  -- Step 3: Select the New Instrument
  song.selected_instrument_index = selected_instrument_index + 1
  
  -- Step 4: Maximize the Volume (Normalize)
  local sbuf = new_sample.sample_buffer
  local highest_detected = 0
  
  for frame_idx = 1, sbuf.number_of_frames do
    if sbuf.number_of_channels == 2 then
      highest_detected = math.max(math.abs(sbuf:sample_data(1, frame_idx)), highest_detected)
      highest_detected = math.max(math.abs(sbuf:sample_data(2, frame_idx)), highest_detected)
    else
      highest_detected = math.max(math.abs(sbuf:sample_data(1, frame_idx)), highest_detected)
    end
  end
  
  if highest_detected == 0 then
    renoise.app():show_error("Normalization failed: highest detected peak is 0.")
    return
  end
  
  sbuf:prepare_sample_data_changes()
  
  for frame_idx = 1, sbuf.number_of_frames do
    if sbuf.number_of_channels == 2 then
      local normalized_sdata = sbuf:sample_data(1, frame_idx) / highest_detected
      sbuf:set_sample_data(1, frame_idx, normalized_sdata)
      normalized_sdata = sbuf:sample_data(2, frame_idx) / highest_detected
      sbuf:set_sample_data(2, frame_idx, normalized_sdata)
    else
      local normalized_sdata = sbuf:sample_data(1, frame_idx) / highest_detected
      sbuf:set_sample_data(1, frame_idx, normalized_sdata)
    end
  end
  
  sbuf:finalize_sample_data_changes()
  
  if sbuf.has_sample_data then
    renoise.app():show_status("Sample successfully normalized (maximized volume).")
  else
    renoise.app():show_error("Normalization failed.")
    return
  end
  
  -- Step 5: Convert the Sample to 16-bit
  local original_sample_rate = sbuf.sample_rate
  local original_frame_count = sbuf.number_of_frames
  local original_sample_data = {}
  
  -- Store the original sample data before creating a new 16-bit buffer
  for c = 1, sbuf.number_of_channels do
    original_sample_data[c] = {}
    for i = 1, original_frame_count do
      original_sample_data[c][i] = sbuf:sample_data(c, i)
    end
  end
  
  -- Now, create the new 16-bit buffer
  sbuf:create_sample_data(
    original_sample_rate,
    16, -- Convert to 16-bit
    sbuf.number_of_channels,
    original_frame_count
  )
  
  sbuf:prepare_sample_data_changes()
  
  -- Copy the original data into the new 16-bit buffer
  for c = 1, sbuf.number_of_channels do
    for i = 1, original_frame_count do
      sbuf:set_sample_data(c, i, original_sample_data[c][i])
    end
  end
  
  sbuf:finalize_sample_data_changes()
  
  if sbuf.has_sample_data then
    renoise.app():show_status("Sample successfully converted to 16-bit.")
  else
    renoise.app():show_error("Failed to convert the sample to 16-bit.")
    return
  end
  
  -- Step 6: Save the Sample
  local filename = renoise.app():prompt_for_filename_to_write(format, "Paketti Save Selected Sample in ." .. format .. " Format")
  
  if filename ~= "" then
    sbuf:save_as(filename, format)
    renoise.app():show_status("Saved sample as " .. format .. " in " .. filename)
  else
    renoise.app():show_error("Saving canceled.")
    return
  end
end

-- Keybindings and Menu Entries
renoise.tool():add_menu_entry{
  name = "Sample Editor:Paketti..:Duplicate, Maximize, Convert to 16Bit, and Save as .WAV",
  invoke = function() DuplicateMaximizeConvertAndSave("wav") end
}

renoise.tool():add_menu_entry{
  name = "Sample Editor:Paketti..:Duplicate, Maximize, Convert to 16Bit, and Save as .FLAC",
  invoke = function() DuplicateMaximizeConvertAndSave("flac") end
}

renoise.tool():add_keybinding{
  name = "Sample Editor:Paketti:Duplicate, Maximize, 16bit, and Save as WAV",
  invoke = function() DuplicateMaximizeConvertAndSave("wav") end
}

renoise.tool():add_keybinding{
  name = "Sample Editor:Paketti:Duplicate, Maximize, 16bit, and Save as FLAC",
  invoke = function() DuplicateMaximizeConvertAndSave("flac") end
}
--------
-- Function to double the LPB value
function PakettiLPBDouble()
  local song=renoise.song()
  local current_lpb=song.transport.lpb
  
  if current_lpb >= 128 then
    if current_lpb * 2 > 256 then
      renoise.app():show_status("LPB Cannot be doubled to over 256")
      return
    end
  end
  
  local new_lpb=current_lpb*2
  song.transport.lpb=new_lpb
  renoise.app():show_status("Doubled LPB from "..current_lpb.." to "..new_lpb)
--  renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Function to halve the LPB value
function PakettiLPBHalve()
  local song=renoise.song()
  local current_lpb=song.transport.lpb
  
  if current_lpb == 1 then
    renoise.app():show_status("LPB cannot be smaller than 1")
    return
  end
  
  if current_lpb % 2 ~= 0 then
    renoise.app():show_status("LPB is odd number, cannot halve LPB.")
    return
  end
  
  local new_lpb=math.floor(current_lpb/2)
  song.transport.lpb=new_lpb
  renoise.app():show_status("Halved LPB from "..current_lpb.." to "..new_lpb)
--  renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Assign the functions to keybindings
renoise.tool():add_keybinding{name="Global:Paketti:Double LPB", invoke=function() PakettiLPBDouble() end}
renoise.tool():add_keybinding{name="Global:Paketti:Halve LPB", invoke=function() PakettiLPBHalve() end}
-------
-- Function to detect note spacing
local function analyze_note_spacing()
  local song = renoise.song()
  local selection = song.selection_in_pattern
  if not selection then
    renoise.app():show_status("No selection in pattern")
    return nil
  end

  local start_line = selection.start_line
  local end_line = selection.end_line
  local track_index = selection.start_track

  local previous_note_line = nil
  local note_spacing_counts = { [1] = 0, [2] = 0 }

  print("Analyzing note spacing in track:", track_index, "-", song:track(track_index).name)

  for line_index = start_line, end_line do
    local line = song:pattern(song.selected_pattern_index):track(track_index):line(line_index)
    local note_column = line:note_column(1)
    
    if not note_column.is_empty then
      if previous_note_line then
        local spacing = line_index - previous_note_line
        print("Note found at line:", line_index, "with spacing:", spacing, "Note:", note_column.note_string)
        if spacing == 1 or spacing == 2 then
          note_spacing_counts[spacing] = note_spacing_counts[spacing] + 1
        end
      end
      previous_note_line = line_index
    end
  end

  -- Determine dominant spacing
  if note_spacing_counts[2] > note_spacing_counts[1] then
    print("Detected note spacing: every 2nd row")
    return 2  -- Notes every 2nd row
  elseif note_spacing_counts[1] > 0 then
    print("Detected note spacing: every row")
    return 1  -- Notes every row
  else
    renoise.app():show_status("Could not determine note spacing")
    return nil
  end
end


-- Function to modify pattern for "notes every row"
local function modify_pattern_triplets()
  local song = renoise.song()
  local selection = song.selection_in_pattern
  if not selection then
    renoise.app():show_status("No selection in pattern")
    return
  end

  local start_line = selection.start_line
  local end_line = selection.end_line
  local track_index = selection.start_track
  local delay_values = { "55", "AA" }  -- 66 and AA as strings
  
  local note_counter = 0
  local triplet_phase = 1

  print("Modifying pattern for notes every row in track:", track_index, "-", song:track(track_index).name)

  for line_index = start_line, end_line do
    local line = song:pattern(song.selected_pattern_index):track(track_index):line(line_index)
    local note_column = line:note_column(1)
    
    if not note_column.is_empty then
      note_counter = note_counter + 1

      if triplet_phase == 1 then
        triplet_phase = 2
        print("Line", line_index, "- No delay (start of triplet) - Note:", note_column.note_string, "Instrument:", note_column.instrument_value)

      elseif triplet_phase == 2 then
        note_column.delay_string = delay_values[1]
        triplet_phase = 3
        print("Line", line_index, "- Applied delay 66 - Note:", note_column.note_string, "Instrument:", note_column.instrument_value)

      elseif triplet_phase == 3 then
        note_column.delay_string = delay_values[2]
        triplet_phase = 1
        -- Insert an empty line after applying delay AA
        song:pattern(song.selected_pattern_index):track(track_index):line(line_index + 1):clear()
        print("Line", line_index, "- Applied delay AA and added an empty line after - Note:", note_column.note_string, "Instrument:", note_column.instrument_value)
      end
    end
  end

  renoise.app():show_status("Triplet pattern applied to every row")
end


-- Function to safely access renoise.song() only when it's valid
local function get_song()
    if renoise.song() then
        return renoise.song()
    else
        error("Renoise song is not available.")
    end
end

local function print_pattern_state(pattern_track, total_lines)
    print("Current pattern state:")
    for line_index = 1, total_lines do
        local line = pattern_track:line(line_index)
        local note_column = line:note_column(1)
        if not note_column.is_empty then
            print(string.format("Line %02d: Note: '%s', Instrument: '%02X', Delay: '%02X'",
                line_index,
                note_column.note_string,
                note_column.instrument_value,
                note_column.delay_value))
        end
    end
end

local function apply_triplet_pattern_with_shifting()
    local song = get_song()
    local pattern_track = song.selected_pattern:track(song.selected_track_index)
    local total_lines = #pattern_track.lines
    local delay_values = {0x00, 0xAA, 0x55}  -- The delay sequence 00-AA-66
    local move_down_accumulated = 0

    -- Step 1: Detect and store positions of all notes
    local note_positions = {}
    for line_index = 1, total_lines do
        local line = pattern_track:line(line_index)
        local note_column = line:note_column(1)

        if not note_column.is_empty then
            table.insert(note_positions, {
                line_index = line_index,
                note = note_column.note_string,
                instrument = note_column.instrument_string
            })
            print(string.format("Detected note '%s' at line: %d", note_column.note_string, line_index))
        end
    end

    -- Step 2: Apply triplet pattern with correct spacing and downward shifting
    for i, data in ipairs(note_positions) do
        local original_pos = data.line_index + move_down_accumulated
        local note_string = data.note
        local instrument_string = data.instrument
        local delay_value = delay_values[(i - 1) % 3 + 1]

        -- Calculate the target position based on the delay value and pattern
        local move_down = 0
        if delay_value == 0x55 then
            move_down = 1  -- Move the note down by 2 rows if the delay is 66
        elseif delay_value == 0xAA then
            move_down = 0  -- Move the note down by 1 row if the delay is AA
        elseif delay_value == 0x00 and i ~= 1 then
            move_down = 1  -- No delay; space to the next logical position
        end

        local target_position = original_pos + move_down

        if target_position > total_lines then
            print(string.format("Skipping move for note '%s' at line %d because it exceeds the pattern length.", note_string, target_position))
            break
        end

        -- Shift all subsequent lines down by `move_down` positions
        if move_down > 0 then
            for j = total_lines, target_position, -1 do
                pattern_track:line(j):copy_from(pattern_track:line(j - move_down))
                pattern_track:line(j - move_down):clear()
            end
            move_down_accumulated = move_down_accumulated + move_down
        end

        -- Set the note, instrument, and delay at the target position
        local target_line = pattern_track:line(target_position)
        target_line:note_column(1).note_string = note_string
        target_line:note_column(1).instrument_string = instrument_string
        target_line:note_column(1).delay_value = delay_value

        print(string.format("Moved note '%s' from line %d to line %d with delay %02X and instrument '%s'",
                            note_string, original_pos, target_position, delay_value, instrument_string))
    end

    renoise.app():show_status("Incremental triplet pattern applied with downward shifting successfully.")
end

-- Main function to detect note spacing and apply the appropriate triplet pattern logic
local function detect_and_apply_triplet_pattern()
    local song = get_song()
    song.selected_track.delay_column_visible = true

    local note_spacing = analyze_note_spacing()
    if note_spacing == 1 then
        modify_pattern_triplets()
    elseif note_spacing == 2 then
        apply_triplet_pattern_with_shifting()
    else
        renoise.app():show_status("Unsupported note spacing or could not detect note spacing")
    end
end

renoise.tool():add_menu_entry {name = "Main Menu:Tools:Expand to Triplets (Note every row, note every 2nd row)",invoke = function() pcall(detect_and_apply_triplet_pattern)end}
----------


renoise.tool():add_keybinding{name="Global:Paketti:Jump to Sends",invoke=function()

if renoise.song().send_track_count == 0 then
renoise.app():show_status("There are no Sends to jump to.")
else
renoise.song().selected_track_index = renoise.song().sequencer_track_count + 2
end
end}


















---------






















-- Function to wipe a specific note column
function wipeNoteColumn(column_number)
  local song = renoise.song()
  song.patterns[song.selected_pattern_index].tracks[song.selected_track_index].lines[song.selected_line_index].note_columns[column_number].note_string = "OFF"
  song.patterns[song.selected_pattern_index].tracks[song.selected_track_index].lines[song.selected_line_index].note_columns[column_number].instrument_string = ".."
end

function chordsplus(number1, number2, number3, number4, number5, number6)

  -- Process number1 using JalexAdd
  JalexAdd(number1)

  -- Process number2
  if number2 == nil then
    -- If number2 is nil, wipe columns 3, 4, 5, 6, and 7
    wipeNoteColumn(3)
    wipeNoteColumn(4)
    wipeNoteColumn(5)
    wipeNoteColumn(6)
    wipeNoteColumn(7)
    renoise.song().selected_note_column_index = 1
    return
  else
    -- If number2 is not nil, process it using JalexAdd
    JalexAdd(number2)
  end

  -- Process number3
  if number3 == nil then
    -- If number3 is nil, wipe columns 4, 5, 6, and 7
    wipeNoteColumn(4)
    wipeNoteColumn(5)
    wipeNoteColumn(6)
    wipeNoteColumn(7)
    renoise.song().selected_note_column_index = 1
    return
  else
    -- If number3 is not nil, process it using JalexAdd
    JalexAdd(number3)
  end

  -- Process number4
  if number4 == nil then
    -- If number4 is nil, wipe columns 5, 6, and 7
    wipeNoteColumn(5)
    wipeNoteColumn(6)
    wipeNoteColumn(7)
    renoise.song().selected_note_column_index = 1
    return
  else
    -- If number4 is not nil, process it using JalexAdd
    JalexAdd(number4)
  end

  -- Process number5
  if number5 == nil then
    -- If number5 is nil, wipe columns 6 and 7
    wipeNoteColumn(6)
    wipeNoteColumn(7)
    renoise.song().selected_note_column_index = 1
    return
  else
    -- If number5 is not nil, process it using JalexAdd
    JalexAdd(number5)
  end

  -- Process number6
  if number6 == nil then
    -- If number6 is nil, wipe columns 7 and 8
    wipeNoteColumn(7)
    wipeNoteColumn(8)
    renoise.song().selected_note_column_index = 1
    return
  else
    -- If number6 is not nil, process it using JalexAdd
    JalexAdd(number6)
  end

  -- Reset the selected note column index to 1
  renoise.song().selected_note_column_index = 1
end




-- List of chord progressions, reordered logically
local chord_list = {
  {name="Chordsplus 3-4 (Maj)", fn=function() chordsplus(4,3) end},
  {name="Chordsplus 4-3 (Min)", fn=function() chordsplus(3,4) end},
  {name="Chordsplus 4-3-4 (Maj7)", fn=function() chordsplus(4,3,4) end},
  {name="Chordsplus 3-4-3 (Min7)", fn=function() chordsplus(3,4,3) end},
  {name="Chordsplus 4-4-3 (Maj7+5)", fn=function() chordsplus(4,4,3) end},
  {name="Chordsplus 3-5-2 (Min7+5)", fn=function() chordsplus(3,5,2) end},
  {name="Chordsplus 3-4-4 (MinMaj7)", fn=function() chordsplus(3,4,4) end}, -- MinorMajor7
  {name="Chordsplus 4-3-4-3 (Maj9)", fn=function() chordsplus(4,3,4,3) end},
  {name="Chordsplus 3-4-3-3 (Min9)", fn=function() chordsplus(3,4,3,3) end},
  {name="Chordsplus 4-3-7 (Maj Added 9th)", fn=function() chordsplus(4,3,7) end},
  {name="Chordsplus 3-4-7 (Min Added 9th)", fn=function() chordsplus(3,4,7) end},
  {name="Chordsplus 4-7-3 (Maj9 Simplified)", fn=function() chordsplus(4,7,3) end}, -- Maj9 without 5th
  {name="Chordsplus 3-7-4 (Min9 Simplified)", fn=function() chordsplus(3,7,4) end}, -- Min9 without 5th
  {name="Chordsplus 3-8-3 (mM9 Simplified)", fn=function() chordsplus(3,8,3) end}, -- MinorMajor9 without 5th
  {name="Chordsplus 3-4-4-3 (mM9)", fn=function() chordsplus(3,4,4,3) end}, -- MinorMajor9
  {name="Chordsplus 4-3-2-5 (Maj6 Add9)", fn=function() chordsplus(4,3,2,5) end}, -- Maj6 Add9
  {name="Chordsplus 3-4-2-5 (Min6 Add9)", fn=function() chordsplus(3,4,2,5) end}, -- Min6 Add9
  {name="Chordsplus 2-5 (Sus2)", fn=function() chordsplus(2,5) end},
  {name="Chordsplus 5-2 (Sus4)", fn=function() chordsplus(5,2) end},
  {name="Chordsplus 5-2-3 (7Sus4)", fn=function() chordsplus(5,2,3) end},
  {name="Chordsplus 4-4 (Aug5)", fn=function() chordsplus(4,4) end},
{name="Chordsplus 4-4-2 (Aug6)", fn=function() chordsplus(4,4,2) end},
{name="Chordsplus 4-4-3 (Aug7)", fn=function() chordsplus(4,4,3) end},
{name="Chordsplus 4-4-4 (Aug8)", fn=function() chordsplus(4,4,4) end},  
  {name="Chordsplus 4-3-3-5 (Aug9)", fn=function() chordsplus(4,3,3,5) end},
  {name="Chordsplus 4-4-7 (Aug10)", fn=function() chordsplus(4,4,7) end},
  {name="Chordsplus 4-3-3-4-4 (Aug11)", fn=function() chordsplus(4,3,3,4,4) end},
  {name="Chordsplus 12-12-12 (Octaves)", fn=function() chordsplus(12,12,12) end}
}

local current_chord_index = 1 -- Start at the first chord

-- Function to advance to the next chord in the list
local function next_chord()
  chord_list[current_chord_index].fn() -- Invoke the current chord function
  renoise.app():show_status("Played: " .. chord_list[current_chord_index].name)
  current_chord_index = current_chord_index + 1
  if current_chord_index > #chord_list then
    current_chord_index = 1 -- Wrap back to the first chord
  end
end

-- MIDI mapping handler, maps values 0-127 to the list of chords
function midi_chord_mapping(value)
  local chord_index = math.floor((value / 127) * (#chord_list - 1)) + 1
  chord_list[chord_index].fn()
  renoise.app():show_status("Played via MIDI: " .. chord_list[chord_index].name)
end

-- Add keybindings dynamically based on the chord list
for i, chord in ipairs(chord_list) do
  renoise.tool():add_keybinding{
    name="Pattern Editor:Paketti:" .. chord.name,
    invoke=chord.fn
  }
end

-- Add keybinding for cycling through chords
renoise.tool():add_keybinding{
  name="Pattern Editor:Paketti:Next Chord in List",
  invoke=next_chord
}

-- MIDI mapping for direct chord access
renoise.tool():add_midi_mapping{
  name="Global:Paketti:Chord Selector [0-127]",
  invoke=function(midi_message) midi_chord_mapping(midi_message.int_value) end
}

