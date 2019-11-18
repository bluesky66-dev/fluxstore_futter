import 'package:flutter/material.dart';
import '../../widgets/start_rating.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../common/styles.dart';
import '../../common/constants.dart';
import '../../generated/i18n.dart';
import '../../models/review.dart';
import '../../services/index.dart';

class Reviews extends StatelessWidget {
  final services = Services();

  final int productId;

  Reviews(this.productId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: services.getReviews(productId),
      builder: (BuildContext context, AsyncSnapshot<List<Review>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container(
              height: 100,
              child: kLoadingWidget(context)
            );
          case ConnectionState.done:
          default:
            if (snapshot.hasError) {
              return Container(
                height: 100,
                child: Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: kErrorRed),
                  ),
                ),
              );
            } else if (snapshot.data.length == 0) {
              return Container(
                height: 100,
                child: Center(
                  child: Text(S.of(context).noReviews),
                ),
              );
            } else {
              return Column(
                children: <Widget>[
                  for (var i = 0; i < snapshot.data.length; i++)
                    renderItem(context, snapshot.data[i])
                ],
              );
            }
        }
      },
    );
  }

  Widget renderItem(context, Review review) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: kGrey200, width: 1.0),
          color: Colors.grey.withAlpha(20),
          borderRadius: BorderRadius.circular(2.0)),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(review.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(review.review, style: TextStyle(color: kGrey600, fontSize: 14)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(timeago.format(review.createdAt),
                    style: TextStyle(color: kGrey400, fontSize: 13)),
                SmoothStarRating(
                    allowHalfRating: true,
                    starCount: 5,
                    rating: review.rating,
                    size: 12.0,
                    color: theme.primaryColor,
                    borderColor: theme.primaryColor,
                    spacing: 0.0),
              ],
            )
          ],
        ),
      ),
    );
  }
}
