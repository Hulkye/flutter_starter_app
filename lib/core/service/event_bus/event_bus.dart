/// 事件消息基类。
abstract class EventMsg {}

/// 事件消息回调。
typedef EventMsgCallback<T extends EventMsg> = void Function(T msg);

/// 事件订阅基类。
abstract class EventSubscriber<T extends EventMsg> {
  EventSubscriber() {
    AppEventBus.subscribe(this);
  }

  Type get eventType => T;

  void onReceive(T msg);

  void dispose() {
    AppEventBus.unsubscribe(this);
  }
}

/// 带可开关回调的事件订阅者。
abstract class EventHandleSubscriber<T extends EventMsg>
    extends EventSubscriber<T> {
  EventHandleSubscriber() : super();

  EventMsgCallback<T>? _listener;

  void on(EventMsgCallback<T> callback) {
    _listener = callback;
  }

  void off() {
    _listener = null;
  }

  @override
  void onReceive(T msg) {
    _listener?.call(msg);
  }

  @override
  void dispose() {
    off();
    super.dispose();
  }
}

/// 简单同步事件总线，用于模块间低频解耦通知。
class AppEventBus {
  AppEventBus._();

  static final List<EventSubscriber> _subscribers = <EventSubscriber>[];

  static void subscribe(EventSubscriber subscriber) {
    if (!_subscribers.contains(subscriber)) {
      _subscribers.add(subscriber);
    }
  }

  static bool unsubscribe(EventSubscriber subscriber) {
    return _subscribers.remove(subscriber);
  }

  static void post(EventMsg? msg) {
    if (msg == null) {
      return;
    }
    final snapshot = List<EventSubscriber>.of(_subscribers);
    for (final subscriber in snapshot) {
      if (msg.runtimeType == subscriber.eventType) {
        subscriber.onReceive(msg);
      }
    }
  }

  static void clear() {
    _subscribers.clear();
  }
}
