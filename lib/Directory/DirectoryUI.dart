import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

class DirectoryUI extends StatefulWidget {
  const DirectoryUI({Key? key}) : super(key: key);

  @override
  State<DirectoryUI> createState() => _DirectoryUIState();
}

class _DirectoryUIState extends State<DirectoryUI> {
  List<Marker> markers = [];
  List directories = [];
  var centerLat = 15.0284;
  var centerLang = 120.6937;
  final mapController = MapController();

  getPharmacies(String searchKey)async{

    final searchResult = await Nominatim.searchByName(
      query: searchKey,
      limit: 50,
      addressDetails: true,
      extraTags: true,
      nameDetails: true,
    );

    searchResult.forEach((element) {
      directories.add(element);
      if(mounted){
        setState(() {
          markers.add(
              Marker(
                point: latLng.LatLng(element.lat, element.lon),
                width: 300,
                height: 300,
                builder: (context){
                  return Column(
                    children: [
                      const Icon(Icons.pin_drop, color: Color(0xff219C9C),),
                      Text("${element.displayName.substring(0, 10)}...", style: const TextStyle(color: Color(0xff219C9C), fontSize: 12), )
                    ],
                  );
                },
              )
          );
        });
      }
    });
    print("TOTAL MARKERS: ${markers.length}");
  }

  Future<List<Marker>> sendRequests()async{
    getPharmacies("pharmacy san fernando pampanga");
    return markers;
  }

  @override
  void initState() {
    super.initState();
    sendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builder, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight * 0.9,
        child: Padding(
          padding: const EdgeInsets.only(left: 100, right: 100),
          child: Card(
            color: const Color(0xffD9DEDC),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))
            ),
            child: Padding(
                padding: const EdgeInsets.all(20.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nearby\nPharmacies",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              var searchList = [];
                              searchList.addAll(directories);
                              showMaterialModalBottomSheet(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        topLeft: Radius.circular(20)
                                    )
                                ),
                                context: context,
                                builder: (context){
                                  return Container(
                                    height: 500,
                                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          child: TextField(
                                            style: TextStyle(
                                                fontSize: 14
                                            ),
                                            decoration: InputDecoration(
                                              label: Text("Search"),
                                              errorStyle: TextStyle(height: 0),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                                borderSide: BorderSide(
                                                  color: Color(0xff219C9C),
                                                  width: 2.0,
                                                ),
                                              ),

                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 6.0,
                                                ),
                                              ),

                                            ),
                                            onChanged: (val)async{
                                              if(val.isEmpty){
                                                searchList.clear();
                                                searchList.addAll(directories);
                                              } else {
                                                searchList.clear();
                                                for(int i = 0; i < directories.length; i++){
                                                  if(directories[i].displayName.toLowerCase().contains(val.toLowerCase())){
                                                    searchList.add(directories[i]);
                                                  }
                                                }
                                              }
                                              setState(() {

                                              });
                                            },
                                            onSubmitted: (val)async{
                                              if(val.isEmpty){
                                                searchList = directories;
                                              } else {
                                                searchList.clear();
                                                for(int i = 0; i < directories.length; i++){
                                                  if(directories[i].displayName.toLowerCase().contains(val.toLowerCase())){
                                                    searchList.add(directories[i]);
                                                  }
                                                }
                                              }
                                              setState(() {

                                              });
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: searchList.length,
                                            itemBuilder: (context, index){
                                              return ListTile(
                                                title: Text(searchList[index].displayName),
                                                subtitle: Text(searchList[index].address.toString()),
                                                onTap: (){
                                                  mapController.move(latLng.LatLng(searchList[index].lat, searchList[index].lon), 15);
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.search,
                            ),)
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 10),
                          child: Container(
                              height: 259,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                  border: Border.all(color: Colors.black, width: 6,
                                  )
                              ),
                              child: FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  center: latLng.LatLng(centerLat, centerLang),
                                  zoom: 11,
                                ),
                                nonRotatedChildren: [

                                ],
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  markers.isNotEmpty ? MarkerClusterLayerWidget(
                                    options: MarkerClusterLayerOptions(
                                      maxClusterRadius: 0,
                                      size: const Size(20, 20),
                                      fitBoundsOptions: const FitBoundsOptions(
                                        padding: EdgeInsets.all(50),
                                      ),
                                      markers: markers,
                                      polygonOptions: const PolygonOptions(
                                          borderColor: Colors.blueAccent,
                                          color: Colors.black12,
                                          borderStrokeWidth: 3),
                                      builder: (context, markers) {
                                        return FloatingActionButton(
                                          onPressed: null,
                                          child: Text(markers.length.toString()),
                                        );
                                      },
                                    ),
                                  ) : Container()
                                ],
                              )
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: directories.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              onTap: (){
                                setState(() {
                                  mapController.move(latLng.LatLng(directories[index].lat, directories[index].lon), 15);
                                });
                              },
                              leading: Icon(
                                  Icons.place_outlined
                              ),
                              title: Text(
                                directories[index].displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      )
                    ]
                ),
              )
            ),
          ),
        ),
      );
    });
  }
}
