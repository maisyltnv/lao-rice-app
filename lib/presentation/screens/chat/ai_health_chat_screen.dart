import 'package:flutter/material.dart';

/// Mock conversational UI for an on-device health assistant.
class AiHealthChatScreen extends StatefulWidget {
  const AiHealthChatScreen({super.key});

  @override
  State<AiHealthChatScreen> createState() => _AiHealthChatScreenState();
}

class _AiHealthChatScreenState extends State<AiHealthChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_ChatMsg>[
    const _ChatMsg(
      text:
          'ສະບາຍດີ! ຂ້ອຍເປັນຜູ້ຊ່ວຍສຸຂະພາບແບບຈຳລອງ. ຖາມກ່ຽວກັບຜິວໜັງ, ວິຕາມິນ, ຫຼື ການດູແລຕົວທ່ານໄດ້ເລີຍ.',
      fromUser: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(text: t, fromUser: true));
      _messages.add(
        const _ChatMsg(
          text: 'ຂໍຂອບໃຈ! ຟີເຈີນີ້ກຳລັງພັດທະນາ — ຄຳຕອບຈິງຈະເຊື່ອມກັບ AI ພາຍຫຼັງ.',
          fromUser: false,
        ),
      );
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final m = _messages[i];
              final align = m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
              final bg = m.fromUser ? scheme.primaryContainer : scheme.surfaceContainerHighest;
              final fg = m.fromUser ? scheme.onPrimaryContainer : scheme.onSurface;
              return Align(
                alignment: align,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(m.fromUser ? 16 : 4),
                      bottomRight: Radius.circular(m.fromUser ? 4 : 16),
                    ),
                  ),
                  child: Text(m.text, style: TextStyle(color: fg, height: 1.35)),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'ພິມຄຳຖາມຂອງທ່ານ…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _send,
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatMsg {
  const _ChatMsg({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;
}
