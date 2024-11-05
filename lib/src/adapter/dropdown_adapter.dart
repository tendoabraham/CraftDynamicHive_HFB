part of craft_dynamic;

abstract class IDropDownAdapter {
  factory IDropDownAdapter(FormItem formItem, ModuleItem moduleItem) {
    switch (EnumFormatter.getControlFormat(formItem.controlFormat!)) {
      case ControlFormat.SELECTBANKACCOUNT:
        return _BankAccountDropDown(formItem: formItem);

      case ControlFormat.SELECTBENEFICIARY:
        return _BeneficiaryDropDown(merchantID: moduleItem.merchantID);

      default:
        return _UserCodeDropDown(dataSourceID: formItem.dataSourceId);
    }
  }
  Future<Map<String, dynamic>?>? getDropDownItems();
}

class _UserCodeDropDown implements IDropDownAdapter {
  _UserCodeDropDown({this.dataSourceID});

  String? dataSourceID;
  final _userCodeRepository = UserCodeRepository();

  @override
  Future<Map<String, dynamic>?>? getDropDownItems() async {
    var userCodes = await _userCodeRepository.getUserCodesById(dataSourceID);
    AppLogger.appLogD(
        tag: "dropdown adapter::datasourceid @$dataSourceID",
        message: userCodes);
    return userCodes.fold<Map<String, dynamic>>(
        {}, (acc, curr) => acc..[curr.subCodeId] = curr.description!);
  }
}

class _BankAccountDropDown implements IDropDownAdapter {
  _BankAccountDropDown({required this.formItem});

  final FormItem formItem;
  final _bankAccountRepository = BankAccountRepository();

  @override
  Future<Map<String, dynamic>?>? getDropDownItems() async {
    var bankAccounts = await _bankAccountRepository.getAllBankAccounts();
    bool? isTransactional = formItem.isTransactional;
    AppLogger.appLogD(
        tag: "Is transactional ${formItem.controlText}",
        message: isTransactional);

    if (isTransactional != null && isTransactional) {
      bankAccounts?.removeWhere((account) => account.isTransactional == false);
    }

    return bankAccounts?.fold<Map<String, dynamic>>({}, (acc, curr) {
      String balance = accountsAndBalances.isNotEmpty
          ? "(${StringUtil.formatNumberWithThousandsSeparator(accountsAndBalances[curr.bankAccountId] ?? "Balance unavailable")})"
          : "";
      return acc
        ..[curr.bankAccountId] = curr.aliasName.isEmpty
            ? "${curr.bankAccountId} $balance"
            : formItem.controlId == ControlID.CLEARBANKACCOUNTID.name
                ? "${curr.bankAccountId} $balance"
                : "${curr.aliasName} $balance";
    });
  }
}

class _BeneficiaryDropDown implements IDropDownAdapter {
  _BeneficiaryDropDown({this.merchantID});

  String? merchantID;
  final _beneficiaryRepository = BeneficiaryRepository();
  final _sharedPref = CommonSharedPref();

  @override
  Future<Map<String, dynamic>?>? getDropDownItems() async {
    var customerNo = await _sharedPref.getCustomerMobile();
    var beneficiaries =
        await _beneficiaryRepository.getBeneficiariesByMerchantID(merchantID!);
    if (merchantID == "007001016" ||
        merchantID == "007001017" ||
        merchantID == 'MTNDB' ||
        merchantID == 'AIRTIME' ||
        merchantID == 'MTNUGAIRTIME' ||
        merchantID == 'AIRTELUG' ||
        merchantID == 'UGANDAMTNC2B' ||
        merchantID == 'AIRTELC2B') {
      beneficiaries?.add(Beneficiary(
          merchantID: merchantID ?? "",
          merchantName: "global",
          accountID: customerNo,
          accountAlias: "Own Number",
          rowId: 0));
    }

    return beneficiaries?.fold<Map<String, dynamic>>(
        {}, (acc, curr) => acc..[curr.accountID] = curr.accountAlias);
  }
}
