import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localization/const.dart';
import 'package:localization/settings.dart';
import 'package:localization/user_model.dart';
import 'package:localization/locale_model.dart';
import 'package:localization/utils.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Future<void> getUser() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await http.get(Uri.parse(randomApi));
      if (res.statusCode == 200) {
        final decodedResponse = json.decode(res.body);
        print(decodedResponse['info']['seed']);
        user = UserModel.fromJson(decodedResponse['results'][0]);
      }
      setState(() {
        isLoading = false;
      });
    } catch (_) {
      print(_.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 40, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              localize(
                  _localeModel.translations['userIntro'], [user.name.first]),
              style: TextStyle(fontSize: 40),
            ),
          ),
          // Spacer(),
          Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                  user.picture.large,
                ),
              )),
        ],
      ),
    );
  }

  bool isLoading = false;
  UserModel user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    iconController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _settings = Provider.of<Settings>(context, listen: false);
    isDarkNotifier = ValueNotifier(_settings.theme == AppTheme.dark);
  }

  Widget _description() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Text(
          localize(_localeModel.translations['aboutUser'],
              [user.location.city, user.location.state, user.location.country]),
          textAlign: TextAlign.center,
          style: TextStyle(),
        ),
      ),
    );
  }

  Widget stackedLogo(String title) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        Padding(
            padding: EdgeInsets.only(left: 5, top: 4),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withOpacity(0.5)),
            )),
      ],
    );
  }

  Widget _dropDown(String selected, List<String> list,
      {Function(String) onChange}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 30,
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(5)),
      child: DropdownButton<String>(
          underline: Container(),
          icon: Container(),
          items: list
              .map((e) => DropdownMenuItem<String>(
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(e.toString())),
                    value: e.toString(),
                  ))
              .toList(),
          value: selectedLanguage,
          onChanged: (x) => onChange(x)),
    );
  }

  Widget infoTile(String key, String value) {
    return Container(
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blue[100].withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 3,
                offset: Offset(1, 2), // changes position of shadow
              ),
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(key), Text(value)],
        ));
  }

  Widget subtitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
    );
  }

  AnimationController iconController;
  LocaleModel _localeModel;
  Settings _settings;
  String selectedLanguage = 'es';
  ValueNotifier<bool> isDarkNotifier;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
          create: (_) => LocaleModel(),
          child: Consumer<LocaleModel>(builder: (context, provider, child) {
            _localeModel = provider;
            return Scaffold(
              body: isLoading || provider.translations.isEmpty || user == null
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          ValueListenableBuilder<bool>(
                            valueListenable: isDarkNotifier,
                            builder: (_, theme, child) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    stackedLogo('Profile'),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _dropDown(selectedLanguage,
                                            ['en', 'de', 'es'], onChange: (x) {
                                          setState(() {
                                            selectedLanguage = x;
                                          });
                                        }),
                                        CupertinoSwitch(
                                          value: theme,
                                          onChanged: (isDark) {
                                            isDarkNotifier.value = isDark;
                                            if (isDark) {
                                              iconController.forward();
                                              Provider.of<Settings>(context,
                                                      listen: false)
                                                  .theme = AppTheme.dark;
                                            } else {
                                              iconController.reverse();
                                              Provider.of<Settings>(context,
                                                      listen: false)
                                                  .theme = AppTheme.light;
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(isDarkNotifier.value
                                            ? Icons.brightness_2_outlined
                                            : Icons.wb_sunny_rounded),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          _title(),
                          _description(),
                          subtitle('About'),
                          infoTile('Gender', user.gender),
                          infoTile('Email', user.email),
                          SizedBox(
                            height: 8,
                          ),
                          subtitle('Location'),
                          infoTile('City', user.location.city),
                          infoTile('State', user.location.state),
                          infoTile('Country', user.location.country),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: subtitle('People you may know'),
                          ),
                          Connections()
                        ],
                      ),
                    ),
            );
          })),
    );
  }
}

class Connections extends StatefulWidget {
  @override
  _ConnectionsState createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> {
  Future<void> getConnections() async {
    try {
      final res = await http.get(Uri.parse(RANDOM_CONNECTIONS));
      if (res.statusCode == 200) {
        Iterable data = json.decode(res.body)['results'];
        final list = data.map((e) => UserModel.fromJson(e)).toList();
        connection.sink.add(list);
      }
    } catch (_) {
      return connection.sink.addError('Failed to Load');
    }
  }

  Widget _userCard(UserModel user, int index) {
    return Container(
      margin: EdgeInsets.only(right: 16, left: index == 0 ? 16 : 0),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.brown.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              padding: EdgeInsets.all(4),
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                  user.picture.large,
                ),
              )),
          Text(
            user.name.first,
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  final connection = StreamController<List<UserModel>>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConnections();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    connection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<UserModel>>(
            stream: connection.stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<UserModel>> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error),
                );
              } else if (snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else
                return Container(
                    height: 200,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, x) => _userCard(snapshot.data[x], x),
                    ));
            }),
      ],
    );
  }
}
