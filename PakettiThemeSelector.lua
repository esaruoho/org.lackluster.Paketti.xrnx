local dialog
local custom_dialog
local os_name = os.platform()
local preferences = renoise.tool().preferences
local temporary_selected_theme
local selected_theme_index
local themes_path = renoise.tool().bundle_path .. "Themes/"
local themes = os.filenames(themes_path, "*.xrnc")

-- Ensure FavoritedList is properly initialized
if not preferences.pakettiThemeSelector:property("FavoritedList") then
  preferences.pakettiThemeSelector:define_property("FavoritedList", renoise.Document { Favorited = renoise.Document.ObservableStringList { "<No Theme Selected>" } })
end

if preferences.pakettiThemeSelector.PreviousSelectedTheme == nil then
  preferences.pakettiThemeSelector.PreviousSelectedTheme = ""
end

if preferences.pakettiThemeSelector.RenoiseLaunchFavoritesLoad == nil then
  preferences.pakettiThemeSelector.RenoiseLaunchFavoritesLoad = false
end

if #themes == 0 then
  renoise.app():show_status("No themes found in Themes folder.")
  return
end

for i, theme in ipairs(themes) do
  themes[i] = theme:gsub("%.xrnc$", "")
end
table.sort(themes, function(a, b) return a:lower() < b:lower() end)
for i, theme in ipairs(themes) do
  themes[i] = string.format("%03d. %s", i, theme)
end
table.insert(themes, 1, "<No Theme Selected>")

local function save_preferences()
  preferences:save_as("preferences.xml")
end

local function pakettiThemeSelectorUpdateLoadTheme(theme_name)
  if theme_name == "<No Theme Selected>" then
    renoise.app():show_status("No theme selected.")
    return
  end
  local theme_path = themes_path .. theme_name:match("%d%d%d%. (.+)") .. ".xrnc"
  print("Loading theme: " .. theme_path)
  renoise.app():load_theme(theme_path)
  renoise.app():show_status("Loaded theme: " .. theme_name)
  temporary_selected_theme = theme_name
  print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
end

local function pakettiThemeSelectorOpenThemesPath()
  local command
  if os_name == "WINDOWS" then command = 'start "" "' .. themes_path .. '"'
  elseif os_name == "MACINTOSH" then command = 'open "' .. themes_path .. '"'
  else command = 'xdg-open "' .. themes_path .. '"' end
  print("Executing command: " .. command)
  os.execute(command)
end

local function pakettiThemeSelectorRefreshThemes(vb)
  themes = os.filenames(themes_path, "*.xrnc")
  for i, theme in ipairs(themes) do themes[i] = theme:gsub("%.xrnc$", "") end
  table.sort(themes, function(a, b) return a:lower() < b:lower() end)
  for i, theme in ipairs(themes) do themes[i] = string.format("%03d. %s", i, theme) end
  table.insert(themes, 1, "<No Theme Selected>")
  vb.views["themes_popup"].items = themes
  vb.views["themes_popup"].value = 1 -- Initialize the dropdown to "<No Theme Selected>"
  vb.views["themes_count"].text = "Select Theme (" .. tostring(#themes - 1) .. ")"  -- Exclude "<No Theme Selected>"
end

local function pakettiThemeSelectorUpdateKeyHandler(dialog, key)
  if key.name == "esc" then return end
end

local function pakettiThemeSelectorDialogClose(vb)
  if custom_dialog and custom_dialog.visible then
    if temporary_selected_theme then
      print("Setting preference to temporary_selected_theme: " .. temporary_selected_theme)
      preferences.pakettiThemeSelector.PreviousSelectedTheme.value = temporary_selected_theme
      vb.views["previous_theme"].text = temporary_selected_theme  -- Update UI
    end
    custom_dialog:close()
    save_preferences()
    -- Save the checkbox state
    if vb.views["launch_random_checkbox"] then
      preferences.pakettiThemeSelector.RenoiseLaunchFavoritesLoad.value = vb.views["launch_random_checkbox"].value
      save_preferences()
    end
    -- Debug Information
    local favorited_list_table = {}
    for i = 1, #preferences.pakettiThemeSelector.FavoritedList do
      table.insert(favorited_list_table, tostring(preferences.pakettiThemeSelector.FavoritedList[i]))
    end
    print("Preferences Debug (Closing Dialog):")
    print("PreviousSelectedTheme: " .. tostring(preferences.pakettiThemeSelector.PreviousSelectedTheme.value))
    print("FavoritedList: " .. table.concat(favorited_list_table, ", "))
    print("RenoiseLaunchFavoritesLoad: " .. tostring(preferences.pakettiThemeSelector.RenoiseLaunchFavoritesLoad.value))
  end
end

local function print_favorites_list()
  print("Current Favorites List:")
  for i = 1, #preferences.pakettiThemeSelector.FavoritedList do
    local theme = tostring(preferences.pakettiThemeSelector.FavoritedList[i])
    print(i .. ". " .. theme)
  end
end

local function pakettiThemeSelectorAddFavorite(theme_name)
  local favorited_list = preferences.pakettiThemeSelector.FavoritedList
  local found = false
  for i = 1, #favorited_list do
    if tostring(favorited_list[i]) == theme_name then
      found = true
      break
    end
  end

  if not found then
    favorited_list:insert(#favorited_list + 1, theme_name)
    print("Added as favorite: " .. theme_name)
    save_preferences()
  else
    print("Theme already in favorites: " .. theme_name)
    renoise.app():show_status("Theme (" .. theme_name .. ") is already in your Favorites")
  end
end

local function pakettiThemeSelectorRemoveFavorite(vb, index)
  local favorited_list = preferences.pakettiThemeSelector.FavoritedList
  if index == 1 then
    renoise.app():show_status("<No Theme Selected> cannot be removed.")
    return
  end
  if index > 1 and index <= #favorited_list then
    local removed_theme = tostring(favorited_list[index])
    favorited_list:remove(index)
    print("Removed Favorite: " .. removed_theme)
    save_preferences()
    pakettiThemeSelectorUpdateFavoritesDropdown(vb)
    -- Update the theme selection
    if #favorited_list > 1 then
      local new_index = math.min(index, #favorited_list)
      vb.views["favorites_popup"].value = new_index
      local theme_name = tostring(preferences.pakettiThemeSelector.FavoritedList[new_index])
      selected_theme_index = table.find(themes, theme_name:gsub("%.xrnc$", ""))
      pakettiThemeSelectorUpdateLoadTheme(themes[selected_theme_index])
    else
      vb.views["favorites_popup"].value = 1
      pakettiThemeSelectorUpdateLoadTheme("<No Theme Selected>")
    end
  else
    print("Invalid index for removal")
  end
end

local function pakettiThemeSelectorRandomizeFavorites(vb)
  if not vb.views["favorites_popup"] then return end  -- Check if favorites_popup exists
  if #preferences.pakettiThemeSelector.FavoritedList <= 1 then
    renoise.app():show_status("You currently have no Favorite Themes set.")
    return
  end
  if #preferences.pakettiThemeSelector.FavoritedList == 2 then
    renoise.app():show_status("You only have 1 favorite, cannot randomize.")
    return
  end
  local current_index = vb.views["favorites_popup"].value or 2
  local new_index = current_index
  while new_index == current_index do 
    new_index = math.random(2, #preferences.pakettiThemeSelector.FavoritedList) 
  end
  vb.views["favorites_popup"].value = new_index
  local random_theme = preferences.pakettiThemeSelector.FavoritedList[new_index]
  print("Randomized Favorite: " .. tostring(random_theme))
  local theme_name = tostring(random_theme)  -- Convert ObservableString to string
  selected_theme_index = table.find(themes, theme_name:gsub("%.xrnc$", ""))
  pakettiThemeSelectorUpdateLoadTheme(themes[selected_theme_index])
  print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
end

local function save_favorites()
  if #preferences.pakettiThemeSelector.FavoritedList <= 1 then
    renoise.app():show_status("There are no Favorites to be saved")
    return
  end

  local file_path = renoise.app():prompt_for_filename_to_write("xml", "Save Favorites")
  if not file_path then
    renoise.app():show_status("No filename was selected, did not save Paketti Theme Selector Favorites")
    return
  end

  local file = io.open(file_path, "w")
  if not file then
    renoise.app():show_status("Failed to open file for writing.")
    return
  end

  file:write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  file:write("<FavoritedList>\n")
  file:write("  <Favorited/>\n")  -- Add the empty Favorited entry
  for i = 2, #preferences.pakettiThemeSelector.FavoritedList do  -- Start from 2 to skip "<No Theme Selected>"
    local theme = tostring(preferences.pakettiThemeSelector.FavoritedList[i])
    if theme ~= "" then
      file:write("  <Favorited>"..theme.."</Favorited>\n")
    end
  end
  file:write("</FavoritedList>\n")
  file:close()
  renoise.app():show_status("Favorites saved to "..file_path)
end

local function load_favorites(vb)
  local file_path = renoise.app():prompt_for_filename_to_read({"xml"}, "Load Favorites")
  if not file_path then
    renoise.app():show_status("No filename was selected, did not load Paketti Theme Selector Favorites")
    return
  end

  local file = io.open(file_path, "r")
  if not file then
    renoise.app():show_status("Failed to open the selected file.")
    return
  end

  local content = file:read("*all")
  file:close()

  -- Debug print: Starting to parse XML file
  print("Starting to parse selected XML file")
  print(content)

  -- Clear existing favorites manually
  local favorited_list = preferences.pakettiThemeSelector.FavoritedList
  while #favorited_list > 0 do
    favorited_list:remove(#favorited_list)
  end

  -- Add "<No Theme Selected>" back
  favorited_list:insert(1, "<No Theme Selected>")

  -- Manually parse the XML content and add each favorite
  local index = 2
  for theme in content:gmatch("<Favorited>(.-)</Favorited>") do
    print("Loading favorite: " .. theme)
    favorited_list:insert(index, theme)
    index = index + 1
  end

  print("Loaded Favorites List:")
  for i = 1, #preferences.pakettiThemeSelector.FavoritedList do
    print(preferences.pakettiThemeSelector.FavoritedList[i])
  end

  pakettiThemeSelectorUpdateFavoritesDropdown(vb)
  save_preferences()

  print("Final FavoritedList in Preferences:")
  for i = 1, #preferences.pakettiThemeSelector.FavoritedList do
    print(preferences.pakettiThemeSelector.FavoritedList[i])
  end

  renoise.app():show_status("Successfully loaded Favorites")
end

-- Function to update the favorites dropdown in the UI
function pakettiThemeSelectorUpdateFavoritesDropdown(vb)
  local items = {"<No Theme Selected>"}
  for i = 2, #preferences.pakettiThemeSelector.FavoritedList do
    local theme = tostring(preferences.pakettiThemeSelector.FavoritedList[i])
    table.insert(items, theme)  -- Add theme to the list without any modifications
  end
  vb.views["favorites_popup"].items = items
  vb.views["favorites_count"].text = "Favorites (" .. tostring(#preferences.pakettiThemeSelector.FavoritedList - 1) .. ")"  -- Exclude "<No Theme Selected>"
end

-- Function to save preferences
function save_preferences()
  renoise.tool().preferences:save_as("preferences.xml")
end

local function pakettiThemeSelectorPickRandomThemeFromAll()
  local new_index = selected_theme_index
  while new_index == selected_theme_index do
    new_index = math.random(#themes - 1) + 1
  end
  selected_theme_index = new_index
  pakettiThemeSelectorUpdateLoadTheme(themes[selected_theme_index])
  print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
  renoise.app():show_status("Picked a random theme from all themes.")
end

local function pakettiThemeSelectorPickRandomThemeFromFavorites(vb)
  pakettiThemeSelectorRandomizeFavorites(vb)
end

local function pakettiThemeSelectorLoadNextFavoriteTheme(vb)
  local current_index = vb.views["favorites_popup"].value
  if current_index < #preferences.pakettiThemeSelector.FavoritedList then
    current_index = current_index + 1
  else
    current_index = 2
  end
  vb.views["favorites_popup"].value = current_index
  local theme_name = tostring(preferences.pakettiThemeSelector.FavoritedList[current_index])
  selected_theme_index = table.find(themes, theme_name:gsub("%.xrnc$", ""))
  pakettiThemeSelectorUpdateLoadTheme(themes[selected_theme_index])
  print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
end

local function pakettiThemeSelectorLoadPreviousFavoriteTheme(vb)
  local current_index = vb.views["favorites_popup"].value
  if current_index > 2 then
    current_index = current_index - 1
  else
    current_index = #preferences.pakettiThemeSelector.FavoritedList
  end
  vb.views["favorites_popup"].value = current_index
  local theme_name = tostring(preferences.pakettiThemeSelector.FavoritedList[current_index])
  selected_theme_index = table.find(themes, theme_name:gsub("%.xrnc$", ""))
  pakettiThemeSelectorUpdateLoadTheme(themes[selected_theme_index])
  print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
end

local function pakettiThemeSelectorDialogOpen(vb)
  print("Dialog Opened - PreviousSelectedTheme: " .. tostring(preferences.pakettiThemeSelector.PreviousSelectedTheme.value))
  selected_theme_index = 1 -- Initialize to "<No Theme Selected>"
  return vb:row { style = "panel", margin = 10,
    vb:column {
      vb:row { vb:text { id = "themes_count", text = "Select Theme (" .. tostring(#themes - 1) .. ")", font = "bold" } },  -- Exclude "<No Theme Selected>"
      vb:row {
        vb:popup { id = "themes_popup", items = themes, value = selected_theme_index, width = 300, notifier = function(index)
          selected_theme_index = index
          local theme_name = themes[selected_theme_index]
          pakettiThemeSelectorUpdateLoadTheme(theme_name)
        end },
        vb:button { text = "-", notifier = function()
          selected_theme_index = (selected_theme_index - 2) % #themes + 1
          if selected_theme_index == 1 then selected_theme_index = #themes end
          vb.views["themes_popup"].value = selected_theme_index
          local theme_name = themes[selected_theme_index]
          pakettiThemeSelectorUpdateLoadTheme(theme_name)
          print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
        end },
        vb:button { text = "+", notifier = function()
          selected_theme_index = selected_theme_index % #themes + 1
          if selected_theme_index == 1 then selected_theme_index = 2 end
          vb.views["themes_popup"].value = selected_theme_index
          local theme_name = themes[selected_theme_index]
          pakettiThemeSelectorUpdateLoadTheme(theme_name)
          print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
        end },
        vb:button { text = "Randomize", notifier = function()
          local new_index = selected_theme_index
          while new_index == selected_theme_index do new_index = math.random(#themes - 1) + 1 end
          selected_theme_index = new_index
          vb.views["themes_popup"].value = selected_theme_index
          local theme_name = themes[selected_theme_index]
          pakettiThemeSelectorUpdateLoadTheme(theme_name)
          print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
          renoise.app():show_status("Picked a random theme at random.")
        end },
        vb:button { text = "Add as Favorite", notifier = function()
          local theme_name = themes[selected_theme_index] .. ".xrnc"
          print("Attempting to add " .. theme_name .. " to Favorites list.")
          print_favorites_list()
          renoise.app():show_status("Added (" .. theme_name .. ") to Favorites list.")
          if theme_name ~= "<No Theme Selected>.xrnc" then
            pakettiThemeSelectorAddFavorite(theme_name)
            pakettiThemeSelectorUpdateFavoritesDropdown(vb)
            print("Updated Favorites List:")
            print_favorites_list()
          end
        end }
      },
      vb:row { vb:text { text = "Previously Loaded Theme", font = "bold" } },
      vb:row {
        vb:text { id = "previous_theme", text = tostring(preferences.pakettiThemeSelector.PreviousSelectedTheme.value) ~= "" and tostring(preferences.pakettiThemeSelector.PreviousSelectedTheme.value) or "<None>" },
        vb:button { text = "Load Previous Theme", notifier = function()
          local prev_theme = tostring(preferences.pakettiThemeSelector.PreviousSelectedTheme.value)
          if prev_theme ~= "" and prev_theme ~= "<None>" then
            local theme_path = themes_path .. prev_theme:match("%d%d%d%. (.+)") .. ".xrnc"
            print("Loading theme: " .. theme_path)
            renoise.app():load_theme(theme_path)
            renoise.app():show_status("Loaded Previous Theme: " .. prev_theme)
          else
            renoise.app():show_status("There was no previous theme saved, please select a theme and close the dialog and reopen the dialog.")
          end
        end }
      },
      vb:row { vb:text { id = "favorites_count", text = "Favorites (" .. tostring(#preferences.pakettiThemeSelector.FavoritedList - 1) .. ")", font = "bold" } },  -- Exclude "<No Theme Selected>"
      vb:row {
        vb:button { text = "Load Favorites", notifier = function() load_favorites(vb) end },
        vb:button { text = "Save Favorites", notifier = function() save_favorites() end }
      },
      vb:row {
        vb:popup { id = "favorites_popup", items = {"<No Theme Selected>"}, width = 300, notifier = function(index)
          if index > 1 then
            local theme_name = tostring(preferences.pakettiThemeSelector.FavoritedList[index])
            selected_theme_index = table.find(themes, theme_name:gsub("%.xrnc$", ""))
            pakettiThemeSelectorUpdateLoadTheme(themes[selected_theme_index])
            print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
          end
        end },
        vb:row {
          vb:button { text = "-", notifier = function()
            local current_index = vb.views["favorites_popup"].value
            if current_index > 2 then current_index = current_index - 1 else current_index = #preferences.pakettiThemeSelector.FavoritedList end
            vb.views["favorites_popup"].value = current_index
            local theme_name = tostring(preferences.pakettiThemeSelector.FavoritedList[current_index])
            selected_theme_index = table.find(themes, theme_name:gsub("%.xrnc$", ""))
            pakettiThemeSelectorUpdateLoadTheme(theme_name)
            print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
          end },
          vb:button { text = "+", notifier = function()
            local current_index = vb.views["favorites_popup"].value
            if current_index < #preferences.pakettiThemeSelector.FavoritedList then current_index = current_index + 1 else current_index = 2 end
            vb.views["favorites_popup"].value = current_index
            local theme_name = tostring(preferences.pakettiThemeSelector.FavoritedList[current_index])
            selected_theme_index = table.find(themes, theme_name:gsub("%.xrnc$", ""))
            pakettiThemeSelectorUpdateLoadTheme(theme_name)
            print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
          end },
          vb:button { text = "Randomize", notifier = function()
            if #preferences.pakettiThemeSelector.FavoritedList <= 1 then
              renoise.app():show_status("You currently have no Favorite Themes set.")
              return
            end
            if #preferences.pakettiThemeSelector.FavoritedList == 2 then
              renoise.app():show_status("You only have 1 favorite, cannot randomize.")
              return
            end
            local current_index = vb.views["favorites_popup"] and vb.views["favorites_popup"].value or 2
            local new_index = current_index
            while new_index == current_index do new_index = math.random(2, #preferences.pakettiThemeSelector.FavoritedList) end
            vb.views["favorites_popup"].value = new_index
            local random_theme = preferences.pakettiThemeSelector.FavoritedList[new_index]
            print("Randomized Favorite: " .. tostring(random_theme))
            local theme_name = tostring(random_theme)
            selected_theme_index = table.find(themes, theme_name:gsub("%.xrnc$", ""))
            pakettiThemeSelectorUpdateLoadTheme(themes[selected_theme_index])
            temporary_selected_theme = theme_name
            print("Your Temporary Selected Theme has been set to: " .. temporary_selected_theme)
          end },
          vb:button { text = "Remove Favorite", notifier = function()
            local current_index = vb.views["favorites_popup"].value
            if current_index > 1 and current_index <= #preferences.pakettiThemeSelector.FavoritedList then
              pakettiThemeSelectorRemoveFavorite(vb, current_index)
              print("Updated Favorites List:")
              print_favorites_list()
            else
              renoise.app():show_status("There are no Favorites to be removed.")
            end
          end }
        }
      },
      vb:row { vb:text { text = "Paketti Theme Selector Settings", font = "bold" } },
      vb:row {
        vb:button { text = "Open Themes Path", notifier = pakettiThemeSelectorOpenThemesPath },
        vb:button { text = "Refresh", notifier = function() pakettiThemeSelectorRefreshThemes(vb) end }
      },
      vb:row {
        vb:checkbox {
          id = "launch_random_checkbox",
          value = preferences.pakettiThemeSelector.RenoiseLaunchFavoritesLoad.value,  -- Correctly initialize the checkbox value
          notifier = function(value)
            preferences.pakettiThemeSelector.RenoiseLaunchFavoritesLoad.value = value
            save_preferences()
          end
        },
        vb:text { text = "On Renoise Launch, Randomize Favorite Theme" }
      },
      vb:row {
        vb:button {
          text = "Close",
          notifier = function() pakettiThemeSelectorDialogClose(vb) end
        }
      }
    }
  }
end

local function pakettiThemeSelectorDialogShow()
  if custom_dialog and custom_dialog.visible then
    return -- Prevent opening the dialog multiple times
  end
  local vb = renoise.ViewBuilder()
  custom_dialog = renoise.app():show_custom_dialog("Paketti Theme Selector", pakettiThemeSelectorDialogOpen(vb), pakettiThemeSelectorUpdateKeyHandler)
  pakettiThemeSelectorUpdateFavoritesDropdown(vb)
  print("Dialog Show - PreviousSelectedTheme: " .. tostring(preferences.pakettiThemeSelector.PreviousSelectedTheme.value))
end

renoise.tool():add_menu_entry { name = "Main Menu:Tools:Paketti..:Paketti Theme Selector", invoke = pakettiThemeSelectorDialogShow }

function pakettiThemeSelectorPickRandomThemeFromFavoritesNoGUI()
local themes_path = renoise.tool().bundle_path .. "Themes/"
local themes = os.filenames(themes_path, "*.xrnc")
local selected_theme_index = nil

  if #preferences.pakettiThemeSelector.FavoritedList <= 1 then
    renoise.app():show_status("You currently have no Favorite Themes set.")
    print("Debug: No Favorite Themes set.")
    return
  end
  if #preferences.pakettiThemeSelector.FavoritedList == 2 then
    renoise.app():show_status("You only have 1 favorite, cannot randomize.")
    print("Debug: Only one favorite, cannot randomize.")
    return
  end

  print("Debug: Starting theme randomization process.")
  local current_index = math.random(2, #preferences.pakettiThemeSelector.FavoritedList)
  local random_theme = preferences.pakettiThemeSelector.FavoritedList[current_index]
  print("Randomized Favorite: " .. tostring(random_theme))

  local cleaned_theme_name = tostring(random_theme):match(".*%. (.+)") or tostring(random_theme)
  print("Debug: Cleaned theme name: " .. cleaned_theme_name)

  selected_theme_index = table.find(themes, cleaned_theme_name)
  print("Debug: Selected theme index: " .. tostring(selected_theme_index))

  if selected_theme_index then
    local filename = themes[selected_theme_index]
    print("Debug: Found theme filename: " .. filename)

    local full_path = themes_path .. filename
    print("Loading theme: " .. full_path)
    renoise.app():load_theme(full_path)
    renoise.app():show_status("Randomized a theme out of your favorite list.")
  else
    renoise.app():show_status("Selected theme not found.")
    print("Debug: Selected theme not found.")
  end
end



-- Key bindings
renoise.tool():add_keybinding { name = "Global:Paketti Theme Selector:Open Paketti Theme Selector Dialog", invoke = function() pakettiThemeSelectorDialogShow() end }
renoise.tool():add_keybinding { name = "Global:Paketti Theme Selector:Pick a Random Theme (All)", invoke = function() pakettiThemeSelectorPickRandomThemeFromAll() end }
renoise.tool():add_keybinding { name = "Global:Paketti Theme Selector:Pick a Random Theme (Favorites)", invoke = function() 
    local vb = renoise.ViewBuilder()
    pakettiThemeSelectorPickRandomThemeFromFavoritesNoGUI() 
end }
--[[
renoise.tool():add_keybinding { name = "Global:Paketti Theme Selector:Load Favorite Theme (Next)", invoke = function() local vb = renoise.ViewBuilder()
    pakettiThemeSelectorLoadNextFavoriteTheme(vb) 
end }
renoise.tool():add_keybinding { name = "Global:Paketti Theme Selector:Load Favorite Theme (Previous)", invoke = function() 
    local vb = renoise.ViewBuilder()
    pakettiThemeSelectorLoadPreviousFavoriteTheme(vb) 
end }
--]]

