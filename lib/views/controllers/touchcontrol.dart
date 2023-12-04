part of views;

class TouchControl {
  List<TouchState> touchStates = [];
  Mutex touchStatesM = Mutex();
  bool flushed = true;
  int writeCounter = 0;
  int curTouchID = 100000;

  TouchControl() {

    // assign random touch ID and hope stuff doesn't interfere
    var rng = new Random();
    curTouchID = 100000 + rng.nextInt(99999);
  }

  Future<void> _flushState() {
    return ConnectionPool.inst.get().then((con) async {
      if (flushed || touchStates.isEmpty || writeCounter > 0) {
        con.free();
        return null;
      }
      var inactiveTouches = <TouchState>[];
      var updatedTouches = <TouchState>[];
      await touchStatesM.protect(() async {
        for (var touchState in touchStates) {
          if (!touchState.active) {
            inactiveTouches.add(touchState);
          } else if (touchState.updated) {
            updatedTouches.add(touchState);
          }
        }
        touchStates.removeWhere((o) => inactiveTouches.contains(o));
        flushed = true;
      });
      writeCounter++;
      return touchWrite(con, updatedTouches).then((e) {
        return touchWriteReset(con, inactiveTouches).then((e) {
          if (!flushed)
            _flushState();
        });
      }).whenComplete(() {
        con.free();
        writeCounter--;
      });
    }, onError: (e) {});
  }

  Future<int> touchDown(int x, int y) async {
    var touchState = TouchState(++curTouchID, x, y);
    touchState.active = true;
    touchState.updated = true;
    await touchStatesM.protect(() async {
      touchStates.add(touchState);
      flushed = false;
    });
    _flushState();
    vibrate();
    return touchState.id;
  }

  Future<void> touchMove(int id, int x, int y) async {
    bool flush = false;
    await touchStatesM.protect(() async {
      for (var touchState in touchStates) {
        if (touchState.id == id) {
          touchState.x = x;
          touchState.y = y;
          touchState.active = true;
          touchState.updated = true;
          flushed = false;
          flush = true;
          break;
        }
      }
    });
    if (flush) _flushState();
  }

  Future<void> touchUp(int id) async {
    bool flush = false;
    await touchStatesM.protect(() async {
      for (var touchState in touchStates) {
        if (touchState.id == id) {
          touchState.active = false;
          touchState.updated = true;
          flushed = false;
          flush = true;
          break;
        }
      }
    });
    if (flush) _flushState();
  }

  Future<void> vibrate() async {
    var vibrationMs = Settings.buttonVibrationDuration.toInt();
    if (vibrationMs > 1) {
      Vibration.vibrate(
          duration: vibrationMs);
    }
  }
}
