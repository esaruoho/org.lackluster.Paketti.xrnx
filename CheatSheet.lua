function CheatSheet()
local vb=renoise.ViewBuilder()
local a=renoise.app()
local s=renoise.song()
local w=a.window

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
local globalwidth=50
-- Locals required to generate list
local wiki="www"
local wikitooltip="http://tutorials.renoise.com/wiki/Pattern_Effect_Commands#Effect_Listing"
local wikibutton= vb:button {width=globalwidth, text=wiki, tooltip=wikitooltip,
  pressed = function() a:open_url("http://tutorials.renoise.com/wiki/Pattern_Effect_Commands#Effect_Listing")
  end}, vb:text {text=wikitooltip}

local arpeggio="0Axy"
local arpeggiotooltip="0Axy - Arpeggio (x=1st note offset, y=2nd note offset (in semitones)) *"
local arpeggiobutton= vb:button {width=globalwidth, text=arpeggio, tooltip=arpeggiotooltip,
  pressed = function() effect_write("0A",arp) end}, vb:text {text=arpeggiotooltip}

local pitchslideup="0Uxx"
local pitchslideuptooltip="0Uxx - Pitch Slide up (00-FF) *"
local pitchslideupbutton = vb:button {width=globalwidth, text=pitchslideup, tooltip=pitchslideuptooltip,
  pressed = function() effect_write("0U",pup) end}

local pitchslidedown="0Dxx"
local pitchslidedowntooltip="0Dxx - Pitch Slide down (00-FF) *"
local pitchslidedownbutton=vb:button {width=globalwidth, text=pitchslidedown, tooltip=pitchslidedowntooltip,
  pressed = function() effect_write("0D",pdn) end}

local setchannelvol="0Mxx"
local setchannelvoltooltip="0Mxx - Set Channel volume (00-FF)"
local setchannelvolbutton=vb:button {width=globalwidth, text=setchannelvol, tooltip=setchannelvoltooltip,
  pressed = function() effect_write("0M",chv) end}

local volumeslicer="0Cxy"
local volumeslicertooltip="0Cxy - Volume slicer  x=factor (0=0%, F=100%), slice at tick y. *"
local volumeslicerbutton=vb:button {width=globalwidth, text=volumeslicer, tooltip=volumeslicertooltip,
  pressed = function() effect_write("0C",vls) end}

local glidetonote="0Gxx"
local glidetonotetooltip="0Gxx - Glide to note with step xx (00-FF)*" 
local glidetonotebutton=vb:button {width=globalwidth, text=glidetonote, tooltip=glidetonotetooltip,
  pressed = function() effect_write("0G",gli) end}

local volumeslideup="0Ixx"
local volumeslideuptooltip="0Ixx - Volume slide up with step xx (0064) (64x0601 or 2x0632 = slide0-full) *"
local volumeslideupbutton=vb:button {width=globalwidth, text=volumeslideup, tooltip=volumeslideuptooltip,
  pressed = function() effect_write("0I",vup) end}

local volumeslidedown="0Oxx"
local volumeslidedowntooltip="0Oxx - Volume slide down with step xx (0064) *"
local volumeslidedownbutton=vb:button {width=globalwidth, text=volumeslidedown, tooltip=volumeslidedowntooltip,
  pressed = function() effect_write("0O",vdn) end}

local setpanning="0Pxx"
local setpanningtooltip="0Pxx - Set panning (00-FF) (00: left; 80: center; FF: right)"
local setpanningbutton=vb:button {width=globalwidth, text=setpanning, tooltip=setpanningtooltip,
  pressed = function() effect_write("0P",pan) end}

local triggersample="0Sxx"
local triggersampletooltip="0Sxx - Trigger sample offset, 00 is sample start, FF is sample end. *"
local triggersamplebutton=vb:button {width=globalwidth, text=triggersample, tooltip=triggersampletooltip,
  pressed = function() effect_write("0S",off) end}

local surround="0Wxx"
local surroundtooltip="0Wxx - Surround width (00-FF) *"
local surroundbutton=vb:button {width=globalwidth, text=surround, tooltip=surroundtooltip,
  pressed = function() effect_write("0W",sur) end}

local playsamplebackwards="0Bxx"
local playsamplebackwardstooltip="0Bxx - Play sample backwards (B00) or forwards again (B01) *"
local playsamplebackwardsbutton=vb:button {width=globalwidth, text=playsamplebackwards, tooltip=playsamplebackwardstooltip,
  pressed = function() effect_write("0B",rev) end}

local settrackvolume="0Lxx"
local settrackvolumetooltip="0Lxx - Set track-volume (00-FF)"
local settrackvolumebutton=vb:button {width=globalwidth, text=settrackvolume, tooltip=settrackvolumetooltip,
  pressed = function() effect_write("0L",trv) end}

local delaynotes="0Qxx"
local delaynotestooltip="0Qxx - Delay notes in track-row xx ticks before playing. (00-speed)"
local delaynotesbutton=vb:button {width=globalwidth, text=delaynotes, tooltip=delaynotestooltip,
  pressed = function() effect_write("0Q",del) end}

local retrig="0Rxy"
local retrigtooltip="0Rxy - Retrig notes in track-row every xy ticks (x=volume; y=ticks 0 - speed) **"
local retrigbutton=vb:button {width=globalwidth, text=retrig, tooltip=retrigtooltip,
  pressed = function() effect_write("0R",ret) end}

local vibrato="0Vxy"
local vibratotooltip="0Vxy - Vibrato x= speed, y = depth; x=(0-F); y=(0-F)*"
local vibratobutton=vb:button {width=globalwidth, text=vibrato, tooltip=vibratotooltip,
  pressed = function() effect_write("0V",vib) end}

local tremolo="0Txy"
local tremolotooltip="0Txy - Set Tremolo x= speed, y= depth"
local tremolobutton=vb:button {width=globalwidth, text=tremolo, tooltip=tremolotooltip,
  pressed = function() effect_write("0T",tre) end}

local autopan="0Nxy"
local autopantooltip="0Nxy - Set Auto Pan, x= speed, y= depth"
local autopanbutton=vb:button {width=globalwidth, text=autopan, tooltip=autopantooltip,
  pressed = function() effect_write("0N",apan) end}

local aenv="0Exy"
local aenvtooltip="0Exy - Set Active Sample Envelope's Position to Offset XX"
local aenvbutton=vb:button {width=globalwidth, text=aenv, tooltip=aenvtooltip,
  pressed = function() effect_write("0E",aenv) end}

local trout="0Jxy"
local trouttooltip="0Jxx - Set Track's Output Routing to channel XX"
local troutbutton=vb:button {width=globalwidth, text=trout, tooltip=trouttooltip,
  pressed = function() effect_write("0J",trout) end}

local stopall="0Xxy"
local stopalltooltip="0Xxx - Stop all notes and FX (xx = 00) or only effect xx (xx >00)"
local stopallbutton=vb:button {width=globalwidth, text=stopall, tooltip=stopalltooltip,
  pressed = function() effect_write("0X",stopall) end}
  
-------
--Generation of Pattern Effect
local dialog_title = "Paketti 0.14 - Pattern Effect Command CheatSheet"
local DEFAULT_MARGIN = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN
local DEFAULT_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING

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

local effect_slider = vb:column {
--  vb:button {width=100},
--  vb:button {width="50%"},
--  vb:slider {width=30,height=127},
vb:minislider{ id="delayslider", width=30,height=127, min=0, max=0xFF, notifier=function(v1) 
s.selected_track.delay_column_visible=true
if s.selected_note_column then s.selected_note_column.delay_value=v1 end end},

vb:minislider{ id="panningslider", width=30,height=127, min=0, max=0x80, notifier=function(v2) 
s.selected_track.panning_column_visible=true
if s.selected_note_column then s.selected_note_column.panning_value=v2 end end},

vb:minislider{ id="volumeslider", width=30,height=127, min=0, max=0x80, notifier=function(v3) 
s.selected_track.volume_column_visible=true
if s.selected_note_column then s.selected_note_column.volume_value=v3 end end},

vb:minislider{ id="effectslider", width=30,height=127, min=0, max=0xFF, notifier=function(v4) 
local s=renoise.song()
--s.selected_track.volume_column_visible=true
local nc=s.selected_note_column
local ec=s.selected_effect_column
local nci=s.selected_note_column_index
if nc == nil then 
-- Protect user if notecolumn is nil
  if ec == nil then return false
-- Also protect user if effect column is nil  
  else 
       s.selected_effect_column.amount_value=v4
-- If effectcolumn does exist, just write to it
return end end

local writenc=nil
writenc=nci
-- Store current note column index into a local variable

s.selected_effect_column_index=1
-- Set the selection location to effect column index 1

s.selected_effect_column.amount_value=v4
-- Write to the amount value of the selected effect column - receive this from effectslider.

s.selected_note_column_index=writenc
-- Return back to previous note column index.
end} }

local dialog_content = vb:row {effect_buttons, effect_desc, effect_slider}
local vb=renoise.ViewBuilder()
  
  local function my_keyhandler_func(dialog, key)
 if not (key.modifiers == "" and key.name == "exclamation") then
    return key
 else
   dialog:close()
 end
end
  a:show_custom_dialog(dialog_title, dialog_content,my_keyhandler_func)
end
      
renoise.tool():add_keybinding{name = "Global:Paketti:Pattern Effect Command CheatSheet",invoke=function() CheatSheet() end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Effect Column CheatSheet", invoke=function() CheatSheet() end}

-----
--functions+ descriptions + etc + for 16 shortcuts for effects
--local status="0Axy - Arpeggio (x=base note offset1, y=base noteoffset 2) *"
--local status="0Uxx - Pitch Slide up (00-FF) *"
--local status="0Dxx - Pitch Slide down (00-FF) *"
--local status="0Mxx - Set Channel volume (00-FF)"
--local status="0Cxy - Volume slicer -- x=factor (0=0.0, F=1.0), slice at tick y. *"
--local status="0Gxx - Glide to note with step xx (00-FF)*" 
--local status="0Ixx - Volume slide up with step xx (0064) (64x0601 or 2x0632 = slide0-full) *"
--local status="0Oxx - Volume slide down with step xx (0064) *"
--local status="0Pxx - Set panning (00-FF) (00: left; 80: center; FF: right)"
--local status="0Sxx - Trigger sample offset, 00 is sample start, FF is sample end. *"
--local status="0Axx - Surround width (00-FF) *"
--local status="0Bxx - Play sample backwards (B00) or forwards again (B01) *"
--local status="0Lxx - Set track-volume (00-FF)"
--local status="0Qxx - Delay notes in track-row xx ticks before playing. (00-speed)"
--local status="0Rxy - Retrig notes in track-row every xy ticks (x=volume; y=ticks 0 - speed) **"
--local status="0Vxy - Vibrato x= speed, y = depth; x=(0-F); y=(0-F)*"

--Effect Functions
function effect_write(effect,status)
local s=renoise.song()
local a=renoise.app()
local nc=s.selected_note_column
local ec=s.selected_effect_column
local nci=s.selected_note_column_index
local w=a.window
if nc == nil then 
-- Protect user if notecolumn is nil
  if ec == nil then return false
-- Also protect user if effect column is nil  
  else 
       s.selected_effect_column.number_string=effect
-- If effectcolumn does exist, just write to it
  a:show_status(status)
return end end

local writenc=nil
writenc=nci
-- Store current note column index into a local variable

s.selected_effect_column_index=1
-- Set the selection location to effect column index 1

s.selected_effect_column.number_string=effect
-- Write to the amount value of the selected effect column - receive this from effectslider.

s.selected_note_column_index=writenc
-- Return back to previous note column index.

  a:show_status(status)
  w.active_middle_frame = 1
  w.lock_keyboard_focus = true
  s.selected_note_column_index=writenc
 end
