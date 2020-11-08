import 'package:flutter/material.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/Screens/MainPages/Posts/screen_owner.dart';
import 'package:provider/provider.dart';

class Users extends StatelessWidget {
  final info;
  Users(this.info);

  @override
  Widget build(BuildContext context) {
    final String firstName = info['first'];
    final String lastName = info['last'];
    final String phone = info['phone'];
    final String email = info['email'];

    final settings = Provider.of<Settings>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ScreenOwner(info['id']);
          }));
        },
        child: Container(
          height: 75,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Name
                Text(
                  firstName + ' ' + lastName,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: settings.darkMode ? Colors.white : Colors.black,
                  ),
                ),

                // Address/
                SizedBox(width: 20),
                Expanded(
                  child: Container(
                    child: FittedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 7),

                          // Email
                          Text(
                            'Email: ' + email,
                            style: TextStyle(
                              fontSize: 20,
                              color: settings.darkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),

                          // Phone
                          Text(
                            'Phone: ' + phone,
                            style: TextStyle(
                              fontSize: 20,
                              color: settings.darkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
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
