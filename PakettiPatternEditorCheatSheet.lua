local effects = {
  {"0A", "-Axy", "Set arpeggio, x/y = first/second note offset in semitones"},
  {"0U", "-Uxx", "Slide Pitch up by xx 1/16ths of a semitone"},
  {"0D", "-Dxx", "Slide Pitch down by xx 1/16ths of a semitone"},
  {"0G", "-Gxx", "Glide towards given note by xx 1/16ths of a semitone"},
  {"0I", "-Ixx", "Fade Volume in by xx volume units"},
  {"0O", "-Oxx", "Fade Volume out by xx volume units"},
  {"0C", "-Cxy", "Cut volume to x after y ticks (x = volume factor: 0=0%, F=100%)", 0x00, 0x0F},
  {"0Q", "-Qxx", "Delay note by xx ticks"},
  {"0M", "-Mxx", "Set note volume to xx"},
  {"0S", "-Sxx", "Trigger sample slice number xx or offset xx"},
  {"0B", "-Bxx", "Play Sample Backwards (B00) or forwards again (B01) *", 0x00, 0x01},
  {"0R", "-Rxy", "Retrigger line every y ticks with volume factor x"},
  {"0Y", "-Yxx", "MaYbe trigger line with probability xx, 00 = mutually exclusive note columns"},
  {"0Z", "-Zxx", "Trigger Phrase xx (Phrase Number (01-7E), 00 = none, 7F = keymap) for a specific note"},
  {"0V", "-Vxy", "Set Vibrato x = speed, y = depth; x=(0-F); y=(0-F)*"},
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
  {"ZK", "ZKxx", "Set Ticks Per Line (TPL) to xx ticks (01-10)", 0x01, 0x0A},
  {"ZG", "ZGxx", "Enable (xx = 01) or disable (xx = 00) Groove", 0x00, 0x01},
  {"ZB", "ZBxx", "Break pattern and jump to line xx in next"},
  {"ZD", "ZDxx", "Delay (pause) pattern for xx lines"}
}

local dialog = nil

function load_preferences()
  if io.exists("preferences.xml") then
    preferences:load_from("preferences.xml")
  end
end

function save_preferences()
  preferences:save_as("preferences.xml")
  renoise.app():show_status("CheatSheet preferences saved")
end

function get_preference_value(preference, default_value)
  if preference == nil then
    return default_value
  else
    return preference
  end
end

-- Ensure visibility of specific columns (volume, panning, delay)
function sliderVisible(column)
  local s = renoise.song()
  if s.selection_in_pattern then
    for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
      local track = s:track(t)
      if track.type == renoise.Track.TRACK_TYPE_MASTER or track.type == renoise.Track.TRACK_TYPE_SEND or track.type == renoise.Track.TRACK_TYPE_GROUP then
        print("Track", t, "Does not have Note Columns, skipping.")
      else
        if column == "volume" then
          track.volume_column_visible = true
        elseif column == "panning" then
          track.panning_column_visible = true
        elseif column == "delay" then
          track.delay_column_visible = true
        end
      end
    end
  else
    local track = s.selected_track
    if track.type == renoise.Track.TRACK_TYPE_MASTER or track.type == renoise.Track.TRACK_TYPE_SEND or track.type == renoise.Track.TRACK_TYPE_GROUP then
      print("Track does not have Note Columns, skipping.")
    else
      if column == "volume" then
        track.volume_column_visible = true
      elseif column == "panning" then
        track.panning_column_visible = true
      elseif column == "delay" then
        track.delay_column_visible = true
      end
    end
  end
end

function randomizeSmatterEffectColumnCustom(effect_command, fill_percentage, min_value, max_value)
  local song = renoise.song()
  local selection = song.selection_in_pattern
  local randomize_switch = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value, false)
  local dont_overwrite = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeDontOverwrite.value, false)

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
    local track_index = song.selected_track_index
    for sequence_index, sequence in ipairs(song.sequencer.pattern_sequence) do
      if song:pattern(sequence).tracks[track_index] then
        local track = song:pattern(sequence).tracks[track_index]
        local trackvis = renoise.song().selected_track
        local lines = renoise.song().selected_pattern.number_of_lines
        for line_index = 1, lines do
          for column_index = 1, trackvis.visible_effect_columns do
            apply_command(track:line(line_index), column_index)
          end
        end
      end
    end
  end

  renoise.app():show_status("Random " .. effect_command .. " commands applied to effect columns of the selected track(s).")
end



function randomizeSmatterEffectColumnC0(fill_all)
  randomizeSmatterEffectColumnCustom("0C", fill_all, 0x00, 0x0F)
end

function randomizeSmatterEffectColumnB0(fill_all)
  randomizeSmatterEffectColumnCustom("0B", fill_all, 0x00, 0x01)
end

function effect_write(effect, status, command, min_value, max_value)
  local s = renoise.song()
  local a = renoise.app()
  local w = a.window
  local randomize_cb = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomize.value, false)
  local fill_all_cb = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value, false)
  local randomize_whole_track_cb = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value, false)
  min_value = min_value or get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value, 0)
  max_value = max_value or get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value, 255)
  if min_value > max_value then
    min_value, max_value = max_value, min_value
  end
  local randomize = function()
    return string.format("%02X", math.random(min_value, max_value))
  end

  if randomize_cb then
    if effect == "0C" then
      status = "Random C00/C0F commands applied to the first effect column of the selected track."
      randomizeSmatterEffectColumnC0(fill_all_cb)
    elseif effect == "0B" then
      status = "Random B00/B01 commands applied to the first effect column of the selected track."
      randomizeSmatterEffectColumnB0(fill_all_cb)
    else
      status = "Random " .. effect .. " commands applied to the first effect column of the selected track."
      randomizeSmatterEffectColumnCustom(effect, fill_all_cb, min_value, max_value)
    end
  else
    if s.selection_in_pattern == nil then
      local nc = s.selected_note_column
      local ec = s.selected_effect_column
      if nc then
        renoise.song().selected_line.effect_columns[1].number_string = effect
      elseif ec then
        ec.number_string = effect
      else
        return false
      end
    else
      local effect_column_selected = false
      for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
        local track = s:track(t)
        local note_columns_visible = track.visible_note_columns
        local effect_columns_visible = track.visible_effect_columns
        local total_columns_visible = note_columns_visible + effect_columns_visible

        local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
        local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or total_columns_visible

        if t == s.selection_in_pattern.end_track and end_column <= note_columns_visible then
          end_column = note_columns_visible + 1
        end

        for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
          for col = start_column, end_column do
            local column_index = col - note_columns_visible
            if col <= total_columns_visible then
              if col <= note_columns_visible then
              elseif column_index > 0 and column_index <= effect_columns_visible then
                effect_column_selected = true
                local effect_column = s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(column_index)
                if effect_column then
                  effect_column.number_string = effect
                end
              end
            end
          end
        end
      end
      if not effect_column_selected then
        for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
          for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
            local track = s:track(t)
            if track.visible_effect_columns > 0 then
              local effect_column = s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(1)
              effect_column.number_string = effect
            end
          end
        end
      end
    end
  end
  a:show_status(status)
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

function CheatSheet()
  local vb = renoise.ViewBuilder()
  local a = renoise.app()
  local s = renoise.song()
  local w = a.window

  if dialog and dialog.visible then
    dialog:close()
    return
  end

  local globalwidth = 50

  local wikitooltip = "http://tutorials.renoise.com/wiki/Pattern_Effect_Commands#Effect_Listing"
  local wikibutton = vb:button {width = globalwidth, text = "www", tooltip = wikitooltip, pressed = function() a:open_url(wikitooltip) end}

  local effect_buttons = vb:column {}
  for _, effect in ipairs(effects) do
    local button = vb:button {width = globalwidth, text = effect[2], tooltip = effect[3], pressed = function() effect_write(effect[1], effect[2] .. " - " .. effect[3], effect[2], effect[4], effect[5]) end}
    local desc = vb:text {text = effect[3]}
    effect_buttons:add_child(vb:row {button, desc})
  end

  local randomize_cb = vb:checkbox {
    value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomize.value, false),
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomize.value = v
      save_preferences()
    end
  }

local fill_probability_text = vb:text {
  style = "strong",
  text = string.format("%d%% Fill Probability", get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value, 0))
}

local fill_probability_slider = vb:slider {
width= 300,
  min = 0,
  max = 1,
  value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value, 0) / 100, -- Convert to fractional
  notifier = function(value)
    local percentage_value = math.floor(value * 100 + 0.5) -- Convert to percentage and round
    local original_value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value, 0)

    -- Check if the value changed significantly
    if original_value ~= percentage_value then
      preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value = percentage_value
      fill_probability_text.text = string.format("%d%% Fill Probability", percentage_value)
      save_preferences()
    end
  end
}




  
--[[
  local fill_all_cb = vb:checkbox {
    value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value, false),
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetFillAll.value = v
      save_preferences()
    end
  }
--]]  
  local randomize_whole_track_cb = vb:checkbox {
    value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value, false),
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeWholeTrack.value = v
      save_preferences()
    end
  }
  local randomizeswitch_cb = vb:checkbox {
    value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value, false),
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeSwitch.value = v
      save_preferences()
    end
  }
  
  local dontoverwrite_cb = vb:checkbox {
    value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeDontOverwrite.value, false),
    notifier = function(v)
      preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeDontOverwrite.value = v
      save_preferences()
    end
  }  
    
 -- Minimum Slider
local min_value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value, 0)

local min_slider = vb:minislider {
  id = "min_slider_unique",
  width = 300,
  min = 0,
  max = 255,
  value = min_value,
  notifier = function(v)
    preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMin.value = v
    vb.views["min_text_unique"].text = string.format("%02X", v)
    save_preferences()
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
local max_value = get_preference_value(preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value, 255)

local max_slider = vb:minislider {
  id = "max_slider_unique",
  width = 300,
  min = 0,
  max = 255,
  value = max_value,
  notifier = function(v)
    preferences.pakettiCheatSheet.pakettiCheatSheetRandomizeMax.value = v
    vb.views["max_text_unique"].text = string.format("%02X", v)
    save_preferences()
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
    vb:horizontal_aligner {mode = "left", vb:text {text = "Min", font="mono"}, min_decrement_button, min_increment_button, min_slider, min_text},
    vb:horizontal_aligner {mode = "left", vb:text {text = "Max", font="mono"}, max_decrement_button, max_increment_button, max_slider, max_text},
    vb:button {text = "Close", width = globalwidth, pressed = function() dialog:close() end}
  }
      
  local sliders = vb:column {
    vb:horizontal_aligner {mode = "right", vb:text {style = "strong", text = "Volume"},
      vb:minislider {
        id = "volumeslider",
        width = 30,
        height = 127,
        min = 0,
        max = 0x80,
        notifier = function(v3)
          sliderVisible("volume")
          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              if track.type == renoise.Track.TRACK_TYPE_MASTER or track.type == renoise.Track.TRACK_TYPE_SEND or track.type == renoise.Track.TRACK_TYPE_GROUP then
                print("Track", t, "Does not have Note Columns, skipping.")
              else
                local note_columns_visible = track.visible_note_columns
                local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
                local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or note_columns_visible
                for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                  for col = start_column, end_column do
                    if col <= note_columns_visible then
                      local note_column = s:pattern(s.selected_pattern_index):track(t):line(i).note_columns[col]
                      if note_column then
                        note_column.volume_value = v3
                      end
                    end
                  end
                end
              end
            end
          else
            if s.selected_note_column == nil and renoise.song().selected_track.type == 1 then
              renoise.song().selected_line.note_columns[1].volume_value = v3
            else
              if s.selected_note_column == nil and (renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_MASTER or renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_SEND or renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_GROUP) then
                renoise.app():show_status("This track type does not have a Volume Column available.")
              end
              if s.selected_note_column then
                s.selected_note_column.volume_value = v3
              end
            end
          end
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

        end
  
      }
    },
    vb:horizontal_aligner {mode = "right", vb:text {style = "strong", text = "Panning"},
      vb:minislider {
        id = "panningslider",
        width = 30,
        height = 127,
        min = 0,
        max = 0x80,
        notifier = function(v2)
          sliderVisible("panning")
          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              if track.type == renoise.Track.TRACK_TYPE_MASTER or track.type == renoise.Track.TRACK_TYPE_SEND or track.type == renoise.Track.TRACK_TYPE_GROUP then
                print("Track", t, "Does not have Note Columns, skipping.")
              else
                local note_columns_visible = track.visible_note_columns
                local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
                local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or note_columns_visible
                for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                  for col = start_column, end_column do
                    if col <= note_columns_visible then
                      local note_column = s:pattern(s.selected_pattern_index):track(t):line(i).note_columns[col]
                      if note_column then
                        note_column.panning_value = v2
                      end
                    end
                  end
                end
              end
            end
          else
            if s.selected_note_column == nil and renoise.song().selected_track.type == 1 then
              renoise.song().selected_line.note_columns[1].panning_value = v2
            else
              if s.selected_note_column == nil and (renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_MASTER or renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_SEND or renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_GROUP) then
                renoise.app():show_status("This track type does not have a Panning Column available.")
              end
              if s.selected_note_column then
                s.selected_note_column.panning_value = v2
              end
            end
          end
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end

      }
    },
    vb:horizontal_aligner {mode = "right", vb:text {style = "strong", text = "Delay"},
      vb:minislider {
        id = "delayslider",
        width = 30,
        height = 127,
        min = 0,
        max = 0xFF,
        notifier = function(v1)
          sliderVisible("delay")
          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              if track.type == renoise.Track.TRACK_TYPE_MASTER or track.type == renoise.Track.TRACK_TYPE_SEND or track.type == renoise.Track.TRACK_TYPE_GROUP then
                print("Track", t, "Does not have Note Columns, skipping.")
              else
                local note_columns_visible = track.visible_note_columns
                local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
                local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or note_columns_visible
                for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                  for col = start_column, end_column do
                    if col <= note_columns_visible then
                      local note_column = s:pattern(s.selected_pattern_index):track(t):line(i).note_columns[col]
                      if note_column then
                        note_column.delay_value = v1
                      end
                    end
                  end
                end
              end
            end
          else
            if s.selected_note_column == nil and renoise.song().selected_track.type == 1 then
              renoise.song().selected_line.note_columns[1].delay_value = v1
            else
              if s.selected_note_column == nil and (renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_MASTER or renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_SEND or renoise.song().selected_track.type == renoise.Track.TRACK_TYPE_GROUP) then
                renoise.app():show_status("This track type does not have a Delay Column available.")
              end
              if s.selected_note_column then
                s.selected_note_column.delay_value = v1
              end
            end
          end
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end

      }
    },
    vb:horizontal_aligner {mode = "right", vb:text {style = "strong", text = "Effect"},
      vb:minislider {
        id = "effectslider",
        width = 30,
        height = 127,
        min = 0,
        max = 0xFF,
        notifier = function(v4)
          if s.selected_track.visible_effect_columns == 0 and s.selected_track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
            s.selected_track.visible_effect_columns = 1
          end

          if s.selection_in_pattern then
            for t = s.selection_in_pattern.start_track, s.selection_in_pattern.end_track do
              local track = s:track(t)
              local note_columns_visible = track.visible_note_columns
              local effect_columns_visible = track.visible_effect_columns
              local total_columns_visible = note_columns_visible + effect_columns_visible
              local start_column = (t == s.selection_in_pattern.start_track) and s.selection_in_pattern.start_column or 1
              local end_column = (t == s.selection_in_pattern.end_track) and s.selection_in_pattern.end_column or total_columns_visible
              for i = s.selection_in_pattern.start_line, s.selection_in_pattern.end_line do
                for col = start_column, end_column do
                  local column_index = col - note_columns_visible
                  if col <= total_columns_visible and column_index > 0 and column_index <= effect_columns_visible then
                    local effect_column = s:pattern(s.selected_pattern_index):track(t):line(i):effect_column(column_index)
                    if effect_column then
                      effect_column.amount_value = v4
                    end
                  end
                end
              end
            end
          else
            local track = s.selected_track
            local line = s.selected_line
            local effect_column = line:effect_column(1)
            if effect_column then
              effect_column.amount_value = v4
            end
          end
        end
      }
    }
  }

  local dialog_content = vb:column {
    vb:row {
      effect_buttons,
      sliders
    },
    vb:row{
      randomize_section
    }
  }

  local function my_keyhandler_func(dialog, key)
    if not (key.modifiers == "" and key.name == "exclamation") then
      return key
    else
      dialog:close()
    end
  end

  dialog = a:show_custom_dialog("Paketti Pattern Effect Command CheatSheet", dialog_content, my_keyhandler_func)
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

renoise.tool():add_keybinding {name = "Global:Paketti:Pattern Effect Command CheatSheet", invoke = function() CheatSheet() end}

-- Initialize preferences
load_preferences()

