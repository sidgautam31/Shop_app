import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';
class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key key}) : super(key: key);
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  var _init = true;
  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  var _isLoading = false;
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(_init){
      final productId = ModalRoute.of(context).settings.arguments as String;
      if(productId != null){
        _editedProduct = Provider.of<Products>(context,listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          'imageUrl': '', // we cannot initialise here because we are using a controller also.
        };
        _imageUrlController.text = _editedProduct.imageUrl; //we have to do this way
      }
    }
    _init = !_init;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if(!_imageUrlFocusNode.hasFocus){
      if(
      (!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) ||
      (!_imageUrlController.text.endsWith('.png') &&
          !_imageUrlController.text.endsWith('.jpg') &&
          !_imageUrlController.text.endsWith('.jpeg'))
      ){
        return;
      }
      setState(() {});
    }
  }



  Future<void> _saveForm() async {
    var _isValid = _form.currentState.validate();
    if(!_isValid){
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if(_editedProduct.id != null){
      await Provider.of<Products>(context,listen: false).updateProduct(_editedProduct.id,_editedProduct);
    }else{
      try{
        await Provider.of<Products>(context,listen: false).addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred'),
            content: Text('Something went wrong'),
            actions: [
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
      /* finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }*/
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _initValues['title'],
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    icon: Icon(Icons.title),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  validator: (value) {
                    if(value.isEmpty){
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: value,
                      price: _editedProduct.price,
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                    );
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _initValues['price'],
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    icon: Icon(Icons.money),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  validator: (value) {
                    if(value.isEmpty){
                      return 'Please enter the amount';
                    }
                    if(double.tryParse(value) == null){
                      return 'Please enter a valid number';
                    }
                    if(double.parse(value) <=0){
                      return 'Please enter a value greater than zero';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      price: double.parse(value),
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                    );
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _initValues['description'],
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    icon: Icon(Icons.description),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  focusNode: _descriptionFocusNode,
                  validator: (value) {
                    if(value.isEmpty){
                      return 'Please enter a description';
                    }
                    if(value.length < 10){
                      return 'Description must be at least 10 characters long';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      price: _editedProduct.price,
                      description: value,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                    );
                  },
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      margin: EdgeInsets.only(top: 8,right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.purple,
                        ),
                      ),
                      child: _imageUrlController.text.isEmpty ?
                      Center(
                        child: Text(
                          'Enter a URL',
                        ),
                      ) :
                      FittedBox(
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Image URL',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          icon: Icon(Icons.link),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        focusNode: _imageUrlFocusNode,
                        controller: _imageUrlController,
                        onEditingComplete: () {
                          setState(() {});
                        },
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        validator: (value) {
                          if(value.isEmpty){
                            return 'Please enter a Image URL';
                          }
                          if(!value.startsWith('http') && !value.startsWith('https')){
                            return 'Please enter a valid URL';
                          }
                          if(!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')){
                            return 'Please enter a valid url';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: value,
                            id: _editedProduct.id,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
