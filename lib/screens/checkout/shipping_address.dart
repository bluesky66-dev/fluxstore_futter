import 'dart:io' show Platform;

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../generated/i18n.dart';
import '../../models/address.dart';
import '../../models/cart.dart';
import '../../widgets/place_picker.dart';

class ShippingAddress extends StatefulWidget {
  final Function onNext;

  ShippingAddress({this.onNext});

  @override
  _ShippingAddressState createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _streetController = TextEditingController();
  TextEditingController _zipController = TextEditingController();
  TextEditingController _stateController = TextEditingController();

  Address address;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () {
        if (Provider.of<CartModel>(context).address != null) {
          setState(() {
            address = Provider.of<CartModel>(context).address;

            _cityController.text = address.city;
            _streetController.text = address.street;
            _zipController.text = address.zipCode;
            _stateController.text = address.state;
          });
        } else {
          setState(() {
            address = Address();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return address == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                        initialValue: address.firstName,
                        decoration: InputDecoration(labelText: S.of(context).firstName),
                        validator: (val) {
                          return val.isEmpty ? S.of(context).firstNameIsRequired : null;
                        },
                        onSaved: (String value) {
                          address.firstName = value;
                        }),
                    TextFormField(
                        initialValue: address.lastName,
                        validator: (val) {
                          return val.isEmpty ? S.of(context).lastNameIsRequired : null;
                        },
                        decoration: InputDecoration(labelText: S.of(context).lastName),
                        onSaved: (String value) {
                          address.lastName = value;
                        }),
                    TextFormField(
                        initialValue: address.phoneNumber,
                        validator: (val) {
                          return val.isEmpty ? S.of(context).phoneIsRequired : null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: S.of(context).phoneNumber),
                        onSaved: (String value) {
                          address.phoneNumber = value;
                        }),
                    TextFormField(
                        initialValue: address.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: S.of(context).email),
                        validator: (val) {
                          if (val.isEmpty) {
                            return S.of(context).emailIsRequired;
                          }
                          return Validator.validateEmail(val);
                        },
                        onSaved: (String value) {
                          address.email = value;
                        }),
                    SizedBox(
                      height: 10.0,
                    ),
                    if (kGoogleAPIKey.isNotEmpty)
                      Row(children: [
                        Expanded(
                          child: ButtonTheme(
                            height: 60,
                            child: RaisedButton(
                              elevation: 0.0,
                              onPressed: () async {
                                LocationResult result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PlacePicker(
                                      Platform.isIOS
                                          ? kGoogleAPIKey['ios']
                                          : kGoogleAPIKey['android'],
                                    ),
                                  ),
                                );

                                if (result != null) {
                                  address.country = result.country;
                                  address.street = result.street;
                                  address.state = result.state;
                                  address.city = result.city;
                                  address.zipCode = result.zip;

                                  setState(() {
                                    _cityController.text = result.city;
                                    _stateController.text = result.state;
                                    _streetController.text = result.street;
                                    _zipController.text = result.zip;
                                  });
                                }

                              },
                              textColor: Theme.of(context).accentColor,
                              color: Theme.of(context).primaryColorLight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.searchLocation,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10.0),
                                  Text(S.of(context).searchingAddress.toUpperCase()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    GestureDetector(
                      onTap: _openCountryPickerDialog,
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: address.country != null
                                    ? Text(
                                        CountryPickerUtils.getCountryByIsoCode(address.country)
                                            .name,
                                        style: TextStyle(fontSize: 17.0))
                                    : Text(S.of(context).country),
                              ),
                              Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: kGrey900,
                        )
                      ]),
                    ),
                    TextFormField(
                      controller: _stateController,
                      validator: (val) {
                        return val.isEmpty ? S.of(context).streetIsRequired : null;
                      },
                      decoration: InputDecoration(labelText: S.of(context).stateProvince),
                      onSaved: (String value) {
                        address.state = value;
                      },
                    ),
                    TextFormField(
                      controller: _cityController,
                      validator: (val) {
                        return val.isEmpty ? S.of(context).cityIsRequired : null;
                      },
                      decoration: InputDecoration(labelText: S.of(context).city),
                      onSaved: (String value) {
                        address.city = value;
                      },
                    ),
                    TextFormField(
                        controller: _streetController,
                        validator: (val) {
                          return val.isEmpty ? S.of(context).streetIsRequired : null;
                        },
                        decoration: InputDecoration(labelText: S.of(context).streetName),
                        onSaved: (String value) {
                          address.street = value;
                        }),
                    TextFormField(
                        controller: _zipController,
                        validator: (val) {
                          return val.isEmpty ? S.of(context).zipCodeIsRequired : null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: S.of(context).zipCode),
                        onSaved: (String value) {
                          address.zipCode = value;
                        }),
                    SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 45,
                          child: RaisedButton(
                            elevation: 0.0,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();
                                Provider.of<CartModel>(context).setAddress(address);
                                widget.onNext();
                              }
                            },
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            child: Text(S.of(context).continueToShipping.toUpperCase()),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              )
            ],
          );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: Container(
              height: 500,
              child: CountryPickerDialog(
                  titlePadding: EdgeInsets.all(8.0),
                  contentPadding: EdgeInsets.all(2.0),
                  searchCursorColor: Colors.pinkAccent,
                  searchInputDecoration: InputDecoration(hintText: 'Search...'),
                  isSearchable: true,
                  title: Text(S.of(context).country),
                  onValuePicked: (Country country) =>
                      setState(() => address.country = country.isoCode),
                  itemBuilder: (country) {
                    return Row(
                      children: <Widget>[
                        CountryPickerUtils.getDefaultFlagImage(country),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(child: Text("${country.name}")),
                      ],
                    );
                  }),
            )),
      );
}
