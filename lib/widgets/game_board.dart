// lib/widgets/game_board.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import 'board_cell.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        final isLoading = provider.isLoading;

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3A5BA0), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: GameState.boardSize,
                ),
                itemCount: GameState.boardSize * GameState.boardSize,
                itemBuilder: (context, index) {
                  final row = index ~/ GameState.boardSize;
                  final col = index % GameState.boardSize;
                  final value = state.board[row][col];

                  final isLastPlayer =
                      state.lastPlayerMove == Position(row, col);
                  final isLastCpu = state.lastCpuMove == Position(row, col);

                  return BoardCell(
                    value: value,
                    isLastMove: isLastPlayer || isLastCpu,
                    onTap: (!isLoading &&
                            state.status == GameStatus.playing &&
                            state.isPlayerTurn)
                        ? () => provider.playerMove(row, col)
                        : null,
                  );
                },
              ),
            ),

            // Loading overlay 
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'AI đang xử lý...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
