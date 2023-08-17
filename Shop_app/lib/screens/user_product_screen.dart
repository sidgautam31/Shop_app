import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';
class UserProductsScreen extends StatelessWidget {

  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context,listen: false).fetchAndSetProducts(true);
  }
  @override
  Widget build(BuildContext context) {
    //final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            iconSize: 30,
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapShot) => snapShot.connectionState == ConnectionState.waiting ? Center(
          child: CircularProgressIndicator(),
        ) :  RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Consumer<Products>(
            builder: (ctx, productData, _) => Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: productData.items.length,
                itemBuilder: (ctx,index) => Column(
                  children: [
                    UserProductItem(
                      productData.items[index].id,
                      productData.items[index].title,
                      productData.items[index].imageUrl,
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
