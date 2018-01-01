# MQL_MYSQL


Self optimized further for MYSQL

Note : Credit goes to the initial author, modification of this script just for the conveniency of calling out function per usage.

*** ALL CHANGES IS MADE WITHIN THE SAME TABLE USING THE CREDENTIALS DETAILS PROVIDED ***

****DEFAULT SETTING FOR UPDATE IS BY REFERRING TO CURRENT SYMBOL ON CHART****

1. To update or create record, just use 
Code :
      database_update_query (int type, string column, double value) //type 1 = buy, 2 = sell)
      
2. To delete whole entry/row of current chart symbol
Code :
      database_delete_entry ()
      
3. To fetch the specific column of the chart symbol as double value
Code :
     database_fetch_double (string column)
     
4. To fetch the specific column of the chart symbol as integer value
Code :
     database_fetch_integer (string column)
     
     
