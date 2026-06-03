import 'package:flutter/material.dart';
import '../services/ad_service.dart';

/// A button that shows a rewarded ad and calls [onRewarded] on success.
/// Displays a loading indicator while the ad is loading/showing.
///
/// Ad flows:
///   - Sudoku hint: "광고 보고 힌트 받기" → +1 hint
///   - Sudoku mistake: "광고 보고 계속하기" → +1 mistake chance
class RewardedAdButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onRewarded;
  final VoidCallback? onFailed;

  const RewardedAdButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onRewarded,
    this.onFailed,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _loading = false;

  Future<void> _onTap() async {
    if (_loading) return;
    setState(() => _loading = true);

    final rewarded = await AdService.instance.showRewardedAd();

    if (!mounted) return;
    setState(() => _loading = false);

    if (rewarded) {
      widget.onRewarded();
    } else {
      widget.onFailed?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해 주세요.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _onTap,
        icon: _loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: widget.color),
              )
            : Icon(widget.icon, size: 18, color: widget.color),
        label: Text(
          _loading ? '광고 로딩 중...' : widget.label,
          style: TextStyle(color: widget.color),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: widget.color.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
