function PakettiLoadDeviceChain(chainName)
renoise.app():load_track_device_chain(chainName) 
end

function PakettiLoadDevicePreset(chainName)
renoise.app():load_track_device_preset(chainName) 
end


renoise.tool():add_keybinding{name="Global:Paketti:Load Device Chain SimpleSend",invoke=function()
PakettiLoadDeviceChain("DeviceChains/SimpleSendMidi.xrnt")
end}

renoise.tool():add_keybinding{name="Global:Paketti:Load Device Chain ClippyClip",invoke=function()
PakettiLoadDevicePreset("DeviceChains/ClippyClip.xrdp")
for i=2,#renoise.song().selected_track.devices do
if renoise.song().selected_track.devices[i].parameters[1].name == "In"
and renoise.song().selected_track.devices[i].parameters[2].name == "Ceiling"
and renoise.song().selected_track.devices[i].parameters[3].name == "8x ovrsmpl"
and renoise.song().selected_track.devices[i].parameters[4].name == "Dry/Wet"
and renoise.song().selected_track.devices[i].parameters[5].name == "Out"
then renoise.song().selected_track.devices[i].display_name="ClippyClip"
end
end
end}

