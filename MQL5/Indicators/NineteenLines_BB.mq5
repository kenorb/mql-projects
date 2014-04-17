//+------------------------------------------------------------------+
//|                                                NineteenLines.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 36
#property indicator_plots   0

#include <ExtrLine\CExtremumCalc_NE.mqh>
#include <ExtrLine\HLine.mqh>
#include <Lib CisNewBar.mqh>

 input int    period_ATR_channel = 100;   //������ ATR ��� ������
 input double percent_ATR_channel = 0.03; //������ ������ ������ � ��������� �� ATR
 input double precentageATR_price = 1;    //�������� ATR ��� ������ ����������

 input bool  show_Extr_MN  = false;
 input color color_Extr_MN = clrRed;
 input bool  show_Extr_W1  = false;
 input color color_Extr_W1 = clrOrange;
 input bool  show_Extr_D1  = false;
 input color color_Extr_D1 = clrYellow;
 input bool  show_Extr_H4  = false;
 input color color_Extr_H4 = clrBlue;
 input bool  show_Extr_H1  = false;
 input color color_Extr_H1 = clrAqua;
 input bool  show_Price_D1  = false;
 input color color_Price_D1 = clrDarkKhaki;

 CExtremumCalc calcMN (Symbol(), PERIOD_MN1, precentageATR_price, period_ATR_channel, percent_ATR_channel);
 CExtremumCalc calcW1 (Symbol(),  PERIOD_W1, precentageATR_price, period_ATR_channel, percent_ATR_channel);
 CExtremumCalc calcD1 (Symbol(),  PERIOD_D1, precentageATR_price, period_ATR_channel, percent_ATR_channel);
 CExtremumCalc calcH4 (Symbol(),  PERIOD_H4, precentageATR_price, period_ATR_channel, percent_ATR_channel);
 CExtremumCalc calcH1 (Symbol(),  PERIOD_H1, precentageATR_price, period_ATR_channel, percent_ATR_channel);

 SExtremum estructMN[3];
 SExtremum estructW1[3];
 SExtremum estructD1[3];
 SExtremum estructH4[3];
 SExtremum estructH1[3];
 SExtremum pstructD1[4];
 
 double Extr_MN_Buffer1[];
 double Extr_MN_Buffer2[];
 double Extr_MN_Buffer3[];
 double  ATR_MN_Buffer1[];
 double  ATR_MN_Buffer2[];
 double  ATR_MN_Buffer3[]; 
 double Extr_W1_Buffer1[];
 double Extr_W1_Buffer2[];
 double Extr_W1_Buffer3[];
 double  ATR_W1_Buffer1[];
 double  ATR_W1_Buffer2[];
 double  ATR_W1_Buffer3[];
 double Extr_D1_Buffer1[];
 double Extr_D1_Buffer2[];
 double Extr_D1_Buffer3[];
 double  ATR_D1_Buffer1[];
 double  ATR_D1_Buffer2[];
 double  ATR_D1_Buffer3[];
 double Extr_H4_Buffer1[];
 double Extr_H4_Buffer2[];
 double Extr_H4_Buffer3[];
 double  ATR_H4_Buffer1[];
 double  ATR_H4_Buffer2[];
 double  ATR_H4_Buffer3[];
 double Extr_H1_Buffer1[];
 double Extr_H1_Buffer2[];
 double Extr_H1_Buffer3[];
 double  ATR_H1_Buffer1[];
 double  ATR_H1_Buffer2[];
 double  ATR_H1_Buffer3[];
 double Price_D1_Buffer1[];
 double Price_D1_Buffer2[];
 double Price_D1_Buffer3[];
 double Price_D1_Buffer4[];
 double   ATR_D1_Buffer [];
 
 CisNewBar barMN(Symbol(), PERIOD_MN1);
 CisNewBar barW1(Symbol(), PERIOD_W1);
 CisNewBar barD1(Symbol(), PERIOD_D1);
 CisNewBar barH4(Symbol(), PERIOD_H4);
 CisNewBar barH1(Symbol(), PERIOD_H1);
 
 int ATR_D1_handle;
 double tmp_buffer_ATR[];
 
 bool series_order = true;
 //+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
 SetInfoTabel();
 PrintFormat("INITIALIZATION");
 
 SetIndexBuffer( 0, Extr_MN_Buffer1, INDICATOR_DATA);
 SetIndexBuffer( 1,  ATR_MN_Buffer1, INDICATOR_DATA);
 SetIndexBuffer( 2, Extr_MN_Buffer2, INDICATOR_DATA);
 SetIndexBuffer( 3,  ATR_MN_Buffer2, INDICATOR_DATA);
 SetIndexBuffer( 4, Extr_MN_Buffer3, INDICATOR_DATA);
 SetIndexBuffer( 5,  ATR_MN_Buffer3, INDICATOR_DATA);
 SetIndexBuffer( 6, Extr_W1_Buffer1, INDICATOR_DATA);
 SetIndexBuffer( 7,  ATR_W1_Buffer1, INDICATOR_DATA);
 SetIndexBuffer( 8, Extr_W1_Buffer2, INDICATOR_DATA);
 SetIndexBuffer( 9,  ATR_W1_Buffer2, INDICATOR_DATA);
 SetIndexBuffer(10, Extr_W1_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(11,  ATR_W1_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(12, Extr_D1_Buffer1, INDICATOR_DATA);
 SetIndexBuffer(13,  ATR_D1_Buffer1, INDICATOR_DATA);
 SetIndexBuffer(14, Extr_D1_Buffer2, INDICATOR_DATA);
 SetIndexBuffer(15,  ATR_D1_Buffer2, INDICATOR_DATA);
 SetIndexBuffer(16, Extr_D1_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(17,  ATR_D1_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(18, Extr_H4_Buffer1, INDICATOR_DATA);
 SetIndexBuffer(19,  ATR_H4_Buffer1, INDICATOR_DATA);
 SetIndexBuffer(20, Extr_H4_Buffer2, INDICATOR_DATA);
 SetIndexBuffer(21,  ATR_H4_Buffer2, INDICATOR_DATA);
 SetIndexBuffer(22, Extr_H4_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(23,  ATR_H4_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(24, Extr_H1_Buffer1, INDICATOR_DATA);
 SetIndexBuffer(25,  ATR_H1_Buffer1, INDICATOR_DATA);
 SetIndexBuffer(26, Extr_H1_Buffer2, INDICATOR_DATA);
 SetIndexBuffer(27,  ATR_H1_Buffer2, INDICATOR_DATA);
 SetIndexBuffer(28, Extr_H1_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(29,  ATR_H1_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(30, Price_D1_Buffer1, INDICATOR_DATA);
 SetIndexBuffer(31, Price_D1_Buffer2, INDICATOR_DATA);
 SetIndexBuffer(32, Price_D1_Buffer3, INDICATOR_DATA);
 SetIndexBuffer(33, Price_D1_Buffer4, INDICATOR_DATA);
 SetIndexBuffer(34,   ATR_D1_Buffer , INDICATOR_DATA);
 
 ArrayInitialize(Extr_MN_Buffer1,  0);
 ArrayInitialize(Extr_MN_Buffer2,  0);
 ArrayInitialize(Extr_MN_Buffer3,  0);
 ArrayInitialize( ATR_MN_Buffer1,  0);
 ArrayInitialize( ATR_MN_Buffer2,  0);
 ArrayInitialize( ATR_MN_Buffer3,  0);
 ArrayInitialize(Extr_W1_Buffer1,  0);
 ArrayInitialize(Extr_W1_Buffer2,  0);
 ArrayInitialize(Extr_W1_Buffer3,  0);
 ArrayInitialize( ATR_W1_Buffer1,  0);
 ArrayInitialize( ATR_W1_Buffer2,  0);
 ArrayInitialize( ATR_W1_Buffer3,  0);
 ArrayInitialize(Extr_D1_Buffer1,  0);
 ArrayInitialize(Extr_D1_Buffer2,  0);
 ArrayInitialize(Extr_D1_Buffer3,  0);
 ArrayInitialize( ATR_D1_Buffer1,  0);
 ArrayInitialize( ATR_D1_Buffer2,  0);
 ArrayInitialize( ATR_D1_Buffer3,  0);
 ArrayInitialize(Extr_H4_Buffer1,  0);
 ArrayInitialize(Extr_H4_Buffer2,  0);
 ArrayInitialize(Extr_H4_Buffer3,  0);
 ArrayInitialize( ATR_H4_Buffer1,  0);
 ArrayInitialize( ATR_H4_Buffer2,  0);
 ArrayInitialize( ATR_H4_Buffer3,  0);
 ArrayInitialize(Extr_H1_Buffer1,  0);
 ArrayInitialize(Extr_H1_Buffer2,  0);
 ArrayInitialize(Extr_H1_Buffer3,  0);
 ArrayInitialize( ATR_H1_Buffer1,  0);
 ArrayInitialize( ATR_H1_Buffer2,  0);
 ArrayInitialize( ATR_H1_Buffer3,  0);
 ArrayInitialize(Price_D1_Buffer1, 0);
 ArrayInitialize(Price_D1_Buffer2, 0);
 ArrayInitialize(Price_D1_Buffer3, 0);
 ArrayInitialize(Price_D1_Buffer4, 0);
 ArrayInitialize(  ATR_D1_Buffer , 0);
 
 ArraySetAsSeries(Extr_MN_Buffer1,  series_order);
 ArraySetAsSeries(Extr_MN_Buffer2,  series_order);
 ArraySetAsSeries(Extr_MN_Buffer3,  series_order);
 ArraySetAsSeries( ATR_MN_Buffer1,  series_order);
 ArraySetAsSeries( ATR_MN_Buffer2,  series_order);
 ArraySetAsSeries( ATR_MN_Buffer3,  series_order);
 ArraySetAsSeries(Extr_W1_Buffer1,  series_order);
 ArraySetAsSeries(Extr_W1_Buffer2,  series_order);
 ArraySetAsSeries(Extr_W1_Buffer3,  series_order);
 ArraySetAsSeries( ATR_W1_Buffer1,  series_order);
 ArraySetAsSeries( ATR_W1_Buffer2,  series_order);
 ArraySetAsSeries( ATR_W1_Buffer3,  series_order);
 ArraySetAsSeries(Extr_D1_Buffer1,  series_order);
 ArraySetAsSeries(Extr_D1_Buffer2,  series_order);
 ArraySetAsSeries(Extr_D1_Buffer3,  series_order);
 ArraySetAsSeries( ATR_D1_Buffer1,  series_order);
 ArraySetAsSeries( ATR_D1_Buffer2,  series_order);
 ArraySetAsSeries( ATR_D1_Buffer3,  series_order);
 ArraySetAsSeries(Extr_H4_Buffer1,  series_order);
 ArraySetAsSeries(Extr_H4_Buffer2,  series_order);
 ArraySetAsSeries(Extr_H4_Buffer3,  series_order);
 ArraySetAsSeries( ATR_H4_Buffer1,  series_order);
 ArraySetAsSeries( ATR_H4_Buffer2,  series_order);
 ArraySetAsSeries( ATR_H4_Buffer3,  series_order);
 ArraySetAsSeries(Extr_H1_Buffer1,  series_order);
 ArraySetAsSeries(Extr_H1_Buffer2,  series_order);
 ArraySetAsSeries(Extr_H1_Buffer3,  series_order);
 ArraySetAsSeries( ATR_H1_Buffer1,  series_order);
 ArraySetAsSeries( ATR_H1_Buffer2,  series_order);
 ArraySetAsSeries( ATR_H1_Buffer3,  series_order);
 ArraySetAsSeries(Price_D1_Buffer1, series_order);
 ArraySetAsSeries(Price_D1_Buffer2, series_order);
 ArraySetAsSeries(Price_D1_Buffer3, series_order);
 ArraySetAsSeries(Price_D1_Buffer4, series_order);
 ArraySetAsSeries(  ATR_D1_Buffer , series_order);
 
 ATR_D1_handle = iATR(Symbol(), PERIOD_D1, period_ATR_channel);
 
 if(show_Extr_MN) CreateExtrLines (estructMN, PERIOD_MN1, color_Extr_MN);
 if(show_Extr_W1) CreateExtrLines (estructW1, PERIOD_W1 , color_Extr_W1);
 if(show_Extr_D1) CreateExtrLines (estructD1, PERIOD_D1 , color_Extr_D1);
 if(show_Extr_H4) CreateExtrLines (estructH4, PERIOD_H4 , color_Extr_H4);
 if(show_Extr_H1) CreateExtrLines (estructH1, PERIOD_H1 , color_Extr_H1);
 if(show_Price_D1)CreatePriceLines(color_Price_D1); 
 
//---
 return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
 IndicatorRelease(ATR_D1_handle);
 //-------MN-LEVEL
 ArrayFree(Extr_MN_Buffer1);
 ArrayFree(Extr_MN_Buffer2);
 ArrayFree(Extr_MN_Buffer3);
 ArrayFree( ATR_MN_Buffer1);
 ArrayFree( ATR_MN_Buffer2);
 ArrayFree( ATR_MN_Buffer3);
 //-------W1-LEVEL
 ArrayFree(Extr_W1_Buffer1);
 ArrayFree(Extr_W1_Buffer2);
 ArrayFree(Extr_W1_Buffer3);
 ArrayFree( ATR_W1_Buffer1);
 ArrayFree( ATR_W1_Buffer2);
 ArrayFree( ATR_W1_Buffer3);
 //-------D1-LEVEL
 ArrayFree(Extr_D1_Buffer1);
 ArrayFree(Extr_D1_Buffer2);
 ArrayFree(Extr_D1_Buffer3);
 ArrayFree( ATR_D1_Buffer1);
 ArrayFree( ATR_D1_Buffer2);
 ArrayFree( ATR_D1_Buffer3);
 //-------H4-LEVEL
 ArrayFree(Extr_H4_Buffer1);
 ArrayFree(Extr_H4_Buffer2);
 ArrayFree(Extr_H4_Buffer3);
 ArrayFree( ATR_H4_Buffer1);
 ArrayFree( ATR_H4_Buffer2);
 ArrayFree( ATR_H4_Buffer3);
 //-------H1-LEVEL
 ArrayFree(Extr_H1_Buffer1);
 ArrayFree(Extr_H1_Buffer2);
 ArrayFree(Extr_H1_Buffer3);
 ArrayFree( ATR_H1_Buffer1);
 ArrayFree( ATR_H1_Buffer2);
 ArrayFree( ATR_H1_Buffer3);
 //-------D1-LEVEL-PRICE
 ArrayFree(Price_D1_Buffer1);
 ArrayFree(Price_D1_Buffer2);
 ArrayFree(Price_D1_Buffer3);
 ArrayFree(Price_D1_Buffer4);
 ArrayFree(  ATR_D1_Buffer );
  
 if(show_Extr_MN) DeleteExtrLines (PERIOD_MN1);
 if(show_Extr_W1) DeleteExtrLines (PERIOD_W1);
 if(show_Extr_D1) DeleteExtrLines (PERIOD_D1);
 if(show_Extr_H4) DeleteExtrLines (PERIOD_H4);
 if(show_Extr_H1) DeleteExtrLines (PERIOD_H1);
 if(show_Price_D1)DeletePriceLines(PERIOD_D1);
 DeleteInfoTabel();
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   bool load = FillATRBuffer();
 
   if(load)
   {
    if(prev_calculated == 0)
    {
     ArraySetAsSeries(open , series_order);
     ArraySetAsSeries(high , series_order);
     ArraySetAsSeries(low  , series_order);
     ArraySetAsSeries(close, series_order);
     ArraySetAsSeries(time , series_order);
     
     calcMN.SetStartDayPrice(close[rates_total-1]);
     calcW1.SetStartDayPrice(close[rates_total-1]);
     calcD1.SetStartDayPrice(close[rates_total-1]);
     calcH4.SetStartDayPrice(close[rates_total-1]);
     calcH1.SetStartDayPrice(close[rates_total-1]);
     
     for(int i = rates_total-2-period_ATR_channel; i > 0; i--)  //rates_total-2 �.�. ���� ��������� � i+1 ��������
     {
      PrintFormat("Calc for %s", TimeToString(time[i]));
      CalcExtr(calcMN, estructMN, time[i]);
      CalcExtr(calcW1, estructW1, time[i]);
      CalcExtr(calcD1, estructD1, time[i]);
      CalcExtr(calcH4, estructH4, time[i]);
      CalcExtr(calcH1, estructH1, time[i]);
      
      Extr_MN_Buffer1[i] = estructMN[0].price;
       ATR_MN_Buffer1[i] = estructMN[0].channel;
      Extr_MN_Buffer2[i] = estructMN[1].price;
       ATR_MN_Buffer2[i] = estructMN[1].channel;
      Extr_MN_Buffer3[i] = estructMN[2].price;
       ATR_MN_Buffer3[i] = estructMN[2].channel;
      Extr_W1_Buffer1[i] = estructW1[0].price;
       ATR_W1_Buffer1[i] = estructW1[0].channel;
      Extr_W1_Buffer2[i] = estructW1[1].price;
       ATR_W1_Buffer2[i] = estructW1[1].channel;
      Extr_W1_Buffer3[i] = estructW1[2].price;
       ATR_W1_Buffer3[i] = estructW1[2].channel;
      Extr_D1_Buffer1[i] = estructD1[0].price;
       ATR_D1_Buffer1[i] = estructD1[0].channel;
      Extr_D1_Buffer2[i] = estructD1[1].price;
       ATR_D1_Buffer2[i] = estructD1[1].channel;
      Extr_D1_Buffer3[i] = estructD1[2].price;
       ATR_D1_Buffer3[i] = estructD1[2].channel;
      Extr_H4_Buffer1[i] = estructH4[0].price;
       ATR_H4_Buffer1[i] = estructH4[0].channel;
      Extr_H4_Buffer2[i] = estructH4[1].price;
       ATR_H4_Buffer2[i] = estructH4[1].channel;
      Extr_H4_Buffer3[i] = estructH4[2].price;
       ATR_H4_Buffer3[i] = estructH4[2].channel;
      Extr_H1_Buffer1[i] = estructH1[0].price;
       ATR_H1_Buffer1[i] = estructH1[0].channel;
      Extr_H1_Buffer2[i] = estructH1[1].price;
       ATR_H1_Buffer2[i] = estructH1[1].channel;
      Extr_H1_Buffer3[i] = estructH1[2].price;
       ATR_H1_Buffer3[i] = estructH1[2].channel;
      Price_D1_Buffer1[i] = open [i+1];
      Price_D1_Buffer2[i] = high [i+1];
      Price_D1_Buffer3[i] = low  [i+1];
      Price_D1_Buffer4[i] = close[i+1];
      CopyBuffer(ATR_D1_handle, 0, i+1, 1, tmp_buffer_ATR);
        ATR_D1_Buffer [i] = (tmp_buffer_ATR[0]*percent_ATR_channel)/2;
     }
     
     if(show_Extr_MN) MoveExtrLines (estructMN, PERIOD_MN1);
     if(show_Extr_W1) MoveExtrLines (estructW1, PERIOD_W1 ); 
     if(show_Extr_D1) MoveExtrLines (estructD1, PERIOD_D1 );
     if(show_Extr_H4) MoveExtrLines (estructH4, PERIOD_H4 );
     if(show_Extr_H1) MoveExtrLines (estructH1, PERIOD_H1 );
     if(show_Price_D1)MovePriceLines(); 
    }//end prev_calculated == 0
    else
    {
     for(int i = rates_total - prev_calculated; i >= 0; i--)
     {      
      Extr_MN_Buffer1[i] = estructMN[0].price;
       ATR_MN_Buffer1[i] = estructMN[0].channel;
      Extr_MN_Buffer2[i] = estructMN[1].price;
       ATR_MN_Buffer2[i] = estructMN[1].channel;
      Extr_MN_Buffer3[i] = estructMN[2].price;
       ATR_MN_Buffer3[i] = estructMN[2].channel;
      Extr_W1_Buffer1[i] = estructW1[0].price;
       ATR_W1_Buffer1[i] = estructW1[0].channel;
      Extr_W1_Buffer2[i] = estructW1[1].price;
       ATR_W1_Buffer2[i] = estructW1[1].channel;
      Extr_W1_Buffer3[i] = estructW1[2].price;
       ATR_W1_Buffer3[i] = estructW1[2].channel;
      Extr_D1_Buffer1[i] = estructD1[0].price;
       ATR_D1_Buffer1[i] = estructD1[0].channel;
      Extr_D1_Buffer2[i] = estructD1[1].price;
       ATR_D1_Buffer2[i] = estructD1[1].channel;
      Extr_D1_Buffer3[i] = estructD1[2].price;
       ATR_D1_Buffer3[i] = estructD1[2].channel;
      Extr_H4_Buffer1[i] = estructH4[0].price;
       ATR_H4_Buffer1[i] = estructH4[0].channel;
      Extr_H4_Buffer2[i] = estructH4[1].price;
       ATR_H4_Buffer2[i] = estructH4[1].channel;
      Extr_H4_Buffer3[i] = estructH4[2].price;
       ATR_H4_Buffer3[i] = estructH4[2].channel;
      Extr_H1_Buffer1[i] = estructH1[0].price;
       ATR_H1_Buffer1[i] = estructH1[0].channel;
      Extr_H1_Buffer2[i] = estructH1[1].price;
       ATR_H1_Buffer2[i] = estructH1[1].channel;
      Extr_H1_Buffer3[i] = estructH1[2].price;
       ATR_H1_Buffer3[i] = estructH1[2].channel;
      Price_D1_Buffer1[i] = open [i+1];
      Price_D1_Buffer2[i] = high [i+1];
      Price_D1_Buffer3[i] = low  [i+1];
      Price_D1_Buffer4[i] = close[i+1];
        ATR_D1_Buffer [i] = ATR_D1_Buffer[i+1];
      
      if(barMN.isNewBar() > 0) CalcExtr(calcMN, estructMN, time[i], true); 
      if(barW1.isNewBar() > 0) CalcExtr(calcW1, estructW1, time[i], true);  
      if(barD1.isNewBar() > 0) CalcExtr(calcD1, estructD1, time[i], true);
      if(barH4.isNewBar() > 0) CalcExtr(calcH4, estructH4, time[i], true);
      if(barH1.isNewBar() > 0) CalcExtr(calcH1, estructH1, time[i], true);
     }
    }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  
  
//-------------------------------------------------------------------+
bool FillATRBuffer()
{
 bool result = true;
 
 if(show_Extr_MN)
  if(!calcMN.isATRCalculated())
   result = false;
   
 if(show_Extr_W1)
  if(!calcW1.isATRCalculated())
   result = false;
   
 if(show_Extr_D1 || show_Price_D1)
  if(!calcD1.isATRCalculated())
   result = false;
   
 if(show_Extr_H4)
  if(!calcH4.isATRCalculated())
   result = false;
   
 if(show_Extr_H1)
  if(!calcH1.isATRCalculated())
   result = false;   
   
 if(!result)
  PrintFormat("%s �� ���������� ��������� ������ ATR, ������� ����� ������. �������� ����� %d", __FUNCTION__, GetLastError()); 
 return(result);
}

void CalcExtr (CExtremumCalc &extrcalc, SExtremum &resArray[], datetime start_pos_time, bool now = false)
{
 extrcalc.RecountExtremum(now, start_pos_time);
 GetThreeExtr(extrcalc, resArray);
}

void GetThreeExtr(CExtremumCalc &extrcalc, SExtremum &resArray[])
{
 for(int j = 0; j < 3; j++)
 {
  resArray[j] = extrcalc.getExtr(j);
 }
 PrintFormat("%s num0: {%d, %0.5f}; num1: {%d, %0.5f}; num2: {%d, %0.5f};", EnumToString((ENUM_TIMEFRAMES)extrcalc.getPeriod()), resArray[0].direction, resArray[0].price, resArray[1].direction, resArray[1].price, resArray[2].direction, resArray[2].price);
}

void CreateExtrLines(const SExtremum &te[], ENUM_TIMEFRAMES tf, color clr)
{
 string name = "extr_" + EnumToString(tf) + "_";
 HLineCreate(0, name+"one"   , 0, te[0].price              , clr, 1, STYLE_DASHDOT);
 HLineCreate(0, name+"one+"  , 0, te[0].price+te[0].channel, clr, 2);
 HLineCreate(0, name+"one-"  , 0, te[0].price-te[0].channel, clr, 2);
 HLineCreate(0, name+"two"   , 0, te[1].price              , clr, 1, STYLE_DASHDOT);
 HLineCreate(0, name+"two+"  , 0, te[1].price+te[1].channel, clr, 2);
 HLineCreate(0, name+"two-"  , 0, te[1].price-te[1].channel, clr, 2);
 HLineCreate(0, name+"three" , 0, te[2].price              , clr, 1, STYLE_DASHDOT);
 HLineCreate(0, name+"three+", 0, te[2].price+te[2].channel, clr, 2);
 HLineCreate(0, name+"three-", 0, te[2].price-te[2].channel, clr, 2);
}

void MoveExtrLines(const SExtremum &te[], ENUM_TIMEFRAMES tf)
{
 string name = "extr_" + EnumToString(tf) + "_";
 HLineMove(0, name+"one"   , te[0].price);
 HLineMove(0, name+"one+"  , te[0].price+te[0].channel);
 HLineMove(0, name+"one-"  , te[0].price-te[0].channel);
 HLineMove(0, name+"two"   , te[1].price);
 HLineMove(0, name+"two+"  , te[1].price+te[1].channel);
 HLineMove(0, name+"two-"  , te[1].price-te[1].channel);
 HLineMove(0, name+"three" , te[2].price);
 HLineMove(0, name+"three+", te[2].price+te[2].channel);
 HLineMove(0, name+"three-", te[2].price-te[2].channel);
}

void DeleteExtrLines(ENUM_TIMEFRAMES tf)
{
 string name = "extr_" + EnumToString(tf) + "_";
 HLineDelete(0, name+"one");
 HLineDelete(0, name+"one+");
 HLineDelete(0, name+"one-");
 HLineDelete(0, name+"two");
 HLineDelete(0, name+"two+");
 HLineDelete(0, name+"two-");
 HLineDelete(0, name+"three");
 HLineDelete(0, name+"three+");
 HLineDelete(0, name+"three-");
}

void CreatePriceLines(color clr)
{
 string name = "price_D1_";
 HLineCreate(0, name+"open"  , 0, 0, clr, 1, STYLE_DASHDOT);
 HLineCreate(0, name+"open+" , 0, 0, clr, 2);
 HLineCreate(0, name+"open-" , 0, 0, clr, 2); 
 HLineCreate(0, name+"high"  , 0, 0, clr, 1, STYLE_DASHDOT);
 HLineCreate(0, name+"high+" , 0, 0, clr, 2);
 HLineCreate(0, name+"high-" , 0, 0, clr, 2);
 HLineCreate(0, name+"low"   , 0, 0, clr, 1, STYLE_DASHDOT);
 HLineCreate(0, name+"low+"  , 0, 0, clr, 2);
 HLineCreate(0, name+"low-"  , 0, 0, clr, 2);
 HLineCreate(0, name+"close" , 0, 0, clr, 1, STYLE_DASHDOT);
 HLineCreate(0, name+"close+", 0, 0, clr, 2);
 HLineCreate(0, name+"close-", 0, 0, clr, 2);
}

void MovePriceLines()
{
 string name = "price_D1_";
 HLineMove(0, name+"open"  , Price_D1_Buffer1[0]);
 HLineMove(0, name+"open+" , Price_D1_Buffer1[0] + ATR_D1_Buffer[0]);
 HLineMove(0, name+"open-" , Price_D1_Buffer1[0] - ATR_D1_Buffer[0]);
 HLineMove(0, name+"high"  , Price_D1_Buffer2[0]);
 HLineMove(0, name+"high+" , Price_D1_Buffer2[0] + ATR_D1_Buffer[0]);
 HLineMove(0, name+"high-" , Price_D1_Buffer2[0] - ATR_D1_Buffer[0]); 
 HLineMove(0, name+"low"   , Price_D1_Buffer3[0]);
 HLineMove(0, name+"low+"  , Price_D1_Buffer3[0] + ATR_D1_Buffer[0]);
 HLineMove(0, name+"low-"  , Price_D1_Buffer3[0] - ATR_D1_Buffer[0]);
 HLineMove(0, name+"close" , Price_D1_Buffer4[0]);
 HLineMove(0, name+"close+", Price_D1_Buffer4[0] + ATR_D1_Buffer[0]);
 HLineMove(0, name+"close-", Price_D1_Buffer4[0] - ATR_D1_Buffer[0]);   
}

void DeletePriceLines(ENUM_TIMEFRAMES tf)
{
 string name = "price_" + EnumToString(tf) + "_";
 HLineDelete(0, name+"open");
 HLineDelete(0, name+"open+");
 HLineDelete(0, name+"open-");
 HLineDelete(0, name+"close");
 HLineDelete(0, name+"close+");
 HLineDelete(0, name+"close-");
 HLineDelete(0, name+"high");
 HLineDelete(0, name+"high+");
 HLineDelete(0, name+"high-");
 HLineDelete(0, name+"low");
 HLineDelete(0, name+"low+");
 HLineDelete(0, name+"low-");
}

//CREATE AND DELETE LABEL AND RECTLABEL
void SetInfoTabel()
{
 int X = 10;
 int Y = 30;
 RectLabelCreate(0, "Extr_Title", 0, X, Y, 130, 105, clrBlack, BORDER_FLAT, CORNER_LEFT_UPPER, clrWhite, STYLE_SOLID, 1, false, false, false);
 LabelCreate(0,  "Extr_PERIOD_MN", 0, X+65, Y+15, CORNER_LEFT_UPPER, "EXTREMUM MONTH", "Arial Black", 8,  color_Extr_MN, ANCHOR_CENTER, false, false, false);
 LabelCreate(0,  "Extr_PERIOD_W1", 0, X+65, Y+30, CORNER_LEFT_UPPER,  "EXTREMUM WEEK", "Arial Black", 8,  color_Extr_W1, ANCHOR_CENTER, false, false, false);
 LabelCreate(0,  "Extr_PERIOD_D1", 0, X+65, Y+45, CORNER_LEFT_UPPER,   "EXTREMUM DAY", "Arial Black", 8,  color_Extr_D1, ANCHOR_CENTER, false, false, false);
 LabelCreate(0,  "Extr_PERIOD_H4", 0, X+65, Y+60, CORNER_LEFT_UPPER, "EXTREMUM 4HOUR", "Arial Black", 8,  color_Extr_H4, ANCHOR_CENTER, false, false, false);
 LabelCreate(0,  "Extr_PERIOD_H1", 0, X+65, Y+75, CORNER_LEFT_UPPER, "EXTREMUM 1HOUR", "Arial Black", 8,  color_Extr_H1, ANCHOR_CENTER, false, false, false);
 LabelCreate(0, "Price_PERIOD_D1", 0, X+65, Y+90, CORNER_LEFT_UPPER,      "PRICE DAY", "Arial Black", 8, color_Price_D1, ANCHOR_CENTER, false, false, false);
 ChartRedraw();
}

void DeleteInfoTabel()
{
 RectLabelDelete(0, "Extr_Title");
 LabelDelete(0, "Extr_PERIOD_MN");
 LabelDelete(0, "Extr_PERIOD_W1");
 LabelDelete(0, "Extr_PERIOD_D1");
 LabelDelete(0, "Extr_PERIOD_H4");
 LabelDelete(0, "Extr_PERIOD_H1");
 LabelDelete(0, "Price_PERIOD_D1");
 ChartRedraw();
}