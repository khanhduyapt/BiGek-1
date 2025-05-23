//+------------------------------------------------------------------+
//|                                                XAUUSD-Amp10$.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
string VER = "V2599";
//-----------------------------------------------------------------------------
int START_EXIT_L = 2;
double INIT_VOLUME = 0.01;
string BOT_SHORT_NM = "(A3E2)";      // "AmW" : amp_w1, "AmD" : amp_d1, "AmH" : amp_h4, "AmS" : amp_h4/2, "Am10": 10Gia, "Am7": 7Gia
double FIXED_SL_BY_PERCENT = 90.00;  // SYMBOL nao LOSS -30% thi dong toan bo lenh cua no
double RISK_BY_PERCENT     = 0.025;  // RISK_BY_PERCENT = 0.25% với FIBO_2=2.0 -> SL ở L.7 thì -15.75% tài khoản.
//   L1     L2       L3       L4       L5       L6       L7
//0.25%  -0.25%   -0.75%   -1.75%   -3.75%   -7.75%   -15.75%
//-----------------------------------------------------------------------------
string telegram_url="https://api.telegram.org";
//-----------------------------------------------------------------------------
#define BtnAutoBuy       "BtnAutoBuy_"
#define BtnAutoSel       "BtnAutoSel_"
#define BtnTrend         "BtnTrend_"
#define BtnClearChart    "BtnClearChart"
#define BtnNewCycleBuy   "NewCycleBuy"
#define BtnNewCycleSel   "NewCycleSel"
#define BtnTpPositiveBuy "BtnTpPositiveBuy"
#define BtnTpPositiveSel "BtnTpPositiveSel"
//-----------------------------------------------------------------------------
#define CYCLE_BUY   "CYCLE_BUY"
#define CYCLE_SEL   "CYCLE_SEL"
#define MAX_L_BUY   "MAX_L_BUY"
#define MAX_L_SEL   "MAX_L_SEL"
#define MAX_TP_BUY  "MAX_TP_BUY"
#define MAX_TP_SEL  "MAX_TP_SEL"
#define MAX_DD_BUY  "MAX_DD_BUY"
#define MAX_DD_SEL  "MAX_DD_SEL"
#define MAX_AMP_BUY "MAX_AMP_BUY"
#define MAX_AMP_SEL "MAX_AMP_SEL"
//-----------------------------------------------------------------------------
string TREND_BUY = "BUY";
string TREND_SEL = "SEL";
int count_closed_today = 0;
double MAXIMUM_DOUBLE = 999999999;
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
const int AUTO_TRADE_ON = 1;
const int AUTO_TRADE_OFF = 0;
datetime TIME_OF_ONE_H1_CANDLE = 3600;
datetime TIME_OF_ONE_H4_CANDLE = 14400;
datetime TIME_OF_ONE_D1_CANDLE = 86400;
datetime TIME_OF_ONE_W1_CANDLE = 604800;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   string symbol = Symbol();
   DeleteAllObjectsByName(BOT_SHORT_NM);


   if(IsTesting())
     {
      GlobalVariableSet(MAX_L_BUY,   0);
      GlobalVariableSet(MAX_DD_BUY,  0);
      GlobalVariableSet(MAX_AMP_BUY, 0);
      GlobalVariableSet(MAX_AMP_SEL, 0);
      GlobalVariableSet(MAX_L_SEL,   0);
      GlobalVariableSet(MAX_DD_SEL,  0);
      GlobalVariableSet(MAX_TP_BUY,  0);
      GlobalVariableSet(MAX_TP_SEL,  0);
      GlobalVariableSet(symbol, (double)AUTO_TRADE_ON);
     }

   Comment(GetComments());

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string symbol = Symbol();
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   create_trend_line("cur_price"
                     , TimeCurrent()-TIME_OF_ONE_W1_CANDLE, cur_price
                     , TimeCurrent()+TIME_OF_ONE_W1_CANDLE, cur_price
                     , clrFireBrick, STYLE_DOT, 1, true, true);

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(vietnamTime, time_struct);
//------------------------------------------------------
   bool allow_re_check_after_1m = false;
   datetime cur_time = TimeCurrent();
   int cur_minute = TimeMinute(cur_time);
   int cur_seconds = TimeSeconds(cur_time);
   int pre_check_minute = -1;
   int pre_check_seconds = -1;
   if(GlobalVariableCheck("timer_one_minu"))
      pre_check_minute = (int)GlobalVariableGet("timer_one_minu");
   if(GlobalVariableCheck("timer_one_sec"))
      pre_check_seconds = (int)GlobalVariableGet("timer_one_sec");
   GlobalVariableSet("timer_one_minu", cur_minute);
   GlobalVariableSet("timer_one_sec", cur_seconds);

   if(pre_check_minute != cur_minute || (cur_seconds / 10 != pre_check_seconds / 10))
     {
      // Thực hiện xử lý mỗi 10 giây
      OpenTrade(symbol);
      Comment(GetComments());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade(string symbol)
  {
   bool IS_CYCLE_BUY = false;
   bool IS_CYCLE_SEL = false;
   string tf = get_time_frame_name(PERIOD_H4);
   string trend_zero_h4 = get_trend_by_macd_vs_zero(symbol, PERIOD_H4);
//string trend_zero_h1 = get_trend_by_macd_vs_zero(symbol, PERIOD_H1);
//string trend_21_h1 = get_trend_by_stoc2(symbol,PERIOD_H1,21,7,7,0);
//string trend_ma10d = get_trend_by_ma(symbol,PERIOD_D1,10,1);
//string trend_hei_d = get_trend_by_heiken(symbol,PERIOD_D1,0);

   if(IsTesting())
     {
      GlobalVariableSet(BtnAutoBuy+symbol,AUTO_TRADE_ON);
      GlobalVariableSet(BtnAutoSel+symbol,AUTO_TRADE_ON);
     }

   if(is_same_symbol(trend_zero_h4, TREND_BUY))
      IS_CYCLE_BUY = true;

   if(is_same_symbol(trend_zero_h4, TREND_SEL))
      IS_CYCLE_SEL = true;

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);
   double close_h4_c01 = iOpen(symbol,PERIOD_H4,0);
   string cur_candle_h4 = cur_price>close_h4_c01?TREND_BUY:TREND_SEL;

//CandleData arrHeiken_M5[];
//get_arr_heiken(symbol, PERIOD_M5, arrHeiken_M5, 15, true);
//string trend_21m5 = get_trend_by_stoc2(symbol,PERIOD_M5,21,7,7,0);

   bool AUTO_ENTRY = GetGlobalVariable(symbol) == AUTO_TRADE_ON;
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
   double AMP_TP = get_AMP_DCA(symbol, PERIOD_H1);
   double AMP_DC = get_AMP_DCA(symbol, PERIOD_H4);
   int slippage = (int)MathAbs(ask-bid);

   double risk_min = Risk_Min();
   double risk_1L = Risk_1L_By_Account_Balance();
   bool is_cur_tab = is_same_symbol(symbol, Symbol());

   int count_buy = 0, count_sel = 0;
   string str_vol_buy = "", str_vol_sel = "";
   string last_comment_buy = "", last_comment_sel = "";
   double vol_buy = 0, vol_sel = 0, profit_buy = 0, profit_sel = 0;
   double global_min_entry_buy = 0, global_max_entry_buy = 0;
   double global_min_entry_sel = 0, global_max_entry_sel = 0;
   double positive_profit_buy = 0, positive_profit_sel = 0;
   datetime last_time_buy = 0, last_time_sel = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            string comment = OrderComment();
            double temp_profit = OrderProfit() + OrderSwap() + OrderCommission();

            if(is_same_symbol(comment, TREND_BUY) && is_same_symbol(comment, BOT_SHORT_NM))
              {
               count_buy += 1;
               vol_buy += OrderLots();
               profit_buy += temp_profit;
               str_vol_buy += DoubleToString(OrderLots(), 2) + " ";
               if(temp_profit > 0)
                  positive_profit_buy += temp_profit;

               if(global_min_entry_buy == 0 || global_min_entry_buy > OrderOpenPrice())
                 {
                  last_time_buy = OrderOpenTime();
                  last_comment_buy = OrderComment();
                  global_min_entry_buy = OrderOpenPrice();
                 }

               if(global_max_entry_buy == 0 || global_max_entry_buy < OrderOpenPrice())
                  global_max_entry_buy =  OrderOpenPrice();
              }

            if(is_same_symbol(comment, TREND_SEL) && is_same_symbol(comment, BOT_SHORT_NM))
              {
               count_sel += 1;
               vol_sel += OrderLots();
               profit_sel += temp_profit;
               str_vol_sel += DoubleToString(OrderLots(), 2) + " ";
               if(temp_profit > 0)
                  positive_profit_sel += temp_profit;

               if(global_min_entry_sel == 0 || global_min_entry_sel > OrderOpenPrice())
                  global_min_entry_sel = OrderOpenPrice();

               if(global_max_entry_sel == 0 || global_max_entry_sel < OrderOpenPrice())
                 {
                  last_time_sel = OrderOpenTime();
                  last_comment_sel = OrderComment();
                  global_max_entry_sel = OrderOpenPrice();
                 }
              }
           }
     {
      if(count_buy > (int)GetGlobalVariable(MAX_L_BUY))
         GlobalVariableSet(MAX_L_BUY, (double)count_buy);
      if(profit_buy < GetGlobalVariable(MAX_DD_BUY))
         GlobalVariableSet(MAX_DD_BUY, profit_buy);

      if(MathAbs(global_max_entry_buy - global_min_entry_buy) > GetGlobalVariable(MAX_AMP_BUY))
         GlobalVariableSet(MAX_AMP_BUY, MathAbs(global_max_entry_buy - global_min_entry_buy));
      if(MathAbs(global_max_entry_sel - global_min_entry_sel) > GetGlobalVariable(MAX_AMP_SEL))
         GlobalVariableSet(MAX_AMP_SEL, MathAbs(global_max_entry_sel - global_min_entry_sel));

      if(count_sel > (int)GetGlobalVariable(MAX_L_SEL))
         GlobalVariableSet(MAX_L_SEL, (double)count_sel);
      if(profit_sel < GetGlobalVariable(MAX_DD_SEL))
         GlobalVariableSet(MAX_DD_SEL, profit_sel);

      if(profit_buy > GetGlobalVariable(MAX_TP_BUY))
         GlobalVariableSet(MAX_TP_BUY, profit_buy);
      if(profit_sel > GetGlobalVariable(MAX_TP_SEL))
         GlobalVariableSet(MAX_TP_SEL, profit_sel);
     }

   if(is_cur_tab)
     {
      DeleteArrowObjects();
      ObjectDelete(0, "TP.BUY");
      ObjectDelete(0, "TP.SEL");
      ObjectDelete(0, BtnTpPositiveBuy);
      ObjectDelete(0, BtnTpPositiveSel);

      double draw_buy = global_max_entry_buy;
      if(draw_buy > 0)
        {
         for(int i=0; i< 5; i++)
            create_trend_line(BOT_SHORT_NM+"DCA.B." + (string)(i+1) + "/" + (string)START_EXIT_L
                              , TimeCurrent()-TIME_OF_ONE_H4_CANDLE*i
                              , draw_buy - AMP_DC*i
                              , TimeCurrent()+TIME_OF_ONE_H4_CANDLE*i
                              , draw_buy - AMP_DC*i
                              , (i+1)<START_EXIT_L?clrBlack:clrBlue
                              , (i+1==5)||(i+1==START_EXIT_L)?STYLE_SOLID:STYLE_DOT
                             );
        }

      double draw_sel = global_min_entry_sel;
      if(draw_sel > 0)
        {
         for(int i=0; i< 5; i++)
            create_trend_line(BOT_SHORT_NM+"DCA.S." + (string)(i+1) + "/" + (string)START_EXIT_L
                              , TimeCurrent()-TIME_OF_ONE_H4_CANDLE*i
                              , draw_sel + AMP_DC*i
                              , TimeCurrent()+TIME_OF_ONE_H4_CANDLE*i
                              , draw_sel + AMP_DC*i
                              , (i+1)<START_EXIT_L?clrBlack:clrRed
                              , (i+1==5)||(i+1==START_EXIT_L)?STYLE_SOLID:STYLE_DOT
                             );
        }

      int BtnWidth = 250;
      int x_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS))-BtnWidth -10;
      int y_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));

      createButton(BtnClearChart, "Clear Chart", 5, y_ref_btn - 25, 150, 20, clrBlack, clrWhite, 7);

      string strCountB = "";
      if(count_buy > 0)
         strCountB += " L." + (string)count_buy + "B";
      strCountB += (count_buy >= START_EXIT_L? " Exiting":"");

      string strCountS = "";
      if(count_sel > 0)
         strCountS = " L." + (string)count_sel + "S";
      strCountS += (count_sel >= START_EXIT_L? " Exiting":"");

      string stoc_main = "(" + format_double_to_string(AMP_TP,digits) + "/" + format_double_to_string(AMP_DC,digits) + ")";

      double step_buy = 0.01;
      if(cur_price>0&&global_max_entry_buy>0)
         step_buy = NormalizeDouble(MathAbs(cur_price-global_max_entry_buy)/AMP_DC, 2);

      double step_sel = 0.01;
      if(cur_price>0&&global_min_entry_sel>0)
         step_sel = NormalizeDouble(MathAbs(cur_price-global_min_entry_sel)/AMP_DC, 2);

      color clrNewCycleColorBuy = IS_CYCLE_BUY ? clrLightGreen : clrLightGray;
      string lableBuy = tf + " BUY " + stoc_main + strCountB + " r" + format_double_to_string(step_buy,2);

      createButton(BtnAutoBuy, "Auto Buy", x_ref_btn+150, y_ref_btn-50,100, 20, clrBlack, GlobalVariableGet(BtnAutoBuy+symbol)==AUTO_TRADE_ON?clrLightGreen:clrLightGray);
      createButton(BtnNewCycleBuy, lableBuy, x_ref_btn, y_ref_btn-80, BtnWidth, 20, clrBlack, clrNewCycleColorBuy);

      if(count_buy > 0)
         createButton(BtnTpPositiveBuy, last_comment_buy + " " + DoubleToString(vol_buy, 2)
                      + " Total:" + DoubleToString(profit_buy, 2) + " $"
                      , x_ref_btn, y_ref_btn-110, BtnWidth, 20, profit_buy>0?clrBlue:clrRed, clrWhite, 7);

      color clrNewCycleColorSel = IS_CYCLE_SEL ? clrMistyRose : clrLightGray;
      string lableSel = tf + " SEL " + stoc_main + strCountS + " r"+ format_double_to_string(step_sel,2);
      createButton(BtnNewCycleSel, lableSel, x_ref_btn, 80, BtnWidth, 20, clrBlack, clrNewCycleColorSel);
      createButton(BtnAutoSel, "Auto Sell", x_ref_btn+150, 50,100, 20, clrBlack, GlobalVariableGet(BtnAutoSel+symbol)==AUTO_TRADE_ON?clrLightGreen:clrLightGray);

      if(count_sel > 0)
         createButton(BtnTpPositiveSel, last_comment_sel + " " + DoubleToString(vol_sel, 2)
                      + " Total:" + DoubleToString(profit_sel, 2) + " $"
                      , x_ref_btn, 110, BtnWidth, 20, profit_sel>0?clrBlue:clrRed, clrWhite, 7);
     }
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
   if(AUTO_ENTRY)
     {
      if(IS_CYCLE_BUY && (count_buy == 0)
         && is_stoc_allow_dca(symbol,count_buy,TREND_BUY))
        {
         count_buy = 1;
         string comment_buy = create_comment(BOT_SHORT_NM, TREND_BUY, count_buy);
         double vol_add = count_sel>0?INIT_VOLUME:0;

         bool opened_buy = Open_Position(symbol,OP_BUY,INIT_VOLUME+vol_add,0.0,0.0,comment_buy);
         return;
        }

      if(IS_CYCLE_SEL && (count_sel == 0)
         && is_stoc_allow_dca(symbol,count_buy,TREND_SEL))
        {
         count_sel = 1;
         string comment_sel = create_comment(BOT_SHORT_NM, TREND_SEL, 1);
         double vol_add = count_buy>0?INIT_VOLUME:0;

         bool opened_sel = Open_Position(symbol,OP_SELL,INIT_VOLUME+vol_add,0.0,0.0,comment_sel);
         return;
        }
     }
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
   if(count_buy > 0)
     {
      // DCA
      if(AUTO_ENTRY && IS_CYCLE_BUY && (global_min_entry_buy>0) && (global_min_entry_buy-AMP_DC>ask)
         && is_same_symbol(cur_candle_h4,TREND_BUY)
         && is_stoc_allow_dca(symbol,count_buy,TREND_BUY))
        {
         count_buy += 1;
         string comment_buy = create_comment(BOT_SHORT_NM, TREND_BUY, count_buy);
         double vol = calc_volume_by_amp(symbol,AMP_TP,MathMax(MathAbs(profit_buy),risk_1L));

         bool opened_buy = Open_Position(symbol, OP_BUY, vol, 0.0, 0.0, comment_buy);
         if(opened_buy)
            return;
        }

      if(profit_buy > risk_min)
        {
         // TP 1L
         if((global_min_entry_buy+AMP_TP<ask) && (profit_buy>risk_1L))
           {
            ClosePosition(symbol, OP_BUY);
            DeleteAllObjectsByName(BOT_SHORT_NM);
            return;
           }

         // Close Exit
         if((count_buy>=START_EXIT_L) || (count_buy>1 && IS_CYCLE_BUY==false))
           {
            ClosePosition(symbol, OP_BUY);
            DeleteAllObjectsByName(BOT_SHORT_NM);
            return;
           }
        }
     }
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
   if(count_sel > 0)
     {
      // DCA
      if(AUTO_ENTRY && IS_CYCLE_SEL && (global_max_entry_sel>0) && (global_max_entry_sel+AMP_DC<bid)
         && is_same_symbol(cur_candle_h4,TREND_SEL)
         && is_stoc_allow_dca(symbol,count_buy,TREND_SEL))
        {
         count_sel += 1;
         string comment_sel = create_comment(BOT_SHORT_NM, TREND_SEL, count_sel);
         double vol = calc_volume_by_amp(symbol,AMP_TP,MathMax(MathAbs(profit_sel), risk_1L));

         bool opened_sel = Open_Position(symbol,OP_SELL,vol,0.0,0.0,comment_sel);
         if(opened_sel)
            return;
        }

      if(profit_sel > risk_min)
        {
         // TP 1L
         if((global_max_entry_sel-AMP_TP>bid) && (profit_sel>risk_1L))
           {
            ClosePosition(symbol, OP_SELL);
            DeleteAllObjectsByName(BOT_SHORT_NM);
            return;
           }

         // Close Exit
         if((count_sel>=START_EXIT_L) || (count_sel>1 && IS_CYCLE_SEL==false))
           {
            ClosePosition(symbol, OP_SELL);
            DeleteAllObjectsByName(BOT_SHORT_NM);
            return;
           }
        }
     }
//---------------------------------------------------------------------------------------------------------
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_AMP_DCA(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
//if(is_same_symbol(symbol, "XAU"))
//   return GLOBAL_AMP_TRADE;

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);

   if(TIMEFRAME == PERIOD_W1)
      return NormalizeDouble(amp_w1, digits);

   if(TIMEFRAME == PERIOD_D1)
      return NormalizeDouble(amp_d1, digits);

   if(TIMEFRAME == PERIOD_H4)
      return NormalizeDouble(amp_h4, digits);

   if(TIMEFRAME == PERIOD_H1)
      return NormalizeDouble(amp_h4/2, digits);

   return amp_w1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_stoc_allow_dca(string symbol, int trade_count, string TREND)
  {
   if(trade_count==0)
      return true;

   if(trade_count==1)
      return is_same_symbol(get_trend_allow_trade_now_by_stoc(symbol,PERIOD_M5), TREND);

   if(trade_count==2)
      return is_same_symbol(get_trend_allow_trade_now_by_stoc(symbol,PERIOD_H1), TREND);

   if(trade_count>2)
      return is_same_symbol(get_trend_allow_trade_now_by_stoc(symbol,PERIOD_H4), TREND);

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsLessThan15MinutesToCloseH4(string symbol)
  {
// Thời gian hiện tại
   datetime now = TimeCurrent();

// Tính thời gian đóng nến H4 hiện tại (nến H4 có chu kỳ là 4 giờ = 14400 giây)
   datetime close_candle_time = iTime(symbol, PERIOD_H4, 0) + 14400; // 14400 = 4 * 60 * 60 giây (4 giờ)

// Tính khoảng thời gian còn lại đến khi nến H4 đóng
   int seconds_left = (int)close_candle_time - (int)now;

// Kiểm tra nếu còn dưới 15 phút (15 * 60 = 900 giây)
   if(seconds_left <= 900)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsWaited15Minutes(string symbol, datetime last_order_time)
  {
   datetime now = TimeCurrent();
   int seconds_left = (int)now - (int)last_order_time;

   if(seconds_left >= 900)
      //Đã chờ 15 phút (15 * 60 = 900 giây)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CanOpenDCA(string symbol, ENUM_TIMEFRAMES PERIOD_WAIT, datetime last_order_time)
  {
   if(PERIOD_WAIT == PERIOD_M15)
      return IsWaited15Minutes(symbol,last_order_time);

   MqlDateTime cur_time;
   TimeToStruct(iTime(symbol, PERIOD_WAIT, 0), cur_time);

   MqlDateTime odr_time;
   TimeToStruct(last_order_time, odr_time);
   int hround = 4;
   if(PERIOD_WAIT==PERIOD_H1)
      hround = 1;

   string last_order_time_str = (string)odr_time.year + StringFormat("%02d", odr_time.mon) +
                                StringFormat("%02d", odr_time.day) +
                                StringFormat("%02d", (odr_time.hour/hround)*hround);

   string current_h1_time_str = (string)cur_time.year +
                                StringFormat("%02d", cur_time.mon) +
                                StringFormat("%02d", cur_time.day) +
                                StringFormat("%02d", cur_time.hour);;

   if(last_order_time_str != current_h1_time_str)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,       // event ID
                  const long&   lparam,   // long type event parameter
                  const double& dparam,   // double type event parameter
                  const string& sparam    // string type event parameter
                 )
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      string symbol = Symbol();

      if(sparam == BtnClearChart)
        {
         for(int i = 0; i < 10; i++)
            DeleteAllObjects();

         OnInit();
        }

      if(sparam == BtnAutoBuy || sparam == BtnAutoSel)
        {
         bool AUTO_ENTRY = GetGlobalVariable(sparam+symbol) == AUTO_TRADE_ON;
         string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         string msg = sparam + symbol + " " + (string)AUTO_ENTRY + " -> " + (string)(!AUTO_ENTRY);
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            if(GlobalVariableGet(sparam+symbol)==AUTO_TRADE_ON)
               GlobalVariableSet(sparam+symbol,AUTO_TRADE_OFF);

            if(GlobalVariableGet(sparam+symbol)==AUTO_TRADE_OFF)
               GlobalVariableSet(sparam+symbol,AUTO_TRADE_ON);

            OpenTrade(symbol);
           }
        }

      if(sparam == BtnNewCycleBuy || sparam == BtnNewCycleSel)
        {
         string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         string msg = sparam + " " + buttonLabel;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");

            double amp_w1, amp_d1, amp_h4, amp_grid_L100;
            GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);
            double risk_1L = Risk_1L_By_Account_Balance();

            string trend = sparam == BtnNewCycleBuy ? TREND_BUY : sparam == BtnNewCycleSel ? TREND_SEL : "";
            int OP_TYPE = sparam == BtnNewCycleBuy ? OP_BUY : sparam == BtnNewCycleSel ? OP_SELL : -1;

            string comment = create_comment("(M.K)" + BOT_SHORT_NM, trend, 1);
            double vol = INIT_VOLUME;

            bool opened = Open_Position(symbol, OP_TYPE, vol, 0.0, 0.0, comment);
            if(opened)
               printf(msg);
           }
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnTpPositiveBuy || sparam == BtnTpPositiveSel)
        {
         string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         string msg = sparam + "  " + Symbol() + "  " + buttonLabel;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");

            if(sparam == BtnTpPositiveBuy)
               ClosePositivePosition(Symbol(), OP_BUY);

            if(sparam == BtnTpPositiveSel)
               ClosePositivePosition(Symbol(), OP_SELL);

            for(int i = 0; i < 10; i++)
               DeleteAllObjects();

            OnInit();
           }
        }
      //-----------------------------------------------------------------------
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Position(string symbol, int OP_TYPE, double volume, double sl, double tp, string comment)
  {
   bool has_commets = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && is_same_symbol(OrderComment(), comment))
            has_commets = true;

   if(has_commets)
     {
      Alert("Really exist: " + comment + "    " + symbol);
      return false;
     }

   int nextticket= 0, demm = 1;
   while(nextticket<=0 && demm < 5)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int slippage = (int)MathAbs(ask-bid);
      double price = NormalizeDouble((bid + ask)/2, Digits);
      if(OP_TYPE == OP_BUY)
         price = ask;
      if(OP_TYPE == OP_SELL)
         price = bid;

      string nComment = is_same_symbol(comment, BOT_SHORT_NM)?comment:BOT_SHORT_NM+comment;

      nextticket = OrderSend(symbol, OP_TYPE, volume, price, slippage, sl, tp, nComment, 0, 0, clrBlue);
      if(nextticket > 0)
         return true;

      demm++;
      Sleep(100); //milliseconds
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heiken(string symbol)
  {
   if(is_same_symbol(symbol, Symbol()) == false)
      return;

   int digits = MathMin(5, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));

   datetime time_1w = iTime(symbol, PERIOD_W1, 1) - iTime(symbol, PERIOD_W1, 2);
   datetime time_1d = iTime(symbol, PERIOD_D1, 1) - iTime(symbol, PERIOD_D1, 2);
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_mn1[];
   get_arr_heiken(symbol, PERIOD_MN1, arrHeiken_mn1, 25, true);
   for(int i = 0; i <= 20; i++)
     {
      color clrColorW = clrLightGray;
      if(arrHeiken_mn1[i+1].ma10>0 && arrHeiken_mn1[i].ma10>0)
         create_trend_line("Ma10M_" + append1Zero(i+1) + "_" + append1Zero(i),
                           arrHeiken_mn1[i+1].time, arrHeiken_mn1[i+1].ma10,
                           (i==0?TimeCurrent():arrHeiken_mn1[i].time), arrHeiken_mn1[i].ma10, clrColorW, STYLE_SOLID, 25, false, false, true, true);

      if(i == 0)
         create_lable("Ma10M", TimeCurrent(), arrHeiken_mn1[0].ma10, "   M " + format_double_to_string(NormalizeDouble(arrHeiken_mn1[0].ma10, digits-1), digits-1));
     }
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_w1[];
   get_arr_heiken(symbol, PERIOD_W1, arrHeiken_w1, 50, true);
   int size_w1 = ArraySize(arrHeiken_w1)-5;
   if(size_w1 > 10)
     {
      double min_ma10w = arrHeiken_w1[0].ma10;
      double max_ma10w = arrHeiken_w1[0].ma10;
      for(int i = 0; i < size_w1; i++)
        {
         if(min_ma10w > arrHeiken_w1[i].ma10)
            min_ma10w = arrHeiken_w1[i].ma10;

         if(max_ma10w < arrHeiken_w1[i].ma10)
            max_ma10w = arrHeiken_w1[i].ma10;
        }
      double amp_5per = (max_ma10w-min_ma10w)/20;
      max_ma10w += amp_5per;
      min_ma10w -= amp_5per;
      double amp_ma10w = (max_ma10w-min_ma10w);

      for(int i = 0; i < size_w1; i++)
        {
         color clrColorW = clrLightGray;
         if(arrHeiken_w1[i+1].ma10>0 && arrHeiken_w1[i].ma10>0)
            create_trend_line("Ma10W_" + append1Zero(i+1) + "_" + append1Zero(i),
                              arrHeiken_w1[i+1].time, arrHeiken_w1[i+1].ma10,
                              (i==0?TimeCurrent():arrHeiken_w1[i].time), arrHeiken_w1[i].ma10, clrColorW, STYLE_SOLID, 20);
         if(i == 0)
            create_lable("Ma10W", TimeCurrent(), arrHeiken_w1[0].ma10, "   W " + format_double_to_string(NormalizeDouble(arrHeiken_w1[0].ma10, digits-1), digits-1));

         int SUB_WINDOW_FOR_STOC_35 = 3;
         color clrMa10w = arrHeiken_w1[i].trend_by_ma10 == TREND_BUY ? clrTeal : clrFireBrick;
         create_trend_line("Ma10W_8020_" + append1Zero(i+1) + "_" + append1Zero(i),
                           arrHeiken_w1[i+1].time
                           , 100*(arrHeiken_w1[i+1].ma10-min_ma10w)/amp_ma10w,
                           (i==0?TimeCurrent():arrHeiken_w1[i].time)
                           , 100*(arrHeiken_w1[i].ma10-min_ma10w)/amp_ma10w
                           , clrMa10w, STYLE_SOLID, 5, false, false, true, true, SUB_WINDOW_FOR_STOC_35);

         if(i == 0)
            create_lable("Ma10W_8020", TimeCurrent(), 100*(arrHeiken_w1[i].ma10-min_ma10w)/amp_ma10w
                         , "   10W " + arrHeiken_w1[i].trend_by_ma10 + " C." + (string)arrHeiken_w1[i].count_ma10
                         , arrHeiken_w1[i].trend_by_ma10, true, 8, true, SUB_WINDOW_FOR_STOC_35);

         string candle_name = "hei_w_" + append1Zero(i);
         datetime time_i2 = arrHeiken_w1[i].time;

         if(Period() > PERIOD_D1 || i == 0)
            continue;

         string trend_w = arrHeiken_w1[i].trend_heiken;

         //double mid = arrHeiken_w1[i].trend_heiken == TREND_BUY ? arrHeiken_w1[i].low : arrHeiken_w1[i].high;
         double mid = (arrHeiken_w1[i].open + arrHeiken_w1[i].close)/2;
         datetime time_i1 = (i == 0) ? time_i2 + time_1w - time_1d : arrHeiken_w1[i-1].time;
         color clrBody = trend_w == TREND_BUY ? clrBlue : trend_w == TREND_SEL ? clrRed : clrNONE;
         color clrColor = trend_w == TREND_BUY ? clrBlue : trend_w == TREND_SEL ? clrRed : clrNONE;

         bool is_fill_body = false;
         if((arrHeiken_w1[i].count_heiken == 7) || (arrHeiken_w1[i].count_heiken == 1))
           {
            clrBody = trend_w == TREND_BUY ? clrLightBlue : clrLightPink;
            //is_fill_body = true;

            create_lable(candle_name + ".No", arrHeiken_w1[i].time, mid, "" + (string)arrHeiken_w1[i].count_heiken, trend_w, true, 15, true);
           }
         else
            create_lable(candle_name + ".No",      arrHeiken_w1[i].time, mid, "   " + (string)arrHeiken_w1[i].count_heiken, trend_w, true, 10, false);

         datetime time_center = ((time_i2+time_i1)/2) - TIME_OF_ONE_H1_CANDLE;
         create_filled_rectangle(candle_name + "_body", time_i2, arrHeiken_w1[i].open, time_i1, arrHeiken_w1[i].close, clrBody, true, is_fill_body, trend_w, 1);
        }
     }
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_d1[];
   get_arr_heiken(symbol, PERIOD_D1, arrHeiken_d1, 250, true);
   int size_d1 = ArraySize(arrHeiken_d1)-5;
   if(size_d1 > 50)
     {
      double min_ma10d = arrHeiken_d1[0].ma10;
      double max_ma10d = arrHeiken_d1[0].ma10;

      for(int i = 0; i < size_d1; i++)
        {
         if(min_ma10d > arrHeiken_d1[i].ma10)
            min_ma10d = arrHeiken_d1[i].ma10;

         if(max_ma10d < arrHeiken_d1[i].ma10)
            max_ma10d = arrHeiken_d1[i].ma10;
        }
      double amp_5per = (max_ma10d-min_ma10d)/20;
      max_ma10d += amp_5per;
      min_ma10d -= amp_5per;
      double amp_ma10d = (max_ma10d-min_ma10d);


      for(int i = 0; i < size_d1; i++)
        {
         color clrColorD = clrLightGray;
         if(arrHeiken_d1[i+1].ma10>0 && arrHeiken_d1[i].ma10>0)
            create_trend_line("Ma10D_" + append1Zero(i+1) + "_" + append1Zero(i),
                              arrHeiken_d1[i+1].time, arrHeiken_d1[i+1].ma10,
                              (i==0?TimeCurrent():arrHeiken_d1[i].time), arrHeiken_d1[i].ma10, clrColorD, STYLE_SOLID, 15);

         if(i == 0)
            create_lable("Ma10D", TimeCurrent(), arrHeiken_d1[0].ma10, "   D " + format_double_to_string(NormalizeDouble(arrHeiken_d1[0].ma10, digits-1), digits-1));


         int SUB_WINDOW_FOR_STOC_21 = 2;
         color clrMa10d = arrHeiken_d1[i].trend_by_ma10 == TREND_BUY ? clrTeal : clrFireBrick;
         create_trend_line("Ma10D_8020_" + append1Zero(i+1) + "_" + append1Zero(i),
                           arrHeiken_d1[i+1].time
                           , 100*(arrHeiken_d1[i+1].ma10-min_ma10d)/amp_ma10d,
                           (i==0?TimeCurrent():arrHeiken_d1[i].time)
                           , 100*(arrHeiken_d1[i].ma10-min_ma10d)/amp_ma10d
                           , clrMa10d, STYLE_SOLID, 5, false, false, true, true, SUB_WINDOW_FOR_STOC_21);

         if(i == 0)
            create_lable("Ma10D_8020", TimeCurrent(), 100*(arrHeiken_d1[i].ma10-min_ma10d)/amp_ma10d
                         , "   10D " + arrHeiken_d1[i].trend_by_ma10 + " C." + (string)arrHeiken_d1[i].count_ma10
                         , arrHeiken_d1[i].trend_by_ma10, true, 8, true, SUB_WINDOW_FOR_STOC_21);



         if(Period() > PERIOD_H4)
            continue;

         string candle_name = "hei_d_" + appendZero100(i);

         CandleData candle_i = arrHeiken_d1[i];
         string sub_name = "_" + (string)(i+1) + "_" + (string)i;
         datetime time_i1;

         double realOpen = iOpen(symbol, PERIOD_D1, i);
         datetime time_i2 = iTime(symbol, PERIOD_D1, i);
         if(i == 0)
            time_i1 = time_i2 + time_1d;
         else
            time_i1 = iTime(symbol, PERIOD_D1, i-1);

         double low = NormalizeDouble(iLow(symbol, PERIOD_D1, i), digits-2);
         double hig = NormalizeDouble(iHigh(symbol, PERIOD_D1, i), digits-2);

         string trend_by_time = arrHeiken_d1[i].trend_heiken;

         color clrColor = trend_by_time == TREND_BUY ? clrLightCyan : trend_by_time == TREND_SEL ? C'235,235,235' : clrNONE;

         create_filled_rectangle(candle_name, time_i2, low, time_i1, hig, clrColor, false);
        }

     }
  }
//+------------------------------------------------------------------+
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
      datetime t, double o, double h, double l, double c,
      string trend_heiken_, int count_heiken_,
      double ma10_, string trend_by_ma10_, int count_ma10_, string trend_vector_ma10_,
      string trend_by_ma05_, string trend_ma3_vs_ma5_, int count_ma3_vs_ma5_,
      string trend_seq_, double ma50_, string trend_ma10vs20_, string trend_ma5vs10_)
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
void draw_line_ma10_8020(string symbol, ENUM_TIMEFRAMES TIMEFRAME, CandleData &arrHeiken_D1[], int sub_window, int width)
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

      string prefix = "Ma10" + get_time_frame_name(TIMEFRAME) + "_8020_" + (string)sub_window;
      for(int i = 0; i < size; i++)
        {
         color clrColorW = clrLightGray;
         color clrMa10 = arrHeiken_D1[i].trend_by_ma10 == TREND_BUY ? clrTeal : clrFireBrick;

         create_trend_line(prefix + append1Zero(i)
                           , i==0?arrHeiken_D1[i].time-TIME_OF_ONE_H4_CANDLE:arrHeiken_D1[i].time
                           , 100*(arrHeiken_D1[i+1].ma10-min_cur)/amp_cur
                           , i==0?TimeCurrent()+TIME_OF_ONE_H1_CANDLE:arrHeiken_D1[i-1].time
                           , 100*(arrHeiken_D1[i].ma10-min_cur)/amp_cur
                           , clrMa10, STYLE_SOLID, width, false, false, true, true, sub_window);

         if(i == 0)
            create_lable(prefix, TimeCurrent(), 100*(arrHeiken_D1[i].ma10-min_cur)/amp_cur
                         , "   10 " + get_time_frame_name(TIMEFRAME) + " " + getShortName(arrHeiken_D1[i].trend_by_ma10) + (string)arrHeiken_D1[i].count_ma10
                         , arrHeiken_D1[i].trend_by_ma10, true, 8, false, sub_window);

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrendlineValueAtCurrentTime(string trendlineName, datetime currentTime)
  {
   datetime time1 = (datetime)ObjectGetInteger(0, trendlineName, OBJPROP_TIME1);
   double price1 = ObjectGetDouble(0, trendlineName, OBJPROP_PRICE1);

   datetime time2 = (datetime)ObjectGetInteger(0, trendlineName, OBJPROP_TIME2);
   double price2 = ObjectGetDouble(0, trendlineName, OBJPROP_PRICE2);

   if((time2 - time1) == 0)
      return 0;

// Tính độ dốc của trendline
   double slope = (price2 - price1) / (time2 - time1);

// Tính giá trị của trendline tại thời gian hiện tại
   double priceAtCurrentTime = NormalizeDouble(price1 + slope * (currentTime - time1), Digits-1);

   return priceAtCurrentTime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Trend_Channel(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   string PREFIX = "CHANNEL_" + get_time_frame_name(TIMEFRAME) + "_";

   int itemIdx1 = 0, itemIdx2 = 0, itemIdx3 = 0, itemIdx4 = 0, itemIdx5 = 0, itemIdx6 = 0, itemIdx7 = 0, itemIdx8 = 0, itemIdx9 = 0, itemIdx10 = 0;
   int count_item1 = 0, count_item2 = 0, count_item3 = 0, count_item4 = 0, count_item5 = 0, count_item6 = 0, count_item7 = 0, count_item8 = 0, count_item9 = 0, count_item10 = 0;
   string trendIdx1 = "", trendIdx2 = "", trendIdx3 = "", trendIdx4 = "", trendIdx5 = "", trendIdx6 = "", trendIdx7 = "", trendIdx8 = "", trendIdx9 = "", trendIdx10 = "";
   double maxmin_hist1 = 0, maxmin_hist2 = 0, maxmin_hist3 = 0, maxmin_hist4 = 0, maxmin_hist5 = 0, maxmin_hist6 = 0, maxmin_hist7 = 0, maxmin_hist8 = 0, maxmin_hist9 = 0, maxmin_hist10 = 0;
   bool found_item1 = false, found_item2 = false, found_item3 = false, found_item4 = false, found_item5 = false, found_item6 = false, found_item7 = false, found_item8 = false, found_item9 = false, found_item10 = false;
   int START_IDX = 1;
   int min_candle_count = 3;
   int limit = MathMin(250, iBars(symbol, TIMEFRAME)-10);

   double macdHist0 = iMACD(symbol, TIMEFRAME,12,26,9, PRICE_CLOSE, MODE_MAIN, 0);
   string trendIdx0 = macdHist0 > 0 ? TREND_BUY : TREND_SEL;
   datetime timeH4 = iTime(symbol, PERIOD_D1, 0);
   for(int i = 0; i < limit; i++)
     {
      double macdHistH4_i = iMACD(symbol, PERIOD_D1,12,26,9, PRICE_CLOSE, MODE_MAIN, i);
      string trendHistH4_i = macdHistH4_i > 0 ? TREND_BUY : TREND_SEL;

      if(trendIdx0 != trendHistH4_i)
        {
         timeH4 = iTime(symbol, PERIOD_D1, i);
         break;
        }
     }
   for(int i = 0; i < limit; i++)
      if(iTime(symbol, TIMEFRAME, i) < timeH4)
        {
         START_IDX = i;
         break;
        }

   for(int i = START_IDX; i < limit; i++)
     {
      double macdHistCurr = iMACD(symbol, TIMEFRAME,12,26,9, PRICE_CLOSE, MODE_MAIN, i);
      double macdHistPrev = iMACD(symbol, TIMEFRAME,12,26,9, PRICE_CLOSE, MODE_MAIN, i+1);

      string trendHistCurr = macdHistCurr > 0 ? TREND_BUY : TREND_SEL;
      string trendHistPrev = macdHistPrev > 0 ? TREND_BUY : TREND_SEL;

      if(i == START_IDX)
        {
         trendIdx1 = macdHistCurr > 0 ? TREND_BUY : TREND_SEL;
         trendIdx2 = trendIdx1 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx3 = trendIdx2 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx4 = trendIdx3 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx5 = trendIdx4 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx6 = trendIdx5 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx7 = trendIdx6 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx8 = trendIdx7 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx9 = trendIdx8 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx10= trendIdx9 == TREND_BUY ? TREND_SEL : TREND_BUY;
        }

      if(!found_item1)
        {
         if(trendIdx1 == trendHistPrev)
           {
            count_item1 += 1;
            if((trendIdx1 == TREND_BUY) && (maxmin_hist1 == 0 || macdHistCurr > maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }

            if((trendIdx1 == TREND_SEL) && (maxmin_hist1 == 0 || macdHistCurr < maxmin_hist1))
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
         if(trendIdx2 == trendHistPrev)
           {
            count_item2 += 1;
            if((trendIdx2 == TREND_BUY) && (maxmin_hist2 == 0 || macdHistCurr > maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }

            if((trendIdx2 == TREND_SEL) && (maxmin_hist2 == 0 || macdHistCurr < maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }
           }
         else
           {
            if(count_item2 > min_candle_count)
               found_item2 = true;
           }

         if(i == limit-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && !found_item3 && (i<limit-2))
        {
         if(trendIdx3 == trendHistPrev)
           {
            count_item3 += 1;
            if((trendIdx3 == TREND_BUY) && (maxmin_hist3 == 0 || macdHistCurr > maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }

            if((trendIdx3 == TREND_SEL) && (maxmin_hist3 == 0 || macdHistCurr < maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }
           }
         else
           {
            if(count_item3 > min_candle_count)
               found_item3 = true;
           }

         if(i == limit-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && found_item3 && !found_item4)
        {
         if(trendIdx4 == trendHistPrev)
           {
            count_item4 += 1;
            if((trendIdx4 == TREND_BUY) && (maxmin_hist4 == 0 || macdHistCurr > maxmin_hist4))
              {
               itemIdx4 = i;
               maxmin_hist4 = macdHistCurr;
              }

            if((trendIdx4 == TREND_SEL) && (maxmin_hist4 == 0 || macdHistCurr < maxmin_hist4))
              {
               itemIdx4 = i;
               maxmin_hist4 = macdHistCurr;
              }
           }
         else
           {
            if(count_item4 > min_candle_count)
               found_item4 = true;
           }

         if(i == limit-1)
            found_item4 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && !found_item5)
        {
         if(trendIdx5 == trendHistPrev)
           {
            count_item5 += 1;
            if((trendIdx5 == TREND_BUY) && (maxmin_hist5 == 0 || macdHistCurr > maxmin_hist5))
              {
               itemIdx5 = i;
               maxmin_hist5 = macdHistCurr;
              }

            if((trendIdx5 == TREND_SEL) && (maxmin_hist5 == 0 || macdHistCurr < maxmin_hist5))
              {
               itemIdx5 = i;
               maxmin_hist5 = macdHistCurr;
              }
           }
         else
           {
            if(count_item5 > min_candle_count)
               found_item5 = true;
           }

         if(i == limit-1)
            found_item5 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && !found_item6)
        {
         if(trendIdx6 == trendHistPrev)
           {
            count_item6 += 1;
            if((trendIdx6 == TREND_BUY) && (maxmin_hist6 == 0 || macdHistCurr > maxmin_hist6))
              {
               itemIdx6 = i;
               maxmin_hist6 = macdHistCurr;
              }

            if((trendIdx6 == TREND_SEL) && (maxmin_hist6 == 0 || macdHistCurr < maxmin_hist6))
              {
               itemIdx6 = i;
               maxmin_hist6 = macdHistCurr;
              }
           }
         else
           {
            if(count_item6 > min_candle_count)
               found_item6 = true;
           }

         if(i == limit-1)
            found_item6 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && !found_item7)
        {
         if(trendIdx7 == trendHistPrev)
           {
            count_item7 += 1;
            if((trendIdx7 == TREND_BUY) && (maxmin_hist7 == 0 || macdHistCurr > maxmin_hist7))
              {
               itemIdx7 = i;
               maxmin_hist7 = macdHistCurr;
              }

            if((trendIdx7 == TREND_SEL) && (maxmin_hist7 == 0 || macdHistCurr < maxmin_hist7))
              {
               itemIdx7 = i;
               maxmin_hist7 = macdHistCurr;
              }
           }
         else
           {
            if(count_item7 > min_candle_count)
               found_item7 = true;
           }

         if(i == limit-1)
            found_item7 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && found_item7 && !found_item8)
        {
         if(trendIdx8 == trendHistPrev)
           {
            count_item8 += 1;
            if((trendIdx8 == TREND_BUY) && (maxmin_hist8 == 0 || macdHistCurr > maxmin_hist8))
              {
               itemIdx8 = i;
               maxmin_hist8 = macdHistCurr;
              }

            if((trendIdx8 == TREND_SEL) && (maxmin_hist8 == 0 || macdHistCurr < maxmin_hist8))
              {
               itemIdx8 = i;
               maxmin_hist8 = macdHistCurr;
              }
           }
         else
           {
            if(count_item8 > min_candle_count)
               found_item8 = true;
           }
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && found_item7 && found_item8 && !found_item9)
        {
         if(trendIdx9 == trendHistPrev)
           {
            count_item9 += 1;
            if((trendIdx9 == TREND_BUY) && (maxmin_hist9 == 0 || macdHistCurr > maxmin_hist9))
              {
               itemIdx9 = i;
               maxmin_hist9 = macdHistCurr;
              }

            if((trendIdx9 == TREND_SEL) && (maxmin_hist9 == 0 || macdHistCurr < maxmin_hist9))
              {
               itemIdx9 = i;
               maxmin_hist9 = macdHistCurr;
              }
           }
         else
           {
            if(count_item9 > min_candle_count)
               found_item9 = true;
           }

        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && found_item7 && found_item8 && found_item9 && !found_item10)
        {
         if(trendIdx10 == trendHistPrev)
           {
            count_item10 += 1;
            if((trendIdx10 == TREND_BUY) && (maxmin_hist10 == 0 || macdHistCurr > maxmin_hist10))
              {
               itemIdx10 = i;
               maxmin_hist10 = macdHistCurr;
              }

            if((trendIdx10 == TREND_SEL) && (maxmin_hist10 == 0 || macdHistCurr < maxmin_hist10))
              {
               itemIdx10 = i;
               maxmin_hist10 = macdHistCurr;
              }
           }
         else
           {
            if(count_item10 > min_candle_count)
               found_item10 = true;
           }
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5 && found_item6 && found_item7 && found_item8 && found_item9 && found_item10)
         break;
     }

   if(found_item1 && found_item2 && found_item3 && found_item4)
     {
      datetime date1 = iTime(symbol, TIMEFRAME, itemIdx1);
      datetime date2 = iTime(symbol, TIMEFRAME, itemIdx2);
      datetime date3 = iTime(symbol, TIMEFRAME, itemIdx3);
      datetime date4 = iTime(symbol, TIMEFRAME, itemIdx4);

      double price1 = trendIdx1 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx1) : iLow(symbol, TIMEFRAME, itemIdx1);
      double price2 = trendIdx2 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx2) : iLow(symbol, TIMEFRAME, itemIdx2);
      double price3 = trendIdx3 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx3) : iLow(symbol, TIMEFRAME, itemIdx3);
      double price4 = trendIdx4 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx4) : iLow(symbol, TIMEFRAME, itemIdx4);

      datetime date0 = TimeCurrent();

      create_trend_line(PREFIX + "13", date3, price3, date1, price1, price1 < price2 ? clrBlue : clrRed, STYLE_SOLID, 1, false, false, true, false);
      create_trend_line(PREFIX + "24", date4, price4, date2, price2, price1 > price2 ? clrBlue : clrRed, STYLE_SOLID, 1, false, false, true, false);

      double cur_line_13_price = GetTrendlineValueAtCurrentTime(PREFIX + "13", date0);
      create_trend_line(PREFIX + "13.", date1, price1, date0, cur_line_13_price, price1 < price2 ? clrBlue : clrRed, STYLE_SOLID, 1, false, false, true, false);

      double cur_line_24_price = GetTrendlineValueAtCurrentTime(PREFIX + "24", date0);
      create_trend_line(PREFIX + "24.", date2, price2, date0, cur_line_24_price, price1 > price2 ? clrBlue : clrRed, STYLE_SOLID, 1, false, false, true, false);
     }


   if(found_item1 && found_item2 && found_item3)
     {
      datetime date1 = iTime(symbol, TIMEFRAME, itemIdx1);
      datetime date2 = iTime(symbol, TIMEFRAME, itemIdx2);
      datetime date3 = iTime(symbol, TIMEFRAME, itemIdx3);

      double price1 = trendIdx1 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx1) : iLow(symbol, TIMEFRAME, itemIdx1);
      double price2 = trendIdx2 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx2) : iLow(symbol, TIMEFRAME, itemIdx2);
      double price3 = trendIdx3 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx3) : iLow(symbol, TIMEFRAME, itemIdx3);

      color clrTrend1 = trendIdx1 == TREND_BUY ? clrRed : clrBlue;
      color clrTrend2 = trendIdx2 == TREND_BUY ? clrRed : clrBlue;
      color clrTrend3 = trendIdx3 == TREND_BUY ? clrRed : clrBlue;

      create_vertical_line("Week1", date1, clrBlack, STYLE_SOLID, 1);
      create_vertical_line("Week2", date2, clrBlack, STYLE_SOLID, 1);
      create_vertical_line("Week3", date3, clrBlack, STYLE_SOLID, 1);

      //create_trend_line("Week1.", date1 - TIME_OF_ONE_W1_CANDLE*1, price1, date1 + TIME_OF_ONE_W1_CANDLE*1, price1, clrTrend1, STYLE_SOLID, 3);
      //create_trend_line("Week2.", date2 - TIME_OF_ONE_W1_CANDLE*1, price2, date2 + TIME_OF_ONE_W1_CANDLE*1, price2, clrTrend2, STYLE_SOLID, 3);
      //create_trend_line("Week3.", date3 - TIME_OF_ONE_W1_CANDLE*1, price3, date3 + TIME_OF_ONE_W1_CANDLE*1, price3, clrTrend3, STYLE_SOLID, 3);

      create_lable("Week1..", date1 - TIME_OF_ONE_W1_CANDLE*1, price1,  "~" + (string)(itemIdx1) + "w", "");
      create_lable("Week2..", date2 - TIME_OF_ONE_W1_CANDLE*1, price2,  "~" + (string)(itemIdx2 - itemIdx1) + "w", "");
      create_lable("Week3..", date3 - TIME_OF_ONE_W1_CANDLE*1, price3,  "~" + (string)(itemIdx3 - itemIdx2) + "w", "");
     }

   if(found_item4)
     {
      color clrTrend = trendIdx4 == TREND_BUY ? clrRed : clrBlue;
      datetime date = iTime(symbol, TIMEFRAME, itemIdx4);
      double price = trendIdx4 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx4) : iLow(symbol, TIMEFRAME, itemIdx4);
      create_vertical_line("Week4", date, clrBlack, STYLE_SOLID, 1);
      //create_trend_line("Week4.", date - TIME_OF_ONE_W1_CANDLE*1, price, date + TIME_OF_ONE_W1_CANDLE*1, price, clrTrend, STYLE_SOLID, 3);
      create_lable("Week4..", date - TIME_OF_ONE_W1_CANDLE*1, price,  "~" + (string)(itemIdx4 - itemIdx3) + "w", "");
     }

   if(found_item5)
     {
      color clrTrend = trendIdx5 == TREND_BUY ? clrRed : clrBlue;
      datetime date = iTime(symbol, TIMEFRAME, itemIdx5);
      double price = trendIdx5 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx5) : iLow(symbol, TIMEFRAME, itemIdx5);
      create_vertical_line("Week5", date, clrBlack, STYLE_SOLID, 1);
      //create_trend_line("Week5.", date - TIME_OF_ONE_W1_CANDLE*1, price, date + TIME_OF_ONE_W1_CANDLE*1, price, clrTrend, STYLE_SOLID, 3);
      create_lable("Week5..", date - TIME_OF_ONE_W1_CANDLE*1, price,  "~" + (string)(itemIdx5 - itemIdx4) + "w", "");
     }

   if(found_item6)
     {
      color clrTrend = trendIdx6 == TREND_BUY ? clrRed : clrBlue;
      datetime date = iTime(symbol, TIMEFRAME, itemIdx6);
      double price = trendIdx6 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx6) : iLow(symbol, TIMEFRAME, itemIdx6);
      create_vertical_line("Week6", date, clrBlack, STYLE_SOLID, 1);
      //create_trend_line("Week6.", date - TIME_OF_ONE_W1_CANDLE*1, price, date + TIME_OF_ONE_W1_CANDLE*1, price, clrTrend, STYLE_SOLID, 3);
      create_lable("Week6..", date - TIME_OF_ONE_W1_CANDLE*1, price,  "~" + (string)(itemIdx6 - itemIdx5) + "w", "");
     }

   if(found_item7)
     {
      color clrTrend = trendIdx7 == TREND_BUY ? clrRed : clrBlue;
      datetime date = iTime(symbol, TIMEFRAME, itemIdx7);
      double price = trendIdx7 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx7) : iLow(symbol, TIMEFRAME, itemIdx7);
      create_vertical_line("Week7", date, clrBlack, STYLE_SOLID, 1);
      //create_trend_line("Week7.", date - TIME_OF_ONE_W1_CANDLE*1, price, date + TIME_OF_ONE_W1_CANDLE*1, price, clrTrend, STYLE_SOLID, 3);
      create_lable("Week7..", date - TIME_OF_ONE_W1_CANDLE*1, price,  "~" + (string)(itemIdx7 - itemIdx6) + "w", "");
     }

   if(found_item8)
     {
      color clrTrend = trendIdx8 == TREND_BUY ? clrRed : clrBlue;
      datetime date = iTime(symbol, TIMEFRAME, itemIdx8);
      double price = trendIdx8 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx8) : iLow(symbol, TIMEFRAME, itemIdx8);
      create_vertical_line("Week8", date, clrBlack, STYLE_SOLID, 1);
      //create_trend_line("Week8.", date - TIME_OF_ONE_W1_CANDLE*1, price, date + TIME_OF_ONE_W1_CANDLE*1, price, clrTrend, STYLE_SOLID, 3);
      create_lable("Week8..", date - TIME_OF_ONE_W1_CANDLE*1, price,  "~" + (string)(itemIdx8 - itemIdx7) + "w", "");
     }

   if(found_item9)
     {
      color clrTrend = trendIdx9 == TREND_BUY ? clrRed : clrBlue;
      datetime date = iTime(symbol, TIMEFRAME, itemIdx9);
      double price = trendIdx9 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx9) : iLow(symbol, TIMEFRAME, itemIdx9);
      create_vertical_line("Week9", date, clrBlack, STYLE_SOLID, 1);
      //create_trend_line("Week9.", date - TIME_OF_ONE_W1_CANDLE*1, price, date + TIME_OF_ONE_W1_CANDLE*1, price, clrTrend, STYLE_SOLID, 3);
      create_lable("Week9..", date - TIME_OF_ONE_W1_CANDLE*1, price,  "~" + (string)(itemIdx9 - itemIdx8) + "w", "");
     }

   if(found_item10)
     {
      color clrTrend = trendIdx10 == TREND_BUY ? clrRed : clrBlue;
      datetime date = iTime(symbol, TIMEFRAME, itemIdx10);
      double price = trendIdx10 == TREND_BUY ? iHigh(symbol, TIMEFRAME, itemIdx10) : iLow(symbol, TIMEFRAME, itemIdx10);
      create_vertical_line("Week10", date, clrBlack, STYLE_SOLID, 1);
      //create_trend_line("Week10.", date - TIME_OF_ONE_W1_CANDLE*1, price, date + TIME_OF_ONE_W1_CANDLE*1, price, clrTrend, STYLE_SOLID, 3);
      create_lable("Week10..", date - TIME_OF_ONE_W1_CANDLE*1, price,  "~" + (string)(itemIdx10 - itemIdx9) + "w", "");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_trend_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int inK, int inD, int inS, int sub_window, int width_main)
  {
   string TF = get_time_frame_name(TIMEFRAME);
   string strKDS = "(" + append1Zero(inK) + "," + append1Zero(inD) + "," + append1Zero(inS) + ")";
   string prefix = strKDS + TF + (string)sub_window;

   int size = 300;
   if(TIMEFRAME == PERIOD_M5)
      size = 1;
   for(int i = 0; i < size; i++)
     {
      datetime time_i = (i == 0) ? TimeCurrent() : iTime(symbol, TIMEFRAME, i);
      datetime time_pre_i = iTime(symbol, TIMEFRAME,i+1);

      double main_i = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  i);
      double sign_i = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,i);

      double main_pre_i = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  i+1);
      double sign_pre_i = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,i+1);

      string trend_di = (main_i > sign_i ? TREND_BUY : TREND_SEL);
      color  color_di = trend_di == TREND_BUY ? clrTeal : clrFireBrick;

      string nm_main = "stoc" + strKDS + "main." + TF + "i" + appendZero100(i);
      string nm_sign = "stoc" + strKDS + "sign." + TF + "i" + appendZero100(i);

      create_trend_line(nm_main, time_i, main_i, time_pre_i, main_pre_i, color_di, STYLE_SOLID, width_main, false, false, true, false, sub_window);
      if(TIMEFRAME == Period())
         create_trend_line(nm_sign, time_i, sign_i, time_pre_i, sign_pre_i, color_di, STYLE_SOLID, width_main, false, false, true, false, sub_window);
      else
         ObjectDelete(0, nm_sign);

      if(i == 0)
        {
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)-2;
         int x_start = (int)(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, sub_window));
         int y_start = (int)(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, sub_window));
         double stoc = (main_i + main_i + sign_i)/3;

         datetime time_frm = TimeCurrent();
         if(Period() == PERIOD_D1)
            time_frm += TIME_OF_ONE_D1_CANDLE;
         if(Period() == PERIOD_H4)
            time_frm += TIME_OF_ONE_H4_CANDLE;
         if(Period() == PERIOD_H1)
            time_frm += TIME_OF_ONE_H1_CANDLE;

         string lableTfD1 = "--D"+(string)inK+" " ;
         string lableTfH4 = "--               H4 ";
         string lableTfH1 = "--                          H1 ";

         string lableTf = get_time_frame_name(TIMEFRAME);
         if(TIMEFRAME == PERIOD_D1)
            lableTf = lableTfD1;
         if(TIMEFRAME == PERIOD_H4)
            lableTf = lableTfH4;
         if(TIMEFRAME == PERIOD_H1)
            lableTf = lableTfH1;

         create_lable("Toc_" + prefix, TimeCurrent(), stoc, lableTf + " (" + getShortName(trend_di) + ", " + DoubleToStr(stoc,1) + ")", trend_di, true, 8, true, sub_window);
         ObjectSetInteger(0,"Toc_" + prefix, OBJPROP_COLOR, trend_di == TREND_BUY ? clrTeal : clrFireBrick);

         if(TIMEFRAME == PERIOD_D1)
            y_start = 10;
         if(TIMEFRAME == PERIOD_H4)
            y_start = (int)(y_start/2) - 10;
         if(TIMEFRAME == PERIOD_H1)
            y_start = (int)(y_start) - 30;

         createButton(BtnTrend + "Stoc " + TF + (string)sub_window
                      , strKDS + " " + TF + " " + trend_di + " " + (string)(int)stoc
                      , x_start - 180 - 5, y_start, 180, 20, color_di, clrWhite, 7, sub_window);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_trend_macd(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int width_main)
  {
   int sub_window = 1;
   double min_value = 0, max_value = 0;
   string TF = get_time_frame_name(TIMEFRAME);
   ObjectDelete(0, "Macd " + TF + "0");

   int size = 300;
   for(int i = 0; i < size; i++)
     {
      datetime time_i = (i == 0) ? TimeCurrent() : iTime(symbol, TIMEFRAME, i);
      datetime time_pre_i = iTime(symbol, TIMEFRAME,i+1);

      double hist_i = iMACD(symbol, TIMEFRAME,12,26,9,PRICE_CLOSE,MODE_MAIN, i);
      double sign_i = iMACD(symbol, TIMEFRAME,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);

      double hist_pre_i = iMACD(symbol, TIMEFRAME,12,26,9,PRICE_CLOSE,MODE_MAIN, i+1);
      double sign_pre_i = iMACD(symbol, TIMEFRAME,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i+1);

      if(i==0 || min_value < hist_i)
         min_value = hist_i;
      if(i==0 || max_value > hist_i)
         max_value = hist_i;

      string trend_di = (hist_i > sign_i ? TREND_BUY : TREND_SEL);
      color  color_di = trend_di == TREND_BUY ? clrTeal : clrFireBrick;
      if(i == 0)
        {
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)-2;
         int x_start = (int)(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, sub_window));
         int y_start = (int)(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, sub_window));

         datetime time_frm = TimeCurrent();
         if(Period() == PERIOD_D1)
            time_frm += TIME_OF_ONE_D1_CANDLE;
         if(Period() == PERIOD_H4)
            time_frm += TIME_OF_ONE_H4_CANDLE;
         if(Period() == PERIOD_H1)
            time_frm += TIME_OF_ONE_H1_CANDLE;

         if(TIMEFRAME == PERIOD_D1)
            y_start = 10;
         if(TIMEFRAME == PERIOD_H4)
            y_start = (int)(y_start/2) - 10;
         if(TIMEFRAME == PERIOD_H1)
            y_start = (int)(y_start) - 30;

         double avg_macd = (hist_i + hist_i + sign_i)/3;

         createButton(BtnTrend + "Macd " + TF + "0", "(12,26,9) " + TF + ": " + trend_di
                      + " " + DoubleToStr(avg_macd, digits)
                      , x_start - 180 - 5, y_start, 180, 20, color_di, clrWhite, 7, sub_window);
        }

      color clrColor = clrBlack;

      string nm_main = "macd_main_" + TF + "_" + appendZero100(i);
      string nm_sign = "macd_sign_" + TF + "_" + appendZero100(i);

      create_trend_line(nm_main, time_i, hist_i, time_pre_i, hist_pre_i, color_di, STYLE_SOLID, width_main, false, false, true, false, sub_window);
      if(TIMEFRAME == Period() || TIMEFRAME == PERIOD_CURRENT)
         create_trend_line(nm_sign, time_i, sign_i, time_pre_i, sign_pre_i, color_di, STYLE_SOLID, width_main, false, false, true, false, sub_window);
      else
         ObjectDelete(0, nm_sign);

      if(i == 0)
        {
         string lableTfD1 = "--D1 " ;
         string lableTfH4 = "--           H4 ";
         string lableTfH1 = "--                      H1 ";

         string lableTf = "";
         if(TIMEFRAME == PERIOD_D1)
            lableTf = lableTfD1;
         if(TIMEFRAME == PERIOD_H4)
            lableTf = lableTfH4;
         if(TIMEFRAME == PERIOD_H1)
            lableTf = lableTfH1;

         create_lable("Macd." + TF, TimeCurrent(), hist_i, lableTf, trend_di,true, 8, true, sub_window);
         ObjectSetInteger(0,"Macd." + TF,OBJPROP_COLOR, color_di);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenChartWindowXauUsd(string buttonLabel, ENUM_TIMEFRAMES TIMEFRAME)
  {
   long chartID = 0;

   string cur_symbol = Symbol();

   if(is_same_symbol(buttonLabel, cur_symbol))
     {
      chartID=ChartFirst();
      while(chartID >= 0)
        {
         ChartClose(chartID);
         chartID = ChartNext(chartID);
        }

      ChartOpen(cur_symbol, TIMEFRAME);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_time_frame_name(ENUM_TIMEFRAMES PERIOD_XX)
  {
   if(PERIOD_XX == PERIOD_M1)
      return "M1";

   if(PERIOD_XX == PERIOD_M5)
      return "M5";

   if(PERIOD_XX == PERIOD_M15)
      return "M15";

   if(PERIOD_XX ==  PERIOD_H1)
      return "H1";

   if(PERIOD_XX ==  PERIOD_H4)
      return "H4";

   if(PERIOD_XX ==  PERIOD_D1)
      return "D1";

   if(PERIOD_XX ==  PERIOD_W1)
      return "W1";

   if(PERIOD_XX ==  PERIOD_MN1)
      return "MO";

   return "??";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getShortName(string trend)
  {
   if(is_same_symbol(trend, TREND_BUY))
      return "B";

   if(is_same_symbol(trend, TREND_SEL))
      return  "S";

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vntime()
  {
   string cpu = "";
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9) ? (string) gmt_time.hour : "0" + (string) gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string str_date_time = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES);
   string vntime = "(" + str_date_time + ")    ";
   return vntime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, int ordertype)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderComment(), BOT_SHORT_NM) &&
            is_same_symbol(OrderSymbol(), symbol) && OrderType() == ordertype)
           {
            int demm = 1;
            while(demm<20)
              {
               double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
               double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
               int slippage = (int)MathAbs(ask-bid);

               if(OrderType() == OP_BUY && is_same_symbol(OrderComment(), TREND_BUY))
                 {
                  bool successful=OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet);
                  if(successful)
                     break;
                 }

               if(OrderType() == OP_SELL && is_same_symbol(OrderComment(), TREND_SEL))
                 {
                  bool successful=OrderClose(OrderTicket(),OrderLots(), ask, slippage, clrViolet);
                  if(successful)
                     break;
                 }

               demm++;
               Sleep(100);
              }
           }
     } //for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositivePosition(string symbol, int OP_TYPE)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderComment(), BOT_SHORT_NM) &&
            is_same_symbol(OrderSymbol(), symbol) &&
            (OrderType() == OP_TYPE) &&
            (OrderProfit() > 0))
           {
            int demm = 1;
            while(demm<5)
              {
               double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
               double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
               int slippage = (int)MathAbs(ask-bid);

               if(OrderType() == OP_BUY)
                 {
                  bool successful=OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet);
                  if(successful)
                     break;
                 }

               if(OrderType() == OP_SELL)
                 {
                  bool successful=OrderClose(OrderTicket(),OrderLots(), ask, slippage, clrViolet);
                  if(successful)
                     break;
                 }

               demm++;
               Sleep(100);
              }
           }
     } //for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTelegramMessage(string symbol, string trend, string message)
  {
   if(is_has_memo_in_file(FILE_NAME_SEND_MSG, symbol, trend))
      return;
   add_memo_to_file(FILE_NAME_SEND_MSG, symbol, trend);

   string botToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
   string chatId_duydk = "5099224587";

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   string str_cur_price = " price:" + (string) price;

   Alert(get_vntime(), message + str_cur_price);

   if(IsTesting())
      return;

   string new_message = get_vntime() + message + str_cur_price;

   StringReplace(new_message, " ", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "_", "%20");
   StringReplace(new_message, " ", "%20");

   string url = StringFormat("%s/bot%s/sendMessage?chat_id=%s&text=%s", telegram_url, botToken, chatId_duydk, new_message);

   string cookie=NULL,headers;
   char   data[],result[];

   ResetLastError();

   int timeout = 60000; // 60 seconds
   int res=WebRequest("GET",url,cookie,NULL,timeout,data,0,result,headers);
   if(res==-1)
      Alert("WebRequest Error:", GetLastError(), ", URL: ", url, ", Headers: ", headers, "   ", MB_ICONERROR);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

   string percent = AppendSpaces(format_double_to_string(profit, 2), 7, false) + "$ (" + AppendSpaces(format_double_to_string(profit/BALANCE * 100, 2), 5, false) + "%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_has_memo_in_file(string filename, string symbol, string TRADING_TREND_KEY)
  {
   string open_trade_today = ReadFileContent(filename);

   string key = create_key(symbol, TRADING_TREND_KEY);
   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename, string symbol, string TRADING_TREND_KEY, string note_stoploss = "", ulong ticket = 0, string note = "")
  {
   string open_trade_today = ReadFileContent(filename);
   string key = create_key(symbol, TRADING_TREND_KEY);

   open_trade_today = open_trade_today + key;

   if(note != "")
      open_trade_today += note;

   open_trade_today += "@NEXT@";

   WriteFileContent(filename, open_trade_today);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReadFileContent(string file_name)
  {
   string fileContent = "";
   int fileHandle = FileOpen(file_name, FILE_READ);

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
void WriteFileContent(string file_name, string content)
  {
   int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);

   if(fileHandle != INVALID_HANDLE)
     {
      string file_contents = CutString(content);

      FileWriteString(fileHandle, file_contents);
      FileClose(fileHandle);
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
      int startIndex = originalLength - max_lengh;
      return StringSubstr(originalString, startIndex, max_lengh);
     }
   return originalString;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_key(string symbol, string TRADING_TREND_KEY)
  {
   string date_time = time2string(iTime(symbol, PERIOD_H4, 0));
   string key = date_time + ":PERIOD_H4:" + TRADING_TREND_KEY + ":" + symbol +";";
   return key;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   double macd_0=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double sign_0=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);

   if(macd_0 >= sign_0)
      return TREND_BUY;

   if(macd_0 <= sign_0)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   double macd_0=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   if(macd_0 >= 0)
      return TREND_BUY;

   if(macd_0 <= 0)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe, string &trend_by_macd, string &trend_mac_vs_signal, string &trend_mac_vs_zero)
  {
   trend_by_macd = "";
   trend_mac_vs_signal = "";
   trend_mac_vs_zero = "";

   double macd_0=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double macd_1=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double sign_0=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   double sign_1=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);

   if(macd_0 >= 0 && sign_0 >= 0)
      trend_by_macd = TREND_BUY;

   if(macd_0 <= 0 && sign_0 <= 0)
      trend_by_macd = TREND_SEL;

   if(macd_0 >= sign_0 && macd_1 >= sign_1 && macd_0 >= macd_1)
      trend_mac_vs_signal = TREND_BUY;

   if(macd_0 <= sign_0 && macd_1 <= sign_1 && macd_0 <= macd_1)
      trend_mac_vs_signal = TREND_SEL;

   if(macd_0 >= 0 && macd_1 >= 0)
      trend_mac_vs_zero = TREND_BUY;

   if(macd_0 <= 0 && macd_1 <= 0)
      trend_mac_vs_zero = TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int remaining_time_to_dca(datetime last_open_trade_time, int waiting_minus)
  {
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_open_trade_time;
   return (int)(waiting_minus - timeGap/60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_by_ma7_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend)
  {
   string trend_m5_ma0710 = "";
   string trend_m5_ma1020 = "";
   string trend_m5_ma2050 = "";
   string trend_m5_C1ma10 = "";
   string trend_m5_ma50d1 = "";
   bool is_insign_m5 = false;
   get_trend_by_ma_seq71020_steadily(symbol, timeframe, trend_m5_ma0710, trend_m5_ma1020, trend_m5_ma2050, trend_m5_C1ma10, trend_m5_ma50d1, is_insign_m5);

   string trend_reverse = get_trend_reverse(find_trend);

   if(trend_reverse == trend_m5_ma2050)
      if(trend_m5_ma0710 == trend_m5_ma1020 && trend_m5_ma1020 == trend_m5_ma2050)
         return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME, bool auto_init = false)
  {
   double bla_K03 = iStochastic(symbol,TIMEFRAME, 3,3,2,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double bla_D03 = iStochastic(symbol,TIMEFRAME, 3,3,2,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double bla_K05 = iStochastic(symbol,TIMEFRAME, 7,5,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D05 = iStochastic(symbol,TIMEFRAME, 7,5,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double bla_K13 = iStochastic(symbol,TIMEFRAME,12,7,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D13 = iStochastic(symbol,TIMEFRAME,12,7,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double bla_K21 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D21 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);

   string result = "";

   string trend_03c = bla_K03>bla_D03?TREND_BUY:TREND_SEL;
   string trend_05c = bla_K05>red_D05?TREND_BUY:TREND_SEL;
   string trend_13c = bla_K13>red_D13?TREND_BUY:TREND_SEL;
   string trend_21c = bla_K21>red_D21?TREND_BUY:TREND_SEL;
   string trend =trend_03c+trend_05c+trend_13c+trend_21c;

   if(
      (bla_K05 <= 20 || red_D05 <= 20) ||
      (bla_K13 <= 20 || red_D13 <= 20) ||
      (bla_K21 <= 20 || red_D21 <= 20)
   )
      if(is_same_symbol(trend,TREND_BUY))
         result += TREND_BUY + " (20) ";

   if(
      (bla_K05 >= 80 || red_D05 >= 80) ||
      (bla_K13 >= 80 || red_D13 >= 80) ||
      (bla_K21 >= 80 || red_D21 >= 80)
   )
      if(is_same_symbol(trend,TREND_SEL))
         result += TREND_SEL + " (80) ";

   if(auto_init && result == "")
     {
      if(is_same_symbol(trend,TREND_BUY))
         result += " " + TREND_BUY;
      if(is_same_symbol(trend,TREND_SEL))

         result += " " + TREND_SEL;
     }


   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc2(string symbol, ENUM_TIMEFRAMES timeframe, int inK = 13, int inD = 8, int inS = 5, int candle_no = 0)
  {
   double M_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double M_1 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  1);// 1st bar
   double S_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar
   double S_1 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,1);// 1st bar

   double black_K = M_0;
   double red_D = S_0;

   if(black_K > red_D)
      return TREND_BUY;

   if(black_K < red_D)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_stoc3(string symbol, ENUM_TIMEFRAMES timeframe, string &cur_trend, double &stoc_value
                        , int inK = 21, int inD = 7, int inS = 7, int candle_no = 0)
  {
   double M_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double S_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar
   int digits = MathMin(5, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))-1;

   if(M_0 > S_0)
      cur_trend = TREND_BUY;

   if(M_0 < S_0)
      cur_trend = TREND_SEL;

   stoc_value = NormalizeDouble((M_0 + M_0 + S_0)/3, digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   double black_K = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double red_D   = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar

   if(find_trend == TREND_BUY && black_K >= red_D && (red_D <= 20 || black_K <= 20))
      return true;

   if(find_trend == TREND_SEL && black_K <= red_D && (red_D >= 80 || black_K >= 80))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//string get_trend_nm(string TREND)
//  {
//   if(is_same_symbol(TREND, TREND_BUY))
//      return "B";
//
//   if(is_same_symbol(TREND, TREND_SEL))
//      return "S";
//
//   return "";
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_same_symbol(string symbol_og, string symbol_tg)
  {
   if(symbol_og == "" || symbol_og == "")
      return false;

   if(StringFind(toLower(symbol_og), toLower(symbol_tg)) >= 0)
      return true;

   if(StringFind(toLower(symbol_tg), toLower(symbol_og)) >= 0)
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
      return "00" + (string) trade_no;

   if(trade_no < 100)
      return "0" + (string) trade_no;

   return (string) trade_no;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_ma(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index,int candle_no = 1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double close_1 = closePrices[candle_no];
   double ma = cal_MA(closePrices, ma_index, candle_no);

   if(close_1 > ma)
      return TREND_BUY;

   if(close_1 < ma)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_filled_rectangle(
   const string            name="Rectangle",         // object name
   datetime                time_from=0,              // anchor point time (bottom-left corner)
   double                  price_from=0,             // anchor point price (bottom-left corner)
   datetime                time_to=0,                // anchor point time (top-right corner)
   double                  price_to=0,               // anchor point price (top-right corner)
   const color             clr_fill=clrGray,         // fill color
   const bool              is_draw_border=false,
   const bool              is_fill_color=true,
   const string            trend_rec="",
   const int               body_border_width=1
)
  {
   string name_new = name;
   if(is_fill_color)
     {
      ObjectDelete(0, name_new);  // Delete any existing object with the same name
      ObjectCreate(0, name_new, OBJ_RECTANGLE, 0, time_from, price_from, time_to, price_to);
      ObjectSetInteger(0, name_new, OBJPROP_COLOR, clrBlack);         // Set border color
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);      // Set border style to solid
      ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, true);            // Set hidden property
      ObjectSetInteger(0, name_new, OBJPROP_BACK, true);              // Set background property
      ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE, false);       // Set selectable property
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);      // Set style to solid
      ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_fill);         // Set fill color (this may not work as intended for all objects)
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);                // Setting this to 1 for consistency
     }

   if(is_draw_border)
     {
      color clr_border = trend_rec == TREND_BUY ? clrBlue : trend_rec == TREND_SEL ? clrRed : clrNONE; //C'215,215,215'

      create_trend_line(name_new + "_left",   time_from, price_from, time_from, price_to,   clr_border, STYLE_SOLID, body_border_width);
      create_trend_line(name_new + "_righ",   time_to,   price_from, time_to,   price_to,   clr_border, STYLE_SOLID, body_border_width);
      create_trend_line(name_new + "_top",    time_from, price_to,   time_to,   price_to,   clr_border, STYLE_SOLID, body_border_width);
      create_trend_line(name_new + "_bottom", time_from, price_from, time_to,   price_from, clr_border, STYLE_SOLID, body_border_width);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_maX_maY(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_6, int ma_index_9)
  {
   int maLength = MathMax(ma_index_6, ma_index_9) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_6 = cal_MA(closePrices, ma_index_6, 1);
   double ma_9 = cal_MA(closePrices, ma_index_9, 1);

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
double cal_MA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i <= candle_no + ma_index; i++)
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
string get_group_value(string comment, string str_start = "[G", string str_end = "]")
  {
   int startPos = StringFind(comment, str_start);
   int endPos = StringFind(comment, str_end, startPos);
   string result = "";

   if(startPos != -1 && endPos != -1)
      result = StringSubstr(comment, startPos, endPos - startPos + 1);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_group_name()
  {
   datetime VnTime = TimeGMT() + 7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(VnTime, time_struct);

   return "[G"
          + (string)time_struct.day
          + (string)time_struct.hour
          + (string)time_struct.min
          + "]";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_ticket_key(ulong ticket)
  {
   string key = "";

   if(ticket > 0)
     {
      key = "000" + (string)(ticket);
      int length = StringLen(key);

      string lastThree = StringSubstr(key, length - 3, 3);

      key = "[K" + lastThree+ "]";
     }

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string time2string(datetime time)
  {
   string today = (string)time;
   StringReplace(today, " ", "");
   StringReplace(today, "000000", "");
   StringReplace(today, "0000", "");
   StringReplace(today, "00:00:00", "");
   StringReplace(today, "00:00", "");

   return today;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double dblLotsRisk(string symbol, double dbAmp, double dbRiskByUsd)
  {
   double dbLotsMinimum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double dbLotsMaximum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double dbLotsStep     = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double dbTickSize     = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double dbTickValue    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

   double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
   double dbLotReal      = (dbRiskByUsd / dbLossOrder / dbLotsStep) * dbLotsStep;
   double dbCalcLot      = (fmin(dbLotsMaximum, fmax(dbLotsMinimum, round(dbLotReal))));
   double roundedLotSize = MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

   if(roundedLotSize < 0.01)
      roundedLotSize = 0.01;

   return NormalizeDouble(roundedLotSize, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_volume_by_amp(string symbol, double amp_trade, double risk)
  {
   return dblLotsRisk(symbol, amp_trade, risk);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA_XX(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index, int candle_no=1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_value = cal_MA(closePrices, ma_index);
   return ma_value;
  }
//+------------------------------------------------------------------+
string Append(double inputString, int totalLength = 6)
  {
   return AppendSpaces((string) inputString, totalLength);
  }
//+------------------------------------------------------------------+
string AppendSpaces(string inputString, int totalLength = 10, bool is_append_right = true)
  {
   int currentLength = StringLen(inputString);

   if(currentLength >= totalLength)
      return (inputString);

   int spacesToAdd = totalLength - currentLength;
   string spaces = "";
   for(int index = 1; index <= spacesToAdd; index++)
      spaces+= " ";

   if(is_append_right)
      return (inputString + spaces);
   else
      return (spaces + inputString);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string append1Zero(int trade_no)
  {
   if(trade_no < 10)
      return "0" + (string) trade_no;

   return (string) trade_no;
  }
//+------------------------------------------------------------------+
string format_double_to_string(double number, int digits = 5)
  {
   string numberString = (string) number;
   int dotIndex = StringFind(numberString, ".");
   if(dotIndex >= 0)
     {
      string beforeDot = StringSubstr(numberString, 0, dotIndex);
      string afterDot = StringSubstr(numberString, dotIndex + 1);
      afterDot = StringSubstr(afterDot, 0, digits); // chỉ lấy digits chữ số đầu tiên sau dấu chấm

      numberString = beforeDot + "." + afterDot;
     }

   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "99999", "9");
   StringReplace(numberString, "99999", "9");
   StringReplace(numberString, "99999", "9");

   return numberString;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {
   return NormalizeDouble(StringToDouble(format_double_to_string(number, digits)), digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_current_timeframe_to_string()
  {
   if(Period() == PERIOD_M1)
      return "M1";

   if(Period() == PERIOD_M5)
      return "M5";

   if(Period() == PERIOD_M15)
      return "M15";

   if(Period() ==  PERIOD_H1)
      return "H1";

   if(Period() ==  PERIOD_H4)
      return "H4";

   if(Period() ==  PERIOD_D1)
      return "D1";

   if(Period() ==  PERIOD_W1)
      return "W1";

   return "??";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_time_enter_the_market()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);

   int currentHour = vietnamDateTime.hour;
   if(18 <= currentHour && currentHour <= 20)
      return false;

   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week == SATURDAY || day_of_week == SUNDAY)
      return false;

   if(day_of_week == FRIDAY && currentHour > 22)
      return false;

   if(3 <= currentHour && currentHour <= 5)
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_strong_news_time()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);

   int hour = vietnamDateTime.hour;
   if((19 <= hour) && (hour <= 21))
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   double                  price_from=0,                   // anchor point price
   datetime                time_to=0,                   // anchor point time
   double                  price_to=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
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
   ObjectDelete(0, name);
   if(ray_left)
      time_from = time_to - TIME_OF_ONE_W1_CANDLE * 350;
   ObjectCreate(0, name_new, OBJ_TREND, sub_window, time_from, price_from, time_to, price_to);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR,       clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_STYLE,       STYLE_XX);
   ObjectSetInteger(0, name_new, OBJPROP_WIDTH,       width);
   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN,      true);
   ObjectSetInteger(0, name_new, OBJPROP_BACK,        is_back);
   ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT,   ray_right); // Bật tính năng "Rời qua phải"
  }

//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool create_vertical_line(
   const string          name0="VLine",      // line name
   datetime              time=0,            // line time
   const color           clr=clrBlack,        // line color
   const ENUM_LINE_STYLE style=STYLE_DOT, // line style
   const int             width=1,           // line width
   const bool            back=true,        // in the background
   const bool            selection=false,    // highlight to move
   const bool            ray=false,          // line's continuation down
   const bool            hidden=true,      // hidden in the object list
   const long            z_order=0)         // priority for mouse click
  {
//string name = STR_RE_DRAW + name0;
   string name = name0;
   int sub_window=0;      // subwindow index

   if(!time)
      time=TimeGMT();

   ResetLastError();

   if(!ObjectCreate(0,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__, ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(0,name,OBJPROP_RAY,ray);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);
   ObjectSetInteger(0,name, OBJPROP_BACK, true);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_ma_seq71020_steadily(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string &trend_ma0710, string &trend_ma1020, string &trend_ma02050, string &trend_C1ma10, string &trend_h4_ma50d1, bool &insign_h4)
  {
   trend_ma0710 = "";
   trend_ma1020 = "";
   trend_ma02050 = "";
   trend_C1ma10 = "";
   trend_h4_ma50d1 = "";

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);


   int count = 0;
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol, TIMEFRAME, i);
     }

   double ma07[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   double ma10[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   double ma20[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   for(int i = 0; i < 5; i++)
     {
      ma07[i] = cal_MA(closePrices, 7, i);
      ma10[i] = cal_MA(closePrices, 10, i);
      ma20[i] = cal_MA(closePrices, 20, i);
     }
   double ma50_0 = cal_MA(closePrices, 50, 0);
   double ma50_1 = cal_MA(closePrices, 50, 1);
   trend_ma02050 = (ma20[1] > ma50_0) && (ma20[0] > ma50_0) ? TREND_BUY : TREND_SEL;

   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   if(ma50_0+amp_d1 < price)
      trend_h4_ma50d1 = TREND_SEL;
   if(ma50_0-amp_d1 > price)
      trend_h4_ma50d1 = TREND_BUY;

   double ma_min = MathMin(MathMin(MathMin(ma07[0], ma10[0]), ma20[0]), ma50_0);
   double ma_max = MathMax(MathMax(MathMax(ma07[0], ma10[0]), ma20[0]), ma50_0);
   insign_h4 = false;
   if(MathAbs(ma_max - ma_min) < amp_h4*2)
      insign_h4 = true;


// Nếu có ít nhất một cặp giá trị không tăng dần, trả về ""
   string seq_buy_07 = TREND_BUY;
   string seq_buy_10 = TREND_BUY;
   string seq_buy_20 = TREND_BUY;
// Nếu có ít nhất một cặp giá trị không giảm dần, trả về ""
   string seq_sel_07 = TREND_SEL;
   string seq_sel_10 = TREND_SEL;
   string seq_sel_20 = TREND_SEL;

   for(int i = 0; i < 3; i++)
     {
      // BUY
      if(ma07[i] < ma07[i + 1])
         seq_buy_07 = "";
      if(ma10[i] < ma10[i + 1])
         seq_buy_10 = "";
      if(ma20[i] < ma20[i + 1])
         seq_buy_20 = "";

      //SEL
      if(ma07[i] > ma07[i + 1])
         seq_sel_07 = "";
      if(ma10[i] > ma10[i + 1])
         seq_sel_10 = "";
      if(ma20[i] > ma20[i + 1])
         seq_sel_20 = "";
     }
   string trend_ma07_vs10 = ma07[0] > ma10[0] ? TREND_BUY : TREND_SEL;
   string trend_ma10_vs20 = ma10[0] > ma20[0] ? TREND_BUY : TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10 == TREND_BUY && seq_buy_20 == TREND_BUY)
      trend_ma1020 = TREND_BUY;
   if(seq_buy_10 == TREND_BUY && trend_ma10_vs20 == TREND_BUY)
      trend_ma1020 = TREND_BUY;


   if(seq_sel_10 == TREND_SEL && seq_sel_20 == TREND_SEL)
      trend_ma1020 = TREND_SEL;

   if(seq_sel_10 == TREND_SEL && trend_ma10_vs20 == TREND_SEL)
      trend_ma1020 = TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10 == TREND_BUY && seq_buy_07 == TREND_BUY)
      trend_ma0710 = TREND_BUY;
   if(seq_buy_07 == TREND_BUY && trend_ma07_vs10 == TREND_BUY)
      trend_ma0710 = TREND_BUY;
   if(closePrices[2] > ma07[2] && closePrices[1] > ma07[1] &&
      closePrices[2] > ma10[2] && closePrices[1] > ma10[1])
      trend_ma0710 = TREND_BUY;

   if(seq_sel_10 == TREND_SEL && seq_sel_07 == TREND_SEL)
      trend_ma0710 = TREND_SEL;
   if(seq_sel_07 == TREND_SEL && trend_ma07_vs10 == TREND_SEL)
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
double calc_average_candle_height(ENUM_TIMEFRAMES timeframe, string symbol, int length)
  {
   int count = 0;
   double totalHeight = 0.0;

   for(int i = 0; i < length; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      count += 1;
      totalHeight += candleHeight;
     }

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double averageHeight = NormalizeDouble(totalHeight / count, digits);

   return averageHeight;
  }
//+------------------------------------------------------------------+
string get_trend_reverse(string TREND)
  {
   if(is_same_symbol(TREND, TREND_BUY))
      return TREND_SEL;

   if(is_same_symbol(TREND, TREND_SEL))
      return TREND_BUY;

   return "";
  }
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int totalObjects = ObjectsTotal();
   for(int i = 0; i < totalObjects - 1; i++)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
      ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteArrowObjects()
  {
   int totalObjects = ObjectsTotal();
   for(int i = 0; i < totalObjects - 1; i++)
     {
      string objectName = ObjectName(0, i);
      if((ObjectType(objectName) == OBJ_ARROW) || is_same_symbol(objectName, "#"))
         ObjectDelete(0, objectName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjectsByName(string name)
  {
   int totalObjects = ObjectsTotal();
   for(int i = 0; i < totalObjects - 1; i++)
     {
      string objectName = ObjectName(0, i);
      if(is_same_symbol(objectName, name))
         ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_simple(
   const string            name="Text",
   string                  label="Label",
   double                  price = 0,
   color                   clrColor = clrBlack
)
  {
   ObjectDelete(0, name);
   datetime time_to=TimeCurrent();                   // anchor point time
   TextCreate(0,name, 0, time_to, price, "        " + label, clrColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const string            TRADING_TREND="",
   const bool              trim_text = true,
   const int               font_size=8,
   const bool              is_bold = false,
   const int               sub_window = 0
)
  {
   ObjectDelete(0, name);
   color clr_color = TRADING_TREND==TREND_BUY ? clrBlue : TRADING_TREND==TREND_SEL ? clrRed : clrBlack;
   TextCreate(0,name, sub_window, time_to, price, trim_text ? " " + label : "        " + label, clr_color);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   if(is_bold)
      ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                string                  text="Text",              // the text itself
                const color             clr=clrRed,               // color
                const string            font="Arial",             // font
                const int               font_size=8,              // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,       // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,              // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__, ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetString(0,name,OBJPROP_TEXT, text);
   ObjectSetString(0,name,OBJPROP_FONT, font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(0,name,OBJPROP_ANGLE, angle);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0,name,OBJPROP_COLOR, clr);
   ObjectSetInteger(0,name,OBJPROP_BACK, back);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTED, selection);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER, z_order);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_pivot(ENUM_TIMEFRAMES TIMEFRAME, string symbol, int size = 20)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_pivot(symbol, TIMEFRAME, index);
     }
   double tf_amp = total_amp / size;

   return NormalizeDouble(tf_amp, digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_pivot(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int tf_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double tf_hig = iHigh(symbol,  TIMEFRAME, tf_index);
   double tf_low = iLow(symbol,   TIMEFRAME, tf_index);
   double tf_clo = iClose(symbol, TIMEFRAME, tf_index);

   double w_pivot    = format_double((tf_hig + tf_low + tf_clo) / 3, digits);
   double tf_s1    = format_double((2 * w_pivot) - tf_hig, digits);
   double tf_s2    = format_double(w_pivot - (tf_hig - tf_low), digits);
   double tf_s3    = format_double(tf_low - 2 * (tf_hig - w_pivot), digits);
   double tf_r1    = format_double((2 * w_pivot) - tf_low, digits);
   double tf_r2    = format_double(w_pivot + (tf_hig - tf_low), digits);
   double tf_r3    = format_double(tf_hig + 2 * (w_pivot - tf_low), digits);

   double tf_amp = MathAbs(tf_s3 - tf_s2)
                   + MathAbs(tf_s2 - tf_s1)
                   + MathAbs(tf_s1 - w_pivot)
                   + MathAbs(w_pivot - tf_r1)
                   + MathAbs(tf_r1 - tf_r2)
                   + MathAbs(tf_r2 - tf_r3);

   tf_amp = format_double(tf_amp / 6, digits);

   return NormalizeDouble(tf_amp, digits);
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   OnTimer();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteAvgAmpToFile()
  {
   string arr_symbol[] =
     {
      "XAUUSD"
      //, "XAGUSD", "USOIL", "BTCUSD",
      //"USTEC", "US30", "US500", "DE30", "UK100", "FR40", "AUS200",
      //"AUDCHF", "AUDNZD", "AUDUSD",
      //"AUDJPY", "CHFJPY", "EURJPY", "GBPJPY", "NZDJPY", "USDJPY",
      //"EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURNZD", "EURUSD",
      //"GBPCHF", "GBPNZD", "GBPUSD",
      //"NZDCAD", "NZDUSD",
      //"USDCAD", "USDCHF"
     };

   /*
      (.*)(W1)(.*)(D1)(.*)(H4)(.*)(H1)(.*)
      if(is_same_symbol(symbol, "\1")){amp_w1 = \3;amp_d1 = \5;amp_h4 = \7;amp_h1 = \9;return;}
   */

//XAUUSD W1    57.145   D1    21.409   H4    9.345 H1    6.118 M15    4.136   M5    2.763;
//XAUUSD W1    57.145   D1    21.409   H4    8.216 H1    1.132 M15    0.187   M5    0.047;

   string file_name = "AvgAmp.txt";
   int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         string file_contents = symbol
                                + "\t" + "W1: " + (string) calc_average_candle_height(PERIOD_W1, symbol, 20)
                                + "\t" + "D1: " + (string) calc_average_candle_height(PERIOD_D1, symbol, 60)
                                + "\t" + "H4: " + (string) calc_average_candle_height(PERIOD_H4, symbol, 360)
                                + "\t" + "H1: " + (string) calc_average_candle_height(PERIOD_H1, symbol, 720)
                                + "\t" + "M15: " + (string) calc_average_candle_height(PERIOD_M15, symbol, 720)
                                + "\t" + "M5: " + (string) calc_average_candle_height(PERIOD_M5, symbol, 720)
                                + ";\n";

         FileWriteString(fileHandle, file_contents);
        }
      FileClose(fileHandle);
     }

//XAUUSD W1    32.289   D1    10.591   H4    4.677 H1    3.061 M15    2.067   M5    1.382;
//XAUUSD W1    28.11    D1    10.591   H4    4.107 H1    0.566 M15    0.093   M5    0.024;

   file_name = "AvgPivot.txt";
   fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         string file_contents = symbol
                                + "\t" + "W1: " + (string) calc_avg_pivot(PERIOD_W1, symbol, 20)
                                + "\t" + "D1: " + (string) calc_avg_pivot(PERIOD_D1, symbol, 60)
                                + "\t" + "H4: " + (string) calc_avg_pivot(PERIOD_H4, symbol, 360)
                                + "\t" + "H1: " + (string) calc_avg_pivot(PERIOD_H1, symbol, 720)
                                + "\t" + "M15: " + (string) calc_avg_pivot(PERIOD_M15, symbol, 720)
                                + "\t" + "M5: " + (string) calc_avg_pivot(PERIOD_M5, symbol, 720)
                                + ";\n";

         FileWriteString(fileHandle, file_contents);
        }
      FileClose(fileHandle);
     }

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createButton(string objName, string text, int x, int y, int width, int height, color clrTextColor, color clrBackground, int font_size=7, int sub_window = 0)
  {
   long chart_id=0;
   ObjectDelete(chart_id, objName);
   ResetLastError();
   if(!ObjectCreate(chart_id, objName, OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }

   ObjectSetString(chart_id,  objName, OBJPROP_TEXT, text);
   ObjectSetInteger(chart_id, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_id, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_id, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_id, objName, OBJPROP_YSIZE, height);
   ObjectSetInteger(chart_id, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(chart_id, objName, OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_id, objName, OBJPROP_COLOR, clrTextColor);
   ObjectSetInteger(chart_id, objName, OBJPROP_BGCOLOR, clrBackground);
   ObjectSetInteger(chart_id, objName, OBJPROP_BORDER_COLOR, clrSilver);
   ObjectSetInteger(chart_id, objName, OBJPROP_BACK, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_STATE, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_SELECTED, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_HIDDEN, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_ZORDER, 999);

   return(true);
  }

//+-----------------------------------------------------------------+
//| Creates Label object on the chart

//| int Yt[3]= {50, 350, 200}, Xt[3]= {110, 110, 110};
//| color textColor=White;
//| ObjectCreateEx("_Benefit_t1_body", Yt[0]-30, Xt[0]-5, 23, 0, true);
//| ObjectSetText("_Benefit_t1_body", "ggg", 110, "Webdings", C'62,62,62'); //Òåëî òàáëèöû áàåâ
//| ObjectCreateEx("_Benefit_t1_Header", Yt[0]-25, Xt[0]+110, 23, 0);
//| ObjectSetText("_Benefit_t1_Header", "BUY-SIDE", 16, "Dungeon", White); //Çàãîëîâîê Buy
//| ObjectCreateEx("_Benefit_t1_1_1", Yt[0], Xt[0], 23, 0);
//| ObjectSetText("_Benefit_t1_1_1", "Orders: "+DoubleToStr(buys, 0), 10, "Courier New", textColor);
//+-----------------------------------------------------------------+
void ObjectCreateEx(string objname,int YOffset, int XOffset=0, string lable="Text", color textColor=White,bool background=false)
  {
   int objType=23, corner=0;
   bool needNUL=false;
   if(ObjectFind(objname)==-1)
     {
      needNUL=true;
      ObjectCreate(objname,objType,0,0,0,0,0);
     }

   ObjectSet(objname,103,YOffset);
   ObjectSet(objname,102,XOffset);
   ObjectSet(objname,101,corner);
   ObjectSet(objname, OBJPROP_BACK, background);
   if(needNUL)
      ObjectSetText(objname,"",14,"Tahoma",Gray);

   ObjectSetText(objname, lable, 10, "Courier New", textColor);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcPotentialTradeProfit(string symbol, int orderType, double orderOpenPrice, double orderTakeProfitPrice, double orderLots)
  {
   if(orderTakeProfitPrice == 0)
      return 0;

   double   tradeTickValuePerLot    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);  //Loss/Gain for a 1 tick move with 1 lot
   double   tickValueBasedOnLots    = tradeTickValuePerLot * orderLots;
   double   priceDifference         = MathAbs(orderOpenPrice - orderTakeProfitPrice);
   int      pointsDifference        = (int)(priceDifference / Point);
   double   potentialProfit         = tickValueBasedOnLots * pointsDifference;

   if(orderType==OP_BUY)
      potentialProfit         = orderTakeProfitPrice > orderOpenPrice ? potentialProfit : -potentialProfit;

   if(orderType==OP_SELL)
      potentialProfit         = orderTakeProfitPrice > orderOpenPrice ? -potentialProfit : potentialProfit;

   return NormalizeDouble(potentialProfit, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_name()
  {
   return BOT_SHORT_NM;

   string trader_name = BOT_SHORT_NM + "{^" + (string)(0) + "^}_";
   return trader_name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_manually(string TREND)
  {
   string name = TREND == TREND_BUY ? "B" : "S";
   string trader_name = BOT_SHORT_NM + "{^" + name + "^}_";
   return trader_name;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_candlestick(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[], int length = 15)
  {
   ArrayResize(candleArray, length+5);
   for(int index = length + 3; index >= 0; index--)
     {
      datetime          time  = iTime(symbol, TIME_FRAME, index);    // Thời gian
      double            open  = iOpen(symbol, TIME_FRAME, index);    // Giá mở
      double            high  = iHigh(symbol, TIME_FRAME, index);    // Giá cao
      double            low   = iLow(symbol, TIME_FRAME, index);      // Giá thấp
      double            close = iClose(symbol, TIME_FRAME, index);  // Giá đóng
      string            trend = "";
      if(open < close)
         trend = TREND_BUY;
      if(open > close)
         trend = TREND_SEL;

      CandleData candle(time, open, high, low, close, trend, 0, 0, "", 0, "", "", "", 0, "", 0, "", "");
      candleArray[index] = candle;
     }


   for(int index = length + 3; index >= 0; index--)
     {
      CandleData cancle_i = candleArray[index];

      int count_trend = 1;
      for(int j = index+1; j < length; j++)
        {
         if(cancle_i.trend_heiken == candleArray[j].trend_heiken)
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
void get_arr_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[], int length = 15, bool is_calc_ma10 = true)
  {
   bool check_seq = false;
   if(TIME_FRAME == PERIOD_H4 || TIME_FRAME == PERIOD_H1)
     {
      length = 50;
      check_seq = true;
     }

   ArrayResize(candleArray, length+5);
     {
      datetime pre_HaTime = iTime(symbol, TIME_FRAME, length+4);
      double pre_HaOpen = iOpen(symbol, TIME_FRAME, length+4);
      double pre_HaHigh = iHigh(symbol, TIME_FRAME, length+4);
      double pre_HaLow = iLow(symbol, TIME_FRAME, length+4);
      double pre_HaClose = iClose(symbol, TIME_FRAME, length+4);
      string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

      CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0, 0, "", 0, "", "", "", 0, "", 0, "", "");
      candleArray[length+4] = candle;
     }

   for(int index = length + 3; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen  = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh  = MathMax(MathMax(haOpen, haClose), iHigh(symbol, TIME_FRAME, index));
      double haLow   = MathMin(MathMin(haOpen, haClose),  iLow(symbol, TIME_FRAME, index));
      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_heiken = 1;
      for(int j = index+1; j < length; j++)
        {
         if(haTrend == candleArray[j].trend_heiken)
            count_heiken += 1;
         else
            break;
        }

      CandleData candle_x(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_heiken, 0, "", 0, "", "", "", 0, "", 0, "", "");
      candleArray[index] = candle_x;
     }

   double lowest = 0.0, higest = 0.0;
   int range = 7;
   if(TIME_FRAME == PERIOD_H4)
      range = 6;
   if(TIME_FRAME == PERIOD_H1)
      range = 12;

   for(int idx = 0; idx <= range; idx++)
     {
      double low = candleArray[idx].low;
      double hig = candleArray[idx].high;
      if((idx == 0) || (lowest > low))
         lowest = low;
      if((idx == 0) || (higest < hig))
         higest = hig;
     }

   if(is_calc_ma10)
     {
      double closePrices[];
      int maLength = length+15;
      ArrayResize(closePrices, maLength);

      for(int i = maLength - 1; i >= 0; i--)
         closePrices[i] = iClose(symbol, TIME_FRAME, i);

      for(int index = ArraySize(candleArray)-2; index >= 0; index--)
        {
         CandleData pre_cancle = candleArray[index+1];
         CandleData cur_cancle = candleArray[index];

         double ma03 = cal_MA(closePrices,  3, index == 0 ? 1 : index);
         double ma05 = cal_MA(closePrices,  5, index == 0 ? 1 : index);
         double ma10 = cal_MA(closePrices, 10, index == 0 ? index : index);

         string trend_vector_ma10 = pre_cancle.ma10 < ma10 ? TREND_BUY : TREND_SEL;
         string trend_ma5vs10 = (ma05 > ma10) ? TREND_BUY : (ma05 < ma10) ? TREND_SEL : "";
         double mid = cur_cancle.close;
         string trend_by_ma05 = (mid > ma05) ? TREND_BUY : (mid < ma05) ? TREND_SEL : "";
         string trend_by_ma10 = (mid > ma10) ? TREND_BUY : (mid < ma10) ? TREND_SEL : "";
         int count_ma10 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_by_ma10 == candleArray[j].trend_by_ma10)
               count_ma10 += 1;
            else
               break;
           }

         string trend_ma3_vs_ma5 = (ma03 > ma05) ? TREND_BUY : (ma03 < ma05) ? TREND_SEL : "";
         int count_ma3_vs_ma5 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_ma3_vs_ma5 == candleArray[j].trend_ma3_vs_ma5)
               count_ma3_vs_ma5 += 1;
            else
               break;
           }

         double ma50 = 0;
         string trend_seq = "";
         if(check_seq && (index == 0))
           {
            ma50 = cal_MA(closePrices, 50, 1);

            string temp_seq = "";
            double ma20 = cal_MA(closePrices, 20, 1);

            if(0 < ma50 && lowest <= ma50 && ma50 <= higest)
              {
               string trend_ma03_vs_20 = (ma03 > ma20) ? TREND_BUY : (ma03 < ma20) ? TREND_SEL : "";
               string trend_ma10_vs_50 = (ma10 > ma50) ? TREND_BUY : (ma10 < ma50) ? TREND_SEL : "";
               if(trend_ma10_vs_50 == trend_ma03_vs_20 && trend_ma10_vs_50 == candleArray[0].trend_heiken)
                 {
                  temp_seq = trend_ma10_vs_50;
                 }
              }


            if(temp_seq != "")
              {
               double amp_w1, amp_d1, amp_h4, amp_grid_L100;
               GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

               double amp_seq = MathMax(MathAbs(ma03 - ma20),MathAbs(ma03 - ma50));
               if(amp_seq <= amp_d1)
                  trend_seq = temp_seq;
              }
           }

         string trend_ma10vs20 = "";
         if(index == 0)
           {
            double ma20 = cal_MA(closePrices, 20, 0);
            trend_ma10vs20 = (ma10 > ma20) ? TREND_BUY : (ma10 < ma20) ? TREND_SEL : "";
           }

         CandleData candle_x(cur_cancle.time, cur_cancle.open, cur_cancle.high, cur_cancle.low, cur_cancle.close, cur_cancle.trend_heiken
                             , cur_cancle.count_heiken, ma10, trend_by_ma10, count_ma10, trend_vector_ma10
                             , trend_by_ma05, trend_ma3_vs_ma5, count_ma3_vs_ma5, trend_seq, ma50, trend_ma10vs20, trend_ma5vs10);

         candleArray[index] = candle_x;
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   return candleArray[candle_index].trend_heiken;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fixed_SL_By_Account_Balance()
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   return NormalizeDouble(BALANCE*FIXED_SL_BY_PERCENT/100, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Risk_1L_By_Account_Balance()
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   return NormalizeDouble(BALANCE*RISK_BY_PERCENT/100, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Risk_Min()
  {
   double risk_1p = Risk_1L_By_Account_Balance();
   double risk_min = NormalizeDouble(risk_1p/5, 2);
   return risk_min;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_comment(string TRADER, string TRADING_TREND, int L)
  {
   string result = TRADER + TRADING_TREND + "_" + appendZero100(L);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_L(string TRADER, string trend, string last_comment)
  {
   for(int i = 1; i < 100; i++)
     {
      string comment = create_comment(TRADER, trend, i);
      if(is_same_symbol(last_comment, comment))
         return i;
     }

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetAmpAvgL15(string symbol, double &amp_w1, double &amp_d1, double &amp_h4, double &amp_grid_L100)
  {
   if(is_same_symbol(symbol, "XAUUSD"))
     {
      amp_w1 = 83.539;
      amp_d1 = 31.359;
      amp_h4 = 6.290;
      amp_grid_L100 = 5;
      return;
     }
   if(is_same_symbol(symbol, "XAGUSD"))
     {
      amp_w1 = 1.3;
      amp_d1 = 0.45;
      amp_h4 = 0.2;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USOIL"))
     {
      amp_w1 = 3.935;
      amp_d1 = 1.656;
      amp_h4 = 0.805;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      amp_w1 = 7010.38;
      amp_d1 = 2930.00;
      amp_h4 = 789.1;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USTEC"))
     {
      amp_w1 = 785.89;
      amp_d1 = 350.00;
      amp_h4 = 81.16;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "US30"))
     {
      amp_w1 = 1037.8;
      amp_d1 = 427.0;
      amp_h4 = 119.5;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "US500"))
     {
      amp_w1 = 150.5;
      amp_d1 = 64.88;
      amp_h4 = 16.93;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "DE30"))
     {
      amp_w1 = 530.6;
      amp_d1 = 156.6;
      amp_h4 = 62.3;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "UK100"))
     {
      amp_w1 = 208.25;
      amp_d1 = 68.31;
      amp_h4 = 29.0;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "FR40"))
     {
      amp_w1 = 250.00;
      amp_d1 = 100.00;
      amp_h4 = 30.00;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "JP225"))
     {
      amp_w1 = 2000.00;
      amp_d1 = 1000.00;
      amp_h4 = 700.00;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUS200"))
     {
      amp_w1 = 204.43;
      amp_d1 = 67.52;
      amp_h4 = 29.93;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDCHF"))
     {
      amp_w1 = 0.01242;
      amp_d1 = 0.00500;
      amp_h4 = 0.00158;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDNZD"))
     {
      amp_w1 = 0.01036;
      amp_d1 = 0.00495;
      amp_h4 = 0.00178;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDUSD"))
     {
      amp_w1 = 0.01267;
      amp_d1 = 0.00452;
      amp_h4 = 0.00218;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDJPY"))
     {
      amp_w1 = 2.950;
      amp_d1 = 1.165;
      amp_h4 = 0.282;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "CHFJPY"))
     {
      amp_w1 = 2.911;
      amp_d1 = 1.107;
      amp_h4 = 0.458;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURJPY"))
     {
      amp_w1 = 3.700;
      amp_d1 = 1.642;
      amp_h4 = 0.434;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPJPY"))
     {
      amp_w1 = 4.600;
      amp_d1 = 2.115;
      amp_h4 = 0.53;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "NZDJPY"))
     {
      amp_w1 = 2.419;
      amp_d1 = 1.068;
      amp_h4 = 0.272;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDJPY"))
     {
      amp_w1 = 3.550;
      amp_d1 = 1.659;
      amp_h4 = 0.427;
      amp_grid_L100 = 1.5;
      return;
     }
   if(is_same_symbol(symbol, "EURAUD"))
     {
      amp_w1 = 0.02215;
      amp_d1 = 0.00954;
      amp_h4 = 0.00417;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURCAD"))
     {
      amp_w1 = 0.01382;
      amp_d1 = 0.00562;
      amp_h4 = 0.00284;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURCHF"))
     {
      amp_w1 = 0.01309;
      amp_d1 = 0.00525;
      amp_h4 = 0.00180;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURGBP"))
     {
      amp_w1 = 0.00695;
      amp_d1 = 0.00283;
      amp_h4 = 0.00131;
      amp_grid_L100 = 0.00155;
      return;
     }
   if(is_same_symbol(symbol, "EURNZD"))
     {
      amp_w1 = 0.02402;
      amp_d1 = 0.01128;
      amp_h4 = 0.00478;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURUSD"))
     {
      amp_w1 = 0.01257;
      amp_d1 = 0.00456;
      amp_h4 = 0.00239;
      amp_grid_L100 = 0.0035;
      return;
     }
   if(is_same_symbol(symbol, "GBPCHF"))
     {
      amp_w1 = 0.01905;
      amp_d1 = 0.00752;
      amp_h4 = 0.00241;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPNZD"))
     {
      amp_w1 = 0.02912;
      amp_d1 = 0.01240;
      amp_h4 = 0.00531;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPUSD"))
     {
      amp_w1 = 0.01652;
      amp_d1 = 0.00630;
      amp_h4 = 0.00317;
      amp_grid_L100 = 0.00335;
      return;
     }
   if(is_same_symbol(symbol, "NZDCAD"))
     {
      amp_w1 = 0.01459;
      amp_d1 = 0.0055;
      amp_h4 = 0.00216;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "NZDUSD"))
     {
      amp_w1 = 0.01106;
      amp_d1 = 0.00435;
      amp_h4 = 0.0021;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      amp_w1 = 0.01328;
      amp_d1 = 0.00462;
      amp_h4 = 0.00252;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDCHF"))
     {
      amp_w1 = 0.01397;
      amp_d1 = 0.00569;
      amp_h4 = 0.00235;
      amp_grid_L100 = 0.006;
      return;
     }

   amp_w1 = calc_average_candle_height(PERIOD_W1, symbol, 20);
   amp_d1 = calc_average_candle_height(PERIOD_D1, symbol, 30);
   amp_h4 = calc_average_candle_height(PERIOD_H4, symbol, 60);
   amp_grid_L100 = amp_d1;
//SendAlert(INDI_NAME, "Get Amp Avg", " Get AmpAvg:" + (string)symbol + "   amp_w1: " + (string)amp_w1 + "   amp_d1: " + (string)amp_d1 + "   amp_h4: " + (string)amp_h4);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetGlobalVariable(string varName)
  {
   if(GlobalVariableCheck(varName))
      return GlobalVariableGet(varName);
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTodayProfitLoss()
  {
   double totalProfitLoss = 0.0; // Variable to store total profit or loss

// Get the current date
   datetime today = StringToTime(TimeToStr(TimeCurrent(), TIME_DATE)); //TIME_OF_ONE_D1_CANDLE

// Loop through closed orders in account history
   count_closed_today = 0;
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         // Check if the order was closed today
         if(OrderCloseTime() >= today)
           {
            int type = OrderType();
            if(type == OP_BUY  || type == OP_BUYLIMIT  || type == OP_BUYSTOP ||
               type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP)
              {
               totalProfitLoss += OrderProfit();
               count_closed_today += 1;
              }
           }
        }
     }

   return totalProfitLoss; // Return the total profit or loss
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string to_percent(double profit, double decimal_part = 2)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   string percent = " (" + format_double_to_string(profit/BALANCE * 100, 1) + "%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   string symbol = Symbol();
   double profit_today = CalculateTodayProfitLoss();
   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double PL=EQUITY - BALANCE;
   string percent = to_percent(profit_today);

   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

   double AMP_DC = get_AMP_DCA(symbol, PERIOD_H1);
   double risk_1L = Risk_1L_By_Account_Balance();
   double fixed_SL = Fixed_SL_By_Account_Balance();

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + cur_timeframe + ") " + Symbol();
   str_comments += "    Risk: " + get_profit_percent(risk_1L);
//str_comments += "    Fixed_SL: " + get_profit_percent(fixed_SL);
   str_comments += "    Min: " + DoubleToStr(Risk_Min(), 2) + "$ Exit >= " + (string)START_EXIT_L + "L";
   str_comments += "    Init: " + (string)INIT_VOLUME + " lot.";

   str_comments += "    Closed(today): " + format_double_to_string(profit_today, 2) + "$"
                   + " (" + format_double_to_string(profit_today*25500/1000000, 2) + " tr)" + percent + "/" + (string) count_closed_today + "L";
   str_comments += "    Opening: " + (string)(int)PL + "$" + to_percent(PL)
                   + " (" + format_double_to_string(PL*25500/1000000, 2) + " tr)";

   str_comments += "\n";
   str_comments += "    Amp(H4): " + format_double_to_string(amp_h4, digits);
   str_comments += "    Amp(D1): " + format_double_to_string(amp_d1, digits);
   str_comments += "    Amp(W1): " + format_double_to_string(amp_w1, digits);
   str_comments += "\n";
   str_comments += "    m.L.B: " + AppendSpaces((string)(int)GetGlobalVariable(MAX_L_BUY), 3, false) + "L";
   str_comments += "    m.Amp.B: " + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_AMP_BUY),2), 7, false);
   str_comments += "    m.TP.B: "  + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_TP_BUY), 2), 7, false) + "$";
   str_comments += "    m.DD.B: "  + AppendSpaces(get_profit_percent(GetGlobalVariable(MAX_DD_BUY)), 7, false) + "$ ";
   str_comments += "\n";
   str_comments += "    m.L.S: " + AppendSpaces((string)(int)GetGlobalVariable(MAX_L_SEL), 3, false) + "L";
   str_comments += "    m.Amp.S: " + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_AMP_SEL),2), 7, false);
   str_comments += "    m.TP.S: "  + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_TP_SEL), 2), 7, false) + "$";
   str_comments += "    m.DD.S: "  + AppendSpaces(get_profit_percent(GetGlobalVariable(MAX_DD_SEL)), 7, false) + "$";

   return str_comments;
  }
//+------------------------------------------------------------------+
