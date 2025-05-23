//+------------------------------------------------------------------+
//|                                               ConnectBinance.mq5 |
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
#define BtnCkH4_                    "BtnCkH4_"
#define BtnDrawCkMonthly            "BtnDrawCkMonthly"
#define BtnDrawCkWeekly             "BtnDrawCkWeekly"
#define BtnDrawCk4hours             "BtnDrawCk4hours"
#define BtnCkLink_                  "BtnCkLink_"
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
#define CLICKED_SYMBOL_TYPE        "CLICKED_TYPE"
#define CLICKED_SYMBOL_CK_INDEX    "CLICKED_CK_INDEX"
#define CLICKED_SYMBOL_COIN_INDEX  "CLICKED_COIN_INDEX"
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
#define BtnFilterCondM1C1         BtnFilter_+"CondM1C1"
#define BtnFilterCondW1C3         BtnFilter_+"CondW1C3"
#define BtnFilterCondW1C1         BtnFilter_+"CondW1C1"
#define BtnFilterCondD1C2         BtnFilter_+"CondD1C2"
#define BtnFilterCondH4C3         BtnFilter_+"CondH4C3"
#define BtnFilterCondH4Sq         BtnFilter_+"CondH4Sq"
#define BtnFilterCondH450         BtnFilter_+"CondH450"
#define BtnFilter1BilVnd          BtnFilter_+"1BilVnd"
#define BtnToutch_                "BtnToutch_"
const string TREND_BUY="BUY";
const string TREND_SEL="SELL";
const string STR_SEQ_BUY="SeqBuy";
const string STR_SEQ_SEL="SeqSel";
const string MASK_TOUCH_MA50="|50|";
datetime TIME_OF_ONE_H1_CANDLE=3600;
datetime TIME_OF_ONE_H4_CANDLE=14400;
datetime TIME_OF_ONE_D1_CANDLE=86400;
datetime TIME_OF_ONE_W1_CANDLE=604800;
color clrActiveBtn = clrLightGreen;
color clrActiveSell= clrMistyRose;
const int BTN_PER_COLUMN=36;
const int NUM_CANDLE_DRAW=21;
const double SYMBOL_TYPE_CK=12.0;
const double SYMBOL_TYPE_COIN=34567.0;
const double FILTER_NON=111;
const double FILTER_BUY=333;
const double FILTER_SEL=555;
const double FILTER_ON =777;
const double OPTION_FOLOWING=111.1;
const double VOL_1BILLION_VND=1000000000;
const string LESS_THAN_20_BIL_VND="<20b";
const string MORE_THAN_1_BIL_VND=">1ty";
const string LESS_THAN_1_BIL_VND="<1ty";
const string GROUP_PHANBON="(Phân)";
const string GROUP_NGANHANG="(Bank)";
const string GROUP_CHUNGKHOAN="(CK)";
const string GROUP_BATDONGSAN="(BĐS)";
const string GROUP_DUOCPHAM="(Dược)";
const string GROUP_DAUKHI="(XTI)";
const string GROUP_THEP="(Thép)";
const string GROUP_CONGNGHIEP="(Công)";
const string GROUP_MAYMAC="(May)";
const string GROUP_DIEN="(Điện)";
const string GROUP_DAVINCI="(Davinci)";
const string GROUP_OTHERS="(Others)";

const string NEW_LIST=", ARBUSDT, STRKUSDT, PYTHUSDT, SEIUSDT, ACTUSDT, CETUSUSDT, COWUSDT, PNUTUSDT, KAIAUSDT, ACTUSDT, CETUSUSDT, COWUSDT, PNUTUSDT, AXLUSDT, ZKUSDT"+
                      ", DYMUSDT, BLURUSDT, EDUUSDT, ENAUSDT, ERNUSDT, FLUXUSDT, FORTHUSDT, GUSDT, HOOKUSDT, LUMIAUSDT, PDAUSDT, USUALUSDT, VICUSDT, AIUSDT";

string ARR_SYMBOLS_COIN[] =
  {
   "BTCUSDT","ETHUSDT",
   "ACEUSDT","ACTUSDT","AERGOUSDT","AEVOUSDT","AGLDUSDT","AIUSDT","ALCXUSDT","ALPINEUSDT","ALTUSDT","AMBUSDT","AMPUSDT",
   "APTUSDT","ARBUSDT","ARKMUSDT","ARKUSDT","ASTUSDT","AXLUSDT","BBUSDT","BEAMXUSDT","BLURUSDT","BNBUSDT",
   "BONKUSDT","BSWUSDT","CATIUSDT","CETUSUSDT","COMBOUSDT","COWUSDT","CREAMUSDT","CYBERUSDT","DIAUSDT",
   "DOGEUSDT","DOGSUSDT","DYMUSDT","EIGENUSDT","ENAUSDT","ERNUSDT","FETUSDT",
   "FISUSDT","FLOKIUSDT","FLUXUSDT","FORTHUSDT","FTMUSDT","GASUSDT","GLMUSDT","GMTUSDT","GNSUSDT","GUSDT",
   "HIFIUSDT","HOOKUSDT","IDUSDT","IQUSDT","JTOUSDT","JUPUSDT","KAIAUSDT","KDAUSDT",
   "LDOUSDT","LINKUSDT","LISTAUSDT","LQTYUSDT","LTCUSDT","LUMIAUSDT","LUNCUSDT","MAGICUSDT","MANTAUSDT","MASKUSDT","MAVUSDT",
   "MEMEUSDT","METISUSDT","MINAUSDT","NEIROUSDT","NEXOUSDT","NFPUSDT","NOTUSDT","NTRNUSDT","OGUSDT","OMNIUSDT","OMUSDT",
   "OPUSDT","ORDIUSDT","OSMOUSDT","PAXGUSDT","PDAUSDT","PENDLEUSDT","PEOPLEUSDT","PEPEUSDT","PHBUSDT",
   "PIVXUSDT","PIXELUSDT","PNUTUSDT","POLUSDT","POLYXUSDT","PORTALUSDT","PORTOUSDT","POWRUSDT","PROMUSDT","PROSUSDT","PSGUSDT","PUNDIXUSDT",
   "PYRUSDT","PYTHUSDT","QIUSDT","QKCUSDT","QUICKUSDT","RADUSDT","RAREUSDT","RDNTUSDT","REIUSDT","RENUSDT",
   "REQUSDT","REZUSDT","RONINUSDT","RPLUSDT","SAGAUSDT","SANTOSUSDT","SCRTUSDT","SCRUSDT","SEIUSDT","SHIBUSDT","SLFUSDT","SNTUSDT",
   "SOLUSDT","SPELLUSDT","STEEMUSDT","STGUSDT","STRAXUSDT","STRKUSDT","STXUSDT","SUIUSDT","SYNUSDT","THEUSDT","TIAUSDT","TKOUSDT","TNSRUSDT",
   "TONUSDT","TRUUSDT","TURBOUSDT","TWTUSDT","UFTUSDT","UMAUSDT","USUALUSDT","USTCUSDT","VANRYUSDT","VIBUSDT","VICUSDT","VIDTUSDT","VITEUSDT",
   "WAXPUSDT","WIFUSDT","WUSDT","XLMUSDT","XRPUSDT","XVGUSDT","ZKUSDT","ZROUSDT"
  };

string ARR_SYMBOLS_CK[] =
  {
   "HOSE_VNINDEX","HOSE_AAA","HOSE_ACB","HOSE_AGR","HOSE_ANV","HOSE_ASM","HOSE_BCM","HOSE_BID","HOSE_BMP","HOSE_BSI","HOSE_BVH","HOSE_BWE","HOSE_CCL","HOSE_CII"
   ,"HOSE_CMG","HOSE_CRE","HOSE_CTD","HOSE_CTG","HOSE_CTR","HOSE_D2D","HOSE_DBC","HOSE_DCM","HOSE_DGC","HOSE_DGW","HOSE_DIG","HOSE_DPM","HOSE_DXG","HOSE_DXS"
   ,"HOSE_EIB","HOSE_EVF","HOSE_FPT","HOSE_FRT","HOSE_FTS","HOSE_GAS","HOSE_GEX","HOSE_GMD","HOSE_GVR","HOSE_HAG","HOSE_HCM","HOSE_HDB","HOSE_HDC","HOSE_HDG"
   ,"HOSE_HPG","HOSE_HSG","HOSE_HT1","HOSE_HVN","HOSE_IMP","HOSE_KBC","HOSE_KDC","HOSE_KDH","HOSE_LHG","HOSE_LPB","HOSE_MBB","HOSE_MSB","HOSE_MSH","HOSE_MSN","HOSE_MWG"
   ,"HOSE_NHA","HOSE_NKG","HOSE_NLG","HOSE_NT2","HOSE_NTL","HOSE_NVL","HOSE_OCB","HOSE_IJC","HOSE_PC1","HOSE_PDR","HOSE_PHR","HOSE_PLX","HOSE_PNJ","HOSE_POW","HOSE_PPC"
   ,"HOSE_PVP","HOSE_PVD","HOSE_PVT","HOSE_QCG","HOSE_REE","HOSE_SAB","HOSE_SBT","HOSE_SCS","HOSE_SHB","HOSE_SIP","HOSE_SJS","HOSE_SSB","HOSE_SSI","HOSE_STB","HOSE_SZC"
   ,"HOSE_TCB","HOSE_TCH","HOSE_TCM","HOSE_TLG","HOSE_TPB","HOSE_VCB","HOSE_VCG","HOSE_VCI","HOSE_VGC","HOSE_VHC","HOSE_VHM","HOSE_VIB","HOSE_VIC","HOSE_VIX"
   ,"HOSE_FCN","HOSE_KSB","HOSE_HHV","HOSE_CKG","HOSE_BFC"
   ,"HOSE_VJC","HOSE_TDC","HOSE_VNM","HOSE_VPB","HOSE_VRE","HOSE_VSH"
   ,"HOSE_OGC","HOSE_BAF","HOSE_SKG","HOSE_CSM","HOSE_TNH"

   ,"HNX_MBS","HNX_TNG","HNX_PVS","HNX_VC7","HNX_AAV","HNX_DTD","HNX_LAS","HNX_MST","HNX_IDC","HNX_NVB","HNX_VC3","HNX_BAB", "HNX_VGS"
   ,"HNX_BCC", "HNX_BVS", "HNX_CAP", "HNX_DVM", "HNX_HUT", "HNX_LHC", "HNX_NBC", "HNX_PLC", "HNX_PVC", "HNX_SHS", "HNX_SLS", "HNX_TIG", "HNX_TVD", "HNX_VCS", "HNX_VIG"

   ,"UPCOM_ABB","UPCOM_BVB","UPCOM_KLB","UPCOM_SGB","UPCOM_HBC","UPCOM_MSR","UPCOM_VGT","UPCOM_HNG"
   ,"UPCOM_VEA", "UPCOM_MCH", "UPCOM_MML", "UPCOM_FOX", "UPCOM_TVN"
  };

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

   double top_price = ChartGetDouble(0, CHART_PRICE_MAX);  // Giá tại đỉnh biểu đồ
   double bottom_price = ChartGetDouble(0, CHART_PRICE_MIN); // Giá tại đáy biểu đồ
   double one_percent = (top_price-bottom_price)/20;
   SetGlobalVariable(BTC_PRICE_HIG,top_price-one_percent);
   SetGlobalVariable(BTC_PRICE_LOW,bottom_price+one_percent);

   Draw_Buttons();

   EventSetTimer(10); // Mỗi 10 giây gọi lại OnTimer
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Buttons()
  {
   int size_ck =ArraySize(ARR_SYMBOLS_CK);
   int size = ArraySize(ARR_SYMBOLS_COIN);

   int btn_width = 180;
   int column[9]; // Mảng để lưu vị trí cột
   for(int i = 0; i < 9; i++)
      column[i] = 30+i*(btn_width+135); // Tính toán khoảng cách cột

   int count_btn = 0;
   int y_dimention_base = 50; // Độ lệch theo chiều dọc cơ bản
   int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))-30;
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
   int x_mwhlinkclear=column[8];
   int clicked_ck_index=(int)GetGlobalVariable(CLICKED_SYMBOL_CK_INDEX);
   if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==-1)
      SetGlobalVariable(CLICKED_SYMBOL_TYPE,SYMBOL_TYPE_CK);

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
   bool FilterCondM1C1=GetGlobalVariable(BtnFilterCondM1C1)==FILTER_ON?true:false;
   bool FilterCondW1C3=GetGlobalVariable(BtnFilterCondW1C3)==FILTER_ON?true:false;
   bool FilterCondW1C1=GetGlobalVariable(BtnFilterCondW1C1)==FILTER_ON?true:false;
   bool FilterCondD1C2=GetGlobalVariable(BtnFilterCondD1C2)==FILTER_ON?true:false;
   bool FilterCondH4C3=GetGlobalVariable(BtnFilterCondH4C3)==FILTER_ON?true:false;
   bool FilterCondH4Sq=GetGlobalVariable(BtnFilterCondH4Sq)==FILTER_ON?true:false;
   bool FilterCondH4Ma50=GetGlobalVariable(BtnFilterCondH450)==FILTER_ON?true:false;
   bool Filter1BilVnd=GetGlobalVariable(BtnFilter1BilVnd)==FILTER_ON?true:false;

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

   int search_x=60*41,search_y=2;
   createButton(BtnFilterTrading,"Trade",(int)(search_x-60*2),search_y,50,30,clrBlack,is_filter_trading?clrActiveBtn:clrWhite,8);
   createButton(BtnFilterToday,"Today?",   search_x-60,  search_y,50,30,clrBlack,clrWhite,8);
   create_TextInput(search_x,search_y,150,30);
   createButton(BtnSearchSymbol,"Search",  search_x+160, search_y,50,30,clrBlack,clrWhite,8);
   string fillterSymbol=GetTextInput();
   createButton(BtnFilterClear,"Clear",    search_x+220, search_y,50,30,clrBlack,clrWhite,8);

   string sorted_symbols_ck[];
   SortSymbols(sorted_symbols_ck);

   if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_CK)

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
            if(FilterCondM383 && is_same_symbol(low_hig_mo,"#382")==false)
               continue;

            if(FilterCondM1C1 && !(count_ma10_mo<=1 && is_same_symbol(trend_ma10_mo,TREND_BUY))) // || count_hei_w1<=2
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

            if(FilterCondW1C1 && !(count_ma10_w1<=1 && is_same_symbol(trend_ma10_w1,TREND_BUY)))
               continue;

            if(FilterCondW1C3 && !(count_ma10_w1<=3 && is_same_symbol(trend_ma10_w1,TREND_BUY)))
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


         if(FilterCondH4Ma50 && is_same_symbol(low_hig_h4,MASK_TOUCH_MA50)==false)
            continue;


         bool is_alert_weekly= (is_same_symbol(trend_ma10_w1,TREND_BUY) && count_ma10_w1<=3);
         bool is_exist_now=false;
         bool is_exist_by_heiken=false;
         bool is_h4_seq_buy=is_same_symbol(low_hig_h4,STR_SEQ_BUY);
         bool is_h4_seq_sel=is_same_symbol(low_hig_h4,STR_SEQ_SEL);

         //if(is_trading_this_symbol==false)
           {
            if(FilterCondH4C3 && !(count_ma10_h4<=3 && is_same_symbol(trend_ma10_h4,TREND_BUY)))  //|| count_hei_h4<=3
               continue;

            if((trend_ma10_h4!="") && FilterCondH4 && is_same_symbol(trend_ma10_h4,TREND_BUY)==false)
               continue;

            if(FilterCondH4Sq && (is_h4_seq_buy==false || is_same_symbol(trend_hei_h4, TREND_BUY)==false))
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
         int y_dimention = y_dimention_base + 30*((count_btn-1) % BTN_PER_COLUMN);

         string btn_d1_name=BtnCkD1_+symbolCk;
         if(is_folowing_this_symbol)
            createButton("BtnCkFolowing"+symbolCk,"^ ^",column[col_index]-19,y_dimention,18,20,clrBlack,clrActiveBtn);

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
         for(int b=1;b<=25;b++)
           {
            StringReplace(low_hig_mo,"  "," ");
            StringReplace(low_hig_mo,"{B"+IntegerToString(b)+"}","");
            StringReplace(low_hig_mo,"{S"+IntegerToString(b)+"}","");
           }

         createButton(btn_d1_name,append1Zero(count)+". "+btn_label+low_hig_mo,column[col_index],y_dimention,btn_width,20,text_color,bg_color,6);

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
            createButton(BtnCkD1_ + symbolCk+"_","",column[col_index],y_dimention+19,btn_width+80,3,clrBlack,clrBlue);

         color clr_color_h4=clrLightGray;
         if((count_ma10_h4<=3) && is_same_symbol(trend_ma10_h4,TREND_BUY))
            clr_color_h4=clrActiveBtn;
         if(is_trading_this_symbol && is_same_symbol(trend_ma10_h4,TREND_SEL))
            clr_color_h4=clrRed;
         if(is_exist_now)
            clr_color_h4=clrRed;
         createButton(BtnCkH4_ + symbolCk,"H4."+getShortName(trend_ma10_h4)+"."+(string)count_ma10_h4,column[col_index]+btn_width+5, y_dimention,50,20,clrBlack,clr_color_h4);

         createButton(BtnCkLink_ + symbolCk,lblCkLink,column[col_index]+btn_width+60, y_dimention,20,20,clrBlack,clrLinkCk);

         if(PERCENT_LOW<15)
            createButton(BtnCkLink_ + symbolCk+"<10%",DoubleToString(PERCENT_LOW,1)+"%",column[col_index]+btn_width+80, y_dimention,35,20,clrBlack,clrWhite,6);
        }
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
   count=0;
   int clicked_index=(int)GetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX);
   int last_load_data_index = (int)GetGlobalVariable(LAST_CHECKED_BINANCE_INDEX);

   if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
      for(int i = 0; i < size; i++)
        {
         string symbolUsdt = ARR_SYMBOLS_COIN[i];
         if(symbolUsdt=="")
            continue;

         if(fillterSymbol!="" && is_same_symbol(symbolUsdt,fillterSymbol)==false)
            continue;

         bool is_trading_this_symbol=GetGlobalVariable(BtnTrading_+symbolUsdt)==OPTION_FOLOWING;
         bool is_folowing_this_symbol=is_trading_this_symbol || GetGlobalVariable(BtnFollowing_+symbolUsdt)==OPTION_FOLOWING;

         if(is_filter_trading && is_trading_this_symbol==false)
            continue;

         if(is_only_follow)
            if(is_folowing_this_symbol==false)
               continue;

         string trend_ma20_w1,trend_ma20_d1,trend_ma20_h4;

         string trend_ma10_w1, trend_hei_w1, trend_ma5_w1,low_hig_w1;
         int count_ma10_w1, count_hei_w1;
         double PERCENT_LOW_W1, PERCENT_HIG_W1;
         GetTrendFromFileCk("BINANCE_"+symbolUsdt,PERIOD_W1,trend_ma20_w1,trend_ma10_w1, count_ma10_w1, trend_hei_w1, count_hei_w1,trend_ma5_w1,low_hig_w1,PERCENT_LOW_W1,PERCENT_HIG_W1);

         if(is_trading_this_symbol==false)
           {
            if(count_ma10_w1==-1)
               continue;

            if(FilterCondW1C3 && !(count_ma10_w1<=3 && is_same_symbol(trend_ma10_w1,TREND_BUY) && is_same_symbol(trend_hei_w1,TREND_BUY)))
               continue;

            if((trend_ma10_w1!="") && FilterCondW1 && is_same_symbol(trend_ma10_w1,TREND_BUY)==false)
               continue;

            if(FilterCondW20 && is_same_symbol(low_hig_w1,"#382")==false)
               continue;
           }

         string trend_ma10_d1, trend_hei_d1, trend_ma5_d1,low_hig_d1;
         int count_ma10_d1, count_hei_d1;
         double PERCENT_LOW_D1, PERCENT_HIG_D1;
         GetTrendFromFileCk("BINANCE_"+symbolUsdt,PERIOD_D1,trend_ma20_d1,trend_ma10_d1, count_ma10_d1, trend_hei_d1, count_hei_d1,trend_ma5_d1,low_hig_d1,PERCENT_LOW_D1,PERCENT_HIG_D1);

         if(is_trading_this_symbol==false)
           {
            if(FilterCondD1C2 && !((count_ma10_d1<=3 && is_same_symbol(trend_ma10_d1,TREND_BUY) && is_same_symbol(trend_hei_d1,TREND_BUY))))
               continue;

            if(FilterCondD1 && !((is_same_symbol(trend_ma10_d1,TREND_BUY) && is_same_symbol(trend_hei_d1,TREND_BUY))))
               continue;

            if(FilterCondD20 && is_same_symbol(trend_ma20_d1,TREND_BUY)==false)
               continue;
           }

         string trend_ma10_h4, trend_hei_h4, trend_ma5_h4,low_hig_h4;
         int count_ma10_h4, count_hei_h4;
         double PERCENT_LOW_H4, PERCENT_HIG_H4;
         GetTrendFromFileCk("BINANCE_"+symbolUsdt,PERIOD_H4,trend_ma20_h4,trend_ma10_h4, count_ma10_h4, trend_hei_h4, count_hei_h4,trend_ma5_h4,low_hig_h4,PERCENT_LOW_H4,PERCENT_HIG_H4);

         bool is_h4_seq_buy=is_same_symbol(low_hig_h4,STR_SEQ_BUY);
         bool is_new_list  =is_same_symbol(NEW_LIST," "+symbolUsdt);
         bool wd_buy=(trend_ma10_w1==TREND_BUY) && (count_ma10_w1<=3);

         if(is_trading_this_symbol==false)
           {
            if(FilterCondH4Sq && (is_h4_seq_buy==false || is_same_symbol(trend_hei_h4, TREND_BUY)==false))
               continue;

            if((trend_ma10_h4!="") && FilterCondH4 && is_same_symbol(trend_ma10_h4,TREND_BUY)==false)
               continue;

            if(FilterCondH4C3 && !(count_ma10_h4<=3 && is_same_symbol(trend_ma10_h4,TREND_BUY)))  //|| count_hei_h4<=3
               continue;
           }

         count_btn+=1;
         int col_index = (count_btn - 1) / BTN_PER_COLUMN; // Xác định cột dựa trên count_btn
         int y_dimention = y_dimention_base + 30 * ((count_btn-1) % BTN_PER_COLUMN); // Tính toán vị trí y trong cột hiện tại


         string btn_label=" "+(symbolUsdt)
                          + " w."+getShortName(trend_ma10_w1)+"."+(string)count_ma10_w1
                          + (is_new_list?" (*)":"");

         color bg_color=clicked_index==i?clrYellow:is_same_symbol(trend_ma10_w1,TREND_BUY)?clrActiveBtn:clrActiveSell;
         if(is_trading_this_symbol)
            bg_color=is_same_symbol(trend_ma10_w1,TREND_BUY)?clrHoneydew:clrActiveSell;
         if(!(count_ma10_w1<=2))
            bg_color=clrLightGray;

         if(PERCENT_LOW_W1*2<PERCENT_HIG_W1)
            bg_color=clrLightGray;
         color text_color=clrBlack;
         if(PERCENT_LOW_W1<PERCENT_HIG_W1/3)
            text_color=clrBlue;
         bg_color=clicked_index==i?clrYellow:bg_color;

         if(is_folowing_this_symbol)
            createButton("BtnCoinFolowing"+symbolUsdt,"^ ^",column[col_index]-19,y_dimention,18,20,clrBlack,clrActiveBtn);

         count+=1;
         string btn_d1_name=BtnD1_+symbolUsdt;
         StringReplace(btn_label,"USDT","");
         createButton(btn_d1_name,append1Zero(count)+". "+btn_label+low_hig_w1,column[col_index],y_dimention,btn_width,20,text_color,bg_color,6);

         if(i==clicked_index)
           {
            ObjectSetString(0,btn_d1_name,OBJPROP_FONT,"Arial Bold");

            clrFolowing=GetGlobalVariable(BtnFollowing_+symbolUsdt)==OPTION_FOLOWING?clrActiveBtn:clrLightGray;
            clrTrading=is_trading_this_symbol?clrActiveBtn:clrLightGray;
           }

         if(count_ma10_w1==-1)
            ObjectSetInteger(0,btn_d1_name,OBJPROP_BGCOLOR,clrDimGray);

         createButton(BtnD1_ + symbolUsdt+">","",column[col_index]-10,y_dimention+6,7,7,clrWhite,(i<=last_load_data_index)?clrBlack:clrNONE);

         if(is_trading_this_symbol)
            createButton(BtnD1_ + symbolUsdt+"_","",column[col_index],y_dimention+20,btn_width+80,5,clrBlack,clrBlue);

         string lblH4="D."+getShortName(trend_ma10_d1)+"."+(string)count_ma10_d1;
         color clr_color_h4=is_same_symbol(trend_ma10_d1,TREND_BUY)&&count_ma10_d1<=3?clrActiveBtn:clrLightGray;
         createButton(BtnH4_ + symbolUsdt,lblH4,column[col_index]+btn_width+5, y_dimention,50,20,clrBlack,clr_color_h4);

         createButton(BtnLink_ + symbolUsdt,"...",column[col_index]+btn_width+60, y_dimention,20,20,clrBlack,clrWhite);
        }
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
   double intPeriod = GetGlobalVariable(BtnOptionPeriod);
   if(intPeriod<0)
     {
      intPeriod = PERIOD_D1;
      SetGlobalVariable(BtnOptionPeriod,(double)intPeriod);
     }

   btn_width=30;
   createButton(BtnOptionPeriod+"_3M",  "3M",10+0*(btn_width+10),chart_heigh,30,19,clrBlack,intPeriod==PERIOD_M3 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_MN1", "Mo",10+1*(btn_width+10),chart_heigh,30,19,clrBlack,intPeriod==PERIOD_MN1?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_W1",  "W1",10+2*(btn_width+10),chart_heigh,30,19,clrBlack,intPeriod==PERIOD_W1 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_D1",  "D1",10+3*(btn_width+10),chart_heigh,30,19,clrBlack,intPeriod==PERIOD_D1 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_H4",  "H4",10+4*(btn_width+10),chart_heigh,30,19,clrBlack,intPeriod==PERIOD_H4 ?clrActiveBtn:clrWhite,7);
   createButton(BtnOptionPeriod+"_H1",  "H1",10+5*(btn_width+10),chart_heigh,30,19,clrBlack,intPeriod==PERIOD_H1 ?clrActiveBtn:clrWhite,7);

   createButton(BtnSaveResult,   "Save",                   10+5*(btn_width+10)+120,chart_heigh,100,19,clrBlack,clrWhite,7);
   createButton(BtnLoadResult,   "Load",                   10+5*(btn_width+10)+230,chart_heigh,100,19,clrBlack,clrWhite,7);

   string market=(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_CK)?"CK":"COIN";
   createButton(BtnMarketType,market,        2,2, 60,30,clrBlack,clrActiveBtn,8);
   createButton(BtnFilterFollow,"^ ^ Only",   70,2, 60,30,clrBlack,is_only_follow?clrActiveBtn:clrLightGray,8);

   color clrW20=FilterCondW20?clrActiveBtn:clrLightGray;
   color clrD20=FilterCondD20?clrActiveBtn:clrLightGray;
   color clr3M=FilterCond3M?clrActiveBtn:clrLightGray;
   color clrMo=FilterCondMO?clrActiveBtn:clrLightGray;
   color clrW1=FilterCondW1?clrActiveBtn:clrLightGray;
   color clrD1=FilterCondD1?clrActiveBtn:clrLightGray;
   color clrH4=FilterCondH4?clrActiveBtn:clrLightGray;

   if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_CK)
     {
      createButton(BtnMakeSymbolsJson, "-> symbols.json",     10+5*(btn_width+10)+340,chart_heigh,100,19,clrBlack,clrWhite,7);


      int x_start=400;
      createButton(BtnFilterVn30,"Vn30",     x_start+30-60*4,2,50,30,clrBlack,is_vn30?clrActiveBtn:clrLightGray,8);
      createButton(BtnFilterHnx30,"Hnx30",   x_start+30-60*3,2,50,30,clrBlack,is_hnx30?clrActiveBtn:clrLightGray,8);
      createButton(BtnFilterCondM383,"#382", x_start+30-60*2,2,50,30,clrBlack,FilterCondM383?clrActiveBtn:clrLightGray,8);

      count+=1;
      int count=0;
      createButton(BtnFilterMa20Mo,"20M", x_start+60*count,2,50,30,clrBlack,clr3M,8);
      count+=1;
      createButton(BtnFilterMa10Mo,"10M", x_start+60*count,2,50,30,clrBlack,clrMo,8);
      count+=1;
      createButton(BtnFilterMa10W1,"10W", x_start+60*count,2,50,30,clrBlack,clrW1,8);
      count+=1;
      createButton(BtnFilterMa10H4,"10H4",x_start+60*count,2,50,30,clrBlack,clrH4,8);
      count+=1;

      count+=1;
      createButton(BtnFilterHistMo,"His.Mo",x_start+60*count,2,50,30,clrBlack,FilterHistMo?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterHistWx,"His.Wx",x_start+60*count,2,50,30,clrBlack,FilterHistWx?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterHistHx,"His.Hx",x_start+60*count,2,50,30,clrBlack,FilterHistHx?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterHistM3,"His.M3",x_start+60*count,2,50,30,clrBlack,FilterHistM3?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterHistM1,"His.M1",x_start+60*count,2,50,30,clrBlack,FilterHistM1?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterHistW3,"His.W3",x_start+60*count,2,50,30,clrBlack,FilterHistW3?clrActiveBtn:clrLightGray,8);
      count+=1;

      count+=1;
      createButton(BtnFilterCondM1C1,"M.C1", x_start+60*count,2,50,30,clrBlack,FilterCondM1C1?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterCondW1C3,"W.C3", x_start+60*count,2,50,30,clrBlack,FilterCondW1C3?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterCondW1C1,"W.C1", x_start+60*count,2,50,30,clrBlack,FilterCondW1C1?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterCondH4Sq,"H4Seq",x_start+60*count,2,50,30,clrBlack,FilterCondH4Sq?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterCondH4C3,"H4.C3",x_start+60*count,2,50,30,clrBlack,FilterCondH4C3?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilterCondH450,"H4.50",x_start+60*count,2,60,30,clrBlack,FilterCondH4Ma50?clrActiveBtn:clrLightGray,8);
      count+=1;

      count+=1;
      createButton("GROUP_"+GROUP_NGANHANG,GROUP_NGANHANG,     x_start+60*count,2,50,30,clrBlack,IS_GROUP_NGANHANG?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_DAUKHI,GROUP_DAUKHI,         x_start+60*count,2,50,30,clrBlack,IS_GROUP_DAUKHI?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_CHUNGKHOAN,GROUP_CHUNGKHOAN, x_start+60*count,2,50,30,clrBlack,IS_GROUP_CHUNGKHOAN?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_BATDONGSAN,GROUP_BATDONGSAN, x_start+60*count,2,50,30,clrBlack,IS_GROUP_BATDONGSAN?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_DUOCPHAM,GROUP_DUOCPHAM,     x_start+60*count,2,50,30,clrBlack,IS_GROUP_DUOCPHAM?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_PHANBON,GROUP_PHANBON,       x_start+60*count,2,50,30,clrBlack,IS_GROUP_PHANBON?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_THEP,GROUP_THEP,             x_start+60*count,2,50,30,clrBlack,IS_GROUP_THEP?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_CONGNGHIEP,GROUP_CONGNGHIEP, x_start+60*count,2,50,30,clrBlack,IS_GROUP_CONGNGHIEP?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_MAYMAC,GROUP_MAYMAC,         x_start+60*count,2,50,30,clrBlack,IS_GROUP_MAYMAC?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_DIEN,GROUP_DIEN,             x_start+60*count,2,50,30,clrBlack,IS_GROUP_DIEN?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_DAVINCI,GROUP_DAVINCI,       x_start+60*count,2,50,30,clrBlack,IS_GROUP_DAVINCI?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton("GROUP_"+GROUP_OTHERS,GROUP_OTHERS,         x_start+60*count,2,50,30,clrBlack,IS_GROUP_OTHERS?clrActiveBtn:clrLightGray,8);
      count+=1;
      createButton(BtnFilter1BilVnd,"h4≧1b",x_start+60*count,2,60,30,clrBlack,Filter1BilVnd?clrActiveBtn:clrLightGray,8);
      count+=1;
     }

   if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
     {
      createButton(BtnFilterCondW20,"#382", 400-60*3,2,50,30,clrBlack,clrW20,8);
      createButton(BtnFilterD20,"D20.B", 400-60*2,2,50,30,clrBlack,clrD20,8);

      createButton(BtnFilterMa10W1,"10W",       400+60*0,2,50,30,clrBlack,clrW1,8);
      createButton(BtnFilterMa10D1,"10D",      400+60*1,2,50,30,clrBlack,clrD1,8);
      createButton(BtnFilterMa10H4,"10H4",       400+60*2,2,50,30,clrBlack,clrH4,8);

      createButton(BtnFilterCondW1C3,"W3Buy",400+60*4,2,50,30,clrBlack,FilterCondW1C3?clrActiveBtn:clrLightGray,8);
      createButton(BtnFilterCondD1C2,"D3Buy",400+60*5,2,50,30,clrBlack,FilterCondD1C2?clrActiveBtn:clrLightGray,8);
      createButton(BtnFilterCondH4Sq,"H4Seq",400+60*6,2,50,30,clrBlack,FilterCondH4Sq?clrActiveBtn:clrLightGray,8);
      createButton(BtnFilterCondH4C3,"H4C3", 400+60*7,2,50,30,clrBlack,FilterCondH4C3?clrActiveBtn:clrLightGray,8);
      createButton(BtnFilterCondH450,"H4.50",400+60*8,2,60,30,clrBlack,FilterCondH4Ma50?clrActiveBtn:clrLightGray,8);


      int clicked_index=(int)GetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX);
      if(clicked_index>0)
        {
         string symbolUsdt=ARR_SYMBOLS_COIN[clicked_index];
         ReDrawChartCoin(symbolUsdt);
        }
     }

   int x_start = (int)chart_width/2+200;

   createButton(BtnToutch_+"up_ck",     "Up",   x_start+00,chart_heigh-3, 35,30,clrBlack,clrWhite,8);
   createButton(BtnToutch_+"dn_ck",     "Dn",   x_start+45,chart_heigh-3, 35,30,clrBlack,clrWhite,8);

   createButton(BtnTrading_,     "Trading",      x_start+100,chart_heigh-3, 90,30,clrBlack,clrTrading,8);
   createButton(BtnFollowing_,   "Following",    x_start+200,chart_heigh-3, 90,30,clrBlack,clrFolowing,8);
   createButton(BtnClearChart,   "Clear Chart",  x_start+300,chart_heigh-3, 90,30,clrBlack,clrWhite,8);
   createButton(BtnCkTradingView,"Trading View", x_start+400,chart_heigh-3,100,30,clrBlack,clrWhite,8);
   if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
     {
      createButton(BtnManualLoadData,"Load Data",x_start+600,  chart_heigh-3,100,30,clrBlack,clrWhite,8);
      createButton(BtnResetLoadData,"Reset",    chart_width-60,chart_heigh-3,50,30,clrBlack,clrWhite,8);
     }

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string cur_ydd=get_ydd(TimeCurrent());

   datetime vietnamTime=TimeGMT()+7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(vietnamTime,time_struct);

   int time_per_minus = (int)GetGlobalVariable(REQUEST_BINANCE_PER_MINUS);
   if(time_per_minus<0)
     {
      time_per_minus=1;
      SetGlobalVariable(REQUEST_BINANCE_PER_MINUS,1);
     }

   int cur_minute = time_struct.min;
   int last_checked_minute = (int)GetGlobalVariable("timer_three_min");
   SetGlobalVariable("timer_three_min", cur_minute);

   int size = ArraySize(ARR_SYMBOLS_COIN);
   bool checked_all_symbol=is_checked_all_symbols();
   if((cur_minute%1==0) && (cur_minute!=last_checked_minute))
     {
      int last_load_data_index = (int)GetGlobalVariable(LAST_CHECKED_BINANCE_INDEX);
      last_load_data_index+=1;
      if(last_load_data_index>=size || last_load_data_index==-1)
         last_load_data_index=0;
      SetGlobalVariable(LAST_CHECKED_BINANCE_INDEX, last_load_data_index);
      string symbolUsdt = ARR_SYMBOLS_COIN[last_load_data_index];

      bool is_folowing_this_symbol=true;
      if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
        {
         is_folowing_this_symbol=is_folowing_on_binance(symbolUsdt);

         if(is_folowing_this_symbol==false)
           {
            int size_coin =ArraySize(ARR_SYMBOLS_COIN);
            for(int idx=last_load_data_index;idx<size_coin;idx++)
              {
               symbolUsdt = ARR_SYMBOLS_COIN[idx];
               is_folowing_this_symbol=is_folowing_on_binance(symbolUsdt);
               if(is_folowing_this_symbol)
                 {
                  last_load_data_index=idx;
                  SetGlobalVariable(LAST_CHECKED_BINANCE_INDEX, last_load_data_index);
                  break;
                 }
              }
           }
        }

      if(is_folowing_this_symbol)
        {
         LoadDataFromBinanceToFile(symbolUsdt,PERIOD_W1,35);
         LoadDataFromBinanceToFile(symbolUsdt,PERIOD_D1,55);
         LoadDataFromBinanceToFile(symbolUsdt,PERIOD_H4,55);

         ObjectSetInteger(0,BtnD1_ + symbolUsdt+">",OBJPROP_BGCOLOR,clrBlack);
        }
     }

   if(is_checked_all_symbols())
      SetGlobalVariable(REQUEST_BINANCE_PER_MINUS,3);
   else
      SetGlobalVariable(REQUEST_BINANCE_PER_MINUS,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_folowing_on_binance(string symbolUsdt)
  {
   return true;//IsButtonExist(symbolUsdt);

   if(GetGlobalVariable(BtnTrading_+symbolUsdt)==OPTION_FOLOWING)
      return true;
   if(GetGlobalVariable(BtnFollowing_+symbolUsdt)==OPTION_FOLOWING)
      return true;

   string trend_ma20_h4, trend_ma10_h4, trend_hei_h4, trend_ma5_h4,low_hig_h4;
   int count_ma10_h4, count_hei_h4;
   double PERCENT_LOW_H4, PERCENT_HIG_H4;
   GetTrendFromFileCk("BINANCE_"+symbolUsdt,PERIOD_H4,trend_ma20_h4,trend_ma10_h4, count_ma10_h4, trend_hei_h4, count_hei_h4,trend_ma5_h4,low_hig_h4,PERCENT_LOW_H4,PERCENT_HIG_H4);

   bool is_h4_seq_buy=is_same_symbol(low_hig_h4,STR_SEQ_BUY);

   if((is_h4_seq_buy==false || is_same_symbol(trend_hei_h4, TREND_BUY)==false))
      return false;

   if((trend_ma10_h4+trend_hei_h4!="") && is_same_symbol(trend_ma10_h4+trend_hei_h4,TREND_BUY)==false)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DrawChartAndSetGlobal(string symbolUsdt,ENUM_TIMEFRAMES TF
                             ,string &open_times[],string &opens[],string &closes[],string &lows[],string &highs[],string &volumes[]
                             ,datetime TIME_OF_ONE_CANDLE, int chart_idx)
  {
   string trend_found="";
   CandleData candleArray[];
   double cur_close_0 = get_arr_heiken_binance(symbolUsdt,candleArray,open_times,opens,closes,lows,highs,volumes);
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
   if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_CK)
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

   bool is_coin = GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN;
   if(is_coin)
     {
      if(TF==PERIOD_D1)
        {
         tool_tip_top=true;
         btc_price_low += (btc_price_high + btc_price_low)/3.0;
        }
      if(TF==PERIOD_H4)
         btc_price_high=btc_price_low+(btc_price_high+btc_price_low)/3.0;

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

   datetime add_time=(datetime)(candleArray[0].time-candleArray[1].time);
   datetime shift=add_time*NUM_CANDLE_DRAW+add_time*6;
   if(chart_idx>0)
      shift=add_time*2;

   if(ada_range>0 && btc_range>0)
     {
      double PERCENT=0;
      double lowest=DBL_MAX,higest=0.0;

      datetime start_time=candleArray[size_d1].time  -shift;
      datetime end_time=candleArray[0].time+add_time -shift;
      datetime tool_tip_time=candleArray[(int)(size_d1*2/3)].time-shift;
      if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
         tool_tip_time=candleArray[(int)(size_d1/2)].time-shift;

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
                              (i==0?candleArray[i].time+TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma50_i0,clrGray,STYLE_SOLID,3);

         if(i<10 && ma20_i1>0 && ma20_i0>0)
            create_trend_line(prefix+"Ma20_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma20_i1,
                              (i==0?candleArray[i].time+TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma20_i0,clrBlue,STYLE_SOLID,2);//TF==PERIOD_MN1&&ma10_i0>ma20_i0?

         if(i<17 && ma10_i1>0 && ma10_i0>0)
           {
            create_trend_line(prefix+"Ma10_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma10_i1,
                              (i==0?candleArray[i].time+TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma10_i0,clrFireBrick,STYLE_SOLID,2);
           }

         string trend=candleArray[i].trend_heiken;
         color clrBody=is_same_symbol(trend,TREND_BUY)?clrTeal:clrBlack;

         create_heiken_candle(prefix+"Body_heiken_"+appendZero100(i),candleArray[i].time+TIME_OF_ONE_H4_CANDLE-shift,candleArray[i].time+TIME_OF_ONE_CANDLE-TIME_OF_ONE_H4_CANDLE-shift
                              ,open,close,low,high,clrBody,false,1,(string)candleArray[i].count_heiken);

         if(ma05_i1>0 && ma05_i0>0)
            create_trend_line(prefix+"Ma05_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candleArray[i+1].time-shift,ma05_i1,
                              (i==0?candleArray[i].time+TIME_OF_ONE_CANDLE:candleArray[i].time)-shift,ma05_i0,clrDimGray,STYLE_SOLID,2);

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
            if(ChartXYToTimePrice(0,10,50,_sub_windows,_time,_price))
              {
               create_label_simple(prefix+"TOOLTIP",get_time_frame_name(TF)+"    "+(is_vn30?"(VN30) ":"")+get_tool_tip_ck(symbolUsdt),_price,clrBlack,tool_tip_time);
              }

         if(!tool_tip_top)
           {
            int chart_heigh=(int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));
            if(ChartXYToTimePrice(0,10,chart_heigh-20,_sub_windows,_time,_price))
              {
               create_label_simple(prefix+"TOOLTIP",get_time_frame_name(TF)+"    "+(is_vn30?"(VN30) ":"")+get_tool_tip_ck(symbolUsdt),_price,clrBlack,tool_tip_time);
              }
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
         create_trend_line(prefix+"HIGEST",    start_time+add_time*2,higest,end_time,higest,clrRed,STYLE_SOLID,1,false, false);

      create_trend_line(prefix+"LOWEST",    start_time+add_time*2,lowest,end_time,lowest,clrRed,STYLE_SOLID,1,false, false);


      create_trend_line(prefix+"fibo_0_236",start_time+add_time*2,fibo_0_236,end_time,fibo_0_236,clrGray,STYLE_DOT,1,false,false);
      create_trend_line(prefix+"fibo_0_382",start_time+add_time*2,fibo_0_382,end_time,fibo_0_382,clrRed,STYLE_DOT,1,false,false);
      create_trend_line(prefix+"fibo_0_500",start_time+add_time*2,fibo_0_500,end_time,fibo_0_500,clrRed,STYLE_SOLID,1,false,false);
      create_trend_line(prefix+"fibo_0_618",start_time+add_time*2,fibo_0_618,end_time,fibo_0_618,clrRed,STYLE_DOT,1, false,false);
      create_trend_line(prefix+"fibo_0_764",start_time+add_time*2,fibo_0_764,end_time,fibo_0_764,clrRed,STYLE_DASH,1,false,false);

      create_label_simple(prefix+"0.118","0.118    " + DoubleToString(CalculateRealValue(fibo_0_118,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_118,clrBlack,start_time);
      create_label_simple(prefix+"0.236","0.236    " + DoubleToString(CalculateRealValue(fibo_0_236,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_236,clrBlack,start_time);
      create_label_simple(prefix+"0.382","0.382    " + DoubleToString(CalculateRealValue(fibo_0_382,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_382,clrBlack,start_time);
      create_label_simple(prefix+"0.500","0.500    " + DoubleToString(CalculateRealValue(fibo_0_500,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_500,clrBlack,start_time);
      create_label_simple(prefix+"0.618","0.618    " + DoubleToString(CalculateRealValue(fibo_0_618,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_618,clrBlack,start_time);
      create_label_simple(prefix+"0.764","0.764    " + DoubleToString(CalculateRealValue(fibo_0_764,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_0_764,clrBlack,start_time);

      if(TF!=PERIOD_H4)
        {
         create_trend_line(prefix+"fibo_1_23+",start_time+add_time*2,fibo_1_236, end_time,fibo_1_236, clrGray,STYLE_DOT,1,false,false);
         create_label_simple(prefix+"1.236","1.236    " + DoubleToString(CalculateRealValue(fibo_1_236,btc_mid,normalization_factor,ada_mid,offset),_digits),fibo_1_236+sai_so,clrBlack,start_time);
        }

      create_label_simple(prefix+"Low%",
                          "Low: "+DoubleToString(real_lowest,_digits) + " (-" + DoubleToString(percent_drop,1) +"%)"
                          ,lowest+sai_so,clrRed,start_time);

      create_label_simple(prefix+"Hig%",
                          "Hig: " +DoubleToString(real_higest,_digits) + " (+" + (string)DoubleToString(percent_rise,1)+"%)"
                          ,(TF!=PERIOD_H4)?higest-sai_so:higest-sai_so*3,clrBlue,start_time);

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
                                 ,candleArray[i].time-TIME_OF_ONE_H4_CANDLE*10+TIME_OF_ONE_CANDLE-shift
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
                                       ,candleArray[i+1].time-TIME_OF_ONE_H4_CANDLE*10+TIME_OF_ONE_CANDLE-shift,pre_avg_volume
                                       ,candleArray[i].time-TIME_OF_ONE_H4_CANDLE*10+TIME_OF_ONE_CANDLE-shift,avg_volume,
                                       clrRed,STYLE_SOLID,1);
                    }
                 }

               if(i==0)
                 {
                  double avg_volume = (total_volume/count_vol)*candleArray[i].close/VOL_1BILLION_VND;//Tỷ VND

                  string lblAvgVol = " Avg "+DoubleToString(avg_volume,1)+" tỷ";
                  if(avg_volume<1)
                     lblAvgVol = " Avg "+DoubleToString(avg_volume,2)+" tỷ";

                  create_label_simple(prefix+"_billion_avg_"+IntegerToString(count_vol)+"candles",lblAvgVol
                                      ,start_price+volume_to_price_ratio*avg_volume,clrBlack, candleArray[0].time+TIME_OF_ONE_H4_CANDLE*7+TIME_OF_ONE_CANDLE-shift,6);
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
         timeToArr[i] = candleArray[i].time-TIME_OF_ONE_H4_CANDLE*10+TIME_OF_ONE_CANDLE-shift;
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSelectedSymbolCoin(string symbolUsdt)
  {
   int size = ArraySize(ARR_SYMBOLS_COIN);
   for(int i=0;i<size;i++)
     {
      if(symbolUsdt==ARR_SYMBOLS_COIN[i]) //is_same_symbol(symbolUsdt," "+ARR_SYMBOLS_COIN[i]) ||
        {
         symbolUsdt=ARR_SYMBOLS_COIN[i];
         SetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX,(double)i);
         printf("Binance index: "+(string)i);
         break;
        }
     }
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

   SetGlobalVariable(CLICKED_SYMBOL_TYPE,SYMBOL_TYPE_CK);

   SetSelectedSymbolCk(symbolCk);
   TestReadAllDataFromFile(symbolCk,PERIOD_MN1,0);
   TestReadAllDataFromFile(symbolCk,PERIOD_W1, 1);
   TestReadAllDataFromFile(symbolCk,PERIOD_H4, 1);

   ObjectSetInteger(0,BtnCkD1_+symbolCk,OBJPROP_BGCOLOR,clrYellow);

   color clrTrading=GetGlobalVariable(BtnTrading_+symbolCk)==OPTION_FOLOWING?clrActiveBtn:clrLightGray;
   ObjectSetInteger(0,BtnTrading_,OBJPROP_BGCOLOR,clrTrading);

   color clrFolowing=GetGlobalVariable(BtnFollowing_+symbolCk)==OPTION_FOLOWING?clrActiveBtn:clrLightGray;
   ObjectSetInteger(0,BtnFollowing_,OBJPROP_BGCOLOR,clrFolowing);

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReDrawChartCoin(string symbolUsdt)
  {
   int size_ck =ArraySize(ARR_SYMBOLS_COIN);
   for(int i = 0; i< size_ck; i++)
     {
      string symbol=ARR_SYMBOLS_COIN[i];
      string btn_d1_name=BtnD1_+symbol;
      int bg_color = (int)ObjectGetInteger(0,btn_d1_name,OBJPROP_BGCOLOR);
      if(bg_color == (int)clrYellow)
         ObjectSetInteger(0,btn_d1_name,OBJPROP_BGCOLOR,clrLightGray);
     }

   DeleteAllObjectsWithPrefix("DCASG_");

   SetGlobalVariable(CLICKED_SYMBOL_TYPE,SYMBOL_TYPE_COIN);

   SetSelectedSymbolCoin(symbolUsdt);

   TestReadAllDataFromFile("BINANCE_"+symbolUsdt,PERIOD_W1,0);
   TestReadAllDataFromFile("BINANCE_"+symbolUsdt,PERIOD_D1,1);
   TestReadAllDataFromFile("BINANCE_"+symbolUsdt,PERIOD_H4,1);

   ObjectSetInteger(0,BtnD1_+symbolUsdt,OBJPROP_BGCOLOR,clrYellow);

   color clrTrading=GetGlobalVariable(BtnTrading_+symbolUsdt)==OPTION_FOLOWING?clrActiveBtn:clrLightGray;
   ObjectSetInteger(0,BtnTrading_,OBJPROP_BGCOLOR,clrTrading);

   color clrFolowing=GetGlobalVariable(BtnFollowing_+symbolUsdt)==OPTION_FOLOWING?clrActiveBtn:clrLightGray;
   ObjectSetInteger(0,BtnFollowing_,OBJPROP_BGCOLOR,clrFolowing);

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsButtonExist(string btn_name)
  {
   int total_objects = ObjectsTotal(0); // Đếm tổng số objects trên chart

   for(int i = 0; i < total_objects; i++)
     {
      string object_name = ObjectName(0, i); // Lấy tên object theo index

      if(is_same_symbol(object_name, btn_name))
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

      double SYMBOL_TYPE= GetGlobalVariable(CLICKED_SYMBOL_TYPE);

      if(SYMBOL_TYPE==SYMBOL_TYPE_CK)
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
      //-----------------------------------------------------------------------
      //-----------------------------------------------------------------------
      if(SYMBOL_TYPE==SYMBOL_TYPE_COIN)
        {
         int size_coin =ArraySize(ARR_SYMBOLS_COIN);
         int index=(int)GetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX);

         if(key == VK_UP)          // Phím mũi tên lên
           {
            index--;    // Giảm biến
            if(index<0)
               index=ArraySize(ARR_SYMBOLS_COIN)-1;
            string symbolUsdt= ARR_SYMBOLS_COIN[index];


            if(IsButtonExist(symbolUsdt)==false)
              {
               for(int idx=index;idx>0;idx--)
                 {
                  symbolUsdt = ARR_SYMBOLS_COIN[idx];
                  if(IsButtonExist(symbolUsdt))
                    {
                     index=idx;
                     break;
                    }
                 }
              }

            Print("VK_UP: "+(string)index + "  "+ symbolUsdt);
            if(IsButtonExist(symbolUsdt))
              {
               SetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX,(double)index);
               ReDrawChartCoin(symbolUsdt);
              }
            return;
           }

         if(key == VK_DOWN)   // Phím mũi tên xuống
           {
            index++;    // Tăng biến
            if(index>=ArraySize(ARR_SYMBOLS_COIN))
               index=0;
            string symbolUsdt= ARR_SYMBOLS_COIN[index];


            if(IsButtonExist(symbolUsdt)==false)
              {
               for(int idx=index;idx<size_coin;idx++)
                 {
                  symbolUsdt = ARR_SYMBOLS_COIN[idx];
                  if(IsButtonExist(symbolUsdt))
                    {
                     index=idx;
                     break;
                    }
                 }
              }

            Print("VK_DO: "+(string)index + "  "+ symbolUsdt);
            if(IsButtonExist(symbolUsdt))
              {
               SetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX,(double)index);
               ReDrawChartCoin(symbolUsdt);
              }
           }
        }
      //-----------------------------------------------------------------------
     }

   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //-----------------------------------------------------------------------
      if(is_same_symbol(sparam,BtnD1_))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("Sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         DeleteAllObjectsWithPrefix("DCASG_");

         SetGlobalVariable(CLICKED_SYMBOL_TYPE,SYMBOL_TYPE_COIN);
         string symbolUsdt=get_symbol_from_label(sparam);

         ReDrawChartCoin(symbolUsdt);
         return;
        }

      if(is_same_symbol(sparam,BtnH4_))
        {
         string btnD1=sparam;
         StringReplace(btnD1,BtnH4_,BtnD1_);
         string buttonLabel = ObjectGetString(0,btnD1,OBJPROP_TEXT);
         string symbolUsdt=get_symbol_from_label(sparam);

         SetSelectedSymbolCoin(symbolUsdt);
         Draw_Buttons();

         string interval="D";//"4H";
         string url="https://www.tradingview.com/chart/r46Q5U5a/?interval="+interval+"&symbol=BINANCE:"+symbolUsdt;
         int result = ShellExecuteW(0, "open", url, NULL, NULL, 1);

         return;
        }

      if(is_same_symbol(sparam,BtnLink_))
        {
         string btnD1=sparam;
         StringReplace(btnD1,BtnLink_,BtnD1_);
         string buttonLabel = ObjectGetString(0,btnD1,OBJPROP_TEXT);
         string symbolUsdt=get_symbol_from_label(sparam);

         SetSelectedSymbolCoin(symbolUsdt);

         int intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
         if(intPeriod==-1)
            intPeriod = PERIOD_D1;

         string interval="D";
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

         string url="https://www.tradingview.com/chart/r46Q5U5a/?interval="+interval+"&symbol=BINANCE:"+symbolUsdt;
         int result = ShellExecuteW(0, "open", url, NULL, NULL, 1);

         return;
        }
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

      if(is_same_symbol(sparam,BtnTrading_) || is_same_symbol(sparam,BtnFollowing_))
        {
         if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_CK)
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

         if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
           {
            int clicked_index=(int)GetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX);

            string symbolUsdt=ARR_SYMBOLS_COIN[clicked_index];

            if(GetGlobalVariable(sparam+symbolUsdt)==OPTION_FOLOWING)
              {
               SetGlobalVariable(sparam+symbolUsdt,0);
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrLightGray);
              }
            else
              {
               SetGlobalVariable(sparam+symbolUsdt,OPTION_FOLOWING);
               if(is_same_symbol(sparam,BtnTrading_))
                  SetGlobalVariable(BtnFollowing_+symbolUsdt,OPTION_FOLOWING);
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

         if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
           {
            SetGlobalVariable(BtnFilterD20,FILTER_ON);
            SetGlobalVariable(BtnFilterMa10W1,FILTER_ON);
            SetGlobalVariable(BtnFilterMa10H4,FILTER_ON);
           }
         else
           {
            //SetGlobalVariable(BtnFilterHistMo,FILTER_ON);
            //SetGlobalVariable(BtnFilterHistWx,FILTER_ON);
            SetGlobalVariable(BtnFilterHistHx,FILTER_ON);
            SetGlobalVariable(BtnFilterHistW3,FILTER_ON);
            SetGlobalVariable(BtnFilterCondH4Sq,FILTER_ON);
           }

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

      if(is_same_symbol(sparam,BtnCkD1_) || is_same_symbol(sparam,BtnCkH4_))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         string symbolCk=get_symbol_ck_from_label(sparam,true);

         Print("Sparam=",sparam," buttonLabel=",buttonLabel," was clicked: " + symbolCk);

         ReDrawChartCk(symbolCk);

         return;
        }

      if(is_same_symbol(sparam,BtnCkH4_))
        {
         string btnD1=sparam;
         StringReplace(btnD1,BtnCkH4_,BtnCkD1_);
         //string buttonLabel = ObjectGetString(0,btnD1,OBJPROP_TEXT);
         string symbolCk=get_symbol_ck_from_label(sparam,false);

         SetSelectedSymbolCk(symbolCk);
         //ObjectSetInteger(0,btnD1,OBJPROP_BGCOLOR,clrYellow);

         string interval="4H";
         string url="https://www.tradingview.com/chart/r46Q5U5a/?interval="+interval+"&symbol="+symbolCk;
         int result = ShellExecuteW(0, "open", url, NULL, NULL, 1);

         return;
        }

      if(is_same_symbol(sparam,BtnMarketType))
        {
         if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_CK)
           {
            ObjectSetString(0, sparam,OBJPROP_TEXT,"COIN");
            SetGlobalVariable(CLICKED_SYMBOL_TYPE,SYMBOL_TYPE_COIN);

            do_clear_cond();
            if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
              {
               SetGlobalVariable(BtnFilterCondH4Sq,FILTER_ON);
               SetGlobalVariable(BtnFilterCondH4C3,FILTER_ON);
               SetGlobalVariable(BtnFilterMa10H4,FILTER_ON);
              }

            Draw_Buttons();
            return;
           }

         if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
           {
            ObjectSetString(0, sparam,OBJPROP_TEXT,"CK");
            SetGlobalVariable(CLICKED_SYMBOL_TYPE,SYMBOL_TYPE_CK);

            Draw_Buttons();
            return;
           }
         return;
        }


      if(is_same_symbol(sparam,BtnCkTradingView))
        {
         if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_CK)
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

         if(GetGlobalVariable(CLICKED_SYMBOL_TYPE)==SYMBOL_TYPE_COIN)
           {
            int clicked_coin_index=(int)GetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX);
            string symbolUsdt = ARR_SYMBOLS_COIN[clicked_coin_index];

            string interval="D";

            int intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
            if(intPeriod==-1)
               intPeriod = PERIOD_D1;
            if(intPeriod == PERIOD_MN1)
               interval="M";
            if(intPeriod == PERIOD_W1)
               interval="W";
            if(intPeriod == PERIOD_H4)
               interval="4H";
            if(intPeriod == PERIOD_H1)
               interval="1H";

            string url="https://www.tradingview.com/chart/r46Q5U5a/?interval="+interval+"&symbol=BINANCE:"+symbolUsdt;
            int result = ShellExecuteW(0, "open", url, NULL, NULL, 1);
           }

         return;
        }

      if(is_same_symbol(sparam,BtnCkLink_))
        {
         string btnD1=sparam;
         StringReplace(btnD1,BtnCkLink_,BtnCkD1_);
         //string buttonLabel = ObjectGetString(0,btnD1,OBJPROP_TEXT);
         string symbolCk=get_symbol_ck_from_label(sparam,false);
         //ObjectSetInteger(0,btnD1,OBJPROP_BGCOLOR,clrYellow);

         SetSelectedSymbolCk(symbolCk);

         int intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
         if(intPeriod==-1)
            intPeriod = PERIOD_D1;

         string interval="D";
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

      if(is_same_symbol(sparam,BtnManualLoadData))
        {
         int clicked_index=(int)GetGlobalVariable(CLICKED_SYMBOL_COIN_INDEX);
         string symbolUsdt = ARR_SYMBOLS_COIN[clicked_index];

         LoadDataFromBinanceToFile(symbolUsdt,PERIOD_W1,35);
         LoadDataFromBinanceToFile(symbolUsdt,PERIOD_D1,55);
         LoadDataFromBinanceToFile(symbolUsdt,PERIOD_H4,55);

         ObjectSetInteger(0,BtnD1_ + symbolUsdt+">",OBJPROP_BGCOLOR,clrBlack);

         ReDrawChartCoin(symbolUsdt);
         Alert("Loaded W1, D1, H4: "+symbolUsdt);
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
bool is_checked_all_symbols()
  {
   bool checked_all_symbol=true;
   string cur_ydd=get_ydd(TimeCurrent());
   int size = ArraySize(ARR_SYMBOLS_COIN);
   for(int i=0;i<size;i++)
     {
      string symbolUsdt=ARR_SYMBOLS_COIN[i];
      string cur_ydd________=(string)GetGlobalVariable(symbolUsdt);
      if(is_same_symbol(cur_ydd________,cur_ydd)==false)
        {
         checked_all_symbol=false;
         break;
        }
     }

   return checked_all_symbol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_symbol_from_label(string lable)
  {
   int size = ArraySize(ARR_SYMBOLS_COIN);
   for(int i=0;i<size;i++)
     {
      string symbolUsdt=ARR_SYMBOLS_COIN[i];
      if(is_same_symbol(lable," "+symbolUsdt) || is_same_symbol(lable,"_"+symbolUsdt))
         return symbolUsdt;
     }

   return "";
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
string LoadDataFromBinanceToFile(string symbolUsdt,ENUM_TIMEFRAMES TF,int size)
  {
   string trend_found="";
//--------------------------------------------------------------------------
   char post[];             // Biến dùng gửi dữ liệu POST (không cần ở đây vì dùng GET)
   char result[];           // Biến nhận kết quả từ API
   int timeout = 5000;      // Thời gian timeout cho WebRequest
   string headers;          // Headers (nếu có)

   string binance_tf="1d";
   if(TF==PERIOD_M15)
      binance_tf="15m";
   if(TF==PERIOD_H1)
      binance_tf="1h";
   if(TF==PERIOD_H4)
      binance_tf="4h";
   if(TF==PERIOD_W1)
      binance_tf="1w";

   string filename="BINANCE_"+symbolUsdt+".txt";
   if(TF==PERIOD_W1)
      filename="BINANCE_"+symbolUsdt+"_WEEKLY.txt";
   if(TF==PERIOD_D1)
      filename="BINANCE_"+symbolUsdt+"_DAILY.txt";
   if(TF==PERIOD_H4)
      filename="BINANCE_"+symbolUsdt+"_4HOURS.txt";

// https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1w&limit=1
   string api_url = "https://api.binance.com/api/v3/klines?symbol="+symbolUsdt+"&interval="+binance_tf+"&limit="+(string)(size+10);
   string tradingview_url="https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=BINANCE:"+symbolUsdt;
   string str_no=appendZero100((int)GetGlobalVariable(LAST_CHECKED_BINANCE_INDEX))+ "/" + appendZero100(ArraySize(ARR_SYMBOLS_COIN));

   string _msg=str_no+"    "+get_vntime()+api_url+AppendSpaces(symbolUsdt,20,false);
   string _log=str_no+"    "+AppendSpaces(get_vntime()+tradingview_url,110,true);
//printf(_msg);

   int res = WebRequest("GET",api_url,"",timeout,headers,post,0,result,headers);
   if(res==200)
     {
      string json = CharArrayToString(result);

      // Xóa ký tự đầu và cuối nếu JSON là mảng
      string clean_json = StringSubstr(json, 1, StringLen(json) - 2);
      //Print(clean_json);  // Kiểm tra đầu vào đã được làm sạch

      // Tách các trường của nến (tách theo dấu ']')
      string candles[];
      int candle_count = StringSplit(clean_json, ']', candles);

      if(candle_count < 1)
        {
         Print("Failed to parse JSON or no candles found.");
         return "";
        }

      // Mảng lưu dữ liệu nến dưới dạng chuỗi
      string opens[], highs[], lows[], closes[], volumes[], open_times[];
      int valid_candle_count = 0;

      // Xử lý từng nến
      for(int i = 0; i < candle_count; i++)
        {
         string candle = candles[i];
         candle = StringSubstr(candle, 1, StringLen(candle) - 2);  // Loại bỏ ký tự bắt đầu và kết thúc

         // Tách các trường của nến (tách theo dấu ',')
         string fields[];
         int field_count = StringSplit(candle, ',', fields);

         if(field_count < 6)
            continue; // Bỏ qua nếu số trường không đúng

         // Tăng kích thước mảng để lưu trữ dữ liệu nến
         ArrayResize(opens, valid_candle_count + 1);
         ArrayResize(highs, valid_candle_count + 1);
         ArrayResize(lows, valid_candle_count + 1);
         ArrayResize(closes, valid_candle_count + 1);
         ArrayResize(volumes, valid_candle_count + 1);
         ArrayResize(open_times, valid_candle_count + 1);

         // Lưu trữ các giá trị dưới dạng chuỗi
         string open_time=fields[0];
         StringReplace(open_time,"[","");
         open_times[valid_candle_count] = open_time;  // Thời gian mở cửa
         opens[valid_candle_count] = fields[1];
         highs[valid_candle_count] = fields[2];
         lows[valid_candle_count] = fields[3];
         closes[valid_candle_count] = fields[4];
         volumes[valid_candle_count] = fields[5];

         // Kiểm tra nếu giá trị hợp lệ (ví dụ, không phải chuỗi rỗng)
         if(opens[valid_candle_count] == "" || highs[valid_candle_count] == "" ||
            lows[valid_candle_count] == "" || closes[valid_candle_count] == "" ||
            volumes[valid_candle_count] == "")
           {
            continue;  // Nếu dữ liệu không hợp lệ thì bỏ qua
           }

         valid_candle_count++;
        }

      // Đảo ngược mảng dữ liệu để dữ liệu mới nhất nằm ở index 0
      ArrayReverse(opens);
      ArrayReverse(highs);
      ArrayReverse(lows);
      ArrayReverse(closes);
      ArrayReverse(volumes);
      ArrayReverse(open_times);

      if(valid_candle_count>10)
        {
         DeleteFileIfExists(filename);
         AppendToFile(filename,"datetime\tsymbol\topen\thigh\tlow\tclose\tvolume");

         for(int i = valid_candle_count-1; i >=0 ; i--)
           {
            // Chuyển đổi chuỗi sang kiểu double
            string time=(string)BinanceDateTimeToVNTime(symbolUsdt,open_times,i);

            string line = time+"\t"+symbolUsdt+"\t"+opens[i]+"\t"+highs[i]+"\t"+lows[i]+"\t"+closes[i]+"\t"+volumes[i];
            StringReplace(line, "\"", "");
            AppendToFile(filename,line);
           }
        }

      if(ArraySize(opens)<size)
        {
         string msg=get_time_frame_name(TF)+"   ArraySize(opens)<size " + AppendSpaces(symbolUsdt,15,true);
         AppendToFile(BINANCE_LOG_FILE,_log+"    "+msg);

         string cur_ydd=get_ydd(TimeCurrent());
         string cur_wdh=cur_ydd+"000"+"0000"+"000"+".0";
         SetGlobalVariable(symbolUsdt,(double)(cur_wdh));

         return "ERROR";
        }

      trend_found="NEXT";//

      return trend_found;
     }
   return trend_found;
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

   datetime time_mid=(time_from+time_to)/2 -TIME_OF_ONE_H4_CANDLE-TIME_OF_ONE_H1_CANDLE;
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

      if(candleArray[0].ma50>0 && candleArray[0].ma20>0 && candleArray[0].ma10>0)
        {
         if(candleArray[0].ma50>candleArray[0].ma20 && candleArray[0].ma20>candleArray[0].ma10)
            low_hig+=" " + STR_SEQ_SEL; //SeqSel;

         if(candleArray[0].ma50<candleArray[0].ma20 && candleArray[0].ma20<candleArray[0].ma10)
            low_hig+=" " + STR_SEQ_BUY; //SeqBuy
         else
            if(candleArray[0].ma50<candleArray[0].close && candleArray[0].ma20<candleArray[0].close && candleArray[0].ma10<candleArray[0].close)
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

   bool Filter1BilVnd=GetGlobalVariable(BtnFilter1BilVnd)==FILTER_ON?true:false;
   if(TF==PERIOD_H4 && Filter1BilVnd)
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
      datetime bar_start = current_time-(i+1)*TIME_OF_ONE_W1_CANDLE;
      datetime bar_end   = current_time - i  *TIME_OF_ONE_W1_CANDLE;

      ArrayResize(scale_open_times, lineIndex);
      scale_open_times[lineIndex - 1] = (string)bar_start;
      lineIndex+=1;
     }

   if(ArraySize(open_times)>10)
      DrawChartAndSetGlobal(symbolCk,TF,scale_open_times,opens,closes,lows,highs,volumes,TIME_OF_ONE_W1_CANDLE-TIME_OF_ONE_H4_CANDLE*2,chart_index);
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
   ,"HOSE_EVF Công ty Tài chính CP Điện lực "+GROUP_CHUNGKHOAN
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
   ,"HOSE_NT2 CTCP Điện lực Dầu khí Nhơn Trạch 2 "+GROUP_DAUKHI
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
   , "HNX_PLC Tổng Công ty Hóa dầu Petrolimex – CTCP"
   , "HNX_PSI Công ty Cổ phần Chứng khoán Dầu khí"
   , "HNX_PVC Tổng Công ty Hóa chất và Dịch vụ Dầu khí – CTCP (PVChem)"
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
  }
//+------------------------------------------------------------------+
