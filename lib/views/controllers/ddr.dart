part of views;

class DDRButton extends ButtonControlButton {

  DDRButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  DDRButtonState createState() => DDRButtonState(this, listenable);
}

class DDRButtonState extends ButtonControlButtonState {
  DDRButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var areaWidth = constraints.maxWidth;
        var areaHeight = constraints.maxHeight;
        var areaMin = min(areaWidth, areaHeight);
        return Container(
          decoration: BoxDecoration(
            color: button.isDown()
                ? Color(0xFF501010)
                : Color(0xFF505050),
          ),
          child: Icon(() {
            if (button.name.endsWith("Panel Up"))
              return Icons.keyboard_arrow_up;
            if (button.name.endsWith("Panel Down"))
              return Icons.keyboard_arrow_down;
            if (button.name.endsWith("Panel Left"))
              return Icons.keyboard_arrow_left;
            if (button.name.endsWith("Panel Right"))
              return Icons.keyboard_arrow_right;
            return null;
          } (), size: areaMin),
        );
      },
    );
  }
}

class DDRControllerView extends StatefulWidget {

  @override
  DDRControllerViewState createState() => DDRControllerViewState();
}

class DDRControllerViewState extends State<DDRControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      DDRButton(buttonControl.notifier, "P1 Start"),
      DDRButton(buttonControl.notifier, "P1 Panel Up"),
      DDRButton(buttonControl.notifier, "P1 Panel Down"),
      DDRButton(buttonControl.notifier, "P1 Panel Left"),
      DDRButton(buttonControl.notifier, "P1 Panel Right"),
      DDRButton(buttonControl.notifier, "P1 Menu Up"),
      DDRButton(buttonControl.notifier, "P1 Menu Down"),
      DDRButton(buttonControl.notifier, "P1 Menu Left"),
      DDRButton(buttonControl.notifier, "P1 Menu Right"),
      DDRButton(buttonControl.notifier, "P2 Start"),
      DDRButton(buttonControl.notifier, "P2 Panel Up"),
      DDRButton(buttonControl.notifier, "P2 Panel Down"),
      DDRButton(buttonControl.notifier, "P2 Panel Left"),
      DDRButton(buttonControl.notifier, "P2 Panel Right"),
      DDRButton(buttonControl.notifier, "P2 Menu Up"),
      DDRButton(buttonControl.notifier, "P2 Menu Down"),
      DDRButton(buttonControl.notifier, "P2 Menu Left"),
      DDRButton(buttonControl.notifier, "P2 Menu Right"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var viewCount = 4;
    var viewNo = controllerViewNo.value % viewCount;
    if (viewNo == 0) return buildMenu(context);
    if (viewNo == 1) return buildDouble(context);
    if (viewNo == 2) return buildSingle(context, 1);
    if (viewNo == 3) return buildSingle(context, 2);
    return null;
  }

  Widget buildMenu(BuildContext context) {
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: AspectRatio(
            aspectRatio: 19 / 9,
            child: Container(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var areaWidth = constraints.maxWidth;
                  var areaHeight = constraints.maxHeight;
                  return Stack(
                    children: [

                      // P1 Start
                      Positioned(
                        left: areaWidth * (.06 + .015 + 0.15 * 1),
                        top: areaHeight * 0.375,
                        child: Container(
                          width: areaWidth * 0.09,
                          height: areaWidth * 0.09,
                          transform: Matrix4.rotationZ(pi/4),
                          child: buttonControl.widgets[0],
                        )
                      ),
                        
                      // P1 Menu Up
                      Positioned(
                        left: areaWidth * (0.015 + 0.15 * 1),
                        top: areaHeight * 0.070,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[5],
                        )
                      ),

                      // P1 Menu Down
                      Positioned(
                        left: areaWidth * (0.015 + 0.15 * 1),
                        top: areaHeight * 0.695,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[6],
                        )
                      ),

                      // P1 Menu Left
                      Positioned(
                        left: areaWidth * (0.015 + 0.15 * 0),
                        top: areaHeight * 0.370,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[7],
                        )
                      ),

                      // P1 Menu Right
                      Positioned(
                        left: areaWidth * (0.015 + 0.15 * 2),
                        top: areaHeight * 0.370,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[8],
                        )
                      ),

                      // P2 Start
                      Positioned(
                        left: areaWidth * (.06 + .1 + 0.15 * 4),
                        top: areaHeight * 0.375,
                        child: Container(
                          width: areaWidth * 0.09,
                          height: areaWidth * 0.09,
                          transform: Matrix4.rotationZ(pi/4),
                          child: buttonControl.widgets[9],
                        )
                      ),
                        
                      // P2 Menu Up
                      Positioned(
                        left: areaWidth * (0.1 + 0.15 * 4),
                        top: areaHeight * 0.070,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[14],
                        )
                      ),

                      // P2 Menu Down
                      Positioned(
                        left: areaWidth * (0.1 + 0.15 * 4),
                        top: areaHeight * 0.695,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[15],
                        )
                      ),

                      // P2 Menu Left
                      Positioned(
                        left: areaWidth * (0.1 + 0.15 * 3),
                        top: areaHeight * 0.370,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[16],
                        )
                      ),

                      // P2 Menu Right
                      Positioned(
                        left: areaWidth * (0.1 + 0.15 * 5),
                        top: areaHeight * 0.370,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[17],
                        )
                      ),

                    ],
                  );
                }
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget buildDouble(BuildContext context) {
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: AspectRatio(
            aspectRatio: 19 / 9,
            child: Container(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var areaWidth = constraints.maxWidth;
                  var areaHeight = constraints.maxHeight;
                  return Stack(
                    children: [

                      // P1 Up
                      Positioned(
                        left: areaWidth * (0.02 + 0.15 * 1),
                        top: areaWidth * 0.015,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[1],
                        )
                      ),

                      // P1 Down
                      Positioned(
                        left: areaWidth * (0.02 + 0.15 * 1),
                        top: areaWidth * (0.015 + 0.3),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[2],
                        )
                      ),

                      // P1 Left
                      Positioned(
                        left: areaWidth * (0.02 + 0.15 * 0),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[3],
                        )
                      ),

                      // P1 Right
                      Positioned(
                        left: areaWidth * (0.02 + 0.15 * 2),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[4],
                        )
                      ),

                      // P2 Up
                      Positioned(
                        left: areaWidth * (0.08 + 0.15 * 4),
                        top: areaWidth * 0.015,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[10],
                        )
                      ),

                      // P2 Down
                      Positioned(
                        left: areaWidth * (0.08 + 0.15 * 4),
                        top: areaWidth * (0.015 + 0.3),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[11],
                        )
                      ),

                      // P2 Left
                      Positioned(
                        left: areaWidth * (0.08 + 0.15 * 3),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[12],
                        )
                      ),

                      // P2 Right
                      Positioned(
                        left: areaWidth * (0.08 + 0.15 * 5),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[13],
                        )
                      ),

                    ],
                  );
                }
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget buildSingle(BuildContext context, int player) {
    int startIndex = player == 2 ? 10 : 1;
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var areaWidth = constraints.maxWidth;
                  var areaHeight = constraints.maxHeight;
                  return Stack(
                    children: [

                      // P1 Up
                      Positioned(
                        left: areaWidth * (0.05 + 0.3 * 1),
                        top: areaWidth * 0.05,
                        child: Container(
                          width: areaWidth * 0.3,
                          height: areaWidth * 0.3,
                          child: buttonControl.widgets[startIndex + 0],
                        )
                      ),

                      // P1 Down
                      Positioned(
                        left: areaWidth * (0.05 + 0.3 * 1),
                        top: areaWidth * (0.05 + 0.6),
                        child: Container(
                          width: areaWidth * 0.3,
                          height: areaWidth * 0.3,
                          child: buttonControl.widgets[startIndex + 1],
                        )
                      ),

                      // P1 Left
                      Positioned(
                        left: areaWidth * (0.05 + 0.3 * 0),
                        top: areaWidth * (0.05 + 0.3),
                        child: Container(
                          width: areaWidth * 0.3,
                          height: areaWidth * 0.3,
                          child: buttonControl.widgets[startIndex + 2],
                        )
                      ),

                      // P1 Right
                      Positioned(
                        left: areaWidth * (0.05 + 0.3 * 2),
                        top: areaWidth * (0.05 + 0.3),
                        child: Container(
                          width: areaWidth * 0.3,
                          height: areaWidth * 0.3,
                          child: buttonControl.widgets[startIndex + 3],
                        )
                      ),

                      // player text
                      Positioned(
                        left: areaWidth * (0.05 + 0.3 * 1),
                        top: areaWidth * (0.05 + 0.3),
                        child: Container(
                          width: areaWidth * 0.3,
                          height: areaWidth * 0.3,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(player.toString()),
                          ),
                        )
                      ),

                    ],
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
