//+------------------------------------------------------------------+
//|                                                    AutoTrade.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;

#define BComment "BComment"
#define BtnClosePosision "ButtonClosePosision"
#define BtnCloseOrder "ButtonCloseOrder"
#define BtnTrade "ButtonTrade"
#define BtnOrderBuy "ButtonOrderBuy"
#define BtnOrderSell "ButtonOrderSell"

double dbRiskRatio = 0.02; // Rủi ro 2% = 20$/lệnh
double INIT_EQUITY = 1000.0; // Vốn đầu tư

string INDICES = "_USTEC_US30_US500_DE30_UK100_FR40_AUS200_BTCUSD_";

string arr_main_symbol[] = {"DXY", "XAUUSD", "BTCUSD", "USOIL", "US30", "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};

string INDI_NAME = "AutoTrade";
string FILE_NAME_ANGEL_LOG = "Exness.log";

//string free_extended_overnight_fees[] =
//  {
//   "XAUUSD"
//   , "AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY"
//   , "AUDNZD", "EURCHF", "GBPJPY", "AUDCHF", "AUDJPY"
//   , "EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD"
//   , "GBPCHF", "GBPNZD"
//   , "NZDJPY", "NZDCAD"
//  };

string free_extended_overnight_fees[] = {"GBPJPY"};


//Delete: "AUDCAD", "CADCHF", "CADJPY", "GBPAUD", "GBPCAD", "NZDCHF",
//BB: "EURGBP", "EURUSD", "GBPUSD"

//Exness_Pro
//string arr_symbol[] =
//  {
//   "XAUUSD", "XAGUSD", "USOIL", "BTCUSD",
//   "USTEC", "US30", "US500", "DE30", "UK100", "FR40", "AUS200",
//   "AUDCHF", "AUDNZD", "AUDUSD",
//   "AUDJPY", "CHFJPY", "EURJPY", "GBPJPY", "NZDJPY", "USDJPY",
//   "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURNZD", "EURUSD",
//   "GBPCHF", "GBPNZD", "GBPUSD",
//   "NZDCAD", "NZDUSD",
//   "USDCAD", "USDCHF"
//  };

string arr_symbol[] = {"GBPJPY"};

//Exness_Standard
//string arr_symbol[] =
//  {
//   "XAUUSDm", "XAGUSDm", "USOILm", "BTCUSDm",
//   "USTECm", "US30m", "US500m", "DE30m", "UK100m", "FR40m", "AUS200m",
//   "AUDCHFm", "AUDJPY", "AUDNZDm", "AUDUSDm",
//   "EURAUDm", "EURCADm", "EURCHFm", "EURGBPm", "EURJPYm", "EURNZDm", "EURUSDm",
//   "GBPCHFm", "GBPJPY", "GBPNZDm", "GBPUSDm",
//   "NZDCADm", "NZDJPY", "NZDUSDm",
//   "USDCADm", "USDCHFm", "USDJPYm"
//  };

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

string PREFIX_TRADE_PERIOD_MO = "Mn";
string PREFIX_TRADE_PERIOD_W1 = "W1";
string PREFIX_TRADE_PERIOD_D1 = "D1";
string PREFIX_TRADE_PERIOD_H4 = "H4";
string PREFIX_TRADE_PERIOD_H1 = "H1";
string PREFIX_TRADE_PERIOD_M5 = "M5";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SWITH_TREND_TYPE_DOJI   = "(Dj)";
string SWITH_TREND_TYPE_HEIKEN = "(Ha)";
string SWITH_TREND_TYPE_STOCH  = "(Oc)";
string SWITH_TREND_TYPE_MA67   = "(07)";
string SWITH_TREND_TYPE_MA10   = "(10)";
string SWITH_TREND_TYPE_MA20   = "(20)";
string SWITH_TREND_TYPE_SEQ    = "(Sq)";

string ENTRY_TRADE_BY_STOC_X = "_AT_byStoc";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OPEN_TRADE = "(OPEN_TRADE)";
string STOP_TRADE = "(STOP_TRADE)";
string OPEN_ORDERS = "(OPEN_ORDER)    ";
string STOP_LOSS = "(STOP_LOSS)";
string AUTO_TRADE  = "(AUTO_TRADE)";

string TRADE_COUNT_ORDER = " Order";
string TRADE_COUNT_ORDER_B = TRADE_COUNT_ORDER + " (B):";
string TRADE_COUNT_ORDER_S = TRADE_COUNT_ORDER + " (S):";
string TRADE_COUNT_POSITION = " Position";
string TRADE_COUNT_POSITION_B = TRADE_COUNT_POSITION + " (B):";
string TRADE_COUNT_POSITION_S = TRADE_COUNT_POSITION + " (S):";

string FILE_NAME_OPEN_TRADE = "_open_trade_today.txt";
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
string FILE_NAME_ALERT_MSG = "_alert_today.txt";
string FILE_NAME_BUTTONS = "_buttons.log";
string FILE_NAME_BUTTONS_FOOTER = "_buttons_footer.log";
string FILE_NAME_BUTTONS_WDH4 = "_buttons_wdh4.log";

//iStochastic
int periodK = 5;
int periodD = 3;
int slowing = 3;

bool DEBUG_ON_HISTORY_DATA = IS_DEBUG_MODE;
bool ALLOW_AUTO_TRADE = true;

string trend_w3331 = "";
string candle_switch_trend_d8 = "";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_trade.SetExpertMagicNumber(20240304);
   Comment(GetComments());

   DeleteAllObjects();

   Draw_Heikens();


   if(DEBUG_ON_HISTORY_DATA)
     {
      TestInitIndicator();
     }
   else
     {
      Draw_Bottom_Msg();
      DrawIndicators();
     }

//WriteNotifyToken();

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(IsMarketClose())
      return;

   if(DEBUG_ON_HISTORY_DATA)
      TestInitIndicator();

   WriteNotifyToken();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StopTrade(string symbol)
  {
   double risk = calcRisk();
   int count_possion_buy = 0, count_possion_sel = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            string TRADING_TREND = "";
            ulong ticket = m_position.Ticket();
            double profit = m_position.Profit();
            double price_open = m_position.PriceOpen();
            bool has_profit_1R = (profit > risk);
            bool has_profit_1usd = (profit > 1);
            double amp_sl = get_default_amp_trade(symbol);
            double price = SymbolInfoDouble(symbol, SYMBOL_BID);

            bool pass_hold_min_time = false;
            double time_diff_buy_hours = (double)(TimeCurrent() - m_position.Time()) / (60 * 60);
            if(time_diff_buy_hours > 8.0)
               pass_hold_min_time = true;

            double number_of_days = NormalizeDouble(time_diff_buy_hours / 24, 1);


            bool is_w1_trade = false;
            if(StringFind(m_position.Comment(), ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_W1) >= 0)
               is_w1_trade = true;

            bool is_d1_trade = false;
            if(StringFind(m_position.Comment(), ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_D1) >= 0)
               is_d1_trade = true;

            bool is_h4_trade = false;
            if(StringFind(m_position.Comment(), ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_H4) >= 0)
               is_h4_trade = true;

            bool is_m5_trade = false;
            if(StringFind(m_position.Comment(), ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_M5) >= 0)
               is_m5_trade = true;

            bool is_first = StringFind(m_position.Comment(), ENTRY_TRADE_BY_STOC_X) >= 0;
            string trend_by_hei_w1_1 = get_trend_by_heiken(symbol, PERIOD_W1, 1);
            string trend_by_hei_h1_0 = get_trend_by_heiken(symbol, PERIOD_H1, 0);
            // ----------------------------AUTO_TRADE----------------------------

            if(StringFind(toLower(m_position.TypeDescription()), "buy") >= 0)
              {
               count_possion_buy += 1;
               TRADING_TREND = TREND_BUY;
              }

            if(StringFind(toLower(m_position.TypeDescription()), "sel") >= 0)
              {
               count_possion_sel += 1;
               TRADING_TREND = TREND_SEL;
              }

            // ----------------------------CLOSE_TRADE_H4----------------------------
            if(is_h4_trade && pass_hold_min_time)
              {
               bool is_opening = true;

               if(trend_by_hei_w1_1 != TRADING_TREND && trend_by_hei_h1_0 != TRADING_TREND)
                 {
                  string trend_w3 = get_trend_by_stoc2(symbol, PERIOD_W1, 3, 3, 3, 1);
                  string ctrend_d8 = get_candle_switch_trend_stoch(symbol, PERIOD_D1, 8, 5, 3);
                  if(StringFind(ctrend_d8, TRADING_TREND) <= 0 && trend_w3 != TRADING_TREND)
                    {
                     is_opening = false;
                     ClosePosition(symbol, TRADING_TREND, ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_H4);
                    }
                 }

               if(is_opening && TRADING_TREND == TREND_BUY)
                  if(has_profit_1R && is_must_exit_trade_by_stoch(symbol, PERIOD_D1, TREND_BUY))
                     if(is_must_exit_trade_by_stoch(symbol, PERIOD_H4, TREND_BUY))
                        if(is_must_exit_trade_by_stoch(symbol, PERIOD_M5, TREND_BUY))
                          {
                           is_opening = false;
                           ClosePosition(symbol, TREND_BUY, ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_H4);
                          }


               if(is_opening && TRADING_TREND == TREND_SEL)
                  if(has_profit_1R && is_must_exit_trade_by_stoch(symbol, PERIOD_D1, TREND_SEL))
                     if(is_must_exit_trade_by_stoch(symbol, PERIOD_H4, TREND_SEL))
                        if(is_must_exit_trade_by_stoch(symbol, PERIOD_M5, TREND_SEL))
                          {
                           is_opening = false;
                           ClosePosition(symbol, TREND_SEL, ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_H4);
                          }

              }

            // ----------------------------CLOSE_TRADE_W1----------------------------
            if(has_profit_1R && pass_hold_min_time)
              {
               if(is_first && number_of_days > 21 && TRADING_TREND == TREND_BUY)
                  if(is_must_exit_trade_by_stoch(symbol, PERIOD_D1, TREND_BUY))
                     if(is_must_exit_trade_by_stoch(symbol, PERIOD_H4, TREND_BUY))
                        ClosePosition(symbol, TREND_BUY, "");

               if(is_first && number_of_days > 21 && TRADING_TREND == TREND_SEL)
                  if(is_must_exit_trade_by_stoch(symbol, PERIOD_D1, TREND_SEL))
                     if(is_must_exit_trade_by_stoch(symbol, PERIOD_H4, TREND_SEL))
                        ClosePosition(symbol, TREND_SEL, "");

               if(TRADING_TREND == TREND_BUY)
                  if(is_continue_hode_postion_by_ma_7_10_20(symbol, PERIOD_H4, TREND_BUY) == false)
                     if(is_must_exit_trade_by_stoch(symbol, PERIOD_W1, TREND_BUY))
                        if(is_must_exit_trade_by_stoch(symbol, PERIOD_D1, TREND_BUY))
                           ClosePosition(symbol, TREND_BUY, "");

               if(TRADING_TREND == TREND_SEL)
                  if(is_continue_hode_postion_by_ma_7_10_20(symbol, PERIOD_H4, TREND_SEL) == false)
                     if(is_must_exit_trade_by_stoch(symbol, PERIOD_W1, TREND_SEL))
                        if(is_must_exit_trade_by_stoch(symbol, PERIOD_D1, TREND_SEL))
                           ClosePosition(symbol, TREND_SEL, "");
              }


            // ----------------------------STOP_LOSS----------------------------
            if(profit + risk < 0 && pass_hold_min_time)
              {
               int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
               double price = SymbolInfoDouble(symbol, SYMBOL_BID);


               double volume = get_default_volume(symbol);
               double new_volume = m_position.Volume()*2;
               string note = (string) NormalizeDouble(new_volume / volume, 1);
               string count = (string) NormalizeDouble(MathLog(new_volume / volume) / MathLog(2), 1);

               if(TRADING_TREND == TREND_BUY && count_possion_buy == 1)
                 {
                  double sl = price_open - amp_sl;
                  if(sl > price)
                    {
                     if(trend_by_hei_h1_0 == TRADING_TREND)
                        if(is_allow_trade_now_by_stoc(symbol, PERIOD_W1, TRADING_TREND))
                          {
                           if(m_trade.Buy(new_volume, symbol, 0.0, 0.0, m_position.PriceOpen(), "MK_B"+count+"_AT_X" + note))
                             {
                              CloseOrders(symbol);
                              m_trade.PositionClose(ticket);
                              SendTelegramMessage(symbol, STOP_LOSS + TRADING_TREND, STOP_LOSS + "   " + TRADING_TREND + "   " + symbol + "   P: " + (string) profit + "$");
                             }
                          }

                    }
                 }

               if(TRADING_TREND == TREND_SEL && count_possion_sel == 1)
                 {
                  double sl = price_open + amp_sl;
                  if(sl < price)
                    {
                     string trend_by_hei_h1_1 = get_trend_by_heiken(symbol, PERIOD_H1, 0);
                     if(trend_by_hei_h1_1 == TRADING_TREND)
                        if(is_allow_trade_now_by_stoc(symbol, PERIOD_W1, TRADING_TREND))
                          {
                           if(m_trade.Sell(m_position.Volume()*2, symbol, 0.0, 0.0, m_position.PriceOpen(), "MK_S"+count+"_AT_X" + note))
                             {
                              CloseOrders(symbol);
                              m_trade.PositionClose(ticket);
                              SendTelegramMessage(symbol, STOP_LOSS + TRADING_TREND, STOP_LOSS + "   " + TRADING_TREND + "   " + symbol + "   P: " + (string) profit + "$");
                             }
                          }

                    }
                 }
              }
            // ----------------------------STOP_LOSS----------------------------

           }
        }
     } // End For PositionsTotal
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteNotifyToken()
  {
   double risk_per_trade = calcRisk();

   string all_lines = "";
   string pre_symbol_prifix = "A";

   uint line_length = 380;
   string hyphen_line = "";
   for(uint j = 0; j < line_length; j++)
      hyphen_line += "-";

   string msg_list_am[];
   string msg_list_tp[];

   string msg_list_w1[];
   string msg_list_d1[];
   string msg_list_h4[];
   string msg_list_h1[];

   string msg_need_2_close[];
   string msg_list_trading[];

   string trade_amp_21w = "";
   string arr_buttons_footer[];
   string arr_buttons_d13h413[];
//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
   int total_fx_size = ArraySize(arr_symbol);
   for(int index = 0; index < total_fx_size; index++)
     {
      string symbol = arr_symbol[index];
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double price = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID), digits);
      string tradingview_symbol = get_tradingview_symbol(symbol);

      if(DEBUG_ON_HISTORY_DATA)
         if(free_overnight(tradingview_symbol) == "")
            continue;

      double dic_top_price;
      double dic_amp_w;
      double dic_avg_candle_week;
      double dic_amp_init_d1;
      GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
      double week_amp = dic_amp_w;

      double volume = dblLotsRisk(symbol, week_amp, risk_per_trade);
      string str_volume = AppendSpaces(format_double_to_string(volume, 2), 5) +  "lot/" + AppendSpaces((string) NormalizeDouble(risk_per_trade, 0), 3, false) + "$";
      StringReplace(str_volume, ".0$", "$");
      //------------------------------------------------------------------

      string str_count_trade = CountTrade(symbol);
      bool has_order_buy = StringFind(str_count_trade, TRADE_COUNT_ORDER_B) >= 0;
      bool has_order_sel = StringFind(str_count_trade, TRADE_COUNT_ORDER_S) >= 0;
      bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
      bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;

      if(has_position_buy || has_position_sel)
        {
         StopTrade(symbol);
        }


      //string trend_w13_by_stoc = get_trend_by_stoc2(symbol, PERIOD_W1, 13, 8, 5, 0);
      CandleData arr_candle_w1[];
      get_arr_heiken(symbol, PERIOD_W1, arr_candle_w1);
      string trend_by_hei_w1_0 = arr_candle_w1[0].trend;
      string trend_by_hei_w1_1 = arr_candle_w1[1].trend;

      CandleData arr_candle_d1[];
      get_arr_heiken(symbol, PERIOD_D1, arr_candle_d1);
      string trend_by_hei_d1_0 = arr_candle_d1[0].trend;
      string trend_by_hei_d1_1 = arr_candle_d1[1].trend;
      string trend_by_vec_d1_ma6 = get_trend_by_vector_ma(symbol, PERIOD_D1, 6);

      CandleData arr_candle_h4[];
      get_arr_heiken(symbol, PERIOD_H4, arr_candle_h4);
      string trend_by_hei_h4_0 = arr_candle_h4[0].trend;
      string trend_by_hei_h4_1 = arr_candle_h4[1].trend;

      string trend_by_hei_h1_1 = get_trend_by_heiken(symbol, PERIOD_H1, 1);

      bool h4h1_allow_trade = (trend_by_hei_h4_1 == trend_by_hei_d1_0) &&
                              (trend_by_hei_h4_1 == trend_by_hei_h4_0) &&
                              (trend_by_hei_h4_1 == trend_by_hei_h1_1);

      string trend_by_ma50_05 = get_trend_by_ma50(symbol, PERIOD_M5);
      string trend_by_hei_05 = get_trend_by_heiken(symbol, PERIOD_M5);
      bool minus_allow_trade = (trend_by_hei_h4_1 == trend_by_ma50_05) &&
                               (trend_by_hei_h4_1 == trend_by_hei_05);


      bool required_follow_weekly_trends_symbols = false;
      if(is_same_symbol(symbol, "JPY") || is_same_symbol(symbol, "BTC"))
         required_follow_weekly_trends_symbols = true;

      trend_w3331 = get_trend_by_stoc2(symbol, PERIOD_W1, 3, 3, 3, 1);
      candle_switch_trend_d8 = get_candle_switch_trend_stoch(symbol, PERIOD_D1, 8, 5, 3);

      bool is_first_candle = StringFind(candle_switch_trend_d8, "(1)") >= 0;

      if(trend_w3331 == trend_by_hei_d1_0 && trend_w3331 == trend_by_hei_h4_0)
         if(is_first_candle && StringFind(candle_switch_trend_d8, trend_w3331) >= 0)
           {
            if((has_position_buy == false && trend_w3331 == TREND_BUY) ||
               (has_position_sel == false && trend_w3331 == TREND_SEL))
              {
               TestOpenTrade(symbol, trend_w3331, PREFIX_TRADE_PERIOD_H4, "");
              }
           }


      if(DEBUG_ON_HISTORY_DATA)
         return;
      //------------------------------------------------------------------

      if(false && h4h1_allow_trade && minus_allow_trade)
         if((has_position_buy == false && trend_by_hei_h4_0 == TREND_BUY && trend_by_hei_h1_1 == TREND_BUY) ||
            (has_position_sel == false && trend_by_hei_h4_0 == TREND_SEL && trend_by_hei_h1_1 == TREND_SEL))
           {
            bool has_open_trade = false;
            if(is_allow_trade_now_by_stoc(symbol, PERIOD_W1, trend_by_hei_h4_0))
               if(is_allow_trade_now_by_stoc(symbol, PERIOD_D1, trend_by_hei_h4_0))
                 {
                  string lable = PREFIX_TRADE_PERIOD_W1 + "cd0_" + (string) arr_candle_d1[0].count + "Ex" + trend_by_hei_h4_0 + " " + tradingview_symbol ;
                  if(is_allow_trade_now_by_stoc(symbol, PERIOD_M5, trend_by_hei_h4_0))
                    {
                     TestOpenTrade(symbol, trend_by_hei_h4_0, PREFIX_TRADE_PERIOD_W1, "cd0_" + (string) arr_candle_d1[0].count);
                     SendTelegramMessage(symbol, trend_by_hei_h4_0, lable);
                     has_open_trade = true;
                    }
                 }
           }


      //------------------------------------------------------------------
      double upper_d1[], middle_d1[], lower_d1[];
      CalculateBollingerBands(symbol, PERIOD_D1, upper_d1, middle_d1, lower_d1, digits, 2);
      double hi_d1 = upper_d1[0];
      double lo_d1 = lower_d1[0];

      double upper_h4[], middle_h4[], lower_h4[];
      CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 2);
      double hi_h4 = upper_h4[0];
      double lo_h4 = lower_h4[0];

      string bb_note = "";
      bool bb_allow_buy = false;
      bool bb_allow_sel = false;
      bool bb_alert = false;
      if(price <= lo_d1 || price <= lo_h4)
        {
         bb_allow_buy = true;

         bb_note += (price <= lo_d1) ? "D1":"";
         bb_note += (price <= lo_h4) ? "H4":"";
         bb_note += "(B)";

         if(price <= lo_d1 && price <= lo_h4) // && price <= lo_h1
            bb_alert = true;
        }

      if(price >= hi_d1 || price >= hi_h4)
        {
         bb_allow_sel = true;

         bb_note += (price >= hi_d1)
                    ? "D1":"";
         bb_note += (price >= hi_h4) ? "H4":"";
         bb_note += "(S)";

         if(price >= hi_d1 && price >= hi_h4) // && price >= hi_h1
            bb_alert = true;
        }

      if(bb_note != "")
         bb_note = "(BB)" + bb_note;

      //------------------------------------------------------------------

      double lowest = 0.0;
      double higest = 0.0;
      for(int i = 0; i < 21; i++)
        {
         double lowPrice = iLow(symbol, PERIOD_W1, i);
         double higPrice = iHigh(symbol, PERIOD_W1, i);

         if((i == 0) || (lowest > lowPrice))
            lowest = lowPrice;

         if((i == 0) || (higest < higPrice))
            higest = higPrice;
        }

      double rate_amp_buy = 0;
      double rate_amp_sel = 0;
      double amp_cycle_weeks = MathAbs(higest - lowest);


      bool is_allow_alert = false;
      string trend_by_amp_weeks = "";
      if((amp_cycle_weeks / week_amp) >= 3)
        {
         rate_amp_sel = MathAbs(higest - price);
         rate_amp_buy = MathAbs(lowest - price);

         if(rate_amp_sel < week_amp*1.5)
           {
            trend_by_amp_weeks = TREND_SEL;

            if(rate_amp_sel < week_amp)
               is_allow_alert = true;
           }

         if(rate_amp_buy < week_amp*1.5)
           {
            trend_by_amp_weeks = TREND_BUY;

            if(rate_amp_buy < week_amp)
               is_allow_alert = true;
           }
        }

      string trade_by_amp = "";
      if(trend_by_amp_weeks != "")
        {
         trade_amp_21w += symbol+ ";";
         trade_by_amp = AppendSpaces(trend_by_amp_weeks, 7);

         if(trend_by_amp_weeks == TREND_BUY)
           {
            trade_by_amp += "tba(" + format_double_to_string((rate_amp_buy / week_amp), 2) + ")";
            if(rate_amp_buy < week_amp)
               trade_by_amp += " * ";
           }

         if(trend_by_amp_weeks == TREND_SEL)
           {
            trade_by_amp += "tba(" + format_double_to_string((rate_amp_sel / week_amp), 2) + ")";
            if(rate_amp_sel < week_amp)
               trade_by_amp += " * ";
           }

         if(is_allow_alert && bb_alert)
           {
            string trend_by_hei_05 = get_trend_by_heiken(symbol, PERIOD_M5, 0);
            if(
               (bb_allow_buy && trend_by_amp_weeks == TREND_BUY && trend_by_hei_05 == TREND_BUY) ||
               (bb_allow_sel && trend_by_amp_weeks == TREND_SEL && trend_by_hei_05 == TREND_SEL))
              {

               //               if(h4h1_allow_trade && trend_by_amp_weeks == trend_by_hei_h4_1)
               //                  if(is_allow_trade_now_by_stoc(symbol, PERIOD_D1, trend_by_amp_weeks))
               //                     if(is_allow_trade_now_by_stoc(symbol, PERIOD_M5, trend_by_amp_weeks))
               //                       {
               //                        TestOpenTrade(symbol, trend_by_amp_weeks, "ByAmp21W(BB)" + trend_by_amp_weeks);
               //
               //                        string msg = OPEN_TRADE + bb_note + " ByAmp21W(BB): " + trend_by_amp_weeks + "    " + symbol + "    " + str_volume;
               //                        SendTelegramMessage(symbol, trend_by_amp_weeks, msg);
               //                       }


              }
           }
        }

      //--------------------------------------------------------------------------------------------------

      string tba_d1 = "";
      double rate_buy = (rate_amp_buy / week_amp);
      double rate_sel = (rate_amp_sel / week_amp);
      tba_d1 += "   Rm(B): " + format_double_to_string(rate_sel, 2);
      tba_d1 += "   Rm(S): " + format_double_to_string(rate_buy, 2);
      string rate = " B" + (string) NormalizeDouble(rate_sel, 1) + " S" + (string) NormalizeDouble(rate_buy,1);

      //--------------------------------------------------------------------------------------------------

      if(has_position_buy || has_position_sel)
        {
         string trading = "";
         if(has_position_buy)
            trading = TREND_BUY;
         if(has_position_sel)
            trading = TREND_SEL;

         int msg_index = ArraySize(msg_list_trading);
         ArrayResize(msg_list_trading, msg_index + 1);

         string msg = "(Op) " + AppendSpaces(trading, 5) + tradingview_symbol;
         msg_list_trading[msg_index] = msg + rate;

         if(trading != trend_by_hei_h1_1)
            if(is_must_exit_trade_by_stoch(symbol, PERIOD_H4, trading))
              {
               bool has_profit = (StringFind(str_count_trade, "-") >= 0) ? false : true;
               if(has_profit)
                 {
                  string msg = "(TP) " + AppendSpaces(trading, 5) + tradingview_symbol;
                  int msg_index = ArraySize(msg_list_tp);
                  ArrayResize(msg_list_tp, msg_index + 1);
                  msg_list_tp[msg_index] = msg;
                 }

               ClosePosition_TakeProfit(symbol, trading, "");
              }

         if(
            trading != trend_by_hei_d1_1 && trading != trend_by_hei_d1_0 &&
            trading != trend_by_hei_h4_1 && trading != trend_by_hei_h4_0 &&
            trading != trend_by_hei_h1_1)
            ClosePosition_TakeProfit(symbol, trading, "");

         string msg_close = "";
         if(trading != trend_by_hei_d1_1 && trading != trend_by_hei_d1_0 && trading != trend_by_hei_h4_0 && trading != trend_by_hei_h1_1)
           {
            msg_close = "(X) " + AppendSpaces(trading, 5) + tradingview_symbol;
           }

         if(has_position_buy &&
            trend_by_amp_weeks == TREND_SEL &&
            trend_by_hei_h4_1 == TREND_SEL &&
            trend_by_hei_h1_1 == TREND_SEL)
           {
            msg_close = "(X) " + AppendSpaces(TREND_BUY, 5) + tradingview_symbol;
           }

         if(has_position_sel &&
            trend_by_amp_weeks == TREND_BUY &&
            trend_by_hei_h4_1 == TREND_BUY &&
            trend_by_hei_h1_1 == TREND_BUY)
           {
            msg_close = "(X) " + AppendSpaces(TREND_SEL, 5) + tradingview_symbol;
           }

         if(msg_close != "")
           {
            int msg_index = ArraySize(msg_need_2_close);
            ArrayResize(msg_need_2_close, msg_index + 1);
            msg_need_2_close[msg_index] = msg_close + rate;
           }
        }

      //--------------------------------------------------------------------------------------------------
      if(bb_alert)
        {
         if(bb_allow_sel && has_position_buy)
            ClosePosition_TakeProfit(symbol, TREND_BUY, "");

         if(bb_allow_buy && has_position_sel)
            ClosePosition_TakeProfit(symbol, TREND_SEL, "");
        }

      string remain = "";
      if(has_position_buy)
         remain += " Rm(B)(" + format_double_to_string(rate_sel, 2) + ")";
      if(has_position_sel)
         remain += " Rm(S)(" + format_double_to_string(rate_buy, 2) + ")";

      string trend_swap = "";
      double swap_long  = SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG);
      double swap_short  = SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT);
      if(swap_long > swap_short*2)
         trend_swap = TREND_BUY;
      if(swap_short > swap_long*2)
         trend_swap = TREND_SEL;

      string doji = "";
      if(IsDojiHeikenAshi(symbol, PERIOD_W1, 0))
         doji += "Doji_W0   ";
      if(IsDojiHeikenAshi(symbol, PERIOD_D1, 0))
         doji += "Doji_D0   ";


      string line = "";
      line += "." + AppendSpaces((string)(index + 1), 2, false) + "   ";
      line += AppendSpaces(tradingview_symbol) + AppendSpaces(format_double_to_string(price, digits-1), 8) + " | ";
      line += AppendSpaces("Swap(B:" + AppendSpaces((string)swap_long, 7, false) + ", S:" + AppendSpaces((string)swap_short, 7, false) + ") " + trend_swap, 35);

      line += str_volume + "/" + AppendSpaces(format_double_to_string(week_amp, digits), 8, false) + "  |  ";
      line += AppendSpaces(str_count_trade, 42);
      line += " | "  + AppendSpaces(remain, 15) + AppendSpaces(trade_by_amp, 25);
      line += " | " + AppendSpaces(doji, 20);
      line += "  https://www.tradingview.com/chart/r46Q5U5a/?interval=D&symbol=" + AppendSpaces(tradingview_symbol);
      line += AppendSpaces(tba_d1, 30);

      //--------------------------------------------------------------------------------------------------
      if(StringLen(line) > 100)
        {
         if(StringFind(all_lines, tradingview_symbol) < 0)
           {
            string cur_symbol_prifix = StringSubstr(tradingview_symbol, 0, 1);
            if(pre_symbol_prifix != cur_symbol_prifix && 13 < index)
              {
               all_lines += hyphen_line + "\n";
               pre_symbol_prifix = cur_symbol_prifix;
              }

            if(index == 4 || index == 11)
               all_lines += hyphen_line + "\n";

            if(index == 38)
               all_lines += AppendSpaces(line, line_length);
            else
               all_lines += AppendSpaces(line, line_length) + "\n";
           }
        }
     }

//--------------------------------------------------------------------------------------------------
   string msgs = "";
   int trading_size = ArraySize(msg_list_trading);
   for(int i = 0; i < trading_size; i++)
      msgs += msg_list_trading[i] + ";";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int am_array_size = ArraySize(msg_list_am);
   for(int i = 0; i < am_array_size; i++)
      msgs += msg_list_am[i] + ";";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int w1_array_size = ArraySize(msg_list_w1);
   for(int i = 0; i < w1_array_size; i++)
      msgs += msg_list_w1[i] + ";";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int tp_array_size = ArraySize(msg_list_tp);
   for(int i = 0; i < tp_array_size; i++)
      msgs += msg_list_tp[i] + ";";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int d1_array_size = ArraySize(msg_list_d1);
   for(int i = 0; i < d1_array_size; i++)
      msgs += msg_list_d1[i] + ";";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int h4_array_size = ArraySize(msg_list_h4);
   for(int i = 0; i < h4_array_size; i++)
      msgs += msg_list_h4[i] + ";";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int h1_array_size = ArraySize(msg_list_h1);
   for(int i = 0; i < h1_array_size; i++)
      msgs += msg_list_h1[i] + ";";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int close_ar_size = ArraySize(msg_need_2_close);
   for(int i = 0; i < close_ar_size; i++)
      msgs += msg_need_2_close[i] + ";";

   WriteFileContent(FILE_NAME_BUTTONS, msgs);

   string footer_contents = "";
   int footer_ar_size = ArraySize(arr_buttons_footer);
   for(int i = 0; i < footer_ar_size; i++)
      footer_contents += arr_buttons_footer[i] + ";";
   WriteFileContent(FILE_NAME_BUTTONS_FOOTER, footer_contents);


   string footer_wdh4_contents = "";
   int footer_wdh4_size = ArraySize(arr_buttons_d13h413);
   for(int i = 0; i < footer_wdh4_size; i++)
      footer_wdh4_contents += arr_buttons_d13h413[i] + ";";
   WriteFileContent(FILE_NAME_BUTTONS_WDH4, footer_wdh4_contents);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   FileDelete(FILE_NAME_ANGEL_LOG);
   int nfile_draft = FileOpen(FILE_NAME_ANGEL_LOG, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);
//------------------------------------------------------------------------------------------------------------------------
// https://www.youtube.com/watch?v=ONWpoGPDvTA&ab_channel=%C4%90%E1%BB%93%C4%90%E1%BB%93ngTi%E1%BA%BFnL%E1%BB%A3i&t=15m45s
// 
// Phật dạy trong kinh tạng Nikaya - Tập 1
// https://www.youtube.com/playlist?list=PLkNi58HMveSB2UYKh-BQ1yZULORsSVQuG
// 
// Phật dạy trong kinh tạng Nikaya - Tập 2
// https://www.youtube.com/playlist?list=PLkNi58HMveSAzRsEUcrngD-Co0nBLmfq1
// 
//------------------------------------------------------------------------------------------------------------------------
   if(nfile_draft != INVALID_HANDLE)
     {
      string str_profit = get_vntime() + get_profit_today();
      FileWrite(nfile_draft, str_profit);
      FileWrite(nfile_draft, hyphen_line);
      FileWrite(nfile_draft, all_lines);
      FileWrite(nfile_draft, hyphen_line);
      FileWrite(nfile_draft, AppendSpaces("VNINDEX", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VNINDEX     VNINDEX", line_length));
                                               https://fireant.vn/ma-chung-khoan/VNINDEX
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VNM         Vinamilk", line_length));
                                               https://fireant.vn/ma-chung-khoan/DXG
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:DXG         Dat Xanh Group", line_length));
                                               https://fireant.vn/ma-chung-khoan/VNM
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:TPB         TPBank", line_length));

      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=XAUUSD          XAUUSD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=XAGUSD          XAGUSD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=BTCUSD          BTCUSD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=USOIL           USOIL", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=US30            US30", line_length));

      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=EURUSD          EURUSD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=USDJPY          USDJPY", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=GBPUSD          GBPUSD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=USDCHF          USDCHF", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=AUDUSD          AUDUSD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=USDCAD          USDCAD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=NZDUSD          NZDUSD", line_length));

      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=AUDNZD          AUDNZD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=EURCHF          EURCHF", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=GBPJPY          GBPJPY", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=AUDCHF          AUDCHF", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=AUDJPY          AUDJPY", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=EURAUD          EURAUD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=EURCAD          EURCAD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=EURGBP          EURGBP", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=EURJPY          EURJPY", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=EURNZD          EURNZD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=GBPCHF          GBPCHF", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=GBPNZD          GBPNZD", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=NZDJPY          NZDJPY", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=H4&symbol=NZDCAD          NZDCAD", line_length));

      FileWrite(nfile_draft, AppendSpaces("", line_length));
      FileWrite(nfile_draft, AppendSpaces("1. Ngân hàng:", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VCB        Vietcombank", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:TCB        Techcombank", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:MBB        MBBank", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VPB        VPBank ", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:HDB        HDBank", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:ACB        Asia Commercial Bank", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:LPB        LienVietPostBank", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:TPB        TPBank", line_length));
      FileWrite(nfile_draft, AppendSpaces("", line_length));
      FileWrite(nfile_draft, AppendSpaces("2. Bất động sản:", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VIC        Vingroup", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:NLG        Nam Long Group", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:DXG        Dat Xanh Group", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:NVL        Novaland", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:KDH        Kinh Đô Corporation", line_length));
      FileWrite(nfile_draft, AppendSpaces("", line_length));
      FileWrite(nfile_draft, AppendSpaces("3. Viễn thông:", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VNM        Viettel", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:FPT        FPT Corporation", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VNG        VNG Corporation", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:CTS        Công ty cổ phần Viễn thông Công nghệ Sài Gòn", line_length));
      FileWrite(nfile_draft, AppendSpaces("", line_length));
      FileWrite(nfile_draft, AppendSpaces("4. Hàng tiêu dùng:", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:MSN        Masan Group", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VNM        Vinamilk", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:SAB        Sabeco", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:MWG        Mobile World Group", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:PNJ        Phú Nhuận Jewelry", line_length));
      FileWrite(nfile_draft, AppendSpaces("", line_length));
      FileWrite(nfile_draft, AppendSpaces("5. Năng lượng:", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:GAS        PetroVietnam Gas", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:PLX        Petrolimex", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:POW        PetroVietnam Power", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:PVD        PetroVietnam Drilling and Well Services", line_length));
      FileWrite(nfile_draft, AppendSpaces("", line_length));
      FileWrite(nfile_draft, AppendSpaces("6. Công nghệ:", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:FPT        FPT Corporation", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:VNG        VNG Corporation", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:PLX        Vietnam National Petroleum Group", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:PGC        Petrolimex Trading Joint Stock Company", line_length));
      FileWrite(nfile_draft, AppendSpaces("", line_length));
      FileWrite(nfile_draft, AppendSpaces("7. Sản xuất, y tế và dược phẩm", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:HPG        Hoà Phát Group", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:GEX        Gemadept Corporation", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:DHG        Công ty Cổ phần Dược Hậu Giang", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:DMC        Công ty Cổ phần Dược phẩm MEDIC", line_length));
      FileWrite(nfile_draft, AppendSpaces("    https://www.tradingview.com/chart/r46Q5U5a/?interval=W&symbol=HOSE:IMP        Công ty Cổ phần Dược phẩm Imexpharm", line_length));
      FileWrite(nfile_draft, AppendSpaces("", line_length));


      FileClose(nfile_draft);
     }
//--------------------------------------------------------------------------------------------------
   Draw_Bottom_Msg();
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double dic_top_price;
   double dic_amp_w;
   double dic_amp_init_h4;
   double dic_amp_init_d1;
   GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_amp_init_h4, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double risk = calcRisk();
   string volume_bt = format_double_to_string(dblLotsRisk(_Symbol, week_amp*2, risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + _Symbol;
   string trend_macd = get_trend_by_macd_and_signal_vs_zero(_Symbol, PERIOD_H4);

   string trend_swap = "";
   double swap_long  = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   double swap_short  = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);
   if(swap_long > swap_short*2)
      trend_swap = TREND_BUY;
   if(swap_short > swap_long*2)
      trend_swap = TREND_SEL;

   CandleData arr_heiken_w1[];
   get_arr_heiken(_Symbol, PERIOD_W1, arr_heiken_w1, 25);
   CandleData arr_heiken_d1[];
   get_arr_heiken(_Symbol, PERIOD_D1, arr_heiken_d1, 25);

   string trend_d13 = get_trend_by_stoc2(_Symbol, PERIOD_D1, 13, 8, 5, 0);
   string trend_h413 = get_trend_by_stoc2(_Symbol, PERIOD_H4, 13, 8, 5, 0);
   string trend_d13_candles = get_candle_switch_trend_stoch(_Symbol, PERIOD_D1, 13, 8, 5);
   string trend_h413_candles = get_candle_switch_trend_stoch(_Symbol, PERIOD_H4, 13, 8, 5);

   str_comments += "    Amp: " + (string) get_default_amp_trade(_Symbol);
   str_comments += "    Volume: " + volume_bt + " lot";
   str_comments += "    Risk: " + (string) risk + "$/" + (string)(dbRiskRatio * 100) + "% ";

   if(trend_swap != "")
      str_comments += "    Swap " + AppendSpaces(trend_swap, 5);

   str_comments += "    Hei(W) " + AppendSpaces(arr_heiken_w1[0].trend + " ("+(string)arr_heiken_w1[0].count+")", 10);
   str_comments += "    Hei(D) " + AppendSpaces(arr_heiken_d1[0].trend + " ("+(string)arr_heiken_d1[0].count+")", 10);

   str_comments += "    (W333.1)" + AppendSpaces(trend_w3331, 5) + "    (D853)" + AppendSpaces(candle_switch_trend_d8);
   if(StringFind(candle_switch_trend_d8, trend_w3331) >= 0)
      str_comments += " ---> " + AppendSpaces(trend_w3331, 5);

//   str_comments += "    Stoc(D13) " + trend_d13_candles;
//   if(is_must_exit_trade_by_stoch(_Symbol, PERIOD_D1, trend_d13))
//      str_comments += "    Must_Exit(D1) ";
//
//   str_comments += "    Stoc(H4.13) " + trend_h413_candles;
//   if(is_must_exit_trade_by_stoch(_Symbol, PERIOD_H4, trend_h413))
//      str_comments += "    Must_Exit(H4.13) ";
//
//   if(DEBUG_ON_HISTORY_DATA)
//      str_comments += "    DEBUG_ON_HISTORY_DATA ";
//   if(ALLOW_AUTO_TRADE)
//      str_comments += "    ALLOW_AUTO_TRADE ";

   str_comments += "\n";
   if(IsMarketClose())
      str_comments += "    MarketClose";
   else
      str_comments += "    Market Open";
   str_comments += "    " + get_profit_today();

   return str_comments;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Bottom_Msg()
  {
   int start_x = 10;
   int start_y = 50;
   int btn_high = 21;
   int btn_width = 225;
   int doji_width = 100;
   int btn_trade_width = 112;
   ushort delimiter = StringGetCharacter(";",0);
//---------------------------------------------------------------------------------------------------------------------------------------
   int main_fx_size = ArraySize(arr_main_symbol);
   int y_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 30;
   for(int temp_i = 0; temp_i < main_fx_size; temp_i++)
     {
      string symbol = arr_main_symbol[temp_i];
      string tradingview_symbol = get_tradingview_symbol(symbol);

      color clrBackground = clrWhiteSmoke;
      if(StringFind(_Symbol, tradingview_symbol) >= 0)
         clrBackground = clrHoneydew;

      createButton("btn_w1_" + tradingview_symbol, tradingview_symbol, temp_i*(doji_width + 10) + 10, y_ref_btn, doji_width, 20, clrBlack, clrBackground, 6);
     }

//---------------------------------------------------------------------------------------------------------------------------------------
   int count_wdh4 = 0;
   int total_fx_size = ArraySize(arr_symbol);
   int y_wdh4_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 55;

   string arr_btn_wdh4[];
   string footer_wdh4_contents = ReadFileContent(FILE_NAME_BUTTONS_WDH4);
   StringSplit(footer_wdh4_contents, delimiter, arr_btn_wdh4);
   int count_wdh4_size = ArraySize(arr_btn_wdh4);

   for(int temp_i = 0; temp_i < total_fx_size; temp_i++)
     {
      string symbol = arr_symbol[temp_i];
      string tradingview_symbol = get_tradingview_symbol(symbol);

      string btn_name = "btn_wdh_" + tradingview_symbol;

      color clrBackground = clrWhiteSmoke;
      if(StringFind(_Symbol, tradingview_symbol) >= 0)
         clrBackground = clrHoneydew;

      string lbl_wdh4 = "";
      bool not_found_button = true;
      for(int index = 0; index < count_wdh4_size; index++)
        {
         lbl_wdh4 = arr_btn_wdh4[index];
         if(is_same_symbol(lbl_wdh4, tradingview_symbol))
           {
            not_found_button = false;
            break;
           }
        }

      if(not_found_button)
         ObjectDelete(0, btn_name);
      else
        {
         createButton(btn_name, lbl_wdh4, count_wdh4*(doji_width + 10) + 10, y_wdh4_btn, doji_width, 20, clrBlack, clrBackground, 6);
         count_wdh4 += 1;
        }
     }

//---------------------------------------------------------------------------------------------------------------------------------------
   int count_doji = 0;
   int y_doj_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 80;

   string btn_footers[];
   string footer_contents = ReadFileContent(FILE_NAME_BUTTONS_FOOTER);
   StringSplit(footer_contents, delimiter, btn_footers);
   int footer_size = ArraySize(btn_footers);

   for(int temp_i = 0; temp_i < total_fx_size; temp_i++)
     {
      string symbol = arr_symbol[temp_i];
      string tradingview_symbol = get_tradingview_symbol(symbol);

      string btn_name = "btn_doji_" + tradingview_symbol;

      color clrBackground = clrWhiteSmoke;
      if(StringFind(_Symbol, tradingview_symbol) >= 0)
         clrBackground = clrHoneydew;

      string lbl_footer = "";
      bool not_found_button = true;
      for(int index = 0; index < footer_size; index++)
        {
         lbl_footer = btn_footers[index];
         if(is_same_symbol(lbl_footer, tradingview_symbol))
           {
            not_found_button = false;
            break;
           }
        }

      if(not_found_button)
         ObjectDelete(0, btn_name);
      else
        {
         createButton(btn_name, lbl_footer, count_doji*(doji_width + 10) + 10, y_doj_btn, doji_width, 20, clrBlack, clrBackground, 6);

         count_doji += 1;
        }

     }

//---------------------------------------------------------------------------------------------------------------------------------------

   string str_count_trade = CountTrade(_Symbol);
   bool has_order_buy = StringFind(str_count_trade, TRADE_COUNT_ORDER_B) >= 0;
   bool has_order_sel = StringFind(str_count_trade, TRADE_COUNT_ORDER_S) >= 0;
   bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
   bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;
   string str_p = "";
   int index = StringFind(str_count_trade, "P:");
   if(index >= 0)
      str_p = StringSubstr(str_count_trade, index, StringLen(str_count_trade));
   color clrPosColor = (StringFind(str_p, "-") >= 0) ? clrFireBrick : clrGreen;

   string cur_haTrend = get_trend_by_heiken(_Symbol, Period(), 0);
   string trend_h4 = get_trend_by_heiken(_Symbol, PERIOD_H4, 0);

   color clrTrade = clrGray;
   if(cur_haTrend == TREND_BUY)
      clrTrade = clrTeal;
   if(cur_haTrend == TREND_SEL)
      clrTrade = clrFireBrick;

   ObjectDelete(0, BtnTrade);
   ObjectDelete(0, BtnOrderBuy);
   ObjectDelete(0, BtnOrderSell);
   ObjectDelete(0, BtnCloseOrder);
   ObjectDelete(0, BtnClosePosision);

   bool allow_sel = true;
   bool allow_buy = true;
   bool allow_trade = false;

   if(cur_haTrend == trend_h4)
     {
      allow_trade = true;

      if(trend_h4 == TREND_BUY)
         allow_sel = false;
      else
         allow_buy = false;
     }

   if(allow_trade)
      createButton(BtnTrade,  cur_haTrend + " " + get_current_timeframe_to_string(), start_x + 0*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrWhite, clrTrade, 8);

   if(has_order_buy == false && has_order_sel == false)
     {
      if(allow_buy)
         createButton(BtnOrderBuy,  "Order_B_" + get_current_timeframe_to_string(), start_x + 1*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrWhite, clrCadetBlue, 8);

      if(allow_sel)
         createButton(BtnOrderSell, "Order_S_" + get_current_timeframe_to_string(), start_x + 2*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrWhite, clrFireBrick, 8);

      if(has_position_buy || has_position_sel)
         createButton(BtnClosePosision, "Close " + str_p,                        start_x + 3*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrPosColor, clrHoneydew,  8);
     }
   else
     {
      createButton(BtnCloseOrder,    "Close Order",                              start_x + 1*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrWhite, clrGray,  8);
      if(has_position_buy || has_position_sel)
         createButton(BtnClosePosision, "Close " + str_p,                        start_x + 2*btn_trade_width, start_y, btn_trade_width - 5, btn_high, clrPosColor, clrHoneydew,  8);
     }

//---------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------

   string contents = ReadFileContent(FILE_NAME_BUTTONS);
   string msgs[];
   StringSplit(contents, delimiter, msgs);

   int init_x = 10;
   int init_y = 80;

   int size = ArraySize(msgs);
   int index_op = 0, index_wa = 0, btn_count = 0;
   bool has_o = false, has_p = false, has_w = false, has_d = false, has_h4 = false;
   for(int index = 0; index < size; index++)
     {
      string msg = msgs[index];
      color clrBackground = clrWhiteSmoke;

      string cur_symbol = "";
      int count_trade = 0;
      double profit = 0.0;

      ulong pre_ticket = 0;
      datetime min_start_date = TimeCurrent();
      int total_fx_size = ArraySize(arr_symbol);
      for(int temp_i = 0; temp_i < total_fx_size; temp_i++)
        {
         string symbol = arr_symbol[temp_i];
         string tradingview_symbol = get_tradingview_symbol(symbol);

         if(StringFind(msg, tradingview_symbol) >= 0)
           {
            cur_symbol = symbol;

            for(int pos = PositionsTotal()-1; pos >= 0; pos--)
              {
               if(m_position.SelectByIndex(pos))
                 {
                  if(toLower(cur_symbol) == toLower(m_position.Symbol()))
                    {
                     count_trade += 1;
                     profit += m_position.Profit();

                     if(pre_ticket == 0 || pre_ticket > m_position.Ticket())
                        min_start_date = m_position.Time();
                    }
                 }
              }
           }
        }

      if(count_trade > 0)
        {
         int secondsPerDay = 24 * 60 * 60;
         int day = (int)MathRound((TimeCurrent() - min_start_date) / secondsPerDay);

         string str_profit = " o"+(string) count_trade + " " + format_double_to_string(profit, 1) +"$ " +(string)day+"d";
         msg += str_profit;
        }

      int x = 0;
      int y = 0;

      bool is_opening_btn = false;
      if(StringFind(msg, "(Op)") >= 0)
        {
         x = init_x + 0*btn_width;
         y = init_y + (index_op * btn_high);
         has_o = true;

         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrWhite;
        }

      if(StringFind(msg, "(TP)") >= 0)
        {
         x = init_x + 0*btn_width;
         y = init_y + (index_op * btn_high);
         y += has_o ? 10 : 0;

         has_p = true;
         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrPaleGreen;
        }


      if(StringFind(msg, "(X)") >= 0)
        {
         x = init_x + 0*btn_width;
         y = init_y + (index_op * btn_high);
         y += has_o ? 10 : 0;
         y += has_p ? 10 : 0;

         index_op += 1;
         is_opening_btn = true;
         clrBackground = clrLightGray;
        }
      // ------------------------------------------------------------
      bool is_found = false;

      int next_col = (index_op > 0) ? 1 : 0;
      if(is_found == false && StringFind(msg, "W1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * btn_high);
         has_w = true;
         index_wa += 1;
         clrBackground = clrLightCyan;

         if(StringFind(msg, "(Am)") >= 0)
            clrBackground = clrPowderBlue;

         is_found = true;
        }

      if(is_found == false && StringFind(msg, "D1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * btn_high);
         y += has_w ? 10 : 0;

         has_d = true;
         index_wa += 1;
         clrBackground = clrAliceBlue;

         is_found = true;
        }

      if(is_found == false && StringFind(msg, "H4") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * btn_high);
         y += has_w ? 10 : 0;
         y += has_d ? 10 : 0;

         has_h4 = true;
         index_wa += 1;
         clrBackground = clrSnow;

         is_found = true;
        }

      if(is_found == false && StringFind(msg, "H1") >= 0)
        {
         x = init_x + next_col*btn_width;
         y = init_y + (index_wa * btn_high);
         y += has_w ? 10 : 0;
         y += has_d ? 10 : 0;
         y += has_h4 ? 10 : 0;

         index_wa += 1;
         clrBackground = clrWhite;

         is_found = true;
        }


      if(msg != "" && x > 0 && y > 0)
        {
         color clrTrade = StringFind(msg, TREND_BUY) >= 0 ? clrNavy : clrFireBrick;
         string TRADING_TREND = StringFind(msg, TREND_BUY) >= 0 ? TREND_BUY : TREND_SEL;

         if(is_opening_btn)
            StringReplace(msg, "(Op)", "");

         if(cur_symbol == _Symbol)
           {
            clrBackground = clrHoneydew;
           }

         btn_count += 1;
         string btn_name = "btn_" + (string) btn_count;
         createButton(btn_name, msg, x, y, btn_width-5, 20, clrTrade, clrBackground, 6);
        }
     }
   for(int index = btn_count + 1; index < 100; index++)
      ObjectDelete(0, "btn_" + (string) index);

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
      if((StringFind(sparam, "btn_") >= 0) || (StringFind(sparam, "Button") >= 0))
        {
         string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         //Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            string tradingview_symbol = get_tradingview_symbol(symbol);

            if(StringFind(buttonLabel, tradingview_symbol) >= 0)
              {
               CloseChart();

               ENUM_TIMEFRAMES timeframe = PERIOD_D1;

               if((StringFind(sparam, "btn_w1_") >= 0) || (StringFind(sparam, "DXY") >= 0))
                  timeframe = PERIOD_W1;

               if(StringFind(buttonLabel, PREFIX_TRADE_PERIOD_W1) >= 0)
                  timeframe = PERIOD_W1;

               if(StringFind(buttonLabel, PREFIX_TRADE_PERIOD_D1) >= 0)
                  timeframe = PERIOD_D1;

               if(StringFind(buttonLabel, PREFIX_TRADE_PERIOD_H4) >= 0)
                  timeframe = PERIOD_H4;

               ChartOpen(symbol, PERIOD_H4);
              }
           }
         // ------------------------------------------------------------------------
         if(StringFind(sparam, "DXY") >= 0)
           {
            CloseChart();
            ChartOpen("DXY", PERIOD_W1);
           }
         // ------------------------------------------------------------------------
        }


      //-----------------------------------------------------------------------
      //-----------------------------------------------------------------------
      if((sparam == BtnTrade) || (sparam == BtnOrderBuy) || (sparam == BtnOrderSell))
        {
         Print("The ", sparam," was clicked");

         CandleData arr_candle_d1[];
         get_arr_heiken(_Symbol, PERIOD_D1, arr_candle_d1);
         string note = "_D" + (arr_candle_d1[0].trend == TREND_BUY ? "b" : "s") + (string)arr_candle_d1[0].count;

         //-----------------------------------------------------------------------
         double dic_top_price;
         double dic_amp_w;
         double dic_avg_candle_week;
         double dic_amp_init_d1;
         GetSymbolData(_Symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
         double week_amp = dic_amp_w;
         double amp_percent = dic_amp_init_d1;

         double amp_sl = week_amp*2;
         double volume = dblLotsRisk(_Symbol, amp_sl, calcRisk());
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         string cur_click_prefix = get_prefix_trade_from_current_timeframe(Period());
         double amp_waste = NormalizeDouble(week_amp / 10, digits);

         double tp_buy = 0.0;
         double tp_sel = 0.0;
         double next_entry_buy = 0.0;
         double next_entry_sel = 0.0;
         double lowest_close_21 = 0.0;
         double higest_close_21 = 0.0;
         if((sparam == BtnTrade) || (sparam == BtnOrderBuy) || (sparam == BtnOrderSell))
           {
            for(int i = 1; i <= 55; i++)
              {
               double low = iLow(_Symbol, PERIOD_H4, i);
               double hig = iHigh(_Symbol, PERIOD_H4, i);
               double close = iClose(_Symbol, PERIOD_H4, i);

               if((i == 1) || (next_entry_buy > low))
                  next_entry_buy = low;
               if((i == 1) || (next_entry_sel < hig))
                  next_entry_sel = hig;

               if(i <= 21)
                 {
                  if((i == 1) || (lowest_close_21 > close))
                     lowest_close_21 = close;

                  if((i == 1) || (higest_close_21 < close))
                     higest_close_21 = close;
                 }
              }

            double nex_price_buy = lowest_close_21*(1 + amp_percent*1);
            double nex_price_sel = higest_close_21*(1 - amp_percent*1);

            tp_buy = next_entry_sel;
            if(tp_buy < nex_price_buy)
               tp_buy = nex_price_buy;

            tp_sel = next_entry_buy;
            if(tp_sel > nex_price_sel)
               tp_sel = nex_price_sel;

            next_entry_buy = next_entry_buy - week_amp;
            next_entry_sel = next_entry_sel + week_amp;
           }
         //-----------------------------------------------------------------------
         int count_order_buy = 0;
         int count_order_sel = 0;
         for(int i = OrdersTotal() - 1; i >= 0; i--)
           {
            if(m_order.SelectByIndex(i))
              {
               if((toLower(_Symbol) == toLower(m_order.Symbol())))
                 {
                  if(m_order.Type() == ORDER_TYPE_BUY_LIMIT || m_order.Type() == ORDER_TYPE_BUY || (StringFind(toLower(m_order.TypeDescription()), "buy") >= 0))
                     count_order_buy += 1;

                  if(m_order.Type() == ORDER_TYPE_SELL_LIMIT || m_order.Type() == ORDER_TYPE_SELL || (StringFind(toLower(m_order.TypeDescription()), "sel") >= 0))
                     count_order_sel += 1;
                 }
              }
           }
         string trend_w1_by_heiken_ma6_stoc = get_trend_by_heiken_ma6_stoc(_Symbol, PERIOD_W1);
         string trend_d1_by_heiken_ma6_stoc = get_trend_by_heiken_ma6_stoc(_Symbol, PERIOD_D1);
         string note_wd = "W1("+trend_w1_by_heiken_ma6_stoc+") & D1("+trend_d1_by_heiken_ma6_stoc+")";

         //-----------------------------------------------------------------------
         if(sparam == BtnTrade)
           {
            string haTrend = get_trend_by_heiken(_Symbol, Period(), 0);

            if(trend_w1_by_heiken_ma6_stoc == trend_d1_by_heiken_ma6_stoc)
               if(trend_w1_by_heiken_ma6_stoc != haTrend)
                 {
                  Alert("Không đánh ("+haTrend+") "+AppendSpaces(_Symbol) +" ngược xu hướng " + note_wd);
                  return;
                 }

            for(int i = PositionsTotal()-1; i >= 0; i--)
              {
               if(m_position.SelectByIndex(i))
                 {
                  if(toLower(_Symbol) == toLower(m_position.Symbol()))
                    {
                     //string trade_from_comment = get_prefix_trade_from_comments(m_position.Comment());
                     //if(cur_trade_prefix == trade_from_comment)
                     Alert("Position   ", m_position.TypeDescription(), "   ", _Symbol, " was opened... profit: ", m_position.Profit());
                     return;
                    }
                 }
              }


            string msg = OPEN_TRADE + "    " + AppendSpaces(haTrend, 5) + _Symbol + "  vol: " + (string) volume + " lot "  + note_wd + note;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  if(haTrend == TREND_BUY)
                    {
                     m_trade.Buy(volume, _Symbol, 0.0, 0.0, tp_buy, "MK_B1_" + cur_click_prefix + note);
                     if(count_order_buy == 0)
                       {
                        //m_trade.BuyLimit(volume, next_entry_buy,              _Symbol, 0.0, tp_buy, 0, 0, "OD_B2_" + cur_click_prefix);
                        //m_trade.BuyLimit(volume, next_entry_buy - amp_waste,  _Symbol, 0.0, tp_buy, 0, 0, "OD_B3_" + cur_click_prefix);
                       }
                    }

                  if(haTrend == TREND_SEL)
                    {
                     m_trade.Sell(volume, _Symbol, 0.0, 0.0, tp_sel, "MK_S1_" + cur_click_prefix + note);
                     if(count_order_sel == 0)
                       {
                        //m_trade.SellLimit(volume, next_entry_sel,             _Symbol, 0.0, tp_sel, 0, 0, "OD_S2_" + cur_click_prefix);
                        //m_trade.SellLimit(volume, next_entry_sel + amp_waste, _Symbol, 0.0, tp_sel, 0, 0, "OD_S3_" + cur_click_prefix);
                       }
                    }

                  Alert(msg+ ".");
                  break;

               case IDNO:
                  break;
              }
           }
         //-----------------------------------------------------------------------
         if(sparam == BtnOrderBuy)
           {
            if(count_order_buy > 0)
              {
               Alert(get_vntime(), " Đã có lệnh ORDER ", _Symbol);
               return;
              }

            double open_price = NormalizeDouble(lowest_close_21, digits);
            if(open_price > price - amp_waste)
               open_price = price - amp_waste;

            string msg = OPEN_ORDERS + AppendSpaces(TREND_BUY, 5) + _Symbol + "  vol: " + (string) volume + " lot " + note_wd + note;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  //Alert(msg+ ".");
                  m_trade.BuyLimit(volume, open_price,                    _Symbol, 0.0, tp_buy, 0, 0, "OD_B1_" + cur_click_prefix + note);
                  //m_trade.BuyLimit(volume, next_entry_buy,              _Symbol, 0.0, tp_buy, 0, 0, "OD_B2_" + cur_click_prefix);
                  //m_trade.BuyLimit(volume, next_entry_buy - amp_waste,  _Symbol, 0.0, tp_buy, 0, 0, "OD_B3_" + cur_click_prefix);
                  break;

               case IDNO:
                  break;
              }
           }
         //-----------------------------------------------------------------------
         if(sparam == BtnOrderSell)
           {
            if(count_order_sel > 0)
              {
               Alert(get_vntime(), " Đã có lệnh ORDER ", _Symbol);
               return;
              }

            double open_price = NormalizeDouble(higest_close_21, digits);
            if(open_price < price + amp_waste)
               open_price = price + amp_waste;

            string msg = OPEN_ORDERS + AppendSpaces(TREND_SEL, 5) + _Symbol + "  vol: " + (string) volume + " lot " + note_wd + note;
            msg += "  Open: " + (string) open_price + "  TP: " + (string) tp_sel;

            int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
            switch(result)
              {
               case IDYES:
                  //Alert(msg+ ".");
                  m_trade.SellLimit(volume, open_price,                   _Symbol,  0.0, tp_sel, 0, 0, "OD_S1_" + cur_click_prefix + note);
                  //m_trade.SellLimit(volume, next_entry_sel,             _Symbol, 0.0, tp_sel, 0, 0, "OD_S2_" + cur_click_prefix);
                  //m_trade.SellLimit(volume, next_entry_sel + amp_waste, _Symbol, 0.0, tp_sel, 0, 0, "OD_S3_" + cur_click_prefix);
                  break;

               case IDNO:
                  break;
              }
           }

         Draw_Bottom_Msg();
        }

      //-----------------------------------------------------------------------
      if(sparam == BtnClosePosision)
        {
         Print("The ", sparam," was clicked");

         for(int i = PositionsTotal()-1; i >= 0; i--)
           {
            if(m_position.SelectByIndex(i))
              {
               ulong ticket = PositionGetTicket(i);
               double profit = PositionGetDouble(POSITION_PROFIT);
               string symbol = PositionGetString(POSITION_SYMBOL);
               string comments = PositionGetString(POSITION_COMMENT);

               if(toLower(_Symbol) == toLower(symbol))
                 {
                  int confirm_result = MessageBox("Đóng Position #" + (string) ticket + "   " + m_position.TypeDescription() + "   " + _Symbol + " profit: " + (string) profit + "?", "Confirm", MB_YESNOCANCEL);
                  if(confirm_result == IDYES)
                    {
                     //Alert("Position #", ticket, "   ", _Symbol, " was closed... profit: ", profit);
                     m_trade.PositionClose(ticket);
                    }
                 }
              }
           }

         Draw_Bottom_Msg();
        }

      if(sparam == BtnCloseOrder)
        {
         Print("The ", sparam," was clicked");

         for(int i = OrdersTotal() - 1; i >= 0; i--)
           {
            if(m_order.SelectByIndex(i))
              {
               ulong ticket = OrderGetTicket(i);
               string comments = OrderGetString(ORDER_COMMENT);

               if((toLower(_Symbol) == toLower(m_order.Symbol())))
                 {
                  int confirm_result = MessageBox("Đóng Order #" + (string) ticket+ "   " + m_order.TypeDescription() + "   " + _Symbol + "   " + comments + "?", "Confirm", MB_YESNOCANCEL);
                  if(confirm_result == IDYES)
                    {
                     //Alert("Order #" + (string) ticket+ "   " + m_order.TypeDescription() + "   " + _Symbol + "   " + comments);
                     m_trade.OrderDelete(ticket);
                    }
                 }
              }
           }

         Draw_Bottom_Msg();
        }

      //-----------------------------------------------------------------------
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      ChartRedraw();

     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestOpenTrade(string symbol, string TRADING_TREND, string PREFIX_TRADE_PERIOD_XXX, string note)
  {
   if(DEBUG_ON_HISTORY_DATA == false)
      return;

   double volume = get_default_volume(symbol);

   if(TRADING_TREND == TREND_BUY)
     {
      string comment = "MK_B1" + ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_XXX + "_" + note;

      m_trade.Buy(volume, symbol, 0.0, 0.0, 0.0, comment);

      string msg_open_trade = OPEN_TRADE + "   BUY    " + symbol + "   "+comment+"   Vol: " + (string) volume;
      SendTelegramMessage(symbol, TREND_BUY, msg_open_trade);
     }

   if(TRADING_TREND == TREND_SEL)
     {
      string comment = "MK_S1" + ENTRY_TRADE_BY_STOC_X + PREFIX_TRADE_PERIOD_XXX + "_" + note;

      m_trade.Sell(volume, symbol, 0.0, 0.0, 0.0, comment);

      string msg_open_trade = OPEN_TRADE + "   SELL   " + symbol + "   "+comment+"   Vol: " + (string) volume;
      SendTelegramMessage(symbol, TREND_BUY, msg_open_trade);
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, string trading_trend, string ENTRY_TYPE)
  {
   CloseOrders(symbol);

   string msg = "";
   double profit = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.TypeDescription()), toLower(trading_trend)) >= 0)
               if(ENTRY_TYPE == "" || (StringFind(m_position.Comment(), ENTRY_TYPE) >= 0))
                 {
                  msg += (string)m_position.Ticket() + ": " + (string) m_position.Profit() + "$";
                  profit += m_position.Profit();
                  m_trade.PositionClose(m_position.Ticket());
                 }

     } //for

   if(msg != "")
      SendTelegramMessage(symbol, STOP_TRADE, STOP_TRADE + " " + trading_trend + "  " + symbol + "   Total: " + (string) profit + "$ ");

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition_StopLoss(string symbol, string trading_trend, ulong except_keep_ticket)
  {
   return;

   CloseOrders(symbol);

   string msg = "";
   double profit = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.TypeDescription()), toLower(trading_trend)) >= 0)
               if(m_position.Ticket() != except_keep_ticket)
                 {
                  msg += (string)m_position.Ticket() + ": " + (string) m_position.Profit() + "$";
                  profit += m_position.Profit();
                  m_trade.PositionClose(m_position.Ticket());
                 }

     } //for

   if(msg != "")
      SendTelegramMessage(symbol, STOP_LOSS, STOP_LOSS + " " + trading_trend + "  " + symbol + "   Total: " + (string) profit + "$ Except: " + (string) except_keep_ticket);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition_TakeProfit(string symbol, string trading_trend, string ENTRY_TYPE)
  {
   return;

   string msg = "";
   double profit = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.TypeDescription()), toLower(trading_trend)) >= 0)
               if(ENTRY_TYPE == "" || (StringFind(m_position.Comment(), ENTRY_TYPE) >= 0))
                  if(m_position.Profit() > 1)
                    {
                     msg += (string)m_position.Ticket() + ": " + (string) m_position.Profit() + "$";
                     profit += m_position.Profit();
                     m_trade.PositionClose(m_position.Ticket());
                    }
     } //for

   if(msg != "")
      SendTelegramMessage(symbol, "TAKE_PROFIT", "(TAKE.PROFIT) " + AppendSpaces(symbol) + " (H4) " + " Total: " + (string) profit + "$ " + msg);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders(string symbol)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_order.Symbol()))
           {
            m_trade.OrderDelete(m_order.Ticket());
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_next_entry(string symbol, string find_trend)
  {
   double next_entry_buy = 0.0;
   double next_entry_sel = 0.0;
   for(int i = 0; i <= 25; i++)
     {
      double low = iLow(_Symbol, PERIOD_H4, i);
      double hig = iHigh(_Symbol, PERIOD_H4, i);

      if((i == 0) || (next_entry_buy > low))
         next_entry_buy = low;
      if((i == 0) || (next_entry_sel < hig))
         next_entry_sel = hig;
     }

   if(find_trend == TREND_BUY)
      return next_entry_buy;

   if(find_trend == TREND_SEL)
      return next_entry_sel;

   return 0.0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseChart()
  {
   long chart_ID=ChartFirst();
   while(chart_ID >= 0)
     {
      ChartClose(chart_ID);
      chart_ID = ChartNext(chart_ID);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_tp_price(string symbol, string trading_trend)
  {
   if(DEBUG_ON_HISTORY_DATA)
      return 0.0;

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double amp_waste = dic_amp_w*0.1;

   double lowest_close_21 = 0.0;
   double higest_close_21 = 0.0;

   for(int i = 1; i <= 21; i++)
     {
      double low = iLow(_Symbol, PERIOD_H4, i);
      double hig = iHigh(_Symbol, PERIOD_H4, i);

      if((i == 1) || (lowest_close_21 > low))
         lowest_close_21 = low;

      if((i == 1) || (higest_close_21 < hig))
         higest_close_21 = hig;

     }

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double tp = 0.0;
   if(trading_trend == TREND_BUY)
     {
      tp = lowest_close_21*(1 + dic_amp_init_d1*1) - amp_waste;
      if(tp < price + dic_amp_w)
         tp = price + dic_amp_w;
     }

   if(trading_trend == TREND_SEL)
     {
      tp = higest_close_21*(1 - dic_amp_init_d1*1) + amp_waste;
      if(tp > price - dic_amp_w)
         tp = price - dic_amp_w;
     }

   return tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Exit_Trade(string symbol, string TRADING_TREND)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            ulong ticket = m_position.Ticket();

            if(toLower(m_position.TypeDescription()) == toLower(TREND_BUY))
               m_trade.PositionClose(ticket);

            if(toLower(m_position.TypeDescription()) == toLower(TREND_SEL))
               m_trade.PositionClose(ticket);
           }
        }
     }
  }


//+------------------------------------------------------------------+
string CountTrade(string symbol)
  {

   int pos_buy = 0;
   int pos_sel = 0;
   double profit_buy = 0.0;
   double profit_sel = 0.0;
   double volume = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_position.Symbol()))) // && (StringFind(toLower(m_position.Comment()), "bb_") >= 0)
           {
            double profit = m_position.Profit() + m_position.Swap();
            long type = PositionGetInteger(POSITION_TYPE);
            volume += m_position.Volume();

            if(type == POSITION_TYPE_BUY)
              {
               pos_buy += 1;
               profit_buy += profit;
              }

            if(type == POSITION_TYPE_SELL)
              {
               pos_sel += 1;
               profit_sel += profit;
              }
           }
        }
     } //for

   int ord_buy = 0;
   int ord_sel = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_order.Symbol())))  //&& (StringFind(toLower(m_position.Comment()), "bb_") >= 0)
           {
            long type = OrderGetInteger(ORDER_TYPE);
            if(type == ORDER_TYPE_BUY_LIMIT)
               ord_buy += 1;

            if(type == ORDER_TYPE_SELL_LIMIT)
               ord_sel += 1;
           }
        }
     }

   string result = "";

   if(ord_buy > 0)
      result += AppendSpaces(TRADE_COUNT_ORDER_B + (string)ord_buy, 13);

   if(ord_sel > 0)
      result += AppendSpaces(TRADE_COUNT_ORDER_S + (string)ord_sel, 13);

   if(ord_buy + ord_sel == 0)
      result += AppendSpaces("", 13);

   if(pos_buy > 0)
      result += AppendSpaces(TRADE_COUNT_POSITION_B + format_double_to_string(volume, 2) + " lot/" + AppendSpaces((string)pos_buy, 2), 20) + "  P:" + AppendSpaces((string) NormalizeDouble(profit_buy, 2) + "$", 7, false);

   if(pos_sel > 0)
      result += AppendSpaces(TRADE_COUNT_POSITION_S + format_double_to_string(volume, 2) + " lot/" + AppendSpaces((string)pos_sel, 2), 20) + "  P:" + AppendSpaces((string) NormalizeDouble(profit_sel, 2) + "$", 7, false);

   StringReplace(result, ".0$", "$");

   return AppendSpaces(result, 50);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
bool IsMarketClose()
  {
   datetime currentGMTTime = TimeGMT();

   MqlDateTime dtw;
   TimeToStruct(currentGMTTime, dtw);
   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)dtw.day_of_week;

   if(day_of_week == SATURDAY || day_of_week == SUNDAY)
      return true; // It's the weekend

   int gmtOffset = 7;
   datetime vietnamTime = currentGMTTime + gmtOffset * 3600;

   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);
   int currentHour = dt.hour;
   if(3 < currentHour && currentHour < 7)
      return true; //VietnamEarlyMorning

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_tradingview_symbol(string symbol)
  {
   string text = symbol;
   StringReplace(text, ".cash", "");

// Lấy một phần của chuỗi mà không bao gồm ký tự "m" cuối cùng
   if(StringGetCharacter(text, StringLen(text) - 1) == 'm')
      text = StringSubstr(text, 0, StringLen(text) - 1);

   return text;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createButton(string objName, string text, int x, int y, int width, int height, color clrTextColor, color clrBackground, int font_size, int z_index=999)
  {
   ResetLastError();
   if(!ObjectCreate(0, objName, OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }


   StringTrimLeft(text);
   StringTrimRight(text);
   StringReplace(text, TREND_BUY, "B");
   StringReplace(text, TREND_SEL, "S");
   StringReplace(text, "  ", " ");
   StringReplace(text, "  ", " ");
   StringReplace(text, "  ", " ");
   StringReplace(text, "(", "");
   StringReplace(text, ")", "");
   StringReplace(text, " ", "_");
   StringTrimLeft(text);
   StringTrimRight(text);

   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE,width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTextColor);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBackground);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, clrSilver);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, z_index);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_default_volume(string symbol)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double risk = calcRisk();

   return dblLotsRisk(symbol, week_amp*2, risk);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_default_amp_trade(string symbol)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   return NormalizeDouble(week_amp * 2, digits);
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
string get_profit_today()
  {
   MqlDateTime date_time;
   TimeToStruct(TimeCurrent(), date_time);
   int current_day = date_time.day, current_month = date_time.mon, current_year = date_time.year;
   int row_count = 0;
// --------------------------------------------------------------------
// --------------------------------------------------------------------
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   HistorySelect(0, TimeCurrent()); // today closed trades PL
   int orders = HistoryDealsTotal();

   double PL = 0.0;
   for(int i = orders - 1; i >= 0; i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
        {
         break;
        }

      string symbol  = HistoryDealGetString(ticket, DEAL_SYMBOL);
      if(symbol == "")
        {
         continue;
        }

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

      if(profit != 0)  // If deal is trade exit with profit or loss
        {
         MqlDateTime deal_time;
         TimeToStruct(HistoryDealGetInteger(ticket, DEAL_TIME), deal_time);

         // If is today deal
         if(deal_time.day == current_day && deal_time.mon == current_month && deal_time.year == current_year)
           {
            PL += profit;
           }
         else
            break;
        }
     }

   double swap = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         swap += m_position.Swap();
        }
     } //for


   double starting_balance = current_balance - PL;
   double current_equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double loss = current_equity - starting_balance;

   return "    Profit Today:" + format_double_to_string(loss, 2) + "$" + "    Swap:" + format_double_to_string(swap, 2) + "$";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_amp(string symbol, ENUM_TIMEFRAMES timeframe, int maLength = 55)
  {
   double lowest = 0.0, higest = 0.0;
   for(int i = 0; i <= maLength; i++)
     {
      double low = iLow(symbol, timeframe, i);
      double hig = iHigh(symbol, timeframe, i);

      if((i == 0) || (lowest > low))
         lowest = low;

      if((i == 0) || (higest < hig))
         higest = hig;
     }

   double amp_low_hig = MathAbs(higest - lowest) / 3.0;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   if(price > MathAbs(higest - amp_low_hig))
      return TREND_SEL;

   if(price < MathAbs(lowest + amp_low_hig))
      return TREND_BUY;

   return "sw";
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
string get_trend_by_ma50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double close0 = closePrices[0];
   double ma_50 = cal_MA(closePrices, 50, 1);

   if(close0 > ma_50)
      return TREND_SEL;

   if(close0 < ma_50)
      return TREND_BUY;

   return "eq";
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
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_6, int ma_index_9)
  {
   int maLength = MathMax(ma_index_6, ma_index_9) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }
   double ma_6_1 = cal_MA(closePrices, ma_index_6, 1);
   double ma_6_2 = cal_MA(closePrices, ma_index_6, 2);
   double ma_9_1 = cal_MA(closePrices, ma_index_9, 1);
   double ma_9_2 = cal_MA(closePrices, ma_index_9, 2);


   if(ma_6_1 >= ma_9_1 && ma_6_2 <= ma_9_2)
      return TREND_BUY;

   if(ma_6_1 <= ma_9_1 && ma_6_2 >= ma_9_2)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_vector_ma(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_0 = cal_MA(closePrices, ma_index, 0);
   double ma_1 = cal_MA(closePrices, ma_index, 1);


   if(ma_0 > ma_1)
      return TREND_BUY;

   if(ma_0 < ma_1)
      return TREND_SEL;

   return "";
  }


// Định nghĩa lớp CandleData
class CandleData
  {
public:
   datetime          time;   // Thời gian
   double            open;   // Giá mở
   double            high;   // Giá cao
   double            low;    // Giá thấp
   double            close;  // Giá đóng
   string            trend;
   int               count;
   // Default constructor
                     CandleData()
     {
      time = 0;
      open = 0.0;
      high = 0.0;
      low = 0.0;
      close = 0.0;
      trend = "";
      count = 0;
     }
                     CandleData(datetime t, double o, double h, double l, double c, string c_trend, int count_c1)
     {
      time = t;
      open = o;
      high = h;
      low = l;
      close = c;
      trend = c_trend;
      count = count_c1;
     }
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[], int length = 15)
  {
   ArrayResize(candleArray, length+5);

   datetime pre_HaTime = iTime(symbol, TIME_FRAME, length+4);
   double pre_HaOpen = iOpen(symbol, TIME_FRAME, length+4);
   double pre_HaHigh = iHigh(symbol, TIME_FRAME, length+4);
   double pre_HaLow = iLow(symbol, TIME_FRAME, length+4);
   double pre_HaClose = iClose(symbol, TIME_FRAME, length+4);
   string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

   CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0);
   candleArray[length+4] = candle;

   for(int index = length + 3; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen  = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh  = MathMax(MathMax(haOpen, haClose), iHigh(symbol, TIME_FRAME, index));
      double haLow   = MathMin(MathMin(haOpen, haClose),  iLow(symbol, TIME_FRAME, index));

      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_trend = 1;
      for(int j = index+1; j < length; j++)
        {
         if(haTrend == candleArray[j].trend)
           {
            count_trend += 1;
           }
         else
           {
            break;
           }
        }

      CandleData candle(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_trend);
      candleArray[index] = candle;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_heiken_6_1(string symbol, ENUM_TIMEFRAMES TIME_FRAME)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   string haTrend0 = candleArray[0].trend;
   string haTrend1 = candleArray[1].trend;
   string haTrend2 = candleArray[2].trend;
   if(haTrend0 == haTrend1 && haTrend1 != haTrend2 && candleArray[2].count > 3)
     {
      return haTrend1;
     }

   if(candleArray[2].count > 5 && IsDojiHeikenAshi(symbol, TIME_FRAME, 1))
     {
      return candleArray[2].trend == TREND_BUY ? TREND_SEL : TREND_BUY;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_heiken_3_0(string symbol, ENUM_TIMEFRAMES TIME_FRAME)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   string haTrend0 = candleArray[0].trend;
   string haTrend1 = candleArray[1].trend;
   if(haTrend0 != haTrend1 && candleArray[1].count > 2)
     {
      return haTrend0;
     }

   if(candleArray[1].count > 3 && IsDojiHeikenAshi(symbol, TIME_FRAME, 0))
     {
      return candleArray[1].trend == TREND_BUY ? TREND_SEL : TREND_BUY;
     }

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDojiHeikenAshi(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   double open = candleArray[candle_index].open;
   double high = candleArray[candle_index].high;
   double low = candleArray[candle_index].low;
   double close = candleArray[candle_index].close;


   double body = MathAbs(open - close) * 3;
   double shadow_hig = high - MathMax(open, close);
   double shadow_low = MathMin(open, close) - low;

   bool isDoji = (body <= shadow_hig) && (body <= shadow_low); // Kiểm tra thân nến có nhỏ hơn 50% dải bóng không

   return isDoji;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   return candleArray[candle_index].trend;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken_ma6_stoc(string symbol, ENUM_TIMEFRAMES TIME_FRAME)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   string trend_by_hei = candleArray[0].trend;
   string trend_by_ma6 = get_trend_by_ma(symbol, TIME_FRAME, 6, 0);
   string trend_by_sto = get_trend_by_stoc(symbol, TIME_FRAME, 0);

//Print("[get_trend_by_heiken_ma6_stoc] ", get_prefix_trade_from_current_timeframe(TIME_FRAME)
//      , "  trend_by_hei_c0: ", trend_by_hei, "  trend_by_ma6_c0: ", trend_by_ma6, "  trend_by_sto_c0: ", trend_by_sto);

   if(trend_by_hei == trend_by_ma6 && trend_by_hei == trend_by_sto)
      return trend_by_hei;

//   if(trend_by_hei == trend_by_ma6)
//      return trend_by_hei;
//
//   if(trend_by_hei == trend_by_sto)
//      return trend_by_hei;

   return "sw_" + get_prefix_trade_from_current_timeframe(TIME_FRAME);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_heiken_and_ma_X_Y(string symbol, ENUM_TIMEFRAMES timeframe, int fast_ma=6, int slow_ma = 10)
  {
   int maLength = MathMax(fast_ma, slow_ma) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma6_0 = cal_MA(closePrices, fast_ma, 0);
   double ma6_1 = cal_MA(closePrices, fast_ma, 1);
   double ma10 = cal_MA(closePrices, slow_ma, 0);

   CandleData candleArray[];
   get_arr_heiken(symbol, timeframe, candleArray);

   string pre_haTrend = candleArray[1].trend;
   string cur_haTrend = candleArray[0].trend;
   double haOpen1     = candleArray[1].open;
   double haClose1    = candleArray[1].close;

   if((pre_haTrend == TREND_BUY && cur_haTrend == TREND_BUY) && (ma6_0 > ma6_1) &&
      (haOpen1 <= ma6_1 && ma6_1 <= haClose1) && (haOpen1 <= ma10 && ma10 <= haClose1))
      return TREND_BUY;

   if((pre_haTrend == TREND_SEL && cur_haTrend == TREND_SEL) && (ma6_0 < ma6_1) &&
      (haOpen1 >= ma6_1 && ma6_1 >= haClose1) && (haOpen1 >= ma10 && ma10 >= haClose1))
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_seq_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
      closePrices[i] = iClose(symbol, timeframe, i);

   double ma_10 = cal_MA(closePrices, 10, 1);
   double ma_20 = cal_MA(closePrices, 20, 1);
   double ma_50 = cal_MA(closePrices, 50, 1);

   if((ma_10 >= ma_20) && (ma_20 >= ma_50))
      return TREND_BUY;

   if((ma_10 <= ma_20) && (ma_20 <= ma_50))
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_by_ma_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe, string trend_by_amp_55h4)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
      closePrices[i] = iClose(symbol, timeframe, i);

   double ma_10 = cal_MA(closePrices, 10, 1);
   double ma_20 = cal_MA(closePrices, 20, 1);
   double ma_50 = cal_MA(closePrices, 50, 1);

   if((trend_by_amp_55h4 == TREND_SEL) && (ma_10 >= ma_20) && (ma_20 >= ma_50))
      return false;

   if((trend_by_amp_55h4 == TREND_BUY) && (ma_10 <= ma_20) && (ma_20 <= ma_50))
      return false;

   return true;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_continue_hode_postion_by_ma_7_10_20(string symbol, ENUM_TIMEFRAMES timeframe, string trading_trend)
  {
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
      closePrices[i] = iClose(symbol, timeframe, i);

   double ma_07 = cal_MA(closePrices, 7, 0);
   double ma_10 = cal_MA(closePrices, 10, 0);
   double ma_20 = cal_MA(closePrices, 20, 0);

   if((trading_trend == TREND_BUY) && (ma_07 >= ma_10) && (ma_10 >= ma_20))
      return true;

   if((trading_trend == TREND_SEL) && (ma_07 <= ma_10) && (ma_10 <= ma_20))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_seq_6_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_seq_ma10_20_50 = "";

   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_6_0 = cal_MA(closePrices, 6, 0);
   double ma_6_1 = cal_MA(closePrices, 6, 1);

   double ma_10 = cal_MA(closePrices, 10, 0);
   double ma_20 = cal_MA(closePrices, 20, 0);
   double ma_50 = cal_MA(closePrices, 50, 0);

   double close = iClose(symbol, timeframe, 0);

   if((ma_6_0 > ma_6_1) && (ma_6_0 > ma_10) && (ma_6_0 > ma_20) && (ma_6_0 > ma_50))
      //if((close > ma_10) && (close > ma_20) && (close > ma_50) && (ma_10 > ma_20))
      trend_seq_ma10_20_50 = TREND_BUY;

   if((ma_6_0 < ma_6_1) && (ma_6_0 < ma_10) && (ma_6_0 < ma_20) && (ma_6_0 < ma_50))
      //if((close < ma_10) && (close < ma_20) && (close < ma_50) && (ma_10 < ma_20))
      trend_seq_ma10_20_50 = TREND_SEL;

   if(timeframe < PERIOD_H1)
      return trend_seq_ma10_20_50;

   if(trend_seq_ma10_20_50 != "")
     {
      double lowest = iLow(symbol, timeframe, 1);
      double higest = iHigh(symbol, timeframe, 1);
      double high = (higest - lowest)/2;

      if(trend_seq_ma10_20_50 == TREND_SEL)
         lowest = lowest - high;

      if(trend_seq_ma10_20_50 == TREND_BUY)
         higest = higest + high;

      if((lowest <= ma_50) && (ma_50 <= higest))
        {
         return trend_seq_ma10_20_50;
        }
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i < ma_index; i++)
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
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_by_ma(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index)
  {
   double ma10 = cal_MA_XX(symbol, timeframe, ma_index, 1);

   CandleData candleArray[];
   get_arr_heiken(symbol, timeframe, candleArray);
   double haClose1 = candleArray[1].close;
   double haClose2 = candleArray[2].close;

   double close_1 = iClose(symbol, timeframe, 1);
   if(close_1 >= ma10 && haClose1 >= ma10 && haClose2 <= ma10)
      return TREND_BUY;

   if(close_1 <= ma10 && haClose1 <= ma10 && haClose2 >= ma10)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string symbol, string trend, string message)
  {
   if(is_has_memo_in_file(FILE_NAME_ALERT_MSG, PREFIX_TRADE_PERIOD_H1, symbol, trend))
      return;
   add_memo_to_file(FILE_NAME_ALERT_MSG, PREFIX_TRADE_PERIOD_H1, symbol, trend);

   Alert(get_vntime(), message);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTelegramMessage(string symbol, string trend, string message)
  {
   if(is_has_memo_in_file(FILE_NAME_SEND_MSG, PREFIX_TRADE_PERIOD_H4, symbol, trend))
      return;
   add_memo_to_file(FILE_NAME_SEND_MSG, PREFIX_TRADE_PERIOD_H4, symbol, trend);

   string botToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
   string chatId_duydk = "5099224587";

   if(StringFind(message, "OPEN_TRADE") >= 0)
     {
      string str_count_trade = CountTrade(symbol);
      bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
      bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;

      if(trend == TREND_BUY && has_position_buy)
         return;

      if(trend == TREND_SEL && has_position_sel)
         return;

      if(is_allow_send_msg_telegram(symbol, PERIOD_W1, 10, trend) == false)
         return;
     }

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   string str_cur_price = " price:" + (string) price;

   Alert(get_vntime(), message + str_cur_price);

   string new_message = get_vntime() + message + str_cur_price;

   StringReplace(new_message, " ", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, OPEN_TRADE, "");
   StringReplace(new_message, "_", "%20");
   StringReplace(new_message, " ", "%20");

   string base_url="https://api.telegram.org";
   string url = StringFormat("%s/bot%s/sendMessage?chat_id=%s&text=%s", base_url, botToken, chatId_duydk, new_message);

   string cookie=NULL,headers;
   char   data[],result[];

   ResetLastError();

   int timeout = 60000; // 60 seconds
   int res=WebRequest("GET",url,cookie,NULL,timeout,data,0,result,headers);
   if(res==-1)
      Alert("WebRequest Error:", GetLastError(), ", URL: ", url, ", Headers: ", headers, "   ", MB_ICONERROR);
  }

//+------------------------------------------------------------------+
string get_prefix_trade_from_current_timeframe(ENUM_TIMEFRAMES period)
  {
   if(period == PERIOD_M5)
      return PREFIX_TRADE_PERIOD_M5;

   if(period ==  PERIOD_H1)
      return PREFIX_TRADE_PERIOD_H1;

   if(period ==  PERIOD_H4)
      return PREFIX_TRADE_PERIOD_H4;

   if(period ==  PERIOD_D1)
      return PREFIX_TRADE_PERIOD_D1;

   if(period ==  PERIOD_W1)
      return PREFIX_TRADE_PERIOD_W1;

   if(period ==  PERIOD_MN1)
      return PREFIX_TRADE_PERIOD_MO;

   return PREFIX_TRADE_PERIOD_H4;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_pre_timeframe(string PREFIX_TRADE_PERIOD)
  {
   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_W1)
      return PERIOD_D1;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_D1)
      return PERIOD_H4;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_H4)
      return PERIOD_H1;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_H1)
      return PERIOD_M5;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_M5)
      return PERIOD_M5;

   return PERIOD_H1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_prefix_trade_from_comments(string comments)
  {
   string low_comments = toLower(comments);

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_W1)) >= 0)
      return PREFIX_TRADE_PERIOD_W1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_D1)) >= 0)
      return PREFIX_TRADE_PERIOD_D1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H4)) >= 0)
      return PREFIX_TRADE_PERIOD_H4;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H1)) >= 0)
      return PREFIX_TRADE_PERIOD_H1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M5)) >= 0)
      return PREFIX_TRADE_PERIOD_M5;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_cur_timeframe(string PREFIX_TRADE_PERIOD)
  {
   string TRADE_PERIOD = "";
   string low_comments =toLower(PREFIX_TRADE_PERIOD);

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_W1)) >= 0)
      return PERIOD_W1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_D1)) >= 0)
      return PERIOD_D1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H4)) >= 0)
      return PERIOD_H4;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_H1)) >= 0)
      return PERIOD_H1;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M5)) >= 0)
      return PERIOD_M5;

   return PERIOD_H4;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcRisk()
  {
   double dbValueRisk = INIT_EQUITY * dbRiskRatio;
   double max_risk = INIT_EQUITY*0.1;
   if(dbValueRisk > max_risk)
     {
      Alert("(", INDI_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than " + (string) max_risk + " per order. Too dangerous.");
      return max_risk;
     }

   return dbValueRisk;
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
string get_vntime()
  {
   string cpu = "";
   string inputString = TerminalInfoString(TERMINAL_CPU_NAME);
   string startString = "Core ";
   string endString = " @";
   int startIndex = StringFind(inputString, startString) + 5;
   int endIndex = StringFind(inputString, endString);
   if(startIndex != -1 && endIndex != -1)
     {
      cpu = StringSubstr(inputString, startIndex, endIndex - startIndex);
     }
   StringReplace(cpu, "i5-", "");

   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9) ? (string) gmt_time.hour : "0" + (string) gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string str_date_time = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES);
   StringReplace(str_date_time, (string)gmt_time.year + ".", "");
   string vntime = "(" + str_date_time + ")    " + cpu + "   " + INDI_NAME + "   ";
   StringReplace(vntime, "GuardianAngel", "");
   return vntime;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_key(string prefix, string symbol, string trend, ENUM_TIMEFRAMES TIMEFRAME)
  {
   string date_time = (string)iTime(symbol, TIMEFRAME, 0);
   StringReplace(date_time, ":00:00", "h");
   StringReplace(date_time, "2024.", "");
   StringReplace(date_time, "2025.", "");
   StringReplace(date_time, "2026.", "");

   return date_time + ":" + prefix + ":" + trend + ":" + symbol +";";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename, string prefix, string symbol, string trend)
  {
   string open_trade_today = ReadFileContent(filename);

   ENUM_TIMEFRAMES TIMEFRAME = PERIOD_H4;
   if(prefix == PREFIX_TRADE_PERIOD_W1)
      TIMEFRAME = PERIOD_W1;
   if(prefix == PREFIX_TRADE_PERIOD_D1)
      TIMEFRAME = PERIOD_D1;
   if(prefix == PREFIX_TRADE_PERIOD_H4)
      TIMEFRAME = PERIOD_H4;
   if(prefix == PREFIX_TRADE_PERIOD_H1)
      TIMEFRAME = PERIOD_H1;

   string key = create_key(prefix, symbol, trend, TIMEFRAME);

   open_trade_today = open_trade_today + key;
   open_trade_today = CutString(open_trade_today);

   WriteFileContent(filename, open_trade_today);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteFileContent(string file_name, string content)
  {
   int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);

   if(fileHandle != INVALID_HANDLE)
     {
      FileWriteString(fileHandle, content);
      FileClose(fileHandle);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CutString(string originalString)
  {
   int originalLength = StringLen(originalString);
   if(originalLength > 1000)
     {
      int startIndex = originalLength - 1000;
      return StringSubstr(originalString, startIndex, 1000);
     }
   return originalString;
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
bool is_has_memo_in_file(string filename, string prefix, string symbol, string trend)
  {
   string open_trade_today = ReadFileContent(filename);

   ENUM_TIMEFRAMES TIMEFRAME = PERIOD_H4;
   if(prefix == PREFIX_TRADE_PERIOD_W1)
      TIMEFRAME = PERIOD_W1;
   if(prefix == PREFIX_TRADE_PERIOD_D1)
      TIMEFRAME = PERIOD_D1;
   if(prefix == PREFIX_TRADE_PERIOD_H4)
      TIMEFRAME = PERIOD_H4;
   if(prefix == PREFIX_TRADE_PERIOD_H1)
      TIMEFRAME = PERIOD_H1;

   string key = create_key(prefix, symbol, trend, TIMEFRAME);

   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_pass_min_time(string prefix, string symbol, string trend)
  {
   return (is_has_memo_in_file(FILE_NAME_OPEN_TRADE, prefix, symbol, trend) == false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_send_msg_telegram(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int length, string find_trend)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double lowest = 0.0;
   double higest = 0.0;
   for(int i = 0; i < length; i++)
     {
      double lowPrice = iLow(symbol, TIMEFRAME, i);
      double higPrice = iHigh(symbol, TIMEFRAME, i);

      if((i == 0) || (lowest > lowPrice))
         lowest = lowPrice;

      if((i == 0) || (higest < higPrice))
         higest = higPrice;
     }

   if(find_trend == TREND_BUY && (MathAbs(price - lowest) < week_amp))
      return true;

   if(find_trend == TREND_SEL && (MathAbs(higest - price) < week_amp))
      return true;

   return false;
  }

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
//---

  }
//+------------------------------------------------------------------+
string get_current_timeframe_to_string()
  {
   if(Period() == PERIOD_M5)
      return "M5";

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
string format_double_to_string(double number, int digits = 5)
  {

   string numberString = (string) NormalizeDouble(number, digits);
   StringReplace(numberString, "000000000001", "");
   StringReplace(numberString, "999999999999", "9");
   StringReplace(numberString, "999999999998", "9");
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

// Hàm tính toán Bollinger Bands
void CalculateBollingerBands(string symbol, ENUM_TIMEFRAMES timeframe, double& upper[], double& middle[], double& lower[], int digits, double deviation = 2)
  {
   int period = 20; // Số ngày cho chu kỳ Bollinger Bands
// double deviation = 2; // Độ lệch chuẩn cho Bollinger Bands
   int shift = 0; // Vị trí trên biểu đồ
   int count = 50;//Bars(symbol, timeframe); // Số nến trên biểu đồ

   for(int i = 0; i < count; i++)
     {
      double sum = 0.0;
      double sumSquared = 0.0;

      for(int j = 0; j < period; j++)
        {
         double price = iClose(symbol, timeframe, i + shift + j);
         sum += price;
         sumSquared += price * price;
        }

      double variance = sumSquared / period - (sum / period) * (sum / period);
      double stddev = MathSqrt(variance);

      double middle_i = sum / period;
      double upper_i = middle_i + deviation * stddev;
      double lower_i = middle_i - deviation * stddev;

      ArrayResize(middle, i + 1);
      ArrayResize(upper, i + 1);
      ArrayResize(lower, i + 1);

      middle[i] = format_double(middle_i, digits);
      upper[i] = format_double(upper_i, digits);
      lower[i] = format_double(lower_i, digits);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int m_handle_macd = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
      return "";

   double m_buff_MACD_main[];
   double m_buff_MACD_signal[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);

   CopyBuffer(m_handle_macd, 0, 0, 2, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 2, m_buff_MACD_signal);

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
string get_trend_consensus_by_long_term_and_short_term_stoc(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_long_term = get_trend_by_stoc2(symbol, timeframe, 13, 8, 5, 0);
   string trend_shot_term = get_trend_by_stoc2(symbol, timeframe,  5, 3, 3, 0);

   if(trend_long_term == trend_shot_term)
      return trend_long_term;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc2(string symbol, ENUM_TIMEFRAMES timeframe, int inK = 13, int inD = 8, int inS = 5, int candle_no = 0)
  {
   int handle_iStochastic = iStochastic(symbol, timeframe, inK, inD, inS, MODE_SMA, STO_LOWHIGH);
   if(handle_iStochastic == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, int candle_no = 1)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   if(K[candle_no] > D[candle_no])
      return TREND_BUY;

   if(K[candle_no] < D[candle_no])
      return TREND_SEL;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_stoch(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {
   if(is_must_StayOut_or_TakeProfit_by_stoc_Extrema(symbol, TIMEFRAME, find_trend, 3, 3, 3))
      return true;

   if(is_must_StayOut_or_TakeProfit_by_stoc_Extrema(symbol, TIMEFRAME, find_trend, 5, 3, 3))
      return true;

   if(is_must_StayOut_or_TakeProfit_by_stoc_Extrema(symbol, TIMEFRAME, find_trend, 7, 3, 3))
      return true;

   if(is_must_StayOut_or_TakeProfit_by_stoc_Extrema(symbol, TIMEFRAME, find_trend, 9, 5, 3))
      return true;

   if(is_must_StayOut_or_TakeProfit_by_stoc_Extrema(symbol, TIMEFRAME, find_trend, 11, 5, 3))
      return true;

   if(is_must_StayOut_or_TakeProfit_by_stoc_Extrema(symbol, TIMEFRAME, find_trend, 13, 8, 5))
      return true;


   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 3, 3, 3))
      return true;

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 5, 3, 3))
      return true;

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 7, 3, 3))
      return true;

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 9, 5, 3))
      return true;

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 11, 5, 3))
      return true;

   if(is_allow_BuyAtBottom_SellAtTop_by_iStochastic(symbol, TIMEFRAME, find_trend, 13, 8, 5))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_StayOut_or_TakeProfit_by_stoc_Extrema(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   int handle = iStochastic(symbol, timeframe, inK, inD, inS, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return true;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if(find_trend == TREND_BUY && black_K >= 80 && red_D >= 80)
      return true;

   if(find_trend == TREND_SEL && black_K <= 20 && red_D <= 20)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_BuyAtBottom_SellAtTop_by_iStochastic(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   int handle = iStochastic(symbol, timeframe, inK, inD, inS, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return false;

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if(find_trend == TREND_BUY && black_K >= red_D && red_D <= 20)
      return true;
   if(find_trend == TREND_BUY && black_K >= red_D && (K[1] <= 20 || K[2] <= 20 || D[0] <= 20 || D[1] <= 20))
      return true;

   if(find_trend == TREND_SEL && black_K <= red_D && red_D >= 80)
      return true;
   if(find_trend == TREND_SEL && black_K <= red_D && (K[1] >= 80 || K[2] >= 80 || D[0] >= 80 || D[1] >= 80))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);

   double black_K = K[0];
   double red_D = D[0];

   if(black_K > red_D && black_K <= 20 && red_D <= 20)
      return TREND_BUY;

   if(black_K < red_D && black_K >= 80 && red_D >= 80)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_candle_switch_trend_stoch(string symbol, ENUM_TIMEFRAMES timeframe, int inK, int inD, int inS)
  {
   int handle = iStochastic(symbol, timeframe, inK, inD, inS, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,50,K);
   CopyBuffer(handle,1,0,50,D);

// Tìm vị trí x thỏa mãn điều kiện
   int index = -1;  // Nếu không tìm thấy, giá trị của x sẽ là -1

   for(int i = 0; i < ArraySize(K) - 1; i++)
     {
      if((K[i] <= D[i] && K[i + 1] >= D[i + 1]) || (K[i] >= D[i] && K[i + 1] <= D[i + 1]))
        {
         // Nếu tìm thấy, lưu vị trí x và kết thúc vòng lặp
         index = i;
         break;
        }
     }

   if(index != -1)
     {
      return (K[0] > D[0] ? TREND_BUY : TREND_SEL) + "(" + (string)(index) + ")"; ;
     }
   else
     {
      return "";
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_stoch(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int handle = iStochastic(symbol, timeframe, periodK, periodD, slowing, MODE_SMA, STO_LOWHIGH);
   if(handle == INVALID_HANDLE)
      return "";

   double K[],D[];
   ArraySetAsSeries(K, true);
   ArraySetAsSeries(D, true);
   CopyBuffer(handle,0,0,10,K);
   CopyBuffer(handle,1,0,10,D);


   int i = 0;
   if((K[i] < D[i] && K[i + 1] > D[i + 1]) || (K[i] > D[i] && K[i + 1] < D[i + 1]))
     {
      if(K[i] >= D[i])
         return TREND_BUY;

      if(K[i] <= D[i])
         return TREND_SEL;
     }

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_amp_week(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int size = 20)
  {
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_week_amp(symbol, TIMEFRAME, index);
     }
   double week_amp = total_amp / size;

   return week_amp;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_week_amp(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int week_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double week_hig = iHigh(symbol,  TIMEFRAME, week_index);
   double week_low = iLow(symbol,   TIMEFRAME, week_index);
   double week_clo = iClose(symbol, TIMEFRAME, week_index);

   double w_pivot    = format_double((week_hig + week_low + week_clo) / 3, digits);
   double week_s1    = format_double((2 * w_pivot) - week_hig, digits);
   double week_s2    = format_double(w_pivot - (week_hig - week_low), digits);
   double week_s3    = format_double(week_low - 2 * (week_hig - w_pivot), digits);
   double week_r1    = format_double((2 * w_pivot) - week_low, digits);
   double week_r2    = format_double(w_pivot + (week_hig - week_low), digits);
   double week_r3    = format_double(week_hig + 2 * (w_pivot - week_low), digits);

   double week_amp = MathAbs(week_s3 - week_s2)
                     + MathAbs(week_s2 - week_s1)
                     + MathAbs(week_s1 - w_pivot)
                     + MathAbs(w_pivot - week_r1)
                     + MathAbs(week_r1 - week_r2)
                     + MathAbs(week_r2 - week_r3);

   week_amp = format_double(week_amp / 6, digits);

   return week_amp;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestInitIndicator()
  {
//return;

   if(DEBUG_ON_HISTORY_DATA == false)
      return;

   Comment(GetComments());
   iMA(_Symbol,PERIOD_CURRENT,3,0,MODE_SMA,PRICE_CLOSE);
   iMA(_Symbol,PERIOD_CURRENT,6,0,MODE_SMA,PRICE_CLOSE);
   iMA(_Symbol,PERIOD_CURRENT,9,0,MODE_SMA,PRICE_CLOSE);

   if(Period() <= PERIOD_H4)
     {
      iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE);
      iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_SMA,PRICE_CLOSE);
     }

   iStochastic(_Symbol, PERIOD_CURRENT, 3, 3, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 7, 3, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 9, 5, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 11, 5, 3, MODE_SMA, STO_LOWHIGH);
   iStochastic(_Symbol, PERIOD_CURRENT, 13, 8, 5, MODE_SMA, STO_LOWHIGH);

   if(Period() <= PERIOD_H4)
      iStochastic(_Symbol, PERIOD_CURRENT, 21, 17, 5, MODE_SMA, STO_LOWHIGH);

   DrawBB();

   Draw_Heikens();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicators()
  {
   if(DEBUG_ON_HISTORY_DATA)
      return;

   Draw_Entry(_Symbol);

   Draw_Amp_D_Wave(_Symbol);

   Draw_PivotHorizontal_TimeVertical();

   DrawBB();

   CalculatePivot("PERIOD_W1", PERIOD_W1);

   CalculateAvgCandleHeigh("PERIOD_W1", PERIOD_W1);
  }


//+------------------------------------------------------------------+
void CalculateAvgCandleHeigh(string prifix, ENUM_TIMEFRAMES TIME_FRAME)
  {
   string yyyymmdd = TimeToString(TimeGMT(), TIME_DATE);
   string yearMonth = StringSubstr(yyyymmdd, 0, 7);
   string filename = "AVG_CANDLE_HEIGH_" + prifix + "_" + yearMonth + ".txt";

   if(FileIsExist(filename))
     {
      // Nếu tệp tồn tại, hiển thị thông báo
      // Alert("Tệp ", filename, " tồn tại.");
     }
   else
     {
      //-------------------------------------------------------------------------------------------------------------------------------
      FileDelete(filename);
      int nfile_w_pivot = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

      if(nfile_w_pivot != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places

            //-------------------------------------------------------------------------------------------------------------------------
            double Avg_Amp_W1 = CalculateAverageCandleHeight(TIME_FRAME, symbol);
            FileWrite(nfile_w_pivot, symbol, format_double_to_string(Avg_Amp_W1, digits));
           } //for
         //--------------------------------------------------------------------------------------------------------------------
         FileClose(nfile_w_pivot);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol)
  {
   double totalHeight = 0.0;

// Tính tổng chiều cao của 10 cây nến M1
   for(int i = 0; i < 50; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      totalHeight += candleHeight;
     }

// Tính chiều cao trung bình
   double averageHeight = totalHeight / 10.0;

   return averageHeight;
  }
//+------------------------------------------------------------------+
void CalculatePivot(string prifix, ENUM_TIMEFRAMES TIME_FRAME)
  {
   string yyyymmdd = TimeToString(TimeGMT(), TIME_DATE);
   string yearMonth = StringSubstr(yyyymmdd, 0, 7);
   string filename = "AVG_AMP_" + prifix + "_" + yearMonth + ".txt";

   if(FileIsExist(filename))
     {
      // Nếu tệp tồn tại, hiển thị thông báo
      // Alert("Tệp ", filename, " tồn tại.");
     }
   else
     {
      //-------------------------------------------------------------------------------------------------------------------------------
      FileDelete(filename);
      int nfile_w_pivot = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, '\t', CP_UTF8);

      if(nfile_w_pivot != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);          // number of decimal places

            //-------------------------------------------------------------------------------------------------------------------------
            double Avg_Amp_W1 = calc_avg_amp_week(symbol, TIME_FRAME, 50);
            FileWrite(nfile_w_pivot, symbol, format_double_to_string(Avg_Amp_W1, digits));
           } //for
         //--------------------------------------------------------------------------------------------------------------------
         FileClose(nfile_w_pivot);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int totalObjects = ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
      if(StringFind(objectName, "redrw_") >= 0 || StringFind(objectName, "dkd") >= 0)
         ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
   if(!time1)
      time1=TimeGMT();
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];

      time2=time1;
     }
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   price2=price1;
  }

//+------------------------------------------------------------------+
bool create_rectangle(
   const string          name="Rectangle",  // rectangle name
   datetime              time1=0,           // first point time
   double                price1=0,          // first point price (Open)
   datetime              time2=0,           // second point time
   double                price2=0,          // second point price (Close)
   const color           def_color=clrBlack,
   const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
   const int             width=1,           // width of rectangle lines
   const bool            fill=false,        // filling rectangle with color
   const bool            background=false,        // in the background
   const bool            selection=false,    // highlight to move
   const bool            hidden=true,       // hidden in the object list
   const long            z_order=0         // priority for mouse click
)
  {
   int sub_window=0;      // subwindow index
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
   ResetLastError();
   if(!ObjectCreate(0,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }

   color clr = get_line_color(price1, price2);
   if(def_color != clrBlack)
     {
      clr = def_color;
     }

   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_FILL,fill);
   ObjectSetInteger(0,name,OBJPROP_BACK,background);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color get_line_color(double open_price, double close_price)
  {
   color candle_color = clrDarkGreen;
   if(open_price > close_price)
     {
      candle_color = clrFireBrick;
     }

   return candle_color;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_amp_trade(string symbol, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

   double amp_trade = week_amp;
   if(TIMEFRAME <= PERIOD_H4)
      amp_trade = week_amp / 2;

//if(TIMEFRAME == PERIOD_H1)
//   amp_trade = week_amp / 8;
//if(TIMEFRAME < PERIOD_H1)
//   amp_trade = week_amp / 16;
   return amp_trade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Amp_D_Wave(string symbol)
  {
   if(DEBUG_ON_HISTORY_DATA)
      return;

   if(Period() != PERIOD_D1 && Period() != PERIOD_H4 && Period() != PERIOD_H1)
      return;

   ENUM_TIMEFRAMES TIMEFRAME = Period();
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double dic_top_price;
   double dic_amp_w;
   double dic_amp_init_h4;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_amp_init_h4, dic_amp_init_d1);
   double week_amp = dic_amp_w;
   double amp_percent = dic_amp_init_d1;

   int size = 55;
   string prefix = "d1";

   if(Period() == PERIOD_H1)
     {
      size = 65;
      prefix = "h1";
      amp_percent = dic_amp_init_h4/2;
     }

   bool is_h4 = (Period() == PERIOD_H4);
   if(is_h4)
     {
      size = 99;
      prefix = "h4";
      amp_percent = dic_amp_init_h4;
     }

   double lowest = 0;
   double higest = 0;
   int candle_index_buy = 1;
   int candle_index_sel = 1;

   int low_idx_h4_55 = 0, hig_idx_h4_55 = 0;
   double low_h4_55 = iClose(symbol, TIMEFRAME, 0), hig_h4_55 = 0.0;

   for(int i = 0; i <= size; i++)
     {
      double close = iClose(symbol, TIMEFRAME, i);

      if(i == 0 || higest <= close)
        {
         higest = close;
         candle_index_sel = i;
        }
      if(i == 0 || lowest >= close)
        {
         lowest = close;
         candle_index_buy = i;
        }


      if((is_h4 && i <= 45) && (hig_h4_55 <= close))
        {
         hig_h4_55 = close;
         hig_idx_h4_55 = i;
        }
      if((is_h4 && i <= 45) && (low_h4_55 >= close))
        {
         low_h4_55 = close;
         low_idx_h4_55 = i;
        }
     }
   bool is_bold = false;

   if(true)
     {
      //vẽ BUY
      datetime cur_time = iTime(symbol, TIMEFRAME, (candle_index_buy-2>0?candle_index_buy-2:0));
      if(Period() == PERIOD_H4)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_buy + 3);
      if(Period() == PERIOD_H1)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_buy + 3);

      datetime nex_time = iTime(symbol, TIMEFRAME, (candle_index_buy-3>0?candle_index_buy-3:candle_index_buy+3));

      double nex_price_1 = lowest*(1 + amp_percent*1);
      double nex_price_2 = lowest*(1 + amp_percent*2);
      double nex_price_3 = lowest*(1 + amp_percent*3);

      create_trend_line(prefix + ".buy_0", cur_time, nex_time, lowest,      clrGreen, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_1", cur_time, nex_time, nex_price_1, clrGreen, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_2", cur_time, nex_time, nex_price_2, clrGreen, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".buy_3", cur_time, nex_time, nex_price_3, clrGreen, digits, false, false, is_bold, true);

      create_lable(prefix + ".lbl.buy_0",  nex_time, lowest, (string)(amp_percent*000) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_1",  nex_time, nex_price_1, (string)(amp_percent*100) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_2",  nex_time, nex_price_2, (string)(amp_percent*200) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.buy_3",  nex_time, nex_price_3, (string)(amp_percent*300) +"%", clrBlack, digits);

      if(is_h4 && low_idx_h4_55 != candle_index_buy)
        {
         datetime time_w0_h4_fr = iTime(symbol, TIMEFRAME, (low_idx_h4_55-3>0?low_idx_h4_55-3:0));
         datetime time_w0_h4_to = iTime(symbol, TIMEFRAME, low_idx_h4_55+3);

         create_lable("lbl.w0.h4.buy_0",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*0), (string)(amp_percent*000) +"%", clrGreen, digits);
         create_lable("lbl.w0.h4.buy_1",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*1), (string)(amp_percent*100) +"%", clrGreen, digits);
         create_lable("lbl.w0.h4.buy_2",  time_w0_h4_fr, low_h4_55*(1 + amp_percent*2), (string)(amp_percent*200) +"%", clrGreen, digits);

         create_trend_line("w0.h4.buy_0", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*0), clrGreen, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.buy_1", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*1), clrGreen, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.buy_2", time_w0_h4_fr, time_w0_h4_to, low_h4_55*(1 + amp_percent*2), clrGreen, digits, false, false, is_bold, true);
        }
     }

   if(true)
     {
      //vẽ SELL
      datetime cur_time = iTime(symbol, TIMEFRAME, (candle_index_sel-2>0?candle_index_sel-2:0));
      if(Period() == PERIOD_H4)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_sel + 3);
      if(Period() == PERIOD_H1)
         cur_time = iTime(symbol, TIMEFRAME, candle_index_sel + 3);

      datetime nex_time = iTime(symbol, TIMEFRAME, (candle_index_sel-3>0?candle_index_sel-3:candle_index_sel+3));

      double nex_price_1 = higest*(1 - amp_percent*1);
      double nex_price_2 = higest*(1 - amp_percent*2);
      double nex_price_3 = higest*(1 - amp_percent*3);

      create_trend_line(prefix + ".sel_0", cur_time, nex_time, higest,      clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_1", cur_time, nex_time, nex_price_1, clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_2", cur_time, nex_time, nex_price_2, clrFireBrick, digits, false, false, is_bold, true);
      create_trend_line(prefix + ".sel_3", cur_time, nex_time, nex_price_3, clrFireBrick, digits, false, false, is_bold, true);

      create_lable(prefix + ".lbl.sel_0",  nex_time, higest, (string)(amp_percent*000) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_1",  nex_time, nex_price_1, (string)(amp_percent*100) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_2",  nex_time, nex_price_2, (string)(amp_percent*200) +"%", clrBlack, digits);
      create_lable(prefix + ".lbl.sel_3",  nex_time, nex_price_3, (string)(amp_percent*300) +"%", clrBlack, digits);

      if(is_h4 && low_idx_h4_55 != candle_index_sel)
        {
         datetime time_w0_h4_fr = iTime(symbol, TIMEFRAME, (hig_idx_h4_55-3>0?hig_idx_h4_55-3:0));
         datetime time_w0_h4_to = iTime(symbol, TIMEFRAME, hig_idx_h4_55+3);

         create_lable("lbl.w0.h4.sel_0",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*0), (string)(amp_percent*000) +"%",  clrFireBrick, digits);
         create_lable("lbl.w0.h4.sel_1",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*1), (string)(amp_percent*100) +"%",  clrFireBrick, digits);
         create_lable("lbl.w0.h4.sel_2",  time_w0_h4_fr, hig_h4_55*(1 - amp_percent*2), (string)(amp_percent*200) +"%",  clrFireBrick, digits);

         create_trend_line("w0.h4.sel_0", time_w0_h4_fr, time_w0_h4_to, hig_h4_55,                     clrFireBrick, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.sel_1", time_w0_h4_fr, time_w0_h4_to, hig_h4_55*(1 - amp_percent*1), clrFireBrick, digits, false, false, is_bold, true);
         create_trend_line("w0.h4.sel_2", time_w0_h4_fr, time_w0_h4_to, hig_h4_55*(1 - amp_percent*2), clrFireBrick, digits, false, false, is_bold, true);
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heikens()
  {
   if(Period() == PERIOD_H4 || Period() == PERIOD_H1)
      Draw_Heiken(_Symbol, PERIOD_D1, 25);

   if(Period() == PERIOD_D1)
      Draw_Heiken(_Symbol, PERIOD_MN1, 10);

   if(Period() == PERIOD_H4 || Period() == PERIOD_D1)
      Draw_Heiken(_Symbol, PERIOD_W1, 25);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heiken(string symbol, ENUM_TIMEFRAMES PERIOD_XX, int length)
  {
   CandleData arr_w[];
   get_arr_heiken(symbol, PERIOD_XX, arr_w, length);
   string prefix = get_prefix_trade_from_current_timeframe(PERIOD_XX) + "_";

   bool is_solid = true;
   datetime time_1d = iTime(symbol, PERIOD_D1, 1) - iTime(symbol, PERIOD_D1, 2);
   if(PERIOD_XX < PERIOD_W1)
      is_solid = false;

   for(int i = 0; i < ArraySize(arr_w) - 2; i++)
     {
      CandleData candle_i = arr_w[i];
      string sub_name = "_" + (string)(i+1) + "_" + (string)i;
      datetime time_i1;

      datetime time_i2 = iTime(symbol, PERIOD_XX, i);
      if(i == 0)
        {
         time_i1 = time_i2 + time_1d * 1;

         if(PERIOD_XX == PERIOD_MN1)
            time_i1 = time_i2 + time_1d * 30;

         if(PERIOD_XX == PERIOD_W1)
            time_i1 = time_i2 + time_1d * 5;
        }
      else
        {
         time_i1 = iTime(symbol, PERIOD_XX, i-1);
        }

      //datetime time_mi = (time_i1 + time_i2) / 2;

      string candle_x = toLower(prefix);
      StringReplace(candle_x, "1", "");
      StringReplace(candle_x, "_", "");

      if(DEBUG_ON_HISTORY_DATA && Period() == PERIOD_H4)
         candle_x += (candle_i.trend == TREND_BUY ? "B" : "S");

      candle_x += (string) candle_i.count + "\n"; // +

      color clrColor = candle_i.trend == TREND_BUY ? clrCadetBlue : clrFireBrick;

      create_lable_trim(prefix + "lbl"  + sub_name, time_i2, MathMax(candle_i.open, candle_i.close), candle_x, clrColor, 5, 8, ANCHOR_LEFT_LOWER);
      create_line(prefix + "open"  + sub_name, time_i2, candle_i.open,  time_i1, candle_i.open,  clrColor, is_solid);
      create_line(prefix + "close" + sub_name, time_i2, candle_i.close, time_i1, candle_i.close, clrColor, is_solid);
      create_line(prefix + "left"  + sub_name, time_i2, candle_i.open,  time_i2, candle_i.close, clrColor, is_solid);
      create_line(prefix + "right" + sub_name, time_i1, candle_i.open,  time_i1, candle_i.close, clrColor, is_solid);
      //create_line(prefix + "top"   + sub_name, time_mi, MathMax(candle_i.open, candle_i.close),  time_mi, candle_i.high, clrColor, is_solid);
      //create_line(prefix + "bot"   + sub_name, time_mi, MathMin(candle_i.open, candle_i.close),  time_mi, candle_i.low,  clrColor, is_solid);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBB()
  {
   string symbol = Symbol();

   datetime label_postion = iTime(symbol, _Period, 0);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   string tradingview_symbol = get_tradingview_symbol(symbol);

   double d1_ma10 = cal_MA_XX(symbol, PERIOD_D1, 10, 0); //get_ma_value(symbol, PERIOD_D1, 10, 0);
   double h4_ma50 = cal_MA_XX(symbol, PERIOD_H4, 50, 0); //get_ma_value(symbol, PERIOD_H4, 50, 0);

   string lable_d1 = "   -------------D(10) " + tradingview_symbol + free_overnight(tradingview_symbol);
// + " D: " + get_candle_switch_trend_stoch(symbol, PERIOD_D1, 13, 8, 5);

   string lable_h4 = "   ---H4(50)"; // + " iStoc13: " + get_candle_switch_trend_stoch(symbol, PERIOD_H4, 13, 8, 5);

   create_lable_trim("d1_ma10", label_postion, d1_ma10, lable_d1, clrGreen, digits, 9);
   create_lable_trim("h4_ma50", label_postion, h4_ma50, lable_h4, clrGreen, digits, 9);


   if(Period() > PERIOD_D1)
      return;

   string str_line = "   ";
   for(int index = 1; index <= 3; index++)
      str_line += "-";


   double upper_d1_20_1[], middle_d1_20_1[], lower_d1_20_1[];
   CalculateBollingerBands(symbol, PERIOD_D1, upper_d1_20_1, middle_d1_20_1, lower_d1_20_1, digits, 1);
   double hi_d1_20_1 = upper_d1_20_1[0];
   double mi_d1_20_0 = middle_d1_20_1[0];
   double lo_d1_20_1 = lower_d1_20_1[0];

   double amp_d1 = MathAbs(hi_d1_20_1 - mi_d1_20_0);

   string str_stop = " D(00)";

   double upper_h1[], middle_h1[], lower_h1[];
   CalculateBollingerBands(symbol, PERIOD_H1, upper_h1, middle_h1, lower_h1, digits, 1);
   double mi_h1_20_0 = middle_h1[0];
   double amp_h1 = MathAbs(upper_h1[0] - middle_h1[0]);
   double hi_h1_20_2 = mi_h1_20_0 + amp_h1*2;
   double lo_h1_20_2 = mi_h1_20_0 - amp_h1*2;
   create_lable_trim("Hi_H1(20, 2)", label_postion, hi_h1_20_2, str_line + "------------------H1+2", clrGreen, digits);
   create_lable_trim("Lo_H1(20, 2)", label_postion, lo_h1_20_2, str_line + "------------------H1-2", clrGreen, digits);

//double upper_15[], middle_15[], lower_15[];
//CalculateBollingerBands(symbol, PERIOD_M15, upper_15, middle_15, lower_15, digits, 1);
//double mi_15_20_0 = middle_15[0];
//double amp_15 = MathAbs(upper_15[0] - middle_15[0]);
//double hi_15_20_2 = mi_15_20_0 + amp_15*2;
//double lo_15_20_2 = mi_15_20_0 - amp_15*2;
//create_lable_trim("Hi_M15(20, 2)", label_postion, hi_15_20_2, str_line + "---------------------------15+2", clrGreen, digits);
//create_lable_trim("Lo_M15(20, 2)", label_postion, lo_15_20_2, str_line + "---------------------------15-2", clrGreen, digits);

   double upper_h4[], middle_h4[], lower_h4[];
   CalculateBollingerBands(symbol, PERIOD_H4, upper_h4, middle_h4, lower_h4, digits, 1);
   double mi_h4_20_0 = middle_h4[0];
   double amp_h4 = MathAbs(upper_h4[0] - middle_h4[0]);

   double hi_h4_20_2 = mi_h4_20_0 + amp_h4*2;
   double lo_h4_20_2 = mi_h4_20_0 - amp_h4*2;


   create_lable_trim("Hi_H4(20, 2)", label_postion, hi_h4_20_2, str_line + "---------H4+2", clrGreen, digits);
   create_lable_trim("Lo_H4(20, 2)", label_postion, lo_h4_20_2, str_line + "---------H4-2", clrGreen, digits);

   ObjectSetInteger(0, "redrw_" + "mi_d1_20_0", OBJPROP_STYLE, STYLE_DASH);
   for(int i = 2; i<=5; i++)
     {
      bool is_solid = false;
      bool is_ray_left = (i==2) ? true : false;
      color line_color = clrGreen;
      if(i == 1)
         line_color = clrDimGray;
      if(i == 2)
         line_color = clrGreen;
      if(i == 3)
         line_color = clrMediumSeaGreen;
      if(i == 4)
         line_color = clrGreen;
      if(i == 5)
         line_color = clrRed;
      line_color = clrGreen;

      double hi_d1_20_i = mi_d1_20_0 + (i*amp_d1);
      double lo_d1_20_i = mi_d1_20_0 - (i*amp_d1);

      create_lable_trim("lbl_hi_d1_20_" + (string)i, label_postion, hi_d1_20_i, str_line + " D+" + (string)i + "", line_color, digits);
      create_lable_trim("lbl_lo_d1_20_" + (string)i, label_postion, lo_d1_20_i, str_line + " D-" + (string)i + "", line_color, digits);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Entry(string symbol)
  {
   if(DEBUG_ON_HISTORY_DATA)
      return;

   int SMA_Handle = iMA(symbol,PERIOD_CURRENT,6,0,MODE_SMA,PRICE_CLOSE);
   if(SMA_Handle == INVALID_HANDLE)
      return;

   double SMA_Buffer[];
   ArraySetAsSeries(SMA_Buffer, true);
   if(CopyBuffer(SMA_Handle,0,0,5,SMA_Buffer)>0)
     {
      ObjectDelete(0,"TREND_BY_ANGLE_2");
      ObjectCreate(0,"TREND_BY_ANGLE_2",OBJ_TRENDBYANGLE,0
                   , iTime(_Symbol,PERIOD_CURRENT,2), SMA_Buffer[2]
                   , iTime(_Symbol,PERIOD_CURRENT,1), SMA_Buffer[1]);
      ObjectSetInteger(0,"TREND_BY_ANGLE_2",OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0,"TREND_BY_ANGLE_2",OBJPROP_RAY_RIGHT,true);
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            ulong ticket = m_position.Ticket();
            double price_open = m_position.PriceOpen();

            datetime time = m_position.Time();
            string comments = m_position.Comment();
            string str_profit = StringFind(toLower(m_position.TypeDescription()), "buy") >= 0 ? "(B)" : "(S)" ;
            str_profit += (string) m_position.Profit() + "$";

            datetime nex_time = time - (iTime(symbol, PERIOD_H1, 1) - iTime(symbol, PERIOD_H1, 10));
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

            color clr_profit_color = clrGreen;
            if(m_position.Profit() < 0)
               clr_profit_color = clrRed;

            color clr_trade2_color = StringFind(toLower(m_position.TypeDescription()), "buy") >= 0 ? clrGreen : clrRed ;

            ENUM_TIMEFRAMES TRADE_PERIOD = get_cur_timeframe(comments);
            double amp_trade_default = get_amp_trade(symbol, TRADE_PERIOD);

            create_lable("lbl_" + (string) ticket, time, price_open, str_profit, clr_profit_color, digits);

           }
        }
     }
  }

//+------------------------------------------------------------------+
void Draw_PivotHorizontal_TimeVertical()
  {
   if(DEBUG_ON_HISTORY_DATA)
      return;

   string symbol = Symbol();
   datetime yesterday_time   = iTime(symbol, PERIOD_D1, 1);
   datetime today_open_time   = yesterday_time + 86400;
   datetime today_close_time   = today_open_time + 86400;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

// -----------------------------------------------------------------------
   ENUM_TIMEFRAMES chartPeriod = Period(); // Lấy khung thời gian của biểu đồ
   datetime close_time_today = iTime(symbol, PERIOD_D1, 0) + 86400;
   double   yesterday_open   = iOpen(symbol, PERIOD_D1, 1);
   double   yesterday_close  = iClose(symbol, PERIOD_D1, 1);
   double   yesterday_high   = iHigh(symbol, PERIOD_D1, 1);
   double   yesterday_low    = iLow(symbol, PERIOD_D1, 1);
   color    yesterday_color  = get_line_color(yesterday_open, yesterday_close);

   double   today_open = iOpen(symbol, PERIOD_D1, 0);
   double   today_close = iClose(symbol, PERIOD_D1, 0);
   double   today_low = iLow(symbol, PERIOD_D1, 0);
   double   today_hig = iHigh(symbol, PERIOD_D1, 0);

   double pre_day_mid = (yesterday_high + yesterday_low) / 2.0;
   double today_mid = (today_hig + today_low) / 2.0;
   color day_mid_color = get_line_color(pre_day_mid, today_mid);

// -----------------------------------------------------------------------
   double dic_top_price;
   double dic_amp_w;
   double dic_avg_candle_week;
   double dic_amp_init_d1;
   GetSymbolData(symbol, dic_top_price, dic_amp_w, dic_avg_candle_week, dic_amp_init_d1);
   double week_amp = dic_amp_w;

// -----------------------------------------------------------------------
   datetime time_1day = iTime(_Symbol, PERIOD_D1, 1) - iTime(_Symbol, PERIOD_D1, 2);

   datetime week_time_1 = iTime(symbol, PERIOD_W1, 1); //Returns the opening time of the bar
   datetime shift_chart = iTime(_Symbol, _Period, 0) - iTime(_Symbol, _Period, 10);
   datetime time_candle_cur = iTime(_Symbol, _Period, 0) + shift_chart;


//   for(int index = 0; index < 150; index ++)
//      if(Period() < PERIOD_H1)
//         create_vertical_line("H4_"+(string)index, iTime(_Symbol, PERIOD_H4, index), clrSilver, STYLE_DOT);
//      else
//         ObjectDelete(0, "H4_"+(string)index);
//
//
//   for(int index = 0; index < 150; index ++)
//      if(Period() < PERIOD_D1)
//         create_vertical_line("D"+(string)index, iTime(_Symbol, PERIOD_D1, index), clrSilver, STYLE_DOT);
//      else
//         ObjectDelete(0, "D"+(string)index);


//for(int index = 0; index < 35; index ++)
//   if(Period() < PERIOD_W1)
//      create_vertical_line("W"+(string)index,  iTime(symbol, PERIOD_W1, index),  clrBlack,STYLE_DASHDOTDOT, 2);
//   else
//      ObjectDelete(0, "W"+(string)index);


   for(int index = 0; index < 10; index ++)
     {
      if(Period() == PERIOD_D1)
         create_vertical_line("Mo"+(string)index,  iTime(symbol, PERIOD_MN1, index), clrBlack, STYLE_SOLID, 1);
      else
         ObjectDelete(0, "Mo"+(string)index);
     }

   bool allow_redraw_trendline = false;
   for(int index = 0; index < 35; index ++)
     {
      color line_color = clrBlack;
      bool is_solid = false;

      double w_s1  = dic_top_price - (week_amp*index);
      create_trend_line("w_dn_" + (string)index, week_time_1, TimeGMT(), w_s1, line_color, digits, true, true, is_solid, allow_redraw_trendline);
      ObjectSetInteger(0, "w_dn_" + (string)index, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(0, "w_dn_" + (string)index, OBJPROP_COLOR, clrSilver);

      double w_r1  = dic_top_price + (week_amp*index);
      create_trend_line("w_up_" + (string)index, week_time_1, TimeGMT(), w_r1, line_color, digits, true, true, is_solid, allow_redraw_trendline);
      ObjectSetInteger(0, "w_up_" + (string)index, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSetInteger(0, "w_up_" + (string)index, OBJPROP_COLOR, clrSilver);
     }

//   if(Period() > PERIOD_H4)
//     {
//      double lowest = 0.0;
//      double higest = 0.0;
//      for(int i = 0; i <= 21; i++)
//        {
//         double lowPrice = iLow(symbol, PERIOD_W1, i);
//         double higPrice = iHigh(symbol, PERIOD_W1, i);
//
//         if((i == 0) || (lowest > lowPrice))
//            lowest = lowPrice;
//
//         if((i == 0) || (higest < higPrice))
//            higest = higPrice;
//        }
//
//      double mid_price = NormalizeDouble((higest + lowest) / 2, digits-1);
//      datetime time_pre_21w = iTime(symbol, PERIOD_W1, 21);
//
//      create_trend_line("low_21w", time_pre_21w, TimeCurrent(), lowest,    clrViolet, digits, false, false, false, allow_redraw_trendline);
//      create_trend_line("mid_21w", time_pre_21w, TimeCurrent(), mid_price, clrFireBrick,  digits, false, false, false, allow_redraw_trendline);
//      create_trend_line("hig_21w", time_pre_21w, TimeCurrent(), higest,    clrTomato,     digits, false, false, false, allow_redraw_trendline);
//
//      ObjectSetInteger(0, "low_21w", OBJPROP_STYLE, STYLE_SOLID);
//      ObjectSetInteger(0, "hig_21w", OBJPROP_STYLE, STYLE_SOLID);
//      ObjectSetInteger(0, "mid_price", OBJPROP_WIDTH, 1);
//      ObjectSetInteger(0, "mid_price", OBJPROP_COLOR, clrFireBrick);
//     }
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
//string name = "redrw_" + name0;
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
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"redrw_" + name, 0, time_to, price, "        " + format_double_to_string(price, digits), clr_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5
)
  {
   TextCreate(0,"redrw_" + name, 0, time_to, price, "        " + label, clr_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_trim(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const int               font_size=8,
   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT
)
  {
   TextCreate(0,"redrw_" + name, 0, time_to, price, label, clr_color);
   ObjectSetInteger(0,"redrw_" + name, OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(0,"redrw_" + name,OBJPROP_ANCHOR, anchor);
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
                const int               font_size=8,             // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,     // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,             // hidden in the object list
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
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               digits=5,
   const bool              ray_left = false,
   const bool              ray_right = true,
   const bool              is_solid_line = false,
   const bool              is_alow_del = true
)
  {
   string name_new = "redrw_" + name;
   if(is_alow_del == false)
      name_new = name;

   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_LEFT, ray_left);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT, ray_right); // Bật tính năng "Rời qua phải"
   if(is_solid_line)
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 2);
     }
   else
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name_new, OBJPROP_BACK, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   double                  price_from=0,                   // anchor point price
   datetime                time_to=0,                   // anchor point time
   double                  price_to=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const bool              is_solid_line = false
)
  {
   string name_new = "redrw_" + name;

   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price_from, time_to, price_to);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_LEFT, false);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT, false); // Bật tính năng "Rời qua phải"
   if(is_solid_line)
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);
     }
   else
     {
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name_new, OBJPROP_BACK, true);
  }

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
string free_overnight(string symbol)
  {
   int free_size = ArraySize(free_extended_overnight_fees);
   for(int index = 0; index < free_size; index++)
     {
      string fre_symbol = free_extended_overnight_fees[index];
      if(is_same_symbol(fre_symbol, symbol))
         return " (Zf)";
     }

   return "";
  }

//https://vn.investing.com/indices/vn100-components
//Dưới đây là các công ty còn lại từ chỉ số VN100 và được phân loại vào các ngành tương ứng:
//Công nghệ, Năng lượng tái tạo, Y tế và dược phẩm, Công nghiệp 4.0
//1. Ngân hàng:
//   - VCB (Vietcombank)
//   - TCB (Techcombank)
//   - MBB (MBBank)
//   - VPB (VPBank)
//   - HDB (HDBank)
//   - ACB (Asia Commercial Bank)
//   - LPB (LienVietPostBank)
//   - TPB (TPBank)
//
//2. Bất động sản:
//   - VIC (Vingroup)
//   - NLG (Nam Long Group)
//   - DXG (Dat Xanh Group)
//   - DIG (Đất Xanh Group)
//   - NVL (Novaland)
//   - KDH (Kinh Đô Corporation)
//
//3. Viễn thông:
//   - VNM (Viettel)
//   - FPT (FPT Corporation)
//   - VNG (VNG Corporation)
//   - GTEL (Global Telecom)
//   - CTS (Công ty cổ phần Viễn thông Công nghệ Sài Gòn)
//
//4. Hàng tiêu dùng:
//   - MSN (Masan Group)
//   - VNM (Vinamilk)
//   - SAB (Sabeco)
//   - MWG (Mobile World Group)
//   - PNJ (Phú Nhuận Jewelry)
//
//5. Năng lượng:
//   - GAS (PetroVietnam Gas)
//   - PLX (Petrolimex)
//   - POW (PetroVietnam Power)
//   - PVD (PetroVietnam Drilling and Well Services)
//
//6. Công nghệ:
//   - FPT (FPT Corporation)
//   - VNG (VNG Corporation)
//   - VCS (Vietnam National Petroleum Group)
//   - PTB (Petrolimex Trading Joint Stock Company)
//
//7. Sản xuất, y tế và dược phẩm
//   - HPG (Hoà Phát Group)
//   - DPM (Đạm Phú Mỹ)
//   - GEX (Gemadept Corporation)
//   - DHG: Công ty Cổ phần Dược Hậu Giang
//   - DMC: Công ty Cổ phần Dược phẩm MEDIC
//   - IMP: Công ty Cổ phần Dược phẩm Imexpharm


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &dic_amp_init_h4, double &dic_amp_init_d1)
  {
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      i_top_price = 36285;
      dic_amp_init_d1 = 0.05;
      amp_w = 1357.35;
      dic_amp_init_h4 = 0.03;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USOIL"))
     {
      i_top_price = 120.000;
      dic_amp_init_d1 = 0.10;
      amp_w = 2.75;
      dic_amp_init_h4 = 0.05;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "XAGUSD"))
     {
      i_top_price = 25.7750;
      dic_amp_init_d1 = 0.06;
      amp_w = 0.63500;
      dic_amp_init_h4 = 0.03;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "XAUUSD"))
     {
      i_top_price = 2088;
      dic_amp_init_d1 = 0.03;
      amp_w = 27.83;
      dic_amp_init_h4 = 0.015;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US500"))
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.05;
      amp_w = 60.00;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US100.cash") || is_same_symbol(symbol, "USTEC"))
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.05;
      amp_w = 274.5;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US30"))
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.05;
      amp_w = 438.76;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "UK100"))
     {
      i_top_price = 7755.65;
      dic_amp_init_d1 = 0.05;
      amp_w = 95.38;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GER40"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "DE30"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "FRA40") || is_same_symbol(symbol, "FR40"))
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 0.05;
      amp_w = 117.6866;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUS200"))
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 0.05;
      amp_w = 93.59;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDJPY"))
     {
      i_top_price = 98.5000;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.100;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDUSD"))
     {
      i_top_price = 0.7210;
      dic_amp_init_d1 = 0.03;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.015;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURAUD"))
     {
      i_top_price = 1.71850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01365;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURGBP"))
     {
      i_top_price = 0.9010;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00497;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURUSD"))
     {
      i_top_price = 1.12465;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0080;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPUSD"))
     {
      i_top_price = 1.315250;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01085;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      i_top_price = 1.38950;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00795;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USDCHF"))
     {
      i_top_price = 0.93865;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00750;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USDJPY"))
     {
      i_top_price = 154.525;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.4250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CADCHF"))
     {
      i_top_price = 0.702850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CADJPY"))
     {
      i_top_price = 111.635;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.0250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CHFJPY"))
     {
      i_top_price = 171.450;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.365000;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURJPY"))
     {
      i_top_price = 162.565;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.43500;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPJPY"))
     {
      i_top_price = 188.405;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.61500;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDJPY"))
     {
      i_top_price = 90.435;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.90000;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURCAD"))
     {
      i_top_price = 1.5225;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00945;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURCHF"))
     {
      i_top_price = 0.96800;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURNZD"))
     {
      i_top_price = 1.89655;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01585;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPAUD"))
     {
      i_top_price = 1.9905;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01575;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPCAD"))
     {
      i_top_price = 1.6885;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01210;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPCHF"))
     {
      i_top_price = 1.11485;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0085;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPNZD"))
     {
      i_top_price = 2.09325;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.016250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDCAD"))
     {
      i_top_price = 0.90385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDCHF"))
     {
      i_top_price = 0.654500;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.005805;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDNZD"))
     {
      i_top_price = 1.09385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00595;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDCAD"))
     {
      i_top_price = 0.84135;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.007200;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDCHF"))
     {
      i_top_price = 0.55;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDUSD"))
     {
      i_top_price = 0.6275;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00660;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "DXY"))
     {
      i_top_price = 103.458;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.6995;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   i_top_price = iClose(symbol, PERIOD_W1, 1);
   dic_amp_init_d1 = 0.02;
   amp_w = calc_avg_amp_week(symbol, PERIOD_W1, 50);
   dic_amp_init_h4 = 0.01;

   SendAlert(INDI_NAME, "SymbolData", " Get SymbolData:" + (string)symbol + "   i_top_price: " + (string)i_top_price + "   amp_w: " + (string)amp_w + "   dic_amp_init_h4: " + (string)dic_amp_init_h4);
   return;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
