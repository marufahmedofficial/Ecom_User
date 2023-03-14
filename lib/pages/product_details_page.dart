import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../auth/authservice.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class ProductDetailsPage extends StatefulWidget {
  static const String routeName = '/productdetails';

  const ProductDetailsPage({Key? key}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late ProductModel productModel;
  late ProductProvider productProvider;
  String displayUrl = '';
  double userRating = 0.0;

  @override
  void didChangeDependencies() {
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    productModel = ModalRoute.of(context)!.settings.arguments as ProductModel;
    displayUrl = productModel.thumbnailImageUrl;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productModel.productName),
      ),
      body: ListView(
        children: [
          CachedNetworkImage(
            width: double.infinity,
            height: 200,
            imageUrl: displayUrl,
            placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      displayUrl = productModel.thumbnailImageUrl;
                    });
                  },
                  child: Card(
                    child: CachedNetworkImage(
                      width: 60,
                      height: 60,
                      imageUrl: productModel.thumbnailImageUrl,
                      placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ),
                ...productModel.additionalImages.map((url) {
                  if (url.isEmpty) {
                    return const SizedBox();
                  }
                  return InkWell(
                    onTap: () {
                      setState(() {
                        displayUrl = url;
                      });
                    },
                    child: Card(
                      child: CachedNetworkImage(
                        width: 60,
                        height: 60,
                        imageUrl: url,
                        placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          ListTile(
            title: Text(productModel.productName),
            subtitle: Text(productModel.category.categoryName),
          ),
          ListTile(
            title: Text(
                'Sale Price: $currencySymbol${calculatePriceAfterDiscount(productModel.salePrice, productModel.productDiscount)}'),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Text('Rate this product'),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: RatingBar.builder(
                      initialRating: 0.0,
                      minRating: 0.0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      ignoreGestures: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        userRating = rating;
                      },
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      if (AuthService.currentUser!.isAnonymous) {
                        showMsg(context, 'Please sign in to rate this product');
                        return;
                      }
                      EasyLoading.show(status: 'Please wait');
                      await productProvider.addRating(productModel.productId!,
                          userRating, context.read<UserProvider>().userModel!);
                      EasyLoading.dismiss();
                      showMsg(context, 'Thanks for your rating');
                    },
                    child: const Text('SUBMIT'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
