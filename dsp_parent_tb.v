module dsp_parent_tb();
    reg [17:0] A, B, D;
    reg [47:0] C;
    reg clk;
    reg RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCARRYIN, RSTOPMODE;
    reg CARRYIN;
    reg [7:0] OPMODE_in;
    reg [17:0] BCIN;
    reg [47:0] PCIN;
    reg CEA, CEB, CEC, CED, CEM, CEP, CECARRYIN, CEOPMODE;
    wire [35:0] M;
    wire [47:0] P;
    wire [47:0] PCOUT;
    wire [17:0] BCOUT;
    wire CARRYOUT;
    wire CARRYOUTF;
dsp_parent dut (.A(A), .B(B), .D(D), .C(C),
    .clk(clk),
    .RSTA(RSTA), .RSTB(RSTB), .RSTC(RSTC), .RSTD(RSTD),
    .RSTM(RSTM), .RSTP(RSTP),
    .RSTCARRYIN(RSTCARRYIN), .RSTOPMODE(RSTOPMODE),
    .CARRYIN(CARRYIN),
    .OPMODE_in(OPMODE_in),
    .BCIN(BCIN),
    .PCIN(PCIN),
    .CEA(CEA), .CEB(CEB), .CEC(CEC), .CED(CED),
    .CEM(CEM), .CEP(CEP),
    .CECARRYIN(CECARRYIN), .CEOPMODE(CEOPMODE),
    .M(M), .P(P), .PCOUT(PCOUT),
    .BCOUT(BCOUT), .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF));

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end   

initial begin
//Path 1 test
A = 0; B=0; C=0; D=0; CARRYIN = 0; OPMODE_in = 0; BCIN = 0; PCIN = 0;
{RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCARRYIN, RSTOPMODE} = 0;
{CEA, CEB, CEC, CED, CEM, CEP, CECARRYIN, CEOPMODE} = 8'b11111111;
@(posedge clk);
A = 20; B=10; C=350; D=25; OPMODE_in = 8'b11011101;
BCIN = $random;
PCIN = $random;
CARRYIN = $random;
repeat(5) @(negedge clk);
if(BCOUT !== 'hf || M ! == 'h12c || P !== 'h32 || PCOUT !== 'h32 || CARRYOUT !== 0 || CARRYOUTF !== 0) $display("Error detected");
else $display("Test 1 succeeded");

//Path 2 test
A = 20; B = 10; C = 350; D = 25; OPMODE_in = 8'b00010000;
BCIN = $random;
PCIN = $random;
CARRYIN = $random;
repeat(3) @(negedge clk);
if(BCOUT !== 'h23 || M !== 'h2bc || P !== 0 || PCOUT !== 0 || CARRYOUT !== 0 || CARRYOUTF !== 0) $display("Error detected");
else $display("Test 2 succeeded");

//Path 3 test
A = 20; B = 10; C = 350; D = 25; OPMODE_in = 8'b00001010;
BCIN = $random;
PCIN = $random;
CARRYIN = $random;
repeat(3) @(negedge clk);
if(BCOUT !== 'ha || M !== 'hc8 || P !== 0 || PCOUT !== 0 || CARRYOUT !== 0 || CARRYOUTF !== 0) $display("Error detected");
else $display("Test 3 succeeded");

//path 4 test
A = 5; B = 6; C = 350; D = 25; PCIN = 3000; OPMODE_in = 8'b10100111;
BCIN = $random;
CARRYIN = $random;
repeat(3) @(negedge clk);
if(BCOUT !== 'h6 || M !== 'h1e || P !== 'hfe6fffec0bb1 || PCOUT !== 'hfe6fffec0bb1 || CARRYOUT !== 1 || CARRYOUTF !== 1) $display("Error detected");
else $display("Test 4 succeeded");

$stop;

end
initial begin
$monitor("T=%0t | OPMODE=%b | A=%0d B=%0d D=%0d C=%0d CIN=%b || X=%0d Z=%0d || M=%0d post=%0d P=%0d COUT=%b",
         $time,
         OPMODE_in,
         A, B, D, C, CARRYIN,
         dut.x_out, dut.z_out,
         M, dut.post_add_sub_out, P, CARRYOUT);
end

endmodule