-- Paketti Pattern Effect Command CheatSheet

-- Initialize dialog variable
local dialog = nil

-- Use your existing preferences without overwriting them
local preferences = renoise.tool().preferences

-- Load and Save Preferences Functions

function load_Cheatsheetpreferences()
  if io.exists("preferences.xml") then
    preferences:load_from("preferences.xml")
  end
end

function save_Cheatsheetpreferences()
  preferences:save_as("preferences.xml")
  renoise.app():show_status("CheatSheet preferences saved")
end


-- Complete list of effects
local effects = {
  {"0A", "-Axy", "Set arpeggio, x/y = first/second note offset in semitones"},
  {"0U", "-Uxx", "Slide Pitch up by xx 1/16ths of a semitone"},
  {"0D", "-Dxx", "Slide Pitch down by xx 1/16ths of a semitone"},
  {"0G", "-Gxx", "Glide towards given note by xx 1/16ths of a semitone"},
  {"0I", "-Ixx", "Fade Volume in by xx volume units"},
  {"0O", "-Oxx", "Fade Volume out by xx volume units"},
  {"0C", "-Cxy", "Cut volume to x after y ticks (x frandomiolume factor: 0=0%, F=100%)"},
  {"0Q", "-Qxx", "Delay note by xx ticks"},
  {"0M", "-Mxx", "Set note volume to xx"},
  {"0S", "-Sxx", "Trigger sample slice number xx or offset xx"},
  {"0B", "-Bxx", "Play Sample Backwards (B00) or forwards again (B01)"},
  {"0R", "-Rxy", "Retrigger line every y ticks with volume factor x"},
  {"0Y", "-Yxx", "Maybe trigger line with probability xx, 00 = mutually exclusive note columns"},
  {"0Z", "-Zxx", "Trigger Phrase xx (Phrase Number (01-7E), 00 = none, 7F = keymap)"},
  {"0V", "-Vxy", "Set Vibrato x = speed, y = depth; x=(0-F); y=(0-F)"},
  {"0T", "-Txy", "Set Tremolo x = speed, y = depth"},
  {"0N", "-Nxy", "Set Auto Pan, x = speed, y = depth"},
  {"0E", "-Exx", "Set Active Sample Envelope's Position to Offset XX"},
  {"0L", "-Lxx", "Set Track Volume Level, 00 = -INF, FF = +3dB"},
  {"0P", "-Pxx", "Set Track Pan, 00 = full left, 80 = center, FF = full right"},
  {"0W", "-Wxx", "Set Track Surround Width, 00 = Min, FF = Max"},
  {"0J", "-Jxx", "Set Track Routing, 01 upwards = hardware channels, FF downwards = parent groups"},
  {"0X", "-Xxx", "Stop all notes and FX (xx = 00), or only effect xx (xx > 00)"},
  {"ZT", "ZTxx", "Set tempo to xx BPM (14-FF, 00 = stop song)"},
  {"ZL", "ZLxx", "Set Lines Per Beat (LPB) to xx lines"},
  {"ZK", "ZKxx", "Set Ticks Per Line (TPL) to xx ticks (01-10)"},
  {"ZG", "ZGxx", "Enable (xx = 01) or disable (xx = 00) Groove"},
  {"ZB", "ZBxx", "Break pattern and jump to line xx in next"},
  {"ZD", "ZDxx", "Delay (pause) pattern for xx lines"}
}


-- Randomization Functions for Effect Columns

function randomizeSmatterEffectColumnCustom(effect_command, fill_percentage, min_value, max_value)
  local song = renoise.song()
  local selection = song.selection_in_pattern
  local randomize_switch = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value
  local dont_overwrite = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeDontOverwrite.value
  local randomize_whole_track_cb = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value  -- Read the preference

  if min_value > max_value then
    min_value, max_value = max_value, min_value
  end

  local randomize = function()
    if randomize_switch then
      return string.format("%02X", math.random() < 0.5 and min_value or max_value)
    else
      return string.format("%02X", math.random(min_value, max_value))
    end
  end

  local should_apply = function()
    return math.random(100) <= fill_percentage
  end

  local apply_command = function(line, column_index)
    local effect_column = line:effect_column(column_index)
    if effect_column then
      if dont_overwrite then
        if effect_column.is_empty and should_apply() then
          effect_column.number_string = effect_command
          effect_column.amount_string = randomize()
        end
      else
        if should_apply() then
          effect_column.number_string = effect_command
          effect_column.amount_string = randomize()
        else
          effect_column:clear()
        end
      end
    end
  end

  if selection then
    -- Apply to selection
    for line_index = selection.start_line, selection.end_line do
      for t = selection.start_track, selection.end_track do
        local track = song:pattern(song.selected_pattern_index):track(t)
        local trackvis = song:track(t)
        local note_columns_visible = trackvis.visible_note_columns
        local effect_columns_visible = trackvis.visible_effect_columns
        local total_columns_visible = note_columns_visible + effect_columns_visible

        local start_column = (t == selection.start_track) and selection.start_column or 1
        local end_column = (t == selection.end_track) and selection.end_column or total_columns_visible

        for col = start_column, end_column do
          local column_index = col - note_columns_visible
          if col > note_columns_visible and column_index > 0 and column_index <= effect_columns_visible then
            apply_command(track:line(line_index), column_index)
          end
        end
      end
    end
  else
    if randomize_whole_track_cb then
      -- Apply to whole track
      local track_index = song.selected_track_index
      for pattern_index = 1, #song.patterns do
        local pattern = song:pattern(pattern_index)
        local track = pattern:track(track_index)
        local lines = pattern.number_of_lines
        for line_index = 1, lines do
          for column_index = 1, song:track(track_index).visible_effect_columns do
            apply_command(track:line(line_index), column_index)
          end
        end
      end
    else
      -- Apply to current line
      local line = song.selected_line
      for column_index = 1, song.selected_track.visible_effect_columns do
        apply_command(line, column_index)
      end
    end
  end

  renoise.app():show_status("Random " .. effect_command .. " commands applied to effect columns.")
end

function randomizeSmatterEffectColumnC0(fill_percentage)
  randomizeSmatterEffectColumnCustom("0C", fill_percentage, 0x00, 0x0F)
end

function randomizeSmatterEffectColumnB0(fill_percentage)
  randomizeSmatterEffectColumnCustom("0B", fill_percentage, 0x00, 0x01)
end


-- Function to ensure visibility of specific columns (volume, panning, delay, samplefx)
function sliderVisible(column)
  local s = renoise.song()
  if s.selection_in_pattern then
    for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
      local track = s:track(t)
      if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
        if column == "volume" then
          track.volume_column_visible = true
        elseif column == "panning" then
          track.panning_column_visible = true
        elseif column == "delay" then
          track.delay_column_visible = true
        elseif column == "samplefx" then
          track.sample_effects_column_visible = true
        end
      end
    end
  else
    local track = s.selected_track
    if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
      if column == "volume" then
        track.volume_column_visible = true
      elseif column == "panning" then
        track.panning_column_visible = true
      elseif column == "delay" then
        track.delay_column_visible = true
      elseif column == "samplefx" then
        track.sample_effects_column_visible = true
      end
    end
  end
end

-- Function to ensure effect columns are visible
function sliderVisibleEffect()
  local s = renoise.song()
  if s.selection_in_pattern then
    for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
      local track = s:track(t)
      if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
        track.visible_effect_columns = math.max(track.visible_effect_columns, 1)
      end
    end
  else
    local track = s.selected_track
    if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
      track.visible_effect_columns = math.max(track.visible_effect_columns, 1)
    end
  end
end

-- Randomize functions for note columns
function randomizeNoteColumn(column_name)
  local s = renoise.song()
  local min_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value
  local max_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value
  local randomize_switch = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value

  if min_value > max_value then
    min_value, max_value = max_value, min_value
  end

  sliderVisible(column_name)
  local column_max_value = 0xFF
  if column_name == "volume_value" or column_name == "panning_value" or column_name == "effect_amount_value" then
    column_max_value = 0x80
  end

  if max_value > column_max_value then
    max_value = column_max_value
  end
  if min_value < 0 then
    min_value = 0
  end

  local randomize_whole_track_cb = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value
  local fill_percentage = preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value
  local should_apply = function()
    return math.random(100) <= fill_percentage
  end

  local random_value = function()
    if randomize_switch then
      return math.random() < 0.5 and min_value or max_value
    else
      return math.random(min_value, max_value)
    end
  end

  local is_subcolumn_not_empty = function(note_column)
    if column_name == "volume_value" then
      return note_column.volume_value ~= renoise.PatternLine.EMPTY_VOLUME
    elseif column_name == "panning_value" then
      return note_column.panning_value ~= renoise.PatternLine.EMPTY_PANNING
    elseif column_name == "delay_value" then
      return note_column.delay_value ~= renoise.PatternLine.EMPTY_DELAY
    elseif column_name == "effect_amount_value" then
      return note_column.effect_number_value ~= renoise.PatternLine.EMPTY_EFFECT_NUMBER or
             note_column.effect_amount_value ~= renoise.PatternLine.EMPTY_EFFECT_AMOUNT
    else
      return false
    end
  end

  if s.selection_in_pattern then
    -- Iterate over selection
    for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
      local track = s:track(t)
      if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
        local note_columns_visible = track.visible_note_columns
        local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
        local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or note_columns_visible
        for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
          for col = start_column, end_column do
            if col <= note_columns_visible then
              local note_column = s:pattern(s.selected_pattern_index):track(t):line(i).note_columns[col]
              if note_column and is_subcolumn_not_empty(note_column) and should_apply() then
                note_column[column_name] = random_value()
              end
            end
          end
        end
      end
    end
  else
    if not randomize_whole_track_cb then
      -- Randomize current line
      local note_column = s.selected_line:note_column(s.selected_note_column_index)
      if note_column and is_subcolumn_not_empty(note_column) then
        note_column[column_name] = random_value()
      end
    else
      -- Randomize whole track
      local track_index = s.selected_track_index
      local track = s:track(track_index)
      if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
        for pattern_index = 1, #s.patterns do
          local pattern = s:pattern(pattern_index)
          local lines = pattern.number_of_lines
          local note_columns_visible = track.visible_note_columns
          for i = 1, lines do
            for col = 1, note_columns_visible do
              local note_column = pattern:track(track_index):line(i).note_columns[col]
              if note_column and is_subcolumn_not_empty(note_column) and should_apply() then
                note_column[column_name] = random_value()
              end
            end
          end
        end
      end
    end
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

function randomizeEffectAmount()
  local s = renoise.song()
  local min_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value
  local max_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value
  local randomize_switch = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value

  if min_value > max_value then
    min_value, max_value = max_value, min_value
  end

  sliderVisibleEffect()

  local randomize_whole_track_cb = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value
  local fill_percentage = preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value
  local should_apply = function()
    return math.random(100) <= fill_percentage
  end

  local random_value = function()
    if randomize_switch then
      return math.random() < 0.5 and min_value or max_value
    else
      return math.random(min_value, max_value)
    end
  end

  if s.selection_in_pattern then
    for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
      local track = s:track(t)
      if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
        local note_columns_visible = track.visible_note_columns
        local effect_columns_visible = track.visible_effect_columns
        local total_columns_visible = note_columns_visible + effect_columns_visible
        local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or note_columns_visible + 1
        local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or total_columns_visible
        for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
          for col = start_column, end_column do
            local column_index = col - note_columns_visible
            if column_index > 0 and column_index <= effect_columns_visible then
              local effect_column = s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(column_index)
              if effect_column and not effect_column.is_empty and should_apply() then
                effect_column.amount_value = random_value()
              end
            end
          end
        end
      end
    end
  else
    if not randomize_whole_track_cb then
      -- Randomize current line
      local effect_column = s.selected_line:effect_column(s.selected_effect_column_index)
      if effect_column and not effect_column.is_empty then
        effect_column.amount_value = random_value()
      end
    else
      -- Randomize whole track
      local track_index = s.selected_track_index
      local track = s:track(track_index)
      if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
        for pattern_index = 1, #s.patterns do
          local pattern = s:pattern(pattern_index)
          local lines = pattern.number_of_lines
          local effect_columns_visible = track.visible_effect_columns
          for i = 1, lines do
            for col = 1, effect_columns_visible do
              local effect_column = pattern:track(track_index):line(i):effect_column(col)
              if effect_column and not effect_column.is_empty and should_apply() then
                effect_column.amount_value = random_value()
              end
            end
          end
        end
      end
    end
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Modified effect_write function with randomization logic

function effect_write(effect, status, command, min_value, max_value)
  local s = renoise.song()
  local a = renoise.app()
  local w = a.window

  -- Retrieve randomization preferences
  local randomize_cb = preferences.pakettiCheatSheet.pakettiCheatSheetRandomize.value
  local fill_percentage = preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value
  local randomize_whole_track_cb = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value
  local randomize_switch = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value
  local dont_overwrite = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeDontOverwrite.value

  min_value = min_value or preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value
  max_value = max_value or preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value

  if min_value > max_value then
    min_value, max_value = max_value, min_value
  end

  local randomize = function()
    if randomize_switch then
      return string.format("%02X", math.random() < 0.5 and min_value or max_value)
    else
      return string.format("%02X", math.random(min_value, max_value))
    end
  end

  local should_apply = function()
    return math.random(100) <= fill_percentage
  end

  if randomize_cb then
    if effect == "0C" then
      status = "Random C00/C0F commands applied to the effect columns."
      randomizeSmatterEffectColumnC0(fill_percentage)
    elseif effect == "0B" then
      status = "Random B00/B01 commands applied to the effect columns."
      randomizeSmatterEffectColumnB0(fill_percentage)
    else
      status = "Random " .. effect .. " commands applied to the effect columns."
      randomizeSmatterEffectColumnCustom(effect, fill_percentage, min_value, max_value)
    end
  else
    -- Original logic without randomization
    if s.selection_in_pattern == nil then
      local ec = s.selected_effect_column
      if ec then
        ec.number_string = effect
      else
        return false
      end
    else
      for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
        local track = s:track(t)
        local note_columns_visible = track.visible_note_columns
        local effect_columns_visible = track.visible_effect_columns
        local total_columns_visible = note_columns_visible + effect_columns_visible

        local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or note_columns_visible + 1
        local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or total_columns_visible

        for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
          for col = start_column, end_column do
            local column_index = col - note_columns_visible
            if column_index > 0 and column_index <= effect_columns_visible then
              local effect_column = s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(column_index)
              if effect_column then
                effect_column.number_string = effect
              end
            end
          end
        end
      end
    end
  end
  a:show_status(status)
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- GUI elements
function CheatSheet()
  local vb = renoise.ViewBuilder()
  local a = renoise.app()
  local s = renoise.song()
  local w = a.window

  if dialog and dialog.visible then
    dialog:close()
    return
  end

  local eSlider = 137 -- Adjusted slider height

  local globalwidth = 50

  local wikitooltip = "http://tutorials.renoise.com/wiki/Pattern_Effect_Commands#Effect_Listing"
  local wikibutton = vb:button {
    width = globalwidth,
    text = "www",
    tooltip = wikitooltip,
    pressed = function()
      a:open_url(wikitooltip)
      renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    end
  }

  local effect_buttons = vb:column {}
  for _, effect in ipairs(effects) do
    local button = vb:button {
      width = globalwidth,
      text = effect[2],
      tooltip = effect[3],
      pressed = function()
        effect_write(effect[1], effect[2] .. " - " .. effect[3], effect[2], effect[4], effect[5])
        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
      end
    }
    local desc = vb:text {text = effect[3]}
    effect_buttons:add_child(vb:row {button, desc})
  end

  -- Randomization Preferences UI Elements
  local randomize_cb = vb:checkbox {
    value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomize.value,
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomize.value = v
     save_Cheatsheetpreferences()
    end
  }

  local fill_probability_text = vb:text {
    style = "strong",
    text = string.format("%d%% Fill Probability", preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value)
  }

  local fill_probability_slider = vb:slider {
    width = 300,
    min = 0,
    max = 1,
    value = preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value / 100,
    notifier = function(value)
      local percentage_value = math.floor(value * 100 + 0.5)
      if preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value ~= percentage_value then
        preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value = percentage_value
        fill_probability_text.text = string.format("%d%% Fill Probability", percentage_value)
         save_Cheatsheetpreferences()
      end
    end
  }

  local randomize_whole_track_cb = vb:checkbox {
    value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value,
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value = v
       save_Cheatsheetpreferences()
    end
  }

  local randomizeswitch_cb = vb:checkbox {
    value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value,
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value = v
       save_Cheatsheetpreferences()
    end
  }

  local dontoverwrite_cb = vb:checkbox {
    value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeDontOverwrite.value,
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeDontOverwrite.value = v
       save_Cheatsheetpreferences()
    end
  }

  -- Minimum Slider
  local min_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value

  local min_slider = vb:minislider {
    id = "min_slider_unique",
    width = 300,
    min = 0,
    max = 255,
    value = min_value,
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value = v
      vb.views["min_text_unique"].text = string.format("%02X", v)
      save_Cheatsheetpreferences()
    end
  }

  local min_text = vb:text {
    id = "min_text_unique",
    text = string.format("%02X", min_value)
  }

  local min_decrement_button = vb:button {
    text = "<",
    notifier = function()
      local current_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value
      if current_value > 0 then
        current_value = current_value - 1
        min_slider.value = current_value
      end
    end
  }

  local min_increment_button = vb:button {
    text = ">",
    notifier = function()
      local current_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value
      if current_value < 255 then
        current_value = current_value + 1
        min_slider.value = current_value
      end
    end
  }

  -- Maximum Slider
  local max_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value

  local max_slider = vb:minislider {
    id = "max_slider_unique",
    width = 300,
    min = 0,
    max = 255,
    value = max_value,
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value = v
      vb.views["max_text_unique"].text = string.format("%02X", v)
       save_Cheatsheetpreferences()
    end
  }

  local max_text = vb:text {
    id = "max_text_unique",
    text = string.format("%02X", max_value)
  }

  local max_decrement_button = vb:button {
    text = "<",
    notifier = function()
      local current_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value
      if current_value > 0 then
        current_value = current_value - 1
        max_slider.value = current_value
      end
    end
  }

  local max_increment_button = vb:button {
    text = ">",
    notifier = function()
      local current_value = preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value
      if current_value < 255 then
        current_value = current_value + 1
        max_slider.value = current_value
      end
    end
  }

  local randomize_section = vb:column {
    vb:text {style = "strong", text = "Randomize Effect Value content"},
    vb:horizontal_aligner {mode = "left", randomize_cb, vb:text {text = "Randomize"}},
    vb:horizontal_aligner {mode = "left", fill_probability_slider, fill_probability_text},
    vb:horizontal_aligner {mode = "left", randomize_whole_track_cb, vb:text {text = "Randomize whole track if nothing is selected"}},
    vb:horizontal_aligner {mode = "left", randomizeswitch_cb, vb:text {text = "Randomize Min/Max Only"}},
    vb:horizontal_aligner {mode = "left", dontoverwrite_cb, vb:text {text = "Don't Overwrite Existing Data"}},
    vb:horizontal_aligner {mode = "left", vb:text {text = "Min", font = "mono"}, min_decrement_button, min_increment_button, min_slider, min_text},
    vb:horizontal_aligner {mode = "left", vb:text {text = "Max", font = "mono"}, max_decrement_button, max_increment_button, max_slider, max_text},
    vb:button {text = "Close", width = globalwidth, pressed = function()
      dialog:close()
      renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    end}
  }

  -- Sliders with Randomize Buttons
  local sliders = vb:column {
    -- Volume
    vb:horizontal_aligner {
      mode = "right",
      vb:text {style = "strong", font = "bold", text = "Volume"},
      vb:button {
        text = "R",
        tooltip = "Randomize Volume",
        notifier = function()
          randomizeNoteColumn("volume_value")
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      },
      vb:minislider {
        id = "volumeslider",
        width = 50,
        height = eSlider,
        min = 0,
        max = 0x80,
        notifier = function(v)
          sliderVisible("volume")
          local s = renoise.song()
          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
                local note_columns_visible = track.visible_note_columns
                local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
                local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or note_columns_visible
                for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                  for col = start_column, end_column do
                    if col <= note_columns_visible then
                      local note_column = s:pattern(s.selected_pattern_index):track(t):line(i).note_columns[col]
                      if note_column then
                        note_column.volume_value = v
                      end
                    end
                  end
                end
              end
            end
          else
            if s.selected_note_column then
              s.selected_note_column.volume_value = v
            end
          end
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      }
    },
    -- Panning
    vb:horizontal_aligner {
      mode = "right",
      vb:text {style = "strong", font = "bold", text = "Panning"},
      vb:button {
        text = "R",
        tooltip = "Randomize Panning",
        notifier = function()
          randomizeNoteColumn("panning_value")
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      },
      vb:minislider {
        id = "panningslider",
        width = 50,
        height = eSlider,
        min = 0,
        max = 0x80,
        notifier = function(v)
          sliderVisible("panning")
          local s = renoise.song()
          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
                local note_columns_visible = track.visible_note_columns
                local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
                local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or note_columns_visible
                for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                  for col = start_column, end_column do
                    if col <= note_columns_visible then
                      local note_column = s:pattern(s.selected_pattern_index):track(t):line(i).note_columns[col]
                      if note_column then
                        note_column.panning_value = v
                      end
                    end
                  end
                end
              end
            end
          else
            if s.selected_note_column then
              s.selected_note_column.panning_value = v
            end
          end
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      }
    },
    -- Delay
    vb:horizontal_aligner {
      mode = "right",
      vb:text {style = "strong", font = "bold", text = "Delay"},
      vb:button {
        text = "R",
        tooltip = "Randomize Delay",
        notifier = function()
          randomizeNoteColumn("delay_value")
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      },
      vb:minislider {
        id = "delayslider",
        width = 50,
        height = eSlider,
        min = 0,
        max = 0xFF,
        notifier = function(v)
          sliderVisible("delay")
          local s = renoise.song()
          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
                local note_columns_visible = track.visible_note_columns
                local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
                local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or note_columns_visible
                for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                  for col = start_column, end_column do
                    if col <= note_columns_visible then
                      local note_column = s:pattern(s.selected_pattern_index):track(t):line(i).note_columns[col]
                      if note_column then
                        note_column.delay_value = v
                      end
                    end
                  end
                end
              end
            end
          else
            if s.selected_note_column then
              s.selected_note_column.delay_value = v
            end
          end
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      }
    },
    -- Sample FX
    vb:horizontal_aligner {
      mode = "right",
      vb:text {style = "strong", font = "bold", text = "Sample FX"},
      vb:button {
        text = "R",
        tooltip = "Randomize Sample FX",
        notifier = function()
          randomizeNoteColumn("effect_amount_value")
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      },
      vb:minislider {
        id = "samplefxslider",
        width = 50,
        height = eSlider,
        min = 0,
        max = 0x80,
        notifier = function(v)
          sliderVisible("samplefx")
          local s = renoise.song()
          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
                local note_columns_visible = track.visible_note_columns
                local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
                local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or note_columns_visible
                for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                  for col = start_column, end_column do
                    if col <= note_columns_visible then
                      local note_column = s:pattern(s.selected_pattern_index):track(t):line(i).note_columns[col]
                      if note_column then
                        note_column.effect_amount_value = v
                      end
                    end
                  end
                end
              end
            end
          else
            if s.selected_note_column then
              s.selected_note_column.effect_amount_value = v
            end
          end
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      }
    },
    -- Effect
    vb:horizontal_aligner {
      mode = "right",
      vb:text {style = "strong", font = "bold", text = "Effect"},
      vb:button {
        text = "R",
        tooltip = "Randomize Effect Amount",
        notifier = function()
          randomizeEffectAmount()
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      },
      vb:minislider {
        id = "effectslider",
        width = 50,
        height = eSlider,
        min = 0,
        max = 0xFF,
        notifier = function(v)
          sliderVisibleEffect()
          local s = renoise.song()
          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
                local note_columns_visible = track.visible_note_columns
                local effect_columns_visible = track.visible_effect_columns
                local total_columns_visible = note_columns_visible + effect_columns_visible
                local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or note_columns_visible + 1
                local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or total_columns_visible
                for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                  for col = start_column, end_column do
                    local column_index = col - note_columns_visible
                    if column_index > 0 and column_index <= effect_columns_visible then
                      local effect_column = s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(column_index)
                      if effect_column then
                        effect_column.amount_value = v
                      end
                    end
                  end
                end
              end
            end
          else
            if s.selected_effect_column then
              s.selected_effect_column.amount_value = v
            elseif s.selected_line then
              s.selected_line.effect_columns[1].amount_value = v
            end
          end
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      }
    }
  }

  local left_column = vb:column {
    effect_buttons,
    randomize_section
  }

  local dialog_content = vb:row {
    left_column,
    sliders
  }

  local function keyhandler_func(dialog, key)
    if key.name == "!" then
      dialog:close()
      renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    else
      return key
    end
  end

  dialog = a:show_custom_dialog("Paketti Pattern Effect Command CheatSheet", dialog_content, keyhandler_func)
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Keybinding to open the CheatSheet
renoise.tool():add_keybinding {name = "Global:Paketti:Pattern Effect Command CheatSheet", invoke = CheatSheet}

