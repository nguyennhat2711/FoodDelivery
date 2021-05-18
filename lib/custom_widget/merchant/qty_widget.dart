import 'package:flutter/material.dart';

enum QtyDirection { horizontal, vertical }

class QtyWidget extends StatefulWidget {
  final String qty;
  final Function(int) onQtyChanged;
  final QtyDirection direction;
  QtyWidget({
    Key key, this.qty, this.onQtyChanged, this.direction = QtyDirection.vertical,
  }) : super(key: key);

  @override
  _QtyWidgetState createState() => _QtyWidgetState();
}

class _QtyWidgetState extends State<QtyWidget> {
  int qty = 0;

  @override
  void initState() {
    qty = int.parse(widget.qty);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getCountWidget();
  }

  Widget getCountWidget(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: widget.direction == QtyDirection.vertical ? Column(
        children: getChildren(),
      ) : Row(
        children: getChildren(),
      ),
    );
  }

  List<Widget> getChildren(){
    return [
      InkWell(
        onTap: (){
          setState(() {
            qty++;
          });
          if(widget.onQtyChanged != null){
            widget.onQtyChanged(("$qty" == widget.qty)? null: qty);
          }
        },
        child: Container(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.add),
        ),
      ),
      Text(
        "$qty",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      InkWell(
        onTap: qty > 1? (){
          setState(() {
            qty--;
          });
          if(widget.onQtyChanged != null){
            widget.onQtyChanged(("$qty" == widget.qty)? null: qty);
          }
        }: null,
        child: Container(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.remove),
        ),
      ),
    ];
  }

}
