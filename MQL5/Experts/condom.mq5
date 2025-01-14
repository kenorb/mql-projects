//+------------------------------------------------------------------+
//|                                                       condom.mq5 |
//|                                              Copyright 2013, GIA |
//|                                             http://www.saita.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, GIA"
#property link      "http://www.saita.net"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert includes                                                  |
//+------------------------------------------------------------------+
#include <CompareDoubles.mqh>
#include <Lib CisNewBar.mqh>
#include <TradeManager\TradeManager.mqh> //���������� ���������� ��� ���������� �������� ��������
#include <CLog.mqh>
//#include <Graph\Graph.mqh>
//+------------------------------------------------------------------+
//| Expert variables                                                 |
//+------------------------------------------------------------------+
//input ulong _magic = 1122;
input int SL = 150;
input int TP = 500;
input double lot = 1;
input int historyDepth = 40;
input ENUM_TRAILING_TYPE trailingType = TRAILING_TYPE_USUAL;
input int minProfit = 250;
input int trailingStop = 150;
input int trailingStep = 5;
input int spread = 30;
input bool tradeOnTrend = false;

input bool useLimitOrders = false;
input int limitPriceDifference = 20;
input bool useStopOrders = false;
input int stopPriceDifference = 20;

string symbol;                               //���������� ��� �������� �������
ENUM_TIMEFRAMES timeframe;
datetime history_start;

CTradeManager ctm();
MqlTick tick;

int  handlePBI;
double  high_buf[], low_buf[], close_buf[2];
ENUM_TM_POSITION_TYPE opBuy, opSell;
int priceDifference;

double globalMax;
double globalMin;
bool waitForSell;
bool waitForBuy;

SPositionInfo pos_info;
STrailing trailing;

double pbiBuf[];     // ����� PBI

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   symbol=Symbol();                 //�������� ������� ������ ������� ��� ���������� ������ ��������� ������ �� ���� �������
   timeframe = Period();
   history_start=TimeCurrent();     //--- �������� ����� ������� �������� ��� ��������� �������� �������
   
   // ���� ����� ��� ��������� PBI      
   //if (trailingType == TRAILING_TYPE_PBI)
   // {
    // ������� ����� PBI
    handlePBI = iCustom(_Symbol,_Period,"PriceBasedIndicator");
    if (handlePBI == INVALID_HANDLE)
    {
     Print("������ ������������� �������� Condom. �� ������� ������� ����� PriceBasedIndicator");
     return (INIT_FAILED);        
    }      
   // }  
   pos_info.volume            = lot;
   pos_info.expiration        = 0;
   trailing.trailingType      = trailingType;
   trailing.minProfit         = minProfit;
   trailing.trailingStop      = trailingStop;
   trailing.trailingStep      = trailingStep;     
   trailing.handleForTrailing = handlePBI; 
   if (useLimitOrders)
   {
    opBuy = OP_BUYLIMIT;
    opSell = OP_SELLLIMIT;
    priceDifference = limitPriceDifference;
   }
   else if (useStopOrders)
        {
         opBuy = OP_BUYSTOP;
         opSell = OP_SELLSTOP;
         priceDifference = stopPriceDifference;
        }
        else
        {
         opBuy = OP_BUY;
         opSell = OP_SELL;
         priceDifference = 0;
        }
   
   //������������� ���������� ��� �������� ���_buf
   ArraySetAsSeries(low_buf, false);
   ArraySetAsSeries(high_buf, false);

   globalMax = 0;
   globalMin = 0;
   waitForSell = false;
   waitForBuy = false;
   
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
   // ����������� ������ ����������� 
   IndicatorRelease(handlePBI);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   ctm.OnTick();
   ctm.DoTrailing();
   //���������� ��� �������� ����������� ������ � ������� ��������
   int errLow = 0;                                                   
   int errHigh = 0;                                                   
   int errClose = 0;
   int errMACD = 0;
   int diff;
   static CisNewBar isNewBar(symbol, timeframe);
   
   if(isNewBar.isNewBar() > 0)
   {
    //�������� ������ �������� ������� � ������������ ������� ��� ���������� ������ � ����
    errLow=CopyLow(symbol, timeframe, 2, historyDepth, low_buf); // (0 - ���. ���, 1 - ����. �����. 2 - �������� �����.)
    errHigh=CopyHigh(symbol, timeframe, 2, historyDepth, high_buf); // (0 - ���. ���, 1 - ����. �����. 2 - �������� �����.)
    errClose=CopyClose(symbol, timeframe, 1, 2, close_buf); // (0 - ���. ���, �������� 2 �����. ����)
             
    if(errLow < 0 || errHigh < 0 || errClose < 0)                         //���� ���� ������
    {
     Alert("�� ������� ����������� ������ �� ������ �������� �������");  //�� ������� ��������� � ��� �� ������
     return;                                                                  //� ������� �� �������
    }

    globalMax = high_buf[ArrayMaximum(high_buf)];
    globalMin = low_buf[ArrayMinimum(low_buf)];
    
    if(LessDoubles(close_buf[1], globalMin)) // ��������� Close(0 - ������, 1 - ������, �.� �� ��� � ���������) ���� ����������� ��������
    {
     waitForSell = false;
     waitForBuy = true;
    }
    
    if(GreatDoubles(close_buf[1], globalMax)) // ��������� Close(0 - ������, 1 - ������, �.� �� ��� � ���������) ���� ����������� ���������
    {
     waitForBuy = false;
     waitForSell = true;
    }
   }
   if(!SymbolInfoTick(Symbol(),tick))
   {
    Alert("SymbolInfoTick() failed, error = ",GetLastError());
    return;
   }     
      
   if (waitForBuy)
   { 
    // ���� ������� ����������� ����� PBI
    if (CopyBuffer(handlePBI,4,0,1,pbiBuf) == 1)
    {
     // Comment("���� = ",int(pbiBuf[0]));
     if (GreatDoubles(tick.ask, close_buf[0]) && GreatDoubles(tick.ask, close_buf[1]) && int(pbiBuf[0]) == 7  )  
     {  
      diff = MathAbs((globalMin - tick.ask)/Point());    
      Comment("DIFF = ",diff); 
      pos_info.type = opBuy;
      pos_info.sl = diff;       
      pos_info.tp = TP;
      pos_info.priceDifference = priceDifference;       
      if (ctm.OpenUniquePosition(symbol, timeframe, pos_info, trailing, spread))
      {
       waitForBuy = false;
       waitForSell = false;
      }
     }
    }
   } 

   if (waitForSell)
   { 
    // ���� ������� ����������� ����� PBI
    if (CopyBuffer(handlePBI,4,0,1,pbiBuf) == 1)
     {   
     // Comment("���� = ",int(pbiBuf[0]));     
      if (LessDoubles(tick.bid, close_buf[0]) && LessDoubles(tick.bid, close_buf[1]) && int(pbiBuf[0]) == 7  )
    {
         diff = MathAbs((tick.bid - globalMax)/Point());  
         Comment("DIFF = ",diff);                   
     pos_info.type = opSell;
         pos_info.sl = diff;
         pos_info.tp = TP;
     pos_info.priceDifference = priceDifference;      
     if (ctm.OpenUniquePosition(symbol, timeframe, pos_info, trailing, spread))
     {
      waitForBuy = false;
      waitForSell = false;
     }
    }
    }   
   }
   return;   
  }
//+------------------------------------------------------------------+

void OnTrade()
  {
   ctm.OnTrade(history_start);
  }

