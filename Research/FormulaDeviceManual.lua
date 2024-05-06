--[[----------------------------------------------------------------------------

  Author : Alexander Stoica
  Creation Date : 07/27/2010
  Last modified : 07/27/2010
  Version : 1.0

----------------------------------------------------------------------------]]--

_AUTO_RELOAD_DEBUG = true

--[[ manual dialog ]]-------------------------------------------------------]]--

function show_manual(dialog_title, filename)

  local header = table.create()
  local pages = table.create()
  local manual_filename = renoise.tool().bundle_path .. filename

  local vb = renoise.ViewBuilder()
  local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  local CONTROL_MARGIN = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN

  local row_navigation = vb:horizontal_aligner {
    id = "navigation",
    margin = CONTROL_MARGIN,
    mode = "justify",

    vb:valuebox {
      id = "page_index",
      width = "10%",
      min = 0,
      max = 0,
      notifier = function(value)
        vb.views.page_list.value = value
      end
    },
    vb:popup {
      id = "page_list",
      width = "90%",
      items = {},
      notifier = function(index)
        vb.views.page_index.value = index
        load_page(vb.views, header, pages, index)
      end
    }
  }

  local row_text = vb:horizontal_aligner {
    margin = CONTROL_MARGIN,

    vb:multiline_text {
      id = "page_text",
      font = "mono",
      width = 506,
      height = 250
    }
  }

  local dialog_content = vb:column {
    margin = DIALOG_MARGIN,

    vb:column {
      id = "content",
      margin = DIALOG_MARGIN,
      style = "group",

      row_navigation,
      row_text
    }
  }

  if io.exists(manual_filename) then

    for line in io.lines(manual_filename) do
      if not line:find("@@(.-)@@") then
        if not pages:is_empty() then
          pages[#pages].lines:insert(line)
        else
          header:insert(line)
        end
      else
         pages:insert(table.create())
         pages[#pages] = {
           name = line:match("@@(.-)@@"),
           lines = table.create()
         }
         line = line:gsub("@@", "")
         pages[#pages].lines:insert(line)
      end
    end

    if not pages:is_empty() then

      local page_names = table.create()

      for _, page in ipairs(pages) do
        page_names:insert(page.name)
      end

      vb.views.page_list.items = page_names
      vb.views.page_index.min = 1
      vb.views.page_index.max = #pages
      vb.views.page_index.value = 1

    else
      vb.views.navigation.visible = false
    end

    vb.views.content:resize()
    load_page(vb.views, header, pages, 1)


   renoise.app():show_custom_dialog (
        dialog_title, dialog_content
        )

  else
    renoise.app():show_warning (
      "The manual could not be found, please reinstall this tool.\n\n" ..
      "Missing file: " .. manual_filename
    )
  end

end

--[[ load page ]]-----------------------------------------------------------]]--

function load_page(vbv, header, pages, page_index)

  vbv.page_text.paragraphs = header

  if not pages:is_empty() then
    for _, line in ipairs(pages[page_index].lines) do
      vbv.page_text:add_line(line)
    end
  end

end

---------------------------------------------------------------------[[ EOF ]]--
