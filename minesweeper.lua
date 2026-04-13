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
  for i,d in ipairs(difficulties) do
    print(i .. ' - ' .. d.name .. ' (' .. d.rows .. 'x' .. d.columns .. ', ' .. d.mines .. ' mines)')
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
    local nr = safeRow + DIRS[i][1]
    local nc = safeCol + DIRS[i][2]
    if self:inBounds(nr, nc) then
      safeSet[(nr - 1) * cols + nc] = true
    end
  end

  local placed = 0
  while placed < self.totalMines do
    local r = math.random(1, rows)
    local c = math.random(1, cols)
    if not self.mines[r][c] and not safeSet[(r - 1) * cols + c] then
      self.mines[r][c] = true
      placed = placed + 1
    end
  end

  for r=1,rows do
    local countsRow = self.counts[r]
    for c=1,cols do
      if not self.mines[r][c] then
        local count = 0
        for i=1,#DIRS do
          local nr = r + DIRS[i][1]
          local nc = c + DIRS[i][2]
          if self:inBounds(nr, nc) and self.mines[nr][nc] then
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
  while #stack > 0 do
    local cell = stack[#stack]
    stack[#stack] = nil
    local cr = cell[1]
    local cc = cell[2]
    if not self.opened[cr][cc] and not self.flagged[cr][cc] then
      self.opened[cr][cc] = true
      self.openedCount = self.openedCount + 1
      newlyOpened[#newlyOpened + 1] = cell

      local count = self.counts[cr][cc]
      if count == 0 then
        self.board:setValue(cr, cc, EMPTY)
        for i=1,#DIRS do
          local nr = cr + DIRS[i][1]
          local nc = cc + DIRS[i][2]
          if self:inBounds(nr, nc) and not self.opened[nr][nc] then
            stack[#stack + 1] = { nr, nc }
          end
        end
      else
        self.board:setValue(cr, cc, tostring(count))
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

    io.write('Action (o=open, f=flag): ')
    local action = io.read()
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
