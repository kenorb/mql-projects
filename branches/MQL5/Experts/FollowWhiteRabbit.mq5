//+------------------------------------------------------------------+
//|                                            FollowWhiteRabbit.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert includes                                                  |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh> //���������� ���������� ��� ���������� �������� ��������
#include <Trade\PositionInfo.mqh> //���������� ���������� ��� ��������� ���������� � ��������
#include <CompareDoubles.mqh>
#include <CIsNewBar.mqh>
#include <TradeManager\TradeManager.mqh>
//+------------------------------------------------------------------+
//| Expert variables                                                 |
//+------------------------------------------------------------------+
input ulong _magic = 1122;
input int SL = 150;
input int TP = 500;
input double _lot = 1;
input int historyDepth = 40;
input double supremacyPercent = 0.2;
input double profitPercent = 0.5;
input ENUM_TIMEFRAMES timeframe = PERIOD_M1;
input bool trailing = false;
input int minProfit = 250;
input int trailingStop = 150;
input int trailingStep = 5;

string my_symbol;                                       //���������� ��� �������� �������
ENUM_TIMEFRAMES my_timeframe;                                    //���������� ��� �������� �������� ����������
datetime history_start;

CTradeManager ctm(_magic);
MqlTick tick;

double takeProfit, stopLoss;
double high_buf[], low_buf[], close_buf[1], open_buf[1];
ENUM_POSITION_TYPE pos_type;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   my_symbol=Symbol();                 //�������� ������� ������ ������� ��� ���������� ������ ��������� ������ �� ���� �������
   history_start=TimeCurrent();        //--- �������� ����� ������� �������� ��� ��������� �������� �������
   
   //������������� ���������� ��� �������� ���_buf
   ArraySetAsSeries(low_buf, false);
   ArraySetAsSeries(high_buf, false);
   ArraySetAsSeries(close_buf, false);
   ArraySetAsSeries(open_buf, false);
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // ����������� ������������ ������� �� ������
   ArrayFree(low_buf);
   ArrayFree(high_buf);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //���������� ��� �������� ����������� ������ � ������� ��������
   int errLow = 0;                                                   
   int errHigh = 0;                                                   
   int errClose = 0;
   int errOpen = 0;
   int errMACD = 0;
   
   double sum = 0;
   double avgBar = 0;
   double lastBar = 0;
   int i = 0;   // �������
   long positionType;

   static CIsNewBar isNewBar;
   
   if(isNewBar.isNewBar(my_symbol, my_timeframe))
   {
    //�������� ������ �������� ������� � ������������ ������� ��� ���������� ������ � ����
    errLow = CopyLow(my_symbol, my_timeframe, 1, historyDepth, low_buf);
    errHigh = CopyHigh(my_symbol, my_timeframe, 1, historyDepth, high_buf);
    errClose = CopyClose(my_symbol, my_timeframe, 1, 1, close_buf);          
    errOpen = CopyOpen(my_symbol, my_timeframe, 1, 1, open_buf);
    
    if(errLow < 0 || errHigh < 0 || errClose < 0 || errOpen < 0)         //���� ���� ������
    {
     Alert("�� ������� ����������� ������ �� ������ �������� �������");  //�� ������� ��������� � ��� �� ������
     return;                                                                                      //� ������� �� �������
    }
    
    for(i = 0; i < historyDepth; i++)
    {
     //Print("high_buf[",i,"] = ", NormalizeDouble(high_buf[i],8), " low_buf[",i,"] = ", NormalizeDouble(low_buf[i],8));
     sum = sum + high_buf[i] - low_buf[i];  
    }
    avgBar = sum / historyDepth;
    //lastBar = high_buf[i-1] - low_buf[i-1];
    lastBar = MathAbs(open_buf[0] - close_buf[0]);
    
    if(GreatDoubles(lastBar, avgBar*(1 + supremacyPercent)))
    {
     PrintFormat("last bar = %.08f avg Bar = %.08f", NormalizeDouble(lastBar,8), NormalizeDouble(avgBar,8));
     double point = SymbolInfoDouble(my_symbol, SYMBOL_POINT);
     int digits = SymbolInfoInteger(my_symbol, SYMBOL_DIGITS);
     double vol=MathPow(10.0, digits); 
     if(LessDoubles(close_buf[0], open_buf[0])) // �� ��������� ���� close < open (��� ����)
     {
      pos_type = POSITION_TYPE_SELL;
     }
     if(GreatDoubles(close_buf[0], open_buf[0]))
     {
      pos_type = POSITION_TYPE_BUY;
     }
     takeProfit = NormalizeDouble(MathAbs(open_buf[0] - close_buf[0])*vol*(1 + profitPercent),0);
     //PrintFormat("(open-close) = %.05f, vol = %.05f, (1+profitpercent) = %.02f, takeprofit = %.01f"
     //           , MathAbs(open_buf[0] - close_buf[0]), vol, (1+profitPercent), takeProfit);
     ctm.OpenPosition(my_symbol, pos_type, _lot, SL, takeProfit, minProfit, trailingStop, trailingStep);
    }
   }
   
   if (trailing)
   {
    ctm.DoTrailing();
   }
   return;   
  }
//+------------------------------------------------------------------+

void OnTrade()
  {
   ctm.OnTrade(history_start);
  }