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
#define BtnCkD1_                    "BtnCkD1_"
#define BtnDelCk_                   "BtnDelCk_"
#define BtnDrawCkMonthly            "BtnDrawCkMonthly"
#define BtnDrawCkWeekly             "BtnDrawCkWeekly"
#define BtnDrawCk4hours             "BtnDrawCk4hours"
#define BtnClearChart               "BtnClearChart"
#define BtnSearchSymbol             "BtnSearchSymbol"
#define BtnFollowing_               "BtnFollowing_"
#define BtnTrading_                 "BtnTrading_"
#define BtnCkTradingView            "BtnCkTradingView"
#define BtnCkBCTC                   "BtnCk_BCTC"
#define BtnScreenHD                 "BtnScreenHD"
#define BtnScreen27                 "BtnScreen27"
#define BtnScreen34                 "BtnScreen34"
#define BtnHideDrawMode             "BtnHideDrawMode"
#define BtnSaveResult               "BtnSaveResult"
#define BtnLoadResult               "BtnLoadResult"
#define BtnMakeSymbolsJson          "BtnMakeSymbolsJson"
#define BtnCandidateJson            "BtnCandidateJson"
#define BtnOptionPeriod             "BtnOption_Period_"
#define BtnMarketType               "BtnMarketType"
#define CLICKED_SYMBOL_CK_INDEX    "CLICKED_CK_INDEX"
#define LAST_CHECKED_BINANCE_INDEX "LAST_CHECKED_BINANCE_INDEX"
#define REQUEST_BINANCE_PER_MINUS  "timer_send_minus"
#define TEXT_INPUT                 "TEXT_INPUT"
#define BtnManualLoadData         "BtnManualLoadData"
#define BtnResetLoadData          "BtnResetLoadData"
#define BtnDoSearch               "BtnDoSearch"
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
#define BtnFilterCondMoSeq        BtnFilter_+"CondM1C1"
#define BtnFilterCondW1Seq        BtnFilter_+"CondW1C3"
#define BtnFilterCondW1C3         BtnFilter_+"CondW1C1"
#define BtnFilterCondD1C2         BtnFilter_+"CondD1C2"
#define BtnFilterCondH4C3         BtnFilter_+"CondH4C3"
#define BtnFilterH4Seq         BtnFilter_+"CondH4Sq"
#define BtnFilterCondH450         BtnFilter_+"CondH450"
#define BtnFilter1BilVnd          BtnFilter_+"1BilVnd"
#define BtnFilter500BVnd          BtnFilter_+"500BVnd"
#define BtnFilter1000BVnd         BtnFilter_+"1000BVnd"
#define BtnFilter5000BVnd         BtnFilter_+"5000BVnd"
#define BtnToutch_                "BtnToutch_"
#define BtnMsg_                   "BtnMsg_"
#define STR_DRAW_CHART            "Draw_"
const string FILE_MSG_LIST_R1C1 = "R1C1.txt";
const string FILE_MSG_LIST_R1C2 = "R1C2.txt";
const string FILE_MSG_LIST_R1C3 = "R1C3.txt";
const int MAX_MESSAGES= 1000;
const string ENTRY_FIBO_382="#382";
const string ENTRY_MA10="#Ma10";
const string TREND_BUY="BUY";
const string TREND_SEL="SELL";
const string STR_SEQ_BUY="SeqBuy";
const string STR_SEQ_SEL="SeqSel";
const string MASK_TOUCH_MA50="|50|";
datetime TIME_OF_ONE_H1_CANDLE=3600;
datetime TIME_OF_ONE_H4_CANDLE=14400;
datetime TIME_OF_ONE_D1_CANDLE=86400;
datetime TIME_OF_ONE_W1_CANDLE=604800;
datetime GLOBAL_TIME_OF_ONE_CANDLE=TIME_OF_ONE_W1_CANDLE-TIME_OF_ONE_H4_CANDLE*7;
datetime GLOBAL_TIME_OF_ONE_VOL_CANDLE=GLOBAL_TIME_OF_ONE_CANDLE-TIME_OF_ONE_H4_CANDLE*5;
color clrActiveBtn = clrLightGreen;
color clrActiveSell= clrMistyRose;
const int BTN_PER_COLUMN=37;
const int NUM_CANDLE_DRAW=21;
const double SYMBOL_TYPE_CK=12.0;
const double FILTER_NON=111;
const double FILTER_BUY=333;
const double FILTER_SEL=555;
const double FILTER_ON =777;
const double OPTION_FOLOWING=111.1;
const double VOL_1BILLION_VND=1000000000;
const double VOL_100BVND=100;
const double VOL_500BVND=500;
const double VOL_1000BVND=1000;
const double VOL_5000BVND=5000;
const double AUTO_TRADE_ONN=1.0;
const double AUTO_TRADE_OFF=-1.0;
const string MORE_THAN_100BIL_VND=">100b";
const string MORE_THAN_500BIL_VND=">500b";
const string MORE_THAN_1000BIL_VND=">1000b";
const string MORE_THAN_5000BIL_VND=">5000b";
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

string ARR_SYMBOLS_FX[] =
  {
   "ICMARKETS_US30", "ICMARKETS_US500", "ICMARKETS_JP225", "ICMARKETS_DE40"
   , "ICMARKETS_XAUUSD", "ICMARKETS_XTIUSD", "ICMARKETS_BTCUSD"
   , "ICMARKETS_EURUSD", "ICMARKETS_USDJPY", "ICMARKETS_GBPUSD", "ICMARKETS_USDCHF", "ICMARKETS_AUDUSD", "ICMARKETS_USDCAD", "ICMARKETS_NZDUSD"
  };

string ARR_SYMBOLS_BANKS[] =
  {
   "HOSE_BID", "HOSE_CTG", "HOSE_EIB", "HOSE_MBB", "HOSE_STB", "HOSE_VCB"
   , "HOSE_ACB", "HOSE_HDB", "HOSE_LPB", "HOSE_MSB", "HOSE_OCB", "HOSE_SHB", "HOSE_SSB", "HOSE_TCB", "HOSE_TPB", "HOSE_VIB", "HOSE_VPB", "HOSE_NAB"
   , "HNX_NVB", "HNX_BAB"
   , "UPCOM_ABB", "UPCOM_BVB", "UPCOM_KLB", "UPCOM_SGB", "UPCOM_PGB", "UPCOM_VAB","UPCOM_VBB"
  };

//string ARR_SYMBOLS_CK[] =
//  {
//   "HOSE_VNINDEX"
//   , "HOSE_BVH", "HOSE_FPT", "HOSE_HPG", "HOSE_HVN", "HOSE_PVT", "HOSE_SSI", "HOSE_POW", "UPCOM_MSR", "UPCOM_HBC"
//
//   , "HOSE_BID", "HOSE_CTG", "HOSE_EIB", "HOSE_MBB", "HOSE_STB", "HOSE_VCB"
//   , "HOSE_ACB", "HOSE_HDB", "HOSE_LPB", "HOSE_MSB", "HOSE_OCB", "HOSE_SHB", "HOSE_SSB", "HOSE_TCB", "HOSE_TPB", "HOSE_VIB", "HOSE_VPB", "HOSE_NAB"
//   , "HNX_NVB", "HNX_BAB"
//   , "UPCOM_ABB", "UPCOM_BVB", "UPCOM_KLB", "UPCOM_SGB", "UPCOM_PGB", "UPCOM_VAB","UPCOM_VBB"
//
//   , "ICMARKETS_US30", "ICMARKETS_US500", "ICMARKETS_JP225", "ICMARKETS_DE40"
//   , "ICMARKETS_XAUUSD", "ICMARKETS_XTIUSD", "ICMARKETS_BTCUSD"
//  };

//Week Seq Buy && Vol>=100BIL/thang
string ARR_SYMBOLS_CK[] =
  {
   "HOSE_VNINDEX"
   , "HNX_DL1", "HNX_DST", "HNX_IPA", "HNX_MAC", "HNX_NDN", "HNX_NTP", "HNX_NVB", "HNX_PLC", "HNX_PVS", "HNX_SHS", "HNX_VFS", "HOSE_AGG", "HOSE_APG", "HOSE_BAF", "HOSE_BFC", "HOSE_BMI", "HOSE_BMP", "HOSE_BWE", "HOSE_CII", "HOSE_CRE", "HOSE_DBC"
   , "HOSE_DCL", "HOSE_DCM", "HOSE_DLG", "HOSE_DPG", "HOSE_DXG", "HOSE_DXS", "HOSE_EIB", "HOSE_EVF", "HOSE_EVG", "HOSE_FIR", "HOSE_FIT", "HOSE_GEE", "HOSE_GEG", "HOSE_GEX", "HOSE_GIL", "HOSE_HAG", "HOSE_HAH", "HOSE_HAP", "HOSE_HDG", "HOSE_HHS"
   , "HOSE_HHV", "HOSE_HQC", "HOSE_HTN", "HOSE_HVH", "HOSE_HVN", "HOSE_IMP", "HOSE_ITC", "HOSE_JVC", "HOSE_KHG", "HOSE_KOS", "HOSE_LDG", "HOSE_MBB", "HOSE_MHC", "HOSE_MSB", "HOSE_MWG", "HOSE_NAF", "HOSE_NLG", "HOSE_NTL", "HOSE_NVL", "HOSE_PAN"
   , "HOSE_PET", "HOSE_POW", "HOSE_QCG", "HOSE_REE", "HOSE_SCR", "HOSE_SHB", "HOSE_SMC", "HOSE_STB", "HOSE_TCB", "HOSE_TCH", "HOSE_TDH", "HOSE_TDM", "HOSE_TLD", "HOSE_TLH", "HOSE_TSC", "HOSE_TV2", "HOSE_VCG", "HOSE_VHM", "HOSE_VIC", "HOSE_VIX"
   , "HOSE_VND", "HOSE_VRE", "UPCOM_AAS", "UPCOM_ABB", "UPCOM_C4G", "UPCOM_G36", "UPCOM_KLB", "UPCOM_LTG", "UPCOM_MSR", "UPCOM_SSH", "UPCOM_TAR", "UPCOM_VAB", "UPCOM_VCR", "UPCOM_VEA"
  }; //95

const string VN30="HOSE_VNINDEX, "+
                  "HOSE_ACB, HOSE_BCM, HOSE_BID, HOSE_BVH, HOSE_CTG, HOSE_FPT, HOSE_GAS, HOSE_GVR, HOSE_HDB, HOSE_HPG, "+
                  "HOSE_MBB, HOSE_MSN, HOSE_MWG, HOSE_PLX, HOSE_POW, HOSE_SAB, HOSE_SHB, HOSE_SSB, HOSE_SSI, HOSE_STB, "+
                  "HOSE_TCB, HOSE_TPB, HOSE_VCB, HOSE_VHM, HOSE_VIB, HOSE_VIC, HOSE_VJC, HOSE_VNM, HOSE_VPB, HOSE_VRE  ";

const string HNX30= "HNX_BCC, HNX_BVS, HNX_CAP, HNX_CEO, HNX_DTD, HNX_DVM, HNX_DXP, HNX_HLD, HNX_HUT, HNX_IDC, HNX_L14, HNX_L18, HNX_LAS, HNX_LHC, HNX_MBS, "+
                    "HNX_NBC, HNX_PLC, HNX_PSI, HNX_PVC, HNX_PVG, HNX_PVS, HNX_SHS, HNX_SLS, HNX_TDN, HNX_TIG, HNX_TNG, HNX_TVD, HNX_VC3, HNX_VCS, HNX_VIG";

const string NOT_TRADE = "HNX_L18" + "HNX_LAS" + "HNX_LHC" + "HNX_NAG" + "HNX_PGS" + "HNX_PSD" + "HNX_SD9" + "HNX_TVD" + "HNX_VIT" + "HOSE_ACC" + "HOSE_ANV" + "HOSE_BBC" + "HOSE_C32" + "HOSE_CDC" + "HOSE_CTF" + "HOSE_CTI" + "HOSE_D2D"
                         + "HOSE_DHA" + "HOSE_DIG" + "HOSE_HCM" + "HOSE_HDC" + "HOSE_KDC" + "HOSE_NBB" + "HOSE_NNC" + "HOSE_SBT" + "HOSE_SHI" + "HOSE_TCL" + "HOSE_THG" + "HOSE_TRC" + "HOSE_VRC" + "HOSE_VSC" + "HOSE_VSH"
                         + "UPCOM_CLX" + "UPCOM_CTW" + "UPCOM_DDV" + "UPCOM_MCH" + "UPCOM_SWC" + "UPCOM_TBD" + "UPCOM_VFC" + "HOSE_TMS" + "HNX_VMS" + "HNX_VC3" + "HNX_CEO";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0);


   Draw_Buttons();

//EventSetTimer(10); // Mỗi 10 giây gọi lại OnTimer
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Buttons()
  {
   int size_ck =ArraySize(ARR_SYMBOLS_CK);

   WriteFileContent(FILE_MSG_LIST_R1C1,"");
   WriteFileContent(FILE_MSG_LIST_R1C2,"");
   WriteFileContent(FILE_MSG_LIST_R1C3,"");

   int btn_width = 180;
   int column[19]; // Mảng để lưu vị trí cột
   for(int i = 0; i < 19; i++)
      column[i] = 30+i*(btn_width+100); // Tính toán khoảng cách cột

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
   bool FilterCondH4Sq=GetGlobalVariable(BtnFilterH4Seq)==FILTER_ON?true:false;
   bool FilterCondH4Ma50=GetGlobalVariable(BtnFilterCondH450)==FILTER_ON?true:false;

   bool Filter1BilVnd=GetGlobalVariable(BtnFilter1BilVnd)==FILTER_ON?true:false;
   bool Filter500BVnd=GetGlobalVariable(BtnFilter500BVnd)==FILTER_ON?true:false;
   bool Filter1000BVnd=GetGlobalVariable(BtnFilter1000BVnd)==FILTER_ON?true:false;
   bool Filter5000BVnd=GetGlobalVariable(BtnFilter5000BVnd)==FILTER_ON?true:false;

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
   createButton(BtnSearchSymbol,"Search",search_x+100+60*1, row_02,50,btn_filter_heigh,clrBlack,clrWhite,8);
   string fillterSymbol=GetTextInput();
   createButton(BtnFilterTrading,"Trade",search_x+100+60*2,row_02,50,btn_filter_heigh,clrBlack,is_filter_trading?clrActiveBtn:clrWhite,8);
   createButton(BtnFilterToday,"Today?", search_x+100+60*3,row_02,50,btn_filter_heigh,clrBlack,clrWhite,8);
   createButton(BtnFilterClear,"Clear",  search_x+100+60*4,row_02,50,btn_filter_heigh,clrBlack,clrYellow,8);

   createButton(BtnDoSearch,"Search", search_x+450,row_02,50,40,clrBlack,clrWhite,8);

   bool is_hide_mode=GetGlobalVariable(BtnHideDrawMode)==AUTO_TRADE_ONN;

   double intPeriod = GetGlobalVariable(BtnOptionPeriod);
   if(intPeriod<0)
     {
      intPeriod = PERIOD_D1;
      SetGlobalVariable(BtnOptionPeriod,(double)intPeriod);
     }

   createButton(BtnOptionPeriod+"_MN1", "Mo",10+0*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_MN1?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_W1",  "W1",10+1*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_W1 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_D1",  "D1",10+2*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_D1 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_H4",  "H4",10+3*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_H4 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_30", "m30",10+4*(btn_filter_width+5),chart_heigh,30,btn_filter_heigh,clrBlack,intPeriod==PERIOD_M30 ?clrActiveBtn:clrWhite,7);

   createButton(BtnSaveResult,   "Save",            50+5*(btn_filter_width+10)+55*0,chart_heigh,50,btn_filter_heigh,clrBlack,clrWhite,7);
   createButton(BtnLoadResult,   "Load",            50+5*(btn_filter_width+10)+55*1,chart_heigh,50,btn_filter_heigh,clrBlack,clrWhite,7);
   createButton(BtnCandidateJson,"(Bg)Summary.json",50+5*(btn_filter_width+10)+55*3-30,chart_heigh,130,btn_filter_heigh,clrBlack,clrWhite,7);
   createButton(BtnMakeSymbolsJson,"symbols.json",  50+5*(btn_filter_width+10)+55*5,chart_heigh,90,btn_filter_heigh,clrBlack,clrWhite,7);

   int x_start=2;
   count=0;
   createButton(BtnFilterVn30,"Vn30",    x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,is_vn30?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHnx30,"Hnx30",  x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,is_hnx30?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterCondM383,ENTRY_FIBO_382,x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondM383?clrActiveBtn:clrLightGray,8);

   count+=1;
   createButton(BtnFilterMa20Mo,"20M", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCond3M?clrActiveBtn:clrPowderBlue,8);
   count+=1;
   createButton(BtnFilterMa10Mo,"10M", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondMO?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterMa10W1,"10W", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondW1?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterMa10H4,"10H4",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondH4?clrActiveBtn:clrLightGray,8);
   count+=1;

   count+=1;
   createButton(BtnFilterHistMo,"His.Mx",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistMo?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHistWx,"His.Wx",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistWx?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton(BtnFilterHistHx,"His.H4",x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterHistHx?clrActiveBtn:clrLightGray,8);
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
   createButton(BtnFilterCondW1Seq,"W.Seq", x_start+60*count,row_01,50,btn_filter_heigh,clrBlack,FilterCondW1Seq?clrActiveBtn:clrActiveSell,8);
   count+=1;
   createButton(BtnFilterH4Seq,"H4.Seq",x_start+60*count,row_01,88,btn_filter_heigh,clrBlack,FilterCondH4Sq?clrActiveBtn:clrActiveSell,8);
   count+=1;
//--------------------------------------------------------------------------------------------------------
   count=0;
   x_start=2;
   createButton(BtnFilterFollow,"^ ^ Only",x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,is_only_follow?clrActiveBtn:clrLightGray,8);
   count+=1;
   createButton("GROUP_"+GROUP_NGANHANG,GROUP_NGANHANG,     x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_NGANHANG?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_OTHERS,GROUP_OTHERS,         x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_OTHERS?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_DAUKHI,GROUP_DAUKHI,         x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_DAUKHI?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_CHUNGKHOAN,GROUP_CHUNGKHOAN, x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_CHUNGKHOAN?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_BATDONGSAN,GROUP_BATDONGSAN, x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_BATDONGSAN?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_DUOCPHAM,GROUP_DUOCPHAM,     x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_DUOCPHAM?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_PHANBON,GROUP_PHANBON,       x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_PHANBON?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_THEP,GROUP_THEP,             x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_THEP?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_CONGNGHIEP,GROUP_CONGNGHIEP, x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_CONGNGHIEP?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_MAYMAC,GROUP_MAYMAC,         x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_MAYMAC?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_DIEN,GROUP_DIEN,             x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_DIEN?clrActiveBtn:clrWhite,8);
   count+=1;
   createButton("GROUP_"+GROUP_DAVINCI,GROUP_DAVINCI,       x_start+60*count,row_02,50,btn_filter_heigh,clrBlack,IS_GROUP_DAVINCI?clrActiveBtn:clrWhite,8);
   count+=1;
//createButton(BtnFilter1BilVnd,"1b",                         x_start+60*count+25*0,row_02,23,btn_filter_heigh,clrBlack,Filter1BilVnd?clrActiveBtn:clrLightGray,8);
   createButton(BtnFilter500BVnd,DoubleToString(VOL_500BVND,0),x_start+60*count+25*0,row_02,23,btn_filter_heigh,clrBlack,Filter500BVnd?clrActiveBtn:clrLightGray,8);
   createButton(BtnFilter1000BVnd,"1K",                        x_start+60*count+25*1,row_02,23,btn_filter_heigh,clrBlack,Filter1000BVnd?clrActiveBtn:clrLightGray,8);
   createButton(BtnFilter5000BVnd,"5K",                        x_start+60*count+25*2,row_02,23,btn_filter_heigh,clrBlack,Filter5000BVnd?clrActiveBtn:clrLightGray,8);
   count+=1;

//--------------------------------------------------------------------------------------------------------
   x_start = (int)chart_width/2+200;
   bool is_screen_mode_hd=GetGlobalVariable(BtnScreenHD)==AUTO_TRADE_ONN;
   bool is_screen_mode_27=GetGlobalVariable(BtnScreen27)==AUTO_TRADE_ONN;
   bool is_screen_mode_34=GetGlobalVariable(BtnScreen34)==AUTO_TRADE_ONN;

   createButton(BtnToutch_+"up_ck", "Up",    x_start-55*8,chart_heigh-15, 90,30,clrBlack,clrWhite,8);
   createButton(BtnToutch_+"dn_ck", "Dn",    x_start-55*6,chart_heigh-15, 90,30,clrBlack,clrWhite,8);


   createButton(BtnHideDrawMode, "Hide",     x_start-55*4,chart_heigh-3, 50,btn_filter_heigh,clrBlack,is_hide_mode?clrActiveBtn:clrWhite,8);
   createButton(BtnScreenHD, "Hd",           x_start-55*3,chart_heigh-3, 50,btn_filter_heigh,clrBlack,is_screen_mode_hd?clrActiveBtn:clrWhite,8);
   createButton(BtnScreen27, "27'",          x_start-55*2,chart_heigh-3, 50,btn_filter_heigh,clrBlack,is_screen_mode_27?clrActiveBtn:clrWhite,8);
   createButton(BtnScreen34, "34'",          x_start-55*1,chart_heigh-3, 50,btn_filter_heigh,clrBlack,is_screen_mode_34?clrActiveBtn:clrWhite,8);

   createButton(BtnTrading_,     "Trading",      x_start+100,chart_heigh-3, 90,btn_filter_heigh,clrBlack,clrTrading,8);
   createButton(BtnFollowing_,   "Following",    x_start+200,chart_heigh-3, 90,btn_filter_heigh,clrBlack,clrFolowing,8);
   createButton(BtnClearChart,   "Clear Chart",  x_start+300,chart_heigh-3, 90,btn_filter_heigh,clrBlack,clrWhite,8);
   createButton(BtnCkTradingView,"Trading View", x_start+400,chart_heigh-3,100,btn_filter_heigh,clrBlack,clrWhite,8);

   createButton(BtnCkBCTC,       "BCTC",         x_start+510,chart_heigh-3, 50,btn_filter_heigh,clrBlack,clrWhite,8);
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
   string sorted_symbols_ck[];
   SortSymbols(sorted_symbols_ck);
   bool foundFillterSymbol=false;
   int firstFoundIndex=-1;
   int count_mo=0, count_w1=0, count_h4=0, count_total=0;
   for(int i = 0; i< size_ck; i++)
     {
      string symbolCk = sorted_symbols_ck[i];
      if(symbolCk=="" || is_same_symbol(NOT_TRADE,symbolCk))
         continue;
      bool is_not_icmarket = is_same_symbol(symbolCk,"ICMARKETS_")==false;

      string tool_tip=get_tool_tip_ck(symbolCk);
      bool is_trading_this_symbol=GetGlobalVariable(BtnTrading_+symbolCk)==OPTION_FOLOWING;

      bool is_exit_trade_by_m30=false;
      string strend_seq_m30 = getTrendSeqM30(symbolCk, is_exit_trade_by_m30);

      if(is_not_icmarket && is_same_symbol(strend_seq_m30, STR_SEQ_BUY))
        {
         string msg_allow_h4=symbolCk + " M30.Seq(13,27,54,189) Buy" ;

         if(allow_PushMessage(symbolCk,FILE_MSG_LIST_R1C2))
            PushMessage(msg_allow_h4,FILE_MSG_LIST_R1C2);
        }

      if(is_not_icmarket && is_exit_trade_by_m30 && is_trading_this_symbol)
        {
         string msg_exit="(Exit by Ma200 m30) " + symbolCk;
         if(allow_PushMessage(symbolCk,FILE_MSG_LIST_R1C3))
            PushMessage(msg_exit,FILE_MSG_LIST_R1C3);
        }

      if(is_filter_trading && is_trading_this_symbol==false)
         continue;

      if(fillterSymbol!="" && (is_same_symbol(symbolCk,fillterSymbol)==false && is_same_symbol(tool_tip,fillterSymbol)==false))
         continue;

      if(IS_GROUP_NGANHANG && is_same_symbol(tool_tip,GROUP_NGANHANG)==false && is_same_symbol(symbolCk,"VNINDEX")==false)
         continue;
      if(IS_GROUP_OTHERS && is_same_symbol(tool_tip,GROUP_NGANHANG))
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

      string trend_ma20_w1, trend_ma10_w1, trend_hei_w1, trend_ma5_w1,low_hig_w1;
      int count_ma10_w1, count_hei_w1;
      double percent_low_w1, percent_hig_w1;
      GetTrendFromFileCk(symbolCk,PERIOD_W1,trend_ma20_w1, trend_ma10_w1, count_ma10_w1, trend_hei_w1, count_hei_w1,trend_ma5_w1,low_hig_w1,percent_low_w1,percent_hig_w1);

      string trend_ma20_h4, trend_ma10_h4, trend_hei_h4, trend_ma5_h4,low_hig_h4;
      int count_ma10_h4, count_hei_h4;
      double percent_low_h4, percent_hig_h4;
      GetTrendFromFileCk(symbolCk,PERIOD_H4,trend_ma20_h4, trend_ma10_h4, count_ma10_h4, trend_hei_h4, count_hei_h4,trend_ma5_h4,low_hig_h4,percent_low_h4,percent_hig_h4);

      bool is_h4_seq_buy=is_same_symbol(low_hig_h4,STR_SEQ_BUY);
      bool is_h4_seq_sel=is_same_symbol(low_hig_h4,STR_SEQ_SEL);
      bool is_alert_w3 = (is_same_symbol(trend_ma10_w1,TREND_BUY) && count_ma10_w1<=3);
      //--------------------------------------------------------------------
      if(is_not_icmarket && is_hide_mode==false)
        {
         string msg_allow_w1="";
         if(is_same_symbol(low_hig_w1,STR_SEQ_BUY) && is_same_symbol(low_hig_w1, "{B"))
            msg_allow_w1+=" Seq(5,10,20) W Buy";

         if(msg_allow_w1 != "" && allow_PushMessage(symbolCk,FILE_MSG_LIST_R1C1))
            PushMessage(" "+symbolCk+" "+msg_allow_w1,FILE_MSG_LIST_R1C1);
         //--------------------------------------------------------------------
         string msg_allow_h4="";
         if(is_same_symbol(low_hig_h4,STR_SEQ_BUY) && is_same_symbol(low_hig_h4, "{B") && is_same_symbol(low_hig_w1, "{B"))
            msg_allow_h4=" Seq(5,10,20) H4 Buy";

         if(msg_allow_h4!="" && is_same_symbol(symbolCk, "VNINDEX")==false && allow_PushMessage(symbolCk,FILE_MSG_LIST_R1C2))
            PushMessage(" "+symbolCk+" "+msg_allow_h4,FILE_MSG_LIST_R1C2);
         //--------------------------------------------------------------------

         string msg_exit="";
         if(is_same_symbol(symbolCk, "VNINDEX") && is_same_symbol(low_hig_w1, "{B")==false)
            msg_exit+="(EXIT_ALL) " + " His.W.SELL";

         if(is_trading_this_symbol)
           {
            if(is_same_symbol(low_hig_w1,STR_SEQ_SEL))
               msg_exit+=" Seq(5,10,20)W Sell ";

            if(is_same_symbol(low_hig_h4,STR_SEQ_SEL))
               msg_exit+=" Seq(5,10,20)H4 Sell ";

            if(msg_exit == "" && is_same_symbol(low_hig_w1, "{B")==false)
               msg_exit+="His.W SELL ";

            if(msg_exit == "" && is_h4_seq_sel && is_same_symbol(low_hig_w1, "{B")==false)
               msg_exit+="Seq SELL ";
           }

         if(msg_exit != "" && allow_PushMessage(symbolCk,FILE_MSG_LIST_R1C3))
            PushMessage(msg_exit + symbolCk,FILE_MSG_LIST_R1C3);
        }
      //if(is_same_symbol(symbolCk, "SSB"))
      //   Alert(low_hig_mo);

      //if(is_trading_this_symbol==false)
        {
         if(Filter500BVnd && is_same_symbol(low_hig_mo, MORE_THAN_500BIL_VND)==false)
            continue;
         if(Filter1000BVnd && is_same_symbol(low_hig_mo, MORE_THAN_1000BIL_VND)==false)
            continue;
         if(Filter5000BVnd && is_same_symbol(low_hig_mo, MORE_THAN_5000BIL_VND)==false)
            continue;

         if(FilterCondM383 && is_same_symbol(low_hig_mo,ENTRY_FIBO_382)==false)
            continue;

         if(FilterCondMoSeq && (is_same_symbol(low_hig_mo,STR_SEQ_BUY)==false || is_same_symbol(symbolCk, "ICMARKETS"))) // || count_hei_w1<=2
            continue;

         if((trend_ma10_mo!="") && FilterCond3M && is_same_symbol(trend_ma20_mo,TREND_BUY)==false)
            continue;

         if(FilterHistMo && !(is_same_symbol(low_hig_mo, "{B")))
            continue;
         if(FilterHistM1 && is_same_symbol(low_hig_mo, "{B1}")==false)
            continue;
         if(FilterHistM3 && is_same_symbol(low_hig_mo, "{B1}")==false && is_same_symbol(low_hig_mo, "{B2}")==false  && is_same_symbol(low_hig_mo, "{B3}")==false)
            continue;
         if((trend_ma10_mo!="") && FilterCondMO && is_same_symbol(trend_ma10_mo,TREND_BUY)==false)
            continue;
        }


      //if(is_trading_this_symbol==false)
        {
         if((trend_ma10_w1!="") && FilterCondW1 && is_same_symbol(trend_ma10_w1,TREND_BUY)==false)
            continue;

         if(FilterCondW1C3 && !(count_ma10_w1<=3 && is_same_symbol(trend_ma10_w1,TREND_BUY)))
            continue;

         if(FilterCondW1Seq && (is_same_symbol(low_hig_w1,STR_SEQ_BUY)==false || is_same_symbol(low_hig_w1, "{B")==false || is_same_symbol(symbolCk, "ICMARKETS")))
            continue;

         if(FilterHistWx && !(is_same_symbol(low_hig_w1, "{B")))
            continue;

         if(FilterHistW3 && is_same_symbol(low_hig_w1, "{B1}")==false && is_same_symbol(low_hig_w1, "{B2}")==false  && is_same_symbol(low_hig_w1, "{B3}")==false)
            continue;
        }

      if(FilterCondH4Ma50 && is_same_symbol(low_hig_h4,MASK_TOUCH_MA50)==false)
         continue;

      bool is_exist_now=false;
      bool is_exist_by_heiken=false;
      //if(is_trading_this_symbol==false)
        {
         if(FilterCondH4C3 && !(count_ma10_h4<=3 && is_same_symbol(trend_ma10_h4,TREND_BUY)))  //|| count_hei_h4<=3
            continue;

         if((trend_ma10_h4!="") && FilterCondH4 && is_same_symbol(trend_ma10_h4,TREND_BUY)==false)
            continue;

         if(FilterCondH4Sq)
           {
            if(is_same_symbol(symbolCk, "ICMARKETS") || is_same_symbol(low_hig_h4, "{B")==false || is_same_symbol(low_hig_h4, STR_SEQ_BUY)==false)
               continue;
           }

         if(FilterHistHx && !(is_same_symbol(low_hig_h4, "{B")))
            continue;

         if(Filter1BilVnd && is_same_symbol(low_hig_h4, LESS_THAN_1_BIL_VND)==false)
            continue;
        }

      if(is_trading_this_symbol && is_same_symbol(trend_hei_w1, TREND_SEL))
         is_exist_by_heiken=true;
      if(is_trading_this_symbol && is_same_symbol(trend_ma10_h4, TREND_SEL) && is_same_symbol(trend_ma10_w1, TREND_SEL) && is_same_symbol(trend_hei_w1, TREND_SEL))
         is_exist_now=true;
      bool allow_trade_h4=is_same_symbol(trend_ma10_w1, TREND_BUY) || is_same_symbol(trend_hei_w1, TREND_BUY);

      string btn_label=symbolCk+" ";
      bool is_start_mo=(is_same_symbol(trend_ma10_mo,TREND_BUY) && count_ma10_mo<=3);
      is_start_mo|=is_same_symbol(trend_ma5_mo,TREND_BUY) && is_same_symbol(trend_hei_mo,TREND_BUY) && (count_hei_mo<=3);

      color text_color=clrBlack;
      if(is_same_symbol(low_hig_mo, "{B")==false)
         text_color=clrRed;

      color bg_color=is_same_symbol(low_hig_mo, "{S")?clrMistyRose:clrHoneydew;
      color clrText = is_same_symbol(low_hig_mo, "{S")?clrRed:clrBlue;

      count_btn+=1;
      int col_index = (count_btn-1) / BTN_PER_COLUMN;
      int y_dimention = y_dimention_base + 22*((count_btn-1) % BTN_PER_COLUMN);

      if(fillterSymbol != "" && count_btn>0)
         foundFillterSymbol=true;

      if(is_hide_mode==false)
         if(is_folowing_this_symbol)
            createButton("BtnCkFolowing"+symbolCk,"",column[col_index]-7,y_dimention,7,btn_heigh,clrText,clrActiveBtn);

      //if(count>110 && count<114)
      //   Alert(count, "  ", symbolCk);

      count+=1;
      StringReplace(btn_label,"HOSE_","");
      StringReplace(btn_label,"HNX_","");
      StringReplace(btn_label,"UPCOM_","");
      StringReplace(btn_label,"ICMARKETS_","");
      //StringReplace(low_hig_mo,ENTRY_FIBO_382,"");
      StringReplace(low_hig_mo,ENTRY_MA10,"");
      StringReplace(low_hig_mo,"|50|","");
      StringReplace(low_hig_mo,STR_SEQ_BUY,"");
      StringReplace(low_hig_mo,STR_SEQ_SEL,"");

      StringReplace(low_hig_mo,MORE_THAN_100BIL_VND,"");
      StringReplace(low_hig_mo,MORE_THAN_500BIL_VND,"");
      StringReplace(low_hig_mo,MORE_THAN_1000BIL_VND,"");
      StringReplace(low_hig_mo,MORE_THAN_5000BIL_VND,"");
      //for(int b=1;b<=25;b++)
      //  {
      //   StringReplace(low_hig_mo,"  "," ");
      //   //StringReplace(low_hig_mo,"{B"+IntegerToString(b)+"}","");
      //   //StringReplace(low_hig_mo,"{S"+IntegerToString(b)+"}","");
      //  }

      createButton(BtnCkD1_+symbolCk,append1Zero(count_btn)+". "+btn_label+low_hig_mo,column[col_index],y_dimention
                   ,is_hide_mode==false?btn_width:0
                   ,btn_heigh,clrText,bg_color,7);

      if(is_hide_mode==false)
        {
         string trend_histogram_w = getBracesContent(low_hig_w1);
         color clr_TextW = is_same_symbol(trend_histogram_w, "S")?clrRed:clrBlue;
         color bg_ColorW = is_same_symbol(trend_histogram_w, "S")?clrMistyRose:clrHoneydew;

         createButton(BtnDelCk_+symbolCk+"_W1",trend_histogram_w,column[col_index]+btn_width+2,y_dimention,25,btn_heigh,clr_TextW,bg_ColorW,7);

         string trend_histogram_h4 = getBracesContent(low_hig_h4);
         color clr_TextH4 = is_same_symbol(trend_histogram_h4, "S")?clrRed:clrBlue;
         color bg_ColorH4 = is_same_symbol(trend_histogram_h4, "S")?clrMistyRose:clrHoneydew;

         createButton(BtnDelCk_+symbolCk+"_H4",trend_histogram_h4,column[col_index]+btn_width+2+27,y_dimention,25,btn_heigh,clr_TextH4,bg_ColorH4,7);

         if(is_not_icmarket && strend_seq_m30 != "")
           {
            color clr_Text_M30 = is_same_symbol(strend_seq_m30, STR_SEQ_SEL)?clrRed:clrBlue;
            color bg_Color_M30 = is_same_symbol(strend_seq_m30, STR_SEQ_SEL)?clrMistyRose:clrHoneydew;

            createButton(BtnDelCk_+symbolCk+"_m30","Seq",column[col_index]+btn_width+29*2,y_dimention,25,btn_heigh,clr_Text_M30,bg_Color_M30,7);
           }
        }

      if(firstFoundIndex==-1)
         firstFoundIndex=i;

      if(is_hide_mode==false)
         if(is_trading_this_symbol)
            createButton(BtnCkD1_ + symbolCk+"_","",column[col_index],y_dimention+17,btn_width,3,clrBlack,clrBlue);


      if(is_same_symbol(symbolCk, "ICMARKETS")==false)
        {
         count_total+=1;
         if(is_same_symbol(low_hig_mo, "{B"))
            count_mo+=1;
         if(is_same_symbol(low_hig_w1, "{B"))
            count_w1+=1;
         if(is_same_symbol(low_hig_h4, "{B"))
            count_h4+=1;
        }
     }

   if(count_total>0)
     {
      int pos_wid=125;
      int pos_sum=search_x+550;
      int count_mo_s=count_total-count_mo, count_w1_s=count_total-count_w1, count_h4_s=count_total-count_h4;

      createButton("SUMMARY_MoBuy",
                   "Mo "+CalcPercentOff(count_mo, count_total)+" "+append1Zero(count_mo)+"/"+IntegerToString(count_total)
                   ,pos_sum+(pos_wid+10)*0,row_02,pos_wid,20,count_mo>count_mo_s?clrBlue:clrBlack,clrHoneydew,count_mo>count_mo_s?8:6);
      createButton("SUMMARY_MoSel",
                   "Mo "+CalcPercentOff(count_mo_s, count_total)+" "+append1Zero(count_mo_s)+"/"+IntegerToString(count_total)
                   ,pos_sum+(pos_wid+10)*0,row_01,pos_wid,20,count_mo<count_mo_s?clrRed:clrBlack,clrMistyRose,count_mo<count_mo_s?8:6);

      createButton("SUMMARY_W1Buy",
                   "W1 "+CalcPercentOff(count_w1, count_total)+" "+append1Zero(count_w1)+"/"+IntegerToString(count_total)
                   ,pos_sum+(pos_wid+10)*1,row_02,pos_wid,20,count_w1>count_w1_s?clrBlue:clrBlack,clrHoneydew,count_w1>count_w1_s?8:6);
      createButton("SUMMARY_W1Sel",
                   "W1 "+CalcPercentOff(count_w1_s, count_total)+" "+append1Zero(count_w1_s)+"/"+IntegerToString(count_total)
                   ,pos_sum+(pos_wid+10)*1,row_01,pos_wid,20,count_w1<count_w1_s?clrRed:clrBlack,clrMistyRose,count_w1<count_w1_s?8:6);

      createButton("SUMMARY_H4Buy",
                   "H4 "+CalcPercentOff(count_h4, count_total)+" "+append1Zero(count_h4)+"/"+IntegerToString(count_total)
                   ,pos_sum+(pos_wid+10)*2,row_02,pos_wid,20,count_h4>count_h4_s?clrBlue:clrBlack,clrHoneydew,count_h4>count_h4_s?8:6);
      createButton("SUMMARY_H4Sel",
                   "H4 "+CalcPercentOff(count_h4_s, count_total)+" "+append1Zero(count_h4_s)+"/"+IntegerToString(count_total)
                   ,pos_sum+(pos_wid+10)*2,row_01,pos_wid,20,count_h4<count_h4_s?clrRed:clrBlack,clrMistyRose,count_h4<count_h4_s?8:6);
     }
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
   CreateMessagesBtn(FILE_MSG_LIST_R1C1);
   CreateMessagesBtn(FILE_MSG_LIST_R1C2);
   CreateMessagesBtn(FILE_MSG_LIST_R1C3);

   if(fillterSymbol != "")
     {
      string symbolCk = FindFiles(fillterSymbol);
      if(symbolCk!="")
         ReDrawChartCk(symbolCk);
      else
         Alert("Not found: "+fillterSymbol);
     }
   else
     {
      int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);
      string clicked_SymbolCk="";
      if(clicked_ck_index>=0 && clicked_ck_index<ArraySize(sorted_symbols_ck))
         clicked_SymbolCk=sorted_symbols_ck[clicked_ck_index];

      if(clicked_SymbolCk!="")
         ReDrawChartCk(clicked_SymbolCk);
     }

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DrawChartAndSetGlobal(string symbolUsdt,ENUM_TIMEFRAMES TF
                             ,string &scale_open_times[],string &opens[],string &closes[],string &lows[],string &highs[],string &volumes[],string &candle_times[], int chart_idx)
  {
// return "";

   string trend_found="";
   CandleData candleArray[];
   double cur_close_0 = get_arr_heiken_binance(symbolUsdt,candleArray,scale_open_times,opens,closes,lows,highs,volumes);

   if(ArraySize(candleArray)<10)
      cur_close_0 = get_arr_candles(symbolUsdt,candleArray,scale_open_times,opens,closes,lows,highs,volumes);

   int _digits=cur_close_0>1000?1:cur_close_0>100?3:5;
//--------------------------------------------------------------------------------------------------------
   string prefix=STR_DRAW_CHART+get_time_frame_name(TF);
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
//--------------------------------------------------------------------------------------------------------
   int chart_width=(int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh=(int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))-25;

   int __sub;
   double __price1,__price2;
   datetime __time1000, __time2000;
   int x1=1190, x2=2090;
   bool is_screen_mode_hd=GetGlobalVariable(BtnScreenHD)==AUTO_TRADE_ONN;
   bool is_screen_mode_27=GetGlobalVariable(BtnScreen27)==AUTO_TRADE_ONN;
   bool is_screen_mode_34=GetGlobalVariable(BtnScreen34)==AUTO_TRADE_ONN;

   if(is_screen_mode_hd)
     {
      x1-=820;
      x2-=820;
     }
   if(is_screen_mode_27)
     {
      x1-=250;
      x2-=220;
     }
   ChartXYToTimePrice(0,x1,75,__sub, __time1000,__price1);
   ChartXYToTimePrice(0,x2,80,__sub, __time2000,__price2);
   double __priceHig5=MathAbs(__price1-__price2);

   double btc_price_high, btc_price_low;
   datetime _time;
   int _sub_windows;
   ChartXYToTimePrice(0,10,70,_sub_windows,_time,btc_price_high);
   ChartXYToTimePrice(0,10,chart_heigh-70,_sub_windows,_time,btc_price_low);
   double haft_chart = (btc_price_high + btc_price_low)/2.0;

   int _width=0;
   if(TF==PERIOD_W1 || TF==PERIOD_MN1)
      btc_price_low=haft_chart+__priceHig5*2;

   if(TF==PERIOD_H4)
      btc_price_high=haft_chart-__priceHig5*15;

   if(TF==PERIOD_H4)
      _width=3;


   double btc_mid = (btc_price_high + btc_price_low) /2.0;

   double ada_price_high = real_higest; // Giá cao nhất hiện tại của ADA
   double ada_price_low = real_lowest;  // Giá thấp nhất hiện tại của ADA
   double ada_mid = (ada_price_high + ada_price_low) / 2.0;

// 2. Tính hệ số chuẩn hóa
   double btc_range = btc_price_high - btc_price_low;
   double ada_range = ada_price_high - ada_price_low;
   double normalization_factor = btc_range/ada_range;
   double offset = 0;

   datetime shift=TimeCurrent()-__time1000; // add_time*(NUM_CANDLE_DRAW+11);
   if(chart_idx>0)
      shift=TimeCurrent()-__time2000; // add_time*6;
   datetime add_time=GLOBAL_TIME_OF_ONE_CANDLE;//(datetime)(candleArray[0].time-candleArray[1].time);
   if(ada_range>0 && btc_range>0)
     {
      //double PERCENT=0;
      double lowest=DBL_MAX,higest=0.0;

      datetime start_time=candleArray[size_d1].time  -shift;
      datetime end_time=candleArray[0].time+add_time -shift;
      datetime tool_tip_time=candleArray[(int)(size_d1*2/3)].time-GLOBAL_TIME_OF_ONE_CANDLE-shift;

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
                              (i==0?candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma50_i0,clrGray,STYLE_SOLID,5);

         if(i<10 && ma20_i1>0 && ma20_i0>0)
            create_trend_line(prefix+"Ma20_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma20_i1,
                              (i==0?candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma20_i0,clrBlue,STYLE_SOLID,3);//TF==PERIOD_MN1&&ma10_i0>ma20_i0?

         if(i<17 && ma10_i1>0 && ma10_i0>0)
           {
            create_trend_line(prefix+"Ma10_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma10_i1,
                              (i==0?candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma10_i0,clrRed,STYLE_SOLID,3);
           }

         if(ma05_i1>0 && ma05_i0>0)
            create_trend_line(prefix+"Ma05_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma05_i1,
                              (i==0?candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma05_i0,clrDimGray,STYLE_SOLID,2);

         string trend=candleArray[i].trend_heiken;
         color clrBody=is_same_symbol(trend,TREND_BUY)?clrTeal:clrBlack;

         string percent = "";
         if(TF==PERIOD_MN1 && candleArray[i].low>0)
            percent = DoubleToString((MathAbs(candleArray[i].high-candleArray[i].low)/candleArray[i].low)*100.0, 1)+"%";



         double _open = BinanceStringToDouble(opens,i);
         double _close = BinanceStringToDouble(closes,i);
         double _low = BinanceStringToDouble(lows,i);
         double _high = BinanceStringToDouble(highs,i);
         double _volume = BinanceStringToDouble(volumes,i);
         color clrDelta = CalcPseudoDeltaColor(candleArray[i].trend_by_ma10,_open,_close,_low,_high,_volume);

         create_heiken_candle(prefix+"hei_"+appendZero100(i)+"_"+StringSubstr(candle_times[i], 0, 13)+"h"
                              ,candleArray[i].time+TIME_OF_ONE_H4_CANDLE*1-shift
                              ,candleArray[i].time+GLOBAL_TIME_OF_ONE_CANDLE-TIME_OF_ONE_H4_CANDLE*3-shift
                              ,open,close,low,high,clrDelta,false,1,(string)candleArray[i].count_heiken,percent); //clrBody



         if(false && i<17)
           {
            double profit=CalcProfitCandle1(candleArray[i].volume, candleArray[i].close,  candleArray[i+1].volume,candleArray[i+1].close);
            string str_profit="";
            if(TF==PERIOD_MN1)
               str_profit=DoubleToString(profit/VOL_1BILLION_VND,0);
            else
               str_profit=DoubleToString(profit/VOL_1BILLION_VND,3); //Tỷ VND

            create_label_simple(prefix+"_bil.profit_"+ appendZero100(i),str_profit+""
                                ,high+__priceHig5*5,clrBlack, candleArray[i].time+TIME_OF_ONE_H4_CANDLE*7-shift,7);
           }

         if(lowest>low)
            lowest=low;
         if(higest<high)
            higest=high;


         if(i==0)
           {
            if(candleArray[0].ma50>0)
              {
               double percent = (MathAbs(cur_close_0 - candleArray[0].ma50) / cur_close_0)*100.0;
               if(cur_close_0 > candleArray[0].ma50)
                  percent = -percent;

               double ma50_i0=(candleArray[i].ma50-ada_mid)*normalization_factor + btc_mid+offset;
               create_label_simple(prefix+"Ma50",FormatVndWithCommas(candleArray[0].ma50)+" ("+DoubleToString(percent,1)+"%)",ma50_i0,clrBlack,candleArray[0].time-shift);
              }

            if(candleArray[0].ma20>0)
              {
               double percent = (MathAbs(cur_close_0 - candleArray[0].ma20) / cur_close_0)*100.0;
               if(cur_close_0 > candleArray[0].ma20)
                  percent = -percent;

               double ma20_i0=(candleArray[i].ma20-ada_mid)*normalization_factor + btc_mid+offset;
               create_label_simple(prefix+"Ma20",FormatVndWithCommas(candleArray[0].ma20)+" ("+DoubleToString(percent,1)+"%)",ma20_i0,clrBlack,candleArray[0].time-shift);
              }

            if(candleArray[0].ma10>0)
              {
               double percent = (MathAbs(cur_close_0 - candleArray[0].ma10) / cur_close_0)*100.0;
               if(cur_close_0 > candleArray[0].ma10)
                  percent = -percent;

               double ma10_i0=(candleArray[i].ma10-ada_mid)*normalization_factor + btc_mid+offset;
               create_label_simple(prefix+"Ma10",FormatVndWithCommas(candleArray[0].ma10)+" ("+DoubleToString(percent,1)+"%)",ma10_i0,clrBlack,candleArray[0].time-shift);
              }
           }
        }

      double cur_price= cur_close_0;
      double cur_mid=(real_higest-real_lowest)/2;

      double fibo_0_100 = higest - (higest - lowest) * 0.100;
      double fibo_0_118 = higest - (higest - lowest) * 0.118;
      double fibo_0_236 = higest - (higest - lowest) * 0.236;
      double fibo_0_382 = higest - (higest - lowest) * 0.382;
      double fibo_0_500 = higest - (higest - lowest) * 0.500;
      double fibo_0_618 = higest - (higest - lowest) * 0.618;
      double fibo_0_786 = higest - (higest - lowest) * 0.786;
      double fibo_0_886 = higest - (higest - lowest) * 0.886;
      double fibo_1_236 = higest - (higest - lowest) * 1.236;
      double fibo_1_236_= higest + (higest - lowest) * 0.236;

      double fibo_real_0_100 = real_higest - (real_higest - real_lowest) * 0.100;
      double fibo_real_0_118 = real_higest - (real_higest - real_lowest) * 0.118;
      double fibo_real_0_236 = real_higest - (real_higest - real_lowest) * 0.236;
      double fibo_real_0_382 = real_higest - (real_higest - real_lowest) * 0.382;
      double fibo_real_0_500 = real_higest - (real_higest - real_lowest) * 0.500;
      double fibo_real_0_618 = real_higest - (real_higest - real_lowest) * 0.618;
      double fibo_real_0_786 = real_higest - (real_higest - real_lowest) * 0.786;
      double fibo_real_0_886 = real_higest - (real_higest - real_lowest) * 0.886;
      double fibo_real_1_236 = real_higest - (real_higest - real_lowest) * 1.236;
      double fibo_real_1_236_= real_higest + (real_higest - real_lowest) * 0.236;

      if(candleArray[0].ma05>0 && candleArray[0].ma10>0 && candleArray[0].ma20>0 && candleArray[0].ma50>0)
        {
         bool is_seq_buy=false;
         if(candleArray[0].ma05>candleArray[0].ma10 && candleArray[0].ma05>candleArray[0].ma20)
            is_seq_buy=true;

         if(candleArray[0].ma05>candleArray[1].ma05 && candleArray[0].ma10>candleArray[1].ma10 && candleArray[0].ma20>candleArray[1].ma20)
            is_seq_buy=true;

         if(is_same_symbol(candleArray[0].trend_heiken, TREND_BUY)
            && candleArray[0].close>candleArray[0].ma10
            && candleArray[0].ma05>candleArray[0].ma10 && candleArray[0].ma05>candleArray[0].ma20)
            is_seq_buy=true;

         if(is_seq_buy)
            create_label_simple(prefix+"Seq"," SEQ.Buy", fibo_0_500+__priceHig5*2,clrBlue,candleArray[1].time-shift,12);

         if(candleArray[0].ma05<candleArray[0].ma10 && candleArray[0].ma05<candleArray[0].ma20)
            create_label_simple(prefix+"Seq"," SEQ.Sell",fibo_0_500+__priceHig5*2,clrRed, candleArray[1].time-shift,12);
        }

      double sai_so=lowest*0.025;
      double price=(cur_close_0-ada_mid)*normalization_factor + btc_mid+offset;

      for(int i = 0; i < size_d1-3; i++)
         create_label_simple(prefix+"Ma10_" +appendZero100(i)
                             ,(candleArray[i].count_ma10<10?"   ":" ")+getShortName(candleArray[i].trend_by_ma10)+"."+(string)candleArray[i].count_ma10
                             ,fibo_0_886+__priceHig5+__priceHig5,candleArray[i].trend_by_ma10==TREND_BUY?clrBlue:clrRed,candleArray[i].time-shift,7);

      if(is_same_symbol(symbolUsdt,"_"))
        {
         bool is_vn30=is_same_symbol(VN30,symbolUsdt);

         int _sub_windows;
         datetime _time;
         double _price;

         if(TF==PERIOD_W1 || TF==PERIOD_MN1)
            chart_heigh=(int)(chart_heigh/2+60);
         if(ChartXYToTimePrice(0,10,chart_heigh-35,_sub_windows,_time,_price))
            create_label_simple(prefix+"TOOLTIP",get_time_frame_name(TF)+"    "+(is_vn30?"(VN30) ":"")+get_tool_tip_ck(symbolUsdt),_price,clrBlack,tool_tip_time);
        }

      datetime draw_fibo_time = (datetime)(start_time+add_time*4.8);

      create_trend_line(prefix+"HIGEST",    draw_fibo_time,higest,    end_time,higest,    clrRed,  STYLE_SOLID,1,false,false);
      create_trend_line(prefix+"LOWEST",    draw_fibo_time,lowest,    end_time,lowest,    clrBlue, STYLE_SOLID,1,false,false);
      create_trend_line(prefix+"fibo_0_118",draw_fibo_time,fibo_0_118,end_time,fibo_0_118,clrRed,  STYLE_DOT,  1,false,false);
      create_trend_line(prefix+"fibo_0_236",draw_fibo_time,fibo_0_236,end_time,fibo_0_236,clrRed,  STYLE_DOT,  1,false,false);
      create_trend_line(prefix+"fibo_0_382",draw_fibo_time,fibo_0_382,end_time,fibo_0_382,clrBlack,STYLE_DOT,  1,false,false);
      create_trend_line(prefix+"fibo_0_500",draw_fibo_time,fibo_0_500,end_time,fibo_0_500,clrBlack,STYLE_SOLID,1,false,false);
      create_trend_line(prefix+"fibo_0_618",draw_fibo_time,fibo_0_618,end_time,fibo_0_618,clrBlack,STYLE_DOT,  1,false,false);
      create_trend_line(prefix+"fibo_0_786",draw_fibo_time,fibo_0_786,end_time,fibo_0_786,clrBlue, STYLE_SOLID,1,false,false);
      create_trend_line(prefix+"fibo_0_886",draw_fibo_time,fibo_0_886,end_time,fibo_0_886,clrBlue, STYLE_SOLID,1,false,false);

      create_label_simple(prefix+"0.118","0.118    " + FormatVndWithCommas(fibo_real_0_118) +" "+ CalcPercentChange(real_higest,fibo_real_0_118),fibo_0_118,clrBlack,start_time);
      create_label_simple(prefix+"0.236","0.236    " + FormatVndWithCommas(fibo_real_0_236) +" "+ CalcPercentChange(real_higest,fibo_real_0_236),fibo_0_236,clrBlack,start_time);
      create_label_simple(prefix+"0.382","0.382    " + FormatVndWithCommas(fibo_real_0_382) +" "+ CalcPercentChange(real_higest,fibo_real_0_382),fibo_0_382,clrBlack,start_time);
      create_label_simple(prefix+"0.500","0.500    " + FormatVndWithCommas(fibo_real_0_500) +" "+ CalcPercentChange(real_higest,fibo_real_0_500),fibo_0_500,clrBlack,start_time);
      create_label_simple(prefix+"0.618","0.618    " + FormatVndWithCommas(fibo_real_0_618) +" "+ CalcPercentChange(real_higest,fibo_real_0_618),fibo_0_618,clrBlack,start_time);
      create_label_simple(prefix+"0.786","0.786    " + FormatVndWithCommas(fibo_real_0_786) +" "+ CalcPercentChange(real_higest,fibo_real_0_786),fibo_0_786,clrBlack,start_time);
      create_label_simple(prefix+"0.886","0.886    " + FormatVndWithCommas(fibo_real_0_886) +" "+ CalcPercentChange(real_higest,fibo_real_0_886),fibo_0_886,clrBlack,start_time);

      if(TF!=PERIOD_H4)
        {
         create_trend_line(prefix+"fibo_1_23+",start_time+add_time*3,fibo_1_236, end_time,fibo_1_236, clrGray,STYLE_DOT,1,false,false);
         create_label_simple(prefix+"1.236","1.236    " + DoubleToString(CalculateRealValue(fibo_1_236,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_1_236+sai_so,clrBlack,start_time);
        }

      create_label_simple(prefix+"Hig%",
                          "Hig: " +FormatVndWithCommas(real_higest) + " " + CalcPercentChange(real_higest, cur_price)+" -"+FormatVndWithCommas(real_higest-cur_price)
                          ,higest,clrRed,start_time);
      create_label_simple(prefix+"Hig%_",
                          "  "+CalcPercentChange(cur_price, real_higest)
                          ,higest,clrBlue,end_time);


      create_label_simple(prefix+"Low%",
                          "Low: "+FormatVndWithCommas(real_lowest) + " " + CalcPercentChange(real_lowest, cur_price)+" +"+FormatVndWithCommas(cur_price-real_lowest)
                          ,lowest-__priceHig5*7,clrBlue,start_time);
      create_label_simple(prefix+"Low%_",
                          "  "+CalcPercentChange(cur_price, real_lowest)
                          ,lowest,clrRed,end_time);


      create_trend_line(prefix+"_close_0",start_time,price,end_time+add_time,price,clrBlue,STYLE_DOT,1,false,false);
      if(TF==PERIOD_MN1)
         create_label_simple(prefix+"cur_close_0","    "+FormatVndWithCommas(cur_close_0) + " "+ CalcPercentChange(real_higest, cur_price)
                             ,price,clrRed,end_time+add_time);
      else
         create_label_simple(prefix+"cur_close_0","    "+FormatVndWithCommas(cur_close_0) + " "+ CalcPercentChange(real_lowest, cur_price)
                             ,TF!=PERIOD_H4?price: price>higest-sai_so*2?higest-sai_so*2: price,clrBlue,end_time+add_time);


      //------------------------------------------------------------------
      //------------------------------------------------------------------
      //------------------------------------------------------------------
      double chart_height = btc_price_high - btc_price_low;
      double start_price = btc_price_low;
      double volume_to_price_ratio = (TF==PERIOD_MN1)?(chart_height*0.1/max_volume)
                                     :(TF==PERIOD_W1)?(chart_height*0.1/max_volume)
                                     :(chart_height*0.18/max_volume);

      int count_vol=0;
      double total_volume=0;
      for(int i = size_d1-2; i >=0 ; i--)
        {

         double price_height = candleArray[i].volume * volume_to_price_ratio;
         datetime draw_time=candleArray[i].time-shift;

         if(max_volume>1)
           {
            datetime timeFr = candleArray[i].time+TIME_OF_ONE_H4_CANDLE*2-shift;
            string volume_name = prefix +"V_"+ appendZero100(i)+"_"+StringSubstr(candle_times[i], 0, 13)+"h";
            create_heiken_candle(volume_name
                                 ,timeFr
                                 ,timeFr+GLOBAL_TIME_OF_ONE_VOL_CANDLE
                                 ,start_price,start_price+price_height,start_price,start_price+price_height
                                 ,candleArray[i].count_ma10<=1 && is_same_symbol(candleArray[i].trend_by_ma10,TREND_BUY)?clrActiveBtn:clrGainsboro,true,1,"");

            if(candleArray[i].volume>0 && is_same_symbol(symbolUsdt,"ICMARKETS")==false)
              {
               if(i<=20)
                 {
                  count_vol+=1;
                  total_volume+= candleArray[i].volume;

                  string bill_volume_name=prefix+"_billion_"+ appendZero100(i)+"_"+StringSubstr(candle_times[i], 0, 10)+"";
                  datetime mid_bill_time=candleArray[i].time+GLOBAL_TIME_OF_ONE_VOL_CANDLE/2-shift;

                  double _open = BinanceStringToDouble(opens,i);
                  double _close = BinanceStringToDouble(closes,i);
                  double _low = BinanceStringToDouble(lows,i);
                  double _high = BinanceStringToDouble(highs,i);
                  double _volume = BinanceStringToDouble(volumes,i);
                  color clrDelta = CalcPseudoDeltaColor(candleArray[i].trend_by_ma10,_open,_close,_low,_high,_volume);


                  if(TF==PERIOD_H4)
                    {
                     double billion = candleArray[i].volume*_close/VOL_1BILLION_VND; //Tỷ VND
                     create_label_simple(bill_volume_name,DoubleToString(billion,2)
                                         ,start_price+__priceHig5*5,clrDelta, mid_bill_time,7);
                    }
                  else
                    {
                     double billion = NormalizeDouble(candleArray[i].volume*_close/VOL_1BILLION_VND,0); //Tỷ VND
                     create_label_simple(bill_volume_name,FormatVndWithCommas(billion)+""
                                         ,start_price+__priceHig5*7,clrDelta, mid_bill_time,7);
                    }

                  ObjectSetDouble(0,bill_volume_name,OBJPROP_ANGLE,-90);
                  ObjectSetInteger(0,bill_volume_name,OBJPROP_ANCHOR,ANCHOR_CENTER);

                  if(i==0)
                    {
                     double avg_volume = (total_volume/count_vol);
                     double billion = avg_volume*_close/VOL_1BILLION_VND;//Tỷ VND

                     string lblAvgVol = ""+FormatVndWithCommas(billion)+" b";
                     if(avg_volume<50)
                        lblAvgVol = ""+DoubleToString(billion,1)+" b";
                     if(avg_volume<1)
                        lblAvgVol = ""+DoubleToString(billion,2)+" b";

                     create_label_simple(prefix+"_billion_avg_"+IntegerToString(count_vol)+"candles","("+lblAvgVol+")"//" (r "+DoubleToString(real_volume,0)+" b)"
                                         ,start_price+__priceHig5*5,billion<VOL_500BVND?clrRed:clrBlue
                                         , candleArray[0].time+TIME_OF_ONE_H4_CANDLE*7+GLOBAL_TIME_OF_ONE_CANDLE-shift,8);
                    }

                 }

              }
           }
        }

      double closeArray[];
      datetime timeFrArr[];
      //int size = ArraySize(candleArray);
      ArrayResize(closeArray, size);
      ArrayResize(timeFrArr, size);

      for(int i = 0; i < size-10; i++)
        {
         closeArray[i] = candleArray[i].close;
         timeFrArr[i] = candleArray[i].time+TIME_OF_ONE_H4_CANDLE*2-shift;
        }

      double hist_range=__priceHig5;//btc_range*0.1;//
      string prefix=STR_DRAW_CHART+get_time_frame_name(TF)+"_";

      DrawAndCountHistogram(prefix, closeArray, timeFrArr, candle_times, true, btc_price_low-hist_range, btc_price_low+hist_range);
     }

   return trend_found;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color CalcPseudoDeltaColor(string trend, double open, double close, double low, double high, double volume)
  {
   double body_size    = MathAbs(close - open);
   double upper_wick   = high - MathMax(open, close);
   double lower_wick   = MathMin(open, close) - low;
   double total_range  = high - low;

// Tránh chia cho 0 nếu cây nến là doji (không có biến động)
   if(total_range == 0)
      return clrSilver;

// Tính tỷ lệ (trọng số tương đối)
   double weight_body  = body_size / total_range;
   double weight_upper = upper_wick / total_range;
   double weight_lower = lower_wick / total_range;

   double pseudo_delta = 0;

   if(trend == "BUY")
     {
      pseudo_delta =
         (close > open) * weight_body * body_size * volume +
         weight_lower * lower_wick * volume -
         weight_upper * upper_wick * volume;
     }
   else
      if(trend == "SELL")
        {
         pseudo_delta =
            -(close < open) * weight_body * body_size * volume -
            weight_lower * lower_wick * volume +
            weight_upper * upper_wick * volume;
        }

// Gán màu theo độ mạnh yếu
//if(pseudo_delta > 0.5)
//   return clrTeal;     // Áp lực mua mạnh
//else
//   if(pseudo_delta > 0)
//      return clrPaleGreen;     // Áp lực mua nhẹ
//   else
//      if(pseudo_delta < -0.5)
//         return clrFireBrick;        // Áp lực bán mạnh
//      else
//         if(pseudo_delta < 0)
//            return clrFireBrick;   // Áp lực bán nhẹ clrLightSalmon
//         else
//            return clrSilver;        // Trung lập

   return (pseudo_delta > 0)?clrTeal:(pseudo_delta < 0)?clrFireBrick : clrFireBrick;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DrawAndCountHistogram(string prefix, const double &closeArray[], datetime &timeFrArr[], string &candle_times[], bool allow_draw, double from=30000, double to=60000)
  {
   string histogramPrefix = prefix+"Hist_";
   DeleteAllObjectsWithPrefix(histogramPrefix);

   int SHORT_EMA_PERIOD = 12;
   int LONG_EMA_PERIOD = 24;
   int SIGNAL_PERIOD = 9;
   int n = ArraySize(closeArray);

   if(n < LONG_EMA_PERIOD)
     {
      //Print("Không đủ dữ liệu để vẽ MACD");
      //return "";
     }

   double macdValues[], signValues[], histogramValues[];
   ArrayResize(macdValues, n);
   ArrayResize(signValues, n);
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
      signValues[i] = CalculateEMA(macdValues, SIGNAL_PERIOD, i);
      histogramValues[i] = macdValues[i] - signValues[i];
     }

// Xác định giá trị min/max cho scale
// Tìm min/max cho scale
//double minVal = FindMinValue(macdValues);
//double maxVal = FindMaxValue(macdValues);
//minVal = NormalizeDouble(MathMin(minVal, MathMin(FindMinValue(signValues), FindMinValue(histogramValues))),5);
//maxVal = NormalizeDouble(MathMax(maxVal, MathMax(FindMaxValue(signValues), FindMaxValue(histogramValues))),5);
//if(allow_draw)
//   Alert(histogramPrefix,"    ",minVal,"       ",maxVal);
//if(MathAbs(minVal) > MathAbs(maxVal)*10)
//   minVal = -maxVal*10;
//printf(prefix+" minVal:"+DoubleToString(minVal,5)+" maxVal:"+DoubleToString(maxVal,5));

   double mid = (from + to) / 2.0;
   datetime shift = allow_draw? timeFrArr[1]-timeFrArr[2]:0;
   double histogram_heigh=MathAbs(from-to);

   string trendArrs[];
   int loop = (int)(MathMin(n-1,21));
   for(int i = loop; i > 0; i--)
     {
      if(macdValues[i] == EMPTY_VALUE || signValues[i] == EMPTY_VALUE)
         continue;

      //double scaled_macd = scaleValue(macdValues[i], minVal, maxVal, from, to);
      //double scaled_sign = scaleValue(signValues[i], minVal, maxVal, from, to);
      double histogram = macdValues[i]-signValues[i];
      //double scaled_hist = mid+1*(scaled_macd-scaled_sign);
      double scaled_hist = mid+(histogram>0?histogram_heigh:-histogram_heigh);

      if(allow_draw)
        {
         color clrColor = mid>scaled_hist?clrFireBrick:mid<scaled_hist?clrTeal:clrLightGray;
         string hist_name = histogramPrefix + appendZero100(i)+"_"+StringSubstr(candle_times[i], 0, 13)+"h";
         create_heiken_candle(hist_name
                              ,timeFrArr[i]+shift,timeFrArr[i]+shift+GLOBAL_TIME_OF_ONE_VOL_CANDLE
                              ,mid,scaled_hist
                              ,MathMin(mid,scaled_hist)
                              ,MathMax(mid,scaled_hist), clrColor,true,1);
        }

      int idx = ArraySize(trendArrs);
      ArrayResize(trendArrs,idx+1);
      trendArrs[idx]=mid>scaled_hist?TREND_SEL:TREND_BUY;
     }
   if(allow_draw)
      create_trend_line(prefix+"_zero_", timeFrArr[loop]+shift, mid,
                        timeFrArr[0]+shift-TIME_OF_ONE_D1_CANDLE*1, mid, clrBlack, STYLE_SOLID,1);

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
     {
      for(int i = ArraySize(countArr)-1; i >=0 ; i--)
        {
         string hist_name = prefix + "Hist_Count_" + IntegerToString(i)+"_"+StringSubstr(candle_times[i], 0, 13)+"h";
         color clrColor = trendArrs[i]==TREND_SEL?clrRed:clrBlue;
         double price = trendArrs[i]==TREND_SEL?mid+histogram_heigh/2:mid-histogram_heigh/2;
         string lbl = (countArr[i]<10?"    ":"   ")+IntegerToString(countArr[i]);

         create_label_simple(hist_name,lbl,price,clrColor,timeFrArr[i],7);

         create_label_simple(prefix+"_date"+ appendZero100(i)+"_"+StringSubstr(candle_times[i], 0, 13)+"h"," "+StringSubstr(candle_times[i], 5, 5)
                             ,(int)(mid-histogram_heigh*1.7),clrColor, timeFrArr[i],6);
        }
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
      if(values[i] < minVal)
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
      if(values[i] > maxVal)
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
      string buttonLabel = ObjectGetString(0,btn_d1_name,OBJPROP_TEXT);

      //color bg_color=is_same_symbol(low_hig_mo, "{S")?clrMistyRose:clrHoneydew;
      if(is_same_symbol(buttonLabel,"{B") || is_same_symbol(buttonLabel,"Buy"))
         ObjectSetInteger(0,btn_d1_name,OBJPROP_BGCOLOR,clrHoneydew);
      if(is_same_symbol(buttonLabel,"{S") || is_same_symbol(buttonLabel,"Sel"))
         ObjectSetInteger(0,btn_d1_name,OBJPROP_BGCOLOR,clrMistyRose);

      if(is_same_symbol(symbolCk, symbol))
         ObjectSetInteger(0,btn_d1_name,OBJPROP_BGCOLOR,clrYellow);
     }


   int total_objects = ObjectsTotal(0);
   for(int i = total_objects - 1; i >= 0; i--)
     {
      string obj_name = ObjectName(0, i);
      if(StringFind(obj_name, BtnMsg_) >= 0)
        {
         string msg = ObjectGetString(0,obj_name,OBJPROP_TEXT);

         if(is_same_symbol(msg, "buy"))
            ObjectSetInteger(0,obj_name,OBJPROP_BGCOLOR,clrHoneydew);
         else
            if(is_same_symbol(msg,"VNINDEX"))
               ObjectSetInteger(0,obj_name,OBJPROP_BGCOLOR,clrRed);
            else
               ObjectSetInteger(0,obj_name,OBJPROP_BGCOLOR,clrMistyRose);

         if(is_same_symbol(obj_name, symbolCk))
            ObjectSetInteger(0,obj_name,OBJPROP_BGCOLOR,clrYellow);
        }
     }


   DeleteAllObjectsWithPrefix(STR_DRAW_CHART);

   SetSelectedSymbolCk(symbolCk);
   TestReadAllDataFromFile(symbolCk,PERIOD_MN1,0);
   TestReadAllDataFromFile(symbolCk,PERIOD_W1, 1);
   TestReadAllDataFromFile(symbolCk,PERIOD_H4, 1);
   TestReadAllDataFromFile(symbolCk,PERIOD_M30,0);

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
      string object_name = ObjectName(0, i);
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
#define VK_DELETE 46
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
      Print("Sparam=",sparam," id=",id," key=",lparam," dparam=",dparam);

      if(key == VK_DELETE)
        {
         string sorted_symbols_ck[];
         SortSymbols(sorted_symbols_ck);

         int index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);
         string symbolCk= sorted_symbols_ck[index];

         ObjectDelete(0,BtnCkD1_+symbolCk);
         ObjectDelete(0,BtnDelCk_+symbolCk);
         ChartRedraw(0);

         return;
        }

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
               if(index==0)
                  Draw_Buttons();
               else
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
               if(index==0)
                  Draw_Buttons();
               else
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
      if(is_same_symbol(sparam,BtnDoSearch))
        {
         ObjectsDeleteAll(0);
         Draw_Buttons();
         return;
        }
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

      if(is_same_symbol(sparam,BtnMsg_))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("The lparam=",lparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         string symbolCk=get_symbol_ck_from_label(sparam,true);

         ReDrawChartCk(symbolCk);

         return;
        }

      if(is_same_symbol(sparam,BtnTrading_) || is_same_symbol(sparam,BtnFollowing_))
        {
         string sorted_symbols_ck[];
         SortSymbols(sorted_symbols_ck);
         int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);
         if(clicked_ck_index>=0 && clicked_ck_index<ArraySize(sorted_symbols_ck))
           {
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

         ChartRedraw(0);

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

         SetGlobalVariable(BtnFilterHistMo,FILTER_ON);
         SetGlobalVariable(BtnFilterHistWx,FILTER_ON);
         SetGlobalVariable(BtnFilterHistHx,FILTER_ON);

         SetGlobalVariable(BtnFilterH4Seq,FILTER_ON);

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

         ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrYellow);
         ChartRedraw(0);

         return;
        }

      if(is_same_symbol(sparam,BtnDelCk_))
        {
         string btnSymbol = sparam;
         StringReplace(btnSymbol,BtnDelCk_,BtnCkD1_);

         ObjectDelete(0,sparam);
         ObjectDelete(0,btnSymbol);
         ChartRedraw(0);
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

      if(is_same_symbol(sparam,BtnHideDrawMode))
        {
         double MODE=GetGlobalVariable(sparam);

         if(MODE==AUTO_TRADE_ONN)
            SetGlobalVariable(sparam,AUTO_TRADE_OFF);
         else
            SetGlobalVariable(sparam,AUTO_TRADE_ONN);

         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnScreenHD) || is_same_symbol(sparam,BtnScreen27) || is_same_symbol(sparam,BtnScreen34))
        {
         double MODE=GetGlobalVariable(sparam);

         SetGlobalVariable(BtnScreenHD,AUTO_TRADE_OFF);
         SetGlobalVariable(BtnScreen27,AUTO_TRADE_OFF);
         SetGlobalVariable(BtnScreen34,AUTO_TRADE_OFF);

         SetGlobalVariable(sparam,AUTO_TRADE_ONN);

         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnCkBCTC))
        {
           {
            int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);

            string sorted_symbols_ck[];
            SortSymbols(sorted_symbols_ck);

            string symbolCk = sorted_symbols_ck[clicked_ck_index];

            if(is_same_symbol(symbolCk, "HOSE") || is_same_symbol(symbolCk, "HNX") || is_same_symbol(symbolCk, "UPCOM"))
              {
               StringReplace(symbolCk,"HOSE_","");
               StringReplace(symbolCk,"UPCOM_","");
               StringReplace(symbolCk,"HNX_","");

               string url="https://stockbiz.vn/ma-chung-khoan/"+symbolCk;
               int result = ShellExecuteW(0, "open", url, NULL, NULL, 1);
              }
           }

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
            if(intPeriod == PERIOD_M30)
               interval="30";

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
         if(is_same_symbol(sparam,"30"))
            PERIOD = PERIOD_M30;

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

      if(is_same_symbol(sparam,BtnCandidateJson))
        {
         ListAllSymbolsCandidate();
         return;
        }

      if(is_same_symbol(sparam,BtnMakeSymbolsJson))
        {
         string sorted_symbols_ck[];
         SortSymbols(sorted_symbols_ck);
         string strNote = "";
         SaveSymbolJson(sorted_symbols_ck, true, strNote);

         // C:\Users\Admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Files\temp_symbols.json
         // string file_path = "C:\\Users\\Admin\\AppData\\Roaming\\MetaQuotes\\Terminal\\53785E099C927DB68A545C249CDBCE06\\MQL5\\Files\\_symbols.json";
         // ShellExecuteW(0, "open", file_path, NULL, NULL, 1);

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
void SaveSymbolJson(string &sorted_symbols_ck[], bool checkOnScreen, string strNotice)
  {
   string arrSymbolCk[];
//------------------------------------------------------------------
   string trading_or_folowing="";
   int gsize= GlobalVariablesTotal();
   for(int i=0;i<gsize;i++)
     {
      continue;

      string key_i = GlobalVariableName(i);
      double value=GlobalVariableGet(key_i);

      if(is_same_symbol(key_i,"VNINDEX"))
         continue;

      //(Binance)BtnTrading_HOSE_VNM
      bool is_trading_or_folowing = value==OPTION_FOLOWING;
      if(is_trading_or_folowing)
         if(is_same_symbol(key_i, "HOSE") || is_same_symbol(key_i, "HNX") || is_same_symbol(key_i, "UPCOM"))
           {
            string _tem_symbol=key_i;
            StringReplace(_tem_symbol, BOT_SHORT_NM,"");
            StringReplace(_tem_symbol, BtnFollowing_,"");
            StringReplace(_tem_symbol, BtnTrading_,"");

            if(is_same_symbol(trading_or_folowing, _tem_symbol))
               continue;

            int cur_size = ArraySize(arrSymbolCk);
            ArrayResize(arrSymbolCk, cur_size + 1);
            arrSymbolCk[cur_size] = _tem_symbol;
            trading_or_folowing+=_tem_symbol+";";
           }
     }
   Print("trading_or_folowing:", trading_or_folowing);
//------------------------------------------------------------------

   string TXT_FILE = "Symbols//symbols.txt";
   string JSON_FILE = "Symbols//symbols.json";

// Create the new file and write the content
   int file_handle = FileOpen(JSON_FILE, FILE_WRITE | FILE_ANSI);
   if(file_handle == INVALID_HANDLE)
     {
      Print("Failed to create file: ", JSON_FILE);
      return;
     }


   int size = ArraySize(sorted_symbols_ck);
   for(int i=0;i<size;i++)
     {
      string symbolCk=sorted_symbols_ck[i];
      if(is_same_symbol(trading_or_folowing, symbolCk))
         continue;

      if(is_same_symbol(NOT_TRADE, symbolCk))
         continue;

      if(IsButtonExist(symbolCk) || (checkOnScreen==false))
        {
         int cur_size = ArraySize(arrSymbolCk);
         ArrayResize(arrSymbolCk, cur_size + 1);
         arrSymbolCk[cur_size] = symbolCk;
        }
      else
        {
         //(Bank)
         string tooltip = get_tool_tip_ck(symbolCk);
         if(is_same_symbol(tooltip, "VNINDEX")==false && is_same_symbol(tooltip, GROUP_NGANHANG))
           {
            int cur_size = ArraySize(arrSymbolCk);
            ArrayResize(arrSymbolCk, cur_size + 1);
            arrSymbolCk[cur_size] = symbolCk;
           }
        }
     }
   int cur_size = ArraySize(arrSymbolCk);
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
   FileWrite(file_handle, "[");
   string line = "    [\"" + "HOSE" + "\",\"" + "VNINDEX" + "\"],";
   FileWrite(file_handle, line);


   ResetFile(TXT_FILE);
   AppendToFile(TXT_FILE,strNotice + "\nstring ARR_SYMBOLS_CK[] = {");
   AppendToFile(TXT_FILE, "  \"HOSE_VNINDEX\"");

   string str_line="";
   int count=0;
   cur_size = ArraySize(arrSymbolCk);
   for(int i=0;i<cur_size;i++)
     {
      string symbolCk=arrSymbolCk[i];
      if(is_same_symbol(symbolCk,"VNINDEX"))
         continue;

      // Vị trí của ký tự "_"
      int pos = StringFind(symbolCk, "_");

      // Cắt chuỗi thành hai phần
      string HOS = StringSubstr(symbolCk, 0, pos);
      string SYM = StringSubstr(symbolCk, pos + 1);

      line = "    [\"" + HOS + "\",\"" + SYM + "\"],";
      if(i==cur_size-1)
         line = "    [\"" + HOS + "\",\"" + SYM + "\"] ";

      count+=1;
      str_line+=", \"" + HOS + "_" + SYM + "\"";
      if(i>0 && i%20==0)
        {
         AppendToFile(TXT_FILE, str_line);
         str_line="";
        }

      FileWrite(file_handle, line);
     }
   FileWrite(file_handle, "]");

   FileClose(file_handle);

   if(str_line!="")
      AppendToFile(TXT_FILE, str_line);
   AppendToFile(TXT_FILE, "}; //"+IntegerToString(count));

   Alert(IntegerToString(count) + " symbols đã xuất vào file: " + JSON_FILE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FindFiles(string keyword)
  {
   if(keyword=="")
      return "";

   string symbol_target = "";

   string filename = "";
   long handle = 0;
   int count = 0;

   handle = FileFindFirst("*.*", filename); // Dùng pattern đơn giản
   if(handle != INVALID_HANDLE)
     {
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
//|BtnCandidateJson                                                  |
//+------------------------------------------------------------------+
void ListAllSymbolsCandidate()
  {
   string arrMonthly[];

   int count = 0;
   long handle = 0;
   string filename = "", FILE_TYPE="_MONTHLY.txt";

   string TXT_FILE="Symbols//1600.txt";
   ResetFile(TXT_FILE);

   string TXT_CAND_FILE="Symbols//W1Seq51020_Month100b.txt";
   ResetFile(TXT_CAND_FILE);

   string TXT_BANKS_FILE="Symbols//Banks.txt";
   ResetFile(TXT_BANKS_FILE);

   handle = FileFindFirst("*.*", filename); // Dùng pattern đơn giản
   if(handle != INVALID_HANDLE)
     {
      Print("Danh sách các tệp trong thư mục Files:");
      do
        {
         if(filename != "" && is_same_symbol(filename, FILE_TYPE))
           {
            string symbolCk = filename;
            StringReplace(symbolCk, FILE_TYPE,"");

            int count_ma10_mo, count_hei_mo;
            double PERCENT_LOW, PERCENT_HIG;
            string trend_ma20_mo, trend_ma10_mo, trend_hei_mo, trend_ma5_mo, low_hig_mo;
            GetTrendFromFileCk(symbolCk,PERIOD_MN1,trend_ma20_mo, trend_ma10_mo, count_ma10_mo, trend_hei_mo, count_hei_mo,trend_ma5_mo,low_hig_mo,PERCENT_LOW,PERCENT_HIG,true);

            string trend_ma20_w1, trend_ma10_w1, trend_hei_w1, trend_ma5_w1,low_hig_w1;
            int count_ma10_w1, count_hei_w1;
            double percent_low_w1, percent_hig_w1;
            GetTrendFromFileCk(symbolCk,PERIOD_W1,trend_ma20_w1, trend_ma10_w1, count_ma10_w1, trend_hei_w1, count_hei_w1,trend_ma5_w1,low_hig_w1,percent_low_w1,percent_hig_w1);

            string trend_ma20_h4, trend_ma10_h4, trend_hei_h4, trend_ma5_h4,low_hig_h4;
            int count_ma10_h4, count_hei_h4;
            double percent_low_h4, percent_hig_h4;
            GetTrendFromFileCk(symbolCk,PERIOD_H4,trend_ma20_h4, trend_ma10_h4, count_ma10_h4, trend_hei_h4, count_hei_h4,trend_ma5_h4,low_hig_h4,percent_low_h4,percent_hig_h4);

            string url="https://www.tradingview.com/chart/r46Q5U5a/?interval="+"M"+"&symbol="+symbolCk;
            StringReplace(url,"_",":");

            string tooltip = get_tool_tip_ck(symbolCk);
            if(is_same_symbol(tooltip,GROUP_NGANHANG))
               AppendToFile(TXT_BANKS_FILE,
                            symbolCk
                            +"\tMa10Mo:"+trend_ma10_mo
                            +"\tMa10W1:"+trend_ma10_w1
                            +"\t"+IntegerToString(count_ma10_mo)
                            +"\t(Mo)"+low_hig_mo
                            +"\t(W1)"+low_hig_w1
                            +"\t(H4)"+low_hig_h4
                            +"\t"+tooltip
                            +"\t"+url
                           );


            AppendToFile(TXT_FILE,
                         symbolCk
                         +"\tMa10Mo:"+trend_ma10_mo
                         +"\tMa10W1:"+trend_ma10_w1
                         +"\t"+IntegerToString(count_ma10_mo)
                         +"\t(Mo)"+low_hig_mo
                         +"\t(W1)"+low_hig_w1
                         +"\t(H4)"+low_hig_h4
                         +"\t"+tooltip
                         +"\t"+url
                        );

            bool is_candidate=false;
            if(is_same_symbol(low_hig_w1, STR_SEQ_BUY) && is_same_symbol(low_hig_mo,MORE_THAN_100BIL_VND))
               is_candidate=true;

            if(is_candidate==false)
               continue;

            AppendToFile(TXT_CAND_FILE,
                         symbolCk
                         +"\tMa10Mo:"+trend_ma10_mo
                         +"\tMa10W1:"+trend_ma10_w1
                         +"\t"+IntegerToString(count_ma10_mo)
                         +"\t(Mo)"+low_hig_mo
                         +"\t(W1)"+low_hig_w1
                         +"\t(H4)"+low_hig_h4
                         +"\t"+tooltip
                         +"\t"+url
                        );

            ArrayResize(arrMonthly, ArraySize(arrMonthly) + 1);
            arrMonthly[ArraySize(arrMonthly) - 1] = symbolCk;

            Print(++count, ".", symbolCk);
           }
        }
      while(FileFindNext(handle, filename));

      FileFindClose(handle);
     }

   if(ArraySize(arrMonthly)>0)
      SaveSymbolJson(arrMonthly, false, "//Week Seq Buy && Vol>=100BIL/thang");
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
      if(is_same_symbol(lable,symbolCk) || is_same_symbol(lable," "+symbolCk) || is_same_symbol(lable,"_"+symbolCk) || lable==symbolCk)
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

   if(PERIOD_XX== PERIOD_M30)
      return "m30";

   if(PERIOD_XX== PERIOD_H4)
      return "H4";

   if(PERIOD_XX== PERIOD_D1)
      return "D1";

   if(PERIOD_XX== PERIOD_W1)
      return "W1";

   if(PERIOD_XX== PERIOD_MN1)
      return "Mo";

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
void CreateMessagesBtn(string FILE_MSG_LIST_)
  {
   int btn_width = 180;
   int START = 20;
   bool is_screen_mode_hd=GetGlobalVariable(BtnScreenHD)==AUTO_TRADE_ONN;
   if(is_screen_mode_hd)
      START = 2550;

   int COL_1=START+(btn_width+10)*0;
   int COL_2=START+(btn_width+10)*1;
   int COL_3=START+(btn_width+10)*2;
   int y_position=880;

   string FILE_NAME_MSG_LIST=FILE_MSG_LIST_R1C1;
   int x_position=COL_1;
   string prifix="W1";
   color clrBgColor = clrWhite;

   if(FILE_MSG_LIST_==FILE_MSG_LIST_R1C2)
     {
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_R1C2;
      x_position=COL_2;
      prifix="H4";
      clrBgColor = clrActiveBtn;
     }

   if(FILE_MSG_LIST_==FILE_MSG_LIST_R1C3)
     {
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_R1C3;
      x_position=COL_3;
      prifix="Exit";
      clrBgColor = clrMistyRose;
     }
//--------------------------------------------------------
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
      //createButton(BtnClearMessage,  "Clear", x_position+60*0,y_position-20,50,16,clrBlack,clrWhite,6);
      //createButton(BtnFilter_+prifix,"Filter",x_position+60*1,y_position-20,50,16,clrBlack,clrWhite,6);
     }

   string total_comments="";
   int size_msg =ArraySize(messageArray);
   string sorted_symbols_ck[];
   SortSymbols(sorted_symbols_ck);

   int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);
   string clicked_SymbolCk="";
   if(clicked_ck_index>=0 && clicked_ck_index<ArraySize(sorted_symbols_ck))
      clicked_SymbolCk=sorted_symbols_ck[clicked_ck_index];

   for(int index = 0; index < size_msg; index++)
     {
      string lable=messageArray[index];
      string symbolCk = get_symbol_ck_from_label(lable, true);

      color clrBackground=clrHoneydew;
      if(FILE_MSG_LIST_==FILE_MSG_LIST_R1C3)
        {
         clrBackground=clrBgColor;
         if(GetGlobalVariable(BtnTrading_+symbolCk)==OPTION_FOLOWING)
            clrBackground=clrMistyRose;

         if(is_same_symbol(symbolCk,"VNINDEX"))
            clrBackground=clrRed;
        }

      if(is_same_symbol(lable, clicked_SymbolCk))
         clrBackground=clrYellow;

      if(FILE_MSG_LIST_==FILE_MSG_LIST_R1C3 && is_same_symbol(lable, "VNINDEX"))
         clrBackground=clrRed;

      StringReplace(lable,"HOSE_","");
      StringReplace(lable,"HNX_","");
      StringReplace(lable,"UPCOM_","");
      StringReplace(lable,"ICMARKETS_","");

      createButton(BtnMsg_+FILE_MSG_LIST_+append1Zero(index)+"_"+symbolCk,lable,x_position,y_position+index*18,btn_width,16,clrBlack,clrBackground,6);//x_position==COL_1?200:250
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
   string                  count_heiken="",
   string percent = ""
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
      create_trend_line(name_new+"+.",time_mid,high,time_mid,high,clr_fill,STYLE_SOLID,5);
   if(low<MathMin(open,close))
      create_trend_line(name_new+"-.",time_mid, low,time_mid, low,clr_fill,STYLE_SOLID,5);

   if(percent!="")
     {
      if(open<close && low<open)
        {
         create_label_simple(name_new+"%","  "+percent,high,clrBlue,time_from,6);
         ObjectSetInteger(0,name_new+"%",OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
        }
      if(open>close && high>open)
        {
         create_label_simple(name_new+"%","  "+percent,low,clrRed,time_from,6);
         ObjectSetInteger(0,name_new+"%",OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
        }
     }

   if(count_heiken!="")
      create_label_simple(name_new+".count",(string)(count_heiken),(open+close)/2,clr_fill,time_mid-TIME_OF_ONE_H4_CANDLE*3);
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
//| Tính phần trăm thay đổi giữa hai mức giá A và B                |
//| Nếu B > A => tăng, nếu B < A => giảm                           |
//| Kết quả trả về dạng "(+x.x%)" hoặc "(-x.x%)"                |
//+------------------------------------------------------------------+
string CalcPercentChange(double price_cur, double price_ref)
  {
   if(price_cur == 0.0)
      return "(N/A)"; // Tránh chia cho 0

   double change = ((price_ref - price_cur) / price_cur) * 100.0;
   string sign = (change >= 0.0) ? "+" : "-";
   double abs_change = MathAbs(change);

   return StringFormat("(%s%.1f%%)", sign, abs_change);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CalcPercentOff(double price_cur, double price_ref)
  {
   if(price_ref == 0.0)
      return "(N/A)"; // Tránh chia cho 0

   double change = (price_cur / price_ref) * 100.0;
   string sign = "";//(change >= 0.0) ? "+" : "-";
   double abs_change = MathAbs(change);

   return StringFormat("(%s%.1f%%)", sign, abs_change);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcProfitCandle1(double vol1, double price1, double vol2, double price2)
  {
   return (vol1 * price1)-(vol2 * price2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FormatVndWithCommas(double number)
  {
   string str = IntegerToString((int)number); // Chuyển thành chuỗi số nguyên
   int len = StringLen(str);
   string formatted = "";

   for(int i = 0; i < len; i++)
     {
      if(i>0 && len>3 && (len - i)%3 == 0)
         formatted += ","; // Thêm dấu ',' sau mỗi 3 số

      formatted += StringSubstr(str, i, 1);
     }
   return formatted;
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
double get_arr_candles(string symbol,CandleData &candleArray[],string &open_times[],string &opens[],string &closes[],string &lows[],string &highs[],string &volumes[])
  {
   bool is_calc_ma10=true;
   bool is_calc_seq102050=true;
   bool check_seq=false;

   int length= ArraySize(opens);
   if(length<0)
      return 0;

   ArrayResize(candleArray,length);
   for(int index=length-1; index>=0; index--)
     {
      datetime pre_HaTime=BinanceDateTimeToVNTime(symbol,open_times,index);
      double pre_HaOpen=BinanceStringToDouble(opens,index);
      double pre_HaHigh=BinanceStringToDouble(highs,index);
      double pre_HaLow=BinanceStringToDouble(lows,index);
      double pre_HaClose=BinanceStringToDouble(closes,index);
      double pre_Volume=BinanceStringToDouble(volumes,index);
      string pre_candle_trend=pre_HaClose>pre_HaOpen ? TREND_BUY : TREND_SEL;

      CandleData candle(pre_HaTime,pre_HaOpen,pre_HaHigh,pre_HaLow,pre_HaClose,pre_candle_trend,0,0,"",0,"","","",0,"",0,"","",0,0,false,false,0,0,pre_Volume);
      candleArray[index]=candle;
     }

   double cur_close_0 = BinanceStringToDouble(closes,0);
   return cur_close_0;
  }
// Hàm tính body volume cho một cây nến
//double CalculateBodyVolume(double open, double close, double low, double high, double volume)
//  {
//   double total_range = high - low;
//   if(total_range <= 0.000001 || volume <= 0)  // tránh chia cho 0
//      return 0;
//
//   double body_range = MathAbs(close - open);
//   double body_volume = (body_range / total_range) * volume;
//
//   return body_volume;
//  }

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
      //pre_Volume=CalculateBodyVolume(pre_HaOpen,pre_HaClose,pre_HaLow,pre_HaHigh,pre_Volume);

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
      //volume=CalculateBodyVolume(open,close,low,high,volume);

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
double cal_MA(double &closePrices[], int ma_index, int candle_no = 0)
  {
   int count = 0;
   double ma = 0.0;
   int length = ArraySize(closePrices);

   for(int i = candle_no; i < candle_no + ma_index; i++)
     {
      if(i < length)
        {
         count++;
         ma += closePrices[i];
        }
     }

   if(count == 0)
      return 0.0;

   return ma / count;
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
string getBracesContent(string str_input)
  {
   int start_pos = StringFind(str_input, "{"); // Tìm vị trí ký tự '{'
   int end_pos = StringFind(str_input, "}");   // Tìm vị trí ký tự '}'

// Kiểm tra nếu tìm thấy cả '{' và '}'
   if(start_pos != -1 && end_pos != -1 && end_pos > start_pos)
     {
      return StringSubstr(str_input, start_pos+1, end_pos-start_pos-1);
     }
   return ""; // Trả về chuỗi rỗng nếu không tìm thấy
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetTrendFromFileCk(string symbolCk,ENUM_TIMEFRAMES TF,
                        string &trend_ma20_mo,
                        string &trend_ma10_monthly, int &count_ma10_monthly,
                        string &trend_hei_monthly, int &count_hei_monthly,
                        string &trend_ma5_monthly, string &low_hig, double &PERCENT_LOW, double &PERCENT_HIG
                        , bool alwaysCheckVolume = false)
  {
   low_hig="";

   string ck_tf="4HOURS";
   if(TF==PERIOD_M30)
      ck_tf="MINUTE30";
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

      low_hig="";
      return;
     }

   CandleData candleArray[];
   double cur_price=get_arr_heiken_binance(symbolCk,candleArray,open_times,opens,closes,lows,highs,volumes);
   if(ArraySize(candleArray)<10)
      cur_price = get_arr_candles(symbolCk,candleArray,open_times,opens,closes,lows,highs,volumes);

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
      // string percent_drop = CalcPercentChange(cur_price, real_lowest);//((cur_price - real_lowest) / cur_price)  * 100.0; // Tính % giảm giá từ giá hiện tại xuống real_lowest
      // string percent_rise = CalcPercentChange(cur_price, real_higest);//((real_higest - cur_price) / cur_price)  * 100.0; // Tính % tăng giá từ giá hiện tại lên real_higest
      // string percent_up = CalcPercentChange(real_lowest, cur_price); //Tính % tăng giá từ đáy lên giá hiện tại.

      double percent_rise = ((real_higest - cur_price) / cur_price)  * 100.0; //Tính % tăng giá từ giá hiện tại lên real_higest
      double percent_up   = ((cur_price - real_lowest) / real_lowest)* 100.0; //Tính % tăng giá từ đáy lên giá hiện tại.
      double fibo_0_382   = real_lowest + (real_higest - real_lowest)* 0.382;

      PERCENT_LOW=NormalizeDouble(percent_up,1);
      PERCENT_HIG=NormalizeDouble(percent_rise,1);

      low_hig = "(" +AppendSpaces(DoubleToString(PERCENT_LOW,1),5,false)+"%~" +AppendSpaces(DoubleToString(PERCENT_HIG,1),5,false)+"%)";

      if(candleArray[0].close<fibo_0_382)
         low_hig+=" "+ENTRY_FIBO_382;
      if(candleArray[0].close<candleArray[0].ma10)
         low_hig+=" "+ENTRY_MA10;


      if(candleArray[0].ma05>0 && candleArray[0].ma10>0 && candleArray[0].ma20>0)
        {
         if(candleArray[0].ma05>candleArray[0].ma10 && candleArray[0].ma10>candleArray[0].ma20)
            low_hig+=" " + STR_SEQ_BUY; //SeqBuy

         if(candleArray[0].ma05>candleArray[1].ma05 && candleArray[0].ma10>candleArray[1].ma10 && candleArray[0].ma20>candleArray[1].ma20)
            low_hig+=" " + STR_SEQ_BUY;

         if(is_same_symbol(candleArray[0].trend_heiken, TREND_BUY)
            && candleArray[0].close>candleArray[0].ma10
            && candleArray[0].ma05>candleArray[0].ma10 && candleArray[0].ma05>candleArray[0].ma20)
            low_hig+=" " + STR_SEQ_BUY;


         if(candleArray[0].ma05<candleArray[0].ma10 && candleArray[0].ma10<candleArray[0].ma20)
            low_hig+=" " + STR_SEQ_SEL; //SeqSel;

         if(candleArray[0].ma05<candleArray[1].ma05 && candleArray[0].ma10<candleArray[1].ma10 && candleArray[0].ma20<candleArray[1].ma20)
            low_hig+=" " + STR_SEQ_SEL;


         double ma50=candleArray[0].ma50;
         if((BinanceStringToDouble(lows,0)<ma50 && ma50<BinanceStringToDouble(highs,0)) ||
            (BinanceStringToDouble(lows,1)<ma50 && ma50<BinanceStringToDouble(highs,1)) ||
            (BinanceStringToDouble(lows,2)<ma50 && ma50<BinanceStringToDouble(highs,2)))
            low_hig+=" " + MASK_TOUCH_MA50;
        }


      double closeArray[];
      datetime timeFrArr[];
      int size = ArraySize(candleArray);
      ArrayResize(closeArray, size);
      ArrayResize(timeFrArr, size);

      for(int i = 0; i < size-10; i++)
        {
         closeArray[i] = candleArray[i].close;
         timeFrArr[i] = candleArray[i].time;
        }

      low_hig+=" {"+DrawAndCountHistogram("", closeArray, timeFrArr, open_times, false) + "}";
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
      bool FilterXxxBVnd=//GetGlobalVariable(BtnFilter30BVnd)==FILTER_ON?true:false||
         //GetGlobalVariable(BtnFilter100BVnd)==FILTER_ON?true:false||
         GetGlobalVariable(BtnFilter500BVnd)==FILTER_ON?true:false||
         GetGlobalVariable(BtnFilter1000BVnd)==FILTER_ON?true:false||
         GetGlobalVariable(BtnFilter5000BVnd)==FILTER_ON?true:false;

      if(alwaysCheckVolume || FilterXxxBVnd)
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
            low_hig+= MORE_THAN_100BIL_VND;
         if(avg_volume>=VOL_500BVND)
            low_hig+= MORE_THAN_500BIL_VND;
         if(avg_volume>=VOL_1000BVND)
            low_hig+= MORE_THAN_1000BIL_VND;
         if(avg_volume>=VOL_5000BVND)
            low_hig+= MORE_THAN_5000BIL_VND;

         if(alwaysCheckVolume)
            low_hig+="\t"+DoubleToString(avg_volume,3)+"";
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestReadAllDataFromFile(string symbolCk,ENUM_TIMEFRAMES TF, int chart_index)
  {
   string ck_tf="4HOURS";
   if(TF==PERIOD_M30)
      ck_tf="MINUTE30";
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

   datetime IME_OF_ONE_CANDLE = GLOBAL_TIME_OF_ONE_CANDLE;
   if(TF==PERIOD_M30)
      IME_OF_ONE_CANDLE = (datetime)(TIME_OF_ONE_H4_CANDLE*3.8);

   int lineIndex=1;
   string scale_open_times[];
   int BarsCount=ArraySize(open_times);
   datetime current_time = TimeCurrent()+TIME_OF_ONE_W1_CANDLE*10;
   for(int i = 0; i < BarsCount; i++)
     {
      datetime scale_time = current_time-(i+1)*(IME_OF_ONE_CANDLE);

      ArrayResize(scale_open_times, lineIndex);
      scale_open_times[lineIndex - 1] = (string)scale_time;
      lineIndex+=1;
     }

   if(ArraySize(open_times)>1)
      if(TF==PERIOD_M30)
         DrawChartMinus30(symbolCk,TF,scale_open_times,opens,closes,lows,highs,volumes,chart_index,IME_OF_ONE_CANDLE);
      else
         DrawChartAndSetGlobal(symbolCk,TF,scale_open_times,opens,closes,lows,highs,volumes,open_times,chart_index);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTrendSeqM30(string symbolCk, bool &is_exit_trade_by_m30)
  {
   string ck_tf="MINUTE30";
   string filePath = symbolCk+"_"+ck_tf+".txt";

// Mảng lưu trữ dữ liệu
   string symbols[];
   string open_times[], opens[], highs[], lows[], closes[], volumes[];

// Gọi hàm để đọc dữ liệu
   ReadAllDataFromFile(filePath, open_times, symbols, opens, highs, lows, closes, volumes);
   if(ArraySize(open_times)>1)
     {
      int size_d1 = ArraySize(closes)-9;


      int size = ArraySize(closes);
      double opensArray[], highsArray[], lowsArray[], closesArray[], volumeArray[];

      ArrayResize(opensArray, size);
      ArrayResize(highsArray, size);
      ArrayResize(lowsArray, size);
      ArrayResize(closesArray, size);
      ArrayResize(volumeArray, size);

      // Chuyển đổi dữ liệu chuỗi sang dạng số
      for(int i = 0; i < size; i++)
        {
         opensArray[i] = BinanceStringToDouble(opens, i);
         highsArray[i] = BinanceStringToDouble(highs, i);
         lowsArray[i] = BinanceStringToDouble(lows, i);
         closesArray[i] = BinanceStringToDouble(closes, i);
         volumeArray[i] = BinanceStringToDouble(volumes, i);
        }

      int ma_periods[] = {7, 13, 27, 54, 189};
      double ma13 = cal_MA(closesArray, 13, 0);
      double ma27 = cal_MA(closesArray, 27, 0);
      double ma54 = cal_MA(closesArray, 54, 0);
      double ma189= cal_MA(closesArray,189, 0);

      is_exit_trade_by_m30=false;
      if((ma27<ma54) || (ma27<ma189))
         is_exit_trade_by_m30=true;

      if(ma13>0 && ma27>0 && ma54>0 && ma189>0)
        {
         if(ma13>ma27 && ma27>ma54 && ma27>ma189)
            return STR_SEQ_BUY;

         if(ma13<ma27 && ma27<ma54 && ma27<ma189)
            return STR_SEQ_SEL;
        }
     }

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DrawChartMinus30(string symbolUsdt, ENUM_TIMEFRAMES TF
                        ,string &scale_open_times[],string &opens[],string &closes[],string &lows[],string &highs[],string &volumes[], int chart_idx, datetime TIME_OF_ONE_CANDLE)
  {
   string trend_found="";
   double cur_close_0 = BinanceStringToDouble(closes,0);

   int _digits=cur_close_0>1000?1:cur_close_0>100?3:5;

   int size_d1 = ArraySize(closes)-9; //(int)MathMin(ArraySize(closes)-9, 185);
//--------------------------------------------------------------------------------------------------------
   string prefix=STR_DRAW_CHART+get_time_frame_name(TF);
   DeleteAllObjectsWithPrefix(prefix);

   if(GetGlobalVariable(BtnFollowing_+symbolUsdt)==OPTION_FOLOWING)
      ObjectSetInteger(0,BtnFollowing_,OBJPROP_BGCOLOR,clrActiveBtn);
   else
      ObjectSetInteger(0,BtnFollowing_,OBJPROP_BGCOLOR,clrLightGray);

//--------------------------------------------------------------------------------------------------------
   double real_lowest=DBL_MAX,real_higest=0.0;

   for(int i = 0; i < size_d1; i++)
     {
      double low= BinanceStringToDouble(lows,i);
      double hig=BinanceStringToDouble(highs,i);
      if((i==0) || (real_lowest==0) || (real_lowest>low))
         if(low>0)
            real_lowest=low;
      if((i==0) || (real_higest==0) || (real_higest<hig))
         real_higest=hig;
     }
//--------------------------------------------------------------------------------------------------------
   int chart_width=(int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh=(int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))-25;

   int __sub;
   double __price1,__price2;
   datetime __time1000, __time2000;
   int x1=1190, x2=2090;
   bool is_screen_mode_hd=GetGlobalVariable(BtnScreenHD)==AUTO_TRADE_ONN;
   bool is_screen_mode_27=GetGlobalVariable(BtnScreen27)==AUTO_TRADE_ONN;
   bool is_screen_mode_34=GetGlobalVariable(BtnScreen34)==AUTO_TRADE_ONN;

   if(is_screen_mode_hd)
     {
      x1-=820;
      x2-=820;
     }
   if(is_screen_mode_27)
     {
      x1-=250;
      x2-=220;
     }
   ChartXYToTimePrice(0,x1,75,__sub, __time1000,__price1);
   ChartXYToTimePrice(0,x2,80,__sub, __time2000,__price2);
   double __priceHig5=MathAbs(__price1-__price2);

   double btc_price_high, btc_price_low;
   datetime _time;
   int _sub_windows;
   ChartXYToTimePrice(0,10,70,_sub_windows,_time,btc_price_high);
   ChartXYToTimePrice(0,10,chart_heigh-70,_sub_windows,_time,btc_price_low);
   double haft_chart = (btc_price_high + btc_price_low)/2.0;

   if(TF==PERIOD_W1 || TF==PERIOD_MN1)
      btc_price_low=haft_chart+__priceHig5*2;

   if(TF==PERIOD_M30)
      btc_price_high=haft_chart-__priceHig5*15;

   double btc_mid = (btc_price_high + btc_price_low) /2.0;

   double ada_price_high = real_higest; // Giá cao nhất hiện tại của ADA
   double ada_price_low = real_lowest;  // Giá thấp nhất hiện tại của ADA
   double ada_mid = (ada_price_high + ada_price_low) / 2.0;

// 2. Tính hệ số chuẩn hóa
   double btc_range = btc_price_high - btc_price_low;
   double ada_range = ada_price_high - ada_price_low;
   double normalization_factor = btc_range/ada_range;
   double offset = 0;

   datetime shift=TimeCurrent()-__time1000; // add_time*(NUM_CANDLE_DRAW+11);
   if(chart_idx>0)
      shift=TimeCurrent()-__time2000; // add_time*6;
   datetime add_time=TIME_OF_ONE_CANDLE;//(datetime)(candleArray[0].time-candleArray[1].time);

   double lowest=DBL_MAX,higest=0.0;


   datetime tool_tip_time=BinanceDateTimeToVNTime(symbolUsdt,scale_open_times,MathMin(size_d1-50,125))-TIME_OF_ONE_CANDLE-shift;

   int size = ArraySize(closes);
   double opensArray[], highsArray[], lowsArray[], closesArray[], volumeArray[];
   datetime timesArray[];

   ArrayResize(opensArray, size);
   ArrayResize(highsArray, size);
   ArrayResize(lowsArray, size);
   ArrayResize(closesArray, size);
   ArrayResize(volumeArray, size);
   ArrayResize(timesArray, size);

// Chuyển đổi dữ liệu chuỗi sang dạng số
   for(int i = 0; i < size; i++)
     {
      opensArray[i] = BinanceStringToDouble(opens, i);
      highsArray[i] = BinanceStringToDouble(highs, i);
      lowsArray[i] = BinanceStringToDouble(lows, i);
      closesArray[i] = BinanceStringToDouble(closes, i);
      volumeArray[i] = BinanceStringToDouble(volumes, i);
      timesArray[i] = BinanceDateTimeToVNTime(symbolUsdt, scale_open_times, i);
     }

//Ketu Mahadasha (7 năm)
//Moon cycle gần 13 tháng
//27 Nakshatra
//54 : 2 vòng Nakshatra (2×27)
//189 : 2 vòng Nakshatra (7×27)

//Sàn HOSE (TP.HCM):
//Giờ giao dịch: 9:00 - 11:30 và 13:00 - 14:45
//MA (số kỳ) | Số nến | Tương đương ngày giao dịch
//MA 7 | 7 nến | ~ 0.875 ngày
//MA 13 | 13 nến | ~ 1.625 ngày
//MA 27 | 27 nến | ~ 3.375 ngày
//MA 54 | 54 nến | ~ 6.75 ngày
//MA 189 | 189 nến | ~ 23.625 ngày
   int ma_periods[] = {7, 13, 27, 54, 189};
   int ma_size = ArraySize(ma_periods);
   double maArrays[10][300]; // giả sử 300 là size đủ lớn
   for(int j = 0; j < ma_size; j++)
     {
      for(int i = 0; i < size; i++)
         maArrays[j][i] = (i < size - ma_periods[j] + 1) ? cal_MA(closesArray, ma_periods[j], i) : 0;
     }

// Vẽ trendline và gán nhãn
   for(int i = 0; i < size_d1; i++)
     {
      double price_factors[5][2];
      for(int j = 0; j < 5; j++)
        {
         price_factors[j][0] = (maArrays[j][i]   - ada_mid) * normalization_factor + btc_mid + offset;
         price_factors[j][1] = (maArrays[j][i+1] - ada_mid) * normalization_factor + btc_mid + offset;
        }

      double open  = (opensArray[i]  - ada_mid) * normalization_factor + btc_mid + offset;
      double close = (closesArray[i] - ada_mid) * normalization_factor + btc_mid + offset;
      double low   = (lowsArray[i]   - ada_mid) * normalization_factor + btc_mid + offset;
      double high  = (highsArray[i]  - ada_mid) * normalization_factor + btc_mid + offset;
      if(lowest > low)
         lowest = low;
      if(higest < high)
         higest = high;


      datetime t0 = (i == 0 ? timesArray[i] + TIME_OF_ONE_CANDLE : timesArray[i]) - shift;
      datetime t1 = timesArray[i + 1] - shift;

      // Ma.189
      if(i < size_d1-ma_periods[4] && price_factors[4][0] > 0 && price_factors[4][1] > 0)
        {
         create_trend_line(prefix+"Ma"+append1Zero(ma_periods[4])+"~23.63 ngày"+"_"+appendZero100(i+1)+""+appendZero100(i), t1, price_factors[4][1], t0, price_factors[4][0],
                           maArrays[1][i] > maArrays[4][i] ? clrActiveBtn : clrMistyRose, STYLE_SOLID, 15);
         if(i < size_d1-ma_periods[4]-1)
            create_label_simple("Ma"+append1Zero(ma_periods[4])+"~23.63 ngày", "Ma"+append1Zero(ma_periods[4])+"~23.63 ngày", price_factors[4][0]+__priceHig5, clrRed, t1);
        }

      // Ma.54
      if(i < size_d1-ma_periods[3] && price_factors[3][0] > 0 && price_factors[3][1] > 0)
        {
         create_trend_line(prefix+"Ma"+append1Zero(ma_periods[3])+"~6.75 ngày"+"_"+appendZero100(i+1)+""+appendZero100(i), t1, price_factors[3][1], t0, price_factors[3][0], clrGray, STYLE_SOLID, 7);
         if(i < size_d1-ma_periods[3]-41)
            create_label_simple("Ma"+append1Zero(ma_periods[3])+"~6.75 ngày", "Ma"+append1Zero(ma_periods[3])+"~6.75 ngày", price_factors[3][0]+__priceHig5, clrBlack, t1);
        }

      // Ma.27
      if(i < size_d1-ma_periods[2]-10 && price_factors[2][0] > 0 && price_factors[2][1] > 0)
        {
         create_trend_line(prefix+"Ma"+append1Zero(ma_periods[2])+"~3.38 ngày"+"_"+appendZero100(i+1)+""+appendZero100(i), t1, price_factors[2][1], t0, price_factors[2][0], clrBlue, STYLE_SOLID, 5);
         if(i < size_d1-ma_periods[2]-35)
            create_label_simple("Ma"+append1Zero(ma_periods[2])+"~3.38 ngày", "Ma"+append1Zero(ma_periods[2])+"~3.38 ngày", price_factors[2][0]+__priceHig5, clrBlue, t1);
        }

      // Ma.13
      if(i < size_d1-ma_periods[1]-10 && price_factors[1][0] > 0 && price_factors[1][1] > 0)
        {
         create_trend_line(prefix+"Ma"+append1Zero(ma_periods[1])+"~1.63 ngày"+"_"+appendZero100(i+1)+""+appendZero100(i), t1, price_factors[1][1], t0, price_factors[1][0], clrRed,  STYLE_SOLID, 3);
         if(i < size_d1-ma_periods[1]-21)
            create_label_simple("Ma"+append1Zero(ma_periods[1])+"~1.63 ngày", "Ma"+append1Zero(ma_periods[1])+"~1.63 ngày", price_factors[1][0]+__priceHig5, clrRed, t1);
        }

      // Ma.07
      if(i < size_d1-ma_periods[0] && price_factors[0][0] > 0 && price_factors[0][1] > 0)
        {
         create_trend_line(prefix+"Ma"+append1Zero(ma_periods[0])+"~0.88 ngày"+"_"+appendZero100(i+1)+appendZero100(i), t1, price_factors[0][1], t0, price_factors[0][0], clrBlack,STYLE_SOLID, 1);
         if(i == size_d1-ma_periods[0]-1)
            create_label_simple("Ma"+append1Zero(ma_periods[0])+"~0.88 ngày", "Ma"+append1Zero(ma_periods[0])+"~0.88 ngày", price_factors[0][0]+__priceHig5, clrBlack, t1);
        }

      if(i == 0)
        {
         //{7, 13, 27, 54, 189};
         datetime lbl_time = timesArray[0] + 3 * TIME_OF_ONE_CANDLE - shift;
         for(int j = ma_size-1; j >= 4; j--)
           {
            if(maArrays[j][0] > 0)
              {
               double percent = (MathAbs(cur_close_0 - maArrays[j][0]) / cur_close_0) * 100.0;
               if(cur_close_0 > maArrays[j][0])
                  percent = -percent;
               double y = price_factors[j][0];
               string labelName = prefix + "Ma" + append1Zero(ma_periods[j]);
               create_label_simple(labelName, FormatVndWithCommas(maArrays[j][0]) + " (" + DoubleToString(percent, 1) + "%)", y, clrBlack, lbl_time);
              }
           }

        }
     }

   double cur_price= cur_close_0;
   double cur_mid=(real_higest-real_lowest)/2;

   double fibo_0_100 = higest - (higest - lowest) * 0.100;
   double fibo_0_118 = higest - (higest - lowest) * 0.118;
   double fibo_0_236 = higest - (higest - lowest) * 0.236;
   double fibo_0_382 = higest - (higest - lowest) * 0.382;
   double fibo_0_500 = higest - (higest - lowest) * 0.500;
   double fibo_0_618 = higest - (higest - lowest) * 0.618;
   double fibo_0_786 = higest - (higest - lowest) * 0.786;
   double fibo_0_886 = higest - (higest - lowest) * 0.886;
   double fibo_1_236 = higest - (higest - lowest) * 1.236;
   double fibo_1_236_= higest + (higest - lowest) * 0.236;

   double fibo_real_0_100 = real_higest - (real_higest - real_lowest) * 0.100;
   double fibo_real_0_118 = real_higest - (real_higest - real_lowest) * 0.118;
   double fibo_real_0_236 = real_higest - (real_higest - real_lowest) * 0.236;
   double fibo_real_0_382 = real_higest - (real_higest - real_lowest) * 0.382;
   double fibo_real_0_500 = real_higest - (real_higest - real_lowest) * 0.500;
   double fibo_real_0_618 = real_higest - (real_higest - real_lowest) * 0.618;
   double fibo_real_0_786 = real_higest - (real_higest - real_lowest) * 0.786;
   double fibo_real_0_886 = real_higest - (real_higest - real_lowest) * 0.886;
   double fibo_real_1_236 = real_higest - (real_higest - real_lowest) * 1.236;
   double fibo_real_1_236_= real_higest + (real_higest - real_lowest) * 0.236;

   if(maArrays[1][0]>0 && maArrays[2][0]>0 && maArrays[3][0]>0 && maArrays[4][0]>0)
     {
      if(maArrays[1][0]>maArrays[2][0] && maArrays[2][0]>maArrays[3][0] && maArrays[3][0]>maArrays[4][0])
         create_label_simple(prefix+"Seq"," SEQ.Buy" //+(string)ma_periods[1]+"."+(string)ma_periods[2]+"."+(string)ma_periods[3]+"."+(string)ma_periods[4]+
                             , fibo_0_500+__priceHig5*2,clrBlue,timesArray[20]-shift,12);

      if(maArrays[1][0]<maArrays[2][0] && maArrays[2][0]<maArrays[3][0] && maArrays[3][0]<maArrays[4][0])
         create_label_simple(prefix+"Seq"," SEQ.Sell" //+(string)ma_periods[1]+"."+(string)ma_periods[2]+"."+(string)ma_periods[3]+"."+(string)ma_periods[4]
                             ,fibo_0_500+__priceHig5*2,clrRed, timesArray[20]-shift,12);
     }

   double sai_so=lowest*0.025;
   double price=(cur_close_0-ada_mid)*normalization_factor + btc_mid+offset;

   if(is_same_symbol(symbolUsdt,"_"))
     {
      bool is_vn30=is_same_symbol(VN30,symbolUsdt);

      int _sub_windows;
      datetime _time;
      double _price;

      if(ChartXYToTimePrice(0,10,chart_heigh-35,_sub_windows,_time,_price))
         create_label_simple(prefix+"TOOLTIP",get_time_frame_name(TF)+"    "+(is_vn30?"(VN30) ":"")+get_tool_tip_ck(symbolUsdt),_price,clrBlack,tool_tip_time);
     }

   datetime start_time=BinanceDateTimeToVNTime(symbolUsdt,scale_open_times,size_d1-60)-shift;
   datetime end_time=BinanceDateTimeToVNTime(symbolUsdt,scale_open_times,0)+add_time -shift;
   datetime draw_fibo_time = (datetime)(start_time+add_time*48);

   create_trend_line(prefix+"HIGEST",    draw_fibo_time,higest,    end_time,higest,    clrRed,  STYLE_SOLID,1,false,false);
   create_trend_line(prefix+"LOWEST",    draw_fibo_time,lowest,    end_time,lowest,    clrBlue, STYLE_SOLID,1,false,false);
   create_trend_line(prefix+"fibo_0_118",draw_fibo_time,fibo_0_118,end_time,fibo_0_118,clrRed,  STYLE_DOT,  1,false,false);
   create_trend_line(prefix+"fibo_0_236",draw_fibo_time,fibo_0_236,end_time,fibo_0_236,clrRed,  STYLE_DOT,  1,false,false);
   create_trend_line(prefix+"fibo_0_382",draw_fibo_time,fibo_0_382,end_time,fibo_0_382,clrBlack,STYLE_DOT,  1,false,false);
   create_trend_line(prefix+"fibo_0_500",draw_fibo_time,fibo_0_500,end_time,fibo_0_500,clrBlack,STYLE_SOLID,1,false,false);
   create_trend_line(prefix+"fibo_0_618",draw_fibo_time,fibo_0_618,end_time,fibo_0_618,clrBlack,STYLE_DOT,  1,false,false);
   create_trend_line(prefix+"fibo_0_786",draw_fibo_time,fibo_0_786,end_time,fibo_0_786,clrBlue, STYLE_SOLID,1,false,false);
   create_trend_line(prefix+"fibo_0_886",draw_fibo_time,fibo_0_886,end_time,fibo_0_886,clrBlue, STYLE_SOLID,1,false,false);

   create_label_simple(prefix+"0.118","0.118    " + FormatVndWithCommas(fibo_real_0_118) +" "+ CalcPercentChange(real_higest,fibo_real_0_118),fibo_0_118,clrBlack,start_time);
   create_label_simple(prefix+"0.236","0.236    " + FormatVndWithCommas(fibo_real_0_236) +" "+ CalcPercentChange(real_higest,fibo_real_0_236),fibo_0_236,clrBlack,start_time);
   create_label_simple(prefix+"0.382","0.382    " + FormatVndWithCommas(fibo_real_0_382) +" "+ CalcPercentChange(real_higest,fibo_real_0_382),fibo_0_382,clrBlack,start_time);
   create_label_simple(prefix+"0.500","0.500    " + FormatVndWithCommas(fibo_real_0_500) +" "+ CalcPercentChange(real_higest,fibo_real_0_500),fibo_0_500,clrBlack,start_time);
   create_label_simple(prefix+"0.618","0.618    " + FormatVndWithCommas(fibo_real_0_618) +" "+ CalcPercentChange(real_higest,fibo_real_0_618),fibo_0_618,clrBlack,start_time);
   create_label_simple(prefix+"0.786","0.786    " + FormatVndWithCommas(fibo_real_0_786) +" "+ CalcPercentChange(real_higest,fibo_real_0_786),fibo_0_786,clrBlack,start_time);
   create_label_simple(prefix+"0.886","0.886    " + FormatVndWithCommas(fibo_real_0_886) +" "+ CalcPercentChange(real_higest,fibo_real_0_886),fibo_0_886,clrBlack,start_time);

   if(TF!=PERIOD_M30)
     {
      create_trend_line(prefix+"fibo_1_23+",start_time+add_time*3,fibo_1_236, end_time,fibo_1_236, clrGray,STYLE_DOT,1,false,false);
      create_label_simple(prefix+"1.236","1.236    " + DoubleToString(CalculateRealValue(fibo_1_236,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_1_236+sai_so,clrBlack,start_time);
     }

   create_label_simple(prefix+"Hig%",
                       "Hig: " +FormatVndWithCommas(real_higest) + " " + CalcPercentChange(real_higest, cur_price)+" -"+FormatVndWithCommas(real_higest-cur_price)
                       ,higest,clrRed,start_time);
   create_label_simple(prefix+"Hig%_",
                       "  "+CalcPercentChange(cur_price, real_higest)
                       ,higest,clrBlue,end_time);


   create_label_simple(prefix+"Low%",
                       "Low: "+FormatVndWithCommas(real_lowest) + " " + CalcPercentChange(real_lowest, cur_price)+" +"+FormatVndWithCommas(cur_price-real_lowest)
                       ,lowest,clrBlue,start_time);
   create_label_simple(prefix+"Low%_",
                       "  "+CalcPercentChange(cur_price, real_lowest)
                       ,lowest,clrRed,end_time);

   create_trend_line(prefix+"_close_0",draw_fibo_time,price,end_time+add_time,price,clrBlue,STYLE_DOT,1,false,false);
   create_label_simple(prefix+"cur_close_0","    "+FormatVndWithCommas(cur_close_0) + " "+ CalcPercentChange(real_lowest, cur_price)
                       ,price,clrBlue,end_time+add_time);

   return trend_found;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortSymbols(string &sorted_symbols[])
  {
// Separate into modifiable groups
   string hose[], hnx[], upcom[], others[];

// Separate symbols into groups
   for(int i = 0; i < ArraySize(ARR_SYMBOLS_CK); i++)
     {
      if(StringFind(ARR_SYMBOLS_CK[i], "HOSE_") == 0)
        {
         ArrayResize(hose, ArraySize(hose) + 1);
         hose[ArraySize(hose) - 1] = ARR_SYMBOLS_CK[i];
         continue;
        }

      if(StringFind(ARR_SYMBOLS_CK[i], "HNX_") == 0)
        {
         ArrayResize(hnx, ArraySize(hnx) + 1);
         hnx[ArraySize(hnx) - 1] = ARR_SYMBOLS_CK[i];
         continue;
        }

      if(StringFind(ARR_SYMBOLS_CK[i], "UPCOM_") == 0)
        {
         ArrayResize(upcom, ArraySize(upcom) + 1);
         upcom[ArraySize(upcom) - 1] = ARR_SYMBOLS_CK[i];
         continue;
        }

        {
         ArrayResize(others, ArraySize(others) + 1);
         others[ArraySize(others) - 1] = ARR_SYMBOLS_CK[i];
         continue;
        }
     }

// Sort modifiable arrays
   SortArray(hose);
   SortArray(hnx);
   SortArray(upcom);
   SortArray(others);

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

   for(int i = 0; i < ArraySize(others); i++)
     {
      ArrayResize(sorted_symbols, ArraySize(sorted_symbols) + 1);
      sorted_symbols[ArraySize(sorted_symbols) - 1] = others[i];
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
   "HOSE_VNINDEX "
   ,"HOSE_ACB NHTMCP Á Châu (ACB) "+GROUP_NGANHANG
   ,"HOSE_BID Đầu tư và Phát triển Việt Nam (BIDV Big4) "+GROUP_NGANHANG
   ,"HOSE_CTG NHTMCP Công Thương VN (VietinBank Big4) "+GROUP_NGANHANG
   ,"HOSE_EIB NHTMCP Xuất Nhập khẩu VN (Eximbank) "+GROUP_NGANHANG
   ,"HOSE_HDB NHTMCP Phát triển TP.HCM (HDBank) "+GROUP_NGANHANG
   ,"HOSE_LPB NHTMCP Bưu điện Liên Việt (LienVietPostBank) "+GROUP_NGANHANG
   ,"HOSE_MBB NHTMCP Quân Đội (MB Bank) "+GROUP_NGANHANG
   ,"HOSE_MSB NHTMCP Hàng Hải VN "+GROUP_NGANHANG
   ,"HOSE_OCB NHTMCP Phương Đông (OCB) "+GROUP_NGANHANG
   ,"HOSE_SHB NHTMCP Sài Gòn – HN (SHB) "+GROUP_NGANHANG
   ,"HOSE_SSB NHTMCP Đông Nam Á (SeABank) "+GROUP_NGANHANG
   ,"HOSE_STB NHTMCP Sài Gòn Thương Tín (Sacombank) "+GROUP_NGANHANG
   ,"HOSE_TCB NHTMCP Kỹ Thương VN (Techcombank) "+GROUP_NGANHANG
   ,"HOSE_TPB NHTMCP Tiên Phong (TPBank) "+GROUP_NGANHANG
   ,"HOSE_VCB NHTMCP Ngoại Thương VN (Vietcombank Big4) "+GROUP_NGANHANG
   ,"HOSE_VIB NHTMCP Quốc tế VN (VIB) "+GROUP_NGANHANG
   ,"HOSE_VPB NHTMCP VN Thịnh Vượng (VPBank) phot Novaland "+GROUP_NGANHANG
   ,"HOSE_NAB Ngân hàng Thương mại Cổ phần Nam Á "+GROUP_NGANHANG
   ,"HNX_NVB NHTMCP Quốc Dân (NCB) "+GROUP_NGANHANG
   ,"HNX_BAB Bắc Á "+GROUP_NGANHANG
   ,"UPCOM_ABB An Bình "+GROUP_NGANHANG
   ,"UPCOM_BVB Bản Việt "+GROUP_NGANHANG
   ,"UPCOM_KLB Kiên Long "+GROUP_NGANHANG
   ,"UPCOM_SGB Sài Gòn Công Thương (Saigonbank) "+GROUP_NGANHANG
   ,"UPCOM_PVC Đại Chúng Việt Nam (PVcomBank) "+GROUP_NGANHANG
   ,"UPCOM_GPB Dầu Khí Toàn Cầu (GPBank) "+GROUP_NGANHANG
   ,"UPCOM_PGB Ngân hàng TMCP Thịnh Vượng và Phát triển "+GROUP_NGANHANG
   ,"UPCOM_VAB Ngân hàng Thương mại Cổ phần Việt Á "+GROUP_NGANHANG
   ,"UPCOM_VBB Ngân hàng TMCP Việt Nam Thương Tín "+GROUP_NGANHANG


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

   , "HOSE_AAA Công ty Cổ phần Nhựa An Phát Xanh "
   , "HOSE_AAM Công ty Cổ phần Thủy sản Mekong "
   , "HOSE_AAT Công ty Cổ phần Tập đoàn Tiên Sơn Thanh Hóa "
   , "HOSE_ABR Công ty Cổ phần Đầu tư Nhãn hiệu Việt "
   , "HOSE_ABS Công ty Cổ phần Dịch vụ Nông nghiệp Bình Thuận "
   , "HOSE_ABT Công ty Cổ phần Xuất nhập khẩu Thủy sản Bến Tre "
   , "HOSE_ACB Ngân hàng Thương mại Cổ phần Á Châu "
   , "HOSE_ACC Công ty Cổ phần Đầu tư và Xây dựng Bình Dương ACC "
   , "HOSE_ACG Công ty Cổ phần Gỗ An Cường "
   , "HOSE_ACL Công ty Cổ phần Xuất Nhập Khẩu Thủy sản Cửu Long An Giang "
   , "HOSE_ADG Công ty Cổ phần Clever Group "
   , "HOSE_ADP Công ty Cổ phần Sơn Á Đông "
   , "HOSE_ADS Công ty Cổ phần Damsan "
   , "HOSE_AGG Công ty Cổ phần Đầu tư và Phát triển Bất động sản An Gia "
   , "HOSE_AGM Công ty Cổ phần Xuất Nhập Khẩu An Giang "
   , "HOSE_AGR Công ty Cổ phần Chứng khoán Agribank "
   , "HOSE_AMD Công ty Cổ phần Đầu tư và Khoáng sản FLC Stone "
   , "HOSE_ANV Công ty Cổ phần Nam Việt "
   , "HOSE_APG Công ty Cổ phần Chứng khoán APG "
   , "HOSE_APH Công ty Cổ phần Tập đoàn An Phát Holdings "
   , "HOSE_ASG Công ty Cổ phần Tập đoàn ASG "
   , "HOSE_ASM Công ty Cổ phần Tập đoàn Sao Mai "
   , "HOSE_ASP Công ty Cổ phần Tập đoàn Dầu khí An Pha "
   , "HOSE_AST Công ty Cổ phần Dịch vụ Hàng không Taseco "
   , "HOSE_BAF Công ty Cổ phần Nông nghiệp BAF Việt Nam "
   , "HOSE_BBC Công ty Cổ phần BIBICA "
   , "HOSE_BCE Công ty Cổ phần Xây dựng và Giao thông Bình Dương "
   , "HOSE_BCG Công ty Cổ phần Tập đoàn Bamboo Capital "
   , "HOSE_BCM Tổng Công ty Đầu tư và Phát triển Công nghiệp - CTCP "
   , "HOSE_BFC Công ty Cổ phần Phân bón Bình Điền "
   , "HOSE_BHN Tổng Công ty Cổ phần Bia – Rượu – Nước giải khát Hà Nội "
   , "HOSE_BIC Tổng Công ty Bảo hiểm Ngân hàng Đầu tư và Phát triển Việt Nam "
   , "HOSE_BID Ngân hàng Thương mại Cổ phần Đầu tư và Phát triển Việt Nam "
   , "HOSE_BKG Công ty Cổ phần Đầu tư BKG Việt Nam "
   , "HOSE_BMC Công ty Cổ phần Khoáng sản Bình Định "
   , "HOSE_BMI Tổng Công ty Cổ phần Bảo Minh "
   , "HOSE_BMP Công ty Cổ phần Nhựa Bình Minh "
   , "HOSE_BRC Công ty Cổ phần Cao su Bến Thành "
   , "HOSE_BSI Công ty Cổ phần Chứng khoán BIDV "
   , "HOSE_BSR Công ty Cổ phần Lọc hóa dầu Bình Sơn "
   , "HOSE_BTP Công ty Cổ phần Nhiệt điện Bà Rịa "
   , "HOSE_BTT Công ty Cổ phần Thương mại – Dịch vụ Bến Thành "
   , "HOSE_BVH Tập đoàn Bảo Việt "
   , "HOSE_BWE Công ty Cổ phần - Tổng Công ty Nước – Môi trường Bình Dương "
   , "HOSE_C32 Công ty Cổ phần CIC39 "
   , "HOSE_C47 Công ty Cổ phần Xây dựng 47 "
   , "HOSE_CCI Công ty Cổ phần Đầu tư Phát triển Công nghiệp Thương mại Củ Chi "
   , "HOSE_CCL Công ty Cổ phần Đầu tư và Phát triển Đô thị Dầu khí Cửu Long "
   , "HOSE_CDC Công ty Cổ phần Chương Dương "
   , "HOSE_CHP Công ty Cổ phần Thủy điện Miền Trung "
   , "HOSE_CIG Công ty Cổ phần COMA18 "
   , "HOSE_CII Công ty Cổ phần Đầu tư Hạ tầng Kỹ thuật TP.HCM "
   , "HOSE_CKG Công ty Cổ phần Tập đoàn Tư vấn Đầu tư Xây dựng Kiên Giang "
   , "HOSE_CLC Công ty Cổ phần Cát Lợi "
   , "HOSE_CLL Công ty Cổ phần Cảng Cát Lái "
   , "HOSE_CLW Công ty Cổ phần Cấp nước Chợ Lớn "
   , "HOSE_CMG Công ty Cổ phần Tập đoàn Công nghệ CMC "
   , "HOSE_CMV Công ty Cổ phần Thương nghiệp Cà Mau "
   , "HOSE_CMX Công ty Cổ phần Camimex Group "
   , "HOSE_CNG Công ty Cổ phần CNG Việt Nam "
   , "HOSE_COM Công ty Cổ phần Vật tư - Xăng dầu "
   , "HOSE_CRC Công ty Cổ phần Create Capital Việt Nam "
   , "HOSE_CRE Công ty Cổ phần Bất động sản Thế Kỷ "
   , "HOSE_CSM Công ty Cổ phần Công nghiệp Cao su Miền Nam "
   , "HOSE_CSV Công ty Cổ phần Hóa chất cơ bản miền Nam "
   , "HOSE_CTD Công ty Cổ phần Xây dựng COTECCONS "
   , "HOSE_CTF Công ty Cổ phần City Auto "
   , "HOSE_CTG Ngân hàng Thương mại Cổ phần Công Thương Việt Nam "
   , "HOSE_CTI Công ty Cổ phần Đầu tư Phát triển Cường Thuận IDICO "
   , "HOSE_CTR Tổng Công ty Cổ phần Công trình Viettel "
   , "HOSE_CTS Công ty Cổ phần Chứng khoán Ngân hàng Công Thương Việt Nam "
   , "HOSE_CVT Công ty Cổ phần CMC "
   , "HOSE_D2D Công ty Cổ phần Phát triển Đô thị Công nghiệp số 2 "
   , "HOSE_DAG Công ty Cổ phần Tập đoàn Nhựa Đông Á "
   , "HOSE_DAH Công ty Cổ phần Tập đoàn Khách sạn Đông Á "
   , "HOSE_DAT Công ty Cổ phần Đầu tư Du lịch và Phát triển Thủy sản "
   , "HOSE_DBC Công ty Cổ phần Tập đoàn DABACO Việt Nam "
   , "HOSE_DBD Công ty Cổ phần Dược - Trang thiết bị Y tế Bình Định "
   , "HOSE_DBT Công ty Cổ phần Dược phẩm Bến Tre "
   , "HOSE_DC4 Công ty Cổ phần Xây dựng DIC Holdings "
   , "HOSE_DCL Công ty Cổ phần Dược phẩm Cửu Long "
   , "HOSE_DCM Công ty Cổ phần Phân bón Dầu khí Cà Mau "
   , "HOSE_DGC Công ty Cổ phần Tập đoàn Hóa chất Đức Giang "
   , "HOSE_DGW Công ty Cổ phần Thế Giới Số "
   , "HOSE_DHA Công ty Cổ phần Hóa An "
   , "HOSE_DHC Công ty Cổ phần Đông Hải Bến Tre "
   , "HOSE_DHG Công ty Cổ phần Dược Hậu Giang "
   , "HOSE_DHM Công ty Cổ phần Thương mại & Khai thác Khoáng sản Dương Hiếu "
   , "HOSE_DIG Tổng Công ty Cổ phần Đầu tư Phát triển Xây dựng "
   , "HOSE_DLG Công ty Cổ phần Tập đoàn Đức Long Gia Lai "
   , "HOSE_DMC Công ty Cổ phần Xuất nhập khẩu Y tế DOMESCO "
   , "HOSE_DPG Công ty Cổ phần Tập đoàn Đạt Phương "
   , "HOSE_DPM Tổng Công ty Phân bón và Hóa chất Dầu khí - Công ty Cổ phần "
   , "HOSE_DPR Công ty Cổ phần Cao su Đồng Phú "
   , "HOSE_DQC Công ty Cổ phần Tập đoàn Điện Quang "
   , "HOSE_DRC Công ty Cổ phần Cao su Đà Nẵng "
   , "HOSE_DRH Công ty Cổ phần DRH Holdings "
   , "HOSE_DRL Công ty Cổ phần Thủy điện - Điện lực 3 "
   , "HOSE_DSC Công ty Cổ phần Chứng khoán DSC "
   , "HOSE_DSE Công ty Cổ phần Chứng khoán DNSE "
   , "HOSE_DSN Công ty Cổ phần Công viên nước Đầm Sen "
   , "HOSE_DTA Công ty Cổ phần Đệ Tam "
   , "HOSE_DTL Công ty Cổ phần Đại Thiên Lộc "
   , "HOSE_DTT Công ty Cổ phần Kỹ nghệ Đô Thành "
   , "HOSE_DVP Công ty Cổ phần Đầu tư và Phát triển Cảng Đình Vũ "
   , "HOSE_DXG Công ty Cổ phần Tập đoàn Đất Xanh "
   , "HOSE_DXS Công ty Cổ phần Dịch vụ Bất động sản Đất Xanh "
   , "HOSE_DXV Công ty Cổ phần Vicem Vật liệu Xây dựng Đà Nẵng "
   , "HOSE_EIB Ngân hàng Thương mại Cổ phần Xuất Nhập khẩu Việt Nam "
   , "HOSE_ELC Công ty Cổ phần Công nghệ - Viễn thông ELCOM "
   , "HOSE_EVE Công ty Cổ phần Everpia "
   , "HOSE_EVF Công ty Tài chính Cổ phần Điện lực "
   , "HOSE_EVG Công ty Cổ phần Tập đoàn Everland "
   , "HOSE_FCM Công ty Cổ phần Khoáng sản FECON "
   , "HOSE_FCN Công ty Cổ phần FECON "
   , "HOSE_FDC Công ty Cổ phần Ngoại thương và Phát triển Đầu tư Thành phố Hồ Chí Minh "
   , "HOSE_FIR Công ty Cổ phần Địa ốc First Real "
   , "HOSE_FIT Công ty Cổ phần Tập đoàn F.I.T "
   , "HOSE_FLC Công ty Cổ phần Tập đoàn FLC "
   , "HOSE_FMC Công ty Cổ phần Thực phẩm Sao Ta "
   , "HOSE_FPT Công ty Cổ phần FPT "
   , "HOSE_FRT Công ty Cổ phần Bán lẻ Kỹ thuật số FPT "
   , "HOSE_FTS Công ty Cổ phần Chứng khoán FPT "
   , "HOSE_GAB Công ty Cổ phần Đầu tư Khai khoáng & Quản lý Tài sản FLC "
   , "HOSE_GAS Tổng Công ty Khí Việt Nam - Công ty Cổ phần "
   , "HOSE_GDT Công ty Cổ phần Chế biến Gỗ Đức Thành "
   , "HOSE_GEE Công ty Cổ phần Điện lực Gelex "
   , "HOSE_GEG Công ty Cổ phần Điện Gia Lai "
   , "HOSE_GEX Công ty Cổ phần Tập đoàn GELEX "
   , "HOSE_GIL Công ty Cổ phần Sản xuất Kinh doanh Xuất nhập khẩu Bình Thạnh "
   , "HOSE_GMD Công ty Cổ phần GEMADEPT "
   , "HOSE_GMH Công ty Cổ phần Minh Hưng Quảng Trị "
   , "HOSE_GSP Công ty Cổ phần Vận tải Sản phẩm Khí Quốc tế "
   , "HOSE_GTA Công ty Cổ phần Chế biến Gỗ Thuận An "
   , "HOSE_GVR Tập đoàn Công nghiệp Cao su Việt Nam - Công ty Cổ phần "
   , "HOSE_HAG Công ty Cổ phần Hoàng Anh Gia Lai "
   , "HOSE_HAH Công ty Cổ phần Vận tải và Xếp dỡ Hải An "
   , "HOSE_HAI Công ty Cổ phần Nông dược HAI "
   , "HOSE_HAP Công ty Cổ phần Tập đoàn HAPACO "
   , "HOSE_HAR Công ty Cổ phần Đầu tư Thương mại Bất động sản An Dương Thảo Điền "
   , "HOSE_HAS Công ty Cổ phần HACISCO "
   , "HOSE_HAX Công ty Cổ phần Dịch vụ Ô tô Hàng Xanh "
   , "HOSE_HCD Công ty Cổ phần Đầu tư Sản xuất và Thương mại HCD "
   , "HOSE_HCM Công ty Cổ phần Chứng khoán Thành phố Hồ Chí Minh "
   , "HOSE_HDB Ngân hàng Thương mại Cổ phần Phát triển Thành phố Hồ Chí Minh "
   , "HOSE_HDC Công ty Cổ phần Phát triển nhà Bà Rịa – Vũng Tàu "
   , "HOSE_HDG Công ty Cổ phần Tập đoàn Hà Đô "
   , "HOSE_HHP Công ty Cổ phần HHP Global "
   , "HOSE_HHS Công ty Cổ phần Đầu tư Dịch vụ Hoàng Huy "
   , "HOSE_HHV Công ty Cổ phần Đầu tư Hạ tầng Giao thông Đèo Cả "
   , "HOSE_HID Công ty Cổ phần Halcom Việt Nam "
   , "HOSE_HII Công ty Cổ phần An Tiến Industries "
   , "HOSE_HMC Công ty Cổ phần Kim khí Thành phố Hồ Chí Minh - Vnsteel "
   , "HOSE_HNA Công ty Cổ phần Thủy điện Hủa Na "
   , "HOSE_HOT Công ty Cổ phần Du lịch Dịch vụ Hội An "
   , "HOSE_HPG Công ty Cổ phần Tập đoàn Hòa Phát "
   , "HOSE_HPX Công ty Cổ phần Đầu tư Hải Phát "
   , "HOSE_HQC Công ty Cổ phần Tư vấn – Thương mại – Dịch vụ Địa ốc Hoàng Quân "
   , "HOSE_HRC Công ty Cổ phần Cao su Hòa Bình "
   , "HOSE_HSG Công ty Cổ phần Tập đoàn Hoa Sen "
   , "HOSE_HSL Công ty Cổ phần Đầu tư Phát triển Thực phẩm Hồng Hà "
   , "HOSE_HT1 Công ty Cổ phần Xi măng VICEM Hà Tiên "
   , "HOSE_HTG Tổng Công ty Cổ phần Dệt may Hòa Thọ "
   , "HOSE_HTI Công ty Cổ phần Đầu tư Phát triển Hạ tầng IDICO "
   , "HOSE_HTL Công ty Cổ phần Kỹ thuật và Ô tô Trường Long "
   , "HOSE_HTN Công ty Cổ phần Hưng Thịnh Incons "
   , "HOSE_HTV Công ty Cổ phần Logistics Vicem "
   , "HOSE_HU1 Công ty Cổ phần Đầu tư và Xây dựng HUD1 "
   , "HOSE_HU3 Công ty Cổ phần Đầu tư và Xây dựng HUD3 "
   , "HOSE_HUB Công ty Cổ phần Xây lắp Thừa Thiên Huế "
   , "HOSE_HVH Công ty Cổ phần Đầu tư và Công nghệ HVC "
   , "HOSE_HVN Tổng Công ty Hàng không Việt Nam - CTCP "
   , "HOSE_HVX Công ty Cổ phần Xi măng Vicem Hải Vân "
   , "HOSE_IBC Công ty Cổ phần Đầu tư Apax Holdings "
   , "HOSE_ICT Công ty Cổ phần Viễn thông - Tin học Bưu điện "
   , "HOSE_IDI Công ty Cổ phần Đầu tư và Phát triển Đa Quốc Gia I.D.I "
   , "HOSE_IJC Công ty Cổ phần Phát triển Hạ tầng Kỹ thuật "
   , "HOSE_ILB Công ty Cổ phần ICD Tân Cảng - Long Bình "
   , "HOSE_IMP Công ty Cổ phần Dược phẩm Imexpharm "
   , "HOSE_ITC Công ty Cổ phần Đầu tư - Kinh doanh Nhà "
   , "HOSE_ITD Công ty Cổ phần Công nghệ Tiên Phong "
   , "HOSE_JVC Công ty Cổ phần Đầu tư và Phát triển Y tế Việt Nhật "
   , "HOSE_KBC Tổng Công ty Phát triển Đô Thị Kinh Bắc – Công ty Cổ phần "
   , "HOSE_KDC Công ty Cổ phần Tập đoàn Kido "
   , "HOSE_KDH Công ty Cổ phần Đầu tư và Kinh doanh Nhà Khang Điền "
   , "HOSE_KHG Công ty Cổ phần Tập đoàn Khải Hoàn Land "
   , "HOSE_KHP Công ty Cổ phần Điện lực Khánh Hòa "
   , "HOSE_KMR Công ty Cổ phần MIRAE "
   , "HOSE_KOS Công ty Cổ phần KOSY "
   , "HOSE_KPF Công ty Cổ phần Đầu tư Tài sản Koji "
   , "HOSE_KSB Công ty Cổ phần Khoáng sản và Xây dựng Bình Dương "
   , "HOSE_L10 Công ty Cổ phần Lilama 10 "
   , "HOSE_LAF Công ty Cổ phần Chế biến Hàng xuất khẩu Long An "
   , "HOSE_LBM Công ty Cổ phần Khoáng sản và Vật liệu Xây dựng Lâm Đồng "
   , "HOSE_LCG Công ty Cổ phần Lizen "
   , "HOSE_LCM Công ty Cổ phần Khai thác và Chế biến Khoáng sản Lào Cai "
   , "HOSE_LDG Công ty Cổ phần Đầu tư LDG "
   , "HOSE_LEC Công ty Cổ phần Bất động sản Điện lực Miền Trung "
   , "HOSE_LGC Công ty Cổ phần Đầu tư Cầu Đường CII "
   , "HOSE_LGL Công ty Cổ phần Đầu tư và Phát triển Đô thị Long Giang "
   , "HOSE_LHG Công ty Cổ phần Long Hậu "
   , "HOSE_LIX Công ty Cổ phần Bột giặt LIX "
   , "HOSE_LM8 Công ty Cổ phần Lilama 18 "
   , "HOSE_LPB Ngân hàng Thương mại Cổ phần Lộc Phát Việt Nam "
   , "HOSE_LSS Công ty Cổ phần Mía đường Lam Sơn "
   , "HOSE_MBB Ngân hàng Thương mại Cổ phần Quân Đội "
   , "HOSE_MCG Công ty Cổ phần Năng lượng và Bất động sản MCG "
   , "HOSE_MCM Công ty Cổ phần Giống bò sữa Mộc Châu "
   , "HOSE_MCP Công ty Cổ phần In và Bao bì Mỹ Châu "
   , "HOSE_MDG Công ty Cổ phần Miền Đông "
   , "HOSE_MHC Công ty Cổ phần MHC "
   , "HOSE_MIG Tổng Công ty Cổ phần Bảo hiểm Quân đội "
   , "HOSE_MSH Công ty Cổ phần May Sông Hồng "
   , "HOSE_MSN Công ty Cổ phần Tập đoàn MaSan "
   , "HOSE_MWG Công ty Cổ phần Đầu tư Thế Giới Di Động "
   , "HOSE_NAF Công ty Cổ phần Nafoods Group "
   , "HOSE_NAV Công ty Cổ phần Nam Việt "
   , "HOSE_NBB Công ty Cổ phần Đầu tư Năm Bảy Bảy "
   , "HOSE_NCT Công ty Cổ phần Dịch vụ Hàng hóa Nội Bài "
   , "HOSE_NHA Tổng Công ty Đầu tư Phát triển Nhà và Đô thị Nam Hà Nội "
   , "HOSE_NHH Công ty Cổ phần Nhựa Hà Nội "
   , "HOSE_NHT Công ty Cổ phần Sản xuất và Thương mại Nam Hoa "
   , "HOSE_NKG Công ty Cổ phần Thép Nam Kim "
   , "HOSE_NLG Công ty Cổ phần Đầu tư Nam Long "
   , "HOSE_NNC Công ty Cổ phần Đá Núi Nhỏ "
   , "HOSE_NO1 Công ty Cổ phần Tập đoàn 911 "
   , "HOSE_NSC Công ty Cổ phần Tập đoàn Giống cây trồng Việt Nam "
   , "HOSE_NT2 Công ty Cổ phần Điện lực Dầu khí Nhơn Trạch 2 "
   , "HOSE_NTL Công ty Cổ phần Phát triển Đô thị Từ Liêm "
   , "HOSE_NVL Công ty Cổ phần Tập đoàn Đầu tư Địa ốc No Va "
   , "HOSE_NVT Công ty Cổ phần Bất động sản Du lịch Ninh Vân Bay "
   , "HOSE_OCB Ngân hàng Thương mại Cổ phần Phương Đông "
   , "HOSE_OGC Công ty Cổ phần Tập đoàn Đại Dương "
   , "HOSE_OPC Công ty Cổ phần Dược phẩm OPC "
   , "HOSE_ORS Công ty Cổ phần Chứng khoán Tiên Phong "
   , "HOSE_PAC Công ty Cổ phần Pin Ắc quy miền Nam "
   , "HOSE_PAN Công ty Cổ phần Tập đoàn PAN "
   , "HOSE_PC1 Công ty Cổ phần Tập đoàn PC1 "
   , "HOSE_PDN Công ty Cổ phần Cảng Đồng Nai "
   , "HOSE_PDR Công ty Cổ phần Phát triển Bất động sản Phát Đạt "
   , "HOSE_PET Tổng Công ty Cổ phần Dịch vụ Tổng hợp Dầu khí "
   , "HOSE_PGC Tổng Công ty Gas Petrolimex - Công ty Cổ phần "
   , "HOSE_PGD Công ty Cổ phần Phân phối Khí thấp áp Dầu khí Việt Nam "
   , "HOSE_PGI Tổng Công ty Cổ phần Bảo hiểm Petrolimex "
   , "HOSE_PGV Tổng Công ty Phát điện 3 - Công ty Cổ phần "
   , "HOSE_PHC Công ty Cổ phần Xây dựng Phục Hưng Holdings "
   , "HOSE_PHR Công ty Cổ phần Cao su Phước Hòa "
   , "HOSE_PIT Công ty Cổ phần Xuất nhập khẩu Petrolimex "
   , "HOSE_PJT Công ty Cổ phần Vận tải Xăng dầu Đường thủy Petrolimex "
   , "HOSE_PLP Công ty Cổ phần Sản xuất và Công nghệ Nhựa Pha Lê "
   , "HOSE_PLX Tập đoàn Xăng dầu Việt Nam "
   , "HOSE_PMG Công ty Cổ phần Đầu tư và Sản xuất Petro Miền Trung "
   , "HOSE_PNC Công ty Cổ phần Văn hóa Phương Nam "
   , "HOSE_PNJ Công ty Cổ phần Vàng bạc Đá quý Phú Nhuận "
   , "HOSE_POW Tổng Công ty Điện lực Dầu khí Việt Nam - CTCP "
   , "HOSE_PPC Công ty Cổ phần Nhiệt điện Phả Lại "
   , "HOSE_PSH Công ty Cổ phần Thương mại Đầu tư Dầu khí Nam Sông Hậu "
   , "HOSE_PTB Công ty Cổ phần Phú Tài "
   , "HOSE_PTC Công ty Cổ phần Đầu tư iCapital "
   , "HOSE_PTL Công ty Cổ phần Victory Group "
   , "HOSE_PVD Tổng Công ty Cổ phần Khoan và Dịch vụ Khoan Dầu khí "
   , "HOSE_PVP Công ty Cổ phần Vận tải Dầu khí Thái Bình Dương "
   , "HOSE_PVT Tổng Công ty Cổ phần Vận tải Dầu khí "
   , "HOSE_PXS Công ty Cổ phần Kết cấu Kim loại và Lắp máy Dầu khí "
   , "HOSE_QCG Công ty Cổ phần Quốc Cường Gia Lai "
   , "HOSE_QNP Công ty Cổ phần Cảng Quy Nhơn "
   , "HOSE_RAL Công ty Cổ phần Bóng đèn Phích nước Rạng Đông "
   , "HOSE_RDP Công ty Cổ phần Rạng Đông Holding "
   , "HOSE_REE Công ty Cổ phần Cơ Điện Lạnh "
   , "HOSE_ROS Công ty Cổ phần Xây dựng FLC FAROS "
   , "HOSE_RYG Công ty Cổ phần Sản xuất và Đầu tư Hoàng Gia "
   , "HOSE_S4A Công ty Cổ phần Thủy điện Sê San 4A "
   , "HOSE_SAB Tổng Công ty Cổ phần Bia – Rượu – Nước giải khát Sài Gòn "
   , "HOSE_SAM Công ty Cổ phần SAM Holdings "
   , "HOSE_SAV Công ty Cổ phần Hợp tác Kinh tế và Xuất nhập khẩu Savimex "
   , "HOSE_SBA Công ty Cổ phần Sông Ba "
   , "HOSE_SBG Công ty Cổ phần Tập đoàn Cơ khí Công nghệ cao Siba "
   , "HOSE_SBT Công ty Cổ phần Thành Thành Công - Biên Hòa "
   , "HOSE_SBV Công ty Cổ phần Siam Brothers Việt Nam "
   , "HOSE_SC5 Công ty Cổ phần Xây dựng Số 5 "
   , "HOSE_SCD Công ty Cổ phần Nước giải khát Chương Dương "
   , "HOSE_SCR Công ty Cổ phần Địa ốc Sài Gòn Thương Tín "
   , "HOSE_SCS Công ty Cổ phần Dịch vụ Hàng hóa Sài Gòn "
   , "HOSE_SFC Công ty Cổ phần Nhiên liệu Sài Gòn "
   , "HOSE_SFG Công ty Cổ phần Phân bón Miền Nam "
   , "HOSE_SFI Công ty Cổ phần Đại lý Vận tải SAFI "
   , "HOSE_SGN Công ty Cổ phần Phục vụ Mặt đất Sài Gòn "
   , "HOSE_SGR Công ty Cổ phần Tổng Công ty Cổ phần Địa ốc Sài Gòn "
   , "HOSE_SGT Công ty Cổ phần Công nghệ Viễn thông Sài Gòn "
   , "HOSE_SHA Công ty Cổ phần Sơn Hà Sài Gòn "
   , "HOSE_SHB Ngân hàng Thương mại Cổ phần Sài Gòn – Hà Nội "
   , "HOSE_SHI Công ty Cổ phần Quốc tế Sơn Hà "
   , "HOSE_SHP Công ty Cổ phần Thủy điện Miền Nam "
   , "HOSE_SII Công ty Cổ phần Hạ tầng nước Sài Gòn "
   , "HOSE_SIP Công ty Cổ phần Đầu tư Sài Gòn VRG "
   , "HOSE_SJD Công ty Cổ phần Thủy điện Cần Đơn "
   , "HOSE_SJS Công ty Cổ phần SJ Group "
   , "HOSE_SKG Công ty Cổ phần Tàu cao tốc Superdong – Kiên Giang "
   , "HOSE_SMA Công ty Cổ phần Thiết bị Phụ tùng Sài Gòn "
   , "HOSE_SMB Công ty Cổ phần Bia Sài Gòn - Miền Trung "
   , "HOSE_SMC Công ty Cổ phần Đầu tư Thương mại SMC "
   , "HOSE_SPM Công ty Cổ phần S.P.M "
   , "HOSE_SRC Công ty Cổ phần Cao su Sao Vàng "
   , "HOSE_SRF Công ty Cổ phần Searefico "
   , "HOSE_SSB Ngân hàng Thương mại Cổ phần Đông Nam Á "
   , "HOSE_SSC Công ty Cổ phần Giống Cây trồng Miền Nam "
   , "HOSE_SSI Công ty Cổ phần Chứng khoán SSI "
   , "HOSE_ST8 Công ty Cổ phần Tập đoàn ST8 "
   , "HOSE_STB Ngân hàng Thương mại Cổ phần Sài Gòn Thương Tín "
   , "HOSE_STG Công ty Cổ phần Kho vận Miền Nam "
   , "HOSE_STK Công ty Cổ phần Sợi Thế Kỷ "
   , "HOSE_SVC Công ty Cổ phần Dịch vụ Tổng hợp Sài Gòn "
   , "HOSE_SVD Công ty Cổ phần Đầu tư & Thương mại Vũ Đăng "
   , "HOSE_SVI Công ty Cổ phần Bao bì Biên Hòa "
   , "HOSE_SVT Công ty Cổ phần Công nghệ Sài Gòn Viễn Đông "
   , "HOSE_SZC Công ty Cổ phần Sonadezi Châu Đức "
   , "HOSE_SZL Công ty Cổ phần Sonadezi Long Thành "
   , "HOSE_TBC Công ty Cổ phần Thủy điện Thác Bà "
   , "HOSE_TCB Ngân hàng Thương mại Cổ phần Kỹ Thương Việt Nam "
   , "HOSE_TCD Công ty Cổ phần Tập đoàn Xây dựng Tracodi "
   , "HOSE_TCH Công ty Cổ phần Đầu tư Dịch vụ Tài chính Hoàng Huy "
   , "HOSE_TCI Công ty Cổ phần Chứng khoán Thành Công "
   , "HOSE_TCL Công ty Cổ phần Đại lý Giao nhận Vận tải Xếp dỡ Tân Cảng "
   , "HOSE_TCM Công ty Cổ phần Dệt may - Đầu tư - Thương mại Thành Công "
   , "HOSE_TCO Công ty Cổ phần TCO Holdings "
   , "HOSE_TCR Công ty Cổ phần Công nghiệp Gốm sứ TAICERA "
   , "HOSE_TCT Công ty Cổ phần Cáp treo Núi Bà Tây Ninh "
   , "HOSE_TDC Công ty Cổ phần Kinh doanh và Phát triển Bình Dương "
   , "HOSE_TDG Công ty Cổ phần Đầu tư TDG GLOBAL "
   , "HOSE_TDH Công ty Cổ phần Phát triển Nhà Thủ Đức "
   , "HOSE_TDM Công ty Cổ phần Nước Thủ Dầu Một "
   , "HOSE_TDP Công ty Cổ phần Thuận Đức "
   , "HOSE_TDW Công ty Cổ phần Cấp nước Thủ Đức "
   , "HOSE_TEG Công ty Cổ phần Năng lượng và Bất động sản Trường Thành "
   , "HOSE_TGG Công ty Cổ phần The Golden Group "
   , "HOSE_THG Công ty Cổ phần Đầu tư và Xây dựng Tiền Giang "
   , "HOSE_TIP Công ty Cổ phần Phát triển Khu Công nghiệp Tín Nghĩa "
   , "HOSE_TIX Công ty Cổ phần Sản xuất Kinh doanh XNK Dịch vụ và Đầu tư Tân Bình "
   , "HOSE_TLD Công ty Cổ phần Đầu tư Xây dựng và Phát triển Đô thị Thăng Long "
   , "HOSE_TLG Công ty Cổ phần Tập đoàn Thiên Long "
   , "HOSE_TLH Công ty Cổ phần Tập đoàn Thép Tiến Lên "
   , "HOSE_TMP Công ty Cổ phần Thủy điện Thác Mơ "
   , "HOSE_TMS Công ty Cổ phần Transimex "
   , "HOSE_TMT Công ty Cổ phần Ô tô TMT "
   , "HOSE_TN1 Công ty Cổ phần ROX Key Holdings "
   , "HOSE_TNC Công ty Cổ phần Cao su Thống Nhất "
   , "HOSE_TNH Công ty Cổ phần Tập đoàn Bệnh viện TNH "
   , "HOSE_TNI Công ty Cổ phần Tập đoàn Thành Nam "
   , "HOSE_TNT Công ty Cổ phần Tập đoàn TNT "
   , "HOSE_TPB Ngân hàng Thương mại Cổ phần Tiên Phong "
   , "HOSE_TPC Công ty Cổ phần Nhựa Tân Đại Hưng "
   , "HOSE_TRA Công ty Cổ phần Traphaco "
   , "HOSE_TRC Công ty Cổ phần Cao su Tây Ninh "
   , "HOSE_TSC Công ty Cổ phần Vật tư Kỹ thuật Nông nghiệp Cần Thơ "
   , "HOSE_TTA Công ty Cổ phần Đầu tư Xây dựng và Phát triển Trường Thành "
   , "HOSE_TTE Công ty Cổ phần Đầu tư Năng lượng Trường Thịnh "
   , "HOSE_TTF Công ty Cổ phần Tập đoàn Kỹ nghệ Gỗ Trường Thành "
   , "HOSE_TV2 Công ty Cổ phần Tư vấn Xây dựng Điện 2 "
   , "HOSE_TVB Công ty Cổ phần Chứng khoán Trí Việt "
   , "HOSE_TVS Công ty Cổ phần Chứng khoán Thiên Việt "
   , "HOSE_TVT Tổng Công ty Việt Thắng - CTCP "
   , "HOSE_TYA Công ty Cổ phần Dây và Cáp điện Taya Việt Nam "
   , "HOSE_UDC Công ty Cổ phần Xây dựng và Phát triển Đô thị tỉnh Bà Rịa - Vũng Tàu "
   , "HOSE_UIC Công ty Cổ phần Đầu tư Phát triển Nhà và Đô thị IDICO "
   , "HOSE_VAF Công ty Cổ phần Phân lân Nung chảy Văn Điển "
   , "HOSE_VCA Công ty Cổ phần Thép VICASA - VNSTEEL "
   , "HOSE_VCB Ngân hàng Thương mại Cổ phần Ngoại Thương Việt Nam "
   , "HOSE_VCF Công ty Cổ phần VINACAFÉ Biên Hòa "
   , "HOSE_VCG Tổng Công ty Cổ phần Xuất nhập khẩu và Xây dựng Việt Nam "
   , "HOSE_VCI Công ty Cổ phần Chứng khoán Vietcap "
   , "HOSE_VDP Công ty Cổ phần Dược phẩm Trung Ương Vidipha "
   , "HOSE_VDS Công ty Cổ phần Chứng khoán Rồng Việt "
   , "HOSE_VFG Công ty Cổ phần Khử trùng Việt Nam "
   , "HOSE_VGC Tổng Công ty Viglacera - CTCP "
   , "HOSE_VHC Công ty Cổ phần Vĩnh Hoàn "
   , "HOSE_VHM Công ty Cổ phần Vinhomes "
   , "HOSE_VIB Ngân hàng Thương mại Cổ phần Quốc tế Việt Nam "
   , "HOSE_VIC Tập đoàn Vingroup - Công ty Cổ phần "
   , "HOSE_VID Công ty Cổ phần Đầu tư Phát triển Thương mại Viễn Đông "
   , "HOSE_VIP Công ty Cổ phần Vận tải Xăng dầu VIPCO "
   , "HOSE_VIX Công ty Cổ phần Chứng khoán VIX "
   , "HOSE_VJC Công ty Cổ phần Hàng không VietJet "
   , "HOSE_VMD Công ty Cổ phần Y Dược phẩm Vimedimex "
   , "HOSE_VND Công ty Cổ phần Chứng khoán VNDIRECT "
   , "HOSE_VNE Tổng Công ty Cổ phần Xây dựng Điện Việt Nam "
   , "HOSE_VNG Công ty Cổ phần Du lịch Thành Thành Công "
   , "HOSE_VNL Công ty Cổ phần Logistics Vinalink "
   , "HOSE_VNM Công ty Cổ phần Sữa Việt Nam "
   , "HOSE_VNS Công ty Cổ phần Ánh Dương Việt Nam "
   , "HOSE_VOS Công ty Cổ phần Vận tải Biển Việt Nam "
   , "HOSE_VPB Ngân hàng Thương mại Cổ phần Việt Nam Thịnh Vượng "
   , "HOSE_VPD Công ty Cổ phần Phát triển Điện lực Việt Nam "
   , "HOSE_VPG Công ty Cổ phần Đầu tư Thương mại Xuất nhập khẩu Việt Phát "
   , "HOSE_VPH Công ty Cổ phần Vạn Phát Hưng "
   , "HOSE_VPI Công ty Cổ phần Đầu tư Văn Phú - Invest "
   , "HOSE_VPS Công ty Cổ phần Thuốc sát trùng Việt Nam "
   , "HOSE_VRC Công ty Cổ phần Bất động sản và Đầu tư VRC "
   , "HOSE_VRE Công ty Cổ phần Vincom Retail "
   , "HOSE_VSC Công ty Cổ phần Container Việt Nam "
   , "HOSE_VSH Công ty Cổ phần Thủy điện Vĩnh Sơn - Sông Hinh "
   , "HOSE_VSI Công ty Cổ phần Đầu tư và Xây dựng Cấp thoát nước "
   , "HOSE_VTB Công ty Cổ phần Viettronics Tân Bình "
   , "HOSE_VTO Công ty Cổ phần Vận tải Xăng dầu VITACO "
   , "HOSE_VTP Tổng Công ty Cổ phần Bưu chính Viettel "
   , "HOSE_YBM Công ty Cổ phần Khoáng sản Công nghiệp Yên Bái "
   , "HOSE_YEG Công ty Cổ phần Tập đoàn Yeah1 "

   , "HNX_ADC Công ty cổ phần Mĩ thuật và Truyền thông "
   , "HNX_ALT CTCP Văn hóa Tân Bình "
   , "HNX_AMC CTCP Khoáng sản Á Châu "
   , "HNX_AME CTCP Alphanam E&C "
   , "HNX_AMV CTCP Sản xuất kinh doanh dược và trang thiết bị y tế Việt Mỹ "
   , "HNX_API CTCP Đầu tư Châu Á - Thái Bình Dương "
   , "HNX_APS Công ty Cổ phần Chứng khoán Châu Á - Thái Bình Dương "
   , "HNX_ARM CTCP Xuất nhập khẩu hàng không "
   , "HNX_ATS Công ty cổ phần Tập đoàn đầu tư ATS "
   , "HNX_BAX CTCP Thống Nhất "
   , "HNX_BBS Công ty CP Vicem bao bì Bút Sơn "
   , "HNX_BCC CTCP Xi măng Bỉm Sơn "
   , "HNX_BCF CTCP Thực phẩm Bích Chi "
   , "HNX_BDB CTCP Sách và thiết bị Bình Định "
   , "HNX_BED CTCP Sách và Thiết bị trường học Đà Nẵng "
   , "HNX_BKC CTCP Khoáng Sản Bắc Kạn "
   , "HNX_BNA CTCP Tập đoàn Đầu tư Bảo Ngọc "
   , "HNX_BPC CTCP Vicem Bao bì Bỉm sơn "
   , "HNX_BSC CÔNG TY CP DỊCH VỤ BẾN THÀNH "
   , "HNX_BST CTCP Sách và Thiết bị Bình Thuận "
   , "HNX_BTS CTCP Xi măng VICEM Bút Sơn "
   , "HNX_BTW CTCP Cấp nước Bến Thành "
   , "HNX_BVS Công ty Cổ phần Chứng khoán Bảo Việt "
   , "HNX_BXH Công Ty Cổ phần Vicem bao bì Hải Phòng "
   , "HNX_C69 CTCP Xây dựng 1369 "
   , "HNX_CAG CTCP Cảng An Giang "
   , "HNX_CAN CTCP Đồ hộp Hạ Long "
   , "HNX_CAP Công ty Cổ phần lâm nông sản thực phẩm Yên Bái "
   , "HNX_CAR CTCP Tập đoàn Giáo dục Trí Việt "
   , "HNX_CCR CTCP Cảng Cam Ranh "
   , "HNX_CDN Công ty Cổ phần Cảng Đà Nẵng "
   , "HNX_CEO CTCP Tập đoàn C.E.O "
   , "HNX_CET CTCP HTC Holding "
   , "HNX_CIA CTCP Dịch vụ Sân bay Quốc tế Cam Ranh "
   , "HNX_CJC CTCP Cơ điện Miền Trung "
   , "HNX_CKV CTCP COKYVINA "
   , "HNX_CLH CTCP Xi măng La Hiên VVMI "
   , "HNX_CLM CTCP Xuất nhập khẩu than - Vinacomin "
   , "HNX_CMC CTCP Đầu tư CMC "
   , "HNX_CMS CTCP Tập đoàn CMH Việt Nam "
   , "HNX_CPC CTCP Thuốc sát trùng Cần Thơ "
   , "HNX_CSC CTCP Tập đoàn COTANA "
   , "HNX_CST CTCP Than Cao Sơn - TKV "
   , "HNX_CTB CTCP Chế tạo bơm Hải Dương "
   , "HNX_CTP Công ty cổ phần Hòa Bình Takara "
   , "HNX_CTT CTCP Chế tạo máy - Vinacomin "
   , "HNX_CVN CÔNG TY CỔ PHẦN VINAM "
   , "HNX_CX8 CTCP Đầu tư và Xây lắp Constrexim số 8 "
   , "HNX_D11 Công ty cổ phần Địa ốc 11 "
   , "HNX_DAD CTCP Đầu tư và Phát triển Giáo dục Đã Nẵng "
   , "HNX_DAE CTCP Sách giáo dục tại Tp. Đà Nẵng "
   , "HNX_DC2 CTCP Đầu tư Phát triển - Xây dựng (DIC) số 2 "
   , "HNX_DDG CTCP Đầu tư Công nghiệp Xuất nhập khẩu Đông Dương "
   , "HNX_DHP CTCP Điện cơ Hải Phòng "
   , "HNX_DHT CTCP Dược phẩm Hà Tây "
   , "HNX_DIH Công ty Cổ phần Đầu tư Phát triển Xây dựng - Hội An "
   , "HNX_DL1 CTCP Tập đoàn Alpha Seven "
   , "HNX_DNC CTCP Điện nước lắp máy Hải Phòng "
   , "HNX_DNP CÔNG TY CỔ PHẦN DNP HOLDING "
   , "HNX_DP3 CTCP Dược phẩm Trung ương 3 "
   , "HNX_DS3 CTCP DS3 "
   , "HNX_DST CTCP Đầu tư Sao Thăng Long "
   , "HNX_DTC CTCP Viglacera Đông Triều "
   , "HNX_DTD CTCP Đầu tư Phát triển Thành Đạt "
   , "HNX_DTG CTCP Dược phẩm Tipharco "
   , "HNX_DTK Tổng công ty Điện lực TKV - CTCP "
   , "HNX_DVM CTCP Dược liệu Việt Nam "
   , "HNX_DXP CTCP Cảng Đoạn Xá "
   , "HNX_EBS CTCP Sách giáo dục tại TP, Hà Nội "
   , "HNX_ECI CTCP Tập đoàn ECI "
   , "HNX_EID CTCP Đầu tư và Phát triển Giáo dục Hà Nội "
   , "HNX_EVS Công ty cổ phần Chứng khoán Everest "
   , "HNX_FID CTCP Đầu tư và Phát triển Doanh nghiệp Việt Nam "
   , "HNX_GDW CTCP Cấp nước Gia Định "
   , "HNX_GIC CTCP Đầu tư Dịch vụ và Phát triển Xanh "
   , "HNX_GKM CTCP GKM Holdings "
   , "HNX_GLT CTCP Kỹ thuật Điện Toàn Cầu "
   , "HNX_GMA CTCP G-Automobile "
   , "HNX_GMX CTCP Gạch Ngói Gốm Xây dựng Mỹ Xuân "
   , "HNX_HAD CTCP Bia Hà Nội - Hải Dương "
   , "HNX_HAT CTCP Thương mại Bia Hà Nội "
   , "HNX_HBS Công ty cổ phần Chứng khoán Hòa Bình "
   , "HNX_HCC CTCP Bê tông Hòa Cầm - Intimex "
   , "HNX_HCT CTCP Thương mại-Dịch vụ-Vận tải Xi măng Hải Phòng "
   , "HNX_HDA CTCP Hãng sơn Đông Á "
   , "HNX_HEV Công ty Cổ phần Sách Đại học - Dạy nghề "
   , "HNX_HGM Công ty Cổ phần Cơ khí và Khoáng sản Hà Giang "
   , "HNX_HHC Công ty cổ phần Bánh kẹo Hải Hà "
   , "HNX_HJS CTCP Thủy điện Nậm Mu "
   , "HNX_HKT Công ty cổ phần Đầu tư QP Xanh "
   , "HNX_HLC CTCP Than Hà Lầm - Vinacomin "
   , "HNX_HLD CTCP Đầu tư và phát triển Bất động sản HUDLAND "
   , "HNX_HMH CTCP Hải Minh "
   , "HNX_HMR CTCP Đá Hoàng Mai "
   , "HNX_HOM CTCP Xi măng VICEM Hoàng Mai "
   , "HNX_HTC Công ty Cổ phần Thương mại Hóc Môn "
   , "HNX_HUT CTCP Tasco "
   , "HNX_HVT CTCP Hóa chất Việt Trì "
   , "HNX_ICG CTCP Xây dựng Sông Hồng "
   , "HNX_IDC Tổng Công ty IDICO - CTCP "
   , "HNX_IDJ CTCP Đầu tư IDJ Việt Nam "
   , "HNX_IDV Công ty Cổ phần Phát triển Hạ tầng Vĩnh Phúc "
   , "HNX_INC CTCP Tư vấn Đầu tư IDICO "
   , "HNX_INN CTCP Bao bì và In Nông nghiệp "
   , "HNX_IPA CTCP Tập đoàn Đầu tư I.P.A "
   , "HNX_ITQ CTCP Tập đoàn Thiên Quang "
   , "HNX_IVS Công ty Cổ phần Chứng khoán Guotai Junan (Việt Nam) "
   , "HNX_KDM Công ty Cổ Phần Tập đoàn GCL "
   , "HNX_KHS CTCP Kiên Hùng "
   , "HNX_KKC Công ty Cổ phần Tập đoàn Thành Thái "
   , "HNX_KMT CTCP Kim khí Miền Trung "
   , "HNX_KSD CTCP Đầu tư DNA "
   , "HNX_KSF Công ty cổ phần Tập đoàn Sunshine "
   , "HNX_KSQ CTCP CNC Capital Việt Nam "
   , "HNX_KST Công ty Cổ phần KASATI "
   , "HNX_KSV Tổng Công ty Khoáng Sản TKV - CTCP "
   , "HNX_KTS CTCP Đường KonTum "
   , "HNX_L14 CTCP Licogi 14 "
   , "HNX_L18 CTCP Đầu tư và Xây dựng số 18 "
   , "HNX_L40 CTCP Đầu tư và Xây dựng 40 "
   , "HNX_LAS CTCP Supe Phốt phát và Hóa chất Lâm Thao "
   , "HNX_LBE Công ty cổ phần Thương mại và Dịch vụ LVA "
   , "HNX_LCD ctcp Lắp máy - Thí nghiệm cơ điện "
   , "HNX_LDP CTCP Dược Lâm Đồng - Ladophar "
   , "HNX_LHC CTCP Đầu tư và Xây dựng Thủy lợi Lâm Đồng "
   , "HNX_LIG CTCP Licogi 13 "
   , "HNX_MAC CTCP Cung ứng và Dịch vụ Kỹ thuật hàng hải "
   , "HNX_MAS CTCP Dịch vụ Hàng Không Sân Bay Đà Nẵng "
   , "HNX_MBG CTCP Tập Đoàn MBG "
   , "HNX_MBS Công ty Cổ phần Chứng khoán MB "
   , "HNX_MCC CTCP Gạch ngói cao cấp "
   , "HNX_MCF Công ty CP Xây lắp Cơ khí và Lương thực Thực phẩm "
   , "HNX_MCO CTCP Đầu tư & Xây dựng BDC Việt Nam "
   , "HNX_MDC CTCP Than Mông Dương - Vinacomin "
   , "HNX_MED CTCP Dược Trung Ương Mediplantex "
   , "HNX_MEL CTCP Thép Mê Lin "
   , "HNX_MKV CTCP Dược Thú Y Cai Lậy "
   , "HNX_MST CTCP Đầu tư MST "
   , "HNX_MVB Tổng công ty Công nghiệp mỏ Việt Bắc TKV - CTCP "
   , "HNX_NAG CTCP Tập Đoàn Nagakawa "
   , "HNX_NAP Công ty Cổ phần Cảng Nghệ Tĩnh "
   , "HNX_NBC CTCP Than Núi Béo - Vinacomin "
   , "HNX_NBP Công ty cổ phần Nhiệt điện Ninh Bình "
   , "HNX_NBW CTCP Cấp nước Nhà Bè "
   , "HNX_NDN CTCP Đầu tư phát triển Nhà Đà Nẵng "
   , "HNX_NDX CTCP Xây lắp Phát triển Nhà Đà Nẵng "
   , "HNX_NET Công ty Cổ Phần Bột Giặt NET "
   , "HNX_NFC CTCP Phân lân Ninh Bình "
   , "HNX_NHC CTCP Gạch ngói Nhị Hiệp "
   , "HNX_NRC CTCP Tập đoàn Danh Khôi "
   , "HNX_NSH CTCP Tập đoàn Nhôm Sông Hồng Shalumi "
   , "HNX_NST CTCP Ngân Sơn "
   , "HNX_NTH CTCP Thủy điện Nước Trong "
   , "HNX_NTP CTCP Nhựa Thiếu niên Tiền Phong "
   , "HNX_NVB Ngân hàng TMCP Quốc Dân "
   , "HNX_OCH CTCP One Capital Hospitality "
   , "HNX_ONE CTCP Công nghệ ONE "
   , "HNX_PBP CTCP Bao bì Dầu khí Việt Nam "
   , "HNX_PCE CTCP Phân bón và Hóa chất Dầu khí Miền Trung "
   , "HNX_PCG Công ty Cổ phần Đầu tư Phát triển Gas Đô thị "
   , "HNX_PCH CTCP Nhựa Picomat "
   , "HNX_PCT Công ty Cổ phần Vận tải biển Global Pacific "
   , "HNX_PDB CTCP Tập đoàn Đầu tư DIN Capital "
   , "HNX_PEN CTCP Xây lắp III Petrolimex "
   , "HNX_PGN Công ty cổ phần Phụ Gia Nhựa "
   , "HNX_PGS CTCP Kinh doanh Khí miền Nam "
   , "HNX_PGT CTCP PGT Holdings "
   , "HNX_PHN CTCP Pin Hà Nội "
   , "HNX_PIA CTCP Tin học Viễn thông Petrolimex "
   , "HNX_PIC CTCP Đầu tư Điện lực 3 "
   , "HNX_PJC CTCP Thương mại và Vận tải Petrolimex Hà Nội "
   , "HNX_PLC Tổng Công ty Hóa dầu Petrolimex - CTCP "
   , "HNX_PMB CTCP Phân bón và Hóa chất Dầu khí Miền Bắc "
   , "HNX_PMC CTCP Dược phẩm dược liệu Pharmedic "
   , "HNX_PMP CTCP Bao bì Đạm Phú Mỹ "
   , "HNX_PMS CTCP Cơ khí xăng dầu "
   , "HNX_POT CTCP Thiết bị Bưu điện "
   , "HNX_PPE Công Ty Cổ Phần Tư Vấn Đầu Tư PP ENTERPRISE "
   , "HNX_PPP CTCP Dược phẩm Phong Phú "
   , "HNX_PPS Công ty cổ phần Dịch vụ kỹ thuật Điện lực Dầu khí Việt Nam "
   , "HNX_PPT CTCP Petro Times "
   , "HNX_PPY CTCP Xăng dầu Dầu khí Phú Yên "
   , "HNX_PRC CTCP Logistics Portserco "
   , "HNX_PRE Tổng công ty cổ phần Tái bảo hiểm Hà Nội "
   , "HNX_PSC CTCP Vận tải và Dịch vụ Petrolimex Sài Gòn "
   , "HNX_PSD CTCP Dịch vụ Phân phối Tổng hợp Dầu khí "
   , "HNX_PSE CTCP Phân bón và Hóa chất Dầu khí Đông Nam Bộ "
   , "HNX_PSI Công ty Cổ phần Chứng khoán Dầu khí "
   , "HNX_PSW CTCP Phân bón và Hóa chất Dầu khí Tây Nam Bộ "
   , "HNX_PTD CÔNG TY CỔ PHẦN THIẾT KẾ XÂY DỰNG THƯƠNG MẠI PHÚC THỊNH "
   , "HNX_PTI TỔNG CÔNG TY CỔ PHẦN BẢO HIỂM BƯU ĐIỆN "
   , "HNX_PTS CTCP Vận tải và Dịch vụ Petrolimex Hải Phòng "
   , "HNX_PTX CTCP Vận tải và dịch vụ Petrolimex Nghệ Tĩnh "
   , "HNX_PV2 Công ty cổ phần Đầu tư PV2 "
   , "HNX_PVB CTCP Bọc Ống Dầu khí Việt Nam "
   , "HNX_PVC Tổng Công ty Hóa chất và Dịch vụ Dầu khí - CTCP (PVChem) "
   , "HNX_PVG Công ty cổ phần Kinh doanh LPG Việt Nam "
   , "HNX_PVI CTCP PVI "
   , "HNX_PVS Tổng CTCP Dịch Vụ Kỹ Thuật Dầu Khí Việt Nam "
   , "HNX_QHD CTCP Que hàn điện Việt Đức "
   , "HNX_QST CTCP Sách và Thiết bị Trường học Quảng Ninh "
   , "HNX_QTC Công ty Cổ phần Công trình Giao thông Vận tải Quảng Nam "
   , "HNX_RCL Công Ty Cổ Phần Địa ốc Chợ Lớn "
   , "HNX_S55 Công ty cổ phần Sông Đà 505 "
   , "HNX_S99 Công ty cổ phần SCI "
   , "HNX_SAF CTCP Lương thực Thực phẩm SAFOCO "
   , "HNX_SCG Công ty cổ phần Tập đoàn Xây dựng SCG "
   , "HNX_SCI CTCP SCI E&C "
   , "HNX_SD5 CTCP Sông Đà 5 "
   , "HNX_SD9 CTCP Sông Đà 9 "
   , "HNX_SDA CTCP SIMCO Sông Đà "
   , "HNX_SDC CTCP Tư vấn Sông Đà "
   , "HNX_SDG CTCP Sadico Cần Thơ "
   , "HNX_SDN CTCP Sơn Đồng Nai "
   , "HNX_SDU CTCP Đầu tư xây dựng và Phát triển đô thị Sông Đà "
   , "HNX_SEB CÔNG TY CỔ PHẦN ĐẦU TƯ VÀ PHÁT TRIỂN ĐIỆN MIỀN TRUNG "
   , "HNX_SED CTCP Đầu tư và Phát triển Giáo dục Phương Nam "
   , "HNX_SFN CTCP Dệt lưới Sài Gòn "
   , "HNX_SGC CTCP Xuất nhập khẩu Sa Giang "
   , "HNX_SGD CTCP Sách giáo dục tại Tp. HCM "
   , "HNX_SGH CTCP Khách sạn Sài Gòn "
   , "HNX_SHE CTCP Phát triển năng lượng Sơn Hà "
   , "HNX_SHN CTCP Đầu tư Tổng hợp Hà Nội "
   , "HNX_SHS Công ty Cổ phần chứng khoán Sài Gòn - Hà Nội "
   , "HNX_SJ1 CTCP Nông nghiệp Hùng Hậu "
   , "HNX_SJE CTCP Sông Đà 11 "
   , "HNX_SLS CTCP Mía đường Sơn La "
   , "HNX_SMN CTCP Sách và Thiết bị Giáo dục Miền Nam "
   , "HNX_SMT CTCP SAMETEL "
   , "HNX_SPC CTCP Bảo vệ Thực vật Sài Gòn "
   , "HNX_SPI CTCP SPIRAL GALAXY "
   , "HNX_SRA CTCP SARA Việt Nam "
   , "HNX_SSM CTCP Chế tạo Kết cấu thép VNECO.SSM "
   , "HNX_STC CTCP Sách và Thiết bị Trường học tại Tp, HCM "
   , "HNX_STP Công ty cổ phần Công nghiệp Thương mại Sông Đà "
   , "HNX_SVN CTCP Tập đoàn VEXILLA Việt Nam "
   , "HNX_SZB CTCP Sonadezi Long Bình "
   , "HNX_TA9 CTCP Xây lắp Thành An 96 "
   , "HNX_TBX CTCP Xi măng Thái Bình "
   , "HNX_TDT CTCP Đầu tư và Phát triển TDT "
   , "HNX_TET CTCP Vải sợi may mặc miền Bắc "
   , "HNX_TFC Công ty Cổ phần Trang "
   , "HNX_THB CTCP Bia Hà Nội - Thanh Hoá "
   , "HNX_THD CTCP Thaiholdings "
   , "HNX_THS CTCP Thanh Hoa - Sông Đà "
   , "HNX_THT CTCP Than Hà Tu - Vinacomin "
   , "HNX_TIG CTCP Tập đoàn Đầu tư Thăng Long "
   , "HNX_TJC CTCP Dịch vụ Vận tải và Thương mại "
   , "HNX_TKU CTCP Công nghiệp Tungkuang "
   , "HNX_TMB CTCP Kinh doanh than miền Bắc-Vinacomin "
   , "HNX_TMC CTCP Thương mại Xuất nhập khẩu Thủ Đức "
   , "HNX_TMX CTCP Vicem Thương mại xi măng "
   , "HNX_TNG CTCP Đầu tư và Thương mại TNG "
   , "HNX_TOT CÔNG TY CỔ PHẦN TRANSIMEX LOGISTICS "
   , "HNX_TPH CTCP In Sách giáo khoa tại Tp. Hà Nội "
   , "HNX_TPP CTCP Tân Phú Việt Nam "
   , "HNX_TSB CTCP Ắc quy Tia Sáng "
   , "HNX_TTC CTCP Gạch men Thanh Thanh "
   , "HNX_TTH CTCP Thương mại và Dịch vụ Tiến Thành "
   , "HNX_TTL Tổng Công ty Thăng Long - CTCP "
   , "HNX_TTT CTCP Du lịch - Thương mại Tây Ninh "
   , "HNX_TV3 Công ty cổ phần Tư vấn Xây dựng điện 3 "
   , "HNX_TV4 CTCP Tư vấn Xây dựng điện 4 "
   , "HNX_TVC CTCP Tập đoàn Quản lý Tài sản Trí Việt "
   , "HNX_TVD CTCP Than Vàng Danh - Vinacomin "
   , "HNX_TXM CTCP Vicem Thạch cao Xi măng "
   , "HNX_UNI CTCP ĐẦU TƯ VÀ PHÁT TRIỂN SAO MAI VIỆT "
   , "HNX_V12 Công ty cổ phần xây dựng số 12 "
   , "HNX_V21 CTCP Vinaconex 21 "
   , "HNX_VBC CTCP Nhựa Bao bì Vinh "
   , "HNX_VC1 Công ty cổ phần xây dựng số 1 "
   , "HNX_VC2 Công ty cổ phần Đầu tư và Xây dựng VINA2 "
   , "HNX_VC3 Công ty Cổ phần Tập đoàn Nam Mê Kông "
   , "HNX_VC6 Công ty cổ phần Xây dựng và đầu tư Visicons "
   , "HNX_VC7 CTCP TẬP ĐOÀN BGI "
   , "HNX_VC9 Công ty cổ phần xây dựng số 9- VC9 "
   , "HNX_VCC CTCP Vinaconex 25 "
   , "HNX_VCM CTCP BV LIFE "
   , "HNX_VCS CTCP VICOSTONE "
   , "HNX_VDL CTCP Thực phẩm Lâm Đồng "
   , "HNX_VE1 CTCP Xây dựng điện VNECO 1 "
   , "HNX_VE3 CTCP Xây dựng điện VNECO3 "
   , "HNX_VE4 CTCP Xây dựng Điện Vneco 4 "
   , "HNX_VE8 CTCP Xây dựng Điện Vneco 8 "
   , "HNX_VFS Công ty Cổ phần Chứng khoán Nhất Việt "
   , "HNX_VGP CTCP Cảng Rau Quả "
   , "HNX_VGS Công ty Cổ Phần Ống thép Việt Đức VGPIPE "
   , "HNX_VHE CTCP Dược liệu và Thực phẩm Việt Nam "
   , "HNX_VHL CTCP Viglacera Hạ Long "
   , "HNX_VIF Tổng công ty Lâm nghiệp Việt Nam- CTCP "
   , "HNX_VIG Công ty cổ phần Chứng khoán Đầu tư Tài chính Việt Nam "
   , "HNX_VIT CÔNG TY CỔ PHẦN VIGLACERA TIÊN SƠN "
   , "HNX_VLA CTCP Đầu tư và phát triển công nghệ Văn Lang "
   , "HNX_VMC Công ty cổ phần VIMECO "
   , "HNX_VMS Công ty cổ phần Phát triển Hàng hải "
   , "HNX_VNC CTCP Tập đoàn Vinacontrol "
   , "HNX_VNF CTCP Vinafreight "
   , "HNX_VNR Tổng CTCP Tái Bảo hiểm Quốc gia Việt Nam "
   , "HNX_VNT CTCP Giao nhận Vận tải Ngoại thương "
   , "HNX_VSA CTCP Đại lý Hàng hải Việt Nam "
   , "HNX_VSM CTCP Container Miền Trung "
   , "HNX_VTC CTCP Viễn thông VTC "
   , "HNX_VTH Công ty Cổ phần Dây cáp điện Việt Thái "
   , "HNX_VTJ CTCP Thương mại và Đầu tư Vi na ta ba "
   , "HNX_VTV Công ty Cổ phần Năng lượng và Môi trường VICEM "
   , "HNX_VTZ CTCP Sản xuất và Thương mại Nhựa Việt Thành "
   , "HNX_WCS CTCP Bến xe Miền Tây "
   , "HNX_WSS Công ty Cổ phần Chứng khoán Phố Wall "
   , "HNX_X20 CTCP X20 "
   , "UPCOM_A32 CTCP 32 "
   , "UPCOM_AAH Công ty Cổ phần Hợp Nhất "
   , "UPCOM_AAS CTCP Chứng khoán SmartInvest "
   , "UPCOM_ABC CTCP Truyền thông VMG "
   , "UPCOM_ABI CTCP Bảo hiểm Ngân hàng Nông Nghiệp "
   , "UPCOM_ABW CTCP Chứng khoán An Bình "
   , "UPCOM_ACE CTCP Bê tông Ly tâm An Giang "
   , "UPCOM_ACM CTCP Tập đoàn Khoáng sản Á Cường "
   , "UPCOM_ACS CTCP Xây lắp Thương mại 2 "
   , "UPCOM_ACV Tổng công ty Cảng hàng không Việt Nam - CTCP "
   , "UPCOM_AFX CTCP Xuất nhập khẩu Nông sản Thực phẩm An Giang "
   , "UPCOM_AG1 CTCP 28.1 "
   , "UPCOM_AGF CTCP Xuất nhập khẩu Thủy sản An Giang "
   , "UPCOM_AGP CTCP Dược phẩm Agimexpharm "
   , "UPCOM_AGX CTCP Thực phẩm Nông sản Xuất khẩu Sài Gòn "
   , "UPCOM_AIC Tổng Công ty cổ phần Bảo hiểm Hàng Không "
   , "UPCOM_AIG CTCP Nguyên liệu Á Châu AIG "
   , "UPCOM_ALV CTCP Xây dựng ALVICO "
   , "UPCOM_AMD CTCP Đầu tư và Khoáng sản FLC Stone "
   , "UPCOM_AMP CTCP Armephaco "
   , "UPCOM_AMS CTCP Cơ khí Xây dựng AMECC "
   , "UPCOM_ANT CTCP Rau quả Thực phẩm An Giang "
   , "UPCOM_APC CTCP Chiếu xạ An Phú "
   , "UPCOM_APF CTCP Nông sản Thực phẩm Quảng Ngãi "
   , "UPCOM_APL CTCP Cơ khí và Thiết bị áp lực - VVMI "
   , "UPCOM_APP CTCP Phát triển phụ gia và sản phầm dầu mỏ "
   , "UPCOM_APT CTCP Kinh doanh Thủy Hải sản Sài Gòn "
   , "UPCOM_ART Công ty Cổ phần Chứng khoán BOS "
   , "UPCOM_ASA CTCP ASA "
   , "UPCOM_ATA CTCP NTACO "
   , "UPCOM_ATB CTCP An Thịnh "
   , "UPCOM_ATG CTCP An Trường An "
   , "UPCOM_AVC CTCP Thủy điện A Vương "
   , "UPCOM_AVF CTCP Việt An "
   , "UPCOM_AVG CTCP Phân bón Quốc tế Âu Việt "
   , "UPCOM_BAL CTCP Bao bì Bia - Rượu - Nước giải khát "
   , "UPCOM_BBH CTCP Bao bì Hoàng Thạch "
   , "UPCOM_BBM CTCP Bia Hà Nội - Nam Định "
   , "UPCOM_BBT CTCP Bông Bạch Tuyết "
   , "UPCOM_BCA CTCP B.C.H "
   , "UPCOM_BCB CTCP 397 "
   , "UPCOM_BCP CTCP Dược Enlie "
   , "UPCOM_BCR CTCP BCG Land "
   , "UPCOM_BCV CTCP Du lịch và Thương mại Bằng Giang Cao Bằng - Vimico "
   , "UPCOM_BDG Công ty Cổ phần May mặc Bình Dương "
   , "UPCOM_BDT CTCP Xây lắp và Vật liệu Xây dựng Đồng Tháp "
   , "UPCOM_BDW CTCP Cấp thoát nước Bình Định "
   , "UPCOM_BEL CTCP Điện tử Biên Hòa "
   , "UPCOM_BGE CTCP BCG Energy "
   , "UPCOM_BGW CTCP Nước sạch Bắc Giang "
   , "UPCOM_BHA CTCP Thủy điện Bắc Hà "
   , "UPCOM_BHC Công ty cổ phần bê tông Biên hòa "
   , "UPCOM_BHG CTCP Chè Biển Hồ "
   , "UPCOM_BHI Tổng CTCP Bảo hiểm Sài Gòn - Hà Nội "
   , "UPCOM_BHK CTCP Bia Hà Nội - Kim Bài "
   , "UPCOM_BHP CTCP Bia Hà Nội - Hải Phòng "
   , "UPCOM_BIG CTCP Big Invest Group "
   , "UPCOM_BII CTCP Đầu tư và Phát triển Công nghiệp Bảo Thư "
   , "UPCOM_BIO CTCP Vắc xin và Sinh phẩm Nha Trang "
   , "UPCOM_BLF CTCP Thủy sản Bạc Liêu "
   , "UPCOM_BLI Tổng CTCP Bảo hiểm Bảo Long "
   , "UPCOM_BLN CTCP Vận tải và Dịch vụ Liên Ninh "
   , "UPCOM_BLT CTCP Lương thực Bình Định "
   , "UPCOM_BMD CTCP Môi trường và Dịch vụ đô thị Bình Thuận "
   , "UPCOM_BMF CTCP Vật liệu Xây dựng và Chất đốt Đồng Nai "
   , "UPCOM_BMG CTCP May Bình Minh "
   , "UPCOM_BMJ CTCP Khoáng sản miền đông AHP "
   , "UPCOM_BMK CTCP Kỹ thuật nhiệt Mèo Đen "
   , "UPCOM_BMN Công ty Cổ phần 715 "
   , "UPCOM_BMS Công ty Cổ phần Chứng khoán Bảo Minh "
   , "UPCOM_BMV CTCP Bột mỳ Vinafood 1 "
   , "UPCOM_BNW CTCP Nước sạch Bắc Ninh "
   , "UPCOM_BOT CTCP BOT Cầu Thái Hà "
   , "UPCOM_BQB CTCP Bia Hà Nội - Quảng Bình "
   , "UPCOM_BRR CTCP Cao su Bà Rịa "
   , "UPCOM_BRS CTCP Dịch vụ Đô thị Bà Rịa "
   , "UPCOM_BSA CTCP Thủy điện Buôn Đôn "
   , "UPCOM_BSD CTCP Bia, Rượu Sài Gòn - Đồng Xuân "
   , "UPCOM_BSG CTCP Xe khách Sài Gòn "
   , "UPCOM_BSH CTCP Bia Sài Gòn - Hà Nội "
   , "UPCOM_BSL CTCP Bia Sài Gòn - Sông Lam "
   , "UPCOM_BSP CTCP Bia Sài Gòn - Phú Thọ "
   , "UPCOM_BSQ CTCP Bia Sài Gòn - Quảng Ngãi "
   , "UPCOM_BT1 CTCP Bảo vệ Thực vật 1 Trung ương "
   , "UPCOM_BT6 CTCP BETON 6 "
   , "UPCOM_BTB CTCP Bia Hà Nội - Thái Bình "
   , "UPCOM_BTD CTCP Bê tông Ly tâm Thủ Đức "
   , "UPCOM_BTG CTCP Bao bì Tiền Giang "
   , "UPCOM_BTH CTCP Chế tạo biến thế và Vật liệu điện Hà Nội "
   , "UPCOM_BTN CTCP Đầu tư Bitco Bình Định "
   , "UPCOM_BTU Công ty Cổ phần Công trình Đô Thị Bến Tre "
   , "UPCOM_BTV CTCP Dịch vụ Du lịch Bến Thành "
   , "UPCOM_BVB Ngân hàng TMCP Bản Việt "
   , "UPCOM_BVG CTCP Group Bắc Việt "
   , "UPCOM_BVL CTCP BV Land "
   , "UPCOM_BVN CTCP Bông Việt Nam "
   , "UPCOM_BWA CTCP Cấp thoát nước và Xây dựng Bảo Lộc "
   , "UPCOM_BWS CTCP Cấp nước Bà Rịa - Vũng Tàu "
   , "UPCOM_C12 CTCP Cầu 12 "
   , "UPCOM_C21 CTCP Thế kỷ 21 "
   , "UPCOM_C22 CTCP 22 "
   , "UPCOM_C4G Công ty cổ phần Tập đoàn CIENCO4 "
   , "UPCOM_C92 CTCP Xây dựng và Đầu tư 492 "
   , "UPCOM_CAD CTCP Chế biến & XNK Thủy sản Cadovimex "
   , "UPCOM_CAT CTCP Thủy sản Cà Mau "
   , "UPCOM_CBI CTCP Gang thép Cao Bằng "
   , "UPCOM_CBS CTCP Mía đường Cao Bằng "
   , "UPCOM_CC1 Tổng Công ty Xây dựng Số 1 - CTCP "
   , "UPCOM_CC4 CTCP Đầu tư và Xây dựng số 4 "
   , "UPCOM_CCA CTCP Xuất nhập khẩu Thủy sản Cần Thơ "
   , "UPCOM_CCC CTCP Xây dựng CDC "
   , "UPCOM_CCM Công ty cổ phần Khoáng sản và Xi măng Cần Thơ "
   , "UPCOM_CCP CTCP Cảng Cửa Cấm Hải Phòng "
   , "UPCOM_CCT CTCP Cảng Cần Thơ "
   , "UPCOM_CCV CTCP Tư vấn Xây dựng Công nghiệp và Đô thị Việt Nam "
   , "UPCOM_CDG CTCP Cầu Đuống "
   , "UPCOM_CDH CTCP Công trình công cộng và Dịch vụ Du lịch Hải Phòng "
   , "UPCOM_CDO CTCP Tư vấn Thiết kế và Phát triển Đô thị "
   , "UPCOM_CDP CTCP Dược phẩm Trung ương Codupha "
   , "UPCOM_CDR CTCP Xây dựng Cao su Đồng Nai "
   , "UPCOM_CEG CTCP Tập đoàn Xây dựng và Thiết bị Công nghiệp "
   , "UPCOM_CEN CTCP CENCON Việt Nam "
   , "UPCOM_CFM CTCP Đầu tư CFM "
   , "UPCOM_CFV CTCP Cà phê Thắng Lợi "
   , "UPCOM_CGV CTCP VINACEGLASS "
   , "UPCOM_CH5 CTCP Xây dựng số 5 Hà Nội "
   , "UPCOM_CHC CTCP Cẩm Hà "
   , "UPCOM_CHS CTCP Chiếu sáng Công cộng Thành phố Hồ Chí Minh "
   , "UPCOM_CI5 CTCP Đầu tư Xây dựng số 5 "
   , "UPCOM_CID CTCP Xây dựng và Phát triển Cơ sở hạ tầng "
   , "UPCOM_CIP CTCP Xây lắp và Sản xuất Công nghiệp "
   , "UPCOM_CK8 CTCP Cơ khí 120 "
   , "UPCOM_CKA CTCP Cơ khí An Giang "
   , "UPCOM_CKD CTCP Cơ khí Đông Anh Licogi "
   , "UPCOM_CLG CTCP Đầu tư và Phát triển Nhà Đất Cotec "
   , "UPCOM_CLX CTCP Xuất nhập khẩu và Đầu tư Chợ Lớn (Cholimex) "
   , "UPCOM_CMD CTCP Vật liệu Xây dựng và Trang trí Nội thất Thành phố Hồ Chí Minh "
   , "UPCOM_CMF CTCP Thực phẩm Cholimex "
   , "UPCOM_CMI CTCP CMISTONE Việt Nam "
   , "UPCOM_CMK CTCP Cơ khí Mạo Khê - Vinacomin "
   , "UPCOM_CMM CTCP Camimex "
   , "UPCOM_CMN CTCP Lương thực Thực phẩm Colusa - Miliket "
   , "UPCOM_CMP Công ty Cổ phần Cảng Chân Mây "
   , "UPCOM_CMT CTCP Công nghệ Mạng và Truyền Thông "
   , "UPCOM_CMW CTCP Cấp nước Cà Mau "
   , "UPCOM_CNA CTCP Tổng Công ty Chè Nghệ An "
   , "UPCOM_CNC CTCP Công nghệ Cao Traphaco "
   , "UPCOM_CNN CTCP Tư vấn công nghệ, thiết bị và kiểm định xây dựng - CONINCO "
   , "UPCOM_CNT CTCP Tập đoàn CNT "
   , "UPCOM_CPA CTCP Cà phê Phước An "
   , "UPCOM_CPH CTCP Phục vụ Mai táng Hải Phòng "
   , "UPCOM_CPI CTCP Đầu tư Cảng Cái Lân "
   , "UPCOM_CQN CTCP Cảng Quảng Ninh "
   , "UPCOM_CQT CTCP Xi măng Quán Triều VVMI "
   , "UPCOM_CSI Công ty Cổ phần Chứng khoán Kiến thiết Việt Nam "
   , "UPCOM_CT3 CTCP Đầu tư và Xây dựng Công trình 3 "
   , "UPCOM_CT6 CTCP Công trình 6 "
   , "UPCOM_CTA CTCP Vinavico "
   , "UPCOM_CTN CTCP Xây dựng công trình ngầm "
   , "UPCOM_CTW CTCP Cấp thoát nước Cần Thơ "
   , "UPCOM_CTX Tổng công ty cổ phần Đầu tư xây dựng và Thương mại Việt Nam "
   , "UPCOM_CYC CTCP Gạch men Chang Yih "
   , "UPCOM_DAC CTCP 382 Đông Anh "
   , "UPCOM_DAG CTCP Tập đoàn Nhựa Đông Á "
   , "UPCOM_DAN Công ty cổ phần Dược Danapha "
   , "UPCOM_DAS CTCP Máy - Thiết bị Dầu khí Đà Nẵng "
   , "UPCOM_DBM CTCP Dược - Vật tư y tế Đăk Lăk "
   , "UPCOM_DC1 CTCP Đầu tư Phát triển Xây dựng số 1 "
   , "UPCOM_DCF CTCP Xây dựng và Thiết kế Số 1 "
   , "UPCOM_DCG CTCP Tổng Công ty May Đáp Cầu "
   , "UPCOM_DCH CTCP Địa chính Hà Nội "
   , "UPCOM_DCR CTCP Gạch men Cosevco "
   , "UPCOM_DCS CTCP Tập Đoàn Đại Châu "
   , "UPCOM_DCT Công ty Cổ phần Tấm lợp Vật liệu Xây dựng Đồng Nai "
   , "UPCOM_DDB CTCP Thương mại và Xây dựng Đông Dương "
   , "UPCOM_DDH CTCP Đảm bảo giao thông đường thủy Hải Phòng "
   , "UPCOM_DDM CTCP Hàng hải Đông Đô "
   , "UPCOM_DDN CTCP Dược - Thiết bị y tế Đà Nẵng "
   , "UPCOM_DDV CTCP DAP - VINACHEM "
   , "UPCOM_DFC CTCP Xích líp Đông Anh "
   , "UPCOM_DFF CTCP Tập đoàn Đua Fat "
   , "UPCOM_DGT CTCP Công trình Giao thông Đồng Nai "
   , "UPCOM_DHB CTCP Phân đạm và Hóa chất Hà Bắc "
   , "UPCOM_DHD CTCP Dược Vật tư Y tế Hải Dương "
   , "UPCOM_DHN CTCP Dược phẩm Hà Nội "
   , "UPCOM_DIC CTCP Đầu tư và Thương mại DIC "
   , "UPCOM_DID CTCP DIC - Đồng Tiến "
   , "UPCOM_DKC CTCP Chợ Lạng Sơn "
   , "UPCOM_DKW CTCP Cấp nước sinh hoạt Châu Thành "
   , "UPCOM_DLD CTCP Du lịch ĐăkLăk "
   , "UPCOM_DLR Công ty Cổ phần Địa ốc Đà Lạt "
   , "UPCOM_DLT Công ty CP Du lịch và Thương mại - Vinacomin "
   , "UPCOM_DM7 CTCP Dệt May 7 "
   , "UPCOM_DMN CTCP Domenal "
   , "UPCOM_DMS CTCP Hóa phẩm Dầu khí DMC - Miền Nam "
   , "UPCOM_DNA CTCP Điện nước An Giang "
   , "UPCOM_DND CTCP Đầu tư Xây dựng và Vật liệu Đồng Nai "
   , "UPCOM_DNE CTCP Môi trường Đô thị Đà Nẵng "
   , "UPCOM_DNH CTCP Thủy điện Đa Nhim - Hàm Thuận - Đa Mi "
   , "UPCOM_DNL CTCP Logistics Cảng Đà Nẵng "
   , "UPCOM_DNM TỔNG CÔNG TY CỔ PHẦN Y TẾ DANAMECO "
   , "UPCOM_DNN CTCP Cấp nước Đà Nẵng "
   , "UPCOM_DNT CTCP Du lịch Đồng Nai "
   , "UPCOM_DNW Công ty Cổ phần Cấp nước Đồng Nai "
   , "UPCOM_DOC CTCP Vật tư Nông nghiệp Đồng Nai "
   , "UPCOM_DOP CTCP Vận tải Xăng dầu Đồng Tháp "
   , "UPCOM_DP1 CTCP Dược phẩm Trung Ương CPC1 "
   , "UPCOM_DP2 CTCP Dược phẩm Trung ương 2 "
   , "UPCOM_DPC Công ty Cổ phần Nhựa Đà Nẵng "
   , "UPCOM_DPH CTCP Dược phẩm Hải Phòng "
   , "UPCOM_DPP CTCP Dược Đồng Nai "
   , "UPCOM_DPS CTCP Đầu tư Phát triển Sóc Sơn "
   , "UPCOM_DRG CTCP Cao su Đắk LắK "
   , "UPCOM_DRI CTCP Đầu tư Cao su Đắk Lắk "
   , "UPCOM_DSD CTCP DHC Suối Đôi "
   , "UPCOM_DSG CTCP Kính Đáp Cầu "
   , "UPCOM_DSP CTCP Dịch vụ Du lịch Phú Thọ "
   , "UPCOM_DTB CTCP Công trình Đô thị Bảo Lộc "
   , "UPCOM_DTE CTCP Đầu tư Năng Lượng Đại Trường Thành Holdings "
   , "UPCOM_DTH CTCP Dược - Vật tư Y tế Thanh Hóa "
   , "UPCOM_DTI CTCP Đầu tư Đức Trung "
   , "UPCOM_DTP CTCP Dược phẩm CPC1 Hà Nội "
   , "UPCOM_DUS CTCP Dịch vụ Đô thị Đà Lạt "
   , "UPCOM_DVC CTCP Thương mại Dịch vụ Tổng hợp Cảng Hải Phòng "
   , "UPCOM_DVG CTCP Đại Việt Group DVG "
   , "UPCOM_DVN Tổng Công ty Dược Việt Nam - CTCP "
   , "UPCOM_DVW CTCP Dịch vụ và Xây dựng Cấp nước Đồng Nai "
   , "UPCOM_DWC CTCP Cấp nước Đắk Lắk "
   , "UPCOM_DWS CTCP Cấp nước và Môi trường đô thị Đồng Tháp "
   , "UPCOM_DXL CTCP Du lịch và Xuất nhập khẩu Lạng Sơn "
   , "UPCOM_DZM CTCP Cơ điện Dzĩ An "
   , "UPCOM_E12 CTCP Xây dựng điện Vneco 12 "
   , "UPCOM_E29 CTCP Đầu tư Xây dựng và kỹ thuật 29 "
   , "UPCOM_ECO CTCP Nhựa sinh thái Việt Nam "
   , "UPCOM_EFI CTCP Đầu tư tài chính Giáo dục "
   , "UPCOM_EIC CTCP EVN Quốc Tế "
   , "UPCOM_EIN CTCP Đầu tư - Thương mại - Dịch vụ Điện lực "
   , "UPCOM_EME CTCP Điện Cơ "
   , "UPCOM_EMG CTCP Thiết bị phụ tùng cơ điện "
   , "UPCOM_EMS Tổng công ty Chuyển phát nhanh Bưu điện- CTCP "
   , "UPCOM_EPC CTCP Cà phê Ea Pốk "
   , "UPCOM_EPH CTCP Dịch vụ Xuất bản Giáo dục Hà Nội "
   , "UPCOM_FBA CTCP Tập đoàn Quốc Tế FBA "
   , "UPCOM_FBC CTCP Cơ khí Phổ Yên "
   , "UPCOM_FCC Công ty cổ phần Liên hợp Thực phẩm "
   , "UPCOM_FCS CTCP Lương thực Thành phố Hồ Chí Minh "
   , "UPCOM_FGL Công ty cổ phần Cà phê Gia Lai "
   , "UPCOM_FHN CTCP Xuất nhập khẩu Lương thực- Thực phẩm Hà Nội "
   , "UPCOM_FHS CTCP Phát hành sách thành phố Hồ Chí Minh - FAHASA "
   , "UPCOM_FIC Tổng công ty Vật liệu xây dựng số 1 - CTCP "
   , "UPCOM_FLC CTCP Tập đoàn FLC "
   , "UPCOM_FOC CTCP Dịch vụ Trực tuyến FPT "
   , "UPCOM_FOX CTCP Viễn thông FPT "
   , "UPCOM_FRC CTCP Lâm đặc sản Xuất khẩu Quảng Nam "
   , "UPCOM_FRM CTCP Lâm nghiệp Sài Gòn "
   , "UPCOM_FSO Công ty Cổ phần Cơ khí đóng tàu thủy sản Việt Nam "
   , "UPCOM_FT1 CTCP Phụ tùng máy số 1 "
   , "UPCOM_FTI CTCP Công nghiệp - Thương mại Hữu Nghị "
   , "UPCOM_FTM CTCP Đầu tư và Phát triển Đức Quân "
   , "UPCOM_G20 CTCP Đầu tư Dệt may Vĩnh Phúc "
   , "UPCOM_G36 Tổng Công ty 36 - CTCP "
   , "UPCOM_GAB CTCP Đầu tư Khai khoáng & Quản lý tài sản FLC "
   , "UPCOM_GCB CTCP Petec Bình Định "
   , "UPCOM_GCF CTCP Thực phẩm G.C "
   , "UPCOM_GDA CTCP Tôn Đông Á "
   , "UPCOM_GER CTCP Thể thao Ngôi sao Geru "
   , "UPCOM_GGG CTCP Ô tô Giải Phóng "
   , "UPCOM_GH3 CTCP Công trình Giao thông Hà Nội "
   , "UPCOM_GHC CTCP Thủy điện Gia Lai "
   , "UPCOM_GLC CTCP Vàng Lào Cai "
   , "UPCOM_GLW CTCP Cấp thoát nước Gia Lai "
   , "UPCOM_GMC CTCP Garmex Sài Gòn "
   , "UPCOM_GND CTCP Gạch ngói Đồng Nai "
   , "UPCOM_GPC CTCP Tập đoàn Green+ "
   , "UPCOM_GSM CTCP Thủy điện Hương Sơn "
   , "UPCOM_GTD Công ty cổ phần Giầy Thượng Đình "
   , "UPCOM_GTS CTCP Công trình Giao thông Sài Gòn "
   , "UPCOM_GTT CTCP Thuận Thảo "
   , "UPCOM_GVT Công ty Cổ phần Giấy Việt Trì "
   , "UPCOM_H11 CTCP Xây dựng HUD 101 "
   , "UPCOM_HAC CTCP Chứng khoán Hải Phòng "
   , "UPCOM_HAF CTCP Thực phẩm Hà Nội "
   , "UPCOM_HAI CTCP Nông dược HAI "
   , "UPCOM_HAM CTCP Vật tư Hậu Giang "
   , "UPCOM_HAN Tổng công ty Xây dựng Hà Nội - CTCP "
   , "UPCOM_HAV CTCP Rượu Hapro "
   , "UPCOM_HBC CTCP Tập đoàn Xây dựng Hòa Bình "
   , "UPCOM_HBD CTCP Bao bì PP Bình Dương "
   , "UPCOM_HBH CTCP Habeco - Hải Phòng "
   , "UPCOM_HC1 CTCP Xây dựng số 1 Hà Nội "
   , "UPCOM_HC3 CTCP Xây dựng số 3 Hải Phòng "
   , "UPCOM_HCB CTCP Dệt may 29/3 "
   , "UPCOM_HCI CTCP Đầu tư - Xây dựng Hà Nội "
   , "UPCOM_HD2 CTCP Đầu tư Phát triển nhà HUD2 "
   , "UPCOM_HD6 CTCP Đầu tư và Phát triển Nhà số 6 Hà Nội "
   , "UPCOM_HD8 CTCP Đầu tư Phát triển Nhà và Đô thị HUD8 "
   , "UPCOM_HDM CTCP Dệt May Huế "
   , "UPCOM_HDO CTCP Hưng Đạo Container "
   , "UPCOM_HDP CTCP Dược Hà Tĩnh "
   , "UPCOM_HDS CTCP Giống cây trồng Hải Dương "
   , "UPCOM_HDW CTCP Kinh doanh nước sạch Hải Dương "
   , "UPCOM_HEC Công ty cổ phần Tư vấn Xây dựng Thủy lợi II "
   , "UPCOM_HEJ Tổng công ty Tư vấn Xây dựng Thủy Lợi Việt Nam - CTCP "
   , "UPCOM_HEP CTCP Môi trường và Công trình Đô thị Huế "
   , "UPCOM_HES CTCP Dịch vụ Giải trí Hà Nội "
   , "UPCOM_HFB CTCP Công trình Cầu phà Thành phố Hồ Chí Minh "
   , "UPCOM_HFC CTCP xăng dầu HFC "
   , "UPCOM_HFX CTCP Sản xuất - Xuất nhập khẩu Thanh Hà "
   , "UPCOM_HGT CTCP Du lịch Hương Giang "
   , "UPCOM_HHG CTCP Hoàng Hà "
   , "UPCOM_HHN CTCP Vận tải và Dịch vụ Hàng hóa Hà Nội "
   , "UPCOM_HIG CTCP Tập Đoàn HIPT "
   , "UPCOM_HIO Công ty cổ phần Helio Energy "
   , "UPCOM_HJC CTCP Hòa Việt "
   , "UPCOM_HKB CTCP Nông nghiệp và Thực phẩm Hà Nội-Kinh Bắc "
   , "UPCOM_HLA CTCP Hữu Liên Á Châu "
   , "UPCOM_HLB CTCP Bia và Nước giải khát Hạ Long "
   , "UPCOM_HLO CTCP Công nghệ Ha Lô "
   , "UPCOM_HLS CTCP Sứ kỹ thuật Hoàng Liên Sơn "
   , "UPCOM_HLT CTCP Dệt may Hoàng Thị Loan "
   , "UPCOM_HLY Công ty cổ phần gốm xây dựng Yên Hưng "
   , "UPCOM_HMD CTCP Hóa chất Minh Đức "
   , "UPCOM_HMG Công ty Cổ phần Kim khí Hà Nội - VNSTEEL "
   , "UPCOM_HMS CTCP Xây dựng bảo tàng Hồ Chí Minh "
   , "UPCOM_HNB CTCP Bến Xe Hà Nội "
   , "UPCOM_HND CTCP Nhiệt điện Hải Phòng "
   , "UPCOM_HNF CTCP Thực phẩm Hữu Nghị "
   , "UPCOM_HNG CTCP Nông nghiệp Quốc tế Hoàng Anh Gia Lai "
   , "UPCOM_HNI CTCP May Hữu Nghị "
   , "UPCOM_HNM CTCP Sữa Hà Nội "
   , "UPCOM_HNP CTCP Hanel Xốp Nhựa "
   , "UPCOM_HNR CTCP Rượu và nước giải khát Hà Nội "
   , "UPCOM_HOT CTCP Du lịch - Dịch vụ Hội An "
   , "UPCOM_HPB CTCP Bao bì PP "
   , "UPCOM_HPD CTCP Thủy điện Đăk Đoa "
   , "UPCOM_HPH CTCP Hóa chất Hưng Phát Hà Bắc "
   , "UPCOM_HPI CTCP Khu công nghiệp Hiệp Phước "
   , "UPCOM_HPM CTCP Xây dựng Thương mại và Khoáng sản Hoàng Phúc "
   , "UPCOM_HPP CTCP Sơn Hải Phòng "
   , "UPCOM_HPT CTCP Dịch vụ Công nghệ Tin học HPT "
   , "UPCOM_HPW CTCP Cấp nước Hải Phòng "
   , "UPCOM_HRB CTCP Harec Đầu tư và Thương mại "
   , "UPCOM_HSA Công ty Cổ phần Hestia "
   , "UPCOM_HSI CTCP Vật tư Tổng hợp và Phân bón Hóa sinh "
   , "UPCOM_HSM Tổng Công ty cổ phần Dệt may Hà Nội "
   , "UPCOM_HSP CTCP Sơn tổng hợp Hà Nội "
   , "UPCOM_HSV CTCP Tập đoàn HSV Việt Nam "
   , "UPCOM_HTE CTCP Đầu tư Kinh doanh Điện lực Thành phố Hồ Chí Minh "
   , "UPCOM_HTM Tổng công ty Thương mại Hà Nội - CTCP "
   , "UPCOM_HTP CTCP In sách giáo khoa Hòa Phát "
   , "UPCOM_HTT CTCP Thương mại Hà Tây "
   , "UPCOM_HU3 CTCP Đầu tư và Xây dựng HUD3 "
   , "UPCOM_HU4 Công ty cổ phần Đầu tư và Xây dựng HUD4 "
   , "UPCOM_HU6 CTCP Đầu tư Phát triển nhà và đô thị HUD6 "
   , "UPCOM_HUG Tổng công ty May Hưng Yên - CTCP "
   , "UPCOM_HVA CTCP Đầu tư HVA "
   , "UPCOM_HVG CTCP Hùng Vương "
   , "UPCOM_HWS CTCP Cấp nước Huế "
   , "UPCOM_IBC CTCP Đầu tư Apax Holdings "
   , "UPCOM_IBD CTCP In Tổng hợp Bình Dương "
   , "UPCOM_ICC CTCP Xây dựng Công Nghiệp "
   , "UPCOM_ICF CTCP Đầu tư Thương mại Thủy Sản "
   , "UPCOM_ICI CTCP Đầu tư và Xây dựng công nghiệp "
   , "UPCOM_ICN CTCP Đầu tư Xây dựng Dầu khí IDICO "
   , "UPCOM_IDP CTCP Sữa Quốc Tế LOF "
   , "UPCOM_IFS CTCP Thực phẩm Quốc tế "
   , "UPCOM_IHK CTCP In Hàng không "
   , "UPCOM_ILA CTCP ILA "
   , "UPCOM_ILC CTCP Hợp tác lao động với nước ngoài "
   , "UPCOM_ILS CTCP Đầu tư Thương mại và Dịch vụ Quốc tế "
   , "UPCOM_IME CTCP Cơ khí và Xây lắp Công nghiệp "
   , "UPCOM_IN4 CTCP In số 4 "
   , "UPCOM_ING CTCP Đầu tư và Phát triển Xây dựng "
   , "UPCOM_IRC CTCP Cao su Công nghiệp "
   , "UPCOM_ISG CTCP Vận tải biển và Hợp tác lao động Quốc tế "
   , "UPCOM_ISH CTCP Thủy điện Srok Phu Miêng IDICO "
   , "UPCOM_IST CTCP ICD Tân Cảng Sóng Thần "
   , "UPCOM_ITA Công ty Cổ phần Đầu tư và Công nghiệp Tân Tạo "
   , "UPCOM_ITS CTCP Đầu tư, Thương mại và Dịch vụ - Vinacomin "
   , "UPCOM_JOS CTCP Chế biến Thủy sản Xuất khẩu Minh Hải "
   , "UPCOM_KAC CTCP Đầu tư Địa ốc Khang An "
   , "UPCOM_KCB CTCP Khoáng sản và Luyện Kim Cao Bằng "
   , "UPCOM_KCE CTCP Bê tông ly tâm Điện lực Khánh Hòa "
   , "UPCOM_KGM CTCP Xuất nhập khẩu Kiên Giang "
   , "UPCOM_KHD CTCP Khai thác, Chế biến khoáng sản Hải Dương "
   , "UPCOM_KHL CTCP Khoáng sản và Vật liệu Xây dựng Hưng Long "
   , "UPCOM_KHW CTCP Cấp thoát nước Khánh Hòa "
   , "UPCOM_KIP Công ty Cổ phần K.I.P Việt Nam "
   , "UPCOM_KLB Ngân hàng Thương mại cổ phần Kiên Long "
   , "UPCOM_KLF CTCP Đầu tư Thương mại và Xuất nhập khẩu CFS "
   , "UPCOM_KSH CTCP Damac GLS "
   , "UPCOM_KTC CTCP Thương mại Kiên Giang "
   , "UPCOM_KTL CTCP Kim khí Thăng Long "
   , "UPCOM_KTT Công ty cổ phần Tập đoàn Đầu tư KTT "
   , "UPCOM_KVC CTCP Sản xuất Xuất nhập khẩu Inox Kim Vĩ "
   , "UPCOM_KWA CTCP Cấp thoát nước và môi trường Kiến Tường "
   , "UPCOM_L12 CTCP Licogi 12 "
   , "UPCOM_L35 Công ty Cổ phần Cơ khí lắp máy Lilama "
   , "UPCOM_L43 CTCP Lilama 45.3 "
   , "UPCOM_L44 CTCP Lilama 45.4 "
   , "UPCOM_L45 CTCP Lilama 45.1 "
   , "UPCOM_L61 CTCP Lilama 69-1 "
   , "UPCOM_L62 Công ty cổ phần LILAMA 69-2 "
   , "UPCOM_L63 Công ty Cổ phần Lilama 69-3 "
   , "UPCOM_LAI CTCP Đầu tư Xây dựng Long An IDICO "
   , "UPCOM_LAW CTCP Cấp thoát nước Long An "
   , "UPCOM_LCC CTCP Xi măng Hồng Phong "
   , "UPCOM_LCM CTCP Khai thác và Chế biến Khoáng sản Lào Cai "
   , "UPCOM_LCS CTCP Licogi 166 "
   , "UPCOM_LDW Công Ty Cổ Phần Cấp Thoát Nước Lâm Đồng "
   , "UPCOM_LG9 CTCP Cơ giới và Xây lắp số 9 "
   , "UPCOM_LGM CTCP Giày da và May mặc Xuất khẩu (Legamex) "
   , "UPCOM_LIC Tổng Công ty Licogi - CTCP "
   , "UPCOM_LKW CTCP Cấp nước Long Khánh "
   , "UPCOM_LLM Tổng Công ty Lắp máy Việt Nam - CTCP "
   , "UPCOM_LM3 CTCP Lilama 3 "
   , "UPCOM_LM7 CTCP Lilama 7 "
   , "UPCOM_LMC CTCP Long Beach LMC "
   , "UPCOM_LMH Công ty Cổ phần Quốc Tế Holding "
   , "UPCOM_LMI CTCP Đầu tư Xây dựng Lắp máy IDICO "
   , "UPCOM_LNC CTCP Lệ Ninh "
   , "UPCOM_LO5 CTCP Lilama 5 "
   , "UPCOM_LPT CTCP Thương mại và Sản xuất Lập Phương Thành "
   , "UPCOM_LQN CTCP Licogi Quảng Ngãi "
   , "UPCOM_LSG CTCP Bất động sản Sài Gòn Vi Na "
   , "UPCOM_LTC CTCP Điện nhẹ viễn thông "
   , "UPCOM_LTG CTCP Tập đoàn Lộc Trời "
   , "UPCOM_LUT CTCP Đầu tư Xây dựng Lương Tài "
   , "UPCOM_M10 Tổng Công ty May 10 - Công ty cổ phần "
   , "UPCOM_MA1 CTCP Thiết bị "
   , "UPCOM_MBN CTCP Môi trường và Công trình đô thị Bắc Ninh "
   , "UPCOM_MCG CTCP Năng lượng và Bất động sản MCG "
   , "UPCOM_MCH CTCP Hàng tiêu dùng Masan "
   , "UPCOM_MDA CTCP Môi trường Đô thị Đông Anh "
   , "UPCOM_MDF CTCP GỖ MDF VRG QUẢNG TRỊ "
   , "UPCOM_MEC CTCP Cơ khí - Lắp máy Sông Đà "
   , "UPCOM_MEF Công ty cổ phần MEINFA "
   , "UPCOM_MES CTCP Cơ điện Công trình "
   , "UPCOM_MFS CTCP Dịch vụ Kỹ thuật MobiFone "
   , "UPCOM_MGC CTCP Địa chất Mỏ - TKV "
   , "UPCOM_MGG Tổng công ty Đức Giang - Công ty cổ phần "
   , "UPCOM_MGR CTCP Tập đoàn Mgroup "
   , "UPCOM_MH3 CTCP Khu công nghiệp cao su Bình Long "
   , "UPCOM_MHL CTCP Minh Hữu Liên "
   , "UPCOM_MIE Tổng Công ty Máy và Thiết bị Công nghiệp - CTCP "
   , "UPCOM_MIM CTCP Khoáng sản và Cơ khí "
   , "UPCOM_MKP CTCP Hóa - Dược phẩm Mekophar "
   , "UPCOM_MLC CTCP Môi trường Đô thị tỉnh Lào Cai "
   , "UPCOM_MLS CTCP Chăn nuôi - Mitraco "
   , "UPCOM_MML CTCP Masan MeatLife "
   , "UPCOM_MNB Tổng Công ty May Nhà Bè - CTCP "
   , "UPCOM_MND CTCP Môi trường Nam Định "
   , "UPCOM_MPC CTCP Tập đoàn Thủy sản Minh Phú "
   , "UPCOM_MPT CTCP Tập đoàn MPT "
   , "UPCOM_MPY CTCP Môi trường đô thị Phú Yên "
   , "UPCOM_MQB CTCP Môi trường và Phát triển Đô thị Quảng Bình "
   , "UPCOM_MQN CTCP Môi trường đô thị Quảng Ngãi "
   , "UPCOM_MRF CTCP Merufa "
   , "UPCOM_MSR CTCP Masan High-Tech Materials "
   , "UPCOM_MTA Tổng công ty Khoáng sản và Thương mại Hà Tĩnh - CTCP "
   , "UPCOM_MTB CTCP Môi trường và Công trình Đô thị tỉnh Thái Bình "
   , "UPCOM_MTC CTCP Dịch vụ du lịch Mỹ Trà "
   , "UPCOM_MTG CTCP MT Gas "
   , "UPCOM_MTH CTCP Môi trường đô thị Hà Đông "
   , "UPCOM_MTL CTCP Dịch vụ Môi trường Đô thị Từ Liêm "
   , "UPCOM_MTP CTCP Dược Medipharco "
   , "UPCOM_MTS CTCP Vật tư - TKV "
   , "UPCOM_MTV CTCP Dịch vụ Môi trường và Công trình Đô thị Vũng Tàu "
   , "UPCOM_MTX Công ty cổ phần Công trình đô thị Gò Công "
   , "UPCOM_MVC CTCP Vật liệu và Xây dựng Bình Dương "
   , "UPCOM_MVN Tổng công ty Hàng hải Việt Nam - CTCP "
   , "UPCOM_MZG CTCP Miza "
   , "UPCOM_NAC CTCP Tư vấn Xây dựng Tổng hợp "
   , "UPCOM_NAS CTCP Dịch vụ hàng không sân bay Nội Bài "
   , "UPCOM_NAU CTCP Môi trường và Công trình đô thị Nghệ An "
   , "UPCOM_NAW CTCP Cấp nước Nghệ An "
   , "UPCOM_NBE CTCP Sách và thiết bị Giáo dục miền Bắc "
   , "UPCOM_NBT CTCP Cấp thoát nước Bến Tre "
   , "UPCOM_NCG CTCP Tập đoàn Nova Consumer "
   , "UPCOM_NCS CTCP Suất ăn Hàng Không Nội Bài "
   , "UPCOM_ND2 CTCP Đầu tư và phát triển điện miền Bắc 2 "
   , "UPCOM_NDC CTCP Nam Dược "
   , "UPCOM_NDF CTCP Chế biến thực phẩm nông sản xuất khẩu Nam Định "
   , "UPCOM_NDP CTCP Dược phẩm 2-9 "
   , "UPCOM_NDT Tổng CTCP Dệt May Nam Định "
   , "UPCOM_NDW CTCP Cấp nước Nam Định "
   , "UPCOM_NED CTCP Đầu tư và Phát triển Điện Tây Bắc "
   , "UPCOM_NEM Công ty cổ phần Thiết bị điện Miền Bắc "
   , "UPCOM_NGC CTCP Chế biến Thủy sản xuất khẩu Ngô Quyền "
   , "UPCOM_NHP CTCP Sản xuất Xuất nhập khẩu NHP "
   , "UPCOM_NHV CTCP Sức khỏe Hồi sinh Việt Nam "
   , "UPCOM_NJC CTCP May Nam Định "
   , "UPCOM_NLS Công ty Cổ phần Cấp thoát Nước Lạng Sơn "
   , "UPCOM_NNT CTCP Cấp nước Ninh Thuận "
   , "UPCOM_NOS Công ty cổ phần Vận Tải Biển và Thương mại Phương Đông "
   , "UPCOM_NQB CTCP Cấp nước Quảng Bình "
   , "UPCOM_NQN CTCP Nước sạch Quảng Ninh "
   , "UPCOM_NQT CTCP Nước sạch Quảng Trị "
   , "UPCOM_NS2 Công ty Cổ phần Nước sạch số 2 Hà Nội "
   , "UPCOM_NSG CTCP Nhựa Sài Gòn "
   , "UPCOM_NSL CTCP Cấp nước Sơn La "
   , "UPCOM_NSS CTCP Nông Súc Sản Đồng Nai "
   , "UPCOM_NTB CTCP Đầu tư xây dựng và Khai thác Công trình giao thông 584 "
   , "UPCOM_NTC CTCP Khu Công nghiệp Nam Tân Uyên "
   , "UPCOM_NTF CTCP Dược - Vật tư Y tế Nghệ An "
   , "UPCOM_NTT CTCP Dệt - May Nha Trang "
   , "UPCOM_NTW CTCP Cấp nước Nhơn Trạch "
   , "UPCOM_NUE CTCP Môi trường đô thị Nha Trang "
   , "UPCOM_NVP CTCP Nước sạch Vĩnh Phúc "
   , "UPCOM_NWT Công ty Cổ phần Vận tải Newway "
   , "UPCOM_NXT CTCP Sản xuất và Cung ứng vật liệu xây dựng Kon Tum "
   , "UPCOM_ODE CTCP Tập đoàn Truyền thông và Giải trí ODE "
   , "UPCOM_OIL Tổng Công ty Dầu Việt Nam - CTCP "
   , "UPCOM_ONW CTCP Dịch vụ Một thế giới "
   , "UPCOM_PAI CTCP Công nghệ thông tin, Viễn thông và Tự động hóa dầu khí "
   , "UPCOM_PAP CTCP Dầu khí Đầu tư Khai thác Cảng Phước An "
   , "UPCOM_PAS CTCP Quốc tế Phương Anh "
   , "UPCOM_PAT CTCP Phốt pho Apatit Việt Nam "
   , "UPCOM_PBC CTCP Dược phẩm Trung ương I - Pharbaco "
   , "UPCOM_PBT CTCP Bao bì và Thương mại Dầu khí Bình Sơn "
   , "UPCOM_PCC CTCP Tập đoàn Xây lắp 1 - Petrolimex "
   , "UPCOM_PCF CTCP Cà phê Petec "
   , "UPCOM_PCM CTCP Vật liệu Xây dựng Bưu Điện "
   , "UPCOM_PDC CTCP Du lịch Dầu khí Phương Đông "
   , "UPCOM_PDV CTCP Vận tải và Tiếp vận Phương Đông Việt "
   , "UPCOM_PEC CTCP Cơ khí Điện lực "
   , "UPCOM_PEG Tổng công ty Thương mại Kỹ thuật và Đầu tư -Công ty cổ phần "
   , "UPCOM_PEQ CTCP Thiết bị Xăng dầu Petrolimex "
   , "UPCOM_PFL Công ty cổ phần Dầu khí Đông Đô "
   , "UPCOM_PHH CTCP Hồng Hà Việt Nam "
   , "UPCOM_PHP CTCP Cảng Hải Phòng "
   , "UPCOM_PHS CTCP Chứng khoán Phú Hưng "
   , "UPCOM_PID CTCP Trang trí nội thất Dầu Khí "
   , "UPCOM_PIS Tổng công ty Pisico Bình Định - CTCP "
   , "UPCOM_PIV CTCP PIV "
   , "UPCOM_PJS CTCP Cấp nước Phú Hòa Tân "
   , "UPCOM_PLA CTCP Đầu tư và Dịch vụ hạ tầng Xăng dầu "
   , "UPCOM_PLE CTCP Tư vấn Xây dựng Petrolimex "
   , "UPCOM_PLO CTCP Kho vận Petec "
   , "UPCOM_PMJ CTCP Vật tư Bưu điện "
   , "UPCOM_PMT CTCP Viễn thông Telvina Việt Nam "
   , "UPCOM_PMW CTCP Cấp nước Phú Mỹ "
   , "UPCOM_PND CTCP Xăng dầu Dầu khí Nam Định "
   , "UPCOM_PNG Công ty Cổ phần Thương mại Phú Nhuận "
   , "UPCOM_PNP CTCP Tân Cảng - Phú Hữu "
   , "UPCOM_PNT CTCP Kỹ thuật Xây dựng Phú Nhuận "
   , "UPCOM_POB CTCP Xăng dầu Dầu khí Thái Bình "
   , "UPCOM_POM CTCP Thép Pomina "
   , "UPCOM_POS CTCP Dịch vụ Lắp đặt, Vận hành và Bảo dưỡng Công trình Dầu khí biển PTSC "
   , "UPCOM_POV CTCP Xăng dầu Dầu khí Vũng Áng "
   , "UPCOM_PPH Tổng công ty cổ phần Phong Phú "
   , "UPCOM_PPI CTCP Đầu tư và Phát triển Dự án Hạ tầng Thái Bình Dương "
   , "UPCOM_PQN CTCP Dịch vụ Dầu khí Quảng Ngãi PTSC "
   , "UPCOM_PRO CTCP Procimex Việt Nam "
   , "UPCOM_PRT Tổng công ty Sản xuất - Xuất nhập khẩu Bình Dương- CTCP "
   , "UPCOM_PSB CTCP Đầu tư Dầu khí Sao Mai – Bến Đình "
   , "UPCOM_PSG CTCP Đầu tư và Xây lắp Dầu khí Sài Gòn "
   , "UPCOM_PSL CTCP Chăn nuôi Phú Sơn "
   , "UPCOM_PSN CTCP Dịch vụ Kỹ thuật PTSC Thanh Hóa "
   , "UPCOM_PSP CTCP Cảng dịch vụ Dầu khí Đình Vũ "
   , "UPCOM_PTE Công ty Cổ phần Xi măng Phú Thọ "
   , "UPCOM_PTG CTCP May Xuất Khẩu Phan Thiết "
   , "UPCOM_PTH CTCP Vận tải và Dịch vụ Petrolimex Hà Tây "
   , "UPCOM_PTO CTCP Dịch vụ- Xây dựng Công trình Bưu điện "
   , "UPCOM_PTP Công ty cổ phần PTP "
   , "UPCOM_PTT CTCP Vận tải dầu khí Đông Dương "
   , "UPCOM_PTV CTCP Thương mại Dầu khí "
   , "UPCOM_PVA CTCP Tổng Công ty Xây lắp Dầu khí Nghệ An "
   , "UPCOM_PVE Tổng Công ty Tư vấn Thiết kế Dầu khí - CTCP "
   , "UPCOM_PVH CTCP Xây lắp Dầu khí Thanh Hóa "
   , "UPCOM_PVL CTCP Đầu tư Nhà đất Việt "
   , "UPCOM_PVM CTCP Máy - Thiết bị Dầu khí "
   , "UPCOM_PVO CTCP Dầu nhờn PV Oil "
   , "UPCOM_PVR CTCP Đầu tư PVR Hà Nội "
   , "UPCOM_PVV Công ty cổ phần Vinaconex 39 "
   , "UPCOM_PVX Tổng CTCP Xây lắp Dầu khí Việt Nam "
   , "UPCOM_PVY CTCP Chế tạo Giàn khoan Dầu khí "
   , "UPCOM_PWA CTCP Bất động sản Dầu khí "
   , "UPCOM_PWS CTCP Cấp thoát nước Phú Yên "
   , "UPCOM_PX1 CTCP Xi Măng Sông Lam 2 "
   , "UPCOM_PXA CTCP Đầu tư và Thương mại Dầu khí Nghệ An "
   , "UPCOM_PXC Công ty Cổ phần Phát triển Đô thị Dầu khí "
   , "UPCOM_PXI CTCP Xây dựng Công nghiệp và Dân dụng Dầu khí "
   , "UPCOM_PXL CTCP Đầu tư Khu Công nghiệp Dầu khí Long Sơn "
   , "UPCOM_PXM CTCP Xây lắp Dầu khí Miền Trung "
   , "UPCOM_PXS CTCP Kết cấu Kim loại và Lắp máy Dầu khí "
   , "UPCOM_PXT CTCP Xây lắp Đường ống Bể chứa Dầu khí "
   , "UPCOM_QBS CTCP Xuất nhập khẩu Quảng Bình "
   , "UPCOM_QCC CTCP Đầu tư Xây dựng và Phát triển Hạ tầng Viễn thông "
   , "UPCOM_QHW CTCP Nước khoáng Quảng Ninh "
   , "UPCOM_QNC CTCP Xi măng và Xây dựng Quảng Ninh "
   , "UPCOM_QNS CTCP Đường Quảng Ngãi "
   , "UPCOM_QNT CTCP Tư vấn và Đầu tư phát triển Quảng Nam "
   , "UPCOM_QNU CTCP Môi trường đô thị Quảng Nam "
   , "UPCOM_QNW CTCP Cấp thoát nước và Xây dựng Quảng Ngãi "
   , "UPCOM_QPH CTCP Thủy điện Quế Phong "
   , "UPCOM_QSP CTCP Tân Cảng Quy Nhơn "
   , "UPCOM_QTP CTCP Nhiệt điện Quảng Ninh "
   , "UPCOM_RAT CTCP Vận tải và Thương mại Đường sắt "
   , "UPCOM_RBC CTCP Công nghiệp và Xuất nhập khẩu Cao su "
   , "UPCOM_RCC CTCP Tổng công ty Công trình đường sắt "
   , "UPCOM_RCD CTCP Xây dựng - Địa ốc Cao su "
   , "UPCOM_RIC Công ty cổ phần Quốc tế Hoàng Gia "
   , "UPCOM_RTB CTCP Cao su Tân Biên "
   , "UPCOM_S12 CTCP Sông Đà 12 "
   , "UPCOM_S27 Công ty Cổ phần Sông Đà 27 "
   , "UPCOM_S72 CTCP Sông Đà 7.02 "
   , "UPCOM_S74 Công ty cổ phần Sông Đà 7.04 "
   , "UPCOM_S96 Công ty Cổ Phần Sông Đà 9.06 "
   , "UPCOM_SAC CTCP Xếp dỡ và Dịch vụ Cảng Sài Gòn "
   , "UPCOM_SAL CTCP Trục vớt cứu hộ Việt Nam "
   , "UPCOM_SAP Công Ty Cổ phần In Sách giáo khoa Tp. HCM "
   , "UPCOM_SAS CTCP Dịch vụ Hàng không Sân bay Tân Sơn Nhất "
   , "UPCOM_SB1 CTCP Bia Sài Gòn- Nghệ Tĩnh "
   , "UPCOM_SBB CTCP Tập đoàn Bia Sài Gòn Bình Tây "
   , "UPCOM_SBD CTCP Công nghệ Sao Bắc Đẩu "
   , "UPCOM_SBH CTCP Thủy điện Sông Ba Hạ "
   , "UPCOM_SBL Công ty Cổ phần Bia Sài Gòn - Bạc Liêu "
   , "UPCOM_SBM CTCP Đầu tư Phát triển Bắc Minh "
   , "UPCOM_SBR CTCP Cao su Sông Bé "
   , "UPCOM_SBS Công ty cổ phần Chứng khoán SBS "
   , "UPCOM_SCC CTCP Thương mại Đầu tư SHB "
   , "UPCOM_SCD CTCP Nước giải khát Chương Dương "
   , "UPCOM_SCJ CTCP Xi măng Sài Sơn "
   , "UPCOM_SCL Công ty cổ phần Sông Đà Cao Cường "
   , "UPCOM_SCO CTCP Công nghiệp Thủy sản "
   , "UPCOM_SCY CTCP Đóng tàu Sông Cấm "
   , "UPCOM_SD1 Công ty cổ phần Sông Đà 1 "
   , "UPCOM_SD2 CTCP Sông Đà 2 "
   , "UPCOM_SD3 CTCP Sông Đà 3 "
   , "UPCOM_SD4 CÔNG TY CỔ PHẦN SÔNG ĐÀ 4 "
   , "UPCOM_SD6 CTCP Sông Đà 6 "
   , "UPCOM_SD7 Công ty Cổ phần Sông Đà 7 "
   , "UPCOM_SD8 Công ty cổ phần Sông Đà 8 "
   , "UPCOM_SDB CTCP Sông Đà 207 "
   , "UPCOM_SDD CTCP Đầu tư và Xây lắp Sông đà "
   , "UPCOM_SDJ CTCP Sông Đà 25 "
   , "UPCOM_SDK CTCP Cơ khí luyện kim "
   , "UPCOM_SDP CTCP SDP "
   , "UPCOM_SDT CTCP Sông Đà 10 "
   , "UPCOM_SDV CTCP Dịch vụ Sonadezi "
   , "UPCOM_SDX CTCP Phòng cháy chữa cháy và Đầu tư Xây dựng Sông Đà "
   , "UPCOM_SDY CTCP Xi măng Sông Đà Yaly "
   , "UPCOM_SEA Tổng công ty Thủy sản Việt Nam- Công ty cổ phần "
   , "UPCOM_SEP CTCP Tổng Công ty Thương mại Quảng Trị "
   , "UPCOM_SGB Ngân hàng TMCP Sài Gòn Công thương "
   , "UPCOM_SGI CTCP Đầu tư Phát triển Sài Gòn 3 Group "
   , "UPCOM_SGP CTCP Cảng Sài Gòn "
   , "UPCOM_SGS CTCP Vận tải biển Sài Gòn "
   , "UPCOM_SHC CTCP Hàng hải Sài Gòn "
   , "UPCOM_SHG Tổng CTCP Sông Hồng "
   , "UPCOM_SID CTCP Đầu tư Phát triển Sài Gòn Co.op "
   , "UPCOM_SIG CTCP Đầu tư và Thương mại Sông Đà "
   , "UPCOM_SII CTCP Hạ tầng nước Sài Gòn "
   , "UPCOM_SIV CTCP SIVICO "
   , "UPCOM_SJC CTCP Sông Đà 1.01 "
   , "UPCOM_SJF CTCP Đầu tư Sao Thái Dương "
   , "UPCOM_SJG Tổng công ty Sông Đà - CTCP "
   , "UPCOM_SJM Công ty Cổ Phần Sông Đà 19 "
   , "UPCOM_SKH Công ty Cổ phần Nước giải khát Sanest Khánh Hòa "
   , "UPCOM_SKN CTCP Nước giải khát Sanna Khánh Hòa "
   , "UPCOM_SKV CTCP Nước giải khát Yến sào Khánh Hòa "
   , "UPCOM_SNC Công ty Cổ phần Xuất nhập khẩu Thủy sản Năm Căn "
   , "UPCOM_SNZ Tổng công ty cổ phần Phát triển khu công nghiệp "
   , "UPCOM_SP2 CTCP Thủy điện Sử Pán 2 "
   , "UPCOM_SPB CTCP Sợi Phú Bài "
   , "UPCOM_SPD CTCP Xuất nhập khẩu Thủy sản miền Trung "
   , "UPCOM_SPH CTCP Xuất nhập khẩu Thủy sản Hà Nội "
   , "UPCOM_SPV CTCP Thủy Đặc Sản "
   , "UPCOM_SQC CTCP Khoáng sản Sài Gòn - Quy Nhơn "
   , "UPCOM_SRB CTCP Tập đoàn Sara "
   , "UPCOM_SSF CTCP Giáo dục G Sài Gòn "
   , "UPCOM_SSG CTCP Vận tải biển Hải Âu "
   , "UPCOM_SSH CTCP Phát triển Sunshine Homes "
   , "UPCOM_SSN CTCP Xuất nhập khẩu Thủy sản Sài Gòn "
   , "UPCOM_STH CTCP Phát hành sách Thái Nguyên "
   , "UPCOM_STL CTCP Sông Đà Thăng Long "
   , "UPCOM_STS CTCP Dịch vụ Vận tải Sài Gòn "
   , "UPCOM_STT CTCP Vận chuyển Sài Gòn Tourist "
   , "UPCOM_STW CTCP Cấp nước Sóc Trăng "
   , "UPCOM_SVG CTCP Hơi Kỹ nghệ Que Hàn "
   , "UPCOM_SVH CTCP Thủy điện Sông Vàng "
   , "UPCOM_SWC Tổng CTCP Đường sông Miền Nam "
   , "UPCOM_SZE CTCP Môi trường Sonadezi "
   , "UPCOM_SZG CTCP Sonadezi Giang Điền "
   , "UPCOM_TA6 CTCP Đầu tư và Xây lắp Thành An 665 "
   , "UPCOM_TAB CTCP Freco Việt Nam "
   , "UPCOM_TAL CTCP Đầu tư Bất động sản Taseco "
   , "UPCOM_TAN Công ty cổ phần Cà phê Thuận An "
   , "UPCOM_TAR CTCP Nông nghiệp Công nghệ cao Trung An "
   , "UPCOM_TAW CTCP Cấp nước Trung An "
   , "UPCOM_TB8 CTCP Sản xuất và Kinh doanh Vật tư thiết bị- VVMI "
   , "UPCOM_TBD Tổng Công ty Thiết bị điện Đông Anh - CTCP "
   , "UPCOM_TBH CTCP Tổng Bách Hóa "
   , "UPCOM_TBR CTCP Địa ốc Tân Bình "
   , "UPCOM_TBT CTCP Xây Dựng Công Trình Giao Thông Bến Tre "
   , "UPCOM_TBW CTCP Nước sạch Thái Bình "
   , "UPCOM_TCJ CTCP Tô Châu "
   , "UPCOM_TCK Tổng công ty cơ khí xây dựng- CTCP "
   , "UPCOM_TCW CTCP Kho vận Tân Cảng "
   , "UPCOM_TDB CTCP Thủy điện Định Bình "
   , "UPCOM_TDF CTCP Trung Đô "
   , "UPCOM_TDS CTCP Thép Thủ Đức - VNSTEEL "
   , "UPCOM_TED Tổng Công ty Tư vấn thiết kế Giao thông vận tải - CTCP "
   , "UPCOM_TEL CTCP Phát triển công trình Viễn thông "
   , "UPCOM_TGG CTCP The Golden Group "
   , "UPCOM_TGP CTCP Trường Phú "
   , "UPCOM_TH1 CTCP Xuất nhập khẩu Tổng hợp I Việt Nam "
   , "UPCOM_THM CTCP Tứ Hải Hà Nam "
   , "UPCOM_THN CTCP Cấp nước Thanh Hóa "
   , "UPCOM_THP CTCP Thủy sản và Thương mại Thuận Phước "
   , "UPCOM_THU CTCP Môi trường và Công trình Đô thị Thanh Hóa "
   , "UPCOM_THW CTCP Cấp nước Tân Hòa "
   , "UPCOM_TID CTCP Tổng công ty Tín Nghĩa "
   , "UPCOM_TIE CTCP TIE "
   , "UPCOM_TIN Công ty Tài chính Cổ phần Tín Việt "
   , "UPCOM_TIS CTCP Gang thép Thái Nguyên "
   , "UPCOM_TKA CTCP Bao bì Tân Khánh An "
   , "UPCOM_TKC CTCP Xây dựng và Kinh doanh Địa ốc Tân Kỷ "
   , "UPCOM_TKG CTCP Sản xuất và Thương mại Tùng Khánh "
   , "UPCOM_TL4 Tổng công ty Xây dựng Thủy lợi 4 - CTCP "
   , "UPCOM_TLI CTCP May Quốc tế Thắng Lợi "
   , "UPCOM_TLP Tổng công ty Thương mại Xuất nhập khẩu Thanh Lễ- CTCP "
   , "UPCOM_TLT CTCP Viglacera Thăng Long "
   , "UPCOM_TMG CTCP Kim loại màu Thái Nguyên - Vimico "
   , "UPCOM_TMW CTCP Tổng hợp Gỗ Tân Mai "
   , "UPCOM_TNA CTCP Thương mại Xuất nhập khẩu Thiên Nam "
   , "UPCOM_TNB CTCP Thép Nhà Bè - VNSTEEL "
   , "UPCOM_TNM CTCP Xuất nhập khẩu và Xây dựng công trình "
   , "UPCOM_TNP CTCP Cảng Thị Nại "
   , "UPCOM_TNS CTCP Thép Tấm lá Thống Nhất "
   , "UPCOM_TNV CTCP Thống nhất Hà Nội "
   , "UPCOM_TNW CTCP Nước sạch Thái Nguyên "
   , "UPCOM_TOP Công ty Cổ phần Phân phối Top One "
   , "UPCOM_TOS CTCP Dịch vụ biển Tân Cảng "
   , "UPCOM_TOW CTCP Cấp nước Trà Nóc- Ô Môn "
   , "UPCOM_TPS CTCP Bến bãi Vận tải Sài Gòn "
   , "UPCOM_TQN CTCP Thông Quảng Ninh "
   , "UPCOM_TQW CTCP Cấp thoát nước Tuyên Quang "
   , "UPCOM_TR1 CTCP Vận tải 1 Traco "
   , "UPCOM_TRS CTCP Vận tải và Dịch vụ Hàng Hải "
   , "UPCOM_TRT CTCP RedstarCera "
   , "UPCOM_TS3 Công ty Cổ phần Trường Sơn 532 "
   , "UPCOM_TS4 CTCP Thủy sản số 4 "
   , "UPCOM_TSA CTCP Đầu tư và Xây lắp Trường Sơn "
   , "UPCOM_TSD CTCP Du lịch Trường Sơn COECCO "
   , "UPCOM_TSG CTCP Thông tin Tín hiệu Đường sắt Sài Gòn "
   , "UPCOM_TSJ CTCP Du lịch Dịch vụ Hà Nội "
   , "UPCOM_TST CTCP Dịch vụ Kỹ thuật Viễn thông "
   , "UPCOM_TT6 CTCP Tập đoàn Tiến Thịnh "
   , "UPCOM_TTB CTCP TTBGROUP "
   , "UPCOM_TTD CTCP Bệnh viện tim Tâm Đức "
   , "UPCOM_TTG CTCP May Thanh Trì "
   , "UPCOM_TTN CTCP Công nghệ và Truyền thông Việt Nam "
   , "UPCOM_TTS CTCP Cán thép Thái Trung "
   , "UPCOM_TTZ CTCP Đầu tư Xây dựng và Công nghệ Tiến Trung "
   , "UPCOM_TUG CTCP Lai dắt và Vận tải Cảng Hải Phòng "
   , "UPCOM_TV1 CTCP Tư vấn Xây dựng Điện 1 "
   , "UPCOM_TV6 Công ty Cổ phần Tập đoàn EMA LAND "
   , "UPCOM_TVA CTCP Sứ Viglacera Thanh Trì "
   , "UPCOM_TVG CTCP Tư vấn Đầu tư và Xây dựng Giao thông vận tải "
   , "UPCOM_TVH CTCP Tư vấn Xây dựng Công trình Hàng Hải "
   , "UPCOM_TVM CTCP Tư vấn đầu tư mỏ và công nghiệp - Vinacomin "
   , "UPCOM_TVN Tổng Công ty Thép Việt Nam - CTCP "
   , "UPCOM_TW3 CTCP Dược Trung ương 3 "
   , "UPCOM_UCT CTCP Đô thị Cần Thơ "
   , "UPCOM_UDC CTCP Xây dựng và Phát triển Đô thị Tỉnh Bà Rịa - Vũng Tàu "
   , "UPCOM_UDJ Công ty cổ phần Phát triển Đô Thị "
   , "UPCOM_UDL CTCP Đô thị và Môi trường Đắk Lắk "
   , "UPCOM_UEM CTCP Cơ điện Uông Bí - Vinacomin "
   , "UPCOM_UMC CTCP Công trình đô thị Nam Định "
   , "UPCOM_UPC CTCP Phát triển Công viên cây xanh và Đô thị Vũng Tàu "
   , "UPCOM_UPH CTCP Dược phẩm TW25 "
   , "UPCOM_USC CTCP Khảo sát và Xây dựng- USCO "
   , "UPCOM_USD CTCP Công trình Đô thị Sóc Trăng "
   , "UPCOM_UXC CTCP Chế biến Thủy sản Út Xi "
   , "UPCOM_V11 CTCP Xây dựng số 11 "
   , "UPCOM_V15 CÔNG TY CỔ PHẦN XÂY DỰNG SỐ 15 "
   , "UPCOM_VAV CTCP VIWACO "
   , "UPCOM_VBG CTCP Địa chất Việt Bắc- TKV "
   , "UPCOM_VBH CTCP Điện tử Bình Hòa "
   , "UPCOM_VC5 CTCP Xây dựng số 5 "
   , "UPCOM_VCE CTCP Xây lắp Môi trường "
   , "UPCOM_VCP CTCP Xây dựng và Năng lượng VCP "
   , "UPCOM_VCR CTCP Đầu tư và Phát triển Du lịch Vinaconex "
   , "UPCOM_VCT CTCP Tư vấn xây dựng Vinaconex "
   , "UPCOM_VCW CTCP Đầu tư Nước sạch Sông Đà "
   , "UPCOM_VCX Công ty cổ phần Xi măng Yên Bình "
   , "UPCOM_VDB CTCP Vận tải và Chế biến Than Đông Bắc "
   , "UPCOM_VDG CTCP Vạn Đạt Group "
   , "UPCOM_VDN CTCP Vinatex Đà Nẵng "
   , "UPCOM_VDT CTCP Lưới thép Bình Tây "
   , "UPCOM_VE2 CTCP Xây dựng điện VNECO 2 "
   , "UPCOM_VE9 CTCP Đầu tư và Xây dựng VNECO 9 "
   , "UPCOM_VEA Tổng công ty Máy động lực và Máy nông nghiệp Việt Nam - CTCP "
   , "UPCOM_VEC Tổng CTCP Điện tử và Tin học Việt Nam "
   , "UPCOM_VEF CTCP Trung tâm Hội chợ Triển lãm Việt Nam "
   , "UPCOM_VES CTCP Đầu tư và Xây dựng điện MÊ CA VNECO "
   , "UPCOM_VET CTCP Thuốc thú y Trung ương Navetco "
   , "UPCOM_VFC CTCP Vinafco "
   , "UPCOM_VFR CTCP Vận tải và Thuê tàu "
   , "UPCOM_VGG Tổng CTCP May Việt Tiến "
   , "UPCOM_VGI Tổng Công ty cổ phần Đầu tư Quốc tế Viettel "
   , "UPCOM_VGL CTCP Mạ kẽm công nghiệp Vingal-Vnsteel "
   , "UPCOM_VGR CTCP Cảng Xanh Vip "
   , "UPCOM_VGT Tập đoàn Dệt may Việt Nam "
   , "UPCOM_VGV Tổng công ty Tư vấn Xây dựng Việt Nam - CTCP "
   , "UPCOM_VHD CTCP Đầu tư Phát triển nhà và Đô thị VINAHUD "
   , "UPCOM_VHF CTCP Xây dựng và chế biến lương thực Vĩnh Hà "
   , "UPCOM_VHG CTCP Đầu tư và Phát triển Việt Trung Nam "
   , "UPCOM_VHH CTCP Đầu tư Kinh doanh nhà Thành Đạt "
   , "UPCOM_VIE CTCP Công nghệ Viễn thông VI TE CO "
   , "UPCOM_VIH CTCP Viglacera Hà Nội "
   , "UPCOM_VIM CTCP Khoáng sản Viglacera "
   , "UPCOM_VIN CTCP Giao nhận Kho vận Ngoại thương Việt Nam "
   , "UPCOM_VIR CTCP Du lịch quốc tế Vũng Tàu "
   , "UPCOM_VIW Tổng công ty Đầu tư Nước và Môi trường Việt Nam- CTCP "
   , "UPCOM_VKC CTCP VKC Holdings "
   , "UPCOM_VKP CTCP Nhựa Tân Hóa "
   , "UPCOM_VLB CTCP Xây dựng và Sản xuất vật liệu xây dựng Biên Hòa "
   , "UPCOM_VLC Tổng Công ty Chăn nuôi Việt Nam - CTCP "
   , "UPCOM_VLF CTCP Lương thực Thực phẩm Vĩnh Long "
   , "UPCOM_VLG CTCP VIMC Logistics "
   , "UPCOM_VLP CTCP Công trình công cộng Vĩnh Long "
   , "UPCOM_VLW CTCP Cấp nước Vĩnh Long "
   , "UPCOM_VMA CTCP Công nghiệp Ô tô - Vinacomin "
   , "UPCOM_VMG CTCP Thương mại và Dịch vụ Dầu khí Vũng Tàu "
   , "UPCOM_VMK Công ty Cổ phần Vimarko "
   , "UPCOM_VMT CTCP Giao nhận Vận tải Miền Trung "
   , "UPCOM_VNA CTCP Vận tải biển Vinaship "
   , "UPCOM_VNB CTCP Sách Việt Nam "
   , "UPCOM_VNH CTCP Đầu tư Việt Việt Nhật "
   , "UPCOM_VNI CTCP Đầu tư Bất động sản Việt Nam "
   , "UPCOM_VNP CTCP Nhựa Việt Nam "
   , "UPCOM_VNX CTCP Quảng cáo và Hội chợ thương mại Vinexad "
   , "UPCOM_VNY CTCP Thuốc thú y Trung ương I "
   , "UPCOM_VNZ Công ty cổ phần VNG "
   , "UPCOM_VOC Tổng công ty Công nghiệp Dầu thực vật Việt Nam – CTCP "
   , "UPCOM_VPA CTCP Vận tải Hóa dầu VP "
   , "UPCOM_VPC CTCP Đầu tư và Phát triển Năng lượng Việt Nam "
   , "UPCOM_VPR CTCP VINAPRINT "
   , "UPCOM_VPW CTCP Cấp thoát nước số I Vĩnh Phúc "
   , "UPCOM_VQC CTCP Giám định -Vinacomin "
   , "UPCOM_VRG CTCP Phát triển đô thị và Khu công nghiệp Cao su Việt Nam "
   , "UPCOM_VSE CTCP Dịch vụ Đường cao tốc Việt Nam "
   , "UPCOM_VSF Tổng công ty Lương thực Miền Nam - CTCP "
   , "UPCOM_VSG CTCP Container Phía Nam "
   , "UPCOM_VSN CTCP Việt Nam Kỹ nghệ Súc sản "
   , "UPCOM_VST CTCP Vận tải và Thuê tàu biển Việt Nam "
   , "UPCOM_VTA CTCP Vitaly "
   , "UPCOM_VTD CTCP Vietourist Holdings "
   , "UPCOM_VTE CTCP Vinacap Kim Long "
   , "UPCOM_VTG CTCP Du lịch tỉnh Bà Rịa - Vũng Tàu "
   , "UPCOM_VTI Công ty Cổ phần Sản xuất Xuất nhập khẩu Dệt may "
   , "UPCOM_VTK CTCP Tư vấn và Dịch vụ Viettel "
   , "UPCOM_VTL CTCP Vang Thăng Long "
   , "UPCOM_VTM CTCP Vận tải và Đưa đón Thợ mỏ-Vinacomin "
   , "UPCOM_VTQ CTCP Việt Trung Quảng Bình "
   , "UPCOM_VTR CTCP Du lịch và Tiếp thị Giao thông Vận tải Việt Nam - Vietravel "
   , "UPCOM_VTS CTCP Gạch ngói Từ Sơn "
   , "UPCOM_VTX CTCP Vận tải đa phương thức VIETRANSTIMEX "
   , "UPCOM_VUA CTCP Chứng khoán Stanley Brothers "
   , "UPCOM_VVN Tổng CTCP Xây dựng công nghiệp Việt Nam "
   , "UPCOM_VVS Công ty cổ phần Đầu tư Phát triển máy Việt Nam "
   , "UPCOM_VW3 CTCP Viwaseen3 "
   , "UPCOM_VWS CTCP Nước và Môi trường Việt Nam "
   , "UPCOM_VXB CTCP Vật liệu xây dựng Bến tre "
   , "UPCOM_VXP CTCP Thuốc thú y Trung ương VETVACO "
   , "UPCOM_VXT CTCP Kho vận và Dịch vụ Thương mại "
   , "UPCOM_WSB Công ty Cổ phần Bia Sài Gòn - Miền Tây "
   , "UPCOM_WTC CTCP Vận tải thủy Vinacomin "
   , "UPCOM_X26 CTCP 26 "
   , "UPCOM_X77 CTCP Thành An 77 "
   , "UPCOM_XDH CTCP Đầu tư Xây dựng Dân dụng Hà Nội "
   , "UPCOM_XHC CTCP Xuân Hòa Việt Nam "
   , "UPCOM_XLV CTCP Xây lắp và dịch vụ Sông Đà "
   , "UPCOM_XMC CTCP Ðầu tư và Xây dựng Xuân Mai "
   , "UPCOM_XMD CTCP Xuân Mai - Đạo Tú "
   , "UPCOM_XMP CTCP Thủy điện Xuân Minh "
   , "UPCOM_XPH CTCP Xà phòng Hà Nội "
   , "UPCOM_YBC CTCP Xi măng và Khoáng sản Yên Bái "
   , "UPCOM_YTC CTCP Xuất nhập khẩu Y tế Thành phố Hồ Chí Minh "
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
