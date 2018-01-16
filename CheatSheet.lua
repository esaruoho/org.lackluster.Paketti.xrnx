function CheatSheet()
local vb=renoise.ViewBuilder()


local arp="0Axy - Arpeggio (x=base note offset1, y=base noteoffset 2) *"
local pup="0Uxx - Pitch Slide up (00-FF) *"
local pdn="0Dxx - Pitch Slide down (00-FF) *"
local chv="0Mxx - Set Channel volume (00-FF)"
local vls="0Cxy - Volume slicer -- x=factor (0=0.0, F=1.0), slice at tick y. *"
local gli="0Gxx - Glide to note with step xx (00-FF)*" 
local vup="0Ixx - Volume Slide Up with step xx (0064) (64x0601 or 2x0632 = slide0-full) *"
local vdn="0Oxx - Volume Slide Down with step xx (0064) *"
local pan="0Pxx - Set Panning (00-FF) (00: left; 80: center; FF: right)"
local off="0Sxx - Trigger Sample Offset, 00 is sample start, FF is sample end. *"
local sur="0Wxx - Surround Width (00-FF) *"
local rev="0Bxx - Play Sample Backwards (B00) or forwards again (B01) *"
local trv="0Lxx - Set track-Volume (00-FF)"
local del="0Qxx - Delay notes in track-row xx ticks before playing. (00-speed)"
local ret="0Rxy - Retrig notes in track-row every xy ticks (x=volume; y=ticks 0 - speed) **"
local vib="0Vxy - Set Vibrato x= speed, y= depth; x=(0-F); y=(0-F)*"
local tre="0Txy - Set Tremolo x= speed, y= depth"
local apan="0Nxy - Set Auto Pan, x= speed, y= depth"
local aenv="0Exx - Set Active Sample Envelope's Position to Offset XX"
local trout="0Jxx - Set Track's Output Routing to channel XX"
local stopall="0Xxx - Stop all notes and FX (xx = 00), or only effect xx (xx > 00)"


-- Locals required to generate list
local wiki="www"
local wikitooltip="http://tutorials.renoise.com/wiki/Pattern_Effect_Commands#Effect_Listing"
local wikibutton= vb:button { text=wiki, tooltip=wikitooltip,
  pressed = function() renoise.app():open_url("http://tutorials.renoise.com/wiki/Pattern_Effect_Commands#Effect_Listing")
  end}, vb:text {text=wikitooltip}

local arpeggio="0Axy"
local arpeggiotooltip="0Axy - Arpeggio (x=1st note offset, y=2nd note offset (in semitones)) *"
local arpeggiobutton= vb:button { text=arpeggio, tooltip=arpeggiotooltip,
  pressed = function() effect_write("0A",arp)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}, vb:text {text=arpeggiotooltip}

local pitchslideup="0Uxx"
local pitchslideuptooltip="0Uxx - Pitch Slide up (00-FF) *"
local pitchslideupbutton = vb:button {text=pitchslideup, tooltip=pitchslideuptooltip,
  pressed = function() effect_write("0U",pup)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local pitchslidedown="0Dxx"
local pitchslidedowntooltip="0Dxx - Pitch Slide down (00-FF) *"
local pitchslidedownbutton=vb:button { text=pitchslidedown, tooltip=pitchslidedowntooltip,
  pressed = function() effect_write("0D",pdn)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local setchannelvol="0Mxx"
local setchannelvoltooltip="0Mxx - Set Channel volume (00-FF)"
local setchannelvolbutton=vb:button { text=setchannelvol, tooltip=setchannelvoltooltip,
  pressed = function() effect_write("0M",chv)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local volumeslicer="0Cxy"
local volumeslicertooltip="0Cxy - Volume slicer  x=factor (0=0%, F=100%), slice at tick y. *"
local volumeslicerbutton=vb:button { text=volumeslicer, tooltip=volumeslicertooltip,
  pressed = function() effect_write("0C",vls)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local glidetonote="0Gxx"
local glidetonotetooltip="0Gxx - Glide to note with step xx (00-FF)*" 
local glidetonotebutton=vb:button { text=glidetonote, tooltip=glidetonotetooltip,
  pressed = function() effect_write("0G",gli)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local volumeslideup="0Ixx"
local volumeslideuptooltip="0Ixx - Volume slide up with step xx (0064) (64x0601 or 2x0632 = slide0-full) *"
local volumeslideupbutton=vb:button { text=volumeslideup, tooltip=volumeslideuptooltip,
  pressed = function() effect_write("0I",vup)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local volumeslidedown="0Oxx"
local volumeslidedowntooltip="0Oxx - Volume slide down with step xx (0064) *"
local volumeslidedownbutton=vb:button { text=volumeslidedown, tooltip=volumeslidedowntooltip,
  pressed = function() effect_write("0O",vdn)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local setpanning="0Pxx"
local setpanningtooltip="0Pxx - Set panning (00-FF) (00: left; 80: center; FF: right)"
local setpanningbutton=vb:button { text=setpanning, tooltip=setpanningtooltip,
  pressed = function() effect_write("0P",pan)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local triggersample="0Sxx"
local triggersampletooltip="0Sxx - Trigger sample offset, 00 is sample start, FF is sample end. *"
local triggersamplebutton=vb:button { text=triggersample, tooltip=triggersampletooltip,
  pressed = function() effect_write("0S",off)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local surround="0Wxx"
local surroundtooltip="0Wxx - Surround width (00-FF) *"
local surroundbutton=vb:button { text=surround, tooltip=surroundtooltip,
  pressed = function() effect_write("0W",sur)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local playsamplebackwards="0Bxx"
local playsamplebackwardstooltip="0Bxx - Play sample backwards (B00) or forwards again (B01) *"
local playsamplebackwardsbutton=vb:button { text=playsamplebackwards, tooltip=playsamplebackwardstooltip,
  pressed = function() effect_write("0B",rev)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local settrackvolume="0Lxx"
local settrackvolumetooltip="0Lxx - Set track-volume (00-FF)"
local settrackvolumebutton=vb:button { text=settrackvolume, tooltip=settrackvolumetooltip,
  pressed = function() effect_write("0L",trv)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local delaynotes="0Qxx"
local delaynotestooltip="0Qxx - Delay notes in track-row xx ticks before playing. (00-speed)"
local delaynotesbutton=vb:button { text=delaynotes, tooltip=delaynotestooltip,
  pressed = function() effect_write("0Q",del)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local retrig="0Rxy"
local retrigtooltip="0Rxy - Retrig notes in track-row every xy ticks (x=volume; y=ticks 0 - speed) **"
local retrigbutton=vb:button { text=retrig, tooltip=retrigtooltip,
  pressed = function() effect_write("0R",ret)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local vibrato="0Vxy"
local vibratotooltip="0Vxy - Vibrato x= speed, y = depth; x=(0-F); y=(0-F)*"
local vibratobutton=vb:button { text=vibrato, tooltip=vibratotooltip,
  pressed = function() effect_write("0V",vib)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local tremolo="0Txy"
local tremolotooltip="0Txy - Set Tremolo x= speed, y= depth"
local tremolobutton=vb:button { text=tremolo, tooltip=tremolotooltip,
  pressed = function() effect_write("0T",tre)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
  end}

local autopan="0Nxy"
local autopantooltip="0Nxy - Set Auto Pan, x= speed, y= depth"
local autopanbutton=vb:button { text=autopan, tooltip=autopantooltip,
  pressed = function() effect_write("0N",apan)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
end}

local aenv="0Exy"
local aenvtooltip="0Exy - Set Active Sample Envelope's Position to Offset XX"
local aenvbutton=vb:button { text=aenv, tooltip=aenvtooltip,
  pressed = function() effect_write("0E",aenv)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
end}

local trout="0Jxy"
local trouttooltip="0Jxx - Set Track's Output Routing to channel XX"
local troutbutton=vb:button { text=trout, tooltip=trouttooltip,
  pressed = function() effect_write("0J",trout)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
end}

local stopall="0Xxy"
local stopalltooltip="0Xxx - Stop all notes and FX (xx = 00) or only effect xx (xx >00)"
local stopallbutton=vb:button { text=stopall, tooltip=stopalltooltip,
  pressed = function() effect_write("0X",stopall)
  renoise.app().window.active_middle_frame = 1
  renoise.app().window.lock_keyboard_focus=true
end}

  

  
  
  
-------

--Generation of Pattern Effect
local dialog_title = "Paketti 0.45 - Pattern Effect Command CheatSheet"
local DEFAULT_MARGIN = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN

local effect_buttons = vb:column {
arpeggiobutton,
pitchslideupbutton,
pitchslidedownbutton,
setchannelvolbutton,
volumeslicerbutton,
glidetonotebutton,
volumeslideupbutton,
volumeslidedownbutton,
setpanningbutton,
triggersamplebutton,
surroundbutton,
playsamplebackwardsbutton,
settrackvolumebutton,
delaynotesbutton,
retrigbutton,
vibratobutton,
tremolobutton,
autopanbutton,
aenvbutton,
troutbutton,
stopallbutton,
wikibutton}

local effect_desc = vb:column {
vb:text{text=arpeggiotooltip},
vb:text{text=pitchslideuptooltip},
vb:text{text=pitchslidedowntooltip},
vb:text{text=setchannelvoltooltip},
vb:text{text=volumeslicertooltip},
vb:text{text=glidetonotetooltip},
vb:text{text=volumeslideuptooltip},
vb:text{text=volumeslidedowntooltip},
vb:text{text=setpanningtooltip},
vb:text{text=triggersampletooltip},
vb:text{text=surroundtooltip},
vb:text{text=playsamplebackwardstooltip},
vb:text{text=settrackvolumetooltip},
vb:text{text=delaynotestooltip},
vb:text{text=retrigtooltip},
vb:text{text=vibratotooltip},
vb:text{text=tremolotooltip},
vb:text{text=autopantooltip},
vb:text{text=aenvtooltip},
vb:text{text=trouttooltip},
vb:text{text=stopalltooltip},
vb:text{text=wikitooltip}
}


local dialog_content = vb:row {effect_buttons, effect_desc}

--{vb:column {effect_buttons},{vb:column{effect_desc}}}
  
  local function my_keyhandler_func(dialog, key)
 if not (key.modifiers == "" and key.name == "exclamation") then
    return key
 else
   dialog:close()
 end
end

  renoise.app():show_custom_dialog(dialog_title, dialog_content,my_keyhandler_func)
end
      
renoise.tool():add_keybinding {name = "Global:Paketti:Pattern Effect Command CheatSheet",
invoke = function() CheatSheet() end}

renoise.tool():add_menu_entry {name="Main Menu:Tools:Paketti..:Effect Column CheatSheet", invoke = function()
CheatSheet() end}

-----
--functions+ descriptions + etc + for 16 shortcuts for effects
--local status="00xy - Arpeggio (x=base note offset1, y=base noteoffset 2) *"
--local status="01xx - Pitch Slide up (00-FF) *"
--local status="02xx - Pitch Slide down (00-FF) *"
--local status="03xx - Set Channel volume (00-FF)"
--local status="04xy - Volume slicer -- x=factor (0=0.0, F=1.0), slice at tick y. *"
--local status="05xx - Glide to note with step xx (00-FF)*" 
--local status="06xx - Volume slide up with step xx (0064) (64x0601 or 2x0632 = slide0-full) *"
--local status="07xx - Volume slide down with step xx (0064) *"
--local status="08xx - Set panning (00-FF) (00: left; 80: center; FF: right)"
--local status="09xx - Trigger sample offset, 00 is sample start, FF is sample end. *"
--local status="0Axx - Surround width (00-FF) *"
--local status="0Bxx - Play sample backwards (B00) or forwards again (B01) *"
--local status="0Cxx - Set track-volume (00-FF)"
--local status="0Dxx - Delay notes in track-row xx ticks before playing. (00-speed)"
--local status="0Exy - Retrig notes in track-row every xy ticks (x=volume; y=ticks 0 - speed) **"
--local status="0Fxy - Vibrato x= speed, y = depth; x=(0-F); y=(0-F)*"

--Effect Functions

function effect_write(effect,effectstatus)
local s = renoise.song()
local w = renoise.app().window
local efc = s.selected_effect_column
     --s.selected_effect_column_index=1

local status=effectstatus

local i=effect
 if efc==nil then
  return
  else
  if efc.number_string==i then
  efc.number_string="00"
  efc.amount_value=00
   else
  efc.number_string=i
  efc.amount_value=00
  renoise.app():show_status(status)
 end
 w.active_middle_frame = 1
 w.lock_keyboard_focus = true
end
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:CheatSheet",invoke=function() CheatSheet() end}

