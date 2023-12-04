part of views;

class FTTButton extends ButtonControlButton {

  FTTButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  FTTButtonState createState() => FTTButtonState(this, listenable);
}

class FTTButtonState extends ButtonControlButtonState {
  FTTButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: () {
          if (button.name.endsWith("1")
          || (button.name.endsWith("2"))) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFFB0F0FF);
          }
          if (button.name.endsWith("3")
          || (button.name.endsWith("4"))) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFFF050C0);
          }
          return button.isDown()
              ? Color(0xFF501010)
              : Color(0xFFD05050);
        } (),
      )
    );
  }
}

class FTTControllerView extends StatefulWidget {

  @override
  FTTControllerViewState createState() => FTTControllerViewState();
}

class FTTControllerViewState extends State<FTTControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      FTTButton(buttonControl.notifier, "Pad 1"),
      FTTButton(buttonControl.notifier, "Pad 2"),
      FTTButton(buttonControl.notifier, "Pad 3"),
      FTTButton(buttonControl.notifier, "Pad 4"),
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
                    children: [

                      // pad 1
                      Positioned(
                        left: areaWidth * (0.05 + 0.23 * 0),
                        top: areaHeight * 0.35,
                        child: Container(
                          width: areaWidth * 0.2,
                          height: areaWidth * 0.2,
                          child: buttonControl.widgets[0],
                        )
                      ),

                      // pad 2
                      Positioned(
                        left: areaWidth * (0.05 + 0.23 * 1),
                        top: areaHeight * 0.35,
                        child: Container(
                          width: areaWidth * 0.2,
                          height: areaWidth * 0.2,
                          child: buttonControl.widgets[1],
                        )
                      ),

                      // pad 3
                      Positioned(
                        left: areaWidth * (0.05 + 0.23 * 2),
                        top: areaHeight * 0.35,
                        child: Container(
                          width: areaWidth * 0.2,
                          height: areaWidth * 0.2,
                          child: buttonControl.widgets[2],
                        )
                      ),

                      // pad 4
                      Positioned(
                        left: areaWidth * (0.05 + 0.23 * 3),
                        top: areaHeight * 0.35,
                        child: Container(
                          width: areaWidth * 0.2,
                          height: areaWidth * 0.2,
                          child: buttonControl.widgets[3],
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
