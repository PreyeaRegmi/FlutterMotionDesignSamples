import 'package:flutter/material.dart';
import 'package:flutter_motion_design_samples/logininteraction/login_interaction_ui.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: LoginInteractionScreen(
          size.height,
          size.width,
          (context) => Container(child: _getLoginForm()),
          (context) => Container(child: _getRegisterForm())),
    );
  }

  Widget _getLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 24,
                color: Colors.grey[400],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[400]),
                          hintText: "Email",
                          fillColor: Colors.white70),
                    ),
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(15.0)),
                        color: Colors.grey[200]),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 24,
                color: Colors.grey[400],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[400]),
                          hintText: "Password",
                          fillColor: Colors.white70),
                    ),
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(15.0)),
                        color: Colors.grey[200]),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(children: [
            Align(
              alignment:Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,0,32,32),
                child: FloatingActionButton(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.arrow_forward_outlined),
                  onPressed: () {},
                ),
              ),
            )
          ]),
        )
      ],
    );
  }

  Widget _getRegisterForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 24,
                color: Colors.grey[400],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[400]),
                          hintText: "Fullname",
                          fillColor: Colors.white70),
                    ),
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(15.0)),
                        color: Colors.grey[200]),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 24,
                color: Colors.grey[400],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[400]),
                          hintText: "Email",
                          fillColor: Colors.white70),
                    ),
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(15.0)),
                        color: Colors.grey[200]),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 24,
                color: Colors.grey[400],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[400]),
                          hintText: "Password",
                          fillColor: Colors.white70),
                    ),
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(15.0)),
                        color: Colors.grey[200]),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(children: [
            Align(
              alignment:Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,0,32,32),
                child: FloatingActionButton(
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.arrow_forward_outlined),
                  onPressed: () {},
                ),
              ),
            )
          ]),
        )
      ],
    );
  }
}
