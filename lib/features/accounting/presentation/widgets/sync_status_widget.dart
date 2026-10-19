import 'package:flutter/material.dart';

enum SyncState { synced, syncing, offlinePending, failed }

class SyncStatusWidget extends StatefulWidget {
  final SyncState syncState;
  final int pendingCount;
  final String? lastSyncedAt;
  final VoidCallback onSyncPressed;

  const SyncStatusWidget({
    super.key,
    required this.syncState,
    required this.pendingCount,
    this.lastSyncedAt,
    required this.onSyncPressed,
  });

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.syncState == SyncState.syncing) {
      _spinController.repeat();
    }
  }

  @override
  void didUpdateWidget(SyncStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.syncState == SyncState.syncing) {
      _spinController.repeat();
    } else {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    Color statusColor;
    String tooltipText;

    switch (widget.syncState) {
      case SyncState.synced:
        iconWidget = const Icon(Icons.cloud_done, color: Colors.green);
        statusColor = Colors.green;
        tooltipText = 'All changes synced to cloud';
        break;
      case SyncState.syncing:
        iconWidget = RotationTransition(
          turns: _spinController,
          child: const Icon(Icons.sync, color: Colors.orange),
        );
        statusColor = Colors.orange;
        tooltipText = 'Syncing outbox queue...';
        break;
      case SyncState.offlinePending:
      case SyncState.failed:
        iconWidget = const Icon(Icons.cloud_off, color: Colors.red);
        statusColor = Colors.red;
        tooltipText = '${widget.pendingCount} pending items waiting for cloud sync';
        break;
    }

    return Tooltip(
      message: tooltipText,
      child: InkWell(
        onTap: widget.syncState == SyncState.syncing ? null : widget.onSyncPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Text(
                widget.syncState == SyncState.synced
                    ? 'Synced'
                    : widget.syncState == SyncState.syncing
                        ? 'Syncing...'
                        : '${widget.pendingCount} Pending',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.refresh, size: 16, color: statusColor),
            ],
          ),
        ),
      ),
    );
  }
}
