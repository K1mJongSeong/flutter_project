import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_flutter_app/FB/FBCloudStore.dart';
import 'package:my_first_flutter_app/page/recipe.dart';
import 'package:my_first_flutter_app/repository/content_repository.dart';
import 'package:my_first_flutter_app/commons/utils.dart';

import '../colors.dart';

final Map<String, String> locationTypeToString = {
  "kr": "한식",
  "cn": "중식",
  "jp": "일식",
  "eu": "양식",
  "he": "건강",
};

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _count = 0;
  Widget _appbarWidget() {
    return AppBar(
      title: Image.asset(
        'assets/images/appbar6.PNG',
        fit: BoxFit.fill,
        width: 5000,
      ),
      backgroundColor: Color(0xFFCCCC99),
      centerTitle: true,
      elevation: 0.0,
      actions: [
        GestureDetector(
          onTap: () {},
          child: PopupMenuButton(
            onSelected: (String where) {
              print(where);
              setState(() {
                currentmenu = where;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                    value: "kr",
                    child: Text(
                      "한식",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                PopupMenuItem(
                    value: "cn",
                    child: Text(
                      "중식",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                PopupMenuItem(
                    value: "jp",
                    child: Text(
                      "일식",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                PopupMenuItem(
                    value: "eu",
                    child: Text(
                      "양식",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                PopupMenuItem(
                    value: "he",
                    child: Text(
                      "건강",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ];
            },
            child: Row(
              children: [
                Text(
                  locationTypeToString[currentmenu],
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  } // 앱바 위젯

  String currentmenu;
  String currentLocation;
  Contentrepository contentrepository;

  @override
  void initState() {
    super.initState();
    currentmenu = "kr";
    contentrepository = Contentrepository();
  }

  _loadContents() {
    return contentrepository.loadContentsFromLocation(currentmenu);
  }

  void _updateRecipeLikeCount() async {
    await FBCloudStore.updateRecipeLikeCount;
  }

  void _incrementCounter() {
    setState(() {
      _count++;
    });
  }

  _makeDatalist(List<Map<String, String>> data) {
    bool _islike = true;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (BuildContext _context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return Recipeview(
                data: data[index],
              );
            }));
            print(data[index]["name"]);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: Hero(
                    tag: data[index]["cid"],
                    child: Image.asset(
                      data[index]["image"],
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data[index]["name"],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          data[index]["explain"],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 1),
                              ),
                              SvgPicture.asset(
                                'aseets/svg/heart_off.svg',
                                width: 13,
                                height: 13,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              IconButton(
                                icon: (_islike
                                    ? Icon(Icons.favorite_outlined)
                                    : Icon(Icons.favorite_border_outlined)),
                                color: red,
                              ),
                              Text(
                                '좋아요 : $_count',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
      itemCount: data.length,
      separatorBuilder: (BuildContext _context, int index) {
        return Container(
          height: 1,
          color: Colors.black.withOpacity(0.4),
        );
      },
    );
  }

  Widget _bodyWidget() {
    return FutureBuilder(
      future: _loadContents(),
      builder: (BuildContext context, dynamic snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // if (snapshot.hasError) {
        //   return Center(
        //     child: Text("데이터 오류"),
        //   );
        // }
        if (snapshot.hasData) {
          return _makeDatalist(snapshot.data);
        }
        return Center(
          child: Text("데이터 없음"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(),
      appBar: _appbarWidget(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/js.png'),
                backgroundColor: Colors.white,
              ),
              accountName: Text(
                '김종성',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text('JongSeong.kim4124@gmail.com',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              decoration: BoxDecoration(
                color: Color(0xFFCCCC99),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
              ),
            ),
            ListTile(
                leading: Icon(
                  Icons.money,
                  color: Colors.grey[850],
                ),
                title: Text('이번달 예산'),
                onTap: () {
                  print('쌉싸름한 레시피');
                }),
            ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Colors.grey[850],
                ),
                title: Text('설정'),
                onTap: () {
                  print('쌉싸름한 레시피');
                }),
            ListTile(
                leading: Icon(
                  Icons.call,
                  color: Colors.grey[850],
                ),
                title: Text('고객센터'),
                onTap: () {
                  print('010-2248-4124');
                }),
          ],
        ),
      ),
    );
  } // 불러오는부분
}
