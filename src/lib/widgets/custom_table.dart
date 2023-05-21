import 'package:flutter/material.dart';

import '../widgets/clickable_text.dart';

class CustomTable extends StatelessWidget {
  final List header;
  final List h_key;
  final List data;
  final List menu_list;
  final List on_menu_click;
  final Map<int, TableColumnWidth> columnWidth;

  const CustomTable({
    super.key,
    required this.header,
    required this.h_key,
    required this.data,
    required this.menu_list,
    required this.on_menu_click,
    this.columnWidth = const {},
  });

  @override
  Widget build(BuildContext context) => Table(
    columnWidths: columnWidth,
    children: [
      TableRow(
        children: List.generate(header.length, (index) => Container(
          color: Colors.grey.shade200,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(header[index], style: const TextStyle(fontSize: 18), overflow: TextOverflow.ellipsis),
        ))
      ),
      for(int index = 0; index < data.length; index++) ...[
        TableRow(
          children: List.generate(h_key.length, (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: SelectableText(data[index][h_key[i]].toString(), style:  const TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis)) // what the fuck
          ))..add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(menu_list.length, (i) => ClickableText(
                  onClick: () => on_menu_click[i](data[index]),
                  text: menu_list[i].split("!")[0],
                  textColor: menu_list[i].split("!").length > 1 ? Colors.red : Colors.blue,
                )),
              ),
            ),
          )
        ),
      ]
    ],
  );
}