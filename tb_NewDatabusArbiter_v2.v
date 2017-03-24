
`timescale 1ns / 1ps

module tb_NewDatabusArbiter_v2 ();

parameter MESSAGE_WIDTH         = 30;
parameter DATA_WIDTH                = 16;
parameter MODE_WIDTH                = 4;
parameter DATA_SEL_WIDTH        = 3;
parameter CHIP_ID_REV           = 16'hF001;
parameter CACHE_WIDTH           = 64;
parameter HALF_CLK_PERIOD = 50; // 10MHz


reg sys_clk;
reg [MESSAGE_WIDTH-1:0] data_in;
reg valid;
reg porb;
reg por_pulseb;
reg timeoutb;
reg eep_loadb;
reg en_rail_rail;
reg [CACHE_WIDTH-1:0] eeprom_cache;
wire [DATA_WIDTH-1:0] data_out;
wire read_eep;
wire pgm_eep;
wire [CACHE_WIDTH-1:0] cache_out;
wire p2s_en;
wire reg0_ldb;
wire reg1_ldb;
wire reg2_ldb;
wire reg3_ldb;
wire eep_cycleb;
wire eep_clrb;

NewDatabusArbiter_v2 UUT (
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
