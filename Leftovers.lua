function savesamplestosmartfolder()
local s=renoise.song()
--local additionalname=os.clock
for i = 1, #renoise.song().instruments do
--instruments[i].samples[1]
renoise.app():show_status("Saving")
  s.instruments[i].samples[1].sample_buffer:save_as(path .. path2 .. i .. ".wav", "wav")
os.execute("sox " .. path .. path2 .. i .. " -b 24 " .. path .. path2 .. i .. i .. ".wav")

--os.execute("open -a Logic\ Pro.app /Users/esaruoho/Music/Logic/abs4/abs4/abs4.logic")
end
renoise.app():show_status("32Bit to 24Bit Conversion From Tmp-folder to Logic Smart Folder Done")
os.execute("cd /Users/esaruoho/Music/samples/LogicSmartFolder;open .") end

renoise.tool():add_keybinding {name = "Global:Paketti:Save Samples to Smart Folder", invoke=function() savesamplestosmartfolder() end}
---------------------------------------------------------------------------------------------------------
-- :::::Automation ExpCurve
function drawVol()
local pos = renoise.song().transport.edit_pos
local pos1 = renoise.song().transport.edit_pos
local edit = renoise.song().transport.edit_mode
local length = renoise.song().selected_pattern.number_of_lines
local curve = 1.105
loadnative("Audio/Effects/Native/Gainer")
renoise.song().selected_track.devices[2].is_maximized=false
for i=1, length do
renoise.song().transport.edit_mode = true
pos.line = i
renoise.song().transport.edit_pos = pos
renoise.song().selected_track.devices[2].parameters[1]:record_value(math.pow(curve, i) / math.pow(curve, length))
end

renoise.song().transport.edit_mode = edit
renoise.song().transport.edit_pos = pos1
end
renoise.tool():add_keybinding {name = "Global:Paketti:ExpCurveVol", invoke=function() drawVol() end}
renoise.tool():add_menu_entry {name = "Pattern Editor:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
renoise.tool():add_menu_entry {name = "Pattern Matrix:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
--renoise.tool():add_keybinding {name = "Global:Paketti:ExpCurveVol", invoke=function() drawVol() end}

-- Track Automation
renoise.tool():add_menu_entry {name="Track Automation:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
renoise.tool():add_menu_entry {name="Track Automation List:Paketti..:ExpCurveVol", invoke=function() drawVol() end}
---------------------------
require "FormulaDeviceManual"

renoise.tool():add_keybinding {name = "Global:Paketti:FormulaDevice", invoke=function()  
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().tracks[renoise.song().selected_track_index]:insert_device_at("Audio/Effects/Native/*Formula", 2)  
local infile = io.open( "FormulaDeviceXML.txt", "rb" )
local indata = infile:read( "*all" )
renoise.song().tracks[renoise.song().selected_track_index].devices[2].active_preset_data = indata
infile:close()

show_manual (
    "Formula Device Documentation", -- manual dialog title
    "FormulaDevice.txt" -- the textfile which contains the manual
  )
end}
