//+------------------------------------------------------------------+
//|                                     void LoadTradeBySeqEvery5min |
//|                                   Copyright 2024,MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;
const string BOT_SHORT_NM="";
//-----------------------------------------------------------------------------
bool ALLOW_DRAW_BUTONS=true;
bool ALLOW_DRAW_PROFIT = true;
double RISK_BY_PERCENT= 5.0;//%
//-----------------------------------------------------------------------------
bool IS_ALLOW_TRAILING_STOP=false;
//-----------------------------------------------------------------------------
string telegram_url="https://api.telegram.org";
//-----------------------------------------------------------------------------
#define GLOBAL_VAR_SL    "LINE_SL_"
#define GLOBAL_VAR_LM    "LINE_LM_"
#define LINE_RR_11       "LINE_RR 1:1"
#define LINE_RR_12       "LINE_RR 1:2"
#define LINE_RR_13       "LINE_RR 1:3"
#define GLOBAL_LINE_TIMER_1 "GLOBAL_LINE_TIMER_1_"
#define GLOBAL_LINE_TIMER_2 "GLOBAL_LINE_TIMER_2_"
#define FIBO_TIME_ZONE_     "FiboTimeZone_"
//Nếu giá trị biến không phải hôm nay thì Alert, âm là Sell, dương là Buy.
#define GLOBAL_VAR_051020H4_  "GLOBAL_VAR_051020H4_"// -yyMMddhhmm
#define GLOBAL_VAR_051020H1_  "GLOBAL_VAR_051020H1_"// -yyMMddhhmm
#define GLOBAL_VAR_102050Mx_  "GLOBAL_VAR_102050Mx_"// -yyMMddhhmm
//-----------------------------------------------------------------------------
#define BtnD10                      "BtnD10_"
#define BtnNoticeD1                 "BtnNoticeD1_"
#define BtnNoticeW1                 "BtnNoticeW1_"
#define BtnInitNoticeM5W1           "BtnInitNoticeM5W1"
#define BtnDeInitNoticeM5W1         "BtnDeInitNoticeM5W1"
#define BtnOptionPeriod             "BtnOption_Period_"
#define BtnMsg_                     "BtnMsg_"
#define BtnMsgR1C1_                 BtnMsg_+"R1C1_"
#define BtnMsgR1C2_                 BtnMsg_+"R1C2_"
#define BtnMsgR1C3_                 BtnMsg_+"R1C3_"
#define BtnMsgREVR_                 BtnMsg_+"REVR_"
#define BtnMsgSTOP_                 BtnMsg_+"STOP_"
#define BtnMsgR2C1_                 BtnMsg_+"R2C1_"
#define BtnMsgR2C2_                 BtnMsg_+"R2C2_"
#define BtnClearMessageR1C1         "BtnClearMessageR1C1"
#define BtnClearMessageR1C2         "BtnClearMessageR1C2"
#define BtnClearMessageR1C3         "BtnClearMessageR1C3"
#define BtnClearMessageREVR         "BtnClearMessageREVR"
#define BtnClearMessageSTOP         "BtnClearMessageSTOP"
#define BtnClearMessageRxCx         "BtnClearMessageRxCx"
#define BtnClearMessageR2C1         "BtnClearMessageR2C1"
#define BtnClearMessageR2C2         "BtnClearMessageR2C2"
#define BtnShowWDHMode              "BtnShowWDHMode"
#define BtnHideDrawMode             "BtnHideDrawMode"
#define BtnHideAngleMode            "BtnHideAngleMode"
#define BtnSimpleControl            "BtnSimpleControl"
#define BtnMacdMode                 "BtnMacdMode"
#define BtnColorMode                "BtnColorMode"
#define BtnClearChart               "BtnClearChart"
#define BtnOpenPosition             "BtnOpenPosition"
#define BtnOpen1L                   "BtnOpen1L"
#define BtnOpenStop1L               "BtnOpenStop1L"
#define BtnCloseSymbol              "BtnCloseSymbol"
#define BtnCloseLimit               "BtnCloseLimit"
#define BtnCloseAllLimit            "BtnCloseAllLimit"
#define BtnTpPositiveThisSymbol     "BtnTpPositiveThisSymbol"
#define BtnTpPositiveAllSymbols     "BtnTpPositiveAllSymbols"
#define BtnInitWaitMacdM5           "BtnInitWaitMacdM5"
#define BtnDeInitWaitMacdM5         "BtnDeInitWaitMacdM5"
#define BtnWaitMacdM5ThenAutoTrade  "BtnWaitMacdM5ThenAutoTrade_"
#define BtnFindR11                  "BtnFindR11"
#define BtnSetPriceLimit            "BtnSetPriceLimit_"
#define BtnFindSL                   "BtnFindSL"
#define BtnSetSLHere                "BtnSetSLHere"
#define BtnSetAmpTrade              "BtnSetAmpTrade_"
#define BtnSetAmpLM                 "BtnSetAmpLM"
#define BtnSuggestTrend             "BtnSuggestTrend"
#define BtnTrendReverse             "BtnTrendReverse"
#define BtnRevRR                    "BtnRevRR"
#define BtnMid3d                    "BtnMid3d"
#define BtnSetTPHereR1              "BtnSetTPHereR1"
#define BtnSetTPHereR2              "BtnSetTPHereR2"
#define BtnSetTPHereR3              "BtnSetTPHereR3"
#define BtnReSetTPEntry             "BtnReSetTPEntry"
#define BtnExitAllTrade             "BtnExitAllTrade"
#define BtnNoticeSeq102050M5        "BtnNoticeSeq102050M5_"
#define BtnNoticeSeq102050H1        "BtnNoticeSeq102050H1_"
#define BtnResetMaCross             "BtnResetMaCross"
#define BtnCloseWhen_               "btn_CloseWhen_"// HeiMa10   HeiMa20  HeiMa50
#define BtnNoticeMaCross            "NoticeMaCross_"// NoticeMaCross+symbol+_H1=8510
#define BtnClearNoticeMaCross       "BtnClearNoticeMaCross"
#define BtnAddFibo                  "btn_add_fibo_"
#define BtnFiboline                 "btn_fiboline_"
#define BtnSupportResistance        "btn_add_Support_Resistance"
#define BtnHorTrendline             "BtnHorTrendline"
#define BtnAddTrendline             "btn_add_trendline"
#define BtnSaveTrendline            "btn_save_trendline"
#define BtnClearTrendline           "btn_clear_trendline"
#define BtnResetTimeline            "btn_reset_timeline"
#define BtnDefaultCycles            "btn_default_cycles"
#define BtnSetTimeHere              "Btn_SetTimeHere"
#define HeivsMa10_BUY "810"
#define HeivsMa10_SEL "910"
#define HeivsMa20_BUY "812"
#define HeivsMa20_SEL "912"
#define HeivsMa50_BUY "815"
#define HeivsMa50_SEL "915"
#define HeikenCandleC2_BUY "831"
#define HeikenCandleC2_SEL "931"
#define HeivsSeqMa102050_BUY "821"
#define HeivsSeqMa102050_SEL "921"
#define HeivsSeqMa102050200_BUY "825"
#define HeivsSeqMa102050200_SEL "925"
#define TP_WHEN_HeiMa10 10.0
#define TP_WHEN_HeiMa20 20.0
#define TP_WHEN_HeiMa50 50.0
#define TP_WHEN_Ma10_07 7.0
#define TP_WHEN_Ma10_13 13.0
#define TP_WHEN_Ma10_21 21.0
#define TP_WHEN_Ma10_27 27.0
#define MANUAL_TRENDLINE_ "MANUAL_TRENDLINE_"
#define MANUAL_TRENDFIBO_ "MANUAL_TRENDFIBO_"
#define MANUAL_SUPPRESIS_ "MANUAL_SUPPRESIS_"
//-----------------------------------------------------------------------------
#define BtnScheduleT2 "BtnScheduleT2_"
#define BtnScheduleT3 "BtnScheduleT3_"
#define BtnScheduleT4 "BtnScheduleT4_"
#define BtnScheduleT5 "BtnScheduleT5_"
#define BtnScheduleT6 "BtnScheduleT6_"
//-----------------------------------------------------------------------------
#define AVG_HEIGHT_W1 "AVG_HEIGHT_W1_"
#define AVG_HEIGHT_D1 "AVG_HEIGHT_D1_"
#define AVG_HEIGHT_H4 "AVG_HEIGHT_H4_"
#define AVG_HEIGHT_H1 "AVG_HEIGHT_H1_"
//-----------------------------------------------------------------------------
const int MAXIMUM_OPENING=25;
const string TREND_BUY="BUY";
const string TREND_SEL="SELL";
const double TYPE_BUY = 111;
const double TYPE_SEL =-111;
const string TREND_LIMIT_BUY = "L.M.B.U.Y";
const string TREND_LIMIT_SEL = "L.M.S.E.L";
const string PRIFIX_MA10 = "(10)";
const string PRIFIX_MA20 = "(20)";
const string PRIFIX_SEQ_H4 = "(Sq)";
const string MASK_NORMAL="";
const string MASK_AUTO="(AT)";
const string MASK_HEGING="(Hg)";
const string MASK_RECOVER="(Re)";
const string MASK_MARKET="(M.K)";
const string MASK_LIMIT="(L.M)";
const string MASK_D10 = "(D.X)";
const string MASK_RevD10="(R.V)";
const string MASK_COUNT_TRI= "(:3)";
const string MASK_ALLOW_TRIPPLE="(3X)";
const string MASK_POSITION="(P.O.S)";
const string MASK_WEEKLY="(=W1)";
const string MASK_TIMEFRAME_TRADING="[TF:";
//#define STR_FILENAME_TREND_WD "TREND_WD.txt"
const int BTN_WIDTH_STANDA=180;
int count_closed_today=0;
double MAXIMUM_DOUBLE=999999999;
const int MAX_MESSAGES= 1000;
const string FILE_MSG_LIST_R1C1 = "R1C1.txt";
const string FILE_MSG_LIST_R1C2 = "R1C2.txt";
const string FILE_MSG_LIST_R1C3 = "R1C3.txt";
const string FILE_MSG_LIST_REVR = "REVR.txt";
const string FILE_MSG_LIST_SL   = "STOP.txt";
const string FILE_MSG_LIST_R2C1 = "R2C1.txt";
const string FILE_MSG_LIST_WAIT = "R2C2.txt";
const string FILE_NAME_SEND_MSG="_send_msg_today.txt";
color clrActiveBtn = clrLightCyan;
color clrActiveSell= clrMistyRose;
const double AUTO_TRADE_BUY = 3.0;
const double AUTO_TRADE_SEL = 2.0;
const double AUTO_TRADE_ONN  =1.0;
const double AUTO_TRADE_OFF =-1.0;
datetime TIME_OF_ONE_H1_CANDLE=3600;
datetime TIME_OF_ONE_H4_CANDLE=14400;
datetime TIME_OF_ONE_D1_CANDLE=86400;
datetime TIME_OF_ONE_W1_CANDLE=604800;
int ARR_TIMES[]= {24,25,13,14,15,16,17,18,19,20,21,22,23};
// Khai báo các biến để giữ tổng chiều cao nến và số lượng nến đã đóng
double   total_height_w1=0, total_height_d1=0, total_height_h4=0, total_height_h1=0;
int      num_candles_w1=0,  num_candles_d1=0,  num_candles_h4=0,  num_candles_h1=0;
datetime last_time_w1=0,    last_time_d1=0,    last_time_h4=0,    last_time_h1=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ACCOUNT_CENT = " ,Exness-MT5Real25:183264196";
string ACCOUNT_FTMO = " ,FTMO-Server2:520188395";
string ACCOUNT_THE5 = " ,FivePercentOnline-Real:24479729";

string ARR_SYMBOLS_FTMO[] =
  {
   "XAUUSD"
   , "AUDUSD", "NZDUSD", "EURUSD", "GBPUSD", "USDCAD", "USDCHF", "EURGBP", "EURAUD", "AUDJPY", "NZDJPY", "EURJPY", "GBPJPY", "USDJPY"
   , "BTCUSD", "USOIL.cash", "US500.cash", "US30.cash", "JP225.cash", "GER40.cash", "XAGUSD"
  };

string ARR_SYMBOLS_THE5[] =
  {
   "XAUUSD"
   , "AUDUSD", "NZDUSD", "EURUSD", "GBPUSD", "USDCAD", "USDCHF", "EURGBP", "EURAUD", "AUDJPY", "NZDJPY", "EURJPY", "GBPJPY", "USDJPY"
   , "SP500", "BTCUSD", "ETHUSD"
  };

string ARR_SYMBOLS_CENT[] =
  {
   "XAUUSDc"
   , "USDJPYc"
//, "AUDUSDc", "NZDUSDc", "EURUSDc", "GBPUSDc", "USDCADc", "USDCHFc", "EURGBPc", "EURAUDc", "AUDJPYc", "NZDJPYc", "EURJPYc", "GBPJPYc", "USDJPYc"
   , "BTCUSDc"
  };

const string MAIN_PAIRS="US30,US500,SP500,US100,NAS100,DAX40,GER40, XAUUSD, USOIL, XTIUSD, BTCUSD, EURUSD, USDJPY, GBPUSD, USDCHF, AUDUSD, USDCAD, NZDUSD";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//CreateTrendWDH();
   string cur_symbol=Symbol();
   ENUM_TIMEFRAMES CUR_TIMEFRAME = Period();

   long chartID=ChartFirst();
   if(ChartNext(chartID) != -1)
      ChartClose(chartID);

   ObjectsDeleteAll(0);

   string trend_183609=checkAndDrawMACDDivergence(cur_symbol,CUR_TIMEFRAME,18,36,9,2,true);
   string trend_122609=checkAndDrawMACDDivergence(cur_symbol,CUR_TIMEFRAME,12,26,9,3,true);
   string trend_061209=checkAndDrawMACDDivergence(cur_symbol,CUR_TIMEFRAME,06,12,9,4,true);

   create_label_simple("trend_183609", trend_183609,0,is_same_symbol(trend_183609,TREND_BUY)?clrBlue:clrRed,TimeCurrent(),2);
   create_label_simple("trend_122609", trend_122609,0,is_same_symbol(trend_122609,TREND_BUY)?clrBlue:clrRed,TimeCurrent(),3);
   create_label_simple("trend_061209", trend_061209,0,is_same_symbol(trend_061209,TREND_BUY)?clrBlue:clrRed,TimeCurrent(),4);

   bool is_show_wdh=GetGlobalVariable(BtnShowWDHMode)==AUTO_TRADE_ONN;
   bool is_hide_mode=GetGlobalVariable(BtnHideDrawMode)==AUTO_TRADE_ONN;
   bool IS_MACD_DOT=GetGlobalVariable(BtnMacdMode)==AUTO_TRADE_ONN;
   bool is_hide_angle=GetGlobalVariable(BtnHideAngleMode)==AUTO_TRADE_ONN;

   if(is_hide_mode==false)
      createButton("BackGround","",0,0,2250,200,clrNONE,clrWhite,7,5);

   if(is_hide_mode == false)
     {
      double top_price = ChartGetDouble(0, CHART_PRICE_MAX);
      double bot_price = ChartGetDouble(0, CHART_PRICE_MIN);
      double LM=GetGlobalVariable(GLOBAL_VAR_LM+cur_symbol);

      if(LM<bot_price || LM>top_price)
        {
         double amp_w1,amp_d1,amp_h4,amp_h1;
         GetAmpAvgL15(cur_symbol,amp_w1,amp_d1,amp_h4,amp_h1);

         double mid = (top_price+bot_price)/2;
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+cur_symbol);

         if(LM>SL)
           {
            SetGlobalVariable(GLOBAL_VAR_LM+cur_symbol,mid);
            SetGlobalVariable(GLOBAL_VAR_SL+cur_symbol,mid-amp_d1);
           }
         else
           {
            SetGlobalVariable(GLOBAL_VAR_LM+cur_symbol,mid);
            SetGlobalVariable(GLOBAL_VAR_SL+cur_symbol,mid+amp_d1);
           }
        }

      init_sl_tp_trendline(false);
     }

   DrawButtons();

   DrawFiboTimeZone52H4(Period(),false);

   DrawTrendMa10(cur_symbol,PERIOD_H4,10,55);
   DrawTrendMa10(cur_symbol,PERIOD_D1,12,35);
   DrawTrendMa10(cur_symbol,PERIOD_W1,15,25);
//DrawTrendCountMa10(cur_symbol,PERIOD_W1,10,25);

   LoadTrendlines();
   LoadFibolines();

   if(CUR_TIMEFRAME<PERIOD_H1)
     {
      string cross_trend;
      int count_cross_1020=countMaCross(cur_symbol,CUR_TIMEFRAME, cross_trend,10,20);
      //Alert(cross_trend, count_cross_1020);
      create_label_simple("count_cross_1020", "      CROSS_1020: "+cross_trend+"."+IntegerToString(count_cross_1020),iClose(cur_symbol,CUR_TIMEFRAME,1),clrBlack,iTime(cur_symbol,CUR_TIMEFRAME,1));
     }

   draw_trend_Stoc(cur_symbol,PERIOD_W1,3,3,3,3,5);
   draw_trend_Stoc(cur_symbol,PERIOD_D1,3,3,3,3,5);
   draw_trend_Stoc(cur_symbol,PERIOD_H4,3,3,3,3,5);
   draw_trend_Stoc(cur_symbol,PERIOD_H1,3,3,3,3,5);

   CandleData arrHeiken_TF[];
   get_arr_heiken(cur_symbol,Period(),arrHeiken_TF,55,true,false);
   bool is_fisrt=true;
   int loop = ArraySize(arrHeiken_TF)-10;
   datetime time_shift=arrHeiken_TF[1].time-arrHeiken_TF[2].time;
   for(int i = 0; i<loop; i++)
     {
      if(arrHeiken_TF[i].count_heiken==1)
        {
         string lblName="Hei_"+append1Zero(i)+"_"+get_yyyymmdd(arrHeiken_TF[i].time);

         double higest=0;
         double lowest=DBL_MAX;
         for(int idx=i; idx<=i+1; idx++)
           {
            double low=iLow(cur_symbol,CUR_TIMEFRAME,idx);
            double hig=iHigh(cur_symbol,CUR_TIMEFRAME,idx);
            if(lowest>low)
               lowest=low;
            if(higest<hig)
               higest=hig;
           }
         bool is_buy = arrHeiken_TF[i].trend_heiken==TREND_BUY?true:false;
         double temp_sl=is_buy?lowest:higest;
         double temp_en=is_buy?higest:lowest;
         double amp=MathAbs(temp_en-temp_sl);
         double temp_tp1=is_buy?temp_en+amp*1:temp_en-amp*1;
         double temp_tp2=is_buy?temp_en+amp*2:temp_en-amp*2;
         double temp_tp3=is_buy?temp_en+amp*3:temp_en-amp*3;

         if(is_fisrt)
           {
            is_fisrt=false;
            string tf = get_time_frame_name(Period());
            datetime str_time=arrHeiken_TF[i+1].time;
            datetime end_time=arrHeiken_TF[0].time+time_shift*2;

            create_trend_line(tf+"_SL_" +arrHeiken_TF[i].trend_heiken,str_time,temp_sl, end_time,temp_sl, clrRed,STYLE_SOLID,2);
            create_trend_line(tf+"_EN_" +arrHeiken_TF[i].trend_heiken,str_time,temp_en, end_time,temp_en, clrGreen,STYLE_SOLID,2);
            create_trend_line(tf+"_TP1_"+arrHeiken_TF[i].trend_heiken,str_time,temp_tp1,end_time,temp_tp1,clrBlue,STYLE_SOLID,1);
            create_trend_line(tf+"_TP2_"+arrHeiken_TF[i].trend_heiken,str_time,temp_tp2,end_time,temp_tp2,clrNavy,STYLE_SOLID,1);
            create_trend_line(tf+"_TP3_"+arrHeiken_TF[i].trend_heiken,str_time,temp_tp3,end_time,temp_tp3,clrRed,STYLE_SOLID,2);

            for(int idx=4; idx<=10; idx++)
              {
               double temp_tpI=is_buy?temp_en+amp*idx:temp_en-amp*idx;
               create_trend_line(tf+"_TP"+IntegerToString(idx)+"_"+arrHeiken_TF[i].trend_by_ma10,str_time,temp_tpI,end_time,temp_tpI,idx<10?clrBlack:clrRed,STYLE_SOLID,1);
              }

            for(int idx=0; idx<=10; idx++)
              {
               double temp_tpI=is_buy?temp_en+amp*idx:temp_en-amp*idx;
               create_label_simple(tf+"_TP"+IntegerToString(idx),""+IntegerToString(idx)+"",temp_tpI,clrBlack,str_time-time_shift*1);
              }

            break;
           }
        }
     }


   Comment(GetComments());
   ChartRedraw();

   if(is_show_wdh)
     {
      int total_chart=3;
      if(Period()>PERIOD_H1)
         total_chart=4;
      DrawChartParent(cur_symbol,PERIOD_W1,1,total_chart);
      DrawChartParent(cur_symbol,PERIOD_D1,2,total_chart);
      DrawChartParent(cur_symbol,PERIOD_H4,3,total_chart);
      if(Period()>PERIOD_H1)
         DrawChartParent(cur_symbol,PERIOD_H1,4,total_chart);
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTick()
  {
   CheckTrendlineUpdates();

   long chartID=ChartFirst();
   if(ChartNext(chartID) != -1)
      ChartClose(chartID);

   datetime vietnamTime=TimeGMT()+7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(vietnamTime,time_struct);

   int cur_minute = time_struct.min;
   int last_checked_minute = (int)GetGlobalVariable("timer_three_min");
   SetGlobalVariable("timer_three_min", cur_minute);

   int time_reload = 15;
   ENUM_TIMEFRAMES TradingPeriod = (ENUM_TIMEFRAMES)GetGlobalVariable(BtnOptionPeriod);
   if(TradingPeriod<0)
      TradingPeriod=PERIOD_H4;
   if(TradingPeriod==PERIOD_M15)
      time_reload = 10;
   if(TradingPeriod==PERIOD_M5)
      time_reload = 5;

   if((cur_minute%time_reload==0) && (cur_minute!=last_checked_minute))
     {
      //if(is_morning_checking_time())
      //  {
      //   if(allow_PushMessage("RESET_NOTICE",FILE_MSG_LIST_SL))
      //      PushMessage("RESET_NOTICE "+get_vnhour(),FILE_MSG_LIST_SL);
      //
      //   int size = getArraySymbolsSize();
      //   for(int index = 0; index < size; index++)
      //     {
      //      string temp_symbol = getSymbolAtIndex(index);
      //      SetGlobalVariable(BtnNoticeMaCross+temp_symbol+"_H1",7);
      //      SetGlobalVariable(BtnNoticeMaCross+temp_symbol+"_H4",7);
      //     }
      //  }
      //else
        {
         //"Check"
         WriteFileContent(FILE_MSG_LIST_R1C1,"");
         WriteFileContent(FILE_MSG_LIST_R1C2,"");
         WriteFileContent(FILE_MSG_LIST_R1C3,"");
         WriteFileContent(FILE_MSG_LIST_REVR,"");
         WriteFileContent(FILE_MSG_LIST_R2C1,"");

         LoadTradeBySeqEvery5min();

         LoadSLTPEvery5min();

         DrawButtons();

         ChartRedraw();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawButtons()
  {
   bool IS_SIMPLE_CONTROL=GetGlobalVariable(BtnSimpleControl)==AUTO_TRADE_ONN;
   bool IS_MACD_DOT=GetGlobalVariable(BtnMacdMode)==AUTO_TRADE_ONN;
   bool IS_FIBO_LINE=GetGlobalVariable(BtnFiboline)==AUTO_TRADE_ONN;
   bool is_show_wdh=GetGlobalVariable(BtnShowWDHMode)==AUTO_TRADE_ONN;
   bool is_hide_mode=GetGlobalVariable(BtnHideDrawMode)==AUTO_TRADE_ONN;
   int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));
   string cur_symbol = Symbol();
   int start_y=5;
   bool cur_buy_only=GetGlobalVariable(cur_symbol)==TYPE_BUY;
   bool cur_sel_only=GetGlobalVariable(cur_symbol)==TYPE_SEL;

   createButton(BtnHideDrawMode,"Buttons",chart_width/2-200+10+260+50,5,60,25,clrBlack,is_hide_mode?clrYellow:clrWhite,7,1);
   createButton(BtnShowWDHMode,"WDH",chart_width/2-200+70+265+50,5,35,25,clrBlack,is_show_wdh?clrActiveBtn:clrWhite,7,1);
   createButton(BtnSimpleControl,"Slim",chart_width-60,5,50,25,clrBlack,IS_SIMPLE_CONTROL?clrActiveBtn:clrLightGray,7,2);

   int start_x=chart_width/2-400+320+10+200+10;
   int count_btn=1;
   if(IS_SIMPLE_CONTROL==false)
     {
      createButton(BtnMacdMode,       "Macd",            start_x+50*(++count_btn),start_y,45,25,clrBlack,IS_MACD_DOT?clrActiveBtn:clrWhite,7,1);
      createButton(BtnFiboline,       "Fibo",            start_x+50*(++count_btn),start_y,45,25,clrBlack,IS_FIBO_LINE?clrActiveBtn:clrWhite,7,1);
      createButton(BtnAddFibo,        "#",               start_x+50*(++count_btn),start_y,45,25,clrRed,clrWhite, 20,1);
     }
   createButton(BtnHorTrendline+TREND_BUY,   "---", start_x+50*(++count_btn),start_y,45,25,clrBlue,clrWhite,20,1);
   createButton(BtnHorTrendline+TREND_SEL,   "---", start_x+50*(++count_btn),start_y,45,25,clrRed,clrWhite, 20,1);
   createButton(BtnSaveTrendline,  "Save",            start_x+50*(++count_btn),start_y,45,25,clrBlack,clrPaleTurquoise,7,1);
   if(IS_SIMPLE_CONTROL==false)
     {
      createButton(BtnAddTrendline,   "Clone",           start_x+50*(++count_btn),start_y,45,25,clrBlack,clrWhite,7,1);
     }
   createButton(BtnClearTrendline, "Del",          start_x+50*(++count_btn),start_y,45,25,clrBlack,clrLightGray,7,1);//9

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(cur_symbol,amp_w1,amp_d1,amp_h4,amp_h1);
   double risk_1L = Risk_1L();
   string tf=get_time_frame_name(Period());
   string curTrend = get_trend_by_ma(cur_symbol,PERIOD_H4,10,0);
   color curColor = curTrend==TREND_BUY?clrActiveBtn:clrActiveSell;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//if(IS_SIMPLE_CONTROL==false)
//   createButton(BtnDefaultCycles,  "Cycles",       start_x+50*(++count_btn), start_y,45,25,clrBlack,cur_buy_only?clrActiveBtn:cur_sel_only?clrActiveSell:clrLightGray,7,1);

   count_btn+=2;
   createButton(BtnFindSL+"_"+tf+"_CurTrend","(12H4)",start_x+50*(++count_btn)-50,   start_y,120,25,clrBlack,curColor,8,1);//15
   count_btn+=1;
   color curHeikenColor=get_trend_by_heiken(cur_symbol,PERIOD_H4,0)==TREND_BUY?clrActiveBtn:clrActiveSell;
   createButton(BtnSetTimeHere+".iHei1", "Hei.H4[1] ",start_x+50*(++count_btn)-10,start_y,75,25,clrBlack,curHeikenColor,8,1);//18
   int xCandle=start_x+50*(++count_btn)+18;
   createButton(BtnSetTimeHere+".iHei2", "[2]",  xCandle,   start_y,30,25,clrBlack,curHeikenColor,8,1);//18
   createButton(BtnSetTimeHere+".iHei3", "[3]",  xCandle+33,start_y,30,25,clrBlack,curHeikenColor,8,1);//18

   count_btn+=1;
   createButton(BtnRevRR,           "Rev",      start_x+50*(++count_btn),start_y,45,25,clrBlack,clrYellow,8,1);//17

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(IS_SIMPLE_CONTROL==false)
     {
      createButton(BtnSetAmpTrade+"W1","W1:"+DoubleToString(calc_volume_by_amp(cur_symbol,amp_w1,risk_1L),2)+" lot", start_x+50*(++count_btn), start_y,90,25,clrBlack,curColor,8,1);//19
      count_btn+=1;
      createButton(BtnSetAmpTrade+"D1","D1:"+DoubleToString(calc_volume_by_amp(cur_symbol,amp_d1,risk_1L),2)+" lot", start_x+50*(++count_btn), start_y,90,25,clrBlack,curColor,8,1);//21
      count_btn+=1;
      createButton(BtnSetAmpTrade+"H4","H4:"+DoubleToString(calc_volume_by_amp(cur_symbol,amp_h4,risk_1L),2)+" lot", start_x+50*(++count_btn), start_y,90,25,clrBlack,curColor,8,1);//23
      count_btn+=1;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   createButton(BtnSetAmpTrade+"00","00",       start_x+50*(++count_btn), start_y,45,25,clrBlack,clrWhite,8,1);//25
   createButton(BtnSetAmpTrade+"??","Amp?",     start_x+50*(++count_btn), start_y,45,25,clrBlack,clrWhite,8,1);//26
   createButton(BtnReSetTPEntry,"Set.Tp.Entry", start_x+50*(++count_btn), start_y,90,25,clrBlack,clrLightGray,8,1);//27

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(is_hide_mode)
      return;

   int SUB_WINDOW=5;
   int count=-1;
   int x = 90;
   int y = 10;
   int btn_width = 300;
   int btn_heigh = 20;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int chart_1_2_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))/2;
   double global_others_profit = 0,global_XAU_profit = 0,count_global_profit = 0,count_xau_profit = 0;

   string arrNoticeSymbols_D[];
   ENUM_TIMEFRAMES curPeriod = Period();

//string strTrendWD = ReadFileContent(STR_FILENAME_TREND_WD);

   int count_wd=0;
   string total_comments="";
   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string symbol = getSymbolAtIndex(index);
      string str_index = "";//"("+append1Zero(index)+") ";
      bool is_cur_tab = is_same_symbol(symbol,cur_symbol);
      //-----------------------------------------------------------------------------------------------
      //-----------------------------------------------------------------------------------------------
      string strBSL=CountBSL(symbol,total_comments);
      string lblBtn10=strBSL;
      count += 1;
      //----------------------------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------------------------
      if(is_cur_tab)
        {
         int x_start=100;
         ObjectSetString(0,BtnD10+symbol,OBJPROP_FONT,"Arial Bold");

         bool is_hide_mode=GetGlobalVariable(BtnHideDrawMode)==AUTO_TRADE_ONN;
         if(is_hide_mode == false)
           {
            if(OrdersTotal()>0)
               createButton(BtnCloseAllLimit,"Close All Limit: "+(string)OrdersTotal(),80,5,120,30,clrBlack,clrWhite,7,2);

            createButton(BtnExitAllTrade,"Exit All",5,5,60,30,clrBlack,clrLightGray,7,2);

            createButton(BtnTpPositiveAllSymbols,"(TP+) "+GetTempProfit(""),5,5,BTN_WIDTH_STANDA+100,30,clrBlack,clrWhite,7,3);

            ENUM_TIMEFRAMES TradingPeriod = (ENUM_TIMEFRAMES)GetGlobalVariable(BtnOptionPeriod);
            if(TradingPeriod<0)
               TradingPeriod=PERIOD_H4;

            int cIdxLen = 1;
            cIdxLen = 200;
            for(int cIdx=1; cIdx<=cIdxLen; cIdx++)
              {
               bool is_doji_normal = is_Doji(symbol,curPeriod,cIdx);
               if(is_doji_normal)
                  create_trend_line("Doji.C"+append1Zero(cIdx)
                                    ,iTime(symbol,curPeriod,cIdx),iLow(symbol,curPeriod,cIdx)
                                    ,iTime(symbol,curPeriod,cIdx),iHigh(symbol,curPeriod,cIdx)
                                    ,clrYellow,STYLE_SOLID,7);
              }

            if(false && is_cur_tab)
              {
               CandleData arrHeiken_W1[];
               get_arr_heiken(symbol,PERIOD_W1,arrHeiken_W1,35,true,false);
               DrawCandleIndex(arrHeiken_W1);

               int sub_window;
               datetime temp_time;
               double  temp_high, temp_price0, temp_price1, temp_price_w;

               if(ChartXYToTimePrice(0, chart_width/2, chart_heigh-5, sub_window, temp_time, temp_price0))
                  if(ChartXYToTimePrice(0, chart_width/2, chart_heigh-35, sub_window, temp_time, temp_price1))
                    {
                     temp_high = (temp_price1-temp_price0)/3;
                     temp_price_w = temp_price0+temp_high*3;

                     if(Period()>=PERIOD_D1)
                       {
                        CandleData arrHeiken_Mo[];
                        get_arr_heiken(symbol,PERIOD_MN1,arrHeiken_Mo,25,true,false);
                        string histogram_mn = DrawAndCountHistogram(arrHeiken_Mo, symbol, PERIOD_MN1,true, temp_price0, temp_price0+temp_high*2);
                       }

                     string histogram_w1 = DrawAndCountHistogram(arrHeiken_W1, symbol, PERIOD_W1, true, temp_price_w, temp_price_w+temp_high*2);
                    }
              }

           }
        }
      //----------------------------------------------------------------------------------
      int btn_heigh = (index==0)?70:20;

      if(index==0)
        {btn_heigh = (size>19)?95:btn_heigh;}
      if(index==7)
        {count = 0; x = btn_width+95; y = 35;}
      if(index==13)
        {count = 0; x = btn_width+95; y = 60;}
      if(index==19)  //BTCUSD
        {count = 0; x = btn_width+95; y = 85;}
      if(size<=5)
         btn_heigh=70;

      int fontSize = 7;
      color clrBackground=clrLightGray;

      bool is_buy_only=GetGlobalVariable(symbol)==TYPE_BUY;
      bool is_sel_only=GetGlobalVariable(symbol)==TYPE_SEL;
      if(is_buy_only || is_sel_only)
        {
         //lblBtn10 = "("+(is_buy_only?TREND_BUY:TREND_SEL)+") " + lblBtn10;
         clrBackground = is_buy_only?clrActiveBtn:clrActiveSell;

         str_index = "";
         str_index += "("+(is_buy_only?TREND_BUY:TREND_SEL)+") ";
         //createButton(BtnD10+symbol+"-", "",x+(btn_width+5)*count,y-2,btn_width,5,clrBlack,is_same_symbol(arrHeiken_D1[0].trend_by_ma20,TREND_BUY)?clrBlue:clrRed,7,SUB_WINDOW);
        }

      color clrText = clrBlack;
      if(is_same_symbol(strBSL,"$"))
         clrText=is_same_symbol(strBSL,"-")?clrRed:clrBlue;

      CandleData arrHeiken_D1[];
      get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,55,true,true);

      if(arrHeiken_D1[0].count_ma20<=2)
         str_index="("+getShortName(arrHeiken_D1[0].trend_by_ma10)+"."+IntegerToString(arrHeiken_D1[0].count_ma20)+") "+str_index;

      //get_consistent_symbol
      createButton(BtnD10+symbol,str_index+lblBtn10+(symbol),x+(btn_width+5)*count,y,btn_width,btn_heigh,clrText,clrBackground,fontSize,SUB_WINDOW);

      if(is_cur_tab)
         createButton(BtnD10+symbol+"|", "",x+(btn_width+5)*count+3,y+3,15,14,clrBlack,clrPurple,fontSize,SUB_WINDOW);
     }
//--------------------------------------------------------------------------------------------
   btn_width=150;
   for(int index = 0; index < ArraySize(arrNoticeSymbols_D); index++)
     {
      string strLable = arrNoticeSymbols_D[index];
      string symbol = get_symbol_from_label(strLable);
      color clrText = is_same_symbol(strLable,"$+")?clrBlue:clrBlack;
      color clrBg = is_same_symbol(symbol,cur_symbol)?clrActiveBtn :
                    is_same_symbol(strLable,"Ma S")?clrMistyRose:clrPowderBlue;

      createButton(BtnNoticeD1+symbol,strLable,(btn_width+5)*index+10,150,btn_width,20,clrText,clrBg,7,SUB_WINDOW);
     }
//--------------------------------------------------------------------------------------------
   double intPeriod = GetGlobalVariable(BtnOptionPeriod);
   if(intPeriod<0)
     {
      intPeriod = PERIOD_D1;
      SetGlobalVariable(BtnOptionPeriod,(double)intPeriod);
     }
//--------------------------------------------------------------------------------------------
   createButton(BtnOptionPeriod+"_W1",  "W1", 5, 5+20*0,30,19,clrBlack,intPeriod==PERIOD_W1 ?clrActiveBtn:clrWhite,7,SUB_WINDOW);
   createButton(BtnOptionPeriod+"_D1",  "D1", 5, 5+20*1,30,19,clrBlack,intPeriod==PERIOD_D1 ?clrActiveBtn:clrWhite,7,SUB_WINDOW);
   createButton(BtnOptionPeriod+"_H4",  "H4", 5, 5+20*2,30,19,clrBlack,intPeriod==PERIOD_H4 ?clrActiveBtn:clrWhite,7,SUB_WINDOW);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   createButton(BtnOptionPeriod+"_H1",  "H1", 40,5+20*0,30,19,clrBlack,intPeriod==PERIOD_H1 ?clrActiveBtn:clrWhite,7,SUB_WINDOW);
   createButton(BtnOptionPeriod+"_M30", "30", 40,5+20*1,30,19,clrBlack,intPeriod==PERIOD_M30?clrActiveBtn:clrWhite,7,SUB_WINDOW);
   createButton(BtnOptionPeriod+"_M15", "15", 40,5+20*2,30,19,clrBlack,intPeriod==PERIOD_M15?clrActiveBtn:clrWhite,7,SUB_WINDOW);
//--------------------------------------------------------------------------------------------
   if(IS_MACD_DOT)
     {
      Draw_MACD_Extremes(cur_symbol,PERIOD_H4,10,false,1,STYLE_DOT);
      //Draw_MACD_Extremes(symbol,PERIOD_H1,7,false,1,STYLE_DOT);
      //is_allow_trade_by_macd_extremes(symbol,PERIOD_M15,"");
      //is_allow_trade_by_macd_extremes(symbol,PERIOD_M5,"");
      if(Period()<=PERIOD_D1)
         Draw_MACD_Extremes(cur_symbol,PERIOD_D1,17,true, 1,STYLE_SOLID);
     }
//--------------------------------------------------------------------------------------------
   bool is_hide_angle=GetGlobalVariable(BtnHideAngleMode)==AUTO_TRADE_ONN;
   if(is_hide_mode == false)
     {
      CreateMessagesBtn(BtnMsgR2C1_);
      CreateMessagesBtn(BtnMsgR2C2_);
      CreateMessagesBtn(BtnMsgR1C1_);
      CreateMessagesBtn(BtnMsgR1C2_);
      CreateMessagesBtn(BtnMsgR1C3_);
      CreateMessagesBtn(BtnMsgSTOP_);
      CreateMessagesBtn(BtnMsgREVR_);
     }
//--------------------------------------------------------------------------------------------
   if(chart_width>2000)
     {
      int init_y=5;
      int STOC_WINDOW=1;
      string find_trend_H1=(string)GetGlobalVariable(BtnNoticeMaCross+cur_symbol+"_H1");
      string find_trend_H4=(string)GetGlobalVariable(BtnNoticeMaCross+cur_symbol+"_H4");


      string str_H4Ma10="(H4) Hei.Ma10"+(is_same_symbol(find_trend_H4,HeivsMa10_BUY)?" "+TREND_BUY:"")+(is_same_symbol(find_trend_H4,HeivsMa10_SEL)?" "+TREND_SEL:"");
      string str_H4Ma20="(H4) Hei.Ma20"+(is_same_symbol(find_trend_H4,HeivsMa20_BUY)?" "+TREND_BUY:"")+(is_same_symbol(find_trend_H4,HeivsMa20_SEL)?" "+TREND_SEL:"");
      string str_H4Ma50="(H4) Hei.Ma50"+(is_same_symbol(find_trend_H4,HeivsMa50_BUY)?" "+TREND_BUY:"")+(is_same_symbol(find_trend_H4,HeivsMa50_SEL)?" "+TREND_SEL:"");

      string str_H4HeikenC2="(H4) Tele Hei.C.1.2"+(is_same_symbol(find_trend_H4,HeikenCandleC2_BUY)?" "+TREND_BUY:"")+(is_same_symbol(find_trend_H4,HeikenCandleC2_SEL)?" "+TREND_SEL:"");
      string str_H1HeikenC2="(H1) Tele Hei.C.1.2|3"+(is_same_symbol(find_trend_H1,HeikenCandleC2_BUY)?" "+TREND_BUY:"")+(is_same_symbol(find_trend_H1,HeikenCandleC2_SEL)?" "+TREND_SEL:"");

      string str_H1Ma10="(H1) Hei.Ma10"+(is_same_symbol(find_trend_H1,HeivsMa10_BUY)?" "+TREND_BUY:"")+(is_same_symbol(find_trend_H1,HeivsMa10_SEL)?" "+TREND_SEL:"");
      string str_H1Seq050="(H1) Hei.Seq050"+(is_same_symbol(find_trend_H1,HeivsSeqMa102050_BUY)?" "+TREND_BUY:"")+(is_same_symbol(find_trend_H1,HeivsSeqMa102050_SEL)?" "+TREND_SEL:"");
      string str_H1Seq200="(H1) Hei.Seq200"+(is_same_symbol(find_trend_H1,HeivsSeqMa102050200_BUY)?" "+TREND_BUY:"")+(is_same_symbol(find_trend_H1,HeivsSeqMa102050200_SEL)?" "+TREND_SEL:"");

      int btn_notice_width = 142;
      int col_1=35,col_2=col_1+btn_notice_width+10,col_3=col_2+btn_notice_width+10,col_4=col_3+btn_notice_width+10,col_5=col_4+btn_notice_width+10,col_6=col_5+btn_notice_width+10,col_7=col_6+btn_notice_width+50;

      bool is_period_h1=Period()==PERIOD_H1;
      bool is_period_h4=Period()==PERIOD_H4;
      createButton(BtnClearNoticeMaCross, "X",col_3,init_y,25,25,clrRed,clrWhite,7,STOC_WINDOW);

      createButton(BtnNoticeMaCross+"_H4Ma10",         str_H4Ma10,col_3,init_y,btn_notice_width,25,clrBlack,is_same_symbol(find_trend_H4,HeivsMa10_BUY)?clrActiveBtn:is_same_symbol(find_trend_H4,HeivsMa10_SEL)?clrActiveSell:clrLightGray,7,STOC_WINDOW+1);
      createButton(BtnNoticeMaCross+"_H4Ma20",         str_H4Ma20,col_4,init_y,btn_notice_width,25,clrBlack,is_same_symbol(find_trend_H4,HeivsMa20_BUY)?clrActiveBtn:is_same_symbol(find_trend_H4,HeivsMa20_SEL)?clrActiveSell:clrLightGray,7,STOC_WINDOW+1);
      createButton(BtnNoticeMaCross+"_H4Ma50",         str_H4Ma50,col_5,init_y,btn_notice_width,25,clrBlack,is_same_symbol(find_trend_H4,HeivsMa50_BUY)?clrActiveBtn:is_same_symbol(find_trend_H4,HeivsMa50_SEL)?clrActiveSell:clrLightGray,7,STOC_WINDOW+1);
      createButton(BtnNoticeMaCross+"_H4HeikenC2", str_H4HeikenC2,col_6,init_y,btn_notice_width,25,clrBlack,is_same_symbol(find_trend_H4,HeikenCandleC2_BUY)?clrActiveBtn:is_same_symbol(find_trend_H4,HeikenCandleC2_SEL)?clrActiveSell:clrLightGray,7,STOC_WINDOW+1);

      createButton(BtnNoticeMaCross+"_H1Ma10",         str_H1Ma10,col_3,init_y,btn_notice_width,25,clrBlack,is_same_symbol(find_trend_H1,HeivsMa10_BUY)?clrActiveBtn:is_same_symbol(find_trend_H1,HeivsMa10_SEL)?clrActiveSell:clrLightGray,7,STOC_WINDOW+2);
      createButton(BtnNoticeMaCross+"_H1Seq050",     str_H1Seq050,col_4,init_y,btn_notice_width,25,clrBlack,is_same_symbol(find_trend_H1,HeivsSeqMa102050_BUY)?clrActiveBtn:is_same_symbol(find_trend_H1,HeivsSeqMa102050_SEL)?clrActiveSell:clrLightGray,7,STOC_WINDOW+2);
      createButton(BtnNoticeMaCross+"_H1Seq200",     str_H1Seq200,col_5,init_y,btn_notice_width,25,clrBlack,is_same_symbol(find_trend_H1,HeivsSeqMa102050200_BUY)?clrActiveBtn:is_same_symbol(find_trend_H1,HeivsSeqMa102050200_SEL)?clrActiveSell:clrLightGray,7,STOC_WINDOW+2);
      createButton(BtnNoticeMaCross+"_H1HeikenC2", str_H1HeikenC2,col_6,init_y,btn_notice_width,25,clrBlack,is_same_symbol(find_trend_H1,HeikenCandleC2_BUY)?clrActiveBtn:is_same_symbol(find_trend_H1,HeikenCandleC2_SEL)?clrActiveSell:clrLightGray,7,STOC_WINDOW+2);
     }
//--------------------------------------------------------------------------------------------
   createButton(BtnClearMessageRxCx,"Check",chart_width/2-50,5,100,30,clrBlack,clrYellowGreen,8,2);
   createButton(BtnClearChart,"Clear Chart",chart_width/2-50+110,5,100,30,clrBlack,clrYellow,8,2);
   createButton(BtnResetTimeline,"Reset",chart_width/2-50+110*2,5,100,30,clrBlack,clrYellowGreen,8,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadSLTPEvery5min(bool allow_alert=true)
  {
//-------------------------------------------------------------------------------
   bool reload=false;
   double risk_1L = Risk_1L();

   bool is_end_of_day=is_end_of_day_time();
   bool is_exit_all_weekend=is_exit_all_by_weekend();

   ENUM_TIMEFRAMES TradingPeriod = (ENUM_TIMEFRAMES)GetGlobalVariable(BtnOptionPeriod);
   if(TradingPeriod<0)
      TradingPeriod=PERIOD_H4;

   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string temp_symbol = getSymbolAtIndex(index);
      double bid = SymbolInfoDouble(temp_symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(temp_symbol,SYMBOL_ASK);
      int digits = (int)SymbolInfoInteger(temp_symbol,SYMBOL_DIGITS);
      double slipage=MathAbs(ask-bid);
      double cur_price = (bid+ask)/2;
      //----------------------------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------------------------
      double total_profit_cur_symbol=0;
      for(int i = PositionsTotal()-1; i >= 0; i--)
        {
         if(m_position.SelectByIndex(i))
            if(is_same_symbol(m_position.Symbol(),temp_symbol))
              {
               string TREND_TYPE = m_position.TypeDescription();
               string trend_reverse=get_trend_reverse(TREND_TYPE);
               double temp_profit = m_position.Profit()+m_position.Swap()+m_position.Commission();
               bool pass_7h=PassedWaitHours(m_position.Time(),7);
               string key="";
               CandleData arrHeiken_H4[];
               get_arr_heiken(temp_symbol,PERIOD_H4,arrHeiken_H4,55,true,true);

               CandleData arrHeiken_H1[];
               get_arr_heiken(temp_symbol,PERIOD_H1,arrHeiken_H1,55,true,true);

               key="(Reverse.Hei.H4.SeqH1)"+temp_symbol;
               if(is_same_symbol(trend_reverse, arrHeiken_H4[0].trend_heiken) &&
                  is_same_symbol(trend_reverse, arrHeiken_H1[0].trend_heiken) &&
                  is_same_symbol(trend_reverse, arrHeiken_H1[0].trend_by_ma10) &&
                  is_same_symbol(trend_reverse, arrHeiken_H1[0].trend_by_ma20) &&
                  is_same_symbol(trend_reverse, arrHeiken_H1[0].trend_by_ma50))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  string msg=key+" "+DoubleToString(temp_profit,1)+"$";
                  PushMessage(msg,FILE_MSG_LIST_SL);
                  reload=true;
                  continue;
                 }

               if(pass_7h)
                 {
                  key="(Reverse.Hei.H4)"+temp_symbol;
                  if(is_same_symbol(trend_reverse,arrHeiken_H4[0].trend_heiken) && allow_PushMessage(key,FILE_MSG_LIST_REVR))
                    {
                     string msg=key+" "+DoubleToString(temp_profit,1)+"$";
                     PushMessage(msg,FILE_MSG_LIST_REVR);
                     ModifyTpEntry(temp_symbol,TREND_TYPE);
                     reload=true;
                    }

                  key="(Reverse.Ma.Hei.H4)"+temp_symbol;
                  if(is_same_symbol(trend_reverse,arrHeiken_H4[1].trend_by_ma10) &&
                     is_same_symbol(trend_reverse,arrHeiken_H4[0].trend_by_ma10) &&
                     is_same_symbol(trend_reverse,arrHeiken_H4[1].trend_heiken) &&
                     is_same_symbol(trend_reverse,arrHeiken_H4[0].trend_heiken) && allow_PushMessage(key,FILE_MSG_LIST_REVR))
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     string msg=key+" "+DoubleToString(temp_profit,1)+"$";
                     PushMessage(msg,FILE_MSG_LIST_SL);
                     reload=true;
                    }
                 }

               key="(Reverse.Stoc.333.H4)"+temp_symbol;
               bool is_exit_by_stoc_h4 = allow_trade_now_by_stoc(temp_symbol,PERIOD_H4,trend_reverse,3,3,3,0);
               bool is_exit_by_stoc_h1 = allow_trade_now_by_stoc(temp_symbol,PERIOD_H1,trend_reverse,3,3,3,0);
               if(temp_profit>0 && is_exit_by_stoc_h4 && is_exit_by_stoc_h1 && allow_PushMessage(key,FILE_MSG_LIST_REVR))
                 {
                  string msg=key+" "+DoubleToString(temp_profit,1)+"$";
                  PushMessage(msg,FILE_MSG_LIST_REVR);
                  double best_tp_today=is_same_symbol(TREND_TYPE,TREND_BUY)?iHigh(temp_symbol,PERIOD_D1,0):iLow(temp_symbol,PERIOD_D1,0);

                  ModifyTp(temp_symbol,TREND_TYPE,best_tp_today);
                  ClosePositivePosition(temp_symbol,TREND_TYPE);
                  reload=true;
                 }
               //-------------------------------------------------------------------
               if(temp_profit>0)
                 {
                  if(arrHeiken_H4[0].count_ma10>=7 &&
                     is_same_symbol(TREND_TYPE,arrHeiken_H4[0].trend_by_ma10) &&
                     is_same_symbol(trend_reverse,arrHeiken_H4[1].trend_heiken)&&
                     is_same_symbol(trend_reverse,arrHeiken_H4[0].trend_heiken))
                    {
                     ClosePositivePosition(temp_symbol,TREND_TYPE);
                    }

                  if(is_exit_all_weekend && is_same_symbol(trend_reverse,arrHeiken_H4[0].trend_by_ma10)
                     && is_same_symbol(trend_reverse,arrHeiken_H4[0].trend_heiken))
                    {
                     ClosePositivePosition(temp_symbol,TREND_TYPE);
                     string msg=" (WEEKEND Exit "+TREND_TYPE+") "+ " "+temp_symbol+" "+DoubleToString(temp_profit,1)+"$";
                     PushMessage(msg,FILE_MSG_LIST_SL);
                     reload=true;
                    }
                 }
               //-------------------------------------------------------------------
               //-------------------------------------------------------------------
               //-------------------------------------------------------------------
               bool has_sl=m_position.StopLoss()>0;

               total_profit_cur_symbol += temp_profit;

               string msg = TREND_TYPE
                            +" "+temp_symbol
                            +" "+format_double_to_string(temp_profit,1)+"$";
               //-------------------------------------------------------------------
               //bool pass_3d=PassedWaitHours(m_position.Time(),24*3);
               //-------------------------------------------------------------------
               //-------------------------------------------------------------------
               //STOP LOSS 1R
               if(has_sl==false && risk_1L+temp_profit<0)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  SendTelegramMessage(temp_symbol,TREND_TYPE,"(SL_1R)"+msg);

                  PushMessage("(SL_1R)"+msg,FILE_MSG_LIST_SL);
                  reload=true;
                 }
               //-------------------------------------------------------------------
               bool is_same_entry_price = true;
               string PriceOpen = DoubleToString(NormalizeDouble(m_position.PriceOpen(), digits-1),digits-1);
               string TakeProfit= DoubleToString(NormalizeDouble(m_position.TakeProfit(),digits-1),digits-1);
               if(PriceOpen != TakeProfit)
                 {
                  is_same_entry_price=(m_position.PriceOpen()-slipage*5<m_position.TakeProfit()) &&
                                      (m_position.TakeProfit()<m_position.PriceOpen()+slipage*5);
                 }
               //-------------------------------------------------------------------
               //TP 1R
               if(temp_profit>risk_1L)
                 {
                  if(is_same_symbol(TREND_TYPE,TREND_BUY) &&
                     is_same_symbol(arrHeiken_H4[1].trend_heiken,TREND_SEL) &&
                     is_same_symbol(arrHeiken_H4[0].trend_heiken,TREND_SEL))
                     m_trade.PositionClose(m_position.Ticket());

                  if(is_same_symbol(TREND_TYPE,TREND_SEL) &&
                     is_same_symbol(arrHeiken_H4[1].trend_heiken,TREND_BUY)&&
                     is_same_symbol(arrHeiken_H4[0].trend_heiken,TREND_BUY))
                     m_trade.PositionClose(m_position.Ticket());
                 }
               //-------------------------------------------------------------------
               //-------------------------------------------------------------------
               //-------------------------------------------------------------------
               //TRAILING STOP
               if(temp_profit>risk_1L)
                 {
                  double entry_price = m_position.PriceOpen(); // Giá mở lệnh
                  double current_price = SymbolInfoDouble(temp_symbol, SYMBOL_BID); // Giá hiện tại
                  double CONTRACT_SIZE = SymbolInfoDouble(temp_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
                  double temp_profit = m_position.Profit() + m_position.Swap() + m_position.Commission(); // Lợi nhuận hiện tại

                  double current_stop_loss = m_position.StopLoss(); // Lấy giá trị Stop Loss hiện tại
                  double new_stop_loss = current_stop_loss;         // Đặt mặc định là giữ nguyên Stop Loss hiện tại

                  // Nếu lãi >= 2R, đảm bảo lãi 1R khi giá hồi lại
                  if(temp_profit >= 2 * risk_1L)
                    {
                     // Tính vị trí Stop Loss để đảm bảo lãi 1R khi hồi giá
                     double target_stop_loss = (m_position.PositionType() == POSITION_TYPE_BUY)
                                               ? entry_price + risk_1L / CONTRACT_SIZE
                                               : entry_price - risk_1L / CONTRACT_SIZE;

                     // Chỉ cập nhật Stop Loss nếu nó tăng lên
                     if((m_position.PositionType() == POSITION_TYPE_BUY && target_stop_loss > current_stop_loss) ||
                        (m_position.PositionType() == POSITION_TYPE_SELL && target_stop_loss < current_stop_loss))
                       {
                        new_stop_loss = target_stop_loss;
                       }
                    }

                  // Nếu lãi >= 3R, đảm bảo lãi 2R khi giá hồi lại
                  if(temp_profit >= 3 * risk_1L)
                    {
                     // Tính vị trí Stop Loss để đảm bảo lãi 2R khi hồi giá
                     double target_stop_loss = (m_position.PositionType() == POSITION_TYPE_BUY)
                                               ? entry_price + 2 * risk_1L / CONTRACT_SIZE
                                               : entry_price - 2 * risk_1L / CONTRACT_SIZE;

                     // Chỉ cập nhật Stop Loss nếu nó tăng lên
                     if((m_position.PositionType() == POSITION_TYPE_BUY && target_stop_loss > current_stop_loss) ||
                        (m_position.PositionType() == POSITION_TYPE_SELL && target_stop_loss < current_stop_loss))
                       {
                        new_stop_loss = target_stop_loss;
                       }
                    }

                  // Đặt Stop Loss nếu có sự thay đổi theo hướng có lợi
                  if(temp_profit >= risk_1L && current_stop_loss != new_stop_loss)
                    {
                     if(m_trade.PositionModify(m_position.Ticket(), new_stop_loss, m_position.TakeProfit()))
                       {
                        Alert("Trailing Stop thành công tại mức: ", DoubleToString(new_stop_loss, _Digits));
                       }
                     else
                       {
                        Alert("Trailing Stop thất bại với lỗi: ", GetLastError());
                       }
                    }
                 }
              }
        }//for PositionsTotal
      //-----------------------------------------------------------------------------------------------------------
      //REDUCT_LOSS(1R)
      if((risk_1L+total_profit_cur_symbol<0))
        {
         double cur_loss = CloseLargestLosingPosition(temp_symbol);

         string msg = "REDUCT_LOSS(1R) "
                      +"    "+temp_symbol
                      +"    Lossed: "+format_double_to_string(cur_loss,1)+"$";

         PushMessage(msg,FILE_MSG_LIST_SL);

         SendTelegramMessage(temp_symbol,"STOP_LOSS",msg);
        }
      //-----------------------------------------------------------------------------------------------------------
      //-----------------------------------------------------------------------------------------------------------
      //-----------------------------------------------------------------------------------------------------------
      for(int i = OrdersTotal()-1; i >= 0; i--)
         if(m_order.SelectByIndex(i))
           {
            string temp_symbol = m_order.Symbol();
            string trend_reverse = get_trend_reverse(m_order.TypeDescription());

            CandleData arrHeiken_H4[];
            get_arr_heiken(temp_symbol,PERIOD_H4,arrHeiken_H4,50,true,true);

            if(is_same_symbol(trend_reverse, arrHeiken_H4[0].trend_heiken))
              {
               m_trade.OrderDelete(m_order.Ticket());
               continue;
              }
           }
      //-----------------------------------------------------------------------------------------------------------
      //-----------------------------------------------------------------------------------------------------------
      //-----------------------------------------------------------------------------------------------------------
     }
//-------------------------------------------------------------------
//-------------------------------------------------------------------
//-------------------------------------------------------------------
   if(reload)
      OnInit();

   Comment(GetComments());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawChartParent(string symbolUsdt,ENUM_TIMEFRAMES TF, int chart_idx,int total_chart)
  {
   CandleData candleArray[];
   get_arr_heiken(symbolUsdt,TF,candleArray,85,true,true);
   double cur_close_0=SymbolInfoDouble(symbolUsdt,SYMBOL_BID);

   int _digits=cur_close_0>1000?1:cur_close_0>100?3:5;
//--------------------------------------------------------------------------------------------------------
   string STR_DRAW_CHART="Draw_";
   string prefix=STR_DRAW_CHART+get_time_frame_name(TF);
   DeleteAllObjectsWithPrefix(prefix);
   int NUM_CANDLE_DRAW=21;
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
   int chart_heigh=(int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));

   int __sub;
   double __price1,__price2;
   datetime __time1000, __time2000;
   ChartXYToTimePrice(0, 10,795,__sub, __time1000,__price1);
   ChartXYToTimePrice(0,320,800,__sub, __time2000,__price2);
   double __priceHig5=MathAbs(__price1-__price2);

   double btc_price_high, btc_price_low;
   datetime _time1, _time2;
   int _sub_windows;
   ChartXYToTimePrice(0,10,70,            _sub_windows,_time1,btc_price_high);
   ChartXYToTimePrice(0,10,chart_heigh-27,_sub_windows,_time2,btc_price_low);

   double canvas_high = (btc_price_high-btc_price_low)/total_chart;

   int _width=3;
   if(chart_idx==1)
     {
      btc_price_low=btc_price_high-canvas_high*1+__priceHig5*1;
      createButton(prefix+"BG","",0,40,792,chart_heigh-10,clrBlack,clrWhite);
     }

   if(chart_idx==2)
     {
      btc_price_high=btc_price_high-canvas_high*1-__priceHig5*2;
      btc_price_low=btc_price_high-canvas_high+__priceHig5*1;
     }

   if(chart_idx==3)
     {
      btc_price_high=btc_price_high-canvas_high*2-__priceHig5*3;
      btc_price_low=btc_price_high-canvas_high*1+__priceHig5*1;
     }

   if(chart_idx==4)
     {
      btc_price_high=btc_price_high-canvas_high*3-__priceHig5*4;
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

   datetime shift=TimeCurrent()-__time1000; // add_time*(NUM_CANDLE_DRAW+11);
   if(chart_idx>0)
      shift=TimeCurrent()-__time2000; // add_time*6;

   datetime GLOBAL_TIME_OF_ONE_CANDLE = TIME_OF_ONE_H4_CANDLE*2;

   datetime add_time=GLOBAL_TIME_OF_ONE_CANDLE;
   if(ada_range>0 && btc_range>0)
     {
      //double PERCENT=0;
      double lowest=DBL_MAX,higest=0.0;

      datetime start_time=__time2000-GLOBAL_TIME_OF_ONE_CANDLE*size_d1*2;
      datetime end_time=__time2000+GLOBAL_TIME_OF_ONE_CANDLE*4;
      datetime heiken_end_time = end_time;
      datetime tool_tip_time=candleArray[(int)(size_d1*2/3)].time-GLOBAL_TIME_OF_ONE_CANDLE-shift;

      datetime mid_chart_time = _time1;
      datetime str_chart_time = _time1;
      for(int i = 0; i < size_d1; i++)
        {
         double ma05_i0=(candleArray[i].ma05-  ada_mid)*normalization_factor + btc_mid +offset;
         double ma05_i1=(candleArray[i+1].ma05-ada_mid)*normalization_factor + btc_mid +offset;

         double ma10_i0=(candleArray[i].ma10-  ada_mid)*normalization_factor + btc_mid +offset;
         double ma10_i1=(candleArray[i+1].ma10-ada_mid)*normalization_factor + btc_mid +offset;

         double ma20_i0=(candleArray[i].ma20-  ada_mid)*normalization_factor + btc_mid +offset;
         double ma20_i1=(candleArray[i+1].ma20-ada_mid)*normalization_factor + btc_mid +offset;

         double ma50_i0=(candleArray[i].ma50-  ada_mid)*normalization_factor + btc_mid +offset;
         double ma50_i1=(candleArray[i+1].ma50-ada_mid)*normalization_factor + btc_mid +offset;

         datetime time1,time2,time_mid;
         double ___;
         int ____;
         ChartXYToTimePrice(0,350-(i+0)*16,100,____, time1,___);
         ChartXYToTimePrice(0,350-(i+0)*16+8,100,____, time_mid,___);
         ChartXYToTimePrice(0,350-(i-1)*16,100,____, time2,___);
         if(i==13)
            mid_chart_time=time2;
         if(i==size_d1-1)
            str_chart_time=time1-GLOBAL_TIME_OF_ONE_CANDLE;

         double open= (candleArray[i].open-    ada_mid)*normalization_factor + btc_mid +offset;
         double close=(candleArray[i].close-   ada_mid)*normalization_factor + btc_mid +offset;
         double low= (candleArray[i].low-      ada_mid)*normalization_factor + btc_mid +offset;
         double high= (candleArray[i].high-    ada_mid)*normalization_factor + btc_mid +offset;

         string trend=candleArray[i].trend_heiken;
         color clrBody=is_same_symbol(trend,TREND_BUY)?clrTeal:clrDimGray;

         create_heiken_candle(prefix+"hei_"+appendZero100(i)
                              ,time1
                              ,time_mid
                              ,time2,open,close,low,high,clrBody,true,1,0
                              ,candleArray[i].count_heiken
                              ,candleArray[i].trend_heiken==TREND_BUY?clrBlack:clrRed);

         double candlestick_open= (candleArray[i].candlestick_open-    ada_mid)*normalization_factor + btc_mid +offset;
         double candlestick_close=(candleArray[i].candlestick_close-   ada_mid)*normalization_factor + btc_mid +offset;
         double candlestick_low= (candleArray[i].candlestick_low-      ada_mid)*normalization_factor + btc_mid +offset;
         double candlestick_high= (candleArray[i].candlestick_high-    ada_mid)*normalization_factor + btc_mid +offset;

         datetime candlestick_time1,candlestick_time2,candlestick_time_mid;
         ChartXYToTimePrice(0,750-(i+0)*16,100,____, candlestick_time1,___);
         ChartXYToTimePrice(0,750-(i+0)*16+8,100,____, candlestick_time_mid,___);
         ChartXYToTimePrice(0,750-(i-1)*16,100,____, candlestick_time2,___);
         color clrCandle=candleArray[i].candlestick_open<candleArray[i].candlestick_close?clrTeal:clrBlack;

         create_heiken_candle(prefix+"candle_"+appendZero100(i)
                              ,candlestick_time1
                              ,candlestick_time_mid
                              ,candlestick_time2
                              ,candlestick_open,candlestick_close,candlestick_low,candlestick_high
                              ,clrCandle,true,1,0
                              ,candleArray[i].count_ma10
                              ,candleArray[i].trend_by_ma10==TREND_BUY?clrBlue:clrRed);

         if(ma05_i1>=0 && ma05_i0>=0 && ma05_i0>=btc_price_low && ma05_i0<=btc_price_high)
           {
            create_trend_line(prefix+"Ma05_"+appendZero100(i+1)+"_"+appendZero100(i),
                              time1,ma05_i1,time2,ma05_i0,clrBlack,STYLE_SOLID,2,false,false,true,false);

            create_trend_line(prefix+"Ma05_Candlestick_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candlestick_time1,ma05_i1,candlestick_time2,ma05_i0,clrBlack,STYLE_SOLID,2,false,false,true,false);
           }

         if(ma10_i1>=0 && ma10_i0>=0 && ma10_i0>=btc_price_low && ma10_i0<=btc_price_high)
           {
            create_trend_line(prefix+"Ma10_"+appendZero100(i+1)+"_"+appendZero100(i),
                              time1,ma10_i1,time2,ma10_i0,clrRed,STYLE_SOLID,2,false,false,true,false);

            create_trend_line(prefix+"Ma10_Candlestick_"+appendZero100(i+1)+"_"+appendZero100(i),
                              candlestick_time1,ma10_i1,candlestick_time2,ma10_i0,clrRed,STYLE_SOLID,2,false,false,true,false);
           }

         if(ma20_i1>=0 && ma20_i0>=0 && ma20_i0>=btc_price_low && ma20_i0<=btc_price_high)
           {
            create_trend_line(prefix+"Ma20_"+appendZero100(i+1)+"_"+appendZero100(i),
                              time1,ma20_i1,time2,ma20_i0,clrBlue,STYLE_SOLID,2,false,false,true,false);

            if(chart_idx>=3)
               create_trend_line(prefix+"Ma20_Candlestick_"+appendZero100(i+1)+"_"+appendZero100(i),
                                 candlestick_time1,ma20_i1,candlestick_time2,ma20_i0,clrBlue,STYLE_SOLID,2,false,false,true,false);
           }

         if(ma50_i1>=0 && ma50_i0>=0 && ma50_i0>=btc_price_low && ma50_i0<=btc_price_high)
           {
            create_trend_line(prefix+"Ma50_"+appendZero100(i+1)+"_"+appendZero100(i),
                              time1,ma50_i1,time2,ma50_i0,clrDimGray,STYLE_SOLID,3,false,false,true,false);

            if(chart_idx>=3)
               create_trend_line(prefix+"Ma50_Candlestick_"+appendZero100(i+1)+"_"+appendZero100(i),
                                 candlestick_time1,ma50_i1,candlestick_time2,ma50_i0,clrDimGray,STYLE_SOLID,3,false,false,true,false);
           }

         if(lowest>low)
            lowest=low;
         if(higest<high)
            higest=high;
         if(i==0)
           {
            heiken_end_time=time2+GLOBAL_TIME_OF_ONE_CANDLE*0;
            end_time=candlestick_time2+TIME_OF_ONE_H1_CANDLE*1;
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

      double sai_so=lowest*0.025;
      double price=(cur_close_0-ada_mid)*normalization_factor + btc_mid+offset;

      datetime draw_fibo_time = (datetime)(start_time+add_time*2);
      color clrColor = is_same_symbol(candleArray[0].trend_heiken,TREND_BUY)?clrBlue:clrRed;

      create_trend_line(prefix+"HIGEST_"+DoubleToString(real_higest,5),       draw_fibo_time, higest,   end_time,higest,    clrRed,  STYLE_SOLID,  1,false,false,true,false);
      create_trend_line(prefix+"LOWEST_"+DoubleToString(real_lowest,5),       draw_fibo_time, lowest,   end_time,lowest,    clrBlue, STYLE_SOLID,  1,false,false,true,false);
      create_trend_line(prefix+"fibo_0118_"+DoubleToString(fibo_real_0_118,5),draw_fibo_time,fibo_0_118,end_time,fibo_0_118,clrRed,  STYLE_SOLID,  1,false,false,true,false);
      create_trend_line(prefix+"fibo_0236_"+DoubleToString(fibo_real_0_236,5),draw_fibo_time,fibo_0_236,end_time,fibo_0_236,clrRed,  STYLE_SOLID,  1,false,false,true,false);
      create_trend_line(prefix+"fibo_0382_"+DoubleToString(fibo_real_0_382,5),draw_fibo_time,fibo_0_382,end_time,fibo_0_382,clrBlack,STYLE_DOT,    1,false,false,true,false);
      create_trend_line(prefix+"fibo_0500_"+DoubleToString(fibo_real_0_500,5),draw_fibo_time,fibo_0_500,end_time,fibo_0_500,clrBlack,STYLE_DASHDOT,1,false,false,true,false);
      create_trend_line(prefix+"fibo_0618_"+DoubleToString(fibo_real_0_618,5),draw_fibo_time,fibo_0_618,end_time,fibo_0_618,clrBlack,STYLE_DOT,    1,false,false,true,false);
      create_trend_line(prefix+"fibo_0786_"+DoubleToString(fibo_real_0_786,5),draw_fibo_time,fibo_0_786,end_time,fibo_0_786,clrBlue, STYLE_SOLID,  1,false,false,true,false);
      create_trend_line(prefix+"fibo_0886_"+DoubleToString(fibo_real_0_886,5),draw_fibo_time,fibo_0_886,end_time,fibo_0_886,clrBlue, STYLE_SOLID,  1,false,false,true,false);

      color clrBreak = is_same_symbol(candleArray[0].trend_by_ma10,TREND_BUY)?clrTeal:clrFireBrick;
      //create_trend_line(prefix+"BREAK_"+DoubleToString(lowest-__priceHig5,5), draw_fibo_time, lowest-__priceHig5,  end_time,lowest-__priceHig5,clrBreak, STYLE_SOLID,5,false,false,true,false);

      string seq="";
      if(candleArray[0].ma10>candleArray[0].ma20 && candleArray[0].ma20>candleArray[0].ma50)
         seq=TREND_BUY;
      if(candleArray[0].ma10<candleArray[0].ma20 && candleArray[0].ma20<candleArray[0].ma50)
         seq=TREND_SEL;
      if(seq!="")
         create_label_simple(prefix+"Seq"," SEQ_"+seq+" ",fibo_0_382+__priceHig5*3,seq==TREND_BUY?clrBlue:clrRed,heiken_end_time,0,12);

      create_label_simple(prefix," ("+get_time_frame_name(TF)+") "+get_consistent_symbol(symbolUsdt),fibo_0_500+__priceHig5*1.5,clrBreak,heiken_end_time,0,12);

      double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbolUsdt);
      double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbolUsdt);
      double TP1 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_11,OBJPROP_PRICE),5);
      double TP2 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_12,OBJPROP_PRICE),5);
      double TP3 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_13,OBJPROP_PRICE),5);

      double price_here = (cur_close_0-ada_mid)*normalization_factor + btc_mid +offset;
      double fake_SL =(SL-  ada_mid)*normalization_factor + btc_mid +offset;
      double fake_LM =(LM-  ada_mid)*normalization_factor + btc_mid +offset;
      double fake_TP1=(TP1- ada_mid)*normalization_factor + btc_mid +offset;
      double fake_TP2=(TP2- ada_mid)*normalization_factor + btc_mid +offset;
      double fake_TP3=(TP3- ada_mid)*normalization_factor + btc_mid +offset;

      create_trend_line(prefix+"Here"+DoubleToString(price_here,5)
                        ,end_time,price_here,end_time+1,price_here,clrColor,STYLE_DOT,10,false,false,true,false);

      datetime time = end_time-GLOBAL_TIME_OF_ONE_CANDLE*7;
      if(fake_SL>=btc_price_low && fake_SL<=btc_price_high)
         create_trend_line(prefix+"SL"+DoubleToString(fake_SL,5),time,fake_SL,end_time,fake_SL,clrRed,             STYLE_DOT,2,false,false,true,false);

      if(fake_LM>=btc_price_low && fake_LM<=btc_price_high)
         create_trend_line(prefix+"LM"+DoubleToString(fake_LM,5),time,fake_LM,end_time,fake_LM,clrGreen,           STYLE_DOT,2,false,false,true,false);

      if(fake_TP1>=btc_price_low && fake_TP1<=btc_price_high)
         create_trend_line(prefix+"TP1_"+DoubleToString(fake_TP1,5),time,fake_TP1,end_time,fake_TP1,clrBlue,       STYLE_DOT,2,false,false,true,false);

      if(fake_TP2>=btc_price_low && fake_TP2<=btc_price_high)
         create_trend_line(prefix+"TP2_"+DoubleToString(fake_TP2,5),time,fake_TP2,end_time,fake_TP2,clrIndigo,     STYLE_DOT,2,false,false,true,false);

      if(fake_TP3>=btc_price_low && fake_TP3<=btc_price_high)
         create_trend_line(prefix+"TP3_"+DoubleToString(fake_TP3,5),time,fake_TP3,end_time,fake_TP3,clrFireBrick,  STYLE_DOT,2,false,false,true,false);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init_sl_tp_trendline(bool is_reset_sl,bool reverse_ma10d1=false)
  {
   string symbol=Symbol();
   bool is_cur_tab=is_same_symbol(symbol,Symbol());
   if(is_cur_tab ==false)
      return;

   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
   double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   string total_comments="";
   string strBSL=CountBSL(symbol,total_comments,true);

   if(LM<=0 || SL<=0 || is_reset_sl)
     {
      CandleData arrHeiken_tf[];
      get_arr_heiken(symbol,PERIOD_H4,arrHeiken_tf,25,true,false);

      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      if(is_same_symbol(arrHeiken_tf[0].trend_by_ma10,TREND_BUY))
         SL=NormalizeDouble(arrHeiken_tf[0].lowest,digits);

      if(is_same_symbol(arrHeiken_tf[0].trend_by_ma10,TREND_SEL))
         SL=NormalizeDouble(arrHeiken_tf[0].higest,digits);

      LM=bid;
      SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL);
      SetGlobalVariable(GLOBAL_VAR_LM+symbol,bid);
     }

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);

   int chart_width=(int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh=(int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));

   string trend=(SL>LM)?TREND_SEL:TREND_BUY;
   color curColor=(SL>LM)?clrActiveSell:clrActiveBtn;
   double amp_sl=NormalizeDouble(MathAbs(LM-SL),digits);
   double amp_trade_now=NormalizeDouble(MathAbs(bid-SL),digits);

   double risk=Risk_1L();
   double volme_by_amp_sl=calc_volume_by_amp(symbol,amp_sl,risk);
   double volme_by_amp_w1=calc_volume_by_amp(symbol,amp_w1,risk);

   string strRev=get_trend_reverse(trend)+" "+(string)volme_by_amp_sl;

   datetime time=TimeCurrent();
   double rr11=trend==TREND_BUY?LM+amp_sl*1:LM-amp_sl*1;
   double rr12=trend==TREND_BUY?LM+amp_sl*2:LM-amp_sl*2;
   double rr13=trend==TREND_BUY?LM+amp_sl*3:LM-amp_sl*3;
   double rr14=trend==TREND_BUY?LM+amp_sl*4:LM-amp_sl*4;
   double rr15=trend==TREND_BUY?LM+amp_sl*5:LM-amp_sl*5;


   create_dragable_trendline(GLOBAL_VAR_SL,clrRed,  SL,STYLE_SOLID,2);
   create_dragable_trendline(GLOBAL_VAR_LM,clrGreen,LM,STYLE_SOLID,2);

   create_dragable_trendline(LINE_RR_11,clrBlue,       rr11,STYLE_SOLID,2);
   create_dragable_trendline(LINE_RR_12,clrIndigo,     rr12,STYLE_SOLID,2);
   create_dragable_trendline(LINE_RR_13,clrFireBrick,  rr13,STYLE_SOLID,2);

//bool is_hide_mode=GetGlobalVariable(BtnHideDrawMode)==AUTO_TRADE_ONN;
   if(true)
     {
      int _sub_windows;
      datetime _time;
      double _price;
      if(ChartXYToTimePrice(0,chart_width/2,chart_heigh/2,_sub_windows,_time,_price))
        {
         create_label_simple("Note_SL","SL",SL,clrBlack,time+TIME_OF_ONE_D1_CANDLE);

         for(int rr=-1;rr<=10;rr++)
           {
            double rr14=trend==TREND_BUY?LM+amp_sl*rr:LM-amp_sl*rr;
            //if((SL>LM && rr14>LM) || (SL<LM && rr14<LM))
            //   continue;

            string LINE_RR_14="LINE_RR 1:"+(string)rr;
            create_label_simple("RR"+(string)rr,""+(string)rr+"",rr14,clrBlack,time+TIME_OF_ONE_D1_CANDLE);

            if(rr>3 || rr<0)
               create_dragable_trendline(LINE_RR_14,clrFireBrick,rr14,STYLE_SOLID,1,false);
           }
        }
     }

   int x,y_start;
   int x_start = chart_width-150;

   if(ChartTimePriceToXY(0,0,time,rr11,x,y_start))
      createButton(BtnSetTPHereR1,"TP."+getShortName(trend)+".1",x_start+50,y_start-10,100,20,clrBlack,curColor);

   if(ChartTimePriceToXY(0,0,time,rr12,x,y_start))
      createButton(BtnSetTPHereR2,"TP."+getShortName(trend)+".2",x_start+50,y_start-10,100,20,clrBlack,clrWhite);

   if(ChartTimePriceToXY(0,0,time,rr13,x,y_start))
      createButton(BtnSetTPHereR3,"TP."+getShortName(trend)+".3",x_start+50,y_start-10,100,20,clrBlack,clrWhite);

   if(strBSL=="" && is_same_symbol(symbol,"XAUUSD"))
     {
      string xau1 = "" + DoubleToString(rr11*108/3230,2) + " tr";
      string xau2 = "" + DoubleToString(rr12*108/3230,2) + " tr";
      string xau3 = "" + DoubleToString(rr13*108/3230,2) + " tr";
      ObjectSetString(0,BtnSetTPHereR1,OBJPROP_TEXT,"(TP1) "+xau1);
      ObjectSetString(0,BtnSetTPHereR2,OBJPROP_TEXT,"(TP2) "+xau2);
      ObjectSetString(0,BtnSetTPHereR3,OBJPROP_TEXT,"(TP3) "+xau3);
     }

   if(ChartTimePriceToXY(0,0,time,LM,x,y_start))
     {
      createButton(BtnSetTimeHere+".iHigh","Hig",chart_width-35*1,y_start-10,30,20,clrBlack,clrYellow);
      createButton(BtnSetTimeHere+".iLow", "Low",chart_width-35*2,y_start-10,30,20,clrBlack,clrYellow);
      createButton(BtnSetTimeHere+".iMid", "Mid",chart_width-35*3,y_start-10,30,20,clrBlack,clrYellow);
      createButton(BtnSetTimeHere+".iMaH10","Ma10",chart_width-35*4,y_start-10,30,20,clrBlack,clrYellow);
      createButton(BtnSetTimeHere+".iMaH20","Ma20",chart_width-35*5,y_start-10,30,20,clrBlack,clrYellow);
      createButton(BtnSetTimeHere+".iMaH50","Ma50",chart_width-35*6,y_start-10,30,20,clrBlack,clrYellow);
     }

   if(ChartTimePriceToXY(0,0,time,SL,x,y_start))
     {
      createButton(BtnSetSLHere,"Set SL", 1500,  y_start-10,60,20,clrBlack,clrWhite);

      createButton(BtnFindSL+"_D1","7W",chart_width-35*3, y_start-10,30,20,clrBlack,clrYellow);
      createButton(BtnFindSL+"_H4","7D",chart_width-35*2, y_start-10,30,20,clrBlack,clrActiveBtn);
      createButton(BtnFindSL+"_H1","H4",chart_width-35*1, y_start-10,30,20,clrBlack,clrActiveBtn);
     }

//if(ChartTimePriceToXY(0,0,time,SL,x,y_start))
//

   createButton(BtnOpenStop1L,trend + " STOP "+ get_consistent_symbol(symbol) + " " + DoubleToString(volme_by_amp_sl,2)+ "lot ~ R: " + DoubleToString(risk,1)+"$"
                ,chart_width/2-200+10+265+50-260,5,250,25,clrBlack,is_same_symbol(trend,TREND_BUY)?clrActiveBtn:clrActiveSell,7,1);


   int opening=PositionsTotal();
   int btn_width=BTN_WIDTH_STANDA;
   string limit=LM<bid&&is_same_symbol(trend,TREND_BUY)?" LIMIT":LM>bid&&is_same_symbol(trend,TREND_SEL)?" LIMIT":"";
   color clrColorByBSL = is_same_symbol(strBSL,"$") && is_same_symbol(strBSL,"+")?clrBlue:clrRed;

   ObjectDelete(0,BtnCloseLimit);
   if(is_same_symbol(strBSL,"oB") || is_same_symbol(strBSL,"oS"))
      createButton(BtnCloseLimit,"Close Limit "+symbol,chart_width/2-325,5,BTN_WIDTH_STANDA,25,clrBlack,clrLightGray,7,1);


   if(is_same_symbol(strBSL,"B") || is_same_symbol(strBSL,"S"))
      createButton(BtnTpPositiveThisSymbol,"(TP+) "+symbol+" "+GetTempProfit(symbol),5,5,280,35,
                   clrColorByBSL,clrWhite,7,4);


   ObjectDelete(0,BtnCloseSymbol);
   if(is_same_symbol(strBSL,"$"))
      createButton(BtnCloseSymbol,"Close "+symbol+" "+strBSL,100,10,200,25,clrColorByBSL,clrWhite,7, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_Doji(string symbol, ENUM_TIMEFRAMES TradingPeriod, int candleIndex)
  {
   double body_normal = MathAbs(iOpen(symbol,TradingPeriod,candleIndex)-iClose(symbol,TradingPeriod,candleIndex));
   double upper_beard_normal = iHigh(symbol,TradingPeriod,candleIndex) - MathMax(iOpen(symbol,TradingPeriod,candleIndex), iClose(symbol,TradingPeriod,candleIndex));
   double lower_beard_normal = MathMin(iOpen(symbol,TradingPeriod,candleIndex), iClose(symbol,TradingPeriod,candleIndex)) - iLow(symbol,TradingPeriod,candleIndex);
   bool is_doji_normal = (upper_beard_normal>body_normal*2) && (lower_beard_normal>body_normal*2);

   return is_doji_normal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_Om(string &strResultOm, string symbol, ENUM_TIMEFRAMES TradingPeriod, int candleIndex)
  {
   strResultOm = "";

   double body_low2 = MathMin(iOpen(symbol,TradingPeriod,candleIndex+1), iClose(symbol,TradingPeriod,candleIndex+1));
   double body_hig2 = MathMax(iOpen(symbol,TradingPeriod,candleIndex+1), iClose(symbol,TradingPeriod,candleIndex+1));
   double body_low1 = MathMin(iOpen(symbol,TradingPeriod,candleIndex), iClose(symbol,TradingPeriod,candleIndex));
   double body_hig1 = MathMax(iOpen(symbol,TradingPeriod,candleIndex), iClose(symbol,TradingPeriod,candleIndex));

   bool is_om2 = (iLow(symbol,TradingPeriod,candleIndex+1) < iLow(symbol,TradingPeriod,candleIndex)  && iHigh(symbol,TradingPeriod,candleIndex+1) > iHigh(symbol,TradingPeriod,candleIndex));
   bool is_om2_body = (body_low2 < body_low1  && body_hig2 > body_hig1);

   bool is_om1 = (iLow(symbol,TradingPeriod,candleIndex+1) > iLow(symbol,TradingPeriod,candleIndex)  && iHigh(symbol,TradingPeriod,candleIndex+1) < iHigh(symbol,TradingPeriod,candleIndex));
   bool is_om1_body = (body_low2 > body_low1  && body_hig2 < body_hig1);

   if(is_om2 || is_om2_body || is_om1 || is_om1_body)
     {
      strResultOm = "C:"+(is_om2?"2.OmHL":"")+" "+(is_om2_body?"2.OmOC":"")+" "+(is_om1?"1.OmHL":"")+" "+(is_om1_body?"1.OmOC":"");
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES getOpenTfTrading(string comments)
  {
   ENUM_TIMEFRAMES TradingPeriod = (ENUM_TIMEFRAMES)GetGlobalVariable(BtnOptionPeriod);
   if(TradingPeriod<0)
      TradingPeriod=PERIOD_H4;

   if(is_same_symbol(comments, MASK_TIMEFRAME_TRADING))
     {
      if(is_same_symbol(comments, MASK_TIMEFRAME_TRADING+get_time_frame_name(PERIOD_D1)))
         return PERIOD_D1;
      if(is_same_symbol(comments, MASK_TIMEFRAME_TRADING+get_time_frame_name(PERIOD_H4)))
         return PERIOD_H4;
      if(is_same_symbol(comments, MASK_TIMEFRAME_TRADING+get_time_frame_name(PERIOD_H1)))
         return PERIOD_H1;
      if(is_same_symbol(comments, MASK_TIMEFRAME_TRADING+get_time_frame_name(PERIOD_M30)))
         return PERIOD_M30;
      if(is_same_symbol(comments, MASK_TIMEFRAME_TRADING+get_time_frame_name(PERIOD_M15)))
         return PERIOD_M15;
      if(is_same_symbol(comments, MASK_TIMEFRAME_TRADING+get_time_frame_name(PERIOD_M5)))
         return PERIOD_M5;
     }

   return TradingPeriod;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getAlertOpenTradeMsg(string symbol, ENUM_TIMEFRAMES TradingPeriod, string TREND_REF, bool checkMa200, bool checkCountOk=false)
  {
   string  msg_r1c1 = "";

   bool is_ref_allow = true;
   if(is_same_symbol(TREND_REF,TREND_BUY) || is_same_symbol(TREND_REF,TREND_SEL))
     {
      if(checkMa200)
        {
         int count_ma10_vs_ma20=0;
         string trend_seq200 = CheckSeqMa10205020(symbol,TradingPeriod,count_ma10_vs_ma20);

         is_ref_allow = is_same_symbol(TREND_REF, trend_seq200);
        }

      if(is_ref_allow)
        {
         CandleData arrHeiken_Cr[];
         get_arr_heiken(symbol,TradingPeriod,arrHeiken_Cr,55,true,true);

         if(is_same_symbol(TREND_REF, arrHeiken_Cr[0].trend_heiken) &&
            is_same_symbol(TREND_REF, arrHeiken_Cr[0].trend_by_ma10) &&
            is_same_symbol(TREND_REF, arrHeiken_Cr[0].trend_by_ma20) &&
            is_same_symbol(TREND_REF, arrHeiken_Cr[0].trend_by_ma50) &&
            (arrHeiken_Cr[0].count_ma10<=3 || arrHeiken_Cr[0].count_ma20<=3 || arrHeiken_Cr[0].count_heiken<=3 || checkCountOk))
           {
            msg_r1c1 = symbol+" "+ get_time_frame_name((ENUM_TIMEFRAMES)TradingPeriod)+" (Seq200) "+ TREND_REF;
           }
        }

     }

   return msg_r1c1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_ftmo_account()
  {
   bool ftmo_account=false;
   long login=AccountInfoInteger(ACCOUNT_LOGIN);
   if(is_same_symbol(ACCOUNT_FTMO,(string)login))
      ftmo_account = true;

   return ftmo_account;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendNoticeMaCross(string symbol)
  {
//----------------------------------------------------------------------------------------------------
   string key_H4=BtnNoticeMaCross+symbol+"_H4";
   string find_trend_H4=(string)GetGlobalVariable(key_H4);

   string key_H1=BtnNoticeMaCross+symbol+"_H1";
   string find_trend_H1=(string)GetGlobalVariable(key_H1);

   if(false && is_same_symbol(find_trend_H1,HeivsSeqMa102050_BUY)==false && is_same_symbol(find_trend_H1,HeivsSeqMa102050_SEL)==false)
     {
      CandleData arrHeiken_H1[];
      get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,55,true,true);

      if(is_same_symbol(TREND_BUY, arrHeiken_H1[0].trend_by_seq_102050)) //TREND_BUY
         find_trend_H1+=HeivsSeqMa102050_SEL;

      if(is_same_symbol(TREND_SEL, arrHeiken_H1[0].trend_by_seq_102050)) //TREND_SEL
         find_trend_H1+=HeivsSeqMa102050_BUY;

      SetGlobalVariable(key_H1,(double)find_trend_H1);
     }
//----------------------------------------------------------------------------------------------------
   if(false && is_same_symbol(find_trend_H1,HeivsSeqMa102050200_BUY)==false && is_same_symbol(find_trend_H1,HeivsSeqMa102050200_SEL)==false)
     {
      double ma10=cal_MA_XX(symbol,PERIOD_H1,10,0);
      double ma200=cal_MA_XX(symbol,PERIOD_H1,200,0);

      if(ma10>ma200) //TREND_BUY
         find_trend_H1+=HeivsSeqMa102050200_SEL;

      if(ma10<ma200) //TREND_SEL
         find_trend_H1+=HeivsSeqMa102050200_BUY;

      SetGlobalVariable(key_H1,(double)find_trend_H1);
     }
//----------------------------------------------------------------------------------------------------
   if(false && is_same_symbol(find_trend_H4,HeikenCandleC2_BUY)==false && is_same_symbol(find_trend_H4,HeikenCandleC2_SEL)==false)
     {
      if(false && allow_PushMessage(symbol,FILE_MSG_LIST_WAIT))
        {
         CandleData arrHeiken_D1[];
         get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,55,true,true);

         bool d1_allow_buy =  is_same_symbol(TREND_BUY,arrHeiken_D1[0].trend_by_ma10) &&
                              is_same_symbol(TREND_BUY,arrHeiken_D1[0].trend_heiken) ;

         bool d1_allow_sel =  is_same_symbol(TREND_SEL,arrHeiken_D1[0].trend_by_ma10) &&
                              is_same_symbol(TREND_SEL,arrHeiken_D1[0].trend_heiken);

         if(d1_allow_buy && arrHeiken_D1[1].count_heiken<7) //TREND_BUY
           {
            find_trend_H4+=HeikenCandleC2_BUY;
            SetGlobalVariable(key_H4,(double)find_trend_H4);
           }

         if(d1_allow_sel && arrHeiken_D1[1].count_heiken<7) //TREND_SEL
           {
            find_trend_H4+=HeikenCandleC2_SEL;
            SetGlobalVariable(key_H4,(double)find_trend_H4);
           }
        }
     }

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
   if(is_same_symbol(find_trend_H4,HeikenCandleC2_BUY) || is_same_symbol(find_trend_H4,HeikenCandleC2_SEL))
     {
      string account_name = AccountInfoString(ACCOUNT_NAME);

      CandleData arrHeiken_H4[];
      get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,55,true,true);

      CandleData arrHeiken_H1[];
      get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,55,true,true);

      bool h4_allow_buy = is_same_symbol(TREND_BUY,arrHeiken_H4[1].trend_heiken) &&
                          is_same_symbol(TREND_BUY,arrHeiken_H4[0].trend_heiken);

      bool h4_allow_sel = is_same_symbol(TREND_SEL,arrHeiken_H4[1].trend_heiken) &&
                          is_same_symbol(TREND_SEL,arrHeiken_H4[0].trend_heiken);

      bool h1_allow_buy = is_same_symbol(TREND_BUY,arrHeiken_H1[1].trend_heiken) &&
                          is_same_symbol(TREND_BUY,arrHeiken_H1[0].trend_heiken);

      bool h1_allow_sel = is_same_symbol(TREND_SEL,arrHeiken_H1[1].trend_heiken) &&
                          is_same_symbol(TREND_SEL,arrHeiken_H1[0].trend_heiken);

      if(is_same_symbol(find_trend_H4,HeikenCandleC2_BUY) || is_same_symbol(find_trend_H4,HeikenCandleC2_SEL))
        {
         if(h4_allow_buy && arrHeiken_H4[0].count_heiken<=3
            && is_same_symbol(arrHeiken_H4[0].trend_by_ma10, arrHeiken_H4[0].trend_heiken)
            && is_same_symbol(find_trend_H4,HeikenCandleC2_BUY))
           {
            StringReplace(find_trend_H4,HeikenCandleC2_BUY,"");
            SetGlobalVariable(key_H4,(double)find_trend_H4);

            string msg1=" (Tel) "+symbol+" H4 No.1.2_BUY";
            string msg2=" ("+account_name+") "+symbol+" H4 No.1.2_BUY";
            string total_comments="";
            string strBSL=CountBSL(symbol,total_comments);
            if(is_same_symbol(strBSL,"$")==false)
               if(h1_allow_buy && allow_PushMessage(msg1,FILE_MSG_LIST_WAIT))
                 {
                  SendTelegramMessage(symbol,TREND_BUY,msg2);
                  PushMessage(msg1,FILE_MSG_LIST_WAIT);
                 }
           }


         if(h4_allow_sel && arrHeiken_H4[0].count_heiken<=3
            && is_same_symbol(arrHeiken_H4[0].trend_by_ma10, arrHeiken_H4[0].trend_heiken)
            && is_same_symbol(find_trend_H4,HeikenCandleC2_SEL))
           {
            StringReplace(find_trend_H4,HeikenCandleC2_SEL,"");
            SetGlobalVariable(key_H4,(double)find_trend_H4);

            string msg1=" (Tel) "+symbol+" H4 No.1.2_SELL";
            string msg2=" ("+account_name+") "+symbol+" H4 No.1.2_SELL";
            string total_comments="";
            string strBSL=CountBSL(symbol,total_comments);
            if(is_same_symbol(strBSL,"$")==false)
               if(h1_allow_sel && allow_PushMessage(msg1,FILE_MSG_LIST_WAIT))
                 {
                  SendTelegramMessage(symbol,TREND_SEL,msg2);
                  PushMessage(msg1,FILE_MSG_LIST_WAIT);
                 }
           }
        }
     }

   if(is_same_symbol(find_trend_H1,HeikenCandleC2_BUY) || is_same_symbol(find_trend_H1,HeikenCandleC2_SEL))
     {
      string account_name = AccountInfoString(ACCOUNT_NAME);

      CandleData arrHeiken_H1[];
      get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,55,true,true);

      bool h1_allow_buy = is_same_symbol(TREND_BUY,arrHeiken_H1[1].trend_heiken) &&
                          is_same_symbol(TREND_BUY,arrHeiken_H1[0].trend_heiken);

      bool h1_allow_sel = is_same_symbol(TREND_SEL,arrHeiken_H1[1].trend_heiken) &&
                          is_same_symbol(TREND_SEL,arrHeiken_H1[0].trend_heiken);


      if(h1_allow_buy && arrHeiken_H1[0].count_heiken>1 && arrHeiken_H1[0].count_heiken<=3 && is_same_symbol(find_trend_H1,HeikenCandleC2_BUY))
        {
         StringReplace(find_trend_H1,HeikenCandleC2_BUY,"");
         SetGlobalVariable(key_H1,(double)find_trend_H1);

         string msg1=" (Tel) "+symbol+" H1 No.1.2|3_BUY";
         string msg2=" ("+account_name+") "+symbol+" H1 No.1.2|3_BUY";

         if(allow_PushMessage(msg1,FILE_MSG_LIST_WAIT))
           {
            PushMessage(msg1,FILE_MSG_LIST_WAIT);

            SendTelegramMessage(symbol,TREND_BUY,msg2);
           }
        }


      if(h1_allow_sel && arrHeiken_H1[0].count_heiken>1 && arrHeiken_H1[0].count_heiken<=3 && is_same_symbol(find_trend_H1,HeikenCandleC2_SEL))
        {
         StringReplace(find_trend_H1,HeikenCandleC2_SEL,"");
         SetGlobalVariable(key_H1,(double)find_trend_H1);

         string msg1=" (Tel) "+symbol+" H1 No.1.2|3_SELL";
         string msg2=" ("+account_name+") "+symbol+" H1 No.1.2|3_SELL";
         if(allow_PushMessage(msg1,FILE_MSG_LIST_WAIT))
           {
            PushMessage(msg1,FILE_MSG_LIST_WAIT);

            SendTelegramMessage(symbol,TREND_SEL,msg2);
           }
        }
     }

//-----------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
   if(is_same_symbol(find_trend_H1,HeivsMa10_BUY) || is_same_symbol(find_trend_H1,HeivsMa10_SEL) ||

      is_same_symbol(find_trend_H1,HeivsMa20_BUY) || is_same_symbol(find_trend_H1,HeivsMa50_BUY) ||
      is_same_symbol(find_trend_H1,HeivsMa20_SEL) || is_same_symbol(find_trend_H1,HeivsMa50_SEL) ||
      is_same_symbol(find_trend_H1,HeivsSeqMa102050_BUY) || is_same_symbol(find_trend_H1,HeivsSeqMa102050200_BUY) ||
      is_same_symbol(find_trend_H1,HeivsSeqMa102050_SEL) || is_same_symbol(find_trend_H1,HeivsSeqMa102050200_SEL)
     )
     {
      CandleData arrHeiken_H1[];
      get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,55,true,true);

      bool h1_allow_buy = is_same_symbol(TREND_BUY,arrHeiken_H1[1].trend_by_ma10) &&
                          is_same_symbol(TREND_BUY,arrHeiken_H1[0].trend_by_ma10) &&
                          is_same_symbol(TREND_BUY,arrHeiken_H1[1].trend_heiken) &&
                          is_same_symbol(TREND_BUY,arrHeiken_H1[0].trend_heiken);

      bool h1_allow_sel = is_same_symbol(TREND_SEL,arrHeiken_H1[1].trend_by_ma10) &&
                          is_same_symbol(TREND_SEL,arrHeiken_H1[0].trend_by_ma10) &&
                          is_same_symbol(TREND_SEL,arrHeiken_H1[1].trend_heiken) &&
                          is_same_symbol(TREND_SEL,arrHeiken_H1[0].trend_heiken);

      if(h1_allow_buy && is_same_symbol(find_trend_H1,HeivsMa10_BUY))
        {
         string msg=symbol+" H1 HeivsMa10_BUY";
         if(allow_PushMessage(msg, FILE_MSG_LIST_WAIT))
           {
            StringReplace(find_trend_H1,HeivsMa10_BUY,"");
            SetGlobalVariable(key_H1,(double)find_trend_H1);

            msg=get_vnhour()+" "+msg;
            PushMessage(msg,FILE_MSG_LIST_WAIT);

            Alert(msg);
           }
        }
      if(h1_allow_sel && is_same_symbol(find_trend_H1,HeivsMa10_SEL))
        {
         string msg=symbol+" H1 HeivsMa10_SEL";
         if(allow_PushMessage(msg, FILE_MSG_LIST_WAIT))
           {
            StringReplace(find_trend_H1,HeivsMa10_SEL,"");
            SetGlobalVariable(key_H1,(double)find_trend_H1);

            msg=get_vnhour()+" "+msg;
            PushMessage(msg,FILE_MSG_LIST_WAIT);

            Alert(msg);
           }
        }
      //-------------------------------------------------------------------------------------------
      //-------------------------------------------------------------------------------------------
      //-------------------------------------------------------------------------------------------
      if(h1_allow_buy && is_same_symbol(find_trend_H1,HeivsSeqMa102050_BUY)
         && arrHeiken_H1[0].ma10>arrHeiken_H1[0].ma20 && arrHeiken_H1[0].ma20>arrHeiken_H1[0].ma50)
        {
         string msg=symbol+" H1 Hei.SeqMa102050_BUY";
         if(allow_PushMessage(msg, FILE_MSG_LIST_WAIT))
           {
            StringReplace(find_trend_H1,HeivsSeqMa102050_BUY,"");
            SetGlobalVariable(key_H1,(double)find_trend_H1);

            msg=get_vnhour()+" "+msg;
            PushMessage(msg,FILE_MSG_LIST_WAIT);

            Alert(msg);
           }
        }

      if(h1_allow_buy && is_same_symbol(find_trend_H1,HeivsSeqMa102050200_BUY)
         && arrHeiken_H1[0].ma10>arrHeiken_H1[0].ma20 && arrHeiken_H1[0].ma20>arrHeiken_H1[0].ma50)
        {
         double ma200=cal_MA_XX(symbol,PERIOD_H1,200,0);
         if(arrHeiken_H1[0].ma50>ma200)
           {
            StringReplace(find_trend_H1,HeivsSeqMa102050200_BUY,"");
            SetGlobalVariable(key_H1,(double)find_trend_H1);

            string msg=get_vnhour()+" "+symbol+" H1 Hei.SeqMa102050200_BUY";
            PushMessage(msg,FILE_MSG_LIST_WAIT);

            if(is_ftmo_account())
               SendTelegramMessage(symbol,TREND_SEL,msg);
            else
               Alert(msg);
           }
        }

      //-----------------------------------------------------------------------

      if(h1_allow_sel && is_same_symbol(find_trend_H1,HeivsSeqMa102050_SEL)
         && arrHeiken_H1[0].ma10<arrHeiken_H1[0].ma20 && arrHeiken_H1[0].ma20<arrHeiken_H1[0].ma50)
        {
         string msg=symbol+" H1 Hei.SeqMa102050_SELL";
         if(allow_PushMessage(msg, FILE_MSG_LIST_WAIT))
           {
            StringReplace(find_trend_H1,HeivsSeqMa102050_SEL,"");
            SetGlobalVariable(key_H1,(double)find_trend_H1);

            msg=get_vnhour()+" "+msg;
            PushMessage(msg,FILE_MSG_LIST_WAIT);

            Alert(msg);
           }
        }

      if(h1_allow_sel && is_same_symbol(find_trend_H1,HeivsSeqMa102050200_SEL)
         && arrHeiken_H1[0].ma10<arrHeiken_H1[0].ma20 && arrHeiken_H1[0].ma20<arrHeiken_H1[0].ma50)
        {
         double ma200=cal_MA_XX(symbol,PERIOD_H1,200,0);
         if(arrHeiken_H1[0].ma50<ma200)
           {
            StringReplace(find_trend_H1,HeivsSeqMa102050200_SEL,"");
            SetGlobalVariable(key_H1,(double)find_trend_H1);

            string msg=get_vnhour()+" "+symbol+" H1 Hei.SeqMa102050200_SELL";
            PushMessage(msg,FILE_MSG_LIST_WAIT);

            if(is_ftmo_account())
               SendTelegramMessage(symbol,TREND_SEL,msg);
            else
               Alert(msg);
           }
        }

      //-----------------------------------------------------------------------

      if(h1_allow_buy && is_same_symbol(find_trend_H1,HeivsMa20_BUY) && arrHeiken_H1[1].close>arrHeiken_H1[1].ma20)
        {
         StringReplace(find_trend_H1,HeivsMa20_BUY,"");
         SetGlobalVariable(key_H1,(double)find_trend_H1);

         string msg=get_vnhour()+" "+symbol+" H1 HeivsMa20_BUY";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }

      if(h1_allow_buy && is_same_symbol(find_trend_H1,HeivsMa50_BUY) && arrHeiken_H1[1].close>arrHeiken_H1[1].ma50)
        {
         StringReplace(find_trend_H1,HeivsMa50_BUY,"");
         SetGlobalVariable(key_H1,(double)find_trend_H1);

         string msg=get_vnhour()+" "+symbol+" H1 HeivsMa50_BUY";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }


      if(h1_allow_sel && is_same_symbol(find_trend_H1,HeivsMa20_SEL) && arrHeiken_H1[1].close<arrHeiken_H1[1].ma20)
        {
         StringReplace(find_trend_H1,HeivsMa20_SEL,"");
         SetGlobalVariable(key_H1,(double)find_trend_H1);

         string msg=get_vnhour()+" "+symbol+" H1 HeivsMa20_SELL";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }

      if(h1_allow_sel && is_same_symbol(find_trend_H1,HeivsMa50_SEL) && arrHeiken_H1[1].close<arrHeiken_H1[1].ma50)
        {
         StringReplace(find_trend_H1,HeivsMa50_SEL,"");
         SetGlobalVariable(key_H1,(double)find_trend_H1);

         string msg=get_vnhour()+" "+symbol+" H1 HeivsMa50_SELL";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }


     }
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
   if(is_same_symbol(find_trend_H4,HeivsMa20_BUY) || is_same_symbol(find_trend_H4,HeivsMa50_BUY) ||
      is_same_symbol(find_trend_H4,HeivsMa20_SEL) || is_same_symbol(find_trend_H4,HeivsMa50_SEL)
     )
     {
      CandleData arrHeiken_H4[];
      get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,55,true,true);

      bool pass_heiken_buy=arrHeiken_H4[0].trend_heiken==TREND_BUY;
      bool pass_heiken_sel=arrHeiken_H4[0].trend_heiken==TREND_SEL;

      if(pass_heiken_buy && is_same_symbol(find_trend_H4,HeivsMa20_BUY) && arrHeiken_H4[0].close>arrHeiken_H4[0].ma20)
        {
         StringReplace(find_trend_H4,HeivsMa20_BUY,"");
         SetGlobalVariable(key_H4,(double)find_trend_H4);

         string msg=get_vnhour()+" "+symbol+" H4 HeivsMa20_BUY";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }

      if(pass_heiken_buy && is_same_symbol(find_trend_H4,HeivsMa50_BUY) && arrHeiken_H4[0].close>arrHeiken_H4[0].ma50)
        {
         StringReplace(find_trend_H4,HeivsMa50_BUY,"");
         SetGlobalVariable(key_H4,(double)find_trend_H4);

         string msg=get_vnhour()+" "+symbol+" H4 HeivsMa50_BUY";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }

      if(pass_heiken_sel && is_same_symbol(find_trend_H4,HeivsMa20_SEL) && arrHeiken_H4[0].close<arrHeiken_H4[0].ma20)
        {
         StringReplace(find_trend_H4,HeivsMa20_SEL,"");
         SetGlobalVariable(key_H4,(double)find_trend_H4);

         string msg=get_vnhour()+" "+symbol+" H4 HeivsMa20_SELL";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }

      if(pass_heiken_sel && is_same_symbol(find_trend_H4,HeivsMa50_SEL) && arrHeiken_H4[0].close<arrHeiken_H4[0].ma50)
        {
         StringReplace(find_trend_H4,HeivsMa50_SEL,"");
         SetGlobalVariable(key_H4,(double)find_trend_H4);

         string msg=get_vnhour()+" "+symbol+" H4 HeivsMa50_SELL";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }

      if(pass_heiken_buy && is_same_symbol(find_trend_H4,HeivsSeqMa102050_BUY) && arrHeiken_H4[0].ma10>arrHeiken_H4[0].ma20 && arrHeiken_H4[0].ma20>arrHeiken_H4[0].ma50)
        {
         StringReplace(find_trend_H4,HeivsSeqMa102050_BUY,"");
         SetGlobalVariable(key_H4,(double)find_trend_H4);

         string msg=get_vnhour()+" "+symbol+" H4 Hei.SeqMa102050_BUY";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }

      if(pass_heiken_buy && is_same_symbol(find_trend_H4,HeivsSeqMa102050200_BUY) && arrHeiken_H4[0].ma10>arrHeiken_H4[0].ma20 && arrHeiken_H4[0].ma20>arrHeiken_H4[0].ma50)
        {
         double ma200=cal_MA_XX(symbol,PERIOD_H4,200,0);
         if(arrHeiken_H4[0].ma50>ma200)
           {
            StringReplace(find_trend_H4,HeivsSeqMa102050200_BUY,"");
            SetGlobalVariable(key_H4,(double)find_trend_H4);

            string msg=get_vnhour()+" "+symbol+" H4 Hei.SeqMa102050200_BUY";
            PushMessage(msg,FILE_MSG_LIST_WAIT);

            Alert(msg);
           }
        }

      if(pass_heiken_sel && is_same_symbol(find_trend_H4,HeivsSeqMa102050_SEL) && arrHeiken_H4[0].ma10<arrHeiken_H4[0].ma20 && arrHeiken_H4[0].ma20<arrHeiken_H4[0].ma50)
        {
         StringReplace(find_trend_H4,HeivsSeqMa102050_SEL,"");
         SetGlobalVariable(key_H4,(double)find_trend_H4);

         string msg=get_vnhour()+" "+symbol+" H4 Hei.SeqMa102050_SELL";
         PushMessage(msg,FILE_MSG_LIST_WAIT);

         Alert(msg);
        }

      if(pass_heiken_sel && is_same_symbol(find_trend_H4,HeivsSeqMa102050200_SEL) && arrHeiken_H4[0].ma10<arrHeiken_H4[0].ma20 && arrHeiken_H4[0].ma20<arrHeiken_H4[0].ma50)
        {
         double ma200=cal_MA_XX(symbol,PERIOD_H4,200,0);
         if(arrHeiken_H4[0].ma50<ma200)
           {
            StringReplace(find_trend_H4,HeivsSeqMa102050200_SEL,"");
            SetGlobalVariable(key_H4,(double)find_trend_H4);

            string msg=get_vnhour()+" "+symbol+" H4 Hei.20.50_SELL";
            PushMessage(msg,FILE_MSG_LIST_WAIT);

            Alert(msg);
           }
        }
     }
//----------------------------------------------------------------------------------------------------
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetNoticeEntryH1(string symbol, string seq_102050_h4)
  {
   return;

   string key_H1=BtnNoticeMaCross+symbol+"_H1";
   string find_trend_H1=(string)GetGlobalVariable(key_H1);
   StringReplace(find_trend_H1,HeikenCandleC2_BUY,"");
   StringReplace(find_trend_H1,HeikenCandleC2_SEL,"");

   if(is_same_symbol(seq_102050_h4,TREND_BUY))
      find_trend_H1+=HeikenCandleC2_BUY;

   if(is_same_symbol(seq_102050_h4,TREND_SEL))
      find_trend_H1+=HeikenCandleC2_SEL;

   SetGlobalVariable(key_H1,(double)find_trend_H1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadTradeBySeqEvery5min()
  {
   double risk=Risk_1L();

   ENUM_TIMEFRAMES TradingPeriod = (ENUM_TIMEFRAMES)GetGlobalVariable(BtnOptionPeriod);
   if(TradingPeriod<0)
      TradingPeriod=PERIOD_H4;

   string last_symbol="";
   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string symbol = getSymbolAtIndex(index);
      SendNoticeMaCross(symbol);

      string str_index = "";
      SetGlobalVariable(symbol,0);

      CandleData arrHeiken_H4[];
      get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,55,true,true);
      CandleData arrHeiken_H1[];
      get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,55,true,true);

      string trend_ma10_h4 = arrHeiken_H4[0].trend_by_ma10;
      string trend_ma20_h4 = arrHeiken_H4[0].trend_by_ma10;
      string trend_heiken_h4 = arrHeiken_H4[0].trend_heiken;
      string trend_reverse_hei_h4=get_trend_reverse(trend_heiken_h4);

      string trend_heiken_h1 = arrHeiken_H1[0].trend_heiken;

      string trend_seq_h4=(arrHeiken_H4[0].ma10>arrHeiken_H4[0].ma20 && arrHeiken_H4[0].ma10>arrHeiken_H4[0].ma50)?TREND_BUY:
                          (arrHeiken_H4[0].ma10<arrHeiken_H4[0].ma20 && arrHeiken_H4[0].ma10<arrHeiken_H4[0].ma50)?TREND_SEL :"";

      if(is_same_symbol(arrHeiken_H4[0].trend_by_ma05, arrHeiken_H4[0].trend_by_ma10) &&
         is_same_symbol(arrHeiken_H4[0].trend_by_ma05, arrHeiken_H4[0].trend_by_ma20) &&
         is_same_symbol(arrHeiken_H4[0].trend_by_ma05, arrHeiken_H4[0].trend_by_ma50))
         trend_seq_h4=arrHeiken_H4[0].trend_by_ma05;

      string trend_seq_h1=(arrHeiken_H1[0].ma10>arrHeiken_H1[0].ma20 && arrHeiken_H1[0].ma10>arrHeiken_H1[0].ma50)?TREND_BUY:
                          (arrHeiken_H1[0].ma10<arrHeiken_H1[0].ma20 && arrHeiken_H1[0].ma10<arrHeiken_H1[0].ma50)?TREND_SEL :"";
      if(is_same_symbol(arrHeiken_H1[0].trend_by_ma05, arrHeiken_H1[0].trend_by_ma10) &&
         is_same_symbol(arrHeiken_H1[0].trend_by_ma05, arrHeiken_H1[0].trend_by_ma20) &&
         is_same_symbol(arrHeiken_H1[0].trend_by_ma05, arrHeiken_H1[0].trend_by_ma50))
         trend_seq_h1=arrHeiken_H1[0].trend_by_ma05;


      if(is_same_symbol(trend_seq_h4, trend_seq_h1))
         if(is_same_symbol(trend_seq_h4, TREND_BUY))
            SetGlobalVariable(symbol,TYPE_BUY);
         else
            SetGlobalVariable(symbol,TYPE_SEL);


      if(is_same_symbol(trend_seq_h4, trend_seq_h1) &&
         is_same_symbol(trend_seq_h4, trend_heiken_h4) &&
         is_same_symbol(trend_seq_h4, trend_heiken_h1) &&
         allow_PushMessage(symbol,FILE_MSG_LIST_R1C1))
        {
         string msg_R1C3 = symbol+" (Seq.H4.H1"+ trend_seq_h4+") "
                           + "  i."+ IntegerToString(arrHeiken_H4[0].count_ma10);

         PushMessage(msg_R1C3,FILE_MSG_LIST_R1C1);
         continue;
        }

      //----------------------------------------------------------------------------------------------------
      if(is_same_symbol(trend_seq_h4, trend_heiken_h1) &&
         is_same_symbol(trend_heiken_h4, arrHeiken_H4[0].trend_by_seq_051020) &&
         is_same_symbol(trend_heiken_h4, arrHeiken_H1[0].trend_by_seq_051020) &&
         allow_PushMessage(symbol,FILE_MSG_LIST_R1C2))
        {
         string msg_R1C3 = symbol+" (051020.H4."+ arrHeiken_H4[0].trend_by_ma10+")  "
                           + "  i."+ IntegerToString(arrHeiken_H4[0].count_ma10);

         PushMessage(msg_R1C3,FILE_MSG_LIST_R1C2);
        }
     }

   CreateMessagesBtn(BtnMsgR1C1_);
   CreateMessagesBtn(BtnMsgR1C2_);
   CreateMessagesBtn(BtnMsgR1C3_);
   CreateMessagesBtn(BtnMsgREVR_);
   CreateMessagesBtn(BtnMsgSTOP_);

   CreateMessagesBtn(BtnMsgR2C1_);
   CreateMessagesBtn(BtnMsgR2C2_);
   if(last_symbol!="")
     {
      //int intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
      //if(intPeriod==-1)
      //   intPeriod = PERIOD_D1;
      //
      //OpenChartWindow(last_symbol,(ENUM_TIMEFRAMES)intPeriod);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool allow_send_alert(string symbol)
  {
   bool send_alert=true;
   string total_comments="";
   string strBSL=CountBSL(symbol,total_comments);
   bool has_001=is_same_symbol(total_comments,appendZero100(1));
   bool has_002=is_same_symbol(total_comments,appendZero100(2));
   bool has_003=is_same_symbol(total_comments,appendZero100(3));
   if(has_001 || has_002 || has_003)
      send_alert=false;

   return send_alert;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTrendlineUpdates(bool re_draw=false)
  {
   string symbol=Symbol();
   double sl_price = ObjectGetDouble(0, GLOBAL_VAR_SL, OBJPROP_PRICE);
   double lm_price = ObjectGetDouble(0, GLOBAL_VAR_LM, OBJPROP_PRICE);
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));

   bool re_draw_rr=false;
   double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
   double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);

   if(sl_price>0 && sl_price!=SL)
     {
      SL=sl_price;
      re_draw_rr=true;
      SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL);
     }

   if(lm_price>0 && lm_price!=LM)
     {
      LM=lm_price;
      re_draw_rr=true;
      SetGlobalVariable(GLOBAL_VAR_LM+symbol,LM);
     }


   if(re_draw)
     {
      //double amp_w1,amp_d1,amp_h4,amp_h1;
      //GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);
      //if(LM>SL)
      //   SL=LM-amp_d1;
      //if(LM<SL)
      //   SL=LM+amp_d1;
      //SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL);

      init_sl_tp_trendline(false);
      OnInit();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetClosePriceAtTime(string symbol, datetime base_time)
  {
   int candle_index = iBarShift(symbol, PERIOD_D1, base_time);

   if(candle_index >= 0)
      return iClose(symbol, PERIOD_D1, candle_index);
   else
      return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_angle_trend(string lineName, datetime time1, double price1, datetime time2, double price2, double angle
                        , color clrColor, int width=1, int STYLE=STYLE_SOLID, bool is_ray=false)
  {
   ObjectDelete(0, lineName);

   if(!ObjectCreate(0, lineName, OBJ_TRENDBYANGLE, 0, time1, price1, time2, price2))
      return;

   ObjectSetInteger(0, lineName, OBJPROP_COLOR,clrColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH,width);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_LEFT,is_ray);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT,is_ray);
   ObjectSetDouble(0, lineName, OBJPROP_ANGLE,angle);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE,STYLE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_cycle_lines(string name,double price, datetime time1, datetime time2, color clrColor, int width=1, int STYLE=STYLE_SOLID)
  {
   ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_CYCLES, 0, time1, price, time2, price))
      return;

   ObjectSetInteger(0,name,OBJPROP_COLOR,clrColor);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setPriceMid3d(string symbol)
  {
   double mid3d=getPriceMid3d(symbol);
   double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
   double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);
   string trend_histogram_d1 = get_trend_by_histogram(symbol,PERIOD_D1);
   double NEW_LM = mid3d;
   if(trend_histogram_d1==TREND_BUY)
      SL=NEW_LM-amp_d1;
   else
      SL=NEW_LM+amp_d1;

   SetGlobalVariable(GLOBAL_VAR_LM+symbol,NEW_LM);
   SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL);

   init_sl_tp_trendline(false);
//DrawFiboTimeZone52H4(Period(),false);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPriceMid3d(string cur_symbol)
  {
   double low3 =MathMin(iLow(cur_symbol,PERIOD_D1,2), MathMin(iLow(cur_symbol,PERIOD_D1,1),iLow(cur_symbol,PERIOD_D1,0)));
   double hig3 =MathMax(iHigh(cur_symbol,PERIOD_D1,2), MathMax(iHigh(cur_symbol,PERIOD_D1,1),iHigh(cur_symbol,PERIOD_D1,0)));
   double mid = (hig3+low3)/2;
   return mid;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFiboTimeZone52H4(ENUM_TIMEFRAMES TF, bool is_set_SL_LM=false, bool includeC0=false, bool isLoadTimeCycles=false)
  {
   string symbol=Symbol();
   int width=1;
   DeleteAllObjectsWithPrefix(FIBO_TIME_ZONE_);
   datetime time_shift = iTime(symbol,Period(),1) - iTime(symbol,Period(),2);
   bool is_hide_mode=GetGlobalVariable(BtnHideDrawMode)==AUTO_TRADE_ONN;
   if(is_hide_mode==true)
      return;

   TF= Period();

   string fibo_name = FIBO_TIME_ZONE_+symbol;

   datetime base_time_1, base_time_2;
   LoadTimelines(base_time_1, base_time_2, false, isLoadTimeCycles);
   create_dragable_vertical_line(GLOBAL_LINE_TIMER_1,base_time_1,clrFireBrick,STYLE_SOLID);
   create_dragable_vertical_line(GLOBAL_LINE_TIMER_2,base_time_2,clrGray,STYLE_SOLID);

   double price1=GetClosePriceAtTime(symbol, base_time_1);
   double price2=GetClosePriceAtTime(symbol, base_time_2);

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);

   string name = "Fibo_D1D2";
   ObjectDelete(0,name);
   ObjectDelete(0,"Fibo_Fan_"+TREND_BUY);
   ObjectDelete(0,"Fibo_Fan_"+TREND_SEL);

   int candle_index1 = iBarShift(symbol, TF, base_time_1);
   int candle_index2 = iBarShift(symbol, TF, base_time_2);
   int candle_count = (candle_index1-candle_index2);


   string trend_macd_21="";
   int macd_lowest_index21, macd_highest_index21;
   find_index_off_macd_extremes(symbol,TF,candle_index1,candle_index2,trend_macd_21, macd_lowest_index21, macd_highest_index21,12,26,9);
   int bar_sta_21=(int)(MathMax(macd_lowest_index21,macd_highest_index21));
   int bar_end_21=(int)(MathMin(macd_lowest_index21,macd_highest_index21));
   if(is_set_SL_LM)
     {
      base_time_1=iTime(symbol,TF,bar_sta_21);
      base_time_2=iTime(symbol,TF,bar_end_21);

      create_dragable_vertical_line(GLOBAL_LINE_TIMER_1,base_time_1,clrFireBrick,STYLE_SOLID);
      create_dragable_vertical_line(GLOBAL_LINE_TIMER_2,base_time_2,clrGray,STYLE_SOLID);
      SaveTimelinesToFile();
     }

   double higest=0,higest_body=0;
   double lowest=DBL_MAX, lowest_body=DBL_MAX;
   int index_highest=candle_index1, index_lowest=candle_index1;
   for(int idx=bar_end_21; idx<=bar_sta_21; idx++)
     {
      double low=iLow(symbol,TF,idx);
      double hig=iHigh(symbol,TF,idx);
      double close=iClose(symbol,TF,idx);
      if(lowest>low)
        {
         lowest=low;
         index_lowest=idx;
        }
      if(higest<hig)
        {
         higest=hig;
         index_highest=idx;
        }

      if(lowest_body>close)
         lowest_body=close;
      if(higest_body<close)
         higest_body=close;
     }

   datetime time_sta_21=iTime(symbol,TF,bar_sta_21);
   int bar_count_21=(int)(MathAbs(bar_sta_21-bar_end_21));
   create_label_simple("CoundCandle","    Total: "+IntegerToString(bar_count_21)+" / "+ IntegerToString(candle_count) +" candles "+get_time_frame_name(TF),lowest,clrRed,base_time_1);
   ObjectSetInteger(0,"CoundCandle",OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);

   if(true)
     {
      string cycle_time="CYCLE_TIME_LINES";
      datetime time_end_21=iTime(symbol,TF,bar_end_21);

      create_trend_line("AMP_TRADE",time_sta_21+time_shift*3,lowest_body, time_sta_21+time_shift*3, higest_body,clrBlue,STYLE_SOLID,5,false,false,false,false);
      ObjectSetInteger(0,"AMP_TRADE",OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0,"AMP_TRADE",OBJPROP_SELECTED, true);

      ObjectDelete(0, cycle_time);
      ObjectCreate(0, cycle_time, OBJ_FIBOTIMES, 0, time_sta_21, lowest, time_end_21, lowest);

      ObjectSetInteger(0, cycle_time, OBJPROP_COLOR, clrNONE);
      ObjectSetInteger(0, cycle_time, OBJPROP_BACK, false);

      double levels[] = {0,1,2,3,4,5,6,7,8,9, 1.618, 2.618, 3.618, 4.618, 5.618, 6.618, 7.618, 8.618,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16,-17,-18};
      int levels_count = ArraySize(levels);
      ObjectSetInteger(0, cycle_time, OBJPROP_LEVELS, levels_count);

      for(int i = 0; i < levels_count; i++)
        {
         ObjectSetDouble(0, cycle_time, OBJPROP_LEVELVALUE, i, levels[i]);

         if(is_same_symbol(DoubleToString(levels[i],3),".618"))
            ObjectSetInteger(0, cycle_time, OBJPROP_LEVELCOLOR, i, clrLightGray);
         else
            ObjectSetInteger(0, cycle_time, OBJPROP_LEVELCOLOR, i, clrBlue);

         if(levels[i]==0 || levels[i]==1)
            ObjectSetInteger(0, cycle_time, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
         else
            ObjectSetInteger(0, cycle_time, OBJPROP_LEVELSTYLE, i, STYLE_DASHDOTDOT);

         ObjectSetInteger(0, cycle_time, OBJPROP_LEVELWIDTH, i, 1);
         ObjectSetString(0,cycle_time,OBJPROP_LEVELTEXT,i,DoubleToString(1*MathAbs(levels[i]),3)+"   ");
        }
     }


   bool IS_FIBO_LINE=GetGlobalVariable(BtnFiboline)==AUTO_TRADE_ONN;
   if(IS_FIBO_LINE)
     {
      string trend_macd_cur="";
      int macd_lowest_index, macd_highest_index;
      int candle_index3=find_index_off_macd_extremes(symbol,TF,candle_index2,0,trend_macd_cur, macd_lowest_index, macd_highest_index,6,12,9);
      datetime base_time_3=iTime(symbol, TF, candle_index3);

      double higest_fibo=iHigh(symbol,TF,macd_highest_index);//0;
      double lowest_fibo=iLow(symbol,TF,macd_lowest_index);//DBL_MAX;
      //for(int idx=candle_index3; idx<=candle_index2; idx++)
      //  {
      //   double low=iLow(symbol,TF,idx);
      //   double hig=iHigh(symbol,TF,idx);
      //   if(lowest_fibo>low)
      //      lowest_fibo=low;
      //   if(higest_fibo<hig)
      //      higest_fibo=hig;
      //  }
      //------------------------------------------------------------------------------------------------------------
      datetime time_to = TimeCurrent()+time_shift*1;
      if(is_same_symbol(trend_macd_cur,TREND_BUY))
         create_angle_trend("ANGLE_CUR_"+TREND_BUY,iTime(symbol,TF,macd_highest_index),iHigh(symbol,TF,macd_highest_index),time_to,lowest_fibo,315,clrBlue,1,STYLE_SOLID,true);
      if(is_same_symbol(trend_macd_cur,TREND_SEL))
         create_angle_trend("ANGLE_CUR_"+TREND_SEL,iTime(symbol,TF,macd_lowest_index), iLow(symbol,TF,macd_lowest_index),  time_to,higest_fibo, 45,clrRed, 1,STYLE_SOLID,true);

      create_trend_line("AMP_TREND_PRE",time_sta_21,lowest,time_sta_21,higest,clrBlue,STYLE_DASHDOTDOT,3,false,false,false,false);
      ObjectSetInteger(0,"AMP_TREND_PRE",OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0,"AMP_TREND_PRE",OBJPROP_SELECTED, true);
      //------------------------------------------------------------------------------------------------------------
      if(trend_macd_cur==TREND_BUY)
         create_trend_line("AMP_TREND_CUR",iTime(symbol,TF,macd_lowest_index),lowest_fibo,iTime(symbol,TF,macd_lowest_index),higest_fibo,clrBlue,STYLE_DASHDOTDOT,3,false,false,false,false);
      if(trend_macd_cur==TREND_SEL)
         create_trend_line("AMP_TREND_CUR",iTime(symbol,TF,macd_highest_index),lowest_fibo,iTime(symbol,TF,macd_highest_index),higest_fibo,clrRed,STYLE_DASHDOTDOT,3,false,false,false,false);
      ObjectSetInteger(0,"AMP_TREND_CUR",OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0,"AMP_TREND_CUR",OBJPROP_SELECTED, true);
      //------------------------------------------------------------------------------------------------------------
      bool IS_MACD_DOT=GetGlobalVariable(BtnMacdMode)==AUTO_TRADE_ONN;
      if(IS_MACD_DOT)
        {
         // {30, 45, 60};
         // {0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, 255, 270, 285, 300, 315, 330, 345, 360};
         //int angles[] = {45};
         if(true)
           {
            //int step = 10;
            //int max_angle = 360;
            //int size = (max_angle / step) + 1;
            //int angles[];
            //ArrayResize(angles, size);
            //for(int i = 0; i < size; i++)
            //   angles[i] = i * step;
            int angles[] = {45};

            int angleSize = ArraySize(angles);
            time_to = TimeCurrent()+time_shift*7;

            //if(is_same_symbol(trend_macd_cur,TREND_SEL))
              {
               datetime time_to_buy = time_to;
               if(is_same_symbol(trend_macd_cur,TREND_BUY))
                  time_to_buy = base_time_2;
               for(int i = 0; i < angleSize; i++)
                 {
                  string name = "ANGLE_PRE_" + IntegerToString(angles[i]) + "_" + TREND_BUY;
                  int angle = 360 - angles[i];
                  int STYLE=STYLE_SOLID;//(angles[i]==45)?STYLE_SOLID:STYLE_DOT;
                  create_angle_trend(name, iTime(symbol, TF, macd_highest_index21), iHigh(symbol, TF, macd_highest_index21), time_to_buy, lowest, angle, clrBlue, 1, STYLE,true);
                 }
              }

            // Vẽ các đường góc cho xu hướng giảm (TREND_SEL)
            //if(is_same_symbol(trend_macd_cur,TREND_BUY))
              {
               datetime time_to_sel = time_to;
               if(is_same_symbol(trend_macd_cur,TREND_SEL))
                  time_to_sel = base_time_2;
               for(int i = 0; i < angleSize; i++)
                 {
                  string name = "ANGLE_PRE_" + IntegerToString(angles[i]) + "_" + TREND_SEL;
                  int angle = angles[i];
                  int STYLE=STYLE_SOLID;//(angles[i]==45)?STYLE_SOLID:STYLE_DOT;
                  create_angle_trend(name, iTime(symbol, TF, macd_lowest_index21), iLow(symbol, TF, macd_lowest_index21), time_to_sel, higest, angle, clrRed, 1, STYLE,true);
                 }
              }
           }

         if(true)
           {
            //------------------------------------------------------------------------------------------------------------
            //| Trường hợp        | time1 & price1 (gốc)            | time2 & price2 (đỉnh hoặc đáy)    |
            //| ----------------- | ------------------------------- | --------------------------------- |
            //| **Xu hướng tăng** | đáy gần nhất + thời gian đáy đó | đỉnh gần nhất sau đáy + thời gian |
            //| **Xu hướng giảm** | đỉnh gần nhất + thời gian đỉnh  | đáy sau đó + thời gian đáy        |
            //datetime projected_time;
            //if(bar_end_21-bar_count_21<0)
            //  {
            //   int delta_seconds = (int)(iTime(symbol,TF,bar_end_21) - iTime(symbol,TF,bar_sta_21));
            //   projected_time=iTime(symbol,TF,bar_end_21)+delta_seconds;
            //  }
            //else
            //   projected_time=iTime(symbol,TF,bar_end_21-bar_count_21);

            double levels[]= {0, 0.113, 0.236, 0.382, 0.5, 0.618, 0.786, 0.886, 1};

            if(is_same_symbol(trend_macd_cur,TREND_SEL))
              {
               DrawFibonacciFan1("ANGLE_PRE_"+ TREND_SEL
                                 , iTime(symbol, TF, bar_sta_21), iLow(symbol, TF, bar_sta_21)
                                 , iTime(symbol, TF, bar_end_21), iHigh(symbol, TF, bar_end_21),clrBlue, levels);
              }
            else
              {
               DrawFibonacciFan1("ANGLE_PRE_"+ TREND_BUY
                                 , iTime(symbol, TF, bar_sta_21), iHigh(symbol, TF, bar_sta_21)
                                 , iTime(symbol, TF, bar_end_21), iLow(symbol, TF, bar_end_21),clrBlue, levels);
              }
           }
        }

      if(true)
        {
         double levels_cur[] = {0, 0.236, 0.382, 0.5, 0.618, 0.786, 0.886, 1
                                // , 1.272, 1.618, 2,-0.272,-0.618,-1
                               };
         string name_cur = "FIBO_CUR";
         ObjectDelete(0,name_cur);
         ObjectCreate(0,name_cur,OBJ_FIBO,0,base_time_2,lowest_fibo,TimeCurrent()+time_shift*20,higest_fibo);

         ObjectSetInteger(0,name_cur,OBJPROP_COLOR,clrNONE);
         ObjectSetInteger(0,name_cur,OBJPROP_RAY_LEFT,false);
         ObjectSetInteger(0,name_cur,OBJPROP_RAY_RIGHT,false);

         int size_screen = ArraySize(levels_cur);
         ObjectSetInteger(0,name_cur,OBJPROP_LEVELS,size_screen);

         for(int i=0; i<size_screen; i++)
           {
            ObjectSetDouble(0,name_cur,OBJPROP_LEVELVALUE,i,levels_cur[i]);
            ObjectSetInteger(0,name_cur,OBJPROP_LEVELWIDTH,i,1);

            if(levels_cur[i]== 0 || levels_cur[i]== 1)
              {
               ObjectSetInteger(0,name_cur,OBJPROP_LEVELSTYLE,i,STYLE_SOLID);
               ObjectSetInteger(0,name_cur,OBJPROP_LEVELCOLOR,i,clrRed);
              }
            else
              {
               ObjectSetInteger(0,name_cur,OBJPROP_LEVELSTYLE,i,STYLE_DOT);
               ObjectSetInteger(0,name_cur,OBJPROP_LEVELCOLOR,i,clrBlack);
              }
            ObjectSetString(0,name_cur,OBJPROP_LEVELTEXT,i,DoubleToString(1*MathAbs(levels_cur[i]<0?levels_cur[i]-1:levels_cur[i]),3)+"   ");
           }
        }
     }

   double mid = (lowest+higest)/2;
   double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
   double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
   if(is_set_SL_LM)
     {
      string trend = get_trend_by_histogram(symbol, TF);
      if(is_same_symbol(trend,TREND_BUY)) //TREND_BUY
        {
         SetGlobalVariable(GLOBAL_VAR_LM+symbol, higest);
         SetGlobalVariable(GLOBAL_VAR_SL+symbol, lowest);
        }
      else      //TREND_SEL
        {
         SetGlobalVariable(GLOBAL_VAR_LM+symbol, lowest);
         SetGlobalVariable(GLOBAL_VAR_SL+symbol, higest);
        }

      init_sl_tp_trendline(false);
      //OnInit();
      return;
     }

   if(candle_count>10)
     {
      double levels_screen[] = {0, 0.113, 0.236, 0.382, 0.5, 0.618, 0.786, 0.886, 1
                                , 1.272, 1.382, 1.618, 2, 2.618, 3, 3.618, 4, 4.618, 5, 5.618, 6, 6.618
                                ,-0.272,-0.382,-0.618,-1,-1.618,-2,-2.618,-3,-3.618,-4,-4.618,-5,-5.618,-6,-6.618
                               };
      datetime time_to=base_time_2;
      if(IS_FIBO_LINE==false)
         time_to=iTime(symbol,TF,1)+time_shift*21;

      ObjectDelete(0,name);
      ObjectCreate(0,name,OBJ_FIBO,0,base_time_1,lowest,time_to,higest);

      ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
      ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);

      int size_screen = ArraySize(levels_screen);
      ObjectSetInteger(0,name,OBJPROP_LEVELS,size_screen);

      for(int i=0; i<size_screen; i++)
        {
         ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels_screen[i]);

         if(levels_screen[i]== 0 || levels_screen[i]== 1)
           {
            ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,1);
            ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrBlue);
            ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_SOLID);
           }
         else
           {
            ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,1);
            ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrBlack);
            ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_DOT);
           }

         ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,DoubleToString(1*MathAbs(levels_screen[i]<0?levels_screen[i]-1:levels_screen[i]),3)+"   ");
        }
     }

   ChartRedraw(0);
//---------------------------------------------------------------------------------------------------------------
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CustomDayOfWeek(datetime time)
  {
// Chuyển đổi datetime thành struct
   MqlDateTime dt;
   TimeToStruct(time, dt);

// Tính toán ngày trong tuần
   int dayOfWeek = (dt.day_of_week + 5) % 7; // Chuyển đổi để 0 là Chủ nhật và 6 là Thứ Bảy
   return dayOfWeek;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime SkipWeekendsForCandles(datetime baseTime, int candleCount, int timeframeMinutes)
  {
   datetime result = baseTime;
   int candlesAdded = 0;

   while(candlesAdded < candleCount)
     {
      result += timeframeMinutes * 60; // Thêm thời gian của một nến

      // Kiểm tra xem kết quả có rơi vào cuối tuần không
      int dayOfWeek = CustomDayOfWeek(result);
      if(dayOfWeek != 0 && dayOfWeek != 6) // 0: Chủ nhật, 6: Thứ Bảy
        {
         candlesAdded++;
        }
     }

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CalculateIntervalUsingITime(string symbol, datetime base_time, int candle_step)
  {
   ENUM_TIMEFRAMES timeframe = PERIOD_H4;

// Tìm chỉ số của nến cơ sở
   int base_index = iBarShift(symbol, timeframe, base_time, false);
   if(base_index < 0)
     {
      Print("Error: Cannot find starting bar.");
      return 0;
     }

   datetime target_time = iTime(symbol, timeframe, base_index + candle_step - 1);

   if(target_time == 0)
     {
      Print("Error: Cannot calculate target time.");
      return 0;
     }

   datetime interval = target_time - base_time;
   return interval;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindSL_LM_Possition(string symbol, string find_trend)
  {
   FindFirstMA6vs10Cross(symbol,Period(),5,10);

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);

   double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   if(is_same_symbol(find_trend,TREND_BUY))
      SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM-amp_w1);

   if(is_same_symbol(find_trend,TREND_SEL))
      SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM+amp_w1);

   init_sl_tp_trendline(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindFirstMA6vs10Cross(string symbol, ENUM_TIMEFRAMES timeframe, int ma_period_1=6,int ma_period_2=10,int candles_to_copy=50)
  {
// Lấy các handle của MA6 và MA10
   int handle_ma6 = iMA(symbol, timeframe, ma_period_1, 0, MODE_SMA, PRICE_CLOSE);
   int handle_ma10 = iMA(symbol, timeframe, ma_period_2, 0, MODE_SMA, PRICE_CLOSE);

// Kiểm tra xem các handle có hợp lệ không
   if(handle_ma6 == INVALID_HANDLE || handle_ma10 == INVALID_HANDLE)
     {
      Print("Failed to create MA handles.");
      return;
     }

// Khai báo các buffer để chứa giá trị MA
   double ma6_buffer[];
   double ma10_buffer[];
   ArraySetAsSeries(ma6_buffer, true);
   ArraySetAsSeries(ma10_buffer, true);

// Copy giá trị MA từ các buffer (chỉ lấy 20 nến gần nhất)
   int copied_ma6 = CopyBuffer(handle_ma6, 0, 0, candles_to_copy, ma6_buffer);
   int copied_ma10 = CopyBuffer(handle_ma10, 0, 0, candles_to_copy, ma10_buffer);

   if(copied_ma6 <= 0 || copied_ma10 <= 0)
     {
      Print("Failed to copy MA buffers.");
      return;
     }

// Duyệt qua các giá trị MA để tìm vị trí giao cắt đầu tiên trong 20 nến gần nhất
   bool found=false;
   for(int i = 1; i < copied_ma6; i++)
     {
      double ma6_prev = ma6_buffer[i];
      double ma10_prev = ma10_buffer[i];
      double ma6_curr = ma6_buffer[i - 1];
      double ma10_curr = ma10_buffer[i - 1];

      // Kiểm tra xem MA6 có giao cắt với MA10 không
      if((ma6_prev < ma10_prev && ma6_curr > ma10_curr) || (ma6_prev > ma10_prev && ma6_curr < ma10_curr))
        {
         // Nội suy để tìm giá trị tại điểm giao cắt
         double cross_price = ma6_curr + (ma10_curr - ma6_curr) * ((ma6_curr - ma6_prev) / ((ma6_prev - ma10_prev) - (ma6_curr - ma10_curr)));
         datetime cross_time = iTime(symbol, timeframe, i - 1);

         create_vertical_line("CrossV",cross_time,clrRed,STYLE_DOT);
         create_trend_line("CrossH",cross_time,cross_price,cross_time+TIME_OF_ONE_W1_CANDLE,cross_price,clrRed,STYLE_DOT,1,true,true);
         create_trend_line("Cross",cross_time,cross_price,cross_time+1,cross_price,clrOrange,STYLE_SOLID,25);
         SetGlobalVariable(GLOBAL_VAR_LM+symbol,cross_price);
         Print("Giao cắt đầu tiên của MA6 và MA10 tại giá: ", DoubleToString(cross_price, _Digits), " tại thời điểm: ", TimeToString(cross_time));

         // Dừng vòng lặp sau khi tìm thấy giao cắt đầu tiên
         found=true;
         break;
        }
     }

// Xóa các handle để tránh rò rỉ bộ nhớ
   IndicatorRelease(handle_ma6);
   IndicatorRelease(handle_ma10);

   if(found==false)
     {
      double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
      SetGlobalVariable(GLOBAL_VAR_LM+symbol,bid);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetEndIndexOfWave3(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int m_handle_macd = iMACD(symbol, timeframe, 18, 36, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      printf("MACD handle is invalid.");
      return 300;
     }

   double histogram[];
   ArraySetAsSeries(histogram, true);
   CopyBuffer(m_handle_macd, 0, 0, 300, histogram);
   if(ArraySize(histogram) <= 0)
     {
      printf("Failed to copy MACD buffers.");
      return 300;
     }

   int wave = 1;  // 1: sóng 1, 2: sóng 2, 3: sóng 3
   int len = ArraySize(histogram);
   int wave3_end_index = -1;

   int end_wave1 = -1;
   int start_wave2 = -1;
   int start_wave3 = -1;
   int MIN_CANDLE_COUNT=13;

   for(int i = 2; i < len - 1; i++)
     {
      double cur = histogram[i];

      // sóng 1 là Dương
      if(wave == 1 && histogram[1] > 0 && cur < 0)
        {
         end_wave1 = i;
         start_wave2 = i;
         wave = 2;
         continue;
        }

      // sóng 1 là Âm
      if(wave == 1 && histogram[1] < 0 && cur > 0)
        {
         end_wave1 = i;
         start_wave2 = i;
         wave = 2;
         continue;
        }
      //------------------------------------------------------
      // sóng 1 là Dương → sóng 2 là Âm → cur > 0 => vào sóng 3
      if(wave == 2 && histogram[1] > 0 && cur > 0)
        {
         int candles_wave2 = i - start_wave2;
         if(candles_wave2 < MIN_CANDLE_COUNT)
           {
            wave = 1; // không đủ nến, quay lại sóng 1
            start_wave2 = -1;
            continue;
           }

         start_wave3 = i;
         wave = 3;
         continue;
        }

      // sóng 1 là Âm → sóng 2 là Dương → cur < 0 => vào sóng 3
      if(wave == 2 && histogram[1] < 0 && cur < 0)
        {
         int candles_wave2 = i - start_wave2;
         if(candles_wave2 < MIN_CANDLE_COUNT)
           {
            wave = 1;
            start_wave2 = -1;
            continue;
           }

         start_wave3 = i;
         wave = 3;
         continue;
        }
      //------------------------------------------------------
      // Đang trong sóng 3 → tìm điểm kết thúc
      if(wave == 3)
        {
         int candles_wave3 = i - start_wave3;
         wave3_end_index = i - 1;

         // Histogram chuyển hướng → kết thúc sóng 3
         if((histogram[1] > 0 && cur < 0) || (histogram[1] < 0 && cur > 0))
           {
            if(candles_wave3 < MIN_CANDLE_COUNT)
              {
               wave = 2; // không đủ nến, quay lại sóng 2
               start_wave3 = -1;
               wave3_end_index = -1;
               continue;
              }
            break;
           }
        }
     }

   if(wave3_end_index>0 && end_wave1>0)
     {
      datetime base_time_1=iTime(symbol,timeframe,wave3_end_index);
      datetime base_time_2=iTime(symbol,timeframe,end_wave1);

      create_dragable_vertical_line(GLOBAL_LINE_TIMER_1,base_time_1,clrFireBrick,STYLE_SOLID);
      create_dragable_vertical_line(GLOBAL_LINE_TIMER_2,base_time_2,clrGray,STYLE_SOLID);
     }

   return wave3_end_index;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string checkAndDrawMACDDivergence(string symbol, ENUM_TIMEFRAMES timeframe, int fast_ema=12, int slow_ema=26, int signal=9, int sub_window=2, bool draw_zigzag=false)
  {
   int handle = iMACD(symbol, timeframe, fast_ema, slow_ema, signal, PRICE_CLOSE);
   if(handle == INVALID_HANDLE)
     {
      Print("Invalid MACD handle.");
      return "";
     }

   double hist[];
   ArraySetAsSeries(hist, true);
   if(CopyBuffer(handle, 0, 0, 100, hist) <= 0)
     {
      Print("CopyBuffer failed.");
      return "";
     }

   datetime times[];
   ArraySetAsSeries(times, true);
   CopyTime(symbol, timeframe, 0, 100, times);

// Mảng chứa các đỉnh/đáy hợp lệ để vẽ zigzag
   datetime zz_time[100];
   double zz_val[100];
   int zz_count = 0;
   int size = ArraySize(hist)-1;
   for(int i = 1; i < size; i++)
     {
      // Đỉnh dương
      if(hist[i] > 0 && hist[i] > hist[i - 1] && hist[i] > hist[i + 1])
        {
         zz_time[zz_count] = times[i];
         zz_val[zz_count] = hist[i];
         zz_count++;
        }
      // Đáy âm
      else
         if(hist[i] < 0 && hist[i] < hist[i - 1] && hist[i] < hist[i + 1])
           {
            zz_time[zz_count] = times[i];
            zz_val[zz_count] = hist[i];
            zz_count++;
           }
     }

   if(draw_zigzag)
     {
      // Xóa zigzag cũ nếu cần
      for(int j = 0; j < 50; j++)
        {
         string name = "ZZ_MACD_" + IntegerToString(j);
         ObjectDelete(0, name);
        }

      // Vẽ đường zigzag từ các điểm tìm được
      string prifix = "ZZ_MACD_"+get_time_frame_name(timeframe) +append1Zero(fast_ema)+append1Zero(slow_ema)+append1Zero(signal);
      for(int i = 0; i < zz_count - 1; i++)
        {
         string name = prifix + IntegerToString(i);
         ObjectCreate(0, name, OBJ_TREND, sub_window, zz_time[i], zz_val[i], zz_time[i + 1], zz_val[i + 1]);
         ObjectSetInteger(0, name, OBJPROP_COLOR, zz_val[i]>0?clrBlue:clrRed);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 3);
         ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
        }

      string name = prifix + IntegerToString(0)+"cur";
      ObjectCreate(0, name, OBJ_TREND, sub_window, zz_time[0], zz_val[0], iTime(symbol,timeframe,0), hist[0]);
      ObjectSetInteger(0, name, OBJPROP_COLOR, hist[0]>zz_val[0]?clrBlue:clrRed);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 3);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
     }

   return hist[0]>zz_val[0]?TREND_BUY:TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int find_index_off_macd_extremes(string symbol, ENUM_TIMEFRAMES timeframe, int end_index, int index_to
                                 , string &cur_trend, int &macd_lowest_index, int &macd_highest_index, int fast_ema=12, int slow_ema=26, int signal=9)
  {
   macd_lowest_index=0;
   macd_highest_index=0;

   cur_trend="";
   int m_handle_macd = iMACD(symbol,timeframe,fast_ema,slow_ema,signal,PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      printf("MACD handle is invalid.");
      return 5;
     }

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main, true);
   int copied_main = CopyBuffer(m_handle_macd,0,0,end_index + 1,m_buff_MACD_main); // Chỉ số 0: MACD Main Line
   if(copied_main <= 0)
     {
      printf("Failed to copy MACD buffers.");
      return 5;
     }

   int cur_index = index_to>copied_main?copied_main-1:index_to-1;
   cur_index=cur_index<0?0:cur_index;
   double cur_histogram = m_buff_MACD_main[cur_index];
   cur_trend=cur_histogram>0?TREND_BUY:TREND_SEL;

   double lowest = DBL_MAX;
   double highest = -DBL_MAX;

   for(int j = index_to; j < copied_main; j++)
     {
      double histogram = m_buff_MACD_main[j];
      if(histogram < lowest)
        {
         lowest = histogram;
         macd_lowest_index = j;
        }

      if(histogram > highest)
        {
         highest = histogram;
         macd_highest_index = j;
        }
     }


   if(cur_trend == TREND_SEL)
      return macd_lowest_index;

   if(cur_trend == TREND_BUY)
      return macd_highest_index;

   return 5;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateOptimalOrders(double volume, int max_orders, double &lot_per_order, int &final_order_count)
  {
   double min_lot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN); // Khối lượng lệnh tối thiểu (thường là 0.01)
   double lot_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP); // Bước nhảy của lot (thường là 0.01)

// Nếu khối lượng nhỏ hơn lot tối thiểu hoặc không hợp lệ
   if(volume < min_lot)
     {
      Print("Volume quá nhỏ, không thể chia lệnh.");
      lot_per_order = 0;
      final_order_count = 0;
      return;
     }

   int order_count = MathMin(max_orders, int(volume / min_lot)); // Số lệnh tối đa có thể mở
   if(order_count == 0)
      order_count = 1; // Ít nhất phải có 1 lệnh

   lot_per_order = NormalizeDouble(volume / order_count, 2); // Làm tròn đến 2 số thập phân
   lot_per_order = MathMax(lot_per_order, min_lot); // Đảm bảo không nhỏ hơn lot tối thiểu

   final_order_count = int(volume / lot_per_order); // Tính lại số lệnh chính xác
   double total_volume = lot_per_order * final_order_count;

// Nếu tổng volume bị lệch, điều chỉnh lại số lệnh
   if(total_volume < volume)
     {
      final_order_count++; // Tăng thêm 1 lệnh nếu cần
      if(final_order_count > max_orders)
         final_order_count = max_orders; // Không vượt quá số lệnh tối đa
     }

   PrintFormat("Optimal Lot Per Order: %.2f, Total Orders: %d", lot_per_order, final_order_count);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_by_macd_extremes(string symbol, ENUM_TIMEFRAMES timeframe,string TREND)
  {
//,double &low_price,double &hig_price
   double low_price=0;
   double hig_price=0;
   int m_handle_macd = iMACD(symbol,timeframe,12,26,9,PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      printf("MACD handle is invalid.");
      return false;
     }

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main, true);
   int copied_main = CopyBuffer(m_handle_macd,0,0,300,m_buff_MACD_main); // Chỉ số 0: MACD Main Line
   if(copied_main <= 0)
     {
      printf("Failed to copy MACD buffers.");
      return false;
     }

//-------------------------------------------------------------------------------
   int highest_positive_index= -1; // Chỉ số của nến có Histogram cao nhất khi dương
   int lowest_negative_index = -1;  // Chỉ số của nến có Histogram thấp nhất khi âm

   bool found_positive=false;
   bool found_negative=false;
   for(int i=0; i<copied_main;i++)
     {
      double macd_histogram = m_buff_MACD_main[i];

      // Sóng ÂM
      if(macd_histogram<0 && found_negative==false)
        {
         double lowest=DBL_MAX;
         for(int j=i;j<copied_main;j++)
           {
            double histogram = m_buff_MACD_main[j];
            if(lowest>histogram)
              {
               lowest=histogram;
               lowest_negative_index=j;
              }

            if(histogram>0 && lowest_negative_index>0)
              {
               i=j;
               found_negative=true;
               break;
              }
           }
        }

      // Sóng DƯƠNG
      if(macd_histogram>0 && found_positive==false)
        {
         double highest=-DBL_MAX;
         for(int j=i;j<copied_main;j++)
           {
            double histogram = m_buff_MACD_main[j];
            if(highest<histogram)
              {
               highest=histogram;
               highest_positive_index=j;
              }

            if(histogram<0 && highest_positive_index>0)
              {
               i=j;
               found_positive=true;
               break;
              }
           }
        }

      if(found_positive && found_negative)
         break;
     }

   if(found_positive && found_negative)
     {
      double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
      double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)-1;
      bool pass_price_buy=(ask<iLow(symbol,timeframe,lowest_negative_index))   && (ask<iLow(symbol,timeframe,highest_positive_index));
      bool pass_price_sel=(bid>iHigh(symbol,timeframe,highest_positive_index)) && (bid>iHigh(symbol,timeframe,lowest_negative_index));

      string TF=get_time_frame_name(timeframe)+"";
      low_price=iLow(symbol,timeframe,lowest_negative_index);
      hig_price=iHigh(symbol,timeframe,highest_positive_index);
      double amp_wave=NormalizeDouble(MathAbs(hig_price-low_price),digits);
      datetime lowtime=iTime(symbol,timeframe,lowest_negative_index);
      datetime higtime=iTime(symbol,timeframe,highest_positive_index);

      double candle_heigh=0;//iHigh(symbol,timeframe,lowest_negative_index)-iLow(symbol,timeframe,lowest_negative_index);

      create_trend_line(TF+"MACD_LOW",    lowtime,low_price,lowtime+1,low_price,pass_price_buy?clrBlue:clrLightGray,STYLE_SOLID,20);
      create_trend_line(TF+"MACD_DOT_LOW",lowtime,low_price,lowtime+1,low_price,clrBlue,STYLE_SOLID,10);
      create_label_simple(TF+"MACD_B",""+StringSubstr(TF,0,3),low_price-candle_heigh,clrBlack,lowtime);

      create_trend_line(TF+"MACD_HIG",    higtime,hig_price,higtime+1,hig_price,pass_price_sel?clrRed:clrLightGray,STYLE_SOLID,20);
      create_trend_line(TF+"MACD_DOT_HIG",higtime,hig_price,higtime+1,hig_price,clrRed,STYLE_SOLID,10);
      create_label_simple(TF+"MACD_S",""+StringSubstr(TF,0,3),hig_price+candle_heigh,clrBlack,higtime);

      if(is_same_symbol(TF,"D1"))
        {
         create_vertical_line(TF+"MACD_VER_LOW",lowtime,clrBlue,STYLE_DOT);
         create_vertical_line(TF+"MACD_VER_HIG",higtime,clrRed,STYLE_DOT);
        }

      if(is_same_symbol(TREND,TREND_BUY))
         return pass_price_buy;

      if(is_same_symbol(TREND,TREND_SEL))
         return pass_price_sel;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Reset_Fibo_Timelines(ENUM_TIMEFRAMES TIMEFRAME)
  {
   string symbol=Symbol();

//datetime base_time_1=iTime(symbol, TIMEFRAME, (int)MathMax(highest_positive_index,lowest_negative_index));
   int index_base_1 = GetEndIndexOfWave3(symbol,TIMEFRAME);

   datetime base_time_1;
   int sub_window;
   double sub_price;

   if(index_base_1>0)
     {}
   else
     {
      int chart_width = (int)MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
      int chart_heigh = (int)MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));

      ChartXYToTimePrice(0,270,chart_heigh/2,sub_window,base_time_1,sub_price);

      datetime base_time_2;//=TimeCurrent()+20*(iTime(symbol,TIMEFRAME,1)-iTime(symbol,TIMEFRAME,2));
      ChartXYToTimePrice(0,chart_width-205,chart_heigh/2,sub_window,base_time_2,sub_price);
      //iTime(symbol, TIMEFRAME, (int)MathMin(highest_positive_index,lowest_negative_index));

      create_dragable_vertical_line(GLOBAL_LINE_TIMER_1,base_time_1,clrFireBrick,STYLE_SOLID);
      create_dragable_vertical_line(GLOBAL_LINE_TIMER_2,base_time_2,clrGray,STYLE_SOLID);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_MACD_Extremes(string symbol, ENUM_TIMEFRAMES timeframe, int dot_size, bool draw_fan=false,int vertical_width=1,ENUM_LINE_STYLE STYLE=STYLE_SOLID)
  {
   int dot=12;//(int)MathMax(dot_size*2/3,10);
   string TF=get_time_frame_name(timeframe)+"";
   datetime amp_time=0;//iTime(symbol, timeframe,1)-iTime(symbol, timeframe,0);
   if(timeframe<PERIOD_H1)
      amp_time=0;

   int m_handle_macd = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      printf("MACD handle is invalid.");
      return;
     }

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main, true);
   int copied_main = CopyBuffer(m_handle_macd,0,0,200,m_buff_MACD_main); // Chỉ số 0: MACD Main Line
   if(copied_main <= 0)
     {
      printf("Failed to copy MACD buffers.");
      return;
     }

   bool IS_MONOCHROME_MODE=GetGlobalVariable(BtnColorMode)==AUTO_TRADE_ONN;

   int highest_positive_index = -1; // Chỉ số của nến có Histogram cao nhất khi dương
   int lowest_negative_index = -1;  // Chỉ số của nến có Histogram thấp nhất khi âm
   double highest_positive_value = -DBL_MAX; // Histogram cao nhất khi dương
   double lowest_negative_value = DBL_MAX;   // Histogram thấp nhất khi âm
   bool is_positive_wave = false;  // Đánh dấu sóng dương
   bool is_negative_wave = false;  // Đánh dấu sóng âm

   datetime add_time=iTime(symbol, timeframe,0)-iTime(symbol, timeframe,1);
   double max_price=0,min_price=0;
   double candle_height=0;//(iHigh(symbol,timeframe,1)-iLow(symbol,timeframe,1))/10;
   int index_max_price=0,index_min_price=0;
   for(int i = 1; i < copied_main; i++)
     {
      double macd_histogram = m_buff_MACD_main[i];

      // Sóng ÂM
      if(macd_histogram < 0)
        {
         int lowest_negative_index=i;
         double lowest=DBL_MAX;
         for(int j=i;j<copied_main;j++)
           {
            double histogram = m_buff_MACD_main[j];
            if(lowest>histogram)
              {
               lowest=histogram;
               lowest_negative_index=j;
              }

            if(histogram>0)
              {
               double low=iLow(symbol,timeframe,lowest_negative_index);
               double entry_buy=iHigh(symbol,timeframe,lowest_negative_index);
               datetime time=iTime(symbol, timeframe, lowest_negative_index);

               //create_vertical_line(TF+"MACD_LOW_V_" + appendZero100(lowest_negative_index)+".",time,clrBlue,STYLE,vertical_width);

               //create_trend_line(TF+"MACD_ENTRY_BUY_"+TF+"_"+ appendZero100(lowest_negative_index)+"_",time,entry_buy,time+TIME_OF_ONE_D1_CANDLE*2,entry_buy,clrBlue,STYLE_SOLID,3);

               create_lable_simple2(TF+"MACD_LOW_B" + appendZero100(lowest_negative_index),"{"+StringSubstr(TF,0,3)+"}",low-candle_height,clrBlue,time,ANCHOR_CENTER);

               //if(timeframe==PERIOD_D1)
               create_trend_line(TF+"MACD_LOW_D" + appendZero100(lowest_negative_index),time,low,time+1,low,clrBlue,STYLE_SOLID,dot); //

               if(min_price==0 || min_price>low)
                 {
                  min_price=low;
                  index_min_price=lowest_negative_index;
                 }

               i=j;
               break;
              }

           }
        }

      // Sóng DƯƠNG
      if(macd_histogram > 0)
        {
         int highest_positive_index=i;
         double highest=-DBL_MAX;
         for(int j=i;j<copied_main;j++)
           {
            double histogram = m_buff_MACD_main[j];
            if(highest<histogram)
              {
               highest=histogram;
               highest_positive_index=j;
              }

            if(histogram<0)
              {
               double hig=iHigh(symbol,timeframe,highest_positive_index);
               double entry_sel = iLow(symbol,timeframe,highest_positive_index);
               datetime time=iTime(symbol, timeframe, highest_positive_index);

               //create_vertical_line(TF+"MACD_HIG_V_" + appendZero100(highest_positive_index)+".", time,clrRed,STYLE,vertical_width);

               //create_trend_line(TF+"MACD_ENTRY_SEL_"+TF+"_"+ appendZero100(highest_positive_index)+"_",time,entry_sel,time+TIME_OF_ONE_D1_CANDLE*2,entry_sel,clrRed,STYLE_SOLID,3);

               create_lable_simple2(TF+"MACD_HIG_S" + appendZero100(highest_positive_index),"{"+StringSubstr(TF,0,3)+"}",hig+candle_height,clrRed,time,ANCHOR_CENTER);

               //if(timeframe==PERIOD_D1)
               create_trend_line(TF+"MACD_HIG_D" + appendZero100(highest_positive_index),time,hig,time+1,hig,clrRed,STYLE_SOLID,dot); //

               if(max_price==0 || max_price<hig)
                 {
                  max_price=hig;
                  index_max_price=highest_positive_index;
                 }

               i=j;
               break;
              }

           }
        }
     }

   if(false)
     {
      double mid_price=(max_price+min_price)/2;
      int index_mid_price=(int)(MathAbs(index_max_price+index_min_price)/2);

      int index_min=MathMin(index_max_price,index_mid_price);
      datetime time_max_price=iTime(symbol, timeframe,index_max_price);
      datetime time_mid_price=iTime(symbol, timeframe,index_mid_price);
      datetime time_min_price=iTime(symbol, timeframe,index_min_price);

      datetime time_date_max=MathMax(time_max_price,time_min_price);
      datetime time_date_min=MathMin(time_max_price,time_min_price);
      //--------------------------------------------------------------------------------------------
      if(Period()<=PERIOD_D1)
        {
         //double lunarCycle = 29.53058867 d
         datetime current_time = TimeCurrent();  // Lấy thời gian hiện tại
         datetime moon_time;
         string pre_moon_phase = "";
         bool found_cur_phase = false;
         int y_start = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))-25;
         int sub_window;
         datetime sub_time;
         double sub_price;
         ChartXYToTimePrice(0,10,y_start-25,sub_window,sub_time,sub_price);

         for(int i=index_min+265; i>=-265; i--)
           {
            if(i >= 0)
               // Thời gian cho các ngày đã xảy ra
               moon_time = time_date_max-i*TIME_OF_ONE_D1_CANDLE;

            else
               // Tính thời gian cho các ngày trong tương lai
               moon_time = time_date_max+(TIME_OF_ONE_D1_CANDLE * MathAbs(i));

            string moon_phase = GetMoonPhaseName(moon_time);
            if(moon_phase != "")
              {
               if(pre_moon_phase != moon_phase)
                 {
                  pre_moon_phase = moon_phase;

                  color crlColor = clrWhite;
                  if(moon_phase=="New")
                     crlColor = clrDimGray;
                  if(moon_phase=="Full")
                     crlColor = clrSilver;

                  string ver_moon_name = "Moon."+moon_phase+"."+format_date_yyMMdd(moon_time);
                  create_trend_line(ver_moon_name,moon_time,sub_price,moon_time+1,sub_price,crlColor,STYLE_SOLID,20);

                  int width = 1;
                  if(found_cur_phase==false && moon_time>current_time)
                    {
                     width=2;
                     found_cur_phase=true;
                    }

                  if(width==2)
                    {
                     string ver_moon_name = "VMoon."+moon_phase+"."+format_date_yyMMdd(moon_time);
                     create_vertical_line(ver_moon_name,moon_time,crlColor,STYLE_SOLID,width);

                     int x5,y5;
                     double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
                     string strLabel=moon_phase +" Moon "+(string)(int)((moon_time-iTime(symbol,PERIOD_D1,0))/TIME_OF_ONE_D1_CANDLE)+"d "+format_date_ddMM(moon_time);
                     if(ChartTimePriceToXY(0,0,moon_time,bid,x5,y5))
                        createButton("Moon_Count",strLabel,x5,y_start,130,20,clrBlack,clrWhite);
                    }
                 }
              }
           }
        }
      //--------------------------------------------------------------------------------------------
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibonacciRetracement(string name,datetime time1,double price1,datetime time2,double price2,color clrLevelColor=clrDimGray)
  {
   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_FIBO,0,time1,price1,time1,price2);

   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);              // Màu của Fibonacci
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);              // Kiểu đường kẻ (nét đứt)
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);                     // Độ dày của đường kẻ

   double levels[] = {0.0,0.236,0.382,0.5,0.618,0.786
                      ,1.0,1.272,1.382,1.5,1.618
                      ,2.0,2.236,2.382,2.5,2.618
                      ,3.0
                      ,4.0
                      ,-0.236,-0.382,-0.5,-0.618,-0.882
                      ,-1.0//,-1.272,-1.382,-1.5,-1.618
                      ,-2.0,-2.236,-2.382,-2.5,-2.618
                      ,-3.0
                     };

   int size = ArraySize(levels);
   ObjectSetInteger(0,name,OBJPROP_LEVELS,size);
   for(int i=0; i<size; i++)
     {
      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels[i]);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrLevelColor);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_SOLID);
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,DoubleToString(100*levels[i],1)+"% ");

      int width = 1;
      if(levels[i]==0.0 || levels[i]==1.0)
         width = 1;
      ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,width);
     }

   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);


   double amp_fibo = MathAbs(price2-price1);
   datetime time_max = time1 > time2?time1:time2;
   datetime time_min = time1 > time2?time2:time1;
   create_trend_line(name+"_0",time_min,MathMin(price1,price2)-amp_fibo*0,TimeCurrent(),MathMin(price1,price2)-amp_fibo*0,clrDimGray,STYLE_SOLID,1,false,true,true,false);
   create_trend_line(name+"_1",time_min,MathMax(price1,price2)+amp_fibo*0,TimeCurrent(),MathMax(price1,price2)+amp_fibo*0,clrDimGray,STYLE_SOLID,1,false,true,true,false);
   create_trend_line(name+"-1",time_max,MathMin(price1,price2)-amp_fibo*1,TimeCurrent(),MathMin(price1,price2)-amp_fibo*1,clrDimGray,STYLE_SOLID,1,false,true,true,false);
   create_trend_line(name+"+1",time_max,MathMax(price1,price2)+amp_fibo*1,TimeCurrent(),MathMax(price1,price2)+amp_fibo*1,clrDimGray,STYLE_SOLID,1,false,true,true,false);
   create_trend_line(name+"-2",time_max,MathMin(price1,price2)-amp_fibo*2,TimeCurrent(),MathMin(price1,price2)-amp_fibo*2,clrDimGray,STYLE_SOLID,1,false,true,true,false);
   create_trend_line(name+"+2",time_max,MathMax(price1,price2)+amp_fibo*2,TimeCurrent(),MathMax(price1,price2)+amp_fibo*2,clrDimGray,STYLE_SOLID,1,false,true,true,false);
   create_trend_line(name+"-3",time_max,MathMin(price1,price2)-amp_fibo*3,TimeCurrent(),MathMin(price1,price2)-amp_fibo*3,clrDimGray,STYLE_SOLID,1,false,true,true,false);
   create_trend_line(name+"+3",time_max,MathMax(price1,price2)+amp_fibo*3,TimeCurrent(),MathMax(price1,price2)+amp_fibo*3,clrDimGray,STYLE_SOLID,1,false,true,true,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibonacciFan1(string name,datetime time1,double price1,datetime time2,double price2, color clrColor, double &levels[])
  {
//Print(get_vntime()+" "+name + "; "+(string)time1 + "; "+(string)price1);

   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_FIBOFAN,0,time1,price1,time2,price2);

   ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);

   color clrLevelColor=clrBlack;

   int size = ArraySize(levels);

   ObjectSetInteger(0,name,OBJPROP_LEVELS,size);
   for(int i = 0; i < size; i++)
     {
      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels[i]);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrColor);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_DOT);
      ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,1);

      string str_level=(is_same_symbol(name,TREND_BUY)? DoubleToString(MathAbs(levels[i]-1),3): DoubleToString(levels[i],3));
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,""); // + str_level
     }

   ObjectSetInteger(0,name,OBJPROP_BACK,false);           // Hiển thị ở phía sau
   ObjectSetInteger(0,name,OBJPROP_SELECTED,true);      // Không được chọn mặc định
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);    // Có thể chọn được
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);         // Không ẩn
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibonacciFan(string name,datetime time1,double price1,datetime time2,double price2,string TREND)
  {
   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_FIBOFAN,0,time1,price1,time2,price2);

   create_trend_line(name+"0.0",time1,price1,time2,price1,clrBlack,STYLE_SOLID,1,true,true);

// Đặt các thuộc tính cho Fibonacci Fan
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);        // Màu của Fibonacci Fan
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);    // Kiểu đường kẻ
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);              // Độ dày của đường kẻ

   color clrLevelColor = TREND==TREND_BUY?clrBlue:clrRed;
   bool IS_MONOCHROME_MODE=GetGlobalVariable(BtnColorMode)==AUTO_TRADE_ONN;
   if(IS_MONOCHROME_MODE)
      clrLevelColor=clrBlack;
//double levels[] = {0.0,0.236,0.382,0.5,0.618,0.786,0.882,1.0,1.118,1.272,1.382,1.5,1.618};

   double levels[];
   ArrayResize(levels,7);  // Số phần tử cho TREND_BUY
   levels[0] = 0.000;
//levels[1] = 0.236;
//levels[2] = 0.382;
   levels[1] = 0.500;
//levels[4] = 0.618;
//levels[5] = 0.786;
//levels[6] = 0.882;
   levels[2] = 1.000;
   levels[3] =-0.500;
//levels[9] =-0.618;
   levels[4]=-1.000;
   levels[5]=-1.500;
   levels[6]=-2.000;

   int size = ArraySize(levels);

   ObjectSetInteger(0,name,OBJPROP_LEVELS,size);
   for(int i = 0; i < size; i++)
     {
      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels[i]);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrLevelColor);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,1);
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,DoubleToString(levels[i],3));
     }

   ObjectSetInteger(0,name,OBJPROP_BACK,true);           // Hiển thị ở phía sau
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);      // Không được chọn mặc định
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);    // Có thể chọn được
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);         // Không ẩn
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawManualFibonacciRetracement(string name, datetime time1, double price1, datetime time2, double price2, color clrLevelColor=clrNONE)
  {
   double values[24] = {0.0//, 0.236, 0.382, 0.5, 0.618, 0.786
                        , 1.0//, 1.272, 1.382, 1.5, 1.618
                        , 2.0//, 2.236, 2.382, 2.5, 2.618
                        , 3.0
                        , 4.0
                        , -1.0//, -0.236, -0.382, -0.5, -0.618
                        , -2.0
                        , -3.0
                        , -4.0
                       };
   int size = ArraySize(values);

   for(int i = 0; i < size; i++)
     {
      string line_name = name + "_Level_" + DoubleToString(100*values[i],1)+"%";
      ObjectDelete(0, line_name);
     }

   for(int i = 0; i < size; i++)
     {
      double level_price = price1 + (price2 - price1) * values[i];
      string line_name = name + "_Level_" + DoubleToString(100*values[i],1)+"%";

      bool ray = false;
      int width = 1;
      int style = STYLE_DOT;

      if(values[i]==0.0 || values[i]==1.0 || values[i]==2.0 || values[i]==3.0 || values[i]==4.0 || values[i]==-1.0 || values[i]==-2.0)
         style = STYLE_SOLID;

      create_trend_line(line_name, time1, level_price, time2, level_price, clrLevelColor, style, width, ray, ray, true, false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibonacciTimeZones(string name,datetime time1,datetime time2,double price2)
  {
   int x0,y0;
   if(!ChartTimePriceToXY(0,0,time2,price2,x0,y0))
      return;

   int sub_window;
   datetime      time;
   double        price;
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))-55;

   ChartXYToTimePrice(
      0,           // Chart ID
      x0,          // The X coordinate on the chart
      chart_heigh, // The Y coordinate on the chart
      sub_window,  // The number of the subwindow
      time,        // Time on the chart
      price         // Price on the chart
   );

   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_FIBOTIMES,0,time1,price,time2,price);

   ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);       // Màu của Fibonacci
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);      // Kiểu đường kẻ (nét chấm)
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);              // Độ dày của đường kẻ

   double levels[] = {0.0,0.236,0.5,0.786,1.0,1.272,1.5,1.786,2.0,2.382,2.5,2.618,3.0,4.0,5.0,6.0,7.0};
   int levels_count = ArraySize(levels);
   ObjectSetInteger(0,name,OBJPROP_LEVELS,levels_count);

   for(int i = 0; i < levels_count; i++)
     {
      int style = STYLE_SOLID;
      if(levels[i]==0.0 || levels[i]==1.0 || levels[i]==2.0 || levels[i]==3.0)
         style = STYLE_SOLID;

      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels[i]);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrRed);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,style);
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,DoubleToString(levels[i],3));
     }

   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true); // Kéo dài qua phải
  }
// Hàm trả về tên của giai đoạn mặt trăng
string GetMoonPhaseName(datetime time)
  {
   double phase = NormalizeDouble(MoonPhase(time),2);

   if(phase < 0.03 || phase > 0.97)
     {
      return "New";  // Trăng non
     }
   else
      if(phase >= 0.22 && phase <= 0.28)
        {
         return "";  // Trăng bán nguyệt đầu
        }
      else
         if(phase >= 0.47 && phase <= 0.53)
           {
            return "Full";  // Trăng tròn
           }
         else
            if(phase >= 0.72 && phase <= 0.78)
              {
               return "";  // Trăng bán nguyệt cuối
              }
            else
               if(phase < 0.47)
                 {
                  return "";  // Trăng lưỡi liềm đang dần tròn
                 }
               else // phase > 0.53
                 {
                  return "";  // Trăng lưỡi liềm đang dần khuyết
                 }
  }
// Hàm xác định giai đoạn mặt trăng dựa trên ngày hiện tại
double MoonPhase(datetime time)
  {
   datetime newMoon = D'2000.01.06 18:14';
   double lunarCycle = 29.53058867 * 24 * 60 * 60;
   double timeSinceNewMoon = (double)(time-newMoon);
   double moonAge = fmod(timeSinceNewMoon,lunarCycle) / lunarCycle;

   return moonAge;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string format_date_yyMMdd(datetime date0)
  {
   MqlDateTime gmt_time;
   TimeToStruct(date0,gmt_time);

   return StringSubstr((string)gmt_time.year,2)+append1Zero(gmt_time.mon)+append1Zero(gmt_time.day);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string format_date_yyMMddhhmm(datetime date0)
  {
   MqlDateTime gmt_time;
   TimeToStruct(date0,gmt_time);

   string result=StringSubstr((string)gmt_time.year,2)+append1Zero(gmt_time.mon)+append1Zero(gmt_time.day)+append1Zero(gmt_time.hour)+append1Zero(gmt_time.min);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string format_date_ddMM(datetime date0)
  {
   MqlDateTime gmt_time;
   TimeToStruct(date0,gmt_time);

   return append1Zero(gmt_time.day)+ "/"+append1Zero(gmt_time.mon);
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
   double            candlestick_open;   // Giá cao
   double            candlestick_high;   // Giá cao
   double            candlestick_low;    // Giá thấp
   double            candlestick_close;  // Giá đóng
   string            trend_heiken;
   int               count_heiken;
   double            ma10;
   string            trend_by_ma10;
   int               count_ma10;
   string            trend_vector_ma10;
   string            trend_by_ma05;
   string            trend_ma10vs20;
   int               count_ma3_vs_ma5;
   string            trend_by_seq_102050;
   double            ma50;
   string            trend_by_seq_051020;
   string            trend_ma05vs10;
   double            lowest;
   double            higest;
   bool              allow_trade_now_by_seq_051020;
   bool              allow_trade_now_by_seq_102050;
   double            ma20;
   int               count_ma20;
   string            trend_by_ma20;
   double            ma05;
   string            trend_by_ma50;
   int               count_ma50;

                     CandleData()
     {
      time=0;
      open=0.0;
      high=0.0;
      low=0.0;
      close=0.0;
      candlestick_open=0.0;   // Giá cao
      candlestick_high=0.0;   // Giá cao
      candlestick_low=0.0;    // Giá thấp
      candlestick_close=0.0;  // Giá đóng
      trend_heiken="";
      count_heiken=0;
      ma10=0;
      trend_by_ma10="";
      count_ma10=0;
      trend_vector_ma10="";
      trend_by_ma05="";
      trend_ma10vs20="";
      count_ma3_vs_ma5=0;
      trend_by_seq_102050="";
      ma50=0;
      trend_by_seq_051020="";
      trend_ma05vs10="";
      lowest=0;
      higest=0;
      allow_trade_now_by_seq_051020=false;
      allow_trade_now_by_seq_102050=false;
      ma20=0;
      count_ma20=0;
      trend_by_ma20="";
      ma05=0;
      trend_by_ma50="";
      count_ma50=0;
     }

                     CandleData(
      datetime t,double o,double h,double l,double c,
      double candlestick_o,double candlestick_h,double candlestick_l,double candlestick_c,
      string trend_heiken_,int count_heiken_,
      double ma10_,string trend_by_ma10_,int count_ma10_,string trend_vector_ma10_,
      string trend_by_ma05_,string trend_ma10vs20_,int count_ma3_vs_ma5_,
      string trend_by_seq_102050_,double ma50_,string trend_by_seq_051020_,string trend_ma05vs10_,
      double lowest_,  double higest_,bool allow_trade_now_by_seq_051020_,bool allow_trade_now_by_seq_102050_,double ma20_,int count_ma20_,string trend_by_ma20_,double ma05_,string trend_by_ma50_, int count_ma50_)
     {
      time=t;
      open=o;
      high=h;
      low=l;
      close=c;

      candlestick_open=candlestick_o;   // Giá cao
      candlestick_high=candlestick_h;   // Giá cao
      candlestick_low= candlestick_l;    // Giá thấp
      candlestick_close=candlestick_c;  // Giá đóng

      trend_heiken=trend_heiken_;
      count_heiken=count_heiken_;
      ma10=ma10_;
      trend_by_ma10=trend_by_ma10_;
      count_ma10=count_ma10_;
      trend_vector_ma10=trend_vector_ma10_;
      trend_by_ma05=trend_by_ma05_;
      trend_ma10vs20=trend_ma10vs20_;
      count_ma3_vs_ma5=count_ma3_vs_ma5_;
      trend_by_seq_102050=trend_by_seq_102050_;
      ma50=ma50_;
      trend_by_seq_051020=trend_by_seq_051020_;
      trend_ma05vs10=trend_ma05vs10_;
      lowest=lowest_;
      higest=higest_;
      allow_trade_now_by_seq_051020=allow_trade_now_by_seq_051020_;
      allow_trade_now_by_seq_102050=allow_trade_now_by_seq_102050_;
      ma20=ma20_;
      count_ma20=count_ma20_;
      trend_by_ma20=trend_by_ma20_;
      ma05=ma05_;
      trend_by_ma50=trend_by_ma50_;
      count_ma50=count_ma50_;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heiken_MWD(string symbol)
  {
//if(is_same_symbol(symbol,Symbol())==false)
   return;

   bool is_cur_tab=is_same_symbol(symbol,Symbol());
   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   datetime time_1w = iTime(symbol,PERIOD_W1,1)-iTime(symbol,PERIOD_W1,2);
   datetime time_1d = iTime(symbol,PERIOD_D1,1)-iTime(symbol,PERIOD_D1,2);
//------------------------------------------------------------------------------------
   bool IS_MONOCHROME_MODE=GetGlobalVariable(BtnColorMode)!=AUTO_TRADE_ONN;
//------------------------------------------------------------------------------------
   CandleData arrHeiken_mn1[];
   get_arr_heiken(symbol,PERIOD_MN1,arrHeiken_mn1,25,true,false);
   for(int i = 0; i <= 24; i++)
     {
      color clrColorW = clrLightGray;
      if(arrHeiken_mn1[i+1].ma10>0 && arrHeiken_mn1[i].ma10>0)
         create_trend_line("Ma10M_"+append1Zero(i+1)+"_"+append1Zero(i),
                           arrHeiken_mn1[i+1].time,arrHeiken_mn1[i+1].ma10,
                           (i==0?TimeCurrent():arrHeiken_mn1[i].time),arrHeiken_mn1[i].ma10,clrColorW,STYLE_SOLID,25,false,false,true,true);

      //if(i==0)
      //   create_label("Ma10M",TimeCurrent(),arrHeiken_mn1[0].ma10,"   M "+format_double_to_string(NormalizeDouble(arrHeiken_mn1[0].ma10,digits-1),digits-1));
     }
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_W1[];
   get_arr_heiken(symbol,PERIOD_W1,arrHeiken_W1,50,true,false);
   int size_w1 = ArraySize(arrHeiken_W1)-5;
   if(size_w1 > 10)
     {
      for(int i = 0; i < size_w1; i++)
        {
         color clrColorW = is_same_symbol(arrHeiken_W1[i].trend_by_ma10,TREND_BUY)?clrLightGray:clrGray;
         if(IS_MONOCHROME_MODE)
            clrColorW = is_same_symbol(arrHeiken_W1[i].trend_by_ma10,TREND_BUY)? clrPaleTurquoise:clrLightPink;

         if((Period()<PERIOD_W1) && (arrHeiken_W1[i+1].ma10>0) && (arrHeiken_W1[i].ma10>0))
            create_trend_line("Ma10W_"+append1Zero(i+1)+"_"+append1Zero(i),
                              arrHeiken_W1[i+1].time,arrHeiken_W1[i+1].ma10,
                              (i==0?TimeCurrent():arrHeiken_W1[i].time),arrHeiken_W1[i].ma10,clrColorW,STYLE_SOLID,20);

         string candle_name = "hei_w_"+append1Zero(i);
         datetime time_i2 = arrHeiken_W1[i].time;

         if(Period() > PERIOD_D1 || i==0)
            continue;
        }
     }
//------------------------------------------------------------------------------------
   CandleData arrHeiken_D1[];
   get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,300,true,false);
   int size_d1 = ArraySize(arrHeiken_D1)-5;
   if(size_d1 > 50)
     {
      for(int i = 0; i < size_d1; i++)
        {
         color clrColorD = is_same_symbol(arrHeiken_D1[i].trend_ma05vs10,TREND_BUY)?clrLightGray:clrGray;
         if(IS_MONOCHROME_MODE)
            clrColorD = is_same_symbol(arrHeiken_D1[i].trend_ma05vs10,TREND_BUY)? clrTeal:clrFireBrick;

         if((Period()<PERIOD_W1) && (arrHeiken_D1[i+1].ma10>0) && (arrHeiken_D1[i].ma10>0))
            create_trend_line("Ma10D_"+append1Zero(i+1)+"_"+append1Zero(i),
                              arrHeiken_D1[i+1].time,arrHeiken_D1[i+1].ma10,
                              (i==0?TimeCurrent():arrHeiken_D1[i].time),arrHeiken_D1[i].ma10,clrColorD,STYLE_SOLID,11);

         //if(i==0)
         //   create_label("Ma10D",TimeCurrent(),arrHeiken_D1[0].ma10,"   D "+format_double_to_string(NormalizeDouble(arrHeiken_D1[0].ma10,digits-1),digits-1));
        }
     }

   if(Period()>PERIOD_H1)
     {
      int SUB_WINDOW=2;
      draw_line_ma10_8020(symbol,PERIOD_W1,arrHeiken_W1,SUB_WINDOW,10);
      draw_line_ma10_8020(symbol,PERIOD_D1,arrHeiken_D1,SUB_WINDOW,5);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTrendMa10(string symbol,ENUM_TIMEFRAMES timeframe, int fontsize,int length=150, bool show_trend=false,color clrColorSell=clrLightPink, color clrColorBuy=clrPaleTurquoise)
  {
   if(is_same_symbol(symbol,Symbol())==false)
      return;

   string TF=get_time_frame_name(timeframe);
   StringReplace(TF,"1","");
   StringReplace(TF,"MN","M");
   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));

   int size=length+15;
   CandleData arrHeiken_TF[];
   get_arr_heiken(symbol,timeframe,arrHeiken_TF,size,true,false);

   datetime time_shift=arrHeiken_TF[1].time-arrHeiken_TF[2].time;

   int loop = length-10;
   int pre_index_ma10=0;
   for(int i = 0; i<loop; i++)
     {
      datetime time1=arrHeiken_TF[i+1].time;
      datetime time0=i==0?TimeCurrent():arrHeiken_TF[i].time;

      double ma10_0=arrHeiken_TF[i].ma10;
      double ma10_1=arrHeiken_TF[i+1].ma10;

      double mid = (arrHeiken_TF[i].open+arrHeiken_TF[i].close+arrHeiken_TF[i].low+arrHeiken_TF[i].high)/4;

      color clrColor10 = arrHeiken_TF[i].trend_by_ma10==TREND_BUY?clrColorBuy:clrColorSell;

      create_trend_line("Draw_Ma10_"+TF+"_"+append1Zero(i+1)+"_"+append1Zero(i),time1,ma10_1,time0,ma10_0,clrColor10,STYLE_SOLID,10);

      if(i==0)
        {
         color preTextColor = arrHeiken_TF[i].trend_by_ma10==TREND_BUY ? clrBlue:clrRed;
         string lblName="Ma10_"+TF+"_"+append1Zero(i)+"_"+get_yyyymmdd(arrHeiken_TF[0].time);

         create_label_simple(lblName
                             , TF+"."+getShortName(arrHeiken_TF[0].trend_by_ma10)+"."+IntegerToString(arrHeiken_TF[0].count_ma10)
                             , arrHeiken_TF[0].ma10,preTextColor,arrHeiken_TF[0].time,0,fontsize);

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTrendCountMa10(string symbol,ENUM_TIMEFRAMES timeframe, int fontsize,int length=150, bool show_trend=false,color clrColorSell=clrLightPink, color clrColorBuy=clrPaleTurquoise)
  {
   if(is_same_symbol(symbol,Symbol())==false)
      return;

   string TF=get_time_frame_name(timeframe);
   StringReplace(TF,"1","");
   StringReplace(TF,"MN","M");
   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));

   int size=length+15;
   CandleData arrHeiken_TF[];
   get_arr_heiken(symbol,timeframe,arrHeiken_TF,size,true,false);

   bool draw_lable_d1=Period()==PERIOD_D1;
   bool draw_rr=Period()==timeframe;
   bool draw_zigzag=Period()==PERIOD_W1;
   datetime time_shift=arrHeiken_TF[1].time-arrHeiken_TF[2].time;

   int loop = length-10;
   int pre_index_ma10=0;
   for(int i = 0; i<loop; i++)
     {
      datetime time1=arrHeiken_TF[i+1].time;
      datetime time0=i==0?TimeCurrent():arrHeiken_TF[i].time;

      double ma05_0=arrHeiken_TF[i].ma05;
      double ma05_1=arrHeiken_TF[i+1].ma05;

      double ma10_0=arrHeiken_TF[i].ma10;
      double ma10_1=arrHeiken_TF[i+1].ma10;

      double mid = (arrHeiken_TF[i].open+arrHeiken_TF[i].close+arrHeiken_TF[i].low+arrHeiken_TF[i].high)/4;


      if(timeframe!=PERIOD_W1 && arrHeiken_TF[i].count_heiken==1)
        {
         if((arrHeiken_TF[i+1].trend_by_ma10==arrHeiken_TF[i+1].trend_heiken && arrHeiken_TF[i+1].trend_by_ma10==arrHeiken_TF[i+1].trend_heiken))
           {
            double candle_heigh = (arrHeiken_TF[i+1].high-arrHeiken_TF[i+1].low)/10;
            string lblName="Heiken_"+TF+"_"+append1Zero(i)+"_"+get_yyyymmdd(arrHeiken_TF[i].time);
            create_label_simple(lblName
                                , ""+IntegerToString(arrHeiken_TF[i+1].count_heiken)
                                , arrHeiken_TF[i+1].trend_by_ma10==TREND_BUY?arrHeiken_TF[i+1].high+candle_heigh:arrHeiken_TF[i+1].low-candle_heigh,clrBlack,arrHeiken_TF[i+1].time,0,fontsize);
            ObjectSetInteger(0,lblName,OBJPROP_ANCHOR,ANCHOR_CENTER);
           }
        }


      if(arrHeiken_TF[i].count_ma10==1)
        {
         color preColor = clrColorSell;
         color preTextColor = clrRed;
         if(arrHeiken_TF[i+1].trend_by_ma10==TREND_BUY)
           {
            preColor = clrColorBuy;
            preTextColor = clrBlue;
           }

         string lblName="Ma10_"+TF+"_"+append1Zero(i)+"_"+get_yyyymmdd(arrHeiken_TF[i].time);
         create_label_simple(lblName
                             , TF+"."+IntegerToString(arrHeiken_TF[i+1].count_ma10)
                             , arrHeiken_TF[i+1].ma10,preTextColor,arrHeiken_TF[i+1].time,0,fontsize);
         ObjectSetInteger(0,lblName,OBJPROP_ANCHOR,ANCHOR_CENTER);

         if(draw_lable_d1==false && draw_zigzag)
            create_trend_line("ZigZag_"+lblName
                              ,arrHeiken_TF[pre_index_ma10].time,arrHeiken_TF[pre_index_ma10].close
                              ,arrHeiken_TF[i+1].time,arrHeiken_TF[i+1].close
                              ,preColor,STYLE_SOLID,15);

         pre_index_ma10=i+1;
        }

      color clrColor05 = mid>ma05_0 ? clrColorBuy:clrColorSell;
      color clrColor10 = arrHeiken_TF[i].trend_by_ma10==TREND_BUY?clrColorBuy:clrColorSell;

      //create_trend_line("Draw_Ma05_"+TF+"_"+append1Zero(i+1)+"_"+append1Zero(i),time1,ma05_1,time0,ma05_0,clrColor05,STYLE_SOLID,10);
      if(timeframe==PERIOD_W1)
         create_trend_line("Draw_Ma10_"+TF+"_"+append1Zero(i+1)+"_"+append1Zero(i),time1,ma10_1,time0,ma10_0,clrColor10,STYLE_SOLID,15);

      if(i==0)
        {
           {
            color preTextColor = arrHeiken_TF[i].trend_by_ma10==TREND_BUY ? clrBlue:clrRed;
            string lblName="Ma10_"+TF+"_"+append1Zero(i)+"_"+get_yyyymmdd(arrHeiken_TF[0].time);

            create_label_simple(lblName
                                , TF+"."+getShortName(arrHeiken_TF[0].trend_by_ma10)+"."+IntegerToString(arrHeiken_TF[0].count_ma10)
                                , arrHeiken_TF[0].ma10,preTextColor,arrHeiken_TF[0].time,0,fontsize);
           }

         if(draw_lable_d1)
           {
            double candle_heigh = (arrHeiken_TF[0].high-arrHeiken_TF[0].low)/10;
            string lblName="Heiken_"+TF+"_"+append1Zero(i)+"_"+get_yyyymmdd(arrHeiken_TF[0].time);
            create_label_simple(lblName
                                , ""+IntegerToString(arrHeiken_TF[0].count_heiken)
                                , arrHeiken_TF[0].trend_by_ma10==TREND_BUY?arrHeiken_TF[0].high+candle_heigh:arrHeiken_TF[0].low-candle_heigh,clrBlack,arrHeiken_TF[0].time,0,fontsize);
           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heiken_H(string symbol,ENUM_TIMEFRAMES timeframe,color clrColor,bool draw_ma10,bool draw_ma20,bool draw_ma50,int length=150)
  {
   return;

   if(is_same_symbol(symbol,Symbol())==false)
      return;

   string TF=get_time_frame_name(timeframe);
   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));

   double closePrices[];
   int maLength=length+15;
   ArrayResize(closePrices,maLength);
   for(int i=maLength-1; i>=0; i--)
      closePrices[i]=iClose(symbol,timeframe,i);

   int loop = length;
   if(draw_ma10)
      loop = length-10;
   if(draw_ma20)
      loop = length-20;
   if(draw_ma50)
      loop = length-50;

   int width_ma10=timeframe==PERIOD_W1?15:10;
   bool IS_MONOCHROME_MODE=GetGlobalVariable(BtnColorMode)==AUTO_TRADE_ONN;

   for(int i = 0; i<loop; i++)
     {
      datetime time1=iTime(symbol,timeframe,i+1);
      datetime time0=i==0?TimeCurrent():iTime(symbol,timeframe,i);

      if(draw_ma10)
        {
         double ma10_0=cal_MA(closePrices,10,i);
         double ma10_1=cal_MA(closePrices,10,i+1);

         color clrColorW = clrColor;
         if(IS_MONOCHROME_MODE==false)
            clrColorW = closePrices[i]>ma10_0?clrPaleTurquoise:clrLightPink;

         create_trend_line("Ma10"+TF+"_"+append1Zero(i+1)+"_"+append1Zero(i),time1,ma10_1,time0,ma10_0,clrColorW,STYLE_SOLID,width_ma10);
         //if(i==0)
         //   create_label("Ma10"+TF,TimeCurrent(),ma10_0,"   Ma10_"+TF+" ("+DoubleToString(ma10_0,digits-1)+")");
        }

      if(draw_ma20)
        {
         double ma20_0=cal_MA(closePrices,20,i);
         double ma20_1=cal_MA(closePrices,20,i+1);

         create_trend_line("Ma20"+TF+"_"+append1Zero(i+1)+"_"+append1Zero(i),time1,ma20_1,time0,ma20_0,clrColor,STYLE_SOLID,15);
         //if(i==0)
         //   create_label("Ma20"+TF,TimeCurrent(),ma20_0,"   Ma20_"+TF);
        }

      if(draw_ma50)
        {
         double ma50_0=cal_MA(closePrices,50,i);
         double ma50_1=cal_MA(closePrices,50,i+1);

         create_trend_line("Ma50"+TF+"_"+append1Zero(i+1)+"_"+append1Zero(i),time1,ma50_1,time0,ma50_0,clrColor,STYLE_SOLID,20);
         //if(i==0)
         //   create_label("Ma50"+TF,TimeCurrent(),ma50_0,"   Ma50_"+TF);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_line_ma10_8020(string symbol,ENUM_TIMEFRAMES TIMEFRAME,CandleData &arrHeiken_D1[],int sub_window,int width)
  {
   int size = ArraySize(arrHeiken_D1)-5;
   if(size > 10)
     {
      double min_cur = arrHeiken_D1[0].ma10;
      double max_cur = arrHeiken_D1[0].ma10;
      for(int i = 0; i < size; i++)
        {
         if(min_cur > arrHeiken_D1[i].ma10)
            min_cur = arrHeiken_D1[i].ma10;

         if(max_cur < arrHeiken_D1[i].ma10)
            max_cur = arrHeiken_D1[i].ma10;
        }
      double amp_5per = (max_cur-min_cur)/20;
      max_cur += amp_5per;
      min_cur -= amp_5per;
      double amp_cur = (max_cur-min_cur);

      string prefix = "Ma10"+get_time_frame_name(TIMEFRAME)+"_8020_"+(string)sub_window;
      for(int i = 0; i < size; i++)
        {
         color clrColorW = clrLightGray;
         color clrMa10 = arrHeiken_D1[i].trend_by_ma10==TREND_BUY?clrTeal:clrFireBrick;

         create_trend_line(prefix+append1Zero(i)
                           ,i==0?arrHeiken_D1[i].time-TIME_OF_ONE_H4_CANDLE:arrHeiken_D1[i].time
                           ,100*(arrHeiken_D1[i+1].ma10-min_cur)/amp_cur
                           ,i==0?TimeCurrent()+TIME_OF_ONE_H1_CANDLE:arrHeiken_D1[i-1].time
                           ,100*(arrHeiken_D1[i].ma10-min_cur)/amp_cur
                           ,clrMa10,STYLE_SOLID,width,false,false,true,true,sub_window);

         if(i==0)
            create_label(prefix,TimeCurrent(),100*(arrHeiken_D1[i].ma10-min_cur)/amp_cur
                         ,"   10 "+get_time_frame_name(TIMEFRAME)+" "+getShortName(arrHeiken_D1[i].trend_by_ma10)+(string)arrHeiken_D1[i].count_ma10
                         ,arrHeiken_D1[i].trend_by_ma10,true,8,false,sub_window);

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMarketOpenForTrading(string symbol)
  {
// Kiểm tra xem symbol có hợp lệ không
   if(!SymbolSelect(symbol,true))
     {
      Print("Symbol is not valid or cannot be selected: ",symbol);
      return false;
     }

// Kiểm tra xem có cho phép giao dịch với symbol hay không
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE))
     {
      Print("Trading is not allowed for the symbol: ",symbol);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsLessThan15MinutesToCloseH4(string symbol)
  {
// Thời gian hiện tại
   datetime now=TimeCurrent();

// Tính thời gian đóng nến H4 hiện tại (nến H4 có chu kỳ là 4 giờ=14400 giây)
   datetime close_candle_time=iTime(symbol,PERIOD_H4,0)+14400; // 14400=4 * 60 * 60 giây (4 giờ)

// Tính khoảng thời gian còn lại đến khi nến H4 đóng
   int seconds_left=(int)close_candle_time-(int)now;

// Kiểm tra nếu còn dưới 15 phút (15 * 60=900 giây)
   if(seconds_left <= 900)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsWaited15Minutes(string symbol,datetime last_order_time)
  {
   datetime now=TimeCurrent();
   int seconds_left=(int)now-(int)last_order_time;

   create_lable_simple2("Wait15M",(string)(int)(seconds_left/60)+"min",iLow(symbol,PERIOD_D1,0),clrBlack,iTime(symbol,PERIOD_D1,0)+TIME_OF_ONE_D1_CANDLE);

   if(seconds_left>=900)
      //Đã chờ 15 phút (15 * 60=900 giây)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PassedWaitHours(datetime last_order_time, int wait_hours=7,bool draw_btn=false)
  {
   int wait=(int)TIME_OF_ONE_H1_CANDLE*wait_hours;

   datetime now=TimeCurrent();
   int seconds_left=(int)now-(int)last_order_time;

   int hours = seconds_left / 3600;               // Chia cho 3600 để lấy số giờ
   int minutes = (seconds_left % 3600) / 60;      // Phần còn lại chia 60 để lấy số phút
   string hhmm = append1Zero(hours) + "h" + append1Zero(minutes) + "p";

   if(false) //draw_btn'
     {
      int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));
      createButton("Waited","("+(string)wait_hours+"h) "+hhmm,415+BTN_WIDTH_STANDA,chart_heigh-35,100,30,clrBlack,(seconds_left>=wait)?clrActiveBtn:clrWhite,7);
     }

   if(seconds_left>=wait)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_current_yyyymmdd()
  {
   MqlDateTime cur_time;
   TimeToStruct(TimeCurrent(),cur_time);

   string current_yyyymmdd=(string)cur_time.year +
                           StringFormat("%02d",cur_time.mon) +
                           StringFormat("%02d",cur_time.day);
   return (double)current_yyyymmdd;
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
string get_ddhh()
  {
   int gmtOffset = 7;
   datetime vietnamTime = TimeGMT() + gmtOffset * 3600;

   MqlDateTime cur_time;
   TimeToStruct(vietnamTime, cur_time);

// Ánh xạ thứ (0=Sunday, 1=Monday, ..., 6=Saturday)
   string weekDays[] = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"};
   string dayOfWeek = weekDays[cur_time.day_of_week];

// Định dạng chuỗi có ngày trong tuần
   string current_yyyymmdd = "(" + StringFormat("%02d", cur_time.day) + dayOfWeek
                             + StringFormat("%02d", cur_time.hour) +
                             StringFormat("%02d", cur_time.min) + ")";

   return current_yyyymmdd;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_yyyymmddhh(datetime time)
  {
   MqlDateTime cur_time;
   TimeToStruct(time,cur_time);

   string current_yyyymmdd=(string)cur_time.year +
                           StringFormat("%02d",cur_time.mon)+
                           StringFormat("%02d",cur_time.day)+
                           StringFormat("%02d",cur_time.hour);
   return current_yyyymmdd;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CanOpenDCA(string symbol,ENUM_TIMEFRAMES PERIOD_WAIT,datetime last_order_time)
  {
   if(last_order_time==0)
      return true;

   if(PERIOD_WAIT==PERIOD_M15)
      return IsWaited15Minutes(symbol,last_order_time);

   MqlDateTime cur_time;
   TimeToStruct(iTime(symbol,PERIOD_WAIT,0),cur_time);

   MqlDateTime odr_time;
   TimeToStruct(last_order_time,odr_time);

   string last_order_yyyymmdd=(string)odr_time.year+StringFormat("%02d",odr_time.mon) +
                              StringFormat("%02d",odr_time.day);

   string current_yyyymmdd=(string)cur_time.year +
                           StringFormat("%02d",cur_time.mon) +
                           StringFormat("%02d",cur_time.day);

   if(PERIOD_WAIT==PERIOD_D1)
     {
      if(last_order_yyyymmdd != current_yyyymmdd)
         return true;
     }

   int hround=4;
   if(PERIOD_WAIT==PERIOD_H1)
      hround=1;

   string last_order_time_str=last_order_yyyymmdd+StringFormat("%02d",(odr_time.hour/hround)*hround);

   string current_time_str=current_yyyymmdd+StringFormat("%02d",cur_time.hour);

   if(last_order_time_str != current_time_str)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Schedule()
  {
   int ScheWidth=20;

   int gmtOffset=7;
   datetime vietnamTime=TimeGMT()+gmtOffset * 3600;
   MqlDateTime dt;
   TimeToStruct(vietnamTime,dt);
   int vietnamHour=dt.hour; //Tính giờ Việt Nam (GMT+7)

   string cur_HH=append1Zero(vietnamHour);
   if(vietnamHour==0)
      cur_HH="24";
   if(vietnamHour==1)
      cur_HH="25";

   string cur_Tx=GetCurrentWeekday();

   string shedule_t2=(string)GetGlobalVariable(BtnScheduleT2);
   string shedule_t3=(string)GetGlobalVariable(BtnScheduleT3);
   string shedule_t4=(string)GetGlobalVariable(BtnScheduleT4);
   string shedule_t5=(string)GetGlobalVariable(BtnScheduleT5);
   string shedule_t6=(string)GetGlobalVariable(BtnScheduleT6);

   createButton("T2","T2 "+append1Zero(GetDayOfWeek("T2")),5+ScheWidth*(0),150,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T2")?clrLightGreen:clrWhite,6);
   createButton("T3","T3 "+append1Zero(GetDayOfWeek("T3")),5+ScheWidth*(0),170,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T3")?clrLightGreen:clrWhite,6);
   createButton("T4","T4 "+append1Zero(GetDayOfWeek("T4")),5+ScheWidth*(0),190,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T4")?clrLightGreen:clrWhite,6);
   createButton("T5","T5 "+append1Zero(GetDayOfWeek("T5")),5+ScheWidth*(0),210,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T5")?clrLightGreen:clrWhite,6);
   createButton("T6","T6 "+append1Zero(GetDayOfWeek("T6")),5+ScheWidth*(0),230,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T6")?clrLightGreen:clrWhite,6);

   int size=ArraySize(ARR_TIMES);
   for(int index=0; index<size; index++)
     {
      int hh=ARR_TIMES[index];
      string str_hh=append1Zero(hh);
      string lable_hh=str_hh;
      if(str_hh=="24")
         lable_hh="00";
      if(str_hh=="25")
         lable_hh="01";

      color clrT2=is_same_symbol(cur_Tx,"T2")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t2,str_hh)?clrLightGreen:clrLightGray;
      color clrT3=is_same_symbol(cur_Tx,"T3")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t3,str_hh)?clrLightGreen:clrLightGray;
      color clrT4=is_same_symbol(cur_Tx,"T4")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t4,str_hh)?clrLightGreen:clrLightGray;
      color clrT5=is_same_symbol(cur_Tx,"T5")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t5,str_hh)?clrLightGreen:clrLightGray;
      color clrT6=is_same_symbol(cur_Tx,"T6")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t6,str_hh)?clrLightGreen:clrLightGray;

      createButton(BtnScheduleT2+str_hh,lable_hh,50+(ScheWidth+2)*(index),150,ScheWidth,18,clrBlack,clrT2,6);
      createButton(BtnScheduleT3+str_hh,lable_hh,50+(ScheWidth+2)*(index),170,ScheWidth,18,clrBlack,clrT3,6);
      createButton(BtnScheduleT4+str_hh,lable_hh,50+(ScheWidth+2)*(index),190,ScheWidth,18,clrBlack,clrT4,6);
      createButton(BtnScheduleT5+str_hh,lable_hh,50+(ScheWidth+2)*(index),210,ScheWidth,18,clrBlack,clrT5,6);
      createButton(BtnScheduleT6+str_hh,lable_hh,50+(ScheWidth+2)*(index),230,ScheWidth,18,clrBlack,clrT6,6);
     }

   if(is_economic_news())
     {
      string objName="BtnSchedule"+cur_Tx+"_"+cur_HH;

      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrRed);
      ObjectSetString(0, objName,OBJPROP_FONT,"Arial Bold");
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrYellowGreen);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//https://sslecal2.forexprostools.com/?columns=exc_flags,exc_currency,exc_importance,exc_actual,exc_forecast,exc_previous&category=_employment,_economicActivity,_inflation,_centralBanks,_confidenceIndex,_balance&features=datepicker,timezone,timeselector,filters&countries=5&importance=3&calType=week&timeZone=27&lang=52
bool is_economic_news()
  {
   int gmtOffset=7;
   datetime vietnamTime=TimeGMT()+gmtOffset * 3600;
   MqlDateTime dt;
   TimeToStruct(vietnamTime,dt);
   int vietnamHour=dt.hour; //Tính giờ Việt Nam (GMT+7)

   if(2<=vietnamHour && vietnamHour<=12)
      return false;

   string cur_Tx=GetCurrentWeekday();
   string shedule_Tx=(string)GetGlobalVariable("BtnSchedule"+cur_Tx+"_");

   string cur_HH=append1Zero(vietnamHour);

   if(is_same_symbol(shedule_Tx,cur_HH))
      return true;

   if(vietnamHour==0 && is_same_symbol(shedule_Tx,"24"))
      return true;

   if(vietnamHour==1 && is_same_symbol(shedule_Tx,"25"))
      return true;

   return false;
  }
// Hàm trả về chuỗi tương ứng với ngày hiện tại (Thứ 2 -> Thứ 6)
string GetCurrentWeekday()
  {
   MqlDateTime STime;
   datetime time_current=TimeCurrent();
   datetime time_local=TimeLocal();

   TimeToStruct(time_current,STime);

   int current_day_of_week=STime.day_of_week;

// Dựa trên thứ hiện tại,trả về chuỗi tương ứng
   switch(current_day_of_week)
     {
      case 1:
         return "T2";  // Thứ 2
      case 2:
         return "T3";  // Thứ 3
      case 3:
         return "T4";  // Thứ 4
      case 4:
         return "T5";  // Thứ 5
      case 5:
         return "T6";  // Thứ 6
      case 6:
         return "T7";  // Thứ 7
      case 0:
         return "CN";  // Chủ Nhật
     }

   return ""; // Trường hợp không hợp lệ
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetDayOfWeek(string weekday)
  {
// Lấy ngày hiện tại
   datetime current_time=TimeCurrent();

   MqlDateTime STime;
//datetime time_current=TimeCurrent();
//datetime time_local=TimeLocal();

   TimeToStruct(current_time,STime);
   int current_day_of_week=STime.day_of_week;  // Không truyền tham số

// Map giá trị string weekday thành số (1=Thứ 2,2=Thứ 3,...,7=Chủ Nhật)
   int target_day_of_week;

   if(weekday=="T2")
      target_day_of_week=1;
   else
      if(weekday=="T3")
         target_day_of_week=2;
      else
         if(weekday=="T4")
            target_day_of_week=3;
         else
            if(weekday=="T5")
               target_day_of_week=4;
            else
               if(weekday=="T6")
                  target_day_of_week=5;
               else
                  if(weekday=="T7")
                     target_day_of_week=6;
                  else
                     if(weekday=="CN")
                        target_day_of_week=0;
                     else
                        return -1; // Trường hợp không hợp lệ

// Tạo cấu trúc thời gian hiện tại
   MqlDateTime current_time_struct;
   TimeToStruct(current_time,current_time_struct);

// Tính khoảng cách ngày giữa ngày hiện tại và ngày cần tìm
   int days_difference=target_day_of_week-current_day_of_week;

// Nếu ngày mục tiêu đã qua trong tuần này,lùi lại về tuần trước
   if(days_difference<0)
      days_difference+=7;

// Lấy thời gian mục tiêu bằng cách cộng số ngày chênh lệch
   datetime target_date=current_time+days_difference * 86400; // 86400=số giây trong 1 ngày

// Trả về ngày tương ứng
   MqlDateTime target_time_struct;
   TimeToStruct(target_date,target_time_struct);

   return target_time_struct.day; // Trả về ngày trong tháng
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Set_LM_SL(string symbol, string trend_by_ma10_d1)
  {
   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);

//double max_candle=0;
//CandleData arrHeiken_cur[];
//get_arr_heiken(symbol,PERIOD_D1,arrHeiken_cur,25,true,false);
//for(int i=0;i<ArraySize(arrHeiken_cur);i++)
//  {
//   double candle=arrHeiken_cur[i].high-arrHeiken_cur[i].low;
//   if(candle>max_candle)
//      max_candle=candle;
//  }
   string trend = is_same_symbol(trend_by_ma10_d1,TREND_BUY)?TREND_BUY:TREND_SEL;
   double price = find_wait_price_ma20(symbol,PERIOD_D1,trend,10);

   double LM=price;//arrHeiken_cur[0].ma10;//is_same_symbol(trend_by_ma10_d1,TREND_BUY)?MathMax(arrHeiken_cur[1].ma10,arrHeiken_cur[0].ma10):MathMin(arrHeiken_cur[1].ma10,arrHeiken_cur[0].ma10);


   double amp_sl=amp_d1*2;//MathMin(MathMax(max_candle,amp_h4),amp_d1);
   double SL=is_same_symbol(trend_by_ma10_d1,TREND_SEL)?LM+amp_sl:LM-amp_sl;

   SetGlobalVariable(GLOBAL_VAR_LM+symbol,LM);
   SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double find_wait_price_ma20(string symbol, ENUM_TIMEFRAMES TF, string trend, int ma_index)
  {
   int length=45;
   double closePrices[];
   ArrayResize(closePrices,length);

   for(int i=0; i<length; i++)
      closePrices[i]=iClose(symbol,TF,i);

   int loop=21;
   if(TF==PERIOD_W1)
      loop=13;

   if(is_same_symbol(trend,TREND_BUY))//TREND_BUY
     {
      double min_ma20=MAXIMUM_DOUBLE;
      for(int i=0; i<=20; i++)
        {
         double ma_i=cal_MA(closePrices,ma_index,i);
         if(ma_i<min_ma20)
            min_ma20=ma_i;
        }

      return min_ma20;
     }

   if(is_same_symbol(trend,TREND_SEL))//TREND_SEL
     {
      double max_ma20=0;
      for(int i=0; i<=20; i++)
        {
         double ma_i=cal_MA(closePrices,ma_index,i);
         if(ma_i>max_ma20)
            max_ma20=ma_i;
        }

      return max_ma20;
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,      // event ID
                  const long&   lparam,  // long type event parameter
                  const double& dparam,  // double type event parameter
                  const string& sparam    // string type event parameter
                 )
  {
//Print("OnChartEvent:  "," lparam=",lparam," dparam=",dparam," sparam=",sparam);

   bool processing=GetGlobalVariable("PROCESSING")==AUTO_TRADE_ONN;
   if(processing)
     {
      //Alert("Đang xử lý, vui lòng chờ...");
      //return;
     }
   SetGlobalVariable("PROCESSING", AUTO_TRADE_ONN);

   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      if(is_same_symbol(sparam,GLOBAL_VAR_LM))
        {
         string objName = ObjectGetString(0,sparam,OBJPROP_NAME);
         Print(sparam," was DRAG");

         CheckTrendlineUpdates(true);
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         init_sl_tp_trendline(false);
         OnInit();
         return;
        }
      if(is_same_symbol(sparam,GLOBAL_VAR_SL))
        {
         string objName = ObjectGetString(0,sparam,OBJPROP_NAME);
         Print(sparam," was DRAG");

         CheckTrendlineUpdates();
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         init_sl_tp_trendline(false);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,GLOBAL_LINE_TIMER_1) || is_same_symbol(sparam,GLOBAL_LINE_TIMER_2))
        {
         string objName = ObjectGetString(0,sparam,OBJPROP_NAME);
         Print(sparam," was DRAG");

         SaveTimelinesToFile();
         DrawFiboTimeZone52H4(Period(),true);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,LINE_RR_11) || is_same_symbol(sparam,LINE_RR_12) || is_same_symbol(sparam,LINE_RR_13))
        {
         string objName = ObjectGetString(0,sparam,OBJPROP_NAME);
         Print(sparam," was DRAG ", ObjectGetDouble(0,sparam,OBJPROP_PRICE));

         ChartRedraw();
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;


         string symbol=Symbol();
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
         double amp_sl=MathAbs(SL-LM);
         int multi=1;
         if(is_same_symbol(sparam,LINE_RR_12))
            multi=2;
         if(is_same_symbol(sparam,LINE_RR_13))
            multi=3;

         if(LM>SL)//TREND_BUY
           {
            double old_price = LM + amp_sl*multi;
            double cur_price = NormalizeDouble(ObjectGetDouble(0,sparam,OBJPROP_PRICE),digits);
            double amp_moved = NormalizeDouble(old_price-cur_price, digits)/multi;

            SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL+amp_moved);
           }

         if(LM<SL)//TREND_SEL
           {
            double old_price = LM - amp_sl*multi;
            double cur_price = NormalizeDouble(ObjectGetDouble(0,sparam,OBJPROP_PRICE),digits);
            double amp_moved = NormalizeDouble(cur_price-old_price, digits)/multi;

            SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL-amp_moved);
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }
     }

   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      string symbol=Symbol();

      if(is_same_symbol(sparam,BtnClearChart))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("The lparam=",lparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         ObjectsDeleteAll(0);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnSupportResistance))
        {
         AddSupportResistance();
         ChartRedraw();
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnAddFibo))
        {
         AddFiboline();
         ChartRedraw();
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }
      if(is_same_symbol(sparam,BtnHorTrendline))
        {
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM);
         init_sl_tp_trendline(false);

         //AddHorTrendline();
         AddSword(sparam);
         ChartRedraw();
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnAddTrendline))
        {
         AddTrendline();
         ChartRedraw();
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnSaveTrendline))
        {
         string msg = "Yes: Save TrendLines.\n"
                      +"No:  Save Cycles.\n";
         int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
         if(result==IDYES)
           {
            SaveTrendlinesToFile();
            SaveFibolinesToFile();
           }
         if(result==IDNO)
            SaveTimeCycles();

         ObjectsDeleteAll(0);
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }
      if(is_same_symbol(sparam,BtnClearTrendline))
        {
         ClearTrendlinesFromFile();
         ObjectsDeleteAll(0);
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnFiboline) ||
         is_same_symbol(sparam,BtnSimpleControl) ||
         is_same_symbol(sparam,BtnMacdMode) ||
         is_same_symbol(sparam,BtnColorMode) ||
         is_same_symbol(sparam,BtnHideDrawMode) ||
         is_same_symbol(sparam,BtnShowWDHMode) ||
         is_same_symbol(sparam,BtnHideAngleMode))
        {
         double MODE=GetGlobalVariable(sparam);

         if(MODE==AUTO_TRADE_ONN)
            SetGlobalVariable(sparam,AUTO_TRADE_OFF);
         else
            SetGlobalVariable(sparam,AUTO_TRADE_ONN);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      //BtnScheduleT2
      if(is_same_symbol(sparam,"BtnSchedule"))
        {
         string shedule_name="BtnSchedule";
         if(is_same_symbol(sparam,BtnScheduleT2))
            shedule_name=BtnScheduleT2;
         if(is_same_symbol(sparam,BtnScheduleT3))
            shedule_name=BtnScheduleT3;
         if(is_same_symbol(sparam,BtnScheduleT4))
            shedule_name=BtnScheduleT4;
         if(is_same_symbol(sparam,BtnScheduleT5))
            shedule_name=BtnScheduleT5;
         if(is_same_symbol(sparam,BtnScheduleT6))
            shedule_name=BtnScheduleT6;

         int size=ArraySize(ARR_TIMES);
         string shedule_tx=(string)GetGlobalVariable(shedule_name);
         for(int index=0; index<size; index++)
           {
            int hh=ARR_TIMES[index];

            string str_hh=append1Zero(hh);
            if(is_same_symbol(sparam,str_hh))
              {
               if(is_same_symbol(shedule_tx,str_hh))
                  StringReplace(shedule_tx,str_hh,"");
               else
                  shedule_tx+=str_hh;
              }
           }

         SetGlobalVariable(shedule_name,(double)shedule_tx);

         Draw_Schedule();

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnOptionPeriod))
        {
         ENUM_TIMEFRAMES PERIOD = PERIOD_D1;
         if(is_same_symbol(sparam,"W1"))
            PERIOD = PERIOD_W1;
         if(is_same_symbol(sparam,"D1"))
            PERIOD = PERIOD_D1;
         if(is_same_symbol(sparam,"H4"))
            PERIOD = PERIOD_H4;
         if(is_same_symbol(sparam,"H1"))
            PERIOD = PERIOD_H1;
         if(is_same_symbol(sparam,"M30"))
            PERIOD = PERIOD_M30;
         if(is_same_symbol(sparam,"M15"))
            PERIOD = PERIOD_M15;
         if(is_same_symbol(sparam,"M5"))
            PERIOD = PERIOD_M5;

         SetGlobalVariable(BtnOptionPeriod,(double)PERIOD);

         OpenChartWindow(symbol,PERIOD);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }
      //-----------------------------------------------------------------------
      //-----------------------------------------------------------------------
      //-----------------------------------------------------------------------
      if(is_same_symbol(sparam,BtnSuggestTrend))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         string trend_by_ma10_d1=is_same_symbol(buttonLabel,TREND_BUY)?TREND_BUY:TREND_SEL;

         Set_LM_SL(symbol, trend_by_ma10_d1);

         FindSL(PERIOD_D1, trend_by_ma10_d1);

         init_sl_tp_trendline(false);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnTrendReverse))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("The lparam=",lparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         double amp_sl=MathAbs(SL-LM);
         string trend_revese=get_trend_reverse(LM>SL?TREND_BUY:TREND_SEL);

         double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);

         //LM=find_wait_price_ma20(symbol, PERIOD_H4, trend_revese);
         //SetGlobalVariable(GLOBAL_VAR_LM+symbol,LM);

         if(trend_revese==TREND_BUY)
           {
            LM=ask;
            SetGlobalVariable(GLOBAL_VAR_LM+symbol,LM);
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM-amp_sl);
           }
         else
           {
            LM=bid;
            SetGlobalVariable(GLOBAL_VAR_LM+symbol,LM);
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM+amp_sl);
           }

         FindSL(Period(), trend_revese);
         init_sl_tp_trendline(false);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnSetPriceLimit))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         double amp_trade=MathAbs(SL-LM);
         string trend = (LM>SL)?TREND_BUY:TREND_SEL;
         //string trend_histogram_w1 = ObjectGetString(0,BtnD10+symbol,OBJPROP_TEXT);

         if(is_same_symbol(buttonLabel, "(W1)10"))
           {
            CandleData arrHeiken_W1[];
            get_arr_heiken(symbol,PERIOD_W1,arrHeiken_W1,50,true,true);
            string trend_by_ma10_w1 = arrHeiken_W1[0].trend_by_ma10;

            SetGlobalVariable(GLOBAL_VAR_LM+symbol, find_wait_price_ma20(symbol,PERIOD_W1,trend_by_ma10_w1,10));
            FindSL(PERIOD_W1, trend_by_ma10_w1);
           }

         if(is_same_symbol(sparam, "(D1)20") || is_same_symbol(buttonLabel, "(D1)20"))
           {
            CandleData arrHeiken_D1[];
            get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,50,true,true);
            string trend_by_ma10_d1 = arrHeiken_D1[1].trend_by_ma10;

            SetGlobalVariable(GLOBAL_VAR_LM+symbol, find_wait_price_ma20(symbol,PERIOD_D1,trend_by_ma10_d1,20));

            FindSL(PERIOD_D1, trend_by_ma10_d1);
           }

         if(is_same_symbol(sparam, "(H4)20") || is_same_symbol(buttonLabel, "(H4)20"))
           {
            CandleData arrHeiken_H4[];
            get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,50,true,true);
            string trend_by_ma20_h4 = arrHeiken_H4[1].trend_by_ma20;

            SetGlobalVariable(GLOBAL_VAR_LM+symbol, find_wait_price_ma20(symbol,PERIOD_H4,trend_by_ma20_h4,20));

            FindSL(PERIOD_H4, trend_by_ma20_h4);
           }

         init_sl_tp_trendline(false);
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }


      if(is_same_symbol(sparam,BtnDefaultCycles))
        {
         ENUM_TIMEFRAMES PERIOD = Period();
         bool isLoadTimeCycles=true;
         datetime base_time_1, base_time_2;
         LoadTimelines(base_time_1, base_time_2, false, isLoadTimeCycles);
         create_dragable_vertical_line(GLOBAL_LINE_TIMER_1,base_time_1,clrFireBrick,STYLE_SOLID);
         create_dragable_vertical_line(GLOBAL_LINE_TIMER_2,base_time_2,clrGray,STYLE_SOLID);
         Sleep100();
         SaveTimelinesToFile();
         Sleep100();
         DrawFiboTimeZone52H4(PERIOD,true,false,true);
         Sleep100();

         bool cur_buy_only=GetGlobalVariable(symbol)==TYPE_BUY;
         bool cur_sel_only=GetGlobalVariable(symbol)==TYPE_SEL;
         CandleData arrHeiken_W1[];
         get_arr_heiken(symbol,PERIOD_W1,arrHeiken_W1,50,true,true);

         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         if(LM>SL)//TREND_BUY
            if(arrHeiken_W1[0].trend_by_ma10==TREND_SEL)
              {
               SetGlobalVariable(GLOBAL_VAR_SL+symbol, LM);
               SetGlobalVariable(GLOBAL_VAR_LM+symbol,SL);
              }
         if(LM<SL)//TREND_SEL
            if(arrHeiken_W1[0].trend_by_ma10==TREND_BUY)
              {
               SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM);
               SetGlobalVariable(GLOBAL_VAR_LM+symbol,SL);
              }
         init_sl_tp_trendline(false);
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnResetTimeline))
        {
         ENUM_TIMEFRAMES PERIOD = Period(); //PERIOD_H4;//
         Reset_Fibo_Timelines(PERIOD);
         Sleep100();
         SaveTimelinesToFile();
         DrawFiboTimeZone52H4(PERIOD,true);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnMid3d))
        {
         setPriceMid3d(symbol);
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnSetTimeHere))
        {
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         double amp_w1,amp_d1,amp_h4,amp_h1;
         GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);
         string trend = LM > SL ? TREND_BUY:TREND_SEL;

         double NEW_LM = LM;
         double high=MathMax(iHigh(symbol,PERIOD_D1,1), iHigh(symbol,PERIOD_D1,0));
         double low=MathMin(iLow(symbol,PERIOD_D1,1), iLow(symbol,PERIOD_D1,0));
         double mid=(high+low)/2;

         double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
         double spread = MathAbs(ask-bid)*3;
         ENUM_TIMEFRAMES TF = Period();

         if(is_same_symbol(sparam,".iHigh"))
            NEW_LM = high;
         if(is_same_symbol(sparam,".iLow"))
            NEW_LM = low;
         if(is_same_symbol(sparam,".iMid"))
            NEW_LM = mid;

         if(is_same_symbol(sparam,".iMaH10"))
            NEW_LM = cal_MA_XX(symbol,PERIOD_H1,10,0);
         if(is_same_symbol(sparam,".iMaH20"))
            NEW_LM = cal_MA_XX(symbol,PERIOD_H1,20,0);
         if(is_same_symbol(sparam,".iMaH50"))
            NEW_LM = cal_MA_XX(symbol,PERIOD_H1,50,0);

         if(is_same_symbol(sparam,".iNow"))
            NEW_LM = trend==TREND_BUY?iHigh(symbol,TF,0):iLow(symbol,TF,0);

         if(is_same_symbol(sparam,".iHei"))
           {
            CandleData arrHeiken_TF[];
            get_arr_heiken(symbol,PERIOD_H4,arrHeiken_TF,55,true,false);

            int loop = ArraySize(arrHeiken_TF)-10;
            datetime time_shift=arrHeiken_TF[1].time-arrHeiken_TF[2].time;

            double higest=0;
            double lowest=DBL_MAX;

            int iIndex=1;
            int count = 0;
            string trend_iHei1 = "";

            for(int i = 0; i < loop; i++)
              {
               if(arrHeiken_TF[i].count_heiken == 1)
                 {
                  if(count == 0)
                     trend_iHei1 = arrHeiken_TF[i].trend_heiken;


                  // Chỉ xét các nến đầu tiên có cùng trend với trend_iHei1
                  if(arrHeiken_TF[i].trend_heiken == trend_iHei1)
                    {
                     count++;

                     if(is_same_symbol(sparam, ".iHei1") && count == 1)
                       {
                        iIndex = i;
                        break;
                       }

                     if(is_same_symbol(sparam, ".iHei2") && count == 2)
                       {
                        iIndex = i;
                        break;
                       }

                     if(is_same_symbol(sparam, ".iHei3") && count == 3)
                       {
                        iIndex = i;
                        break;
                       }
                    }
                 }
              }

            for(int idx=iIndex; idx<=iIndex+1; idx++)
              {
               double low=iLow(symbol,PERIOD_H4,idx);
               double hig=iHigh(symbol,PERIOD_H4,idx);
               if(lowest>low)
                  lowest=low;
               if(higest<hig)
                  higest=hig;
              }

            create_filled_rectangle(".iHei",iTime(symbol,PERIOD_H4,iIndex), lowest, iTime(symbol,PERIOD_H4,iIndex+1), higest, clrRed);

            bool is_buy = trend_iHei1==TREND_BUY?true:false;
            double temp_sl=is_buy?lowest:higest;
            double temp_en=cal_MA_XX(symbol,PERIOD_H1,10,iIndex);
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,temp_sl);
            SetGlobalVariable(GLOBAL_VAR_LM+symbol,temp_en);
            init_sl_tp_trendline(false);

            //if(is_same_symbol(sparam,".iMaH"))
            OnInit();

            return;
           }

         SetGlobalVariable(GLOBAL_VAR_LM+symbol,NEW_LM);

         init_sl_tp_trendline(false);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnRevRR))
        {
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         double amp_trade=MathAbs(SL-LM);

         if(LM>SL)//TREND_BUY->TREND_SEL
           {
            //SetGlobalVariable(GLOBAL_VAR_LM+symbol,SL);
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM+amp_trade);
           }
         else //TREND_SEL->TREND_BUY
           {
            //SetGlobalVariable(GLOBAL_VAR_LM+symbol,SL);
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM-amp_trade);
           }

         init_sl_tp_trendline(false);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnSetAmpTrade))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("The lparam=",lparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         if(is_same_symbol(sparam,"??"))
           {
            DrawFiboTimeZone52H4(Period(),true);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            return;
           }

         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         double bid=SymbolInfoDouble(symbol,SYMBOL_BID);

         double amp_w1,amp_d1,amp_h4,amp_h1;
         GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);

         if(is_same_symbol(sparam,"Move"))
           {
            double amp_trade = amp_d1*2;//MathAbs(LM-SL);

            if(LM>SL)//TREND_BUY
              {
               SetGlobalVariable(GLOBAL_VAR_LM+symbol,bid);
               SetGlobalVariable(GLOBAL_VAR_SL+symbol,bid-amp_trade);
              }

            if(LM<SL)//TREND_SEL
              {
               SetGlobalVariable(GLOBAL_VAR_LM+symbol,bid);
               SetGlobalVariable(GLOBAL_VAR_SL+symbol,bid+amp_trade);
              }

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         if(is_same_symbol(sparam,"00"))
           {
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         double amp_trade=amp_d1;
         if(is_same_symbol(sparam,"D1"))
            amp_trade=amp_d1;
         if(is_same_symbol(sparam,"W1"))
            amp_trade=amp_w1;
         if(is_same_symbol(sparam,"H4"))
            amp_trade=amp_h4;

         if(LM>SL)//TREND_BUY
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM-amp_trade);
         if(LM<SL)//TREND_SEL
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,LM+amp_trade);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnExitAllTrade))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         string msg = "(SetTPEntry) "+buttonLabel+"?\n";
         int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
         if(result==IDYES)
           {
            int size = getArraySymbolsSize();
            for(int index = 0; index < size; index++)
              {
               string temp_symbol = getSymbolAtIndex(index);

               ClosePositivePosition(temp_symbol,TREND_BUY);
               ClosePositivePosition(temp_symbol,TREND_SEL);

               ModifyTpEntry(temp_symbol,TREND_BUY);
               ModifyTpEntry(temp_symbol,TREND_SEL);
              }

            //            WriteFileContent(FILE_MSG_LIST_R2C1,"");
            //            WriteFileContent(FILE_MSG_LIST_WAIT,"");
            //
            //            WriteFileContent(FILE_MSG_LIST_R1C1,"");
            //            WriteFileContent(FILE_MSG_LIST_R1C2,"");
            //            WriteFileContent(FILE_MSG_LIST_R1C3,"");
            //            WriteFileContent(FILE_MSG_LIST_REVR,"");

            LoadTradeBySeqEvery5min();
            LoadSLTPEvery5min(false);

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnReSetTPEntry))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         string msg = symbol+"    "+buttonLabel+"?\n";
         int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
         if(result==IDYES)
           {
            ModifyTpEntry(symbol,TREND_BUY);
            ModifyTpEntry(symbol,TREND_SEL);
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnSetTPHereR1) || is_same_symbol(sparam,BtnSetTPHereR2) || is_same_symbol(sparam,BtnSetTPHereR3))
        {
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
         double cur_price = NormalizeDouble(ObjectGetDouble(0,LINE_RR_13,OBJPROP_PRICE),digits-1);

         if(is_same_symbol(sparam,BtnSetTPHereR1))
            cur_price = NormalizeDouble(ObjectGetDouble(0,LINE_RR_11,OBJPROP_PRICE),digits-1);
         if(is_same_symbol(sparam,BtnSetTPHereR2))
            cur_price = NormalizeDouble(ObjectGetDouble(0,LINE_RR_12,OBJPROP_PRICE),digits-1);

         string TREND="";
         if(LM>SL)//TREND_BUY
            TREND=TREND_BUY;

         if(LM<SL)//TREND_SEL
            TREND=TREND_SEL;

         ModifyTp(symbol,TREND,cur_price);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnFindSL))
        {
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         string trend = (LM>SL)?TREND_BUY:TREND_SEL;

         if(is_same_symbol(sparam, "_CurTrend"))
           {
            CandleData arrHeiken_TF[];
            get_arr_heiken(symbol,PERIOD_H4,arrHeiken_TF,55,true,false);

            trend = arrHeiken_TF[0].trend_by_ma10;

            int iIndex=1;
            for(int i = 1; i < 27; i++)
               if(arrHeiken_TF[i].count_ma10 == 1)
                 {
                  iIndex=i;
                  break;
                 }
            double NEW_LM = trend==TREND_BUY?iHigh(symbol,PERIOD_H4,iIndex):iLow(symbol,PERIOD_H4,iIndex);
            SetGlobalVariable(GLOBAL_VAR_LM+symbol,NEW_LM);

            double NEW_SL = FindSL(PERIOD_H4, trend);
            NEW_SL = trend==TREND_BUY?MathMin(NEW_SL, iLow(symbol,PERIOD_H4,iIndex)):MathMax(NEW_SL, iHigh(symbol,PERIOD_H4,iIndex));
            SetGlobalVariable(GLOBAL_VAR_SL+symbol, NEW_SL);

            OnInit();
            return;
           }

         if(is_same_symbol(sparam, "_H1"))
            FindSL(PERIOD_H4, trend);
         else
            if(is_same_symbol(sparam, "_H4"))
               FindSL(PERIOD_D1, trend);
            else
               if(is_same_symbol(sparam, "_D1"))
                  FindSL(PERIOD_W1, trend);
               else
                  FindSL(PERIOD_W1, trend);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnSetSLHere))
        {
         string trend="";
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);

         if(LM>SL)//TREND_BUY
            trend=TREND_BUY;
         if(LM<SL)//TREND_SEL
            trend=TREND_SEL;

         ModifySL(symbol,trend,SL);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnFindR11))
        {
         double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
         double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
         double amp_sl = MathAbs(LM-SL);

         if(LM>SL)//TREND_BUY
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL-amp_sl);
         if(LM<SL)//TREND_SEL
            SetGlobalVariable(GLOBAL_VAR_SL+symbol,SL+amp_sl);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnInitWaitMacdM5))
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);

            double trade_type=GetGlobalVariable(BtnNoticeW1+temp_symbol);
            SetGlobalVariable(BtnWaitMacdM5ThenAutoTrade+temp_symbol,trade_type);
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnDeInitWaitMacdM5))
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);

            SetGlobalVariable(BtnWaitMacdM5ThenAutoTrade+temp_symbol,AUTO_TRADE_OFF);
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }


      if(is_same_symbol(sparam,BtnDeInitNoticeM5W1))
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);
            SetGlobalVariable(BtnNoticeSeq102050M5+temp_symbol,AUTO_TRADE_OFF);
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnInitNoticeM5W1))
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);

            double trade_type=GetGlobalVariable(BtnNoticeW1+temp_symbol);
            SetGlobalVariable(BtnNoticeSeq102050M5+temp_symbol,trade_type);
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnNoticeSeq102050M5) || is_same_symbol(sparam,BtnNoticeSeq102050H1) || is_same_symbol(sparam,BtnNoticeW1))
        {
         double trade_type=GetGlobalVariable(sparam+symbol);

         if((MathAbs(trade_type)==MathAbs(AUTO_TRADE_BUY)))
           {
            SetGlobalVariable(sparam+symbol,AUTO_TRADE_SEL);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
           }
         else
            if(MathAbs(trade_type)==MathAbs(AUTO_TRADE_SEL))
              {
               SetGlobalVariable(sparam+symbol,AUTO_TRADE_OFF);
               SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
               OnInit();
              }
            else
               if(MathAbs(trade_type)==MathAbs(AUTO_TRADE_OFF))
                 {
                  SetGlobalVariable(sparam+symbol,AUTO_TRADE_BUY);
                  SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
                  OnInit();
                 }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }


      if(is_same_symbol(sparam,BtnCloseWhen_))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);

         double value=TP_WHEN_HeiMa50;
         if(is_same_symbol(sparam,"HeiMa10"))
            value=TP_WHEN_HeiMa10;
         if(is_same_symbol(sparam,"HeiMa20"))
            value=TP_WHEN_HeiMa20;
         if(is_same_symbol(sparam,"HeiMa50"))
            value=TP_WHEN_HeiMa50;

         if(is_same_symbol(sparam,"Ma10_07"))
            value=TP_WHEN_Ma10_07;
         if(is_same_symbol(sparam,"Ma10_13"))
            value=TP_WHEN_Ma10_13;
         if(is_same_symbol(sparam,"Ma10_21"))
            value=TP_WHEN_Ma10_21;
         if(is_same_symbol(sparam,"Ma10_27"))
            value=TP_WHEN_Ma10_27;

         SetGlobalVariable(BtnCloseWhen_,value);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnNoticeMaCross))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         if(is_same_symbol(buttonLabel,TREND_BUY))
            StringReplace(buttonLabel,TREND_BUY,TREND_SEL);
         else
            if(is_same_symbol(buttonLabel,TREND_SEL))
               StringReplace(buttonLabel,TREND_SEL,"");
            else
               buttonLabel+=" "+TREND_BUY;
         StringReplace(buttonLabel,"  "," ");
         StringReplace(buttonLabel,"  "," ");
         StringReplace(buttonLabel,"  "," ");
         ObjectSetString(0,sparam,OBJPROP_TEXT,buttonLabel);



         string _H1Ma10=ObjectGetString(0,BtnNoticeMaCross+"_H1Ma10",OBJPROP_TEXT);
         string _H1Ma20=ObjectGetString(0,BtnNoticeMaCross+"_H1Ma20",OBJPROP_TEXT);
         string _H1Ma50=ObjectGetString(0,BtnNoticeMaCross+"_H1Ma50",OBJPROP_TEXT);
         string _H1Seq050=ObjectGetString(0,BtnNoticeMaCross+"_H1Seq050",OBJPROP_TEXT);
         string _H1Seq200=ObjectGetString(0,BtnNoticeMaCross+"_H1Seq200",OBJPROP_TEXT);
         string _H1HeikenC2=ObjectGetString(0,BtnNoticeMaCross+"_H1HeikenC2",OBJPROP_TEXT);

         string _H4HeikenC2=ObjectGetString(0,BtnNoticeMaCross+"_H4HeikenC2",OBJPROP_TEXT);
         string _H4Ma10=ObjectGetString(0,BtnNoticeMaCross+"_H4Ma10",OBJPROP_TEXT);
         string _H4Ma20=ObjectGetString(0,BtnNoticeMaCross+"_H4Ma20",OBJPROP_TEXT);
         string _H4Ma50=ObjectGetString(0,BtnNoticeMaCross+"_H4Ma50",OBJPROP_TEXT);
         string _H41020=ObjectGetString(0,BtnNoticeMaCross+"_H41020",OBJPROP_TEXT);
         string _H42050=ObjectGetString(0,BtnNoticeMaCross+"_H42050",OBJPROP_TEXT);

         string find_trend_H1="7";
         string find_trend_H4="7";


         find_trend_H1+=is_same_symbol(_H1HeikenC2,TREND_BUY)?HeikenCandleC2_BUY:"";
         find_trend_H1+=is_same_symbol(_H1HeikenC2,TREND_SEL)?HeikenCandleC2_SEL:"";
         find_trend_H1+=is_same_symbol(_H1Ma10,TREND_BUY)?HeivsMa10_BUY:"";
         find_trend_H1+=is_same_symbol(_H1Ma10,TREND_SEL)?HeivsMa10_SEL:"";
         find_trend_H1+=is_same_symbol(_H1Ma20,TREND_BUY)?HeivsMa20_BUY:"";
         find_trend_H1+=is_same_symbol(_H1Ma20,TREND_SEL)?HeivsMa20_SEL:"";
         find_trend_H1+=is_same_symbol(_H1Ma50,TREND_BUY)?HeivsMa50_BUY:"";
         find_trend_H1+=is_same_symbol(_H1Ma50,TREND_SEL)?HeivsMa50_SEL:"";
         find_trend_H1+=is_same_symbol(_H1Seq050,TREND_BUY)?HeivsSeqMa102050_BUY:"";
         find_trend_H1+=is_same_symbol(_H1Seq050,TREND_SEL)?HeivsSeqMa102050_SEL:"";
         find_trend_H1+=is_same_symbol(_H1Seq200,TREND_BUY)?HeivsSeqMa102050200_BUY:"";
         find_trend_H1+=is_same_symbol(_H1Seq200,TREND_SEL)?HeivsSeqMa102050200_SEL:"";




         find_trend_H4+=is_same_symbol(_H4HeikenC2,TREND_BUY)?HeikenCandleC2_BUY:"";
         find_trend_H4+=is_same_symbol(_H4HeikenC2,TREND_SEL)?HeikenCandleC2_SEL:"";
         find_trend_H4+=is_same_symbol(_H4Ma10,TREND_BUY)?HeivsMa10_BUY:"";
         find_trend_H4+=is_same_symbol(_H4Ma10,TREND_SEL)?HeivsMa10_SEL:"";
         find_trend_H4+=is_same_symbol(_H4Ma20,TREND_BUY)?HeivsMa20_BUY:"";
         find_trend_H4+=is_same_symbol(_H4Ma20,TREND_SEL)?HeivsMa20_SEL:"";
         find_trend_H4+=is_same_symbol(_H4Ma50,TREND_BUY)?HeivsMa50_BUY:"";
         find_trend_H4+=is_same_symbol(_H4Ma50,TREND_SEL)?HeivsMa50_SEL:"";
         find_trend_H4+=is_same_symbol(_H41020,TREND_BUY)?HeivsSeqMa102050_BUY:"";
         find_trend_H4+=is_same_symbol(_H41020,TREND_SEL)?HeivsSeqMa102050_SEL:"";
         find_trend_H4+=is_same_symbol(_H42050,TREND_BUY)?HeivsSeqMa102050200_BUY:"";
         find_trend_H4+=is_same_symbol(_H42050,TREND_SEL)?HeivsSeqMa102050200_SEL:"";

         SetGlobalVariable(BtnNoticeMaCross+symbol+"_H1",(double)find_trend_H1);
         SetGlobalVariable(BtnNoticeMaCross+symbol+"_H4",(double)find_trend_H4);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnClearNoticeMaCross))
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);
            SetGlobalVariable(BtnNoticeMaCross+temp_symbol+"_H1",7);
            SetGlobalVariable(BtnNoticeMaCross+temp_symbol+"_H4",7);
           }

         PushMessage("RESET_NOTICE "+get_vnhour(),FILE_MSG_LIST_SL);

         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnResetMaCross))
        {
         if(is_same_symbol(sparam,BtnResetMaCross+"_H1"))
            SetGlobalVariable(BtnNoticeMaCross+symbol+"_H1",0.0);

         if(is_same_symbol(sparam,BtnResetMaCross+"_H4"))
            SetGlobalVariable(BtnNoticeMaCross+symbol+"_H4",0.0);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }


      //-----------------------------------------------------------------------
      if(is_same_symbol(sparam,BtnD10) || is_same_symbol(sparam,BtnNoticeD1))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("The lparam=",sparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         int intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
         if(intPeriod==-1)
            intPeriod = PERIOD_D1;

         OpenChartWindow(buttonLabel,(ENUM_TIMEFRAMES)intPeriod);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnMsgR2C1_) ||
         is_same_symbol(sparam,BtnMsgR2C2_) ||

         is_same_symbol(sparam,BtnMsgSTOP_) ||
         is_same_symbol(sparam,BtnMsgREVR_) ||
         is_same_symbol(sparam,BtnMsgR1C3_) ||
         is_same_symbol(sparam,BtnMsgR1C2_) ||
         is_same_symbol(sparam,BtnMsgR1C1_))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("The lparam=",lparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         if(is_same_symbol(buttonLabel,symbol))
            return;

         int intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
         if(intPeriod<0)
            intPeriod=PERIOD_H4;

         if(is_same_symbol(buttonLabel,"(W10)"))
            intPeriod = PERIOD_W1;

         //if(is_same_symbol(buttonLabel,get_time_frame_name(PERIOD_D1)))
         //   intPeriod = PERIOD_D1;
         //if(is_same_symbol(buttonLabel,get_time_frame_name(PERIOD_H4)))
         //   intPeriod = PERIOD_H4;
         //if(is_same_symbol(buttonLabel,get_time_frame_name(PERIOD_H1)))
         //   intPeriod = PERIOD_H1;
         //if(is_same_symbol(buttonLabel,get_time_frame_name(PERIOD_M30)))
         //   intPeriod = PERIOD_M30;
         //if(is_same_symbol(buttonLabel,get_time_frame_name(PERIOD_M15)))
         //   intPeriod = PERIOD_M15;

         OpenChartWindow(buttonLabel,(ENUM_TIMEFRAMES)intPeriod);

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnCloseLimit))
        {
         //string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         //string msg = symbol+"    "+buttonLabel+"?\n";
         //int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
         //if(result==IDYES)
           {
            CloseLimitOrder(symbol,TREND_BUY);
            CloseLimitOrder(symbol,TREND_SEL);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }
        }

      if(is_same_symbol(sparam,BtnCloseSymbol))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         string msg = symbol+"    "+buttonLabel+"?\n";
         int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
         if(result==IDYES)
           {
            CloseLimitOrder(symbol,TREND_BUY);
            CloseLimitOrder(symbol,TREND_SEL);
            ClosePositionByTrend(symbol,TREND_BUY);
            ClosePositionByTrend(symbol,TREND_SEL);
            //ClosePositivePosition(symbol,TREND_BUY);
            //ClosePositivePosition(symbol,TREND_SEL);
           }

         ObjectsDeleteAll(0);
         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         OnInit();
         return;
        }

      if(is_same_symbol(sparam,BtnTpPositiveThisSymbol))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         Print("The lparam=",sparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

         //string msg = buttonLabel+"?\n";
         //int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
         //if(result==IDYES)
           {
            ClosePositivePosition(symbol,TREND_BUY);
            ClosePositivePosition(symbol,TREND_SEL);

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }
        }

      if(is_same_symbol(sparam,BtnCloseAllLimit))
        {
         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         //string msg = buttonLabel+"?\n";
         //int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
         //if(result==IDYES)
           {
            int size = getArraySymbolsSize();
            for(int index = 0; index < size; index++)
              {
               string temp_symbol = getSymbolAtIndex(index);

               CloseLimitOrder(temp_symbol,TREND_BUY);
               CloseLimitOrder(temp_symbol,TREND_SEL);
              }

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }
        }

      if(is_same_symbol(sparam,BtnTpPositiveAllSymbols))
        {
         Alert("Tự đóng từng task một");
         return;

         string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
         //string msg = buttonLabel+"?\n";
         //int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
         //if(result==IDYES)
           {
            int size = getArraySymbolsSize();
            for(int index = 0; index < size; index++)
              {
               string temp_symbol = getSymbolAtIndex(index);
               ClosePositivePosition(temp_symbol,TREND_BUY);
               ClosePositivePosition(temp_symbol,TREND_SEL);
              }

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }
        }

      if(is_same_symbol(sparam,BtnClearMessageRxCx) ||

         is_same_symbol(sparam,BtnClearMessageR2C1) ||
         is_same_symbol(sparam,BtnClearMessageR2C2) ||

         is_same_symbol(sparam,BtnClearMessageR1C1) ||
         is_same_symbol(sparam,BtnClearMessageR1C2) ||
         is_same_symbol(sparam,BtnClearMessageR1C3) ||
         is_same_symbol(sparam,BtnClearMessageREVR) ||
         is_same_symbol(sparam,BtnClearMessageSTOP))
        {
         if(is_same_symbol(sparam,BtnClearMessageRxCx))
           {
            string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
            //string msg = buttonLabel+"?\n";
            //int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
            //if(result==IDYES)
              {
               WriteFileContent(FILE_MSG_LIST_R1C1,"");
               WriteFileContent(FILE_MSG_LIST_R1C2,"");
               WriteFileContent(FILE_MSG_LIST_R1C3,"");
               //WriteFileContent(FILE_MSG_LIST_REVR,"");

               WriteFileContent(FILE_MSG_LIST_R2C1,"");
               CreateMessagesBtn(BtnMsgR2C1_);

               CreateMessagesBtn(BtnMsgR1C1_);
               CreateMessagesBtn(BtnMsgR1C2_);
               CreateMessagesBtn(BtnMsgR1C3_);
               //CreateMessagesBtn(BtnMsgREVR_);

               LoadTradeBySeqEvery5min();
               LoadSLTPEvery5min(true);

               SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
               OnInit();
               return;
              }
           }

         if(is_same_symbol(sparam,BtnClearMessageR2C1))
           {
            WriteFileContent(FILE_MSG_LIST_R2C1,"");
            CreateMessagesBtn(BtnMsgR2C1_);

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         if(is_same_symbol(sparam,BtnClearMessageR2C2))
           {
            WriteFileContent(FILE_MSG_LIST_WAIT,"");
            CreateMessagesBtn(BtnMsgR2C2_);

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         if(is_same_symbol(sparam,BtnClearMessageSTOP))
           {
            WriteFileContent(FILE_MSG_LIST_SL,"");
            CreateMessagesBtn(BtnMsgSTOP_);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         if(is_same_symbol(sparam,BtnClearMessageREVR))
           {
            WriteFileContent(FILE_MSG_LIST_REVR,"");
            CreateMessagesBtn(BtnMsgREVR_);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         if(is_same_symbol(sparam,BtnClearMessageR1C3))
           {
            WriteFileContent(FILE_MSG_LIST_R1C3,"");
            CreateMessagesBtn(BtnMsgR1C3_);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         if(is_same_symbol(sparam,BtnClearMessageR1C2))
           {
            WriteFileContent(FILE_MSG_LIST_R1C2,"");
            CreateMessagesBtn(BtnMsgR1C2_);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         if(is_same_symbol(sparam,BtnClearMessageR1C1))
           {
            WriteFileContent(FILE_MSG_LIST_R1C1,"");
            CreateMessagesBtn(BtnMsgR1C1_);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
            return;
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      if(is_same_symbol(sparam,BtnOpenStop1L))
        {
         //Alert(get_time_frame_name(Period()));

         //------------------------------------------------------------
         int count_trade=0;
         string last_comment="";
         double volume_opening=0;
         double profit=0,cur_sl_buy=0,cur_sl_sel=0;
         for(int i=PositionsTotal()-1; i>=0; i--)
            if(m_position.SelectByIndex(i))
               if(is_same_symbol(m_position.Symbol(),symbol))
                 {
                  count_trade+=1;
                  last_comment+="    "+m_position.Comment();
                  double temp_profit = m_position.Profit()+m_position.Swap()+m_position.Commission();

                  if(is_same_symbol(m_position.TypeDescription(),TREND_BUY))
                     cur_sl_buy=m_position.StopLoss();
                  if(is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                     cur_sl_sel=m_position.StopLoss();

                  if(volume_opening<m_position.Volume())
                     volume_opening=m_position.Volume();

                  profit+=temp_profit;
                 }

         for(int i=OrdersTotal()-1; i>=0; i--)
            if(m_order.SelectByIndex(i))
               if(is_same_symbol(m_order.Symbol(),symbol))
                  m_trade.OrderDelete(m_order.Ticket());


         int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
         double SL=NormalizeDouble(GetGlobalVariable(GLOBAL_VAR_SL+symbol), digits);
         double LM=NormalizeDouble(GetGlobalVariable(GLOBAL_VAR_LM+symbol), digits);
         double TP1 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_11,OBJPROP_PRICE),digits-1);
         double TP2 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_12,OBJPROP_PRICE),digits-1);
         double TP3 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_13,OBJPROP_PRICE),digits-1);

         double amp_sl = NormalizeDouble(MathAbs(LM-SL), digits);

         string trend_now="";
         if(LM>SL) //TREND_BUY
            trend_now=TREND_BUY;
         if(LM<SL) //TREND_SEL
            trend_now=TREND_SEL;

         string comment_mk1=create_comment(get_ddhh(),trend_now,count_trade+1,"");

         if(count_trade>=1 && profit<=1)
           {
            Alert(DoubleToString(profit,2) + "$    Khong cho nhoi lenh am: "+ symbol + "    "+comment_mk1);
            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            return;
           }

         double risk=Risk_1L();

         double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
         double spread = MathAbs(ask-bid);

         CandleData arrHeiken_Cr[];
         get_arr_heiken(symbol,Period(),arrHeiken_Cr,50,true,true);


         string msg=get_vntime()+trend_now+"_STOP "+symbol+" risk:"+DoubleToString(risk,1) +"    "+comment_mk1+"?\n";
         msg+= "Yes: Limit/Stop \n";
         msg+= "No : Market \n";
         if(is_same_symbol(trend_now,arrHeiken_Cr[0].trend_ma10vs20)==false)
            msg+="\nChú ý: Đang đánh ngược "+get_time_frame_name(Period())+" Ma10vsMa20: " + arrHeiken_Cr[0].trend_ma10vs20;

         double volume = calc_volume_by_amp(symbol,amp_sl,risk);
         //------------------------------------------------------------
         //------------------------------------------------------------
         //------------------------------------------------------------
         //------------------------------------------------------------
         //------------------------------------------------------------
         int result=MessageBox(msg,"Confirm",MB_YESNOCANCEL);

         if(result==IDYES)
           {
            double TP=0;
            datetime expiration_time_25h = (datetime)(TimeCurrent() + 48 * 3600); // 25 tiếng (25 giờ * 3600 giây)


            if(LM>SL) //TREND_BUY
              {
               double entry = LM+spread;
               double real_sl = SL-spread;
               double real_amp_sl = MathAbs(entry-real_sl);
               TP=LM+amp_sl;
               double real_tp = entry+real_amp_sl;
               double volume = calc_volume_by_amp(symbol,real_amp_sl,risk);

               if(volume_opening>0)
                  volume=volume_opening;

               if(bid>entry)
                 {
                  m_trade.BuyLimit(volume,entry,symbol,real_sl,TP1,ORDER_TIME_SPECIFIED, expiration_time_25h,comment_mk1);
                 }
               else
                 {
                  m_trade.BuyStop(volume,entry,symbol,real_sl,TP1, ORDER_TIME_SPECIFIED, expiration_time_25h,comment_mk1);
                 }
              }

            if(LM<SL) //TREND_SEL
              {
               double entry = LM-spread;
               double real_sl = SL+spread;
               double real_amp_sl = MathAbs(real_sl-entry);
               TP=LM-amp_sl;
               double real_tp = entry-real_amp_sl;
               double volume = calc_volume_by_amp(symbol,real_amp_sl,risk);

               if(volume_opening>0)
                  volume=volume_opening;

               if(ask<entry)
                  m_trade.SellLimit(volume,entry,symbol,real_sl,TP1, ORDER_TIME_SPECIFIED, expiration_time_25h,comment_mk1);
               else
                  m_trade.SellStop(volume,entry,symbol,real_sl,TP1, ORDER_TIME_SPECIFIED, expiration_time_25h,comment_mk1);
              }

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
           }
         if(result==IDNO)
           {
            double TP=0;

            if(LM>SL) //TREND_BUY
              {
               double entry = ask+spread;
               double real_sl = SL-spread;
               double real_amp_sl = MathAbs(entry-real_sl);
               TP=LM+amp_sl;
               double real_tp = entry+real_amp_sl;
               double volume = calc_volume_by_amp(symbol,real_amp_sl,risk);

               if(volume_opening>0)
                  volume=volume_opening;


               m_trade.Buy(volume,symbol,ask+spread,real_sl,TP1,MASK_MARKET+comment_mk1);
              }

            if(LM<SL) //TREND_SEL
              {
               double entry = bid-spread;
               double real_sl = SL+spread;
               double real_amp_sl = MathAbs(real_sl-entry);
               TP=LM-amp_sl;
               double real_tp = entry-real_amp_sl;
               double volume = calc_volume_by_amp(symbol,real_amp_sl,risk);

               if(volume_opening>0)
                  volume=volume_opening;

               m_trade.Sell(volume,symbol,bid-spread,real_sl,TP1,MASK_MARKET+comment_mk1);
              }

            SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
            OnInit();
           }

         SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
         return;
        }

      //-----------------------------------------------------------------------
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      ChartRedraw();
      SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
     }

   SetGlobalVariable("PROCESSING", AUTO_TRADE_OFF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FindSL(ENUM_TIMEFRAMES TF, string TREND)
  {
   double NEW_SL = 0;
   string symbol = Symbol();
   double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
   double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);
   double amp_trade = amp_d1;

   int size = 7;
   if(TF==PERIOD_D1)
     {
      size = 7;
      amp_trade = amp_d1;
     }

   if(TF<=PERIOD_H4)
     {
      size = 12;
      amp_trade = amp_h4;
     }

   CandleData arrHeiken_Cr[];
   get_arr_heiken(symbol,TF,arrHeiken_Cr,size+10,true,true);

   double lowest=0.0,higest=0.0;
   for(int idx=0; idx<=size; idx++)
     {
      double low=arrHeiken_Cr[idx].low;
      double hig=arrHeiken_Cr[idx].high;
      if((idx==0) || (lowest==0) || (lowest>low))
         lowest=low;
      if((idx==0) || (higest==0) || (higest<hig))
         higest=hig;
     }

   if(is_same_symbol(TREND, TREND_BUY))
     {

      if(MathAbs(lowest-LM) < amp_trade)
         NEW_SL=LM-amp_trade;
      else
         NEW_SL=lowest;
     }

   if(is_same_symbol(TREND, TREND_SEL))
     {
      if(MathAbs(higest-LM) < amp_trade)
         NEW_SL=LM+amp_trade;
      else
         NEW_SL=higest;
     }

   SetGlobalVariable(GLOBAL_VAR_SL+symbol, NEW_SL);
   return NEW_SL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Position(string symbol,string TREND_TYPE,double volume,double sl,double priceLimit,double tp,string comment,string strRR)
  {
   int count_trade=0;
   string last_comment="";

   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(),symbol))
           {
            count_trade+=1;
            last_comment=m_position.Comment();
           }

//for(int i=OrdersTotal()-1; i>=0; i--)
//   if(m_order.SelectByIndex(i))
//      if(is_same_symbol(m_order.Symbol(),symbol))
//        {
//         count_trade+=1;
//         last_comment=m_order.Comment();
//        }

   if(count_trade>0)
     {
      Alert("Really Trade: "+ symbol + "    "+last_comment);
      return false;
     }

   int demm=1;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   while(demm<5)
     {
      double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
      double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
      int slippage=(int)MathAbs(ask-bid);
      double price=NormalizeDouble((bid+ask)/2,digits);

      bool result=false;
      if(is_same_symbol(TREND_TYPE,TREND_BUY))
         result = m_trade.Buy(volume,symbol,0.0,sl,tp,comment);

      if(is_same_symbol(TREND_TYPE,TREND_SEL))
         result = m_trade.Sell(volume,symbol,0.0,sl,tp,comment);

      if(is_same_symbol(TREND_TYPE,TREND_LIMIT_BUY) && priceLimit > 0)
         result = m_trade.BuyLimit(volume,priceLimit,symbol,sl,tp,0,0,comment);

      if(is_same_symbol(TREND_TYPE,TREND_LIMIT_SEL) && priceLimit > 0)
         result = m_trade.SellLimit(volume,priceLimit,symbol,sl,tp,0,0,comment);

      if(result)
         return true;

      demm++;
      Sleep100(); //milliseconds
     }

   return false;
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
   int sub_windows=0,
   const int font_size=8
)
  {
   if(ALLOW_DRAW_BUTONS==false)
      return;

   ObjectDelete(0,name);
   if(time_to==0)
      time_to=TimeCurrent()+TIME_OF_ONE_H4_CANDLE;                   // anchor point time
   TextCreate(0,name,sub_windows,time_to,price,label,clrColor);
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
void OpenChartWindow(string buttonLabel,ENUM_TIMEFRAMES TIMEFRAME)
  {
   bool is_cur_tab = is_same_symbol(buttonLabel,Symbol());

   if(is_cur_tab && TIMEFRAME==Period())
      return;

   long chartID = 0;
   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string cur_symbol = getSymbolAtIndex(index);

      if(is_same_symbol(buttonLabel,cur_symbol))
        {
         chartID=ChartFirst();
         while(chartID >= 0)
           {
            ChartClose(chartID);
            chartID = ChartNext(chartID);
           }

         ChartOpen(cur_symbol,TIMEFRAME);
        }
     }
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

   if(PERIOD_XX==PERIOD_M30)
      return "M30";

   if(PERIOD_XX== PERIOD_H1)
      return "H1";

   if(PERIOD_XX== PERIOD_H4)
      return "H4";

   if(PERIOD_XX== PERIOD_D1)
      return "D1";

   if(PERIOD_XX== PERIOD_W1)
      return "W1";

   if(PERIOD_XX== PERIOD_MN1)
      return "Mo";

   return "??";
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
string get_vntime()
  {
   string cpu="";
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
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string str_date_time = TimeToString(vietnamTime,TIME_MINUTES);
   string vntime = "("+str_date_time+")";
   return vntime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_morning_checking_time()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);

   if(dt.hour == 7 && dt.min >= 0 && dt.min <= 20)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_cur_hour_vn()
  {
   MqlDateTime mql_time;
   datetime vietnamTime = TimeGMT()+7*3600;
   TimeToStruct(vietnamTime,mql_time);

   return mql_time.hour;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTpEntry(string symbol, string TRADING_TREND, bool allow_close=true)
  {
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double slipage=MathAbs(ask-bid);

   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(),symbol))
           {
            string TREND_TYPE = m_position.TypeDescription();

            if(is_same_symbol(TRADING_TREND,TREND_TYPE)==false)
               continue;

            double temp_profit = m_position.Profit()+m_position.Swap()+m_position.Commission();
            if(allow_close && temp_profit>0.5)
              {
               m_trade.PositionClose(m_position.Ticket());
               continue;
              }

            int demm=1;
            while(demm<5)
              {
               string PriceOpen = DoubleToString(NormalizeDouble(m_position.PriceOpen(), digits-1),digits-1);
               string TakeProfit= DoubleToString(NormalizeDouble(m_position.TakeProfit(),digits-1),digits-1);
               //printf("ModifyTp Entry "+(string)demm);
               if(PriceOpen != TakeProfit)
                 {
                  //printf("PriceOpen != TakeProfit");
                  bool is_same_price=(m_position.PriceOpen()-slipage*5<m_position.TakeProfit()) &&
                                     (m_position.TakeProfit()<m_position.PriceOpen()+slipage*5);

                  if(is_same_price==false)
                    {
                     //printf("is_same_price==false");
                     double tp_to_entry=m_position.PriceOpen();
                     if(is_same_symbol(TREND_TYPE,TREND_BUY))
                        tp_to_entry+=slipage*2;
                     if(is_same_symbol(TREND_TYPE,TREND_SEL))
                        tp_to_entry-=slipage*2;

                     bool successful= m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),tp_to_entry);
                     if(successful)
                       {
                        //Alert("ModifyTp Entry "+symbol);
                        string msg="(ModifyTpEntry) "+symbol;
                        PushMessage(msg,FILE_MSG_LIST_SL);

                        break;
                       }
                    }
                 }
               demm+=1;
               Sleep100();
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBetterSL(double new_sl, double current_sl, string trend)
  {
   if(is_same_symbol(trend,TREND_BUY))
      return NormalizeDouble(new_sl,5) > NormalizeDouble(current_sl,5);

   if(is_same_symbol(trend,TREND_SEL))
      return NormalizeDouble(new_sl,5) < NormalizeDouble(current_sl,5);

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifySL(string symbol,string TREND,double new_sl)
  {
   printf("ModifyTp: "+symbol);
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(),symbol) &&
            is_same_symbol(m_position.TypeDescription(),TREND))
           {
            int demm=1;
            while(demm<5)
              {
               // Kiểm tra điều kiện cải thiện SL
               double current_sl = m_position.StopLoss();
               if(!IsBetterSL(new_sl, current_sl, TREND))
                 {
                  Alert("Lệnh bị từ chối: Không được phép dịch SL theo hướng bất lợi."
                        , m_position.TypeDescription()," new_sl: ", NormalizeDouble(new_sl,5), " >= cur_sl: ", NormalizeDouble(current_sl,5));
                  break;
                 }

               bool successful=m_trade.PositionModify(m_position.Ticket(),new_sl,m_position.TakeProfit());
               //if(successful)
               break;

               demm+=1;
               Sleep100();
              }
           }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp(string symbol,string TREND,double tp_price)
  {
   printf("ModifyTp: "+symbol);
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         if(
            is_same_symbol(m_position.Symbol(),symbol) &&
            (is_same_symbol(m_position.Comment(),TREND) || is_same_symbol(m_position.TypeDescription(),TREND))
         )
           {
            bool is_same_tp=tp_price==m_position.TakeProfit();
            if(is_same_tp==false)
               is_same_tp=format_double_to_string(tp_price,digits-1)==format_double_to_string(m_position.TakeProfit(),digits-1) ;

            if(is_same_tp==false)
              {
               int demm=1;
               while(demm<5)
                 {
                  bool successful=m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),tp_price);
                  if(successful)
                     break;

                  demm+=1;
                  Sleep100();
                 }
              }
           }

//for(int i=OrdersTotal()-1; i>=0; i--)
//   if(m_order.SelectByIndex(i))
//      if(
//         is_same_symbol(m_order.Symbol(),symbol) &&
//         (is_same_symbol(m_order.Comment(),TREND) || is_same_symbol(m_order.TypeDescription(),TREND)))
//        {
//         bool is_same_tp=tp_price==m_order.TakeProfit();
//         if(is_same_tp==false)
//            is_same_tp=format_double_to_string(tp_price,digits-1)==format_double_to_string(m_order.TakeProfit(),digits-1) ;
//
//         if(is_same_tp==false)
//           {
//            int demm=1;
//            while(demm<5)
//              {
//               bool successful=m_trade.OrderModify(m_order.Ticket(),m_order.PriceOpen(),m_order.StopLoss(),tp_price,ORDER_TIME_DAY,0);
//               if(successful)
//                  break;
//
//               demm+=1;
//               Sleep100();
//              }
//           }
//        }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositionByTrend(string symbol,string TREND)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         if(//is_same_symbol(m_position.Comment(),BOT_SHORT_NM) &&
            is_same_symbol(m_position.Symbol(),symbol))
            if(is_same_symbol(m_position.TypeDescription(),TREND))
              {
               int demm=1;
               while(demm<5)
                 {
                  bool successful=m_trade.PositionClose(m_position.Ticket());
                  if(successful)
                     break;

                  demm++;
                  Sleep100();
                 }
              }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CloseLargestLosingPosition(string symbol)
  {
   double max_loss = 0.0;
   ulong worst_ticket = 0;

// Duyệt qua tất cả các vị thế mở
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(is_same_symbol(PositionGetSymbol(i), symbol)==false)
         continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double profit = PositionGetDouble(POSITION_PROFIT);

      // Tìm vị thế có số lỗ lớn nhất
      if(profit < max_loss)
        {
         max_loss = profit;
         worst_ticket = ticket;
        }
     }

// Nếu không tìm thấy vị thế thua lỗ thì thoát
   if(worst_ticket == 0)
     {
      Print("Không có vị thế thua lỗ nào để đóng cho ", symbol);
      return max_loss;
     }

// Đóng vị thế có số lỗ lớn nhất
   if(m_trade.PositionClose(worst_ticket))
      PrintFormat("Đã đóng vị thế thua lỗ nhất của %s với Ticket: %d, Lỗ: %.2f",
                  symbol, worst_ticket, max_loss);
   else
      PrintFormat("Lỗi khi đóng vị thế %s với Ticket: %d", symbol, worst_ticket);

   return max_loss;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sleep100()
  {
   if(IS_DEBUG_MODE)
      return;

   Sleep(100);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseLimitOrder(string symbol,string TRADING_TREND)
  {
   for(int i = OrdersTotal()-1; i >= 0; i--)
      if(m_order.SelectByIndex(i))
         if(is_same_symbol(m_order.Symbol(),symbol) &&
            is_same_symbol(m_order.TypeDescription(),TRADING_TREND))
           {
            int demm = 1;
            while(demm<5)
              {
               bool successful=m_trade.OrderDelete(m_order.Ticket());
               if(successful)
                  break;

               demm+=1;
               Sleep100();
              }
           }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositivePosition(string symbol,string TREND)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         if(//is_same_symbol(m_position.Comment(),BOT_SHORT_NM) &&
            is_same_symbol(m_position.TypeDescription(),TREND) &&
            is_same_symbol(m_position.Symbol(),symbol) && (m_position.Profit()>0))
           {
            int demm=1;
            while(demm<5)
              {
               bool successful=m_trade.PositionClose(m_position.Ticket());
               if(successful)
                  break;

               demm++;
               Sleep100();
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOccurrences(string textComment,string pattern)
  {
   int count = 0;
   int pos = StringFind(textComment,pattern,0);

   while(pos != -1)
     {
      count++;
      pos = StringFind(textComment,pattern,pos+StringLen(pattern));
     }

   return count;
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
   int btn_width = 280;
   int chart_width = (int)MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));

   int startX=400;
   int COL_0=chart_width-btn_width-10;
   int COL_1=startX+(btn_width+15)*1+100;
   int COL_2=startX+(btn_width+15)*2+100;
   int COL_3=startX+(btn_width+15)*3+100;
   int COL_4=startX+(btn_width+15)*4+100;
   int ROW_1= 60;
   int ROW_2=500;
   int ROW_3=700;

   string BtnClearMessage=BtnClearMessageR1C1;
   string FILE_NAME_MSG_LIST=FILE_MSG_LIST_R1C1;
   int y_position=ROW_1;
   int x_position=COL_1; //+260
   string prifix="R1C1";
   color clrBgColor = clrWhite;

   if(BtnSeq___==BtnMsgR1C2_)
     {
      BtnClearMessage=BtnClearMessageR1C2;
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_R1C2;
      y_position=ROW_1;
      x_position=COL_2;
      prifix="R1C2";
      clrBgColor = clrYellow;
     }

   if(BtnSeq___==BtnMsgR1C3_)
     {
      BtnClearMessage=BtnClearMessageR1C3;
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_R1C3;
      x_position=COL_1;
      x_position=COL_3;
      prifix="R1C3";
     }
//--------------------------------------------------------
   if(BtnSeq___==BtnMsgR2C1_)
     {
      BtnClearMessage=BtnClearMessageR2C1;
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_R2C1;
      y_position=ROW_2;
      x_position=COL_1;
      prifix="R2C1";
     }

   if(BtnSeq___==BtnMsgR2C2_)
     {
      BtnClearMessage=BtnClearMessageR2C2;
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_WAIT;
      y_position=ROW_2;
      x_position=COL_2;
      prifix="Wait";
      btn_width = 300;
     }
//--------------------------------------------------------
   if(BtnSeq___==BtnMsgREVR_)
     {
      BtnClearMessage=BtnClearMessageREVR;
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_REVR;
      y_position=ROW_3;
      x_position=COL_1;
      prifix="Revr";
     }

   if(BtnSeq___==BtnMsgSTOP_)
     {
      BtnClearMessage=BtnClearMessageSTOP;
      FILE_NAME_MSG_LIST=FILE_MSG_LIST_SL;
      y_position=ROW_3;
      x_position=COL_2;
      prifix="SL_TP";
      clrBgColor = clrWhite;
     }
//--------------------------------------------------------
   ObjectDelete(0,BtnClearMessage);
   for(int index = 0; index < MAX_MESSAGES; index++)
      ObjectDelete(0,BtnSeq___+append1Zero(index));

   string fileContent = ReadFileContent(FILE_NAME_MSG_LIST);

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

   if(ArraySize(messageArray) > 0)
      createButton(BtnClearMessage,"x "+prifix,x_position,y_position-20,50,18,clrBlack,clrYellow,7);

   string total_comments="";
   int size = getArraySymbolsSize();
   for(int index = 0; index < ArraySize(messageArray); index++)
     {
      string lable=messageArray[index];
      string symbol=get_symbol_from_label(lable);
      bool is_cur_tab = is_same_symbol(symbol,Symbol());

      string strCountBSL="";
      if(BtnSeq___!=BtnMsgSTOP_)
         strCountBSL=CountBSL(symbol,total_comments);


      color clrBackground=is_same_symbol(lable,"$")? clrLightGray:is_same_symbol(lable,TREND_BUY)?clrActiveBtn:is_same_symbol(lable,TREND_SEL)?clrActiveSell:clrWhite;
      clrBackground=is_same_symbol(strCountBSL,"$") || is_same_symbol(strCountBSL,"oB") || is_same_symbol(strCountBSL,"oS")? clrLightGray:clrBackground;
      if(BtnSeq___==BtnMsgSTOP_)
         clrBackground = clrBgColor;
      if(BtnSeq___==BtnMsgREVR_)
         clrBackground = clrWhite;

      color clrText=clrBlack;
      if(is_same_symbol(strCountBSL,"$"))
        {
         if(is_same_symbol(strCountBSL,"+"))
            clrText=clrBlue;
         if(is_same_symbol(strCountBSL,"-"))
            clrText=clrRed;
        }

      string btnName = BtnSeq___+append1Zero(index)+"_"+prifix+"_"+symbol;
      createButton(btnName,strCountBSL+lable,x_position,y_position+index*20,btn_width,18,clrText,clrBackground,6);

      if(is_cur_tab)
         createButton(btnName+">","",x_position+3,y_position+index*20+3,10,12,clrBlack,clrPurple);
      //   ObjectSetInteger(0,btnName,OBJPROP_FONTSIZE,8);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTempProfit(string symbol)
  {
   double profit_buy=0,profit_sel=0,positive_profit_buy=0,positive_profit_sel=0;
   int count_buy = 0,count_sel = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(symbol=="" || is_same_symbol(symbol,m_position.Symbol()))
           {
            double temp_profit = m_position.Profit()+m_position.Swap()+m_position.Commission();

            if(is_same_symbol(m_position.TypeDescription(),TREND_BUY))
              {
               count_buy += 1;
               profit_buy+=temp_profit;
               if(temp_profit>0)
                  positive_profit_buy+=temp_profit;
              }

            if(is_same_symbol(m_position.TypeDescription(),TREND_SEL))
              {
               count_sel += 1;
               profit_sel+=temp_profit;
               if(temp_profit>0)
                  positive_profit_sel+=temp_profit;
              }
           }

   string result_b="";
   if(count_buy>0)
      result_b= "B:"+DoubleToString(positive_profit_buy,0)+"$/"+DoubleToString(profit_buy,0)+"$";

   string result_s="";
   if(count_sel>0)
      result_s= "S:"+DoubleToString(positive_profit_sel,0)+"$/"+DoubleToString(profit_sel,0)+"$";

   string result=DoubleToString(positive_profit_buy+positive_profit_sel,0)+"$"+to_percent(positive_profit_buy+positive_profit_sel,2)
                 + (result_b!=""?"  ":"") + result_b
                 + (result_s!=""?"  ":"") + result_s;

   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CountBSL(string symbol,string &total_comments, bool show_volume=false)
  {
   total_comments="";
   bool is_cur_tab = is_same_symbol(symbol,Symbol());
   double profit_buy=0,profit_sel=0;
   int count_buy = 0,count_sel = 0,count_limit_buy = 0,count_limit_sel = 0;
   datetime draw_time=TimeCurrent()+TIME_OF_ONE_H1_CANDLE;
   if(Period()==PERIOD_H1)
      draw_time+=TIME_OF_ONE_H1_CANDLE*2;
   if(Period()==PERIOD_H4)
      draw_time+=TIME_OF_ONE_H4_CANDLE*2;
   if(Period()==PERIOD_D1)
      draw_time+=TIME_OF_ONE_D1_CANDLE*2;

   double risk_danger=Risk_1L()/2;
   double vol=0;
   bool is_danger=false;
   string trend_by_ma20_h4=get_trend_by_ma(symbol,PERIOD_H4,20,1);
   string trend_by_ma50_h4=get_trend_by_ma(symbol,PERIOD_H4,50,1);

   for(int i = PositionsTotal()-1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(),symbol)) // && is_same_symbol(m_position.Comment(),BOT_SHORT_NM)
           {
            double temp_profit = m_position.Profit()+m_position.Swap()+m_position.Commission();
            total_comments+= m_position.Comment();
            vol+=m_position.Volume();
            if(temp_profit+risk_danger<0)
               is_danger=true;

            string trend_reverse = get_trend_reverse(m_position.TypeDescription());
            if(is_same_symbol(trend_reverse, trend_by_ma20_h4) && is_same_symbol(trend_reverse, trend_by_ma50_h4))
               is_danger=true;

            if(is_cur_tab)
              {
               int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
               double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
               double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
               double loss=calcPotentialTradeProfit(symbol,m_position.TypeDescription(),m_position.PriceOpen(),SL,m_position.Volume());

               //string text="SL(Here): "+DoubleToString(loss,2)+"$"; //+" (" + DoubleToString(MathAbs(SL-LM),digits)+")"
               //ObjectSetString(0,BtnSetSLHere,OBJPROP_TEXT,text);

               string lblProfit = "Profit"+(string)m_position.Ticket();
               string label = ".............................."
                              +(is_same_symbol(m_position.TypeDescription(),TREND_BUY)?"Buy":"Sell")
                              +" "+(temp_profit>0?"+":"")+DoubleToString(temp_profit,1)+" $";
               create_label_simple(lblProfit,label,iLow(symbol,PERIOD_W1,0),temp_profit<0?clrRed:clrBlue,m_position.Time(),0,9);
               ObjectSetDouble(0,lblProfit,OBJPROP_ANGLE,-90);
               ObjectSetInteger(0,lblProfit,OBJPROP_ANCHOR,ANCHOR_CENTER);

               if(MathAbs(temp_profit)>0)
                 {
                  double bid = SymbolInfoDouble(symbol,SYMBOL_BID);

                  double price_rr11 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_11,OBJPROP_PRICE),digits);
                  double price_rr12 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_12,OBJPROP_PRICE),digits);
                  double price_rr13 = NormalizeDouble(ObjectGetDouble(0,LINE_RR_13,OBJPROP_PRICE),digits);

                  double tp1=calcPotentialTradeProfit(symbol,m_position.TypeDescription(),m_position.PriceOpen(),price_rr11,m_position.Volume());
                  double tp2=calcPotentialTradeProfit(symbol,m_position.TypeDescription(),m_position.PriceOpen(),price_rr12,m_position.Volume());
                  double tp3=calcPotentialTradeProfit(symbol,m_position.TypeDescription(),m_position.PriceOpen(),price_rr13,m_position.Volume());

                  if(is_same_symbol(symbol,"XAUUSD"))
                    {
                     string xau1 = "" + DoubleToString(price_rr11*108/3230,2) + " tr";
                     string xau2 = "" + DoubleToString(price_rr12*108/3230,2) + " tr";
                     string xau3 = "" + DoubleToString(price_rr13*108/3230,2) + " tr";
                     ObjectSetString(0,BtnSetTPHereR1,OBJPROP_TEXT,"(TP1) "+xau1);
                     ObjectSetString(0,BtnSetTPHereR2,OBJPROP_TEXT,"(TP2) "+xau2);
                     ObjectSetString(0,BtnSetTPHereR3,OBJPROP_TEXT,"(TP3) "+xau3);
                    }
                  else
                    {
                     ObjectSetString(0,BtnSetTPHereR1,OBJPROP_TEXT,"(TP1) "+DoubleToString(tp1,2)+"$");
                     ObjectSetString(0,BtnSetTPHereR2,OBJPROP_TEXT,"(TP2) "+DoubleToString(tp2,2)+"$");
                     ObjectSetString(0,BtnSetTPHereR3,OBJPROP_TEXT,"(TP3) "+DoubleToString(tp3,2)+"$");
                    }
                 }

               if(m_position.StopLoss()>0)
                 {
                  double loss=calcPotentialTradeProfit(symbol,m_position.TypeDescription(),m_position.PriceOpen(),m_position.StopLoss(),m_position.Volume());
                  create_label_simple("SL"+(string)m_position.Ticket(),"SL: "+DoubleToString(loss,1)+"$",m_position.StopLoss(),loss<0?clrRed:clrBlue,draw_time);
                 }

               if(m_position.TakeProfit()>0)
                 {
                  double loss=calcPotentialTradeProfit(symbol,m_position.TypeDescription(),m_position.PriceOpen(),m_position.TakeProfit(),m_position.Volume());
                  create_label_simple("TP"+(string)m_position.Ticket(),"TP: "+DoubleToString(loss,1)+"$",m_position.TakeProfit(),loss<0?clrRed:clrBlue,draw_time);
                 }
              }

            if(is_same_symbol(m_position.TypeDescription(),TREND_BUY))
              {
               count_buy += 1;
               profit_buy+=temp_profit;
              }

            if(is_same_symbol(m_position.TypeDescription(),TREND_SEL))
              {
               count_sel += 1;
               profit_sel+=temp_profit;
              }
           }

   for(int i = OrdersTotal()-1; i >= 0; i--)
      if(m_order.SelectByIndex(i))
         if(is_same_symbol(m_order.Symbol(),symbol)) // && is_same_symbol(m_order.Comment(),BOT_SHORT_NM)
           {
            total_comments+= m_order.Comment();

            string trend_reverse = get_trend_reverse(m_order.TypeDescription());
            if(is_same_symbol(trend_reverse, trend_by_ma20_h4) && is_same_symbol(trend_reverse, trend_by_ma50_h4))
               is_danger=true;

            if(is_same_symbol(m_order.TypeDescription(),TREND_BUY))
               count_limit_buy += 1;

            if(is_same_symbol(m_order.TypeDescription(),TREND_SEL))
               count_limit_sel += 1;

            if(is_cur_tab)
              {
               string lblName="Profit_"+(string)m_order.Ticket();
               create_label_simple(lblName,"(LM)    "+m_order.Comment(),m_order.PriceOpen(),clrBlack,draw_time);
               //ObjectSetDouble(0,lblName,OBJPROP_ANGLE,90);
               //ObjectSetInteger(0,lblName,OBJPROP_ANCHOR,ANCHOR_CENTER);

               if(m_order.StopLoss()>0)
                 {
                  double loss=calcPotentialTradeProfit(symbol,m_order.TypeDescription(),m_order.PriceOpen(),m_order.StopLoss(),m_order.VolumeCurrent());
                  create_label_simple("SL"+(string)m_order.Ticket(),MASK_LIMIT+" SL: "+DoubleToString(loss,1)+"$",m_order.StopLoss(),clrRed,draw_time);
                 }

               if(m_order.TakeProfit()>0)
                 {
                  double loss=calcPotentialTradeProfit(symbol,m_order.TypeDescription(),m_order.PriceOpen(),m_order.TakeProfit(),m_order.VolumeCurrent());
                  create_label_simple("TP"+(string)m_order.Ticket(),MASK_LIMIT+" TP: "+DoubleToString(loss,1)+"$",m_order.TakeProfit(),clrBlue,draw_time);
                 }
              }
           }

   string strBSL="";
   strBSL+=(count_buy>0)?"B"+(string)count_buy+""+(profit_buy>0?"+":"")+DoubleToString(profit_buy,1)+"$":"";
   strBSL+=(count_limit_buy>0)?" oB"+(string)count_limit_buy+"L":"";

   strBSL+=(count_sel>0)?"S"+(string)count_sel+""+(profit_sel>0?"+":"")+DoubleToString(profit_sel,1)+"$":"";
   strBSL+=(count_limit_sel>0)?" oS"+(string)count_limit_sel+"L":"";

   if(show_volume && vol>0)
      strBSL+=" "+DoubleToString(vol,2);

   StringReplace(strBSL,"  "," ");
   StringReplace(strBSL,"  "," ");
   StringReplace(strBSL,"  "," ");
   if(is_same_symbol(strBSL,"B") || is_same_symbol(strBSL,"S"))
      strBSL+=" ";
   else
      strBSL="";

   return strBSL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TRIPLE_LIMIT_ORDER(string symbol,string TREND_TYPE,double risk,string mask_count_triple,double price_limit)
  {
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);
   double AMP_X3L = amp_w1;

   double vol_1L = calc_volume_by_amp(symbol,AMP_X3L,MathAbs(risk));

   double amp_tp = NormalizeDouble(AMP_X3L*2/3,digits);

   double TP_1 = is_same_symbol(TREND_TYPE,TREND_BUY) ||is_same_symbol(TREND_TYPE,TREND_LIMIT_BUY)?price_limit+amp_tp
                 :is_same_symbol(TREND_TYPE,TREND_SEL)||is_same_symbol(TREND_TYPE,TREND_LIMIT_SEL)?price_limit-amp_tp
                 :0;
   double TP_2 = is_same_symbol(TREND_TYPE,TREND_BUY) ||is_same_symbol(TREND_TYPE,TREND_LIMIT_BUY)?price_limit+amp_tp
                 :is_same_symbol(TREND_TYPE,TREND_SEL)||is_same_symbol(TREND_TYPE,TREND_LIMIT_SEL)?price_limit-amp_tp
                 :0;
   double TP_3 = 0;

   if(TREND_TYPE != "")
     {
      string comment_1 = mask_count_triple+create_comment("","",1,"");
      string comment_2 = mask_count_triple+create_comment("","",2,"");
      string comment_3 = mask_count_triple+create_comment("","",3,"");

      Open_Position(symbol,TREND_TYPE,vol_1L,0.0,price_limit,NormalizeDouble(TP_3,digits),comment_3,comment_3);

      Open_Position(symbol,TREND_TYPE,vol_1L,0.0,price_limit,NormalizeDouble(TP_2,digits),comment_2,comment_2);

      Open_Position(symbol,TREND_TYPE,vol_1L,0.0,price_limit,NormalizeDouble(TP_1,digits),comment_1,comment_1);

      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTelegramMessage(string symbol,string trend,string message)
  {
   double price=SymbolInfoDouble(symbol,SYMBOL_BID);
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   string str_cur_price=" price:"+DoubleToString(price,digits-1);

   Alert(get_vntime(),message+str_cur_price);

   string account = AccountInfoString(ACCOUNT_NAME);
   if(is_same_symbol(account, "FTMO")==false)
      return;

   if(is_has_memo_in_file(FILE_NAME_SEND_MSG,symbol,trend))
      return;
   add_memo_to_file(FILE_NAME_SEND_MSG,symbol,trend);

   string botToken="5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
   string chatId_duydk="5099224587";

   int cur_hour=get_cur_hour_vn();
   if(cur_hour<8 || cur_hour>22)
      return;

   if(IS_DEBUG_MODE)
      return;

   string new_message=get_vntime()+message+str_cur_price;

   StringReplace(new_message," ","_");
   StringReplace(new_message,"__","_");
   StringReplace(new_message,"__","_");
   StringReplace(new_message,"__","_");
   StringReplace(new_message,"__","_");
   StringReplace(new_message,"_","%20");
   StringReplace(new_message," ","%20");

   string url=StringFormat("%s/bot%s/sendMessage?chat_id=%s&text=%s",telegram_url,botToken,chatId_duydk,new_message);

   string cookie=NULL,headers;
   char   data[],result[];

   ResetLastError();

   int timeout=60000; // 60 seconds
   int res=WebRequest("GET",url,cookie,NULL,timeout,data,0,result,headers);
   if(res==-1)
      Alert("WebRequest Error:",GetLastError(),",URL: ",url,",Headers: ",headers,"   ",MB_ICONERROR);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_acc_profit_percent()
  {
   double ACC_PROFIT =AccountInfoDouble(ACCOUNT_PROFIT);
   return get_profit_percent(ACC_PROFIT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_profit_percent(double profit)
  {
   double BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);

   string percent=AppendSpaces(format_double_to_string(profit,2),7,false)+"$ ("+AppendSpaces(format_double_to_string(profit/BALANCE * 100,2),5,false)+"%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_has_memo_in_file(string filename,string symbol,string TRADING_TREND_KEY)
  {
   string open_trade_today=ReadFileContent(filename);

   string key=create_key(symbol,TRADING_TREND_KEY);
   if(StringFind(open_trade_today,key)>=0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename,string symbol,string TRADING_TREND_KEY,string note_stoploss="",ulong ticket=0,string note="")
  {
   string open_trade_today=ReadFileContent(filename);
   string key=create_key(symbol,TRADING_TREND_KEY);

   open_trade_today=open_trade_today+key;

   if(note != "")
      open_trade_today+=note;

   open_trade_today+="@NEXT@";

   WriteFileContent(filename,open_trade_today);
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
string create_key(string symbol,string TRADING_TREND_KEY)
  {
   string date_time=time2string(iTime(symbol,PERIOD_H4,0));
   string key=date_time+":PERIOD_H4:"+TRADING_TREND_KEY+":"+symbol +";";
   return key;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_volume_by_fibo_dca(string symbol,int trade_no,double F_I_B_O, double INIT_VOLUME)
  {
   double vol=INIT_VOLUME;

   for(int i=2; i <= trade_no; i++)
      vol=vol*F_I_B_O;

   if(vol<INIT_VOLUME || vol>30)
      return  NormalizeDouble(INIT_VOLUME,2);

   return NormalizeDouble(vol,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int remaining_time_to_dca(datetime last_open_trade_time,int waiting_minus)
  {
   datetime currentTime=TimeCurrent();
   datetime timeGap=currentTime-last_open_trade_time;
   return (int)(waiting_minus-timeGap/60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_by_ma7_10_20_50(string symbol,ENUM_TIMEFRAMES timeframe,string find_trend)
  {
   string trend_m5_ma0710="";
   string trend_m5_ma1020="";
   string trend_m5_ma2050="";
   string trend_m5_C1ma10="";
   string trend_m5_ma50d1="";
   bool is_insign_m5=false;
   get_trend_by_ma_seq71020_steadily(symbol,timeframe,trend_m5_ma0710,trend_m5_ma1020,trend_m5_ma2050,trend_m5_C1ma10,trend_m5_ma50d1,is_insign_m5);

   string trend_reverse=get_trend_reverse(find_trend);

   if(trend_reverse==trend_m5_ma2050)
      if(trend_m5_ma0710==trend_m5_ma1020 && trend_m5_ma1020==trend_m5_ma2050)
         return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_same_symbol(string symbol_og,string symbol_tg)
  {
   if(symbol_og=="" || symbol_og=="")
      return false;

   StringReplace(symbol_og, ".cash","");
   StringReplace(symbol_tg, ".cash","");

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
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
double get_ATR(string symbol,ENUM_TIMEFRAMES PERIOD)
  {
   double ATR[];
   ArrayResize(ATR,10);
   int hATR=iATR(symbol,PERIOD,200);
   CopyBuffer(hATR,0,0,10,ATR);
   return ATR[1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_histogram(string symbol,ENUM_TIMEFRAMES timeframe, int fast_ema=12, int slow_ema=26, int signal=9)
  {
   int m_handle_macd=iMACD(symbol,timeframe,fast_ema,slow_ema,signal,PRICE_CLOSE); //,12,26,9
   if(m_handle_macd==INVALID_HANDLE)
      return "";

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main,true);

   CopyBuffer(m_handle_macd,0,0,2,m_buff_MACD_main);

   double m_macd=m_buff_MACD_main[1];
   if(timeframe>PERIOD_H4)
      m_macd=m_buff_MACD_main[0];

   if(m_macd>0)
      return TREND_BUY ;

   if(m_macd<0)
      return TREND_SEL ;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_count_by_histogram(string &trend, int &count, string symbol, ENUM_TIMEFRAMES timeframe, int fast_ema, int slow_ema, int signal)
  {
   int m_handle_macd = iMACD(symbol, timeframe, fast_ema, slow_ema, signal, PRICE_CLOSE);  // Tạo handle cho MACD
   if(m_handle_macd == INVALID_HANDLE)
     {
      trend = "";  // Nếu không lấy được dữ liệu, trả về chuỗi rỗng
      return;
     }

   int num_bars = 50;  // Số lượng nến để lấy giá trị histogram (có thể thay đổi)
   double m_buff_MACD_main[];  // Mảng lưu trữ các giá trị MACD main (histogram)
   ArraySetAsSeries(m_buff_MACD_main, true);  // Đặt mảng theo kiểu series để truy cập dữ liệu mới nhất dễ dàng

// Sao chép dữ liệu từ MACD buffer vào mảng
   CopyBuffer(m_handle_macd, 0, 0, num_bars, m_buff_MACD_main);

// Khởi tạo trạng thái ban đầu
   bool in_buy_mode = m_buff_MACD_main[0] > 0;  // Nếu giá trị MACD > 0, bắt đầu đếm Buy
   if(in_buy_mode)
      trend=TREND_BUY;

   bool in_sell_mode = m_buff_MACD_main[0]< 0; // Nếu giá trị MACD < 0, bắt đầu đếm Sell
   if(in_sell_mode)
      trend=TREND_SEL;

// Biến để đếm số lần Buy hoặc Sell
   count = 0;  // Đếm số lượng Buy hoặc Sell
// Duyệt qua tất cả các giá trị histogram và đếm số lần Buy hoặc Sell
   for(int i = 0; i < num_bars; i++)
     {
      double m_macd = m_buff_MACD_main[i];  // Lấy giá trị MACD tại nến i

      // Nếu đang ở chế độ Buy và gặp MACD > 0
      if(in_buy_mode && m_macd > 0)
        {
         count++;
        }

      // Nếu đang ở chế độ Sell và gặp MACD < 0
      if(in_sell_mode && m_macd < 0)
        {
         count++;  // Tăng số lần Sell
        }

      // Nếu gặp tín hiệu đối diện, đổi trạng thái và dừng đếm
      if(in_buy_mode && m_macd < 0)   // Nếu gặp tín hiệu Sell sau khi đếm Buy
        {
         break;  // Dừng vòng lặp, không cần đếm nữa
        }
      else
         if(in_sell_mode && m_macd > 0)   // Nếu gặp tín hiệu Buy sau khi đếm Sell
           {
            break;  // Dừng vòng lặp, không cần đếm nữa
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd_and_signal_vs_zero(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   int m_handle_macd=iMACD(symbol,timeframe,12,26,9,PRICE_CLOSE);
   if(m_handle_macd==INVALID_HANDLE)
      return "";

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd,0,0,2,m_buff_MACD_main);
   CopyBuffer(m_handle_macd,1,0,2,m_buff_MACD_signal);

   double m_macd   =m_buff_MACD_main[0];
   double m_signal =m_buff_MACD_signal[0];

   if(m_macd>=0 && m_signal>=0)
      return TREND_BUY ;

   if(m_macd <= 0 && m_signal <= 0)
      return TREND_SEL ;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc2(string symbol,ENUM_TIMEFRAMES timeframe,int inK=13,int inD=8,int inS=5,int candle_no=0)
  {
   int handle_iStochastic=iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH);
   if(handle_iStochastic==INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K,true);
   ArraySetAsSeries(D,true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double _K=K[candle_no];
   double _D=D[candle_no];

   if(_K <= 20 || _D <= 20)
      return TREND_BUY;

   if(_K >= 80 || _D >= 80)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string draw_trend_Stoc(string symbol,ENUM_TIMEFRAMES timeframe,int inK=3,int inD=3,int inS=3,int line_width=3,int SUB_WINDOW = 5)
  {
   int handle_iStochastic=iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH);
   if(handle_iStochastic==INVALID_HANDLE)
      return "";

   int length=5;
   double K[],D[];
   ArraySetAsSeries(K,true);
   ArraySetAsSeries(D,true);
   CopyBuffer(handle_iStochastic,0,0,length,K);
   CopyBuffer(handle_iStochastic,1,0,length,D);

   double _K=K[0];
   double _D=D[0];
   string result = "";
   if(_K <= 21 || _D <= 23)
      result = TREND_BUY;
   if(_K >= 79 || _D >= 77)
      result = TREND_SEL;
   result+=_K>_D?"(b)":"(s)";

   string name = "stoc_"+get_time_frame_name(timeframe);
   color clrColor = is_same_symbol(result,TREND_BUY)?clrBlue:is_same_symbol(result,TREND_SEL)?clrRed:clrBlack;
   string lbl = "<<< "+get_time_frame_name(timeframe)+"("+DoubleToString(_K,0)+", "+DoubleToString(_D,0)+") "+(_K>_D?"(buy)":"(sel)");

   int _sub_windows;
   datetime _time;
   double _price;
   ChartXYToTimePrice(0, 2250, 10, _sub_windows, _time, _price);
   _time=_time>TimeCurrent()?_time:TimeCurrent();

   create_label_simple(name+"_trend",lbl,(_K+_D)/2,clrColor,_time,SUB_WINDOW,8);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool allow_trade_now_by_stoc(string symbol,ENUM_TIMEFRAMES timeframe,string FIND_TREND,int inK=3,int inD=3,int inS=3,int candle_no=0)
  {
   int handle_iStochastic=iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH);
   if(handle_iStochastic==INVALID_HANDLE)
      return false;

   double K[],D[];
   ArraySetAsSeries(K,true);
   ArraySetAsSeries(D,true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double black_K=K[candle_no];
   double red_D=D[candle_no];

   if(black_K<20 && red_D<20 && is_same_symbol(FIND_TREND,TREND_BUY))
      return true;

   if(black_K>80 && red_D>80 && is_same_symbol(FIND_TREND,TREND_SEL))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int periodK, int periodD, int slowing, int candle_no, int &calnde,string &trend)
  {
   calnde=50;
   trend="";
   int handle_iStochastic = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle_iStochastic,0,0,50,K);
   CopyBuffer(handle_iStochastic,1,0,50,D);

   double black_K = K[candle_no];
   double red_D = D[candle_no];

   for(int i = candle_no; i < ArraySize(K) - 1; i++)
     {
      if(K[i] < D[i] && K[i + 1] > D[i + 1])
        {
         calnde = i;
         trend=TREND_SEL;
         break;
        }

      if(K[i] > D[i] && K[i + 1] < D[i + 1])
        {
         calnde = i;
         trend=TREND_BUY;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_candle_switch_trend_macd(string symbol,ENUM_TIMEFRAMES timeframe, int &calnde,string &trend)
  {
   calnde=50;
   trend="";
   int m_handle_macd=iMACD(symbol,timeframe,12,26,9,PRICE_CLOSE);
   if(m_handle_macd==INVALID_HANDLE)
      return;

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main,true);

   CopyBuffer(m_handle_macd,0,0,50,m_buff_MACD_main);

   double m_macd =m_buff_MACD_main[0];
//double m_signal =m_buff_MACD_signal[0];

   int size=ArraySize(m_buff_MACD_main);
   for(int i=1;i<size;i++)
     {
      double macd_i=m_buff_MACD_main[i];
      if(m_macd>0 && macd_i<0)
        {
         calnde = i;
         trend=TREND_BUY;
         break;
        }
      if(m_macd<0 && macd_i>0)
        {
         calnde = i;
         trend=TREND_SEL;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_mmdd_swith_trend(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   int maLength=50;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i=maLength-1; i >= 0; i--)
      closePrices[i]=iClose(symbol,timeframe,i);

   double ma10d1=cal_MA(closePrices,10,1);
   double close_d1=closePrices[1];
   string trend_ma10_d1=(close_d1>ma10d1)?TREND_BUY:TREND_SEL;

   for(int i=1;i<maLength;i++)
     {
      double ma=cal_MA(closePrices,10,i);
      double close_1=closePrices[i];
      string cur_trend=(close_1>ma)?TREND_BUY:TREND_SEL;
      if(cur_trend!=trend_ma10_d1)
        {
         MqlDateTime cur_time;
         TimeToStruct(iTime(symbol,PERIOD_D1,i),cur_time);

         string mmdd=StringFormat("%02d",cur_time.mon) +
                     StringFormat("%02d",cur_time.day);

         return mmdd+"_"+trend_ma10_d1;
        }
     }

   return "MMDD_"+trend_ma10_d1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe,int ma_index,int candle_no=1)
  {
   int maLength=ma_index+5;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i=maLength-1; i>=0; i--)
     {
      closePrices[i]=iClose(symbol,timeframe,i);
     }

   double close_1=closePrices[candle_no];
   double ma=cal_MA(closePrices,ma_index,candle_no);

   if(close_1>ma)
      return TREND_BUY;

   if(close_1<ma)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_filled_rectangle(
   const string            name="Rectangle",        // object name
   datetime                time_from=0,             // anchor point time (bottom-left corner)
   double                  price_from=0,            // anchor point price (bottom-left corner)
   datetime                time_to=0,               // anchor point time (top-right corner)
   double                  price_to=0,              // anchor point price (top-right corner)
   const color             clr_fill=clrGray,        // fill color
   const bool              is_draw_border=false,
   const bool              is_fill_color=true,
   const string            trend_rec="",
   const int               body_border_width=2
)
  {
   string name_new=BOT_SHORT_NM+name;

   ObjectDelete(0,name_new);  // Delete any existing object with the same name
   ObjectCreate(0,name_new,OBJ_RECTANGLE,0,time_from,price_from,time_to,price_to);
   ObjectSetInteger(0,name_new,OBJPROP_COLOR,clr_fill);         // Set border color
   ObjectSetInteger(0,name_new,OBJPROP_STYLE,STYLE_SOLID);      // Set border style to solid
   ObjectSetInteger(0,name_new,OBJPROP_HIDDEN,true);            // Set hidden property
   ObjectSetInteger(0,name_new,OBJPROP_BACK,true);              // Set background property
   ObjectSetInteger(0,name_new,OBJPROP_SELECTABLE,false);       // Set selectable property
   ObjectSetInteger(0,name_new,OBJPROP_STYLE,STYLE_SOLID);      // Set style to solid

   if(is_draw_border)
      //  {
      //   //--- set border type
      //   ObjectSetInteger(0,name_new,OBJPROP_BORDER_TYPE,BORDER_SUNKEN);
      //   //--- set the chart's corner, relative to which point coordinates are defined
      //   ObjectSetInteger(0,name_new,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      //   //--- set flat border line style
      //   ObjectSetInteger(0,name_new,OBJPROP_STYLE,STYLE_SOLID);
      //   //--- set flat border width
      //   ObjectSetInteger(0,name_new,OBJPROP_WIDTH,1);
      //  }
      //else
     {
      ObjectSetInteger(0,name_new,OBJPROP_FILL,true);
      create_trend_line(name_new+"|",time_from,price_from,time_from,price_to,clrBlack,STYLE_SOLID,1);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_heiken_candle(
   const string            name="Rectangle",        // object name
   datetime                time_from=0,             // anchor point time (bottom-left corner)
   datetime                time_mid=0,
   datetime                time_to=0,               // anchor point time (top-right corner)
   double                  open=0,            // anchor point price (bottom-left corner)
   double                  close=0,              // anchor point price (top-right corner)
   double                  low=0,            // anchor point price (bottom-left corner)
   double                  high=0,              // anchor point price (top-right corner)
   const color             clr_fill=clrGray,        // fill color
   bool                    is_fill_body=false,
   int                     boder_width=2,
   int sub_windows=0,
   int count_ = 0,
   color curColor=clrWhite
)
  {
   string name_new=BOT_SHORT_NM+name;

   ObjectDelete(0,name_new);  // Delete any existing object with the same name
   ObjectCreate(0,name_new,OBJ_RECTANGLE,sub_windows,time_from,open,time_to,close);
   ObjectSetInteger(0,name_new,OBJPROP_STYLE,STYLE_SOLID);      // Set border style to solid
   ObjectSetInteger(0,name_new,OBJPROP_HIDDEN,true);            // Set hidden property
   ObjectSetInteger(0,name_new,OBJPROP_BACK,false);              // Set background property
   ObjectSetInteger(0,name_new,OBJPROP_SELECTABLE,false);       // Set selectable property
   ObjectSetInteger(0,name_new,OBJPROP_COLOR,clr_fill);         // Set fill color (this may not work as intended for all objects)
   ObjectSetInteger(0,name_new,OBJPROP_BGCOLOR,clrWhite);
   ObjectSetInteger(0,name_new,OBJPROP_FILL,is_fill_body);
   ObjectSetInteger(0,name_new,OBJPROP_WIDTH,2);      // Setting this to 1 for consistency

   double bread=MathAbs(open-close)/10;
   ObjectCreate(0,name_new+"2",OBJ_RECTANGLE,sub_windows,time_from,low-bread,time_to,high+bread);
   ObjectSetInteger(0,name_new+"2",OBJPROP_BACK,false);
   ObjectSetInteger(0,name_new+"2",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name_new+"2",OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,name_new+"2",OBJPROP_WIDTH,2);

   double mid =(open+close)/2;
//create_trend_line(name_new+"-",time_from,mid,time_to,mid,clr_fill,STYLE_SOLID,2,false,false,false,false);

   create_trend_line(name_new+"|",time_mid,low,time_mid,high,clr_fill,STYLE_SOLID,2,false,false,false,false);

   create_label_simple(name_new+"lbl.ma",IntegerToString(count_),mid,curColor,time_mid);
   ObjectSetInteger(0,name_new+"lbl.ma",OBJPROP_ANCHOR,ANCHOR_CENTER);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_maX_maY(string symbol,ENUM_TIMEFRAMES timeframe,int ma_index_6,int ma_index_9)
  {
   int maLength=MathMax(ma_index_6,ma_index_9)+5;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i=maLength-1; i>=0; i--)
     {
      closePrices[i]=iClose(symbol,timeframe,i);
     }

   double ma_6=cal_MA(closePrices,ma_index_6,1);
   double ma_9=cal_MA(closePrices,ma_index_9,1);

   if(ma_6>ma_9)
      return TREND_BUY;

   if(ma_6<ma_9)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_group_value(string comment,string str_start="[G",string str_end="]")
  {
   int startPos=StringFind(comment,str_start);
   int endPos=StringFind(comment,str_end,startPos);
   string result="";

   if(startPos != -1 && endPos != -1)
      result=StringSubstr(comment,startPos,endPos-startPos+1);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_group_name()
  {
   datetime VnTime=TimeGMT()+7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(VnTime,time_struct);

   return "[G"
          +(string)time_struct.day
          +(string)time_struct.hour
          +(string)time_struct.min
          +"]";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_ticket_key(ulong ticket)
  {
   string key="";

   if(ticket>0)
     {
      key="000"+(string)(ticket);
      int length=StringLen(key);

      string lastThree=StringSubstr(key,length-3,3);

      key="[K"+lastThree+ "]";
     }

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string time2string(datetime time)
  {
   string today=(string)time;
   StringReplace(today," ","");
   StringReplace(today,"000000","");
   StringReplace(today,"0000","");
   StringReplace(today,"00:00:00","");
   StringReplace(today,"00:00","");

   return today;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double dblLotsRisk(string symbol,double dbAmp,double dbRiskByUsd)
  {
   if(is_same_symbol(symbol,"XAU") || is_same_symbol(symbol,"XAG"))
     {
      double EQUITY=AccountInfoDouble(ACCOUNT_EQUITY);
      string account = AccountInfoString(ACCOUNT_NAME);

      if(EQUITY>=108050 && EQUITY<110000)
        {
         return 0.05;
        }

      if(EQUITY>=8000 && EQUITY<11000)
        {
         return 0.01;
        }
     }

   double dbLotsMinimum =SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double dbLotsMaximum =SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double dbLotsStep    =SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double dbTickSize    =SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double dbTickValue   =SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);

   double dbLossOrder   =dbAmp * dbTickValue / dbTickSize;
   double dbLotReal     =(dbRiskByUsd / dbLossOrder / dbLotsStep) * dbLotsStep;
   double dbCalcLot     =(fmin(dbLotsMaximum,fmax(dbLotsMinimum,round(dbLotReal))));
   double roundedLotSize=MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

   if(roundedLotSize<0.01)
      roundedLotSize=0.01;

   return NormalizeDouble(roundedLotSize,2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_volume_by_amp(string symbol,double amp_trade,double risk)
  {
   return dblLotsRisk(symbol,amp_trade,risk);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA_XX(string symbol,ENUM_TIMEFRAMES timeframe,int ma_index,int candle_no=1)
  {
   int maLength=ma_index+5;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i=maLength-1; i>=candle_no; i--)
     {
      closePrices[i]=iClose(symbol,timeframe,i);
     }

   double ma_value=cal_MA(closePrices,ma_index);
   return ma_value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA(double &closePrices[], int ma_index, int candle_no = 0)
  {
   int count = 0;
   double ma = 0.0;
   int size = ArraySize(closePrices);

   for(int i = candle_no; i < candle_no + ma_index; i++)
     {
      if(i < size)
        {
         count++;
         ma += closePrices[i];
        }
     }

   if(count == 0)
      return 0;
   return ma / count;
  }

// Hàm đếm số nến mà MA10 nằm trên hoặc dưới MA20
string CheckSeqMa10205020(string symbol, ENUM_TIMEFRAMES PERIOD_ID, int &count_ma10_vs_ma20)
  {
   count_ma10_vs_ma20=200;
   string trend_result="NotFound";

   int maLength = 200;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
      closePrices[i] = iClose(symbol, PERIOD_ID, i);

   int size = ArraySize(closePrices);
   int limit = size - 50;  // Đảm bảo đủ dữ liệu tính Ma50

   if(limit <= 0)
      return trend_result;

// Xác định hướng kiểm tra dựa trên nến hiện tại (candle 0)
   double ma00_0 = closePrices[1];
   double ma10_0 = cal_MA(closePrices, 10, 0);
   double ma20_0 = cal_MA(closePrices, 20, 0);
   double ma50_0 = cal_MA(closePrices, 50, 0);
   double ma200_0= cal_MA(closePrices,size-10, 0);

   if((ma00_0 > ma10_0) && (ma10_0 > ma20_0)  && (ma20_0 > ma50_0)  && (ma50_0 > ma200_0))
      trend_result=TREND_BUY;

   if((ma00_0 < ma10_0) && (ma10_0 < ma20_0)  && (ma20_0 < ma50_0)  && (ma50_0 < ma200_0))
      trend_result=TREND_SEL;

   if(trend_result=="")
      return trend_result;

   bool isAbove = ma10_0 > ma20_0;
   for(int i = 0; i < limit; i++)
     {
      double ma10 = cal_MA(closePrices, 10, i);
      double ma20 = cal_MA(closePrices, 20, i);

      if(isAbove)
        {
         if(ma10 > ma20)
            count_ma10_vs_ma20++;
         else
            break;
        }

      if(!isAbove)
        {
         if(ma10 < ma20)
            count_ma10_vs_ma20++;
         else
            break;
        }
     }

   return trend_result;
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
string append1Zero(int trade_no)
  {
   if(trade_no<10)
      return "0"+(string) trade_no;

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
string get_current_timeframe_to_string()
  {
   ENUM_TIMEFRAMES TF=Period();
//Alert(TF,"    ",PERIOD_H4);
   if(TF==PERIOD_M1)
      return "M1";

   if(TF==PERIOD_M5)
      return "M5";

   if(TF==PERIOD_M15)
      return "M15";

   if(TF== PERIOD_H1)
      return "H1";

   if(TF== PERIOD_H4)
      return "H4";

   if(TF== PERIOD_H8)
      return "H8";

   if(TF== PERIOD_D1)
      return "D1";

   if(TF== PERIOD_W1)
      return "W1";

   if(TF== PERIOD_MN1)
      return "Mo";

   return "__";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_time_enter_the_market()
  {
   datetime vietnamTime=TimeGMT()+7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime,vietnamDateTime);

   int currentHour=vietnamDateTime.hour;
   if(18 <= currentHour && currentHour <= 20)
      return false;

   const ENUM_DAY_OF_WEEK day_of_week=(ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week==SATURDAY || day_of_week==SUNDAY)
      return false;

   if(day_of_week==FRIDAY && currentHour>22)
      return false;

   if(3 <= currentHour && currentHour <= 5)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_end_of_day_time()
  {
   datetime vietnamTime=TimeGMT()+7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime,vietnamDateTime);

   int currentHour=vietnamDateTime.hour;

   const ENUM_DAY_OF_WEEK day_of_week=(ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;

   if(4 <= currentHour && currentHour<=7)
     {
      //if(day_of_week==WEDNESDAY || day_of_week==FRIDAY)
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_asia_tp_time()
  {
   datetime vietnamTime=TimeGMT()+7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime,vietnamDateTime);

   int currentHour=vietnamDateTime.hour;

   if(16 <= currentHour && currentHour<=17)
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_exit_all_by_weekend()
  {
   datetime vietnamTime=TimeGMT()+7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime,vietnamDateTime);

   int currentHour=vietnamDateTime.hour;

   const ENUM_DAY_OF_WEEK day_of_week=(ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;

   if(day_of_week==FRIDAY && 22 <= currentHour)
      return true;

   if(day_of_week==SATURDAY && currentHour>=0)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_dragable_trendline(string name, color line_color, double price, ENUM_LINE_STYLE STYLE=STYLE_SOLID,int width=3,bool allow_drag=true)
  {
   string name_new=name;

   ObjectDelete(0,name_new);
   if(ObjectFind(0, name_new) != 0)
     {
      ObjectCreate(0, name_new, OBJ_HLINE,0,TimeCurrent()-TIME_OF_ONE_W1_CANDLE,price);
      ObjectSetInteger(0, name_new, OBJPROP_COLOR,line_color);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH,width);
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE);
      ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE, allow_drag);
      ObjectSetInteger(0, name_new, OBJPROP_SELECTED, allow_drag);
      ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, !allow_drag);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_dragable_vertical_line(string name,datetime time, color line_color, ENUM_LINE_STYLE STYLE=STYLE_SOLID)
  {
   int width=1;
   if(is_same_symbol(name,GLOBAL_LINE_TIMER_1))
      width=1;

   ObjectDelete(0,name);

   if(ObjectFind(0, name) != 0)
     {
      ObjectCreate(0, name, OBJ_VLINE,0,time,0);
      ObjectSetInteger(0, name, OBJPROP_COLOR,line_color);
      ObjectSetInteger(0, name, OBJPROP_WIDTH,width);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDragableLine(string line_name, datetime base_time, double top_price, datetime interval,int width=5)
  {
// Xóa đối tượng nếu đã tồn tại
   ObjectDelete(0, line_name);

// Tạo đối tượng đường thẳng
   ObjectCreate(0, line_name, OBJ_TREND, 0,base_time-interval,top_price, base_time, top_price);

// Thiết lập thuộc tính cho đường thẳng
   ObjectSetInteger(0, line_name, OBJPROP_COLOR, clrBlue);       // Màu xanh
   ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_SOLID);   // Kiểu đường liền mạch
   ObjectSetInteger(0, line_name, OBJPROP_WIDTH, width);         // Độ rộng đường
   ObjectSetInteger(0, line_name, OBJPROP_SELECTABLE, true);    // Có thể chọn
   ObjectSetInteger(0, line_name, OBJPROP_SELECTED, true);      // Tự động được chọn
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_SupportResistance_file_name()
  {
   return "TREND_SUP_RESIS_"+get_consistent_symbol(Symbol()) + ".csv";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_fiboline_consistent_file_name()
  {
   return "TREND_FIBO_"+get_consistent_symbol(Symbol()) + ".csv";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trendline_consistent_file_name()
  {
   return "TREND_LINES_"+get_consistent_symbol(Symbol()) + ".csv";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_timeline_consistent_file_name(bool is_weekly=false)
  {
   return "TIME_LINES_"+get_consistent_symbol(Symbol()) + (is_weekly?"":"") + ".csv"; //_WEEK
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_cycles_file_name()
  {
   return "TIME_CYCLES_"+get_consistent_symbol(Symbol()) + ".csv"; //_WEEK
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_consistent_symbol(string symbol)
  {
   string file_name = symbol;

   StringReplace(file_name,".cash","");
   StringReplace(file_name,"XTIUSD","USOIL");
   StringReplace(file_name,"SP500", "US500");
   StringReplace(file_name,"NAS100","US100");
   StringReplace(file_name,"DAX40", "GER40");
   StringReplace(file_name,"JPN225","JP225");

   if(StringSubstr(file_name, StringLen(file_name) - 1, 1) == "c")
      file_name = StringSubstr(file_name, 0, StringLen(file_name) - 1);

   return file_name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddSupportResistance()
  {
   string symbol=Symbol();
   double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
   double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
   double price_offset=MathAbs(SL-LM);

   for(int i=-20;i<=20;i++)
      create_dragable_trendline(MANUAL_SUPPRESIS_+append1Zero(i),clrDimGray,LM+price_offset*i,STYLE_SOLID,1,false);

   string file_name = get_SupportResistance_file_name();
   int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV, ';'); // | FILE_COMMON

   if(file_handle == INVALID_HANDLE)
     {
      Print("Failed to open file for saving: ", file_name, ", Error: ", GetLastError());
      return;
     }

   datetime _time=TimeCurrent();

   int total_objects = ObjectsTotal(0); // Lấy tổng số đối tượng trên chart
   for(int i = 0; i < total_objects; i++)
     {
      string obj_name = ObjectName(0,i); // Lấy tên đối tượng
      if(is_same_symbol(obj_name, MANUAL_SUPPRESIS_))  // Kiểm tra đầu ngữ
        {
         double start_price = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0);

         // Ghi thông tin trendline vào file
         FileWrite(file_handle, obj_name, _time, start_price, _time, start_price);
        }
     }
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadSupportResistance()
  {
   string file_name = get_SupportResistance_file_name();
   int file_handle = FileOpen(file_name, FILE_READ | FILE_CSV, ';');

   if(file_handle == INVALID_HANDLE)
      return;

   while(!FileIsEnding(file_handle))
     {
      string trendline_name;
      string start_time, end_time;
      double start_price, end_price;

      // Đọc dữ liệu từ file
      trendline_name = FileReadString(file_handle);
      start_time = FileReadString(file_handle);
      start_price = FileReadNumber(file_handle);
      end_time = FileReadString(file_handle);
      end_price = FileReadNumber(file_handle);

      if(is_same_symbol(trendline_name, MANUAL_SUPPRESIS_))
        {
         create_dragable_trendline(trendline_name,clrDimGray,start_price,STYLE_SOLID,1,false);
        }
     }

   FileClose(file_handle); // Đóng file sau khi đọc xong
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddFiboline()
  {
   string symbol=Symbol();
   ENUM_TIMEFRAMES TF=Period();

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);
   double price_offset = amp_d1*2;

   double SL=GetGlobalVariable(GLOBAL_VAR_SL+symbol);
   double LM=GetGlobalVariable(GLOBAL_VAR_LM+symbol);
   if(MathAbs(SL-LM)>price_offset)
      price_offset=MathAbs(SL-LM);


   string trend_macd_cur="";
   int macd_lowest_index, macd_highest_index;
   datetime base_time_2 = (datetime)ObjectGetInteger(0, GLOBAL_LINE_TIMER_2, OBJPROP_TIME);
   int candle_index2 = iBarShift(symbol, TF, base_time_2);
   find_index_off_macd_extremes(symbol,TF,candle_index2,0,trend_macd_cur, macd_lowest_index, macd_highest_index,6,12,9);
   double higest_fibo=iHigh(symbol,TF,macd_highest_index);//0;
   double lowest_fibo=iLow(symbol,TF,macd_lowest_index);//DBL_MAX;
   int bar_sta_21=(int)(MathMax(macd_lowest_index,macd_highest_index));
   int bar_end_21=(int)(MathMin(macd_lowest_index,macd_highest_index));
   for(int idx=bar_end_21; idx<=bar_sta_21; idx++)
     {
      double low=iLow(symbol,TF,idx);
      double hig=iHigh(symbol,TF,idx);
      if(lowest_fibo>low)
         lowest_fibo=low;
      if(higest_fibo<hig)
         higest_fibo=hig;
     }

   datetime start_time = 0;
   datetime end_time = 0;
   double start_price = 0.0;
   double end_price = 0.0;

   if(trend_macd_cur == TREND_SEL)
     {
      start_time = iTime(symbol, TF, macd_lowest_index);
      start_price = lowest_fibo;//iLow(symbol, TF, macd_lowest_index);

      end_time = iTime(symbol, TF, macd_highest_index);
      end_price = higest_fibo;//iHigh(symbol, TF, macd_highest_index);
     }

   if(trend_macd_cur == TREND_BUY)
     {
      start_time = iTime(symbol, TF, macd_highest_index);
      start_price = higest_fibo;//iHigh(symbol, TF, macd_highest_index);

      end_time = iTime(symbol, TF, macd_lowest_index);
      end_price = lowest_fibo;//iLow(symbol, TF, macd_lowest_index);
     }


   int width=1;
   color clrColor=clrBlack;
   double levels[] = {0, 0.236, 0.382, 0.5, 0.618, 0.786, 1, 1.273, 1.5, 1.618, 2};
   string name = MANUAL_TRENDFIBO_ + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);

   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_FIBO,0,start_time,start_price,end_time,end_price);

   ObjectSetInteger(0,name,OBJPROP_COLOR,clrColor);              // Màu của Fibonacci
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);              // Kiểu đường kẻ (nét đứt)
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);                     // Độ dày của đường kẻ
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,true);

   int size = ArraySize(levels);
   ObjectSetInteger(0,name,OBJPROP_LEVELS,size);
   for(int i=0; i<size; i++)
     {
      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels[i]);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrColor);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_SOLID);
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,DoubleToString(100*levels[i],1)+"% ");
      ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,width);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadFibolines()
  {
   string file_name = get_fiboline_consistent_file_name();
   int file_handle = FileOpen(file_name, FILE_READ | FILE_CSV, ';');

   if(file_handle == INVALID_HANDLE)
      return;

   while(!FileIsEnding(file_handle))
     {
      string trendline_name;
      string start_time, end_time;
      double start_price, end_price;

      // Đọc dữ liệu từ file
      trendline_name = FileReadString(file_handle);
      start_time = FileReadString(file_handle);
      start_price = FileReadNumber(file_handle);
      end_time = FileReadString(file_handle);
      end_price = FileReadNumber(file_handle);

      if(is_same_symbol((string)start_time,"1970"))
         continue;

      if(is_same_symbol(trendline_name, MANUAL_TRENDFIBO_) && start_time!="")
        {
         int width=1;
         color clrColor=clrBlack;
         double levels[] = {0, 0.236, 0.382, 0.5, 0.618, 0.786, 1, 1.273, 1.5, 1.618, 2};
         string name = trendline_name;

         datetime draw_time1=StringToTime(start_time);
         datetime draw_time2=StringToTime(end_time);

         ObjectDelete(0,name);
         ObjectCreate(0,name,OBJ_FIBO,0,draw_time1,start_price,draw_time2,end_price);

         ObjectSetInteger(0,name,OBJPROP_COLOR,clrColor);              // Màu của Fibonacci
         ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);             // Kiểu đường kẻ (nét đứt)
         ObjectSetInteger(0,name,OBJPROP_WIDTH,1);                     // Độ dày của đường kẻ
         ObjectSetInteger(0,name,OBJPROP_BACK,false);
         ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,false);
         ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
         ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,name,OBJPROP_SELECTED,true);

         int size = ArraySize(levels);
         ObjectSetInteger(0,name,OBJPROP_LEVELS,size);
         for(int i=0; i<size; i++)
           {
            ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels[i]);
            ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrColor);
            ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_DOT);
            ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,DoubleToString(1*MathAbs(levels[i]),3)+"");
            ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,width);
           }

         // Debug: In ra thông tin trendline
         Print("Fiboline: ", trendline_name, " | Start: Time=", start_time, ", Price=", start_price," | End: Time=", end_time, ", Price=", end_price);

        }
     }

   FileClose(file_handle); // Đóng file sau khi đọc xong
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveFibolinesToFile()
  {
   string file_name = get_fiboline_consistent_file_name();
   int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV, ';'); // | FILE_COMMON

   if(file_handle == INVALID_HANDLE)
     {
      Print("Failed to open file for saving: ", file_name, ", Error: ", GetLastError());
      return;
     }

   int total_objects = ObjectsTotal(0); // Lấy tổng số đối tượng trên chart
   for(int i = 0; i < total_objects; i++)
     {
      string obj_name = ObjectName(0,i); // Lấy tên đối tượng
      if(is_same_symbol(obj_name, MANUAL_TRENDFIBO_))  // Kiểm tra đầu ngữ
        {
         // Lấy thời gian và giá trị tại điểm đầu
         datetime start_time = (datetime)ObjectGetInteger(0, obj_name, OBJPROP_TIME, 0); // Điểm đầu tiên
         double start_price = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0);

         // Lấy thời gian và giá trị tại điểm cuối
         datetime end_time = (datetime)ObjectGetInteger(0, obj_name, OBJPROP_TIME, 1); // Điểm thứ hai
         double end_price = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 1);

         // Debug: In ra thông tin trendline
         Print("Fiboline"+append1Zero(i)+": ", obj_name,
               " | Start: Time=", start_time, ", Price=", start_price,
               " | End: Time=", end_time, ", Price=", end_price);

         // Ghi thông tin trendline vào file
         FileWrite(file_handle, obj_name, start_time, start_price, end_time, end_price);
        }
     }
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddHorTrendline()
  {
   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(Symbol(),amp_w1,amp_d1,amp_h4,amp_h1);
   double price_offset = amp_d1;

   datetime start_time = 0;
   datetime end_time = 0;
   double start_price = 0.0;
   double end_price = 0.0;

   int _sub_windows;
   datetime _time;
   double _price;
   int chart_width = (int)MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int)MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));
   int x_1=chart_width/2;
   int y_1=chart_heigh/2;
   if(ChartXYToTimePrice(0, x_1, y_1, _sub_windows, _time, _price))
     {
      start_time = _time;
      start_price = _price;

      if(Period()<PERIOD_H4)
         end_time = start_time + TIME_OF_ONE_W1_CANDLE*1;
      else
         end_time = start_time + TIME_OF_ONE_W1_CANDLE*3;
      end_price = _price;

      string trendline_name = MANUAL_TRENDLINE_ + get_current_timeframe_to_string() + "_" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
      if(ObjectCreate(0, trendline_name, OBJ_TREND, 0, start_time, start_price, end_time, end_price))
        {
         ObjectSetInteger(0, trendline_name, OBJPROP_COLOR, clrBlue);
         ObjectSetInteger(0, trendline_name, OBJPROP_WIDTH, 3);
         ObjectSetInteger(0, trendline_name, OBJPROP_RAY, false);
         ObjectSetInteger(0, trendline_name, OBJPROP_SELECTABLE, true);
         ObjectSetInteger(0, trendline_name, OBJPROP_SELECTED, true);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddTrendline(bool is_add_new=false)
  {
   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(Symbol(),amp_w1,amp_d1,amp_h4,amp_h1);
   double price_offset = amp_d1;

   datetime start_time = 0;
   datetime end_time = 0;
   double start_price = 0.0;
   double end_price = 0.0;

   bool has_trendlines = false;
   if(is_add_new==false)
     {
      string file_name = get_trendline_consistent_file_name();
      int file_handle = FileOpen(file_name, FILE_READ | FILE_CSV, ';');
      has_trendlines = (file_handle != INVALID_HANDLE);

      if(has_trendlines)  // Có dữ liệu trong file
        {
         while(!FileIsEnding(file_handle))
           {
            // Đọc thông tin trendline cuối cùng
            string trendline_name = FileReadString(file_handle);
            string last_start_time_str = FileReadString(file_handle);
            double last_start_price = FileReadNumber(file_handle);
            string last_end_time_str = FileReadString(file_handle);
            double last_end_price = FileReadNumber(file_handle);

            // Cập nhật giá trị trendline mới nhất
            start_time = StringToTime(last_start_time_str);
            end_time = StringToTime(last_end_time_str);
            start_price = last_start_price + price_offset;
            end_price = last_end_price + price_offset;
           }
        }
      FileClose(file_handle);
     }

   if(has_trendlines==false || is_same_symbol((string)start_time,"1970"))
     {
      int _sub_windows;
      datetime _time;
      double _price;
      int chart_width = (int)MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
      int chart_heigh = (int)MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));
      int x_1=chart_width/2;
      int y_1=chart_heigh/2;
      if(ChartXYToTimePrice(0, x_1, y_1, _sub_windows, _time, _price))
        {
         start_time = _time;
         start_price = _price;

         if(Period()<PERIOD_H4)
            end_time = start_time + TIME_OF_ONE_W1_CANDLE*1;
         else
            end_time = start_time + TIME_OF_ONE_W1_CANDLE*3;
         end_price = _price;


         double price_2=_price-amp_d1;
         int x_2, y_2;
         if(ChartTimePriceToXY(0,0,start_time,price_2, x_2, y_2))
           {
            int heigh=MathAbs(y_1-y_2);
            int x_3=x_2+heigh;
            int y_3=y_2;

            if(ChartXYToTimePrice(0, x_3, y_3, _sub_windows, _time, _price))
              {
               end_time = _time;
               end_price = _price;
              }
           }
        }
     }

// Tạo trendline mới
   string trendline_name = MANUAL_TRENDLINE_ + get_current_timeframe_to_string() + "_" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
   if(ObjectCreate(0, trendline_name, OBJ_TREND, 0, start_time, start_price, end_time, end_price))
     {
      ObjectSetInteger(0, trendline_name, OBJPROP_COLOR, clrBlue);
      ObjectSetInteger(0, trendline_name, OBJPROP_WIDTH, 3);
      ObjectSetInteger(0, trendline_name, OBJPROP_RAY, false);
      ObjectSetInteger(0, trendline_name, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, trendline_name, OBJPROP_SELECTED, true);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddSword(string sparam)
  {
   int chart_width = (int)MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int)MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));

   int _sub_windows;
   datetime _time1, _time3;
   double _price1, _price3;
   string trend = TREND_SEL;
   color clrColor=clrRed;
   if(is_same_symbol(sparam,TREND_BUY))
     {
      trend = TREND_BUY;
      clrColor=clrBlue;
      ChartXYToTimePrice(0, chart_width/2,                 chart_heigh*1/3, _sub_windows, _time1, _price1);
      ChartXYToTimePrice(0, chart_width/2+chart_heigh*1/3, chart_heigh*2/3, _sub_windows, _time3, _price3);
     }
   else
     {
      ChartXYToTimePrice(0, chart_width/2,                 chart_heigh*2/3, _sub_windows, _time1, _price1);
      ChartXYToTimePrice(0, chart_width/2+chart_heigh*1/3, chart_heigh*1/3, _sub_windows, _time3, _price3);
     }

   string trendline_name = MANUAL_TRENDLINE_ + get_current_timeframe_to_string() + "_"+trend+ TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
   if(ObjectCreate(0, trendline_name, OBJ_TREND, 0, _time1, _price1, _time3, _price3))
     {
      ObjectSetInteger(0, trendline_name, OBJPROP_COLOR, clrColor);
      ObjectSetInteger(0, trendline_name, OBJPROP_WIDTH, 5);
      ObjectSetInteger(0, trendline_name, OBJPROP_RAY, false);
      ObjectSetInteger(0, trendline_name, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, trendline_name, OBJPROP_SELECTED, true);
      //ObjectSetInteger(0, trendline_name, OBJPROP_RAY_LEFT, true);
      //ObjectSetInteger(0, trendline_name, OBJPROP_RAY_RIGHT, true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadTrendlines()
  {
   string file_name = get_trendline_consistent_file_name();
   int file_handle = FileOpen(file_name, FILE_READ | FILE_CSV, ';');

   if(file_handle == INVALID_HANDLE)
      return;

   while(!FileIsEnding(file_handle))
     {
      string trendline_name;
      string start_time, end_time;
      double start_price, end_price;

      // Đọc dữ liệu từ file
      trendline_name = FileReadString(file_handle);
      start_time = FileReadString(file_handle);
      start_price = FileReadNumber(file_handle);
      end_time = FileReadString(file_handle);
      end_price = FileReadNumber(file_handle);

      if(is_same_symbol((string)start_time,"1970"))
         continue;

      // Tạo trendline trên chart
      if(ObjectCreate(0, trendline_name, OBJ_TREND, 0, StringToTime(start_time), start_price, StringToTime(end_time), end_price))
        {
         if(is_same_symbol(trendline_name,TREND_BUY))
            ObjectSetInteger(0, trendline_name, OBJPROP_COLOR, clrBlue);
         else
            ObjectSetInteger(0, trendline_name, OBJPROP_COLOR, clrRed);

         ObjectSetInteger(0, trendline_name, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, trendline_name, OBJPROP_WIDTH,3);
         ObjectSetInteger(0, trendline_name, OBJPROP_RAY, false);
         ObjectSetInteger(0, trendline_name, OBJPROP_SELECTABLE, true);
         ObjectSetInteger(0, trendline_name, OBJPROP_SELECTED, false);

         //ObjectSetInteger(0, trendline_name, OBJPROP_RAY_LEFT, true);
         //ObjectSetInteger(0, trendline_name, OBJPROP_RAY_RIGHT, true);
        }
     }

   FileClose(file_handle); // Đóng file sau khi đọc xong
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveTrendlinesToFile()
  {
   string file_name = get_trendline_consistent_file_name(); // File lưu trendline cho từng biểu đồ
   int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV, ';'); // | FILE_COMMON

   if(file_handle == INVALID_HANDLE)
     {
      Print("Failed to open file for saving: ", file_name, ", Error: ", GetLastError());
      return;
     }

   int total_objects = ObjectsTotal(0); // Lấy tổng số đối tượng trên chart
   for(int i = 0; i < total_objects; i++)
     {
      string obj_name = ObjectName(0,i); // Lấy tên đối tượng
      if(is_same_symbol(obj_name, MANUAL_TRENDLINE_))  // Kiểm tra đầu ngữ
        {
         // Lấy thời gian và giá trị tại điểm đầu
         datetime start_time = (datetime)ObjectGetInteger(0, obj_name, OBJPROP_TIME, 0); // Điểm đầu tiên
         double start_price = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0);

         // Lấy thời gian và giá trị tại điểm cuối
         datetime end_time = (datetime)ObjectGetInteger(0, obj_name, OBJPROP_TIME, 1); // Điểm thứ hai
         double end_price = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 1);

         // Debug: In ra thông tin trendline
         Print("Trendline"+append1Zero(i)+": ", obj_name,
               " | Start: Time=", start_time, ", Price=", start_price,
               " | End: Time=", end_time, ", Price=", end_price);

         // Ghi thông tin trendline vào file
         FileWrite(file_handle, obj_name, start_time, start_price, end_time, end_price);
        }
     }
   FileClose(file_handle); // Đóng file sau khi lưu xong
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveTimelinesToFile()
  {
   string symbol = get_consistent_symbol(Symbol());
   string file_name = get_timeline_consistent_file_name(false);
   int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV, ';'); // | FILE_COMMON

   if(file_handle == INVALID_HANDLE)
     {
      Print("Failed to open file for saving: ", file_name, ", Error: ", GetLastError());
      return;
     }

   datetime base_time_1 = (datetime)ObjectGetInteger(0, GLOBAL_LINE_TIMER_1, OBJPROP_TIME);
   datetime base_time_2 = (datetime)ObjectGetInteger(0, GLOBAL_LINE_TIMER_2, OBJPROP_TIME);

   if(StringLen((string)base_time_1)<4 || is_same_symbol((string)(datetime)base_time_1,"1970"))
      base_time_1=TimeCurrent()-TIME_OF_ONE_W1_CANDLE;

   if(StringLen((string)base_time_2)<4 || is_same_symbol((string)(datetime)base_time_2,"1970"))
      base_time_2=TimeCurrent()+TIME_OF_ONE_H4_CANDLE;

   string obj_name=GLOBAL_LINE_TIMER_1+symbol;
   datetime start_time = base_time_1;
   double start_price = 0;
   datetime end_time = base_time_2;
   double end_price = 0;

   FileWrite(file_handle, obj_name, start_time, start_price, end_time, end_price);
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveTimeCycles()
  {
   string symbol = get_consistent_symbol(Symbol());
   string file_name = get_cycles_file_name();
   int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV, ';'); // | FILE_COMMON

   if(file_handle == INVALID_HANDLE)
     {
      Print("Failed to open file for saving: ", file_name, ", Error: ", GetLastError());
      return;
     }

   datetime base_time_1 = (datetime)ObjectGetInteger(0, GLOBAL_LINE_TIMER_1, OBJPROP_TIME);
   datetime base_time_2 = (datetime)ObjectGetInteger(0, GLOBAL_LINE_TIMER_2, OBJPROP_TIME);

   string obj_name=GLOBAL_LINE_TIMER_1+symbol;
   datetime start_time = base_time_1;
   double start_price = 0;
   datetime end_time = base_time_2;
   double end_price = 0;

   FileWrite(file_handle, obj_name, start_time, start_price, end_time, end_price);
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadTimelines(datetime &base_time_1, datetime &base_time_2, bool is_weekly, bool isLoadTimeCycles)
  {
   base_time_1 = TimeCurrent()-TIME_OF_ONE_W1_CANDLE;
   base_time_2 = TimeCurrent()+TIME_OF_ONE_H4_CANDLE;

   string symbol = get_consistent_symbol(Symbol());
   string file_name = get_timeline_consistent_file_name(is_weekly);
   if(isLoadTimeCycles)
      file_name = get_cycles_file_name();

   int file_handle = FileOpen(file_name, FILE_READ | FILE_CSV, ';');

   if(file_handle == INVALID_HANDLE)
      return;

   while(!FileIsEnding(file_handle))
     {
      string trendline_name;
      string start_time, end_time;
      double start_price, end_price;

      // Đọc dữ liệu từ file
      trendline_name = FileReadString(file_handle);
      start_time = FileReadString(file_handle);
      start_price = FileReadNumber(file_handle);
      end_time = FileReadString(file_handle);
      end_price = FileReadNumber(file_handle);

      if(is_same_symbol((string)start_time,"1970"))
         continue;

      if(is_same_symbol(trendline_name, GLOBAL_LINE_TIMER_1) && start_time!="")
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string symbol=get_consistent_symbol(getSymbolAtIndex(index));
            if(is_same_symbol(trendline_name,symbol))
              {
               // Debug: In ra thông tin trendline
               //Print("Load Time lines: ", trendline_name, " | Start: Time=", start_time, ", Price=", start_price," | End: Time=", end_time, ", Price=", end_price);
               base_time_1 = StringToTime(start_time);
               base_time_2 = StringToTime(end_time);
              }
           }
        }
     }

   FileClose(file_handle); // Đóng file sau khi đọc xong
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearTrendlinesFromFile()
  {
   string file_name = get_trendline_consistent_file_name(); // File lưu trendline cho từng biểu đồ
   int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV, ';'); // | FILE_COMMON

   if(file_handle == INVALID_HANDLE)
      return;

   FileWrite(file_handle,"");
   FileClose(file_handle);

//-----------------------------------------------------------------------
//return;

   file_name = get_fiboline_consistent_file_name(); // File lưu trendline cho từng biểu đồ
   file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV, ';'); // | FILE_COMMON
   if(file_handle == INVALID_HANDLE)
      return;

   FileWrite(file_handle,"");
   FileClose(file_handle);
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
   if(ALLOW_DRAW_BUTONS==false)
      return;

   string name_new=BOT_SHORT_NM+name;

   ObjectDelete(0,name_new);
   ObjectCreate(0,name_new,OBJ_TREND,sub_window,time_from,price_from,time_to,price_to);
   ObjectSetInteger(0,name_new,OBJPROP_COLOR,      clr_color);
   ObjectSetInteger(0,name_new,OBJPROP_STYLE,      STYLE_XX);
   ObjectSetInteger(0,name_new,OBJPROP_WIDTH,      width);
   ObjectSetInteger(0,name_new,OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0,name_new,OBJPROP_BACK,       is_back);
   ObjectSetInteger(0,name_new,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0,name_new,OBJPROP_RAY_LEFT,   ray_left);
   ObjectSetInteger(0,name_new,OBJPROP_RAY_RIGHT,  ray_right); // Bật tính năng "Rời qua phải"
  }

//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
void create_vertical_line(
   const string          name0="VLine",     // line name
   datetime              time=0,           // line time
   const color           clr=clrBlack,       // line color
   const ENUM_LINE_STYLE style=STYLE_DOT,// line style
   const int             width=1,          // line width
   const bool            back=true,       // in the background
   const bool            selection=false,   // highlight to move
   const bool            ray=true,         // line's continuation down
   const bool            hidden=true,     // hidden in the object list
   const long            z_order=0)         // priority for mouse click
  {
//string name=STR_RE_DRAW+name0;
   string name=name0;
   ObjectDelete(0,name);
   int sub_window=0;      // subwindow index

   if(!time)
      time=TimeGMT();

   ResetLastError();

   string name_new=BOT_SHORT_NM+name;

   if(!ObjectCreate(0,name_new,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,": failed to create a vertical line! Error code=",GetLastError());
     }
   ObjectSetInteger(0,name_new,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name_new,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name_new,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name_new,OBJPROP_BACK,back);
   ObjectSetInteger(0,name_new,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(0,name_new,OBJPROP_SELECTED,selection);
   ObjectSetInteger(0,name_new,OBJPROP_RAY,ray);
   ObjectSetInteger(0,name_new,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(0,name_new,OBJPROP_ZORDER,z_order);
   ObjectSetInteger(0,name_new,OBJPROP_BACK,true);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_ma_seq7102050(string symbol,ENUM_TIMEFRAMES TIMEFRAME)
  {

   int count=0;
   int maLength=55;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i=maLength-1; i>=0; i--)
     {
      count+=1;
      closePrices[i]=iClose(symbol,TIMEFRAME,i);
     }
   if(count<50)
      return "";

   double ma07_0=cal_MA(closePrices, 7,0);
   double ma10_0=cal_MA(closePrices,10,0);
   double ma20_0=cal_MA(closePrices,20,0);
   double ma50_0=cal_MA(closePrices,50,0);

   if((ma07_0>ma10_0) && (ma10_0>ma20_0) && (ma20_0>ma50_0))
      return TREND_BUY;

   if((ma07_0<ma10_0) && (ma10_0<ma20_0) && (ma20_0<ma50_0))
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_ma_seq71020_steadily(string symbol,ENUM_TIMEFRAMES TIMEFRAME,string &trend_ma0710,string &trend_ma1020,string &trend_ma02050,string &trend_C1ma10,string &trend_h4_ma50d1,bool &insign_h4)
  {
   trend_ma0710="";
   trend_ma1020="";
   trend_ma02050="";
   trend_C1ma10="";
   trend_h4_ma50d1="";

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);


   int count=0;
   int maLength=55;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i=maLength-1; i>=0; i--)
     {
      count+=1;
      closePrices[i]=iClose(symbol,TIMEFRAME,i);
     }

   double ma07[5]= {0.0,0.0,0.0,0.0,0.0};
   double ma10[5]= {0.0,0.0,0.0,0.0,0.0};
   double ma20[5]= {0.0,0.0,0.0,0.0,0.0};
   for(int i=0; i<5; i++)
     {
      ma07[i]=cal_MA(closePrices,7,i);
      ma10[i]=cal_MA(closePrices,10,i);
      ma20[i]=cal_MA(closePrices,20,i);
     }
   double ma50_0=cal_MA(closePrices,50,0);
   double ma50_1=cal_MA(closePrices,50,1);
   trend_ma02050=(ma20[1]>ma50_0) && (ma20[0]>ma50_0) ? TREND_BUY : TREND_SEL;

   double price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(ma50_0+amp_d1<price)
      trend_h4_ma50d1=TREND_SEL;
   if(ma50_0-amp_d1>price)
      trend_h4_ma50d1=TREND_BUY;

   double ma_min=MathMin(MathMin(MathMin(ma07[0],ma10[0]),ma20[0]),ma50_0);
   double ma_max=MathMax(MathMax(MathMax(ma07[0],ma10[0]),ma20[0]),ma50_0);
   insign_h4=false;
   if(MathAbs(ma_max-ma_min)<amp_h4*2)
      insign_h4=true;


// Nếu có ít nhất một cặp giá trị không tăng dần,trả về ""
   string seq_buy_07=TREND_BUY;
   string seq_buy_10=TREND_BUY;
   string seq_buy_20=TREND_BUY;
// Nếu có ít nhất một cặp giá trị không giảm dần,trả về ""
   string seq_sel_07=TREND_SEL;
   string seq_sel_10=TREND_SEL;
   string seq_sel_20=TREND_SEL;

   for(int i=0; i<3; i++)
     {
      // BUY
      if(ma07[i]<ma07[i+1])
         seq_buy_07="";
      if(ma10[i]<ma10[i+1])
         seq_buy_10="";
      if(ma20[i]<ma20[i+1])
         seq_buy_20="";

      //SEL
      if(ma07[i]>ma07[i+1])
         seq_sel_07="";
      if(ma10[i]>ma10[i+1])
         seq_sel_10="";
      if(ma20[i]>ma20[i+1])
         seq_sel_20="";
     }
   string trend_ma07_vs10=ma07[0]>ma10[0] ? TREND_BUY : TREND_SEL;
   string trend_ma10_vs20=ma10[0]>ma20[0] ? TREND_BUY : TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10==TREND_BUY && seq_buy_20==TREND_BUY)
      trend_ma1020=TREND_BUY;
   if(seq_buy_10==TREND_BUY && trend_ma10_vs20==TREND_BUY)
      trend_ma1020=TREND_BUY;


   if(seq_sel_10==TREND_SEL && seq_sel_20==TREND_SEL)
      trend_ma1020=TREND_SEL;

   if(seq_sel_10==TREND_SEL && trend_ma10_vs20==TREND_SEL)
      trend_ma1020=TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10==TREND_BUY && seq_buy_07==TREND_BUY)
      trend_ma0710=TREND_BUY;
   if(seq_buy_07==TREND_BUY && trend_ma07_vs10==TREND_BUY)
      trend_ma0710=TREND_BUY;
   if(closePrices[2]>ma07[2] && closePrices[1]>ma07[1] &&
      closePrices[2]>ma10[2] && closePrices[1]>ma10[1])
      trend_ma0710=TREND_BUY;

   if(seq_sel_10==TREND_SEL && seq_sel_07==TREND_SEL)
      trend_ma0710=TREND_SEL;
   if(seq_sel_07==TREND_SEL && trend_ma07_vs10==TREND_SEL)
      trend_ma0710=TREND_SEL;
   if(closePrices[2]<ma07[2] && closePrices[1]<ma07[1] &&
      closePrices[2]<ma10[2] && closePrices[1]<ma10[1])
      trend_ma0710=TREND_SEL;


   if(closePrices[1]>ma10[1])
      trend_C1ma10=TREND_BUY;

   if(closePrices[1]<ma10[1])
      trend_C1ma10=TREND_SEL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_average_candle_height(ENUM_TIMEFRAMES timeframe,string symbol,int length)
  {
   int count=0;
   double totalHeight=0.0;

   for(int i=0; i<length; i++)
     {
      double highPrice=iHigh(symbol,timeframe,i);
      double lowPrice=iLow(symbol,timeframe,i);
      double candleHeight=highPrice-lowPrice;

      count+=1;
      totalHeight+=candleHeight;
     }

   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double averageHeight=NormalizeDouble(totalHeight / count,digits);

   return averageHeight;
  }
//+------------------------------------------------------------------+
string get_trend_reverse(string TREND)
  {
   if(is_same_symbol(TREND,TREND_BUY))
      return TREND_SEL;

   if(is_same_symbol(TREND,TREND_SEL))
      return TREND_BUY;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects(ENUM_OBJECT OBJ_TYPE=OBJ_ARROW)
  {
   int total_objects=ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i=total_objects-1; i>=0; i--)
     {
      string obj_name=ObjectName(0,i);
      int obj_type=(int)ObjectGetInteger(0,obj_name,OBJPROP_TYPE);
      if(obj_type==OBJ_TYPE)
        {
         ObjectDelete(0,obj_name);
        }
     }
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
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_simple2(
   const string            name="Text",
   string                  label="Label",
   double                  price=0,
   color                   clrColor=clrBlack,
   datetime time_to=0,
   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,
   const bool              is_bold=false
)
  {
   ObjectDelete(0,name);
   if(time_to==0)
      time_to=TimeCurrent();                   // anchor point time
   TextCreate(0,name,0,time_to,price," "+label,clrColor);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   if(is_bold)
     {
      ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
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
   string name_new=BOT_SHORT_NM+name;

   if(!ObjectCreate(chart_ID,name_new,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,": failed to create \"Text\" object! Error code=",GetLastError());
      return(false);
     }
   ObjectSetString(0,name_new,OBJPROP_TEXT,text);
   ObjectSetString(0,name_new,OBJPROP_FONT,font);
   ObjectSetInteger(0,name_new,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(0,name_new,OBJPROP_ANGLE,angle);
   ObjectSetInteger(0,name_new,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name_new,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name_new,OBJPROP_BACK,false);
   ObjectSetInteger(0,name_new,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(0,name_new,OBJPROP_SELECTED,selection);
   ObjectSetInteger(0,name_new,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(0,name_new,OBJPROP_ZORDER,z_order);
   ObjectSetString(0,name_new,OBJPROP_TOOLTIP,text);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_pivot(ENUM_TIMEFRAMES TIMEFRAME,string symbol,int size=20)
  {
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double total_amp=0.0;
   for(int index=1; index <= size; index ++)
     {
      total_amp=total_amp+calc_pivot(symbol,TIMEFRAME,index);
     }
   double tf_amp=total_amp / size;

   return NormalizeDouble(tf_amp,digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_pivot(string symbol,ENUM_TIMEFRAMES TIMEFRAME,int tf_index)
  {
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);// number of decimal places

   double tf_hig=iHigh(symbol, TIMEFRAME,tf_index);
   double tf_low=iLow(symbol,  TIMEFRAME,tf_index);
   double tf_clo=iClose(symbol,TIMEFRAME,tf_index);

   double w_pivot   =format_double((tf_hig+tf_low+tf_clo) / 3,digits);
   double tf_s1   =format_double((2 * w_pivot)-tf_hig,digits);
   double tf_s2   =format_double(w_pivot-(tf_hig-tf_low),digits);
   double tf_s3   =format_double(tf_low-2 * (tf_hig-w_pivot),digits);
   double tf_r1   =format_double((2 * w_pivot)-tf_low,digits);
   double tf_r2   =format_double(w_pivot+(tf_hig-tf_low),digits);
   double tf_r3   =format_double(tf_hig+2 * (w_pivot-tf_low),digits);

   double tf_amp=MathAbs(tf_s3-tf_s2)
                 +MathAbs(tf_s2-tf_s1)
                 +MathAbs(tf_s1-w_pivot)
                 +MathAbs(w_pivot-tf_r1)
                 +MathAbs(tf_r1-tf_r2)
                 +MathAbs(tf_r2-tf_r3);

   tf_amp=format_double(tf_amp / 6,digits);

   return NormalizeDouble(tf_amp,digits);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteAvgAmpToFile()
  {
   string arr_symbol[] =
     {
      "XAUUSD"
      //,"XAGUSD","USOIL","BTCUSD",
      //"USTEC","US30","US500","DE30","UK100","FR40","AUS200",
      //"AUDCHF","AUDNZD","AUDUSD",
      //"AUDJPY","CHFJPY","EURJPY","GBPJPY","NZDJPY","USDJPY",
      //"EURAUD","EURCAD","EURCHF","EURGBP","EURNZD","EURUSD",
      //"GBPCHF","GBPNZD","GBPUSD",
      //"NZDCAD","NZDUSD",
      //"USDCAD","USDCHF"
     };

   /*
      (.*)(W1)(.*)(D1)(.*)(H4)(.*)(H1)(.*)
      if(is_same_symbol(symbol,"\1")){amp_w1=\3;amp_d1=\5;amp_h4=\7;amp_h1=\9;return;}
   */

//XAUUSD W1    57.145   D1    21.409   H4    9.345 H1    6.118 M15    4.136   M5    2.763;
//XAUUSD W1    57.145   D1    21.409   H4    8.216 H1    1.132 M15    0.187   M5    0.047;

   string file_name="AvgAmp.txt";
   int fileHandle=FileOpen(file_name,FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size=ArraySize(arr_symbol);
      for(int index=0; index<total_fx_size; index++)
        {
         string symbol=arr_symbol[index];
         string file_contents=symbol
                              +"\t"+"W1: "+(string) calc_average_candle_height(PERIOD_W1,symbol,20)
                              +"\t"+"D1: "+(string) calc_average_candle_height(PERIOD_D1,symbol,60)
                              +"\t"+"H4: "+(string) calc_average_candle_height(PERIOD_H4,symbol,360)
                              +"\t"+"H1: "+(string) calc_average_candle_height(PERIOD_H1,symbol,720)
                              +"\t"+"M15: "+(string) calc_average_candle_height(PERIOD_M15,symbol,720)
                              +"\t"+"M5: "+(string) calc_average_candle_height(PERIOD_M5,symbol,720)
                              +";\n";

         FileWriteString(fileHandle,file_contents);
        }
      FileClose(fileHandle);
     }

//XAUUSD W1    32.289   D1    10.591   H4    4.677 H1    3.061 M15    2.067   M5    1.382;
//XAUUSD W1    28.11    D1    10.591   H4    4.107 H1    0.566 M15    0.093   M5    0.024;

   file_name="AvgPivot.txt";
   fileHandle=FileOpen(file_name,FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size=ArraySize(arr_symbol);
      for(int index=0; index<total_fx_size; index++)
        {
         string symbol=arr_symbol[index];
         string file_contents=symbol
                              +"\t"+"W1: "+(string) calc_avg_pivot(PERIOD_W1,symbol,20)
                              +"\t"+"D1: "+(string) calc_avg_pivot(PERIOD_D1,symbol,60)
                              +"\t"+"H4: "+(string) calc_avg_pivot(PERIOD_H4,symbol,360)
                              +"\t"+"H1: "+(string) calc_avg_pivot(PERIOD_H1,symbol,720)
                              +"\t"+"M15: "+(string) calc_avg_pivot(PERIOD_M15,symbol,720)
                              +"\t"+"M5: "+(string) calc_avg_pivot(PERIOD_M5,symbol,720)
                              +";\n";

         FileWriteString(fileHandle,file_contents);
        }
      FileClose(fileHandle);
     }

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
bool createButton(string name,string text,int x,int y,int width,int height,color clrTextColor=clrBlack,color clrBackground=clrWhite,int font_size=7,int sub_window=0)
  {
   if(ALLOW_DRAW_BUTONS==false)
      return false;

   string name_new=name;//BOT_SHORT_NM+

   long chart_id=0;
   ObjectDelete(chart_id,name_new);
   ResetLastError();
   if(!ObjectCreate(chart_id,name_new,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code=",GetLastError());
      return(false);
     }

   ObjectSetString(chart_id, name_new,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name_new,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_id,name_new,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_id,name_new,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_id,name_new,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_id,name_new,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(chart_id,name_new,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_id,name_new,OBJPROP_COLOR,clrTextColor);
   ObjectSetInteger(chart_id,name_new,OBJPROP_BGCOLOR,clrBackground);
   ObjectSetInteger(chart_id,name_new,OBJPROP_BORDER_COLOR,clrSilver);
   ObjectSetInteger(chart_id,name_new,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name_new,OBJPROP_STATE,false);
   ObjectSetInteger(chart_id,name_new,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_id,name_new,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_id,name_new,OBJPROP_HIDDEN,false);
   ObjectSetInteger(chart_id,name_new,OBJPROP_ZORDER,9999);

   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcPotentialTradeProfit(string symbol,string TREND,double orderOpenPrice,double orderTakeProfitPrice,double orderLots)
  {
   if(orderTakeProfitPrice==0)
      return 0;

   double   tradeTickValuePerLot   =SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);  //Loss/Gain for a 1 tick move with 1 lot
   double   tickValueBasedOnLots   =tradeTickValuePerLot * orderLots;
   double   priceDifference        =MathAbs(orderOpenPrice-orderTakeProfitPrice);
   int      pointsDifference       =(int)(priceDifference / Point());
   double   potentialProfit        =tickValueBasedOnLots * pointsDifference;

   if(TREND==TREND_BUY)
      potentialProfit        =orderTakeProfitPrice>orderOpenPrice ? potentialProfit : -potentialProfit;

   if(TREND==TREND_SEL)
      potentialProfit        =orderTakeProfitPrice>orderOpenPrice ? -potentialProfit : potentialProfit;

   return NormalizeDouble(potentialProfit,2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_name()
  {
   return BOT_SHORT_NM;

   string trader_name=BOT_SHORT_NM+"{^"+(string)(0)+"^}_";
   return trader_name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_manually(string TREND)
  {
   string name=TREND==TREND_BUY ? "B" : "S";
   string trader_name=BOT_SHORT_NM+"{^"+name+"^}_";
   return trader_name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_candlestick(string symbol,ENUM_TIMEFRAMES TIME_FRAME,CandleData &candleArray[],int length=15)
  {
   ArrayResize(candleArray,length+5);
   for(int index=length+3; index>=0; index--)
     {
      datetime          time =iTime(symbol,TIME_FRAME,index);    // Thời gian
      double            open =iOpen(symbol,TIME_FRAME,index);    // Giá mở
      double            high =iHigh(symbol,TIME_FRAME,index);    // Giá cao
      double            low  =iLow(symbol,TIME_FRAME,index);      // Giá thấp
      double            close=iClose(symbol,TIME_FRAME,index);  // Giá đóng
      string            trend="";
      if(open<close)
         trend=TREND_BUY;
      if(open>close)
         trend=TREND_SEL;

      CandleData candle(time,open,high,low,close,open,high,low,close,trend,0,0,"",0,"","","",0,"",0,"","",0,0,false,false,0.0,0,"",0,"",0);
      candleArray[index]=candle;
     }


   for(int index=length+3; index>=0; index--)
     {
      CandleData cancle_i=candleArray[index];

      int count_trend=1;
      for(int j=index+1; j<length; j++)
        {
         if(cancle_i.trend_heiken==candleArray[j].trend_heiken)
            count_trend+=1;
         else
            break;
        }

      candleArray[index].count_heiken=count_trend;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countMaCross(string symbol, ENUM_TIMEFRAMES TF, string &cross_trend, int ma_fast = 10, int ma_slow = 50)
  {
   double closePrices[];
   int maLength=100;
   ArrayResize(closePrices,maLength);

   for(int i=maLength-1; i>=0; i--)
      closePrices[i]=iClose(symbol,TF,i);

   double ma10_0 = cal_MA(closePrices, ma_fast, 0);
   double ma20_0 = cal_MA(closePrices, ma_slow, 0);

   int count_ma10_vs_ma20 = 0;
   cross_trend = (ma10_0 > ma20_0) ?TREND_BUY:TREND_SEL;

   bool isAbove = ma10_0 > ma20_0;
   for(int i = 0; i < maLength; i++)
     {
      double ma10 = cal_MA(closePrices, ma_fast, i);
      double ma20 = cal_MA(closePrices, ma_slow, i);

      if(isAbove)
        {
         if(ma10 > ma20)
            count_ma10_vs_ma20++;
         else
            break;
        }

      if(!isAbove)
        {
         if(ma10 < ma20)
            count_ma10_vs_ma20++;
         else
            break;
        }
     }
   if(count_ma10_vs_ma20==0)
      count_ma10_vs_ma20=maLength;

   return count_ma10_vs_ma20;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string check_MACrossover(double& closePrices[], int ma10 = 6, int ma20 = 20)
  {
   for(int i = 0; i < 4; i++) // Kiểm tra trong khoảng nến từ 0 đến 4
     {
      double ma10_prev = cal_MA(closePrices, ma10, i+1);
      double ma20_prev = cal_MA(closePrices, ma20, i+1);

      double ma10_curr = cal_MA(closePrices, ma10, i);
      double ma20_curr = cal_MA(closePrices, ma20, i);

      if(ma10_prev <= ma20_prev && ma10_curr > ma20_curr)
         return TREND_BUY;  // MA10 cắt lên MA20

      if(ma10_prev >= ma20_prev && ma10_curr < ma20_curr)
         return TREND_SEL; // MA10 cắt xuống MA20
     }

   return ""; // Không có giao cắt
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string check_MACrossoverHeiken(CandleData &candleArray[], int ma10 = 6, int ma20 = 20)
  {
   double closePrices[];
   int maLength=ArraySize(candleArray);
   ArrayResize(closePrices,maLength);

   for(int i=maLength-1; i>=0; i--)
      closePrices[i]=candleArray[i].close;

   for(int i = 0; i < 3; i++) // Kiểm tra trong khoảng nến từ 0 đến 4
     {
      double ma10_prev = cal_MA(closePrices, ma10, i+1);
      double ma20_prev = cal_MA(closePrices, ma20, i+1);

      double ma10_curr = cal_MA(closePrices, ma10, i);
      double ma20_curr = cal_MA(closePrices, ma20, i);

      if(ma10_prev <= ma20_prev && ma10_curr > ma20_curr)
         return TREND_BUY;  // MA10 cắt lên MA20

      if(ma10_prev >= ma20_prev && ma10_curr < ma20_curr)
         return TREND_SEL; // MA10 cắt xuống MA20
     }

   return ""; // Không có giao cắt
  }
//+------------------------------------------------------------------+
//double close_1 = iClose(symbol,TradingPeriod,1);
//double close_2 = iClose(symbol,TradingPeriod,2);
//double ma20 = cal_MA_XX(symbol,TradingPeriod,20,1);
//string trend_by_ma20 = close_1 > ma20 ? TREND_BUY : TREND_SEL;
//bool cut_buy_20 = (close_2<ma20) && (ma20<close_1);
//bool cut_sel_20 = (close_2>ma20) && (ma20>close_1);
//if(msg_r1c1=="" && (cut_buy_20 || cut_sel_20))
//   msg_r1c1 = symbol+" "+TF_TRADING+" x Ma20 " + trend_by_ma20;
//+------------------------------------------------------------------+
void get_arr_heiken(string symbol,ENUM_TIMEFRAMES TIME_FRAME,CandleData &candleArray[],int length,bool is_calc_ma10,bool is_calc_seq102050)
  {
   if(is_calc_seq102050 && TIME_FRAME<=PERIOD_H4 && length<50)
      length=50;

   ArrayResize(candleArray,length+5);
     {
      datetime pre_HaTime=iTime(symbol,TIME_FRAME,length+4);
      double pre_HaOpen=iOpen(symbol,TIME_FRAME,length+4);
      double pre_HaHigh=iHigh(symbol,TIME_FRAME,length+4);
      double pre_HaLow=iLow(symbol,TIME_FRAME,length+4);
      double pre_HaClose=iClose(symbol,TIME_FRAME,length+4);
      string pre_candle_trend=pre_HaClose>pre_HaOpen ? TREND_BUY : TREND_SEL;

      double candlestick_open=pre_HaOpen;
      double candlestick_high=pre_HaHigh;
      double candlestick_low=pre_HaLow;
      double candlestick_close=pre_HaClose;

      CandleData candle(pre_HaTime,pre_HaOpen,pre_HaHigh,pre_HaLow,pre_HaClose
                        ,candlestick_open, candlestick_high, candlestick_low, candlestick_close
                        ,pre_candle_trend,0,0,"",0,"","","",0,"",0,"","",0,0,false,false,0,0,"",0,"",0);
      candleArray[length+4]=candle;
     }


   for(int index=length+3; index>=0; index--)
     {
      CandleData pre_cancle=candleArray[index+1];

      datetime haTime=iTime(symbol,TIME_FRAME,index);

      double candlestick_open=iOpen(symbol,TIME_FRAME,index);
      double candlestick_high=iHigh(symbol,TIME_FRAME,index);
      double candlestick_low=iLow(symbol,TIME_FRAME,index);
      double candlestick_close=iClose(symbol,TIME_FRAME,index);

      double haClose=(candlestick_open+candlestick_high+candlestick_low+candlestick_close) / 4.0;
      double haOpen =(pre_cancle.open+pre_cancle.close) / 2.0;
      double haHigh =MathMax(MathMax(haOpen,haClose),candlestick_high);
      double haLow  =MathMin(MathMin(haOpen,haClose),candlestick_low);
      string haTrend=haClose>=haOpen ? TREND_BUY : TREND_SEL;

      int count_heiken=1;
      for(int j=index+1; j<length; j++)
        {
         if(haTrend==candleArray[j].trend_heiken)
            count_heiken+=1;
         else
            break;
        }

      CandleData candle_x(haTime,haOpen,haHigh,haLow,haClose
                          ,candlestick_open, candlestick_high, candlestick_low, candlestick_close
                          ,haTrend,count_heiken,0,"",0,"","","",0,"",0,"","",0,0,false,false,0,0,"",0,"",0);
      candleArray[index]=candle_x;
     }

   if(is_calc_ma10)
     {
      double lowest=0.0,higest=0.0;
      for(int idx=0; idx <= length; idx++)
        {
         double low=candleArray[idx].low;
         double hig=candleArray[idx].high;
         if((idx==0) || (lowest==0) || (lowest>low))
            lowest=low;
         if((idx==0) || (higest==0) || (higest<hig))
            higest=hig;
        }

      double closePrices[];
      int maLength=length+15;
      ArrayResize(closePrices,maLength);

      for(int i=maLength-1; i>=0; i--)
         closePrices[i]=iClose(symbol,TIME_FRAME,i);

      double lowest_7d=0.0,higest_7d=0.0;
      for(int id=0; id<7; id++)
        {
         double low=iLow(symbol,PERIOD_D1,id);
         double hig=iHigh(symbol,PERIOD_D1,id);
         if((id==0) || (lowest_7d==0) || (lowest_7d>low))
            lowest_7d=low;
         if((id==0) || (higest_7d==0) || (higest_7d<hig))
            higest_7d=hig;
        }

      double amp_w1,amp_d1,amp_h4,amp_h1;
      GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);


      int loop=ArraySize(candleArray)-5;
      for(int index=loop; index>=0; index--)
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
         string trend_ma10vs20="";
         string trend_ma05vs10=(ma05>ma10)? TREND_BUY : (ma05<ma10)? TREND_SEL : "";

         string trend_by_ma20="";
         string trend_by_ma50="";
         if(is_calc_seq102050 && loop>40 && index<loop-20)
           {
            double ma20=cal_MA(closePrices,20,index);
            trend_by_ma20 =(mid>ma20) ? TREND_BUY : (mid<ma20) ? TREND_SEL : "";

            double ma50=cal_MA(closePrices,50,index);
            trend_by_ma50 =(mid>ma50) ? TREND_BUY : (mid<ma50) ? TREND_SEL : "";
           }

         double ma20=0;
         double ma50=0;
         bool allow_trade_now_by_seq_051020=false;
         bool allow_trade_now_by_seq_102050=false;

         string trend_by_seq_051020="";
         string trend_by_seq_102050="";
         if(maLength>45 && index<=21)
           {
            ma20=cal_MA(closePrices,20,index);
            trend_ma10vs20=(ma10>ma20)? TREND_BUY : (ma10<ma20)? TREND_SEL : "";

            if(mid>ma05 && ma05>ma10 && ma10>ma20 && is_same_symbol(trend_by_ma10,TREND_BUY))
               trend_by_seq_051020 = TREND_BUY;
            if(mid<ma05 && ma05<ma10 && ma10<ma20 && is_same_symbol(trend_by_ma10,TREND_SEL))
               trend_by_seq_051020 = TREND_SEL;

            bool is_seq_buy = (mid>ma05 && mid>ma10 && mid>ma20);
            bool is_seq_sel = (mid<ma05 && mid<ma10 && mid<ma20);
            if(is_seq_buy || is_seq_sel)
              {
               if(is_seq_buy && (lowest_7d>ma20-amp_d1))
                  allow_trade_now_by_seq_051020=true;

               if(is_seq_sel && (higest_7d<ma20+amp_d1))
                  allow_trade_now_by_seq_051020=true;
              }

            //CHECK_SEQ
            if(maLength>45)
              {
               ma50=cal_MA(closePrices,50,index);
               trend_by_ma50 =(mid>ma50) ? TREND_BUY : (mid<ma50) ? TREND_SEL : "";

               if(ma10>ma20 && ma20>ma50 && is_same_symbol(trend_by_ma20,TREND_BUY))
                 {
                  trend_by_seq_102050=TREND_BUY;

                  if(lowest_7d>ma50-amp_d1)
                     allow_trade_now_by_seq_102050=true;
                 }

               if(ma10<ma20 && ma20<ma50 && is_same_symbol(trend_by_ma20,TREND_SEL))
                 {
                  trend_by_seq_102050=TREND_SEL;

                  if(higest_7d<ma50+amp_d1)
                     allow_trade_now_by_seq_102050=true;
                 }
              }
           }


         int count_ma10=1;
         for(int j=index+1; j<length+1; j++)
           {
            if(trend_by_ma10==candleArray[j].trend_by_ma10)
               count_ma10+=1;
            else
               break;
           }

         int count_ma20=1;
         if(is_calc_seq102050 && trend_by_ma20 != "")
            for(int j=index+1; j<length+1; j++)
              {
               if(trend_by_ma20==candleArray[j].trend_by_ma20)
                  count_ma20+=1;
               else
                  break;
              }

         int count_ma50=1;
         if(is_calc_seq102050 && trend_by_ma50 != "")
            for(int j=index+1; j<length+1; j++)
              {
               if(trend_by_ma50==candleArray[j].trend_by_ma50)
                  count_ma50+=1;
               else
                  break;
              }

         int count_ma3_vs_ma5=99;
         CandleData candle_x(cur_cancle.time,cur_cancle.open,cur_cancle.high,cur_cancle.low,cur_cancle.close
                             ,cur_cancle.candlestick_open, cur_cancle.candlestick_high, cur_cancle.candlestick_low, cur_cancle.candlestick_close
                             ,cur_cancle.trend_heiken
                             ,cur_cancle.count_heiken,ma10,trend_by_ma10,count_ma10,trend_vector_ma10
                             ,trend_by_ma05,trend_ma10vs20,count_ma3_vs_ma5,trend_by_seq_102050,ma50,trend_by_seq_051020,trend_ma05vs10,lowest,higest,allow_trade_now_by_seq_051020,allow_trade_now_by_seq_102050
                             ,ma20,count_ma20,trend_by_ma20,ma05,trend_by_ma50, count_ma50);

         candleArray[index]=candle_x;
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol,ENUM_TIMEFRAMES TIME_FRAME,int candle_idx)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol,TIME_FRAME,candleArray,candle_idx+3,false,false);

   string result=candleArray[candle_idx].trend_heiken;

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Risk_1L()
  {
   double result = 50;
   long login=AccountInfoInteger(ACCOUNT_LOGIN);
   if(is_same_symbol(ACCOUNT_CENT,(string)login))
      return 250;

   if(is_same_symbol(ACCOUNT_FTMO,(string)login))
      result = 250;

   if(is_same_symbol(ACCOUNT_THE5,(string)login))
      result = 50;

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Risk_By_Percent(double risk_by_percent=5)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   return NormalizeDouble(BALANCE*risk_by_percent/100, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_comment_timeframe(string TRADING_TREND,int L)
  {
   string result=BOT_SHORT_NM+TRADING_TREND+"_"+appendZero100(L);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_comment(string TRADER, string TRADING_TREND, int L, string count_ma10)
  {
   double tp_when=GetGlobalVariable(BtnCloseWhen_);

   string result = TRADER + MASK_TIMEFRAME_TRADING + get_time_frame_name(Period())+"]"+count_ma10 + TRADING_TREND + "_" + append1Zero(L);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_L(string TRADER,string trend,string last_comment)
  {
   for(int i=1; i<100; i++)
     {
      string comment=create_comment(TRADER,trend,i,"");
      if(is_same_symbol(last_comment,comment))
         return i;
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetAmpAvgL15(string symbol,double &amp_w1,double &amp_d1,double &amp_h4,double &amp_h1)
  {
   if(is_same_symbol(symbol,"XAUUSD"))//AU
     {
      amp_w1=100;
      amp_d1=70;
      amp_h4=30;
      amp_h1=15;
      return;
     }
   if(is_same_symbol(symbol,"XAGUSD"))//AG
     {
      amp_w1=1.95;
      amp_d1=0.85;
      amp_h4=0.55;
      amp_h1=0.35;
      return;
     }
   if(is_same_symbol(symbol,"USOIL"))//UL
     {
      amp_w1=4.25;
      amp_d1=1.77;
      amp_h4=0.80;
      amp_h1=0.41;
      return;
     }
   if(is_same_symbol(symbol,"BTCUSD"))//BU
     {
      amp_w1=8440;
      amp_d1=4265;
      amp_h4=2382;
      amp_h1=1388;
      return;
     }
   if(is_same_symbol(symbol,"ETHUSD"))//ETH
     {
      amp_w1=450;
      amp_d1=150;
      amp_h4=100;
      amp_h1=50;
      return;
     }

   if(is_same_symbol(symbol,"USTEC") || is_same_symbol(symbol,"US100"))//U100
     {
      amp_w1=800.0;
      amp_d1=400.0;
      amp_h4=200.0;
      amp_h1=125;
      return;
     }
   if(is_same_symbol(symbol,"US30"))//U30
     {
      amp_w1=1090.0;
      amp_d1=529.0;
      amp_h4=262.5;
      amp_h1=165;
      return;
     }
   if(is_same_symbol(symbol,"US500"))//U5
     {
      amp_w1=160.0;
      amp_d1=80.0;
      amp_h4=41.0;
      amp_h1=27.5;
      return;
     }
   if(is_same_symbol(symbol,"DE30"))
     {
      amp_w1=530.6;
      amp_d1=156.6;
      amp_h4=62.3;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"UK100"))
     {
      amp_w1=208.25;
      amp_d1=68.31;
      amp_h4=29.0;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"FR40") || is_same_symbol(symbol,"DAX40") || is_same_symbol(symbol,"GER40"))
     {
      amp_w1=600.00;
      amp_d1=300.00;
      amp_h4=200.00;
      amp_h1=125.00;
      return;
     }
   if(is_same_symbol(symbol,"JP225"))
     {
      amp_w1=2000.00;
      amp_d1=1000.00;
      amp_h4=700.00;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"AUS200"))
     {
      amp_w1=204.43;
      amp_d1=67.52;
      amp_h4=29.93;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"AUDCHF"))//AF
     {
      amp_w1=0.01242;
      amp_d1=0.00500;
      amp_h4=0.00158;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"AUDNZD"))//AN
     {
      amp_w1=0.01036;
      amp_d1=0.00495;
      amp_h4=0.00178;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"AUDUSD"))//AU
     {
      amp_w1=0.01267;
      amp_d1=0.00562;
      amp_h4=0.00238;
      amp_h1=0.0015;
      return;
     }
   if(is_same_symbol(symbol,"AUDJPY"))//AJ
     {
      amp_w1=2.950;
      amp_d1=1.165;
      amp_h4=0.52;
      amp_h1=0.35;
      return;
     }
   if(is_same_symbol(symbol,"CHFJPY"))//CJ
     {
      amp_w1=4.911;
      amp_d1=1.107;
      amp_h4=0.458;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"EURJPY"))//EJ
     {
      amp_w1=3.700;
      amp_d1=1.642;
      amp_h4=0.81;
      amp_h1=0.52;
      return;
     }
   if(is_same_symbol(symbol,"GBPJPY"))//GJ
     {
      amp_w1=4.48;
      amp_d1=1.95;
      amp_h4=0.95;
      amp_h1=0.60;
      return;
     }
   if(is_same_symbol(symbol,"NZDJPY"))//NJ
     {
      amp_w1=2.419;
      amp_d1=1.068;
      amp_h4=0.455;
      amp_h1=0.282;
      return;
     }
   if(is_same_symbol(symbol,"USDJPY"))//UJ
     {
      amp_w1=3.55;
      amp_d1=1.55;
      amp_h4=0.66;
      amp_h1=0.50;
      return;
     }
   if(is_same_symbol(symbol,"EURAUD"))//EA
     {
      amp_w1=0.030;
      amp_d1=0.021;
      amp_h4=0.006;
      amp_h1=0.003;
      return;
     }
   if(is_same_symbol(symbol,"EURCAD"))//EC
     {
      amp_w1=0.0193;
      amp_d1=0.0010;
      amp_h4=0.0037;
      amp_h1=0.0017;
      return;
     }
   if(is_same_symbol(symbol,"EURCHF"))//UF
     {
      amp_w1=0.01309;
      amp_d1=0.00525;
      amp_h4=0.00180;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"EURGBP"))//EG
     {
      amp_w1=0.00755;
      amp_d1=0.00375;
      amp_h4=0.00155;
      amp_h1=0.00105;
      return;
     }
   if(is_same_symbol(symbol,"EURNZD"))//EN
     {
      amp_w1=0.0252;
      amp_d1=0.0113;
      amp_h4=0.0048;
      amp_h1=0.0031;
      return;
     }
   if(is_same_symbol(symbol,"EURUSD"))//EU
     {
      amp_w1=0.0156;
      amp_d1=0.0085;
      amp_h4=0.0055;
      amp_h1=0.0025;
      return;
     }
   if(is_same_symbol(symbol,"GBPCHF"))//GF
     {
      amp_w1=0.01905;
      amp_d1=0.00752;
      amp_h4=0.00241;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"GBPNZD"))//GN
     {
      amp_w1=0.0295;
      amp_d1=0.0142;
      amp_h4=0.0055;
      amp_h1=0.0033;
      return;
     }
   if(is_same_symbol(symbol,"GBPUSD"))//GU
     {
      amp_w1=0.01952;
      amp_d1=0.01020;
      amp_h4=0.00355;
      amp_h1=0.00225;
      return;
     }
   if(is_same_symbol(symbol,"NZDCAD"))//NC
     {
      amp_w1=0.01459;
      amp_d1=0.0055;
      amp_h4=0.00216;
      amp_h1=0;
      return;
     }
   if(is_same_symbol(symbol,"NZDUSD"))//NU
     {
      amp_w1=0.0118;
      amp_d1=0.0052;
      amp_h4=0.0021;
      amp_h1=0.0012;
      return;
     }
   if(is_same_symbol(symbol,"USDCAD"))//UC
     {
      amp_w1=0.0158;
      amp_d1=0.0105;
      amp_h4=0.0045;
      amp_h1=0.0031;
      return;
     }
   if(is_same_symbol(symbol,"USDCHF"))//UF
     {
      amp_w1=0.0139;
      amp_d1=0.0065;
      amp_h4=0.0025;
      amp_h1=0.0015;
      return;
     }

   amp_w1=calc_average_candle_height(PERIOD_W1,symbol,20);
   amp_d1=calc_average_candle_height(PERIOD_D1,symbol,30);
   amp_h4=calc_average_candle_height(PERIOD_H4,symbol,60);
   amp_h1=amp_d1;
//SendAlert(INDI_NAME,"Get Amp Avg"," Get AmpAvg:"+(string)symbol+"   amp_w1: "+(string)amp_w1+"   amp_d1: "+(string)amp_d1+"   amp_h4: "+(string)amp_h4);
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetDefaultButtonColor(string trend)
  {
   return is_same_symbol(trend,TREND_BUY)?clrActiveBtn:is_same_symbol(trend,TREND_SEL)?clrActiveSell:clrLightGray;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetGlobalVariableTrend(string varName)
  {
   string trend="";
   double trade_type=GetGlobalVariable(varName);
   trend+=MathAbs(trade_type)==MathAbs(AUTO_TRADE_BUY)?TREND_BUY:"";
   trend+=MathAbs(trade_type)==MathAbs(AUTO_TRADE_SEL)?TREND_SEL:"";

   return trend;
  }
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
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateCandleHeight(string symbol, int candle_index, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double high=iHigh(symbol, TIMEFRAME, candle_index);   // Giá cao nhất của cây nến
   double low=iLow(symbol, TIMEFRAME, candle_index);     // Giá thấp nhất của cây nến
   return high - low;  // Chiều cao của cây nến
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getArraySymbolsSize()
  {
//--- Account number
   long login=AccountInfoInteger(ACCOUNT_LOGIN);


   if(is_same_symbol(ACCOUNT_CENT,(string)login))
      return ArraySize(ARR_SYMBOLS_CENT);

   if(is_same_symbol(ACCOUNT_FTMO,(string)login))
      return ArraySize(ARR_SYMBOLS_FTMO);

   if(is_same_symbol(ACCOUNT_THE5,(string)login))
      return ArraySize(ARR_SYMBOLS_THE5);

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getSymbolAtIndex(int index)
  {
//--- Account number
   long login=AccountInfoInteger(ACCOUNT_LOGIN);

   if(is_same_symbol(ACCOUNT_CENT,(string)login))
      return ARR_SYMBOLS_CENT[index];

   if(is_same_symbol(ACCOUNT_FTMO,(string)login))
      return ARR_SYMBOLS_FTMO[index];

   if(is_same_symbol(ACCOUNT_THE5,(string)login))
      return ARR_SYMBOLS_THE5[index];

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_symbol_from_label(string lable)
  {
   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string symbol = getSymbolAtIndex(index);
      if(is_same_symbol(lable,symbol))
         return symbol;
     }

   return lable;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateAverageCandleHeight(string symbol)
  {
   datetime current_candle_time_w1=iTime(NULL, PERIOD_W1, 0);
   if(current_candle_time_w1 != last_time_w1)
     {
      int last_closed_candle_index=1;  // Cây nến W1 vừa đóng cửa là cây nến index 1 (index 0 là cây nến hiện tại)

      // Tính chiều cao của nến vừa đóng
      double candle_height_w1=CalculateCandleHeight(symbol,last_closed_candle_index,PERIOD_W1);

      // Cập nhật tổng chiều cao nến và số lượng nến đã đóng
      total_height_w1 += candle_height_w1;
      num_candles_w1 += 1;

      // Tính chiều cao trung bình của tất cả các nến
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)-1;
      double average_height_w1=NormalizeDouble(total_height_w1/num_candles_w1,digits);

      //if(average_height_w1>GetGlobalVariable(AVG_HEIGHT_W1+symbol))
      SetGlobalVariable(AVG_HEIGHT_W1+symbol,average_height_w1);

      last_time_w1=current_candle_time_w1;  // Cập nhật lại thời gian của cây nến cuối cùng
     }
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
   datetime current_candle_time_d1=iTime(NULL, PERIOD_D1, 0);
   if(current_candle_time_d1 != last_time_d1)
     {
      int last_closed_candle_index=1;  // Cây nến D1 vừa đóng cửa là cây nến index 1 (index 0 là cây nến hiện tại)

      // Tính chiều cao của nến vừa đóng
      double candle_height_d1=CalculateCandleHeight(symbol,last_closed_candle_index,PERIOD_D1);

      // Cập nhật tổng chiều cao nến và số lượng nến đã đóng
      total_height_d1 += candle_height_d1;
      num_candles_d1 += 1;

      // Tính chiều cao trung bình của tất cả các nến
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)-1;
      double average_height_d1=NormalizeDouble(total_height_d1/num_candles_d1,digits);

      //if(average_height_d1>GetGlobalVariable(AVG_HEIGHT_D1+symbol))
      SetGlobalVariable(AVG_HEIGHT_D1+symbol,average_height_d1);

      last_time_d1=current_candle_time_d1;  // Cập nhật lại thời gian của cây nến cuối cùng
     }
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
   datetime current_candle_time_h4=iTime(NULL, PERIOD_H4, 0);
   if(current_candle_time_h4 != last_time_h4)
     {
      int last_closed_candle_index=1;  // Cây nến H4 vừa đóng cửa là cây nến index 1 (index 0 là cây nến hiện tại)

      // Tính chiều cao của nến vừa đóng
      double candle_height_h4=CalculateCandleHeight(symbol,last_closed_candle_index,PERIOD_H4);

      // Cập nhật tổng chiều cao nến và số lượng nến đã đóng
      total_height_h4 += candle_height_h4;
      num_candles_h4 += 1;

      // Tính chiều cao trung bình của tất cả các nến
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)-1;
      double average_height_h4=NormalizeDouble(total_height_h4/num_candles_h4,digits);

      //if(average_height_h4>GetGlobalVariable(AVG_HEIGHT_H4+symbol))
      SetGlobalVariable(AVG_HEIGHT_H4+symbol,average_height_h4);

      last_time_h4=current_candle_time_h4;  // Cập nhật lại thời gian của cây nến cuối cùng
     }
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
   datetime current_candle_time_h1=iTime(NULL, PERIOD_H1, 0);
   if(current_candle_time_h1 != last_time_h1)
     {
      int last_closed_candle_index=1;  // Cây nến H1 vừa đóng cửa là cây nến index 1 (index 0 là cây nến hiện tại)

      // Tính chiều cao của nến vừa đóng
      double candle_height_h1=CalculateCandleHeight(symbol,last_closed_candle_index,PERIOD_H1);

      // Cập nhật tổng chiều cao nến và số lượng nến đã đóng
      total_height_h1 += candle_height_h1;
      num_candles_h1 += 1;

      // Tính chiều cao trung bình của tất cả các nến
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)-1;
      double average_height_h1=NormalizeDouble(total_height_h1/num_candles_h1,digits);

      //if(average_height_h1>GetGlobalVariable(AVG_HEIGHT_H1+symbol))
      SetGlobalVariable(AVG_HEIGHT_H1+symbol,average_height_h1);

      last_time_h1=current_candle_time_h1;  // Cập nhật lại thời gian của cây nến cuối cùng
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTodayProfitLoss()
  {
   double totalProfitLoss=0.0; // Variable to store total profit or loss

   MqlDateTime date_time;
   TimeToStruct(TimeCurrent(),date_time);
   int current_day=date_time.day,current_month=date_time.mon,current_year=date_time.year;
   int row_count=0;
// --------------------------------------------------------------------
// --------------------------------------------------------------------
   double current_balance=AccountInfoDouble(ACCOUNT_BALANCE);
   HistorySelect(0,TimeCurrent()); // today closed trades PL
   int orders=HistoryDealsTotal();

   double PL=0.0;
   for(int i=orders-1; i>=0; i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
        {
         break;
        }

      string symbol =HistoryDealGetString(ticket,DEAL_SYMBOL);
      if(symbol=="")
        {
         continue;
        }

      double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT)+HistoryDealGetDouble(ticket,DEAL_COMMISSION)+HistoryDealGetDouble(ticket,DEAL_SWAP);

      if(profit != 0)  // If deal is trade exit with profit or loss
        {
         MqlDateTime deal_time;
         TimeToStruct(HistoryDealGetInteger(ticket,DEAL_TIME),deal_time);

         // If is today deal
         if(deal_time.day==current_day && deal_time.mon==current_month && deal_time.year==current_year)
           {
            PL+=profit;
           }
         else
            break;
        }
     }

   return PL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawCandleIndex(CandleData &arrHeiken_Cr[])
  {
   int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));
   int dheigh = 60;
   bool IS_MACD_DOT=GetGlobalVariable(BtnMacdMode)==AUTO_TRADE_ONN;

   string symbol = Symbol();
   ENUM_TIMEFRAMES period = Period();

   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_h1);
   double avg_amp = amp_w1;
   if(period==PERIOD_D1)
      avg_amp = amp_d1;
   if(period==PERIOD_H4)
      avg_amp = amp_h4;
   if(period<=PERIOD_H1)
      avg_amp = amp_h1;

   int size_d1 = ArraySize(arrHeiken_Cr)-10;
   string boicuabay = ",0,7,13,21,27,34,52,";
   datetime time_shift = arrHeiken_Cr[1].time - arrHeiken_Cr[2].time;
   double bread = (arrHeiken_Cr[1].high-arrHeiken_Cr[1].low)/8;
   for(int i = 0; i < size_d1-20; i++)
     {
      string lbl_Ma10="CountMa10D_"+appendZero100(i);
      double amp_candle = arrHeiken_Cr[i].high-arrHeiken_Cr[i].low;
      if(amp_candle>avg_amp*2)
         create_trend_line("Purple.C"+appendZero100(i)
                           ,arrHeiken_Cr[i].time,arrHeiken_Cr[i].low
                           ,arrHeiken_Cr[i].time,arrHeiken_Cr[i].high
                           ,clrLavender,STYLE_SOLID,6);

      //create_trend_line(lbl_Ma10+".",arrHeiken_Cr[i+1].time,arrHeiken_Cr[i+1].ma10,arrHeiken_Cr[i].time,arrHeiken_Cr[i].ma10,clrDimGray,STYLE_SOLID,3);

      string key_ma10=","+IntegerToString(arrHeiken_Cr[i].count_ma10)+",";

      color clrColor=is_same_symbol(arrHeiken_Cr[i].trend_heiken,TREND_BUY)?clrBlue:clrRed;
      double pos = is_same_symbol(arrHeiken_Cr[i].trend_heiken,TREND_BUY)?arrHeiken_Cr[i].high+bread:arrHeiken_Cr[i].low-bread;

      datetime timeMid = arrHeiken_Cr[i].time;
      string key_hei =","+IntegerToString(arrHeiken_Cr[i].count_heiken)+",";

      if(is_same_symbol(boicuabay, key_ma10))
         create_trend_line(lbl_Ma10+"_",timeMid,pos,timeMid+1,pos,clrYellow,STYLE_SOLID,7,false,false,true,false);

      create_label_simple(lbl_Ma10,IntegerToString(arrHeiken_Cr[i].count_heiken),pos,clrColor,timeMid,0,6);
      ObjectSetInteger(0,lbl_Ma10,OBJPROP_ANCHOR,ANCHOR_CENTER);

      if(i == 0)
        {
         create_label_simple("CountMa20",""+getShortName(arrHeiken_Cr[0].trend_by_ma20)+"." +IntegerToString(arrHeiken_Cr[0].count_ma20)
                             ,arrHeiken_Cr[i].ma20,is_same_symbol(arrHeiken_Cr[0].trend_by_ma20,TREND_BUY)?clrBlue:clrRed,timeMid,0,7);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DrawAndCountHistogram(CandleData &candleArray[], string symbol, ENUM_TIMEFRAMES TF, bool allow_draw=false, double price_from=50000, double price_to=60000)
  {
   double closeArray[];
//datetime timeFrArr[];
   int size = ArraySize(candleArray);
   ArrayResize(closeArray, size);
//ArrayResize(timeFrArr, size);

//datetime shift = iTime(symbol, PERIOD_CURRENT, 1)-iTime(symbol, PERIOD_CURRENT, 2);
   string prefix = "Histogram"+get_time_frame_name(TF);

   for(int i = 0; i < size-10; i++)
     {
      closeArray[i] = candleArray[i].close;
      //timeFrArr[i] = iTime(symbol, PERIOD_CURRENT, i);//+50
     }

   int SHORT_EMA_PERIOD = 12;
   int LONG_EMA_PERIOD = 26;
   int SIGNAL_PERIOD = 9;
   int n = ArraySize(closeArray);

   if(n < LONG_EMA_PERIOD)
     {
      //Print("Không đủ dữ liệu để vẽ MACD");
      return "";
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

   double mid = (price_from + price_to) / 2.0;
   double hist_high = (price_to-price_from)/2;
   color clrColorBuy=clrPaleTurquoise, clrSell=clrLightPink;
   datetime TIME_SPACE = TIME_OF_ONE_H4_CANDLE;
   datetime TIME_OF_ONE_CANDLE=candleArray[0].time-candleArray[1].time;
   string trendArrs[];
   int loop = (int)(MathMin(n-26,20));
   for(int i = loop; i >= 0; i--)
     {
      if(macdValues[i] == EMPTY_VALUE || signalValues[i] == EMPTY_VALUE)
         continue;

      double hist = macdValues[i]-signalValues[i];
      string trend_his = hist>0?TREND_BUY:TREND_SEL;
      double hist_price = hist>0?mid+hist_high:mid-hist_high;
      if(allow_draw)
        {
         color clrColor = hist>0?clrTeal:clrFireBrick;
         string hist_name = prefix + "Hist_" + append1Zero(i)+"_"+get_yyyymmdd(candleArray[i].time);

         if(i<20)
            create_filled_rectangle(hist_name
                                    ,candleArray[i].time,mid
                                    ,(i>0?candleArray[i-1].time:TimeCurrent()),hist_price
                                    ,clrColor,true,false);
        }

      int idx = ArraySize(trendArrs);
      ArrayResize(trendArrs,idx+1);
      trendArrs[idx]=trend_his;
     }
   if(allow_draw)
      create_trend_line(prefix + "Zero"
                        , candleArray[loop-1].time-TIME_OF_ONE_CANDLE, mid
                        , TimeCurrent(), mid
                        , clrBlack, STYLE_SOLID,1);

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

   if(ArraySize(countArr) > 0)
     {
      string Histogram = trendArrs[0]+"_"+(string)countArr[0];

      color clrColor = trendArrs[0]==TREND_SEL?clrRed:clrBlue;
      if(allow_draw)
         create_label_simple("lblHistogram_"+get_time_frame_name(TF)
                             ,"   "+get_time_frame_name(TF)+" "+Histogram
                             ,mid,clrColor,TimeCurrent());

      Print(prefix+symbol+Histogram);
      return trendArrs[0];
     }

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
string to_percent(double profit,double decimal_part=2)
  {
   double BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
   string percent=" ("+format_double_to_string(profit/BALANCE * 100,1)+"%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   string symbol=Symbol();
   double profit_today=CalculateTodayProfitLoss();
   double EQUITY=AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
   double PL=EQUITY-BALANCE;
   string percent=to_percent(profit_today);

   double price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   int digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
   double amp_w1,amp_d1,amp_h4,amp_h1;
   GetAmpAvgL15(Symbol(),amp_w1,amp_d1,amp_h4,amp_h1);

   double risk_1L=Risk_1L();

   string cur_timeframe=get_current_timeframe_to_string();
   string str_comments=GetCurrentWeekday()+get_vntime()+AccountInfoString(ACCOUNT_NAME)+" "+BOT_SHORT_NM+" "+Symbol();

   if(is_same_symbol(symbol,"XAUUSD"))
      str_comments+=" Vàng: " +  DoubleToString(price*108/3230,2) + " tr";

   str_comments+="    "+DoubleToString(EQUITY,1)+"/10800";
   str_comments+="    Risk: "+get_profit_percent(risk_1L) + to_percent(risk_1L);
   str_comments+="    "+(string)RISK_BY_PERCENT+"%: "+(string)(int)Risk_By_Percent(RISK_BY_PERCENT);
   str_comments+="    Closed(today): "+format_double_to_string(profit_today,2)+"$"
                 +" ("+format_double_to_string(profit_today*25500/1000000,2)+" tr)"+percent+"/"+(string) count_closed_today+"L";
   str_comments+="    Opening: "+(string)(int)PL+"$"+to_percent(PL)
                 +" ("+format_double_to_string(PL*25500/1000000,2)+" tr)";

   if(Period()==PERIOD_MN1)//
     {
      str_comments+="\n";
      //str_comments+="    AVG_W1: "+format_double_to_string(GetGlobalVariable(AVG_HEIGHT_W1+symbol),digits-1)+" ("+(string)num_candles_w1+") / " + (string)amp_w1;
      //str_comments+="    AVG_D1: "+format_double_to_string(GetGlobalVariable(AVG_HEIGHT_D1+symbol),digits-1)+" ("+(string)num_candles_d1+") / " + (string)amp_d1;
      //str_comments+="    AVG_H4: "+format_double_to_string(GetGlobalVariable(AVG_HEIGHT_H4+symbol),digits-1)+" ("+(string)num_candles_h4+") / " + (string)amp_h4;
      //str_comments+="    AVG_H1: "+format_double_to_string(GetGlobalVariable(AVG_HEIGHT_H1+symbol),digits-1)+" ("+(string)num_candles_h1+") / " + (string)amp_h1;
      double AVG_W1=NormalizeDouble(calc_average_candle_height(PERIOD_W1,symbol,50),digits-1);
      double AVG_D1=NormalizeDouble(calc_average_candle_height(PERIOD_D1,symbol,50),digits-1);
      double AVG_H4=NormalizeDouble(calc_average_candle_height(PERIOD_H4,symbol,50),digits-1);
      double AVG_H1=NormalizeDouble(calc_average_candle_height(PERIOD_H1,symbol,50),digits-1);
      string AVG="";
      AVG+="    AVG_W1: "+(string)AVG_W1+" ( / amp_w1: " + (string)amp_w1;
      AVG+="    AVG_D1: "+(string)AVG_D1+" ( / amp_d1: " + (string)amp_d1;
      AVG+="    AVG_H4: "+(string)AVG_H4+" ( / amp_h4: " + (string)amp_h4;
      AVG+="    AVG_H1: "+(string)AVG_H1+" ( / amp_h1: " + (string)amp_h1;
      printf(symbol+AVG);
      str_comments+=AVG;
     }



   string account = AccountInfoString(ACCOUNT_NAME);
   if(EQUITY>=108050 && EQUITY<110000)
     {
      if(is_same_symbol(account,"FTMO"))
        {
         for(int i = PositionsTotal()-1; i >= 0; i--)
            if(m_position.SelectByIndex(i))
               m_trade.PositionClose(m_position.Ticket());

         SendTelegramMessage("The5percent","","PASS FTMO");
        }
     }

   if(EQUITY>=10805 && EQUITY<11000)
     {
      if(is_same_symbol(account,"10K"))
        {
         for(int i = PositionsTotal()-1; i >= 0; i--)
            if(m_position.SelectByIndex(i))
               m_trade.PositionClose(m_position.Ticket());

         SendTelegramMessage("The5percent","","PASS The5");
        }
     }
   return str_comments;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
