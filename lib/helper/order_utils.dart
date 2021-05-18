import 'package:flutter/material.dart';

import 'global_translations.dart';

enum OrderOptions {
  viewOrder,
  reOrder,
  addReview,
  cancelOrder,
  trackOrder,
  chat
}
enum NotificationOptions { delete, cancel }

showError(scaffoldKey, msg) {
  scaffoldKey.currentState.showSnackBar(
    SnackBar(
      content: Text(msg, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.black87,
    ),
  );
}

Future showOrderOptions(
    BuildContext context, Map orderData, String code) async {
  var result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height / 2,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  "${lang.api("What do you want to do")}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                height: 2,
                color: Colors.grey,
              ),
              getClickable(
                  context, lang.api("View Order"), OrderOptions.viewOrder),
              getClickable(context, lang.api("Re-Order"), OrderOptions.reOrder),
              orderData["add_review"]
                  ? getClickable(
                      context, lang.api("Add Review"), OrderOptions.addReview)
                  : Container(),
              orderData["add_cancel"]
                  ? getClickable(context, lang.api("Cancel Order"),
                      OrderOptions.cancelOrder)
                  : Container(),
              orderData["add_track"]
                  ? getClickable(
                      context, lang.api("Track Order"), OrderOptions.trackOrder)
                  : Container(),
              getClickable(context, lang.api("Chat with Merchant"),
                      OrderOptions.chat)
            ],
          ),
        ),
      );
    },
  );
  return result;
}

Future showNotificationOptions(BuildContext context) async {
  var result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height / 2,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  "${lang.api("What do you want to do")}?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                height: 2,
                color: Colors.grey,
              ),
              getClickable(context, lang.api("Delete this records?"),
                  NotificationOptions.delete),
              getClickable(
                  context, lang.api("Cancel"), NotificationOptions.cancel),
            ],
          ),
        ),
      );
    },
  );
  return result;
}

Widget getClickable(BuildContext context, String label, option) {
  return InkWell(
    onTap: () {
      Navigator.of(context).pop(option);
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      child: Text(
        label,
      ),
    ),
  );
}
