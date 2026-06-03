import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Map<int, int> remainingCounts; // how many of each digit still needed
  final void Function(int) onNumber;
  final VoidCallback onErase;
  final VoidCallback onUndo;
  final VoidCallback onHint;
  final VoidCallback onToggleMode;
  final bool isNoteMode;
  final int hintsLeft;
  final bool canUndo;

  const NumberPad({
    super.key,
    required this.remainingCounts,
    required this.onNumber,
    required this.onErase,
    required this.onUndo,
    required this.onHint,
    required this.onToggleMode,
    required this.isNoteMode,
    required this.hintsLeft,
    required this.canUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              icon: Icons.undo_rounded,
              label: '되돌리기',
              onTap: canUndo ? onUndo : null,
            ),
            _ActionButton(
              icon: isNoteMode ? Icons.edit_rounded : Icons.edit_off_rounded,
              label: isNoteMode ? '메모 ON' : '메모 OFF',
              onTap: onToggleMode,
              active: isNoteMode,
            ),
            _ActionButton(
              icon: Icons.lightbulb_rounded,
              label: '힌트 $hintsLeft',
              onTap: hintsLeft > 0 ? onHint : null,
              active: false,
            ),
            _ActionButton(
              icon: Icons.backspace_outlined,
              label: '지우기',
              onTap: onErase,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Number row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(9, (i) {
            final n = i + 1;
            final remaining = remainingCounts[n] ?? 0;
            return _NumberButton(
              number: n,
              remaining: remaining,
              onTap: remaining > 0 ? () => onNumber(n) : null,
            );
          }),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF7B61FF).withOpacity(0.2)
                    : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? const Color(0xFF7B61FF) : Colors.white12,
                ),
              ),
              child: Icon(icon,
                  color: active ? const Color(0xFF7B61FF) : Colors.white70,
                  size: 20),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  color: active ? const Color(0xFF7B61FF) : Colors.white54,
                )),
          ],
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final int remaining;
  final VoidCallback? onTap;

  const _NumberButton({
    required this.number,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.25,
        child: Container(
          width: 34,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$number',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$remaining',
                style: const TextStyle(fontSize: 9, color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
