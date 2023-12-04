part of views;

class ButtonControl {
  final notifier = ValueNotifier<int>(0);
  List<ButtonControlButton> widgets = [];
  List<ButtonState> buttons = [];
  bool buttonsFlushed = true;
  int writeCounter = 0;

  ButtonControl() {

    // get a list of all buttons
    ConnectionPool.inst.get().then((con) {
      buttonsRead(con).then((readButtons) {
        buttons = readButtons;
        for (var button in buttons) {
          button.active = false;
        }
      }).whenComplete(() { con.free(); });
    }, onError: (e) {});
  }

  Future<void> _flushState() {
    return ConnectionPool.inst.get().then((con) {
      if (buttonsFlushed || buttons.isEmpty || writeCounter > 0) {
        con.free();
        return null;
      }
      var activeButtons = <ButtonState>[];
      for (var button in buttons) {
        if (button.active) {
          button.active = false;
          activeButtons.add(button);
        }
      }
      buttonsFlushed = true;
      writeCounter++;
      return buttonsWrite(con, activeButtons).then((e) {
        if (!buttonsFlushed)
          _flushState();
      }).whenComplete(() {
        con.free();
        writeCounter--;
      });
    }, onError: (e) {});
  }

  bool setVelocity(String name, double state) {
    bool flush = false;
    for (var button in buttons) {
      if (button.name == name) {
        if (button.state != state) {
          button.state = state;
          button.active = true;
          buttonsFlushed = false;
          flush = true;
        }
        break;
      }
    }
    if (flush) {
      _flushState();
    }
    return flush;
  }

  void setState(String name, bool state) {
    if (setVelocity(name, state ? 1.0 : 0.0)) {
      vibrate();
    }
  }

  void vibrate() async {
    var vibrationMs = Settings.buttonVibrationDuration.toInt();
    if (vibrationMs > 1) {
      Vibration.vibrate(
          duration: vibrationMs);
    }
  }

  Widget wrapListener(Widget child) {
    return Listener(
      onPointerDown: (p) {
        this.processPointer(p.pointer, p.position, true);
      },
      onPointerMove: (p) {
        this.processPointer(p.pointer, p.position, true);
      },
      onPointerUp: (p) {
        this.processPointer(p.pointer, p.position, false);
      },
      onPointerCancel: (p) {
        this.processPointer(p.pointer, p.position, false);
      },
      child: child,
    );
  }

  void processPointer(var pointer, Offset position, bool down) {
    widgets.forEach((btn) {
      if (btn.key.currentContext == null) {
        if (btn.pointers.isNotEmpty) {
          btn.pointers.clear();
          notifier.value++;
        }
        return;
      };
      RenderBox box = btn.key.currentContext.findRenderObject();
      Offset start = box.localToGlobal(Offset.zero);
      Rect rect = Rect.fromLTWH(
          start.dx, start.dy,
          box.size.width, box.size.height
      );
      bool flush = false;
      if (rect.contains(position)) {
        if (down) {
          if (btn.pointers.add(pointer))
            flush = true;
        } else {
          if (btn.pointers.remove(pointer))
            flush = true;
        }
      } else if (btn.pointers.contains(pointer)) {
        if (btn.pointers.remove(pointer))
          flush = true;
      }
      if (flush) {
        notifier.value++;
        this.setState(
            btn.name,
            btn.pointers.isNotEmpty
        );
      }
    });
  }
}

abstract class ButtonControlButton extends StatefulWidget {
  final GlobalKey key = GlobalKey();
  final ValueListenable listenable;
  final Set pointers = Set();
  final String name;

  ButtonControlButton(this.listenable, this.name);

  bool isDown() {
    return pointers.isNotEmpty;
  }
}

abstract class ButtonControlButtonState extends State {
  final ValueListenable listenable;
  final ButtonControlButton button;

  ButtonControlButtonState(this.button, this.listenable);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: listenable,
        builder: (context, value, child) {
          return buildContent(context);
        }
    );
  }

  Widget buildContent(BuildContext context);
}
