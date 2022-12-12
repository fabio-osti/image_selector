typedef Unlisten = Function();

abstract class Listenable<T> {
  Listenable(this._value);

  update(Function(T) fn) {
    fn(_value);
    _sing();
  }

  T _value;
  
  int _nextListenerKey = 0;
  final Map<int, Function()> _listeners = {};

  _sing() {
    _listeners.forEach((key, value) {
      value();
    });
  }

  Unlisten listen(Function() listener) {
    var listenerKey = _nextListenerKey;
    while(_listeners.containsKey(listenerKey)) {
      listenerKey = _nextListenerKey++;
    }
    
    _listeners[listenerKey] = listener;
    return () {
      _listeners.remove(listenerKey);
    };
  }
}

class ImutableListenable<T> extends Listenable<T> {
  ImutableListenable(T obj) : super(obj);

  T get value => _value;
}

class MutableListenable<T> extends Listenable<T> {
  MutableListenable(T obj) : super(obj);

  T get value => _value;
  set value(T obj) {
    super._value = obj;
    super._sing();
  }
}