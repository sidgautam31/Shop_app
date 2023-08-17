import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import 'package:shop/providers/product.dart';
import '../screens/product_detail_screen.dart';
import '../providers/auth.dart';
class ProductItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context,listen: false);
    final cart = Provider.of<Cart>(context,listen: false);
    final authData = Provider.of<Auth>(context,listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(placeholder: AssetImage('assets/images/product-placeholder.png'),image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          )
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              color: Theme.of(context).accentColor,
              icon : Icon(
                product.isFavourite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                product.toggleFavouriteStatus(authData.token,authData.userID);
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Item added to cart!',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 10,
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: Theme.of(context).accentColor,
                      onPressed: () => cart.removeSingleItem(product.id),
                    ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
