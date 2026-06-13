// lib/providers/game_provider.dart

import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../services/api_service.dart';
import '../services/game_logic.dart';
import '../services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  GameState _state = GameState.initial();
  bool _isLoading = false;

  GameState get state => _state;
  bool get isLoading => _isLoading;

  /// Khởi tạo: tải ván cờ đã lưu (nếu có)
  Future<void> init() async {
    final saved = await StorageService.loadGameState();
    if (saved != null && saved.status == GameStatus.playing) {
      _state = saved;
      notifyListeners();
    }
  }

  /// Người chơi đánh vào ô (row, col)
  Future<void> playerMove(int row, int col) async {
    if (_isLoading) return;
    if (_state.status != GameStatus.playing) return;
    if (!_state.isPlayerTurn) return;
    if (_state.board[row][col] != CellValue.empty) return;

    // Cập nhật bàn cờ với nước đi của người chơi
    final newBoard = GameLogic.copyBoard(_state.board);
    newBoard[row][col] = CellValue.player;

    final newPlayerMoves = List<Position>.from(_state.playerMoves)
      ..add(Position(row, col));

    // Kiểm tra thắng
    if (GameLogic.checkWin(newBoard, row, col)) {
      _state = _state.copyWith(
        board: newBoard,
        playerMoves: newPlayerMoves,
        status: GameStatus.playerWin,
        lastPlayerMove: Position(row, col),
        isPlayerTurn: false,
      );
      await StorageService.clearGameState();
      notifyListeners();
      return;
    }

    // Kiểm tra hòa
    if (GameLogic.checkDraw(newBoard)) {
      _state = _state.copyWith(
        board: newBoard,
        playerMoves: newPlayerMoves,
        status: GameStatus.draw,
        lastPlayerMove: Position(row, col),
        isPlayerTurn: false,
      );
      await StorageService.clearGameState();
      notifyListeners();
      return;
    }

    // Chuyển lượt sang CPU
    _state = _state.copyWith(
      board: newBoard,
      playerMoves: newPlayerMoves,
      lastPlayerMove: Position(row, col),
      isPlayerTurn: false,
    );
    notifyListeners();

    // Gọi API lấy nước đi của CPU
    await _cpuMove(newPlayerMoves);
  }

  Future<void> _cpuMove(List<Position> playerMoves) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cpuPos = await ApiService.getCpuMove(
        playerMoves: playerMoves,
        cpuMoves: _state.cpuMoves,
      );

      if (cpuPos == null) {
        // Không có nước đi hợp lệ → hòa
        _state = _state.copyWith(status: GameStatus.draw);
        _isLoading = false;
        await StorageService.clearGameState();
        notifyListeners();
        return;
      }

      // Đảm bảo ô CPU chọn là trống
      if (_state.board[cpuPos.x][cpuPos.y] != CellValue.empty) {
        // Tìm ô trống khác (fallback)
        final fallback = _findEmptyCell();
        if (fallback == null) {
          _state = _state.copyWith(status: GameStatus.draw);
          _isLoading = false;
          await StorageService.clearGameState();
          notifyListeners();
          return;
        }
        await _applyCpuMove(fallback);
        return;
      }

      await _applyCpuMove(cpuPos);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyCpuMove(Position cpuPos) async {
    final newBoard = GameLogic.copyBoard(_state.board);
    newBoard[cpuPos.x][cpuPos.y] = CellValue.cpu;

    final newCpuMoves = List<Position>.from(_state.cpuMoves)..add(cpuPos);

    // Kiểm tra CPU thắng
    if (GameLogic.checkWin(newBoard, cpuPos.x, cpuPos.y)) {
      _state = _state.copyWith(
        board: newBoard,
        cpuMoves: newCpuMoves,
        lastCpuMove: cpuPos,
        status: GameStatus.cpuWin,
        isPlayerTurn: false,
      );
      _isLoading = false;
      await StorageService.clearGameState();
      notifyListeners();
      return;
    }

    // Kiểm tra hòa
    if (GameLogic.checkDraw(newBoard)) {
      _state = _state.copyWith(
        board: newBoard,
        cpuMoves: newCpuMoves,
        lastCpuMove: cpuPos,
        status: GameStatus.draw,
        isPlayerTurn: false,
      );
      _isLoading = false;
      await StorageService.clearGameState();
      notifyListeners();
      return;
    }

    // Trả lượt cho người chơi
    _state = _state.copyWith(
      board: newBoard,
      cpuMoves: newCpuMoves,
      lastCpuMove: cpuPos,
      isPlayerTurn: true,
    );
    _isLoading = false;

    // Lưu trạng thái
    await StorageService.saveGameState(_state);
    notifyListeners();
  }

  Position? _findEmptyCell() {
    for (int r = 0; r < GameState.boardSize; r++) {
      for (int c = 0; c < GameState.boardSize; c++) {
        if (_state.board[r][c] == CellValue.empty) return Position(r, c);
      }
    }
    return null;
  }

  /// Reset ván cờ mới
  Future<void> resetGame() async {
    _isLoading = false;
    _state = GameState.initial();
    await StorageService.clearGameState();
    notifyListeners();
  }
}
