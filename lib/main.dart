import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pesquisa Endereço',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'TESTE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _InitialPage();
}

class _InitialPage extends State<MyHomePage> {
  String? selectedUF;
  String? selectedBairro;
  String? selectedCapital;
  int currentPage = 1;
  int itemsPerPage = 15;
  TextEditingController bairroController = TextEditingController();
  late PaginatedDataTable _dataTableWidget;
  bool isDataReady = false;

  Future<Map<String, String>> getAddressFromCoordinates(double latitude, double longitude) async {
    const apiKey = 'AIzaSyCt4G58O44JWSqq3erJJlhN3A2kFr-X1yk';
    final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&key=$apiKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['address'] != null) {
        return {
          'UF': data['address']['state'] ?? 'Desconhecido',
          'Capital': data['address']['city'] ?? 'Desconhecido',
          'Bairro': data['address']['suburb'] ?? 'Desconhecido',
        };
      }
    }
    return {
      'UF': 'Desconhecido',
      'Capital': 'Desconhecido',
      'Bairro': 'Desconhecido',
    };
  }

  void buildTable(List<Map<String, dynamic>> dataTable) {
    final myDataTableSource = MyDataTableSource(dataTable);

    _dataTableWidget = PaginatedDataTable(
      source: myDataTableSource,
      columns: const [
        DataColumn(label: Flexible(child: Text('CEP'))),
        DataColumn(label: Flexible(child: Text('Logradouro'))),
        DataColumn(label: Flexible(child: Text('Complemento'))),
        DataColumn(label: Flexible(child: Text('Bairro'))),
        DataColumn(label: Flexible(child: Text('Localidade'))),
        DataColumn(label: Flexible(child: Text('UF'))),
        DataColumn(label: Flexible(child: Text('IBGE'))),
        DataColumn(label: Flexible(child: Text('Opções'))),
      ],
      rowsPerPage: 8,
    );

    setState(() {
      isDataReady = true;
    });
  }

  Future<void> getDadosTable(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) { 
      final List<Map<String, dynamic>> dataTable = List<Map<String, dynamic>>.from(json.decode(response.body));
      if (dataTable.isNotEmpty) {
        buildTable(dataTable);
      }
    } else {
      print("Sem dados para os parametros fornecidos");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 70.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, João.',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'SEJA BEM VINDO A 7PAY',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, right: 20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: 100,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.textsms,
                            color: Color(0xFF414141),
                            size: 30.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: 100,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Color(0xFF414141),
                            size: 35.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: 100,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF414141),
                            size: 40.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([]),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height * 0.5),
          color: const Color(0xFF2F2F2F),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Elementos do Menu Lateral esquerdo
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, top: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30, top: 40),
              height: MediaQuery.of(context).size.height * 0.18,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Endereços',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF414141),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 2.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // 1- Entrada de input para o estado (UF)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 200,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(color: Color(0xFF414141), width: 2.0),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedUF,
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                isExpanded: true,
                                style: const TextStyle(color: Colors.black),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedUF = newValue;
                                    selectedCapital = ufs.firstWhere((uf) => uf["UF"] == newValue)["capital"];
                                  });
                                },
                                items: ufs.map<DropdownMenuItem<String>>((Map<String, String> uf) {
                                  return DropdownMenuItem<String>(
                                    value: uf["UF"],
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        uf["UF"]!,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                decoration: const InputDecoration(
                                  hintText: 'UF',
                                  contentPadding: EdgeInsets.only(left: 8.0),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 2- Entrada de Text para o bairro
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 400,
                            child: TextFormField(
                              controller: bairroController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'[^\w\s]'),
                                ),
                              ],
                              decoration: InputDecoration(
                                hintText: 'BAIRRO',
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF414141), width: 2.0),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF414141), width: 2.0),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF414141), width: 2.0),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              cursorColor: Colors.black,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedBairro = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Parte à direita (Botões)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 3- Botão FILTRAR
                        ElevatedButton(
                          onPressed: () async {
                            String? uf = selectedUF;
                            String? bairro = bairroController.text;  // Obtenha o valor do controlador
                            String? urlBase = "https://viacep.com.br/ws";
                            if (uf != null && bairro != "") {
                              String? capital = ufs.firstWhere((ufData) => ufData["UF"] == uf)["capital"];
                              capital = removeSpecialCharacters(capital!);
                              getDadosTable("$urlBase/$uf/${capital.replaceAll(' ', '')}/${bairro.replaceAll(' ', '')}/json/");
                            } else {
                              try {
                                Position position;
                                if (kIsWeb) {
                                  position = await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high,
                                  );
                                  Map<String, String> addressData = await getAddressFromCoordinates(position.latitude, position.longitude);
                                  String? newSelectedUF = ufs.firstWhereOrNull((ufData) => ufData["completeName"] == addressData['UF'])?["UF"];
                                  String? newSelectedBairro = addressData['Bairro'];
                                  String? newCapital = removeSpecialCharacters(addressData['Capital']!);

                                  if (newSelectedUF != null && newSelectedBairro != null) {
                                    getDadosTable("$urlBase/$newSelectedUF/${newCapital.replaceAll(' ', '')}/${newSelectedBairro.replaceAll(' ', '')}/json/");
                                    setState(() {
                                      selectedUF = newSelectedUF;
                                      bairroController.text = newSelectedBairro;
                                      selectedCapital = newCapital;
                                    });
                                  } else {
                                    print('UF ou Bairro é nulo.');
                                  }
                                }
                              } catch (e) {
                                print('Erro ao recuperar a localização: $e');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey.shade800, // Cor de fundo cinza escuro
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(150, 50), // Ajuste a altura conforme necessário
                          ),
                          child: const Text(
                            'FILTRAR',
                            style: TextStyle(
                              color: Colors.white, // Cor do texto branca
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Adicione um espaço de 8 pixels entre os botões
                        // 4- Botão Atualizar
                        ElevatedButton(
                          onPressed: () {
                            // Implemente a lógica do botão Atualizar aqui
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey.shade800, // Cor de fundo cinza escuro
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(150, 50), // Ajuste a altura conforme necessário
                          ),
                          child: const Text(
                            'ATUALIZAR',
                            style: TextStyle(
                              color: Colors.white, // Cor do texto branca
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Adicione um espaço de 8 pixels entre os botões
                        // 5- Botão CADASTRAR com ícone de +
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implemente a lógica do botão CADASTRAR aqui
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'CADASTRAR',
                            style: TextStyle(
                              color: Colors.white, // Cor do texto branca
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey.shade800, // Cor de fundo cinza escuro
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(150, 50), // Ajuste a altura conforme necessário
                          ),
                        ),
                        const SizedBox(width: 8), // Adicione um espaço de 8 pixels entre os botões
                        // 6- Ícone de download circundado por um círculo
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.download,
                              color: Color(0xFF414141),
                              size: 40.0,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Theme(
                data: ThemeData(
                  canvasColor: Colors.white,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey, width: 2.0),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: isDataReady ? _dataTableWidget : SizedBox(),
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

List<Map<String, String>> ufs = [
  {"UF": "AC", "capital": "Rio Branco", "completeName": "Acre"},
  {"UF": "AL", "capital": "Maceió", "completeName": "Alagoas"},
  {"UF": "AP", "capital": "Macapá", "completeName": "Amapá"},
  {"UF": "AM", "capital": "Manaus", "completeName": "Amazonas"},
  {"UF": "BA", "capital": "Salvador", "completeName": "Bahia"},
  {"UF": "CE", "capital": "Fortaleza", "completeName": "Ceará"},
  {"UF": "DF", "capital": "Brasília", "completeName": "Distrito Federal"},
  {"UF": "ES", "capital": "Vitória", "completeName": "Espírito Santo"},
  {"UF": "GO", "capital": "Goiânia", "completeName": "Goiás"},
  {"UF": "MA", "capital": "São Luís", "completeName": "Maranhão"},
  {"UF": "MT", "capital": "Cuiabá", "completeName": "Mato Grosso"},
  {"UF": "MS", "capital": "Campo Grande", "completeName": "Mato Grosso do Sul"},
  {"UF": "MG", "capital": "Belo Horizonte", "completeName": "Minas Gerais"},
  {"UF": "PA", "capital": "Belém", "completeName": "Pará"},
  {"UF": "PB", "capital": "João Pessoa", "completeName": "Paraíba"},
  {"UF": "PR", "capital": "Curitiba", "completeName": "Paraná"},
  {"UF": "PE", "capital": "Recife", "completeName": "Pernambuco"},
  {"UF": "PI", "capital": "Teresina", "completeName": "Piauí"},
  {"UF": "RJ", "capital": "Rio de Janeiro", "completeName": "Rio de Janeiro"},
  {"UF": "RN", "capital": "Natal", "completeName": "Rio Grande do Norte"},
  {"UF": "RS", "capital": "Porto Alegre", "completeName": "Rio Grande do Sul"},
  {"UF": "RO", "capital": "Porto Velho", "completeName": "Rondônia"},
  {"UF": "RR", "capital": "Boa Vista", "completeName": "Roraima"},
  {"UF": "SC", "capital": "Florianópolis", "completeName": "Santa Catarina"},
  {"UF": "SP", "capital": "São Paulo", "completeName": "São Paulo"},
  {"UF": "SE", "capital": "Aracaju", "completeName": "Sergipe"},
  {"UF": "TO", "capital": "Palmas", "completeName": "Tocantins"},
];

String removeSpecialCharacters(String input) {
  input = input.replaceAll('á', 'a');
  input = input.replaceAll('â', 'a');
  input = input.replaceAll('ã', 'a');
  input = input.replaceAll('à', 'a');
  input = input.replaceAll('é', 'e');
  input = input.replaceAll('ê', 'e');
  input = input.replaceAll('í', 'i');
  input = input.replaceAll('ó', 'o');
  input = input.replaceAll('ô', 'o');
  input = input.replaceAll('õ', 'o');
  input = input.replaceAll('ú', 'u');
  input = input.replaceAll('ü', 'u');
  return input;
}

class pagination extends DataTableSource {
  final List<Map<String, dynamic>> data;

  pagination(this.data);

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(data[index]["cep"].toString(), softWrap: true)),
      DataCell(Text(data[index]['logradouro'].toString(), softWrap: true)),
      DataCell(Text(data[index]['complemento'].toString(), softWrap: true)),
      DataCell(Text(data[index]['bairro'].toString(), softWrap: true)),
      DataCell(Text(data[index]['localidade'].toString(), softWrap: true)),
      DataCell(Text(data[index]['uf'].toString(), softWrap: true)),
      DataCell(Text(data[index]['ibge'].toString(), softWrap: true)),
      const DataCell(Icon(
        Icons.list,
        color: Color(0xFF414141),
        size: 40.0,
      )),
    ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => data.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}

class MyDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;

  MyDataTableSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final row = data[index];

    return DataRow(cells: [
      DataCell(Text(row["cep"].toString(), softWrap: true)),
      DataCell(Text(row['logradouro'].toString(), softWrap: true)),
      DataCell(Text(row['complemento'].toString(), softWrap: true)),
      DataCell(Text(row['bairro'].toString(), softWrap: true)),
      DataCell(Text(row['localidade'].toString(), softWrap: true)),
      DataCell(Text(row['uf'].toString(), softWrap: true)),
      DataCell(Text(row['ibge'].toString(), softWrap: true)),
      const DataCell(Icon(
        Icons.list,
        color: Color(0xFF414141),
        size: 40.0,
      )),
    ]);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}