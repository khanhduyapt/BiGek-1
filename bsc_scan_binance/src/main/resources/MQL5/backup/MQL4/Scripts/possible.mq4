//--------------------------------------------------------------------
// possible.mq4
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------------
int Count=0;                                    // ���������� �������.
//--------------------------------------------------------------------
int start()                                     // ����. �-�� start()
  {
   double Price=Bid;                            // ��������� �������.
   Count++;
   Alert("����� ��� ",Count,"   ���� = ",Price);// ���������
   return;                                      // ����� �� start()
  }
//--------------------------------------------------------------------
int init()                                      // ����. �-�� init()
  {
   Alert ("��������� �-�� init() ��� �������"); // ���������
   return;                                      // ����� �� init()   
  }
//--------------------------------------------------------------------
int deinit()                                    // ����. �-�� deinit()
  {
   Alert ("��������� �-�� deinit() ��� ��������");// ���������
   return;                                      // ����� �� deinit()
  }
//--------------------------------------------------------------------