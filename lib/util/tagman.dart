part of util;

class TagManager {
  static TagManager inst = new TagManager();

  StreamController<String> tagStream;

  TagManager() {
    this.tagStream = StreamController<String>.broadcast();
  }

  void dispose() {
    this.tagStream.close();
  }

  Future<void> start() async {

    // subscribe
    /*FlutterNfcReader.read.listen((data) async {

      // get data
      String idData = data.id;
      if (idData.startsWith("0x"))
        idData = idData.substring(2);

      // check if valid hex
      if (idData.length % 2 == 0 &&
          RegExp(r"^([a-zA-Z0-9][a-zA-Z0-9])+$").hasMatch(idData)) {

        // upper case
        idData = idData.toUpperCase();

        // reverse bytes if this is an ISO-15693 card (E004 cards)
        String id = "";
        if (idData.endsWith("04E0")) {
          for (int i = idData.length - 2; i >= 0; i -= 2) {
            id += idData.substring(i, i + 2);
          }
        } else {
          id = idData;
        }

        // trim size if too big
        if (id.length > 16)
          id = id.substring(0, 16);

        // fill with zeroes
        while (id.length < 16)
          id += "0";

        // check length
        if (id.length == 16)
          this.tagStream.add(id);
      }
    }, onError: (e) {
      print("NFC features unavailable.");
    });*/
  }
}
