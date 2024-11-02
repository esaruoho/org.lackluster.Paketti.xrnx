--[[
  Paketti Preferences Optimization
  - Eliminates repeated filter type searches
  - Implements a lookup table for filter types
  - Caches the filter index
  - Removes unnecessary print statements
]]--

local dialog
local vb = renoise.ViewBuilder()
local initial_value = nil
local dialog = nil
local pakettiDeviceChainPathDisplayId

-- Define a debug flag
local DEBUG = false

-- Lookup table for filter types
local filter_types = {
  "None", "LP Clean", "LP K35", "LP Moog", "LP Diode", "HP Clean",
  "HP K35", "HP Moog", "BP Clean", "BP K35", "BP Moog", "BandPass",
  "BandStop", "Vowel", "Comb", "Decimator", "Dist Shape", "Dist Fold",
  "AM Sine", "AM Triangle", "AM Saw", "AM Pulse"
}

function loadPlaidZap()
    renoise.app():load_instrument("Gifts/plaidzap.xrni")
end


local filter_type_map = {}
for i, v in ipairs(filter_types) do
  filter_type_map[v] = i
end

-- Function to get the index of a filter type using the lookup table
local function get_filter_type_index(filter_type)
  local index = filter_type_map[filter_type]
  if index then
    if DEBUG then
      print("Found filter type: " .. filter_type .. " at index: " .. index)
    end
    return index
  else
    if DEBUG then
      print("Filter type not found, defaulting to index 1 ('None').")
    end
    return 1 -- Default to "None" if not found
  end
end

-- Initialize the filter index
local cached_filter_index = 1

local function my_keyhandler_func(dialog, key)
  local closer = preferences.pakettiDialogClose.value

  if key.modifiers == "" and key.name == closer then
    dialog:close()
    dialog = nil
    return nil
  end

  if not (key.modifiers == "" and key.name == "exclamation") then
    return key
  else
    dialog:close()
    dialog = nil
    return nil
  end
end

local sample_rates = {22050, 44100, 48000, 88200, 96000, 192000}

-- Function to find the index of the sample rate
local function find_sample_rate_index(rate)
    for i, v in ipairs(sample_rates) do
        if v == rate then
            return i
        end
    end
    return 1 -- default to 22050 if not found
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

-- Main Preferences Document with Segments
preferences = renoise.Document.create("ScriptingToolPreferences") {
  pakettiDialogClose="esc",
  PakettiDeviceChainPath = "DeviceChains/",
  upperFramePreference=0,
  _0G01_Loader=false,
  RandomBPM=false,
  loadPaleGreenTheme=false,
  PakettiStripSilenceThreshold=0.0121,
  PakettiMoveSilenceThreshold=0.0121,
  renderSampleRate=88200,
  renderBitDepth=32,
  renderBypass=false,
  pakettiEditMode=1,
  pakettiLoaderInterpolation=1,
  pakettiLoaderFilterType="LP Clean",
  pakettiLoaderOverSampling=true,
  pakettiLoaderOneshot=false,
  pakettiLoaderAutoFade=true,
  pakettiLoaderAutoseek=false,
  pakettiLoaderLoopMode=1,
  pakettiLoaderNNA=2,
  pakettiLoaderLoopExit=false,
  selectionNewInstrumentSelect=false,
  selectionNewInstrumentLoop=2,
  selectionNewInstrumentInterpolation=4,
  selectionNewInstrumentAutoFade=true,
  selectionNewInstrumentAutoseek=false,
  pakettiPitchbendLoaderEnvelope=false,
  pakettiSlideContentAutomationToo=true,
  pakettiDefaultXRNI="Presets/12st_Pitchbend.xrni",
  pakettiDefaultDrumkitXRNI="Presets/12st_Pitchbend_Drumkit_C0.xrni",

  UserPreferences = {
    userPreferredDevice01 = "<None>",
    userPreferredDevice02 = "<None>",
    userPreferredDevice03 = "<None>",
    userPreferredDevice04 = "<None>",
    userPreferredDevice05 = "<None>",
    userPreferredDevice06 = "<None>",
    userPreferredDevice07 = "<None>",
    userPreferredDevice08 = "<None>",
    userPreferredDevice09 = "<None>",
    userPreferredDevice10 = "<None>",
    userPreferredDeviceLoad = true
  },
  -- WipeSlices Segment
  WipeSlices = {
    WipeSlicesLoopMode=2,
    WipeSlicesLoopRelease=false,
    WipeSlicesBeatSyncMode=1,
    WipeSlicesOneShot=false,
    WipeSlicesAutoseek=false,
    WipeSlicesAutofade=true,
    WipeSlicesMuteGroup=1,
    WipeSlicesNNA=1,
    WipeSlicesBeatSyncGlobal=false,
    sliceCounter=1,
    slicePreviousDirection=1
  },
-- changes made
  -- AppSelection and SmartFolders Segment
  AppSelection = {
    AppSelection1="",
    AppSelection2="",
    AppSelection3="",
    AppSelection4="",
    AppSelection5="",
    AppSelection6="",
    SmartFoldersApp1="",
    SmartFoldersApp2="",
    SmartFoldersApp3=""
  },
  pakettiThemeSelector = {
    PreviousSelectedTheme = "",
    FavoritedList = { "<No Theme Selected>" }, -- Initialize as a simple table
    RenoiseLaunchFavoritesLoad = false,
    RenoiseLaunchRandomLoad = false
  },
  
-- changes made
  -- Paketti eSpeak Segment
  pakettieSpeak = {
    word_gap=3,
    capitals=5,
    pitch=35,
    amplitude=05,
    speed=150,
    language=40,
    voice=2,
    text="Good afternoon, this is eSpeak, a Text-to-Speech engine, speaking. Shall we play a game?",
    executable=default_executable,
    clear_all_samples=true,
    add_render_to_current_instrument=false,
    render_on_change=false
  },

  OctaMEDPickPutSlots = {
    SetSelectedInstrument=false,
    UseEditStep=false,
    Slot01="",
    Slot02="",
    Slot03="",
    Slot04="",
    Slot05="",
    Slot06="",
    Slot07="",
    Slot08="",
    Slot09="",
    Slot10="",
    RandomizeEnabled=false,
    RandomizePercentage=10,
  },

  RandomizeSettings = {
    pakettiRandomizeSelectedDevicePercentage=50,
    pakettiRandomizeSelectedDevicePercentageUserPreference1=10,
    pakettiRandomizeSelectedDevicePercentageUserPreference2=25,
    pakettiRandomizeSelectedDevicePercentageUserPreference3=50,
    pakettiRandomizeSelectedDevicePercentageUserPreference4=75,
    pakettiRandomizeSelectedDevicePercentageUserPreference5=90,
    pakettiRandomizeAllDevicesPercentage=50,
    pakettiRandomizeAllDevicesPercentageUserPreference1=10,
    pakettiRandomizeAllDevicesPercentageUserPreference2=25,
    pakettiRandomizeAllDevicesPercentageUserPreference3=50,
    pakettiRandomizeAllDevicesPercentageUserPreference4=75,
    pakettiRandomizeAllDevicesPercentageUserPreference5=90,
    pakettiRandomizeSelectedPluginPercentage=50,
    pakettiRandomizeSelectedPluginPercentageUserPreference1=10,
    pakettiRandomizeSelectedPluginPercentageUserPreference2=20,
    pakettiRandomizeSelectedPluginPercentageUserPreference3=30,
    pakettiRandomizeSelectedPluginPercentageUserPreference4=40,
    pakettiRandomizeSelectedPluginPercentageUserPreference5=50,
    pakettiRandomizeAllPluginsPercentage=50,
    pakettiRandomizeAllPluginsPercentageUserPreference1=10,
    pakettiRandomizeAllPluginsPercentageUserPreference2=20,
    pakettiRandomizeAllPluginsPercentageUserPreference3=30,
    pakettiRandomizeAllPluginsPercentageUserPreference4=40,
    pakettiRandomizeAllPluginsPercentageUserPreference5=50
  },
  pakettiColuga = {
    pakettiColugaLoopMode=2,
    pakettiColugaClipLength=10,
    pakettiColugaAmountOfVideos=1,
    pakettiColugaLoadWholeVideo=true,
    pakettiColugaOutputDirectory="Set this yourself, please.",
    pakettiColugaFormatToSave=1,
    pakettiColugaPathToSave="<No path set>",
    pakettiColugaNewInstrumentOrSameInstrument=true,
    pakettiColugaYT_DLPLocation="<No path set>"  
  },
  
  pakettiCheatSheet = {
    pakettiCheatSheetRandomize=false,
    pakettiCheatSheetRandomizeMin=0,
    pakettiCheatSheetRandomizeMax=255,
    pakettiCheatSheetFillAll=100,
    pakettiCheatSheetRandomizeWholeTrack=false,
    pakettiCheatSheetRandomizeSwitch=false,
    pakettiCheatSheetRandomizeDontOverwrite=false
}, 

  pakettiPhraseInitDialog = {
    Autoseek = false,
    VolumeColumnVisible = false,
    PanningColumnVisible = false,
    InstrumentColumnVisible = false,
    DelayColumnVisible = false,
    SampleFXColumnVisible = false,
    NoteColumns = 1,
    EffectColumns = 0,
    Shuffle = 0,
    LPB = 4,
    Length = 64,
    SetName = false,
    Name = ""
    },
  pakettiDynamicViews = {
  bla ="ble"
  }
}

-- Assigning Preferences to renoise.tool
renoise.tool().preferences = preferences

-- Accessing Segments
eSpeak = renoise.tool().preferences.pakettieSpeak
pakettiThemeSelector = renoise.tool().preferences.pakettiThemeSelector
WipeSlices = renoise.tool().preferences.WipeSlices
AppSelection = renoise.tool().preferences.AppSelection
RandomizeSettings = renoise.tool().preferences.RandomizeSettings
pakettiColuga = renoise.tool().preferences.pakettiColuga

-- Function to initialize the filter index
local function initialize_filter_index()
  if preferences.pakettiLoaderFilterType.value ~= nil then
    cached_filter_index = get_filter_type_index(preferences.pakettiLoaderFilterType.value)
  else
    preferences.pakettiLoaderFilterType.value = "LP Moog"
    cached_filter_index = get_filter_type_index("LP Moog")
  end
end

-- Call the initialization function once
initialize_filter_index()

local function pakettiGetXRNIDefaultPresetFiles()
    local presetsFolder = "Presets/"
    local files = os.filenames(presetsFolder, "*.xrni")
    
    -- Check if any presets were found
    if not files or #files == 0 then
        renoise.app():show_status("No .xrni preset files found in: " .. presetsFolder)
        return { "<No Preset Selected>" }
    end
    
    -- Sort the files alphabetically for better user experience
    table.sort(files, function(a, b) return a:lower() < b:lower() end)
    
    -- Insert a default option at the beginning
    table.insert(files, 1, "<No Preset Selected>")
    
    return files
end

-- Function to create horizontal rule
function horizontal_rule()
    return vb:horizontal_aligner{mode="justify", width="100%", vb:space{width=2}, vb:row{height=2, width="30%", style="panel"}, vb:space{width=2}}
end

-- Function to create vertical space
function vertical_space(height) return vb:row{height = height} end

-- Functions to update preferences
function update_interpolation_mode(value) preferences.pakettiLoaderInterpolation.value = value end
function update_autofade_mode(value) preferences.pakettiLoaderAutoFade.value = value end
function update_oversampling_mode(value) preferences.pakettiLoaderOverSampling.value=value end

function update_loop_mode(loop_mode_pref, value)
  loop_mode_pref.value = value
  preferences.pakettiLoaderLoopMode.value = value
end

function create_loop_mode_switch(preference)
  return vb:switch{
    items = {"Off", "Forward", "Backward", "PingPong"},
    value = preference.value,
    width = 400,
    notifier = function(value)
      update_loop_mode(preference, value)
    end
  }
end

-- Initialize filter index
if preferences.pakettiLoaderFilterType.value ~= nil then
  initial_value = get_filter_type_index(preferences.pakettiLoaderFilterType.value)
else
  preferences.pakettiLoaderFilterType.value ="LP Moog"
  initial_value = get_filter_type_index("LP Moog")
end

local dialog_content = nil

function show_paketti_preferences()
    local threshold_label = vb:text {
        text = string.format("%.3f%%", preferences.PakettiStripSilenceThreshold.value * 100), width=100
    }

    local begthreshold_label = vb:text {
        text = string.format("%.3f%%", preferences.PakettiMoveSilenceThreshold.value * 100), width=100
    }

    local pakettiDeviceChainPathDisplayId = "pakettiDeviceChainPathDisplay_" .. tostring(math.random(2, 30000))

    local upperbuttonwidth=160
    if dialog and dialog.visible then
        dialog_content=nil
        dialog:close()
        return
    end

        local presetFiles = pakettiGetXRNIDefaultPresetFiles()
    
    -- Get the initial value (index) for the popup
    local pakettiDefaultXRNIDisplayId = "pakettiDefaultXRNIDisplay_" .. tostring(math.random(2,30000))
    local pakettiDefaultDrumkitXRNIDisplayId = "pakettiDefaultDrumkitXRNIDisplay_" .. tostring(math.random(2,30000))

    local dialog_content = vb:column {
      margin=10,

      -- Full-width row for buttons wrapped in a group
      vb:column {
        style="group",margin=10, width="100%",
        vb:row {
          vb:button{text="About Paketti/Donations", width=50, notifier=function() show_about_dialog() end},
          vb:button{text="Theme Selector",width=upperbuttonwidth-100,notifier=function() pakettiThemeSelectorDialogShow() end},
          vb:button{text="Gater",width=upperbuttonwidth-150,notifier=function()
            local max_rows=nil
            max_rows=renoise.song().selected_pattern.number_of_lines
            if renoise.song() then
              pakettiGaterDialog()
              renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
            end
          end},
          vb:button{text="Audio Processing",width=upperbuttonwidth-100,notifier=function() PakettiAudioProcessingToolsDialogShow() end},
          vb:button{text="Effect CheatSheet",width=40,notifier=function() CheatSheet() end},
          vb:button{text="Phrase Init Dialog",width=upperbuttonwidth-100,notifier=function() pakettiPhraseSettingsDialogShow() end},
          vb:button{text="Randomize Plugins/Devices", width=50, notifier=function()
          openCombinedRandomizerDialog() end},
          vb:button{text="Configure Launch App Selection/Paths", width=50, notifier=function()
          show_app_selection_dialog() end},
          vb:button{text="MIDI Populator",width=upperbuttonwidth-100,notifier=function() generaMIDISetupShowCustomDialog() end},
          vb:button{text="KeyBindings",width=upperbuttonwidth-100,notifier=function() showPakettiKeyBindingsDialog() end},
          vb:button{text="Midi Mappings",width=upperbuttonwidth-100,notifier=function() show_midi_mappings_dialog() end}
        }
      },

      -- Horizontal rule
      horizontal_rule(),

      vb:row {
        vb:column {
          margin=5,width=600,style="group",      
          vb:column {
            style="group",margin=10, width="100%",
            vb:text{style="strong",font="bold",text="Miscellaneous Settings"},
            vb:row {
              vb:text{text="Upper Frame",width=150},
              vb:switch{items={"Off","Scopes","Spectrum"},value=preferences.upperFramePreference.value+1,width=200,
                notifier=function(value) preferences.upperFramePreference.value=value-1 end}
            },
            -- Splitting and positioning the long text on a new row
            vb:row {vb:text{style="strong",text="Whether F2,F3,F4,F11 change the Upper Frame Scope state or not"}},
            vb:row {
              vb:text{text="0G01 Loader",width=150},
              vb:switch{items={"Off","On"},value=preferences._0G01_Loader.value and 2 or 1,width=200,
                notifier=function(value)
                  preferences._0G01_Loader.value=(value==2)
                  update_0G01_loader_menu_entries()
                end}
            },
            -- Splitting and positioning the long text on a new row
            vb:row {vb:text{style="strong",text="Upon loading a Sample, inserts a C-4 and -G01 to New Track, Sample plays until end of length and triggers again."}},

            vb:row {
              vb:text{text="Random BPM",width=150},
              vb:switch{items={"Off","On"},value=preferences.RandomBPM.value and 2 or 1,width=200,
                notifier=function(value) preferences.RandomBPM.value=(value==2) update_random_bpm_preferences() end}
            },
            vb:row { vb:text{text="Pale Green Theme",width=150},vb:button{text="Load",width=100,notifier=function() update_loadPaleGreenTheme_preferences() end} },
            vb:row { vb:text{text="Gifts: Plaid Zap .XRNI",width=150},vb:button{text="Load",width=100,notifier=function() loadPlaidZap() end} }
          },
    horizontal_rule(),
            vb:column{style = "group", margin = 10, width="100%",
                vb:row{vb:text{text = "Create New Instrument & Loop from Selection", font="bold",style = "strong"}},
                vb:row{vb:text{text = "Select Newly Created", width = 150},
                    vb:switch{items = {"Off", "On"},
                        value = preferences.selectionNewInstrumentSelect.value and 2 or 1,
                        width = 200,
                        notifier = function(value)
                            preferences.selectionNewInstrumentSelect.value = (value == 2)
                        end}},
          vb:row { vb:text{text="Sample Interpolation",width=150},vb:switch{items={"None","Linear","Cubic","Sinc"},value=preferences.selectionNewInstrumentInterpolation.value,width=200,
              notifier=function(value) 
                  preferences.selectionNewInstrumentInterpolation.value = value end}
            },
                    vb:row{vb:text{text = "Loop on Newly Created", width = 150},
                    create_loop_mode_switch(preferences.selectionNewInstrumentLoop)},
            vb:row { vb:text{text="Autoseek",width=150},vb:switch{items={"Off","On"},value=preferences.selectionNewInstrumentAutoseek.value and 2 or 1,width=200,
              notifier=function(value) preferences.selectionNewInstrumentAutoseek.value=(value ==2) end}
            },
            vb:row { vb:text{text="AutoFade",width=150},vb:switch{items={"Off","On"},value=preferences.selectionNewInstrumentAutoFade.value and 2 or 1,width=200,
              notifier=function(value) 
              preferences.selectionNewInstrumentAutoFade.value=(value==2) 
              end}
            }},
          -- Render Settings wrapped in group
          horizontal_rule(),
          vb:column {
            style="group",margin=10, width="100%",
            vb:text{style="strong",font="bold",text="Render Settings"}, -- Applied bold and strong
            vb:row { vb:text{text="Sample Rate",width=150},vb:switch{items={"22050","44100","48000","88200","96000","192000"},value=find_sample_rate_index(preferences.renderSampleRate.value),width=300,
              notifier=function(value) preferences.renderSampleRate.value=sample_rates[value] end}
            },
            vb:row { vb:text{text="Bit Depth",width=150},vb:switch{items={"16","24","32"},value=preferences.renderBitDepth.value==16 and 1 or preferences.renderBitDepth.value==24 and 2 or 3,width=300,
              notifier=function(value) preferences.renderBitDepth.value=(value==1 and 16 or value==2 and 24 or 32) end}
            },
            vb:row { vb:text{text="Bypass Devices",width=150},vb:switch{items={"Off","On"},value=preferences.renderBypass.value and 2 or 1,width=300,
              notifier=function(value) preferences.renderBypass.value=(value==2) end}
            }
          },

          -- Strip Silence / Move Beginning Silence to End wrapped in group
          horizontal_rule(),
     vb:column {
      style = "group", margin = 10, width = "100%",

      -- Title text
      vb:text{style = "strong", font = "bold", text = "Silence Settings"},

      -- First row for Strip Silence Threshold
      vb:row {vb:text{text="Strip Silence Threshold:", width=150},
        vb:minislider{
          min=0,
          max=1,
          value=preferences.PakettiStripSilenceThreshold.value,
          width=200,
          notifier = function(value)
            threshold_label.text = string.format("%.3f%%", value * 100) -- Update the label
            preferences.PakettiStripSilenceThreshold.value = value
          end
        },threshold_label,
      },

      -- Second row for Move Silence Threshold
      vb:row {
        vb:text {text = "Move Silence Threshold:", width = 150},
        vb:minislider {
          min = 0,
          max = 1,
          value = preferences.PakettiMoveSilenceThreshold.value,
          width = 200,
          notifier = function(value)
            begthreshold_label.text = string.format("%.3f%%", value * 100) -- Update the label
            preferences.PakettiMoveSilenceThreshold.value = value
          end
        },begthreshold_label,
      },

    },

          -- Edit Mode Coloring wrapped in group
          horizontal_rule(),
          vb:column {
            style="group",margin=10, width="100%",
            vb:text{style="strong",font="bold",text="Edit Mode Colouring"}, -- Applied bold and strong
            vb:row { vb:text{text="Edit Mode",width=150},vb:switch{items={"None","Selected Track","All Tracks"},value=preferences.pakettiEditMode.value,width=300,
              notifier=function(value) preferences.pakettiEditMode.value=value end}
            },
            vb:row { vb:text{style="strong",text="Enable Scope Highlight by going to Settings -> GUI -> Show Track Color Blends."} }
          }
        },

        -- Column 2
        vb:column {
          style="group",margin=5,width=600,
          -- Paketti Loader Settings wrapped in group
          vb:column {
            style="group",margin=10, width="100%",
            vb:text{style="strong",font="bold",text="Paketti Loader Settings"},
            vb:row { vb:text{text="Sample Interpolation",width=150},vb:switch{items={"None","Linear","Cubic","Sinc"},value=preferences.pakettiLoaderInterpolation.value,width=200,
              notifier=function(value) update_interpolation_mode(value) end}
            },
            vb:row { vb:text{text="One-Shot",width=150},vb:switch{items={"Off","On"},value=preferences.pakettiLoaderOneshot.value and 2 or 1,width=200,
              notifier=function(value) preferences.pakettiLoaderOneshot.value=(value==2) end}
            },
            vb:row { vb:text{text="Autoseek",width=150},vb:switch{items={"Off","On"},value=preferences.pakettiLoaderAutoseek.value and 2 or 1,width=200,
              notifier=function(value) preferences.pakettiLoaderAutoseek.value=(value==2) end}
            },
            vb:row { vb:text{text="AutoFade",width=150},vb:switch{items={"Off","On"},value=preferences.pakettiLoaderAutoFade.value and 2 or 1,width=200,
              notifier=function(value) preferences.pakettiLoaderAutoFade.value=(value==2) end}
            },
            vb:row { vb:text{text="New Note Action(NNA) Mode",width=150},vb:switch{items={"Cut","Note-Off","Continue"},value=preferences.pakettiLoaderNNA.value,width=300,
              notifier=function(value) preferences.pakettiLoaderNNA.value=value end}
            },
            vb:row { vb:text{text="OverSampling",width=150},vb:switch{items={"Off","On"},value=preferences.pakettiLoaderOverSampling.value and 2 or 1,width=200,
              notifier=function(value) preferences.pakettiLoaderOverSampling.value=(value==2) end}
            },
            vb:row { vb:text{text="Loop Mode",width=150},create_loop_mode_switch(preferences.pakettiLoaderLoopMode) },
            vb:row { vb:text{text="Loop Release/Exit Mode",width=150},vb:checkbox{value=preferences.pakettiLoaderLoopExit.value,notifier=function(value) preferences.pakettiLoaderLoopExit.value=value end} },
            vb:row { vb:text{text="Enable AHDSR Envelope",width=150},vb:checkbox{value=preferences.pakettiPitchbendLoaderEnvelope.value,notifier=function(value) preferences.pakettiPitchbendLoaderEnvelope.value=value end} },
            vb:row { 
              vb:text{text="FilterType",width=150},
              vb:popup{
                items = filter_types,
                value = cached_filter_index,
                width = 200,
                notifier = function(value)
                  preferences.pakettiLoaderFilterType.value = filter_types[value]
                  cached_filter_index = value -- Update the cached index
                  -- Removed print statements for performance
                  preferences:save_as("preferences.xml")
                end
              }
            },
    --[[        vb:row { vb:text{text="Default XRNI to use:",width=150},vb:textfield{text=preferences.pakettiDefaultXRNI.value:match("[^/\\]+$"),width=300,id=pakettiDefaultXRNIDisplayId,notifier=function(value) preferences.pakettiDefaultXRNI.value=value end},vb:button{text="Browse",width=100,notifier=function()
              local filePath=renoise.app():prompt_for_filename_to_read({"*.XRNI"},"Paketti Default XRNI Selector Dialog")
              if filePath and filePath~="" then preferences.pakettiDefaultXRNI.value=filePath vb.views[pakettiDefaultXRNIDisplayId].text=filePath:match("[^/\\]+$") else renoise.app():show_status("No XRNI Instrument was selected") end end} },
              --]]
    -- Generate a unique id based on timestamp or counter

    vb:row { 
      vb:text {
        text = "Default XRNI to use:", 
        width = 150
      },
      
      vb:textfield {
        text = preferences.pakettiDefaultXRNI.value:match("[^/\\]+$"), 
        width = 300, 
        id = pakettiDefaultXRNIDisplayId, -- Use dynamic ID
        notifier = function(value)
          preferences.pakettiDefaultXRNI.value = value
        end
      },
      
      vb:button {
        text = "Browse", 
        width = 100, 
        notifier = function()
          local filePath = renoise.app():prompt_for_filename_to_read({"*.XRNI"}, "Paketti Default XRNI Selector Dialog")
          
          if filePath and filePath ~= "" then 
            preferences.pakettiDefaultXRNI.value = filePath 
            vb.views[pakettiDefaultXRNIDisplayId].text = filePath:match("[^/\\]+$")
          else 
            renoise.app():show_status("No XRNI Instrument was selected")
          end
        end
      }
    },
              
              
              
            vb:row { vb:text{text="Preset Files:",width=150},vb:popup{items=presetFiles,width=300,notifier=function(value)
              local selectedFile=presetFiles[value] 
              preferences.pakettiDefaultXRNI.value="Presets/"..selectedFile 
              vb.views[pakettiDefaultXRNIDisplayId].text=selectedFile 
            end} },
         
            vb:row { vb:text{text="Default Drumkit XRNI to use:",width=150},vb:textfield{text=preferences.pakettiDefaultDrumkitXRNI.value:match("[^/\\]+$"),width=300,id=pakettiDefaultDrumkitXRNIDisplayId,notifier=function(value) preferences.pakettiDefaultDrumkitXRNI.value=value end},vb:button{text="Browse",width=100,notifier=function()
              local filePath=renoise.app():prompt_for_filename_to_read({"*.XRNI"},"Paketti Default Drumkit XRNI Selector Dialog")
              if filePath and filePath~="" then preferences.pakettiDefaultDrumkitXRNI.value=filePath vb.views[pakettiDefaultDrumkitXRNIDisplayId].text=filePath:match("[^/\\]+$") else renoise.app():show_status("No XRNI Drumkit Instrument was selected") end end} },
            vb:row { vb:text{text="Preset Files:",width=150},vb:popup{items=presetFiles,width=300,notifier=function(value)
              local selectedFile=presetFiles[value] 
              preferences.pakettiDefaultDrumkitXRNI.value="Presets/"..selectedFile 
              vb.views[pakettiDefaultDrumkitXRNIDisplayId].text=selectedFile 
            end} }
          },

          -- Wipe & Slice Settings wrapped in group
          horizontal_rule(),
          vb:column {
            style="group",margin=10, width="100%",
            vb:text{style="strong",font="bold",text="Wipe & Slices Settings"},
            vb:row { vb:text{text="Slice Loop Mode",width=150},create_loop_mode_switch(preferences.WipeSlices.WipeSlicesLoopMode) },
            vb:row { vb:text{text="Slice Loop Release/Exit Mode",width=150},vb:checkbox{value=preferences.WipeSlices.WipeSlicesLoopRelease.value,notifier=function(value) preferences.WipeSlices.WipeSlicesLoopRelease.value=value end} },
            vb:row { vb:text{text="Slice BeatSync Mode",width=150},vb:switch{items={"Repitch","Time-Stretch (Percussion)","Time-Stretch (Texture)","Off"},value=preferences.WipeSlices.WipeSlicesBeatSyncMode.value,width=420,
              notifier=function(value) preferences.WipeSlices.WipeSlicesBeatSyncMode.value=value end}
            },
            vb:row { vb:text{text="Slice One-Shot",width=150},vb:switch{items={"Off","On"},value=preferences.WipeSlices.WipeSlicesOneShot.value and 2 or 1,width=200,
              notifier=function(value) preferences.WipeSlices.WipeSlicesOneShot.value=(value==2) end}
            },
            vb:row { vb:text{text="Slice Autoseek",width=150},vb:switch{items={"Off","On"},value=preferences.WipeSlices.WipeSlicesAutoseek.value and 2 or 1,width=200,
              notifier=function(value) preferences.WipeSlices.WipeSlicesAutoseek.value=(value==2) end}
            },
            vb:row { vb:text{text="Slice Autofade",width=150},vb:switch{items={"Off","On"},value=preferences.WipeSlices.WipeSlicesAutofade.value and 2 or 1,width=200,
              notifier=function(value) preferences.WipeSlices.WipeSlicesAutofade.value=(value==2) end}
            },
            vb:row { vb:text{text="New Note Action(NNA) Mode",width=150},vb:switch{items={"Cut","Note-Off","Continue"},value=preferences.WipeSlices.WipeSlicesNNA.value,width=300,
              notifier=function(value) preferences.WipeSlices.WipeSlicesNNA.value=value end}
            },
            vb:row { vb:text{text="Mute Group",width=150},vb:switch{items={"Off","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"},value=preferences.WipeSlices.WipeSlicesMuteGroup.value+1,width=400,
              notifier=function(value) preferences.WipeSlices.WipeSlicesMuteGroup.value=value-1 end}
            }
          },
    --    },
        
        vb:text{style="strong", font="bold", text="Random Device Chain Loader Path"},
    
    vb:row{
        vb:textfield{
            text = preferences.PakettiDeviceChainPath.value,
            width = 300,
            id = pakettiDeviceChainPathDisplayId,
            notifier = function(value)
                preferences.PakettiDeviceChainPath.value = value
            end
        },
        vb:button{
            text = "Browse",
            width = 60,
            notifier = function()
                local path = renoise.app():prompt_for_path("Select Device Chain Path")
                if path and path ~= "" then
                    preferences.PakettiDeviceChainPath.value = path
                    vb.views[pakettiDeviceChainPathDisplayId].text = path
                else
                    renoise.app():show_status("No path was selected, returning to default.")
                    preferences.PakettiDeviceChainPath.value = "DeviceChains/"
                    vb.views[pakettiDeviceChainPathDisplayId].text = "DeviceChains/"
                end
            end
        },
        vb:button{
            text = "Reset to Default",
            width = 100,
            notifier = function()
                preferences.PakettiDeviceChainPath.value = "DeviceChains/"
                vb.views[pakettiDeviceChainPathDisplayId].text = "DeviceChains/"
            end
        },
        vb:button{text="Load Random Chain",width=100,notifier=function()
        PakettiRandomDeviceChain(preferences.PakettiDeviceChainPath.value)
        end
        }}
    },
        
      },

      -- Bottom Buttons
      vb:horizontal_aligner { mode="distribute",
        vb:button{text="OK",width="50%",notifier=function() 
          preferences:save_as("preferences.xml")
          print (preferences.pakettiDefaultXRNI.value)
          print (preferences.pakettiLoaderFilterType.value)
          dialog:close() 
        end},
        vb:button{text="Cancel",width="50%",notifier=function() dialog:close() end}
      }
    }

    dialog = renoise.app():show_custom_dialog("Paketti Preferences", dialog_content, my_keyhandler_func)
end

function on_sample_count_change()
    if not preferences._0G01_Loader.value then return end
    local song = renoise.song()
    if not song or #song.tracks == 0 or song.selected_track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then return end

    local selected_track_index = song.selected_track_index
    local new_track_idx = selected_track_index + 1

    song:insert_track_at(new_track_idx)
    local line = song.patterns[song.selected_pattern_index].tracks[new_track_idx]:line(1)
    song.selected_track_index = new_track_idx
    line.note_columns[1].note_string = "C-4"
    line.note_columns[1].instrument_value = song.selected_instrument_index - 1
    line.effect_columns[1].number_string = "0G"
    line.effect_columns[1].amount_value = 01
end

function manage_sample_count_observer(attach)
    local song = renoise.song()
    local instr = song.selected_instrument
    if attach then
        if not instr.samples_observable:has_notifier(on_sample_count_change) then
            instr.samples_observable:add_notifier(on_sample_count_change)
        end
    else
        if instr.samples_observable:has_notifier(on_sample_count_change) then
            instr.samples_observable:remove_notifier(on_sample_count_change)
        end
    end
end

function update_dynamic_menu_entries()
    local enableMenuEntryName = "Main Menu:Tools:Paketti..:!Preferences..:0G01 Loader Enable"
    local disableMenuEntryName = "Main Menu:Tools:Paketti..:!Preferences..:0G01 Loader Disable"

    if preferences._0G01_Loader.value then
        if renoise.tool():has_menu_entry(enableMenuEntryName) then
            renoise.tool():remove_menu_entry(enableMenuEntryName)
        end
        if not renoise.tool():has_menu_entry(disableMenuEntryName) then
            renoise.tool():add_menu_entry{name = disableMenuEntryName,
                invoke = function()
                    preferences._0G01_Loader.value = false
                    update_dynamic_menu_entries()
                    if dialog and dialog.visible then
                        dialog:close()
                        show_paketti_preferences()
                    end
                end}
        end
    else
        if renoise.tool():has_menu_entry(disableMenuEntryName) then
            renoise.tool():remove_menu_entry(disableMenuEntryName)
        end
        if not renoise.tool():has_menu_entry(enableMenuEntryName) then
            renoise.tool():add_menu_entry{name = enableMenuEntryName,
                invoke = function()
                    preferences._0G01_Loader.value = true
                    update_dynamic_menu_entries()
                    if dialog and dialog.visible then
                        dialog:close()
                        show_paketti_preferences()
                    end
                end}
        end
    end
end

function update_0G01_loader_menu_entries()
    manage_sample_count_observer(preferences._0G01_Loader.value)
    update_dynamic_menu_entries()
end

function initialize_tool()
    update_0G01_loader_menu_entries()
end

function safe_initialize()
    if not renoise.tool().app_idle_observable:has_notifier(initialize_tool) then
        renoise.tool().app_idle_observable:add_notifier(initialize_tool)
    end
    load_Pakettipreferences()
    initialize_filter_index() -- Ensure the filter index is initialized
end

function load_Pakettipreferences()
    if io.exists("preferences.xml") then
        preferences:load_from("preferences.xml")
    end
end

function update_loadPaleGreenTheme_preferences() renoise.app():load_theme("Themes/Lackluster - Pale Green Renoise Theme.xrnc") end


safe_initialize()

renoise.tool():add_menu_entry{name = "Main Menu:Tools:Paketti..:!Preferences..:Paketti Preferences...", invoke = show_paketti_preferences}
renoise.tool():add_keybinding{name = "Global:Paketti:Show Paketti Preferences...", invoke = show_paketti_preferences}

