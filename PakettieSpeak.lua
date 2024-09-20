-- Initialize the ViewBuilder and other variables
local vb = renoise.ViewBuilder()
local dialog = nil
local rns = nil
local rnt = renoise.tool()
local ra = renoise.app()
local button_press_active = false

-- Full list of languages
local LANGUAGES = {
  {"Afrikaans","af"},
  {"Albanian","sq"},
  {"Amharic","am"},
  {"Aragonese","an"},
  {"Arabic","ar"},
  {"Armenian (East Armenia)","hy"},
  {"Armenian (West Armenia)","hyw"},
  {"Assamese","as"},
  {"Azerbaijani","az"},
  {"Bashkir","ba"},
  {"Basque","eu"},
  {"Belarusian","be"},
  {"Bengali","bn"},
  {"Bishnupriya Manipuri","bpy"},
  {"Bosnian","bs"},
  {"Bulgarian","bg"},
  {"Catalan","ca"},
  {"Cherokee","chr"},
  {"Chinese (Cantonese)","yue"},
  {"Chinese (Cantonese, Latin as Jyutping)","yue-Latn-jyutping"},
  {"Chinese (Mandarin, Latin as English)","cmn"},
  {"Chinese (Mandarin, Latin as Pinyin)","cmn-Latn-pinyin"},
  {"Chuvash","cv"},
  {"Croatian","hr"},
  {"Czech","cs"},
  {"Danish","da"},
  {"Dutch","nl"},
  {"English (America)","en-US"},
  {"English (America, New York City)","en-US-nyc"},
  {"English (Caribbean)","en-029"},
  {"English (Great Britain)","en"},
  {"English (Lancaster)","en-GB-x-gbclan"},
  {"English (Received Pronunciation)","en-GB-x-rp"},
  {"English (Scotland)","en-GB-scotland"},
  {"English (West Midlands)","en-GB-x-gbcwmd"},
  {"Esperanto","eo"},
  {"Estonian","et"},
  {"Finnish","fi"},
  {"French (Belgium)","fr-BE"},
  {"French (France)","fr"},
  {"French (Switzerland)","fr-CH"},
  {"Gaelic (Irish)","ga"},
  {"Gaelic (Scottish)","gd"},
  {"Georgian","ka"},
  {"German","de"},
  {"Greek","el"},
  {"Greek (Ancient)","grc"},
  {"Greenlandic","kl"},
  {"Gujarati","gu"},
  {"Haitian Creole","ht"},
  {"Hakka Chinese","hak"},
  {"Hawaiian","haw"},
  {"Hebrew","he"},
  {"Hindi","hi"},
  {"Hungarian","hu"},
  {"Icelandic","is"},
  {"Ido","io"},
  {"Indonesian","id"},
  {"Interlingua","ia"},
  {"Italian","it"},
  {"Japanese","ja"},
  {"Kazakh","kk"},
  {"K'iche'","quc"},
  {"Klingon","piqd"},
  {"Kannada","kn"},
  {"Konkani","kok"},
  {"Korean","ko"},
  {"Kurdish","ku"},
  {"Kyrgyz","ky"},
  {"Lang Belta","qdb"},
  {"Latin","la"},
  {"Latgalian","ltg"},
  {"Latvian","lv"},
  {"Lingua Franca Nova","lfn"},
  {"Lithuanian","lt"},
  {"Lojban","jbo"},
  {"Luxembourgish","lb"},
  {"Lule Saami","smj"},
  {"Macedonian","mk"},
  {"Maori","mi"},
  {"Malay","ms"},
  {"Malayalam","ml"},
  {"Maltese","mt"},
  {"Marathi","mr"},
  {"Myanmar (Burmese)","my"},
  {"Nahuatl (Classical)","nci"},
  {"Nepali","ne"},
  {"Norwegian Bokmål","nb"},
  {"Nogai","nog"},
  {"Oromo","om"},
  {"Oriya","or"},
  {"Papiamento","pap"},
  {"Persian","fa"},
  {"Persian (Pinglish)","fa-Latn"},
  {"Polish","pl"},
  {"Portuguese (Brazil)","pt-BR"},
  {"Portuguese (Portugal)","pt"},
  {"Punjabi","pa"},
  {"Pyash","py"},
  {"Quechua","qu"},
  {"Quenya","qya"},
  {"Romanian","ro"},
  {"Russian","ru"},
  {"Russian (Latvia)","ru-LV"},
  {"Sindarin","sjn"},
  {"Sindhi","sd"},
  {"Sinhala","si"},
  {"Shan (Tai Yai)","shn"},
  {"Slovak","sk"},
  {"Slovenian","sl"},
  {"Spanish (Latin America)","es-419"},
  {"Spanish (Spain)","es"},
  {"Swahili","sw"},
  {"Swedish","sv"},
  {"Tamil","ta"},
  {"Telugu","te"},
  {"Thai","th"},
  {"Turkish","tr"},
  {"Turkmen","tk"},
  {"Tatar","tt"},
  {"Ukrainian","uk"},
  {"Urdu","ur"},
  {"Uyghur","ug"},
  {"Uzbek","uz"},
  {"Vietnamese (Central)","vi-VN-x-central"},
  {"Vietnamese (Northern)","vi"},
  {"Vietnamese (Southern)","vi-VN-x-south"},
  {"Welsh","cy"}
}

-- Full list of voices
local VOICES = {
  "None",
  "adam",
  "Alex",
  "Alicia",
  "Andrea",
  "Andy",
  "anika",
  "anikaRobot",
  "Annie",
  "announcer",
  "antonio",
  "AnxiousAndy",
  "aunty",
  "belinda",
  "benjamin",
  "boris",
  "caleb",
  "croak",
  "david",
  "Demonic",
  "Denis",
  "Diogo",
  "ed",
  "edward",
  "edward2",
  "f1",
  "f2",
  "f3",
  "f4",
  "f5",
  "fast",
  "Gene",
  "Gene2",
  "grandma",
  "grandpa",
  "gustave",
  "Henrique",
  "Hugo",
  "iven",
  "iven2",
  "iven3",
  "iven4",
  "Jacky",
  "john",
  "kaukovalta",
  "klatt",
  "klatt2",
  "klatt3",
  "klatt4",
  "klatt5",
  "klatt6",
  "Lee",
  "linda",
  "m1",
  "m2",
  "m3",
  "m4",
  "m5",
  "m6",
  "m7",
  "m8",
  "marcelo",
  "Marco",
  "Mario",
  "max",
  "miguel",
  "Michael",
  "michel",
  "Mike",
  "Mr serious",
  "Nguyen",
  "norbert",
  "pablo",
  "paul",
  "pedro",
  "quincy",
  "RicishayMax",
  "RicishayMax2",
  "RicishayMax3",
  "rob",
  "robert",
  "robosoft",
  "sandro",
  "shelby",
  "steph",
  "Storm",
  "travis",
  "Tweaky",
  "victor",
  "whisper",
  "whisperf",
  "zac"
}

-- Initialize language and voice names
local LANGUAGE_NAMES = {}
local LANGUAGE_SHORTS = {}
local VOICES_NAMES = {}

for _, langs in pairs(LANGUAGES) do
  table.insert(LANGUAGE_NAMES, langs[1])
  table.insert(LANGUAGE_SHORTS, langs[2])
end

for _, voice in pairs(VOICES) do
  table.insert(VOICES_NAMES, voice)
end

local os_name = os.platform()
local default_executable
if os_name == "WINDOWS" then
  default_executable = "C:\\Program Files\\espeak\\espeak.exe"
elseif os_name == "MACINTOSH" then
  default_executable = "/opt/homebrew/bin/espeak-ng"
else
  default_executable = "/usr/bin/espeak-ng"
end

-- Utility functions for path conversion
function PakettieSpeakConvertPath(path)
  path = tostring(path)
  if os_name == "WINDOWS" then
    return string.gsub(path, "/", "\\")
  else
    return path
  end
end

function PakettieSpeakRevertPath(path)
  path = tostring(path)
  if os_name == "WINDOWS" then
    return string.gsub(path, "\\", "/")
  else
    return path
  end
end

local selected_textfile = ""

-- Function to load text from a file
function PakettieSpeakLoadTextfile(refresh)
  if not refresh then
    selected_textfile = renoise.app():prompt_for_filename_to_read({"*.txt"}, "Load Textfile")
  end
  if selected_textfile ~= "" then
    local file = io.open(selected_textfile, "r")
    if file then
      local content = file:read("*all")
      file:close()
      vb.views.PakettieSpeak_text_field.text = content
      vb.views.PakettieSpeak_load_textfile_button.text = selected_textfile:match("[^/\\]+$")
      print("Loaded textfile:", content)
      ReSpeak.text.value = content
      PakettieSpeakCreateSample()
      PakettieSpeakUpdateLineCount() -- Update line count after loading textfile
    else
      renoise.app():show_error("Failed to read the file.")
    end
  end
end

-- Function to split text into lines
function PakettieSpeakGetLines(text)
  local lines = {}
  for line in text:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines
end

-- Function to update the max value of 'Which row' valuebox
function PakettieSpeakUpdateLineCount()
  local text = vb.views.PakettieSpeak_text_field.text
  local lines = PakettieSpeakGetLines(text)
  local line_count = #lines
  vb.views.PakettieSpeak_which_row.max = math.max(line_count, 1)
  if vb.views.PakettieSpeak_which_row.value > line_count then
    vb.views.PakettieSpeak_which_row.value = 0 -- Set to 0 to render all text
  end
end

local dialog_width = 300
local control_width = 190
local valuebox_width = 60
local button_width = 190

local function PakettieSpeakUpdateSelection()
  local text = vb.views.PakettieSpeak_text_field.text
  local start = vb.views.PakettieSpeak_start_pos.value
  local length = vb.views.PakettieSpeak_length_pos.value
  local max_length = #text - start + 1
  if length > max_length then
    length = max_length
    vb.views.PakettieSpeak_length_pos.value = length
    renoise.app():show_status("No more can be selected")
  end
  if length == 0 then
    vb.views.PakettieSpeak_selection_display.text = ""
  else
    local end_pos = start + length - 1
    if start <= #text and end_pos <= #text and start <= end_pos then
      local selected_text = text:sub(start, end_pos)
      vb.views.PakettieSpeak_selection_display.text = selected_text
    end
  end
end

-- Function to create the GUI
function PakettieSpeakMakeGUI()
  return vb:column{
    width = dialog_width,
    vb:space{height = 5},
    vb:horizontal_aligner{
      mode = "center",
      vb:text{
        width = control_width,
        height = 24,
        text = "Path to eSpeak",
        font = "bold"
      }
    },
    vb:horizontal_aligner{
      mode = "center",
      vb:button{
        id = "PakettieSpeak_exe_button",
        width = control_width,
        height = 24,
        text = PakettieSpeakRevertPath(ReSpeak.executable),
        notifier = function()
          local filename = renoise.app():prompt_for_filename_to_read({"*.*"}, "Select Executable")
          if filename ~= "" then
            ReSpeak.executable = PakettieSpeakConvertPath(filename)
            renoise.tool().preferences.pakettiReSpeak.executable = ReSpeak.executable
            vb.views.PakettieSpeak_exe_button.text = PakettieSpeakRevertPath(ReSpeak.executable)
            vb.views.PakettieSpeak_exe_button.width = math.min(#vb.views.PakettieSpeak_exe_button.text * 8, control_width)
          end
        end
      }
    },
    vb:space{height = 5},
    -- Randomize Buttons
    vb:row{
      vb:button{
        id = "PakettieSpeak_randomize_everything",
        text = "Randomized String",
        width = button_width + button_width,
        height = 24,
        notifier = function()
          local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#€%&/()=?"
          local result = ""
          local count = math.random(10, 100)
          for i = 1, count do
            local random_index = math.random(1, #characters)
            result = result .. characters:sub(random_index, random_index)
          end
          vb.views.PakettieSpeak_text_field.text = result
          ReSpeak.text.value = result
          PakettieSpeakCreateSample()
          PakettieSpeakUpdateLineCount()
        end
      }
    },
    vb:row{
      vb:button{
        id = "PakettieSpeak_randomize_consonants",
        text = "Randomize Consonants",
        width = button_width,
        height = 24,
        notifier = function()
          local consonants = "bcdfghjklmnpqrstvwxyz"
          local result = ""
          local count = math.random(10, 100)
          for i = 1, count do
            local random_index = math.random(1, #consonants)
            result = result .. consonants:sub(random_index, random_index)
          end
          vb.views.PakettieSpeak_text_field.text = result
          ReSpeak.text.value = result
          PakettieSpeakCreateSample()
          PakettieSpeakUpdateLineCount()
        end
      },
      vb:button{
        id = "PakettieSpeak_randomize_vowels",
        text = "Randomize Vowels",
        width = button_width,
        height = 24,
        notifier = function()
          local vowels = "aeiou"
          local result = ""
          local count = math.random(10, 100)
          for i = 1, count do
            local random_index = math.random(1, #vowels)
            result = result .. vowels:sub(random_index, random_index)
          end
          vb.views.PakettieSpeak_text_field.text = result
          ReSpeak.text.value = result
          PakettieSpeakCreateSample()
          PakettieSpeakUpdateLineCount()
        end
      }
    },
    -- Load Textfile and Refresh Buttons
    vb:row{
      vb:button{
        id = "PakettieSpeak_load_textfile_button",
        text = "Load Textfile",
        width = button_width,
        height = 24,
        notifier = function()
          PakettieSpeakLoadTextfile(false)
        end
      },
      vb:button{
        text = "Refresh",
        width = button_width,
        height = 24,
        notifier = function()
          PakettieSpeakLoadTextfile(true)
          print("Refresh: loaded textfile and updated textfield")
          ReSpeak.text.value = vb.views.PakettieSpeak_text_field.text
          PakettieSpeakUpdateLineCount()
        end
      }
    },
    -- Text Field
    vb:column{
      margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
      spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
      width = 380,
      style = "group",
      vb:multiline_textfield{
        id = "PakettieSpeak_text_field",
        width = 373,
        height = 100,
        style = "border",
        text = tostring(ReSpeak.text.value),
        notifier = function()
          PakettieSpeakUpdateLineCount()
        end
      }
    },
    -- Which Row and Selection Controls
    vb:row{
      vb:text{text = "Which row:"},
      vb:valuebox{
        id = "PakettieSpeak_which_row",
        min = 0,
        max = 1,
        value = 0,
        notifier = function(value)
          local text = vb.views.PakettieSpeak_text_field.text
          local lines = PakettieSpeakGetLines(text)
          if value == 0 then
            ReSpeak.text.value = text -- Render all text
          else
            local selected_line = lines[value] or ""
            ReSpeak.text.value = selected_line
          end
          if ReSpeak.render_on_change.value then
            PakettieSpeakCreateSample(ReSpeak.text.value)
          end
        end
      }
    },
    vb:row{
      vb:text{text = "Start:"},
      vb:valuebox{
        id = "PakettieSpeak_start_pos",
        min = 1,
        max = 500,
        value = 1,
        notifier = PakettieSpeakUpdateSelection
      },
      vb:text{text = "Length:"},
      vb:valuebox{
        id = "PakettieSpeak_length_pos",
        min = 0,
        max = 500,
        value = 0,
        notifier = function()
          PakettieSpeakUpdateSelection()
        end
      },
      vb:button{
        text = "-",
        width = 20,
        notifier = function()
          if vb.views.PakettieSpeak_length_pos.value > 0 then
            vb.views.PakettieSpeak_length_pos.value = vb.views.PakettieSpeak_length_pos.value - 1
            PakettieSpeakUpdateSelection()
            if ReSpeak.render_on_change.value then
              PakettieSpeakCreateSample(vb.views.PakettieSpeak_selection_display.text)
            end
          end
        end
      },
      vb:button{
        text = "+",
        width = 20,
        notifier = function()
          if vb.views.PakettieSpeak_length_pos.value < 500 then
            vb.views.PakettieSpeak_length_pos.value = vb.views.PakettieSpeak_length_pos.value + 1
            PakettieSpeakUpdateSelection()
            if ReSpeak.render_on_change.value then
              PakettieSpeakCreateSample(vb.views.PakettieSpeak_selection_display.text)
            end
          end
        end
      }
    },
    vb:row{
      vb:text{text = "Selection:"},
      vb:textfield{
        id = "PakettieSpeak_selection_display",
        width = 323,
        height = 20,
        edit_mode = false
      }
    },
    vb:horizontal_aligner{
      mode = "center",
      vb:button{
        text = "Generate Selection",
        width = button_width,
        height = 24,
        notifier = function()
          local text = vb.views.PakettieSpeak_text_field.text
          local start = vb.views.PakettieSpeak_start_pos.value
          local length = vb.views.PakettieSpeak_length_pos.value
          local end_pos = start + length - 1
          if start <= #text and end_pos <= #text and start <= end_pos then
            local selected_text = text:sub(start, end_pos)
            print("Selected text:", selected_text)
            renoise.app():show_status("Selected text: " .. selected_text)
            ReSpeak.text.value = selected_text
            PakettieSpeakCreateSample()
          else
            renoise.app():show_status("Invalid selection range")
          end
        end
      }
    },
    -- Settings Controls
    vb:column{
      margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
      spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
      width = 373,
      vb:row{
        vb:text{text = "Language:", width = 80},
        vb:popup{
          id = "PakettieSpeak_language",
          width = 250,
          items = LANGUAGE_NAMES,
          value = ReSpeak.language.value,
          notifier = function(idx)
            if not button_press_active then
              ReSpeak.language.value = idx
              if ReSpeak.render_on_change.value then PakettieSpeakCreateSample(ReSpeak.text.value) end
            end
          end
        },
        vb:button{
          text = "-",
          width = 20,
          notifier = function()
            if vb.views.PakettieSpeak_language.value > 1 then
              button_press_active = true
              vb.views.PakettieSpeak_language.value = vb.views.PakettieSpeak_language.value - 1
              ReSpeak.language.value = vb.views.PakettieSpeak_language.value
              if ReSpeak.render_on_change.value then PakettieSpeakCreateSample(ReSpeak.text.value) end
              button_press_active = false
            else
              renoise.app():show_status("You are at the beginning of the list.")
            end
          end
        },
        vb:button{
          text = "+",
          width = 20,
          notifier = function()
            if vb.views.PakettieSpeak_language.value < #LANGUAGE_NAMES then
              button_press_active = true
              vb.views.PakettieSpeak_language.value = vb.views.PakettieSpeak_language.value + 1
              ReSpeak.language.value = vb.views.PakettieSpeak_language.value
              if ReSpeak.render_on_change.value then PakettieSpeakCreateSample(ReSpeak.text.value) end
              button_press_active = false
            else
              renoise.app():show_status("You are at the bottom of the list.")
            end
          end
        }
      },
      -- Voice Control
      vb:row{
        vb:text{text = "Voice:", width = 80},
        vb:popup{
          id = "PakettieSpeak_voice",
          width = 250,
          items = VOICES,
          value = ReSpeak.voice.value,
          notifier = function(idx)
            if not button_press_active then
              ReSpeak.voice.value = idx
              if ReSpeak.render_on_change.value then PakettieSpeakCreateSample(ReSpeak.text.value) end
            end
          end
        },
        vb:button{
          text = "-",
          width = 20,
          notifier = function()
            if vb.views.PakettieSpeak_voice.value > 2 then
              button_press_active = true
              vb.views.PakettieSpeak_voice.value = vb.views.PakettieSpeak_voice.value - 1
              ReSpeak.voice.value = vb.views.PakettieSpeak_voice.value
              if ReSpeak.render_on_change.value then PakettieSpeakCreateSample(ReSpeak.text.value) end
              button_press_active = false
            else
              renoise.app():show_status("You are at the beginning of the list")
            end
          end
        },
        vb:button{
          text = "+",
          width = 20,
          notifier = function()
            if vb.views.PakettieSpeak_voice.value < #VOICES then
              button_press_active = true
              vb.views.PakettieSpeak_voice.value = vb.views.PakettieSpeak_voice.value + 1
              ReSpeak.voice.value = vb.views.PakettieSpeak_voice.value
              if ReSpeak.render_on_change.value then PakettieSpeakCreateSample(ReSpeak.text.value) end
              button_press_active = false
            else
              renoise.app():show_status("You are at the bottom of the list")
            end
          end
        }
      },
      -- Other Controls (Word Gap, Pitch Capitals, etc.)
      vb:row{
        vb:text{width = 80, text = "Word Gap:"},
        vb:valuebox{
          id = "PakettieSpeak_gap_box",
          width = valuebox_width,
          min = 1,
          max = 10000,
          value = ReSpeak.word_gap.value,
          steps = {1, 10, 100},
          notifier = function(gap)
            ReSpeak.word_gap.value = gap
            print("Word Gap set to:", gap)
          end
        }
      },
      vb:row{
        vb:text{width = 80, text = "Pitch Capitals:"},
        vb:valuebox{
          id = "PakettieSpeak_capitals_box",
          width = valuebox_width,
          min = 1,
          max = 100,
          value = ReSpeak.capitals.value,
          steps = {1, 5},
          notifier = function(capitals)
            ReSpeak.capitals.value = capitals
            print("Pitch Capitals set to:", capitals)
          end
        }
      },
      vb:row{
        vb:text{width = 80, text = "Pitch:"},
        vb:valuebox{
          id = "PakettieSpeak_pitch_box",
          width = valuebox_width,
          min = 0,
          max = 99,
          value = ReSpeak.pitch.value,
          steps = {1, 5},
          notifier = function(pitch)
            ReSpeak.pitch.value = pitch
            print("Pitch set to:", pitch)
          end
        }
      },
      vb:row{
        vb:text{width = 80, text = "Amplitude:"},
        vb:valuebox{
          id = "PakettieSpeak_amplitude_box",
          width = valuebox_width,
          min = 0,
          max = 200,
          value = ReSpeak.amplitude.value,
          steps = {1, 5},
          notifier = function(amplitude)
            ReSpeak.amplitude.value = amplitude
            print("Amplitude set to:", amplitude)
          end
        }
      },
      vb:row{
        vb:text{width = 80, text = "Speed:"},
        vb:valuebox{
          id = "PakettieSpeak_speed_box",
          width = valuebox_width,
          min = 1,
          max = 500,
          value = ReSpeak.speed.value,
          steps = {1, 5},
          notifier = function(speed)
            ReSpeak.speed.value = speed
            print("Speed set to:", speed)
          end
        }
      }
    },
    -- Checkboxes
    vb:row{
      vb:checkbox{
        id = "PakettieSpeak_clear_all_samples",
        width = 18,
        height = 18,
        value = ReSpeak.clear_all_samples.value == true,
        notifier = function(bool)
          ReSpeak.clear_all_samples.value = bool
          print("Clear All Samples set to:", bool)
        end
      },
      vb:text{text = "Overwrite Samples in Selected Instrument"}
    },
    vb:row{
      vb:checkbox{
        id = "PakettieSpeak_render_on_change",
        width = 18,
        height = 18,
        value = ReSpeak.render_on_change.value == true,
        notifier = function(bool)
          ReSpeak.render_on_change.value = bool
          print("Render on Change set to:", bool)
        end
      },
      vb:text{text = "+/- Click Should Render Again"}
    },
    vb:space{height = 10},
    -- Load and Save Settings Buttons
    vb:horizontal_aligner{
      mode = "center",
      vb:button{
        id = "PakettieSpeak_load_button",
        width = button_width,
        height = 24,
        text = "Load Settings",
        notifier = function()
          local filename = renoise.app():prompt_for_filename_to_read({"*.rts"}, "Load Settings")
          if filename ~= "" then
            local result = ReSpeak:load_from(filename)
            if result == nil then
              renoise.app():show_error("Unable to Load Settings.")
            else
              print("Loaded Settings:", result)
              vb.views.PakettieSpeak_text_field.text = tostring(ReSpeak.text.value)
              vb.views.PakettieSpeak_language.value = ReSpeak.language.value
              vb.views.PakettieSpeak_voice.value = ReSpeak.voice.value
              vb.views.PakettieSpeak_gap_box.value = ReSpeak.word_gap.value
              vb.views.PakettieSpeak_capitals_box.value = ReSpeak.capitals.value
              vb.views.PakettieSpeak_pitch_box.value = ReSpeak.pitch.value
              vb.views.PakettieSpeak_amplitude_box.value = ReSpeak.amplitude.value
              vb.views.PakettieSpeak_speed_box.value = ReSpeak.speed.value
              local espeak_executable = PakettieSpeakRevertPath(ReSpeak.executable)
              vb.views.PakettieSpeak_exe_button.text = espeak_executable
              vb.views.PakettieSpeak_exe_button.width = math.min(#vb.views.PakettieSpeak_exe_button.text * 8, control_width)
              renoise.tool().preferences.pakettiReSpeak.executable = espeak_executable
              vb.views.PakettieSpeak_clear_all_samples.value = ReSpeak.clear_all_samples.value == true
              vb.views.PakettieSpeak_render_on_change.value = ReSpeak.render_on_change.value == true
              PakettieSpeakUpdateLineCount()
            end
          end
        end
      },
      vb:button{
        id = "PakettieSpeak_save_button",
        width = button_width,
        height = 24,
        text = "Save Settings",
        notifier = function()
          local filename = renoise.app():prompt_for_filename_to_write(".rts", "Save Settings")
          if filename ~= "" then
            ReSpeak.text.value = vb.views.PakettieSpeak_text_field.text
            local result = ReSpeak:save_as(filename)
            if result == nil then
              renoise.app():show_error("Unable to Save Settings.")
            else
              print("Saved Settings:", result)
            end
          end
        end
      }
    },
    vb:space{height = 5},
    -- Generate Sample and Randomize Settings Buttons
    vb:horizontal_aligner{
      mode = "center",
      vb:button{
        text = "Generate Sample",
        width = button_width,
        height = 24,
        notifier = function()
          ReSpeak.text.value = vb.views.PakettieSpeak_text_field.text
          PakettieSpeakCreateSample()
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
        end
      },
      vb:button{
        text = "Randomize Settings",
        width = button_width,
        height = 24,
        notifier = function()
          vb.views.PakettieSpeak_language.value = math.random(1, #LANGUAGE_NAMES)
          ReSpeak.language.value = vb.views.PakettieSpeak_language.value
          vb.views.PakettieSpeak_voice.value = math.random(1, #VOICES)
          ReSpeak.voice.value = vb.views.PakettieSpeak_voice.value
          local random_gap = math.random(1, 200)
          vb.views.PakettieSpeak_gap_box.value = random_gap
          ReSpeak.word_gap.value = random_gap
          local random_capitals = math.random(1, 100)
          vb.views.PakettieSpeak_capitals_box.value = random_capitals
          ReSpeak.capitals.value = random_capitals
          local random_pitch = math.random(0, 99)
          vb.views.PakettieSpeak_pitch_box.value = random_pitch
          ReSpeak.pitch.value = random_pitch
          local random_speed = math.random(1, 500)
          vb.views.PakettieSpeak_speed_box.value = random_speed
          ReSpeak.speed.value = random_speed
          if ReSpeak.render_on_change.value then
            PakettieSpeakCreateSample(ReSpeak.text.value)
          end
        end
      }
    },
    vb:space{height = 10}
  }
end

-- Function to show the GUI
function PakettieSpeakShowGUI()
  dialog = renoise.app():show_custom_dialog("Paketti eSpeak Text-to-Speech", PakettieSpeakMakeGUI(), PakettieSpeakKeyHandlerFunc)
  PakettieSpeakUpdateLineCount() -- Update line count when showing the dialog
end

-- Prepare function
function PakettieSpeakPrepare()
  print("Starting dialog with settings:")
  print("Text:", ReSpeak.text.value)
  -- ... (other print statements)

  if dialog and dialog.visible then
    dialog:show()
    return
  end

  local espeak_location = renoise.tool().preferences.pakettiReSpeak.executable
  if espeak_location ~= "" then
    ReSpeak.executable = PakettieSpeakConvertPath(espeak_location)
  else
    renoise.app():show_alert("Please set the eSpeak path before running.")
    return
  end

  PakettieSpeakShowGUI()
end

-- Key handler function
function PakettieSpeakKeyHandlerFunc(dialog, key)
  if key.modifiers == "" and key.name == "esc" then
    dialog:close()
  else
    return key
  end
end

-- Toggle dialog function
function PakettieSpeakToggleDialog()
  if dialog and dialog.visible then
    ReSpeak.text.value = vb.views.PakettieSpeak_text_field.text
    PakettieSpeakCreateSample()
  else
    PakettieSpeakPrepare()
  end
end

-- Function to create sample
function PakettieSpeakCreateSample(custom_text)
  local text_to_render = custom_text or ReSpeak.text.value
  print(text_to_render)
  local executable = PakettieSpeakRevertPath(ReSpeak.executable)
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
    -- Ensure pakettiPreferencesDefaultInstrumentLoader() is defined
    pakettiPreferencesDefaultInstrumentLoader()
    while #instrument.samples > 0 do
      instrument:delete_sample_at(1)
    end
    local sample = instrument:insert_sample_at(1)
    song.selected_instrument.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
    sample.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
  else
    instrument = song:insert_instrument_at(renoise.song().selected_instrument_index + 1)
    song.selected_instrument_index = renoise.song().selected_instrument_index + 1
    pakettiPreferencesDefaultInstrumentLoader()
    song.selected_instrument.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
    song.selected_instrument:insert_sample_at(1)
    local sample = song.selected_instrument.samples[1]
    sample.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
    normalize_selected_sample()
  end

  instrument.name = "eSpeak (" .. LANGUAGE_NAMES[ReSpeak.language.value] .. ", " .. VOICES_NAMES[ReSpeak.voice.value] .. ")"
  local sample = song.selected_instrument.samples[1]
  local buffer = sample.sample_buffer

  print("Loading path:" .. path)
  if not PakettieSpeakFileExists(path) then
    renoise.app():show_error("Sample was not rendered. An error happened.")
    return
  end

  local bool, result = buffer:load_from(path)
  local currentActiveMiddleFrame = renoise.app().window.active_middle_frame
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  normalize_selected_sample()
end

-- Check if file exists
function PakettieSpeakFileExists(path)
  local f = io.open(path, "r")
  return f ~= nil and io.close(f)
end

-- Add menu entry and keybindings
renoise.tool():add_menu_entry{
  name = "Sample Editor:Paketti..:Paketti eSpeak Text-to-Speech...",
  invoke = function()
    PakettieSpeakToggleDialog()
  end
}

renoise.tool():add_keybinding{
  name = "Global:Paketti:Paketti eSpeak Text-to-Speech",
  invoke = function()
    PakettieSpeakToggleDialog()
  end
}

-- Generate Sample Keybinding
renoise.tool():add_keybinding{
  name = "Global:Paketti:Paketti eSpeak Generate Sample",
  invoke = function()
    if dialog and dialog.visible then
      ReSpeak.text.value = vb.views.PakettieSpeak_text_field.text
      PakettieSpeakCreateSample()
    else
      PakettieSpeakPrepare()
    end
  end
}

-- Generate Selection Keybinding
renoise.tool():add_keybinding{
  name = "Global:Paketti:Paketti eSpeak Generate Selection",
  invoke = function()
    if dialog and dialog.visible then
      local text = vb.views.PakettieSpeak_text_field.text
      local start = vb.views.PakettieSpeak_start_pos.value
      local length = vb.views.PakettieSpeak_length_pos.value
      local end_pos = start + length - 1
      if start <= #text and end_pos <= #text and start <= end_pos then
        local selected_text = text:sub(start, end_pos)
        print("Selected text:", selected_text)
        renoise.app():show_status("Selected text: " .. selected_text)
        ReSpeak.text.value = selected_text
        PakettieSpeakCreateSample()
      else
        renoise.app():show_status("Invalid selection range")
      end
    else
      PakettieSpeakPrepare()
    end
  end
}

-- Generate Row Keybindings
for value = 0, 31 do
  renoise.tool():add_keybinding{
    name = ("Global:Paketti:Paketti eSpeak Generate Row %02d"):format(value),
    invoke = function()
      local text = vb.views.PakettieSpeak_text_field.text
      local lines = PakettieSpeakGetLines(text)
      -- If value is 0, take all the content, otherwise select the specific line.
      local selected_line = (value == 0) and text or (lines[value] or "")
      -- Protection: do nothing if selected line is empty
      if selected_line == "" then return end
      ReSpeak.text.value = selected_line
      if ReSpeak.render_on_change.value then
        PakettieSpeakCreateSample(ReSpeak.text.value)
      end
    end
  }
end

-- Refresh Keybinding
renoise.tool():add_keybinding{
  name = "Global:Paketti:Paketti eSpeak Refresh",
  invoke = function()
    if dialog and dialog.visible then
      PakettieSpeakLoadTextfile(true)
      print("Refresh: loaded textfile and updated textfield")
      ReSpeak.text.value = vb.views.PakettieSpeak_text_field.text
      PakettieSpeakUpdateLineCount()
    else
      PakettieSpeakPrepare()
    end
  end
}

_AUTO_RELOAD_DEBUG = function() end

