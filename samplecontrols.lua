function selectedSampleTranspose(amount)
local currentSampleTranspose = renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].transpose
local changedSampleTranspose = currentSampleTranspose + amount
if changedSampleTranspose > 120 then changedSampleTranspose = 120
else if changedSampleTranspose < -120 then changedSampleTranspose = -120 end end
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].transpose=changedSampleTranspose
end

renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose -1",invoke=function() selectedSampleTranspose(-1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose +1",invoke=function() selectedSampleTranspose(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose -12",invoke=function() selectedSampleTranspose(-12) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose +12",invoke=function() selectedSampleTranspose(12) end}
renoise.tool():add_keybinding{name="Global:Paketti:Selected Sample Transpose 0",invoke=function() selectedSampleTranspose(0) end}

