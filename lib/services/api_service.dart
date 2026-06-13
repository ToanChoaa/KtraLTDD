// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_state.dart';

class ApiService {
  // API endpoint từ đề thi - cập nhật URL thực tế tại đây
  static const String _baseUrl =
      'https://caro-api.onrender.com/api/move'; // Thay bằng URL thực tế

  /// Gọi API để lấy nước đi của CPU
  /// Trả về Position nếu thành công, null nếu lỗi
  static Future<Position?> getCpuMove({
    required List<Position> playerMoves,
    required List<Position> cpuMoves,
  }) async {
    try {
      final payload = {
        'board': [8, 8],
        'player': playerMoves.map((p) => p.toJson()).toList(),
        'cpu': cpuMoves.map((p) => p.toJson()).toList(),
      };

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // API trả về {x: int, y: int} hoặc {position: {x, y}}
        if (data.containsKey('x') && data.containsKey('y')) {
          return Position(data['x'] as int, data['y'] as int);
        } else if (data.containsKey('position')) {
          final pos = data['position'] as Map<String, dynamic>;
          return Position(pos['x'] as int, pos['y'] as int);
        } else if (data.containsKey('move')) {
          final move = data['move'] as Map<String, dynamic>;
          return Position(move['x'] as int, move['y'] as int);
        }
      }
    } catch (e) {
      // Fallback: tính toán nước đi cơ bản nếu API không khả dụng
      return _fallbackMove(playerMoves, cpuMoves);
    }
    return _fallbackMove(playerMoves, cpuMoves);
  }

  /// Fallback AI khi không có API: chiến lược đơn giản
  static Position? _fallbackMove(
    List<Position> playerMoves,
    List<Position> cpuMoves,
  ) {
    const size = GameState.boardSize;
    final occupied = <Position>{...playerMoves, ...cpuMoves};

    // Kiểm tra nếu bàn cờ đầy
    if (occupied.length >= size * size) return null;

    // Thử chặn người chơi trước (tìm điểm nguy hiểm nhất)
    final best = _findBestMove(playerMoves, cpuMoves, occupied);
    return best;
  }

  static Position _findBestMove(
    List<Position> playerMoves,
    List<Position> cpuMoves,
    Set<Position> occupied,
  ) {
    const size = GameState.boardSize;

    // Tính điểm cho từng ô trống
    int bestScore = -1;
    Position? bestPos;

    // Ưu tiên tấn công (tạo chuỗi dài) rồi phòng thủ
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final pos = Position(row, col);
        if (occupied.contains(pos)) continue;

        // Kiểm tra gần vị trí đã đánh
        bool isNear = false;
        for (final p in occupied) {
          if ((p.x - row).abs() <= 2 && (p.y - col).abs() <= 2) {
            isNear = true;
            break;
          }
        }
        if (!isNear && occupied.isNotEmpty) continue;

        final attackScore = _scorePosition(
          pos,
          cpuMoves.toSet(),
          occupied,
          size,
        );
        final defenseScore = _scorePosition(
          pos,
          playerMoves.toSet(),
          occupied,
          size,
        );
        final score = attackScore * 2 + defenseScore;

        if (score > bestScore) {
          bestScore = score;
          bestPos = pos;
        }
      }
    }

    // Nếu chưa có nước đi nào, đánh giữa bàn
    if (occupied.isEmpty) return const Position(3, 3);

    return bestPos ??
        _findFirstEmpty(occupied, size) ??
        const Position(0, 0);
  }

  static Position? _findFirstEmpty(Set<Position> occupied, int size) {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final p = Position(r, c);
        if (!occupied.contains(p)) return p;
      }
    }
    return null;
  }

  static int _scorePosition(
    Position pos,
    Set<Position> moves,
    Set<Position> occupied,
    int size,
  ) {
    const directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];

    int totalScore = 0;
    for (final dir in directions) {
      int count = 1; // Tính vị trí hiện tại
      // Đếm theo hướng thuận
      for (int i = 1; i < 5; i++) {
        final nr = pos.x + dir[0] * i;
        final nc = pos.y + dir[1] * i;
        final np = Position(nr, nc);
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) break;
        if (moves.contains(np)) {
          count++;
        } else {
          break;
        }
      }
      // Đếm theo hướng ngược
      for (int i = 1; i < 5; i++) {
        final nr = pos.x - dir[0] * i;
        final nc = pos.y - dir[1] * i;
        final np = Position(nr, nc);
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) break;
        if (moves.contains(np)) {
          count++;
        } else {
          break;
        }
      }
      totalScore += count * count; // Bình phương để ưu tiên chuỗi dài
    }
    return totalScore;
  }
}
