//+------------------------------------------------------------------+
//|                                                  RunBackTest.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property script_show_inputs 
#include <TradeManager\BackTest.mqh>    //���������� ���������� ��������
#include <StringUtilities.mqh>        
#include <kernel32.mqh>                 //��� WIN API �������
 
//+------------------------------------------------------------------+
//| ������ ��������� ���������� ���������� ����������                |
//+------------------------------------------------------------------+

// ���������, �������� �������������

input string   file_catalog = "C:\\Taki";              // ����� �������� � ���������� TAKI
input string   url_list  = "C:\\";                     // ����� �������� url �������
input datetime time_from    = 0;                       // � ������ �������
input datetime time_to      = 0;                       // �� ����� �����

//---- ���������� ���������� � �������

// ������ ���� ���������
string robotArray[3] =
 {
  "condom",
  "TIHIRO",
  "FollowWhiteRabbit"
 };

// ������ ��������

string symbolArray[6] =
 {
  "EURUSD",
  "GBPUSD",
  "USDCHF",
  "USDJPY",
  "USDCAD",
  "AUDUSD"
 };
 
// ������ �����������
 
ENUM_TIMEFRAMES periodArray[20] =
 {
   PERIOD_M1,
   PERIOD_M2,
   PERIOD_M3,
   PERIOD_M4,
   PERIOD_M5,
   PERIOD_M6,
   PERIOD_M10,
   PERIOD_M12,
   PERIOD_M15,
   PERIOD_M20,
   PERIOD_M30,
   PERIOD_H1,
   PERIOD_H2,
   PERIOD_H3,
   PERIOD_H4,
   PERIOD_H6,
   PERIOD_H8,
   PERIOD_D1,
   PERIOD_W1,
   PERIOD_MN1 
 }; 

//---- ������� ���������� ������ ����� ������� 
 
string GetFileHistory (int n_robot, int n_symbol, int n_period)
 {
  return robotArray[n_robot]+"/"+"History"+"/"+robotArray[n_robot]+"_"+symbolArray[n_symbol]+"_"+PeriodToString(periodArray[n_period])+".csv";
 } 
 
//---- ������� ���������� ����� ����� ����������� ���������� �������� 
 
string GetBackTestFileName (int n_robot, int n_symbol, int n_period)
 {
  string str="";
  str = StringFormat("\dat\%s_%s_%s[%s,%s].dat", robotArray[n_robot], symbolArray[n_symbol], PeriodToString(periodArray[n_period]), TimeToString(time_from),TimeToString(time_to));
  StringReplace(str," ","_");
  StringReplace(str,":",".");  
  str = file_catalog+str;
  return str;
 } 
 
//---- ������� ���������� ����� ����� ������ URL �������

string GetBacktestUrlList ()
 {
   return url_list+"/"+"_backtest_.dat";
 }
 
//---- ������� ���������� ����� ���������� TAKI

string GetTAKIUrl ()
 {
   return "cmd /C start "+file_catalog+"/"+"TAKI.exe";
 }


void OnStart()
{
 uchar    val[];
 string   backtest_file;    // ���� ����������
 string   history_url;      // ����� ����� �������
 string   url_backtest;     // ����� ����� ������ url � ������ ��������
 string   url_TAKI;         // ����� TAKI ����������
 // ������ ����������
 int      file_handle;      // ����� ����� ������ URL ������ ���������
 int      i_rob,i_sym,i_per;// ���������� ������� ��� ������� �� �����
 int      robots_n;         // ���������� ������� 
 int      symbols_n;        // ���������� ��������
 int      period_n;         // ���������� ��������
 bool     flag;             // ���� �������� �������� �������� �������
 bool     flag_backtest;    // ���� �������� ������������ ����� ����������
 
 // ������������� ����������
 robots_n  = ArraySize(robotArray);
 symbols_n = ArraySize(symbolArray);
 period_n  = ArraySize(periodArray);
 
 //Alert("N_ROBOTS = ",robots_n,);
   
 // ��������� �������� url ������ ������
 url_backtest  = GetBacktestUrlList ();       // ��������� ���� ������ url ������ ��������
 url_TAKI      = GetTAKIUrl ();               // ��������� ���� �������� � ����������
 
 
 BackTest backtest;         // ������ ������ ��������
 // ��������� ���� ������ URL ������� ��������
 file_handle   = CreateFileW(url_backtest, _GENERIC_WRITE_, _FILE_SHARE_WRITE_, 0, _CREATE_ALWAYS_, 128, NULL); 
 Comment("");
 WriteTo(file_handle,file_catalog+"\ ");  
 // �������� �� ������ � ��������� ���� �������
 for (i_rob=0;i_rob < robots_n; i_rob ++ )
  {
     Alert("����� = ",i_rob);
   for (i_sym=0;i_sym < symbols_n; i_sym ++)
    {
     for (i_per=0;i_per < period_n; i_per ++)
      {
       
       // ��������� ����� ����� �������
       history_url = GetFileHistory (i_rob,i_sym,i_per);
      // Alert("���� ������� = ",history_url);
       // �������� ������� ������� �� ����� 
       flag = backtest.LoadHistoryFromFile(history_url,time_from,time_to);
            // Alert("���� �������� [",i_sym,",",i_per,"]");
       // ���� ���� ������� ������� ��������
       if (flag)
         {
         Alert("�������� [",i_sym,",",i_per,"]");
          // ��������� ���� ���������
          backtest_file = GetBackTestFileName (i_rob,i_sym,i_per);
        //  Alert("BACKTEST = ",backtest_file);
          // ��������� ���� ��������
          flag_backtest = backtest.SaveBackTestToFile(backtest_file,symbolArray[i_sym],periodArray[i_per],robotArray[i_rob]);
          Alert("���� �������� [",i_sym,",",i_per,"]");
          // ������� ���� �������
         
          backtest.DeleteHistory();
          if (flag_backtest)
           {
            // ��������� URL � ���� ������ URL ��������
            Comment("");
            WriteTo(file_handle,backtest_file+" ");
           }
         }
        else
         {
          Comment("�� ������� ������� ������� �� �����");
         }         
        
        
      }
        
    }
  
  }
  
  Alert("����� �� ������");

 //��������� ���� ������ url
 CloseHandle(file_handle);

  if (flag_backtest)
   {
    // ��������� ���������� ����������� ����������� ��������
    StringToCharArray ( url_TAKI,val);
    WinExec(val, 1);
   }  

}