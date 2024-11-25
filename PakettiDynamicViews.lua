-- Declare DynamicViewPrefs before using it
local DynamicViewPrefs

-- Set the number of dynamic views
local dynamic_views_count = 8
local steps_per_view = 8

local views_upper = {
  {frame = renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES, label = "Track Scopes"},
  {frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM, label = "Master Spectrum"}
}

local views_middle = {
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR, label = "Pattern Editor"},
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_MIXER, label = "Mixer"},
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR, label = "Phrase Editor"},
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES, label = "Sample Keyzones"},
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR, label = "Sample Editor"},
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION, label = "Sample Modulation"},
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS, label = "Sample Effects"},
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR, label = "Plugin Editor"},
  {frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR, label = "MIDI Editor"}
}

local views_lower = {
  {frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS, label = "Track DSPs"},
  {frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION, label = "Track Automation"}
}

-- Restricted middle frames that force the lower frame to hide
local restricted_middle_frames = { 
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR
}

-- Middle frames that disable Pattern Matrix and Advanced Editor
local disable_pattern_matrix_advanced_edit_middle_frames = {
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR,
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR
}

-- Mixer frame that disables Advanced Editor
local disable_advanced_edit_mixer_frame = renoise.ApplicationWindow.MIDDLE_FRAME_MIXER

-- Current step tracker for each dynamic view
local current_steps = {}
for i = 1, dynamic_views_count do
  current_steps[i] = 0 -- Start with step 0 for each dynamic view
end

-- Last cycled time tracker for debounce
local last_cycled_time = {}
for i = 1, dynamic_views_count do
  last_cycled_time[i] = 0
end

-- Access renoise.tool().preferences
local preferences = renoise.tool().preferences
local DynamicViewPrefs

if not preferences:property("PakettiDynamicViews") then
  preferences:add_property("PakettiDynamicViews", renoise.Document.DocumentList())
end
DynamicViewPrefs = preferences.PakettiDynamicViews


-- Initialize PakettiDynamicViews if not already present
for dv = 1, dynamic_views_count do
  if not preferences.PakettiDynamicViews[dv] then
    local dynamic_view = create_dynamic_view_entry()
    preferences.PakettiDynamicViews:insert(dv, dynamic_view)
  end
end


-- Initialize Dynamic View Preferences without overwriting existing ones
function initializeDynamicViewPreferences()
-- Initialize PakettiDynamicViews if not already present
for dv = 1, dynamic_views_count do
  if not preferences.PakettiDynamicViews[dv] then
    local dynamic_view = create_dynamic_view_entry()
    preferences.PakettiDynamicViews:insert(dv, dynamic_view)
  else
    -- Ensure steps are initialized
    local dynamic_view = preferences.PakettiDynamicViews[dv]
    if not dynamic_view.steps then
      dynamic_view:property("steps", renoise.Document.DocumentList())
    end
    for step = 1, steps_per_view do
      if not dynamic_view.steps[step] then
        local step_entry = create_dynamic_view_step_entry()
        dynamic_view.steps:insert(step, step_entry)
      end
    end
  end
end
-- Call the initialization function
end
initializeDynamicViewPreferences()

-- Function to check if the middle frame should disable both Pattern Matrix and Advanced Editor
local function disable_pattern_matrix_and_advanced_edit(middle_frame)
  for _, frame in ipairs(disable_pattern_matrix_advanced_edit_middle_frames) do
    if middle_frame == frame then
      return true
    end
  end
  return false
end

-- Function to check if the middle frame is restricted
local function is_restricted_middle_frame(middle_frame)
  for _, restricted_frame in ipairs(restricted_middle_frames) do
    if middle_frame == restricted_frame then
      return true
    end
  end
  return false
end

-- Function to build dropdown options for a given view list
local function build_options(view_list, include_hide)
  local options = { "<Change Nothing>" }
  if include_hide then
    table.insert(options, "<Hide>")
  end
  for _, view in ipairs(view_list) do
    table.insert(options, view.label)
  end
  return options
end

function apply_dynamic_view_step(dv, step)
  local app_window = renoise.app().window

  -- Access the dynamic view and step entry
  local dynamic_view = preferences.PakettiDynamicViews[dv]
  local step_entry = dynamic_view.steps[step]

  -- Access properties from step_entry
  local upper_frame_index = step_entry.upper_frame_index.value or 1
  local middle_frame_index = step_entry.middle_frame_index.value or 1
  local lower_frame_index = step_entry.lower_frame_index.value or 1

  -- Apply Upper Frame
  if upper_frame_index == 1 then
    -- "<Change Nothing>" - do not change visibility or active frame
  elseif upper_frame_index == 2 then
    app_window.upper_frame_is_visible = false  -- "<Hide>"
  else
    app_window.active_upper_frame = views_upper[upper_frame_index - 2].frame
    app_window.upper_frame_is_visible = true
  end

  -- Apply Middle Frame
  if middle_frame_index == 1 then
    -- "<Change Nothing>" - do nothing
  else
    local middle_frame = views_middle[middle_frame_index - 1].frame
    app_window.active_middle_frame = middle_frame

    -- Automatically hide the lower frame if a restricted middle frame is selected
    if is_restricted_middle_frame(middle_frame) then
      app_window.lower_frame_is_visible = false
      lower_frame_index = 2  -- Set to "<Hide>" for consistency
      step_entry.lower_frame_index.value = 2
    end

    -- Uncheck the Pattern Advanced Edit checkbox if necessary
    if disable_pattern_matrix_and_advanced_edit(middle_frame) then
      step_entry.pattern_matrix_visible.value = false
      step_entry.pattern_advanced_edit_visible.value = false
    elseif middle_frame == disable_advanced_edit_mixer_frame then
      -- Only uncheck the Pattern Advanced Edit checkbox, allow Pattern Matrix
      step_entry.pattern_advanced_edit_visible.value = false
    end
  end

  -- Apply Lower Frame
  if lower_frame_index == 1 then
    -- "<Change Nothing>" - do not change visibility or active frame
  elseif lower_frame_index == 2 then
    app_window.lower_frame_is_visible = false  -- "<Hide>"
  else
    app_window.active_lower_frame = views_lower[lower_frame_index - 2].frame
    app_window.lower_frame_is_visible = true
  end

  -- Apply Visibility Toggles
  app_window.sample_record_dialog_is_visible = step_entry.sample_record_visible.value or false
  app_window.disk_browser_is_visible = step_entry.disk_browser_visible.value or false
  app_window.instrument_box_is_visible = step_entry.instrument_box_visible.value or false
  app_window.pattern_matrix_is_visible = step_entry.pattern_matrix_visible.value or false
  app_window.pattern_advanced_edit_is_visible = step_entry.pattern_advanced_edit_visible.value or false
end

function cycle_dynamic_view(dv)
  local current_time = os.clock()
  local debounce_delay = 0.2 -- 200 milliseconds

  if (current_time - last_cycled_time[dv]) < debounce_delay then
    -- Not enough time has passed since the last cycle, ignore the call
    return
  end

  last_cycled_time[dv] = current_time

  local app_window = renoise.app().window

  -- Reset current steps of other dynamic views
  for i = 1, dynamic_views_count do
    if i ~= dv then
      current_steps[i] = 0
    end
  end

  local steps_count = 0
  local max_steps = steps_per_view
  local configured_steps = {}

  local dynamic_view = preferences.PakettiDynamicViews[dv]

  -- Determine the list of configured steps
  for step = 1, max_steps do
    local step_entry = dynamic_view.steps[step]

    local upper_frame_index = step_entry.upper_frame_index.value
    local middle_frame_index = step_entry.middle_frame_index.value
    local lower_frame_index = step_entry.lower_frame_index.value

    if upper_frame_index > 1 or middle_frame_index > 1 or lower_frame_index > 1 then
      table.insert(configured_steps, step)
    end
  end

  steps_count = #configured_steps

  if steps_count > 0 then
    -- Check if current view matches any step in the dynamic view
    local current_view_matches = false
    for _, step in ipairs(configured_steps) do
      local step_entry = dynamic_view.steps[step]

      local upper_frame_index = step_entry.upper_frame_index.value
      local middle_frame_index = step_entry.middle_frame_index.value
      local lower_frame_index = step_entry.lower_frame_index.value

      -- Extract checkbox states for the step
      local sample_recorder_visible = step_entry.sample_record_visible.value
      local disk_browser_visible = step_entry.disk_browser_visible.value
      local instrument_box_visible = step_entry.instrument_box_visible.value
      local pattern_matrix_visible = step_entry.pattern_matrix_visible.value
      local pattern_advanced_edit_visible = step_entry.pattern_advanced_edit_visible.value

      -- Get current application window states
      local app_sample_recorder_visible = app_window.sample_record_dialog_is_visible
      local app_disk_browser_visible = app_window.disk_browser_is_visible
      local app_instrument_box_visible = app_window.instrument_box_is_visible
      local app_pattern_matrix_visible = app_window.pattern_matrix_is_visible
      local app_pattern_advanced_edit_visible = app_window.pattern_advanced_edit_is_visible

      -- Compare frames
      local matches_upper = (upper_frame_index == 1) or
        (upper_frame_index == 2 and not app_window.upper_frame_is_visible) or
        (upper_frame_index > 2 and app_window.upper_frame_is_visible and
         app_window.active_upper_frame == views_upper[upper_frame_index - 2].frame)

      local matches_middle = (middle_frame_index == 1) or
        (middle_frame_index > 1 and app_window.active_middle_frame == views_middle[middle_frame_index - 1].frame)

      local matches_lower = (lower_frame_index == 1) or
        (lower_frame_index == 2 and not app_window.lower_frame_is_visible) or
        (lower_frame_index > 2 and app_window.lower_frame_is_visible and
         app_window.active_lower_frame == views_lower[lower_frame_index - 2].frame)

      -- Compare checkbox states
      local matches_sample_recorder = (sample_recorder_visible == app_sample_recorder_visible)
      local matches_disk_browser = (disk_browser_visible == app_disk_browser_visible)
      local matches_instrument_box = (instrument_box_visible == app_instrument_box_visible)
      local matches_pattern_matrix = (pattern_matrix_visible == app_pattern_matrix_visible)
      local matches_pattern_advanced_edit = (pattern_advanced_edit_visible == app_pattern_advanced_edit_visible)

      if matches_upper and matches_middle and matches_lower and
         matches_sample_recorder and matches_disk_browser and
         matches_instrument_box and matches_pattern_matrix and
         matches_pattern_advanced_edit then
        current_steps[dv] = step
        current_view_matches = true
        break
      end
    end

    -- If current view does not match any step, reset to start from the beginning
    if not current_view_matches then
      current_steps[dv] = 0
    end

    -- Get the current step index in the configured_steps array
    local current_step_index = nil
    for i, step in ipairs(configured_steps) do
      if step == current_steps[dv] then
        current_step_index = i
        break
      end
    end

    -- If not in any step, start from the beginning
    if not current_step_index then
      current_step_index = 1
    else
      -- Move to next configured step
      current_step_index = (current_step_index % steps_count) + 1
    end

    local next_step = configured_steps[current_step_index]

    apply_dynamic_view_step(dv, next_step)
    current_steps[dv] = next_step

    -- Get the middle frame label
    local step_entry = dynamic_view.steps[next_step]
    local middle_frame_index = step_entry.middle_frame_index.value
    local middle_frame_label = ""
    if middle_frame_index > 1 then
      middle_frame_label = views_middle[middle_frame_index - 1].label
    else
      middle_frame_label = "<Change Nothing>"
    end

    -- Format dynamic view and step numbers with leading zeros
    local step_str = string.format("%02d", next_step)

    local status_message = "Paketti Dynamic View " .. string.format("%02d", dv) .. " - Showing Step " .. step_str .. ": " .. middle_frame_label
    renoise.app():show_status(status_message)
  else
    renoise.app():show_status("Paketti Dynamic View " .. string.format("%02d", dv) .. " - No steps to cycle through.")
  end
end

local function build_step_column(vb, dv, step, update_steps_label)
  local dynamic_view = preferences.PakettiDynamicViews[dv]
  local step_entry = dynamic_view.steps[step]
  
  return vb:column {
    vb:popup {
      items = build_options(views_upper, true),
      bind = step_entry.upper_frame_index,
      width = 150,
      notifier = function()
        apply_dynamic_view_step(dv, step)
        update_steps_label()
        -- Preferences are saved automatically
      end
    },
    vb:popup {
      items = build_options(views_middle, false),
      bind = step_entry.middle_frame_index,
      width = 150,
      notifier = function()
        apply_dynamic_view_step(dv, step)
        update_steps_label()
      end
    },
    vb:popup {
      items = build_options(views_lower, true),
      bind = step_entry.lower_frame_index,
      width = 150,
      notifier = function()
        apply_dynamic_view_step(dv, step)
        update_steps_label()
      end
    },
    vb:row {
      vb:checkbox {
        bind = step_entry.instrument_box_visible,
        notifier = function(value)
          step_entry.instrument_box_visible.value = value
          if value then
            step_entry.disk_browser_visible.value = true
          end
          apply_dynamic_view_step(dv, step)
          update_steps_label()
        end
      },
      vb:text { text = "Instrument Box Visible" }
    },
    vb:row {
      vb:checkbox {
        bind = step_entry.disk_browser_visible,
        notifier = function()
          apply_dynamic_view_step(dv, step)
          update_steps_label()
        end
      },
      vb:text { text = "Disk Browser Visible" }
    },
    vb:row {
      vb:checkbox {
        bind = step_entry.sample_record_visible,
        notifier = function()
          apply_dynamic_view_step(dv, step)
          update_steps_label()
        end
      },
      vb:text { text = "Sample Recorder Visible" }
    },
    vb:row {
      vb:checkbox {
        bind = step_entry.pattern_matrix_visible,
        notifier = function()
          apply_dynamic_view_step(dv, step)
          update_steps_label()
        end
      },
      vb:text { text = "Pattern Matrix Visible" }
    },
    vb:row {
      vb:checkbox {
        bind = step_entry.pattern_advanced_edit_visible,
        notifier = function()
          apply_dynamic_view_step(dv, step)
          update_steps_label()
        end
      },
      vb:text { text = "Pattern Advanced Edit Visible" }
    }
  }
end

local function build_dynamic_view_ui(vb, dv)
  local dynamic_view = preferences.PakettiDynamicViews[dv]
  local steps_label = vb:text { text = "Steps in Cycle: 0" }

  local function update_steps_label()
    local steps_count = 0
    for step = 1, steps_per_view do
      local step_entry = dynamic_view.steps[step]
      local upper_frame_index = step_entry.upper_frame_index.value
      local middle_frame_index = step_entry.middle_frame_index.value
      local lower_frame_index = step_entry.lower_frame_index.value
      if upper_frame_index > 1 or middle_frame_index > 1 or lower_frame_index > 1 then
        steps_count = steps_count + 1
      end
    end
    steps_label.text = "Steps in Cycle: " .. steps_count
  end

  local function clear_checkboxes()
    for step = 1, steps_per_view do
      local step_entry = dynamic_view.steps[step]
      step_entry.sample_record_visible.value = false
      step_entry.disk_browser_visible.value = false
      step_entry.instrument_box_visible.value = false
      step_entry.pattern_matrix_visible.value = false
      step_entry.pattern_advanced_edit_visible.value = false
    end
    update_steps_label()
    -- Preferences are saved automatically
  end

  -- Initialize the label
  update_steps_label()

  return vb:column {
    vb:row {
      vb:text { text = "Paketti Dynamic View " .. string.format("%02d", dv), font = "bold" },
      steps_label
    },
    vb:row {
      build_step_column(vb, dv, 1, update_steps_label),
      build_step_column(vb, dv, 2, update_steps_label),
      build_step_column(vb, dv, 3, update_steps_label),
      build_step_column(vb, dv, 4, update_steps_label),
      build_step_column(vb, dv, 5, update_steps_label),
      build_step_column(vb, dv, 6, update_steps_label),
      build_step_column(vb, dv, 7, update_steps_label),
      build_step_column(vb, dv, 8, update_steps_label)
    },
    vb:row {
      vb:button { text = "Cycle", height = 10, width = 100, pressed = function() cycle_dynamic_view(dv) end },
      vb:button { text = "Clear All Checkboxes", height = 10, width = 160, pressed = function() clear_checkboxes() end }
    }
  }
end

-- Assemble the dialog interface for dynamic views
function build_dialog_interface(vb, start_dv, end_dv, close_dialog)
  local interface = vb:column {}
  for dv = start_dv, end_dv do
    interface:add_child(build_dynamic_view_ui(vb, dv))
    interface:add_child(vb:space { height = 5 })
  end
  -- Add Save, Save & Close, and Load buttons to the bottom
  interface:add_child(vb:row {
    vb:button { text = "Save Dynamic Views as a textfile", height = 20, width = 150, pressed = function() save_dynamic_views_to_txt() end },
    vb:button { text = "Load Dynamic Views from a textfile", height = 20, width = 150, pressed = function() load_dynamic_views_from_txt() end },
    vb:button { text = "Close", height = 20, width = 100, pressed = function()
      close_dialog()
    end }
  })
  return interface
end

-- Dialog setup for dynamic views
function showDynamicViewDialog(start_dv, end_dv)
  local vb = renoise.ViewBuilder()
  local dialog_content
  local dialog

  local function close_dialog()
    if dialog and dialog.visible then
      dialog:close()
    end
  end

  dialog_content = build_dialog_interface(vb, start_dv, end_dv, close_dialog)
  dialog = renoise.app():show_custom_dialog("Paketti Dynamic View Preferences Dialog " .. start_dv .. "-" .. end_dv, dialog_content)
end

function save_dynamic_views_to_txt()
  local file_path = renoise.app():prompt_for_filename_to_write("txt", "Save Dynamic Views as .txt")
  if not file_path then return end

  local file = io.open(file_path, "w")
  if not file then
    renoise.app():show_status("Error opening file for saving.")
    return
  end

  for dv = 1, dynamic_views_count do
    local dynamic_view = preferences.PakettiDynamicViews[dv]
    file:write("Dynamic View " .. string.format("%02d", dv) .. ":\n")
    for step = 1, steps_per_view do
      local step_entry = dynamic_view.steps[step]
      local upper = step_entry.upper_frame_index.value
      local middle = step_entry.middle_frame_index.value
      local lower = step_entry.lower_frame_index.value
      local disk_browser = tostring(step_entry.disk_browser_visible.value)
      local instrument_box = tostring(step_entry.instrument_box_visible.value)
      local sample_recorder = tostring(step_entry.sample_record_visible.value)
      local pattern_matrix = tostring(step_entry.pattern_matrix_visible.value)
      local advanced_edit = tostring(step_entry.pattern_advanced_edit_visible.value)

      file:write(string.format("  Step %d - Upper: %d, Middle: %d, Lower: %d, Disk Browser: %s, Instrument Box: %s, Sample Recorder: %s, Pattern Matrix: %s, Pattern Advanced Edit: %s\n",
        step, upper, middle, lower, disk_browser, instrument_box, sample_recorder, pattern_matrix, advanced_edit))
    end
  end

  file:close()
  renoise.app():show_status("Dynamic Views saved successfully.")
end

function load_dynamic_views_from_txt()
  local file_path = renoise.app():prompt_for_filename_to_read({"txt"}, "Load Dynamic Views from .txt")
  if not file_path then return end

  local file = io.open(file_path, "r")
  if not file then
    renoise.app():show_status("Error opening file for loading.")
    return
  end

  local dv = nil
  for line in file:lines() do
    local dv_number = string.match(line, "^Dynamic View (%d+):")
    if dv_number then
      dv = tonumber(dv_number)
    else
      if dv then
        local dynamic_view = preferences.PakettiDynamicViews[dv]
        local step, upper, middle, lower, disk_browser, instrument_box, sample_recorder, pattern_matrix, advanced_edit = string.match(
          line,
          "Step (%d+) %- Upper: (%d+), Middle: (%d+), Lower: (%d+), Disk Browser: (%w+), Instrument Box: (%w+), Sample Recorder: (%w+), Pattern Matrix: (%w+), Pattern Advanced Edit: (%w+)"
        )
        if step then
          step = tonumber(step)
          local step_entry = dynamic_view.steps[step]
          step_entry.upper_frame_index.value = tonumber(upper)
          step_entry.middle_frame_index.value = tonumber(middle)
          step_entry.lower_frame_index.value = tonumber(lower)
          step_entry.disk_browser_visible.value = (disk_browser == "true")
          step_entry.instrument_box_visible.value = (instrument_box == "true")
          step_entry.sample_record_visible.value = (sample_recorder == "true")
          step_entry.pattern_matrix_visible.value = (pattern_matrix == "true")
          step_entry.pattern_advanced_edit_visible.value = (advanced_edit == "true")
        end
      end
    end
  end

  file:close()
  -- Preferences are saved automatically
  renoise.app():show_status("Dynamic Views loaded successfully.")
end


function set_dynamic_view_step_from_knob(dv, knob_value)
  local steps_count = 0
  local max_steps = steps_per_view
  local configured_steps = {}

  local dynamic_view = preferences.PakettiDynamicViews[dv]

  -- Determine the list of configured steps
  for step = 1, max_steps do
    local step_entry = dynamic_view.steps[step]

    local upper_frame_index = step_entry.upper_frame_index.value
    local middle_frame_index = step_entry.middle_frame_index.value
    local lower_frame_index = step_entry.lower_frame_index.value

    -- Check checkboxes
    local has_checkbox_selected = 
      step_entry.sample_record_visible.value or
      step_entry.disk_browser_visible.value or
      step_entry.instrument_box_visible.value or
      step_entry.pattern_matrix_visible.value or
      step_entry.pattern_advanced_edit_visible.value

    if upper_frame_index > 1 or middle_frame_index > 1 or lower_frame_index > 1 or has_checkbox_selected then
      table.insert(configured_steps, step)
    end
  end

  steps_count = #configured_steps

  if steps_count > 0 then
    -- Map knob value to configured steps
    local index = math.floor((knob_value / 127) * (steps_count - 1) + 0.5) + 1
    if index < 1 then index = 1 end
    if index > steps_count then index = steps_count end
    local step = configured_steps[index]

    apply_dynamic_view_step(dv, step)
    current_steps[dv] = step

    -- Optionally, show status message
    local step_entry = dynamic_view.steps[step]
    local middle_frame_index = step_entry.middle_frame_index.value
    local middle_frame_label = ""
    if middle_frame_index > 1 then
      middle_frame_label = views_middle[middle_frame_index - 1].label
    else
      middle_frame_label = "<Change Nothing>"
    end
    local status_message = "Paketti Dynamic View " .. string.format("%02d", dv) .. " - Set to Step " .. string.format("%02d", step) .. ": " .. middle_frame_label
    renoise.app():show_status(status_message)
  else
    renoise.app():show_status("Paketti Dynamic View " .. string.format("%02d", dv) .. " - No configured steps to select.")
  end
end

-- Add menu entries and keybindings for each dynamic view
for dv = 1, dynamic_views_count do
  local dv_id = string.format("%02d", dv)
  renoise.tool():add_keybinding{name="Global:Paketti:Cycle Paketti Dynamic View " .. dv_id, invoke=function() cycle_dynamic_view(dv) end}
  renoise.tool():add_midi_mapping{name="Paketti:Cycle Paketti Dynamic View " .. dv_id, invoke=function() cycle_dynamic_view(dv) end}
  renoise.tool():add_midi_mapping{name="Paketti:Midi Paketti Dynamic View " .. dv_id .. " x[Knob]", 
    invoke=function(midi_message)
      if midi_message:is_abs_value() then
        local knob_value = midi_message.int_value
        set_dynamic_view_step_from_knob(dv, knob_value)
      end
    end}
end

renoise.tool():add_keybinding{name="Global:Paketti:Paketti Dynamic View Preferences Dialog 1-4...", invoke=function() showDynamicViewDialog(1, 4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Dynamic View Preferences Dialog 5-8...", invoke=function() showDynamicViewDialog(5, 8) end}

renoise.tool():add_midi_mapping{name="Paketti:Paketti Dynamic View Preferences Dialog 1-4...", invoke=function() showDynamicViewDialog(1, 4) end}
renoise.tool():add_midi_mapping{name="Paketti:Paketti Dynamic View Preferences Dialog 5-8...", invoke=function() showDynamicViewDialog(5, 8) end}

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:!Preferences..:Paketti Dynamic View Preferences Dialog 1-4...",invoke=function() showDynamicViewDialog(1, 4) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:!Preferences..:Paketti Dynamic View Preferences Dialog 5-8...",invoke=function() showDynamicViewDialog(5, 8) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:!Preferences..:Paketti Save Dynamic Views as a textfile", invoke=function() save_dynamic_views_to_txt() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:!Preferences..:Paketti Load Dynamic Views from a textfile", invoke=function() load_dynamic_views_from_txt() end}

