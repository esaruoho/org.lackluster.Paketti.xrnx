function PakettiLoadDeviceChain(chainName)
renoise.app():load_track_device_chain(chainName) 
end

renoise.tool():add_keybinding{name="Global:Paketti:Load Device Chain SimpleSend",invoke=function()
PakettiLoadDeviceChain("DeviceChains/SimpleSendMidi.xrnt")
end}

