import 'package:flutter/material.dart';
import 'styles/app_theme.dart';
import 'styles/styles.dart';

/// ---------- Navy palette ----------
const kNavy900 = Color(0xFF0B1E3C); // กรมเข้มมาก
const kNavy850 = Color(0xFF0E2249); // การ์ดหลัก
const kNavy800 = Color(0xFF102A56); // บับเบิลของคนอื่น
const kBlue700 = Color(0xFF1D4ED8); // บับเบิลของเรา
const kBlueRing = Color(0xFF2563EB); // เส้นขอบเวลาถูกเลือก

class SecureChatPage extends StatefulWidget {
  const SecureChatPage({super.key});

  @override
  State<SecureChatPage> createState() => _SecureChatPageState();
}

class _SecureChatPageState extends State<SecureChatPage> {
  final _searchCtrl = TextEditingController();

  final List<_ChatItem> _allItems = const [
    _ChatItem("Officer Martinez", "Confirmed. En route to location.", "OM", 2, true),
    _ChatItem("Officer Chen", "Suspect apprehended.", "OC", 0, false),
    _ChatItem("Dispatch Central", "New assignment available.", "DC", 1, false),
    _ChatItem("Officer Taylor", "Copy that. Standing by.", "OT", 0, false),
  ];

  bool _unreadOnly = false;
  String _sort = 'recent';
  late List<_ChatItem> _visible;

  @override
  void initState() {
    super.initState();
    _visible = List.of(_allItems);
  }

  void _applySearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _visible = _allItems.where((e) {
        final hit = e.name.toLowerCase().contains(q) || e.last.toLowerCase().contains(q);
        final passUnread = !_unreadOnly || e.unread > 0;
        return hit && passUnread;
      }).toList();

      if (_sort == 'alpha') {
        _visible.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sort == 'unread') {
        _visible.sort((b, a) => a.unread.compareTo(b.unread)); // desc
      }
    });
  }

  Future<void> _openFilterSheet() async {
    bool unreadOnly = _unreadOnly;
    String sort = _sort;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Unread only'),
                value: unreadOnly,
                onChanged: (v) => setState(() => unreadOnly = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: sort,
                    items: const [
                      DropdownMenuItem(value: 'recent', child: Text('Recent')),
                      DropdownMenuItem(value: 'unread', child: Text('Unread (desc)')),
                      DropdownMenuItem(value: 'alpha', child: Text('Name (A–Z)')),
                    ],
                    onChanged: (v) => setState(() => sort = v ?? 'recent'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _unreadOnly = unreadOnly;
                      _sort = sort;
                    });
                    _applySearch();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goGroupChat(String roomName) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => GroupChatPage(roomName: roomName)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Chat')),
      body: Column(
        children: [
          // --- Top search + filter ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => _applySearch(),
                    onSubmitted: (_) => _applySearch(),
                    decoration: InputDecoration(
                      hintText: 'Search chats, names, messages…',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _openFilterSheet,
                  icon: const Icon(Icons.tune),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kBlueRing,
                    side: const BorderSide(color: kBlueRing),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // --- List ---
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _goGroupChat(_visible[i].name),
                child: _ChatTile(_visible[i]),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemCount: _visible.length,
            ),
          ),
        ],
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

/// การ์ดพื้นสีน้ำเงินกรม (แทน DarkCard เพื่อคุมสีชัดเจน)
class _NavyCard extends StatelessWidget {
  final Widget child;
  final bool border;
  final EdgeInsets padding;
  const _NavyCard({required this.child, this.border = false, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kNavy850,
        borderRadius: BorderRadius.circular(20),
        border: border ? Border.all(color: kBlueRing, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final _ChatItem item;
  const _ChatTile(this.item);

  @override
  Widget build(BuildContext context) {
    return _NavyCard(
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
                Text(item.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(item.last,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          if (item.unread > 0) AppBadge('${item.unread}'),
        ],
      ),
    );
  }
}

/// ---------------------- Group Chat Page ----------------------
class GroupChatPage extends StatefulWidget {
  final String roomName;
  const GroupChatPage({super.key, required this.roomName});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final _msgCtrl = TextEditingController();
  final List<_Msg> _messages = const [
    _Msg('OM', 'Martinez', 'Arrived at site.', '10:02'),
    _Msg('OC', 'Chen', 'Secured entrance.', '10:03'),
    _Msg('DC', 'Dispatch', 'Backup en route.', '10:04'),
  ];

  void _send() {
    final t = _msgCtrl.text.trim();
    if (t.isEmpty) return;
    final now = TimeOfDay.now();
    setState(() {
      _messages.add(_Msg(
        'YOU',
        'You',
        t,
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ));
    });
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group Chat • ${widget.roomName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isMe = m.initials == 'YOU';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isMe)
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFE5E7EB),
                          child: Text(m.initials,
                              style: const TextStyle(
                                  color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? kBlue700 : kNavy800, // ← เปลี่ยนเป็นน้ำเงินกรม
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(m.sender, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text(m.text, style: const TextStyle(color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(m.time, style: const TextStyle(fontSize: 11, color: Colors.white60)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isMe)
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFE5E7EB),
                          child: Text('YOU',
                              style: TextStyle(
                                  color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 10)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // composer
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        isDense: true,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _send, child: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String initials;
  final String sender;
  final String text;
  final String time;
  const _Msg(this.initials, this.sender, this.text, this.time);
}
