`timescale 1ns / 1ps


module tb_Timeout ();

parameter HALF_CLK_PERIOD = 50; // 10MHz

reg sys_clk;
reg bit_clk;
reg porb;
reg por_pulseb;
reg read_id_rev;
reg read_reg;
reg read_eep;
reg valid;
reg p2s_enb;
reg eep_cycleb;
reg timeoutb;
reg pulldwn_trib;

Timeout UUT (
	.sys_clk(sys_clk),
	.bit_clk(bit_clk),
	.porb(porb),
	.por_pulseb(por_pulseb),
	.read_id_rev(read_id_rev),
	.read_reg(read_reg),
	.read_eep(read_eep),
	.valid(valid),
	.p2s_enb(p2s_enb),
	.eep_cycleb(eep_cycleb),
	.timeoutb(timeoutb),
	.pulldwn_trib(pulldwn_trib),

);

always #(HALF_CLK_PERIOD) sys_clk = ~sys_clk;


initial begin
	sys_clk = ;
	bit_clk = ;
	porb = ;
	por_pulseb = ;
	read_id_rev = ;
	read_reg = ;
	read_eep = ;
	valid = ;
	p2s_enb = ;
	eep_cycleb = ;
	timeoutb = ;
	pulldwn_trib = ;

end

endmodule
