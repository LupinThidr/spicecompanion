part of views;

// game state
String gameModel = "";
String gameDest = "";
String gameSpec = "";
String gameRev = "";
String gameExt = "";
Duration lastPing = Duration(seconds: 1);

enum SpiceTheme { Light, Dark }
final spiceThemes = {
  SpiceTheme.Light: ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
  ),

  SpiceTheme.Dark: ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
  )
};
SpiceTheme currentTheme;

class MainView extends StatefulWidget {
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  SpiceView _currentView;
  Widget _viewWidget;

  String _gameName = "";
  String _gameServer = "";
  Widget _gameAvatar;
  static Timer _gameTimer;
  static bool _gameTickActive = false;
  static bool toolbarHidden = false;

  _MainViewState() {
    _setView(defaultSpiceView);
    _gameTimerReset();
    _gameAvatar = Image.asset("assets/spice.png");

    // subscribe to pool changes for quick info refresh
    ConnectionPool.inst.changes.stream.listen((pool) {
      _gameTimerTick(null);
    });
  }

  void _gameTimerReset() {

    // cancel old
    if (_gameTimer != null)
      _gameTimer.cancel();

    // create new timer
    _gameTimer = Timer.periodic(
        Duration(
          seconds: 1,
        ),
        _gameTimerTick
    );

    // instant tick
    _gameTimerTick(null);
  }

  void _gameTimerTick(Timer _) {

    // ignore if currently processing
    if (_gameTickActive) return;

    // query
    ConnectionPool.inst.get().then((con) {

      // lock
      if (_gameTickActive) return;
      _gameTickActive = true;

      var t1 = DateTime.now();
      infoAVS(con).then((avs) {
        var t2 = DateTime.now();
        lastPing = t2.difference(t1);
        var tDiff = lastPing.inMilliseconds;
        setState(() {

          // get info
          gameModel = avs["model"];
          gameDest = avs["dest"];
          gameSpec = avs["spec"];
          gameRev = avs["rev"];
          gameExt = avs["ext"];

          // set info
          _gameName = "$gameModel:$gameDest:$gameSpec:$gameRev:$gameExt";
          _gameServer = "${con.host}:${con.port}@${tDiff}ms";
        });

      }).whenComplete(() {
        con.free();
      });

    }).whenComplete(() {

      // unlock
      _gameTickActive = false;

    }).catchError((e) {

      // reset info
      gameModel = "";
      gameDest = "";
      gameSpec = "";
      gameRev = "";
      gameExt = "";

      // set title
      setState(() {
        _gameName = "Disconnected";
        _gameServer = "Please connect to a server.";
        _gameAvatar = Image.asset("assets/spice.png");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: spiceThemes[currentTheme],
        home: StatefulBuilder(
            builder: (BuildContext context, StateSetter state) {
              return Scaffold(
                appBar: AppBar(
                  toolbarHeight: toolbarHidden ? 0 : null,
                  title: Text(getViewName(_currentView)),
                  elevation: 5.0,
                  actions: () {
                    var list = <Widget>[];
                    if (_currentView == SpiceView.Controller) {
                      list.add(
                          Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: GestureDetector(
                                onTap: () {
                                  controllerViewNo.value++;
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.autorenew,
                                  size: 26.0,
                                ),
                              )
                          )
                      );
                    }
                    if (_currentView == SpiceView.Screen) {
                      list.add(
                        Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              screensViewNo.value++;
                            },
                            child: Icon(
                              Icons.refresh,
                              size: 26.0,
                            ),
                          )
                        )
                      );
                      /*list.add(
                          Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: GestureDetector(
                                onTap: () {
                                  ConnectionPool.inst.get().then((con) {
                                    captureGetJPG(con,
                                        screen: 0,
                                        divide: 2,
                                        quality: 50).then((capture) async {
                                      // only works on iOS apparently
                                      var dir = await getDownloadsDirectory();
                                      var path = dir.path;
                                      var now = DateTime.now();
                                      var fmt = DateFormat("yyy-MM-dd_HH-mm-ss");
                                      var nowFmt = fmt.format(now);
                                      var file = File("$path/spice_$nowFmt.jpg");
                                      await file.writeAsBytes(
                                          capture.data.toList(growable: false),
                                          flush: true);
                                      setState(() {});
                                    }).whenComplete(() => con.free());
                                  });
                                },
                                child: Icon(
                                  Icons.save,
                                  size: 26.0,
                                ),
                              )
                          )
                      );*/
                      list.add(
                        Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              ConnectionPool.inst.get().then((con) {
                                captureGetJPG(con,
                                  screen: screensCaptureNo,
                                  divide: 2,
                                  quality: 50).then((capture) async {
                                    var dir = await getApplicationDocumentsDirectory();
                                    var path = dir.path;
                                    var file = File("$path/capture.jpg");
                                    await file.writeAsBytes(
                                        capture.data.toList(growable: false),
                                        flush: true);
                                    Share.shareFiles(<String>[file.path],
                                        mimeTypes: <String>["image/jpeg"]);
                                    setState(() {});
                                }).whenComplete(() => con.free());
                              });
                            },
                            child: Icon(
                              Icons.share,
                              size: 26.0,
                            ),
                          )
                        )
                      );
                    }
                    list.add(
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            if (!isFullScreen) {
                              setState(() {
                                toolbarHidden = !toolbarHidden;
                              });
                            }
                            fullscreenToggle();
                          },
                          onLongPress: () {
                            setState(() {
                              toolbarHidden = !toolbarHidden;
                            });
                          },
                          child: Icon(
                            Icons.aspect_ratio,
                            size: 26.0,
                          ),
                        )
                      )
                    );
                    return list;
                  } (),
                ),
                body: Listener(
                  onPointerDown: (p) {
                    if (toolbarHidden && p.position.dy < 16) {
                      setState(() {
                        toolbarHidden = false;
                      });
                    }
                  },
                  child: _viewWidget,
                ),
                drawer: Drawer(
                  child: ListView(
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                        accountName: Text(_gameName),
                        accountEmail: Text(_gameServer),
                        currentAccountPicture: _gameAvatar,
                      ),

                      ListTile(
                          title: Text(getViewName(SpiceView.Servers)),
                          trailing: Icon(Icons.cloud),
                          onTap: () => setState(() {
                            _setView(SpiceView.Servers);
                            Navigator.of(context).pop();
                          })
                      ),

                      Divider(),

                      ListTile(
                          title: Text(getViewName(SpiceView.CardManager)),
                          trailing: Icon(Icons.credit_card),
                          onTap: () => setState(() {
                            _setView(SpiceView.CardManager);
                            Navigator.of(context).pop();
                          })
                      ),
                      ListTile(
                          title: Text(getViewName(SpiceView.Keypad)),
                          trailing: Icon(Icons.dialpad),
                          onTap: () => setState(() {
                            _setView(SpiceView.Keypad);
                            Navigator.of(context).pop();
                          })
                      ),
                      ListTile(
                          title: Text(getViewName(SpiceView.Patches)),
                          trailing: Icon(Icons.memory),
                          onTap: () => setState(() {
                            _setView(SpiceView.Patches);
                            Navigator.of(context).pop();
                          })
                      ),

                      Divider(),

                      ListTile(
                          title: Text(getViewName(SpiceView.Screen)),
                          trailing: Icon(Icons.cast),
                          onTap: () => setState(() {
                            _setView(SpiceView.Screen);
                            Navigator.of(context).pop();
                          })
                      ),
                      ListTile(
                          title: Text(getViewName(SpiceView.Controller)),
                          trailing: Icon(Icons.gamepad),
                          onTap: () => setState(() {
                            _setView(SpiceView.Controller);
                            Navigator.of(context).pop();
                          })
                      ),
                      ListTile(
                          title: Text(getViewName(SpiceView.Buttons)),
                          trailing: Icon(Icons.keyboard),
                          onTap: () => setState(() {
                            _setView(SpiceView.Buttons);
                            Navigator.of(context).pop();
                          })
                      ),
                      ListTile(
                          title: Text(getViewName(SpiceView.Analogs)),
                          trailing: Icon(Icons.threesixty),
                          onTap: () => setState(() {
                            _setView(SpiceView.Analogs);
                            Navigator.of(context).pop();
                          })
                      ),
                      ListTile(
                          title: Text(getViewName(SpiceView.Lights)),
                          trailing: Icon(Icons.lightbulb_outline),
                          onTap: () => setState(() {
                            _setView(SpiceView.Lights);
                            Navigator.of(context).pop();
                          })
                      ),
                      ListTile(
                          title: Text(getViewName(SpiceView.Coins)),
                          trailing: Icon(Icons.monetization_on),
                          onTap: () => setState(() {
                            _setView(SpiceView.Coins);
                            Navigator.of(context).pop();
                          })
                      ),

                      Divider(),

                      ListTile(
                          title: Text(getViewName(SpiceView.Info)),
                          trailing: Icon(Icons.info),
                          onTap: () => setState(() {
                            _setView(SpiceView.Info);
                            Navigator.of(context).pop();
                          })
                      ),
                      ListTile(
                          title: Text(getViewName(SpiceView.Settings)),
                          trailing: Icon(Icons.settings),
                          onTap: () => setState(() {
                            _setView(SpiceView.Settings);
                            Navigator.of(context).pop();
                          })
                      ),
                    ],
                  ),
                ),
              );
            }
        )
    );
  }

  void _setView(SpiceView view) {
    if (_currentView == view)
      return;
    _currentView = view;
    _viewWidget = getView(_currentView);
  }
}
