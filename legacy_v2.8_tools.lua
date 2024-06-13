--EZMaximizeSpectrum
--December 15, 2011, Renoise 2.8 only
--esaruoho
function EZMaximizeSpectrum()
local s=renoise.song()
local t=s.transport
local w=renoise.app().window
  if t.playing==false then
     t.playing=true end

w.disk_browser_is_expanded=true
w.active_upper_frame=4
w.upper_frame_is_visible=true
w.lower_frame_is_visible=false
renoise.app():show_status("Current BPM: " .. t.bpm .. " Current LPB: " .. t.lpb .. ". You are feeling fine. Playback started.")
end

renoise.tool():add_keybinding{name="Global:Paketti:EZ Maximize Spectrum",invoke=function() EZMaximizeSpectrum() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:EZ Maximize Spectrum",invoke=function() EZMaximizeSpectrum() end}
renoise.tool():add_menu_entry{name="Mixer:EZ Maximize Spectrum",invoke=function() EZMaximizeSpectrum() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:EZ Maximize Spectrum",invoke=function() EZMaximizeSpectrum() end}


renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Reverb", invoke=function() loadvst("Audio/Effects/AU/aumf:676v:TOGU") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Chorus", invoke=function() loadvst("Audio/Effects/AU/aufx:Chor:Togu") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Ultra Simple EQ", invoke=function() loadvst("Audio/Effects/AU/aufx:TILT:Togu") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Dub-Delay I", invoke=function() loadvst("Audio/Effects/AU/aumf:aumf:Togu") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Dub-Delay II", invoke=function() loadvst("Audio/Effects/AU/aumf:dub2:Togu") end}
renoise.tool():add_keybinding{name="Global:Track Devices:Load TOGU Audioline Dub-Delay III",invoke=function() loadvst("Audio/Effects/AU/aumf:xg70:TOGU") end}

