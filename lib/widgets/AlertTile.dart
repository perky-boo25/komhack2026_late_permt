import 'package:flutter/material.dart';

class AlertTile extends StatelessWidget{
  final String type;
  final String location;
  final String whenMade;
  final bool inProg;
  final VoidCallback onBtnPressed;

  const AlertTile({
    super.key,
    required this.type,
    required this.location,
    required this.whenMade,
    required this.inProg,
    required this.onBtnPressed
  });

  String getTypeEmergency(){
    return"$type Emergency";
  }


  Widget getTileIcon(){
    switch(type){
      case 'SOS':
        return ImageIcon(
          AssetImage("assets/sos.png"),
          color: Colors.red,
          size: 40
        );
      case 'Fire':
        return ImageIcon(
          AssetImage("assets/fire.png"),
          color: Colors.orange,
          size: 40
        );
      case 'Flood':
        return ImageIcon(
          AssetImage("assets/flood.png"),
          color: Colors.blue,
          size: 40
        );
      case 'Medic':
        return ImageIcon(
          AssetImage("assets/medic.png"),
          color: Colors.green,
          size: 40
        );
      case 'Other':
        return ImageIcon(
          AssetImage("assets/other.png"),
          color: Colors.black,
          size: 40
        );
      default:
        return ImageIcon(
          AssetImage("assets/other.png"),
          color: Colors.black,
          size: 40
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical:4, horizontal: 16),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: const
            BorderRadius.all(Radius.circular(8)),
            side:
              BorderSide(
                color: Colors.black,
                width: 0.5,
            ),
        ),
        leading: getTileIcon(),
        title: Row(
          children: [
            Text(
              getTypeEmergency(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                
              ),
            ),
            
          ],
        ),
        subtitle: Row(
          children:[
            Text(
              location,
              style: TextStyle(
                fontSize: 12,
              )),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              whenMade,
              style:  TextStyle(
                fontSize: 12
                )
              ),
            SizedBox(
              height: 30,
              child: TextButton(
                onPressed: onBtnPressed, //TODO: nav to incident details page
                style: TextButton.styleFrom(
                  fixedSize: Size(85, 60),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor: inProg ? Colors.yellow[400] : Colors.red[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: const
                    BorderRadius.all(Radius.circular(8)),
                    side:
                      BorderSide(
                        color: inProg ? const Color(0xFF3E2723) : const Color(0xFFB71C1C)),
                    ),
                  ),

                child: Text(
                  inProg ? "In Progress" : "Respond",
                  style: TextStyle(
                      fontSize: 12,
                      color: inProg ? Color(0xFF3E2723) : Colors.red[900],
                      fontWeight: FontWeight.bold,
                      )
                    ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}