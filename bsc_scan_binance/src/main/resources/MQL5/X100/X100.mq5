//+------------------------------------------------------------------+
//|                                                      Solomon.mq5 |
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BOT_SHORT_NM = "(AmW)";       //"AmW":amp_w1,"AmD":amp_d1,"AmH":amp_h4,"AmS":amp_h4/2
//double FIXED_SL_BY_PERCENT = 100.00; // SYMBOL nao LOSS -30% thi dong toan bo lenh cua no
double RISK_BY_PERCENT     = 0.50;   // RISK_BY_PERCENT = 0.25%
//-----------------------------------------------------------------------------
string telegram_url="https://api.telegram.org";
//-----------------------------------------------------------------------------
#define BtnD10                   "BtnD10_"
#define BtnTrend                 "BtnTrend_"
#define BtnNoticeDH21            "BtnNoticeDH21"
#define BtnNoticeD1              "BtnNoticeD1"
#define BtnNoticeH4              "BtnNoticeH4"
#define BtnNoticeH1              "BtnNoticeH1"
#define BtnTradeD10H4            "BtnTradeD10H4_"
#define BtnTradeWma10            "BtnTradeWma10_"
#define BtnWaitToBuy             "BtnWaitBuyM5_"
#define BtnWaitToSel             "BtnWaitSelM5_"
#define BtnTradeByMa10D          "BtnTradeByMa10D_"
#define BtnTradeByRevMa10D       "BtnTradeByRevMa10D"
#define BtnTpSymbol              "BtnTpSymbol"
#define BtnCloseSymbol           "BtnCloseSymbol"
#define BtnCloseLimit            "BtnCloseLimit"
#define BtnCloseAllLimit         "BtnCloseAllLimit"
#define BtnCloseAllTicket        "BtnCloseAllTicket"
#define BtnTpXauPositive         "BtnTpXauPositive"
#define BtnTpOthersPositive      "BtnTpOthersPositive"
#define BtnClearChart            "BtnClearChart"
#define BtnClearMessage          "BtnClearMessage"
#define BtnTelegramMessage       "Telegram_Message"
#define BtnTpDay_06_07           "BtnTpDay_06_07"
#define BtnTpDay_13_14           "BtnTpDay_13_14"
#define BtnTpDay_20_21           "BtnTpDay_20_21"
#define BtnTpDay_27_28           "BtnTpDay_27_28"
#define BtnTpDay_34_35           "BtnTpDay_34_35"
#define BtnSendNoticeHei         "BtnSendNoticeHei_"
#define BtnSendNoticeMacd        "BtnSendNoticeMacd_"
#define BtnSendNoticeStoc        "BtnSendNoticeStoc_"
#define BtnInitStocH4ByW1Ma10    "BtnInitStocH4ByW1Ma10"
#define BtnResetWaitBuySelM5     "BtnResetWaitBuySelM5"
#define BtnOptionAutoExit        "BtnOptionAutoExit_"
#define SendTeleSeqMsg_          "SendTeleSeqMsg_"
#define BtnOptionPeriod          "BtnOption_Period_"
#define START_TRADE_LINE         "START_TRADE"
#define MAX_MESSAGES 20
bool ALLOW_DRAW_PROFIT = true;
//-----------------------------------------------------------------------------
bool IS_WAITTING_10PER_BUY = false;
bool IS_WAITTING_10PER_SEL = false;
bool IS_CONTINUE_TRADING_CYCLE_BUY = false;
bool IS_CONTINUE_TRADING_CYCLE_SEL = false;
double PRICE_START_TRADE = 0.0;
const double AUTO_TRADE_ON = 1;
const double AUTO_TRADE_OFF = -1;
//-----------------------------------------------------------------------------
const int OP_BUY=1;
const int OP_SEL=0;
bool   DEBUG_MODE = true;
string TREND_BUY = "BUY";
string TREND_SEL = "SELL";
string TREND_LIMIT_BUY = "LIMIT_B_U_Y";
string TREND_LIMIT_SEL = "LIMIT_S_E_L";
string MASK_DANGER   = "(X)";
string MASK_HEDG     = "(HG)";
string MASK_ROOT     = "(RO)";
string MASK_EXIT     = "(EX)";
string MASK_MANUAL   = "(ML)";
string MASK_10PER    = "(HS)";
string MASK_TP1D     = "(D.1)";
string MASK_D10      = "(D.X)";
string MASK_RevD10   = "(R.V)";
string MASK_SEQ_H4   = "(S.Q)";
string MASK_MARKET   = "(M.K)";
string MASK_LIMIT    = "(L.M)";
string MASK_TRIPLE   = "(X.3)";
string MASK_COUNT_TRI= "(:3)";
string MASK_AUTO_TRADE     = "(AT)";
string MASK_DAILY_TRADE    = "(DT)";
string MASK_TREND_TRANSFER = "(T.F)";
string SWITCH_TREND_BY_HISTOGRAM = "SwByHistogram_";
string LOCK = "(Lock)";
double MAXIMUM_DOUBLE = 999999999;
int count_closed_today = 0;
string FILE_NAME_MSG_LIST = "_messages.txt";
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
string FILE_NAME_AUTO_TRADE = "_auto_trade_today.txt";
datetime ALERT_MSG_TIME = 0;
datetime TIME_OF_ONE_H1_CANDLE = 3600;
datetime TIME_OF_ONE_H4_CANDLE = 14400;
datetime TIME_OF_ONE_D1_CANDLE = 86400;
datetime TIME_OF_ONE_W1_CANDLE = 604800;
string lable_profit_buy = "",lable_profit_sel = "",lableBtnPaddingTrade = "",lable_profit_positive_orders = "";
int DEFAULT_WAITING_DCA_IN_MINUS = 30,BUTTON_HEIGH = 20;
int MINUTES_BETWEEN_ORDER = 10;
int LIMIT_D = 250;
string arr_largest_negative_trader_name[100];
double arr_largest_negative_trader_amount[100];
string INIT_TREND_TODAY = "";
double FIBO_1618 = 1.618;
double FIBO_2618 = 2.618;
bool isDragging = false;
double INIT_START_PRICE = 0.0;
color clrActiveBtn = clrLightGreen;
int const SUB_WINDOW_BTN_CONTROLS = 4;
int const BTN_SEND_MSG_WIDTH = 155;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string REAL_ACCOUNT = ",Wallet-Real31:111119992"
                      +",   X100-Real31:111119988"     // Opening
                      +",Cent50k1-Real30:87149162"     // Opening
                      +",Exness-MT5Real25:183045374"   // Opening
                      +",Cent50k3-:"
                      +",Cent50k4-:"
                      +",Cent50k5-Real32:117076886"    // Opening
                      +",Cent50k6-Real32:117068423"    // Opening Cent50k6_NoEA
                      ;

string ARR_SYMBOLS_CENT[] =
  {
   "XAUUSDc"
   ,"AUDJPYc","NZDJPYc","EURJPYc","GBPJPYc","USDJPYc"
   ,"AUDCHFc","AUDNZDc","AUDUSDc"
   ,"EURAUDc","EURCADc","EURCHFc","GBPCHFc","EURNZDc","GBPNZDc"
   ,"EURGBPc","EURUSDc","GBPUSDc","NZDUSDc"
   ,"USDCADc","USDCHFc"
   ,"BTCUSDc"
  };

//Trial8:69478966
string ARR_SYMBOLS_USD[] =
  {
   "XAUUSD"
   ,"AUDJPY","NZDJPY","EURJPY","GBPJPY","USDJPY"
   ,"AUDCHF","AUDNZD","AUDUSD"
   ,"EURAUD","EURCAD","EURCHF","GBPCHF","EURNZD","GBPNZD"
   ,"EURGBP","EURUSD","GBPUSD","NZDUSD"
   ,"USDCAD","USDCHF"
   ,"USOIL","BTCUSD","US30","US500","USTEC","FR40","JP225"
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawButtons()
  {
   return;
   int size = getArraySymbolsSize();
   int count=0;
   int x = 40;
   int y = 5;
   int btn_width = 210;
   int btn_heigh = 20;
   int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));
   int chart_1_2_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))/2;

   for(int index = 0; index < size; index++)
     {
      string symbol = getSymbolAtIndex(index);
      bool is_cur_tab = is_same_symbol(symbol,Symbol());

      int btn_heigh = index==0?80:20;
      if(index==0 && size < 22)
         btn_heigh = 80;
      if(index==0 && size >= 22)
         btn_heigh = 110;

      string lblBtn10=symbol;
      if(index==0)
        {}
      if(index==8)
        {count = 0; x = btn_width+45; y = 35; btn_heigh = 20;}
      if(index==15)
        {count = 0; x = btn_width+45; y = 65; btn_heigh = 20;}
      if(index==21)
        {count = 0; x = btn_width+45; y = 95; btn_heigh = 20;}
      //----------------------------------------------------------------------------------------------------
      color clrBackground = clrWhite;
      color clrText = clrBlack;

      createButton(BtnD10+symbol,lblBtn10,x+(btn_width+5)*count,is_cur_tab && (index > 0)?y-7:y,btn_width
                   ,(index==0)?btn_heigh:is_cur_tab?btn_heigh+15:btn_heigh,clrText,clrBackground,6,4);

      if(is_cur_tab)
         ObjectSetString(0,BtnD10+symbol,OBJPROP_FONT,"Arial Bold");
     }
  }
//+------------------------------------------------------------------+
//| OpenTrade_X100                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   long chartID=ChartFirst();
   if(ChartNext(chartID) != -1)
      ChartClose(chartID);

   ObjectsDeleteAll(0);
   printf("int OnInit()");

//WriteAvgAmpToFile();
//for(int row = 0; row < 10; row++)
//   DeleteAllObjects();
//DeleteArrowObjects();
   string symbol = Symbol();

   DrawButtons();
   Draw_Notice_Ma10D();

   if(Period()==PERIOD_W1)
     {
      //FindMACDExtremes(symbol,PERIOD_W1,3);
      Draw_Trend_Channel(symbol,PERIOD_W1);
     }
   else
     {
      //FindMACDExtremes(symbol,PERIOD_W1,3);
      Draw_Fibo(symbol,PERIOD_D1);
     }
//
////Calc_Wave_Amp(symbol,PERIOD_M5);
//
   int width_man = 2;
   int width_sub = 1;

   if(Period()==PERIOD_MN1)
     {
      draw_trend_macd(symbol,PERIOD_MN1,width_man);
      draw_trend_macd(symbol,PERIOD_W1,width_sub);
     }

   if(Period()==PERIOD_W1)
     {
      draw_trend_macd(symbol,PERIOD_W1,width_man);
      draw_trend_macd(symbol,PERIOD_D1,width_sub);

      draw_trend_stoc(symbol,PERIOD_W1,21,7,7,2,width_man);
      draw_trend_stoc(symbol,PERIOD_D1,21,7,7,2,width_sub);
     }

   if(Period()==PERIOD_D1)
     {
      draw_trend_macd(symbol,PERIOD_D1,width_man);
      draw_trend_macd(symbol,PERIOD_H4,width_sub);

      draw_trend_stoc(symbol,PERIOD_D1,21,7,7,2,width_man);
      draw_trend_stoc(symbol,PERIOD_H4,21,7,7,2,width_sub);
     }

   if(Period() <= PERIOD_H4)
     {
      draw_trend_macd(symbol,PERIOD_H4,width_man);
      draw_trend_macd(symbol,PERIOD_H1,width_sub);

      draw_trend_stoc(symbol,PERIOD_H4,21,7,7,2,width_man);
      draw_trend_stoc(symbol,PERIOD_H1,21,7,7,2,width_sub);
     }

   if(Period()==PERIOD_H1)
     {
      CandleData arrHeiken_H1[];
      get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,350,true);
      CandleData arrHeiken_H4[];
      get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,250,true);
      CandleData arrHeiken_D1[];
      get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,30,true);

      draw_line_ma10_8020(symbol,PERIOD_H1,arrHeiken_H1,3,1);
      draw_line_ma10_8020(symbol,PERIOD_H4,arrHeiken_H4,3,2);
      draw_line_ma10_8020(symbol,PERIOD_D1,arrHeiken_D1,3,3);
     }

   if(Period() >= PERIOD_H4)
      Draw_Heiken(symbol);

   Draw_CurPrice_Line();

   Draw_Buttons_Trend(symbol);

   if(is_same_symbol(symbol,"XAU"))
      Draw_Lines(symbol);

   CreateMessagesBtn();

   Draw_MACD_Extremes_2(symbol,PERIOD_D1,45,true, 1,STYLE_SOLID);
   Draw_MACD_Extremes_2(symbol,PERIOD_H4,30,false,1,STYLE_DOT);
   Draw_MACD_Extremes_2(symbol,PERIOD_H1,15,false,1,STYLE_DOT);

   create_label_simple("Moon",GetMoonPhaseName(TimeCurrent()),iClose(symbol,PERIOD_D1,1));
   createButton(BtnClearChart,"Clear Chart",470,50,100,18,clrBlack,clrLightGray,6);

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   printf("int OnTimer()");

   if(is_time_enter_the_market()==false)
      return;

   string cur_symbol = Symbol();
   datetime vietnamTime = TimeGMT()+7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(vietnamTime,time_struct);
//-------------------------------------------------------------------------------
   bool allow_re_check_after_1h = false;
   int cur_hour = time_struct.hour;
   int pre_check_hour = -1;
   if(GlobalVariableCheck("timer_one_hour"))
      pre_check_hour = (int)GlobalVariableGet("timer_one_hour");
   GlobalVariableSet("timer_one_hour",cur_hour);

   if(pre_check_hour != cur_hour)
      allow_re_check_after_1h = true;

   if(is_setting_reset_on_new_day())
     {
      string today = (string)time_struct.year+(string)time_struct.mon+(string)time_struct.day;
      string RESET_DAY = (string)GetGlobalVariable("RESET_DAY");
      if(RESET_DAY != today)
        {
         init_stoc_h4_by_w1_ma10();
        }
     }
//-------------------------------------------------------------------------------
   bool allow_re_check_after_1m = false;
   int cur_minus = time_struct.min;
   int pre_check_minus = -1;
   if(GlobalVariableCheck("timer_one_minu"))
      pre_check_minus = (int)GlobalVariableGet("timer_one_minu");
   GlobalVariableSet("timer_one_minu",cur_minus);
   if(pre_check_minus != cur_minus)
     {
      allow_re_check_after_1m = true;
      Draw_Notice_Ma10D();
     }
//-------------------------------------------------------------------------------
   Draw_CurPrice_Line();
   ObjectSetString(0,BtnCloseAllTicket,OBJPROP_TEXT,"(All) X("+(string)OrdersTotal()+"L): "+get_acc_profit_percent());
//-------------------------------------------------------------------------------
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double PROFIT = AccountInfoDouble(ACCOUNT_PROFIT);
   bool is_80_percent_loss = (BALANCE*0.8+PROFIT < 0);
   if(is_80_percent_loss)
     {
      int size = getArraySymbolsSize();
      for(int index = 0; index < size; index++)
        {
         string temp_symbol = getSymbolAtIndex(index);
         ClosePosition(temp_symbol,TREND_BUY);
         ClosePosition(temp_symbol,TREND_SEL);
        }
      Draw_Notice_Ma10D();
     }
//-------------------------------------------------------------------------------
   double risk_1L = Risk_1L_By_Account_Balance();
   double risk_3L = risk_1L*3;
   if(allow_re_check_after_1m)
     {
      int size = getArraySymbolsSize();
      for(int index = 0; index < size; index++)
        {
         double total_profit = 0;
         //bool has_opened_today = false;
         int count_L = 0,count_limit = 0,count_buy = 0,count_sel = 0;
         string temp_symbol = getSymbolAtIndex(index);

         for(int i = PositionsTotal()-1; i >= 0; i--)
           {
            if(m_position.SelectByIndex(i))
              {
               if(is_same_symbol(m_position.Symbol(),temp_symbol))
                 {
                  string TREND_TYPE  = m_position.TypeDescription();
                  string comment = m_position.Comment();
                  string find_trend = (is_same_symbol(m_position.TypeDescription(),TREND_BUY))?TREND_BUY:(is_same_symbol(m_position.TypeDescription(),TREND_SEL))?TREND_SEL:"";
                  string rev_trading_trend = get_trend_reverse(find_trend);

                  double temp_profit = m_position.Profit()+m_position.Swap()+m_position.Commission();

                  bool is_3p_loss = (risk_3L+temp_profit < 0);

                  string msg = find_trend
                               +"    "+temp_symbol
                               +"    "+comment
                               +"    Profit: "+format_double_to_string(temp_profit,1)+"$";
                  //-----------------------------------------------------------------------------------------------------------
                  //TRIPLE ORDER
                  double bid = SymbolInfoDouble(temp_symbol,SYMBOL_BID);
                  double ask = SymbolInfoDouble(temp_symbol,SYMBOL_ASK);
                  double cur_price = (bid+ask)/2;

                  double AMP_X3L = get_AMP_SLW(temp_symbol);

                  int digits = (int)SymbolInfoInteger(temp_symbol,SYMBOL_DIGITS);

                  double open_price = m_position.PriceOpen();
                  double x3_price_buy = open_price-AMP_X3L*0.95;
                  double x3_price_sel = open_price+AMP_X3L*0.95;

                  if(m_position.StopLoss()<=0)
                     if((is_same_symbol(m_position.TypeDescription(),TREND_BUY) && (open_price-cur_price > AMP_X3L*0.95)) ||
                        (is_same_symbol(m_position.TypeDescription(),TREND_SEL) && (cur_price-open_price > AMP_X3L*0.95)))
                       {
                        ObjectSetString(0,BtnD10+temp_symbol,OBJPROP_FONT,"Arial Bold");
                        ObjectSetInteger(0,BtnD10+temp_symbol,OBJPROP_FONTSIZE,8);
                        ObjectSetInteger(0,BtnD10+temp_symbol,OBJPROP_COLOR,clrRed);

                        string trend_stoc_21h = get_trend_by_stoc2(temp_symbol,PERIOD_H1,21,7,7,1);

                        if((is_same_symbol(m_position.TypeDescription(),TREND_BUY) && trend_stoc_21h==TREND_BUY) ||
                           (is_same_symbol(m_position.TypeDescription(),TREND_SEL) && trend_stoc_21h==TREND_SEL))
                          {
                           CandleData arrHeiken_H1[];
                           get_arr_heiken(temp_symbol,PERIOD_H1,arrHeiken_H1,15,true);

                           if(trend_stoc_21h==arrHeiken_H1[0].trend_heiken &&
                              trend_stoc_21h==arrHeiken_H1[0].trend_by_ma10)
                             {
                              int count_tri = CountOccurrences(comment,MASK_COUNT_TRI);
                              if(count_tri < 2)
                                {
                                 string strTriple = "";
                                 for(int ti = 0; ti <= count_tri; ti++)
                                    strTriple += MASK_COUNT_TRI;

                                 string TREND_LIMIT=is_same_symbol(TREND_TYPE,TREND_BUY)?TREND_LIMIT_BUY:is_same_symbol(TREND_TYPE,TREND_SEL)?TREND_LIMIT_SEL:"";
                                 double price_limit=is_same_symbol(TREND_TYPE,TREND_BUY)?iLow(temp_symbol,PERIOD_W1,0):is_same_symbol(TREND_TYPE,TREND_SEL)?iHigh(temp_symbol,PERIOD_W1,0):0;
                                 double depreciation=MathAbs(ask-bid)*5;
                                 double new_sl=is_same_symbol(TREND_TYPE,TREND_BUY)?iLow(temp_symbol,PERIOD_W1,0)-depreciation:is_same_symbol(TREND_TYPE,TREND_SEL)?iHigh(temp_symbol,PERIOD_W1,0)+depreciation:0;

                                 if(TRIPLE_LIMIT_ORDER(temp_symbol,TREND_LIMIT,MathAbs(temp_profit),strTriple,price_limit))
                                    if(m_trade.PositionModify(m_position.Ticket(),new_sl,m_position.TakeProfit()))
                                      {
                                       OpenChartWindow(temp_symbol,PERIOD_D1);
                                       SendTelegramMessage(temp_symbol,"TRIPLE_ORDER","(SL AMP W1)_(TRIPLE ORDER):"+msg,true);
                                      }
                                }
                             }
                          }
                       }
                  //-----------------------------------------------------------------------------------------------------------
                  //TRAILING STOP
                  bool allow_trailing_stop_0 = false;
                  if(is_same_symbol(m_position.TypeDescription(),TREND_BUY)  && (cur_price-open_price > AMP_X3L*1.1))
                     allow_trailing_stop_0 = true;
                  if(is_same_symbol(m_position.TypeDescription(),TREND_SEL) && (open_price-cur_price > AMP_X3L*1.1))
                     allow_trailing_stop_0 = true;
                  if(allow_trailing_stop_0)
                    {
                     if(open_price*0.9 < open_price && open_price < open_price*1.1)
                       {
                        double price = (is_same_symbol(m_position.TypeDescription(),TREND_BUY))?bid:ask;
                        if(m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),m_position.TakeProfit()))
                          {
                           OpenChartWindow(temp_symbol,PERIOD_D1);
                           SendTelegramMessage(temp_symbol,"TRAILING_STOP","(TRAILING_STOP):"+msg,true);

                           Sleep(500);
                           continue;
                          }
                       }
                    }
                  //-----------------------------------------------------------------------------------------------------------
                  if(false)//is_3p_loss
                    {
                     if(is_same_symbol(m_position.TypeDescription(),TREND_BUY))
                        if(m_trade.PositionClose(m_position.Ticket()))
                           SendTelegramMessage(temp_symbol,"STOP_LOSS","STOP_LOSS(3L) "+msg,true);

                     if(is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                        if(m_trade.PositionClose(m_position.Ticket()))
                           SendTelegramMessage(temp_symbol,"STOP_LOSS","STOP_LOSS(3L) "+msg,true);

                     Draw_Notice_Ma10D();
                    }
                  //-----------------------------------------------------------------------------------------------------------
                  if(is_same_symbol(m_position.TypeDescription(),TREND_BUY))
                     count_buy += 1;

                  if(is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                     count_sel += 1;

                  if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) || is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                    {
                     count_L += 1;
                     total_profit += temp_profit;

                     //if(allow_re_check_after_1h)
                     //   has_opened_today = is_order_opened_today(temp_symbol);
                    }
                 }
              }
           }

         for(int i = OrdersTotal()-1; i >= 0; i--)
            if(m_order.SelectByIndex(i))
               if(is_same_symbol(m_order.Symbol(),temp_symbol))
                 {
                  count_limit += 1;
                 }
         //--------------------------------------------------------------------------------------------------------------
         if(count_L > 0)
           {
            string objName = BtnD10+temp_symbol;
            string buttonLabel = ObjectGetString(0,objName,OBJPROP_TEXT);
            string str_profit = (total_profit > 0?"+":"")+(string)(int)total_profit+to_percent(total_profit,1) ;
            if(count_buy > 0)
               str_profit += (string)count_buy+"B";
            if(count_sel > 0)
               str_profit += (string)count_sel+"S";

            if(count_limit > 0)
               str_profit += ".L"+(string) count_limit;

            bool is_wating_buy = GetGlobalVariable(BtnWaitToBuy+temp_symbol)==AUTO_TRADE_ON;
            bool is_wating_sel = GetGlobalVariable(BtnWaitToSel+temp_symbol)==AUTO_TRADE_ON;
            if(is_wating_buy)
               str_profit += ".wB";
            if(is_wating_sel)
               str_profit += ".wS";

            ObjectSetString(0,objName,OBJPROP_TEXT,ReplaceStringAfter(buttonLabel,"$",str_profit));
           }
         //--------------------------------------------------------------------------------------------------------------
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Notice_Ma10D()
  {
   printf("void Draw_Notice_Ma10D()");
   if(is_time_enter_the_market()==false)
      return;

   int x = 40;
   int y = 5;
   int btn_width = 210;
   int btn_heigh = 20;
   int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));
   int chart_1_2_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))/2;

   ObjectDelete(0,BtnTpSymbol);
   ObjectDelete(0,BtnCloseSymbol);
   ObjectDelete(0,BtnCloseLimit);
   int count = 0;
   string master_msg = "";
   string prefix_msg = "";
   string arrNoticeSymbols_D[];
   string arrNoticeSymbols_H4[];
   string strNoticeSymbols = "";
   string strTrade_Symbols_H4 = "";

   double risk_min = Risk_Min();
   double risk_1L = Risk_1L_By_Account_Balance();
//double fixSL = Fixed_SL_By_Account_Balance();

   ObjectDelete(0,"SL_BUY");
   ObjectDelete(0,"SL_SELL");

   int size = getArraySymbolsSize();
   double global_others_profit = 0,global_XAU_profit = 0,count_global_profit = 0,count_xau_profit = 0;
   for(int index = 0; index < size; index++)
     {
      string symbol = getSymbolAtIndex(index);
      bool is_cur_tab = is_same_symbol(symbol,Symbol());

      double AMP_DC1 = get_AMP_DCA(symbol,PERIOD_D1);
      double AMP_X3L = get_AMP_SLW(symbol);

      double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
      int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

      CandleData arrHeiken_W1[];
      get_arr_heiken(symbol,PERIOD_W1,arrHeiken_W1,15,true);

      CandleData arrHeiken_D1[];
      get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,45,true);

      CandleData arrHeiken_H4[];
      get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,15,true);

      CandleData arrHeiken_H1[];
      get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,15,true);

      string str_profit = "";
      string trading_trend = "";
      double min_entry_buy = 0,max_entry_sel = 0;
      double total_profit_cur_symbol = 0,total_profit_buy = 0,total_profit_sel = 0,tp_profit = 0;
      int count_L = 0,cur_count_limit_buy = 0,cur_count_limit_sel = 0,
          count_limit = 0,count_all_limit = 0,count_buy = 0,count_sel = 0,count_tp_1d = 0;

      count_all_limit = OrdersTotal();
      for(int i = OrdersTotal()-1; i >= 0; i--)
         if(m_order.SelectByIndex(i))
            if(is_same_symbol(m_order.Symbol(),symbol))
              {
               count_limit += 1;

               if(is_same_symbol(m_order.TypeDescription(),TREND_BUY))
                  cur_count_limit_buy += 1;
               if(is_same_symbol(m_order.TypeDescription(),TREND_SEL))
                  cur_count_limit_sel += 1;
              }

      for(int i = PositionsTotal()-1; i >= 0; i--)
         if(m_position.SelectByIndex(i))
           {
            string TREND_TYPE = m_position.TypeDescription();

            if(is_same_symbol(m_position.Symbol(),symbol))
              {
               string find_trend = (is_same_symbol(m_position.TypeDescription(),TREND_BUY))?TREND_BUY:(is_same_symbol(m_position.TypeDescription(),TREND_SEL))?TREND_SEL:"";
               double temp_profit = m_position.Profit()+m_position.Swap()+m_position.Commission();
               trading_trend += find_trend;
               total_profit_cur_symbol += temp_profit;

               if(is_cur_tab && ALLOW_DRAW_PROFIT)
                  create_label((string)m_position.Ticket(),TimeCurrent()+TIME_OF_ONE_W1_CANDLE,m_position.PriceOpen(),getShortName(find_trend)+" "+(string)(int)temp_profit+" $",temp_profit > 1?TREND_BUY:TREND_SEL);
               else
                  ObjectDelete(0,(string)m_position.Ticket());

               if(temp_profit > 0)
                 {
                  tp_profit += temp_profit;

                  if(is_same_symbol(symbol,"XAU")==false)
                    {
                     global_others_profit += temp_profit;
                     count_global_profit += 1;
                    }
                  else
                    {
                     global_XAU_profit += temp_profit;
                     count_xau_profit += 1;
                    }
                 }

               if(is_same_symbol(m_position.TypeDescription(),TREND_BUY))
                 {
                  count_buy += 1;
                  total_profit_buy += temp_profit;

                  if(min_entry_buy==0 || min_entry_buy > m_position.PriceOpen())
                     min_entry_buy = m_position.PriceOpen();
                 }

               if(is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                 {
                  count_sel += 1;
                  total_profit_sel += temp_profit;

                  if(max_entry_sel==0 || max_entry_sel < m_position.PriceOpen())
                     max_entry_sel = m_position.PriceOpen();
                 }

               if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) || is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                  count_L += 1;

               if(is_same_symbol(m_position.Comment(),MASK_TP1D))
                  if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) || is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                     count_tp_1d += 1;

               if(is_cur_tab && ALLOW_DRAW_PROFIT)
                  if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) || is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                    {
                     int idx = (is_same_symbol(m_position.TypeDescription(),TREND_BUY))?count_buy:count_sel;

                     //double tp_price = (is_same_symbol(m_position.TypeDescription(),TREND_BUY))?m_position.PriceOpen()+AMP_X3L*2:m_position.PriceOpen()-AMP_X3L*2;
                     //create_label("tp_"+(string)m_position.Ticket(),TimeCurrent(),tp_price,"--------------------tp."+(string)idx,"");

                     double x3_price = (is_same_symbol(m_position.TypeDescription(),TREND_BUY))?m_position.PriceOpen()-AMP_X3L:m_position.PriceOpen()+AMP_X3L;
                     create_label("x3_"+(string)m_position.Ticket(),TimeCurrent(),x3_price,"-------------------------------X3."+(string)idx,"");
                    }
              }

           }
      //----------------------------------------------------------------------------------
      if(is_cur_tab && min_entry_buy > 0)
         create_label("amp_d1_buy",TimeCurrent(), min_entry_buy-AMP_DC1,"----------------------------------------",TREND_SEL);

      if(is_cur_tab && max_entry_sel > 0)
         create_label("amp_d1_sel",TimeCurrent(), min_entry_buy+AMP_DC1,"----------------------------------------",TREND_SEL);

      string strCountBSL = "";
      if(count_buy > 0)
         strCountBSL += (string)count_buy+"B";
      if(count_sel > 0)
         strCountBSL += (string)count_sel+"S";

      string strCountLimit = "";
      if(cur_count_limit_buy > 0)
         strCountLimit += ".LB"+(string)cur_count_limit_buy;
      if(cur_count_limit_sel > 0)
         strCountLimit += ".LS"+(string)cur_count_limit_sel;
      strCountBSL += strCountLimit;

      if(count_L > 0)
         str_profit = " $"+(total_profit_cur_symbol > 0?"+":"")+(string)(int)total_profit_cur_symbol+to_percent(total_profit_cur_symbol,1)+" ";

      if(is_cur_tab && (cur_count_limit_buy+cur_count_limit_sel) > 0)
         createButton(BtnCloseLimit,symbol+" Close "+(string) strCountLimit+"",5,chart_heigh-95,BTN_SEND_MSG_WIDTH,20,clrBlack,clrWhite,7);

      if(count_all_limit > 0)
         createButton(BtnCloseAllLimit,"Close All "+(string) count_all_limit+" Limit",5,chart_heigh-120,BTN_SEND_MSG_WIDTH,20,clrBlack,clrWhite,7);

      string trend_by_ma10d_vs_ma10w = arrHeiken_D1[0].ma10 > arrHeiken_D1[0].ma10?TREND_BUY:TREND_SEL;

      string trend_by_macd_d1=get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_D1);

      int count_d10 = arrHeiken_D1[0].count_ma10;
      int count_hei_d1 = arrHeiken_D1[0].count_heiken;
      int count_hei_h4 = arrHeiken_H4[0].count_heiken;
      int count_hei_h1 = arrHeiken_H1[0].count_heiken;

      string trend_by_ma10_w1 = arrHeiken_W1[0].trend_by_ma10;
      string trend_by_ma10_d1 = arrHeiken_D1[0].trend_by_ma10;
      string trend_by_ma10_h4 = arrHeiken_H4[0].trend_by_ma10;

      string trend_heiken_d1 = arrHeiken_D1[0].trend_heiken;
      string trend_heiken_h4 = arrHeiken_H4[0].trend_heiken;
      string trend_heiken_h1 = arrHeiken_H1[0].trend_heiken;
      string trend_ma10vs20_d1 = arrHeiken_D1[0].trend_ma10vs20;

      string trend_zero_h4 = get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_H4);
      string trend_zero_h1 = get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_H1);
      //----------------------------------------------------------------------------------
      //BtnSendNoticeHei    BtnSendNoticeMacd    BtnSendNoticeStoc    BtnSendNotice8020
      //----------------------------------------------------------------------------------
      string key_d1_buy = (string)PERIOD_D1+(string)1;//OP_BUY;
      string key_d1_sel = (string)PERIOD_D1+(string)0;//OP_SELL;
      string key_h4_buy = (string)PERIOD_H4+(string)1;//OP_BUY;
      string key_h4_sel = (string)PERIOD_H4+(string)0;//OP_SELL;
      string key_h1_buy = (string)PERIOD_H1+(string)1;//OP_BUY;
      string key_h1_sel = (string)PERIOD_H1+(string)0;//OP_SELL;

        {
         string lblNotifyH4 = "";
         if(trend_by_ma10_h4==trend_by_ma10_w1 &&
            trend_heiken_h4==trend_by_ma10_w1 &&
            (count_hei_h4 <= 3 || arrHeiken_H4[0].count_ma10 <= 3))

            lblNotifyH4 += " (W.H4)";

         if(trend_heiken_h4==trend_zero_h4 &&
            trend_heiken_h4==trend_zero_h1 &&
            trend_heiken_h4==arrHeiken_D1[1].trend_by_ma10
           )
            lblNotifyH4 += " Macd.DHH";

         if(lblNotifyH4!= "")
           {
            int num_h4 = ArraySize(arrNoticeSymbols_H4);
            ArrayResize(arrNoticeSymbols_H4,num_h4+1);

            string lblH4 = str_profit
                           +lblNotifyH4
                           +"."+trend_heiken_h4+".C"+(string)arrHeiken_H4[0].count_ma10
                           +"~"+symbol;

            arrNoticeSymbols_H4[num_h4] = lblH4;
           }
        }

      if(trend_by_ma10_d1!=TREND_BUY)
         GlobalVariableSet(BtnWaitToBuy+symbol,AUTO_TRADE_OFF);

      if(trend_by_ma10_d1!=TREND_SEL)
         GlobalVariableSet(BtnWaitToSel+symbol,AUTO_TRADE_OFF);

      bool is_wating_buy = GetGlobalVariable(BtnWaitToBuy+symbol)==AUTO_TRADE_ON;
      bool is_wating_sel = GetGlobalVariable(BtnWaitToSel+symbol)==AUTO_TRADE_ON;

      if((is_wating_buy && trend_by_ma10_d1==TREND_BUY) || (is_wating_sel && trend_by_ma10_d1==TREND_SEL))
        {
         if(is_same_symbol(get_trend_allow_trade_now_by_stoc(symbol,PERIOD_M5),trend_by_ma10_d1))
            if(is_allow_trade_by_macd_extremes(symbol,PERIOD_M5,trend_by_ma10_d1))
               if(Check_Open_Position_By_Stoc(symbol,trend_by_ma10_d1,MASK_AUTO_TRADE+"(8020)M5"))
                 {
                  if(trend_by_ma10_d1==TREND_BUY)
                     GlobalVariableSet(BtnWaitToBuy+symbol,AUTO_TRADE_OFF);

                  if(trend_by_ma10_d1==TREND_SEL)
                     GlobalVariableSet(BtnWaitToSel+symbol,AUTO_TRADE_OFF);

                  OpenChartWindow(symbol,PERIOD_D1);

                  return;
                 }
        }

      if(is_wating_buy)
         strCountBSL += ".wB";
      if(is_wating_sel)
         strCountBSL += ".wS";
      //----------------------------------------------------------------------------------
      if(
         (count_buy > 0 && is_same_symbol(trend_by_ma10_d1,TREND_SEL)) ||
         (count_sel > 0 && is_same_symbol(trend_by_ma10_d1,TREND_BUY))
      )
        {
         int auto_exit = (int)GetGlobalVariable(BtnOptionAutoExit+symbol);
         if(auto_exit != AUTO_TRADE_ON)
            GlobalVariableSet(BtnOptionAutoExit+symbol,(double)AUTO_TRADE_ON);
        }
      //----------------------------------------------------------------------------------
      color clrD10 = trend_by_ma10_d1==TREND_BUY?clrBlue:clrRed;

      string lblWeek = "";
      bool pass_count_cond_d10 = (count_d10 <= 3);

      string lblBtn10 = symbol;
      if(count_L > 0)
         lblBtn10 += str_profit+" ";
      lblBtn10 += strCountBSL;


      bool IS_CYCLE_BUY = false;
      bool IS_CYCLE_SEL = false;

      if(trend_by_ma10_d1==TREND_BUY)
         IS_CYCLE_BUY = true;

      if(trend_by_ma10_d1==TREND_SEL)
         IS_CYCLE_SEL = true;

      btn_heigh = index==0?80:20;
      if(index==0 && size < 22)
         btn_heigh = 80;
      if(index==0 && size >= 22)
         btn_heigh = 110;

      if(index==0)
         lblBtn10 += " "+format_double_to_string(SymbolInfoDouble(symbol,SYMBOL_BID),1)+"$";
      if(index==8)
        {count = 0; x = btn_width+45; y = 35; btn_heigh = 20;}
      if(index==15)
        {count = 0; x = btn_width+45; y = 65; btn_heigh = 20;}
      if(index==21)
        {count = 0; x = btn_width+45; y = 95; btn_heigh = 20;}
      //----------------------------------------------------------------------------------------------------
      color clrBackground = clrWhite;
      color clrText = (total_profit_cur_symbol+risk_1L<0) || (count_L >=3)?clrRed:clrBlack;

      if((count_buy>0 && trend_by_ma10_d1==TREND_SEL) ||
         (count_sel>0 && trend_by_ma10_d1==TREND_BUY))
         clrBackground = clrMistyRose;
      if(is_cur_tab)
         clrBackground = clrLightGreen;

      if(trend_by_ma10_w1==trend_by_ma10_d1 && trend_by_ma10_d1==trend_zero_h4)
         lblBtn10 = " {WDH4."+getShortName(arrHeiken_W1[0].trend_by_ma10)+"}"+lblBtn10;
      else
         if(trend_by_ma10_d1==trend_zero_h4)
            lblBtn10 = " {DH4."+getShortName(arrHeiken_D1[1].trend_by_ma10)+"}"+lblBtn10;

      createButton(BtnD10+symbol,lblBtn10,x+(btn_width+5)*count,is_cur_tab && (index > 0)?y-7:y,btn_width
                   ,(index==0)?btn_heigh:is_cur_tab?btn_heigh+15:btn_heigh,clrText,clrBackground,6,4);

      if(is_cur_tab)
         ObjectSetString(0,BtnD10+symbol,OBJPROP_FONT,"Arial Bold");

      count += 1;
      //----------------------------------------------------------------------------------------------------
      double vol = 0;
      if(is_cur_tab)
        {
         double price = (bid+ask)/2;

         Comment(GetComments());
         ObjectSetString(0,BtnD10+symbol,OBJPROP_FONT,"Arial Bold");
         ObjectSetInteger(0,BtnD10+symbol,OBJPROP_COLOR,clrText);

         if(trend_heiken_d1==trend_by_ma10_d1)
            create_label("Only_Trade",TimeCurrent()+TIME_OF_ONE_W1_CANDLE,price,"                "+trend_by_ma10_d1+" ",trend_by_ma10_d1,false,10,true);

         create_trend_line("SL_B",TimeCurrent()-TIME_OF_ONE_W1_CANDLE,price-AMP_X3L,TimeCurrent()+TIME_OF_ONE_W1_CANDLE,price-AMP_X3L,clrRed);
         create_trend_line("SL_S",TimeCurrent()-TIME_OF_ONE_W1_CANDLE,price+AMP_X3L,TimeCurrent()+TIME_OF_ONE_W1_CANDLE,price+AMP_X3L,clrRed);

         createButton(BtnTpDay_06_07,"D 06 07",10,chart_1_2_heigh-25*2,60,20,clrBlack,GetGlobalVariable(BtnTpDay_06_07+"_"+Symbol()) > 0?clrActiveBtn:clrWhite,7);
         createButton(BtnTpDay_13_14,"D 13 14",10,chart_1_2_heigh-25*1,60,20,clrBlack,GetGlobalVariable(BtnTpDay_13_14+"_"+Symbol()) > 0?clrActiveBtn:clrWhite,7);
         createButton(BtnTpDay_20_21,"D 20 21",10,chart_1_2_heigh-25*0,60,20,clrBlack,GetGlobalVariable(BtnTpDay_20_21+"_"+Symbol()) > 0?clrActiveBtn:clrWhite,7);
         createButton(BtnTpDay_27_28,"D 27 28",10,chart_1_2_heigh+25*1,60,20,clrBlack,GetGlobalVariable(BtnTpDay_27_28+"_"+Symbol()) > 0?clrActiveBtn:clrWhite,7);
         createButton(BtnTpDay_34_35,"D 34 35",10,chart_1_2_heigh+25*2,60,20,clrBlack,GetGlobalVariable(BtnTpDay_34_35+"_"+Symbol()) > 0?clrActiveBtn:clrWhite,7);

         vol = calc_volume_by_amp(symbol,AMP_X3L,risk_1L);
         string trend_rev_d10 = get_trend_reverse(trend_by_ma10_d1);
         int _x = int(chart_width*1.5/3)-150;
         string lblBtnD1 = BOT_SHORT_NM+" Ma10."+trend_by_ma10_d1+" c"+(string)count_d10+" "+symbol+" "+(string)RISK_BY_PERCENT+"%("+(string)(int) risk_1L+"$) "+format_double_to_string(vol,2)+" lot. L"+strCountBSL;
         createButton(BtnTradeByMa10D,lblBtnD1,_x,(trend_by_ma10_d1==TREND_BUY?chart_heigh-50:50),350,30,trend_by_ma10_d1==TREND_BUY?clrBlue:clrFireBrick,trend_by_ma10_d1==TREND_BUY?clrActiveBtn:clrMistyRose,7);

         //if(is_same_symbol(trend_heiken_d1+arrHeiken_W1[0].trend_heiken+arrHeiken_W1[0].trend_by_ma05+arrHeiken_W1[0].trend_by_ma10,trend_rev_d10) ||
         //   (trend_rev_d10==trend_by_ma10_h4 && (trend_rev_d10==trend_heiken_h4 || trend_rev_d10==trend_zero_h4)))
           {
            string lblRevD1 = BOT_SHORT_NM+" "+MASK_RevD10+" "+trend_rev_d10+" "+symbol+" "+(string)
                              RISK_BY_PERCENT+"%("+(string)(int) risk_1L+"$) "+format_double_to_string(vol,2)+" lot. L"+strCountBSL;
            createButton(BtnTradeByRevMa10D,lblRevD1,_x,(trend_by_ma10_d1==TREND_BUY? 50:chart_heigh-50),350,30,clrBlack,clrLightGray,7);
           }

         if(trend_by_ma10_d1==TREND_BUY)
            createButton(BtnWaitToBuy,"(WDH4) Wait.B.M5"+(count_buy>0?" L"+(string)count_buy+"B":""),_x+350+10,chart_heigh-50,135,30,clrBlack,is_wating_buy?clrActiveBtn:clrLightGray,7);

         if(trend_by_ma10_d1==TREND_SEL)
            createButton(BtnWaitToSel,"(WDH4) Wait.S.M5"+(count_sel>0?" L"+(string)count_sel+"S":""),_x+350+10,50,            135,30,clrBlack,is_wating_sel?clrMistyRose:clrLightGray,7);

         string strLblTP = "(Close) ";
         if(count_buy > 0)
            strLblTP += (string)count_buy+"B";
         if(count_sel > 0)
            strLblTP += (string)count_sel+"S";
         strLblTP += " "+symbol+" $"+(total_profit_cur_symbol>0?"+":"")+(string)(int) total_profit_cur_symbol+" ";

         if(count_L > 0)
           {
            if(tp_profit > 1)
               createButton(BtnTpSymbol,"(TP) "+symbol+" $+"+(string)(int)tp_profit,5,chart_heigh-75,BTN_SEND_MSG_WIDTH,20,clrBlue,clrWhite,7);

            createButton(BtnCloseSymbol,strLblTP,5,chart_heigh-25,BTN_SEND_MSG_WIDTH,20,
                         total_profit_cur_symbol > 0?clrBlue:clrBlack,
                         total_profit_cur_symbol > 0?clrWhite:clrLightGray,7);
           }
        }
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
        {
           {
            string Notice_Symbol = (string) GetGlobalVariable(BtnSendNoticeHei+symbol);
            if(is_same_symbol(Notice_Symbol,key_d1_buy) && is_same_symbol(Notice_Symbol,key_d1_sel))
               GlobalVariableSet(BtnSendNoticeHei+symbol,-1);
            else
               if(is_same_symbol(Notice_Symbol,key_d1_buy) || is_same_symbol(Notice_Symbol,key_d1_sel))
                 {
                  string find_trend = is_same_symbol(Notice_Symbol,key_d1_buy)? TREND_BUY :
                                      is_same_symbol(Notice_Symbol,key_d1_sel)?TREND_SEL:"";

                  if(find_trend==arrHeiken_D1[0].trend_by_ma10 &&
                     find_trend==arrHeiken_D1[0].trend_heiken &&
                     find_trend==arrHeiken_H4[0].trend_heiken &&
                     find_trend==arrHeiken_H1[0].trend_heiken)
                    {
                     StringReplace(Notice_Symbol,key_d1_buy,"");
                     StringReplace(Notice_Symbol,key_d1_sel,"");
                     GlobalVariableSet(BtnSendNoticeHei+symbol,(double) Notice_Symbol);

                     SendTelegramMessage(symbol,find_trend,"(Ma.Hei.D1+H4H1) "+BtnSendNoticeHei+symbol+" D1 "+find_trend,true);
                     PushMessage(get_vntime() + " " + symbol + " D1" + find_trend);

                     OpenChartWindow(symbol,PERIOD_D1);
                    }
                 }
            //----------------------------------------------------------------------------------
            if(is_same_symbol(Notice_Symbol,key_h4_buy) && is_same_symbol(Notice_Symbol,key_h4_sel))
               GlobalVariableSet(BtnSendNoticeHei+symbol,-1);
            else
               if(is_same_symbol(Notice_Symbol,key_h4_buy) || is_same_symbol(Notice_Symbol,key_h4_sel))
                 {
                  bool allow_send_h4 = false;
                  string find_trend = is_same_symbol(Notice_Symbol,key_h4_buy)? TREND_BUY:is_same_symbol(Notice_Symbol,key_h4_sel)?TREND_SEL:"";

                  if(find_trend==arrHeiken_H4[0].trend_by_ma10 &&
                     find_trend==arrHeiken_H4[0].trend_heiken &&
                     find_trend==arrHeiken_H1[0].trend_heiken)
                     allow_send_h4 = true;

                  if(allow_send_h4)
                    {
                     StringReplace(Notice_Symbol,key_h4_buy,"");
                     StringReplace(Notice_Symbol,key_h4_sel,"");
                     GlobalVariableSet(BtnSendNoticeHei+symbol,(double) Notice_Symbol);

                     SendTelegramMessage(symbol,find_trend,"(Ma.Hei.H4+H1) "+BtnSendNoticeHei+symbol+" H4 "+find_trend,true);
                     PushMessage(get_vntime() + " " + symbol + " H4" + find_trend);

                     OpenChartWindow(symbol,PERIOD_D1);
                    }
                 }
            //----------------------------------------------------------------------------------
            if(is_same_symbol(Notice_Symbol,key_h1_buy) && is_same_symbol(Notice_Symbol,key_h1_sel))
               GlobalVariableSet(BtnSendNoticeHei+symbol,-1);
            else
               if(is_same_symbol(Notice_Symbol,key_h1_buy) || is_same_symbol(Notice_Symbol,key_h1_sel))
                 {
                  bool allow_send_h1 = false;
                  string find_trend = is_same_symbol(Notice_Symbol,key_h1_buy)? TREND_BUY:is_same_symbol(Notice_Symbol,key_h1_sel)?TREND_SEL:"";

                  if(find_trend==arrHeiken_H1[0].trend_by_ma10 &&
                     find_trend==arrHeiken_H1[0].trend_heiken)
                     allow_send_h1 = true;

                  if(allow_send_h1)
                    {
                     StringReplace(Notice_Symbol,key_h1_buy,"");
                     StringReplace(Notice_Symbol,key_h1_sel,"");
                     GlobalVariableSet(BtnSendNoticeHei+symbol,(double) Notice_Symbol);

                     SendTelegramMessage(symbol,find_trend,"(Ma.Hei.H1) "+BtnSendNoticeHei+symbol+" H1 "+find_trend,true);
                     PushMessage(get_vntime() + " " + symbol + " H1" + find_trend);

                     OpenChartWindow(symbol,PERIOD_D1);
                    }
                 }
           }
         //----------------------------------------------------------------------------------
           {
            string Notice_Macd = (string) GetGlobalVariable(BtnSendNoticeMacd+symbol);
            if(is_same_symbol(Notice_Macd,key_d1_buy) && is_same_symbol(Notice_Macd,key_d1_sel))
               GlobalVariableSet(BtnSendNoticeMacd+symbol,-1);
            else
               if(is_same_symbol(Notice_Macd,key_d1_buy) || is_same_symbol(Notice_Macd,key_d1_sel))
                 {
                  string find_trend = is_same_symbol(Notice_Macd,key_d1_buy)? TREND_BUY :
                                      is_same_symbol(Notice_Macd,key_d1_sel)?TREND_SEL:"";

                  if(find_trend==arrHeiken_D1[0].trend_heiken &&
                     find_trend==get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_D1))
                    {
                     StringReplace(Notice_Macd,key_d1_buy,"");
                     StringReplace(Notice_Macd,key_d1_sel,"");
                     GlobalVariableSet(BtnSendNoticeMacd+symbol,(double) Notice_Macd);

                     SendTelegramMessage(symbol,find_trend,"(Macd) "+BtnSendNoticeMacd+symbol+" D1 "+find_trend,true);
                     PushMessage(get_vntime() + " " + symbol + " D1" + find_trend);

                     OpenChartWindow(symbol,PERIOD_D1);
                    }
                 }
            //----------------------------------------------------------------------------------
            if(is_same_symbol(Notice_Macd,key_h4_buy) && is_same_symbol(Notice_Macd,key_h4_sel))
               GlobalVariableSet(BtnSendNoticeMacd+symbol,-1);
            else
               if(is_same_symbol(Notice_Macd,key_h4_buy) || is_same_symbol(Notice_Macd,key_h4_sel))
                 {
                  bool allow_send_h4 = false;
                  string find_trend = is_same_symbol(Notice_Macd,key_h4_buy)? TREND_BUY:is_same_symbol(Notice_Macd,key_h4_sel)?TREND_SEL:"";

                  if(find_trend==arrHeiken_H4[0].trend_heiken &&
                     find_trend==get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_H4))
                     allow_send_h4 = true;

                  if(allow_send_h4)
                    {
                     StringReplace(Notice_Macd,key_h4_buy,"");
                     StringReplace(Notice_Macd,key_h4_sel,"");
                     GlobalVariableSet(BtnSendNoticeMacd+symbol,(double) Notice_Macd);

                     SendTelegramMessage(symbol,find_trend,"(Macd) "+BtnSendNoticeMacd+symbol+" H4 "+find_trend,true);
                     PushMessage(get_vntime() + " " + symbol + " H4" + find_trend);

                     OpenChartWindow(symbol,PERIOD_D1);
                    }
                 }
            //----------------------------------------------------------------------------------
            if(is_same_symbol(Notice_Macd,key_h1_buy) && is_same_symbol(Notice_Macd,key_h1_sel))
               GlobalVariableSet(BtnSendNoticeMacd+symbol,-1);
            else
               if(is_same_symbol(Notice_Macd,key_h1_buy) || is_same_symbol(Notice_Macd,key_h1_sel))
                 {
                  bool allow_send_h1 = false;
                  string find_trend = is_same_symbol(Notice_Macd,key_h1_buy)? TREND_BUY:is_same_symbol(Notice_Macd,key_h1_sel)?TREND_SEL:"";

                  if(find_trend==arrHeiken_H1[0].trend_heiken &&
                     find_trend==get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_H1))
                     allow_send_h1 = true;

                  if(allow_send_h1)
                    {
                     StringReplace(Notice_Macd,key_h1_buy,"");
                     StringReplace(Notice_Macd,key_h1_sel,"");
                     GlobalVariableSet(BtnSendNoticeMacd+symbol,(double) Notice_Macd);

                     SendTelegramMessage(symbol,find_trend,"(Macd) "+BtnSendNoticeMacd+symbol+" H1 "+find_trend,true);
                     PushMessage(get_vntime() + " " + symbol + " H1" + find_trend);

                     OpenChartWindow(symbol,PERIOD_D1);
                    }
                 }
           }
         //----------------------------------------------------------------------------------
           {
            string Notice_Stoc = (string) GetGlobalVariable(BtnSendNoticeStoc+symbol);

            //----------------------------------------------------------------------------------
            if(is_same_symbol(Notice_Stoc,key_h4_buy) && is_same_symbol(Notice_Stoc,key_h4_sel))
               GlobalVariableSet(BtnSendNoticeStoc+symbol,-1);
            else
               if(is_same_symbol(Notice_Stoc,key_h4_buy) || is_same_symbol(Notice_Stoc,key_h4_sel))
                 {
                  bool allow_send_h4 = false;
                  string find_trend = is_same_symbol(Notice_Stoc,key_h4_buy)? TREND_BUY:is_same_symbol(Notice_Stoc,key_h4_sel)?TREND_SEL:"";

                  if(find_trend==trend_by_ma10_w1 &&
                     find_trend==arrHeiken_H4[0].trend_heiken &&
                     find_trend==trend_by_ma10_h4)
                     allow_send_h4 = true;

                  if(allow_send_h4)
                    {
                     StringReplace(Notice_Stoc,key_h4_buy,"");
                     StringReplace(Notice_Stoc,key_h4_sel,"");
                     GlobalVariableSet(BtnSendNoticeStoc+symbol,(double) Notice_Stoc);

                     PushMessage(get_vntime()+" "+symbol+" "+trend_by_ma10_d1);
                    }
                 }
            //----------------------------------------------------------------------------------
            if(is_same_symbol(Notice_Stoc,key_h1_buy) && is_same_symbol(Notice_Stoc,key_h1_sel))
               GlobalVariableSet(BtnSendNoticeStoc+symbol,-1);
            else
               if(is_same_symbol(Notice_Stoc,key_h1_buy) || is_same_symbol(Notice_Stoc,key_h1_sel))
                 {
                  bool allow_send_h1 = false;
                  string find_trend = is_same_symbol(Notice_Stoc,key_h1_buy)? TREND_BUY:is_same_symbol(Notice_Stoc,key_h1_sel)?TREND_SEL:"";

                  string trend_stoc_21h1 = get_trend_by_stoc2(symbol,PERIOD_H1,21,7,7,0);

                  if(find_trend==arrHeiken_H1[0].trend_heiken &&
                     find_trend==trend_stoc_21h1)
                     allow_send_h1 = true;

                  if(allow_send_h1)
                    {
                     StringReplace(Notice_Stoc,key_h1_buy,"");
                     StringReplace(Notice_Stoc,key_h1_sel,"");
                     GlobalVariableSet(BtnSendNoticeStoc+symbol,(double) Notice_Stoc);

                     SendTelegramMessage(symbol,find_trend,"(Stoc21) "+BtnSendNoticeStoc+symbol+" H1 "+find_trend,true);
                     PushMessage(get_vntime() + " " + symbol + " H1" + find_trend);

                     OpenChartWindow(symbol,PERIOD_D1);
                    }
                 }
           }
        }
      //----------------------------------------------------------------------------------
        {
         string notice_d1 = "";
         //if(1 <= count_hei_d1 && count_hei_d1 <= 3)
         //   notice_d1 = " Hei "+getShortName(trend_heiken_d1)+"."+(string) count_hei_d1+" ~"+symbol;
         //else
         if(1 <= count_d10 && count_d10 <= 3)
            notice_d1 =strCountBSL+ " Ma "+getShortName(trend_by_ma10_d1)+"."+(string) count_d10+" ~"+symbol;

         if(notice_d1 != "")
           {
            int num_symbols = ArraySize(arrNoticeSymbols_D);
            ArrayResize(arrNoticeSymbols_D,num_symbols+1);

            strNoticeSymbols += symbol+".";
            arrNoticeSymbols_D[num_symbols] = notice_d1;
           }
        }
     }
//----------------------------------------------------------------------------------
   ObjectDelete(1,BtnTpOthersPositive);
   if(global_others_profit > 0)
      createButton(BtnTpOthersPositive,"(Oth)TP("+(string)(int) count_global_profit+"L): "+get_profit_percent(global_others_profit),5,120,BTN_SEND_MSG_WIDTH,20,clrBlack,clrActiveBtn,6);

   ObjectDelete(1,BtnTpXauPositive);
   if(global_XAU_profit > 0)
      createButton(BtnTpXauPositive,"(Xau)TP("+(string)(int) count_xau_profit+"L): "+get_profit_percent(global_XAU_profit),   5,150,BTN_SEND_MSG_WIDTH,20,clrBlack,clrActiveBtn,6);
//----------------------------------------------------------------------------------
   for(int index = 0; index < size; index++)
      ObjectDelete(0,BtnNoticeH4+getSymbolAtIndex(index));

   int row_index = 0;
   for(int index = 0; index < ArraySize(arrNoticeSymbols_H4); index++)
     {
      string strLable = arrNoticeSymbols_H4[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = clrBlack;//is_same_symbol(strLable,"$+")?clrBlue:is_same_symbol(strLable,"$-")?clrFireBrick:clrBlack;
      color clrBg = is_same_symbol(symbol,Symbol())?clrLightGreen:clrWhite;
      //is_same_symbol(strLable,MASK_DANGER)?clrWhiteSmoke :
      //is_same_symbol(strLable,"$")?clrWhiteSmoke:clrWhite;

      createButton(BtnNoticeH4+symbol,strLable,165,50+row_index*25,300,20,clrText,clrBg,7);
      row_index += 1;
     }
//----------------------------------------------------------------------------------
   int count_row = 0;
   int count_col = 0;
   for(int index = 0; index < size; index++)
      ObjectDelete(0,BtnNoticeD1+getSymbolAtIndex(index));

   btn_width = 150;
   for(int index = 0; index < ArraySize(arrNoticeSymbols_D); index++)
     {
      string strLable = arrNoticeSymbols_D[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable,"$+")?clrBlue:clrBlack;
      color clrBg = is_same_symbol(symbol,Symbol())?clrActiveBtn :
                    is_same_symbol(strLable,"$")?clrLightGray:clrPowderBlue;

      createButton(BtnNoticeD1+symbol,strLable,(btn_width+5)*index+10,125,btn_width,15,clrText,clrBg,7,4);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_AMP_DCA(string symbol,ENUM_TIMEFRAMES TIMEFRAME)
  {
   double amp_w1,amp_d1,amp_h4,amp_grid_L100;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_grid_L100);
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   if(TIMEFRAME==PERIOD_W1)
      return NormalizeDouble(amp_w1,digits);

   if(TIMEFRAME==PERIOD_D1)
      return NormalizeDouble(amp_d1,digits);

   if(TIMEFRAME==PERIOD_H4)
      return NormalizeDouble(amp_h4,digits);

   if(TIMEFRAME==PERIOD_H1)
      return NormalizeDouble(amp_h4/2,digits);

   return amp_w1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_AMP_SLW(string symbol)
  {
   double amp_w1,amp_d1,amp_h4,amp_grid_L100;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_grid_L100);
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   return NormalizeDouble(MathMax(amp_w1,amp_d1*2.5),digits);
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
   string            trend_ma3_vs_ma5;
   int               count_ma3_vs_ma5;
   string            trend_seq;
   double            ma50;
   string            trend_ma10vs20;
   string            trend_ma5vs10;

                     CandleData()
     {
      time = 0;
      open = 0.0;
      high = 0.0;
      low = 0.0;
      close = 0.0;
      trend_heiken = "";
      count_heiken = 0;
      ma10 = 0;
      trend_by_ma10 = "";
      count_ma10 = 0;
      trend_vector_ma10 = "";
      trend_by_ma05 = "";
      trend_ma3_vs_ma5 = "";
      count_ma3_vs_ma5 = 0;
      trend_seq = "";
      ma50 = 0;
      trend_ma10vs20 = "";
      trend_ma5vs10 = "";
     }

                     CandleData(
      datetime t,double o,double h,double l,double c,
      string trend_heiken_,int count_heiken_,
      double ma10_,string trend_by_ma10_,int count_ma10_,string trend_vector_ma10_,
      string trend_by_ma05_,string trend_ma3_vs_ma5_,int count_ma3_vs_ma5_,
      string trend_seq_,double ma50_,string trend_ma10vs20_,string trend_ma5vs10_)
     {
      time = t;
      open = o;
      high = h;
      low = l;
      close = c;
      trend_heiken = trend_heiken_;
      count_heiken = count_heiken_;
      ma10 = ma10_;
      trend_by_ma10 = trend_by_ma10_;
      count_ma10 = count_ma10_;
      trend_vector_ma10 = trend_vector_ma10_;
      trend_by_ma05 = trend_by_ma05_;
      trend_ma3_vs_ma5 = trend_ma3_vs_ma5_;
      count_ma3_vs_ma5 = count_ma3_vs_ma5_;
      trend_seq = trend_seq_;
      ma50 = ma50_;
      trend_ma10vs20 = trend_ma10vs20_;
      trend_ma5vs10 = trend_ma5vs10_;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_trend_stoc(string symbol,ENUM_TIMEFRAMES TIMEFRAME,int inK,int inD,int inS,int sub_window,int width_main)
  {
   string TF = get_time_frame_name(TIMEFRAME);
   string strKDS = "("+append1Zero(inK)+","+append1Zero(inD)+","+append1Zero(inS)+")";
   string prefix = strKDS+TF+(string)sub_window;

   int handle_iStochastic = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH);
   if(handle_iStochastic==INVALID_HANDLE)
      return;

   double K[],D[];
   ArraySetAsSeries(K,true);
   ArraySetAsSeries(D,true);
   CopyBuffer(handle_iStochastic,0,0,LIMIT_D+5,K);
   CopyBuffer(handle_iStochastic,1,0,LIMIT_D+5,D);

   if((ArraySize(K)<LIMIT_D) || (ArraySize(D)<LIMIT_D))
      return;

   for(int i = 0; i < LIMIT_D; i++)
     {
      datetime time_i = (i==0)?TimeCurrent():iTime(symbol,TIMEFRAME,i);
      datetime time_pre_i = iTime(symbol,TIMEFRAME,i+1);

      double main_i = K[i];
      double sign_i = D[i];

      double main_pre_i = K[i+1];
      double sign_pre_i = D[i+1];

      string trend_di = (main_i > sign_i?TREND_BUY:TREND_SEL);
      color  color_di = trend_di==TREND_BUY?clrTeal:clrFireBrick;

      string nm_main = "stoc"+strKDS+"main."+TF+"i"+appendZero100(i);
      string nm_sign = "stoc"+strKDS+"sign."+TF+"i"+appendZero100(i);

      create_trend_line(nm_main,time_i,main_i,time_pre_i,main_pre_i,color_di,STYLE_SOLID,width_main,false,false,true,false,sub_window);
      if(TIMEFRAME==Period())
         create_trend_line(nm_sign,time_i,sign_i,time_pre_i,sign_pre_i,color_di,STYLE_SOLID,width_main,false,false,true,false,sub_window);
      else
         ObjectDelete(0,nm_sign);

      if(i==0)
        {
         int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)-2;
         int x_start = (int)(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,sub_window));
         int y_start = (int)(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,sub_window));
         double stoc = (main_i+main_i+sign_i)/3;

         datetime time_frm = TimeCurrent();
         if(Period()==PERIOD_D1)
            time_frm += TIME_OF_ONE_D1_CANDLE;
         if(Period()==PERIOD_H4)
            time_frm += TIME_OF_ONE_H4_CANDLE;
         if(Period()==PERIOD_H1)
            time_frm += TIME_OF_ONE_H1_CANDLE;

         string lableTfD1 = "--D"+(string)inK+"" ;
         string lableTfH4 = "--                     H4";
         string lableTfH1 = "--                               H1";

         string lableTf = get_time_frame_name(TIMEFRAME);
         if(TIMEFRAME==PERIOD_D1)
            lableTf = lableTfD1;
         if(TIMEFRAME==PERIOD_H4)
            lableTf = lableTfH4;
         if(TIMEFRAME==PERIOD_H1)
            lableTf = lableTfH1;

         create_label("Toc_"+prefix,TimeCurrent(),stoc,lableTf+" ("+getShortName(trend_di)+","+DoubleToString(stoc,1)+")",trend_di,true,8,true,sub_window);
         ObjectSetInteger(0,"Toc_"+prefix,OBJPROP_COLOR,trend_di==TREND_BUY?clrTeal:clrFireBrick);


         if(TIMEFRAME==PERIOD_D1)
            y_start = 10;
         if(TIMEFRAME==PERIOD_H4)
            y_start = (int)(y_start/2)-10;
         if(TIMEFRAME==PERIOD_H1)
            y_start = (int)(y_start)-30;

         createButton(BtnTrend+"Stoc "+TF+(string)sub_window
                      ,strKDS+" "+TF+" "+trend_di+" "+(string)(int)stoc
                      ,x_start-180-5,y_start,180,20,color_di,clrWhite,7,sub_window);
        }

     }
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
      Alert("MACD handle is invalid.");
      return false;
     }

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main, true);
   int copied_main = CopyBuffer(m_handle_macd,0,0,300,m_buff_MACD_main); // Chỉ số 0: MACD Main Line
   if(copied_main <= 0)
     {
      Alert("Failed to copy MACD buffers.");
      return false;
     }

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
      create_label_simple(TF+"MACD_B",""+StringSubstr(TF,0,3)+ " "+DoubleToString(amp_wave,digits)+(pass_price_buy? " Ok":""),low_price-candle_heigh,clrBlack,lowtime);

      create_trend_line(TF+"MACD_HIG",    higtime,hig_price,higtime+1,hig_price,pass_price_sel?clrRed:clrLightGray,STYLE_SOLID,20);
      create_trend_line(TF+"MACD_DOT_HIG",higtime,hig_price,higtime+1,hig_price,clrRed,STYLE_SOLID,10);
      create_label_simple(TF+"MACD_S",""+StringSubstr(TF,0,3)+ " "+DoubleToString(amp_wave,digits)+(pass_price_sel? " Ok":""),hig_price+candle_heigh,clrBlack,higtime);

      if(is_same_symbol(TF,"D1"))
        {
         create_vertical_line(TF+"MACD_VER_LOW",lowtime,clrBlue,STYLE_DOT);
         create_vertical_line(TF+"MACD_VER_HIG",higtime,clrRed,STYLE_DOT);

         //DrawFibonacciRetracement(TF+"FIBO",MathMin(lowtime,higtime),low_price,MathMin(lowtime,higtime),hig_price);
         //create_trend_line(TF+"FIBO_TREND_LINE",lowtime,low_price,higtime,hig_price,clrBlack,STYLE_DOT,1,true,true);
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
void Draw_MACD_Extremes_2(string symbol, ENUM_TIMEFRAMES timeframe, int dot_size=20, bool draw_fan=false,int vertical_width=1,ENUM_LINE_STYLE STYLE=STYLE_SOLID)
  {
   bool IS_MONOCHROME_MODE=false;

   int dot=(int)MathMax(dot_size/2,7);
   string TF=get_time_frame_name(timeframe)+"_";
   datetime amp_time=0;//iTime(symbol, timeframe,1)-iTime(symbol, timeframe,0);
   if(timeframe<PERIOD_H1)
      amp_time=0;

   int m_handle_macd = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      Alert("MACD handle is invalid.");
      return;
     }

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main, true);
   int copied_main = CopyBuffer(m_handle_macd,0,0,300,m_buff_MACD_main); // Chỉ số 0: MACD Main Line
   if(copied_main <= 0)
     {
      Alert("Failed to copy MACD buffers.");
      return;
     }

   int highest_positive_index = -1; // Chỉ số của nến có Histogram cao nhất khi dương
   int lowest_negative_index = -1;  // Chỉ số của nến có Histogram thấp nhất khi âm
   double highest_positive_value = -DBL_MAX; // Histogram cao nhất khi dương
   double lowest_negative_value = DBL_MAX;   // Histogram thấp nhất khi âm
   bool is_positive_wave = false;  // Đánh dấu sóng dương
   bool is_negative_wave = false;  // Đánh dấu sóng âm

   datetime add_time=iTime(symbol, timeframe,0)-iTime(symbol, timeframe,1);
   double max_price=0,min_price=0;
   double candle_height=0;//(iHigh(symbol,timeframe,1)-iLow(symbol,timeframe,1))/3;
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
               datetime time=iTime(symbol, timeframe, lowest_negative_index);

               create_trend_line(TF+"MACD_LOW_L" + appendZero100(lowest_negative_index)+"_",time,low,time-amp_time,low,IS_MONOCHROME_MODE?clrLightGray:clrLightGreen,STYLE_SOLID,dot_size);

               if(draw_fan)
                  create_vertical_line(TF+"MACD_LOW_V" + appendZero100(lowest_negative_index)+".",time,clrLightGreen,STYLE,vertical_width);

               if(is_same_symbol(TF,"D1"))
                  create_lable_simple2(TF+"MACD_LOW_B" + appendZero100(lowest_negative_index),"B ",low-candle_height,clrBlue,time,ANCHOR_CENTER,true);

               create_trend_line(TF+"MACD_LOW_D" + appendZero100(lowest_negative_index),time,low,time+1,low,IS_MONOCHROME_MODE?clrSilver:clrDodgerBlue,STYLE_SOLID,dot);

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
               datetime time=iTime(symbol, timeframe, highest_positive_index);

               create_trend_line(TF+"MACD_HIG_L" + appendZero100(highest_positive_index)+"_",time,hig, time-amp_time,hig,IS_MONOCHROME_MODE?clrLightGray:clrPink,STYLE_SOLID,dot_size);

               if(draw_fan)
                  create_vertical_line(TF+"MACD_HIG_V" + appendZero100(highest_positive_index)+".", time,clrPink,STYLE,vertical_width);

               if(is_same_symbol(TF,"D1"))
                  create_lable_simple2(TF+"MACD_HIG_S" + appendZero100(highest_positive_index),"S ",hig+candle_height,clrRed,time,ANCHOR_CENTER,true);

               create_trend_line(TF+"MACD_HIG_D" + appendZero100(highest_positive_index),time,hig,time+1,hig,IS_MONOCHROME_MODE?clrSilver:clrTomato,STYLE_SOLID,dot);

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
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_trend_macd(string symbol,ENUM_TIMEFRAMES TIMEFRAME,int width_main)
  {
   int sub_window = 1;
   double min_value = 0,max_value = 0;
   string TF = get_time_frame_name(TIMEFRAME);
   ObjectDelete(0,"Macd "+TF+"0");

   int m_handle_macd = iMACD(symbol,TIMEFRAME,12,26,9,PRICE_CLOSE);
   if(m_handle_macd==INVALID_HANDLE)
      return ;

   double m_buff_MACD_main[];
   double m_buff_MACD_sign[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_sign,true);

   CopyBuffer(m_handle_macd,0,0,LIMIT_D+5,m_buff_MACD_main);
   CopyBuffer(m_handle_macd,1,0,LIMIT_D+5,m_buff_MACD_sign);

   if((ArraySize(m_buff_MACD_main)<LIMIT_D) || (ArraySize(m_buff_MACD_sign)<LIMIT_D))
      return;

   for(int i = 0; i < LIMIT_D; i++)
     {
      datetime time_i = (i==0)?TimeCurrent():iTime(symbol,TIMEFRAME,i);
      datetime time_pre_i = iTime(symbol,TIMEFRAME,i+1);

      double hist_i = m_buff_MACD_main[i];
      double sign_i = m_buff_MACD_sign[i];

      double hist_pre_i = m_buff_MACD_main[i+1];
      double sign_pre_i = m_buff_MACD_sign[i+1];

      if(i==0 || min_value < hist_i)
         min_value = hist_i;
      if(i==0 || max_value > hist_i)
         max_value = hist_i;

      string trend_di = (hist_i > sign_i?TREND_BUY:TREND_SEL);
      color  color_di = trend_di==TREND_BUY?clrTeal:clrFireBrick;
      if(i==0)
        {
         int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)-2;
         int x_start = (int)(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,sub_window));
         int y_start = (int)(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,sub_window));

         datetime time_frm = TimeCurrent();
         if(Period()==PERIOD_D1)
            time_frm += TIME_OF_ONE_D1_CANDLE;
         if(Period()==PERIOD_H4)
            time_frm += TIME_OF_ONE_H4_CANDLE;
         if(Period()==PERIOD_H1)
            time_frm += TIME_OF_ONE_H1_CANDLE;

         if(TIMEFRAME==PERIOD_D1)
            y_start = 10;
         if(TIMEFRAME==PERIOD_H4)
            y_start = (int)(y_start/2)-10;
         if(TIMEFRAME==PERIOD_H1)
            y_start = (int)(y_start)-30;

         double avg_macd = (hist_i+hist_i+sign_i)/3;

         createButton(BtnTrend+"Macd "+TF+"0","(12,26,9) "+TF+": "+trend_di
                      +" "+DoubleToString(avg_macd,digits)
                      ,x_start-180-5,y_start,180,20,color_di,clrWhite,7,sub_window);
        }

      color clrColor = clrBlack;

      string nm_main = "macd_main_"+TF+"_"+appendZero100(i);
      string nm_sign = "macd_sign_"+TF+"_"+appendZero100(i);

      create_trend_line(nm_main,time_i,hist_i,time_pre_i,hist_pre_i,color_di,STYLE_SOLID,width_main,false,false,true,false,sub_window);
      if(TIMEFRAME==Period() || TIMEFRAME==PERIOD_CURRENT)
         create_trend_line(nm_sign,time_i,sign_i,time_pre_i,sign_pre_i,color_di,STYLE_SOLID,width_main,false,false,true,false,sub_window);
      else
         ObjectDelete(0,nm_sign);

      if(i==0)
        {
         string lableTfD1 = "--D1 " ;
         string lableTfH4 = "--           H4 ";
         string lableTfH1 = "--                      H1 ";

         string lableTf = "";
         if(TIMEFRAME==PERIOD_D1)
            lableTf = lableTfD1;
         if(TIMEFRAME==PERIOD_H4)
            lableTf = lableTfH4;
         if(TIMEFRAME==PERIOD_H1)
            lableTf = lableTfH1;

         create_label("Macd."+TF,TimeCurrent(),hist_i,lableTf,trend_di,true,8,true,sub_window);
         ObjectSetInteger(0,"Macd."+TF,OBJPROP_COLOR,color_di);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Trend_Channel(string symbol,ENUM_TIMEFRAMES TIMEFRAME)
  {
   string PREFIX = "CHANNEL_"+get_time_frame_name(TIMEFRAME)+"_";

   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   int itemIdx1 = 0,itemIdx2 = 0,itemIdx3 = 0,itemIdx4 = 0,itemIdx5 = 0,itemIdx6 = 0,itemIdx7 = 0,itemIdx8 = 0,itemIdx9 = 0,itemIdx10 = 0;
   int count_item1 = 0,count_item2 = 0,count_item3 = 0,count_item4 = 0,count_item5 = 0,count_item6 = 0,count_item7 = 0,count_item8 = 0,count_item9 = 0,count_item10 = 0;
   string trendIdx1 = "",trendIdx2 = "",trendIdx3 = "",trendIdx4 = "",trendIdx5 = "",trendIdx6 = "",trendIdx7 = "",trendIdx8 = "",trendIdx9 = "",trendIdx10 = "";
   double maxmin_hist1 = 0,maxmin_hist2 = 0,maxmin_hist3 = 0,maxmin_hist4 = 0,maxmin_hist5 = 0,maxmin_hist6 = 0,maxmin_hist7 = 0,maxmin_hist8 = 0,maxmin_hist9 = 0,maxmin_hist10 = 0;
   bool found_item1 = false,found_item2 = false,found_item3 = false,found_item4 = false,found_item5 = false,found_item6 = false,found_item7 = false,found_item8 = false,found_item9 = false,found_item10 = false;
   int START_IDX = 1;
   int min_candle_count = 10;

   int m_handle_macd = iMACD(symbol,TIMEFRAME,12,26,9,PRICE_CLOSE);
   if(m_handle_macd==INVALID_HANDLE)
      return ;

   double m_buff_MACD_main[];
   double m_buff_MACD_sign[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_sign,true);

   CopyBuffer(m_handle_macd,0,0,255,m_buff_MACD_main);
   CopyBuffer(m_handle_macd,1,0,255,m_buff_MACD_sign);


   double macdHist0 = m_buff_MACD_main[0];
   string trendIdx0 = macdHist0 > 0?TREND_BUY:TREND_SEL;
   datetime timeH4 = iTime(symbol,PERIOD_D1,0);
   for(int i = 0; i < LIMIT_D; i++)
     {
      double macdHistH4_i = m_buff_MACD_main[i];
      string trendHistH4_i = macdHistH4_i > 0?TREND_BUY:TREND_SEL;

      if(trendIdx0 != trendHistH4_i)
        {
         timeH4 = iTime(symbol,PERIOD_D1,i);
         break;
        }
     }
   for(int i = 0; i < LIMIT_D; i++)
      if(iTime(symbol,TIMEFRAME,i) < timeH4)
        {
         START_IDX = i;
         break;
        }

   for(int i = START_IDX; i < LIMIT_D; i++)
     {
      double macdHistCurr = m_buff_MACD_main[i];
      double macdHistPrev = m_buff_MACD_sign[i+1];

      string trendHistCurr = macdHistCurr > 0?TREND_BUY:TREND_SEL;
      string trendHistPrev = macdHistPrev > 0?TREND_BUY:TREND_SEL;

      if(i==START_IDX)
        {
         trendIdx1 = macdHistCurr > 0?TREND_BUY:TREND_SEL;
         trendIdx2 = trendIdx1==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx3 = trendIdx2==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx4 = trendIdx3==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx5 = trendIdx4==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx6 = trendIdx5==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx7 = trendIdx6==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx8 = trendIdx7==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx9 = trendIdx8==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx10= trendIdx9==TREND_BUY?TREND_SEL:TREND_BUY;
        }

      if(!found_item1)
        {
         if(trendIdx1==trendHistPrev)
           {
            count_item1 += 1;
            if((trendIdx1==TREND_BUY) && (maxmin_hist1==0 || macdHistCurr > maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }

            if((trendIdx1==TREND_SEL) && (maxmin_hist1==0 || macdHistCurr < maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }
           }
         else
           {
            found_item1 = true;
           }
        }

      if(found_item1 && !found_item2)
        {
         if(trendIdx2==trendHistPrev)
           {
            count_item2 += 1;
            if((trendIdx2==TREND_BUY) && (maxmin_hist2==0 || macdHistCurr > maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }

            if((trendIdx2==TREND_SEL) && (maxmin_hist2==0 || macdHistCurr < maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx2-itemIdx1) > min_candle_count)
               found_item2 = true;
           }

         if(i==LIMIT_D-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && !found_item3 && (i<LIMIT_D-2))
        {
         if(trendIdx3==trendHistPrev)
           {
            count_item3 += 1;
            if((trendIdx3==TREND_BUY) && (maxmin_hist3==0 || macdHistCurr > maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }

            if((trendIdx3==TREND_SEL) && (maxmin_hist3==0 || macdHistCurr < maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx3-itemIdx2) > min_candle_count)
               found_item3 = true;
           }

         if(i==LIMIT_D-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && found_item3 && !found_item4)
        {
         if(trendIdx4==trendHistPrev)
           {
            count_item4 += 1;
            if((trendIdx4==TREND_BUY) && (maxmin_hist4==0 || macdHistCurr > maxmin_hist4))
              {
               itemIdx4 = i;
               maxmin_hist4 = macdHistCurr;
              }

            if((trendIdx4==TREND_SEL) && (maxmin_hist4==0 || macdHistCurr < maxmin_hist4))
              {
               itemIdx4 = i;
               maxmin_hist4 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx4-itemIdx3) > min_candle_count)
               found_item4 = true;
           }

         if(i==LIMIT_D-1)
            found_item4 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && !found_item5)
        {
         if(trendIdx5==trendHistPrev)
           {
            count_item5 += 1;
            if((trendIdx5==TREND_BUY) && (maxmin_hist5==0 || macdHistCurr > maxmin_hist5))
              {
               itemIdx5 = i;
               maxmin_hist5 = macdHistCurr;
              }

            if((trendIdx5==TREND_SEL) && (maxmin_hist5==0 || macdHistCurr < maxmin_hist5))
              {
               itemIdx5 = i;
               maxmin_hist5 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx5-itemIdx4) > min_candle_count)
               found_item5 = true;
           }

         if(i==LIMIT_D-1)
            found_item5 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && !found_item6)
        {
         if(trendIdx6==trendHistPrev)
           {
            count_item6 += 1;
            if((trendIdx6==TREND_BUY) && (maxmin_hist6==0 || macdHistCurr > maxmin_hist6))
              {
               itemIdx6 = i;
               maxmin_hist6 = macdHistCurr;
              }

            if((trendIdx6==TREND_SEL) && (maxmin_hist6==0 || macdHistCurr < maxmin_hist6))
              {
               itemIdx6 = i;
               maxmin_hist6 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx6-itemIdx5) > min_candle_count)
               found_item6 = true;
           }

         if(i==LIMIT_D-1)
            found_item6 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && !found_item7)
        {
         if(trendIdx7==trendHistPrev)
           {
            count_item7 += 1;
            if((trendIdx7==TREND_BUY) && (maxmin_hist7==0 || macdHistCurr > maxmin_hist7))
              {
               itemIdx7 = i;
               maxmin_hist7 = macdHistCurr;
              }

            if((trendIdx7==TREND_SEL) && (maxmin_hist7==0 || macdHistCurr < maxmin_hist7))
              {
               itemIdx7 = i;
               maxmin_hist7 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx7-itemIdx6) > min_candle_count)
               found_item7 = true;
           }

         if(i==LIMIT_D-1)
            found_item7 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && found_item7 && !found_item8)
        {
         if(trendIdx8==trendHistPrev)
           {
            count_item8 += 1;
            if((trendIdx8==TREND_BUY) && (maxmin_hist8==0 || macdHistCurr > maxmin_hist8))
              {
               itemIdx8 = i;
               maxmin_hist8 = macdHistCurr;
              }

            if((trendIdx8==TREND_SEL) && (maxmin_hist8==0 || macdHistCurr < maxmin_hist8))
              {
               itemIdx8 = i;
               maxmin_hist8 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx8-itemIdx7) > min_candle_count)
               found_item8 = true;
           }
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && found_item7 && found_item8 && !found_item9)
        {
         if(trendIdx9==trendHistPrev)
           {
            count_item9 += 1;
            if((trendIdx9==TREND_BUY) && (maxmin_hist9==0 || macdHistCurr > maxmin_hist9))
              {
               itemIdx9 = i;
               maxmin_hist9 = macdHistCurr;
              }

            if((trendIdx9==TREND_SEL) && (maxmin_hist9==0 || macdHistCurr < maxmin_hist9))
              {
               itemIdx9 = i;
               maxmin_hist9 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx9-itemIdx8) > min_candle_count)
               found_item9 = true;
           }

        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && found_item7 && found_item8 && found_item9 && !found_item10)
        {
         if(trendIdx10==trendHistPrev)
           {
            count_item10 += 1;
            if((trendIdx10==TREND_BUY) && (maxmin_hist10==0 || macdHistCurr > maxmin_hist10))
              {
               itemIdx10 = i;
               maxmin_hist10 = macdHistCurr;
              }

            if((trendIdx10==TREND_SEL) && (maxmin_hist10==0 || macdHistCurr < maxmin_hist10))
              {
               itemIdx10 = i;
               maxmin_hist10 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx10-itemIdx9) > min_candle_count)
               found_item10 = true;
           }
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && found_item7 && found_item8 && found_item9 && found_item10)
         break;
     }

   if(found_item1 && found_item2 && found_item3 && found_item4)
     {
      datetime date1 = iTime(symbol,TIMEFRAME,itemIdx1);
      datetime date2 = iTime(symbol,TIMEFRAME,itemIdx2);
      datetime date3 = iTime(symbol,TIMEFRAME,itemIdx3);
      datetime date4 = iTime(symbol,TIMEFRAME,itemIdx4);

      double price1 = trendIdx1==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx1):iLow(symbol,TIMEFRAME,itemIdx1);
      double price2 = trendIdx2==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx2):iLow(symbol,TIMEFRAME,itemIdx2);
      double price3 = trendIdx3==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx3):iLow(symbol,TIMEFRAME,itemIdx3);
      double price4 = trendIdx4==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx4):iLow(symbol,TIMEFRAME,itemIdx4);

      datetime date0 = TimeCurrent();

      create_trend_line(PREFIX+"13",date3,price3,date1,price1,price1 < price2?clrBlue:clrRed,STYLE_SOLID,1,true,true,true,false);
      create_trend_line(PREFIX+"24",date4,price4,date2,price2,price1 > price2?clrBlue:clrRed,STYLE_SOLID,1,true,true,true,false);

      double cur_line_13_price = GetTrendlineValueAtCurrentTime(PREFIX+"13",date0);
      create_trend_line(PREFIX+"13.",date1,price1,date0,cur_line_13_price,price1 < price2?clrBlue:clrRed,STYLE_SOLID,1,false,false,true,false);

      double cur_line_24_price = GetTrendlineValueAtCurrentTime(PREFIX+"24",date0);
      create_trend_line(PREFIX+"24.",date2,price2,date0,cur_line_24_price,price1 > price2?clrBlue:clrRed,STYLE_SOLID,1,false,false,true,false);
     }


   if(found_item1 && found_item2 && found_item3)
     {
      datetime date1 = iTime(symbol,TIMEFRAME,itemIdx1);
      datetime date2 = iTime(symbol,TIMEFRAME,itemIdx2);
      datetime date3 = iTime(symbol,TIMEFRAME,itemIdx3);

      double price1 = trendIdx1==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx1):iLow(symbol,TIMEFRAME,itemIdx1);
      double price2 = trendIdx2==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx2):iLow(symbol,TIMEFRAME,itemIdx2);
      double price3 = trendIdx3==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx3):iLow(symbol,TIMEFRAME,itemIdx3);

      color clrTrend1 = trendIdx1==TREND_BUY?clrRed:clrBlue;
      color clrTrend2 = trendIdx2==TREND_BUY?clrRed:clrBlue;
      color clrTrend3 = trendIdx3==TREND_BUY?clrRed:clrBlue;

      create_vertical_line("Week1",date1,clrBlack,STYLE_SOLID,1);
      create_vertical_line("Week2",date2,clrBlack,STYLE_SOLID,1);
      create_vertical_line("Week3",date3,clrBlack,STYLE_SOLID,1);

      create_trend_line("Week1.",date1,price1,date1+TIME_OF_ONE_H4_CANDLE,price1,clrTrend1,STYLE_SOLID,25);
      create_trend_line("Week2.",date2,price2,date2+TIME_OF_ONE_H4_CANDLE,price2,clrTrend2,STYLE_SOLID,25);
      create_trend_line("Week3.",date3,price3,date3+TIME_OF_ONE_H4_CANDLE,price3,clrTrend3,STYLE_SOLID,25);

      create_label("Week1..",date1-TIME_OF_ONE_W1_CANDLE*1,price1, "~"+(string)(itemIdx1)+"w","");
      create_label("Week2..",date2-TIME_OF_ONE_W1_CANDLE*1,price2, "~"+(string)(itemIdx2-itemIdx1)+"w","");
      create_label("Week3..",date3-TIME_OF_ONE_W1_CANDLE*1,price3, "~"+(string)(itemIdx3-itemIdx2)+"w","");
     }

   if(found_item4)
     {
      color clrTrend = trendIdx4==TREND_BUY?clrRed:clrBlue;
      datetime date = iTime(symbol,TIMEFRAME,itemIdx4);
      double price = trendIdx4==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx4):iLow(symbol,TIMEFRAME,itemIdx4);
      create_vertical_line("Week4",date,clrBlack,STYLE_SOLID,1);
      create_trend_line("Week4.",date,price,date+TIME_OF_ONE_H4_CANDLE,price,clrTrend,STYLE_SOLID,25);
      create_label("Week4..",date-TIME_OF_ONE_W1_CANDLE*1,price, "~"+(string)(itemIdx4-itemIdx3)+"w","");
     }

   if(found_item5)
     {
      color clrTrend = trendIdx5==TREND_BUY?clrRed:clrBlue;
      datetime date = iTime(symbol,TIMEFRAME,itemIdx5);
      double price = trendIdx5==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx5):iLow(symbol,TIMEFRAME,itemIdx5);
      create_vertical_line("Week5",date,clrBlack,STYLE_SOLID,1);
      create_trend_line("Week5.",date,price,date+TIME_OF_ONE_H4_CANDLE,price,clrTrend,STYLE_SOLID,25);
      create_label("Week5..",date-TIME_OF_ONE_W1_CANDLE*1,price, "~"+(string)(itemIdx5-itemIdx4)+"w","");
     }

   if(found_item6)
     {
      color clrTrend = trendIdx6==TREND_BUY?clrRed:clrBlue;
      datetime date = iTime(symbol,TIMEFRAME,itemIdx6);
      double price = trendIdx6==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx6):iLow(symbol,TIMEFRAME,itemIdx6);
      create_vertical_line("Week6",date,clrBlack,STYLE_SOLID,1);
      create_trend_line("Week6.",date,price,date+TIME_OF_ONE_H4_CANDLE,price,clrTrend,STYLE_SOLID,25);
      create_label("Week6..",date-TIME_OF_ONE_W1_CANDLE*1,price, "~"+(string)(itemIdx6-itemIdx5)+"w","");
     }

   if(found_item7)
     {
      color clrTrend = trendIdx7==TREND_BUY?clrRed:clrBlue;
      datetime date = iTime(symbol,TIMEFRAME,itemIdx7);
      double price = trendIdx7==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx7):iLow(symbol,TIMEFRAME,itemIdx7);
      create_vertical_line("Week7",date,clrBlack,STYLE_SOLID,1);
      create_trend_line("Week7.",date,price,date+TIME_OF_ONE_H4_CANDLE,price,clrTrend,STYLE_SOLID,25);
      create_label("Week7..",date-TIME_OF_ONE_W1_CANDLE*1,price, "~"+(string)(itemIdx7-itemIdx6)+"w","");
     }

   if(found_item8)
     {
      color clrTrend = trendIdx8==TREND_BUY?clrRed:clrBlue;
      datetime date = iTime(symbol,TIMEFRAME,itemIdx8);
      double price = trendIdx8==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx8):iLow(symbol,TIMEFRAME,itemIdx8);
      create_vertical_line("Week8",date,clrBlack,STYLE_SOLID,1);
      create_trend_line("Week8.",date,price,date+TIME_OF_ONE_H4_CANDLE,price,clrTrend,STYLE_SOLID,25);
      create_label("Week8..",date-TIME_OF_ONE_W1_CANDLE*1,price, "~"+(string)(itemIdx8-itemIdx7)+"w","");
     }

   if(found_item9)
     {
      color clrTrend = trendIdx9==TREND_BUY?clrRed:clrBlue;
      datetime date = iTime(symbol,TIMEFRAME,itemIdx9);
      double price = trendIdx9==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx9):iLow(symbol,TIMEFRAME,itemIdx9);
      create_vertical_line("Week9",date,clrBlack,STYLE_SOLID,1);
      create_trend_line("Week9.",date,price,date+TIME_OF_ONE_H4_CANDLE,price,clrTrend,STYLE_SOLID,25);
      create_label("Week9..",date-TIME_OF_ONE_W1_CANDLE*1,price, "~"+(string)(itemIdx9-itemIdx8)+"w","");
     }

   if(found_item10)
     {
      color clrTrend = trendIdx10==TREND_BUY?clrRed:clrBlue;
      datetime date = iTime(symbol,TIMEFRAME,itemIdx10);
      double price = trendIdx10==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx10):iLow(symbol,TIMEFRAME,itemIdx10);
      create_vertical_line("Week10",date,clrBlack,STYLE_SOLID,1);
      create_trend_line("Week10.",date,price,date+TIME_OF_ONE_H4_CANDLE,price,clrTrend,STYLE_SOLID,25);
      create_label("Week10..",date-TIME_OF_ONE_W1_CANDLE*1,price, "~"+(string)(itemIdx10-itemIdx9)+"w","");
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calc_Wave_Amp(string symbol,ENUM_TIMEFRAMES TIMEFRAME)
  {
   int itemIdx1 = 0,itemIdx2 = 0,itemIdx3 = 0;
   int count_item1 = 0,count_item2 = 0,count_item3 = 0;
   string trendIdx1 = "",trendIdx2 = "",trendIdx3 = "";
   double maxmin_hist1 = 0,maxmin_hist2 = 0,maxmin_hist3 = 0;
   bool found_item1 = false,found_item2 = false,found_item3 = false;

   int START_IDX = 1;
   int min_candle_count = 10;
   int limit = LIMIT_D;


   int m_handle_macd = iMACD(symbol,TIMEFRAME,12,26,9,PRICE_CLOSE);
   if(m_handle_macd==INVALID_HANDLE)
      return ;

   double m_buff_MACD_main[];
   double m_buff_MACD_sign[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_sign,true);

   CopyBuffer(m_handle_macd,0,0,255,m_buff_MACD_main);
   CopyBuffer(m_handle_macd,1,0,255,m_buff_MACD_sign);

   double macdHist0 = m_buff_MACD_main[0];
   string trendIdx0 = macdHist0 > 0?TREND_BUY:TREND_SEL;

   for(int i = 0; i < LIMIT_D; i++)
     {
      double macdHistCurr = m_buff_MACD_main[i];
      double macdHistPrev = m_buff_MACD_sign[i+1];

      string trendHistCurr = macdHistCurr > 0?TREND_BUY:TREND_SEL;
      string trendHistPrev = macdHistPrev > 0?TREND_BUY:TREND_SEL;

      if(i==START_IDX)
        {
         trendIdx1 = macdHistCurr > 0?TREND_BUY:TREND_SEL;
         trendIdx2 = trendIdx1==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx3 = trendIdx2==TREND_BUY?TREND_SEL:TREND_BUY;
        }

      if(!found_item1)
        {
         if(trendIdx1==trendHistPrev)
           {
            count_item1 += 1;
            if((trendIdx1==TREND_BUY) && (maxmin_hist1==0 || macdHistCurr > maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }

            if((trendIdx1==TREND_SEL) && (maxmin_hist1==0 || macdHistCurr < maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }
           }
         else
           {
            found_item1 = true;
           }
        }

      if(found_item1 && !found_item2)
        {
         if(trendIdx2==trendHistPrev)
           {
            count_item2 += 1;
            if((trendIdx2==TREND_BUY) && (maxmin_hist2==0 || macdHistCurr > maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }

            if((trendIdx2==TREND_SEL) && (maxmin_hist2==0 || macdHistCurr < maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx2-itemIdx1) > min_candle_count)
               found_item2 = true;
           }

         if(i==limit-1)
            found_item3 = true;
        }


      if(found_item1 && found_item2 && !found_item3 && (i<limit-2))
        {
         if(trendIdx3==trendHistPrev)
           {
            count_item3 += 1;
            if((trendIdx3==TREND_BUY) && (maxmin_hist3==0 || macdHistCurr > maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }

            if((trendIdx3==TREND_SEL) && (maxmin_hist3==0 || macdHistCurr < maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx3-itemIdx2) > min_candle_count)
               found_item3 = true;
           }

         if(i==limit-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && found_item3)
         break;
     }
   double amp_1to2=0;
   if(trendIdx1==TREND_BUY)
      amp_1to2 = iHigh(symbol,TIMEFRAME,itemIdx1)-iLow(symbol,TIMEFRAME,itemIdx2);
   if(trendIdx1==TREND_SEL)
      amp_1to2 = iHigh(symbol,TIMEFRAME,itemIdx2)-iLow(symbol,TIMEFRAME,itemIdx1);

   create_label_simple("Amp_Wave","1to2: "+(string)amp_1to2,iOpen(symbol,TIMEFRAME,1));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Fibo(string symbol,ENUM_TIMEFRAMES TIMEFRAME)
  {
   string PREFIX = "CHANNEL_"+get_time_frame_name(TIMEFRAME)+"_";
   double lowest_5p = MAXIMUM_DOUBLE;
   if(Period() > PERIOD_D1)
     {
      ObjectDelete(0,"TimeZone");
      ObjectDelete(0,"_Fibo_Fan");

      ObjectDelete(0,"date1");
      ObjectDelete(0,"date2");
      ObjectDelete(0,"date3");

      ObjectDelete(0,"count_range1");
      ObjectDelete(0,"count_range2");
      ObjectDelete(0,"count_range3");

      return;
     }

   bool is_draw_h4 = TIMEFRAME==PERIOD_H4;

   int itemIdx1 = 0,itemIdx2 = 0,itemIdx3 = 0,itemIdx4 = 0,itemIdx5 = 0;
   int count_item1 = 0,count_item2 = 0,count_item3 = 0,count_item4 = 0,count_item5 = 0;
   string trendIdx1 = "",trendIdx2 = "",trendIdx3 = "",trendIdx4 = "",trendIdx5 = "";
   double maxmin_hist1 = 0,maxmin_hist2 = 0,maxmin_hist3 = 0,maxmin_hist4 = 0,maxmin_hist5 = 0;
   bool found_item1 = false,found_item2 = false,found_item3 = false,found_item4 = false,found_item5 = false;

   int START_IDX = 1;
   int min_candle_count = 10;

   int m_handle_macd = iMACD(symbol,TIMEFRAME,12,26,9,PRICE_CLOSE);
   if(m_handle_macd==INVALID_HANDLE)
      return ;

   double m_buff_MACD_main[];
   double m_buff_MACD_sign[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_sign,true);

   CopyBuffer(m_handle_macd,0,0,LIMIT_D+5,m_buff_MACD_main);
   CopyBuffer(m_handle_macd,1,0,LIMIT_D+5,m_buff_MACD_sign);

   if((ArraySize(m_buff_MACD_main)<LIMIT_D) || (ArraySize(m_buff_MACD_sign)<LIMIT_D))
      return;

   double macdHist0 = m_buff_MACD_main[0];
   string trendIdx0 = macdHist0 > 0?TREND_BUY:TREND_SEL;
   datetime timeH4 = iTime(symbol,PERIOD_H4,0);
   for(int i = 0; i < LIMIT_D; i++)
     {
      double macdHistH4_i =  m_buff_MACD_main[i];
      string trendHistH4_i = macdHistH4_i > 0?TREND_BUY:TREND_SEL;

      if(trendIdx0 != trendHistH4_i)
        {
         timeH4 = iTime(symbol,PERIOD_H4,i);
         break;
        }
     }
   for(int i = 0; i < LIMIT_D; i++)
      if(iTime(symbol,PERIOD_D1,i) < timeH4)
        {
         START_IDX = i;
         break;
        }

   for(int i = MathMax(START_IDX,0); i < LIMIT_D; i++)
     {
      double macdHistCurr =  m_buff_MACD_main[i];
      double macdHistPrev =  m_buff_MACD_main[i+1];

      string trendHistCurr = macdHistCurr > 0?TREND_BUY:TREND_SEL;
      string trendHistPrev = macdHistPrev > 0?TREND_BUY:TREND_SEL;

      if(i==START_IDX)
        {
         trendIdx1 = macdHistCurr > 0?TREND_BUY:TREND_SEL;
         trendIdx2 = trendIdx1==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx3 = trendIdx2==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx4 = trendIdx3==TREND_BUY?TREND_SEL:TREND_BUY;
         trendIdx5 = trendIdx4==TREND_BUY?TREND_SEL:TREND_BUY;
        }

      if(!found_item1)
        {
         if(trendIdx1==trendHistPrev)
           {
            count_item1 += 1;
            if((trendIdx1==TREND_BUY) && (maxmin_hist1==0 || macdHistCurr > maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }

            if((trendIdx1==TREND_SEL) && (maxmin_hist1==0 || macdHistCurr < maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }
           }
         else
           {
            found_item1 = true;
           }
        }

      if(found_item1 && !found_item2)
        {
         if(trendIdx2==trendHistPrev)
           {
            count_item2 += 1;
            if((trendIdx2==TREND_BUY) && (maxmin_hist2==0 || macdHistCurr > maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }

            if((trendIdx2==TREND_SEL) && (maxmin_hist2==0 || macdHistCurr < maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx2-itemIdx1) > min_candle_count)
               found_item2 = true;
           }

         if(i==LIMIT_D-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && !found_item3 && (i<LIMIT_D-2))
        {
         if(trendIdx3==trendHistPrev)
           {
            count_item3 += 1;
            if((trendIdx3==TREND_BUY) && (maxmin_hist3==0 || macdHistCurr > maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }

            if((trendIdx3==TREND_SEL) && (maxmin_hist3==0 || macdHistCurr < maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx3-itemIdx2) > min_candle_count)
               found_item3 = true;
           }

         if(i==LIMIT_D-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && found_item3 && !found_item4)
        {
         if(trendIdx4==trendHistPrev)
           {
            count_item4 += 1;
            if((trendIdx4==TREND_BUY) && (maxmin_hist4==0 || macdHistCurr > maxmin_hist4))
              {
               itemIdx4 = i;
               maxmin_hist4 = macdHistCurr;
              }

            if((trendIdx4==TREND_SEL) && (maxmin_hist4==0 || macdHistCurr < maxmin_hist4))
              {
               itemIdx4 = i;
               maxmin_hist4 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx4-itemIdx3) > min_candle_count)
               found_item4 = true;
           }

         if(i==LIMIT_D-1)
            found_item4 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && !found_item5)
        {
         if(trendIdx5==trendHistPrev)
           {
            count_item5 += 1;
            if((trendIdx5==TREND_BUY) && (maxmin_hist5==0 || macdHistCurr > maxmin_hist5))
              {
               itemIdx5 = i;
               maxmin_hist5 = macdHistCurr;
              }

            if((trendIdx5==TREND_SEL) && (maxmin_hist5==0 || macdHistCurr < maxmin_hist5))
              {
               itemIdx5 = i;
               maxmin_hist5 = macdHistCurr;
              }
           }
         else
           {
            if(MathAbs(itemIdx5-itemIdx4) > min_candle_count)
               found_item5 = true;
           }

         if(i==LIMIT_D-1)
            found_item5 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5)
         break;
     }

   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   if(is_draw_h4)
     {
      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5)
        {
         datetime date1 = iTime(symbol,TIMEFRAME,itemIdx1);
         datetime date2 = iTime(symbol,TIMEFRAME,itemIdx2);
         datetime date3 = iTime(symbol,TIMEFRAME,itemIdx3);
         datetime date4 = iTime(symbol,TIMEFRAME,itemIdx4);
         datetime date5 = iTime(symbol,TIMEFRAME,itemIdx5);

         double price1 = trendIdx1==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx1):iLow(symbol,TIMEFRAME,itemIdx1);
         double price2 = trendIdx2==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx2):iLow(symbol,TIMEFRAME,itemIdx2);
         double price3 = trendIdx3==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx3):iLow(symbol,TIMEFRAME,itemIdx3);
         double price4 = trendIdx4==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx4):iLow(symbol,TIMEFRAME,itemIdx4);
         double price5 = trendIdx5==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx5):iLow(symbol,TIMEFRAME,itemIdx5);

         lowest_5p = MathMin(MathMin(price4,price5),price3);

         create_trend_line(PREFIX+"price1",date1,price1,date1+TIME_OF_ONE_H4_CANDLE,price1,clrSilver,STYLE_SOLID,25);
         create_trend_line(PREFIX+"price2",date2,price2,date2+TIME_OF_ONE_H4_CANDLE,price2,clrSilver,STYLE_SOLID,25);
         create_trend_line(PREFIX+"price3",date3,price3,date3+TIME_OF_ONE_H4_CANDLE,price3,clrSilver,STYLE_SOLID,25);
         create_trend_line(PREFIX+"price4",date4,price4,date4+TIME_OF_ONE_H4_CANDLE,price4,clrSilver,STYLE_SOLID,25);
         create_trend_line(PREFIX+"price5",date5,price5,date5+TIME_OF_ONE_H4_CANDLE,price5,clrSilver,STYLE_SOLID,25);

         datetime date0 = TimeCurrent();
         bool is_draw_date4 = date4 < date3;
         bool is_draw_date5 = date5 < date3;

         create_trend_line(PREFIX+"LINE_24",date4,price4,date2,price2,clrBlueViolet,STYLE_SOLID,3,false,false);
         create_trend_line(PREFIX+"LINE_35",date5,price5,date3,price3,clrBlueViolet,STYLE_SOLID,3,false,false);

         double cur_line_24_price = GetTrendlineValueAtCurrentTime(PREFIX+"LINE_24",date0);
         create_trend_line(PREFIX+"LINE_24_CUR",date2,price2,date0,cur_line_24_price,clrBlueViolet,STYLE_SOLID,3,false,false);

         double cur_line_35_price = GetTrendlineValueAtCurrentTime(PREFIX+"LINE_35",date0);
         create_trend_line(PREFIX+"LINE_35_CUR",date3,price3,date0,cur_line_35_price,clrBlueViolet,STYLE_SOLID,3,false,false);
        }

      return;
     }

   if(found_item1 && found_item2 && found_item3)
     {
      datetime date1 = iTime(symbol,TIMEFRAME,itemIdx1);
      datetime date2 = iTime(symbol,TIMEFRAME,itemIdx2);
      datetime date3 = iTime(symbol,TIMEFRAME,itemIdx3);

      double price1 = trendIdx1==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx1):iLow(symbol,TIMEFRAME,itemIdx1);
      double price2 = trendIdx2==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx2):iLow(symbol,TIMEFRAME,itemIdx2);
      double price3 = trendIdx3==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx3):iLow(symbol,TIMEFRAME,itemIdx3);

      create_vertical_line("date1",date1,trendIdx1==TREND_BUY?clrRed:clrBlue,STYLE_SOLID,2);
      create_vertical_line("date2",date2,trendIdx2==TREND_BUY?clrRed:clrBlue,STYLE_SOLID,2);
      create_vertical_line("date3",date3,trendIdx3==TREND_BUY?clrRed:clrBlue,STYLE_SOLID,2);

      create_trend_line(PREFIX+"_price1",date1,price1,date1+TIME_OF_ONE_H4_CANDLE,price1,clrSilver,STYLE_SOLID,25);
      create_trend_line(PREFIX+"_price2",date2,price2,date2+TIME_OF_ONE_H4_CANDLE,price2,clrSilver,STYLE_SOLID,25);
      create_trend_line(PREFIX+"_price3",date3,price3,date3+TIME_OF_ONE_H4_CANDLE,price3,clrSilver,STYLE_SOLID,25);

      int count1 = CountD1Candles(symbol,date1,TimeCurrent());
      int count2 = CountD1Candles(symbol,date2,date1);
      int count3 = CountD1Candles(symbol,date3,date2);

      int y_start = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS))-25;
      datetime date0 = TimeCurrent();
      int count0 = (int)(count2*0.618);
      //if(count0 > count1)
        {
         //date0 = AddCandlesToDate(date1,count0);
         //create_vertical_line("date0",date0,clrBlack,STYLE_DASHDOTDOT,1);

         int x0,y0;
         if(ChartTimePriceToXY(0,0,date0,bid,x0,y0))
            createButton("count_range0",(string) count0+"c "+format_date_yyyyMMdd(date0),x0+5,5,120,20,clrBlack,clrWhite);
        }

      if(count2 > count1)
        {
         //date0 = AddCandlesToDate(date1,count2);
         //create_vertical_line("date_cycle_1",date0,clrBlack,STYLE_DASHDOTDOT,1);

         string count_range0 = ObjectGetString(0,"count_range0",OBJPROP_TEXT);
         count_range0 += " ~ "+(string)count2+"c "+format_date_yyyyMMdd(date0);
         ObjectSetString(0,"count_range0",OBJPROP_TEXT,count_range0);
         ObjectSetInteger(0,"count_range0",OBJPROP_XSIZE,240);
        }

      int x1,y1;
      if(ChartTimePriceToXY(0,0,date1,bid,x1,y1))
         createButton("count_range1","[1] "+(string) count1+"c",x1+5,y_start,60,20,clrBlack,clrWhite);

      int x2,y2;
      if(ChartTimePriceToXY(0,0,date2,bid,x2,y2))
         createButton("count_range2","[2] "+(string) count2+"c",x2+5,y_start,60,20,clrBlack,clrWhite);

      int x3,y3;
      if(ChartTimePriceToXY(0,0,date3,bid,x3,y3))
         createButton("count_range3","[3] "+(string) count3+"c",x3+5,y_start,60,20,clrBlack,clrWhite);


      int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

      if(found_item4 && found_item5)
        {
         datetime date4 = iTime(symbol,TIMEFRAME,itemIdx4);
         datetime date5 = iTime(symbol,TIMEFRAME,itemIdx5);
         bool is_draw_date4 = date4 < date3;
         bool is_draw_date5 = date5 < date3;

         double price4 = trendIdx4==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx4):iLow(symbol,TIMEFRAME,itemIdx4);
         double price5 = trendIdx5==TREND_BUY?iHigh(symbol,TIMEFRAME,itemIdx5):iLow(symbol,TIMEFRAME,itemIdx5);

         lowest_5p=MathMin(MathMin(price4,price5),lowest_5p);

         int count4 = CountD1Candles(symbol,date4,date3)-1;
         int count5 = CountD1Candles(symbol,date5,date4)-1;

         create_trend_line(PREFIX+"_price4",date4,price4,date4+TIME_OF_ONE_H4_CANDLE,price4,clrSilver,STYLE_SOLID,25);
         create_trend_line(PREFIX+"_price5",date5,price5,date5+TIME_OF_ONE_H4_CANDLE,price5,clrSilver,STYLE_SOLID,25);

         if(is_draw_date4)
            create_vertical_line("date4",date4,trendIdx4==TREND_BUY?clrRed:clrBlue,STYLE_SOLID,1);

         if(is_draw_date5)
            create_vertical_line("date5",date5,trendIdx5==TREND_BUY?clrRed:clrBlue,STYLE_SOLID,1);

         if(is_draw_date4 && count4 > 7 && count2 > 7)
            create_trend_line("CHANNEL_D_24",date4,price4,date2,price2,clrBlack,STYLE_SOLID,2,false,true,true,false);

         if(is_draw_date5 && count3 > 7 && count5 > 7)
            create_trend_line("CHANNEL_D_35",date5,price5,date3,price3,clrBlack,STYLE_SOLID,2,false,true,true,false);

         double cur_line_24_price = GetTrendlineValueAtCurrentTime("CHANNEL_D_24",date0);
         double cur_line_35_price = GetTrendlineValueAtCurrentTime("CHANNEL_D_35",date0);

         if(is_draw_date4 && cur_line_24_price > 0 && count4 > 7 && count2 > 7)
           {
            create_label("cur_line_24_price",date0,cur_line_24_price,format_double_to_string(cur_line_24_price,digits-1));
            create_trend_line("CHANNEL_D_24.",date2,price2,date0,cur_line_24_price,clrGray,STYLE_SOLID,2,false,true,true,false);
           }

         if(is_draw_date5 && cur_line_35_price > 0 && count3 > 7 && count5 > 7)
           {
            create_label("cur_line_35_price",date0,cur_line_35_price,format_double_to_string(cur_line_35_price,digits-1));
            create_trend_line("CHANNEL_D_35.",date3,price3,date0,cur_line_35_price,clrGray,STYLE_SOLID,2,false,true,true,false);
           }

         int x4,y4;
         if(is_draw_date4)
            if(ChartTimePriceToXY(0,0,date4,bid,x4,y4))
               createButton("count_range4","[4] "+(string) count4+"c",x4+5,y_start,60,20,clrBlack,clrWhite);

         int x5,y5;
         if(is_draw_date5)
            if(ChartTimePriceToXY(0,0,date5,bid,x5,y5))
               createButton("count_range5","[5] "+(string) count5+"c",x5+5,y_start,60,20,clrBlack,clrWhite);
        }


      if(trendIdx2==TREND_SEL)
         DrawManualFibonacciRetracement("_Fibo_2",date2,price3,date1,price2,clrBlack);
      if(trendIdx2==TREND_BUY)
         DrawManualFibonacciRetracement("_Fibo_2",date1,price2,date2,price3,clrBlack);


      double amp_w1,amp_d1,amp_h4,amp_grid_L100;
      GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_grid_L100);

      if(MathAbs(price1-price2) > amp_w1)
        {
         if(trendIdx1==TREND_SEL)
            DrawFibonacciRetracement("_Fibo_1",date1,price2,date2,price1);

         if(trendIdx1==TREND_BUY)
            DrawFibonacciRetracement("_Fibo_1",date1,price1,date2,price2);
        }


      ObjectDelete(0,"_Fibo_Fan");
      if((Period()==PERIOD_D1||Period()==PERIOD_H4 ||Period()==PERIOD_H1) && (MathAbs(price1-price2) > amp_w1))
        {
         DrawFibonacciTimeZones("TimeZone",date2,date1,price1);

         //if(trendIdx1==TREND_SEL)
           {
            DrawFibonacciFan("_Fibo_Fan_S",date2,MathMin(price1,price2),date1,MathMax(price1,price2),TREND_SEL);
           }

         //if(trendIdx1==TREND_BUY)
           {
            DrawFibonacciFan("_Fibo_Fan_B",date2,MathMax(price1,price2),date1,MathMin(price1,price2),TREND_BUY);
           }
        }

      //if(is_same_symbol(symbol,"XAU"))
        {
         double amp_p1p2=MathAbs(price1-price2);
         datetime time = iTime(symbol,PERIOD_W1,0)+TIME_OF_ONE_W1_CANDLE*5;
         //----------------------------------------------
         if(ChartTimePriceToXY(0,0,time,price1,x1,y1))
            createButton("price1",(string)price1,x1,y1-10,70,20,clrBlack,clrWhite,8);

         if(ChartTimePriceToXY(0,0,time,price2,x1,y1))
            createButton("price2",(string)price2,x1,y1-10,70,20,clrBlack,clrWhite,8);
         //----------------------------------------------
         double price_a1=NormalizeDouble(MathMin(price1,price2)-amp_p1p2,  digits-2);
         double price_a2=NormalizeDouble(MathMin(price1,price2)-amp_p1p2*2,digits-2);

         if(ChartTimePriceToXY(0,0,time,price_a1,x1,y1))
            createButton("price_a1",format_double_to_string(price_a1,digits-2),x1,y1-10,70,20,clrBlack,clrWhite,8);

         if(ChartTimePriceToXY(0,0,time,price_a2,x1,y1))
            createButton("price_a2",format_double_to_string(price_a2,digits-2),x1,y1-10,70,20,clrBlack,clrWhite,8);
         //----------------------------------------------
         double price_b1=NormalizeDouble(MathMax(price1,price2)+amp_p1p2,  digits-2);
         double price_b2=NormalizeDouble(MathMax(price1,price2)+amp_p1p2*2,digits-2);

         if(ChartTimePriceToXY(0,0,time,price_b1,x1,y1))
            createButton("price_b1",(string)price_b1,x1,y1-10,70,20,clrBlack,clrWhite,8);

         if(ChartTimePriceToXY(0,0,time,price_b2,x1,y1))
            createButton("price_b2",(string)price_b2,x1,y1-10,70,20,clrBlack,clrWhite,8);
        }

      if(found_item2)
        {
         CandleData arrHeiken_mn1[];
         get_arr_heiken(symbol,PERIOD_MN1,arrHeiken_mn1,24,true);
         int size_mn1 = ArraySize(arrHeiken_mn1);

         double lowest = 0,highest = 0;
         get_lowest_highest(arrHeiken_mn1,size_mn1,lowest,highest);

         for(int i = -100; i < 100; i++)
            ObjectDelete(0,"support_resistance_"+appendZero100(i));

         if(lowest > 0 && highest > 0)
           {
            int step = (int)((highest-lowest)/amp_w1)+1;
            double amp_draw = (highest-lowest)/step;

            datetime time_fr = date2-TIME_OF_ONE_W1_CANDLE;
            datetime time_to = date2;
            for(int i = -10; i < step+10; i++)
              {
               double line = lowest+i*amp_draw;
               create_trend_line("support_resistance_"+appendZero100(i),time_fr,line,time_to,line,clrBlack,STYLE_SOLID,1,true,(Period() > PERIOD_D1),true,false);
              }
           }
        }

      if(false && Period() < PERIOD_W1)
        {
         double price_min = MathMin(price1,price2);
         double price_max = MathMax(price1,price2);
         datetime draw_time = AddCandlesToDate(TimeCurrent(),MathMin(21,count2));
         create_trend_line("LINE_AMP_FIBO",draw_time,price_min,draw_time,price_max,clrDimGray,STYLE_SOLID,10);
         ObjectSetInteger(0,"LINE_AMP_FIBO",OBJPROP_STATE,true);
         ObjectSetInteger(0,"LINE_AMP_FIBO",OBJPROP_SELECTED,true);
         ObjectSetInteger(0,"LINE_AMP_FIBO",OBJPROP_SELECTABLE,true);

         draw_time += TIME_OF_ONE_W1_CANDLE;
         double mid = (price_min+price_max)/2;
         price_min = mid-amp_w1/2;
         price_max = mid+amp_w1/2;
         create_trend_line("LINE_AMP_W",draw_time,price_min,draw_time,price_max,clrDimGray,STYLE_SOLID,10);
         ObjectSetInteger(0,"LINE_AMP_W",OBJPROP_STATE,true);
         ObjectSetInteger(0,"LINE_AMP_W",OBJPROP_SELECTED,true);
         ObjectSetInteger(0,"LINE_AMP_W",OBJPROP_SELECTABLE,true);
        }
      else
        {
         ObjectDelete(0,"LINE_AMP_FIBO");
         ObjectDelete(0,"LINE_AMP_W");
        }


      //double lunarCycle = 29.53058867 d
      double lowest_5p = MathMin(MathMin(price1,price2),MathMin(price3,lowest_5p));
      datetime current_time = TimeCurrent();  // Lấy thời gian hiện tại
      datetime moon_time;
      string pre_moon_phase = "";
      bool found_cur_phase = false;
      //datetime date2 = iTime(symbol,PERIOD_D1,itemIdx2);
      for(int i=itemIdx2+265; i>=-265; i--)
        {
         if(i >= 0)
           {
            // Thời gian cho các ngày đã xảy ra
            moon_time = date2-i*TIME_OF_ONE_D1_CANDLE;
           }
         else
           {
            // Tính thời gian cho các ngày trong tương lai
            moon_time = date2+(TIME_OF_ONE_D1_CANDLE * MathAbs(i));
           }

         string moon_phase = GetMoonPhaseName(moon_time);
         if(moon_phase != "")
           {
            if(pre_moon_phase != moon_phase)
              {
               pre_moon_phase = moon_phase;
               //if(Period()==PERIOD_H4)
               create_label("Moon.D"+appendZero100(i),moon_time,lowest_5p,StringSubstr(moon_phase,0,1));

               color crlColor = clrBlack;
               ENUM_LINE_STYLE style = STYLE_DOT;
               if(moon_phase=="New")
                 {
                  //style = STYLE_SOLID;
                  crlColor = clrRed;
                 }
               if(moon_phase=="Full")
                 {
                  //style = STYLE_DASHDOT;
                  crlColor = clrBlue;
                 }

               int width = 1;
               if(found_cur_phase==false && moon_time>current_time)
                 {
                  width=2;
                  found_cur_phase=true;
                 }
               string ver_moon_name = "Moon."+moon_phase+"."+format_date_yyyyMMdd(moon_time);
               create_vertical_line(ver_moon_name,moon_time,crlColor,style,width);

               if(width==2)
                 {
                  int x5,y5;
                  if(ChartTimePriceToXY(0,0,moon_time,bid,x5,y5))
                     createButton("Moon_Count",StringSubstr(moon_phase,0,1)+" Moon "+(string)(int)((moon_time-iTime(symbol,PERIOD_D1,0))/TIME_OF_ONE_D1_CANDLE)+"d "+format_date_ddMM(moon_time),x5,y_start,110,20,clrBlack,clrWhite);
                 }
              }
           }
        }


     }
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
// Ngày gốc: Trăng non vào ngày 6/1/2000
   datetime newMoon = D'2000.01.06 18:14';
// Chu kỳ mặt trăng trung bình (tính bằng giây) = 29.53058867 ngày
   double lunarCycle = 29.53058867 * 24 * 60 * 60;

// Tính thời gian đã trôi qua từ lần trăng non chuẩn
   double timeSinceNewMoon = (double)(time-newMoon);

// Tính phần dư thời gian chia cho chu kỳ mặt trăng (giá trị từ 0 đến 1)
   double moonAge = fmod(timeSinceNewMoon,lunarCycle) / lunarCycle;

   return moonAge;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckSendTeleSeqToday(string symbol,ENUM_TIMEFRAMES TF,string strLable)
  {
   string key = SendTeleSeqMsg_+symbol;
   string value = get_vn_date()+(string)(is_same_symbol(strLable,TREND_BUY)?1:0)
                  +(TF==PERIOD_D1?"999":"")
                  +(TF==PERIOD_H4?"240":"")
                  +(TF==PERIOD_H1?"060":"");

   double sended_value = 0;
   if(GlobalVariableCheck(key))
      sended_value = GlobalVariableGet(key);

   if(sended_value <= 0)
     {
      GlobalVariableSet(key,(double)value);
      SendTelegramMessage(symbol,"SEQ",strLable,true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getMsgSendTeleSeqToday(string symbol)
  {
   string key = SendTeleSeqMsg_+symbol;
   if(GlobalVariableCheck(key))
     {
      double value = GlobalVariableGet(key);
      string strToday = get_vn_date();
      if(value > 0)
        {
         string strValue = (string)value;
         if(is_same_symbol(strValue,strToday))
           {
            string value_buy_h4 = strToday+(string)OP_BUY +"240";
            string value_sel_h4 = strToday+(string)OP_SEL+"240";

            if(is_same_symbol(strValue,value_buy_h4))
               return "H4.Seq."+TREND_BUY+"~"+symbol;
            if(is_same_symbol(strValue,value_sel_h4))
               return "H4.Seq."+TREND_SEL+"~"+symbol;

            string value_buy_h1 = strToday+(string)OP_BUY +"060";
            string value_sel_h1 = strToday+(string)OP_SEL+"060";

            if(is_same_symbol(strValue,value_buy_h1))
               return "H1.Seq."+TREND_BUY+"~"+symbol;
            if(is_same_symbol(strValue,value_sel_h1))
               return "H1.Seq."+TREND_SEL+"~"+symbol;
           }
        }
     }

   return "";
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
void PushMessage(string newMessage)
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

   CreateMessagesBtn();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateMessagesBtn()
  {
   ObjectDelete(0,BtnClearMessage);
   for(int index = 0; index < MAX_MESSAGES; index++)
      ObjectDelete(0,SendTeleSeqMsg_+append1Zero(index));

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

   if(ArraySize(messageArray) > 1)
      createButton(BtnClearMessage,"Clear Msg",580,50,90,18,clrBlack,clrLightGray,6);

   int size = getArraySymbolsSize();
   for(int index = 0; index < ArraySize(messageArray); index++)
     {
      string strLable = messageArray[index];

      string time = "";
      for(int i = 0; i < StringLen(strLable); i++)
         if(fileContent[i]==')')
           {
            time = StringSubstr(fileContent,0,i+1);
            break;
           }

      string symbol = "";
      for(int i = 0; i < size; i++)
        {
         string temp_symbol = getSymbolAtIndex(i);
         if(is_same_symbol(strLable,temp_symbol))
           {
            symbol = temp_symbol;
            break;
           }
        }

      string tf = "";
      if(is_same_symbol(strLable,"D1"))
         tf = "D1";
      if(is_same_symbol(strLable,"H4"))
         tf = "H4";
      if(is_same_symbol(strLable,"H1"))
         tf = "H1";

      string find_trend = is_same_symbol(strLable,TREND_BUY)?TREND_BUY
                          :is_same_symbol(strLable,TREND_SEL)?TREND_SEL:"";

      string lable = time+" "+tf+" "+symbol+" "+find_trend;

      createButton(SendTeleSeqMsg_+append1Zero(index),lable,470,70+index*20,200,18,clrBlack,is_same_symbol(strLable,Symbol())?clrActiveBtn:clrWhite,6);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_yyyymmdd(datetime time)
  {
   MqlDateTime cur_time;
   TimeToStruct(time,cur_time);

   string current_yyyymmdd = (string)cur_time.year +
                             StringFormat("%02d",cur_time.mon) +
                             StringFormat("%02d",cur_time.day);
   return current_yyyymmdd;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check_Open_Position_By_Stoc(string symbol,string find_trend,string mask_auto_trade_by)
  {
   bool is_wating_buy = GetGlobalVariable(BtnWaitToBuy+symbol)==AUTO_TRADE_ON;
   bool is_wating_sel = GetGlobalVariable(BtnWaitToSel+symbol)==AUTO_TRADE_ON;

   bool allow_trade = false;
   if(find_trend==TREND_BUY && is_wating_buy)
      allow_trade = true;
   if(find_trend==TREND_SEL && is_wating_sel)
      allow_trade = true;

   if(allow_trade==false)
      return false;

   datetime today = iTime(symbol,PERIOD_D1,0);
   double best_entry_buy = 0,best_entry_sel = 0;
   int count_buy = 0,count_sel = 0,count_today_buy = 0,count_today_sel = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(),symbol))
           {
            if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) && is_same_symbol(find_trend,TREND_BUY))
              {
               count_buy += 1;
               if(m_position.Time() >= today)
                  count_today_buy += 1;

               if(best_entry_buy==0 || best_entry_buy > m_position.PriceOpen())
                  best_entry_buy = m_position.PriceOpen();
              }

            if(is_same_symbol(m_position.TypeDescription(),TREND_SEL) && is_same_symbol(find_trend,TREND_SEL))
              {
               count_sel += 1;
               if(m_position.Time() >= today)
                  count_today_sel += 1;

               if(best_entry_sel==0 || best_entry_sel < m_position.PriceOpen())
                  best_entry_sel = m_position.PriceOpen();
              }
           }

   if(is_same_symbol(find_trend,TREND_BUY) || is_same_symbol(find_trend,TREND_SEL))
     {
      double AMP_DCA = get_AMP_DCA(symbol,PERIOD_D1);
      double AMP_X3L = get_AMP_SLW(symbol);

      int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      double vol_1L = calc_volume_by_amp(symbol,AMP_X3L,Risk_1L_By_Account_Balance());

      int count_next = is_same_symbol(find_trend,TREND_BUY)?count_buy+1:is_same_symbol(find_trend,TREND_SEL)?count_sel+1:1;
      string comment_1 = mask_auto_trade_by+create_comment("",find_trend,count_next);

      double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
      double price = (bid+ask)/2;

      bool allow_trade_today = false;

      if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) && (count_buy==0 || count_today_buy==0))
         allow_trade_today = true;

      if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) && count_today_buy >0 && count_buy > 0 && best_entry_buy > 0)
         if(best_entry_buy-AMP_DCA > price)
            allow_trade_today = true;

      if(is_same_symbol(m_position.TypeDescription(),TREND_SEL) && (count_sel==0 || count_today_sel==0))
         allow_trade_today = true;

      if(is_same_symbol(m_position.TypeDescription(),TREND_SEL) && count_today_sel > 0 && count_sel > 0 && best_entry_sel > 0)
         if(best_entry_sel+AMP_DCA < price)
            allow_trade_today = true;


      string msg = mask_auto_trade_by+" "+symbol+" "+find_trend
                   +" b:"+(string)count_buy
                   +" s:"+(string)count_sel
                   +comment_1;
      //+ " today_b:"+(string)count_today_buy
      //+ " today_s:"+(string)count_today_sel;
      //+ " best_b:"+DoubleToString(best_entry_buy,digits)
      //+ " best_s:"+DoubleToString(best_entry_sel,digits);

      if(allow_trade_today)
        {
         bool market_ok = Open_Position(symbol,find_trend,vol_1L,0.0,0.0,comment_1);

         if(market_ok)
           {
            msg = "(DONE)" +" "+msg;
            SendTelegramMessage(symbol,find_trend,msg,true);

            PushMessage(get_vntime()+msg);
            Sleep(500);
            return true;
           }
        }

     }

   return false;
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
   double AMP_X3L = get_AMP_SLW(symbol);

   double vol_1L = calc_volume_by_amp(symbol,AMP_X3L,MathAbs(risk));

   double amp_tp = NormalizeDouble(AMP_X3L*2/3,digits);
   string find_trend = is_same_symbol(TREND_TYPE,TREND_BUY)?TREND_BUY:is_same_symbol(TREND_TYPE,TREND_SEL)?TREND_SEL:"";
   double TP_1 = is_same_symbol(TREND_TYPE,TREND_BUY)?cur_price+amp_tp  :is_same_symbol(TREND_TYPE,TREND_SEL)?cur_price-amp_tp  :0;
   double TP_2 = is_same_symbol(TREND_TYPE,TREND_BUY)?cur_price+amp_tp  :is_same_symbol(TREND_TYPE,TREND_SEL)?cur_price-amp_tp  :0;
   double TP_3 = 0;

   if(TREND_TYPE != "")
     {
      string comment_1 = mask_count_triple+create_comment("",find_trend,1);
      string comment_2 = mask_count_triple+create_comment("",find_trend,2);
      string comment_3 = mask_count_triple+create_comment("",find_trend,3);

      bool market_ok = Open_Position(symbol,TREND_TYPE,vol_1L,0.0,NormalizeDouble(TP_3,digits),comment_3,price_limit);

      if(market_ok)
         market_ok   = Open_Position(symbol,TREND_TYPE,vol_1L,0.0,NormalizeDouble(TP_2,digits),comment_2,price_limit);

      if(market_ok)
         market_ok   = Open_Position(symbol,TREND_TYPE,vol_1L,0.0,NormalizeDouble(TP_1,digits),comment_1,price_limit);

      if(market_ok)
         return true;
     }


   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TRIPLE_ORDER(string symbol,string TREND_TYPE,double risk,string mask_count_triple)
  {
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));

   double AMP_X3L = get_AMP_SLW(symbol);

   double vol_1L = calc_volume_by_amp(symbol,AMP_X3L,MathAbs(risk));

   double amp_tp = NormalizeDouble(AMP_X3L*2/3,digits);
   string find_trend = is_same_symbol(TREND_TYPE,TREND_BUY)?TREND_BUY:is_same_symbol(TREND_TYPE,TREND_SEL)?TREND_SEL:"";
   double TP_1 = is_same_symbol(TREND_TYPE,TREND_BUY)?cur_price+amp_tp  :is_same_symbol(TREND_TYPE,TREND_SEL)?cur_price-amp_tp  :0;
   double TP_2 = is_same_symbol(TREND_TYPE,TREND_BUY)?cur_price+amp_tp  :is_same_symbol(TREND_TYPE,TREND_SEL)?cur_price-amp_tp  :0;
   double TP_3 = 0;

   if(TREND_TYPE != "")
     {
      string comment_1 = mask_count_triple+create_comment("",find_trend,1);
      string comment_2 = mask_count_triple+create_comment("",find_trend,2);
      string comment_3 = mask_count_triple+create_comment("",find_trend,3);

      bool market_ok = Open_Position(symbol,TREND_TYPE,vol_1L,0.0,NormalizeDouble(TP_3,digits),comment_3);

      if(market_ok)
         market_ok   = Open_Position(symbol,TREND_TYPE,vol_1L,0.0,NormalizeDouble(TP_2,digits),comment_2);

      if(market_ok)
         market_ok   = Open_Position(symbol,TREND_TYPE,vol_1L,0.0,NormalizeDouble(TP_1,digits),comment_1);

      if(market_ok)
         return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetGlobalVariable(string varName)
  {
   if(GlobalVariableCheck(varName))
      return GlobalVariableGet(varName);
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_day_stop_trade(string symbol,bool hasOpenOrder)
  {
   string result = "";

   if(GetGlobalVariable(BtnTpDay_06_07+"_"+symbol) > 0)
      result += "_6_7_";
   if(GetGlobalVariable(BtnTpDay_13_14+"_"+symbol) > 0)
      result += "_13_14_";
   if(GetGlobalVariable(BtnTpDay_20_21+"_"+symbol) > 0)
      result += "_20_21_";
   if(GetGlobalVariable(BtnTpDay_27_28+"_"+symbol) > 0)
      result += "_27_28_";
   if(GetGlobalVariable(BtnTpDay_34_35+"_"+symbol) > 0)
      result += "_34_35_";

   if(result=="" && hasOpenOrder)
     {
      GlobalVariableSet(BtnTpDay_27_28+"_"+symbol,1);
      return "_27_28_";
     }

   return result;
  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void do_hedging(string symbol)
//  {
//   double global_bot_count_hedg_buy = 0;
//   double global_bot_count_hedg_sel = 0;
//   double total_vol_buy = 0,total_vol_sel = 0;
//   for(int i = OrdersTotal()-1; i >= 0; i--)
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//         if(is_same_symbol(m_position.Symbol(),symbol))
//           {
//            ifis_same_symbol(m_position.TypeDescription(),TREND_BUY)
//              {
//               total_vol_buy += m_position.Volume();
//               if(is_same_symbol(m_position.Comment(),MASK_HEDG))
//                  global_bot_count_hedg_buy += 1;
//              }
//
//            ifis_same_symbol(m_position.TypeDescription(),TREND_SEL)
//              {
//               total_vol_sel += m_position.Volume();
//               if(is_same_symbol(m_position.Comment(),MASK_HEDG))
//                  global_bot_count_hedg_sel += 1;
//              }
//           }
//
//   if(MathAbs(total_vol_buy-total_vol_sel) > 0.01)
//     {
//      double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
//      double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
//      int OP_TYPE = total_vol_buy > total_vol_sel?OP_SELL:OP_BUY;
//      int count = (int)(total_vol_buy > total_vol_sel?global_bot_count_hedg_sel:global_bot_count_hedg_buy)+1;
//      string TREND_TYPE = total_vol_buy > total_vol_sel?TREND_SEL:TREND_BUY;
//
//      double hedg_volume = MathAbs(total_vol_buy-total_vol_sel)-0.01;
//      string hedg_comment = create_comment(MASK_HEDG,TREND_TYPE,count);
//      bool hedging_ok = Open_Position(symbol,OP_TYPE,hedg_volume,0.0,0.0,hedg_comment);
//      if(hedging_ok)
//        {
//         hedg_comment = create_comment(MASK_HEDG,TREND_TYPE,0);
//         hedging_ok = Open_Position(symbol,OP_TYPE,0.01,0.0,0.0,hedg_comment);
//
//         SendTelegramMessage(symbol,MASK_HEDG,"hedging_ok: "+symbol+"    "+(string)hedg_volume+"lot.",false);
//        }
//     }
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Position(string symbol,string TREND_TYPE,double volume,double sl,double tp,string comment,double priceLimit=0)
  {
   printf("Open_Position symbol: "+symbol+" "+TREND_TYPE+" volume:"
          +(string) volume+" sl:"+(string) sl+" tp:"+(string) tp+" comment:"+(string) comment);

   ResetLastError();

   int demm = 1;
   while(demm < 3)
     {
      bool result = false;

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
      else
         printf("Open_Position Error:"+(string)GetLastError());

      demm++;
      Sleep(500); //milliseconds
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_main_control_screen()
  {
   int screen_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   bool draw_common_btn = screen_width < (140+215+375)?false:true; // 1646,1216 > 800
   return draw_common_btn;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime AddCandlesToDate(datetime date1,int candles)
  {
   int added_days = 0;
   datetime new_date = date1;

   while(candles > 0)
     {
      new_date += 24 * 3600; // Thêm một ngày
      //int day_of_week = TimeDayOfWeek(new_date);

      // Kiểm tra nếu ngày mới là ngày trong tuần (không phải thứ Bảy hoặc Chủ Nhật)
      //if(day_of_week != 0 && day_of_week != 6)
        {
         candles--;
        }
     }

   return new_date;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountD1Candles(string symbol,datetime date_start,datetime date_end)
  {
   int timeframe = PERIOD_D1; // D1 timeframe
   int candle_count = 0;

   for(int i = 1; i < LIMIT_D; i++)
     {
      datetime candle_time = iTime(symbol,PERIOD_D1,i);

      if(candle_time >= date_start && candle_time <= date_end)
        {
         //int day_of_week = TimeDayOfWeek(candle_time);
         candle_count++;

        }
     }

   return candle_count;
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

   double levels[30] = {0.0,0.236,0.382,0.5,0.618,0.764
                        ,1.0,1.236,1.382,1.5,1.618
                        ,2.0,2.236,2.382,2.5,2.618
                        ,3.0
                        ,4.0
                        ,-0.236,-0.382,-0.5,-0.618,-0.882
                        ,-1.0//,-1.236,-1.382,-1.5,-1.618
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
         width = 2;
      ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,width);
     }

   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);


   double amp_fibo = MathAbs(price2-price1);
   datetime time_max = time1 > time2?time1:time2;
   datetime time_min = time1 > time2?time2:time1;
   create_trend_line(name+"_0",time_min,MathMin(price1,price2)-amp_fibo*0,TimeCurrent(),MathMin(price1,price2)-amp_fibo*0,clrBlack,STYLE_SOLID,2,false,true,true,false);
   create_trend_line(name+"_1",time_min,MathMax(price1,price2)+amp_fibo*0,TimeCurrent(),MathMax(price1,price2)+amp_fibo*0,clrBlack,STYLE_SOLID,2,false,true,true,false);
   create_trend_line(name+"-1",time_max,MathMin(price1,price2)-amp_fibo*1,TimeCurrent(),MathMin(price1,price2)-amp_fibo*1,clrBlack,STYLE_SOLID,2,false,true,true,false);
   create_trend_line(name+"+1",time_max,MathMax(price1,price2)+amp_fibo*1,TimeCurrent(),MathMax(price1,price2)+amp_fibo*1,clrBlack,STYLE_SOLID,2,false,true,true,false);
   create_trend_line(name+"-2",time_max,MathMin(price1,price2)-amp_fibo*2,TimeCurrent(),MathMin(price1,price2)-amp_fibo*2,clrBlack,STYLE_SOLID,2,false,true,true,false);
   create_trend_line(name+"+2",time_max,MathMax(price1,price2)+amp_fibo*2,TimeCurrent(),MathMax(price1,price2)+amp_fibo*2,clrBlack,STYLE_SOLID,2,false,true,true,false);
   create_trend_line(name+"-3",time_max,MathMin(price1,price2)-amp_fibo*3,TimeCurrent(),MathMin(price1,price2)-amp_fibo*3,clrBlack,STYLE_SOLID,2,false,true,true,false);
   create_trend_line(name+"+3",time_max,MathMax(price1,price2)+amp_fibo*3,TimeCurrent(),MathMax(price1,price2)+amp_fibo*3,clrBlack,STYLE_SOLID,2,false,true,true,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindMACDExtremes(string symbol, ENUM_TIMEFRAMES timeframe,int line_width)
  {
   string TF_=get_time_frame_name(timeframe)+"_";

//int totalObjects = ObjectsTotal(0);
//for(int i = 0; i < totalObjects-1; i++)
//  {
//   string objectName = ObjectName(0,i);
//   if(is_same_symbol(objectName,"MACD"))
//      ObjectDelete(0,objectName);
//  }

// Lấy handle của chỉ báo MACD
   int m_handle_macd = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
     {
      Alert("MACD handle is invalid.");
      return;
     }

// Khai báo các buffer để chứa giá trị MACD Main và Signal
   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main, true);

// Copy giá trị MACD Main
   int copied_main = CopyBuffer(m_handle_macd,0,0,300,m_buff_MACD_main); // Chỉ số 0: MACD Main Line
   if(copied_main <= 0)
     {
      Alert("Failed to copy MACD buffers.");
      return;
     }

   int highest_positive_index = -1; // Chỉ số của nến có Histogram cao nhất khi dương
   int lowest_negative_index = -1;  // Chỉ số của nến có Histogram thấp nhất khi âm
   double highest_positive_value = -DBL_MAX; // Histogram cao nhất khi dương
   double lowest_negative_value = DBL_MAX;   // Histogram thấp nhất khi âm
   bool is_positive_wave = false;  // Đánh dấu sóng dương
   bool is_negative_wave = false;  // Đánh dấu sóng âm

   datetime add_time=iTime(symbol, timeframe,0)-iTime(symbol, timeframe,1);
   double max_price=0,min_price=0;
   int index_max_price=0,index_min_price=0;
// Duyệt qua các nến để tìm giá trị Histogram
   for(int i = 1; i < copied_main; i++)
     {
      double macd_histogram = m_buff_MACD_main[i];

      // Kết thúc sóng dương, vẽ đường thẳng qua nến có Histogram cao nhất
      if(is_positive_wave && macd_histogram < 0)
        {
         double hig=iHigh(symbol,timeframe,highest_positive_index);
         datetime time=iTime(symbol, timeframe, highest_positive_index);

         create_vertical_line("MACD_HIG_"+TF_+ appendZero100(highest_positive_index), time,clrRed,STYLE_SOLID,line_width);
         create_trend_line("MACD_HIG_"+TF_+appendZero100(highest_positive_index)+"_",time-add_time*4,hig, time+add_time*4,hig,clrRed,STYLE_SOLID,line_width);

         is_positive_wave = false; // Kết thúc sóng dương

         if(max_price==0 || max_price<hig)
           {
            max_price=hig;
            index_max_price=highest_positive_index;
           }

         if(min_price==0 || min_price>hig)
           {
            //min_price=hig;
            //index_min_price=highest_positive_index;
           }
        }

      // Kết thúc sóng âm, vẽ đường thẳng qua nến có Histogram thấp nhất
      if(is_negative_wave && macd_histogram > 0)
        {
         double low=iLow(symbol,timeframe,lowest_negative_index);
         datetime time=iTime(symbol, timeframe, lowest_negative_index);

         create_vertical_line("MACD_LOW_"+TF_+appendZero100(lowest_negative_index),time, clrBlue,STYLE_SOLID,line_width);
         create_trend_line("MACD_LOW_"+TF_+appendZero100(lowest_negative_index)+"_",time-add_time*4,low,time+add_time*4,low,clrBlue,STYLE_SOLID,line_width);

         is_negative_wave = false; // Kết thúc sóng âm

         if(max_price==0 || max_price<low)
           {
            //max_price=low;
            //index_max_price=lowest_negative_index;
           }

         if(min_price==0 || min_price>low)
           {
            min_price=low;
            index_min_price=lowest_negative_index;
           }
        }

      // Kiểm tra Histogram dương (sóng dương)
      if(macd_histogram > 0)
        {
         is_positive_wave = true;
         is_negative_wave = false; // Kết thúc sóng âm
         lowest_negative_value = DBL_MAX; // Reset giá trị thấp nhất

         if(macd_histogram > highest_positive_value)
           {
            highest_positive_value = macd_histogram;
            highest_positive_index = i; // Cập nhật chỉ số nến có Histogram cao nhất
           }
        }

      // Kiểm tra Histogram âm (sóng âm)
      if(macd_histogram < 0)
        {
         is_negative_wave = true;
         is_positive_wave = false;           // Kết thúc sóng dương
         highest_positive_value = -DBL_MAX;  // Reset giá trị cao nhất

         if(macd_histogram < lowest_negative_value)
           {
            lowest_negative_value = macd_histogram;
            lowest_negative_index = i; // Cập nhật chỉ số nến có Histogram thấp nhất
           }
        }
     }

//double mid_price=(max_price+min_price)/2;
//int index_mid_price=(int)(MathAbs(index_max_price+index_min_price)/2);
//
//create_vertical_line(".MACD.V.HIG",iTime(symbol, timeframe,index_max_price),clrBlue,STYLE_SOLID,2);
//create_vertical_line(".MACD.V.MID",iTime(symbol, timeframe,index_mid_price),clrGreen,STYLE_SOLID,1);
//create_vertical_line(".MACD.V.LOW",iTime(symbol, timeframe,index_min_price),clrBlue,STYLE_SOLID,2);
//
//create_trend_line(".MACD.HIG",iTime(symbol, timeframe,index_min_price),max_price,iTime(symbol, timeframe,index_max_price),max_price,clrBlue,STYLE_SOLID,2);
//create_trend_line(".MACD.MID",iTime(symbol, timeframe,index_min_price),mid_price,iTime(symbol, timeframe,index_max_price),mid_price,clrGreen,STYLE_SOLID,1);
//create_trend_line(".MACD.LOW",iTime(symbol, timeframe,index_min_price),min_price,iTime(symbol, timeframe,index_max_price),min_price,clrBlue,STYLE_SOLID,2);
//
//DrawFibonacciFan("FIBO_FAN_S",iTime(symbol,timeframe,index_min_price),max_price,iTime(symbol,timeframe,index_max_price),mid_price,TREND_SEL);
//DrawFibonacciFan("FIBO_FAN_B",iTime(symbol,timeframe,index_min_price),min_price,iTime(symbol,timeframe,index_max_price),(max_price+min_price)/2,TREND_BUY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibonacciFan(string name,datetime time1,double price1,datetime time2,double price2,string TREND)
  {
// Xóa Fibonacci Fan nếu đã tồn tại
   ObjectDelete(0,name);

// Tạo Fibonacci Fan mới
   ObjectCreate(0,name,OBJ_FIBOFAN,0,time1,price1,time2,price2);

   create_trend_line(name+"0.0",time1,price1,time2,price1,clrBlack,STYLE_SOLID,2,false,false);

// Đặt các thuộc tính cho Fibonacci Fan
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);        // Màu của Fibonacci Fan
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);    // Kiểu đường kẻ
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);              // Độ dày của đường kẻ

   color clrLevelColor = TREND==TREND_BUY?clrBlue:clrRed;
//double levels[] = {0.0,0.236,0.382,0.5,0.618,0.764,0.882,1.0,1.118,1.236,1.382,1.5,1.618};

   double levels[];
   ArrayResize(levels,8);  // Số phần tử cho TREND_BUY
   levels[0] = 0.0;
   levels[1] = 0.236;
   levels[2] = 0.382;
   levels[3] = 0.5;
   levels[4] = 0.618;
   levels[5] = 0.764;
   levels[6] = 0.882;
   levels[7] = 1.0;


   int size = ArraySize(levels);

   ObjectSetInteger(0,name,OBJPROP_LEVELS,size);
   for(int i = 0; i < size; i++)
     {
      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels[i]);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrLevelColor);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_DOT);
      ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,1);
      if(TREND==TREND_BUY)
         ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,format_double_to_string(levels[i]*100,1)); // DoubleToString(levels[i],1)
     }

   ObjectSetInteger(0,name,OBJPROP_BACK,false);           // Hiển thị ở phía sau
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);      // Không được chọn mặc định
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);    // Có thể chọn được
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);         // Không ẩn
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawManualFibonacciRetracement(string name,datetime time1,double price1,datetime time2,double price2,color clrLevelColor=clrNONE)
  {
   double values[24] = {0.0//,0.236,0.382,0.5,0.618,0.764
                        ,1.0//,1.236,1.382,1.5,1.618
                        ,2.0//,2.236,2.382,2.5,2.618
                        ,3.0
                        ,4.0
                        ,-1.0//,-0.236,-0.382,-0.5,-0.618
                        ,-2.0
                        ,-3.0
                        ,-4.0
                       };
   int size = ArraySize(values);

   for(int i = 0; i < size; i++)
     {
      string line_name = name+"_Level_"+DoubleToString(100*values[i],1)+"%";
      ObjectDelete(0,line_name);
     }

   for(int i = 0; i < size; i++)
     {
      double level_price = price1+(price2-price1) * values[i];
      string line_name = name+"_Level_"+DoubleToString(100*values[i],1)+"%";

      bool ray = false;
      int width = 1;
      int style = STYLE_DOT;

      if(values[i]==0.0 || values[i]==1.0 || values[i]==2.0 || values[i]==3.0 || values[i]==4.0 || values[i]==-1.0 || values[i]==-2.0)
         style = STYLE_SOLID;

      create_trend_line(line_name,time1,level_price,time2,level_price,clrLevelColor,style,width,ray,ray,true,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetDateFromFiboTimeLevel(string name,double level)
  {
   datetime date_at_level = ObjectGetTimeByValue(0,name,level);
   return date_at_level;
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
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);      // Kiểu đường kẻ (nét chấm)
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);              // Độ dày của đường kẻ

   double levels[] = {0.0,0.236,0.5,0.764,1.0,1.236,1.5,1.764,2.0,2.382,2.5,2.618,3.0,4.0,5.0,6.0,7.0};
   int levels_count = ArraySize(levels);
   ObjectSetInteger(0,name,OBJPROP_LEVELS,levels_count);

   for(int i = 0; i < levels_count; i++)
     {
      int style = STYLE_DOT;
      if(levels[i]==0.0 || levels[i]==1.0 || levels[i]==2.0 || levels[i]==3.0)
         style = STYLE_DOT;

      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,levels[i]);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrGray);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,style);
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,DoubleToString(levels[i],3));
     }

   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true); // Kéo dài qua phải

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Lines(string symbol)
  {
   if(is_main_control_screen() && is_same_symbol(symbol,Symbol()))
     {
      CandleData arrHeiken_D1[];
      get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,35,true);

      string prifix = "draw_";
      for(int col = 0; col < 91; col ++)
        {
         double low_di = iLow(symbol,PERIOD_D1,col);
         double close_di = iClose(symbol,PERIOD_D1,col);
         double hig_di = iHigh(symbol,PERIOD_D1,col);

         datetime time_di = iTime(symbol,PERIOD_D1,col);
         datetime time_di0 = col==0?TimeCurrent():iTime(symbol,PERIOD_D1,col-1);

         if(col < ArraySize(arrHeiken_D1))
            GetHighestLowestM5Times(symbol,time_di,time_di0,col);
        }
      //-------------------------------------------------------------------------------------------------
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heiken(string symbol)
  {
   if(is_same_symbol(symbol,Symbol())==false)
      return;

   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));

   datetime time_1w = iTime(symbol,PERIOD_W1,1)-iTime(symbol,PERIOD_W1,2);
   datetime time_1d = iTime(symbol,PERIOD_D1,1)-iTime(symbol,PERIOD_D1,2);
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_mn1[];
   get_arr_heiken(symbol,PERIOD_MN1,arrHeiken_mn1,25,true);
   for(int i = 0; i <= 20; i++)
     {
      color clrColorW = clrLightGray;
      if(arrHeiken_mn1[i+1].ma10>0 && arrHeiken_mn1[i].ma10>0)
         create_trend_line("Ma10M_"+append1Zero(i+1)+"_"+append1Zero(i),
                           arrHeiken_mn1[i+1].time,arrHeiken_mn1[i+1].ma10,
                           (i==0?TimeCurrent():arrHeiken_mn1[i].time),arrHeiken_mn1[i].ma10,clrColorW,STYLE_SOLID,25,false,false,true,true);

      if(i==0)
         create_label("Ma10M",TimeCurrent(),arrHeiken_mn1[0].ma10,"   M "+format_double_to_string(NormalizeDouble(arrHeiken_mn1[0].ma10,digits-1),digits-1));
     }
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_W1[];
   get_arr_heiken(symbol,PERIOD_W1,arrHeiken_W1,50,true);
   int size_w1 = ArraySize(arrHeiken_W1)-5;
   if(size_w1 > 10)
     {
      for(int i = 0; i < size_w1; i++)
        {
         color clrColorW = clrLightGray;
         if((Period()<PERIOD_W1) && (arrHeiken_W1[i+1].ma10>0) && (arrHeiken_W1[i].ma10>0))
            create_trend_line("Ma10W_"+append1Zero(i+1)+"_"+append1Zero(i),
                              arrHeiken_W1[i+1].time,arrHeiken_W1[i+1].ma10,
                              (i==0?TimeCurrent():arrHeiken_W1[i].time),arrHeiken_W1[i].ma10,clrColorW,STYLE_SOLID,20);
         if(i==0)
            create_label("Ma10W",TimeCurrent(),arrHeiken_W1[0].ma10,"   W "+format_double_to_string(NormalizeDouble(arrHeiken_W1[0].ma10,digits-1),digits-1));

         string candle_name = "hei_w_"+append1Zero(i);
         datetime time_i2 = arrHeiken_W1[i].time;

         if(Period() > PERIOD_D1 || i==0)
            continue;

         string trend_w = arrHeiken_W1[i].trend_heiken;

         //double mid = arrHeiken_W1[i].trend_heiken==TREND_BUY?arrHeiken_W1[i].low:arrHeiken_W1[i].high;
         double mid = (arrHeiken_W1[i].open+arrHeiken_W1[i].close)/2;
         datetime time_i1 = (i==0)?time_i2+time_1w-time_1d:arrHeiken_W1[i-1].time;
         color clrBody = trend_w==TREND_BUY?clrBlue:trend_w==TREND_SEL?clrRed:clrNONE;
         color clrColor = trend_w==TREND_BUY?clrBlue:trend_w==TREND_SEL?clrRed:clrNONE;

         bool is_fill_body = false;
         if((arrHeiken_W1[i].count_heiken==7) || (arrHeiken_W1[i].count_heiken==1))
           {
            clrBody = trend_w==TREND_BUY?clrLightBlue:clrLightPink;
            //is_fill_body = true;

            create_label(candle_name+".No",arrHeiken_W1[i].time,mid,""+(string)arrHeiken_W1[i].count_heiken,trend_w,true,15,true);
           }
         else
            create_label(candle_name+".No",     arrHeiken_W1[i].time,mid,"   "+(string)arrHeiken_W1[i].count_heiken,trend_w,true,10,false);

         datetime time_center = ((time_i2+time_i1)/2)-TIME_OF_ONE_H1_CANDLE;
         create_filled_rectangle(candle_name+"_body",time_i2,arrHeiken_W1[i].open,time_i1,arrHeiken_W1[i].close,clrBody,true,is_fill_body,trend_w,1);
        }
     }
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_D1[];
   get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,LIMIT_D,true);
   int size_d1 = ArraySize(arrHeiken_D1)-5;
   if(size_d1 > 50)
     {
      for(int i = 0; i < size_d1; i++)
        {
         color clrColorD = clrLightGray;

         if((Period()<PERIOD_W1) && (arrHeiken_D1[i+1].ma10>0) && (arrHeiken_D1[i].ma10>0))
            create_trend_line("Ma10D_"+append1Zero(i+1)+"_"+append1Zero(i),
                              arrHeiken_D1[i+1].time,arrHeiken_D1[i+1].ma10,
                              (i==0?TimeCurrent():arrHeiken_D1[i].time),arrHeiken_D1[i].ma10,clrColorD,STYLE_SOLID,10);

         if(i==0)
            create_label("Ma10D",TimeCurrent(),arrHeiken_D1[0].ma10,"   D "+format_double_to_string(NormalizeDouble(arrHeiken_D1[0].ma10,digits-1),digits-1));


         if(Period() > PERIOD_H4)
            continue;

         string candle_name = "hei_d_"+appendZero100(i);

         CandleData candle_i = arrHeiken_D1[i];
         string sub_name = "_"+(string)(i+1)+"_"+(string)i;
         datetime time_i1;

         double realOpen = iOpen(symbol,PERIOD_D1,i);
         datetime time_i2 = iTime(symbol,PERIOD_D1,i);
         if(i==0)
            time_i1 = time_i2+time_1d;
         else
            time_i1 = iTime(symbol,PERIOD_D1,i-1);

         double low = NormalizeDouble(iLow(symbol,PERIOD_D1,i),digits-2);
         double hig = NormalizeDouble(iHigh(symbol,PERIOD_D1,i),digits-2);

         string trend_by_time = arrHeiken_D1[i].trend_heiken;

         color clrColor = trend_by_time==TREND_BUY?clrLightCyan:trend_by_time==TREND_SEL?C'235,235,235':clrNONE;

         create_filled_rectangle(candle_name,time_i2,low,time_i1,hig,clrColor,false);
        }
     }

   bool is_cur_tab = is_same_symbol(symbol,Symbol());
   if(is_cur_tab)
     {
      CandleData arrHeiken_H4[];
      get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,350,true);
      draw_line_ma10_8020(symbol,PERIOD_H4,arrHeiken_H4,2,2);

      draw_line_ma10_8020(symbol,PERIOD_W1,arrHeiken_W1,3,4);
      draw_line_ma10_8020(symbol,PERIOD_D1,arrHeiken_D1,3,3);
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
void get_time_zones(string symbol,string &date_fr,string &date_to)
  {
   date_fr = "2023.12.31"; //GetFirstWeekOfCurrentMonth();
   date_to = AddWeeksToDate(date_fr,13);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string AddWeeksToDate(string date_fr,int weeks)
  {
// Chuyển đổi chuỗi ngày thành kiểu datetime
   datetime date_value = StringToTime(date_fr);

// Lấy thời gian hiện tại
   datetime current_time = TimeCurrent();

// Tính toán số giây trong một tuần
   int seconds_in_week = 7 * 24 * 3600; // 1 tuần có 7 ngày,mỗi ngày có 24 giờ,mỗi giờ có 3600 giây

   datetime new_date_value = date_value;

// Thêm tuần từng tuần một và kiểm tra nếu ngày mới lớn hơn ngày hiện tại
   for(int i = 0; i < weeks; i++)
     {
      new_date_value += seconds_in_week;
      if(new_date_value > current_time)
        {
         new_date_value -= seconds_in_week; // Bỏ tuần cuối cùng nếu nó vượt quá ngày hiện tại
         break;
        }
     }

// Chuyển đổi datetime mới thành chuỗi ngày
   string date_to = TimeToString(new_date_value,TIME_DATE);

   return date_to;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateWeeksBetweenDates(string date_fr,string date_to)
  {
// Chuyển đổi chuỗi ngày thành kiểu datetime
   datetime datetime_fr = StringToTime(date_fr);
   datetime datetime_to = StringToTime(date_to);

// Tính toán chênh lệch thời gian giữa hai ngày dưới dạng số giây
   int seconds_difference = (int)(datetime_to-datetime_fr);

// Tính toán số giây trong một tuần
   int seconds_in_week = 7 * 24 * 3600; // 1 tuần có 7 ngày,mỗi ngày có 24 giờ,mỗi giờ có 3600 giây

// Tính toán số tuần
   int weeks_difference = (int)(seconds_difference / seconds_in_week);

   return weeks_difference;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_TimeZones(string symbol,string date_form,string date_to,int levels = 20)
  {
   string name = "FiboTimeZones_"+symbol;
   ObjectDelete(1,name);

   ObjectCreate(0,name,OBJ_FIBOTIMES,0,StringToTime(date_form),0,StringToTime(date_to),0);

   ObjectSetInteger(0,name,OBJPROP_LEVELS,levels);
   for(int i = 0; i < levels; i++)
     {
      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,i);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrBlack);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_DOT);
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i,i==0?"0":"");
     }

   ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,OBJ_PERIOD_W1); // OBJ_PERIOD_D1|
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReplaceStringAfter(string str_input,string match_string,string replacement)
  {
// Tìm vị trí của ký tự "$"
   int pos = StringFind(str_input,match_string);

// Nếu không tìm thấy ký tự "$",trả về chuỗi gốc
   if(pos==-1)
      return str_input;

// Tách phần trước và phần sau của ký tự "$"
   string beforeDollar = StringSubstr(str_input,0,pos+1);

// Kết hợp phần trước và phần thay thế
   string newString = beforeDollar+replacement;

   return newString;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_CurPrice_Line()
  {
   string symbol = Symbol();
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   create_trend_line("cur_price",TimeCurrent()-TIME_OF_ONE_W1_CANDLE,cur_price,TimeCurrent()+TIME_OF_ONE_W1_CANDLE,cur_price,clrFireBrick,STYLE_DOT,1,true,true);

   create_vertical_line("cur_v_line",TimeCurrent(),clrGray,STYLE_DOT,1,true,false,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string RemoveCharsBeforeTilde(string str_input)
  {
   int tilde_pos = StringFind(str_input,"~");
   if(tilde_pos != -1)
      return StringSubstr(str_input,tilde_pos+1);

   return str_input;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTrendFiltering(string symbol)
  {
   if(is_same_symbol(symbol,Symbol())==false)
      return "";

   CandleData arrHeiken_D1[];
   CandleData arrHeiken_H4[];
   CandleData arrHeiken_H1[];

   get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,35,true);
   get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,20,true);
   get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,20,true);

   string result = "";
   result += " Heiken_D1[0]: "+arrHeiken_D1[0].trend_heiken;
   result += "    Ma10[0]: "+arrHeiken_D1[0].trend_by_ma10;
   result += "\n";

   result += " Heiken_H4[0]: "+arrHeiken_H4[0].trend_heiken;
   result += "    Ma10[0]: "+arrHeiken_H4[0].trend_by_ma10;
   result += "\n";

   result += " Heiken_H1[0]: "+arrHeiken_H1[0].trend_heiken;
   result += "    Ma10[0]: "+arrHeiken_H1[0].trend_by_ma10;
   result += "\n";

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetStartPrice(bool show_mesage=true)
  {
//   double min_close_heiken_h4 = 0;
//   double max_close_heiken_h4 = 0;
//
//   for(int i = 0; i < ArraySize(arrHeiken_H4); i++)
//     {
//      double close = arrHeiken_H4[i].close;
//      if(i==0 || min_close_heiken_h4 > close)
//         min_close_heiken_h4 = close;
//
//      if(i==0 || max_close_heiken_h4 < close)
//         max_close_heiken_h4 = close;
//     }
//
//   if(trend_by_ma10_d1==TREND_BUY)
//     {
//      INIT_START_PRICE = arrHeiken_D1[0].ma10; //min_close_heiken_h4;
//      GlobalVariableSet("MyHorizontalLinePrice",INIT_START_PRICE);
//      ObjectSetDouble(0,START_TRADE_LINE,OBJPROP_PRICE,INIT_START_PRICE);
//      saveAutoTrade();
//     }
//
//   if(trend_by_ma10_d1==TREND_SEL)
//     {
//      INIT_START_PRICE = arrHeiken_D1[0].ma10; //max_close_heiken_h4;
//      GlobalVariableSet("MyHorizontalLinePrice",INIT_START_PRICE);
//      ObjectSetDouble(0,START_TRADE_LINE,OBJPROP_PRICE,INIT_START_PRICE);
//      saveAutoTrade();
//     }
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
void OnChartEvent(const int     id,      // event ID
                  const long&   lparam,  // long type event parameter
                  const double& dparam,  // double type event parameter
                  const string& sparam    // string type event parameter
                 )
  {
   string symbol = Symbol();

   switch(id)
     {
      case CHARTEVENT_OBJECT_CLICK:
         if(sparam==START_TRADE_LINE)
           {
            isDragging = true;
            INIT_START_PRICE = ObjectGetDouble(0,START_TRADE_LINE,OBJPROP_PRICE);
            Print("CHARTEVENT_OBJECT_CLICK "+(string) INIT_START_PRICE);
            GlobalVariableSet("MyHorizontalLinePrice",INIT_START_PRICE);
           }
         else
            isDragging = false;

         break;

      case CHARTEVENT_OBJECT_DRAG:
         if(sparam==START_TRADE_LINE)
           {
            isDragging = false;
            INIT_START_PRICE = ObjectGetDouble(0,START_TRADE_LINE,OBJPROP_PRICE);
            Print("CHARTEVENT_OBJECT_DRAG "+(string) INIT_START_PRICE);
            GlobalVariableSet("MyHorizontalLinePrice",INIT_START_PRICE);
           }
         break;

     }
//-------------------------------------------------------------------------------------------------------

   if(is_same_symbol(sparam,BtnOptionPeriod))
     {
      int PERIOD = PERIOD_D1;
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

      GlobalVariableSet(BtnOptionPeriod,(double)PERIOD);
      Draw_Buttons_Trend(symbol);
     }

   if(is_same_symbol(sparam,BtnD10))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      Print("The lparam=",sparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

      int intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
      if(intPeriod==-1)
         intPeriod = PERIOD_D1;

      OpenChartWindow(buttonLabel,(ENUM_TIMEFRAMES)intPeriod);
     }
//-------------------------------------------------------------------------------------------------------
   if(is_same_symbol(sparam,BtnNoticeDH21) || is_same_symbol(sparam,BtnNoticeD1))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      Print("The lparam=",lparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

      OpenChartWindow(buttonLabel,PERIOD_D1);
     }

   if(is_same_symbol(sparam,BtnTrend) || is_same_symbol(sparam,SendTeleSeqMsg_))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      Print("The lparam=",lparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");
      ENUM_TIMEFRAMES TF = PERIOD_D1;

      if(is_same_symbol(sparam,"W1"))
         TF = PERIOD_W1;
      if(is_same_symbol(sparam,"D1"))
         TF = PERIOD_D1;
      if(is_same_symbol(sparam,"H4"))
         TF = PERIOD_H4;
      if(is_same_symbol(sparam,"H1"))
         TF = PERIOD_H1;

      if(is_same_symbol(sparam,SendTeleSeqMsg_))
         OpenChartWindow(buttonLabel,TF);
      else
         OpenChartWindow(sparam+"."+symbol,TF);
     }

   if(is_same_symbol(sparam,BtnNoticeH4) || is_same_symbol(sparam,BtnTradeD10H4) || is_same_symbol(sparam,BtnTradeWma10))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      Print("The lparam=",sparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

      if(is_same_symbol(sparam,BtnTradeWma10))
         OpenChartWindow(buttonLabel,PERIOD_D1);
      else
         OpenChartWindow(buttonLabel,PERIOD_D1);
     }

   if(is_same_symbol(sparam,BtnNoticeH1))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      Print("The lparam=",sparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

      OpenChartWindow(buttonLabel,PERIOD_H1);
     }

   if(is_same_symbol(sparam,BtnSendNoticeHei) ||
      is_same_symbol(sparam,BtnSendNoticeMacd) ||
      is_same_symbol(sparam,BtnSendNoticeStoc)
     )
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);

      if(is_same_symbol(buttonLabel,TREND_BUY)==false && is_same_symbol(buttonLabel,TREND_SEL)==false)
         buttonLabel += TREND_BUY;
      else
         if(is_same_symbol(buttonLabel,TREND_BUY))
            StringReplace(buttonLabel,TREND_BUY,TREND_SEL);
         else
            if(is_same_symbol(buttonLabel,TREND_SEL))
               StringReplace(buttonLabel,TREND_SEL,"");


      ObjectSetString(0,sparam,OBJPROP_TEXT,buttonLabel);
      saveAutoTrade();

      Draw_Buttons_Trend(symbol);
     }

   if(is_same_symbol(sparam,BtnInitStocH4ByW1Ma10))
     {
      init_stoc_h4_by_w1_ma10();

      Draw_Notice_Ma10D();
     }

   if(is_same_symbol(sparam,BtnResetWaitBuySelM5))
     {
      int size = getArraySymbolsSize();
      for(int index = 0; index < size; index++)
        {
         string temp_symbol = getSymbolAtIndex(index);

         GlobalVariableSet(BtnWaitToBuy+temp_symbol,AUTO_TRADE_OFF);
         GlobalVariableSet(BtnWaitToSel+temp_symbol,AUTO_TRADE_OFF);
        }

      Draw_Notice_Ma10D();
     }

   if(is_same_symbol(sparam,BtnWaitToBuy) || is_same_symbol(sparam,BtnWaitToSel))
     {
      bool AUTO_ENTRY = GetGlobalVariable(sparam+symbol)==AUTO_TRADE_ON;
      //string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      //string msg = sparam+symbol+" "+(string)AUTO_ENTRY+" -> "+(string)(!AUTO_ENTRY);
      //int result = MessageBox(msg+"?","Confirm",MB_YESNOCANCEL);
      //if(result==IDYES)
        {
         color clrColor = clrLightGray;
         if(AUTO_ENTRY)
            GlobalVariableSet(sparam+symbol,AUTO_TRADE_OFF);
         else
           {
            GlobalVariableSet(sparam+symbol,AUTO_TRADE_ON);
            if(is_same_symbol(sparam,BtnWaitToBuy))
               clrColor = clrActiveBtn;
            if(is_same_symbol(sparam,BtnWaitToSel))
               clrColor = clrMistyRose;
           }

         ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrColor);
         Draw_Notice_Ma10D();
        }
     }

   if(is_same_symbol(sparam,BtnOptionAutoExit))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      double auto_trade = 0;
      double old_value = (double)GetGlobalVariable(BtnOptionAutoExit+symbol);
      if(old_value==-1 || old_value==0)
         auto_trade = AUTO_TRADE_ON;
      if(old_value==AUTO_TRADE_ON)
         auto_trade = 0;
      if(is_same_symbol(buttonLabel,TREND_BUY) && is_same_symbol(buttonLabel,TREND_SEL))
         auto_trade = 0;

      printf(symbol+" auto_exit: "+(string)auto_trade+"    AUTO_TRADE_ON: "+(string)AUTO_TRADE_ON);
      GlobalVariableSet(BtnOptionAutoExit+symbol,(double)auto_trade);

      Draw_Buttons_Trend(symbol);
     }

   if(is_same_symbol(sparam,BtnCloseSymbol))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      Print("The lparam=",sparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

      if(is_same_symbol(buttonLabel,symbol)==false)
         return;

      string msg = buttonLabel+"?\n";
      int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
      if(result==IDYES)
        {
         ClosePosition(symbol,TREND_BUY);
         ClosePosition(symbol,TREND_SEL);
         Draw_Notice_Ma10D();
        }
     }

   if(is_same_symbol(sparam,BtnTpSymbol))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      Print("The lparam=",sparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

      if(is_same_symbol(buttonLabel,symbol)==false)
         return;

      //string msg = buttonLabel+"?\n";
      //int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
      //if(result==IDYES)
        {
         ClosePositivePosition(symbol,TREND_BUY);
         ClosePositivePosition(symbol,TREND_SEL);

         ObjectDelete(0,BtnTpSymbol);
         Draw_Notice_Ma10D();
        }
     }


   if(is_same_symbol(sparam,BtnClearMessage))
     {
      WriteFileContent(FILE_NAME_MSG_LIST,"");
      CreateMessagesBtn();
     }

   if(is_same_symbol(sparam,BtnClearChart))
     {
      OnInit();
     }

   if(is_same_symbol(sparam,BtnCloseAllLimit))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      string msg = buttonLabel+"?\n";
      int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
      if(result==IDYES)
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);

            CloseLimitOrder(temp_symbol,TREND_BUY);
            CloseLimitOrder(temp_symbol,TREND_SEL);
           }

         ObjectDelete(0,BtnCloseAllLimit);
         Draw_Notice_Ma10D();
        }
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

         Draw_Notice_Ma10D();
        }
     }

   if(is_same_symbol(sparam,BtnCloseAllTicket))
     {
      return;

      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      string msg = "  BtnCloseAllTicket "+buttonLabel+"?\n";
      int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
      if(result==IDYES)
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);
            ClosePosition(temp_symbol,TREND_BUY);
            ClosePosition(temp_symbol,TREND_SEL);

            CloseLimitOrder(temp_symbol,TREND_BUY);
            CloseLimitOrder(temp_symbol,TREND_SEL);
           }
         Draw_Notice_Ma10D();
        }
     }

   if(is_same_symbol(sparam,BtnTpXauPositive))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      //string msg = "  "+buttonLabel+"?\n";
      //int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
      //if(result==IDYES)
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);
            if(is_same_symbol(temp_symbol,"XAU"))
              {
               ClosePositivePosition(temp_symbol,TREND_BUY);
               ClosePositivePosition(temp_symbol,TREND_SEL);
              }
           }
         Draw_Notice_Ma10D();
        }
     }

   if(is_same_symbol(sparam,BtnTpOthersPositive))
     {
      //string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      //string msg = "  "+buttonLabel+"?\n";
      //int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
      //if(result==IDYES)
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);
            if(is_same_symbol(temp_symbol,"XAU")==false)
              {
               ClosePositivePosition(temp_symbol,TREND_BUY);
               ClosePositivePosition(temp_symbol,TREND_SEL);
              }
           }
         Draw_Notice_Ma10D();
        }
     }

//----------------------------------------------------------------------------------------------------------------
   if(is_same_symbol(sparam,BtnTradeByMa10D) || is_same_symbol(sparam,BtnTradeByRevMa10D))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      Print("The lparam=",sparam," dparam=",dparam," sparam=",sparam," buttonLabel=",buttonLabel," was clicked");

      if(is_same_symbol(buttonLabel,Symbol())==false)
         return;

      string trading_trend = is_same_symbol(buttonLabel,TREND_BUY)?TREND_BUY:is_same_symbol(buttonLabel,TREND_SEL)?TREND_SEL:"";

      if(trading_trend=="")
         return;

      int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      double AMP_DCA = NormalizeDouble(MathMax(get_AMP_DCA(symbol,PERIOD_H4),get_AMP_DCA(symbol,PERIOD_D1)/2),digits);
      double AMP_X3L = get_AMP_SLW(symbol);

      double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
      double cur_price = (bid+ask)/2;

      double sl = calc_SL_7d_for_trade_init(symbol,trading_trend,AMP_X3L);
      double amp_sl = MathMax(AMP_X3L,MathAbs(cur_price-sl));

      double risk_1L = Risk_1L_By_Account_Balance();
      double vol_1percent = calc_volume_by_amp(symbol,amp_sl,risk_1L);
      double vol_limit = NormalizeDouble(vol_1percent,2);
      double vol_market = NormalizeDouble(vol_1percent,2);

      int count_total = 1,count_limit = 0,count_opening = 0;

      for(int i = PositionsTotal()-1; i >= 0; i--)
         if(m_position.SelectByIndex(i))
            if(is_same_symbol(m_position.Symbol(),symbol))
              {
               if(is_same_symbol(m_position.TypeDescription(),trading_trend))
                  count_opening += 1;
              }

      for(int i = OrdersTotal()-1; i >= 0; i--)
         if(m_order.SelectByIndex(i))
            if(is_same_symbol(m_order.Symbol(),symbol))
              {
               if(is_same_symbol(m_order.TypeDescription(),trading_trend))
                  count_limit += 1;
              }

      count_limit += 1;
      count_opening += 1;

      if((count_opening > 1) && (count_limit > 3))
        {
         Alert(symbol+" "+trading_trend+". There is 1 open+1 Limit orders so cannot open more.");
         return;
        }

      string mask = "";
      if(is_same_symbol(sparam,BtnTradeByMa10D))
         mask = MASK_D10;
      if(is_same_symbol(sparam,BtnTradeByRevMa10D))
         mask = MASK_RevD10;

      string comment_market = mask+create_comment(MASK_MARKET,trading_trend,count_total);
      string comment_limit  = mask+create_comment(MASK_LIMIT, trading_trend,count_total);

      double price_limit = is_same_symbol(trading_trend,TREND_BUY)?cur_price-(AMP_DCA*count_limit):is_same_symbol(trading_trend,TREND_SEL)?cur_price+(AMP_DCA*count_limit):0;
      price_limit = NormalizeDouble(price_limit,digits);
      double sl_limit = NormalizeDouble(trading_trend==TREND_BUY?price_limit-AMP_X3L:trading_trend==TREND_SEL?price_limit+AMP_X3L:0,digits);

      double tp_now   = trading_trend==TREND_BUY?cur_price+AMP_X3L*2:cur_price-AMP_X3L*2;
      double tp_limit = trading_trend==TREND_BUY?price_limit+AMP_X3L*1  :price_limit-AMP_X3L*1;

      string strLable = trading_trend+" "+symbol+" Vol "+(string)RISK_BY_PERCENT+"% = "+format_double_to_string(vol_1percent,2)+" lot ("+(string)(int)risk_1L+")";
      string msg = strLable+"?\n";
      msg += "(YES) "+comment_market+"    "+format_double_to_string(vol_market,2)+" lot,SL: "+DoubleToString(sl,digits)+" TP: "+DoubleToString(tp_now,digits)+". Market " "\n";
      msg += "(NO)  "+comment_limit +"   "+format_double_to_string(vol_limit,2)+" lot,SL: "+DoubleToString(sl_limit,digits)+" TP: "+DoubleToString(tp_limit,digits)+". Limit: "+DoubleToString(price_limit,digits)+"\n";

      int result = MessageBox(msg,"Confirm",MB_YESNOCANCEL);
      if(result==IDYES)
        {
         if(count_opening > 1)
           {
            Alert(symbol+" "+trading_trend+". There is 1 open orders so cannot open more.");
            return;
           }

         if(trading_trend != "" && price_limit > 0)
           {
            bool market_ok = Open_Position(Symbol(),trading_trend,vol_market,0.0,0.0,comment_market);
            if(market_ok)
               GlobalVariableSet(BtnTpDay_20_21+"_"+symbol,1);
            Draw_Notice_Ma10D();
           }
        }

      if(result==IDNO)
        {
         if(count_limit > 3)
           {
            Alert(symbol+" "+trading_trend+". There are 3 open limit orders so cannot open more.");
            return;
           }

         trading_trend = is_same_symbol(buttonLabel,TREND_BUY)?TREND_LIMIT_BUY:is_same_symbol(buttonLabel,TREND_SEL)?TREND_LIMIT_SEL:"";

         if(trading_trend != "" && price_limit > 0)
           {
            bool limit_ok = Open_Position(Symbol(),trading_trend,vol_limit,0.0,0.0,comment_limit,price_limit);
            if(limit_ok)
              {
               Draw_Notice_Ma10D();
              }
           }
        }
     }
//-----------------------------------------------------------------------------------------
   if(is_same_symbol(sparam,BtnTpDay_06_07) || is_same_symbol(sparam,BtnTpDay_13_14) ||
      is_same_symbol(sparam,BtnTpDay_20_21) ||
      is_same_symbol(sparam,BtnTpDay_27_28) || is_same_symbol(sparam,BtnTpDay_34_35))
     {
      string key = sparam+"_"+Symbol();
      if(GetGlobalVariable(key) > 0)
         GlobalVariableSet(key,-1);
      else
         GlobalVariableSet(key,1);

      Draw_Notice_Ma10D();
     }
//-----------------------------------------------------------------------------------------
   if(is_same_symbol(sparam,BtnTelegramMessage))
     {
      string buttonLabel = ObjectGetString(0,sparam,OBJPROP_TEXT);
      OpenChartWindow(buttonLabel,PERIOD_D1);
     }
//-------------------------------------------------------------------------------------------------------
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
      double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

      //-----------------------------------------------------------------------

      //-----------------------------------------------------------------------
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      ChartRedraw();
     }
  }
//if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) && m_position.StopLoss()==0)
//  {
//   double price = SymbolInfoDouble(temp_symbol,SYMBOL_BID);
//   if(OrderModify(m_position.Ticket(),price,NormalizeDouble(m_position.PriceOpen()-amp_w1,digits),m_position.TakeProfit(),0,clrNONE))
//      printf("OrderModify SL_BUY: "+temp_symbol);
//
//   Sleep(500);
//   continue;
//  }

//if(is_same_symbol(m_position.TypeDescription(),TREND_SEL) && m_position.StopLoss()==0)
//  {
//   double price = SymbolInfoDouble(temp_symbol,SYMBOL_ASK);
//   if(OrderModify(m_position.Ticket(),price,NormalizeDouble(m_position.PriceOpen()+amp_w1,digits),m_position.TakeProfit(),0,clrNONE))
//      printf("OrderModify SL_SELL: "+temp_symbol);
//   Sleep(500);
//   continue;
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePosition(string symbol,string TRADING_TREND)
  {
   for(int i = PositionsTotal()-1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(),symbol) && is_same_symbol(m_position.TypeDescription(),TRADING_TREND))
            if((TRADING_TREND=="") || (m_position.Comment()=="") || is_same_symbol(m_position.Comment(),TRADING_TREND))
              {
               int demm = 1;
               while(demm<5)
                 {
                  double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
                  double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
                  int slippage = (int)MathAbs(ask-bid);

                  if(is_same_symbol(m_position.TypeDescription(),TREND_BUY) && (is_same_symbol(m_position.Comment(),TREND_BUY) || (m_position.Comment()=="" && TRADING_TREND=="")))
                    {
                     bool successful=m_trade.PositionClose(m_position.Ticket());
                     if(successful)
                        break;
                    }

                  if(is_same_symbol(m_position.TypeDescription(),TREND_SEL) && (is_same_symbol(m_position.Comment(),TREND_SEL) || (m_position.Comment()=="" && TRADING_TREND=="")))
                    {
                     bool successful=m_trade.PositionClose(m_position.Ticket());
                     if(successful)
                        break;
                    }

                  demm++;
                  Sleep(500);
                 }
              }


   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sleep100()
  {
   Sleep(100);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseLimitOrder(string symbol,string TRADING_TREND)
  {
   for(int i = OrdersTotal()-1; i >= 0; i--)
      if(m_order.SelectByIndex(i))
         if(is_same_symbol(m_order.Symbol(),symbol) && is_same_symbol(m_order.TypeDescription(),TRADING_TREND))
           {
            int demm = 1;
            while(demm<5)
              {
               bool successful=m_trade.OrderDelete(m_order.Ticket());
               if(successful)
                  return true;

               demm+=1;
               Sleep100();
              }
           }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePositivePosition(string symbol,string TRADING_TREND)
  {
   bool result = false;
   double min_profit = 1;
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(),symbol) && (m_position.Profit() > min_profit))
            if((TRADING_TREND=="") || (m_position.Comment()=="") || is_same_symbol(m_position.Comment(),TRADING_TREND))
              {
               int demm = 1;
               while(demm<5)
                 {

                  bool successful=m_trade.PositionClose(m_position.Ticket());
                  if(successful)
                    {
                     result = true;
                     break;
                    }


                  demm++;
                  Sleep(500);
                 }
              }
     } //for

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string symbol,string trend,string message)
  {
   return;

   if(is_main_control_screen()==false)
      return;

   if(ALERT_MSG_TIME==iTime(symbol,PERIOD_H4,0))
      return;
   ALERT_MSG_TIME = iTime(symbol,PERIOD_H4,0);

   Alert(get_vntime(),message);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTelegramMessage(string symbol,string trend,string message,bool is_send_now)
  {
   if(allowSendMsgByAccount()==false)
     {
      Alert(get_vntime(),message);
      return;
     }

   if(is_send_now==false)
     {
      string date_time = time2string(iTime(symbol,PERIOD_H4,0));
      string key = symbol+"_"+trend+"_"+date_time;

      string send_telegram_today = ReadFileContent(FILE_NAME_SEND_MSG);
      if(StringFind(send_telegram_today,key) >= 0)
         return;
      WriteFileContent(FILE_NAME_SEND_MSG,"Telegram: "+key+" "+symbol+" "+trend+" "+message+"; "+send_telegram_today);
     }

   string botToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
   string chatId_duydk = "5099224587";

   double price = SymbolInfoDouble(symbol,SYMBOL_BID);
   string str_cur_price = " price:"+(string) price;

   Alert(get_vntime(),message+str_cur_price);


   string new_message = AccountInfoString(ACCOUNT_NAME)+get_vntime()+message+str_cur_price;

   StringReplace(new_message," ","_");
   StringReplace(new_message,"SendTeleMsg","");
   StringReplace(new_message,BtnSendNoticeHei,"");
   StringReplace(new_message,BtnSendNoticeMacd,"");
   StringReplace(new_message,BtnSendNoticeStoc,"");
   StringReplace(new_message,"__","_");
   StringReplace(new_message,"__","_");
   StringReplace(new_message,"__","_");
   StringReplace(new_message,"__","_");
   StringReplace(new_message,"_","%20");
   StringReplace(new_message," ","%20");

   string url = StringFormat("%s/bot%s/sendMessage?chat_id=%s&text=%s",telegram_url,botToken,chatId_duydk,new_message);

   string cookie=NULL,headers;
   char   data[],result[];

   ResetLastError();

   int timeout = 60000; // 60 seconds
   int res=WebRequest("GET",url,cookie,NULL,timeout,data,0,result,headers);
   if(res==-1)
      Alert("WebRequest Error:",GetLastError(),",URL: ",url,",Headers: ",headers,"   ",MB_ICONERROR);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_acc_profit_percent()
  {
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   return get_profit_percent(ACC_PROFIT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_profit_percent(double profit)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);

   string percent = AppendSpaces(format_double_to_string(profit,2),7,false)+"$ ("+AppendSpaces(format_double_to_string(profit/BALANCE * 100,1),5,false)+"%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_has_memo_in_file(string filename,string symbol,string TRADING_TREND_KEY)
  {
   string open_trade_today = ReadFileContent(filename);

   string key = create_key(symbol,TRADING_TREND_KEY);
   if(StringFind(open_trade_today,key) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename,string symbol,string TRADING_TREND_KEY,string note_stoploss = "",ulong ticket = 0,string note = "")
  {
   string open_trade_today = ReadFileContent(filename);
   string key = create_key(symbol,TRADING_TREND_KEY);

   WriteFileContent(filename,key);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReadFileContent(string file_name)
  {
   string fileContent = "";
   int fileHandle = FileOpen(file_name,FILE_READ);

   if(fileHandle != INVALID_HANDLE)
     {
      ulong fileSize = FileSize(fileHandle);
      if(fileSize > 0)
        {
         fileContent = FileReadString(fileHandle);
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
   int fileHandle = FileOpen(file_name,FILE_WRITE | FILE_TXT);

   if(fileHandle != INVALID_HANDLE)
     {
      //string file_contents = CutString(content);

      FileWriteString(fileHandle,content);
      FileClose(fileHandle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void saveAutoTrade()
  {
   string symbol = Symbol();
   GlobalVariableSet("IS_CONTINUE_TRADING_CYCLE_BUY",IS_CONTINUE_TRADING_CYCLE_BUY);
   GlobalVariableSet("IS_CONTINUE_TRADING_CYCLE_SEL",IS_CONTINUE_TRADING_CYCLE_SEL);

   string content = (string) iTime(symbol,PERIOD_D1,0)+"~";
   content += "AUTO_BUY:"+(string) IS_CONTINUE_TRADING_CYCLE_BUY+"~";
   content += "AUTO_SEL:"+(string) IS_CONTINUE_TRADING_CYCLE_SEL+"~";
   content += "WAIT_BUY_10:"+(string) IS_WAITTING_10PER_BUY+"~";
   content += "WAIT_SEL_10:"+(string) IS_WAITTING_10PER_SEL+"~";

   WriteFileContent(FILE_NAME_AUTO_TRADE,content);

   string key_d1_buy = (string)PERIOD_D1+(string)OP_BUY;
   string key_d1_sel = (string)PERIOD_D1+(string)OP_SEL;
   string key_h4_buy = (string)PERIOD_H4+(string)OP_BUY;
   string key_h4_sel = (string)PERIOD_H4+(string)OP_SEL;
   string key_h1_buy = (string)PERIOD_H1+(string)OP_BUY;
   string key_h1_sel = (string)PERIOD_H1+(string)OP_SEL;

   string buttonLabelD1 = ObjectGetString(0,BtnSendNoticeHei+"_D1",OBJPROP_TEXT);
   string buttonLabelH4 = ObjectGetString(0,BtnSendNoticeHei+"_H4",OBJPROP_TEXT);
   string buttonLabelH1 = ObjectGetString(0,BtnSendNoticeHei+"_H1",OBJPROP_TEXT);

   string Notice_Symbol = "";
   if(is_same_symbol(buttonLabelD1,TREND_BUY))
      Notice_Symbol += key_d1_buy;
   if(is_same_symbol(buttonLabelD1,TREND_SEL))
      Notice_Symbol += key_d1_sel;

   if(is_same_symbol(buttonLabelH4,TREND_BUY))
      Notice_Symbol += key_h4_buy;
   if(is_same_symbol(buttonLabelH4,TREND_SEL))
      Notice_Symbol += key_h4_sel;

   if(is_same_symbol(buttonLabelH1,TREND_BUY))
      Notice_Symbol += key_h1_buy;
   if(is_same_symbol(buttonLabelH1,TREND_SEL))
      Notice_Symbol += key_h1_sel;

   if(Notice_Symbol=="")
      Notice_Symbol = "-1";

   GlobalVariableSet(BtnSendNoticeHei+symbol,(double) Notice_Symbol);

//-------------------------------------------------------------------
   string btnMacdD1 = ObjectGetString(0,BtnSendNoticeMacd+"_D1",OBJPROP_TEXT);
   string btnMacdH4 = ObjectGetString(0,BtnSendNoticeMacd+"_H4",OBJPROP_TEXT);
   string btnMacdH1 = ObjectGetString(0,BtnSendNoticeMacd+"_H1",OBJPROP_TEXT);

   string Notice_Macd = "";
   if(is_same_symbol(btnMacdD1,TREND_BUY))
      Notice_Macd += key_d1_buy;
   if(is_same_symbol(btnMacdD1,TREND_SEL))
      Notice_Macd += key_d1_sel;

   if(is_same_symbol(btnMacdH4,TREND_BUY))
      Notice_Macd += key_h4_buy;
   if(is_same_symbol(btnMacdH4,TREND_SEL))
      Notice_Macd += key_h4_sel;

   if(is_same_symbol(btnMacdH1,TREND_BUY))
      Notice_Macd += key_h1_buy;
   if(is_same_symbol(btnMacdH1,TREND_SEL))
      Notice_Macd += key_h1_sel;

   if(Notice_Macd=="")
      Notice_Macd = "-1";

   GlobalVariableSet(BtnSendNoticeMacd+symbol,(double) Notice_Macd);
//-------------------------------------------------------------------
   string btnStocH4 = ObjectGetString(0,BtnSendNoticeStoc+"_H4",OBJPROP_TEXT);
   string btnStocH1 = ObjectGetString(0,BtnSendNoticeStoc+"_H1",OBJPROP_TEXT);

   string Notice_Stoc = "";
   if(is_same_symbol(btnStocH4,TREND_BUY))
      Notice_Stoc += key_h4_buy;
   if(is_same_symbol(btnStocH4,TREND_SEL))
      Notice_Stoc += key_h4_sel;

   if(is_same_symbol(btnStocH1,TREND_BUY))
      Notice_Stoc += key_h1_buy;
   if(is_same_symbol(btnStocH1,TREND_SEL))
      Notice_Stoc += key_h1_sel;

   if(Notice_Stoc=="")
      Notice_Stoc = "-1";

   GlobalVariableSet(BtnSendNoticeStoc+symbol,(double) Notice_Stoc);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void loadAutoTrade()
  {
   string content = ReadFileContent(FILE_NAME_AUTO_TRADE);
   string cur_time = (string) iTime(Symbol(),PERIOD_D1,0)+"~";
   string str_auto_buy = "AUTO_BUY:"+(string) true+"~";
   string str_auto_sel = "AUTO_SEL:"+(string) true+"~";
   string str_wait_buy10 = "WAIT_BUY_10:"+(string) true+"~";
   string str_wait_sel10 = "WAIT_SEL_10:"+(string) true+"~";

   if(is_same_symbol(content,cur_time))
     {
      IS_CONTINUE_TRADING_CYCLE_BUY = is_same_symbol(content,str_auto_buy);
      IS_CONTINUE_TRADING_CYCLE_SEL = is_same_symbol(content,str_auto_sel);

      IS_WAITTING_10PER_BUY = is_same_symbol(content,str_wait_buy10);
      IS_WAITTING_10PER_SEL = is_same_symbol(content,str_wait_sel10);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CutString(string originalString)
  {
   int max_lengh = 10000;
   int originalLength = StringLen(originalString);
   if(originalLength > max_lengh)
     {
      int startIndex = originalLength-max_lengh;
      return StringSubstr(originalString,startIndex,max_lengh);
     }
   return originalString;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_key(string symbol,string TRADING_TREND_KEY)
  {
   string date_time = time2string(iTime(symbol,PERIOD_H4,0));
   string key = date_time+":PERIOD_H4:"+TRADING_TREND_KEY+":"+symbol +";";
   return key;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_volume_by_fibo_vol(double cur_max_vol,double fibo)
  {
   double vol = 0.01;
   return NormalizeDouble(vol,2);

   for(int i = 2; i <= 15; i++)
     {
      vol = NormalizeDouble(vol*fibo,2);
      if(vol >= cur_max_vol+0.01)
         return NormalizeDouble(vol,2);
     }

   if(vol < 0.01)
      return 0.01;

   return NormalizeDouble(vol,2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_volume_by_fibo_dca(int trade_no)
  {
   double vol = 0.01;
   return NormalizeDouble(vol,2);

   for(int i = 2; i <= trade_no; i++)
     {
      vol = vol*FIBO_1618;
      if(trade_no >= 15)
         break;
     }

   if(vol < 0.01)
      return 0.01;

   return NormalizeDouble(vol,2);
  }

// Function to get the highest and lowest M5 candle times in the current day
void GetHighestLowestM5Times(string symbol,datetime timeStart,datetime timeEnd,int dIndex)
  {
   double   highestPrice = -1;
   double   lowestPrice = -1;
   datetime highestTime = 0;
   datetime lowestTime = 0;

   string vnhig_d1 = "hig_"+time2string(timeStart);
   string vnlow_d1 = "low_"+time2string(timeStart);

   if(Period() <= PERIOD_H4 && !is_sunday(timeStart))
     {
      int i = 0;
      while(true)
        {
         datetime candleTime = iTime(symbol,PERIOD_H1,i);
         if(candleTime < timeStart)
            break;

         if(candleTime >= timeEnd)
           {
            i++;
            continue;
           }

         double high = iHigh(symbol,PERIOD_H1,i);
         double low = iLow(symbol,PERIOD_H1,i);

         if(highestPrice==-1 || high > highestPrice)
           {
            highestPrice = high;
            highestTime = candleTime;
           }

         if(lowestPrice==-1 || low < lowestPrice)
           {
            lowestPrice = low;
            lowestTime = candleTime;
           }

         i++;
        }

      bool is_up = lowestTime < highestTime;
      int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      create_label(vnhig_d1,dIndex==0?iTime(symbol,PERIOD_D1,0):timeStart,highestPrice,(is_up==true?""+format_double_to_string(highestPrice-lowestPrice,digits-2)+"":""),is_up==true?TREND_BUY:"",true,6);   // convert2vntime(highestTime)
      create_label(vnlow_d1,dIndex==0?iTime(symbol,PERIOD_D1,0):timeStart,lowestPrice,(is_up==false? ""+format_double_to_string(lowestPrice-highestPrice,digits-2)+"":""), is_up==false? TREND_SEL:"",true,6);  // convert2vntime(lowestTime)
     }
   else
     {
      ObjectDelete(0,vnhig_d1);
      ObjectDelete(0,vnlow_d1);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTrendByLowHigTimes(string symbol,datetime timeStart,datetime timeEnd,ENUM_TIMEFRAMES TIMEFRAME)
  {
   double   highestPrice = -1;
   double   lowestPrice = -1;
   datetime highestTime = 0;
   datetime lowestTime = 0;

   int i = 0;
   while(true)
     {
      datetime candleTime = iTime(symbol,TIMEFRAME,i);
      if(candleTime < timeStart)
         break;

      if(candleTime >= timeEnd)
        {
         i++;
         continue;
        }

      double high = iHigh(symbol,TIMEFRAME,i);
      double low = iLow(symbol,TIMEFRAME,i);

      if(highestPrice==-1 || high > highestPrice)
        {
         highestPrice = high;
         highestTime = candleTime;
        }

      if(lowestPrice==-1 || low < lowestPrice)
        {
         lowestPrice = low;
         lowestTime = candleTime;
        }

      i++;
     }

   if(lowestTime==0 && highestTime==0)
      return "";

   bool is_up = lowestTime < highestTime;

   if(is_up)
      return TREND_BUY;

   return TREND_SEL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_histogram(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   int m_handle_macd = iMACD(symbol,timeframe,12,26,9,PRICE_CLOSE);
   if(m_handle_macd==INVALID_HANDLE)
      return "";

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main,true);

   CopyBuffer(m_handle_macd,0,0,2,m_buff_MACD_main);

   double m_macd    = m_buff_MACD_main[0];
//double m_signal  = m_buff_MACD_signal[0];

   if(m_macd > 0)
      return TREND_BUY ;

   if(m_macd < 0)
      return TREND_SEL ;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd_and_signal_vs_zero(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   int m_handle_macd = iMACD(symbol,timeframe,12,26,9,PRICE_CLOSE);
   if(m_handle_macd==INVALID_HANDLE)
      return "";

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd,0,0,2,m_buff_MACD_main);
   CopyBuffer(m_handle_macd,1,0,2,m_buff_MACD_signal);

   double m_macd    = m_buff_MACD_main[0];
   double m_signal  = m_buff_MACD_signal[0];

   if(m_macd >= 0 && m_signal >= 0)
      return TREND_BUY ;

   if(m_macd <= 0 && m_signal <= 0)
      return TREND_SEL ;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//bool is_order_opened_today(string symbol)
//  {
//// Lấy thời gian hiện tại
//   datetime current_time = TimeCurrent();
//
//// Lấy thời gian bắt đầu của ngày hôm nay
//   datetime start_of_today = StringToTime(TimeToString(current_time,TIME_DATE));
//
//// Duyệt qua tất cả các lệnh trong lịch sử và đang hoạt động
//   for(int i = OrdersHistoryTotal()-1; i >= 0; i--)
//     {
//      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
//         if(is_same_symbol(m_position.Symbol(),symbol))
//            // Kiểm tra nếu lệnh được mở từ thời gian bắt đầu của ngày hôm nay trở đi
//            if(OrderOpenTime() >= start_of_today)
//               return true;
//     }
//
//   for(int i = OrdersTotal()-1; i >= 0; i--)
//     {
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//        {
//         // Kiểm tra nếu lệnh được mở từ thời gian bắt đầu của ngày hôm nay trở đi
//         if(OrderOpenTime() >= start_of_today)
//            return true;
//        }
//     }
//
//// Nếu không có lệnh nào được mở trong ngày hôm nay
//   return false;
//  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool passes_waiting_time_dca(datetime last_open_trade_time,int count_possion)
  {
   return true;

   int waiting_minus = DEFAULT_WAITING_DCA_IN_MINUS+MINUTES_BETWEEN_ORDER*count_possion;

   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime-last_open_trade_time;
   if(timeGap >= waiting_minus * 60)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int remaining_time_to_dca(datetime last_open_trade_time,int waiting_minus)
  {
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime-last_open_trade_time;
   return (int)(waiting_minus-timeGap/60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string str_remaining_time(datetime last_open_trade_time,int count_possion)
  {
   int waiting_minus = DEFAULT_WAITING_DCA_IN_MINUS+MINUTES_BETWEEN_ORDER*count_possion;

   int remain = remaining_time_to_dca(last_open_trade_time,waiting_minus);
   datetime currentTime = TimeCurrent();
   datetime newTime = currentTime+remain * 60;

   if(remain < 0)
      remain = 0;

   string value = "  "+(string)remain +"p";

   return value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_by_ma7_10_20_50(string symbol,ENUM_TIMEFRAMES timeframe,string find_trend)
  {
   string trend_m5_ma0710 = "";
   string trend_m5_ma1020 = "";
   string trend_m5_ma2050 = "";
   string trend_m5_C1ma10 = "";
   string trend_m5_ma50d1 = "";
   bool is_insign_m5 = false;
   get_trend_by_ma_seq71020_steadily(symbol,timeframe,trend_m5_ma0710,trend_m5_ma1020,trend_m5_ma2050,trend_m5_C1ma10,trend_m5_ma50d1,is_insign_m5);

   string trend_reverse = get_trend_reverse(find_trend);

   if(trend_reverse==trend_m5_ma2050)
      if(trend_m5_ma0710==trend_m5_ma1020 && trend_m5_ma1020==trend_m5_ma2050)
         return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc2(string symbol,ENUM_TIMEFRAMES timeframe,int inK = 13,int inD = 8,int inS = 5,int candle_no = 0)
  {
   int handle_iStochastic = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH);
   if(handle_iStochastic==INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K,true);
   ArraySetAsSeries(D,true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   double black_K = K[candle_no];
   double red_D = D[candle_no];

   if(black_K > red_D)
      return TREND_BUY;

   if(black_K < red_D)
      return TREND_SEL;

   return "";
  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void get_trend_by_stoc3(string symbol,ENUM_TIMEFRAMES timeframe,string &cur_trend,double &stoc_value
//                        ,int inK = 21,int inD = 7,int inS = 7,int candle_no = 0)
//  {
//   double M_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);// 0 bar
//   double S_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar
//   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))-1;
//
//   if(M_0 > S_0)
//      cur_trend = TREND_BUY;
//
//   if(M_0 < S_0)
//      cur_trend = TREND_SEL;
//
//   stoc_value = NormalizeDouble((M_0+M_0+S_0)/3,digits);
//  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//bool is_allow_trade_now_by_stoc(string symbol,ENUM_TIMEFRAMES timeframe,string find_trend,int inK,int inD,int inS)
//  {
//   double black_K = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);// 0 bar
//   double red_D   = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar
//
//   if(find_trend==TREND_BUY && black_K >= red_D && (red_D <= 20 || black_K <= 20))
//      return true;
//
//   if(find_trend==TREND_SEL && black_K <= red_D && (red_D >= 80 || black_K >= 80))
//      return true;
//
//   return false;
//  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//bool is_allow_take_profit_now_by_stoc(string symbol,ENUM_TIMEFRAMES timeframe,string find_trend,int inK,int inD,int inS)
//  {
//   double black_K = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);// 0 bar
//   double red_D   = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar
//
//   if(find_trend==TREND_BUY && red_D <= 20 && black_K <= 20)
//      return true;
//
//   if(find_trend==TREND_SEL && red_D >= 80 && black_K >= 80)
//      return true;
//
//   return false;
//  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//string check_stoch_before_trade(string symbol,ENUM_TIMEFRAMES TIMEFRAME,string find_trend)
//  {
//   string msg = "";
//
//   double h4_bla_K_5_3_2 = iStochastic(symbol,TIMEFRAME,5,3,2,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);
//   double h4_red_D_5_3_2 = iStochastic(symbol,TIMEFRAME,5,3,2,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//   double h4_bla_K_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);
//   double h4_red_D_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//
//   if(find_trend==TREND_BUY)
//      if(h4_bla_K_5_3_2 >= 80 || h4_red_D_5_3_2 >= 80 || h4_bla_K_13_5_5 >= 80 || h4_red_D_13_5_5 >= 80)
//         msg = "BUY is not allowed. Stoch "+get_time_frame_name(TIMEFRAME)+" is in overbought.";
//
//   if(find_trend==TREND_SEL)
//      if(h4_bla_K_5_3_2 <= 20 || h4_red_D_5_3_2 <= 20 || h4_bla_K_13_5_5 <= 20 || h4_red_D_13_5_5 <= 20)
//         msg = "SELL is not allowed. Stoch "+get_time_frame_name(TIMEFRAME)+" is in oversold.";
//
//   return msg;
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_allow_trade_now_by_stoc(string symbol,ENUM_TIMEFRAMES timeframe,bool auto_init = false)
  {
   int handle_iStochastic = iStochastic(symbol,timeframe,3,2,3,MODE_SMA,STO_LOWHIGH);
   if(handle_iStochastic==INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K,true);
   ArraySetAsSeries(D,true);
   CopyBuffer(handle_iStochastic,0,0,10,K);
   CopyBuffer(handle_iStochastic,1,0,10,D);

   string result = "";
   if(K[0]<=20 && D[0]<=20)
      result += TREND_BUY+" (20) ";

   if(K[0]>=80 && D[0]>=80)
      result += TREND_SEL+" (80) ";

   if(auto_init && result=="")
      result += " "+TREND_BUY+" "+TREND_SEL+" ";

   return result;
  }


////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//string get_trend_allow_trade_now_by_stoc(string symbol,ENUM_TIMEFRAMES TIMEFRAME,bool auto_init = false)
//  {
//   double bla_K__5_3_2 = iStochastic(symbol,TIMEFRAME,7,5,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);
//   double red_D__5_3_2 = iStochastic(symbol,TIMEFRAME,7,5,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//   double bla_K_13_5_5 = iStochastic(symbol,TIMEFRAME,12,7,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);
//   double red_D_13_5_5 = iStochastic(symbol,TIMEFRAME,12,7,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//   double bla_K_21_7_7 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);
//   double red_D_21_7_7 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//
//   string result = "";
//
//   if(
//      (bla_K__5_3_2 <= 20 || red_D__5_3_2 <= 20) ||
//      (bla_K_13_5_5 <= 20 || red_D_13_5_5 <= 20) ||
//      (bla_K_21_7_7 <= 20 || red_D_21_7_7 <= 20)
//   )
//      result += TREND_BUY+" (20) ";
//
//   if(
//      (bla_K__5_3_2 >= 80 || red_D__5_3_2 >= 80) ||
//      (bla_K_13_5_5 >= 80 || red_D_13_5_5 >= 80) ||
//      (bla_K_21_7_7 >= 80 || red_D_21_7_7 >= 80)
//   )
//      result += TREND_SEL+" (80) ";
//
//   if(auto_init && result=="")
//      result += " "+TREND_BUY+" "+TREND_SEL+" ";
//
//   return result;
//  }
//
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void Count_Stoc_Candles(string symbol,int TIMEFRAME
//                        ,string &trend_stoc_21h4,int &count_stoc_21_h4,string &trend_stoc_80_20,double &stoc_value
//                        ,int inK,int inD,int inS,bool is_draw_time_trend_d1 = false)
//  {
//   int limit = LIMIT_D;
//
//   double bla_K = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN, 0);
//   double red_D = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
//   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
//   stoc_value = NormalizeDouble((bla_K+bla_K+red_D)/3,digits);
//
//   int idx_0   = 0,idx_1   = 0,idx_2   = 0;
//   int count_0 = 1,count_1 = 1,count_2 = 1;
//   string trend_0 = bla_K > red_D?TREND_BUY:TREND_SEL;
//   string trend_1 = bla_K > red_D?TREND_SEL:TREND_BUY;
//   string trend_2 = trend_0;
//
//   trend_stoc_80_20 = "";
//   if(stoc_value >= 80)
//      trend_stoc_80_20 = TREND_SEL;
//   if(stoc_value <= 20)
//      trend_stoc_80_20 = TREND_BUY;
//   trend_stoc_80_20 += " ("+(string)(int)(stoc_value)+")";
//
//   bool found_0 = false,found_1 = false,found_2 = false;
//   for(int i = 1; i < limit; i++)
//     {
//      bla_K = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN, i);
//      red_D = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,i);
//      string trend_i = bla_K > red_D?TREND_BUY:TREND_SEL;
//
//      if(!found_0)
//        {
//         if(trend_0==trend_i)
//           {
//            idx_0 = i;
//            count_0 += 1;
//           }
//         else
//            found_0 = true;
//        }
//
//      if(found_0 && !found_1)
//        {
//         if(trend_1==trend_i)
//           {
//            idx_1 = i;
//            count_1 += 1;
//           }
//         else
//            found_1 = true;
//        }
//
//      if(found_0 && found_1 && !found_2)
//        {
//         if(trend_2==trend_i)
//           {
//            idx_2 = i;
//            count_2 += 1;
//           }
//         else
//            found_2 = true;
//        }
//      if(found_0 && found_1 && found_2)
//         break;
//     }
//
//   bool cur_symbol = is_same_symbol(symbol,Symbol());
//
//   if(false && cur_symbol && is_draw_time_trend_d1)
//     {
//      ObjectDelete(0,"h_time_trend_0");
//      ObjectDelete(0,"h_time_trend_1");
//      ObjectDelete(0,"h_time_trend_2");
//
//      if(found_0 && found_1 && found_2)
//        {
//         datetime time_0 = iTime(symbol,TIMEFRAME,idx_0);
//         datetime time_1 = iTime(symbol,TIMEFRAME,idx_1);
//         datetime time_2 = iTime(symbol,TIMEFRAME,idx_2);
//
//         color clrLineColor_0 = trend_0==TREND_BUY?clrTeal:clrFireBrick;
//         color clrLineColor_1 = trend_1==TREND_BUY?clrTeal:clrFireBrick;
//         color clrLineColor_2 = trend_2==TREND_BUY?clrTeal:clrFireBrick;
//
//         int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0));
//         int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
//
//         int sub_window;
//         datetime time;
//         double price;
//         if(ChartXYToTimePrice(0,chart_width/2,chart_heigh-10,sub_window,time,price))
//           {
//            double amp_w1,amp_d1,amp_h4,amp_grid_L100;
//            GetAmpAvgL15(Symbol(),amp_w1,amp_d1,amp_h4,amp_grid_L100);
//
//            create_filled_rectangle("h_time_trend_2",time_2,price,time_1,price-amp_h4/2,clrLineColor_2,true,true,trend_2,1);
//            create_filled_rectangle("h_time_trend_1",time_1,price,time_0,price-amp_h4/2,clrLineColor_1,true,true,trend_1,1);
//            create_filled_rectangle("h_time_trend_0",time_0,price,TimeCurrent()+ TIME_OF_ONE_D1_CANDLE,price-amp_h4/2,clrLineColor_0,true,true,trend_0,1);
//           }
//        }
//     }
//
//
//   if(cur_symbol && is_draw_time_trend_d1 && (TIMEFRAME==Period()))
//     {
//      ObjectDelete(0,"Stoc.0");
//      ObjectDelete(0,"Stoc.1");
//      ObjectDelete(0,"Stoc.2");
//      ObjectDelete(0,"V.Stoc.0");
//      ObjectDelete(0,"V.Stoc.1");
//      ObjectDelete(0,"V.Stoc.2");
//
//      double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
//      int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,2));
//      int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,2))-18;
//
//      if(found_0)
//        {
//         //int x,y;
//         datetime time_0 = iTime(symbol,TIMEFRAME,idx_0);
//         color clrLineColor = trend_0==TREND_BUY?clrBlue:clrRed;
//         create_vertical_line("V.Stoc.0",time_0,clrBlack,STYLE_SOLID,1,true,false,false,true,2);
//
//         //if(ChartTimePriceToXY(0,0,time_0,bid,x,y))
//         //   createButton("Stoc.0","(0) "+getShortName(trend_0)+"."+(string)count_0,x+3,chart_heigh,60,15,clrLineColor,clrWhite,6,2);
//        }
//
//      if(found_1 && count_1 > 5)
//        {
//         //int x,y;
//         datetime time_1 = iTime(symbol,TIMEFRAME,idx_1);
//         color clrLineColor = trend_1==TREND_BUY?clrBlue:clrRed;
//         create_vertical_line("V.Stoc.1",time_1,clrBlack,STYLE_SOLID,1,true,false,false,true,2);
//
//         //if(ChartTimePriceToXY(0,0,time_1,bid,x,y))
//         //   createButton("Stoc.1","(0) "+getShortName(trend_1)+"."+(string)count_1,x+3,chart_heigh,60,15,clrLineColor,clrWhite,6,2);
//        }
//
//      if(found_2 && count_2 > 5)
//        {
//         //int x,y;
//         datetime time_2 = iTime(symbol,TIMEFRAME,idx_2);
//         color clrLineColor = trend_2==TREND_BUY?clrBlue:clrRed;
//         create_vertical_line("V.Stoc.2",time_2,clrBlack,STYLE_SOLID,1,true,false,false,true,2);
//
//         //if(ChartTimePriceToXY(0,0,time_2,bid,x,y))
//         //   createButton("Stoc.2","(0) "+getShortName(trend_2)+"."+(string)count_2,x+3,chart_heigh,60,15,clrLineColor,clrWhite,6,2);
//        }
//     }
//
//   trend_stoc_21h4 = trend_0;
//   count_stoc_21_h4 = count_0;
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_manual_trade(string comment)
  {
   if(is_same_symbol(comment,MASK_MANUAL))
      return true;

   if(comment=="")
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_same_symbol(string symbol_og,string symbol_tg)
  {
   if(symbol_og=="" || symbol_og=="")
      return false;

   if(StringFind(toLower(symbol_og),toLower(symbol_tg)) >= 0)
      return true;

   if(StringFind(toLower(symbol_tg),toLower(symbol_og)) >= 0)
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
   if(trade_no < 10)
      return "00"+(string) trade_no;

   if(trade_no < 100)
      return "0"+(string) trade_no;

   return (string) trade_no;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string append1Zero(int trade_no)
  {
   if(trade_no < 10)
      return "0"+(string) trade_no;

   return (string) trade_no;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe,int ma_index,int candle_no = 1)
  {
   int maLength = ma_index+5;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i = maLength-1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol,timeframe,i);
     }

   double close_1 = closePrices[candle_no];
   double ma = cal_MA(closePrices,ma_index,candle_no);

   if(close_1 > ma)
      return TREND_BUY;

   if(close_1 < ma)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_maX_maY(string symbol,ENUM_TIMEFRAMES timeframe,int ma_index_6,int ma_index_9)
  {
   int maLength = MathMax(ma_index_6,ma_index_9)+5;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i = maLength-1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol,timeframe,i);
     }

   double ma_6 = cal_MA(closePrices,ma_index_6,1);
   double ma_9 = cal_MA(closePrices,ma_index_9,1);

   if(ma_6 > ma_9)
      return TREND_BUY;

   if(ma_6 < ma_9)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA(double& closePrices[],int ma_index,int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i <= candle_no+ma_index; i++)
     {
      count += 1;
      ma += closePrices[i];
     }
   ma /= count;

   return ma;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_group_value(string comment,string str_start = "[G",string str_end = "]")
  {
   int startPos = StringFind(comment,str_start);
   int endPos = StringFind(comment,str_end,startPos);
   string result = "";

   if(startPos != -1 && endPos != -1)
      result = StringSubstr(comment,startPos,endPos-startPos+1);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_group_name()
  {
   datetime VnTime = TimeGMT()+7 * 3600;
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
   string key = "";

   if(ticket > 0)
     {
      key = "000"+(string)(ticket);
      int length = StringLen(key);

      string lastThree = StringSubstr(key,length-3,3);

      key = "[K"+lastThree+ "]";
     }

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string time2string(datetime time)
  {
   string today = (string)time;
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
   double dbLotsMinimum  = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double dbLotsMaximum  = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double dbLotsStep     = SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double dbTickSize     = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double dbTickValue    = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   if(dbTickSize==0)
      return 0.01;
   double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
   if(dbLossOrder==0 || dbLotsStep==0)
      return 0.01;

   double dbLotReal      = (dbRiskByUsd / dbLossOrder / dbLotsStep) * dbLotsStep;
   double dbCalcLot      = (fmin(dbLotsMaximum,fmax(dbLotsMinimum,round(dbLotReal))));
   double roundedLotSize = MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

   if(roundedLotSize < 0.01)
      roundedLotSize = 0.01;

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
double calc_SL_7d_for_trade_arr(string symbol,CandleData &arrHeiken_D1[],string trend_ma10_d1,double amp_sl_min)
  {
   double min_10d = 0;
   double max_10d = 0;
   for(int i = 0; i < 7; i++)
     {
      if(i==0 || min_10d > arrHeiken_D1[i].low)
         min_10d = arrHeiken_D1[i].low;

      if(i==0 || max_10d < arrHeiken_D1[i].high)
         max_10d = arrHeiken_D1[i].high;
     }
   double sl_buy = min_10d;
   double sl_sel = max_10d;

   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double cur_price = (bid+ask)/2;

   double amp_sl = trend_ma10_d1==TREND_BUY?MathAbs(cur_price-sl_buy):trend_ma10_d1==TREND_SEL? MathAbs(cur_price-sl_sel):0;
   if(amp_sl < amp_sl_min)
     {
      sl_buy = cur_price-amp_sl_min;
      sl_sel = cur_price+amp_sl_min;
     }
   int digits = MathMin(5,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));

   return NormalizeDouble(trend_ma10_d1==TREND_BUY?sl_buy:trend_ma10_d1==TREND_SEL? sl_sel:0,digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_lowest_highest(CandleData &arrHeiken_heiken[],int size,double &lowest,double &highest)
  {
   double min_x = 0;
   double max_x = 0;
   for(int i = 0; i < size; i++)
     {
      if(i==0 || min_x > arrHeiken_heiken[i].low)
         min_x = arrHeiken_heiken[i].low;

      if(i==0 || max_x < arrHeiken_heiken[i].high)
         max_x = arrHeiken_heiken[i].high;
     }

   lowest = min_x;
   highest = max_x;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_SL_7d_for_trade_init(string symbol,string trend_ma10_d1,double amp_sl_min)
  {
   CandleData arrHeiken_D1[];
   get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,10,true);

   return calc_SL_7d_for_trade_arr(symbol,arrHeiken_D1,trend_ma10_d1,amp_sl_min);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double calc_SL_7w_for_protect_account(string symbol,string trend_ma10_d1,double amp_w1)
//  {
//   CandleData arrHeiken_W1[];
//   get_arr_heiken(symbol,PERIOD_W1,arrHeiken_W1,21,true);
//
//   return calc_SL_7d_for_trade_arr(symbol,arrHeiken_W1,trend_ma10_d1,amp_w1);
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA_XX(string symbol,ENUM_TIMEFRAMES timeframe,int ma_index,int candle_no=1)
  {
   int maLength = ma_index+5;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i = maLength-1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol,timeframe,i);
     }

   double ma_value = cal_MA(closePrices,ma_index);
   return ma_value;
  }
//+------------------------------------------------------------------+
string Append(double inputString,int totalLength = 6)
  {
   return AppendSpaces((string) inputString,totalLength);
  }
//+------------------------------------------------------------------+
string AppendSpaces(string inputString,int totalLength = 10,bool is_append_right = true)
  {
   int currentLength = StringLen(inputString);

   if(currentLength >= totalLength)
      return (inputString);

   int spacesToAdd = totalLength-currentLength;
   string spaces = "";
   for(int index = 1; index <= spacesToAdd; index++)
      spaces+= " ";

   if(is_append_right)
      return (inputString+spaces);
   else
      return (spaces+inputString);
  }

//+------------------------------------------------------------------+
string format_double_to_string(double number,int digits = 5)
  {
   string numberString = (string) number;
   int dotIndex = StringFind(numberString,".");
   if(dotIndex >= 0)
     {
      string beforeDot = StringSubstr(numberString,0,dotIndex);
      string afterDot = StringSubstr(numberString,dotIndex+1);
      afterDot = StringSubstr(afterDot,0,digits); // chỉ lấy digits chữ số đầu tiên sau dấu chấm

      numberString = beforeDot+"."+afterDot;
     }

   StringReplace(numberString,"00000","");
   StringReplace(numberString,"00000","");
   StringReplace(numberString,"00000","");
   StringReplace(numberString,"99999","9");
   StringReplace(numberString,"99999","9");
   StringReplace(numberString,"99999","9");

   dotIndex = StringFind(numberString,".");
   string afterDot = StringSubstr(numberString,dotIndex+1);
   if(dotIndex > 0 && StringLen(afterDot) < digits)
      numberString += "0";

   return numberString;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number,int digits)
  {
   return NormalizeDouble(StringToDouble(format_double_to_string(number,digits)),digits);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string get_current_timeframe_to_string()
  {
   if(Period()==PERIOD_M1)
      return "M1";

   if(Period()==PERIOD_M5)
      return "M5";

   if(Period()==PERIOD_M15)
      return "M15";

   if(Period()==PERIOD_M30)
      return "M30";

   if(Period()== PERIOD_H1)
      return "H1";

   if(Period()== PERIOD_H4)
      return "H4";

   if(Period()== PERIOD_D1)
      return "D1";

   if(Period()== PERIOD_W1)
      return "W1";

   return "??";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_current_timeframe()
  {
   if(Period()==PERIOD_M1)
      return "01";

   if(Period()==PERIOD_M5)
      return "05";

   if(Period()==PERIOD_M15)
      return "15";

   if(Period()==PERIOD_M30)
      return "30";

   if(Period()== PERIOD_H1)
      return "1";

   if(Period()== PERIOD_H4)
      return "4";

   if(Period()== PERIOD_D1)
      return "D";

   if(Period()== PERIOD_W1)
      return "W";

   if(Period()== PERIOD_MN1)
      return "MO";

   return "??";
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

   return "??";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vntime()
  {
   string cpu = "";
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(),gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9)?(string) gmt_time.hour:"0"+(string) gmt_time.hour;

   datetime vietnamTime = TimeGMT()+7 * 3600;
   string str_date_time = TimeToString(vietnamTime,TIME_DATE | TIME_MINUTES);
   string vntime = "("+str_date_time+")    ";
   return vntime;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string format_date_yyyyMMdd(datetime date0)
  {
   MqlDateTime gmt_time;
   TimeToStruct(date0,gmt_time);

   return (string)gmt_time.year+"/"+append1Zero(gmt_time.mon)+"/"+append1Zero(gmt_time.day);
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
string get_vn_date()
  {
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(),gmt_time);

   string str_date_time = (string)gmt_time.year+append1Zero(gmt_time.mon)+append1Zero(gmt_time.day);

   return str_date_time;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vnhour()
  {
   string cpu = "";
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(),gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9)?(string) gmt_time.hour:"0"+(string) gmt_time.hour;

   datetime vietnamTime = TimeGMT()+7 * 3600;
   string str_date_time = TimeToString(vietnamTime,TIME_MINUTES);
   string vntime = "("+str_date_time+")";
   return vntime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string convert2vntime(datetime time)
  {
// Time difference between UTC and Vietnam Time is +7 hours
   int timeOffset = 7 * 3600; // 7 hours in seconds

// Add the offset to the given time
   datetime vietnamTime = time+timeOffset;

   string str_date_time = TimeToString(vietnamTime,TIME_MINUTES);

   return str_date_time;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//bool must_exit_trade_today(string symbol,string TREND)
//  {
//   datetime vietnamTime = TimeGMT()+7 * 3600;
//   MqlDateTime timeStruct;
//   TimeToStruct(vietnamTime,timeStruct);
//
//   if(timeStruct.hour > 23 || (timeStruct.hour==23 && timeStruct.min >= 30))
//     {
//      if(is_allow_take_profit_now_by_stoc(symbol,PERIOD_M15,TREND,3,2,3))
//         return true;
//
//      if(is_allow_take_profit_now_by_stoc(symbol,PERIOD_M5, TREND,3,2,3))
//         return true;
//     }
//
//   return false;
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_sunday(datetime timeEnd)
  {
   MqlDateTime vietnamDateTime;
   TimeToStruct(timeEnd,vietnamDateTime);

   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week==SUNDAY)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_time_enter_the_market()
  {
   datetime vietnamTime = TimeGMT()+7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime,vietnamDateTime);

   int currentHour = vietnamDateTime.hour;

   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week==SATURDAY || day_of_week==SUNDAY)
      if(currentHour>8)
         return true;
      else
         return false;

   if(day_of_week==FRIDAY && currentHour > 22)
      return false;

   if(3 <= currentHour && currentHour <= 7)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_setting_reset_on_new_day()
  {
   datetime vietnamTime = TimeGMT()+7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime,vietnamDateTime);

   int currentHour = vietnamDateTime.hour;
   int currentMinus = vietnamDateTime.min;
   if(currentHour==7)
      if(5 <= currentMinus && currentMinus <= 15)
         return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_hedging_time()
  {
   datetime vietnamTime = TimeGMT()+7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime,vietnamDateTime);

   int currentHour = vietnamDateTime.hour;
   if(22 <= currentHour || currentHour <= 3)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrendlineValueAtCurrentTime(string trendlineName,datetime currentTime)
  {
   double price = ObjectGetValueByTime(0,trendlineName,currentTime);

   return price;
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
   const int               width = 1,
   const bool              ray_left = false,
   const bool              ray_right = false,
   const bool              is_hiden = true,
   const bool              is_back = true,
   const int               sub_window = 0
)
  {
   string name_new = name;
   ObjectDelete(0,name);
//if(ray_left)
//   time_from = time_to-TIME_OF_ONE_W1_CANDLE * 350;
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
   const int               body_border_width=1
)
  {
   string name_new = name;
   if(is_fill_color)
     {
      ObjectDelete(0,name_new);  // Delete any existing object with the same name
      ObjectCreate(0,name_new,OBJ_RECTANGLE,0,time_from,price_from,time_to,price_to);
      ObjectSetInteger(0,name_new,OBJPROP_COLOR,clrBlack);         // Set border color
      ObjectSetInteger(0,name_new,OBJPROP_STYLE,STYLE_SOLID);      // Set border style to solid
      ObjectSetInteger(0,name_new,OBJPROP_HIDDEN,true);            // Set hidden property
      ObjectSetInteger(0,name_new,OBJPROP_BACK,true);              // Set background property
      ObjectSetInteger(0,name_new,OBJPROP_SELECTABLE,false);       // Set selectable property
      ObjectSetInteger(0,name_new,OBJPROP_STYLE,STYLE_SOLID);      // Set style to solid
      ObjectSetInteger(0,name_new,OBJPROP_COLOR,clr_fill);         // Set fill color (this may not work as intended for all objects)
      ObjectSetInteger(0,name_new,OBJPROP_WIDTH,1);                // Setting this to 1 for consistency
     }

   if(is_draw_border)
     {
      color clr_border = trend_rec==TREND_BUY?clrBlue:trend_rec==TREND_SEL?clrRed:clrNONE; //C'215,215,215'

      create_trend_line(name_new+"_left",  time_from,price_from,time_from,price_to,  clr_border,STYLE_SOLID,body_border_width);
      create_trend_line(name_new+"_righ",  time_to,  price_from,time_to,  price_to,  clr_border,STYLE_SOLID,body_border_width);
      create_trend_line(name_new+"_top",   time_from,price_to,  time_to,  price_to,  clr_border,STYLE_SOLID,body_border_width);
      create_trend_line(name_new+"_bottom",time_from,price_from,time_to,  price_from,clr_border,STYLE_SOLID,body_border_width);
     }
  }
//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool create_vertical_line(
   const string          name0="VLine",     // line name
   datetime              time=0,           // line time
   const color           clr=clrBlack,       // line color
   const ENUM_LINE_STYLE style=STYLE_DOT,// line style
   const int             width=1,          // line width
   const bool            back=true,       // in the background
   const bool            selection=false,   // highlight to move
   const bool            ray=false,         // line's continuation down
   const bool            hidden=true,     // hidden in the object list
   const long            z_order=0)         // priority for mouse click
  {
   string name = name0;
   int sub_window=0;      // subwindow index

   if(ObjectCreate(0,name,OBJ_VLINE,sub_window,time,0))
     {
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_STYLE,style);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
      ObjectSetInteger(0,name,OBJPROP_BACK,back);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(0,name,OBJPROP_RAY,ray);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_seq102050(string symbol,ENUM_TIMEFRAMES TIMEFRAME,int candle_index)
  {
   int count = 0;
   int maLength = 55+candle_index;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i = maLength-1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol,TIMEFRAME,i);
     }
   double ma10_0 = cal_MA(closePrices,10,candle_index+0);
   double ma10_1 = cal_MA(closePrices,10,candle_index+1);

   double ma20_0 = cal_MA(closePrices,20,candle_index+0);
   double ma20_1 = cal_MA(closePrices,20,candle_index+1);

   double ma50_0 = cal_MA(closePrices,50,candle_index+0);
   double ma50_1 = cal_MA(closePrices,50,candle_index+1);

   if((ma10_0 > ma10_1) && (ma20_0 > ma20_1 || ma50_0 > ma50_1) && (ma10_0 > ma20_0) && (ma20_0 > ma50_0))
      return TREND_BUY;

   if((ma10_0 < ma10_1) && (ma20_0 < ma20_1 || ma50_0 < ma50_1) && (ma10_0 < ma20_0) && (ma20_0 < ma50_0))
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_ma_seq71020_steadily(string symbol,ENUM_TIMEFRAMES TIMEFRAME,string &trend_ma0710,string &trend_ma1020,string &trend_ma02050,string &trend_C1ma10,string &trend_h4_ma50d1,bool &insign_h4)
  {
   trend_ma0710 = "";
   trend_ma1020 = "";
   trend_ma02050 = "";
   trend_C1ma10 = "";
   trend_h4_ma50d1 = "";

   double amp_w1,amp_d1,amp_h4,amp_grid_L100;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_grid_L100);


   int count = 0;
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices,maLength);
   for(int i = maLength-1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol,TIMEFRAME,i);
     }

   double ma07[5] = {0.0,0.0,0.0,0.0,0.0};
   double ma10[5] = {0.0,0.0,0.0,0.0,0.0};
   double ma20[5] = {0.0,0.0,0.0,0.0,0.0};
   for(int i = 0; i < 5; i++)
     {
      ma07[i] = cal_MA(closePrices,7,i);
      ma10[i] = cal_MA(closePrices,10,i);
      ma20[i] = cal_MA(closePrices,20,i);
     }
   double ma50_0 = cal_MA(closePrices,50,0);
   double ma50_1 = cal_MA(closePrices,50,1);
   trend_ma02050 = (ma20[0] > ma50_0)?TREND_BUY:TREND_SEL;

   double price = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(ma50_0+amp_d1 < price)
      trend_h4_ma50d1 = TREND_SEL;
   if(ma50_0-amp_d1 > price)
      trend_h4_ma50d1 = TREND_BUY;

   double ma_min = MathMin(MathMin(MathMin(ma07[0],ma10[0]),ma20[0]),ma50_0);
   double ma_max = MathMax(MathMax(MathMax(ma07[0],ma10[0]),ma20[0]),ma50_0);
   insign_h4 = false;
   if(MathAbs(ma_max-ma_min) < amp_h4*2)
      insign_h4 = true;

// Nếu có ít nhất một cặp giá trị không tăng dần,trả về ""
   string seq_buy_07 = TREND_BUY;
   string seq_buy_10 = TREND_BUY;
   string seq_buy_20 = TREND_BUY;
// Nếu có ít nhất một cặp giá trị không giảm dần,trả về ""
   string seq_sel_07 = TREND_SEL;
   string seq_sel_10 = TREND_SEL;
   string seq_sel_20 = TREND_SEL;

   for(int i = 0; i < 1; i++)
     {
      // BUY
      if(ma07[i] < ma07[i+1])
         seq_buy_07 = "";
      if(ma10[i] < ma10[i+1])
         seq_buy_10 = "";
      if(ma20[i] < ma20[i+1])
         seq_buy_20 = "";

      //SEL
      if(ma07[i] > ma07[i+1])
         seq_sel_07 = "";
      if(ma10[i] > ma10[i+1])
         seq_sel_10 = "";
      if(ma20[i] > ma20[i+1])
         seq_sel_20 = "";
     }
   string trend_ma07_vs10 = ma07[0] > ma10[0]?TREND_BUY:TREND_SEL;
   string trend_ma10_vs20 = ma10[0] > ma20[0]?TREND_BUY:TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10==TREND_BUY && seq_buy_20==TREND_BUY)
      trend_ma1020 = TREND_BUY;
   if(seq_buy_10==TREND_BUY && trend_ma10_vs20==TREND_BUY)
      trend_ma1020 = TREND_BUY;


   if(seq_sel_10==TREND_SEL && seq_sel_20==TREND_SEL)
      trend_ma1020 = TREND_SEL;

   if(seq_sel_10==TREND_SEL && trend_ma10_vs20==TREND_SEL)
      trend_ma1020 = TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10==TREND_BUY && seq_buy_07==TREND_BUY)
      trend_ma0710 = TREND_BUY;
   if(seq_buy_07==TREND_BUY && trend_ma07_vs10==TREND_BUY)
      trend_ma0710 = TREND_BUY;
   if(closePrices[2] > ma07[2] && closePrices[1] > ma07[1] &&
      closePrices[2] > ma10[2] && closePrices[1] > ma10[1])
      trend_ma0710 = TREND_BUY;

   if(seq_sel_10==TREND_SEL && seq_sel_07==TREND_SEL)
      trend_ma0710 = TREND_SEL;
   if(seq_sel_07==TREND_SEL && trend_ma07_vs10==TREND_SEL)
      trend_ma0710 = TREND_SEL;
   if(closePrices[2] < ma07[2] && closePrices[1] < ma07[1] &&
      closePrices[2] < ma10[2] && closePrices[1] < ma10[1])
      trend_ma0710 = TREND_SEL;


   if(closePrices[1] > ma10[1])
      trend_C1ma10 = TREND_BUY;

   if(closePrices[1] < ma10[1])
      trend_C1ma10 = TREND_SEL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_average_candle_height(ENUM_TIMEFRAMES timeframe,string symbol,int length)
  {
   int count = 0;
   double totalHeight = 0.0;

   for(int i = 0; i < length; i++)
     {
      double highPrice = iHigh(symbol,timeframe,i);
      double lowPrice = iLow(symbol,timeframe,i);
      double candleHeight = highPrice-lowPrice;

      count += 1;
      totalHeight += candleHeight;
     }

   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double averageHeight = NormalizeDouble(totalHeight / count,digits);

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
void DeleteArrowObjects()
  {
   int total_objects = ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i = total_objects-1; i >= 0; i--)
     {
      string obj_name = ObjectName(0,i);        // Lấy tên đối tượng
      int obj_type = (int)ObjectGetInteger(0,obj_name,OBJPROP_TYPE); // Lấy loại đối tượng
      if(obj_type==OBJ_ARROW)                  // Kiểm tra nếu đối tượng là OBJ_ARROW
        {
         ObjectDelete(0,obj_name);              // Xóa đối tượng
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjectsFor_PERIOD_W1()
  {
   if(Period()==PERIOD_D1)
     {
      for(int row = 0; row < 10; row++)
        {
         int totalObjects = ObjectsTotal(0);
         for(int i = 0; i < totalObjects-1; i++)
           {
            string objectName = ObjectName(0,i);
            if(is_same_symbol(objectName,"hei_d_"))
               ObjectDelete(0,objectName);
           }
        }
     }

   if(Period() < PERIOD_W1)
      return;

   ObjectDelete(0,"LINE_AMP_FIBO");
   ObjectDelete(0,"LINE_AMP_W");

   for(int row = 0; row < 10; row++)
     {
      int totalObjects = ObjectsTotal(0);
      for(int i = 0; i < totalObjects-1; i++)
        {
         string objectName = ObjectName(0,i);

         if(is_same_symbol(objectName,"Ma10W") ||
            is_same_symbol(objectName,"Ma10D") ||
            is_same_symbol(objectName,"Fibo_") ||
            is_same_symbol(objectName,"stoc_sign_") ||
            is_same_symbol(objectName,"hei_w_") ||
            is_same_symbol(objectName,"hei_d_")
           )
            ObjectDelete(0,objectName);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int totalObjects = ObjectsTotal(0);
   for(int i = 0; i < totalObjects-1; i++)
     {
      string objectName = ObjectName(0,i);
      ObjectDelete(0,objectName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_label_simple(
   const string            name="Text",
   string                  label="Label",
   double                  price = 0,
   color                   clrColor = clrBlack,
   datetime                time_to=0,
   const int               font_size=8
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
   if(is_bold)
     {
      ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
     }
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
   const bool              trim_text = true,
   const int               font_size=8,
   const bool              is_bold = false,
   const int               sub_window = 0
)
  {
   ObjectDelete(0,name);
   color clr_color = TRADING_TREND==TREND_BUY?clrBlue:TRADING_TREND==TREND_SEL?clrRed:clrBlack;
   TextCreate(0,name,sub_window,time_to,price,trim_text?" "+label:"        "+label,clr_color);

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
      Print(__FUNCTION__,": failed to create \"Text\" object! Error code = ",GetLastError());
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
double calc_avg_pivot(ENUM_TIMEFRAMES TIMEFRAME,string symbol,int size = 20)
  {
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp+calc_pivot(symbol,TIMEFRAME,index);
     }
   double tf_amp = total_amp / size;

   return NormalizeDouble(tf_amp,digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_pivot(string symbol,ENUM_TIMEFRAMES TIMEFRAME,int tf_index)
  {
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);// number of decimal places

   double tf_hig = iHigh(symbol, TIMEFRAME,tf_index);
   double tf_low = iLow(symbol,  TIMEFRAME,tf_index);
   double tf_clo = iClose(symbol,TIMEFRAME,tf_index);

   double w_pivot    = format_double((tf_hig+tf_low+tf_clo) / 3,digits);
   double tf_s1    = format_double((2 * w_pivot)-tf_hig,digits);
   double tf_s2    = format_double(w_pivot-(tf_hig-tf_low),digits);
   double tf_s3    = format_double(tf_low-2 * (tf_hig-w_pivot),digits);
   double tf_r1    = format_double((2 * w_pivot)-tf_low,digits);
   double tf_r2    = format_double(w_pivot+(tf_hig-tf_low),digits);
   double tf_r3    = format_double(tf_hig+2 * (w_pivot-tf_low),digits);

   double tf_amp = MathAbs(tf_s3-tf_s2)
                   +MathAbs(tf_s2-tf_s1)
                   +MathAbs(tf_s1-w_pivot)
                   +MathAbs(w_pivot-tf_r1)
                   +MathAbs(tf_r1-tf_r2)
                   +MathAbs(tf_r2-tf_r3);

   tf_amp = format_double(tf_amp / 6,digits);

   return NormalizeDouble(tf_amp,digits);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,START_TRADE_LINE);
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//OnTimer();
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
      if(is_same_symbol(symbol,"\1")){amp_w1 = \3;amp_d1 = \5;amp_h4 = \7;amp_h1 = \9;return;}
   */

//XAUUSD W1    57.145   D1    21.409   H4    9.345 H1    6.118 M15    4.136   M5    2.763;
//XAUUSD W1    57.145   D1    21.409   H4    8.216 H1    1.132 M15    0.187   M5    0.047;

   string file_name = "AvgAmp.txt";
   int fileHandle = FileOpen(file_name,FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         string file_contents = symbol
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

   file_name = "AvgPivot.txt";
   fileHandle = FileOpen(file_name,FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         string file_contents = symbol
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
void createChannel(string name,datetime time1,double price1,datetime time2,double price2,datetime time3,double price3)
  {
// Xóa kênh nếu đã tồn tại
   ObjectDelete(0,name);

// Tạo kênh mới
   ObjectCreate(0,name,OBJ_CHANNEL,0,time1,price1,time2,price2,time3,price3);

// Đặt các thuộc tính cho kênh
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);             // Màu của kênh
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);                  // Độ dày của kênh
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);        // Kiểu đường nét của kênh
   ObjectSetInteger(0,name,OBJPROP_RAY,false);                // Không mở rộng đường kênh
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);          // Cho phép chọn kênh
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);             // Không ẩn kênh
   ObjectSetInteger(0,name,OBJPROP_BACK,false);               // Vẽ kênh phía trước các đối tượng khác
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getGannGridProperties(string symbol,string &time1,string &time2,double &price1,double &scale)
  {
   time1 = "2020.04.05";
   time2 = "2020.10.04";
   if(is_same_symbol("AUDJPY",symbol))
     {
      price1 = 56.780251;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("NZDJPY",symbol))
     {
      price1 = 57.136103;
      scale = 120.00;
      return;
     }
   if(is_same_symbol("EURJPY",symbol))
     {
      price1 = 109.326526;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("GBPJPY",symbol))
     {
      price1 = 119.382734;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("USDJPY",symbol))
     {
      price1 = 104.781215;
      scale = 250.00;
      return;
     }
   if(is_same_symbol("AUDUSD",symbol))
     {
      price1 = 0.539664;
      scale = 100.00;
      return;
     }
   if(is_same_symbol("AUDNZD",symbol))
     {
      price1 = 0.999311;
      scale = 60;
      return;
     }
   if(is_same_symbol("EURNZD",symbol))
     {
      price1 = 1.5475;
      scale = 140;
      return;
     }
   if(is_same_symbol("GBPNZD",symbol))
     {
      price1 = 1.801365;
      scale = 120.00;
      return;
     }
   if(is_same_symbol("NZDUSD",symbol))
     {
      price1 = 0.541205;
      scale = 70;
      return;
     }
   if(is_same_symbol("EURAUD",symbol))
     {
      price1 = 1.393284;
      scale = 200;
      return;
     }
   if(is_same_symbol("AUDCHF",symbol))
     {
      price1 = 0.527752;
      scale = 90.00;
      return;
     }
   if(is_same_symbol("EURCHF",symbol))
     {
      price1 = 0.905838;
      scale = 150;
      return;
     }
   if(is_same_symbol("GBPCHF",symbol))
     {
      price1 = 1.022527;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("USDCHF",symbol))
     {
      price1 = 0.820282;
      scale = 100;
      return;
     }
   if(is_same_symbol("EURGBP",symbol))
     {
      price1 = 0.828975;
      scale = 60;
      return;
     }
   if(is_same_symbol("EURUSD",symbol))
     {
      price1 = 0.946562;
      scale = 100;
      return;
     }
   if(is_same_symbol("GBPUSD",symbol))
     {
      price1 = 1.008458;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("EURCAD",symbol))
     {
      price1 = 1.268354;
      scale = 120;
      return;
     }
   if(is_same_symbol("USDCAD",symbol))
     {
      price1 = 1.196023;
      scale = 100.00;
      return;
     }
   if(is_same_symbol("XAUUSD",symbol))
     {
      price1 = 1094.10099;
      scale = 2931.52;
      return;
     }
   if(is_same_symbol("USOIL",symbol))
     {
      price1 = 7.418861;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("BTCUSD",symbol))
     {
      price1 = 3635.108768;
      scale = 18992.5;
      return;
     }
   if(is_same_symbol("US30",symbol))
     {
      price1 = 18271.067371;
      scale = 800.00;
      return;
     }
   if(is_same_symbol("US500",symbol))
     {
      price1 = 2264.744749;
      scale = 1000.00;
      return;
     }
   if(is_same_symbol("USTEC",symbol))
     {
      price1 = 6185.376848;
      scale = 5555;
      return;
     }
   if(is_same_symbol("FR40",symbol))
     {
      price1 = 3247.2;
      scale = 2000.00;
      return;
     }
   if(is_same_symbol("JP225",symbol))
     {
      price1 = 14371.216374;
      scale = 1000;
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createGannGrid(string name,datetime time1,datetime time2,double price1,double scale)
  {
// Xóa Gann Grid nếu đã tồn tại
   ObjectDelete(0,name);
   ResetLastError();
   if(!ObjectCreate(0,name,OBJ_GANNGRID,0,time1,price1,time2,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ",GetLastError());
      return(false);
     }

// Đặt các thuộc tính cho Gann Grid
   ObjectSetDouble(0,name,OBJPROP_SCALE,scale);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrDimGray); // Màu của Gann Grid
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);  // Kiểu đường nét của Gann Grid
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);          // Độ dày của Gann Grid
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);  // Cho phép chọn Gann Grid
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);     // Không ẩn Gann Grid
   ObjectSetInteger(0,name,OBJPROP_BACK,true);        // Vẽ Gann Grid phía trước các đối tượng khác
   ObjectSetInteger(0,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,OBJ_PERIOD_W1); // OBJ_PERIOD_D1|

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createButton(string objName,string text,int x,int y,int width,int height,color clrTextColor,color clrBackground,int font_size=7,int sub_window = 0)
  {
   long chart_id=0;
   ObjectDelete(chart_id,objName);
   ResetLastError();
   if(!ObjectCreate(chart_id,objName,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ",GetLastError());
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
   ObjectSetInteger(chart_id,objName,OBJPROP_ZORDER,999);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcPotentialTradeProfit(string symbol,string trend_Type,double orderOpenPrice,double orderTakeProfitPrice,double orderLots)
  {
   double   tradeTickValuePerLot    = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);  //Loss/Gain for a 1 tick move with 1 lot
   double   tickValueBasedOnLots    = tradeTickValuePerLot * orderLots;
   double   priceDifference         = MathAbs(orderOpenPrice-orderTakeProfitPrice);
   int      pointsDifference        = (int)(priceDifference / Point());
   double   potentialProfit         = tickValueBasedOnLots * pointsDifference;

   if(is_same_symbol(trend_Type,TREND_BUY))
      potentialProfit = orderTakeProfitPrice > orderOpenPrice?potentialProfit:-potentialProfit;

   if(is_same_symbol(trend_Type,TREND_SEL))
      potentialProfit = orderTakeProfitPrice > orderOpenPrice?-potentialProfit:potentialProfit;

   return NormalizeDouble(potentialProfit,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_manually(string TREND)
  {
   string name = getShortName(TREND);
   string trader_name = "{^"+name+"^}_";
   return trader_name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createLable(string header,string trend)
  {
   string str = getShortName(trend);
   if(str=="")
      return "";

   return header+" "+str;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createLable2(string header,string lalbe)
  {
   if(lalbe==" " || lalbe=="")
      return "";

   return header+" "+lalbe;
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
color getColorByTrend(string trend,color clrDefault = clrNONE)
  {
   if(is_same_symbol(trend,TREND_BUY))
      return clrBlue;

   if(is_same_symbol(trend,TREND_SEL))
      return  clrRed;

   return clrDefault;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getShortStoc(string trend_over_bs_by_stoc)
  {
   string lblStoc = (is_same_symbol(trend_over_bs_by_stoc,TREND_BUY)?"20":"")+" "+(is_same_symbol(trend_over_bs_by_stoc,TREND_SEL)?"80":"");

   StringTrimLeft(lblStoc);
   StringTrimRight(lblStoc);

   if(lblStoc==" " || lblStoc=="" || lblStoc=="20 80")
      lblStoc = "";

   return lblStoc;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_candlestick(string symbol,ENUM_TIMEFRAMES TIME_FRAME,CandleData &candleArray[],int length = 15)
  {
   ArrayResize(candleArray,length+5);
   for(int index = length+3; index >= 0; index--)
     {
      datetime          time  = iTime(symbol,TIME_FRAME,index);    // Thời gian
      double            open  = iOpen(symbol,TIME_FRAME,index);    // Giá mở
      double            high  = iHigh(symbol,TIME_FRAME,index);    // Giá cao
      double            low   = iLow(symbol,TIME_FRAME,index);      // Giá thấp
      double            close = iClose(symbol,TIME_FRAME,index);  // Giá đóng
      string            trend = "";
      if(open < close)
         trend = TREND_BUY;
      if(open > close)
         trend = TREND_SEL;

      CandleData candle(time,open,high,low,close,trend,0,0,"",0,"","","",0,"",0,"","");
      candleArray[index] = candle;
     }


   for(int index = length+3; index >= 0; index--)
     {
      CandleData cancle_i = candleArray[index];

      int count_trend = 1;
      for(int j = index+1; j < length; j++)
        {
         if(cancle_i.trend_heiken==candleArray[j].trend_heiken)
            count_trend += 1;
         else
            break;
        }

      candleArray[index].count_heiken = count_trend;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_heiken(string symbol,ENUM_TIMEFRAMES TIME_FRAME,CandleData &candleArray[],int length = 15,bool is_calc_ma10 = true)
  {
   bool check_seq = false;
   if(TIME_FRAME==PERIOD_H4 || TIME_FRAME==PERIOD_H1)
     {
      length = 50;
      check_seq = true;
     }

   ArrayResize(candleArray,length+5);
     {
      datetime pre_HaTime = iTime(symbol,TIME_FRAME,length+4);
      double pre_HaOpen = iOpen(symbol,TIME_FRAME,length+4);
      double pre_HaHigh = iHigh(symbol,TIME_FRAME,length+4);
      double pre_HaLow = iLow(symbol,TIME_FRAME,length+4);
      double pre_HaClose = iClose(symbol,TIME_FRAME,length+4);
      string pre_candle_trend = pre_HaClose > pre_HaOpen?TREND_BUY:TREND_SEL;

      CandleData candle(pre_HaTime,pre_HaOpen,pre_HaHigh,pre_HaLow,pre_HaClose,pre_candle_trend,0,0,"",0,"","","",0,"",0,"","");
      candleArray[length+4] = candle;
     }

   for(int index = length+3; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index+1];

      datetime haTime = iTime(symbol,TIME_FRAME,index);
      double haClose = (iOpen(symbol,TIME_FRAME,index)+iClose(symbol,TIME_FRAME,index)+iHigh(symbol,TIME_FRAME,index)+iLow(symbol,TIME_FRAME,index)) / 4.0;
      double haOpen  = (pre_cancle.open+pre_cancle.close) / 2.0;
      double haHigh  = MathMax(MathMax(haOpen,haClose),iHigh(symbol,TIME_FRAME,index));
      double haLow   = MathMin(MathMin(haOpen,haClose), iLow(symbol,TIME_FRAME,index));
      string haTrend = haClose >= haOpen?TREND_BUY:TREND_SEL;

      int count_heiken = 1;
      for(int j = index+1; j < length; j++)
        {
         if(haTrend==candleArray[j].trend_heiken)
            count_heiken += 1;
         else
            break;
        }

      CandleData candle_x(haTime,haOpen,haHigh,haLow,haClose,haTrend,count_heiken,0,"",0,"","","",0,"",0,"","");
      candleArray[index] = candle_x;
     }

   double lowest = 0.0,higest = 0.0;
   int range = 7;
   if(TIME_FRAME==PERIOD_H4)
      range = 6;
   if(TIME_FRAME==PERIOD_H1)
      range = 12;

   for(int idx = 0; idx <= range; idx++)
     {
      double low = candleArray[idx].low;
      double hig = candleArray[idx].high;
      if((idx==0) || (lowest > low))
         lowest = low;
      if((idx==0) || (higest < hig))
         higest = hig;
     }

   if(is_calc_ma10)
     {
      double closePrices[];
      int maLength = length+15;
      ArrayResize(closePrices,maLength);

      for(int i = maLength-1; i >= 0; i--)
         closePrices[i] = iClose(symbol,TIME_FRAME,i);

      for(int index = ArraySize(candleArray)-2; index >= 0; index--)
        {
         CandleData pre_cancle = candleArray[index+1];
         CandleData cur_cancle = candleArray[index];

         double ma03 = cal_MA(closePrices, 3,index==0?1:index);
         double ma05 = cal_MA(closePrices, 5,index==0?1:index);
         double ma10 = cal_MA(closePrices,10,index==0?index:index);

         string trend_vector_ma10 = pre_cancle.ma10 < ma10?TREND_BUY:TREND_SEL;
         string trend_ma5vs10 = (ma05 > ma10)?TREND_BUY:(ma05 < ma10)?TREND_SEL:"";
         double mid = cur_cancle.close;
         string trend_by_ma05 = (mid > ma05)?TREND_BUY:(mid < ma05)?TREND_SEL:"";
         string trend_by_ma10 = (mid > ma10)?TREND_BUY:(mid < ma10)?TREND_SEL:"";
         int count_ma10 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_by_ma10==candleArray[j].trend_by_ma10)
               count_ma10 += 1;
            else
               break;
           }

         string trend_ma3_vs_ma5 = (ma03 > ma05)?TREND_BUY:(ma03 < ma05)?TREND_SEL:"";
         int count_ma3_vs_ma5 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_ma3_vs_ma5==candleArray[j].trend_ma3_vs_ma5)
               count_ma3_vs_ma5 += 1;
            else
               break;
           }

         double ma50 = 0;
         string trend_seq = "";
         if(check_seq && (index==0))
           {
            ma50 = cal_MA(closePrices,50,1);

            string temp_seq = "";
            double ma20 = cal_MA(closePrices,20,1);

            if(0 < ma50 && lowest <= ma50 && ma50 <= higest)
              {
               string trend_ma03_vs_20 = (ma03 > ma20)?TREND_BUY:(ma03 < ma20)?TREND_SEL:"";
               string trend_ma10_vs_50 = (ma10 > ma50)?TREND_BUY:(ma10 < ma50)?TREND_SEL:"";
               if(trend_ma10_vs_50==trend_ma03_vs_20 && trend_ma10_vs_50==candleArray[0].trend_heiken)
                 {
                  temp_seq = trend_ma10_vs_50;
                 }
              }


            if(temp_seq != "")
              {
               double amp_w1,amp_d1,amp_h4,amp_grid_L100;
               GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_grid_L100);

               double amp_seq = MathMax(MathAbs(ma03-ma20),MathAbs(ma03-ma50));
               if(amp_seq <= amp_d1)
                  trend_seq = temp_seq;
              }
           }

         string trend_ma10vs20 = "";
         if(TIME_FRAME==PERIOD_D1 && index==0)
           {
            double ma20 = cal_MA(closePrices,20,1);
            trend_ma10vs20 = (ma10 > ma20)?TREND_BUY:(ma10 < ma20)?TREND_SEL:"";
           }

         CandleData candle_x(cur_cancle.time,cur_cancle.open,cur_cancle.high,cur_cancle.low,cur_cancle.close,cur_cancle.trend_heiken
                             ,cur_cancle.count_heiken,ma10,trend_by_ma10,count_ma10,trend_vector_ma10
                             ,trend_by_ma05,trend_ma3_vs_ma5,count_ma3_vs_ma5,trend_seq,ma50,trend_ma10vs20,trend_ma5vs10);

         candleArray[index] = candle_x;
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol,ENUM_TIMEFRAMES TIME_FRAME,int candle_index = 0)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol,TIME_FRAME,candleArray);

   return candleArray[candle_index].trend_heiken;
  }
//+------------------------------------------------------------------+
double get_largest_negative(string TRADER)
  {
   for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
     {
      string name = arr_largest_negative_trader_name[i];
      if(is_same_symbol(name,TRADER))
         return MathAbs(NormalizeDouble(arr_largest_negative_trader_amount[i],2));
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_largest_negative(string TRADER,double profit)
  {
   if(profit > 0)
      return;

   double found_trader = false;
   for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
     {
      string name = arr_largest_negative_trader_name[i];
      if(is_same_symbol(name,TRADER))
        {
         found_trader = true;
         if(MathAbs(arr_largest_negative_trader_amount[i]) < MathAbs(profit))
            arr_largest_negative_trader_amount[i] = MathAbs(profit);
        }
     }

   if(found_trader==false)
     {
      for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
        {
         string name = arr_largest_negative_trader_name[i];
         if(name=="" || StringLen(name) < 1)
           {
            arr_largest_negative_trader_name[i] = TRADER;
            arr_largest_negative_trader_amount[i] = MathAbs(profit);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Risk_1L_By_Account_Balance()
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   return NormalizeDouble(BALANCE*RISK_BY_PERCENT/100,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Risk_Min()
  {
//double risk_1p = Risk_1L_By_Account_Balance();
//double risk_min = NormalizeDouble(risk_1p/5,2);
   return 3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_comment(string TRADER,string TRADING_TREND,int L)
  {
   string result = TRADER+TRADING_TREND+"_"+appendZero100(L);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_L(string TRADER,string trend,string last_comment)
  {
   for(int i = 1; i < 100; i++)
     {
      string comment = create_comment(TRADER,trend,i);
      if(is_same_symbol(last_comment,comment))
         return i;
     }

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetAmpAvgL15(string symbol,double &amp_w1,double &amp_d1,double &amp_h4,double &amp_grid_L100)
  {
   if(is_same_symbol(symbol,"XAUUSD"))
     {
      amp_w1 = 83.539;
      amp_d1 = 31.359;
      amp_h4 = 6.295;
      amp_grid_L100 = 5;
      return;
     }
   if(is_same_symbol(symbol,"XAGUSD"))
     {
      amp_w1 = 1.3;
      amp_d1 = 0.45;
      amp_h4 = 0.2;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"USOIL"))
     {
      amp_w1 = 3.935;
      amp_d1 = 1.656;
      amp_h4 = 0.805;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"BTCUSD"))
     {
      amp_w1 = 7010.38;
      amp_d1 = 2930.00;
      amp_h4 = 789.1;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"USTEC"))
     {
      amp_w1 = 785.89;
      amp_d1 = 350.00;
      amp_h4 = 81.16;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"US30"))
     {
      amp_w1 = 1037.8;
      amp_d1 = 427.0;
      amp_h4 = 119.5;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"US500"))
     {
      amp_w1 = 150.5;
      amp_d1 = 64.88;
      amp_h4 = 16.93;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"DE30"))
     {
      amp_w1 = 530.6;
      amp_d1 = 156.6;
      amp_h4 = 62.3;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"UK100"))
     {
      amp_w1 = 208.25;
      amp_d1 = 68.31;
      amp_h4 = 29.0;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"FR40"))
     {
      amp_w1 = 250.00;
      amp_d1 = 100.00;
      amp_h4 = 30.00;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"JP225"))
     {
      amp_w1 = 2000.00;
      amp_d1 = 1000.00;
      amp_h4 = 700.00;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"AUS200"))
     {
      amp_w1 = 204.43;
      amp_d1 = 67.52;
      amp_h4 = 29.93;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"AUDCHF"))
     {
      amp_w1 = 0.01242;
      amp_d1 = 0.00500;
      amp_h4 = 0.00158;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"AUDNZD"))
     {
      amp_w1 = 0.01036;
      amp_d1 = 0.00495;
      amp_h4 = 0.00178;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"AUDUSD"))
     {
      amp_w1 = 0.01267;
      amp_d1 = 0.00452;
      amp_h4 = 0.00218;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"AUDJPY"))
     {
      amp_w1 = 2.950;
      amp_d1 = 1.165;
      amp_h4 = 0.282;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"CHFJPY"))
     {
      amp_w1 = 2.911;
      amp_d1 = 1.107;
      amp_h4 = 0.458;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"EURJPY"))
     {
      amp_w1 = 3.700;
      amp_d1 = 1.642;
      amp_h4 = 0.434;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"GBPJPY"))
     {
      amp_w1 = 4.600;
      amp_d1 = 2.115;
      amp_h4 = 0.53;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"NZDJPY"))
     {
      amp_w1 = 2.419;
      amp_d1 = 1.068;
      amp_h4 = 0.272;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"USDJPY"))
     {
      amp_w1 = 3.550;
      amp_d1 = 1.659;
      amp_h4 = 0.427;
      amp_grid_L100 = 1.5;
      return;
     }
   if(is_same_symbol(symbol,"EURAUD"))
     {
      amp_w1 = 0.02215;
      amp_d1 = 0.00954;
      amp_h4 = 0.00417;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"EURCAD"))
     {
      amp_w1 = 0.01382;
      amp_d1 = 0.00562;
      amp_h4 = 0.00284;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"EURCHF"))
     {
      amp_w1 = 0.01309;
      amp_d1 = 0.00525;
      amp_h4 = 0.00180;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"EURGBP"))
     {
      amp_w1 = 0.00695;
      amp_d1 = 0.00283;
      amp_h4 = 0.00131;
      amp_grid_L100 = 0.00155;
      return;
     }
   if(is_same_symbol(symbol,"EURNZD"))
     {
      amp_w1 = 0.02402;
      amp_d1 = 0.01128;
      amp_h4 = 0.00478;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"EURUSD"))
     {
      amp_w1 = 0.01257;
      amp_d1 = 0.00456;
      amp_h4 = 0.00239;
      amp_grid_L100 = 0.0035;
      return;
     }
   if(is_same_symbol(symbol,"GBPCHF"))
     {
      amp_w1 = 0.01905;
      amp_d1 = 0.00752;
      amp_h4 = 0.00241;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"GBPNZD"))
     {
      amp_w1 = 0.02912;
      amp_d1 = 0.01240;
      amp_h4 = 0.00531;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"GBPUSD"))
     {
      amp_w1 = 0.01652;
      amp_d1 = 0.00630;
      amp_h4 = 0.00317;
      amp_grid_L100 = 0.00335;
      return;
     }
   if(is_same_symbol(symbol,"NZDCAD"))
     {
      amp_w1 = 0.01459;
      amp_d1 = 0.0055;
      amp_h4 = 0.00216;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"NZDUSD"))
     {
      amp_w1 = 0.01106;
      amp_d1 = 0.00435;
      amp_h4 = 0.0021;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"USDCAD"))
     {
      amp_w1 = 0.01328;
      amp_d1 = 0.00462;
      amp_h4 = 0.00252;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol,"USDCHF"))
     {
      amp_w1 = 0.01397;
      amp_d1 = 0.00569;
      amp_h4 = 0.00235;
      amp_grid_L100 = 0.006;
      return;
     }

   amp_w1 = calc_average_candle_height(PERIOD_W1,symbol,20);
   amp_d1 = calc_average_candle_height(PERIOD_D1,symbol,30);
   amp_h4 = calc_average_candle_height(PERIOD_H4,symbol,60);
   amp_grid_L100 = amp_d1;
//SendAlert(INDI_NAME,"Get Amp Avg"," Get AmpAvg:"+(string)symbol+"   amp_w1: "+(string)amp_w1+"   amp_d1: "+(string)amp_d1+"   amp_h4: "+(string)amp_h4);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol,double &i_top_price,double &amp_w,double &dic_amp_init_h4,double &dic_amp_init_d1)
  {
   if(is_same_symbol(symbol,"BTCUSD"))
     {
      i_top_price = 36285;
      dic_amp_init_d1 = 0.05;
      amp_w = 1357.35;
      dic_amp_init_h4 = 0.03;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"USOIL"))
     {
      i_top_price = 120.000;
      dic_amp_init_d1 = 0.10;
      amp_w = 2.75;
      dic_amp_init_h4 = 0.05;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"XAGUSD"))
     {
      i_top_price = 25.7750;
      dic_amp_init_d1 = 0.06;
      amp_w = 0.63500;
      dic_amp_init_h4 = 0.03;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"XAUUSD"))
     {
      i_top_price = 2088;
      dic_amp_init_d1 = 0.03;
      amp_w = 27.83;
      dic_amp_init_h4 = 0.015;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"US500"))
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.05;
      amp_w = 60.00;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"US100.cash") || is_same_symbol(symbol,"USTEC"))
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.05;
      amp_w = 274.5;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"US30"))
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.05;
      amp_w = 438.76;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"UK100"))
     {
      i_top_price = 7755.65;
      dic_amp_init_d1 = 0.05;
      amp_w = 95.38;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"GER40"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"DE30"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"FRA40") || is_same_symbol(symbol,"FR40"))
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 0.05;
      amp_w = 117.6866;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"AUS200"))
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 0.05;
      amp_w = 93.59;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"AUDJPY"))
     {
      i_top_price = 98.5000;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.100;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"AUDUSD"))
     {
      i_top_price = 0.7210;
      dic_amp_init_d1 = 0.03;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.015;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"EURAUD"))
     {
      i_top_price = 1.71850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01365;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"EURGBP"))
     {
      i_top_price = 0.9010;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00497;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"EURUSD"))
     {
      i_top_price = 1.12465;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0080;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"GBPUSD"))
     {
      i_top_price = 1.315250;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01085;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }
   if(is_same_symbol(symbol,"USDCAD"))
     {
      i_top_price = 1.38950;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00795;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"USDCHF"))
     {
      i_top_price = 0.93865;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00750;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"USDJPY"))
     {
      i_top_price = 154.525;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.4250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"CADCHF"))
     {
      i_top_price = 0.702850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"CADJPY"))
     {
      i_top_price = 111.635;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.0250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"CHFJPY"))
     {
      i_top_price = 171.450;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.365000;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"EURJPY"))
     {
      i_top_price = 162.565;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.43500;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"GBPJPY"))
     {
      i_top_price = 188.405;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.61500;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"NZDJPY"))
     {
      i_top_price = 90.435;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.90000;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"EURCAD"))
     {
      i_top_price = 1.5225;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00945;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"EURCHF"))
     {
      i_top_price = 0.96800;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"EURNZD"))
     {
      i_top_price = 1.89655;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01585;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"GBPAUD"))
     {
      i_top_price = 1.9905;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01575;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"GBPCAD"))
     {
      i_top_price = 1.6885;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01210;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"GBPCHF"))
     {
      i_top_price = 1.11485;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0085;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"GBPNZD"))
     {
      i_top_price = 2.09325;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.016250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"AUDCAD"))
     {
      i_top_price = 0.90385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"AUDCHF"))
     {
      i_top_price = 0.654500;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.005805;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"AUDNZD"))
     {
      i_top_price = 1.09385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00595;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"NZDCAD"))
     {
      i_top_price = 0.84135;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.007200;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"NZDCHF"))
     {
      i_top_price = 0.55;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"NZDUSD"))
     {
      i_top_price = 0.6275;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00660;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   if(is_same_symbol(symbol,"DXY"))
     {
      i_top_price = 103.458;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.6995;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol,PERIOD_W1,1);
      return;
     }

   i_top_price = iClose(symbol,PERIOD_W1,1);
   dic_amp_init_d1 = calc_avg_amp_week(symbol,PERIOD_D1,50);
   amp_w = calc_avg_amp_week(symbol,PERIOD_W1,50);
   dic_amp_init_h4 = calc_avg_amp_week(symbol,PERIOD_H4,50);

   SendAlert(BOT_SHORT_NM,"SymbolData"," Get SymbolData:"+(string)symbol+"   i_top_price: "+(string)i_top_price+"   amp_w: "+(string)amp_w+"   dic_amp_init_h4: "+(string)dic_amp_init_h4);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_amp_week(string symbol,ENUM_TIMEFRAMES TIMEFRAME,int size = 20)
  {
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp+calc_week_amp(symbol,TIMEFRAME,index);
     }
   double week_amp = total_amp / size;

   return week_amp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_week_amp(string symbol,ENUM_TIMEFRAMES TIMEFRAME,int week_index)
  {
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);// number of decimal places

   double week_hig = iHigh(symbol, TIMEFRAME,week_index);
   double week_low = iLow(symbol,  TIMEFRAME,week_index);
   double week_clo = iClose(symbol,TIMEFRAME,week_index);

   double w_pivot    = format_double((week_hig+week_low+week_clo) / 3,digits);
   double week_s1    = format_double((2 * w_pivot)-week_hig,digits);
   double week_s2    = format_double(w_pivot-(week_hig-week_low),digits);
   double week_s3    = format_double(week_low-2 * (week_hig-w_pivot),digits);
   double week_r1    = format_double((2 * w_pivot)-week_low,digits);
   double week_r2    = format_double(w_pivot+(week_hig-week_low),digits);
   double week_r3    = format_double(week_hig+2 * (w_pivot-week_low),digits);

   double week_amp = MathAbs(week_s3-week_s2)
                     +MathAbs(week_s2-week_s1)
                     +MathAbs(week_s1-w_pivot)
                     +MathAbs(w_pivot-week_r1)
                     +MathAbs(week_r1-week_r2)
                     +MathAbs(week_r2-week_r3);

   week_amp = format_double(week_amp / 6,digits);

   return week_amp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTodayProfitLoss()
  {
   double totalProfitLoss = 0.0; // Variable to store total profit or loss

   MqlDateTime date_time;
   TimeToStruct(TimeCurrent(),date_time);
   int current_day = date_time.day,current_month = date_time.mon,current_year = date_time.year;
   int row_count = 0;
// --------------------------------------------------------------------
// --------------------------------------------------------------------
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   HistorySelect(0,TimeCurrent()); // today closed trades PL
   int orders = HistoryDealsTotal();

   double PL = 0.0;
   for(int i = orders-1; i >= 0; i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
        {
         break;
        }

      string symbol  = HistoryDealGetString(ticket,DEAL_SYMBOL);
      if(symbol=="")
        {
         continue;
        }

      double profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);

      if(profit != 0)  // If deal is trade exit with profit or loss
        {
         MqlDateTime deal_time;
         TimeToStruct(HistoryDealGetInteger(ticket,DEAL_TIME),deal_time);

         // If is today deal
         if(deal_time.day==current_day && deal_time.mon==current_month && deal_time.year==current_year)
           {
            PL += profit;
           }
         else
            break;
        }
     }

//double swap = 0.0;
//for(int i = PositionsTotal()-1; i >= 0; i--)
//  {
//   if(m_position.SelectByIndex(i))
//     {
//      swap += m_position.Swap();
//     }
//  } //for

   return PL;

//   double starting_balance = current_balance-PL;
//   double current_equity   = AccountInfoDouble(ACCOUNT_EQUITY);
//   totalProfitLoss = current_equity-starting_balance;
//
//   return totalProfitLoss; // Return the total profit or loss
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteIndicatorsWindows()
  {
   long chart_id = ChartID();

   int windowCount = 100;  // Assumed maximum number of windows for safety
   for(int windowIndex = 1; windowIndex < windowCount; windowIndex++)
     {
      int indicatorCount = ChartIndicatorsTotal(chart_id,windowIndex);
      if(indicatorCount <= 0)
         continue;

      for(int i = indicatorCount-1; i >= 0; i--)
        {
         string indicatorName = ChartIndicatorName(chart_id,windowIndex,i);

         if(!ChartIndicatorDelete(chart_id,windowIndex,indicatorName))
           {
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateRemainder(double price,double AMP_DCA_MIN)
  {
   int digits = (int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
   return NormalizeDouble(MathMod(price,AMP_DCA_MIN),digits-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateQuotient(double price,double AMP_DCA_MIN)
  {
   return MathFloor(price / AMP_DCA_MIN);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_Cno()
  {
   return "";
   double AMP_DC = 10;
   int NUMBER_OF_TRADER = 5;
   double bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double price = (bid+ask)/2;
   double step = NormalizeDouble(AMP_DC / (NUMBER_OF_TRADER),2);
   double rm1 = CalculateRemainder(price,AMP_DC);
   double rm2 = CalculateQuotient(rm1,step); //0.25: 20 Traders,0.5: 10 Traders

   return "(C"+(string)+rm2+")";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_doji_heiken_ashi(CandleData &candleArray[],int candle_index)
  {
   double open = candleArray[candle_index].open;
   double high = candleArray[candle_index].high;
   double low = candleArray[candle_index].low;
   double close = candleArray[candle_index].close;

   double body = MathAbs(open-close) * 3;
   double shadow_hig = high-MathMax(open,close);
   double shadow_low = MathMin(open,close)-low;

   bool isDoji = (body <= shadow_hig) && (body <= shadow_low);

   return isDoji;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string to_percent(double profit,double decimal_part = 2)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   string percent = " ("+format_double_to_string(profit/BALANCE * 100,1)+"%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getArraySymbolsSize()
  {
//--- Account number
   long login=AccountInfoInteger(ACCOUNT_LOGIN);

   if(is_same_symbol(REAL_ACCOUNT,(string)login))
      return ArraySize(ARR_SYMBOLS_CENT);

   return ArraySize(ARR_SYMBOLS_USD);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getSymbolAtIndex(int index)
  {
//--- Account number
   long login=AccountInfoInteger(ACCOUNT_LOGIN);

   if(is_same_symbol(REAL_ACCOUNT,(string)login))
      return ARR_SYMBOLS_CENT[index];
   else
      return ARR_SYMBOLS_USD[index];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool allowSendMsgByAccount()
  {
//--- Account number
   long login=AccountInfoInteger(ACCOUNT_LOGIN);

   if(is_same_symbol(REAL_ACCOUNT,(string)login))
      return true;

   return false;
  }
//+------------------------------------------------------------------+
void init_stoc_h4_by_w1_ma10()
  {
   string key_h4_buy = (string)PERIOD_H4+(string)OP_BUY;
   string key_h4_sel = (string)PERIOD_H4+(string)OP_SEL;

   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string temp_symbol = getSymbolAtIndex(index);

      CandleData arrHeiken_W1[];
      get_arr_heiken(temp_symbol,PERIOD_W1,arrHeiken_W1,10,true);

      string Notice_Stoc = "-1";
      if(arrHeiken_W1[0].trend_by_ma10==TREND_BUY)
         Notice_Stoc = key_h4_buy;
      if(arrHeiken_W1[0].trend_by_ma10==TREND_SEL)
         Notice_Stoc = key_h4_sel;

      GlobalVariableSet(BtnSendNoticeStoc+temp_symbol,(double)Notice_Stoc);

      datetime vietnamTime = TimeGMT()+7 * 3600;
      MqlDateTime time_struct;
      TimeToStruct(vietnamTime,time_struct);
      string today = (string)time_struct.year+(string)time_struct.mon+(string)time_struct.day;
      GlobalVariableSet("RESET_DAY",(double)today);
     }

   Draw_Notice_Ma10D();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Buttons_Trend(string symbol)
  {
   if(is_same_symbol(symbol,Symbol())==false)
      return;

   string trend_by_macd_w1 = "",trend_mac_vs_signal_w1 = "",trend_mac_vs_zero_w1 = "",trend_vector_histogram_w1 = "",trend_vector_signal_w1 = "",trend_macd_note_w1="";
   string trend_by_macd_d1 = "",trend_mac_vs_signal_d1 = "",trend_mac_vs_zero_d1 = "",trend_vector_histogram_d1 = "",trend_vector_signal_d1 = "",trend_macd_note_d1="";
   string trend_by_macd_h4 = "",trend_mac_vs_signal_h4 = "",trend_mac_vs_zero_h4 = "",trend_vector_histogram_h4 = "",trend_vector_signal_h4 = "",trend_macd_note_h4="";
   string trend_by_macd_h1 = "",trend_mac_vs_signal_h1 = "",trend_mac_vs_zero_h1 = "",trend_vector_histogram_h1 = "",trend_vector_signal_h1 = "",trend_macd_note_h1="";

   trend_by_macd_w1=get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_W1);//,trend_by_macd_w1,trend_mac_vs_signal_w1,trend_mac_vs_zero_w1,trend_vector_histogram_w1,trend_vector_signal_w1,trend_macd_note_w1);
   trend_by_macd_d1=get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_D1);//,trend_by_macd_d1,trend_mac_vs_signal_d1,trend_mac_vs_zero_d1,trend_vector_histogram_d1,trend_vector_signal_d1,trend_macd_note_d1);
   trend_by_macd_h4=get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_H4);//,trend_by_macd_h4,trend_mac_vs_signal_h4,trend_mac_vs_zero_h4,trend_vector_histogram_h4,trend_vector_signal_h4,trend_macd_note_h4);
   trend_by_macd_h1=get_trend_by_macd_and_signal_vs_zero(symbol,PERIOD_H1);//,trend_by_macd_h1,trend_mac_vs_signal_h1,trend_mac_vs_zero_h1,trend_vector_histogram_h1,trend_vector_signal_h1,trend_macd_note_h1);

   CandleData arrHeiken_W1[];
   CandleData arrHeiken_D1[];
   CandleData arrHeiken_H4[];
   CandleData arrHeiken_H1[];
   get_arr_heiken(symbol,PERIOD_W1,arrHeiken_W1,15,true);
   get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,35,true);
   get_arr_heiken(symbol,PERIOD_H4,arrHeiken_H4,20,true);
   get_arr_heiken(symbol,PERIOD_H1,arrHeiken_H1,20,true);

   string trend_by_ma10_w1 = arrHeiken_W1[0].trend_by_ma10;
   string trend_by_ma10_d1 = arrHeiken_D1[0].trend_by_ma10;
   string trend_by_ma10_h4 = arrHeiken_H4[0].trend_by_ma10;
   string trend_by_ma10_h1 = arrHeiken_H1[0].trend_by_ma10;

   string TF = get_current_timeframe_to_string();

   int chart_width = (int) MathRound(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS));

   int chart_macd_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,1));
   int chart_stoc_heigh = (int) MathRound(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,2));

   int x_max = chart_width-70;
   int y_start = 80;
   int y_row_m4 = y_start-20*11-5*6;
   int y_row_m3 = y_start-20*10-5*5;
   int y_row_m2 = y_start-20*9 -5*4;
   int y_row_m1 = y_start-20*7-5*2;
   int y_row_0  = y_start-20*6-5*1;
   int y_row_1  = y_start-20*5+5*0;
   int y_row_2  = y_start-20*4+5*1;
   int y_row_3  = y_start-20*3+5*2;
   int y_row_4  = y_start-20*2+5*3;
   int y_row_5  = y_start-20*1+5*4;
   int y_row_6  = y_start-20*0+5*5;

     {
      string key_d1_buy = (string)PERIOD_D1+(string)OP_BUY;
      string key_d1_sel = (string)PERIOD_D1+(string)OP_SEL;
      string key_h4_buy = (string)PERIOD_H4+(string)OP_BUY;
      string key_h4_sel = (string)PERIOD_H4+(string)OP_SEL;
      string key_h1_buy = (string)PERIOD_H1+(string)OP_BUY;
      string key_h1_sel = (string)PERIOD_H1+(string)OP_SEL;

      //--------------------------------------------------------------------------------------------

      string Notice_Symbol = (string) GetGlobalVariable(BtnSendNoticeHei+symbol);

      string lblMsgD1 = "Ma.Hei.D1+H4H1 "+(is_same_symbol(Notice_Symbol,key_d1_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Symbol,key_d1_sel)?TREND_SEL:"");
      if(is_same_symbol(lblMsgD1,TREND_BUY) && is_same_symbol(lblMsgD1,TREND_SEL))
         lblMsgD1 = "Ma.Hei.D1+H4H1";
      color bgColorD1 = is_same_symbol(Notice_Symbol,key_d1_buy)?clrActiveBtn:is_same_symbol(Notice_Symbol,key_d1_sel)?clrMistyRose:clrWhite;

      string lblMsgH4 = "Ma.Hei.H4+H1 "+(is_same_symbol(Notice_Symbol,key_h4_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Symbol,key_h4_sel)?TREND_SEL:"");
      if(is_same_symbol(lblMsgH4,TREND_BUY) && is_same_symbol(lblMsgH4,TREND_SEL))
         lblMsgH4 = "Ma.Hei.H4+H1";
      color bgColorH4 = is_same_symbol(Notice_Symbol,key_h4_buy)?clrActiveBtn:is_same_symbol(Notice_Symbol,key_h4_sel)?clrMistyRose:clrWhite;

      string lblMsgH1 = "Ma.Hei.H1 "+(is_same_symbol(Notice_Symbol,key_h1_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Symbol,key_h1_sel)?TREND_SEL:"");
      if(is_same_symbol(lblMsgH1,TREND_BUY) && is_same_symbol(lblMsgH1,TREND_SEL))
         lblMsgH1 = "Ma.Hei.H1";
      color bgColorH1 = is_same_symbol(Notice_Symbol,key_h1_buy)?clrActiveBtn:is_same_symbol(Notice_Symbol,key_h1_sel)?clrMistyRose:clrWhite;

      int chart_mid_heigh = (int)(chart_heigh/2-50+25*3);
      createButton(BtnSendNoticeHei+"_D1","(Msg) "+lblMsgD1,5,chart_mid_heigh+25*4,BTN_SEND_MSG_WIDTH,20,clrBlack,bgColorD1,7);
      createButton(BtnSendNoticeHei+"_H4","(Msg) "+lblMsgH4,5,chart_mid_heigh+25*5,BTN_SEND_MSG_WIDTH,20,clrBlack,bgColorH4,7);
      createButton(BtnSendNoticeHei+"_H1","(Msg) "+lblMsgH1,5,chart_mid_heigh+25*6,BTN_SEND_MSG_WIDTH,20,clrBlack,bgColorH1,7);

      //--------------------------------------------------------------------------------------------

      string Notice_Macd = (string) GetGlobalVariable(BtnSendNoticeMacd+symbol);
      string lblMacdD1 = "HeiD1+Macd "+(is_same_symbol(Notice_Macd,key_d1_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Macd,key_d1_sel)?TREND_SEL:"");
      if(is_same_symbol(lblMacdD1,TREND_BUY) && is_same_symbol(lblMacdD1,TREND_SEL))
         lblMacdD1 = "HeiD1+Macd";
      color bgMacdD1 = is_same_symbol(Notice_Macd,key_d1_buy)?clrActiveBtn:is_same_symbol(Notice_Macd,key_d1_sel)?clrMistyRose:clrWhite;

      string lblMacdH4 = "HeiH4+Macd "+(is_same_symbol(Notice_Macd,key_h4_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Macd,key_h4_sel)?TREND_SEL:"");
      if(is_same_symbol(lblMacdH4,TREND_BUY) && is_same_symbol(lblMacdH4,TREND_SEL))
         lblMacdH4 = "HeiH4+Macd";
      color bgMacdH4 = is_same_symbol(Notice_Macd,key_h4_buy)?clrActiveBtn:is_same_symbol(Notice_Macd,key_h4_sel)?clrMistyRose:clrWhite;

      string lblMacdH1 = "HeiH1+Macd "+(is_same_symbol(Notice_Macd,key_h1_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Macd,key_h1_sel)?TREND_SEL:"");
      if(is_same_symbol(lblMacdH1,TREND_BUY) && is_same_symbol(lblMacdH1,TREND_SEL))
         lblMacdH1 = "HeiH1+Macd";
      color bgMacdH1 = is_same_symbol(Notice_Macd,key_h1_buy)?clrActiveBtn:is_same_symbol(Notice_Macd,key_h1_sel)?clrMistyRose:clrWhite;

      createButton(BtnSendNoticeMacd+"_D1","(Msg) "+lblMacdD1,5, 5,BTN_SEND_MSG_WIDTH,20,clrBlack,bgMacdD1,7,1);
      createButton(BtnSendNoticeMacd+"_H4","(Msg) "+lblMacdH4,5,30,BTN_SEND_MSG_WIDTH,20,clrBlack,bgMacdH4,7,1);
      createButton(BtnSendNoticeMacd+"_H1","(Msg) "+lblMacdH1,5,55,BTN_SEND_MSG_WIDTH,20,clrBlack,bgMacdH1,7,1);

      //--------------------------------------------------------------------------------------------

      string Notice_Stoc = (string) GetGlobalVariable(BtnSendNoticeStoc+symbol);
      string lblStocD1 = "HeiD1+Sto21 "+(is_same_symbol(Notice_Stoc,key_d1_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Stoc,key_d1_sel)?TREND_SEL:"");
      if(is_same_symbol(lblStocD1,TREND_BUY) && is_same_symbol(lblStocD1,TREND_SEL))
         lblStocD1 = "(D1) Sto21";
      color bgStocD1 = is_same_symbol(Notice_Stoc,key_d1_buy)?clrActiveBtn:is_same_symbol(Notice_Stoc,key_d1_sel)?clrMistyRose:clrWhite;

      string lblStocH4 = "W+Hei.Ma.H4 "+(is_same_symbol(Notice_Stoc,key_h4_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Stoc,key_h4_sel)?TREND_SEL:"");
      if(is_same_symbol(lblStocH4,TREND_BUY) && is_same_symbol(lblStocH4,TREND_SEL))
         lblStocH4 = "W+Hei.Ma.H4";
      color bgStocH4 = is_same_symbol(Notice_Stoc,key_h4_buy)?clrActiveBtn:is_same_symbol(Notice_Stoc,key_h4_sel)?clrMistyRose:clrWhite;

      string lblStocH1 = "HeiH1+Sto21 "+(is_same_symbol(Notice_Stoc,key_h1_buy)?TREND_BUY:"")+(is_same_symbol(Notice_Stoc,key_h1_sel)?TREND_SEL:"");
      if(is_same_symbol(lblStocH1,TREND_BUY) && is_same_symbol(lblStocH1,TREND_SEL))
         lblStocH1 = "HeiH1+Sto21";
      color bgStocH1 = is_same_symbol(Notice_Stoc,key_h1_buy)?clrActiveBtn:is_same_symbol(Notice_Stoc,key_h1_sel)?clrMistyRose:clrWhite;

      createButton(BtnSendNoticeStoc+"_H4","(Msg) "+lblStocH4,5, 5,BTN_SEND_MSG_WIDTH,20,clrBlack,bgStocH4,7,2);
      createButton(BtnSendNoticeStoc+"_H1","(Msg) "+lblStocH1,5,30,BTN_SEND_MSG_WIDTH,20,clrBlack,bgStocH1,7,2);
      createButton(BtnResetWaitBuySelM5,"Reset Wait Buy.Sel",   5,60,BTN_SEND_MSG_WIDTH,30,clrBlack,clrLightGray,7,2);

      color clrInit = clrActiveBtn;
      datetime vietnamTime = TimeGMT()+7 * 3600;
      MqlDateTime time_struct;
      TimeToStruct(vietnamTime,time_struct);
      string today = (string)time_struct.year+(string)time_struct.mon+(string)time_struct.day;
      string RESET_DAY = (string)GetGlobalVariable("RESET_DAY");
      if(RESET_DAY==today)
         clrInit = clrLightGray;
      createButton(BtnInitStocH4ByW1Ma10,"Init",BTN_SEND_MSG_WIDTH+10,5,35,20,clrBlack,clrInit,7,2);

      //--------------------------------------------------------------------------------------------
      int auto_exit = (int)GetGlobalVariable(BtnOptionAutoExit+symbol);
      createButton(BtnOptionAutoExit,"(Ex)HeiH1+(8020)H4H1",5,75,BTN_SEND_MSG_WIDTH,20,clrBlack,auto_exit==AUTO_TRADE_ON?clrActiveBtn:clrLightGray,6,3);
     }
//--------------------------------------------------------------------------------------------
   double intPeriod = (int)GetGlobalVariable(BtnOptionPeriod);
   if(intPeriod==-1)
     {
      intPeriod = PERIOD_D1;
      GlobalVariableSet(BtnOptionPeriod,(double)intPeriod);
     }
   createButton(BtnOptionPeriod+"_MN1","MO",5, 5,30,19,clrBlack,intPeriod==PERIOD_MN1? clrActiveBtn:clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnOptionPeriod+"_W1", "W1",5,25,30,19,clrBlack,intPeriod==PERIOD_W1?clrActiveBtn:clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnOptionPeriod+"_D1", "D1",5,45,30,19,clrBlack,intPeriod==PERIOD_D1?clrActiveBtn:clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnOptionPeriod+"_H4", "H4",5,65,30,19,clrBlack,intPeriod==PERIOD_H4?clrActiveBtn:clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnOptionPeriod+"_H1", "H1",5,85,30,19,clrBlack,intPeriod==PERIOD_H1?clrActiveBtn:clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
//--------------------------------------------------------------------------------------------
   createButton("Ma10", "Ma10",x_max-65*4,y_row_2,63,20,clrBlack,clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"Ma10W1",  "W1 "+getShortName(arrHeiken_W1[0].trend_by_ma10)+":"+(string)arrHeiken_W1[0].count_ma10, x_max-65*3,y_row_2,63,20,trend_by_ma10_w1==TREND_BUY?clrBlue:clrRed,clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"Ma10D1",  "D " +getShortName(arrHeiken_D1[0].trend_by_ma10)+"" +(string)arrHeiken_D1[0].count_ma10, x_max-65*2,y_row_2,63,20,trend_by_ma10_d1==TREND_BUY?clrBlue:clrRed,clrWhite,11,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"Ma10H4",  "H4 "+getShortName(arrHeiken_H4[0].trend_by_ma10)+":"+(string)arrHeiken_H4[0].count_ma10, x_max-65*1,y_row_2,63,20,trend_by_ma10_h4==TREND_BUY?clrBlue:clrRed,clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"Ma10H1",  "H1 "+getShortName(arrHeiken_H1[0].trend_by_ma10)+":"+(string)arrHeiken_H1[0].count_ma10, x_max-65*0,y_row_2,63,20,trend_by_ma10_h1==TREND_BUY?clrBlue:clrRed,clrWhite,7,SUB_WINDOW_BTN_CONTROLS);

   createButton("Heiken","Heiken",                                                                                         x_max-65*4,y_row_3,63,20,clrBlack,clrWhite,                                                      7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"HeiW1[0]","W1 "+getShortName(arrHeiken_W1[0].trend_heiken)+":"+(string)arrHeiken_W1[0].count_heiken,x_max-65*3,y_row_3,63,20,arrHeiken_W1[0].trend_heiken==TREND_BUY?clrBlue:clrRed,clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"HeiD1[0]","D " +getShortName(arrHeiken_D1[0].trend_heiken)      +(string)arrHeiken_D1[0].count_heiken,x_max-65*2,y_row_3,63,20,arrHeiken_D1[0].trend_heiken==TREND_BUY?clrBlue:clrRed,clrWhite,11,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"HeiH4[0]","H4 "+getShortName(arrHeiken_H4[0].trend_heiken)+":"+(string)arrHeiken_H4[0].count_heiken,x_max-65*1,y_row_3,63,20,arrHeiken_H4[0].trend_heiken==TREND_BUY?clrBlue:clrRed,clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"HeiH1[0]","H1 "+getShortName(arrHeiken_H1[0].trend_heiken)+":"+(string)arrHeiken_H1[0].count_heiken,x_max-65*0,y_row_3,63,20,arrHeiken_H1[0].trend_heiken==TREND_BUY?clrBlue:clrRed,clrWhite,7,SUB_WINDOW_BTN_CONTROLS);

   createButton("MacdH4",    "Macd",x_max-65*4,y_row_4,63,20,clrBlack,clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"Mac.Sig.W1","W1 "+trend_vector_histogram_w1,x_max-65*3,y_row_4,63,20,getColorByTrend(trend_vector_histogram_w1,clrBlack), clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"Mac.Sig.D1","D1 "+trend_mac_vs_signal_d1,   x_max-65*2,y_row_4,63,20,getColorByTrend(trend_mac_vs_signal_d1,clrBlack),    clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"Mac.Sig.H4","H4 "+trend_mac_vs_signal_h4,   x_max-65*1,y_row_4,63,20,getColorByTrend(trend_mac_vs_signal_h4,clrBlack),    clrWhite,7,SUB_WINDOW_BTN_CONTROLS);
   createButton(BtnTrend+"Mac.Sig.H1","H1 "+trend_mac_vs_signal_h1,   x_max-65*0,y_row_4,63,20,getColorByTrend(trend_mac_vs_signal_h1,clrBlack),    clrWhite,7,SUB_WINDOW_BTN_CONTROLS);

   createButton(BtnCloseAllTicket,"(All) X("+(string)OrdersTotal()+"L): "+get_acc_profit_percent(),5,50,BTN_SEND_MSG_WIDTH,20,clrBlack,clrWhite,6);

   int y2 = (int)(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,2));
   createButton(BtnTrend+"Stoc.D1"," D1 "+get_trend_allow_trade_now_by_stoc(symbol,PERIOD_D1,false),x_max-200,10,              80,20,clrBlack,clrWhite,7,2);
   createButton(BtnTrend+"Stoc.H4"," H4 "+get_trend_allow_trade_now_by_stoc(symbol,PERIOD_H4,false),x_max-200,(int)(y2/2)-10,80,20,clrBlack,clrWhite,7,2);
   createButton(BtnTrend+"Stoc.H1"," H1 "+get_trend_allow_trade_now_by_stoc(symbol,PERIOD_H1,false),x_max-200,(int)(y2)  -30,80,20,clrBlack,clrWhite,7,2);

   create_trend_line("Toc_21_7_7",iTime(symbol,PERIOD_W1,1),50.0,TimeCurrent(),50.0,clrBlack,STYLE_DASHDOTDOT,1,true,true,true,true,2);
   create_trend_line("Toc_35_7_7",iTime(symbol,PERIOD_W1,1),50.0,TimeCurrent(),50.0,clrBlack,STYLE_DASHDOTDOT,1,true,true,true,true,3);

   if(TF != "??")
     {
      ObjectSetString(0,BtnTrend+"Ma10"+TF,OBJPROP_FONT,"Arial Bold");
      ObjectSetString(0,BtnTrend+"Hei"+TF+"[0]",OBJPROP_FONT,"Arial Bold");
      ObjectSetString(0,BtnTrend+"Mac.Sig."+TF,OBJPROP_FONT,"Arial Bold");
      ObjectSetString(0,BtnTrend+"Toc"+TF,OBJPROP_FONT,"Arial Bold");
      ObjectSetString(0,BtnTrend+"Sto."+TF,OBJPROP_FONT,"Arial Bold");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   if(is_main_control_screen()==false)
      return "";

   string symbol = Symbol();
   double profit_today = CalculateTodayProfitLoss();
   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double PL=EQUITY-BALANCE;
   string percent = to_percent(profit_today);

   double AMP_DCA = get_AMP_DCA(symbol,PERIOD_D1);
   double risk_1L = Risk_1L_By_Account_Balance();

   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double price = (bid+ask)/2;
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   double amp_w1,amp_d1,amp_h4,amp_grid_L100;
   GetAmpAvgL15(symbol,amp_w1,amp_d1,amp_h4,amp_grid_L100);

   double import_price = (price*25500*(37.5/31.1035)/1000000);

   string cur_timeframe = get_current_timeframe_to_string();
//--- Account number
   long login=AccountInfoInteger(ACCOUNT_LOGIN);
   string str_comments = AccountInfoString(ACCOUNT_NAME)+":"+(string)login+" "+get_vntime();//+"("+cur_timeframe+") ";
   str_comments += "    Closed(today): "+format_double_to_string(profit_today,2)+"$"
                   +" ("+format_double_to_string(profit_today*25500/1000000,2)+" tr)"+percent+"/"+(string) count_closed_today+"L";
   str_comments += "    Opening: "+(string)(int)PL+"$"+to_percent(PL)
                   +" ("+format_double_to_string(PL*25500/1000000,2)+" tr)";
   str_comments += "    Risk: "+get_profit_percent(risk_1L)+"/(AmW)";
//str_comments += "    Fixed_SL: "+get_profit_percent(fixSL);
   str_comments += "    Min: "+(string)Risk_Min()+"$";
   double depreciation=MathAbs(ask-bid)*5;
   str_comments += "    ^v: " + format_double_to_string(depreciation,digits) + "$";

   if(is_same_symbol(Symbol(),"XAU"))
      str_comments += "    VND: "+format_double_to_string(import_price*1.09,2)+"~"+format_double_to_string(import_price*1.119,2)+" tr";

   str_comments += "    Amp(W1): "+format_double_to_string(amp_w1,digits)+"$";
   str_comments += "    Amp(D1): "+format_double_to_string(amp_d1,digits)+"$    W1="+DoubleToString(amp_w1/amp_d1,2)+" L.D1";
   str_comments += "    Amp(H4): "+format_double_to_string(amp_h4,digits)+"$    W1="+DoubleToString(amp_w1/amp_h4,2)+" L.H4";

   if(Period()==PERIOD_W1)
     {
      double avg_candle_w1 = calc_average_candle_height(PERIOD_W1,symbol,21);
      double avg_candle_d1 = calc_average_candle_height(PERIOD_D1,symbol,50);

      string str_avg_21w = "    Avg21(W1): "+format_double_to_string(avg_candle_w1,digits)+"    "+"("+(string)(NormalizeDouble(avg_candle_w1/amp_w1,2)*100)+"%)";
      string str_avg_50d = "    Avg50(D1): "+format_double_to_string(avg_candle_d1,digits)+"    "+"("+(string)(NormalizeDouble(avg_candle_d1/amp_d1,2)*100)+"%)";

      str_comments += str_avg_21w+str_avg_50d;
      printf(symbol+"    "+str_avg_21w+"    "+str_avg_50d);
     }

   if(is_time_enter_the_market()==false)
      str_comments += "    MarketClosed";
   else
      str_comments += "    MarketOpening";

   str_comments += "    CloseDay"+get_day_stop_trade(symbol,false);

   str_comments += "\n\n"; //+(string)get_vn_date()


   return str_comments;
  }
//+------------------------------------------------------------------+
