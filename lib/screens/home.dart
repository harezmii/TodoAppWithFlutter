import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:todoapp/model/ItemModel.dart';
import 'package:todoapp/utils/utils.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TabController _tabController;
  bool _isExpanded = true;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  var itemBoxes = List<ItemModel>();
  var _itemModelTitle;
  var _itemModelExplain;
  var _timestamp;

  static var _now = DateTime.now();
  var weekLastDay = _now.subtract(new Duration(days: _now.weekday - 7));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          await _auth.signOut();
          Navigator.pop(context);
        },
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            resizeToAvoidBottomPadding: true,
            floatingActionButton: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: FloatingActionButton(
                backgroundColor: Color(0xff171c3c),
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: TodoAppRegister(),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.add,
                  size: 40,
                ),
              ),
            ),
            body: Container(
              color: Color(0xff171c3c),
              child: Column(
                children: [
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      color: Color(0xff171c3c),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "TodoApp",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        SizedBox(
                          height: 26,
                        ),
                        Container(
                          height: 70,
                          width: 320,
                          decoration: BoxDecoration(
                            color: Color(0xff2d325c),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: TabBar(
                            indicatorWeight: 0.1,
                            indicatorColor: Color(0xff171c3c),
                            indicator: BoxDecoration(
                              color: Colors.lightGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tabs: [
                              Tab(
                                child: Text(
                                  "Today",
                                  style: TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                      color: Colors.white),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "Week",
                                  style: TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                      color: Colors.white),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "Month",
                                  style: TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40),
                        ),
                        color: Colors.white,
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            padding: EdgeInsets.all(20),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firebaseFirestore
                                  .collection(_auth.currentUser.uid.toString())
                                  .where(
                                    "timestamp".split(" ")[0],
                                    isGreaterThanOrEqualTo:
                                        DateFormat("yyyy-MM-dd").format(
                                      _now,
                                    ),
                                    isLessThanOrEqualTo:
                                        DateFormat("yyyy-MM-dd HH:mm").format(
                                      DateTime(_now.year, _now.month, _now.day,
                                          23, 59),
                                    ),
                                  )
                                  .snapshots(includeMetadataChanges: true),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                itemBoxes.clear();
                                final itemDocs = snapshot.data.docs;
                                for (var item in itemDocs) {
                                  _itemModelTitle =
                                      item.data()["itemModelTitle"];
                                  _itemModelExplain =
                                      item.data()["itemModelExplain"];
                                  _timestamp = item.data()["timestamp"];

                                  itemBoxes.add(new ItemModel(_itemModelTitle,
                                      _itemModelExplain, _timestamp));
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ExpansionPanelList(
                                                dividerColor: Colors.lightGreen,
                                                animationDuration:
                                                    Duration(milliseconds: 300),
                                                expansionCallback: (int index,
                                                    bool isExpanded) async {
                                                  _isExpanded = !isExpanded;
                                                  setState(() {});
                                                },
                                                children: [
                                                  ExpansionPanel(
                                                    headerBuilder:
                                                        (BuildContext context,
                                                            bool isExpanded) {
                                                      return ListTile(
                                                        leading: Text(
                                                          itemBoxes[index]
                                                              .timestamp,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        title: Text(
                                                          itemBoxes[index]
                                                              .itemModelTitle,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    body: ListTile(
                                                      title: Text(itemBoxes[
                                                              index]
                                                          .itemModelExplain),
                                                      trailing: GestureDetector(
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 28,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _firebaseFirestore
                                                                .runTransaction(
                                                              (transaction) async {
                                                                await transaction
                                                                    .delete(snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .reference);
                                                              },
                                                            );
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    isExpanded: _isExpanded,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            padding: EdgeInsets.all(20),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firebaseFirestore
                                  .collection(_auth.currentUser.uid.toString())
                                  .where(
                                    "timestamp".split(" ")[0],
                                    isGreaterThanOrEqualTo:
                                        DateFormat("yyyy-MM-dd").format(
                                      _now,
                                    ),
                                    isLessThanOrEqualTo:
                                        DateFormat("yyyy-MM-dd HH:mm").format(
                                      DateTime(
                                          weekLastDay.year,
                                          weekLastDay.month,
                                          weekLastDay.day,
                                          23,
                                          59),
                                    ),
                                  )
                                  .snapshots(includeMetadataChanges: true),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                itemBoxes.clear();
                                final itemDocs = snapshot.data.docs;
                                for (var item in itemDocs) {
                                  _itemModelTitle =
                                      item.data()["itemModelTitle"];
                                  _itemModelExplain =
                                      item.data()["itemModelExplain"];
                                  _timestamp = item.data()["timestamp"];

                                  itemBoxes.add(new ItemModel(_itemModelTitle,
                                      _itemModelExplain, _timestamp));
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ExpansionPanelList(
                                                dividerColor: Colors.lightGreen,
                                                animationDuration:
                                                    Duration(milliseconds: 300),
                                                expansionCallback: (int index,
                                                    bool isExpanded) async {
                                                  _isExpanded = !isExpanded;
                                                  setState(() {});
                                                },
                                                children: [
                                                  ExpansionPanel(
                                                    headerBuilder:
                                                        (BuildContext context,
                                                            bool isExpanded) {
                                                      return ListTile(
                                                        leading: Text(
                                                          itemBoxes[index]
                                                              .timestamp,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        title: Text(
                                                          itemBoxes[index]
                                                              .itemModelTitle,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    body: ListTile(
                                                      title: Text(itemBoxes[
                                                              index]
                                                          .itemModelExplain),
                                                      trailing: GestureDetector(
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 28,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _firebaseFirestore
                                                                .runTransaction(
                                                              (transaction) async {
                                                                await transaction
                                                                    .delete(snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .reference);
                                                              },
                                                            );
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    isExpanded: _isExpanded,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            padding: EdgeInsets.all(20),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firebaseFirestore
                                  .collection(_auth.currentUser.uid.toString())
                                  .where(
                                    "timestamp",
                                    isLessThanOrEqualTo:
                                        DateFormat("yyyy-MM-dd HH:mm").format(
                                      LastDayCurrentMonth(),
                                    ),
                                  )
                                  .snapshots(includeMetadataChanges: true),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                itemBoxes.clear();
                                final itemDocs = snapshot.data.docs;
                                for (var item in itemDocs) {
                                  _itemModelTitle =
                                      item.data()["itemModelTitle"];
                                  _itemModelExplain =
                                      item.data()["itemModelExplain"];
                                  _timestamp = item.data()["timestamp"];

                                  itemBoxes.add(new ItemModel(_itemModelTitle,
                                      _itemModelExplain, _timestamp));
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ExpansionPanelList(
                                                dividerColor: Colors.lightGreen,
                                                animationDuration:
                                                    Duration(milliseconds: 300),
                                                expansionCallback: (int index,
                                                    bool isExpanded) async {
                                                  _isExpanded = !isExpanded;
                                                  setState(() {});
                                                },
                                                children: [
                                                  ExpansionPanel(
                                                    headerBuilder:
                                                        (BuildContext context,
                                                            bool isExpanded) {
                                                      return ListTile(
                                                        leading: Text(
                                                          itemBoxes[index]
                                                              .timestamp,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        title: Text(
                                                          itemBoxes[index]
                                                              .itemModelTitle,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color: _timestamp
                                                                        .toString()
                                                                        .compareTo(
                                                                          DateFormat("yyyy-MM-dd")
                                                                              .format(
                                                                                DateTime.now(),
                                                                              )
                                                                              .toString(),
                                                                        ) <=
                                                                    -1
                                                                ? Colors.red
                                                                : Colors
                                                                    .lightGreen,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    body: ListTile(
                                                      title: Text(itemBoxes[
                                                              index]
                                                          .itemModelExplain),
                                                      trailing: GestureDetector(
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 28,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _firebaseFirestore
                                                                .runTransaction(
                                                              (transaction) async {
                                                                await transaction
                                                                    .delete(snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .reference);
                                                              },
                                                            );
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    isExpanded: _isExpanded,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TodoAppRegister extends StatefulWidget {
  @override
  _TodoAppRegisterState createState() => _TodoAppRegisterState();
}

class _TodoAppRegisterState extends State<TodoAppRegister> {
  var _itemModelTitle;
  var _itemModelExplain;
  var _timestamp;

  TextEditingController _controllerItemModelTitle = new TextEditingController();
  TextEditingController _controllerItemModelExplain =
      new TextEditingController();

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff171c3c),
      child: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                print("User :" + _auth.currentUser.uid.toString());
              },
              child: Text(
                "TodoApp Register",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _controllerItemModelTitle,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: Colors.orange,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                labelStyle: TextStyle(color: Colors.white),
                hintText: "Enter The Title",
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _controllerItemModelExplain,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: Colors.orange,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                labelStyle: TextStyle(color: Colors.white),
                hintText: "Enter The Explain",
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime(2020, 1, 1),
                      maxTime: DateTime(2025, 1, 1),
                      currentTime: DateTime.now(),
                      locale: LocaleType.tr,
                      onConfirm: (value) {
                        _timestamp =
                            DateFormat("yyyy-MM-dd HH:mm").format(value);
                      },
                    );
                  },
                  child: Icon(
                    Icons.date_range,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    LastDayCurrentMonth();
                  },
                  child: Text(
                    "DateTime",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () async {
                if (_controllerItemModelTitle.text.isEmpty ||
                    _controllerItemModelExplain.text.isEmpty ||
                    _timestamp == null) {
                  Toast.show("Boş Bırakmayın", context);
                } else {
                  await _firebaseFirestore
                      .collection(_auth.currentUser.uid)
                      .add({
                    "itemModelTitle": _controllerItemModelTitle.text.trim(),
                    "itemModelExplain": _controllerItemModelExplain.text.trim(),
                    "timestamp": _timestamp.toString(),
                  }).then((value) {
                    Toast.show("Eklendi", context);
                    Navigator.pop(context);
                  }).catchError((e) => Toast.show("Eklenemedi", context));
                  /*
                  await _firebaseFirestore.collection("itemData").add({
                    "itemModelTitle": _controllerItemModelTitle.text.trim(),
                    "itemModelExplain": _controllerItemModelExplain.text.trim(),
                    "timestamp": _timestamp.toString(),
                  }).then((value) {
                    Toast.show("Eklendi", context);
                    Navigator.pop(context);
                  }).catchError(
                        (error) => Toast.show("Eklenemedi Hata", context),
                  );
                  */
                }
              },
              child: Container(
                height: 50,
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    "ADD",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime LastDayCurrentMonth() {
  DateTime now = new DateTime.now();
  DateTime lastDayOfMonth = new DateTime(now.year, now.month + 1, 0, 23, 59);
  return lastDayOfMonth;
}
