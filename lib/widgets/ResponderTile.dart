import 'package:flutter/material.dart';


class ResponderTile extends StatelessWidget {
  final String rID;
  final String name;
  final String loc;
  final String dept;
  final bool isActive;

  const ResponderTile({
    super.key,
    required this.rID,
    required this.name,
    required this.loc,
    required this.dept,
    required this.isActive,
  });

/// GETTERS
//to get initials
  String get _initials {
    if (name.isEmpty) return "??";
    List<String> names = name.split(" ");
    if (names.length > 1) {
      return (names[0][0] + names[1][0]).toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  //change colors depending on dept of user
  Color _getDeptColor() {
    switch (dept.toLowerCase()) {
      case 'fire': return Colors.orange;
      case 'police': return Colors.blue;
      case 'medical': return Colors.green;
      case 'gen': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black12, width: 0.5),
      ),
      child: ListTile(
        tileColor: Colors.white,
        leading: CircleAvatar(
          backgroundColor: _getDeptColor().withOpacity(0.2),
          child: Text(
            _initials,
            style: TextStyle(
              color: _getDeptColor(),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rID, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
            Text(loc, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.green.shade300 : Colors.grey.shade400,
                width: 1,
              ),
            ),
            child: Text(
              isActive ? "• ACTIVE" : "• IDLE",
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.green[700] : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ),
    );
  }
}
