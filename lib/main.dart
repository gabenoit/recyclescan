import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:recyclescan/location/locationpage.dart';
import 'package:recyclescan/rule.dart';
import 'package:recyclescan/utils/dynamictext.dart';
import 'package:recyclescan/utils/pair.dart';
import 'package:recyclescan/utils/screenorientation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'city.dart';
import 'detector/home.dart';
import 'utils/placeholder.dart';

/// Clé globale permettant de mettre à jour dynamiquement le titre de l'application
GlobalKey<DynamicTextState> title = GlobalKey();

/// Instance des préférences stockées de manière permanente sur le téléphone
SharedPreferences? prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initRules();
  initCities({"Namur": Pair(5000, rules["Namur"]!)});
  prefs = await SharedPreferences.getInstance();
  final cameras = await availableCameras();
  final camera = cameras.first;
  runApp(
    App(camera: camera),
  );
}

/// Point d'entrée de l'application --
class App extends StatelessWidget with PortraitModeMixin {
  final CameraDescription camera;

  const App({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RecycleScan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        bottomAppBarColor: Colors.green,
      ),
      home: WidgetManager(
        camera: camera,
      ),
    );
  }
}

/// Manager permettant de mettre à jour le widget à afficher en fonction du contexte.
/// Ce dernier change lorsque l'on appuie sur un lien dans la liste déroulante en haut à
/// gauche de l'app (menu "burgers").
class WidgetManager extends StatefulWidget {
  final CameraDescription camera;
  const WidgetManager({super.key, required this.camera});

  @override
  State<StatefulWidget> createState() => _WidgetManagerState();
}

class _WidgetManagerState extends State<WidgetManager> {
  Widget _currentWidget = Container();
  late SharedPreferences _prefs;
  final _tileStyle = ListTileStyle.list;

  /// Change le widget courant et gère ou non le contexte en fonction du paramètre ```popCtx```
  ///
  /// Params:
  /// -------
  /// - w: le nouveau widget
  /// - popCtx (default = true): doit retirer ou non le contexte courant
  void _setWidget(Widget w, {bool popCtx = true}) {
    setState(() {
      _currentWidget = w;
    });
    if (popCtx) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _prefs = prefs!;
    if (_prefs.getString("location") == null) {
      _currentWidget = LocationPage(
        okHandler: () =>
            _setWidget(HomePage(camera: widget.camera), popCtx: false),
        prefs: _prefs,
      );
    } else {
      _currentWidget = HomePage(camera: widget.camera);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: DynamicText(key: title, 'RecycleScan')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                'RecycleScan',
                style: TextStyle(color: Colors.lightGreen),
              ),
            ),
            ListTile(
              title: const Text("Camera"),
              style: _tileStyle,
              textColor: Colors.lightGreen,
              onTap: (() => _setWidget(HomePage(camera: widget.camera))),
            ),
            ListTile(
              title: const Text("Changer ma province"),
              style: _tileStyle,
              textColor: Colors.lightGreen,
              onTap: (() => _setWidget(
                    LocationPage(
                      okHandler: () => _setWidget(
                          HomePage(camera: widget.camera),
                          popCtx: false),
                      prefs: _prefs,
                    ),
                  )),
            )
          ],
        ),
      ),
      body: _currentWidget,
    );
  }
}
