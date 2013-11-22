//+------------------------------------------------------------------+
//|                                                AddOnFuctions.mq4 |
//|                                            Copyright � 2011, GIA |
//|                                             http://www.saita.net |
//+------------------------------------------------------------------+

//+----------------------------------------------------------------------------+
//|  ������   : 11.02.2013                                                     |
//|  �������� : ���������� �������� � ����������� �� ����, ����� ���� ������   |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    arg1 - �������� 1                                                       |
//|    arg2 - �������� 2                                                       |
//+----------------------------------------------------------------------------+ 
int GreatDouble(double arg1, double arg2)
{
 if(NormalizeDouble(arg1 - arg2, 8) > 0) return(1);
 else if (NormalizeDouble(arg1 - arg2, 8) < 0) return(-1);
      else return(0); 
}

//+----------------------------------------------------------------------------+
//|  ������   : 20.11.2012                                                     |
//|  �������� : ���������� ���� �������� ���������                             |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    v - ��������                                                            |
//+----------------------------------------------------------------------------+
int sign( double v )
{
    if( v < 0 ) return( -1 );
    return( 1 );
}

//+----------------------------------------------------------------------------+
//|  ������   : 20.11.2012                                                     |
//|  �������� : ���������� ��������� ����� � "condition ? ifTrue : ifFalse"    |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    condition - ����������� �������                                         |
//|    ifTrue - �������� ������������ ��� ���������� �������                   |
//|    ifFalse - �������� ������������ ��� �� ���������� �������               |
//+----------------------------------------------------------------------------+ 
double iif( bool condition, double ifTrue, double ifFalse )
{
    if( condition ) return( ifTrue );
    
    return( ifFalse );
}

//+----------------------------------------------------------------------------+
//|  ������   : 20.11.2012                                                     |
//|  �������� : ���������� ��������� ����� � "condition ? ifTrue : ifFalse"    |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    condition - ����������� �������                                         |
//|    ifTrue - �������� ������������ ��� ���������� �������                   |
//|    ifFalse - �������� ������������ ��� �� ���������� �������               |
//+----------------------------------------------------------------------------+ 
string iifStr( bool condition, string ifTrue, string ifFalse )
{
    if( condition ) return( ifTrue );
    
    return( ifFalse );
}

//+----------------------------------------------------------------------------+
//|  ������   : 20.11.2012                                                     |
//|  �������� : ���������� ����������� ������                                  |
//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+ 
int orderDirection()
{
    return( 1 - 2 * ( OrderType() % 2 ) );
}

//+----------------------------------------------------------------------------+
//|  ������   : 20.11.2012                                                     |
//|  �������� : ����� ��������� � ������ � ������ ��������� ������             |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    functionName - ��� ������� � ���������� ������                          |
//|    assertion - ���������� �������                                          |
//|    description - ����� ���������                                           |
//+----------------------------------------------------------------------------+
void assert(string functionName, bool assertion, string description = "")
{
 if(!assertion) 
  Print("ASSERT: in " + functionName + "() - " + description);
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 01.09.2005                                                     |
//|  �������� : ����� ��������� � ������� � � ������                           |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    m - ����� ���������                                                     |
//+----------------------------------------------------------------------------+
void Message(string m)
{
 Comment(m);
 if (StringLen(m)>0) Print(m);
} 

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 01.09.2005                                                     |
//|  �������� : ���������� ������������ ����������                             |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    TimeFrame - ��������� (���������� ������)      (0 - ������� ��)         |
//+----------------------------------------------------------------------------+
string GetNameTF(int TimeFrame=0)
{
 if (TimeFrame==0) TimeFrame=Period();
 switch (TimeFrame)
 {
  case PERIOD_M1:  return("M1");
  case PERIOD_M5:  return("M5");
  case PERIOD_M15: return("M15");
  case PERIOD_M30: return("M30");
  case PERIOD_H1:  return("H1");
  case PERIOD_H4:  return("H4");
  case PERIOD_D1:  return("Daily");
  case PERIOD_W1:  return("Weekly");
  case PERIOD_MN1: return("Monthly");
  default:         return("UnknownPeriod");
 }
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 01.09.2005                                                     |
//|  �������� : ���������� ������������ �������� ��������                      |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    op - ������������� �������� ��������                                    |
//+----------------------------------------------------------------------------+
string GetNameOP(int op)
{
 switch (op)
 {
  case OP_BUY      : return("Buy");
  case OP_SELL     : return("Sell");
  case OP_BUYLIMIT : return("Buy Limit");
  case OP_SELLLIMIT: return("Sell Limit");
  case OP_BUYSTOP  : return("Buy Stop");
  case OP_SELLSTOP : return("Sell Stop");
  default          : return("Unknown Operation");
 }
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 12.03.2008                                                     |
//|  �������� : ���������� ���� ������������� �������.                         |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    sy - ������������ �����������   (""   - ����� ������,                   |
//|                                     NULL - ������� ������)                 |
//|    op - ��������                   (-1   - ����� �����)                    |
//|    mn - MagicNumber                (-1   - ����� �����)                    |
//|    ot - ����� ��������             ( 0   - ����� ����� ���������)          |
//+----------------------------------------------------------------------------+
bool ExistOrders(string sy="", int op=-1, int mn=-1, datetime ot=0) {
  int i, total=OrdersTotal(), ty;

  if (sy=="0") sy=Symbol();
  for (i=0; i<total; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      ty=OrderType();
      if (ty>1 && ty<6) {
        if ((OrderSymbol()==sy || sy=="") && (op<0 || ty==op)) {
          if (mn<0 || OrderMagicNumber()==mn) {
            if (ot<=OrderOpenTime()) return(True);
          }
        }
      }
    }
  }
  return(False);
}

//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 06.03.2008                                                     |
//|  �������� : ���������� ���� ������������� �������                          |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    sy - ������������ �����������   (""   - ����� ������,                   |
//|                                     NULL - ������� ������)                 |
//|    op - ��������                   (-1   - ����� �������)                  |
//|    mn - MagicNumber                (-1   - ����� �����)                    |
//|    ot - ����� ��������             ( 0   - ����� ����� ��������)           |
//+----------------------------------------------------------------------------+
bool ExistPositions(string sy="", int op=-1, int mn=-1, datetime ot=0) {
  int i, total=OrdersTotal();

  if (sy=="0") sy=Symbol();
  for (i=0; i<total; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==sy || sy=="") {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (op<0 || OrderType()==op) {
            if (mn<0 || OrderMagicNumber()==mn) {
              if (ot<=OrderOpenTime()) return(True);
            }
          }
        }
      }
    }
  }
  return(False);
}


//+----------------------------------------------------------------------------+
//|  �����    : ��� ����� �. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  ������   : 28.11.2006                                                     |
//|  �������� : ����������� ������ �������������� ���������� ������.           |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    pp - ���� ��������� ������                                              |
//|    sl - ������� ������� �����                                              |
//|    tp - ������� ������� �����                                              |
//|    cl - ���� ������ �����������                                            |
//+----------------------------------------------------------------------------+
void ModifyOrder(double pp=-1, double sl=0, double tp=0, color cl=CLR_NONE) {
  bool   fm;
  double op, pa, pb, os, ot;
  int    dg=MarketInfo(OrderSymbol(), MODE_DIGITS), er, it;
 
  if (pp<=0) pp=OrderOpenPrice();
  if (sl<=0 ) sl=OrderStopLoss();
  if (tp<=0 ) tp=OrderTakeProfit();
  
  pp=NormalizeDouble(pp, dg);
  sl=NormalizeDouble(sl, dg);
  tp=NormalizeDouble(tp, dg);
  op=NormalizeDouble(OrderOpenPrice() , dg);
  os=NormalizeDouble(OrderStopLoss()  , dg);
  ot=NormalizeDouble(OrderTakeProfit(), dg);
 
  if (pp!=op || sl!=os || tp!=ot) {
    for (it=1; it<=NumberOfTry; it++) {
      if (!IsTesting() && (!IsExpertEnabled() || IsStopped())) break;
      while (!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      fm=OrderModify(OrderTicket(), pp, sl, tp, 0, cl);
      if (fm) {
        if (UseSound) PlaySound(NameFileSound); break;
      } else {
        er=GetLastError();
        pa=MarketInfo(OrderSymbol(), MODE_ASK);
        pb=MarketInfo(OrderSymbol(), MODE_BID);
        Print("Error(",er,") modifying order: ",ErrorDescription(er),", try ",it);
        Print("Ask=",pa,"  Bid=",pb,"  sy=",OrderSymbol(),
              "  op="+GetNameOP(OrderType()),"  pp=",pp,"  sl=",sl,"  tp=",tp);
        Sleep(1000*10);
      }
    }
  }
}

//+----------------------------------------------------------------------------+
//|  �����    : GIA                                                            |
//+----------------------------------------------------------------------------+
//|  ������   : 10.01.2013                                                     |
//|  �������� : ������� ����� �������������� ��������� �������.                |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    pp - ���� ��������� ������                                              |
//+----------------------------------------------------------------------------+
void ClosePosBySelect(double pp=-1, string comment = "")
 {
  bool   fc;
  color  clClose;
  double pa, pb;
  int    err, it;

  if (OrderType()==OP_BUY || OrderType()==OP_SELL)
  {
   for (it=1; it<=NumberOfTry; it++)
   {
    if (!IsTesting() && (!IsExpertEnabled() || IsStopped())) break;
    while (!IsTradeAllowed()) Sleep(5000);
    
    RefreshRates();
    
    if (pp < 0)
    {
     if (OrderType()==OP_BUY)
     {
      pp=MarketInfo(OrderSymbol(), MODE_BID);
      clClose=Violet;
     }
     else
     {
      pp=MarketInfo(OrderSymbol(), MODE_ASK);
      clClose=Violet;
     }
    } 
    fc=OrderClose(OrderTicket(), OrderLots(), pp, Slippage, clClose);
    
    if (fc)
    {
     if (UseSound) PlaySound(NameFileSound);
     if (comment !="") Alert(comment);
     break;
    }
    else
    {
     err=GetLastError();
     if (err==146) while (IsTradeContextBusy()) Sleep(1000*11);
     Print("Error(",err,") Close ",GetNameOP(OrderType())," ", ErrorDescription(err),", try ",it);
     Print(OrderTicket(),"  Ask=",Ask,"  Bid=",Bid,"  pp=",pp);
     Print("sy=",OrderSymbol(),"  ll=",OrderLots(),"  sl=",OrderStopLoss(), "  tp=",OrderTakeProfit(),"  mn=",OrderMagicNumber());
     Sleep(1000*5);
    }
   }
  }
  else
  {
   Print("������������ �������� ��������. Close ",GetNameOP(OrderType()));
  }
 }

//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//| ������   :                                                      |
//| �������� : �������� �������. ������ ������� ��� ������ �� �������.         |
//+----------------------------------------------------------------------------+
//| ���������:                                                                 |
//| symb - ������������ �����������   (NULL - ������� ������)                    |
//| operation - ��������                   ( -1  - ����� �����)                       |
//| magic - MagicNumber                ( -1  - ����� �����)                       |
//+----------------------------------------------------------------------------+
void DeleteOrders(string symb="", int operation=-1, int magic=-1) 
{
 int i;
 total=OrdersTotal();
 int orderType;

 if (symb=="" || symb=="0") symb=Symbol();
 for (i = 0; i < total; i++)
 {
  if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
  {
   orderType=OrderType();
   if (orderType==OP_BUYLIMIT || orderType==OP_BUYSTOP || orderType==OP_SELLLIMIT || orderType==OP_SELLSTOP)
   {
    if (OrderSymbol()==symb && (operation<0 || orderType==operation))
    {
     if (magic<0 || OrderMagicNumber()==magic) 
     {
      OrderDelete(OrderTicket(), clDelete);
     }
    }
   }
  }
 }
}
//+------------------------------------------------------------------+
//|                                LimitOrderExpirationForTester     |
//| �������� : �������� �������, ������� �� ����� ����������.        |
//+------------------------------------------------------------------+
//| ���������:                                                       |
//+------------------------------------------------------------------+
int LimitOrderExpirationForTester()
{
 int orderType;
 total = OrdersTotal();
 
 if (total > 0)
 {
  for (int i=0; i<total; i++)
  {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   {
    if (OrderMagicNumber() == _MagicNumber)  
    {
     orderType=OrderType();
     if (orderType==OP_BUYLIMIT || orderType==OP_BUYSTOP || orderType==OP_SELLLIMIT || orderType==OP_SELLSTOP)
     {
      if (TimeCurrent() > OrderExpiration())
      {
       Alert("������ ����� �����=", OrderTicket()," TimeCurrent=",TimeCurrent()," OrderExpiration=",TimeToStr(OrderExpiration(), TIME_DATE),":",TimeToStr(OrderExpiration(), TIME_MINUTES));
       OrderDelete(OrderTicket(), clDelete);
      }
     }
    }
   }
  }
 }
}