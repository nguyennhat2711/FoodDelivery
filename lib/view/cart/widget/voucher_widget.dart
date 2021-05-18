import 'package:afandim/core/services/repository.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:flutter/material.dart';

class VoucherWidget extends StatefulWidget {
  final transactionType;
  final scaffoldKey;
  final VoidCallback reloadCart;
  const VoucherWidget(
      {Key key, this.transactionType, this.scaffoldKey, this.reloadCart})
      : super(key: key);

  @override
  _VoucherWidgetState createState() => _VoucherWidgetState();
}

class _VoucherWidgetState extends State<VoucherWidget> {
  final _controller = TextEditingController();
  final _repo = Repository();

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            lang.api("Do you have a voucher?"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TextFormField(
                        controller: _controller,
                        onChanged: (text) {},
                        onFieldSubmitted: (text) {},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: lang.api("Enter voucher here"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    onPressed: () async {
                      showLoadingDialog(lang.api("loading"));
                      Map<String, dynamic> response = await _repo.applyVoucher({
                        "transaction_type": widget.transactionType["key"],
                        "voucher_name": _controller.text,
                      });
                      Navigator.of(context).pop();
                      if (response.containsKey("code") &&
                          response["code"] == 1) {
                        widget.reloadCart();
                      } else {
                        showError(widget.scaffoldKey, response["msg"]);
                      }
                    },
                    child: Text(
                      lang.api("Apply"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
