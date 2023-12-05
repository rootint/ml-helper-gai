import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neuralearn_flutter/message.dart';
import 'package:neuralearn_flutter/message_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ChatView(),
              ),
            ),
            const BottomTextField(),
          ],
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'NeuraLearn',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'LLaMa 2 Finetuned',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: const Color(0x4D555555),
          ),
        ],
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
    Provider.of<MessageProvider>(context, listen: false)
        .sendAndReceiveAMessage(controller.text);
    controller.text = '';
    setState(() {
      _buttonDisabled = true;
    });
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
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  hintText: 'Message...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0x1DFFFFFF),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xDDFFFFFF),
                      width: 1,
                    ),
                  ),
                  hintStyle: const TextStyle(
                    color: Color(0x6DFFFFFF),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
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
                  fontSize: 16,
                ),
                cursorColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                decoration: BoxDecoration(
                  color: _buttonDisabled
                      ? const Color(0x55FFFFFF) 
                      : const Color(0xDDFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.arrow_up,
                    color: Colors.black,
                    size: 19,
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

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    var messages = Provider.of<MessageProvider>(context).messages;
    var contextLoading = Provider.of<MessageProvider>(context).contextLoading;
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Text(
            'No messages yet!\nYou can ask whatever you want about Machine Learning.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          if (contextLoading && index == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Checking our vector DB...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }
          if (contextLoading) {
            return MessageBubble(
              message: messages[index - 1].message,
              sentByUser: messages[index - 1].sentByUser,
            );
          } else {
            return MessageBubble(
              message: messages[index].message.trim(),
              sentByUser: messages[index].sentByUser,
            );
          }
        },
        reverse: true,
        itemCount: contextLoading ? messages.length + 1 : messages.length,
      );
    }
  }
}

class MessageBubble extends StatelessWidget {
  final bool sentByUser;
  final String message;
  const MessageBubble({
    required this.sentByUser,
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          sentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: sentByUser ? Color(0xFFFFFFFF) : Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                topRight: const Radius.circular(8),
                bottomRight: Radius.circular(sentByUser ? 0 : 8),
                bottomLeft: Radius.circular(sentByUser ? 8 : 0),
              ),
              border: sentByUser
                  ? null
                  : Border.fromBorderSide(
                      BorderSide(
                        color: const Color(0x2AFFFFFF),
                      ),
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                message,
                style: TextStyle(
                  color: sentByUser ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
