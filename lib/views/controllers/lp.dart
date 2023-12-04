part of views;

class LPButton extends ButtonControlButton {

  LPButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  LPButtonState createState() => LPButtonState(this, listenable);
}

class LPButtonState extends ButtonControlButtonState {
  LPButtonState(listenable, button) : super(listenable, button);

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
            if (button.name.endsWith("Left"))
              return CupertinoIcons.heart_fill;
            if (button.name.endsWith("Right"))
              return CupertinoIcons.plus;
            return null;
          } (), size: areaMin),
        );
      },
    );
  }
}

class LPControllerView extends StatefulWidget {

  @override
  LPControllerViewState createState() => LPControllerViewState();
}

class LPControllerViewState extends State<LPControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      LPButton(buttonControl.notifier, "Left"),
      LPButton(buttonControl.notifier, "Right"),
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

                      // left
                      Positioned(
                        left: areaWidth * 0.075,
                        top: areaHeight * 0.08,
                        child: Container(
                          width: areaWidth * 0.4,
                          height: areaWidth * 0.4,
                          child: buttonControl.widgets[0],
                        )
                      ),

                      // right
                      Positioned(
                        left: areaWidth * 0.535,
                        top: areaHeight * 0.08,
                        child: Container(
                          width: areaWidth * 0.4,
                          height: areaWidth * 0.4,
                          child: buttonControl.widgets[1],
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
