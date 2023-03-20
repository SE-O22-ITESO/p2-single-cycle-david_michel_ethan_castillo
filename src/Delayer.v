// Coder:           Cuauhtemoc Aguilera
// Date:            09/09/22
// File:			     Delayer.v
// Module name:	  Delayer
// Project Name:	  risc_v_top
// Description:	  Delayer

module Delayer
 # (parameter YY = 10 ) // Se requieren 27 bits para representar 100,000,0000 de cuentas
   (
    input clk,
    input rst,
    input enable,
    output iguales
    );
localparam WIDTH = $clog2(YY);  
reg [WIDTH-1:0]cuenta ;  

// Comparador
assign iguales = ( YY + 1 ==(cuenta) )? 1'b1 : 1'b0;

// Contador
always @(posedge rst, posedge clk)
    begin
        if (rst)
            cuenta <= {WIDTH{1'b0}};
        else 
            if (enable)
                if (iguales)
                         cuenta <= {WIDTH{1'b0}};
                else 
                        cuenta <= cuenta + 1'b1;
             else
                cuenta <= cuenta;
     end
endmodule