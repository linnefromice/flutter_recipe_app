import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/ingredient_item.dart';

class IngredientInputTile extends StatefulWidget {
  final IngredientItem ingredient;
  final ValueChanged<double> onChanged;

  const IngredientInputTile({
    super.key,
    required this.ingredient,
    required this.onChanged,
  });

  @override
  State<IngredientInputTile> createState() => _IngredientInputTileState();
}

class _IngredientInputTileState extends State<IngredientInputTile> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatAmount(widget.ingredient.currentAmount),
    );
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(IngredientInputTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update text when NOT focused, to prevent cursor jumping
    if (!_hasFocus &&
        widget.ingredient.currentAmount !=
            oldWidget.ingredient.currentAmount) {
      _controller.text = _formatAmount(widget.ingredient.currentAmount);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(widget.ingredient.name,
                style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                suffixText: widget.ingredient.unit,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed > 0) {
                  widget.onChanged(parsed);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              '(${_formatAmount(widget.ingredient.baseAmount)})',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
