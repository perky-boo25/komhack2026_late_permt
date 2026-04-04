import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // true = resident, false = responder
  bool isResidentSelected = true;

  void onContinuePressed() {
    if (isResidentSelected) {
      // go to location picker when ready
      // Navigator.pushNamed(context, '/location-picker');

      // TO BE REMOVED/ temporary placeholder
      Navigator.pushNamed(context, '/home');
      return;
    } else {
      // go to responder login when ready
      Navigator.pushNamed(context, '/responder-dashboard');// para laang ni mag dirtso sa dashboard
      // change to log in when ready na

      // TO BE REMOVED/ temporary placeholder
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('going to responder login...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                const LogoWidget(),

                const SizedBox(height: 16),

                // app name
                const Text(
                  'App Name',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                // tagline
                const Text(
                  'tagline',
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),

                const SizedBox(height: 56),

                // role prompt
                const Text(
                  'I am a...',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 12),

                // resident option
                GestureDetector(
                  onTap: () => setState(() => isResidentSelected = true),
                  child: RoleOptionTile(
                    label: 'Resident / Local',
                    icon: Icons.person_outline,
                    tileColor: const Color(0xFF7BC67E),
                    isSelected: isResidentSelected,
                  ),
                ),

                const SizedBox(height: 10),

                // responder option
                GestureDetector(
                  onTap: () => setState(() => isResidentSelected = false),
                  child: RoleOptionTile(
                    label: 'Responder',
                    icon: Icons.shield_outlined,
                    tileColor: const Color(0xFF7EC8E3),
                    isSelected: !isResidentSelected,
                  ),
                ),

                const SizedBox(height: 24),

                // continue button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onContinuePressed,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      isResidentSelected
                          ? 'press to continue as resident'
                          : 'press to continue as responder',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// logo widget
// replace with real image when ready
class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset(
          'images/placeholder.jpg',
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// role option tile
// reusable card for role selection
class RoleOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tileColor;
  final bool isSelected;

  const RoleOptionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.tileColor,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? tileColor.withOpacity(0.35)
            : tileColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? tileColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tileColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
