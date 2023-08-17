import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../providers/products.dart';
enum FilterOptions{
  AllProducts,
  Favourites,
}
class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavourites = false;
    var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    /*
        Provider.of<Products>(context).fetchAndSetProducts();

        This method won't work because initState doesn't work with of context statements,
        it would work however if we set listen to false;
    */

    // below is an alternative approach but it is more like a HACK !!, avoid using it;

    /*
        Future.delayed(Duration.zero).then((_) {
        Provider.of<Products>(context).fetchAndSetProducts();
    });

       we will not use this because it is a hack basically.
       Instead we will use didChangeDependencies as we did earlier when we wanted to
       use initState with context
    */

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(_isInit){
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = !_isInit;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop!'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue){
              setState(() {
                if(_showOnlyFavourites){
                  _showOnlyFavourites = false;
                }else{
                  _showOnlyFavourites = true;
                }
              });

            },
            icon: Icon(Icons.more_vert_sharp),
            itemBuilder: (_) => [
              PopupMenuItem(child: Text('All Products'), value: FilterOptions.AllProducts,),
              PopupMenuItem(child: Text('Favourites'), value: FilterOptions.Favourites,),
            ],
          ),
          Consumer<Cart>(builder: ( _ , cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      )
        : ProductsGrid(_showOnlyFavourites),
    );
  }
}
