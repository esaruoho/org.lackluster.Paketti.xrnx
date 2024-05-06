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

renoise.tool():add_keybinding{
name="Pattern Editor:Paketti:Show Automation",invoke=function() renoise.app().window.active_lower_frame=renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
 end}
 renoise.tool():add_keybinding{
name="Mixer:Paketti:Show Automation", invoke=function() renoise.app().window.active_lower_frame=renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
 end}
renoise.tool():add_keybinding{
name="Instrument Box:Paketti:Show Automation",invoke=function() renoise.app().window.active_lower_frame=renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
 end}
-----------
-- Draw Automation curves, lines, within Automation Selection.

local renoise = renoise
local tool = renoise.tool()

-- Updated menu paths with new functionalities
local menu_entries = {
  {"Track Automation:Paketti..:Selection Up (Exp)", "exp_ramp_up"},
  {"Track Automation:Paketti..:Selection Up (Linear)", "linear_up"},
  {"Track Automation:Paketti..:Selection Down (Exp)", "exp_ramp_down"},
  {"Track Automation:Paketti..:Selection Down (Linear)", "linear_down"},
  {"--Track Automation:Paketti..:Selection Center->Up (Exp)", "center_exp_up"},
  {"Track Automation:Paketti..:Selection Center->Up (Linear)", "center_linear_up"},
  {"Track Automation:Paketti..:Selection Center->Down (Exp)", "center_exp_down"},
  {"Track Automation:Paketti..:Selection Center->Down (Linear)", "center_linear_down"},
  {"--Track Automation:Paketti..:Set to Center", "set_to_center"},
  {"--Track Automation:Paketti..:Selection Top->Center (Exp)", "back_to_center_top_exp"},
  {"Track Automation:Paketti..:Selection Top->Center (Linear)", "back_to_center_top_linear"},
  {"Track Automation:Paketti..:Selection Bottom->Center (Exp)", "back_to_center_bottom_exp"},
  {"Track Automation:Paketti..:Selection Bottom->Center (Linear)", "back_to_center_bottom_linear"}
}

-- Add menu entries
for _, entry in ipairs(menu_entries) do
  tool:add_menu_entry {
    name = entry[1],
    invoke = function() apply_automation_curve(entry[2]) end
  }
end

function apply_automation_curve(type)
  local song = renoise.song()
  local automation_parameter = song.selected_automation_parameter

  if automation_parameter and automation_parameter.is_automatable then
    local envelope = song:pattern(song.selected_pattern_index):track(song.selected_track_index):find_automation(automation_parameter)

    if envelope and envelope.selection_range then
      local selection = envelope.selection_range
      local start_line = selection[1]
      local end_line = selection[2]

      -- Get min, max, and mid values
      local min_val = automation_parameter.value_min
      local max_val = automation_parameter.value_max
      local mid_val = (min_val + max_val) / 2

      -- Clear existing points in the selection range
      envelope:clear_range(start_line, end_line)

      -- Calculate and set the boundary values only
      if type == "set_to_center" or string.match(type, "linear") then
        local start_val, end_val
        if type == "set_to_center" then
          start_val, end_val = mid_val, mid_val
        elseif type == "linear_up" then
          start_val, end_val = min_val, max_val
        elseif type == "linear_down" then
          start_val, end_val = max_val, min_val
        elseif type == "center_linear_up" then
          start_val, end_val = mid_val, max_val
        elseif type == "center_linear_down" then
          start_val, end_val = mid_val, min_val
        elseif type == "back_to_center_top_linear" then
          start_val, end_val = max_val, mid_val
        elseif type == "back_to_center_bottom_linear" then
          start_val, end_val = min_val, mid_val
        end
        envelope:add_point_at(start_line, start_val)
        envelope:add_point_at(end_line, end_val)
      else
        -- Apply curve with full range modification, ensuring the final step is added
        for i = start_line, end_line do
          local normalizedPosition = (i - start_line) / (end_line - start_line)
          local value = calculate_value(type, normalizedPosition, min_val, max_val, mid_val)
          envelope:add_point_at(i, value)
        end
        -- Ensure the last point is explicitly added
        local final_value = calculate_value(type, 1, min_val, max_val, mid_val)
        envelope:add_point_at(end_line, final_value)
      end
    else
      renoise.app():show_status("No automation selection or envelope found.")
    end
  else
    renoise.app():show_status("No automatable parameter selected.")
  end
end

function calculate_value(type, normalizedPosition, min_val, max_val, mid_val)
  local value = 0
  if type == "exp_ramp_up" then
    value = math.exp(normalizedPosition * 5 - 5) -- 0.007 to 1
  elseif type == "exp_ramp_down" then
    value = 1 - math.exp(normalizedPosition * 5 - 5) -- 1 to 0.007
  elseif type == "center_exp_up" then
    value = mid_val + (max_val - mid_val) * (math.exp(normalizedPosition * 8) - 1) / (math.exp(8) - 1)
  elseif type == "center_exp_down" then
    value = mid_val - (mid_val - min_val) * (math.exp(normalizedPosition * 8) - 1) / (math.exp(8) - 1)
  elseif type == "back_to_center_top_exp" then
    value = max_val * (math.exp(-10 * normalizedPosition)) + mid_val * (1 - math.exp(-10 * normalizedPosition))
  elseif type == "back_to_center_bottom_exp" then
    value = min_val * (math.exp(-10 * normalizedPosition)) + mid_val * (1 - math.exp(-10 * normalizedPosition))
  end
  return math.max(min_val, math.min(max_val, value)) -- Clamping value
end




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




