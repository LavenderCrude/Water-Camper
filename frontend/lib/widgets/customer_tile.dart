import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showPending;

  const CustomerTile({
    super.key,
    required this.customer,
    this.trailing,
    this.onTap,
    this.showPending = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(customer.phone),
                  const SizedBox(height: 2),
                  Text(
                    customer.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showPending && customer.pendingAmount > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Pending: ₹${customer.pendingAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (trailing != null)
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 170,
                ),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
