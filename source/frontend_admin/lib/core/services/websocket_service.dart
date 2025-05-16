import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../config/api_config.dart';
import '../../models/message_model.dart';

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
      print("WebSocket already connected.");
      return;
    }

    if (_stompClient != null) {
      _stompClient!.deactivate();
    }
    
    String wsUrl = ApiConfig.websocketUrl;

    Map<String, String> connectHeaders = {};
    if (token != null && token.isNotEmpty) {
      connectHeaders['Authorization'] = 'Bearer $token';
      print('Connecting WebSocket with Authorization header.');
    } else {
      print('Warning: Attempting to connect WebSocket without an auth token.');
    }
    
    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) {
          print('WebSocket Error: $error');
        },
        onDisconnect: (StompFrame frame) {
          print('WebSocket disconnected: ${frame.body}');
        },
        onStompError: (StompFrame frame) {
          print('STOMP error: ${frame.body}');
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
    print('WebSocket connected');
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
  
  void subscribeToAdminMessages(String adminId, String userId, Function(Message) onMessageReceived) {
    String topic = '/topic/admin-messages/$adminId/$userId';
    
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
            Map<String, dynamic> response = json.decode(frame.body!);
            Message message = Message.fromMap(response);
            
            if (_messageHandlers[topic] != null) {
              for (var handler in _messageHandlers[topic]!) {
                handler(message);
              }
            }
          }
        },
      );
    }
  }
  
  void subscribeToMessageRead(String adminId, String userId, Function(String) onMessageRead) {
    String topic = '/topic/messages/read/$userId/$adminId';
    
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
  
  void subscribeToMessageDeleted(String adminId, String userId, Function(String) onMessageDeleted) {
    String topic = '/topic/messages/deleted/$userId/$adminId';
    
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
  
  void unsubscribeFromAdminMessages(String adminId, String userId, [Function(Message)? handler]) {
    String topic = '/topic/admin-messages/$adminId/$userId';
    
    if (handler != null && _messageHandlers[topic] != null) {
      _messageHandlers[topic]!.remove(handler);
    } else {
      _messageHandlers.remove(topic);
    }
  }
  
  void unsubscribeFromMessageRead(String adminId, String userId, [Function(String)? handler]) {
    String topic = '/topic/messages/read/$userId/$adminId';
    
    if (handler != null && _messageReadHandlers[topic] != null) {
      _messageReadHandlers[topic]!.remove(handler);
    } else {
      _messageReadHandlers.remove(topic);
    }
  }
  
  void unsubscribeFromMessageDeleted(String adminId, String userId, [Function(String)? handler]) {
    String topic = '/topic/messages/deleted/$userId/$adminId';
    
    if (handler != null && _messageDeletedHandlers[topic] != null) {
      _messageDeletedHandlers[topic]!.remove(handler);
    } else {
      _messageDeletedHandlers.remove(topic);
    }
  }
  
  void sendMessage(String adminId, String userId, Message message) {
    if (_stompClient?.connected ?? false) {
      _stompClient!.send(
        destination: '/app/chat/$userId/$adminId',
        body: json.encode(message.toMap()),
      );
    }
  }
  
  void disconnect() {
    _stompClient?.deactivate();
  }
  
  void dispose() {
    _messageHandlers.clear();
    _messageReadHandlers.clear();
    _messageDeletedHandlers.clear();
    disconnect();
  }
} 