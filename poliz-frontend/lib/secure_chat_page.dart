import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ---------- Navy palette ----------
const kNavy900 = Color(0xFF0B1E3C);
const kNavy850 = Color(0xFF0E2249);
const kNavy800 = Color(0xFF102A56);
const kBlue700 = Color(0xFF1D4ED8);
const kBlueRing = Color(0xFF2563EB);

class SecureChatPage extends StatefulWidget {
  final String currentUser;
  const SecureChatPage({super.key, required this.currentUser});

  @override
  State<SecureChatPage> createState() => _SecureChatPageState();
}

class _SecureChatPageState extends State<SecureChatPage> {
  final _searchCtrl = TextEditingController();
  bool _unreadOnly = false;
  String _sort = 'recent';
  List<_ChatItem> _allItems = [];
  List<_ChatItem> _visible = [];

  // ✅ ใช้ localhost (ถ้า Spring Boot รันในเครื่องเดียวกัน)
  final String _baseUrl = 'http://localhost:8080/api/chats';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchChats();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) _fetchChats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchChats() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/users?exclude=${Uri.encodeComponent(widget.currentUser)}'),
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          _allItems = data
              .map((e) => _ChatItem(
                    id: e['id'],
                    name: e['name'],
                    initials: e['initials'],
                    last: e['lastMessage'] ?? 'Say hi 👋',
                    unread: e['unread'] ?? 0,
                  ))
              .toList();
          _applySearch();
        });
      } else {
        debugPrint("⚠️ Failed to fetch chats: ${res.statusCode}");
      }
    } catch (e) {
      if (mounted) debugPrint("❌ Error loading users: $e");
    }
  }

  void _applySearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (!mounted) return;
    setState(() {
      _visible = _allItems.where((e) {
        final hit = e.name.toLowerCase().contains(q);
        final passUnread = !_unreadOnly || e.unread > 0;
        return hit && passUnread;
      }).toList();

      if (_sort == 'alpha') {
        _visible.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sort == 'unread') {
        _visible.sort((b, a) => a.unread.compareTo(b.unread));
      }
    });
  }

  Future<void> _openFilterSheet() async {
    bool unreadOnly = _unreadOnly;
    String sort = _sort;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Filters',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Unread only'),
                  value: unreadOnly,
                  onChanged: (v) => setModalState(() => unreadOnly = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Sort by'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: sort,
                      items: const [
                        DropdownMenuItem(value: 'recent', child: Text('Recent')),
                        DropdownMenuItem(value: 'unread', child: Text('Unread')),
                        DropdownMenuItem(value: 'alpha', child: Text('Name A–Z')),
                      ],
                      onChanged: (v) =>
                          setModalState(() => sort = v ?? 'recent'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(ctx, {'unreadOnly': unreadOnly, 'sort': sort}),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _unreadOnly = result['unreadOnly'];
        _sort = result['sort'];
      });
      _applySearch();
    }
  }

  void _openChat(_ChatItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(
          currentUser: widget.currentUser,
          receiverName: item.name,
        ),
      ),
    );
    // ✅ mark as read หลังกลับจากหน้าห้องแชท
    final receiver = Uri.encodeComponent(item.name);
    try {
      await http.post(Uri.parse('$_baseUrl/${widget.currentUser}/mark-read/$receiver'));
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _fetchChats();
    } catch (e) {
      debugPrint("⚠️ Error marking chat with $receiver as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Secure Chat (${widget.currentUser})')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => _applySearch(),
                    decoration: InputDecoration(
                      hintText: 'Search users…',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.tune),
                  label: const Text('Filter'),
                  onPressed: _openFilterSheet,
                )
              ],
            ),
          ),
          Expanded(
            child: _visible.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final user = _visible[i];
                      return GestureDetector(
                        onTap: () => _openChat(user),
                        child: _ChatTile(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatItem {
  final int id;
  final String name;
  final String initials;
  final String last;
  final int unread;
  const _ChatItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.last,
    required this.unread,
  });
}

class _ChatTile extends StatelessWidget {
  final _ChatItem item;
  const _ChatTile(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kNavy850,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Text(item.initials,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.last,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (item.unread > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: kBlueRing, borderRadius: BorderRadius.circular(12)),
              child: Text('${item.unread}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

/// ------------------ Group Chat Page ------------------
class GroupChatPage extends StatefulWidget {
  final String currentUser;
  final String receiverName;
  const GroupChatPage(
      {super.key, required this.currentUser, required this.receiverName});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final _msgCtrl = TextEditingController();
  final List<_Msg> _messages = [];
  
  // ✅ ใช้ localhost สำหรับเชื่อม backend Spring Boot
  final String _baseUrl = 'http://localhost:8080/api/chats';
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/${widget.currentUser}/${widget.receiverName}/messages'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (!mounted) return;

        final newMessages = data.map((m) => _Msg(
          initials: (m['sender'] == widget.currentUser) ? 'YOU' : m['sender'].substring(0, 2).toUpperCase(),
          sender: m['sender'],
          text: m['text'],
          time: m['time'],
        )).toList();

        setState(() {
          for (final msg in newMessages) {
            if (!_messages.any((old) => old.text == msg.text && old.time == msg.time && old.sender == msg.sender)) {
              _messages.add(msg);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) debugPrint("⚠️ Error loading messages: $e");
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final msg = _Msg(
      initials: 'YOU',
      sender: widget.currentUser,
      text: text,
      time: TimeOfDay.now().format(context),
    );

    setState(() => _messages.add(msg));
    _msgCtrl.clear();

    try {
      await http.post(
        Uri.parse('$_baseUrl/${widget.currentUser}/${widget.receiverName}/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': widget.currentUser,
          'receiver': widget.receiverName,
          'text': text,
          'time': msg.time
        }),
      );
    } catch (e) {
      debugPrint("⚠️ Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat • ${widget.receiverName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isMe = m.initials == 'YOU';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? kBlue700 : kNavy800,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(m.sender, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        Text(m.text, style: const TextStyle(color: Colors.white)),
                        Text(m.time, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ปรับปุ่มให้ disabled ถ้าไม่มีข้อความ
                  FilledButton(
                    onPressed: _msgCtrl.text.isEmpty ? null : _send, // ถ้าไม่มีข้อความจะทำให้ปุ่มไม่สามารถคลิกได้
                    child: const Icon(Icons.send),
                  ),
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
  const _Msg({
    required this.initials,
    required this.sender,
    required this.text,
    required this.time,
  });
}
