// lib/widgets/board_cell.dart

import 'package:flutter/material.dart';
import '../models/game_state.dart';

class BoardCell extends StatelessWidget {
  final CellValue value;
  final bool isLastMove;
  final VoidCallback? onTap;

  const BoardCell({
    super.key,
    required this.value,
    required this.isLastMove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF3A5BA0), width: 0.8),
        ),
        child: Center(
          child: _buildSymbol(),
        ),
      ),
    );
  }

  Widget _buildSymbol() {
    if (value == CellValue.empty) return const SizedBox.shrink();

    final isX = value == CellValue.player;
    Color color;

    if (isLastMove) {
      // Màu cái mới đánh
      color = isX ? const Color(0xFFFF6B35) : const Color(0xFF00C853);
    } else {
      // Màu bình thường
      color = isX ? const Color(0xFF1565C0) : const Color(0xFFD32F2F);
    }

    return Text(
      isX ? 'X' : 'O',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1,
      ),
    );
  }
}
