import 'package:flutter/material.dart';

class AboutCart extends StatelessWidget {

  final String text;
  final String value;
  final VoidCallback onTap;

  const AboutCart({Key key, this.text, this.value, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
