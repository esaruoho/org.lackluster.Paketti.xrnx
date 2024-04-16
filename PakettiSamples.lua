function addSampleSlot(amount)
for i=1,amount do
renoise.song().instruments[renoise.song().selected_instrument_index]:insert_sample_at(i)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Add Sample Slot to Instrument", invoke=function() addSampleSlot(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Add 84 Sample Slots to Instrument", invoke=function() addSampleSlot(84) end}
-------------------------------------------------------------------------------------------------------------------------------
function LoopState(number)
renoise.song().selected_sample.loop_mode=number
end

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 1 Off",invoke=function() LoopState(1) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 2 Forward",invoke=function() LoopState(2) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 3 Reverse",invoke=function() LoopState(3) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 4 PingPong",invoke=function() LoopState(4) end}

