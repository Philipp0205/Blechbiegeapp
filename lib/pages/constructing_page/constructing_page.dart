import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/pages/constructing_page/constructing_page_segment_widget.dart';
import 'package:open_bsp/pages/constructing_page/constructing_sketcher.dart';

import '../../bloc /constructing/constructing_page_bloc.dart';

class ConstructingPage extends StatefulWidget {
  const ConstructingPage({Key? key}) : super(key: key);

  @override
  _ConstructingPageState createState() => _ConstructingPageState();
}

class _ConstructingPageState extends State<ConstructingPage> {
  bool showCoordinates = true;
  bool showEdgeLengths = false;

  final _sController = TextEditingController();
  final _rController = TextEditingController();

  @override
  void initState() {
    super.initState();

    double s = context.read<ConstructingPageBloc>().state.s;
    double r = context.read<ConstructingPageBloc>().state.r;
    _sController.text = s.toStringAsFixed(0);

    _rController.text = r.toStringAsFixed(0);
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("USA"), value: "USA"),
      DropdownMenuItem(child: Text("Canada"), value: "Canada"),
      DropdownMenuItem(child: Text("Brazil"), value: "Brazil"),
      DropdownMenuItem(child: Text("England"), value: "England"),
    ];
    return menuItems;
  }

  @override
  void dispose() {
    _sController.dispose();
    _sController.dispose();
    super.dispose();
  }

  @override
  String selectedValue = "USA";

  Widget build(BuildContext context) {
    return BlocBuilder<ConstructingPageBloc, ConstructingPageState>(
        builder: (context, state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Biegeapp')],
          ),
        ),
        backgroundColor: Colors.yellow[50],
        body: Container(
          child: Column(
            children: [
              // section Title
              // section CustomPainter
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ConstructingPageSegmentWidget(),
              ),
              // section Checkboxes
              /*
              *    ____ _               _    _
              *   / ___| |__   ___  ___| | _| |__   _____  _____  ___
              *  | |   | '_ \ / _ \/ __| |/ / '_ \ / _ \ \/ / _ \/ __|
              *  | |___| | | |  __/ (__|   <| |_) | (_) >  <  __/\__ \
              *   \____|_| |_|\___|\___|_|\_\_.__/ \___/_/\_\___||___/
              *
              */

              Row(
                children: [
                  Checkbox(
                      value: state.showCoordinates,
                      onChanged: (bool? value) {
                        context.read<ConstructingPageBloc>().add(
                            ConstructingPageCoordinatesShown(
                                showCoordinates: value!));
                        print('checkbox');
                      }),
                  Text('Koordinaten'),
                  Checkbox(
                      value: state.showEdgeLengths,
                      onChanged: (bool? value) {
                        context.read<ConstructingPageBloc>().add(
                            ConstructingPageEdgeLengthsShown(
                                showEdgeLengths: value!));
                      }),
                  Text('Längen'),
                  Checkbox(
                      value: state.showAngles,
                      onChanged: (bool? value) {
                        context.read<ConstructingPageBloc>().add(
                            ConstructingPageAnglesShown(showAngles: value!));
                      }),
                  Text('Winkel')
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              // section thickness
              /*
              *   _   _     _      _
              *  | |_| |__ (_) ___| | ___ __   ___  ___ ___
              *  | __| '_ \| |/ __| |/ / '_ \ / _ \/ __/ __|
              *  | |_| | | | | (__|   <| | | |  __/\__ \__ \
              *   \__|_| |_|_|\___|_|\_\_| |_|\___||___/___/
              *
              */
              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      child: TextField(
                          controller: _sController,
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            context.read<ConstructingPageBloc>().add(
                                ConstructingPageSChanged(
                                    s: double.parse(_sController.text)));
                          }),
                    ),
                    Text('Bleckdicke (s)   '),
                    Container(
                      width: 30,
                      height: 30,
                      child: TextField(
                          controller: _rController,
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            context.read<ConstructingPageBloc>().add(
                                ConstructingPageRChanged(
                                    r: double.parse(_rController.text)));
                          }),
                    ),
                    Text('Radius (r) (buggy)'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                child: Row(
                  children: [
                    // DropdownButton(
                    //     value: selectedValue,
                    //     onChanged: (String? newValue){
                    //       setState(() {
                    //         selectedValue = newValue!;
                    //       });
                    //     },
                    //     items: dropdownItems
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
