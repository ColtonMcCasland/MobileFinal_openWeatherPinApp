import 'package:flutter/material.dart';

class ComposeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withOpacity(.1),
      padding: const EdgeInsets.only(right: 16.0, top: 6.0, bottom: 12.0,),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.0),
                border: Border.all(
                  width: 1.0,
                  color: Colors.red,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Write somethinghere ....'),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16.0, left: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.send,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
