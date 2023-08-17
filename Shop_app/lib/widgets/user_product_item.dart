import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/edit_product_screen.dart';
import '../providers/products.dart';
class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id,this.title,this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final colorContext = Theme.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          imageUrl,
        ),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
              ),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: id);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
              ),
              color: Theme.of(context).errorColor,
              onPressed: () async {
                final flag = await showDialog(
                  context: context,
                  builder: (ctx) =>
                      AlertDialog(
                        title: Text('Are you sure?'),
                        content: Text('Do you want to remove this product'),
                        elevation: 20,
                        actions: [
                          FlatButton(
                            child: Text('NO'),
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text('YES'),
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            },
                          ),
                        ],
                      ),
                );
                if (flag) {
                  try {
                    await Provider.of<Products>(context, listen: false).deleteProduct(id);
                  } catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Deleting product failed!',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: colorContext.primaryColor,
                        elevation: 10,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}
