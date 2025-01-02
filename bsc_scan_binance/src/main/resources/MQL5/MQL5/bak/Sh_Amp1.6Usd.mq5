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
bool IS_ALLOW_HEDGING=false;
bool IS_ALLOW_TRAILING_STOP=false;
double AMP_TP_L1 = 3.0; //ATR_H1(200) = 6.75
double AMP_TRADE = AMP_TP_L1;
double AMP_STOP = AMP_TP_L1*7;
double AMP_TRAILING_STOP = 1.68;
double FIBO = 1.618;
double INIT_VOLUME=0.01;
int START_EXIT_L = 10;
double FIXED_SL = 100000.00; // 40$
string BOT_SHORT_NM = "(F168L10)";
//-----------------------------------------------------------------------------
string telegram_url="https://api.telegram.org";
//-----------------------------------------------------------------------------
#define BtnAutoBuy       "BtnAuto.Buy."
#define BtnAutoSel       "BtnAuto.Sel."
#define BtnDelLimitBuy   "BtnDelLimitBuy"
#define BtnDelLimitSel   "BtnDelLimitSel"
#define BtnSendLimitBuy  "BtnSendLimitBuy"
#define BtnSendLimitSel  "BtnSendLimitSel"
#define BtnTrendFollow   "BtnTrendFollow_"
#define BtnCloseAll      "BtnCloseAll"
#define BtnClearChart    "BtnClearChart"
#define BtnOneCycleBuy   "NewCycleBuy"
#define BtnOneCycleSel   "NewCycleSel"
#define BtnTpPositiveBuy "BtnTpPositiveBuy"
#define BtnTpPositiveSel "BtnTpPositiveSel"
//-----------------------------------------------------------------------------
#define BtnScheduleT2 "BtnScheduleT2_"
#define BtnScheduleT3 "BtnScheduleT3_"
#define BtnScheduleT4 "BtnScheduleT4_"
#define BtnScheduleT5 "BtnScheduleT5_"
#define BtnScheduleT6 "BtnScheduleT6_"
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
#define MAX_DD_DAY_BUY "MAX_DD_DAY_BUY"
#define MAX_DD_DAY_SEL "MAX_DD_DAY_SEL"
#define MAX_AMP_SOLVE_BUY "MAX_AMP_SOLVE_BUY"
#define MAX_AMP_SOLVE_SEL "MAX_AMP_SOLVE_SEL"
//-----------------------------------------------------------------------------
string trend_heiken_h4 = "";
string TREND_BUY = "BUY";
string TREND_SEL = "SEL";
string MASK_NORMAL = "";
string MASK_HEGING = "(Hg)";
string MASK_RECOVER = "(Re)";
string MASK_MARKET = "(Mk)";
string MASK_LIMIT = "(LM)";
int count_closed_today = 0;
double MAXIMUM_DOUBLE = 999999999;
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
bool enableBtnManualBuy = false, enableBtnManualSel = false;
const double AUTO_TRADE_ON = 1;
const double AUTO_TRADE_OFF = 0;
datetime TIME_OF_ONE_H1_CANDLE = 3600;
datetime TIME_OF_ONE_H4_CANDLE = 14400;
datetime TIME_OF_ONE_D1_CANDLE = 86400;
datetime TIME_OF_ONE_W1_CANDLE = 604800;
int ARR_TIMES[] = {24,25,13,14,15,16,17,18,19,20,21,22,23};
double global_count_buy=0,global_count_sel=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   string symbol = Symbol();
//DeleteAllObjects();

   Draw_Schedule();

   if(true)
     {
      SetGlobalVariable(MAX_L_BUY,   0);
      SetGlobalVariable(MAX_DD_BUY,  0);
      SetGlobalVariable(MAX_AMP_BUY, 0);
      SetGlobalVariable(MAX_AMP_SEL, 0);
      SetGlobalVariable(MAX_L_SEL,   0);
      SetGlobalVariable(MAX_DD_SEL,  0);
      SetGlobalVariable(MAX_TP_BUY,  0);
      SetGlobalVariable(MAX_TP_SEL,  0);

      SetGlobalVariable(MAX_DD_DAY_BUY,0);
      SetGlobalVariable(MAX_DD_DAY_SEL,0);
      SetGlobalVariable(MAX_AMP_SOLVE_BUY,0);
      SetGlobalVariable(MAX_AMP_SOLVE_SEL,0);

      //SetGlobalVariable(BtnTrendFollow+symbol,AUTO_TRADE_ON);
      SetGlobalVariable(BtnAutoBuy+symbol,AUTO_TRADE_ON);
      SetGlobalVariable(BtnAutoSel+symbol,AUTO_TRADE_ON);
     }

   Comment(GetComments());

//EventSetTimer(10); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTick()
  {
   long chartID=ChartFirst();
   if(ChartNext(chartID) != -1)
      ChartClose(chartID);

   string symbol = Symbol();
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   create_trend_line("cur_price"
                     , TimeCurrent()-TIME_OF_ONE_W1_CANDLE, cur_price
                     , TimeCurrent()+TIME_OF_ONE_W1_CANDLE, cur_price
                     , clrFireBrick, STYLE_DOT, 1, true, true);
//-------------------------------------------------------------------------------
   string cur_symbol = Symbol();
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(vietnamTime, time_struct);

   int cur_hour = time_struct.hour;
   int pre_check_hour = (int)GetGlobalVariable("timer_one_hour");
   SetGlobalVariable("timer_one_hour", cur_hour);

   if(pre_check_hour != cur_hour)
     {
      Draw_Schedule();
     }
//-------------------------------------------------------------------------------
   OpenTrade_XauUsd(symbol);
   Comment(GetComments());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTrade_XauUsd(string symbol)
  {
   if(is_same_symbol(symbol, "XAU")==false)
      return;

   string tf = "";//get_time_frame_name(PERIOD_TRADE);
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double cur_price = NormalizeDouble((bid+ask)/2,digits);
   double open_d0 = iOpen(symbol,PERIOD_D1,0);
   double moved = NormalizeDouble(cur_price-open_d0,digits-2);

   double price_lowest_2d=MathMin(bid-0.5,MathMin(iLow(symbol,PERIOD_D1,0),iLow(symbol,PERIOD_D1,1)));
   double price_higest_2d=MathMax(ask+0.5,MathMax(iHigh(symbol,PERIOD_D1,0),iHigh(symbol,PERIOD_D1,1)));

   string today = (string)get_current_yyyymmdd();
   datetime time = iTime(symbol,PERIOD_D1,0);
   create_vertical_line(today,time, cur_price>open_d0?clrBlue:clrRed,STYLE_SOLID);
   create_trend_line("OPEN_D0",time,open_d0,time+TIME_OF_ONE_D1_CANDLE,open_d0,clrBlack,STYLE_DOT);

   double price_end_buy=MathMin(open_d0+AMP_STOP,price_lowest_2d+AMP_STOP);
   double price_end_sel=MathMax(open_d0-AMP_STOP,price_higest_2d-AMP_STOP);

   create_trend_line("END_SEL",time,price_end_sel,time+TIME_OF_ONE_D1_CANDLE,price_end_sel,clrRed,STYLE_DASH);
   create_trend_line("END_BUY",time,price_end_buy,time+TIME_OF_ONE_D1_CANDLE,price_end_buy,clrBlue,STYLE_DASH);
   create_label_simple("END_SEL_","End.Sel",price_end_sel,clrBlack,time+TIME_OF_ONE_D1_CANDLE);
   create_label_simple("END_BUY_","End.Buy",price_end_buy,clrBlack,time+TIME_OF_ONE_D1_CANDLE);

   ENUM_TIMEFRAMES PERIOD_MACD_FOLLOWING = PERIOD_D1;
//bool IS_FOLLOW_TREND = GetGlobalVariable(BtnTrendFollow+symbol)==AUTO_TRADE_ON;
   bool IS_CYCLE_BUY = (GetGlobalVariable(BtnAutoBuy+symbol)==AUTO_TRADE_ON);
   bool IS_CYCLE_SEL = (GetGlobalVariable(BtnAutoSel+symbol)==AUTO_TRADE_ON);

   string TRADE_TIMES="__8_9_10_11_12__14_15_16_17_18__";//7_13_22_23_1_2_3__";
   string vn_hour = "_" + (string)get_vn_hour() + "_";
   bool ALLOW_NEW_CYCLE = is_same_symbol(TRADE_TIMES,vn_hour);

   string trend_wdh4 = "";
   string trend_following = "";
//   if(IS_FOLLOW_TREND)
//     {
//      //string trend_ma10_w1 = get_trend_by_ma(symbol,PERIOD_W1,10,0);
//      //string trend_ma10_d1 = get_trend_by_ma(symbol,PERIOD_D1,10,0);
//      string trend_ma10_h4 = get_trend_by_ma(symbol,PERIOD_H4,10,1);
//      //if(trend_ma10_w1==trend_ma10_d1 && trend_ma10_d1==trend_ma10_h4)
//      //   trend_wdh4 = trend_ma10_w1;
//      //trend_following = "W:" + trend_ma10_w1 + " D:" + trend_ma10_d1 + " H4:" + trend_ma10_h4;
//
//      trend_following = " H4:" + trend_ma10_h4;
//      if(is_same_symbol(trend_following,TREND_BUY)==false)
//         IS_CYCLE_BUY=false;
//      if(is_same_symbol(trend_following,TREND_SEL)==false)
//         IS_CYCLE_SEL=false;
//     }

//if(price_end_buy<bid)
//   IS_CYCLE_BUY=false;
//if(price_end_sel>ask)
//   IS_CYCLE_SEL=false;

   ObjectDelete(0,"NEWS");
//if(is_economic_news())
   if(false)
     {
      IS_CYCLE_BUY=false;
      IS_CYCLE_SEL=false;
      create_lable_simple("NEWS","Disable trading due to economic news",open_d0-AMP_TRADE);
     }
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
   double risk_min = Risk_Min();
   double risk_1L = Risk_1L_By_Account_Balance();
   bool is_cur_tab = is_same_symbol(symbol, Symbol());

   int count_buy = 0, count_sel = 0, count_recover_buy = 0, count_recover_sel = 0, count_heg_buy = 0, count_heg_sel = 0;
   double vol_negertive_buy = 0, vol_negertive_sel = 0;
   string str_vol_buy = "", str_vol_sel = "";
   string last_comment_buy = "", last_comment_sel = "";
   string total_comment_buy = "", total_comment_sel = "";
   double last_tp_buy = 0, last_tp_sel = 0;
   double vol_buy = 0, vol_sel = 0, vol_heg_buy = 0, vol_heg_sel = 0, profit_buy = 0, profit_sel = 0;
   double global_profit = 0;
   double global_min_entry_buy = 0, global_max_entry_buy = 0;
   double global_min_entry_sel = 0, global_max_entry_sel = 0;
   double potential_profit_buy = 0, potential_profit_sel = 0;
   double positive_profit_buy = 0, positive_profit_sel = 0;
   double global_max_recover_buy=0,global_min_recover_sel=0;
   datetime last_time_buy = 0, last_time_sel = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(), symbol) && is_same_symbol(m_position.Comment(),BOT_SHORT_NM))
           {
            double current_tp = m_position.TakeProfit();
            string comment = m_position.Comment();
            double temp_profit = m_position.Profit() + m_position.Swap() + m_position.Commission();
            global_profit += temp_profit;

            if(is_same_symbol(comment, TREND_BUY))
              {
               total_comment_buy += m_position.Comment();

               if(is_same_symbol(comment,MASK_HEGING))
                 {
                  count_heg_buy += 1;
                  vol_heg_buy += m_position.Volume();
                 }
               else
                  if(is_same_symbol(m_position.TypeDescription(),TREND_BUY))
                    {
                     count_buy += 1;
                     vol_buy += m_position.Volume();

                     if(current_tp > 0 && current_tp < m_position.PriceOpen())
                        vol_negertive_buy += m_position.Volume();

                     //--------------------------------------MOVE_TP_BUY----------------------------------------
                     //Nếu giá gần đạt TP hiện tại (cách khoảng 2$), dịch TP lên thêm 3$
                     //double new_tp_level = current_tp + AMP_MOVE_TP;
                     //if((current_tp>0) && (bid >= current_tp - AMP_TRAILING_STOP))
                     //  {
                     //   current_tp=new_tp_level;
                     //   m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),new_tp_level);
                     //  }
                     //-----------------------------------------------------------------------------------------

                     //--------------------------------------TRAILING_STOP--------------------------------------
                     if(IS_ALLOW_TRAILING_STOP && global_count_buy>3)
                       {
                        double new_stop_level = bid - AMP_TRAILING_STOP;
                        if((temp_profit>risk_1L) && (m_position.PriceOpen() < new_stop_level))
                           if(m_position.StopLoss()==0 || m_position.StopLoss() < new_stop_level)
                              m_trade.PositionModify(m_position.Ticket(),new_stop_level,current_tp);
                       }
                     //-----------------------------------------------------------------------------------------

                     profit_buy += temp_profit;
                     str_vol_buy += DoubleToString(m_position.Volume(), 2) + " ";
                     if(temp_profit > 0)
                        positive_profit_buy += temp_profit;

                     potential_profit_buy += calcPotentialTradeProfit(symbol, TREND_BUY, m_position.PriceOpen(), current_tp, m_position.Volume());

                     if(global_min_entry_buy == 0 || global_min_entry_buy > m_position.PriceOpen())
                       {
                        last_tp_buy = current_tp;
                        last_time_buy = m_position.Time();
                        last_comment_buy = m_position.Comment();
                        global_min_entry_buy = m_position.PriceOpen();
                       }

                     if(global_max_entry_buy == 0 || global_max_entry_buy < m_position.PriceOpen())
                        global_max_entry_buy =  m_position.PriceOpen();

                     if(is_same_symbol(comment,MASK_RECOVER))
                       {
                        count_recover_buy+=1;
                        if(global_max_recover_buy==0 || global_max_recover_buy<m_position.PriceOpen())
                           global_max_recover_buy=m_position.PriceOpen();
                       }
                    }
              }

            if(is_same_symbol(comment, TREND_SEL))
              {
               total_comment_sel += m_position.Comment();

               if(is_same_symbol(comment,MASK_HEGING))
                 {
                  count_heg_sel += 1;
                  vol_heg_sel += m_position.Volume();
                 }
               else
                  if(is_same_symbol(m_position.TypeDescription(),TREND_SEL))
                    {
                     count_sel += 1;
                     vol_sel += m_position.Volume();

                     if(current_tp > 0 && current_tp > m_position.PriceOpen())
                        vol_negertive_sel += m_position.Volume();

                     //--------------------------------------MOVE_TP_SEL----------------------------------------
                     //Nếu giá gần đạt TP hiện tại (cách khoảng 2$), dịch TP lên thêm 3$
                     //double new_tp_level = current_tp - AMP_MOVE_TP;
                     //if((current_tp>0) && (ask <= current_tp + AMP_TRAILING_STOP))
                     //  {
                     //   current_tp=new_tp_level;
                     //   m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),new_tp_level);
                     //  }
                     //-----------------------------------------------------------------------------------------

                     //--------------------------------------TRAILING_STOP--------------------------------------
                     if(IS_ALLOW_TRAILING_STOP && global_count_sel>3)
                       {
                        double new_stop_level = ask + AMP_TRAILING_STOP;
                        if((temp_profit>risk_1L) && (m_position.PriceOpen() > new_stop_level))
                           if(m_position.StopLoss()==0 || m_position.StopLoss() > new_stop_level)
                              m_trade.PositionModify(m_position.Ticket(),new_stop_level,current_tp);
                       }
                     //-----------------------------------------------------------------------------------------

                     profit_sel += temp_profit;
                     str_vol_sel += DoubleToString(m_position.Volume(), 2) + " ";
                     if(temp_profit > 0)
                        positive_profit_sel += temp_profit;

                     potential_profit_sel += calcPotentialTradeProfit(symbol, TREND_SEL, m_position.PriceOpen(), current_tp, m_position.Volume());

                     if(global_min_entry_sel == 0 || global_min_entry_sel > m_position.PriceOpen())
                        global_min_entry_sel = m_position.PriceOpen();

                     if(global_max_entry_sel == 0 || global_max_entry_sel < m_position.PriceOpen())
                       {
                        last_tp_sel = current_tp;
                        last_time_sel = m_position.Time();
                        last_comment_sel = m_position.Comment();
                        global_max_entry_sel = m_position.PriceOpen();
                       }

                     if(is_same_symbol(comment,MASK_RECOVER))
                       {
                        count_recover_sel+=1;
                        if(global_min_recover_sel==0 || global_min_recover_sel>m_position.PriceOpen())
                           global_min_recover_sel=m_position.PriceOpen();
                       }
                    }
              }
           }
//---------------------------------------------------------------------------------------------------------
   int count_order_buy=0,count_order_sel=0;
   string yyyymmdd_today = get_yyyymmdd(TimeCurrent());
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(m_order.SelectByIndex(i))
         if(is_same_symbol(m_order.Comment(), BOT_SHORT_NM) && is_same_symbol(m_order.Symbol(), symbol))
           {
            string comment = m_order.Comment();
            string open_time = get_yyyymmdd(m_order.TimeSetup());

            if(is_same_symbol(comment, TREND_BUY))
              {
               count_order_buy+=1;
               if(global_min_entry_buy == 0 || global_min_entry_buy > m_order.PriceOpen())
                  global_min_entry_buy = m_order.PriceOpen();
              }

            if(is_same_symbol(comment, TREND_SEL))
              {
               count_order_sel+=1;
               if(global_max_entry_sel == 0 || global_max_entry_sel < m_order.PriceOpen())
                  global_max_entry_sel = m_order.PriceOpen();
              }

            if(open_time!=yyyymmdd_today)
              {
               Alert("Delete Order " + open_time + " " + symbol);
               m_trade.OrderDelete(m_order.Ticket());
              }
           }
//---------------------------------------------------------------------------------------------------------
     {
      global_count_buy = count_buy;
      global_count_sel = count_sel;

      if(count_buy > (int)GetGlobalVariable(MAX_L_BUY))
         SetGlobalVariable(MAX_L_BUY, (double)count_buy);
      if(profit_buy < GetGlobalVariable(MAX_DD_BUY))
        {
         SetGlobalVariable(MAX_DD_BUY, profit_buy);
         SetGlobalVariable(MAX_DD_DAY_BUY, get_current_yyyymmdd());
        }

      if(MathAbs(global_max_entry_buy - global_min_entry_buy) > GetGlobalVariable(MAX_AMP_BUY))
         SetGlobalVariable(MAX_AMP_BUY, MathAbs(global_max_entry_buy - global_min_entry_buy));
      if(MathAbs(global_max_entry_sel - global_min_entry_sel) > GetGlobalVariable(MAX_AMP_SEL))
         SetGlobalVariable(MAX_AMP_SEL, MathAbs(global_max_entry_sel - global_min_entry_sel));

      if(count_sel > (int)GetGlobalVariable(MAX_L_SEL))
         SetGlobalVariable(MAX_L_SEL, (double)count_sel);
      if(profit_sel < GetGlobalVariable(MAX_DD_SEL))
        {
         SetGlobalVariable(MAX_DD_SEL, profit_sel);
         SetGlobalVariable(MAX_DD_DAY_SEL, get_current_yyyymmdd());
        }

      if(profit_buy > GetGlobalVariable(MAX_TP_BUY))
         SetGlobalVariable(MAX_TP_BUY, profit_buy);
      if(profit_sel > GetGlobalVariable(MAX_TP_SEL))
         SetGlobalVariable(MAX_TP_SEL, profit_sel);
     }
//---------------------------------------------------------------------------------------------------------
   double min_range_bs = (global_min_entry_buy-global_max_entry_sel);
   double max_range_bs = (global_max_entry_buy-global_min_entry_sel);

   StringReplace(total_comment_buy,BOT_SHORT_NM,"");
   StringReplace(total_comment_sel,BOT_SHORT_NM,"");

   string comment_L001_buy = TREND_BUY + "_" + appendZero100(1);
   string comment_L002_buy = TREND_BUY + "_" + appendZero100(2);
   string comment_L003_buy = TREND_BUY + "_" + appendZero100(3);

   string comment_L001_sel = TREND_SEL + "_" + appendZero100(1);
   string comment_L002_sel = TREND_SEL + "_" + appendZero100(2);
   string comment_L003_sel = TREND_SEL + "_" + appendZero100(3);

   total_comment_buy = is_same_symbol(total_comment_buy,comment_L001_buy)? "(L1B) " + total_comment_buy:total_comment_buy;
   total_comment_sel = is_same_symbol(total_comment_sel,comment_L001_sel)? "(L1S) " + total_comment_sel:total_comment_sel;

   createButton("comment_buy",total_comment_buy,5,270,330,20,clrBlack,clrWhite,6);
   createButton("comment_sel",total_comment_sel,5,295,330,20,clrBlack,clrWhite,6);

   double next_buy = global_min_entry_buy-AMP_TRADE;
   double next_sel = global_max_entry_sel+AMP_TRADE;
   create_trend_line("NEXT_BUY",time,next_buy,time+TIME_OF_ONE_D1_CANDLE,next_buy,clrBlue,STYLE_SOLID,1);
   create_trend_line("NEXT_SEL",time,next_sel,time+TIME_OF_ONE_D1_CANDLE,next_sel,clrRed, STYLE_SOLID,1);

   double range_buy = global_max_entry_buy-global_min_entry_buy;
   double range_sel = global_max_entry_sel-global_min_entry_sel;

   double vol_recover_buy = MathMax(calc_volume_by_amp(symbol,AMP_TP_L1,MathAbs(profit_buy)),INIT_VOLUME);
   double vol_recover_sel = MathMax(calc_volume_by_amp(symbol,AMP_TP_L1,MathAbs(profit_sel)),INIT_VOLUME);

   string lblReBuy = "Range.B="+format_double_to_string(range_buy,digits-1)+" / "+(string)count_buy+"L " + MASK_RECOVER+(string)count_recover_buy + " Vol:" + format_double_to_string(vol_recover_buy,2);
   string lblReSel = "Range.S="+format_double_to_string(range_sel,digits-1)+" / "+(string)count_sel+"L " + MASK_RECOVER+(string)count_recover_sel + " Vol:" + format_double_to_string(vol_recover_sel,2);

   create_lable_simple("RANGE_BUY",lblReBuy,next_buy,clrBlack,time+TIME_OF_ONE_D1_CANDLE);
   create_lable_simple("RANGE_SEL",lblReSel,next_sel,clrBlack,time+TIME_OF_ONE_D1_CANDLE);
//---------------------------------------------------------------------------------------------------------
   if(count_order_buy>0 && count_buy<START_EXIT_L)
      CloseOrdersByTrend(symbol,TREND_BUY);

   if(count_order_sel>0 && count_sel<START_EXIT_L)
      CloseOrdersByTrend(symbol,TREND_SEL);
//---------------------------------------------------------------------------------------------------------
   if((profit_buy+profit_sel+FIXED_SL)<0)
     {
      ClosePositionByTrend(symbol,TREND_BUY);
      ClosePositionByTrend(symbol,TREND_SEL);
      Alert("STOP_LOSS OP_BUY   " + symbol + "    Profit:"+ (string)(int)(profit_buy+profit_sel) + "$");
      return;
     }

   if((count_heg_buy+count_heg_sel>0) && (global_profit>risk_1L))
     {
      ClosePositionByTrend(symbol,TREND_BUY);
      ClosePositionByTrend(symbol,TREND_SEL);
      Alert("DE_HEDGING   " + symbol + "    Profit:"+ (string)(int)(profit_buy+profit_sel) + "$");
      return;
     }
//---------------------------------------------------------------------------------------------------------
   if((count_heg_buy+count_heg_sel>0) && (global_profit>0))
     {
      ClosePositionByTrend(symbol,TREND_BUY);
      ClosePositionByTrend(symbol,TREND_SEL);
      return;
     }

   if(trend_wdh4 != "")
     {
      if(trend_wdh4 == TREND_BUY && (count_sel==1 || profit_sel>0))
        {
         CloseOrdersByTrend(symbol,TREND_SEL);
         return;
        }

      if(trend_wdh4 == TREND_SEL && (count_buy==1 || profit_buy>0))
        {
         CloseOrdersByTrend(symbol,TREND_BUY);
         return;
        }

      if(trend_wdh4 == TREND_BUY && count_heg_buy==0 && count_sel>0)
        {
         count_heg_buy+=1;
         string comment_buy = create_comment(MASK_HEGING,TREND_BUY,count_heg_buy);
         double vol = vol_sel;//calc_volume_by_amp(symbol,AMP_STOP,MathAbs(profit_sel));
         Open_Position(symbol,TREND_BUY,vol,0.0,0.0,comment_buy);
         return;
        }

      if(trend_wdh4 == TREND_SEL && count_heg_sel==0 && count_buy>0)
        {
         count_heg_sel+=1;
         string comment_sel = create_comment(MASK_HEGING,TREND_SEL,count_heg_sel);
         double vol = vol_buy;//calc_volume_by_amp(symbol,AMP_STOP,MathAbs(profit_sel));
         Open_Position(symbol,TREND_SEL,vol,0.0,0.0,comment_sel);
         return;
        }
     }
//---------------------------------------------------------------------------------------------------------
   double TP_BUY_L1 = ask+AMP_TP_L1;
   double TP_SEL_L1 = bid-AMP_TP_L1;

   if(ALLOW_NEW_CYCLE && IS_CYCLE_BUY && (count_buy==0))
     {
      count_buy = 1;
      string comment_buy = create_comment(MASK_NORMAL,TREND_BUY,count_buy);

      Open_Position(symbol,TREND_BUY,INIT_VOLUME,0.0,TP_BUY_L1,comment_buy);
      return;
     }

   if(ALLOW_NEW_CYCLE && IS_CYCLE_SEL && (count_sel==0))
     {
      count_sel = 1;
      string comment_sel = create_comment(MASK_NORMAL,TREND_SEL,count_sel);

      Open_Position(symbol,TREND_SEL,INIT_VOLUME,0.0,TP_SEL_L1,comment_sel);
      return;
     }
//---------------------------------------------------------------------------------------------------------
   if(count_buy>0)
     {
      if((global_min_entry_buy>0) && (global_min_entry_buy-AMP_TRADE>ask))
        {
         count_buy += 1;
         double TP_BUY = ask+AMP_TRADE*FIBO;
         double vol = calc_volume_by_fibo_dca(symbol,count_buy,FIBO);
         string comment_buy = create_comment(MASK_NORMAL,TREND_BUY,count_buy);

         bool opened_buy = Open_Position(symbol,TREND_BUY,vol,0.0,0.0,comment_buy);
         if(false)
           {
            if(count_buy>=START_EXIT_L)
              {
               count_buy+=1;
               vol = calc_volume_by_fibo_dca(symbol,count_buy,FIBO);
               comment_buy = create_comment(MASK_RECOVER,TREND_BUY,count_buy);

               m_trade.BuyLimit(vol,price_lowest_2d,symbol,0.0,TP_BUY,0,0,comment_buy);
              }

            ModifyTp(symbol,TREND_BUY,TREND_BUY,TP_BUY);
            return;
           }
        }

      if(profit_buy>risk_min)
        {
         if((count_buy>=MathMin(7,START_EXIT_L)) || (IS_CYCLE_BUY==false))
           {
            if(MathAbs(global_min_entry_buy-cur_price) > GetGlobalVariable(MAX_AMP_SOLVE_BUY))
               SetGlobalVariable(MAX_AMP_SOLVE_BUY, MathAbs(global_min_entry_buy-cur_price));

            ClosePositionByTrend(symbol,TREND_BUY);
            return;
           }
        }

      if(potential_profit_buy<=0)
        {
         if(last_tp_buy==0)
            last_tp_buy=ask+AMP_TRADE;

         ModifyTp(symbol,TREND_BUY,TREND_BUY,last_tp_buy+0.5);
         return;
        }
     }
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
   if(count_sel>0)
     {
      if((global_max_entry_sel>0) && (global_max_entry_sel+AMP_TRADE<bid))
        {
         count_sel += 1;
         double TP_SEL = bid-AMP_TRADE*FIBO;
         double vol = calc_volume_by_fibo_dca(symbol,count_sel,FIBO);
         string comment_sel = create_comment(MASK_NORMAL,TREND_SEL,count_sel);

         bool opened_sel = Open_Position(symbol,TREND_SEL,vol,0.0,0.0,comment_sel);
         if(false)
           {
            if(count_sel>=START_EXIT_L)
              {
               count_sel+=1;
               vol = calc_volume_by_fibo_dca(symbol,count_sel,FIBO);
               comment_sel = create_comment(MASK_RECOVER,TREND_SEL,count_sel);

               m_trade.SellLimit(vol,price_higest_2d,symbol,0.0,TP_SEL,0,0,comment_sel);
              }

            ModifyTp(symbol,TREND_SEL,TREND_SEL,TP_SEL);
            return;
           }
        }

      if(profit_sel>risk_min)
        {
         if((count_sel>=MathMin(7,START_EXIT_L)) || (IS_CYCLE_SEL==false))
           {
            if(MathAbs(global_max_entry_sel-cur_price) > GetGlobalVariable(MAX_AMP_SOLVE_SEL))
               SetGlobalVariable(MAX_AMP_SOLVE_SEL, MathAbs(global_max_entry_sel-cur_price));

            ClosePositionByTrend(symbol,TREND_SEL);
            return;
           }
        }

      if(potential_profit_sel<=0)
        {
         if(last_tp_sel==0)
            last_tp_sel=bid-AMP_TRADE;

         ModifyTp(symbol,TREND_SEL,TREND_SEL,last_tp_sel-0.5);
        }
     }
//---------------------------------------------------------------------------------------------------------
     {
      if(count_buy>0 && is_same_symbol(total_comment_buy,comment_L001_buy)==false)
        {
         ClosePositionByTrend(symbol,TREND_BUY);
         Alert("STOP_TRADE " + symbol + "  " + total_comment_buy);
         return;
        }

      if(count_sel>0 && is_same_symbol(total_comment_sel,comment_L001_sel)==false)
        {
         ClosePositionByTrend(symbol,TREND_SEL);
         Alert("STOP_TRADE " + symbol + "  " + total_comment_sel);
         return;
        }
     }
//---------------------------------------------------------------------------------------------------------
   double step_buy = 0.01;
   if(cur_price>0&&global_max_entry_buy>0)
      step_buy = NormalizeDouble(MathAbs(cur_price-global_max_entry_buy)/AMP_TRADE, 2);

   double step_sel = 0.01;
   if(cur_price>0&&global_min_entry_sel>0)
      step_sel = NormalizeDouble(MathAbs(cur_price-global_min_entry_sel)/AMP_TRADE, 2);

   if(is_cur_tab)
     {
      int BtnWidth = 250;
      int x_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS))-BtnWidth-10;
      int y_ref_btn = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));

      createButton(BtnCloseAll, "Close All: " + get_acc_profit_percent(), 5, 350, 200, 30, clrBlack, clrLightGray, 7);
      createButton(BtnClearChart, "Clear Chart", 5, y_ref_btn - 35, 180, 30, clrBlack, clrWhite, 7);

      //color clrColorTrendFollowing = IS_FOLLOW_TREND?clrLightGreen:clrLightGray;
      //string strLblTrendFollowing = "(Follow) " + trend_following + " " + (IS_FOLLOW_TREND?"ON":"OFF");
      //createButton(BtnTrendFollow, strLblTrendFollowing, x_ref_btn+50, (int)(y_ref_btn/2), 200, 20, clrBlack, clrColorTrendFollowing, 7);
      //if(trend_wdh4!="")
      //   ObjectSetString(0, BtnTrendFollow,OBJPROP_FONT,"Arial Bold");

      string strCountB = "";
      if(count_buy > 0)
         strCountB += "  L." + (string)count_buy + "B";
      if(count_heg_buy > 0)
         strCountB += "  Hg." + (string)count_heg_buy + " " + (string)vol_heg_buy;

      strCountB += (count_buy >= START_EXIT_L? " Ex":"");

      string strCountS = "";
      if(count_sel > 0)
         strCountS = "  L." + (string)count_sel + "S";
      if(count_heg_sel > 0)
         strCountB += "  Hg." + (string)count_heg_sel + " " + (string)vol_heg_sel;

      strCountS += (count_sel >= START_EXIT_L? " Ex":"");

      string stoc_main = "(" + format_double_to_string(AMP_TRAILING_STOP,digits-1)
                         + "/" +  format_double_to_string(AMP_TRADE,digits-1)
                         + "/" + format_double_to_string(AMP_STOP,digits-1) + ")";

      color clrNewCycleColorBuy = count_buy>0 ? clrLightGreen : clrLightGray;
      string lableBuy = tf + " L1 " + stoc_main + strCountB
                        + (vol_negertive_buy>0?" (Ne." + format_double_to_string(vol_negertive_buy,2) + ")":"")
                        + " Est: "+ format_double_to_string(potential_profit_buy,2) + "$";;

      string lblAutoBuy = (GetGlobalVariable(BtnAutoBuy+symbol)==AUTO_TRADE_ON?"(Global ON)":"(Global Off)") + " Buy " + format_double_to_string(moved,digits-2);
      createButton(BtnAutoBuy, lblAutoBuy, x_ref_btn+100, y_ref_btn-50,150, 30, clrBlack, IS_CYCLE_BUY?clrLightGreen:clrLightGray);
      createButton(BtnOneCycleBuy, lableBuy, x_ref_btn, y_ref_btn-80, BtnWidth, 20, clrBlack, clrNewCycleColorBuy);

      string lblProfitBuy = "";
      if(count_buy > 0)
         lblProfitBuy = last_comment_buy + " " + DoubleToString(vol_buy, 2) + " " + DoubleToString(profit_buy, 2) + "$";
      createButton(BtnTpPositiveBuy, lblProfitBuy, x_ref_btn, y_ref_btn-110, BtnWidth, 20, profit_buy>0?clrBlue:clrRed, clrWhite, 7);


      createButton(BtnDelLimitBuy, "Del.B", x_ref_btn+75, y_ref_btn-150, 45, 20, clrBlack, clrLightGray, 7);
      createButton(BtnSendLimitBuy, "Limit.5L.Buy." + format_double_to_string(AMP_TP_L1,digits-1), x_ref_btn+130, y_ref_btn-150, 120, 20, clrBlack, clrLightGray, 7);
      createButton(BtnSendLimitSel, "Limit.5L.Sel." + format_double_to_string(AMP_TP_L1,digits-1), x_ref_btn+130, 150, 120, 20, clrBlack, clrLightGray, 7);
      createButton(BtnDelLimitSel, "Del.S", x_ref_btn+75, 150, 45, 20, clrBlack, clrLightGray, 7);

      color clrNewCycleColorSel = count_sel>0 ? clrMistyRose : clrLightGray;
      string lableSel = tf + " L1 " + stoc_main + strCountS
                        + (vol_negertive_sel>0?" (Ne." + format_double_to_string(vol_negertive_sel,2) + ")":"")
                        + " Est: "+ format_double_to_string(potential_profit_sel,2) + "$";
      createButton(BtnOneCycleSel, lableSel, x_ref_btn, 80, BtnWidth, 20, clrBlack, clrNewCycleColorSel);

      string lblAutoSel = (GetGlobalVariable(BtnAutoSel+symbol)==AUTO_TRADE_ON?"(Global ON)":"(Global Off)") + " Sell " + format_double_to_string(moved,digits-2);
      createButton(BtnAutoSel, lblAutoSel, x_ref_btn+100, 40,150, 30, clrBlack, IS_CYCLE_SEL?clrLightGreen:clrLightGray);

      string lblProfitSel = "";
      if(count_sel > 0)
         lblProfitSel = last_comment_sel + " " + DoubleToString(vol_sel, 2) + " " + DoubleToString(profit_sel, 2) + "$";
      createButton(BtnTpPositiveSel, lblProfitSel, x_ref_btn, 110, BtnWidth, 20, profit_sel>0?clrBlue:clrRed, clrWhite, 7);
     }
  }
// Hàm kiểm tra xem symbol có cho phép mở lệnh không
bool IsMarketOpenForTrading(string symbol)
  {
// Kiểm tra xem symbol có hợp lệ không
   if(!SymbolSelect(symbol, true))
     {
      Print("Symbol is not valid or cannot be selected: ", symbol);
      return false;
     }

// Kiểm tra xem có cho phép giao dịch với symbol hay không
   if(!SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE))
     {
      Print("Trading is not allowed for the symbol: ", symbol);
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
double get_current_yyyymmdd()
  {
   MqlDateTime cur_time;
   TimeToStruct(TimeCurrent(), cur_time);

   string current_yyyymmdd = (string)cur_time.year +
                             StringFormat("%02d", cur_time.mon) +
                             StringFormat("%02d", cur_time.day);
   return (double)current_yyyymmdd;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_yyyymmdd(datetime time)
  {
   MqlDateTime cur_time;
   TimeToStruct(time, cur_time);

   string current_yyyymmdd = (string)cur_time.year +
                             StringFormat("%02d", cur_time.mon) +
                             StringFormat("%02d", cur_time.day);
   return current_yyyymmdd;
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

   string last_order_yyyymmdd = (string)odr_time.year + StringFormat("%02d", odr_time.mon) +
                                StringFormat("%02d", odr_time.day);

   string current_yyyymmdd = (string)cur_time.year +
                             StringFormat("%02d", cur_time.mon) +
                             StringFormat("%02d", cur_time.day);

   if(PERIOD_WAIT==PERIOD_D1)
     {
      if(last_order_yyyymmdd != current_yyyymmdd)
         return true;
     }

   int hround = 4;
   if(PERIOD_WAIT==PERIOD_H1)
      hround = 1;

   string last_order_time_str = last_order_yyyymmdd + StringFormat("%02d", (odr_time.hour/hround)*hround);

   string current_time_str = current_yyyymmdd + StringFormat("%02d", cur_time.hour);

   if(last_order_time_str != current_time_str)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_vn_hour()
  {
   int gmtOffset = 7;
   datetime vietnamTime = TimeGMT() + gmtOffset * 3600;
   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);
   int vietnamHour = dt.hour; //Tính giờ Việt Nam (GMT+7)

   return vietnamHour;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Schedule()
  {
   int ScheWidth = 20;

   int gmtOffset = 7;
   datetime vietnamTime = TimeGMT() + gmtOffset * 3600;
   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);
   int vietnamHour = dt.hour; //Tính giờ Việt Nam (GMT+7)

   string cur_HH = append1Zero(vietnamHour);
   if(vietnamHour==0)
      cur_HH = "24";
   if(vietnamHour==1)
      cur_HH = "25";

   string cur_Tx = GetCurrentWeekday();

   string shedule_t2 = (string)GetGlobalVariable(BtnScheduleT2);
   string shedule_t3 = (string)GetGlobalVariable(BtnScheduleT3);
   string shedule_t4 = (string)GetGlobalVariable(BtnScheduleT4);
   string shedule_t5 = (string)GetGlobalVariable(BtnScheduleT5);
   string shedule_t6 = (string)GetGlobalVariable(BtnScheduleT6);

   createButton("T2", "T2 " + append1Zero(GetDayOfWeek("T2")), 5+ScheWidth*(0),150,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T2")?clrLightGreen:clrWhite,6);
   createButton("T3", "T3 " + append1Zero(GetDayOfWeek("T3")), 5+ScheWidth*(0),170,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T3")?clrLightGreen:clrWhite,6);
   createButton("T4", "T4 " + append1Zero(GetDayOfWeek("T4")), 5+ScheWidth*(0),190,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T4")?clrLightGreen:clrWhite,6);
   createButton("T5", "T5 " + append1Zero(GetDayOfWeek("T5")), 5+ScheWidth*(0),210,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T5")?clrLightGreen:clrWhite,6);
   createButton("T6", "T6 " + append1Zero(GetDayOfWeek("T6")), 5+ScheWidth*(0),230,ScheWidth*2,18,clrBlack,is_same_symbol(cur_Tx,"T6")?clrLightGreen:clrWhite,6);

   int size = ArraySize(ARR_TIMES);
   for(int index = 0; index < size; index++)
     {
      int hh = ARR_TIMES[index];
      string str_hh = append1Zero(hh);
      string lable_hh = str_hh;
      if(str_hh=="24")
         lable_hh = "00";
      if(str_hh=="25")
         lable_hh = "01";

      color clrT2 = is_same_symbol(cur_Tx,"T2")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t2, str_hh)?clrLightGreen:clrLightGray;
      color clrT3 = is_same_symbol(cur_Tx,"T3")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t3, str_hh)?clrLightGreen:clrLightGray;
      color clrT4 = is_same_symbol(cur_Tx,"T4")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t4, str_hh)?clrLightGreen:clrLightGray;
      color clrT5 = is_same_symbol(cur_Tx,"T5")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t5, str_hh)?clrLightGreen:clrLightGray;
      color clrT6 = is_same_symbol(cur_Tx,"T6")&&is_same_symbol(cur_HH,str_hh)?clrYellow : is_same_symbol(shedule_t6, str_hh)?clrLightGreen:clrLightGray;

      createButton(BtnScheduleT2 + str_hh, lable_hh, 50+(ScheWidth+2)*(index),150,ScheWidth,18,clrBlack,clrT2,6);
      createButton(BtnScheduleT3 + str_hh, lable_hh, 50+(ScheWidth+2)*(index),170,ScheWidth,18,clrBlack,clrT3,6);
      createButton(BtnScheduleT4 + str_hh, lable_hh, 50+(ScheWidth+2)*(index),190,ScheWidth,18,clrBlack,clrT4,6);
      createButton(BtnScheduleT5 + str_hh, lable_hh, 50+(ScheWidth+2)*(index),210,ScheWidth,18,clrBlack,clrT5,6);
      createButton(BtnScheduleT6 + str_hh, lable_hh, 50+(ScheWidth+2)*(index),230,ScheWidth,18,clrBlack,clrT6,6);
     }

   if(is_economic_news())
     {
      string objName = "BtnSchedule"+cur_Tx+"_"+cur_HH;

      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
      ObjectSetString(0,  objName, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrYellowGreen);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//https://sslecal2.forexprostools.com/?columns=exc_flags,exc_currency,exc_importance,exc_actual,exc_forecast,exc_previous&category=_employment,_economicActivity,_inflation,_centralBanks,_confidenceIndex,_balance&features=datepicker,timezone,timeselector,filters&countries=5&importance=3&calType=week&timeZone=27&lang=52
bool is_economic_news()
  {
   int gmtOffset = 7;
   datetime vietnamTime = TimeGMT() + gmtOffset * 3600;
   MqlDateTime dt;
   TimeToStruct(vietnamTime, dt);
   int vietnamHour = dt.hour; //Tính giờ Việt Nam (GMT+7)

   if(2<=vietnamHour && vietnamHour<=12)
      return false;

   string cur_Tx = GetCurrentWeekday();
   string shedule_Tx = (string)GetGlobalVariable("BtnSchedule"+cur_Tx+"_");

   string cur_HH = append1Zero(vietnamHour);

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

   int current_day_of_week = STime.day_of_week;

// Dựa trên thứ hiện tại, trả về chuỗi tương ứng
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
   datetime current_time = TimeCurrent();

   MqlDateTime STime;
//datetime time_current=TimeCurrent();
//datetime time_local=TimeLocal();

   TimeToStruct(current_time,STime);
   int current_day_of_week = STime.day_of_week;  // Không truyền tham số

// Map giá trị string weekday thành số (1 = Thứ 2, 2 = Thứ 3, ..., 7 = Chủ Nhật)
   int target_day_of_week;

   if(weekday == "T2")
      target_day_of_week = 1;
   else
      if(weekday == "T3")
         target_day_of_week = 2;
      else
         if(weekday == "T4")
            target_day_of_week = 3;
         else
            if(weekday == "T5")
               target_day_of_week = 4;
            else
               if(weekday == "T6")
                  target_day_of_week = 5;
               else
                  if(weekday == "T7")
                     target_day_of_week = 6;
                  else
                     if(weekday == "CN")
                        target_day_of_week = 0;
                     else
                        return -1; // Trường hợp không hợp lệ

// Tạo cấu trúc thời gian hiện tại
   MqlDateTime current_time_struct;
   TimeToStruct(current_time, current_time_struct);

// Tính khoảng cách ngày giữa ngày hiện tại và ngày cần tìm
   int days_difference = target_day_of_week - current_day_of_week;

// Nếu ngày mục tiêu đã qua trong tuần này, lùi lại về tuần trước
   if(days_difference < 0)
      days_difference += 7;

// Lấy thời gian mục tiêu bằng cách cộng số ngày chênh lệch
   datetime target_date = current_time + days_difference * 86400; // 86400 = số giây trong 1 ngày

// Trả về ngày tương ứng
   MqlDateTime target_time_struct;
   TimeToStruct(target_date, target_time_struct);

   return target_time_struct.day; // Trả về ngày trong tháng
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
         return;
        }

      //BtnScheduleT2
      if(is_same_symbol(sparam,"BtnSchedule"))
        {
         string shedule_name = "BtnSchedule";
         if(is_same_symbol(sparam,BtnScheduleT2))
            shedule_name = BtnScheduleT2;
         if(is_same_symbol(sparam,BtnScheduleT3))
            shedule_name = BtnScheduleT3;
         if(is_same_symbol(sparam,BtnScheduleT4))
            shedule_name = BtnScheduleT4;
         if(is_same_symbol(sparam,BtnScheduleT5))
            shedule_name = BtnScheduleT5;
         if(is_same_symbol(sparam,BtnScheduleT6))
            shedule_name = BtnScheduleT6;

         int size = ArraySize(ARR_TIMES);
         string shedule_tx = (string)GetGlobalVariable(shedule_name);
         for(int index = 0; index < size; index++)
           {
            int hh = ARR_TIMES[index];

            string str_hh = append1Zero(hh);
            if(is_same_symbol(sparam,str_hh))
              {
               if(is_same_symbol(shedule_tx,str_hh))
                  StringReplace(shedule_tx,str_hh,"");
               else
                  shedule_tx += str_hh;
              }
           }

         SetGlobalVariable(shedule_name,(double)shedule_tx);

         Draw_Schedule();

         return;
        }

      if(is_same_symbol(sparam,BtnAutoBuy) || is_same_symbol(sparam,BtnAutoSel) || is_same_symbol(sparam,BtnTrendFollow))
        {
         bool AUTO_ENTRY = GetGlobalVariable(sparam+symbol) == AUTO_TRADE_ON;
         //string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         //string msg = sparam + symbol + " " + (string)AUTO_ENTRY + " -> " + (string)(!AUTO_ENTRY);
         //int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         //if(result == IDYES)
           {
            if(AUTO_ENTRY==AUTO_TRADE_ON)
               SetGlobalVariable(sparam+symbol,AUTO_TRADE_OFF);

            if(AUTO_ENTRY==AUTO_TRADE_OFF)
               SetGlobalVariable(sparam+symbol,AUTO_TRADE_ON);

            OpenTrade_XauUsd(symbol);
            return;
           }
        }

      if(is_same_symbol(sparam,BtnDelLimitBuy) || is_same_symbol(sparam,BtnDelLimitSel))
        {
         Print("The ", sparam," was clicked");

         for(int i = OrdersTotal() - 1; i >= 0; i--)
            if(m_order.SelectByIndex(i))
               if(is_same_symbol(Symbol(),m_order.Symbol()))
                 {
                  if(is_same_symbol(sparam,BtnDelLimitBuy) && is_same_symbol(m_order.Comment(),TREND_BUY))
                     m_trade.OrderDelete(m_order.Ticket());

                  if(is_same_symbol(sparam,BtnDelLimitSel) && is_same_symbol(m_order.Comment(),TREND_SEL))
                     m_trade.OrderDelete(m_order.Ticket());
                 }

        }

      if(is_same_symbol(sparam,BtnSendLimitBuy) || is_same_symbol(sparam,BtnSendLimitSel))
        {
         Print("The ", sparam," was clicked");

         int count_order_buy=0,count_order_sel=0;
         for(int i = OrdersTotal() - 1; i >= 0; i--)
            if(m_order.SelectByIndex(i))
               if(is_same_symbol(Symbol(),m_order.Symbol()))
                 {
                  if(is_same_symbol(m_order.Comment(),TREND_BUY))
                     count_order_buy += 1;

                  if(is_same_symbol(m_order.Comment(),TREND_SEL))
                     count_order_sel += 1;
                 }

         double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
         double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

         if(is_same_symbol(sparam,BtnSendLimitBuy))
           {
            for(int i=count_order_buy+1;i<=count_order_buy+5;i++)
              {
               double open_price = bid-AMP_TP_L1*i;
               m_trade.BuyLimit(INIT_VOLUME,open_price, Symbol(), 0.0, 0.0, 0, 0, MASK_LIMIT + "_"+TREND_BUY+"_" + appendZero100(i));
              }
           }

         if(is_same_symbol(sparam,BtnSendLimitSel))
           {
            for(int i=count_order_sel+1;i<=count_order_sel+5;i++)
              {
               double open_price = ask+AMP_TP_L1*i;
               m_trade.SellLimit(INIT_VOLUME,open_price, Symbol(), 0.0, 0.0, 0, 0, MASK_LIMIT + "_"+TREND_SEL+"_" + appendZero100(i));
              }
           }

        }

      if(sparam == BtnOneCycleBuy || sparam == BtnOneCycleSel)
        {
         //string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         //string msg = sparam + " " + buttonLabel;
         //int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         //if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");

            double amp_w1, amp_d1, amp_h4, amp_grid_L100;
            GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);
            double risk_1L = Risk_1L_By_Account_Balance();

            string trend = sparam == BtnOneCycleBuy ? TREND_BUY : sparam == BtnOneCycleSel ? TREND_SEL : "";

            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

            double tp = sparam == BtnOneCycleBuy ? ask+AMP_TP_L1 : sparam == BtnOneCycleSel ? bid-AMP_TP_L1 : 0.0;

            string comment = create_comment(MASK_MARKET, trend, 1);
            double vol = INIT_VOLUME;

            bool opened = Open_Position(symbol,trend,vol,0.0,tp,comment);

            return;
           }
        }

      if(sparam == BtnCloseAll)
        {
         string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         string msg = sparam + "  " + Symbol() + "  " + buttonLabel;
         int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");
            ClosePositionByTrend(symbol,TREND_BUY);
            ClosePositionByTrend(symbol,TREND_SEL);

            for(int i = 0; i < 10; i++)
               DeleteAllObjects();

            OpenTrade_XauUsd(symbol);
            return;
           }
        }
      //-----------------------------------------------------------------------
      if(sparam == BtnTpPositiveBuy || sparam == BtnTpPositiveSel)
        {
         //string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
         //string msg = sparam + "  " + Symbol() + "  " + buttonLabel;
         //int result = MessageBox(msg + "?", "Confirm", MB_YESNOCANCEL);
         //if(result == IDYES)
           {
            Print("The ", sparam," was clicked IDYES");

            if(sparam == BtnTpPositiveBuy)
               ClosePositivePosition(symbol, TREND_BUY);

            if(sparam == BtnTpPositiveSel)
               ClosePositivePosition(symbol, TREND_SEL);

            for(int i = 0; i < 10; i++)
               DeleteAllObjects();

            OnInit();
            return;
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
bool Open_Position(string symbol, string TREND, double volume, double sl, double tp, string comment)
  {
   bool has_commets = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Symbol(), symbol) && is_same_symbol(m_position.Comment(),BOT_SHORT_NM) && is_same_symbol(m_position.Comment(), comment))
            has_commets = true;

   if(has_commets)
     {
      Alert("Really exist: " + comment + "    " + symbol);
      return false;
     }

   int nextticket= 0, demm = 1;
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   while(nextticket<=0 && demm < 5)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int slippage = (int)MathAbs(ask-bid);
      double price = NormalizeDouble((bid + ask)/2, digits);

      if(TREND == TREND_BUY)
         nextticket = m_trade.Buy(volume,symbol,0.0,sl,tp,comment);
      if(TREND == TREND_SEL)
         nextticket = m_trade.Sell(volume,symbol,0.0,sl,tp,comment);

      if(nextticket > 0)
         return true;

      demm++;
      Sleep100(); //milliseconds
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
void create_label_simple(
   const string            name="Text",
   string                  label="Label",
   double                  price = 0,
   color                   clrColor = clrBlack,
   datetime time_to=0
)
  {
   ObjectDelete(0, name);
   if(time_to==0)
      time_to=TimeCurrent() + TIME_OF_ONE_H4_CANDLE;                   // anchor point time
   TextCreate(0,name, 0, time_to, price, label, clrColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_label(
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
void ModifyTp(string symbol, string trend_type, string TREND, double tp_price)
  {
   printf("ModifyTp: " + symbol);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Comment(), BOT_SHORT_NM) &&
            (is_same_symbol(m_position.Comment(),MASK_HEGING)==false) &&
            is_same_symbol(m_position.Symbol(), symbol) && is_same_symbol(m_position.Comment(),TREND) && is_same_symbol(m_position.TypeDescription(),trend_type))
           {
            bool is_same_tp = tp_price==m_position.TakeProfit();
            if(is_same_tp==false)
               is_same_tp=format_double_to_string(tp_price, digits-1) == format_double_to_string(m_position.TakeProfit(), digits-1) ;

            if(is_same_tp==false)
              {
               int demm = 1;
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

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(m_order.SelectByIndex(i))
         if(is_same_symbol(m_order.Comment(), BOT_SHORT_NM) &&
            (is_same_symbol(m_order.Comment(),MASK_HEGING)==false) &&
            is_same_symbol(m_order.Symbol(), symbol) && is_same_symbol(m_order.Comment(),TREND) && is_same_symbol(m_order.TypeDescription(),trend_type))
           {
            bool is_same_tp = tp_price==m_order.TakeProfit();
            if(is_same_tp==false)
               is_same_tp=format_double_to_string(tp_price, digits-1) == format_double_to_string(m_order.TakeProfit(), digits-1) ;

            if(is_same_tp==false)
              {
               int demm = 1;
               while(demm<5)
                 {
                  bool successful=m_trade.OrderModify(m_order.Ticket(),m_order.PriceOpen(), m_order.StopLoss(),tp_price,ORDER_TIME_DAY,0);
                  if(successful)
                     break;

                  demm+=1;
                  Sleep100();
                 }
              }
           }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositionByTrend(string symbol, string TREND)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Comment(), BOT_SHORT_NM) && is_same_symbol(m_position.Symbol(), symbol))
            if(is_same_symbol(m_position.Comment(),TREND))
              {
               int demm = 1;
               while(demm<5)
                 {
                  bool successful=m_trade.PositionClose(m_position.Ticket());
                  if(successful)
                     break;

                  demm++;
                  Sleep100();
                 }
              }

   CloseOrdersByTrend(symbol,TREND);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrdersByTrend(string symbol, string TREND)
  {
   if(OrdersTotal()==0)
      return;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(m_order.SelectByIndex(i))
         if(is_same_symbol(m_order.Comment(), BOT_SHORT_NM) && is_same_symbol(m_order.Symbol(), symbol))
            if(is_same_symbol(m_order.Comment(),TREND))
              {
               int demm = 1;
               while(demm<5)
                 {
                  bool successful=m_trade.OrderDelete(m_order.Ticket());
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
void Sleep100()
  {
   if(IS_DEBUG_MODE)
      return;

   Sleep(100);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositivePosition(string symbol, string TREND)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.Comment(), BOT_SHORT_NM) &&
            is_same_symbol(m_position.TypeDescription(), TREND) && is_same_symbol(m_position.Symbol(), symbol) && (m_position.Profit() > 0))
           {
            int demm = 1;
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

   if(IS_DEBUG_MODE)
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
double calc_volume_by_fibo_dca(string symbol, int trade_no, double F_I_B_O)
  {
   double vol = INIT_VOLUME;

   for(int i = 2; i <= trade_no; i++)
      vol = vol*F_I_B_O;

   if(vol < INIT_VOLUME)
      return  NormalizeDouble(INIT_VOLUME, 2);

   return NormalizeDouble(vol, 2);
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
double get_ATR(string symbol, ENUM_TIMEFRAMES PERIOD)
  {
   double ATR[];
   ArrayResize(ATR,50);
   int hATR = iATR(symbol,PERIOD,200);
//ArraySetAsSeries( ATR, true);
   CopyBuffer(hATR,0,0,40,ATR);    //take number of average value
//for ( int i=0 ; i<ArraySize(ATR) ; i++ ){
//    Print("the ATR " + i + " is " + ATR[i]);
   return ATR[1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_histogram(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   int m_handle_macd = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
   if(m_handle_macd == INVALID_HANDLE)
      return "";

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main,true);

   CopyBuffer(m_handle_macd, 0, 0, 2, m_buff_MACD_main);

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
bool is_hedging_time()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);

   int currentHour = vietnamDateTime.hour;
   if(22 <= currentHour || currentHour <= 3)
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
   ObjectsDeleteAll(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllArrows()
  {
   int total_objects = ObjectsTotal(0); // Lấy tổng số đối tượng trên biểu đồ
   for(int i = total_objects - 1; i >= 0; i--)
     {
      string obj_name = ObjectName(0, i);        // Lấy tên đối tượng
      int obj_type = (int)ObjectGetInteger(0, obj_name, OBJPROP_TYPE); // Lấy loại đối tượng
      if(obj_type == OBJ_ARROW)                  // Kiểm tra nếu đối tượng là OBJ_ARROW
        {
         ObjectDelete(0, obj_name);              // Xóa đối tượng
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_simple(
   const string            name="Text",
   string                  label="Label",
   double                  price = 0,
   color                   clrColor = clrBlack,
   datetime time_to=0
)
  {
   ObjectDelete(0, name);
   if(time_to==0)
      time_to=TimeCurrent();                   // anchor point time
   TextCreate(0,name, 0, time_to, price, " "+label, clrColor);
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
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcPotentialTradeProfit(string symbol, string TREND, double orderOpenPrice, double orderTakeProfitPrice, double orderLots)
  {
   if(orderTakeProfitPrice == 0)
      return 0;

   double   tradeTickValuePerLot    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);  //Loss/Gain for a 1 tick move with 1 lot
   double   tickValueBasedOnLots    = tradeTickValuePerLot * orderLots;
   double   priceDifference         = MathAbs(orderOpenPrice - orderTakeProfitPrice);
   int      pointsDifference        = (int)(priceDifference / Point());
   double   potentialProfit         = tickValueBasedOnLots * pointsDifference;

   if(TREND==TREND_BUY)
      potentialProfit         = orderTakeProfitPrice > orderOpenPrice ? potentialProfit : -potentialProfit;

   if(TREND==TREND_SEL)
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
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int index)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray,3,false);

   string result = candleArray[index].trend_heiken;

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Risk_1L_By_Account_Balance()
  {
   return AMP_TP_L1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Risk_Min()
  {
//double risk_1p = Risk_1L_By_Account_Balance();
//double risk_min = NormalizeDouble(risk_1p/5, 2);
   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_comment(string MASK_XX, string TRADING_TREND, int L)
  {
   string result = MASK_XX + BOT_SHORT_NM + TRADING_TREND + "_" + appendZero100(L);

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
   if(GlobalVariableCheck(BOT_SHORT_NM+varName))
      return GlobalVariableGet(BOT_SHORT_NM+varName);

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetGlobalVariable(string varName, double value)
  {
   GlobalVariableSet(BOT_SHORT_NM+varName, value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTodayProfitLoss()
  {
   double totalProfitLoss = 0.0; // Variable to store total profit or loss

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

//double swap = 0.0;
//for(int i = PositionsTotal() - 1; i >= 0; i--)
//  {
//   if(m_position.SelectByIndex(i))
//     {
//      swap += m_position.Swap();
//     }
//  } //for

   return PL;

//   double starting_balance = current_balance - PL;
//   double current_equity   = AccountInfoDouble(ACCOUNT_EQUITY);
//   totalProfitLoss = current_equity - starting_balance;
//
//   return totalProfitLoss; // Return the total profit or loss
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

   double risk_1L = Risk_1L_By_Account_Balance();

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = GetCurrentWeekday() + get_vntime() + AccountInfoString(ACCOUNT_NAME) + " " + BOT_SHORT_NM + " " + Symbol();
   str_comments += "    Risk: " + get_profit_percent(risk_1L);
   str_comments += "    Min: " + format_double_to_string(Risk_Min(), 2) + "$ Exit >= " + (string)START_EXIT_L + "L";
   str_comments += "    TP_L1: " + format_double_to_string(AMP_TP_L1, digits)
                   + "  DC: "+format_double_to_string(AMP_TRADE, digits)
                   + "  STOP: " + (string)AMP_STOP;
   str_comments += "\n";
   str_comments += "    Fixed_SL: " + get_profit_percent(FIXED_SL);

   str_comments += "    Closed(today): " + format_double_to_string(profit_today, 2) + "$"
                   + " (" + format_double_to_string(profit_today*25500/1000000, 2) + " tr)" + percent + "/" + (string) count_closed_today + "L";
   str_comments += "    Opening: " + (string)(int)PL + "$" + to_percent(PL)
                   + " (" + format_double_to_string(PL*25500/1000000, 2) + " tr)";

   str_comments += "\n";
   str_comments += "    " + (string)FIBO + "    ";
   for(int i=1; i<=7; i++)
      str_comments += "L"+(string)i + "("
                      + format_double_to_string(calc_volume_by_fibo_dca(symbol,i,FIBO), 2) + "/"
                      + format_double_to_string(AMP_TRADE*i,2) + ")"
                      + (i<7?"  ":"");

   str_comments += "\n";
//str_comments += "    Amp(H4): " + format_double_to_string(amp_h4, digits);
//str_comments += "    Amp(D1): " + format_double_to_string(amp_d1, digits);
//str_comments += "    Amp(W1): " + format_double_to_string(amp_w1, digits);

   str_comments += "\n";
   str_comments += "    m.L.B: " + AppendSpaces((string)(int)GetGlobalVariable(MAX_L_BUY), 3, false) + "L";
   str_comments += "    Day.B: " + AppendSpaces((string)(int)GetGlobalVariable(MAX_DD_DAY_BUY), 3, false);
   str_comments += "    m.A.Sv.B: " + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_AMP_SOLVE_BUY),2), 7, false);

   str_comments += "    m.Amp.B: " + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_AMP_BUY),2), 7, false);
   str_comments += "    m.TP.B: "  + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_TP_BUY), 2), 7, false) + "$";
   str_comments += "    m.DD.B: "  + AppendSpaces(get_profit_percent(GetGlobalVariable(MAX_DD_BUY)), 7, false) + "$ ";
   str_comments += "\n";
   str_comments += "    m.L.S: " + AppendSpaces((string)(int)GetGlobalVariable(MAX_L_SEL), 3, false) + "L";
   str_comments += "    Day.S: " + AppendSpaces((string)(int)GetGlobalVariable(MAX_DD_DAY_SEL), 3, false);
   str_comments += "    m.A.Sv.S: " + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_AMP_SOLVE_SEL),2), 7, false);

   str_comments += "    m.Amp.S: " + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_AMP_SEL),2), 7, false);
   str_comments += "    m.TP.S: "  + AppendSpaces(format_double_to_string(GetGlobalVariable(MAX_TP_SEL), 2), 7, false) + "$";
   str_comments += "    m.DD.S: "  + AppendSpaces(get_profit_percent(GetGlobalVariable(MAX_DD_SEL)), 7, false) + "$";

   return str_comments;
  }
//+------------------------------------------------------------------+
