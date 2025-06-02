import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class BookingStatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const BookingStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: statusData.backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: statusData.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusData.icon,
            size: isCompact ? 12 : 14,
            color: statusData.textColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusData.displayText,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: statusData.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusData _getStatusData(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusData(
          displayText: 'Pending',
          icon: Icons.schedule,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          textColor: Colors.orange.shade700,
        );
      case 'confirmed':
        return _StatusData(
          displayText: 'Confirmed',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          textColor: Colors.green.shade700,
        );
      case 'cancelled':
        return _StatusData(
          displayText: 'Cancelled',
          icon: Icons.cancel,
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          textColor: Colors.red.shade700,
        );
      case 'completed':
        return _StatusData(
          displayText: 'Completed',
          icon: Icons.done_all,
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          textColor: Colors.blue.shade700,
        );
      default:
        return _StatusData(
          displayText: status,
          icon: Icons.help_outline,
          backgroundColor: Colors.grey.shade50,
          borderColor: Colors.grey.shade200,
          textColor: Colors.grey.shade700,
        );
    }
  }
}

class _StatusData {
  final String displayText;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  _StatusData({
    required this.displayText,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
