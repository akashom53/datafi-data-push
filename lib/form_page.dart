import 'dart:convert';

import 'package:datapushflutter/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

String _chosenIndustry;
List<SectionModel> _sections = [];

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();

  final Map<String, String> _industries = {
    "Agriculture": "5eba49f1fbd9fd1ad27cc7c4",
    "Banking": "5eba49fcfbd9fd1ad27cc7c5",
    "Business Services": "5eba49fcfbd9fd1ad27cc7c6",
    "Commercial": "5eba49fcfbd9fd1ad27cc7c7",
    "Construction": "5eba49fcfbd9fd1ad27cc7c8",
    "Education": "5eba49fcfbd9fd1ad27cc7c9",
    "Electricity Utility": "5eba49fcfbd9fd1ad27cc7ca",
    "Emergency Management": "5eba49fcfbd9fd1ad27cc7cb",
    "Engineering": "5eba49fcfbd9fd1ad27cc7cc",
    "Environmental Services": "5eba49fcfbd9fd1ad27cc7cd",
    "Forestry": "5eba49fcfbd9fd1ad27cc7ce",
    "Government": "5eba49fcfbd9fd1ad27cc7cf",
    "Hospitality": "5eba49fcfbd9fd1ad27cc7d0",
    "Humanitarian Aid": "5eba49fcfbd9fd1ad27cc7d1",
    "Natural Resources": "5eba49fcfbd9fd1ad27cc7d4",
    "Manufacturing": "5eba49fcfbd9fd1ad27cc7d2",
    "Mining": "5eba49fcfbd9fd1ad27cc7d3",
    "Oil and Gas": "5eba49fcfbd9fd1ad27cc7d5",
    "Political": "5eba49fcfbd9fd1ad27cc7d6",
    "Public Health": "5eba49fcfbd9fd1ad27cc7d7",
    "Real Estate": "5eba49fcfbd9fd1ad27cc7d8",
    "Retail": "5eba49fcfbd9fd1ad27cc7d9",
    "Safety": "5eba49fcfbd9fd1ad27cc7da",
    "Telecome": "5eba49fcfbd9fd1ad27cc7db",
    "Tourism": "5eba49fcfbd9fd1ad27cc7dc",
    "Water & Sewer": "5eba49fcfbd9fd1ad27cc7dd",
    "Archaeology": "5ed60175091009ad14c2fbcc",
    "COVID 19 Responses": "5ed601b8091009ad14c2fbcd"
  };

  String getIndustryName(int row, int col) {
    int index = (5 * row) + col;
    if (index < _industries.keys.length)
      return _industries.keys.elementAt(index);
    return null;
  }

  void _showIndustryChooser(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: SingleChildScrollView(
            child: Column(
              children: List<int>.generate(
                (_industries.keys.length ~/ 5) + 1,
                (index) => index,
              )
                  .map<Widget>(
                    (row) => Row(
                      children:
                          List<int>.generate(5, (index) => index).map<Widget>(
                        (col) {
                          String industryName = getIndustryName(row, col);
                          if (industryName == null) return Container();
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _chosenIndustry = industryName;
                                Navigator.of(context).pop();
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      spreadRadius: 4,
                                    ),
                                  ]),
                              height: 100,
                              width:
                                  (MediaQuery.of(context).size.width - 100) / 5,
                              margin: const EdgeInsets.all(10),
                              child: Center(
                                child: Text(industryName),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  submitApp(
      String appName, String industryId, List<SectionModel> sections) async {
    List<Map<String, dynamic>> sectionsMap = [];
    sections.asMap().forEach((index, section) {
      Map<String, dynamic> sectionMap = {
        "title": section.name,
        "type": "new_section",
        "displayIndex": "$index",
      };
      List<Map<String, dynamic>> fieldsMap = [];
      section.fields.asMap().forEach((index, field) {
        Map<String, dynamic> fieldMap = {
          "label": field.typeKey,
          "type": field.typeKey,
          "displayIndex": "$index"
        };
        if (field.typeKey == "multiple") {
          fieldMap["validation"] = "dropdown";
          fieldMap["default_val"] = field.options;
        }
        fieldsMap.add(fieldMap);
      });
      sectionMap["fields"] = fieldsMap;
      sectionsMap.add(sectionMap);
    });

    Map<String, dynamic> requestMap = {
      "name": appName,
      "industryId": industryId,
      "authEnabled": true,
      "registerAllow": true,
      "sections": sectionsMap
    };

    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    try {
      final resp = await http.post(
        "https://api.datafi.app/master/app",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestMap),
      );
      Navigator.of(context).pop();

      if (resp.statusCode == 200) {
        _appNameController.clear();
        setState(() {
          _chosenIndustry = null;
          _sections = [];
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text("Something went wrong. Could not create app"),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Something went wrong. Could not create app"),
        ),
      );
    }
  }

  bool validate() {
    String appName = _appNameController.text;
    if (appName == null || appName.length == 0) {
      showError("App Name cannot be empty");
      return false;
    }
    if (_chosenIndustry == null) {
      showError("Please choose an industry");
      return false;
    }
    if (_sections.length == 0) {
      showError("Please add a section");
      return false;
    }
    var sections =
        _sections.where((section) => !section.isEmpty).map<SectionModel>(
      (section) {
        section.fields =
            section.fields.where((field) => !field.isEmpty).toList();
        return section;
      },
    ).toList();
    if (_sections.length != 0 && sections.length == 0) {
      showError("Please fill data in Section");
      return false;
    }
    for (var section in sections) {
      if (section.name == null || section.name.length == 0) {
        section.name = "default";
      }
      if (section.fields.length == 0) {
        showError("Please add fields to Section ${section.name}");
        return false;
      }
      for (var field in section.fields) {
        if (!field.isValid) {
          showError("Invalid field in Section ${section.name}");
          return false;
        }
      }
    }
    _sections = sections;
    return true;
  }

  void showError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(error),
        actions: <Widget>[
          FlatButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  void submit() {
    submitApp(_appNameController.text, _industries[_chosenIndustry], _sections);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Push"),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "SAVE",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (validate()) {
                submit();
              }
            },
          )
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _appNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "App Name",
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      _showIndustryChooser(context);
                    },
                    child: Container(
                      height: 56,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(_chosenIndustry ?? "Choose Industry"),
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    color: Colors.black,
                    height: 1,
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text("Sections"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            _sections.add(SectionModel());
                          });
                        },
                        child: Text("Add Section"),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                  ),
                  Column(
                    children:
                        List<int>.generate(_sections.length, (index) => index)
                            .map<Widget>((e) => SectionWidget(
                                  index: e,
                                ))
                            .toList(),
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

class SectionWidget extends StatefulWidget {
  final int index;

  const SectionWidget({
    Key key,
    this.index,
  }) : super(key: key);

  @override
  _SectionWidgetState createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Section Title",
            ),
            onChanged: (val) {
              _sections[widget.index].name = val;
            },
          ),
          Container(
            height: 20,
          ),
          Column(
            children: List<int>.generate(
              _sections[widget.index].fields.length,
              (index) => index,
            )
                .map<Widget>(
                  (e) => FieldCard(
                    sectionIndex: widget.index,
                    fieldIndex: e,
                  ),
                )
                .toList(),
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                _sections[widget.index].fields.add(FieldModel());
              });
            },
            child: Text("Add Field"),
          ),
        ],
      ),
    );
  }
}

class FieldCard extends StatefulWidget {
  final int sectionIndex, fieldIndex;

  const FieldCard({
    Key key,
    this.sectionIndex,
    this.fieldIndex,
  }) : super(key: key);

  @override
  _FieldCardState createState() => _FieldCardState();
}

class _FieldCardState extends State<FieldCard> {
  void _showFieldTypeChooser(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: FieldModel.TYPES
                  .map<Widget>((e) => new ListTile(
                      title: new Text(e),
                      onTap: () {
                        setState(() {
                          _sections[widget.sectionIndex]
                              .fields[widget.fieldIndex]
                              .type = e;
                        });
                        Navigator.of(context).pop();
                      }))
                  .toList(),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: TextFormField(
                  onChanged: (val) {
                    _sections[widget.sectionIndex]
                        .fields[widget.fieldIndex]
                        .name = val;
                  },
                  decoration: InputDecoration(
                    labelText: "Field Label",
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  _showFieldTypeChooser(context);
                },
                child: Text(_sections[widget.sectionIndex]
                        .fields[widget.fieldIndex]
                        .type ??
                    "Choose Type"),
              ),
            ],
          ),
          _sections[widget.sectionIndex].fields[widget.fieldIndex].type ==
                  "dropdown"
              ? TextFormField(
                  decoration: InputDecoration(labelText: "Options"),
                  onChanged: (val) {
                    _sections[widget.sectionIndex]
                        .fields[widget.fieldIndex]
                        .options = val;
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
