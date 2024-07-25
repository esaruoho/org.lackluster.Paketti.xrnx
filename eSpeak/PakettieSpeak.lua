vb=renoise.ViewBuilder()
dialog=nil
rns=nil
rnt=renoise.tool()
ra=renoise.app()
local button_press_active = false

LANGUAGES={{"Afrikaans","af"},{"Albanian","sq"},{"Amharic","am"},{"Aragonese","an"},{"Arabic","ar"},{"Armenian_(East_Armenia)","hy"},{"Armenian_(West_Armenia)","hyw"},{"Assamese","as"},{"Azerbaijani","az"},{"Bashkir","ba"},{"Basque","eu"},{"Belarusian","be"},{"Bengali","bn"},{"Bishnupriya_Manipuri","bpy"},{"Bosnian","bs"},{"Bulgarian","bg"},{"Catalan","ca"},{"Cherokee","chr"},{"Chinese_(Cantonese)","yue"},{"Chinese_(Cantonese,_latin_as_Jyutping)","yue-Latn-jyutping"},{"Chinese_(Mandarin,_latin_as_English)","cmn"},{"Chinese_(Mandarin,_latin_as_Pinyin)","cmn-Latn-pinyin"},{"Chuvash","cv"},{"Croatian","hr"},{"Czech","cs"},{"Danish","da"},{"Dutch","nl"},{"English_(America)","en-US"},{"English_(America,_New_York_City)","en-US-nyc"},{"English_(Caribbean)","en-029"},{"English_(Great_Britain)","en"},{"English_(Lancaster)","en-GB-x-gbclan"},{"English_(Received_Pronunciation)","en-GB-x-rp"},{"English_(Scotland)","en-GB-scotland"},{"English_(West_Midlands)","en-GB-x-gbcwmd"},{"Esperanto","eo"},{"Estonian","et"},{"Finnish","fi"},{"French_(Belgium)","fr-BE"},{"French_(France)","fr"},{"French_(Switzerland)","fr-CH"},{"Gaelic_(Irish)","ga"},{"Gaelic_(Scottish)","gd"},{"Georgian","ka"},{"German","de"},{"Greek","el"},{"Greek_(Ancient)","grc"},{"Greenlandic","kl"},{"Gujarati","gu"},{"Haitian_Creole","ht"},{"Hakka_Chinese","hak"},{"Hawaiian","haw"},{"Hebrew","he"},{"Hindi","hi"},{"Hungarian","hu"},{"Icelandic","is"},{"Ido","io"},{"Indonesian","id"},{"Interlingua","ia"},{"Italian","it"},{"Japanese","ja"},{"Kazakh","kk"},{"K'iche'","quc"},{"Klingon","piqd"},{"Kannada","kn"},{"Konkani","kok"},{"Korean","ko"},{"Kurdish","ku"},{"Kyrgyz","ky"},{"Lang_Belta","qdb"},{"Latin","la"},{"Latgalian","ltg"},{"Latvian","lv"},{"Lingua_Franca_Nova","lfn"},{"Lithuanian","lt"},{"Lojban","jbo"},{"Luxembourgish","lb"},{"Lule_Saami","smj"},{"Macedonian","mk"},{"Māori","mi"},{"Malay","ms"},{"Malayalam","ml"},{"Maltese","mt"},{"Marathi","mr"},{"Myanmar_(Burmese)","my"},{"Nahuatl_(Classical)","nci"},{"Nepali","ne"},{"Norwegian_Bokmål","nb"},{"Nogai","nog"},{"Oromo","om"},{"Oriya","or"},{"Papiamento","pap"},{"Persian","fa"},{"Persian_(Pinglish)","fa-Latn"},{"Polish","pl"},{"Portuguese_(Brazil)","pt-BR"},{"Portuguese_(Portugal)","pt"},{"Punjabi","pa"},{"Pyash","py"},{"Quechua","qu"},{"Quenya","qya"},{"Romanian","ro"},{"Russian","ru"},{"Russian_(Latvia)","ru-LV"},{"Sindarin","sjn"},{"Sindhi","sd"},{"Sinhala","si"},{"Shan_(Tai_Yai)","shn"},{"Slovak","sk"},{"Slovenian","sl"},{"Spanish_(Latin_America)","es-419"},{"Spanish_(Spain)","es"},{"Swahili","sw"},{"Swedish","sv"},{"Tamil","ta"},{"Telugu","te"},{"Thai","th"},{"Turkish","tr"},{"Turkmen","tk"},{"Tatar","tt"},{"Ukrainian","uk"},{"Urdu","ur"},{"Uyghur","ug"},{"Uzbek","uz"},{"Vietnamese_(Central)","vi-VN-x-central"},{"Vietnamese_(Northern)","vi"},{"Vietnamese_(Southern)","vi-VN-x-south"},{"Welsh","cy"}}

VOICES={"None","adam","Alex","Alicia","Andrea","Andy","anika","anikaRobot","Annie","announcer","antonio","AnxiousAndy","aunty","belinda","benjamin","boris","caleb","croak","david","Demonic","Denis","Diogo","ed","edward","edward2","f1","f2","f3","f4","f5","fast","Gene","Gene2","grandma","grandpa","gustave","Henrique","Hugo","iven","iven2","iven3","iven4","Jacky","john","kaukovalta","klatt","klatt2","klatt3","klatt4","klatt5","klatt6","Lee","linda","m1","m2","m3","m4","m5","m6","m7","m8","marcelo","Marco","Mario","max","miguel","Michael","michel","Mike","Mr serious","Nguyen","norbert","pablo","paul","pedro","quincy","RicishayMax","RicishayMax2","RicishayMax3","rob","robert","robosoft","sandro","shelby","steph","Storm","travis","Tweaky","victor","whisper","whisperf","zac"}

LANGUAGE_NAMES={}
LANGUAGE_SHORTS={}
VOICES_NAMES={}

for _,langs in pairs(LANGUAGES)do
  table.insert(LANGUAGE_NAMES,langs[1])
  table.insert(LANGUAGE_SHORTS,langs[2])
end

for _,voice in pairs(VOICES)do
  table.insert(VOICES_NAMES,voice)
end




local os_name=os.platform()
local default_executable
if os_name=="WINDOWS"then
  default_executable="C:\\Program Files\\espeak\\espeak.exe"
elseif os_name=="MACINTOSH"then
  default_executable="/opt/homebrew/bin/espeak-ng"
else
  default_executable="/usr/bin/espeak-ng"
end

function pakettiReSpeakConvertPath(path)
  path=tostring(path)
  if os_name=="WINDOWS"then
    return string.gsub(path,"/","\\")
  else
    return path
  end
end

function pakettiReSpeakRevertPath(path)
  path=tostring(path)
  if os_name=="WINDOWS"then
    return string.gsub(path,"\\","/")
  else
    return path
  end
end

--------------------
--------------- Main
--------------------

-- Assuming ReSpeak.language.value and ReSpeak.voice.value are properly defined and within range
local language_index = ReSpeak.language.value
local voice_index = ReSpeak.voice.value


renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Paketti eSpeak Text-to-Speech",invoke=function()pakettiReSpeakToggleDialog()end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Paketti eSpeak Text-to-Speech",invoke=function()pakettiReSpeakToggleDialog()end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti eSpeak Text-to-Speech",invoke=function()pakettiReSpeakToggleDialog()end}

_AUTO_RELOAD_DEBUG=function()end

function pakettiReSpeakFileExists(path)
  local f=io.open(path,"r")
  return f~=nil and io.close(f)
end

local selected_textfile=""

function pakettiReSpeakLoadTextfile(refresh)
  if not refresh then
    selected_textfile=renoise.app():prompt_for_filename_to_read({"*.txt"},"Load Textfile")
  end
  if selected_textfile~=""then
    local file=io.open(selected_textfile,"r")
    if file then
      local content=file:read("*all")
      file:close()
      vb.views.text_field.text=content
      vb.views.load_textfile_button.text=selected_textfile:match("[^/\\]+$")
      print("Loaded textfile:",content)
          ReSpeak.text.value=content
          pakettiReSpeakCreateSample()
    else
      renoise.app():show_error("Failed to read the file.")
    end
  end
end

local dialog_width=300
local control_width=190
local valuebox_width=60
local button_width=190

local function update_selection()
  local text=vb.views.text_field.text
  local start=vb.views.start_pos.value
  local length=vb.views.length_pos.value
  local max_length=#text-start+1
  if length>max_length then
    length=max_length
    vb.views.length_pos.value=length
    renoise.app():show_status("No more can be selected")
  end
  if length==0 then
    vb.views.selection_display.text=""
  else
    local end_pos=start+length-1
    if start<=#text and end_pos<=#text and start<=end_pos then
      local selected_text=text:sub(start,end_pos)
      vb.views.selection_display.text=selected_text
    end
  end
end





make_gui = vb:column{
  width = dialog_width,
  vb:space{height = 5},
  vb:horizontal_aligner{mode = "center", vb:text{width = control_width, height = 24, text = "Path to eSpeak", font = "bold"}},
  vb:horizontal_aligner{mode = "center", vb:button{id = "exe_button", width = control_width, height = 24, text = pakettiReSpeakRevertPath(ReSpeak.executable), notifier = function()
    local filename = renoise.app():prompt_for_filename_to_read({"*.*"}, "Select Executable")
    if filename ~= "" then
      ReSpeak.executable = pakettiReSpeakConvertPath(filename)
      renoise.tool().preferences.pakettiReSpeak.executable = ReSpeak.executable
      vb.views.exe_button.text = pakettiReSpeakRevertPath(ReSpeak.executable)
      vb.views.exe_button.width = math.min(#vb.views.exe_button.text * 8, control_width) -- Adjust width dynamically based on text length
    end
  end}},
  vb:space{height = 5},
  vb:row{vb:button{id = "load_textfile_button", text = "Load Textfile", width = button_width, height = 24, notifier = function() pakettiReSpeakLoadTextfile(false) end},
    vb:button{text = "Refresh", width = button_width, height = 24, notifier = function()
      pakettiReSpeakLoadTextfile(true)
      print("Refresh: loaded textfile and updated textfield")
      ReSpeak.text.value = vb.views.text_field.text  -- Ensure text is up-to-date
    end}},
  vb:column{
    margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
    spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
    width = 380,
    style = "group",
    vb:multiline_textfield{id = "text_field", width = 373, height = 100, style = "border", text = tostring(ReSpeak.text)},
  vb:row{
    vb:text{text = "Start:"},
    vb:valuebox{id = "start_pos", min = 1, max = 500, value = 1, notifier = update_selection},
vb:text{text = "Length:"},
vb:valuebox{id = "length_pos", min = 0, max = 500, value = 0, notifier = function()
  update_selection()
  if vb.views.length_pos.value > 0 then
    pakettiReSpeakCreateSample(vb.views.selection_display.text) -- Trigger render when length changes
  end
end},
vb:button{text = "-", width = 20, notifier = function()
  if vb.views.length_pos.value > 0 then
    vb.views.length_pos.value = vb.views.length_pos.value - 1
    update_selection()
   -- if vb.views.length_pos.value > 0 then
   --   pakettiReSpeakCreateSample(vb.views.selection_display.text) -- Trigger render when length decreases
   -- end
  end
end},
vb:button{text = "+", width = 20, notifier = function()
  if vb.views.length_pos.value < 500 then
    vb.views.length_pos.value = vb.views.length_pos.value + 1
    update_selection()
  --  pakettiReSpeakCreateSample(vb.views.selection_display.text) -- Trigger render when length increases
  end
end}
  },
  vb:row{
    vb:text{text = "Selection:"},
    vb:textfield{id = "selection_display", width = 323, height = 20, edit_mode = false}
  },
  vb:horizontal_aligner{
    mode = "center",
    vb:button{
      text = "Generate Selection",
      width = button_width,
      height = 24,
      notifier = function()
        local text = vb.views.text_field.text
        local start = vb.views.start_pos.value
        local length = vb.views.length_pos.value
        local end_pos = start + length - 1
        if start <= #text and end_pos <= #text and start <= end_pos then
          local selected_text = text:sub(start, end_pos)
          print("Selected text:", selected_text)
          renoise.app():show_status("Selected text: " .. selected_text)
          -- Feed the selected text to the renderer
          ReSpeak.text.value = selected_text
          pakettiReSpeakCreateSample()
        else
          renoise.app():show_status("Invalid selection range")
        end
      end
    }
  },
  vb:column{
    margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
    spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
    width = 373,
    vb:row{
      vb:text{text = "Language:", width = 80},
      vb:popup{id = "language", width = 250, items = LANGUAGE_NAMES, value = ReSpeak.language.value, notifier = function(idx)
        ReSpeak.language.value = idx
        if ReSpeak.render_on_change.value then pakettiReSpeakCreateSample(vb.views.text_field.text) end
      end},
      vb:button{text = "-", width = 20, notifier = function()
        if vb.views.language.value > 1 then
          vb.views.language.value = vb.views.language.value - 1
          ReSpeak.language.value = vb.views.language.value
          print("Language - pressed, textfield content:", vb.views.text_field.text)
      --    if ReSpeak.render_on_change.value then pakettiReSpeakCreateSample() end
        else
          renoise.app():show_status("You are at the beginning of the list.")
        end
      end},
      vb:button{text = "+", width = 20, notifier = function()
        if vb.views.language.value < #LANGUAGE_NAMES then
          vb.views.language.value = vb.views.language.value + 1
          ReSpeak.language.value = vb.views.language.value
          print("Language + pressed, textfield content:", vb.views.text_field.text)
       --   if ReSpeak.render_on_change.value then pakettiReSpeakCreateSample() end
        else
          renoise.app():show_status("You are at the bottom of the list.")
        end
      end}
    },
    vb:row{
      vb:text{text = "Voice:", width = 80},
      vb:popup{id = "voice", width = 250, items = VOICES, value = ReSpeak.voice.value, notifier = function(idx)
        ReSpeak.voice.value = idx
        if ReSpeak.render_on_change.value then pakettiReSpeakCreateSample(vb.views.text_field.text) end
      end},
      vb:button{text = "-", width = 20, notifier = function()
        if vb.views.voice.value > 2 then -- Ensure not going below index 2
          vb.views.voice.value = vb.views.voice.value - 1
          ReSpeak.voice.value = vb.views.voice.value
          print("Voice - pressed, textfield content:", vb.views.text_field.text)
 --         if ReSpeak.render_on_change.value then pakettiReSpeakCreateSample(vb.views.text_field.text) end
        else
          renoise.app():show_status("You are at the beginning of the list")
        end
      end},
      vb:button{text = "+", width = 20, notifier = function()
        if vb.views.voice.value < #VOICES then
          vb.views.voice.value = vb.views.voice.value + 1
          ReSpeak.voice.value = vb.views.voice.value
          print("Voice + pressed, textfield content:", vb.views.text_field.text)
  --        if ReSpeak.render_on_change.value then pakettiReSpeakCreateSample(vb.views.text_field.text) end
        else
          renoise.app():show_status("You are at the bottom of the list")
        end
      end}
    },
    vb:row{vb:text{width = 80, text = "Word Gap:"}, vb:valuebox{id = "gap_box", width = valuebox_width, min = 1, max = 10000, value = ReSpeak.word_gap.value, steps = {1, 10, 100}, notifier = function(gap)
      ReSpeak.word_gap.value = gap
      print("Word Gap set to:", gap)
    end}},
    vb:row{vb:text{width = 80, text = "Pitch Capitals:"}, vb:valuebox{id = "capitals_box", width = valuebox_width, min = 1, max = 100, value = ReSpeak.capitals.value, steps = {1, 5}, notifier = function(capitals)
      ReSpeak.capitals.value = capitals
      print("Pitch Capitals set to:", capitals)
    end}},
    vb:row{vb:text{width = 80, text = "Pitch:"}, vb:valuebox{id = "pitch_box", width = valuebox_width, min = 0, max = 99, value = ReSpeak.pitch.value, steps = {1, 5}, notifier = function(pitch)
      ReSpeak.pitch.value = pitch
      print("Pitch set to:", pitch)
    end}},
    vb:row{vb:text{width = 80, text = "Amplitude:"}, vb:valuebox{id = "amplitude_box", width = valuebox_width, min = 0, max = 200, value = ReSpeak.amplitude.value, steps = {1, 5}, notifier = function(amplitude)
      ReSpeak.amplitude.value = amplitude
      print("Amplitude set to:", amplitude)
    end}},
    vb:row{vb:text{width = 80, text = "Speed:"}, vb:valuebox{id = "speed_box", width = valuebox_width, min = 1, max = 500, value = ReSpeak.speed.value, steps = {1, 5}, notifier = function(speed)
      ReSpeak.speed.value = speed
      print("Speed set to:", speed)
    end}},
  },
  vb:row{vb:checkbox{id = "clear_all_samples", width = 18, height = 18, value = ReSpeak.clear_all_samples.value == true, notifier = function(bool)
    ReSpeak.clear_all_samples.value = bool
    print("Clear All Samples set to:", bool)
  end}, vb:text{text = "Overwrite Samples in Selected Instrument"}},
  vb:row{vb:checkbox{id = "render_on_change", width = 18, height = 18, value = ReSpeak.render_on_change.value == true, notifier = function(bool)
    ReSpeak.render_on_change.value = bool
    print("Render on Change set to:", bool)
  end}, vb:text{text = "+/- Click Should Render a New Instrument"}},
  vb:space{height = 10},
  vb:horizontal_aligner{mode = "center", vb:button{id = "load_button", width = button_width, height = 24, text = "Load Settings", notifier = function()
    local filename = renoise.app():prompt_for_filename_to_read({"*.rts"}, "Load Settings")
    if filename ~= "" then
      local result = ReSpeak:load_from(filename)
      if result == nil then
        renoise.app():show_error("Unable to Load Settings.")
      else
        print("Loaded Settings:", result)
        print("Loaded Text:", ReSpeak.text.value)
        print("Loaded Language:", ReSpeak.language.value)
        print("Loaded Voice:", ReSpeak.voice.value)
        print("Loaded Word Gap:", ReSpeak.word_gap.value)
        print("Loaded Pitch Capitals:", ReSpeak.capitals.value)
        print("Loaded Pitch:", ReSpeak.pitch.value)
        print("Loaded Amplitude:", ReSpeak.amplitude.value)
        print("Loaded Speed:", ReSpeak.speed.value)
        print("Loaded Executable:", ReSpeak.executable.value)
        print("Loaded Clear All Samples:", ReSpeak.clear_all_samples.value)

        vb.views.text_field.text = tostring(ReSpeak.text.value)
        vb.views.language.value = ReSpeak.language.value
        vb.views.voice.value = ReSpeak.voice.value
        vb.views.gap_box.value = ReSpeak.word_gap.value
        vb.views.capitals_box.value = ReSpeak.capitals.value
        vb.views.pitch_box.value = ReSpeak.pitch.value
        vb.views.amplitude_box.value = ReSpeak.amplitude.value
        vb.views.speed_box.value = ReSpeak.speed.value
        local espeak_executable = pakettiReSpeakRevertPath(ReSpeak.executable)
        vb.views.exe_button.text = espeak_executable
        vb.views.exe_button.width = math.min(#vb.views.exe_button.text * 8, control_width)
        renoise.tool().preferences.pakettiReSpeak.executable = espeak_executable
        vb.views.clear_all_samples.value = ReSpeak.clear_all_samples.value == true
        vb.views.render_on_change.value = ReSpeak.render_on_change.value == true
      end
    end
  end},
  vb:button{id = "save_button", width = button_width, height = 24, text = "Save Settings", notifier = function()
    local filename = renoise.app():prompt_for_filename_to_write(".rts", "Save Settings")
    if filename ~= "" then
      ReSpeak.text.value = string.gsub(vb.views.text_field.text, "\n", " ")
      local result = ReSpeak:save_as(filename)
      if result == nil then
        renoise.app():show_error("Unable to Save Settings.")
      else
        print("Saved Settings:", result)
        print("Saved Text:", ReSpeak.text.value)
        print("Saved Language:", ReSpeak.language.value)
        print("Saved Voice:", ReSpeak.voice.value)
        print("Saved Word Gap:", ReSpeak.word_gap.value)
        print("Saved Pitch Capitals:", ReSpeak.capitals.value)
        print("Saved Pitch:", ReSpeak.pitch.value)
        print("Saved Amplitude:", ReSpeak.amplitude.value)
        print("Saved Speed:", ReSpeak.speed.value)
        print("Saved Executable:", ReSpeak.executable.value)
        print("Saved Clear All Samples:", ReSpeak.clear_all_samples.value)
        print("Saved Render on Change:", ReSpeak.render_on_change.value)
      end
    end
  end}},
  vb:space{height = 20},
  vb:horizontal_aligner{mode = "center", vb:button{text = "Generate Sample", width = button_width, height = 24, notifier = function()
    ReSpeak.text.value = string.gsub(vb.views.text_field.text, "\n", " ")
    pakettiReSpeakCreateSample()
    renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  end}},
  vb:space{height = 10}
}}
function pakettiReSpeakPrepare()
  print("Starting dialog with settings:")
  print("Text:",ReSpeak.text.value)
  print("Language:",ReSpeak.language.value)
  print("Voice:",ReSpeak.voice.value)
  print("Word Gap:",ReSpeak.word_gap.value)
  print("Pitch Capitals:",ReSpeak.capitals.value)
  print("Pitch:",ReSpeak.pitch.value)
  print("Amplitude:",ReSpeak.amplitude.value)
  print("Speed:",ReSpeak.speed.value)
  print("Executable:",ReSpeak.executable)
  print("Clear All Samples:",ReSpeak.clear_all_samples.value)
  print("Render on Change:",ReSpeak.render_on_change.value)

  if dialog and dialog.visible then
    dialog:show()
    return
  end

  local espeak_location=renoise.tool().preferences.pakettiReSpeak.executable
  if espeak_location~=""then
    ReSpeak.executable=pakettiReSpeakConvertPath(espeak_location)
  else
    renoise.app():show_alert("Please set the eSpeak path before running.")
    return
  end
  vb.views.exe_button.text=pakettiReSpeakRevertPath(ReSpeak.executable)
  vb.views.exe_button.width=math.min(#vb.views.exe_button.text*8,control_width)
  vb.views.text_field.text=tostring(ReSpeak.text.value)
  vb.views.language.value=ReSpeak.language.value
  vb.views.voice.value=ReSpeak.voice.value
  vb.views.gap_box.value=ReSpeak.word_gap.value
  vb.views.capitals_box.value=ReSpeak.capitals.value
  vb.views.pitch_box.value=ReSpeak.pitch.value
  vb.views.amplitude_box.value=ReSpeak.amplitude.value
  vb.views.speed_box.value=ReSpeak.speed.value
  vb.views.clear_all_samples.value=ReSpeak.clear_all_samples.value==true
  vb.views.render_on_change.value=ReSpeak.render_on_change.value==true

  show_gui()
end

local function pakettiReSpeakKeyHandlerFunc(dialog,key)
  if key.modifiers==""and key.name=="esc"then
    dialog:close()
  else
    return key
  end
end

function show_gui()
  dialog=renoise.app():show_custom_dialog("Paketti eSpeak Text-to-Speech v0.354",make_gui,pakettiReSpeakKeyHandlerFunc)

  print("Dialog GUI elements set to:")
  print("Text:",vb.views.text_field.text)
  print("Language:",vb.views.language.value)
  print("Voice:",vb.views.voice.value)
  print("Word Gap:",vb.views.gap_box.value)
  print("Pitch Capitals:",vb.views.capitals_box.value)
  print("Pitch:",vb.views.pitch_box.value)
  print("Amplitude:",vb.views.amplitude_box.value)
  print("Speed:",vb.views.speed_box.value)
  print("Executable:",vb.views.exe_button.text)
  print("Clear All Samples:",vb.views.clear_all_samples.value)
  print("Render on Change:",vb.views.render_on_change.value)
end

function pakettiReSpeakToggleDialog()
  if dialog and dialog.visible then
    pakettiReSpeakCreateSample()
  else
    pakettiReSpeakPrepare()
  end
end

function pakettiReSpeakCreateSample(custom_text)
  local text_to_render = custom_text or ReSpeak.text.value
  print (text_to_render)
  local executable = pakettiReSpeakRevertPath(ReSpeak.executable)
  local path = os.tmpname() .. ".wav"

  local cmd = executable
  cmd = cmd .. " -a " .. ReSpeak.amplitude.value
  cmd = cmd .. " -v " .. LANGUAGE_SHORTS[ReSpeak.language.value]

  if ReSpeak.voice.value ~= 1 then
    cmd = cmd .. "+" .. VOICES[ReSpeak.voice.value]
  end

  cmd = cmd .. " -b 1 -m "
  cmd = cmd .. " -p " .. ReSpeak.pitch.value
  cmd = cmd .. " -s " .. ReSpeak.speed.value
  cmd = cmd .. " -g " .. ReSpeak.word_gap.value
  cmd = cmd .. " -k " .. ReSpeak.capitals.value
  cmd = cmd .. " -w " .. path
  cmd = cmd .. ' "' .. text_to_render .. '"'

  print("Command to be executed:" .. cmd)

  os.execute(cmd)

  local song = renoise.song()
  local instrument

  if ReSpeak.clear_all_samples.value then
    instrument = song.selected_instrument
    pakettiPreferencesDefaultInstrumentLoader()
    while #instrument.samples > 0 do
      instrument:delete_sample_at(1)
    end
    local sample = instrument:insert_sample_at(1)
    renoise.song().selected_instrument.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
    sample.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
  else
    instrument = song:insert_instrument_at(renoise.song().selected_instrument_index + 1)
    song.selected_instrument_index = renoise.song().selected_instrument_index + 1
    pakettiPreferencesDefaultInstrumentLoader()
    renoise.song().selected_instrument.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
    song.selected_instrument:insert_sample_at(1)
  local sample = song.selected_instrument.samples[1]
  
--    local sample=renoise.song().selected_instrument.samples[1] 
    sample.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
  end

  instrument.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
  local sample = song.selected_instrument.samples[1]
  local buffer = sample.sample_buffer

  print("Loading path:" .. path)
  if not pakettiReSpeakFileExists(path) then
    renoise.app():show_error("Sample was not rendered. An error happened.")
    return
  end

  local bool, result = buffer:load_from(path)
  local currentActiveMiddleFrame = renoise.app().window.active_middle_frame
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

