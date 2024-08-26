require "Paketti0G01_Loader"
require "PakettiKeyBindings"
require "PakettiThemeSelector"
require "PakettieSpeak"
require "base64float"
local rx = require 'rx'
require "PakettiAutomation"

require "PakettiControls"
require "PakettiDeviceChains"
require "PakettiGater"
require "PakettiImpulseTracker"
require "PakettiInstrumentBox"
require "PakettiLoaders"
require "PakettiLoadNativeGUI"
require "PakettiLoadVSTGUI"
require "PakettiLoadAUVST3GUI"
require "PakettiLoadLADSPADSSI"
require "PakettiLoadPlugins"
require "PakettiMainMenuEntries"
require "PakettiMidi"
require "PakettiPatternEditor"
require "PakettiPatternEditorCheatSheet"
require "PakettiPatternMatrix"
require "PakettiPatternSequencer"
require "PakettiPhraseEditor"
require "PakettiPlayerProSuite"
require "PakettiSamples"
require "PakettiTkna"
require "PakettiRecorder" 
require "PakettiExperimental_Verify"
require "Coluga/PakettiColuga"
-- These were requested via GitHub / Renoise Forum / Renoise Discord - always get in touch with me (esaruoho@icloud.com)
-- Or post a feature on https://github.com/esaruoho/org.lackluster.Paketti.xrnx/issues/new
require "PakettiRequests"

------------------------------------------------
-- Autoexec.bat
-- everytime a new Renoise song is created, run this

local themes_path = renoise.tool().bundle_path .. "Themes/"
local themes = os.filenames(themes_path, "*.xrnc")
local selected_theme_index = nil
-- Debug print all available themes
--print("Debug: Available themes:")
--for i, theme in ipairs(themes) do
--  print(i .. ": " .. theme)
--end

function pakettiThemeSelectorRenoiseStartFavorites()
  if #preferences.pakettiThemeSelector.FavoritedList <= 1 then
    renoise.app():show_status("You currently have no Favorite Themes set.")
    return
  end
  if #preferences.pakettiThemeSelector.FavoritedList == 2 then
    renoise.app():show_status("You only have 1 favorite, cannot randomize.")
    return
  end

  local current_index = math.random(2, #preferences.pakettiThemeSelector.FavoritedList)
  local random_theme = preferences.pakettiThemeSelector.FavoritedList[current_index]
  print("Randomized Favorite: " .. tostring(random_theme))

  local cleaned_theme_name = tostring(random_theme):match(".*%. (.+)") or tostring(random_theme)
  selected_theme_index = table.find(themes, cleaned_theme_name)

oprint (tostring(random_theme))

renoise.app():load_theme(themes_path .. tostring(random_theme) .. ".xrnc")
renoise.app():show_status("Randomized a theme out of your favorite list. " .. tostring(random_theme))
--[[
  if selected_theme_index then
    local filename = themes[selected_theme_index]

    local full_path = themes_path .. filename
    renoise.app():load_theme(full_path)
    renoise.app():show_status("Randomized a theme out of your favorite list.")
  else
    renoise.app():show_status("Selected theme not found.")
  end
--]]
end

local function pakettiThemeSelectorPickRandomThemeFromAll()
local themes_path = renoise.tool().bundle_path .. "Themes/"
local themes = os.filenames(themes_path, "*.xrnc")
  local new_index = selected_theme_index
  while new_index == selected_theme_index do
    new_index = math.random(#themes - 1) + 1
  end
  selected_theme_index = new_index
  renoise.app():load_theme(themes_path .. themes[selected_theme_index])
  renoise.app():show_status("Picked a random theme from all themes. " .. themes[selected_theme_index])
end





function startup()  
   local s=renoise.song()
   local t=s.transport
     -- renoise.app().window:select_preset(1)
      s.sequencer.keep_sequence_sorted=false
      t.groove_enabled=true
      if preferences.pakettiThemeSelector.RenoiseLaunchRandomLoad.value then 
      pakettiThemeSelectorPickRandomThemeFromAll()
      else if preferences.pakettiThemeSelector.RenoiseLaunchFavoritesLoad.value then
    pakettiThemeSelectorRenoiseStartFavorites()
  
  --  print("Debug: RenoiseLaunchFavoritesLoad is false.")
  end
  end
  
       shuffle_oblique_strategies()
--      renoise.app():show_status("There was a save and the Startup Notifier ran.")
end

if not renoise.tool().app_new_document_observable:has_notifier(startup)   
  then renoise.tool().app_new_document_observable:add_notifier(startup)
  else renoise.tool().app_new_document_observable:remove_notifier(startup) end  
---------
_AUTO_RELOAD_DEBUG = function() startup()
end

-- Debug print  
function dbug(msg)  
 local base_types = {  
 ["nil"]=true, ["boolean"]=true, ["number"]=true,  
 ["string"]=true, ["thread"]=true, ["table"]=true  
 }  
 if not base_types[type(msg)] then oprint(msg)  
 elseif type(msg) == 'table' then rprint(msg)  
 else print(msg) end  
end







