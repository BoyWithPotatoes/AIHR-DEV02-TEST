import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam/widgets/snack_alert.dart';
import 'package:flutter/material.dart';

import '../utils/controller_validator.dart';
import '../utils/global.dart';
import '../widgets/button.dart';
import '../widgets/clickable_text.dart';
import '../widgets/custom_table.dart';
import '../widgets/dialog_scaffold.dart';
import '../widgets/simple_textfield.dart';

class Thickness extends StatefulWidget {
  final Map pipe_data;
  final Map cml_data;
  final Map tp_data;
  const Thickness({
    super.key,
    required this.pipe_data,
    required this.cml_data,
    required this.tp_data,
  });

  @override
  State<Thickness> createState() => _ThicknessState();
}

class _ThicknessState extends State<Thickness> {
  bool _loaded = true;
  final List _data = [];

  bool _show_snack = false;
  String _snack_text = "";

  @override
  void initState() {
    _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"], widget.tp_data["tp_number"]);
    super.initState();
  }

  _getData(line_number, cml_number, tp_number) async {
    setState(() {
      _loaded = false;
      _data.clear();
    });
    QuerySnapshot query = await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").doc(widget.tp_data["id"]).collection("thickness").where("line_number", isEqualTo: line_number).where("cml_number", isEqualTo: cml_number).orderBy("inspection_date").where("tp_number", isEqualTo: tp_number).get(); // even god cannot understand this, but I do ;)
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
                text: "Test Point",
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
              text: "Thickness"
            )
          ]
        ),
      ),
    ),

    body: SnackAlert(
      on_click: () => setState(() => _show_snack = false),
      text: _snack_text,
      show: _show_snack,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: !_loaded ? Center(child: CircularProgressIndicator(color: Colors.grey.shade400,)) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.pipe_data["line_number"]} / ${widget.cml_data["cml_number"]} / ${widget.tp_data["tp_number"]}", style: const TextStyle(fontSize: 32)),
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // refresh
                  const Icon(Icons.refresh, color: Colors.blue, size: 20),
                  ClickableText(
                    onClick: () {
                      _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"], widget.tp_data["tp_number"]);
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
                        "inspection_date": TextEditingController(),
                        "actual_thickness": TextEditingController(),
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
                                            "Add Thickness",
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
                                              controller: TextEditingController()..text = widget.tp_data["tp_number"].toString(),
                                              read_only: true,
                                            ),
                                            SimpleTextField(
                                              title: "Inspection Date",
                                              controller: controller["inspection_date"],
                                              hint_text: "Year-Month-Day  ex. 2020-01-01",
                                              date: true,
                                            ),
                                            SimpleTextField(
                                              title: "Actual thickness",
                                              controller: controller["actual_thickness"],
                                              only_number: true,
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
                                      
                                                if (!RegExp(r'^\d{4}\-\d{2}\-\d{2}').hasMatch(controller["inspection_date"].text)) {
                                                  err = "Incorrect date format";
                                                  loading = false;
                                                  return;
                                                }

                                                await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").doc(widget.tp_data["id"]).collection("thickness").add(
                                                  {
                                                    "line_number": widget.pipe_data["line_number"],
                                                    "cml_number": widget.cml_data["cml_number"],
                                                    "tp_number": widget.tp_data["tp_number"],
                                                    "inspection_date": controller["inspection_date"].text,
                                                    "actual_thickness": double.parse(controller["actual_thickness"].text),
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
                                                _snack_text = "New Thickness Added";
                                                _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"], widget.tp_data["tp_number"]);
                                              },
                                              child: loading ? const SizedBox(height: 21, width: 21, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("ADD", style: TextStyle(fontSize: 18, color: Colors.white)),
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
                    text: "Add Thickness",
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
                        2: FlexColumnWidth(0.5),
                      },
                      header: const ["Inspection Date", "Actual Thickness (mm)", ""],
                      h_key: const ["inspection_date", "actual_thickness"],
                      data: _data,
                      menu_list: const ["Edit", "Delete!"],
                      on_menu_click: [
                        (data) {
                          bool loading = false;
                          String err = "";
                          Map controller = {
                            "inspection_date": TextEditingController()..text = data["inspection_date"].toString(),
                            "actual_thickness": TextEditingController()..text = data["actual_thickness"].toString(),
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
                                                "Edit Thickness",
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
                                                  controller: TextEditingController()..text = widget.tp_data["tp_number"].toString(),
                                                  read_only: true,
                                                ),
                                                SimpleTextField(
                                                  title: "Inspectaion Date",
                                                  controller: controller["inspection_date"],
                                                  date: true,
                                                ),
                                                SimpleTextField(
                                                  title: "Actual Thickness",
                                                  controller: controller["actual_thickness"],
                                                  only_number: true,
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

                                                    if (!RegExp(r'^\d{4}\-\d{2}\-\d{2}').hasMatch(controller["inspection_date"].text)) {
                                                      err = "Incorrect date format";
                                                      loading = false;
                                                      return;
                                                    }
              
                                                    await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").doc(widget.tp_data["id"]).collection("thickness").doc(data["id"]).update({
                                                      "inspection_date": controller["inspection_date"].text,
                                                      "actual_thickness": double.parse(controller["actual_thickness"].text)
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
                                                    _snack_text = "Edited";
                                                    _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"], widget.tp_data["tp_number"]);
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
                                            const Text(
                                              "Delete",
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
                                                  await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(widget.cml_data["id"]).collection("tp").doc(widget.tp_data["id"]).collection("thickness").doc(data["id"]).delete().catchError((err) {
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
                                                    _snack_text = "Deleted";
                                                  _getData(widget.pipe_data["line_number"], widget.cml_data["cml_number"], widget.tp_data["tp_number"]);
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