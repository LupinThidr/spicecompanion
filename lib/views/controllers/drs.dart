part of views;

class DRSButton extends ButtonControlButton {

  DRSButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  DRSButtonState createState() => DRSButtonState(this, listenable);
}

class DRSButtonState extends ButtonControlButtonState {
  DRSButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: button.isDown()
            ? Color(0xFF501010)
            : Color(0xFF505050),
      ),
    );
  }
}

class DRSControllerView extends StatefulWidget {

  @override
  DRSControllerViewState createState() => DRSControllerViewState();
}

class DRSControllerViewState extends State<DRSControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      DRSButton(buttonControl.notifier, "P1 Start"),
      DRSButton(buttonControl.notifier, "P1 Up"),
      DRSButton(buttonControl.notifier, "P1 Down"),
      DRSButton(buttonControl.notifier, "P1 Left"),
      DRSButton(buttonControl.notifier, "P1 Right"),
      DRSButton(buttonControl.notifier, "P2 Start"),
      DRSButton(buttonControl.notifier, "P2 Up"),
      DRSButton(buttonControl.notifier, "P2 Down"),
      DRSButton(buttonControl.notifier, "P2 Left"),
      DRSButton(buttonControl.notifier, "P2 Right"),
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
                          child: buttonControl.widgets[1],
                        )
                      ),

                      // P1 Menu Down
                      Positioned(
                        left: areaWidth * (0.015 + 0.15 * 1),
                        top: areaHeight * 0.695,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[2],
                        )
                      ),

                      // P1 Menu Left
                      Positioned(
                        left: areaWidth * (0.015 + 0.15 * 0),
                        top: areaHeight * 0.370,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[3],
                        )
                      ),

                      // P1 Menu Right
                      Positioned(
                        left: areaWidth * (0.015 + 0.15 * 2),
                        top: areaHeight * 0.370,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[4],
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
                          child: buttonControl.widgets[5],
                        )
                      ),
                        
                      // P2 Menu Up
                      Positioned(
                        left: areaWidth * (0.1 + 0.15 * 4),
                        top: areaHeight * 0.070,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[6],
                        )
                      ),

                      // P2 Menu Down
                      Positioned(
                        left: areaWidth * (0.1 + 0.15 * 4),
                        top: areaHeight * 0.695,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[7],
                        )
                      ),

                      // P2 Menu Left
                      Positioned(
                        left: areaWidth * (0.1 + 0.15 * 3),
                        top: areaHeight * 0.370,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[8],
                        )
                      ),

                      // P2 Menu Right
                      Positioned(
                        left: areaWidth * (0.1 + 0.15 * 5),
                        top: areaHeight * 0.370,
                        child: Container(
                          width: areaWidth * 0.12,
                          height: areaWidth * 0.12,
                          child: buttonControl.widgets[9],
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
