//+------------------------------------------------------------------+
//|                                                    XAUUSD-V2.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
string BOT_SHORT_NM = "(C7)";
string VER = "V240505";
string INDI_NAME = BOT_SHORT_NM + VER;

//-----------------------------------------------------------------------------
#define BtnHedging "BtnHedging"
#define BtnPaddingTrade "BtnPaddingTrade"
#define BtnNewCycleBuy "NewCycleBuy"
#define BtnNewCycleSel "NewCycleSel"
#define BtnCloseProfitBuy "BtnCloseProfitBuy"
#define BtnUpTpBuy "BtnUpTpBuy"
#define BtnDnTpBuy "BtnDnTpBuy"
#define BtnCloseProfitSel "BtnCloseProfitSel"
#define BtnUpTpSel "BtnUpTpSel"
#define BtnDnTpSel "BtnDnTpSel"
#define BtnManualBuy "BtnManualBuy"
#define BtnManualSel "BtnManualSel"
bool IS_CONTINUE_TRADING_CYCLE_BUY = false;
bool IS_CONTINUE_TRADING_CYCLE_SEL = false;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
int    NUMBER_PE_TRADE   = 5;        // Biên độ quá 5 lệnh thì bắt đầu cầu hòa.
int    NUMBER_OF_TRADE   = 15;       // Đánh 10 lệnh, 3000 USC, để từ đầu đến cuối thì không cháy.
double INIT_EQUITY       = 2000.0;   // Vốn đầu tư
double FUNDS_PER_TRADER  = 2000.0;   // Vốn đầu tư cho mỗi trader để đánh 15 lệnh.
double INIT_VOLUME       = 0.01;     // Lot
//-----------------------------------------------------------------------------
double AMP_DC_BUY        = 0;
double AMP_TP_BUY        = 0;
double AMP_DC_SEL        = 0;
double AMP_TP_SEL        = 0;
double amp_d7            = 0;
double avg_candle_w1     = 0;
double LOWEST_OF_7_DAYS  = 0;
double CENTER_OF_3_DAYS  = 0;
double HIGEST_OF_7_DAYS  = 0;
//-----------------------------------------------------------------------------
double store = 0.0;
bool   DEBUG_MODE = true;
string TREND_BUY = "BUY";
string TREND_SEL = "SELL";
string MASK_HEDG = "(HG)";
string MASK_ROOT = "(RO)";
string MASK_EXIT = "(EX)";
string MASK_TREND_TRANSFER = "(T.F)";
string LOCK = "(Lock)";
datetime global_last_open_time = 0;
datetime last_trend_shift_time = TimeCurrent();
string str_buy = "";
string str_sel = "";
double max_amp = 0;
string max_amp_day = "";
double max_vol = 0;
double cur_vol = 0;
int max_count = 0;
int max_lenh_calc = 0;
double max_drawdown = 0;
string max_draw_day = "";
double global_vol_buy = 0, global_vol_sel = 0;
double global_max_vol_buy = 0;
double global_max_vol_sel = 0;
double global_max_count_buy = 0;
double global_max_count_sel = 0;
int global_count_hedging = 0;
double MAXIMUM_DOUBLE = 999999999;
double global_min_exit_price = MAXIMUM_DOUBLE, global_max_exit_price = 0;
int global_count_exit_order = 0;
int global_count_buy = 0;
int global_count_sel = 0;
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
datetime ALERT_MSG_TIME = 0;
string telegram_url="https://api.telegram.org";
datetime TIME_OF_ONE_H4_CANDLE = 14400;
string lable_profit_buy = "", lable_profit_sel = "", lableBtnPaddingTrade = "";
int DEFAULT_WAITING_DCA_IN_MINUS = 30;
int MINUTES_BETWEEN_ORDER = 10;
string arr_largest_negative_trader_name[100];
double arr_largest_negative_trader_amount[100];
bool enableBtnManualBuy = false, enableBtnManualSel = false;
string INIT_TREND_TODAY = "";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   init_amp_dca(Symbol());

//WriteAvgAmpToFile();
   Comment(GetComments());
   Draw_Buttons();

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
   string symbol = Symbol();
   OpenTrade(symbol);
   Draw_Buttons();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade(string symbol)
  {
   if(is_same_symbol(symbol, "XAUUSD") == false)
      return;

   string today = time2string(iTime(symbol, PERIOD_W1, 0));
   string profit  = format_double_to_string(AccountInfoDouble(ACCOUNT_PROFIT), 2);

   init_amp_dca(symbol);
   ProtectAccount(symbol);
   do_padding_trade(symbol, false);
//-----------------------------------------------------------------------------
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double EQUITY  = AccountInfoDouble(ACCOUNT_EQUITY);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4,  trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);
   INIT_TREND_TODAY = trend_mac_vs_zero_h4;

   auto_join_market(symbol);

   string str_result = "";

   if(IsTesting())
     {
      IS_CONTINUE_TRADING_CYCLE_BUY = true;
      IS_CONTINUE_TRADING_CYCLE_SEL = true;

      //if(INIT_TREND_TODAY == TREND_SEL)
      //   IS_CONTINUE_TRADING_CYCLE_BUY = false;
      //if(INIT_TREND_TODAY == TREND_BUY)
      //   IS_CONTINUE_TRADING_CYCLE_SEL = false;
      //if((INIT_TREND_TODAY == TREND_SEL && global_count_buy > 0) ||
      //   (INIT_TREND_TODAY == TREND_BUY && global_count_sel > 0))
      //   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H4, INIT_TREND_TODAY, 3, 2, 3))
      //      trend_shift_by_position(symbol, INIT_TREND_TODAY);
     }

     {
      string trader_name = create_trader_name();

      if(IS_CONTINUE_TRADING_CYCLE_BUY)
         str_result = OpenTrade_ByFibonacci(symbol, trader_name, TREND_BUY);

      if(IS_CONTINUE_TRADING_CYCLE_SEL)
         str_result = OpenTrade_ByFibonacci(symbol, trader_name, TREND_SEL);

      if(IS_CONTINUE_TRADING_CYCLE_BUY == false && IS_CONTINUE_TRADING_CYCLE_SEL == false)
         str_result = OpenTrade_ByFibonacci(symbol, trader_name, "");
     }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
   string comment = GetComments();
   if(ACC_PROFIT < max_drawdown)
     {
      max_drawdown = ACC_PROFIT;
      max_draw_day = time2string(iTime(symbol, PERIOD_D1, 0));
     }

   Comment(BOT_SHORT_NM + comment + "\n\n"
           + "TotalVol: " + format_double_to_string(cur_vol, 2)
           + "    Balance:" + format_double_to_string(BALANCE, 2) + " (x" + format_double_to_string((BALANCE/INIT_EQUITY), 1)+ ")"
           + "    Profit:" + profit
           + "    MaxDD: "  + format_double_to_string(max_drawdown, 2) + "$" + " (" + format_double_to_string(100*(max_drawdown/INIT_EQUITY), 2)+ "%) "  + max_draw_day
           + "    MaxAmp: " + format_double_to_string(max_amp, 2) + " ("+ max_amp_day+ ")"
           + "    L: " + (string) max_count + "    Lcalc: " + (string) max_lenh_calc + "\n\n"
           + str_result
          );

     {
      ObjectDelete(0, "D_RANGE_UP");
      ObjectDelete(0, "D_RANGE_DN");

      double global_amp_d1_allow_new_buy = true;
      double global_amp_d1_allow_new_sel = true;
      double price_open_c1 = iOpen(symbol, PERIOD_D1, 1);
      double price_close_c1 = iClose(symbol, PERIOD_D1, 1);

      double up = MathMax(price_open_c1, price_close_c1) + amp_d1;
      double dn = MathMin(price_open_c1, price_close_c1) - amp_d1;
      double mi = NormalizeDouble((up+dn)/2, Digits);
      datetime draw_time = iTime(symbol, PERIOD_D1, 0) - TIME_OF_ONE_H4_CANDLE;
      create_trend_line("D_RANGE_UP", draw_time, up, TimeCurrent(), up, clrFireBrick,  STYLE_DOT, 2);
      create_trend_line("D_RANGE_MI", draw_time, mi, TimeCurrent(), mi, clrBlack,      STYLE_DOT, 2);
      create_trend_line("D_RANGE_DN", draw_time, dn, TimeCurrent(), dn, clrBlueViolet, STYLE_DOT, 2);
      create_trend_line("CENTER_OF_3_DAYS", draw_time, CENTER_OF_3_DAYS, TimeCurrent(), CENTER_OF_3_DAYS, clrBlack, STYLE_DASHDOTDOT, 2, true, true);
     }

   string ver_name = "w." + time2string(iTime(symbol, PERIOD_W1, 0));
   if(ObjectFind(0, ver_name) < 0)
      create_vertical_line(ver_name, iTime(symbol, PERIOD_W1, 0), clrRed,  STYLE_DASHDOTDOT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OpenTrade_ByFibonacci(string symbol, string TRADER, string trend_init, bool trade_now = false)
  {
   if(is_same_symbol(symbol, Symbol()) == false)
      return "";

   int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   int slippage = (int)MathAbs(ask-bid);

   double temp_cur_vol = 0;
   string keys_all = "";
   string tickets_locked = "";

   global_count_buy = 0;
   global_count_sel = 0;
   global_count_hedging = 0;
   global_count_exit_order = 0;
   double global_profit_buy = 0, global_profit_sel = 0;
   double old_takeprofit_buy = 0, old_takeprofit_sel = 0;
   double potential_profit_buy = 0, potential_profit_sel = 0;
   string key_cur_group_buy = "", key_cur_group_sel = "";
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            string comment = OrderComment();

            if(global_last_open_time < OrderOpenTime())
               global_last_open_time = OrderOpenTime();

            if(is_same_symbol(comment, MASK_HEDG))
               global_count_hedging += 1;

            if(is_same_symbol(comment, MASK_EXIT))
              {
               global_count_exit_order += 1;
               if(global_min_exit_price > OrderOpenPrice())
                  global_min_exit_price = OrderOpenPrice();
               if(global_max_exit_price < OrderOpenPrice())
                  global_max_exit_price = OrderOpenPrice();
              }

            temp_cur_vol += OrderLots();
            double cur_profit = OrderProfit() + OrderSwap() + OrderCommission();
            double profit = 0;
            if(OrderType() == OP_BUY)
              {
               global_count_buy += 1;
               old_takeprofit_buy = OrderTakeProfit();
               global_vol_buy += OrderLots();
               global_profit_buy += cur_profit;
               potential_profit_buy += determinePotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), OrderTakeProfit(), OrderLots());
              }
            if(OrderType() == OP_SELL)
              {
               global_count_sel += 1;
               old_takeprofit_sel = OrderTakeProfit();
               global_vol_sel += OrderLots();
               global_profit_sel += cur_profit;
               potential_profit_sel += determinePotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), OrderTakeProfit(), OrderLots());
              }

            if(is_same_symbol(OrderComment(), TRADER))
              {
               string key = create_ticket_key(OrderTicket());
               keys_all += key;

               if(is_same_symbol(OrderComment(), LOCK))
                  tickets_locked += OrderComment();

               if(is_same_symbol(comment, TREND_BUY) && (is_same_symbol(comment, MASK_ROOT) || is_same_symbol(comment, "_01")))
                  key_cur_group_buy = key;

               if(is_same_symbol(comment, TREND_SEL) && (is_same_symbol(comment, MASK_ROOT) || is_same_symbol(comment, "_01")))
                  key_cur_group_sel = key;
              }
           }

   double risk = calcRisk();
   double draw_price = iClose(symbol, PERIOD_H4, 1);
   datetime draw_time = TimeCurrent(); // iTime(symbol, PERIOD_H4, 0) + TIME_OF_ONE_H4_CANDLE; //TimeCurrent()
//-----------------------------------------------------------------------------
   double max_volume = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   bool vol_allow_new_buy = true;
   bool vol_allow_new_sel = true;
   if(global_vol_buy > max_volume/5)
      vol_allow_new_buy = false;
   if(global_vol_sel > max_volume/5)
      vol_allow_new_sel = false;
   if(temp_cur_vol > 0)
      cur_vol = temp_cur_vol;

   double global_amp_d1_allow_new_buy = true;
   double global_amp_d1_allow_new_sel = true;
   double price_open_c1 = iOpen(symbol, PERIOD_D1, 1);
   double price_close_c1 = iClose(symbol, PERIOD_D1, 1);
   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

   if(ask > MathMax(price_open_c1, price_close_c1) + amp_d1)
     {
      global_amp_d1_allow_new_buy = false;

      if(IS_CONTINUE_TRADING_CYCLE_BUY)
        {
         IS_CONTINUE_TRADING_CYCLE_BUY = false;
         //SendAlert(symbol, "AUTO_JOIN_BUY", "global_amp_d1_allow_new_buy : False");
        }
     }

   if(bid < MathMin(price_open_c1, price_close_c1) - amp_d1)
     {
      global_amp_d1_allow_new_sel = false;

      if(IS_CONTINUE_TRADING_CYCLE_SEL)
        {
         IS_CONTINUE_TRADING_CYCLE_SEL = false;
         //SendAlert(symbol, "AUTO_JOIN_SEL", "global_amp_d1_allow_new_sel : False");
        }
     }
//-----------------------------------------------------------------------------
   int count_lock_buy = 0, count_lock_sel = 0;
   double total_vol_lock_buy = 0.00, total_vol_lock_sel = 0.00;
   int count_possion_buy = 0, count_possion_sel = 0;
   double total_profit=0.00, total_profit_buy = 0.00, total_profit_sel = 0.00;
   double total_volume_buy = 0, total_volume_sel = 0;
   double max_openprice_buy = 0, min_openprice_sel = 10000000;
   double cur_tp_buy = 0, cur_tp_sel = 0;

   int first_ticket_buy = 0, first_ticket_sel = 0;
   datetime first_open_time_buy = 0, first_open_time_sel = 0;
   datetime last_open_time_buy = 0, last_open_time_sel = 0;

   double min_entry_buy = 0, min_entry_sel = 0;
   double max_entry_buy = 0, max_entry_sel = 0;

   int last_ticket_buy = 0, last_ticket_sel = 0;
   string last_comment_buy = "", last_comment_sel = "";

   int global_possion_buy = 0, global_possion_sel = 0;

   bool has_hedging_buy = false, has_hedging_sel = false;
   double total_vol_hedging_buy = 0, total_vol_hedging_sel = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ");
         break;
        }

      if(OrderType() == OP_BUY)
         global_possion_buy += 1;
      if(OrderType() == OP_SELL)
         global_possion_sel += 1;

      if(is_same_symbol(OrderComment(), TRADER) == false)
         continue;

      double cur_profit = OrderProfit() + OrderSwap() + OrderCommission();
      double price_sell_off = OrderType() == OP_BUY ? OrderOpenPrice() + 3 : OrderOpenPrice() - 3;

      if(OrderType() == OP_BUY)
        {
         if(is_same_symbol(OrderComment(), MASK_HEDG) == true)
           {
            has_hedging_buy = true;
            total_vol_hedging_buy += OrderLots();
           }

         if(is_same_symbol(OrderComment(), LOCK) == false)
            count_possion_buy += 1;
         else
           {
            count_lock_buy += 1;
            total_vol_lock_buy += OrderLots();
           }

         if(last_open_time_buy < OrderOpenTime())
            last_open_time_buy = OrderOpenTime();

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
         if(is_same_symbol(OrderComment(), MASK_HEDG) == true)
           {
            has_hedging_sel = true;
            total_vol_hedging_sel += OrderLots();
           }

         if(is_same_symbol(OrderComment(), LOCK) == false)
            count_possion_sel += 1;
         else
           {
            count_lock_sel += 1;
            total_vol_lock_sel += OrderLots();
           }

         if(last_open_time_sel < OrderOpenTime())
            last_open_time_sel = OrderOpenTime();

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

   if(max_amp < max_entry_buy - min_entry_buy)
     {
      max_amp = max_entry_buy - min_entry_buy;
      max_amp_day = time2string(iTime(symbol, PERIOD_D1, 0));
     }
   if(max_amp < max_entry_sel - min_entry_sel)
     {
      max_amp = max_entry_sel - min_entry_sel;
      max_amp_day = time2string(iTime(symbol, PERIOD_D1, 0));
     }

   if(max_vol < total_volume_buy)
      max_vol = total_volume_buy;
   if(max_vol < total_volume_sel)
      max_vol = total_volume_sel;

   if(max_count < count_possion_buy)
      max_count = count_possion_buy;
   if(max_count < count_possion_sel)
      max_count = count_possion_sel;
//-----------------------------------------------------------------------------
   init_amp_dca(symbol);
   int temp_count_buy = (int)MathMax(count_possion_buy, MathAbs(max_entry_buy - min_entry_buy)/AMP_DC_BUY) + 1;
   int temp_count_sel = (int)MathMax(count_possion_sel, MathAbs(max_entry_sel - min_entry_sel)/AMP_DC_SEL) + 1;
//-----------------------------------------------------------------------------
   lable_profit_buy = "";
   double est_profit_buy = get_estimate_profit(AMP_DC_BUY, get_L(TRADER, TREND_BUY, last_comment_buy));
   if(global_count_buy > 0)
     {
      lable_profit_buy = BOT_SHORT_NM + "(Buy." + (string) global_count_buy + ") " + AppendSpaces(format_double_to_string(global_profit_buy, 1) + "$", 8, false)
                         + " Est: " + format_double_to_string(potential_profit_buy, 1) + "$";

      if(potential_profit_buy < est_profit_buy)
         ModifyTp_ForPotentialProfit(symbol, OP_BUY, AMP_TP_BUY, TRADER, 0.0);
     }

   lable_profit_sel = "";
   double est_profit_sel = get_estimate_profit(AMP_DC_SEL, get_L(TRADER, TREND_SEL, last_comment_sel));
   if(global_count_sel > 0)
     {
      lable_profit_sel = BOT_SHORT_NM + "(Sell." + (string) global_count_sel + ") " + AppendSpaces(format_double_to_string(global_profit_sel, 1) + "$", 8, false)
                         + " Est: " + format_double_to_string(potential_profit_sel, 1) + "$";

      if(potential_profit_sel < est_profit_sel)
         ModifyTp_ForPotentialProfit(symbol, OP_SELL, AMP_TP_SEL, TRADER, 0.0);
     }
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
   string result = "";
   ObjectDelete(0, "next_dca_buy");
   if(MathAbs(total_profit_buy) > 0)
     {
      //set_largest_negative(TRADER, total_profit_buy);

      result +=  AppendSpaces(TRADER, 8)
                 + " Buy: " + Append(count_possion_buy, 2) + "(" + (string)(temp_count_buy-1) + ")" + AppendSpaces(format_double_to_string(total_volume_buy, 2), 6, false) + " lot "
                 + "    " + format_double_to_string(min_entry_buy, digits-2) + " ~ " + format_double_to_string(max_entry_buy, digits-2) + " : " + AppendSpaces(format_double_to_string(max_entry_buy-min_entry_buy, digits-2), 5, false)
                 + "    trend_init: " + trend_init //+ "    macd: " + trend_mac_vs_zero_h4
                 + "    " + last_comment_buy
                 //+ "    " + (string)get_largest_negative(TRADER)
                 + "   Est: " + format_double_to_string(est_profit_buy, 2)
                 + ((total_vol_hedging_buy > 0) ? "    hedging: " + format_double_to_string(total_vol_hedging_buy, 2) + " lot" : "")
                 + "\n";

      create_lable("next_dca_buy", TimeCurrent(), min_entry_buy - AMP_DC_BUY,
                   "____B" + str_remaining_time(last_open_time_buy, temp_count_buy)+ "  " + format_double_to_string(min_entry_buy - AMP_DC_BUY, digits)
                   + "  No." + (string)(count_possion_buy+1)
                   + " (" + format_double_to_string(get_value_by_fibo_1618(INIT_VOLUME, count_possion_buy+1, 2), 2) + ")"
                  );
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectDelete(0, "next_dca_sel");
   if(MathAbs(total_profit_sel) > 0)
     {
      //set_largest_negative(TRADER, total_profit_sel);

      result += AppendSpaces(TRADER, 8)
                + " Sell:  " + Append(count_possion_sel, 2) + "(" + (string)(temp_count_sel-1) + ")" + AppendSpaces(format_double_to_string(total_volume_sel, 2), 6, false) + " lot "
                + "    " + format_double_to_string(min_entry_sel, digits-2) + " ~ " + format_double_to_string(max_entry_sel, digits-2) + " : " + AppendSpaces(format_double_to_string(max_entry_sel-min_entry_sel, digits-2), 5, false)
                + "    trend_init: " + trend_init //+ "    macd: " + trend_mac_vs_zero_h4
                + "    " + last_comment_sel
                //+ "    " + (string)get_largest_negative(TRADER)
                + "   Est: " + format_double_to_string(est_profit_sel, 2)
                + ((total_vol_hedging_buy > 0) ? "    hedging: " + format_double_to_string(total_vol_hedging_buy, 2) + " lot" : "")
                + "\n";

      create_lable("next_dca_sel", TimeCurrent(), min_entry_buy + AMP_DC_SEL,
                   "____S" + str_remaining_time(last_open_time_sel, temp_count_sel) + "  "  + format_double_to_string(min_entry_buy + AMP_DC_SEL, digits)
                   + "  No." + (string)(count_possion_sel+1)
                   + " (" + format_double_to_string(get_value_by_fibo_1618(INIT_VOLUME, count_possion_sel+1, 2), 2) + ")"
                  );
     }
//-----------------------------------------------------------------------------
   enableBtnManualBuy = false;
   if(global_amp_d1_allow_new_buy)
      if(count_possion_buy == 0 || (min_entry_buy - AMP_DC_BUY > ask))
         enableBtnManualBuy = true;

   enableBtnManualSel = false;
   if(global_amp_d1_allow_new_sel)
      if(count_possion_sel == 0 || (max_entry_sel + AMP_DC_SEL < bid))
         enableBtnManualSel = true;
//-----------------------------------------------------------------------------
   bool continue_trading = false;
   if(IS_CONTINUE_TRADING_CYCLE_SEL || IS_CONTINUE_TRADING_CYCLE_BUY || trade_now)
      continue_trading = true;
   if(continue_trading == false)
      return result;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
   if(global_count_hedging == 0 || trade_now)
     {
      if(IS_CONTINUE_TRADING_CYCLE_BUY || trade_now)
         if(vol_allow_new_buy && global_amp_d1_allow_new_buy && count_possion_buy == 0 && trend_init == TREND_BUY)
            if(passes_time_between_trader() || trade_now)
              {
               int ticket = OrderSend(symbol, OP_BUY, INIT_VOLUME, ask, 0, 0.0, ask + AMP_TP_BUY, MASK_ROOT + create_comment(TRADER, TREND_BUY, count_possion_buy+1), 0, 0, clrBlue);
               if(ticket > 0)
                  Print("BUY order opened.");
              }

      if(IS_CONTINUE_TRADING_CYCLE_SEL || trade_now)
         if(vol_allow_new_sel && global_amp_d1_allow_new_sel && count_possion_sel == 0 && trend_init == TREND_SEL)
            if(passes_time_between_trader() || trade_now)
              {
               int ticket = OrderSend(symbol,OP_SELL, INIT_VOLUME, bid, 0, 0.0, bid - AMP_TP_SEL, MASK_ROOT + create_comment(TRADER, TREND_SEL, count_possion_sel+1), 0, 0, clrRed);
               if(ticket > 0)
                  Print("SEL order opened.");
              }
      //-----------------------------------------------------------------------------
      //-----------------------------------------------------------------------------
      //-----------------------------------------------------------------------------
      if((count_possion_buy > 0) && (count_possion_buy < NUMBER_PE_TRADE) && (min_entry_buy - AMP_DC_BUY > ask))
        {
         double tp_buy = NormalizeDouble(ask + AMP_TP_BUY, digits);
         if(count_possion_buy < temp_count_buy && temp_count_buy < NUMBER_OF_TRADE)
           {
            count_possion_buy = temp_count_buy;
            double volume = get_value_by_fibo_1618(INIT_VOLUME, count_possion_buy, 2);

            if(max_lenh_calc < count_possion_buy)
               max_lenh_calc = count_possion_buy;

            if(passes_waiting_time_dca(last_open_time_buy, count_possion_buy) || trade_now)
              {
               int nextticket = OrderSend(symbol, OP_BUY, volume, ask, slippage, 0.0, tp_buy, key_cur_group_buy + create_comment(TRADER, TREND_BUY, count_possion_buy), 0, 0, clrBlue);
               if(nextticket > 0)
                  if(count_possion_buy >= NUMBER_OF_TRADE/3)
                     ModifyTp_ExceptLockKey(symbol, TREND_BUY, tp_buy, TRADER);
              }
           }
        }


      if((NUMBER_PE_TRADE <= temp_count_buy) && (temp_count_buy <= NUMBER_OF_TRADE) && (min_entry_buy - AMP_DC_BUY > ask))
         if((temp_count_buy < NUMBER_PE_TRADE) || is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_BUY, 3, 2, 3))
           {
            count_possion_buy = temp_count_buy;
            double volume = get_value_by_fibo_1618(INIT_VOLUME, count_possion_buy, 2);

            if(passes_waiting_time_dca(last_open_time_buy, count_possion_buy))
              {
               int nextticket = OrderSend(symbol, OP_BUY, volume, ask, slippage, 0.0, 0.0, key_cur_group_buy + create_comment(TRADER, TREND_BUY, count_possion_buy), 0, 0, clrBlue);
               if(nextticket > 0)
                  Print("BUY order opened.");
              }
           }

      if(temp_count_buy >= NUMBER_PE_TRADE && total_profit_buy > 0)
        {
         ClosePosition(symbol, OP_BUY, TRADER);
        }

      if((has_hedging_buy || temp_count_buy >= NUMBER_OF_TRADE) && (AccountInfoDouble(ACCOUNT_PROFIT) > 0))
        {
         // (HEDGING_FOR_BUY) (1) Dong lenh BUY truoc (2) Sau do moi dong lenh HEDGING.
         ClosePosition(symbol, OP_BUY, "");
         ClosePosition(symbol, OP_SELL, "");
        }
      //-----------------------------------------------------------------------------
      //-----------------------------------------------------------------------------
      //-----------------------------------------------------------------------------
      if((count_possion_sel > 0) && (count_possion_sel < NUMBER_PE_TRADE) && (max_entry_sel + AMP_DC_SEL < bid))
        {
         double tp_sel = NormalizeDouble(bid - AMP_TP_SEL, digits);
         if(count_possion_sel < temp_count_sel && temp_count_sel < NUMBER_OF_TRADE)
           {
            count_possion_sel = temp_count_sel;
            double volume = get_value_by_fibo_1618(INIT_VOLUME, count_possion_sel, 2);

            if(max_lenh_calc < count_possion_sel)
               max_lenh_calc = count_possion_sel;

            if(passes_waiting_time_dca(last_open_time_sel, count_possion_sel) || trade_now)
              {
               int nextticket = OrderSend(symbol,OP_SELL, volume, bid, slippage, 0.0, tp_sel, key_cur_group_sel + create_comment(TRADER, TREND_SEL, count_possion_sel), 0, 0, clrBlack);
               if(nextticket > 0)
                  if(count_possion_sel >= NUMBER_OF_TRADE/3)
                     ModifyTp_ExceptLockKey(symbol, TREND_SEL, tp_sel, TRADER);
              }
           }
        }

      if((NUMBER_PE_TRADE <= temp_count_sel) && (temp_count_sel <= NUMBER_OF_TRADE)  && (max_entry_sel + AMP_DC_SEL < bid))
         if((temp_count_sel < NUMBER_PE_TRADE) || is_allow_trade_now_by_stoc(symbol, PERIOD_H4, TREND_SEL, 3, 2, 3))
           {
            count_possion_sel = temp_count_sel;
            double volume = get_value_by_fibo_1618(INIT_VOLUME, count_possion_sel, 2);

            if(passes_waiting_time_dca(last_open_time_sel, count_possion_sel))
              {
               int nextticket = OrderSend(symbol,OP_SELL, volume, bid, slippage, 0.0, 0.0, key_cur_group_sel + create_comment(TRADER, TREND_SEL, count_possion_sel), 0, 0, clrBlack);
               if(nextticket > 0)
                  Print("SEL order opened.");
              }
           }

      if(temp_count_sel >= NUMBER_PE_TRADE && total_profit_sel > 0)
        {
         ClosePosition(symbol, OP_SELL, TRADER);
        }

      if((has_hedging_buy || temp_count_sel >= NUMBER_OF_TRADE) && (AccountInfoDouble(ACCOUNT_PROFIT) > 0))
        {
         // (HEDGING_FOR_SEL) (1) Dong lenh SEL truoc (2) Sau do moi dong lenh HEDGING.
         ClosePosition(symbol, OP_SELL, "");
         ClosePosition(symbol, OP_BUY, "");
        }
     }

   return result;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProtectAccount(string symbol)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   if(ACC_PROFIT > calcRisk())
      if((global_count_hedging > 0) || (global_count_exit_order > 0) || global_count_buy > 5 || global_count_sel > 5)
        {
         ClosePosition(symbol, OP_BUY, "");
         ClosePosition(symbol, OP_SELL, "");
        }

   create_lable_simple("ProtectAccount", "ProtectAccount: OK", CENTER_OF_3_DAYS + AMP_DC_BUY/10, clrBlue);

   bool allow_hedging = (ACC_PROFIT + BALANCE*0.2 < 0);
   if(!allow_hedging)
      return;

   create_lable_simple("ProtectAccount", "(HEDGING) ProtectAccount", CENTER_OF_3_DAYS + AMP_DC_BUY/10, clrRed);
   do_hedging(symbol, 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void do_padding_trade(string symbol, bool trade_now)
  {
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   if(ACC_PROFIT == 0)
      return;

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   string trend_by_ma10_m5 = get_trend_by_ma(symbol, PERIOD_M5, 10, 1);
   bool allow_append_buy = (trend_by_ma10_m5 == TREND_BUY) && (ask < CENTER_OF_3_DAYS - AMP_TP_BUY);
   bool allow_append_sel = (trend_by_ma10_m5 == TREND_BUY) && (bid > CENTER_OF_3_DAYS + AMP_TP_SEL);


   string TREND = (ask+bid)/2 < CENTER_OF_3_DAYS ? TREND_BUY : TREND_SEL;
   double draw_price = iClose(symbol, PERIOD_M5, 1);
   double tp_price = TREND == TREND_BUY ? ask + AMP_TP_BUY : bid - AMP_TP_SEL;
   create_lable("tp_padding_trade", TimeCurrent(), tp_price, " ------------- tp ------------- ", TREND, false);

   double vol_balance = calc_volume_by_amp(symbol, TREND == TREND_BUY ? AMP_TP_BUY : AMP_TP_SEL, MathAbs(ACC_PROFIT));
   lableBtnPaddingTrade = TREND + " " + format_double_to_string(vol_balance, 2) + " SOLVE " + format_double_to_string(ACC_PROFIT, 1) + "$";
   create_lable(BtnPaddingTrade, TimeCurrent(), draw_price, lableBtnPaddingTrade, "", false);
   ObjectSetInteger(0,BtnPaddingTrade, OBJPROP_BACK, false);

   if(allow_append_buy || allow_append_sel)
     {
      bool allow_notify_padding_trade = (global_count_exit_order == 0) ||
                                        (TREND == TREND_BUY && global_min_exit_price - AMP_TP_BUY > bid) ||
                                        (TREND == TREND_SEL && global_max_exit_price + AMP_TP_SEL < ask);

      if(allow_notify_padding_trade)
        {
         color clrText = allow_append_buy ? clrBlue : allow_append_sel ? clrRed : clrBlack;

         ObjectSetInteger(0,BtnPaddingTrade, OBJPROP_FONTSIZE, 9);
         ObjectSetString(0,BtnPaddingTrade, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0,BtnPaddingTrade, OBJPROP_COLOR, clrText);

         ObjectSetInteger(0,"tp_padding_trade", OBJPROP_FONTSIZE, 9);
         ObjectSetString(0,"tp_padding_trade", OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0,"tp_padding_trade", OBJPROP_COLOR, clrText);

         SendAlert(symbol, "PADDING_TRADE", "Allow : " + lableBtnPaddingTrade);
        }
     }


   if(trade_now)
     {
      int OP_TYPE = (TREND == TREND_BUY) ? OP_BUY : (TREND == TREND_SEL) ? OP_SELL : -1;
      if(OP_TYPE != -1)
        {
         string comment = MASK_EXIT + create_comment(create_trader_name(), TREND, global_count_exit_order+1);

         bool exit_ok = Open_Position(symbol, OP_TYPE, vol_balance, 0.0, tp_price, comment);
         if(exit_ok)
           {
            Alert("(MASK_EXIT)" + symbol + " " + comment);
            //   SendTelegramMessage(symbol, "MASK_EXIT", "(MASK_EXIT)" + symbol + " " + comment);
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void do_hedging(string symbol, int OP_1HEDGING_2REFRESH)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   double total_vol_buy = 0, total_vol_sel = 0;
   global_count_hedging = 0;
   double min_exit_price = MAXIMUM_DOUBLE, max_exit_price = 0;

   string all_keys_normal = "", all_keys_hedg = "";
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            string key = create_ticket_key(OrderTicket());

            if(is_same_symbol(OrderComment(), MASK_HEDG))
              {
               global_count_hedging += 1;
               all_keys_hedg += key;

               string key_val = get_group_value(OrderComment(), "[K", "]");
               all_keys_hedg += key_val;
              }
            else
               all_keys_normal += key;
           }


   if(global_count_hedging > 0 && ACC_PROFIT > calcRisk())
     {
      ClosePosition(symbol, OP_BUY, "");
      ClosePosition(symbol, OP_SELL, "");
     }


   bool send_telegram_hedging_ok = false;
   global_count_hedging = 0;
   global_count_exit_order = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            string key = create_ticket_key(OrderTicket());

            if(is_same_symbol(OrderComment(), MASK_HEDG))
              {
               if(OP_1HEDGING_2REFRESH == 1 || OP_1HEDGING_2REFRESH == 2)
                 {
                  string key_val = get_group_value(OrderComment(), "[K", "]");
                  if(is_same_symbol(all_keys_normal, key_val)==false)
                    {
                     double candle_m5 = CalculateAverageCandleHeight(PERIOD_M5, symbol, 20);
                     double price_sell_off = OrderType() == OP_BUY ? OrderOpenPrice() + candle_m5 : OrderOpenPrice() - candle_m5;

                     int ross=0, demm = 1;
                     while(ross<=0 && demm<20)
                       {
                        double price = OrderType() == OP_BUY ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);
                        ross=OrderModify(OrderTicket(),price,OrderStopLoss(),price_sell_off,0,clrBlue);
                        demm++;
                        Sleep(100);
                       }
                    }
                 }
              }

            if(OP_1HEDGING_2REFRESH == 1)
               if(is_same_symbol(OrderComment(), MASK_HEDG) == false && is_same_symbol(all_keys_hedg, key)==false)
                 {
                  global_count_hedging += 1;
                  all_keys_hedg += key;

                  int OP_TYPE = OrderType() == OP_BUY ? OP_SELL : OP_BUY;
                  string hedg_comment = OrderComment();
                  if(OrderType() == OP_BUY)
                     StringReplace(hedg_comment, TREND_BUY, TREND_SEL);
                  if(OrderType() == OP_SELL)
                     StringReplace(hedg_comment, TREND_SEL, TREND_BUY);

                  hedg_comment = MASK_HEDG + key + hedg_comment;
                  bool hedging_ok = Open_Position(symbol, OP_TYPE, OrderLots(), 0.0, 0.0, hedg_comment);
                  if(hedging_ok)
                    {
                     send_telegram_hedging_ok = true;
                     Alert("(MASK_HEDG)" + symbol + " " + hedg_comment);
                    }
                 }


            if(is_same_symbol(OrderComment(), MASK_EXIT))
              {
               global_count_exit_order += 1;
               if(global_min_exit_price > OrderOpenPrice())
                  global_min_exit_price = OrderOpenPrice();
               if(global_max_exit_price < OrderOpenPrice())
                  global_max_exit_price = OrderOpenPrice();
              }
            else
              {
               if(OP_1HEDGING_2REFRESH == 1)
                 {
                  if(is_same_symbol(OrderComment(), MASK_HEDG) == false)
                     if(OrderStopLoss() > 0 || OrderTakeProfit() > 0)
                       {
                        int ross=0, demm = 1;
                        while(ross<=0 && demm<20)
                          {
                           ross=OrderModify(OrderTicket(), 0.0, 0.0, 0.0, 0, clrBlue);
                           demm++;
                           Sleep(100);
                          }
                       }
                 }

               if(OrderType() == OP_BUY)
                  total_vol_buy += OrderLots();

               if(OrderType() == OP_SELL)
                  total_vol_sel += OrderLots();
              }
           }
     } //for

   if(send_telegram_hedging_ok)
      SendTelegramMessage(symbol, "MASK_HEDG", "(MASK_HEDG)(" + (string)global_count_hedging + ") " + symbol);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Position(string symbol, int OP_TYPE, double volume, double sl, double tp, string comment)
  {
   int nextticket= 0, demm = 1;
   while(nextticket<=0 && demm < 12)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int slippage = (int)MathAbs(ask-bid);
      double price = NormalizeDouble((bid + ask)/2, Digits);
      if(OP_TYPE == OP_BUY)
         price = ask;
      if(OP_TYPE == OP_SELL)
         price = bid;

      nextticket = OrderSend(symbol, OP_TYPE, volume, price, slippage, sl, tp, comment, 0, 0, clrBlue);
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
void Draw_Buttons()
  {
//if(ObjectFind(0, BtnNewCycle) >= 0)
   ObjectDelete(0, BtnHedging);
   ObjectDelete(0, BtnNewCycleBuy);
   ObjectDelete(0, BtnNewCycleSel);
   ObjectDelete(0, BtnUpTpBuy);
   ObjectDelete(0, BtnDnTpBuy);
   ObjectDelete(0, BtnUpTpSel);
   ObjectDelete(0, BtnDnTpSel);
   ObjectDelete(0, BtnManualBuy);
   ObjectDelete(0, BtnManualSel);

   int y_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 45;

   createButton(BtnHedging, "Hedging " + (global_count_hedging > 0 ? "(" + (string)global_count_hedging + ")" : ""), 10, y_ref_btn - 90, 120, 35, clrBlack, clrLightGreen, 9);

   color clrNewCycleColorBuy = IS_CONTINUE_TRADING_CYCLE_BUY ? clrLightGreen : clrGray;
   string lableBuy = BOT_SHORT_NM + " Auto BUY " + (IS_CONTINUE_TRADING_CYCLE_BUY ? "(ON)" : "(OFF)");
   createButton(BtnNewCycleBuy, lableBuy, 10, y_ref_btn - 45, 190, 35, clrBlack, clrNewCycleColorBuy, 9);

   color clrBtnManualBuy = enableBtnManualBuy ? clrLightGreen : clrGray;
   color clrTextBuy = INIT_TREND_TODAY == TREND_BUY ? clrBlack : clrBlack;
   createButton(BtnManualBuy, "Buy" + (INIT_TREND_TODAY == TREND_BUY ? " (Main)" : " (Revr)"),  210, y_ref_btn - 45, 110, 35, clrTextBuy, clrBtnManualBuy, 9);

   color clrNewCycleColorSel = IS_CONTINUE_TRADING_CYCLE_SEL ? clrLightGreen : clrGray;
   string lableSel = BOT_SHORT_NM + " Auto SEL " + (IS_CONTINUE_TRADING_CYCLE_SEL ? "(ON)" : "(OFF)");
   createButton(BtnNewCycleSel, lableSel, 10, y_ref_btn,      190, 35, clrBlack, clrNewCycleColorSel, 9);

   color clrBtnManualSel = enableBtnManualSel ? clrLightGreen : clrGray;
   color clrTextSel = INIT_TREND_TODAY == TREND_SEL ? clrBlack : clrBlack;
   createButton(BtnManualSel, "Sell" + (INIT_TREND_TODAY == TREND_SEL ? " (Main)" : " (Revr)"), 210, y_ref_btn, 110, 35, clrTextSel, clrBtnManualSel, 9);

   ObjectDelete(0, BtnCloseProfitBuy);
   if(lable_profit_buy != "")
     {
      color lblColor = StringFind(lable_profit_buy, "-") > 0 ? clrFireBrick : clrBlue;
      createButton(BtnCloseProfitBuy, lable_profit_buy, 130 + 200, y_ref_btn - 45, 250, 35, lblColor, clrLightSkyBlue, 9);
      createButton(BtnUpTpBuy,         "(B)TP +3$",     130 + 460, y_ref_btn - 45, 100, 35, clrBlack, clrLightSkyBlue, 9);
      createButton(BtnDnTpBuy,         "(B)TP -1$",     130 + 570, y_ref_btn - 45, 100, 35, clrBlack, clrLightSkyBlue, 9);
     }


   ObjectDelete(0, BtnCloseProfitSel);
   if(lable_profit_sel != "")
     {
      color lblColor = StringFind(lable_profit_sel, "-") > 0 ? clrFireBrick : clrBlue;
      createButton(BtnCloseProfitSel, lable_profit_sel, 130 + 200, y_ref_btn, 250, 35, lblColor, clrSeashell, 9);
      createButton(BtnUpTpSel,         "(S)TP +3$",     130 + 460, y_ref_btn, 100, 35, clrBlack, clrSeashell, 9);
      createButton(BtnDnTpSel,         "(S)TP -1$",     130 + 570, y_ref_btn, 100, 35, clrBlack, clrSeashell, 9);
     }
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
      //-----------------------------------------------------------------------
      if(sparam == BtnHedging)
        {
         string msg = BOT_SHORT_NM + " Hedging " + Symbol() + "?\n";
         msg += "(YES) Hedging + Refresh.\n";
         msg += "(NO)  Refresh.";
         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
            do_hedging(Symbol(), 1);
         if(result == IDNO)
            do_hedging(Symbol(), 2);
        }

      if(sparam == BtnPaddingTrade)
        {
         string msg = BOT_SHORT_NM + " " + Symbol() + " " + lableBtnPaddingTrade + "?";
         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
            do_padding_trade(Symbol(), true);
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnNewCycleBuy)
        {
         Print("The ", sparam," was clicked, IS_CONTINUE_TRADING_CYCLE_BUY=" + (string)IS_CONTINUE_TRADING_CYCLE_BUY);
         IS_CONTINUE_TRADING_CYCLE_BUY = !IS_CONTINUE_TRADING_CYCLE_BUY;
         Print("IS_CONTINUE_TRADING_CYCLE_BUY ->" + (string)IS_CONTINUE_TRADING_CYCLE_BUY);
         OnTimer();
        }
      if(sparam == BtnNewCycleSel)
        {
         Print("The ", sparam," was clicked, IS_CONTINUE_TRADING_CYCLE_SEL=" + (string)IS_CONTINUE_TRADING_CYCLE_SEL);
         IS_CONTINUE_TRADING_CYCLE_SEL = !IS_CONTINUE_TRADING_CYCLE_SEL;
         Print("IS_CONTINUE_TRADING_CYCLE_SEL ->" + (string)IS_CONTINUE_TRADING_CYCLE_SEL);
         OnTimer();
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnCloseProfitBuy)
        {
         string msg = BOT_SHORT_NM + " CLOSE_ALL " + Symbol() + "  " + lable_profit_buy;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");
            ClosePosition(Symbol(), OP_BUY, BOT_SHORT_NM);
            OnTimer();
           }
        }
      if(sparam == BtnUpTpBuy)
        {
         ModifyTp_ForPotentialProfit(Symbol(), OP_BUY, 3, BOT_SHORT_NM, 0.0);
         OnTimer();
        }

      if(sparam == BtnDnTpBuy)
        {
         ModifyTp_ForPotentialProfit(Symbol(), OP_BUY,-1, BOT_SHORT_NM, 0.0);
         OnTimer();
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnCloseProfitSel)
        {
         string msg = BOT_SHORT_NM + " CLOSE_ALL " + Symbol() + "  " + lable_profit_sel;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");
            ClosePosition(Symbol(), OP_SELL, BOT_SHORT_NM);
            OnTimer();
           }
        }

      if(sparam == BtnUpTpSel)
        {
         ModifyTp_ForPotentialProfit(Symbol(), OP_SELL, 3, BOT_SHORT_NM, 0.0);
         OnTimer();
        }

      if(sparam == BtnDnTpSel)
        {
         ModifyTp_ForPotentialProfit(Symbol(), OP_SELL,-1, BOT_SHORT_NM, 0.0);
         OnTimer();
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnManualBuy)
        {
         string msg = BOT_SHORT_NM + " ManualBuy " + Symbol() + "  " + lable_profit_sel;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            string trader_name = create_trader_name();
            string temp_result = OpenTrade_ByFibonacci(Symbol(), trader_name, TREND_BUY, true);
           }
        }

      if(sparam == BtnManualSel)
        {
         string msg = BOT_SHORT_NM + " ManualSell " + Symbol() + "  " + lable_profit_sel;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            string trader_name = create_trader_name();
            string temp_result = OpenTrade_ByFibonacci(Symbol(), trader_name, TREND_SEL, true);
           }
        }
      //-----------------------------------------------------------------------
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      ChartRedraw();
      Draw_Buttons();
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_And_ProgressiveProfits(string symbol, string TRADING_TREND, double tp_price, string TRADER)
  {
   double old_tp = 0;
   double old_potential_profit = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
              {
               old_tp = OrderTakeProfit();
               if(TRADING_TREND == TREND_BUY)
                  old_potential_profit += determinePotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), OrderTakeProfit(), OrderLots());
               if(TRADING_TREND == TREND_SEL)
                  old_potential_profit += determinePotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), OrderTakeProfit(), OrderLots());
              }


   double new_tp = tp_price;
   if(old_tp != tp_price)
     {
      int count = 0;
      while(true)
        {
         double new_potential_profit = 0;
         for(int i = OrdersTotal() - 1; i >= 0; i--)
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
               if(toLower(symbol) == toLower(OrderSymbol()))
                  if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
                    {
                     if(TRADING_TREND == TREND_BUY)
                        new_potential_profit += determinePotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), new_tp, OrderLots());
                     if(TRADING_TREND == TREND_SEL)
                        new_potential_profit += determinePotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), new_tp, OrderLots());
                    }

         if(new_potential_profit > old_potential_profit)
            break;

         if(TRADING_TREND == TREND_BUY)
            new_tp += AMP_DC_BUY;
         if(TRADING_TREND == TREND_SEL)
            new_tp -= AMP_DC_SEL;

         count += 1;
         if(count> 100)
            return;
        }
     }

   double BID = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ASK = SymbolInfoDouble(symbol, SYMBOL_ASK);
   int slippage = (int)MathAbs(ASK-BID);

   datetime time_draw = iTime(symbol, PERIOD_H4, 0);
   color lineColor = TRADING_TREND == TREND_BUY ? clrBlue : clrFireBrick;
   create_trend_line(TRADER + TRADING_TREND + "_TP", time_draw, new_tp, time_draw + TIME_OF_ONE_H4_CANDLE, new_tp, lineColor, STYLE_SOLID, 3);

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
              {
               double cur_tp = OrderTakeProfit();
               double opend_price = OrderOpenPrice();

               if(cur_tp != tp_price)
                 {
                  double price = (OrderType() == OP_BUY) ? ASK : (OrderType() == OP_SELL) ? BID : NormalizeDouble((ASK+BID/2), Digits);

                  int ross=0, demm = 1;
                  while(ross<=0 && demm<20)
                    {
                     ross=OrderModify(OrderTicket(),price,OrderStopLoss(),new_tp,0,clrBlue);
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
void ModifyTp_ExceptLockKey(string symbol, string TRADING_TREND, double tp_price, string TRADER)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(is_same_symbol(OrderSymbol(), symbol))
            if(StringFind(toLower(OrderComment()), toLower(TRADER)) >= 0)
               if(StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0)
                  if(OrderTakeProfit() != tp_price)
                     if(is_same_symbol(OrderComment(), LOCK) == false &&
                        is_same_symbol(OrderComment(), "B2S") == false &&
                        is_same_symbol(OrderComment(), "S2B") == false)
                       {
                        double price = SymbolInfoDouble(symbol, SYMBOL_BID);
                        if(OrderType() == OP_BUY)
                           price = SymbolInfoDouble(symbol, SYMBOL_ASK);

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
void ModifyTp_ForPotentialProfit(string symbol, int order_type, double added_amp_tp, string KEY_TO_CLOSE, double old_tp_price)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(is_same_symbol(OrderSymbol(), symbol))
            if(is_same_symbol(OrderComment(), KEY_TO_CLOSE))
               if(OrderType() == order_type)
                  if(OrderTakeProfit() != old_tp_price)
                     if(is_same_symbol(OrderComment(), LOCK) == false &&
                        is_same_symbol(OrderComment(), "B2S") == false &&
                        is_same_symbol(OrderComment(), "S2B") == false)
                       {
                        double tp_price = OrderTakeProfit();
                        double price = SymbolInfoDouble(symbol, SYMBOL_BID);

                        if(OrderType() == OP_BUY)
                          {
                           tp_price += added_amp_tp;
                           price = SymbolInfoDouble(symbol, SYMBOL_ASK);
                          }
                        if(OrderType() == OP_SELL)
                          {
                           tp_price -= added_amp_tp;
                           price = SymbolInfoDouble(symbol, SYMBOL_BID);
                          }

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
         if(is_same_symbol(OrderSymbol(), symbol))
            if(StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0)
               if(OrderStopLoss() != sl_price)
                  if(is_same_symbol(OrderComment(), LOCK) == false &&
                     is_same_symbol(OrderComment(), "B2S") == false &&
                     is_same_symbol(OrderComment(), "S2B") == false)
                    {
                     double price = 0.0;
                     if(OrderType() == OP_SELL)
                       {
                        price = SymbolInfoDouble(symbol, SYMBOL_ASK);
                        if(price >= OrderOpenPrice())
                           price = 0.0;
                       }

                     if(OrderType() == OP_BUY)
                       {
                        price = SymbolInfoDouble(symbol, SYMBOL_BID);
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
         if(is_same_symbol(OrderSymbol(), symbol))
            if(OrderType() == ordertype)
               if(TRADER == "" || is_same_symbol(OrderComment(), TRADER))
                 {
                  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
                  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
                  int slippage = (int)MathAbs(ask-bid);

                  if(OrderType() == OP_BUY)
                     if(!OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet))
                       {
                        Print("OrderClose error ",GetLastError());
                        Sleep(1000);
                       }

                  if(OrderType() == OP_SELL)
                     if(!OrderClose(OrderTicket(),OrderLots(), ask, slippage, clrViolet))
                       {
                        Print("OrderClose error ",GetLastError());
                        Sleep(1000);
                       }
                 }
     } //for
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string symbol, string trend, string message)
  {
   if(ALERT_MSG_TIME == iTime(symbol, PERIOD_H4, 0))
      return;
   ALERT_MSG_TIME = iTime(symbol, PERIOD_H4, 0);

   Alert(get_vntime(), message);
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
   StringReplace(date_time, ":", "");

   string key = date_time + ":PERIOD_H4:" + TRADING_TREND_KEY + ":" + symbol +";";
   StringReplace(key, " ", "_");
   StringReplace(key, ".", "");
   StringReplace(key, "::", ":");
   StringReplace(key, ":", ":");

   return key;
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
double get_total_by_fibo_1618(double init, int trade_no, int digits)
  {
   double fibo = 1.618;
   double vol = init;
   double total = init;
   for(int i = 2; i <= trade_no; i++)
     {
      vol = vol*fibo;
      total += vol;
     }

   return NormalizeDouble(total, digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_value_by_fibo_2618(double init, int trade_no, int digits)
  {
   double fibo = 2.618;
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

   if(macd_0 >= 0 && macd_1 >= 0)
      trend_mac_vs_zero = TREND_BUY;

   if(macd_0 <= 0 && macd_1 <= 0)
      trend_mac_vs_zero = TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trend_shift(string symbol, string NEW_TREND)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double lowest = 0.0, higest = 0.0;
   for(int idx = 1; idx <= 55; idx++)
     {
      double close = iClose(symbol, PERIOD_H4, idx);
      if((idx == 0) || (lowest > close))
         lowest = close;
      if((idx == 0) || (higest < close))
         higest = close;
     }

   if((NEW_TREND == TREND_BUY) && (higest - AMP_TP_BUY*2 < price))
      return false;

   if((NEW_TREND == TREND_SEL) && (lowest + AMP_TP_SEL*2 > price))
      return false;

   double PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   if(EQUITY < BALANCE/2)
      return false;

   if(PROFIT < 0 && MathAbs(PROFIT) < EQUITY/3)
      return false;

// Cần chờ tối thiểu 1 giờ sau mỗi lần chuyển đổi để tránh tạo GAP sụt giảm tài khoản.
//bool pass_time_check = false;
//datetime currentTime = TimeCurrent();
//datetime timeGap = currentTime - last_trend_shift_time;
//if(timeGap < 1 * 60 * 60)
//   return false;

   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H4, NEW_TREND, 3, 2, 3))
      return true;
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H1, NEW_TREND, 3, 2, 3))
      return true;
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_M15, NEW_TREND, 3, 2, 3))
      return true;

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
bool passes_time_between_trader()
  {
   int waiting_minus = 5;
   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - global_last_open_time;
   if(timeGap >= waiting_minus * 60)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool passes_waiting_time_dca(datetime last_open_trade_time, int count_possion)
  {
   int waiting_minus = DEFAULT_WAITING_DCA_IN_MINUS + MINUTES_BETWEEN_ORDER*count_possion;

   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_open_trade_time;
   if(timeGap >= waiting_minus * 60)
      return true;

   return false;
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
string str_remaining_time(datetime last_open_trade_time, int count_possion)
  {
   int waiting_minus = DEFAULT_WAITING_DCA_IN_MINUS + MINUTES_BETWEEN_ORDER*count_possion;

   int remain = remaining_time_to_dca(last_open_trade_time, waiting_minus);
   datetime currentTime = TimeCurrent();
   datetime newTime = currentTime + remain * 60;

   if(remain < 0)
      remain = 0;

   string value = "  " + (string)remain  + "p";

   return value;
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

   if(dbTickSize == 0 || dbLotsStep == 0 || dbLotsStep == 0)
      return 0.01;

   double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
   if(dbLossOrder == 0)
      return 0.01;

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
   string vntime = "(" + str_date_time + ")    " + INDI_NAME + "   ";
   StringReplace(vntime, "GuardianAngel", "");
   return vntime;
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
   const bool              is_hiden = true
)
  {
   string name_new = name;
   ObjectDelete(0, name);
   if(ray_left)
      time_from = time_to - TIME_OF_ONE_H4_CANDLE * 1000;
   ObjectCreate(0, name_new, OBJ_TREND, 0, time_from, price_from, time_to, price_to);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_XX);
   ObjectSetInteger(0, name_new, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN,      is_hiden);
   ObjectSetInteger(0, name_new, OBJPROP_BACK,        is_hiden);
   ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE,  !is_hiden);
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

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);


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
void GetAmpAvgL15(string symbol, double &amp_w1, double &amp_d1, double &amp_h4, double &amp_grid_L100)
  {
   if(is_same_symbol(symbol, "XAUUSD"))
     {
      amp_w1 = 50;
      amp_d1 = 20;
      amp_h4 = 6.295;
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
      amp_w1 = 7.182;
      amp_d1 = 1.983;
      amp_h4 = 0.805;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      amp_w1 = 3570.59;
      amp_d1 = 1273.25;
      amp_h4 = 789.1;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USTEC"))
     {
      amp_w1 = 664.39;
      amp_d1 = 199.95;
      amp_h4 = 81.16;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "US30"))
     {
      amp_w1 = 1066.8;
      amp_d1 = 308.8;
      amp_h4 = 119.5;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "US500"))
     {
      amp_w1 = 154.5;
      amp_d1 = 43.3;
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
      amp_w1 = 247.74;
      amp_d1 = 76.95;
      amp_h4 = 30.71;
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
      amp_d1 = 0.0042;
      amp_h4 = 0.00158;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDNZD"))
     {
      amp_w1 = 0.01293;
      amp_d1 = 0.00481;
      amp_h4 = 0.00178;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDUSD"))
     {
      amp_w1 = 0.01652;
      amp_d1 = 0.00567;
      amp_h4 = 0.00218;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDJPY"))
     {
      amp_w1 = 2.285;
      amp_d1 = 0.774;
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
      amp_w1 = 3.166;
      amp_d1 = 1.101;
      amp_h4 = 0.434;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPJPY"))
     {
      amp_w1 = 3.873;
      amp_d1 = 1.326;
      amp_h4 = 0.53;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "NZDJPY"))
     {
      amp_w1 = 2.034;
      amp_d1 = 0.704;
      amp_h4 = 0.272;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDJPY"))
     {
      amp_w1 = 3.044;
      amp_d1 = 1.072;
      amp_h4 = 0.427;
      amp_grid_L100 = 1.5;
      return;
     }
   if(is_same_symbol(symbol, "EURAUD"))
     {
      amp_w1 = 0.02969;
      amp_d1 = 0.01072;
      amp_h4 = 0.00417;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURCAD"))
     {
      amp_w1 = 0.02146;
      amp_d1 = 0.00765;
      amp_h4 = 0.00284;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURCHF"))
     {
      amp_w1 = 0.01309;
      amp_d1 = 0.00429;
      amp_h4 = 0.0018;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURGBP"))
     {
      amp_w1 = 0.01162;
      amp_d1 = 0.00356;
      amp_h4 = 0.00131;
      amp_grid_L100 = 0.00155;
      return;
     }
   if(is_same_symbol(symbol, "EURNZD"))
     {
      amp_w1 = 0.03185;
      amp_d1 = 0.01191;
      amp_h4 = 0.00478;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURUSD"))
     {
      amp_w1 = 0.01858;
      amp_d1 = 0.00624;
      amp_h4 = 0.00239;
      amp_grid_L100 = 0.0035;
      return;
     }
   if(is_same_symbol(symbol, "GBPCHF"))
     {
      amp_w1 = 0.01905;
      amp_d1 = 0.00601;
      amp_h4 = 0.00241;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPNZD"))
     {
      amp_w1 = 0.03533;
      amp_d1 = 0.01304;
      amp_h4 = 0.00531;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPUSD"))
     {
      amp_w1 = 0.02454;
      amp_d1 = 0.00811;
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
      amp_w1 = 0.0151;
      amp_d1 = 0.00524;
      amp_h4 = 0.0021;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      amp_w1 = 0.01943;
      amp_d1 = 0.00651;
      amp_h4 = 0.00252;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDCHF"))
     {
      amp_w1 = 0.017;
      amp_d1 = 0.00715;
      amp_h4 = 0.00235;
      amp_grid_L100 = 0.006;
      return;
     }

   amp_w1 = CalculateAverageCandleHeight(PERIOD_W1, symbol, 20);
   amp_d1 = CalculateAverageCandleHeight(PERIOD_D1, symbol, 30);
   amp_h4 = CalculateAverageCandleHeight(PERIOD_H4, symbol, 60);
   amp_grid_L100 = amp_h4;
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
   for(int i = 0; i < totalObjects - 1; i++)
     {
      string objectName = ObjectName(0, i); // Lấy tên của đối tượng
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
   const string            TRADING_TREND="BUY",
   const bool              trim_text = true
)
  {
   ObjectDelete(0, name);
   color clr_color = TRADING_TREND==TREND_BUY ? clrBlue : TRADING_TREND==TREND_BUY ? clrRed : clrBlack;
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
                                + "\t" + "W1: " + (string) CalculateAverageCandleHeight(PERIOD_W1, symbol, 120)
                                + "\t" + "D1: " + (string) CalculateAverageCandleHeight(PERIOD_D1, symbol, 360)
                                + "\t" + "H4: " + (string) CalculateAverageCandleHeight(PERIOD_H4, symbol, 720)
                                + "\t" + "H1: " + (string) CalculateAverageCandleHeight(PERIOD_H1, symbol, 720)
                                + "\t" + "M15: " + (string) CalculateAverageCandleHeight(PERIOD_M15, symbol, 720)
                                + "\t" + "M5: " + (string) CalculateAverageCandleHeight(PERIOD_M5, symbol, 720)
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
                                + "\t" + "W1: " + (string) calc_avg_pivot(PERIOD_W1, symbol, 54)
                                + "\t" + "D1: " + (string) calc_avg_pivot(PERIOD_D1, symbol, 360)
                                + "\t" + "H4: " + (string) calc_avg_pivot(PERIOD_H4, symbol, 720)
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
bool createButton(string objName, string text, int x, int y, int width, int height, color clrTextColor, color clrBackground, int font_size, int z_index=999)
  {
   ResetLastError();
   if(!ObjectCreate(0, objName, OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }

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
double determinePotentialTradeProfit(string symbol, ENUM_ORDER_TYPE orderType, double orderOpenPrice, double orderTakeProfitPrice, double orderLots)
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

   int index = 0;
   string trader_name = BOT_SHORT_NM + "{^" + (string)(index) + "^}_";
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

      CandleData candle_x(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_trend);
      candleArray[index] = candle_x;
     }
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
double get_largest_negative(string TRADER)
  {
   for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
     {
      string name = arr_largest_negative_trader_name[i];
      if(is_same_symbol(name, TRADER))
         return MathAbs(NormalizeDouble(arr_largest_negative_trader_amount[i], 2));
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_largest_negative(string TRADER, double profit)
  {
   if(profit > 0)
      return;

   double found_trader = false;
   for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
     {
      string name = arr_largest_negative_trader_name[i];
      if(is_same_symbol(name, TRADER))
        {
         found_trader = true;
         if(MathAbs(arr_largest_negative_trader_amount[i]) < MathAbs(profit))
            arr_largest_negative_trader_amount[i] = MathAbs(profit);
        }
     }

   if(found_trader == false)
     {
      for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
        {
         string name = arr_largest_negative_trader_name[i];
         if(name == "" || StringLen(name) < 1)
           {
            arr_largest_negative_trader_name[i] = TRADER;
            arr_largest_negative_trader_amount[i] = MathAbs(profit);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcRisk()
  {
   double dbRiskRatio = 0.01;    // Rủi ro 1%
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
string create_comment(string TRADER, string TRADING_TREND, int L)
  {
   string result = TRADER + TRADING_TREND + "_" + append1Zero(L);
   if(L >= NUMBER_PE_TRADE)
      result = MASK_EXIT + result;

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
double get_estimate_profit(double AMP_DC, int trade_no)
  {
   if(AMP_DC < 2)// amp=1.000->1.999
     {
      if(trade_no == 1)
         return 3 ;
      if(trade_no == 2)
         return 6.35 ;
      if(trade_no == 3)
         return 10.28 ;
      if(trade_no == 4)
         return 15.13 ;
      if(trade_no == 5)
         return 21.49 ;
      if(trade_no == 6)
         return 30.27 ;
      if(trade_no == 7)
         return 42.97 ;
      if(trade_no == 8)
         return 62.03 ;
      if(trade_no == 9)
         return 91.36 ;
      if(trade_no == 10)
         return 137.32 ;
      if(trade_no == 11)
         return 210.18 ;
      if(trade_no == 12)
         return 326.58 ;
      if(trade_no == 13)
         return 513.4 ;
      if(trade_no == 14)
         return 814.19 ;
      if(trade_no == 15)
         return 1299.36 ;
      if(trade_no == 16)
         return 2082.86 ;
      if(trade_no == 17)
         return 3349.06 ;
      if(trade_no == 18)
         return 5396.28 ;
      if(trade_no == 19)
         return 8707.19 ;
      if(trade_no == 20)
         return 14062.73 ;
      return 0;
     }

   if(AMP_DC < 3)// amp=2.000->2.999
     {
      if(trade_no == 1)
         return 4 ;
      if(trade_no == 2)
         return 8.47 ;
      if(trade_no == 3)
         return 13.71 ;
      if(trade_no == 4)
         return 20.18 ;
      if(trade_no == 5)
         return 28.65 ;
      if(trade_no == 6)
         return 40.36 ;
      if(trade_no == 7)
         return 57.29 ;
      if(trade_no == 8)
         return 82.7 ;
      if(trade_no == 9)
         return 121.81 ;
      if(trade_no == 10)
         return 183.09 ;
      if(trade_no == 11)
         return 280.25 ;
      if(trade_no == 12)
         return 435.44 ;
      if(trade_no == 13)
         return 684.54 ;
      if(trade_no == 14)
         return 1085.58 ;
      if(trade_no == 15)
         return 1732.47 ;
      if(trade_no == 16)
         return 2777.14 ;
      if(trade_no == 17)
         return 4465.42 ;
      if(trade_no == 18)
         return 7195.05 ;
      if(trade_no == 19)
         return 11609.59 ;
      if(trade_no == 20)
         return 18750.31 ;
      return 0;
     }

   if(AMP_DC < 4) // amp=3.000->3.999
     {
      if(trade_no == 1)
         return 6 ;
      if(trade_no == 2)
         return 12.71 ;
      if(trade_no == 3)
         return 20.56 ;
      if(trade_no == 4)
         return 30.27 ;
      if(trade_no == 5)
         return 42.97 ;
      if(trade_no == 6)
         return 60.53 ;
      if(trade_no == 7)
         return 85.94 ;
      if(trade_no == 8)
         return 124.05 ;
      if(trade_no == 9)
         return 182.72 ;
      if(trade_no == 10)
         return 274.64 ;
      if(trade_no == 11)
         return 420.37 ;
      if(trade_no == 12)
         return 653.16 ;
      if(trade_no == 13)
         return 1026.81 ;
      if(trade_no == 14)
         return 1628.38 ;
      if(trade_no == 15)
         return 2598.71 ;
      if(trade_no == 16)
         return 4165.72 ;
      if(trade_no == 17)
         return 6698.13 ;
      if(trade_no == 18)
         return 10792.57 ;
      if(trade_no == 19)
         return 17414.38 ;
      if(trade_no == 20)
         return 28125.46 ;
      return 0;
     }

   if(AMP_DC < 5) // amp=4.000->4.999
     {
      if(trade_no == 1)
         return 8 ;
      if(trade_no == 2)
         return 16.94 ;
      if(trade_no == 3)
         return 27.42 ;
      if(trade_no == 4)
         return 40.36 ;
      if(trade_no == 5)
         return 57.3 ;
      if(trade_no == 6)
         return 80.71 ;
      if(trade_no == 7)
         return 114.59 ;
      if(trade_no == 8)
         return 165.41 ;
      if(trade_no == 9)
         return 243.63 ;
      if(trade_no == 10)
         return 366.19 ;
      if(trade_no == 11)
         return 560.49 ;
      if(trade_no == 12)
         return 870.88 ;
      if(trade_no == 13)
         return 1369.08 ;
      if(trade_no == 14)
         return 2171.17 ;
      if(trade_no == 15)
         return 3464.95 ;
      if(trade_no == 16)
         return 5554.29 ;
      if(trade_no == 17)
         return 8930.84 ;
      if(trade_no == 18)
         return 14390.09 ;
      if(trade_no == 19)
         return 23219.17 ;
      if(trade_no == 20)
         return 37500.62 ;
      return 0;
     }

   if(AMP_DC > 5) // amp=5.000->5.999
     {
      if(trade_no == 1)
         return 10 ;
      if(trade_no == 2)
         return 21.18 ;
      if(trade_no == 3)
         return 34.27 ;
      if(trade_no == 4)
         return 50.45 ;
      if(trade_no == 5)
         return 71.62 ;
      if(trade_no == 6)
         return 100.89 ;
      if(trade_no == 7)
         return 143.24 ;
      if(trade_no == 8)
         return 206.76 ;
      if(trade_no == 9)
         return 304.53 ;
      if(trade_no == 10)
         return 457.73 ;
      if(trade_no == 11)
         return 700.61 ;
      if(trade_no == 12)
         return 1088.6 ;
      if(trade_no == 13)
         return 1711.35 ;
      if(trade_no == 14)
         return 2713.96 ;
      if(trade_no == 15)
         return 4331.19 ;
      if(trade_no == 16)
         return 6942.86 ;
      if(trade_no == 17)
         return 11163.55 ;
      if(trade_no == 18)
         return 17987.62 ;
      if(trade_no == 19)
         return 29023.96 ;
      if(trade_no == 20)
         return 46875.77 ;
      return 0;
     }

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void auto_join_market(string symbol)
  {
   if(IsTesting() == false)
      return;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);
   int currentVnHour = vietnamDateTime.hour;

   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week == SATURDAY || day_of_week == SUNDAY)
      return;

   if(6 <= currentVnHour && currentVnHour <= 15)
      if((IS_CONTINUE_TRADING_CYCLE_BUY == false && INIT_TREND_TODAY == TREND_BUY) ||
         (IS_CONTINUE_TRADING_CYCLE_SEL == false && INIT_TREND_TODAY == TREND_SEL))
         if(is_allow_trade_now_by_stoc(symbol, PERIOD_M15, INIT_TREND_TODAY, 5, 3, 3)
            || is_allow_trade_now_by_stoc(symbol, PERIOD_H1, INIT_TREND_TODAY, 5, 3, 3)
            || is_allow_trade_now_by_stoc(symbol, PERIOD_H4, INIT_TREND_TODAY, 5, 3, 3))
           {
            if(INIT_TREND_TODAY == TREND_BUY)
              {
               IS_CONTINUE_TRADING_CYCLE_BUY = true;
               //SendAlert(symbol, "AUTO_JOIN", "(auto_join_market): CYCLE_BUY -> True");
              }
            if(INIT_TREND_TODAY == TREND_SEL)
              {
               IS_CONTINUE_TRADING_CYCLE_SEL = true;
               //SendAlert(symbol, "AUTO_JOIN", "(auto_join_market): CYCLE_SEL -> True");
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = get_vntime() + "(" + cur_timeframe + ") " + Symbol();

   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "";
   get_trend_by_macd_and_signal_vs_zero(Symbol(), PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4);

   str_comments += "    (H4): " + (string) trend_mac_vs_zero_h4;
   str_comments += "    Init: " + (string) INIT_VOLUME + " lot";
   str_comments += "    Funds: " + (string) INIT_EQUITY + "$ ";/// Risk: " + format_double_to_string(risk, 1) + "$ / " + format_double_to_string((dbRiskRatio * 100), 2) + "%    ";
   str_comments += "    Lmax: " + (string) NUMBER_OF_TRADE;
//str_comments += "    Amp(15): " + (string) calc_avg_pivot(PERIOD_M15, Symbol());
   str_comments += "    Amp(H1): " + (string) calc_avg_pivot(PERIOD_H1, Symbol());
   str_comments += "    DCA.Buy(H4): " + (string) AMP_DC_BUY;
   str_comments += "    DCA.Sel(H4): " + (string) AMP_DC_SEL;
//str_comments += "    Amp(D1): " + (string) calc_avg_pivot(PERIOD_D1, Symbol());
   str_comments += "    Amp(W1): " + (string) calc_avg_pivot(PERIOD_W1, Symbol());

   if(is_time_enter_the_market() == false)
      str_comments += "    Do Nothing! Stand outside";

   str_comments += "    CycleBuy: " + (string) IS_CONTINUE_TRADING_CYCLE_BUY;
   str_comments += "    CycleSel: " + (string) IS_CONTINUE_TRADING_CYCLE_SEL;
   str_comments += "    Next(5p): " + (string) passes_time_between_trader();

   return str_comments;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init_amp_dca(string symbol)
  {
   double lowest = 0.0, higest = 0.0;
   double lowest_3d = 0.0, higest_3d = 0.0;
   for(int idx = 0; idx <= 7; idx++)
     {
      double low = iLow(symbol, PERIOD_D1, idx);
      double hig = iHigh(symbol, PERIOD_D1, idx);
      if((idx == 0) || (lowest > low))
         lowest = low;
      if((idx == 0) || (higest < hig))
         higest = hig;

      if((idx == 0) || (lowest_3d > low && idx <= 2))
         lowest_3d = low;
      if((idx == 0) || (higest_3d < hig && idx <= 2))
         higest_3d = hig;
     }
   amp_d7 = MathAbs(higest - lowest);
   LOWEST_OF_7_DAYS = NormalizeDouble(lowest, Digits);
   CENTER_OF_3_DAYS = NormalizeDouble((higest_3d + lowest_3d)/2, Digits);
   HIGEST_OF_7_DAYS = NormalizeDouble(higest, Digits);

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);
   double amp_trade = NormalizeDouble(10, Digits);

   AMP_DC_BUY = amp_trade;
   AMP_DC_SEL = amp_trade;

   AMP_TP_BUY = NormalizeDouble(AMP_DC_BUY * 2, Digits);
   AMP_TP_SEL = NormalizeDouble(AMP_DC_SEL * 2, Digits);
  }
//+------------------------------------------------------------------+
