local const = {
  games = {
    {
      name = 'Tic-tac-toe',
      filename = 'tic_tac_toe',
      symbols = { [0] = 'X', [1] = 'O' },
      startMessage = '> Tic-tac-toe is starting...',
    },
    {
      name = 'Sudoku',
      filename = 'sudoku',
      startMessage = '> Sudoku is starting...',
    },
    {
      name = 'Minesweeper',
      filename = 'minesweeper',
      startMessage = '> Minesweeper is starting...',
      difficulties = {
        { name = 'Easy',   rows = 9,  columns = 9,  mines = 10 },
        { name = 'Medium', rows = 16, columns = 16, mines = 40 },
        { name = 'Hard',   rows = 16, columns = 30, mines = 99 },
      },
    },
  }
}

return const
