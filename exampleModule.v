

module NewDatabusArbiter_v2 (
    sys_clk,
    data_in, // {preamble[29:22], mode[21:18], data[17:2], parity[1], endbit[0]} // only care about mode+data
    valid,
    porb,
    por_pulseb,
    timeoutb,
    eep_loadb,
    en_rail_rail,
    eeprom_cache,
    
    data_out,
    read_eep,
    pgm_eep,
    cache_out,
    p2s_en,
    reg0_ldb,
    reg1_ldb,
    reg2_ldb,
    reg3_ldb,
    eep_cycleb,
    eep_clrb

);

/*----------------------------------------- */
/*---------------Constants----------------- */
/*----------------------------------------- */

parameter MESSAGE_WIDTH         = 30;
parameter DATA_WIDTH                = 16;
parameter MODE_WIDTH                = 4;
parameter DATA_SEL_WIDTH        = 3;
parameter CHIP_ID_REV           = 16'hF001;
parameter CACHE_WIDTH           = 64;

/*----------------------------------------- */
/*--------------Module IOs----------------- */
/*----------------------------------------- */

input wire sys_clk;
input wire [MESSAGE_WIDTH-1:0] data_in;
input wire valid;
input wire porb;
input wire por_pulseb;
input wire timeoutb;
input wire eep_loadb;
input wire en_rail_rail;
input wire [CACHE_WIDTH-1:0] eeprom_cache;

output reg [DATA_WIDTH-1:0] data_out = {DATA_WIDTH {1'b0}};
output reg read_eep = 1'b0;
output reg pgm_eep = 1'b0;
output wire [CACHE_WIDTH-1:0] cache_out;
output reg p2s_en = 1'b0;
output reg reg0_ldb = 1'b0;
output reg reg1_ldb = 1'b0;
output reg reg2_ldb = 1'b0;
output reg reg3_ldb = 1'b0;
output reg eep_cycleb = 1'b1;
output reg eep_clrb = 1'b1;

/*----------------------------------------- */
/*-------------Input Config---------------- */
/*----------------------------------------- */

wire int_rstb;
assign int_rstb = porb & por_pulseb & timeoutb;

/*----------------------------------------- */
/*-------------Instantiation--------------- */
/*----------------------------------------- */

reg [MODE_WIDTH-1:0] int_mode = {MODE_WIDTH {1'b0}};
reg [DATA_SEL_WIDTH-1:0] int_data_sel = {DATA_SEL_WIDTH {1'b0}};

reg [DATA_WIDTH-1:0] reg0 = {DATA_WIDTH {1'b0}};
reg [DATA_WIDTH-1:0] reg1 = {DATA_WIDTH {1'b0}};
reg [DATA_WIDTH-1:0] reg2 = {DATA_WIDTH {1'b0}};
reg [DATA_WIDTH-1:0] reg3 = {DATA_WIDTH {1'b0}};
assign cache_out = {reg3, reg2, reg1, reg0};

reg en_rail_rail_ff = 1'b0;

reg [2:0] sel_eep_state = 3'b000;
reg [2:0] sel_reg_state = 3'b000;

reg readback_eep = 1'b0;
reg readback_reg = 1'b0;
reg write_reg = 1'b0;
reg [3:0] addr_code = 4'b0000;
reg readback_id_rev = 1'b0;
reg [7:0] fxn_code = 8'h00;
reg select_eep = 1'b0;
reg select_reg = 1'b0;
reg selecting_eep = 1'b0;
reg selecting_reg = 1'b0;

wire eep_clrb_int;
assign eep_clrb_int = ~pgm_eep & porb;

reg write_reg_ff = 1'b0;

reg valid_ff = 1'b0;

/*----------------------------------------- */
/*-----------------Logic------------------- */
/*----------------------------------------- */

always @(posedge sys_clk, negedge int_rstb) begin
    if (int_rstb == 1'b0) begin
        int_mode <= {MODE_WIDTH {1'b0}};
        int_data_sel <= {DATA_SEL_WIDTH {1'b0}};
        valid_ff <= 1'b0;
    end else if (valid == 1'b1) begin
        int_mode <= data_in[21:18];
        int_data_sel <= data_in[4:2];
        valid_ff <= 1'b1;
    end else if (valid == 1'b0) begin
        valid_ff <= 1'b0;
    end
end

always @(posedge sys_clk) begin
    eep_clrb <= eep_clrb_int;
end

always @(posedge sys_clk, negedge int_rstb) begin
    if (int_rstb == 1'b0) begin
        select_reg <= 1'b0;
        select_eep <= 1'b0;
        read_eep <= 1'b0;
        pgm_eep <= 1'b0;
        en_rail_rail_ff <= 1'b0;
        eep_cycleb <= 1'b1;
        p2s_en <= 1'b0;
        readback_eep <= 1'b0;
        readback_reg <= 1'b0;
        fxn_code <= 8'h00;
        readback_id_rev <= 1'b0;
        write_reg <= 1'b0;
        addr_code <= 4'h0;
        
    end else if (valid_ff == 1'b1) begin
        
        /**************************/
        // WRITE TO REGISTERS
        /**************************/
        if (int_mode == 4'h0) begin
            write_reg <= 1'b1;
            addr_code <= 4'b0001;
            
        end else if (int_mode == 4'h1) begin
            write_reg <= 1'b1;
            addr_code <= 4'b0010;
                
        end else if (int_mode == 4'h2) begin
            write_reg <= 1'b1;
            addr_code <= 4'b0100;
                
        end else if (int_mode == 4'h3) begin
            write_reg <= 1'b1;
            addr_code <= 4'b1000;
        
        /**************************/
        // READBACK CHIP ID AND REVISION
        /**************************/
        end else if (int_mode == 4'h4) begin
            readback_id_rev <= 1'b1;
            p2s_en <= 1'b1;
        
        /**************************/
        // READBACK REGISTERS
        /**************************/
        end else if (int_mode == 4'h5 && int_data_sel == 3'b000) begin
            fxn_code <= 8'b00000001;
            readback_reg <= 1'b1;
            p2s_en <= 1'b1;
        
        end else if (int_mode == 4'h5 && int_data_sel == 3'b001) begin
            fxn_code <= 8'b00000010;
            readback_reg <= 1'b1;
            p2s_en <= 1'b1;
                
        end else if (int_mode == 4'h5 && int_data_sel == 3'b010) begin
            fxn_code <= 8'b00000100;
            readback_reg <= 1'b1;
            p2s_en <= 1'b1;
                
        end else if (int_mode == 4'h5 && int_data_sel == 3'b011) begin
            fxn_code <= 8'b00001000;
            readback_reg <= 1'b1;
            p2s_en <= 1'b1;
            
        /**************************/
        // SETUP TO READBACK FROM EEPROM
        /**************************/
        end else if (int_mode == 4'h5 && int_data_sel >= 3'b100) begin
            fxn_code <= 8'b00010000;
            read_eep <= 1'b1;
            readback_eep <= 1'b1;
            p2s_en <= 1'b1;
        
        end else if (int_mode == 4'h5 && int_data_sel == 3'b101) begin
            fxn_code <= 8'b00100000;
            read_eep <= 1'b1;
            readback_eep <= 1'b1;
            p2s_en <= 1'b1;
        
        end else if (int_mode == 4'h5 && int_data_sel == 3'b110) begin
            fxn_code <= 8'b01000000;
            read_eep <= 1'b1;
            readback_eep <= 1'b1;
            p2s_en <= 1'b1;
        
        end else if (int_mode == 4'h5 && int_data_sel == 3'b111) begin
            fxn_code <= 8'b10000000;
            read_eep <= 1'b1;
            readback_eep <= 1'b1;
            p2s_en <= 1'b1;
        
        
        /**************************/
        // SETUP TO PROGRAM EEPROM
        /**************************/
        end else if (int_mode == 4'h6) begin
            eep_cycleb <= 1'b0;
            if (en_rail_rail == 1'b1) begin
                en_rail_rail_ff <= 1'b1;
            end else if (en_rail_rail == 1'b0 && en_rail_rail_ff == 1'b1) begin
                pgm_eep <= 1'b1;
            end
        
        /**************************/
        // SELECT EEPROM
        /**************************/
        end else if (int_mode == 4'h7 && int_data_sel == 3'b000) begin
            read_eep <= 1'b1;
            select_eep <= 1'b1;
            
        /**************************/
        // SELECT REGISTERS
        /**************************/
        end else if (int_mode == 4'h7 && int_data_sel == 3'b001) begin
            select_reg <= 1'b1;
        end     
        
    end else if (valid_ff == 1'b0) begin
        select_reg <= 1'b0;
        select_eep <= 1'b0;
        read_eep <= 1'b0;
        pgm_eep <= 1'b0;
        en_rail_rail_ff <= 1'b0;
        eep_cycleb <= 1'b1;
        p2s_en <= 1'b0;
        readback_eep <= 1'b0;
        readback_reg <= 1'b0;
        fxn_code <= 8'h00;
        readback_id_rev <= 1'b0;
        write_reg <= 1'b0;
        addr_code <= 4'h0;
    end
end

// Equivalent to "Cache Registers" block and "Databus Tristate Buffers" block
always @(posedge sys_clk, negedge int_rstb) begin
    if (!int_rstb) begin
        sel_eep_state <= 3'b000;
        sel_reg_state <= 3'b000;
        data_out <= {DATA_WIDTH {1'b0}};
        reg0_ldb <= 1'b0;
        reg1_ldb <= 1'b0;
        reg2_ldb <= 1'b0;
        reg3_ldb <= 1'b0;
    end else if (write_reg == 1'b1 && write_reg_ff == 1'b0) begin
        write_reg_ff <= 1'b1;
        case (addr_code)
            4'b0001:    reg0 <= data_in[17:2];
            4'b0010:    reg1 <= data_in[17:2];
            4'b0100: reg2 <= data_in[17:2];
            4'b1000: reg3 <= data_in[17:2];
        endcase     
    end else if (readback_id_rev) begin
        data_out <= CHIP_ID_REV;
    end else if (readback_reg) begin
        case (fxn_code)
            8'b00000001: data_out <= reg0;
            8'b00000010: data_out <= reg1;
            8'b00000100: data_out <= reg2;
            8'b00001000: data_out <= reg3;
            default: data_out <= {DATA_WIDTH {1'b0}};
        endcase
    end else if (readback_eep) begin 
        // separated from register readback to accomodate eeprom timing
        case (fxn_code)
            8'b00010000: data_out <= eeprom_cache[15:0];
            8'b00100000: data_out <= eeprom_cache[31:16];
            8'b01000000: data_out <= eeprom_cache[47:32];
            8'b10000000: data_out <= eeprom_cache[63:48];
            default: data_out <= {DATA_WIDTH {1'b0}};
        endcase
    end else if (!eep_cycleb) begin
        data_out <= {DATA_WIDTH {1'b0}};
    end else if (select_eep == 1'b1 || selecting_eep == 1'b1) begin
        case (sel_eep_state)
            3'b000: begin
                selecting_eep <= 1'b1;
                data_out <= eeprom_cache[15:0];
                reg0_ldb <= 1'b1;
                reg1_ldb <= 1'b0;
                reg2_ldb <= 1'b0;
                reg3_ldb <= 1'b0;
                sel_eep_state <= 3'b001;
            end
            3'b001: begin
                selecting_eep <= 1'b1;
                data_out <= eeprom_cache[31:16];
                reg0_ldb <= 1'b0;
                reg1_ldb <= 1'b1;
                reg2_ldb <= 1'b0;
                reg3_ldb <= 1'b0;
                sel_eep_state <= 3'b010;
            end
            3'b010: begin
                selecting_eep <= 1'b1;
                data_out <= eeprom_cache[47:32];
                reg0_ldb <= 1'b0;
                reg1_ldb <= 1'b0;
                reg2_ldb <= 1'b1;
                reg3_ldb <= 1'b0;
                sel_eep_state <= 3'b011;
            end
            3'b011: begin
                selecting_eep <= 1'b1;
                data_out <= eeprom_cache[63:48];
                reg0_ldb <= 1'b0;
                reg1_ldb <= 1'b0;
                reg2_ldb <= 1'b0;
                reg3_ldb <= 1'b1;
                sel_eep_state <= 3'b100;
            end
            default: begin
                selecting_eep <= 1'b0;
                data_out <= {DATA_WIDTH {1'b0}};
                reg0_ldb <= 1'b0;
                reg1_ldb <= 1'b0;
                reg2_ldb <= 1'b0;
                reg3_ldb <= 1'b0;
                sel_eep_state <= 3'b100;
            end
        endcase
    end else if (select_reg == 1'b1 || selecting_reg == 1'b1) begin
        case(sel_reg_state)
            3'b000: begin
                selecting_reg <= 1'b1;
                data_out <= reg0;
                reg0_ldb <= 1'b1;
                reg1_ldb <= 1'b0;
                reg2_ldb <= 1'b0;
                reg3_ldb <= 1'b0;
                sel_reg_state <= 3'b001;
            end
            3'b001: begin
                selecting_reg <= 1'b1;
                data_out <= reg1;
                reg0_ldb <= 1'b0;
                reg1_ldb <= 1'b1;
                reg2_ldb <= 1'b0;
                reg3_ldb <= 1'b0;
                sel_reg_state <= 3'b010;
            end
            3'b010: begin
                selecting_reg <= 1'b1;
                data_out <= reg2;
                reg0_ldb <= 1'b0;
                reg1_ldb <= 1'b0;
                reg2_ldb <= 1'b1;
                reg3_ldb <= 1'b0;
                sel_reg_state <= 3'b011;
            end
            3'b011: begin
                selecting_reg <= 1'b1;
                data_out <= reg3;
                reg0_ldb <= 1'b0;
                reg1_ldb <= 1'b0;
                reg2_ldb <= 1'b0;
                reg3_ldb <= 1'b1;
                sel_reg_state <= 3'b100;
            end
            default: begin
                selecting_reg <= 1'b0;
                data_out <= {DATA_WIDTH {1'b0}};
                reg0_ldb <= 1'b0;
                reg1_ldb <= 1'b0;
                reg2_ldb <= 1'b0;
                reg3_ldb <= 1'b0;
                sel_reg_state <= 3'b100;
            end
        endcase
    end else begin
        sel_eep_state <= 3'b000;
        sel_reg_state <= 3'b000;
        data_out <= {DATA_WIDTH {1'b0}};
        reg0_ldb <= 1'b0;
        reg1_ldb <= 1'b0;
        reg2_ldb <= 1'b0;
        reg3_ldb <= 1'b0;
        if (addr_code == 4'h0) begin
            write_reg_ff <= 1'b0;
        end
    end
end



endmodule

