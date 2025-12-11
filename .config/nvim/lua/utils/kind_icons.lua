local M = {}

local kind_icons = {
  Array = "",
  Boolean = "",
  Class = "",
  Color = "",
  Constant = "",
  Constructor = "",
  Control = "",
  Copilot = "",
  Enum = "",
  EnumMember = "",
  Event = "",
  Field = "",
  File = "",
  Folder = "",
  Function = "",
  Interface = "",
  Key = "",
  Keyword = "",
  Method = "",
  Module = "",
  Namespace = "",
  Null = "",
  Number = "",
  Object = "",
  Operator = "",
  Package = "",
  Property = "",
  Reference = "",
  Snippet = "",
  String = "",
  Struct = "",
  Text = "",
  TypeParameter = "",
  Unit = "",
  Unknown = "",
  Value = "",
  Variable = "",
}

---@param pad? boolean
---@return table
function M.get_icons(pad)
  if pad then
    local padded_icons = {}
    for key, icon in pairs(kind_icons) do
      padded_icons[key] = icon .. " "
    end
    return padded_icons
  end
  return kind_icons
end

return M
