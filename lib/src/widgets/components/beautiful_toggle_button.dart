import 'package:flutter/material.dart';

class BeautifulToggleButton extends StatefulWidget {
  final ValueChanged<bool> onTap; // Callback for state change
  final bool initialState; // Initial state (true for ON, false for OFF)
  final IconData onIcon; // Icon for the ON state
  final IconData offIcon; // Icon for the OFF state

  const BeautifulToggleButton({
    required this.onTap,
    this.initialState = false,
    this.onIcon = Icons.power,
    this.offIcon = Icons.power_off,
    Key? key,
  }) : super(key: key);

  @override
  BeautifulToggleButtonState createState() => BeautifulToggleButtonState();
}

class BeautifulToggleButtonState extends State<BeautifulToggleButton>
    with SingleTickerProviderStateMixin {
  late bool isOn;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialState;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (isOn) {
      _controller.value = 1.0; // Start at ON position
    }
  }

  void _toggle() {
    setState(() {
      isOn = !isOn;
      if (isOn) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onTap(isOn); // Notify parent of the state change
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: isOn ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Toggle icon
            Align(
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Icon(
                    isOn ? widget.onIcon : widget.offIcon,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // ON/OFF Label
            Align(
              alignment: Alignment.center,
              child: Text(
                isOn ? "ON" : "OFF",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
