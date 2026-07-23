import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App 内跨页面、跨模块的低频业务事件基类。
abstract class AppEvent {
  const AppEvent();
}

/// 事件消息回调。
typedef AppEventCallback<T extends AppEvent> = void Function(T event);

/// 事件订阅基类。
abstract class AppEventSubscriber<T extends AppEvent> {
  Type get eventType => T;

  void onReceive(T event);
}

/// 带可开关回调的事件订阅者。
abstract class AppEventHandleSubscriber<T extends AppEvent>
    extends AppEventSubscriber<T> {
  AppEventCallback<T>? _listener;

  void on(AppEventCallback<T> callback) {
    _listener = callback;
  }

  void off() {
    _listener = null;
  }

  @override
  void onReceive(T event) {
    _listener?.call(event);
  }

  void dispose() {
    off();
  }
}

/// App 通用事件总线。
final class AppEventBus {
  AppEventBus();

  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast(sync: true);
  final Map<Type, List<AppEventSubscriber>> _subscribers =
      <Type, List<AppEventSubscriber>>{};

  Stream<T> on<T extends AppEvent>() {
    return _controller.stream
        .where((event) => event.runtimeType == T)
        .cast<T>();
  }

  StreamSubscription<T> listen<T extends AppEvent>(AppEventCallback<T> onData) {
    return on<T>().listen(onData);
  }

  void subscribe<T extends AppEvent>(AppEventSubscriber<T> subscriber) {
    final subscribers = _subscribers.putIfAbsent(
      subscriber.eventType,
      () => <AppEventSubscriber>[],
    );
    if (!subscribers.contains(subscriber)) {
      subscribers.add(subscriber);
    }
  }

  bool unsubscribe<T extends AppEvent>(AppEventSubscriber<T> subscriber) {
    final subscribers = _subscribers[subscriber.eventType];
    if (subscribers == null) return false;
    final removed = subscribers.remove(subscriber);
    if (subscribers.isEmpty) {
      _subscribers.remove(subscriber.eventType);
    }
    return removed;
  }

  void emit(AppEvent event) {
    final subscribers = List<AppEventSubscriber>.of(
      _subscribers[event.runtimeType] ?? const <AppEventSubscriber>[],
    );
    for (final subscriber in subscribers) {
      subscriber.onReceive(event);
    }
    _controller.add(event);
  }

  void post(AppEvent event) {
    emit(event);
  }

  void clear() {
    _subscribers.clear();
  }

  void dispose() {
    clear();
    unawaited(_controller.close());
  }
}

final appEventBusProvider = Provider<AppEventBus>((ref) {
  final eventBus = AppEventBus();
  ref.onDispose(eventBus.dispose);
  return eventBus;
});
