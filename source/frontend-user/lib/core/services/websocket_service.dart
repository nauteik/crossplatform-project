import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/models/message_model.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  
  factory WebSocketService() {
    return _instance;
  }
  
  WebSocketService._internal();
  
  StompClient? _stompClient;
  
  final Map<String, List<Function(Message)>> _messageHandlers = {};
  final Map<String, List<Function(String)>> _messageReadHandlers = {};
  final Map<String, List<Function(String)>> _messageDeletedHandlers = {};
  
  bool get isConnected => _stompClient?.connected ?? false;
  
  void connect({String? token}) {
    if (_stompClient != null && _stompClient!.connected) {
      print("User WebSocket already connected.");
      return;
    }

    if (_stompClient != null) {
      _stompClient!.deactivate();
    }
    
    String wsUrl = ApiConstants.websocketUrl; 
    
    Map<String, String> connectHeaders = {};
    if (token != null && token.isNotEmpty) {
      connectHeaders['Authorization'] = 'Bearer $token';
      print('User WebSocket: Connecting with Authorization header.');
    } else {
      print('User WebSocket: Warning - Attempting to connect without an auth token.');
    }
    
    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) {
          print('User WebSocket Error: $error');
        },
        onDisconnect: (StompFrame frame) {
          print('User WebSocket disconnected: ${frame.body}');
        },
        onStompError: (StompFrame frame) {
          print('User STOMP error: ${frame.body}');
        },
        webSocketConnectHeaders: connectHeaders, 
        reconnectDelay: const Duration(milliseconds: 0),
        heartbeatIncoming: const Duration(milliseconds: 10000),
        heartbeatOutgoing: const Duration(milliseconds: 10000),
      ),
    );
    
    _stompClient?.activate();
  }
  
  void _onConnect(StompFrame frame) {
    print('User WebSocket connected');
    for (var topic in _messageHandlers.keys) {
      _subscribeToMessages(topic);
    }
    for (var topic in _messageReadHandlers.keys) {
      _subscribeToMessageRead(topic);
    }
    for (var topic in _messageDeletedHandlers.keys) {
      _subscribeToMessageDeleted(topic);
    }
  }
  
  void subscribeToUserMessages(String userId, String adminId, Function(Message) onMessageReceived) {
    String topic = '/topic/messages/$userId/$adminId';
    print("User WebSocket: Subscribing to $topic");

    if (_messageHandlers[topic] == null) {
      _messageHandlers[topic] = [];
    }
    if (!_messageHandlers[topic]!.contains(onMessageReceived)) {
      _messageHandlers[topic]!.add(onMessageReceived);
    }
    _subscribeToMessages(topic);
  }
  
  void _subscribeToMessages(String topic) {
    if (_stompClient?.connected ?? false) {
      _stompClient!.subscribe(
        destination: topic,
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              Map<String, dynamic> response = json.decode(frame.body!);
              Message message = Message.fromMap(response);
              if (_messageHandlers[topic] != null) {
                for (var handler in _messageHandlers[topic]!) {
                  handler(message);
                }
              }
            } catch (e) {
              print("User WebSocket: Error decoding message from $topic: $e");
              print("Raw message body: ${frame.body}");
            }
          }
        },
      );
    } else {
      print("User WebSocket: Not connected, cannot subscribe to $topic");
    }
  }
  
  void subscribeToMessageRead(String userId, String adminId, Function(String) onMessageRead) {
    String topic = '/topic/messages/read/$userId/$adminId';
    print("User WebSocket: Subscribing to message read on $topic");
    if (_messageReadHandlers[topic] == null) {
      _messageReadHandlers[topic] = [];
    }
    if (!_messageReadHandlers[topic]!.contains(onMessageRead)) {
      _messageReadHandlers[topic]!.add(onMessageRead);
    }
    _subscribeToMessageRead(topic);
  }
  
  void _subscribeToMessageRead(String topic) {
    if (_stompClient?.connected ?? false) {
      _stompClient!.subscribe(
        destination: topic,
        callback: (StompFrame frame) {
          if (frame.body != null) {
            String messageId = frame.body!;
            if (_messageReadHandlers[topic] != null) {
              for (var handler in _messageReadHandlers[topic]!) {
                handler(messageId);
              }
            }
          }
        },
      );
    }
  }
  
  void subscribeToMessageDeleted(String userId, String adminId, Function(String) onMessageDeleted) {
    String topic = '/topic/messages/deleted/$userId/$adminId';
    print("User WebSocket: Subscribing to message deleted on $topic");
    if (_messageDeletedHandlers[topic] == null) {
      _messageDeletedHandlers[topic] = [];
    }
    if (!_messageDeletedHandlers[topic]!.contains(onMessageDeleted)) {
      _messageDeletedHandlers[topic]!.add(onMessageDeleted);
    }
    _subscribeToMessageDeleted(topic);
  }
  
  void _subscribeToMessageDeleted(String topic) {
    if (_stompClient?.connected ?? false) {
      _stompClient!.subscribe(
        destination: topic,
        callback: (StompFrame frame) {
          if (frame.body != null) {
            String messageId = frame.body!;
            if (_messageDeletedHandlers[topic] != null) {
              for (var handler in _messageDeletedHandlers[topic]!) {
                handler(messageId);
              }
            }
          }
        },
      );
    }
  }
  
  void unsubscribeFromUserMessages(String userId, String adminId, [Function(Message)? handler]) {
    String topic = '/topic/messages/$userId/$adminId';
    print("User WebSocket: Unsubscribing from $topic");
    if (handler != null && _messageHandlers[topic] != null) {
      _messageHandlers[topic]!.remove(handler);
    } else {
      _messageHandlers.remove(topic);
    }
  }
  
  void unsubscribeFromMessageRead(String userId, String adminId, [Function(String)? handler]) {
    String topic = '/topic/messages/read/$userId/$adminId';
    if (handler != null && _messageReadHandlers[topic] != null) {
      _messageReadHandlers[topic]!.remove(handler);
    } else {
      _messageReadHandlers.remove(topic);
    }
  }
  
  void unsubscribeFromMessageDeleted(String userId, String adminId, [Function(String)? handler]) {
    String topic = '/topic/messages/deleted/$userId/$adminId';
    if (handler != null && _messageDeletedHandlers[topic] != null) {
      _messageDeletedHandlers[topic]!.remove(handler);
    } else {
      _messageDeletedHandlers.remove(topic);
    }
  }
  
  void sendMessage(String userId, String adminId, Message message) {
    String destination = '/app/chat/$userId/$adminId';
    print("User WebSocket: Sending message to $destination");

    if (_stompClient?.connected ?? false) {
      _stompClient!.send(
        destination: destination,
        body: json.encode(message.toMap()),
      );
    } else {
      print("User WebSocket: Not connected. Cannot send message.");
    }
  }
  
  void disconnect() {
    print("User WebSocket: Deactivating client.");
    _stompClient?.deactivate();
  }
  
  void dispose() {
    print("User WebSocket: Disposing service.");
    _messageHandlers.clear();
    _messageReadHandlers.clear();
    _messageDeletedHandlers.clear();
    disconnect();
  }
} 