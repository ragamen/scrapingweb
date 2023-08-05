import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'articulos.dart';
import 'common.dart';
import 'lista.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: "https://qpewttmefqniyqflyjmu.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwZXd0dG1lZnFuaXlxZmx5am11Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzM2NjI1NDYsImV4cCI6MTk4OTIzODU0Nn0.OnRuoILFCh1WhCTjNx8JGRPaf_OzrBthdhL-H3dXhQk");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required String title});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Articulos> articulos = [];
  bool borrar = false;
  @override
  void initState() {
    super.initState();
    if (!borrar) {
      limpiarganador();
      borrar = true;
    }
    getWebSiteData();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('WebScraping'),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemCount: articulos.length,
          itemBuilder: (context, index) {
            final articulo = articulos[index];
            var xHora = articulo.hora;
            var xOper = articulo.operador;
            return ListTile(
              leading: Image.network(
                'https://lotoven.com/${articulo.urlimage}',
                height: 80,
                width: 80,
              ),
              title:
                  Text(articulo.nombre, style: const TextStyle(fontSize: 26)),
              subtitle: Text('${articulo.numero} Hora:$xHora $xOper',
                  style: const TextStyle(fontSize: 16)),
            );
          },
        ));
  }

  Future getWebSiteData() async {
//    final url = Uri.parse('https://www.amazon.com/s?k=iphone');

    final url = Uri.parse('https://lotoven.com/animalitos/'); // Uri.parse
    try {
      final response = await http.get(url);
      dom.Document html = dom.Document.html(response.body);
      final numero = html
          .querySelectorAll('h4 > small')
          .map((element) => element.innerHtml.trim())
          .toList();
      final nombre = html
          .querySelectorAll(' > span.info')
          .map((element) => element.innerHtml.trim())
          .toList();
      final hora = html
          .querySelectorAll(' div > span.info2')
          .map((element) => element.innerHtml.trim())
          .toList();

      final urlimage = html
          .querySelectorAll(' > div > div > img')
          .map((element) => element.attributes['src']!)
          .toList();
      urlimage.remove('/assets/images/investment/thumb-min.webp');
      print(urlimage.length);
      setState(() {
        articulos = List.generate(
            nombre.length,
            (index) => Articulos(
                  operador: hora[index].substring(5, hora[index].length).trim(),
                  numero: '',
                  urlimage: urlimage[index],
                  nombre: nombre[index],
                  hora: hora[index].substring(0, 5).trim(),
                  fecha: DateTime.now().toString().substring(0, 10),
                ));
        var contx = articulos.length;

        for (var index = 0; index < contx; index++) {
          var xgan = articulos[index];
          if (xgan.operador.trim() == "Guacharo Activo") {
            print(xgan.hora.trim());
          }
          String xoper = xgan.operador.trim();
          String xnumero = xgan.numero;
          String xima = xgan.urlimage;
          String xnomb = xgan.nombre;
          String xhora = xgan.hora.trim();
          String xfecha = xgan.fecha.trim();

          var contx1 = Lista.operadores.length;
          for (var i = 0; i < contx1; i++) {
            if (Lista.operadores[i].operador == xoper &&
                Lista.operadores[i].hora == xhora) {
              Lista.operadores[i].nombre = xnomb;
            }
          }
//          insertarGanador(xoper, xnumero, xima, xnomb, xhora);
        }
        contx = Lista.operadores.length;
        for (var index = 0; index < contx; index++) {
          var xgan = Lista.operadores[index];
          String xoper = xgan.operador;
          String xnumero = xgan.numero;
          String xima = xgan.urlimage;
          String xnomb = xgan.nombre;
          String xhora = xgan.hora;
          String xfecha = xgan.fecha;

          insertarGanador(xoper, xnumero, xima, xnomb, xhora, xfecha);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        // ignore: prefer_interpolation_to_compose_strings
        print('{eeee$e}');
      }
    }

// #article-content-container > h3:nth-child(306)
//       .querySelectorAll('h2 > a > span')
  }

  insertarGanador(xoper, xnumero, xima, xnomb, xhora, xfecha) async {
    try {
      await cliente.from('loterias').insert({
        'operador': xoper,
        'numero': xnumero,
        'nombre': xnomb,
        'urlimage': xima,
        'hora': xhora,
        'fecha': xfecha
      });
    } catch (e) {
      print(e);
    }
  }

  limpiarganador() async {
    var fec = DateTime.now().toString().substring(0, 10);
    print(fec);
    await cliente.from('loterias').delete().eq('fecha', fec);
  }
}
