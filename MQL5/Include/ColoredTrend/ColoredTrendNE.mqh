//+------------------------------------------------------------------+
//|                                                 ColoredTrend.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <CLog.mqh>
#include <CompareDoubles.mqh>
#include "ColoredTrendUtilities.mqh"
#include <StringUtilities.mqh>

#define AMOUNT_OF_PRICE 2
#define AMOUNT_BARS_FOR_HUGE 100

CLog log_output(OUT_COMMENT, LOG_NONE, 50, "PBI", 30);

//+------------------------------------------------------------------+
//| ��������������� ����� ��� ���������� ColoredTrend                |
//+------------------------------------------------------------------+
class CColoredTrend
{
protected:
  string _symbol;
  ENUM_TIMEFRAMES _period;
  ENUM_MOVE_TYPE enumMoveType[];
  ENUM_MOVE_TYPE previous_move_type;
  int digits;
  SExtremum num0, 
            num1, 
            num2;  // ������ ��������� �����������
  SExtremum lastOnTrend;       // ��������� ��������� �������� ������  
  double _percentage_ATR;
  double _startDayPrice;
  double difToNewExtremum;
  double difToTrend;     // �� ������� ��� ����� ��� ������ ��������� ���������� ���������, ��� �� ������� �����.
  int _depth;            // ���������� ����� ��� ������� ���������� 
  int ATR_handle;
  double buffer_ATR[];
  MqlRates buffer_Rates[];
  datetime time_buffer[];
  
  int FillTimeSeries(ENUM_TF tfType, int count, int start_pos, MqlRates &array[]);
  int FillATRBuf(int count, int start_pos);
  
  bool isCorrectionEnds(double price, ENUM_MOVE_TYPE move_type, int start_pos);
  int isLastBarHuge(int start_pos);
  int isNewTrend();
  int isEndTrend();
public:
  void CColoredTrend(string symbol, ENUM_TIMEFRAMES period, int depth, double percentage_ATR, double dif, int ATR_ma_period);
  SExtremum isExtremum(int start_index);
  bool FindExtremumInHistory(int depth);
  bool CountMoveType(int bar, int start_pos, SExtremum &extremum, ENUM_MOVE_TYPE topTF_Movement = MOVE_TYPE_UNKNOWN);
  ENUM_MOVE_TYPE GetMoveType(int i);
  int TrendDirection();
  void Zeros();
};

//+-----------------------------------------+
//| �����������                             |
//+-----------------------------------------+
void CColoredTrend::CColoredTrend(string symbol, ENUM_TIMEFRAMES period, int depth, double percentage_ATR, double dif, int ATR_ma_period) : 
                   _symbol(symbol),
                   _period(period),
                   _depth(depth),
                   _percentage_ATR(percentage_ATR),
                   previous_move_type(MOVE_TYPE_UNKNOWN),
                   difToTrend(dif)
{
 num0.direction = 0;
 num1.direction = 0;
 num2.direction = 0;
 num0.price = -1;
 num1.price = -1;
 num2.price = -1;
 
 MqlRates buffer[1];
 CopyRates(_symbol, _period, _depth, 1, buffer);
 CopyTime(_symbol, _period, _depth, 1, time_buffer);
 _startDayPrice = buffer[0].close;
 ATR_handle = iATR(_symbol, _period, ATR_ma_period);
 digits = (int)SymbolInfoInteger(_symbol, SYMBOL_DIGITS);
 ArrayResize(enumMoveType, depth);
 ArrayInitialize(enumMoveType, 0);
 log_output.Write(LOG_DEBUG, StringFormat("%s ����������� ������ CColoredTrend", EnumToString(_period)));
}

//+--------------------------------------+
//| ������� ��������� ��� �������� ����� |
//+--------------------------------------+
bool CColoredTrend::CountMoveType(int bar, int start_pos, SExtremum &extremum, ENUM_MOVE_TYPE topTF_Movement = MOVE_TYPE_UNKNOWN)
{
 if(bar == 0) //�� "�������" ���� ������ ����������� �� ����� � ������ ������� ������� ��� �� ������ �������� � ����������
  return (true); 

 if(bar == ArraySize(enumMoveType))  // ������� ������ ��� ������ �����������
  ArrayResize(enumMoveType, ArraySize(enumMoveType)*2, ArraySize(enumMoveType)*2);
  
 if(FillTimeSeries(CURRENT_TF, AMOUNT_OF_PRICE, start_pos, buffer_Rates) < 0) // ������� ������ ������������ �������
  return (false); 
 if(FillATRBuf(2, start_pos) < 0) // �������� ������ ������� ���������� ATR
  return (false);  
 
 CopyTime(_symbol, _period, start_pos, 1, time_buffer);  
 enumMoveType[bar] = previous_move_type;
 difToNewExtremum = buffer_ATR[0] * _percentage_ATR;
 SExtremum current_bar = {0, -1};
 
 int newTrend = 0;  
 current_bar = isExtremum(start_pos); 
 if (current_bar.direction != 0)
 {
  extremum = current_bar;
  if (current_bar.direction == num0.direction) // ���� ����� ��������� � ��� �� ����������, ��� ������
  {
   num0.price = current_bar.price;
  }
  else
  {
   num2 = num1;
   num1 = num0;
   num0 = current_bar;
  } 
  //log_output.Write(LOG_DEBUG, StringFormat("%s %s ATR = %.05f;  num0 = {%d, %.05f}; num1 = {%d, %.05f}; num2 = {%d, %.05f};", EnumToString(_period), TimeToString(time_buffer[0]), difToNewExtremum, num0.direction, num0.price, num1.direction, num1.price, num2.direction, num2.price));
  newTrend = isNewTrend();        
 }
 
 // �������� �� ������� 3� �����������. ����� ���� ��� ���� �����������
 if (num2.direction == 0 && num2.price == -1) //���������� (num0 > 0 && num1 > 0 && num2 > 0) �.�. num2 �� ����������� ���� �� ����������� num0 � num1
 {
  //log_output.Write(LOG_MAIN, StringFormat("%s %s �� ��������� 3 ����������. i = %d; start_pos = %d; num0 = {%d, %f}; num1 = {%d, %f}; num2 = {%d, %f};", EnumToString(_period), TimeToString(time_buffer[0]), bar, start_pos, num0.direction, num0.price, num1.direction, num1.price, num2.direction, num2.price));
  return (true); 
 } 
  
 if (newTrend == -1 && enumMoveType[bar] != MOVE_TYPE_TREND_DOWN_FORBIDEN && enumMoveType[bar] != MOVE_TYPE_TREND_DOWN)
 {// ���� ������� ����� ��������� (0) � ������������� (1) ����������� � "difToTrend" ��� ������ ������ ��������
  //log_output.Write(LOG_MAIN, StringFormat("%s %s ��������� ������� isNewTrend DOWN �� %d ����. ������� �������� = %s", EnumToString(_period), TimeToString(time_buffer[0]), bar, MoveTypeToString(enumMoveType[bar])));
  //log_output.Write(LOG_DEBUG, StringFormat("%s %s �� ������� �� �������� %s", EnumToString(_period), TimeToString(time_buffer[0]), MoveTypeToString(topTF_Movement))); 
  enumMoveType[bar] = (topTF_Movement == MOVE_TYPE_FLAT) ? MOVE_TYPE_TREND_DOWN_FORBIDEN : MOVE_TYPE_TREND_DOWN;
  previous_move_type = enumMoveType[bar];
  return (true);
 }
 else if (newTrend == 1 && enumMoveType[bar] != MOVE_TYPE_TREND_UP_FORBIDEN && enumMoveType[bar] != MOVE_TYPE_TREND_UP) // ���� ������� �������� ���� ���������� ���������� 
 {
  //log_output.Write(LOG_MAIN, StringFormat("%s %s ��������� ������� isNewTrend UP �� %d ����. ������� �������� = %s", EnumToString(_period), TimeToString(time_buffer[0]), bar, MoveTypeToString(enumMoveType[bar])));
  //log_output.Write(LOG_DEBUG, StringFormat("%s %s �� ������� �� �������� %s", EnumToString(_period), TimeToString(time_buffer[0]), MoveTypeToString(topTF_Movement))); 
  enumMoveType[bar] = (topTF_Movement == MOVE_TYPE_FLAT) ? MOVE_TYPE_TREND_UP_FORBIDEN : MOVE_TYPE_TREND_UP;
  previous_move_type = enumMoveType[bar];
  return (true);
 }
 else 
 {
  if(enumMoveType[bar] == MOVE_TYPE_UNKNOWN)
  {
   //log_output.Write(LOG_MAIN, StringFormat("%s %s ���������� �������� �� ���� ����������. ������ FLAT", EnumToString(_period), TimeToString(time_buffer[0])));
   enumMoveType[bar] = MOVE_TYPE_FLAT;
   previous_move_type = enumMoveType[bar];
   return (true);
  }
 }
 
 //������ ��������� ���� ���� ���� �������� ������ ���� �������� 
 if ((enumMoveType[bar] == MOVE_TYPE_TREND_UP || enumMoveType[bar] == MOVE_TYPE_TREND_UP_FORBIDEN) && 
      LessDoubles(buffer_Rates[AMOUNT_OF_PRICE-1].close, buffer_Rates[AMOUNT_OF_PRICE-1].open, digits))
 {
  //log_output.Write(LOG_MAIN, StringFormat("%s %s bar = %d, ���������� ����� �����(�������� ��������� ����), ������� ��������=%.05f; ������� ��������=%.05f", EnumToString(_period), TimeToString(time_buffer[0]), bar, buffer_Rates[AMOUNT_OF_PRICE-1].close, buffer_Rates[AMOUNT_OF_PRICE-1].open));
  enumMoveType[bar] = MOVE_TYPE_CORRECTION_DOWN;
  if (num0.direction > 0) 
   lastOnTrend = num0; 
  else 
   lastOnTrend = num1;
  previous_move_type = enumMoveType[bar];
  return (true);
 }
 //������ ��������� ����� ���� ���� �������� ������ �������� ����������� ����
 if ((enumMoveType[bar] == MOVE_TYPE_TREND_DOWN || enumMoveType[bar] == MOVE_TYPE_TREND_DOWN_FORBIDEN) && 
      GreatDoubles(buffer_Rates[AMOUNT_OF_PRICE-1].close, buffer_Rates[AMOUNT_OF_PRICE-1].open, digits))
 {
  log_output.Write(LOG_MAIN, StringFormat("%s %s bar = %d, ���������� ����� ����(�������� ��������� �����), ������� ��������=%.05f; ������� ��������=%.05f", EnumToString(_period), TimeToString(time_buffer[0]), bar, buffer_Rates[AMOUNT_OF_PRICE-1].close, buffer_Rates[AMOUNT_OF_PRICE-1].open));
  enumMoveType[bar] = MOVE_TYPE_CORRECTION_UP;
  if (num0.direction < 0) 
   lastOnTrend = num0; 
  else 
   lastOnTrend = num1;
  previous_move_type = enumMoveType[bar];
  return (true);
 }
 
 //��������� �������� �� ����� �����/���� ��� ����������� ������� isCorrectionEnds
 //���� ��������� ���� ������/������ ���������� ��������� ��� �� ������� �� "�������" ���
 if ((enumMoveType[bar] == MOVE_TYPE_CORRECTION_UP) && 
      isCorrectionEnds(buffer_Rates[AMOUNT_OF_PRICE-1].close, enumMoveType[bar], start_pos))                       
 {
  enumMoveType[bar] = (topTF_Movement == MOVE_TYPE_FLAT) ? MOVE_TYPE_TREND_DOWN_FORBIDEN : MOVE_TYPE_TREND_DOWN;
  log_output.Write(LOG_MAIN, StringFormat("%s %s bar = %d, ����������� ��������� �����(������� ����� ����), ��������� ����=%.05f ������ ���������� ����������=%.05f", EnumToString(_period), TimeToString(time_buffer[0]), bar, buffer_Rates[AMOUNT_OF_PRICE-1].close, lastOnTrend.price));
  //log_output.Write(LOG_DEBUG, StringFormat("%s %s num0 = {%d, %.05f}; num1 = {%d, %.05f}; num2 = {%d, %.05f};", EnumToString(_period), TimeToString(time_buffer[0]), num0.direction, num0.price, num1.direction, num1.price, num2.direction, num2.price));
  previous_move_type = enumMoveType[bar];
  return (true);
 }
 
 if ((enumMoveType[bar] == MOVE_TYPE_CORRECTION_DOWN) && 
      isCorrectionEnds(buffer_Rates[AMOUNT_OF_PRICE-1].close, enumMoveType[bar], start_pos))
 {
  enumMoveType[bar] = (topTF_Movement == MOVE_TYPE_FLAT) ? MOVE_TYPE_TREND_UP_FORBIDEN : MOVE_TYPE_TREND_UP;
  log_output.Write(LOG_MAIN, StringFormat("%s %s bar = %d, ����������� ��������� ����(������� ����� �����), ��������� ����=%.05f ������ ���������� ����������=%.05f", EnumToString(_period), TimeToString(time_buffer[0]), bar, buffer_Rates[AMOUNT_OF_PRICE-1].close, lastOnTrend.price));
  //log_output.Write(LOG_DEBUG, StringFormat("%s %s num0 = {%d, %.05f}; num1 = {%d, %.05f}; num2 = {%d, %.05f};", EnumToString(_period), TimeToString(time_buffer[0]), num0.direction, num0.price, num1.direction, num1.price, num2.direction, num2.price));
  previous_move_type = enumMoveType[bar];
  return (true);
 }

 if (((previous_move_type == MOVE_TYPE_TREND_DOWN || previous_move_type == MOVE_TYPE_CORRECTION_DOWN  ) && isEndTrend() == 1) || 
     ((previous_move_type == MOVE_TYPE_TREND_UP   || previous_move_type == MOVE_TYPE_CORRECTION_UP) && isEndTrend() == -1))   
 {
  if(num1.direction < 0) log_output.Write(LOG_MAIN, StringFormat("%s %s bar = %d, ������� ����, ����� �������� ������ ���������� ����������� num2-num1=%.05f*2 > num0-num1=%.05f", EnumToString(_period), TimeToString(time_buffer[0]), bar, (num2.price-num1.price), (num0.price-num1.price)));
  if(num1.direction > 0) log_output.Write(LOG_MAIN, StringFormat("%s %s bar = %d, ������� ����, ����� �������� ������ ���������� ����������� num1-num2=%.05f*2 > num0-num1=%.05f", EnumToString(_period), TimeToString(time_buffer[0]), bar, (num1.price-num2.price), (num1.price-num0.price)));
  log_output.Write(LOG_DEBUG, StringFormat("%s %s num0 = {%d, %.05f}; num1 = {%d, %.05f}; num2 = {%d, %.05f};", EnumToString(_period), TimeToString(time_buffer[0]), num0.direction, num0.price, num1.direction, num1.price, num2.direction, num2.price));
  enumMoveType[bar] = MOVE_TYPE_FLAT;
  previous_move_type = enumMoveType[bar];
  return (true);
 }
 
 return (true);
}
 
//+----------------------------------------------------+
//| ������� �������� ������� �� ������� ����� �������� |
//+----------------------------------------------------+
ENUM_MOVE_TYPE CColoredTrend::GetMoveType(int i)
{
 if(i < 0 || i >= ArraySize(enumMoveType))
 {
  Alert(StringFormat("%s i = %d; period = %s; ArraySize = %d", MakeFunctionPrefix(__FUNCTION__), i, EnumToString((ENUM_TIMEFRAMES)_period), ArraySize(enumMoveType)));
  return(MOVE_TYPE_UNKNOWN);
 }
 return(enumMoveType[i]);
}
//+--------------------------------------------------------------------+
//| ������� ���������� ����������� � �������� ���������� � ������ �����|
//+--------------------------------------------------------------------+
SExtremum CColoredTrend::isExtremum(int start_index)
{
 SExtremum result = {0,0};
 MqlRates buffer[1];
 CopyRates(_symbol, _period, start_index, 1, buffer);
 double high = 0, low = 0;
 
 if (start_index == 0)
 {
  high = buffer[0].close;
  low = buffer[0].close;
 }
 else
 {
  high = buffer[0].high;
  low = buffer[0].low;
 }
 if (((num0.direction == 0) && (GreatDoubles(high, _startDayPrice + 2*difToNewExtremum, digits))) // ���� ����������� ��� ��� � ���� 2 ���� �� ��������� ����
   || (num0.direction > 0 && (GreatDoubles(high, num0.price, digits)))
   || (num0.direction < 0 && (GreatDoubles(high, num0.price + difToNewExtremum, digits))))
 {
  result.direction = 1;
  result.price = high;
 }
 
 if (((num0.direction == 0) && (LessDoubles(low, _startDayPrice - 2*difToNewExtremum, digits))) // ���� ����������� ��� ��� � ���� 2 ���� �� ��������� ����
   || (num0.direction < 0 && (LessDoubles(low, num0.price, digits)))
   || (num0.direction > 0 && (LessDoubles(low, num0.price - difToNewExtremum, digits))))
 {
  result.direction = -1;
  result.price = low;
 }
 
 //log_output.Write(LOG_DEBUG, StringFormat("start_pos = %d; num0 = {%d, %.05f}; num1 = {%d, %.05f}; num2 = {%d, %.05f};", start_index, num0.direction, num0.price, num1.direction, num1.price, num2.direction, num2.price));
 return(result);
}


//+-------------------------------------------------+
//| ������� ��������� ������ ��� �� �������         |
//+-------------------------------------------------+
int CColoredTrend::FillTimeSeries(ENUM_TF tfType, int count, int start_pos, MqlRates &array[])
{
//--- ������� �����������
 int copied = 0;
 ENUM_TIMEFRAMES period;
 switch (tfType)
 {
  case BOTTOM_TF: 
   period = GetBottomTimeframe(_period);
   break;
  case CURRENT_TF:
   period = _period;
   break;
  case TOP_TF:
   period = GetTopTimeframe(_period);
   break;
 }
 
 copied = CopyRates(_symbol, period, start_pos, count, array); // ������ ������ �� 0 �� count-1, ����� count ���������
//--- ���� �� ������� ����������� ����������� ���������� �����
 if(copied < count)
 {
  string comm = StringFormat("%s ��� ������� %s �������� %d ����� �� %d ������������� Rates. Period = %s. Error = %d | start = %d count = %d",
                             MakeFunctionPrefix(__FUNCTION__),
                             _symbol,
                             copied,
                             count,
                             EnumToString((ENUM_TIMEFRAMES)period),
                             GetLastError(),
                             start_pos,
                             count
                            );
  //--- ������� ��������� � ����������� �� ������� ���� �������
  Print(comm);
 }
 return(copied);
}

//+----------------------------------------------------+
//| ������� ��������� ������ ���������� ATR �� ������� |
//+----------------------------------------------------+
int CColoredTrend::FillATRBuf(int count, int start_pos = 0)
{
 if(ATR_handle == INVALID_HANDLE)                      //��������� ������� ������ ����������
 {
  Print("�� ������� �������� ����� ATR");             //���� ����� �� �������, �� ������� ��������� � ��� �� ������
 }
 //--- ������� �������
 int attempts = 0;
//--- ������� �����������
 int copied = 0;
//--- ������ 25 ������� �������� ��������� �� ������� �������
 copied = CopyBuffer(ATR_handle, 0, start_pos, count, buffer_ATR);

//--- ���� �� ������� ����������� ����������� ���������� �����
 if(copied < count)
 {
  string comm = StringFormat("%s ��� ������� %s �������� %d ����� �� %d ������������� ATR. Period = %s.  Error = %d | start = %d count = %d bars_calculated = %d",
                             MakeFunctionPrefix(__FUNCTION__),
                             _symbol,
                             copied,
                             count,
                             EnumToString((ENUM_TIMEFRAMES)_period),
                             GetLastError(),
                             start_pos,
                             count,
                             BarsCalculated(ATR_handle)
                            );
  //--- ������� ��������� � ����������� �� ������� ���� �������
  Print(comm);
 }
 return(copied);
}

//+----------------------------------------------------+
//| ������� ��������� ������� ������ �� ���������      |
//+----------------------------------------------------+
bool CColoredTrend::isCorrectionEnds(double price, ENUM_MOVE_TYPE move_type, int start_pos)
{
 bool extremum_condition = false, 
      bottomTF_condition = false;
 if (move_type == MOVE_TYPE_CORRECTION_UP)
 {
  extremum_condition = LessDoubles(price, lastOnTrend.price, digits);
  if(isLastBarHuge(start_pos) > 0) bottomTF_condition = true;
  //if(extremum_condition) log_output.Write(LOG_DEBUG, StringFormat("%s %s %.05f %s UP Extremum condition success: %.05f < %.05f", EnumToString(_period), TimeToString(time_buffer[0]), price, TimeToString(time_buffer[0]), price, lastOnTrend.price));
  //if(bottomTF_condition) log_output.Write(LOG_DEBUG, StringFormat("%s %s %.05f %s UP BottomTF condition success", EnumToString(_period), TimeToString(time_buffer[0]), price, TimeToString(time_buffer[0])));
 }
 if (move_type == MOVE_TYPE_CORRECTION_DOWN)
 {
  extremum_condition = GreatDoubles(price, lastOnTrend.price, digits);
  if(isLastBarHuge(start_pos) < 0) bottomTF_condition = true;
  //if(extremum_condition) log_output.Write(LOG_DEBUG, StringFormat("%s %s %.05f %s DOWN Extremum condition success: %.05f > %.05f", EnumToString(_period), TimeToString(time_buffer[0]), price, TimeToString(time_buffer[0]), price, lastOnTrend.price));
  //if(bottomTF_condition) log_output.Write(LOG_DEBUG, StringFormat("%s %s %.05f %s DOWN BottomTF condition success", EnumToString(_period), TimeToString(time_buffer[0]), price, TimeToString(time_buffer[0])));
 }
 
 return ((extremum_condition) || (bottomTF_condition));
}

//+----------------------------------------------------------------+
//| ������� ���������� �������� �� ��� "�������" � ��� ����������� |
//+----------------------------------------------------------------+
int CColoredTrend::isLastBarHuge(int start_pos)
{
 if(_period == PERIOD_M1) return(0);
 double sum = 0;
 MqlRates rates[];
 FillTimeSeries(BOTTOM_TF, AMOUNT_BARS_FOR_HUGE, start_pos, rates);
 int size = ArraySize(rates);
 for(int i = 0; i < size - 1; i++)
 {
  sum = sum + rates[i].high - rates[i].low;  
 }
 double avgBar = sum / size;
 double lastBar = MathAbs(rates[size-1].open - rates[size-1].close);
    
 if(GreatDoubles(lastBar, avgBar*2))
 {
  if(GreatDoubles(rates[size-1].open, rates[size-1].close, digits))
  {
//   log_output.Write(LOG_DEBUG, StringFormat("%s %s avgBar = %.05f ; lastBar = %.05f; openLB = %.05f", EnumToString(_period), TimeToString(time_buffer[0]), avgBar, lastBar, rates[_depth-1].open));
//   log_output.Write(LOG_DEBUG, StringFormat("%s %s open = %.05f, close = %.05f", EnumToString(_period), TimeToString(time_buffer[0]), rates[_depth-1].open, rates[_depth-1].close));
   return(1);
  }
  if(LessDoubles(rates[size-1].open, rates[size-1].close, digits))
  {
//   log_output.Write(LOG_DEBUG, StringFormat("%s %s avgBar = %.05f ; lastBar = %.05f; openLB = %.05f", EnumToString(_period), TimeToString(time_buffer[0]), avgBar, lastBar, rates[_depth-1].open));
//    log_output.Write(LOG_DEBUG, StringFormat("%s %s open = %.05f, close = %.05f", EnumToString(_period), TimeToString(time_buffer[0]), rates[_depth-1].open, rates[_depth-1].close));
   return(-1);
  }
  
 }
 return(0);
}

//+----------------------------------------------------+
//| ������� ���������� ������ ������                   |
//+----------------------------------------------------+
int CColoredTrend::isNewTrend()
{
 if (num1.direction < 0 && LessDoubles((num2.price - num1.price)*difToTrend ,(num0.price - num1.price), digits))
  return(1);
 if (num1.direction > 0 && LessDoubles((num1.price - num2.price)*difToTrend ,(num1.price - num0.price), digits))
  return(-1);
  
 return(0);
}

//+----------------------------------------------------------+
//| ������� ���������� ����� ������/��������� (������ �����) |
//+----------------------------------------------------------+
int CColoredTrend::isEndTrend()
{
 if (num1.direction < 0 && GreatDoubles((num2.price - num1.price)*difToTrend ,(num0.price - num1.price), digits))
  return(1);
 if (num1.direction > 0 && GreatDoubles((num1.price - num2.price)*difToTrend ,(num1.price - num0.price), digits))
  return(-1);
  
 return(0);
}

//+-------------------------------------------------------------+
//| ������� ��������� ������ ����� �������� ��������� ��������� |
//+-------------------------------------------------------------+
void CColoredTrend::Zeros()
{
  SExtremum zero = {0, 0};
 
  for(int i = 0; i < ArraySize(enumMoveType); i++)
  {
   enumMoveType[i] = MOVE_TYPE_UNKNOWN;
  }
}