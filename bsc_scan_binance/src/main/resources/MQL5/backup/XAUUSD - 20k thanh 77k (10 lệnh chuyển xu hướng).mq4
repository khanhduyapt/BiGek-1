//+------------------------------------------------------------------+
//|                                                       XAUUSD.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string INDI_NAME = "[XAUUSD]";
double dbRiskRatio = 0.01;    // Rủi ro 1%
double INIT_EQUITY = 10000.0; // Vốn đầu tư

string TREND_BUY = "BUY";
string TREND_SEL = "SELL";
string LOCK = "_Lock.";
string LOCK_SEL = LOCK + "S_";
string LOCK_BUY = LOCK + "B_";
datetime last_check_time = TimeCurrent();
datetime last_trend_shift_time = TimeCurrent();
string str_buy = "";
string str_sel = "";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment(GetComments());
   EventSetTimer(300); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
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
   OnTimer();
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   DeleteAllObjects();

   string TRADER = "(XAU)";
   string str_count = "";


//string trend_by_macd_h1 = "", trend_mac_vs_signal_h1 = "", trend_mac_vs_zero_h1 = "";
//get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_H1, trend_by_macd_h1, trend_mac_vs_signal_h1, trend_mac_vs_zero_h1);

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_M15, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);

//bool not_allow_against_main_trend = false;
//if(trend_by_macd_h4 != "" && trend_by_macd_h4 == trend_by_macd_h1)
//   not_allow_against_main_trend = true; "";//
   string trend_main = trend_mac_vs_signal_h4;
   string trend_reve = get_trend_reverse(trend_main);

   int NUMBER_OF_TRADE = 10;
   string str_count_main = OpenTrade_Only1Side(Symbol(), "(Main)", 1, 3, trend_main, 0.05, true,  NUMBER_OF_TRADE, true);
   string str_count_reve = OpenTrade_Only1Side(Symbol(), "(Reve)", 2, 5, trend_reve, 0.05, false, NUMBER_OF_TRADE, true);

   string str_buy_temp = (trend_main == TREND_BUY) ? str_count_main : str_count_reve;
   string str_sel_temp = (trend_main == TREND_SEL) ? str_count_main : str_count_reve;
   if(str_buy_temp != "")
      str_buy = str_buy_temp;
   if(str_sel_temp != "")
      str_sel = str_sel_temp;

   string comment = GetComments();
   string balance = format_double_to_string(AccountInfoDouble(ACCOUNT_BALANCE), 2);
   string profit  = format_double_to_string(AccountInfoDouble(ACCOUNT_PROFIT), 2);

   Comment(TRADER + comment
           + "    Find: " + trend_mac_vs_signal_h4 + "    balance:" + balance + "    profit:" + profit + "\n"
           + "                                   " + str_buy + "    " + str_sel + "\n"
          );

   create_vertical_line("dkd" + time2string(iTime(Symbol(), PERIOD_D1, 0)), iTime(Symbol(), PERIOD_D1, 0), clrBlack,  STYLE_DASHDOTDOT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OpenTrade_Only1Side(string symbol, string TRADER, double AMP_DCA, double AMP_TP, string trend_init, double init_volume = 0.01,
                           bool not_allow_against_main_trend = false, int NUMBER_OF_TRADE = 15, bool dca_to_die = false)
  {
   int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   int slippage = (int)MathAbs(ask-bid);


   string keys_all = "";
   string tickets_locked = "";
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
            if(is_same_symbol(OrderComment(), TRADER))
              {
               string key = create_ticket_key(OrderTicket());
               keys_all += key;

               if(is_same_symbol(OrderComment(), LOCK))
                  tickets_locked += OrderComment();
              }

//-----------------------------------------------------------------------------
   int count_lock_buy = 0, count_lock_sel = 0;
   double total_vol_lock_buy = 0, total_vol_lock_sel = 0;
   int count_possion_buy = 0, count_possion_sel = 0;
   double total_profit=0, total_profit_buy = 0, total_profit_sel = 0;
   double total_volume_buy = 0, total_volume_sel = 0;
   double max_openprice_buy = 0, min_openprice_sel = 10000000;
   double cur_tp_buy = 0, cur_tp_sel = 0;

   int first_ticket_buy = 0, first_ticket_sel = 0;
   datetime first_open_time_buy = 0, first_open_time_sel = 0;

   double min_entry_buy = 0, min_entry_sel = 0;
   double max_entry_buy = 0, max_entry_sel = 0;

   int last_ticket_buy = 0, last_ticket_sel = 0;
   string last_comment_buy = "", last_comment_sel = "";

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ");
         break;
        }

      if(is_same_symbol(OrderComment(), TRADER) == false)
         continue;

      double cur_profit = OrderProfit() + OrderSwap() + OrderCommission();
      double price_sell_off = OrderType() == OP_BUY ? OrderOpenPrice() + 3 : OrderOpenPrice() - 3;

      if(OrderType() == OP_BUY)
        {
         if(is_same_symbol(OrderComment(), LOCK) == false)
            count_possion_buy += 1;
         else
           {
            count_lock_buy += 1;
            total_vol_lock_buy += OrderLots();
           }

         total_volume_buy += OrderLots();
         total_profit_buy += cur_profit;

         if(min_entry_buy == 0 || min_entry_buy > OrderOpenPrice())
            min_entry_buy = OrderOpenPrice();

         if(max_entry_buy < OrderOpenPrice())
            max_entry_buy = OrderOpenPrice();

         if(last_ticket_buy == 0 || last_ticket_buy < OrderTicket())
           {
            last_ticket_buy = OrderTicket();
            cur_tp_buy = OrderTakeProfit();
            last_comment_buy = OrderComment();
           }

         if(first_ticket_buy == 0 || first_ticket_buy > OrderTicket())
           {
            first_ticket_buy = OrderTicket();
            first_open_time_buy = OrderOpenTime();
           }

         if(max_openprice_buy < OrderOpenPrice())
            max_openprice_buy = OrderOpenPrice();
        }


      if(OrderType() == OP_SELL)
        {
         if(is_same_symbol(OrderComment(), LOCK) == false)
            count_possion_sel += 1;
         else
           {
            count_lock_sel += 1;
            total_vol_lock_sel += OrderLots();
           }

         total_volume_sel += OrderLots();

         total_profit_sel += cur_profit;
         if(min_entry_sel == 0 || min_entry_sel > OrderOpenPrice())
            min_entry_sel = OrderOpenPrice();

         if(max_entry_sel < OrderOpenPrice())
            max_entry_sel = OrderOpenPrice();

         if(last_ticket_sel == 0 || last_ticket_sel < OrderTicket())
           {
            last_ticket_sel = OrderTicket();
            cur_tp_sel = OrderTakeProfit();
            last_comment_sel = OrderComment();
           }

         if(first_ticket_sel == 0 || first_ticket_sel > OrderTicket())
           {
            first_ticket_sel = OrderTicket();
            first_open_time_sel = OrderOpenTime();
           }

         if(min_openprice_sel > OrderOpenPrice())
            min_openprice_sel = OrderOpenPrice();
        }
     }

   string result = "";
   if(trend_init == TREND_BUY)
      result += "    "
                + "    buy:" + (string)count_possion_buy + "    (lock):" + (string)count_lock_buy + "    " + format_double_to_string(total_vol_lock_buy, 2) + " lot "
                + "    " + format_double_to_string(min_entry_buy, digits-2) + " ~ " + format_double_to_string(max_entry_buy, digits-2) + " : " + format_double_to_string(max_entry_buy-min_entry_buy, digits-2)
                + "    vol:" + (string)total_volume_buy
                + "    amp:" + (string)AMP_DCA
                ;

   if(trend_init == TREND_SEL)
      result += "    "
                + "    sel:" + (string)count_possion_sel + "    (lock):" + (string)count_lock_sel + "    " + format_double_to_string(total_vol_lock_sel, 2) + " lot "
                + "    " + format_double_to_string(min_entry_sel, digits-2) + " ~ " + format_double_to_string(max_entry_sel, digits-2) + " : " + format_double_to_string(max_entry_sel-min_entry_sel, digits-2)
                + "    vol:" + (string)total_volume_sel
                + "    amp:" + (string)AMP_DCA
                ;

//-----------------------------------------------------------------------------
   if(count_possion_buy == 0 && trend_init == TREND_BUY)
     {
      int ticket = OrderSend(symbol, OP_BUY, init_volume, ask, 0, 0.0, ask + AMP_TP, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy+1), 0, 0, clrBlack);
      if(ticket > 0)
         Print("BUY order opened.");
     }

   if(count_possion_sel == 0 && trend_init == TREND_SEL)
     {
      int ticket = OrderSend(symbol,OP_SELL, init_volume, bid, 0, 0.0, bid - AMP_TP, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_sel+1), 0, 0, clrBlack);
      if(ticket > 0)
         Print("SEL order opened.");
     }
//-----------------------------------------------------------------------------
   if((trend_init == TREND_BUY || dca_to_die) && count_possion_buy > 0 && (count_possion_buy < NUMBER_OF_TRADE) && (min_entry_buy - AMP_DCA > ask))
     {
      //double AMP_TP = MathMax(AMP_DCA*2, MathAbs(max_entry_buy - min_entry_buy)*0.618);
      double tp_buy = NormalizeDouble(ask + AMP_TP, digits);

      count_possion_buy += 1;
      double  volume = get_value_by_fibo_1618(init_volume, count_possion_buy, 2);

      if(passes_timer_5minus())
        {
         int nextticket = OrderSend(symbol, OP_BUY, volume, ask, slippage, 0.0, tp_buy, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_buy), 0, 0, clrBlack);
         if(nextticket > 0)
            if(count_possion_buy>=5)
               ModifyTp_ExceptLockKey(symbol, TREND_BUY, tp_buy, TRADER);
        }
     }

   if((trend_init == TREND_SEL || dca_to_die) && count_possion_sel > 0 && (count_possion_sel < NUMBER_OF_TRADE) && (max_entry_sel + AMP_DCA < bid))
     {
      //double AMP_TP = MathMax(AMP_DCA*2, MathAbs(max_entry_sel - min_entry_sel)*0.618);
      double tp_sel = NormalizeDouble(bid - AMP_TP, digits);

      count_possion_sel += 1;
      double  volume = get_value_by_fibo_1618(init_volume, count_possion_sel, 2);

      if(passes_timer_5minus())
        {
         int nextticket = OrderSend(symbol,OP_SELL, volume, bid, slippage, 0.0, tp_sel, TRADER + get_trend_nm(TREND_BUY) + "_" + append1Zero(count_possion_sel), 0, 0, clrBlack);
         if(nextticket > 0)
            if(count_possion_sel>=5)
               ModifyTp_ExceptLockKey(symbol, TREND_SEL, tp_sel, TRADER);
        }
     }

   if(not_allow_against_main_trend)
     {
      if(trend_init == TREND_BUY && total_profit_sel != 0)
         trend_shift_by_position(symbol, TREND_BUY, AMP_TP, TRADER);

      if(trend_init == TREND_SEL && total_profit_buy != 0)
         trend_shift_by_position(symbol, TREND_SEL, AMP_TP, TRADER);
     }

   if(count_possion_sel >= NUMBER_OF_TRADE || count_possion_buy >= NUMBER_OF_TRADE)
     {
      if(count_possion_sel >= NUMBER_OF_TRADE)
         trend_shift_by_position(symbol, TREND_BUY, AMP_TP, TRADER);

      if(count_possion_buy >= NUMBER_OF_TRADE)
         trend_shift_by_position(symbol, TREND_SEL, AMP_TP, TRADER);
     }

   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trend_shift_by_position(string symbol, string NEW_TREND, double AMP_TP, string TRADER)
  {
   if(is_allow_trend_shift(symbol, NEW_TREND, AMP_TP))
     {
      //---------------------------------------------------------------------------
      string keys_all = "";
      string tickets_locked = "";
      for(int i = OrdersTotal() - 1; i >= 0; i--)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(is_same_symbol(OrderSymbol(), symbol))
               if(is_same_symbol(OrderComment(), TRADER))
                 {
                  string key = create_ticket_key(OrderTicket());
                  keys_all += key;

                  if(is_same_symbol(OrderComment(), LOCK))
                     tickets_locked += OrderComment();
                 }
      StringReplace(tickets_locked, TREND_BUY, "");
      StringReplace(tickets_locked, TREND_SEL, "");
      StringReplace(tickets_locked, LOCK_BUY, "");
      StringReplace(tickets_locked, LOCK_SEL, "");
      StringReplace(tickets_locked, TRADER, "");

      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(is_same_symbol(OrderSymbol(), symbol))
              {
               if(is_same_symbol(OrderComment(), TRADER) == false)
                  continue;

               string key = create_ticket_key(OrderTicket());
               double cur_profit = OrderProfit() + OrderSwap() + OrderCommission();

               bool has_trend_shift = false;
               if(OrderType() == OP_SELL && is_same_symbol(NEW_TREND, TREND_BUY))
                  if(tickets_locked == "" || is_same_symbol(tickets_locked, key) == false)
                    {
                     has_trend_shift = true;
                     double tp_by_amp = NormalizeDouble(ask + AMP_TP, digits);
                     double tp_buy = tp_by_amp;
                     if(OrderTakeProfit() > 0)
                        tp_buy = NormalizeDouble(ask + MathAbs(OrderTakeProfit() - OrderOpenPrice()), digits);
                     tp_buy = MathMax(tp_buy, tp_by_amp);


                     double volume_calc = OrderLots();
                     double amp_tp_calc = tp_buy - ask;
                     double volume_new, amp_tp_new;
                     adjust_volume_and_amp_tp(symbol, volume_calc, amp_tp_calc, volume_new, amp_tp_new);
                     if(amp_tp_new == 0 || volume_new == 0)
                       {
                        volume_new = volume_calc;
                        amp_tp_new = amp_tp_calc;
                       }

                     int next_ticket = OrderSend(symbol, OP_BUY, volume_new, ask, 0, 0.0, ask + amp_tp_new, LOCK_SEL + TRADER + "(S2B.tf)" + key, 0, 0, clrBlack);
                     if(next_ticket > 0)
                        Print("S2B tranfer order opened.");

                     if(cur_profit < 0)
                       {
                        double volume = NormalizeDouble(calc_volume_by_amp(symbol, AMP_TP, MathAbs(cur_profit)*1), 2);
                        double volume_new2, amp_tp_new2;
                        adjust_volume_and_amp_tp(symbol, volume, AMP_TP, volume_new2, amp_tp_new2);
                        if(volume_new2 == 0 || amp_tp_new2 == 0)
                          {
                           volume_new2 = volume;
                           amp_tp_new2 = AMP_TP;
                          }

                        int next_ticket_2 = OrderSend(symbol, OP_BUY, volume_new2, ask, 0, 0.0, ask + amp_tp_new2, LOCK_SEL + TRADER + "(S2B.pf)" + key, 0, 0, clrBlack);
                        if(next_ticket_2 > 0)
                           Print("BUY profit order opened.");
                       }

                     if(!OrderClose(OrderTicket(),OrderLots(), ask,3,Violet))
                        Print("OrderClose error ",GetLastError());
                    }

               if(OrderType() == OP_BUY && is_same_symbol(NEW_TREND, TREND_SEL))
                  if(tickets_locked == "" || is_same_symbol(tickets_locked, key) == false)
                    {
                     has_trend_shift = true;
                     double tp_by_amp = NormalizeDouble(bid - AMP_TP, digits);
                     double tp_sel = tp_by_amp;
                     if(OrderTakeProfit() > 0)
                        tp_sel = NormalizeDouble(bid - MathAbs(OrderTakeProfit() - OrderOpenPrice()), digits);
                     tp_sel = MathMin(tp_sel, tp_by_amp);

                     double volume_calc = OrderLots();
                     double amp_tp_calc = bid - tp_sel;
                     double volume_new, amp_tp_new;
                     adjust_volume_and_amp_tp(symbol, volume_calc, amp_tp_calc, volume_new, amp_tp_new);
                     if(amp_tp_new == 0 || volume_new == 0)
                       {
                        volume_new = volume_calc;
                        amp_tp_new = amp_tp_calc;
                       }

                     int next_ticket = OrderSend(symbol, OP_SELL, volume_new, bid, 0, 0.0, bid - amp_tp_new, LOCK_BUY + TRADER + "(B2S.tf)" + key, 0, 0, clrBlack);
                     if(next_ticket > 0)
                        Print("B2S tranfer order opened.");

                     if(cur_profit < 0)
                       {
                        double volume = NormalizeDouble(calc_volume_by_amp(symbol, AMP_TP, MathAbs(cur_profit)*1), 2);

                        double volume_new2, amp_tp_new2;
                        adjust_volume_and_amp_tp(symbol, volume, AMP_TP, volume_new2, amp_tp_new2);
                        if(volume_new2 == 0 || amp_tp_new2 == 0)
                          {
                           volume_new2 = volume;
                           amp_tp_new2 = AMP_TP;
                          }

                        int next_ticket_2 = OrderSend(symbol, OP_SELL, volume_new2, bid, 0, 0.0, bid - amp_tp_new2, LOCK_BUY + TRADER + "(B2S.pf)" + key, 0, 0, clrBlack);
                        if(next_ticket_2 > 0)
                           Print("B2S profit order opened.");
                       }

                     if(!OrderClose(OrderTicket(),OrderLots(), bid,3,Violet))
                        Print("OrderClose error ",GetLastError());
                    }

              }
           }
        } //for
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ExceptLockKey(string symbol, string TRADING_TREND, double tp_price, string KEY_TO_CLOSE)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0)
               if(StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0)
                  if(OrderTakeProfit() != tp_price)
                     if(is_same_symbol(OrderComment(), LOCK_BUY) == false && is_same_symbol(OrderComment(), LOCK_SEL) == false)
                       {
                        double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
                        if(OrderType() == OP_BUY)
                           price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);

                        int ross=0, demm = 1;
                        while(ross<=0 && demm<20)
                          {
                           ross=OrderModify(OrderTicket(),price,OrderStopLoss(),tp_price,0,clrBlue);
                           demm++;
                           Sleep(100);
                          }
                       }
        }
     } //for
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifySL(string symbol, string TRADING_TREND, double sl_price, string KEY_TO_CLOSE)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0)
               if(StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0)
                  if(OrderStopLoss() != sl_price)
                     if(is_same_symbol(OrderComment(), LOCK_BUY) == false && is_same_symbol(OrderComment(), LOCK_SEL) == false)
                       {
                        double price = 0.0;
                        if(OrderType() == OP_SELL)
                          {
                           price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
                           if(price >= OrderOpenPrice())
                              price = 0.0;
                          }


                        if(OrderType() == OP_BUY)
                          {
                           price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
                           if(price <= OrderOpenPrice())
                              price = 0.0;
                          }

                        int ross=0, demm = 1;
                        while(ross<=0 && demm<20)
                          {
                           ross=OrderModify(OrderTicket(),price,sl_price,OrderTakeProfit(),0,clrBlue);
                           demm++;
                           Sleep(100);
                          }
                       }
        }
     } //for
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(string symbol, int ordertype, string TRADER)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(OrderType() == ordertype)
               if(TRADER == "" || (StringFind(toLower(OrderComment()), toLower(TRADER)) >= 0))
                 {
                  double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
                  if(OrderType() == OP_BUY)
                     price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);

                  if(!OrderClose(OrderTicket(),OrderLots(),price,10,Violet))
                     Print("OrderClose error ",GetLastError());
                 }
     } //for
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
void get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe, string &trend_by_macd, string &trend_mac_vs_signal, string &trend_mac_vs_zero)
  {
   trend_by_macd = "";
   trend_mac_vs_signal = "";
   trend_mac_vs_zero = "";

   double macd_0=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_MAIN,0);
   double macd_1=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_MAIN,1);
   double sign_0=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_SIGNAL,0);
   double sign_1=iMACD(symbol, timeframe,18,36,12,PRICE_CLOSE,MODE_SIGNAL,1);

   if(macd_0 >= 0 && sign_0 >= 0)
      trend_by_macd = TREND_BUY;

   if(macd_0 <= 0 && sign_0 <= 0)
      trend_by_macd = TREND_SEL;

   if(macd_0 >= sign_0 && macd_1 >= sign_1 && macd_0 >= macd_1)
      trend_mac_vs_signal = TREND_BUY;

   if(macd_0 <= sign_0 && macd_1 <= sign_1 && macd_0 <= macd_1)
      trend_mac_vs_signal = TREND_SEL;

   if(macd_0 >= 0)
      trend_mac_vs_zero = TREND_BUY;

   if(macd_0 <= 0)
      trend_mac_vs_zero = TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trend_shift(string symbol, string NEW_TREND, double AMP_TP)
  {
//   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
//
//   double lowest = 0.0, higest = 0.0;
//   for(int idx = 1; idx <= 55; idx++)
//     {
//      double close = iClose(symbol, PERIOD_H4, idx);
//      if((idx == 0) || (lowest > close))
//         lowest = close;
//      if((idx == 0) || (higest < close))
//         higest = close;
//     }
//
//   if((NEW_TREND == TREND_BUY) && (higest - AMP_TP > price))
//      return true;
//
//   if((NEW_TREND == TREND_SEL) && (lowest + AMP_TP < price))
//      return true;

   if(is_allow_trade_now_by_stoc(symbol, PERIOD_M5, NEW_TREND, 3, 2, 3))
      return true;

// Cần chờ tối thiểu 1 giờ sau mỗi lần chuyển đổi để tránh tạo GAP sụt giảm tài khoản.
//bool pass_time_check = false;
//datetime currentTime = TimeCurrent();
//datetime timeGap = currentTime - last_trend_shift_time;
//if(timeGap >= 1 * 60 * 60)
//   return true;

   return false;
  }


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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool passes_timer_5minus()
  {
   return true;

   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_check_time;
   if(timeGap >= 5 * 60)
     {
      last_check_time = TimeCurrent();
      return true;
     }

   return false;
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
string append1Zero(int trade_no)
  {
   if(trade_no < 10)
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
string time2string(datetime time)
  {
   string today = (string)time;
   StringReplace(today, " ", "");
   StringReplace(today, ":", "");
   StringReplace(today, ".", "");
   StringReplace(today, "000000", "");
   StringReplace(today, "0000", "");

   return today;
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
void adjust_volume_and_amp_tp(string symbol, double volume_calc, double amp_tp_calc, double &volume_new, double &amp_tp_new)
  {
   amp_tp_new = amp_tp_calc;
   volume_new = volume_calc;
//return;

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double amp_w1, amp_d1, amp_h4;
   GetAmpAvg(symbol, amp_w1, amp_d1, amp_h4);
   double risk = calcRisk();
   double volume_standard = dblLotsRisk(symbol, amp_d1, risk);

   if(volume_calc < volume_standard*3)
      return;

// 5 lot(tp:20)
//30 lot(tp:3 ) = 30*(9/3) lot (tp:9)
   amp_tp_new = NormalizeDouble(amp_d1/2, digits);
   volume_new = NormalizeDouble(volume_calc *(amp_tp_new/amp_tp_calc), digits);

   if(volume_new >= volume_standard * 10)
     {
      // 100 lot (tp:10) = 50 lot (pt: 10*(100/(5*10))
      amp_tp_new = amp_tp_new*(volume_new/(volume_standard * 10));
      volume_new = volume_standard * 10;
     }

   return;
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
//+------------------------------------------------------------------+
string format_double_to_string(double number, int digits = 5)
  {

   string numberString = (string) NormalizeDouble(number, digits);
   StringReplace(numberString, "000000000002", "");
   StringReplace(numberString, "000000000001", "");
   StringReplace(numberString, "999999999999", "9");
   StringReplace(numberString, "999999999998", "9");

   int dotIndex = StringFind(numberString, ".");
   if(dotIndex >= 0)
     {
      string beforeDot = StringSubstr(numberString, 0, dotIndex);
      string afterDot = StringSubstr(numberString, dotIndex + 1);
      afterDot = StringSubstr(afterDot, 0, digits); // chỉ lấy digits chữ số đầu tiên sau dấu chấm

      numberString = beforeDot + "." + afterDot;
     }


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
//+------------------------------------------------------------------+
string get_current_timeframe_to_string()
  {
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
string get_vntime()
  {
   string cpu = "";
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Fun_Error(int Error)                        // Function of processing errors
  {
   switch(Error)
     {
      // Not crucial errors
      case  4:
         Alert("Trade server is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 135:
         Alert("Price changed. Trying once again..");
         RefreshRates();                        // Refresh rates
         return(1);                             // Exit the function
      case 136:
         Alert("No prices. Waiting for a new tick..");
         while(RefreshRates()==false)           // Till a new tick
            Sleep(1);                           // Pause in the loop
         return(1);                             // Exit the function
      case 137:
         Alert("Broker is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 146:
         Alert("Trading subsystem is busy. Trying once again..");
         Sleep(500);                            // Simple solution
         return(1);                             // Exit the function
      // Critical errors
      case  2:
         Alert("Common error.");
         return(0);                             // Exit the function
      case  5:
         Alert("Old terminal version.");
         return(0);                             // Exit the function
      case 64:
         Alert("Account blocked.");
         return(0);                             // Exit the function
      case 133:
         Alert("Trading forbidden.");
         return(0);                             // Exit the function
      case 134:
         Alert("Not enough money to execute operation.");
         return(0);                             // Exit the function
      default:
         Alert("Error occurred: ",Error); // Other variants
         return(0);                             // Exit the function
     }
  }
//+------------------------------------------------------------------+

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

//SendAlert(INDI_NAME, "Get Amp Avg", " Get AmpAvg:" + (string)symbol + "   amp_w1: " + (string)amp_w1 + "   amp_d1: " + (string)amp_d1 + "   amp_h4: " + (string)amp_h4);
   return;
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
   if(totalObjects < 100)
      return;

   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
      if(totalObjects < 100 && ObjectType(objectName) == OBJ_TREND)
         continue;

      if(is_same_symbol(objectName, "dkd") == false)
         ObjectDelete(0, objectName); // Xóa đối tượng nếu là đường trendline
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   double amp_w1, amp_d1, amp_h4;
   GetAmpAvg(Symbol(), amp_w1, amp_d1, amp_h4);
   double risk = calcRisk();
   string volume_bt = format_double_to_string(dblLotsRisk(Symbol(), amp_d1, risk), 2);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + INDI_NAME + " " + cur_timeframe + ") " + Symbol();

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);

   str_comments += "    Macd(H4): " + (string) trend_by_macd_h4;

//if(IS_DEBUG_MODE == false)
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

   return str_comments;
  }
//+------------------------------------------------------------------+
