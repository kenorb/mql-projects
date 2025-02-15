//+------------------------------------------------------------------+
//|                                              TihiroIndicator.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <TIHIRO\Extrem.mqh>     //���������� ���������� ��� ������ �����������
#include <CompareDoubles.mqh>   

//---- ����� ������������� 2 ������
#property indicator_buffers 4
//---- ������������ 1 ����������� ��� �������
#property indicator_plots   4
//---- � �������� ���������� ������������ �����
#property indicator_type1 DRAW_LINE
//---- ���� ����������
#property indicator_color1  clrBlue
//---- ����� ����� ����������
#property indicator_style1  STYLE_SOLID
//---- ������� ����� ����������
#property indicator_width1  1
//---- ����������� ����� ����� ����������
#property indicator_label1  "TREND_DOWN"

//---- � �������� ���������� ������������ �����
#property indicator_type2 DRAW_LINE
//---- ���� ����������
#property indicator_color2  clrRed
//---- ����� ����� ����������
#property indicator_style2  STYLE_SOLID
//---- ������� ����� ����������
#property indicator_width2  1
//---- ����������� ����� ����� ����������
#property indicator_label2  "TREND_UP"


//---- � �������� ���������� ������������ �����
#property indicator_type3 DRAW_LINE
//---- ���� ����������
#property indicator_color3  clrYellow
//---- ����� ����� ����������
#property indicator_style3  STYLE_DASHDOT
//---- ������� ����� ����������
#property indicator_width3  1

//---- � �������� ���������� ������������ �����
#property indicator_type4 DRAW_LINE
//---- ���� ����������
#property indicator_color4  clrYellow
//---- ����� ����� ����������
#property indicator_style4  STYLE_DASHDOT
//---- ������� ����� ����������
#property indicator_width4  1


input short bars=50;  //��������� ���������� ����� �������
input int   priceDifferent=10; //������� ��� ��� ������ �����������


//---- ����� �������� �����  ������
double trendLineDown[];
double trendLineUp[];
double priceHigh[];
double priceLow[];

//---- TD ����� (����������) ����������� ������
Extrem point_up_left;         //����� �����
Extrem point_up_right;        //������ �����
//---- TD ����� (����������) ����������� ������
Extrem point_down_left;       //����� �����
Extrem point_down_right;      //������ �����
//---- �������� ������� ����� ������
double tg_down;               //������� ���������� ����� �����
double tg_up;                 //������� ���������� ����� �����
//---- ����� ��� ������ �����������
short  flag_up=0;             //���� ��� ����������� ������, 0-��� ����������, 1-������ ����, 2-��� �������
short  flag_down=0;           //���� ��� ����������� ������, 0-��� ����������, 1-������ ����, 2-��� �������
//---- ������� ��� ��� ������ �����������
double priceDiff;             //����������� ������� ���
double price_diff_left;       //������� ��� �����
double price_diff_right;      //������� ��� ������    

int OnInit()
  {
//---- ��������� ������� �������
   SetIndexBuffer(0,trendLineDown,INDICATOR_DATA);   
   SetIndexBuffer(1,trendLineUp,  INDICATOR_DATA);  
   SetIndexBuffer(2,priceHigh,  INDICATOR_DATA);     
   SetIndexBuffer(3,priceLow,  INDICATOR_DATA);                           
   priceDiff = priceDifferent*_Point;

   return(INIT_SUCCEEDED);
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
   int i;
   flag_down = 0;  
   flag_up = 0;   
   //�������� �� ����� � ��������� ����������
   
   for(i = rates_total-3; i > 0; i--)
    {
     trendLineDown[i]=0;    
     trendLineUp[i]=0;      
     price_diff_left  = high[i] - high[i-1];
     price_diff_right = high[i] - high[i+1];  
     //���� ������� high ���� ������ high ��� ����������� � ����������
     //if ( GreatDoubles(high[i],high[i-1]) && GreatDoubles(high[i],high[i+1]) && flag_down < 2 )
     if (price_diff_left >= priceDiff && price_diff_right >= priceDiff && flag_down < 2)
      {
       if ( flag_down == 0 )
        {
         //��������� ������ ���������
         point_down_right.SetExtrem(i,high[i]);
         flag_down=1; 
        }
       else 
        {
         if( GreatDoubles(high[i],point_down_right.price) )
          {
          //��������� ����� ���������
          point_down_left.SetExtrem(i,high[i]);               
          flag_down=2;
          }
        }            
      }  //���������� �����
     //���� ������� low ���� ������ low ��� ����������� � ����������
     price_diff_left  = low[i-1]-low[i];
     price_diff_right = low[i+1]-low[i]; 
    // if ( LessDoubles(low[i],low[i-1]) && LessDoubles(low[i],low[i+1])&&flag_up < 2)
     if (price_diff_left >= priceDiff && price_diff_right >= priceDiff && flag_up < 2)
      {
       if (flag_up == 0)
        {
         //��������� ������ ���������
         point_up_right.SetExtrem(i,low[i]);
         flag_up=1; 
        }
       else 
        {
         if(LessDoubles(low[i],point_up_right.price))
          {
          //��������� ����� ���������
          point_up_left.SetExtrem(i,low[i]);        
          flag_up=2;
          }
        }            
      }  //���������� �����         
    } 
    //��������� �������� ������� ����� �����
    if (flag_down==2) //���� ��� ���������� ��� ����������� ������ �������
     {
      tg_down = (point_down_right.price-point_down_left.price)/(point_down_right.n_bar-point_down_left.n_bar);
     }
    if (flag_up==2) //���� ��� ���������� ��� ����������� ������ �������
     {
      tg_up = (point_up_right.price-point_up_left.price)/(point_up_right.n_bar-point_up_left.n_bar);
     }     
    //�������� �� ����� � ��������� �����, ������������� ������ ������
    
    priceHigh[rates_total-1] = high[rates_total-1];
    priceLow[rates_total-1]  = low[rates_total-1];
    
    for (i = rates_total-1; i > 0 ; i--)
     { 
       trendLineDown[i] = 0;
       trendLineUp[i] = 0;
       priceHigh[i] = high[i];
       priceLow[i]  = low[i];
       
      if (flag_down==2)
       {

        if (i>=point_down_left.n_bar)
         trendLineDown[i] = point_down_left.price+(i-point_down_left.n_bar)*tg_down;
       }
      if (flag_up==2)
       {
        if (i>=point_up_left.n_bar)
         trendLineUp[i] = point_up_left.price+(i-point_up_left.n_bar)*tg_up;
       }    
     }

   return(rates_total);
  }