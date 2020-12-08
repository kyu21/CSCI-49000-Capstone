import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Screens/Conversations/screen_messages.dart';

class Convos extends StatefulWidget {
// VARIABLES ===================================================================
  final recipientName;
  final senderName;
  final convoId;
// =============================================================================
// FUNCTIONS ===================================================================

  Convos(this.recipientName, this.senderName, this.convoId);

  @override
  _ConvosState createState() => _ConvosState();
}

class _ConvosState extends State<Convos> {
// VARIABLES ===================================================================

// =============================================================================
// FUNCTIONS ===================================================================

  void showMessages(var chattingWith) async {
    if (this.mounted) {
      setState(() {
        _loading = true;
      });
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return Messaging(chattingWith, widget.senderName, widget.convoId);
      }),
    );

    if (this.mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

// =============================================================================
// WIDGETS =====================================================================

// =============================================================================
// MAIN ========================================================================

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    // Info
    var chattingWith = widget.recipientName;

    // Providers
    Settings settings = Provider.of<Settings>(context);
    return GestureDetector(
      onTap: () {
        showMessages(chattingWith);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: settings.darkMode ? settings.colorMiddle : Colors.grey,
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
          ),
          width: double.infinity,
          height: 75,
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      width: 210,
                      child: Text(
                        //Left side of the conversation box; the user's name
                        chattingWith,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: settings.darkMode
                              ? settings.colorBackground
                              : Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
