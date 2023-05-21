import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam/pages/test_point.dart';
import 'package:exam/utils/calculate.dart';
import 'package:exam/utils/global.dart';
import 'package:exam/widgets/clickable_text.dart';
import 'package:exam/widgets/custom_table.dart';
import 'package:exam/widgets/snack_alert.dart';
import 'package:flutter/material.dart';

import '../utils/controller_validator.dart';
import '../widgets/button.dart';
import '../widgets/dialog_scaffold.dart';
import '../widgets/simple_textfield.dart';

class CML extends StatefulWidget {
  final Map pipe_data;
  const CML({super.key, required this.pipe_data});

  @override
  State<CML> createState() => _CMLState();
}

class _CMLState extends State<CML> {
  bool _loaded = false;
  final List _data = [];

  bool _show_snack = false;
  String _snack_text = "";

  @override
  void initState() {
    _getData(widget.pipe_data["line_number"]);
    super.initState();
  }

  _getData(line_number) async {
    setState(() {
      _loaded = false;
      _data.clear();
    });
    QuerySnapshot query = await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").where("line_number", isEqualTo: line_number).orderBy("cml_number").get();
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
                },
              ),
            ),
            const TextSpan(
              text: " / "
            ),
            const TextSpan(
              text: "CML"
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
            Text(widget.pipe_data["line_number"], style: const TextStyle(fontSize: 32)),
    
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // refresh
                  const Icon(Icons.refresh, color: Colors.blue, size: 20),
                  ClickableText(
                    onClick: () {
                      _getData(widget.pipe_data["line_number"]);
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
                        "cml_number": TextEditingController(),
                        "cml_description": TextEditingController(),
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
                                            "Add CML",
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
                                              controller: TextEditingController()..text = widget.pipe_data["line_number"],
                                              read_only: true,
                                            ),
                                            SimpleTextField(
                                              title: "CML Number",
                                              controller: controller["cml_number"],
                                              only_number: true,
                                            ),
                                            SimpleTextField(
                                              title: "CML Description",
                                              controller: controller["cml_description"],
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
                                                if (!controller_validate(controller)) {
                                                  err = "All field must be filled";
                                                  loading = false;
                                                  return;
                                                }
                                      
                                                // check existng
                                                QuerySnapshot exist = await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").where("cml_number", isEqualTo: double.parse(controller["cml_number"].text)).get();
                                                if (exist.docs.isNotEmpty) {
                                                  err = "This CML number is already exist";
                                                  setState(() => loading = false);
                                                  return;
                                                }

                                                double aod = cal_actual_OD(widget.pipe_data["pipe_size"]);
                                                double st = cal_strucural(widget.pipe_data["pipe_size"]);
                                                double dt = cal_design_thickness(widget.pipe_data["design_pressure"], aod, widget.pipe_data["stress"], widget.pipe_data["joint_efficiency"]);
                                                await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").add(
                                                  {
                                                    "line_number": widget.pipe_data["line_number"],
                                                    "cml_number": double.parse(controller["cml_number"].text),
                                                    "cml_description": controller["cml_description"].text,
                                                    "actual_outside_diameter": aod,
                                                    "design_thickness": dt,
                                                    "required_thickness": cal_required_thickness(dt, st),
                                                    "structural_thickness": st,
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
                                                _snack_text = "New CML Added";
                                                _getData(widget.pipe_data["line_number"]);
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
                    text: "Add CML",
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
                        0: FlexColumnWidth(0.6),
                      },
                      header: const ["CML Number\n    ", "CML Description\n  ", "Actual\nOutside Diameter", "Design\nThickness (mm)", "Structural\nThickness (mm)", "Required\nThickness", " \n "],
                      h_key: const ["cml_number", "cml_description", "actual_outside_diameter", "design_thickness", "structural_thickness", "required_thickness"],
                      data: _data,
                      menu_list: const ["View TP", "Edit", "Delete!"],
                      on_menu_click: [
                        (data) {
                          setState(() => _show_snack = false);
                          Navigator.push(
                            context, 
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => TestPoint(pipe_data: widget.pipe_data, cml_data: data),
                            ),  
                          );
                        },
                        (data) {
                          bool loading = false;
                          String err = "";
                          Map controller = {
                            "cml_number": TextEditingController()..text = data["cml_number"].toString(),
                            "cml_description": TextEditingController()..text = data["cml_description"].toString(),
                          };
              
                          showGeneralDialog(
                            transitionDuration: Duration.zero,
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
                                                "Edit CML / ${data["cml_number"]}",
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
                                                  controller: TextEditingController()..text = widget.pipe_data["line_number"],
                                                  read_only: true,
                                                ),
                                                SimpleTextField(
                                                  title: "CML Number",
                                                  controller: controller["cml_number"],
                                                  read_only: true,
                                                ),
                                                SimpleTextField(
                                                  title: "CML Description",
                                                  controller: controller["cml_description"],
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
                                                    if (!controller_validate(controller)) {
                                                      err = "All field must be filled";
                                                      loading = false;
                                                      return;
                                                    }
              
                                                    await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(data["id"]).update({
                                                      "cml_description": controller["cml_description"].text
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
                                                    _snack_text = "${data["cml_number"]} Edited";
                                                    _getData(widget.pipe_data["line_number"]);
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
                                              "Delete / ${data["cml_number"]}",
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
                                                  await firestore.collection("info").doc(widget.pipe_data["id"]).collection("cml").doc(data["id"]).delete().catchError((err) {
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
                                                  _snack_text = "${data["cml_number"]} Deleted";
                                                  _getData(widget.pipe_data["line_number"]);
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
                      ]
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    ),
  );
}