import 'dart:io';
import 'package:flutter/material.dart';

/// Screen that mimics Locket's post-capture "Send to…" UI.
/// Use: Navigator.push(context, MaterialPageRoute(
///   builder: (_) => SendToScreen(imagePath: file.path),
/// ));
class SendToScreen extends StatefulWidget {
  final String imagePath;
  final List<Recipient> initialRecipients;
  const SendToScreen({
    super.key,
    required this.imagePath,
    this.initialRecipients = const [],
  });

  @override
  State<SendToScreen> createState() => _SendToScreenState();
}

class _SendToScreenState extends State<SendToScreen> {
  String? _message;
  final List<Recipient> _allRecipients = [
    const Recipient(id: 'all', name: 'All', avatarUrl: null, isAll: true),
    const Recipient(id: 't', name: 'T', avatarUrl: null),
    const Recipient(id: 'h', name: 'H', avatarUrl: null),
    const Recipient(id: 'k', name: 'K', avatarUrl: null),
    const Recipient(id: 'm', name: 'M', avatarUrl: null),
  ];
  Set<String> _selected = {'all'}; // default All

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipients.isNotEmpty) {
      _selected = widget.initialRecipients.map((e) => e.id).toSet();
      if (_selected.length > 1) _selected.remove('all');
    }
  }

  void _toggleRecipient(Recipient r) {
    setState(() {
      if (r.isAll) {
        _selected = {'all'};
        return;
      }
      if (_selected.contains(r.id)) {
        _selected.remove(r.id);
      } else {
        _selected.add(r.id);
      }
      _selected.remove('all');
      if (_selected.isEmpty) _selected = {'all'}; // never empty
    });
  }

  Future<void> _editMessage() async {
    final controller = TextEditingController(text: _message);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a message',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLength: 140,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  counterStyle: const TextStyle(color: Colors.white54),
                  hintText: 'Say something…',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(
                    ctx,
                    controller.text.trim().isEmpty
                        ? null
                        : controller.text.trim(),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _message = result);
  }

  Future<void> _send() async {
    // TODO: upload file at widget.imagePath and send to _selected recipients with optional _message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sent to ${_selected.contains('all') ? 'All' : _selected.length.toString() + ' friend(s)'}' +
              (_message != null ? ' with message' : ''),
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    'Send to…',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Save',
                    onPressed: () {
                      /* TODO: save to device */
                    },
                    icon: const Icon(
                      Icons.download_outlined,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Preview card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(widget.imagePath), fit: BoxFit.cover),

                      // Message pill pinned to bottom center like Locket
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 14,
                        child: Center(
                          child: GestureDetector(
                            onTap: _editMessage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF80755F,
                                ).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _message == null || _message!.isEmpty
                                    ? 'Add a message'
                                    : _message!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            // Dots (single item example)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final active = i == 2; // center active
                return Container(
                  width: active ? 8 : 6,
                  height: active ? 8 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            const Spacer(),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 12,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundIcon(
                        icon: Icons.close,
                        onTap: () => Navigator.pop(context),
                      ),
                      _PrimaryAction(icon: Icons.send_rounded, onTap: _send),
                      _RoundIcon(
                        icon: Icons.text_fields_outlined,
                        onTap: _editMessage,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Recipients row
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (_, i) {
                        final r = _allRecipients[i];
                        final selected = _selected.contains(r.id);
                        return _RecipientChip(
                          recipient: r,
                          selected: selected,
                          onTap: () => _toggleRecipient(r),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: _allRecipients.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Recipient {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isAll;
  const Recipient({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isAll = false,
  });
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIcon({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PrimaryAction({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}

class _RecipientChip extends StatelessWidget {
  final Recipient recipient;
  final bool selected;
  final VoidCallback? onTap;
  const _RecipientChip({
    required this.recipient,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = recipient.isAll ? 'All' : recipient.name;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.amber : Colors.white24,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white12,
              backgroundImage: recipient.avatarUrl != null
                  ? NetworkImage(recipient.avatarUrl!)
                  : null,
              child: recipient.avatarUrl == null
                  ? Text(
                      label.characters.first,
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.amber : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
