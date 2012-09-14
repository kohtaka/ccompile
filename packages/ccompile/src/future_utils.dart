class FutureUtils {
  static Future fromSync(Function sync) {
    var completer = new Completer();
    new Timer(0, (timer) => completer.complete(sync()));
    return completer.future;
  }
}
