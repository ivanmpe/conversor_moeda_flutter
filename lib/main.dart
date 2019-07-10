import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

String key = "cdceabb3";
const String request = "https://api.hgbrasil.com/finance";
double dollar;
double euro;

void main() async {
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final euroController = TextEditingController();
  final dollarController = TextEditingController();

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * dollar).toStringAsFixed(2);
    euroController.text = ((dolar * dollar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double e = double.parse(text);
    realController.text = (e * euro).toStringAsFixed(2);
    dollarController.text = ((e * euro) / dollar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$Conversor"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _clearAll,
          )
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados :(",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    ),
                  );
                } else {
                  dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        buildTextField(
                            "Reais", "R\$ ", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "US\$ ", dollarController,
                            _dollarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "€ ", euroController, _euroChanged),
                        Divider(),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  //print(json.decode(response.body)["results"]["currencies"]["USD"]);
  return json.decode(response.body);
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return Container(
    height: 50.0,
    child: TextField(
      controller: c,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefix),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      onChanged: f,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    ),
  );
}
