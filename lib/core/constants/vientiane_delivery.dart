/// Delivery zone: Vientiane Capital only.
class VientianeDelivery {
  VientianeDelivery._();

  static const provinceName = 'ນະຄອນຫຼວງວຽງຈັນ';
  static const centerLat = 17.9757;
  static const centerLng = 102.6331;
  static const minLat = 17.85;
  static const maxLat = 18.25;
  static const minLng = 102.45;
  static const maxLng = 102.85;

  static bool contains(double lat, double lng) =>
      lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
}
