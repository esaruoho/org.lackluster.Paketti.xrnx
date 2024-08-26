
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

for _, entry in ipairs(menu_entries) do tool:add_menu_entry({name = entry[1], invoke = function() apply_linear_automation_curveCenter(entry[2]) end})
end

-- Create the linear automation functions
function center_up_linear()
  apply_linear_automation_curveCenter("center_up_linear")
end

function center_down_linear()
  apply_linear_automation_curveCenter("center_down_linear")
end

function up_center_linear()
  apply_linear_automation_curveCenter("up_center_linear")
end

function down_center_linear()
  apply_linear_automation_curveCenter("down_center_linear")
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



function AutomationDeviceShowUI()
if renoise.song().selected_automation_device.external_editor_visible
then renoise.song().selected_automation_device.external_editor_visible=false
else
renoise.song().selected_automation_device.external_editor_visible=true
end
end

renoise.tool():add_menu_entry{name="--Track Automation List:Paketti..:Show/Hide External Editor for Device", invoke=function() AutomationDeviceShowUI() end}
renoise.tool():add_menu_entry{name="Track Automation List:Paketti..:Show/Hide External Editor for Plugin",invoke=function() openExternalInstrumentEditor() end}
renoise.tool():add_menu_entry{name="--Track Automation:Paketti..:Show/Hide External Editor for Device", invoke=function() AutomationDeviceShowUI() end}
renoise.tool():add_menu_entry{name="Track Automation:Paketti..:Show/Hide External Editor for Plugin",invoke=function() openExternalInstrumentEditor() end}






-- 
function showAutomationHard()
if renoise.app().window.active_middle_frame == 5
then renoise.app().window.active_middle_frame = 1
end

if renoise.app().window.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
then
renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
return
end

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
    local normalizedValue = (expValue - 1) / (max_exp_value - 1) * 0.25  -- Adjust the normalized value to cap at 0.25
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
    local normalizedValue = (expValue - 1) / (max_exp_value - 1) * 0.25  -- Adjust the normalized value to cap at 0.25
    envelope:add_point_at(math.floor(position + 1), math.max(0, normalizedValue))  -- Ensure the point is within valid range
  end

  song.transport.edit_mode = false
  renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
end

renoise.tool():add_keybinding{name="Global:Paketti:Gainer Exponential Curve Up", invoke=function() gainerExpCurveVol() end}
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




-- Function to read the selected slots in the pattern matrix for the currently selected track.
local function read_pattern_matrix_selection()
  local song = renoise.song()
  local sequencer = song.sequencer
  local track_index = song.selected_track_index
  local selected_slots = {}
  local total_patterns = #sequencer.pattern_sequence

  -- Loop through the sequence slots and check selection status for the selected track
  for sequence_index = 1, total_patterns do
    if sequencer:track_sequence_slot_is_selected(track_index, sequence_index) then
      table.insert(selected_slots, sequence_index)
    end
  end

  return selected_slots
end

-- Helper function to get or create automation
local function get_or_create_automation(parameter, pattern_index, track_index)
  local automation = renoise.song().patterns[pattern_index].tracks[track_index]:find_automation(parameter)
  if automation then
    automation:clear()  -- Clear existing automation
  else
    automation = renoise.song().patterns[pattern_index].tracks[track_index]:create_automation(parameter)
  end
  return automation
end

-- Clamp a value to the range [0, 1]
local function clamp(value)
  return math.max(0.0, math.min(1.0, value))
end

-- Function to apply ramp to selected automation
local function apply_ramp(selected_slots, ramp_type, is_exp, is_up)
  local song = renoise.song()
  local track_index = song.selected_track_index
  local selected_parameter = song.selected_automation_parameter

  if not selected_parameter then
    renoise.app():show_status("No automation lane selected.")
    return
  end

  -- Calculate total length of selected patterns
  local total_length = 0
  local pattern_lengths = {}
  for _, sequence_index in ipairs(selected_slots) do
    local pattern_index = song.sequencer.pattern_sequence[sequence_index]
    local pattern_length = song.patterns[pattern_index].number_of_lines
    pattern_lengths[#pattern_lengths + 1] = pattern_length
    total_length = total_length + pattern_length
  end

  -- Set up exponential or linear ramp
  local curve = is_exp and 1.1 or 1.0
  local max_value = math.pow(curve, total_length - 1)

  -- Apply the ramp to the automation parameter
  local current_position = 0
  for idx, sequence_index in ipairs(selected_slots) do
    local pattern_index = song.sequencer.pattern_sequence[sequence_index]
    local pattern_length = pattern_lengths[idx]
    local envelope = get_or_create_automation(selected_parameter, pattern_index, track_index)

    -- Clear the envelope and apply the ramp
    envelope:clear()

    for line = 0, pattern_length - 1 do
      local global_position = current_position + line
      local normalized_value

      if is_exp then
        -- Exponential calculation
        normalized_value = math.pow(curve, global_position)
        normalized_value = (normalized_value - 1) / (max_value - 1)
      else
        -- Linear calculation
        normalized_value = global_position / (total_length - 1)
      end

      -- Clamp the value to the [0, 1] range
      normalized_value = clamp(is_up and normalized_value or 1 - normalized_value)

      -- Apply the point to the envelope
      envelope:add_point_at(line + 1, normalized_value)
    end

    -- Update position for the next pattern
    current_position = current_position + pattern_length
  end

  renoise.app():show_status(ramp_type .. " ramp applied to selected automation.")
end

-- Wrapper functions for the different ramp operations
local function automation_volume_ramp_up_exp()
  local selected_slots = read_pattern_matrix_selection()
  apply_ramp(selected_slots, "Exponential Volume Up", true, true)
end

local function automation_volume_ramp_down_exp()
  local selected_slots = read_pattern_matrix_selection()
  apply_ramp(selected_slots, "Exponential Volume Down", true, false)
end

local function automation_volume_ramp_up_lin()
  local selected_slots = read_pattern_matrix_selection()
  apply_ramp(selected_slots, "Linear Volume Up", false, true)
end

local function automation_volume_ramp_down_lin()
  local selected_slots = read_pattern_matrix_selection()
  apply_ramp(selected_slots, "Linear Volume Down", false, false)
end

-- Automation ramps based on selected automation lane
local function automation_ramp_up_exp()
  local selected_slots = read_pattern_matrix_selection()
  apply_ramp(selected_slots, "Exponential Automation Up", true, true)
end

local function automation_ramp_down_exp()
  local selected_slots = read_pattern_matrix_selection()
  apply_ramp(selected_slots, "Exponential Automation Down", true, false)
end

local function automation_ramp_up_lin()
  local selected_slots = read_pattern_matrix_selection()
  apply_ramp(selected_slots, "Linear Automation Up", false, true)
end

local function automation_ramp_down_lin()
  local selected_slots = read_pattern_matrix_selection()
  apply_ramp(selected_slots, "Linear Automation Down", false, false)
end

-- Optimized `menu_entry` and `key_binding` definitions for compactness
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Ramp Up (Exp) for Selection", invoke = automation_ramp_up_exp }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Ramp Down (Exp) for Selection", invoke = automation_ramp_down_exp }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Ramp Up (Lin) for Selection", invoke = automation_ramp_up_lin }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Ramp Down (Lin) for Selection", invoke = automation_ramp_down_lin }

renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Ramp Up (Exp)", invoke = automation_ramp_up_exp }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Ramp Down (Exp)", invoke = automation_ramp_down_exp }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Ramp Up (Lin)", invoke = automation_ramp_up_lin }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Ramp Down (Lin)", invoke = automation_ramp_down_lin }

-- Whitelist of center-based automation parameters
local center_based_parameters = {
  ["X_Pitchbend"] = true,
  ["Panning"] = true,
  ["Pitchbend"] = true
}

-- Function to apply special center-based ramp for certain parameters (linear and exponential)
local function apply_center_based_ramp(selected_slots, ramp_type, is_up, is_exp)
  local song = renoise.song()
  local track_index = song.selected_track_index
  local selected_parameter = song.selected_automation_parameter

  if not selected_parameter then
    renoise.app():show_status("No automation lane selected.")
    return
  end

  -- Check if the selected parameter is in the center-based whitelist
  if not center_based_parameters[selected_parameter.name] then
    renoise.app():show_status("Selected parameter is not center-based.")
    return
  end

  -- Calculate total length of selected patterns
  local total_length = 0
  local pattern_lengths = {}
  for _, sequence_index in ipairs(selected_slots) do
    local pattern_index = song.sequencer.pattern_sequence[sequence_index]
    local pattern_length = song.patterns[pattern_index].number_of_lines
    pattern_lengths[#pattern_lengths + 1] = pattern_length
    total_length = total_length + pattern_length
  end

  -- Set up the exponential or linear ramp (0.5 based)
  local curve = is_exp and 1.1 or 1
  local max_value = math.pow(curve, total_length - 1)

  -- Apply the ramp to the automation parameter
  local current_position = 0
  for idx, sequence_index in ipairs(selected_slots) do
    local pattern_index = song.sequencer.pattern_sequence[sequence_index]
    local pattern_length = pattern_lengths[idx]
    local envelope = get_or_create_automation(selected_parameter, pattern_index, track_index)

    -- Clear the envelope and apply the ramp
    envelope:clear()

    for line = 0, pattern_length - 1 do
      local global_position = current_position + line
      local normalized_value

      -- Linear interpolation
      if not is_exp then
        local t = global_position / (total_length - 1)
        if ramp_type == "Top to Center" then
          normalized_value = 1.0 - (t * 0.5) -- 1.0 to 0.5
        elseif ramp_type == "Bottom to Center" then
          normalized_value = t * 0.5 -- 0.0 to 0.5
        elseif ramp_type == "Center to Top" then
          normalized_value = 0.5 + (t * 0.5) -- 0.5 to 1.0
        elseif ramp_type == "Center to Bottom" then
          normalized_value = 0.5 - (t * 0.5) -- 0.5 to 0.0
        end
      else
        -- Exponential interpolation
        normalized_value = math.pow(curve, global_position)
        normalized_value = (normalized_value - 1) / (max_value - 1)
        if ramp_type == "Top to Center" then
          normalized_value = 1.0 - (normalized_value * 0.5) -- 1.0 to 0.5
        elseif ramp_type == "Bottom to Center" then
          normalized_value = normalized_value * 0.5 -- 0.0 to 0.5
        elseif ramp_type == "Center to Top" then
          normalized_value = 0.5 + (normalized_value * 0.5) -- 0.5 to 1.0
        elseif ramp_type == "Center to Bottom" then
          normalized_value = 0.5 - (normalized_value * 0.5) -- 0.5 to 0.0
        end
      end

      -- Ensure the normalized_value is within valid bounds
      normalized_value = math.max(0, math.min(1, normalized_value))

      -- Apply the point to the envelope
      envelope:add_point_at(line + 1, normalized_value)
    end

    -- Update position for the next pattern
    current_position = current_position + pattern_length
  end

  renoise.app():show_status(ramp_type .. " center-based ramp applied to selected automation.")
end

-- Special center-based ramp operations (Exponential and Linear)
local function automation_center_to_top_exp() apply_center_based_ramp(read_pattern_matrix_selection(), "Center to Top", true, true) end
local function automation_top_to_center_exp() apply_center_based_ramp(read_pattern_matrix_selection(), "Top to Center", false, true) end
local function automation_center_to_bottom_exp() apply_center_based_ramp(read_pattern_matrix_selection(), "Center to Bottom", false, true) end
local function automation_bottom_to_center_exp() apply_center_based_ramp(read_pattern_matrix_selection(), "Bottom to Center", true, true) end

local function automation_center_to_top_lin() apply_center_based_ramp(read_pattern_matrix_selection(), "Center to Top", true, false) end
local function automation_top_to_center_lin() apply_center_based_ramp(read_pattern_matrix_selection(), "Top to Center", false, false) end
local function automation_center_to_bottom_lin() apply_center_based_ramp(read_pattern_matrix_selection(), "Center to Bottom", false, false) end
local function automation_bottom_to_center_lin() apply_center_based_ramp(read_pattern_matrix_selection(), "Bottom to Center", true, false) end

-- Register menu entries and keybindings for all 8 center-based automations
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Center to Top (Exp)", invoke = automation_center_to_top_exp }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Top to Center (Exp)", invoke = automation_top_to_center_exp }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Center to Bottom (Exp)", invoke = automation_center_to_bottom_exp }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Bottom to Center (Exp)", invoke = automation_bottom_to_center_exp }

renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Center to Top (Lin)", invoke = automation_center_to_top_lin }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Top to Center (Lin)", invoke = automation_top_to_center_lin }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Center to Bottom (Lin)", invoke = automation_center_to_bottom_lin }
renoise.tool():add_menu_entry { name = "Pattern Matrix:Paketti..:Automation Bottom to Center (Lin)", invoke = automation_bottom_to_center_lin }

renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Center to Top (Exp)", invoke = automation_center_to_top_exp }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Top to Center (Exp)", invoke = automation_top_to_center_exp }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Center to Bottom (Exp)", invoke = automation_center_to_bottom_exp }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Bottom to Center (Exp)", invoke = automation_bottom_to_center_exp }

renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Center to Top (Lin)", invoke = automation_center_to_top_lin }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Top to Center (Lin)", invoke = automation_top_to_center_lin }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Center to Bottom (Lin)", invoke = automation_center_to_bottom_lin }
renoise.tool():add_keybinding { name = "Global:Paketti..:Automation Bottom to Center (Lin)", invoke = automation_bottom_to_center_lin }





