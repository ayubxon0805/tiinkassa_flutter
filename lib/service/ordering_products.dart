import 'package:flutter/material.dart';

import 'package:tiinkassa_flutter/Hive/hive_instance_class.dart';
import 'package:tiinkassa_flutter/model/category/category_model.dart';
import 'package:tiinkassa_flutter/model/mainbox/mainbox_model.dart';
import 'package:tiinkassa_flutter/model/totalproduct/totalproduct_model.dart';
import 'package:tiinkassa_flutter/model/view_model.dart';

FocusNode myFocusNode = FocusNode();

List<TotalProduct> totalProduct = HiveBoxes.totalPriceBox.values.toList();

CategoryForSale catModel = CategoryForSale();
List<MainBoxModel> mainBox = <MainBoxModel>[];
TotalProduct sale = TotalProduct();
TotalProduct product = TotalProduct();
TotalProduct products = TotalProduct();

class OrderedSingelton {
  OrderedSingelton._();
  static Future<void> getAllProducts() async {
    List<CategoryForSale> ss = await ProductsViewProvider().getAllProducts();
    for (var iteam in ss) {
      if (iteam.barcode.toString() != '') {
        HiveBoxes.prefsBox.put(iteam.barcode.toString(), iteam);
      }
    }
  }

  static Future<bool> addProduct({
    required String name,
    required String barcode,
    required num productPrice,
    required int qcounter,
    required int sku,
  }) async {
    product = TotalProduct(
      name: name,
      barcode: barcode,
      quantity: 1,
      sku: sku,
      price: productPrice,
      category: "",
    );

    MainBoxModel? mm =
        HiveBoxes.mainBox.get(product.barcode, defaultValue: null);
    if (mm == null) {
      product.sku = OrderedSingelton.getLastSku();
    } else {
      product.sku = mm.sku;
      product.quantity = 0;
      TotalProduct? checkedProduct =
          HiveBoxes.totalPriceBox.get(product.barcode, defaultValue: null);
      checkedProduct != null
          ? product.quantity = checkedProduct.quantity! + 1
          : product.quantity = product.quantity! + 1;
    }
    return await HiveBoxes.totalPriceBox
        .put(product.barcode.toString(), product)
        .then((value) => true);
  }

  //int get LSKUR(){}
  static int getLastSku() {
    int a;
    a = HiveBoxes.lastSku.get('detectSku', defaultValue: 0) ?? 0;
    int b = a;
    b++;
    HiveBoxes.lastSku.put('detectSku', b);
    return a;
  }

  static bool addmyBox() {
    List<TotalProduct> totalproduct = HiveBoxes.totalPriceBox.values.toList();
    List<MainBoxModel> setToMainBox = [];
    // ignore: avoid_function_literals_in_foreach_calls
    totalproduct.forEach((element) {
      MainBoxModel mainBox = MainBoxModel(
        name: element.name,
        barcode: element.barcode,
        price: element.price,
        sku: element.sku,
        quantity: element.quantity,
      );
      setToMainBox.add(mainBox);
    });
    Map<dynamic, MainBoxModel> map = {};
    for (var m in setToMainBox) {
      map[m.key] = m;
    }
    HiveBoxes.mainBox.putAll(map);
    return true;
  }
}
