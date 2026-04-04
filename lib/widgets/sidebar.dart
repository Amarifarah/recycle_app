import 'package:flutter/material.dart';
class SideBar extends StatefulWidget {
  final ValueChanged<String> onItemSelected;
  final String selectedPage;

  const SideBar({
    super.key,
    required this.onItemSelected,
    required this.selectedPage,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 230,
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: Column(
        children: [
          // ---- LOGO + Bouton collapse ----
          Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!isCollapsed)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "EcoVision",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  isCollapsed ? Icons.arrow_right : Icons.arrow_left,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => isCollapsed = !isCollapsed),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---- MENU ITEMS ----
          buildItem(Icons.dashboard, "dashboard"),
          buildItem(Icons.precision_manufacturing, "machines"),
          buildItem(Icons.person, "clients"),
          buildItem(Icons.analytics, "analytics"),
          buildItem(Icons.settings, "settings"),

          const Spacer(),

          buildItem(Icons.logout, "logout", isLogout: true),
        ],
      ),
    );
  }

  Widget buildItem(IconData icon, String page, {bool isLogout = false}) {
    bool selected = widget.selectedPage == page;

    return InkWell(
      onTap: () => widget.onItemSelected(page),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.redAccent : Colors.white,
              size: 26,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 12),
              Text(
                page[0].toUpperCase() + page.substring(1),
                style: TextStyle(
                  fontSize: 16,
                  color: isLogout ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
