//+------------------------------------------------------------------+
//|                                              BEOVB_BUOVB_bar.mq4 |
//|                                  Copyright 2015, Iglakov Dmitry. |
//|                                               cjdmitri@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Iglakov Dmitry."
#property link      "cjdmitri@gmail.com"
#property version   "1.00"
#property strict

extern int     interval          = 25;                               //Interval
extern double  lot               = 0.1;                              //Lot Size
extern int     TP                = 400;                              //Take Profit
extern int     magic             = 962231;                           //Magic number
extern int     slippage          = 2;                                //Slippage
extern int     ExpDate           = 48;                               //Expiration Order (Minutes)
extern int     bar1size          = 900;                              //Bar 1 Size

double   buyPrice,//define BuyStop price
buyTP,      //Take Profit BuyStop
buySL,      //Stop Loss BuyStop
sellPrice,  //define SellStop price
sellTP,     //Take Profit SellStop
sellSL;     //Stop Loss SellStop

double   open1,//first candle Open price
open2,    //second candle Open price
close1,   //first candle Close price
close2,   //second candle Close price
low1,     //first candle Low price
low2,     //second candle Low price
high1,    //first candle High price
high2;    //second candle High price

datetime _ExpDate=0; // local variable to determine order's expiration time 
double _bar1size; // local variable required to eliminate a flat market
datetime timeBUOVB_BEOVB; // time of a bar when pattern orders were opened, to avoid re-opening
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double   _bid     = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits); //define a lower price 
   double   _ask     = NormalizeDouble(MarketInfo(Symbol(), MODE_ASK), Digits); //define an upper price
   double   _point   = MarketInfo(Symbol(), MODE_POINT);
//--- define prices of necessary bars
   open1        = NormalizeDouble(iOpen(Symbol(), Period(), 1), Digits);
   open2        = NormalizeDouble(iOpen(Symbol(), Period(), 2), Digits);
   close1       = NormalizeDouble(iClose(Symbol(), Period(), 1), Digits);
   close2       = NormalizeDouble(iClose(Symbol(), Period(), 2), Digits);
   low1         = NormalizeDouble(iLow(Symbol(), Period(), 1), Digits);
   low2         = NormalizeDouble(iLow(Symbol(), Period(), 2), Digits);
   high1        = NormalizeDouble(iHigh(Symbol(), Period(), 1), Digits);
   high2        = NormalizeDouble(iHigh(Symbol(), Period(), 2), Digits);

//--- Define prices for placing orders and stop orders
   buyPrice=NormalizeDouble(high1+interval*_point,Digits); //define a price of order placing with intervals
   buySL = NormalizeDouble(low1-interval * _point,Digits); //define a stop loss with interval
   buyTP=NormalizeDouble(buyPrice+TP*_point,Digits);       //define a take profit
   _ExpDate=TimeCurrent()+ExpDate*1*60;                   //a pending order expiration time calculation
//--- We also calculate sell orders
   sellPrice=NormalizeDouble(low1-interval*_point,Digits);
   sellSL=NormalizeDouble(high1+interval*_point,Digits);
   sellTP=NormalizeDouble(sellPrice-TP*_point,Digits);
//---
   _bar1size=NormalizeDouble(((high1-low1)/_point),0);
//--- Finding bearish pattern BEOVB
   if(timeBUOVB_BEOVB!=iTime(Symbol(),Period(),1) && // orders are not yet opened for this pattern 
      _bar1size>bar1size && //first bar is big enough not to consider a flat market
      low1 < low2 &&        //First bar's Low is below second bar's Low
      high1 > high2 &&      //First bar's High is above second bar's High
      close1 < open2 &&     //First bar's Close price is lower than second bar's Open price
      open1 > close1 &&     //First bar is a bearish bar
      open2 < close2)       //Second bar is a bullish bar
     {
      //--- we have described all conditions indicating that the first bar completely engulfs the second bar and is a bearish bar
      OrderOpenF(Symbol(),OP_SELLSTOP,lot,sellPrice,slippage,sellSL,sellTP,NULL,magic,_ExpDate,Blue);
      timeBUOVB_BEOVB=iTime(Symbol(),Period(),1); //indicate that orders are already placed on this pattern
     }
//--- Finding bullish pattern BUOVB
   if(timeBUOVB_BEOVB!=iTime(Symbol(),Period(),1) && // orders are not yet opened for this pattern 
      _bar1size>bar1size && //first bar is big enough not to consider a flat market
      low1 < low2 &&      //First bar's Low is below second bar's Low
      high1 > high2 &&    //First bar's High is above second bar's High
      close1 > open2 &&   //First bar's Close price is higher than second bar's Open price
      open1 < close1 &&   //First bar is a bullish bar
      open2 > close2)     //Second bar is a bearish bar
     {
      //--- we have described all conditions indicating that the first bar completely engulfs the second bar and is a bullish bar 
      OrderOpenF(Symbol(),OP_BUYSTOP,lot,buyPrice,slippage,buySL,buyTP,NULL,magic,_ExpDate,Blue);
      timeBUOVB_BEOVB=iTime(Symbol(),Period(),1); //indicate that orders are already placed on this pattern
     }
  }
//+---------------------------------------------------------------------------------------------------------------------+
//| The function opens or sets an order                                                                                 |
//| symbol      - symbol, at which a deal is performed.                                                                 |
//| cmd         - a deal Can have any value of trade operations.                                                        |
//| volume      - amount of lots.                                                                                       |
//| price       - Open price.                                                                                           |
//| slippage    - maximum price deviation for market buy or sell orders.         |
//| stoploss    - position close price when an unprofitability level is reached (0 if there is no unprofitability level)|
//| takeprofit  - position close price when a profitability level is reached (0 if there is no profitability level).    |
//| comment     - order comment. The last part of comment can be changed by the trade server.                           |
//| magic       - order magic number. Can be used as an identifier determined by user.                                  |
//| expiration  - pending order expiration time.                                                                        |
//| arrow_color - Opening arrow's color on the chart. If the parameter is missing or its value equals CLR_NONE          |
//|               then the opening arrow is not displayed on the chart.                                                 |
//+---------------------------------------------------------------------------------------------------------------------+
int OrderOpenF(string     OO_symbol,
               int        OO_cmd,
               double     OO_volume,
               double     OO_price,
               int        OO_slippage,
               double     OO_stoploss,
               double     OO_takeprofit,
               string     OO_comment,
               int        OO_magic,
               datetime   OO_expiration,
               color      OO_arrow_color)
  {
   int      result      = -1;    //result of opening an order
   int      Error       = 0;     //error when opening an order
   int      attempt     = 0;     //amount of performed attempts
   int      attemptMax  = 3;     //maximum amount of attempts
   bool     exit_loop   = false; //exit the loop
   string   lang=TerminalInfoString(TERMINAL_LANGUAGE);  //trading terminal language, for defining the language of the messages
   double   stopllvl=NormalizeDouble(MarketInfo(OO_symbol,MODE_STOPLEVEL)*MarketInfo(OO_symbol,MODE_POINT),Digits);  //minimum stop loss/ take profit level, in points
                                                                                                                     //the module provides a safe order opening. 
//--- checking stop orders for buying
   if(OO_cmd==OP_BUY || OO_cmd==OP_BUYLIMIT || OO_cmd==OP_BUYSTOP)
     {
      double tp = (OO_takeprofit - OO_price)/MarketInfo(OO_symbol, MODE_POINT);
      double sl = (OO_price - OO_stoploss)/MarketInfo(OO_symbol, MODE_POINT);
      if(tp>0 && tp<=stopllvl)
        {
         OO_takeprofit=OO_price+stopllvl+2*MarketInfo(OO_symbol,MODE_POINT);
        }
      if(sl>0 && sl<=stopllvl)
        {
         OO_stoploss=OO_price -(stopllvl+2*MarketInfo(OO_symbol,MODE_POINT));
        }
     }
//--- checking stop orders for selling
   if(OO_cmd==OP_SELL || OO_cmd==OP_SELLLIMIT || OO_cmd==OP_SELLSTOP)
     {
      double tp = (OO_price - OO_takeprofit)/MarketInfo(OO_symbol, MODE_POINT);
      double sl = (OO_stoploss - OO_price)/MarketInfo(OO_symbol, MODE_POINT);
      if(tp>0 && tp<=stopllvl)
        {
         OO_takeprofit=OO_price -(stopllvl+2*MarketInfo(OO_symbol,MODE_POINT));
        }
      if(sl>0 && sl<=stopllvl)
        {
         OO_stoploss=OO_price+stopllvl+2*MarketInfo(OO_symbol,MODE_POINT);
        }
     }
//--- while loop
   while(!exit_loop)
     {
      result=OrderSend(OO_symbol,OO_cmd,OO_volume,OO_price,OO_slippage,OO_stoploss,OO_takeprofit,OO_comment,OO_magic,OO_expiration,OO_arrow_color); //attempt to open an order using the specified parameters
      //--- if there is an error when opening an order
      if(result<0)
        {
         Error = GetLastError();                                     //assign a code to an error
         switch(Error)                                               //error enumeration
           {                                                         //order closing error enumeration and an attempt to fix them
            case  2:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;                                         //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  3:
               RefreshRates();
               exit_loop = true;                                     //exit while
               break;                                                //exit switch   
            case  4:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  5:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch   
            case  6:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(5000);                                       //3 seconds of delay
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case  8:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(7000);                                       //3 seconds of delay
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 64:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 65:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 128:
               Sleep(3000);
               RefreshRates();
               continue;                                             //exit switch
            case 129:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  Sleep(3000);                                       //3 seconds of delay
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 130:
               exit_loop=true;                                       //exit while
               break;
            case 131:
               exit_loop = true;                                     //exit while
               break;                                                //exit switch
            case 132:
               Sleep(10000);                                         //sleep for 10 seconds
               RefreshRates();                                       //update data
                                                                     //exit_loop = true;                                   //exit while
               break;                                                //exit switch
            case 133:
               exit_loop=true;                                       //exit while
               break;                                                //exit switch
            case 134:
               exit_loop=true;                                       //exit while
               break;                                                //exit switch
            case 135:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 136:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;                                 //define one more attempt
                  RefreshRates();
                  break;                                             //exit switch
                 }
               if(attempt==attemptMax)
                 {
                  attempt = 0;                                       //reset the amount of attempts to zero 
                  exit_loop = true;                                  //exit while
                  break;                                             //exit switch
                 }
            case 137:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(2000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 138:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(1000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 139:
               exit_loop=true;
               break;
            case 141:
               Sleep(5000);
               exit_loop=true;
               break;
            case 145:
               exit_loop=true;
               break;
            case 146:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  Sleep(2000);
                  RefreshRates();
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 147:
               if(attempt<attemptMax)
                 {
                  attempt=attempt+1;
                  OO_expiration=0;
                  break;
                 }
               if(attempt==attemptMax)
                 {
                  attempt=0;
                  exit_loop=true;
                  break;
                 }
            case 148:
               exit_loop=true;
               break;
            default:
               Print("Error: ",Error);
               exit_loop=true; //exit while 
               break;          //other options 
           }
        }
      //--- if no errors detected
      else
        {
         if(lang == "Russian") {Print ("The order is successfully opened. ", result);}
         if(lang == "English") {Print("The order is successfully opened.", result);}
         Error = 0;                                //reset the error code to zero
         break;                                    //exit while
                                                   //errorCount =0;                          //reset the amount of attempts to zero
        }
     }
   return(result);
  }
//+------------------------------------------------------------------+
