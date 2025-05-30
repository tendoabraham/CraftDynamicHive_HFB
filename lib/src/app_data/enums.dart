// ignore_for_file: constant_identifier_names

part of craft_dynamic;

enum ViewType {
  TEXT,
  BUTTON,
  RBUTTON,
  DROPDOWN,
  TAB,
  LABEL,
  QRSCANNER,
  PHONECONTACTS,
  DATE,
  HIDDEN,
  LIST,
  TEXTVIEW,
  HYPERLINK,
  CONTAINER,
  SELECTEDTEXT,
  IMAGE,
  TITLE,
  FORM,
  OTHER,
  STEPPER,
  STEP,
  CHECKBOX,
  HORIZONTALTEXT,
  DYNAMICDROPDOWN,
  CAROUSELVIEW,
  TEXTLINK,
  IMAGEDYNAMICDROPDOWN
}

enum ControlFormat {
  PinNumber,
  PIN,
  NUMERIC,
  Amount,
  DATE,
  imagepanel,
  HorizontalScroll,
  SELECTBANKACCOUNT,
  SELECTBENEFICIARY,
  LISTDATA,
  OTHER,
  OPENFORM,
  NEXT,
  TEXT,
  RADIOGROUPS,
  SHOWDIALOG,
  OWNNUMBER
}

enum DynamicDataType { Modules, ActionControls, FormControls }

enum ControlID {
  BANKACCOUNTID,
  BANKACCOUNTID1,
  BANKACCOUNTID2,
  BANKACCOUNTID3,
  BANKACCOUNTID4,
  BANKACCOUNTID5,
  BENEFICIARYACCOUNTID,
  OTHER,
  AMOUNT,
  BIBLELIST,
  TOACCOUNTID,
  FROMACCOUNTID,
  SELECTTYPE,
  CLEARBANKACCOUNTID,
  BILLERNAME,
  BILLERTYPE,
  RECEIVINGBRANCH,
  FROMNAME,
  FREQUENCY
}

enum ActionType {
  DBCALL,
  ACTIVATIONREQ,
  PAYBILL,
  VALIDATE,
  LOGIN,
  CHANGEPIN,
  ACTIVATE,
  BENEFICIARY,
  CHANGELANGUAGE,
  FORGOTPIN
}

enum ActionID { GETTRXLIST }

enum UserAccountData {
  FirstName,
  LastName,
  IDNumber,
  EmailID,
  ImageUrl,
  LastLoginDateTime,
  LoanLimit,
  Phone
}

enum RequestParam {
  FormID,
  SessionID,
  CustomerID,
  MobileNumber,
  Login,
  EncryptedFields,
  Activation,
  ModuleID,
  PayBill,
  UNIQUEID,
  BankID,
  Country,
  VersionNumber,
  IMEI,
  IMSI,
  TRXSOURCE,
  APPNAME,
  CODEBASE,
  LATLON,
  MerchantID,
  Validate,
  HEADER,
  DynamicForm,
  CHANGEPIN,
  CHANGELANGUAGE,
  Paybill,
}

enum FormFieldProp { ControlID, ControlValue }

enum ListType { TransactionList, ViewOrderList, BeneficiaryList }

enum ModuleId {
  DEFAULT,
  BOOKCAB,
  MERCHANTPAYMENT,
  GAS,
  DRINKS,
  TOPUPWALLET,
  SUPERMARKET,
  GROCERIES,
  PHARMACY,
  CAKE,
  FOOD,
  FINGERPRINT,
  TRANSACTIONSCENTER,
  PENDINGTRANSACTIONS,
  VIEWBENEFICIARY,
  STANDINGORDERVIEWDETAILS,
  PIN,
  LANGUAGEPREFERENCE,
  ADDBENEFICIARY,
  SECRETQUESTIONS,
  SECRETQUESTIONSCHECK,
  FORGOTPIN,
  MAIN,
  QUICKPAY,
  MTNDATA,
  AUTHENTICATOR
}

enum LittleProduct {
  Ride,
  PayMerchants,
  LoadWallet,
  Deliveries,
}

enum StatusCode {
  success("000"),
  failure("091"),
  lowFailure("092"),
  token("099"),
  otp("093"),
  changeLanguage("094"),
  changeBankType("095"),
  changePin("101"),
  forgotPin("107"),
  deviceMismatch("102"),
  setsecurityquestions("106"),
  logout("111"),
  unknown("XXXX");

  const StatusCode(this.statusCode);
  final String statusCode;
}

enum MenuCategory { BLOCK, FORM }

enum MenuType {
  Vertical,
  Horizontal,
}

enum ParentModule { MAIN, TRANSACTIONHISTORY, MYACCOUNTS }

enum RouteUrl { auth, account, card, other, staticdata }

enum FormId {
  STATICDATA,
  LOGIN,
  ACTIVATIONREQ,
  ACTIVATE,
  PAYBILL,
  MENU,
  FORMS,
  ACTIONS,
  ALERTCONFIRMATIONFORM,
  DBCALL
}

enum MapKey { TRANSTYPE, TRXCURRENCY, DATE, DEFAULT, AMOUNT }

enum MapValue { CREDIT, DEBIT, DEFAULT }

const success = "000";
const failure = "091";
const lowFailure = "092";
const token = "099";
const otp = "093";
const changeLanguage = "094";
const changeBankType = "095";
const changePin = "101";
const forgotpin = "107";
const unknown = "xxx";
