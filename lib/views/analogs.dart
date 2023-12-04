part of views;

class AnalogsView extends StatefulWidget {

  @override
  _AnalogsViewState createState() => _AnalogsViewState();
}

class _AnalogsViewState extends State<AnalogsView> {

  List<AnalogState> _analogStates = List();
  bool _analogStatesLock = false;
  Timer refreshTimer;
  int updateCount = 0;
  bool locked = false;
  List<String> ignoreAnalogNames = List();

  @override
  void initState() {
    super.initState();
    ignoreAnalogNames = List();
    if (!locked)
      freeList();
    update();
  }

  @override
  void dispose() {
    if (refreshTimer != null)
      refreshTimer.cancel();
    if (!locked)
      freeList();
    super.dispose();
  }

  Future<void> writeSingle(AnalogState state) async {
    return ConnectionPool.inst.get().then((con) {
      return analogsWrite(con, [state]).whenComplete(() {
        locked = true;
        state.active = true;
        con.free();
      });
    }, onError: (e) {});
  }

  Future<void> writeList() async {
    return ConnectionPool.inst.get().then((con) {
      if (_analogStates == null || _analogStates.length == 0)
        return null;
      return analogsWrite(con, _analogStates).whenComplete(() => con.free());
    }, onError: (e) {});
  }

  Future<void> freeList() async {
    return ConnectionPool.inst.get().then((con) {
      analogsWriteReset(con, []).whenComplete(() => con.free());
    }, onError: (e) {});
  }

  void update() {

    // update timer
    if (refreshTimer == null || refreshTimer.tick >= 64) {
      if (refreshTimer != null)
        refreshTimer.cancel();
      refreshTimer = Timer.periodic(
        Duration(milliseconds: max(128, lastPing.inMilliseconds)),
          (timer) => update()
      );
    }

    // update analogs
    if (updateCount < 2) {
      updateCount++;
      ConnectionPool.inst.get().then((con) {
        analogsRead(con).then((stateList) {

          // check lock first
          if (_analogStatesLock)
            return;

          // apply new list
          _analogStatesLock = true;
          List<AnalogState> newList = List();
          for (var newState in stateList) {
            if (newState.active)
              locked = true;
            if (!ignoreAnalogNames.contains(newState.name))
              newList.add(newState);
            else
              newList.addAll(_analogStates.where(
                      (oldState) => oldState.name == newState.name
              ));
          }
          _analogStates = newList;
          _analogStatesLock = false;

          try {
            setState(() {});
          } on Error {}

        }).whenComplete(() => con.free());
      }, onError: (e) {

        // clear list on disconnect
        _analogStates = List();
      }).whenComplete(() => updateCount--);
    }
  }

  @override
  Widget build(BuildContext context) {

    // empty view
    if (_analogStates.length == 0)
      return Container(
        child: Center(
            child: Text('No analogs available :(')
        ),
      );

    // list view
    return Scaffold(
      body: ListView(
       children: _analogStates.map((analog) {

         // title color
         var titleColor = analog.active ? Colors.orange : null;

         return ListTile(
           title: Text(analog.name, style: TextStyle(color: titleColor)),
           subtitle: Slider(
             value: analog.state,
             min: 0.0,
             max: 1.0,
             divisions: 100,
             activeColor: Colors.blue,
             inactiveColor: Colors.grey,
             onChanged: (value) {
               analog.state = value;
               writeSingle(analog);
               setState(() {});
             },
             onChangeStart: (value) {
               ignoreAnalogNames.add(analog.name);
             },
             onChangeEnd: (value) {
               ignoreAnalogNames.remove(analog.name);
               analog.state = value;
               writeSingle(analog);
               setState(() {});
             },
           ),
           onTap: () async {
             if (analog.state >= 0.5)
               analog.state = 0;
             else
               analog.state = 1;
             await writeSingle(analog);
             setState(() {});
           },
         );

       }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(locked ? Icons.lock : Icons.lock_open),
        onPressed: () {
          if (locked) {
            locked = false;
            freeList();
          } else {
            locked = true;
            writeList();
          }
          setState(() {});
        },
        backgroundColor: locked ? Colors.red : null,
      ),
    );
  }
}
