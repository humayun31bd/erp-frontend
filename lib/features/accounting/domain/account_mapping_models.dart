import 'package:erp_frontend/features/accounting/domain/accounting_models.dart';

class AccountMapping {
  final String? id;
  final String moduleKey;
  final String mappingKey;
  final String accountId;
  final Account? account;

  AccountMapping({
    this.id,
    required this.moduleKey,
    required this.mappingKey,
    required this.accountId,
    this.account,
  });

  factory AccountMapping.fromJson(Map<String, dynamic> json) {
    return AccountMapping(
      id: json['id'] as String?,
      moduleKey: json['module_key'] as String? ?? json['moduleKey'] as String? ?? '',
      mappingKey: json['mapping_key'] as String? ?? json['mappingKey'] as String? ?? '',
      accountId: json['account_id'] as String? ?? json['accountId'] as String? ?? '',
      account: json['account'] != null ? Account.fromJson(json['account'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'moduleKey': moduleKey,
      'mappingKey': mappingKey,
      'accountId': accountId,
    };
  }
}

class AccountMappingsResponse {
  final bool success;
  final List<AccountMapping> mappings;

  AccountMappingsResponse({required this.success, required this.mappings});

  factory AccountMappingsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['mappings'] as List<dynamic>?) ?? [];
    return AccountMappingsResponse(
      success: json['success'] as bool? ?? true,
      mappings: list.map((e) => AccountMapping.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// System Mapping Meta Definitions
class SystemMappingDefinition {
  final String moduleKey;
  final String mappingKey;
  final String label;
  final String description;
  final String requiredType; // ASSET, LIABILITY, REVENUE, EXPENSE, EQUITY
  final String defaultCodeHint;

  const SystemMappingDefinition({
    required this.moduleKey,
    required this.mappingKey,
    required this.label,
    required this.description,
    required this.requiredType,
    required this.defaultCodeHint,
  });
}

const List<SystemMappingDefinition> kSystemMappingDefinitions = [
  // POS & Retail Sales Module
  SystemMappingDefinition(
    moduleKey: 'POS',
    mappingKey: 'POS_CASH',
    label: 'POS Cash Register Account',
    description: 'Receives daily cash collected at checkout counters and POS cash floats.',
    requiredType: 'ASSET',
    defaultCodeHint: '1.10.01',
  ),
  SystemMappingDefinition(
    moduleKey: 'POS',
    mappingKey: 'POS_BANK',
    label: 'POS Card & Merchant Settlement Bank',
    description: 'Receives debit/credit card swipe payments and POS digital merchant settlements.',
    requiredType: 'ASSET',
    defaultCodeHint: '1.10.02',
  ),
  SystemMappingDefinition(
    moduleKey: 'POS',
    mappingKey: 'POS_REVENUE',
    label: 'POS Sales Revenue Account',
    description: 'Credits retail grocery product sales income for every completed POS invoice.',
    requiredType: 'REVENUE',
    defaultCodeHint: '4.10.01',
  ),
  SystemMappingDefinition(
    moduleKey: 'POS',
    mappingKey: 'POS_RECEIVABLE',
    label: 'POS Corporate Customer AR Account',
    description: 'Accounts Receivable control account for credit sales to corporate accounts.',
    requiredType: 'ASSET',
    defaultCodeHint: '1.20.02',
  ),

  // Purchasing & AP Module
  SystemMappingDefinition(
    moduleKey: 'PURCHASE',
    mappingKey: 'PURCHASE_AP',
    label: 'Accounts Payable (AP - Trade Vendors)',
    description: 'Credits wholesale supplier bills and distributor trade accounts payable.',
    requiredType: 'LIABILITY',
    defaultCodeHint: '2.10.01',
  ),
  SystemMappingDefinition(
    moduleKey: 'PURCHASE',
    mappingKey: 'PURCHASE_COGS',
    label: 'Cost of Goods Sold (COGS - Purchases)',
    description: 'Debits cost of stock purchased from agricultural suppliers & wholesalers.',
    requiredType: 'EXPENSE',
    defaultCodeHint: '5.10.01',
  ),

  // Tax & Regulatory Compliance
  SystemMappingDefinition(
    moduleKey: 'TAX',
    mappingKey: 'VAT_PAYABLE',
    label: 'NBR VAT Output / VDS Payable',
    description: 'Holds NBR Bangladesh 7.5%/15% VAT collected and VDS deducted at source.',
    requiredType: 'LIABILITY',
    defaultCodeHint: '2.10.03',
  ),
  SystemMappingDefinition(
    moduleKey: 'TAX',
    mappingKey: 'TDS_PAYABLE',
    label: 'NBR Income Tax TDS Payable (Sec 52)',
    description: 'Holds NBR Bangladesh withholding tax (TDS) deducted from supplier bills.',
    requiredType: 'LIABILITY',
    defaultCodeHint: '2.10.02',
  ),

  // Inventory & Asset Management
  SystemMappingDefinition(
    moduleKey: 'INVENTORY',
    mappingKey: 'INVENTORY_ASSET',
    label: 'Inventory Asset Stock Account',
    description: 'Controls valuation of store inventory (Produce, Frozen, Dry & Packaged goods).',
    requiredType: 'ASSET',
    defaultCodeHint: '1.20.01',
  ),
];
