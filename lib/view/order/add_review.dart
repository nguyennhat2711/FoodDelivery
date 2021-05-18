import 'package:afandim/core/services/repository.dart';
import 'package:afandim/custom_widget/alternative_button.dart';
import 'package:afandim/custom_widget/alternative_text_field.dart';
import 'package:afandim/custom_widget/rating_bar.dart';
import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/order_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AddReview extends StatefulWidget {
  final Map orderData;

  AddReview({Key key, this.orderData}) : super(key: key);

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  final _repo = Repository();
  double rating = 0;
  final _controller = TextEditingController();
  bool anonymousReview = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _repo.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(lang.api("Review your order")),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.orderData["logo"],
                  width: 46,
                  height: 46,
                  placeholder: (context, text) {
                    return Image(
                      image: AssetImage("assets/images/logo-placeholder.png"),
                      width: 46,
                      height: 46,
                    );
                  },
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.orderData["merchant_name"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                          "${lang.api("Status")}: ${widget.orderData["status"]}"),
                      Text(
                          "${lang.api("Order ID")}: ${widget.orderData["order_id"]}"),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                height: 2,
                color: Colors.grey,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: RatingBar(
                onChanged: (value) {
                  setState(() {
                    rating = value;
                  });
                },
                size: 54,
                rating: rating,
                numStars: 5,
                isInt: true,
              ),
            ),
            AlternativeTextField(
              controller: _controller,
              hint: lang.api("What do you think of your order?"),
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: anonymousReview,
                  onChanged: (value) {
                    setState(() {
                      anonymousReview = !anonymousReview;
                    });
                  },
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        anonymousReview = !anonymousReview;
                      });
                    },
                    child: Text(
                      lang.api("Review anonymously"),
                    ),
                  ),
                ),
              ],
            ),
            AlternativeButton(
                label: lang.api("Submit"),
                onPressed: () async {
                  if (_controller.text.isEmpty) {
                    showError(
                        _scaffoldKey, lang.api("You have to write a review"));
                  } else {
                    showLoadingDialog();
                    Map<String, dynamic> response = await _repo.addReview({
                      "rating": rating.toInt(),
                      "order_id": widget.orderData["order_id"],
                      "review": _controller.text,
                      "as_anonymous": anonymousReview ? 1 : 0
                    });
                    Navigator.of(context).pop();
                    if (response.containsKey("code") && response["code"] == 1) {
                      Navigator.of(context).pop(true);
                    } else {
                      showError(_scaffoldKey, response["msg"]);
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }
}
