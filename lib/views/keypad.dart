part of views;

enum KeypadKey {
  KeyBlank, Key00, Key0,
  Key1, Key2, Key3,
  Key4, Key5, Key6,
  Key7, Key8, Key9,
  KeyMode, KeyInsert, KeyNone
}

const _keyLookup = {
  KeypadKey.KeyBlank: 'D',
  KeypadKey.Key00: 'A',
  KeypadKey.Key0: '0',
  KeypadKey.Key1: '1',
  KeypadKey.Key2: '2',
  KeypadKey.Key3: '3',
  KeypadKey.Key4: '4',
  KeypadKey.Key5: '5',
  KeypadKey.Key6: '6',
  KeypadKey.Key7: '7',
  KeypadKey.Key8: '8',
  KeypadKey.Key9: '9',
  KeypadKey.KeyMode: '',
  KeypadKey.KeyInsert: '',
  KeypadKey.KeyNone: '',
};

class _KeypadButton extends StatelessWidget {
  final KeypadKey _key;
  final String _label;
  final Function(KeypadKey) _cb;
  final Color fontColor;
  final double fontSize;

  _KeypadButton(this._key, this._label, this._cb,
      {this.fontColor, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        enableFeedback: true, // may want to make this an option?
        child: Center(
          child: Text(
            _label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize ?? 42.0,
              color: fontColor
            )
          ),
        ),
        onTap: () {
          if (this._cb != null)
            this._cb(_key);
        }
      ),
    );
  }
}

class KeypadView extends StatefulWidget {
  @override
  _KeypadViewState createState() => _KeypadViewState();
}

class _KeypadViewState extends State<KeypadView> {

  String keyBuffer = "";
  Future<void> keyBufferSend;
  int currentMode = 0;
  bool active = false;
  StreamSubscription<String> cardSubscription;

  _KeypadViewState();

  @override
  void initState() {
    super.initState();
    active = true;

    // subscribe to card inserts
    cardSubscription = TagManager.inst.tagStream.stream.listen((id) {
      if (active) {

        // check card id trigger
        for (var card in cardList) {
          if (card.idTrigger == id) {
            id = card.id;
            break;
          }
        }

        // insert card
        insertCardID(id);
      }
    });
  }

  @override
  void dispose() {
    cardSubscription.cancel();
    active = false;
    super.dispose();
  }

  String getModeString() {
    switch (currentMode) {
      case 0:
        if (getPlayerCount(gameModel) <= 1)
          return "";
        return "P1";
      case 1:
        return "P2";
      default:
        return "??";
    }
  }

  int getModePlayer() {
    switch (currentMode) {
      case 0:
        return 0;
      case 1:
        return 1;
      default:
        return 0;
    }
  }

  Color getModeColor() {
    switch (currentMode) {
      case 0:
        return Colors.teal;
      case 1:
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  void nextMode() {
    currentMode = (currentMode + 1) % 2;
    if (getPlayerCount(gameModel) <= 1)
      currentMode = 0;
    setState(() {});
  }

  void insertCard() async {

    // check if cards are loaded
    if (!cardListLoaded) {
      /*await SharedPreferences.getInstance().then((prefs) {
        cardListLoad(prefs);
      });*/
    }

    // check if cards are defined
    if (cardList.length == 0) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Please add cards first."),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 500),
      ));
      return;
    }

    // check if we only have one card
    var card;
    if (cardList.length == 1) {

      // just use that one then
      card = cardList[0];

    } else if (cardList.any((i) => i.active)) {

      // use the active card
      card = cardList.firstWhere((i) => i.active);

    } else {

      // show card selection dialog
      card = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Select Card"),
            children: cardList.map((CardInfo card) {
              return SimpleDialogOption(
                child: Text("${card.name} (${card.id})"),
                onPressed: () {
                  Navigator.pop(context, card);
                },
              );
            }).toList(),
          );
        }
      );
    }

    // check result
    if (card != null && card is CardInfo) {

      // move card to index 0 since we want the last used cards at the top
      cardList.remove(card);
      cardList.insert(0, card);
      /*SharedPreferences.getInstance().then((prefs) {
        cardListSave(prefs);
      });*/

      // insert
      insertCardID(card.id);
    }
  }

  void insertCardID(String id) {

    // get connection
    ConnectionPool.inst.get().then((con) {

      // show info
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Inserting Card: $id"),
        backgroundColor: getModeColor(),
        duration: Duration(seconds: 1),
      ));

      // insert card
      cardInsert(con, getModePlayer(), id).whenComplete(() {
        con.free();
      });

    }, onError: (err) {

      // show error
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Please connect to a server first."),
        backgroundColor: Colors.deepOrange,
        duration: Duration(seconds: 1),
      ));

    });
  }

  void keyCallback(KeypadKey key) {

    // switch mode on blank key instead
    switch (key) {
      case KeypadKey.KeyMode:
        nextMode();
        return;
      case KeypadKey.KeyInsert:
        insertCard();
        return;
      case KeypadKey.KeyNone:
        return;
      default:
        break;
    }

    // check length
    if (keyBuffer.length < 8)
      keyBuffer += _keyLookup[key];

    // update
    if (keyBuffer.length > 0)
      keyUpdate();
  }

  void keyUpdate() {
    if (keyBufferSend == null) {
      keyBufferSend = ConnectionPool.inst.get().then((con) {
        keypadsWrite(con, getModePlayer(), keyBuffer).whenComplete(() {
          con.free();
          keyBufferSend = null;
          if (keyBuffer.length > 0)
            keyUpdate();
        });
      }, onError: (e) {}).whenComplete(() {
        keyBuffer = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                _KeypadButton(KeypadKey.Key7, '7', keyCallback),
                _KeypadButton(KeypadKey.Key8, '8', keyCallback),
                _KeypadButton(KeypadKey.Key9, '9', keyCallback),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                _KeypadButton(KeypadKey.Key4, '4', keyCallback),
                _KeypadButton(KeypadKey.Key5, '5', keyCallback),
                _KeypadButton(KeypadKey.Key6, '6', keyCallback),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                _KeypadButton(KeypadKey.Key1, '1', keyCallback),
                _KeypadButton(KeypadKey.Key2, '2', keyCallback),
                _KeypadButton(KeypadKey.Key3, '3', keyCallback),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                _KeypadButton(KeypadKey.Key0, '0', keyCallback),
                _KeypadButton(KeypadKey.Key00, '00', keyCallback),
                _KeypadButton(KeypadKey.KeyBlank, '.', keyCallback),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                _KeypadButton(KeypadKey.KeyMode, getModeString(), keyCallback,
                  fontSize: 28,
                  fontColor: getModeColor(),
                ),
                _KeypadButton(KeypadKey.KeyInsert, 'Insert Card', keyCallback,
                  fontSize: 28,
                  fontColor: Colors.deepOrange,
                ),
                _KeypadButton(KeypadKey.KeyNone, '', keyCallback),
              ],
            ),
          ),
        ],
      )
    );
  }
}
