part of views;

class PatchCache {
  Patch patch;
  PatchState state;
  PatchCache(this.patch, this.state);
}

class PatchesView extends StatefulWidget {

  @override
  _PatchesViewState createState() => _PatchesViewState();
}

class _PatchesViewState extends State<PatchesView> {

  var subViews = [
    PatchesSubView(setting: _PatchesSubViewSetting.Preset),
    PatchesSubView(setting: _PatchesSubViewSetting.Online),
    PatchesSubView(setting: _PatchesSubViewSetting.Custom),
  ];

  var titles = [
    "Preset",
    "Online",
    "Custom"
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: subViews.length,
      child: Scaffold(
        appBar: TabBar(
          isScrollable: true,
          tabs: subViews.map((PatchesSubView subView) {
            return Tab(
              text: titles[subView.setting.index],
            );
          }).toList(),
        ),
        body: TabBarView(
          children: subViews,
        ),
      )
    );
  }
}

class PatchesSubView extends StatefulWidget {

  final _PatchesSubViewSetting setting;
  PatchesSubView({this.setting});

  @override
  _PatchesSubViewState createState() => _PatchesSubViewState(
      setting: this.setting
  );
}

enum _PatchesSubViewSetting {
  Preset,
  Online,
  Custom
}

class _PatchesSubViewState extends State<PatchesSubView> {

  // keys
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  // state
  _PatchesSubViewSetting setting;
  List<PatchCache> patchList = List();

  _PatchesSubViewState({this.setting});

  Future<void> update() async {
    return ConnectionPool.inst.get().then((con) {
      infoAVS(con).then((avs) async {

        // get info
        var gameCode = avs["model"];
        var dateCode = int.parse(avs["ext"]);

        // get patches
        List<Patch> patches = List();
        switch (this.setting) {
          case _PatchesSubViewSetting.Preset:
            for (var patch in PatchManager.inst.getPatches(gameCode, dateCode))
              if (patch.preset)
                patches.add(patch);
            break;
          case _PatchesSubViewSetting.Online:
            for (var patch in PatchManager.inst.getPatches(gameCode, dateCode))
              if (patch.online)
                patches.add(patch);
            break;
          case _PatchesSubViewSetting.Custom:
            for (var patch in PatchManager.inst.getPatches(gameCode, dateCode))
              if (!patch.preset)
                patches.add(patch);
            break;
        }

        // add patches to cache
        List<PatchCache> newList = List();
        for (var patch in patches) {
          newList.add(PatchCache(
              patch,
              await patch.getState(con)
          ));
        }
        this.patchList = newList;

        // update state
        if (mounted)
          setState(() {});

      }).whenComplete(() => con.free());
    }, onError: (e) {
      this.patchList = List();
    });
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  Widget build(BuildContext context) {

    // action button
    FloatingActionButton actionButton;
    switch (this.setting) {
      case _PatchesSubViewSetting.Preset:
        break;
      case _PatchesSubViewSetting.Online:
        actionButton = FloatingActionButton(
          heroTag: "online",
          child: Icon(Icons.settings),
          onPressed: () async {
            _showAddOnlineDialog();
          },
        );
        break;
      case _PatchesSubViewSetting.Custom:
        actionButton = FloatingActionButton(
          heroTag: "custom",
          child: Icon(Icons.settings),
          onPressed: () async {
            _showAddCustomDialog();
          },
        );
        break;
    }

    // check patches
    if (!ConnectionPool.inst.hasConnection() || patchList.length == 0) {
      var error = "Please connect to a server first.";
      if (ConnectionPool.inst.hasConnection())
        error = "No patches known for this version :(";
      return Scaffold(
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: update,
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(error),
              ),
            ],
          ),
        ),
        floatingActionButton: actionButton,
      );
    }

    // patch list
    return Scaffold(
      floatingActionButton: actionButton,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: update,
        child: ListView(
            children: patchList.map((PatchCache cache) {

              // decide on title and color
              String title;
              Color color;
              switch (cache.state) {
                case PatchState.Unknown:
                  title = cache.patch.name;
                  color = Colors.grey;
                  break;
                case PatchState.Enabled:
                  title = "${cache.patch.name} (Enabled)";
                  color = Colors.green;
                  break;
                case PatchState.Disabled:
                  title = "${cache.patch.name} (Disabled)";
                  color = Colors.red;
                  break;
              }

              // build item
              return ListTile(
                title: Text(title, style: TextStyle(
                  color: color,
                ),
                ),
                subtitle: Text(cache.patch.description),
                onLongPress: () {
                  switch (this.setting) {
                    case _PatchesSubViewSetting.Preset:
                      break;
                    case _PatchesSubViewSetting.Online:
                      break;
                    case _PatchesSubViewSetting.Custom:
                      _showCustomOptions(cache.patch);
                      break;
                  }
                },
                onTap: () {

                  // decide on new state
                  var newState = PatchState.Unknown;
                  switch (cache.state) {
                    case PatchState.Unknown:
                      newState = PatchState.Unknown;
                      break;
                    case PatchState.Disabled:
                      newState = PatchState.Enabled;
                      break;
                    case PatchState.Enabled:
                      newState = PatchState.Disabled;
                      break;
                  }

                  // check if no state change takes place
                  if (newState == PatchState.Unknown) {
                    var error = "Patch is invalid: memory mismatch.";
                    if (!ConnectionPool.inst.hasPassword())
                      error = "Patches require a password to be set.";

                    // show error
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(error),
                      backgroundColor: Colors.red,
                      duration: Duration(milliseconds: 700),
                    ));
                    return;
                  }

                  // get connection
                  ConnectionPool.inst.get().then((con) async {

                    // apply new state
                    bool error = false;
                    try {
                      bool result = await cache.patch.setState(
                          con, newState).whenComplete(() {
                        con.free();
                        update();
                      });
                      if (result == null || !result)
                        error = true;
                    } catch (Exception) {
                      con.free();
                      error = true;
                    }

                    // show error
                    if (error) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Error applying patch."),
                        backgroundColor: Colors.red,
                        duration: Duration(milliseconds: 700),
                      ));
                    }

                  }, onError: (e) {

                    // show error
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Please connect to a server."),
                      backgroundColor: Colors.red,
                      duration: Duration(milliseconds: 700),
                    ));
                  });
                },
              );
            }).toList()
        ),
      ),
    );
  }

  _showAddOnlineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.file_download),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Download from URL"),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => PatchDownloadView(),
                  ),
                ).then((_) => update());
              }
          ),
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.share),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Export all online patches"),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                String json = PatchManager.inst.getPatchesJSONOnline();
                if (Platform.isAndroid || Platform.isIOS)
                  Share.share(json);
              }
          ),
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.cancel),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Cancel"),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }
          ),
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.delete_forever),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Remove all online patches"),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                PatchManager.inst.removeOnlinePatches();
                update();
              }
          ),
        ],
      ),
    );
  }

  _showAddCustomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.memory),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Add memory patch"),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => PatchAddCustomView(
                      baseDetails: null,
                      onSave: (patch) {
                        PatchManager.inst.addPatch(patch);
                        update();
                      },
                    ),
                  ),
                ).then((_) => update());
              }
          ),
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.share),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Export all custom patches"),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                String json = PatchManager.inst.getPatchesJSONCustom();
                if (Platform.isAndroid || Platform.isIOS)
                  Share.share(json);
              }
          ),
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.cancel),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Cancel"),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }
          ),
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.delete_forever),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Remove all custom patches"),
                  ),
                ],
              ),
              onPressed: () {
                PatchManager.inst.removeCustomPatches();
                update();
                Navigator.of(context).pop();
              }
          ),
        ],
      ),
    );
  }

  void _showCustomOptions(Patch patch) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(Icons.edit),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text('Edit \'${patch.name}\''),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => PatchAddCustomView(
                      baseDetails: patch,
                      onSave: (patchNew) {
                        PatchManager.inst.removePatch(patch);
                        PatchManager.inst.addPatch(patchNew);
                        update();
                      },
                    ),
                  ),
                );
              }
          ),
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.delete),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text('Remove'),
                ),
              ],
            ),
            onPressed: () {
              PatchManager.inst.removePatch(patch);
              update();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class PatchDownloadView extends StatefulWidget {

  @override
  _PatchDownloadViewState createState() => _PatchDownloadViewState();
}

class _PatchDownloadViewState extends State<PatchDownloadView> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  bool _autoValidateFields = false;
  String _urlInput = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download patches from URL"),
      ),
      body: Form(
        key: _formState,
        child: NoOverglow(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.cloud_download),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _urlInput,
                  decoration: InputDecoration(
                    labelText: "URL",
                    hintText: "http://pastebin.com/raw/example",
                  ),
                  onSaved: (String s) => _urlInput = s,
                  validator: validateURL,
                  autovalidate: _autoValidateFields,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text("Download/Import"),
            onPressed: () async {
              if(_formState.currentState.validate()) {
                _formState.currentState.save();

                // download
                await downloadTextFromURL(_urlInput).then((json) async {
                  try {

                    // parse patches
                    int no1 = PatchManager.inst.countPatches();
                    PatchManager.inst.addPatchesFromJson(json, online: true);
                    int no2 = PatchManager.inst.countPatches();
                    int count = no2 - no1;

                    // show success
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Success"),
                            content: Text("$count patches have been imported!"),
                            actions: [
                              FlatButton(child: Text("Dismiss"), onPressed: () {
                                Navigator.of(context).pop();
                              })
                            ],
                          );
                        }
                    );

                  } on Exception {

                    // show error
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text("Unable to parse from JSON :("),
                          actions: [
                            FlatButton(child: Text("Dismiss"), onPressed: () {
                              Navigator.of(context).pop();
                            })
                          ],
                        );
                      }
                    );
                  }

                }, onError: (e) async {

                  // show error
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text("Unable to download contents :("),
                          actions: [
                            FlatButton(child: Text("Dismiss"), onPressed: () {
                              Navigator.of(context).pop();
                            })
                          ],
                        );
                      }
                  );
                });

                Navigator.of(context).pop();

              } else {
                setState(() {
                  // upon trying to add/write invalid data,
                  // it'll be validated every time the fields change
                  // until you save it.
                  _autoValidateFields = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String validateURL(String cardID) {
    if (!RegExp(r"^(https?:\/\/)?(www\.)?"
        + r"[-a-zA-Z0-9@:%._\+~#=]{1,256}\."
        + r"[a-z]{1,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$").hasMatch(cardID))
      return "Invalid URL!";
    return null;
  }
}


class PatchAddCustomView extends StatefulWidget {
  PatchAddCustomView({@required this.onSave, this.baseDetails});

  final void Function(MemoryPatch) onSave;
  final MemoryPatch baseDetails;

  _PatchAddCustomViewState createState() => _PatchAddCustomViewState();
}

class _PatchAddCustomViewState extends State<PatchAddCustomView> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  bool _autoValidateFields = false;
  MemoryPatch _data;

  @override
  void initState() {
    super.initState();
    if (widget.baseDetails == null) {

      // create new patch
      _data = MemoryPatch.fromMap({
        "name": "",
        "type": "memory",
        "patches": [{}],
      });

      // pre fill data
      if (gameExt.length == 10) {
        _data.dateCodeMin = int.parse(gameExt, onError: (e) {});
        _data.dateCodeMax = int.parse(gameExt, onError: (e) {});
      }
      if (gameModel.length == 3) {
        _data.gameCode = gameModel;
      }

    } else {
      var map = {};
      widget.baseDetails.writeToMap(map);
      _data = MemoryPatch.fromMap(map);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baseDetails == null ? 'Add Patch' : 'Edit Patch'),
      ),
      body: Form(
        key: _formState,
        child: NoOverglow(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Unlock all songs',
                  ),
                  onSaved: (String s) => _data.name = s,
                  validator: validateBasic,
                  autovalidate: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.chat_bubble),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.description,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'This patch unlocks all songs.',
                  ),
                  onSaved: (String s) => _data.description = s,
                  validator: null,
                  autovalidate: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.gameCode,
                  decoration: InputDecoration(
                    labelText: 'Game Code',
                    hintText: 'LDJ',
                  ),
                  onSaved: (String s) => _data.gameCode = s,
                  validator: validateGameCode,
                  autovalidate: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.dateCodeMax == 0 ? null
                      : _data.dateCodeMax.toString(),
                  decoration: InputDecoration(
                    labelText: 'Date Code',
                    hintText: '2019010100',
                  ),
                  onSaved: (String s) {
                    int dateCode = int.parse(s);
                    _data.dateCodeMin = dateCode;
                    _data.dateCodeMax = dateCode;
                  },
                  validator: validateNumber,
                  autovalidate: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.library_books),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.getPatches()[0].dllName,
                  decoration: InputDecoration(
                    labelText: 'DLL Name',
                    hintText: 'bm2dx.dll',
                  ),
                  onSaved: (s) => _data.getPatches()[0].dllName = s,
                  validator: validateDLL,
                  autovalidate: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.memory),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.getPatches()[0].dataEnabled,
                  decoration: InputDecoration(
                    labelText: 'Data Enabled (Hex)',
                    hintText: '9090909090',
                  ),
                  onSaved: (s) {
                    _data.getPatches()[0].dataEnabled = s.replaceAll(
                        new RegExp(r"\s+\b|\b\s"), "");
                  },
                  validator: validateHex,
                  autovalidate: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.memory),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.getPatches()[0].dataDisabled,
                  decoration: InputDecoration(
                    labelText: 'Data Disabled (Hex)',
                    hintText: 'E900000000',
                  ),
                  onSaved: (s) {
                    _data.getPatches()[0].dataDisabled = s.replaceAll(
                        new RegExp(r"\s+\b|\b\s"), "");
                  },
                  validator: validateHex,
                  autovalidate: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.getPatches()[0].dataOffset == 0 ? null :
                    _data.getPatches()[0].dataOffset.toString(),
                  decoration: InputDecoration(
                    labelText: 'Offset',
                    hintText: '0xFFFF / 65535',
                  ),
                  onSaved: (String s) {
                    int parsed = int.parse(s);
                    _data.getPatches()[0].dataOffset = parsed;
                  },
                  validator: validateNumber,
                  autovalidate: _autoValidateFields,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text(widget.baseDetails == null ? 'Add' : 'Save'),
            onPressed: () {
              if(_formState.currentState.validate()) {
                _formState.currentState.save();
                widget.onSave(_data);
                Navigator.of(context).pop();
              } else {
                setState(() {
                  // upon trying to add/resave invalid data,
                  // it'll be validated every time the fields change
                  // until you save it.
                  _autoValidateFields = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String validateBasic(String s) {
    if (s.length == 0) return "Can't be empty!";
    return null;
  }

  String validateNumber(String s) {
    if (s.length == 0) return "Can't be empty!";
    var parsed = int.tryParse(s);
    return parsed == null ? "Invalid number!" : null;
  }

  String validateGameCode(String s) {
    if (s.length == 0) return "Can't be empty!";
    if (s.length != 3) return "Must be 3 letters!";
    return null;
  }

  String validateDLL(String s) {
    if (!RegExp(r"^[a-zA-Z0-9]+\.(dll|exe)$").hasMatch(s))
      return "Invalid DLL name!";
    return null;
  }

  String validateHex(String s) {
    s = s.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (!RegExp(r"^([a-zA-Z0-9][a-zA-Z0-9])+$").hasMatch(s))
      return "Must be a valid hex string!";
    return null;
  }
}
