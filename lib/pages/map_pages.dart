import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiz/models/location_model.dart';

class MapPages extends StatefulWidget {
  const MapPages({super.key});

  @override
  State<MapPages> createState() => _MapPagesState();
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _MapPagesState extends State<MapPages> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.24167456424069, 106.83614573480172),
    zoom: 14.4746,
  );
  static const CameraPosition _kLake = CameraPosition(
      target: LatLng(-6.24167456424069, 106.83614573480172),
      zoom: 14.151926040649414);
  bool isDetail = false;
  bool isSearch = false;
  late FocusNode myFocusNode;

  LatLng _currentPosition = const LatLng(-6.24167456424069, 106.83614573480172);

  late LocationModel _selectedLocation;

  final List<LocationModel> _locations = [
    LocationModel(
        name: "Rumah Sakit Anak dan Bunda Harapan Kita",
        address:
            "Jl. Letjen S. Parman No.Kav. 87, Slipi, Kec. Palmerah, Kota Jakarta Barat, Daerah Khusus Ibukota Jakarta 11420",
        image:
            "https://lh5.googleusercontent.com/p/AF1QipP70dwasTO51sZOek4DBc7oiSoEl-N7VmRDS_xS=w408-h270-k-no",
        lat: -6.1845396886288855,
        lng: 106.7989743276285),
    LocationModel(
      name: "RSUD Kota Bogor",
      address:
          "Jl. DR. Sumeru No.120, RT.03/RW.20, Menteng, Kec. Bogor Bar., Kota Bogor, Jawa Barat 16112",
      image:
          "https://lh5.googleusercontent.com/p/AF1QipMf6XBkRSiW8cIA7cWvBBrrxclLixjk_gr_6uda=w408-h254-k-no",
      lat: -6.556775559614826,
      lng: 106.77233506290314,
    ),
  ];

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

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
                  markerId: const MarkerId('detail-location'),
                  position: _currentPosition,
                  draggable: true,
                  onTap: _showDetailSelectedLocation),
              for (var item in _locations)
                Marker(
                  markerId: MarkerId(item.name),
                  position: LatLng(item.lat, item.lng),
                  draggable: true,
                  onTap: () {
                    _goToThePosition(location: item);
                  },
                ),
            },
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Cari Rumah Sakit",
                    prefixIcon: const Icon(Icons.search),
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

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<void> _goToThePosition({required LocationModel location}) async {
    CameraPosition pos = CameraPosition(
        target: LatLng(location.lat, location.lng), zoom: 14.151926040649414);
    setState(() {
      _currentPosition = LatLng(location.lat, location.lng);
      _selectedLocation = location;
    });
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(pos));
    _showDetailSelectedLocation();
  }

  void _hideDetail() {
    myFocusNode.unfocus();
    setState(() {
      isDetail = false;
    });
  }

  Future<void> _resetPosition() async {
    final GoogleMapController controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  }

  Future<void> _searchLocation() async {
    setState(() {
      isSearch = true;
    });
    await Future.delayed(const Duration(seconds: 2));
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
            const SizedBox(
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
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Hasil pencarian",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black87),
            ),
            const SizedBox(
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  subtitle: Text(_locations[index].address),
                  onTap: () {
                    _goToThePosition(location: _locations[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ]);
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
              const SizedBox(
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
              const SizedBox(
                height: 5,
              ),
              const Text(
                "Detail Lokasi",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black87),
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                subtitle: Text(_selectedLocation.address),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
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
              const SizedBox(
                height: 5,
              ),
              Flexible(
                  child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ServiceWidget(
                      text: "IGD",
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ServiceWidget(
                      text: "Poli Umum",
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ServiceWidget(
                      text: "Poli Gigi",
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ServiceWidget(
                      text: "Poli Kandungan",
                    ),
                  ],
                ),
              )),
              const SizedBox(
                height: 10,
              ),
              const Row(
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
              const SizedBox(
                height: 5,
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
          );
        });
  }
}
