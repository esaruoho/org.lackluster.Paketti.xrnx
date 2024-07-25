-- Global Variables
local RUNTIME = tostring(os.time())
local SAMPLE_LENGTH = 10
local dialog = nil
local pakettiColugaMacOSBashScriptPath = "Coluga/PakettiColuga.sh"

-- Function to execute a bash script
local function pakettiColugaExecuteBashScript(search_phrase, youtube_url, download_dir, clip_length, full_video)
  local script_content = string.format([[
#!/bin/bash

SEARCH_PHRASE="%s"
YOUTUBE_URL="%s"
DOWNLOAD_DIR="%s"
CLIP_LENGTH="%d"
FULL_VIDEO="%s"
TEMP_DIR="$DOWNLOAD_DIR/tempfolder"
COMPLETION_SIGNAL_FILE="$TEMP_DIR/download_completed.txt"
FILENAMES_FILE="$TEMP_DIR/filenames.txt"

echo "Starting PakettiColuga.sh with arguments:"
echo "SEARCH_PHRASE: $SEARCH_PHRASE"
echo "YOUTUBE_URL: $YOUTUBE_URL"
echo "DOWNLOAD_DIR: $DOWNLOAD_DIR"
echo "CLIP_LENGTH: $CLIP_LENGTH"
echo "FULL_VIDEO: $FULL_VIDEO"

mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$TEMP_DIR"

rm -f "$TEMP_DIR"/*.wav
rm -f "$COMPLETION_SIGNAL_FILE"
> "$FILENAMES_FILE"

cd "$TEMP_DIR" || exit

sanitize_filename() {
  echo "$1" | tr -cd '[:alnum:]._-'
}

if [ "$YOUTUBE_URL" != "" ]; then
  if [ "$FULL_VIDEO" == "true" ]; then
    echo "Downloading full video from URL..."
    yt-dlp -f ba --extract-audio --audio-format wav -o "${TEMP_DIR}/%%(title)s-%%(id)s.%%(ext)s" "$YOUTUBE_URL"
  else
    echo "Downloading clip of length ${CLIP_LENGTH} seconds from URL..."
    yt-dlp --download-sections "*0-${CLIP_LENGTH}" -f ba --extract-audio --audio-format wav -o "${TEMP_DIR}/%%(title)s-%%(id)s.%%(ext)s" "$YOUTUBE_URL"
  fi
else
  if [ "$FULL_VIDEO" == "true" ]; then
    echo "Downloading full video as audio..."
    yt-dlp -f ba --extract-audio --audio-format wav -o "${TEMP_DIR}/%%(title)s-%%(id)s.%%(ext)s" "ytsearch1:$SEARCH_PHRASE"
  else
    echo "Downloading clip of length ${CLIP_LENGTH} seconds..."
    yt-dlp --download-sections "*0-${CLIP_LENGTH}" -f ba --extract-audio --audio-format wav -o "${TEMP_DIR}/%%(title)s-%%(id)s.%%(ext)s" "ytsearch1:$SEARCH_PHRASE"
  fi
fi

# Sanitize filenames
for file in *.wav; do
  [ -e "$file" ] || continue
  sanitized_file=$(sanitize_filename "$file")
  if [ "$file" != "$sanitized_file" ]; then
    mv "$file" "$sanitized_file"
    echo "Renamed '$file' to '$sanitized_file'"
  fi
  echo "$sanitized_file" >> "$FILENAMES_FILE"
done

# Signal completion
touch "$COMPLETION_SIGNAL_FILE"

echo "PakettiColuga.sh finished."
]], search_phrase, youtube_url, download_dir, clip_length, tostring(full_video))

  local script_file = io.open(pakettiColugaMacOSBashScriptPath, "w")
  script_file:write(script_content)
  script_file:close()
  os.execute("chmod +x " .. pakettiColugaMacOSBashScriptPath)

  local command = 'open -a Terminal "' .. pakettiColugaMacOSBashScriptPath .. '"'
  print("Executing command: " .. command)
  os.execute(command)
end

-- Function to load downloaded samples into Renoise
local function pakettiColugaLoadVideoAudioIntoRenoise(download_dir, loop_mode, create_new_instrument)
  local temp_dir = download_dir .. "/tempfolder"
  local completion_signal_file = temp_dir .. "/download_completed.txt"
  local filenames_file = temp_dir .. "/filenames.txt"
  
  -- Wait until the completion signal file is created
  while not io.open(completion_signal_file, "r") do
    os.execute('sleep 1')
  end

  -- Wait until the filenames.txt file is created and contains data
  local filenames
  repeat
    local file = io.open(filenames_file, "r")
    if file then
      filenames = file:read("*a")
      file:close()
    end
    os.execute('sleep 1')
  until filenames and #filenames > 0

  -- Read sanitized filenames from the filenames.txt file
  local sample_files = {}
  for line in filenames:gmatch("[^\r\n]+") do
    table.insert(sample_files, temp_dir .. "/" .. line:match('^"?([^"]*)"?$'))
  end

  if #sample_files == 0 then
    print("No samples found in directory: " .. temp_dir)
    return
  end

  print("Found " .. #sample_files .. " sample(s) in directory: " .. temp_dir)

  -- Ensure files are fully available
  for _, file in ipairs(sample_files) do
    local file_size = -1
    repeat
      local current_file_size = io.open(file, "r"):seek("end")
      if current_file_size == file_size then break end
      file_size = current_file_size
      os.execute('sleep 1')
    until false
  end

  local selected_instrument_index = renoise.song().selected_instrument_index

if create_new_instrument then
  print("This is what I have selected now")
  print(renoise.song().selected_instrument_index)

  selected_instrument_index = renoise.song().selected_instrument_index + 1
  print("Changed Selected Instrument Index")
  
  renoise.song():insert_instrument_at(selected_instrument_index)
  print("I have inserted an instrument at selected_instrument_index which is selected_instrument_index + 1")
  
  print("Selected instrument index before setting: ", renoise.song().selected_instrument_index)
  renoise.song().selected_instrument_index = selected_instrument_index
  print("Selected instrument index after setting: ", renoise.song().selected_instrument_index)
  
  pakettiPreferencesDefaultInstrumentLoader()
  print("I have now used the Default Instrument Loader.")
  
  print("Selected instrument index after loading instrument: ", renoise.song().selected_instrument_index)
end


  local instrument = renoise.song().instruments[selected_instrument_index]

  for _, file in ipairs(sample_files) do
    print("Checking file: " .. file)
    if io.open(file, "r") then
      local sample = instrument:insert_sample_at(1)
      sample.sample_buffer:load_from(file)
      sample.name = file:match("^.+/(.+)$")
      instrument.name = sample.name
      print("Loaded sample: " .. file)
      sample.loop_mode = loop_mode
    else
      print("File does not exist: " .. file)
    end
  end

  for _, file in ipairs(sample_files) do
    local dest_file = download_dir .. "/" .. file:match("^.+/(.+)$")
    os.rename(file, dest_file)
    print("Moved '" .. file .. "' to '" .. dest_file .. "'")
  end

  local file = io.open(filenames_file, "w")
  file:close()

  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

-- Key Handler function for the dialog
local function PakettiColugaKeyHandlerFunc(dialog, key)
  if key.modifiers == "" and key.name == "exclamation" then
    print("Exclamation key pressed, closing dialog.")
    dialog:close()
  else
    return key
  end
end

-- Detect OS Platform
local os_name = os.platform()

if os_name == "WINDOWS" then
  renoise.app():show_warning("Coluga is not yet ready to run a script in Windows")
  return
end

-- GUI Dialog Content Creation function
local function PakettiColugaDialogContent()
  local vb = renoise.ViewBuilder()
  local loop_modes = {"Off", "Forward", "Backward", "PingPong"}
  local dialog_content = vb:column {
    margin = 10,
    vb:row { margin = 5, vb:column { width = 150, vb:text { text = "Search Phrase:" }, vb:text { text = "YouTube URL:" }, vb:text { text = "Output Directory:" }, vb:text { text = "Clip Length (seconds):" }, vb:text { text = "Loop Mode:" }, vb:text { text = "Amount of Videos to Search for:" } },
      vb:column { width = 600, vb:textfield { id = "search_phrase", width = 400 }, vb:textfield { id = "youtube_url", width = 400 }, vb:row { vb:textfield { id = "output_dir", width = 400, text = preferences.pakettiColuga.pakettiColugaOutputDirectory.value }, vb:button { text = "Browse", notifier = function() local dir = renoise.app():prompt_for_path("Select Output Directory") if dir then vb.views.output_dir.text = dir preferences.pakettiColuga.pakettiColugaOutputDirectory.value = dir end end }, }, vb:valuebox { id = "clip_length", min = 1, max = 60, value = preferences.pakettiColuga.pakettiColugaClipLength.value or SAMPLE_LENGTH, notifier = function(value) preferences.pakettiColuga.pakettiColugaClipLength.value = value end }, vb:switch { id = "loop_mode", items = loop_modes, value = preferences.pakettiColuga.pakettiColugaLoopMode.value or 2, width=300 }, vb:valuebox { id = "video_amount", min = 1, max = 100, value = preferences.pakettiColuga.pakettiColugaAmountOfVideos.value or 1, notifier = function(value) preferences.pakettiColuga.pakettiColugaAmountOfVideos.value = value end }, }, },
    vb:row {vb:checkbox { id = "full_video", value = preferences.pakettiColuga.pakettiColugaLoadWholeVideo.value, notifier = function(value) if value then vb.views.clip_length.value = SAMPLE_LENGTH end end }, vb:text { text = "Download Whole Video as Audio" }, },
    vb:row {vb:checkbox { id = "create_new_instrument", value = preferences.pakettiColuga.pakettiColugaNewInstrumentOrSameInstrument.value }, vb:text { text = "Create New Instrument for Each Downloaded Audio" }, },
    vb:row {vb:text { text = "Save Successfully Downloaded Audio to Selected Folder" } },
    vb:row {vb:switch { id = "save_format", items = {"Off", "Save WAV", "Save FLAC"}, value = preferences.pakettiColuga.pakettiColugaFormatToSave.value or 1, width=300 }, },
    vb:row {vb:text { text = "Save Path: " }, vb:text { id = "save_path", text = preferences.pakettiColuga.pakettiColugaPathToSave.value or "<No path set>", font = "bold" }, vb:button { text = "Browse", notifier = function() local dir = renoise.app():prompt_for_path("Select Save Path") if dir then vb.views.save_path.text = dir preferences.pakettiColuga.pakettiColugaPathToSave.value = dir end end }, },
    vb:row {vb:button { text = "Start", notifier = function()
      local search_phrase = vb.views.search_phrase.text
      local youtube_url = vb.views.youtube_url.text
      local output_dir = vb.views.output_dir.text
      if output_dir == "" or output_dir == "<No path set>" then
        renoise.app():show_status("You need to set the Output Directory before we can start downloading audio")
        renoise.app():show_message("You need to set the Output Directory before we can start downloading audio")
        return
      end
      local clip_length = vb.views.clip_length.value
      local full_video = vb.views.full_video.value
      local loop_mode = vb.views.loop_mode.value
      local create_new_instrument = vb.views.create_new_instrument.value
      local save_format = vb.views.save_format.items[vb.views.save_format.value]
      local save_to_folder = save_format ~= "Off"
      local save_path = vb.views.save_path.text

      if save_to_folder and save_path == "<No path set>" then
        renoise.app():show_status("You need to set the Save Path before we can start downloading audio")
        renoise.app():show_message("You need to set the Save Path before we can start downloading audio")
        return
      end

      print("Starting process with:")
      print("  Search Phrase: " .. search_phrase)
      print("  YouTube URL: " .. youtube_url)
      print("  Output Directory: " .. output_dir)
      print("  Clip Length: " .. tostring(clip_length))
      print("  Download Full Video: " .. tostring(full_video))
      print("  Loop Mode: " .. loop_modes[loop_mode])
      print("  Create New Instrument: " .. tostring(create_new_instrument))
      print("  Save Format: " .. save_format)
      print("  Save to Folder: " .. tostring(save_to_folder))
      print("  Save Path: " .. save_path)

      pakettiColugaExecuteBashScript(search_phrase, youtube_url, output_dir, clip_length, full_video)
      pakettiColugaLoadVideoAudioIntoRenoise(output_dir, loop_mode, create_new_instrument)
    end }, vb:button { text = "Save", notifier = function()
      preferences.pakettiColuga.pakettiColugaOutputDirectory.value = vb.views.output_dir.text
      preferences.pakettiColuga.pakettiColugaClipLength.value = vb.views.clip_length.value
      preferences.pakettiColuga.pakettiColugaLoopMode.value = vb.views.loop_mode.value
      preferences.pakettiColuga.pakettiColugaAmountOfVideos.value = vb.views.video_amount.value
      preferences.pakettiColuga.pakettiColugaLoadWholeVideo.value = vb.views.full_video.value
      preferences.pakettiColuga.pakettiColugaNewInstrumentOrSameInstrument.value = vb.views.create_new_instrument.value
      preferences.pakettiColuga.pakettiColugaFormatToSave.value = vb.views.save_format.value
      preferences.pakettiColuga.pakettiColugaPathToSave.value = vb.views.save_path.text
    end }, vb:button { text = "Save & Close", notifier = function()
      preferences.pakettiColuga.pakettiColugaOutputDirectory.value = vb.views.output_dir.text
      preferences.pakettiColuga.pakettiColugaClipLength.value = vb.views.clip_length.value
      preferences.pakettiColuga.pakettiColugaLoopMode.value = vb.views.loop_mode.value
      preferences.pakettiColuga.pakettiColugaAmountOfVideos.value = vb.views.video_amount.value
      preferences.pakettiColuga.pakettiColugaLoadWholeVideo.value = vb.views.full_video.value
      preferences.pakettiColuga.pakettiColugaNewInstrumentOrSameInstrument.value = vb.views.create_new_instrument.value
      preferences.pakettiColuga.pakettiColugaFormatToSave.value = vb.views.save_format.value
      preferences.pakettiColuga.pakettiColugaPathToSave.value = vb.views.save_path.text
      PakettiColugaCloseDialog()
    end } }
  }
  return dialog_content
end

-- Show/Hide Dialog function
function PakettiColugaShowDialog()
  if dialog and dialog.visible then
    print("Dialog is visible, closing dialog.")
    PakettiColugaCloseDialog()
  else
    print("Dialog is not visible, creating new dialog.")
    dialog = renoise.app():show_custom_dialog("Paketti Coluga Downloader", PakettiColugaDialogContent(), PakettiColugaKeyHandlerFunc)
  end
end

-- Close Dialog function
function PakettiColugaCloseDialog()
  if dialog and dialog.visible then
    dialog:close()
  end
  dialog = nil
  print("Dialog closed.")
  renoise.app():show_status("Closing Paketti Coluga Dialog")
end

-- GUI and Tool registration
renoise.tool():add_menu_entry { name = "Main Menu:Tools:Paketti..:Paketti Coluga Downloader", invoke = PakettiColugaShowDialog }
renoise.tool():add_keybinding { name = "Global:Tools:Paketti Coluga Downloader", invoke = PakettiColugaShowDialog }
renoise.tool():add_midi_mapping { name = "Paketti:Paketti Coluga Downloader", invoke = PakettiColugaShowDialog }
renoise.tool():add_menu_entry { name = "Sample Editor:Paketti..:Paketti Coluga Downloader", invoke = PakettiColugaShowDialog }
renoise.tool():add_menu_entry { name = "Sample Navigator:Paketti..:Paketti Coluga Downloader", invoke = PakettiColugaShowDialog }
renoise.tool():add_menu_entry { name = "Instrument Box:Paketti..:Paketti Coluga Downloader", invoke = PakettiColugaShowDialog }



