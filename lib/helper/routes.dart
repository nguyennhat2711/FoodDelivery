import 'package:afandim/view/become_partner/become_partner.dart';
import 'package:afandim/view/become_partner/register_delivery.dart';
import 'package:afandim/view/country_picker.dart';
import 'package:afandim/view/profile/address_directory/list.dart';
import 'package:afandim/view/profile/bookings_history.dart';
import 'package:afandim/view/profile/contact_us_view.dart';
import 'package:afandim/view/profile/credit_cards/add.dart';
import 'package:afandim/view/profile/credit_cards/list.dart';
import 'package:afandim/view/profile/edit_profile.dart';
import 'package:afandim/view/profile/favorite.dart';
import 'package:afandim/view/profile/message_us_view.dart';
import 'package:afandim/view/profile/notifications.dart';
import 'package:afandim/view/profile/orders_history.dart';
import 'package:afandim/view/profile/points/points.dart';
import 'package:afandim/view/profile/settings.dart';
import 'package:afandim/view/splash/splash.dart';
import 'package:afandim/view/update_screen.dart';
import 'package:flutter/material.dart';

const String indexRoute = '/';
const String splashRoute = '/splash';
const String countryServerRoute = '/server_country';

const String editProfileRoute = '/edit_profile';

const String contactUsRoute = '/contact_us';
const String messageUsRoute = '/message_us';
const String registerDeliveryRoute = '/register_delivery';
const String notificationsRoute = '/notifications';
const String ordersHistoryRoute = '/orders_history';
const String bookingsHistoryRoute = '/bookings_history';
const String pointsRoute = '/points';
const String favoriteRoute = '/favorite';
const String creditCardsRoute = '/credit_cards';
const String addCardRoute = '/add_card';
const String addressDirectoryRoute = '/address_directory';
const String settingsRoute = '/settings';
const String partnerRoute = '/partner';

const String chatRoute = '/chat';
const String updateRequired = '/update_req';
const String supportChatRoute = '/support_chat';

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  indexRoute: (BuildContext context) => new Splash(),
  splashRoute: (BuildContext context) => new Splash(),
  countryServerRoute: (BuildContext context) => new CountryPicker(),
  updateRequired: (BuildContext context) => new UpdateScreen(),
  contactUsRoute: (BuildContext context) => new ContactUs(),
  messageUsRoute: (BuildContext context) => new MessageUs(),
  registerDeliveryRoute: (BuildContext context) => new RegisterDelivery(),
  settingsRoute: (BuildContext context) => new Settings(),
  editProfileRoute: (BuildContext context) => new EditProfile(),
  notificationsRoute: (BuildContext context) => new Notifications(),
  ordersHistoryRoute: (BuildContext context) => new OrdersHistory(),
  bookingsHistoryRoute: (BuildContext context) => new BookingsHistory(),
  pointsRoute: (BuildContext context) => new Points(),
  favoriteRoute: (BuildContext context) => new Favorite(),
  creditCardsRoute: (BuildContext context) => new CreditCards(),
  addCardRoute: (BuildContext context) => new AddCard(),
  addressDirectoryRoute: (BuildContext context) => new AddressDirectory(),
  partnerRoute: (BuildContext context) => new BecomePartnerView()
};
