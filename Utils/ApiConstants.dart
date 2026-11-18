class ApiConstants {
  static const String baseUrl = 'https://jivit-api.volvrit.org';

  // Socket.io server (live delivery tracking).
  // NOTE: confirm host/port with the backend dev. The integration guide shows a
  // local dev address (http://192.168.1.72:5001); in production the socket
  // server is assumed to sit on the same host as the REST API (443/https).
  static const String socketUrl = baseUrl;

  // Franchise Auth
  static const String franchiseLogin = '$baseUrl/api/franchise/auth/login';
  static const String franchiseRefreshToken = '$baseUrl/api/franchise/auth/refresh-token';

  // Rider Auth
  static const String riderLogin = '$baseUrl/api/delivery-agent/auth/login';
  static const String riderRefreshToken = '$baseUrl/api/delivery-agent/auth/refresh-token';

  // Rider Profile
  static const String riderProfile = '$baseUrl/api/delivery-agent/profile';
  static const String riderProfileImage = '$baseUrl/api/delivery-agent/profile/image';

  // Rider Stats
  static const String riderTodayStats = '$baseUrl/api/delivery-agent/orders/stats/today';

  // Rider Orders
  static const String riderTodayOrders = '$baseUrl/api/delivery-agent/orders/today';
  static String riderOrderDetail(String orderId) => '$baseUrl/api/delivery-agent/orders/$orderId';
  static const String riderOrderUpdateStatus = '$baseUrl/api/delivery-agent/orders/status';
  static String riderOrderReject(String orderId) => '$baseUrl/api/delivery-agent/orders/$orderId/reject';

  // Franchise Profile
  static const String franchiseProfile = '$baseUrl/api/franchise/profile';
  static const String franchiseProfilePhoto = '$baseUrl/api/franchise/profile/photo';

  // Franchise Zone Management
  static const String franchiseZoneCities = '$baseUrl/api/franchise/zone-management/cities';
  static String franchiseZoneRiders(String zone) => '$baseUrl/api/franchise/zone-management/zones/$zone/riders';

  // Franchise Delivery Agent
  static const String franchiseDeliveryAgent = '$baseUrl/api/franchise/delivery-agent';
  static String franchiseDeliveryAgentToggle(String id) => '$baseUrl/api/franchise/delivery-agent/$id/toggle-status';
  static const String franchiseDeliveryAgentLive = '$baseUrl/api/franchise/delivery-agent/live';
  static const String franchiseTodayOrders = '$baseUrl/api/franchise/delivery-agent/today-orders';
  static String franchiseTodayOrderDetail(String orderId) =>
      '$baseUrl/api/franchise/delivery-agent/today-orders/$orderId';

  // Franchise Order List / Detail
  static const String franchiseOrderList = '$baseUrl/api/franchise/order/list';
  static String franchiseOrderDetail(String id) => '$baseUrl/api/franchise/order/$id/detail';
  static const String franchiseOrderUpdateStatus = '$baseUrl/api/franchise/order/update-status';

  // Franchise Delivery Order Actions
  static String franchiseOrderReassign(String orderId) =>
      '$baseUrl/api/franchise/delivery-agent/orders/$orderId/reassign';
  static String franchiseOrderCodCollected(String orderId) =>
      '$baseUrl/api/franchise/delivery-agent/orders/$orderId/cod-collected';

  // Franchise Plans
  static const String franchisePlans = '$baseUrl/api/franchise/delivery-agent/plans';

  // Franchise Customers
  static const String franchiseCustomers = '$baseUrl/api/franchise/customers';
  static String franchiseCustomerDeliveryHistory(String customerId) =>
      '$baseUrl/api/franchise/customers/$customerId/delivery-history';

  // Franchise Customer Notes
  static const String franchiseCustomerNotes = '$baseUrl/api/franchise/customer-notes';
  static String franchiseCustomerNote(String customerId) =>
      '$baseUrl/api/franchise/customer-notes/$customerId';

  // Legal
  static String legalContent(String type) => '$baseUrl/api/legal/$type';

  // Franchise Inventory
  static const String franchiseInventory = '$baseUrl/api/franchise/inventory';

  // Franchise COD
  static const String franchiseCodOrders = '$baseUrl/api/franchise/cod-orders';

  // Franchise Bank
  static const String franchiseBank = '$baseUrl/api/franchise/bank';
  static const String franchiseDashboardStats = '$baseUrl/api/franchise/dashboard/stats';
  static const String franchiseDeliveryStats = '$baseUrl/api/franchise/delivery/stats';
}
