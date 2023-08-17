import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/products.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './providers/auth.dart';
import './helpers/custom_routes.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          // ignore: missing_required_param
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (ctx, auth, previousProduct) => Products(
              auth.token,
              auth.userID,
              previousProduct == null ? [] : previousProduct.items,
            ),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          // ignore: missing_required_param
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousOrders) => Orders(
              auth.token,
              auth.userID,
              previousOrders == null ? [] : previousOrders.orders,
            ),
          ),
        ],
      child: Consumer<Auth>(
        builder: (ctx, auth , _) =>  MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }
            ),
          ),
          home: auth.isAuth ? ProductsOverviewScreen() : FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx, authResultSnapShot) => authResultSnapShot.connectionState == ConnectionState.waiting ?
            SplashScreen() :
            AuthScreen(),
          ) ,
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      )
    );
  }
}

