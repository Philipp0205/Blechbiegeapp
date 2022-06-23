import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/pages/constructing_page/config_page_segment_widget.dart';

import '../../bloc /configuration_page/configuration_page_bloc.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key}) : super(key: key);

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  bool showCoordinates = true;
  bool showEdgeLengths = false;

  final _sController = TextEditingController();
  final _rController = TextEditingController();

  @override
  void initState() {
    super.initState();

    double s = context.read<ConfigurationPageBloc>().state.s;
    double r = context.read<ConfigurationPageBloc>().state.r;
    _sController.text = s.toStringAsFixed(0);

    _rController.text = r.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _sController.dispose();
    _rController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigurationPageBloc, ConstructingPageState>(
        builder: (context, state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Biegeapp')],
          ),
        ),
        backgroundColor: Colors.white,
          floatingActionButton: Stack(
            children: [
              /// Left Button
              Positioned(
                left: 40,
                bottom: 20,
                child: FloatingActionButton(
                  heroTag: "btn1",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_left),
                onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              /// Right Button
              Positioned(
                bottom: 20,
                right: 10,
                child: FloatingActionButton(
                  heroTag: "btn2",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_right),
                  onPressed: () => Navigator.of(context).pushNamed("/third"),
                ),
              ),
            ],
          ),
        body: Container(
          child: Column(
            children: [
              // section Title
              // section CustomPainter
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ConstructingPageSegmentWidget(),
              ),
              Row(
                children: [
                  Checkbox(
                      value: state.showCoordinates,
                      onChanged: (bool? value) {
                        context.read<ConfigurationPageBloc>().add(
                            ConfigCoordinatesShown(
                                showCoordinates: value!));
                        print('checkbox');
                      }),
                  Text('Koordinaten'),
                  Checkbox(
                      value: state.showEdgeLengths,
                      onChanged: (bool? value) {
                        context.read<ConfigurationPageBloc>().add(
                            ConfigEdgeLengthsShown(
                                showEdgeLengths: value!));
                      }),
                  Text('Längen'),
                  Checkbox(
                      value: state.showAngles,
                      onChanged: (bool? value) {
                        context.read<ConfigurationPageBloc>().add(
                            ConfigAnglesShown(showAngles: value!));
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
                            context.read<ConfigurationPageBloc>().add(
                                ConfigSChanged(
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
                            double? value = double.tryParse(text);
                            if (value != null) {
                              context.read<ConfigurationPageBloc>().add(
                                  ConfigRChanged(
                                      r: double.parse(_rController.text)));
                            }
                          }),
                    ),
                    Text('Radius (r)'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
