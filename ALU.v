
module ALU (clk_i,data1_i, data2_i,type_op_ctrl_i ,ALUCtrl_i, data_o,Zero_o);


input clk_i;
input [31:0] data1_i, data2_i;
input [2:0] ALUCtrl_i;
input type_op_ctrl_i;
output reg[31:0] data_o;
output reg Zero_o;

parameter SUM = 3'b001;
parameter SUB = 3'b010;
parameter MUL = 3'b011;
parameter DIV = 3'b100;
parameter N=47;
parameter Z=0;



reg [7:0] exp_a,exp_b;
reg [23:0] mant_a,mant_b;
reg [23:0] all_manta,all_mantb;


reg [47:0] prod_div; //register to store the prod or div result based on op_code
reg [47:0] dividend;


integer index,i;
reg [47:0] norm_prod_div;
reg [23:0] norm_mant;
reg [23:0] rounded_result;
//rounding 
reg g,r;
reg [21:0] s;
reg [7:0] exp_result;
reg [23:0] add_sum;

reg flag;



task fpu_op(reg [2:0] op);
begin
$display("You are now doing FPU operation");
$display("operation being oerformed is :%3b",op);
exp_a=data1_i[30:23];
exp_b=data2_i[30:23];
mant_a={1,data1_i[22:0]};
mant_b={1,data2_i[22:0]};
all_manta=(exp_b>exp_a)?(mant_a>>(exp_b-exp_a)):mant_a;
all_mantb=(exp_a>exp_b)?(mant_b>>(exp_a-exp_b)):mant_b;
exp_result=(exp_a>exp_b)?exp_a:exp_b;
case(op)
SUM: begin
add_sum=all_manta+all_mantb;
$display("mant_a is %24b",all_manta);
$display("Sum is : %24b",add_sum);
data_o={data1_i[0],exp_result,add_sum[22:0]};
$display("actual output is %32b",data_o);
end
SUB: begin
add_sum=(all_manta>all_mantb)?all_manta-all_mantb:all_mantb-all_manta;
$display("diff is : %24b",add_sum);
data_o={data1_i[0],exp_result,add_sum[22:0]};
$display("actual output is :%32b",data_o);
end
MUL: begin
prod_div=all_manta*all_mantb;
$display("product is %48b",prod_div);
for(i=N;i>Z;i=i-1)
begin
if(!flag && prod_div[i]==1)
begin
index=i;
flag=1;
end
end
$display("index is :%0d",index);
norm_prod_div=prod_div<<(47-index);
$display("normalized product is :%48b",norm_prod_div);
norm_mant=norm_prod_div[47:24];
//rounding
g=norm_prod_div[23];
r=norm_prod_div[22];
s=norm_prod_div[21:0];
if(g==1 && (r==1 || |s==1 || norm_prod_div[0]==1))
begin
rounded_result=norm_mant+1;
end
else
begin
rounded_result=norm_mant;
end
exp_result=(exp_a>exp_b)?exp_a-exp_b+127 : exp_b-exp_a+127;
data_o={data1_i[0],exp_result,rounded_result[22:0]};
$display("Prod, actual output is %32b",data_o);


end
DIV: begin
dividend=data1_i << 24;
prod_div=dividend/data1_i;
//normalization
for(i=N;i>Z;i=i-1)
begin
if(!flag && prod_div[i]==1)
begin
index=i;
flag=1;
end
end
$display("index is %0d",index);
norm_prod_div=prod_div<<(47-index);
//seperate mantissa
norm_mant=norm_prod_div[47:24];
//rounding
g=norm_prod_div[23];
r=norm_prod_div[22];
s=norm_prod_div[21:0];
if(g==1 && (r==1 || |s==1))
begin
rounded_result=norm_mant+1;
end
else
begin
rounded_result=norm_mant;
end
exp_result=(exp_a>exp_b)?exp_a-exp_b+127 : exp_b-exp_a+127;
data_o={data1_i[0],exp_result,rounded_result[22:0]};
$display("actual output is %32b",data_o);
//index=0;
end



endcase

end
endtask



task norm_op(reg [2:0] op);
begin
$display("you are now performing normal operation");
case(op)
SUM: begin
data_o = data1_i + data2_i;
end
SUB: begin
data_o=data1_i-data2_i;
end
MUL: begin
data_o=data1_i * data2_i;
end
DIV: begin
data_o=data1_i/data2_i;
end
endcase
end
endtask


/* implement here */
always@(posedge clk_i)begin
Zero_o   = (data1_i - data2_i)?0:1;
flag=0;
$display("Alu has been given a task !!!");
$display("type of op is : %b",type_op_ctrl_i);
case(type_op_ctrl_i)
0: fpu_op(ALUCtrl_i);
1: norm_op(ALUCtrl_i);

endcase

end

endmodule
        

    
    
            
        
        
        
        
        
        

