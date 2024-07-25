local vb=renoise.ViewBuilder()
local dialog
local donations={
  {"2012-02-06","Nate Schmold",76.51,{"3030.ca","https://3030.ca"},{"Ghost Cartridge","https://ghostcartridge.com"},{"YouTube","https://YouTube.com/@3030-tv"}},
  {"2024-04-18","Casiino",17.98,{"Instagram","https://www.instagram.com/elcasiino/"}},
  {"2024-06-30","Zoey Samples",13.43,{"BTD Records","https://linktr.ee/BTD_Records"}},
  {"2024-07-19","Casiino",43.87,{"Instagram","https://www.instagram.com/elcasiino/"}}}

local total_amount=0
for _,donation in ipairs(donations)do total_amount=total_amount+donation[3]end

local function my_keyhandler_func(dialog,key)
  if not(key.modifiers==""and key.name=="exclamation")then return key
  else dialog:close()end
end

local function open_url(url)
  renoise.app():open_url(url)
end

local function pakettiDonationsDialog()
  local dialog_content=vb:column{
    margin=20,
    vb:row{vb:text{text="Date",width=70},vb:text{text="Person",width=100},vb:text{text="Amount",width=50},vb:text{text="Links",width=100}}}

  for _,donation in ipairs(donations)do
    local link_buttons=vb:horizontal_aligner{mode="left"}
    for i=4,6 do
      if donation[i]then
        link_buttons:add_child(vb:button{
          text=donation[i][1],
          notifier=function()open_url(donation[i][2])end
        })
      end
    end

    dialog_content:add_child(vb:row{vb:text{text=donation[1],width=70},vb:text{text=donation[2],width=100},
      vb:text{text=string.format("%.2f",donation[3]).."€",width=50,font='bold'},
      link_buttons
    })
  end
  dialog_content:add_child(vb:space{height=5})
  dialog_content:add_child(vb:text{text="Total: "..string.format("%.2f",total_amount).."€",font='bold'})
  dialog_content:add_child(vb:space{height=20})
  dialog_content:add_child(vb:text{text="Here's how to donate:",font='bold'})
  dialog_content:add_child(vb:horizontal_aligner{
    mode="distribute",
    vb:button{text="PayPal.me",notifier=function()open_url("https://www.paypal.com/donate/?hosted_button_id=PHZ9XDQZ46UR8")end},
    vb:button{text="Ko-fi",notifier=function()open_url("https://ko-fi.com/esaruoho")end},
    vb:button{text="Bandcamp",notifier=function()open_url("http://lackluster.bandcamp.com/")end},
    vb:button{text="GitHub Sponsors",notifier=function()open_url("https://github.com/sponsors/esaruoho")end},
    vb:button{text="Linktr.ee",notifier=function()open_url("https://linktr.ee/esaruoho")end}
    })
  dialog_content:add_child(vb:space{height=20})
  dialog_content:add_child(vb:horizontal_aligner{mode="distribute",
    vb:button{text="OK",notifier=function()dialog:close()end},
    vb:button{text="Cancel",notifier=function()dialog:close()end}})
  dialog=renoise.app():show_custom_dialog("Paketti Donations",dialog_content,my_keyhandler_func)
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:!!About..:__Donate__",invoke=function()pakettiDonationsDialog()end}



renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:!Preferences:Open Paketti Path",invoke=function() renoise.app():open_path(renoise.tool().bundle_path)end}










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
    invoke=function() PakettiShowDeviceListDialog() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Load VST Devices Dialog",invoke=vstShowPluginListDialog}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Load VST3/AU Devices Dialog",invoke=vst3ShowPluginListDialog}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Load LADSPA/DSSI Devices Dialog",invoke=LADSPADSSIShowPluginListDialog}    
    
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

