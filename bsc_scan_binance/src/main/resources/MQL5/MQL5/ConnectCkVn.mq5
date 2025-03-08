//+------------------------------------------------------------------+
//|                                                  ConnectCkVn.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--------------------------------------------------------------------------------------------------------------------
#import "shell32.dll"
int ShellExecuteW(int hWnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import
//--------------------------------------------------------------------------------------------------------------------
//https://api.binance.com
string telegram_url="https://api.telegram.org";
string api_binance_url="https://api.binance.com";
const string BOT_SHORT_NM="(Binance)";
const string BINANCE_LOG_FILE="BinanceLog.txt";
const string GLOBAL_VARIABLE_FILE="global_variable.data";
#define BtnD1_                      "BtnD1_"
#define BtnH4_                      "BtnH4_"
#define BtnLink_                    "BtnLink_"
#define BtnCkD1_                    "BtnCkD1_"
#define BtnDrawCkMonthly            "BtnDrawCkMonthly"
#define BtnDrawCkWeekly             "BtnDrawCkWeekly"
#define BtnDrawCk4hours             "BtnDrawCk4hours"
#define BtnClearChart               "BtnClearChart"
#define BtnSearchSymbol             "BtnSearchSymbol"
#define BtnFollowing_               "BtnFollowing_"
#define BtnTrading_                 "BtnTrading_"
#define BtnCkTradingView            "BtnCkTradingView"
#define BtnSaveResult               "BtnSaveResult"
#define BtnLoadResult               "BtnLoadResult"
#define BtnMakeSymbolsJson          "BtnMakeSymbolsJson"
#define BtnOptionPeriod             "BtnOption_Period_"
#define BtnMarketType               "BtnMarketType"
#define CLICKED_SYMBOL_CK_INDEX    "CLICKED_CK_INDEX"
#define LAST_CHECKED_BINANCE_INDEX "LAST_CHECKED_BINANCE_INDEX"
#define REQUEST_BINANCE_PER_MINUS  "timer_send_minus"
#define BTC_PRICE_HIG              "btc_price_hig"
#define BTC_PRICE_LOW              "btc_price_low"
#define TEXT_INPUT                 "TEXT_INPUT"
#define BtnManualLoadData         "BtnManualLoadData"
#define BtnResetLoadData          "BtnResetLoadData"
#define BtnFilter_                "BtnFilter_"
#define BtnFilterFollow           BtnFilter_+"Follow"
#define BtnFilterTrading          BtnFilter_+"Trading"
#define BtnFilterVn30             BtnFilter_+"Vn30"
#define BtnFilterHnx30            BtnFilter_+"Hnx30"
#define BtnFilterMa20Mo           BtnFilter_+"Ma20Mo"
#define BtnFilterMa10Mo           BtnFilter_+"Ma10Mo"
#define BtnFilterMa10W1           BtnFilter_+"Ma10W1"
#define BtnFilterMa10D1           BtnFilter_+"Ma10D1"
#define BtnFilterMa10H4           BtnFilter_+"Ma10H4"
#define BtnFilterHistMo           BtnFilter_+"HistMo"
#define BtnFilterHistM1           BtnFilter_+"HistM1"
#define BtnFilterHistM3           BtnFilter_+"HistM3"
#define BtnFilterHistWx           BtnFilter_+"HistWx"
#define BtnFilterHistHx           BtnFilter_+"HistHx"
#define BtnFilterHistW3           BtnFilter_+"HistW3"
#define BtnFilterToday            BtnFilter_+"Today"
#define BtnFilterClear            BtnFilter_+"Clear"
#define BtnFilterCondW20          BtnFilter_+"CondW20"
#define BtnFilterD20              BtnFilter_+"D20"
#define BtnFilterCondM383         BtnFilter_+"CondM383"
#define BtnFilterCondMoSeq         BtnFilter_+"CondM1C1"
#define BtnFilterCondW1Seq         BtnFilter_+"CondW1C3"
#define BtnFilterCondW1C3         BtnFilter_+"CondW1C1"
#define BtnFilterCondD1C2         BtnFilter_+"CondD1C2"
#define BtnFilterCondH4C3         BtnFilter_+"CondH4C3"
#define BtnFilterCondH4Sq         BtnFilter_+"CondH4Sq"
#define BtnFilterCondH450         BtnFilter_+"CondH450"
#define BtnFilter1BilVnd          BtnFilter_+"1BilVnd"
#define BtnFilter100BVnd          BtnFilter_+"100BVnd"
#define BtnToutch_                "BtnToutch_"
#define BtnClearMessageR1C1         "BtnClearMessageR1C1"
#define BtnClearMessageR1C2         "BtnClearMessageR1C2"
#define BtnMsgR1C1_                 "BtnMsgR1C1_"
#define BtnMsgR1C2_                 "BtnMsgR1C2_"
const string FILE_MSG_LIST_R1C1 = "R1C1.txt";
const string FILE_MSG_LIST_R1C2 = "R1C2.txt";
const int MAX_MESSAGES= 1000;
const string TREND_BUY="BUY";
const string TREND_SEL="SELL";
const string STR_SEQ_BUY="SeqBuy";
const string STR_SEQ_SEL="SeqSel";
const string MASK_TOUCH_MA50="|50|";
datetime TIME_OF_ONE_H1_CANDLE=3600;
datetime TIME_OF_ONE_H4_CANDLE=14400;
datetime TIME_OF_ONE_D1_CANDLE=86400;
datetime TIME_OF_ONE_W1_CANDLE=604800;
datetime GLOBAL_TIME_OF_ONE_CANDLE=TIME_OF_ONE_W1_CANDLE-TIME_OF_ONE_H4_CANDLE*10;
color clrActiveBtn = clrLightGreen;
color clrActiveSell= clrMistyRose;
const int BTN_PER_COLUMN=50;
const int NUM_CANDLE_DRAW=21;
const double SYMBOL_TYPE_CK=12.0;
const double FILTER_NON=111;
const double FILTER_BUY=333;
const double FILTER_SEL=555;
const double FILTER_ON =777;
const double OPTION_FOLOWING=111.1;
const double VOL_1BILLION_VND=1000000000;
const string MORE_THAN_100_BIL_VND=">100b";
const string MORE_THAN_1_BIL_VND=">1ty";
const string LESS_THAN_1_BIL_VND="<1ty";
const string GROUP_NGANHANG="(Bank)";
const string GROUP_CHUNGKHOAN="(CK)";
const string GROUP_BATDONGSAN="(BĐS)";
const string GROUP_DUOCPHAM="(Dược)";
const string GROUP_DAUKHI="(XTI)";
const string GROUP_THEP="(Thép)";
const string GROUP_CONGNGHIEP="(Công)";
const string GROUP_MAYMAC="(May)";
const string GROUP_DIEN="(Điện)";
const string GROUP_PHANBON="(Phân)";
const string GROUP_DAVINCI="(Davinci)";
const string GROUP_OTHERS="(Others)";

//VN200(volume>70Bvnd/month)
string ARR_SYMBOLS_CK[] =
  {
   "HOSE_VNINDEX"
   , "HOSE_BID", "HOSE_CTG", "HOSE_EIB", "HOSE_MBB", "HOSE_STB", "HOSE_VCB", "HNX_NVB"
   , "HOSE_ACB", "HOSE_HDB", "HOSE_LPB", "HOSE_OCB", "HOSE_SHB", "HOSE_SSB", "HOSE_TCB", "HOSE_TPB", "HOSE_VIB", "HOSE_VPB", "HNX_BAB", "UPCOM_ABB", "UPCOM_BVB", "UPCOM_KLB", "UPCOM_SGB", "UPCOM_PVC", "UPCOM_GPB"

   , "HOSE_AAA", "HOSE_ADS", "HOSE_ANV", "HOSE_ASM", "HOSE_BBC", "HOSE_BCE", "HOSE_BFC", "HOSE_BIC", "HOSE_BMC", "HOSE_BMI", "HOSE_BMP", "HOSE_BVH", "HOSE_C32", "HOSE_C47"
   , "HOSE_CCL", "HOSE_CII", "HOSE_CMG", "HOSE_CMX", "HOSE_CNG", "HOSE_CSV", "HOSE_CTD", "HOSE_CTF", "HOSE_CTI", "HOSE_D2D", "HOSE_DAH", "HOSE_DCL", "HOSE_DCM", "HOSE_DGW", "HOSE_DHC", "HOSE_DHM"
   , "HOSE_DIG", "HOSE_DLG", "HOSE_DMC", "HOSE_DPM", "HOSE_DPR", "HOSE_DRC", "HOSE_DRH", "HOSE_DVP", "HOSE_DXG", "HOSE_ELC", "HOSE_FCN", "HOSE_FIT", "HOSE_FMC", "HOSE_FPT", "HOSE_FRT", "HOSE_GAS"
   , "HOSE_GIL", "HOSE_GMD", "HOSE_HAG", "HOSE_HAH", "HOSE_HAP", "HOSE_HAR", "HOSE_HAX", "HOSE_HCD", "HOSE_HDC", "HOSE_HDG", "HOSE_HHS", "HOSE_HPG", "HOSE_HQC", "HOSE_HSG", "HOSE_HT1", "HOSE_IDI", "HOSE_IJC"
   , "HOSE_IMP", "HOSE_ITC", "HOSE_ITD", "HOSE_JVC", "HOSE_KBC", "HOSE_KDC", "HOSE_KDH", "HOSE_KHP", "HOSE_KSB", "HOSE_LCG", "HOSE_LDG", "HOSE_LHG", "HOSE_LIX", "HOSE_LSS", "HOSE_MHC", "HOSE_MSN"
   , "HOSE_MWG", "HOSE_NAF", "HOSE_NBB", "HOSE_NKG", "HOSE_NLG", "HOSE_NT2", "HOSE_NTL", "HOSE_OGC", "HOSE_PAC", "HOSE_PAN", "HOSE_PC1", "HOSE_PDR", "HOSE_PET", "HOSE_PGC", "HOSE_PHR", "HOSE_PNJ", "HOSE_PPC"
   , "HOSE_PTB", "HOSE_PVD", "HOSE_PVT", "HOSE_QCG", "HOSE_REE", "HOSE_SAB", "HOSE_SAM", "HOSE_SBT", "HOSE_SCR", "HOSE_SGT", "HOSE_SHI", "HOSE_SJS", "HOSE_SKG", "HOSE_SMC", "HOSE_STK", "HOSE_SVC"
   , "HOSE_SZC", "HOSE_TCH", "HOSE_TCL", "HOSE_TCM", "HOSE_TCO", "HOSE_TDC", "HOSE_TDH", "HOSE_TIP", "HOSE_TLG", "HOSE_TLH", "HOSE_TMS", "HOSE_TRC", "HOSE_TSC", "HOSE_TTF", "HOSE_VFG", "HOSE_VHC"
   , "HOSE_VIC", "HOSE_VIP", "HOSE_VJC", "HOSE_VNM", "HOSE_VOS", "HOSE_VPH", "HOSE_VRC", "HOSE_VSC", "HOSE_VSH", "HOSE_VTO"

   , "HNX_API", "HNX_BCC", "HNX_CEO", "HNX_CSC", "HNX_DHT", "HNX_DL1", "HNX_DNP", "HNX_DXP", "HNX_HLD", "HNX_HUT", "HNX_IDJ", "HNX_L18", "HNX_LAS", "HNX_LHC", "HNX_LIG", "HNX_MAC", "HNX_MBG", "HNX_MST"
   , "HNX_NBC", "HNX_NDN", "HNX_NTP", "HNX_PLC", "HNX_PVB", "HNX_PVC", "HNX_PVI", "HNX_S99", "HNX_SAF", "HNX_SLS", "HNX_TIG", "HNX_TNG", "HNX_TVC", "HNX_TVD", "HNX_VC3", "HNX_VGS"

   , "UPCOM_ACV", "UPCOM_DDV", "UPCOM_G36", "UPCOM_MCH", "UPCOM_MSR", "UPCOM_ND2", "UPCOM_NTC", "UPCOM_PVM", "UPCOM_PXL", "UPCOM_QNS", "UPCOM_SEA", "UPCOM_SGP", "UPCOM_TVN", "UPCOM_VEF"
   , "UPCOM_VFC", "UPCOM_VGG", "UPCOM_VGT", "UPCOM_VLB", "UPCOM_VOC", "UPCOM_VRG"
  };

//string ARR_SYMBOLS_CK[] =
//  {
//   "HOSE_VNINDEX","HOSE_AAA","HOSE_ACB","HOSE_AGR","HOSE_ANV","HOSE_ASM","HOSE_BCM","HOSE_BID","HOSE_BMP","HOSE_BSI","HOSE_BVH","HOSE_BWE","HOSE_CCL","HOSE_CII"
//   ,"HOSE_CMG","HOSE_CRE","HOSE_CTD","HOSE_CTG","HOSE_CTR","HOSE_D2D","HOSE_DBC","HOSE_DCM","HOSE_DGC","HOSE_DGW","HOSE_DIG","HOSE_DPM","HOSE_DXG","HOSE_DXS"
//   ,"HOSE_EIB","HOSE_EVF","HOSE_FPT","HOSE_FRT","HOSE_FTS","HOSE_GAS","HOSE_GEX","HOSE_GMD","HOSE_GVR","HOSE_HAG","HOSE_HCM","HOSE_HDB","HOSE_HDC","HOSE_HDG"
//   ,"HOSE_HPG","HOSE_HSG","HOSE_HT1","HOSE_HVN","HOSE_IMP","HOSE_KBC","HOSE_KDC","HOSE_KDH","HOSE_LHG","HOSE_LPB","HOSE_MBB","HOSE_MSB","HOSE_MSH","HOSE_MSN","HOSE_MWG"
//   ,"HOSE_NHA","HOSE_NKG","HOSE_NLG","HOSE_NT2","HOSE_NTL","HOSE_NVL","HOSE_OCB","HOSE_IJC","HOSE_PC1","HOSE_PDR","HOSE_PHR","HOSE_PLX","HOSE_PNJ","HOSE_POW","HOSE_PPC"
//   ,"HOSE_PVP","HOSE_PVD","HOSE_PVT","HOSE_QCG","HOSE_REE","HOSE_SAB","HOSE_SBT","HOSE_SCS","HOSE_SHB","HOSE_SIP","HOSE_SJS","HOSE_SSB","HOSE_SSI","HOSE_STB","HOSE_SZC"
//   ,"HOSE_TCB","HOSE_TCH","HOSE_TCM","HOSE_TLG","HOSE_TPB","HOSE_VCB","HOSE_VCG","HOSE_VCI","HOSE_VGC","HOSE_VHC","HOSE_VHM","HOSE_VIB","HOSE_VIC","HOSE_VIX","HOSE_TNH"
//   ,"HOSE_FCN","HOSE_KSB","HOSE_HHV","HOSE_CKG","HOSE_BFC","HOSE_VJC","HOSE_TDC","HOSE_VNM","HOSE_VPB","HOSE_VRE","HOSE_VSH","HOSE_OGC","HOSE_BAF","HOSE_SKG","HOSE_CSM"
//
//   ,"HNX_MBS","HNX_TNG","HNX_PVS","HNX_VC7","HNX_AAV","HNX_DTD","HNX_LAS","HNX_MST","HNX_IDC","HNX_NVB","HNX_VC3","HNX_BAB", "HNX_VGS"
//   ,"HNX_BCC", "HNX_BVS", "HNX_CAP", "HNX_DVM", "HNX_HUT", "HNX_LHC", "HNX_NBC", "HNX_PLC", "HNX_PVC", "HNX_SHS", "HNX_SLS", "HNX_TIG", "HNX_TVD", "HNX_VCS", "HNX_VIG"
//
//   ,"UPCOM_ABB","UPCOM_BVB","UPCOM_KLB","UPCOM_SGB","UPCOM_HBC","UPCOM_MSR","UPCOM_VGT","UPCOM_HNG","UPCOM_VEA", "UPCOM_MCH", "UPCOM_MML", "UPCOM_FOX", "UPCOM_TVN"
//  };

//string ARR_SYMBOLS_CK[] =
//  {
//   "HOSE_VNINDEX"
//   ,"HOSE_AAA","HOSE_ACB","HOSE_AGR","HOSE_ANV","HOSE_ASM","HOSE_BCM","HOSE_BID","HOSE_BMP","HOSE_BSI","HOSE_BVH","HOSE_BWE","HOSE_CCL","HOSE_CII"
//   ,"HOSE_CMG","HOSE_CRE","HOSE_CTD","HOSE_CTG","HOSE_CTR","HOSE_D2D","HOSE_DBC","HOSE_DCM","HOSE_DGC","HOSE_DGW","HOSE_DIG","HOSE_DPM","HOSE_DXG","HOSE_DXS"
//   ,"HOSE_EIB","HOSE_EVF","HOSE_FPT","HOSE_FRT","HOSE_FTS","HOSE_GAS","HOSE_GEX","HOSE_GMD","HOSE_GVR","HOSE_HAG","HOSE_HCM","HOSE_HDB","HOSE_HDC","HOSE_HDG"
//   ,"HOSE_HPG","HOSE_HSG","HOSE_HT1","HOSE_HVN","HOSE_IMP","HOSE_KBC","HOSE_KDC","HOSE_KDH","HOSE_LHG","HOSE_LPB","HOSE_MBB","HOSE_MSB","HOSE_MSH","HOSE_MSN","HOSE_MWG"
//   ,"HOSE_NHA","HOSE_NKG","HOSE_NLG","HOSE_NT2","HOSE_NTL","HOSE_NVL","HOSE_OCB","HOSE_IJC","HOSE_PC1","HOSE_PDR","HOSE_PHR","HOSE_PLX","HOSE_PNJ","HOSE_POW","HOSE_PPC"
//   ,"HOSE_PVP","HOSE_PVD","HOSE_PVT","HOSE_QCG","HOSE_REE","HOSE_SAB","HOSE_SBT","HOSE_SCS","HOSE_SHB","HOSE_SIP","HOSE_SJS","HOSE_SSB","HOSE_SSI","HOSE_STB","HOSE_SZC"
//   ,"HOSE_TCB","HOSE_TCH","HOSE_TCM","HOSE_TLG","HOSE_TPB","HOSE_VCB","HOSE_VCG","HOSE_VCI","HOSE_VGC","HOSE_VHC","HOSE_VHM","HOSE_VIB","HOSE_VIC","HOSE_VIX","HOSE_TNH"
//   ,"HOSE_FCN","HOSE_KSB","HOSE_HHV","HOSE_CKG","HOSE_BFC","HOSE_VJC","HOSE_TDC","HOSE_VNM","HOSE_VPB","HOSE_VRE","HOSE_VSH","HOSE_OGC","HOSE_BAF","HOSE_SKG","HOSE_CSM"
//   ,"HNX_MBS","HNX_TNG","HNX_PVS","HNX_VC7","HNX_AAV","HNX_DTD","HNX_LAS","HNX_MST","HNX_IDC","HNX_NVB","HNX_VC3","HNX_BAB", "HNX_VGS"
//   ,"HNX_BCC", "HNX_BVS", "HNX_CAP", "HNX_DVM", "HNX_HUT", "HNX_LHC", "HNX_NBC", "HNX_PLC", "HNX_PVC", "HNX_SHS", "HNX_SLS", "HNX_TIG", "HNX_TVD", "HNX_VCS", "HNX_VIG"
//   ,"UPCOM_ABB","UPCOM_BVB","UPCOM_KLB","UPCOM_SGB","UPCOM_HBC","UPCOM_MSR","UPCOM_VGT","UPCOM_HNG","UPCOM_VEA", "UPCOM_MCH", "UPCOM_MML", "UPCOM_FOX", "UPCOM_TVN"
//
//   , "HOSE_AAM", "UPCOM_ABC", "UPCOM_ABI", "HOSE_ABT", "HOSE_ACC", "UPCOM_ACE", "HOSE_ACL", "UPCOM_ACV", "HNX_ADC", "HOSE_ADS", "UPCOM_AFX", "HOSE_AGM", "UPCOM_AGP", "UPCOM_AGX", "HNX_ALT", "HNX_AMC", "HNX_AME", "UPCOM_AMP", "UPCOM_AMS", "HNX_AMV", "UPCOM_ANT", "HNX_API", "UPCOM_APL", "HNX_ARM", "HOSE_ASP", "UPCOM_ATA", "HNX_ATS"
//   , "UPCOM_AVF", "HNX_BAX", "HOSE_BBC", "HNX_BBS", "HOSE_BCE", "HOSE_BCG", "UPCOM_BCP", "UPCOM_BDG", "UPCOM_BDW", "UPCOM_BHC", "HOSE_BHN", "UPCOM_BHP", "HOSE_BIC", "HNX_BKC", "UPCOM_BLI", "UPCOM_BLN", "HOSE_BMC", "HOSE_BMI", "UPCOM_BMJ", "UPCOM_BMN", "HNX_BPC", "HOSE_BRC", "UPCOM_BRS", "HNX_BSC", "UPCOM_BSG", "UPCOM_BSP", "UPCOM_BSQ"
//   , "UPCOM_BT1", "UPCOM_BT6", "UPCOM_BTB", "UPCOM_BTD", "UPCOM_BTG", "HOSE_BTP", "HNX_BTS", "HOSE_BTT", "UPCOM_BTU", "UPCOM_BVG", "UPCOM_BVN", "UPCOM_BWA", "HNX_BXH", "UPCOM_C12", "UPCOM_C21", "HOSE_C32", "HOSE_C47", "UPCOM_CAD", "HNX_CAN", "HOSE_CCI", "UPCOM_CCV", "HOSE_CDC", "UPCOM_CDG", "HNX_CDN", "HNX_CEO", "UPCOM_CHC", "HOSE_CHP"
//   , "UPCOM_CHS", "UPCOM_CI5", "UPCOM_CID", "HOSE_CIG", "HNX_CJC", "UPCOM_CKD", "HNX_CKV", "HOSE_CLC", "HNX_CLH", "HOSE_CLL", "HNX_CLM", "HOSE_CLW", "UPCOM_CLX", "HNX_CMC", "UPCOM_CMF", "HNX_CMS", "HOSE_CMV", "HOSE_CMX", "UPCOM_CNC", "HOSE_CNG", "UPCOM_CNN", "UPCOM_CNT", "HOSE_COM", "HNX_CPC", "UPCOM_CQT", "HNX_CSC", "HOSE_CSV"
//   , "UPCOM_CT3", "HNX_CTB", "HOSE_CTF", "HOSE_CTI", "UPCOM_CTN", "HNX_CTP", "HNX_CTT", "UPCOM_CTW", "HNX_CVN", "HNX_CX8", "HNX_D11", "UPCOM_DAC", "HNX_DAD", "HOSE_DAH", "UPCOM_DAS", "UPCOM_DBM", "UPCOM_DC1", "HNX_DC2", "UPCOM_DCF", "HOSE_DCL", "UPCOM_DCT", "UPCOM_DDH", "UPCOM_DDM", "UPCOM_DDN", "UPCOM_DDV", "UPCOM_DFC", "UPCOM_DGT"
//   , "HOSE_DHA", "HOSE_DHC", "HOSE_DHG", "HOSE_DHM", "HNX_DHP", "HNX_DHT", "HNX_DL1", "HOSE_DLG", "HOSE_DMC", "HNX_DNC", "UPCOM_DND", "UPCOM_DNL", "HNX_DNP", "UPCOM_DNW", "UPCOM_DOC", "UPCOM_DOP", "HNX_DP3", "UPCOM_DPH", "UPCOM_DPP", "HOSE_DPR", "HOSE_DQC", "HOSE_DRC", "HOSE_DRH", "HOSE_DRL", "HOSE_DSN", "HOSE_DTA", "HOSE_DTL"
//   , "HOSE_DTT", "UPCOM_DVC", "HOSE_DVP", "HNX_DXP", "HOSE_DXV", "HNX_ECI", "UPCOM_EIC", "HNX_EID", "HOSE_ELC", "UPCOM_EMG", "HOSE_EVE", "HOSE_FCM", "UPCOM_FCS", "HOSE_FDC", "HNX_FID", "HOSE_FIT", "HOSE_FMC", "UPCOM_G36", "UPCOM_GCB", "HOSE_GDT", "UPCOM_GER", "UPCOM_GGG", "UPCOM_GHC", "HOSE_GIL", "HNX_GLT", "HNX_GMX", "UPCOM_GND"
//   , "UPCOM_GSM", "HOSE_GSP", "HOSE_GTA", "UPCOM_GTD", "UPCOM_GTS", "UPCOM_GTT", "UPCOM_GVT", "UPCOM_H11", "HNX_HAD", "HOSE_HAH", "UPCOM_HAN", "HOSE_HAP", "HOSE_HAR", "HOSE_HAS", "HNX_HAT", "HOSE_HAX", "UPCOM_HBD", "HNX_HCC", "HOSE_HCD", "UPCOM_HCI", "HNX_HCT", "UPCOM_HD2", "HNX_HDA", "UPCOM_HDM", "UPCOM_HDP", "UPCOM_HEC", "UPCOM_HES"
//   , "UPCOM_HFC", "UPCOM_HFX", "HNX_HGM", "HNX_HHC", "HOSE_HHS", "HOSE_HID", "UPCOM_HIG", "UPCOM_HJC", "HNX_HJS", "HNX_HKT", "UPCOM_HLA", "UPCOM_HLB", "HNX_HLC", "HNX_HLD", "HOSE_HMC", "UPCOM_HMG", "HNX_HMH", "UPCOM_HNB", "UPCOM_HND", "UPCOM_HNF", "UPCOM_HNP", "HNX_HOM", "UPCOM_HPB", "UPCOM_HPD", "UPCOM_HPP", "UPCOM_HPT", "UPCOM_HPW"
//   , "HOSE_HQC", "HOSE_HRC", "UPCOM_HSA", "UPCOM_HSI", "HNX_HTC", "HOSE_HTI", "HOSE_HTL", "HOSE_HTV", "HOSE_HU1", "UPCOM_HU4", "UPCOM_HU6", "HNX_HVT", "HOSE_HVX", "UPCOM_ICC", "HNX_ICG", "UPCOM_ICI", "UPCOM_ICN", "HOSE_IDI", "HNX_IDJ", "HNX_IDV", "UPCOM_IFS", "UPCOM_IHK", "UPCOM_IME", "UPCOM_IN4", "HNX_INC", "HNX_INN", "UPCOM_ISG"
//   , "UPCOM_ISH", "UPCOM_IST", "HOSE_ITC", "HOSE_ITD", "HNX_ITQ", "UPCOM_ITS", "HOSE_JVC", "UPCOM_KCB", "UPCOM_KCE", "HNX_KDM", "UPCOM_KHD", "HOSE_KHP", "UPCOM_KHW", "UPCOM_KIP", "HNX_KKC", "HOSE_KMR", "HNX_KMT", "HOSE_KPF", "HNX_KSD", "HNX_KSQ", "HNX_KST", "UPCOM_KTL", "HNX_KTS", "HOSE_L10", "UPCOM_L12", "HNX_L14", "HNX_L18"
//   , "UPCOM_L45", "UPCOM_L63", "HOSE_LAF", "UPCOM_LAI", "UPCOM_LAW", "HOSE_LBM", "UPCOM_LCC", "HNX_LCD", "HOSE_LCG", "HOSE_LDG", "HNX_LDP", "HOSE_LGC", "HOSE_LGL", "HNX_LIG", "HOSE_LIX", "UPCOM_LKW", "UPCOM_LM3", "HOSE_LM8", "UPCOM_LQN", "HOSE_LSS", "HNX_MAC", "HNX_MAS", "HNX_MBG", "HNX_MCC", "HNX_MCF", "HNX_MCO", "HOSE_MCP", "HNX_MDC"
//   , "UPCOM_MDF", "HOSE_MDG", "UPCOM_MGC", "UPCOM_MH3", "HOSE_MHC", "UPCOM_MIC", "HNX_MKV", "UPCOM_MTA", "UPCOM_MTG", "UPCOM_MTH", "UPCOM_MTL", "UPCOM_MTP", "HOSE_NAF", "HNX_NAG", "UPCOM_NAS", "HOSE_NAV", "HOSE_NBB", "HNX_NBP", "UPCOM_NBT", "UPCOM_NCS", "HOSE_NCT", "UPCOM_ND2", "UPCOM_NDC", "HNX_NDN", "UPCOM_NDP", "HNX_NDX", "HNX_NET"
//   , "HNX_NFC", "HNX_NHC", "UPCOM_NLS", "HOSE_NNC", "UPCOM_NNT", "UPCOM_NOS", "UPCOM_NQB", "UPCOM_NS2", "HOSE_NSC", "UPCOM_NSG", "HNX_NST", "UPCOM_NTB", "UPCOM_NTC", "HNX_NTP", "UPCOM_NTW", "UPCOM_NUE", "UPCOM_NWT", "HNX_OCH", "HNX_ONE", "UPCOM_ONW", "HOSE_OPC", "HOSE_PAC", "UPCOM_PAI", "HOSE_PAN", "HNX_PBP", "HNX_PCG", "HNX_PCT"
//   , "HNX_PDB", "HOSE_PDN", "UPCOM_PEC", "HNX_PEN", "UPCOM_PEQ", "HOSE_PET", "UPCOM_PFL", "HOSE_PGC", "HOSE_PGD", "HOSE_PGI", "HNX_PGS", "HNX_PGT", "UPCOM_PHH", "HNX_PIC", "UPCOM_PID", "UPCOM_PIS", "HOSE_PIT", "HNX_PJC", "UPCOM_PJS", "HOSE_PJT", "HNX_PMB", "HNX_PMC", "UPCOM_PMJ", "HNX_PMP", "HNX_PMS", "UPCOM_PMT", "HOSE_PNC"
//   , "UPCOM_PND", "UPCOM_PNG", "UPCOM_PNT", "UPCOM_POS", "HNX_POT", "UPCOM_POV", "HNX_PPE", "HNX_PPP", "HNX_PPS", "HNX_PPY", "HNX_PRC", "UPCOM_PRO", "UPCOM_PSB", "HNX_PSC", "HNX_PSD", "HNX_PSE", "UPCOM_PSG", "UPCOM_PSL", "UPCOM_PSP", "HNX_PSW", "HOSE_PTB", "HOSE_PTC", "HNX_PTD", "UPCOM_PTE", "UPCOM_PTG", "UPCOM_PTH", "HNX_PTI"
//   , "HOSE_PTL", "UPCOM_PTP", "HNX_PTS", "UPCOM_PTT", "HNX_PV2", "UPCOM_PVA", "HNX_PVB", "HNX_PVG", "HNX_PVI", "UPCOM_PVM", "UPCOM_PVO", "UPCOM_PXL", "UPCOM_PXM", "UPCOM_QCC", "HNX_QHD", "UPCOM_QHW", "UPCOM_QNS", "UPCOM_QNU", "UPCOM_QNW", "UPCOM_QPH", "UPCOM_QSP", "HNX_QTC", "HOSE_RAL", "UPCOM_RAT", "UPCOM_RBC", "UPCOM_RCC", "UPCOM_RCD"
//   , "HNX_RCL", "HOSE_RDP", "UPCOM_RTB", "UPCOM_S12", "UPCOM_S27", "HOSE_S4A", "HNX_S55", "UPCOM_S96", "HNX_S99", "UPCOM_SAC", "HNX_SAF", "HOSE_SAM", "UPCOM_SAS", "HOSE_SAV", "UPCOM_SB1", "HOSE_SBA", "UPCOM_SBD", "UPCOM_SBL", "HOSE_SBV", "HOSE_SC5", "UPCOM_SCC", "HNX_SCI", "UPCOM_SCO", "HOSE_SCR", "UPCOM_SD1", "UPCOM_SD3", "HNX_SD5"
//   , "UPCOM_SD8", "HNX_SD9", "HNX_SDA", "UPCOM_SDB", "HNX_SDC", "HNX_SDG", "UPCOM_SDJ", "UPCOM_SDK", "HNX_SDN", "HNX_SDU", "UPCOM_SDV", "UPCOM_SDX", "UPCOM_SEA", "HNX_SEB", "HNX_SED", "UPCOM_SEP", "HOSE_SFC", "HOSE_SFG", "HOSE_SFI", "HNX_SFN", "HNX_SGC", "HNX_SGH", "UPCOM_SGP", "UPCOM_SGS", "HOSE_SGT", "HOSE_SHA", "UPCOM_SHG"
//   , "HOSE_SHI", "HNX_SHN", "HOSE_SHP", "UPCOM_SID", "HNX_SJ1", "HOSE_SJD", "HNX_SJE", "UPCOM_SJM", "HOSE_SMA", "HOSE_SMC", "HNX_SMT", "UPCOM_SNC", "UPCOM_SPB", "UPCOM_SPD", "UPCOM_SPH", "HNX_SPI", "HOSE_SPM", "UPCOM_SPV", "UPCOM_SQC", "HNX_SRA", "UPCOM_SRB", "HOSE_SRC", "HOSE_SRF", "HOSE_SSC", "UPCOM_SSF", "UPCOM_SSG", "HNX_SSM"
//   , "UPCOM_SSN", "HOSE_ST8", "HOSE_STG", "HOSE_STK", "HNX_STP", "UPCOM_STS", "HOSE_SVC", "UPCOM_SVG", "HOSE_SVI", "HNX_SVN", "HOSE_SVT", "UPCOM_SWC", "UPCOM_SZE", "HOSE_SZL", "HNX_TA9", "UPCOM_TAW", "HOSE_TBC", "UPCOM_TBD", "UPCOM_TBT", "HNX_TBX", "HOSE_TCL", "HOSE_TCO", "HOSE_TCR", "HOSE_TCT", "HOSE_TDH", "UPCOM_TDS", "HOSE_TDW"
//   , "HNX_TET", "HNX_TFC", "UPCOM_TGP", "HNX_THB", "HOSE_THG", "HNX_THS", "HNX_THT", "UPCOM_THW", "HOSE_TIP", "UPCOM_TIS", "HOSE_TIX", "HNX_TJC", "HNX_TKU", "UPCOM_TL4", "HOSE_TLH", "UPCOM_TLT", "HNX_TMB", "HNX_TMC", "UPCOM_TMG", "HOSE_TMP", "HOSE_TMS", "HOSE_TMT", "UPCOM_TMW", "HNX_TMX", "UPCOM_TNB", "HOSE_TNC", "UPCOM_TNM"
//   , "UPCOM_TNP", "UPCOM_TNS", "HOSE_TNT", "UPCOM_TOP", "HOSE_TPC", "HNX_TPP", "UPCOM_TPS", "UPCOM_TQN", "HOSE_TRA", "HOSE_TRC", "UPCOM_TRS", "HNX_TSB", "HOSE_TSC", "HNX_TTC", "UPCOM_TTD", "HOSE_TTF", "UPCOM_TTG", "HNX_TTH", "UPCOM_TUG", "HNX_TV3", "HNX_TV4", "HNX_TVC", "UPCOM_TVG", "UPCOM_TVM", "UPCOM_TW3", "HNX_TXM", "HOSE_TYA"
//   , "UPCOM_UCT", "UPCOM_UDJ", "UPCOM_UEM", "HOSE_UIC", "HNX_UNI", "UPCOM_UPC", "UPCOM_UPH", "UPCOM_USC", "UPCOM_V11", "HNX_V12", "UPCOM_V15", "HNX_V21", "HOSE_VAF", "HNX_VBC", "HNX_VC1", "HNX_VC2", "UPCOM_VC5", "HNX_VC6", "HNX_VC9", "HNX_VCC", "HOSE_VCF", "HNX_VCM", "UPCOM_VCP", "UPCOM_VCT", "UPCOM_VCW", "UPCOM_VCX", "HNX_VDL"
//   , "UPCOM_VDN", "UPCOM_VDT", "HNX_VE1", "HNX_VE3", "HNX_VE4", "HNX_VE8", "UPCOM_VEF", "UPCOM_VES", "UPCOM_VFC", "HOSE_VFG", "UPCOM_VGG", "UPCOM_VGL", "HNX_VGP", "UPCOM_VHF", "UPCOM_VHH", "HNX_VHL", "HOSE_VID", "UPCOM_VIM", "UPCOM_VIN", "HOSE_VIP", "HNX_VIT", "HNX_VLA", "UPCOM_VLB", "UPCOM_VLC", "UPCOM_VLF", "UPCOM_VLG", "HNX_VMC"
//   , "HOSE_VMD", "HNX_VMS", "HNX_VNC", "HOSE_VNE", "HNX_VNF", "UPCOM_VNI", "HOSE_VNL", "UPCOM_VNP", "HNX_VNR", "HOSE_VNS", "HNX_VNT", "UPCOM_VNX", "UPCOM_VNY", "UPCOM_VOC", "HOSE_VOS", "UPCOM_VPA", "UPCOM_VPC", "HOSE_VPH", "UPCOM_VPR", "HOSE_VPS", "UPCOM_VQC", "HOSE_VRC", "UPCOM_VRG", "HNX_VSA", "HOSE_VSC", "UPCOM_VSG", "HOSE_VSI"
//   , "UPCOM_VSN", "UPCOM_VST", "UPCOM_VTA", "HOSE_VTB", "HNX_VTC", "HNX_VTH", "UPCOM_VTI", "HOSE_VTO", "HNX_VTV", "UPCOM_VTX", "UPCOM_VWS", "HNX_WCS", "UPCOM_WSB", "UPCOM_WTC", "UPCOM_XHC", "UPCOM_XMD", "UPCOM_XPH", "UPCOM_YBC"
//  };

const string VN30="HOSE_VNINDEX, "+
                  "HOSE_ACB, HOSE_BCM, HOSE_BID, HOSE_BVH, HOSE_CTG, HOSE_FPT, HOSE_GAS, HOSE_GVR, HOSE_HDB, HOSE_HPG, "+
                  "HOSE_MBB, HOSE_MSN, HOSE_MWG, HOSE_PLX, HOSE_POW, HOSE_SAB, HOSE_SHB, HOSE_SSB, HOSE_SSI, HOSE_STB, "+
                  "HOSE_TCB, HOSE_TPB, HOSE_VCB, HOSE_VHM, HOSE_VIB, HOSE_VIC, HOSE_VJC, HOSE_VNM, HOSE_VPB, HOSE_VRE  ";

const string HNX30= "HNX_BCC, HNX_BVS, HNX_CAP, HNX_CEO, HNX_DTD, HNX_DVM, HNX_DXP, HNX_HLD, HNX_HUT, HNX_IDC, HNX_L14, HNX_L18, HNX_LAS, HNX_LHC, HNX_MBS, "+
                    "HNX_NBC, HNX_PLC, HNX_PSI, HNX_PVC, HNX_PVG, HNX_PVS, HNX_SHS, HNX_SLS, HNX_TDN, HNX_TIG, HNX_TNG, HNX_TVD, HNX_VC3, HNX_VCS, HNX_VIG";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0);

   double _price;
   datetime _time;
   int _sub_windows;
   int chart_heigh=(int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));
   if(ChartXYToTimePrice(0,10,70,_sub_windows,_time,_price))
      SetGlobalVariable(BTC_PRICE_HIG,_price);

   if(ChartXYToTimePrice(0,10,chart_heigh-70,_sub_windows,_time,_price))
      SetGlobalVariable(BTC_PRICE_LOW,_price);

//  ListAllFiles();
   Draw_Buttons();

//EventSetTimer(10); // Mỗi 10 giây gọi lại OnTimer
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ListAllFiles()
  {
   string filename = "";
   long handle = 0;
   int count = 0;

// Thử liệt kê tất cả file trong thư mục Files
   handle = FileFindFirst("*.*", filename); // Dùng pattern đơn giản
   if(handle != INVALID_HANDLE)
     {
      Print("Danh sách các tệp trong thư mục Files:");
      do
        {
         if(filename != "")
           {
            Print(++count, ". ", filename);
           }
        }
      while(FileFindNext(handle, filename));

      FileFindClose(handle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Buttons()
  {
   int size_ck =ArraySize(ARR_SYMBOLS_CK);

   int btn_width = 130;
   int column[19]; // Mảng để lưu vị trí cột
   for(int i = 0; i < 19; i++)
      column[i] = 30+i*(btn_width+30); // Tính toán khoảng cách cột

   int count_btn = 0;
   int y_dimention_base = 50; // Độ lệch theo chiều dọc cơ bản
   int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))-20;
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
   int x_mwhlinkclear=column[8];
   int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);

   int count=0;
   color clrFolowing=clrLightGray;
   color clrTrading=clrLightGray;
   bool is_vn30=GetGlobalVariable(BtnFilterVn30)==FILTER_ON?true:false;
   bool is_hnx30=GetGlobalVariable(BtnFilterHnx30)==FILTER_ON?true:false;
   bool is_only_follow=GetGlobalVariable(BtnFilterFollow)==FILTER_ON?true:false;
   bool is_filter_trading=GetGlobalVariable(BtnFilterTrading)==OPTION_FOLOWING;

   bool FilterHistMo=GetGlobalVariable(BtnFilterHistMo)==FILTER_ON?true:false;
   bool FilterHistWx=GetGlobalVariable(BtnFilterHistWx)==FILTER_ON?true:false;
   bool FilterHistHx=GetGlobalVariable(BtnFilterHistHx)==FILTER_ON?true:false;

   bool FilterHistM1=GetGlobalVariable(BtnFilterHistM1)==FILTER_ON?true:false;
   bool FilterHistM3=GetGlobalVariable(BtnFilterHistM3)==FILTER_ON?true:false;
   bool FilterHistW3=GetGlobalVariable(BtnFilterHistW3)==FILTER_ON?true:false;

   bool FilterCond3M=GetGlobalVariable(BtnFilterMa20Mo)==FILTER_ON?true:false;
   bool FilterCondMO=GetGlobalVariable(BtnFilterMa10Mo)==FILTER_ON?true:false;
   bool FilterCondW1=GetGlobalVariable(BtnFilterMa10W1)==FILTER_ON?true:false;
   bool FilterCondD1=GetGlobalVariable(BtnFilterMa10D1)==FILTER_ON?true:false;
   bool FilterCondH4=GetGlobalVariable(BtnFilterMa10H4)==FILTER_ON?true:false;

   bool FilterCondW20=GetGlobalVariable(BtnFilterCondW20)==FILTER_ON?true:false;
   bool FilterCondD20=GetGlobalVariable(BtnFilterD20)==FILTER_ON?true:false;

   bool FilterCondM383=GetGlobalVariable(BtnFilterCondM383)==FILTER_ON?true:false;
   bool FilterCondMoSeq=GetGlobalVariable(BtnFilterCondMoSeq)==FILTER_ON?true:false;
   bool FilterCondW1Seq=GetGlobalVariable(BtnFilterCondW1Seq)==FILTER_ON?true:false;
   bool FilterCondW1C3=GetGlobalVariable(BtnFilterCondW1C3)==FILTER_ON?true:false;
   bool FilterCondD1C2=GetGlobalVariable(BtnFilterCondD1C2)==FILTER_ON?true:false;
   bool FilterCondH4C3=GetGlobalVariable(BtnFilterCondH4C3)==FILTER_ON?true:false;
   bool FilterCondH4Sq=GetGlobalVariable(BtnFilterCondH4Sq)==FILTER_ON?true:false;
   bool FilterCondH4Ma50=GetGlobalVariable(BtnFilterCondH450)==FILTER_ON?true:false;
   bool Filter1BilVnd=GetGlobalVariable(BtnFilter1BilVnd)==FILTER_ON?true:false;
   bool Filter100BVnd=GetGlobalVariable(BtnFilter100BVnd)==FILTER_ON?true:false;

   bool IS_GROUP_NGANHANG=GetGlobalVariable("GROUP_"+GROUP_NGANHANG)==FILTER_ON;
   bool IS_GROUP_DAUKHI=GetGlobalVariable("GROUP_"+GROUP_DAUKHI)==FILTER_ON;
   bool IS_GROUP_CHUNGKHOAN=GetGlobalVariable("GROUP_"+GROUP_CHUNGKHOAN)==FILTER_ON;
   bool IS_GROUP_BATDONGSAN=GetGlobalVariable("GROUP_"+GROUP_BATDONGSAN)==FILTER_ON;
   bool IS_GROUP_DUOCPHAM=GetGlobalVariable("GROUP_"+GROUP_DUOCPHAM)==FILTER_ON;
   bool IS_GROUP_PHANBON=GetGlobalVariable("GROUP_"+GROUP_PHANBON)==FILTER_ON;
   bool IS_GROUP_THEP=GetGlobalVariable("GROUP_"+GROUP_THEP)==FILTER_ON;
   bool IS_GROUP_CONGNGHIEP=GetGlobalVariable("GROUP_"+GROUP_CONGNGHIEP)==FILTER_ON;
   bool IS_GROUP_MAYMAC=GetGlobalVariable("GROUP_"+GROUP_MAYMAC)==FILTER_ON;
   bool IS_GROUP_DIEN=GetGlobalVariable("GROUP_"+GROUP_DIEN)==FILTER_ON;
   bool IS_GROUP_DAVINCI=GetGlobalVariable("GROUP_"+GROUP_DAVINCI)==FILTER_ON;
   bool IS_GROUP_OTHERS=GetGlobalVariable("GROUP_"+GROUP_OTHERS)==FILTER_ON;

   int search_x=60*15, btn_heigh=18, btn_filter_heigh=18, row_01=25, row_02=2, btn_filter_width=30;
   create_TextInput(search_x,row_02,150,btn_filter_heigh);
   createButton(BtnSearchSymbol,"Search",  search_x+160, row_02,50,btn_filter_heigh,clrBlack,clrWhite,8);
   string fillterSymbol=GetTextInput();
   createButton(BtnFilterClear,"Clear",  search_x+220,row_02,50,btn_filter_heigh,clrBlack,clrWhite,8);
   createButton(BtnFilterTrading,"Trade",search_x+280,row_02,50,btn_filter_heigh,clrBlack,is_filter_trading?clrActiveBtn:clrWhite,8);
   createButton(BtnFilterToday,"Today?", search_x+340,row_02,50,btn_filter_heigh,clrBlack,clrWhite,8);

   double intPeriod = GetGlobalVariable(BtnOptionPeriod);
   if(intPeriod<0)
     {
      intPeriod = PERIOD_D1;
      SetGlobalVariable(BtnOptionPeriod,(double)intPeriod);
     }

   createButton(BtnOptionPeriod+"_3M",  "3M",10+0*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_M3 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_MN1", "Mo",10+1*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_MN1?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_W1",  "W1",10+2*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_W1 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_D1",  "D1",10+3*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_D1 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_H4",  "H4",10+4*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_H4 ?clrActiveBtn:clrWhite,7);
//createButton(BtnOptionPeriod+"_H1",  "H1",10+5*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_H1 ?clrActiveBtn:clrWhite,7);

   createButton(BtnSaveResult,   "Save",              10+5*(btn_filter_width+10)+55*0,chart_heigh,50,btn_filter_heigh,clrBlack,clrWhite,7);
   createButton(BtnLoadResult,   "Load",              10+5*(btn_filter_width+10)+55*1,chart_heigh,50,btn_filter_heigh,clrBlack,clrWhite,7);
   createButton(BtnMakeSymbolsJson, "symbols.json",10+5*(btn_filter_width+10)+55*2,chart_heigh,70,19,clrBlack,clrWhite,7);

   color clrW20=FilterCondW20?clrActiveBtn:clrLightGray;
   color clrD20=FilterCondD20?clrActiveBtn:clrLightGray;
   color clr3M=FilterCond3M?clrActiveBtn:clrLightGray;
   color clrMo=FilterCondMO?clrActiveBtn:clrLightGray;
   color clrW1=FilterCondW1?clrActiveBtn:clrLightGray;
   color clrD1=FilterCondD1?clrActiveBtn:clrLightGray;
   color clrH4=FilterCondH4?clrActiveBtn:clrLightGray;

   int x_start=2;
   count=0;
   createButton(BtnFilterVn30,"Vn30",    x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,is_vn30?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHnx30,"Hnx30",  x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,is_hnx30?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterCondM383,"#382",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondM383?clrActiveBtn:clrLightGray,8);

   count+=1;
   createButton(BtnFilterMa20Mo,"20M", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,clr3M,8);
   count+=1;
   createButton(BtnFilterMa10Mo,"10M", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,clrMo,8);
   count+=1;
   createButton(BtnFilterMa10W1,"10W", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,clrW1,8);
   count+=1;
   createButton(BtnFilterMa10H4,"10H4",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,clrH4,8);
   count+=1;

   count+=1;
   createButton(BtnFilterHistMo,"His.Mo",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistMo?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHistWx,"His.Wx",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistWx?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHistHx,"His.Hx",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistHx?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHistM3,"His.M3",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistM3?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHistM1,"His.M1",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistM1?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHistW3,"His.W3",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistW3?clrActiveBtn:clrLightGray,8);
   count+=1;

   count+=1;
   createButton(BtnFilterCondW1C3,"W.C3", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondW1C3?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterCondH4C3,"H4.C3",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondH4C3?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterCondH450,"H4.50",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondH4Ma50?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterCondMoSeq,"M.Seq", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondMoSeq?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterCondW1Seq,"W.Seq", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondW1Seq?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterCondH4Sq,"H4.051020",x_start+60*count,row_01,85,btn_filter_heigh,clrBlack,FilterCondH4Sq?clrActiveBtn:clrWhite,8);
   count+=1;
//--------------------------------------------------------------------------------------------------------
   count=0;
   x_start=2;
   createButton(BtnFilterFollow,"^ ^ Only",x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,is_only_follow?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_NGANHANG,GROUP_NGANHANG,     x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_NGANHANG?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_DAUKHI,GROUP_DAUKHI,         x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_DAUKHI?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_CHUNGKHOAN,GROUP_CHUNGKHOAN, x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_CHUNGKHOAN?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_BATDONGSAN,GROUP_BATDONGSAN, x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_BATDONGSAN?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_DUOCPHAM,GROUP_DUOCPHAM,     x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_DUOCPHAM?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_PHANBON,GROUP_PHANBON,       x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_PHANBON?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_THEP,GROUP_THEP,             x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_THEP?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_CONGNGHIEP,GROUP_CONGNGHIEP, x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_CONGNGHIEP?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_MAYMAC,GROUP_MAYMAC,         x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_MAYMAC?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_DIEN,GROUP_DIEN,             x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_DIEN?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_DAVINCI,GROUP_DAVINCI,       x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_DAVINCI?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_OTHERS,GROUP_OTHERS,         x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_OTHERS?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilter1BilVnd,"1b",x_start+60*count,row_02,20,btn_filter_heigh,clrBlack,Filter1BilVnd?clrActiveBtn:clrLightGray,8);
   createButton(BtnFilter100BVnd,"100b",x_start+60*count+25,row_02,30,btn_filter_heigh,clrBlack,Filter100BVnd?clrActiveBtn:clrLightGray,8);
   count+=1;

//--------------------------------------------------------------------------------------------------------
   x_start = (int)chart_width/2+200;
   createButton(BtnToutch_+"up_ck", "Up",   x_start+00,chart_heigh-3, 35,btn_filter_heigh,clrBlack,clrWhite,8);
   createButton(BtnToutch_+"dn_ck", "Dn",   x_start+45,chart_heigh-3, 35,btn_filter_heigh,clrBlack,clrWhite,8);

   createButton(BtnTrading_,     "Trading",      x_start+100,chart_heigh-3, 90,btn_filter_heigh,clrBlack,clrTrading,8);
   createButton(BtnFollowing_,   "Following",    x_start+200,chart_heigh-3, 90,btn_filter_heigh,clrBlack,clrFolowing,8);
   createButton(BtnClearChart,   "Clear Chart",  x_start+300,chart_heigh-3, 90,btn_filter_heigh,clrBlack,clrWhite,8);
   createButton(BtnCkTradingView,"Trading View", x_start+400,chart_heigh-3,100,btn_filter_heigh,clrBlack,clrWhite,8);

//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------

   string sorted_symbols_ck[];
   SortSymbols(sorted_symbols_ck);
   bool foundFillterSymbol=false;

   for(int i = 0; i< size_ck; i++)
     {
      string symbolCk = sorted_symbols_ck[i];
      if(symbolCk=="")
         continue;

      string tool_tip=get_tool_tip_ck(symbolCk);
      bool is_trading_this_symbol=GetGlobalVariable(BtnTrading_+symbolCk)==OPTION_FOLOWING;

      if(is_filter_trading && is_trading_this_symbol==false)
         continue;

      if(fillterSymbol!="" && (is_same_symbol(symbolCk,fillterSymbol)==false && is_same_symbol(tool_tip,fillterSymbol)==false))
         continue;

      if(IS_GROUP_NGANHANG && is_same_symbol(tool_tip,GROUP_NGANHANG)==false)
         continue;
      if(IS_GROUP_DAUKHI && is_same_symbol(tool_tip,GROUP_DAUKHI)==false)
         continue;
      if(IS_GROUP_CHUNGKHOAN && is_same_symbol(tool_tip,GROUP_CHUNGKHOAN)==false)
         continue;
      if(IS_GROUP_BATDONGSAN && is_same_symbol(tool_tip,GROUP_BATDONGSAN)==false)
         continue;
      if(IS_GROUP_DUOCPHAM && is_same_symbol(tool_tip,GROUP_DUOCPHAM)==false)
         continue;
      if(IS_GROUP_PHANBON && is_same_symbol(tool_tip,GROUP_PHANBON)==false)
         continue;
      if(IS_GROUP_THEP && is_same_symbol(tool_tip,GROUP_THEP)==false)
         continue;
      if(IS_GROUP_CONGNGHIEP && is_same_symbol(tool_tip,GROUP_CONGNGHIEP)==false)
         continue;
      if(IS_GROUP_MAYMAC && is_same_symbol(tool_tip,GROUP_MAYMAC)==false)
         continue;
      if(IS_GROUP_DIEN && is_same_symbol(tool_tip,GROUP_DIEN)==false)
         continue;
      if(IS_GROUP_DAVINCI && is_same_symbol(tool_tip,GROUP_DAVINCI)==false)
         continue;
      if(IS_GROUP_OTHERS && is_same_symbol(tool_tip,GROUP_OTHERS)==false)
         continue;


      bool is_folowing_this_symbol=is_trading_this_symbol || (GetGlobalVariable(BtnFollowing_+symbolCk)==OPTION_FOLOWING);

      if(is_only_follow)
         if(is_folowing_this_symbol==false)
            continue;

      if(is_vn30 && is_same_symbol(VN30,symbolCk)==false)
         continue;
      if(is_hnx30 && is_same_symbol(HNX30,symbolCk)==false)
         continue;

      string trend_ma20_mo, trend_ma10_mo, trend_hei_mo, trend_ma5_mo, low_hig_mo;
      int count_ma10_mo, count_hei_mo;
      double PERCENT_LOW, PERCENT_HIG;
      GetTrendFromFileCk(symbolCk,PERIOD_MN1,trend_ma20_mo, trend_ma10_mo, count_ma10_mo, trend_hei_mo, count_hei_mo,trend_ma5_mo,low_hig_mo,PERCENT_LOW,PERCENT_HIG);

      //if(is_trading_this_symbol==false)
        {
         if(Filter100BVnd && is_same_symbol(low_hig_mo, MORE_THAN_100_BIL_VND)==false)
            continue;

         if(FilterCondM383 && is_same_symbol(low_hig_mo,"#382")==false)
            continue;

         if(FilterCondMoSeq && is_same_symbol(low_hig_mo,STR_SEQ_BUY)==false) // || count_hei_w1<=2
            continue;

         if((trend_ma10_mo!="") && FilterCond3M && is_same_symbol(trend_ma20_mo,TREND_BUY)==false)
            continue;

         if(FilterHistMo && is_same_symbol(low_hig_mo, "{B")==false)
            continue;
         if(FilterHistM1 && is_same_symbol(low_hig_mo, "{B1}")==false)
            continue;
         if(FilterHistM3 && is_same_symbol(low_hig_mo, "{B1}")==false && is_same_symbol(low_hig_mo, "{B2}")==false  && is_same_symbol(low_hig_mo, "{B3}")==false)
            continue;
         if((trend_ma10_mo!="") && FilterCondMO && is_same_symbol(trend_ma10_mo,TREND_BUY)==false)
            continue;
        }

      string trend_ma20_w1, trend_ma10_w1, trend_hei_w1, trend_ma5_w1,low_hig_w1;
      int count_ma10_w1, count_hei_w1;
      double percent_low_w1, percent_hig_w1;
      GetTrendFromFileCk(symbolCk,PERIOD_W1,trend_ma20_w1, trend_ma10_w1, count_ma10_w1, trend_hei_w1, count_hei_w1,trend_ma5_w1,low_hig_w1,percent_low_w1,percent_hig_w1);

      //if(is_trading_this_symbol==false)
        {
         if((trend_ma10_w1!="") && FilterCondW1 && is_same_symbol(trend_ma10_w1,TREND_BUY)==false)
            continue;

         if(FilterCondW1C3 && !(count_ma10_w1<=3 && is_same_symbol(trend_ma10_w1,TREND_BUY)))
            continue;

         if(FilterCondW1Seq && is_same_symbol(low_hig_w1,STR_SEQ_BUY)==false)
            continue;

         if(FilterHistWx && is_same_symbol(low_hig_w1, "{B")==false)
            continue;

         if(FilterHistW3 && is_same_symbol(low_hig_w1, "{B1}")==false && is_same_symbol(low_hig_w1, "{B2}")==false  && is_same_symbol(low_hig_w1, "{B3}")==false)
            continue;
        }

      string trend_ma20_h4, trend_ma10_h4, trend_hei_h4, trend_ma5_h4,low_hig_h4;
      int count_ma10_h4, count_hei_h4;
      double percent_low_h4, percent_hig_h4;
      GetTrendFromFileCk(symbolCk,PERIOD_H4,trend_ma20_h4, trend_ma10_h4, count_ma10_h4, trend_hei_h4, count_hei_h4,trend_ma5_h4,low_hig_h4,percent_low_h4,percent_hig_h4);

      bool is_h4_seq_buy=is_same_symbol(low_hig_h4,STR_SEQ_BUY);
      bool is_h4_seq_sel=is_same_symbol(low_hig_h4,STR_SEQ_SEL);

      string msg_allow_trade="";
      if(is_folowing_this_symbol && is_h4_seq_buy)
         msg_allow_trade="Allow BUY "+symbolCk;

      if(msg_allow_trade != "" && allow_PushMessage(symbolCk,FILE_MSG_LIST_R1C1))
        {
         //Alert(get_vnhour()+" "+msg_allow_trade);
         PushMessage(msg_allow_trade,FILE_MSG_LIST_R1C1);
        }

      string msg_exit="";

      if(msg_exit == "" && is_trading_this_symbol && is_same_symbol(low_hig_w1, "{B")==false)
         msg_exit="His.W SELL "+symbolCk;

      if(msg_exit == "" && is_folowing_this_symbol && is_h4_seq_sel)
         msg_exit="Seq SELL "+symbolCk;

      if(msg_exit != "" && allow_PushMessage(symbolCk,FILE_MSG_LIST_R1C2))
        {
         Alert(get_vnhour()+" "+msg_exit);
         PushMessage(msg_exit,FILE_MSG_LIST_R1C2);
        }


      if(FilterCondH4Ma50 && is_same_symbol(low_hig_h4,MASK_TOUCH_MA50)==false)
         continue;


      bool is_alert_weekly= (is_same_symbol(trend_ma10_w1,TREND_BUY) && count_ma10_w1<=3);
      bool is_exist_now=false;
      bool is_exist_by_heiken=false;


      //if(is_trading_this_symbol==false)
        {
         if(FilterCondH4C3 && !(count_ma10_h4<=3 && is_same_symbol(trend_ma10_h4,TREND_BUY)))  //|| count_hei_h4<=3
            continue;

         if((trend_ma10_h4!="") && FilterCondH4 && is_same_symbol(trend_ma10_h4,TREND_BUY)==false)
            continue;

         if(FilterCondH4Sq && is_h4_seq_buy==false)
            continue;

         if(FilterHistHx && is_same_symbol(low_hig_h4, "{B")==false)
            continue;

         if(Filter1BilVnd && is_same_symbol(low_hig_h4, LESS_THAN_1_BIL_VND)==false)
            continue;
        }

      if(is_trading_this_symbol && is_same_symbol(trend_hei_w1, TREND_SEL))
         is_exist_by_heiken=true;
      if(is_trading_this_symbol && is_same_symbol(trend_ma10_h4, TREND_SEL) && is_same_symbol(trend_ma10_w1, TREND_SEL) && is_same_symbol(trend_hei_w1, TREND_SEL))
         is_exist_now=true;
      bool allow_trade_h4=is_same_symbol(trend_ma10_w1, TREND_BUY) || is_same_symbol(trend_hei_w1, TREND_BUY);

      //if(count_btn!=112)
      color clrLinkCk=clrWhite;
      string lblCkLink="...";
      if(is_h4_seq_buy)
        {
         lblCkLink="3B";
         clrLinkCk=clrActiveBtn;
        }

      if(is_h4_seq_sel)
        {
         lblCkLink="3S";
         clrLinkCk=clrActiveSell;
         if(is_trading_this_symbol)
            is_exist_now=true;
        }

      string btn_label=symbolCk;

      bool is_start_mo=(is_same_symbol(trend_ma10_mo,TREND_BUY) && count_ma10_mo<=3);
      is_start_mo|=is_same_symbol(trend_ma5_mo,TREND_BUY) && is_same_symbol(trend_hei_mo,TREND_BUY) && (count_hei_mo<=3);

      color text_color=clrBlack;
      color bg_color=clrHoneydew;
      if(is_same_symbol(low_hig_mo+low_hig_w1, "{S"))
         bg_color=clrMistyRose;

      bg_color=clicked_ck_index==i?clrYellow:bg_color;

      count_btn+=1;
      int col_index = (count_btn-1) / BTN_PER_COLUMN;
      int y_dimention = y_dimention_base + 22*((count_btn-1) % BTN_PER_COLUMN);

      if(fillterSymbol != "" && count_btn>0)
         foundFillterSymbol=true;

      string btn_d1_name=BtnCkD1_+symbolCk;
      if(is_folowing_this_symbol)
         createButton("BtnCkFolowing"+symbolCk,"^ ^",column[col_index]-19,y_dimention,btn_heigh-2,btn_heigh,clrBlack,clrActiveBtn);

      //if(count>110 && count<114)
      //   Alert(count, "  ", symbolCk);

      count+=1;
      StringReplace(btn_label,"HOSE_","");
      StringReplace(btn_label,"HNX_","");
      StringReplace(btn_label,"UPCOM_","");
      StringReplace(btn_label,"UPCOM_","");
      StringReplace(low_hig_mo,"#382","");
      StringReplace(low_hig_mo,"|50|","");
      StringReplace(low_hig_mo,STR_SEQ_BUY,"");
      StringReplace(low_hig_mo,STR_SEQ_SEL,"");
      StringReplace(low_hig_mo,MORE_THAN_100_BIL_VND,"");
      for(int b=1;b<=25;b++)
        {
         StringReplace(low_hig_mo,"  "," ");
         StringReplace(low_hig_mo,"{B"+IntegerToString(b)+"}","");
         StringReplace(low_hig_mo,"{S"+IntegerToString(b)+"}","");
        }

      createButton(btn_d1_name,append1Zero(count_btn)+". "+btn_label+low_hig_mo,column[col_index],y_dimention,btn_width,btn_heigh,text_color,bg_color,6);

      bool is_vn30=is_same_symbol(VN30,symbolCk);
      bool is_hnx30=is_same_symbol(HNX30,symbolCk);

      ObjectSetString(0,btn_d1_name,OBJPROP_TOOLTIP,(is_vn30?"(VN30) ":is_hnx30?"(HNX30) ":"")+tool_tip);
      if(i==clicked_ck_index)
         ObjectSetString(0,btn_d1_name,OBJPROP_FONT,"Arial Bold");

      if(i==clicked_ck_index)
        {
         TestReadAllDataFromFile(symbolCk,PERIOD_MN1,0);
         TestReadAllDataFromFile(symbolCk,PERIOD_W1, 1);
         TestReadAllDataFromFile(symbolCk,PERIOD_H4, 1);

         clrFolowing=GetGlobalVariable(BtnFollowing_+symbolCk)==OPTION_FOLOWING?clrActiveBtn:clrLightGray;
         clrTrading=is_trading_this_symbol?clrActiveBtn:clrLightGray;
        }

      if(is_trading_this_symbol)
         createButton(BtnCkD1_ + symbolCk+"_","",column[col_index],y_dimention+17,btn_width,3,clrBlack,clrBlue);
     }

//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
   CreateMessagesBtn(BtnMsgR1C1_);
   CreateMessagesBtn(BtnMsgR1C2_);

   if(fillterSymbol != "" && foundFillterSymbol == false)
     {
      string symbolCk = FindFiles(fillterSymbol);
      if(symbolCk!="")
         ReDrawChartCk(symbolCk);
      else
         Alert("Not found: "+fillterSymbol);
     }

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FindFiles(string keyword)
  {
   string symbol_target = "";

   string filename = "";
   long handle = 0;
   int count = 0;

   handle = FileFindFirst("*.*", filename); // Dùng pattern đơn giản
   if(handle != INVALID_HANDLE)
     {
      Print("Danh sách các tệp trong thư mục Files:");
      do
        {
         if(filename != "" && is_same_symbol(filename,"_"+keyword+"_") && is_same_symbol(filename,"_MONTHLY.txt"))
           {
            //Print(++count, ". ", filename);
            symbol_target = filename;
            StringReplace(symbol_target,"_MONTHLY.txt","");
            break;
           }
        }
      while(FileFindNext(handle, filename));

      FileFindClose(handle);
     }

   return symbol_target;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DrawChartAndSetGlobal(string symbolUsdt,ENUM_TIMEFRAMES TF
                             ,string &scale_open_times[],string &opens[],string &closes[],string &lows[],string &highs[],string &volumes[],string &candle_times[], int chart_idx)
  {
   string trend_found="";
   CandleData candleArray[];
   double cur_close_0 = get_arr_heiken_binance(symbolUsdt,candleArray,scale_open_times,opens,closes,lows,highs,volumes);
   int _digits=cur_close_0>1000?1:cur_close_0>100?3:5;
//--------------------------------------------------------------------------------------------------------
   string prefix="DCASG_"+get_time_frame_name(TF);
   DeleteAllObjectsWithPrefix(prefix);

   if(GetGlobalVariable(BtnFollowing_+symbolUsdt)==OPTION_FOLOWING)
      ObjectSetInteger(0,BtnFollowing_,OBJPROP_BGCOLOR,clrActiveBtn);
   else
      ObjectSetInteger(0,BtnFollowing_,OBJPROP_BGCOLOR,clrLightGray);

//--------------------------------------------------------------------------------------------------------
   double real_lowest=DBL_MAX,real_higest=0.0;
   int size_d1 =(int)MathMin(ArraySize(candleArray)-9, NUM_CANDLE_DRAW);
   for(int i = 0; i < size_d1; i++)
     {
      double low=candleArray[i].low;
      double hig=candleArray[i].high;
      if((i==0) || (real_lowest==0) || (real_lowest>low))
         if(low>0)
            real_lowest=low;
      if((i==0) || (real_higest==0) || (real_higest<hig))
         real_higest=hig;
     }

   double btc_price_high = GetGlobalVariable(BTC_PRICE_HIG);
   double btc_price_low = GetGlobalVariable(BTC_PRICE_LOW);
   double haft_chart = (btc_price_high + btc_price_low)/2.0;

   int _width=0;
   bool tool_tip_top=false;
     {
      if(TF==PERIOD_W1)
        {
         tool_tip_top=true;
         btc_price_low=haft_chart;
        }

      if(TF==PERIOD_H4)
         btc_price_high=haft_chart;

      if(TF==PERIOD_H4)
         _width=3;
     }

   double btc_mid = (btc_price_high + btc_price_low) /2.0;

   double ada_price_high = real_higest; // Giá cao nhất hiện tại của ADA
   double ada_price_low = real_lowest;  // Giá thấp nhất hiện tại của ADA
   double ada_mid = (ada_price_high + ada_price_low) / 2.0;

// 2. Tính hệ số chuẩn hóa
   double btc_range = btc_price_high - btc_price_low;
   double ada_range = ada_price_high - ada_price_low;
   double normalization_factor = btc_range/ada_range;
   double offset = 0;

   int __sub;
   double __price;
   datetime __time900, __time1500;
   datetime add_time=GLOBAL_TIME_OF_ONE_CANDLE;//(datetime)(candleArray[0].time-candleArray[1].time);
   ChartXYToTimePrice(0,950, 70,__sub, __time900,__price);
   ChartXYToTimePrice(0,1800, 70,__sub, __time1500,__price);

   datetime shift=TimeCurrent()-__time900; // add_time*(NUM_CANDLE_DRAW+11);
   if(chart_idx>0)
      shift=TimeCurrent()-__time1500; // add_time*6;

   if(ada_range>0 && btc_range>0)
     {
      double PERCENT=0;
      double lowest=DBL_MAX,higest=0.0;

      datetime start_time=candleArray[size_d1].time  -shift;
      datetime end_time=candleArray[0].time+add_time -shift;
      datetime tool_tip_time=candleArray[(int)(size_d1*2/3)].time-shift;

      double volumeArray[];
      int size = ArraySize(candleArray);
      ArrayResize(volumeArray, size);
      for(int i = 0; i < size; i++)
         volumeArray[i] = candleArray[i].volume;

      double max_volume = 0;
      for(int i = 0; i < size_d1; i++)
        {
         if(max_volume<candleArray[i].volume)
            max_volume=candleArray[i].volume;

         double ma05_i0=(candleArray[i].ma05-  ada_mid)*normalization_factor + btc_mid +offset;
         double ma05_i1=(candleArray[i+1].ma05-ada_mid)*normalization_factor + btc_mid +offset;

         double ma10_i0=(candleArray[i].ma10-  ada_mid)*normalization_factor + btc_mid +offset;
         double ma10_i1=(candleArray[i+1].ma10-ada_mid)*normalization_factor + btc_mid +offset;

         double ma20_i0=(candleArray[i].ma20-  ada_mid)*normalization_factor + btc_mid +offset;
         double ma20_i1=(candleArray[i+1].ma20-ada_mid)*normalization_factor + btc_mid +offset;

         double ma50_i0=(candleArray[i].ma50-  ada_mid)*normalization_factor + btc_mid +offset;
         double ma50_i1=(candleArray[i+1].ma50-ada_mid)*normalization_factor + btc_mid +offset;


         double open= (candleArray[i].open-    ada_mid)*normalization_factor + btc_mid +offset;
         double close=(candleArray[i].close-   ada_mid)*normalization_factor + btc_mid +offset;
         double low= (candleArray[i].low-      ada_mid)*normalization_factor + btc_mid +offset;
         double high= (candleArray[i].high-    ada_mid)*normalization_factor + btc_mid +offset;

         if(i<5 && ma50_i1>0 && ma50_i0>0)
            create_trend_line(prefix+"Ma50_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma50_i1,
                              (i==0?candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma50_i0,clrGray,STYLE_SOLID,3);

         if(i<10 && ma20_i1>0 && ma20_i0>0)
            create_trend_line(prefix+"Ma20_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma20_i1,
                              (i==0?candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma20_i0,clrBlue,STYLE_SOLID,2);//TF==PERIOD_MN1&&ma10_i0>ma20_i0?

         if(i<17 && ma10_i1>0 && ma10_i0>0)
           {
            create_trend_line(prefix+"Ma10_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma10_i1,
                              (i==0?candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma10_i0,clrFireBrick,STYLE_SOLID,2);
           }

         string trend=candleArray[i].trend_heiken;
         color clrBody=is_same_symbol(trend,TREND_BUY)?clrTeal:clrBlack;

         create_heiken_candle(prefix+"Body_heiken_"+appendZero100(i)
                              ,candleArray[i].time+TIME_OF_ONE_H4_CANDLE*1-shift
                              ,candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE-TIME_OF_ONE_H4_CANDLE*3-shift
                              ,open,close,low,high,clrBody,false,1,(string)candleArray[i].count_heiken);

         if(ma05_i1>0 && ma05_i0>0)
            create_trend_line(prefix+"Ma05_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma05_i1,
                              (i==0?candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma05_i0,clrDimGray,STYLE_SOLID,2);

         if(lowest>low)
           {
            lowest=low;
            PERCENT=NormalizeDouble(100*(candleArray[0].close-candleArray[i].low)/candleArray[i].low,2);
           }
         if(higest<high)
           {
            higest=high;
           }

         if(i==0)
           {
            if(candleArray[0].ma50>0)
              {
               double percent = (MathAbs(cur_close_0 - candleArray[0].ma50) / cur_close_0)*100.0;
               if(cur_close_0 > candleArray[0].ma50)
                  percent = -percent;

               double ma50_i0=(candleArray[i].ma50-ada_mid)*normalization_factor + btc_mid+offset;
               create_label_simple(prefix+"Ma50",DoubleToString(candleArray[0].ma50,_digits)+" ("+DoubleToString(percent,1)+"%)",ma50_i0,clrBlack,candleArray[0].time-shift);
              }

            if(candleArray[0].ma20>0)
              {
               double percent = (MathAbs(cur_close_0 - candleArray[0].ma20) / cur_close_0)*100.0;
               if(cur_close_0 > candleArray[0].ma20)
                  percent = -percent;

               double ma20_i0=(candleArray[i].ma20-ada_mid)*normalization_factor + btc_mid+offset;
               create_label_simple(prefix+"Ma20",DoubleToString(candleArray[0].ma20,_digits)+" ("+DoubleToString(percent,1)+"%)",ma20_i0,clrBlack,candleArray[0].time-shift);
              }

            if(candleArray[0].ma10>0)
              {
               double percent = (MathAbs(cur_close_0 - candleArray[0].ma10) / cur_close_0)*100.0;
               if(cur_close_0 > candleArray[0].ma10)
                  percent = -percent;

               double ma10_i0=(candleArray[i].ma10-ada_mid)*normalization_factor + btc_mid+offset;
               create_label_simple(prefix+"Ma10",DoubleToString(candleArray[0].ma10,_digits)+" ("+DoubleToString(percent,1)+"%)",ma10_i0,clrBlack,candleArray[0].time-shift);
              }
           }
        }

      double cur_price= cur_close_0;
      double cur_mid=(real_higest-real_lowest)/2;
      double percent_drop = ((cur_price - real_lowest) / cur_price)  * 100.0;  // Tính % giảm giá từ giá hiện tại xuống real_lowest
      double percent_rise = ((real_higest - cur_price) / cur_price)  * 100.0; // Tính % tăng giá từ giá hiện tại lên real_higest
      double percent_up   = ((cur_price - real_lowest) / real_lowest)* 100.0;
      double fibo_0_118 = lowest + (higest - lowest) * 0.118;
      double fibo_0_236 = lowest + (higest - lowest) * 0.236;
      double fibo_0_382 = lowest + (higest - lowest) * 0.382;
      double fibo_0_500 = lowest + (higest - lowest) * 0.500;
      double fibo_0_618 = lowest + (higest - lowest) * 0.618;
      double fibo_0_764 = lowest + (higest - lowest) * 0.764;
      double fibo_1_236 = lowest + (higest - lowest) * 1.236;
      double fibo_1_236_= lowest - (higest - lowest) * 0.236;

      double sai_so=lowest*0.025;
      double price=(cur_close_0-ada_mid)*normalization_factor + btc_mid+offset;
      double PERCENT_HIG=NormalizeDouble(PERCENT*(higest-price)/(price-lowest),2);
      color clrPercent = PERCENT_HIG/PERCENT>2?clrBlue:PERCENT_HIG/PERCENT>1?clrBlack:clrRed;

      for(int i = 0; i < size_d1-2; i++)
         create_label_simple(prefix+"Ma10_Index" +appendZero100(i), "  "+getShortName(candleArray[i].trend_by_ma10)+"."+(string)candleArray[i].count_ma10
                             ,fibo_0_118
                             ,candleArray[i].trend_by_ma10==TREND_BUY?clrBlue:clrRed,candleArray[i].time-shift);

      if(is_same_symbol(symbolUsdt,"_"))
        {
         bool is_vn30=is_same_symbol(VN30,symbolUsdt);

         int _sub_windows;
         datetime _time;
         double _price;

         if(tool_tip_top)
            if(ChartXYToTimePrice(0,10,60,_sub_windows,_time,_price))
               create_label_simple(prefix+"TOOLTIP",get_time_frame_name(TF)+"    "+(is_vn30?"(VN30) ":"")+get_tool_tip_ck(symbolUsdt),_price,clrBlack,tool_tip_time);

         if(!tool_tip_top)
           {
            int chart_heigh=(int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));
            if(ChartXYToTimePrice(0,10,chart_heigh-35,_sub_windows,_time,_price))
               create_label_simple(prefix+"TOOLTIP",get_time_frame_name(TF)+"    "+(is_vn30?"(VN30) ":"")+get_tool_tip_ck(symbolUsdt),_price,clrBlack,tool_tip_time);

           }
        }

      if(false)//TF!=PERIOD_H4
        {
         string lable=symbolUsdt+" (Ma10) "+(candleArray[0].trend_by_ma10)+"."+(string)candleArray[0].count_ma10
                      + " (Ma5) "+(candleArray[0].close>candleArray[0].ma05?TREND_BUY:TREND_SEL)
                      + " (05vs10) "+(candleArray[0].ma05>candleArray[0].ma10?TREND_BUY:TREND_SEL)
                      ;
         lable+=" (Hei) "+(candleArray[0].trend_heiken)+"."+(string)candleArray[0].count_heiken;
         StringReplace(lable,"USDT","");
         create_label_simple(prefix+"Ma10D",lable,higest-sai_so,is_same_symbol(candleArray[0].trend_by_ma10,TREND_BUY)?clrBlue:clrRed,tool_tip_time);
        }

      if(TF!=PERIOD_H4)
         create_trend_line(prefix+"HIGEST",    start_time+add_time*3,higest,end_time,higest,clrRed,STYLE_SOLID,1,false, false);

      create_trend_line(prefix+"LOWEST",    start_time+add_time*3,lowest,end_time,lowest,clrRed,STYLE_SOLID,1,false, false);


      create_trend_line(prefix+"fibo_0_236",start_time+add_time*3,fibo_0_236,end_time,fibo_0_236,clrGray,STYLE_DOT,1,false,false);
      create_trend_line(prefix+"fibo_0_382",start_time+add_time*3,fibo_0_382,end_time,fibo_0_382,clrRed,STYLE_DOT,1,false,false);
      create_trend_line(prefix+"fibo_0_500",start_time+add_time*3,fibo_0_500,end_time,fibo_0_500,clrRed,STYLE_SOLID,1,false,false);
      create_trend_line(prefix+"fibo_0_618",start_time+add_time*3,fibo_0_618,end_time,fibo_0_618,clrRed,STYLE_DOT,1, false,false);
      create_trend_line(prefix+"fibo_0_764",start_time+add_time*3,fibo_0_764,end_time,fibo_0_764,clrRed,STYLE_DOT,1,false,false);

      create_label_simple(prefix+"0.118","0.118    " + DoubleToString(CalculateRealValue(fibo_0_118,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_118,clrBlack,start_time);
      create_label_simple(prefix+"0.236","0.236    " + DoubleToString(CalculateRealValue(fibo_0_236,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_236,clrBlack,start_time);
      create_label_simple(prefix+"0.382","0.382    " + DoubleToString(CalculateRealValue(fibo_0_382,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_382,clrBlack,start_time);
      create_label_simple(prefix+"0.500","0.500    " + DoubleToString(CalculateRealValue(fibo_0_500,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_500,clrBlack,start_time);
      create_label_simple(prefix+"0.618","0.618    " + DoubleToString(CalculateRealValue(fibo_0_618,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_618,clrBlack,start_time);
      create_label_simple(prefix+"0.764","0.764    " + DoubleToString(CalculateRealValue(fibo_0_764,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_764,clrBlack,start_time);

      if(TF!=PERIOD_H4)
        {
         create_trend_line(prefix+"fibo_1_23+",start_time+add_time*3,fibo_1_236, end_time,fibo_1_236, clrGray,STYLE_DOT,1,false,false);
         create_label_simple(prefix+"1.236","1.236    " + DoubleToString(CalculateRealValue(fibo_1_236,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_1_236+sai_so,clrBlack,start_time);
        }

      create_label_simple(prefix+"Low%",
                          "Low: "+DoubleToString(real_lowest,_digits) + " (-" + DoubleToString(percent_drop,1) +"%)"
                          ,lowest+sai_so,clrRed,start_time);

      create_label_simple(prefix+"Hig%",
                          "Hig: " +DoubleToString(real_higest,_digits) + " (+" + (string)DoubleToString(percent_rise,1)+"%)"
                          ,TF!=PERIOD_H4?higest:higest-sai_so*2,clrBlue,start_time);

      create_trend_line(prefix+"_close_0",start_time,price,end_time+add_time,price,clrBlue,STYLE_DOT,1,false,false);
      create_label_simple(prefix+"cur_close_0","   "+DoubleToString(cur_close_0,_digits) + " (+"+ DoubleToString(percent_up,1)+"%)",price,clrBlack,end_time+add_time);
      //------------------------------------------------------------------
      //------------------------------------------------------------------
      //------------------------------------------------------------------
      double chart_height = btc_price_high - btc_price_low;
      double start_price = btc_price_low - chart_height*0.00;
      double volume_to_price_ratio = (TF!=PERIOD_H4)?(chart_height*0.1/max_volume):(chart_height*0.35/max_volume);

      int count_vol=0;
      double total_volume=0;
      for(int i = size_d1-2; i >=0 ; i--)
        {
         string volume_name = prefix +"VolumeBar_"+ appendZero100(i);
         double price_height = candleArray[i].volume * volume_to_price_ratio;
         datetime draw_time=candleArray[i].time-shift;

         if(max_volume>1)
           {
            create_heiken_candle(volume_name
                                 ,candleArray[i].time+TIME_OF_ONE_H4_CANDLE*7-shift
                                 ,candleArray[i].time-TIME_OF_ONE_H4_CANDLE*10+GLOBAL_TIME_OF_ONE_CANDLE-shift
                                 ,start_price,start_price+price_height,start_price,start_price+price_height
                                 ,candleArray[i].count_ma10<=1 && is_same_symbol(candleArray[i].trend_by_ma10,TREND_BUY)?clrActiveBtn:clrLightGray,true,1,"");

            if(i<=20)
              {
               count_vol+=1;
               total_volume+= candleArray[i].volume;

               if(TF==PERIOD_H4)
                 {
                  double billion = candleArray[i].volume*candleArray[i].close/VOL_1BILLION_VND; //Tỷ VND
                  create_label_simple(prefix+"_billion_"+ appendZero100(i),DoubleToString(billion,1),start_price+price_height,clrBlack, candleArray[i].time+TIME_OF_ONE_H4_CANDLE*7-shift,6);

                  if(i<7)
                    {
                     double pre_avg_volume = start_price+volume_to_price_ratio*cal_MA(volumeArray, 10, i+1);
                     double avg_volume = start_price+volume_to_price_ratio*cal_MA(volumeArray, 10, i);

                     create_trend_line(prefix+"_avg_vol" + append1Zero(i)
                                       ,candleArray[i+1].time-TIME_OF_ONE_H4_CANDLE*10+GLOBAL_TIME_OF_ONE_CANDLE-shift,pre_avg_volume
                                       ,candleArray[i].time-TIME_OF_ONE_H4_CANDLE*10+GLOBAL_TIME_OF_ONE_CANDLE-shift,avg_volume,
                                       clrRed,STYLE_SOLID,1);
                    }
                 }

               if(i==0)
                 {
                  double avg_volume = (total_volume/count_vol)*candleArray[i].close/VOL_1BILLION_VND;//Tỷ VND

                  string lblAvgVol = " Avg "+DoubleToString(avg_volume,1)+" tỷ";
                  if(avg_volume<1)
                     lblAvgVol = " Avg "+DoubleToString(avg_volume,2)+" tỷ";

                  lblAvgVol+=" " + StringSubstr(candle_times[0], 0, 13)+"h";

                  create_label_simple(prefix+"_billion_avg_"+IntegerToString(count_vol)+"candles",lblAvgVol
                                      ,start_price+volume_to_price_ratio*avg_volume,clrBlack, candleArray[0].time+TIME_OF_ONE_H4_CANDLE*7+GLOBAL_TIME_OF_ONE_CANDLE-shift,6);
                 }
              }
           }
        }

      double closeArray[];
      datetime timeFrArr[], timeToArr[];
      //int size = ArraySize(candleArray);
      ArrayResize(closeArray, size);
      ArrayResize(timeFrArr, size);
      ArrayResize(timeToArr, size);

      for(int i = 0; i < size-10; i++)
        {
         closeArray[i] = candleArray[i].close;
         timeFrArr[i] = candleArray[i].time+TIME_OF_ONE_H4_CANDLE*7-shift;
         timeToArr[i] = candleArray[i].time-TIME_OF_ONE_H4_CANDLE*10+GLOBAL_TIME_OF_ONE_CANDLE-shift;
        }

      double hist_range=btc_range*0.05;
      string prefix=get_time_frame_name(TF)+"_";

      DrawAndCountHistogram(prefix, closeArray, timeFrArr, timeToArr, true, btc_price_low-hist_range, btc_price_low+hist_range);
     }

   return trend_found;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DrawAndCountHistogram(string prefix, const double &closeArray[], datetime &timeFrArr[], datetime &timeToArr[], bool allow_draw, double from=50000, double to=60000)
  {
   DeleteAllObjectsWithPrefix(prefix + "Hist_");

   int SHORT_EMA_PERIOD = 12;
   int LONG_EMA_PERIOD = 26;
   int SIGNAL_PERIOD = 9;
   int n = ArraySize(closeArray);

   if(n < LONG_EMA_PERIOD)
     {
      //Print("Không đủ dữ liệu để vẽ MACD");
      //return "";
     }

   double macdValues[], signalValues[], histogramValues[];
   ArrayResize(macdValues, n);
   ArrayResize(signalValues, n);
   ArrayResize(histogramValues, n);

// Tính MACD từ phần tử cuối về đầu
   for(int i = n-1; i >= 0; i--)
     {
      double emaShort = CalculateEMA(closeArray, SHORT_EMA_PERIOD, i);
      double emaLong = CalculateEMA(closeArray, LONG_EMA_PERIOD, i);
      macdValues[i] = emaShort - emaLong;
      //Print("macdValues["+(string)i+"]"+(string)macdValues[i]);
     }

// Tính Signal Line (EMA của MACD)
   for(int i = n - 1; i >= 0; i--)
     {
      signalValues[i] = CalculateEMA(macdValues, SIGNAL_PERIOD, i);
      histogramValues[i] = macdValues[i] - signalValues[i];
     }

// Xác định giá trị min/max cho scale
// Tìm min/max cho scale
   double minVal = FindMinValue(macdValues);
   minVal = MathMin(minVal, MathMin(FindMinValue(signalValues), FindMinValue(histogramValues)));

   double maxVal = FindMaxValue(macdValues);
   maxVal = MathMax(maxVal, MathMax(FindMaxValue(signalValues), FindMaxValue(histogramValues)));

   double mid = (from + to) / 2.0;
   datetime shift = allow_draw? timeFrArr[1]-timeFrArr[2]:0;

   string trendArrs[];
   for(int i = MathMin(n-1,21); i > 0; i--)
     {
      if(macdValues[i] == EMPTY_VALUE || signalValues[i] == EMPTY_VALUE)
         continue;

      double scaled_macd = scaleValue(macdValues[i], minVal, maxVal, from, to);
      double scaled_signal = scaleValue(signalValues[i], minVal, maxVal, from, to);
      double scaled_hist = mid+scaled_macd-scaled_signal;

      if(allow_draw)
        {
         color clrColor = mid>scaled_hist?clrFireBrick:clrTeal;
         string hist_name = prefix + "Hist_" + IntegerToString(i);
         create_heiken_candle(hist_name
                              ,timeFrArr[i]+shift,timeToArr[i]+shift
                              ,mid,scaled_hist
                              ,MathMin(mid,scaled_hist)
                              ,MathMax(mid,scaled_hist), clrColor,true,1);

         create_trend_line(hist_name+"_zero_", timeFrArr[i]+shift, mid, timeFrArr[i-1]+shift, mid, clrColor, STYLE_SOLID,1);
        }

      int idx = ArraySize(trendArrs);
      ArrayResize(trendArrs,idx+1);
      trendArrs[idx]=mid>scaled_hist?TREND_SEL:TREND_BUY;
     }

   ArrayReverse(trendArrs);

// Đếm số lượng BUY/SELL cho từng item
   int countArr[];  // Mảng lưu kết quả đếm
   ArrayResize(countArr, ArraySize(trendArrs));
   for(int i = 0; i < ArraySize(trendArrs); i++)
     {
      int count = 0;
      string currentTrend = trendArrs[i];

      // Đếm liên tiếp từ vị trí hiện tại trở về trước
      for(int j = i; j < ArraySize(trendArrs); j++)
        {
         if(trendArrs[j] == currentTrend)
            count++;
         else
            break;
        }

      countArr[i] = count;  // Gán giá trị đếm cho mảng
     }

   if(allow_draw)
      for(int i = ArraySize(countArr)-1; i >=0 ; i--)
        {
         string hist_name = prefix + "Hist_Count_" + IntegerToString(i);
         color clrColor = trendArrs[i]==TREND_SEL?clrRed:clrBlue;
         create_label_simple(hist_name, "  "+IntegerToString(countArr[i]), mid,clrColor, timeFrArr[i]);
        }

   if(ArraySize(countArr) > 0)
      return getShortName(trendArrs[0])+(string)countArr[0];

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(const double &prices[], int period, int index)
  {
   double k = 2.0 / (period + 1);
   double ema = prices[index];  // EMA khởi đầu là giá trị tại index
   for(int i = index - 1; i >= 0; i--)  // Lùi về phía trước
     {
      ema = prices[i] * k + ema * (1 - k);
     }
   return ema;
  }
// Hàm tìm giá trị nhỏ nhất, loại bỏ EMPTY_VALUE
double FindMinValue(const double &values[])
  {
   double minVal = DBL_MAX;
   for(int i = 0; i < ArraySize(values); i++)
     {
      if(values[i] != EMPTY_VALUE && values[i] < minVal)
         minVal = values[i];
     }
   return minVal;
  }

// Hàm tìm giá trị lớn nhất, loại bỏ EMPTY_VALUE
double FindMaxValue(const double &values[])
  {
   double maxVal = -DBL_MAX;
   for(int i = 0; i < ArraySize(values); i++)
     {
      if(values[i] != EMPTY_VALUE && values[i] > maxVal)
         maxVal = values[i];
     }
   return maxVal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Hàm scale giá trị với giới hạn [from, to]
double scaleValue(double value, double minVal, double maxVal, double from, double to)
  {
   if(maxVal == minVal)
      return (from + to) / 2.0;

   double scaledValue = from + (value - minVal) * (to - from) / (maxVal - minVal);

// Clamp giá trị trong khoảng from-to
   return MathMax(MathMin(scaledValue, to), from);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateRealValue(double fake_value, double btc_mid, double normalization_factor, double ada_mid, double offset)
  {
   if(normalization_factor == 0.0) // Tránh lỗi chia cho 0
     {
      Print("Error: Normalization factor is zero.");
      return 0.0;
     }

// Tính lại giá trị thực từ giá trị giả có offset
   double open_real = ((fake_value - btc_mid - offset) / normalization_factor) + ada_mid;
   return open_real;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSelectedSymbolCk(string symbolCk)
  {
   string symbolCk_=symbolCk;
   StringReplace(symbolCk_,":","_");

   string sorted_symbols_ck[];
   SortSymbols(sorted_symbols_ck);

   int size = ArraySize(sorted_symbols_ck);
   for(int i=0;i<size;i++)
     {
      if(is_same_symbol(symbolCk_,sorted_symbols_ck[i]) || symbolCk_==sorted_symbols_ck[i])
        {
         SetGlobalVariable(CLICKED_SYMBOL_CK_INDEX,(double)i);
         printf("CK index: "+(string)i);
         break;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReDrawChartCk(string symbolCk)
  {
   string sorted_symbols_ck[];
   SortSymbols(sorted_symbols_ck);

   int size_ck =ArraySize(sorted_symbols_ck);
   for(int i = 0; i< size_ck; i++)
     {
      string symbol=sorted_symbols_ck[i];
      string btn_d1_name=BtnCkD1_+symbol;
      int bg_color = (int)ObjectGetInteger(0,btn_d1_name,OBJPROP_BGCOLOR);
      if(bg_color == (int)clrYellow)
         ObjectSetInteger(0,btn_d1_name,OBJPROP_BGCOLOR,clrLightGray);
     }

   DeleteAllObjectsWithPrefix("DCASG_");

   SetSelectedSymbolCk(symbolCk);
   TestReadAllDataFromFile(symbolCk,PERIOD_MN1,0);
   TestReadAllDataFromFile(symbolCk,PERIOD_W1, 1);
   TestReadAllDataFromFile(symbolCk,PERIOD_H4, 1);

   ObjectSetInteger(0,BtnCkD1_+symbolCk,OBJPROP_BGCOLOR,clrYellow);

   color clrTrading=GetGlobalVariable(BtnTrading_+symbolCk)==OPTION_FOLOWING?clrActiveBtn:clrLightGray;
   ObjectSetInteger(0,BtnTrading_,OBJPROP_BGCOLOR,clrTrading);

   color clrFolowing=GetGlobalVariable(BtnFollowing_+symbolCk)==OPTION_FOLOWING?clrActiveBtn:clrLightGray;
   ObjectSetInteger(0,BtnFollowing_,OBJPROP_BGCOLOR,clrFolowing);

   string tool_tip=get_tool_tip_ck(symbolCk);

   if(StringFind(tool_tip, GROUP_PHANBON)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_PHANBON,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_PHANBON,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_PHANBON)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_PHANBON,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_PHANBON,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_NGANHANG)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_NGANHANG,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_NGANHANG,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_CHUNGKHOAN)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_CHUNGKHOAN,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_CHUNGKHOAN,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_BATDONGSAN)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_BATDONGSAN,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_BATDONGSAN,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_DUOCPHAM)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_DUOCPHAM,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_DUOCPHAM,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_DAUKHI)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_DAUKHI,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_DAUKHI,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_THEP)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_THEP,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_THEP,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_CONGNGHIEP)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_CONGNGHIEP,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_CONGNGHIEP,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_MAYMAC)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_MAYMAC,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_MAYMAC,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_DIEN)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_DIEN,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_DIEN,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_DAVINCI)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_DAVINCI,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_DAVINCI,OBJPROP_BGCOLOR,clrLightGray);

   if(StringFind(tool_tip, GROUP_OTHERS)>0)
      ObjectSetInteger(0,"GROUP_"+GROUP_OTHERS,OBJPROP_BGCOLOR,clrYellow);
   else
      ObjectSetInteger(0,"GROUP_"+GROUP_OTHERS,OBJPROP_BGCOLOR,clrLightGray);


   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsButtonExist(string symbolCk)
  {
   int total_objects = ObjectsTotal(0); // Đếm tổng số objects trên chart

   for(int i = 0; i < total_objects; i++)
     {
      string object_name = ObjectName(0, i); // Lấy tên object theo index

      if(is_same_symbol(object_name, BtnCkD1_) && is_same_symbol(object_name, symbolCk))
        {
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void do_clear_cond(string except="")
  {
   string file_path = TEXT_INPUT+".txt";
   ResetFile(file_path);

   int size= GlobalVariablesTotal();
   for(int i=0;i<size;i++)
     {
      string name = GlobalVariableName(i);
      if(is_same_symbol(name,"GROUP_") || is_same_symbol(name,"Filter"))
        {
         if(except=="")
            GlobalVariableSet(name,FILTER_NON);
         else
           {
            if(is_same_symbol(name,except)==false)
               GlobalVariableSet(name,FILTER_NON);
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void do_search()
  {
   string file_path = TEXT_INPUT+".txt";
   ResetFile(file_path);
   string text=GetTextInput();
   AppendToFile(file_path,text);

   if(text!="")
     {
      int size= GlobalVariablesTotal();
      for(int i=0;i<size;i++)
        {
         string name = GlobalVariableName(i);
         if(is_same_symbol(name,"GROUP_") || is_same_symbol(name,"Filter"))
           {
            GlobalVariableSet(name,FILTER_NON);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define VK_ENTER  13
#define VK_UP     38  // Mã phím mũi tên lên
#define VK_DOWN   40  // Mã phím mũi tên xuống
void OnChartEvent(const int     id,      // event ID
                  const long&   lparam,  // long type event parameter
                  const double& dparam,  // double type event parameter
                  const string& sparam    // string type event parameter
                 )
  {
   bool ck_updn=(id==CHARTEVENT_OBJECT_CLICK) && (is_same_symbol(sparam,BtnToutch_));

   if(id == CHARTEVENT_KEYDOWN || ck_updn)  // Kiểm tra sự kiện phím nhấn
     {
      int key = (int)lparam;    // Lấy mã phím

      Print("Sparam=",sparam," id=",id," lparam=",lparam," dparam=",dparam);

      if(key == VK_ENTER)
        {
         do_search();

         ObjectsDeleteAll(0);
         Draw_Buttons();
         return;
        }

        {
         string sorted_symbols_ck[];
         SortSymbols(sorted_symbols_ck);

         int size_ck =ArraySize(sorted_symbols_ck);
         int index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);

         bool ck_up=(id==CHARTEVENT_OBJECT_CLICK) && (is_same_symbol(sparam,BtnToutch_+"up_ck"));
         bool ck_dn=(id==CHARTEVENT_OBJECT_CLICK) && (is_same_symbol(sparam,BtnToutch_+"dn_ck"));

         if(key == VK_UP || ck_up)          // Phím mũi tên lên
           {
            index--;    // Giảm biến
            if(index<0)
               index=ArraySize(sorted_symbols_ck)-1;
            string symbolCk= sorted_symbols_ck[index];

            if(IsButtonExist(symbolCk)==false)
              {
               for(int idx=index;idx>0;idx--)
                 {
                  symbolCk = sorted_symbols_ck[idx];
                  if(IsButtonExist(symbolCk))
                    {
                     index=idx;
                     break;
                    }
                 }
              }

            Print("VK_UP: "+(string)index + "  "+ symbolCk);
            if(IsButtonExist(symbolCk))
              {
               SetGlobalVariable(CLICKED_SYMBOL_CK_INDEX,(double)index);
               ReDrawChartCk(symbolCk);
              }
            return;
           }

         if(key == VK_DOWN || ck_dn)   // Phím mũi tên xuống
           {
            index++;    // Tăng biến
            if(index>=ArraySize(sorted_symbols_ck))
               index=0;
            string symbolCk= sorted_symbols_ck[index];

            if(IsButtonExist(symbolCk)==false)
              {
               for(int idx=index;idx<size_ck;idx++)
                 {
                  symbolCk = sorted_symbols_ck[idx];
                  if(IsButtonExist(symbolCk))
                    {
                     index=idx;
                     break;
                    }
                 }
              }

            Print("VK_DO: "+(string)index + "  "+ symbolCk);
            if(IsButtonExist(symbolCk))
              {
               SetGlobalVariable(CLICKED_SYMBOL_CK_INDEX,(double)index);
               ReDrawChartCk(symbolCk);
              }
            return;
           }
        }

      //-----------------------------------------------------------------------
     }

   if(id==CHARTEVENT_OBJECT_CLICK)
     {

      //--------------------------------------------------------------------------------------
      //--------------------------------------------------------------------------------------
      //--------------------------------------------------------------------------------------
      if(is_same_symbol(sparam,BtnFilterTrading))
        {
         do_clear_cond();

         if(GetGlobalVariable(sparam)==OPTION_FOLOWING)
            SetGlobalVariable(sparam,0);
         else
            SetGlobalVariable(sparam,OPTION_FOLOWING);

         Draw_Buttons();
         return;
        }


      if(is_same_symbol(sparam,BtnClearMessageR1C2))
        {
         WriteFileContent(FILE_MSG_LIST_R1C2,"");
         CreateMessagesBtn(BtnMsgR1C2_);
         return;
        }

      if(is_same_symbol(sparam,BtnClearMessageR1C1))
        {
         WriteFileContent(FILE_MSG_LIST_R1C1,"");
         CreateMessagesBtn(BtnMsgR1C1_);
         return;
        }

      if(is_same_symbol(sparam,BtnMsgR1C2_) || is_same_symbol(sparam,BtnMsgR1C1_))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("The lparam=",lparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         string symbolCk=get_symbol_ck_from_label(buttonLabel,true);

         ReDrawChartCk(symbolCk);

         return;
        }

      if(is_same_symbol(sparam,BtnTrading_) || is_same_symbol(sparam,BtnFollowing_))
        {
           {
            int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);

            string sorted_symbols_ck[];
            SortSymbols(sorted_symbols_ck);
            string symbolCk=sorted_symbols_ck[clicked_ck_index];

            if(GetGlobalVariable(sparam+symbolCk)==OPTION_FOLOWING)
              {
               SetGlobalVariable(sparam+symbolCk,0);
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrLightGray);
              }
            else
              {
               SetGlobalVariable(sparam+symbolCk,OPTION_FOLOWING);
               if(is_same_symbol(sparam,BtnTrading_))
                  SetGlobalVariable(BtnFollowing_+symbolCk,OPTION_FOLOWING);

               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrActiveBtn);
              }
           }

         if(is_same_symbol(sparam,BtnTrading_))
           {
            ObjectsDeleteAll(0);
            Draw_Buttons();
           }

         return;
        }

      if(is_same_symbol(sparam,"GROUP_"))
        {
         int size= GlobalVariablesTotal();
         for(int i=0;i<size;i++)
           {
            string name = GlobalVariableName(i);
            if(is_same_symbol(name,"GROUP_") && is_same_symbol(sparam,name)==false)
              {
               GlobalVariableSet(name,FILTER_NON);
               //Alert(name+(string)GlobalVariableGet(name));
              }
           }

         if(GetGlobalVariable(sparam)==FILTER_ON)
            SetGlobalVariable(sparam,FILTER_NON);
         else
            SetGlobalVariable(sparam,FILTER_ON);

         //Draw_Buttons();
         ObjectsDeleteAll(0);
         Draw_Buttons();
         return;
        }

      if(is_same_symbol(sparam,BtnFilterClear))
        {
         do_clear_cond();
         ObjectsDeleteAll(0);
         Draw_Buttons();
         return;
        }

      if(is_same_symbol(sparam,BtnFilterToday))
        {
         do_clear_cond();

         //SetGlobalVariable(BtnFilterHistMo,FILTER_ON);
         SetGlobalVariable(BtnFilterHistWx,FILTER_ON);
         SetGlobalVariable(BtnFilterHistHx,FILTER_ON);
         //SetGlobalVariable(BtnFilterHistW3,FILTER_ON);
         SetGlobalVariable(BtnFilterCondH4Sq,FILTER_ON);

         //Draw_Buttons();
         ObjectsDeleteAll(0);
         Draw_Buttons();

         return;
        }

      if(is_same_symbol(sparam,BtnFilter_))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("Sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         if(is_same_symbol(sparam,BtnFilterCondH450))
           {
            do_clear_cond(sparam);
            if(GetGlobalVariable(sparam)!=FILTER_ON)
               SetGlobalVariable(BtnFilterMa20Mo,FILTER_ON);
           }

         if(GetGlobalVariable(sparam)==FILTER_ON)
            SetGlobalVariable(sparam,FILTER_NON);
         else
            SetGlobalVariable(sparam,FILTER_ON);

         ObjectsDeleteAll(0);
         Draw_Buttons();

         return;
        }

      if(is_same_symbol(sparam,BtnCkD1_))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         string symbolCk=get_symbol_ck_from_label(sparam,true);

         Print("Sparam=",sparam," buttonLabel=",buttonLabel," was clicked: " + symbolCk);

         ReDrawChartCk(symbolCk);

         return;
        }

      if(is_same_symbol(sparam,BtnCkTradingView))
        {
           {
            int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);

            string sorted_symbols_ck[];
            SortSymbols(sorted_symbols_ck);

            string symbolCk = sorted_symbols_ck[clicked_ck_index];
            StringReplace(symbolCk,"_",":");

            int intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
            if(intPeriod==-1)
               intPeriod = PERIOD_D1;

            string interval="M";
            if(intPeriod == PERIOD_MN1)
               interval="M";
            if(intPeriod == PERIOD_W1)
               interval="W";
            if(intPeriod == PERIOD_H4)
               interval="4H";
            if(intPeriod == PERIOD_H1)
               interval="1H";
            if(intPeriod == PERIOD_M3)
               interval="3M";

            string url="https://www.tradingview.com/chart/r46Q5U5a/?interval="+interval+"&symbol="+symbolCk;
            int result = ShellExecuteW(0, "open", url, NULL, NULL, 1);
           }

         return;
        }

      //--------------------------------------------------------------------------------------
      if(is_same_symbol(sparam,BtnDrawCkMonthly))
        {
         ObjectSetInteger(0,BtnDrawCkMonthly,OBJPROP_BGCOLOR,clrActiveBtn);
         ObjectSetInteger(0,BtnDrawCkWeekly, OBJPROP_BGCOLOR,clrLightGray);
         ObjectSetInteger(0,BtnDrawCk4hours, OBJPROP_BGCOLOR,clrLightGray);

         int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);
         string sorted_symbols_ck[];
         SortSymbols(sorted_symbols_ck);

         string symbolCk=sorted_symbols_ck[clicked_ck_index];
         TestReadAllDataFromFile(symbolCk,PERIOD_MN1,0);

         return;
        }
      if(is_same_symbol(sparam,BtnDrawCkWeekly))
        {
         ObjectSetInteger(0,BtnDrawCkMonthly,OBJPROP_BGCOLOR,clrLightGray);
         ObjectSetInteger(0,BtnDrawCkWeekly, OBJPROP_BGCOLOR,clrActiveBtn);
         ObjectSetInteger(0,BtnDrawCk4hours, OBJPROP_BGCOLOR,clrLightGray);

         int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);

         string sorted_symbols_ck[];
         SortSymbols(sorted_symbols_ck);

         string symbolCk=sorted_symbols_ck[clicked_ck_index];
         TestReadAllDataFromFile(symbolCk,PERIOD_W1,1);
         return;
        }
      if(is_same_symbol(sparam,BtnDrawCk4hours))
        {
         ObjectSetInteger(0,BtnDrawCkMonthly,OBJPROP_BGCOLOR,clrLightGray);
         ObjectSetInteger(0,BtnDrawCkWeekly, OBJPROP_BGCOLOR,clrLightGray);
         ObjectSetInteger(0,BtnDrawCk4hours, OBJPROP_BGCOLOR,clrActiveBtn);

         int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);

         string sorted_symbols_ck[];
         SortSymbols(sorted_symbols_ck);

         string symbolCk=sorted_symbols_ck[clicked_ck_index];
         TestReadAllDataFromFile(symbolCk,PERIOD_H4,1);
         return;
        }
      //--------------------------------------------------------------------------------------
      //--------------------------------------------------------------------------------------
      //--------------------------------------------------------------------------------------
      if(is_same_symbol(sparam,BtnOptionPeriod))
        {
         ENUM_TIMEFRAMES PERIOD = PERIOD_D1;
         if(is_same_symbol(sparam,"MN1"))
            PERIOD = PERIOD_MN1;
         if(is_same_symbol(sparam,"W1"))
            PERIOD = PERIOD_W1;
         if(is_same_symbol(sparam,"D1"))
            PERIOD = PERIOD_D1;
         if(is_same_symbol(sparam,"H4"))
            PERIOD = PERIOD_H4;
         if(is_same_symbol(sparam,"H1"))
            PERIOD = PERIOD_H1;
         if(is_same_symbol(sparam,"H12"))
            PERIOD = PERIOD_H12;
         if(is_same_symbol(sparam,"M5"))
            PERIOD = PERIOD_M5;
         if(is_same_symbol(sparam,"3M"))
            PERIOD = PERIOD_M3;

         SetGlobalVariable(BtnOptionPeriod,(double)PERIOD);

         Draw_Buttons();
         return;
        }

      if(is_same_symbol(sparam,BtnSearchSymbol))
        {
         do_search();
         ObjectsDeleteAll(0);
         Draw_Buttons();
         return;
        }

      if(is_same_symbol(sparam,BtnClearChart))
        {
         ObjectsDeleteAll(0);
         Draw_Buttons();
         return;
        }

      if(is_same_symbol(sparam,BtnResetLoadData))
        {
         SetGlobalVariable(LAST_CHECKED_BINANCE_INDEX, -1);
         do_clear_cond();
         ObjectsDeleteAll(0);
         Draw_Buttons();
         return;
        }

      if(is_same_symbol(sparam,BtnMakeSymbolsJson))
        {
         string JSON_FILE = "_symbols.json";

         // Create the new file and write the content
         int file_handle = FileOpen(JSON_FILE, FILE_WRITE | FILE_ANSI);
         if(file_handle == INVALID_HANDLE)
           {
            Print("Failed to create file: ", JSON_FILE);
            return;
           }

         string sorted_symbols_ck[];
         SortSymbols(sorted_symbols_ck);

         string arrSymbolCk[];
         int size = ArraySize(sorted_symbols_ck);
         for(int i=0;i<size;i++)
           {
            string symbolCk=sorted_symbols_ck[i];
            if(IsButtonExist(symbolCk))
              {
               int cur_size = ArraySize(arrSymbolCk);
               ArrayResize(arrSymbolCk, cur_size + 1);
               arrSymbolCk[cur_size] = symbolCk;
              }
           }

         FileWrite(file_handle, "[");
         string line = "    [\"" + "HOSE" + "\",\"" + "VNINDEX" + "\"],";
         FileWrite(file_handle, line);

         int cur_size = ArraySize(arrSymbolCk);
         for(int i=0;i<cur_size;i++)
           {
            string symbolCk=arrSymbolCk[i];

            // Vị trí của ký tự "_"
            int pos = StringFind(symbolCk, "_");

            // Cắt chuỗi thành hai phần
            string HOS = StringSubstr(symbolCk, 0, pos);
            string SYM = StringSubstr(symbolCk, pos + 1);

            line = "    [\"" + HOS + "\",\"" + SYM + "\"],";
            if(i==cur_size-1)
               line = "    [\"" + HOS + "\",\"" + SYM + "\"] ";

            FileWrite(file_handle, line);
           }
         FileWrite(file_handle, "]");

         FileClose(file_handle);

         Alert("Dữ liệu đã xuất thành công vào file: ", JSON_FILE);
         // C:\Users\Admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Files\temp_symbols.json
         string file_path = "C:\\Users\\Admin\\AppData\\Roaming\\MetaQuotes\\Terminal\\53785E099C927DB68A545C249CDBCE06\\MQL5\\Files\\_symbols.json";
         ShellExecuteW(0, "open", file_path, NULL, NULL, 1);

         return;
        }

      if(is_same_symbol(sparam,BtnSaveResult))
        {
         int result=MessageBox(GLOBAL_VARIABLE_FILE +" sẽ bị ghi đè. Có muốn thực hiện không?","Confirm",MB_YESNOCANCEL);
         if(result!=IDYES)
            return;

         string CurrentDate = get_yyyymmdd(TimeCurrent());
         string newFileName = "global_variable_" + CurrentDate + ".data";

         if(FileIsExist(GLOBAL_VARIABLE_FILE))
           {
            //fileHandle = FileOpen(filename, FILE_WRITE|FILE_READ|FILE_ANSI);

            int file_handle = FileOpen(GLOBAL_VARIABLE_FILE, FILE_READ | FILE_ANSI);
            if(file_handle == INVALID_HANDLE)
              {
               Print("Failed to open file: ", GLOBAL_VARIABLE_FILE);
               return;
              }

            // Read content from the old file
            string content = "";
            while(!FileIsEnding(file_handle))
              {
               content += FileReadString(file_handle) + "\n";
              }
            FileClose(file_handle);

            // Create the new file and write the content
            file_handle = FileOpen(newFileName, FILE_WRITE | FILE_ANSI);
            if(file_handle == INVALID_HANDLE)
              {
               Print("Failed to create file: ", newFileName);
               return;
              }

            FileWrite(file_handle, content);
            FileClose(file_handle);
           }

         ResetFile(GLOBAL_VARIABLE_FILE);

         int size= GlobalVariablesTotal();
         for(int i=0;i<size;i++)
           {
            string key_i = GlobalVariableName(i);
            string value=(string)GlobalVariableGet(key_i);

            AppendToFile(GLOBAL_VARIABLE_FILE,key_i+" "+value);
           }

         Alert("Dữ liệu đã xuất thành công vào file: ", GLOBAL_VARIABLE_FILE);
         return;
        }


      if(is_same_symbol(sparam, BtnLoadResult))
        {
         int result=MessageBox("Có muốn load lại toàn bộ biến Global không?","Confirm",MB_YESNOCANCEL);
         if(result!=IDYES)
            return;

         // Đường dẫn file
         string file_path = GLOBAL_VARIABLE_FILE;

         // Mở file để đọc
         int handle = FileOpen(file_path, FILE_READ | FILE_TXT);
         if(handle == INVALID_HANDLE)
           {
            Alert("Không thể mở file: ", file_path);
            return;
           }

         // Đọc từng dòng trong file
         while(!FileIsEnding(handle))
           {
            string line = FileReadString(handle); // Đọc dòng
            StringTrimRight(line);               // Xóa khoảng trắng cuối dòng nếu có

            // Kiểm tra nếu dòng không rỗng
            if(StringLen(line) > 0)
              {
               // Tách key_i và value bằng khoảng trắng
               string key_i;
               double value;
               int pos = StringFind(line, " ");
               if(pos != -1)
                 {
                  key_i = StringSubstr(line, 0, pos);                     // Symbol là phần trước dấu cách
                  value = StringToDouble(StringSubstr(line, pos + 1));    // Value là phần sau dấu cách

                  // Thiết lập giá trị GlobalVariable
                  GlobalVariableSet(key_i, value);
                 }
              }
           }

         FileClose(handle); // Đóng file sau khi đọc xong

         Alert("Tất cả giá trị GlobalVariable đã được tải lại từ file.");

         Draw_Buttons();
         return;
        }

      //-----------------------------------------------------------------------
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_symbol_ck_from_label(string lable, bool is_load_data)
  {
   int size = ArraySize(ARR_SYMBOLS_CK);
   for(int i=0;i<size;i++)
     {
      string symbolCk=ARR_SYMBOLS_CK[i];
      if(is_same_symbol(lable," "+symbolCk) || is_same_symbol(lable,"_"+symbolCk) || lable==symbolCk)
        {
         if(is_load_data)
            return symbolCk;

         StringReplace(symbolCk,"_",":");
         return symbolCk;
        }
     }

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sleep30Seconds()
  {
   Sleep(60000); // Tạm dừng 60 giây
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_time_frame_name(ENUM_TIMEFRAMES PERIOD_XX)
  {
   if(PERIOD_XX==PERIOD_M1)
      return "M1";

   if(PERIOD_XX==PERIOD_M5)
      return "M5";

   if(PERIOD_XX==PERIOD_M15)
      return "M15";

   if(PERIOD_XX== PERIOD_H1)
      return "H1";

   if(PERIOD_XX== PERIOD_H4)
      return "H4";

   if(PERIOD_XX== PERIOD_D1)
      return "D1";

   if(PERIOD_XX== PERIOD_W1)
      return "W1";

   if(PERIOD_XX== PERIOD_MN1)
      return "MO";

   if(PERIOD_XX== PERIOD_M3)
      return "3M";

   return "??";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjectsWithPrefix(string prefix)
  {
   int total_objects = ObjectsTotal(0);  // Lấy tổng số đối tượng trên biểu đồ hiện tại
   for(int i = total_objects - 1; i >= 0; i--)
     {
      string obj_name = ObjectName(0, i);  // Lấy tên đối tượng
      if(StringFind(obj_name, prefix) == 0)     // Kiểm tra nếu tên bắt đầu với prefix
        {
         ObjectDelete(0, obj_name);  // Xóa đối tượng
        }
     }
  }
//+------------------------------------------------------------------+
//#define TREND_BUY=3;
//#define TREND_SEL=7;
// ydd|trading:1/0|Ma10W:B/S(3/7),HeiW:B/S(3/7),CountMa(1->9)|Ma10D:B/S(3/7),HeiD:B/S(3/7),CountMa(1->9)|Ma10H4:B/S(3/7),HeiH4:B/S(3/7),CountMa(1->9)
// ydd 331 332 000.6 : ngay ydd da check, 1: da buy nen luon thoe doi, Ma10W: buy, HeiW: buy, Dem ma10[0] la tuan thu 1.
//+------------------------------------------------------------------+
void get_decrypt_trend_path(string w10_hei_n,string &w10,string &hei,string &count_ma10)
  {
   w10        = "";
   hei        = "";
   count_ma10 = "";

   if(StringLen(w10_hei_n)>=3)
     {
      w10        = StringSubstr(w10_hei_n,0,1);
      hei        = StringSubstr(w10_hei_n,1,2);
      count_ma10 = StringSubstr(w10_hei_n,2);

      if(is_same_symbol(w10, TREND_BUY) || is_same_symbol(w10, TREND_BUY))
         w10=TREND_BUY;
      if(is_same_symbol(w10, TREND_SEL) || is_same_symbol(w10, TREND_SEL))
         w10=TREND_SEL;

      if(is_same_symbol(hei, TREND_BUY) || is_same_symbol(hei, TREND_BUY))
         hei=TREND_BUY;
      if(is_same_symbol(hei, TREND_SEL) || is_same_symbol(hei, TREND_SEL))
         hei=TREND_SEL;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_tftrend_path(string symbolUsdt, string &ydd,string &w1_hei_n,string &d1_hei_n,string &h4_hei_n,string &notice_h4)
  {
   ydd       = "111";
   w1_hei_n  = "000";
   d1_hei_n  = "0000";
   h4_hei_n  = "0000";
   notice_h4 = "0";

   string wdh=(string)GetGlobalVariable(symbolUsdt);
   if(StringLen(wdh)>=13)
     {
      ydd       = StringSubstr(wdh, 0,3);
      w1_hei_n  = StringSubstr(wdh, 3,3);
      d1_hei_n  = StringSubstr(wdh, 6,4);
      h4_hei_n  = StringSubstr(wdh,10,4);

      int dot_position = StringFind(wdh, ".");
      if(dot_position != -1)
        {
         string decimal_part = StringSubstr(wdh, dot_position+1);
         notice_h4=decimal_part;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BinanceStringToDouble(string &prices[],int index)
  {
   if(ArraySize(prices)<5)
      return 0;
   if(index>=ArraySize(prices)-2)
      return 0;

   string value=prices[index];

// Loại bỏ dấu ngoặc kép nếu có
   StringReplace(value, "\"", "");  // Thay tất cả dấu ngoặc kép bằng chuỗi rỗng

// Chuyển đổi chuỗi sang kiểu double
   double dblValue = StringToDouble(value);

   return dblValue;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime BinanceDateTimeToVNTime(string symbol, string &open_times[],int index)
  {
   if(ArraySize(open_times)<5)
      return 0;
   if(index>=ArraySize(open_times)-2)
      return 0;

   string symbolCks = ";";
   int size_ck = ArraySize(ARR_SYMBOLS_CK);
   for(int jj = 0; jj< size_ck; jj++)
      symbolCks += ARR_SYMBOLS_CK[jj]+"; ";

   return StringToTime(open_times[index]);

   datetime result_time = 0;
   if(is_same_symbol(symbolCks,symbol))
     {
      return StringToTime(open_times[index]);
     }
   else
     {
      string str_unix_timestamp=open_times[index];
      long unix_timestamp=(long)str_unix_timestamp;

      // Chuyển đổi Unix timestamp (milli-giây) thành giây
      long timestamp_seconds = unix_timestamp / 1000;

      // Chuyển đổi giây thành datetime
      result_time = (datetime)timestamp_seconds;

      // Chuyển đổi datetime thành giờ VN (chênh lệch múi giờ VN là UTC+7)
      result_time += 7 * 3600;  // Thêm 7 giờ (7 * 3600 giây)
     }

   return result_time;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getShortName(string trend)
  {
   if(is_same_symbol(trend,TREND_BUY))
      return "B";

   if(is_same_symbol(trend,TREND_SEL))
      return  "S";

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_ydd(datetime time)
  {
   MqlDateTime cur_time;
   TimeToStruct(time,cur_time);

   string current_ymmdd=StringSubstr((string)cur_time.year,3,1) +
//StringFormat("%02d",cur_time.mon) +
                        StringFormat("%02d",cur_time.day);
   return current_ymmdd;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_yyyymmdd(datetime time)
  {
   MqlDateTime cur_time;
   TimeToStruct(time,cur_time);

   string current_yyyymmdd=(string)cur_time.year +
                           StringFormat("%02d",cur_time.mon) +
                           StringFormat("%02d",cur_time.day);
   return current_yyyymmdd;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_yyyymmdd_hhmm(datetime date0)
  {
   MqlDateTime gmt_time;
   TimeToStruct(date0,gmt_time);

   string result=(string)gmt_time.year+append1Zero(gmt_time.mon)+append1Zero(gmt_time.day)+append1Zero(gmt_time.hour)+append1Zero(gmt_time.min);

   return result;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetGlobalVariable(string varName)
  {
   if(GlobalVariableCheck(BOT_SHORT_NM+varName))
      return GlobalVariableGet(BOT_SHORT_NM+varName);

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetGlobalVariable(string varName,double value)
  {
   GlobalVariableSet(BOT_SHORT_NM+varName,value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteGlobalVariable(string varName)
  {
   GlobalVariableDel(BOT_SHORT_NM+varName);
  }
//+------------------------------------------------------------------+
string appendZero100(int trade_no)
  {
   if(trade_no<10)
      return "00"+(string) trade_no;

   if(trade_no<100)
      return "0"+(string) trade_no;

   return (string) trade_no;
  }
//+------------------------------------------------------------------+
string Append(double inputString,int totalLength=6)
  {
   return AppendSpaces((string) inputString,totalLength);
  }
//+------------------------------------------------------------------+
string AppendSpaces(string inputString,int totalLength=10,bool is_append_right=true)
  {
   int currentLength=StringLen(inputString);

   if(currentLength>=totalLength)
      return (inputString);

   int spacesToAdd=totalLength-currentLength;
   string spaces="";
   for(int index=1; index <= spacesToAdd; index++)
      spaces+= " ";

   if(is_append_right)
      return (inputString+spaces);
   else
      return (spaces+inputString);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string append1Zero(int trade_no,string append="0")
  {
   if(trade_no<10)
      return append+(string) trade_no;

   return (string) trade_no;
  }
//+------------------------------------------------------------------+
string format_double_to_string(double number,int digits=5)
  {
   string numberString=(string) number;
   int dotIndex=StringFind(numberString,".");
   if(dotIndex>=0)
     {
      string beforeDot=StringSubstr(numberString,0,dotIndex);
      string afterDot=StringSubstr(numberString,dotIndex+1);
      afterDot=StringSubstr(afterDot,0,digits); // chỉ lấy digits chữ số đầu tiên sau dấu chấm

      numberString=beforeDot+"."+afterDot;
     }

   StringReplace(numberString,"00000","");
   StringReplace(numberString,"00000","");
   StringReplace(numberString,"00000","");
   StringReplace(numberString,"99999","9");
   StringReplace(numberString,"99999","9");
   StringReplace(numberString,"99999","9");

   return DoubleToString((double)numberString,digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReadFileContent(string file_name)
  {
   string fileContent="";
   int fileHandle=FileOpen(file_name,FILE_READ);

   if(fileHandle != INVALID_HANDLE)
     {
      ulong fileSize=FileSize(fileHandle);
      if(fileSize>0)
        {
         fileContent=FileReadString(fileHandle);
        }

      FileClose(fileHandle);
     }

   return fileContent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteFileContent(string file_name,string content)
  {
   int fileHandle=FileOpen(file_name,FILE_WRITE | FILE_TXT);

   if(fileHandle != INVALID_HANDLE)
     {
      string file_contents=CutString(content);

      FileWriteString(fileHandle,file_contents);
      FileClose(fileHandle);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CutString(string originalString)
  {
   int max_lengh=10000;
   int originalLength=StringLen(originalString);
   if(originalLength>max_lengh)
     {
      int startIndex=originalLength-max_lengh;
      return StringSubstr(originalString,startIndex,max_lengh);
     }
   return originalString;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool allow_PushMessage(string symbol,string FILE_NAME_MSG_LIST)
  {
   string fileContent = ReadFileContent(FILE_NAME_MSG_LIST);
   StringToLower(fileContent);
   StringToLower(symbol);
   if(StringFind(fileContent, symbol) >= 0)
      return false;
   return true;
//return !is_same_symbol(fileContent, symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PushMessage(string newMessage,string FILE_NAME_MSG_LIST)
  {
   string fileContent = ReadFileContent(FILE_NAME_MSG_LIST);
   fileContent += newMessage+"~";
   WriteFileContent(FILE_NAME_MSG_LIST,fileContent);

   string messageArray[];
   int _start = 0;
   int count = 0;
   for(int i = 0; i < StringLen(fileContent); i++)
     {
      if(fileContent[i]=='~')
        {
         int size = ArraySize(messageArray);
         ArrayResize(messageArray,size+1);
         messageArray[size] = StringSubstr(fileContent,_start,i-_start);
         _start = i+1;
         count++;
        }
     }


   int size = ArraySize(messageArray);
   if(size > MAX_MESSAGES)
     {
      string newMessageArray[];
      for(int i = MAX_MESSAGES; i > 0; i--)
        {
         int newsize = ArraySize(newMessageArray);
         ArrayResize(newMessageArray,newsize+1);
         newMessageArray[newsize] = messageArray[size-i];
        }

      fileContent = "";
      int size1 = ArraySize(newMessageArray);
      for(int i = 0; i< size1; i++)
         fileContent += newMessageArray[i]+"~";
      WriteFileContent(FILE_NAME_MSG_LIST,fileContent);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateMessagesBtn(string BtnSeq___)
  {
   int btn_width = 120;
   int COL_1=2400+(btn_width+10)*0;
   int COL_2=2450+(btn_width+10)*1;

   string BtnClearMessage=BtnClearMessageR1C1;
   string FILE_NAME_MSG_LIST=FILE_MSG_LIST_R1C1;
   int x_position=COL_1; //+260
   int y_position=20;
   string prifix="R1C1(AllowTrade)";
   color clrBgColor = clrWhite;

   if(BtnSeq___==BtnMsgR1C2_)
     {
      BtnClearMessage=BtnClearMessageR1C2;
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_R1C2;
      x_position=COL_2;
      prifix="R1C2(ExitTrade)";
      clrBgColor = clrYellow;
     }

//--------------------------------------------------------
   ObjectDelete(0,BtnClearMessage);
   for(int index = 0; index < MAX_MESSAGES; index++)
      ObjectDelete(0,BtnSeq___+append1Zero(index));

   string fileContent = ReadFileContent(FILE_NAME_MSG_LIST);

   string messageArray[];
   int _start = 0;
   for(int i = 0; i < StringLen(fileContent); i++)
     {
      if(fileContent[i]=='~')
        {
         int size = ArraySize(messageArray);
         ArrayResize(messageArray,size+1);
         messageArray[size] = StringSubstr(fileContent,_start,i-_start);
         _start = i+1;
        }
     }

   if(ArraySize(messageArray) > 0)
     {
      createButton(BtnClearMessage,  "Clear", x_position+60*0,y_position-20,50,16,clrBlack,clrWhite,6);
      //createButton(BtnFilter_+prifix,"Filter",x_position+60*1,y_position-20,50,16,clrBlack,clrWhite,6);
     }

   string total_comments="";
   int size_msg =ArraySize(messageArray);

   for(int index = 0; index < size_msg; index++)
     {
      string lable=messageArray[index];
      string symbolCk = get_symbol_ck_from_label(lable, true);

      color clrBackground=clrWhite;

      createButton(BtnSeq___+append1Zero(index)+"_"+symbolCk,lable,x_position,y_position+index*18,btn_width,16,clrBlack,clrBackground,6);//x_position==COL_1?200:250
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number,int digits)
  {
   return NormalizeDouble(StringToDouble(format_double_to_string(number,digits)),digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_same_symbol(string symbol_og,string symbol_tg)
  {
   if(symbol_og=="" || symbol_og=="")
      return false;

   if(StringFind(toLower(symbol_og),toLower(symbol_tg))>=0)
      return true;

   if(StringFind(toLower(symbol_tg),toLower(symbol_og))>=0)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
//+------------------------------------------------------------------+
string get_vntime()
  {
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(),gmt_time);
   string current_gmt_hour=(gmt_time.hour>9) ? (string) gmt_time.hour : "0"+(string) gmt_time.hour;

   datetime vietnamTime=TimeGMT()+7 * 3600;
   string str_date_time=TimeToString(vietnamTime,TIME_DATE | TIME_MINUTES);
   string vntime="("+str_date_time+")    ";
   return vntime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vnhour()
  {
   datetime vietnamTime = TimeGMT()+7 * 3600;
   string str_date_time = TimeToString(vietnamTime,TIME_MINUTES);
   string vntime = "("+str_date_time+")";
   return vntime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createButton(string objName,string text,int x,int y,int width,int height,color clrTextColor=clrBlack,color clrBackground=clrWhite,int font_size=6,int sub_window=0)
  {
   long chart_id=0;
   ObjectDelete(chart_id,objName);
   ResetLastError();
   if(!ObjectCreate(chart_id,objName,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code=",GetLastError());
      return(false);
     }
   StringReplace(text,"  "," ");
   StringReplace(text,"  "," ");
   StringReplace(text,"  "," ");
   ObjectSetString(chart_id, objName,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,objName,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_id,objName,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_id,objName,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_id,objName,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_id,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(chart_id,objName,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_id,objName,OBJPROP_COLOR,clrTextColor);
   ObjectSetInteger(chart_id,objName,OBJPROP_BGCOLOR,clrBackground);
   ObjectSetInteger(chart_id,objName,OBJPROP_BORDER_COLOR,clrSilver);
   ObjectSetInteger(chart_id,objName,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,objName,OBJPROP_STATE,false);
   ObjectSetInteger(chart_id,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_id,objName,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_id,objName,OBJPROP_HIDDEN,false);
   ObjectSetInteger(chart_id,objName,OBJPROP_ZORDER,9999);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_heiken_candle(
   const string            name="Rectangle",        // object name
   datetime                time_from=0,             // anchor point time (bottom-left corner)
   datetime                time_to=0,               // anchor point time (top-right corner)
   double                  open=0,            // anchor point price (bottom-left corner)
   double                  close=0,              // anchor point price (top-right corner)
   double                  low=0,            // anchor point price (bottom-left corner)
   double                  high=0,              // anchor point price (top-right corner)
   const color             clr_fill=clrGray,        // fill color
   bool                    is_fill_body=false,
   int                     boder_width=1,
   string                  count_heiken=""
)
  {
   string name_new=name;

   ObjectDelete(0,name_new);  // Delete any existing object with the same name
   ObjectCreate(0,name_new,OBJ_RECTANGLE,0,time_from,open,time_to,close);
   ObjectSetInteger(0,name_new,OBJPROP_STYLE,STYLE_SOLID);      // Set border style to solid
   ObjectSetInteger(0,name_new,OBJPROP_HIDDEN,true);            // Set hidden property
   ObjectSetInteger(0,name_new,OBJPROP_BACK,true);              // Set background property
   ObjectSetInteger(0,name_new,OBJPROP_SELECTABLE,false);       // Set selectable property
   ObjectSetInteger(0,name_new,OBJPROP_STYLE,STYLE_SOLID);      // Set style to solid
   ObjectSetInteger(0,name_new,OBJPROP_COLOR,clr_fill);         // Set fill color (this may not work as intended for all objects)
   ObjectSetInteger(0,name_new,OBJPROP_BGCOLOR,clr_fill);
   ObjectSetInteger(0,name_new,OBJPROP_FILL,is_fill_body);
   ObjectSetInteger(0,name_new,OBJPROP_WIDTH,boder_width);      // Setting this to 1 for consistency

   datetime time_mid=(time_from+time_to)/2;
   create_trend_line(name_new+"+",time_mid,MathMax(open,close),time_mid,high,clr_fill,STYLE_SOLID,boder_width);
   create_trend_line(name_new+"-",time_mid,MathMin(open,close),time_mid,low, clr_fill,STYLE_SOLID,boder_width);

   if(high>MathMax(open,close))
      create_trend_line(name_new+"+.",time_mid,high,time_mid,high,clr_fill,STYLE_SOLID,7);

   if(low<MathMin(open,close))
      create_trend_line(name_new+"-.",time_mid, low,time_mid, low,clr_fill,STYLE_SOLID,7);

   color color_heiken=open<close?clrBlue:clrRed;
   if(count_heiken!="")
      create_label_simple(name_new+".count",(string)(count_heiken),(open+close)/2,color_heiken,time_mid-TIME_OF_ONE_H4_CANDLE*3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_trend_line(
   const string            name="Text",        // object name
   datetime                time_from=0,                  // anchor point time
   double                  price_from=0,                  // anchor point price
   datetime                time_to=0,                  // anchor point time
   double                  price_to=0,                  // anchor point price
   const color             clr_color=clrRed,             // color
   const int               STYLE_XX=STYLE_SOLID,
   const int               width=1,
   const bool              ray_left=false,
   const bool              ray_right=false,
   const bool              is_hiden=true,
   const bool              is_back=true,
   const int               sub_window=0
)
  {
   string name_new=name;
   ObjectDelete(0,name);
   ObjectCreate(0,name_new,OBJ_TREND,sub_window,time_from,price_from,time_to,price_to);
   ObjectSetInteger(0,name_new,OBJPROP_COLOR,      clr_color);
   ObjectSetInteger(0,name_new,OBJPROP_STYLE,      STYLE_XX);
   ObjectSetInteger(0,name_new,OBJPROP_WIDTH,      width);
   ObjectSetInteger(0,name_new,OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0,name_new,OBJPROP_BACK,       is_back);
   ObjectSetInteger(0,name_new,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0,name_new,OBJPROP_RAY_LEFT,  ray_left);
   ObjectSetInteger(0,name_new,OBJPROP_RAY_RIGHT,  ray_right); // Bật tính năng "Rời qua phải"
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_TextInput(long XDISTANCE=100
                                     , long YDISTANCE=100
                      , int XSIZE=150
                      , int YSIZE=30)
  {
   string name=TEXT_INPUT;
   if(!ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0))
     {
      Print("Không thể tạo đối tượng Edit Label!");
      return;
     }

// Đặt thuộc tính cho đối tượng
   ObjectSetInteger(0, name, OBJPROP_XSIZE, XSIZE);        // Chiều rộng
   ObjectSetInteger(0, name, OBJPROP_YSIZE, YSIZE);         // Chiều cao
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER); // Góc hiển thị
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, XDISTANCE);     // Khoảng cách từ cạnh trái
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, YDISTANCE);     // Khoảng cách từ cạnh trên
   ObjectSetInteger(0, name, OBJPROP_BACK, false);        // Hiển thị nền
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);

   string text="";
   string file_path = TEXT_INPUT+".txt";
   int handle = FileOpen(file_path, FILE_READ | FILE_TXT);
   if(handle != INVALID_HANDLE)
     {
      while(!FileIsEnding(handle))
        {
         string line = FileReadString(handle); // Đọc dòng
         StringTrimRight(line);               // Xóa khoảng trắng cuối dòng nếu có
         text+=line;
        }

      ObjectSetString(0, name, OBJPROP_TEXT, text);
     }
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTextInput()
  {
   string name=TEXT_INPUT;
   if(ObjectFind(0, name) < 0)
     {
      Print("Không tìm thấy đối tượng: ", name);
      return "";
     }
   return ObjectGetString(0, name, OBJPROP_TEXT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_label_simple(
   const string            name="Text",
   string                  label="Label",
   double                  price=0,
   color                   clrColor=clrBlack,
   datetime time_to=0,
   int font_size=8
)
  {
   ObjectDelete(0,name);
   if(time_to==0)
      time_to=TimeCurrent()+TIME_OF_ONE_H4_CANDLE;                   // anchor point time
   TextCreate(0,name,0,time_to,price,label,clrColor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_label(
   const string            name="Text",        // object name
   datetime                time_to=0,                  // anchor point time
   double                  price=0,                  // anchor point price
   string                  label="label",                  // anchor point price
   const string            TRADING_TREND="",
   const bool              trim_text=true,
   const int               font_size=8,
   const bool              is_bold=false,
   const int               sub_window=0
)
  {
   ObjectDelete(0,name);
   color clr_color=TRADING_TREND==TREND_BUY ? clrBlue : TRADING_TREND==TREND_SEL ? clrRed : clrBlack;
   TextCreate(0,name,sub_window,time_to,price,trim_text ? " "+label : "        "+label,clr_color);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   if(is_bold)
      ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,              // chart's ID
                const string            name="Text",             // object name
                const int               sub_window=0,            // subwindow index
                datetime                time=0,                  // anchor point time
                double                  price=0,                 // anchor point price
                string                  text="Text",             // the text itself
                const color             clr=clrRed,              // color
                const string            font="Arial",            // font
                const int               font_size=8,             // font size
                const double            angle=0.0,               // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,      // anchor type
                const bool              back=false,              // in the background
                const bool              selection=false,         // highlight to move
                const bool              hidden=true,             // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,": failed to create \"Text\" object! Error code=",GetLastError());
      return(false);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(0,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleData
  {
public:
   datetime          time;   // Thời gian
   double            open;   // Giá mở
   double            high;   // Giá cao
   double            low;    // Giá thấp
   double            close;  // Giá đóng
   string            trend_heiken;
   int               count_heiken;
   double            ma10;
   string            trend_by_ma10;
   int               count_ma10;
   string            trend_vector_ma10;
   string            trend_by_ma05;
   string            trend_ma03vs05;
   int               count_ma3_vs_ma5;
   string            trend_by_seq_102050;
   double            ma50;
   string            trend_ma10vs20;
   string            trend_ma05vs10;
   double            lowest;
   double            higest;
   bool              allow_trade_now_by_seq_051020;
   bool              allow_trade_now_by_seq_102050;
   double            ma20;
   double            ma05;
   double            volume;

                     CandleData()
     {
      time=0;
      open=0.0;
      high=0.0;
      low=0.0;
      close=0.0;
      trend_heiken="";
      count_heiken=0;
      ma10=0;
      trend_by_ma10="";
      count_ma10=0;
      trend_vector_ma10="";
      trend_by_ma05="";
      trend_ma03vs05="";
      count_ma3_vs_ma5=0;
      trend_by_seq_102050="";
      ma50=0;
      trend_ma10vs20="";
      trend_ma05vs10="";
      lowest=0;
      higest=0;
      allow_trade_now_by_seq_051020=false;
      allow_trade_now_by_seq_102050=false;
      ma20=0;
      ma05=0;
      volume=0;
     }

                     CandleData(
      datetime t,double o,double h,double l,double c,
      string trend_heiken_,int count_heiken_,
      double ma10_,string trend_by_ma10_,int count_ma10_,string trend_vector_ma10_,
      string trend_by_ma05_,string trend_ma03vs05_,int count_ma3_vs_ma5_,
      string trend_by_seq_102050_,double ma50_,string trend_ma10vs20_,string trend_ma05vs10_,
      double lowest_,  double higest_,bool allow_trade_now_by_seq_051020_,bool allow_trade_now_by_seq_102050_,double ma20_,double ma05_,double volume_)
     {
      time=t;
      open=o;
      high=h;
      low=l;
      close=c;
      trend_heiken=trend_heiken_;
      count_heiken=count_heiken_;
      ma10=ma10_;
      trend_by_ma10=trend_by_ma10_;
      count_ma10=count_ma10_;
      trend_vector_ma10=trend_vector_ma10_;
      trend_by_ma05=trend_by_ma05_;
      trend_ma03vs05=trend_ma03vs05_;
      count_ma3_vs_ma5=count_ma3_vs_ma5_;
      trend_by_seq_102050=trend_by_seq_102050_;
      ma50=ma50_;
      trend_ma10vs20=trend_ma10vs20_;
      trend_ma05vs10=trend_ma05vs10_;
      lowest=lowest_;
      higest=higest_;
      allow_trade_now_by_seq_051020=allow_trade_now_by_seq_051020_;
      allow_trade_now_by_seq_102050=allow_trade_now_by_seq_102050_;
      ma20=ma20_;
      ma05=ma05_;
      volume=volume_;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_arr_heiken_binance(string symbol,CandleData &candleArray[],string &open_times[],string &opens[],string &closes[],string &lows[],string &highs[],string &volumes[])
  {
   bool is_calc_ma10=true;
   bool is_calc_seq102050=true;
   bool check_seq=false;

   int length= ArraySize(opens)-10;
   if(length<0)
      return 0;

   ArrayResize(candleArray,length+5);
     {
      datetime pre_HaTime=BinanceDateTimeToVNTime(symbol,open_times,length);
      double pre_HaOpen=BinanceStringToDouble(opens,length);
      double pre_HaHigh=BinanceStringToDouble(highs,length);
      double pre_HaLow=BinanceStringToDouble(lows,length);
      double pre_HaClose=BinanceStringToDouble(closes,length);
      double pre_Volume=BinanceStringToDouble(volumes,length);
      string pre_candle_trend=pre_HaClose>pre_HaOpen ? TREND_BUY : TREND_SEL;

      CandleData candle(pre_HaTime,pre_HaOpen,pre_HaHigh,pre_HaLow,pre_HaClose,pre_candle_trend,0,0,"",0,"","","",0,"",0,"","",0,0,false,false,0,0,pre_Volume);
      candleArray[length+4]=candle;
     }

   double cur_close_0 = BinanceStringToDouble(closes,0);

   for(int index=length; index>=0; index--)
     {
      CandleData pre_cancle=candleArray[index+1];

      datetime time=BinanceDateTimeToVNTime(symbol,open_times,index);
      double open = BinanceStringToDouble(opens,index);
      double close = BinanceStringToDouble(closes,index);
      double low = BinanceStringToDouble(lows,index);
      double high = BinanceStringToDouble(highs,index);
      double volume = BinanceStringToDouble(volumes,index);

      datetime haTime=time;
      double haClose=(open+close+high+low) / 4.0;
      double haOpen =(pre_cancle.open+pre_cancle.close) / 2.0;
      double haHigh =MathMax(MathMax(haOpen,haClose),high);
      double haLow  =MathMin(MathMin(haOpen,haClose),low);
      string haTrend=haClose>=haOpen ? TREND_BUY : TREND_SEL;

      int count_heiken=1;
      for(int j=index+1; j<length; j++)
        {
         if(haTrend==candleArray[j].trend_heiken)
            count_heiken+=1;
         else
            break;
        }

      CandleData candle_x(haTime,haOpen,haHigh,haLow,haClose,haTrend,count_heiken,0,"",0,"","","",0,"",0,"","",0,0,false,false,0,0,volume);
      candleArray[index]=candle_x;
     }

   double lowest=DBL_MAX,higest=0.0;
   for(int idx=0; idx <= length; idx++)
     {
      double low=candleArray[idx].low;
      double hig=candleArray[idx].high;
      if((idx==0) || (lowest==0) || (lowest>low))
         if(low>0)
            lowest=low;
      if((idx==0) || (higest==0) || (higest<hig))
         higest=hig;
     }

   if(is_calc_ma10)
     {
      double closePrices[];
      int maLength=length;
      ArrayResize(closePrices,maLength);

      for(int i=maLength-1; i>=0; i--)
         closePrices[i]=BinanceStringToDouble(closes,i);

      for(int index=ArraySize(candleArray)-5; index>=0; index--)
        {
         CandleData pre_cancle=candleArray[index+1];
         CandleData cur_cancle=candleArray[index];

         double ma03=cal_MA(closePrices, 3,index);
         double ma05=cal_MA(closePrices, 5,index);
         double ma10=cal_MA(closePrices,10,index);

         double mid=cur_cancle.close;
         string trend_vector_ma10=pre_cancle.ma10<ma10 ? TREND_BUY : TREND_SEL;

         string trend_by_ma05 =(mid>ma05) ? TREND_BUY : (mid<ma05) ? TREND_SEL : "";
         string trend_by_ma10 =(mid>ma10) ? TREND_BUY : (mid<ma10) ? TREND_SEL : "";
         string trend_ma03vs05=(ma03>ma05)? TREND_BUY : (ma03<ma05)? TREND_SEL : "";
         string trend_ma05vs10=(ma05>ma10)? TREND_BUY : (ma05<ma10)? TREND_SEL : "";

         double ma20=0;
         double ma50=0;
         bool allow_trade_now_by_seq_051020=false;
         bool allow_trade_now_by_seq_102050=false;

         string trend_ma10vs20="";
         string trend_by_seq_102050="";
         if(length>20 && index<=25)
           {
            ma20=cal_MA(closePrices,20,index);
            trend_ma10vs20=(ma10>ma20)? TREND_BUY : (ma10<ma20)? TREND_SEL : "";

            if((ma05>ma10 && ma10>ma20) || (ma05<ma10 && ma10<ma20))
              {
               double lowest_05_candles=DBL_MAX,higest_05_candles=0.0;
               for(int idx10=0; idx10 <= 5; idx10++)
                 {
                  double low=candleArray[idx10].low;
                  double hig=candleArray[idx10].high;
                  if((idx10==0) || (lowest_05_candles==0) || (lowest_05_candles>low))
                     if(low>0)
                        lowest_05_candles=low;
                  if((idx10==0) || (higest_05_candles==0) || (higest_05_candles<hig))
                     higest_05_candles=hig;
                 }

               if(lowest_05_candles<=ma50 && ma50<=higest_05_candles)
                  allow_trade_now_by_seq_051020=true;
              }

            if(length>35 && index<=25)
              {
               ma50=cal_MA(closePrices,50,index);

               double lowest_10_candles=DBL_MAX,higest_10_candles=0.0;
               for(int idx10=0; idx10 <= 10; idx10++)
                 {
                  double low=candleArray[idx10].low;
                  double hig=candleArray[idx10].high;
                  if((idx10==0) || (lowest_10_candles==0) || (lowest_10_candles>low))
                     if(low>0)
                        lowest_10_candles=low;
                  if((idx10==0) || (higest_10_candles==0) || (higest_10_candles<hig))
                     higest_10_candles=hig;
                 }

               double close_c1=candleArray[1].close;
               if(close_c1>=ma10 && ma10>=ma20 && ma20>=ma50 && ma10>=ma50 && ma50>0)
                 {
                  trend_by_seq_102050=TREND_BUY;

                  if(lowest_10_candles<=ma50 && ma50<=higest_10_candles)
                     allow_trade_now_by_seq_102050=true;
                 }

               if(close_c1<=ma10 && ma10<=ma20 && ma20<=ma50 && ma10<=ma50 && ma50>0)
                 {
                  trend_by_seq_102050=TREND_SEL;

                  if(lowest_10_candles<=ma50 && ma50<=higest_10_candles)
                     allow_trade_now_by_seq_102050=true;
                 }
              }
           }

         if(index==0 && length>30 && ma50==0)
            ma50=cal_MA(closePrices,50,index);

         int count_ma10=1;
         for(int j=index+1; j<length+1; j++)
           {
            if(trend_by_ma10==candleArray[j].trend_by_ma10)
               count_ma10+=1;
            else
               break;
           }


         int count_ma3_vs_ma5=1;
         for(int j=index+1; j<length+1; j++)
           {
            if(trend_ma03vs05==candleArray[j].trend_ma03vs05)
               count_ma3_vs_ma5+=1;
            else
               break;
           }

         CandleData candle_x(cur_cancle.time,cur_cancle.open,cur_cancle.high,cur_cancle.low,cur_cancle.close,cur_cancle.trend_heiken
                             ,cur_cancle.count_heiken,ma10,trend_by_ma10,count_ma10,trend_vector_ma10
                             ,trend_by_ma05,trend_ma03vs05,count_ma3_vs_ma5,trend_by_seq_102050,ma50,trend_ma10vs20,trend_ma05vs10,lowest,higest
                             ,allow_trade_now_by_seq_051020,allow_trade_now_by_seq_102050,ma20,ma05,cur_cancle.volume);

         candleArray[index]=candle_x;
        }

     }

   return cur_close_0;
  }
//+------------------------------------------------------------------+
double cal_MA(double& closePrices[],int ma_index,int candle_no=1)
  {
   int count=0;
   double ma=0.0;
   int lengh=(ArraySize(closePrices));
   for(int i=candle_no; i <= candle_no+ma_index; i++)
     {
      if(i<lengh)
        {
         count+=1;
         ma+=closePrices[i];
        }
     }
   ma /= count;

   return ma;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DeleteFileIfExists(string file_path)
  {
// Check if the file exists
   if(FileIsExist(file_path))
     {
      // Attempt to delete the file
      if(FileDelete(file_path))
        {
         //Print("File deleted successfully: ", file_path);
         return true;  // Return true if deletion was successful
        }
      else
        {
         Print("Failed to delete file: ", file_path, " Error: ", GetLastError());
         return false;  // Return false if deletion failed
        }
     }
   else
     {
      //Print("File does not exist: ", file_path);
      return false;  // Return false if the file does not exist
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetFile(const string file_path)
  {
   int handle = FileOpen(file_path, FILE_WRITE | FILE_TXT); // Mở file ở chế độ ghi mới
   if(handle != INVALID_HANDLE)
     {
      FileClose(handle); // Đóng ngay để xóa nội dung cũ
     }
   else
     {
      Print("Không thể tạo hoặc xóa nội dung file: ", file_path);
     }
  }
//+------------------------------------------------------------------+
void AppendToFile(const string filename, const string content)
  {
   int fileHandle;

// Mở tệp ở chế độ ghi cuối (FILE_WRITE | FILE_READ | FILE_ANSI)
   fileHandle = FileOpen(filename, FILE_WRITE|FILE_READ|FILE_ANSI);

   if(fileHandle != INVALID_HANDLE)
     {
      // Di chuyển con trỏ đến cuối tệp
      FileSeek(fileHandle, 0, SEEK_END);

      // Ghi một dòng mới vào cuối tệp
      FileWrite(fileHandle, content);

      // Đóng tệp
      FileClose(fileHandle);
     }
   else
     {
      Print("Error opening file: ", filename, " Error: ", GetLastError());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReadAllDataFromFile(
   const string filePath,
   string &times[],
   string &symbols[],
   string &opens[],
   string &highs[],
   string &lows[],
   string &closes[],
   string &volumes[])
  {
// Kiểm tra tệp có tồn tại hay không
   if(filePath=="" || filePath==" ")
      return;

   if(!FileIsExist(filePath))
     {
      printf("Không tìm thấy tệp: "+filePath);
      return;
     }

// Mở file để đọc
   int fileHandle = FileOpen(filePath, FILE_READ | FILE_CSV | FILE_ANSI, ';');

   if(fileHandle == INVALID_HANDLE)
     {
      PrintFormat("Không thể mở tệp: %s. Lỗi: %d", filePath, GetLastError());
      Print("5004: Tệp không tồn tại.");
      Print("5008: Quyền hạn không đủ.");
      Print("5014: Đường dẫn không hợp lệ.");
      return;
     }

// Đọc từng dòng từ file
   int lineIndex = 0;
   while(!FileIsEnding(fileHandle))
     {
      // Đọc dữ liệu trên mỗi dòng
      string line = FileReadString(fileHandle);

      if(line == "")
         continue; // Bỏ qua các dòng rỗng

      // Loại bỏ header (dòng đầu tiên)
      if(lineIndex == 0)
        {
         lineIndex++;
         continue;
        }

      // Tách dữ liệu từ dòng (giả định sử dụng dấu tab hoặc dấu ',' để tách)
      string fields[];
      int fieldCount = StringSplit(line, '\t', fields); // Hoặc ',' nếu file dùng dấu ','

      // Kiểm tra số lượng trường trên mỗi dòng
      if(fieldCount < 7)
        {
         PrintFormat("Dòng dữ liệu không hợp lệ: %s", line);
         continue;
        }

      // Resize các mảng để chứa dữ liệu mới
      ArrayResize(times, lineIndex);
      ArrayResize(symbols, lineIndex);
      ArrayResize(opens, lineIndex);
      ArrayResize(highs, lineIndex);
      ArrayResize(lows, lineIndex);
      ArrayResize(closes, lineIndex);
      ArrayResize(volumes, lineIndex);

      // Gán dữ liệu vào các mảng
      times[lineIndex - 1] = (fields[0]);
      symbols[lineIndex - 1] = fields[1];
      opens[lineIndex - 1] = (fields[2]);
      highs[lineIndex - 1] = (fields[3]);
      lows[lineIndex - 1] = (fields[4]);
      closes[lineIndex - 1] = (fields[5]);
      volumes[lineIndex - 1] = (fields[6]);

      //printf(opens[lineIndex - 1]);

      lineIndex++;
     }

// Đóng file sau khi đọc xong
   FileClose(fileHandle);

// Đảo ngược mảng dữ liệu để dữ liệu mới nhất nằm ở index 0
   ArrayReverse(opens);
   ArrayReverse(highs);
   ArrayReverse(lows);
   ArrayReverse(closes);
   ArrayReverse(times);

//PrintFormat("Đã đọc %d dòng dữ liệu từ file: %s", lineIndex - 1, filePath);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetTrendFromFileCk(string symbolCk,ENUM_TIMEFRAMES TF,
                        string &trend_ma20_mo,
                        string &trend_ma10_monthly, int &count_ma10_monthly,
                        string &trend_hei_monthly, int &count_hei_monthly,
                        string &trend_ma5_monthly, string &low_hig, double &PERCENT_LOW, double &PERCENT_HIG)
  {
   string ck_tf="4HOURS";
   if(TF==PERIOD_H1)
      ck_tf="1HOUR";
   if(TF==PERIOD_H4)
      ck_tf="4HOURS";
   if(TF==PERIOD_D1)
      ck_tf="DAILY";
   if(TF==PERIOD_W1)
      ck_tf="WEEKLY";
   if(TF==PERIOD_MN1)
      ck_tf="MONTHLY";

   string filePath = symbolCk+"_"+ck_tf+".txt";

   string open_times[], symbols[], opens[], highs[], lows[], closes[], volumes[];
   ReadAllDataFromFile(filePath, open_times, symbols, opens, highs, lows, closes, volumes);

   if(ArraySize(open_times)<5)
     {
      trend_ma20_mo="";

      trend_ma10_monthly="";
      count_ma10_monthly=-1;

      trend_hei_monthly="";
      count_hei_monthly=-1;

      trend_ma5_monthly="";
      return;
     }

   CandleData candleArray[];
   double cur_price=get_arr_heiken_binance(symbolCk,candleArray,open_times,opens,closes,lows,highs, volumes);

   trend_ma10_monthly=candleArray[0].trend_by_ma10;
   count_ma10_monthly=candleArray[0].count_ma10;

   trend_hei_monthly=candleArray[0].trend_heiken;
   count_hei_monthly=candleArray[0].count_heiken;

   trend_ma5_monthly=candleArray[0].ma05>candleArray[0].ma10?TREND_BUY:TREND_SEL;
   trend_ma20_mo=candleArray[0].close>candleArray[0].ma20?TREND_BUY:TREND_SEL;

   double real_lowest=DBL_MAX,real_higest=0.0;
   int size_d1 =(int)MathMin(ArraySize(candleArray)-9, NUM_CANDLE_DRAW);
   for(int i = 0; i < size_d1; i++)
     {
      double low=candleArray[i].low;
      double hig=candleArray[i].high;
      if((i==0) || (real_lowest==0) || (real_lowest>low))
         if(low>0)
            real_lowest=low;
      if((i==0) || (real_higest==0) || (real_higest<hig))
         real_higest=hig;
     }

   if(real_lowest>0 && real_higest>0 && cur_price>0)
     {
      double percent_drop = ((cur_price - real_lowest) / cur_price)  * 100.0;  // Tính % giảm giá từ giá hiện tại xuống real_lowest
      double percent_rise = ((real_higest - cur_price) / cur_price)  * 100.0; // Tính % tăng giá từ giá hiện tại lên real_higest
      double percent_up   = ((cur_price - real_lowest) / real_lowest)* 100.0;
      double fibo_0_382   = real_lowest + (real_higest - real_lowest)* 0.382;

      PERCENT_LOW=NormalizeDouble(percent_up,1);
      PERCENT_HIG=NormalizeDouble(percent_rise,1);

      low_hig = "(" +AppendSpaces(DoubleToString(PERCENT_LOW,1),5,false)+"%~" +AppendSpaces(DoubleToString(PERCENT_HIG,1),5,false)+"%)";

      if(candleArray[0].close<fibo_0_382)
         low_hig+=" #382";
      else
         low_hig+="     ";

      if(candleArray[0].ma05>0 && candleArray[0].ma10>0 && candleArray[0].ma20>0)
        {
         if(candleArray[0].ma05<candleArray[0].ma10 && candleArray[0].ma10<candleArray[0].ma20)
            low_hig+=" " + STR_SEQ_SEL; //SeqSel;

         if(candleArray[0].ma05>candleArray[0].ma10 && candleArray[0].ma10>candleArray[0].ma20)
            low_hig+=" " + STR_SEQ_BUY; //SeqBuy

         double ma50=candleArray[0].ma50;
         if((BinanceStringToDouble(lows,0)<ma50 && ma50<BinanceStringToDouble(highs,0)) ||
            (BinanceStringToDouble(lows,1)<ma50 && ma50<BinanceStringToDouble(highs,1)) ||
            (BinanceStringToDouble(lows,2)<ma50 && ma50<BinanceStringToDouble(highs,2)))
            low_hig+=" " + MASK_TOUCH_MA50;
        }


      double closeArray[];
      datetime timeFrArr[], timeToArr[];
      int size = ArraySize(candleArray);
      ArrayResize(closeArray, size);
      ArrayResize(timeFrArr, size);
      ArrayResize(timeToArr, size);

      for(int i = 0; i < size-10; i++)
        {
         closeArray[i] = candleArray[i].close;
         timeFrArr[i] = candleArray[i].time;
         timeToArr[i] = candleArray[i].time;
        }

      low_hig+=" {"+DrawAndCountHistogram("", closeArray, timeFrArr, timeToArr, false) + "}";
     }

   if(TF==PERIOD_H4)
     {
      bool Filter1BilVnd=GetGlobalVariable(BtnFilter1BilVnd)==FILTER_ON?true:false;
      if(Filter1BilVnd)
        {
         int count_vol=0;
         double total_volume = 0;
         for(int i=20; i>=0;i--)
           {
            count_vol+=1;
            total_volume+= candleArray[i].volume;
           }
         double avg_volume = (total_volume/count_vol)*candleArray[0].close/VOL_1BILLION_VND;//Tỷ VND

         if(avg_volume>=1)
            low_hig+= MORE_THAN_1_BIL_VND;
         else
            low_hig+= LESS_THAN_1_BIL_VND;

         //if(TF==PERIOD_MN1 && avg_volume<20)
         //   low_hig+= LESS_THAN_20_BIL_VND;
        }
     }

   if(TF==PERIOD_MN1)
     {
      double VOL_100BVND=70;

      bool Filter100BVnd=GetGlobalVariable(BtnFilter100BVnd)==FILTER_ON?true:false;
      if(Filter100BVnd)
        {
         double volume2 = candleArray[2].volume*candleArray[2].close/VOL_1BILLION_VND;//Tỷ VND
         double volume1 = candleArray[1].volume*candleArray[1].close/VOL_1BILLION_VND;//Tỷ VND
         if(volume2>=VOL_100BVND || volume1>=VOL_100BVND)
            low_hig+= MORE_THAN_100_BIL_VND;
         else
           {
            int count_vol=0;
            int loop = (int) MathMin(20, ArraySize(candleArray)-1);
            double total_volume = 0;
            for(int i=loop; i>=0;i--)
              {
               count_vol+=1;
               total_volume+= candleArray[i].volume;
              }
            double avg_volume = (total_volume/count_vol)*candleArray[0].close/VOL_1BILLION_VND;//Tỷ VND

            if(avg_volume>=VOL_100BVND)
               low_hig+= MORE_THAN_100_BIL_VND;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestReadAllDataFromFile(string symbolCk,ENUM_TIMEFRAMES TF, int chart_index)
  {
   string ck_tf="4HOURS";
   if(TF==PERIOD_H1)
      ck_tf="1HOUR";
   if(TF==PERIOD_H4)
      ck_tf="4HOURS";
   if(TF==PERIOD_D1)
      ck_tf="DAILY";
   if(TF==PERIOD_W1)
      ck_tf="WEEKLY";
   if(TF==PERIOD_MN1)
      ck_tf="MONTHLY";

   string filePath = symbolCk+"_"+ck_tf+".txt";

// Mảng lưu trữ dữ liệu
   string symbols[];
   string open_times[], opens[], highs[], lows[], closes[], volumes[];

// Gọi hàm để đọc dữ liệu
   ReadAllDataFromFile(filePath, open_times, symbols, opens, highs, lows, closes, volumes);

   int lineIndex=1;
   string scale_open_times[];
   int BarsCount=ArraySize(open_times);
   datetime current_time = TimeCurrent()+TIME_OF_ONE_W1_CANDLE*10;
   for(int i = 0; i < BarsCount; i++)
     {
      datetime scale_time = current_time-(i+1)*(GLOBAL_TIME_OF_ONE_CANDLE);
      //datetime bar_end   = current_time - i  *TIME_OF_ONE_W1_CANDLE;

      ArrayResize(scale_open_times, lineIndex);
      scale_open_times[lineIndex - 1] = (string)scale_time;
      lineIndex+=1;
     }

   if(ArraySize(open_times)>10)
      DrawChartAndSetGlobal(symbolCk,TF,scale_open_times,opens,closes,lows,highs,volumes,open_times,chart_index);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortSymbols(string &sorted_symbols[])
  {
// Separate into modifiable groups
   string hose[], hnx[], upcom[];

// Separate symbols into groups
   for(int i = 0; i < ArraySize(ARR_SYMBOLS_CK); i++)
     {
      if(StringFind(ARR_SYMBOLS_CK[i], "HOSE_") == 0)
        {
         ArrayResize(hose, ArraySize(hose) + 1);
         hose[ArraySize(hose) - 1] = ARR_SYMBOLS_CK[i];
        }
      else
         if(StringFind(ARR_SYMBOLS_CK[i], "HNX_") == 0)
           {
            ArrayResize(hnx, ArraySize(hnx) + 1);
            hnx[ArraySize(hnx) - 1] = ARR_SYMBOLS_CK[i];
           }
         else
            if(StringFind(ARR_SYMBOLS_CK[i], "UPCOM_") == 0)
              {
               ArrayResize(upcom, ArraySize(upcom) + 1);
               upcom[ArraySize(upcom) - 1] = ARR_SYMBOLS_CK[i];
              }
     }

// Sort modifiable arrays
   SortArray(hose);
   SortArray(hnx);
   SortArray(upcom);

// Combine results into sorted_symbols
   ArrayResize(sorted_symbols, 1);
   sorted_symbols[0] = "HOSE_VNINDEX";  // Ensure HOSE_VNINDEX is first

// Append sorted groups to sorted_symbols
   for(int i = 0; i < ArraySize(hose); i++)
     {
      if(hose[i] != "HOSE_VNINDEX")
        {
         ArrayResize(sorted_symbols, ArraySize(sorted_symbols) + 1);
         sorted_symbols[ArraySize(sorted_symbols) - 1] = hose[i];
        }
     }
   for(int i = 0; i < ArraySize(hnx); i++)
     {
      ArrayResize(sorted_symbols, ArraySize(sorted_symbols) + 1);
      sorted_symbols[ArraySize(sorted_symbols) - 1] = hnx[i];
     }
   for(int i = 0; i < ArraySize(upcom); i++)
     {
      ArrayResize(sorted_symbols, ArraySize(sorted_symbols) + 1);
      sorted_symbols[ArraySize(sorted_symbols) - 1] = upcom[i];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortArray(string &arr[])
  {
   int size = ArraySize(arr);
   for(int i = 0; i < size - 1; i++)
     {
      for(int j = 0; j < size - i - 1; j++)
        {
         // Compare two elements and swap if needed
         if(StringCompare(arr[j], arr[j + 1]) > 0)
           {
            string temp = arr[j];
            arr[j] = arr[j + 1];
            arr[j + 1] = temp;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_tool_tip_ck(string symbol)
  {
   int size=ArraySize(ARR_SYMBOLS_TOOL_TIP_CK);
   for(int i=0;i<size;i++)
      if(is_same_symbol(ARR_SYMBOLS_TOOL_TIP_CK[i],symbol))
         return ARR_SYMBOLS_TOOL_TIP_CK[i];

   return symbol;
  }
string ARR_SYMBOLS_TOOL_TIP_CK[] =
  {
   "HOSE_VNINDEX "+GROUP_NGANHANG
   ,"HOSE_ACB NHTMCP Á Châu (ACB) "+GROUP_NGANHANG
   ,"HOSE_BID Đầu tư và Phát triển Việt Nam (BIDV Big4) "+GROUP_NGANHANG
   ,"HOSE_CTG NHTMCP Công Thương VN (VietinBank Big4) "+GROUP_NGANHANG
   ,"HOSE_EIB NHTMCP Xuất Nhập khẩu VN (Eximbank) "+GROUP_NGANHANG
   ,"HOSE_HDB NHTMCP Phát triển TP.HCM (HDBank) "+GROUP_NGANHANG
   ,"HOSE_LPB NHTMCP Bưu điện Liên Việt (LienVietPostBank) "+GROUP_NGANHANG
   ,"HOSE_MBB NHTMCP Quân Đội (MB Bank) "+GROUP_NGANHANG
   ,"HOSE_OCB NHTMCP Phương Đông (OCB) "+GROUP_NGANHANG
   ,"HOSE_SHB NHTMCP Sài Gòn – HN (SHB) "+GROUP_NGANHANG
   ,"HOSE_SSB NHTMCP Đông Nam Á (SeABank) "+GROUP_NGANHANG
   ,"HOSE_STB NHTMCP Sài Gòn Thương Tín (Sacombank) "+GROUP_NGANHANG
   ,"HOSE_TCB NHTMCP Kỹ Thương VN (Techcombank) "+GROUP_NGANHANG
   ,"HOSE_TPB NHTMCP Tiên Phong (TPBank) "+GROUP_NGANHANG
   ,"HOSE_VCB NHTMCP Ngoại Thương VN (Vietcombank Big4) "+GROUP_NGANHANG
   ,"HOSE_VIB NHTMCP Quốc tế VN (VIB) "+GROUP_NGANHANG
   ,"HOSE_VPB NHTMCP VN Thịnh Vượng (VPBank) "+GROUP_NGANHANG
   ,"HNX_NVB NHTMCP Quốc Dân (NCB) "+GROUP_NGANHANG
   ,"HNX_BAB Bắc Á "+GROUP_NGANHANG
   ,"UPCOM_ABB An Bình "+GROUP_NGANHANG
   ,"UPCOM_BVB Bản Việt "+GROUP_NGANHANG
   ,"UPCOM_KLB Kiên Long "+GROUP_NGANHANG
   ,"UPCOM_SGB Sài Gòn Công Thương (Saigonbank) "+GROUP_NGANHANG
   ,"UPCOM_PVC Đại Chúng Việt Nam (PVcomBank) "+GROUP_NGANHANG
   ,"UPCOM_GPB Dầu Khí Toàn Cầu (GPBank) "+GROUP_NGANHANG


   ,"HOSE_AAA CTCP Nhựa An Phát Xanh "+GROUP_OTHERS
   ,"HOSE_ANV CTCP Nam Việt "+GROUP_OTHERS
   ,"HOSE_ASM CTCP Tập đoàn Sao Mai "+GROUP_OTHERS
   ,"HOSE_BCG CTCP Tập đoàn Bamboo Capital "+GROUP_DIEN
   ,"HOSE_BCM TCty ĐT&PT Công nghiệp - CTCP "+GROUP_CONGNGHIEP
   ,"HOSE_BMP CTCP Nhựa Bình Minh "+GROUP_OTHERS
   ,"HOSE_BSI CTCP Chứng khoán BIDV "+GROUP_CHUNGKHOAN
   ,"HOSE_BVH Tập đoàn Bảo Việt "+GROUP_OTHERS
   ,"HOSE_BWE CTCP - TCty Nước – Môi trường Bình Dương "+GROUP_OTHERS
   ,"HOSE_CII CTCP Đầu tư Hạ tầng Kỹ thuật TP.HCM "+GROUP_CONGNGHIEP
   ,"HOSE_CMG CTCP Tập đoàn Công nghệ CMC "+GROUP_OTHERS
   ,"HOSE_CRE CTCP BĐS Thế Kỷ "+GROUP_BATDONGSAN
   ,"HOSE_CTD CTCP Xây dựng COTECCONS "+GROUP_BATDONGSAN
   ,"HOSE_CTR Tổng CTCP Công trình Viettel "+GROUP_CONGNGHIEP
   ,"HOSE_DBC CTCP Tập đoàn DABACO VN "+GROUP_OTHERS
   ,"HOSE_DCM CTCP Phân bón Dầu khí Cà Mau "+GROUP_PHANBON+GROUP_DAUKHI
   ,"HOSE_BFC CTCP Phân bón Bình Điền "+GROUP_PHANBON
   ,"HOSE_DGC CTCP Tập đoàn Hóa chất Đức Giang "+GROUP_PHANBON
   ,"HOSE_DGW CTCP Thế Giới Số "+GROUP_OTHERS
   ,"HOSE_DIG Tổng CTCP ĐT&PT Xây dựng (A7) "+GROUP_BATDONGSAN
   ,"HOSE_DPM TCty Phân bón và Hóa chất Dầu khí - CTCP "+GROUP_PHANBON+GROUP_DAUKHI
   ,"HOSE_DXG CTCP Tập đoàn Đất Xanh "+GROUP_BATDONGSAN
   ,"HOSE_DXS CTCP Dịch vụ BĐS Đất Xanh "+GROUP_BATDONGSAN
   ,"HOSE_EVF Công ty Tài chính CP Điện lực "+GROUP_CHUNGKHOAN+GROUP_DIEN
   ,"HOSE_FPT CTCP FPT "+GROUP_OTHERS
   ,"HOSE_FRT CTCP Bán lẻ Kỹ thuật số FPT(chuỗi nhà thuốc Long Châu) "+GROUP_OTHERS+GROUP_DUOCPHAM
   ,"HOSE_FTS CTCP Chứng khoán FPT "+GROUP_CHUNGKHOAN
   ,"HOSE_GAS TCty Khí VN - CTCP "+GROUP_DAUKHI
   ,"HOSE_GEX CTCP Tập đoàn GELEX "+GROUP_BATDONGSAN
   ,"HOSE_GMD CTCP GEMADEPT "+GROUP_DUOCPHAM
   ,"HOSE_GVR Tập đoàn Công nghiệp Cao su VN - CTCP "+GROUP_CONGNGHIEP
   ,"HOSE_HAG CTCP Hoàng Anh Gia Lai "+GROUP_OTHERS
   ,"HOSE_HCM CTCP Chứng khoán TP.HCM "+GROUP_CHUNGKHOAN
   ,"HOSE_HDC CTCP Phát triển nhà Bà Rịa – Vũng Tàu "+GROUP_BATDONGSAN
   ,"HOSE_HDG CTCP Tập đoàn Hà Đô "+GROUP_BATDONGSAN
   ,"HOSE_HHV CTCP Đầu tư Hạ tầng Giao thông Đèo Cả "+GROUP_CONGNGHIEP
   ,"HOSE_HPG CTCP Tập đoàn Hòa Phát "+GROUP_THEP
   ,"HOSE_HSG CTCP Tập đoàn Hoa Sen "+GROUP_THEP
   ,"HNX_VGS CTCP Tập đoàn Hoa Sen "+GROUP_THEP
   ,"UPCOM_TVN CTCP Tập đoàn Hoa Sen "+GROUP_THEP
   ,"HOSE_HT1 CTCP Xi măng VICEM Hà Tiên "+GROUP_CONGNGHIEP
   ,"HOSE_HVN Tổng Công ty Hàng không VN Airlines "+GROUP_OTHERS
   ,"HOSE_IMP CTCP Dược phẩm Imexpharm "+GROUP_DUOCPHAM
   ,"HOSE_KBC TCty Phát triển Đô Thị Kinh Bắc – CTCP "+GROUP_CONGNGHIEP
   ,"HOSE_KDC CTCP Tập đoàn Kido "+GROUP_OTHERS
   ,"HOSE_KDH CTCP Đầu tư và Kinh doanh Nhà Khang Điền "+GROUP_BATDONGSAN
   ,"HOSE_KOS CTCP KOSY "+GROUP_OTHERS
   ,"HOSE_MSB NHTMCP Hàng Hải VN "+GROUP_NGANHANG
   ,"HOSE_MSN CTCP Tập đoàn MaSan "+GROUP_OTHERS
   ,"HOSE_MWG CTCP Đầu tư Thế Giới Di Động "+GROUP_OTHERS
   ,"HOSE_NKG CTCP Thép Nam Kim "+GROUP_THEP
   ,"HOSE_NLG CTCP Đầu tư Nam Long "+GROUP_CHUNGKHOAN
   ,"HOSE_NT2 CTCP Điện lực Dầu khí Nhơn Trạch 2 "+GROUP_DAUKHI+GROUP_DIEN
   ,"HOSE_NVL CTCP Tập đoàn Đầu tư Địa ốc Novaland "+GROUP_BATDONGSAN
   ,"HOSE_PAN CTCP Tập đoàn PAN "+GROUP_OTHERS
   ,"HOSE_PC1 CTCP Tập đoàn PC1 "+GROUP_OTHERS
   ,"HOSE_PDR CTCP Phát triển BĐS Phát Đạt "+GROUP_BATDONGSAN
   ,"HOSE_PHR CTCP Cao su Phước Hòa "+GROUP_OTHERS
   ,"HOSE_PLX Tập đoàn Xăng dầu VN "+GROUP_DAUKHI
   ,"HOSE_PNJ CTCP Vàng bạc Đá quý Phú Nhuận "+GROUP_OTHERS
   ,"HOSE_POW TCty Điện lực Dầu khí VN - CTCP "+GROUP_DIEN+GROUP_DAUKHI
   ,"HOSE_PPC CTCP Nhiệt điện Phả Lại "+GROUP_DIEN
   ,"HOSE_PTB CTCP Phú Tài "+GROUP_CHUNGKHOAN
   ,"HOSE_PVD Tổng CTCP Khoan và Dịch vụ Khoan Dầu khí "+GROUP_DAUKHI
   ,"HOSE_PVT Tổng CTCP Vận tải Dầu khí "+GROUP_DAUKHI
   ,"HOSE_PVP CTCP Vận tải Dầu khí TBD "+GROUP_DAUKHI
   ,"HOSE_REE CTCP Cơ Điện Lạnh "+GROUP_CONGNGHIEP
   ,"HOSE_SAB TCTCP Bia – Rượu – Nước giải khát Sài Gòn "+GROUP_OTHERS
   ,"HOSE_SBT CTCP Thành Thành Công - Biên Hòa "+GROUP_OTHERS
   ,"HOSE_SCS CTCP Dịch vụ Hàng hóa Sài Gòn "+GROUP_OTHERS
   ,"HOSE_SIP CTCP Đầu tư Sài Gòn VRG "+GROUP_CHUNGKHOAN
   ,"HOSE_SJS Công ty Đầu tư Phát triển Đô thị và Khu công nghiệp Sông Đà "+GROUP_OTHERS
   ,"HOSE_SSI CTCP Chứng khoán SSI "+GROUP_CHUNGKHOAN
   ,"HOSE_SZC CTCP Sonadezi Châu Đức "+GROUP_BATDONGSAN
   ,"HOSE_TCH CTCP ĐTDV Tài chính Hoàng Huy "+GROUP_CHUNGKHOAN
   ,"HOSE_TLG CTCP Tập đoàn Thiên Long "+GROUP_OTHERS
   ,"HOSE_VCG Tổng CTCP Xuất nhập khẩu và Xây dựng VN "+GROUP_DAVINCI+GROUP_CONGNGHIEP
   ,"HOSE_FCN Công tyCP FECON (nền móng, công trình ngầm) "+GROUP_DAVINCI+GROUP_CONGNGHIEP
   ,"HOSE_KSB CTCP Khoáng sản và Xây dựng Bình Dương (Khai thác mỏ, BĐSKCN) "+GROUP_DAVINCI+GROUP_CONGNGHIEP
   ,"HOSE_HHV CTCP Đầu tư Hạ tầng Giao thông Đèo Cả "+GROUP_DAVINCI+GROUP_CONGNGHIEP
   ,"HOSE_CKG CTCP Tập đoàn Tư vấn Đầu tư Xây dựng Kiên Giang "+GROUP_DAVINCI+GROUP_CONGNGHIEP
   ,"HOSE_DC4 Công tyCP DIC số 4 (Bà Rịa - Vũng Tàu) "+GROUP_DAVINCI+GROUP_CONGNGHIEP
   ,"HOSE_VCI CTCP Chứng khoán Vietcap "+GROUP_CHUNGKHOAN
   ,"HOSE_VGC TCty Viglacera - CTCP "+GROUP_CONGNGHIEP
   ,"HOSE_VHC CTCP Vĩnh Hoàn (nuôi trồng và chế biến cá tra) "+GROUP_OTHERS
   ,"HOSE_VHM CTCP Vinhomes "+GROUP_BATDONGSAN
   ,"HOSE_VIC Tập đoàn Vingroup - CTCP "+GROUP_OTHERS
   ,"HOSE_VIX CTCP Chứng khoán VIX "+GROUP_CHUNGKHOAN
   ,"HOSE_VJC CTCP Hàng không VietJet "+GROUP_OTHERS
   ,"HOSE_VND CTCP Chứng khoán VNDIRECT "+GROUP_CHUNGKHOAN
   ,"HOSE_VNM CTCP Sữa VN "+GROUP_OTHERS
   ,"HOSE_VPI CTCP Đầu tư Văn Phú - Invest "+GROUP_CHUNGKHOAN
   ,"HOSE_VRE CTCP Vincom Retail "+GROUP_OTHERS
   ,"HOSE_VSH CTCP Thủy điện Vĩnh Sơn - Sông Hinh "+GROUP_DIEN
   ,"HOSE_TCM CTCP Dệt may - Đầu tư - Thương mại Thành Công "+GROUP_MAYMAC
   ,"HOSE_CCL CTCP ĐT&PT Đô Thị Dầu khí Cửu Long "+GROUP_DAUKHI
   ,"HOSE_HAR CTCP Đầu tư Thương mại BĐS An Dương Thảo Điền "+GROUP_BATDONGSAN
   ,"HOSE_SZL CTCP Sonadezi Long Thành "+GROUP_BATDONGSAN
   ,"HOSE_D2D CTCP Phát triển Đô thị Công nghiệp Số 2 "+GROUP_CONGNGHIEP+GROUP_BATDONGSAN
   ,"HOSE_TDC CTCP Kinh doanh và Phát triển Bình Dương "+GROUP_BATDONGSAN
   ,"HOSE_AGR CTCP Chứng khoán Agribank (chỉ là ck, còn chưa lên sàn Big4) "+GROUP_CHUNGKHOAN
   ,"HOSE_LHG CTCP Xây dựng Long Hậu "+GROUP_BATDONGSAN
   ,"HOSE_NHA TCT ĐT&PT Nhà và Đô thị Nam HN "+GROUP_BATDONGSAN
   ,"HOSE_NTL CTCP Phát triển Đô thị Từ Liêm "+GROUP_BATDONGSAN
   ,"HOSE_IJC CTCP Phát triển Hạ tầng Kỹ thuật Bình Dương "+GROUP_CONGNGHIEP
   ,"HOSE_QCG CTCP Quốc Cường Gia Lai "+GROUP_BATDONGSAN
   ,"HOSE_MSH CTCP May Sông Hồng "+GROUP_MAYMAC
   ,"UPCOM_HBC Tập đoàn Xây dựng Hòa Bình "+GROUP_BATDONGSAN
   ,"UPCOM_PDV CTCP Vận Tải Và Tiếp Vận Phương Đông Việt "+GROUP_DAUKHI
   ,"HNX_VC3 CTCP Xây dựng Số 3 "+GROUP_CONGNGHIEP
   ,"HNX_IDV CTCP Phát triển Hạ tầng Vĩnh Phúc "+GROUP_CONGNGHIEP
   ,"HNX_IDC TCty ĐT&PT đô thị & KCNVN IDICO, nhà KCN "+GROUP_CONGNGHIEP
   ,"HOSE_TEG CTCP Năng lượng mặt trời và Bất động sản Trường Thành "+GROUP_CONGNGHIEP+GROUP_DIEN
   ,"HOSE_PNC CTCP Văn hóa Phương Nam "+GROUP_OTHERS
   ,"HOSE_TMT CTCP Ô tô TMT "+GROUP_CONGNGHIEP
   ,"HOSE_SFC CTCP Nhiên liệu Sài Gòn "+GROUP_CONGNGHIEP
   ,"HOSE_DTT CTCP Kỹ nghệ Đô Thành (chai nhựa) "+GROUP_CONGNGHIEP
   ,"HOSE_OGC CTCP Tập đoàn Đại Dương "+GROUP_OTHERS
   ,"HOSE_BAF CTCP Nông nghiệp BAF(nuôi heo) "+GROUP_OTHERS
   ,"HNX_MBS CTCP Chứng khoán MB (bởi Ngân hàng MB) "+GROUP_CHUNGKHOAN
   ,"HNX_TNG CTCP TNG lĩnh vực may công nghiệp xuất khẩu "+GROUP_MAYMAC
   ,"HNX_PVS TCTCP Dịch vụ Kỹ thuật Dầu khí VN "+GROUP_DAUKHI
   ,"HNX_VC7 Xây dựng các công trình dân dụng, công nghiệp "+GROUP_CONGNGHIEP
   ,"HNX_AAV CTCP Việt Tiên Sơn Địa Ốc "+GROUP_BATDONGSAN
   ,"HNX_DTD CTCP Đầu tư Phát triển Thành Đạt(xây dựng) "+GROUP_CONGNGHIEP+GROUP_BATDONGSAN
   ,"HNX_LAS CTCP Supe Phốt phát và Hóa chất Lâm Thao "+GROUP_CONGNGHIEP
   ,"HNX_MST CTCP Đầu tư MST (xây lắp công trình, đá, cát, sỏi) "+GROUP_CONGNGHIEP
   ,"HNX_VMS CTCP Phát triển Hàng Hải (kho bãi, bốc xếp) "+GROUP_CONGNGHIEP
   ,"HNX_VHL Viglacera Ha Long "+GROUP_CONGNGHIEP
   ,"HNX_VE3 CTCP Xây dựng Điện VNECO3 "+GROUP_CONGNGHIEP
   ,"HNX_SVN CTCP Tập đoàn Vexilla (vốn 500 triệu) "+GROUP_CONGNGHIEP
   ,"HNX_FID CTCP Đầu tư và Phát triển Doanh nghiệp "+GROUP_CHUNGKHOAN
   ,"HNX_DTK TCT Điện lực TKV Vinacomin(quản lý 5 nhà máy nhiệt điện) "+GROUP_CONGNGHIEP
   ,"HNX_STP CTCP Công nghiệp Thương mại Sông Đà "+GROUP_CONGNGHIEP+GROUP_DIEN
   ,"UPCOM_VIW TCT Đầu tư Nước và Môi trường VN "+GROUP_CONGNGHIEP
   ,"UPCOM_MSR MASAN RESOURCES JSC "+GROUP_CONGNGHIEP
   ,"UPCOM_VGT Tập đoàn Dệt May VN "+GROUP_MAYMAC
   ,"UPCOM_HNG CTCP Nông nghiệp Quốc tế Hoàng Anh Gia Lai "+GROUP_OTHERS
   ,"HOSE_SKG Công ty TNHH Tàu cao tốc Superdong - Kiên Giang "+GROUP_OTHERS
   ,"HOSE_CSM CTCP Công nghiệp Cao su Miền Nam "+GROUP_OTHERS
   ,"HOSE_TNH Công tyCP Bệnh viện Quốc tế Thái Nguyên "+GROUP_OTHERS

   , "HNX_BCC CTCP Xi măng Bỉm Sơn"
   , "HNX_BVS Công ty Cổ phần Chứng khoán Bảo Việt"
   , "HNX_CAP Công ty Cổ phần lâm nông sản thực phẩm Yên Bái"
   , "HNX_DVM CTCP Dược liệu Việt Nam"
   , "HNX_HLD CTCP Đầu tư và phát triển Bất động sản HUDLAND"
   , "HNX_HUT CTCP Tasco"
   , "HNX_L14 CTCP Licogi 14"
   , "HNX_L18 CTCP Đầu tư và Xây dựng số 18"
   , "HNX_LHC CTCP Đầu tư và Xây dựng Thủy lợi Lâm Đồng"
   , "HNX_NBC CTCP Than Núi Béo – Vinacomin"
   , "HNX_PLC Tổng Công ty Hóa dầu Petrolimex – CTCP"+GROUP_DAUKHI
   , "HNX_PSI Công ty Cổ phần Chứng khoán Dầu khí"
   , "HNX_PVC Tổng Công ty Hóa chất và Dịch vụ Dầu khí – CTCP (PVChem)"+GROUP_DAUKHI
   , "HNX_PVG Công ty cổ phần Kinh doanh LPG Việt Nam"
   , "HNX_SHS Công ty Cổ phần chứng khoán Sài Gòn – Hà Nội"
   , "HNX_SLS CTCP Mía đường Sơn La"
   , "HNX_TIG CTCP Tập đoàn Đầu tư Thăng Long"
   , "HNX_TVD CTCP Than Vàng Danh – Vinacomin"
   , "HNX_VCS CTCP VICOSTONE"
   , "HNX_VIG Công ty cổ phần Chứng khoán Đầu tư Tài chính Việt Nam"

   , "UPCOM_VEA Tổng Công ty Máy động lực và Máy nông nghiệp VN"
   , "UPCOM_MCH CTCP Hàng tiêu dùng Masan"
   , "UPCOM_MML CTCP Masan MeatLife"
   , "UPCOM_MSR CTCP Masan High-Tech Materials"
   , "UPCOM_VEF CTCP Trung tâm Hội chợ Triển lãm VN"
   , "UPCOM_FOX CTCP Viễn thông FPT"







   ,"HOSE_AAM Công ty Cổ phần Thủy sản Mekong"
   ,"UPCOM_ABC Công ty cổ phần Truyền thông VMG"
   ,"UPCOM_ABI Công ty Cổ phần Bảo hiểm Ngân hàng Nông nghiệp"
   ,"HOSE_ABT Công ty Cổ phần Xuất nhập khẩu Thủy sản Bến Tre"
   ,"HOSE_ACC Công ty cổ phần Bê tông Becamex"
   ,"UPCOM_ACE Công ty Cổ phần Bê tông ly tâm An Giang"
   ,"HOSE_ACL Công ty cổ phần Xuất nhập khẩu Thủy sản Cửu Long An Giang"
   ,"UPCOM_ACV Tổng công ty Cảng hàng không Việt Nam - CTCP"
   ,"HNX_ADC Công ty Cổ phần Mĩ thuật và Truyền thông"
   ,"HOSE_ADS Công ty cổ phần Damsan"
   ,"UPCOM_AFX Công ty Cổ phần Xuất nhập khẩu Nông sản Thực phẩm An Giang"
   ,"HOSE_AGM Công ty cổ phần Xuất nhập khẩu An Giang"
   ,"UPCOM_AGP CTCP Dược phẩm Agimexpharm"
   ,"UPCOM_AGX Công ty cổ phần Thực phẩm Nông sản Xuất khẩu Sài Gòn"
   ,"HNX_ALT Công ty Cổ phần Văn hóa Tân Bình"
   ,"HNX_AMC Công ty cổ phần Khoáng sản Á Châu"
   ,"HNX_AME Công ty Cổ phần Alphanam E&C"
   ,"UPCOM_AMP Công ty Cổ phần Armephaco"
   ,"UPCOM_AMS Công ty Cổ phần Cơ khí xây dựng AMECC"
   ,"HNX_AMV CTCP Sản xuất Kinh doanh Dược và Trang thiết bị Y tế Việt Mỹ"
   ,"UPCOM_ANT CTCP Rau quả Thực phẩm An Giang"
   ,"HNX_API Công ty Cổ phần Đầu tư Châu Á - Thái Bình Dương"
   ,"UPCOM_APL CTCP Cơ khí và Thiết bị áp lực - VVMI"
   ,"HNX_ARM Công ty Cổ phần Xuất nhập khẩu Hàng không"
   ,"HOSE_ASP Công ty Cổ phần Tập đoàn Dầu khí An Pha"
   ,"UPCOM_ATA Công ty Cổ phần NTACO"
   ,"HNX_ATS CTCP Suất ăn công nghiệp Atesco"
   ,"UPCOM_AVF Công ty Cổ phần Việt An"
   ,"HNX_BAX Công ty Cổ phần Thống Nhất"
   ,"HOSE_BBC Công ty Cổ phần Bibica"
   ,"HNX_BBS Công ty cổ phần VICEM Bao bì Bút Sơn"
   ,"HOSE_BCE Công ty Cổ phần Xây dựng và Giao thông Bình Dương"
   ,"HOSE_BCG Công ty cổ phần Bamboo Capital"
   ,"UPCOM_BCP Công ty cổ phần Dược Becamex"
   ,"UPCOM_BDG CTCP May mặc Bình Dương"
   ,"UPCOM_BDW Công ty cổ phần Cấp thoát nước Bình Định"
   ,"UPCOM_BHC Công ty Cổ phần Bê tông Biên Hòa"
   ,"HOSE_BHN Tổng CTCP Bia - Rượu - Nước giải khát Hà Nội"
   ,"UPCOM_BHP Công ty Cổ phần Bia Hà Nội - Hải Phòng"
   ,"HOSE_BIC Tổng Công ty Cổ phần Bảo hiểm Ngân hàng Đầu tư và phát triển Việt Nam"
   ,"HNX_BKC Công ty Cổ phần Khoáng sản Bắc Kạn"
   ,"UPCOM_BLI Tổng Công ty cổ phần Bảo hiểm Bảo Long"
   ,"UPCOM_BLN CTCP Vận tải và Dịch vụ Liên Ninh"
   ,"HOSE_BMC Công ty cổ phần Khoáng sản Bình Định"
   ,"HOSE_BMI Tổng Công ty Cổ phần Bảo Minh"
   ,"UPCOM_BMJ Công ty Cổ phần Khoáng sản Becamex"
   ,"UPCOM_BMN Công ty Cổ phần 715"
   ,"HNX_BPC Công ty cổ phần Vicem Bao bì Bỉm Sơn"
   ,"HOSE_BRC Công ty Cổ phần Cao su Bến Thành"
   ,"UPCOM_BRS Công ty Cổ phần Dịch vụ đô thị Bà Rịa"
   ,"HNX_BSC Công ty Cổ phần Dịch vụ Bến Thành"
   ,"UPCOM_BSG Công ty Cổ phần Xe khách Sài Gòn"
   ,"UPCOM_BSP CTCP Bia Sài Gòn - Phú Thọ"
   ,"UPCOM_BSQ Công ty cổ phần Bia Sài Gòn - Quảng Ngãi"
   ,"UPCOM_BT1 Công ty cổ phần Bảo vệ Thực vật 1 Trung ương"
   ,"UPCOM_BT6 Công ty Cổ phần Beton 6"
   ,"UPCOM_BTB Công ty Cổ phần Bia Hà Nội - Thái Bình"
   ,"UPCOM_BTD Công ty Cổ phần Bê tông Ly tâm Thủ Đức"
   ,"UPCOM_BTG Công ty Cổ phần Bao bì Tiền Giang"
   ,"HOSE_BTP Công ty Cổ phần Nhiệt điện Bà Rịa"
   ,"HNX_BTS Công ty cổ phần Xi măng Vicem Bút Sơn"
   ,"HOSE_BTT Công ty Cổ phần Thương mại - Dịch vụ Bến Thành"
   ,"UPCOM_BTU CTCP Công trình Đô thị Bến Tre"
   ,"UPCOM_BVG Công ty Cổ phần Đầu tư BVG"
   ,"UPCOM_BVN Công ty cổ phần Bông Việt Nam"
   ,"UPCOM_BWA Công ty Cổ phần Cấp thoát nước và Xây dựng Bảo Lộc"
   ,"HNX_BXH Công ty cổ phần VICEM Bao bì Hải Phòng"
   ,"UPCOM_C12 Công ty Cổ phần Cầu 12 - Cienco 1"
   ,"UPCOM_C21 Công ty cổ phần Thế kỷ 21"
   ,"HOSE_C32 Công ty Cổ phần Đầu tư Xây dựng 3-2"
   ,"HOSE_C47 Công ty Cổ phần Xây dựng 47"
   ,"UPCOM_CAD Công ty Cổ phần Chế biến và Xuất nhập khẩu Thủy sản CADOVIMEX"
   ,"HNX_CAN Công ty Cổ phần Đồ hộp Hạ Long"
   ,"HOSE_CCI Công ty Cổ phần Đầu tư Phát triển Công nghiệp - Thương mại Củ Chi"
   ,"UPCOM_CCV Công ty cổ phần Tư vấn Xây dựng Công nghiệp và Đô thị Việt Nam"
   ,"HOSE_CDC Công ty Cổ phần Chương Dương"
   ,"UPCOM_CDG Công ty Cổ phần Cầu Đuống"
   ,"HNX_CDN Công ty cổ phần Cảng Đà Nẵng"
   ,"HNX_CEO Công ty Cổ phần Tập đoàn C.E.O"
   ,"UPCOM_CHC Công ty Cổ phần Cẩm Hà"
   ,"HOSE_CHP Công ty Cổ phần Thủy điện miền Trung"
   ,"UPCOM_CHS Công ty Cổ phần Chiếu sáng Công cộng Thành phố Hồ Chí Minh"
   ,"UPCOM_CI5 Công ty cổ phần Đầu tư Xây dựng số 5"
   ,"UPCOM_CID Công ty Cổ phần Xây dựng và Phát triển Cơ sở Hạ tầng"
   ,"HOSE_CIG Công ty Cổ phần COMA18"
   ,"HNX_CJC Công ty Cổ phần Cơ điện Miền Trung"
   ,"UPCOM_CKD Công ty cổ phần Cơ khí Đông Anh Licogi"
   ,"HNX_CKV Công ty Cổ phần COKYVINA"
   ,"HOSE_CLC Công ty Cổ phần Cát Lợi"
   ,"HNX_CLH Công ty cổ phần Xi măng La Hiên VVMI"
   ,"HOSE_CLL Công ty cổ phần Cảng Cát Lái"
   ,"HNX_CLM CTCP Xuất nhập khẩu Than - Vinacomin"
   ,"HOSE_CLW Công ty Cổ phần Cấp nước Chợ Lớn"
   ,"UPCOM_CLX Công ty Cổ phần Xuất nhập khẩu và Đầu tư Chợ Lớn"
   ,"HNX_CMC Công ty Cổ phần Đầu tư CMC"
   ,"UPCOM_CMF Công ty Cổ phần Thực phẩm Cholimex"
   ,"HNX_CMS Công ty cổ phần Xây dựng và Nhân lực Việt Nam"
   ,"HOSE_CMV Công ty Cổ phần Thương nghiệp Cà Mau"
   ,"HOSE_CMX Công ty Cổ phần Chế biến và Xuất nhập khẩu Thủy sản Cà Mau"
   ,"UPCOM_CNC Công ty cổ phần Công nghệ cao Traphaco"
   ,"HOSE_CNG Công ty cổ phần CNG Việt Nam"
   ,"UPCOM_CNN CTCP Tư vấn công nghệ, thiết bị và kiểm định xây dựng - CONINCO"
   ,"UPCOM_CNT Công ty Cổ phần Xây dựng và Kinh doanh Vật tư"
   ,"HOSE_COM Công ty Cổ phần Vật tư - Xăng dầu"
   ,"HNX_CPC Công ty Cổ phần Thuốc sát trùng Cần Thơ"
   ,"UPCOM_CQT Công ty cổ phần Xi măng Quán Triều VVMI"
   ,"HNX_CSC Công ty Cổ phần Đầu tư và Xây dựng Thành Nam"
   ,"HOSE_CSV Công ty Cổ phần Hóa chất Cơ bản miền Nam"
   ,"UPCOM_CT3 Công ty Cổ phần Đầu tư và Xây dựng Công trình 3"
   ,"HNX_CTB Công ty Cổ phần Chế tạo Bơm Hải Dương"
   ,"HOSE_CTF Công ty cổ phần City Auto"
   ,"HOSE_CTI Công ty Cổ phần Đầu tư Phát triển Cường Thuận IDICO"
   ,"UPCOM_CTN Công ty Cổ phần Xây dựng Công trình ngầm"
   ,"HNX_CTP Công ty Cổ phần Thương Phú"
   ,"HNX_CTT CTCP Chế tạo máy Vinacomin"
   ,"UPCOM_CTW CTCP Cấp thoát nước Cần Thơ"
   ,"HNX_CVN Công ty cổ phần Vinam"
   ,"HNX_CX8 Công ty cổ phần Đầu tư và Xây lắp Constrexim số 8"
   ,"HNX_D11 Công ty Cổ phần Địa ốc 11"
   ,"UPCOM_DAC Công ty Cổ phần Viglacera Đông Anh"
   ,"HNX_DAD Công ty Cổ phần Đầu tư và Phát triển Giáo dục Đà Nẵng"
   ,"HOSE_DAH Công ty cổ phần Tập đoàn Khách sạn Đông Á"
   ,"UPCOM_DAS Công ty Cổ phần Máy - Thiết bị Dầu khí Đà Nẵng"
   ,"UPCOM_DBM Công ty Cổ phần Dược - Vật tư Y tế Đăk Lăk"
   ,"UPCOM_DC1 CTCP Đầu tư Phát triển Xây dựng số 1"
   ,"HNX_DC2 Công ty Cổ phần Đầu tư Phát triển - Xây dựng số 2"
   ,"UPCOM_DCF Công ty Cổ phần Xây dựng và Thiết kế số 1"
   ,"HOSE_DCL Công ty Cổ phần Dược phẩm Cửu Long"
   ,"UPCOM_DCT Công ty Cổ phần Tấm lợp Vật liệu xây dựng Đồng Nai"
   ,"UPCOM_DDH CTCP Đảm bảo giao thông đường thủy Hải Phòng"
   ,"UPCOM_DDM Công ty Cổ phần Hàng hải Đông Đô"
   ,"UPCOM_DDN Công ty Cổ phần Dược - Thiết bị Y tế Đà Nẵng"
   ,"UPCOM_DDV Công ty cổ phần DAP - VINACHEM"
   ,"UPCOM_DFC Công ty Cổ phần Xích líp Đông Anh"
   ,"UPCOM_DGT Công ty cổ phần Công trình Giao thông Đồng Nai"
   ,"HOSE_DHA Công ty Cổ phần Hóa An"
   ,"HOSE_DHC Công ty Cổ phần Đông Hải Bến Tre"
   ,"HOSE_DHG Công ty Cổ phần Dược Hậu Giang"
   ,"HOSE_DHM Công ty cổ phần Thương mại và Khai thác Khoáng sản Dương Hiếu"
   ,"HNX_DHP Công ty Cổ phần Điện Cơ Hải Phòng"
   ,"HNX_DHT Công ty Cổ phần Dược phẩm Hà Tây"
   ,"HNX_DL1 Công ty Cổ phần Đầu tư Phát triển Dịch vụ Công trình Công cộng Đức Long Gia Lai"
   ,"HOSE_DLG Công ty Cổ phần Tập đoàn Đức Long Gia Lai"
   ,"HOSE_DMC Công ty Cổ phần Xuất nhập khẩu Y tế Domesco"
   ,"HNX_DNC Công ty Cổ phần Điện nước Lắp máy Hải Phòng"
   ,"UPCOM_DND CTCP Đầu tư Xây dựng và Vật liệu Đồng Nai"
   ,"UPCOM_DNL Công ty cổ phần Logistic Cảng Đà Nẵng"
   ,"HNX_DNP Công ty Cổ phần Nhựa Đồng Nai"
   ,"UPCOM_DNW Công ty cổ phần Cấp nước Đồng Nai"
   ,"UPCOM_DOC Công ty cổ phần Vật tư nông nghiệp Đồng Nai"
   ,"UPCOM_DOP CTCP Vận tải Xăng dầu Đồng Tháp"
   ,"HNX_DP3 Công ty Cổ phần Dược phẩm Trung ương 3"
   ,"UPCOM_DPH Công ty Cổ phần Dược phẩm Hải Phòng"
   ,"UPCOM_DPP Công ty Cổ phần Dược Đồng Nai"
   ,"HOSE_DPR Công ty Cổ phần Cao su Đồng Phú"
   ,"HOSE_DQC Công ty Cổ phần Bóng đèn Điện Quang"
   ,"HOSE_DRC Công ty Cổ phần Cao su Đà Nẵng"
   ,"HOSE_DRH Công ty cổ phần Đầu tư Căn nhà Mơ ước"
   ,"HOSE_DRL Công ty Cổ phần Thủy điện – Điện lực 3"
   ,"HOSE_DSN Công ty Cổ phần Công viên nước Đầm Sen"
   ,"HOSE_DTA Công ty Cổ phần Đệ Tam"
   ,"HOSE_DTL Công ty Cổ phần Đại Thiên Lộc"
   ,"HOSE_DTT Công ty Cổ phần Kỹ nghệ Đô Thành"
   ,"UPCOM_DVC Công ty cổ phần Thương mại Dịch vụ Tổng hợp Cảng Hải Phòng"
   ,"HOSE_DVP Công ty cổ phần Đầu tư và Phát triển Cảng Đình Vũ"
   ,"HNX_DXP Công ty cổ phần Cảng Đoạn Xá"
   ,"HOSE_DXV Công ty Cổ phần VICEM Vật liệu Xây dựng Đà Nẵng"
   ,"HNX_ECI Công ty Cổ phần Bản đồ và Tranh ảnh Giáo dục"
   ,"UPCOM_EIC Công ty cổ phần EVN Quốc tế"
   ,"HNX_EID Công ty Cổ phần Đầu tư và Phát triển giáo dục Hà Nội"
   ,"HOSE_ELC Công ty Cổ phần Đầu tư Phát triển Công nghệ Điện tử Viễn thông"
   ,"UPCOM_EMG Công ty Cổ phần Thiết bị Phụ tùng Cơ điện"
   ,"HOSE_EVE Công ty cổ phần Everpia Việt Nam"
   ,"HOSE_FCM Công ty cổ phần Khoáng sản FECON"
   ,"UPCOM_FCS Công ty Cổ phần Lương thực Thành phố Hồ Chí Minh"
   ,"HOSE_FDC Công ty Cổ phần Ngoại thương và Phát triển Đầu tư Thành phố Hồ Chí Minh"
   ,"HNX_FID Công ty Cổ phần Đầu tư và Phát triển Doanh nghiệp Việt Nam"
   ,"HOSE_FIT Công ty cổ phần Tập đoàn F.I.T"
   ,"HOSE_FMC Công ty Cổ phần Thực phẩm Sao Ta"
   ,"UPCOM_G36 Tổng Công ty 36 - CTCP"
   ,"UPCOM_GCB Công ty Cổ Phần Petec Bình Định"
   ,"HOSE_GDT Công ty Cổ phần Chế biến Gỗ Đức Thành"
   ,"UPCOM_GER Công ty Cổ phần Thể thao Ngôi sao Geru"
   ,"UPCOM_GGG Công ty cổ phần Ô tô Giải Phóng"
   ,"UPCOM_GHC Công ty Cổ phần Thủy điện Gia Lai"
   ,"HOSE_GIL Công ty Cổ phần Sản xuất Kinh doanh Xuất nhập khẩu Bình Thạnh"
   ,"HNX_GLT Công ty cổ phần Kỹ thuật điện Toàn Cầu"
   ,"HNX_GMX Công ty cổ phần Gạch Ngói Gốm Xây dựng Mỹ Xuân"
   ,"UPCOM_GND Công ty Cổ phần Gạch ngói Đồng Nai"
   ,"UPCOM_GSM Công ty cổ phần Thủy điện Hương Sơn"
   ,"HOSE_GSP Công ty cổ phần Vận tải Sản phẩm khí quốc tế"
   ,"HOSE_GTA Công ty Cổ phần Chế biến Gỗ Thuận An"
   ,"UPCOM_GTD Công ty Cổ phần Giầy Thượng Đình"
   ,"UPCOM_GTS CTCP Công trình Giao thông Sài Gòn"
   ,"UPCOM_GTT Công ty Cổ phần Thuận Thảo"
   ,"UPCOM_GVT Công ty Cổ phần Giấy Việt Trì"
   ,"UPCOM_H11 CTCP Xây dựng HUD101"
   ,"HNX_HAD Công ty Cổ phần Bia Hà Nội - Hải Dương"
   ,"HOSE_HAH Công ty Cổ phần Vận tải và Xếp dỡ Hải An"
   ,"UPCOM_HAN Tổng công ty Xây dựng Hà Nội - CTCP"
   ,"HOSE_HAP Công ty Cổ phần Tập đoàn Hapaco"
   ,"HOSE_HAR Công ty Cổ phần Đầu tư Thương mại Bất động sản An Dương Thảo Điền"
   ,"HOSE_HAS Công ty Cổ phần HACISCO"
   ,"HNX_HAT Công ty Cổ phần Thương mại Bia Hà Nội"
   ,"HOSE_HAX Công ty Cổ phần Dịch vụ Ô tô Hàng Xanh"
   ,"UPCOM_HBD Công ty Cổ phần Bao bì PP Bình Dương"
   ,"HNX_HCC Công ty Cổ phần Bê tông Hoà Cầm - Intimex"
   ,"HOSE_HCD Công ty Cổ phần Đầu tư Sản xuất và Thương mại HCD"
   ,"UPCOM_HCI Công ty Cổ phần Đầu tư - Xây dựng Hà Nội"
   ,"HNX_HCT Công ty Cổ phần Thương mại Dịch vụ Vận tải Xi măng Hải Phòng"
   ,"UPCOM_HD2 CTCP Đầu tư Phát triển nhà HUD2"
   ,"HNX_HDA Công ty Cổ phần Hãng sơn Đông Á"
   ,"UPCOM_HDM Công ty Cổ phần Dệt - May Huế"
   ,"UPCOM_HDP Công ty Cổ phần Dược Hà Tĩnh"
   ,"UPCOM_HEC Công ty Cổ phần Tư vấn Xây dựng Thủy lợi II"
   ,"UPCOM_HES Công ty Cổ phần Dịch vụ Giải trí Hà Nội"
   ,"UPCOM_HFC Công ty Cổ phần Xăng dầu Chất đốt Hà Nội"
   ,"UPCOM_HFX Công ty cổ phần Sản xuất - Xuất nhập khẩu Thanh Hà"
   ,"HNX_HGM Công ty cổ phần Cơ khí và Khoáng sản Hà Giang"
   ,"HNX_HHC Công ty Cổ phần Bánh kẹo Hải Hà"
   ,"HOSE_HHS Công ty Cổ phần Đầu tư Dịch vụ Hoàng Huy"
   ,"HOSE_HID Công ty Cổ phần Đầu tư và Tư vấn Hà Long"
   ,"UPCOM_HIG Công ty Cổ phần Tập đoàn HIPT"
   ,"UPCOM_HJC Công ty Cổ phần Hòa Việt"
   ,"HNX_HJS Công ty Cổ phần Thủy điện Nậm Mu"
   ,"HNX_HKT Công ty Cổ phần Chè Hiệp Khánh"
   ,"UPCOM_HLA Công ty Cổ phần Hữu Liên Á Châu"
   ,"UPCOM_HLB Công ty Cổ phần Bia và Nước giải khát Hạ Long"
   ,"HNX_HLC CTCP Than Hà Lầm - Vinacomin"
   ,"HNX_HLD Công ty Cổ phần Đầu tư và Phát triển Bất động sản HUDLAND"
   ,"HOSE_HMC Công ty Cổ phần Kim khí Thành phố Hồ Chí Minh - Vnsteel"
   ,"UPCOM_HMG CTCP Kim khí Hà Nội - VNSTEEL"
   ,"HNX_HMH Công ty Cổ phần Hải Minh"
   ,"UPCOM_HNB CTCP Bến xe Hà Nội"
   ,"UPCOM_HND CTCP Nhiệt điện Hải Phòng"
   ,"UPCOM_HNF CTCP Thực phẩm Hữu Nghị"
   ,"UPCOM_HNP Công ty Cổ phần Hanel Xốp nhựa"
   ,"HNX_HOM Công ty cổ phần Xi măng VICEM Hoàng Mai"
   ,"UPCOM_HPB Công ty Cổ phần Bao bì PP"
   ,"UPCOM_HPD Công ty Công ty Cổ phần Thủy điện Đăk Đoa"
   ,"UPCOM_HPP Công ty Cổ phần Sơn Hải Phòng"
   ,"UPCOM_HPT Công ty Cổ phần Dịch vụ Công nghệ Tin học HPT"
   ,"UPCOM_HPW Công ty Cổ phần Cấp nước Hải Phòng"
   ,"HOSE_HQC Công ty cổ phần Tư vấn-Thương mại-Dịch vụ Địa ốc Hoàng Quân"
   ,"HOSE_HRC Công ty Cổ phần Cao su Hòa Bình"
   ,"UPCOM_HSA Công ty Cổ phần HESTIA"
   ,"UPCOM_HSI Công ty Cổ phần Vật tư tổng hợp và Phân bón Hóa sinh"
   ,"HNX_HTC Công ty Cổ phần Thương mại Hóc Môn"
   ,"HOSE_HTI Công ty Cổ phần Đầu tư phát triển hạ tầng IDICO"
   ,"HOSE_HTL Công ty Cổ phần Kỹ thuật và Ô tô Trường Long"
   ,"HOSE_HTV Công ty Cổ phần Vận tải Hà Tiên"
   ,"HOSE_HU1 Công ty Cổ phần Đầu tư và Xây dựng HUD1"
   ,"UPCOM_HU4 Công ty Cổ phần Đầu tư và Xây dựng HUD4"
   ,"UPCOM_HU6 Công ty cổ phần Đầu tư Phát triển nhà và Đô thị HUD 6"
   ,"HNX_HVT Công ty Cổ phần Hóa chất Việt Trì"
   ,"HOSE_HVX Công ty Cổ phần Xi măng Vicem Hải Vân"
   ,"UPCOM_ICC CTCP Xây dựng Công nghiệp"
   ,"HNX_ICG Công ty Cổ phần Xây dựng Sông Hồng"
   ,"UPCOM_ICI Công ty Cổ phần Đầu tư và Xây dựng Công nghiệp"
   ,"UPCOM_ICN Công ty cổ phần Đầu tư Xây dựng Dầu khí IDICO"
   ,"HOSE_IDI Công ty Cổ phần Đầu tư và Phát triển Đa Quốc Gia I.D.I"
   ,"HNX_IDJ Công ty Cổ phần Đầu tư Tài chính Quốc tế và Phát triển Doanh nghiệp IDJ"
   ,"HNX_IDV Công ty Cổ phần Phát triển Hạ tầng Vĩnh Phúc"
   ,"UPCOM_IFS Công ty Cổ phần Thực phẩm Quốc tế"
   ,"UPCOM_IHK Công ty Cổ phần In Hàng không"
   ,"UPCOM_IME Công ty Cổ phần Cơ khí và Xây lắp Công nghiệp"
   ,"UPCOM_IN4 Công ty Cổ phần In số 4"
   ,"HNX_INC Công ty Cổ phần Tư vấn Đầu tư IDICO"
   ,"HNX_INN Công ty Cổ phần Bao bì và In Nông nghiệp"
   ,"UPCOM_ISG CTCP Vận tải biển & Hợp tác Quốc tế"
   ,"UPCOM_ISH Công ty cổ phần Thủy điện Srok Phu Miêng IDICO"
   ,"UPCOM_IST Công ty Cổ phần ICD Tân Cảng Sóng Thần"
   ,"HOSE_ITC Công ty Cổ phần Đầu tư - Kinh doanh nhà"
   ,"HOSE_ITD Công ty Cổ phần Công nghệ Tiên Phong"
   ,"HNX_ITQ Công ty cổ phần Tập đoàn Thiên Quang"
   ,"UPCOM_ITS Công ty cổ phần Đầu tư, Thương mại và Dịch vụ - Vinacomin"
   ,"HOSE_JVC Công ty cổ phần Thiết bị Y tế Việt Nhật"
   ,"UPCOM_KCB CTCP Khoáng sản và luyện kim Cao Bằng"
   ,"UPCOM_KCE Công ty Cổ phần Bê tông Ly tâm Điện lực Khánh Hòa"
   ,"HNX_KDM CTCP Xây dựng và Thương mại Long Thành"
   ,"UPCOM_KHD CTCP Khai thác, Chế biến khoáng sản Hải Dương"
   ,"HOSE_KHP Công ty Cổ phần Điện lực Khánh Hòa"
   ,"UPCOM_KHW Công ty Cổ phần Cấp nước Khánh Hòa"
   ,"UPCOM_KIP CTCP Khí cụ Điện 1"
   ,"HNX_KKC Công ty Cổ phần Sản xuất và Kinh doanh Kim khí"
   ,"HOSE_KMR Công ty Cổ phần Mirae"
   ,"HNX_KMT Công ty cổ phần Kim khí miền Trung"
   ,"HOSE_KPF Công ty Cổ phần Tư vấn Dự án Quốc tế KPF"
   ,"HNX_KSD Công ty cổ phần Đầu tư DNA"
   ,"HNX_KSQ Công ty cổ phần Đầu tư KSQ"
   ,"HNX_KST Công ty cổ phần KASATI"
   ,"UPCOM_KTL CTCP Kim khí Thăng Long"
   ,"HNX_KTS Công ty cổ phần Đường Kon Tum"
   ,"HOSE_L10 Công ty cổ phần Lilama 10"
   ,"UPCOM_L12 Công ty cổ phần Licogi 12"
   ,"HNX_L14 Công ty cổ phần LICOGI 14"
   ,"HNX_L18 Công ty Cổ phần Đầu tư và Xây dựng số 18"
   ,"UPCOM_L45 CTCP Lilama 45.1"
   ,"UPCOM_L63 CTCP Lilama 69-3"
   ,"HOSE_LAF Công ty Cổ phần Chế biến Hàng xuất khẩu Long An"
   ,"UPCOM_LAI CTCP Đầu tư xây dựng Long An IDICO"
   ,"UPCOM_LAW Công ty cổ phần Cấp thoát nước Long An"
   ,"HOSE_LBM Công ty Cổ phần Khoáng sản và Vật liệu xây dựng Lâm Đồng"
   ,"UPCOM_LCC Công ty Cổ phần Xi măng Lạng Sơn"
   ,"HNX_LCD Công ty Cổ phần Lắp máy - Thí nghiệm Cơ điện"
   ,"HOSE_LCG Công ty cổ phần LICOGI 16"
   ,"HOSE_LDG Công ty Cổ phần Đầu tư LDG"
   ,"HNX_LDP Công ty Cổ phần Dược Lâm Đồng - Ladophar"
   ,"HOSE_LGC Công ty Cổ phần Đầu tư Cầu đường CII"
   ,"HOSE_LGL Công ty cổ phần Đầu tư và Phát triển Đô thị Long Giang"
   ,"HNX_LIG Công ty Cổ phần Licogi 13"
   ,"HOSE_LIX Công ty Cổ phần Bột giặt Lix"
   ,"UPCOM_LKW CTCP Cấp nước Long Khánh"
   ,"UPCOM_LM3 Công ty Cổ phần Lilama 3"
   ,"HOSE_LM8 Công ty Cổ phần Lilama 18"
   ,"UPCOM_LQN Công ty cổ phần Licogi Quảng Ngãi"
   ,"HOSE_LSS Công ty Cổ phần Mía đường Lam Sơn"
   ,"HNX_MAC Công ty Cổ phần Cung ứng và Dịch vụ Kỹ thuật Hàng Hải"
   ,"HNX_MAS Công ty cổ phần Dịch vụ Hàng không Sân bay Đà Nẵng"
   ,"HNX_MBG Công ty cổ phần Đầu tư Phát triển Xây dựng và Thương mại Việt Nam"
   ,"HNX_MCC Công ty Cổ phần Gạch ngói cao cấp"
   ,"HNX_MCF CTCP Xây lắp Cơ khí và Lương thực Thực phẩm"
   ,"HNX_MCO Công ty Cổ phần Đầu tư và Xây dựng BDC Việt Nam"
   ,"HOSE_MCP Công ty cổ phần In và Bao bì Mỹ Châu"
   ,"HNX_MDC Công ty cổ phần Than Mông Dương - Vinacomin"
   ,"UPCOM_MDF Công ty cổ phần Gỗ MDF VRG Quảng Trị"
   ,"HOSE_MDG Công ty Cổ phần miền Đông"
   ,"UPCOM_MGC CTCP Địa chất mỏ - TKV"
   ,"UPCOM_MH3 Công ty Cổ phần Khu Công Nghiệp Cao Su Bình Long"
   ,"HOSE_MHC Công ty Cổ phần MHC"
   ,"UPCOM_MIC Công ty Cổ phần Kỹ nghệ Khoáng sản Quảng Nam"
   ,"HNX_MKV Công ty Cổ phần Dược Thú y Cai Lậy"
   ,"UPCOM_MTA Tổng Công ty Khoáng sản và Thương mại Hà Tĩnh - CTCP"
   ,"UPCOM_MTG Công ty Cổ phần MT Gas"
   ,"UPCOM_MTH Công ty Cổ phần Môi trường Đô thị Hà Đông"
   ,"UPCOM_MTL CTCP Dịch vụ Môi trường Đô thị Từ Liêm"
   ,"UPCOM_MTP Công ty Cổ phần Dược trung ương Medipharco - Tenamyd"
   ,"HOSE_NAF Công ty Cổ phần Nafoods Group"
   ,"HNX_NAG Công ty cổ phần Nagakawa Việt Nam"
   ,"UPCOM_NAS Công ty Cổ phần Dịch vụ Hàng không Sân bay Nội Bài"
   ,"HOSE_NAV Công ty Cổ phần Nam Việt"
   ,"HOSE_NBB Công ty Cổ phần Đầu tư Năm Bảy Bảy"
   ,"HNX_NBP Công ty Cổ phần Nhiệt điện Ninh Bình"
   ,"UPCOM_NBT CTCP Cấp thoát nước Bến Tre"
   ,"UPCOM_NCS Công ty cổ phần Suất ăn Hàng không Nội Bài"
   ,"HOSE_NCT Công ty Cổ phần Dịch vụ Hàng hóa Nội Bài"
   ,"UPCOM_ND2 Công ty Cổ phần Đầu tư Phát triển điện Miền Bắc 2"
   ,"UPCOM_NDC Công ty Cổ phần Nam Dược"
   ,"HNX_NDN Công ty Cổ phần Đầu tư Phát triển Nhà Đà Nẵng"
   ,"UPCOM_NDP CTCP Dược phẩm 2-9 TP. Hồ Chí Minh"
   ,"HNX_NDX Công ty Cổ phần Xây lắp Phát triển Nhà Đà Nẵng"
   ,"HNX_NET Công ty Cổ phần Bột giặt Net"
   ,"HNX_NFC Công ty Cổ phần Phân lân Ninh Bình"
   ,"HNX_NHC Công ty Cổ phần Gạch Ngói Nhị Hiệp"
   ,"UPCOM_NLS Công ty cổ phần Cấp thoát Nước Lạng Sơn"
   ,"HOSE_NNC Công ty Cổ phần Đá Núi Nhỏ"
   ,"UPCOM_NNT Công ty cổ phần Cấp nước Ninh Thuận"
   ,"UPCOM_NOS Công ty Cổ phần Vận tải Biển Bắc"
   ,"UPCOM_NQB Công ty cổ phần Cấp nước Quảng Bình"
   ,"UPCOM_NS2 Công ty Cổ phần Nước sạch số 2 Hà Nội"
   ,"HOSE_NSC Công ty cổ phần Giống cây trồng Trung ương"
   ,"UPCOM_NSG CTCP Nhựa Sài Gòn"
   ,"HNX_NST Công ty Cổ phần Ngân Sơn"
   ,"UPCOM_NTB Công ty cổ phần Đầu tư Xây dựng và Khai thác Công trình Giao thông 584"
   ,"UPCOM_NTC Công ty Cổ phần Khu Công nghiệp Nam Tân Uyên"
   ,"HNX_NTP Công ty Cổ phần Nhựa Thiếu niên Tiền Phong"
   ,"UPCOM_NTW Công ty cổ phần Cấp nước Nhơn Trạch"
   ,"UPCOM_NUE Công ty Cổ phần Môi trường Đô thị Nha Trang"
   ,"UPCOM_NWT CTCP Vận tải Newway"
   ,"HNX_OCH Công ty Cổ phần Khách sạn và Dịch vụ Đại Dương"
   ,"HNX_ONE Công ty Cổ phần Truyền thông số 1"
   ,"UPCOM_ONW Công ty Cổ phần Dịch vụ Một Thế giới"
   ,"HOSE_OPC Công ty cổ phần Dược phẩm OPC"
   ,"HOSE_PAC Công ty Cổ phần Pin Ắc quy Miền Nam"
   ,"UPCOM_PAI CTCP Công nghệ thông tin, viễn thông và tự động hóa Dầu khí"
   ,"HOSE_PAN Công ty Cổ phần Tập đoàn PAN"
   ,"HNX_PBP Công ty cổ phần Bao bì Dầu khí Việt Nam"
   ,"HNX_PCG Công ty Cổ phần Đầu tư và Phát triển Gas Đô Thị"
   ,"HNX_PCT Công ty cổ phần Dịch vụ Vận tải Dầu khí Cửu Long"
   ,"HNX_PDB Công ty Cổ phần Pacific Dinco"
   ,"HOSE_PDN Công ty Cổ phần Cảng Đồng Nai"
   ,"UPCOM_PEC Công ty Cổ phần Cơ khí Điện lực"
   ,"HNX_PEN Công ty cổ phần Xây lắp III Petrolimex"
   ,"UPCOM_PEQ CTCP Thiết bị Xăng dầu Petrolimex"
   ,"HOSE_PET Tổng Công ty Cổ phần Dịch vụ Tổng hợp Dầu khí"
   ,"UPCOM_PFL Công ty cổ phần Dầu khí Đông Đô"
   ,"HOSE_PGC Tổng Công ty Gas Petrolimex-CTCP"
   ,"HOSE_PGD Công ty Cổ phần Phân phối Khí thấp áp Dầu khí Việt Nam"
   ,"HOSE_PGI Tổng Công ty cổ phần Bảo hiểm Petrolimex"
   ,"HNX_PGS Công ty Cổ phần Kinh doanh Khí Miền Nam"
   ,"HNX_PGT Công ty Cổ phần PGT Holdings"
   ,"UPCOM_PHH Công ty Cổ phần Hồng Hà Việt Nam"
   ,"HNX_PIC CTCP Đầu tư Điện lực 3"
   ,"UPCOM_PID Công ty Cổ phần Trang trí Nội thất Dầu khí"
   ,"UPCOM_PIS Tổng công ty Pisico Bình Định - CTCP"
   ,"HOSE_PIT Công ty Cổ phần Xuất nhập khẩu Petrolimex"
   ,"HNX_PJC Công ty Cổ phần Thương mại và Vận tải Petrolimex Hà Nội"
   ,"UPCOM_PJS Công ty cổ phần Cấp nước Phú Hòa Tân"
   ,"HOSE_PJT Công ty Cổ phần Vận tải Xăng dầu Đường thủy Petrolimex"
   ,"HNX_PMB Công ty cổ phần Phân bón và Hóa chất Dầu khí Miền Bắc"
   ,"HNX_PMC Công ty Cổ phần Dược phẩm Dược liệu Pharmedic"
   ,"UPCOM_PMJ CTCP Vật tư Bưu điện"
   ,"HNX_PMP Công ty cổ phần Bao bì Đạm Phú Mỹ"
   ,"HNX_PMS Công ty Cổ phần Cơ khí Xăng dầu"
   ,"UPCOM_PMT Công ty cổ phần Viễn thông TELVINA Việt Nam"
   ,"HOSE_PNC Công ty Cổ phần Văn hóa Phương Nam"
   ,"UPCOM_PND Công ty Cổ phần Xăng dầu Dầu khí Nam Định"
   ,"UPCOM_PNG Công ty cổ phần Thương mại Phú Nhuận"
   ,"UPCOM_PNT Công ty cổ phần Kỹ thuật Xây dựng Phú Nhuận"
   ,"UPCOM_POS Công ty Cổ phần Dịch vụ Lắp đặt, Vận hành và Bảo dưỡng Công trình Dầu khí biển PTSC"
   ,"HNX_POT Công ty Cổ phần Thiết bị Bưu điện"
   ,"UPCOM_POV Công ty Cổ phần Xăng dầu Dầu khí Vũng Áng"
   ,"HNX_PPE Công ty cổ phần Tư vấn Điện lực Dầu khí Việt Nam"
   ,"HNX_PPP Công ty Cổ phần Dược phẩm Phong Phú"
   ,"HNX_PPS Công ty Cổ phần Dịch vụ Kỹ thuật Điện lực Dầu khí Việt Nam"
   ,"HNX_PPY CTCP Xăng dầu Dầu khí Phú Yên"
   ,"HNX_PRC Công ty Cổ phần Logistics Portserco"
   ,"UPCOM_PRO Công ty Cổ phần Procimex Việt Nam"
   ,"UPCOM_PSB Công ty cổ phần Đầu tư Dầu khí Sao Mai – Bến Đình"
   ,"HNX_PSC Công ty cổ phần Vận tải và Dịch vụ Petrolimex Sài Gòn"
   ,"HNX_PSD Công ty cổ phần Dịch vụ Phân phối Tổng hợp Dầu khí"
   ,"HNX_PSE Công ty cổ phần Phân bón và Hóa chất Dầu khí Đông Nam Bộ"
   ,"UPCOM_PSG Công ty Cổ phần Đầu tư và Xây lắp Dầu khí Sài Gòn"
   ,"UPCOM_PSL Công ty Cổ phần Chăn nuôi Phú Sơn"
   ,"UPCOM_PSP Công ty Cổ phần Cảng dịch vụ Dầu khí Đình Vũ"
   ,"HNX_PSW Công ty cổ phần Phân bón và Hóa chất Dầu khí Tây Nam Bộ"
   ,"HOSE_PTB Công ty Cổ phần Phú Tài"
   ,"HOSE_PTC Công ty Cổ phần Đầu tư và Xây dựng Bưu điện"
   ,"HNX_PTD CTCP Thiết kế - Xây dựng - Thương mại Phúc Thịnh"
   ,"UPCOM_PTE Công ty Cổ phần Xi măng Phú Thọ"
   ,"UPCOM_PTG Công ty Cổ phần May Xuất khẩu Phan Thiết"
   ,"UPCOM_PTH Công ty Cổ phần Vận tải và Dịch vụ Petrolimex Hà Tây"
   ,"HNX_PTI Tổng Công ty Cổ phần Bảo hiểm Bưu điện"
   ,"HOSE_PTL Công ty Cổ phần Đầu tư Hạ tầng và Đô thị Dầu khí PVC"
   ,"UPCOM_PTP Công ty Cổ phần Dịch vụ Viễn thông và In Bưu điện"
   ,"HNX_PTS Công ty Cổ phần Vận tải và Dịch vụ Petrolimex Hải Phòng"
   ,"UPCOM_PTT Công ty Cổ phần Vận tải Dầu khí Đông Dương"
   ,"HNX_PV2 Công ty cổ phần Đầu tư PV2"
   ,"UPCOM_PVA Công ty Cổ phần Tổng Công ty Xây lắp Dầu khí Nghệ An"
   ,"HNX_PVB Công ty cổ phần Bọc ống Dầu khí Việt Nam"
   ,"HNX_PVG Công ty Cổ phần Kinh doanh Khí hóa lỏng Miền Bắc"
   ,"HNX_PVI Công ty Cổ phần PVI"
   ,"UPCOM_PVM Công ty Cổ phần Máy - Thiết bị Dầu khí"
   ,"UPCOM_PVO CTCP Dầu nhờn PV Oil"
   ,"UPCOM_PXL Công ty cổ phần Đầu tư Xây dựng Thương mại Dầu khí-IDICO"
   ,"UPCOM_PXM Công ty Cổ phần Xây lắp Dầu khí Miền Trung"
   ,"UPCOM_QCC CTCP Đầu tư Xây dựng và Phát triển Hạ tầng Viễn thông"
   ,"HNX_QHD Công ty Cổ phần Que hàn điện Việt Đức"
   ,"UPCOM_QHW CTCP Nước khoáng Quảng Ninh"
   ,"UPCOM_QNS Công ty Cổ phần Đường Quảng Ngãi"
   ,"UPCOM_QNU Công ty Cổ phần Môi trường Đô thị Quảng Nam"
   ,"UPCOM_QNW CTCP Cấp thoát nước và Xây dựng Quảng Ngãi"
   ,"UPCOM_QPH Công ty Cổ phần Thủy điện Quế Phong"
   ,"UPCOM_QSP Công ty cổ phần Tân Cảng Quy Nhơn"
   ,"HNX_QTC Công ty Cổ phần Công trình Giao thông Vận tải Quảng Nam"
   ,"HOSE_RAL Công ty Cổ phần Bóng đèn Phích nước Rạng Đông"
   ,"UPCOM_RAT CTCP Vận tải và Thương mại Đường sắt"
   ,"UPCOM_RBC CTCP Công nghiệp và Xuất nhập khẩu Cao Su"
   ,"UPCOM_RCC Công ty Cổ phần Tổng công ty Công trình đường sắt"
   ,"UPCOM_RCD Công ty cổ phần Xây dựng - Địa ốc Cao su"
   ,"HNX_RCL Công ty Cổ phần Địa ốc Chợ Lớn"
   ,"HOSE_RDP Công ty Cổ phần Nhựa Rạng Đông"
   ,"UPCOM_RTB Công ty cổ phần Cao su Tân Biên"
   ,"UPCOM_S12 Công ty Cổ phần Sông Đà 12"
   ,"UPCOM_S27 Công ty cổ phần Sông Đà 27"
   ,"HOSE_S4A Công ty Cổ phần Thủy điện Sê San 4A"
   ,"HNX_S55 Công ty Cổ phần Sông Đà 505"
   ,"UPCOM_S96 Công ty Cổ phần Sông Đà 9.06"
   ,"HNX_S99 Công ty Cổ phần SCI"
   ,"UPCOM_SAC Công ty Cổ phần Xếp dỡ và Dịch vụ Cảng Sài Gòn"
   ,"HNX_SAF Công ty Cổ phần Lương thực Thực phẩm Safoco"
   ,"HOSE_SAM Công ty Cổ phần Đầu tư và Phát triển Sacom"
   ,"UPCOM_SAS CTCP Dịch vụ Hàng không Sân bay Tân Sơn Nhất"
   ,"HOSE_SAV Công ty Cổ phần Hợp tác kinh tế và Xuất nhập khẩu SAVIMEX"
   ,"UPCOM_SB1 Công ty cổ phần Bia Sài Gòn - Nghệ Tĩnh"
   ,"HOSE_SBA Công ty Cổ phần Sông Ba"
   ,"UPCOM_SBD Công ty Cổ phần Công nghệ Sao Bắc Đẩu"
   ,"UPCOM_SBL Công ty Cổ phần Bia Sài Gòn - Bạc Liêu"
   ,"HOSE_SBV Công ty cổ phần Siam Brothers Việt Nam"
   ,"HOSE_SC5 Công ty Cổ phần Xây dựng số 5"
   ,"UPCOM_SCC Công ty Cổ phần Đầu tư Thương mại Hưng Long tỉnh Hòa Bình"
   ,"HNX_SCI Công ty Cổ phần Xây dựng và Đầu tư Sông Đà 9"
   ,"UPCOM_SCO Công ty Cổ phần Công nghiệp Thủy sản"
   ,"HOSE_SCR Công ty Cổ phần Địa ốc Sài Gòn Thương Tín"
   ,"UPCOM_SD1 Công ty Cổ phần Sông Đà 1"
   ,"UPCOM_SD3 Công ty Cổ phần Sông Đà 3"
   ,"HNX_SD5 Công ty Cổ phần Sông Đà 5"
   ,"UPCOM_SD8 Công ty Cổ phần Sông Đà 8"
   ,"HNX_SD9 Công ty Cổ phần Sông Đà 9"
   ,"HNX_SDA Công ty Cổ phần Simco Sông Đà"
   ,"UPCOM_SDB Công ty Cổ phần Sông Đà 207"
   ,"HNX_SDC Công ty Cổ phần Tư vấn Sông Đà"
   ,"HNX_SDG Công ty Cổ phần Sadico Cần Thơ"
   ,"UPCOM_SDJ Công ty Cổ phần Sông Đà 25"
   ,"UPCOM_SDK Công ty Cổ phần Cơ khí Luyện kim"
   ,"HNX_SDN Công ty Cổ phần Sơn Đồng Nai"
   ,"HNX_SDU Công ty Cổ phần Đầu tư Xây dựng và Phát triển Đô thị Sông Đà"
   ,"UPCOM_SDV Công ty Cổ phần Dịch vụ Sonadezi"
   ,"UPCOM_SDX CTCP Phòng cháy chữa cháy và Đầu tư Xây dựng Sông Đà"
   ,"UPCOM_SEA Tổng công ty Thủy sản Việt Nam – CTCP"
   ,"HNX_SEB Công ty Cổ phần Đầu tư và Phát triển Điện miền Trung"
   ,"HNX_SED Công ty Cổ phần Đầu tư và Phát triển giáo dục Phương Nam"
   ,"UPCOM_SEP Công ty Cổ phần Tổng Công ty Thương mại Quảng Trị"
   ,"HOSE_SFC Công ty Cổ phần Nhiên liệu Sài Gòn"
   ,"HOSE_SFG Công ty Cổ phần Phân bón Miền Nam"
   ,"HOSE_SFI Công ty Cổ phần Đại lý Vận tải SAFI"
   ,"HNX_SFN Công ty Cổ phần Dệt lưới Sài Gòn"
   ,"HNX_SGC Công ty Cổ phần Xuất nhập khẩu Sa Giang"
   ,"HNX_SGH Công ty Cổ phần Khách sạn Sài Gòn"
   ,"UPCOM_SGP Công ty Cổ phần Cảng Sài Gòn"
   ,"UPCOM_SGS Công ty Cổ phần Vận tải biển Sài Gòn"
   ,"HOSE_SGT Công ty Cổ phần Công nghệ Viễn thông Sài Gòn"
   ,"HOSE_SHA Công ty Cổ phần Sơn Hà Sài Gòn"
   ,"UPCOM_SHG Tổng Công ty Cổ phần Sông Hồng"
   ,"HOSE_SHI Công ty cổ phần Quốc tế Sơn Hà"
   ,"HNX_SHN Công ty Cổ phần Đầu tư Tổng hợp Hà Nội"
   ,"HOSE_SHP Công ty cổ phần Thủy điện Miền Nam"
   ,"UPCOM_SID Công ty Cổ phần Đầu tư Phát triển Sài Gòn Co.op"
   ,"HNX_SJ1 Công ty Cổ phần Nông Nghiệp Hùng Hậu"
   ,"HOSE_SJD Công ty Cổ phần Thủy điện Cần Đơn"
   ,"HNX_SJE Công ty Cổ phần Sông Đà 11"
   ,"UPCOM_SJM Công ty Cổ phần Sông Đà 19"
   ,"HOSE_SMA Công ty Cổ phần Thiết bị Phụ tùng Sài Gòn"
   ,"HOSE_SMC Công ty Cổ phần Đầu tư Thương mại SMC"
   ,"HNX_SMT Công ty cổ phần Vật liệu Điện và Viễn thông Sam Cường"
   ,"UPCOM_SNC Công ty Cổ phần Xuất nhập khẩu Thủy sản Năm Căn"
   ,"UPCOM_SPB CTCP Sợi Phú Bài"
   ,"UPCOM_SPD Công ty Cổ phần Xuất nhập khẩu Thủy sản Miền Trung"
   ,"UPCOM_SPH Công ty cổ phần Xuất nhập khẩu Thủy sản Hà Nội"
   ,"HNX_SPI Công ty cổ phần Đá Spilít"
   ,"HOSE_SPM Công ty Cổ phần S.P.M"
   ,"UPCOM_SPV Công ty cổ phần Thủy Đặc Sản"
   ,"UPCOM_SQC Công ty Cổ phần Khoáng sản Sài Gòn - Quy Nhơn"
   ,"HNX_SRA Công ty Cổ phần Sara Việt Nam"
   ,"UPCOM_SRB Công ty Cổ phần Tập đoàn Sara"
   ,"HOSE_SRC Công ty Cổ phần Cao Su Sao Vàng"
   ,"HOSE_SRF Công ty Cổ phần Kỹ Nghệ Lạnh"
   ,"HOSE_SSC Công ty Cổ phần Giống cây trồng Miền Nam"
   ,"UPCOM_SSF Công ty Cổ phần Giầy Sài Gòn"
   ,"UPCOM_SSG Công ty Cổ phần Vận tải biển Hải Âu"
   ,"HNX_SSM Công ty Cổ phần Chế tạo Kết cấu Thép VNECO.SSM"
   ,"UPCOM_SSN Công ty Cổ phần Xuất nhập khẩu Thủy sản Sài Gòn"
   ,"HOSE_ST8 Công ty Cổ phần Siêu Thanh"
   ,"HOSE_STG Công ty Cổ phần Kho vận Miền Nam"
   ,"HOSE_STK Công ty cổ phần Sợi Thế Kỷ"
   ,"HNX_STP Công ty Cổ phần Công nghiệp Thương mại Sông Đà"
   ,"UPCOM_STS Công ty Cổ phần Dịch vụ Vận tải Sài Gòn"
   ,"HOSE_SVC Công ty Cổ phần Dịch vụ tổng hợp Sài Gòn"
   ,"UPCOM_SVG CTCP Hơi Kỹ nghệ Que hàn"
   ,"HOSE_SVI Công ty Cổ phần Bao bì Biên Hòa"
   ,"HNX_SVN Công ty cổ phần SOLAVINA"
   ,"HOSE_SVT Công ty Cổ phần Công nghệ Sài Gòn Viễn Đông"
   ,"UPCOM_SWC Tổng Công ty Cổ phần Đường Sông Miền Nam"
   ,"UPCOM_SZE Công ty Cổ phần Môi trường Sonadezi"
   ,"HOSE_SZL Công ty cổ phần Sonadezi Long Thành"
   ,"HNX_TA9 Công ty Cổ phần Xây lắp Thành An 96"
   ,"UPCOM_TAW CTCP Cấp nước Trung An"
   ,"HOSE_TBC Công ty cổ phần Thủy điện Thác Bà"
   ,"UPCOM_TBD Tổng Công ty Thiết bị Điện Đông Anh - Công ty Cổ phần"
   ,"UPCOM_TBT Công ty Cổ phần Xây dựng Công trình Giao thông Bến Tre"
   ,"HNX_TBX Công ty Cổ phần Xi măng Thái Bình"
   ,"HOSE_TCL Công ty Cổ phần Đại lý Giao nhận Vận tải Xếp dỡ Tân Cảng"
   ,"HOSE_TCO Công ty Cổ phần Vận tải Đa phương thức Duyên Hải"
   ,"HOSE_TCR Công ty Cổ phần Công nghiệp Gốm sứ Taicera"
   ,"HOSE_TCT Công ty Cổ phần Cáp treo Núi Bà Tây Ninh"
   ,"HOSE_TDH Công ty Cổ phần Phát triển Nhà Thủ Đức"
   ,"UPCOM_TDS Công ty cổ phần Thép Thủ Đức - Vnsteel"
   ,"HOSE_TDW Công ty Cổ phần Cấp nước Thủ Đức"
   ,"HNX_TET Công ty Cổ phần Vải sợi May mặc Miền Bắc"
   ,"HNX_TFC Công ty Cổ phần Trang"
   ,"UPCOM_TGP Công ty Cổ phần Trường Phú"
   ,"HNX_THB Công ty cổ phần Bia Thanh Hóa"
   ,"HOSE_THG Công ty Cổ phần Đầu tư và Xây dựng Tiền Giang"
   ,"HNX_THS Công ty cổ phần Thanh Hoa - Sông Đà"
   ,"HNX_THT Công ty cổ phần Than Hà Tu - Vinacomin"
   ,"UPCOM_THW Công ty cổ phần Cấp nước Tân Hòa"
   ,"HOSE_TIP Công ty cổ phần Phát triển Khu Công nghiệp Tín Nghĩa"
   ,"UPCOM_TIS Công ty cổ phần Gang thép Thái Nguyên"
   ,"HOSE_TIX CTCP Sản xuất Kinh doanh Xuất nhập khẩu Dịch vụ và Đầu tư Tân Bình"
   ,"HNX_TJC Công ty cổ phần Dịch vụ Vận tải và Thương mại"
   ,"HNX_TKU Công ty Cổ phần Công nghiệp Tung Kuang"
   ,"UPCOM_TL4 Tổng công ty Xây dựng Thủy lợi 4 - CTCP"
   ,"HOSE_TLH Công ty Cổ phần Tập đoàn Thép Tiến Lên"
   ,"UPCOM_TLT Công ty Cổ phần Viglacera Thăng Long"
   ,"HNX_TMB Công ty Cổ phần Kinh doanh than Miền Bắc - Vinacomin"
   ,"HNX_TMC Công ty Cổ phần Thương mại - Xuất nhập khẩu Thủ Đức"
   ,"UPCOM_TMG Công ty Cổ phần Kim loại màu Thái Nguyên - Vimico"
   ,"HOSE_TMP Công ty cổ phần Thủy điện Thác Mơ"
   ,"HOSE_TMS Công ty Cổ phần Transimex"
   ,"HOSE_TMT Công ty Cổ phần Ô tô TMT"
   ,"UPCOM_TMW Công ty Cổ phần Tổng hợp Gỗ Tân Mai"
   ,"HNX_TMX Công ty cổ phần VICEM Thương mại Xi măng"
   ,"UPCOM_TNB Công ty Cổ phần Thép Nhà Bè - VNSTEEL"
   ,"HOSE_TNC Công ty Cổ phần Cao su Thống Nhất"
   ,"UPCOM_TNM Công ty Cổ phần Xuất nhập khẩu và Xây dựng Công trình"
   ,"UPCOM_TNP Công ty cổ phần Cảng Thị Nại"
   ,"UPCOM_TNS Công ty Cổ phần Thép Tấm lá Thống Nhất"
   ,"HOSE_TNT Công ty Cổ phần Tài nguyên"
   ,"UPCOM_TOP CTCP Phân phối Top One"
   ,"HOSE_TPC Công ty Cổ phần Nhựa Tân Đại Hưng"
   ,"HNX_TPP Công ty Cổ phần Nhựa Tân Phú"
   ,"UPCOM_TPS CTCP Bến bãi Vận tải Sài Gòn"
   ,"UPCOM_TQN Công ty Cổ phần Thông Quảng Ninh"
   ,"HOSE_TRA Công ty Cổ phần TRAPHACO"
   ,"HOSE_TRC Công ty Cổ phần Cao su Tây Ninh"
   ,"UPCOM_TRS CTCP Vận tải và Dịch vụ Hàng hải"
   ,"HNX_TSB Công ty Cổ phần Ắc quy Tia sáng"
   ,"HOSE_TSC Công ty Cổ phần Vật tư kỹ thuật Nông nghiệp Cần Thơ"
   ,"HNX_TTC Công ty Cổ phần Gạch men Thanh Thanh"
   ,"UPCOM_TTD Công ty Cổ phần Bệnh viện Tim Tâm Đức"
   ,"HOSE_TTF Công ty Cổ phần Tập đoàn Kỹ nghệ Gỗ Trường Thành"
   ,"UPCOM_TTG Công ty Cổ phần May Thanh Trì"
   ,"HNX_TTH Công ty cổ phần Thương Mại và Dịch Vụ Tiến Thành"
   ,"UPCOM_TUG Công ty Cổ phần Lai dắt và Vận tải Cảng Hải Phòng"
   ,"HNX_TV3 Công ty Cổ phần Tư vấn Xây dựng Điện 3"
   ,"HNX_TV4 Công ty Cổ phần Tư vấn Xây dựng Điện 4"
   ,"HNX_TVC Công ty cổ phần Quản lý Đầu tư Trí Việt"
   ,"UPCOM_TVG Công ty cổ phần Tư vấn Đầu tư và Xây dựng Giao thông Vận tải"
   ,"UPCOM_TVM CTCP Tư vấn Đầu tư Mỏ và Công nghiệp - Vinacomin"
   ,"UPCOM_TW3 CTCP Dược Trung ương 3"
   ,"HNX_TXM Công ty cổ phần VICEM Thạch cao Xi măng"
   ,"HOSE_TYA Công ty Cổ phần Dây và Cáp điện Taya Việt Nam"
   ,"UPCOM_UCT Công ty Cổ phần Đô thị Cần Thơ"
   ,"UPCOM_UDJ Công ty Cổ phần Phát triển Đô thị"
   ,"UPCOM_UEM CTCP Cơ điện Uông Bí- Vinacomin"
   ,"HOSE_UIC Công ty Cổ phần Đầu tư Phát triển Nhà và Đô thị Idico"
   ,"HNX_UNI Công ty Cổ phần Viễn Liên"
   ,"UPCOM_UPC CTCP Phát triển Công viên cây xanh và Đô thị Vũng Tàu"
   ,"UPCOM_UPH CTCP Dược phẩm TW25"
   ,"UPCOM_USC Công ty Cổ phần Khảo sát và Xây dựng - USCO"
   ,"UPCOM_V11 Công ty Cổ phần Xây dựng số 11"
   ,"HNX_V12 Công ty Cổ phần Xây dựng số 12"
   ,"UPCOM_V15 Công ty Cổ phần Xây dựng Số 15"
   ,"HNX_V21 Công ty Cổ phần VINACONEX 21"
   ,"HOSE_VAF Công ty cổ phần Phân lân nung chảy Văn Điển"
   ,"HNX_VBC Công ty Cổ phần Nhựa Bao bì Vinh"
   ,"HNX_VC1 Công ty Cổ phần Xây dựng số 1"
   ,"HNX_VC2 Công ty Cổ phần Xây dựng số 2"
   ,"UPCOM_VC5 Công ty Cổ phần Xây dựng số 5"
   ,"HNX_VC6 Công ty Cổ phần Vinaconex 6"
   ,"HNX_VC9 Công ty Cổ phần Xây dựng số 9"
   ,"HNX_VCC Công ty Cổ phần Vinaconex 25"
   ,"HOSE_VCF Công ty Cổ phần VinaCafé Biên Hòa"
   ,"HNX_VCM Công ty Cổ phần Nhân lực và Thương mại Vinaconex"
   ,"UPCOM_VCP Công ty cổ phần Đầu tư xây dựng và phát triển năng lượng Vinaconex"
   ,"UPCOM_VCT Công ty Cổ phần Tư vấn Xây dựng Vinaconex"
   ,"UPCOM_VCW Công ty Cổ phần Nước sạch Vinaconex"
   ,"UPCOM_VCX Công ty Cổ phần Xi măng Yên Bình"
   ,"HNX_VDL Công ty Cổ phần Thực phẩm Lâm Đồng"
   ,"UPCOM_VDN Công ty Cổ phần Vinatex Đà Nẵng"
   ,"UPCOM_VDT Công ty cổ phần Lưới thép Bình Tây"
   ,"HNX_VE1 Công ty Cổ phần Xây dựng điện VNECO 1"
   ,"HNX_VE3 Công ty cổ phần Xây dựng điện VNECO 3"
   ,"HNX_VE4 Công ty Cổ phần Xây dựng điện VNECO4"
   ,"HNX_VE8 Công ty cổ phần Xây dựng điện VNECO 8"
   ,"UPCOM_VEF CTCP Trung tâm Hội chợ Triển lãm Việt Nam"
   ,"UPCOM_VES Công ty Cổ phần Đầu tư và Xây dựng điện Mê Ca Vneco"
   ,"UPCOM_VFC Công ty Cổ phần VINAFCO"
   ,"HOSE_VFG Công ty Cổ phần Khử trùng Việt Nam"
   ,"UPCOM_VGG Tổng Công ty cổ phần May Việt Tiến"
   ,"UPCOM_VGL CTCP Mạ kẽm công nghiệp Vingal - Vnsteel"
   ,"HNX_VGP Công ty Cổ phần Cảng Rau quả"
   ,"UPCOM_VHF Công ty Cổ phần Xây dựng và Chế biến lương thực Vĩnh Hà"
   ,"UPCOM_VHH Công ty cổ phần Đầu tư Kinh doanh nhà Thành Đạt"
   ,"HNX_VHL Công ty Cổ phần Viglacera Hạ Long"
   ,"HOSE_VID Công ty Cổ phần Đầu tư Phát triển Thương mại Viễn Đông"
   ,"UPCOM_VIM Công ty Cổ phần Khoáng sản Viglacera"
   ,"UPCOM_VIN CTCP Giao nhận Kho vận Ngoại thương Việt Nam"
   ,"HOSE_VIP Công ty Cổ phần Vận tải Xăng dầu VIPCO"
   ,"HNX_VIT Công ty Cổ phần Viglacera Tiên Sơn"
   ,"HNX_VLA Công ty Cổ phần Đầu tư và Phát triển Công nghệ Văn Lang"
   ,"UPCOM_VLB CTCP Xây dựng và Sản xuất Vật liệu Xây dựng Biên Hòa"
   ,"UPCOM_VLC Tổng Công ty Chăn nuôi Việt Nam - CTCP"
   ,"UPCOM_VLF Công ty Cổ phần Lương thực Thực phẩm Vĩnh Long"
   ,"UPCOM_VLG CTCP Vinalines Logistics - Việt Nam"
   ,"HNX_VMC Công ty Cổ phần Vimeco"
   ,"HOSE_VMD Công ty cổ phần Y Dược phẩm Vimedimex"
   ,"HNX_VMS CTCP Phát triển Hàng hải"
   ,"HNX_VNC Công ty Cổ phần Tập đoàn Vinacontrol"
   ,"HOSE_VNE Tổng công ty Cổ phần Xây dựng điện Việt Nam"
   ,"HNX_VNF Công ty cổ phần Vinafreight"
   ,"UPCOM_VNI Công ty cổ phần Đầu tư Bất động sản Việt Nam"
   ,"HOSE_VNL Công ty cổ phần Logistics Vinalink"
   ,"UPCOM_VNP Công ty cổ phần Nhựa Việt Nam"
   ,"HNX_VNR Tổng Công ty Cổ phần Tái bảo hiểm quốc gia Việt Nam"
   ,"HOSE_VNS Công ty Cổ phần Ánh Dương Việt Nam"
   ,"HNX_VNT Công ty cổ phần Giao nhận Vận tải Ngoại thương"
   ,"UPCOM_VNX Công ty Cổ phần Quảng cáo và Hội chợ Thương mại"
   ,"UPCOM_VNY Công ty Cổ phần Thuốc Thú y Trung ương I"
   ,"UPCOM_VOC Tổng Công ty Công nghiệp Dầu thực vật Việt Nam - CTCP"
   ,"HOSE_VOS Công ty Cổ phần Vận tải biển Việt Nam"
   ,"UPCOM_VPA CTCP Vận tải Hóa dầu VP"
   ,"UPCOM_VPC Công ty Cổ phần Đầu tư và Phát triển Năng lượng Việt Nam"
   ,"HOSE_VPH Công ty Cổ phần Vạn Phát Hưng"
   ,"UPCOM_VPR CTCP In và Thương mại Vina"
   ,"HOSE_VPS CTCP Thuốc sát trùng Việt Nam"
   ,"UPCOM_VQC Công ty Cổ phần Giám định Vinacomin"
   ,"HOSE_VRC Công ty Cổ phần Xây lắp và Địa ốc Vũng Tàu"
   ,"UPCOM_VRG CTCP Phát triển đô thị và Khu công nghiệp Cao su Việt Nam"
   ,"HNX_VSA Công ty cổ phần Đại lý Hàng hải Việt Nam"
   ,"HOSE_VSC Công ty cổ phần Tập đoàn Container Việt Nam"
   ,"UPCOM_VSG Công ty Cổ phần Container Phía Nam"
   ,"HOSE_VSI Công ty Cổ phần Đầu tư và Xây dựng Cấp thoát nước"
   ,"UPCOM_VSN CTCP Việt Nam Kỹ nghệ Súc sản"
   ,"UPCOM_VST Công ty Cổ phần Vận tải và Thuê tàu biển Việt Nam"
   ,"UPCOM_VTA Công ty Cổ phần Vitaly"
   ,"HOSE_VTB Công ty Cổ phần Viettronics Tân Bình"
   ,"HNX_VTC Công ty Cổ phần Viễn thông VTC"
   ,"HNX_VTH Công ty Cổ phần Dây cáp điện Việt Thái"
   ,"UPCOM_VTI Công ty Cổ phần Sản xuất – Xuất nhập khẩu Dệt May"
   ,"HOSE_VTO Công ty Cổ phần Vận tải Xăng dầu VITACO"
   ,"HNX_VTV Công ty Cổ phần VICEM Vật tư Vận tải Xi măng"
   ,"UPCOM_VTX Công ty cổ phần Vận tải đa phương thức Vietranstimex"
   ,"UPCOM_VWS Công ty Cổ phần Nước và Môi trường Việt Nam"
   ,"HNX_WCS Công ty Cổ phần Bến xe Miền Tây"
   ,"UPCOM_WSB Công ty Cổ phần Bia Sài Gòn - Miền Tây"
   ,"UPCOM_WTC CTCP Vận tải thủy - Vinacomin"
   ,"UPCOM_XHC Công ty cổ phần Xuân Hòa Việt Nam"
   ,"UPCOM_XMD Công ty cổ phần Xuân Mai - Đạo Tú"
   ,"UPCOM_XPH Công ty Cổ phần Xà phòng Hà Nội"
   ,"UPCOM_YBC Công ty Cổ phần Xi măng và Khoáng sản Yên Bái"

  }
//+------------------------------------------------------------------+
