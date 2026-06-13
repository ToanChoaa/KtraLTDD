// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/player_info.dart';
import '../widgets/result_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    // Khôi phục ván cờ đã lưu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Cờ Caro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, child) {
          // Hiển thị dialog khi ván cờ kết thúc
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndShowDialog(context, provider);
          });

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const PlayerInfo(),
                _buildTurnIndicator(provider.state),
                const SizedBox(height: 8),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: GameBoard(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRestartButton(context, provider),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _checkAndShowDialog(BuildContext context, GameProvider provider) {
    final status = provider.state.status;
    if (status != GameStatus.playing && !_dialogShown) {
      _dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ResultDialog(
          status: status,
          onRestart: () {
            _dialogShown = false;
            provider.resetGame();
          },
        ),
      );
    }
    // Reset flag nếu ván cờ đang chơi
    if (status == GameStatus.playing) {
      _dialogShown = false;
    }
  }

  Widget _buildTurnIndicator(GameState state) {
    if (state.status != GameStatus.playing) return const SizedBox.shrink();

    final text = state.isPlayerTurn
        ? '🎯 Lượt của bạn (X)'
        : '🤖 AI đang suy nghĩ...';
    final color =
        state.isPlayerTurn ? const Color(0xFF1565C0) : const Color(0xFFD32F2F);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(state.isPlayerTurn),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRestartButton(BuildContext context, GameProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _dialogShown = false;
            provider.resetGame();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: const Text(
            'CHƠI LẠI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
