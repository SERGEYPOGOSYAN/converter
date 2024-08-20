import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      title: "Currency Converter",
      home: CurrencyConverter(),
    ));

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController fromTextController = TextEditingController();
  List<String> currencies = [];  // Инициализация пустого списка
  String fromCurrency = "USD";
  String toCurrency = "EUR";
  String? result;

  @override
  void initState() {
    super.initState();
    _loadCurrencies(fromCurrency);
  }

  Future<void> _loadCurrencies(String fromCurrency) async {
    String uri = "https://v6.exchangerate-api.com/v6/c54615a46ec28a126b7c7d9d/latest/$fromCurrency";
    var response = await http.get(Uri.parse(uri), headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body);
    Map<String, dynamic> curMap = responseBody['conversion_rates'];
    setState(() {
      currencies = curMap.keys.toList().cast<String>();
    });
    print(currencies);
    print(responseBody);
  }

  Future<void> _doConversion() async {
    String uri = "https://v6.exchangerate-api.com/v6/c54615a46ec28a126b7c7d9d/latest/$fromCurrency";
    var response = await http.get(Uri.parse(uri), headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body);
    setState(() {
      result = (double.parse(fromTextController.text) * (responseBody["conversion_rates"][toCurrency])).toString();
    });
    print(result);
  }

  void _onFromChanged(String value) {
    setState(() {
      fromCurrency = value;
      _loadCurrencies(fromCurrency);
    });
  }

  void _onToChanged(String value) {
    setState(() {
      toCurrency = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Converter"),
      ),
      body: currencies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height ,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 3.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ListTile(
                        title: TextField(
                          controller: fromTextController,
                          style: TextStyle(fontSize: 20.0, color: Colors.black),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                        ),
                        trailing: _buildDropDownButton(fromCurrency),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward),
                        onPressed: _doConversion,
                      ),
                      ListTile(
                        title: Chip(
                          label: result != null
                              ? Text(
                                  result!,
                                  style: Theme.of(context).textTheme.displaySmall,  // Используем headline4 вместо display1
                                )
                              : Text(""),
                        ),
                        trailing: _buildDropDownButton(toCurrency),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDropDownButton(String currencyCategory) {
    return DropdownButton<String>(
      value: currencyCategory,
      items: currencies
          .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: <Widget>[
                    Text(value),
                  ],
                ),
              ))
          .toList(),
      onChanged: (String? value) {
        if (currencyCategory == fromCurrency) {
          _onFromChanged(value!);
        } else {
          _onToChanged(value!);
        }
      },
    );
  }
}