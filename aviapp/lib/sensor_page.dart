import 'dart:async';
import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


class MotorPage extends StatefulWidget {

  const MotorPage({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<MotorPage> {
  final String SERVICE_UUID            = "";
  final String CHARACTERISTIC_UUID     = "";

  BluetoothCharacteristic targetCharacteristic;

  double _currentSliderValue1 = 0;
  double _value = 0;
  bool status = true;
  bool isReady;

  Timer _timer;

  Stream<List<int>> stream;
  // ignore: deprecated_member_use
  List<double> traceDust = List();

  @override
  void initState() {
    super.initState();
    isReady = true;
   // connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        _Pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _Pop();
      return;
    }
    targetCharacteristic.write([ 0xe8, 0xa1, 0x00]);
    targetCharacteristic.write([ 0xe8, 0xa3, 0x00]);
    targetCharacteristic.write([ 0xe8, 0xa6, 0x00]);

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() != null) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() != null) {

              targetCharacteristic = characteristic;


              targetCharacteristic.write([ 0xe8, 0xa2, 0x00, 0x64]);
              targetCharacteristic.write([ 0xe8, 0xa1, 0x01]);
              targetCharacteristic.write([ 0xe8, 0xa2, 0x00, 0x64]);
              targetCharacteristic.write([ 0xe8, 0xa5, 0x00]);


              stream = characteristic.value;


            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (!isReady) {
      _Pop();
    }
  }


  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
            new AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to disconnect device and go back?'),
              actions: <Widget>[
                // ignore: deprecated_member_use
                new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No')),
                // ignore: deprecated_member_use
                new FlatButton(
                    onPressed: () {
                      disconnectFromDevice();
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('Yes')),
              ],
            ) ??
            false);
  }

  // ignore: non_constant_identifier_names
  _Pop() {
    Navigator.of(context).pop(true);
  }


  @override
  Widget build(BuildContext context) {

    Slider  sliderPWM1 = Slider(
      value: _currentSliderValue1,
      min: 0,
      max: 255,
      divisions: 255,
      label: _currentSliderValue1.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentSliderValue1 = value;
     //     _value = _currentSliderValue1*60.0;
     //     targetCharacteristic.write([ 0xe8, 0xa3, _currentSliderValue1.toInt()]);

        });
      }
    );


    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('AviaPP'),
        ),
        body: Container(
            child: !isReady
                ? Center(
                    child: Text(
                      "Waiting...",
                      style: TextStyle(fontSize: 24, color: Colors.red),
                    ),
                  )
                : Container(
                    child: StreamBuilder<List<int>>(
                      stream: stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<int>> snapshot) {
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');

                        if (1 == 1) {

                          _value = _currentSliderValue1*60.0;

                          return Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[

                            SfRadialGauge(
                            axes: <RadialAxis>[
                                RadialAxis(startAngle: 270,
                                endAngle: 270,
                                minimum: 0,
                                maximum: 80,
                                interval: 10,
                                radiusFactor: 0.4,
                                showAxisLine: false,
                                showLastLabel: false,
                                minorTicksPerInterval: 4,
                                majorTickStyle: MajorTickStyle(
                                    length: 8, thickness: 3, color: Colors.white),
                                minorTickStyle: MinorTickStyle(
                                    length: 3, thickness: 1.5, color: Colors.grey),
                                axisLabelStyle: GaugeTextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                onLabelCreated: labelCreated
                            ),
                              RadialAxis(
                                  minimum: 0,
                                  maximum: 15000,
                                  labelOffset: 30,
                                  axisLineStyle: AxisLineStyle(
                                      thicknessUnit: GaugeSizeUnit.factor, thickness: 0.03),
                                  majorTickStyle: MajorTickStyle(
                                      length: 6, thickness: 4, color: Colors.white),
                                  minorTickStyle: MinorTickStyle(
                                      length: 3, thickness: 3, color: Colors.white),
                                  axisLabelStyle: GaugeTextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                  ranges: <GaugeRange>[
                                    GaugeRange(startValue: 0,
                                        endValue: 16000,
                                        sizeUnit: GaugeSizeUnit.factor,
                                        startWidth: 0.03,
                                        endWidth: 0.03,
                                        gradient: SweepGradient(
                                            colors: const<Color>[
                                              Colors.green,
                                              Colors.yellow,
                                              Colors.red
                                            ],
                                            stops: const<double>[0.0, 0.5, 1]))
                                  ],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(value: _value,
                                        needleLength: 0.95,
                                        enableAnimation: true,
                                        animationType: AnimationType.ease,
                                        needleStartWidth: 1.5,
                                        needleEndWidth: 6,
                                        needleColor: Colors.red,
                                        knobStyle: KnobStyle(knobRadius: 0.09,sizeUnit: GaugeSizeUnit.factor))
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(widget: Container(child:
                                    Column(
                                        children: <Widget>[
                                          Text(_value.toInt().toString(), style: TextStyle(
                                              fontSize: 25, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 20),
                                          Text('RPM', style: TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.bold))
                                        ]
                                    )), angle: 90, positionFactor: 1.65)
                                  ]
                              )
                              ]),
                              _buildLabel('Lights'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:<Widget>[
                                  CustomSwitch(
                                    activeColor: Colors.lightGreenAccent,
                                    value: status,
                                    onChanged: (value) {
                                      setState(() {
                                        status = value;

                                        if(status){
                                          targetCharacteristic.write([ 0xe8, 0xa6, 0x55]);
                                        } else{
                                          targetCharacteristic.write([ 0xe8, 0xa6, 0x00]);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Expanded(
                                flex: 0,
                                child: sliderPWM1,
                              ),
                            ],
                          ));
                        } else {return Text('Check the stream');
                        }
                      },
                    ),
                  )),
      ),
    );
  }

  void labelCreated(AxisLabelCreatedArgs args) {
    if (args.text == '0') {
      args.text = 'N';
    }
    else if (args.text == '80')
      args.text = '';
    else if (args.text == '10')
      args.text = '';
    else if (args.text == '20')
      args.text = 'E';
    else if (args.text == '30')
      args.text = '';
    else if (args.text == '40')
      args.text = 'S';
    else if (args.text == '50')
      args.text = '';
    else if (args.text == '60')
      args.text = 'W';
    else if (args.text == '70')
      args.text = '';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildLabel(String value) {
    return Container(
      margin: EdgeInsets.only(
        top: 25,
        bottom: 5,
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }

}
