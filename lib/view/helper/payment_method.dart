import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/custom_page.dart';
import 'package:afandim/custom_widget/empty_widget.dart';
import 'package:afandim/custom_widget/loading_widget.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:afandim/helper/pref_manager.dart';
import 'package:afandim/view/helper/receipt.dart';
import 'package:flutter/material.dart';

class PaymentMethod extends StatefulWidget {
  final String transactionType;
  final String deliveryTime;
  final String deliveryDate;
  final bool deliveryAsap;
  const PaymentMethod(
      {Key key,
      this.transactionType,
      this.deliveryTime,
      this.deliveryDate,
      this.deliveryAsap = false})
      : super(key: key);

  @override
  _PaymentMethodState createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final _repo = Repository();
  bool isLoading = true;
  List list = [];
  String message;
  String paymentCode;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      isLoading = true;
      list = [];
    });

    Map<String, dynamic> response = await _repo.loadPaymentList({
      "transaction_type": widget.transactionType,
    });
    isLoading = false;
    if (response.containsKey("code") && response["code"] == 1) {
      list = response["details"]["data"];
      paymentCode = list[0]["payment_code"];
    } else {
      message = response["msg"];
    }
    setState(() {});
  }

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      scaffoldKey: _scaffoldKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    lang.api("Payment method"),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  getList(),
                  AlternativeButton(
                    label: lang.api("PAY"),
                    onPressed: isLoading ? null : pay,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pay() async {
    if (paymentCode == "cod") {
      payNow(paymentCode);
//      if("${lang.settings["cod_change_required"]}" == "2"){
//        Navigator.of(context).push(
//          MaterialPageRoute(builder: (context) {
//            return CodForm(
//              transactionType: widget.transactionType,
//              deliveryDate: widget.deliveryDate,
//              deliveryTime: widget.deliveryTime,
//            );
//          }),
//        );
//      }
    } else {
      payNow(paymentCode);
    }
  }

  payNow(paymentCode) async {
    showLoadingDialog();
    Map<String, dynamic> response = await _repo.payNow({
      "delivery_asap": widget.deliveryAsap,
      "sms_order_session": "",
      "order_change": "0",
      "delivery_time": widget.deliveryTime,
      "delivery_date": widget.deliveryDate,
      "payment_provider": paymentCode,
      "transaction_type": widget.transactionType
    });
    Navigator.of(context).pop();
    if (response.containsKey("code") && response["code"] == 1) {
      await PrefManager().remove("active_merchant");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return Receipt(
          message: response["msg"],
          data: response["details"],
        );
      }), ModalRoute.withName("/no_route"));
    } else {
      showError(_scaffoldKey, response["msg"]);
    }
  }

  Widget getList() {
    if (isLoading) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        child: LoadingWidget(
          size: 84.0,
          useLoader: true,
          message: lang.api("loading"),
        ),
      );
    } else {
      if (list.length == 0) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: EmptyWidget(
            size: 128,
            message: message,
          ),
        );
      } else {
        return buildList();
      }
    }
  }

  Widget buildList() {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return Row(
          children: [
            Radio<String>(
              value: "${item["payment_code"]}",
              groupValue: paymentCode,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() {
                  paymentCode = value;
                });
              },
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    paymentCode = "${item["payment_code"]}";
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["payment_name"],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
