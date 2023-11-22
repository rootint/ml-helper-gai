import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ChatView(),
              ),
            ),
            BottomTextField(),
          ],
        ),
      ),
    );
  }
}

class BottomTextField extends StatefulWidget {
  const BottomTextField({super.key});

  @override
  State<BottomTextField> createState() => _BottomTextFieldState();
}

class _BottomTextFieldState extends State<BottomTextField> {
  final controller = TextEditingController();
  bool _buttonDisabled = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    controller.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x4D555555)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  hintText: 'Message...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0x1DFFFFFF),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xDDFFFFFF),
                      width: 1,
                    ),
                  ),
                  hintStyle: const TextStyle(
                    color: Color(0x4DFFFFFF),
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                onChanged: (val) {
                  if (val == '') {
                    setState(() {
                      _buttonDisabled = true;
                    });
                  } else {
                    setState(() {
                      _buttonDisabled = false;
                    });
                  }
                },
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
                cursorColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      _buttonDisabled ? const Color(0x55FFFFFF) : const Color(0xDDFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(11),
                  child: Icon(
                    CupertinoIcons.arrow_up,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView();
  }
}
