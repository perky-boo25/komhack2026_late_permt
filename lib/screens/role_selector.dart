// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  static const _red = Colors.red;
  static final _orange = Colors.orange.shade400;
  static const _black = Colors.black;
  static const _white = Colors.white;

  // true = resident, false = responder
  bool isResidentSelected = true;

  void onContinuePressed() {
    if (isResidentSelected) {
      Navigator.pushNamed(context, '/home');
    } else {
      Navigator.pushNamed(context, '/responder-login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                //logo
                const LogoWidget(),

                const SizedBox(height: 16),

                // app name

                const SizedBox(height: 4),

                // tagline
                const Text(
                  'Mabuhay!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 48),

                //  label
                Center(child: Text(
                  'Isa akong ...',
                  style:TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.4,
                  ),
                ),
              ),

                const SizedBox(height: 16),

                // resident picker
                GestureDetector(
                  onTap: () => setState(() => isResidentSelected = true),
                  child: RoleOptionTile(
                    label: 'Residente / Lokal',
                    sublabel: 'Mag-ulat ng mga emergency sa inyong lugar',
                    icon: Icons.person_outline,
                    accentColor: _orange,
                    isSelected: isResidentSelected,
                  ),
                ),

                const SizedBox(height: 10),

                // responder picker
                GestureDetector(
                  onTap: () => setState(() => isResidentSelected = false),
                  child: RoleOptionTile(
                    label: 'Responder',
                    sublabel: 'Umaksyon sa mga emergency',
                    icon: Icons.shield_outlined,
                    accentColor: _red,
                    isSelected: !isResidentSelected,
                  ),
                ),

                const SizedBox(height: 28),

                // continue button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onContinuePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isResidentSelected ? _orange : _red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isResidentSelected
                              ? 'Magpatuloy bilang Residente'
                              : 'Magpatuloy bilang Responder',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward,
                            size: 16, color: _white),
                      ],
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
class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 500,
        height: 180,
        child: Image.asset(
          'images/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


// role option label
class RoleOptionTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;

  const RoleOptionTile({
    super.key,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? accentColor.withOpacity(0.07)
            : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? accentColor : const Color(0xFFE0E0E0),
          width: isSelected ? 2.0 : 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor
                  : accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : accentColor,
            ),
          ),

          const SizedBox(width: 14),

          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 15,
                    color: isSelected
                        ? accentColor.withOpacity(0.8)
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          // Selection indicator
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: Icon(
              Icons.check_circle_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
