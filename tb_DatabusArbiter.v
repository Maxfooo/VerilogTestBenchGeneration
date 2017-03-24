`timescale 1ns / 1ps


module tb_DatabusArbiter ();

parameter HALF_CLK_PERIOD = 50; // 10MHz

reg [CACHE_WIDTH-1:0] sys_clk;
reg [CACHE_WIDTH-1:0] data_in;
reg [CACHE_WIDTH-1:0] valid;
reg [CACHE_WIDTH-1:0] porb;
reg [CACHE_WIDTH-1:0] por_pulseb;
reg [CACHE_WIDTH-1:0] timeoutb;
reg [CACHE_WIDTH-1:0] eep_loadb;
reg [CACHE_WIDTH-1:0] en_rail_rail;
reg [CACHE_WIDTH-1:0] eeprom_cache;
wire [CACHE_WIDTH-1:0] data_out;
wire [CACHE_WIDTH-1:0] read_eep;
wire pgm_eep;
wire cache_out;
wire p2s_en;
wire reg0_ldb;
wire reg1_ldb;
wire reg2_ldb;
wire reg3_ldb;
wire eep_cycleb;
wire eep_clrb;

DatabusArbiter UUT (
	.sys_clk(sys_clk),
	.data_in(data_in),
	.valid(valid),
	.porb(porb),
	.por_pulseb(por_pulseb),
	.timeoutb(timeoutb),
	.eep_loadb(eep_loadb),
	.en_rail_rail(en_rail_rail),
	.eeprom_cache(eeprom_cache),
	.data_out(data_out),
	.read_eep(read_eep),
	.pgm_eep(pgm_eep),
	.cache_out(cache_out),
	.p2s_en(p2s_en),
	.reg0_ldb(reg0_ldb),
	.reg1_ldb(reg1_ldb),
	.reg2_ldb(reg2_ldb),
	.reg3_ldb(reg3_ldb),
	.eep_cycleb(eep_cycleb),
	.eep_clrb(eep_clrb)

);

always #(HALF_CLK_PERIOD) sys_clk = ~sys_clk;


initial begin
	sys_clk = ;
	data_in = ;
	valid = ;
	porb = ;
	por_pulseb = ;
	timeoutb = ;
	eep_loadb = ;
	en_rail_rail = ;
	eeprom_cache = ;

end

endmodule
