//+------------------------------------------------------------------+
//|                                                CTradeManager.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include <TradeManager\TradeManagerEnums.mqh>
#include "test_Position.mqh"
#include "test_PositionArray.mqh"
#include "test_CTMTradeFunctions.mqh"
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <CompareDoubles.mqh>

//+------------------------------------------------------------------+
//| ����� ������������ ��������������� �������� ����������           |
//+------------------------------------------------------------------+
class test_CTradeManager
{
protected:
  test_CPosition *position;
  test_CTMTradeFunctions trade;
  ulong _magic;
  bool _useSound;
  string _nameFileSound;   // ������������ ��������� �����
  
  test_CPositionArray _openPositions; ///< Array of open virtual orders for this VOM instance, also persisted as a file
  test_CPositionArray _positionsHistory; ///< Array of closed virtual orders, also persisted as a file
  
public:
  void test_CTradeManager(ulong magic): _magic(magic), _useSound(true), _nameFileSound("expert.wav"){};
             
               // ���������� ����� �������� �����������
  
  bool OpenPosition(string symbol, ENUM_POSITION_TYPE type,double volume
                   ,int sl, int tp, int minProfit, int trailingStop, int trailingStep);
  bool ClosePosition(long ticket,int slippage,color Color=CLR_NONE); 
  void OnTick();
  void OnTrade(datetime history_start);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool test_CTradeManager::OpenPosition(string symbol, ENUM_POSITION_TYPE type, double volume
                                ,int sl, int tp, int minProfit, int trailingStop, int trailingStep)
{
 //Print("=> ",__FUNCTION__," at ",TimeToString(TimeCurrent(),TIME_SECONDS));
 int i = 0;
 int total = _openPositions.Total();
 switch(type)
 {
  case POSITION_TYPE_BUY:
   if (total > 0)
   {
    for (i = total - 1; i >= 0; i--) // ��������� ��� ������ ��� ������� �� �������
    {
     //PrintFormat("������� %d-� �������", i);
     test_CPosition *pos = _openPositions.At(i);
     //PrintFormat("������� %d-� ������� ������=%s, �����=%d", i, pos.getSymbol(), pos.getMagic());
     if ((pos.getSymbol() == symbol) && (pos.getMagic() == _magic))
     {
      if (pos.getType() == POSITION_TYPE_SELL)
      {
       pos.ClosePosition();
       _openPositions.Delete(i);
      }
     }
    }
   }
   break;
  case POSITION_TYPE_SELL:
   if (total > 0)
   {
    for (i = total - 1; i >= 0; i--) // ��������� ��� ������ ��� ������� �� �������
    {
     //PrintFormat("������� %d-� �������", i);
     test_CPosition *pos = _openPositions.At(i);
     if ((pos.getSymbol() == symbol) && (pos.getMagic() == _magic))
     {
      if (pos.getType() == POSITION_TYPE_BUY)
      {
       pos.ClosePosition();
       _openPositions.Delete(i);
      }
     }
    }
   }
   break;
  default:
   //LogFile.Log(LOG_PRINT,__FUNCTION__," error: Invalid ENUM_VIRTUAL_ORDER_TYPE");
   break;
 }
 
 total = _openPositions.Total();
 if (total <= 0)
 {
  position = new test_CPosition(_magic, symbol, type, volume, sl, tp, minProfit, trailingStop, trailingStep);
  if (position.OpenPosition())
  {
   PrintFormat("%s, magic=%d, symb=%s, type=%s, vol=%.02f, sl=%.06f, tp=%.06f", MakeFunctionPrefix(__FUNCTION__),position.getMagic(), position.getSymbol(), PositionTypeToStr(position.getType()), position.getVolume(), position.getStopLossPrice(), position.getTakeProfitPrice());
   _openPositions.Add(position);
   return(true); // ���� ������ ������� �������
  }
  else
  {
   return(false); // ���� ������� ������� �� �������
  }
 }
 PrintFormat("�������� �������� ������� %d", total);
 return(true); // ���� �������� �������� �������, ������ �� ���� ����������� 
}

//+------------------------------------------------------------------+
/// Called from EA OnTrade().
/// Actions virtual stoplosses, takeprofits \n
/// Include the following in each EA that uses TradeManager
//+------------------------------------------------------------------+
void test_CTradeManager::OnTrade(datetime history_start)
  {
//--- ����������� ����� ��� �������� ��������� ��������� �����
   static int prev_positions = 0, prev_orders = 0, prev_deals = 0, prev_history_orders = 0;
   static double prev_volume = 0;
   int index = 0;
//--- �������� �������� �������
   bool update=HistorySelect(history_start,TimeCurrent());

   double curr_volume = PositionGetDouble(POSITION_VOLUME);
   int curr_positions = PositionsTotal();
   int curr_orders = OrdersTotal();
   int curr_deals = HistoryOrdersTotal();
   int curr_history_orders = HistoryDealsTotal();
//--- ������� ���������� � ����� �������, � ����� ��������� � ������� 
/*  PrintFormat("PositionsTotal() = %d (%+d)",
               curr_positions,(curr_positions-prev_positions));
   PrintFormat("Position Volume() = %.02f (%.02f)",
               curr_volume,(curr_volume-prev_volume));
              
   PrintFormat("OrdersTotal() = %d (%+d)",
               curr_orders,curr_orders-prev_orders);
   PrintFormat("HistoryOrdersTotal() = %d (%+d)",
               curr_deals,curr_deals-prev_deals);
   PrintFormat("HistoryDealsTotal() = %d (%+d)",
               curr_history_orders,curr_history_orders-prev_history_orders);
*/

//--- ������� ������� ����� ��� �������� ������ �������
   
//--- ������� ������� ��������� � ����������   
   if ((curr_positions-prev_positions) != 0 || (curr_volume - prev_volume) != 0) // ���� ���������� ���������� ��� ����� �������
   {
    for(int i = _openPositions.Total()-1; i>=0; i--) // �� ������� ����� �������
    {
     position = _openPositions.At(i);
     if (!OrderSelect(position.getStopLossTicket()))
     {
      PrintFormat("%s ��� ������-���������, ��������� ���������� TakeProfitTicket=%d", MakeFunctionPrefix(__FUNCTION__), OrderGetTicket(OrderGetInteger(ORDER_POSITION_ID)));
      if (trade.OrderDelete(position.getTakeProfitTicket()))
      {
       index = _openPositions.TicketToIndex(position.getPositionTicket());
       _openPositions.Delete(index);
      }
      break;
     }
     if (!OrderSelect(position.getTakeProfitTicket()))
     {
      PrintFormat("%s ��� ������-�����������, ��������� �������� StopLossTicket=%d", MakeFunctionPrefix(__FUNCTION__), OrderGetTicket(OrderGetInteger(ORDER_POSITION_ID)));
      if (trade.OrderDelete(position.getStopLossTicket()))
      {
       index = _openPositions.TicketToIndex(position.getPositionTicket());
       _openPositions.Delete(index);
      }
      break;
     }
    }
   }
//--- �������� ��������� �����
   prev_volume = curr_volume;
   prev_positions = curr_positions;
   prev_orders = curr_orders;
   prev_deals = curr_deals;
   prev_history_orders = curr_history_orders;
   //PrintFormat("curr_positions= %d, prev_positions= %d, curr-prev= %d; curr_volume= %.02f, prev_volume= %.02f, curr-prev=%.02f, "
   //           , curr_positions, prev_positions, (curr_positions-prev_positions), curr_volume, prev_volume, (curr_volume-prev_volume));
   //Print("");
  }
//+------------------------------------------------------------------+
/// Called from EA OnTick().
/// Actions virtual stoplosses, takeprofits \n
/// Include the following in each EA that uses TradeManager
/// \code
/// // EA code
/// void OnTick()
///  {
///   // action virtual stoplosses, takeprofits
///   tm.OnTick();
///   //
///   // continue with other tick event handling in this EA
///   // ....
/// \endcode
//+------------------------------------------------------------------+
void test_CTradeManager::OnTick()
{
 for(int i = _openPositions.Total()-1; i>=0; i--) // �� ������� ����� �������
 {
  int index = 0;
  position = _openPositions.At(i);
  if (!OrderSelect(position.getStopLossTicket()))
  {
   PrintFormat("%s ��� ������-���������, ��������� ���������� TakeProfitTicket=%d", MakeFunctionPrefix(__FUNCTION__), OrderGetTicket(OrderGetInteger(ORDER_POSITION_ID)));
   trade.OrderDelete(position.getTakeProfitTicket());
   index = _openPositions.TicketToIndex(position.getPositionTicket());
   _openPositions.Delete(index);
   break;
  }
  if (!OrderSelect(position.getTakeProfitTicket()))
  {
   PrintFormat("%s ��� ������-�����������, ��������� �������� StopLossTicket=%d", MakeFunctionPrefix(__FUNCTION__), OrderGetTicket(OrderGetInteger(ORDER_POSITION_ID)));
   trade.OrderDelete(position.getStopLossTicket());
   index = _openPositions.TicketToIndex(position.getPositionTicket());
   _openPositions.Delete(index);
   break;
  }
 }
}  
//+------------------------------------------------------------------+
/// Close a virtual order.
/// \param [in] ticket			Open virtual order ticket
/// \param [in] slippage		also known as deviation.  Typical value is 50
/// \param [in] arrow_color 	Default=CLR_NONE. This parameter is provided for MT4 compatibility and is not used.
/// \return							true if successful, false if not
//+------------------------------------------------------------------+
bool test_CTradeManager::ClosePosition(long ticket,int slippage,color Color=CLR_NONE)
{
 test_CPosition *pos = _openPositions.AtTicket(ticket);  // �������� �� ������� ��������� �� ������� �� �� ������
 trade.OrderDelete(pos.getTakeProfitTicket());      // ������� �����-����������
 trade.OrderDelete(pos.getStopLossTicket());        // ������� �����-��������
 _openPositions.Delete(_openPositions.TicketToIndex(ticket));  // �� ������ �������� ������ ������� � �������, ������� �������
 return(false);
}

