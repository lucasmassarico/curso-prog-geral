local Board = {}

function Board.create(rows, columns, defaultValue)
  local board = {}
  board.rows = rows
  board.columns = columns
  board.data = {}

  for i=1,rows do
    board.data[i] = {}
    for j=1,columns do
      board.data[i][j] = defaultValue
    end
  end

  setmetatable(board, {
    __index = Board
  })
  return board
end

function Board:draw()
  local rows = self.rows
  local cols = self.columns
  local width = #tostring(math.max(rows, cols))
  local emptyLabel = string.rep(' ', width)

  local function pad(value)
    local s = tostring(value)
    local missing = width - #s
    if missing <= 0 then
      return s
    end
    return string.rep(' ', missing) .. s
  end

  local lines = {}

  local header = { emptyLabel }
  for j=1,cols do
    header[#header + 1] = ' '
    header[#header + 1] = pad(j)
  end
  lines[1] = table.concat(header)

  for i=1,rows do
    local row = self.data[i]
    local parts = { pad(i) }
    for j=1,cols do
      parts[#parts + 1] = ' '
      parts[#parts + 1] = pad(row[j])
    end
    lines[i + 1] = table.concat(parts)
  end

  print(table.concat(lines, '\n'))
end

function Board:setValue(row, column, value)
  self.data[row][column] = value
end

function Board:getValue(row, column)
  return self.data[row][column]
end

return Board
