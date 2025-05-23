//+------------------------------------------------------------------+
//|                                                      Solomon.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;


double dbRiskRatio =  0.005; // Rủi ro 1%
double INIT_EQUITY = 1000.0; // Vốn đầu tư

string INDICES = "_USTEC_US30_US500_DE30_UK100_FR40_AUS200_BTCUSD_XAGUSD_";

string arr_main_symbol[] = {"DXY", "XAUUSD", "BTCUSD", "USOIL", "US30", "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};

string INDI_NAME = "Solomon";
string FILE_NAME_TRADINGLIST_LOG = "Solomon.log";

//Exness_Pro
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

string free_extended_overnight_fees[] =
  {
   "XAUUSD", "BTCUSD"
   , "AUDUSD", "EURUSD", "GBPUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY"
   , "AUDNZD", "EURCHF", "GBPJPY", "AUDCHF", "AUDJPY"
   , "EURAUD", "EURCAD", "EURGBP", "EURJPY", "EURNZD"
   , "GBPCHF", "GBPNZD"
   , "NZDJPY", "NZDCAD"
  };


string TREND_BUY = "BUY";
string TREND_SEL = "SELL";

string PREFIX_TRADE_PERIOD_MO = "Mn";
string PREFIX_TRADE_PERIOD_W1 = "W1";
string PREFIX_TRADE_PERIOD_D1 = "D1";
string PREFIX_TRADE_PERIOD_H4 = "H4";
string PREFIX_TRADE_PERIOD_H1 = "H1";
string PREFIX_TRADE_PERIOD_M5 = "M5";
string PREFIX_TRADE_PERIOD_M15 = "M15";

string MEMORY_STOPLOSS  = "@SL:";
string MEMORY_TICKET    = "@Ticket:";
string MEMORY_WATING    = "@TF:";
string STR_NEXT_ITEM    = "@NEXT@";

string FILE_TRADE_LIMIT          = "_no_delete_file_LimitTrade.log";
string FILE_NAME_OPEN_TRADE      = "_open_trade_today.txt";
string FILE_NAME_SEND_MSG        = "_send_msg_today.txt";
string FILE_NAME_ALERT_MSG       = "_alert_today.txt";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OPEN_TRADE    = "(OPEN_TRADE)";
string STOP_TRADE    = "(STOP_TRADE)";
string OPEN_ORDERS   = "(OPEN_ORDER)    ";
string STOP_LOSS     = "(STOP_LOSS)";
string AUTO_TRADE    = "(AUTO_TRADE)";

//string MARKET_POSITION = "MK_";
string ORDER_POSITIONS = "OD_";

string LOCK_SEL = "_LoS_";
string LOCK_BUY = "_LoB_";
string STR_RE_DRAW = "_DRAW_";
//+------------------------------------------------------------------+
string TREND_LOSING  = "";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TRADER_ASHOK_V20 = "(Ashok.2.0)";
string TRADER_ASHOK_V30 = "(Ashok.3.0)";
string TRADER_CLEOP_V03 = "(Cleop.0.3)";
string TRADER_CLEOP_V05 = "(Cleop.0.5)";
string TRADER_CLEOP_V10 = "(Cleop.1.0)";
string TRADER_CLEOP_V15 = "(Cleop.1.5)";
string TRADER_CLEOP_V20 = "(Cleop.2.0)";
string TRADER_CLEOP_V25 = "(Cleop.2.5)";
string TRADER_MAHUA_V05 = "(MaHua.0.5)";
string TRADER_MAHUA_V10 = "(MaHua.1.0)";
string TRADER_MAHUA_V15 = "(MaHua.1.5)";
string TRADER_MAHUA_V20 = "(MaHua.2.0)";
string TRADER_MAHUA_V25 = "(MaHua.2.5)";
string TRADER_AKHEN_V05 = "(Akhen.0.5)";
string TRADER_AKHEN_V10 = "(Akhen.1.0)";
string TRADER_AKHEN_V15 = "(Akhen.1.5)";
string TRADER_AKHEN_V20 = "(Akhen.2.0)";
string TRADER_AKHEN_V25 = "(Akhen.2.5)";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TRADER_SOLOMON = "(Solomon)";
//+------------------------------------------------------------------+
int MAX_DCA = 5;
datetime TIME_OF_ONE_H4_CANDLE = 14400;

// Biến lưu thời gian mở lệnh cuối cùng
datetime last_order_open_time = TimeCurrent();
datetime last_open_trade_time = TimeCurrent();
datetime last_trend_shift_time = TimeCurrent();
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_trade.SetExpertMagicNumber(20240320);

   Comment(GetComments());

   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Comment(GetComments());
   create_vertical_line(time2string(iTime(Symbol(), PERIOD_W1, 0)), iTime(Symbol(), PERIOD_W1, 0), clrBlack,  STYLE_DASHDOTDOT);


   string symbol = Symbol();
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);
   double default_volume = calc_volume_by_amp(symbol, amp_d1, calcRisk());

   string trend_w3 = get_trend_by_stoc2(symbol, PERIOD_W1, 3, 2, 3, 0);
   string trend_w5 = get_trend_by_stoc2(symbol, PERIOD_W1, 5, 3, 3, 0);
   string trend_d10 = get_trend_by_ma(symbol, PERIOD_D1, 10, 1);
   string trend_h4_ma0710 = "";
   string trend_h4_ma1020 = "";
   string trend_h4_ma2050 = "";
   string trend_h4_C1ma10 = "";
   string trend_h4_ma50d1 = "";
   bool is_insign_h4 = false;
   get_trend_by_ma_seq71020_steadily(symbol, PERIOD_H4, trend_h4_ma0710, trend_h4_ma1020, trend_h4_ma2050, trend_h4_C1ma10, trend_h4_ma50d1, is_insign_h4);


   string FIND_TREND_H4 = "";
   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);
   if((trend_by_macd_h4 == trend_w3 && trend_by_macd_h4 == trend_w5) && trend_by_macd_h4 == trend_d10 && trend_by_macd_h4 == trend_h4_ma2050)
      FIND_TREND_H4 = trend_by_macd_h4;

   OpenTrade_StandardVolume(symbol, "(Mac2050h4)", amp_h4, FIND_TREND_H4, default_volume, true);
  }
//+------------------------------------------------------------------+
//|not_allow_against_main_trend = False <-> DCA đến chết             |
//+------------------------------------------------------------------+
void OpenTrade_StandardVolume(string symbol, string TRADER, double AMP_DCA, string trend_init, double init_volume = 0.01, bool not_allow_against_main_trend=true)
  {
   if(is_same_symbol(INDICES, symbol) && trend_init != TREND_BUY)
      return;

   int NUMBER_OF_TRADE = 100;
   double AMP_TP_DCA = AMP_DCA*2;

   double BID = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ASK = SymbolInfoDouble(symbol, SYMBOL_ASK);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   string keys_all = "";
   string keys_locks_sel = "";
   string keys_locks_buy = "";
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(is_same_symbol(TRADER, m_position.Comment()))
              {
               keys_all += create_ticket_key(m_position.Ticket());

               if(StringFind(toLower(m_position.Comment()), toLower(LOCK_BUY)) >= 0)
                  keys_locks_buy += create_ticket_key(m_position.Ticket()) + m_position.Comment() + ";";

               if(StringFind(toLower(m_position.Comment()), toLower(LOCK_SEL)) >= 0)
                  keys_locks_sel += create_ticket_key(m_position.Ticket()) + m_position.Comment() + ";";
              }

   int count_possion_buy = 0, count_possion_sel = 0;
   double total_profit=0, total_profit_buy = 0, total_profit_sel = 0;
   double total_volume_buy = 0, total_volume_sel = 0;
   double max_openprice_buy = 0, min_openprice_sel = 10000000;
   double cur_tp_buy = 0, cur_tp_sel = 0;

   ulong first_ticket_buy = 0, first_ticket_sel = 0;
   datetime first_open_time_buy = 0, first_open_time_sel = 0;
   double first_entry_buy = 0, first_entry_sel = 0;

   double last_entry_buy = 0, last_entry_sel = 0;
   ulong last_ticket_buy = 0, last_ticket_sel = 0;
   string last_comment_buy = "", last_comment_sel = "";

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            if(is_same_symbol(TRADER, m_position.Comment()) == false)
               continue;

            double cur_profit = m_position.Profit() + m_position.Swap() + m_position.Commission();
            double price_sell_off = is_same_symbol(m_position.TypeDescription(), TREND_BUY) ? m_position.PriceOpen() + 3 : m_position.PriceOpen() - 3;
            string TRADING_TREND = get_trend_in_note(m_position.TypeDescription());

            //if(is_same_symbol(m_position.Comment(), "01"))
            //   create_lable(time2string(m_position.Time()), TimeCurrent(), m_position.TakeProfit(), "(TP)(" +get_trend_nm(TRADING_TREND) + ") " + TRADER);

            string bilock_ticket = m_position.Comment();
            string key = create_ticket_key(m_position.Ticket());
            if(is_same_symbol(bilock_ticket, LOCK_BUY) || is_same_symbol(bilock_ticket, LOCK_SEL))
              {
               StringReplace(bilock_ticket, TRADER, "");
               StringReplace(bilock_ticket, LOCK_BUY, "");
               StringReplace(bilock_ticket, LOCK_SEL, "");

               if(keys_all == "" || is_same_symbol(keys_all, key) == false)
                  m_trade.PositionModify(m_position.Ticket(), m_position.StopLoss(), price_sell_off);
              }

            if(is_same_symbol(m_position.Comment(), LOCK_BUY) || is_same_symbol(m_position.Comment(), LOCK_SEL))
               continue;

            if(TRADING_TREND == TREND_BUY)
              {
               count_possion_buy += 1;
               total_profit_buy += cur_profit;
               total_volume_buy += m_position.Volume();

               if(last_ticket_buy < m_position.Ticket())
                 {
                  cur_tp_buy = m_position.TakeProfit();
                  last_entry_buy = m_position.PriceOpen();
                  last_ticket_buy = m_position.Ticket();
                  last_comment_buy = m_position.Comment();
                 }

               if(is_same_symbol(m_position.Comment(), "01"))
                 {
                  first_ticket_buy = m_position.Ticket();
                  first_open_time_buy = m_position.Time();
                  first_entry_buy = m_position.PriceOpen();
                 }

               if(max_openprice_buy < m_position.PriceOpen())
                  max_openprice_buy = m_position.PriceOpen();
              }

            if(TRADING_TREND == TREND_SEL)
              {
               count_possion_sel += 1;
               total_profit_sel += cur_profit;
               total_volume_sel += m_position.Volume();

               if(last_ticket_sel < m_position.Ticket())
                 {
                  cur_tp_sel = m_position.TakeProfit();
                  last_entry_sel = m_position.PriceOpen();
                  last_ticket_sel = m_position.Ticket();
                  last_comment_sel = m_position.Comment();
                 }

               if(is_same_symbol(m_position.Comment(), "01"))
                 {
                  first_ticket_sel = m_position.Ticket();
                  first_open_time_sel = m_position.Time();
                  first_entry_sel = m_position.PriceOpen();
                 }

               if(min_openprice_sel > m_position.PriceOpen())
                  min_openprice_sel =m_position.PriceOpen();
              }
           }
        }
     } //for
//---------------------------------------------------------------------------
   bool stoc_h4_allow_buy_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3);
   bool stoc_h4_allow_sel_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_SEL, 3, 2, 3);

   if((stoc_h4_allow_sel_now && total_profit_buy > 0) || (keys_locks_buy == "" && count_possion_buy == 0))
      ClosePosition(symbol, TREND_BUY, TRADER);

   if((stoc_h4_allow_buy_now && total_profit_sel > 0) || (keys_locks_sel == "" && count_possion_sel == 0))
      ClosePosition(symbol, TREND_SEL, TRADER);
//-----------------------------------------------------------------------------
   if(count_possion_buy == 0 && trend_init == TREND_BUY)
      m_trade.Buy(init_volume,  symbol, ASK, 0.0, ASK + AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy+1));

   if(count_possion_sel == 0 && trend_init == TREND_SEL)
      m_trade.Sell(init_volume, symbol, BID, 0.0, BID - AMP_DCA, TRADER + get_trend_nm(TREND_SEL) + "_" + append1Zero(count_possion_sel+1));
//-----------------------------------------------------------------------------
   if(trend_init == TREND_BUY || not_allow_against_main_trend == false)
      if(stoc_h4_allow_sel_now == false && count_possion_buy > 0 && count_possion_buy < NUMBER_OF_TRADE && (ASK < last_entry_buy - AMP_DCA))
        {
         double amp_tp = MathMax(AMP_TP_DCA, MathAbs(first_entry_buy - last_entry_buy)*0.618);
         double tp_buy = NormalizeDouble(ASK + amp_tp, digits);

         count_possion_buy += 1;
         if(m_trade.Buy(init_volume, symbol, 0.0, 0.0, tp_buy, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy)))
            ModifyTp_ExceptLockKey(symbol, TREND_BUY, tp_buy, TRADER);
        }

   if(trend_init == TREND_SEL || not_allow_against_main_trend == false)
      if(stoc_h4_allow_buy_now == false && count_possion_sel > 0 && count_possion_sel < NUMBER_OF_TRADE && (BID > last_entry_sel + AMP_DCA))
        {
         double amp_tp = MathMax(AMP_TP_DCA, MathAbs(last_entry_sel - first_entry_sel)*0.618);
         double tp_sel = NormalizeDouble(BID - amp_tp, digits);

         count_possion_sel += 1;
         if(m_trade.Sell(init_volume, symbol, 0.0, 0.0, tp_sel, TRADER + get_trend_nm(TREND_SEL) + "_" + append1Zero(count_possion_sel)))
            ModifyTp_ExceptLockKey(symbol, TREND_SEL, tp_sel, TRADER);
        }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
   string key_group_buy = create_ticket_key(first_ticket_buy);
   string key_group_sel = create_ticket_key(first_ticket_sel);

   if(trend_init == TREND_BUY && stoc_h4_allow_sel_now == false && not_allow_against_main_trend && (key_group_sel != "" && is_same_symbol(keys_locks_sel, key_group_sel) == false))
      trend_shift_implement(symbol, TREND_BUY, total_profit_sel, AMP_TP_DCA, TRADER, total_volume_sel, key_group_sel);

   if(trend_init == TREND_SEL && stoc_h4_allow_buy_now == false && not_allow_against_main_trend && (key_group_buy != "" && is_same_symbol(keys_locks_buy, key_group_buy) == false))
      trend_shift_implement(symbol, TREND_SEL, total_profit_buy, AMP_TP_DCA, TRADER, total_volume_buy, key_group_buy);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trend_shift_implement(string symbol, string NEW_TREND, double total_loss, double AMP_TP_DCA, string TRADER, double volume_traded, string key_group)
  {
   if(is_allow_trend_shift(symbol, NEW_TREND))
     {
      double BID = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ASK = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double volume_balance = MathMax(volume_traded, calc_volume_by_amp(symbol, AMP_TP_DCA, MathAbs(total_loss))*2);

      if(NEW_TREND == TREND_BUY)
         if(m_trade.Buy(volume_balance, symbol, ASK, 0.0, ASK + AMP_TP_DCA, LOCK_SEL + TRADER + key_group))
           {
            Sleep(5000);
            ClosePosition(symbol, TREND_SEL, TRADER);

            create_lable(LOCK_SEL + TRADER + time2string(iTime(symbol, PERIOD_H4, 1)), iTime(symbol, PERIOD_H4, 1), ASK + AMP_TP_DCA, LOCK_SEL + TRADER + (string) volume_balance);
           }


      if(NEW_TREND == TREND_SEL)
         if(m_trade.Sell(volume_balance, symbol, BID, 0.0, BID - AMP_TP_DCA, LOCK_BUY + TRADER + key_group))
           {
            Sleep(5000);
            ClosePosition(symbol, TREND_BUY, TRADER);

            create_lable(LOCK_BUY + TRADER + time2string(iTime(symbol, PERIOD_H4, 1)), iTime(symbol, PERIOD_H4, 1), BID + AMP_TP_DCA, LOCK_BUY + TRADER + (string) volume_balance);
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTradeSolomon(string symbol)
  {
   double risk = calcRisk();
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);
   double default_volume = calc_volume_by_amp(symbol, amp_d1, risk);

   string trend_w3 = get_trend_by_stoc2(symbol, PERIOD_W1, 3, 2, 3, 0);
   string trend_w5 = get_trend_by_stoc2(symbol, PERIOD_W1, 5, 3, 3, 0);

   string trend_d10 = get_trend_by_ma(symbol, PERIOD_D1, 10, 1);
   string trend_h4_stoc1327 = get_trend_by_stoc132_ma7(symbol, PERIOD_H4);
   string trend_h4_stoc8532 = get_trend_by_stoc82_ma7(symbol, PERIOD_H4);

   bool stoc_h4_allow_buy_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3);
   bool stoc_h4_allow_sel_now = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_SEL, 3, 2, 3);

   string trend_h4_ma0710 = "";
   string trend_h4_ma1020 = "";
   string trend_h4_ma2050 = "";
   string trend_h4_C1ma10 = "";
   string trend_h4_ma50d1 = "";
   bool is_insign_h4 = false;
   get_trend_by_ma_seq71020_steadily(symbol, PERIOD_H4, trend_h4_ma0710, trend_h4_ma1020, trend_h4_ma2050, trend_h4_C1ma10, trend_h4_ma50d1, is_insign_h4);

// --------------------------------------------------------------------------
   CandleData arr_heiken_d1[];
   get_arr_heiken(symbol, PERIOD_D1, arr_heiken_d1);

   CandleData arr_heiken_h4[];
   get_arr_heiken(symbol, PERIOD_H4, arr_heiken_h4);
   string trend_hei_h4_0 = arr_heiken_h4[0].trend;
   string trend_hei_h4_1 = arr_heiken_h4[1].trend;
// --------------------------------------------------------------------------
   string keys_all = "";
   string keys_locks_sel = "";
   string keys_locks_buy = "";
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            if(is_same_symbol(m_position.Comment(), TRADER_SOLOMON))
              {
               keys_all += "(" + (string)m_position.Ticket() + ")";

               if(StringFind(toLower(m_position.Comment()), toLower(LOCK_BUY)) >= 0)
                  keys_locks_buy += "(" + (string)m_position.Ticket() + ")" + m_position.Comment() + ";";

               if(StringFind(toLower(m_position.Comment()), toLower(LOCK_SEL)) >= 0)
                  keys_locks_sel += "(" + (string)m_position.Ticket() + ")" + m_position.Comment() + ";";
              }
           }

   StringReplace(keys_locks_buy, TREND_BUY, "");
   StringReplace(keys_locks_buy, TREND_SEL, "");
   StringReplace(keys_locks_buy, TRADER_SOLOMON, "");

   StringReplace(keys_locks_sel, TREND_BUY, "");
   StringReplace(keys_locks_sel, TREND_SEL, "");
   StringReplace(keys_locks_buy, TRADER_SOLOMON, "");

   double lowest_20h4 = 0.0, higest_20h4 = 0.0;
   for(int idx = 0; idx <= 20; idx++)
     {
      double close = iClose(symbol, PERIOD_H4, idx);
      if((idx == 0) || (lowest_20h4 > close))
         lowest_20h4 = close;
      if((idx == 0) || (higest_20h4 < close))
         higest_20h4 = close;
     }
// --------------------------------------------------------------------------
   double best_tp_buy = 0, best_tp_sel = 0;
   double best_entry_buy = 0, best_entry_sel = 0;

   double max_volume_buy = 0, max_volume_sel = 0;
   double total_volume_buy = 0, total_volume_sel = 0;

   int count_init_buy = 0, count_init_sel = 0;
   int count_possion_buy = 0, count_possion_sel = 0;
   double total_profit=0, total_profit_buy = 0, total_profit_sel = 0;

   double min_time_buy_in_hours = 10000.0;
   double min_time_sel_in_hours = 10000.0;

   bool is_need_reprocessing = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            if(is_same_symbol(TRADER_SOLOMON, m_position.Comment()) == false)
               continue;

            double cur_profit = m_position.Profit() + m_position.Swap() + m_position.Commission();
            double price_sell_off = is_same_symbol(m_position.TypeDescription(), TREND_BUY) ? m_position.PriceOpen() + 3 : m_position.PriceOpen() - 3;
            string lable_profit = " " + get_trend_nm(m_position.TypeDescription()) + " " + (string) NormalizeDouble(cur_profit, 1) + "$ " + (string) m_position.Volume();

            string type = "";
            string bilock = "";
            bool has_profit = cur_profit > risk/2;
            string REVERSE = get_trend_reverse(m_position.TypeDescription());
            string TRADING_TREND = get_trend_in_note(m_position.TypeDescription());

            double hold_time_in_hours = (double)(TimeCurrent() - m_position.Time()) / (60 * 60);
            if(TRADING_TREND == TREND_BUY)
              {
               count_possion_buy += 1;
               if(count_possion_buy == 1 || best_entry_buy > m_position.PriceOpen())
                 {
                  best_tp_buy = m_position.TakeProfit();
                  best_entry_buy = m_position.PriceOpen();
                 }
               if(min_time_buy_in_hours <= hold_time_in_hours)
                  min_time_buy_in_hours = hold_time_in_hours;
              }

            if(TRADING_TREND == TREND_SEL)
              {
               count_possion_sel += 1;
               if(count_possion_sel == 1 || best_entry_sel < m_position.PriceOpen())
                 {
                  best_tp_sel = m_position.TakeProfit();
                  best_entry_sel = m_position.PriceOpen();
                 }

               if(min_time_sel_in_hours < hold_time_in_hours)
                  min_time_sel_in_hours = hold_time_in_hours;
              }

            if(StringFind(toLower(m_position.Comment()), toLower(LOCK_SEL)) >= 0)
              {
               type = "LOCK_SEL_";
               bilock = m_position.Comment();
               StringReplace(bilock, LOCK_SEL, "");
               StringReplace(bilock, TRADER_SOLOMON, "");
               StringReplace(bilock, TREND_BUY, "");
               StringReplace(bilock, TREND_SEL, "");

               lable_profit += " (LOCK_SEL)" + bilock ;// + " all: " + keys_all;
              }

            if(StringFind(toLower(m_position.Comment()), toLower(LOCK_BUY)) >= 0)
              {
               type = "LOCK_BUY_";
               bilock = m_position.Comment();
               StringReplace(bilock, LOCK_BUY, "");
               StringReplace(bilock, TRADER_SOLOMON, "");
               StringReplace(bilock, TREND_BUY, "");
               StringReplace(bilock, TREND_SEL, "");

               lable_profit += " (LOCK_BUY)" + bilock ;// + " all: " + keys_all;
              }


            if(trend_h4_ma1020 == REVERSE && trend_h4_ma2050 == REVERSE && trend_w3 == REVERSE)
              {
               create_lable_entry(m_position.Ticket()
                                  , m_position.Time()
                                  , m_position.PriceOpen()
                                  , m_position.TypeDescription()
                                  , amp_d1
                                  , " (SL) " + TRADER_SOLOMON + get_trend_nm(REVERSE) + " " + ((string) NormalizeDouble(cur_profit, 1)) + "$");

               create_entry_line("SL_" + get_trend_nm(REVERSE) + "_"+ (string) m_position.Ticket()
                                 , iTime(symbol, PERIOD_H4, 5), iTime(symbol, PERIOD_H4, 1)
                                 , iClose(symbol, PERIOD_H4, 1)
                                 , "SL:" + (string) NormalizeDouble(cur_profit, 1) + "$");

               if(m_position.Profit() > 0)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
               else
                  if(m_position.StopLoss() <= 0 && is_allow_trade_now_by_stoc(symbol, PERIOD_H4, REVERSE, 3, 2, 3))
                    {
                     double volume_balance = calc_volume_by_amp(symbol, amp_h4, MathAbs(cur_profit))*2;
                     if(volume_balance > default_volume*3)
                        volume_balance = default_volume*3;

                     if(TRADING_TREND == TREND_BUY)
                       {
                        m_trade.Sell(volume_balance, symbol, price, m_position.PriceOpen(), price - amp_h4, TRADER_SOLOMON + LOCK_BUY + "_(" + (string)m_position.Ticket() + ")");
                        Sleep(5000);
                        m_trade.PositionModify(m_position.Ticket(), price - amp_h4, m_position.TakeProfit());
                        Sleep(5000);
                       }

                     if(TRADING_TREND == TREND_SEL)
                       {
                        m_trade.Buy(volume_balance, symbol, price, m_position.PriceOpen(), price + amp_h4, TRADER_SOLOMON + LOCK_SEL + "_(" + (string)m_position.Ticket() + ")");
                        Sleep(5000);
                        m_trade.PositionModify(m_position.Ticket(), price + amp_h4, m_position.TakeProfit());
                        Sleep(5000);
                       }
                    }
              }
            else
              {
               create_lable_entry(m_position.Ticket()
                                  , m_position.Time()
                                  , m_position.PriceOpen()
                                  , m_position.TypeDescription()
                                  , amp_d1
                                  , lable_profit);
              }


            if(bilock != "")
              {
               if(StringFind(keys_all, bilock) >= 0)
                  continue;
               else
                  m_trade.PositionModify(m_position.Ticket(), m_position.StopLoss(), price_sell_off);
              }


            total_profit += cur_profit;
            bool is_sell_off = false;
            bool take_profit = false;
            // --------------------------------------------------------
            if(StringFind(toLower(m_position.TypeDescription()), "buy") >= 0)
              {
               if(has_profit && trend_h4_stoc1327 == TREND_SEL && trend_h4_ma0710 != TREND_BUY)
                  take_profit = true;

               if(trend_h4_ma1020 == TREND_SEL)
                  is_sell_off = true;


               total_profit_buy += m_position.Profit();

               total_volume_buy += m_position.Volume();
               if(max_volume_buy < m_position.Volume())
                  max_volume_buy = m_position.Volume();

               if(StringFind(toLower(m_position.TypeDescription()), "init") >= 0)
                  count_init_buy += 1;
              }

            if(StringFind(toLower(m_position.TypeDescription()), "sel") >= 0)
              {
               if(has_profit && trend_h4_stoc1327 == TREND_BUY && trend_h4_ma0710 != TREND_SEL)
                  take_profit = true;

               if(trend_h4_ma1020 == TREND_BUY)
                  is_sell_off = true;


               total_profit_sel += m_position.Profit();

               total_volume_sel += m_position.Volume();
               if(max_volume_sel < m_position.Volume())
                  max_volume_sel = m_position.Volume();

               if(StringFind(toLower(m_position.TypeDescription()), "init") >= 0)
                  count_init_sel += 1;
              }

            if(is_sell_off)
              {
               create_lable_entry(m_position.Ticket()
                                  , m_position.Time()
                                  , m_position.PriceOpen()
                                  , m_position.TypeDescription()
                                  , 0
                                  , "(" + (string) m_position.Ticket() + ")" + " (Sell Off) " + get_trend_nm(TRADING_TREND) + ": " + ((string) NormalizeDouble(cur_profit, 1)) + "$ " + (string) m_position.Volume()
                                 );

               if(m_position.StopLoss() == 0)
                 {
                  double lowest = 0.0, higest = 0.0;
                  for(int idx = 0; idx <= 55; idx++)
                    {
                     double close = iClose(symbol, PERIOD_H4, idx);
                     if((idx == 0) || (lowest > close))
                        lowest = close;
                     if((idx == 0) || (higest < close))
                        higest = close;
                    }

                  // Bán ở đáy, thì cần Mua lên đến đỉnh.
                  if(TRADING_TREND == TREND_SEL && trend_h4_stoc1327 == TREND_BUY && (keys_locks_sel == "" || StringFind(keys_locks_sel, "(" + (string) m_position.Ticket() + ")") < 0))
                    {
                     double amp_fix_bug = amp_d1;
                     double amp_mov_bug = MathAbs(price - m_position.PriceOpen());

                     double vol_fix_bug = amp_mov_bug * m_position.Volume() / amp_fix_bug;
                     vol_fix_bug = MathMax(vol_fix_bug, calc_volume_by_amp(symbol, amp_fix_bug, MathAbs(cur_profit) + MathAbs(cur_profit*amp_fix_bug/amp_mov_bug)))*1.5;

                     if(vol_fix_bug > MathMax(m_position.Volume(), default_volume)*3)
                        vol_fix_bug = MathMax(m_position.Volume(), default_volume)*3;

                     if(vol_fix_bug < MathMax(m_position.Volume(), default_volume)*2)
                        vol_fix_bug = MathMax(m_position.Volume(), default_volume)*2;

                     vol_fix_bug = NormalizeDouble(vol_fix_bug, 2);

                     if(Open_Market(symbol, TREND_BUY, vol_fix_bug, TRADER_SOLOMON + LOCK_SEL + "(" + (string) m_position.Ticket() + ")", price + amp_fix_bug))
                       {
                        m_trade.PositionModify(m_position.Ticket(), price + amp_fix_bug, price_sell_off);
                        m_trade.BuyLimit(vol_fix_bug, NormalizeDouble(m_position.PriceOpen() + amp_mov_bug/2, digits), symbol, 0.0, price, 0, 0, TRADER_SOLOMON + LOCK_SEL + "(" + (string) m_position.Ticket() + ")");
                        return;
                       }


                    }
                 }

               is_need_reprocessing = true;
              }
            else
               if(take_profit)
                 {
                  create_lable_entry(m_position.Ticket()
                                     , m_position.Time()
                                     , m_position.PriceOpen()
                                     , m_position.TypeDescription()
                                     , amp_d1
                                     , " (TP_H4) " + get_trend_nm(TRADING_TREND) + " " + ((string) NormalizeDouble(cur_profit, 1)) + "$");

                  m_trade.PositionClose(m_position.Ticket());

                  is_need_reprocessing = true;
                 }

           }
        }
     } //for

//if(is_need_reprocessing)
//   OpenTradeSolomon(symbol);

   int count_order_buy = 0, count_order_sel = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if((toLower(symbol) == toLower(m_order.Symbol())))  //&& (StringFind(toLower(m_position.Comment()), "bb_") >= 0)
           {
            if(StringFind(toLower(m_order.TypeDescription()), "buy") >= 0)
              {
               count_order_buy += 1;
              }

            if(StringFind(toLower(m_order.TypeDescription()), "sel") >= 0)
              {
               count_order_sel += 1;
              }
           }
        }
     }


//------------------------------------------------------------------
   double amp_buy_moved = (best_entry_buy - price);
   double amp_sel_moved = (price - best_entry_sel);

   bool stoc_w_allow_trade = trend_w3 == trend_w5;

//------------------------------------------------------------------
   if(stoc_w_allow_trade && total_profit > risk)
     {
      if(trend_w3 == TREND_BUY)
         ClosePosition_TakeProfit(symbol, TREND_SEL, TRADER_SOLOMON);

      if(trend_w3 == TREND_SEL)
         ClosePosition_TakeProfit(symbol, TREND_BUY, TRADER_SOLOMON);
     }

   if((keys_locks_buy == "") && (count_possion_buy + count_possion_sel == 0) && (count_order_buy > 0))
      CloseOrders(symbol, TREND_BUY, TRADER_SOLOMON);

   if((keys_locks_sel == "") && (count_possion_buy + count_possion_sel == 0) && (count_order_sel > 0))
      CloseOrders(symbol, TREND_SEL, TRADER_SOLOMON);
//------------------------------------------------------------------
   bool is_hoding = false;

   if(is_same_symbol(INDICES, symbol) && trend_w3 != TREND_BUY)
      return;

   bool time_allow_dca_buy = true;
   if(min_time_buy_in_hours < 24)
      time_allow_dca_buy = false;

   bool time_allow_dca_sel = true;
   if(min_time_sel_in_hours < 24)
      time_allow_dca_sel = false;

   double tp_buy = NormalizeDouble(price + amp_d1*5, digits);
   double tp_sel = NormalizeDouble(price - amp_d1*5, digits);

   bool stoc_h4_2050_allow_trade = is_allow_trade_now_by_stoc(symbol, PERIOD_H4, trend_h4_ma2050, 3, 2, 3);

   if(trend_h4_ma2050 == trend_h4_ma1020 && stoc_h4_2050_allow_trade)
     {
      if(trend_h4_ma2050 == TREND_BUY && (count_possion_buy == 0))
        {
         Open_Market(symbol, TREND_BUY, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_BUY) + "_ta." + (string)(count_possion_buy + 1), tp_buy);
         return;
        }

      if(trend_h4_ma2050 == TREND_SEL && (count_possion_sel == 0))
        {
         Open_Market(symbol, TREND_SEL, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_SEL) + "_tb." + (string)(count_possion_sel + 1), tp_sel);
         return;
        }

     }

   if((count_possion_buy == 0) && (higest_20h4 - price > amp_d1*2) && trend_h4_ma2050 == TREND_BUY && stoc_h4_2050_allow_trade)
     {
      Open_Market(symbol, TREND_BUY, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_BUY) + "_tc." + (string)(count_possion_buy + 1), price + amp_d1);
      return;
     }
   if((count_possion_buy == 1) && (higest_20h4 - price > amp_d1*2) && price < best_entry_buy - amp_d1 && is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3))
     {
      Open_Market(symbol, TREND_BUY, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_BUY) + "_td." + (string)(count_possion_buy + 1), price + amp_d1);
      return;
     }

   if((count_possion_sel == 0) && (lowest_20h4 + amp_d1*2 < price) && trend_h4_ma2050 == TREND_SEL && trend_h4_ma1020 == TREND_SEL && stoc_h4_2050_allow_trade)
     {
      Open_Market(symbol, TREND_SEL, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_SEL) + "_te." + (string)(count_possion_sel + 1), price - amp_d1);
      return;
     }

//if((trend_h4_ma2050 == TREND_BUY && price < best_entry_buy - amp_d1) || (trend_h4_ma2050 == TREND_SEL && price > best_entry_sel + amp_d1))
     {
      if(trend_h4_ma2050 == TREND_BUY && (amp_buy_moved > amp_d1) && (count_possion_buy > 0) && (count_possion_buy < MAX_DCA)
         && (trend_h4_stoc1327 == TREND_BUY || is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3)))
        {
         int trade_no = count_possion_buy+1;
         double volume = calc_volume_by_amp(symbol, amp_d1, MathAbs(total_profit_buy) + risk);
         Open_Market(symbol, TREND_BUY, NormalizeDouble(volume, 2), TRADER_SOLOMON + get_trend_nm(TREND_BUY) + "_dc." + (string)(trade_no), tp_buy);
         return;
        }

      if(trend_h4_ma2050 == TREND_SEL && (amp_sel_moved > amp_d1) && (count_possion_sel > 0) && (count_possion_sel < MAX_DCA)
         && (trend_h4_stoc1327 == TREND_SEL || is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_SEL, 3, 2, 3)))
        {
         int trade_no = count_possion_sel+1;
         double volume = calc_volume_by_amp(symbol, amp_d1, MathAbs(total_profit_sel) + risk);
         Open_Market(symbol, TREND_SEL, NormalizeDouble(volume, 2), TRADER_SOLOMON + get_trend_nm(TREND_SEL) + "_dc." + (string)(trade_no), tp_sel);
         return;
        }
     }


   if(stoc_w_allow_trade
      && (trend_h4_stoc1327 == trend_w3)
      && (trend_h4_stoc1327 == trend_h4_ma0710 && trend_h4_stoc1327 == trend_h4_ma1020)
     )
     {
      if(keys_locks_buy == "" && trend_w3 == TREND_BUY && (count_possion_buy == 0 && count_order_buy == 0))
        {
         Open_Market(symbol, TREND_BUY, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_BUY) + "_" + append1Zero(1), tp_buy);
         return;
        }

      if(keys_locks_sel == "" && trend_w3 == TREND_SEL && (count_possion_sel == 0 && count_order_sel == 0))
        {
         Open_Market(symbol, TREND_SEL, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_SEL) + "_" + append1Zero(1), tp_sel);
         return;
        }

      if((trend_w3 == TREND_BUY && (count_possion_buy + count_order_buy < 2) && time_allow_dca_buy) ||
         (trend_w3 == TREND_SEL && (count_possion_sel + count_order_sel < 2) && time_allow_dca_sel))

         if((trend_w3 == trend_d10) && (trend_w3 == trend_h4_ma2050) && (trend_w3 == arr_heiken_d1[1].trend || trend_w3 == arr_heiken_d1[0].trend)
            && arr_heiken_d1[1].count < 7)
           {
            bool lock_allow_trade = true;
            // Không nhồi lệnh khi:
            if(trend_w3 == TREND_BUY && keys_locks_buy != "")
               lock_allow_trade = false;
            if(trend_w3 == TREND_SEL && keys_locks_sel != "")
               lock_allow_trade = false;

            if(lock_allow_trade)
              {
               is_hoding = true;
               if(passes_last_order_open_time(4))
                 {
                  if(trend_w3 == TREND_BUY)
                    {
                     Open_Market(symbol, TREND_BUY, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_BUY) + "_w" + (string)(count_possion_buy + 1), tp_buy);
                     if(price < higest_20h4 - amp_d1*2)
                       {
                        m_trade.BuyLimit(default_volume, NormalizeDouble(price - amp_d1*1, digits), symbol, 0.0, price + amp_d1*0, 0, 0, TRADER_SOLOMON + get_trend_nm(TREND_BUY) + "_WD." + (string)(count_possion_buy+2));
                        m_trade.BuyLimit(default_volume, NormalizeDouble(price - amp_d1*2, digits), symbol, 0.0, price + amp_d1*1, 0, 0, TRADER_SOLOMON + get_trend_nm(TREND_BUY) + "_WD." + (string)(count_possion_buy+3));
                       }
                    }

                  if(trend_w3 == TREND_SEL)
                    {
                     Open_Market(symbol, TREND_SEL, default_volume, TRADER_SOLOMON + get_trend_nm(TREND_SEL) + "_w" + (string)(count_possion_sel + 1), tp_sel);
                     if(price > lowest_20h4 + amp_d1*2)
                       {
                        m_trade.SellLimit(default_volume, NormalizeDouble(price + amp_d1*1, digits), symbol, 0.0, price - amp_d1*0, 0, 0, TRADER_SOLOMON + get_trend_nm(TREND_SEL) + "_WD." + (string)(count_possion_sel+2));
                        m_trade.SellLimit(default_volume, NormalizeDouble(price + amp_d1*2, digits), symbol, 0.0, price - amp_d1*1, 0, 0, TRADER_SOLOMON + get_trend_nm(TREND_SEL) + "_WD." + (string)(count_possion_sel+3));
                       }
                    }

                  return;
                 }
              }
           }
     }


// ------------------------------------------------------------------
   if(is_same_symbol(Symbol(), symbol))
     {
      double ma10d = iClose(symbol, PERIOD_W1, 1);
      create_lable("FIND", TimeCurrent(), ma10d, "     " + trend_w3 + "    " + (string) AccountInfoDouble(ACCOUNT_BALANCE), TREND_BUY, false);
     }
// ------------------------------------------------------------------
   if(is_hoding == false && ((total_profit > risk) || (total_profit_buy > risk) || (total_profit_sel > risk)))
     {
      string trend_ma07 = get_trend_by_ma(symbol, PERIOD_H4, 7);

      if(total_profit > risk)
         if((total_profit_buy > total_profit_sel && (trend_h4_ma0710 != TREND_BUY || trend_h4_stoc1327 != TREND_BUY) && trend_hei_h4_1 != TREND_BUY && trend_hei_h4_0 != TREND_BUY) ||
            (total_profit_sel > total_profit_buy && (trend_h4_ma0710 != TREND_SEL || trend_h4_stoc1327 != TREND_SEL) && trend_hei_h4_1 != TREND_SEL && trend_hei_h4_0 != TREND_SEL))
           {
            create_lable(time2string(iTime(symbol, PERIOD_H4, 0)), iTime(symbol, PERIOD_H4, 0), price,
                         " Pt " + (string) NormalizeDouble(total_profit, 1) + "$", total_profit > 0 ? TREND_BUY : TREND_SEL);

            ClosePosition(symbol, "", TRADER_SOLOMON);
            return;
           }

      if(total_profit_buy > risk)
         if((trend_h4_ma0710 != TREND_BUY || trend_h4_stoc1327 != TREND_BUY) && trend_hei_h4_1 != TREND_BUY && trend_hei_h4_0 != TREND_BUY)
           {
            create_lable(time2string(iTime(symbol, PERIOD_H4, 0)), iTime(symbol, PERIOD_H4, 0), price,
                         " Pb " + (string) NormalizeDouble(total_profit_buy, 1) + "$", total_profit_buy > 0 ? TREND_BUY : TREND_SEL);

            ClosePosition(symbol, TREND_BUY, TRADER_SOLOMON);
            return;
           }

      if(total_profit_sel > risk)
         if((trend_h4_ma0710 != TREND_SEL || trend_h4_stoc1327 != TREND_SEL) && trend_hei_h4_1 != TREND_SEL && trend_hei_h4_0 != TREND_SEL)
           {
            create_lable(time2string(iTime(symbol, PERIOD_H4, 0)), iTime(symbol, PERIOD_H4, 0), price,
                         " Ps " + (string) NormalizeDouble(total_profit_sel, 1) + "$", total_profit_sel > 0 ? TREND_BUY : TREND_SEL);

            ClosePosition(symbol, TREND_SEL, TRADER_SOLOMON);
            return;
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade_Only1Side(string symbol, string TRADER, double AMP_DCA, string trend_init, double init_volume = 0.01, bool is_increase_vol_by_fibo = false)
  {
   if(trend_init == "")
      return;

   if(is_same_symbol(INDICES, symbol) && trend_init != TREND_BUY)
      return;

   int NUMBER_OF_TRADE = 100;
   double AMP_TP_DCA = AMP_DCA * 2;

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   int count_possion_buy = 0, count_possion_sel = 0;
   double total_profit=0, total_profit_buy = 0, total_profit_sel = 0;
   double total_volume_buy = 0, total_volume_sel = 0;
   double max_openprice_buy = 0, min_openprice_sel = 10000000;
   double cur_tp_buy = 0, cur_tp_sel = 0;

   ulong first_ticket_buy = 0, first_ticket_sel = 0;
   datetime first_open_time_buy = 0, first_open_time_sel = 0;
   double first_entry_buy = 0, first_entry_sel = 0;

   double last_entry_buy = 0, last_entry_sel = 0;
   ulong last_ticket_buy = 0, last_ticket_sel = 0;
   string last_comment_buy = "", last_comment_sel = "";

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            if(is_same_symbol(TRADER, m_position.Comment()) == false)
               continue;

            double cur_profit = m_position.Profit() + m_position.Swap() + m_position.Commission();
            string TRADING_TREND = get_trend_in_note(m_position.TypeDescription());

            //if(is_same_symbol(m_position.Comment(), "01"))
            //   create_lable(time2string(m_position.Time()), TimeCurrent(), m_position.TakeProfit(), "(TP)(" +get_trend_nm(TRADING_TREND) + ") " + TRADER);

            if(TRADING_TREND == TREND_BUY)
              {
               count_possion_buy += 1;
               total_profit_buy += cur_profit;
               total_volume_buy += m_position.Volume();

               if(last_ticket_buy < m_position.Ticket())
                 {
                  cur_tp_buy = m_position.TakeProfit();
                  last_entry_buy = m_position.PriceOpen();
                  last_ticket_buy = m_position.Ticket();
                  last_comment_buy = m_position.Comment();
                 }

               if(is_same_symbol(m_position.Comment(), "01"))
                 {
                  first_ticket_buy = m_position.Ticket();
                  first_open_time_buy = m_position.Time();
                  first_entry_buy = m_position.PriceOpen();
                 }

               if(max_openprice_buy < m_position.PriceOpen())
                  max_openprice_buy = m_position.PriceOpen();
              }

            if(TRADING_TREND == TREND_SEL)
              {
               count_possion_sel += 1;
               total_profit_sel += cur_profit;
               total_volume_sel += m_position.Volume();

               if(last_ticket_sel < m_position.Ticket())
                 {
                  cur_tp_sel = m_position.TakeProfit();
                  last_entry_sel = m_position.PriceOpen();
                  last_ticket_sel = m_position.Ticket();
                  last_comment_sel = m_position.Comment();
                 }

               if(is_same_symbol(m_position.Comment(), "01"))
                 {
                  first_ticket_sel = m_position.Ticket();
                  first_open_time_sel = m_position.Time();
                  first_entry_sel = m_position.PriceOpen();
                 }

               if(min_openprice_sel > m_position.PriceOpen())
                  min_openprice_sel =m_position.PriceOpen();
              }
           }
        }
     } //for

//-----------------------------------------------------------------------------
   if(count_possion_buy == 0 && trend_init == TREND_BUY)
      m_trade.Buy(init_volume,  symbol, price, 0.0, price + AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy+1));

   if(count_possion_sel == 0 && trend_init == TREND_SEL)
      m_trade.Sell(init_volume, symbol, price, 0.0, price - AMP_DCA, TRADER + get_trend_nm(TREND_SEL) + "_" + append1Zero(count_possion_sel+1));
//-----------------------------------------------------------------------------

   if(trend_init == TREND_BUY && count_possion_buy > 0 && count_possion_buy < NUMBER_OF_TRADE && (price < last_entry_buy - AMP_DCA))
     {
      double amp_tp = MathMax(AMP_TP_DCA, MathAbs(first_entry_buy - last_entry_buy)*0.618);
      double tp_buy = NormalizeDouble(price + amp_tp, digits);

      count_possion_buy += 1;
      double volume = is_increase_vol_by_fibo ? get_value_by_fibo_1618(init_volume, count_possion_buy, 2) : init_volume;

      if(m_trade.Buy(volume, symbol, 0.0, 0.0, tp_buy, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy)))
         ModifyTp_ExceptLockKey(symbol, TREND_BUY, tp_buy, TRADER);
     }

   if(trend_init == TREND_SEL && count_possion_sel > 0 && count_possion_sel < NUMBER_OF_TRADE && (price > last_entry_sel + AMP_DCA))
     {
      double amp_tp = MathMax(AMP_TP_DCA, MathAbs(last_entry_sel - first_entry_sel)*0.618);
      double tp_sel = NormalizeDouble(price - amp_tp, digits);

      count_possion_sel += 1;
      double volume = is_increase_vol_by_fibo ? get_value_by_fibo_1618(init_volume, count_possion_sel, 2) : init_volume;
      if(m_trade.Sell(volume, symbol, 0.0, 0.0, tp_sel, TRADER + get_trend_nm(TREND_SEL) + "_" + append1Zero(count_possion_sel)))
         ModifyTp_ExceptLockKey(symbol, TREND_SEL, tp_sel, TRADER);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade_DCASH(string symbol, double AMP_DCA, string trend_init, double init_volume = 0.01, int NUMBER_OF_TRADE = 100)
  {
   if(is_same_symbol(INDICES, symbol) && trend_init != TREND_BUY)
      return;

   string TRADER = "(Vechai)";

   if(trend_init == TREND_BUY)
      TRADER = "(Bhufu"+(string) AMP_DCA +")";

   if(trend_init == TREND_SEL)
      TRADER = "(Shufu"+(string) AMP_DCA +")";

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   int count_possion_buy = 0, count_possion_sel = 0;
   double total_profit=0, total_profit_buy = 0, total_profit_sel = 0;
   double total_volume_buy = 0, total_volume_sel = 0;
   double max_openprice_buy = 0, min_openprice_sel = 10000000;
   double cur_tp_buy = 0, cur_tp_sel = 0;

   ulong first_ticket_buy = 0, first_ticket_sel = 0;
   datetime first_open_time_buy = 0, first_open_time_sel = 0;
   double first_entry_buy = 0, first_entry_sel = 0;

   double last_entry_buy = 0, last_entry_sel = 0;
   ulong last_ticket_buy = 0, last_ticket_sel = 0;
   string last_comment_buy = "", last_comment_sel = "";

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
           {
            if(is_same_symbol(TRADER, m_position.Comment()) == false)
               continue;

            double cur_profit = m_position.Profit() + m_position.Swap() + m_position.Commission();
            string TRADING_TREND = get_trend_in_note(m_position.TypeDescription());

            if(TRADING_TREND == TREND_BUY)
              {
               count_possion_buy += 1;
               total_profit_buy += cur_profit;
               total_volume_buy += m_position.Volume();

               if(last_ticket_buy < m_position.Ticket())
                 {
                  cur_tp_buy = m_position.TakeProfit();
                  last_entry_buy = m_position.PriceOpen();
                  last_ticket_buy = m_position.Ticket();
                  last_comment_buy = m_position.Comment();
                 }

               if(is_same_symbol(m_position.Comment(), "01"))
                 {
                  first_ticket_buy = m_position.Ticket();
                  first_open_time_buy = m_position.Time();
                  first_entry_buy = m_position.PriceOpen();
                 }

               if(max_openprice_buy < m_position.PriceOpen())
                  max_openprice_buy = m_position.PriceOpen();
              }

            if(TRADING_TREND == TREND_SEL)
              {
               count_possion_sel += 1;
               total_profit_sel += cur_profit;
               total_volume_sel += m_position.Volume();

               if(last_ticket_sel < m_position.Ticket())
                 {
                  cur_tp_sel = m_position.TakeProfit();
                  last_entry_sel = m_position.PriceOpen();
                  last_ticket_sel = m_position.Ticket();
                  last_comment_sel = m_position.Comment();
                 }

               if(is_same_symbol(m_position.Comment(), "01"))
                 {
                  first_ticket_sel = m_position.Ticket();
                  first_open_time_sel = m_position.Time();
                  first_entry_sel = m_position.PriceOpen();
                 }

               if(min_openprice_sel > m_position.PriceOpen())
                  min_openprice_sel = m_position.PriceOpen();
              }
           }
        }
     } //for

//---------------------------------------------------------------------------
   if(count_possion_buy == 0 && trend_init == TREND_BUY)
      m_trade.Buy(init_volume,  symbol, price, 0.0, price + AMP_DCA, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy+1));

   if(count_possion_sel == 0 && trend_init == TREND_SEL)
      m_trade.Sell(init_volume, symbol, price, 0.0, price - AMP_DCA, TRADER + get_trend_nm(TREND_SEL) + "_" + append1Zero(count_possion_sel+1));
//---------------------------------------------------------------------------
   if(count_possion_buy > 0 && count_possion_buy < NUMBER_OF_TRADE && (price < last_entry_buy - AMP_DCA))
     {
      double amp_tp = MathMax(AMP_DCA*2, MathAbs(first_entry_buy - last_entry_buy)*0.618);
      double tp_buy = NormalizeDouble(price + amp_tp, digits);

      count_possion_buy += 1;
      double volume = get_value_by_fibo_1618(init_volume, count_possion_buy, 2);
      if(m_trade.Buy(volume, symbol, 0.0, 0.0, tp_buy, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy)))
         ModifyTp_ExceptLockKey(symbol, TREND_BUY, tp_buy, TRADER);
     }

   if(count_possion_sel > 0 && count_possion_sel < NUMBER_OF_TRADE && (price > last_entry_sel + AMP_DCA))
     {
      double amp_tp = MathMax(AMP_DCA*2, MathAbs(last_entry_sel - first_entry_sel)*0.618);
      double tp_sel = NormalizeDouble(price - amp_tp, digits);

      count_possion_sel += 1;
      double volume = get_value_by_fibo_1618(init_volume, count_possion_sel, 2);
      if(m_trade.Sell(volume, symbol, 0.0, 0.0, tp_sel, TRADER + get_trend_nm(TREND_SEL) + "_" + append1Zero(count_possion_sel)))
         ModifyTp_ExceptLockKey(symbol, TREND_SEL, tp_sel, TRADER);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_ticket_key(ulong ticket)
  {
   string key = "";

   if(ticket > 0)
      key = "(" + (string)(ticket)+ ")";

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ExceptLockKey(string symbol, string TRADING_TREND, double tp_price, string KEY_TO_CLOSE)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.Comment()), toLower(KEY_TO_CLOSE)) >= 0)
               if(StringFind(toLower(m_position.TypeDescription()), toLower(TRADING_TREND)) >= 0)
                  if(m_position.TakeProfit() != tp_price)
                     if(is_same_symbol(m_position.Comment(), LOCK_BUY) == false && is_same_symbol(m_position.Comment(), LOCK_SEL) == false)
                       {
                        double new_sl = m_position.StopLoss();
                        double new_tp = m_position.TakeProfit();
                        if(is_same_symbol(m_position.TypeDescription(), TREND_BUY))
                          {
                           if(tp_price > m_position.PriceOpen())
                              new_tp = tp_price;
                           else
                              new_sl = tp_price;
                          }

                        if(is_same_symbol(m_position.TypeDescription(), TREND_SEL))
                          {
                           if(tp_price < m_position.PriceOpen())
                              new_tp = tp_price;
                           else
                              new_sl = tp_price;
                          }

                        m_trade.PositionModify(m_position.Ticket(), new_sl, new_tp);
                       }
        }
     } //for
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifySL(string symbol, string TRADING_TREND, double sl_price, string KEY_TO_CLOSE)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.Comment()), toLower(KEY_TO_CLOSE)) >= 0)
               if(StringFind(toLower(m_position.TypeDescription()), toLower(TRADING_TREND)) >= 0)
                  if(m_position.StopLoss() != sl_price)
                     m_trade.PositionModify(m_position.Ticket(), sl_price, m_position.TakeProfit());
        }
     } //for
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Market(string symbol, string TRADING_TREND, double volume, string KEY_CLOSE, double tp_price)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double open1 = iOpen(symbol, PERIOD_H1, 1);
   double close1 = iClose(symbol, PERIOD_H1, 1);

   bool allow_trade_now = false;
   if(TRADING_TREND == TREND_BUY && (price <= MathMin(open1, close1)))
      allow_trade_now = true;
   if(TRADING_TREND == TREND_SEL && (price >= MathMax(open1, close1)))
      allow_trade_now = true;
   if(allow_trade_now == false)
      return false;

   string reverse = get_trend_reverse(TRADING_TREND);
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H1, reverse, 3, 2, 3))
      return false;
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H4, reverse, 3, 2, 3))
      return false;
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_D1, reverse, 3, 2, 3))
      return false;

   if(check_trade_interval() == false)
      return false;

   double risk = calcRisk();
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);
   double default_volume = calc_volume_by_amp(symbol, amp_d1, risk);
   if(volume > default_volume*3)
      volume = default_volume*3;

   if(TRADING_TREND == TREND_BUY)
     {
      Sleep(5000);
      if(m_trade.Buy(volume,  symbol, 0.0, 0.0, tp_price, KEY_CLOSE))
        {
         return true;
        }
     }

   if(TRADING_TREND == TREND_SEL)
     {
      Sleep(5000);
      if(m_trade.Sell(volume, symbol, 0.0, 0.0, tp_price, KEY_CLOSE))
        {
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool passes_last_order_open_time(int hours)
  {
   datetime currentTime = TimeCurrent(); // Lấy thời gian hiện tại
   datetime timeGap = currentTime - last_order_open_time; // Tính thời gian giữa hai lệnh mở (đơn vị: giây)

// Nếu thời gian giữa các lệnh mở lớn hơn hoặc bằng 36 tiếng (36 * 3600 giây)
   if(timeGap >= hours * 3600)
     {
      last_order_open_time = currentTime;
      return true; // Thời gian giữa các lệnh mở đủ lớn
     }
   else
      return false; // Thời gian giữa các lệnh mở không đủ lớn
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool check_trade_interval()
  {
   datetime currentTime = TimeCurrent(); // Lấy thời gian hiện tại
   datetime timeGap = currentTime - last_open_trade_time; // Tính thời gian giữa hai lệnh mở (đơn vị: giây)

// Nếu thời gian giữa các lệnh mở lớn hơn hoặc bằng 5 phút (15 * 60 giây)
   if(timeGap >= 5 * 60)
     {
      last_open_trade_time = TimeCurrent();
      return true; // Thời gian giữa các lệnh mở đủ lớn
     }
   else
      return false; // Thời gian giữa các lệnh mở không đủ lớn
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
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, string TRADING_TREND, string KEY_TO_CLOSE)
  {
   string msg = "";
   double profit = 0.0;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(TRADING_TREND == "" || (StringFind(toLower(m_position.TypeDescription()), toLower(TRADING_TREND)) >= 0))
               if(KEY_TO_CLOSE == "" || (StringFind(toLower(m_position.Comment()), toLower(KEY_TO_CLOSE)) >= 0))
                 {
                  //create_lable(time2string(m_position.Time())
                  //             , m_position.Time()
                  //             , m_position.PriceOpen() - amp_d1
                  //             , " Pg: " + (string) NormalizeDouble(m_position.Profit(), 1) + "$", m_position.Profit() > 0 ? TREND_BUY : TREND_SEL);

                  msg += (string)m_position.Ticket() + ": " + (string) m_position.Profit() + "$";
                  profit += m_position.Profit();
                  m_trade.PositionClose(m_position.Ticket());
                 }
     } //for

   if(msg != "")
      SendTelegramMessage(symbol, STOP_TRADE, STOP_TRADE + " " + TRADING_TREND + "  " + symbol + "   Total: " + (string) profit + "$ ");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition_TakeProfit(string symbol, string TRADING_TREND, string KEY_CLOSE)
  {
   string msg = "";
   double profit = 0.0;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_position.Symbol()))
            if(StringFind(toLower(m_position.TypeDescription()), toLower(TRADING_TREND)) >= 0)
               if(KEY_CLOSE == "" || (StringFind(m_position.Comment(), KEY_CLOSE) >= 0))
                  if(m_position.Profit() > 1)
                    {
                     //create_lable(time2string(m_position.Time())
                     //             , m_position.Time()
                     //             , m_position.PriceOpen() - amp_d1
                     //             , " P1: " + (string) NormalizeDouble(m_position.Profit(), 1) + "$", m_position.Profit() > 0 ? TREND_BUY : TREND_SEL);

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
void CloseOrders(string symbol, string TRADING_TREND, string KEY_CLOSE)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(m_order.SelectByIndex(i))
         if(toLower(symbol) == toLower(m_order.Symbol()))
            if(StringFind(toLower(m_order.TypeDescription()), toLower(TRADING_TREND)) >= 0)
               if(KEY_CLOSE == "" || (StringFind(m_position.Comment(), KEY_CLOSE) >= 0))
                  m_trade.OrderDelete(m_order.Ticket());

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_value_by_fibo_1618(double init, int trade_no, int digits)
  {
   double fibo = 1.618;
   double vol = init;
   for(int i = 2; i <= trade_no; i++)
     {
      vol = vol*fibo;
     }

   return NormalizeDouble(vol, digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_value_by_fibo_1236(double init, int trade_no, int digits)
  {
   double fibo = 1.236;
   double dca = init;
   for(int i = 2; i <= trade_no; i++)
     {
      dca = dca*fibo;
     }

   return NormalizeDouble(dca, digits);
  }


//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

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
//---

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

   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);


   int count = 0;
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol, TIMEFRAME, i);
     }

   double ma07[5];
   double ma10[5];
   double ma20[5];
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

//----------------------------------------------------------------
//   if(TIMEFRAME == PERIOD_H4)
//     {
//      datetime time1 = iTime(symbol, TIMEFRAME, 1);
//      datetime time0 = iTime(symbol, TIMEFRAME, 0);
//      string drawtime = time2string(time1);
//
//      if(trend_ma02050 != "")
//         create_lable_trim("ma50" + drawtime, time1, ma50_1,  trend_ma02050  == TREND_BUY ? "50b": "50s",  trend_ma02050 == TREND_BUY ? clrBlue : clrRed, 5, 6, ANCHOR_CENTER);
//
//
//      create_line("ma20_1_0" + drawtime, time1, ma20[1], time0, ma20[0], clrBlack, STYLE_DASHDOTDOT, 1, false, false);
//      if(trend_ma1020 != "")
//         create_lable_trim("ma20" + drawtime, time1, ma20[1], trend_ma1020 == TREND_BUY ? "20b": "20s", trend_ma1020 == TREND_BUY ? clrBlue : clrRed, 5, 6, ANCHOR_CENTER);
//
//
//      create_line("ma10_1_0" + drawtime, time1, ma10[1], time0, ma10[0], clrBlack, STYLE_DOT, 1, false, false);
//      if(trend_C1ma10 != "")
//         create_lable_trim("ma10" + drawtime, time1, ma10[1],   trend_C1ma10 == TREND_BUY ? "10b": "10s",   trend_C1ma10 == TREND_BUY ? clrBlue : clrRed, 5, 6, ANCHOR_CENTER);
//     }


//   double close_d1 = iClose(symbol, PERIOD_D1, 1);
//   double close_d0_low = iLow(symbol, PERIOD_D1, 0);
//   double close_d0_hig = iHigh(symbol, PERIOD_D1, 0);
//   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
//
//   string d_prefix = "rule";//time2string(iTime(symbol, PERIOD_D1, 0));
//   datetime time = TimeCurrent() ;//+ (iTime(symbol, PERIOD_H4, 1) - iTime(symbol, PERIOD_H4, 2));
//   create_lable_trim("lc1" + d_prefix, time, close_d1, (string)NormalizeDouble(close_d1, digits), clrBlue, 5, 8, ANCHOR_CENTER);
//
//   create_lable_trim("lup" + d_prefix, time, close_d0_hig, (string)NormalizeDouble(close_d0_hig - close_d1, digits), clrBlue, 5, 8, ANCHOR_CENTER);
//   create_lable_trim("ldn" + d_prefix, time, close_d0_low, (string)NormalizeDouble(close_d1 - close_d0_low, digits), clrRed, 5, 8, ANCHOR_CENTER);
//
//   create_line("up" + d_prefix,        time, close_d1, time, close_d0_hig, clrBlue, STYLE_SOLID, 2, false, false);
//   create_line("dn" + d_prefix,        time, close_d1, time, close_d0_low, clrRed, STYLE_SOLID, 2, false, false);
//
//   create_lable_trim("aup" + d_prefix, time, close_d1 + avg_amp_h4, "+" + (string)NormalizeDouble(avg_amp_h4, digits), clrRed, 5, 8, ANCHOR_CENTER);
//   create_lable_trim("adn" + d_prefix, time, close_d1 - avg_amp_h4, "-" + (string)NormalizeDouble(avg_amp_h4, digits), clrRed, 5, 8, ANCHOR_CENTER);
//
//   create_vertical_line("v" + d_prefix, iTime(symbol, PERIOD_D1, 0), clrBlack,  STYLE_DASHDOTDOT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool has_D1_scam_in_10_candles_H4(string symbol, string find_trend)
  {
   CandleData arr_candlestick[];
   get_arr_candlestick(symbol, PERIOD_H4, arr_candlestick, 5);

   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);

   for(int i = 0; i < ArraySize(arr_candlestick) - 1; i++)
     {
      if(find_trend == arr_candlestick[i].trend)
        {
         double amp_i = MathAbs(arr_candlestick[i].open - arr_candlestick[i].close);
         if(amp_i > amp_d1)
           {
            double start_price = iOpen(symbol, PERIOD_H4, i);

            string lbl_name = "scam_" + time2string(iTime(symbol, PERIOD_H4, i));
            create_lable(lbl_name + "Op", iTime(symbol, PERIOD_H4, i), start_price,                                                       "__d1__",             find_trend, true);
            create_lable(lbl_name + "Am", iTime(symbol, PERIOD_H4, i), find_trend == TREND_BUY ? start_price+amp_d1 : start_price-amp_d1, "_" + (string)amp_d1, find_trend, true);

            return false;
           }
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPriceAmp(string symbol, string timeframe)
  {
   string file_name = "AMP.txt";

   if(is_has_memo_in_file(file_name, PREFIX_TRADE_PERIOD_MO, "RE_CALC_MONLY", "AMP_WDH") == false)
     {
      int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);

      if(fileHandle != INVALID_HANDLE)
        {
         int total_fx_size = ArraySize(arr_symbol);
         for(int index = 0; index < total_fx_size; index++)
           {
            string symbol = arr_symbol[index];
            string file_contents = symbol
                                   + "~" + "(W1)" + (string) CalculateAverageCandleHeight(PERIOD_W1, symbol, 120)
                                   + "~" + "(D1)" + (string) CalculateAverageCandleHeight(PERIOD_D1, symbol, 360)
                                   + "~" + "(H4)" + (string) CalculateAverageCandleHeight(PERIOD_H4, symbol, 720)
                                   + ";";

            FileWriteString(fileHandle, file_contents);
           }

         FileClose(fileHandle);
        }

      add_memo_to_file(file_name, PREFIX_TRADE_PERIOD_MO, "RE_CALC_MONLY", "AMP_WDH");
     }

// Mở tệp để đọc
   int file_handle = FileOpen(file_name, FILE_READ);
   if(file_handle == INVALID_HANDLE)
     {
      Print("Error opening file ", file_name);
      return CalculateAverageCandleHeight(PERIOD_W1, symbol, 12);
     }

// Duyệt qua từng dòng trong tệp
   string contents;
   while(!FileIsEnding(file_handle))
     {
      // Đọc mỗi dòng trong tệp
      contents = FileReadString(file_handle);

      ushort tab_delimiter = StringGetCharacter("~",0);
      ushort line_delimiter = StringGetCharacter(";",0);

      string lines[];
      StringSplit(contents, line_delimiter, lines);

      for(int i= 0; i<ArraySize(lines); i++)
        {
         string line = lines[i];
         if(is_same_symbol(line, symbol))
           {
            //Print(line);
            string tabs[];
            StringSplit(line, tab_delimiter, tabs);
            for(int j= 0; j<ArraySize(tabs); j++)
              {
               if(is_same_symbol(tabs[j], timeframe))
                 {
                  string amp = tabs[j];
                  StringReplace(amp, "(", "");
                  StringReplace(amp, timeframe, "");
                  StringReplace(amp, ")", "");
                  StringReplace(amp, " ", "");

                  double price_range = StringToDouble(amp);
                  FileClose(file_handle);

                  if(price_range > 0)
                     return price_range;
                 }
              }
           }
        }

     }

// Đóng tệp và trả về giá trị mặc định nếu không tìm thấy
   FileClose(file_handle);
   Print("Get PriceAmp not found for ", symbol, " ", timeframe);

   return CalculateAverageCandleHeight(PERIOD_W1, symbol, 12);
  }

////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//double get_amp_tp(string symbol)
//  {
////if(is_same_symbol("XAU", symbol))
////   return 5;
//
//   double amp_w1;
//   double amp_d1;
//   double amp_h4;
//   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);
//
//   return 1;
//  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_in_note(string TREND)
  {
   if(is_same_symbol(TREND, TREND_BUY))
      return TREND_BUY;

   if(is_same_symbol(TREND, TREND_SEL))
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_nm(string TREND)
  {
   if(is_same_symbol(TREND, TREND_BUY))
      return "B";

   if(is_same_symbol(TREND, TREND_SEL))
      return "S";

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   double risk = calcRisk();
   double amp_w1 = 0, amp_d1 = 0, amp_h4 = 0;
   GetAmpAvg(Symbol(), amp_w1, amp_d1, amp_h4);
   string volume_bt = format_double_to_string(dblLotsRisk(Symbol(), amp_d1, risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + Symbol();

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);

   string trend_by_macd_d1 = "", trend_mac_vs_signal_d1 = "", trend_mac_vs_zero_d1 = "";
   get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_D1, trend_by_macd_d1, trend_mac_vs_signal_d1, trend_mac_vs_zero_d1);

   str_comments += "    Macd(H4): " + (string) trend_by_macd_h4;
   str_comments += "    Macd(D1): " + (string) trend_mac_vs_signal_d1;

   if(IS_DEBUG_MODE == false)
     {
      str_comments += "    Vol: " + volume_bt + " lot";
      str_comments += "    Funds: " + (string) INIT_EQUITY + "$ / Risk: " + (string) risk + "$ / " + (string)(dbRiskRatio * 100) + "%    ";

      //str_comments += "\n";
      str_comments += "    Avg(H4): " + (string) amp_h4;
      str_comments += "    Avg(D1): " + (string) amp_d1;
      str_comments += "    Avg(W1): " + (string) amp_w1;
     }

   if(IsMarketClose())
      str_comments += "    MarketClose";
   else
      str_comments += "    Market Open";
   str_comments += "    " + get_profit_today();


   return str_comments;
  }


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
   if(18 <= currentHour && currentHour <= 20)
      return true; //started US session, and strong news
   if(3 < currentHour && currentHour < 7)
      return true; //VietnamEarlyMorning

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trading_key(string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND)
  {
// "@TF:H4:BUY:XAUUSD;"

   string today = (string)iTime(symbol, PERIOD_D1, 0);
   StringReplace(today, " ", "");
   StringReplace(today, ":", "");
   StringReplace(today, ".", "");
   StringReplace(today, "000000", "");

   return today + MEMORY_WATING + PREFIX_TRADE_PERIOD_XX + ":" + TRADING_TREND + ":" + symbol + ";";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string time2string(datetime time)
  {
   string today = (string)time;
   StringReplace(today, " ", "");
   StringReplace(today, ":", "");
   StringReplace(today, ".", "");

   return today;
  }


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
string get_prefix_trade_from_timeframe(ENUM_TIMEFRAMES period)
  {
   if(period == PERIOD_M5)
      return PREFIX_TRADE_PERIOD_M5;

   if(period == PERIOD_M15)
      return PREFIX_TRADE_PERIOD_M15;

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
      return PERIOD_M15;

   if(PREFIX_TRADE_PERIOD == PREFIX_TRADE_PERIOD_M15)
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

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M15)) >= 0)
      return PREFIX_TRADE_PERIOD_M15;

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

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M15)) >= 0)
      return PERIOD_M15;

   if(StringFind(low_comments, toLower(PREFIX_TRADE_PERIOD_M5)) >= 0)
      return PERIOD_M5;

   return PERIOD_H4;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES get_timeframe(string PREFIX_TRADE_PERIOD_XX)
  {
   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_W1)
      return PERIOD_W1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_D1)
      return PERIOD_D1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_H4)
      return PERIOD_H4;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_H1)
      return PERIOD_H1;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_M15)
      return PERIOD_M15;

   if(PREFIX_TRADE_PERIOD_XX == PREFIX_TRADE_PERIOD_M5)
      return PERIOD_M5;

   return PERIOD_D1;
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
double calc_volume_by_amp(string symbol, double amp_trade, double risk)
  {
   return dblLotsRisk(symbol, amp_trade, risk);
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
string create_key(string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND_KEY)
  {
   ENUM_TIMEFRAMES TIMEFRAME = get_timeframe(PREFIX_TRADE_PERIOD_XX);
   string date_time = (string)iTime(symbol, TIMEFRAME, 0);
   StringReplace(date_time, ":", "");

   string key = date_time + ":" + PREFIX_TRADE_PERIOD_XX + ":" + TRADING_TREND_KEY + ":" + symbol +";";
   StringReplace(key, " ", "_");
   StringReplace(key, ".", "");
   StringReplace(key, "::", ":");
   StringReplace(key, ":", ":");

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_has_memo_in_file(string filename, string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND_KEY)
  {
   string open_trade_today = ReadFileContent(filename);

   string key = create_key(PREFIX_TRADE_PERIOD_XX, symbol, TRADING_TREND_KEY);
   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void remove_memo_from_file(string filename, string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND_KEY)
  {
   string file_contents = ReadFileContent(filename);

   string key_find = create_key(PREFIX_TRADE_PERIOD_XX, symbol, TRADING_TREND_KEY);
   bool has_value = StringFind(file_contents, key_find) >= 0;

   if(has_value)
     {
      StringReplace(file_contents, key_find, "");
      WriteFileContent(filename, file_contents);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename, string PREFIX_TRADE_PERIOD_XX, string symbol, string TRADING_TREND_KEY, string note_stoploss = "", ulong ticket = 0, string note = "")
  {
   string open_trade_today = ReadFileContent(filename);
   string key = create_key(PREFIX_TRADE_PERIOD_XX, symbol, TRADING_TREND_KEY);

   open_trade_today = open_trade_today + key;

   if(StringLen(note_stoploss) > 1 || note_stoploss != "")
     {
      open_trade_today += MEMORY_STOPLOSS + note_stoploss;
      open_trade_today += MEMORY_TICKET + (string) ticket;
     }

   if(note != "")
      open_trade_today += note;

   open_trade_today += STR_NEXT_ITEM;

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
   int max_lengh = 1000;
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

   string result = "    Swap:" + format_double_to_string(swap, 2) + "$";
   result += "    Profit Today:" + format_double_to_string(loss, 2) + "$";

   if(loss + INIT_EQUITY*0.1 < 0)
      result += STOP_TRADE;

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAverageCandleHeight(ENUM_TIMEFRAMES timeframe, string symbol, int length)
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
//+------------------------------------------------------------------+


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

      CandleData candle(time, open, high, low, close, trend, 0);
      candleArray[index] = candle;
     }


   for(int index = length + 3; index >= 0; index--)
     {
      CandleData cancle_i = candleArray[index];

      int count_trend = 1;
      for(int j = index+1; j < length; j++)
        {
         if(cancle_i.trend == candleArray[j].trend)
            count_trend += 1;
         else
            break;
        }

      candleArray[index].count = count_trend;
     }

  }

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

//if(StringFind(message, "OPEN_TRADE") >= 0)
//  {
//   string str_count_trade = CountTrade(symbol);
//   bool has_position_buy = StringFind(str_count_trade, TRADE_COUNT_POSITION_B) >= 0;
//   bool has_position_sel = StringFind(str_count_trade, TRADE_COUNT_POSITION_S) >= 0;
//
//   if(trend == TREND_BUY && has_position_buy)
//      return;
//
//   if(trend == TREND_SEL && has_position_sel)
//      return;
//
//   if(is_allow_send_msg_telegram(symbol, PERIOD_W1, 10, trend) == false)
//      return;
//  }

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
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_entry(
   const ulong             ticket,                          // ticket
   datetime                time_draw=0,                     // anchor point time
   double                  openprice=0,                     // anchor point price
   const string            TREND="BUY",
   double                  amp_tp=0,                        // anchor point price
   string                  label="label"                   // anchor point price
)
  {
   return;

   string TRADING_TREND = is_same_symbol(TREND, TREND_BUY) ? TREND_BUY : TREND_SEL;

   color clr_color = StringFind(label, "-") >= 0 ? clrRed : clrBlue;
   double tp_price = TRADING_TREND==TREND_BUY ? openprice + amp_tp : openprice - amp_tp;
   double sl_price = TRADING_TREND==TREND_BUY ? openprice - amp_tp : openprice + amp_tp;

   string name_lb = "z_" + (string) ticket + "_tx";
   string name_tp = "z_" + (string) ticket + "_tp";
   string name_sl = "z_" + (string) ticket + "_sl";

   TextCreate(0,name_lb, 0, time_draw, openprice, label, clr_color);

   ObjectCreate(0, name_tp, OBJ_TREND, 0, time_draw + TIME_OF_ONE_H4_CANDLE, tp_price, time_draw - 2*TIME_OF_ONE_H4_CANDLE, tp_price);
   ObjectSetInteger(0, name_tp, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_tp, OBJPROP_STYLE, STYLE_SOLID);

   ObjectCreate(0, name_sl, OBJ_TREND, 0, time_draw + TIME_OF_ONE_H4_CANDLE, sl_price, time_draw - 2*TIME_OF_ONE_H4_CANDLE, sl_price);
   ObjectSetInteger(0, name_sl, OBJPROP_COLOR, clrFireBrick);
   ObjectSetInteger(0, name_sl, OBJPROP_STYLE, STYLE_DOT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const string            TRADING_TREND="BUY",
   const bool              trim_text = true
)
  {
   color clr_color = TRADING_TREND==TREND_BUY ? clrBlue : clrRed;
   TextCreate(0,name, 0, time_to, price, trim_text ? label : "        " + label, clr_color);
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
void create_entry_line(
   const string            name="Text",                  // object name
   datetime                time_from=0,                  // anchor point time
   datetime                time_to=0,                    // anchor point time
   double                  price=0,                      // anchor point price
   string                  title = "Title",              // Title
   const string            TRADING_TREND= "BUY"              // color
)
  {
   string name_new = name;
   create_lable(name_new + "lbl", time_from, price, title, TRADING_TREND, true);
   color clr_color = TRADING_TREND == TREND_BUY ? clrBlue : clrRed;

   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price, time_to, price);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_LEFT, false);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT, false); // Bật tính năng "Rời qua phải"
   ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);
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
   const int               STYLE_XX=STYLE_SOLID,
   const int               width = 1,
   const bool              ray_left = false,
   const bool              ray_right = false,
   const bool              is_hiden = true
)
  {
   string name_new = name;
   if(is_hiden)
      name_new = name + STR_RE_DRAW;

   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price_from, time_to, price_to);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_LEFT, false);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT, false); // Bật tính năng "Rời qua phải"
   ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_XX);
   ObjectSetInteger(0, name_new, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN,      is_hiden);
   ObjectSetInteger(0, name_new, OBJPROP_BACK,        is_hiden);
   ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE,  !is_hiden);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_LEFT, ray_left);   // Tắt tính năng "Rời qua trái"
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT, ray_right); // Bật tính năng "Rời qua phải"
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

   double amp_2_3 = MathAbs(higest - lowest) * 2.0 / 3.0;
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);

   if(price > MathAbs(higest - amp_2_3))
      return TREND_SEL;

   if(price < MathAbs(lowest + amp_2_3))
      return TREND_BUY;

   return "";
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
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
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

   if(find_trend == TREND_BUY && black_K >= red_D && (red_D <= 20 || black_K <= 20))
      return true;

   if(find_trend == TREND_SEL && black_K <= red_D && (red_D >= 80 || black_K >= 80))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc132_ma7(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_ma7 = get_trend_by_ma(symbol, timeframe, 3, 1);
   if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 3, 2, 3, 0))
      if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 13, 8, 5, 0))
         return trend_ma7;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc82_ma7(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string trend_ma7 = get_trend_by_ma(symbol, timeframe, 7, 1);
   if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 3, 2, 3, 0))
      if(trend_ma7 == get_trend_by_stoc2(symbol, timeframe, 8, 5, 3, 0))
         return trend_ma7;
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_maX_maY(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_10, int ma_index_20)
  {
   int maLength = MathMax(ma_index_10, ma_index_20) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_10_1 = cal_MA(closePrices, ma_index_10, 1);
   double ma_20_1 = cal_MA(closePrices, ma_index_20, 1);

   double ma_10_0 = cal_MA(closePrices, ma_index_10, 0);
   double ma_20_0 = cal_MA(closePrices, ma_index_20, 0);

   string trend_10_0 = ma_10_0 > ma_10_1 ? TREND_BUY : TREND_SEL;
   string trend_20_0 = ma_20_0 > ma_20_1 ? TREND_BUY : TREND_SEL;

   if(trend_10_0 == trend_20_0)
      return trend_20_0;

   if(ma_10_0 > ma_20_0 && ma_10_1 > ma_20_1)
      return TREND_BUY;

   if(ma_10_0 < ma_20_0 && ma_10_1 < ma_20_1)
      return TREND_SEL;

   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_candlestick(string symbol, ENUM_TIMEFRAMES TIME_FRAME, string TRADING_TREND)
  {
   double open  = iOpen(symbol,  TIME_FRAME, 1);
   double high  = iHigh(symbol,  TIME_FRAME, 1);
   double low   = iLow(symbol,   TIME_FRAME, 1);
   double close = iClose(symbol, TIME_FRAME, 1);

   double body = MathAbs(open - close);
   double shadow_hig = high - MathMax(open, close);
   double shadow_low = MathMin(open, close) - low;

   bool is_hammer = false;
   if(TRADING_TREND == TREND_SEL)
      is_hammer = (body*3 <= shadow_low);

   if(TRADING_TREND == TREND_BUY)
      is_hammer = (body*3 <= shadow_hig);

   if(is_hammer)
     {
      int count = 0;
      for(int i = 2; i <= 20; i++)
        {
         if(TRADING_TREND == TREND_BUY)
            if(close > iClose(symbol, TIME_FRAME, i))
               count += 1;

         if(TRADING_TREND == TREND_SEL)
            if(close < iClose(symbol, TIME_FRAME, i))
               count += 1;
        }

      if(count >= 15)
        {
         //color clrColor = TRADING_TREND == TREND_BUY ? clrBlue : clrRed;
         //string lbl_name = "hammer_" + get_prefix_trade_from_timeframe(TIME_FRAME) + time2string(iTime(symbol, TIME_FRAME, 1));
         //create_lable_trim(lbl_name, iTime(symbol, TIME_FRAME, 1), close, "Hammer", clrColor, 5, 8, ANCHOR_RIGHT);

         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {
   if(Period() > PERIOD_D1)
      if(is_must_exit_trade_by_stoch_extrema(symbol, TIMEFRAME, find_trend, 3, 3, 3))
         return true;

   if(is_must_exit_trade_by_stoch_extrema(symbol, TIMEFRAME, find_trend, 5, 3, 3))
      return true;

   if(is_must_exit_trade_by_stoch_extrema(symbol, TIMEFRAME, find_trend, 8, 5, 3))
      return true;

   if(Period() <= PERIOD_D1)
      if(is_must_exit_trade_by_stoch_extrema(symbol, TIMEFRAME, find_trend, 13, 8, 5))
         return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_must_exit_trade_by_stoch_extrema(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
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

   if(find_trend == TREND_BUY && ((black_K >= 80 && red_D >= 80) || (black_K < red_D)))
      return true;

   if(find_trend == TREND_SEL && ((black_K <= 20 && red_D <= 20) || (black_K > red_D)))
      return true;

   if(timeframe >= PERIOD_D1)
     {
      if(find_trend == TREND_BUY && (black_K >= 70 || red_D >= 70))
         return true;

      if(find_trend == TREND_SEL && (black_K <= 30 || red_D <= 30))
         return true;
     }

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trend_shift(string symbol, string NEW_TREND)
  {
// (1: Thời gian giữa các lệnh:
//    1-1: 12 tiếng: 20k-> 110k
//    1-2:  4 tiếng: 20k-> 107.7k
//    1-3:  1 tiếng: 20k-> 109.5k
// (2: Trả về luôn) 20k-> 144k, sụt giảm tài khoản từ 30k về 6k, vô cùng nguy hiểm.

// Yêu cầu mỗi lần chuyển trạng thái từ Buy<->Sell:
// Cần chờ tối thiểu 1 giờ sau mỗi lần chuyển đổi để tránh tạo GAP sụt giảm tài khoản.
   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_trend_shift_time;
   if(timeGap >= 1 * 60 * 60)
      pass_time_check = true;
   else
      return false;

// (3: iStochastic) 20k-> 110k
   if(pass_time_check)
     {
      int handle_138 = iStochastic(symbol, PERIOD_H4, 13, 8, 5, MODE_SMA, STO_LOWHIGH);
      if(handle_138 == INVALID_HANDLE)
         return false;

      double K138[], D138[];
      ArraySetAsSeries(K138, true);
      ArraySetAsSeries(D138, true);
      CopyBuffer(handle_138,0,0,10,K138);
      CopyBuffer(handle_138,1,0,10,D138);

      double K138_0 = K138[0];
      double D138_0 = D138[0];

      if(NEW_TREND == TREND_BUY && (K138_0 < 80 || D138_0 < 80))
        {
         last_trend_shift_time = currentTime;
         return true;
        }

      if(NEW_TREND == TREND_SEL && (K138_0 > 20 || D138_0 > 20))
        {
         last_trend_shift_time = currentTime;
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool del_it_allow_trend_shift(string symbol, string NEW_TREND)
  {
   int handle_032 = iStochastic(symbol, PERIOD_H4,  3, 2, 3, MODE_SMA, STO_LOWHIGH);
   if(handle_032 == INVALID_HANDLE)
      return false;

   double K032[], D032[];
   ArraySetAsSeries(K032, true);
   ArraySetAsSeries(D032, true);
   CopyBuffer(handle_032,0,0,10,K032);
   CopyBuffer(handle_032,1,0,10,D032);

   int handle_085 = iStochastic(symbol, PERIOD_H4,  8, 5, 3, MODE_SMA, STO_LOWHIGH);
   if(handle_085 == INVALID_HANDLE)
      return false;

   double K085[], D085[];
   ArraySetAsSeries(K085, true);
   ArraySetAsSeries(D085, true);
   CopyBuffer(handle_085,0,0,10,K085);
   CopyBuffer(handle_085,1,0,10,D085);

   int handle_138 = iStochastic(symbol, PERIOD_H4, 13, 8, 5, MODE_SMA, STO_LOWHIGH);
   if(handle_138 == INVALID_HANDLE)
      return false;

   double K138[], D138[];
   ArraySetAsSeries(K138, true);
   ArraySetAsSeries(D138, true);
   CopyBuffer(handle_138,0,0,10,K138);
   CopyBuffer(handle_138,1,0,10,D138);

   double K032_0 = K032[0];
   double D032_0 = D032[0];
   double K032_1 = K032[1];
   double D032_1 = D032[1];

   double K085_0 = K085[0];
   double D085_0 = D085[0];
   double K085_1 = K085[1];
   double D085_1 = D085[1];

   double K138_0 = K138[0];
   double D138_0 = D138[0];
   double K138_1 = K138[1];
   double D138_1 = D138[1];

//   if(NEW_TREND == TREND_BUY && K032_0 >= 80 && D032_0 >= 80)
//      return false; // wait, đang ở đỉnh, không được BUY để chuyển xu hướng
//   if(NEW_TREND == TREND_SEL && K032_0 <= 20 && D032_0 <= 20)
//      return false; // wait, đang ở đáy, không được SEL để chuyển xu hướng
//
//   if(NEW_TREND == TREND_BUY && K085_0 >= 80 && D085_0 >= 80)
//      return false; // wait, đang ở đỉnh, không được BUY để chuyển xu hướng
//   if(NEW_TREND == TREND_SEL && K085_0 <= 20 && D085_0 <= 20)
//      return false; // wait, đang ở đáy, không được SEL để chuyển xu hướng
//
//   if(NEW_TREND == TREND_BUY && (K138_0 >= 80 || D138_0 >= 80))
//      return false; // wait, đang ở đỉnh, không được BUY để chuyển xu hướng
//   if(NEW_TREND == TREND_SEL && (K138_0 <= 20 || D138_0 <= 20))
//      return false; // wait, đang ở đáy, không được SEL để chuyển xu hướng
//
//
//
//   if(NEW_TREND == TREND_BUY && K032_1 >= 80 && D032_1 >= 80)
//      return false; // wait, đang ở đỉnh, không được BUY để chuyển xu hướng
//   if(NEW_TREND == TREND_SEL && K032_1 <= 20 && D032_1 <= 20)
//      return false; // wait, đang ở đáy, không được SEL để chuyển xu hướng
//
//   if(NEW_TREND == TREND_BUY && K085_1 >= 80 && D085_1 >= 80)
//      return false; // wait, đang ở đỉnh, không được BUY để chuyển xu hướng
//   if(NEW_TREND == TREND_SEL && K085_1 <= 20 && D085_1 <= 20)
//      return false; // wait, đang ở đáy, không được SEL để chuyển xu hướng
//
//   if(NEW_TREND == TREND_BUY && (K138_1 >= 80 || D138_1 >= 80))
//      return false; // wait, đang ở đỉnh, không được BUY để chuyển xu hướng
//   if(NEW_TREND == TREND_SEL && (K138_1 <= 20 || D138_1 <= 20))
//      return false; // wait, đang ở đáy, không được SEL để chuyển xu hướng


   if(NEW_TREND == TREND_BUY
      && (K138_0 < 80 && D138_0 < 80 && K032_0 < 80 && D032_0 < 80 && K085_0 < 80 && D085_0 < 80))
      return true;

   if(NEW_TREND == TREND_SEL
      && (K138_0 > 20 && D138_0 > 20 && K032_0 > 20 && D032_0 > 20 && K085_0 > 20 && D085_0 > 20))
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe, string &trend_by_macd, string &trend_mac_vs_signal, string &trend_mac_vs_zero)
  {
   trend_by_macd = "";
   trend_mac_vs_signal = "";
   trend_mac_vs_zero = "";

   int m_handle_macd = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
      return;

   double m_buff_MACD_main[];
   double m_buff_MACD_sign[];
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_sign,true);

   CopyBuffer(m_handle_macd, 0, 0, 2, m_buff_MACD_main);
   CopyBuffer(m_handle_macd, 1, 0, 2, m_buff_MACD_sign);

   double m_macd = m_buff_MACD_main[0];
   double m_sign = m_buff_MACD_sign[0];

   if(m_macd >= 0 && m_sign >= 0)
      trend_by_macd = TREND_BUY;

   if(m_macd <= 0 && m_sign <= 0)
      trend_by_macd = TREND_SEL;

   if(m_buff_MACD_main[0] > m_buff_MACD_sign[0] && m_buff_MACD_main[1] > m_buff_MACD_sign[1] && m_buff_MACD_main[0] > m_buff_MACD_main[1])
      trend_mac_vs_signal = TREND_BUY;

   if(m_buff_MACD_main[0] < m_buff_MACD_sign[0] && m_buff_MACD_main[1] < m_buff_MACD_sign[1] && m_buff_MACD_main[0] < m_buff_MACD_main[1])
      trend_mac_vs_signal = TREND_SEL;

   if(m_macd > 0)
      trend_mac_vs_zero = TREND_BUY;

   if(m_macd < 0)
      trend_mac_vs_zero = TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetAmpAvg(string symbol, double &amp_w1, double &amp_d1, double &amp_h4)
  {
   if(is_same_symbol(symbol, "XAUUSD"))
     {
      amp_w1 = 50;
      amp_d1 = 20;
      amp_h4 = 8;
      return;
     }
   if(is_same_symbol(symbol, "XAGUSD"))
     {
      amp_w1 = 1.3;
      amp_d1 = 0.45;
      amp_h4 = 0.2;
      return;
     }
   if(is_same_symbol(symbol, "USOIL"))
     {
      amp_w1 = 7.182;
      amp_d1 = 1.983;
      amp_h4 = 0.805;
      return;
     }
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      amp_w1 = 3570.59;
      amp_d1 = 1273.25;
      amp_h4 = 789.1;
      return;
     }
   if(is_same_symbol(symbol, "USTEC"))
     {
      amp_w1 = 664.39;
      amp_d1 = 199.95;
      amp_h4 = 81.16;
      return;
     }
   if(is_same_symbol(symbol, "US30"))
     {
      amp_w1 = 1066.8;
      amp_d1 = 308.8;
      amp_h4 = 119.5;
      return;
     }
   if(is_same_symbol(symbol, "US500"))
     {
      amp_w1 = 154.5;
      amp_d1 = 43.3;
      amp_h4 = 16.93;
      return;
     }
   if(is_same_symbol(symbol, "DE30"))
     {
      amp_w1 = 530.6;
      amp_d1 = 156.6;
      amp_h4 = 62.3;
      return;
     }
   if(is_same_symbol(symbol, "UK100"))
     {
      amp_w1 = 208.25;
      amp_d1 = 68.31;
      amp_h4 = 29.0;
      return;
     }
   if(is_same_symbol(symbol, "FR40"))
     {
      amp_w1 = 247.74;
      amp_d1 = 76.95;
      amp_h4 = 30.71;
      return;
     }
   if(is_same_symbol(symbol, "AUS200"))
     {
      amp_w1 = 204.43;
      amp_d1 = 67.52;
      amp_h4 = 29.93;
      return;
     }
   if(is_same_symbol(symbol, "AUDCHF"))
     {
      amp_w1 = 0.01242;
      amp_d1 = 0.0042;
      amp_h4 = 0.00158;
      return;
     }
   if(is_same_symbol(symbol, "AUDNZD"))
     {
      amp_w1 = 0.01293;
      amp_d1 = 0.00481;
      amp_h4 = 0.00178;
      return;
     }
   if(is_same_symbol(symbol, "AUDUSD"))
     {
      amp_w1 = 0.01652;
      amp_d1 = 0.00567;
      amp_h4 = 0.00218;
      return;
     }
   if(is_same_symbol(symbol, "AUDJPY"))
     {
      amp_w1 = 2.285;
      amp_d1 = 0.774;
      amp_h4 = 0.282;
      return;
     }
   if(is_same_symbol(symbol, "CHFJPY"))
     {
      amp_w1 = 2.911;
      amp_d1 = 1.107;
      amp_h4 = 0.458;
      return;
     }
   if(is_same_symbol(symbol, "EURJPY"))
     {
      amp_w1 = 3.166;
      amp_d1 = 1.101;
      amp_h4 = 0.434;
      return;
     }
   if(is_same_symbol(symbol, "GBPJPY"))
     {
      amp_w1 = 3.873;
      amp_d1 = 1.326;
      amp_h4 = 0.53;
      return;
     }
   if(is_same_symbol(symbol, "NZDJPY"))
     {
      amp_w1 = 2.034;
      amp_d1 = 0.704;
      amp_h4 = 0.272;
      return;
     }
   if(is_same_symbol(symbol, "USDJPY"))
     {
      amp_w1 = 3.044;
      amp_d1 = 1.072;
      amp_h4 = 0.427;
      return;
     }
   if(is_same_symbol(symbol, "EURAUD"))
     {
      amp_w1 = 0.02969;
      amp_d1 = 0.01072;
      amp_h4 = 0.00417;
      return;
     }
   if(is_same_symbol(symbol, "EURCAD"))
     {
      amp_w1 = 0.02146;
      amp_d1 = 0.00765;
      amp_h4 = 0.00284;
      return;
     }
   if(is_same_symbol(symbol, "EURCHF"))
     {
      amp_w1 = 0.01309;
      amp_d1 = 0.00429;
      amp_h4 = 0.0018;
      return;
     }
   if(is_same_symbol(symbol, "EURGBP"))
     {
      amp_w1 = 0.01162;
      amp_d1 = 0.00356;
      amp_h4 = 0.00131;
      return;
     }
   if(is_same_symbol(symbol, "EURNZD"))
     {
      amp_w1 = 0.03185;
      amp_d1 = 0.01191;
      amp_h4 = 0.00478;
      return;
     }
   if(is_same_symbol(symbol, "EURUSD"))
     {
      amp_w1 = 0.01858;
      amp_d1 = 0.00624;
      amp_h4 = 0.00239;
      return;
     }
   if(is_same_symbol(symbol, "GBPCHF"))
     {
      amp_w1 = 0.01905;
      amp_d1 = 0.00601;
      amp_h4 = 0.00241;
      return;
     }
   if(is_same_symbol(symbol, "GBPNZD"))
     {
      amp_w1 = 0.03533;
      amp_d1 = 0.01304;
      amp_h4 = 0.00531;
      return;
     }
   if(is_same_symbol(symbol, "GBPUSD"))
     {
      amp_w1 = 0.02454;
      amp_d1 = 0.00811;
      amp_h4 = 0.00317;
      return;
     }
   if(is_same_symbol(symbol, "NZDCAD"))
     {
      amp_w1 = 0.01459;
      amp_d1 = 0.0055;
      amp_h4 = 0.00216;
      return;
     }
   if(is_same_symbol(symbol, "NZDUSD"))
     {
      amp_w1 = 0.0151;
      amp_d1 = 0.00524;
      amp_h4 = 0.0021;
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      amp_w1 = 0.01943;
      amp_d1 = 0.00651;
      amp_h4 = 0.00252;
      return;
     }
   if(is_same_symbol(symbol, "USDCHF"))
     {
      amp_w1 = 0.017;
      amp_d1 = 0.00591;
      amp_h4 = 0.00235;
      return;
     }

   amp_w1 = CalculateAverageCandleHeight(PERIOD_W1, symbol, 15);
   amp_d1 = CalculateAverageCandleHeight(PERIOD_D1, symbol, 30);
   amp_h4 = CalculateAverageCandleHeight(PERIOD_H4, symbol, 60);

   SendAlert(INDI_NAME, "Get Amp Avg", " Get AmpAvg:" + (string)symbol + "   amp_w1: " + (string)amp_w1 + "   amp_d1: " + (string)amp_d1 + "   amp_h4: " + (string)amp_h4);
   return;
  }

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
   amp_w = CalculateAverageCandleHeight(PERIOD_W1, symbol, 50);
   dic_amp_init_h4 = 0.01;

   SendAlert(INDI_NAME, "SymbolData", " Get SymbolData:" + (string)symbol + "   i_top_price: " + (string)i_top_price + "   amp_w: " + (string)amp_w + "   dic_amp_init_h4: " + (string)dic_amp_init_h4);
   return;
  }
//+------------------------------------------------------------------+
