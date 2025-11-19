// chatbot_screen.dart
import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your Sky Health assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Simulate bot response
    _simulateBotResponse(_messageController.text);
    _messageController.clear();
  }

  void _simulateBotResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 1), () {
      String response = _generateResponse(userMessage);
      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    });
  }

  String _generateResponse(String userMessage) {
    userMessage = userMessage.toLowerCase();
    
    if (userMessage.contains('appointment') || userMessage.contains('book')) {
      return "I can help you book an appointment! You can use the 'Book an Appointment' card on the home screen to schedule with our specialists.";
    } else if (userMessage.contains('medicine') || userMessage.contains('prescription')) {
      return "For medicine and prescription management, please visit the 'My Medicine' or 'Prescriptions' sections in the app.";
    } else if (userMessage.contains('symptom') || userMessage.contains('pain')) {
      return "I'm here to help, but please remember I'm an AI assistant. For medical symptoms or emergencies, please consult with a healthcare professional immediately.";
    } else if (userMessage.contains('hello') || userMessage.contains('hi')) {
      return "Hello! Welcome to Sky Health. How can I assist you with your health needs today?";
    } else {
      return "Thank you for your message. I'm here to help with your health-related queries. You can ask me about appointments, medicines, or general health information.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isUser: message.isUser,
                  timestamp: message.timestamp,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFf8f9fa),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF3498db),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF3498db),
              child: Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 18,
              ),
              radius: 16,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF3498db) : const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF2c3e50),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isUser ? Colors.white70 : const Color(0xFF7f8c8d),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF2ecc71),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
              radius: 16,
            ),
        ],
      ),
    );
  }
}
