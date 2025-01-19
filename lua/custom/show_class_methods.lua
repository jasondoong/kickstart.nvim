local M = {}

function M.show_classes_and_methods()
  local function on_list(options)
    local filtered_options = {}

    -- Iterate over 'items' to filter out variables and build a tree-like structure
    for key, value in pairs(options) do
      if key == 'items' then
        local filtered_items = {}
        local last_kind = nil

        for _, item in ipairs(value) do
          local prefix = ""

          if item.kind == 'Class' then
            -- Top-level classes
            prefix = ".\t "
            last_kind = 'Class'
          elseif item.kind == 'Method' then
            -- Indent methods under classes
            if last_kind == 'Class' then
              prefix = ".\t │ "
            else
              prefix = ".\t   "
            end
          elseif item.kind == 'Function' then
            prefix = ".\t "
          end

          if item.kind ~= 'Variable' then
            -- Add the tree-like prefix
            item.text = prefix .. item.text
            table.insert(filtered_items, item)
          end
        end

        filtered_options[key] = filtered_items
      else
        filtered_options[key] = value
      end
    end

    -- Set the quickfix list and open it
    vim.fn.setqflist({}, ' ', filtered_options)
    vim.cmd([[copen]])
  end

  -- Request document symbols and process them through `on_list`
  vim.lsp.buf.document_symbol({ on_list = on_list })
end

return M

