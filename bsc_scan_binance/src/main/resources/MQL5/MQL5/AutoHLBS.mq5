//+------------------------------------------------------------------+
//|                                                     AutoHLBS.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;
COrderInfo     m_order;
CTrade         m_trade;
#define BOT_SHORT_NM    "(BS)"
const string TREND_BUY="BUY";
const string TREND_SEL="SELL";
datetime TIME_OF_ONE_H1_CANDLE=3600;
datetime TIME_OF_ONE_H4_CANDLE=14400;
datetime TIME_OF_ONE_D1_CANDLE=86400;
datetime TIME_OF_ONE_W1_CANDLE=604800;
// Khai báo các biến toàn cục
datetime lastOrderTime = 0;  // Thời gian của lệnh trước đó
int buyStopTicket = -1;      // Lệnh Buy Stop
int sellStopTicket = -1;     // Lệnh Sell Stop

// Các tham số cấu hình
double TP_Multiplier = 50;          // Lý thuyết TP: 10 lần spread
double TrailingStop_Multiplier = 50; // Trailing Stop: 10 lần spread

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   string symbol = Symbol();
   lastOrderTime = iTime(symbol,PERIOD_D1,0);  // Lưu thời gian của cây nến đầu tiên
   iMA(symbol, PERIOD_D1, 10, 0, MODE_SMA, PRICE_CLOSE);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime vietnamTime=TimeGMT()+7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(vietnamTime,time_struct);

   int cur_minute = time_struct.min;
   int last_checked_minute = (int)GetGlobalVariable("timer_three_min");
   SetGlobalVariable("timer_three_min", cur_minute);

   int time_reload = 15;
   if((cur_minute%time_reload==0) && (cur_minute!=last_checked_minute))
     {
      string symbol = Symbol();
      // Kiểm tra nếu là ngày mới (thời gian nến hiện tại không giống với thời gian lệnh trước đó)
      if(get_yyyymmdd(iTime(symbol,PERIOD_D1,0)) != get_yyyymmdd(lastOrderTime))
        {
         lastOrderTime = iTime(symbol,PERIOD_D1,0);  // Cập nhật thời gian ngày mới
         //CloseAllOrders();    // Đóng tất cả các lệnh cũ
         PlaceOrders(symbol);       // Đặt lệnh Buy Stop và Sell Stop cho ngày mới
        }

      // Kiểm tra Trailing Stop cho các lệnh đang mở
      CheckTrailingStop(symbol);
      SetTakeProfitForAllPositions(symbol, 13);

     }
  }
// Hàm để đặt lệnh Buy Stop và Sell Stop
void PlaceOrders(string symbol)
  {
   double spread = getSpread(symbol);
   double lowPrice = iLow(symbol, PERIOD_D1, 1)-spread;    // Đáy của nến ngày trước
   double highPrice = iHigh(symbol, PERIOD_D1, 1)+spread;  // Đỉnh của nến ngày trước

   string trend_histogam_w1;
   int count_histogram_w1;
   get_trend_count_by_histogram(trend_histogam_w1, count_histogram_w1, symbol,PERIOD_W1,6,12,9);

   string trend_histogam_d1;
   int count_histogram_d1;
   get_trend_count_by_histogram(trend_histogam_d1,count_histogram_d1,symbol,PERIOD_D1,6,12,9);

   string trend_by_ma10w = get_trend_by_ma(symbol,PERIOD_W1,10, 1);
   string trend_by_ma10d = get_trend_by_ma(symbol,PERIOD_D1,10, 1);

   create_lable_simple2(" WD", ".W: "+trend_histogam_w1+"."+ IntegerToString(count_histogram_w1)  +
                        " .D: "+trend_histogam_d1+"."+ IntegerToString(count_histogram_d1) +
                        " Ma: "+trend_by_ma10d, (lowPrice+highPrice)/2, clrWhite);

   CandleData arrHeiken_D1[];
   get_arr_heiken(symbol,PERIOD_D1,arrHeiken_D1,55,true,false);
   int sub_window, dheigh = 60;
   datetime temp_time;
   double temp_space, temp_high, temp_price1, temp_price2, temp_price3, temp_price0, temp_price4;
   int chart_width = (int)MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int)MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));
   string trend_histogram_heiken_d1="";
   if(ChartXYToTimePrice(0, chart_width/2, chart_heigh-dheigh*2, sub_window, temp_time, temp_price1))
      if(ChartXYToTimePrice(0, chart_width/2, chart_heigh-dheigh*3, sub_window, temp_time, temp_price2))
        {
         temp_high = temp_price2-temp_price1;
         temp_space = temp_high/5;
         temp_price3 = temp_price2+temp_high;
         temp_price0 = temp_price1-temp_high;
         temp_price4 = temp_price3+temp_high;

         int count_d1;
         DrawAndCountHistogram(arrHeiken_D1, trend_histogram_heiken_d1, count_d1, symbol, PERIOD_D1, true, temp_price1, temp_price2);

         if(is_same_symbol(trend_histogram_heiken_d1,TREND_SEL))
            ClosePositivePosition(symbol,TREND_BUY);

         if(is_same_symbol(trend_histogram_heiken_d1,TREND_BUY))
            ClosePositivePosition(symbol,TREND_SEL);
        }

// Lặp qua tất cả các vị thế mở
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))  // Lấy thông tin của từng vị thế
        {
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)m_position.Type();  // Loại vị thế (BUY hoặc SELL)

         if(type == POSITION_TYPE_BUY)
           {
            if(trend_histogam_d1==TREND_SEL || trend_by_ma10d==TREND_SEL || trend_by_ma10w == TREND_SEL || trend_histogam_w1 == TREND_SEL)
               m_trade.PositionClose(m_position.Ticket());
           }

         if(type == POSITION_TYPE_SELL)
           {
            if(trend_histogam_d1==TREND_BUY || trend_by_ma10d==TREND_BUY || trend_by_ma10w == TREND_BUY || trend_histogam_w1 == TREND_BUY)
               m_trade.PositionClose(m_position.Ticket());
           }
        }
     }


   if(trend_by_ma10w != trend_histogam_w1 ||
      trend_histogam_w1 != trend_histogam_d1 ||
      trend_histogam_d1 != trend_by_ma10d ||
      trend_histogram_heiken_d1 != trend_by_ma10d
// || PositionsTotal() > 0
//|| (arrHeiken_D1[1].count_ma10>10 && arrHeiken_D1[1].count_heiken>10)
     )
      return;

   double lotSize = 0.1;  // Kích thước lot, bạn có thể thay đổi tùy ý
   datetime expiration_time_48h = (datetime)(TimeCurrent()+3*24*3600);

// Đặt lệnh Buy Stop ở mức giá đỉnh của nến ngày
   if(trend_histogam_w1==TREND_BUY)
     {
      double entry = highPrice;
      double TP = 0;
      double SL = 0;//lowest;
      m_trade.BuyStop(lotSize,entry,symbol,SL,TP, ORDER_TIME_SPECIFIED, expiration_time_48h,"Buy_"+append1Zero(PositionsTotal()+1));
     }

// Đặt lệnh Sell Stop ở mức giá đáy của nến ngày
   if(trend_histogam_w1==TREND_SEL)
     {
      double entry = lowPrice;
      double TP = 0;
      double SL = 0;//higest;
      m_trade.SellStop(lotSize,entry,symbol,SL,TP, ORDER_TIME_SPECIFIED, expiration_time_48h,"Sell_"+append1Zero(PositionsTotal()+1));
     }

  }

// Hàm để đóng tất cả các lệnh đang mở
void CloseAllOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         m_trade.OrderDelete(m_order.Ticket());
        }
     }
  }
// Hàm thiết lập Take Profit (TP) cho tất cả các vị thế khi có đủ 7 vị thế mở
void SetTakeProfitForAllPositions(string symbol, int numberOfCandles)
  {
   if(PositionsTotal() >= numberOfCandles)   // Chỉ thực hiện nếu có đủ ít nhất 7 vị thế mở
     {
      double bestBuyTakeProfit = -1;
      double bestSellTakeProfit = -1;

      // Lấy giá trị TP tốt nhất trong 7 ngày cho BUY và SELL
      double lowest=DBL_MAX,higest=0.0;
      for(int idx=0; idx<=numberOfCandles; idx++)
        {
         double low=MathMin(iClose(symbol,PERIOD_D1,idx), iClose(symbol,PERIOD_D1,idx));
         double hig=MathMax(iClose(symbol,PERIOD_D1,idx), iClose(symbol,PERIOD_D1,idx));
         if(lowest>low)
            lowest=low;
         if(higest<hig)
            higest=hig;
        }
      bestBuyTakeProfit=higest;
      bestSellTakeProfit=lowest;

      // Lặp qua tất cả các vị thế mở
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(m_position.SelectByIndex(i))   // Lấy thông tin của từng vị thế
           {
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)m_position.Type();  // Loại vị thế (BUY hoặc SELL)

            // Cập nhật TakeProfit cho vị thế BUY
            if(type == POSITION_TYPE_BUY && bestBuyTakeProfit != -1)
              {
               m_trade.PositionModify(m_position.Ticket(), m_position.StopLoss(), bestBuyTakeProfit);
              }

            // Cập nhật TakeProfit cho vị thế SELL
            if(type == POSITION_TYPE_SELL && bestSellTakeProfit != -1)
              {
               m_trade.PositionModify(m_position.Ticket(), m_position.StopLoss(), bestSellTakeProfit);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositivePosition(string symbol,string TREND)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         if(is_same_symbol(m_position.TypeDescription(),TREND) && is_same_symbol(m_position.Symbol(),symbol))
           {
            if(m_position.Profit()>0)
              {
               int demm=1;
               while(demm<5)
                 {
                  bool successful=m_trade.PositionClose(m_position.Ticket());
                  if(successful)
                     break;

                  demm++;
                 }
              }
            else
              {
               m_trade.PositionModify(m_position.Ticket(), m_position.StopLoss(), m_position.PriceOpen());
              }
           }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTrailingStop(string symbol)
  {
   double spread = getSpread(symbol);  // Lấy spread của symbol hiện tại
   double bestBuyStopLoss = -1;        // Khởi tạo giá trị StopLoss tốt nhất cho các vị thế BUY
   double bestSellStopLoss = -1;       // Khởi tạo giá trị StopLoss tốt nhất cho các vị thế SELL

// Lặp qua tất cả các vị thế mở
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))  // Lấy thông tin của từng vị thế
        {
         double orderOpenPrice = m_position.PriceOpen();  // Giá mở vị thế
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)m_position.Type();  // Loại vị thế (BUY hoặc SELL)
         double bid = SymbolInfoDouble(symbol, SYMBOL_BID);  // Giá Bid
         double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);  // Giá Ask

         double currentPrice = (type == POSITION_TYPE_BUY) ? ask : bid;  // Giá hiện tại của thị trường (Buy hoặc Sell)
         double trailingStopDistance = spread * TrailingStop_Multiplier;  // Khoảng cách trailing stop

         // Đối với các vị thế BUY, tìm StopLoss tốt nhất
         if(type == POSITION_TYPE_BUY)
           {
            if(bestBuyStopLoss == -1 || m_position.StopLoss() > bestBuyStopLoss)  // Tìm StopLoss lớn nhất
              {
               bestBuyStopLoss = m_position.StopLoss();
              }

            // Nếu có lãi, di chuyển StopLoss lên
            //if(currentPrice - orderOpenPrice > trailingStopDistance)
            //  {
            //   double newStopLoss = currentPrice - trailingStopDistance;
            //   if(newStopLoss > m_position.StopLoss())  // Di chuyển StopLoss lên nếu có lãi
            //     {
            //      m_trade.PositionModify(m_position.Ticket(), newStopLoss, m_position.TakeProfit());
            //     }
            //  }
           }

         // Đối với các vị thế SELL, tìm StopLoss tốt nhất
         if(type == POSITION_TYPE_SELL)
           {
            if(bestSellStopLoss == -1 || m_position.StopLoss() < bestSellStopLoss)  // Tìm StopLoss nhỏ nhất
              {
               bestSellStopLoss = m_position.StopLoss();
              }

            // Nếu có lãi, di chuyển StopLoss xuống
            //if(orderOpenPrice - currentPrice > trailingStopDistance)
            //  {
            //   double newStopLoss = currentPrice + trailingStopDistance;
            //   if(newStopLoss < m_position.StopLoss())  // Di chuyển StopLoss xuống nếu có lãi
            //     {
            //      m_trade.PositionModify(m_position.Ticket(), newStopLoss, m_position.TakeProfit());
            //     }
            //  }
           }
        }
     }

// Sau khi duyệt qua tất cả các vị thế, thiết lập StopLoss tốt nhất cho tất cả các vị thế BUY và SELL
// Cập nhật StopLoss cho tất cả các vị thế BUY
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)m_position.Type();  // Loại vị thế
         if(type == POSITION_TYPE_BUY && bestBuyStopLoss != -1)
           {
            // Thiết lập StopLoss cho các vị thế BUY nếu có giá trị StopLoss tốt nhất
            m_trade.PositionModify(m_position.Ticket(), bestBuyStopLoss, m_position.TakeProfit());
           }

         if(type == POSITION_TYPE_SELL && bestSellStopLoss != -1)
           {
            // Thiết lập StopLoss cho các vị thế SELL nếu có giá trị StopLoss tốt nhất
            m_trade.PositionModify(m_position.Ticket(), bestSellStopLoss, m_position.TakeProfit());
           }
        }
     }
  }
//
//// Hàm kiểm tra và di chuyển Trailing Stop cho các lệnh đang có lãi
//void CheckTrailingStop(string symbol)
//  {
//   double spread = getSpread(symbol);
//   for(int i=PositionsTotal()-1; i>=0; i--)
//     {
//      if(m_position.SelectByIndex(i))
//        {
//         double orderOpenPrice = m_position.PriceOpen();
//         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)m_position.Type();
//         double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
//         double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
//
//         double currentPrice = (type == POSITION_TYPE_BUY) ? ask : bid;
//         double trailingStopDistance = spread * TrailingStop_Multiplier; // Xác định khoảng cách Trailing Stop dựa trên spread
//
//         if(type == POSITION_TYPE_BUY)
//           {
//            if(currentPrice - orderOpenPrice > trailingStopDistance)
//              {
//               double newStopLoss = currentPrice - trailingStopDistance;
//               if(newStopLoss > m_position.StopLoss())  // Di chuyển Stop Loss lên nếu có lãi
//                 {
//                  m_trade.PositionModify(m_position.Ticket(), newStopLoss, m_position.TakeProfit());
//                 }
//              }
//           }
//         else
//            if(type == POSITION_TYPE_SELL)
//              {
//               if(orderOpenPrice - currentPrice > trailingStopDistance)
//                 {
//                  double newStopLoss = currentPrice + trailingStopDistance;
//                  if(newStopLoss < m_position.StopLoss())  // Di chuyển Stop Loss xuống nếu có lãi
//                    {
//                     m_trade.PositionModify(m_position.Ticket(), newStopLoss, m_position.TakeProfit());
//                    }
//                 }
//              }
//        }
//     }
//  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }

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
double getSpread(string symbol)
  {
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double spread = MathAbs(ask-bid) ; // Spread của symbol
   return spread;
  }
// Hàm tính chiều cao trung bình của râu nến trong numberOfCandles nến ngày
double GetAverageWickHeight(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int numberOfCandles)
  {
   double totalUpperWick = 0;  // Tổng chiều cao của râu trên
   double totalLowerWick = 0;  // Tổng chiều cao của râu dưới
   double upperWick, lowerWick;

// Duyệt qua số lượng nến cần tính (numberOfCandles nến gần nhất)
   for(int i = 1; i <= numberOfCandles; i++)
     {
      // Lấy giá trị đỉnh, đáy, mở cửa và đóng cửa của nến
      double highPrice = iHigh(symbol, TIMEFRAME, i);  // Đỉnh của nến i
      double lowPrice = iLow(symbol, TIMEFRAME, i);    // Đáy của nến i
      double openPrice = iOpen(symbol, TIMEFRAME, i);   // Giá mở cửa của nến i
      double closePrice = iClose(symbol, TIMEFRAME, i); // Giá đóng cửa của nến i

      // Tính râu trên (râu trên là phần từ đỉnh đến mức giá cao hơn giữa open và close)
      if(closePrice > openPrice)  // Nến tăng
        {
         upperWick = highPrice - closePrice; // Râu trên là từ close đến high
        }
      else // Nến giảm
        {
         upperWick = highPrice - openPrice; // Râu trên là từ open đến high
        }

      // Tính râu dưới (râu dưới là phần từ đáy đến mức giá thấp hơn giữa open và close)
      if(closePrice > openPrice)  // Nến tăng
        {
         lowerWick = lowPrice - openPrice; // Râu dưới là từ open đến low
        }
      else // Nến giảm
        {
         lowerWick = lowPrice - closePrice; // Râu dưới là từ close đến low
        }

      // Cộng dồn râu trên và râu dưới vào tổng
      totalUpperWick += upperWick;
      totalLowerWick += lowerWick;
     }

// Tính chiều cao trung bình của râu trên và râu dưới
   double averageUpperWick = totalUpperWick / numberOfCandles;
   double averageLowerWick = totalLowerWick / numberOfCandles;

// Trả về tổng chiều cao trung bình của cả râu trên và râu dưới
   return averageUpperWick + averageLowerWick;
  }
// Hàm tính chiều cao trung bình của 10 nến
double GetAverageCandleHeight(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int numberOfCandles)
  {
   double totalHeight = 0;  // Biến lưu tổng chiều cao của các nến
   double candleHeight;

// Duyệt qua số lượng nến cần tính (10 nến gần nhất)
   for(int i = 1; i <= numberOfCandles; i++)
     {
      // Lấy giá trị đỉnh và đáy của nến
      double highPrice = iHigh(symbol, TIMEFRAME, i);  // Đỉnh của nến i
      double lowPrice = iLow(symbol, TIMEFRAME, i);    // Đáy của nến i

      // Tính chiều cao của nến (chênh lệch giữa đỉnh và đáy)
      candleHeight = highPrice - lowPrice;

      // Cộng dồn chiều cao vào tổng
      totalHeight += candleHeight;
     }

// Tính chiều cao trung bình
   double averageHeight = totalHeight / numberOfCandles;

   return averageHeight;  // Trả về chiều cao trung bình
  }

// Hàm để lấy chiều cao của nến dài nhất trong 10 ngày trước
double GetHighestCandleHeight(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int numberOfCandles = 10)
  {
   double highestHeight = 0;  // Biến lưu chiều cao nến dài nhất
   double candleHeight;

// Duyệt qua 10 ngày trước
   for(int i = 1; i <= numberOfCandles; i++)
     {
      // Lấy giá trị đỉnh và đáy của nến
      double highPrice = iHigh(symbol, TIMEFRAME, i);
      double lowPrice = iLow(symbol, TIMEFRAME, i);

      // Tính chiều cao của nến (chênh lệch giữa đỉnh và đáy)
      candleHeight = highPrice - lowPrice;

      // Kiểm tra nếu chiều cao của nến này lớn hơn nến dài nhất đã tìm được
      if(candleHeight > highestHeight)
        {
         highestHeight = candleHeight;
        }
     }

   return highestHeight;  // Trả về chiều cao của nến dài nhất
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
string get_trend_by_histogram(string symbol,ENUM_TIMEFRAMES timeframe, int fast_ema, int slow_ema, int signal)
  {
   int m_handle_macd=iMACD(symbol,timeframe,fast_ema,slow_ema,signal,PRICE_CLOSE); //,12,26,9
   if(m_handle_macd==INVALID_HANDLE)
      return "";

   double m_buff_MACD_main[];
   ArraySetAsSeries(m_buff_MACD_main,true);

   CopyBuffer(m_handle_macd,0,0,2,m_buff_MACD_main);

   double m_macd   =m_buff_MACD_main[0];
//double m_signal =m_buff_MACD_signal[0];

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
double cal_MA(double& closePrices[],int ma_index,int candle_no=1)
  {
   int count=0;
   double ma=0.0;
   int size = ArraySize(closePrices);
   for(int i=candle_no; i <= candle_no+ma_index; i++)
     {
      if(i<size)
        {
         count+=1;
         ma+=closePrices[i];
        }
     }
   if(count==0)
      return 0;

   ma /= count;

   return ma;
  }
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
      string trend_heiken_,int count_heiken_,
      double ma10_,string trend_by_ma10_,int count_ma10_,string trend_vector_ma10_,
      string trend_by_ma05_,string trend_ma03vs05_,int count_ma3_vs_ma5_,
      string trend_by_seq_102050_,double ma50_,string trend_by_seq_051020_,string trend_ma05vs10_,
      double lowest_,  double higest_,bool allow_trade_now_by_seq_051020_,bool allow_trade_now_by_seq_102050_,double ma20_,int count_ma20_,string trend_by_ma20_,double ma05_,string trend_by_ma50_, int count_ma50_)
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
//+------------------------------------------------------------------+
//|                                                                  |
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

      CandleData candle(pre_HaTime,pre_HaOpen,pre_HaHigh,pre_HaLow,pre_HaClose,pre_candle_trend,0,0,"",0,"","","",0,"",0,"","",0,0,false,false,0,0,"",0,"",0);
      candleArray[length+4]=candle;
     }


   for(int index=length+3; index>=0; index--)
     {
      CandleData pre_cancle=candleArray[index+1];

      datetime haTime=iTime(symbol,TIME_FRAME,index);
      double haClose=(iOpen(symbol,TIME_FRAME,index)+iClose(symbol,TIME_FRAME,index)+iHigh(symbol,TIME_FRAME,index)+iLow(symbol,TIME_FRAME,index)) / 4.0;
      double haOpen =(pre_cancle.open+pre_cancle.close) / 2.0;
      double haHigh =MathMax(MathMax(haOpen,haClose),iHigh(symbol,TIME_FRAME,index));
      double haLow  =MathMin(MathMin(haOpen,haClose), iLow(symbol,TIME_FRAME,index));
      string haTrend=haClose>=haOpen ? TREND_BUY : TREND_SEL;

      int count_heiken=1;
      for(int j=index+1; j<length; j++)
        {
         if(haTrend==candleArray[j].trend_heiken)
            count_heiken+=1;
         else
            break;
        }

      CandleData candle_x(haTime,haOpen,haHigh,haLow,haClose,haTrend,count_heiken,0,"",0,"","","",0,"",0,"","",0,0,false,false,0,0,"",0,"",0);
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

      double lowest_05_candles=0.0,higest_05_candles=0.0;
      for(int idx10=0; idx10<5; idx10++)
        {
         double low=candleArray[idx10].low;
         double hig=candleArray[idx10].high;
         if((idx10==0) || (lowest_05_candles==0) || (lowest_05_candles>low))
            lowest_05_candles=low;
         if((idx10==0) || (higest_05_candles==0) || (higest_05_candles<hig))
            higest_05_candles=hig;
        }

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
         string trend_ma03vs05=(ma03>ma05)? TREND_BUY : (ma03<ma05)? TREND_SEL : "";
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
         if(maLength>20 && index<=5)
           {
            ma20=cal_MA(closePrices,20,index);

            if(mid>ma05 && ma05>ma10 && ma10>ma20)
               trend_by_seq_051020 = TREND_BUY;
            if(mid<ma05 && ma05<ma10 && ma10<ma20)
               trend_by_seq_051020 = TREND_SEL;

            bool is_seq_buy = (mid>ma05 && mid>ma10 && mid>ma20);
            bool is_seq_sel = (mid<ma05 && mid<ma10 && mid<ma20);
            if(is_seq_buy || is_seq_sel)
              {
               if(lowest_05_candles<=ma20 && ma20<=higest_05_candles)
                 {
                  //                  string trend_cross = check_MACrossover(closePrices,10,20);
                  //                  if(trend_cross=="")
                  //                     trend_cross = check_MACrossover(closePrices,5,20);
                  //                  if(trend_cross=="")
                  //                     trend_cross = check_MACrossover(closePrices,5,10);
                  //
                  //                  if(is_seq_buy && is_same_symbol(trend_cross, TREND_BUY))
                  //                     allow_trade_now_by_seq_051020=true;
                  //
                  //                  if(is_seq_sel && is_same_symbol(trend_cross, TREND_SEL))
                  //                     allow_trade_now_by_seq_051020=true;
                 }
              }

            //CHECK_SEQ
            if(maLength>45)
              {
               ma50=cal_MA(closePrices,50,index);
               trend_by_ma50 =(mid>ma50) ? TREND_BUY : (mid<ma50) ? TREND_SEL : "";

               if(ma10>ma20 && ma20>ma50)
                 {
                  trend_by_seq_102050=TREND_BUY;

                  if(lowest_05_candles<=ma50 && ma50<=higest_05_candles)
                     allow_trade_now_by_seq_102050=true;
                 }

               if(ma10<ma20 && ma20<ma50)
                 {
                  trend_by_seq_102050=TREND_SEL;

                  if(lowest_05_candles<=ma50 && ma50<=higest_05_candles)
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
                             ,trend_by_ma05,trend_ma03vs05,count_ma3_vs_ma5,trend_by_seq_102050,ma50,trend_by_seq_051020,trend_ma05vs10,lowest,higest,allow_trade_now_by_seq_051020,allow_trade_now_by_seq_102050
                             ,ma20,count_ma20,trend_by_ma20,ma05,trend_by_ma50, count_ma50);

         candleArray[index]=candle_x;
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
   datetime vietnamTime = TimeGMT()+7 * 3600;
   string str_date_time = TimeToString(vietnamTime,TIME_MINUTES);
   string vntime = "("+str_date_time+")";
   return vntime;
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
string append1Zero(int trade_no)
  {
   if(trade_no<10)
      return "0"+(string) trade_no;

   return (string) trade_no;
  }//+------------------------------------------------------------------+
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
   string name_new=BOT_SHORT_NM+name;

   ObjectDelete(0,name_new);
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
   ObjectDelete(0,name);
   if(time_to==0)
      time_to=TimeCurrent()+TIME_OF_ONE_H4_CANDLE;                   // anchor point time
   TextCreate(0,name,sub_windows,time_to,price,label,clrColor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DrawAndCountHistogram(CandleData &candleArray[], string &trend_histogram_, int &count_
                             , string symbol, ENUM_TIMEFRAMES TF, bool allow_draw=false, double price_from=50000, double price_to=60000)
  {
   double closeArray[];
   datetime timeFrArr[];
   int size = ArraySize(candleArray);
   ArrayResize(closeArray, size);
   ArrayResize(timeFrArr, size);

//datetime shift = iTime(symbol, PERIOD_CURRENT, 1)-iTime(symbol, PERIOD_CURRENT, 2);
   string prefix = "Histogram"+get_time_frame_name(TF);

   for(int i = 0; i < size-10; i++)
     {
      closeArray[i] = candleArray[i].close;
      timeFrArr[i] = iTime(symbol, PERIOD_CURRENT, i);
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

// Xác định giá trị min/max cho scale
// Tìm min/max cho scale
   double minVal = FindMinValue(macdValues);
   minVal = MathMin(minVal, MathMin(FindMinValue(signalValues), FindMinValue(histogramValues)));

   double maxVal = FindMaxValue(macdValues);
   maxVal = MathMax(maxVal, MathMax(FindMaxValue(signalValues), FindMaxValue(histogramValues)));

   double mid = (price_from + price_to) / 2.0;

   string trendArrs[];
   string trend_macd="";
   for(int i = MathMin(n-26,20); i > 0; i--)
     {
      if(macdValues[i] == EMPTY_VALUE || signalValues[i] == EMPTY_VALUE)
         continue;

      double scaled_macd = scaleValue(macdValues[i], minVal, maxVal, price_from, price_to);
      double scaled_signal = scaleValue(signalValues[i], minVal, maxVal, price_from, price_to);
      double scaled_hist = mid+scaled_macd-scaled_signal;

      if(allow_draw)
        {
         color clrColor = mid>scaled_hist?clrFireBrick:clrTeal;
         string hist_name = prefix + "Hist_" + append1Zero(i);

         if(i<20)
            create_trend_line(hist_name,timeFrArr[i],mid,timeFrArr[i],scaled_hist,clrColor,STYLE_SOLID,3);
         create_trend_line(hist_name+"_zero_", timeFrArr[i], mid, timeFrArr[i-1], mid, clrColor, STYLE_SOLID,2);
        }

      int idx = ArraySize(trendArrs);
      ArrayResize(trendArrs,idx+1);
      trendArrs[idx]=mid>scaled_hist?TREND_SEL:TREND_BUY;
      trend_macd=macdValues[i]>0?TREND_BUY:TREND_SEL;
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

   if(allow_draw && false)
      for(int i = ArraySize(countArr)-1; i >=0 ; i--)
        {
         string hist_name = prefix + "Hist_Count_" + IntegerToString(i);
         color clrColor = trendArrs[i]==TREND_SEL?clrRed:clrBlue;
         create_label_simple(hist_name, "  "+IntegerToString(countArr[i]), mid,clrColor, timeFrArr[i]);
        }

   if(ArraySize(countArr) > 0)
     {
      trend_macd="." + getShortName(macdValues[1]>0?TREND_BUY:macdValues[1]<0?TREND_SEL:"");
      trend_histogram_ = trendArrs[1];
      count_ = countArr[1];

      string Histogram = trend_macd+"."+trend_histogram_+"_"+(string)countArr[1];

      if(countArr[0]>=20)
         Histogram = trend_histogram_+">"+(string)countArr[1];


      Histogram+="."+getShortName(trend_macd);

      color clrColor = trend_histogram_==TREND_SEL?clrRed:clrBlue;
      if(allow_draw)
         create_label_simple("lblHistogram_"+get_time_frame_name(TF),get_time_frame_name(TF)+" "+Histogram,mid,clrColor,timeFrArr[0]);

      return Histogram;
     }

   trend_histogram_ = "";
   count_ = 20;
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
