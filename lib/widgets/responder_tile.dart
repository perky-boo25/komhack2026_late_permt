import 'package:flutter/material.dart';

class ResponderTile extends StatelessWidget {
  final String rID;
  final String name;
  final String loc;
  final String dept;
  final bool isActive;
  final bool canDelete;
  final String? creatorResponderId;
  final VoidCallback? onDelete;
  
  final bool isAdmin;

  const ResponderTile({
    super.key,
    required this.rID,
    required this.name,
    required this.loc,
    required this.dept,
    required this.isActive,
    this.isAdmin = false,
    this.canDelete = false, //default
    this.creatorResponderId,
    this.onDelete,
  });

  String get _initials {
    if (name.isEmpty) return "??";
    List<String> names = name.split(" ");
    if (names.length > 1) {
      return (names[0][0] + names[1][0]).toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        tileColor: Colors.transparent,
        leading: CircleAvatar(
          backgroundColor: _getDeptColor().withValues(alpha:0.2),
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
            //  ADMIN LINE
            const SizedBox(height: 2),
            if (isAdmin && creatorResponderId != null) ...[
              const SizedBox(height: 2),
              Text(
                'Admin: $creatorResponderId',
                style: TextStyle(
                  fontSize: 11,
                  color: canDelete ? Colors.grey.shade500 : Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // status badge
            Container(
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

            if (isAdmin) ...[
              const SizedBox(width: 8),
              if (canDelete)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: onDelete,
                )
              else
                Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}