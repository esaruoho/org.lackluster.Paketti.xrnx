-- Function to set the scheduled sequence as the current section
function tknaSetCurrentSectionAsScheduledSequence()
  local song = renoise.song()
  local sequencer = song.sequencer
  local transport = song.transport
  local current_sequence_index = song.selected_sequence_index
  local total_sequences = #sequencer.pattern_sequence

  -- Helper function to find all sections
  local function findSections()
    local sections = {}
    for i = 1, total_sequences do
      if sequencer:sequence_is_start_of_section(i) then
        table.insert(sections, i)
      end
    end
    return sections
  end

  -- Helper function to find the section index for a given sequence index
  local function findSectionIndex(sections, sequence_index)
    local total_sections = #sections
    for i, section_start in ipairs(sections) do
      local section_end = (i < total_sections) and (sections[i + 1] - 1) or total_sequences
      if sequence_index >= section_start and sequence_index <= section_end then
        return i, section_start, section_end
      end
    end
    return nil
  end

  local sections = findSections()
  local current_section_index, current_section_start, current_section_end = findSectionIndex(sections, current_sequence_index)

  -- Set the scheduled sequence to the current section if it exists
  if current_section_index then
    transport:set_scheduled_sequence(current_section_start)
    for i = current_section_start + 1, current_section_end do
      transport:add_scheduled_sequence(i)
    end
    renoise.app():show_status("Set scheduled sequence to current section: " .. current_section_start .. " to " .. current_section_end)
  else
    renoise.app():show_status("Current sequence is not inside any section.")
  end
end

-- Function to add the current section to the scheduled sequences
function tknaAddCurrentSectionToScheduledSequences()
  local song = renoise.song()
  local sequencer = song.sequencer
  local transport = song.transport
  local current_sequence_index = song.selected_sequence_index
  local total_sequences = #sequencer.pattern_sequence

  -- Helper function to find all sections
  local function findSections()
    local sections = {}
    for i = 1, total_sequences do
      if sequencer:sequence_is_start_of_section(i) then
        table.insert(sections, i)
      end
    end
    return sections
  end

  -- Helper function to find the section index for a given sequence index
  local function findSectionIndex(sections, sequence_index)
    local total_sections = #sections
    for i, section_start in ipairs(sections) do
      local section_end = (i < total_sections) and (sections[i + 1] - 1) or total_sequences
      if sequence_index >= section_start and sequence_index <= section_end then
        return i, section_start, section_end
      end
    end
    return nil
  end

  local sections = findSections()
  local current_section_index, current_section_start, current_section_end = findSectionIndex(sections, current_sequence_index)

  -- Add the current section to the scheduled sequences if it exists
  if current_section_index then
    for i = current_section_start, current_section_end do
      transport:add_scheduled_sequence(i)
    end
    renoise.app():show_status("Added current section to scheduled sequences: " .. current_section_start .. " to " .. current_section_end)
  else
    renoise.app():show_status("Current sequence is not inside any section.")
  end
end

-- Adding keybindings for the functions
renoise.tool():add_keybinding{name="Global:Paketti:Set Current Section as Scheduled Sequence",invoke=tknaSetCurrentSectionAsScheduledSequence}
renoise.tool():add_keybinding{name="Global:Paketti:Add Current Section to Scheduled Sequences",invoke=tknaAddCurrentSectionToScheduledSequences}

-- Adding menu entries for the functions
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Set Current Section as Scheduled Sequence",invoke=tknaSetCurrentSectionAsScheduledSequence}
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Add Current Section to Scheduled Sequences",invoke=tknaAddCurrentSectionToScheduledSequences}

-- Adding MIDI mappings for the functions
renoise.tool():add_midi_mapping{name="Tools:Paketti:Set Current Section as Scheduled Sequence",invoke=tknaSetCurrentSectionAsScheduledSequence}
renoise.tool():add_midi_mapping{name="Tools:Paketti:Add Current Section to Scheduled Sequences",invoke=tknaAddCurrentSectionToScheduledSequences}


-- Function to expand the section loop step-by-step, adding the next section
function expandSectionLoopNext()
  local song = renoise.song()
  local sequencer = song.sequencer
  local transport = song.transport
  local current_sequence_index = song.selected_sequence_index
  local total_sequences = #sequencer.pattern_sequence

  -- Helper function to find all sections
  local function findSectionsA()
    local sections = {}
    for i = 1, total_sequences do
      if sequencer:sequence_is_start_of_section(i) then
        table.insert(sections, i)
      end
    end
    return sections
  end

  local sections = findSectionsA()
  local total_sections = #sections

  -- Helper function to find the section index for a given sequence index
  local function findSectionIndexA(sequence_index)
    for i, section_start in ipairs(sections) do
      local section_end = (i < total_sections) and (sections[i + 1] - 1) or total_sequences
      if sequence_index >= section_start and sequence_index <= section_end then
        return i, section_start, section_end
      end
    end
    return nil
  end

  local current_section_index, current_section_start, current_section_end = findSectionIndexA(current_sequence_index)
  local loop_range = transport.loop_sequence_range

  -- If no loop range or an invalid loop range exists, set it to the current section
  if not loop_range or #loop_range ~= 2 or 
      (loop_range[1] == 0 and loop_range[2] == 0) then
    if current_section_index then
      transport.loop_sequence_range = {current_section_start, current_section_end}
    else
      renoise.app():show_status("Current sequence is not inside any section.")
    end
  else
    local loop_end = loop_range[2]
    local next_section_index = findSectionIndexA(loop_end + 1)

    -- If there's a next section to add
    if next_section_index then
      local next_section_start, next_section_end = sections[next_section_index], (next_section_index < total_sections) and (sections[next_section_index + 1] - 1) or total_sequences
      transport.loop_sequence_range = {loop_range[1], next_section_end}
    else
      -- No more sections to add to the loop
      renoise.app():show_status("No more sections to add to the loop.")
    end
  end
end

-- Function to expand the section loop step-by-step, adding the previous section
function expandSectionLoopPrevious()
  local song = renoise.song()
  local sequencer = song.sequencer
  local transport = song.transport
  local current_sequence_index = song.selected_sequence_index
  local total_sequences = #sequencer.pattern_sequence

  -- Helper function to find all sections
  local function findSectionsB()
    local sections = {}
    for i = 1, total_sequences do
      if sequencer:sequence_is_start_of_section(i) then
        table.insert(sections, i)
      end
    end
    return sections
  end

  local sections = findSectionsB()
  local total_sections = #sections

  -- Helper function to find the section index for a given sequence index
  local function findSectionIndexB(sequence_index)
    for i, section_start in ipairs(sections) do
      local section_end = (i < total_sections) and (sections[i + 1] - 1) or total_sequences
      if sequence_index >= section_start and sequence_index <= section_end then
        return i, section_start, section_end
      end
    end
    return nil
  end

  local current_section_index, current_section_start, current_section_end = findSectionIndexB(current_sequence_index)
  local loop_range = transport.loop_sequence_range

  -- If no loop range or an invalid loop range exists, set it to the current section
  if not loop_range or #loop_range ~= 2 or 
      (loop_range[1] == 0 and loop_range[2] == 0) then
    if current_section_index then
      transport.loop_sequence_range = {current_section_start, current_section_end}
    else
      renoise.app():show_status("Current sequence is not inside any section.")
    end
  else
    local loop_start = loop_range[1]
    local previous_section_index = findSectionIndexB(loop_start - 1)

    -- If there's a previous section to add
    if previous_section_index then
      local previous_section_start, previous_section_end = sections[previous_section_index], (previous_section_index < total_sections) and (sections[previous_section_index + 1] - 1) or total_sequences
      transport.loop_sequence_range = {previous_section_start, loop_range[2]}
    else
      -- No more sections to add to the loop
      renoise.app():show_status("No more sections to add to the loop.")
    end
  end
end

-- Adding keybinding for the functions
renoise.tool():add_keybinding{name="Global:Paketti:Section Loop (Next)",invoke=expandSectionLoopNext}
renoise.tool():add_keybinding{name="Global:Paketti:Section Loop (Previous)",invoke=expandSectionLoopPrevious}

-- Adding menu entry for the functions
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Section Loop (Next)",invoke=expandSectionLoopNext}
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Section Loop (Previous)",invoke=expandSectionLoopPrevious}

-- Adding MIDI mapping for the functions
renoise.tool():add_midi_mapping{name="Tools:Paketti:Section Loop (Next)",invoke=expandSectionLoopNext}
renoise.tool():add_midi_mapping{name="Tools:Paketti:Section Loop (Previous)",invoke=expandSectionLoopPrevious}



-- Function to expand the sequence selection step-by-step
function tknaSequenceSelectionPlusOne()
  local song = renoise.song()
  local sequencer = song.sequencer
  local current_sequence_index = song.selected_sequence_index
  local selection_range = sequencer.selection_range
  local total_sequences = #sequencer.pattern_sequence

  -- If no selection range exists or if it is {0, 0}, select the current sequence
  if not selection_range or #selection_range ~= 2 or 
      (selection_range[1] == 0 and selection_range[2] == 0) then
    sequencer.selection_range = {current_sequence_index, current_sequence_index}
  else
    local start_index = selection_range[1]
    local end_index = selection_range[2]

    -- If the end index is less than the total number of sequences
    if end_index < total_sequences then
      -- Extend the selection range by including the next sequence
      sequencer.selection_range = {start_index, end_index + 1}
    else
      -- No more sequences to add to the selection
      renoise.app():show_status("No more sequences left to add to the selection.")
    end
  end
end

-- Function to reduce the sequence selection step-by-step
function tknaSequenceSelectionMinusOne()
  local song = renoise.song()
  local sequencer = song.sequencer
  local current_sequence_index = song.selected_sequence_index
  local selection_range = sequencer.selection_range

  -- If no selection range exists or if it is {0, 0}, select the current sequence
  if not selection_range or #selection_range ~= 2 or 
      (selection_range[1] == 0 and selection_range[2] == 0) then
    sequencer.selection_range = {current_sequence_index, current_sequence_index}
  else
    local start_index = selection_range[1]
    local end_index = selection_range[2]

    -- If the start index is greater than 1
    if start_index > 1 then
      -- Reduce the selection range by excluding the first sequence
      sequencer.selection_range = {start_index - 1, end_index}
    else
      -- No more sequences to remove from the selection
      renoise.app():show_status("No more sequences left to add to the selection.")
    end
  end
end

-- Adding keybinding for the functions
renoise.tool():add_keybinding{name="Global:Paketti:Sequence Selection (Next)",invoke=tknaSequenceSelectionPlusOne}
renoise.tool():add_keybinding{name="Global:Paketti:Sequence Selection (Previous)",invoke=tknaSequenceSelectionMinusOne}

-- Adding menu entry for the functions
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Sequence Selection (Next)",invoke=tknaSequenceSelectionPlusOne}
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Sequence Selection (Previous)",invoke=tknaSequenceSelectionMinusOne}

-- Adding MIDI mapping for the functions
renoise.tool():add_midi_mapping{name="Tools:Paketti:Sequence Selection (Next)",invoke=tknaSequenceSelectionPlusOne}
renoise.tool():add_midi_mapping{name="Tools:Paketti:Sequence Selection (Previous)",invoke=tknaSequenceSelectionMinusOne}










-------
function patternEditorSelectedLastTrack()
renoise.song().selected_track_index=#renoise.song().tracks
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Select Last Track",invoke=function() patternEditorSelectedLastTrack() end}


-- Toggle Note Off "===" On / Off in all selected tracks within the selection or current row.
function PakettiNoteOffToSelection()
  local s = renoise.song()
  local currPatt = s.selected_pattern_index
  local selection = s.selection_in_pattern
  local note_col_idx = s.selected_note_column_index

  if selection then
    -- Loop through all lines and tracks within the selection
    for line = selection.start_line, selection.end_line do
      for track = selection.start_track, selection.end_track do
        local note_col = s.patterns[currPatt].tracks[track].lines[line].note_columns[note_col_idx]
        
        if note_col_idx and note_col_idx > 0 then
          if note_col.note_string == "OFF" then
            note_col.note_string = ""
          else
            note_col.note_string = "OFF"
          end
        end
      end
    end
  else
    -- No selection, operate on the current row
    local currLine = s.selected_line_index
    local currTrack = s.selected_track_index
    
    if note_col_idx and note_col_idx > 0 then
      local note_col = s.patterns[currPatt].tracks[currTrack].lines[currLine].note_columns[note_col_idx]
      
      if note_col.note_string == "OFF" then
        note_col.note_string = ""
      else
        note_col.note_string = "OFF"
      end
    end
  end
end

-- Add keybinding for the new function
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Toggle Note Off in Selected Tracks",invoke=function() PakettiNoteOffToSelection() end}





--------
-- Function to rotate sample buffer content forwards based on MIDI knob (0...127)
function rotate_sample_buffer_forward(knob_value)
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    buffer:prepare_sample_data_changes()
    local frames = buffer.number_of_frames
    local rotate_amount = math.floor((knob_value / 127) * frames)
    for c = 1, buffer.number_of_channels do
      local temp_data = {}
      for i = 1, frames do
        temp_data[i] = buffer:sample_data(c, i)
      end
      for i = 1, frames do
        local new_pos = (i + rotate_amount - 1) % frames + 1
        buffer:set_sample_data(c, new_pos, temp_data[i])
      end
    end
    buffer:finalize_sample_data_changes()
  else
    renoise.app():show_status("No sample data to rotate.")
  end
end

-- Function to rotate sample buffer content backwards based on MIDI knob (0...127)
function rotate_sample_buffer_backward(knob_value)
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    buffer:prepare_sample_data_changes()
    local frames = buffer.number_of_frames
    local rotate_amount = math.floor((knob_value / 127) * frames)
    for c = 1, buffer.number_of_channels do
      local temp_data = {}
      for i = 1, frames do
        temp_data[i] = buffer:sample_data(c, i)
      end
      for i = 1, frames do
        local new_pos = (i - rotate_amount - 1 + frames) % frames + 1
        buffer:set_sample_data(c, new_pos, temp_data[i])
      end
    end
    buffer:finalize_sample_data_changes()
  else
    renoise.app():show_status("No sample data to rotate.")
  end
end

-- Adding MIDI mapping for rotating sample buffer content forwards
renoise.tool():add_midi_mapping{name="Global:Tools:Rotate Sample Buffer Content Forward [Set]",invoke=function(midi_message)
  rotate_sample_buffer_forward(midi_message.int_value)
end}

-- Adding MIDI mapping for rotating sample buffer content backwards
renoise.tool():add_midi_mapping{name="Global:Tools:Rotate Sample Buffer Content Backward [Set]",invoke=function(midi_message)
  rotate_sample_buffer_backward(midi_message.int_value)
end}











renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Randomize Selected Instrument Plugin Parameters",invoke=function()randomizeSelectedPlugin()end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Plugin",invoke=function()randomizeSelectedPlugin()end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Randomize Selected Instrument Plugin Parameters",invoke=function()randomizeSelectedPlugin()end}

-- Function to randomize parameters of the selected plugin
function randomizeSelectedPlugin()
  local song = renoise.song()
  local instrument = renoise.song().selected_instrument 

  if not instrument or not instrument.plugin_properties then
    renoise.app():show_status("The currently selected Instrument does not have a plugin loaded.")
    return
  end

  local plugin_name = renoise.song().selected_instrument.plugin_properties.plugin_device.name
  renoise.app():show_status("Randomizing parameters for plugin: " .. plugin_name)

  local parameter_count = #instrument.plugin_properties.plugin_device.parameters
  
  for i = 1, parameter_count do
    local parameter = instrument.plugin_properties.plugin_device.parameters[i]
    local min = parameter.value_min
    local max = parameter.value_max
    local random_value = math.random() * (max - min) + min
    parameter.value = random_value
  end
  
  renoise.app():show_status("Randomized " .. parameter_count .. " parameters for plugin: " .. plugin_name)
end




-- Tool Registration
renoise.tool():add_menu_entry{name="DSP Device:Paketti..:Randomize Selected Device Parameters",invoke=function()randomize_selected_device()end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Randomize Selected Device Parameters",invoke=function()randomize_selected_device()end}
renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Device",invoke=function()randomize_selected_device()end}

-- Function to randomize parameters of the selected device
function randomize_selected_device()
  local song = renoise.song()
  local device = song.selected_device
  
  if not device then
    renoise.app():show_status("No DSP Device has been selected, cannot randomize parameters. Select a Track DSP Device and try again.")
    return
  end

  local parameter_count = #device.parameters
   local device_name = device.display_name
  for i = 1, parameter_count do
    local parameter = device:parameter(i)
    local min = parameter.value_min
    local max = parameter.value_max
    local random_value = math.random() * (max - min) + min
    parameter.value = random_value
  end
  
  renoise.app():show_status("Randomized " .. parameter_count .. " parameters for device: " .. device_name)
end










-- Function to toggle the sequence selection based on the provided sequence number
function tknaToggleSequenceSelection(number)
  local seq_index = number + 1 -- Adjusting to 1-based index as required by Renoise

  -- Check if the current selection matches the specified sequence number
  if renoise.song().sequencer.selection_range and
     #renoise.song().sequencer.selection_range == 2 and
     renoise.song().sequencer.selection_range[1] == seq_index and
     renoise.song().sequencer.selection_range[2] == seq_index then
    -- If so, clear the selection
    renoise.song().sequencer.selection_range = {}
  else
    -- Otherwise, set the selection to the specified sequence number
    renoise.song().sequencer.selection_range = {seq_index, seq_index}
  end
end

-- Loop to create keybindings for sequence numbers 00 to 32
for i = 1, 33 do
  local padded_number = string.format("%02d", i - 1)
  local keybinding_name = "Global:Paketti:Toggle Sequence Selection " .. padded_number

  -- Create a keybinding for each sequence number
  renoise.tool():add_keybinding{name=keybinding_name, invoke=function() tknaToggleSequenceSelection(i - 1) end}
end


-- Function to toggle the sequence selection based on the provided sequence number
-- If there is a selection_range, turn it into a sequence loop
function SequenceSelectionToLoop()
  local song = renoise.song()
  local selection_start = song.sequencer.selection_range[1]
  local selection_end = song.sequencer.selection_range[2]

  -- Check if the loop range matches the current selection
  if song.transport.loop_sequence_range[1] == selection_start and 
     song.transport.loop_sequence_range[2] == selection_end then
    -- If it matches, disable the loop by setting it to nil
    song.transport.loop_sequence_range = {}
  else
    -- Otherwise, set the loop range to the current selection
    song.transport.loop_sequence_range = { selection_start, selection_end }
  end
end

-- Adding a key binding for the function
renoise.tool():add_keybinding{name="Global:Paketti:Toggle Sequence Selection to Loop",invoke=function() SequenceSelectionToLoop() end}

-- Adding a menu entry for the function
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Toggle Sequence Selection to Loop",invoke=function() SequenceSelectionToLoop() end}

renoise.tool():add_keybinding{name="Global:Paketti:Toggle Sequence Selection (All) On/Off",invoke=function()
local sequencerCount=#renoise.song().sequencer.pattern_sequence
--if renoise.song().sequencer.selection_range=={1,sequencerCount} 
--then renoise.song().sequencer.selection_range={} else
renoise.song().sequencer.selection_range={1,#renoise.song().sequencer.pattern_sequence}
--end
end
}


function tknaUnselectSequenceSelection()
renoise.song().sequencer.selection_range={}
end

renoise.tool():add_keybinding{name="Global:Paketti:Set Sequence Selection Off",invoke=tknaUnselectSequenceSelection}

-- Function to toggle the current sequence selection
function tknaToggleCurrentSequenceSelection()
  -- Check if the current selection matches the selected sequence index
  if renoise.song().sequencer.selection_range and
     #renoise.song().sequencer.selection_range == 2 and
     renoise.song().sequencer.selection_range[1] == renoise.song().selected_sequence_index and
     renoise.song().sequencer.selection_range[2] == renoise.song().selected_sequence_index then
    -- If so, clear the selection
    renoise.song().sequencer.selection_range = {}
  else
    -- Otherwise, set the selection to the current sequence index
    renoise.song().sequencer.selection_range = {renoise.song().selected_sequence_index, renoise.song().selected_sequence_index}
  end
end

-- Add keybinding for the function
renoise.tool():add_keybinding{name="Global:Paketti:Toggle Current Sequence Selection On/Off", invoke=tknaToggleCurrentSequenceSelection}




-- Helper function to select and loop a specific section
function select_and_loop_section(section_number)
  local song = renoise.song()
  local sequencer = song.sequencer
  local sequence_count = #sequencer.pattern_sequence

  local current_section_start = nil
  local current_section_index = 0

  -- Find the start index of the specific section
  for i = 1, sequence_count do
    if sequencer:sequence_is_start_of_section(i) then
      current_section_index = current_section_index + 1
      if current_section_index == section_number then
        current_section_start = i
        break
      end
    end
  end

  -- If the specified section is not found, exit the function
  if not current_section_start then
    renoise.app():show_status("No such Section exists, doing nothing.")
    return
  end

  -- Find the end index of the current section
  local current_section_end = sequence_count
  for i = current_section_start + 1, sequence_count do
    if sequencer:sequence_is_start_of_section(i) then
      current_section_end = i - 1
      break
    end
  end

  -- Set the loop to the current section
  song.transport.loop_sequence_range = {current_section_start, current_section_end}
  
  -- Notify the user
  renoise.app():show_status("Loop set to section " .. section_number .. " from sequence " .. current_section_start .. " to " .. current_section_end)
end

-- Helper function to find the current section index
function find_current_section_index()
  local song = renoise.song()
  local sequencer = song.sequencer
  local sequence_count = #sequencer.pattern_sequence
  local current_pos = song.transport.edit_pos.sequence
  local loop_start = song.transport.loop_sequence_range[1]
  local loop_end = song.transport.loop_sequence_range[2]

  -- Check if a section is currently selected
  if loop_start > 0 and loop_end > 0 and loop_start <= loop_end then
    local current_section_index = 0
    for i = 1, sequence_count do
      if sequencer:sequence_is_start_of_section(i) then
        current_section_index = current_section_index + 1
        if loop_start == i then
          return current_section_index
        end
      end
    end
  end

  -- If no section is selected, find the section based on the current edit position
  local current_section_index = 0
  for i = 1, sequence_count do
    if sequencer:sequence_is_start_of_section(i) then
      current_section_index = current_section_index + 1
      if i > current_pos then
        return current_section_index - 1
      end
    end
  end
  return current_section_index
end

-- Function to select and loop the next section
function select_and_loop_section_next()
  local current_section_index = find_current_section_index()
  if current_section_index < 32 then
    select_and_loop_section(current_section_index + 1)
  else
    renoise.app():show_status("There is no Next Section available.")
  end
end

-- Function to select and loop the previous section
function select_and_loop_section_previous()
  local current_section_index = find_current_section_index()
  if current_section_index > 1 then
    select_and_loop_section(current_section_index - 1)
  else
    renoise.app():show_status("There is no Previous Section available.")
  end
end

-- Function to turn off the sequence selection
function set_sequence_selection_off()
  local song = renoise.song()
  song.transport.loop_sequence_range = {0, 0}
  renoise.app():show_status("Sequence selection turned off.")
end

-- Function to select and loop a specific section, or deselect it if already selected
function select_and_loop_section(section_index)
  local song = renoise.song()
  local sequencer = song.sequencer
  local sequence_count = #sequencer.pattern_sequence
  local current_section_index = 0
  local loop_start = 0
  local loop_end = 0

  for i = 1, sequence_count do
    if sequencer:sequence_is_start_of_section(i) then
      current_section_index = current_section_index + 1
      if current_section_index == section_index then
        loop_start = i
        for j = i + 1, sequence_count do
          if sequencer:sequence_is_start_of_section(j) then
            loop_end = j - 1
            break
          end
        end
        if loop_end == 0 then
          loop_end = sequence_count
        end
        break
      end
    end
  end

  if song.transport.loop_sequence_range[1] == loop_start and song.transport.loop_sequence_range[2] == loop_end then
    set_sequence_selection_off()
  else
    song.transport.loop_sequence_range = {loop_start, loop_end}
    renoise.app():show_status("Looped section " .. section_index)
  end
end

for section_number = 1, 32 do
  renoise.tool():add_keybinding{name="Global:Paketti..:Select and Loop Sequence Section " .. string.format("%02d", section_number),
    invoke=function() select_and_loop_section(section_number) end
  }
end

renoise.tool():add_keybinding{name="Global:Paketti:Select and Loop Section (Next)",invoke=select_and_loop_section_next}
renoise.tool():add_keybinding{name="Global:Paketti:Select and Loop Section (Previous)",invoke=select_and_loop_section_previous}

renoise.tool():add_keybinding{name="Global:Paketti:Set Sequence Loop Selection Off",invoke=set_sequence_selection_off}




function tknaNextSequence(count)
local currSeq = renoise.song().selected_sequence_index
local nextSeq = currSeq + count
local total_sequences = #renoise.song().sequencer.pattern_sequence

if nextSeq < 1 then renoise.app():show_status("You are on the first sequence.") return else

  if nextSeq <= total_sequences then
    renoise.song().selected_sequence_index = nextSeq
    else
    renoise.app():show_status("No more sequences available.")
  end
end

end

renoise.tool():add_keybinding{name="Global:Paketti:Jump to Sequence (Next)",invoke=function() tknaNextSequence(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Jump to Sequence (Previous)",invoke=function() tknaNextSequence(-1) end}

function tknaContinueSequenceFromSameLine(number)
local storedSequence = renoise.song().selected_sequence_index
local storedRow = renoise.song().selected_line_index
  if number <= #renoise.song().sequencer.pattern_sequence then
if renoise.song().transport.follow_player then
renoise.song().selected_sequence_index = number
else

renoise.song().transport.follow_player = true 
renoise.song().selected_sequence_index = number
renoise.song().transport.follow_player = false
renoise.song().selected_sequence_index=storedSequence
renoise.song().selected_line_index=storedRow 
end
    else
    renoise.app():show_status("Sequence does not exist, doing nothing.")
  end

end


for i = 1, 32 do
  -- Zero-pad the number for sequence naming
  local padded_number = string.format("%02d", i - 1)
  
  -- Add keybinding for each sequence
  renoise.tool():add_keybinding{name="Global:Paketti:Continue Sequence " .. padded_number .. " From Same Line", invoke=function() 
  if i < #renoise.song().sequencer.pattern_sequence then
  tknaContinueSequenceFromSameLine(i) 
  else
  renoise.song():show_status("Sequence does not exist, doing nothing.")
  end
  end}

end
--------

function tknaContinueCurrentSequenceFromCurrentLine()
  local song = renoise.song()

  local storedSequence = song.selected_sequence_index
  local step = 1

  local function processStep()
    if step == 1 then
      renoise.song().transport.follow_player = true
      renoise.app():show_status("Jumping to Previously Selected (Current) Sequence")
      step = step + 1
    elseif step == 2 then
      renoise.song().selected_sequence_index = storedSequence
      step = step + 1
    elseif step == 3 then
      renoise.song().transport.follow_player = false
      renoise.tool().app_idle_observable:remove_notifier(processStep)
    end
  end

  renoise.tool().app_idle_observable:add_notifier(processStep)
end


  renoise.tool():add_keybinding{name="Global:Paketti:Continue Current Sequence From Same Line", invoke=function() 
  tknaContinueCurrentSequenceFromCurrentLine() 
end}
---------
function tknaMidiMapSequence(value)
  local max_seq = #renoise.song().sequencer.pattern_sequence - 1
  local sequence_num = math.floor((value / 127) * max_seq) + 1
  tknaContinueSequenceFromSameLine(sequence_num)
end

-- Add MIDI mapping
renoise.tool():add_midi_mapping{name="Global:Paketti:Continue Sequence From Same Line [Set Sequence]", invoke=function(message)
  if message:is_abs_value() then
    tknaMidiMapSequence(message.int_value)
  end
end}

--------
for i = 1, 32 do
  -- Zero-pad the number for sequence naming
  local padded_number = string.format("%02d", i - 1)
  
  -- Add keybinding for each sequence
  renoise.tool():add_keybinding{name="Global:Paketti:Selected Specific Sequence " .. padded_number, invoke=function() 
  if i < #renoise.song().sequencer.pattern_sequence then 
  renoise.song().selected_sequence_index = i
  else renoise.app():show_status("Sequence does not exist, doing nothing.")
  end
     end}
end




function tknaTriggerSequence(number)
  local total_sequences = #renoise.song().sequencer.pattern_sequence
  if number < total_sequences then
    renoise.song().transport:trigger_sequence(number)
  else
    renoise.app():show_status("This sequence position does not exist.")
  end
end

for i = 1, 32 do
  -- Zero-pad the number for sequence naming
  local padded_number = string.format("%02d", i - 1)
  
  -- Add keybinding for each sequence
  renoise.tool():add_keybinding{name="Global:Paketti:Trigger Sequence " .. padded_number, invoke=function() tknaTriggerSequence(i) end}
end







function tknaSetSequenceAsScheduledList(number)
if renoise.song().transport.playing then  else renoise.song().transport.playing=true
end
local total_sequences = #renoise.song().sequencer.pattern_sequence
if number < total_sequences then
renoise.song().transport:set_scheduled_sequence(number)
else
renoise.app():show_status("This sequence position does not exist.")
end
end

for i = 1,32 do
  local padded_number = string.format("%02d", i - 1)
  
  -- Add keybinding for each sequence
  renoise.tool():add_keybinding{name="Global:Paketti:Set Sequence " .. padded_number .. " as Scheduled List", invoke=function() tknaSetSequenceAsScheduledList(i) end}
end

  renoise.tool():add_keybinding{name="Global:Paketti:Set Current Sequence as Scheduled List", invoke=function() 
  
  renoise.song().transport:set_scheduled_sequence(renoise.song().selected_sequence_index) end}

  renoise.tool():add_keybinding{name="Global:Paketti:Add Current Sequence to Scheduled List", invoke=function() 
  
  renoise.song().transport:add_scheduled_sequence(renoise.song().selected_sequence_index) end}


function tknaAddSequenceToScheduledList(number)
if renoise.song().transport.playing then  else renoise.song().transport.playing=true
end
local total_sequences = #renoise.song().sequencer.pattern_sequence
if number < total_sequences then
renoise.song().transport:add_scheduled_sequence(number)
else
renoise.app():show_status("This sequence position does not exist.")
end
end

for i = 1,32 do
  local padded_number = string.format("%02d", i - 1)
  
  -- Add keybinding for each sequence
  renoise.tool():add_keybinding{name="Global:Paketti:Add Sequence " .. padded_number .. " to Scheduled List", invoke=function() tknaAddSequenceToScheduledList(i) end}
end


for i = 1, 32 do
  local padded_number = string.format("%02d", i - 1)
  renoise.tool():add_keybinding{
    name="Global:Paketti:Toggle Sequence Loop to " .. padded_number,
    invoke=function()
      local total_sequences = #renoise.song().sequencer.pattern_sequence
      if i <= total_sequences then
        local current_range = renoise.song().transport.loop_sequence_range
        if current_range[1] == i and current_range[2] == i then
          -- Turn off the loop
          renoise.song().transport.loop_sequence_range = {}
          renoise.app():show_status("Sequence loop turned off.")
        else
          -- Set the loop to the specified range
          renoise.song().transport.loop_sequence_range = {i, i}
          renoise.app():show_status("Sequence loop set to " .. padded_number)
        end
      else
        renoise.app():show_status("This sequence does not exist.")
      end
    end
  }
end




renoise.tool():add_keybinding{name="Global:Paketti:Clear Pattern Sequence Loop",invoke=function()
renoise.song().transport.loop_sequence_range = {} end}



-- Function to compare two tables for value equality
function tables_equal(t1, t2)
  if #t1 ~= #t2 then
    return false
  end
  for i = 1, #t1 do
    if t1[i] ~= t2[i] then
      return false
    end
  end
  return true
end

-- Function to set the sequence loop from current loop position to specified position
function setSequenceLoopFromCurrentTo(position)
  local total_sequences = #renoise.song().sequencer.pattern_sequence
  local current_range = renoise.song().transport.loop_sequence_range

  -- Ensure the specified position is within the valid range
  if position > total_sequences then
    renoise.app():show_status("This sequence does not exist.")
    return
  end

  -- Check if current_range is {0,0} using the tables_equal function
  if tables_equal(current_range, {0,0}) then
    renoise.song().transport.loop_sequence_range = {position, position}
    return
  end

  local current_start = current_range[1]

  -- Check if the specified position is valid for setting the loop
  if position < current_start then
    renoise.song().transport.loop_sequence_range = {position, current_start}
    renoise.app():show_status("Sequence loop set from " .. position .. " to " .. current_start)
  else
    renoise.song().transport.loop_sequence_range = {current_start, position}
    renoise.app():show_status("Sequence loop set from " .. current_start .. " to " .. position)
  end
end

-- Loop to create keybindings for setting the loop range from current to specified position
for i = 1, 32 do
  local padded_number = string.format("%02d", i - 1)
  renoise.tool():add_keybinding{name="Global:Paketti:Set Sequence Loop from Current to " .. padded_number,invoke=function()
    setSequenceLoopFromCurrentTo(i)
  end}
end

------

function globalChangeVisibleColumnState(columnName)
  for i=1, renoise.song().sequencer_track_count do
    if renoise.song().tracks[i].type == 1 and columnName == "delay" then
      renoise.song().tracks[i].delay_column_visible = true
    elseif renoise.song().tracks[i].type == 1 and columnName == "volume" then
      renoise.song().tracks[i].volume_column_visible = true
    elseif renoise.song().tracks[i].type == 1 and columnName == "panning" then
      renoise.song().tracks[i].panning_column_visible = true
    elseif renoise.song().tracks[i].type == 1 and columnName == "sample_effects" then
      renoise.song().tracks[i].sample_effects_column_visible = true
    else
      renoise.app():show_status("Invalid column name: " .. columnName)
    end
  end
end



-----------
------------------------------
------------------------------
------------------------------


-- Define the XML content as a string
local InstrautomationXML = [[
<?xml version="1.0" encoding="UTF-8"?>
<FilterDevicePreset doc_version="13">
  <DeviceSlot type="InstrumentAutomationDevice">
    <IsMaximized>true</IsMaximized>
    <ParameterNumber0>0</ParameterNumber0>
    <ParameterNumber1>1</ParameterNumber1>
    <ParameterNumber2>2</ParameterNumber2>
    <ParameterNumber3>3</ParameterNumber3>
    <ParameterNumber4>4</ParameterNumber4>
    <ParameterNumber5>5</ParameterNumber5>
    <ParameterNumber6>6</ParameterNumber6>
    <ParameterNumber7>7</ParameterNumber7>
    <ParameterNumber8>8</ParameterNumber8>
    <ParameterNumber9>9</ParameterNumber9>
    <ParameterNumber10>10</ParameterNumber10>
    <ParameterNumber11>11</ParameterNumber11>
    <ParameterNumber12>12</ParameterNumber12>
    <ParameterNumber13>13</ParameterNumber13>
    <ParameterNumber14>14</ParameterNumber14>
    <ParameterNumber15>15</ParameterNumber15>
    <ParameterNumber16>16</ParameterNumber16>
    <ParameterNumber17>17</ParameterNumber17>
    <ParameterNumber18>18</ParameterNumber18>
    <ParameterNumber19>19</ParameterNumber19>
    <ParameterNumber20>20</ParameterNumber20>
    <ParameterNumber21>21</ParameterNumber21>
    <ParameterNumber22>22</ParameterNumber22>
    <ParameterNumber23>23</ParameterNumber23>
    <ParameterNumber24>24</ParameterNumber24>
    <ParameterNumber25>25</ParameterNumber25>
    <ParameterNumber26>26</ParameterNumber26>
    <ParameterNumber27>27</ParameterNumber27>
    <ParameterNumber28>28</ParameterNumber28>
    <ParameterNumber29>29</ParameterNumber29>
    <ParameterNumber30>30</ParameterNumber30>
    <ParameterNumber31>31</ParameterNumber31>
    <ParameterNumber32>32</ParameterNumber32>
    <ParameterNumber33>33</ParameterNumber33>
    <ParameterNumber34>34</ParameterNumber34>
    <VisiblePages>8</VisiblePages>
  </DeviceSlot>
</FilterDevicePreset>
]]

-- Function to load the preset XML directly into the Instr. Automation device
function openVisiblePagesToFitParameters()
  local song = renoise.song()

  -- Load the Instr. Automation device into the selected track using insert_device_at
  local track = song.selected_track
  track:insert_device_at("Audio/Effects/Native/*Instr. Automation", 2)

  -- Set the active_preset_data to the provided XML content
  renoise.song().selected_track.devices[2].active_preset_data = InstrautomationXML

  -- Debug logging: Confirm the preset has been loaded
  renoise.app():show_status("Preset loaded into Instr. Automation device.")
end

-- Register the function to a menu entry
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Open Visible Pages to Fit Plugin Parameter Count",invoke=openVisiblePagesToFitParameters}
renoise.tool():add_menu_entry{name="DSP Device:Paketti..:Open Visible Pages to Fit Plugin Parameter Count",invoke=openVisiblePagesToFitParameters}

-- Register a keybinding for easier access (optional)
renoise.tool():add_keybinding{name="Global:Paketti:Open Visible Pages to Fit Parameters",invoke=openVisiblePagesToFitParameters}




--------------





-- Mix-Paste Tool for Renoise
-- This tool will mix clipboard data with the pattern data in Renoise

local temp_text_path = renoise.tool().bundle_path .. "temp_mixpaste.txt"
local mix_paste_mode = false

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker MixPaste",invoke=function()
  mix_paste()
end}

function mix_paste()
  if not mix_paste_mode then
    -- First invocation: save selection to text file and perform initial paste
    save_selection_to_text()
    local clipboard_data = load_pattern_data_from_text()
    if clipboard_data then
      print("Debug: Clipboard data loaded for initial paste:\n" .. clipboard_data)
      perform_initial_paste(clipboard_data)
      renoise.app():show_status("Initial mix-paste performed. Run Mix-Paste again to perform the final mix.")
    else
      renoise.app():show_error("Failed to load clipboard data from text file.")
    end
    mix_paste_mode = true
  else
    -- Second invocation: load from text file and perform final mix-paste
    local clipboard_data = load_pattern_data_from_text()
    if clipboard_data then
      print("Debug: Clipboard data loaded for final paste:\n" .. clipboard_data)
      perform_final_mix_paste(clipboard_data)
      mix_paste_mode = false
      -- Clear the temp text file
      local file = io.open(temp_text_path, "w")
      file:write("")
      file:close()
    else
      renoise.app():show_error("Failed to load clipboard data from text file.")
    end
  end
end

function save_selection_to_text()
  local song = renoise.song()
  local selection = song.selection_in_pattern
  if not selection then
    renoise.app():show_error("Please make a selection in the pattern first.")
    return
  end

  -- Capture pattern data using rprint and save to text file
  local pattern_data = {}
  local pattern = song:pattern(song.selected_pattern_index)
  local track_index = song.selected_track_index

  for line_index = selection.start_line, selection.end_line do
    local line_data = {}
    local line = pattern:track(track_index):line(line_index)
    for col_index = 1, #line.note_columns do
      local note_column = line:note_column(col_index)
      table.insert(line_data, string.format("%s %02X %02X %02X %02X", 
        note_column.note_string, note_column.instrument_value, 
        note_column.volume_value, note_column.effect_number_value, 
        note_column.effect_amount_value))
    end
    for col_index = 1, #line.effect_columns do
      local effect_column = line:effect_column(col_index)
      table.insert(line_data, string.format("%02X %02X", 
        effect_column.number_value, effect_column.amount_value))
    end
    table.insert(pattern_data, table.concat(line_data, " "))
  end

  -- Save pattern data to text file
  local file = io.open(temp_text_path, "w")
  file:write(table.concat(pattern_data, "\n"))
  file:close()

  print("Debug: Saved pattern data to text file:\n" .. table.concat(pattern_data, "\n"))
end

function load_pattern_data_from_text()
  local file = io.open(temp_text_path, "r")
  if not file then
    return nil
  end
  local clipboard = file:read("*a")
  file:close()
  return clipboard
end

function perform_initial_paste(clipboard_data)
  local song = renoise.song()
  local track_index = song.selected_track_index
  local line_index = song.selected_line_index
  local pattern = song:pattern(song.selected_pattern_index)
  local track = pattern:track(track_index)

  local clipboard_lines = parse_clipboard_data(clipboard_data)

  for i, clipboard_line in ipairs(clipboard_lines) do
    local line = track:line(line_index + i - 1)
    for col_index, clipboard_note_col in ipairs(clipboard_line.note_columns) do
      if col_index <= #line.note_columns then
        local note_col = line:note_column(col_index)
        if note_col.is_empty then
          note_col.note_string = clipboard_note_col.note_string
          note_col.instrument_value = clipboard_note_col.instrument_value
          note_col.volume_value = clipboard_note_col.volume_value
          note_col.effect_number_value = clipboard_note_col.effect_number_value
          note_col.effect_amount_value = clipboard_note_col.effect_amount_value
        end
      end
    end
    for col_index, clipboard_effect_col in ipairs(clipboard_line.effect_columns) do
      if col_index <= #line.effect_columns then
        local effect_col = line:effect_column(col_index)
        if effect_col.is_empty then
          effect_col.number_value = clipboard_effect_col.number_value
          effect_col.amount_value = clipboard_effect_col.amount_value
        end
      end
    end
  end
end

function perform_final_mix_paste(clipboard_data)
  local song = renoise.song()
  local track_index = song.selected_track_index
  local line_index = song.selected_line_index
  local pattern = song:pattern(song.selected_pattern_index)
  local track = pattern:track(track_index)

  local clipboard_lines = parse_clipboard_data(clipboard_data)

  for i, clipboard_line in ipairs(clipboard_lines) do
    local line = track:line(line_index + i - 1)
    for col_index, clipboard_note_col in ipairs(clipboard_line.note_columns) do
      if col_index <= #line.note_columns then
        local note_col = line:note_column(col_index)
        if not note_col.is_empty then
          if clipboard_note_col.effect_number_value > 0 then
            note_col.effect_number_value = clipboard_note_col.effect_number_value
            note_col.effect_amount_value = clipboard_note_col.effect_amount_value
          end
        end
      end
    end
    for col_index, clipboard_effect_col in ipairs(clipboard_line.effect_columns) do
      if col_index <= #line.effect_columns then
        local effect_col = line:effect_column(col_index)
        if not effect_col.is_empty then
          if clipboard_effect_col.number_value > 0 then
            effect_col.number_value = clipboard_effect_col.number_value
            effect_col.amount_value = clipboard_effect_col.amount_value
          end
        end
      end
    end
  end
end

function parse_clipboard_data(clipboard)
  local lines = {}
  for line in clipboard:gmatch("[^\r\n]+") do
    table.insert(lines, parse_line(line))
  end
  return lines
end

function parse_line(line)
  local note_columns = {}
  local effect_columns = {}
  for note_col_data in line:gmatch("(%S+ %S+ %S+ %S+ %S+)") do
    table.insert(note_columns, parse_note_column(note_col_data))
  end
  for effect_col_data in line:gmatch("(%S+ %S+)") do
    table.insert(effect_columns, parse_effect_column(effect_col_data))
  end
  return {note_columns=note_columns,effect_columns=effect_columns}
end

function parse_note_column(data)
  local note, instrument, volume, effect_number, effect_amount = data:match("(%S+) (%S+) (%S+) (%S+) (%S+)")
  return {
    note_string=note,
    instrument_value=tonumber(instrument, 16),
    volume_value=tonumber(volume, 16),
    effect_number_value=tonumber(effect_number, 16),
    effect_amount_value=tonumber(effect_amount, 16),
  }
end

function parse_effect_column(data)
  local number, amount = data:match("(%S+) (%S+)")
  return {
    number_value=tonumber(number, 16),
    amount_value=tonumber(amount, 16),
  }
end












-------------------------
--------
function Experimental()
    function read_file(path)
        local file = io.open(path, "r")  -- Open the file in read mode
        if not file then
            print("Failed to open file")
            return nil
        end
        local content = file:read("*a")  -- Read the entire content
        file:close()
        return content
    end

    function check_and_execute(xml_path, bash_script)
        local xml_content = read_file(xml_path)
        if not xml_content then
            return
        end

        local pattern = "<ShowScriptingDevelopmentTools>(.-)</ShowScriptingDevelopmentTools>"
        local current_value = xml_content:match(pattern)

        if current_value == "false" then  -- Check if the value is false
            print("Scripting tools are disabled. Executing the bash script to enable...")
            local command = 'open -a Terminal "' .. bash_script .. '"'
            os.execute(command)
        elseif current_value == "true" then
            print("Scripting tools are already enabled. No need to execute the bash script.")
          local bash_script = "/Users/esaruoho/macOS_DisableScriptingTools.sh"
            local command = 'open -a Terminal "' .. bash_script .. '"'
            os.execute(command)
        else
            print("Could not find the <ShowScriptingDevelopmentTools> tag in the XML.")
        end
    end

    local config_path = "/Users/esaruoho/Library/Preferences/Renoise/V3.4.3/Config.xml"
    local bash_script = "/Users/esaruoho/macOS_EnableScriptingTools.sh" -- Ensure this path is correct

    check_and_execute(config_path, bash_script)
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Experimental",invoke=function() Experimental() end}

--Wipes the pattern data, but not the samples or instruments.
--WARNING: Does not reset current filename.
function wipeSongPattern()
local s=renoise.song()
  for i=1,300 do
    if s.patterns[i].is_empty==false then
    s.patterns[i]:clear()
    renoise.song().patterns[i].number_of_lines=64
    else 
    print ("Encountered empty pattern, not deleting")
    renoise.song().patterns[i].number_of_lines=64
    end
  end
end
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Song Patterns", invoke=function() wipeSongPattern() end}

function AutoGapper()
-- Something has changed with the Filter-device:
--*** ./Experimental_Verify.lua:30: attempt to index field '?' (a nil value)
--*** stack traceback:
--***   ./Experimental_Verify.lua:30: in function 'AutoGapper'
--***   ./Experimental_Verify.lua:37: in function <./Experimental_Verify.lua:37>

--renoise.song().tracks[get_master_track_index()].visible_effect_columns = 4  
local gapper=nil
renoise.app().window.active_lower_frame=1
renoise.app().window.lower_frame_is_visible=true
  loadnative("Audio/Effects/Native/Filter")
  loadnative("Audio/Effects/Native/*LFO")
  renoise.song().selected_track.devices[2].parameters[2].value=2
  renoise.song().selected_track.devices[2].parameters[3].value=1
  renoise.song().selected_track.devices[2].parameters[7].value=2
  renoise.song().selected_track.devices[3].parameters[5].value=0.0074
local gapper=renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines*2*4
  renoise.song().selected_track.devices[2].parameters[6].value_string=tostring(gapper)
--renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[4].number_string = "18"
end
--renoise.tool():add_keybinding{name="Global:Paketti:Add Filter & LFO (AutoGapper)", invoke=function() AutoGapper() end}
------------
function start_stop_sample_and_loop_oh_my()
local w=renoise.app().window
local s=renoise.song()
local t=s.transport
local ss=s.selected_sample
local currTrak=s.selected_track_index
local currPatt=s.selected_pattern_index

if w.sample_record_dialog_is_visible then
    -- we are recording, stop
    t:start_stop_sample_recording()
    -- write note
     ss.autoseek=true
     s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
     s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"

for i= 1,12 do
if s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].is_empty==true then
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].note_string="C-4"
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].instrument_value=s.selected_instrument_index-1
else
 if i == renoise.song().tracks[currTrak].visible_note_columns and i == 12
  then renoise.song():insert_track_at(renoise.song().selected_track_index)
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[1].note_string="C-4"
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[1].instrument_value=s.selected_instrument_index-1
end
end
end
    -- hide dialog
    w.sample_record_dialog_is_visible = false
  else
    -- not recording. show dialog, start recording.
    w.sample_record_dialog_is_visible = true
    t:start_stop_sample_recording()
  end
end

--renoise.tool():add_keybinding{name="Global:Paketti:Stair RecordToCurrent", invoke=function() 
--if renoise.song().transport.playing==false then
    --renoise.song().transport.playing=true end
--start_stop_sample_and_loop_oh_my() end}
--
--function stairs()
--local currCol=nil
--local addCol=nil
--currCol=renoise.song().selected_note_column_index
---
--if renoise.song().selected_track.visibile_note_columns and renoise.song().selected_note_column_index == 12   then 
--renoise.song().selected_note_column_index = 1
--end
--
--
--if currCol == renoise.song().selected_track.visible_note_columns
--then renoise.song().selected_track.visible_note_columns = addCol end
--
--renoise.song().selected_note_column_index=currCol+1
--
--end
--renoise.tool():add_keybinding{name="Global:Paketti:Stair", invoke=function() stairs() end}

function effectbypasspattern()
local currTrak = renoise.song().selected_track_index
local number = (table.count(renoise.song().selected_track.devices))
 for i=2,number  do 
  --renoise.song().selected_track.devices[i].is_active=false
  renoise.song().selected_track.visible_effect_columns=(table.count(renoise.song().selected_track.devices)-1)
--This would be (1-8F)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[1].number_string="10"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[2].number_string="20"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[3].number_string="30"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[4].number_string="40"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[5].number_string="50"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[6].number_string="60"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[7].number_string="70"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[8].number_string="80"
--this would be 00 for disabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="00"
 end
end

function effectenablepattern()
local currTrak = renoise.song().selected_track_index
local number = (table.count(renoise.song().selected_track.devices))
for i=2,number  do 
--enable all plugins on selected track right now
--renoise.song().selected_track.devices[i].is_active=true
--display max visible effects
local helper=(table.count(renoise.song().selected_track.devices)-1)
renoise.song().selected_track.visible_effect_columns=helper
--This would be (1-8F)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[1].number_string="10"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[2].number_string="20"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[3].number_string="30"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[4].number_string="40"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[5].number_string="50"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[6].number_string="60"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[7].number_string="70"
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[8].number_string="80"

--this would be 01 for enabling
local ooh=(i-1)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[currTrak].lines[1].effect_columns[ooh].amount_string="01"
end
end
------
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Bypass All Devices on Channel", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Enable All Devices on Channel", invoke=function() effectenable() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Bypass 8 Track DSP Devices (Write to Pattern)", invoke=function() effectbypasspattern() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Enable 8 Track DSP Devices (Write to Pattern)", invoke=function() effectenablepattern()  end}
----------------------------

-- has-line-input + add-line-input
function has_line_input()
-- Write some code to find the line input in the correct place
local tr = renoise.song().selected_track
 if tr.devices[2] and tr.devices[2].device_path=="Audio/Effects/Native/#Line Input" 
  then return true
 else
  return false
 end
end

function add_line_input()
-- Write some code to add the line input in the correct place
 loadnative("Audio/Effects/Native/#Line Input")
end

function remove_line_input()
-- Write some code to remove the line input if it's in the correct place
 renoise.song().selected_track:delete_device_at(2)
end

-- recordamajic
function recordamajic9000(running)
    if running then
    renoise.song().transport.playing=true
        -- start recording code here
renoise.app().window.sample_record_dialog_is_visible=true
renoise.app().window.lock_keyboard_focus=true
renoise.song().transport:start_stop_sample_recording()
    else
    -- Stop recording here
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Recordammajic9000",
invoke=function() if has_line_input() then 
      recordtocurrenttrack()    
      G01()
 else add_line_input()
      recordtocurrenttrack()
      G01()
 end end}

-- turn samplerecorder ON
function SampleRecorderOn()
local howmany = table.count(renoise.song().selected_track.devices)

if renoise.app().window.sample_record_dialog_is_visible==false then
renoise.app().window.sample_record_dialog_is_visible=true 

  if howmany == 1 then 
    loadnative("Audio/Effects/Native/#Line Input")
    return
  else
    if renoise.song().selected_track.devices[2].name=="#Line Input" then
    renoise.song().selected_track:delete_device_at(2)
    renoise.app().window.sample_record_dialog_is_visible=false
    else
    loadnative("Audio/Effects/Native/#Line Input")
    return
end    
  end  

else renoise.app().window.sample_record_dialog_is_visible=false
  if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Display Sample Recorder with #Line Input", invoke=function() SampleRecorderOn() end}

function glideamount(amount)
local counter=nil 
for i=renoise.song().selection_in_pattern.start_line,renoise.song().selection_in_pattern.end_line 
do renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].number_string="0G" 
counter=renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].amount_value+amount 

if counter > 255 then counter=255 end
if counter < 1 then counter=0 
end
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].amount_value=counter 
end
end

local s = nil

function startup_()
  local s=renoise.song()
--   renoise.app().window:select_preset(1)
   
   renoise.song().instruments[s.selected_instrument_index].active_tab=1
    if renoise.app().window.active_middle_frame==0 and s.selected_sample.sample_buffer_observable:has_notifier(sample_loaded_change_to_sample_editor) then 
    s.selected_sample.sample_buffer_observable:remove_notifier(sample_loaded_change_to_sample_editor)
    else
  --s.selected_sample.sample_buffer_observable:add_notifier(sample_loaded_change_to_sample_editor)

    return
    end
end

  function sample_loaded_change_to_sample_editor()
--    renoise.app().window.active_middle_frame=4
  end

if not renoise.tool().app_new_document_observable:has_notifier(startup_) 
   then renoise.tool().app_new_document_observable:add_notifier(startup_)
   else renoise.tool().app_new_document_observable:remove_notifier(startup_)
end
--------------------------------------------------------------------------------
function PakettiCapsLockNoteOffNextPtn()   
local s=renoise.song()
local wrapping=s.transport.wrapped_pattern_edit
local editstep=s.transport.edit_step

local currLine=s.selected_line_index
local currPatt=s.selected_pattern_index

local counter=nil
local addlineandstep=nil
local counting=nil
local seqcount=nil
local resultPatt=nil

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="FF"
then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=""
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=""
return
else
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"
then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00"  
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return
end

if renoise.song().transport.edit_mode==true then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"  
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="CF"
return
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"

then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00" 
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string~=nil then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="FF"
return
else 
if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=="OFF" then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
return
else
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
end

--s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
end

addlineandstep=currLine+editstep
seqcount = currPatt+1

if addlineandstep > s.patterns[currPatt].number_of_lines then
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
counting=addlineandstep-s.patterns[currPatt].number_of_lines
 if seqcount > (table.count(renoise.song().sequencer.pattern_sequence)) then 
 seqcount = (table.count(renoise.song().sequencer.pattern_sequence))
 s.selected_sequence_index=seqcount
 end
 
resultPatt=currPatt+1 
 if resultPatt > #renoise.song().sequencer.pattern_sequence then 
 resultPatt = (table.count(renoise.song().sequencer.pattern_sequence))
s.selected_sequence_index=resultPatt
s.selected_line_index=counting
end
else 
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
--s.selected_sequence_index=currPatt+1
s.selected_line_index=addlineandstep

counter = addlineandstep-1

renoise.app():show_status("Now on: " .. counter .. "/" .. s.patterns[currPatt].number_of_lines .. " In Pattern: " .. currPatt)
end
end
----
function PakettiCapsLockNoteOff()   
local s=renoise.song()
local st=s.transport
local wrapping=st.wrapped_pattern_edit
local editstep=st.edit_step

local currLine=s.selected_line_index
local currPatt=s.selected_sequence_index

local counter=nil
local addlineandstep=nil
local counting=nil
local seqcount=nil

if renoise.song().patterns[renoise.song().selected_sequence_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=="OFF" then 

s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
return
else end

if not s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=="OFF"
then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
else s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
end

addlineandstep=currLine+editstep
seqcount = currPatt+1

if addlineandstep > s.patterns[currPatt].number_of_lines then
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
counting=addlineandstep-s.patterns[currPatt].number_of_lines
 if seqcount > (table.count(renoise.song().sequencer.pattern_sequence)) then 
 seqcount = (table.count(renoise.song().sequencer.pattern_sequence))
 s.selected_sequence_index=seqcount
 end
--s.selected_sequence_index=currPatt+1
s.selected_line_index=counting
else 
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
--s.selected_sequence_index=currPatt+1
s.selected_line_index=addlineandstep

counter = addlineandstep-1

renoise.app():show_status("Now on: " .. counter .. "/" .. s.patterns[currPatt].number_of_lines .. " In Pattern: " .. currPatt)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Note Off / Caps Lock replacement", invoke=function() 
if renoise.song().transport.wrapped_pattern_edit == false then PakettiCapsLockNoteOffNextPtn() 
else PakettiCapsLockNoteOff() end
end}
--------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Record to Current Track+Plus", 
invoke=function() 
      renoise.app().window.active_lower_frame=1
local howmany = table.count(renoise.song().selected_track.devices)

if howmany == 1 then 
loadnative("Audio/Effects/Native/#Line Input")
recordtocurrenttrack()
return
else
if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  recordtocurrenttrack()
  return
else
  loadnative("Audio/Effects/Native/#Line Input")
  recordtocurrenttrack()
  return
end end end}

renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Record To Current", invoke=function() recordtocurrenttrack() end}
----------------------------------------------------------------------------------------------------------
--esa- 2nd keybind for Record Toggle ON/OFF with effect_column reading
function RecordToggle()
 local a=renoise.app()
 local s=renoise.song()
 local t=s.transport
 local currentstep=t.edit_step
--if has notifier, dump notifier, if no notifier, add notifier
 if t.edit_mode then
    t.edit_mode=false
 if t.edit_step==0 then
    t.edit_step=1
 else
  return
 end 
 else
      t.edit_mode = true
   if s.selected_effect_column_index == 1 then t.edit_step=0
   elseif s.selected_effect_column_index == 0 then t.edit_step=currentstep return
   end
end
end
----------------------------------------
require "Research/FormulaDeviceManual"

renoise.tool():add_keybinding{name="Global:Paketti:FormulaDevice", invoke=function()  
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().tracks[renoise.song().selected_track_index]:insert_device_at("Audio/Effects/Native/*Formula", 2)  
local infile = io.open( "Research/FormulaDeviceXML.txt", "rb" )
local indata = infile:read( "*all" )
renoise.song().tracks[renoise.song().selected_track_index].devices[2].active_preset_data = indata
infile:close()

show_manual (
    "Formula Device Documentation", -- manual dialog title
    "Research/FormulaDevice.txt" -- the textfile which contains the manual
  )
end}
---------------------------
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Disk Browser Focus",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(7) end}

renoise.tool():add_keybinding{name="Global:Paketti:Disk Browser Focus",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(8) end}

renoise.tool():add_keybinding{name="Global:Paketti:Disk Browser Focus (2nd)",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(8) end}

renoise.tool():add_keybinding{name="Global:Paketti:Contour Shuttle Disk Browser Focus",invoke=function() renoise.app().window:select_preset(8) end}
------------------------------------------------------------------------------------------------
function G01()
local s=renoise.song()
  local currTrak=s.selected_track_index
  local currPatt=s.selected_pattern_index
local rightinstrument=nil
local rightinstrument=renoise.song().selected_instrument_index-1
  if not preferences._0G01_Loader.value then return end

local line=s.patterns[currPatt].tracks[currTrak].lines[1]
    line.note_columns[1].note_string="C-4"
    line.note_columns[1].instrument_value=rightinstrument
    s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
    s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"
end
--------- inspect

function writeToClipboard(text)
    -- Using AppleScript to handle clipboard operations
    local safe_text = text:gsub('"', '\\"')  -- Escape double quotes for AppleScript
    local command = 'osascript -e \'set the clipboard to "' .. safe_text .. '"\''

    -- Execute the command and check for errors
    local success, exit_code, exit_reason = os.execute(command)
    if success then
        print("Successfully copied to clipboard: " .. text)
    else
        print("Failed to copy to clipboard:", exit_reason, "(exit code " .. tostring(exit_code) .. ")")
    end
end
---------
function move_up(chg)
local sindex=renoise.song().selected_line_index
local s= renoise.song()
local note=s.selected_note_column
--This switches currently selected row but doesn't 
--move the note
--s.selected_line_index = (sindex+chg)
-- moving note up, applying correct delay value and moving cursor up goes here
end
--movedown
function move_down(chg)
local sindex=renoise.song().selected_line_index
local s= renoise.song()
--This switches currently selected row but doesn't 
--move the note
--s.selected_line_index = (sindex+chg)
-- moving note down, applying correct delay value and moving cursor down goes here
end


-- Function to adjust the delay value of the selected note column within the current phrase
-- TODO: missing API for reading phrase.selected_line_index. can't work
function Phrplusdelay(chg)
  local song = renoise.song()
  local nc = song.selected_note_column

  -- Check if a note column is selected
  if not nc then
    local message = "No note column is selected!"
    renoise.app():show_status(message)
    print(message)
    return
  end

  local currTrak = song.selected_track_index
  local currInst = song.selected_instrument_index
  local currPhra = song.selected_phrase_index
  local sli = song.selected_line_index
  local snci = song.selected_note_column_index

  -- Check if a phrase is selected
  if currPhra == 0 then
    local message = "No phrase is selected!"
    renoise.app():show_status(message)
    print(message)
    return
  end

  -- Ensure delay columns are visible in both track and phrase
  song.instruments[currInst].phrases[currPhra].delay_column_visible = true
  song.tracks[currTrak].delay_column_visible = true

  -- Get current delay value from the selected note column in the phrase
  local phrase = song.instruments[currInst].phrases[currPhra]
  local line = phrase:line(sli)
  local note_column = line:note_column(snci)
  local Phrad = note_column.delay_value

  -- Adjust delay value, ensuring it stays within 0-255 range
  note_column.delay_value = math.max(0, math.min(255, Phrad + chg))

  -- Show and print status message
  local message = "Delay value adjusted by " .. chg .. " at line " .. sli .. ", column " .. snci
  renoise.app():show_status(message)
  print(message)

  -- Show and print visible note columns and effect columns
  local visible_note_columns = phrase.visible_note_columns
  local visible_effect_columns = phrase.visible_effect_columns
  local columns_message = string.format("Visible Note Columns: %d, Visible Effect Columns: %d", visible_note_columns, visible_effect_columns)
  renoise.app():show_status(columns_message)
  print(columns_message)
end

-- Add keybindings for adjusting the delay value
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +1",invoke=function() Phrplusdelay(1) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -1",invoke=function() Phrplusdelay(-1) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +10",invoke=function() Phrplusdelay(10) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -10",invoke=function() Phrplusdelay(-10) end}


---------------------------------------------------------------------------------------------------------

----------

function delay(seconds)
    local command = "sleep " .. tonumber(seconds)
    os.execute(command)
end


----------
function pattern_line_notifier(pos) --here
  local colnumber=nil
  local countline=nil
  local count=nil
--  print (pos.pattern)
--  print (pos.track)
--  print (pos.line)

local s=renoise.song() 
local t=s.transport
if t.edit_step==0 then 
count=s.selected_note_column_index+1

if count == s.tracks[s.selected_track_index].visible_note_columns then s.selected_note_column_index=count return end
if count > s.tracks[s.selected_track_index].visible_note_columns then 
local slicount=nil
slicount=s.selected_line_index+1 
if slicount > s.patterns[s.selected_pattern_index].number_of_lines
then 
s.selected_line_index=s.patterns[s.selected_pattern_index].number_of_lines end
count=1 
s.selected_note_column_index=count return
else s.selected_note_column_index=count return end
end

countline=s.selected_line_index+1---1+renoise.song().transport.edit_step
   if t.edit_step>1 then
   countline=countline-1
   else countline=s.selected_line_index end
   --print ("countline is selected line index +1" .. countline)
   --print ("editstep" .. renoise.song().transport.edit_step)
   if countline > s.patterns[s.selected_pattern_index].number_of_lines
   then countline=1
   end
   s.selected_line_index=countline
 
   colnumber=s.selected_note_column_index+1
   if colnumber > s.tracks[s.selected_track_index].visible_note_columns then
   s.selected_note_column_index=1
   return end
  s.selected_note_column_index=colnumber end
  
function startcolumncycling(number) -- here
local s=renoise.song()
  if s.patterns[s.selected_pattern_index]:has_line_notifier(pattern_line_notifier) 
then s.patterns[s.selected_pattern_index]:remove_line_notifier(pattern_line_notifier)
 renoise.app():show_status(number .. " Column Cycle Keyjazz Off")
else s.patterns[s.selected_pattern_index]:add_line_notifier(pattern_line_notifier)
 renoise.app():show_status(number .. " Column Cycle Keyjazz On") end
end

for cck=1,12 do
renoise.tool():add_keybinding{name="Global:Paketti:Column Cycle Keyjazz " .. cck,invoke=function() displayNoteColumn(cck) startcolumncycling(cck) end}
end

renoise.tool():add_keybinding{name="Global:Paketti:Start/Stop Column Cycling",invoke=function() startcolumncycling() 
  if renoise.song().patterns[renoise.song().selected_pattern_index]:has_line_notifier(pattern_line_notifier)
then renoise.app():show_status("Column Cycle Keyjazz On")
else renoise.app():show_status("Column Cycle Keyjazz Off") end end}

renoise.tool():add_keybinding{name="Global:Paketti:Column Cycle Keyjazz 01_Special",invoke=function() 
displayNoteColumn(12) 
GenerateDelayValue()
renoise.song().transport.edit_mode=true
renoise.song().transport.edit_step=0
renoise.song().selected_note_column_index=1
startcolumncycling(12) end}
----------------------------



