import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactUsCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ContactUsCard({Key key, this.imagePath, this.label, this.color, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(Radius.circular(1000))),
              padding: EdgeInsets.all(8),
              child: imagePath.endsWith(".svg")? SvgPicture.asset(
                imagePath,
                width: 24,
              ): Image(
                image: AssetImage(imagePath),
                width: 24,
                height: 24,
              ),
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
