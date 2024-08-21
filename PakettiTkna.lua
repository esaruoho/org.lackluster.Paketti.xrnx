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
  renoise.tool():add_keybinding{name="Global:Paketti:Select and Loop Sequence Section " .. string.format("%02d", section_number),
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
renoise.tool():add_midi_mapping{name="Paketti:Continue Sequence From Same Line [Set Sequence]", invoke=function(message)
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
renoise.tool():add_midi_mapping{name="Paketti:Set Current Section as Scheduled Sequence",invoke=tknaSetCurrentSectionAsScheduledSequence}
renoise.tool():add_midi_mapping{name="Paketti:Add Current Section to Scheduled Sequences",invoke=tknaAddCurrentSectionToScheduledSequences}


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
renoise.tool():add_midi_mapping{name="Paketti:Section Loop (Next)",invoke=expandSectionLoopNext}
renoise.tool():add_midi_mapping{name="Paketti:Section Loop (Previous)",invoke=expandSectionLoopPrevious}



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
renoise.tool():add_midi_mapping{name="Paketti:Sequence Selection (Next)",invoke=tknaSequenceSelectionPlusOne}
renoise.tool():add_midi_mapping{name="Paketti:Sequence Selection (Previous)",invoke=tknaSequenceSelectionMinusOne}

-- Function to expand the loop selection to the next sequence
function tknaSequenceLoopSelectionNext()
  local song = renoise.song()
  local transport = song.transport
  local sequencer = song.sequencer
  local total_sequences = #sequencer.pattern_sequence
  local loop_range = transport.loop_sequence_range
  local current_sequence_index = song.selected_sequence_index

  -- If no loop range or an invalid loop range exists, select the current sequence
  if not loop_range or #loop_range ~= 2 or (loop_range[1] == 0 and loop_range[2] == 0) then
    transport.loop_sequence_range = {current_sequence_index, current_sequence_index}
  else
    local loop_start = loop_range[1]
    local loop_end = loop_range[2]

    -- If the loop end is less than the total number of sequences
    if loop_end < total_sequences then
      -- Extend the loop range by including the next sequence
      transport.loop_sequence_range = {loop_start, loop_end + 1}
    else
      -- No more sequences to add to the loop
      renoise.app():show_status("No more to add, at end of song")
    end
  end
end

-- Function to expand the loop selection to the previous sequence
function tknaSequenceLoopSelectionPrevious()
  local song = renoise.song()
  local transport = song.transport
  local sequencer = song.sequencer
  local total_sequences = #sequencer.pattern_sequence
  local loop_range = transport.loop_sequence_range
  local current_sequence_index = song.selected_sequence_index

  -- If no loop range or an invalid loop range exists, select the current sequence
  if not loop_range or #loop_range ~= 2 or (loop_range[1] == 0 and loop_range[2] == 0) then
    transport.loop_sequence_range = {current_sequence_index, current_sequence_index}
  else
    local loop_start = loop_range[1]
    local loop_end = loop_range[2]

    -- If the loop start is greater than 1
    if loop_start > 1 then
      -- Extend the loop range by including the previous sequence
      transport.loop_sequence_range = {loop_start - 1, loop_end}
    else
      -- No more sequences to add to the loop
      renoise.app():show_status("No more to add, at beginning of song")
    end
  end
end

-- Adding keybindings for the functions
renoise.tool():add_keybinding{name="Global:Paketti:Sequence Loop Selection (Next)",invoke=tknaSequenceLoopSelectionNext}
renoise.tool():add_keybinding{name="Global:Paketti:Sequence Loop Selection (Previous)",invoke=tknaSequenceLoopSelectionPrevious}

-- Adding menu entries for the functions
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Sequence Loop Selection (Next)",invoke=tknaSequenceLoopSelectionNext}
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Sequence Loop Selection (Previous)",invoke=tknaSequenceLoopSelectionPrevious}

-- Adding MIDI mappings for the functions
renoise.tool():add_midi_mapping{name="Paketti:Sequence Loop Selection (Next)",invoke=tknaSequenceLoopSelectionNext}
renoise.tool():add_midi_mapping{name="Paketti:Sequence Loop Selection (Previous)",invoke=tknaSequenceLoopSelectionPrevious}

-- Function to add a loop to the current section content and schedule the section to play from the first sequence
function tknaAddLoopAndScheduleSection()
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

  -- Set the loop and schedule sequence to the current section if it exists
  if current_section_index then
    -- Set loop sequence range
    transport.loop_sequence_range = {current_section_start, current_section_end}
    
    -- Set scheduled sequence
    transport:set_scheduled_sequence(current_section_start)

    -- Show status message
    renoise.app():show_status("Loop added to current section and scheduled to play from the first sequence.")
  else
    renoise.app():show_status("Current sequence is not inside any section.")
  end
end

-- Add a global keybinding
renoise.tool():add_keybinding{name="Global:Paketti:Set Section Loop and Schedule Section",
  invoke=tknaAddLoopAndScheduleSection
}

-- Add a global MIDI mapping
renoise.tool():add_midi_mapping{name="Paketti:Set Section Loop and Schedule Section [Knob]",
  invoke=function(message)
    if message:is_trigger() then
      tknaAddLoopAndScheduleSection()
    end
  end
}

function tknaSetScheduledSequenceToCurrentSequenceAndLoop()
  local song = renoise.song()
  local selection_start = song.selected_sequence_index
  local selection_end = song.selected_sequence_index

  if song.transport.loop_sequence_range[1] == selection_start and 
     song.transport.loop_sequence_range[2] == selection_end then
    song.transport.loop_sequence_range = {}
  else
    song.transport.loop_sequence_range = { selection_start, selection_end }
  end

  local current_sequence_index = song.selected_sequence_index
  if song.transport.playing then else song.transport.playing=true end
  local total_sequences = #song.sequencer.pattern_sequence
  if current_sequence_index <= total_sequences then
    song.transport:set_scheduled_sequence(current_sequence_index)
  else
    renoise.app():show_status("This sequence position does not exist.")
  end
end

-- Add keybinding for the new function
renoise.tool():add_keybinding{name="Global:Paketti:Set Current Sequence as Scheduled and Loop", invoke=tknaSetScheduledSequenceToCurrentSequenceAndLoop}



