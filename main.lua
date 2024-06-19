require "Paketti0G01_Loader"
require "PakettiAutomation"
require "PakettiControls"
require "PakettiImpulseTracker"
require "PakettiInstrumentBox"
require "PakettiLoaders"
require "PakettiLoadNativeGUI"
require "PakettiLoadVSTGUI"
require "PakettiLoadAUVST3GUI"
require "PakettiLoadPlugins"
require "PakettiMainMenuEntries"
require "PakettiMidi"
require "PakettiPatternEditor"
require "PakettiPatternEditorCheatSheet"
require "PakettiPatternMatrix"
require "PakettiPhraseEditor"
require "PakettiSamples"
require "PakettiRecorder" 
require "PakettiExperimental_Verify"
-- These were requested via GitHub / Renoise Forum / Renoise Discord - always get in touch with me (esaruoho@icloud.com)
-- Or post a feature on https://github.com/esaruoho/org.lackluster.Paketti.xrnx/issues/new
require "PakettiRequests"


------------------------------------------------
-- Autoexec.bat
-- everytime a new Renoise song is created, run this
function startup()  
   local s=renoise.song()
   local t=s.transport
     -- renoise.app().window:select_preset(1)
      s.sequencer.keep_sequence_sorted=false
      t.groove_enabled=true
      renoise.app():show_status("There was a save and the Startup Notifier ran.")
end

if not renoise.tool().app_new_document_observable:has_notifier(startup)   
  then renoise.tool().app_new_document_observable:add_notifier(startup)
  else renoise.tool().app_new_document_observable:remove_notifier(startup) end  
---------
_AUTO_RELOAD_DEBUG = function() startup()
end

-- Debug print  
function dbug(msg)  
 local base_types = {  
 ["nil"]=true, ["boolean"]=true, ["number"]=true,  
 ["string"]=true, ["thread"]=true, ["table"]=true  
 }  
 if not base_types[type(msg)] then oprint(msg)  
 elseif type(msg) == 'table' then rprint(msg)  
 else print(msg) end  
end







