import 'package:flutter/material.dart';

class CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onTap;

  const CounterRow({
    super.key,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              _CounterButton(icon: Icons.remove, onPressed: onDecrement),
              Container(
                width: 48,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              _CounterButton(
                  icon: Icons.add, onPressed: onIncrement, primary: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  const _CounterButton({
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: primary
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class BigCounter extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int>? onValueChanged;

  const BigCounter({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CounterButton(
          icon: Icons.remove,
          onPressed: onDecrement,
        ),
        const SizedBox(width: 24),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final controller = TextEditingController(text: value.toString());

            final result = await showDialog<int>(
              context: context,
              builder: (context) => AlertDialog(
                scrollable: true,
                title: const Text("Enter Count"),
                content: SingleChildScrollView(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter number",
                    ),
                    onSubmitted: (value) {
                      final number = int.tryParse(value);
                      Navigator.pop(context, number ?? 0);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  FilledButton(
                    onPressed: () {
                      final number = int.tryParse(controller.text);
                      Navigator.pop(context, number == null ? value : number);
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );

            if (result != null && onValueChanged != null) {
              onValueChanged!(result);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        _CounterButton(
          icon: Icons.add,
          onPressed: onIncrement,
          primary: true,
        ),
      ],
    );
  }
}
