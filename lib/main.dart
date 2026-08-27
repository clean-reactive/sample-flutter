import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      letterSpacing: 1.5,
      color: theme.colorScheme.onSurfaceVariant,
    );

    const status = (isProcessing: true, label: 'Processing');
    const resource = (isLocalSelected: true);

    const statistics = [
      (value: '2', label: 'users'),
      (value: '2', label: 'orders'),
      (value: '3', label: 'items'),
      (value: '7', label: 'qty'),
    ];

    const orders = [
      (
        orderId: 'order-a1b2c3',
        userId: 'user-42',
        summaryLabel: '2 items',
        isDeleteOrderButtonDisabled: false,
        items: [
          (
            itemId: 'item-001',
            productId: 'product-77',
            productQuantity: '3',
            isDeleteItemButtonDisabled: false,
          ),
          (
            itemId: 'item-002',
            productId: 'product-91',
            productQuantity: '1',
            isDeleteItemButtonDisabled: false,
          ),
        ],
      ),
      (
        orderId: 'order-d4e5f6',
        userId: 'user-17',
        summaryLabel: '1 item',
        isDeleteOrderButtonDisabled: true,
        items: [
          (
            itemId: 'item-003',
            productId: 'product-12',
            productQuantity: '3',
            isDeleteItemButtonDisabled: true,
          ),
        ],
      ),
    ];

    return MaterialApp(
      title: 'Clean Reactive',
      theme: theme,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // -- title --
                    Text(
                      'ORDERS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // -- resource picker and status --
                    Text('RESOURCE', style: labelStyle),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: true, label: Text('Local')),
                            ButtonSegment(value: false, label: Text('Remote')),
                          ],
                          selected: {resource.isLocalSelected},
                          onSelectionChanged: (_) {},
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status.isProcessing) ...[
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              status.label,
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -- statistics --
                    Text('STATISTICS', style: labelStyle),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final stat in statistics)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  stat.value,
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  stat.label,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -- orders --
                    for (final order in orders) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('ORDER', style: labelStyle),
                                        const SizedBox(height: 4),
                                        Text(
                                          order.orderId,
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'User ${order.userId}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  OutlinedButton(
                                    onPressed: order.isDeleteOrderButtonDisabled
                                        ? null
                                        : () {},
                                    child: const Text('Delete Order'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // -- order items --
                              Theme(
                                data: theme.copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    order.summaryLabel,
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: EdgeInsets.zero,
                                  children: [
                                    for (final item in order.items) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Wrap(
                                                spacing: 24,
                                                runSpacing: 8,
                                                children: [
                                                  for (final field in [
                                                    (
                                                      label: 'ID',
                                                      value: item.itemId,
                                                    ),
                                                    (
                                                      label: 'PRODUCT ID',
                                                      value: item.productId,
                                                    ),
                                                    (
                                                      label: 'QUANTITY',
                                                      value:
                                                          item.productQuantity,
                                                    ),
                                                  ])
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          field.label,
                                                          style: theme
                                                              .textTheme
                                                              .labelSmall
                                                              ?.copyWith(
                                                                letterSpacing:
                                                                    1.2,
                                                                color: theme
                                                                    .colorScheme
                                                                    .onSurfaceVariant,
                                                              ),
                                                        ),
                                                        Text(
                                                          field.value,
                                                          style: theme
                                                              .textTheme
                                                              .bodySmall,
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            OutlinedButton(
                                              onPressed:
                                                  item.isDeleteItemButtonDisabled
                                                  ? null
                                                  : () {},
                                              child: const Text('Delete Item'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
