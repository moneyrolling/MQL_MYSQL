/********************************************************************
 * MQLMySQL interface library                                       *
 ********************************************************************
 * This library uses MQLMySQL.DLL was developed as interface to con-*
 * nect to the MySQL database server.                               *
 * Note: Check expert advisor "Common" parameters to be sure that   *
 *       DLL imports are allowed.                      
 * Editted and Tweak to suite the author need.                      *
 ********************************************************************/
bool SQLTrace = false;
datetime MySqlLastConnect=0;

#import "..\libraries\MQLMySQL.dll"
// returns version of MySqlCursor.dll library
string cMySqlVersion ();

// number of last error of connection
int    cGetMySqlErrorNumber(int pConnection);

// number of last error of cursor
int    cGetCursorErrorNumber(int pCursorID);

// description of last error for connection
string cGetMySqlErrorDescription(int pConnection);

// description of last error for cursor
string cGetCursorErrorDescription(int pCursorID);

// establish connection to MySql database server
// and return connection identifier
int    cMySqlConnect       (string pHost,       // Host name
                            string pUser,       // User
                            string pPassword,   // Password
                            string pDatabase,   // Database name
                            int    pPort,       // Port
                            string pSocket,     // Socket for Unix
                            int    pClientFlag);// Client flag
// closes connection to database
void   cMySqlDisconnect    (int pConnection);   // pConnection - database identifier (pointer to structure)
// executes non-SELECT statements
bool   cMySqlExecute       (int    pConnection, // pConnection - database identifier (pointer to structure)
                            string pQuery);     // pQuery      - SQL query for execution
// creates an cursor based on SELECT statement
// return valuse - cursor identifier
int    cMySqlCursorOpen    (int    pConnection, // pConnection - database identifier (pointer to structure)
                            string pQuery);     // pQuery      - SELECT statement for execution
// closes opened cursor
void   cMySqlCursorClose   (int pCursorID);     // pCursorID  - internal identifier of cursor
// return number of rows was selected by cursor
int    cMySqlCursorRows    (int pCursorID);     // pCursorID  - internal identifier of cursor
// fetch next row from cursor into current row buffer
// return true - if succeeded, otherwise - false
bool   cMySqlCursorFetchRow(int pCursorID);     // pCursorID  - internal identifier of cursor
// retrieves the value from current row was fetched by cursor
string cMySqlGetRowField   (int    pCursorID,   // pCursorID  - internal identifier of cursor
                            int    pField);     // pField     - number of field in SELECT clause (started from 0,1,2... e.t.c.)

// Reads and returns the key value from standard INI-file
string ReadIni             (string pFileName,   // INI-filename
                            string pSection,    // name of section
                            string pKey);       // name of key
#import


//interface variables
int    MySqlErrorNumber;       // recent MySQL error number
string MySqlErrorDescription;  // error description

// return the version of MySQLCursor.DLL
string MySqlVersion()
{
 return(cMySqlVersion());
}

// Interface function MySqlConnect - make connection to MySQL database using parameter:
// pHost       - DNS name or IP-address
// pUser       - database user (f.e. root)
// pPassword   - password of user (f.e. Zok1LmVdx)
// pDatabase   - database name (f.e. metatrader)
// pPort       - TCP/IP port of database listener (f.e. 3306)
// pSocket     - unix socket (for sockets or named pipes using)
// pClientFlag - combination of the flags for features (usual 0)
// ------------------------------------------------------------------------------------
// RETURN      - database connection identifier
//               if return value = 0, check MySqlErrorNumber and MySqlErrorDescription
int MySqlConnect(string pHost, string pUser, string pPassword, string pDatabase, int pPort, string pSocket, int pClientFlag)
{
 int connection;
 ClearErrors();
 connection = cMySqlConnect(pHost, pUser, pPassword, pDatabase, pPort, pSocket, pClientFlag);

 if (SQLTrace) Print ("Connecting to Host=", pHost, ", User=", pUser, ", Database=", pDatabase, " DBID#", connection);

 if (connection == -1)
    {
     MySqlErrorNumber = cGetMySqlErrorNumber(-1);
     MySqlErrorDescription = cGetMySqlErrorDescription(-1);
     if (SQLTrace) Print ("Connection error #",MySqlErrorNumber," ",MySqlErrorDescription);
    }
 else
    {
     MySqlLastConnect = TimeCurrent();
     if (SQLTrace) Print ("Connected! DBID#",connection);
    }
 
 return (connection);
}

// Interface function MySqlDisconnect - closes connection "pConnection" to database
// When no connection was established - nothing happends
void MySqlDisconnect(int &pConnection)
{
 ClearErrors();
 if (pConnection != -1) 
    {
     cMySqlDisconnect(pConnection);
     if (SQLTrace) Print ("DBID#",pConnection," disconnected");
     pConnection = -1;
    }
}

// Interface function MySqlExecute - executes SQL query via specified connection
// pConnection - opened database connection
// pQuery      - SQL query
// ------------------------------------------------------
// RETURN      - true : when execution succeded
//             - false: when any error was raised (see MySqlErrorNumber, MySqlErrorDescription, MySqlErrorQuery)
bool MySqlExecute(int pConnection, string pQuery)
{
 ClearErrors();
 if (SQLTrace) {Print ("DBID#",pConnection,", CMD:",pQuery);}
 if (pConnection == -1) 
    {
     // no connection
     MySqlErrorNumber = -2;
     MySqlErrorDescription = "No connection to the database.";
     if (SQLTrace) Print ("CMD>",MySqlErrorNumber, ": ", MySqlErrorDescription);
     return (false);
    }
 
 if (!cMySqlExecute(pConnection, pQuery))
    {
     MySqlErrorNumber = cGetMySqlErrorNumber(pConnection);
     MySqlErrorDescription = cGetMySqlErrorDescription(pConnection);
     if (SQLTrace) Print ("CMD>",MySqlErrorNumber, ": ", MySqlErrorDescription);
     return (false);
    }
 return (true);
}

// creates an cursor based on SELECT statement
// return valuse - cursor identifier
int MySqlCursorOpen(int pConnection, string pQuery)
{
 int result;
 if (SQLTrace) {Print ("DBID#",pConnection,", QRY:",pQuery);}
 ClearErrors();
 result = cMySqlCursorOpen(pConnection, pQuery);
 if (result == -1)
    {
     MySqlErrorNumber = cGetMySqlErrorNumber(pConnection);
     MySqlErrorDescription = cGetMySqlErrorDescription(pConnection);
     if (SQLTrace) Print ("QRY>",MySqlErrorNumber, ": ", MySqlErrorDescription);
    }
 return (result);
}

// closes opened cursor
void MySqlCursorClose(int pCursorID)
{
 ClearErrors();
 cMySqlCursorClose(pCursorID);
 MySqlErrorNumber = cGetCursorErrorNumber(pCursorID);
 MySqlErrorDescription = cGetCursorErrorDescription(pCursorID);
 if (SQLTrace) 
    {
     if (MySqlErrorNumber!=0)
        {
         Print ("Cursor #",pCursorID," closing error:", MySqlErrorNumber, ": ", MySqlErrorDescription);
        }
     else 
        {
         Print ("Cursor #",pCursorID," closed");
        }
    }
}

// return number of rows was selected by cursor
int MySqlCursorRows(int pCursorID)
{
 int result;
 result = cMySqlCursorRows(pCursorID);
 MySqlErrorNumber = cGetCursorErrorNumber(pCursorID);
 MySqlErrorDescription = cGetCursorErrorDescription(pCursorID);
 if (SQLTrace) Print ("Cursor #",pCursorID,", rows: ",result);
 return (result);
}

// fetch next row from cursor into current row buffer
// return true - if succeeded, otherwise - false
bool MySqlCursorFetchRow(int pCursorID)
{
 bool result;
 result = cMySqlCursorFetchRow(pCursorID);
 MySqlErrorNumber = cGetCursorErrorNumber(pCursorID);
 MySqlErrorDescription = cGetCursorErrorDescription(pCursorID);
 return (result); 
}

// retrieves the value from current row was fetched by cursor
string MySqlGetRowField(int pCursorID, int pField)
{
 string result;
 result = cMySqlGetRowField(pCursorID, pField);
 MySqlErrorNumber = cGetCursorErrorNumber(pCursorID);
 MySqlErrorDescription = cGetCursorErrorDescription(pCursorID);
 return (result);
}

int MySqlGetFieldAsInt(int pCursorID, int pField)
{
 return ((int)StringToInteger(MySqlGetRowField(pCursorID, pField)));
}

double MySqlGetFieldAsDouble(int pCursorID, int pField)
{
 return (StringToDouble(MySqlGetRowField(pCursorID, pField)));
}

datetime MySqlGetFieldAsDatetime(int pCursorID, int pField)
{
 string x = MySqlGetRowField(pCursorID, pField);
 StringReplace(x,"-",".");
 return (StringToTime(x));
}

string MySqlGetFieldAsString(int pCursorID, int pField)
{
 return (MySqlGetRowField(pCursorID, pField));
}

// just to clear error buffer before any function started its functionality
void ClearErrors()
{
 MySqlErrorNumber = 0;
 MySqlErrorDescription = "No errors.";
}



/********************************************************************
 * MySQL standard definitions                                       *
 ********************************************************************/
#define CLIENT_LONG_PASSWORD               1 /* new more secure passwords */
#define CLIENT_FOUND_ROWS                  2 /* Found instead of affected rows */
#define CLIENT_LONG_FLAG                   4 /* Get all column flags */
#define CLIENT_CONNECT_WITH_DB             8 /* One can specify db on connect */
#define CLIENT_NO_SCHEMA                  16 /* Don't allow database.table.column */
#define CLIENT_COMPRESS                   32 /* Can use compression protocol */
#define CLIENT_ODBC                       64 /* Odbc client */
#define CLIENT_LOCAL_FILES               128 /* Can use LOAD DATA LOCAL */
#define CLIENT_IGNORE_SPACE              256 /* Ignore spaces before '(' */
#define CLIENT_PROTOCOL_41               512 /* New 4.1 protocol */
#define CLIENT_INTERACTIVE              1024 /* This is an interactive client */
#define CLIENT_SSL                      2048 /* Switch to SSL after handshake */
#define CLIENT_IGNORE_SIGPIPE           4096 /* IGNORE sigpipes */
#define CLIENT_TRANSACTIONS             8192 /* Client knows about transactions */
#define CLIENT_RESERVED                16384 /* Old flag for 4.1 protocol  */
#define CLIENT_SECURE_CONNECTION       32768 /* New 4.1 authentication */
#define CLIENT_MULTI_STATEMENTS        65536 /* Enable/disable multi-stmt support */
#define CLIENT_MULTI_RESULTS          131072 /* Enable/disable multi-results */
#define CLIENT_PS_MULTI_RESULTS       262144 /* Multi-results in PS-protocol */



///    --------------- SELF DATABASE CONFIGURATION -------------------------  
//--------------------------BY : MONEY ROLLING------------------------------

///********************************DATABASE CONFIGURATION*******************************************************///
   
   //EDIT THESE PARAMETER TO SUITE THE NEED OF YOUR DATABASE
   
   string Host       = "IP";
   string User       = "USER";
   string Password   = "PASSWD";
   string Database   = "DB_NAME";
   int    Port       = 3306;
   string Socket     = "0";
   int    ClientFlag = 0;  
   string table      = "TABLE_NAME";  
   
   
void database_update_query (int type, string column, double value) //type 1 = buy, 2 = sell
{
   ///DATABASE PARAMETERS INITIALIZATION///
   
   int DB; // database identifier
   Print (MySqlVersion());

   //INI = TerminalPath()+"\\MQL4\\Scripts\\MyConnection.ini";
 
   // reading database credentials from INI file
   
   string symbol=StringSubstr(Symbol(),0,6);
   Print ("Host: ",Host, ", User: ", User, ", Database: ",Database);
   Print ("New Symbol "+symbol);
 
   // open database connection
   Print ("Connecting Update...");
 
   DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
   if (DB == -1) 
   { Print ("Connection failed! Error: "+MySqlErrorDescription); } 
   else 
   { Print ("Connected Update! DBID#",DB);}
   ///END DATABASE INITIALIZATION///
   int Cursor, Rows;
   string Query1, Query2, Query3;
   Query1="SELECT "+column+" FROM `"+table+"` WHERE SYMBOL='"+symbol+"'";
   Cursor = MySqlCursorOpen(DB, Query1);
   if (Cursor >= 0) // cursor opened
   {
    
    //Rows = MySqlGetFieldAsString(Cursor);
    
     Rows=MySqlCursorRows(Cursor);
     /// CREATING THE NEW RECORD ///
     if (Rows <= 0) // record not exist
     {
      //Then we create a row for it
          Query2="INSERT INTO `"+Database+"`.`"+table+"` (`SYMBOL`, `TYPE`,'"+column+"') VALUES ('"+symbol+"', '"+type+"', '"+column+"')";
          if (!MySqlExecute(DB, Query2))//if failed to insert new row for new symbol
          {
          Print("Failed to Insert New Row Of "+column+" For Symbol"+symbol);
          MySqlCursorClose(Cursor);
          MySqlDisconnect(DB);
          Print ("Disconnected. Script done!");
          }
          else
          {
          Print("Created New Row Of "+column+" For"+symbol+" Successfully");
          Print(Query2);
          MySqlCursorClose(Cursor);
          MySqlDisconnect(DB);
          Print ("Disconnected. Script done!");
          }
         
     }
     /// END CREATING NEW RECORD ///
    
     ///UPDATE BNEW RECORD///
    else//record did exist, so we just update it
    {
        Query3 ="UPDATE "+table+" SET TYPE="+type+", "+column+"="+value+" WHERE SYMBOL='"+symbol+"' ";
        if (!MySqlExecute(DB, Query3))
        {
        Print("Failed to Update "+column+"For Symbol"+symbol);
        Print(Query3);
        MySqlCursorClose(Cursor);
        MySqlDisconnect(DB);
        Print ("Disconnected. Script done!");
        }
        else
        {
        Print("Update Row of "+column+" For"+symbol+" Successfully");
        Print(Query3);
        MySqlCursorClose(Cursor);
        MySqlDisconnect(DB);
        Print ("Disconnected. Script done!");
        }
     
    }
    MySqlCursorClose(Cursor);
    MySqlDisconnect(DB);
    Print ("Disconnected. Script done!");
   }
  
  MySqlCursorClose(Cursor);
  MySqlDisconnect(DB);
  Print ("Disconnected. Script done!");
}


void database_update_multiple_query (int type, string column1, int value1, string column2, double value2,string column3, double value3,string column4, double value4,) //type 1 = buy, 2 = sell
{
   ///DATABASE PARAMETERS INITIALIZATION///
   
   int DB; // database identifier
   Print (MySqlVersion());

   //INI = TerminalPath()+"\\MQL4\\Scripts\\MyConnection.ini";
 
   // reading database credentials from INI file
   
   string symbol=StringSubstr(Symbol(),0,6);
   Print ("Host: ",Host, ", User: ", User, ", Database: ",Database);
   Print ("New Symbol "+symbol);
 
   // open database connection
   Print ("Connecting Update...");
 
   DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
   if (DB == -1) 
   { Print ("Connection failed! Error: "+MySqlErrorDescription); } 
   else 
   { Print ("Connected Update! DBID#",DB);}
   ///END DATABASE INITIALIZATION///
   int Cursor, Rows;
   string Query1, Query2, Query3;
   Query1="SELECT "+column1+" FROM `"+table+"` WHERE SYMBOL='"+symbol+"'";
   Cursor = MySqlCursorOpen(DB, Query1);
   if (Cursor >= 0) // cursor opened
   {
    
    //Rows = MySqlGetFieldAsString(Cursor);
    
     Rows=MySqlCursorRows(Cursor);
     /// CREATING THE NEW RECORD ///
     if (Rows <= 0) // record not exist
     {
      //Then we create a row for it
          Query2="INSERT INTO `"+Database+"`.`"+table+"` (`SYMBOL`, `TYPE`,`"+column1+"`,`"+column2+"`,`"+column3+"`,`"+column4+"`) VALUES ('"+symbol+"', '"+type+"', '"+value1+"', '"+value2+"', '"+value3+"', '"+value4+"')";
          if (!MySqlExecute(DB, Query2))//if failed to insert new row for new symbol
          {
          Print("Failed to Insert New Multiple Record For Symbol"+symbol);
          Print(Query2);
          MySqlCursorClose(Cursor);
          MySqlDisconnect(DB);
          Print ("Disconnected. Script done!");
          }
          else
          {
          Print("Created New Multilple Record For"+symbol+" Successfully");
          Print(Query2);
          MySqlCursorClose(Cursor);
          MySqlDisconnect(DB);
          Print ("Disconnected. Script done!");
          }
         
     }
     /// END CREATING NEW RECORD ///
    
     ///UPDATE BNEW RECORD///
    else//record did exist, so we just update it
    {
        Query3 ="UPDATE "+table+" SET TYPE="+type+", "+column1+"="+value1+", "+column2+"="+value2+", "+column3+"="+value3+", "+column4+"="+value4+" WHERE SYMBOL='"+symbol+"' ";
        if (!MySqlExecute(DB, Query3))
        {
        Print("Failed to Update Multiple Column For Symbol"+symbol);
        Print(Query3);
        MySqlCursorClose(Cursor);
        MySqlDisconnect(DB);
        Print ("Disconnected. Script done!");
        }
        else
        {
        Print("Update Multiple Column For"+symbol+" Successfully");
        Print(Query3);
        MySqlCursorClose(Cursor);
        MySqlDisconnect(DB);
        Print ("Disconnected. Script done!");
        }
     
    }
    MySqlCursorClose(Cursor);
    MySqlDisconnect(DB);
    Print ("Disconnected. Script done!");
   }
  
  MySqlCursorClose(Cursor);
  MySqlDisconnect(DB);
  Print ("Disconnected. Script done!");
}

void database_delete_entry ()
{
   ///DATABASE PARAMETERS INITIALIZATION///
   
   int DB; // database identifier
   Print (MySqlVersion());

   //INI = TerminalPath()+"\\MQL4\\Scripts\\MyConnection.ini";
 
   
   string symbol=StringSubstr(Symbol(),0,6);
   Print ("Host: ",Host, ", User: ", User, ", Database: ",Database);
   Print ("New Symbol "+symbol);
 
   // open database connection
   Print ("Connecting Update...");
 
   DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
   if (DB == -1) 
   { Print ("Connection failed! Error: "+MySqlErrorDescription); } 
   else 
   { Print ("Connected Update! DBID#",DB);}
   ///END DATABASE INITIALIZATION///
   int Cursor, Rows;
   string Query1, Query2, Query3;
   
   
   Query1="SELECT * FROM `"+table+"` WHERE SYMBOL='"+symbol+"'";  //as if no record inside, we do nothing
   Cursor = MySqlCursorOpen(DB, Query1);
   
   if (Cursor >= 0) //CURSOR OPENED
   { 
         Rows=MySqlCursorRows(Cursor);
         if (Rows <= 0)//record not exist
         {
           Print ("Do Nothing As No Record Found For Symbol "+symbol);
           MySqlCursorClose(Cursor);
           MySqlDisconnect(DB);
           Print ("Disconnected. Script done!");
         
         }
         
         else
         {
   
               Query2 ="DELETE FROM `"+table+"` WHERE SYMBOL='"+symbol+"'"; 
               if (!MySqlExecute(DB, Query2))//if failed to insert new row for new symbol
               {
                      Print("Failed to Delete Record For "+symbol);
                      Print(Query2);
                      MySqlCursorClose(Cursor);
                      MySqlDisconnect(DB);
                      Print ("Disconnected. Script done!");
               }
               else
               {
                      Print("Delete Old Record For "+symbol+" Is Success");
                      Print(Query2);
                      MySqlCursorClose(Cursor);
                      MySqlDisconnect(DB);
                      Print ("Disconnected. Script done!");
               }
        }
        
      MySqlCursorClose(Cursor);
      MySqlDisconnect(DB);
      Print ("Disconnected. Script done!");
    }
}

double database_fetch_double (string column)
{
   ///DATABASE PARAMETERS INITIALIZATION///
   
   int DB; // database identifier
   Print (MySqlVersion());

     
   string symbol=StringSubstr(Symbol(),0,6);
   Print ("Host: ",Host, ", User: ", User, ", Database: ",Database);
   Print ("New Symbol "+symbol);
 
   // open database connection
   Print ("Connecting Update...");
 
   DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
   if (DB == -1) 
   { Print ("Connection failed! Error: "+MySqlErrorDescription); } 
   else 
   { Print ("Connected Update! DBID#",DB);}
   ///END DATABASE INITIALIZATION///
   int Cursor, Rows;
   string Query1, Query2, Query3;
   double value;
   
   Query1="SELECT "+column+" FROM `"+table+"` WHERE SYMBOL='"+symbol+"'";
   Cursor = MySqlCursorOpen(DB, Query1);
   
   if (Cursor >= 0) //CURSOR OPENED
   { 
         Rows=MySqlCursorRows(Cursor);
         if (Rows <= 0)//record not exist
         {
           Print ("No Record Found For"+column+" of Symbol "+symbol);
           MySqlCursorClose(Cursor);
           MySqlDisconnect(DB);
           Print ("Disconnected. Script done!");
           return(0);
         }
   
         else//meaning record exist
         {
           if (MySqlCursorFetchRow(Cursor))
           { 
             value = MySqlGetFieldAsDouble(Cursor, 0);
             MySqlCursorClose(Cursor);
             MySqlDisconnect(DB);
             Print ("Data of "+column+" for Symbol "+symbol+" is found");
             Print ("Disconnected. Script done!");
              
             return(value);//NO TRADE
           }
           
           else
           {
              MySqlCursorClose(Cursor);
              MySqlDisconnect(DB);
              Print ("Cannot Find Data of "+column+" for Symbol "+symbol);
              Print ("Disconnected. Script done!");
              
              return(0);//NO TRADE
           }
     
          }
   
              MySqlCursorClose(Cursor);
              MySqlDisconnect(DB);
              Print ("Disconnected. Script done!");
              
              return(0);//NO TRADE
    }
   MySqlCursorClose(Cursor);
   MySqlDisconnect(DB);
   Print ("Disconnected. Script done!");
   return(0);//NO TRADE
}

int database_fetch_integer (string column)
{
   ///DATABASE PARAMETERS INITIALIZATION///
   
   int DB; // database identifier
   Print (MySqlVersion());

  
   string symbol=StringSubstr(Symbol(),0,6);
   Print ("Host: ",Host, ", User: ", User, ", Database: ",Database);
   Print ("New Symbol "+symbol);
 
   // open database connection
   Print ("Connecting Update...");
 
   DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
   if (DB == -1) 
   { Print ("Connection failed! Error: "+MySqlErrorDescription); } 
   else 
   { Print ("Connected Update! DBID#",DB);}
   ///END DATABASE INITIALIZATION///
   int Cursor, Rows;
   string Query1, Query2, Query3;
   double value;
   
   Query1="SELECT "+column+" FROM `"+table+"` WHERE SYMBOL='"+symbol+"'";
   Cursor = MySqlCursorOpen(DB, Query1);
   
   if (Cursor >= 0) //CURSOR OPENED
   { 
         Rows=MySqlCursorRows(Cursor);
         if (Rows <= 0)//record not exist
         {
           Print ("No Record Found For "+column+" of Symbol"+symbol);
           MySqlCursorClose(Cursor);
           MySqlDisconnect(DB);
           Print ("Disconnected. Script done!");
           return(0);
         }
   
         else//meaning record exist
         {
           if (MySqlCursorFetchRow(Cursor))
           { 
             value = MySqlGetFieldAsInt(Cursor, 0);
             MySqlCursorClose(Cursor);
             MySqlDisconnect(DB);
             Print ("Data of "+column+" for Symbol "+symbol+" is found");
             Print ("Disconnected. Script done!");
              
             return(value);//NO TRADE
           }
           
           else
           {
              MySqlCursorClose(Cursor);
              MySqlDisconnect(DB);
              Print ("Cannot Find Data of "+column+" for Symbol "+symbol);
              Print ("Disconnected. Script done!");
              
              return(0);//NO TRADE
           }
     
          }
   
              MySqlCursorClose(Cursor);
              MySqlDisconnect(DB);
              Print ("Disconnected. Script done!");
              
              return(0);//NO TRADE
    }
   MySqlCursorClose(Cursor);
   MySqlDisconnect(DB);
   Print ("Disconnected. Script done!");
   return(0);//NO TRADE
}
///************************************END DATABASE CONFIGURATION**********************************************///
