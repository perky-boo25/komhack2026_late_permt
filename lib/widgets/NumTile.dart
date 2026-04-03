import 'package:flutter/material.dart';

class NumTile extends StatelessWidget {
  final String type;
  final String value;

  const NumTile({super.key, required this.type, required this.value});

  static const Map<String, Map<String, dynamic>> _styles = {
    'SOS': {'color': Colors.red, 'img': AssetImage("assets/sos.png")},
    'Fire': {'color': Colors.orange, 'img': AssetImage("assets/fire.png")},
    'Flood': {'color': Colors.blue, 'img': AssetImage("assets/flood.png")},
    'Medic': {'color': Colors.green, 'img': AssetImage("assets/medic.png")},
    'Other': {'color': Colors.black, 'img': AssetImage("assets/other.png")},
  };

  @override
  Widget build(BuildContext context) {
    final style = _styles[type] ?? _styles['Other']!;
    
    final Color themeColor = style['color'];
    final AssetImage imageAsset = style['img'];

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: themeColor),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageIcon(
                      imageAsset,
                      size: 12,
                      color: themeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
