module assignment(clk,res,set,test,p0,p1,p2,p3,lt0,lt1,lt2,lt3,unlock);

input clk,res,set,test;
input [2:0]p0,p1,p2,p3;

output reg [6:0]lt0,lt1,lt2,lt3;
output reg unlock;

reg [2:0]state,next_state;

reg [1:0]attempt_cnt=2'b00;

reg [31:0] cycle_count;

reg [7:0] lockout_count;

reg [11:0]password;
wire [11:0]entered;

assign entered ={p0,p1,p2,p3};

//FSM states
parameter IDLE=3'b000;
parameter SETP=3'b001;
parameter CHECK=3'b010;
parameter OPEN=3'b011;
parameter FAIL=3'b100;
parameter LOCKOUT=3'b101;

parameter integer LOCKOUT_CYCLES = 20;

//STATE REGISTER
always @(posedge clk or posedge res)
begin
if(res)
begin
   state<=IDLE;
   attempt_cnt<=2'd0;
   lockout_count<=8'd0;
   cycle_count <= 32'd0;
end
else if(state==FAIL)
begin
   state<=next_state;
   attempt_cnt<=attempt_cnt+1;
   cycle_count <= cycle_count + 1'b1;
end
else if(state==OPEN)
begin
   state<=next_state;
   attempt_cnt<=2'd0;
   cycle_count <= cycle_count + 1'b1;
end
else if (state==LOCKOUT)
begin
   state<=next_state;
   attempt_cnt<=2'd0;
   lockout_count<=lockout_count+1'b1;
   cycle_count <= cycle_count + 1'b1;
end
else
begin
   state<=next_state;
   lockout_count<=8'd0;
   cycle_count <= cycle_count + 1'b1;
end
end

//PASSWORD STORAGE
always @(posedge clk)
begin
if(state==SETP)
   password<=entered;
end

//NEXT STATE LOGIC
always @(*)
begin
case(state)

IDLE:
begin
if(set && !test)
   next_state=SETP;
else if(test)
   next_state=CHECK;
else
   next_state=IDLE;
end

SETP:
next_state=IDLE;

CHECK:
begin
if(entered==password)
   next_state=OPEN;
else
   next_state=FAIL;
end

OPEN:
next_state=IDLE;

FAIL:
begin
    if(attempt_cnt==2)
        next_state = LOCKOUT;
    else
        next_state = IDLE;
end

LOCKOUT:
begin
    if(lockout_count >= LOCKOUT_CYCLES-1)
        next_state = IDLE;
    else
        next_state = LOCKOUT;
end

default:
next_state=IDLE;

endcase
end

//OUTPUT LOGIC
always @(*)
begin
unlock = 0;
lt0 = 7'b1111111;
lt1 = 7'b1111111;
lt2 = 7'b1111111;
lt3 = 7'b1111111;

case(state)

SETP:
begin
    lt3 = 7'b0010010; // S
    lt2 = 7'b0000110; // E
    lt1 = 7'b0000111; // T
    lt0 = 7'b0001100; // P
end

OPEN:
begin
    unlock = 1;
    lt3 = 7'b1000000; // O
    lt2 = 7'b0001100; // P
    lt1 = 7'b0000110; // E
    lt0 = 7'b0101011; // N
end

FAIL:
begin
    lt3 = 7'b0001110; // F
    lt2 = 7'b0001000; // A
    lt1 = 7'b1111001; // I
    lt0 = 7'b1000111; // L
end

LOCKOUT:
begin
    lt3 = 7'b1000111; // L
    lt2 = 7'b1000000; // O
    lt1 = 7'b1000110; // C
    lt0 = 7'b0000111; // T
end

endcase
end

endmodule

