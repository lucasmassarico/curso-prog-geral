local Board = require('board')
local Minesweeper = {}

local DIRS = {
  {-1,-1},{-1, 0},{-1, 1},
  { 0,-1},        { 0, 1},
  { 1,-1},{ 1, 0},{ 1, 1},
}

local HIDDEN = '#'
local FLAG = 'F'
local MINE = '*'
local EMPTY = '.'

local function readAction()
  while true do
    io.write('Action (o=open, f=flag): ')
    local action = io.read()

    if action == 'o' or action == 'f' then
      return action
    end

    print('Invalid action. Try again.')
  end
end

function Minesweeper.create(config)
  local game = {}
  game.config = config
  setmetatable(game, { __index = Minesweeper })
  return game
end

function Minesweeper:run()
  print(self.config.startMessage)
  self:chooseDifficulty()
  self:setupBoard()
  self.startTime = os.time()

  self:playManual()

  print('Minesweeper has finished!')
end

function Minesweeper:chooseDifficulty()
  local difficulties = self.config.difficulties
  print('Select difficulty:')
  for i, difficulty in ipairs(difficulties) do
    print(string.format("%d - %s (%dx%d, %d mines)", i, difficulty.name, difficulty.rows, difficulty.columns, difficulty.mines))
  end

  local choice = readNumber('Choose: ', 1, #difficulties, 'Invalid choice. Try again.')
  self.difficulty = difficulties[choice]
end

function Minesweeper:setupBoard()
  local rows = self.difficulty.rows
  local cols = self.difficulty.columns
  self.rows = rows
  self.columns = cols
  self.totalMines = self.difficulty.mines
  self.flagCount = 0
  self.openedCount = 0
  self.minesPlaced = false
  self.gameOver = false
  self.won = false

  self.opened = {}
  self.flagged = {}
  self.mines = {}
  self.counts = {}
  for i=1,rows do
    self.opened[i] = {}
    self.flagged[i] = {}
    self.mines[i] = {}
    self.counts[i] = {}
    for j=1,cols do
      self.opened[i][j] = false
      self.flagged[i][j] = false
      self.mines[i][j] = false
      self.counts[i][j] = 0
    end
  end

  self.board = Board.create(rows, cols, HIDDEN)
end

function Minesweeper:inBounds(r, c)
  return r >= 1 and r <= self.rows and c >= 1 and c <= self.columns
end

function Minesweeper:placeMines(safeRow, safeCol)
  local rows = self.rows
  local cols = self.columns

  local safeSet = {}
  safeSet[(safeRow - 1) * cols + safeCol] = true
  for i=1,#DIRS do
    local neighborRow = safeRow + DIRS[i][1]
    local neighborColumn = safeCol + DIRS[i][2]
    if self:inBounds(neighborRow, neighborColumn) then
      safeSet[(neighborRow - 1) * cols + neighborColumn] = true
    end
  end

  local placed = 0
  while placed < self.totalMines do
    local randomRow = math.random(1, rows)
    local randomColumn = math.random(1, cols)
    if not self.mines[randomRow][randomColumn] and not safeSet[(randomRow - 1) * cols + randomColumn] then
      self.mines[randomRow][randomColumn] = true
      placed = placed + 1
    end
  end

  for r=1,rows do
    local countsRow = self.counts[r]
    for c=1,cols do
      if not self.mines[r][c] then
        local count = 0
        for i=1,#DIRS do
          local neighborRow = r + DIRS[i][1]
          local neighborColumn = c + DIRS[i][2]
          if self:inBounds(neighborRow, neighborColumn) and self.mines[neighborRow][neighborColumn] then
            count = count + 1
          end
        end
        countsRow[c] = count
      end
    end
  end

  self.minesPlaced = true
end

function Minesweeper:openCell(r, c)
  if self.opened[r][c] or self.flagged[r][c] then
    return nil
  end

  if not self.minesPlaced then
    self:placeMines(r, c)
  end

  if self.mines[r][c] then
    self.opened[r][c] = true
    self.board:setValue(r, c, MINE)
    self.gameOver = true
    return { {r, c} }
  end

  local newlyOpened = {}
  local stack = { {r, c} }
  local stackSize = 1

  while stackSize > 0 do
    local cell = stack[stackSize]
    stack[stackSize] = nil
    stackSize = stackSize - 1

    local currentRow = cell[1]
    local currentColumn = cell[2]

    if not self.opened[currentRow][currentColumn] and not self.flagged[currentRow][currentColumn] then
      self.opened[currentRow][currentColumn] = true
      self.openedCount = self.openedCount + 1
      table.insert(newlyOpened, cell)

      local count = self.counts[currentRow][currentColumn]
      if count == 0 then
        self.board:setValue(currentRow, currentColumn, EMPTY)

        for i=1,#DIRS do
          local neighborRow = currentRow + DIRS[i][1]
          local neighborColumn = currentColumn + DIRS[i][2]

          if self:inBounds(neighborRow, neighborColumn) and not self.opened[neighborRow][neighborColumn] then
            stackSize = stackSize + 1
            stack[stackSize] = { neighborRow, neighborColumn }
          end
        end
      else
        self.board:setValue(currentRow, currentColumn, tostring(count))
      end
    end
  end

  if self.openedCount == self.rows * self.columns - self.totalMines then
    self.gameOver = true
    self.won = true
  end

  return newlyOpened
end

function Minesweeper:flagCell(r, c)
  if self.opened[r][c] then
    return
  end
  if self.flagged[r][c] then
    self.flagged[r][c] = false
    self.flagCount = self.flagCount - 1
    self.board:setValue(r, c, HIDDEN)
  else
    self.flagged[r][c] = true
    self.flagCount = self.flagCount + 1
    self.board:setValue(r, c, FLAG)
  end
end

function Minesweeper:drawStatus()
  local elapsed = os.time() - self.startTime
  print('Time: ' .. elapsed .. 's  |  Flags: ' .. self.flagCount .. '/' .. self.totalMines)
end

function Minesweeper:playManual()
  while not self.gameOver do
    self.board:draw()
    self:drawStatus()

    local action = readAction()
    local row = readNumber('Row: ', 1, self.rows, 'Invalid row. Try again.')
    local col = readNumber('Column: ', 1, self.columns, 'Invalid column. Try again.')

    if action == 'f' then
      self:flagCell(row, col)
    else
      self:openCell(row, col)
    end
  end

  self.board:draw()
  self:drawStatus()
  if self.won then
    print('You won!')
  else
    print('Game over! You hit a mine.')
  end
end

return Minesweeper
