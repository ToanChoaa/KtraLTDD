// lib/widgets/result_dialog.dart

import 'package:flutter/material.dart';
import '../models/game_state.dart';

class ResultDialog extends StatelessWidget {
  final GameStatus status;
  final VoidCallback onRestart;

  const ResultDialog({
    super.key,
    required this.status,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(config['emoji']!, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              config['title']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              config['subtitle']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRestart();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CHƠI LẠI',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getConfig() {
    switch (status) {
      case GameStatus.playerWin:
        return {
          'emoji': '🏆',
          'title': 'CHÚC MỪNG!',
          'subtitle': 'NGƯỜI CHƠI\nđã chiến thắng.',
        };
      case GameStatus.cpuWin:
        return {
          'emoji': '😟',
          'title': 'BẠN ĐÃ THUA CUỘC!',
          'subtitle': 'AI đã chiến thắng.\nChúc bạn may mắn lần sau!',
        };
      case GameStatus.draw:
        return {
          'emoji': '🤝',
          'title': 'HÒA!',
          'subtitle': 'Không có người thắng.\nHãy thử lại!',
        };
      default:
        return {
          'emoji': '🎮',
          'title': 'KẾT THÚC',
          'subtitle': '',
        };
    }
  }
}
