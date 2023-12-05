import 'package:flutter/material.dart';
import 'package:neuralearn_flutter/message.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessageProvider extends ChangeNotifier {
  var messages = [];
  var contextLoading = false;

  void sendAndReceiveAMessage(String message) async {
    String partialMessage = '';
    messages.insert(0, Message(message: message, sentByUser: true));
    notifyListeners();
    var request = http.Request(
        'POST', Uri.parse('http://bibatalov.ru:8080/chain'))
      // 'POST', Uri.parse('https://d4f5-188-130-155-160.ngrok-free.app/chain'))
      ..headers.addAll({'Content-Type': 'application/json'})
      ..body = jsonEncode({'prompt': message});
    contextLoading = true;
    notifyListeners();
    var streamedResponse = await request.send();

    streamedResponse.stream.transform(utf8.decoder).listen((value) {
      // Assuming each value is a complete message
      if (partialMessage != '') {
        messages.removeAt(0);
        contextLoading = false;
      }
      partialMessage += value;
      messages.insert(0, Message(message: partialMessage, sentByUser: false));
      notifyListeners();
    }, onError: (error) {
      // Handle errors...
    });
    // var response = await http.post(
    //   Uri.parse('https://4791-188-130-155-160.ngrok-free.app/send'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(<String, String>{
    //     'prompt': message,
    //   }),
    // );
    // messages.insert(
    //     0,
    //     Message(
    //         message: jsonDecode(response.body)['answer'], sentByUser: false));
    // notifyListeners();
  }
}
