part of util;


class CardCipher {

  // all valid cipher characters in correct order
  static const String CIPHER_CHARS = "0123456789ABCDEFGHJKLMNPRSTUWXYZ";

  static String encode(String cardID) {

    // check length
    if (cardID.length != 16)
      throw new Exception("cardID must be of length 16");

    // capitalize
    cardID = cardID.toUpperCase();

    // convert to reversed list of int
    List<int> cardIDData = HEX.decode(cardID).reversed.toList(growable: false);

    // encipher
    List<int> cipher = cardIDData.map((e) => e).toList(growable: false);
    unpack(cipher, cipher2(0x00, pack(cipher)));
    unpack(cipher, cipher1(0x20, pack(cipher)));
    unpack(cipher, cipher2(0x40, pack(cipher)));

    // convert to 5 bit
    final List<int> bits = List<int>(65);
    for (int i = 0; i < 64; i++)
      bits[i] = (cipher[i >> 3] >> (~i & 7)) & 1;
    bits[64] = 0;
    final List<int> parts = List<int>(16);
    for (int i = 0; i < 13; i++) {
      parts[i] = 0;
      for (int n = 0; n < 5; n++)
        parts[i] |= bits[i * 5 + n] << 4 - n;
    }

    // get card type
    final int cardType = card_type(cardID);

    // make it 14 parts
    parts[0] ^= cardType;
    parts[13] = 1;
    for (int i = 1; i < 14; i++)
      parts[i] ^= parts[i - 1];

    // special fields
    parts[14] = cardType;
    parts[15] = 0;
    parts[15] = checksum(parts);

    // build string
    String cipherText = "";
    for (int i = 0; i < 16; i++)
      cipherText += CIPHER_CHARS[parts[i]];

    // return cipher text
    return cipherText;
  }

  static String decode(String cipher) {

    // capitalize
    cipher = cipher.toUpperCase();

    // remove invalid characters
    cipher = cipher.trim();
    cipher = cipher.replaceAll("-", "");
    cipher = cipher.replaceAll(" ", "");
    cipher = cipher.replaceAll("O", "0");
    cipher = cipher.replaceAll("I", "1");

    // check length
    if (cipher.length != 16)
      throw new Exception("Cipher not of length 16: " + cipher);

    // convert to parts
    List<int> parts = new List<int>(16);
    for (int offset = 0; offset < 16; offset++) {

      // get character
      String c = cipher[offset];

      // find character in array
      int value = -1;
      for (int n = 0; n < CIPHER_CHARS.length; n++) {
        if (c == CIPHER_CHARS[n]) {
          value = n;
          break;
        }
      }

      // character not found
      if (value < 0)
        throw new Exception("Invalid card cipher character: " + c);

      // save value
      parts[offset] = value;
    }

    // convert to 13 parts
    for (int i = 13; i > 0; i--)
      parts[i] ^= parts[i - 1];
    parts[0] ^= parts[14];

    // convert to bits
    List<int> bits = new List<int>(64);
    for (int i = 0; i < 64; i++)
      bits[i] = (parts[i ~/ 5] >> (4 - (i % 5))) & 1;

    // pack into bytes
    List<int> cipherBytes = new List<int>(8);
    for (int i = 0; i < 8; i++)
      cipherBytes[i] = 0;
    for (int i = 0; i < 64; i++)
      cipherBytes[i ~/ 8] |= bits[i] << (~i & 7);

    // decipher
    List<int> decipheredBytes = new List<int>(cipherBytes.length);
    unpack(decipheredBytes, cipher1(0x40, pack(cipherBytes)));
    unpack(decipheredBytes, cipher2(0x20, pack(decipheredBytes)));
    unpack(decipheredBytes, cipher1(0x00, pack(decipheredBytes)));

    // reverse
    decipheredBytes = decipheredBytes.reversed.toList();

    // convert to hex
    return HEX.encode(decipheredBytes).toUpperCase();
  }

  static int cipher1(int off, int state) {

    // extract long
    int higher = state >> 32;
    int lower = state & 0xFFFFFFFF;

    // loop
    for (int i = 0; i < 32; i += 4) {

      int lowerROR = rotateRight(higher ^ KEY[off + 31 - i], 28);
      int lowerXOR = 0;
      lowerXOR ^= LOOKUP1[((higher ^ KEY[off + 30 - i]) >> 26) & 0x3F];
      lowerXOR ^= LOOKUP2[((higher ^ KEY[off + 30 - i]) >> 18) & 0x3F];
      lowerXOR ^= LOOKUP3[((higher ^ KEY[off + 30 - i]) >> 10) & 0x3F];
      lowerXOR ^= LOOKUP4[((higher ^ KEY[off + 30 - i]) >> 2) & 0x3F];
      lowerXOR ^= LOOKUP5[(lowerROR >> 26) & 0x3F];
      lowerXOR ^= LOOKUP6[(lowerROR >> 18) & 0x3F];
      lowerXOR ^= LOOKUP7[(lowerROR >> 10) & 0x3F];
      lowerXOR ^= LOOKUP8[(lowerROR >> 2) & 0x3F];
      lower ^= lowerXOR;

      int higherROR = rotateRight(lower ^ KEY[off + 29 - i], 28);
      int higherXOR = 0;
      higherXOR ^= LOOKUP1[((lower ^ KEY[off + 28 - i]) >> 26) & 0x3F];
      higherXOR ^= LOOKUP2[((lower ^ KEY[off + 28 - i]) >> 18) & 0x3F];
      higherXOR ^= LOOKUP3[((lower ^ KEY[off + 28 - i]) >> 10) & 0x3F];
      higherXOR ^= LOOKUP4[((lower ^ KEY[off + 28 - i]) >> 2) & 0x3F];
      higherXOR ^= LOOKUP5[(higherROR >> 26) & 0x3F];
      higherXOR ^= LOOKUP6[(higherROR >> 18) & 0x3F];
      higherXOR ^= LOOKUP7[(higherROR >> 10) & 0x3F];
      higherXOR ^= LOOKUP8[(higherROR >> 2) & 0x3F];
      higher ^= higherXOR;
    }

    // join values
    return (higher << 32) | (lower & 0xFFFFFFFF);
  }

  static int cipher2(int off, int state) {

    // extract long
    int higher = (state >> 32);
    int lower = state & 0xFFFFFFFF;

    // loop
    for (int i = 0; i < 32; i += 4) {

      // process lower
      int lowerROR = rotateRight(higher ^ KEY[off + i + 1], 28);
      int lowerXOR = 0;
      lowerXOR ^= LOOKUP5[(lowerROR >> 26) & 0x3F];
      lowerXOR ^= LOOKUP6[(lowerROR >> 18) & 0x3F];
      lowerXOR ^= LOOKUP7[(lowerROR >> 10) & 0x3F];
      lowerXOR ^= LOOKUP8[(lowerROR >> 2) & 0x3F];
      lowerXOR ^= LOOKUP1[((higher ^ KEY[off + i]) >> 26) & 0x3F];
      lowerXOR ^= LOOKUP2[((higher ^ KEY[off + i]) >> 18) & 0x3F];
      lowerXOR ^= LOOKUP3[((higher ^ KEY[off + i]) >> 10) & 0x3F];
      lowerXOR ^= LOOKUP4[((higher ^ KEY[off + i]) >> 2) & 0x3F];
      lower ^= lowerXOR;

      // process higher
      int higherROR = rotateRight(lower ^ KEY[off + i + 3], 28);
      int higherXOR = 0;
      higherXOR ^= LOOKUP5[(higherROR >> 26) & 0x3F];
      higherXOR ^= LOOKUP6[(higherROR >> 18) & 0x3F];
      higherXOR ^= LOOKUP7[(higherROR >> 10) & 0x3F];
      higherXOR ^= LOOKUP8[(higherROR >> 2) & 0x3F];
      higherXOR ^= LOOKUP1[((lower ^ KEY[off + i + 2]) >> 26) & 0x3F];
      higherXOR ^= LOOKUP2[((lower ^ KEY[off + i + 2]) >> 18) & 0x3F];
      higherXOR ^= LOOKUP3[((lower ^ KEY[off + i + 2]) >> 10) & 0x3F];
      higherXOR ^= LOOKUP4[((lower ^ KEY[off + i + 2]) >> 2) & 0x3F];
      higher ^= higherXOR;
    }

    // join values
    return (higher << 32) | (lower & 0xFFFFFFFF);
  }

  static int card_type(String cardID) {
    if (cardID.startsWith("E0"))
      return 1;
    if (cardID.startsWith("01"))
      return 2;
    throw new Exception("Unknown card type: " + cardID);
  }

  static int checksum(List<int> buffer) {
    int chk = 0;
    for (int i = 0; i < buffer.length; i++)
      chk += (i % 3 + 1) * (buffer[i] & 0xFF);
    while (chk >= 0x20)
      chk = (chk & 0x1F) + (chk >> 5);
    return chk & 0xFF;
  }

  static int rotateRight(int val, int amount) {
    val = val & 0xFFFFFFFF;
    return ((val << (32 - amount)) | (val >> amount)) & 0xFFFFFFFF;
  }

  static void unpack(List<int> buffer, int state) {

    // magical algorithm
    int i1 = state >> 32;
    int i2 = state;
    int i3 = rotateRight(i2, 31);
    int i4 = (i1 ^ i3) & 0x55555555;
    int i5 = i4 ^ i3;
    int i6 = rotateRight(i4 ^ i1, 31);
    int i7 = (i6 ^ (i5 >> 8)) & 0x00FF00FF;
    int i8 = i5 ^ (i7 << 8);
    int i9 = i7 ^ i6;
    int i10 = ((i9 >> 2) ^ i8) & 0x33333333;
    int i11 = (i10 << 2) ^ i9;
    int i12 = i10 ^ i8;
    int i13 = (i11 ^ (i12 >> 16)) & 0x0000FFFF;
    int i14 = i12 ^ (i13 << 16);
    int i15 = i13 ^ i11;
    int i16 = (i14 ^ (i15 >> 4)) & 0x0F0F0F0F;
    int i17 = (i16 << 4) ^ i15;
    int i18 = i16 ^ i14;

    // write to buffer
    buffer[0] = i18 & 0xFF;
    buffer[1] = (i18 >> 8) & 0xFF;
    buffer[2] = (i18 >> 16) & 0xFF;
    buffer[3] = (i18 >> 24) & 0xFF;
    buffer[4] = i17 & 0xFF;
    buffer[5] = (i17 >> 8) & 0xFF;
    buffer[6] = (i17 >> 16) & 0xFF;
    buffer[7] = (i17 >> 24) & 0xFF;
  }

  static int pack(List<int> buffer) {

    // unpack
    int val1 = buffer[0] & 0xFF;
    val1 |= (buffer[1] & 0xFF) << 8;
    val1 |= (buffer[2] & 0xFF) << 16;
    val1 |= (buffer[3] & 0xFF) << 24;
    int val2 = buffer[4] & 0xFF;
    val2 |= (buffer[5] & 0xFF) << 8;
    val2 |= (buffer[6] & 0xFF) << 16;
    val2 |= (buffer[7] & 0xFF) << 24;

    // magical algorithm
    int i1 = (((val1 ^ (val2 >> 4)) & 0x0F0F0F0F) << 4) ^ val2;
    int i2 = ((val1 ^ (val2 >> 4)) & 0x0F0F0F0F) ^ val1;
    int i3 = (i1 ^ (i2 >> 16)) & 0x0000FFFF;
    int i4 = ((i1 ^ (i2 >> 16)) << 16) ^ i2;
    int i5 = i3 ^ i1;
    int i6 = (i4 ^ (i5 >> 2)) & 0x33333333;
    int i7 = i5 ^ (i6 << 2);
    int i8 = i6 ^ i4;
    int i9 = (i7 ^ (i8 >> 8)) & 0x00FF00FF;
    int i10 = i8 ^ (i9 << 8);
    int i11 = rotateRight(i9 ^ i7, 1);
    int i12 = (i10 ^ i11) & 0x55555555;
    int i13 = rotateRight(i12 ^ i10, 1);
    int i14 = i12 ^ i11;

    // pack
    return (i13 << 32) | (i14 & 0xFFFFFFFF);
  }

  // Lookup Tables

  static const List<int> KEY = [
    0x20d0d03c, 0x868ecb41, 0xbcd89c84, 0x4c0e0d0d,
    0x84fc30ac, 0x4cc1890e, 0xfc5418a4, 0x02c50f44,
    0x68acb4e0, 0x06cd4a4e, 0xcc28906c, 0x4f0c8ac0,
    0xb03ca468, 0x884ac7c4, 0x389490d8, 0xcf80c6c2,
    0x58d87404, 0xc48ec444, 0xb4e83c50, 0x498d0147,
    0x64f454c0, 0x4c4701c8, 0xec302cc4, 0xc6c949c1,
    0xc84c00f0, 0xcdcc49cc, 0x883c5cf4, 0x8b0fcb80,
    0x703cc0b0, 0xcb820a8d, 0x78804c8c, 0x4fca830e,
    0x80d0f03c, 0x8ec84f8c, 0x98c89c4c, 0xc80d878f,
    0x54bc949c, 0xc801c5ce, 0x749078dc, 0xc3c80d46,
    0x2c8070f0, 0x0cce4dcf, 0x8c3874e4, 0x8d448ac3,
    0x987cac70, 0xc0c20ac5, 0x288cfc78, 0xc28543c8,
    0x4c8c7434, 0xc50e4f8d, 0x8468f4b4, 0xcb4a0307,
    0x2854dc98, 0x48430b45, 0x6858fce8, 0x4681cd49,
    0xd04808ec, 0x458d0fcb, 0xe0a48ce4, 0x880f8fce,
    0x7434b8fc, 0xce080a8e, 0x5860fc6c, 0x46c886cc,
    0xd01098a4, 0xce090b8c, 0x1044cc2c, 0x86898e0f,
    0xd0809c3c, 0x4a05860f, 0x54b4f80c, 0x4008870e,
    0x1480b88c, 0x0ac8854f, 0x1c9034cc, 0x08444c4e,
    0x0cb83c64, 0x41c08cc6, 0x1c083460, 0xc0c603ce,
    0x2ca0645c, 0x818246cb, 0x0408e454, 0xc5464487,
    0x88607c18, 0xc1424187, 0x284c7c90, 0xc1030509,
    0x40486c94, 0x4603494b, 0xe0404ce4, 0x4109094d,
    0x60443ce4, 0x4c0b8b8d, 0xe054e8bc, 0x02008e89,
  ];

  static const List<int> LOOKUP1 = [
    0x02080008, 0x02082000, 0x00002008, 0x00000000,
    0x02002000, 0x00080008, 0x02080000, 0x02082008,
    0x00000008, 0x02000000, 0x00082000, 0x00002008,
    0x00082008, 0x02002008, 0x02000008, 0x02080000,
    0x00002000, 0x00082008, 0x00080008, 0x02002000,
    0x02082008, 0x02000008, 0x00000000, 0x00082000,
    0x02000000, 0x00080000, 0x02002008, 0x02080008,
    0x00080000, 0x00002000, 0x02082000, 0x00000008,
    0x00080000, 0x00002000, 0x02000008, 0x02082008,
    0x00002008, 0x02000000, 0x00000000, 0x00082000,
    0x02080008, 0x02002008, 0x02002000, 0x00080008,
    0x02082000, 0x00000008, 0x00080008, 0x02002000,
    0x02082008, 0x00080000, 0x02080000, 0x02000008,
    0x00082000, 0x00002008, 0x02002008, 0x02080000,
    0x00000008, 0x02082000, 0x00082008, 0x00000000,
    0x02000000, 0x02080008, 0x00002000, 0x00082008,
  ];

  static const List<int> LOOKUP2 = [
    0x08000004, 0x00020004, 0x00000000, 0x08020200,
    0x00020004, 0x00000200, 0x08000204, 0x00020000,
    0x00000204, 0x08020204, 0x00020200, 0x08000000,
    0x08000200, 0x08000004, 0x08020000, 0x00020204,
    0x00020000, 0x08000204, 0x08020004, 0x00000000,
    0x00000200, 0x00000004, 0x08020200, 0x08020004,
    0x08020204, 0x08020000, 0x08000000, 0x00000204,
    0x00000004, 0x00020200, 0x00020204, 0x08000200,
    0x00000204, 0x08000000, 0x08000200, 0x00020204,
    0x08020200, 0x00020004, 0x00000000, 0x08000200,
    0x08000000, 0x00000200, 0x08020004, 0x00020000,
    0x00020004, 0x08020204, 0x00020200, 0x00000004,
    0x08020204, 0x00020200, 0x00020000, 0x08000204,
    0x08000004, 0x08020000, 0x00020204, 0x00000000,
    0x00000200, 0x08000004, 0x08000204, 0x08020200,
    0x08020000, 0x00000204, 0x00000004, 0x08020004,
  ];

  static const List<int> LOOKUP3 = [
    0x80040100, 0x01000100, 0x80000000, 0x81040100,
    0x00000000, 0x01040000, 0x81000100, 0x80040000,
    0x01040100, 0x81000000, 0x01000000, 0x80000100,
    0x81000000, 0x80040100, 0x00040000, 0x01000000,
    0x81040000, 0x00040100, 0x00000100, 0x80000000,
    0x00040100, 0x81000100, 0x01040000, 0x00000100,
    0x80000100, 0x00000000, 0x80040000, 0x01040100,
    0x01000100, 0x81040000, 0x81040100, 0x00040000,
    0x81040000, 0x80000100, 0x00040000, 0x81000000,
    0x00040100, 0x01000100, 0x80000000, 0x01040000,
    0x81000100, 0x00000000, 0x00000100, 0x80040000,
    0x00000000, 0x81040000, 0x01040100, 0x00000100,
    0x01000000, 0x81040100, 0x80040100, 0x00040000,
    0x81040100, 0x80000000, 0x01000100, 0x80040100,
    0x80040000, 0x00040100, 0x01040000, 0x81000100,
    0x80000100, 0x01000000, 0x81000000, 0x01040100,
  ];

  static const List<int> LOOKUP4 = [
    0x04010801, 0x00000000, 0x00010800, 0x04010000,
    0x04000001, 0x00000801, 0x04000800, 0x00010800,
    0x00000800, 0x04010001, 0x00000001, 0x04000800,
    0x00010001, 0x04010800, 0x04010000, 0x00000001,
    0x00010000, 0x04000801, 0x04010001, 0x00000800,
    0x00010801, 0x04000000, 0x00000000, 0x00010001,
    0x04000801, 0x00010801, 0x04010800, 0x04000001,
    0x04000000, 0x00010000, 0x00000801, 0x04010801,
    0x00010001, 0x04010800, 0x04000800, 0x00010801,
    0x04010801, 0x00010001, 0x04000001, 0x00000000,
    0x04000000, 0x00000801, 0x00010000, 0x04010001,
    0x00000800, 0x04000000, 0x00010801, 0x04000801,
    0x04010800, 0x00000800, 0x00000000, 0x04000001,
    0x00000001, 0x04010801, 0x00010800, 0x04010000,
    0x04010001, 0x00010000, 0x00000801, 0x04000800,
    0x04000801, 0x00000001, 0x04010000, 0x00010800,
  ];

  static const List<int> LOOKUP5 = [
    0x00000400, 0x00000020, 0x00100020, 0x40100000,
    0x40100420, 0x40000400, 0x00000420, 0x00000000,
    0x00100000, 0x40100020, 0x40000020, 0x00100400,
    0x40000000, 0x00100420, 0x00100400, 0x40000020,
    0x40100020, 0x00000400, 0x40000400, 0x40100420,
    0x00000000, 0x00100020, 0x40100000, 0x00000420,
    0x40100400, 0x40000420, 0x00100420, 0x40000000,
    0x40000420, 0x40100400, 0x00000020, 0x00100000,
    0x40000420, 0x00100400, 0x40100400, 0x40000020,
    0x00000400, 0x00000020, 0x00100000, 0x40100400,
    0x40100020, 0x40000420, 0x00000420, 0x00000000,
    0x00000020, 0x40100000, 0x40000000, 0x00100020,
    0x00000000, 0x40100020, 0x00100020, 0x00000420,
    0x40000020, 0x00000400, 0x40100420, 0x00100000,
    0x00100420, 0x40000000, 0x40000400, 0x40100420,
    0x40100000, 0x00100420, 0x00100400, 0x40000400,
  ];

  static const List<int> LOOKUP6 = [
    0x00800000, 0x00001000, 0x00000040, 0x00801042,
    0x00801002, 0x00800040, 0x00001042, 0x00801000,
    0x00001000, 0x00000002, 0x00800002, 0x00001040,
    0x00800042, 0x00801002, 0x00801040, 0x00000000,
    0x00001040, 0x00800000, 0x00001002, 0x00000042,
    0x00800040, 0x00001042, 0x00000000, 0x00800002,
    0x00000002, 0x00800042, 0x00801042, 0x00001002,
    0x00801000, 0x00000040, 0x00000042, 0x00801040,
    0x00801040, 0x00800042, 0x00001002, 0x00801000,
    0x00001000, 0x00000002, 0x00800002, 0x00800040,
    0x00800000, 0x00001040, 0x00801042, 0x00000000,
    0x00001042, 0x00800000, 0x00000040, 0x00001002,
    0x00800042, 0x00000040, 0x00000000, 0x00801042,
    0x00801002, 0x00801040, 0x00000042, 0x00001000,
    0x00001040, 0x00801002, 0x00800040, 0x00000042,
    0x00000002, 0x00001042, 0x00801000, 0x00800002,
  ];

  static const List<int> LOOKUP7 = [
    0x10400000, 0x00404010, 0x00000010, 0x10400010,
    0x10004000, 0x00400000, 0x10400010, 0x00004010,
    0x00400010, 0x00004000, 0x00404000, 0x10000000,
    0x10404010, 0x10000010, 0x10000000, 0x10404000,
    0x00000000, 0x10004000, 0x00404010, 0x00000010,
    0x10000010, 0x10404010, 0x00004000, 0x10400000,
    0x10404000, 0x00400010, 0x10004010, 0x00404000,
    0x00004010, 0x00000000, 0x00400000, 0x10004010,
    0x00404010, 0x00000010, 0x10000000, 0x00004000,
    0x10000010, 0x10004000, 0x00404000, 0x10400010,
    0x00000000, 0x00404010, 0x00004010, 0x10404000,
    0x10004000, 0x00400000, 0x10404010, 0x10000000,
    0x10004010, 0x10400000, 0x00400000, 0x10404010,
    0x00004000, 0x00400010, 0x10400010, 0x00004010,
    0x00400010, 0x00000000, 0x10404000, 0x10000010,
    0x10400000, 0x10004010, 0x00000010, 0x00404000,
  ];

  static const List<int> LOOKUP8 = [
    0x00208080, 0x00008000, 0x20200000, 0x20208080,
    0x00200000, 0x20008080, 0x20008000, 0x20200000,
    0x20008080, 0x00208080, 0x00208000, 0x20000080,
    0x20200080, 0x00200000, 0x00000000, 0x20008000,
    0x00008000, 0x20000000, 0x00200080, 0x00008080,
    0x20208080, 0x00208000, 0x20000080, 0x00200080,
    0x20000000, 0x00000080, 0x00008080, 0x20208000,
    0x00000080, 0x20200080, 0x20208000, 0x00000000,
    0x00000000, 0x20208080, 0x00200080, 0x20008000,
    0x00208080, 0x00008000, 0x20000080, 0x00200080,
    0x20208000, 0x00000080, 0x00008080, 0x20200000,
    0x20008080, 0x20000000, 0x20200000, 0x00208000,
    0x20208080, 0x00008080, 0x00208000, 0x20200080,
    0x00200000, 0x20000080, 0x20008000, 0x00000000,
    0x00008000, 0x00200000, 0x20200080, 0x00208080,
    0x20000000, 0x20208000, 0x00000080, 0x20008080,
  ];
}
