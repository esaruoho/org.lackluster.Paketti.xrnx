renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:!!About..:!! Donate !!",invoke=function()
renoise.app():open_url("http://paypal.me/esaruoho")
end}


renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:!!About..:Open Paketti Path",invoke=function() renoise.app():open_path(renoise.tool().bundle_path)
 end}








renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Debug:Inspect Plugin",invoke=function() inspectPlugin() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Debug:Inspect Device in Slot 2",invoke=function() inspectEffect() end}

renoise.tool():add_menu_entry{name = "--Main Menu:Tools:Paketti..:Pattern Editor:Random BPM (60-180)",
   invoke = function()
        -- Define a list of possible BPM values
        local bpmList = {80, 100, 115, 123, 128, 132, 135, 138, 160}
        
        -- Get the current BPM
        local currentBPM = renoise.song().transport.bpm
        
        -- Filter the list to exclude the current BPM
        local newBpmList = {}
        for _, bpm in ipairs(bpmList) do
            if bpm ~= currentBPM then
                table.insert(newBpmList, bpm)
            end
        end

        -- Select a random BPM from the filtered list
        if #newBpmList > 0 then
            local selectedBPM = newBpmList[math.random(#newBpmList)]
            renoise.song().transport.bpm = selectedBPM
            print("Random BPM set to: " .. selectedBPM) -- Debug output to the console
        else
            print("No alternative BPM available to switch to.")
        end

        -- Optional: write the BPM to a file or apply other logic
        if renoise.tool().preferences.RandomBPM and renoise.tool().preferences.RandomBPM.value then
            write_bpm() -- Ensure this function is defined elsewhere in your tool
            print("BPM written to file or handled additionally.")
        end
    end
}

--renoise.song().transport.bpm=math.random(60,180) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Write Current BPM&LPB to Master column",invoke=function() write_bpm() end}








renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Pattern Editor:Effect Column CheatSheet Dialog", invoke=function() CheatSheet() end}

-------- Plugins/Devices
-- Adding menu entries for listing available plugins by type
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Load Native Devices Dialog",
    invoke=function() show_plugin_list_dialog() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Load VST Devices Dialog",invoke=vstShowPluginListDialog}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Load VST3/AU Devices Dialog",invoke=vst3ShowPluginListDialog}
    
    
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Debug:List Available VST Plugins",
    invoke=function() listByPluginType("VST") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Debug:List Available AU Plugins",
    invoke=function() listByPluginType("AU") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Debug:List Available VST3 Plugins",
    invoke=function() listByPluginType("VST3") end}
-- Adding menu entries for listing available devices (effects) by type
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Debug:List Available VST Effects",
    invoke=function() listDevicesByType("VST") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Debug:List Available AU Effects",
    invoke=function() listDevicesByType("AU") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Debug:List Available VST3 Effects",
    invoke=function() listDevicesByType("VST3") end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Debug:Dump VST/VST3/AU/Native Effects to Console", invoke=function() 
local devices=renoise.song().tracks[renoise.song().selected_track_index].available_devices
  for key, value in ipairs (devices) do 
    print(key, value)
  end
end}
renoise.tool():add_menu_entry{name="---Main Menu:Tools:Paketti..:Plugins/Devices:Debug:Available Routings for Track",invoke=function() showAvailableRoutings() end}

-- Function to create and show the dialog with a text field.
function squigglerdialog()
  local vb = renoise.ViewBuilder()
  local content = vb:column {
    margin = 10,
    vb:textfield {
      value = "∿",
      edit_mode = true
    }
  }
  
  -- Using a local variable for 'dialog' to limit its scope to this function.
  local dialog = renoise.app():show_custom_dialog("Copy the Squiggler to your clipboard", content)
end

renoise.tool():add_keybinding{name="Global:Paketti:∿ Squiggly Sinewave to Clipboard (macOS)", invoke=function() squigglerdialog() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:∿ Squiggly Sinewave to Clipboard", invoke=function() squigglerdialog() end}

