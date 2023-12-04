part of views;

enum JBControl {
  B1, B2, B3, B4, B5, B6, B7, B8, B9, B10, B11, B12, B13, B14, B15, B16
}

class JBButton extends ButtonControlButton {

  JBButton(ValueListenable listenable, JBControl control)
      : super(listenable, "Button " + (control.index + 1).toString());

  @override
  JBButtonState createState() => JBButtonState(this, listenable);
}

class JBButtonState extends ButtonControlButtonState {
  JBButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: button.isDown()
              ? Color(0xFF505050)
              : Color(0xFF101010),
          border: Border.all(
            color: Color(0xFF102050),
          ),
        )
      ),
    );
  }
}

class JBControllerView extends StatefulWidget {

  @override
  JBControllerViewState createState() => JBControllerViewState();
}

class JBControllerViewState extends State<JBControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      JBButton(buttonControl.notifier, JBControl.B1),
      JBButton(buttonControl.notifier, JBControl.B2),
      JBButton(buttonControl.notifier, JBControl.B3),
      JBButton(buttonControl.notifier, JBControl.B4),
      JBButton(buttonControl.notifier, JBControl.B5),
      JBButton(buttonControl.notifier, JBControl.B6),
      JBButton(buttonControl.notifier, JBControl.B7),
      JBButton(buttonControl.notifier, JBControl.B8),
      JBButton(buttonControl.notifier, JBControl.B9),
      JBButton(buttonControl.notifier, JBControl.B10),
      JBButton(buttonControl.notifier, JBControl.B11),
      JBButton(buttonControl.notifier, JBControl.B12),
      JBButton(buttonControl.notifier, JBControl.B13),
      JBButton(buttonControl.notifier, JBControl.B14),
      JBButton(buttonControl.notifier, JBControl.B15),
      JBButton(buttonControl.notifier, JBControl.B16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF102050),
        body: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF102050),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buttonControl.widgets[0],
                        buttonControl.widgets[1],
                        buttonControl.widgets[2],
                        buttonControl.widgets[3],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buttonControl.widgets[4],
                        buttonControl.widgets[5],
                        buttonControl.widgets[6],
                        buttonControl.widgets[7],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buttonControl.widgets[8],
                        buttonControl.widgets[9],
                        buttonControl.widgets[10],
                        buttonControl.widgets[11],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buttonControl.widgets[12],
                        buttonControl.widgets[13],
                        buttonControl.widgets[14],
                        buttonControl.widgets[15],
                      ],
                    ),
                  ),
                ],
              ),
            )
          )
        ),
      )
    );
  }
}
