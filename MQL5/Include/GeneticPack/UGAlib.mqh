//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
//|                                                       JQS UGA v1.3.1 |
//|                                       Copyright ｩ 2010, JQS aka Joo. |
//|                                     http://www.mql4.com/ru/users/joo |
//|                                  https://login.mql5.com/ru/users/joo |
//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
//ﾁ鞦�韶�裲� "ﾓ�鞣褞�琿���胛 ﾃ褊褪顆褥��胛 ﾀ�胛�頸�� UGAlib"             |
//頌����銛��裙� ��裝��珞�褊韃 ��������� 粢�褥�粢����� �頌�瑟�.           |
//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
#include "MATrainLib.mqh"

//----------------------ﾃ��矜����� �褞褌褊���-----------------------------
double Chromosome[];            //ﾍ珮�� ���韲韈頏�褌�� 瑩胚�褊��� �����韋 - 肄���
                                //(�瑜�韲褞: 粢�� �裨������ �褪� � �.�.)-���������
int    ChromosomeCount     =0;  //ﾌ瑕�韲琿��� 粽銕�跫�� ���顆褥�粽 �������� � �����韋
int    TotalOfChromosomesInHistory=0;//ﾎ碼裹 ���顆褥�粽 �������� � 頌���韋
int    ChrCountInHistory   =0;  //ﾊ��顆褥�粽 ��韭琿���� �������� � 矜鈑 ��������
int    GeneCount           =0;  //ﾊ��顆褥�粽 肄��� � ���������

double RangeMinimum        =0.0;//ﾌ竟韲�� 蒻瑜珸��� ��頌��
double RangeMaximum        =0.0;//ﾌ瑕�韲�� 蒻瑜珸��� ��頌��
double Precision           =0.0;//ﾘ璢 ��頌��
int    OptimizeMethod      =0;  //1-�竟韲��, ��碚� 蓿�胛� - �瑕�韲��

double Population   [][1000];   //ﾏ��������
double Colony       [][500];    //ﾊ������ ��������
int    PopulChromosCount   =0;  //ﾒ裲��裹 ���顆褥�粽 �������� � �������韋
int    Epoch               =0;  //ﾊ��-粽 ���� 砒� �����褊��
int    AmountStartsFF=0;        //ﾊ��顆褥�粽 鈞������ �����韋 ��頌����硴褊�����


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾎ���粹�� ������� UGA
void UGA
(
double ReplicationPortion, //ﾄ��� ﾐ襃�韭璋韋.
double NMutationPortion,   //ﾄ��� ﾅ��褥�粢���� ���璋韋.
double ArtificialMutation, //ﾄ��� ﾈ������粢���� ���璋韋.
double GenoMergingPortion, //ﾄ��� ﾇ琲���粽籵��� 肄���.
double CrossingOverPortion,//ﾄ��� ﾊ����竟胛粢��.
//---
double ReplicationOffset,  //ﾊ����頽韃�� ��襌褊�� 胙瑙頽 竟�褞籵��
double NMutationProbability//ﾂ褞�������� ���璋韋 �琥蒡胛 肄�� � %
)
{ 
  //�碣�� 肄�褞瑣���, ���韈粽蒻��� ������ �蒻� �珸
  MathSrand((int)TimeLocal());
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int    chromos=0, gene  =0;//竟蒟��� �������� � 肄���
  int    resetCounterFF   =1;//��褪�韭 �碣���� "ﾝ��� 砒� �����褊韜"
  int    currentEpoch     =1;//���褞 �裲��裨 �����
  int    SumOfCurrentEpoch=0;//����� "ﾝ��� 砒� �����褊韜"
  int    MinOfCurrentEpoch=Epoch;//�竟韲琿���� "ﾝ��� 砒� �����褊韜"
  int    MaxOfCurrentEpoch=0;//�瑕�韲琿���� "ﾝ��� 砒� �����褊韜"
  int    epochGlob        =0;//�碼裹 ���顆褥�粽 ����
  // ﾊ������ [���顆褥�粽 ��韈�瑕��(肄���)][���顆褥�粽 ���砒� � �����韋]
  ArrayResize    (Population,GeneCount+1);
  ArrayInitialize(Population,0.0);
  // ﾊ������ �������� [���顆褥�粽 ��韈�瑕��(肄���)][���顆褥�粽 ���砒� � �����韋]
  ArrayResize    (Colony,GeneCount+1);
  ArrayInitialize(Colony,0.0);
  // ﾁ瑙� ��������
  // [���顆褥�粽 ��韈�瑕��(肄���)][���顆褥�粽 �������� � 矜��蘊
  double          historyHromosomes[][100000];
  ArrayResize    (historyHromosomes,GeneCount+1);
  ArrayInitialize(historyHromosomes,0.0);
  //----------------------------------------------------------------------
  //--------------ﾏ��粢��� ����裲������ 糢�蓖�� �瑩瑟褪���----------------
  //...���顆褥�粽 �������� 蒡�跫� 磊�� �� �褊��� 2
  if (ChromosomeCount<=1)  ChromosomeCount=2;
  if (ChromosomeCount>500) ChromosomeCount=500;
  //----------------------------------------------------------------------
  //======================================================================
  // 1) ﾑ�鈕瑣� ��������������                                     覧覧�1)
  ProtopopulationBuilding ();
  //======================================================================
  // 2) ﾎ��裝褄頸� ��頌����硴褊����� �琥蒡� ���礪                  覧覧�2)
  //ﾄ�� 1-�� �����韋
  for (chromos=0;chromos<ChromosomeCount;chromos++)
    for (gene=1;gene<=GeneCount;gene++)
      Colony[gene][chromos]=Population[gene][chromos];

  GetFitness(historyHromosomes);

  for (chromos=0;chromos<ChromosomeCount;chromos++)
    Population[0][chromos]=Colony[0][chromos];

  //ﾄ�� 2-�� �����韋
  for (chromos=ChromosomeCount;chromos<ChromosomeCount*2;chromos++)
    for (gene=1;gene<=GeneCount;gene++)
      Colony[gene][chromos-ChromosomeCount]=Population[gene][chromos];

  GetFitness(historyHromosomes);

  for (chromos=ChromosomeCount;chromos<ChromosomeCount*2;chromos++)
    Population[0][chromos]=Colony[0][chromos-ChromosomeCount];
  //======================================================================
  // 3) ﾏ�蒹���粨�� ��������� � �珸���趺���                         覧覧3)
  RemovalDuplicates();
  //======================================================================
  // 4) ﾂ�蒟�頸� ��琿����� ���������                               覧覧�4)
  for (gene=0;gene<=GeneCount;gene++)
    Chromosome[gene]=Population[gene][0];
  //======================================================================
  //ServiceFunction();

  //ﾎ���粹�� �韭� 肄�褪顆褥��胛 琿胛�頸�� � 5 �� 6
  while (currentEpoch<=Epoch)
  {
    //====================================================================
    // 5) ﾎ�褞瑣��� UGA                                            覧覧�5)
    CycleOfOperators
    (
    historyHromosomes,
    //---
    ReplicationPortion, //ﾄ��� ﾐ襃�韭璋韋.
    NMutationPortion,   //ﾄ��� ﾅ��褥�粢���� ���璋韋.
    ArtificialMutation, //ﾄ��� ﾈ������粢���� ���璋韋.
    GenoMergingPortion, //ﾄ��� ﾇ琲���粽籵��� 肄���.
    CrossingOverPortion,//ﾄ��� ﾊ����竟胛粢��.
    //---
    ReplicationOffset,  //ﾊ����頽韃�� ��襌褊�� 胙瑙頽 竟�褞籵��
    NMutationProbability//ﾂ褞�������� ���璋韋 �琥蒡胛 肄�� � %
    );
    //====================================================================
    // 6) ﾑ�珞�頸� 肄�� ����裙� ������� � 肄�瑟� ��琿����� ���������. 
    // ﾅ��� ��������� ����裙� ������� ����� ��琿�����,
    // 鈞�褊頸� ��琿�����.                                         覧覧�6)
    //ﾅ��� �褂韲 ���韲韈璋韋 - �竟韲韈璋��
    if (OptimizeMethod==1)
    {
      //ﾅ��� ������ ��������� �������韋 ����� ��琿�����
      if (Population[0][0]<Chromosome[0])
      {
        //ﾇ瑟褊韲 ��琿����� ���������
        for (gene=0;gene<=GeneCount;gene++)
          Chromosome[gene]=Population[gene][0];
      //  ServiceFunction();
        //ﾑ碣��韲 ��褪�韭 "���� 砒� �����褊韜"
        if (currentEpoch<MinOfCurrentEpoch)
          MinOfCurrentEpoch=currentEpoch;
        if (currentEpoch>MaxOfCurrentEpoch)
          MaxOfCurrentEpoch=currentEpoch;
        SumOfCurrentEpoch+=currentEpoch; currentEpoch=1; resetCounterFF++;
      }
      else
        currentEpoch++;
    }
    //ﾅ��� �褂韲 ���韲韈璋韋 - �瑕�韲韈璋��
    else
    {
      //ﾅ��� ������ ��������� �������韋 ����� ��琿�����
      if (Population[0][0]>Chromosome[0])
      {
        //ﾇ瑟褊韲 ��琿����� ���������
        for (gene=0;gene<=GeneCount;gene++)
          Chromosome[gene]=Population[gene][0];
     //   ServiceFunction();
        //ﾑ碣��韲 ��褪�韭 "���� 砒� �����褊韜"
        if (currentEpoch<MinOfCurrentEpoch)
          MinOfCurrentEpoch=currentEpoch;
        if (currentEpoch>MaxOfCurrentEpoch)
          MaxOfCurrentEpoch=currentEpoch;
        SumOfCurrentEpoch+=currentEpoch; currentEpoch=1; resetCounterFF++;
      }
      else
        currentEpoch++;
    }
    //====================================================================
    //ﾏ����� 襌ｸ �蓖� �����....
    epochGlob++;
  }

}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾑ�鈕瑙韃 ������������韋
void ProtopopulationBuilding()
{ 
  PopulChromosCount=ChromosomeCount*2;
  //ﾇ瑜���頸� ��������� ��������瑟� �� ����琺����
  //...肄�瑟� � 蒻瑜珸��� RangeMinimum...RangeMaximum
  for (int chromos=0;chromos<PopulChromosCount;chromos++)
  {
    //�璞竟�� � 1-胛 竟蒟��� (0-�� -鈞�裼褞粨��籵� 蓁� VFF) 
    for (int gene=1;gene<=GeneCount;gene++)
      Population[gene][chromos]=
      SelectInDiscreteSpace(RNDfromCI(RangeMinimum,RangeMaximum),RangeMinimum,RangeMaximum,Precision,3);
    TotalOfChromosomesInHistory++;
  }
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾏ����褊韃 ��頌����硴褊����� 蓁� �琥蒡� ���礪.
void GetFitness
(
double &historyHromosomes[][100000]
)
{ 
  for (int chromos=0;chromos<ChromosomeCount;chromos++)
    CheckHistoryChromosomes(chromos,historyHromosomes);
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾏ��粢��� ��������� �� 矜鈑 ��������.
void CheckHistoryChromosomes
(
int     chromos,
double &historyHromosomes[][100000]
)
{ 
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int   Ch1=0;  //ﾈ�蒟�� ��������� 韈 矜鍄
  int   Ge =0;  //ﾈ�蒟�� 肄��
  int   cnt=0;  //ﾑ�褪�韭 ��韭琿���� 肄���. ﾅ��� ���� �蒻� 肄� ���顆瑯��� 
                //- ��������� ��韈�瑯��� ��韭琿����
  //----------------------------------------------------------------------
  //ﾅ��� � 矜鈑 ��瑙頸�� ���� �蓖� ���������
  if (ChrCountInHistory>0)
  {
    //ﾏ褞裔褞褌 ��������� � 矜鈑, ���磊 �琺�� �瑕�� 趺
    for (Ch1=0;Ch1<ChrCountInHistory && cnt<GeneCount;Ch1++)
    {
      cnt=0;
      //ﾑ粢��褌 肄��, ���� 竟蒟�� 肄�� �褊��� ���-籵 肄��� � ���� ���琅����� �蒻�瑕�糺� 肄��
      for (Ge=1;Ge<=GeneCount;Ge++)
      {
        if (Colony[Ge][chromos]!=historyHromosomes[Ge][Ch1])
          break;
        cnt++;
      }
    }
    //ﾅ��� �珮�琿��� �蒻�瑕�糺� 肄��� ������� 趺, ��跫� 粡��� 胛��粽� �褸褊韃 韈 矜鍄
    if (cnt==GeneCount)
      Colony[0][chromos]=historyHromosomes[0][Ch1-1];
    //ﾅ��� �褪 �瑕�� 趺 ��������� � 矜鈑, �� �瑰��頸瑯� 蓁� �蟶 FF...
    else
    {
    
      FitnessFunction(chromos);
      //.. � 褥�� 褥�� �褥�� � 矜鈑 ����瑙韲
      if (ChrCountInHistory<100000)
      {
        for (Ge=0;Ge<=GeneCount;Ge++)
          historyHromosomes[Ge][ChrCountInHistory]=Colony[Ge][chromos];
        ChrCountInHistory++;
      }
    }
  }
  //ﾅ��� 矜鈞 ������, �瑰��頸瑯� 蓁� �蟶 FF � ����瑙韲 蟶 � 矜鈑
  else
  {
    FitnessFunction(chromos);
    for (Ge=0;Ge<=GeneCount;Ge++)
      historyHromosomes[Ge][ChrCountInHistory]=Colony[Ge][chromos];
    ChrCountInHistory++;
  }
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾖ韭� ��褞瑣���� UGA
void CycleOfOperators
(
double &historyHromosomes[][100000],
//---
double    ReplicationPortion, //ﾄ��� ﾐ襃�韭璋韋.
double    NMutationPortion,   //ﾄ��� ﾅ��褥�粢���� ���璋韋.
double    ArtificialMutation, //ﾄ��� ﾈ������粢���� ���璋韋.
double    GenoMergingPortion, //ﾄ��� ﾇ琲���粽籵��� 肄���.
double    CrossingOverPortion,//ﾄ��� ﾊ����竟胛粢��.
//---
double    ReplicationOffset,  //ﾊ����頽韃�� ��襌褊�� 胙瑙頽 竟�褞籵��
double    NMutationProbability//ﾂ褞�������� ���璋韋 �琥蒡胛 肄�� � %
)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  double          child[];
  ArrayResize    (child,GeneCount+1);
  ArrayInitialize(child,0.0);

  int gene=0,chromos=0, border=0;
  int    i=0,u=0;
  double p=0.0,start=0.0;
  double          fit[][2];
  ArrayResize    (fit,6);
  ArrayInitialize(fit,0.0);

  //ﾑ�褪�韭 ���琅����� �褥� � ��粽� �������韋.
  int T=0;
  //----------------------------------------------------------------------

  //ﾇ琅琅韲 蒡�� ��褞瑣���� UGA
  double portion[6];
  portion[0]=ReplicationPortion; //ﾄ��� ﾐ襃�韭璋韋.
  portion[1]=NMutationPortion;   //ﾄ��� ﾅ��褥�粢���� ���璋韋.
  portion[2]=ArtificialMutation; //ﾄ��� ﾈ������粢���� ���璋韋.
  portion[3]=GenoMergingPortion; //ﾄ��� ﾇ琲���粽籵��� 肄���.
  portion[4]=CrossingOverPortion;//ﾄ��� ﾊ����竟胛粢��.
  portion[5]=0.0;
  //----------------------------
  if (NMutationProbability<0.0)
    NMutationProbability=0.0;
  if (NMutationProbability>100.0)
    NMutationProbability=100.0;
  //----------------------------
  //------------------------ﾖ韭� ��褞瑣���� UGA---------
  //ﾇ瑜����褌 ��糒� ������� ������瑟� 
  while (T<ChromosomeCount)
  {
    //============================
    for (i=0;i<6;i++)
    {
      fit[i][0]=start;
      fit[i][1]=start+MathAbs(portion[i]-portion[5]);
      start=fit[i][1];
    }
    p=RNDfromCI(fit[0][0],fit[4][1]);
    for (u=0;u<5;u++)
    {
      if ((fit[u][0]<=p && p<fit[u][1]) || p==fit[u][1])
        break;
    }
    //============================
    switch (u)
    {
    //---------------------
    case 0:
      //------------------------ﾐ襃�韭璋��--------------------------------
      //ﾅ��� 褥�� �褥�� � ��粽� �����韋, ��鈕琅韲 ��糒� ���磬
      if (T<ChromosomeCount)
      {
        Replication(child,ReplicationOffset);
        //ﾏ��褄韲 ��糒� ���磬 � ��糒� �������
        for (gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //ﾎ蓖� �褥�� 鈞����, ��褪�韭 �褞褌��瑯� 糀褞裝
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------
      break;
      //---------------------
    case 1:
      //---------------------ﾅ��褥�粢���� ���璋��-------------------------
      //ﾅ��� 褥�� �褥�� � ��粽� �����韋, ��鈕琅韲 ��糒� ���磬
      if (T<ChromosomeCount)
      {
        NaturalMutation(child,NMutationProbability);
        //ﾏ��褄韲 ��糒� ���磬 � ��糒� �������
        for (gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //ﾎ蓖� �褥�� 鈞����, ��褪�韭 �褞褌��瑯� 糀褞裝
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------
      break;
      //---------------------
    case 2:
      //----------------------ﾈ������粢���� ���璋��-----------------------
      //ﾅ��� 褥�� �褥�� � ��粽� �����韋, ��鈕琅韲 ��糒� ���磬
      if (T<ChromosomeCount)
      {
        ArtificialMutation(child,ReplicationOffset);
        //ﾏ��褄韲 ��糒� ���磬 � ��糒�  �������
        for (gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //ﾎ蓖� �褥�� 鈞����, ��褪�韭 �褞褌��瑯� 糀褞裝
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------
      break;
      //---------------------
    case 3:
      //-------------ﾎ碣珸�籵�韃 ���礪 � 鈞韲��粽籵����� 肄�瑟�-----------
      //ﾅ��� 褥�� �褥�� � ��粽� �����韋, ��鈕琅韲 ��糒� ���磬
      if (T<ChromosomeCount)
      {
        GenoMerging(child);
        //ﾏ��褄韲 ��糒� ���磬 � ��糒� ������� 
        for (gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //ﾎ蓖� �褥�� 鈞����, ��褪�韭 �褞褌��瑯� 糀褞裝
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------
      break;
      //---------------------
    default:
      //---------------------------ﾊ����竟胛粢�---------------------------
      //ﾅ��� 褥�� �褥�� � ��粽� �����韋, ��鈕琅韲 ��糒� ���磬
      if (T<ChromosomeCount)
      {
        CrossingOver(child);
        //ﾏ��褄韲 ��糒� ���磬 � ��糒�  �������
        for (gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //ﾎ蓖� �褥�� 鈞����, ��褪�韭 �褞褌��瑯� 糀褞裝
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------

      break;
      //---------------------
    }
  }//ﾊ��褻 �韭�� ��褞瑣���� UGA--

  //ﾎ��裝褄韲 ��頌����硴褊����� �琥蒡� ���礪 � �����韋 ��������
  GetFitness(historyHromosomes);

  //ﾏ��褄韲 �������� � ����粹�� ���������
  if (PopulChromosCount>=ChromosomeCount)
  {
    border=ChromosomeCount;
    PopulChromosCount=ChromosomeCount*2;
  }
  else
  {
    border=PopulChromosCount;
    PopulChromosCount+=ChromosomeCount;
  }
  for (chromos=0;chromos<ChromosomeCount;chromos++)
    for (gene=0;gene<=GeneCount;gene++)
      Population[gene][chromos+border]=Colony[gene][chromos];

  //ﾏ�蒹���粨� ��������� � ��裝���褌� �珸���趺���
  RemovalDuplicates();
}//���褻 �-韋
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾐ襃�韭璋��
void Replication
(
double &child[],
double  ReplicationOffset
)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  double C1=0.0,C2=0.0,temp=0.0,Maximum=0.0,Minimum=0.0;
  int address_mama=0,address_papa=0;
  //----------------------------------------------------------------------
  SelectTwoParents(address_mama,address_papa);
  //-------------------ﾖ韭� �褞裔��� 肄���--------------------------------
  for (int i=1;i<=GeneCount;i++)
  {
    //----���裝褄韲 ����萵 �瑣� � ��褻 --------
    C1 = Population[i][address_mama];
    C2 = Population[i][address_papa];
    //------------------------------------------
    
    //------------------------------------------------------------------
    //....���裝褄韲 �琲碚���韜 � �琲�褊��韜 韈 �頷,
    //褥�� ﾑ1>C2, ���褊�褌 頷 �褥�瑟�
    if (C1>C2)
    {
      temp = C1; C1=C2; C2 = temp;
    }
    //--------------------------------------------
    if (C2-C1<Precision)
    {
      child[i]=C1; continue;
    }
    //--------------------------------------------
    //ﾍ珸�璞韲 胙瑙頽� ��鈕瑙�� ��粽胛 肄��
    Minimum = C1-((C2-C1)*ReplicationOffset);
    Maximum = C2+((C2-C1)*ReplicationOffset);
    //--------------------------------------------
    //ﾎ��鈞�褄���� ���粢���, ��� 磊 ��頌� �� 糺�褄 韈 鈞萵���胛 蒻瑜珸���
    if (Minimum < RangeMinimum) Minimum = RangeMinimum;
    if (Maximum > RangeMaximum) Maximum = RangeMaximum;
    //---------------------------------------------------------------
    temp=RNDfromCI(Minimum,Maximum);
    child[i]=
    SelectInDiscreteSpace(temp,RangeMinimum,RangeMaximum,Precision,3);
  }
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾅ��褥�粢���� ���璋��.
void NaturalMutation
(
double &child[],
double  NMutationProbability
)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int    address=0;
  //----------------------------------------------------------------------
  
  //-----------------ﾎ�碚� ��蒻�褄�------------------------
  SelectOneParent(address);
  //---------------------------------------
  for (int i=1;i<=GeneCount;i++)
    if (RNDfromCI(0.0,100.0)<=NMutationProbability)
      child[i]=
      SelectInDiscreteSpace(RNDfromCI(RangeMinimum,RangeMaximum),RangeMinimum,RangeMaximum,Precision,3);
    else
      child[i]=Population[i][address];
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾈ������粢���� ���璋��.
void ArtificialMutation
(
double &child[],
double  ReplicationOffset
)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  double C1=0.0,C2=0.0,temp=0.0,Maximum=0.0,Minimum=0.0,p=0.0;
  int address_mama=0,address_papa=0;
  //----------------------------------------------------------------------
  //-----------------ﾎ�碚� ��蒻�褄裨------------------------
  SelectTwoParents(address_mama,address_papa);
  //--------------------------------------------------------
  //-------------------ﾖ韭� �褞裔��� 肄���------------------------------
  for (int i=1;i<=GeneCount;i++)
  {
    //----���裝褄韲 ����萵 �瑣� � ��褻 --------
    C1 = Population[i][address_mama];
    C2 = Population[i][address_papa];
    //------------------------------------------
    
    //------------------------------------------------------------------
    //....���裝褄韲 �琲碚���韜 � �琲�褊��韜 韈 �頷,
    //褥�� ﾑ1>C2, ���褊�褌 頷 �褥�瑟�
    if (C1>C2)
    {
      temp=C1; C1=C2; C2=temp;
    }
    //--------------------------------------------
    //ﾍ珸�璞韲 胙瑙頽� ��鈕瑙�� ��粽胛 肄��
    Minimum=C1-((C2-C1)*ReplicationOffset);
    Maximum=C2+((C2-C1)*ReplicationOffset);
    //--------------------------------------------
    //ﾎ��鈞�褄���� ���粢���, ��� 磊 ��頌� �� 糺�褄 韈 鈞萵���胛 蒻瑜珸���
    if (Minimum < RangeMinimum) Minimum = RangeMinimum;
    if (Maximum > RangeMaximum) Maximum = RangeMaximum;
    //---------------------------------------------------------------
    p=MathRand();
    if (p<16383.5)
    {
      temp=RNDfromCI(RangeMinimum,Minimum);
      child[i]=
      SelectInDiscreteSpace(temp,RangeMinimum,RangeMaximum,Precision,3);
    }
    else
    {
      temp=RNDfromCI(Maximum,RangeMaximum);
      child[i]=
      SelectInDiscreteSpace(temp,RangeMinimum,RangeMaximum,Precision,3);
    }
  }
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾇ琲���粽籵�韃 肄���.
void GenoMerging
(
double &child[]
)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int  address=0;
  //----------------------------------------------------------------------
  for (int i=1;i<=GeneCount;i++)
  {
    //-----------------ﾎ�碚� ��蒻�褄�------------------------
    SelectOneParent(address);
    //--------------------------------------------------------
    child[i]=Population[i][address];
  }
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾊ����竟胛粢�.
void CrossingOver
(
double &child[]
)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int address_mama=0,address_papa=0;
  //----------------------------------------------------------------------
  //-----------------ﾎ�碚� ��蒻�褄裨------------------------
  SelectTwoParents(address_mama,address_papa);
  //--------------------------------------------------------
  //ﾎ��裝褄韲 ����� �珸��籵
  int address_of_gene=(int)MathFloor((GeneCount-1)*(MathRand()/32767.5));

  for (int i=1;i<=GeneCount;i++)
  {
    //----���頏�褌 肄�� �瑣褞�--------
    if (i<=address_of_gene+1)
      child[i]=Population[i][address_mama];
    //----���頏�褌 肄�� ����--------
    else
      child[i]=Population[i][address_papa];
  }
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾎ�碚� 葢�� ��蒻�褄裨.
void SelectTwoParents
(
int &address_mama,
int &address_papa
)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int cnt=1;
  address_mama=0;//琅�褥 �瑣褞竟���� ���礪 � �������韋
  address_papa=0;//琅�褥 ����糂��� ���礪 � �������韋
  //----------------------------------------------------------------------
  //----------------------------ﾎ�碚� ��蒻�褄裨--------------------------
  //ﾄ褥��� ������� 糺碣瑣� �珸��� ��蒻�褄裨.
  while (cnt<=10)
  {
    //ﾄ�� �瑣褞竟���� ���礪
    address_mama=NaturalSelection();
    //ﾄ�� ����糂��� ���礪
    address_papa=NaturalSelection();
    if (address_mama!=address_papa)
      break;
    cnt++;
  }
  //---------------------------------------------------------------------
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾎ�碚� �蓖�胛 ��蒻�褄�.
void SelectOneParent
(
int &address//琅�褥 ��蒻�褄����� ���礪 � �������韋
)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  address=0;
  //----------------------------------------------------------------------
  //----------------------------ﾎ�碚� ��蒻�褄�--------------------------
  address=NaturalSelection();
  //---------------------------------------------------------------------
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾅ��褥�粢���� ��碚�.
int NaturalSelection()
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int    i=0,u=0;
  double p=0.0,start=0.0;
  double          fit[][2];
  ArrayResize    (fit,PopulChromosCount);
  ArrayInitialize(fit,0.0);
  double delta=(Population[0][0]-Population[0][PopulChromosCount-1])*0.01-Population[0][PopulChromosCount-1];
  //----------------------------------------------------------------------

  for (i=0;i<PopulChromosCount;i++)
  {
    fit[i][0]=start;
    fit[i][1]=start+MathAbs(Population[0][i]+delta);
    start=fit[i][1];
  }
  p=RNDfromCI(fit[0][0],fit[PopulChromosCount-1][1]);

  for (u=0;u<PopulChromosCount;u++)
    if ((fit[u][0]<=p && p<fit[u][1]) || p==fit[u][1])
      break;

  return(u);
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾓ萵�褊韃 蔘硴韭瑣�� � ����頏�粲�� �� VFF
void RemovalDuplicates()
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int             chromosomeUnique[1000];//ﾌ瑰�鞣 ��瑙頸 ��韈�瑕 ��韭琿������ 
                                         //�琥蒡� ���������: 0-蔘硴韭瑣, 1-��韭琿����
  ArrayInitialize(chromosomeUnique,1);   //ﾏ�裝����跖�, ��� 蔘硴韭瑣�� �褪
  double          PopulationTemp[][1000];
  ArrayResize    (PopulationTemp,GeneCount+1);
  ArrayInitialize(PopulationTemp,0.0);

  int Ge =0;                             //ﾈ�蒟�� 肄��
  int Ch =0;                             //ﾈ�蒟�� ���������
  int Ch2=0;                             //ﾈ�蒟�� 糘���� ���������
  int cnt=0;                             //ﾑ�褪�韭
  //----------------------------------------------------------------------

  //----------------------ﾓ萵�韲 蔘硴韭瑣�---------------------------1
  //ﾂ�礪�瑯� �褞糺� 韈 �瑩� 蓁� ��珞�褊��...
  for (Ch=0;Ch<PopulChromosCount-1;Ch++)
  {
    //ﾅ��� �� 蔘硴韭瑣...
    if (chromosomeUnique[Ch]!=0)
    {
      //ﾂ�礪�瑯� 糘���� 韈 �瑩�...
      for (Ch2=Ch+1;Ch2<PopulChromosCount;Ch2++)
      {
        if (chromosomeUnique[Ch2]!=0)
        {
          //ﾎ硼��韲 ��褪�韭 ���顆褥�籵 鞴褊�顆��� 肄���
          cnt=0;
          //ﾑ粢��褌 肄��, ���� ���琅����� �蒻�瑕�糺� 肄��
          for (Ge=1;Ge<=GeneCount;Ge++)
          {
            if (Population[Ge][Ch]!=Population[Ge][Ch2])
              break;
            else
              cnt++;
          }
          //ﾅ��� �珮�琿��� �蒻�瑕�糺� 肄��� ������� 趺, ������� 糂裙� 肄���
          //..��������� ��韈�瑯��� 蔘硴韭瑣��
          if (cnt==GeneCount)
            chromosomeUnique[Ch2]=0;
        }
      }
    }
  }
  //ﾑ�褪�韭 ����頸瑯� ���顆褥�粽 ��韭琿���� ��������
  cnt=0;
  //ﾑ���頏�褌 ��韭琿���� ��������� 粽 糅褌褊��� �瑰鞣
  for (Ch=0;Ch<PopulChromosCount;Ch++)
  {
    //ﾅ��� ��������� ��韭琿���, ����頏�褌 蟶, 褥�� �褪, �褞裨蒟� � ��裝���裨
    if (chromosomeUnique[Ch]==1)
    {
      for (Ge=0;Ge<=GeneCount;Ge++)
        PopulationTemp[Ge][cnt]=Population[Ge][Ch];
      cnt++;
    }
  }
  //ﾍ珸�璞韲 �褞褌褊��� "ﾂ�裙� ��������" 鈿璞褊韃 ��褪�韭� ��韭琿���� ��������
  PopulChromosCount=cnt;
  //ﾂ褞�褌 ��韭琿���� ��������� �碣瑣�� � �瑰�鞣 蓁� 糅褌褊��胛 ��瑙褊�� 
  //..�磬裝竟�褌�� �������韜 
  for (Ch=0;Ch<PopulChromosCount;Ch++)
    for (Ge=0;Ge<=GeneCount;Ge++)
      Population[Ge][Ch]=PopulationTemp[Ge][Ch];
  //=================================================================1

  //----------------ﾐ瑙跖��籵�韃 �������韋---------------------------2
  PopulationRanking();
  //=================================================================2
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾐ瑙跖��籵�韃 �������韋.
void PopulationRanking()
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  int cnt=1, i = 0, u = 0;
  double          PopulationTemp[][1000];           //ﾂ�褌褊��� ��������� 
  ArrayResize    (PopulationTemp,GeneCount+1);
  ArrayInitialize(PopulationTemp,0.0);

  int             Indexes[];                        //ﾈ�蒟��� ��������
  ArrayResize    (Indexes,PopulChromosCount);
  ArrayInitialize(Indexes,0);
  int    t0=0;
  double          ValueOnIndexes[];                 //VFF ����粢���糒��頷
                                                    //..竟蒟���� ��������
  ArrayResize    (ValueOnIndexes,PopulChromosCount);
  ArrayInitialize(ValueOnIndexes,0.0); double t1=0.0;
  //----------------------------------------------------------------------

  //ﾏ����珞韲 竟蒟��� 粽 糅褌褊��� �瑰�鞣� temp2 � 
  //...����頏�褌 �褞糒� ������ 韈 ����頏�褌�胛 �瑰�鞣�
  for (i=0;i<PopulChromosCount;i++)
  {
    Indexes[i] = i;
    ValueOnIndexes[i] = Population[0][i];
  }
  if (OptimizeMethod==1)
  {
    while (cnt>0)
    {
      cnt=0;
      for (i=0;i<PopulChromosCount-1;i++)
      {
        if (ValueOnIndexes[i]>ValueOnIndexes[i+1])
        {
          //-----------------------
          t0 = Indexes[i+1];
          t1 = ValueOnIndexes[i+1];
          Indexes   [i+1] = Indexes[i];
          ValueOnIndexes   [i+1] = ValueOnIndexes[i];
          Indexes   [i] = t0;
          ValueOnIndexes   [i] = t1;
          //-----------------------
          cnt++;
        }
      }
    }
  }
  else
  {
    while (cnt>0)
    {
      cnt=0;
      for (i=0;i<PopulChromosCount-1;i++)
      {
        if (ValueOnIndexes[i]<ValueOnIndexes[i+1])
        {
          //-----------------------
          t0 = Indexes[i+1];
          t1 = ValueOnIndexes[i+1];
          Indexes   [i+1] = Indexes[i];
          ValueOnIndexes   [i+1] = ValueOnIndexes[i];
          Indexes   [i] = t0;
          ValueOnIndexes   [i] = t1;
          //-----------------------
          cnt++;
        }
      }
    }
  }
  //ﾑ�鈕琅韲 ������頏�籵���� �瑰�鞣 �� �����褊��� 竟蒟��瑟
  for (i=0;i<GeneCount+1;i++)
    for (u=0;u<PopulChromosCount;u++)
      PopulationTemp[i][u]=Population[i][Indexes[u]];
  //ﾑ���頏�褌 ������頏�籵���� �瑰�鞣 �碣瑣��
  for (i=0;i<GeneCount+1;i++)
    for (u=0;u<PopulChromosCount;u++)
      Population[i][u]=PopulationTemp[i][u];
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾃ褊褞瑣�� ����琺��� �頌褄 韈 鈞萵���胛 竟�褞籵��.
double RNDfromCI(double Minimum,double Maximum) 
{ return(Minimum+((Maximum-Minimum)*MathRand()/32767.5));}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ﾂ�碚� � 蒻���褪��� ������瑙��粢.
//ﾐ褂韲�:
//1-硴韆琺�裹 ��韈�
//2-硴韆琺�裹 �粢��� 
//��碚�-蒡 硴韆琺�裙�
double SelectInDiscreteSpace
(
double In, 
double InMin, 
double InMax, 
double step, 
int    RoundMode
)
{
  if (step==0.0)
    return(In);
  // �砒��褶韲 ��珞齏������ 胙瑙頽
  if ( InMax < InMin )
  {
    double temp = InMax; InMax = InMin; InMin = temp;
  }
  // ��� �瑩��褊韋 - 粢��褌 �瑩��褊��� 胙瑙頽�
  if ( In < InMin ) return( InMin );
  if ( In > InMax ) return( InMax );
  if ( InMax == InMin || step <= 0.0 ) return( InMin );
  // ��鞣裝褌 � 鈞萵����� �瑰��珮�
  step = (InMax - InMin) / MathCeil ( (InMax - InMin) / step );
  switch ( RoundMode )
  {
  case 1:  return( InMin + step * MathFloor ( ( In - InMin ) / step ) );
  case 2:  return( InMin + step * MathCeil  ( ( In - InMin ) / step ) );
  default: return( InMin + step * MathRound ( ( In - InMin ) / step ) );
  }
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
