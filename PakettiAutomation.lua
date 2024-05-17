
local renoise = renoise
local tool = renoise.tool()


function apply_selection_up_linear()
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  envelope:clear_range(start_line, end_line)
  envelope:add_point_at(start_line, automation_parameter.value_min)
  envelope:add_point_at(end_line, 1.0)

  print("Selection Up Linear applied:")
  print("Start Line: " .. start_line .. ", Value: " .. automation_parameter.value_min)
  print("End Line: " .. end_line .. ", Value: 1.0")
end

local renoise = renoise
local tool = renoise.tool()


function apply_selection_down_linear()
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  envelope:clear_range(start_line, end_line)
  envelope:add_point_at(start_line, 1.0)
  envelope:add_point_at(end_line, automation_parameter.value_min)

  print("Selection Down Linear applied:")
  print("Start Line: " .. start_line .. ", Value: 1.0")
  print("End Line: " .. end_line .. ", Value: " .. automation_parameter.value_min)
end

local renoise = renoise
local tool = renoise.tool()

function apply_constant_automation_top_to_top(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  envelope:clear_range(start_line, end_line)
  envelope:add_point_at(start_line, 1.0)
  envelope:add_point_at(start_line + 1, 1.0)  -- A tick after start
  envelope:add_point_at(end_line - 1, 1.0)  -- Just before end
  envelope:add_point_at(end_line, 1.0)
end

local renoise = renoise
local tool = renoise.tool()



function apply_constant_automation_bottom_to_bottom(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  envelope:clear_range(start_line, end_line)
  envelope:add_point_at(start_line, 0.0)
  envelope:add_point_at(start_line + 1, 0.0)  -- A tick after start
  envelope:add_point_at(end_line - 1, 0.0)  -- Just before end
  envelope:add_point_at(end_line, 0.0)
end






local renoise = renoise
local tool = renoise.tool()

function apply_exponential_automation_curve_top_to_center(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  print("Automation from line " .. start_line .. " to " .. end_line)  -- Debug for range

  envelope:clear_range(start_line, end_line)

  local k = 6  -- Steepness factor
  for i = start_line, end_line do
    local normalizedPosition = (i - start_line) / (end_line - start_line)
    local value = 1.0 - 0.5 * (1 - math.exp(-k * normalizedPosition))  -- Adjusted for decay starting at 1.0
    envelope:add_point_at(i, value)
    print("Adding point at line " .. i .. " with value " .. value)  -- Debug print
  end

  -- Explicitly set the last point at end_line to 0.5
  envelope:add_point_at(end_line, 0.5)
  print("Explicitly setting final point at line " .. end_line .. " with value 0.5")  -- Debug print for the final point
end







local renoise = renoise
local tool = renoise.tool()


function apply_exponential_automation_curve_bottom_to_center(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  print("Automation from line " .. start_line .. " to " .. end_line)  -- Debug for range

  envelope:clear_range(start_line, end_line)

  local k = 6  -- Steepness factor
  -- We make sure to include the last index by going up to end_line
  for i = start_line, end_line do
    local normalizedPosition = (i - start_line) / (end_line - start_line)
    local value = 0.5 * (1 - math.exp(-k * normalizedPosition))
    envelope:add_point_at(i, value)
    print("Adding point at line " .. i .. " with value " .. value)  -- Debug print
  end
  
    -- Explicitly set the last point at end_line to 0.5
  envelope:add_point_at(end_line, 0.5)
  print("Explicitly setting final point at line " .. end_line .. " with value 0.5")  -- Debug print for the final point

end








local renoise = renoise
local tool = renoise.tool()

function apply_exponential_automation_curve_center_to_bottom(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  envelope:clear_range(start_line, end_line)

  local k = 3
  for i = start_line, end_line - 1 do  -- Loop until the second last point
    local normalizedPosition = (i - start_line) / (end_line - start_line)
    local value = 0.5 * (1 - math.exp(k * normalizedPosition - k))
    envelope:add_point_at(i, value)
  end
  envelope:add_point_at(end_line, 0.0)  -- Explicitly set the last point to 0.0
end




local renoise = renoise
local tool = renoise.tool()


function apply_exponential_automation_curve_center_to_top(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  envelope:clear_range(start_line, end_line)

  local k = 3
  for i = start_line, end_line - 1 do  -- Loop until the second last point
    local normalizedPosition = (i - start_line) / (end_line - start_line)
    local value = 0.5 + 0.5 * math.exp(k * normalizedPosition - k)
    envelope:add_point_at(i, value)
  end
  envelope:add_point_at(end_line, 1.0)  -- Explicitly set the last point to 1.0
end








local renoise = renoise
local tool = renoise.tool()

renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Selection Up (Linear)",
invoke = function() apply_selection_up_linear() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Selection Down (Linear)",
invoke = function() apply_selection_down_linear() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Top to Top",
invoke=function() apply_constant_automation_top_to_top() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Bottom to Bottom",
invoke=function() apply_constant_automation_bottom_to_bottom() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Top to Center (Exp)",
invoke=function() apply_exponential_automation_curve_top_to_center() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Bottom to Center (Exp)",
invoke=function() apply_exponential_automation_curve_bottom_to_center() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Center to Bottom (Exp)",
invoke=function() apply_exponential_automation_curve_center_to_bottom() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Center to Top (Exp)",
invoke=function() apply_exponential_automation_curve_center_to_top() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Selection Down (Exp)",
invoke=function() apply_exponential_automation_curveDOWN() end})
renoise.tool():add_menu_entry({name="Track Automation:Paketti..:Selection Up (Exp)",
invoke=function() apply_exponential_automation_curveUP() end})



function apply_exponential_automation_curveDOWN(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  print("Selection start: " .. start_line .. ", end: " .. end_line)  -- Debug for selection range

  envelope:clear_range(start_line, end_line)

  local k = 3  -- Adjust this value to change the steepness of the curve
  for i = start_line, end_line do
    local normalizedPosition = (i - start_line) / (end_line - start_line)
    local value = 1 - (math.exp(k * normalizedPosition) / math.exp(k))  -- Using exponential decay
    envelope:add_point_at(i, value)
    print("Adding point at line " .. i .. " with value " .. value)  -- Debug print
  end

  -- Explicitly setting the last point to ensure it hits exactly 0.0
  envelope:add_point_at(end_line, 0.0)
  print("Explicitly setting final point at line " .. end_line .. " with value 0.0")  -- Debug print for the final point
end



-- Selection up EXP
local renoise = renoise
local tool = renoise.tool()


function apply_exponential_automation_curveUP(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]

  print("Selection start: " .. start_line .. ", end: " .. end_line)  -- Debug for selection range

  envelope:clear_range(start_line, end_line)

  local k = 3  -- Adjust this value to change the steepness of the curve
  for i = start_line, end_line do
    local normalizedPosition = (i - start_line) / (end_line - start_line)
    local value = (math.exp(k * normalizedPosition)) / (math.exp(k))
    envelope:add_point_at(i, value)
    print("Adding point at line " .. i .. " with value " .. value)  -- Debug print
  

  -- Explicitly setting the last point to ensure it hits exactly 1.0
  local final_value = (math.exp(k)) / (math.exp(k))
  envelope:add_point_at(end_line, final_value)
  print("Explicitly setting final point at line " .. (end_line) .. " with value " .. final_value)  -- Debug print for the final point
end
end

--------
-------- linear uplocal renoise = renoise
local renoise = renoise
local tool = renoise.tool()

local menu_entries = {
  {"Track Automation:Paketti..:Selection Center->Up (Linear)", "center_up_linear"},
  {"Track Automation:Paketti..:Selection Center->Down (Linear)", "center_down_linear"},
  {"Track Automation:Paketti..:Selection Up->Center (Linear)", "up_center_linear"},
  {"Track Automation:Paketti..:Selection Down->Center (Linear)", "down_center_linear"}
}

for _, entry in ipairs(menu_entries) do
  tool:add_menu_entry({
    name = entry[1],
    invoke = function() apply_linear_automation_curveCenter(entry[2]) end
  })
end

function apply_linear_automation_curveCenter(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]
  local mid_val = (automation_parameter.value_min + automation_parameter.value_max) / 2

  envelope:clear_range(start_line, end_line)

  if type == "center_up_linear" then
    envelope:add_point_at(start_line, mid_val)
    envelope:add_point_at(end_line, automation_parameter.value_max)
  elseif type == "center_down_linear" then
    envelope:add_point_at(start_line, mid_val)
    envelope:add_point_at(end_line, automation_parameter.value_min)
  elseif type == "up_center_linear" then
    envelope:add_point_at(start_line, automation_parameter.value_max)
    envelope:add_point_at(end_line, mid_val)
  elseif type == "down_center_linear" then
    envelope:add_point_at(start_line, automation_parameter.value_min)
    envelope:add_point_at(end_line, mid_val)
  end
end





--set to center
local renoise = renoise
local tool = renoise.tool()

tool:add_menu_entry({name = "--Track Automation:Paketti..:Set to Center",
  invoke = function() set_to_center() end
})

function set_to_center()
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter
  if not automation_parameter or not automation_parameter.is_automatable then
    renoise.app():show_status("Please select an automatable parameter.")
    return
  end

  local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)
  if not envelope or not envelope.selection_range then
    renoise.app():show_status("No automation selection or envelope found.")
    return
  end

  local selection = envelope.selection_range
  local start_line = selection[1]
  local end_line = selection[2]
  local mid_val = (automation_parameter.value_min + automation_parameter.value_max) / 2

  envelope:clear_range(start_line, end_line)
  envelope:add_point_at(start_line, mid_val)
  envelope:add_point_at(end_line, mid_val)
end

function openExternalInstrumentEditor()
local pd=renoise.song().selected_instrument.plugin_properties.plugin_device
local w=renoise.app().window
    if renoise.song().selected_instrument.plugin_properties.plugin_loaded==false then
    --w.pattern_matrix_is_visible = false
    --w.sample_record_dialog_is_visible = false
    --w.upper_frame_is_visible = true
    --w.lower_frame_is_visible = true
    --w.active_upper_frame = 1
    --w.active_middle_frame= 4
    --w.active_lower_frame = 1 -- TrackDSP
    w.lock_keyboard_focus=true
    else
     if pd.external_editor_visible==false then pd.external_editor_visible=true else pd.external_editor_visible=false end
     end
end

renoise.tool():add_menu_entry{name="Track Automation:Paketti..:Open External Editor for Plugin",invoke=function() openExternalInstrumentEditor() end}









-- 
function showAutomationHard()
if renoise.app().window.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
and renoise.app().window.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_MIXER
then renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
else end
renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
end
renoise.tool():add_keybinding{name="Global:Paketti:Switch to Automation",invoke=function() showAutomationHard() end}

-- Show automation (via Pattern Matrix/Pattern Editor)
function showAutomation()
  local w=renoise.app().window
  local raw=renoise.ApplicationWindow
  local wamf = renoise.app().window.active_middle_frame
  if wamf==1 and renoise.app().window.lower_frame_is_visible==false then w.active_lower_frame = raw.LOWER_FRAME_TRACK_AUTOMATION return else end
 
  if (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR)
 or (wamf==raw.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR) 
  then renoise.app().window.active_middle_frame=1 
  w.active_lower_frame = raw.LOWER_FRAME_TRACK_AUTOMATION
  return else end
if w.active_lower_frame == raw.LOWER_FRAME_TRACK_AUTOMATION 
then w.active_lower_frame = raw.LOWER_FRAME_TRACK_DSPS return end  
    w.active_lower_frame = raw.LOWER_FRAME_TRACK_AUTOMATION
    w.lock_keyboard_focus=true
    renoise.song().transport.follow_player=false end

renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Switch to Automation",invoke=function() showAutomation() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Switch to Automation",invoke=function() showAutomation() end}
renoise.tool():add_keybinding{name="Pattern Matrix:Paketti:Switch to Automation",invoke=function() showAutomation() end}
renoise.tool():add_keybinding{name="Mixer:Paketti:Switch to Automation",invoke=function() showAutomation() end}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Show Automation",invoke=function() renoise.app().window.active_lower_frame=renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
 end}
 renoise.tool():add_keybinding{name="Mixer:Paketti:Show Automation", invoke=function() renoise.app().window.active_lower_frame=renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
 end}
renoise.tool():add_keybinding{name="Instrument Box:Paketti:Show Automation",invoke=function() renoise.app().window.active_lower_frame=renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
 end}
-----------
-- Draw Automation curves, lines, within Automation Selection.

-------------------------------------------------------
function gainerExpCurveVol()
  local song = renoise.song()
  local length = song.patterns[song.selected_pattern_index].number_of_lines
  local curve = 1.105
  
  loadnative("Audio/Effects/Native/Gainer")
  local gainer = song.selected_track.devices[2]
  local gain_parameter = gainer.parameters[1]  -- Gain parameter
  local track_index = song.selected_track_index
  local envelope = song.patterns[song.selected_pattern_index].tracks[track_index]:create_automation(gain_parameter)
  envelope:clear()

  -- Define the number of points based on the pattern length
  local total_points = length <= 16 and 16 or length  -- If pattern length is 16 or fewer, use 16 points; otherwise, use the length

  local max_exp_value = math.pow(curve, length - 1)  -- Calculate the maximum value for normalization

  -- Insert points for detailed automation
  for i = 0, total_points - 1 do
    local position = i / (total_points - 1) * (length - 1)  -- Scale position in the range of 0 to length-1
    local expValue = math.pow(curve, position)
    local normalizedValue = (expValue - 1) / (max_exp_value - 1)
    envelope:add_point_at(math.floor(position + 1), math.max(0, normalizedValue))  -- Ensure the point is within valid range
  end

  song.transport.edit_mode = false
  renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
end


function gainerExpReverseCurveVol()
  local song = renoise.song()
  local length = song.patterns[song.selected_pattern_index].number_of_lines
  local curve = 1.105
  
  loadnative("Audio/Effects/Native/Gainer")
  local gainer = song.selected_track.devices[2]
  local gain_parameter = gainer.parameters[1]  -- Gain parameter
  local track_index = song.selected_track_index
  local envelope = song.patterns[song.selected_pattern_index].tracks[track_index]:create_automation(gain_parameter)
  envelope:clear()

  -- Define the number of points based on the pattern length
  local total_points = length <= 16 and 16 or length  -- Use 16 points for patterns of 16 rows or fewer

  local max_exp_value = math.pow(curve, length - 1)  -- Calculate the maximum value for normalization

  -- Insert points for detailed automation
  for i = 0, total_points - 1 do
    local position = i / (total_points - 1) * (length - 1)  -- Scale position in the range of 0 to length-1
    local expValue = math.pow(curve, (length - 1) - position)  -- Reverse the curve calculation
    local normalizedValue = (expValue - 1) / (max_exp_value - 1)
    envelope:add_point_at(math.floor(position + 1), math.max(0, normalizedValue))  -- Ensure the point is within valid range
  end

  song.transport.edit_mode = false
  renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
end

renoise.tool():add_keybinding{name="Global:Paketti:Gainer Exponential Curve Up", invoke = function() gainerExpCurveVol() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Gainer Exponential Curve Up", invoke=function() gainerExpCurveVol() end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Gainer Exponential Curve Up", invoke=function() gainerExpCurveVol() end}
renoise.tool():add_menu_entry{name="--Track Automation:Paketti..:Gainer Exponential Curve Up", invoke=function() gainerExpCurveVol() end}
renoise.tool():add_menu_entry{name="Track Automation List:Paketti..:Gainer Exponential Curve Up", invoke=function() gainerExpCurveVol() end}

renoise.tool():add_keybinding{name="Global:Paketti:Gainer Exponential Curve Down", invoke=function() gainerExpReverseCurveVol() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Gainer Exponential Curve Down", invoke=function() gainerExpReverseCurveVol() end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Gainer Exponential Curve Down", invoke=function() gainerExpReverseCurveVol() end}
renoise.tool():add_menu_entry{name="Track Automation:Paketti..:Gainer Exponential Curve Down", invoke=function() gainerExpReverseCurveVol() end}
renoise.tool():add_menu_entry{name="Track Automation List:Paketti..:Gainer Exponential Curve Down", invoke=function() gainerExpReverseCurveVol() end}


--------------




