part of util;

enum PatchState {
  Unknown,
  Enabled,
  Disabled
}

abstract class Patch {

  String name = "Patch";
  String description = "";
  String gameCode = "";
  int dateCodeMin = 0;
  int dateCodeMax = 0;
  bool preset = false;
  bool online = false;

  static Patch parseMap(Map map) {
    var type = map["type"] ?? "null";
    switch (type) {
      case "memory":
        return MemoryPatch.fromMap(map);
      case "signature":
        return SignaturePatch.fromMap(map);
      default:
        throw FormatException("Unknown patch type: $type");
    }
  }

  Patch.fromMap(Map map) {
    name = map["name"] ?? name;
    description = map["description"] ?? description;
    gameCode = map["gameCode"] ?? gameCode;
    if (map["dateCode"] != null) {
      dateCodeMin = map["dateCode"];
      dateCodeMax = map["dateCode"];
    } else {
      dateCodeMin = map["dateCodeMin"] ?? dateCodeMin;
      dateCodeMax = map["dateCodeMax"] ?? dateCodeMax;
    }
    preset = map["preset"] ?? preset;
    online = map["online"] ?? online;
  }

  void writeToMap(Map map) {
    map["name"] = name;
    map["description"] = description;
    map["gameCode"] = gameCode;
    map["dateCodeMin"] = dateCodeMin;
    map["dateCodeMax"] = dateCodeMax;
    map["preset"] = preset;
    map["online"] = online;
  }

  bool isInRange(int dateCode) {
    if (dateCodeMin == 0 && dateCodeMax == 0)
      return true;
    if (dateCodeMax == 0)
      return dateCode >= dateCodeMin;
    return dateCode >= dateCodeMin && dateCode <= dateCodeMax;
  }

  Future<bool> isApplicable(Connection con) async {
    return await getState(con) != PatchState.Unknown;
  }

  Future<PatchState> getState(Connection con) async {
    return PatchState.Unknown;
  }

  Future<bool> setState(Connection con, PatchState state) async {
    return false;
  }

  void resetState() {
  }

}

class _MemoryPatchData {
  String dllName = "";
  String dataEnabled = "";
  String dataDisabled = "";
  int dataOffset = 0;
}

class MemoryPatch extends Patch {

  List<_MemoryPatchData> _patches = List<_MemoryPatchData>();

  MemoryPatch.fromMap(Map map) : super.fromMap(map) {
    for (var patch in map["patches"] ?? []) {
      var data = _MemoryPatchData();
      data.dllName = patch["dllName"] ?? data.dllName;
      data.dataEnabled = trimHex(patch["dataEnabled"] ?? data.dataEnabled);
      data.dataDisabled = trimHex(patch["dataDisabled"] ?? data.dataDisabled);
      var offset = patch["dataOffset"] ?? data.dataOffset;
      if (offset is String)
        data.dataOffset = int.parse(offset);
      else
        data.dataOffset = offset;
      this._patches.add(data);
    }
    this.resetState();
  }

  List<_MemoryPatchData> getPatches() {
    return _patches;
  }

  @override
  void writeToMap(Map map) {
    super.writeToMap(map);
    map["type"] = "memory";

    // add all patches
    List patchesList = List();
    for (var data in _patches) {
      Map patch = Map();
      patch["dllName"] = data.dllName;
      patch["dataEnabled"] = trimHex(data.dataEnabled);
      patch["dataDisabled"] = trimHex(data.dataDisabled);
      patch["dataOffset"] = data.dataOffset;
      patchesList.add(patch);
    }
    map["patches"] = patchesList;
  }

  @override
  Future<PatchState> getState(Connection con) async {

    // get state for each patch
    List<PatchState> states = List();
    for (var patch in _patches)
      states.add(await getSingleState(con, patch));

    // get final patch state
    bool disabled = false;
    for (var state in states) {
      switch (state) {
        case PatchState.Unknown:
          return PatchState.Unknown;
        case PatchState.Enabled:
          if (disabled)
            return PatchState.Unknown;
          continue;
        case PatchState.Disabled:
          disabled = true;
      }
    }

    // we return enabled/disabled only if all states match
    if (disabled)
      return PatchState.Disabled;
    else
      return PatchState.Enabled;
  }

  Future<PatchState> getSingleState(
      Connection con, _MemoryPatchData patch) async {

    // check super state
    var superState = await super.getState(con);
    if (superState != PatchState.Unknown)
      return superState;

    // check lengths
    if (patch.dataEnabled.length == 0 && patch.dataDisabled.length == 0)
      return PatchState.Unknown;

    // read memory
    return memoryRead(
        con,
        patch.dllName,
        patch.dataOffset,
        max(patch.dataEnabled.length, patch.dataDisabled.length) >> 1
    ).then((data) {

      // check data
      if (patch.dataEnabled.length > 0 && data.startsWith(patch.dataEnabled))
        return PatchState.Enabled;
      else if (patch.dataDisabled.length > 0 &&
          data.startsWith(patch.dataDisabled))
        return PatchState.Disabled;
      return PatchState.Unknown;

    }, onError: (_) {
      return PatchState.Unknown;
    });
  }

  @override
  Future<bool> setState(Connection con, PatchState state) async {

    // set state for each patch
    List<bool> states = List();
    for (var patch in _patches)
      states.add(await setSingleState(con, state, patch));

    // check for failure
    for (var state in states)
      if (!state)
        return false;
    return true;
  }

  Future<bool> setSingleState(
      Connection con, PatchState state, _MemoryPatchData patch) async {

    // check super
    if (await super.setState(con, state))
      return true;

    // check state
    switch (state) {
      case PatchState.Unknown:
        return true;
      case PatchState.Enabled:
        return memoryWrite(
            con, patch.dllName, patch.dataEnabled, patch.dataOffset).then((_) {
          return true;
        });
      case PatchState.Disabled:
        return memoryWrite(
            con, patch.dllName, patch.dataDisabled, patch.dataOffset).then((_) {
          return true;
        });
      default:
        return false;
    }
  }
}

class SignaturePatch extends Patch {

  String dllName = "";
  String signature = "";
  String replacement = "";
  int offset = 0;
  int usage = 0;

  // state
  int rawOffset = 0;
  String dataDisabled = "";

  @override
  void resetState() {
    super.resetState();
    this.rawOffset = 0;
    this.dataDisabled = "";
  }

  SignaturePatch.fromMap(Map map) : super.fromMap(map) {
    dllName = map["dllName"] ?? dllName;
    signature = trimHex(map["signature"] ?? signature);
    replacement = trimHex(map["replacement"] ?? replacement);
    offset = map["offset"] ?? offset;
    usage = map["usage"] ?? usage;
    this.resetState();
  }

  @override
  void writeToMap(Map map) {
    super.writeToMap(map);
    map["type"] = "signature";
    map["dllName"] = dllName;
    map["signature"] = signature;
    map["replacement"] = replacement;
    map["offset"] = offset;
    map["usage"] = usage;
  }

  @override
  Future<PatchState> getState(Connection con) async {

    // check super state
    var superState = await super.getState(con);
    if (superState != PatchState.Unknown)
      return superState;

    // check raw offset since it will be non-zero once enabled
    if (rawOffset > 0)
      return PatchState.Enabled;

    // check if the signature can be found
    return PatchState.Disabled;
  }

  @override
  Future<bool> setState(Connection con, PatchState state) async {

    // check super
    if (await super.setState(con, state))
      return true;

    // check state
    switch (state) {
      case PatchState.Unknown:
        return true;
      case PatchState.Enabled:

        // find patch position
        return memorySignature(
            con,
            dllName,
            signature,
            "",
            offset,
            usage
        ).then((rawOffset) async {

          // remember data
          this.rawOffset = rawOffset;
          return memoryRead(
              con,
              dllName,
              rawOffset,
              replacement.length
          ).then((data) {
            this.dataDisabled = data;

            // actually apply the patch
            return memorySignature(
                con, dllName, signature, replacement, offset, usage
            ).then((rawOffset2) {

              // both offsets should be exactly the same
              if (rawOffset == rawOffset2)
                return true;

              // failure - shouldn't happen in practice
              this.resetState();
              return false;

            }, onError: (e) {
              this.resetState();
              return false;
            });
          }, onError: (e) {
            this.resetState();
            return false;
          });

        }, onError: (e) => false);

      case PatchState.Disabled:

        // write old data back
        return memoryWrite(
            con, dllName, dataDisabled, rawOffset
        ).then((_) {
          this.resetState();
          return true;
        }, onError: (e) {
          return false;
        });
      default:
        return false;
    }
  }
}

class PatchManager {
  static const preferencesKeyPatches = "patch_manager_patches";

  // app wide instance
  static PatchManager inst = PatchManager();

  // list of all patches
  Map<String, List<Patch>> _patchList = Map();

  PatchManager();

  void importDefaults() async {

    // load file list
    var files = jsonDecode(await rootBundle.loadString(
        "assets/patches/presets.json", cache: false));

    // import patches from each file
    for (var file in files) {
      try {
        var json = await rootBundle.loadString(
            "assets/patches/$file", cache: false);
        addPatchesFromJson(json);
      } on Error catch (e) {
        print("Failed importing presets from $file: ${e.toString()}");
      }
    }
    int presetPatches = countPatches();

    // load patches from preferences
    await this._load();

    // print number of loaded patches
    print("Loaded $presetPatches preset patches.");
    print("Loaded ${countPatches() - presetPatches} saved patches.");
  }

  void _save() async {
    String json = this.getPatchesJSON();
    Storage storage = window.localStorage;
    storage[preferencesKeyPatches] = json;
  }

  Future<void> _load() async {
    Storage storage = window.localStorage;
    if (storage.containsKey(preferencesKeyPatches)) {
      String json = storage[preferencesKeyPatches];
      try {
        addPatchesFromJson(json);
      } on Error {
        storage.remove(preferencesKeyPatches);
      }
    }
  }

  int countPatches() {
    int count = 0;
    for (var list in _patchList.values)
      count += list.length;
    return count;
  }

  String getPatchesJSON() {

    // write patches to map
    List data = List();
    _patchList.forEach((gameCode, list) {
      list.forEach((patch) {
        if (!patch.preset) {
          Map map = Map();
          patch.writeToMap(map);
          data.add(map);
        }
      });
    });

    // encode
    return jsonEncode(data);
  }

  String getPatchesJSONCustom() {
    List data = List();
    _patchList.forEach((gameCode, list) {
      list.forEach((patch) {
        if (!patch.preset && !patch.online) {
          Map map = Map();
          patch.writeToMap(map);
          data.add(map);
        }
      });
    });
    return jsonEncode(data);
  }

  String getPatchesJSONOnline() {
    List data = List();
    _patchList.forEach((gameCode, list) {
      list.forEach((patch) {
        if (!patch.preset && patch.online) {
          Map map = Map();
          patch.writeToMap(map);
          data.add(map);
        }
      });
    });
    return jsonEncode(data);
  }

  List<Patch> getPatches(String gameCode, int dateCode) {
    List<Patch> resultList = List();
    var gamePatches = _patchList[gameCode] ?? List();
    for (var patch in gamePatches) {
      if (patch.isInRange(dateCode))
        resultList.add(patch);
    }
    return resultList;
  }

  void addPatch(Patch patch, {bool save = true}) {

    // get game list of patches
    var gamePatches = _patchList[patch.gameCode] ?? List();

    // check for duplicates
    gamePatches.removeWhere((patch2) {
      return patch2.name == patch.name &&
          patch2.dateCodeMin == patch.dateCodeMin &&
          patch2.dateCodeMax == patch.dateCodeMax &&
          patch2.online == patch.online &&
          patch2.preset == patch.preset;
    });

    // add to patches
    gamePatches.add(patch);
    _patchList[patch.gameCode] = gamePatches;

    // save
    if (save)
      this._save();
  }

  void removePatch(Patch patch, {bool save = true}) {
    var list = _patchList[patch.gameCode];
    if (list != null)
      list.removeWhere((patch2) {
        return patch.name == patch2.name
            && patch.gameCode == patch2.gameCode
            && patch.dateCodeMin == patch2.dateCodeMin
            && patch.dateCodeMax == patch2.dateCodeMax
            && patch.preset == patch2.preset
            && patch.online == patch2.online;
      });
    if (save)
      this._save();
  }

  void addPatchFromMap(Map map) {
    addPatch(Patch.parseMap(map));
  }

  void addPatchesFromJson(String json, {bool online = false}) {
    List data = jsonDecode(json);
    for (var map in data) {

      // forced values for online imports
      if (online) {
        map["preset"] = false;
        map["online"] = true;
      }

      addPatchFromMap(map);
    }
  }

  void removeOnlinePatches() {
    for (var list in _patchList.values)
      list.removeWhere((patch) => patch.online);
  }

  void removeCustomPatches() {
    for (var list in _patchList.values)
      list.removeWhere((patch) => !patch.preset && !patch.online);
  }

  void resetStates() {
    _patchList.forEach((gameCode, patchList) {
      patchList.forEach((patch) {
        patch.resetState();
      });
    });
  }

}