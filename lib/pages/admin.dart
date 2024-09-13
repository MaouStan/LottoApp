import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/models/response/adminGetRes.dart';
import 'package:lotto_app/models/response/lottoGetRes.dart';

class Adminpage extends StatefulWidget {
  @override
  _AdminpageState createState() => _AdminpageState();
}

Future<Map<String, List<LottoGetRes>>> fetchPurchasedLottoData() async {
  final response = await http
      .get(Uri.parse('https://nodejs-wfjd.onrender.com/lotto/with_uid'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    List<LottoGetRes> purchasedLotto =
        jsonResponse.map((data) => LottoGetRes.fromJson(data)).toList();
    return {'purchasedLotto': purchasedLotto}; // Wrap in a map
  } else {
    throw Exception('Failed to load purchased lotto data');
  }
}

class _AdminpageState extends State<Adminpage> {
  List<int> randomNumbers = List.generate(6, (index) => index + 1);
  late Future<List<LottoGetRes>> loadData;
  late AdminGetLottoRes lenlotto;

  // String lenuser = '';
  // String lenall = '';
  // late Future<Map<String, List<LottoGetRes>>> _purchasedLottoData;
  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
    //  _purchasedLottoData = fetchPurchasedLottoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFF453BC9),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF453BC9),
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    height: 25,
                    width: double.infinity,
                    child: const Center(
                      child: Text(
                        'สุ่มรางวัล Number',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return RandomButton(
                                    onClose: () {
                                      Navigator.of(context).pop(); // ปิด dialog
                                    },
                                    onRefresh: () {
                                      setState(() {
                                        // โหลดข้อมูลใหม่ทันทีเมื่อรีเซ็ต
                                        loadData =
                                            loadDataAsync(); // เรียกใช้ Future ใหม่
                                      });
                                    },
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromARGB(255, 153, 153, 153),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Random',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // การแสดงผลกล่องข้อมูลสถิติผ่าน FutureBuilder
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              // FutureBuilder สำหรับการโหลดข้อมูล
                              FutureBuilder(
                                future: loadData, // การโหลดข้อมูลแบบ Future
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator(), // แสดง spinner ระหว่างการโหลด
                                    );
                                  }

                                  // เมื่อข้อมูลโหลดสำเร็จ
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatBox(
                                          'สลากถูกซื้อไปแล้ว',
                                          ':\t${lenlotto.lenuser.toString()}', // แสดงผลจำนวนสลากที่ถูกซื้อ
                                        ),
                                      ),
                                      const SizedBox(
                                          width: 10), // เว้นระยะระหว่างกล่อง
                                      Expanded(
                                        child: _buildStatBox(
                                          'สลากทั้งหมด',
                                          ':\t${lenlotto.lenall.toString()}', // แสดงผลจำนวนสลากทั้งหมด
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    loadData =
                                        loadDataAsync(); // เรียกใช้ Future ใหม่เมื่อรีเฟรช
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      const Color.fromARGB(255, 153, 153, 153),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Refresh Data', // ข้อความบนปุ่ม
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<LottoGetRes>>(
              future: loadData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // ขณะกำลังดึงข้อมูล
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // หากมีข้อผิดพลาด
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  // เมื่อดึงข้อมูลเสร็จสิ้น
                  var lottoList = snapshot.data!;
                  return SizedBox(
                    height: 520,
                    width: 380,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 241, 241),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              itemCount: lottoList.isEmpty
                                  ? 5
                                  : lottoList
                                      .length, // Default to 5 items if the list is empty
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                              itemBuilder: (context, index) {
                                // Calculate prize based on index (starting at 500,000 and halving for each subsequent prize)
                                double prizeAmount =
                                    500000 / (1 << index); // 500,000 / 2^index
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.blueAccent,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'รางวัลที่ ${lottoList.isNotEmpty ? lottoList[index].prize ?? '?' : (index + 1)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 110, 110, 110),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    ' ${lottoList.isNotEmpty ? lottoList[index].number ?? '?' : '??????'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 110, 110, 110),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Text(
                                    'เงินรางวัล \n ${prizeAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  tileColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  visualDensity: const VisualDensity(
                                      vertical: -4), // Adjust item spacing
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ResetButtonn(
                        onClose: () {
                          Navigator.of(context).pop(); // ปิด Dialog
                        },
                        onRefresh: () {
                          // _handleRefresh();
                          setState(() {
                            loadData = loadDataAsync();
                          });
                        },
                      );
                    },
                  );
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 153, 153, 153),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<LottoGetRes>> loadDataAsync() async {
    var value = await Configuration.getConfig();
    String url = value['apiEndPoint'];

    var json = await http.get(Uri.parse('$url/admin/lottory'));
    lenlotto = adminGetLottoResFromJson(json.body);
    var response = await http
        .get(Uri.parse('https://nodejs-wfjd.onrender.com/lotto/seprize'));
    if (response.statusCode == 200) {
      return lottoGetResFromJson(response.body);
    } else {
      throw Exception('Failed to load lotto data');
    }
  }
}

Widget _buildStatBox(String title, String value) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    ),
  );
}

class RandomButton extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onRefresh;
  const RandomButton({Key? key, required this.onClose, required this.onRefresh})
      : super(key: key);

  @override
  _RandomButtonState createState() => _RandomButtonState();
}

class _RandomButtonState extends State<RandomButton> {
  int _selectedCheckbox = -1;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color(0xFF453BC9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                'สุ่มออกรางวัล',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: _selectedCheckbox == 0,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _selectedCheckbox = 0;
                        });
                      },
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return const Color.fromRGBO(70, 189, 108, 1);
                        }
                        return const Color(0xFF453BC9);
                      }),
                    ),
                  ),
                  const Text('สุ่มจากสลากทั้งหมด'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: _selectedCheckbox == 1,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _selectedCheckbox = 1;
                        });
                      },
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return const Color.fromRGBO(70, 189, 108, 1);
                        }
                        return const Color(0xFF453BC9);
                      }),
                    ),
                  ),
                  const Text('สุ่มจากสลากที่ลูกค้าซื้อ'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 75,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: widget.onClose,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 75,
                  child: IconButton(
                    icon:
                        const Icon(Icons.check, color: Colors.white, size: 30),
                    onPressed: () {
                      // You might want to add a check function here
                      // check(context, _selectedCheckbox, widget.onRefresh);

                      check(context, _selectedCheckbox, widget.onRefresh);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void check(BuildContext context, int se, VoidCallback onRefresh) async {
    // แสดง Dialog ขณะกำลังดำเนินการ
    log(se.toString());
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: const Text(
            'กำลังดำเนินการ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        content: const Text(
          'กรุณารอสักครู่...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );

    try {
      // รับค่า Configuration
      var value = await Configuration.getConfig();
      String url = value['apiEndPoint'];

      // เลือกเส้นที่เหมาะสมตามค่า se
      String endpoint;
      if (se == 1) {
        endpoint = '/admin/ranprizeuser'; // เส้นที่ 1
      } else if (se == 0) {
        endpoint = '/admin/ranprizeall'; // เส้นที่ 2
      } else {
        throw Exception('Invalid value for se: $se');
      }

      // ส่งคำขอไปยัง API
      var response = await http.get(Uri.parse('$url$endpoint'));
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      // ตรวจสอบสถานะการตอบสนอง
      if (response.statusCode == 200 || response.statusCode == 201) {
        // สุ่มสำเร็จ
        Navigator.pop(context); // ปิด Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: const Text(
                'สำเร็จ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            content: const Text(
              'สุ่มสำเร็จ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Dialog
                  onRefresh(); // เรียกฟังก์ชันรีเฟรช
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        // การตอบสนองไม่สำเร็จ
        Navigator.pop(context); // ปิด Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: const Text(
                'ข้อผิดพลาด',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            content: const Text(
              'เเอดมินได้ทำการสุ่มไปแล้วหรือสลากขายออกไม่ครบ5ใบ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Dialog
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // การจัดการข้อผิดพลาด
      Navigator.pop(context); // ปิด Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: const Text(
              'ข้อผิดพลาด',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          content: const Text(
            'กรุณาเลือกระหว่าง สุ่มทั้งหมด หรือ สุ่มจากสลากที่ซื้อ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
              },
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }
}

class ResetButtonn extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onRefresh; // Added parameter

  ResetButtonn({required this.onClose, required this.onRefresh});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                color: Color(0xFF453BC9), // Purple color
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                'รีเซ็ตระบบใหม่',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'สร้างสลากจำนวน:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "ขั้นต่ำ 100 ใบ",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                      border: UnderlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'การรีเซ็ตระบบใหม่จะทำให้ข้อมูล\nลูกค้าและสลากหายทั้งหมด\nคุณแน่ใจหรือไม่?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButtonn(
                          Icons.close, const Color(0xFFE74C3C), onClose),
                      _buildActionButtonn(Icons.check, const Color(0xFF2ECC71),
                          () {
                        Navigator.pop(context); // Close the dialog

                        // Save a reference to the BuildContext
                        final navigatorContext = Navigator.of(context);

// Show loading spinner with create new popup
                        showDialog(
                          context: navigatorContext.context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            titlePadding: EdgeInsets.zero,
                            title: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20.0)),
                              ),
                              child: const Text(
                                'กำลังดำเนินการ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            content: const Text(
                              'กรุณารอสักครู่...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );

                        // Call the reset function and then close the spinner
                        _reset(navigatorContext.context).then((_) {
                          Navigator.pop(navigatorContext.context); // Close the loading spinner using the saved context                          // Refresh data after reset
                          onRefresh();
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reset(BuildContext context) async {
    String amountString = _controller.text;
    int? amount = int.tryParse(amountString);

    if (amount == null) {
      await _showErrorDialog(context, 'กรุณากรอกจำนวนที่ถูกต้อง');
      return;
    }

    if (amount < 100) {
      await _showErrorDialog(context, 'กรุณาใส่จำนวนที่มากกว่า 100');
      return;
    }

    try {
      var value = await Configuration.getConfig();
      String url = value['apiEndPoint'];

      // Perform the reset operation
      var response =
          await http.get(Uri.parse('$url/admin/randomlottory/$amount'));
      log(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Fetch updated lottery data
        var json = await http.get(Uri.parse('$url/admin/lottory'));
        log(json.body);
        log(json.statusCode.toString());
        if (json.statusCode == 201) {
          var lenlotto = adminGetLottoResFromJson(json.body);
          log("lenlotto");

          // Call onRefresh to update the UI or perform any additional actions
          onRefresh();

          // Show success dialog
          await _showSuccessDialog(context, 'ทำการรีเซ็ตระบบสำเร็จ');
        } else {
          // Handle unexpected response while fetching updated lottery data
          await _showErrorDialog(context, 'ไม่สามารถดึงข้อมูลสลากได้');
        }
      } else {
        // Handle cases where the reset operation was not successful
        await _showErrorDialog(
            context, 'Admin ได้ทำการรีระบบไปแล้วรอออกรางวัลก่อนจึงจะรีระบบได้');
      }
    } catch (e) {
      // Handle any unexpected exceptions
      await _showErrorDialog(context, 'เกิดข้อผิดพลาด: ${e.toString()}');
    } finally {
      // Close the loading spinner if it's still showing
      // Navigator.pop(context);
    }
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: const Text(
            'ข้อผิดพลาด',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: const Text(
            'สำเร็จ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonn(
      IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      width: 75,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
