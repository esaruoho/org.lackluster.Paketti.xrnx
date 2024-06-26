-- Show or hide Pattern Matrix
function showhidepatternmatrix()
  if renoise.app().window.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    then renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR 
    renoise.app().window.pattern_matrix_is_visible = true
    return
  end
  if renoise.app().window.pattern_matrix_is_visible == true
    then renoise.app().window.pattern_matrix_is_visible = false
    else renoise.app().window.pattern_matrix_is_visible = true
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Show/Hide Pattern Matrix",invoke=function() showhidepatternmatrix() end}
renoise.tool():add_menu_entry{name="--Pattern Matrix:Paketti..:Switch to Automation",invoke=function() showAutomation() end}
renoise.tool():add_menu_entry{name="--Pattern Matrix:Paketti..:Bypass EFX (Write to Pattern)", invoke=function() effectbypasspattern()  end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Enable EFX (Write to Pattern)", invoke=function() effectenablepattern() end}
renoise.tool():add_menu_entry{name="--Pattern Matrix:Paketti..:Bypass All Devices on Channel", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Enable All Devices on Channel", invoke=function() effectenable() end}
renoise.tool():add_menu_entry{name="--Pattern Matrix:Paketti..:Play at 75% Speed (Song BPM)", invoke=function() playat75() end}
renoise.tool():add_menu_entry{name="Pattern Matrix:Paketti..:Play at 100% Speed (Song BPM)", invoke=function() returnbackto100()  end}

