import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiz/models/location_model.dart';

class MapPages extends StatefulWidget {
  const MapPages({super.key});

  @override
  State<MapPages> createState() => _MapPagesState();
}

class _MapPagesState extends State<MapPages> {
  bool isDetail = false;
  bool isSearch = false;
  late FocusNode myFocusNode;
  LatLng _currentPosition = LatLng(-6.24167456424069, 106.83614573480172);
  late LocationModel _selectedLocation;

  final List<LocationModel> _locations = [
    LocationModel(
        name: "Rumah Sakit Anak dan Bunda Harapan Kita",
        address: "Jl. Suka Maju No. 1",
        image:
            "https://lh5.googleusercontent.com/p/AF1QipP70dwasTO51sZOek4DBc7oiSoEl-N7VmRDS_xS=w408-h270-k-no",
        lat: -6.1845396886288855,
        lng: 106.7989743276285),
    LocationModel(
        name: "RSUD Bogor",
        address: "Jl. Suka Maju No. 1",
        image:
            "https://lh5.googleusercontent.com/p/AF1QipMf6XBkRSiW8cIA7cWvBBrrxclLixjk_gr_6uda=w408-h254-k-no",
        lat: -6.2428189655075546,
        lng: 106.83413551564657),
  ];

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.24167456424069, 106.83614573480172),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      target: LatLng(-6.24167456424069, 106.83614573480172),
      zoom: 90.151926040649414);

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            onTap: (LatLng) {
              myFocusNode.unfocus();
              _hideDetail();
            },
            mapType: MapType.normal,
            markers: {
              const Marker(
                markerId: MarkerId('Pancoran'),
                position: LatLng(-6.24167456424069, 106.83614573480172),
                draggable: true,
              ),
              Marker(
                  markerId: MarkerId('detail-location'),
                  position: _currentPosition,
                  draggable: true,
                  onTap: _showDetailSelectedLocation),
            },
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SafeArea(
                child: TextField(
                  onSubmitted: (value) {
                    _searchLocation();
                  },
                  focusNode: myFocusNode,
                  onTap: () {
                    _hideDetail();
                    myFocusNode.requestFocus();
                  },
                  decoration: InputDecoration(
                    suffixIcon: isSearch
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : SizedBox(),
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Cari Rumah Sakit",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // isDetail
          //     ? Align(
          //         alignment: Alignment.bottomCenter,
          //         child: Container(
          //           width: double.infinity,
          //           height: MediaQuery.of(context).size.height * 0.15,
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //           ),
          //           child: SafeArea(
          //               child: Column(
          //             children: [Text("sds")],
          //           )),
          //         ),
          //       )
          //     : SizedBox()
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<void> _resetPosition() async {
    final GoogleMapController controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  }

  Future<void> _goToThePosition({required LocationModel location}) async {
    CameraPosition pos = CameraPosition(
        target: LatLng(location.lat, location.lng), zoom: 90.151926040649414);
    setState(() {
      _currentPosition = LatLng(location.lat, location.lng);
      _selectedLocation = location;
    });
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(pos));
  }

  Future<void> _searchLocation() async {
    setState(() {
      isSearch = true;
    });
    await Future.delayed(Duration(seconds: 2));
    _showDetail();
    setState(() {
      isSearch = false;
    });
  }

  void _showDetail() {
    myFocusNode.unfocus();
    _resetPosition();
    // setState(() {
    //   isDetail = true;
    // });
    showModalBottomSheet(
        useSafeArea: true,
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            SizedBox(
              height: 18,
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 50,
                height: 5,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Hasil pencarian",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black87),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              children: List.generate(
                _locations.length,
                (index) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      _locations[index].image,
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    _locations[index].name,
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  subtitle: new Text(_locations[index].address),
                  onTap: () {
                    _goToThePosition(location: _locations[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ]);
        });
  }

  void _hideDetail() {
    myFocusNode.unfocus();
    setState(() {
      isDetail = false;
    });
  }

  void _showDetailSelectedLocation() {
    myFocusNode.unfocus();
    showModalBottomSheet(
        useSafeArea: true,
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                height: 18,
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 50,
                  height: 5,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Detail Lokasi",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black87),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    _selectedLocation.image,
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  _selectedLocation.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                subtitle: Text(_selectedLocation.address),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Layanan yang tersedia",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Flexible(
                  child: Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ServiceWidget(
                      text: "IGD",
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ServiceWidget(
                      text: "Poli Umum",
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ServiceWidget(
                      text: "Poli Gigi",
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ServiceWidget(
                      text: "Poli Kandungan",
                    ),
                  ],
                ),
              )),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Jam Operasional",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 20,
              ),
            ]),
          );
        });
  }
}

class ServiceWidget extends StatelessWidget {
  String text = "Service";
  ServiceWidget({
    super.key,
    this.text = "Service",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
