import 'package:flutter/material.dart';
import 'styles/app_theme.dart';
import 'styles/styles.dart';

class SecureChatPage extends StatelessWidget {
  const SecureChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _ChatItem("Officer Martinez", "Confirmed. En route to location.", "OM", 2, true),
      _ChatItem("Officer Chen", "Suspect apprehended.", "OC", 0, false),
      _ChatItem("Dispatch Central", "New assignment available.", "DC", 1, false),
      _ChatItem("Officer Taylor", "Copy that. Standing by.", "OT", 0, false),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Chat')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => _ChatTile(items[i]),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemCount: items.length,
      ),
    );
  }
}

class _ChatItem {
  final String name, last, initials;
  final int unread;
  final bool selected;
  const _ChatItem(this.name, this.last, this.initials, this.unread, this.selected);
}

class _ChatTile extends StatelessWidget {
  final _ChatItem item;
  const _ChatTile(this.item);

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      border: item.selected,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE5E7EB),
            child: Text(
              item.initials,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                const SizedBox(height: 2),
                Text(item.last, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (item.unread > 0) AppBadge('${item.unread}'),
        ],
      ),
    );
  }
}