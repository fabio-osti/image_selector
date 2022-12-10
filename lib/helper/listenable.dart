typedef Unlisten = Function();

class _Listenable<T> {
  _Listenable(T obj) : _object = obj;

  update(Function(T) fn) {
    fn(_object);
    _sing();
  }

  T _object;
  T get() => _object;
  
  int key = 0;
  final Map<int, Function()> _listeners = {};

  _sing() {
    _listeners.forEach((key, value) {
      value();
    });
  }

  Unlisten listen(Function() listener) {
    final listenerKey = key++;
    _listeners[listenerKey] = listener;
    return () {
      _listeners.remove(listenerKey);
    };
  }
}

class ImutableListenable<T> extends _Listenable<T> {
  ImutableListenable(T obj) : super(obj);
}

class MutableListenable<T> extends _Listenable<T> {
  MutableListenable(T obj) : super(obj);

  void set(T obj) {
    super._object = obj;
    super._sing();
  }
}