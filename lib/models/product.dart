class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  bool isSelected = false;

  Product({this.id, this.name, this.imageUrl, this.price});
}

List<Product> getListItems() {
  var items = List<Product>();
  items.add(Product(
      id: 1,
      name: "Laptop",
      imageUrl: "images/items/item-1-3x.png",
      price: 50000,
   ));

  items.add(Product(
      id: 2,
      name: "Hạt Đậu",
      imageUrl: "images/items/item-2-3x.png",
      price: 80000));

  items.add(Product(
      name: "Coffee",
      imageUrl: "images/items/item-3-3x.png",
      price: 100000));

  items.add(Product(
      name: "Nhà Cửa",
      imageUrl: "images/items/item-4-3x.png",
      price: 120000));

  items.add(Product(
      name: "Heo Vàng",
      imageUrl: "images/items/item-5-3x.png",
      price: 200000));

  items.add(Product(
      name: "Áo Quần",
      imageUrl: "images/items/item-6-3x.png",
      price: 1000000));
  return items;
}
