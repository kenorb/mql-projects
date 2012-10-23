//+------------------------------------------------------------------+
//|                                              desepticon v004.mq4 |
//|                                            Copyright � 2011, GIA |
//|                                             http://www.saita.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2011, GIA"
#property link      "http://www.saita.net"

//------- ������� ��������� ��������� -----------------------------------------+
extern int hairLength = 250;

extern int Kperiod = 5;
extern int Dperiod = 3;
extern int slowing = 3;
//------- ���������� ���������� ��������� -------------------------------------+


//------- ����������� ������� ������� -----------------------------------------+
#include <stdlib.mqh>             // ����������� ����������#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>
//--------------------------------------------------------------- 3 --
#include <DesepticonVariables.mqh>    // �������� ����������
#include <AddOnFuctions.mqh>  
#include <CheckBeforeStart.mqh>       // �������� ������� ����������
#include <DesepticonTrendCriteria.mqh>
#include <StochasticDivergenceProcedures.mqh>
#include <DesepticonBreakthrough2.mqh>
#include <searchForTits.mqh>
#include <GetLastOrderHist.mqh>
#include <GetLots.mqh>     // �� ����� ���������� ����� �����������
#include <isNewBar.mqh>
#include <isMACDExtremum.mqh>
#include <DesepticonOpening.mqh>
#include <DesepticonTrailing.mqh>

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init(){
  Alert("��������� �-�� init() ��� �������");

  aTimeframe[1,0] = PERIOD_H1;
  aTimeframe[1,1] = TakeProfit_1H;
  aTimeframe[1,2] = StopLoss_1H_min;
  aTimeframe[1,3] = StopLoss_1H_max;
  aTimeframe[1,4] = MACD_channel_1H;
  aTimeframe[1,5] = MinProfit_1H;
  aTimeframe[1,6] = TrailingStop_1H_min;
  aTimeframe[1,7] = TrailingStop_1H_max;
  aTimeframe[1,8] = TrailingStep_1H;
  aTimeframe[1,9] = PERIOD_M5;
  
  for (frameIndex = startTF; frameIndex <= finishTF; frameIndex++)
  {
   InitTrendDirection(aTimeframe[frameIndex, 0], aTimeframe[frameIndex,4]);
   //Alert("���������� ����������� ������");
  
   InitStoDivergenceArray(aTimeframe[frameIndex, 0]);
   //Alert("���������� ����������� Stochastic");
  }
  
  return(0);
 }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit(){
	Alert("��������� ������� deinit");
	return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start(){
	for (frameIndex = startTF; frameIndex < finishTF; frameIndex++){
     //Alert ("���� �� ����� ��");
     //Alert ("frameIndex", frameIndex);
     Jr_Timeframe = aTimeframe[frameIndex, 9];
     Elder_Timeframe = aTimeframe[frameIndex, 0];
     
     TakeProfit = aTimeframe[frameIndex, 1];
     StopLoss_min = aTimeframe[frameIndex, 2];
     StopLoss_max = aTimeframe[frameIndex, 3]; 
     Jr_MACD_channel = aTimeframe[frameIndex + 1, 4];
     Elder_MACD_channel = aTimeframe[frameIndex, 4];
     
     MinProfit = aTimeframe[frameIndex, 5]; 
     TrailingStop_min = aTimeframe[frameIndex, 6];
     TrailingStop_max = aTimeframe[frameIndex, 7]; 
     TrailingStep = aTimeframe[frameIndex, 8];
     
     if (!CheckBeforeStart())   // ��������� ������� ���������
     {
      PlaySound("alert2.wav");
      return (0); 
     }
     
     total=OrdersTotal();


     if( isNewBar(Elder_Timeframe) ) // �� ������ ����� ���� �������� �� ��������� ����� � ��������� �� �������
     {
      trendDirection[frameIndex][0] = TwoTitsTrendCriteria(Elder_Timeframe, Elder_MACD_channel, eld_EMA1, eld_EMA2, eldFastMACDPeriod, eldSlowMACDPeriod);
      if (trendDirection[frameIndex][0] > 0) // ���� ����� ����� �� ������� ����������
      {
       trendDirection[frameIndex][1] = 1;
      }
      if (trendDirection[frameIndex][0] < 0) // ���� ����� ����
      {
       trendDirection[frameIndex][1] = -1;
      }
      
  //--------------------------
  // ���������� ��� ��� ��� ����� �����������
  //--------------------------     
      if (wantToOpen[frameIndex][1] != 0) // ���� ������ ����������� �� ����������� Stochastic
      {
       barsCountToBreak[frameIndex][1]++;
       if (barsCountToBreak[frameIndex][1] > breakForStochastic)
       { 
        barsCountToBreak[frameIndex][1] = 0; // ������ 2� ����� ��������, ��� ������ �����������
        wantToOpen[frameIndex][1] = 0;
       }
      }
  //--------------------------
  // ���������, ��� ��� ��� ����� �����������
  //--------------------------     
      
  //--------------------------
  // ��������� ����������� Stochastic
  //--------------------------    
      InitStoDivergenceArray(Elder_Timeframe); 
      if (wantToOpen[frameIndex][1] == 0) // ���� ��� �� ����� �����������
      {   
       wantToOpen[frameIndex][1] = isStoDivergence(Elder_Timeframe);  // ��������� �� ����������� �� ���� ����    
      }
  //--------------------------
  // ��������� ����������� Stochastic
  //-------------------------- 
     
     } // close isNewBar(Elder_Timeframe)

     //-------------------------------------------------------------------------------------------
     // ����
     //-------------------------------------------------------------------------------------------      
     if (trendDirection[frameIndex][0] == 0)    // ���������� ����, ����� ���� �������� ����� �� MACD, �����������.
     {
      
      if (Ask > iMA(NULL, Elder_Timeframe, 3, 0, 1, PRICE_HIGH, 0) + hairLength*Point)
      {
       trendDirection[frameIndex][0] = 1;
       trendDirection[frameIndex][1] = 1;
       return(0);
      }
      if (Bid < iMA(NULL, Elder_Timeframe, 3, 0, 1, PRICE_LOW, 0) - hairLength*Point)
      {
       trendDirection[frameIndex][0] = -1;
       trendDirection[frameIndex][1] = -1;
       return(0);
      }

	//--------------------------
	// ����������� 
	//--------------------------
	   if (wantToOpen[frameIndex][1] > 0) // ����� ����������� ����� (���� ����), ���� ������ ���������, ����� ��������
      {
       if (Bid < iMA(NULL, Elder_Timeframe, 3, 0, 1, 0, 0) + deltaPriceToEMA*Point)
       {
        openPlace = "������� �� ����, " + openPlace;
	     if (DesepticonBreakthrough2(1, Jr_Timeframe) != 0) // ��� ������������ ������������� ����, ���� ������, �����������
	     {
	      // �������� ���������� ������ �������� ������ 
	     }
	    }
      } // close ����� ����������� �����
    
      if (wantToOpen[frameIndex][1] < 0) // ����� ����������� ���� (���� �������), ���� ������ ��������, ����� ���������
      {
       if (Ask > iMA(NULL, Elder_Timeframe, 3, 0, 1, 0, 0) - deltaPriceToEMA*Point)
       {
        openPlace = "������� �� ����, " + openPlace;
	     if (DesepticonBreakthrough2(-1, Jr_Timeframe) <= 0) // ��� ������������ ������������� ����, ���� ������, �����������
	     {
	      // �������� ���������� ������ �������� ������ 
	     }
	    }
      } // close ����� ����������� ����
	//--------------------------
	// ����������� 
	//--------------------------
   
     } // close ����	
    } // close ����
//----
	if (UseTrailing) DesepticonTrailing(NULL, Jr_Timeframe);
	return(0);
} // close start
//+------------------------------------------------------------------+