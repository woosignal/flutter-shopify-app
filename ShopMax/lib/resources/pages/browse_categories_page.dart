import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal_shopify_api/models/response/collection_item_response.dart';
import 'package:woosignal_shopify_api/models/response/product_search.dart';
import 'package:woosignal_shopify_api/models/response/products_by_collection_id_response.dart';
import '/resources/widgets/woosignal_ui.dart';

class BrowseCategoriesPage extends NyStatefulWidget {
  static const path = '/browse-categories';

  BrowseCategoriesPage() : super(path, child: _BrowseCategoriesPageState());
}

class _BrowseCategoriesPageState extends NyState<BrowseCategoriesPage> {
  Collections? _collection;
  bool hasNextPage = true;
  String? cursor;

  @override
  init() async {
    _collection = data() as Collections;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_collection?.title ?? "")),
      body: SafeAreaWidget(
        child: NyPullToRefresh.grid(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
          child: (context, product) {
            product as ProductSearch;
            return ProductItem.fromShopifyProductSearch(product);
          },
          data: (int iteration) async {
            if (hasNextPage == false) return [];
            ProductsByCollectionIdResponse? productsByCollectionIdResponse =
                await appWooSignalShopify((api) =>
                    api.getProductsByCollectionId(
                        id: _collection?.id, after: cursor, first: 50));
            cursor = productsByCollectionIdResponse?.pageInfo?.endCursor;
            if (productsByCollectionIdResponse?.pageInfo?.hasNextPage != true) {
              hasNextPage = false;
            }
            return productsByCollectionIdResponse?.products ?? [];
          },
          beforeRefresh: () {
            cursor = null;
            hasNextPage = true;
          },
        ),
      ),
    );
  }
}
