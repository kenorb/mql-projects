//+------------------------------------------------------------------+
//|                                                 config_C_Log.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define CONF_EXPIRATION_TIME 30              // ����� ����� ���� � ����
#define CONF_LIMIT_SIZE      50              // ���������� ������ log-����� � Mb
#define CONF_LOG_LEVEL       LOG_DEBUG       // ������� �����������
#define CONF_CATALOG_NAME    "Log"           // ��� �������� ��� �������� �����
// ������ ������ ����������
#define CONF_OUT_TEST        OUT_PRINT       // � ������� ��������� (���������� �����, �����������, ������������)
#define CONF_OUT_REAL_TIME   OUT_FILE        // � �������� �������
