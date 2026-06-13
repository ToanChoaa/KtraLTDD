// lib/widgets/player_info.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';

class PlayerInfo extends StatelessWidget {
  const PlayerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        final isPlayerTurn =
            state.isPlayerTurn && state.status == GameStatus.playing;
        final isCpuTurn =
            !state.isPlayerTurn && state.status == GameStatus.playing;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _PlayerCard(
                  label: 'NGƯỜI CHƠI',
                  symbol: 'X',
                  symbolColor: const Color(0xFF1565C0),
                  isActive: isPlayerTurn,
                  isLeft: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlayerCard(
                  label: 'AI',
                  symbol: 'O',
                  symbolColor: const Color(0xFFD32F2F),
                  isActive: isCpuTurn,
                  isLeft: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String label;
  final String symbol;
  final Color symbolColor;
  final bool isActive;
  final bool isLeft;

  const _PlayerCard({
    required this.label,
    required this.symbol,
    required this.symbolColor,
    required this.isActive,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1565C0).withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: const Color(0xFF1565C0), width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment:
            isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: isLeft
            ? [
                _buildBadge(isActive),
                const SizedBox(width: 8),
                _buildSymbol(),
              ]
            : [
                _buildSymbol(),
                const SizedBox(width: 8),
                _buildBadge(isActive),
              ],
      ),
    );
  }

  Widget _buildBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1565C0) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade600,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSymbol() {
    return Text(
      symbol,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: symbolColor,
      ),
    );
  }
}
