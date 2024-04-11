function addSampleSlot(amount)
for i=1,amount do
renoise.song().instruments[renoise.song().selected_instrument_index]:insert_sample_at(i)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Add Sample Slot to Instrument", invoke=function() addSampleSlot(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Add 84 Sample Slots to Instrument", invoke=function() addSampleSlot(84) end}


