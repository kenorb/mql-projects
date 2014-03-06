//+------------------------------------------------------------------+
//|                                                      DisMACD.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#include <Lib CisNewBar.mqh>                  // ��� �������� ������������ ������ ����
#include <divergenceStochastic.mqh>           // ���������� ���������� ��� ������ ��������� � ����������� ����������
#include <ChartObjects\ChartObjectsLines.mqh> // ��� ��������� ����� ���������\�����������
#include <CompareDoubles.mqh>                 // ��� �������� �����������  ���

 // ��������� ����������
 
//---- ����� ������������� 2 ������
#property indicator_buffers 2
//---- ������������ 2 ����������� ����������
#property indicator_plots   2

//---- � �������� ���������� �������  ������������ �����
#property indicator_type1 DRAW_LINE
//---- ���� ����������
#property indicator_color1  clrWhite
//---- ������� ����� ����������
#property indicator_width1  1
//---- ����� �����
#property indicator_style1 STYLE_SOLID
//---- ����������� ����� ����� ����������
#property indicator_label1  "StochasticTopLevel"

//---- � �������� ���������� �������  ������������ �����
#property indicator_type2 DRAW_LINE
//---- ���� ����������
#property indicator_color2  clrRed
//---- ������� ����� ����������
#property indicator_width2  1
//---- ����� �����
#property indicator_style2  STYLE_DASHDOT
//---- ����������� ����� ����� ����������
#property indicator_label2  "StochasticBottomLevel"

 // ������������ ������ �������� ����� �������
 enum BARS_MODE
 {
  ALL_HISTORY=0, // ��� �������
  INPUT_BARS     // �������� ���������� ����� ������������
 };
 // ������ ������ ����� �����
 color lineColors[5]=
  {
   clrRed,
   clrBlue,
   clrYellow,
   clrGreen,
   clrGray
  };
//+------------------------------------------------------------------+
//| �������� ��������� ����������                                    |
//+------------------------------------------------------------------+
input BARS_MODE           bars_mode=ALL_HISTORY;        // ����� �������� �������
input short               bars=20000;                   // ��������� ���������� ����� ������� (K-������)
input ENUM_MA_METHOD      ma_method=MODE_SMA;           // ��� �����������
input ENUM_STO_PRICE      price_field=STO_LOWHIGH;      // ������ ������� ����������           
input int                 top_level=80;                 // ������� ������� 
input int                 bottom_level=20;              // ������ ������� 
input int                 DEPTH_STOC=10;                // ������� ����� ������ 
input int                 ALLOW_DEPTH_FOR_PRICE_EXTR=3; // ����� ����� ������
input int                 depth=10;                     // ������� ���������� ������������
input string              file_url="STAT_STOC.txt";     // url ����� ����� ���������� 


//+------------------------------------------------------------------+
//| ���������� ����������                                            |
//+------------------------------------------------------------------+

bool               first_calculate;        // ���� ������� ������ OnCalculate
int                handleStoc;             // ����� ����������
int                lastBarIndex;           // ������ ���������� ����   
long               countTrend;             // ������� ����� �����

PointDiv           divergencePoints;       // ��������� � ����������� ����������
CChartObjectTrend  trendLine;              // ������ ������ ��������� �����
CisNewBar          isNewBar;               // ��� �������� ������������ ������ ����

double             bufferStoc[];           // ����� ���������� 1
double             bufferStoc2[];          // ����� ���������� 2

int countConvPos = 0;                      // ���������� ������������� �������� ���������
int countConvNeg = 0;                      // ���������� ���������� �������� ���������
int countDivPos  = 0;                      // ���������� ������������� �������� �����������
int countDivNeg  = 0;                      // ���������� ���������� �������� ����������� 

double averConvPos = 0;      // ������� ���������� ���������
double averConvNeg = 0;      // ������� �� ���������� ���������
double averDivPos  = 0;      // ������� ���������� �����������
double averDivNeg  = 0;      // ������� �� ���������� �����������
double averPos     = 0;      // ������� ���������� ������
double averNeg     = 0;      // ������� �� ���������� ������   
 
// ��������� ���������� ��� �������� ��������� ��������� � ����������
 double localMax;
 double localMin;

// ������� � ����� �� ������� ���������� ���������\�����������

int count;

// ����� ����� ���������� ��������� \ ����������� 
 int file_handle;   

//+------------------------------------------------------------------+
//| ������� ������� ����������                                       |
//+------------------------------------------------------------------+

int OnInit()
  {
   // ������� ���� ���������� 
   file_handle = FileOpen(file_url, FILE_WRITE|FILE_COMMON|FILE_ANSI|FILE_TXT, "");
   if (file_handle == INVALID_HANDLE) //�� ������� ������� ����
    {
     Alert("������ �������� �����");
     return (INIT_FAILED);
    }  
   // ������� ��� ����������� �������     
   ObjectsDeleteAll(0,0,OBJ_TREND);
   ObjectsDeleteAll(0,1,OBJ_TREND);   
   // ��������� ��������� � �������
   SetIndexBuffer(0,bufferStoc,INDICATOR_DATA);
   SetIndexBuffer(1,bufferStoc2,INDICATOR_DATA);   
   // ������������� ����������  ����������
   first_calculate = true;
   countTrend = 1;
   // ��������� ����� ���������� ����������
   handleStoc = iStochastic(_Symbol,_Period,5,3,3,ma_method,price_field);
   return(INIT_SUCCEEDED);
  }

void OnDeinit ()
  {

  }
  

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
    int retCode;  // ��������� ���������� ��������� � �����������
    // ���� ��� ������ ������ ������ ��������� ����������
    if (first_calculate)
     {
      if (bars_mode == ALL_HISTORY)
       {
        lastBarIndex = rates_total - 101;
       }
      else
       {
       if (bars < 100)
        {
         lastBarIndex = 1;
        }
       else if (bars > rates_total)
        {
         lastBarIndex = rates_total-101;
        }
       else
        {
         lastBarIndex = bars-101;
        }
       }
       // �������� ������ ����������
       if ( CopyBuffer(handleStoc,0,0,bars,bufferStoc) < 0 ||
            CopyBuffer(handleStoc,1,0,bars,bufferStoc2) < 0 )
           {
             // ���� �� ������� ��������� ������ ����������
             return (0);
           }    
       for (;lastBarIndex > 0; lastBarIndex--)
        {
          // ��������� ������� �� ������ �� ������� �����������\��������� 
          retCode = divergenceSTOC (handleStoc,_Symbol,_Period,top_level,bottom_level,DEPTH_STOC,ALLOW_DEPTH_FOR_PRICE_EXTR,divergencePoints,lastBarIndex);
          // ���� �� ������� ��������� �����
          if (retCode == -2)
           return (0);
          // ���� ���������\����������� ����������
          if (retCode)
           {                                     
          //  trendLine.Color(lineColors[countTrend % 5] );
            //������� ����� ���������\�����������                    
            trendLine.Create(0,"PriceLine_"+countTrend,0,divergencePoints.timeExtrPrice1,divergencePoints.valueExtrPrice1,divergencePoints.timeExtrPrice2,divergencePoints.valueExtrPrice2);           
            
            //trendLine.Color(lineColors[countTrend % 5] );         
            //������� ����� ���������\����������� �� ����������
            trendLine.Create(0,"StocLine_"+countTrend,1,divergencePoints.timeExtrSTOC1,divergencePoints.valueExtrSTOC1,divergencePoints.timeExtrSTOC2,divergencePoints.valueExtrSTOC2);            
            //����������� ���������� ����� �����
            countTrend++;
            
            localMax = high[lastBarIndex];
            localMin = low[lastBarIndex];
            for (count=1;count<=depth;count++)
             {
              if (high[lastBarIndex-count] > localMax)
               localMax = high[lastBarIndex-count];
              if (low[lastBarIndex-count] < localMin)
               localMin = low[lastBarIndex-count];
             } 
             
            if (retCode == 1)
             {
               FileWriteString(file_handle,"\n "+TimeToString(time[lastBarIndex])+" (�����������): " );   
               FileWriteString(file_handle,"\n�������: "+DoubleToString(localMax - close[lastBarIndex])+" ������: "+DoubleToString(close[lastBarIndex]-localMin));    
               if ( GreatDoubles ( (localMax - close[lastBarIndex]), (close[lastBarIndex] - localMin) ) )
                 {
               
                   averDivPos  = averDivPos + localMax - close[lastBarIndex];
                   averPos     = averPos + localMax - close[lastBarIndex]; 
                   countDivPos ++; // ����������� ������� ������������� ���������
                 }
               else
                 {
                   averDivNeg  = averDivNeg + localMin - close[lastBarIndex];  
                   averNeg     = averNeg + localMin - close[lastBarIndex]; 
                   countDivNeg ++; // ����� ����������� ������� ������������� ���������
                 }
             }
            if (retCode == -1)
             {
               FileWriteString(file_handle,"\n "+TimeToString(time[lastBarIndex])+" (���������): " );   
               FileWriteString(file_handle,"\n�������: "+DoubleToString(localMax - close[lastBarIndex])+" ������: "+DoubleToString(close[lastBarIndex]-localMin));                
               if (LessDoubles ( (localMax - close[lastBarIndex]), (close[lastBarIndex] - localMin) ) )
                 {
                  averConvPos = averConvPos + localMax - close[lastBarIndex];
                  averPos     = averPos + localMax - close[lastBarIndex];  
                  countConvPos ++; // ����������� ������� ������������� �����������
                 }
               else
                 {
                  averConvNeg = averConvNeg + localMin - close[lastBarIndex];  
                  averNeg     = averNeg + localMin - close[lastBarIndex];
                  countConvNeg ++; // ����� ����������� ������� ������������� �����������
                 }   
             }            
            
           }
        }
        
           // ���������� ������� ��������
   if (countConvNeg > 0)
    averConvNeg = averConvNeg / countConvNeg;
   if (countConvPos > 0) 
    averConvPos = averConvPos / countConvPos;
   if (countDivNeg > 0)
    averDivNeg  = averDivNeg  / countDivNeg;
   if (countDivPos > 0)
    averDivPos  = averDivPos  / countDivPos;
   if (countConvNeg > 0 || countDivNeg > 0)
    averNeg     = averNeg     / (countConvNeg + countDivNeg);
   if (countConvPos > 0 || countDivPos > 0)
    averPos     = averPos     / (countConvPos + countDivPos);    
        
    Alert("________________________________________");
    Alert("������� �� ����������: ",averNeg);
    Alert("������� ����������: ",averPos);
    Alert("������� �� ���������� �����������: ",averDivNeg);
    Alert("������� ���������� �����������: ",averDivPos); 
    Alert("������� �� ���������� ���������: ",averConvNeg);
    Alert("������� ���������� ���������: ",averConvPos);           
    Alert("�� ���������� �����������: ",countDivNeg);
    Alert("���������� �����������: ",countDivPos);
    Alert("����� �����������: ",countDivPos+countDivNeg);
    Alert("�� ���������� ���������: ",countConvNeg);
    Alert("���������� ���������: ",countConvPos);
    Alert("����� ���������: ",countConvPos+countConvNeg);
    Alert("���������� ������ ���������\�����������:");
    
    // ��������� � ���� ���������� �������������� �������� ���� ��������� \ �����������
 
   FileWriteString(file_handle,"\n\n������ ���������: "+IntegerToString(countConvPos) );   
   FileWriteString(file_handle,"\n�� ������ ���������: "+IntegerToString(countConvNeg) );
   FileWriteString(file_handle,"\n����� ���������: "+IntegerToString(countConvNeg+countConvPos) );  
   FileWriteString(file_handle,"\n������ �����������: "+IntegerToString(countDivPos) );   
   FileWriteString(file_handle,"\n�� ������ �����������: "+IntegerToString(countDivNeg) );
   FileWriteString(file_handle,"\n����� �����������: "+IntegerToString(countDivNeg+countDivPos) ); 
    
   FileWriteString(file_handle,"\n������� ���������� ���������: "+DoubleToString(averConvPos,_Digits));  
   FileWriteString(file_handle,"\n������� �� ���������� ���������: "+DoubleToString(averConvNeg,_Digits));
   FileWriteString(file_handle,"\n������� ���������� �����������: "+DoubleToString(averDivPos,_Digits)); 
   FileWriteString(file_handle,"\n������� �� ���������� �����������: "+DoubleToString(averDivNeg,_Digits));
   FileWriteString(file_handle,"\n������� ����������: "+DoubleToString(averPos,_Digits));            
   FileWriteString(file_handle,"\n������� �� ����������: "+DoubleToString(averNeg,_Digits));
   if (GreatDoubles(averNeg,0))
    FileWriteString(file_handle,"\n��������� ������� ������� � ������: "+DoubleToString(averPos/averNeg,_Digits));     
   if (GreatDoubles(averDivNeg,0))  
    FileWriteString(file_handle,"\n��������� ������� ������� � ������ �����������: "+DoubleToString(averDivPos/averDivNeg,_Digits));         
   if (GreatDoubles(averConvNeg,0))
    FileWriteString(file_handle,"\n��������� ������� ������� � ������ ���������: "+DoubleToString(averConvPos/averConvNeg,_Digits)); 
     
                      
      
    FileClose(file_handle);          //��������� ���� ����������
        
       first_calculate = false;
     }
    else  // ���� ������� �� ������
     { 
       // �������� ����� ����������
       if ( CopyBuffer(handleStoc,0,0,rates_total,bufferStoc) < 0 ||
            CopyBuffer(handleStoc,1,0,rates_total,bufferStoc2) < 0 )
           {
             // ���� �� ������� ��������� ������ ����������
             return (0);
           }                 
       // ���� ����������� ����� ���
       if (isNewBar.isNewBar() > 0)
        {        
         // ���������� ���������\����������� ����������
         retCode = divergenceSTOC (handleStoc,_Symbol,_Period,top_level,bottom_level,DEPTH_STOC,ALLOW_DEPTH_FOR_PRICE_EXTR,divergencePoints,1);         
         // ���� ���������\����������� ����������
         if (retCode)
          {   
          // trendLine.Color(lineColors[countTrend % 5] );     
           // ������� ����� ���������\�����������              
           trendLine.Create(0,"PriceLine_"+countTrend,0,divergencePoints.timeExtrPrice1,divergencePoints.valueExtrPrice1,divergencePoints.timeExtrPrice2,divergencePoints.valueExtrPrice2); 
          // trendLine.Color(lineColors[countTrend % 5] );           
           //������� ����� ���������\����������� �� MACD
           trendLine.Create(0,"StocLine_"+countTrend,1,divergencePoints.timeExtrSTOC1,divergencePoints.valueExtrSTOC1,divergencePoints.timeExtrSTOC2,divergencePoints.valueExtrSTOC2);    
           // ����������� ���������� ����� �����
           countTrend++;
          }      
        }
     } 
       
    return(rates_total);
  }