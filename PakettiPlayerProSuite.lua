local vb
local dialog

local note_names = {"C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-"}
local notes = {}
for octave = 0, 9 do
  for _, note in ipairs(note_names) do
    table.insert(notes, note .. octave)
  end
end
table.insert(notes, "000") -- Adding "---" as "000"
table.insert(notes, "OFF")

local function PakettiPlayerProNoteGridInsertNoteInPattern(note, instrument)
  local song = renoise.song()
  local sel = song.selection_in_pattern
  local pattern_index = song.selected_pattern_index
  local note_to_insert = note == "000" and "---" or note
  local note_column_selected = false

  local function insert_note_line(line, col)
    line:note_column(col).note_string = note_to_insert
    if instrument ~= nil and note ~= "---" and note ~= "OFF" then
      local instrument_actual = instrument - 1
      local instrument_string = string.format("%02X", instrument_actual)
      print("Inserting instrument string: " .. instrument_string)
      line:note_column(col).instrument_string = instrument_string
    end
    print("Note column info - Instrument String: " .. line:note_column(col).instrument_string .. ", Instrument Value: " .. tostring(line:note_column(col).instrument_value))
  end

  if sel == nil then
    local line = song.selected_line
    local col = song.selected_note_column_index
    local visible_note_columns = song.selected_track.visible_note_columns
    if col > 0 and col <= visible_note_columns then
      insert_note_line(line, col)
      note_column_selected = true
    end
  else
    for track_index = sel.start_track, sel.end_track do
      local pattern_track = song.patterns[pattern_index]:track(track_index)
      local visible_note_columns = song:track(track_index).visible_note_columns
      for line_index = sel.start_line, sel.end_line do
        local line = pattern_track:line(line_index)
        for col_index = 1, visible_note_columns do
          if (track_index > sel.start_track) or (col_index >= sel.start_column) then
            if col_index <= visible_note_columns then
              insert_note_line(line, col_index)
              note_column_selected = true
            end
          end
        end
      end
    end
  end

  if not note_column_selected then
    local message = "No Note Columns were selected, doing nothing."
    renoise.app():show_status(message)
  end
end

local function PakettiPlayerProNoteGridUpdateInstrumentInPattern(instrument)
  local song = renoise.song()
  local sel = song.selection_in_pattern
  local pattern_index = song.selected_pattern_index

  local function update_instrument_line(line, col)
    if instrument ~= nil then
      local instrument_actual = instrument - 1
      local instrument_string = string.format("%02X", instrument_actual)
      print("Updating instrument string: " .. instrument_string)
      line:note_column(col).instrument_string = instrument_string
    end
    print("Updated Note column info - Instrument String: " .. line:note_column(col).instrument_string .. ", Instrument Value: " .. tostring(line:note_column(col).instrument_value))
  end

  if sel == nil then
    local line = song.selected_line
    local col = song.selected_note_column_index
    local visible_note_columns = song.selected_track.visible_note_columns
    if col > 0 and col <= visible_note_columns then
      update_instrument_line(line, col)
    end
  else
    for track_index = sel.start_track, sel.end_track do
      local pattern_track = song.patterns[pattern_index]:track(track_index)
      local visible_note_columns = song:track(track_index).visible_note_columns
      for line_index = sel.start_line, sel.end_line do
        local line = pattern_track:line(line_index)
        for col_index = 1, visible_note_columns do
          if (track_index > sel.start_track) or (col_index >= sel.start_column) then
            if col_index <= visible_note_columns then
              update_instrument_line(line, col_index)
            end
          end
        end
      end
    end
  end
end

local function PakettiPlayerProNoteGridUpdateInstrumentPopup()
  local instrument_items = {"<None>"}
  for i = 0, #renoise.song().instruments - 1 do
    local instrument = renoise.song().instruments[i + 1]
    table.insert(instrument_items, string.format("%02X: %s", i, (instrument.name or "Untitled")))
  end
  if vb.views["instrument_popup"] then
    vb.views["instrument_popup"].items = instrument_items
  end
end

local function PakettiPlayerProNoteGridChangeInstrument(instrument)
  PakettiPlayerProNoteGridUpdateInstrumentInPattern(instrument)
end

local function PakettiPlayerProNoteGridCreateGrid()
  local grid_rows = 11
  local grid_columns = 12
  local grid = vb:column{}
  for row = 1, grid_rows do
    local row_items = vb:row{}
    for col = 1, grid_columns do
      local index = (row - 1) * grid_columns + col
      if notes[index] then
        row_items:add_child(vb:button{
          text = notes[index],
          width = 30,
          height = 15,
          notifier = function()
            local instrument_value = renoise.song().selected_instrument_index
            print("Note button clicked. Instrument Value: " .. tostring(instrument_value))
            PakettiPlayerProNoteGridInsertNoteInPattern(notes[index], instrument_value)
            -- Return focus to the Pattern Editor
            renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
          end
        })
      end
    end
    grid:add_child(row_items)
  end
  return grid
end

local function PakettiPlayerProNoteGridCloseDialog()
  if dialog and dialog.visible then
    dialog:close()
  end
  dialog = nil
  print("Dialog closed.")
  renoise.app():show_status("Closing Paketti PlayerPro Note Dialog")
end

local function PakettiPlayerProNoteGridCreateDialogContent()
  vb = renoise.ViewBuilder()
  
  local instrument_items = {"<None>"}
  for i = 0, #renoise.song().instruments - 1 do
    local instrument = renoise.song().instruments[i + 1]
    table.insert(instrument_items, string.format("%02X: %s", i, (instrument.name or "Untitled")))
  end

  local selected_instrument_index = renoise.song().selected_instrument_index
  local selected_instrument_value = selected_instrument_index + 1
  print("Dialog opened. Selected Instrument Index: " .. tostring(selected_instrument_index) .. ", Selected Instrument Value: " .. tostring(selected_instrument_value))

  return vb:column{
    margin = 10,
    vb:row{
      vb:text{
        text = "Instrument:"
      },
      vb:popup{
        items = instrument_items,
        width = 200,
        id = "instrument_popup",
        value = selected_instrument_value,
        notifier = function(value)
          local instrument
          if value == 1 then
            instrument = nil
            renoise.song().selected_instrument_index = nil
          else
            instrument = value - 1
            renoise.song().selected_instrument_index = instrument
          end
          print("Instrument dropdown changed. Value: " .. tostring(value) .. ", Instrument Index: " .. tostring(instrument))
          PakettiPlayerProNoteGridChangeInstrument(instrument)
        end
      },
      vb:button{
        text = "Refresh",
        width = 100,
        notifier = function()
          PakettiPlayerProNoteGridUpdateInstrumentPopup()
        end
      }
    },
    PakettiPlayerProNoteGridCreateGrid(),
    vb:row{
      vb:button{
        text = "Close",
        width = 100,
        notifier = function()
          PakettiPlayerProNoteGridCloseDialog()
        end
      }
    }
  }
end

local function PakettiPlayerProNoteGridKeyHandlerFunc(dialog, key)
  if key.modifiers == "" and key.name == "exclamation" then
    print("Exclamation key pressed, closing dialog.")
    dialog:close()
  else
    return key
  end
end

local function PakettiPlayerProNoteGridShowDropdownGrid()
  if dialog and dialog.visible then
    print("Dialog is visible, closing dialog.")
    PakettiPlayerProNoteGridCloseDialog()
  else
    print("Dialog is not visible, creating new dialog.")
    dialog = renoise.app():show_custom_dialog("Player Pro Note Selector", PakettiPlayerProNoteGridCreateDialogContent(), PakettiPlayerProNoteGridKeyHandlerFunc)
    print("Dialog opened.")
    renoise.app():show_status("Opening Paketti PlayerPro Note Dialog")
    -- Return focus to the Pattern Editor
    renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
  end
end

local function PakettiPlayerProNoteGridAddNoteMenuEntries()
  local note_ranges = {
    {name = "C-0 to B-2", range_start = 1, range_end = 36},
    {name = "C-3 to B-5", range_start = 37, range_end = 72},
    {name = "C-6 to B-9", range_start = 73, range_end = 108}
  }

  for _, range in ipairs(note_ranges) do
    for i = range.range_start, range.range_end do
      if notes[i] then
        renoise.tool():add_menu_entry{
          name = "Pattern Editor:Paketti..:Note Dropdown.."..range.name..":"..notes[i],
          invoke = function() PakettiPlayerProNoteGridInsertNoteInPattern(notes[i], renoise.song().selected_instrument_index) end}
      end
    end
    renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Note Dropdown.."..range.name..":000", invoke=function() PakettiPlayerProNoteGridInsertNoteInPattern("000", renoise.song().selected_instrument_index) end}
    renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Note Dropdown.."..range.name..":OFF", invoke=function() PakettiPlayerProNoteGridInsertNoteInPattern("OFF", renoise.song().selected_instrument_index) end}
  end
end

-- Handle scenario when the dialog is closed by other means
renoise.app().window.active_middle_frame_observable:add_notifier(function()
  if dialog and not dialog.visible then
    print("Dialog is not visible, removing reference.")
    PakettiPlayerProNoteGridCloseDialog()
    print("Reference removed.")
  end
end)

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Open Player Pro Note Column Dialog", invoke=PakettiPlayerProNoteGridShowDropdownGrid}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Open Player Pro Note Column Dialog", invoke=PakettiPlayerProNoteGridShowDropdownGrid}

PakettiPlayerProNoteGridAddNoteMenuEntries()
--------------







-- Function to transpose notes
function pakettiPlayerProTranspose(steps)
  local song=renoise.song()
  local selection=song.selection_in_pattern
  local pattern=song.selected_pattern

  -- Determine the range to transpose
  local start_track, end_track, start_line, end_line, start_column, end_column

  if selection~=nil then
    start_track=selection.start_track
    end_track=selection.end_track
    start_line=selection.start_line
    end_line=selection.end_line
    start_column=selection.start_column
    end_column=selection.end_column
  else
    start_track=song.selected_track_index
    end_track=song.selected_track_index
    start_line=song.selected_line_index
    end_line=song.selected_line_index
    start_column=1
    end_column=song.tracks[start_track].visible_note_columns
  end

  -- Iterate through each track in the determined range
  for track_index=start_track,end_track do
    local track=pattern:track(track_index)

    -- Iterate through each line in the determined range
    for line_index=start_line,end_line do
      local line=track:line(line_index)

      -- Iterate through each note column in the line within the determined range
      for column_index=start_column,end_column do
        local note_column=line:note_column(column_index)
        if not note_column.is_empty then
          note_column.note_value=(note_column.note_value+steps)%120
        end
      end
    end
  end
end

-- Adding keybindings for PlayerPro Transpose
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Player Pro Transpose Selection or Row +1",invoke=function() pakettiPlayerProTranspose(1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Player Pro Transpose Selection or Row -1",invoke=function() pakettiPlayerProTranspose(-1) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Player Pro Transpose Selection or Row +12",invoke=function() pakettiPlayerProTranspose(12) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Player Pro Transpose Selection or Row -12",invoke=function() pakettiPlayerProTranspose(-12) end}
