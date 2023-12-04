part of views;

class NostButton extends ButtonControlButton {

  NostButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  NostButtonState createState() => NostButtonState(this, listenable);
}

class NostButtonState extends ButtonControlButtonState {
  NostButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: button.isDown()
            ? Color(0xFF501010)
            : Color(0xFF505050),
        border: Border.all(
          color: Color(0xFF404040),
        ),
      )
    );
  }
}

class NostControllerView extends StatefulWidget {

  @override
  NostControllerViewState createState() => NostControllerViewState();
}

class NostControllerViewState extends State<NostControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      NostButton(buttonControl.notifier, "Key 1"),
      NostButton(buttonControl.notifier, "Key 2"),
      NostButton(buttonControl.notifier, "Key 3"),
      NostButton(buttonControl.notifier, "Key 4"),
      NostButton(buttonControl.notifier, "Key 5"),
      NostButton(buttonControl.notifier, "Key 6"),
      NostButton(buttonControl.notifier, "Key 7"),
      NostButton(buttonControl.notifier, "Key 8"),
      NostButton(buttonControl.notifier, "Key 9"),
      NostButton(buttonControl.notifier, "Key 10"),
      NostButton(buttonControl.notifier, "Key 11"),
      NostButton(buttonControl.notifier, "Key 12"),
      NostButton(buttonControl.notifier, "Key 13"),
      NostButton(buttonControl.notifier, "Key 14"),
      NostButton(buttonControl.notifier, "Key 15"),
      NostButton(buttonControl.notifier, "Key 16"),
      NostButton(buttonControl.notifier, "Key 17"),
      NostButton(buttonControl.notifier, "Key 18"),
      NostButton(buttonControl.notifier, "Key 19"),
      NostButton(buttonControl.notifier, "Key 20"),
      NostButton(buttonControl.notifier, "Key 21"),
      NostButton(buttonControl.notifier, "Key 22"),
      NostButton(buttonControl.notifier, "Key 23"),
      NostButton(buttonControl.notifier, "Key 24"),
      NostButton(buttonControl.notifier, "Key 25"),
      NostButton(buttonControl.notifier, "Key 26"),
      NostButton(buttonControl.notifier, "Key 27"),
      NostButton(buttonControl.notifier, "Key 28"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: AspectRatio(
            aspectRatio: 19 / 9,
            child: Container(
              /*decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF102050),
                ),
              ),*/
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var areaWidth = constraints.maxWidth;
                  var areaHeight = constraints.maxHeight;
                  return Stack(
                    children: () {
                      var list = <Widget>[];
                      var btnNum = 0;
                      buttonControl.widgets.forEach((btn) {
                        list.add(Positioned(
                            left: areaWidth * (btnNum / 28),
                            top: areaHeight * 0.525,
                            child: Container(
                              width: areaWidth * (1 / 28),
                              height: areaWidth * 0.2125,
                              child: buttonControl.widgets[btnNum],
                            )
                        ));
                        btnNum++;
                      });
                      return list;
                    } (),
                  );
                }
              ),
            ),
          ),
        ),
      )
    );
  }
}
