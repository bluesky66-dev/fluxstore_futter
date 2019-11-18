import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../common/styles.dart';
import '../common/tools.dart';
import '../generated/i18n.dart';
import '../models/order.dart';
import '../services/index.dart';

class OrderDetail extends StatefulWidget {
  final Order order;
  final VoidCallback onRefresh;

  OrderDetail({this.order, this.onRefresh});

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final services = Services();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(S.of(context).orderNo + " #${widget.order.number}"),
          backgroundColor: kGrey200,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: <Widget>[
              for (var item in widget.order.lineItems)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: Text(item.name)),
                      SizedBox(
                        width: 15,
                      ),
                      Text("x${item.quantity}"),
                      SizedBox(width: 20),
                      Text(Tools.getCurrecyFormatted(item.total),
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
              Container(
                decoration: BoxDecoration(color: kGrey200),
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(S.of(context).subtotal),
                        Text(
                          Tools.getCurrecyFormatted(widget.order.lineItems
                              .fold(0, (sum, e) => sum + double.parse(e.total))),
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(S.of(context).shippingMethod),
                        Text(
                          widget.order.shippingMethodTitle,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(S.of(context).total),
                        Text(
                          Tools.getCurrecyFormatted(widget.order.total),
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    S.of(context).status,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    widget.order.status.toUpperCase(),
                    style: TextStyle(
                        color: kOrderStatusColor[widget.order.status] != null
                            ? HexColor(kOrderStatusColor[widget.order.status])
                            : Colors.black,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
              SizedBox(height: 15),
              Stack(children: <Widget>[
                Container(
                  height: 6,
                  decoration:
                      BoxDecoration(color: kGrey200, borderRadius: BorderRadius.circular(3)),
                ),
                if (widget.order.status == "processing")
                  Container(
                    height: 6,
                    width: 200,
                    decoration: BoxDecoration(
                        color: kOrderStatusColor[widget.order.status] != null
                            ? HexColor(kOrderStatusColor[widget.order.status])
                            : Colors.black,
                        borderRadius: BorderRadius.circular(3)),
                  ),
                if (widget.order.status != "processing")
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                        color: kOrderStatusColor[widget.order.status] != null
                            ? HexColor(kOrderStatusColor[widget.order.status])
                            : Colors.black,
                        borderRadius: BorderRadius.circular(3)),
                  ),
              ]),
              SizedBox(height: 40),
              Text(S.of(context).shippingAddress,
                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if(widget.order.billing != null)
              Text(widget.order.billing.street +
                  ", " +
                  widget.order.billing.city +
                  ", " +
                  getCountryName(widget.order.billing.country)),
              if (widget.order.status == "processing")
                Column(
                  children: <Widget>[
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ButtonTheme(
                            height: 45,
                            child: RaisedButton(
                                textColor: Colors.white,
                                color: HexColor("#056C99"),
                                onPressed: () {
                                  refundOrder();
                                },
                                child: Text(S.of(context).refundRequest.toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.w700))),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                )
            ],
          ),
        ));
  }

  String getCountryName(country) {
    try {
      return CountryPickerUtils.getCountryByIsoCode(country).name;
    } catch (err) {
      return country;
    }
  }

  void refundOrder() async {
    _showLoading();
    try {
      await services.updateOrder(widget.order.id, status: "refunded");
      _hideLoading();
      widget.onRefresh();
      Navigator.of(context).pop();
    } catch (err) {
      _hideLoading();

      final snackBar = SnackBar(
        content: Text(err.toString()),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void _showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new Center(
              child: new Container(
                  decoration: new BoxDecoration(
                      color: Colors.white30, borderRadius: new BorderRadius.circular(5.0)),
                  padding: new EdgeInsets.all(50.0),
                  child: kLoadingWidget(context)));
        });
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }
}
