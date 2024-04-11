renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Random BPM (60-180)",invoke=function()
renoise.song().transport.bpm=math.random(60,180) end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Write Current BPM&LPB to Master column",invoke=function() write_bpm() end}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Bypass All Devices on Channel", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Enable All Devices on Channel", invoke=function() effectenable() end}
renoise.tool():add_menu_entry{name="---Main Menu:Tools:Paketti..:Available Routings for Track",invoke=function() showAvailableRoutings() end}


renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Effect Column CheatSheet", invoke=function() CheatSheet() end}



-------- Plugins/Devices
-- Adding menu entries for listing available plugins by type
renoise.tool():add_menu_entry {
    name = "--Main Menu:Tools:Paketti..:Plugins/Devices:Load Native Devices Dialog",
    invoke = function() show_plugin_list_dialog() end}

renoise.tool():add_menu_entry {
    name = "--Main Menu:Tools:Paketti..:Plugins/Devices:List Available VST Plugins",
    invoke = function() listByPluginType("VST") end
}
renoise.tool():add_menu_entry {
    name = "Main Menu:Tools:Paketti..:Plugins/Devices:List Available AU Plugins",
    invoke = function() listByPluginType("AU") end
}
renoise.tool():add_menu_entry {
    name = "Main Menu:Tools:Paketti..:Plugins/Devices:List Available VST3 Plugins",
    invoke = function() listByPluginType("VST3") end
}
-- Adding menu entries for listing available devices (effects) by type
renoise.tool():add_menu_entry {
    name = "Main Menu:Tools:Paketti..:Plugins/Devices:List Available VST Effects",
    invoke = function() listDevicesByType("VST") end
}
renoise.tool():add_menu_entry {
    name = "Main Menu:Tools:Paketti..:Plugins/Devices:List Available AU Effects",
    invoke = function() listDevicesByType("AU") end
}
renoise.tool():add_menu_entry {
    name = "Main Menu:Tools:Paketti..:Plugins/Devices:List Available VST3 Effects",
    invoke = function() listDevicesByType("VST3") end
}
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Plugins/Devices:Dump VST/VST3/AU/Native Effects to Console", invoke=function() 
local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices
  for key, value in ipairs (devices) do 
    print(key, value)
  end
end}



