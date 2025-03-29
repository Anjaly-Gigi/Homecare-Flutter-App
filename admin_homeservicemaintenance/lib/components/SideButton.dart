import 'package:flutter/material.dart';


class SideButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const SideButton({super.key, required this.icon, required this.label, this.onTap});

  @override
  _SideButtonState createState() => _SideButtonState();
}

class _SideButtonState extends State<SideButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            color: isHovered ? Color.fromARGB(255, 76, 60, 139).withOpacity(0.8) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: isHovered ? Colors.white : Color.fromARGB(255, 76, 60, 139),
                size: 22,
              ),
              SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: isHovered ? Colors.white :  Color.fromARGB(255, 76, 60, 139),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class SideButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   const SideButton({super.key, required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
      
//         padding: EdgeInsets.all(10),
//         child: Row(
//           children: [
//             Icon(icon),
//             SizedBox(
//               width: 10,
//             ),
//             Text(label,
//                 style: TextStyle(
//                     color: Color(0xFF543A14), fontSize: 15, letterSpacing: 2)),
//           ],
//         ));
//   }
// }
