//+------------------------------------------------------------------+
//|                                                CTradeManager.mq5 |
//|                                              Copyright 2013, GIA |
//|                                             http://www.saita.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, GIA"
#property link      "http://www.saita.net"
#property version   "1.00"

#include "TradeManagerEnums.mqh"
#include "PositionOnPendingOrders.mqh"
#include "PositionArray.mqh"
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <CompareDoubles.mqh>
#include <CLog.mqh>

int error = 0;
//+------------------------------------------------------------------+
//| ����� ������������ ��������������� �������� ����������           |
//+------------------------------------------------------------------+
class CTradeManager
{
protected:
  CPosition *position;
  ulong _magic;
  bool _useSound;
  string _nameFileSound;   // ������������ ��������� �����
  
  CPositionArray _positionsToReProcessing;
  CPositionArray _openPositions; ///< Array of open virtual orders for this VOM instance, also persisted as a file
  //CPositionArray _positionsHistory; ///< Array of closed virtual orders, also persisted as a file
  
public:
  void CTradeManager():  _useSound(true), _nameFileSound("expert.wav") 
  {
   _magic = MakeMagic(); 
   log_file.Write(LOG_DEBUG, "�������� ������� CTradeManager"); 
  };
  
  bool OpenPosition(string symbol, ENUM_TM_POSITION_TYPE type,double volume ,int sl, int tp, 
                    int minProfit, int trailingStop, int trailingStep, int priceDifference = 0);
  void ModifyPosition(ENUM_TRADE_REQUEST_ACTIONS trade_action);
  bool ClosePosition(long ticket, color Color=CLR_NONE); // �������� ������� �� ������
  bool ClosePosition(int i,color Color=CLR_NONE);  // �������� ������� �� ������� � ������� ������� 
  bool CloseReProcessingPosition(int i,color Color=CLR_NONE);
  long MakeMagic(string strSymbol = "");
  void DoTrailing();
  void Initialization();
  void Deinitialization();
  void OnTick();
  void OnTrade(datetime history_start);
  void SaveSituationToFile(bool debug = false);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradeManager::OpenPosition(string symbol, ENUM_TM_POSITION_TYPE type, double volume,int sl, int tp, 
                                 int minProfit, int trailingStop, int trailingStep, int priceDifferense = 0)
{
 if (_positionsToReProcessing.Total() > 0) 
 {
  log_file.Write(LOG_DEBUG, "���������� ������� ������� ��� ��� ��� ���� ������� � positionsToReProcessing.");
  return false;
 }

 int i = 0;
 int total = _openPositions.Total();
 log_file.Write(LOG_DEBUG
               ,StringFormat("%s, ��������� ������� %s. �������� ������� �� ������ ������: %d"
                            , MakeFunctionPrefix(__FUNCTION__), GetNameOP(type), total));
 log_file.Write(LOG_DEBUG, _openPositions.PrintToString());
 switch(type)
 {
  case OP_BUY:
   if (total > 0)
   {
    for (i = total - 1; i >= 0; i--) // ��������� ��� ������ ��� ������� �� �������
    {
     CPosition *pos = _openPositions.At(i);
     //PrintFormat("������� %d-� ������� ������=%s, �����=%d", i, pos.getSymbol(), pos.getMagic());
     if ((pos.getSymbol() == symbol) && (pos.getMagic() == _magic))
     {
      if (pos.getType() == OP_SELL || pos.getType() == OP_SELLLIMIT || pos.getType() == OP_SELLSTOP)
      {
       ClosePosition(i);
      }
     }
    }
   }
   break;
  case OP_SELL:
   if (total > 0)
   {
    for (i = total - 1; i >= 0; i--) // ��������� ��� ������ ��� ������� �� �������
    {
     CPosition *pos = _openPositions.At(i);
     if ((pos.getSymbol() == symbol) && (pos.getMagic() == _magic))
     {
      if (pos.getType() == OP_BUY || pos.getType() == OP_BUYLIMIT || pos.getType() == OP_BUYSTOP)
      {
       ClosePosition(i);
      }
     }
    }
   }
   break;
  default:
   log_file.Write(LOG_DEBUG, StringFormat("%s Error: Invalid ENUM_VIRTUAL_ORDER_TYPE", MakeFunctionPrefix(__FUNCTION__)));
   break;
 }
 
 total = _openPositions.Total() + _positionsToReProcessing.Total();
 if (total <= 0)
 {
  log_file.Write(LOG_DEBUG, StringFormat("%s openPositions � positionsToReProcessing ����� - ��������� ����� �������", MakeFunctionPrefix(__FUNCTION__)));
  position = new CPosition(_magic, symbol, type, volume, sl, tp, minProfit, trailingStop, trailingStep, priceDifferense);
  ENUM_POSITION_STATUS openingResult = position.OpenPosition();
  if (openingResult == POSITION_STATUS_OPEN || openingResult == POSITION_STATUS_PENDING) // ������� ���������� �������� �������
  {
   log_file.Write(LOG_DEBUG, StringFormat("%s, magic=%d, symb=%s, type=%s, price=%.05f vol=%.02f, sl=%.06f, tp=%.06f", MakeFunctionPrefix(__FUNCTION__),position.getMagic(), position.getSymbol(), GetNameOP(position.getType()), position.getPositionPrice(), position.getVolume(), position.getStopLossPrice(), position.getTakeProfitPrice()));
   _openPositions.Add(position);
   SaveSituationToFile();
   log_file.Write(LOG_DEBUG, StringFormat("%s %s", MakeFunctionPrefix(__FUNCTION__), _openPositions.PrintToString()));
   return(true); // ���� ������ ������� �������
  }
  else
  {
   error = GetLastError();
   _positionsToReProcessing.Add(position);
   log_file.Write(LOG_DEBUG, StringFormat("%s �� ������� ������� �������.Error{%d} = %s", MakeFunctionPrefix(__FUNCTION__), error, ErrorDescription(error)));
   return(false); // ���� ������� ������� �� �������
  }
 }
 log_file.Write(LOG_DEBUG, StringFormat("%s �������� �������� ������� %d", MakeFunctionPrefix(__FUNCTION__), total));
 return(true); // ���� �������� �������� �������, ������ �� ���� ����������� 
}
//+------------------------------------------------------------------+ 
// ������� ���������� ���������� ���������
//+------------------------------------------------------------------+
void CTradeManager::DoTrailing()  //TO DO LIST : �������� ������������
{
 int total = _openPositions.Total();
 ulong ticket = 0, slTicket = 0;
 long type = -1;
 double newSL = 0;

//--- ������� � ����� �� ���� �������
 for(int i = 0; i < total; i++)
 {
  CPosition *pos = _openPositions.At(i);
  pos.DoTrailing();
 } 
};
//+------------------------------------------------------------------+ 
// ������� ����������� �������
//+------------------------------------------------------------------+
void CTradeManager::ModifyPosition(ENUM_TRADE_REQUEST_ACTIONS trade_action)
{
};

//+------------------------------------------------------------------+
/// Called from EA OnTrade().
/// Actions virtual stoplosses, takeprofits \n

/// Include the folowing in each EA that uses TradeManager
//+------------------------------------------------------------------+
void CTradeManager::OnTrade(datetime history_start)
  {
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CTradeManager::OnTick()
{
 MqlTick tick;
 SymbolInfoTick(Symbol(), tick);
 ENUM_TM_POSITION_TYPE type;
 int size = _openPositions.Total();
 for(int i = size - 1; i>=0; i--) // �� ������� ����� �������
 {
  position = _openPositions.At(i); // ������� ������� �� �� �������
  type = position.getType();
    
  if (!OrderSelect(position.getStopLossTicket())) // ���� �� �� ����� ������� ���� �� ��� ������, ������ �� ��������
  {
   log_file.Write(LOG_DEBUG, StringFormat("%s ��� ������-StopLoss", MakeFunctionPrefix(__FUNCTION__)));
   log_file.Write(LOG_DEBUG, StringFormat("%s, ������� ������� [%d]", MakeFunctionPrefix(__FUNCTION__), i));
    _openPositions.Delete(i);
    SaveSituationToFile();
    break;                         // ... � ������� ������� �� ������� ������� 
  }
     
  if ((type == OP_SELL && position.getTakeProfitPrice() >= tick.ask) || (type == OP_BUY && position.getTakeProfitPrice() <= tick.bid)) // ���� ����� �� ������ TP
  {
   log_file.Write(LOG_DEBUG, StringFormat("%s ���� ����� �� ������ TP, ��������� ������� type = %s, ask = %f, bif = %f, TPprice = %f", MakeFunctionPrefix(__FUNCTION__), GetNameOP(type), tick.ask, tick.bid, position.getTakeProfitPrice()));
   ClosePosition(i);
   break;             // ��������� ��� �����
  }
     
  if (position.getPositionStatus() == POSITION_STATUS_PENDING) // ���� ��� ������� ���������� �������...
  { 
   if (!OrderSelect(position.getPositionTicket())) // ... � �� �� ����� �� ������� �� �� ������, ������ ��� ���������
   {
    log_file.Write(LOG_DEBUG, StringFormat("%s ��������� ������� ���������� ���������� �������.�������� ���������� StopLoss � TakeProfit.", MakeFunctionPrefix(__FUNCTION__)));
    if (position.setStopLoss() == STOPLEVEL_STATUS_NOT_PLACED
     || position.setTakeProfit() == STOPLEVEL_STATUS_NOT_PLACED )  // ��������� ���������� �������� � ����������
    {
     log_file.Write(LOG_DEBUG, StringFormat("%s �� ���������� ���������� StopLoss �/��� TakeProfit. ���������� ������� [%d] � positionsToReProcessing.", MakeFunctionPrefix(__FUNCTION__)));                  
     position.setPositionStatus(POSITION_STATUS_NOT_COMPLETE);  // ���� �� ����������, ��������, ����� ��������� �������
     _positionsToReProcessing.Add(position); 
     break;
    }
    log_file.Write(LOG_DEBUG, StringFormat("%s ���������� ���������� StopLoss �/��� TakeProfit. ���������� ������� [%d] � openPositions.", MakeFunctionPrefix(__FUNCTION__)));
    position.setPositionStatus(POSITION_STATUS_OPEN); // ������� ���������, ���� � ���� �����������
    _openPositions.Add(position);
    SaveSituationToFile();
   }
  }
 }
 size = _positionsToReProcessing.Total();
 for(int i = size - 1; i>=0; i--) // �� ������� ������� �� ���������
 {
  CPosition *pos = _positionsToReProcessing.Position(i);  // �������� �� ������� ��������� �� ������� �� �� ������
  if (pos.getPositionStatus() == POSITION_STATUS_NOT_DELETED)
  {
   if (pos.RemovePendingPosition() == POSITION_STATUS_DELETED)
   {
    log_file.Write(LOG_DEBUG, StringFormat("%s ���������� ������� ������� [%d].������� � �� positionsToReProcessing.", MakeFunctionPrefix(__FUNCTION__), i));
    _positionsToReProcessing.Delete(i);
    break;
   }
  }
  
  if (pos.getStopLossStatus() == STOPLEVEL_STATUS_NOT_DELETED)
  {
   log_file.Write(LOG_DEBUG, StringFormat("%s ������� StopLoss � TakeProfit", MakeFunctionPrefix(__FUNCTION__)));    
   CloseReProcessingPosition(i);
   break;
  }
  
  if (pos.getPositionStatus() == POSITION_STATUS_NOT_COMPLETE)
  {
   if (pos.setStopLoss() != STOPLEVEL_STATUS_NOT_PLACED && pos.setTakeProfit() != STOPLEVEL_STATUS_NOT_PLACED)
   {
    log_file.Write(LOG_DEBUG, StringFormat("%s ���������� ���������� StopLoss � TakeProfit � ������� [%d].���������� � �� positionsToReProcessing � openPositions.", MakeFunctionPrefix(__FUNCTION__), i));    
    pos.setPositionStatus(POSITION_STATUS_OPEN);
    _openPositions.Add(_positionsToReProcessing.Detach(i));
    SaveSituationToFile();
   }
  }
 }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CTradeManager::Initialization()
{
 log_file.Write(LOG_DEBUG, StringFormat("%s ������� ������� �������������.", MakeFunctionPrefix(__FUNCTION__)));
 int file_handle = FileOpen(CreateRDFilename(), FILE_READ|FILE_CSV|FILE_COMMON, ";");
 if (file_handle != INVALID_HANDLE)
 {
  log_file.Write(LOG_DEBUG, StringFormat("%s ���������� ���� ���������. ��������� ������ �� ����.", MakeFunctionPrefix(__FUNCTION__)));
  _openPositions.ReadFromFile(file_handle);
  FileClose(CreateRDFilename());
  log_file.Write(LOG_DEBUG, StringFormat("%s ����������� ������ �� ����� ���������.", MakeFunctionPrefix(__FUNCTION__)));
  SaveSituationToFile(true);
  log_file.Write(LOG_DEBUG, StringFormat("%s %s", MakeFunctionPrefix(__FUNCTION__), _openPositions.PrintToString()));
 }
 else
  log_file.Write(LOG_DEBUG, StringFormat("%s ���� ��������� �����������.���������� ���������� ��������� ���� ���������������.", MakeFunctionPrefix(__FUNCTION__)));
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CTradeManager::Deinitialization()
{
 log_file.Write(LOG_DEBUG, StringFormat("%s ������� ������� ���������������.", MakeFunctionPrefix(__FUNCTION__)));
 int size = _openPositions.Total();
 int attempts = 0;
 while (attempts < 25)
 {
  for(int i = size - 1; i>=0; i--) // �� ������� ����� �������
  {
   position = _openPositions.At(i);
   ClosePosition(i);
  }
  size = _openPositions.Total();
  if(size == 0) break;
  attempts++;
 }
 
 FileDelete(CreateRDFilename(), FILE_COMMON);
}
//+------------------------------------------------------------------+
/// Close a virtual order.
/// \param [in] ticket			Open virtual order ticket
/// \param [in] arrow_color 	Default=CLR_NONE. This parameter is provided for MT4 compatibility and is not used.
/// \return							true if successful, false if not
//+------------------------------------------------------------------+
bool CTradeManager::ClosePosition(long ticket, color Color=CLR_NONE)
{
 int index = _openPositions.TicketToIndex(ticket);
 return ClosePosition(index);
}

//+------------------------------------------------------------------+
/// Close a virtual order.
/// \param [in] i			      position index in array of positions
/// \param [in] arrow_color 	Default=CLR_NONE. This parameter is provided for MT4 compatibility and is not used.
/// \return							true if successful, false if not
//+------------------------------------------------------------------+
bool CTradeManager::ClosePosition(int i,color Color=CLR_NONE)
{
 CPosition *pos = _openPositions.Position(i);  // �������� �� ������� ��������� �� ������� �� �� �������
 if (pos.ClosePosition())
 {
  _openPositions.Delete(i);  // ������� ������� �� �������
  SaveSituationToFile();
  log_file.Write(LOG_DEBUG, StringFormat("%s ������� ������� [%d]", MakeFunctionPrefix(__FUNCTION__), i));
  return(true);
 }
 else
 {
  error = GetLastError();
  _positionsToReProcessing.Add(_openPositions.Detach(i));
  log_file.Write(LOG_DEBUG, StringFormat("%s �� ������� ������� ������� [%d]. ������� ���������� � ������ positionsToReProcessing.Error{%d} = %s"
                                        , MakeFunctionPrefix(__FUNCTION__), i, error, ErrorDescription(error)));
 }
 return(false);
}

//+------------------------------------------------------------------+
/// Delete a virtual position from "not_deleted".
/// \param [in] i			      position index in array of positions
/// \param [in] arrow_color 	Default=CLR_NONE. This parameter is provided for MT4 compatibility and is not used.
/// \return							true if successful, false if not
//+------------------------------------------------------------------+
bool CTradeManager::CloseReProcessingPosition(int i,color Color=CLR_NONE)
{
 CPosition *pos = _positionsToReProcessing.Position(i);  // �������� �� ������� ��������� �� ������� �� �� �������
 if (pos.RemoveStopLoss() == STOPLEVEL_STATUS_DELETED)
 {
  log_file.Write(LOG_DEBUG, StringFormat("%s ������� ����������� ����-�����", MakeFunctionPrefix(__FUNCTION__)));
  _positionsToReProcessing.Delete(i);  // ������� ������� �� �������
  return(true);
 }
 return(false);
}
//+------------------------------------------------------------------+
/// Create magic numbar
/// \param [string] str       symbol
/// \return							generated magic number
//+------------------------------------------------------------------+
long CTradeManager::MakeMagic(string strSymbol = "")
{
 if(strSymbol == "") strSymbol = Symbol();
 string s = strSymbol + PeriodToString(Period()) + MQL5InfoString(MQL5_PROGRAM_NAME);
 ulong ulHash = 5381;
 for(int i = StringLen(s)-1; i >=0;i--)
 {
  ulHash = ((ulHash<<5) + ulHash) + StringGetCharacter(s,i);
 }
 return MathAbs((long)ulHash);
}

string CreateRDFilename (bool debug = false)
{
 string result;
 if (debug) result = StringFormat("%s\\RescueData\\%s_%s_%s_debug.csv", MQL5InfoString(MQL5_PROGRAM_NAME), MQL5InfoString(MQL5_PROGRAM_NAME), StringSubstr(Symbol(),0,6), PeriodToString(Period()));
 else result = StringFormat("%s\\RescueData\\%s_%s_%s_rd.csv", MQL5InfoString(MQL5_PROGRAM_NAME), MQL5InfoString(MQL5_PROGRAM_NAME), StringSubstr(Symbol(),0,6), PeriodToString(Period()));
 return(result);
}

void CTradeManager::SaveSituationToFile(bool debug = false)
{
 string file_name = CreateRDFilename(debug);
 int file_handle = FileOpen(file_name, FILE_WRITE|FILE_CSV|FILE_COMMON, ";");
 if(file_handle == INVALID_HANDLE)
 {
  log_file.Write(LOG_DEBUG, StringFormat("%s �� ���������� ������� ����: %s", MakeFunctionPrefix(__FUNCTION__), file_name));
  return;
 }
 _openPositions.WriteToFile(file_handle);
 FileClose(file_handle);
}