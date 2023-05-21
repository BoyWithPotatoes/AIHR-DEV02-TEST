import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam/pages/cml.dart';
import 'package:exam/widgets/button.dart';
import 'package:exam/widgets/custom_table.dart';
import 'package:exam/widgets/dialog_scaffold.dart';
import 'package:exam/widgets/simple_textfield.dart';
import 'package:exam/widgets/snack_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/calculate.dart';
import '../utils/controller_validator.dart';
import '../widgets/clickable_text.dart';
import '../utils/global.dart';

import 'package:universal_html/html.dart' as html;

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool _loaded = false;
  final List _data = [];
  List _filteredData = [];

  bool _show_snack = false;
  String _snack_text = "";

  @override
  void initState() {
    _getData();
    super.initState();
  }

  void _getData() async {
    setState(() {
      _loaded = false;
      _data.clear();
      _filteredData.clear();
    });
    QuerySnapshot query = await firestore.collection("info").orderBy("line_number").get();
    for (var doc in query.docs) {
      _data.add((doc.data() as Map<String, dynamic>)..["id"] = doc.id); // yeah, somethime you gotta think outside all the way beyond the universe
    }
    _filteredData = _data;
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        "PIPING",
        style: TextStyle(
          fontSize: 20,
          color: Colors.black
        ),
      ),
      actions: [
        Container(
          padding: const EdgeInsets.only(right: 16.0),
          alignment: Alignment.center,
          child: ClickableText(
            onClick: () => html.window.open("https://github.com/BoyWithPotatoes/AIHR-DEV02-TEST", "BoyWithPotatoes"),
            text: "View Source",
            textSize: 20,
            textColor: Colors.grey,
          ),
        ),
      ],
    ),

    body: SnackAlert(
      on_click: () => setState(() {
        _show_snack = false;
        _snack_text = "";
      }),
      text: _snack_text,
      show: _show_snack,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: !_loaded ? Center(child: CircularProgressIndicator(color: Colors.grey.shade400,)) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // search box
            CupertinoSearchTextField(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.zero,
                color: Colors.grey.shade200
              ),
              style: const TextStyle(
                fontSize: 20,
              ),
              onChanged: (text) {
                 _filteredData = text.isEmpty ? _data : 
                 _data.where((e) => 
                  e["line_number"].toString().toLowerCase().contains(text.toLowerCase()) ||
                  e["location"].toString().toLowerCase().contains(text.toLowerCase()) ||
                  e["from"].toString().toLowerCase().contains(text.toLowerCase()) ||
                  e["to"].toString().toLowerCase().contains(text.toLowerCase()) ||
                  e["pipr_size"].toString().toLowerCase().contains(text.toLowerCase()) ||
                  e["service"].toString().toLowerCase().contains(text.toLowerCase()) ||
                  e["material"].toString().toLowerCase().contains(text.toLowerCase())
                ).toList();
                setState(() {}); // god is dead
                // I know there is an easier way to do this
                // might turn that into search library and upload to pub.dev
              },
            ),
            
            // refresh and add new button
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // refresh
                  const Icon(Icons.refresh, color: Colors.blue, size: 20),
                  ClickableText(
                    onClick: () {
                      _getData();
                    },
                    text: "Refresh",
                    textColor: Colors.blue,
                  ),
                  
                  const SizedBox(width: 32), //space
        
                  //add new
                  const Icon(Icons.add_box_outlined, color: Colors.blue, size: 20),
                  ClickableText(
                    onClick: () {
                      bool loading = false;
                      String err = "";
                      Map controller = {
                        "line_number": TextEditingController(),
                        "location": TextEditingController(),
                        "from": TextEditingController(),
                        "to": TextEditingController(),
                        "drawing_number": TextEditingController(),
                        "service": TextEditingController(),
                        "material": TextEditingController(),
                        "inservice_date": TextEditingController(),
                        "pipe_size": TextEditingController(),
                        "original_thickness": TextEditingController(),
                        "stress": TextEditingController(),
                        "joint_efficiency": TextEditingController(),
                        "ca": TextEditingController(),
                        "design_life": TextEditingController(),
                        "design_pressure": TextEditingController(),
                        "operating_pressure": TextEditingController(),
                        "design_temperature": TextEditingController(),
                        "operating_temperature": TextEditingController(),
                      };
        
                      showGeneralDialog(
                        transitionDuration: Duration.zero, // minimalism rules
                        barrierDismissible: false,
                        barrierColor: Colors.black.withOpacity(0.2),
                        context: context, 
                        pageBuilder: (context, _, __) => WillPopScope(
                          onWillPop: () async => !loading,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              return Dialog(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero
                                ),
                                insetPadding: const EdgeInsets.all(32),
                                elevation: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DialogScaffold(
                                      appBar: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Add Piping Information",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                        
                                          if (!loading) ... [
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () => Navigator.pop(context),
                                                child: const Icon(Icons.close),
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                      body: ListView(
                                        padding: const EdgeInsets.all(16.0),
                                        shrinkWrap: true,
                                        children: [
                                          SimpleTextField(
                                            title: "Line Number",
                                            controller: controller["line_number"],
                                          ),
                                          SimpleTextField(
                                            title: "Location",
                                            controller: controller["location"],
                                          ),
                                          SimpleTextField(
                                            title: "From",
                                            controller: controller["from"],
                                          ),
                                          SimpleTextField(
                                            title: "To",
                                            controller: controller["to"],
                                          ),
                                          SimpleTextField(
                                            title: "Drawing Number",
                                            controller: controller["drawing_number"],
                                          ),
                                          SimpleTextField(
                                            title: "Service",
                                            controller: controller["service"],
                                          ),
                                          SimpleTextField(
                                            title: "Material",
                                            controller: controller["material"],
                                          ),
                                          SimpleTextField(
                                            title: "Inservice Date",
                                            controller: controller["inservice_date"],
                                            hint_text: "Year-Month-Day   ex. 2020-01-01", //mysql date format (note: not gonna write regex) (note2: finally wrote the regex and I regret it)
                                            date: true,
                                          ),
                                          SimpleTextField(
                                            title: "Pipe Size (Inch)",
                                            controller: controller["pipe_size"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "Original Thickness",
                                            controller: controller["original_thickness"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "Stress",
                                            controller: controller["stress"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "Joint Efficiency",
                                            controller: controller["joint_efficiency"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "CA",
                                            controller: controller["ca"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "Design Life",
                                            controller: controller["design_life"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "Design Pressure",
                                            controller: controller["design_pressure"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "Operating pressure",
                                            controller: controller["operating_pressure"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "Design Temperature",
                                            controller: controller["design_temperature"],
                                            only_number: true,
                                          ),
                                          SimpleTextField(
                                            title: "Operating temperature",
                                            controller: controller["operating_temperature"],
                                            only_number: true,
                                          ),
                                          
                                          if (err.isNotEmpty) ... [
                                            Text(err, style: const TextStyle(fontSize: 16, color: dexon_red)),
                                            const SizedBox(height: 16),
                                          ],
                                          
                                          SimpleButton(
                                            onClick: () async {
                                              if (loading) { return; }
                                              setState(() {
                                                loading = true;
                                                err = "";
                                              });
                                              if (!controller_validate(controller)) {
                                                err = "All field must be filled";
                                                loading = false;
                                                return;
                                              }
                                              
                                              if (!RegExp(r'^\d{4}\-\d{2}\-\d{2}').hasMatch(controller["inservice_date"].text)) {
                                                err = "Incorrect date format";
                                                loading = false;
                                                return;
                                              }
        
                                              // check existng
                                              QuerySnapshot exist = await firestore.collection("info").where("line_number", isEqualTo: controller["line_number"].text).get();
                                              if (exist.docs.isNotEmpty) {
                                                err = "This line number is already exist";
                                                setState(() => loading = false);
                                                return;
                                              }
                                              await firestore.collection("info").add({
                                                "line_number": controller["line_number"].text,
                                                "location": controller["location"].text,
                                                "from": controller["from"].text,
                                                "to": controller["to"].text,
                                                "drawing_number": controller["drawing_number"].text,
                                                "service": controller["service"].text,
                                                "material": controller["material"].text,
                                                "inservice_date": controller["inservice_date"].text,
                                                "pipe_size": double.parse(controller["pipe_size"].text),
                                                "original_thickness": double.parse(controller["original_thickness"].text),
                                                "stress": double.parse(controller["stress"].text),
                                                "joint_efficiency": double.parse(controller["joint_efficiency"].text),
                                                "ca": double.parse(controller["ca"].text),
                                                "design_life": double.parse(controller["design_life"].text),
                                                "design_pressure": double.parse(controller["design_pressure"].text),
                                                "operating_pressure": double.parse(controller["operating_pressure"].text),
                                                "design_temperature": double.parse(controller["design_temperature"].text),
                                                "operating_temperature": double.parse(controller["operating_temperature"].text)
                                              }).catchError((err) {
                                                err = "Unexpected error. Please try again later.";
                                                return err;
                                              });
                                              if (err.isNotEmpty) {
                                                setState(() => loading = false);
                                                return;
                                              }
        
                                              if (!mounted) { return; }
                                              Navigator.pop(context);
                                              _show_snack = true;
                                              _snack_text = "New Piping Added";
                                              _getData();
                                            },
                                            child: loading ? const SizedBox(height: 21, width: 21, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("ADD", style: TextStyle(fontSize: 18, color: Colors.white)), // only god and me can understand this
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),
                      );
                    },
                    text: "Add Piping",
                    textColor: Colors.blue,
                  ),
                ],
              ),
            ),
        
            // table
            if (_filteredData.isNotEmpty) ... [
              Expanded(
                child: ListView(
                  children: [
                    CustomTable(
                      data: _filteredData,
                      columnWidth: const {
                        0: FlexColumnWidth(0.5),
                        1: FlexColumnWidth(0.5),
                        4: FlexColumnWidth(0.6),
                        5: FlexColumnWidth(0.4),
                      },
                      header: const ["Line Number", "Location", "From", "To", "Pipe Size (Inch)", "Service", "Material", ""],
                      h_key: const ["line_number", "location", "from", "to", "pipe_size", "service", "material"],
                      menu_list: const ["View Detail", "Info", "Delete!"],
                      on_menu_click: [
                        (data) {
                          setState(() => _show_snack = false);
                          Navigator.push(
                            context, 
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => CML(pipe_data: data),
                            ),  
                          );
                        },
                        (data) {
                          bool loading = false;
                          String err = "";
                          Map controller = {
                            "line_number": 0,
                            "location": 0,
                            "from": 0,
                            "to": 0,
                            "drawing_number": 0,
                            "service": 0,
                            "material": 0,
                            "inservice_date": 0,
                            "pipe_size": 0,
                            "original_thickness": 0,
                            "stress": 0,
                            "joint_efficiency": 0,
                            "ca": 0,
                            "design_life": 0,
                            "design_pressure": 0,
                            "operating_pressure": 0,
                            "design_temperature": 0,
                            "operating_temperature": 0,
                          };
                          controller.forEach((key, value) => controller[key] = TextEditingController()..text = data[key].toString()); // creativity at its finest
                          showGeneralDialog(
                            transitionDuration: Duration.zero, // minimalism rules
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.2),
                            context: context, 
                            pageBuilder: (context, _, __) => WillPopScope(
                              onWillPop: () async => !loading,
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return Dialog(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero
                                    ),
                                    insetPadding: const EdgeInsets.all(32),
                                    elevation: 0,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DialogScaffold(
                                          appBar: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Piping Information / ${data["line_number"]}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                            
                                              if (!loading) ... [
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap: () => Navigator.pop(context),
                                                    child: const Icon(Icons.close),
                                                  ),
                                                ),
                                              ]
                                            ],
                                          ),
                                          body: ListView(
                                            padding: const EdgeInsets.all(16.0),
                                            shrinkWrap: true,
                                            children: [
                                              SimpleTextField(
                                                title: "Line Number",
                                                controller: controller["line_number"],
                                                read_only: true,
                                              ),
                                              SimpleTextField(
                                                title: "Location",
                                                controller: controller["location"],
                                              ),
                                              SimpleTextField(
                                                title: "From",
                                                controller: controller["from"],
                                              ),
                                              SimpleTextField(
                                                title: "To",
                                                controller: controller["to"],
                                              ),
                                              SimpleTextField(
                                                title: "Drawing Number",
                                                controller: controller["drawing_number"],
                                              ),
                                              SimpleTextField(
                                                title: "Service",
                                                controller: controller["service"],
                                              ),
                                              SimpleTextField(
                                                title: "Material",
                                                controller: controller["material"],
                                              ),
                                              SimpleTextField(
                                                title: "Inservice Date",
                                                controller: controller["inservice_date"],
                                                hint_text: "Year-Month-Day   ex. 2020-01-01",
                                                date: true,
                                              ),
                                              SimpleTextField(
                                                title: "Pipe Size (Inch)",
                                                controller: controller["pipe_size"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "Original Thickness",
                                                controller: controller["original_thickness"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "Stress",
                                                controller: controller["stress"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "Joint Efficiency",
                                                controller: controller["joint_efficiency"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "CA",
                                                controller: controller["ca"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "Design Life",
                                                controller: controller["design_life"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "Design Pressure",
                                                controller: controller["design_pressure"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "Operating pressure",
                                                controller: controller["operating_pressure"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "Design Temperature",
                                                controller: controller["design_temperature"],
                                                only_number: true,
                                              ),
                                              SimpleTextField(
                                                title: "Operating temperature",
                                                controller: controller["operating_temperature"],
                                                only_number: true,
                                              ),
                                              
                                              if (err.isNotEmpty) ... [
                                                Text(err, style: const TextStyle(fontSize: 16, color: dexon_red)),
                                                const SizedBox(height: 16),
                                              ],
                                              
                                              SimpleButton(
                                                onClick: () async {
                                                  if (loading) { return; }
                                                  setState(() {
                                                    loading = true;
                                                    err = "";
                                                  });
                                                  if (!controller_validate(controller)) {
                                                    err = "All field must be filled";
                                                    loading = false;
                                                    return;
                                                  }

                                                  if (!RegExp(r'^\d{4}\-\d{2}\-\d{2}').hasMatch(controller["inservice_date"].text)) {
                                                    err = "Incorrect date format";
                                                    loading = false;
                                                    return;
                                                  }
                                                  
                                                  await firestore.collection("info").doc(data["id"]).update({
                                                    "location": controller["location"].text,
                                                    "from": controller["from"].text,
                                                    "to": controller["to"].text,
                                                    "drawing_number": controller["drawing_number"].text,
                                                    "service": controller["service"].text,
                                                    "material": controller["material"].text,
                                                    "inservice_date": controller["inservice_date"].text,
                                                    "pipe_size": double.parse(controller["pipe_size"].text),
                                                    "original_thickness": double.parse(controller["original_thickness"].text),
                                                    "stress": double.parse(controller["stress"].text),
                                                    "joint_efficiency": double.parse(controller["joint_efficiency"].text),
                                                    "ca": double.parse(controller["ca"].text),
                                                    "design_life": double.parse(controller["design_life"].text),
                                                    "design_pressure": double.parse(controller["design_pressure"].text),
                                                    "operating_pressure": double.parse(controller["operating_pressure"].text),
                                                    "design_temperature": double.parse(controller["design_temperature"].text),
                                                    "operating_temperature": double.parse(controller["operating_temperature"].text)
                                                  }).catchError((err) {
                                                    err = "Unexpected error. Please try again later.";
                                                  });
                                                  if (err.isNotEmpty) {
                                                    setState(() => loading = false);
                                                    return;
                                                  }
        
                                                  QuerySnapshot query = await firestore.collection("info").doc(data["id"]).collection("cml").get();
                                                  for (DocumentSnapshot doc in query.docs) {
                                                    double pipe_size = double.parse(controller["pipe_size"].text);
                                                    double dp = double.parse(controller["design_pressure"].text);
                                                    double stress = double.parse(controller["stress"].text);
                                                    double je = double.parse(controller["joint_efficiency"].text);
                                                    double aod = cal_actual_OD(pipe_size);
                                                    double st = cal_strucural(pipe_size);
                                                    double dt = cal_design_thickness(dp, aod, stress, je);
                                                    await firestore.collection("info").doc(data["id"]).collection("cml").doc(doc.id).update(
                                                      {
                                                        "actual_outside_diameter": aod,
                                                        "design_thickness": dt,
                                                        "required_thickness": cal_required_thickness(dt, st),
                                                        "structural_thickness": st
                                                      }
                                                    );
                                                  }
                                                  if (!mounted) { return; }
                                                  Navigator.pop(context);
                                                  _snack_text = "${data["line_number"]} Edited";
                                                  _show_snack = true;
                                                  _getData();
                                                },
                                                child: loading ? const SizedBox(height: 21, width: 21, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("SAVE EDIT", style: TextStyle(fontSize: 18, color: Colors.white)), // only god and me can understand this, now only I can understand this
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              ),
                            ),
                          );
                        },
                        (data) {
                          bool loading = false;
                          String err = "";
                          showGeneralDialog(
                            transitionDuration: Duration.zero, // minimalism rules
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.2),
                            context: context,
                            pageBuilder: (context, _, __) => StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DialogScaffold(
                                        height: 160,
                                        appBar: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Delete / ${data["line_number"]}",
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                      
                                            if (!loading) ... [
                                              MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () => Navigator.pop(context),
                                                  child: const Icon(Icons.close),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                        body: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(),
                                              const Text("Confirm Delete?", style: TextStyle(fontSize: 20)),
                                              if (err.isNotEmpty) ... [
                                                Text(err, style: const TextStyle(fontSize: 16, color: dexon_red)),
                                                const SizedBox(height: 16),
                                              ],
                                              SimpleButton(
                                                onClick: () async {
                                                  if (loading) {return;}
                                                  err = "";
                                                  setState(() => loading = true);
                                                  await firestore.collection("info").doc(data["id"]).delete().catchError((err) {
                                                    err = "Unexpected error. Please try again later";
                                                  });
                                                  loading = false;
                                                  if (err.isNotEmpty) {
                                                    setState(() {});
                                                    return;
                                                  }
                                                  if (!mounted) { return; }
                                                  Navigator.pop(context);
                                                  _show_snack = true;
                                                  _snack_text = "${data["line_number"]} Deleted";
                                                  _getData();
                                                },
                                                child: loading ? const SizedBox(height: 21, width: 21, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("CONFIRM", style: TextStyle(fontSize: 18, color: Colors.white)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                          );
                        }
                      ],
                    ),
                  ],
                ),
              ),
            ] else ... [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 256, color: Colors.grey.shade300),
                    Text("No Data Found", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}