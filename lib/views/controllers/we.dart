part of views;

class WEButton extends ButtonControlButton {

  WEButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  WEButtonState createState() => WEButtonState(this, listenable);
}

class WEButtonState extends ButtonControlButtonState {
  WEButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: button.isDown()
            ? Color(0xFF501010)
            : Color(0xFF505050),
      ),
    );
  }
}

class WEControllerView extends StatefulWidget {

  @override
  WEControllerViewState createState() => WEControllerViewState();
}

class WEControllerViewState extends State<WEControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      WEButton(buttonControl.notifier, "Start"),
      WEButton(buttonControl.notifier, "Up"),
      WEButton(buttonControl.notifier, "Down"),
      WEButton(buttonControl.notifier, "Left"),
      WEButton(buttonControl.notifier, "Right"),
      WEButton(buttonControl.notifier, "Button A"),
      WEButton(buttonControl.notifier, "Button B"),
      WEButton(buttonControl.notifier, "Button C"),
      WEButton(buttonControl.notifier, "Button D"),
      WEButton(buttonControl.notifier, "Button E"),
      WEButton(buttonControl.notifier, "Button F"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var viewCount = 1;
    var viewNo = controllerViewNo.value % viewCount;
    if (viewNo == 0) return buildMenu(context);
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

                      // start
                      Positioned(
                        left: areaWidth * 0.5,
                        top: areaWidth * 0.015,
                        child: Container(
                          width: areaWidth * 0.08,
                          height: areaWidth * 0.08,
                          child: buttonControl.widgets[0],
                        )
                      ),

                      // up
                      Positioned(
                        left: areaWidth * (0.02 + 0.1 * 1),
                        top: areaWidth * 0.065,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[1],
                        )
                      ),

                      // down
                      Positioned(
                        left: areaWidth * (0.02 + 0.1 * 1),
                        top: areaWidth * (0.015 + 0.25),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[2],
                        )
                      ),

                      // left
                      Positioned(
                        left: areaWidth * (0.02 + 0.1 * 0),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[3],
                        )
                      ),

                      // right
                      Positioned(
                        left: areaWidth * (0.02 + 0.1 * 2),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[4],
                        )
                      ),

                      // button a
                      Positioned(
                        left: areaWidth * (0.5 + 0.15 * 0),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.125,
                          height: areaWidth * 0.125,
                          child: buttonControl.widgets[5],
                        )
                      ),

                      // button b
                      Positioned(
                        left: areaWidth * (0.5 + 0.15 * 1),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.125,
                          height: areaWidth * 0.125,
                          child: buttonControl.widgets[6],
                        )
                      ),

                      // button c
                      Positioned(
                        left: areaWidth * (0.5 + 0.15 * 2),
                        top: areaWidth * (0.015 + 0.15),
                        child: Container(
                          width: areaWidth * 0.125,
                          height: areaWidth * 0.125,
                          child: buttonControl.widgets[7],
                        )
                      ),

                      // button d
                      Positioned(
                        left: areaWidth * (0.5 + 0.15 * 0),
                        top: areaWidth * (0.015 + 0.3),
                        child: Container(
                          width: areaWidth * 0.125,
                          height: areaWidth * 0.125,
                          child: buttonControl.widgets[8],
                        )
                      ),

                      // button e
                      Positioned(
                        left: areaWidth * (0.5 + 0.15 * 1),
                        top: areaWidth * (0.015 + 0.3),
                        child: Container(
                          width: areaWidth * 0.125,
                          height: areaWidth * 0.125,
                          child: buttonControl.widgets[9],
                        )
                      ),

                      // button f
                      Positioned(
                        left: areaWidth * (0.5 + 0.15 * 2),
                        top: areaWidth * (0.015 + 0.3),
                        child: Container(
                          width: areaWidth * 0.125,
                          height: areaWidth * 0.125,
                          child: buttonControl.widgets[10],
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
