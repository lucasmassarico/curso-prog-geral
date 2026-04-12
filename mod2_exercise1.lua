function setupRootElement()
  local root = {}
  root.id = 'rootElement'
  root.visible = true
  root.color = 'red'
  root['background color'] = 'yellow'
  root.text = 'Main Window'
  root.children = {
    { id = 'child1', zOrder = 1, visible = true, parent = root },
    { id = 'child2', zOrder = 2, visible = true, parent = root },
    { id = 'child3', zOrder = 3, visible = false, clickVolume = 0.02, parent = root },
  }
  root.savedIndexes = { 4, 1, 3, 2, 5, total = 5 }
  root.layoutPositions = { 'top', 'left', 'bottom', 'right' }
  root.innerLengths = { x = 1, l = { x = 2, l = { x = 3, l = { x = 4, l = { x = 5, l = { x = 6 } } } } } }

  return root
end

function table.tostring(t, maxDepth, indent)
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

function main()
  local rootElement = setupRootElement()
  print(table.tostring(rootElement, 3, "  "))
end

main()
