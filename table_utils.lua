local table_utils = {}

function table_utils.tostring(t, maxDepth, indent)
  if type(t) ~= "table" then
    error("Invalid argument: expected a table.", 2)
  end

  local buffer = {}
  local seen = {}
  indent = indent or "  "
  maxDepth = maxDepth or math.huge

  local writeValue
  local writeKey
  local writeTable

  local function push(text)
      buffer[#buffer + 1] = text
  end

  local function isIdentifier(key)
    return type(key) == "string" and key:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
  end

  local function isArrayIndex(key, arraySize)
    return type(key) == "number"
      and key >= 1
      and key <= arraySize
      and key % 1 == 0
  end

  writeValue = function(value, depth, currentIndent)
    local valueType = type(value)

    if valueType == "number" or valueType == "boolean" or valueType == "nil" then
      push(tostring(value))
    elseif valueType == "string" then
      push(string.format("%q", value))
    elseif valueType == "table" then
      if seen[value] or depth > maxDepth then
        push(string.format("%q", tostring(value)))
      else
        writeTable(value, depth, currentIndent)
      end
    else
      push(string.format("%q", tostring(value)))
    end
  end

  writeKey = function(key, depth, currentIndent)
    if isIdentifier(key) then
      push(key)
      push(" = ")
    else
      push("[")
      writeValue(key, depth, currentIndent)
      push("] = ")
    end
  end

  writeTable = function(tbl, depth, currentIndent)
    seen[tbl] = true
    push("{")

    local nextIndent = currentIndent .. indent
    local hasAnyField = false

    local arraySize = 0
    while rawget(tbl, arraySize + 1) ~= nil do
      arraySize = arraySize + 1
    end

    for i = 1, arraySize do
      hasAnyField = true
      push("\n")
      push(nextIndent)
      writeValue(tbl[i], depth + 1, nextIndent)
      push(",")
    end

    for key, value in pairs(tbl) do
      if not isArrayIndex(key, arraySize) then
        hasAnyField = true
        push("\n")
        push(nextIndent)
        writeKey(key, depth + 1, nextIndent)
        writeValue(value, depth + 1, nextIndent)
        push(",")
      end
    end

    if hasAnyField then
      push("\n")
      push(currentIndent)
    end

    push("}")
  end

  writeValue(t, 1, "")
  return table.concat(buffer)
end

return table_utils
