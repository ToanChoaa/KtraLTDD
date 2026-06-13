// lib/services/game_logic.dart

import '../models/game_state.dart';

class GameLogic {
  static const int boardSize = GameState.boardSize;
  static const int winCount = 5;

  /// Kiểm tra thắng sau khi đặt quân tại (row, col)
  static bool checkWin(List<List<CellValue>> board, int row, int col) {
    final cell = board[row][col];
    if (cell == CellValue.empty) return false;

    const directions = [
      [0, 1],  // ngang
      [1, 0],  // dọc
      [1, 1],  // chéo xuống phải
      [1, -1], // chéo xuống trái
    ];

    for (final dir in directions) {
      int count = 1;

      // Đếm theo hướng thuận
      for (int i = 1; i < winCount; i++) {
        final nr = row + dir[0] * i;
        final nc = col + dir[1] * i;
        if (!_inBounds(nr, nc) || board[nr][nc] != cell) break;
        count++;
      }
      // Đếm theo hướng ngược
      for (int i = 1; i < winCount; i++) {
        final nr = row - dir[0] * i;
        final nc = col - dir[1] * i;
        if (!_inBounds(nr, nc) || board[nr][nc] != cell) break;
        count++;
      }

      if (count >= winCount) return true;
    }
    return false;
  }

  /// Kiểm tra hòa (bàn cờ đầy mà chưa ai thắng)
  static bool checkDraw(List<List<CellValue>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell == CellValue.empty) return false;
      }
    }
    return true;
  }

  static bool _inBounds(int r, int c) =>
      r >= 0 && r < boardSize && c >= 0 && c < boardSize;

  /// Tạo bản sao bàn cờ
  static List<List<CellValue>> copyBoard(List<List<CellValue>> board) {
    return board.map((row) => List<CellValue>.from(row)).toList();
  }
}
