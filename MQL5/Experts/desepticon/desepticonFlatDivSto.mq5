//+------------------------------------------------------------------+
//|                                         desepticonFlatDivSto.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
 
#include <Lib CisNewBar.mqh>
#include <divergenceStochastic.mqh>
#include <TradeManager/TradeManager.mqh>

input ENUM_TIMEFRAMES eldTF = PERIOD_H1;
input ENUM_TIMEFRAMES jrTF = PERIOD_M5;

//��������� divSto indicator 
input int    kPeriod = 5;          // �-������ ����������
input int    dPeriod = 3;          // D-������ ����������
input int    slow  = 3;            // ����������� ����������. ��������� �������� �� 1 �� 3.
input int    top_level = 80;       // Top-level ���������
input int    bottom_level = 20;    // Bottom-level ����������

//��������� ������  
input double orderVolume = 0.1;         // ����� ������
input int    slOrder = 100;             // Stop Loss
input int    tpOrder = 100;             // Take Profit
input int    trStop = 100;              // Trailing Stop
input int    trStep = 100;              // Trailing Step
input int    minProfit = 250;           // Minimal Profit 
input bool   useLimitOrders = false;    // ������������ Limit ������
input int    limitPriceDifference = 50; // ������� ��� Limit �������
input bool   useStopOrders = false;     // ������������ Stop ������
input int    stopPriceDifference = 50;  // ������� ��� Stop �������

input bool   useTrailing = false;  // ������������ ��������
input bool   useJrEMAExit = false; // ����� �� �������� �� ���
input int    posLifeTime = 10;     // ����� �������� ������ � �����
input int    deltaPriceToEMA = 7;  // ������� ����� ����� � EMA
input int    periodEMA = 3;        // ������ ���������� EMA
input int    waitAfterDiv = 4;     // �������� ������ ����� ����������� (� �����)
//��������� PriceBased indicator
input int    historyDepth = 40;    // ������� ������� ��� �������
input int    bars=30;              // ������� ������ ����������

int    handleTrend;
int    handleEMA;
int    handleSTO;
double bufferTrend[];
double bufferEMA[];

datetime history_start;
ENUM_TM_POSITION_TYPE opBuy, opSell;
int priceDifference = 10;    // Price Difference

CisNewBar eldNewBar(eldTF);
CTradeManager tradeManager;

int OnInit()
{
 log_file.Write(LOG_DEBUG, StringFormat("%s �����������.", MakeFunctionPrefix(__FUNCTION__)));
 history_start = TimeCurrent();        //--- �������� ����� ������� �������� ��� ��������� �������� �������
 handleTrend =  iCustom(NULL, 0, "PriceBasedIndicator", historyDepth, bars);
 handleSTO = iStochastic(NULL, eldTF, kPeriod, dPeriod, slow, MODE_SMA, STO_CLOSECLOSE); 
 handleEMA = iMA(NULL, 0, periodEMA, 0, MODE_EMA, PRICE_CLOSE); 
   
 if (handleTrend == INVALID_HANDLE || handleEMA == INVALID_HANDLE)
 {
  log_file.Write(LOG_DEBUG, StringFormat("%s INVALID_HANDLE (handleTrend || handleEMA). Error(%d) = %s" 
                                        , MakeFunctionPrefix(__FUNCTION__), GetLastError(), ErrorDescription(GetLastError())));
  return(INIT_FAILED);
 }
 
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
  
 ArraySetAsSeries(bufferTrend, true);
 ArraySetAsSeries(bufferEMA, true);;
 ArrayResize(bufferTrend, 1, 3);
 ArrayResize(bufferEMA, 2, 6);
   
 return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
 IndicatorRelease(handleTrend);
 IndicatorRelease(handleSTO); 
 IndicatorRelease(handleEMA);
 ArrayFree(bufferTrend);
 ArrayFree(bufferEMA);
 log_file.Write(LOG_DEBUG, StringFormat("%s �������������.", MakeFunctionPrefix(__FUNCTION__)));
}

void OnTick()
{
 int totalPositions = PositionsTotal();
 int positionType = -1;
 static bool isProfit = false;
 static int  wait = 0;
 int order_direction = 0;
 double point = Point();
 double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
 double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
 
 isProfit = tradeManager.isMinProfit(_Symbol);
 //TO DO: ����� �� EMA
   
 if (eldNewBar.isNewBar() > 0)   //�� ������ ����� ���� �������� TF
 {
  if (!isProfit && positionType > -1 && TimeCurrent() - PositionGetInteger(POSITION_TIME) > posLifeTime*PeriodSeconds(eldTF))
  { //���� �� �������� minProfit �� ������ �����
     //close position 
  }
  
  if ((CopyBuffer( handleTrend, 4, 1, 1,  bufferTrend) < 0) ||
      (CopyBuffer(   handleEMA, 0, 0, 2,    bufferEMA) < 0) )   //�������� ������ �����������
  {
   log_file.Write(LOG_DEBUG, StringFormat("%s ������ ���������� ������. (divStoBuffer || bufferTrend || bufferEMA).Error(%d) = %s" 
                                          , MakeFunctionPrefix(__FUNCTION__), GetLastError(), ErrorDescription(GetLastError())));
   return;
  }
  
  wait++; 
  if (order_direction != 0)
  {
   if (wait > waitAfterDiv)
   {
    wait = 0;
    order_direction = 0;
   }
  }
  
  order_direction = divergenceSTOC(handleSTO, Symbol(), eldTF, top_level, bottom_level);
  
  if (bufferTrend[0] == 7)               //���� ����������� ������ FLAT  
  {
   log_file.Write(LOG_DEBUG, StringFormat("%s ����", MakeFunctionPrefix(__FUNCTION__)));   
   if (order_direction == 1)
   {
    log_file.Write(LOG_DEBUG, StringFormat("%s ����������� MACD 1", MakeFunctionPrefix(__FUNCTION__)));
    if(bid < bufferEMA[0] + deltaPriceToEMA*point)
    {
     tradeManager.OpenPosition(Symbol(), opBuy, orderVolume, slOrder, tpOrder, minProfit, trStop, trStep, priceDifference);
     wait = 0;
    }
   }
   if (order_direction == -1)
   {
    log_file.Write(LOG_DEBUG, StringFormat("%s ����������� MACD -1", MakeFunctionPrefix(__FUNCTION__)));
    if(ask > bufferEMA[0] - deltaPriceToEMA*point)
    {
     tradeManager.OpenPosition(Symbol(), opSell, orderVolume, slOrder, tpOrder, minProfit, trStop, trStep, priceDifference);
     wait = 0;
    }
   }
  } // close trend == FLAT
 } // close newBar
 if (useTrailing)
 {
  tradeManager.DoTrailing();
 }
} // close OnTick

void OnTrade()
{
 tradeManager.OnTrade(history_start);
}