-- PakettiPreferences.lua
local vb = renoise.ViewBuilder()

-- Define Preferences
local preferences = renoise.Document.create("ScriptingToolPreferences") {
    _0G01_Loader = false,
    _RandomBPM = false
}

renoise.tool().preferences = preferences

-- Expose preferences to other scripts
local PakettiPreferences = {}
function PakettiPreferences.get_preferences()
    return preferences
end

-- Function to update and manage preference changes
function PakettiPreferences.update_preferences()
    -- Code to manage dynamic preferences update
end

-- GUI for setting preferences
function PakettiPreferences.show_dialog()
    local dialog, dialog_content
    local checkbox_0G01_Loader = vb:checkbox {
        value = preferences._0G01_Loader.value,
        notifier = function(value)
            preferences._0G01_Loader.value = value
            -- This call is needed to update the state in the main script or anywhere needed
            PakettiPreferences.update_preferences()
        end
    }

    local checkbox_RandomBPM = vb:checkbox {
        value = preferences._RandomBPM.value,
        notifier = function(value)
            preferences._RandomBPM.value = value
        end
    }

    dialog_content = vb:column {
        margin = 10,
        vb:row {
            checkbox_0G01_Loader,
            vb:text { text = "Enable 0G01 Loader" }
        },
        vb:row {
            checkbox_RandomBPM,
            vb:text { text = "Enable Random BPM" }
        },
        vb:horizontal_aligner {
            mode = "distribute",
            vb:button {
                text = "OK",
                notifier = function()
                    dialog:close()
                end
            },
            vb:button {
                text = "Cancel",
                notifier = function()
                    dialog:close()
                end
            }
        }
    }

    dialog = renoise.app():show_custom_dialog("Paketti Preferences", dialog_content)
end



-- Add menu entry for showing the preferences dialog
renoise.tool():add_menu_entry{
    name = "Main Menu:Tools:Paketti..:!Preferences:Paketti Preferencegs2...",
    invoke = PakettiPreferences.show_dialog
}

