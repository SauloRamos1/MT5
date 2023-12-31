//+------------------------------------------------------------------+
//|                                                      BB_MACD.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| INCLUDES
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
//+------------------------------------------------------------------+
//| INPUT
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input double Profit = 100;//Ganho Máximo(R$)
input double Loss = 110;//Perda Máxima(R$) ou 100

input double gatilhoBE = 50;//Gatilho BreakEven
input double gatilhoMove = 30;
bool beAtivo;

input double gatilhoTS = 30; //Gatilho TraillingStop
input double stepTS = 5; // Step TraillingStop ou 150



MqlDateTime                   horaAtual;

input int                     horaInicioAbertura1 = 10;//Hora de Inicio 1
input int                     minutoInicioAbertura1 = 0;//Minuto de Inicio 1
input int                     horaFimAbertura1 = 17;//Hora de Encerramento 1
input int                     minutoFimAbertura1 = 0;//Minuto de Encerramento 1

input int                     horaInicioAbertura2 = 15;//Hora de Inicio 2
input int                     minutoInicioAbertura2 = 5;//Minuto de Inicio 2
input int                     horaFimAbertura2 = 16;//Hora de Encerramento 2
input int                     minutoFimAbertura2 = 00;//Minuto de Encerramento 2

input int                     horaInicioAbertura3 = 14;//Hora de Inicio 3
input int                     minutoInicioAbertura3 = 00;//Minuto de Inicio 3
input int                     horaFimAbertura3 = 16;//Hora de Encerramento 3
input int                     minutoFimAbertura3 = 00;//Minuto de Encerramento 3


input int                     horaInicioFechamento = 16;//Hora de Inicio de Fechamento de Posições
input int                     minutoInicioFechamento = 00;//Minuto de Inicio de Fechamento de Posições+


//input int contratos = 1;
//input double Profit = 100;//Ganho Máximo(R$)
//input double Loss = 20;//Perda Máxima(R$)

double saldo;
int contratos = 1;
int ganho_dia = 0;
//input double gatilhoTS = 50; //Gatilho TraillingStop
//input double stepTS = 50; // Step TraillingStop
//+------------------------------------------------------------------+
//| GLOBAIS
//+------------------------------------------------------------------+

//---
double lasthaAber;
double lasthaFech;
double openBuffer[];
double closeBuffer[];
double highBuffer[];
double lowBuffer[];

CTrade trade;

double SL,TP;
datetime  TimeCurrent();


double media[];

int BB_Handle = INVALID_HANDLE;

double BBUp[],BBLow[],BBMiddle[];

int MACD_Handle = INVALID_HANDLE;

double MACDLine[], MACDsignal[], MACDHistogram[];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArraySetAsSeries(closeBuffer,true);
   ArraySetAsSeries(openBuffer,true);
   ArraySetAsSeries(lowBuffer,true);
   ArraySetAsSeries(highBuffer,true);
   
   ArraySetAsSeries(BBUp,true);
   ArraySetAsSeries(BBLow,true);
   ArraySetAsSeries(BBMiddle,true);
      
   ArraySetAsSeries(MACDLine,true);
   ArraySetAsSeries(MACDsignal,true);
   ArraySetAsSeries(MACDHistogram,true);
   
   
   ArraySetAsSeries(media,true);
   BB_Handle = iBands(_Symbol, _Period,20,0,2,PRICE_CLOSE);
   MACD_Handle = iCustom(_Symbol,_Period,"macd",12,26,9,PRICE_CLOSE,true);
     
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//   if (!HoraNegociacao()) {
//      return;
//   }

   CopyBuffer (BB_Handle,0,0,10, BBMiddle); 
   CopyBuffer (BB_Handle,1,0,10, BBUp); 
   CopyBuffer (BB_Handle,2,0,10, BBLow); 
   
   CopyClose(_Symbol, _Period,0, 10, closeBuffer);
   CopyOpen(_Symbol, _Period,0, 10, openBuffer);
   CopyLow(_Symbol, _Period,0, 10, lowBuffer);
   CopyHigh(_Symbol, _Period,0, 10, highBuffer);
   
   CopyBuffer (MACD_Handle,0,0,10, MACDsignal); 
   CopyBuffer (MACD_Handle,1,0,10, MACDLine); 
   CopyBuffer (MACD_Handle,2,0,10, MACDHistogram); 
   
   bool sinalCompra = false;
   bool sinalVenda = false;
   
   

//---- Verificar se estou comprado ----//
   bool comprado = false;
   bool vendido = false;

   if(PositionSelect(_Symbol))
     {
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         comprado = true;
        }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         vendido = true;
        }
     }
   bool posAberta = false;
   if(comprado || vendido)
     {
      posAberta = true;
     }
     
     if (posAberta) {
        // TrailingGain (BBMiddle[0]);
     }
//STOP MOVEL

   if(!posAberta)
     {
      beAtivo = false;
     }

   if(posAberta && !beAtivo)
     {
     // BreakEven(closeBuffer[0]);
     }

   if(posAberta && beAtivo)
     {
    //  TrailingStop(closeBuffer[0]);
     }
     
  

//Print (int  OrdersTotal(););
   if(isNewBar() && HoraNegociacao1())
     {

   
   if(closeBuffer[0] <= BBLow[0])
    {
        sinalCompra = true;
        
} else if (closeBuffer[0] >= BBUp[0]) {
      sinalVenda =true;
     }
   

    //if (MACDsignal[0] > MACDLine [0] && (MACDsignal[1] < MACDLine [1] || MACDsignal[2] < MACDLine [2]) ){
    //  sinalCompra = true;
    //} else if (MACDsignal[0] < MACDLine [0] && (MACDsignal[1] > MACDLine [1] || MACDsignal[2] > MACDLine [2]) ){
    //sinalVenda = true;
    //}
     saldo = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

     if (saldo > 400){
    //    contratos = saldo / 400;
     }
         
      // if (contratos > 5000){
      //    contratos = 5000;
      // }
      //--- Logica de Roteamento---//

      if(!comprado && !vendido)   //Zerado!
        {

         if(sinalCompra)
           {
            //SL = SymbolInfoDouble(_Symbol,SYMBOL_ASK) - Loss;
            //TP = SymbolInfoDouble(_Symbol,SYMBOL_ASK) + Profit;
            
            TP = BBMiddle[0];
            
            trade.Buy(contratos,_Symbol,0,0,0,"Compra a Mercado");
            
         //   TesterWithdrawal(0.5);

           }
         if(sinalVenda)
           {
            SL = SymbolInfoDouble(_Symbol,SYMBOL_BID) + Loss;
            TP = SymbolInfoDouble(_Symbol,SYMBOL_BID) - Profit;
            //trade.Sell(contratos,_Symbol,0,SL,TP,"Venda a Mercado");
         //   TesterWithdrawal(0.5);

            ////---
           }

        }
      else
        {
         if(comprado)
           {
            if(sinalVenda)
              {
               SL = SymbolInfoDouble(_Symbol,SYMBOL_BID) + Loss;
               TP = SymbolInfoDouble(_Symbol,SYMBOL_BID) - Profit;
               trade.Sell(contratos,_Symbol,0,0,0,"Virada de Mao (Compra -> Venda");
           //    TesterWithdrawal(0.5);
              }

           }
         else
            if(vendido)
              {

               if(sinalCompra)
                 {
                  //DEVE ZERAR POSICAO E COMPRAR MAIS 1 e nao comprar2
                  // PRoblema da ordem aberta
                  SL = SymbolInfoDouble(_Symbol,SYMBOL_ASK) - Loss;
                  TP = SymbolInfoDouble(_Symbol,SYMBOL_ASK) + Profit;
                //  trade.Buy(contratos*2,_Symbol,0,SL,0,"Virada de Mao (Venda -> Compra");
              //    TesterWithdrawal(0.5);
                 }

              }
        }
     }

  }
//+------------------------------------------------------------------+
bool isNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingStop(double preco)
  {
   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      string symbol = PositionGetSymbol(i);

      if(symbol == _Symbol)
        {
         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
         double StopLossCorrente = PositionGetDouble(POSITION_SL);
         double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            if(preco >= (StopLossCorrente + gatilhoTS))
              {

               int novoSL = StopLossCorrente + stepTS;
               if(trade.PositionModify(PositionTicket, novoSL, TakeProfitCorrente))
                 {
                  //  Print("TrailingStop - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                 }
               else
                 {
                  //  Print("TrailingStop - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                 }
              }
           }
         else
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               if(preco <= (StopLossCorrente - gatilhoTS))
                 {
                  int novoSL = StopLossCorrente - stepTS;
                  if(trade.PositionModify(PositionTicket, novoSL, TakeProfitCorrente))
                    {
                     // Print("TrailingStop - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                    }
                  else
                    {
                     //  Print("TrailingStop - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                    }
                 }
              }
        }
     }
  }
//---

//+------------------------------------------------------------------+
void TrailingGain(double TP)
  {
   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      string symbol = PositionGetSymbol(i);

      if(symbol == _Symbol)
        {
         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
         double StopLossCorrente = PositionGetDouble(POSITION_SL);
         double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            if(TP != TakeProfitCorrente)
              {

               int novoSL = StopLossCorrente + stepTS;
               if(trade.PositionModify(PositionTicket, 0, TP))
                 {
                  //  Print("TrailingStop - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                 }
               else
                 {
                  //  Print("TrailingStop - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                 }
              }
           }
         else
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               if(TP <= (StopLossCorrente - gatilhoTS))
                 {
                  int novoSL = StopLossCorrente - stepTS;
                  if(trade.PositionModify(PositionTicket, novoSL, TakeProfitCorrente))
                    {
                     // Print("TrailingStop - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                    }
                  else
                    {
                     //  Print("TrailingStop - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                    }
                 }
              }
        }
     }
  }
//---

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BreakEven(double preco)
  {
   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      string symbol = PositionGetSymbol(i);
      if(symbol == _Symbol)
        {
         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
         double PrecoEntrada = PositionGetDouble(POSITION_PRICE_OPEN);
         double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            if(preco >= (PrecoEntrada + gatilhoBE))
              {
               if(trade.PositionModify(PositionTicket, PrecoEntrada + gatilhoMove, TakeProfitCorrente))
                 {
                  //   Print("BreakEven - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                  beAtivo = true;
                 }
               else
                 {
                  //  Print("BreakEven - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                 }
              }
           }
         else
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               if(preco <= (PrecoEntrada - gatilhoBE ))
                 {
                  if(trade.PositionModify(PositionTicket, PrecoEntrada  - gatilhoMove, TakeProfitCorrente))
                    {
                     //  Print("BreakEven - sem falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                     beAtivo = true;
                    }
                  else
                    {
                     //  Print("BreakEven - com falha. ResultRetcode: ", trade.ResultRetcode(), ", RetcodeDescription: ", trade.ResultRetcodeDescription());
                    }
                 }
              }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HoraNegociacao1()
  {
   TimeCurrent(horaAtual);
   if(horaAtual.hour >= horaInicioAbertura1 && horaAtual.hour <= horaFimAbertura1)
     {
      if(horaAtual.hour == horaInicioAbertura1)
        {
         if(horaAtual.min >= minutoInicioAbertura1)
           {
            return true;
           }
         else
           {
            return false;
           }
        }
      if(horaAtual.hour == horaFimAbertura1)
        {
         if(horaAtual.min <= minutoFimAbertura1)
           {
            return true;
           }
         else
           {
            return false;
           }
        }
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HoraNegociacao2()
  {
   TimeCurrent(horaAtual);
   if(horaAtual.hour >= horaInicioAbertura2 && horaAtual.hour <= horaFimAbertura2)
     {
      if(horaAtual.hour == horaInicioAbertura2)
        {
         if(horaAtual.min >= minutoInicioAbertura2)
           {
            return true;
           }
         else
           {
            return false;
           }
        }
      if(horaAtual.hour == horaFimAbertura2)
        {
         if(horaAtual.min <= minutoFimAbertura2)
           {
            return true;
           }
         else
           {
            return false;
           }
        }
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HoraNegociacao3()
  {
   TimeCurrent(horaAtual);
   if(horaAtual.hour >= horaInicioAbertura3 && horaAtual.hour <= horaFimAbertura3)
     {
      if(horaAtual.hour == horaInicioAbertura3)
        {
         if(horaAtual.min >= minutoInicioAbertura3)
           {
            return true;
           }
         else
           {
            return false;
           }
        }
      if(horaAtual.hour == horaFimAbertura3)
        {
         if(horaAtual.min <= minutoFimAbertura3)
           {
            return true;
           }
         else
           {
            return false;
           }
        }
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HoraFechamento()
  {
   TimeCurrent(horaAtual);
   if(horaAtual.hour >= horaInicioFechamento)
     {
      if(horaAtual.hour == horaInicioFechamento)
        {
         if(horaAtual.min >= minutoInicioFechamento)
           {
            return true;
           }
         else
           {
            return false;
           }
        }
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
