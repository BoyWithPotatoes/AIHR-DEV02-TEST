import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam/pages/thickness.dart';
import 'package:exam/widgets/snack_alert.dart';
import 'package:flutter/material.dart';

import '../utils/controller_validator.dart';
import '../utils/global.dart';
import '../widgets/button.dart';
import '../widgets/clickable_text.dart';
import '../widgets/custom_table.dart';
import '../widgets/dialog_scaffold.dart';
import '../widgets/simple_textfield.dart';

class TestPoint extends StatefulWidget {
  final Map pipe_data;
  final Map cml_data;
  const TestPoint({
    super.key,
    required this.pipe_data,
    required this.cml_data,
  });

  @override
  State<TestPoint> createState() => _TestPointState();
}

class _TestPointState extends State<TestPoint> {
  bool _loaded = true;
  final List _data = [];

  bool _show_snack = false;
  String _snack_text = "";

  @override
  void initState() {
    _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"]);
    super.initState();
  }

  _getData(line_number, cml_number) async {
    setState(() {
      _loaded = false;
      _data.clear();
    });
    QuerySnapshot query = await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").where("line_number", isEqualTo: line_number).where("cml_number", isEqualTo: cml_number).orderBy("tp_number").get();
    for (var doc in query.docs) {
      _data.add((doc.data() as Map<String, dynamic>)..["id"] = doc.id);
    }
    setState(() => _loaded = true);
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black
          ),
          children: [
            WidgetSpan(
              child: ClickableText(
                text: "PIPING",
                textColor: Colors.grey.shade600,
                textSize: 20,
                onClick: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
            TextSpan(
              text: " / ",
              style: TextStyle(color: Colors.grey.shade600)
            ),
            WidgetSpan(
              child: ClickableText(
                text: "CML",
                textColor: Colors.grey.shade600,
                textSize: 20,
                onClick: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const TextSpan(
              text: " / "
            ),
            const TextSpan(
              text: "Test Point"
            )
          ]
        ),
      ),
    ),

    body: SnackAlert(
      on_click: () => setState(() => _show_snack = false),
      show: _show_snack,
      text: _snack_text,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: !_loaded ? Center(child: CircularProgressIndicator(color: Colors.grey.shade400,)) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.pipe_data["line_number"]} / ${widget.cml_data["cml_number"]}", style: const TextStyle(fontSize: 32)),
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // refresh
                  const Icon(Icons.refresh, color: Colors.blue, size: 20),
                  ClickableText(
                    onClick: () {
                      _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"]);
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
                        "tp_number": TextEditingController(),
                        "tp_description": TextEditingController(),
                        "note": TextEditingController(),
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
                                            "Add Test Point",
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
                                      body: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SimpleTextField(
                                              title: "Line Number",
                                              controller: TextEditingController()..text = widget.pipe_data["line_number"].toString(),
                                              read_only: true,
                                            ),
                                            SimpleTextField(
                                              title: "CML Number",
                                              controller: TextEditingController()..text = widget.cml_data["cml_number"].toString(),
                                              read_only: true,
                                            ),
                                            SimpleTextField(
                                              title: "TP Number",
                                              controller: controller["tp_number"],
                                              only_number: true,
                                            ),
                                            SimpleTextField(
                                              title: "TP Description",
                                              controller: controller["tp_description"],
                                              only_number: true,
                                            ),
                                            SimpleTextField(
                                              title: "Note",
                                              controller: controller["note"],
                                            ),
                                            
                                            const Spacer(),
                                            if (err.isNotEmpty) ... [
                                              Text(err, style: const TextStyle(fontSize: 16, color: dexon_red)),
                                              const SizedBox(height: 16),
                                            ],
                                            
                                            SimpleButton(
                                              onClick: () async {
                                                if (loading) {return;}
                                                setState(() {
                                                  loading = true;
                                                  err = "";
                                                });
                                                if (!controller_validate(controller, except: [controller["note"]])) {
                                                  err = "All field must be filled";
                                                  loading = false;
                                                  return;
                                                }
                                      
                                                // check existng
                                                QuerySnapshot exist = await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").where("tp_number", isEqualTo: double.parse(controller["tp_number"].text)).get();
                                                if (exist.docs.isNotEmpty) {
                                                  err = "This Test Point number is already exist";
                                                  setState(() => loading = false);
                                                  return;
                                                }
                                                await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").add(
                                                  {
                                                    "line_number": widget.pipe_data["line_number"],
                                                    "cml_number": widget.cml_data["cml_number"],
                                                    "tp_number": double.parse(controller["tp_number"].text),
                                                    "tp_description": double.parse(controller["tp_description"].text),
                                                    "note": controller["note"].text,
                                                  }
                                                ).catchError((err) {
                                                  err = "Unexpected error. Please try again later.";
                                                  return err;
                                                });
                                                if (err.isNotEmpty) {
                                                  return;
                                                }
                                      
                                                if (!mounted) { return; }
                                                Navigator.pop(context);
                                                _show_snack = true;
                                                _snack_text = "New Test Point Added";
                                                _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"]);
                                              },
                                              child: loading ? const SizedBox(height: 21, width: 21, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("ADD", style: TextStyle(fontSize: 18, color: Colors.white)), // only god and me can understand this
                                            ),
                                          ],
                                        ),
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
                    text: "Add Test Point",
                    textColor: Colors.blue,
                  ),
                ],
              ),
            ),
    
            if (_data.isEmpty) ... [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 256, color: Colors.grey.shade300),
                    Text("No Data Found", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  ],
                ),
              ),
            ] else ... [
              Expanded(
                child: ListView(
                  children: [
                    CustomTable(
                      columnWidth: const {
                        0: FlexColumnWidth(0.5),
                        1: FlexColumnWidth(0.5),
                        3: FlexColumnWidth(0.5),
                      },
                      header: const ["TP Number", "TP Description", "Note", ""],
                      h_key: const ["tp_number", "tp_description", "note"],
                      data: _data,
                      menu_list: const ["View Thickness", "Edit", "Delete!"],
                      on_menu_click: [
                        (data) {
                          setState(() => _show_snack = false);
                          Navigator.push(
                            context, 
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => Thickness(pipe_data: widget.pipe_data, cml_data: data, tp_data: data),
                            ),  
                          );
                        },
                        (data) {
                          bool loading = false;
                          String err = "";
                          Map controller = {
                            "tp_description": TextEditingController()..text = data["tp_description"].toString(),
                            "note": TextEditingController()..text = data["note"].toString(),
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
                                              Text(
                                                "Edit Test point / ${data["tp_number"]}",
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SimpleTextField(
                                                  title: "Line Number",
                                                  controller: TextEditingController()..text = widget.pipe_data["line_number"].toString(),
                                                  read_only: true,
                                                ),
                                                SimpleTextField(
                                                  title: "CML Number",
                                                  controller: TextEditingController()..text = widget.cml_data["cml_number"].toString(),
                                                  read_only: true,
                                                ),
                                                SimpleTextField(
                                                  title: "TP Number",
                                                  controller: TextEditingController()..text = data["tp_number"].toString(),
                                                  read_only: true,
                                                  only_number: true,
                                                ),
                                                SimpleTextField(
                                                  title: "TP Description",
                                                  controller: controller["tp_description"],
                                                  only_number: true,
                                                ),
                                                SimpleTextField(
                                                  title: "Note",
                                                  controller: controller["note"],
                                                ),
                                                
                                                const Spacer(),
                                                if (err.isNotEmpty) ... [
                                                  Text(err, style: const TextStyle(fontSize: 16, color: dexon_red)),
                                                  const SizedBox(height: 16),
                                                ],
                                                
                                                SimpleButton(
                                                  onClick: () async {
                                                    if (loading) {return;}
                                                    setState(() {
                                                      loading = true;
                                                      err = "";
                                                    });
                                                    if (!controller_validate(controller, except: [controller["note"]])) {
                                                      err = "All field must be filled";
                                                      loading = false;
                                                      return;
                                                    }
              
                                                    await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").doc(data["id"]).update({
                                                      "tp_description": double.parse(controller["tp_description"].text),
                                                      "note": controller["note"].text
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
                                                    _snack_text = "${data["tp_number"]} Edited";
                                                    _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"]);
                                                  },
                                                  child: loading ? const SizedBox(height: 21, width: 21, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("SAVE EDIT", style: TextStyle(fontSize: 18, color: Colors.white)),
                                                ),
                                              ],
                                            ),
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
                                              "Delete / ${data["tp_number"]}",
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
                                                  await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").doc(data["id"]).delete().catchError((err) {
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
                                                  _snack_text = "${data["tp_number"]} Deleted";
                                                  _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"]);
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
              )
            ]
          ],
        ),
      ),
    ),
  );
}