class RouteNames {
  RouteNames._();

  static const String login = 'login';
  static const String dashboard = 'dashboard';
  static const String invoices = 'invoices';
  static const String createInvoice = 'create_invoice';
  static const String invoiceDetail = 'invoice_detail';
  static const String clients = 'clients';
  static const String settings = 'settings';
}

class RoutePaths {
  RoutePaths._();

  static const String login = '/login';
  static const String dashboard = '/';
  static const String invoices = '/invoices';
  static const String createInvoice = 'create';
  static const String invoiceDetail = 'detail/:id';
  static const String clients = '/clients';
  static const String settings = '/settings';
}
