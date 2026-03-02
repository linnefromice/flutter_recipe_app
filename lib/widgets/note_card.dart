import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/adjustment_note.dart';

class NoteCard extends StatelessWidget {
  final AdjustmentNote note;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          note.title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              'x${note.ratio.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dateFormat.format(note.createdAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...note.items.map((i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        '${i.name}: ${_formatAmount(i.baseAmount)} → ${_formatAmount(i.adjustedAmount)} ${i.unit}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )),
                if (note.memo.isNotEmpty) ...[
                  const Divider(height: 16),
                  Text(note.memo, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }
}
