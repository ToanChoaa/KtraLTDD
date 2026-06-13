// lib/models/game_state.dart

enum CellValue { empty, player, cpu }

enum GameStatus { playing, playerWin, cpuWin, draw }

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Map<String, int> toJson() => {'x': x, 'y': y};

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(json['x'] as int, json['y'] as int);
  }

  @override
  bool operator ==(Object other) =>
      other is Position && other.x == x && other.y == y;

  @override
  int get hashCode => x * 31 + y;
}

class GameState {
  static const int boardSize = 8;

  final List<List<CellValue>> board;
  final bool isPlayerTurn;
  final GameStatus status;
  final Position? lastPlayerMove;
  final Position? lastCpuMove;
  final List<Position> playerMoves;
  final List<Position> cpuMoves;

  GameState({
    required this.board,
    required this.isPlayerTurn,
    required this.status,
    this.lastPlayerMove,
    this.lastCpuMove,
    required this.playerMoves,
    required this.cpuMoves,
  });

  factory GameState.initial() {
    return GameState(
      board: List.generate(
        boardSize,
        (_) => List.filled(boardSize, CellValue.empty),
      ),
      isPlayerTurn: true,
      status: GameStatus.playing,
      lastPlayerMove: null,
      lastCpuMove: null,
      playerMoves: [],
      cpuMoves: [],
    );
  }

  GameState copyWith({
    List<List<CellValue>>? board,
    bool? isPlayerTurn,
    GameStatus? status,
    Position? lastPlayerMove,
    Position? lastCpuMove,
    List<Position>? playerMoves,
    List<Position>? cpuMoves,
  }) {
    return GameState(
      board: board ?? this.board,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
      status: status ?? this.status,
      lastPlayerMove: lastPlayerMove ?? this.lastPlayerMove,
      lastCpuMove: lastCpuMove ?? this.lastCpuMove,
      playerMoves: playerMoves ?? this.playerMoves,
      cpuMoves: cpuMoves ?? this.cpuMoves,
    );
  }

  Map<String, dynamic> toJson() {
    // Flatten board to list of ints (0=empty, 1=player, 2=cpu)
    final flatBoard = board
        .map((row) => row.map((c) => c.index).toList())
        .toList();
    return {
      'board': flatBoard,
      'isPlayerTurn': isPlayerTurn,
      'status': status.index,
      'lastPlayerMove': lastPlayerMove?.toJson(),
      'lastCpuMove': lastCpuMove?.toJson(),
      'playerMoves': playerMoves.map((p) => p.toJson()).toList(),
      'cpuMoves': cpuMoves.map((p) => p.toJson()).toList(),
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    final flatBoard = json['board'] as List;
    final board = flatBoard.map((row) {
      return (row as List).map((v) => CellValue.values[v as int]).toList();
    }).toList();

    return GameState(
      board: board,
      isPlayerTurn: json['isPlayerTurn'] as bool,
      status: GameStatus.values[json['status'] as int],
      lastPlayerMove: json['lastPlayerMove'] != null
          ? Position.fromJson(json['lastPlayerMove'] as Map<String, dynamic>)
          : null,
      lastCpuMove: json['lastCpuMove'] != null
          ? Position.fromJson(json['lastCpuMove'] as Map<String, dynamic>)
          : null,
      playerMoves: (json['playerMoves'] as List)
          .map((p) => Position.fromJson(p as Map<String, dynamic>))
          .toList(),
      cpuMoves: (json['cpuMoves'] as List)
          .map((p) => Position.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
