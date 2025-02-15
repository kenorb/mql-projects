//+------------------------------------------------------------------+
//|                                            VirtualOrderArray.mqh |
//|                                     Copyright Paul Hampton-Smith |
//|                            http://paulsfxrandomwalk.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Paul Hampton-Smith"
#property link      "http://paulsfxrandomwalk.blogspot.com"

#include "TradeManagerConfig.mqh"
#include "TradeManagerEnums.mqh"
#include "PositionOnPendingOrders.mqh"
#include <Arrays/ArrayObj.mqh>
#include <StringUtilities.mqh>
//+------------------------------------------------------------------+
/// Stores an array of virtual orders.
//+------------------------------------------------------------------+
class CPositionArray : public CArrayObj
  {
private:
   string            m_strPersistFilename;

public:
   CPositionArray();
   ~CPositionArray();
   CPosition        *AtTicket(long lTicket);
   int               OpenLots(string strSymbol);
   /// Count of orders.
   int               OrderCount(string strSymbol,long lMagic);
   int               OrderCount(string strSymbol,long lMagic,ENUM_TM_POSITION_TYPE eOrderType);
   string            PersistFilename(){return(m_strPersistFilename);}
   string            PersistFilename(string strFilename);
   int               TicketToIndex(long lTicket);
   bool              ReadFromFile(int handle);                                 //��������� �� ����� ������� �������
   bool              ReadFromFile(int handle,datetime start,datetime finish);  //��������� �� ����� ������� �������
   bool              WriteToFile(int handle);
   string            SummaryList();
   void              Clear(const long nMagic);      //�������� ������� ������� �� �������
   void              Clear(const string strSymbol); //�������� ������� ������� �� �������
   void              Clear();                       //�������� ����� ������� �������
   string            PrintToString();
   CPosition         *Position(int nIndex){return((CPosition*)CArrayObj::At(nIndex));}

  };
//+------------------------------------------------------------------+
//|   �����������                                                    |
//+------------------------------------------------------------------+
CPositionArray::CPositionArray()
  {
   m_strPersistFilename="";
  }
  
//+------------------------------------------------------------------+
//|    ����������                                                    |
//+------------------------------------------------------------------+
CPositionArray::~CPositionArray()
  {
   for(int i = Total(); i >= 0; i--)
   {
    delete Position(i);
   }
  }
//+------------------------------------------------------------------+
/// Searches for and returns the Position which matches ticket.
/// \param [in]	lTicket	Order ticket
/// \return						CPosition handle, or NULL if not found
//+------------------------------------------------------------------+
CPosition *CPositionArray::AtTicket(long lTicket)
  {
   for(int i= Total()- 1; i >= 0; i--)
     {
      CPosition *pos=Position(i);
      if(pos.getTMTicket()==lTicket)
        {
         //LogFile.Log(LOG_VERBOSE,__FUNCTION__,StringFormat("(%d) returning valid CPosition",lTicket));
         return(pos);
        }
     }
   //LogFile.Log(LOG_PRINT,__FUNCTION__,StringFormat("(%d) error: could not find a valid CPosition",lTicket));
   return(NULL);
  }
//+------------------------------------------------------------------+
/// Returns positive lots if total virtual position is long and negative lots if short.
/// \param [in]   strSymbol   Symbol
/// \return       +/-Lots * 1000                                                                  |
//+------------------------------------------------------------------+
int CPositionArray::OpenLots(string strSymbol)
  {
   double dblTotalPosition=0.0;
   for(int i=Total()-1;i>=0;i--)
     {
      CPosition *pos=Position(i);
      if(pos.getSymbol()==strSymbol)
         switch(pos.getType())
           {
            case OP_BUY:
               dblTotalPosition+=pos.getVolume(); break;
            case OP_SELL:
               dblTotalPosition-=pos.getVolume();
           }
     }
   int nTotalPosition=(int)MathRound(dblTotalPosition*1000.0);
   //LogFile.Log(LOG_VERBOSE,__FUNCTION__,StringFormat("(%s) returning %d",strSymbol,nTotalPosition));
   return(nTotalPosition);
  }
//+------------------------------------------------------------------+
/// Count of orders.
/// \param [in] strSymbol
/// \param [in] nMagic
/// \return	Count of orders matching input criteria
//+------------------------------------------------------------------+
int CPositionArray::OrderCount(string strSymbol,long lMagic)
  {
   int nOrdersTotal=0;
   for(int i=Total()-1;i>=0;i--)
     {
      CPosition *pos=Position(i);
      if(pos.getMagic()==lMagic)
         if(pos.getSymbol()==strSymbol)
            nOrdersTotal++;
     }
   return(nOrdersTotal);
  }
//+------------------------------------------------------------------+
/// Count of orders of a certain type.
/// \param [in] strSymbol
/// \param [in] nMagic
/// \param [in] eOrderType
/// \return	Count of orders matching input criteria
//+------------------------------------------------------------------+
int CPositionArray::OrderCount(string strSymbol, long lMagic, ENUM_TM_POSITION_TYPE eOrderType)
  {
   int nOrdersTotal=0;
   for(int i=Total()-1;i>=0;i--)
     {
      CPosition *pos=Position(i);
      if(pos.getMagic()==lMagic)
         if(pos.getType()==eOrderType)
            if(pos.getSymbol()==strSymbol)
               nOrdersTotal++;
     }
   return(nOrdersTotal);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CPositionArray::PersistFilename(string strFilename)
  {
// need to start with a fresh file for every test
   if(MQL5InfoInteger(MQL5_TESTING) || MQL5InfoInteger(MQL5_OPTIMIZATION) || MQL5InfoInteger(MQL5_VISUAL_MODE))
      FileDelete(strFilename);

   return(m_strPersistFilename=strFilename);
  }
/*  
//+------------------------------------------------------------------+
/// Reads array contents from PersistFilename()
//+------------------------------------------------------------------+
bool CPositionArray::ReadFromFile(bool bCreateLineObjects=true)
  {
   if(!FileIsExist(PersistFilename()))
     {
      //LogFile.Log(LOG_VERBOSE,__FUNCTION__," warning: file "+PersistFilename()+" does not exist yet - assume zero orders");
      return(true);
     }

   int handle=-1;
   int nRepeatCount=Config.FileAccessRetries;
   while((handle=FileOpen(PersistFilename(),FILE_READ|FILE_CSV,Config.VirtualOrdersFileCsvDelimiter))<=0 && nRepeatCount>0)
     {
      Sleep(Config.FileAccessSleep_mSec);
      nRepeatCount--;
      //LogFile.Log(LOG_DEBUG,__FUNCTION__," retrying #"+(string)nRepeatCount);
     }

   if(handle<=0)
     {
      //LogFile.Log(LOG_PRINT,__FUNCTION__," error: "+ErrorDescription(::GetLastError())+" opening "+PersistFilename());
      return(false);
     }

// clear off header
   while(!FileIsLineEnding(handle)) FileReadString(handle);

   while(!FileIsEnding(handle))
     {
      CPosition *pos=new CPosition;
      // only add orders that don't already exist in the array
      if(pos.ReadFromFile(handle))
        {
         if(TicketToIndex(pos.getPositionTicket())==-1)
           {
            Add(pos);
           }
         else
           {
            delete pos;
           }
        }
     }
   FileClose(handle);
   //LogFile.Log(LOG_DEBUG,__FUNCTION__," successful reading from "+PersistFilename());
   return(true);
  }*/
//+------------------------------------------------------------------+
/// Searches for and returns the index of the Position which matches ticket.
/// \param [in]	lTicket	Order ticket
/// \return						Index, or -1 if not found
//+------------------------------------------------------------------+
int CPositionArray::TicketToIndex(long lTicket)
  {
   for(int i=Total()-1;i>=0;i--)
     {
      CPosition *pos=Position(i);
      //LogFile.Log(LOG_VERBOSE,__FUNCTION__,StringFormat("(%d) looking at open virtual order #%d",lTicket,pos.Ticket()));
      if(pos.getTMTicket()==lTicket)
        {
         //LogFile.Log(LOG_VERBOSE,__FUNCTION__,StringFormat("(%d) returning %d",lTicket,i));
         return(i);
        }
     }
   //LogFile.Log(LOG_DEBUG,__FUNCTION__,StringFormat("(%d) warning: ticket not found, returning -1",lTicket));
   return(-1);
  }
//+------------------------------------------------------------------+
/// Saves array contents to PersistFilename()
//+------------------------------------------------------------------+
/*bool CPositionArray::WriteToFile()
  {
   int handle=-1;
   int nRepeatCount=Config.FileAccessRetries;
   while((handle=FileOpen(PersistFilename(),FILE_CSV|FILE_WRITE,Config.VirtualOrdersFileCsvDelimiter))<=0 && nRepeatCount>0)
     {
      Sleep(Config.FileAccessSleep_mSec);
      nRepeatCount--;
      //LogFile.Log(LOG_DEBUG,__FUNCTION__," retrying #"+(string)nRepeatCount);
     }

   if(handle<=0)
     {
      //LogFile.Log(LOG_PRINT,__FUNCTION__," error: "+ErrorDescription(::GetLastError())+" opening "+PersistFilename());
      return(false);
     }

   CPosition *tmp;
   tmp.WriteToFile(handle,true);
   for(int i=0;i<Total();i++)
     {
      Position(i).WriteToFile(handle, false);
     }
   FileClose(handle);
   //LogFile.Log(LOG_DEBUG,__FUNCTION__," successful writing to "+PersistFilename());
   return(true);
  }*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CPositionArray::SummaryList()
  {/*
   string strSummary; StringInit(strSummary);
   for(int i=0;i<Total();i++)
     {
      strSummary=strSummary+Position(i).SummaryString()+"\n";
     }
   return(strSummary);*/
   return("");
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionArray::Clear(const long nMagic)
  {
   for(int i=Total()-1;i>=0;i--)
     {
      CPosition *pos=Position(i);
      if(pos.getMagic()==nMagic) Delete(i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionArray::Clear(const string strSymbol)
  {
   for(int i=Total()-1;i>=0;i--)
     {
      CPosition *pos=Position(i);
      if(pos.getSymbol()==strSymbol) Delete(i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionArray::Clear()
  {
   for(int i=Total()-1;i>=0;i--)
     {
      CPosition *pos=Position(i);
      Delete(i);
     }
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CPositionArray::PrintToString()
{
 int total = Total();
 string result = StringFormat("Array(size=%d): ", total);
 CPosition *pos;
 for (int i = total-1; i >= 0; i--)
 {
  pos = Position(i);
  StringFormat("%s [%d] = {%d, %.05f, %s, %s, %.05f, %.05f, %d}", 
  result, i, pos.getMagic(), pos.getPositionPrice(), PositionStatusToStr(pos.getPositionStatus()), GetNameOP(pos.getType()), pos.getStopLossPrice(), pos.getTakeProfitPrice(), pos.getStopLossTicket());
  if(pos.getType() != OP_BUY && pos.getType() != OP_SELL) 
  {
   if(OrderSelect(pos.getOrderTicket()))
    StringConcatenate(result, result, EnumToString((ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE)));
   else
    StringConcatenate(result, result, EnumToString((ENUM_ORDER_STATE)HistoryOrderGetInteger(pos.getOrderTicket(), ORDER_STATE)));
  }
 }
 return result;
}

bool CPositionArray::ReadFromFile(int handle)
{
 uint count =0;
 if(handle != INVALID_HANDLE)
 {
  CPosition *pos;
  while(!FileIsEnding(handle))
  {
   pos = new CPosition();
   if (pos.ReadFromFile(handle))
   {
    Add(pos);
   }
   else
    delete pos;
   
  }
  Print("Read count: ", this.Total());
  return true;
 }
 return false;
}

bool CPositionArray::ReadFromFile(int handle,datetime start,datetime finish)
{
 if(handle != INVALID_HANDLE)
 {
  
  CPosition *pos;
  while(!FileIsEnding(handle))
  {
   pos = new CPosition();
   if (pos.ReadFromFile(handle))
   {
    
    if (pos.getOpenPosDT() >= start && pos.getOpenPosDT() <= finish)
     {
      Add(pos);
     }
   }
   else
    delete pos;
   
  }
  Print("Read count: ", this.Total());
  return true;
 }
 return false;
}

bool CPositionArray::WriteToFile(int handle)
{
 if(handle != INVALID_HANDLE)
 {
  int size = Total();

  CPosition *pos;
  for(int i = size-1; i >= 0; i--)
  {
   pos = Position(i);
   pos.WriteToFile(handle);
  }
  return true;
 }
 return false;
}