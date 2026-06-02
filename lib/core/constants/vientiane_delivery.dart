/// Delivery zone: Vientiane Capital only.
class VientianeDelivery {
  VientianeDelivery._();

  static const provinceName = 'ນະຄອນຫຼວງວຽງຈັນ';
  static const centerLat = 17.9757;
  static const centerLng = 102.6331;
  // Slightly wider bounding box to avoid rejecting valid "Vientiane Capital" GPS points
  // on some devices / map providers.
  static const minLat = 17.70;
  static const maxLat = 18.35;
  static const minLng = 102.30;
  static const maxLng = 102.95;

  static bool contains(double lat, double lng) =>
      lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
}
