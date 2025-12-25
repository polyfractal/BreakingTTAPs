// Licensed under CERN Open Hardware Licence Version 2 - Strongly Reciprocal
// See LICENSE in this directory for more details

`default_nettype none
module chip_core #(
    parameter NUM_INPUT_PADS = 13,
    parameter NUM_BIDIR_PADS = 41  
)(
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
    `endif

    input  wire clk,
    input  wire rst_n,

    input  wire [NUM_INPUT_PADS-1:0] input_in,
    output wire [NUM_INPUT_PADS-1:0] input_pu,
    output wire [NUM_INPUT_PADS-1:0] input_pd,

    // Bidirectional Pads (Can be Input or Output)
    input  wire [NUM_BIDIR_PADS-1:0] bidir_in,  // Signal FROM Pad
    output wire [NUM_BIDIR_PADS-1:0] bidir_out, // Signal TO Pad
    output wire [NUM_BIDIR_PADS-1:0] bidir_oe,  // Output Enable (1=Output, 0=Input)
    output wire [NUM_BIDIR_PADS-1:0] bidir_cs,
    output wire [NUM_BIDIR_PADS-1:0] bidir_sl,
    output wire [NUM_BIDIR_PADS-1:0] bidir_ie,  // Input Enable
    output wire [NUM_BIDIR_PADS-1:0] bidir_pu,
    output wire [NUM_BIDIR_PADS-1:0] bidir_pd
);

    // -----------------------------------------------------------
    // 1. Signal Declarations
    // -----------------------------------------------------------
    
    // Wires to connect chip_top inputs
    wire uart_rx_wire;
    wire uart_tx_wire;
    wire uart_tick_wire;
    wire miso_wire;
    wire [15:0] gpi16_wire; 
    wire [7:0] parallel8_wire; 
    wire parallel_strobe_wire;
    wire parallel_clock_wire;

    // Wires to catch chip_top outputs
    wire mosi_wire;
    wire [15:0] gpo16_wire; 
    
    // Reset handling
    wire rst_active_high;
    assign rst_active_high = ~rst_n; 


    // -----------------------------------------------------------
    // 2. Instantiate chip_top
    // -----------------------------------------------------------
    (* keep *)
    \tta::chip_top  chip_top_inst (
        `ifdef USE_POWER_PINS
        .VDD(VDD),
        .VSS(VSS),
        `endif
        .clk_i(clk),
        .rst_i(rst_active_high),
        
        .uart_rx_i(uart_rx_wire),
        .uart_tx_o(uart_tx_wire),
        .uart_tick16_i(uart_tick_wire),

        .miso_i(miso_wire),
        .mosi_o(mosi_wire),

        .gpo16_o(gpo16_wire),
        .gpi16_i(gpi16_wire), 
         
        .parallel_in_i(parallel8_wire),
        .parallel_strobe_i(parallel_strobe_wire),
        .parallel_clock_i(parallel_clock_wire)
    );


    // -----------------------------------------------------------
    // 3. Pad Configuration & Mapping
    // -----------------------------------------------------------

    // --- Dedicated Inputs Mapping (input_in) ---
    assign uart_rx_wire   = input_in[0];
    assign uart_tick_wire = input_in[1];
    assign miso_wire      = input_in[2];
    assign parallel_strobe_wire = input_in[3];
    assign parallel_clock_wire  = input_in[4];
    assign parallel8_wire       = input_in[12:5];

    assign input_pu = '0; 
    assign input_pd = '0;


    // --- Bidirectional Pad Mapping ---
    
    // A. OUTPUTS: Map gpo16 and mosi to bidir_out
    // Pads [15:0]  = GPO (16 bits)
    // Pad  [16]    = MOSI (1 bit)
    assign bidir_out[15:0] = gpo16_wire;
    assign bidir_out[16]   = mosi_wire;
    assign bidir_out[17]   = uart_tx_wire;
    assign bidir_out[NUM_BIDIR_PADS-1:18] = '0; 

    // B. INPUTS: Map gpi16 from bidir_in
    // Pads [33:18] = GPI (16 bits)
    // Math: Start at 18. End at (18 + 16 - 1) = 33.
    assign gpi16_wire = bidir_in[33:18];


    // -----------------------------------------------------------
    // 4. Direction Control
    // -----------------------------------------------------------
    
    // 1. Output Enables (Pads 0-17 are Outputs)
    assign bidir_oe[17:0] = {18{1'b1}};           
    assign bidir_oe[NUM_BIDIR_PADS-1:18] = '0;    

    // 2. Input Enables
    
    // A. Disable RX on Output pads (0-17)
    assign bidir_ie[17:0]  = '0;                  

    // B. Enable RX on GPI pins (18-33)
    assign bidir_ie[33:18] = {16{1'b1}};          
    
    // C. Disable RX on unused pads (34 to End)
    if (NUM_BIDIR_PADS > 34) begin
        assign bidir_ie[NUM_BIDIR_PADS-1:34] = '0; 
    end

    // Configure standard Pad settings
    assign bidir_cs = '0; 
    assign bidir_sl = '0; 
    assign bidir_pu = '0; 
    assign bidir_pd = '0; 

endmodule

`default_nettype wire


`default_nettype none

module \std::cdc::sync2_bool  (
        input clk_i,
        input in_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::cdc::sync2_bool" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::cdc::sync2_bool );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/cdc.spade:34,9" *)
    logic _e_137;
    (* src = "<compiler dir>/stdlib/cdc.spade:34,9" *)
    \std::cdc::sync2[2152]  sync2_0(.clk_i(\clk ), .in_i(\in ), .output__(_e_137));
    assign output__ = _e_137;
endmodule

module \std::conv::tri_to_bool  (
        input b_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::tri_to_bool" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::tri_to_bool );
        end
    end
    `endif
    logic \b ;
    assign \b  = b_i;
    logic _e_433;
    assign _e_433 = \b ;
    assign output__ = _e_433;
endmodule

module \std::conv::clock_to_bool  (
        input c_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::clock_to_bool" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::clock_to_bool );
        end
    end
    `endif
    logic \c ;
    assign \c  = c_i;
    logic _e_487;
    assign _e_487 = \c ;
    assign output__ = _e_487;
endmodule

module \std::conv::bool_to_clock  (
        input c_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::bool_to_clock" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::bool_to_clock );
        end
    end
    `endif
    logic \c ;
    assign \c  = c_i;
    logic _e_491;
    assign _e_491 = \c ;
    assign output__ = _e_491;
endmodule

module \std::io::rising_edge  (
        input clk_i,
        input sync1_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::io::rising_edge" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::io::rising_edge );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \sync1 ;
    assign \sync1  = sync1_i;
    (* src = "<compiler dir>/stdlib/io.spade:3,14" *)
    reg \sync2 ;
    (* src = "<compiler dir>/stdlib/io.spade:4,14" *)
    logic _e_583;
    (* src = "<compiler dir>/stdlib/io.spade:4,5" *)
    logic _e_581;
    always @(posedge \clk ) begin
        \sync2  <= \sync1 ;
    end
    assign _e_583 = !\sync2 ;
    assign _e_581 = \sync1  && _e_583;
    assign output__ = _e_581;
endmodule

module \std::io::falling_edge  (
        input clk_i,
        input sync1_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::io::falling_edge" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::io::falling_edge );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \sync1 ;
    assign \sync1  = sync1_i;
    (* src = "<compiler dir>/stdlib/io.spade:9,14" *)
    reg \sync2 ;
    (* src = "<compiler dir>/stdlib/io.spade:10,14" *)
    logic _e_591;
    (* src = "<compiler dir>/stdlib/io.spade:10,5" *)
    logic _e_589;
    always @(posedge \clk ) begin
        \sync2  <= \sync1 ;
    end
    assign _e_591 = !\sync1 ;
    assign _e_589 = \sync2  && _e_591;
    assign output__ = _e_589;
endmodule

module \tta::sram::sram_512x32  (
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input en_i,
        input[15:0] addr_i,
        input we_i,
        input[31:0] wdata_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::sram::sram_512x32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::sram::sram_512x32 );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic \en ;
    assign \en  = en_i;
    logic[15:0] \addr ;
    assign \addr  = addr_i;
    logic \we ;
    assign \we  = we_i;
    logic[31:0] \wdata ;
    assign \wdata  = wdata_i;
    (* src = "src/sram.spade:43,35" *)
    logic[15:0] _e_1140;
    (* src = "src/sram.spade:43,29" *)
    logic[8:0] \word_idx ;
    (* src = "src/sram.spade:46,23" *)
    logic[7:0] \d0 ;
    (* src = "src/sram.spade:47,29" *)
    logic[31:0] _e_1148;
    (* src = "src/sram.spade:47,23" *)
    logic[7:0] \d1 ;
    (* src = "src/sram.spade:48,29" *)
    logic[31:0] _e_1153;
    (* src = "src/sram.spade:48,23" *)
    logic[7:0] \d2 ;
    (* src = "src/sram.spade:49,29" *)
    logic[31:0] _e_1158;
    (* src = "src/sram.spade:49,23" *)
    logic[7:0] \d3 ;
    (* src = "src/sram.spade:59,9" *)
    logic \cen ;
    (* src = "src/sram.spade:62,25" *)
    logic \gwen ;
    (* src = "src/sram.spade:63,25" *)
    logic[7:0] \wen ;
    (* src = "src/sram.spade:66,22" *)
    logic[7:0] _e_7850;
    (* src = "src/sram.spade:66,22" *)
    logic[7:0] _e_7851_mut;
    (* src = "src/sram.spade:66,22" *)
    logic[7:0] _e_1181;
    (* src = "src/sram.spade:66,22" *)
    logic[7:0] _e_1181_mut;
    (* src = "src/sram.spade:66,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:66,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:67,22" *)
    logic[7:0] _e_7852;
    (* src = "src/sram.spade:67,22" *)
    logic[7:0] _e_7853_mut;
    (* src = "src/sram.spade:67,22" *)
    logic[7:0] _e_1185;
    (* src = "src/sram.spade:67,22" *)
    logic[7:0] _e_1185_mut;
    (* src = "src/sram.spade:67,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:67,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:68,22" *)
    logic[7:0] _e_7854;
    (* src = "src/sram.spade:68,22" *)
    logic[7:0] _e_7855_mut;
    (* src = "src/sram.spade:68,22" *)
    logic[7:0] _e_1189;
    (* src = "src/sram.spade:68,22" *)
    logic[7:0] _e_1189_mut;
    (* src = "src/sram.spade:68,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:68,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:69,22" *)
    logic[7:0] _e_7856;
    (* src = "src/sram.spade:69,22" *)
    logic[7:0] _e_7857_mut;
    (* src = "src/sram.spade:69,22" *)
    logic[7:0] _e_1193;
    (* src = "src/sram.spade:69,22" *)
    logic[7:0] _e_1193_mut;
    (* src = "src/sram.spade:69,9" *)
    logic[7:0] \qr3 ;
    (* src = "src/sram.spade:69,9" *)
    logic[7:0] \qw3_mut ;
    logic[31:0] _e_1233;
    logic[31:0] _e_1237;
    (* src = "src/sram.spade:78,9" *)
    logic[31:0] _e_1236;
    (* src = "src/sram.spade:77,9" *)
    logic[31:0] _e_1232;
    logic[31:0] _e_1242;
    (* src = "src/sram.spade:79,9" *)
    logic[31:0] _e_1241;
    (* src = "src/sram.spade:77,9" *)
    logic[31:0] _e_1231;
    logic[31:0] _e_1247;
    (* src = "src/sram.spade:80,9" *)
    logic[31:0] _e_1246;
    (* src = "src/sram.spade:77,9" *)
    logic[31:0] \q32 ;
    localparam[15:0] _e_1142 = 2;
    assign _e_1140 = \addr  >> _e_1142;
    assign \word_idx  = _e_1140[8:0];
    assign \d0  = \wdata [7:0];
    localparam[31:0] _e_1150 = 32'd8;
    assign _e_1148 = \wdata  >> _e_1150;
    assign \d1  = _e_1148[7:0];
    localparam[31:0] _e_1155 = 32'd16;
    assign _e_1153 = \wdata  >> _e_1155;
    assign \d2  = _e_1153[7:0];
    localparam[31:0] _e_1160 = 32'd24;
    assign _e_1158 = \wdata  >> _e_1160;
    assign \d3  = _e_1158[7:0];
    assign \cen  = \rst ;
    localparam[0:0] _e_1167 = 0;
    localparam[0:0] _e_1169 = 1;
    assign \gwen  = \we  ? _e_1167 : _e_1169;
    localparam[7:0] _e_1174 = 0;
    localparam[7:0] _e_1176 = 255;
    assign \wen  = \we  ? _e_1174 : _e_1176;
    
    assign _e_7850 = _e_7851_mut;
    assign _e_1181 = {_e_7850};
    assign {_e_7851_mut} = _e_1181_mut;
    assign \qr0  = _e_1181[7:0];
    assign _e_1181_mut[7:0] = \qw0_mut ;
    
    assign _e_7852 = _e_7853_mut;
    assign _e_1185 = {_e_7852};
    assign {_e_7853_mut} = _e_1185_mut;
    assign \qr1  = _e_1185[7:0];
    assign _e_1185_mut[7:0] = \qw1_mut ;
    
    assign _e_7854 = _e_7855_mut;
    assign _e_1189 = {_e_7854};
    assign {_e_7855_mut} = _e_1189_mut;
    assign \qr2  = _e_1189[7:0];
    assign _e_1189_mut[7:0] = \qw2_mut ;
    
    assign _e_7856 = _e_7857_mut;
    assign _e_1193 = {_e_7856};
    assign {_e_7857_mut} = _e_1193_mut;
    assign \qr3  = _e_1193[7:0];
    assign _e_1193_mut[7:0] = \qw3_mut ;
    (* src = "src/sram.spade:70,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d0 ), .Q(\qw0_mut ));
    (* src = "src/sram.spade:71,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_1(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d1 ), .Q(\qw1_mut ));
    (* src = "src/sram.spade:72,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_2(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d2 ), .Q(\qw2_mut ));
    (* src = "src/sram.spade:73,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_3(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d3 ), .Q(\qw3_mut ));
    assign _e_1233 = {24'b0, \qr0 };
    assign _e_1237 = {24'b0, \qr1 };
    localparam[31:0] _e_1240 = 32'd8;
    assign _e_1236 = _e_1237 << _e_1240;
    assign _e_1232 = _e_1233 | _e_1236;
    assign _e_1242 = {24'b0, \qr2 };
    localparam[31:0] _e_1245 = 32'd16;
    assign _e_1241 = _e_1242 << _e_1245;
    assign _e_1231 = _e_1232 | _e_1241;
    assign _e_1247 = {24'b0, \qr3 };
    localparam[31:0] _e_1250 = 32'd24;
    assign _e_1246 = _e_1247 << _e_1250;
    assign \q32  = _e_1231 | _e_1246;
    assign output__ = \q32 ;
endmodule

module \tta::sram::stack_ram_256x32  (
`ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input[7:0] word_idx_i,
        input we_i,
        input[31:0] wdata_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::sram::stack_ram_256x32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::sram::stack_ram_256x32 );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[7:0] \word_idx ;
    assign \word_idx  = word_idx_i;
    logic \we ;
    assign \we  = we_i;
    logic[31:0] \wdata ;
    assign \wdata  = wdata_i;
    (* src = "src/sram.spade:99,23" *)
    logic[7:0] \d0 ;
    (* src = "src/sram.spade:100,29" *)
    logic[31:0] _e_1258;
    (* src = "src/sram.spade:100,23" *)
    logic[7:0] \d1 ;
    (* src = "src/sram.spade:101,29" *)
    logic[31:0] _e_1263;
    (* src = "src/sram.spade:101,23" *)
    logic[7:0] \d2 ;
    (* src = "src/sram.spade:102,29" *)
    logic[31:0] _e_1268;
    (* src = "src/sram.spade:102,23" *)
    logic[7:0] \d3 ;
    (* src = "src/sram.spade:105,9" *)
    logic \cen ;
    (* src = "src/sram.spade:106,25" *)
    logic \gwen ;
    (* src = "src/sram.spade:107,25" *)
    logic[7:0] \wen ;
    (* src = "src/sram.spade:110,22" *)
    logic[7:0] _e_7858;
    (* src = "src/sram.spade:110,22" *)
    logic[7:0] _e_7859_mut;
    (* src = "src/sram.spade:110,22" *)
    logic[7:0] _e_1291;
    (* src = "src/sram.spade:110,22" *)
    logic[7:0] _e_1291_mut;
    (* src = "src/sram.spade:110,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:110,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_7860;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_7861_mut;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_1295;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_1295_mut;
    (* src = "src/sram.spade:111,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:111,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_7862;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_7863_mut;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_1299;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_1299_mut;
    (* src = "src/sram.spade:112,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:112,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_7864;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_7865_mut;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_1303;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_1303_mut;
    (* src = "src/sram.spade:113,9" *)
    logic[7:0] \qr3 ;
    (* src = "src/sram.spade:113,9" *)
    logic[7:0] \qw3_mut ;
    logic[31:0] _e_1343;
    logic[31:0] _e_1347;
    (* src = "src/sram.spade:122,9" *)
    logic[31:0] _e_1346;
    (* src = "src/sram.spade:121,9" *)
    logic[31:0] _e_1342;
    logic[31:0] _e_1352;
    (* src = "src/sram.spade:123,9" *)
    logic[31:0] _e_1351;
    (* src = "src/sram.spade:121,9" *)
    logic[31:0] _e_1341;
    logic[31:0] _e_1357;
    (* src = "src/sram.spade:124,9" *)
    logic[31:0] _e_1356;
    (* src = "src/sram.spade:121,9" *)
    logic[31:0] \q32 ;
    assign \d0  = \wdata [7:0];
    localparam[31:0] _e_1260 = 32'd8;
    assign _e_1258 = \wdata  >> _e_1260;
    assign \d1  = _e_1258[7:0];
    localparam[31:0] _e_1265 = 32'd16;
    assign _e_1263 = \wdata  >> _e_1265;
    assign \d2  = _e_1263[7:0];
    localparam[31:0] _e_1270 = 32'd24;
    assign _e_1268 = \wdata  >> _e_1270;
    assign \d3  = _e_1268[7:0];
    assign \cen  = \rst ;
    localparam[0:0] _e_1277 = 0;
    localparam[0:0] _e_1279 = 1;
    assign \gwen  = \we  ? _e_1277 : _e_1279;
    localparam[7:0] _e_1284 = 0;
    localparam[7:0] _e_1286 = 255;
    assign \wen  = \we  ? _e_1284 : _e_1286;
    
    assign _e_7858 = _e_7859_mut;
    assign _e_1291 = {_e_7858};
    assign {_e_7859_mut} = _e_1291_mut;
    assign \qr0  = _e_1291[7:0];
    assign _e_1291_mut[7:0] = \qw0_mut ;
    
    assign _e_7860 = _e_7861_mut;
    assign _e_1295 = {_e_7860};
    assign {_e_7861_mut} = _e_1295_mut;
    assign \qr1  = _e_1295[7:0];
    assign _e_1295_mut[7:0] = \qw1_mut ;
    
    assign _e_7862 = _e_7863_mut;
    assign _e_1299 = {_e_7862};
    assign {_e_7863_mut} = _e_1299_mut;
    assign \qr2  = _e_1299[7:0];
    assign _e_1299_mut[7:0] = \qw2_mut ;
    
    assign _e_7864 = _e_7865_mut;
    assign _e_1303 = {_e_7864};
    assign {_e_7865_mut} = _e_1303_mut;
    assign \qr3  = _e_1303[7:0];
    assign _e_1303_mut[7:0] = \qw3_mut ;
    (* src = "src/sram.spade:114,13" *)
    gf180mcu_fd_ip_sram__sram256x8m8wm1 gf180mcu_fd_ip_sram__sram256x8m8wm1_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d0 ), .Q(\qw0_mut ));
    (* src = "src/sram.spade:115,13" *)
    gf180mcu_fd_ip_sram__sram256x8m8wm1 gf180mcu_fd_ip_sram__sram256x8m8wm1_1(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d1 ), .Q(\qw1_mut ));
    (* src = "src/sram.spade:116,13" *)
    gf180mcu_fd_ip_sram__sram256x8m8wm1 gf180mcu_fd_ip_sram__sram256x8m8wm1_2(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d2 ), .Q(\qw2_mut ));
    (* src = "src/sram.spade:117,13" *)
    gf180mcu_fd_ip_sram__sram256x8m8wm1 gf180mcu_fd_ip_sram__sram256x8m8wm1_3(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d3 ), .Q(\qw3_mut ));
    assign _e_1343 = {24'b0, \qr0 };
    assign _e_1347 = {24'b0, \qr1 };
    localparam[31:0] _e_1350 = 32'd8;
    assign _e_1346 = _e_1347 << _e_1350;
    assign _e_1342 = _e_1343 | _e_1346;
    assign _e_1352 = {24'b0, \qr2 };
    localparam[31:0] _e_1355 = 32'd16;
    assign _e_1351 = _e_1352 << _e_1355;
    assign _e_1341 = _e_1342 | _e_1351;
    assign _e_1357 = {24'b0, \qr3 };
    localparam[31:0] _e_1360 = 32'd24;
    assign _e_1356 = _e_1357 << _e_1360;
    assign \q32  = _e_1341 | _e_1356;
    assign output__ = \q32 ;
endmodule

module \tta::sram::iram_512x32  (
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input en_i,
        input[8:0] addr_i,
        input we_i,
        input[31:0] wdata_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::sram::iram_512x32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::sram::iram_512x32 );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic \en ;
    assign \en  = en_i;
    logic[8:0] \addr ;
    assign \addr  = addr_i;
    logic \we ;
    assign \we  = we_i;
    logic[31:0] \wdata ;
    assign \wdata  = wdata_i;
    (* src = "src/sram.spade:145,23" *)
    logic[7:0] \d0 ;
    (* src = "src/sram.spade:146,29" *)
    logic[31:0] _e_1368;
    (* src = "src/sram.spade:146,23" *)
    logic[7:0] \d1 ;
    (* src = "src/sram.spade:147,29" *)
    logic[31:0] _e_1373;
    (* src = "src/sram.spade:147,23" *)
    logic[7:0] \d2 ;
    (* src = "src/sram.spade:148,29" *)
    logic[31:0] _e_1378;
    (* src = "src/sram.spade:148,23" *)
    logic[7:0] \d3 ;
    (* src = "src/sram.spade:157,9" *)
    logic \cen ;
    (* src = "src/sram.spade:159,25" *)
    logic \gwen ;
    (* src = "src/sram.spade:160,25" *)
    logic[7:0] \wen ;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_7866;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_7867_mut;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_1401;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_1401_mut;
    (* src = "src/sram.spade:163,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:163,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:164,22" *)
    logic[7:0] _e_7868;
    (* src = "src/sram.spade:164,22" *)
    logic[7:0] _e_7869_mut;
    (* src = "src/sram.spade:164,22" *)
    logic[7:0] _e_1405;
    (* src = "src/sram.spade:164,22" *)
    logic[7:0] _e_1405_mut;
    (* src = "src/sram.spade:164,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:164,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:165,22" *)
    logic[7:0] _e_7870;
    (* src = "src/sram.spade:165,22" *)
    logic[7:0] _e_7871_mut;
    (* src = "src/sram.spade:165,22" *)
    logic[7:0] _e_1409;
    (* src = "src/sram.spade:165,22" *)
    logic[7:0] _e_1409_mut;
    (* src = "src/sram.spade:165,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:165,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:166,22" *)
    logic[7:0] _e_7872;
    (* src = "src/sram.spade:166,22" *)
    logic[7:0] _e_7873_mut;
    (* src = "src/sram.spade:166,22" *)
    logic[7:0] _e_1413;
    (* src = "src/sram.spade:166,22" *)
    logic[7:0] _e_1413_mut;
    (* src = "src/sram.spade:166,9" *)
    logic[7:0] \qr3 ;
    (* src = "src/sram.spade:166,9" *)
    logic[7:0] \qw3_mut ;
    logic[31:0] _e_1453;
    logic[31:0] _e_1457;
    (* src = "src/sram.spade:175,9" *)
    logic[31:0] _e_1456;
    (* src = "src/sram.spade:174,9" *)
    logic[31:0] _e_1452;
    logic[31:0] _e_1462;
    (* src = "src/sram.spade:176,9" *)
    logic[31:0] _e_1461;
    (* src = "src/sram.spade:174,9" *)
    logic[31:0] _e_1451;
    logic[31:0] _e_1467;
    (* src = "src/sram.spade:177,9" *)
    logic[31:0] _e_1466;
    (* src = "src/sram.spade:174,9" *)
    logic[31:0] \q32 ;
    assign \d0  = \wdata [7:0];
    localparam[31:0] _e_1370 = 32'd8;
    assign _e_1368 = \wdata  >> _e_1370;
    assign \d1  = _e_1368[7:0];
    localparam[31:0] _e_1375 = 32'd16;
    assign _e_1373 = \wdata  >> _e_1375;
    assign \d2  = _e_1373[7:0];
    localparam[31:0] _e_1380 = 32'd24;
    assign _e_1378 = \wdata  >> _e_1380;
    assign \d3  = _e_1378[7:0];
    assign \cen  = \rst ;
    localparam[0:0] _e_1387 = 0;
    localparam[0:0] _e_1389 = 1;
    assign \gwen  = \we  ? _e_1387 : _e_1389;
    localparam[7:0] _e_1394 = 0;
    localparam[7:0] _e_1396 = 255;
    assign \wen  = \we  ? _e_1394 : _e_1396;
    
    assign _e_7866 = _e_7867_mut;
    assign _e_1401 = {_e_7866};
    assign {_e_7867_mut} = _e_1401_mut;
    assign \qr0  = _e_1401[7:0];
    assign _e_1401_mut[7:0] = \qw0_mut ;
    
    assign _e_7868 = _e_7869_mut;
    assign _e_1405 = {_e_7868};
    assign {_e_7869_mut} = _e_1405_mut;
    assign \qr1  = _e_1405[7:0];
    assign _e_1405_mut[7:0] = \qw1_mut ;
    
    assign _e_7870 = _e_7871_mut;
    assign _e_1409 = {_e_7870};
    assign {_e_7871_mut} = _e_1409_mut;
    assign \qr2  = _e_1409[7:0];
    assign _e_1409_mut[7:0] = \qw2_mut ;
    
    assign _e_7872 = _e_7873_mut;
    assign _e_1413 = {_e_7872};
    assign {_e_7873_mut} = _e_1413_mut;
    assign \qr3  = _e_1413[7:0];
    assign _e_1413_mut[7:0] = \qw3_mut ;
    (* src = "src/sram.spade:167,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\addr ), .D(\d0 ), .Q(\qw0_mut ));
    (* src = "src/sram.spade:168,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_1(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\addr ), .D(\d1 ), .Q(\qw1_mut ));
    (* src = "src/sram.spade:169,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_2(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\addr ), .D(\d2 ), .Q(\qw2_mut ));
    (* src = "src/sram.spade:170,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_3(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\addr ), .D(\d3 ), .Q(\qw3_mut ));
    assign _e_1453 = {24'b0, \qr0 };
    assign _e_1457 = {24'b0, \qr1 };
    localparam[31:0] _e_1460 = 32'd8;
    assign _e_1456 = _e_1457 << _e_1460;
    assign _e_1452 = _e_1453 | _e_1456;
    assign _e_1462 = {24'b0, \qr2 };
    localparam[31:0] _e_1465 = 32'd16;
    assign _e_1461 = _e_1462 << _e_1465;
    assign _e_1451 = _e_1452 | _e_1461;
    assign _e_1467 = {24'b0, \qr3 };
    localparam[31:0] _e_1470 = 32'd24;
    assign _e_1466 = _e_1467 << _e_1470;
    assign \q32  = _e_1451 | _e_1466;
    assign output__ = \q32 ;
endmodule

module \tta::sram::iram_1024x32  (
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input[9:0] addr_i,
        input we_i,
        input[31:0] wdata_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::sram::iram_1024x32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::sram::iram_1024x32 );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[9:0] \addr ;
    assign \addr  = addr_i;
    logic \we ;
    assign \we  = we_i;
    logic[31:0] \wdata ;
    assign \wdata  = wdata_i;
    (* src = "src/sram.spade:191,26" *)
    logic[8:0] \index ;
    (* src = "src/sram.spade:192,28" *)
    logic _e_1478;
    (* src = "src/sram.spade:192,25" *)
    logic \bank ;
    (* src = "src/sram.spade:195,15" *)
    logic \en0 ;
    (* src = "src/sram.spade:196,15" *)
    logic \en1 ;
    (* src = "src/sram.spade:199,15" *)
    logic \we0 ;
    (* src = "src/sram.spade:200,15" *)
    logic \we1 ;
    (* src = "src/sram.spade:203,18" *)
    logic[31:0] \rdata0 ;
    (* src = "src/sram.spade:204,18" *)
    logic[31:0] \rdata1 ;
    (* src = "src/sram.spade:208,14" *)
    reg \bank_d ;
    (* src = "src/sram.spade:210,8" *)
    logic _e_1524;
    (* src = "src/sram.spade:210,5" *)
    logic[31:0] _e_1523;
    assign \index  = \addr [8:0];
    localparam[9:0] _e_1480 = 512;
    assign _e_1478 = \addr  < _e_1480;
    localparam[0:0] _e_1482 = 0;
    localparam[0:0] _e_1484 = 1;
    assign \bank  = _e_1478 ? _e_1482 : _e_1484;
    localparam[0:0] _e_1488 = 0;
    assign \en0  = \bank  == _e_1488;
    localparam[0:0] _e_1492 = 1;
    assign \en1  = \bank  == _e_1492;
    assign \we0  = \we  && \en0 ;
    assign \we1  = \we  && \en1 ;
    (* src = "src/sram.spade:203,18" *)
    \tta::sram::iram_512x32  iram_512x32_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .en_i(\en0 ), .addr_i(\index ), .we_i(\we0 ), .wdata_i(\wdata ), .output__(\rdata0 ));
    (* src = "src/sram.spade:204,18" *)
    \tta::sram::iram_512x32  iram_512x32_1(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .en_i(\en1 ), .addr_i(\index ), .we_i(\we1 ), .wdata_i(\wdata ), .output__(\rdata1 ));
    localparam[0:0] _e_1521 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \bank_d  <= _e_1521;
        end
        else begin
            \bank_d  <= \bank ;
        end
    end
    localparam[0:0] _e_1526 = 0;
    assign _e_1524 = \bank_d  == _e_1526;
    assign _e_1523 = _e_1524 ? \rdata0  : \rdata1 ;
    assign output__ = _e_1523;
endmodule

module \tta::chip_top  (
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input uart_rx_i,
        output uart_tx_o,
        input uart_tick16_i,
        input miso_i,
        output mosi_o,
        output[15:0] gpo16_o,
        input[15:0] gpi16_i,
        input[7:0] parallel_in_i,
        input parallel_strobe_i,
        input parallel_clock_i,
        output[136:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::chip_top" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::chip_top );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic \uart_rx ;
    assign \uart_rx  = uart_rx_i;
    logic \uart_tx_mut ;
    assign uart_tx_o = \uart_tx_mut ;
    logic \uart_tick16 ;
    assign \uart_tick16  = uart_tick16_i;
    logic \miso ;
    assign \miso  = miso_i;
    logic \mosi_mut ;
    assign mosi_o = \mosi_mut ;
    logic[15:0] \gpo16_mut ;
    assign gpo16_o = \gpo16_mut ;
    logic[15:0] \gpi16 ;
    assign \gpi16  = gpi16_i;
    logic[7:0] \parallel_in ;
    assign \parallel_in  = parallel_in_i;
    logic \parallel_strobe ;
    assign \parallel_strobe  = parallel_strobe_i;
    logic \parallel_clock ;
    assign \parallel_clock  = parallel_clock_i;
    (* src = "src/main.spade:72,24" *)
    logic[9:0] _e_7874;
    (* src = "src/main.spade:72,24" *)
    logic[9:0] _e_7875_mut;
    (* src = "src/main.spade:72,24" *)
    logic[9:0] _e_1535;
    (* src = "src/main.spade:72,24" *)
    logic[9:0] _e_1535_mut;
    (* src = "src/main.spade:72,9" *)
    logic[9:0] \pc_r ;
    (* src = "src/main.spade:72,9" *)
    logic[9:0] \pc_w_mut ;
    (* src = "src/main.spade:73,25" *)
    logic[8:0] \parallel_data ;
    (* src = "src/main.spade:77,28" *)
    logic[8:0] _e_7876;
    (* src = "src/main.spade:77,28" *)
    logic[8:0] _e_7877_mut;
    (* src = "src/main.spade:77,28" *)
    logic[8:0] _e_1547;
    (* src = "src/main.spade:77,28" *)
    logic[8:0] _e_1547_mut;
    (* src = "src/main.spade:77,9" *)
    logic[8:0] \mosi_r ;
    (* src = "src/main.spade:77,9" *)
    logic[8:0] \mosi_w_mut ;
    (* src = "src/main.spade:78,16" *)
    logic \tick ;
    (* src = "src/main.spade:79,20" *)
    logic[11:0] \spi_data ;
    (* src = "src/main.spade:80,17" *)
    logic _e_1561;
    (* src = "src/main.spade:81,21" *)
    logic _e_1565;
    (* src = "src/main.spade:81,20" *)
    logic \spi_busy ;
    (* src = "src/main.spade:83,34" *)
    logic[8:0] _e_7878;
    (* src = "src/main.spade:83,34" *)
    logic[8:0] _e_7879_mut;
    (* src = "src/main.spade:83,34" *)
    logic[8:0] _e_1571;
    (* src = "src/main.spade:83,34" *)
    logic[8:0] _e_1571_mut;
    (* src = "src/main.spade:83,9" *)
    logic[8:0] \uart_tx_r ;
    (* src = "src/main.spade:83,9" *)
    logic[8:0] \uart_tx_w_mut ;
    (* src = "src/main.spade:84,20" *)
    logic[10:0] \uart_out ;
    (* src = "src/main.spade:85,20" *)
    logic _e_1580;
    (* src = "src/main.spade:87,29" *)
    logic[109:0] \subsys ;
    (* src = "src/main.spade:94,56" *)
    logic[10:0] _e_1595;
    (* src = "src/main.spade:94,55" *)
    logic[11:0] _e_1594;
    (* src = "src/main.spade:95,7" *)
    logic[11:0] _e_1601;
    (* src = "src/main.spade:95,7" *)
    logic[10:0] _e_1599;
    (* src = "src/main.spade:95,8" *)
    logic[9:0] \v ;
    (* src = "src/main.spade:95,7" *)
    logic \_ ;
    logic _e_7882;
    logic _e_7884;
    logic _e_7886;
    (* src = "src/main.spade:96,7" *)
    logic[11:0] _e_1605;
    (* src = "src/main.spade:96,7" *)
    logic[10:0] _e_1603;
    (* src = "src/main.spade:96,7" *)
    logic _e_1604;
    logic _e_7889;
    logic _e_7891;
    (* src = "src/main.spade:97,7" *)
    logic[11:0] _e_1609;
    (* src = "src/main.spade:97,7" *)
    logic[10:0] __n1;
    (* src = "src/main.spade:97,7" *)
    logic __n2;
    logic _e_7895;
    (* src = "src/main.spade:94,49" *)
    logic _e_1593;
    (* src = "src/main.spade:94,14" *)
    reg \released ;
    (* src = "src/main.spade:101,15" *)
    logic[97:0] _e_1614;
    logic _e_7897;
    (* src = "src/main.spade:102,16" *)
    logic[97:0] _e_1617;
    (* src = "src/main.spade:100,17" *)
    logic[97:0] \instr ;
    (* src = "src/main.spade:108,9" *)
    logic _e_1621;
    (* src = "src/main.spade:112,9" *)
    logic[8:0] _e_1627;
    (* src = "src/main.spade:114,9" *)
    logic _e_1630;
    (* src = "src/main.spade:115,9" *)
    logic[8:0] _e_1632;
    (* src = "src/main.spade:106,19" *)
    logic[509:0] \tta_out ;
    (* src = "src/main.spade:119,18" *)
    logic[15:0] _e_1638;
    (* src = "src/main.spade:123,9" *)
    logic _e_1642;
    (* src = "src/main.spade:124,9" *)
    logic[9:0] _e_1644;
    (* src = "src/main.spade:125,9" *)
    logic[10:0] _e_1646;
    (* src = "src/main.spade:126,9" *)
    logic[98:0] _e_1648;
    (* src = "src/main.spade:127,9" *)
    logic[15:0] _e_1650;
    (* src = "src/main.spade:122,5" *)
    logic[136:0] _e_1641;
    
    assign _e_7874 = _e_7875_mut;
    assign _e_1535 = {_e_7874};
    assign {_e_7875_mut} = _e_1535_mut;
    assign \pc_r  = _e_1535[9:0];
    assign _e_1535_mut[9:0] = \pc_w_mut ;
    (* src = "src/main.spade:73,25" *)
    \tta::parallel_rx::parallel_boot  parallel_boot_0(.clk_i(\clk ), .rst_i(\rst ), .data_in_i(\parallel_in ), .strobe_i(\parallel_strobe ), .clk_pin_i(\parallel_clock ), .output__(\parallel_data ));
    
    assign _e_7876 = _e_7877_mut;
    assign _e_1547 = {_e_7876};
    assign {_e_7877_mut} = _e_1547_mut;
    assign \mosi_r  = _e_1547[8:0];
    assign _e_1547_mut[8:0] = \mosi_w_mut ;
    localparam[15:0] _e_1551 = 10;
    (* src = "src/main.spade:78,16" *)
    \tta::tick_generator  tick_generator_0(.clk_i(\clk ), .rst_i(\rst ), .period_i(_e_1551), .output__(\tick ));
    (* src = "src/main.spade:79,20" *)
    \tta::spi_master::spi_master  spi_master_0(.clk_i(\clk ), .rst_i(\rst ), .tick_i(\tick ), .miso_i(\miso ), .start_tx_i(\mosi_r ), .output__(\spi_data ));
    assign _e_1561 = \spi_data [9];
    assign \mosi_mut  = _e_1561;
    assign _e_1565 = \spi_data [11];
    assign \spi_busy  = !_e_1565;
    
    assign _e_7878 = _e_7879_mut;
    assign _e_1571 = {_e_7878};
    assign {_e_7879_mut} = _e_1571_mut;
    assign \uart_tx_r  = _e_1571[8:0];
    assign _e_1571_mut[8:0] = \uart_tx_w_mut ;
    (* src = "src/main.spade:84,20" *)
    \tta::uart::uart_fu  uart_fu_0(.clk_i(\clk ), .rst_i(\rst ), .tick16_i(\uart_tick16 ), .rx_in_i(\uart_rx ), .tx_data_i(\uart_tx_r ), .output__(\uart_out ));
    assign _e_1580 = \uart_out [10];
    assign \uart_tx_mut  = _e_1580;
    (* src = "src/main.spade:87,29" *)
    \tta::boot_imem_subsystem::boot_imem_sub  boot_imem_sub_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .rx_opt_i(\parallel_data ), .fetch_pc_i(\pc_r ), .output__(\subsys ));
    localparam[0:0] _e_1592 = 0;
    assign _e_1595 = \subsys [10:0];
    assign _e_1594 = {_e_1595, \released };
    assign _e_1601 = _e_1594;
    assign _e_1599 = _e_1594[11:1];
    assign \v  = _e_1599[9:0];
    assign \_  = _e_1594[0];
    assign _e_7882 = _e_1599[10] == 1'd1;
    localparam[0:0] _e_7883 = 1;
    assign _e_7884 = _e_7882 && _e_7883;
    localparam[0:0] _e_7885 = 1;
    assign _e_7886 = _e_7884 && _e_7885;
    localparam[0:0] _e_1602 = 1;
    assign _e_1605 = _e_1594;
    assign _e_1603 = _e_1594[11:1];
    assign _e_1604 = _e_1594[0];
    assign _e_7889 = _e_1603[10] == 1'd0;
    assign _e_7891 = _e_7889 && _e_1604;
    localparam[0:0] _e_1606 = 1;
    assign _e_1609 = _e_1594;
    assign __n1 = _e_1594[11:1];
    assign __n2 = _e_1594[0];
    localparam[0:0] _e_7893 = 1;
    localparam[0:0] _e_7894 = 1;
    assign _e_7895 = _e_7893 && _e_7894;
    localparam[0:0] _e_1610 = 0;
    always_comb begin
        priority casez ({_e_7886, _e_7891, _e_7895})
            3'b1??: _e_1593 = _e_1602;
            3'b01?: _e_1593 = _e_1606;
            3'b001: _e_1593 = _e_1610;
            3'b?: _e_1593 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \released  <= _e_1592;
        end
        else begin
            \released  <= _e_1593;
        end
    end
    assign _e_1614 = \subsys [108:11];
    assign _e_7897 = !\released ;
    (* src = "src/main.spade:102,16" *)
    \tta::noop  noop_0(.output__(_e_1617));
    always_comb begin
        priority casez ({\released , _e_7897})
            2'b1?: \instr  = _e_1614;
            2'b01: \instr  = _e_1617;
            2'b?: \instr  = 98'dx;
        endcase
    end
    assign _e_1621 = !\released ;
    assign _e_1627 = \uart_out [9:1];
    assign _e_1630 = \uart_out [0];
    assign _e_1632 = \spi_data [8:0];
    (* src = "src/main.spade:106,19" *)
    \tta::tta::tta  tta_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(_e_1621), .insn_i(\instr ), .pc_w_o(\pc_w_mut ), .gpi16_i(\gpi16 ), .uart_rx_i(_e_1627), .uart_tx_o(\uart_tx_w_mut ), .uart_tx_busy_i(_e_1630), .spi_miso_i(_e_1632), .spi_mosi_o(\mosi_w_mut ), .spi_busy_i(\spi_busy ), .output__(\tta_out ));
    assign _e_1638 = \tta_out [15:0];
    assign \gpo16_mut  = _e_1638;
    assign _e_1642 = \subsys [109];
    assign _e_1644 = \tta_out [509:500];
    assign _e_1646 = \subsys [10:0];
    assign _e_1648 = \tta_out [114:16];
    assign _e_1650 = \tta_out [15:0];
    assign _e_1641 = {_e_1642, _e_1644, _e_1646, _e_1648, _e_1650};
    assign output__ = _e_1641;
endmodule

module \tta::noop  (
        output[97:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::noop" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::noop );
        end
    end
    `endif
    (* src = "src/main.spade:134,16" *)
    logic[36:0] _e_1655;
    (* src = "src/main.spade:134,27" *)
    logic[10:0] _e_1656;
    (* src = "src/main.spade:134,11" *)
    logic[48:0] _e_1654;
    (* src = "src/main.spade:135,16" *)
    logic[36:0] _e_1659;
    (* src = "src/main.spade:135,27" *)
    logic[10:0] _e_1660;
    (* src = "src/main.spade:135,11" *)
    logic[48:0] _e_1658;
    (* src = "src/main.spade:133,3" *)
    logic[97:0] _e_1653;
    assign _e_1655 = {5'd6, 32'bX};
    assign _e_1656 = {7'd2, 4'bX};
    localparam[0:0] _e_1657 = 0;
    assign _e_1654 = {_e_1655, _e_1656, _e_1657};
    assign _e_1659 = {5'd6, 32'bX};
    assign _e_1660 = {7'd2, 4'bX};
    localparam[0:0] _e_1661 = 0;
    assign _e_1658 = {_e_1659, _e_1660, _e_1661};
    assign _e_1653 = {_e_1654, _e_1658};
    assign output__ = _e_1653;
endmodule

module \tta::tick_generator  (
        input clk_i,
        input rst_i,
        input[15:0] period_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::tick_generator" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::tick_generator );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[15:0] \period ;
    assign \period  = period_i;
    (* src = "src/main.spade:142,21" *)
    logic[16:0] _e_1670;
    (* src = "src/main.spade:142,12" *)
    logic _e_1668;
    (* src = "src/main.spade:142,51" *)
    logic[17:0] _e_1677;
    (* src = "src/main.spade:142,45" *)
    logic[16:0] _e_1676;
    (* src = "src/main.spade:142,9" *)
    logic[16:0] _e_1667;
    (* src = "src/main.spade:141,14" *)
    reg[16:0] \count ;
    (* src = "src/main.spade:144,5" *)
    logic _e_1680;
    localparam[16:0] _e_1666 = 0;
    localparam[15:0] _e_1672 = 1;
    assign _e_1670 = \period  - _e_1672;
    assign _e_1668 = \count  == _e_1670;
    localparam[16:0] _e_1674 = 0;
    localparam[16:0] _e_1679 = 1;
    assign _e_1677 = \count  + _e_1679;
    assign _e_1676 = _e_1677[16:0];
    assign _e_1667 = _e_1668 ? _e_1674 : _e_1676;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \count  <= _e_1666;
        end
        else begin
            \count  <= _e_1667;
        end
    end
    localparam[16:0] _e_1682 = 0;
    assign _e_1680 = \count  == _e_1682;
    assign output__ = _e_1680;
endmodule

module \tta::uart::uart_fu  (
        input clk_i,
        input rst_i,
        input tick16_i,
        input rx_in_i,
        input[8:0] tx_data_i,
        output[10:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::uart::uart_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::uart::uart_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic \tick16 ;
    assign \tick16  = tick16_i;
    logic \rx_in ;
    assign \rx_in  = rx_in_i;
    logic[8:0] \tx_data ;
    assign \tx_data  = tx_data_i;
    (* src = "src/uart.spade:54,43" *)
    logic[1:0] _e_1688;
    (* src = "src/uart.spade:54,36" *)
    logic[17:0] _e_1687;
    (* src = "src/uart.spade:57,35" *)
    logic[3:0] _e_1698;
    (* src = "src/uart.spade:57,35" *)
    logic[4:0] _e_1697;
    (* src = "src/uart.spade:57,29" *)
    logic[3:0] \next_tick ;
    (* src = "src/uart.spade:58,29" *)
    logic[3:0] _e_1703;
    (* src = "src/uart.spade:58,29" *)
    logic \baud_tick ;
    (* src = "src/uart.spade:60,19" *)
    logic[1:0] _e_1708;
    (* src = "src/uart.spade:61,17" *)
    logic[1:0] _e_1710;
    logic _e_7899;
    (* src = "src/uart.spade:62,27" *)
    logic[8:0] _e_1713;
    (* src = "src/uart.spade:63,25" *)
    logic[8:0] _e_1716;
    (* src = "src/uart.spade:63,25" *)
    logic[7:0] \data ;
    logic _e_7901;
    logic _e_7903;
    (* src = "src/uart.spade:66,36" *)
    logic[1:0] _e_1719;
    (* src = "src/uart.spade:66,29" *)
    logic[17:0] _e_1718;
    (* src = "src/uart.spade:68,25" *)
    logic[8:0] _e_1723;
    logic _e_7905;
    (* src = "src/uart.spade:62,21" *)
    logic[17:0] _e_1712;
    (* src = "src/uart.spade:71,17" *)
    logic[1:0] _e_1725;
    logic _e_7907;
    (* src = "src/uart.spade:73,32" *)
    logic[1:0] _e_1731;
    (* src = "src/uart.spade:73,47" *)
    logic[7:0] _e_1732;
    (* src = "src/uart.spade:73,25" *)
    logic[17:0] _e_1730;
    (* src = "src/uart.spade:75,32" *)
    logic[1:0] _e_1738;
    (* src = "src/uart.spade:75,42" *)
    logic[7:0] _e_1740;
    (* src = "src/uart.spade:75,49" *)
    logic[3:0] _e_1742;
    (* src = "src/uart.spade:75,25" *)
    logic[17:0] _e_1737;
    (* src = "src/uart.spade:72,21" *)
    logic[17:0] _e_1727;
    (* src = "src/uart.spade:78,17" *)
    logic[1:0] _e_1745;
    logic _e_7909;
    (* src = "src/uart.spade:81,28" *)
    logic[3:0] _e_1752;
    (* src = "src/uart.spade:81,28" *)
    logic _e_1751;
    (* src = "src/uart.spade:82,36" *)
    logic[1:0] _e_1757;
    (* src = "src/uart.spade:82,51" *)
    logic[7:0] _e_1758;
    (* src = "src/uart.spade:82,29" *)
    logic[17:0] _e_1756;
    (* src = "src/uart.spade:84,36" *)
    logic[1:0] _e_1764;
    (* src = "src/uart.spade:84,51" *)
    logic[7:0] _e_1766;
    (* src = "src/uart.spade:84,51" *)
    logic[7:0] _e_1765;
    (* src = "src/uart.spade:84,69" *)
    logic[3:0] _e_1771;
    (* src = "src/uart.spade:84,69" *)
    logic[4:0] _e_1770;
    (* src = "src/uart.spade:84,63" *)
    logic[3:0] _e_1769;
    (* src = "src/uart.spade:84,29" *)
    logic[17:0] _e_1763;
    (* src = "src/uart.spade:81,25" *)
    logic[17:0] _e_1750;
    (* src = "src/uart.spade:87,32" *)
    logic[1:0] _e_1777;
    (* src = "src/uart.spade:87,42" *)
    logic[7:0] _e_1779;
    (* src = "src/uart.spade:87,49" *)
    logic[3:0] _e_1781;
    (* src = "src/uart.spade:87,25" *)
    logic[17:0] _e_1776;
    (* src = "src/uart.spade:79,21" *)
    logic[17:0] _e_1747;
    (* src = "src/uart.spade:90,17" *)
    logic[1:0] _e_1784;
    logic _e_7911;
    (* src = "src/uart.spade:92,32" *)
    logic[1:0] _e_1790;
    (* src = "src/uart.spade:92,25" *)
    logic[17:0] _e_1789;
    (* src = "src/uart.spade:94,32" *)
    logic[1:0] _e_1796;
    (* src = "src/uart.spade:94,42" *)
    logic[7:0] _e_1798;
    (* src = "src/uart.spade:94,49" *)
    logic[3:0] _e_1800;
    (* src = "src/uart.spade:94,25" *)
    logic[17:0] _e_1795;
    (* src = "src/uart.spade:91,21" *)
    logic[17:0] _e_1786;
    (* src = "src/uart.spade:60,13" *)
    logic[17:0] _e_1707;
    (* src = "src/uart.spade:56,9" *)
    logic[17:0] _e_1693;
    (* src = "src/uart.spade:54,14" *)
    reg[17:0] \tx ;
    (* src = "src/uart.spade:104,24" *)
    logic[1:0] _e_1806;
    (* src = "src/uart.spade:105,9" *)
    logic[1:0] _e_1808;
    logic _e_7913;
    (* src = "src/uart.spade:106,9" *)
    logic[1:0] _e_1810;
    logic _e_7915;
    (* src = "src/uart.spade:107,9" *)
    logic[1:0] _e_1812;
    logic _e_7917;
    (* src = "src/uart.spade:107,27" *)
    logic[7:0] _e_1815;
    (* src = "src/uart.spade:107,26" *)
    logic[7:0] _e_1814;
    (* src = "src/uart.spade:107,26" *)
    logic _e_1813;
    (* src = "src/uart.spade:108,9" *)
    logic[1:0] _e_1819;
    logic _e_7919;
    (* src = "src/uart.spade:104,18" *)
    logic \tx_out ;
    (* src = "src/uart.spade:111,25" *)
    logic[1:0] _e_1823;
    (* src = "src/uart.spade:112,9" *)
    logic[1:0] _e_1825;
    logic _e_7921;
    (* src = "src/uart.spade:113,9" *)
    logic[1:0] \_ ;
    (* src = "src/uart.spade:111,19" *)
    logic \tx_busy ;
    (* src = "src/uart.spade:120,14" *)
    reg \rx_sync1 ;
    (* src = "src/uart.spade:121,14" *)
    reg \rx_sync2 ;
    (* src = "src/uart.spade:122,9" *)
    logic \rxd ;
    (* src = "src/uart.spade:124,43" *)
    logic[1:0] _e_1847;
    (* src = "src/uart.spade:124,36" *)
    logic[16:0] _e_1846;
    (* src = "src/uart.spade:126,19" *)
    logic[1:0] _e_1856;
    (* src = "src/uart.spade:127,17" *)
    logic[1:0] _e_1858;
    logic _e_7924;
    (* src = "src/uart.spade:128,24" *)
    logic _e_1861;
    (* src = "src/uart.spade:129,32" *)
    logic[1:0] _e_1865;
    (* src = "src/uart.spade:129,25" *)
    logic[16:0] _e_1864;
    (* src = "src/uart.spade:128,21" *)
    logic[16:0] _e_1860;
    (* src = "src/uart.spade:134,17" *)
    logic[1:0] _e_1871;
    logic _e_7926;
    (* src = "src/uart.spade:135,24" *)
    logic[3:0] _e_1875;
    (* src = "src/uart.spade:135,24" *)
    logic _e_1874;
    (* src = "src/uart.spade:136,28" *)
    logic _e_1880;
    (* src = "src/uart.spade:137,36" *)
    logic[1:0] _e_1884;
    (* src = "src/uart.spade:137,29" *)
    logic[16:0] _e_1883;
    (* src = "src/uart.spade:139,36" *)
    logic[1:0] _e_1890;
    (* src = "src/uart.spade:139,29" *)
    logic[16:0] _e_1889;
    (* src = "src/uart.spade:136,25" *)
    logic[16:0] _e_1879;
    (* src = "src/uart.spade:142,32" *)
    logic[1:0] _e_1896;
    (* src = "src/uart.spade:142,42" *)
    logic[7:0] _e_1898;
    (* src = "src/uart.spade:142,49" *)
    logic[2:0] _e_1900;
    (* src = "src/uart.spade:142,67" *)
    logic[3:0] _e_1904;
    (* src = "src/uart.spade:142,67" *)
    logic[4:0] _e_1903;
    (* src = "src/uart.spade:142,61" *)
    logic[3:0] _e_1902;
    (* src = "src/uart.spade:142,25" *)
    logic[16:0] _e_1895;
    (* src = "src/uart.spade:135,21" *)
    logic[16:0] _e_1873;
    (* src = "src/uart.spade:145,17" *)
    logic[1:0] _e_1907;
    logic _e_7928;
    (* src = "src/uart.spade:146,24" *)
    logic[3:0] _e_1911;
    (* src = "src/uart.spade:146,24" *)
    logic _e_1910;
    (* src = "src/uart.spade:150,40" *)
    logic[7:0] _e_1917;
    (* src = "src/uart.spade:150,39" *)
    logic[7:0] _e_1916;
    (* src = "src/uart.spade:150,54" *)
    logic[7:0] _e_1920;
    (* src = "src/uart.spade:150,39" *)
    logic[7:0] \next_sh ;
    (* src = "src/uart.spade:152,28" *)
    logic[2:0] _e_1929;
    (* src = "src/uart.spade:152,28" *)
    logic _e_1928;
    (* src = "src/uart.spade:153,36" *)
    logic[1:0] _e_1934;
    (* src = "src/uart.spade:153,29" *)
    logic[16:0] _e_1933;
    (* src = "src/uart.spade:155,36" *)
    logic[1:0] _e_1940;
    (* src = "src/uart.spade:155,66" *)
    logic[2:0] _e_1944;
    (* src = "src/uart.spade:155,66" *)
    logic[3:0] _e_1943;
    (* src = "src/uart.spade:155,60" *)
    logic[2:0] _e_1942;
    (* src = "src/uart.spade:155,29" *)
    logic[16:0] _e_1939;
    (* src = "src/uart.spade:152,25" *)
    logic[16:0] _e_1927;
    (* src = "src/uart.spade:158,32" *)
    logic[1:0] _e_1950;
    (* src = "src/uart.spade:158,42" *)
    logic[7:0] _e_1952;
    (* src = "src/uart.spade:158,49" *)
    logic[2:0] _e_1954;
    (* src = "src/uart.spade:158,67" *)
    logic[3:0] _e_1958;
    (* src = "src/uart.spade:158,67" *)
    logic[4:0] _e_1957;
    (* src = "src/uart.spade:158,61" *)
    logic[3:0] _e_1956;
    (* src = "src/uart.spade:158,25" *)
    logic[16:0] _e_1949;
    (* src = "src/uart.spade:146,21" *)
    logic[16:0] _e_1909;
    (* src = "src/uart.spade:161,17" *)
    logic[1:0] _e_1961;
    logic _e_7930;
    (* src = "src/uart.spade:162,24" *)
    logic[3:0] _e_1965;
    (* src = "src/uart.spade:162,24" *)
    logic _e_1964;
    (* src = "src/uart.spade:164,32" *)
    logic[1:0] _e_1970;
    (* src = "src/uart.spade:164,47" *)
    logic[7:0] _e_1971;
    (* src = "src/uart.spade:164,25" *)
    logic[16:0] _e_1969;
    (* src = "src/uart.spade:166,32" *)
    logic[1:0] _e_1977;
    (* src = "src/uart.spade:166,42" *)
    logic[7:0] _e_1979;
    (* src = "src/uart.spade:166,49" *)
    logic[2:0] _e_1981;
    (* src = "src/uart.spade:166,67" *)
    logic[3:0] _e_1985;
    (* src = "src/uart.spade:166,67" *)
    logic[4:0] _e_1984;
    (* src = "src/uart.spade:166,61" *)
    logic[3:0] _e_1983;
    (* src = "src/uart.spade:166,25" *)
    logic[16:0] _e_1976;
    (* src = "src/uart.spade:162,21" *)
    logic[16:0] _e_1963;
    (* src = "src/uart.spade:126,13" *)
    logic[16:0] _e_1855;
    (* src = "src/uart.spade:125,9" *)
    logic[16:0] _e_1852;
    (* src = "src/uart.spade:124,14" *)
    reg[16:0] \rx ;
    (* src = "src/uart.spade:177,36" *)
    logic[1:0] _e_1993;
    (* src = "src/uart.spade:178,9" *)
    logic[1:0] _e_1995;
    logic _e_7932;
    (* src = "src/uart.spade:178,26" *)
    logic[3:0] _e_1997;
    (* src = "src/uart.spade:178,26" *)
    logic _e_1996;
    (* src = "src/uart.spade:179,9" *)
    logic[1:0] __n1;
    (* src = "src/uart.spade:177,30" *)
    logic _e_1992;
    (* src = "src/uart.spade:177,20" *)
    logic \rx_valid ;
    (* src = "src/uart.spade:182,38" *)
    logic[7:0] _e_2007;
    (* src = "src/uart.spade:182,33" *)
    logic[8:0] _e_2006;
    (* src = "src/uart.spade:182,54" *)
    logic[8:0] _e_2010;
    (* src = "src/uart.spade:182,19" *)
    logic[8:0] \rx_data ;
    (* src = "src/uart.spade:184,5" *)
    logic[10:0] _e_2012;
    assign _e_1688 = {2'd0};
    localparam[7:0] _e_1689 = 0;
    localparam[3:0] _e_1690 = 0;
    localparam[3:0] _e_1691 = 0;
    assign _e_1687 = {_e_1688, _e_1689, _e_1690, _e_1691};
    assign _e_1698 = \tx [3:0];
    localparam[3:0] _e_1700 = 1;
    assign _e_1697 = _e_1698 + _e_1700;
    assign \next_tick  = _e_1697[3:0];
    assign _e_1703 = \tx [3:0];
    localparam[3:0] _e_1705 = 15;
    assign \baud_tick  = _e_1703 == _e_1705;
    assign _e_1708 = \tx [17:16];
    assign _e_1710 = _e_1708;
    assign _e_7899 = _e_1708[1:0] == 2'd0;
    assign _e_1713 = \tx_data ;
    assign _e_1716 = _e_1713;
    assign \data  = _e_1713[7:0];
    assign _e_7901 = _e_1713[8] == 1'd1;
    localparam[0:0] _e_7902 = 1;
    assign _e_7903 = _e_7901 && _e_7902;
    assign _e_1719 = {2'd1};
    localparam[3:0] _e_1721 = 0;
    localparam[3:0] _e_1722 = 0;
    assign _e_1718 = {_e_1719, \data , _e_1721, _e_1722};
    assign _e_1723 = _e_1713;
    assign _e_7905 = _e_1713[8] == 1'd0;
    always_comb begin
        priority casez ({_e_7903, _e_7905})
            2'b1?: _e_1712 = _e_1718;
            2'b01: _e_1712 = \tx ;
            2'b?: _e_1712 = 18'dx;
        endcase
    end
    assign _e_1725 = _e_1708;
    assign _e_7907 = _e_1708[1:0] == 2'd1;
    assign _e_1731 = {2'd2};
    assign _e_1732 = \tx [15:8];
    localparam[3:0] _e_1734 = 0;
    localparam[3:0] _e_1735 = 0;
    assign _e_1730 = {_e_1731, _e_1732, _e_1734, _e_1735};
    assign _e_1738 = \tx [17:16];
    assign _e_1740 = \tx [15:8];
    assign _e_1742 = \tx [7:4];
    assign _e_1737 = {_e_1738, _e_1740, _e_1742, \next_tick };
    assign _e_1727 = \baud_tick  ? _e_1730 : _e_1737;
    assign _e_1745 = _e_1708;
    assign _e_7909 = _e_1708[1:0] == 2'd2;
    assign _e_1752 = \tx [7:4];
    localparam[3:0] _e_1754 = 7;
    assign _e_1751 = _e_1752 == _e_1754;
    assign _e_1757 = {2'd3};
    assign _e_1758 = \tx [15:8];
    localparam[3:0] _e_1760 = 0;
    localparam[3:0] _e_1761 = 0;
    assign _e_1756 = {_e_1757, _e_1758, _e_1760, _e_1761};
    assign _e_1764 = {2'd2};
    assign _e_1766 = \tx [15:8];
    localparam[7:0] _e_1768 = 1;
    assign _e_1765 = _e_1766 >> _e_1768;
    assign _e_1771 = \tx [7:4];
    localparam[3:0] _e_1773 = 1;
    assign _e_1770 = _e_1771 + _e_1773;
    assign _e_1769 = _e_1770[3:0];
    localparam[3:0] _e_1774 = 0;
    assign _e_1763 = {_e_1764, _e_1765, _e_1769, _e_1774};
    assign _e_1750 = _e_1751 ? _e_1756 : _e_1763;
    assign _e_1777 = \tx [17:16];
    assign _e_1779 = \tx [15:8];
    assign _e_1781 = \tx [7:4];
    assign _e_1776 = {_e_1777, _e_1779, _e_1781, \next_tick };
    assign _e_1747 = \baud_tick  ? _e_1750 : _e_1776;
    assign _e_1784 = _e_1708;
    assign _e_7911 = _e_1708[1:0] == 2'd3;
    assign _e_1790 = {2'd0};
    localparam[7:0] _e_1791 = 0;
    localparam[3:0] _e_1792 = 0;
    localparam[3:0] _e_1793 = 0;
    assign _e_1789 = {_e_1790, _e_1791, _e_1792, _e_1793};
    assign _e_1796 = \tx [17:16];
    assign _e_1798 = \tx [15:8];
    assign _e_1800 = \tx [7:4];
    assign _e_1795 = {_e_1796, _e_1798, _e_1800, \next_tick };
    assign _e_1786 = \baud_tick  ? _e_1789 : _e_1795;
    always_comb begin
        priority casez ({_e_7899, _e_7907, _e_7909, _e_7911})
            4'b1???: _e_1707 = _e_1712;
            4'b01??: _e_1707 = _e_1727;
            4'b001?: _e_1707 = _e_1747;
            4'b0001: _e_1707 = _e_1786;
            4'b?: _e_1707 = 18'dx;
        endcase
    end
    assign _e_1693 = \tick16  ? _e_1707 : \tx ;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \tx  <= _e_1687;
        end
        else begin
            \tx  <= _e_1693;
        end
    end
    assign _e_1806 = \tx [17:16];
    assign _e_1808 = _e_1806;
    assign _e_7913 = _e_1806[1:0] == 2'd0;
    localparam[0:0] _e_1809 = 1;
    assign _e_1810 = _e_1806;
    assign _e_7915 = _e_1806[1:0] == 2'd1;
    localparam[0:0] _e_1811 = 0;
    assign _e_1812 = _e_1806;
    assign _e_7917 = _e_1806[1:0] == 2'd2;
    assign _e_1815 = \tx [15:8];
    localparam[7:0] _e_1817 = 1;
    assign _e_1814 = _e_1815 & _e_1817;
    localparam[7:0] _e_1818 = 0;
    assign _e_1813 = _e_1814 != _e_1818;
    assign _e_1819 = _e_1806;
    assign _e_7919 = _e_1806[1:0] == 2'd3;
    localparam[0:0] _e_1820 = 1;
    always_comb begin
        priority casez ({_e_7913, _e_7915, _e_7917, _e_7919})
            4'b1???: \tx_out  = _e_1809;
            4'b01??: \tx_out  = _e_1811;
            4'b001?: \tx_out  = _e_1813;
            4'b0001: \tx_out  = _e_1820;
            4'b?: \tx_out  = 1'dx;
        endcase
    end
    assign _e_1823 = \tx [17:16];
    assign _e_1825 = _e_1823;
    assign _e_7921 = _e_1823[1:0] == 2'd0;
    localparam[0:0] _e_1826 = 0;
    assign \_  = _e_1823;
    localparam[0:0] _e_7922 = 1;
    localparam[0:0] _e_1828 = 1;
    always_comb begin
        priority casez ({_e_7921, _e_7922})
            2'b1?: \tx_busy  = _e_1826;
            2'b01: \tx_busy  = _e_1828;
            2'b?: \tx_busy  = 1'dx;
        endcase
    end
    localparam[0:0] _e_1833 = 1;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx_sync1  <= _e_1833;
        end
        else begin
            \rx_sync1  <= \rx_in ;
        end
    end
    localparam[0:0] _e_1839 = 1;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx_sync2  <= _e_1839;
        end
        else begin
            \rx_sync2  <= \rx_sync1 ;
        end
    end
    assign \rxd  = \rx_sync2 ;
    assign _e_1847 = {2'd0};
    localparam[7:0] _e_1848 = 0;
    localparam[2:0] _e_1849 = 0;
    localparam[3:0] _e_1850 = 0;
    assign _e_1846 = {_e_1847, _e_1848, _e_1849, _e_1850};
    assign _e_1856 = \rx [16:15];
    assign _e_1858 = _e_1856;
    assign _e_7924 = _e_1856[1:0] == 2'd0;
    assign _e_1861 = !\rxd ;
    assign _e_1865 = {2'd1};
    localparam[7:0] _e_1866 = 0;
    localparam[2:0] _e_1867 = 0;
    localparam[3:0] _e_1868 = 0;
    assign _e_1864 = {_e_1865, _e_1866, _e_1867, _e_1868};
    assign _e_1860 = _e_1861 ? _e_1864 : \rx ;
    assign _e_1871 = _e_1856;
    assign _e_7926 = _e_1856[1:0] == 2'd1;
    assign _e_1875 = \rx [3:0];
    localparam[3:0] _e_1877 = 7;
    assign _e_1874 = _e_1875 == _e_1877;
    assign _e_1880 = !\rxd ;
    assign _e_1884 = {2'd2};
    localparam[7:0] _e_1885 = 0;
    localparam[2:0] _e_1886 = 0;
    localparam[3:0] _e_1887 = 0;
    assign _e_1883 = {_e_1884, _e_1885, _e_1886, _e_1887};
    assign _e_1890 = {2'd0};
    localparam[7:0] _e_1891 = 0;
    localparam[2:0] _e_1892 = 0;
    localparam[3:0] _e_1893 = 0;
    assign _e_1889 = {_e_1890, _e_1891, _e_1892, _e_1893};
    assign _e_1879 = _e_1880 ? _e_1883 : _e_1889;
    assign _e_1896 = \rx [16:15];
    assign _e_1898 = \rx [14:7];
    assign _e_1900 = \rx [6:4];
    assign _e_1904 = \rx [3:0];
    localparam[3:0] _e_1906 = 1;
    assign _e_1903 = _e_1904 + _e_1906;
    assign _e_1902 = _e_1903[3:0];
    assign _e_1895 = {_e_1896, _e_1898, _e_1900, _e_1902};
    assign _e_1873 = _e_1874 ? _e_1879 : _e_1895;
    assign _e_1907 = _e_1856;
    assign _e_7928 = _e_1856[1:0] == 2'd2;
    assign _e_1911 = \rx [3:0];
    localparam[3:0] _e_1913 = 15;
    assign _e_1910 = _e_1911 == _e_1913;
    assign _e_1917 = \rx [14:7];
    localparam[7:0] _e_1919 = 1;
    assign _e_1916 = _e_1917 >> _e_1919;
    localparam[7:0] _e_1923 = 128;
    localparam[7:0] _e_1925 = 0;
    assign _e_1920 = \rxd  ? _e_1923 : _e_1925;
    assign \next_sh  = _e_1916 | _e_1920;
    assign _e_1929 = \rx [6:4];
    localparam[2:0] _e_1931 = 7;
    assign _e_1928 = _e_1929 == _e_1931;
    assign _e_1934 = {2'd3};
    localparam[2:0] _e_1936 = 0;
    localparam[3:0] _e_1937 = 0;
    assign _e_1933 = {_e_1934, \next_sh , _e_1936, _e_1937};
    assign _e_1940 = {2'd2};
    assign _e_1944 = \rx [6:4];
    localparam[2:0] _e_1946 = 1;
    assign _e_1943 = _e_1944 + _e_1946;
    assign _e_1942 = _e_1943[2:0];
    localparam[3:0] _e_1947 = 0;
    assign _e_1939 = {_e_1940, \next_sh , _e_1942, _e_1947};
    assign _e_1927 = _e_1928 ? _e_1933 : _e_1939;
    assign _e_1950 = \rx [16:15];
    assign _e_1952 = \rx [14:7];
    assign _e_1954 = \rx [6:4];
    assign _e_1958 = \rx [3:0];
    localparam[3:0] _e_1960 = 1;
    assign _e_1957 = _e_1958 + _e_1960;
    assign _e_1956 = _e_1957[3:0];
    assign _e_1949 = {_e_1950, _e_1952, _e_1954, _e_1956};
    assign _e_1909 = _e_1910 ? _e_1927 : _e_1949;
    assign _e_1961 = _e_1856;
    assign _e_7930 = _e_1856[1:0] == 2'd3;
    assign _e_1965 = \rx [3:0];
    localparam[3:0] _e_1967 = 15;
    assign _e_1964 = _e_1965 == _e_1967;
    assign _e_1970 = {2'd0};
    assign _e_1971 = \rx [14:7];
    localparam[2:0] _e_1973 = 0;
    localparam[3:0] _e_1974 = 0;
    assign _e_1969 = {_e_1970, _e_1971, _e_1973, _e_1974};
    assign _e_1977 = \rx [16:15];
    assign _e_1979 = \rx [14:7];
    assign _e_1981 = \rx [6:4];
    assign _e_1985 = \rx [3:0];
    localparam[3:0] _e_1987 = 1;
    assign _e_1984 = _e_1985 + _e_1987;
    assign _e_1983 = _e_1984[3:0];
    assign _e_1976 = {_e_1977, _e_1979, _e_1981, _e_1983};
    assign _e_1963 = _e_1964 ? _e_1969 : _e_1976;
    always_comb begin
        priority casez ({_e_7924, _e_7926, _e_7928, _e_7930})
            4'b1???: _e_1855 = _e_1860;
            4'b01??: _e_1855 = _e_1873;
            4'b001?: _e_1855 = _e_1909;
            4'b0001: _e_1855 = _e_1963;
            4'b?: _e_1855 = 17'dx;
        endcase
    end
    assign _e_1852 = \tick16  ? _e_1855 : \rx ;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx  <= _e_1846;
        end
        else begin
            \rx  <= _e_1852;
        end
    end
    assign _e_1993 = \rx [16:15];
    assign _e_1995 = _e_1993;
    assign _e_7932 = _e_1993[1:0] == 2'd3;
    assign _e_1997 = \rx [3:0];
    localparam[3:0] _e_1999 = 15;
    assign _e_1996 = _e_1997 == _e_1999;
    assign __n1 = _e_1993;
    localparam[0:0] _e_7933 = 1;
    localparam[0:0] _e_2001 = 0;
    always_comb begin
        priority casez ({_e_7932, _e_7933})
            2'b1?: _e_1992 = _e_1996;
            2'b01: _e_1992 = _e_2001;
            2'b?: _e_1992 = 1'dx;
        endcase
    end
    assign \rx_valid  = \tick16  && _e_1992;
    assign _e_2007 = \rx [14:7];
    assign _e_2006 = {1'd1, _e_2007};
    assign _e_2010 = {1'd0, 8'bX};
    assign \rx_data  = \rx_valid  ? _e_2006 : _e_2010;
    assign _e_2012 = {\tx_out , \rx_data , \tx_busy };
    assign output__ = _e_2012;
endmodule

module \tta::alu::alu_fu  (
        input clk_i,
        input rst_i,
        input[32:0] set_op_a_i,
        input[37:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::alu_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::alu_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_op_a ;
    assign \set_op_a  = set_op_a_i;
    logic[37:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/alu.spade:24,9" *)
    logic[31:0] \v ;
    logic _e_7935;
    logic _e_7937;
    logic _e_7939;
    (* src = "src/alu.spade:23,45" *)
    logic[31:0] _e_2021;
    (* src = "src/alu.spade:23,14" *)
    reg[31:0] \op_a ;
    (* src = "src/alu.spade:31,9" *)
    logic[36:0] _e_2032;
    (* src = "src/alu.spade:31,14" *)
    logic[4:0] _e_2030;
    (* src = "src/alu.spade:31,14" *)
    logic[31:0] \b ;
    logic _e_7941;
    logic _e_7944;
    logic _e_7946;
    logic _e_7947;
    (* src = "src/alu.spade:31,45" *)
    logic[32:0] _e_2036;
    (* src = "src/alu.spade:31,39" *)
    logic[31:0] _e_2035;
    (* src = "src/alu.spade:31,34" *)
    logic[32:0] _e_2034;
    (* src = "src/alu.spade:32,9" *)
    logic[36:0] _e_2041;
    (* src = "src/alu.spade:32,14" *)
    logic[4:0] _e_2039;
    (* src = "src/alu.spade:32,14" *)
    logic[31:0] b_n1;
    logic _e_7949;
    logic _e_7952;
    logic _e_7954;
    logic _e_7955;
    (* src = "src/alu.spade:32,45" *)
    logic[32:0] _e_2045;
    (* src = "src/alu.spade:32,39" *)
    logic[31:0] _e_2044;
    (* src = "src/alu.spade:32,34" *)
    logic[32:0] _e_2043;
    (* src = "src/alu.spade:33,9" *)
    logic[36:0] _e_2050;
    (* src = "src/alu.spade:33,14" *)
    logic[4:0] _e_2048;
    (* src = "src/alu.spade:33,14" *)
    logic[31:0] b_n2;
    logic _e_7957;
    logic _e_7960;
    logic _e_7962;
    logic _e_7963;
    (* src = "src/alu.spade:33,39" *)
    logic[31:0] _e_2053;
    (* src = "src/alu.spade:33,34" *)
    logic[32:0] _e_2052;
    (* src = "src/alu.spade:34,9" *)
    logic[36:0] _e_2058;
    (* src = "src/alu.spade:34,14" *)
    logic[4:0] _e_2056;
    (* src = "src/alu.spade:34,14" *)
    logic[31:0] b_n3;
    logic _e_7965;
    logic _e_7968;
    logic _e_7970;
    logic _e_7971;
    (* src = "src/alu.spade:34,39" *)
    logic[31:0] _e_2061;
    (* src = "src/alu.spade:34,34" *)
    logic[32:0] _e_2060;
    (* src = "src/alu.spade:35,9" *)
    logic[36:0] _e_2066;
    (* src = "src/alu.spade:35,14" *)
    logic[4:0] _e_2064;
    (* src = "src/alu.spade:35,14" *)
    logic[31:0] b_n4;
    logic _e_7973;
    logic _e_7976;
    logic _e_7978;
    logic _e_7979;
    (* src = "src/alu.spade:35,40" *)
    logic[31:0] _e_2069;
    (* src = "src/alu.spade:35,35" *)
    logic[32:0] _e_2068;
    (* src = "src/alu.spade:36,9" *)
    logic[36:0] _e_2073;
    (* src = "src/alu.spade:36,14" *)
    logic[4:0] _e_2071;
    (* src = "src/alu.spade:36,14" *)
    logic[31:0] b_n5;
    logic _e_7981;
    logic _e_7984;
    logic _e_7986;
    logic _e_7987;
    (* src = "src/alu.spade:36,39" *)
    logic[31:0] _e_2076;
    (* src = "src/alu.spade:36,34" *)
    logic[32:0] _e_2075;
    (* src = "src/alu.spade:37,9" *)
    logic[36:0] _e_2081;
    (* src = "src/alu.spade:37,14" *)
    logic[4:0] _e_2079;
    (* src = "src/alu.spade:37,14" *)
    logic[31:0] b_n6;
    logic _e_7989;
    logic _e_7992;
    logic _e_7994;
    logic _e_7995;
    (* src = "src/alu.spade:37,45" *)
    logic[31:0] _e_2085;
    (* src = "src/alu.spade:37,39" *)
    logic[31:0] _e_2084;
    (* src = "src/alu.spade:37,34" *)
    logic[32:0] _e_2083;
    (* src = "src/alu.spade:38,9" *)
    logic[36:0] _e_2090;
    (* src = "src/alu.spade:38,14" *)
    logic[4:0] _e_2088;
    (* src = "src/alu.spade:38,14" *)
    logic[31:0] b_n7;
    logic _e_7997;
    logic _e_8000;
    logic _e_8002;
    logic _e_8003;
    (* src = "src/alu.spade:38,45" *)
    logic[31:0] _e_2094;
    (* src = "src/alu.spade:38,39" *)
    logic[31:0] _e_2093;
    (* src = "src/alu.spade:38,34" *)
    logic[32:0] _e_2092;
    (* src = "src/alu.spade:39,9" *)
    logic[36:0] _e_2099;
    (* src = "src/alu.spade:39,14" *)
    logic[4:0] _e_2097;
    (* src = "src/alu.spade:39,14" *)
    logic[31:0] b_n8;
    logic _e_8005;
    logic _e_8008;
    logic _e_8010;
    logic _e_8011;
    (* src = "src/alu.spade:39,40" *)
    logic[31:0] _e_2102;
    (* src = "src/alu.spade:39,35" *)
    logic[32:0] _e_2101;
    (* src = "src/alu.spade:40,9" *)
    logic[36:0] _e_2107;
    (* src = "src/alu.spade:40,14" *)
    logic[4:0] _e_2105;
    (* src = "src/alu.spade:40,14" *)
    logic[31:0] b_n9;
    logic _e_8013;
    logic _e_8016;
    logic _e_8018;
    logic _e_8019;
    (* src = "src/alu.spade:40,40" *)
    logic[31:0] _e_2110;
    (* src = "src/alu.spade:40,35" *)
    logic[32:0] _e_2109;
    (* src = "src/alu.spade:41,9" *)
    logic[36:0] _e_2115;
    (* src = "src/alu.spade:41,14" *)
    logic[4:0] _e_2113;
    (* src = "src/alu.spade:41,14" *)
    logic[31:0] b_n10;
    logic _e_8021;
    logic _e_8024;
    logic _e_8026;
    logic _e_8027;
    (* src = "src/alu.spade:41,40" *)
    logic[31:0] _e_2118;
    (* src = "src/alu.spade:41,35" *)
    logic[32:0] _e_2117;
    (* src = "src/alu.spade:44,9" *)
    logic[36:0] _e_2123;
    (* src = "src/alu.spade:44,14" *)
    logic[4:0] _e_2121;
    (* src = "src/alu.spade:44,14" *)
    logic[31:0] b_n11;
    logic _e_8029;
    logic _e_8032;
    logic _e_8034;
    logic _e_8035;
    (* src = "src/alu.spade:44,42" *)
    logic _e_2127;
    (* src = "src/alu.spade:44,39" *)
    logic[31:0] _e_2126;
    (* src = "src/alu.spade:44,34" *)
    logic[32:0] _e_2125;
    (* src = "src/alu.spade:45,9" *)
    logic[36:0] _e_2136;
    (* src = "src/alu.spade:45,14" *)
    logic[4:0] _e_2134;
    (* src = "src/alu.spade:45,14" *)
    logic[31:0] b_n12;
    logic _e_8037;
    logic _e_8040;
    logic _e_8042;
    logic _e_8043;
    (* src = "src/alu.spade:45,42" *)
    logic _e_2140;
    (* src = "src/alu.spade:45,39" *)
    logic[31:0] _e_2139;
    (* src = "src/alu.spade:45,34" *)
    logic[32:0] _e_2138;
    (* src = "src/alu.spade:48,9" *)
    logic[36:0] _e_2149;
    (* src = "src/alu.spade:48,14" *)
    logic[4:0] _e_2147;
    (* src = "src/alu.spade:48,14" *)
    logic[31:0] b_n13;
    logic _e_8045;
    logic _e_8048;
    logic _e_8050;
    logic _e_8051;
    (* src = "src/alu.spade:48,41" *)
    logic[31:0] _e_2152;
    (* src = "src/alu.spade:48,36" *)
    logic[32:0] _e_2151;
    (* src = "src/alu.spade:49,9" *)
    logic[36:0] _e_2157;
    (* src = "src/alu.spade:49,14" *)
    logic[4:0] _e_2155;
    (* src = "src/alu.spade:49,14" *)
    logic[31:0] b_n14;
    logic _e_8053;
    logic _e_8056;
    logic _e_8058;
    logic _e_8059;
    (* src = "src/alu.spade:49,41" *)
    logic[31:0] _e_2160;
    (* src = "src/alu.spade:49,36" *)
    logic[32:0] _e_2159;
    (* src = "src/alu.spade:52,9" *)
    logic[36:0] _e_2165;
    (* src = "src/alu.spade:52,14" *)
    logic[4:0] _e_2163;
    (* src = "src/alu.spade:52,14" *)
    logic[31:0] b_n15;
    logic _e_8061;
    logic _e_8064;
    logic _e_8066;
    logic _e_8067;
    (* src = "src/alu.spade:52,41" *)
    logic[31:0] _e_2168;
    (* src = "src/alu.spade:52,36" *)
    logic[32:0] _e_2167;
    (* src = "src/alu.spade:53,9" *)
    logic[36:0] _e_2173;
    (* src = "src/alu.spade:53,14" *)
    logic[4:0] _e_2171;
    (* src = "src/alu.spade:53,14" *)
    logic[31:0] b_n16;
    logic _e_8069;
    logic _e_8072;
    logic _e_8074;
    logic _e_8075;
    (* src = "src/alu.spade:53,41" *)
    logic[31:0] _e_2176;
    (* src = "src/alu.spade:53,36" *)
    logic[32:0] _e_2175;
    logic _e_8077;
    (* src = "src/alu.spade:55,17" *)
    logic[32:0] _e_2180;
    (* src = "src/alu.spade:29,36" *)
    logic[32:0] \result ;
    (* src = "src/alu.spade:59,51" *)
    logic[32:0] _e_2185;
    (* src = "src/alu.spade:59,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2020 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_7935 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_7936 = 1;
    assign _e_7937 = _e_7935 && _e_7936;
    assign _e_7939 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_7937, _e_7939})
            2'b1?: _e_2021 = \v ;
            2'b01: _e_2021 = \op_a ;
            2'b?: _e_2021 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_2020;
        end
        else begin
            \op_a  <= _e_2021;
        end
    end
    assign _e_2032 = \trig [36:0];
    assign _e_2030 = _e_2032[36:32];
    assign \b  = _e_2032[31:0];
    assign _e_7941 = \trig [37] == 1'd1;
    assign _e_7944 = _e_2030[4:0] == 5'd0;
    localparam[0:0] _e_7945 = 1;
    assign _e_7946 = _e_7944 && _e_7945;
    assign _e_7947 = _e_7941 && _e_7946;
    assign _e_2036 = \op_a  + \b ;
    assign _e_2035 = _e_2036[31:0];
    assign _e_2034 = {1'd1, _e_2035};
    assign _e_2041 = \trig [36:0];
    assign _e_2039 = _e_2041[36:32];
    assign b_n1 = _e_2041[31:0];
    assign _e_7949 = \trig [37] == 1'd1;
    assign _e_7952 = _e_2039[4:0] == 5'd1;
    localparam[0:0] _e_7953 = 1;
    assign _e_7954 = _e_7952 && _e_7953;
    assign _e_7955 = _e_7949 && _e_7954;
    assign _e_2045 = \op_a  - b_n1;
    assign _e_2044 = _e_2045[31:0];
    assign _e_2043 = {1'd1, _e_2044};
    assign _e_2050 = \trig [36:0];
    assign _e_2048 = _e_2050[36:32];
    assign b_n2 = _e_2050[31:0];
    assign _e_7957 = \trig [37] == 1'd1;
    assign _e_7960 = _e_2048[4:0] == 5'd2;
    localparam[0:0] _e_7961 = 1;
    assign _e_7962 = _e_7960 && _e_7961;
    assign _e_7963 = _e_7957 && _e_7962;
    assign _e_2053 = \op_a  & b_n2;
    assign _e_2052 = {1'd1, _e_2053};
    assign _e_2058 = \trig [36:0];
    assign _e_2056 = _e_2058[36:32];
    assign b_n3 = _e_2058[31:0];
    assign _e_7965 = \trig [37] == 1'd1;
    assign _e_7968 = _e_2056[4:0] == 5'd3;
    localparam[0:0] _e_7969 = 1;
    assign _e_7970 = _e_7968 && _e_7969;
    assign _e_7971 = _e_7965 && _e_7970;
    assign _e_2061 = \op_a  | b_n3;
    assign _e_2060 = {1'd1, _e_2061};
    assign _e_2066 = \trig [36:0];
    assign _e_2064 = _e_2066[36:32];
    assign b_n4 = _e_2066[31:0];
    assign _e_7973 = \trig [37] == 1'd1;
    assign _e_7976 = _e_2064[4:0] == 5'd4;
    localparam[0:0] _e_7977 = 1;
    assign _e_7978 = _e_7976 && _e_7977;
    assign _e_7979 = _e_7973 && _e_7978;
    assign _e_2069 = ~b_n4;
    assign _e_2068 = {1'd1, _e_2069};
    assign _e_2073 = \trig [36:0];
    assign _e_2071 = _e_2073[36:32];
    assign b_n5 = _e_2073[31:0];
    assign _e_7981 = \trig [37] == 1'd1;
    assign _e_7984 = _e_2071[4:0] == 5'd5;
    localparam[0:0] _e_7985 = 1;
    assign _e_7986 = _e_7984 && _e_7985;
    assign _e_7987 = _e_7981 && _e_7986;
    assign _e_2076 = \op_a  ^ b_n5;
    assign _e_2075 = {1'd1, _e_2076};
    assign _e_2081 = \trig [36:0];
    assign _e_2079 = _e_2081[36:32];
    assign b_n6 = _e_2081[31:0];
    assign _e_7989 = \trig [37] == 1'd1;
    assign _e_7992 = _e_2079[4:0] == 5'd6;
    localparam[0:0] _e_7993 = 1;
    assign _e_7994 = _e_7992 && _e_7993;
    assign _e_7995 = _e_7989 && _e_7994;
    assign _e_2085 = \op_a  << b_n6;
    assign _e_2084 = _e_2085[31:0];
    assign _e_2083 = {1'd1, _e_2084};
    assign _e_2090 = \trig [36:0];
    assign _e_2088 = _e_2090[36:32];
    assign b_n7 = _e_2090[31:0];
    assign _e_7997 = \trig [37] == 1'd1;
    assign _e_8000 = _e_2088[4:0] == 5'd7;
    localparam[0:0] _e_8001 = 1;
    assign _e_8002 = _e_8000 && _e_8001;
    assign _e_8003 = _e_7997 && _e_8002;
    assign _e_2094 = \op_a  >> b_n7;
    assign _e_2093 = _e_2094[31:0];
    assign _e_2092 = {1'd1, _e_2093};
    assign _e_2099 = \trig [36:0];
    assign _e_2097 = _e_2099[36:32];
    assign b_n8 = _e_2099[31:0];
    assign _e_8005 = \trig [37] == 1'd1;
    assign _e_8008 = _e_2097[4:0] == 5'd8;
    localparam[0:0] _e_8009 = 1;
    assign _e_8010 = _e_8008 && _e_8009;
    assign _e_8011 = _e_8005 && _e_8010;
    (* src = "src/alu.spade:39,40" *)
    \tta::alu::ashr32  ashr32_0(.x_i(\op_a ), .sh_i(b_n8), .output__(_e_2102));
    assign _e_2101 = {1'd1, _e_2102};
    assign _e_2107 = \trig [36:0];
    assign _e_2105 = _e_2107[36:32];
    assign b_n9 = _e_2107[31:0];
    assign _e_8013 = \trig [37] == 1'd1;
    assign _e_8016 = _e_2105[4:0] == 5'd9;
    localparam[0:0] _e_8017 = 1;
    assign _e_8018 = _e_8016 && _e_8017;
    assign _e_8019 = _e_8013 && _e_8018;
    (* src = "src/alu.spade:40,40" *)
    \tta::alu::rotl32  rotl32_0(.x_i(\op_a ), .sh32_i(b_n9), .output__(_e_2110));
    assign _e_2109 = {1'd1, _e_2110};
    assign _e_2115 = \trig [36:0];
    assign _e_2113 = _e_2115[36:32];
    assign b_n10 = _e_2115[31:0];
    assign _e_8021 = \trig [37] == 1'd1;
    assign _e_8024 = _e_2113[4:0] == 5'd10;
    localparam[0:0] _e_8025 = 1;
    assign _e_8026 = _e_8024 && _e_8025;
    assign _e_8027 = _e_8021 && _e_8026;
    (* src = "src/alu.spade:41,40" *)
    \tta::alu::rotr32  rotr32_0(.x_i(\op_a ), .sh32_i(b_n10), .output__(_e_2118));
    assign _e_2117 = {1'd1, _e_2118};
    assign _e_2123 = \trig [36:0];
    assign _e_2121 = _e_2123[36:32];
    assign b_n11 = _e_2123[31:0];
    assign _e_8029 = \trig [37] == 1'd1;
    assign _e_8032 = _e_2121[4:0] == 5'd11;
    localparam[0:0] _e_8033 = 1;
    assign _e_8034 = _e_8032 && _e_8033;
    assign _e_8035 = _e_8029 && _e_8034;
    assign _e_2127 = \op_a  < b_n11;
    assign _e_2126 = _e_2127 ? \op_a  : b_n11;
    assign _e_2125 = {1'd1, _e_2126};
    assign _e_2136 = \trig [36:0];
    assign _e_2134 = _e_2136[36:32];
    assign b_n12 = _e_2136[31:0];
    assign _e_8037 = \trig [37] == 1'd1;
    assign _e_8040 = _e_2134[4:0] == 5'd12;
    localparam[0:0] _e_8041 = 1;
    assign _e_8042 = _e_8040 && _e_8041;
    assign _e_8043 = _e_8037 && _e_8042;
    assign _e_2140 = \op_a  > b_n12;
    assign _e_2139 = _e_2140 ? \op_a  : b_n12;
    assign _e_2138 = {1'd1, _e_2139};
    assign _e_2149 = \trig [36:0];
    assign _e_2147 = _e_2149[36:32];
    assign b_n13 = _e_2149[31:0];
    assign _e_8045 = \trig [37] == 1'd1;
    assign _e_8048 = _e_2147[4:0] == 5'd13;
    localparam[0:0] _e_8049 = 1;
    assign _e_8050 = _e_8048 && _e_8049;
    assign _e_8051 = _e_8045 && _e_8050;
    (* src = "src/alu.spade:48,41" *)
    \tta::alu::sadd32  sadd32_0(.a_u_i(\op_a ), .b_u_i(b_n13), .output__(_e_2152));
    assign _e_2151 = {1'd1, _e_2152};
    assign _e_2157 = \trig [36:0];
    assign _e_2155 = _e_2157[36:32];
    assign b_n14 = _e_2157[31:0];
    assign _e_8053 = \trig [37] == 1'd1;
    assign _e_8056 = _e_2155[4:0] == 5'd14;
    localparam[0:0] _e_8057 = 1;
    assign _e_8058 = _e_8056 && _e_8057;
    assign _e_8059 = _e_8053 && _e_8058;
    (* src = "src/alu.spade:49,41" *)
    \tta::alu::ssub32  ssub32_0(.a_u_i(\op_a ), .b_u_i(b_n14), .output__(_e_2160));
    assign _e_2159 = {1'd1, _e_2160};
    assign _e_2165 = \trig [36:0];
    assign _e_2163 = _e_2165[36:32];
    assign b_n15 = _e_2165[31:0];
    assign _e_8061 = \trig [37] == 1'd1;
    assign _e_8064 = _e_2163[4:0] == 5'd15;
    localparam[0:0] _e_8065 = 1;
    assign _e_8066 = _e_8064 && _e_8065;
    assign _e_8067 = _e_8061 && _e_8066;
    (* src = "src/alu.spade:52,41" *)
    \tta::alu::uadd32  uadd32_0(.a_i(\op_a ), .b_i(b_n15), .output__(_e_2168));
    assign _e_2167 = {1'd1, _e_2168};
    assign _e_2173 = \trig [36:0];
    assign _e_2171 = _e_2173[36:32];
    assign b_n16 = _e_2173[31:0];
    assign _e_8069 = \trig [37] == 1'd1;
    assign _e_8072 = _e_2171[4:0] == 5'd16;
    localparam[0:0] _e_8073 = 1;
    assign _e_8074 = _e_8072 && _e_8073;
    assign _e_8075 = _e_8069 && _e_8074;
    (* src = "src/alu.spade:53,41" *)
    \tta::alu::usub32  usub32_0(.a_i(\op_a ), .b_i(b_n16), .output__(_e_2176));
    assign _e_2175 = {1'd1, _e_2176};
    assign _e_8077 = \trig [37] == 1'd0;
    assign _e_2180 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_7947, _e_7955, _e_7963, _e_7971, _e_7979, _e_7987, _e_7995, _e_8003, _e_8011, _e_8019, _e_8027, _e_8035, _e_8043, _e_8051, _e_8059, _e_8067, _e_8075, _e_8077})
            18'b1?????????????????: \result  = _e_2034;
            18'b01????????????????: \result  = _e_2043;
            18'b001???????????????: \result  = _e_2052;
            18'b0001??????????????: \result  = _e_2060;
            18'b00001?????????????: \result  = _e_2068;
            18'b000001????????????: \result  = _e_2075;
            18'b0000001???????????: \result  = _e_2083;
            18'b00000001??????????: \result  = _e_2092;
            18'b000000001?????????: \result  = _e_2101;
            18'b0000000001????????: \result  = _e_2109;
            18'b00000000001???????: \result  = _e_2117;
            18'b000000000001??????: \result  = _e_2125;
            18'b0000000000001?????: \result  = _e_2138;
            18'b00000000000001????: \result  = _e_2151;
            18'b000000000000001???: \result  = _e_2159;
            18'b0000000000000001??: \result  = _e_2167;
            18'b00000000000000001?: \result  = _e_2175;
            18'b000000000000000001: \result  = _e_2180;
            18'b?: \result  = 33'dx;
        endcase
    end
    assign _e_2185 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_2185;
        end
        else begin
            \res_reg  <= \result ;
        end
    end
    assign output__ = \res_reg ;
endmodule

module \tta::alu::uadd32  (
        input[31:0] a_i,
        input[31:0] b_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::uadd32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::uadd32 );
        end
    end
    `endif
    logic[31:0] \a ;
    assign \a  = a_i;
    logic[31:0] \b ;
    assign \b  = b_i;
    logic[31:0] _e_2190;
    logic[31:0] _e_2192;
    (* src = "src/alu.spade:70,25" *)
    logic[32:0] \sum ;
    (* src = "src/alu.spade:73,8" *)
    logic _e_2196;
    (* src = "src/alu.spade:76,9" *)
    logic[31:0] _e_2202;
    (* src = "src/alu.spade:73,5" *)
    logic[31:0] _e_2195;
    assign _e_2190 = \a ;
    assign _e_2192 = \b ;
    assign \sum  = _e_2190 + _e_2192;
    localparam[32:0] _e_2198 = 33'd4294967295;
    assign _e_2196 = \sum  > _e_2198;
    localparam[31:0] _e_2200 = 32'd4294967295;
    assign _e_2202 = \sum [31:0];
    assign _e_2195 = _e_2196 ? _e_2200 : _e_2202;
    assign output__ = _e_2195;
endmodule

module \tta::alu::usub32  (
        input[31:0] a_i,
        input[31:0] b_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::usub32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::usub32 );
        end
    end
    `endif
    logic[31:0] \a ;
    assign \a  = a_i;
    logic[31:0] \b ;
    assign \b  = b_i;
    (* src = "src/alu.spade:82,8" *)
    logic _e_2206;
    (* src = "src/alu.spade:85,15" *)
    logic[32:0] _e_2213;
    (* src = "src/alu.spade:85,9" *)
    logic[31:0] _e_2212;
    (* src = "src/alu.spade:82,5" *)
    logic[31:0] _e_2205;
    assign _e_2206 = \a  < \b ;
    localparam[31:0] _e_2210 = 32'd0;
    assign _e_2213 = \a  - \b ;
    assign _e_2212 = _e_2213[31:0];
    assign _e_2205 = _e_2206 ? _e_2210 : _e_2212;
    assign output__ = _e_2205;
endmodule

module \tta::alu::sadd32  (
        input[31:0] a_u_i,
        input[31:0] b_u_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::sadd32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::sadd32 );
        end
    end
    `endif
    logic[31:0] \a_u ;
    assign \a_u  = a_u_i;
    logic[31:0] \b_u ;
    assign \b_u  = b_u_i;
    (* src = "src/alu.spade:95,22" *)
    logic[31:0] \a ;
    (* src = "src/alu.spade:96,22" *)
    logic[31:0] \b ;
    (* src = "src/alu.spade:99,26" *)
    logic[32:0] \a_big ;
    (* src = "src/alu.spade:100,26" *)
    logic[32:0] \b_big ;
    (* src = "src/alu.spade:101,15" *)
    logic[33:0] \sum ;
    (* src = "src/alu.spade:106,8" *)
    logic _e_2234;
    (* src = "src/alu.spade:108,15" *)
    logic _e_2240;
    (* src = "src/alu.spade:112,28" *)
    logic[31:0] sum_n1;
    (* src = "src/alu.spade:113,9" *)
    logic[31:0] _e_2249;
    (* src = "src/alu.spade:108,12" *)
    logic[31:0] _e_2239;
    (* src = "src/alu.spade:106,5" *)
    logic[31:0] _e_2233;
    (* src = "src/alu.spade:95,22" *)
    \std::conv::impl_4::to_int[2153]  to_int_0(.self_i(\a_u ), .output__(\a ));
    (* src = "src/alu.spade:96,22" *)
    \std::conv::impl_4::to_int[2153]  to_int_1(.self_i(\b_u ), .output__(\b ));
    assign \a_big  = {\a [31], \a };
    assign \b_big  = {\b [31], \b };
    assign \sum  = $signed(\a_big ) + $signed(\b_big );
    localparam[33:0] _e_2236 = 34'd2147483647;
    assign _e_2234 = $signed(\sum ) > $signed(_e_2236);
    localparam[31:0] _e_2238 = 32'd2147483647;
    localparam[33:0] _e_2242 = -34'd2147483648;
    assign _e_2240 = $signed(\sum ) < $signed(_e_2242);
    localparam[31:0] _e_2244 = 32'd2147483648;
    assign sum_n1 = \sum [31:0];
    (* src = "src/alu.spade:113,9" *)
    \std::conv::impl_3::to_uint[2154]  to_uint_0(.self_i(sum_n1), .output__(_e_2249));
    assign _e_2239 = _e_2240 ? _e_2244 : _e_2249;
    assign _e_2233 = _e_2234 ? _e_2238 : _e_2239;
    assign output__ = _e_2233;
endmodule

module \tta::alu::ssub32  (
        input[31:0] a_u_i,
        input[31:0] b_u_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::ssub32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::ssub32 );
        end
    end
    `endif
    logic[31:0] \a_u ;
    assign \a_u  = a_u_i;
    logic[31:0] \b_u ;
    assign \b_u  = b_u_i;
    (* src = "src/alu.spade:118,22" *)
    logic[31:0] \a ;
    (* src = "src/alu.spade:119,22" *)
    logic[31:0] \b ;
    (* src = "src/alu.spade:121,26" *)
    logic[32:0] \a_big ;
    (* src = "src/alu.spade:122,26" *)
    logic[32:0] \b_big ;
    (* src = "src/alu.spade:123,25" *)
    logic[33:0] \diff ;
    (* src = "src/alu.spade:125,8" *)
    logic _e_2269;
    (* src = "src/alu.spade:127,15" *)
    logic _e_2275;
    (* src = "src/alu.spade:130,35" *)
    logic[31:0] \trunc_diff ;
    (* src = "src/alu.spade:131,9" *)
    logic[31:0] _e_2284;
    (* src = "src/alu.spade:127,12" *)
    logic[31:0] _e_2274;
    (* src = "src/alu.spade:125,5" *)
    logic[31:0] _e_2268;
    (* src = "src/alu.spade:118,22" *)
    \std::conv::impl_4::to_int[2153]  to_int_0(.self_i(\a_u ), .output__(\a ));
    (* src = "src/alu.spade:119,22" *)
    \std::conv::impl_4::to_int[2153]  to_int_1(.self_i(\b_u ), .output__(\b ));
    assign \a_big  = {\a [31], \a };
    assign \b_big  = {\b [31], \b };
    assign \diff  = $signed(\a_big ) - $signed(\b_big );
    localparam[33:0] _e_2271 = 34'd2147483647;
    assign _e_2269 = $signed(\diff ) > $signed(_e_2271);
    localparam[31:0] _e_2273 = 32'd2147483647;
    localparam[33:0] _e_2277 = -34'd2147483648;
    assign _e_2275 = $signed(\diff ) < $signed(_e_2277);
    localparam[31:0] _e_2279 = 32'd2147483648;
    assign \trunc_diff  = \diff [31:0];
    (* src = "src/alu.spade:131,9" *)
    \std::conv::impl_3::to_uint[2154]  to_uint_0(.self_i(\trunc_diff ), .output__(_e_2284));
    assign _e_2274 = _e_2275 ? _e_2279 : _e_2284;
    assign _e_2268 = _e_2269 ? _e_2273 : _e_2274;
    assign output__ = _e_2268;
endmodule

module \tta::alu::ashr32  (
        input[31:0] x_i,
        input[31:0] sh_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::ashr32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::ashr32 );
        end
    end
    `endif
    logic[31:0] \x ;
    assign \x  = x_i;
    logic[31:0] \sh ;
    assign \sh  = sh_i;
    (* src = "src/alu.spade:138,9" *)
    logic[31:0] \sh32 ;
    (* src = "src/alu.spade:139,29" *)
    logic[31:0] \logical ;
    (* src = "src/alu.spade:140,32" *)
    logic[31:0] _e_2294;
    (* src = "src/alu.spade:140,26" *)
    logic \sign1 ;
    logic[30:0] _e_2300;
    (* src = "src/alu.spade:141,30" *)
    logic[31:0] \signmask ;
    (* src = "src/alu.spade:142,33" *)
    logic _e_2304;
    (* src = "src/alu.spade:142,62" *)
    logic[32:0] _e_2312;
    (* src = "src/alu.spade:142,73" *)
    logic[32:0] _e_2315;
    (* src = "src/alu.spade:142,62" *)
    logic[32:0] _e_2311;
    (* src = "src/alu.spade:142,56" *)
    logic[31:0] _e_2310;
    (* src = "src/alu.spade:142,30" *)
    logic[31:0] \top_mask ;
    (* src = "src/alu.spade:143,26" *)
    logic[31:0] \fill ;
    (* src = "src/alu.spade:144,5" *)
    logic[31:0] _e_2323;
    assign \sh32  = \sh ;
    assign \logical  = \x  >> \sh32 ;
    localparam[31:0] _e_2296 = 32'd31;
    assign _e_2294 = \x  >> _e_2296;
    assign \sign1  = _e_2294[0:0];
    localparam[30:0] _e_2299 = 0;
    assign _e_2300 = {30'b0, \sign1 };
    assign \signmask  = _e_2299 - _e_2300;
    localparam[31:0] _e_2306 = 32'd0;
    assign _e_2304 = \sh  == _e_2306;
    localparam[31:0] _e_2308 = 32'd0;
    localparam[31:0] _e_2313 = 32'd0;
    localparam[31:0] _e_2314 = 32'd1;
    assign _e_2312 = _e_2313 - _e_2314;
    localparam[31:0] _e_2316 = 32'd32;
    assign _e_2315 = _e_2316 - \sh ;
    assign _e_2311 = _e_2312 << _e_2315;
    assign _e_2310 = _e_2311[31:0];
    assign \top_mask  = _e_2304 ? _e_2308 : _e_2310;
    assign \fill  = \signmask  & \top_mask ;
    assign _e_2323 = \logical  | \fill ;
    assign output__ = _e_2323;
endmodule

module \tta::alu::rotl32  (
        input[31:0] x_i,
        input[31:0] sh32_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::rotl32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::rotl32 );
        end
    end
    `endif
    logic[31:0] \x ;
    assign \x  = x_i;
    logic[31:0] \sh32 ;
    assign \sh32  = sh32_i;
    (* src = "src/alu.spade:148,6" *)
    logic _e_2328;
    (* src = "src/alu.spade:149,26" *)
    logic[31:0] \left ;
    (* src = "src/alu.spade:150,36" *)
    logic[32:0] _e_2339;
    (* src = "src/alu.spade:150,30" *)
    logic[31:0] \inverted ;
    (* src = "src/alu.spade:151,27" *)
    logic[31:0] \right ;
    (* src = "src/alu.spade:152,5" *)
    logic[31:0] _e_2347;
    (* src = "src/alu.spade:148,3" *)
    logic[31:0] _e_2327;
    localparam[31:0] _e_2330 = 32'd0;
    assign _e_2328 = \sh32  == _e_2330;
    assign \left  = \x  << \sh32 ;
    localparam[31:0] _e_2340 = 32'd32;
    assign _e_2339 = _e_2340 - \sh32 ;
    assign \inverted  = _e_2339[31:0];
    assign \right  = \x  >> \inverted ;
    assign _e_2347 = \left  | \right ;
    assign _e_2327 = _e_2328 ? \x  : _e_2347;
    assign output__ = _e_2327;
endmodule

module \tta::alu::rotr32  (
        input[31:0] x_i,
        input[31:0] sh32_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::rotr32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::rotr32 );
        end
    end
    `endif
    logic[31:0] \x ;
    assign \x  = x_i;
    logic[31:0] \sh32 ;
    assign \sh32  = sh32_i;
    (* src = "src/alu.spade:157,6" *)
    logic _e_2352;
    (* src = "src/alu.spade:158,27" *)
    logic[31:0] \right ;
    (* src = "src/alu.spade:159,36" *)
    logic[32:0] _e_2363;
    (* src = "src/alu.spade:159,30" *)
    logic[31:0] \inverted ;
    (* src = "src/alu.spade:160,27" *)
    logic[31:0] \left ;
    (* src = "src/alu.spade:161,5" *)
    logic[31:0] _e_2371;
    (* src = "src/alu.spade:157,3" *)
    logic[31:0] _e_2351;
    localparam[31:0] _e_2354 = 32'd0;
    assign _e_2352 = \sh32  == _e_2354;
    assign \right  = \x  >> \sh32 ;
    localparam[31:0] _e_2364 = 32'd32;
    assign _e_2363 = _e_2364 - \sh32 ;
    assign \inverted  = _e_2363[31:0];
    assign \left  = \x  << \inverted ;
    assign _e_2371 = \right  | \left ;
    assign _e_2351 = _e_2352 ? \x  : _e_2371;
    assign output__ = _e_2351;
endmodule

module \tta::alu::pick_alu_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::pick_alu_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::pick_alu_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/alu.spade:169,9" *)
    logic[42:0] _e_2378;
    (* src = "src/alu.spade:169,14" *)
    logic[31:0] \x ;
    logic _e_8079;
    logic _e_8081;
    logic _e_8083;
    logic _e_8084;
    (* src = "src/alu.spade:169,35" *)
    logic[32:0] _e_2380;
    (* src = "src/alu.spade:170,9" *)
    logic[43:0] \_ ;
    (* src = "src/alu.spade:171,13" *)
    logic[42:0] _e_2386;
    (* src = "src/alu.spade:171,18" *)
    logic[31:0] x_n1;
    logic _e_8087;
    logic _e_8089;
    logic _e_8091;
    logic _e_8092;
    (* src = "src/alu.spade:171,39" *)
    logic[32:0] _e_2388;
    (* src = "src/alu.spade:172,13" *)
    logic[43:0] __n1;
    (* src = "src/alu.spade:172,18" *)
    logic[32:0] _e_2391;
    (* src = "src/alu.spade:170,14" *)
    logic[32:0] _e_2383;
    (* src = "src/alu.spade:168,5" *)
    logic[32:0] _e_2375;
    assign _e_2378 = \m1 [42:0];
    assign \x  = _e_2378[36:5];
    assign _e_8079 = \m1 [43] == 1'd1;
    assign _e_8081 = _e_2378[42:37] == 6'd1;
    localparam[0:0] _e_8082 = 1;
    assign _e_8083 = _e_8081 && _e_8082;
    assign _e_8084 = _e_8079 && _e_8083;
    assign _e_2380 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8085 = 1;
    assign _e_2386 = \m0 [42:0];
    assign x_n1 = _e_2386[36:5];
    assign _e_8087 = \m0 [43] == 1'd1;
    assign _e_8089 = _e_2386[42:37] == 6'd1;
    localparam[0:0] _e_8090 = 1;
    assign _e_8091 = _e_8089 && _e_8090;
    assign _e_8092 = _e_8087 && _e_8091;
    assign _e_2388 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8093 = 1;
    assign _e_2391 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8092, _e_8093})
            2'b1?: _e_2383 = _e_2388;
            2'b01: _e_2383 = _e_2391;
            2'b?: _e_2383 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8084, _e_8085})
            2'b1?: _e_2375 = _e_2380;
            2'b01: _e_2375 = _e_2383;
            2'b?: _e_2375 = 33'dx;
        endcase
    end
    assign output__ = _e_2375;
endmodule

module \tta::alu::pick_alu_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[37:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::alu::pick_alu_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::alu::pick_alu_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/alu.spade:178,9" *)
    logic[42:0] _e_2397;
    (* src = "src/alu.spade:178,14" *)
    logic[4:0] \op ;
    (* src = "src/alu.spade:178,14" *)
    logic[31:0] \x ;
    logic _e_8095;
    logic _e_8097;
    logic _e_8100;
    logic _e_8101;
    logic _e_8102;
    (* src = "src/alu.spade:178,44" *)
    logic[36:0] _e_2400;
    (* src = "src/alu.spade:178,39" *)
    logic[37:0] _e_2399;
    (* src = "src/alu.spade:179,9" *)
    logic[43:0] \_ ;
    (* src = "src/alu.spade:180,13" *)
    logic[42:0] _e_2408;
    (* src = "src/alu.spade:180,18" *)
    logic[4:0] op_n1;
    (* src = "src/alu.spade:180,18" *)
    logic[31:0] x_n1;
    logic _e_8105;
    logic _e_8107;
    logic _e_8110;
    logic _e_8111;
    logic _e_8112;
    (* src = "src/alu.spade:180,48" *)
    logic[36:0] _e_2411;
    (* src = "src/alu.spade:180,43" *)
    logic[37:0] _e_2410;
    (* src = "src/alu.spade:181,13" *)
    logic[43:0] __n1;
    (* src = "src/alu.spade:181,18" *)
    logic[37:0] _e_2415;
    (* src = "src/alu.spade:179,14" *)
    logic[37:0] _e_2404;
    (* src = "src/alu.spade:177,5" *)
    logic[37:0] _e_2393;
    assign _e_2397 = \m1 [42:0];
    assign \op  = _e_2397[36:32];
    assign \x  = _e_2397[31:0];
    assign _e_8095 = \m1 [43] == 1'd1;
    assign _e_8097 = _e_2397[42:37] == 6'd2;
    localparam[0:0] _e_8098 = 1;
    localparam[0:0] _e_8099 = 1;
    assign _e_8100 = _e_8097 && _e_8098;
    assign _e_8101 = _e_8100 && _e_8099;
    assign _e_8102 = _e_8095 && _e_8101;
    assign _e_2400 = {\op , \x };
    assign _e_2399 = {1'd1, _e_2400};
    assign \_  = \m1 ;
    localparam[0:0] _e_8103 = 1;
    assign _e_2408 = \m0 [42:0];
    assign op_n1 = _e_2408[36:32];
    assign x_n1 = _e_2408[31:0];
    assign _e_8105 = \m0 [43] == 1'd1;
    assign _e_8107 = _e_2408[42:37] == 6'd2;
    localparam[0:0] _e_8108 = 1;
    localparam[0:0] _e_8109 = 1;
    assign _e_8110 = _e_8107 && _e_8108;
    assign _e_8111 = _e_8110 && _e_8109;
    assign _e_8112 = _e_8105 && _e_8111;
    assign _e_2411 = {op_n1, x_n1};
    assign _e_2410 = {1'd1, _e_2411};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8113 = 1;
    assign _e_2415 = {1'd0, 37'bX};
    always_comb begin
        priority casez ({_e_8112, _e_8113})
            2'b1?: _e_2404 = _e_2410;
            2'b01: _e_2404 = _e_2415;
            2'b?: _e_2404 = 38'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8102, _e_8103})
            2'b1?: _e_2393 = _e_2399;
            2'b01: _e_2393 = _e_2404;
            2'b?: _e_2393 = 38'dx;
        endcase
    end
    assign output__ = _e_2393;
endmodule

module \tta::modadd::modadd_fu  (
        input clk_i,
        input rst_i,
        input[32:0] set_base_i,
        input[32:0] set_mask_i,
        input[32:0] set_ptr_i,
        input[32:0] trig_stride_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::modadd::modadd_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::modadd::modadd_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_base ;
    assign \set_base  = set_base_i;
    logic[32:0] \set_mask ;
    assign \set_mask  = set_mask_i;
    logic[32:0] \set_ptr ;
    assign \set_ptr  = set_ptr_i;
    logic[32:0] \trig_stride ;
    assign \trig_stride  = trig_stride_i;
    (* src = "src/modadd.spade:20,9" *)
    logic[31:0] \v ;
    logic _e_8115;
    logic _e_8117;
    logic _e_8119;
    (* src = "src/modadd.spade:19,45" *)
    logic[31:0] _e_2421;
    (* src = "src/modadd.spade:19,14" *)
    reg[31:0] \base ;
    (* src = "src/modadd.spade:25,9" *)
    logic[31:0] v_n1;
    logic _e_8121;
    logic _e_8123;
    logic _e_8125;
    (* src = "src/modadd.spade:24,45" *)
    logic[31:0] _e_2432;
    (* src = "src/modadd.spade:24,14" *)
    reg[31:0] \mask ;
    (* src = "src/modadd.spade:33,13" *)
    logic[31:0] v_n2;
    logic _e_8127;
    logic _e_8129;
    logic _e_8131;
    (* src = "src/modadd.spade:32,27" *)
    logic[31:0] \current_ptr ;
    (* src = "src/modadd.spade:38,13" *)
    logic[31:0] \stride ;
    logic _e_8133;
    logic _e_8135;
    (* src = "src/modadd.spade:41,36" *)
    logic[32:0] _e_2459;
    (* src = "src/modadd.spade:41,30" *)
    logic[31:0] _e_2458;
    (* src = "src/modadd.spade:41,30" *)
    logic[31:0] \offset ;
    (* src = "src/modadd.spade:42,17" *)
    logic[31:0] _e_2464;
    logic _e_8137;
    (* src = "src/modadd.spade:37,9" *)
    logic[31:0] _e_2452;
    (* src = "src/modadd.spade:31,14" *)
    reg[31:0] \ptr ;
    (* src = "src/modadd.spade:49,47" *)
    logic[32:0] _e_2472;
    (* src = "src/modadd.spade:51,13" *)
    logic[31:0] v_n3;
    logic _e_8139;
    logic _e_8141;
    logic _e_8143;
    (* src = "src/modadd.spade:50,27" *)
    logic[31:0] current_ptr_n1;
    (* src = "src/modadd.spade:56,13" *)
    logic[31:0] stride_n1;
    logic _e_8145;
    logic _e_8147;
    (* src = "src/modadd.spade:57,36" *)
    logic[32:0] _e_2489;
    (* src = "src/modadd.spade:57,30" *)
    logic[31:0] _e_2488;
    (* src = "src/modadd.spade:57,30" *)
    logic[31:0] offset_n1;
    (* src = "src/modadd.spade:58,22" *)
    logic[31:0] _e_2495;
    (* src = "src/modadd.spade:58,17" *)
    logic[32:0] _e_2494;
    logic _e_8149;
    (* src = "src/modadd.spade:60,21" *)
    logic[32:0] _e_2499;
    (* src = "src/modadd.spade:55,9" *)
    logic[32:0] _e_2482;
    (* src = "src/modadd.spade:49,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_2420 = 32'd0;
    assign \v  = \set_base [31:0];
    assign _e_8115 = \set_base [32] == 1'd1;
    localparam[0:0] _e_8116 = 1;
    assign _e_8117 = _e_8115 && _e_8116;
    assign _e_8119 = \set_base [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8117, _e_8119})
            2'b1?: _e_2421 = \v ;
            2'b01: _e_2421 = \base ;
            2'b?: _e_2421 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \base  <= _e_2420;
        end
        else begin
            \base  <= _e_2421;
        end
    end
    localparam[31:0] _e_2431 = 32'd0;
    assign v_n1 = \set_mask [31:0];
    assign _e_8121 = \set_mask [32] == 1'd1;
    localparam[0:0] _e_8122 = 1;
    assign _e_8123 = _e_8121 && _e_8122;
    assign _e_8125 = \set_mask [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8123, _e_8125})
            2'b1?: _e_2432 = v_n1;
            2'b01: _e_2432 = \mask ;
            2'b?: _e_2432 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \mask  <= _e_2431;
        end
        else begin
            \mask  <= _e_2432;
        end
    end
    localparam[31:0] _e_2442 = 32'd0;
    assign v_n2 = \set_ptr [31:0];
    assign _e_8127 = \set_ptr [32] == 1'd1;
    localparam[0:0] _e_8128 = 1;
    assign _e_8129 = _e_8127 && _e_8128;
    assign _e_8131 = \set_ptr [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8129, _e_8131})
            2'b1?: \current_ptr  = v_n2;
            2'b01: \current_ptr  = \ptr ;
            2'b?: \current_ptr  = 32'dx;
        endcase
    end
    assign \stride  = \trig_stride [31:0];
    assign _e_8133 = \trig_stride [32] == 1'd1;
    localparam[0:0] _e_8134 = 1;
    assign _e_8135 = _e_8133 && _e_8134;
    assign _e_2459 = \current_ptr  + \stride ;
    assign _e_2458 = _e_2459[31:0];
    assign \offset  = _e_2458 & \mask ;
    assign _e_2464 = \base  | \offset ;
    assign _e_8137 = \trig_stride [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8135, _e_8137})
            2'b1?: _e_2452 = _e_2464;
            2'b01: _e_2452 = \current_ptr ;
            2'b?: _e_2452 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \ptr  <= _e_2442;
        end
        else begin
            \ptr  <= _e_2452;
        end
    end
    assign _e_2472 = {1'd0, 32'bX};
    assign v_n3 = \set_ptr [31:0];
    assign _e_8139 = \set_ptr [32] == 1'd1;
    localparam[0:0] _e_8140 = 1;
    assign _e_8141 = _e_8139 && _e_8140;
    assign _e_8143 = \set_ptr [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8141, _e_8143})
            2'b1?: current_ptr_n1 = v_n3;
            2'b01: current_ptr_n1 = \ptr ;
            2'b?: current_ptr_n1 = 32'dx;
        endcase
    end
    assign stride_n1 = \trig_stride [31:0];
    assign _e_8145 = \trig_stride [32] == 1'd1;
    localparam[0:0] _e_8146 = 1;
    assign _e_8147 = _e_8145 && _e_8146;
    assign _e_2489 = current_ptr_n1 + stride_n1;
    assign _e_2488 = _e_2489[31:0];
    assign offset_n1 = _e_2488 & \mask ;
    assign _e_2495 = \base  | offset_n1;
    assign _e_2494 = {1'd1, _e_2495};
    assign _e_8149 = \trig_stride [32] == 1'd0;
    assign _e_2499 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8147, _e_8149})
            2'b1?: _e_2482 = _e_2494;
            2'b01: _e_2482 = _e_2499;
            2'b?: _e_2482 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_2472;
        end
        else begin
            \res  <= _e_2482;
        end
    end
    assign output__ = \res ;
endmodule

module \tta::modadd::pick_base  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::modadd::pick_base" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::modadd::pick_base );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/modadd.spade:71,9" *)
    logic[42:0] _e_2505;
    (* src = "src/modadd.spade:71,14" *)
    logic[31:0] \a ;
    logic _e_8151;
    logic _e_8153;
    logic _e_8155;
    logic _e_8156;
    (* src = "src/modadd.spade:71,35" *)
    logic[32:0] _e_2507;
    (* src = "src/modadd.spade:72,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:72,25" *)
    logic[42:0] _e_2513;
    (* src = "src/modadd.spade:72,30" *)
    logic[31:0] a_n1;
    logic _e_8159;
    logic _e_8161;
    logic _e_8163;
    logic _e_8164;
    (* src = "src/modadd.spade:72,51" *)
    logic[32:0] _e_2515;
    (* src = "src/modadd.spade:72,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:72,65" *)
    logic[32:0] _e_2518;
    (* src = "src/modadd.spade:72,14" *)
    logic[32:0] _e_2510;
    (* src = "src/modadd.spade:70,5" *)
    logic[32:0] _e_2502;
    assign _e_2505 = \m1 [42:0];
    assign \a  = _e_2505[36:5];
    assign _e_8151 = \m1 [43] == 1'd1;
    assign _e_8153 = _e_2505[42:37] == 6'd30;
    localparam[0:0] _e_8154 = 1;
    assign _e_8155 = _e_8153 && _e_8154;
    assign _e_8156 = _e_8151 && _e_8155;
    assign _e_2507 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8157 = 1;
    assign _e_2513 = \m0 [42:0];
    assign a_n1 = _e_2513[36:5];
    assign _e_8159 = \m0 [43] == 1'd1;
    assign _e_8161 = _e_2513[42:37] == 6'd30;
    localparam[0:0] _e_8162 = 1;
    assign _e_8163 = _e_8161 && _e_8162;
    assign _e_8164 = _e_8159 && _e_8163;
    assign _e_2515 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8165 = 1;
    assign _e_2518 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8164, _e_8165})
            2'b1?: _e_2510 = _e_2515;
            2'b01: _e_2510 = _e_2518;
            2'b?: _e_2510 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8156, _e_8157})
            2'b1?: _e_2502 = _e_2507;
            2'b01: _e_2502 = _e_2510;
            2'b?: _e_2502 = 33'dx;
        endcase
    end
    assign output__ = _e_2502;
endmodule

module \tta::modadd::pick_mask  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::modadd::pick_mask" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::modadd::pick_mask );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/modadd.spade:78,9" *)
    logic[42:0] _e_2523;
    (* src = "src/modadd.spade:78,14" *)
    logic[31:0] \a ;
    logic _e_8167;
    logic _e_8169;
    logic _e_8171;
    logic _e_8172;
    (* src = "src/modadd.spade:78,35" *)
    logic[32:0] _e_2525;
    (* src = "src/modadd.spade:79,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:79,25" *)
    logic[42:0] _e_2531;
    (* src = "src/modadd.spade:79,30" *)
    logic[31:0] a_n1;
    logic _e_8175;
    logic _e_8177;
    logic _e_8179;
    logic _e_8180;
    (* src = "src/modadd.spade:79,51" *)
    logic[32:0] _e_2533;
    (* src = "src/modadd.spade:79,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:79,65" *)
    logic[32:0] _e_2536;
    (* src = "src/modadd.spade:79,14" *)
    logic[32:0] _e_2528;
    (* src = "src/modadd.spade:77,5" *)
    logic[32:0] _e_2520;
    assign _e_2523 = \m1 [42:0];
    assign \a  = _e_2523[36:5];
    assign _e_8167 = \m1 [43] == 1'd1;
    assign _e_8169 = _e_2523[42:37] == 6'd31;
    localparam[0:0] _e_8170 = 1;
    assign _e_8171 = _e_8169 && _e_8170;
    assign _e_8172 = _e_8167 && _e_8171;
    assign _e_2525 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8173 = 1;
    assign _e_2531 = \m0 [42:0];
    assign a_n1 = _e_2531[36:5];
    assign _e_8175 = \m0 [43] == 1'd1;
    assign _e_8177 = _e_2531[42:37] == 6'd31;
    localparam[0:0] _e_8178 = 1;
    assign _e_8179 = _e_8177 && _e_8178;
    assign _e_8180 = _e_8175 && _e_8179;
    assign _e_2533 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8181 = 1;
    assign _e_2536 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8180, _e_8181})
            2'b1?: _e_2528 = _e_2533;
            2'b01: _e_2528 = _e_2536;
            2'b?: _e_2528 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8172, _e_8173})
            2'b1?: _e_2520 = _e_2525;
            2'b01: _e_2520 = _e_2528;
            2'b?: _e_2520 = 33'dx;
        endcase
    end
    assign output__ = _e_2520;
endmodule

module \tta::modadd::pick_ptr  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::modadd::pick_ptr" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::modadd::pick_ptr );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/modadd.spade:85,9" *)
    logic[42:0] _e_2541;
    (* src = "src/modadd.spade:85,14" *)
    logic[31:0] \a ;
    logic _e_8183;
    logic _e_8185;
    logic _e_8187;
    logic _e_8188;
    (* src = "src/modadd.spade:85,34" *)
    logic[32:0] _e_2543;
    (* src = "src/modadd.spade:86,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:86,25" *)
    logic[42:0] _e_2549;
    (* src = "src/modadd.spade:86,30" *)
    logic[31:0] a_n1;
    logic _e_8191;
    logic _e_8193;
    logic _e_8195;
    logic _e_8196;
    (* src = "src/modadd.spade:86,50" *)
    logic[32:0] _e_2551;
    (* src = "src/modadd.spade:86,59" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:86,64" *)
    logic[32:0] _e_2554;
    (* src = "src/modadd.spade:86,14" *)
    logic[32:0] _e_2546;
    (* src = "src/modadd.spade:84,5" *)
    logic[32:0] _e_2538;
    assign _e_2541 = \m1 [42:0];
    assign \a  = _e_2541[36:5];
    assign _e_8183 = \m1 [43] == 1'd1;
    assign _e_8185 = _e_2541[42:37] == 6'd32;
    localparam[0:0] _e_8186 = 1;
    assign _e_8187 = _e_8185 && _e_8186;
    assign _e_8188 = _e_8183 && _e_8187;
    assign _e_2543 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8189 = 1;
    assign _e_2549 = \m0 [42:0];
    assign a_n1 = _e_2549[36:5];
    assign _e_8191 = \m0 [43] == 1'd1;
    assign _e_8193 = _e_2549[42:37] == 6'd32;
    localparam[0:0] _e_8194 = 1;
    assign _e_8195 = _e_8193 && _e_8194;
    assign _e_8196 = _e_8191 && _e_8195;
    assign _e_2551 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8197 = 1;
    assign _e_2554 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8196, _e_8197})
            2'b1?: _e_2546 = _e_2551;
            2'b01: _e_2546 = _e_2554;
            2'b?: _e_2546 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8188, _e_8189})
            2'b1?: _e_2538 = _e_2543;
            2'b01: _e_2538 = _e_2546;
            2'b?: _e_2538 = 33'dx;
        endcase
    end
    assign output__ = _e_2538;
endmodule

module \tta::modadd::pick_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::modadd::pick_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::modadd::pick_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/modadd.spade:92,9" *)
    logic[42:0] _e_2559;
    (* src = "src/modadd.spade:92,14" *)
    logic[31:0] \a ;
    logic _e_8199;
    logic _e_8201;
    logic _e_8203;
    logic _e_8204;
    (* src = "src/modadd.spade:92,35" *)
    logic[32:0] _e_2561;
    (* src = "src/modadd.spade:93,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:93,25" *)
    logic[42:0] _e_2567;
    (* src = "src/modadd.spade:93,30" *)
    logic[31:0] a_n1;
    logic _e_8207;
    logic _e_8209;
    logic _e_8211;
    logic _e_8212;
    (* src = "src/modadd.spade:93,51" *)
    logic[32:0] _e_2569;
    (* src = "src/modadd.spade:93,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:93,65" *)
    logic[32:0] _e_2572;
    (* src = "src/modadd.spade:93,14" *)
    logic[32:0] _e_2564;
    (* src = "src/modadd.spade:91,5" *)
    logic[32:0] _e_2556;
    assign _e_2559 = \m1 [42:0];
    assign \a  = _e_2559[36:5];
    assign _e_8199 = \m1 [43] == 1'd1;
    assign _e_8201 = _e_2559[42:37] == 6'd33;
    localparam[0:0] _e_8202 = 1;
    assign _e_8203 = _e_8201 && _e_8202;
    assign _e_8204 = _e_8199 && _e_8203;
    assign _e_2561 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8205 = 1;
    assign _e_2567 = \m0 [42:0];
    assign a_n1 = _e_2567[36:5];
    assign _e_8207 = \m0 [43] == 1'd1;
    assign _e_8209 = _e_2567[42:37] == 6'd33;
    localparam[0:0] _e_8210 = 1;
    assign _e_8211 = _e_8209 && _e_8210;
    assign _e_8212 = _e_8207 && _e_8211;
    assign _e_2569 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8213 = 1;
    assign _e_2572 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8212, _e_8213})
            2'b1?: _e_2564 = _e_2569;
            2'b01: _e_2564 = _e_2572;
            2'b?: _e_2564 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8204, _e_8205})
            2'b1?: _e_2556 = _e_2561;
            2'b01: _e_2556 = _e_2564;
            2'b?: _e_2556 = 33'dx;
        endcase
    end
    assign output__ = _e_2556;
endmodule

module \tta::uart_in::uart_in  (
        input clk_i,
        input rst_i,
        input[8:0] uart_byte_i,
        input pop_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::uart_in::uart_in" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::uart_in::uart_in );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[8:0] \uart_byte ;
    assign \uart_byte  = uart_byte_i;
    logic \pop ;
    assign \pop  = pop_i;
    (* src = "src/uart_in.spade:17,16" *)
    logic[14:0] \data ;
    (* src = "src/uart_in.spade:18,48" *)
    logic[32:0] _e_2583;
    (* src = "src/uart_in.spade:19,7" *)
    logic[31:0] \b ;
    logic _e_8215;
    logic _e_8217;
    logic[31:0] _e_2589;
    (* src = "src/uart_in.spade:19,18" *)
    logic[32:0] _e_2588;
    logic _e_8219;
    (* src = "src/uart_in.spade:20,15" *)
    logic[32:0] _e_2592;
    (* src = "src/uart_in.spade:18,56" *)
    logic[32:0] _e_2584;
    (* src = "src/uart_in.spade:18,14" *)
    reg[32:0] data_n1;
    (* src = "src/uart_in.spade:17,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\uart_byte ), .pop_i(\pop ), .output__(\data ));
    assign _e_2583 = {1'd0, 32'bX};
    assign \b  = data_n1[31:0];
    assign _e_8215 = data_n1[32] == 1'd1;
    localparam[0:0] _e_8216 = 1;
    assign _e_8217 = _e_8215 && _e_8216;
    assign _e_2589 = \b ;
    assign _e_2588 = {1'd1, _e_2589};
    assign _e_8219 = data_n1[32] == 1'd0;
    assign _e_2592 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8217, _e_8219})
            2'b1?: _e_2584 = _e_2588;
            2'b01: _e_2584 = _e_2592;
            2'b?: _e_2584 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2583;
        end
        else begin
            data_n1 <= _e_2584;
        end
    end
    assign output__ = data_n1;
endmodule

module \tta::uart_in::uart_out  (
        input clk_i,
        input rst_i,
        input[8:0] byte_to_write_i,
        output[8:0] tx_o,
        input uart_tx_busy_i
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::uart_in::uart_out" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::uart_in::uart_out );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[8:0] \byte_to_write ;
    assign \byte_to_write  = byte_to_write_i;
    logic[8:0] \tx_mut ;
    assign tx_o = \tx_mut ;
    logic \uart_tx_busy ;
    assign \uart_tx_busy  = uart_tx_busy_i;
    (* src = "src/uart_in.spade:39,65" *)
    logic _e_2599;
    (* src = "src/uart_in.spade:39,16" *)
    logic[14:0] \data ;
    (* src = "src/uart_in.spade:40,47" *)
    logic[8:0] _e_2605;
    (* src = "src/uart_in.spade:41,7" *)
    logic[7:0] \b ;
    logic _e_8221;
    logic _e_8223;
    (* src = "src/uart_in.spade:41,18" *)
    logic[8:0] _e_2610;
    logic _e_8225;
    (* src = "src/uart_in.spade:42,15" *)
    logic[8:0] _e_2613;
    (* src = "src/uart_in.spade:40,55" *)
    logic[8:0] _e_2606;
    (* src = "src/uart_in.spade:40,14" *)
    reg[8:0] data_n1;
    assign _e_2599 = !\uart_tx_busy ;
    (* src = "src/uart_in.spade:39,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\byte_to_write ), .pop_i(_e_2599), .output__(\data ));
    assign _e_2605 = {1'd0, 8'bX};
    assign \b  = data_n1[7:0];
    assign _e_8221 = data_n1[8] == 1'd1;
    localparam[0:0] _e_8222 = 1;
    assign _e_8223 = _e_8221 && _e_8222;
    assign _e_2610 = {1'd1, \b };
    assign _e_8225 = data_n1[8] == 1'd0;
    assign _e_2613 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8223, _e_8225})
            2'b1?: _e_2606 = _e_2610;
            2'b01: _e_2606 = _e_2613;
            2'b?: _e_2606 = 9'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2605;
        end
        else begin
            data_n1 <= _e_2606;
        end
    end
    assign \tx_mut  = data_n1;
endmodule

module \tta::uart_in::pick_uart_inpop  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::uart_in::pick_uart_inpop" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::uart_in::pick_uart_inpop );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/uart_in.spade:52,9" *)
    logic[42:0] _e_2620;
    logic _e_8227;
    logic _e_8229;
    logic _e_8230;
    (* src = "src/uart_in.spade:53,9" *)
    logic[43:0] \_ ;
    (* src = "src/uart_in.spade:54,13" *)
    logic[42:0] _e_2626;
    logic _e_8233;
    logic _e_8235;
    logic _e_8236;
    (* src = "src/uart_in.spade:55,13" *)
    logic[43:0] __n1;
    (* src = "src/uart_in.spade:53,14" *)
    logic _e_2624;
    (* src = "src/uart_in.spade:51,5" *)
    logic _e_2618;
    assign _e_2620 = \m1 [42:0];
    assign _e_8227 = \m1 [43] == 1'd1;
    assign _e_8229 = _e_2620[42:37] == 6'd41;
    assign _e_8230 = _e_8227 && _e_8229;
    localparam[0:0] _e_2622 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_8231 = 1;
    assign _e_2626 = \m0 [42:0];
    assign _e_8233 = \m0 [43] == 1'd1;
    assign _e_8235 = _e_2626[42:37] == 6'd41;
    assign _e_8236 = _e_8233 && _e_8235;
    localparam[0:0] _e_2628 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_8237 = 1;
    localparam[0:0] _e_2630 = 0;
    always_comb begin
        priority casez ({_e_8236, _e_8237})
            2'b1?: _e_2624 = _e_2628;
            2'b01: _e_2624 = _e_2630;
            2'b?: _e_2624 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8230, _e_8231})
            2'b1?: _e_2618 = _e_2622;
            2'b01: _e_2618 = _e_2624;
            2'b?: _e_2618 = 1'dx;
        endcase
    end
    assign output__ = _e_2618;
endmodule

module \tta::uart_in::pick_uart_out8  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[8:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::uart_in::pick_uart_out8" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::uart_in::pick_uart_out8 );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/uart_in.spade:61,9" *)
    logic[42:0] _e_2635;
    (* src = "src/uart_in.spade:61,14" *)
    logic[7:0] \x ;
    logic _e_8239;
    logic _e_8241;
    logic _e_8243;
    logic _e_8244;
    (* src = "src/uart_in.spade:61,36" *)
    logic[8:0] _e_2637;
    (* src = "src/uart_in.spade:62,9" *)
    logic[43:0] \_ ;
    (* src = "src/uart_in.spade:63,13" *)
    logic[42:0] _e_2643;
    (* src = "src/uart_in.spade:63,18" *)
    logic[7:0] x_n1;
    logic _e_8247;
    logic _e_8249;
    logic _e_8251;
    logic _e_8252;
    (* src = "src/uart_in.spade:63,40" *)
    logic[8:0] _e_2645;
    (* src = "src/uart_in.spade:64,13" *)
    logic[43:0] __n1;
    (* src = "src/uart_in.spade:64,18" *)
    logic[8:0] _e_2648;
    (* src = "src/uart_in.spade:62,14" *)
    logic[8:0] _e_2640;
    (* src = "src/uart_in.spade:60,5" *)
    logic[8:0] _e_2632;
    assign _e_2635 = \m1 [42:0];
    assign \x  = _e_2635[36:29];
    assign _e_8239 = \m1 [43] == 1'd1;
    assign _e_8241 = _e_2635[42:37] == 6'd38;
    localparam[0:0] _e_8242 = 1;
    assign _e_8243 = _e_8241 && _e_8242;
    assign _e_8244 = _e_8239 && _e_8243;
    assign _e_2637 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8245 = 1;
    assign _e_2643 = \m0 [42:0];
    assign x_n1 = _e_2643[36:29];
    assign _e_8247 = \m0 [43] == 1'd1;
    assign _e_8249 = _e_2643[42:37] == 6'd38;
    localparam[0:0] _e_8250 = 1;
    assign _e_8251 = _e_8249 && _e_8250;
    assign _e_8252 = _e_8247 && _e_8251;
    assign _e_2645 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8253 = 1;
    assign _e_2648 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8252, _e_8253})
            2'b1?: _e_2640 = _e_2645;
            2'b01: _e_2640 = _e_2648;
            2'b?: _e_2640 = 9'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8244, _e_8245})
            2'b1?: _e_2632 = _e_2637;
            2'b01: _e_2632 = _e_2640;
            2'b?: _e_2632 = 9'dx;
        endcase
    end
    assign output__ = _e_2632;
endmodule

module \tta::cmp::cmp_fu  (
        input clk_i,
        input rst_i,
        input[32:0] set_op_a_i,
        input[35:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmp::cmp_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmp::cmp_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_op_a ;
    assign \set_op_a  = set_op_a_i;
    logic[35:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/cmp.spade:29,9" *)
    logic[31:0] \v ;
    logic _e_8255;
    logic _e_8257;
    logic _e_8259;
    (* src = "src/cmp.spade:28,42" *)
    logic[31:0] _e_2654;
    (* src = "src/cmp.spade:28,14" *)
    reg[31:0] \a ;
    (* src = "src/cmp.spade:35,9" *)
    logic[34:0] _e_2665;
    (* src = "src/cmp.spade:35,14" *)
    logic[2:0] _e_2663;
    (* src = "src/cmp.spade:35,14" *)
    logic[31:0] \b ;
    logic _e_8261;
    logic _e_8264;
    logic _e_8266;
    logic _e_8267;
    (* src = "src/cmp.spade:35,47" *)
    logic _e_2669;
    (* src = "src/cmp.spade:35,40" *)
    logic[31:0] _e_2668;
    (* src = "src/cmp.spade:35,35" *)
    logic[32:0] _e_2667;
    (* src = "src/cmp.spade:36,9" *)
    logic[34:0] _e_2674;
    (* src = "src/cmp.spade:36,14" *)
    logic[2:0] _e_2672;
    (* src = "src/cmp.spade:36,14" *)
    logic[31:0] b_n1;
    logic _e_8269;
    logic _e_8272;
    logic _e_8274;
    logic _e_8275;
    (* src = "src/cmp.spade:36,47" *)
    logic _e_2678;
    (* src = "src/cmp.spade:36,40" *)
    logic[31:0] _e_2677;
    (* src = "src/cmp.spade:36,35" *)
    logic[32:0] _e_2676;
    (* src = "src/cmp.spade:37,9" *)
    logic[34:0] _e_2683;
    (* src = "src/cmp.spade:37,14" *)
    logic[2:0] _e_2681;
    (* src = "src/cmp.spade:37,14" *)
    logic[31:0] b_n2;
    logic _e_8277;
    logic _e_8280;
    logic _e_8282;
    logic _e_8283;
    (* src = "src/cmp.spade:37,47" *)
    logic _e_2687;
    (* src = "src/cmp.spade:37,40" *)
    logic[31:0] _e_2686;
    (* src = "src/cmp.spade:37,35" *)
    logic[32:0] _e_2685;
    (* src = "src/cmp.spade:38,9" *)
    logic[34:0] _e_2692;
    (* src = "src/cmp.spade:38,14" *)
    logic[2:0] _e_2690;
    (* src = "src/cmp.spade:38,14" *)
    logic[31:0] b_n3;
    logic _e_8285;
    logic _e_8288;
    logic _e_8290;
    logic _e_8291;
    (* src = "src/cmp.spade:38,47" *)
    logic _e_2697;
    (* src = "src/cmp.spade:38,66" *)
    logic _e_2700;
    (* src = "src/cmp.spade:38,47" *)
    logic _e_2696;
    (* src = "src/cmp.spade:38,40" *)
    logic[31:0] _e_2695;
    (* src = "src/cmp.spade:38,35" *)
    logic[32:0] _e_2694;
    (* src = "src/cmp.spade:39,9" *)
    logic[34:0] _e_2705;
    (* src = "src/cmp.spade:39,14" *)
    logic[2:0] _e_2703;
    (* src = "src/cmp.spade:39,14" *)
    logic[31:0] b_n4;
    logic _e_8293;
    logic _e_8296;
    logic _e_8298;
    logic _e_8299;
    (* src = "src/cmp.spade:39,47" *)
    logic _e_2709;
    (* src = "src/cmp.spade:39,40" *)
    logic[31:0] _e_2708;
    (* src = "src/cmp.spade:39,35" *)
    logic[32:0] _e_2707;
    (* src = "src/cmp.spade:40,9" *)
    logic[34:0] _e_2714;
    (* src = "src/cmp.spade:40,14" *)
    logic[2:0] _e_2712;
    (* src = "src/cmp.spade:40,14" *)
    logic[31:0] b_n5;
    logic _e_8301;
    logic _e_8304;
    logic _e_8306;
    logic _e_8307;
    (* src = "src/cmp.spade:40,47" *)
    logic _e_2719;
    (* src = "src/cmp.spade:40,58" *)
    logic _e_2722;
    (* src = "src/cmp.spade:40,47" *)
    logic _e_2718;
    (* src = "src/cmp.spade:40,40" *)
    logic[31:0] _e_2717;
    (* src = "src/cmp.spade:40,35" *)
    logic[32:0] _e_2716;
    logic _e_8309;
    (* src = "src/cmp.spade:41,35" *)
    logic[32:0] _e_2726;
    (* src = "src/cmp.spade:34,36" *)
    logic[32:0] \result ;
    (* src = "src/cmp.spade:45,51" *)
    logic[32:0] _e_2731;
    (* src = "src/cmp.spade:45,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2653 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_8255 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_8256 = 1;
    assign _e_8257 = _e_8255 && _e_8256;
    assign _e_8259 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8257, _e_8259})
            2'b1?: _e_2654 = \v ;
            2'b01: _e_2654 = \a ;
            2'b?: _e_2654 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \a  <= _e_2653;
        end
        else begin
            \a  <= _e_2654;
        end
    end
    assign _e_2665 = \trig [34:0];
    assign _e_2663 = _e_2665[34:32];
    assign \b  = _e_2665[31:0];
    assign _e_8261 = \trig [35] == 1'd1;
    assign _e_8264 = _e_2663[2:0] == 3'd0;
    localparam[0:0] _e_8265 = 1;
    assign _e_8266 = _e_8264 && _e_8265;
    assign _e_8267 = _e_8261 && _e_8266;
    assign _e_2669 = \a  == \b ;
    (* src = "src/cmp.spade:35,40" *)
    \tta::cmp::to_u32  to_u32_0(.x_i(_e_2669), .output__(_e_2668));
    assign _e_2667 = {1'd1, _e_2668};
    assign _e_2674 = \trig [34:0];
    assign _e_2672 = _e_2674[34:32];
    assign b_n1 = _e_2674[31:0];
    assign _e_8269 = \trig [35] == 1'd1;
    assign _e_8272 = _e_2672[2:0] == 3'd1;
    localparam[0:0] _e_8273 = 1;
    assign _e_8274 = _e_8272 && _e_8273;
    assign _e_8275 = _e_8269 && _e_8274;
    assign _e_2678 = \a  != b_n1;
    (* src = "src/cmp.spade:36,40" *)
    \tta::cmp::to_u32  to_u32_1(.x_i(_e_2678), .output__(_e_2677));
    assign _e_2676 = {1'd1, _e_2677};
    assign _e_2683 = \trig [34:0];
    assign _e_2681 = _e_2683[34:32];
    assign b_n2 = _e_2683[31:0];
    assign _e_8277 = \trig [35] == 1'd1;
    assign _e_8280 = _e_2681[2:0] == 3'd2;
    localparam[0:0] _e_8281 = 1;
    assign _e_8282 = _e_8280 && _e_8281;
    assign _e_8283 = _e_8277 && _e_8282;
    (* src = "src/cmp.spade:37,47" *)
    \tta::cmp::signed_lt  signed_lt_0(.a_i(\a ), .b_i(b_n2), .output__(_e_2687));
    (* src = "src/cmp.spade:37,40" *)
    \tta::cmp::to_u32  to_u32_2(.x_i(_e_2687), .output__(_e_2686));
    assign _e_2685 = {1'd1, _e_2686};
    assign _e_2692 = \trig [34:0];
    assign _e_2690 = _e_2692[34:32];
    assign b_n3 = _e_2692[31:0];
    assign _e_8285 = \trig [35] == 1'd1;
    assign _e_8288 = _e_2690[2:0] == 3'd3;
    localparam[0:0] _e_8289 = 1;
    assign _e_8290 = _e_8288 && _e_8289;
    assign _e_8291 = _e_8285 && _e_8290;
    (* src = "src/cmp.spade:38,47" *)
    \tta::cmp::signed_lt  signed_lt_1(.a_i(\a ), .b_i(b_n3), .output__(_e_2697));
    assign _e_2700 = \a  == b_n3;
    assign _e_2696 = _e_2697 || _e_2700;
    (* src = "src/cmp.spade:38,40" *)
    \tta::cmp::to_u32  to_u32_3(.x_i(_e_2696), .output__(_e_2695));
    assign _e_2694 = {1'd1, _e_2695};
    assign _e_2705 = \trig [34:0];
    assign _e_2703 = _e_2705[34:32];
    assign b_n4 = _e_2705[31:0];
    assign _e_8293 = \trig [35] == 1'd1;
    assign _e_8296 = _e_2703[2:0] == 3'd4;
    localparam[0:0] _e_8297 = 1;
    assign _e_8298 = _e_8296 && _e_8297;
    assign _e_8299 = _e_8293 && _e_8298;
    assign _e_2709 = \a  < b_n4;
    (* src = "src/cmp.spade:39,40" *)
    \tta::cmp::to_u32  to_u32_4(.x_i(_e_2709), .output__(_e_2708));
    assign _e_2707 = {1'd1, _e_2708};
    assign _e_2714 = \trig [34:0];
    assign _e_2712 = _e_2714[34:32];
    assign b_n5 = _e_2714[31:0];
    assign _e_8301 = \trig [35] == 1'd1;
    assign _e_8304 = _e_2712[2:0] == 3'd5;
    localparam[0:0] _e_8305 = 1;
    assign _e_8306 = _e_8304 && _e_8305;
    assign _e_8307 = _e_8301 && _e_8306;
    assign _e_2719 = \a  < b_n5;
    assign _e_2722 = \a  == b_n5;
    assign _e_2718 = _e_2719 || _e_2722;
    (* src = "src/cmp.spade:40,40" *)
    \tta::cmp::to_u32  to_u32_5(.x_i(_e_2718), .output__(_e_2717));
    assign _e_2716 = {1'd1, _e_2717};
    assign _e_8309 = \trig [35] == 1'd0;
    assign _e_2726 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8267, _e_8275, _e_8283, _e_8291, _e_8299, _e_8307, _e_8309})
            7'b1??????: \result  = _e_2667;
            7'b01?????: \result  = _e_2676;
            7'b001????: \result  = _e_2685;
            7'b0001???: \result  = _e_2694;
            7'b00001??: \result  = _e_2707;
            7'b000001?: \result  = _e_2716;
            7'b0000001: \result  = _e_2726;
            7'b?: \result  = 33'dx;
        endcase
    end
    assign _e_2731 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_2731;
        end
        else begin
            \res_reg  <= \result ;
        end
    end
    assign output__ = \res_reg ;
endmodule

module \tta::cmp::pick_cmp_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmp::pick_cmp_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmp::pick_cmp_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/cmp.spade:53,9" *)
    logic[42:0] _e_2738;
    (* src = "src/cmp.spade:53,14" *)
    logic[31:0] \x ;
    logic _e_8311;
    logic _e_8313;
    logic _e_8315;
    logic _e_8316;
    (* src = "src/cmp.spade:53,35" *)
    logic[32:0] _e_2740;
    (* src = "src/cmp.spade:54,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmp.spade:55,13" *)
    logic[42:0] _e_2746;
    (* src = "src/cmp.spade:55,18" *)
    logic[31:0] x_n1;
    logic _e_8319;
    logic _e_8321;
    logic _e_8323;
    logic _e_8324;
    (* src = "src/cmp.spade:55,39" *)
    logic[32:0] _e_2748;
    (* src = "src/cmp.spade:56,13" *)
    logic[43:0] __n1;
    (* src = "src/cmp.spade:56,18" *)
    logic[32:0] _e_2751;
    (* src = "src/cmp.spade:54,14" *)
    logic[32:0] _e_2743;
    (* src = "src/cmp.spade:52,5" *)
    logic[32:0] _e_2735;
    assign _e_2738 = \m1 [42:0];
    assign \x  = _e_2738[36:5];
    assign _e_8311 = \m1 [43] == 1'd1;
    assign _e_8313 = _e_2738[42:37] == 6'd11;
    localparam[0:0] _e_8314 = 1;
    assign _e_8315 = _e_8313 && _e_8314;
    assign _e_8316 = _e_8311 && _e_8315;
    assign _e_2740 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8317 = 1;
    assign _e_2746 = \m0 [42:0];
    assign x_n1 = _e_2746[36:5];
    assign _e_8319 = \m0 [43] == 1'd1;
    assign _e_8321 = _e_2746[42:37] == 6'd11;
    localparam[0:0] _e_8322 = 1;
    assign _e_8323 = _e_8321 && _e_8322;
    assign _e_8324 = _e_8319 && _e_8323;
    assign _e_2748 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8325 = 1;
    assign _e_2751 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8324, _e_8325})
            2'b1?: _e_2743 = _e_2748;
            2'b01: _e_2743 = _e_2751;
            2'b?: _e_2743 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8316, _e_8317})
            2'b1?: _e_2735 = _e_2740;
            2'b01: _e_2735 = _e_2743;
            2'b?: _e_2735 = 33'dx;
        endcase
    end
    assign output__ = _e_2735;
endmodule

module \tta::cmp::pick_cmp_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[35:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmp::pick_cmp_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmp::pick_cmp_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/cmp.spade:62,9" *)
    logic[42:0] _e_2757;
    (* src = "src/cmp.spade:62,14" *)
    logic[2:0] \op ;
    (* src = "src/cmp.spade:62,14" *)
    logic[31:0] \x ;
    logic _e_8327;
    logic _e_8329;
    logic _e_8332;
    logic _e_8333;
    logic _e_8334;
    (* src = "src/cmp.spade:62,44" *)
    logic[34:0] _e_2760;
    (* src = "src/cmp.spade:62,39" *)
    logic[35:0] _e_2759;
    (* src = "src/cmp.spade:63,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmp.spade:64,13" *)
    logic[42:0] _e_2768;
    (* src = "src/cmp.spade:64,18" *)
    logic[2:0] op_n1;
    (* src = "src/cmp.spade:64,18" *)
    logic[31:0] x_n1;
    logic _e_8337;
    logic _e_8339;
    logic _e_8342;
    logic _e_8343;
    logic _e_8344;
    (* src = "src/cmp.spade:64,48" *)
    logic[34:0] _e_2771;
    (* src = "src/cmp.spade:64,43" *)
    logic[35:0] _e_2770;
    (* src = "src/cmp.spade:65,13" *)
    logic[43:0] __n1;
    (* src = "src/cmp.spade:65,18" *)
    logic[35:0] _e_2775;
    (* src = "src/cmp.spade:63,14" *)
    logic[35:0] _e_2764;
    (* src = "src/cmp.spade:61,5" *)
    logic[35:0] _e_2753;
    assign _e_2757 = \m1 [42:0];
    assign \op  = _e_2757[36:34];
    assign \x  = _e_2757[33:2];
    assign _e_8327 = \m1 [43] == 1'd1;
    assign _e_8329 = _e_2757[42:37] == 6'd12;
    localparam[0:0] _e_8330 = 1;
    localparam[0:0] _e_8331 = 1;
    assign _e_8332 = _e_8329 && _e_8330;
    assign _e_8333 = _e_8332 && _e_8331;
    assign _e_8334 = _e_8327 && _e_8333;
    assign _e_2760 = {\op , \x };
    assign _e_2759 = {1'd1, _e_2760};
    assign \_  = \m1 ;
    localparam[0:0] _e_8335 = 1;
    assign _e_2768 = \m0 [42:0];
    assign op_n1 = _e_2768[36:34];
    assign x_n1 = _e_2768[33:2];
    assign _e_8337 = \m0 [43] == 1'd1;
    assign _e_8339 = _e_2768[42:37] == 6'd12;
    localparam[0:0] _e_8340 = 1;
    localparam[0:0] _e_8341 = 1;
    assign _e_8342 = _e_8339 && _e_8340;
    assign _e_8343 = _e_8342 && _e_8341;
    assign _e_8344 = _e_8337 && _e_8343;
    assign _e_2771 = {op_n1, x_n1};
    assign _e_2770 = {1'd1, _e_2771};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8345 = 1;
    assign _e_2775 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_8344, _e_8345})
            2'b1?: _e_2764 = _e_2770;
            2'b01: _e_2764 = _e_2775;
            2'b?: _e_2764 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8334, _e_8335})
            2'b1?: _e_2753 = _e_2759;
            2'b01: _e_2753 = _e_2764;
            2'b?: _e_2753 = 36'dx;
        endcase
    end
    assign output__ = _e_2753;
endmodule

module \tta::cmp::to_u32  (
        input x_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmp::to_u32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmp::to_u32 );
        end
    end
    `endif
    logic \x ;
    assign \x  = x_i;
    (* src = "src/cmp.spade:72,5" *)
    logic[31:0] _e_2777;
    localparam[31:0] _e_2780 = 32'd1;
    localparam[31:0] _e_2782 = 32'd0;
    assign _e_2777 = \x  ? _e_2780 : _e_2782;
    assign output__ = _e_2777;
endmodule

module \tta::cmp::signed_lt  (
        input[31:0] a_i,
        input[31:0] b_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmp::signed_lt" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmp::signed_lt );
        end
    end
    `endif
    logic[31:0] \a ;
    assign \a  = a_i;
    logic[31:0] \b ;
    assign \b  = b_i;
    (* src = "src/cmp.spade:81,29" *)
    logic[31:0] _e_2786;
    (* src = "src/cmp.spade:81,29" *)
    logic[31:0] _e_2785;
    (* src = "src/cmp.spade:81,23" *)
    logic \sa ;
    (* src = "src/cmp.spade:82,29" *)
    logic[31:0] _e_2793;
    (* src = "src/cmp.spade:82,29" *)
    logic[31:0] _e_2792;
    (* src = "src/cmp.spade:82,23" *)
    logic \sb ;
    (* src = "src/cmp.spade:83,8" *)
    logic _e_2799;
    (* src = "src/cmp.spade:84,9" *)
    logic _e_2803;
    (* src = "src/cmp.spade:86,9" *)
    logic _e_2807;
    (* src = "src/cmp.spade:83,5" *)
    logic _e_2798;
    localparam[31:0] _e_2788 = 32'd31;
    assign _e_2786 = \a  >> _e_2788;
    localparam[31:0] _e_2789 = 32'd1;
    assign _e_2785 = _e_2786 & _e_2789;
    assign \sa  = _e_2785[0:0];
    localparam[31:0] _e_2795 = 32'd31;
    assign _e_2793 = \b  >> _e_2795;
    localparam[31:0] _e_2796 = 32'd1;
    assign _e_2792 = _e_2793 & _e_2796;
    assign \sb  = _e_2792[0:0];
    assign _e_2799 = \sa  != \sb ;
    localparam[0:0] _e_2805 = 1;
    assign _e_2803 = \sa  == _e_2805;
    assign _e_2807 = \a  < \b ;
    assign _e_2798 = _e_2799 ? _e_2803 : _e_2807;
    assign output__ = _e_2798;
endmodule

module \tta::gpi::gpi16  (
        input clk_i,
        input rst_i,
        input[15:0] pins_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::gpi::gpi16" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::gpi::gpi16 );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[15:0] \pins ;
    assign \pins  = pins_i;
    logic[31:0] _e_2815;
    (* src = "src/gpi.spade:15,12" *)
    reg[31:0] \s1 ;
    (* src = "src/gpi.spade:16,12" *)
    reg[31:0] \s2 ;
    (* src = "src/gpi.spade:17,3" *)
    logic[32:0] _e_2822;
    localparam[31:0] _e_2814 = 32'd0;
    assign _e_2815 = {16'b0, \pins };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s1  <= _e_2814;
        end
        else begin
            \s1  <= _e_2815;
        end
    end
    localparam[31:0] _e_2820 = 32'd0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s2  <= _e_2820;
        end
        else begin
            \s2  <= \s1 ;
        end
    end
    assign _e_2822 = {1'd1, \s2 };
    assign output__ = _e_2822;
endmodule

module \tta::pc::pc_fu  (
        input clk_i,
        input rst_i,
        input[10:0] jump_to_i,
        input[10:0] bt_i,
        output[9:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::pc::pc_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::pc::pc_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[10:0] \jump_to ;
    assign \jump_to  = jump_to_i;
    logic[10:0] \bt ;
    assign \bt  = bt_i;
    (* src = "src/pc.spade:16,49" *)
    logic[21:0] _e_2830;
    (* src = "src/pc.spade:17,9" *)
    logic[21:0] _e_2837;
    (* src = "src/pc.spade:17,9" *)
    logic[10:0] _e_2835;
    (* src = "src/pc.spade:17,10" *)
    logic[9:0] \bt_target ;
    (* src = "src/pc.spade:17,9" *)
    logic[10:0] \_ ;
    logic _e_8348;
    logic _e_8350;
    logic _e_8352;
    (* src = "src/pc.spade:18,9" *)
    logic[21:0] _e_2842;
    (* src = "src/pc.spade:18,9" *)
    logic[10:0] _e_2839;
    (* src = "src/pc.spade:18,9" *)
    logic[10:0] _e_2841;
    (* src = "src/pc.spade:18,16" *)
    logic[9:0] \pc_target ;
    logic _e_8355;
    logic _e_8357;
    logic _e_8359;
    logic _e_8360;
    (* src = "src/pc.spade:19,9" *)
    logic[21:0] _e_2846;
    (* src = "src/pc.spade:19,9" *)
    logic[10:0] _e_2844;
    (* src = "src/pc.spade:19,9" *)
    logic[10:0] _e_2845;
    logic _e_8363;
    logic _e_8365;
    logic _e_8366;
    (* src = "src/pc.spade:19,42" *)
    logic[10:0] _e_2848;
    (* src = "src/pc.spade:19,36" *)
    logic[9:0] _e_2847;
    (* src = "src/pc.spade:16,43" *)
    logic[9:0] _e_2829;
    (* src = "src/pc.spade:16,14" *)
    reg[9:0] \pc ;
    localparam[9:0] _e_2828 = 0;
    assign _e_2830 = {\bt , \jump_to };
    assign _e_2837 = _e_2830;
    assign _e_2835 = _e_2830[21:11];
    assign \bt_target  = _e_2835[9:0];
    assign \_  = _e_2830[10:0];
    assign _e_8348 = _e_2835[10] == 1'd1;
    localparam[0:0] _e_8349 = 1;
    assign _e_8350 = _e_8348 && _e_8349;
    localparam[0:0] _e_8351 = 1;
    assign _e_8352 = _e_8350 && _e_8351;
    assign _e_2842 = _e_2830;
    assign _e_2839 = _e_2830[21:11];
    assign _e_2841 = _e_2830[10:0];
    assign \pc_target  = _e_2841[9:0];
    assign _e_8355 = _e_2839[10] == 1'd0;
    assign _e_8357 = _e_2841[10] == 1'd1;
    localparam[0:0] _e_8358 = 1;
    assign _e_8359 = _e_8357 && _e_8358;
    assign _e_8360 = _e_8355 && _e_8359;
    assign _e_2846 = _e_2830;
    assign _e_2844 = _e_2830[21:11];
    assign _e_2845 = _e_2830[10:0];
    assign _e_8363 = _e_2844[10] == 1'd0;
    assign _e_8365 = _e_2845[10] == 1'd0;
    assign _e_8366 = _e_8363 && _e_8365;
    localparam[9:0] _e_2850 = 1;
    assign _e_2848 = \pc  + _e_2850;
    assign _e_2847 = _e_2848[9:0];
    always_comb begin
        priority casez ({_e_8352, _e_8360, _e_8366})
            3'b1??: _e_2829 = \bt_target ;
            3'b01?: _e_2829 = \pc_target ;
            3'b001: _e_2829 = _e_2847;
            3'b?: _e_2829 = 10'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \pc  <= _e_2828;
        end
        else begin
            \pc  <= _e_2829;
        end
    end
    assign output__ = \pc ;
endmodule

module \tta::pc::pick_pc_jump  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[10:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::pc::pick_pc_jump" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::pc::pick_pc_jump );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/pc.spade:27,9" *)
    logic[42:0] _e_2856;
    (* src = "src/pc.spade:27,14" *)
    logic[9:0] \a ;
    logic _e_8368;
    logic _e_8370;
    logic _e_8372;
    logic _e_8373;
    (* src = "src/pc.spade:27,34" *)
    logic[10:0] _e_2858;
    (* src = "src/pc.spade:28,9" *)
    logic[43:0] \_ ;
    (* src = "src/pc.spade:28,25" *)
    logic[42:0] _e_2864;
    (* src = "src/pc.spade:28,30" *)
    logic[9:0] a_n1;
    logic _e_8376;
    logic _e_8378;
    logic _e_8380;
    logic _e_8381;
    (* src = "src/pc.spade:28,50" *)
    logic[10:0] _e_2866;
    (* src = "src/pc.spade:28,59" *)
    logic[43:0] __n1;
    (* src = "src/pc.spade:28,64" *)
    logic[10:0] _e_2869;
    (* src = "src/pc.spade:28,14" *)
    logic[10:0] _e_2861;
    (* src = "src/pc.spade:26,5" *)
    logic[10:0] _e_2853;
    assign _e_2856 = \m1 [42:0];
    assign \a  = _e_2856[36:27];
    assign _e_8368 = \m1 [43] == 1'd1;
    assign _e_8370 = _e_2856[42:37] == 6'd3;
    localparam[0:0] _e_8371 = 1;
    assign _e_8372 = _e_8370 && _e_8371;
    assign _e_8373 = _e_8368 && _e_8372;
    assign _e_2858 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8374 = 1;
    assign _e_2864 = \m0 [42:0];
    assign a_n1 = _e_2864[36:27];
    assign _e_8376 = \m0 [43] == 1'd1;
    assign _e_8378 = _e_2864[42:37] == 6'd3;
    localparam[0:0] _e_8379 = 1;
    assign _e_8380 = _e_8378 && _e_8379;
    assign _e_8381 = _e_8376 && _e_8380;
    assign _e_2866 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8382 = 1;
    assign _e_2869 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_8381, _e_8382})
            2'b1?: _e_2861 = _e_2866;
            2'b01: _e_2861 = _e_2869;
            2'b?: _e_2861 = 11'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8373, _e_8374})
            2'b1?: _e_2853 = _e_2858;
            2'b01: _e_2853 = _e_2861;
            2'b?: _e_2853 = 11'dx;
        endcase
    end
    assign output__ = _e_2853;
endmodule

module \tta::gpo::gpo16  (
        input clk_i,
        input rst_i,
        input[16:0] wr_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::gpo::gpo16" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::gpo::gpo16 );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[16:0] \wr ;
    assign \wr  = wr_i;
    (* src = "src/gpo.spade:17,7" *)
    logic[15:0] \v ;
    logic _e_8384;
    logic _e_8386;
    logic _e_8388;
    (* src = "src/gpo.spade:16,5" *)
    logic[15:0] _e_2875;
    (* src = "src/gpo.spade:15,12" *)
    reg[15:0] \outv ;
    localparam[15:0] _e_2874 = 0;
    assign \v  = \wr [15:0];
    assign _e_8384 = \wr [16] == 1'd1;
    localparam[0:0] _e_8385 = 1;
    assign _e_8386 = _e_8384 && _e_8385;
    assign _e_8388 = \wr [16] == 1'd0;
    always_comb begin
        priority casez ({_e_8386, _e_8388})
            2'b1?: _e_2875 = \v ;
            2'b01: _e_2875 = \outv ;
            2'b?: _e_2875 = 16'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \outv  <= _e_2874;
        end
        else begin
            \outv  <= _e_2875;
        end
    end
    assign output__ = \outv ;
endmodule

module \tta::gpo::pick_gpo16  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[16:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::gpo::pick_gpo16" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::gpo::pick_gpo16 );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/gpo.spade:27,9" *)
    logic[42:0] _e_2887;
    (* src = "src/gpo.spade:27,14" *)
    logic[15:0] \x ;
    logic _e_8390;
    logic _e_8392;
    logic _e_8394;
    logic _e_8395;
    (* src = "src/gpo.spade:27,34" *)
    logic[16:0] _e_2889;
    (* src = "src/gpo.spade:28,9" *)
    logic[43:0] \_ ;
    (* src = "src/gpo.spade:29,13" *)
    logic[42:0] _e_2895;
    (* src = "src/gpo.spade:29,18" *)
    logic[15:0] x_n1;
    logic _e_8398;
    logic _e_8400;
    logic _e_8402;
    logic _e_8403;
    (* src = "src/gpo.spade:29,38" *)
    logic[16:0] _e_2897;
    (* src = "src/gpo.spade:30,13" *)
    logic[43:0] __n1;
    (* src = "src/gpo.spade:30,18" *)
    logic[16:0] _e_2900;
    (* src = "src/gpo.spade:28,14" *)
    logic[16:0] _e_2892;
    (* src = "src/gpo.spade:26,5" *)
    logic[16:0] _e_2884;
    assign _e_2887 = \m1 [42:0];
    assign \x  = _e_2887[36:21];
    assign _e_8390 = \m1 [43] == 1'd1;
    assign _e_8392 = _e_2887[42:37] == 6'd10;
    localparam[0:0] _e_8393 = 1;
    assign _e_8394 = _e_8392 && _e_8393;
    assign _e_8395 = _e_8390 && _e_8394;
    assign _e_2889 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8396 = 1;
    assign _e_2895 = \m0 [42:0];
    assign x_n1 = _e_2895[36:21];
    assign _e_8398 = \m0 [43] == 1'd1;
    assign _e_8400 = _e_2895[42:37] == 6'd10;
    localparam[0:0] _e_8401 = 1;
    assign _e_8402 = _e_8400 && _e_8401;
    assign _e_8403 = _e_8398 && _e_8402;
    assign _e_2897 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8404 = 1;
    assign _e_2900 = {1'd0, 16'bX};
    always_comb begin
        priority casez ({_e_8403, _e_8404})
            2'b1?: _e_2892 = _e_2897;
            2'b01: _e_2892 = _e_2900;
            2'b?: _e_2892 = 17'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8395, _e_8396})
            2'b1?: _e_2884 = _e_2889;
            2'b01: _e_2884 = _e_2892;
            2'b?: _e_2884 = 17'dx;
        endcase
    end
    assign output__ = _e_2884;
endmodule

module \tta::spi::spi_in  (
        input clk_i,
        input rst_i,
        input[8:0] miso_byte_i,
        input pop_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::spi::spi_in" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::spi::spi_in );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[8:0] \miso_byte ;
    assign \miso_byte  = miso_byte_i;
    logic \pop ;
    assign \pop  = pop_i;
    (* src = "src/spi.spade:17,16" *)
    logic[14:0] \data ;
    (* src = "src/spi.spade:18,48" *)
    logic[32:0] _e_2911;
    (* src = "src/spi.spade:19,7" *)
    logic[31:0] \b ;
    logic _e_8406;
    logic _e_8408;
    logic[31:0] _e_2917;
    (* src = "src/spi.spade:19,18" *)
    logic[32:0] _e_2916;
    logic _e_8410;
    (* src = "src/spi.spade:20,15" *)
    logic[32:0] _e_2920;
    (* src = "src/spi.spade:18,56" *)
    logic[32:0] _e_2912;
    (* src = "src/spi.spade:18,14" *)
    reg[32:0] data_n1;
    (* src = "src/spi.spade:17,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\miso_byte ), .pop_i(\pop ), .output__(\data ));
    assign _e_2911 = {1'd0, 32'bX};
    assign \b  = data_n1[31:0];
    assign _e_8406 = data_n1[32] == 1'd1;
    localparam[0:0] _e_8407 = 1;
    assign _e_8408 = _e_8406 && _e_8407;
    assign _e_2917 = \b ;
    assign _e_2916 = {1'd1, _e_2917};
    assign _e_8410 = data_n1[32] == 1'd0;
    assign _e_2920 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8408, _e_8410})
            2'b1?: _e_2912 = _e_2916;
            2'b01: _e_2912 = _e_2920;
            2'b?: _e_2912 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2911;
        end
        else begin
            data_n1 <= _e_2912;
        end
    end
    assign output__ = data_n1;
endmodule

module \tta::spi::spi_out8  (
        input clk_i,
        input rst_i,
        input[8:0] byte_to_write_i,
        output[8:0] mosi_o,
        input spi_busy_i
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::spi::spi_out8" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::spi::spi_out8 );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[8:0] \byte_to_write ;
    assign \byte_to_write  = byte_to_write_i;
    logic[8:0] \mosi_mut ;
    assign mosi_o = \mosi_mut ;
    logic \spi_busy ;
    assign \spi_busy  = spi_busy_i;
    (* src = "src/spi.spade:44,65" *)
    logic _e_2927;
    (* src = "src/spi.spade:44,16" *)
    logic[14:0] \data ;
    (* src = "src/spi.spade:45,47" *)
    logic[8:0] _e_2933;
    (* src = "src/spi.spade:46,7" *)
    logic[7:0] \b ;
    logic _e_8412;
    logic _e_8414;
    (* src = "src/spi.spade:46,18" *)
    logic[8:0] _e_2938;
    logic _e_8416;
    (* src = "src/spi.spade:47,15" *)
    logic[8:0] _e_2941;
    (* src = "src/spi.spade:45,55" *)
    logic[8:0] _e_2934;
    (* src = "src/spi.spade:45,14" *)
    reg[8:0] data_n1;
    assign _e_2927 = !\spi_busy ;
    (* src = "src/spi.spade:44,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\byte_to_write ), .pop_i(_e_2927), .output__(\data ));
    assign _e_2933 = {1'd0, 8'bX};
    assign \b  = data_n1[7:0];
    assign _e_8412 = data_n1[8] == 1'd1;
    localparam[0:0] _e_8413 = 1;
    assign _e_8414 = _e_8412 && _e_8413;
    assign _e_2938 = {1'd1, \b };
    assign _e_8416 = data_n1[8] == 1'd0;
    assign _e_2941 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8414, _e_8416})
            2'b1?: _e_2934 = _e_2938;
            2'b01: _e_2934 = _e_2941;
            2'b?: _e_2934 = 9'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2933;
        end
        else begin
            data_n1 <= _e_2934;
        end
    end
    assign \mosi_mut  = data_n1;
endmodule

module \tta::spi::pick_spi_inpop  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::spi::pick_spi_inpop" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::spi::pick_spi_inpop );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/spi.spade:57,9" *)
    logic[42:0] _e_2948;
    logic _e_8418;
    logic _e_8420;
    logic _e_8421;
    (* src = "src/spi.spade:58,9" *)
    logic[43:0] \_ ;
    (* src = "src/spi.spade:59,13" *)
    logic[42:0] _e_2954;
    logic _e_8424;
    logic _e_8426;
    logic _e_8427;
    (* src = "src/spi.spade:60,13" *)
    logic[43:0] __n1;
    (* src = "src/spi.spade:58,14" *)
    logic _e_2952;
    (* src = "src/spi.spade:56,5" *)
    logic _e_2946;
    assign _e_2948 = \m1 [42:0];
    assign _e_8418 = \m1 [43] == 1'd1;
    assign _e_8420 = _e_2948[42:37] == 6'd42;
    assign _e_8421 = _e_8418 && _e_8420;
    localparam[0:0] _e_2950 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_8422 = 1;
    assign _e_2954 = \m0 [42:0];
    assign _e_8424 = \m0 [43] == 1'd1;
    assign _e_8426 = _e_2954[42:37] == 6'd42;
    assign _e_8427 = _e_8424 && _e_8426;
    localparam[0:0] _e_2956 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_8428 = 1;
    localparam[0:0] _e_2958 = 0;
    always_comb begin
        priority casez ({_e_8427, _e_8428})
            2'b1?: _e_2952 = _e_2956;
            2'b01: _e_2952 = _e_2958;
            2'b?: _e_2952 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8421, _e_8422})
            2'b1?: _e_2946 = _e_2950;
            2'b01: _e_2946 = _e_2952;
            2'b?: _e_2946 = 1'dx;
        endcase
    end
    assign output__ = _e_2946;
endmodule

module \tta::spi::pick_spi_out8  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[8:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::spi::pick_spi_out8" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::spi::pick_spi_out8 );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/spi.spade:66,9" *)
    logic[42:0] _e_2963;
    (* src = "src/spi.spade:66,14" *)
    logic[7:0] \x ;
    logic _e_8430;
    logic _e_8432;
    logic _e_8434;
    logic _e_8435;
    (* src = "src/spi.spade:66,35" *)
    logic[8:0] _e_2965;
    (* src = "src/spi.spade:67,9" *)
    logic[43:0] \_ ;
    (* src = "src/spi.spade:68,13" *)
    logic[42:0] _e_2971;
    (* src = "src/spi.spade:68,18" *)
    logic[7:0] x_n1;
    logic _e_8438;
    logic _e_8440;
    logic _e_8442;
    logic _e_8443;
    (* src = "src/spi.spade:68,39" *)
    logic[8:0] _e_2973;
    (* src = "src/spi.spade:69,13" *)
    logic[43:0] __n1;
    (* src = "src/spi.spade:69,18" *)
    logic[8:0] _e_2976;
    (* src = "src/spi.spade:67,14" *)
    logic[8:0] _e_2968;
    (* src = "src/spi.spade:65,5" *)
    logic[8:0] _e_2960;
    assign _e_2963 = \m1 [42:0];
    assign \x  = _e_2963[36:29];
    assign _e_8430 = \m1 [43] == 1'd1;
    assign _e_8432 = _e_2963[42:37] == 6'd20;
    localparam[0:0] _e_8433 = 1;
    assign _e_8434 = _e_8432 && _e_8433;
    assign _e_8435 = _e_8430 && _e_8434;
    assign _e_2965 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8436 = 1;
    assign _e_2971 = \m0 [42:0];
    assign x_n1 = _e_2971[36:29];
    assign _e_8438 = \m0 [43] == 1'd1;
    assign _e_8440 = _e_2971[42:37] == 6'd20;
    localparam[0:0] _e_8441 = 1;
    assign _e_8442 = _e_8440 && _e_8441;
    assign _e_8443 = _e_8438 && _e_8442;
    assign _e_2973 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8444 = 1;
    assign _e_2976 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8443, _e_8444})
            2'b1?: _e_2968 = _e_2973;
            2'b01: _e_2968 = _e_2976;
            2'b?: _e_2968 = 9'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8435, _e_8436})
            2'b1?: _e_2960 = _e_2965;
            2'b01: _e_2960 = _e_2968;
            2'b?: _e_2960 = 9'dx;
        endcase
    end
    assign output__ = _e_2960;
endmodule

module \tta::lalu::lalu_fu  (
        input clk_i,
        input rst_i,
        input[32:0] set_op_a_i,
        input[33:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lalu::lalu_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lalu::lalu_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_op_a ;
    assign \set_op_a  = set_op_a_i;
    logic[33:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/lalu.spade:23,9" *)
    logic[31:0] \v ;
    logic _e_8446;
    logic _e_8448;
    logic _e_8450;
    (* src = "src/lalu.spade:22,45" *)
    logic[31:0] _e_2982;
    (* src = "src/lalu.spade:22,14" *)
    reg[31:0] \op_a ;
    (* src = "src/lalu.spade:29,9" *)
    logic[32:0] _e_2993;
    (* src = "src/lalu.spade:29,14" *)
    logic _e_2991;
    (* src = "src/lalu.spade:29,14" *)
    logic[31:0] \b ;
    logic _e_8452;
    logic _e_8455;
    logic _e_8457;
    logic _e_8458;
    (* src = "src/lalu.spade:29,46" *)
    logic[32:0] _e_2997;
    (* src = "src/lalu.spade:29,40" *)
    logic[31:0] _e_2996;
    (* src = "src/lalu.spade:29,35" *)
    logic[32:0] _e_2995;
    (* src = "src/lalu.spade:30,9" *)
    logic[32:0] _e_3002;
    (* src = "src/lalu.spade:30,14" *)
    logic _e_3000;
    (* src = "src/lalu.spade:30,14" *)
    logic[31:0] b_n1;
    logic _e_8460;
    logic _e_8463;
    logic _e_8465;
    logic _e_8466;
    (* src = "src/lalu.spade:30,46" *)
    logic[32:0] _e_3006;
    (* src = "src/lalu.spade:30,40" *)
    logic[31:0] _e_3005;
    (* src = "src/lalu.spade:30,35" *)
    logic[32:0] _e_3004;
    logic _e_8468;
    (* src = "src/lalu.spade:31,34" *)
    logic[32:0] _e_3010;
    (* src = "src/lalu.spade:28,36" *)
    logic[32:0] \result ;
    (* src = "src/lalu.spade:35,51" *)
    logic[32:0] _e_3015;
    (* src = "src/lalu.spade:35,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2981 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_8446 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_8447 = 1;
    assign _e_8448 = _e_8446 && _e_8447;
    assign _e_8450 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8448, _e_8450})
            2'b1?: _e_2982 = \v ;
            2'b01: _e_2982 = \op_a ;
            2'b?: _e_2982 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_2981;
        end
        else begin
            \op_a  <= _e_2982;
        end
    end
    assign _e_2993 = \trig [32:0];
    assign _e_2991 = _e_2993[32];
    assign \b  = _e_2993[31:0];
    assign _e_8452 = \trig [33] == 1'd1;
    assign _e_8455 = _e_2991 == 1'd0;
    localparam[0:0] _e_8456 = 1;
    assign _e_8457 = _e_8455 && _e_8456;
    assign _e_8458 = _e_8452 && _e_8457;
    assign _e_2997 = \op_a  + \b ;
    assign _e_2996 = _e_2997[31:0];
    assign _e_2995 = {1'd1, _e_2996};
    assign _e_3002 = \trig [32:0];
    assign _e_3000 = _e_3002[32];
    assign b_n1 = _e_3002[31:0];
    assign _e_8460 = \trig [33] == 1'd1;
    assign _e_8463 = _e_3000 == 1'd1;
    localparam[0:0] _e_8464 = 1;
    assign _e_8465 = _e_8463 && _e_8464;
    assign _e_8466 = _e_8460 && _e_8465;
    assign _e_3006 = \op_a  - b_n1;
    assign _e_3005 = _e_3006[31:0];
    assign _e_3004 = {1'd1, _e_3005};
    assign _e_8468 = \trig [33] == 1'd0;
    assign _e_3010 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8458, _e_8466, _e_8468})
            3'b1??: \result  = _e_2995;
            3'b01?: \result  = _e_3004;
            3'b001: \result  = _e_3010;
            3'b?: \result  = 33'dx;
        endcase
    end
    assign _e_3015 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_3015;
        end
        else begin
            \res_reg  <= \result ;
        end
    end
    assign output__ = \res_reg ;
endmodule

module \tta::lalu::pick_lalu_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lalu::pick_lalu_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lalu::pick_lalu_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/lalu.spade:43,9" *)
    logic[42:0] _e_3022;
    (* src = "src/lalu.spade:43,14" *)
    logic[31:0] \x ;
    logic _e_8470;
    logic _e_8472;
    logic _e_8474;
    logic _e_8475;
    (* src = "src/lalu.spade:43,36" *)
    logic[32:0] _e_3024;
    (* src = "src/lalu.spade:44,9" *)
    logic[43:0] \_ ;
    (* src = "src/lalu.spade:45,13" *)
    logic[42:0] _e_3030;
    (* src = "src/lalu.spade:45,18" *)
    logic[31:0] x_n1;
    logic _e_8478;
    logic _e_8480;
    logic _e_8482;
    logic _e_8483;
    (* src = "src/lalu.spade:45,40" *)
    logic[32:0] _e_3032;
    (* src = "src/lalu.spade:46,13" *)
    logic[43:0] __n1;
    (* src = "src/lalu.spade:46,18" *)
    logic[32:0] _e_3035;
    (* src = "src/lalu.spade:44,14" *)
    logic[32:0] _e_3027;
    (* src = "src/lalu.spade:42,5" *)
    logic[32:0] _e_3019;
    assign _e_3022 = \m1 [42:0];
    assign \x  = _e_3022[36:5];
    assign _e_8470 = \m1 [43] == 1'd1;
    assign _e_8472 = _e_3022[42:37] == 6'd14;
    localparam[0:0] _e_8473 = 1;
    assign _e_8474 = _e_8472 && _e_8473;
    assign _e_8475 = _e_8470 && _e_8474;
    assign _e_3024 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8476 = 1;
    assign _e_3030 = \m0 [42:0];
    assign x_n1 = _e_3030[36:5];
    assign _e_8478 = \m0 [43] == 1'd1;
    assign _e_8480 = _e_3030[42:37] == 6'd14;
    localparam[0:0] _e_8481 = 1;
    assign _e_8482 = _e_8480 && _e_8481;
    assign _e_8483 = _e_8478 && _e_8482;
    assign _e_3032 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8484 = 1;
    assign _e_3035 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8483, _e_8484})
            2'b1?: _e_3027 = _e_3032;
            2'b01: _e_3027 = _e_3035;
            2'b?: _e_3027 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8475, _e_8476})
            2'b1?: _e_3019 = _e_3024;
            2'b01: _e_3019 = _e_3027;
            2'b?: _e_3019 = 33'dx;
        endcase
    end
    assign output__ = _e_3019;
endmodule

module \tta::lalu::pick_lalu_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[33:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lalu::pick_lalu_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lalu::pick_lalu_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/lalu.spade:52,9" *)
    logic[42:0] _e_3041;
    (* src = "src/lalu.spade:52,14" *)
    logic \op ;
    (* src = "src/lalu.spade:52,14" *)
    logic[31:0] \x ;
    logic _e_8486;
    logic _e_8488;
    logic _e_8491;
    logic _e_8492;
    logic _e_8493;
    (* src = "src/lalu.spade:52,45" *)
    logic[32:0] _e_3044;
    (* src = "src/lalu.spade:52,40" *)
    logic[33:0] _e_3043;
    (* src = "src/lalu.spade:53,9" *)
    logic[43:0] \_ ;
    (* src = "src/lalu.spade:54,13" *)
    logic[42:0] _e_3052;
    (* src = "src/lalu.spade:54,18" *)
    logic op_n1;
    (* src = "src/lalu.spade:54,18" *)
    logic[31:0] x_n1;
    logic _e_8496;
    logic _e_8498;
    logic _e_8501;
    logic _e_8502;
    logic _e_8503;
    (* src = "src/lalu.spade:54,49" *)
    logic[32:0] _e_3055;
    (* src = "src/lalu.spade:54,44" *)
    logic[33:0] _e_3054;
    (* src = "src/lalu.spade:55,13" *)
    logic[43:0] __n1;
    (* src = "src/lalu.spade:55,18" *)
    logic[33:0] _e_3059;
    (* src = "src/lalu.spade:53,14" *)
    logic[33:0] _e_3048;
    (* src = "src/lalu.spade:51,5" *)
    logic[33:0] _e_3037;
    assign _e_3041 = \m1 [42:0];
    assign \op  = _e_3041[36:36];
    assign \x  = _e_3041[35:4];
    assign _e_8486 = \m1 [43] == 1'd1;
    assign _e_8488 = _e_3041[42:37] == 6'd15;
    localparam[0:0] _e_8489 = 1;
    localparam[0:0] _e_8490 = 1;
    assign _e_8491 = _e_8488 && _e_8489;
    assign _e_8492 = _e_8491 && _e_8490;
    assign _e_8493 = _e_8486 && _e_8492;
    assign _e_3044 = {\op , \x };
    assign _e_3043 = {1'd1, _e_3044};
    assign \_  = \m1 ;
    localparam[0:0] _e_8494 = 1;
    assign _e_3052 = \m0 [42:0];
    assign op_n1 = _e_3052[36:36];
    assign x_n1 = _e_3052[35:4];
    assign _e_8496 = \m0 [43] == 1'd1;
    assign _e_8498 = _e_3052[42:37] == 6'd15;
    localparam[0:0] _e_8499 = 1;
    localparam[0:0] _e_8500 = 1;
    assign _e_8501 = _e_8498 && _e_8499;
    assign _e_8502 = _e_8501 && _e_8500;
    assign _e_8503 = _e_8496 && _e_8502;
    assign _e_3055 = {op_n1, x_n1};
    assign _e_3054 = {1'd1, _e_3055};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8504 = 1;
    assign _e_3059 = {1'd0, 33'bX};
    always_comb begin
        priority casez ({_e_8503, _e_8504})
            2'b1?: _e_3048 = _e_3054;
            2'b01: _e_3048 = _e_3059;
            2'b?: _e_3048 = 34'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8493, _e_8494})
            2'b1?: _e_3037 = _e_3043;
            2'b01: _e_3037 = _e_3048;
            2'b?: _e_3037 = 34'dx;
        endcase
    end
    assign output__ = _e_3037;
endmodule

module \tta::tta::decode_move  (
        input[10:0] dst_i,
        input[32:0] v_i,
        output[43:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::tta::decode_move" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::tta::decode_move );
        end
    end
    `endif
    logic[10:0] \dst ;
    assign \dst  = dst_i;
    logic[32:0] \v ;
    assign \v  = v_i;
    (* src = "src/tta.spade:196,11" *)
    logic[43:0] _e_3062;
    (* src = "src/tta.spade:197,9" *)
    logic[43:0] _e_3069;
    (* src = "src/tta.spade:197,9" *)
    logic[10:0] _e_3066;
    (* src = "src/tta.spade:197,10" *)
    logic[3:0] \i ;
    (* src = "src/tta.spade:197,9" *)
    logic[32:0] _e_3068;
    (* src = "src/tta.spade:197,32" *)
    logic[31:0] \x ;
    logic _e_8507;
    logic _e_8509;
    logic _e_8511;
    logic _e_8513;
    logic _e_8514;
    (* src = "src/tta.spade:197,49" *)
    logic[42:0] _e_3071;
    (* src = "src/tta.spade:197,44" *)
    logic[43:0] _e_3070;
    (* src = "src/tta.spade:199,9" *)
    logic[43:0] _e_3077;
    (* src = "src/tta.spade:199,9" *)
    logic[10:0] _e_3074;
    (* src = "src/tta.spade:199,9" *)
    logic[32:0] _e_3076;
    (* src = "src/tta.spade:199,32" *)
    logic[31:0] x_n1;
    logic _e_8517;
    logic _e_8519;
    logic _e_8521;
    logic _e_8522;
    (* src = "src/tta.spade:199,49" *)
    logic[42:0] _e_3079;
    (* src = "src/tta.spade:199,44" *)
    logic[43:0] _e_3078;
    (* src = "src/tta.spade:200,9" *)
    logic[43:0] _e_3084;
    (* src = "src/tta.spade:200,9" *)
    logic[10:0] _e_3081;
    (* src = "src/tta.spade:200,9" *)
    logic[32:0] _e_3083;
    (* src = "src/tta.spade:200,32" *)
    logic[31:0] x_n2;
    logic _e_8525;
    logic _e_8527;
    logic _e_8529;
    logic _e_8530;
    (* src = "src/tta.spade:200,63" *)
    logic[4:0] _e_3087;
    (* src = "src/tta.spade:200,49" *)
    logic[42:0] _e_3086;
    (* src = "src/tta.spade:200,44" *)
    logic[43:0] _e_3085;
    (* src = "src/tta.spade:201,9" *)
    logic[43:0] _e_3092;
    (* src = "src/tta.spade:201,9" *)
    logic[10:0] _e_3089;
    (* src = "src/tta.spade:201,9" *)
    logic[32:0] _e_3091;
    (* src = "src/tta.spade:201,32" *)
    logic[31:0] x_n3;
    logic _e_8533;
    logic _e_8535;
    logic _e_8537;
    logic _e_8538;
    (* src = "src/tta.spade:201,63" *)
    logic[4:0] _e_3095;
    (* src = "src/tta.spade:201,49" *)
    logic[42:0] _e_3094;
    (* src = "src/tta.spade:201,44" *)
    logic[43:0] _e_3093;
    (* src = "src/tta.spade:202,9" *)
    logic[43:0] _e_3100;
    (* src = "src/tta.spade:202,9" *)
    logic[10:0] _e_3097;
    (* src = "src/tta.spade:202,9" *)
    logic[32:0] _e_3099;
    (* src = "src/tta.spade:202,32" *)
    logic[31:0] x_n4;
    logic _e_8541;
    logic _e_8543;
    logic _e_8545;
    logic _e_8546;
    (* src = "src/tta.spade:202,63" *)
    logic[4:0] _e_3103;
    (* src = "src/tta.spade:202,49" *)
    logic[42:0] _e_3102;
    (* src = "src/tta.spade:202,44" *)
    logic[43:0] _e_3101;
    (* src = "src/tta.spade:203,9" *)
    logic[43:0] _e_3108;
    (* src = "src/tta.spade:203,9" *)
    logic[10:0] _e_3105;
    (* src = "src/tta.spade:203,9" *)
    logic[32:0] _e_3107;
    (* src = "src/tta.spade:203,32" *)
    logic[31:0] x_n5;
    logic _e_8549;
    logic _e_8551;
    logic _e_8553;
    logic _e_8554;
    (* src = "src/tta.spade:203,63" *)
    logic[4:0] _e_3111;
    (* src = "src/tta.spade:203,49" *)
    logic[42:0] _e_3110;
    (* src = "src/tta.spade:203,44" *)
    logic[43:0] _e_3109;
    (* src = "src/tta.spade:204,9" *)
    logic[43:0] _e_3116;
    (* src = "src/tta.spade:204,9" *)
    logic[10:0] _e_3113;
    (* src = "src/tta.spade:204,9" *)
    logic[32:0] _e_3115;
    (* src = "src/tta.spade:204,33" *)
    logic[31:0] x_n6;
    logic _e_8557;
    logic _e_8559;
    logic _e_8561;
    logic _e_8562;
    (* src = "src/tta.spade:204,64" *)
    logic[4:0] _e_3119;
    (* src = "src/tta.spade:204,50" *)
    logic[42:0] _e_3118;
    (* src = "src/tta.spade:204,45" *)
    logic[43:0] _e_3117;
    (* src = "src/tta.spade:205,9" *)
    logic[43:0] _e_3124;
    (* src = "src/tta.spade:205,9" *)
    logic[10:0] _e_3121;
    (* src = "src/tta.spade:205,9" *)
    logic[32:0] _e_3123;
    (* src = "src/tta.spade:205,33" *)
    logic[31:0] x_n7;
    logic _e_8565;
    logic _e_8567;
    logic _e_8569;
    logic _e_8570;
    (* src = "src/tta.spade:205,64" *)
    logic[4:0] _e_3127;
    (* src = "src/tta.spade:205,50" *)
    logic[42:0] _e_3126;
    (* src = "src/tta.spade:205,45" *)
    logic[43:0] _e_3125;
    (* src = "src/tta.spade:206,9" *)
    logic[43:0] _e_3132;
    (* src = "src/tta.spade:206,9" *)
    logic[10:0] _e_3129;
    (* src = "src/tta.spade:206,9" *)
    logic[32:0] _e_3131;
    (* src = "src/tta.spade:206,33" *)
    logic[31:0] x_n8;
    logic _e_8573;
    logic _e_8575;
    logic _e_8577;
    logic _e_8578;
    (* src = "src/tta.spade:206,64" *)
    logic[4:0] _e_3135;
    (* src = "src/tta.spade:206,50" *)
    logic[42:0] _e_3134;
    (* src = "src/tta.spade:206,45" *)
    logic[43:0] _e_3133;
    (* src = "src/tta.spade:207,9" *)
    logic[43:0] _e_3140;
    (* src = "src/tta.spade:207,9" *)
    logic[10:0] _e_3137;
    (* src = "src/tta.spade:207,9" *)
    logic[32:0] _e_3139;
    (* src = "src/tta.spade:207,34" *)
    logic[31:0] x_n9;
    logic _e_8581;
    logic _e_8583;
    logic _e_8585;
    logic _e_8586;
    (* src = "src/tta.spade:207,65" *)
    logic[4:0] _e_3143;
    (* src = "src/tta.spade:207,51" *)
    logic[42:0] _e_3142;
    (* src = "src/tta.spade:207,46" *)
    logic[43:0] _e_3141;
    (* src = "src/tta.spade:208,9" *)
    logic[43:0] _e_3148;
    (* src = "src/tta.spade:208,9" *)
    logic[10:0] _e_3145;
    (* src = "src/tta.spade:208,9" *)
    logic[32:0] _e_3147;
    (* src = "src/tta.spade:208,34" *)
    logic[31:0] x_n10;
    logic _e_8589;
    logic _e_8591;
    logic _e_8593;
    logic _e_8594;
    (* src = "src/tta.spade:208,65" *)
    logic[4:0] _e_3151;
    (* src = "src/tta.spade:208,51" *)
    logic[42:0] _e_3150;
    (* src = "src/tta.spade:208,46" *)
    logic[43:0] _e_3149;
    (* src = "src/tta.spade:209,9" *)
    logic[43:0] _e_3156;
    (* src = "src/tta.spade:209,9" *)
    logic[10:0] _e_3153;
    (* src = "src/tta.spade:209,9" *)
    logic[32:0] _e_3155;
    (* src = "src/tta.spade:209,34" *)
    logic[31:0] x_n11;
    logic _e_8597;
    logic _e_8599;
    logic _e_8601;
    logic _e_8602;
    (* src = "src/tta.spade:209,65" *)
    logic[4:0] _e_3159;
    (* src = "src/tta.spade:209,51" *)
    logic[42:0] _e_3158;
    (* src = "src/tta.spade:209,46" *)
    logic[43:0] _e_3157;
    (* src = "src/tta.spade:210,9" *)
    logic[43:0] _e_3164;
    (* src = "src/tta.spade:210,9" *)
    logic[10:0] _e_3161;
    (* src = "src/tta.spade:210,9" *)
    logic[32:0] _e_3163;
    (* src = "src/tta.spade:210,33" *)
    logic[31:0] x_n12;
    logic _e_8605;
    logic _e_8607;
    logic _e_8609;
    logic _e_8610;
    (* src = "src/tta.spade:210,64" *)
    logic[4:0] _e_3167;
    (* src = "src/tta.spade:210,50" *)
    logic[42:0] _e_3166;
    (* src = "src/tta.spade:210,45" *)
    logic[43:0] _e_3165;
    (* src = "src/tta.spade:211,9" *)
    logic[43:0] _e_3172;
    (* src = "src/tta.spade:211,9" *)
    logic[10:0] _e_3169;
    (* src = "src/tta.spade:211,9" *)
    logic[32:0] _e_3171;
    (* src = "src/tta.spade:211,33" *)
    logic[31:0] x_n13;
    logic _e_8613;
    logic _e_8615;
    logic _e_8617;
    logic _e_8618;
    (* src = "src/tta.spade:211,64" *)
    logic[4:0] _e_3175;
    (* src = "src/tta.spade:211,50" *)
    logic[42:0] _e_3174;
    (* src = "src/tta.spade:211,45" *)
    logic[43:0] _e_3173;
    (* src = "src/tta.spade:212,9" *)
    logic[43:0] _e_3180;
    (* src = "src/tta.spade:212,9" *)
    logic[10:0] _e_3177;
    (* src = "src/tta.spade:212,9" *)
    logic[32:0] _e_3179;
    (* src = "src/tta.spade:212,35" *)
    logic[31:0] x_n14;
    logic _e_8621;
    logic _e_8623;
    logic _e_8625;
    logic _e_8626;
    (* src = "src/tta.spade:212,66" *)
    logic[4:0] _e_3183;
    (* src = "src/tta.spade:212,52" *)
    logic[42:0] _e_3182;
    (* src = "src/tta.spade:212,47" *)
    logic[43:0] _e_3181;
    (* src = "src/tta.spade:213,9" *)
    logic[43:0] _e_3188;
    (* src = "src/tta.spade:213,9" *)
    logic[10:0] _e_3185;
    (* src = "src/tta.spade:213,9" *)
    logic[32:0] _e_3187;
    (* src = "src/tta.spade:213,35" *)
    logic[31:0] x_n15;
    logic _e_8629;
    logic _e_8631;
    logic _e_8633;
    logic _e_8634;
    (* src = "src/tta.spade:213,66" *)
    logic[4:0] _e_3191;
    (* src = "src/tta.spade:213,52" *)
    logic[42:0] _e_3190;
    (* src = "src/tta.spade:213,47" *)
    logic[43:0] _e_3189;
    (* src = "src/tta.spade:214,9" *)
    logic[43:0] _e_3196;
    (* src = "src/tta.spade:214,9" *)
    logic[10:0] _e_3193;
    (* src = "src/tta.spade:214,9" *)
    logic[32:0] _e_3195;
    (* src = "src/tta.spade:214,35" *)
    logic[31:0] x_n16;
    logic _e_8637;
    logic _e_8639;
    logic _e_8641;
    logic _e_8642;
    (* src = "src/tta.spade:214,66" *)
    logic[4:0] _e_3199;
    (* src = "src/tta.spade:214,52" *)
    logic[42:0] _e_3198;
    (* src = "src/tta.spade:214,47" *)
    logic[43:0] _e_3197;
    (* src = "src/tta.spade:215,9" *)
    logic[43:0] _e_3204;
    (* src = "src/tta.spade:215,9" *)
    logic[10:0] _e_3201;
    (* src = "src/tta.spade:215,9" *)
    logic[32:0] _e_3203;
    (* src = "src/tta.spade:215,35" *)
    logic[31:0] x_n17;
    logic _e_8645;
    logic _e_8647;
    logic _e_8649;
    logic _e_8650;
    (* src = "src/tta.spade:215,66" *)
    logic[4:0] _e_3207;
    (* src = "src/tta.spade:215,52" *)
    logic[42:0] _e_3206;
    (* src = "src/tta.spade:215,47" *)
    logic[43:0] _e_3205;
    (* src = "src/tta.spade:217,9" *)
    logic[43:0] _e_3212;
    (* src = "src/tta.spade:217,9" *)
    logic[10:0] _e_3209;
    (* src = "src/tta.spade:217,9" *)
    logic[32:0] _e_3211;
    (* src = "src/tta.spade:217,33" *)
    logic[31:0] x_n18;
    logic _e_8653;
    logic _e_8655;
    logic _e_8657;
    logic _e_8658;
    (* src = "src/tta.spade:217,64" *)
    logic[2:0] _e_3215;
    (* src = "src/tta.spade:217,50" *)
    logic[42:0] _e_3214;
    (* src = "src/tta.spade:217,45" *)
    logic[43:0] _e_3213;
    (* src = "src/tta.spade:218,9" *)
    logic[43:0] _e_3220;
    (* src = "src/tta.spade:218,9" *)
    logic[10:0] _e_3217;
    (* src = "src/tta.spade:218,9" *)
    logic[32:0] _e_3219;
    (* src = "src/tta.spade:218,33" *)
    logic[31:0] x_n19;
    logic _e_8661;
    logic _e_8663;
    logic _e_8665;
    logic _e_8666;
    (* src = "src/tta.spade:218,64" *)
    logic[2:0] _e_3223;
    (* src = "src/tta.spade:218,50" *)
    logic[42:0] _e_3222;
    (* src = "src/tta.spade:218,45" *)
    logic[43:0] _e_3221;
    (* src = "src/tta.spade:219,9" *)
    logic[43:0] _e_3228;
    (* src = "src/tta.spade:219,9" *)
    logic[10:0] _e_3225;
    (* src = "src/tta.spade:219,9" *)
    logic[32:0] _e_3227;
    (* src = "src/tta.spade:219,36" *)
    logic[31:0] x_n20;
    logic _e_8669;
    logic _e_8671;
    logic _e_8673;
    logic _e_8674;
    (* src = "src/tta.spade:219,67" *)
    logic[2:0] _e_3231;
    (* src = "src/tta.spade:219,53" *)
    logic[42:0] _e_3230;
    (* src = "src/tta.spade:219,48" *)
    logic[43:0] _e_3229;
    (* src = "src/tta.spade:220,9" *)
    logic[43:0] _e_3236;
    (* src = "src/tta.spade:220,9" *)
    logic[10:0] _e_3233;
    (* src = "src/tta.spade:220,9" *)
    logic[32:0] _e_3235;
    (* src = "src/tta.spade:220,34" *)
    logic[31:0] x_n21;
    logic _e_8677;
    logic _e_8679;
    logic _e_8681;
    logic _e_8682;
    (* src = "src/tta.spade:220,65" *)
    logic[2:0] _e_3239;
    (* src = "src/tta.spade:220,51" *)
    logic[42:0] _e_3238;
    (* src = "src/tta.spade:220,46" *)
    logic[43:0] _e_3237;
    (* src = "src/tta.spade:221,9" *)
    logic[43:0] _e_3244;
    (* src = "src/tta.spade:221,9" *)
    logic[10:0] _e_3241;
    (* src = "src/tta.spade:221,9" *)
    logic[32:0] _e_3243;
    (* src = "src/tta.spade:221,34" *)
    logic[31:0] x_n22;
    logic _e_8685;
    logic _e_8687;
    logic _e_8689;
    logic _e_8690;
    (* src = "src/tta.spade:221,65" *)
    logic[2:0] _e_3247;
    (* src = "src/tta.spade:221,51" *)
    logic[42:0] _e_3246;
    (* src = "src/tta.spade:221,46" *)
    logic[43:0] _e_3245;
    (* src = "src/tta.spade:222,9" *)
    logic[43:0] _e_3252;
    (* src = "src/tta.spade:222,9" *)
    logic[10:0] _e_3249;
    (* src = "src/tta.spade:222,9" *)
    logic[32:0] _e_3251;
    (* src = "src/tta.spade:222,34" *)
    logic[31:0] x_n23;
    logic _e_8693;
    logic _e_8695;
    logic _e_8697;
    logic _e_8698;
    (* src = "src/tta.spade:222,65" *)
    logic[2:0] _e_3255;
    (* src = "src/tta.spade:222,51" *)
    logic[42:0] _e_3254;
    (* src = "src/tta.spade:222,46" *)
    logic[43:0] _e_3253;
    (* src = "src/tta.spade:223,9" *)
    logic[43:0] _e_3260;
    (* src = "src/tta.spade:223,9" *)
    logic[10:0] _e_3257;
    (* src = "src/tta.spade:223,9" *)
    logic[32:0] _e_3259;
    (* src = "src/tta.spade:223,34" *)
    logic[31:0] x_n24;
    logic _e_8701;
    logic _e_8703;
    logic _e_8705;
    logic _e_8706;
    (* src = "src/tta.spade:223,65" *)
    logic[2:0] _e_3263;
    (* src = "src/tta.spade:223,51" *)
    logic[42:0] _e_3262;
    (* src = "src/tta.spade:223,46" *)
    logic[43:0] _e_3261;
    (* src = "src/tta.spade:224,9" *)
    logic[43:0] _e_3268;
    (* src = "src/tta.spade:224,9" *)
    logic[10:0] _e_3265;
    (* src = "src/tta.spade:224,9" *)
    logic[32:0] _e_3267;
    (* src = "src/tta.spade:224,34" *)
    logic[31:0] x_n25;
    logic _e_8709;
    logic _e_8711;
    logic _e_8713;
    logic _e_8714;
    (* src = "src/tta.spade:224,65" *)
    logic[2:0] _e_3271;
    (* src = "src/tta.spade:224,51" *)
    logic[42:0] _e_3270;
    (* src = "src/tta.spade:224,46" *)
    logic[43:0] _e_3269;
    (* src = "src/tta.spade:226,9" *)
    logic[43:0] _e_3276;
    (* src = "src/tta.spade:226,9" *)
    logic[10:0] _e_3273;
    (* src = "src/tta.spade:226,9" *)
    logic[32:0] _e_3275;
    (* src = "src/tta.spade:226,33" *)
    logic[31:0] x_n26;
    logic _e_8717;
    logic _e_8719;
    logic _e_8721;
    logic _e_8722;
    (* src = "src/tta.spade:226,50" *)
    logic[42:0] _e_3278;
    (* src = "src/tta.spade:226,45" *)
    logic[43:0] _e_3277;
    (* src = "src/tta.spade:227,9" *)
    logic[43:0] _e_3283;
    (* src = "src/tta.spade:227,9" *)
    logic[10:0] _e_3280;
    (* src = "src/tta.spade:227,9" *)
    logic[32:0] _e_3282;
    (* src = "src/tta.spade:227,33" *)
    logic[31:0] x_n27;
    logic _e_8725;
    logic _e_8727;
    logic _e_8729;
    logic _e_8730;
    (* src = "src/tta.spade:227,65" *)
    logic _e_3286;
    (* src = "src/tta.spade:227,50" *)
    logic[42:0] _e_3285;
    (* src = "src/tta.spade:227,45" *)
    logic[43:0] _e_3284;
    (* src = "src/tta.spade:228,9" *)
    logic[43:0] _e_3291;
    (* src = "src/tta.spade:228,9" *)
    logic[10:0] _e_3288;
    (* src = "src/tta.spade:228,9" *)
    logic[32:0] _e_3290;
    (* src = "src/tta.spade:228,33" *)
    logic[31:0] x_n28;
    logic _e_8733;
    logic _e_8735;
    logic _e_8737;
    logic _e_8738;
    (* src = "src/tta.spade:228,65" *)
    logic _e_3294;
    (* src = "src/tta.spade:228,50" *)
    logic[42:0] _e_3293;
    (* src = "src/tta.spade:228,45" *)
    logic[43:0] _e_3292;
    (* src = "src/tta.spade:230,9" *)
    logic[43:0] _e_3299;
    (* src = "src/tta.spade:230,9" *)
    logic[10:0] _e_3296;
    (* src = "src/tta.spade:230,9" *)
    logic[32:0] _e_3298;
    (* src = "src/tta.spade:230,32" *)
    logic[31:0] x_n29;
    logic _e_8741;
    logic _e_8743;
    logic _e_8745;
    logic _e_8746;
    (* src = "src/tta.spade:230,62" *)
    logic[9:0] _e_3302;
    (* src = "src/tta.spade:230,49" *)
    logic[42:0] _e_3301;
    (* src = "src/tta.spade:230,44" *)
    logic[43:0] _e_3300;
    (* src = "src/tta.spade:232,9" *)
    logic[43:0] _e_3307;
    (* src = "src/tta.spade:232,9" *)
    logic[10:0] _e_3304;
    (* src = "src/tta.spade:232,9" *)
    logic[32:0] _e_3306;
    (* src = "src/tta.spade:232,32" *)
    logic[31:0] x_n30;
    logic _e_8749;
    logic _e_8751;
    logic _e_8753;
    logic _e_8754;
    (* src = "src/tta.spade:232,64" *)
    logic[9:0] _e_3310;
    (* src = "src/tta.spade:232,49" *)
    logic[42:0] _e_3309;
    (* src = "src/tta.spade:232,44" *)
    logic[43:0] _e_3308;
    (* src = "src/tta.spade:233,9" *)
    logic[43:0] _e_3315;
    (* src = "src/tta.spade:233,9" *)
    logic[10:0] _e_3312;
    (* src = "src/tta.spade:233,9" *)
    logic[32:0] _e_3314;
    (* src = "src/tta.spade:233,32" *)
    logic[31:0] x_n31;
    logic _e_8757;
    logic _e_8759;
    logic _e_8761;
    logic _e_8762;
    (* src = "src/tta.spade:233,49" *)
    logic[42:0] _e_3317;
    (* src = "src/tta.spade:233,44" *)
    logic[43:0] _e_3316;
    (* src = "src/tta.spade:235,9" *)
    logic[43:0] _e_3322;
    (* src = "src/tta.spade:235,9" *)
    logic[10:0] _e_3319;
    (* src = "src/tta.spade:235,9" *)
    logic[32:0] _e_3321;
    (* src = "src/tta.spade:235,32" *)
    logic[31:0] x_n32;
    logic _e_8765;
    logic _e_8767;
    logic _e_8769;
    logic _e_8770;
    (* src = "src/tta.spade:235,49" *)
    logic[42:0] _e_3324;
    (* src = "src/tta.spade:235,44" *)
    logic[43:0] _e_3323;
    (* src = "src/tta.spade:236,9" *)
    logic[43:0] _e_3329;
    (* src = "src/tta.spade:236,9" *)
    logic[10:0] _e_3326;
    (* src = "src/tta.spade:236,9" *)
    logic[32:0] _e_3328;
    (* src = "src/tta.spade:236,32" *)
    logic[31:0] x_n33;
    logic _e_8773;
    logic _e_8775;
    logic _e_8777;
    logic _e_8778;
    (* src = "src/tta.spade:236,49" *)
    logic[42:0] _e_3331;
    (* src = "src/tta.spade:236,44" *)
    logic[43:0] _e_3330;
    (* src = "src/tta.spade:237,9" *)
    logic[43:0] _e_3336;
    (* src = "src/tta.spade:237,9" *)
    logic[10:0] _e_3333;
    (* src = "src/tta.spade:237,9" *)
    logic[32:0] _e_3335;
    (* src = "src/tta.spade:237,32" *)
    logic[31:0] x_n34;
    logic _e_8781;
    logic _e_8783;
    logic _e_8785;
    logic _e_8786;
    (* src = "src/tta.spade:237,49" *)
    logic[42:0] _e_3338;
    (* src = "src/tta.spade:237,44" *)
    logic[43:0] _e_3337;
    (* src = "src/tta.spade:239,9" *)
    logic[43:0] _e_3343;
    (* src = "src/tta.spade:239,9" *)
    logic[10:0] _e_3340;
    (* src = "src/tta.spade:239,9" *)
    logic[32:0] _e_3342;
    (* src = "src/tta.spade:239,33" *)
    logic[31:0] x_n35;
    logic _e_8789;
    logic _e_8791;
    logic _e_8793;
    logic _e_8794;
    (* src = "src/tta.spade:239,50" *)
    logic[42:0] _e_3345;
    (* src = "src/tta.spade:239,45" *)
    logic[43:0] _e_3344;
    (* src = "src/tta.spade:240,9" *)
    logic[43:0] _e_3350;
    (* src = "src/tta.spade:240,9" *)
    logic[10:0] _e_3347;
    (* src = "src/tta.spade:240,9" *)
    logic[32:0] _e_3349;
    (* src = "src/tta.spade:240,33" *)
    logic[31:0] x_n36;
    logic _e_8797;
    logic _e_8799;
    logic _e_8801;
    logic _e_8802;
    (* src = "src/tta.spade:240,50" *)
    logic[42:0] _e_3352;
    (* src = "src/tta.spade:240,45" *)
    logic[43:0] _e_3351;
    (* src = "src/tta.spade:241,9" *)
    logic[43:0] _e_3357;
    (* src = "src/tta.spade:241,9" *)
    logic[10:0] _e_3354;
    (* src = "src/tta.spade:241,9" *)
    logic[32:0] _e_3356;
    (* src = "src/tta.spade:241,33" *)
    logic[31:0] x_n37;
    logic _e_8805;
    logic _e_8807;
    logic _e_8809;
    logic _e_8810;
    (* src = "src/tta.spade:241,50" *)
    logic[42:0] _e_3359;
    (* src = "src/tta.spade:241,45" *)
    logic[43:0] _e_3358;
    (* src = "src/tta.spade:243,9" *)
    logic[43:0] _e_3364;
    (* src = "src/tta.spade:243,9" *)
    logic[10:0] _e_3361;
    (* src = "src/tta.spade:243,9" *)
    logic[32:0] _e_3363;
    (* src = "src/tta.spade:243,32" *)
    logic[31:0] x_n38;
    logic _e_8813;
    logic _e_8815;
    logic _e_8817;
    logic _e_8818;
    (* src = "src/tta.spade:243,62" *)
    logic[15:0] _e_3367;
    (* src = "src/tta.spade:243,49" *)
    logic[42:0] _e_3366;
    (* src = "src/tta.spade:243,44" *)
    logic[43:0] _e_3365;
    (* src = "src/tta.spade:245,9" *)
    logic[43:0] _e_3372;
    (* src = "src/tta.spade:245,9" *)
    logic[10:0] _e_3369;
    (* src = "src/tta.spade:245,9" *)
    logic[32:0] _e_3371;
    (* src = "src/tta.spade:245,32" *)
    logic[31:0] x_n39;
    logic _e_8821;
    logic _e_8823;
    logic _e_8825;
    logic _e_8826;
    (* src = "src/tta.spade:245,49" *)
    logic[42:0] _e_3374;
    (* src = "src/tta.spade:245,44" *)
    logic[43:0] _e_3373;
    (* src = "src/tta.spade:246,9" *)
    logic[43:0] _e_3379;
    (* src = "src/tta.spade:246,9" *)
    logic[10:0] _e_3376;
    (* src = "src/tta.spade:246,9" *)
    logic[32:0] _e_3378;
    (* src = "src/tta.spade:246,32" *)
    logic[31:0] x_n40;
    logic _e_8829;
    logic _e_8831;
    logic _e_8833;
    logic _e_8834;
    (* src = "src/tta.spade:246,63" *)
    logic[2:0] _e_3382;
    (* src = "src/tta.spade:246,49" *)
    logic[42:0] _e_3381;
    (* src = "src/tta.spade:246,44" *)
    logic[43:0] _e_3380;
    (* src = "src/tta.spade:247,9" *)
    logic[43:0] _e_3387;
    (* src = "src/tta.spade:247,9" *)
    logic[10:0] _e_3384;
    (* src = "src/tta.spade:247,9" *)
    logic[32:0] _e_3386;
    (* src = "src/tta.spade:247,32" *)
    logic[31:0] x_n41;
    logic _e_8837;
    logic _e_8839;
    logic _e_8841;
    logic _e_8842;
    (* src = "src/tta.spade:247,63" *)
    logic[2:0] _e_3390;
    (* src = "src/tta.spade:247,49" *)
    logic[42:0] _e_3389;
    (* src = "src/tta.spade:247,44" *)
    logic[43:0] _e_3388;
    (* src = "src/tta.spade:248,9" *)
    logic[43:0] _e_3395;
    (* src = "src/tta.spade:248,9" *)
    logic[10:0] _e_3392;
    (* src = "src/tta.spade:248,9" *)
    logic[32:0] _e_3394;
    (* src = "src/tta.spade:248,32" *)
    logic[31:0] x_n42;
    logic _e_8845;
    logic _e_8847;
    logic _e_8849;
    logic _e_8850;
    (* src = "src/tta.spade:248,63" *)
    logic[2:0] _e_3398;
    (* src = "src/tta.spade:248,49" *)
    logic[42:0] _e_3397;
    (* src = "src/tta.spade:248,44" *)
    logic[43:0] _e_3396;
    (* src = "src/tta.spade:249,9" *)
    logic[43:0] _e_3403;
    (* src = "src/tta.spade:249,9" *)
    logic[10:0] _e_3400;
    (* src = "src/tta.spade:249,9" *)
    logic[32:0] _e_3402;
    (* src = "src/tta.spade:249,32" *)
    logic[31:0] x_n43;
    logic _e_8853;
    logic _e_8855;
    logic _e_8857;
    logic _e_8858;
    (* src = "src/tta.spade:249,63" *)
    logic[2:0] _e_3406;
    (* src = "src/tta.spade:249,49" *)
    logic[42:0] _e_3405;
    (* src = "src/tta.spade:249,44" *)
    logic[43:0] _e_3404;
    (* src = "src/tta.spade:250,9" *)
    logic[43:0] _e_3411;
    (* src = "src/tta.spade:250,9" *)
    logic[10:0] _e_3408;
    (* src = "src/tta.spade:250,9" *)
    logic[32:0] _e_3410;
    (* src = "src/tta.spade:250,32" *)
    logic[31:0] x_n44;
    logic _e_8861;
    logic _e_8863;
    logic _e_8865;
    logic _e_8866;
    (* src = "src/tta.spade:250,63" *)
    logic[2:0] _e_3414;
    (* src = "src/tta.spade:250,49" *)
    logic[42:0] _e_3413;
    (* src = "src/tta.spade:250,44" *)
    logic[43:0] _e_3412;
    (* src = "src/tta.spade:251,9" *)
    logic[43:0] _e_3419;
    (* src = "src/tta.spade:251,9" *)
    logic[10:0] _e_3416;
    (* src = "src/tta.spade:251,9" *)
    logic[32:0] _e_3418;
    (* src = "src/tta.spade:251,32" *)
    logic[31:0] x_n45;
    logic _e_8869;
    logic _e_8871;
    logic _e_8873;
    logic _e_8874;
    (* src = "src/tta.spade:251,63" *)
    logic[2:0] _e_3422;
    (* src = "src/tta.spade:251,49" *)
    logic[42:0] _e_3421;
    (* src = "src/tta.spade:251,44" *)
    logic[43:0] _e_3420;
    (* src = "src/tta.spade:253,9" *)
    logic[43:0] _e_3427;
    (* src = "src/tta.spade:253,9" *)
    logic[10:0] _e_3424;
    (* src = "src/tta.spade:253,9" *)
    logic[32:0] _e_3426;
    (* src = "src/tta.spade:253,34" *)
    logic[31:0] x_n46;
    logic _e_8877;
    logic _e_8879;
    logic _e_8881;
    logic _e_8882;
    (* src = "src/tta.spade:253,66" *)
    logic[2:0] _e_3430;
    (* src = "src/tta.spade:253,51" *)
    logic[42:0] _e_3429;
    (* src = "src/tta.spade:253,46" *)
    logic[43:0] _e_3428;
    (* src = "src/tta.spade:254,9" *)
    logic[43:0] _e_3435;
    (* src = "src/tta.spade:254,9" *)
    logic[10:0] _e_3432;
    (* src = "src/tta.spade:254,9" *)
    logic[32:0] _e_3434;
    (* src = "src/tta.spade:254,34" *)
    logic[31:0] x_n47;
    logic _e_8885;
    logic _e_8887;
    logic _e_8889;
    logic _e_8890;
    (* src = "src/tta.spade:254,66" *)
    logic[2:0] _e_3438;
    (* src = "src/tta.spade:254,51" *)
    logic[42:0] _e_3437;
    (* src = "src/tta.spade:254,46" *)
    logic[43:0] _e_3436;
    (* src = "src/tta.spade:255,9" *)
    logic[43:0] _e_3443;
    (* src = "src/tta.spade:255,9" *)
    logic[10:0] _e_3440;
    (* src = "src/tta.spade:255,9" *)
    logic[32:0] _e_3442;
    (* src = "src/tta.spade:255,34" *)
    logic[31:0] x_n48;
    logic _e_8893;
    logic _e_8895;
    logic _e_8897;
    logic _e_8898;
    (* src = "src/tta.spade:255,66" *)
    logic[2:0] _e_3446;
    (* src = "src/tta.spade:255,51" *)
    logic[42:0] _e_3445;
    (* src = "src/tta.spade:255,46" *)
    logic[43:0] _e_3444;
    (* src = "src/tta.spade:256,9" *)
    logic[43:0] _e_3451;
    (* src = "src/tta.spade:256,9" *)
    logic[10:0] _e_3448;
    (* src = "src/tta.spade:256,9" *)
    logic[32:0] _e_3450;
    (* src = "src/tta.spade:256,34" *)
    logic[31:0] x_n49;
    logic _e_8901;
    logic _e_8903;
    logic _e_8905;
    logic _e_8906;
    (* src = "src/tta.spade:256,66" *)
    logic[2:0] _e_3454;
    (* src = "src/tta.spade:256,51" *)
    logic[42:0] _e_3453;
    (* src = "src/tta.spade:256,46" *)
    logic[43:0] _e_3452;
    (* src = "src/tta.spade:257,9" *)
    logic[43:0] _e_3459;
    (* src = "src/tta.spade:257,9" *)
    logic[10:0] _e_3456;
    (* src = "src/tta.spade:257,9" *)
    logic[32:0] _e_3458;
    (* src = "src/tta.spade:257,34" *)
    logic[31:0] x_n50;
    logic _e_8909;
    logic _e_8911;
    logic _e_8913;
    logic _e_8914;
    (* src = "src/tta.spade:257,66" *)
    logic[2:0] _e_3462;
    (* src = "src/tta.spade:257,51" *)
    logic[42:0] _e_3461;
    (* src = "src/tta.spade:257,46" *)
    logic[43:0] _e_3460;
    (* src = "src/tta.spade:258,9" *)
    logic[43:0] _e_3467;
    (* src = "src/tta.spade:258,9" *)
    logic[10:0] _e_3464;
    (* src = "src/tta.spade:258,9" *)
    logic[32:0] _e_3466;
    (* src = "src/tta.spade:258,35" *)
    logic[31:0] x_n51;
    logic _e_8917;
    logic _e_8919;
    logic _e_8921;
    logic _e_8922;
    (* src = "src/tta.spade:258,67" *)
    logic[2:0] _e_3470;
    (* src = "src/tta.spade:258,52" *)
    logic[42:0] _e_3469;
    (* src = "src/tta.spade:258,47" *)
    logic[43:0] _e_3468;
    (* src = "src/tta.spade:260,9" *)
    logic[43:0] _e_3475;
    (* src = "src/tta.spade:260,9" *)
    logic[10:0] _e_3472;
    (* src = "src/tta.spade:260,9" *)
    logic[32:0] _e_3474;
    (* src = "src/tta.spade:260,32" *)
    logic[31:0] x_n52;
    logic _e_8925;
    logic _e_8927;
    logic _e_8929;
    logic _e_8930;
    (* src = "src/tta.spade:260,49" *)
    logic[42:0] _e_3477;
    (* src = "src/tta.spade:260,44" *)
    logic[43:0] _e_3476;
    (* src = "src/tta.spade:261,9" *)
    logic[43:0] _e_3482;
    (* src = "src/tta.spade:261,9" *)
    logic[10:0] _e_3479;
    (* src = "src/tta.spade:261,9" *)
    logic[32:0] _e_3481;
    (* src = "src/tta.spade:261,32" *)
    logic[31:0] x_n53;
    logic _e_8933;
    logic _e_8935;
    logic _e_8937;
    logic _e_8938;
    (* src = "src/tta.spade:261,49" *)
    logic[42:0] _e_3484;
    (* src = "src/tta.spade:261,44" *)
    logic[43:0] _e_3483;
    (* src = "src/tta.spade:263,9" *)
    logic[43:0] _e_3489;
    (* src = "src/tta.spade:263,9" *)
    logic[10:0] _e_3486;
    (* src = "src/tta.spade:263,9" *)
    logic[32:0] _e_3488;
    (* src = "src/tta.spade:263,32" *)
    logic[31:0] x_n54;
    logic _e_8941;
    logic _e_8943;
    logic _e_8945;
    logic _e_8946;
    (* src = "src/tta.spade:263,49" *)
    logic[42:0] _e_3491;
    (* src = "src/tta.spade:263,44" *)
    logic[43:0] _e_3490;
    (* src = "src/tta.spade:264,9" *)
    logic[43:0] _e_3496;
    (* src = "src/tta.spade:264,9" *)
    logic[10:0] _e_3493;
    (* src = "src/tta.spade:264,9" *)
    logic[32:0] _e_3495;
    (* src = "src/tta.spade:264,32" *)
    logic[31:0] x_n55;
    logic _e_8949;
    logic _e_8951;
    logic _e_8953;
    logic _e_8954;
    (* src = "src/tta.spade:264,49" *)
    logic[42:0] _e_3498;
    (* src = "src/tta.spade:264,44" *)
    logic[43:0] _e_3497;
    (* src = "src/tta.spade:266,9" *)
    logic[43:0] _e_3503;
    (* src = "src/tta.spade:266,9" *)
    logic[10:0] _e_3500;
    (* src = "src/tta.spade:266,9" *)
    logic[32:0] _e_3502;
    (* src = "src/tta.spade:266,37" *)
    logic[31:0] x_n56;
    logic _e_8957;
    logic _e_8959;
    logic _e_8961;
    logic _e_8962;
    (* src = "src/tta.spade:266,54" *)
    logic[42:0] _e_3505;
    (* src = "src/tta.spade:266,49" *)
    logic[43:0] _e_3504;
    (* src = "src/tta.spade:268,9" *)
    logic[43:0] _e_3510;
    (* src = "src/tta.spade:268,9" *)
    logic[10:0] _e_3507;
    (* src = "src/tta.spade:268,9" *)
    logic[32:0] _e_3509;
    (* src = "src/tta.spade:268,27" *)
    logic[31:0] x_n57;
    logic _e_8965;
    logic _e_8967;
    logic _e_8969;
    logic _e_8970;
    (* src = "src/tta.spade:268,44" *)
    logic[42:0] _e_3512;
    (* src = "src/tta.spade:268,39" *)
    logic[43:0] _e_3511;
    (* src = "src/tta.spade:269,9" *)
    logic[43:0] _e_3517;
    (* src = "src/tta.spade:269,9" *)
    logic[10:0] _e_3514;
    (* src = "src/tta.spade:269,9" *)
    logic[32:0] _e_3516;
    (* src = "src/tta.spade:269,27" *)
    logic[31:0] x_n58;
    logic _e_8973;
    logic _e_8975;
    logic _e_8977;
    logic _e_8978;
    (* src = "src/tta.spade:269,44" *)
    logic[42:0] _e_3519;
    (* src = "src/tta.spade:269,39" *)
    logic[43:0] _e_3518;
    (* src = "src/tta.spade:270,9" *)
    logic[43:0] _e_3524;
    (* src = "src/tta.spade:270,9" *)
    logic[10:0] _e_3521;
    (* src = "src/tta.spade:270,9" *)
    logic[32:0] _e_3523;
    (* src = "src/tta.spade:270,27" *)
    logic[31:0] x_n59;
    logic _e_8981;
    logic _e_8983;
    logic _e_8985;
    logic _e_8986;
    (* src = "src/tta.spade:270,59" *)
    logic _e_3527;
    (* src = "src/tta.spade:270,44" *)
    logic[42:0] _e_3526;
    (* src = "src/tta.spade:270,39" *)
    logic[43:0] _e_3525;
    (* src = "src/tta.spade:272,9" *)
    logic[43:0] _e_3533;
    (* src = "src/tta.spade:272,9" *)
    logic[10:0] _e_3530;
    (* src = "src/tta.spade:272,9" *)
    logic[32:0] _e_3532;
    (* src = "src/tta.spade:272,26" *)
    logic[31:0] x_n60;
    logic _e_8989;
    logic _e_8991;
    logic _e_8993;
    logic _e_8994;
    (* src = "src/tta.spade:272,57" *)
    logic _e_3536;
    (* src = "src/tta.spade:272,43" *)
    logic[42:0] _e_3535;
    (* src = "src/tta.spade:272,38" *)
    logic[43:0] _e_3534;
    (* src = "src/tta.spade:273,9" *)
    logic[43:0] _e_3542;
    (* src = "src/tta.spade:273,9" *)
    logic[10:0] _e_3539;
    (* src = "src/tta.spade:273,9" *)
    logic[32:0] _e_3541;
    (* src = "src/tta.spade:273,27" *)
    logic[31:0] x_n61;
    logic _e_8997;
    logic _e_8999;
    logic _e_9001;
    logic _e_9002;
    (* src = "src/tta.spade:273,44" *)
    logic[42:0] _e_3544;
    (* src = "src/tta.spade:273,39" *)
    logic[43:0] _e_3543;
    (* src = "src/tta.spade:274,9" *)
    logic[43:0] _e_3549;
    (* src = "src/tta.spade:274,9" *)
    logic[10:0] _e_3546;
    (* src = "src/tta.spade:274,9" *)
    logic[32:0] _e_3548;
    (* src = "src/tta.spade:274,27" *)
    logic[31:0] x_n62;
    logic _e_9005;
    logic _e_9007;
    logic _e_9009;
    logic _e_9010;
    (* src = "src/tta.spade:274,44" *)
    logic[42:0] _e_3551;
    (* src = "src/tta.spade:274,39" *)
    logic[43:0] _e_3550;
    (* src = "src/tta.spade:276,9" *)
    logic[43:0] _e_3556;
    (* src = "src/tta.spade:276,9" *)
    logic[10:0] _e_3553;
    (* src = "src/tta.spade:276,9" *)
    logic[32:0] _e_3555;
    (* src = "src/tta.spade:276,26" *)
    logic[31:0] x_n63;
    logic _e_9013;
    logic _e_9015;
    logic _e_9017;
    logic _e_9018;
    (* src = "src/tta.spade:276,43" *)
    logic[42:0] _e_3558;
    (* src = "src/tta.spade:276,38" *)
    logic[43:0] _e_3557;
    (* src = "src/tta.spade:277,9" *)
    logic[43:0] _e_3563;
    (* src = "src/tta.spade:277,9" *)
    logic[10:0] _e_3560;
    (* src = "src/tta.spade:277,9" *)
    logic[32:0] _e_3562;
    (* src = "src/tta.spade:277,26" *)
    logic[31:0] x_n64;
    logic _e_9021;
    logic _e_9023;
    logic _e_9025;
    logic _e_9026;
    (* src = "src/tta.spade:277,43" *)
    logic[42:0] _e_3565;
    (* src = "src/tta.spade:277,38" *)
    logic[43:0] _e_3564;
    (* src = "src/tta.spade:278,9" *)
    logic[43:0] _e_3570;
    (* src = "src/tta.spade:278,9" *)
    logic[10:0] _e_3567;
    (* src = "src/tta.spade:278,9" *)
    logic[32:0] _e_3569;
    (* src = "src/tta.spade:278,25" *)
    logic[31:0] x_n65;
    logic _e_9029;
    logic _e_9031;
    logic _e_9033;
    logic _e_9034;
    (* src = "src/tta.spade:278,42" *)
    logic[42:0] _e_3572;
    (* src = "src/tta.spade:278,37" *)
    logic[43:0] _e_3571;
    (* src = "src/tta.spade:279,9" *)
    logic[43:0] _e_3577;
    (* src = "src/tta.spade:279,9" *)
    logic[10:0] _e_3574;
    (* src = "src/tta.spade:279,9" *)
    logic[32:0] _e_3576;
    (* src = "src/tta.spade:279,26" *)
    logic[31:0] x_n66;
    logic _e_9037;
    logic _e_9039;
    logic _e_9041;
    logic _e_9042;
    (* src = "src/tta.spade:279,43" *)
    logic[42:0] _e_3579;
    (* src = "src/tta.spade:279,38" *)
    logic[43:0] _e_3578;
    (* src = "src/tta.spade:281,9" *)
    logic[43:0] _e_3584;
    (* src = "src/tta.spade:281,9" *)
    logic[10:0] _e_3581;
    (* src = "src/tta.spade:281,9" *)
    logic[32:0] _e_3583;
    (* src = "src/tta.spade:281,26" *)
    logic[31:0] x_n67;
    logic _e_9045;
    logic _e_9047;
    logic _e_9049;
    logic _e_9050;
    (* src = "src/tta.spade:281,43" *)
    logic[42:0] _e_3586;
    (* src = "src/tta.spade:281,38" *)
    logic[43:0] _e_3585;
    (* src = "src/tta.spade:283,9" *)
    logic[43:0] _e_3591;
    (* src = "src/tta.spade:283,9" *)
    logic[10:0] _e_3588;
    (* src = "src/tta.spade:283,9" *)
    logic[32:0] _e_3590;
    (* src = "src/tta.spade:283,28" *)
    logic[31:0] x_n68;
    logic _e_9053;
    logic _e_9055;
    logic _e_9057;
    logic _e_9058;
    (* src = "src/tta.spade:283,45" *)
    logic[42:0] _e_3593;
    (* src = "src/tta.spade:283,40" *)
    logic[43:0] _e_3592;
    (* src = "src/tta.spade:284,9" *)
    logic[43:0] _e_3598;
    (* src = "src/tta.spade:284,9" *)
    logic[10:0] _e_3595;
    (* src = "src/tta.spade:284,9" *)
    logic[32:0] _e_3597;
    (* src = "src/tta.spade:284,33" *)
    logic[31:0] x_n69;
    logic _e_9061;
    logic _e_9063;
    logic _e_9065;
    logic _e_9066;
    (* src = "src/tta.spade:284,50" *)
    logic[42:0] _e_3600;
    (* src = "src/tta.spade:284,45" *)
    logic[43:0] _e_3599;
    (* src = "src/tta.spade:285,9" *)
    logic[43:0] _e_3605;
    (* src = "src/tta.spade:285,9" *)
    logic[10:0] _e_3602;
    (* src = "src/tta.spade:285,9" *)
    logic[32:0] _e_3604;
    (* src = "src/tta.spade:285,32" *)
    logic[31:0] x_n70;
    logic _e_9069;
    logic _e_9071;
    logic _e_9073;
    logic _e_9074;
    (* src = "src/tta.spade:285,49" *)
    logic[42:0] _e_3607;
    (* src = "src/tta.spade:285,44" *)
    logic[43:0] _e_3606;
    (* src = "src/tta.spade:287,9" *)
    logic[43:0] _e_3611;
    (* src = "src/tta.spade:287,9" *)
    logic[10:0] _e_3608;
    (* src = "src/tta.spade:287,9" *)
    logic[32:0] _e_3610;
    (* src = "src/tta.spade:287,32" *)
    logic[31:0] x_n71;
    logic _e_9077;
    logic _e_9079;
    logic _e_9081;
    logic _e_9082;
    (* src = "src/tta.spade:287,63" *)
    logic[7:0] _e_3614;
    (* src = "src/tta.spade:287,49" *)
    logic[42:0] _e_3613;
    (* src = "src/tta.spade:287,44" *)
    logic[43:0] _e_3612;
    (* src = "src/tta.spade:288,9" *)
    logic[43:0] _e_3619;
    (* src = "src/tta.spade:288,9" *)
    logic[10:0] _e_3616;
    (* src = "src/tta.spade:288,9" *)
    logic[32:0] _e_3618;
    (* src = "src/tta.spade:288,32" *)
    logic[31:0] x_n72;
    logic _e_9085;
    logic _e_9087;
    logic _e_9089;
    logic _e_9090;
    (* src = "src/tta.spade:288,49" *)
    logic[42:0] _e_3621;
    (* src = "src/tta.spade:288,44" *)
    logic[43:0] _e_3620;
    (* src = "src/tta.spade:290,9" *)
    logic[43:0] _e_3625;
    (* src = "src/tta.spade:290,9" *)
    logic[10:0] _e_3622;
    (* src = "src/tta.spade:290,9" *)
    logic[32:0] _e_3624;
    (* src = "src/tta.spade:290,33" *)
    logic[31:0] x_n73;
    logic _e_9093;
    logic _e_9095;
    logic _e_9097;
    logic _e_9098;
    (* src = "src/tta.spade:290,65" *)
    logic[7:0] _e_3628;
    (* src = "src/tta.spade:290,50" *)
    logic[42:0] _e_3627;
    (* src = "src/tta.spade:290,45" *)
    logic[43:0] _e_3626;
    (* src = "src/tta.spade:291,9" *)
    logic[43:0] _e_3633;
    (* src = "src/tta.spade:291,9" *)
    logic[10:0] _e_3630;
    (* src = "src/tta.spade:291,9" *)
    logic[32:0] _e_3632;
    (* src = "src/tta.spade:291,33" *)
    logic[31:0] x_n74;
    logic _e_9101;
    logic _e_9103;
    logic _e_9105;
    logic _e_9106;
    (* src = "src/tta.spade:291,50" *)
    logic[42:0] _e_3635;
    (* src = "src/tta.spade:291,45" *)
    logic[43:0] _e_3634;
    (* src = "src/tta.spade:293,9" *)
    logic[43:0] \_ ;
    (* src = "src/tta.spade:293,14" *)
    logic[43:0] _e_3637;
    (* src = "src/tta.spade:196,5" *)
    logic[43:0] _e_3061;
    assign _e_3062 = {\dst , \v };
    assign _e_3069 = _e_3062;
    assign _e_3066 = _e_3062[43:33];
    assign \i  = _e_3066[3:0];
    assign _e_3068 = _e_3062[32:0];
    assign \x  = _e_3068[31:0];
    assign _e_8507 = _e_3066[10:4] == 7'd0;
    localparam[0:0] _e_8508 = 1;
    assign _e_8509 = _e_8507 && _e_8508;
    assign _e_8511 = _e_3068[32] == 1'd1;
    localparam[0:0] _e_8512 = 1;
    assign _e_8513 = _e_8511 && _e_8512;
    assign _e_8514 = _e_8509 && _e_8513;
    assign _e_3071 = {6'd0, \i , \x , 1'bX};
    assign _e_3070 = {1'd1, _e_3071};
    assign _e_3077 = _e_3062;
    assign _e_3074 = _e_3062[43:33];
    assign _e_3076 = _e_3062[32:0];
    assign x_n1 = _e_3076[31:0];
    assign _e_8517 = _e_3074[10:4] == 7'd1;
    assign _e_8519 = _e_3076[32] == 1'd1;
    localparam[0:0] _e_8520 = 1;
    assign _e_8521 = _e_8519 && _e_8520;
    assign _e_8522 = _e_8517 && _e_8521;
    assign _e_3079 = {6'd1, x_n1, 5'bX};
    assign _e_3078 = {1'd1, _e_3079};
    assign _e_3084 = _e_3062;
    assign _e_3081 = _e_3062[43:33];
    assign _e_3083 = _e_3062[32:0];
    assign x_n2 = _e_3083[31:0];
    assign _e_8525 = _e_3081[10:4] == 7'd2;
    assign _e_8527 = _e_3083[32] == 1'd1;
    localparam[0:0] _e_8528 = 1;
    assign _e_8529 = _e_8527 && _e_8528;
    assign _e_8530 = _e_8525 && _e_8529;
    assign _e_3087 = {5'd0};
    assign _e_3086 = {6'd2, _e_3087, x_n2};
    assign _e_3085 = {1'd1, _e_3086};
    assign _e_3092 = _e_3062;
    assign _e_3089 = _e_3062[43:33];
    assign _e_3091 = _e_3062[32:0];
    assign x_n3 = _e_3091[31:0];
    assign _e_8533 = _e_3089[10:4] == 7'd3;
    assign _e_8535 = _e_3091[32] == 1'd1;
    localparam[0:0] _e_8536 = 1;
    assign _e_8537 = _e_8535 && _e_8536;
    assign _e_8538 = _e_8533 && _e_8537;
    assign _e_3095 = {5'd1};
    assign _e_3094 = {6'd2, _e_3095, x_n3};
    assign _e_3093 = {1'd1, _e_3094};
    assign _e_3100 = _e_3062;
    assign _e_3097 = _e_3062[43:33];
    assign _e_3099 = _e_3062[32:0];
    assign x_n4 = _e_3099[31:0];
    assign _e_8541 = _e_3097[10:4] == 7'd4;
    assign _e_8543 = _e_3099[32] == 1'd1;
    localparam[0:0] _e_8544 = 1;
    assign _e_8545 = _e_8543 && _e_8544;
    assign _e_8546 = _e_8541 && _e_8545;
    assign _e_3103 = {5'd2};
    assign _e_3102 = {6'd2, _e_3103, x_n4};
    assign _e_3101 = {1'd1, _e_3102};
    assign _e_3108 = _e_3062;
    assign _e_3105 = _e_3062[43:33];
    assign _e_3107 = _e_3062[32:0];
    assign x_n5 = _e_3107[31:0];
    assign _e_8549 = _e_3105[10:4] == 7'd5;
    assign _e_8551 = _e_3107[32] == 1'd1;
    localparam[0:0] _e_8552 = 1;
    assign _e_8553 = _e_8551 && _e_8552;
    assign _e_8554 = _e_8549 && _e_8553;
    assign _e_3111 = {5'd3};
    assign _e_3110 = {6'd2, _e_3111, x_n5};
    assign _e_3109 = {1'd1, _e_3110};
    assign _e_3116 = _e_3062;
    assign _e_3113 = _e_3062[43:33];
    assign _e_3115 = _e_3062[32:0];
    assign x_n6 = _e_3115[31:0];
    assign _e_8557 = _e_3113[10:4] == 7'd6;
    assign _e_8559 = _e_3115[32] == 1'd1;
    localparam[0:0] _e_8560 = 1;
    assign _e_8561 = _e_8559 && _e_8560;
    assign _e_8562 = _e_8557 && _e_8561;
    assign _e_3119 = {5'd4};
    assign _e_3118 = {6'd2, _e_3119, x_n6};
    assign _e_3117 = {1'd1, _e_3118};
    assign _e_3124 = _e_3062;
    assign _e_3121 = _e_3062[43:33];
    assign _e_3123 = _e_3062[32:0];
    assign x_n7 = _e_3123[31:0];
    assign _e_8565 = _e_3121[10:4] == 7'd8;
    assign _e_8567 = _e_3123[32] == 1'd1;
    localparam[0:0] _e_8568 = 1;
    assign _e_8569 = _e_8567 && _e_8568;
    assign _e_8570 = _e_8565 && _e_8569;
    assign _e_3127 = {5'd6};
    assign _e_3126 = {6'd2, _e_3127, x_n7};
    assign _e_3125 = {1'd1, _e_3126};
    assign _e_3132 = _e_3062;
    assign _e_3129 = _e_3062[43:33];
    assign _e_3131 = _e_3062[32:0];
    assign x_n8 = _e_3131[31:0];
    assign _e_8573 = _e_3129[10:4] == 7'd9;
    assign _e_8575 = _e_3131[32] == 1'd1;
    localparam[0:0] _e_8576 = 1;
    assign _e_8577 = _e_8575 && _e_8576;
    assign _e_8578 = _e_8573 && _e_8577;
    assign _e_3135 = {5'd7};
    assign _e_3134 = {6'd2, _e_3135, x_n8};
    assign _e_3133 = {1'd1, _e_3134};
    assign _e_3140 = _e_3062;
    assign _e_3137 = _e_3062[43:33];
    assign _e_3139 = _e_3062[32:0];
    assign x_n9 = _e_3139[31:0];
    assign _e_8581 = _e_3137[10:4] == 7'd10;
    assign _e_8583 = _e_3139[32] == 1'd1;
    localparam[0:0] _e_8584 = 1;
    assign _e_8585 = _e_8583 && _e_8584;
    assign _e_8586 = _e_8581 && _e_8585;
    assign _e_3143 = {5'd8};
    assign _e_3142 = {6'd2, _e_3143, x_n9};
    assign _e_3141 = {1'd1, _e_3142};
    assign _e_3148 = _e_3062;
    assign _e_3145 = _e_3062[43:33];
    assign _e_3147 = _e_3062[32:0];
    assign x_n10 = _e_3147[31:0];
    assign _e_8589 = _e_3145[10:4] == 7'd11;
    assign _e_8591 = _e_3147[32] == 1'd1;
    localparam[0:0] _e_8592 = 1;
    assign _e_8593 = _e_8591 && _e_8592;
    assign _e_8594 = _e_8589 && _e_8593;
    assign _e_3151 = {5'd9};
    assign _e_3150 = {6'd2, _e_3151, x_n10};
    assign _e_3149 = {1'd1, _e_3150};
    assign _e_3156 = _e_3062;
    assign _e_3153 = _e_3062[43:33];
    assign _e_3155 = _e_3062[32:0];
    assign x_n11 = _e_3155[31:0];
    assign _e_8597 = _e_3153[10:4] == 7'd12;
    assign _e_8599 = _e_3155[32] == 1'd1;
    localparam[0:0] _e_8600 = 1;
    assign _e_8601 = _e_8599 && _e_8600;
    assign _e_8602 = _e_8597 && _e_8601;
    assign _e_3159 = {5'd10};
    assign _e_3158 = {6'd2, _e_3159, x_n11};
    assign _e_3157 = {1'd1, _e_3158};
    assign _e_3164 = _e_3062;
    assign _e_3161 = _e_3062[43:33];
    assign _e_3163 = _e_3062[32:0];
    assign x_n12 = _e_3163[31:0];
    assign _e_8605 = _e_3161[10:4] == 7'd13;
    assign _e_8607 = _e_3163[32] == 1'd1;
    localparam[0:0] _e_8608 = 1;
    assign _e_8609 = _e_8607 && _e_8608;
    assign _e_8610 = _e_8605 && _e_8609;
    assign _e_3167 = {5'd11};
    assign _e_3166 = {6'd2, _e_3167, x_n12};
    assign _e_3165 = {1'd1, _e_3166};
    assign _e_3172 = _e_3062;
    assign _e_3169 = _e_3062[43:33];
    assign _e_3171 = _e_3062[32:0];
    assign x_n13 = _e_3171[31:0];
    assign _e_8613 = _e_3169[10:4] == 7'd14;
    assign _e_8615 = _e_3171[32] == 1'd1;
    localparam[0:0] _e_8616 = 1;
    assign _e_8617 = _e_8615 && _e_8616;
    assign _e_8618 = _e_8613 && _e_8617;
    assign _e_3175 = {5'd12};
    assign _e_3174 = {6'd2, _e_3175, x_n13};
    assign _e_3173 = {1'd1, _e_3174};
    assign _e_3180 = _e_3062;
    assign _e_3177 = _e_3062[43:33];
    assign _e_3179 = _e_3062[32:0];
    assign x_n14 = _e_3179[31:0];
    assign _e_8621 = _e_3177[10:4] == 7'd15;
    assign _e_8623 = _e_3179[32] == 1'd1;
    localparam[0:0] _e_8624 = 1;
    assign _e_8625 = _e_8623 && _e_8624;
    assign _e_8626 = _e_8621 && _e_8625;
    assign _e_3183 = {5'd13};
    assign _e_3182 = {6'd2, _e_3183, x_n14};
    assign _e_3181 = {1'd1, _e_3182};
    assign _e_3188 = _e_3062;
    assign _e_3185 = _e_3062[43:33];
    assign _e_3187 = _e_3062[32:0];
    assign x_n15 = _e_3187[31:0];
    assign _e_8629 = _e_3185[10:4] == 7'd16;
    assign _e_8631 = _e_3187[32] == 1'd1;
    localparam[0:0] _e_8632 = 1;
    assign _e_8633 = _e_8631 && _e_8632;
    assign _e_8634 = _e_8629 && _e_8633;
    assign _e_3191 = {5'd14};
    assign _e_3190 = {6'd2, _e_3191, x_n15};
    assign _e_3189 = {1'd1, _e_3190};
    assign _e_3196 = _e_3062;
    assign _e_3193 = _e_3062[43:33];
    assign _e_3195 = _e_3062[32:0];
    assign x_n16 = _e_3195[31:0];
    assign _e_8637 = _e_3193[10:4] == 7'd17;
    assign _e_8639 = _e_3195[32] == 1'd1;
    localparam[0:0] _e_8640 = 1;
    assign _e_8641 = _e_8639 && _e_8640;
    assign _e_8642 = _e_8637 && _e_8641;
    assign _e_3199 = {5'd15};
    assign _e_3198 = {6'd2, _e_3199, x_n16};
    assign _e_3197 = {1'd1, _e_3198};
    assign _e_3204 = _e_3062;
    assign _e_3201 = _e_3062[43:33];
    assign _e_3203 = _e_3062[32:0];
    assign x_n17 = _e_3203[31:0];
    assign _e_8645 = _e_3201[10:4] == 7'd18;
    assign _e_8647 = _e_3203[32] == 1'd1;
    localparam[0:0] _e_8648 = 1;
    assign _e_8649 = _e_8647 && _e_8648;
    assign _e_8650 = _e_8645 && _e_8649;
    assign _e_3207 = {5'd16};
    assign _e_3206 = {6'd2, _e_3207, x_n17};
    assign _e_3205 = {1'd1, _e_3206};
    assign _e_3212 = _e_3062;
    assign _e_3209 = _e_3062[43:33];
    assign _e_3211 = _e_3062[32:0];
    assign x_n18 = _e_3211[31:0];
    assign _e_8653 = _e_3209[10:4] == 7'd19;
    assign _e_8655 = _e_3211[32] == 1'd1;
    localparam[0:0] _e_8656 = 1;
    assign _e_8657 = _e_8655 && _e_8656;
    assign _e_8658 = _e_8653 && _e_8657;
    assign _e_3215 = {3'd0};
    assign _e_3214 = {6'd40, _e_3215, x_n18, 2'bX};
    assign _e_3213 = {1'd1, _e_3214};
    assign _e_3220 = _e_3062;
    assign _e_3217 = _e_3062[43:33];
    assign _e_3219 = _e_3062[32:0];
    assign x_n19 = _e_3219[31:0];
    assign _e_8661 = _e_3217[10:4] == 7'd20;
    assign _e_8663 = _e_3219[32] == 1'd1;
    localparam[0:0] _e_8664 = 1;
    assign _e_8665 = _e_8663 && _e_8664;
    assign _e_8666 = _e_8661 && _e_8665;
    assign _e_3223 = {3'd1};
    assign _e_3222 = {6'd40, _e_3223, x_n19, 2'bX};
    assign _e_3221 = {1'd1, _e_3222};
    assign _e_3228 = _e_3062;
    assign _e_3225 = _e_3062[43:33];
    assign _e_3227 = _e_3062[32:0];
    assign x_n20 = _e_3227[31:0];
    assign _e_8669 = _e_3225[10:4] == 7'd21;
    assign _e_8671 = _e_3227[32] == 1'd1;
    localparam[0:0] _e_8672 = 1;
    assign _e_8673 = _e_8671 && _e_8672;
    assign _e_8674 = _e_8669 && _e_8673;
    assign _e_3231 = {3'd2};
    assign _e_3230 = {6'd40, _e_3231, x_n20, 2'bX};
    assign _e_3229 = {1'd1, _e_3230};
    assign _e_3236 = _e_3062;
    assign _e_3233 = _e_3062[43:33];
    assign _e_3235 = _e_3062[32:0];
    assign x_n21 = _e_3235[31:0];
    assign _e_8677 = _e_3233[10:4] == 7'd22;
    assign _e_8679 = _e_3235[32] == 1'd1;
    localparam[0:0] _e_8680 = 1;
    assign _e_8681 = _e_8679 && _e_8680;
    assign _e_8682 = _e_8677 && _e_8681;
    assign _e_3239 = {3'd3};
    assign _e_3238 = {6'd40, _e_3239, x_n21, 2'bX};
    assign _e_3237 = {1'd1, _e_3238};
    assign _e_3244 = _e_3062;
    assign _e_3241 = _e_3062[43:33];
    assign _e_3243 = _e_3062[32:0];
    assign x_n22 = _e_3243[31:0];
    assign _e_8685 = _e_3241[10:4] == 7'd23;
    assign _e_8687 = _e_3243[32] == 1'd1;
    localparam[0:0] _e_8688 = 1;
    assign _e_8689 = _e_8687 && _e_8688;
    assign _e_8690 = _e_8685 && _e_8689;
    assign _e_3247 = {3'd4};
    assign _e_3246 = {6'd40, _e_3247, x_n22, 2'bX};
    assign _e_3245 = {1'd1, _e_3246};
    assign _e_3252 = _e_3062;
    assign _e_3249 = _e_3062[43:33];
    assign _e_3251 = _e_3062[32:0];
    assign x_n23 = _e_3251[31:0];
    assign _e_8693 = _e_3249[10:4] == 7'd24;
    assign _e_8695 = _e_3251[32] == 1'd1;
    localparam[0:0] _e_8696 = 1;
    assign _e_8697 = _e_8695 && _e_8696;
    assign _e_8698 = _e_8693 && _e_8697;
    assign _e_3255 = {3'd5};
    assign _e_3254 = {6'd40, _e_3255, x_n23, 2'bX};
    assign _e_3253 = {1'd1, _e_3254};
    assign _e_3260 = _e_3062;
    assign _e_3257 = _e_3062[43:33];
    assign _e_3259 = _e_3062[32:0];
    assign x_n24 = _e_3259[31:0];
    assign _e_8701 = _e_3257[10:4] == 7'd25;
    assign _e_8703 = _e_3259[32] == 1'd1;
    localparam[0:0] _e_8704 = 1;
    assign _e_8705 = _e_8703 && _e_8704;
    assign _e_8706 = _e_8701 && _e_8705;
    assign _e_3263 = {3'd6};
    assign _e_3262 = {6'd40, _e_3263, x_n24, 2'bX};
    assign _e_3261 = {1'd1, _e_3262};
    assign _e_3268 = _e_3062;
    assign _e_3265 = _e_3062[43:33];
    assign _e_3267 = _e_3062[32:0];
    assign x_n25 = _e_3267[31:0];
    assign _e_8709 = _e_3265[10:4] == 7'd26;
    assign _e_8711 = _e_3267[32] == 1'd1;
    localparam[0:0] _e_8712 = 1;
    assign _e_8713 = _e_8711 && _e_8712;
    assign _e_8714 = _e_8709 && _e_8713;
    assign _e_3271 = {3'd7};
    assign _e_3270 = {6'd40, _e_3271, x_n25, 2'bX};
    assign _e_3269 = {1'd1, _e_3270};
    assign _e_3276 = _e_3062;
    assign _e_3273 = _e_3062[43:33];
    assign _e_3275 = _e_3062[32:0];
    assign x_n26 = _e_3275[31:0];
    assign _e_8717 = _e_3273[10:4] == 7'd27;
    assign _e_8719 = _e_3275[32] == 1'd1;
    localparam[0:0] _e_8720 = 1;
    assign _e_8721 = _e_8719 && _e_8720;
    assign _e_8722 = _e_8717 && _e_8721;
    assign _e_3278 = {6'd14, x_n26, 5'bX};
    assign _e_3277 = {1'd1, _e_3278};
    assign _e_3283 = _e_3062;
    assign _e_3280 = _e_3062[43:33];
    assign _e_3282 = _e_3062[32:0];
    assign x_n27 = _e_3282[31:0];
    assign _e_8725 = _e_3280[10:4] == 7'd28;
    assign _e_8727 = _e_3282[32] == 1'd1;
    localparam[0:0] _e_8728 = 1;
    assign _e_8729 = _e_8727 && _e_8728;
    assign _e_8730 = _e_8725 && _e_8729;
    assign _e_3286 = {1'd0};
    assign _e_3285 = {6'd15, _e_3286, x_n27, 4'bX};
    assign _e_3284 = {1'd1, _e_3285};
    assign _e_3291 = _e_3062;
    assign _e_3288 = _e_3062[43:33];
    assign _e_3290 = _e_3062[32:0];
    assign x_n28 = _e_3290[31:0];
    assign _e_8733 = _e_3288[10:4] == 7'd29;
    assign _e_8735 = _e_3290[32] == 1'd1;
    localparam[0:0] _e_8736 = 1;
    assign _e_8737 = _e_8735 && _e_8736;
    assign _e_8738 = _e_8733 && _e_8737;
    assign _e_3294 = {1'd1};
    assign _e_3293 = {6'd15, _e_3294, x_n28, 4'bX};
    assign _e_3292 = {1'd1, _e_3293};
    assign _e_3299 = _e_3062;
    assign _e_3296 = _e_3062[43:33];
    assign _e_3298 = _e_3062[32:0];
    assign x_n29 = _e_3298[31:0];
    assign _e_8741 = _e_3296[10:4] == 7'd30;
    assign _e_8743 = _e_3298[32] == 1'd1;
    localparam[0:0] _e_8744 = 1;
    assign _e_8745 = _e_8743 && _e_8744;
    assign _e_8746 = _e_8741 && _e_8745;
    assign _e_3302 = x_n29[9:0];
    assign _e_3301 = {6'd3, _e_3302, 27'bX};
    assign _e_3300 = {1'd1, _e_3301};
    assign _e_3307 = _e_3062;
    assign _e_3304 = _e_3062[43:33];
    assign _e_3306 = _e_3062[32:0];
    assign x_n30 = _e_3306[31:0];
    assign _e_8749 = _e_3304[10:4] == 7'd31;
    assign _e_8751 = _e_3306[32] == 1'd1;
    localparam[0:0] _e_8752 = 1;
    assign _e_8753 = _e_8751 && _e_8752;
    assign _e_8754 = _e_8749 && _e_8753;
    assign _e_3310 = x_n30[9:0];
    assign _e_3309 = {6'd18, _e_3310, 27'bX};
    assign _e_3308 = {1'd1, _e_3309};
    assign _e_3315 = _e_3062;
    assign _e_3312 = _e_3062[43:33];
    assign _e_3314 = _e_3062[32:0];
    assign x_n31 = _e_3314[31:0];
    assign _e_8757 = _e_3312[10:4] == 7'd32;
    assign _e_8759 = _e_3314[32] == 1'd1;
    localparam[0:0] _e_8760 = 1;
    assign _e_8761 = _e_8759 && _e_8760;
    assign _e_8762 = _e_8757 && _e_8761;
    assign _e_3317 = {6'd19, x_n31, 5'bX};
    assign _e_3316 = {1'd1, _e_3317};
    assign _e_3322 = _e_3062;
    assign _e_3319 = _e_3062[43:33];
    assign _e_3321 = _e_3062[32:0];
    assign x_n32 = _e_3321[31:0];
    assign _e_8765 = _e_3319[10:4] == 7'd33;
    assign _e_8767 = _e_3321[32] == 1'd1;
    localparam[0:0] _e_8768 = 1;
    assign _e_8769 = _e_8767 && _e_8768;
    assign _e_8770 = _e_8765 && _e_8769;
    assign _e_3324 = {6'd4, x_n32, 5'bX};
    assign _e_3323 = {1'd1, _e_3324};
    assign _e_3329 = _e_3062;
    assign _e_3326 = _e_3062[43:33];
    assign _e_3328 = _e_3062[32:0];
    assign x_n33 = _e_3328[31:0];
    assign _e_8773 = _e_3326[10:4] == 7'd34;
    assign _e_8775 = _e_3328[32] == 1'd1;
    localparam[0:0] _e_8776 = 1;
    assign _e_8777 = _e_8775 && _e_8776;
    assign _e_8778 = _e_8773 && _e_8777;
    assign _e_3331 = {6'd5, x_n33, 5'bX};
    assign _e_3330 = {1'd1, _e_3331};
    assign _e_3336 = _e_3062;
    assign _e_3333 = _e_3062[43:33];
    assign _e_3335 = _e_3062[32:0];
    assign x_n34 = _e_3335[31:0];
    assign _e_8781 = _e_3333[10:4] == 7'd35;
    assign _e_8783 = _e_3335[32] == 1'd1;
    localparam[0:0] _e_8784 = 1;
    assign _e_8785 = _e_8783 && _e_8784;
    assign _e_8786 = _e_8781 && _e_8785;
    assign _e_3338 = {6'd6, x_n34, 5'bX};
    assign _e_3337 = {1'd1, _e_3338};
    assign _e_3343 = _e_3062;
    assign _e_3340 = _e_3062[43:33];
    assign _e_3342 = _e_3062[32:0];
    assign x_n35 = _e_3342[31:0];
    assign _e_8789 = _e_3340[10:4] == 7'd36;
    assign _e_8791 = _e_3342[32] == 1'd1;
    localparam[0:0] _e_8792 = 1;
    assign _e_8793 = _e_8791 && _e_8792;
    assign _e_8794 = _e_8789 && _e_8793;
    assign _e_3345 = {6'd7, x_n35, 5'bX};
    assign _e_3344 = {1'd1, _e_3345};
    assign _e_3350 = _e_3062;
    assign _e_3347 = _e_3062[43:33];
    assign _e_3349 = _e_3062[32:0];
    assign x_n36 = _e_3349[31:0];
    assign _e_8797 = _e_3347[10:4] == 7'd37;
    assign _e_8799 = _e_3349[32] == 1'd1;
    localparam[0:0] _e_8800 = 1;
    assign _e_8801 = _e_8799 && _e_8800;
    assign _e_8802 = _e_8797 && _e_8801;
    assign _e_3352 = {6'd8, x_n36, 5'bX};
    assign _e_3351 = {1'd1, _e_3352};
    assign _e_3357 = _e_3062;
    assign _e_3354 = _e_3062[43:33];
    assign _e_3356 = _e_3062[32:0];
    assign x_n37 = _e_3356[31:0];
    assign _e_8805 = _e_3354[10:4] == 7'd38;
    assign _e_8807 = _e_3356[32] == 1'd1;
    localparam[0:0] _e_8808 = 1;
    assign _e_8809 = _e_8807 && _e_8808;
    assign _e_8810 = _e_8805 && _e_8809;
    assign _e_3359 = {6'd9, x_n37, 5'bX};
    assign _e_3358 = {1'd1, _e_3359};
    assign _e_3364 = _e_3062;
    assign _e_3361 = _e_3062[43:33];
    assign _e_3363 = _e_3062[32:0];
    assign x_n38 = _e_3363[31:0];
    assign _e_8813 = _e_3361[10:4] == 7'd39;
    assign _e_8815 = _e_3363[32] == 1'd1;
    localparam[0:0] _e_8816 = 1;
    assign _e_8817 = _e_8815 && _e_8816;
    assign _e_8818 = _e_8813 && _e_8817;
    assign _e_3367 = x_n38[15:0];
    assign _e_3366 = {6'd10, _e_3367, 21'bX};
    assign _e_3365 = {1'd1, _e_3366};
    assign _e_3372 = _e_3062;
    assign _e_3369 = _e_3062[43:33];
    assign _e_3371 = _e_3062[32:0];
    assign x_n39 = _e_3371[31:0];
    assign _e_8821 = _e_3369[10:4] == 7'd40;
    assign _e_8823 = _e_3371[32] == 1'd1;
    localparam[0:0] _e_8824 = 1;
    assign _e_8825 = _e_8823 && _e_8824;
    assign _e_8826 = _e_8821 && _e_8825;
    assign _e_3374 = {6'd11, x_n39, 5'bX};
    assign _e_3373 = {1'd1, _e_3374};
    assign _e_3379 = _e_3062;
    assign _e_3376 = _e_3062[43:33];
    assign _e_3378 = _e_3062[32:0];
    assign x_n40 = _e_3378[31:0];
    assign _e_8829 = _e_3376[10:4] == 7'd41;
    assign _e_8831 = _e_3378[32] == 1'd1;
    localparam[0:0] _e_8832 = 1;
    assign _e_8833 = _e_8831 && _e_8832;
    assign _e_8834 = _e_8829 && _e_8833;
    assign _e_3382 = {3'd0};
    assign _e_3381 = {6'd12, _e_3382, x_n40, 2'bX};
    assign _e_3380 = {1'd1, _e_3381};
    assign _e_3387 = _e_3062;
    assign _e_3384 = _e_3062[43:33];
    assign _e_3386 = _e_3062[32:0];
    assign x_n41 = _e_3386[31:0];
    assign _e_8837 = _e_3384[10:4] == 7'd42;
    assign _e_8839 = _e_3386[32] == 1'd1;
    localparam[0:0] _e_8840 = 1;
    assign _e_8841 = _e_8839 && _e_8840;
    assign _e_8842 = _e_8837 && _e_8841;
    assign _e_3390 = {3'd1};
    assign _e_3389 = {6'd12, _e_3390, x_n41, 2'bX};
    assign _e_3388 = {1'd1, _e_3389};
    assign _e_3395 = _e_3062;
    assign _e_3392 = _e_3062[43:33];
    assign _e_3394 = _e_3062[32:0];
    assign x_n42 = _e_3394[31:0];
    assign _e_8845 = _e_3392[10:4] == 7'd43;
    assign _e_8847 = _e_3394[32] == 1'd1;
    localparam[0:0] _e_8848 = 1;
    assign _e_8849 = _e_8847 && _e_8848;
    assign _e_8850 = _e_8845 && _e_8849;
    assign _e_3398 = {3'd2};
    assign _e_3397 = {6'd12, _e_3398, x_n42, 2'bX};
    assign _e_3396 = {1'd1, _e_3397};
    assign _e_3403 = _e_3062;
    assign _e_3400 = _e_3062[43:33];
    assign _e_3402 = _e_3062[32:0];
    assign x_n43 = _e_3402[31:0];
    assign _e_8853 = _e_3400[10:4] == 7'd44;
    assign _e_8855 = _e_3402[32] == 1'd1;
    localparam[0:0] _e_8856 = 1;
    assign _e_8857 = _e_8855 && _e_8856;
    assign _e_8858 = _e_8853 && _e_8857;
    assign _e_3406 = {3'd3};
    assign _e_3405 = {6'd12, _e_3406, x_n43, 2'bX};
    assign _e_3404 = {1'd1, _e_3405};
    assign _e_3411 = _e_3062;
    assign _e_3408 = _e_3062[43:33];
    assign _e_3410 = _e_3062[32:0];
    assign x_n44 = _e_3410[31:0];
    assign _e_8861 = _e_3408[10:4] == 7'd45;
    assign _e_8863 = _e_3410[32] == 1'd1;
    localparam[0:0] _e_8864 = 1;
    assign _e_8865 = _e_8863 && _e_8864;
    assign _e_8866 = _e_8861 && _e_8865;
    assign _e_3414 = {3'd4};
    assign _e_3413 = {6'd12, _e_3414, x_n44, 2'bX};
    assign _e_3412 = {1'd1, _e_3413};
    assign _e_3419 = _e_3062;
    assign _e_3416 = _e_3062[43:33];
    assign _e_3418 = _e_3062[32:0];
    assign x_n45 = _e_3418[31:0];
    assign _e_8869 = _e_3416[10:4] == 7'd46;
    assign _e_8871 = _e_3418[32] == 1'd1;
    localparam[0:0] _e_8872 = 1;
    assign _e_8873 = _e_8871 && _e_8872;
    assign _e_8874 = _e_8869 && _e_8873;
    assign _e_3422 = {3'd5};
    assign _e_3421 = {6'd12, _e_3422, x_n45, 2'bX};
    assign _e_3420 = {1'd1, _e_3421};
    assign _e_3427 = _e_3062;
    assign _e_3424 = _e_3062[43:33];
    assign _e_3426 = _e_3062[32:0];
    assign x_n46 = _e_3426[31:0];
    assign _e_8877 = _e_3424[10:4] == 7'd47;
    assign _e_8879 = _e_3426[32] == 1'd1;
    localparam[0:0] _e_8880 = 1;
    assign _e_8881 = _e_8879 && _e_8880;
    assign _e_8882 = _e_8877 && _e_8881;
    assign _e_3430 = {3'd0};
    assign _e_3429 = {6'd13, _e_3430, x_n46, 2'bX};
    assign _e_3428 = {1'd1, _e_3429};
    assign _e_3435 = _e_3062;
    assign _e_3432 = _e_3062[43:33];
    assign _e_3434 = _e_3062[32:0];
    assign x_n47 = _e_3434[31:0];
    assign _e_8885 = _e_3432[10:4] == 7'd48;
    assign _e_8887 = _e_3434[32] == 1'd1;
    localparam[0:0] _e_8888 = 1;
    assign _e_8889 = _e_8887 && _e_8888;
    assign _e_8890 = _e_8885 && _e_8889;
    assign _e_3438 = {3'd1};
    assign _e_3437 = {6'd13, _e_3438, x_n47, 2'bX};
    assign _e_3436 = {1'd1, _e_3437};
    assign _e_3443 = _e_3062;
    assign _e_3440 = _e_3062[43:33];
    assign _e_3442 = _e_3062[32:0];
    assign x_n48 = _e_3442[31:0];
    assign _e_8893 = _e_3440[10:4] == 7'd49;
    assign _e_8895 = _e_3442[32] == 1'd1;
    localparam[0:0] _e_8896 = 1;
    assign _e_8897 = _e_8895 && _e_8896;
    assign _e_8898 = _e_8893 && _e_8897;
    assign _e_3446 = {3'd2};
    assign _e_3445 = {6'd13, _e_3446, x_n48, 2'bX};
    assign _e_3444 = {1'd1, _e_3445};
    assign _e_3451 = _e_3062;
    assign _e_3448 = _e_3062[43:33];
    assign _e_3450 = _e_3062[32:0];
    assign x_n49 = _e_3450[31:0];
    assign _e_8901 = _e_3448[10:4] == 7'd50;
    assign _e_8903 = _e_3450[32] == 1'd1;
    localparam[0:0] _e_8904 = 1;
    assign _e_8905 = _e_8903 && _e_8904;
    assign _e_8906 = _e_8901 && _e_8905;
    assign _e_3454 = {3'd3};
    assign _e_3453 = {6'd13, _e_3454, x_n49, 2'bX};
    assign _e_3452 = {1'd1, _e_3453};
    assign _e_3459 = _e_3062;
    assign _e_3456 = _e_3062[43:33];
    assign _e_3458 = _e_3062[32:0];
    assign x_n50 = _e_3458[31:0];
    assign _e_8909 = _e_3456[10:4] == 7'd51;
    assign _e_8911 = _e_3458[32] == 1'd1;
    localparam[0:0] _e_8912 = 1;
    assign _e_8913 = _e_8911 && _e_8912;
    assign _e_8914 = _e_8909 && _e_8913;
    assign _e_3462 = {3'd4};
    assign _e_3461 = {6'd13, _e_3462, x_n50, 2'bX};
    assign _e_3460 = {1'd1, _e_3461};
    assign _e_3467 = _e_3062;
    assign _e_3464 = _e_3062[43:33];
    assign _e_3466 = _e_3062[32:0];
    assign x_n51 = _e_3466[31:0];
    assign _e_8917 = _e_3464[10:4] == 7'd52;
    assign _e_8919 = _e_3466[32] == 1'd1;
    localparam[0:0] _e_8920 = 1;
    assign _e_8921 = _e_8919 && _e_8920;
    assign _e_8922 = _e_8917 && _e_8921;
    assign _e_3470 = {3'd5};
    assign _e_3469 = {6'd13, _e_3470, x_n51, 2'bX};
    assign _e_3468 = {1'd1, _e_3469};
    assign _e_3475 = _e_3062;
    assign _e_3472 = _e_3062[43:33];
    assign _e_3474 = _e_3062[32:0];
    assign x_n52 = _e_3474[31:0];
    assign _e_8925 = _e_3472[10:4] == 7'd53;
    assign _e_8927 = _e_3474[32] == 1'd1;
    localparam[0:0] _e_8928 = 1;
    assign _e_8929 = _e_8927 && _e_8928;
    assign _e_8930 = _e_8925 && _e_8929;
    assign _e_3477 = {6'd16, x_n52, 5'bX};
    assign _e_3476 = {1'd1, _e_3477};
    assign _e_3482 = _e_3062;
    assign _e_3479 = _e_3062[43:33];
    assign _e_3481 = _e_3062[32:0];
    assign x_n53 = _e_3481[31:0];
    assign _e_8933 = _e_3479[10:4] == 7'd54;
    assign _e_8935 = _e_3481[32] == 1'd1;
    localparam[0:0] _e_8936 = 1;
    assign _e_8937 = _e_8935 && _e_8936;
    assign _e_8938 = _e_8933 && _e_8937;
    assign _e_3484 = {6'd17, x_n53, 5'bX};
    assign _e_3483 = {1'd1, _e_3484};
    assign _e_3489 = _e_3062;
    assign _e_3486 = _e_3062[43:33];
    assign _e_3488 = _e_3062[32:0];
    assign x_n54 = _e_3488[31:0];
    assign _e_8941 = _e_3486[10:4] == 7'd55;
    assign _e_8943 = _e_3488[32] == 1'd1;
    localparam[0:0] _e_8944 = 1;
    assign _e_8945 = _e_8943 && _e_8944;
    assign _e_8946 = _e_8941 && _e_8945;
    assign _e_3491 = {6'd21, x_n54, 5'bX};
    assign _e_3490 = {1'd1, _e_3491};
    assign _e_3496 = _e_3062;
    assign _e_3493 = _e_3062[43:33];
    assign _e_3495 = _e_3062[32:0];
    assign x_n55 = _e_3495[31:0];
    assign _e_8949 = _e_3493[10:4] == 7'd56;
    assign _e_8951 = _e_3495[32] == 1'd1;
    localparam[0:0] _e_8952 = 1;
    assign _e_8953 = _e_8951 && _e_8952;
    assign _e_8954 = _e_8949 && _e_8953;
    assign _e_3498 = {6'd22, x_n55, 5'bX};
    assign _e_3497 = {1'd1, _e_3498};
    assign _e_3503 = _e_3062;
    assign _e_3500 = _e_3062[43:33];
    assign _e_3502 = _e_3062[32:0];
    assign x_n56 = _e_3502[31:0];
    assign _e_8957 = _e_3500[10:4] == 7'd57;
    assign _e_8959 = _e_3502[32] == 1'd1;
    localparam[0:0] _e_8960 = 1;
    assign _e_8961 = _e_8959 && _e_8960;
    assign _e_8962 = _e_8957 && _e_8961;
    assign _e_3505 = {6'd23, x_n56, 5'bX};
    assign _e_3504 = {1'd1, _e_3505};
    assign _e_3510 = _e_3062;
    assign _e_3507 = _e_3062[43:33];
    assign _e_3509 = _e_3062[32:0];
    assign x_n57 = _e_3509[31:0];
    assign _e_8965 = _e_3507[10:4] == 7'd58;
    assign _e_8967 = _e_3509[32] == 1'd1;
    localparam[0:0] _e_8968 = 1;
    assign _e_8969 = _e_8967 && _e_8968;
    assign _e_8970 = _e_8965 && _e_8969;
    assign _e_3512 = {6'd24, x_n57, 5'bX};
    assign _e_3511 = {1'd1, _e_3512};
    assign _e_3517 = _e_3062;
    assign _e_3514 = _e_3062[43:33];
    assign _e_3516 = _e_3062[32:0];
    assign x_n58 = _e_3516[31:0];
    assign _e_8973 = _e_3514[10:4] == 7'd59;
    assign _e_8975 = _e_3516[32] == 1'd1;
    localparam[0:0] _e_8976 = 1;
    assign _e_8977 = _e_8975 && _e_8976;
    assign _e_8978 = _e_8973 && _e_8977;
    assign _e_3519 = {6'd25, x_n58, 5'bX};
    assign _e_3518 = {1'd1, _e_3519};
    assign _e_3524 = _e_3062;
    assign _e_3521 = _e_3062[43:33];
    assign _e_3523 = _e_3062[32:0];
    assign x_n59 = _e_3523[31:0];
    assign _e_8981 = _e_3521[10:4] == 7'd60;
    assign _e_8983 = _e_3523[32] == 1'd1;
    localparam[0:0] _e_8984 = 1;
    assign _e_8985 = _e_8983 && _e_8984;
    assign _e_8986 = _e_8981 && _e_8985;
    localparam[31:0] _e_3529 = 32'd0;
    assign _e_3527 = x_n59 != _e_3529;
    assign _e_3526 = {6'd26, _e_3527, 36'bX};
    assign _e_3525 = {1'd1, _e_3526};
    assign _e_3533 = _e_3062;
    assign _e_3530 = _e_3062[43:33];
    assign _e_3532 = _e_3062[32:0];
    assign x_n60 = _e_3532[31:0];
    assign _e_8989 = _e_3530[10:4] == 7'd61;
    assign _e_8991 = _e_3532[32] == 1'd1;
    localparam[0:0] _e_8992 = 1;
    assign _e_8993 = _e_8991 && _e_8992;
    assign _e_8994 = _e_8989 && _e_8993;
    localparam[31:0] _e_3538 = 32'd0;
    assign _e_3536 = x_n60 != _e_3538;
    assign _e_3535 = {6'd27, _e_3536, 36'bX};
    assign _e_3534 = {1'd1, _e_3535};
    assign _e_3542 = _e_3062;
    assign _e_3539 = _e_3062[43:33];
    assign _e_3541 = _e_3062[32:0];
    assign x_n61 = _e_3541[31:0];
    assign _e_8997 = _e_3539[10:4] == 7'd62;
    assign _e_8999 = _e_3541[32] == 1'd1;
    localparam[0:0] _e_9000 = 1;
    assign _e_9001 = _e_8999 && _e_9000;
    assign _e_9002 = _e_8997 && _e_9001;
    assign _e_3544 = {6'd28, x_n61, 5'bX};
    assign _e_3543 = {1'd1, _e_3544};
    assign _e_3549 = _e_3062;
    assign _e_3546 = _e_3062[43:33];
    assign _e_3548 = _e_3062[32:0];
    assign x_n62 = _e_3548[31:0];
    assign _e_9005 = _e_3546[10:4] == 7'd63;
    assign _e_9007 = _e_3548[32] == 1'd1;
    localparam[0:0] _e_9008 = 1;
    assign _e_9009 = _e_9007 && _e_9008;
    assign _e_9010 = _e_9005 && _e_9009;
    assign _e_3551 = {6'd29, x_n62, 5'bX};
    assign _e_3550 = {1'd1, _e_3551};
    assign _e_3556 = _e_3062;
    assign _e_3553 = _e_3062[43:33];
    assign _e_3555 = _e_3062[32:0];
    assign x_n63 = _e_3555[31:0];
    assign _e_9013 = _e_3553[10:4] == 7'd64;
    assign _e_9015 = _e_3555[32] == 1'd1;
    localparam[0:0] _e_9016 = 1;
    assign _e_9017 = _e_9015 && _e_9016;
    assign _e_9018 = _e_9013 && _e_9017;
    assign _e_3558 = {6'd30, x_n63, 5'bX};
    assign _e_3557 = {1'd1, _e_3558};
    assign _e_3563 = _e_3062;
    assign _e_3560 = _e_3062[43:33];
    assign _e_3562 = _e_3062[32:0];
    assign x_n64 = _e_3562[31:0];
    assign _e_9021 = _e_3560[10:4] == 7'd65;
    assign _e_9023 = _e_3562[32] == 1'd1;
    localparam[0:0] _e_9024 = 1;
    assign _e_9025 = _e_9023 && _e_9024;
    assign _e_9026 = _e_9021 && _e_9025;
    assign _e_3565 = {6'd31, x_n64, 5'bX};
    assign _e_3564 = {1'd1, _e_3565};
    assign _e_3570 = _e_3062;
    assign _e_3567 = _e_3062[43:33];
    assign _e_3569 = _e_3062[32:0];
    assign x_n65 = _e_3569[31:0];
    assign _e_9029 = _e_3567[10:4] == 7'd66;
    assign _e_9031 = _e_3569[32] == 1'd1;
    localparam[0:0] _e_9032 = 1;
    assign _e_9033 = _e_9031 && _e_9032;
    assign _e_9034 = _e_9029 && _e_9033;
    assign _e_3572 = {6'd32, x_n65, 5'bX};
    assign _e_3571 = {1'd1, _e_3572};
    assign _e_3577 = _e_3062;
    assign _e_3574 = _e_3062[43:33];
    assign _e_3576 = _e_3062[32:0];
    assign x_n66 = _e_3576[31:0];
    assign _e_9037 = _e_3574[10:4] == 7'd67;
    assign _e_9039 = _e_3576[32] == 1'd1;
    localparam[0:0] _e_9040 = 1;
    assign _e_9041 = _e_9039 && _e_9040;
    assign _e_9042 = _e_9037 && _e_9041;
    assign _e_3579 = {6'd33, x_n66, 5'bX};
    assign _e_3578 = {1'd1, _e_3579};
    assign _e_3584 = _e_3062;
    assign _e_3581 = _e_3062[43:33];
    assign _e_3583 = _e_3062[32:0];
    assign x_n67 = _e_3583[31:0];
    assign _e_9045 = _e_3581[10:4] == 7'd68;
    assign _e_9047 = _e_3583[32] == 1'd1;
    localparam[0:0] _e_9048 = 1;
    assign _e_9049 = _e_9047 && _e_9048;
    assign _e_9050 = _e_9045 && _e_9049;
    assign _e_3586 = {6'd34, x_n67, 5'bX};
    assign _e_3585 = {1'd1, _e_3586};
    assign _e_3591 = _e_3062;
    assign _e_3588 = _e_3062[43:33];
    assign _e_3590 = _e_3062[32:0];
    assign x_n68 = _e_3590[31:0];
    assign _e_9053 = _e_3588[10:4] == 7'd69;
    assign _e_9055 = _e_3590[32] == 1'd1;
    localparam[0:0] _e_9056 = 1;
    assign _e_9057 = _e_9055 && _e_9056;
    assign _e_9058 = _e_9053 && _e_9057;
    assign _e_3593 = {6'd35, x_n68, 5'bX};
    assign _e_3592 = {1'd1, _e_3593};
    assign _e_3598 = _e_3062;
    assign _e_3595 = _e_3062[43:33];
    assign _e_3597 = _e_3062[32:0];
    assign x_n69 = _e_3597[31:0];
    assign _e_9061 = _e_3595[10:4] == 7'd70;
    assign _e_9063 = _e_3597[32] == 1'd1;
    localparam[0:0] _e_9064 = 1;
    assign _e_9065 = _e_9063 && _e_9064;
    assign _e_9066 = _e_9061 && _e_9065;
    assign _e_3600 = {6'd36, x_n69, 5'bX};
    assign _e_3599 = {1'd1, _e_3600};
    assign _e_3605 = _e_3062;
    assign _e_3602 = _e_3062[43:33];
    assign _e_3604 = _e_3062[32:0];
    assign x_n70 = _e_3604[31:0];
    assign _e_9069 = _e_3602[10:4] == 7'd71;
    assign _e_9071 = _e_3604[32] == 1'd1;
    localparam[0:0] _e_9072 = 1;
    assign _e_9073 = _e_9071 && _e_9072;
    assign _e_9074 = _e_9069 && _e_9073;
    assign _e_3607 = {6'd37, 37'bX};
    assign _e_3606 = {1'd1, _e_3607};
    assign _e_3611 = _e_3062;
    assign _e_3608 = _e_3062[43:33];
    assign _e_3610 = _e_3062[32:0];
    assign x_n71 = _e_3610[31:0];
    assign _e_9077 = _e_3608[10:4] == 7'd72;
    assign _e_9079 = _e_3610[32] == 1'd1;
    localparam[0:0] _e_9080 = 1;
    assign _e_9081 = _e_9079 && _e_9080;
    assign _e_9082 = _e_9077 && _e_9081;
    assign _e_3614 = x_n71[7:0];
    assign _e_3613 = {6'd20, _e_3614, 29'bX};
    assign _e_3612 = {1'd1, _e_3613};
    assign _e_3619 = _e_3062;
    assign _e_3616 = _e_3062[43:33];
    assign _e_3618 = _e_3062[32:0];
    assign x_n72 = _e_3618[31:0];
    assign _e_9085 = _e_3616[10:4] == 7'd75;
    assign _e_9087 = _e_3618[32] == 1'd1;
    localparam[0:0] _e_9088 = 1;
    assign _e_9089 = _e_9087 && _e_9088;
    assign _e_9090 = _e_9085 && _e_9089;
    assign _e_3621 = {6'd42, 37'bX};
    assign _e_3620 = {1'd1, _e_3621};
    assign _e_3625 = _e_3062;
    assign _e_3622 = _e_3062[43:33];
    assign _e_3624 = _e_3062[32:0];
    assign x_n73 = _e_3624[31:0];
    assign _e_9093 = _e_3622[10:4] == 7'd73;
    assign _e_9095 = _e_3624[32] == 1'd1;
    localparam[0:0] _e_9096 = 1;
    assign _e_9097 = _e_9095 && _e_9096;
    assign _e_9098 = _e_9093 && _e_9097;
    assign _e_3628 = x_n73[7:0];
    assign _e_3627 = {6'd38, _e_3628, 29'bX};
    assign _e_3626 = {1'd1, _e_3627};
    assign _e_3633 = _e_3062;
    assign _e_3630 = _e_3062[43:33];
    assign _e_3632 = _e_3062[32:0];
    assign x_n74 = _e_3632[31:0];
    assign _e_9101 = _e_3630[10:4] == 7'd74;
    assign _e_9103 = _e_3632[32] == 1'd1;
    localparam[0:0] _e_9104 = 1;
    assign _e_9105 = _e_9103 && _e_9104;
    assign _e_9106 = _e_9101 && _e_9105;
    assign _e_3635 = {6'd41, 37'bX};
    assign _e_3634 = {1'd1, _e_3635};
    assign \_  = _e_3062;
    localparam[0:0] _e_9107 = 1;
    assign _e_3637 = {1'd0, 43'bX};
    always_comb begin
        priority casez ({_e_8514, _e_8522, _e_8530, _e_8538, _e_8546, _e_8554, _e_8562, _e_8570, _e_8578, _e_8586, _e_8594, _e_8602, _e_8610, _e_8618, _e_8626, _e_8634, _e_8642, _e_8650, _e_8658, _e_8666, _e_8674, _e_8682, _e_8690, _e_8698, _e_8706, _e_8714, _e_8722, _e_8730, _e_8738, _e_8746, _e_8754, _e_8762, _e_8770, _e_8778, _e_8786, _e_8794, _e_8802, _e_8810, _e_8818, _e_8826, _e_8834, _e_8842, _e_8850, _e_8858, _e_8866, _e_8874, _e_8882, _e_8890, _e_8898, _e_8906, _e_8914, _e_8922, _e_8930, _e_8938, _e_8946, _e_8954, _e_8962, _e_8970, _e_8978, _e_8986, _e_8994, _e_9002, _e_9010, _e_9018, _e_9026, _e_9034, _e_9042, _e_9050, _e_9058, _e_9066, _e_9074, _e_9082, _e_9090, _e_9098, _e_9106, _e_9107})
            76'b1???????????????????????????????????????????????????????????????????????????: _e_3061 = _e_3070;
            76'b01??????????????????????????????????????????????????????????????????????????: _e_3061 = _e_3078;
            76'b001?????????????????????????????????????????????????????????????????????????: _e_3061 = _e_3085;
            76'b0001????????????????????????????????????????????????????????????????????????: _e_3061 = _e_3093;
            76'b00001???????????????????????????????????????????????????????????????????????: _e_3061 = _e_3101;
            76'b000001??????????????????????????????????????????????????????????????????????: _e_3061 = _e_3109;
            76'b0000001?????????????????????????????????????????????????????????????????????: _e_3061 = _e_3117;
            76'b00000001????????????????????????????????????????????????????????????????????: _e_3061 = _e_3125;
            76'b000000001???????????????????????????????????????????????????????????????????: _e_3061 = _e_3133;
            76'b0000000001??????????????????????????????????????????????????????????????????: _e_3061 = _e_3141;
            76'b00000000001?????????????????????????????????????????????????????????????????: _e_3061 = _e_3149;
            76'b000000000001????????????????????????????????????????????????????????????????: _e_3061 = _e_3157;
            76'b0000000000001???????????????????????????????????????????????????????????????: _e_3061 = _e_3165;
            76'b00000000000001??????????????????????????????????????????????????????????????: _e_3061 = _e_3173;
            76'b000000000000001?????????????????????????????????????????????????????????????: _e_3061 = _e_3181;
            76'b0000000000000001????????????????????????????????????????????????????????????: _e_3061 = _e_3189;
            76'b00000000000000001???????????????????????????????????????????????????????????: _e_3061 = _e_3197;
            76'b000000000000000001??????????????????????????????????????????????????????????: _e_3061 = _e_3205;
            76'b0000000000000000001?????????????????????????????????????????????????????????: _e_3061 = _e_3213;
            76'b00000000000000000001????????????????????????????????????????????????????????: _e_3061 = _e_3221;
            76'b000000000000000000001???????????????????????????????????????????????????????: _e_3061 = _e_3229;
            76'b0000000000000000000001??????????????????????????????????????????????????????: _e_3061 = _e_3237;
            76'b00000000000000000000001?????????????????????????????????????????????????????: _e_3061 = _e_3245;
            76'b000000000000000000000001????????????????????????????????????????????????????: _e_3061 = _e_3253;
            76'b0000000000000000000000001???????????????????????????????????????????????????: _e_3061 = _e_3261;
            76'b00000000000000000000000001??????????????????????????????????????????????????: _e_3061 = _e_3269;
            76'b000000000000000000000000001?????????????????????????????????????????????????: _e_3061 = _e_3277;
            76'b0000000000000000000000000001????????????????????????????????????????????????: _e_3061 = _e_3284;
            76'b00000000000000000000000000001???????????????????????????????????????????????: _e_3061 = _e_3292;
            76'b000000000000000000000000000001??????????????????????????????????????????????: _e_3061 = _e_3300;
            76'b0000000000000000000000000000001?????????????????????????????????????????????: _e_3061 = _e_3308;
            76'b00000000000000000000000000000001????????????????????????????????????????????: _e_3061 = _e_3316;
            76'b000000000000000000000000000000001???????????????????????????????????????????: _e_3061 = _e_3323;
            76'b0000000000000000000000000000000001??????????????????????????????????????????: _e_3061 = _e_3330;
            76'b00000000000000000000000000000000001?????????????????????????????????????????: _e_3061 = _e_3337;
            76'b000000000000000000000000000000000001????????????????????????????????????????: _e_3061 = _e_3344;
            76'b0000000000000000000000000000000000001???????????????????????????????????????: _e_3061 = _e_3351;
            76'b00000000000000000000000000000000000001??????????????????????????????????????: _e_3061 = _e_3358;
            76'b000000000000000000000000000000000000001?????????????????????????????????????: _e_3061 = _e_3365;
            76'b0000000000000000000000000000000000000001????????????????????????????????????: _e_3061 = _e_3373;
            76'b00000000000000000000000000000000000000001???????????????????????????????????: _e_3061 = _e_3380;
            76'b000000000000000000000000000000000000000001??????????????????????????????????: _e_3061 = _e_3388;
            76'b0000000000000000000000000000000000000000001?????????????????????????????????: _e_3061 = _e_3396;
            76'b00000000000000000000000000000000000000000001????????????????????????????????: _e_3061 = _e_3404;
            76'b000000000000000000000000000000000000000000001???????????????????????????????: _e_3061 = _e_3412;
            76'b0000000000000000000000000000000000000000000001??????????????????????????????: _e_3061 = _e_3420;
            76'b00000000000000000000000000000000000000000000001?????????????????????????????: _e_3061 = _e_3428;
            76'b000000000000000000000000000000000000000000000001????????????????????????????: _e_3061 = _e_3436;
            76'b0000000000000000000000000000000000000000000000001???????????????????????????: _e_3061 = _e_3444;
            76'b00000000000000000000000000000000000000000000000001??????????????????????????: _e_3061 = _e_3452;
            76'b000000000000000000000000000000000000000000000000001?????????????????????????: _e_3061 = _e_3460;
            76'b0000000000000000000000000000000000000000000000000001????????????????????????: _e_3061 = _e_3468;
            76'b00000000000000000000000000000000000000000000000000001???????????????????????: _e_3061 = _e_3476;
            76'b000000000000000000000000000000000000000000000000000001??????????????????????: _e_3061 = _e_3483;
            76'b0000000000000000000000000000000000000000000000000000001?????????????????????: _e_3061 = _e_3490;
            76'b00000000000000000000000000000000000000000000000000000001????????????????????: _e_3061 = _e_3497;
            76'b000000000000000000000000000000000000000000000000000000001???????????????????: _e_3061 = _e_3504;
            76'b0000000000000000000000000000000000000000000000000000000001??????????????????: _e_3061 = _e_3511;
            76'b00000000000000000000000000000000000000000000000000000000001?????????????????: _e_3061 = _e_3518;
            76'b000000000000000000000000000000000000000000000000000000000001????????????????: _e_3061 = _e_3525;
            76'b0000000000000000000000000000000000000000000000000000000000001???????????????: _e_3061 = _e_3534;
            76'b00000000000000000000000000000000000000000000000000000000000001??????????????: _e_3061 = _e_3543;
            76'b000000000000000000000000000000000000000000000000000000000000001?????????????: _e_3061 = _e_3550;
            76'b0000000000000000000000000000000000000000000000000000000000000001????????????: _e_3061 = _e_3557;
            76'b00000000000000000000000000000000000000000000000000000000000000001???????????: _e_3061 = _e_3564;
            76'b000000000000000000000000000000000000000000000000000000000000000001??????????: _e_3061 = _e_3571;
            76'b0000000000000000000000000000000000000000000000000000000000000000001?????????: _e_3061 = _e_3578;
            76'b00000000000000000000000000000000000000000000000000000000000000000001????????: _e_3061 = _e_3585;
            76'b000000000000000000000000000000000000000000000000000000000000000000001???????: _e_3061 = _e_3592;
            76'b0000000000000000000000000000000000000000000000000000000000000000000001??????: _e_3061 = _e_3599;
            76'b00000000000000000000000000000000000000000000000000000000000000000000001?????: _e_3061 = _e_3606;
            76'b000000000000000000000000000000000000000000000000000000000000000000000001????: _e_3061 = _e_3612;
            76'b0000000000000000000000000000000000000000000000000000000000000000000000001???: _e_3061 = _e_3620;
            76'b00000000000000000000000000000000000000000000000000000000000000000000000001??: _e_3061 = _e_3626;
            76'b000000000000000000000000000000000000000000000000000000000000000000000000001?: _e_3061 = _e_3634;
            76'b0000000000000000000000000000000000000000000000000000000000000000000000000001: _e_3061 = _e_3637;
            76'b?: _e_3061 = 44'dx;
        endcase
    end
    assign output__ = _e_3061;
endmodule

module \tta::tta::tta  (
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input[97:0] insn_i,
        output[9:0] pc_w_o,
        input[15:0] gpi16_i,
        input[8:0] uart_rx_i,
        output[8:0] uart_tx_o,
        input uart_tx_busy_i,
        input[8:0] spi_miso_i,
        output[8:0] spi_mosi_o,
        input spi_busy_i,
        output[509:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::tta::tta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::tta::tta );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[97:0] \insn ;
    assign \insn  = insn_i;
    logic[9:0] \pc_w_mut ;
    assign pc_w_o = \pc_w_mut ;
    logic[15:0] \gpi16 ;
    assign \gpi16  = gpi16_i;
    logic[8:0] \uart_rx ;
    assign \uart_rx  = uart_rx_i;
    logic[8:0] \uart_tx_mut ;
    assign uart_tx_o = \uart_tx_mut ;
    logic \uart_tx_busy ;
    assign \uart_tx_busy  = uart_tx_busy_i;
    logic[8:0] \spi_miso ;
    assign \spi_miso  = spi_miso_i;
    logic[8:0] \spi_mosi_mut ;
    assign spi_mosi_o = \spi_mosi_mut ;
    logic \spi_busy ;
    assign \spi_busy  = spi_busy_i;
    (* src = "src/tta.spade:335,38" *)
    logic[10:0] _e_9108;
    (* src = "src/tta.spade:335,38" *)
    logic[10:0] _e_9109_mut;
    (* src = "src/tta.spade:335,38" *)
    logic[10:0] _e_3642;
    (* src = "src/tta.spade:335,38" *)
    logic[10:0] _e_3642_mut;
    (* src = "src/tta.spade:335,9" *)
    logic[10:0] \bt_target_r ;
    (* src = "src/tta.spade:335,9" *)
    logic[10:0] \bt_target_w_mut ;
    (* src = "src/tta.spade:338,19" *)
    logic[9:0] \pc_val ;
    (* src = "src/tta.spade:343,19" *)
    logic[10:0] \bt_val ;
    (* src = "src/tta.spade:349,19" *)
    logic[32:0] \alu_res ;
    (* src = "src/tta.spade:354,19" *)
    logic[32:0] \bit_res ;
    (* src = "src/tta.spade:359,20" *)
    logic[32:0] \lalu_res ;
    (* src = "src/tta.spade:364,19" *)
    logic[32:0] \mul_res ;
    (* src = "src/tta.spade:369,19" *)
    logic[32:0] \div_res ;
    (* src = "src/tta.spade:374,19" *)
    logic[32:0] \cmp_res ;
    (* src = "src/tta.spade:378,20" *)
    logic[32:0] \cmpz_res ;
    (* src = "src/tta.spade:384,19" *)
    logic[32:0] \lsu_res ;
    (* src = "src/tta.spade:390,20" *)
    logic[32:0] \lsu2_res ;
    (* src = "src/tta.spade:394,20" *)
    logic[32:0] \tanh_res ;
    (* src = "src/tta.spade:397,36" *)
    logic[63:0] _e_3726;
    (* src = "src/tta.spade:397,9" *)
    logic[31:0] \cc_res_lo ;
    (* src = "src/tta.spade:397,9" *)
    logic[31:0] \cc_res_high ;
    (* src = "src/tta.spade:401,24" *)
    logic[32:0] \xorshift_res ;
    (* src = "src/tta.spade:407,19" *)
    logic[32:0] \mac_res ;
    (* src = "src/tta.spade:413,19" *)
    logic[32:0] \sel_res ;
    (* src = "src/tta.spade:420,19" *)
    logic[32:0] \mda_res ;
    (* src = "src/tta.spade:426,21" *)
    logic[32:0] \stack_res ;
    (* src = "src/tta.spade:430,19" *)
    logic[15:0] \gpo_res ;
    (* src = "src/tta.spade:433,19" *)
    logic[32:0] \gpi_res ;
    (* src = "src/tta.spade:437,23" *)
    logic[32:0] \uart_in_res ;
    (* src = "src/tta.spade:443,22" *)
    logic[32:0] \spi_in_res ;
    (* src = "src/tta.spade:450,30" *)
    logic[48:0] _e_3799;
    (* src = "src/tta.spade:450,30" *)
    logic[36:0] _e_3798;
    (* src = "src/tta.spade:450,47" *)
    logic[36:0] _e_3802;
    (* src = "src/tta.spade:450,47" *)
    logic[3:0] \i ;
    logic _e_9111;
    logic _e_9113;
    (* src = "src/tta.spade:450,74" *)
    logic[36:0] __n2;
    (* src = "src/tta.spade:450,24" *)
    logic[3:0] \ra0 ;
    (* src = "src/tta.spade:451,30" *)
    logic[48:0] _e_3809;
    (* src = "src/tta.spade:451,30" *)
    logic[36:0] _e_3808;
    (* src = "src/tta.spade:451,47" *)
    logic[36:0] _e_3812;
    (* src = "src/tta.spade:451,47" *)
    logic[3:0] i_n1;
    logic _e_9116;
    logic _e_9118;
    (* src = "src/tta.spade:451,74" *)
    logic[36:0] __n3;
    (* src = "src/tta.spade:451,24" *)
    logic[3:0] \ra1 ;
    (* src = "src/tta.spade:455,20" *)
    logic[575:0] \registry ;
    (* src = "src/tta.spade:460,12" *)
    logic[48:0] _e_3827;
    (* src = "src/tta.spade:460,12" *)
    logic _e_3826;
    (* src = "src/tta.spade:461,19" *)
    logic[48:0] _e_3832;
    (* src = "src/tta.spade:461,19" *)
    logic[36:0] _e_3831;
    (* src = "src/tta.spade:462,17" *)
    logic[36:0] _e_3835;
    (* src = "src/tta.spade:462,17" *)
    logic[3:0] __n4;
    logic _e_9121;
    logic _e_9123;
    (* src = "src/tta.spade:462,48" *)
    logic[31:0] _e_3837;
    (* src = "src/tta.spade:462,43" *)
    logic[32:0] _e_3836;
    (* src = "src/tta.spade:463,17" *)
    logic[36:0] _e_3839;
    logic _e_9125;
    logic[31:0] _e_3841;
    (* src = "src/tta.spade:463,33" *)
    logic[32:0] _e_3840;
    (* src = "src/tta.spade:464,17" *)
    logic[36:0] _e_3843;
    logic _e_9127;
    (* src = "src/tta.spade:464,44" *)
    logic[10:0] _e_3846;
    logic[31:0] _e_3845;
    (* src = "src/tta.spade:464,34" *)
    logic[32:0] _e_3844;
    (* src = "src/tta.spade:465,17" *)
    logic[36:0] _e_3850;
    (* src = "src/tta.spade:465,17" *)
    logic[31:0] \v ;
    logic _e_9129;
    logic _e_9131;
    (* src = "src/tta.spade:465,39" *)
    logic[32:0] _e_3851;
    (* src = "src/tta.spade:466,17" *)
    logic[36:0] _e_3853;
    logic _e_9133;
    (* src = "src/tta.spade:466,33" *)
    logic[32:0] _e_3854;
    (* src = "src/tta.spade:467,17" *)
    logic[36:0] _e_3856;
    logic _e_9135;
    (* src = "src/tta.spade:468,17" *)
    logic[36:0] _e_3858;
    logic _e_9137;
    (* src = "src/tta.spade:469,17" *)
    logic[36:0] _e_3860;
    logic _e_9139;
    (* src = "src/tta.spade:470,17" *)
    logic[36:0] _e_3862;
    logic _e_9141;
    (* src = "src/tta.spade:471,17" *)
    logic[36:0] _e_3864;
    logic _e_9143;
    (* src = "src/tta.spade:472,17" *)
    logic[36:0] _e_3866;
    logic _e_9145;
    (* src = "src/tta.spade:473,17" *)
    logic[36:0] _e_3868;
    logic _e_9147;
    (* src = "src/tta.spade:474,17" *)
    logic[36:0] _e_3870;
    logic _e_9149;
    (* src = "src/tta.spade:475,17" *)
    logic[36:0] _e_3872;
    logic _e_9151;
    (* src = "src/tta.spade:476,17" *)
    logic[36:0] _e_3874;
    logic _e_9153;
    (* src = "src/tta.spade:476,35" *)
    logic[32:0] _e_3875;
    (* src = "src/tta.spade:477,17" *)
    logic[36:0] _e_3877;
    logic _e_9155;
    (* src = "src/tta.spade:477,37" *)
    logic[32:0] _e_3878;
    (* src = "src/tta.spade:478,17" *)
    logic[36:0] _e_3880;
    logic _e_9157;
    (* src = "src/tta.spade:479,17" *)
    logic[36:0] _e_3882;
    logic _e_9159;
    (* src = "src/tta.spade:480,17" *)
    logic[36:0] _e_3884;
    logic _e_9161;
    (* src = "src/tta.spade:481,17" *)
    logic[36:0] _e_3886;
    logic _e_9163;
    (* src = "src/tta.spade:482,17" *)
    logic[36:0] _e_3888;
    logic _e_9165;
    (* src = "src/tta.spade:483,17" *)
    logic[36:0] _e_3890;
    logic _e_9167;
    (* src = "src/tta.spade:484,17" *)
    logic[36:0] _e_3892;
    logic _e_9169;
    (* src = "src/tta.spade:485,17" *)
    logic[36:0] _e_3894;
    logic _e_9171;
    (* src = "src/tta.spade:486,17" *)
    logic[36:0] _e_3896;
    logic _e_9173;
    (* src = "src/tta.spade:461,13" *)
    logic[32:0] _e_3830;
    (* src = "src/tta.spade:488,18" *)
    logic[32:0] _e_3899;
    (* src = "src/tta.spade:460,9" *)
    logic[32:0] \bus0_val_opt ;
    (* src = "src/tta.spade:491,12" *)
    logic[48:0] _e_3903;
    (* src = "src/tta.spade:491,12" *)
    logic _e_3902;
    (* src = "src/tta.spade:492,19" *)
    logic[48:0] _e_3908;
    (* src = "src/tta.spade:492,19" *)
    logic[36:0] _e_3907;
    (* src = "src/tta.spade:493,17" *)
    logic[36:0] _e_3911;
    (* src = "src/tta.spade:493,17" *)
    logic[3:0] __n5;
    logic _e_9175;
    logic _e_9177;
    (* src = "src/tta.spade:493,48" *)
    logic[31:0] _e_3913;
    (* src = "src/tta.spade:493,43" *)
    logic[32:0] _e_3912;
    (* src = "src/tta.spade:494,17" *)
    logic[36:0] _e_3915;
    logic _e_9179;
    logic[31:0] _e_3917;
    (* src = "src/tta.spade:494,33" *)
    logic[32:0] _e_3916;
    (* src = "src/tta.spade:495,17" *)
    logic[36:0] _e_3919;
    logic _e_9181;
    (* src = "src/tta.spade:495,44" *)
    logic[10:0] _e_3922;
    logic[31:0] _e_3921;
    (* src = "src/tta.spade:495,34" *)
    logic[32:0] _e_3920;
    (* src = "src/tta.spade:496,17" *)
    logic[36:0] _e_3926;
    (* src = "src/tta.spade:496,17" *)
    logic[31:0] v_n1;
    logic _e_9183;
    logic _e_9185;
    (* src = "src/tta.spade:496,39" *)
    logic[32:0] _e_3927;
    (* src = "src/tta.spade:497,17" *)
    logic[36:0] _e_3929;
    logic _e_9187;
    (* src = "src/tta.spade:497,33" *)
    logic[32:0] _e_3930;
    (* src = "src/tta.spade:498,17" *)
    logic[36:0] _e_3932;
    logic _e_9189;
    (* src = "src/tta.spade:499,17" *)
    logic[36:0] _e_3934;
    logic _e_9191;
    (* src = "src/tta.spade:500,17" *)
    logic[36:0] _e_3936;
    logic _e_9193;
    (* src = "src/tta.spade:501,17" *)
    logic[36:0] _e_3938;
    logic _e_9195;
    (* src = "src/tta.spade:502,17" *)
    logic[36:0] _e_3940;
    logic _e_9197;
    (* src = "src/tta.spade:503,17" *)
    logic[36:0] _e_3942;
    logic _e_9199;
    (* src = "src/tta.spade:504,17" *)
    logic[36:0] _e_3944;
    logic _e_9201;
    (* src = "src/tta.spade:505,17" *)
    logic[36:0] _e_3946;
    logic _e_9203;
    (* src = "src/tta.spade:506,17" *)
    logic[36:0] _e_3948;
    logic _e_9205;
    (* src = "src/tta.spade:507,17" *)
    logic[36:0] _e_3950;
    logic _e_9207;
    (* src = "src/tta.spade:507,35" *)
    logic[32:0] _e_3951;
    (* src = "src/tta.spade:508,17" *)
    logic[36:0] _e_3953;
    logic _e_9209;
    (* src = "src/tta.spade:508,37" *)
    logic[32:0] _e_3954;
    (* src = "src/tta.spade:509,17" *)
    logic[36:0] _e_3956;
    logic _e_9211;
    (* src = "src/tta.spade:510,17" *)
    logic[36:0] _e_3958;
    logic _e_9213;
    (* src = "src/tta.spade:511,17" *)
    logic[36:0] _e_3960;
    logic _e_9215;
    (* src = "src/tta.spade:512,17" *)
    logic[36:0] _e_3962;
    logic _e_9217;
    (* src = "src/tta.spade:513,17" *)
    logic[36:0] _e_3964;
    logic _e_9219;
    (* src = "src/tta.spade:514,17" *)
    logic[36:0] _e_3966;
    logic _e_9221;
    (* src = "src/tta.spade:515,17" *)
    logic[36:0] _e_3968;
    logic _e_9223;
    (* src = "src/tta.spade:516,17" *)
    logic[36:0] _e_3970;
    logic _e_9225;
    (* src = "src/tta.spade:517,17" *)
    logic[36:0] _e_3972;
    logic _e_9227;
    (* src = "src/tta.spade:492,13" *)
    logic[32:0] _e_3906;
    (* src = "src/tta.spade:519,18" *)
    logic[32:0] _e_3975;
    (* src = "src/tta.spade:491,9" *)
    logic[32:0] \bus1_val_opt ;
    (* src = "src/tta.spade:522,26" *)
    logic[48:0] _e_3979;
    (* src = "src/tta.spade:522,26" *)
    logic[10:0] _e_3978;
    (* src = "src/tta.spade:522,14" *)
    logic[43:0] \m0 ;
    (* src = "src/tta.spade:523,26" *)
    logic[48:0] _e_3985;
    (* src = "src/tta.spade:523,26" *)
    logic[10:0] _e_3984;
    (* src = "src/tta.spade:523,14" *)
    logic[43:0] \m1 ;
    (* src = "src/tta.spade:527,17" *)
    logic[36:0] \rf_w0 ;
    (* src = "src/tta.spade:528,17" *)
    logic[36:0] \rf_w1 ;
    (* src = "src/tta.spade:530,20" *)
    logic[32:0] \alu_op_a ;
    (* src = "src/tta.spade:531,20" *)
    logic[37:0] \alu_trig ;
    (* src = "src/tta.spade:533,20" *)
    logic[32:0] \bit_op_a ;
    (* src = "src/tta.spade:534,20" *)
    logic[35:0] \bit_trig ;
    (* src = "src/tta.spade:536,21" *)
    logic[32:0] \lalu_op_a ;
    (* src = "src/tta.spade:537,21" *)
    logic[33:0] \lalu_trig ;
    (* src = "src/tta.spade:539,24" *)
    logic[32:0] \mul_set_addr ;
    (* src = "src/tta.spade:540,20" *)
    logic[32:0] \mul_trig ;
    (* src = "src/tta.spade:542,24" *)
    logic[32:0] \div_set_addr ;
    (* src = "src/tta.spade:543,20" *)
    logic[32:0] \div_trig ;
    (* src = "src/tta.spade:545,20" *)
    logic[32:0] \cmp_op_a ;
    (* src = "src/tta.spade:546,20" *)
    logic[35:0] \cmp_trig ;
    (* src = "src/tta.spade:548,21" *)
    logic[35:0] \cmpz_trig ;
    (* src = "src/tta.spade:550,25" *)
    logic[10:0] \pc_jump_final ;
    (* src = "src/tta.spade:552,21" *)
    logic[10:0] \bt_target ;
    (* src = "src/tta.spade:553,19" *)
    logic[32:0] \bt_trig ;
    (* src = "src/tta.spade:555,24" *)
    logic[32:0] \lsu_set_addr ;
    (* src = "src/tta.spade:556,25" *)
    logic[32:0] \lsu_load_trig ;
    (* src = "src/tta.spade:557,26" *)
    logic[32:0] \lsu_store_trig ;
    (* src = "src/tta.spade:559,25" *)
    logic[32:0] \lsu2_set_addr ;
    (* src = "src/tta.spade:560,26" *)
    logic[32:0] \lsu2_load_trig ;
    (* src = "src/tta.spade:561,27" *)
    logic[32:0] \lsu2_store_trig ;
    (* src = "src/tta.spade:563,25" *)
    logic[32:0] \xorshift_trig ;
    (* src = "src/tta.spade:565,24" *)
    logic[32:0] \mac_set_addr ;
    (* src = "src/tta.spade:566,20" *)
    logic[32:0] \mac_trig ;
    (* src = "src/tta.spade:567,21" *)
    logic \mac_clear ;
    (* src = "src/tta.spade:569,20" *)
    logic[1:0] \sel_cond ;
    (* src = "src/tta.spade:570,20" *)
    logic[32:0] \sel_seta ;
    (* src = "src/tta.spade:571,21" *)
    logic[32:0] \sel_trigb ;
    (* src = "src/tta.spade:573,20" *)
    logic[32:0] \mda_base ;
    (* src = "src/tta.spade:574,20" *)
    logic[32:0] \mda_mask ;
    (* src = "src/tta.spade:575,19" *)
    logic[32:0] \mda_ptr ;
    (* src = "src/tta.spade:576,20" *)
    logic[32:0] \mda_trig ;
    (* src = "src/tta.spade:578,21" *)
    logic[32:0] \tanh_trig ;
    (* src = "src/tta.spade:580,25" *)
    logic[32:0] \stack_setaddr ;
    (* src = "src/tta.spade:581,22" *)
    logic[32:0] \stack_push ;
    (* src = "src/tta.spade:582,21" *)
    logic \stack_pop ;
    (* src = "src/tta.spade:584,20" *)
    logic[16:0] \gpo_trig ;
    (* src = "src/tta.spade:586,25" *)
    logic[8:0] \spi_out8_trig ;
    (* src = "src/tta.spade:587,26" *)
    logic \spi_inpop_trig ;
    (* src = "src/tta.spade:589,26" *)
    logic[8:0] \uart_out8_trig ;
    (* src = "src/tta.spade:590,27" *)
    logic \uart_inpop_trig ;
    (* src = "src/tta.spade:592,9" *)
    logic[10:0] \pc_jump_comb ;
    (* src = "src/tta.spade:593,24" *)
    logic[31:0] \rd0 ;
    (* src = "src/tta.spade:594,24" *)
    logic[31:0] \rd1 ;
    (* src = "src/tta.spade:597,14" *)
    logic[31:0] \r0 ;
    (* src = "src/tta.spade:598,14" *)
    logic[31:0] \r1 ;
    (* src = "src/tta.spade:599,14" *)
    logic[31:0] \r2 ;
    (* src = "src/tta.spade:600,14" *)
    logic[31:0] \r3 ;
    (* src = "src/tta.spade:601,14" *)
    logic[31:0] \r4 ;
    (* src = "src/tta.spade:602,14" *)
    logic[31:0] \r5 ;
    (* src = "src/tta.spade:603,14" *)
    logic[31:0] \r6 ;
    (* src = "src/tta.spade:604,14" *)
    logic[31:0] \r7 ;
    (* src = "src/tta.spade:605,14" *)
    logic[31:0] \r8 ;
    (* src = "src/tta.spade:606,14" *)
    logic[31:0] \r9 ;
    (* src = "src/tta.spade:607,15" *)
    logic[31:0] \r10 ;
    (* src = "src/tta.spade:608,15" *)
    logic[31:0] \r11 ;
    (* src = "src/tta.spade:609,15" *)
    logic[31:0] \r12 ;
    (* src = "src/tta.spade:610,15" *)
    logic[31:0] \r13 ;
    (* src = "src/tta.spade:611,15" *)
    logic[31:0] \r14 ;
    (* src = "src/tta.spade:612,15" *)
    logic[31:0] \r15 ;
    (* src = "src/tta.spade:655,9" *)
    logic[98:0] _e_4233;
    (* src = "src/tta.spade:641,5" *)
    logic[509:0] _e_4219;
    
    assign _e_9108 = _e_9109_mut;
    assign _e_3642 = {_e_9108};
    assign {_e_9109_mut} = _e_3642_mut;
    assign \bt_target_r  = _e_3642[10:0];
    assign _e_3642_mut[10:0] = \bt_target_w_mut ;
    (* src = "src/tta.spade:338,19" *)
    \tta::pc::pc_fu  pc_fu_0(.clk_i(\clk ), .rst_i(\rst ), .jump_to_i(\pc_jump_final ), .bt_i(\bt_target_r ), .output__(\pc_val ));
    assign \pc_w_mut  = \pc_val ;
    (* src = "src/tta.spade:343,19" *)
    \tta::bt::bt_fu  bt_fu_0(.clk_i(\clk ), .rst_i(\rst ), .jump_to_i(\bt_target ), .condition_trig_i(\bt_trig ), .output__(\bt_val ));
    assign \bt_target_w_mut  = \bt_val ;
    (* src = "src/tta.spade:349,19" *)
    \tta::alu::alu_fu  alu_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\alu_op_a ), .trig_i(\alu_trig ), .output__(\alu_res ));
    (* src = "src/tta.spade:354,19" *)
    \tta::bit::bit_fu  bit_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\bit_op_a ), .trig_i(\bit_trig ), .output__(\bit_res ));
    (* src = "src/tta.spade:359,20" *)
    \tta::lalu::lalu_fu  lalu_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\lalu_op_a ), .trig_i(\lalu_trig ), .output__(\lalu_res ));
    (* src = "src/tta.spade:364,19" *)
    \tta::mul_shiftadd::mul_shiftadd_fu  mul_shiftadd_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\mul_set_addr ), .trig_i(\mul_trig ), .output__(\mul_res ));
    (* src = "src/tta.spade:369,19" *)
    \tta::div_shiftsub::div_shiftsub_fu  div_shiftsub_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\div_set_addr ), .trig_i(\div_trig ), .output__(\div_res ));
    (* src = "src/tta.spade:374,19" *)
    \tta::cmp::cmp_fu  cmp_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\cmp_op_a ), .trig_i(\cmp_trig ), .output__(\cmp_res ));
    (* src = "src/tta.spade:378,20" *)
    \tta::cmpz::cmpz_fu  cmpz_fu_0(.clk_i(\clk ), .rst_i(\rst ), .trig_i(\cmpz_trig ), .output__(\cmpz_res ));
    (* src = "src/tta.spade:384,19" *)
    \tta::lsu::lsu_fu  lsu_fu_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .set_addr_a_i(\lsu_set_addr ), .load_trig_i(\lsu_load_trig ), .store_trig_i(\lsu_store_trig ), .output__(\lsu_res ));
    (* src = "src/tta.spade:390,20" *)
    \tta::lsu::lsu_fu  lsu_fu_1(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .set_addr_a_i(\lsu2_set_addr ), .load_trig_i(\lsu2_load_trig ), .store_trig_i(\lsu2_store_trig ), .output__(\lsu2_res ));
    (* src = "src/tta.spade:394,20" *)
    \tta::tanh::tanh_pwl_fu  tanh_pwl_fu_0(.clk_i(\clk ), .rst_i(\rst ), .trig_i(\tanh_trig ), .output__(\tanh_res ));
    (* src = "src/tta.spade:397,36" *)
    \tta::cc::cc_fu  cc_fu_0(.clk_i(\clk ), .rst_i(\rst ), .output__(_e_3726));
    assign \cc_res_lo  = _e_3726[63:32];
    assign \cc_res_high  = _e_3726[31:0];
    (* src = "src/tta.spade:401,24" *)
    \tta::xorshift::xorshift_fu  xorshift_fu_0(.clk_i(\clk ), .rst_i(\rst ), .trig_i(\xorshift_trig ), .output__(\xorshift_res ));
    (* src = "src/tta.spade:407,19" *)
    \tta::mac::mac_fu  mac_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\mac_set_addr ), .trig_i(\mac_trig ), .clr_i(\mac_clear ), .output__(\mac_res ));
    (* src = "src/tta.spade:413,19" *)
    \tta::sel::sel_fu  sel_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_cond_i(\sel_cond ), .set_a_i(\sel_seta ), .trig_b_i(\sel_trigb ), .output__(\sel_res ));
    (* src = "src/tta.spade:420,19" *)
    \tta::modadd::modadd_fu  modadd_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_base_i(\mda_base ), .set_mask_i(\mda_mask ), .set_ptr_i(\mda_ptr ), .trig_stride_i(\mda_trig ), .output__(\mda_res ));
    (* src = "src/tta.spade:426,21" *)
    \tta::stack_lsu::stack_lsu_fu  stack_lsu_fu_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .set_sp_i(\stack_setaddr ), .pop_trig_i(\stack_pop ), .push_trig_i(\stack_push ), .output__(\stack_res ));
    (* src = "src/tta.spade:430,19" *)
    \tta::gpo::gpo16  gpo16_0(.clk_i(\clk ), .rst_i(\rst ), .wr_i(\gpo_trig ), .output__(\gpo_res ));
    (* src = "src/tta.spade:433,19" *)
    \tta::gpi::gpi16  gpi16_0(.clk_i(\clk ), .rst_i(\rst ), .pins_i(\gpi16 ), .output__(\gpi_res ));
    (* src = "src/tta.spade:437,23" *)
    \tta::uart_in::uart_in  uart_in_0(.clk_i(\clk ), .rst_i(\rst ), .uart_byte_i(\uart_rx ), .pop_i(\uart_inpop_trig ), .output__(\uart_in_res ));
    (* src = "src/tta.spade:439,13" *)
    \tta::uart_in::uart_out  uart_out_0(.clk_i(\clk ), .rst_i(\rst ), .byte_to_write_i(\uart_out8_trig ), .tx_o(\uart_tx_mut ), .uart_tx_busy_i(\uart_tx_busy ));
    (* src = "src/tta.spade:443,22" *)
    \tta::spi::spi_in  spi_in_0(.clk_i(\clk ), .rst_i(\rst ), .miso_byte_i(\spi_miso ), .pop_i(\spi_inpop_trig ), .output__(\spi_in_res ));
    (* src = "src/tta.spade:445,13" *)
    \tta::spi::spi_out8  spi_out8_0(.clk_i(\clk ), .rst_i(\rst ), .byte_to_write_i(\spi_out8_trig ), .mosi_o(\spi_mosi_mut ), .spi_busy_i(\spi_busy ));
    assign _e_3799 = \insn [97:49];
    assign _e_3798 = _e_3799[48:12];
    assign _e_3802 = _e_3798;
    assign \i  = _e_3798[31:28];
    assign _e_9111 = _e_3798[36:32] == 5'd0;
    localparam[0:0] _e_9112 = 1;
    assign _e_9113 = _e_9111 && _e_9112;
    assign __n2 = _e_3798;
    localparam[0:0] _e_9114 = 1;
    localparam[3:0] _e_3805 = 0;
    always_comb begin
        priority casez ({_e_9113, _e_9114})
            2'b1?: \ra0  = \i ;
            2'b01: \ra0  = _e_3805;
            2'b?: \ra0  = 4'dx;
        endcase
    end
    assign _e_3809 = \insn [48:0];
    assign _e_3808 = _e_3809[48:12];
    assign _e_3812 = _e_3808;
    assign i_n1 = _e_3808[31:28];
    assign _e_9116 = _e_3808[36:32] == 5'd0;
    localparam[0:0] _e_9117 = 1;
    assign _e_9118 = _e_9116 && _e_9117;
    assign __n3 = _e_3808;
    localparam[0:0] _e_9119 = 1;
    localparam[3:0] _e_3815 = 0;
    always_comb begin
        priority casez ({_e_9118, _e_9119})
            2'b1?: \ra1  = i_n1;
            2'b01: \ra1  = _e_3815;
            2'b?: \ra1  = 4'dx;
        endcase
    end
    (* src = "src/tta.spade:455,20" *)
    \tta::regfile::regfile8_fu  regfile8_fu_0(.clk_i(\clk ), .rst_i(\rst ), .wr0_i(\rf_w0 ), .wr1_i(\rf_w1 ), .ra0_i(\ra0 ), .ra1_i(\ra1 ), .output__(\registry ));
    assign _e_3827 = \insn [97:49];
    assign _e_3826 = _e_3827[0];
    assign _e_3832 = \insn [97:49];
    assign _e_3831 = _e_3832[48:12];
    assign _e_3835 = _e_3831;
    assign __n4 = _e_3831[31:28];
    assign _e_9121 = _e_3831[36:32] == 5'd0;
    localparam[0:0] _e_9122 = 1;
    assign _e_9123 = _e_9121 && _e_9122;
    assign _e_3837 = \registry [575:544];
    assign _e_3836 = {1'd1, _e_3837};
    assign _e_3839 = _e_3831;
    assign _e_9125 = _e_3831[36:32] == 5'd3;
    assign _e_3841 = {22'b0, \pc_val };
    assign _e_3840 = {1'd1, _e_3841};
    assign _e_3843 = _e_3831;
    assign _e_9127 = _e_3831[36:32] == 5'd4;
    localparam[9:0] _e_3848 = 1;
    assign _e_3846 = \pc_val  + _e_3848;
    assign _e_3845 = {21'b0, _e_3846};
    assign _e_3844 = {1'd1, _e_3845};
    assign _e_3850 = _e_3831;
    assign \v  = _e_3831[31:0];
    assign _e_9129 = _e_3831[36:32] == 5'd5;
    localparam[0:0] _e_9130 = 1;
    assign _e_9131 = _e_9129 && _e_9130;
    assign _e_3851 = {1'd1, \v };
    assign _e_3853 = _e_3831;
    assign _e_9133 = _e_3831[36:32] == 5'd6;
    localparam[31:0] _e_3855 = 32'd0;
    assign _e_3854 = {1'd1, _e_3855};
    assign _e_3856 = _e_3831;
    assign _e_9135 = _e_3831[36:32] == 5'd1;
    assign _e_3858 = _e_3831;
    assign _e_9137 = _e_3831[36:32] == 5'd7;
    assign _e_3860 = _e_3831;
    assign _e_9139 = _e_3831[36:32] == 5'd8;
    assign _e_3862 = _e_3831;
    assign _e_9141 = _e_3831[36:32] == 5'd9;
    assign _e_3864 = _e_3831;
    assign _e_9143 = _e_3831[36:32] == 5'd10;
    assign _e_3866 = _e_3831;
    assign _e_9145 = _e_3831[36:32] == 5'd11;
    assign _e_3868 = _e_3831;
    assign _e_9147 = _e_3831[36:32] == 5'd12;
    assign _e_3870 = _e_3831;
    assign _e_9149 = _e_3831[36:32] == 5'd2;
    assign _e_3872 = _e_3831;
    assign _e_9151 = _e_3831[36:32] == 5'd13;
    assign _e_3874 = _e_3831;
    assign _e_9153 = _e_3831[36:32] == 5'd14;
    assign _e_3875 = {1'd1, \cc_res_lo };
    assign _e_3877 = _e_3831;
    assign _e_9155 = _e_3831[36:32] == 5'd15;
    assign _e_3878 = {1'd1, \cc_res_high };
    assign _e_3880 = _e_3831;
    assign _e_9157 = _e_3831[36:32] == 5'd16;
    assign _e_3882 = _e_3831;
    assign _e_9159 = _e_3831[36:32] == 5'd17;
    assign _e_3884 = _e_3831;
    assign _e_9161 = _e_3831[36:32] == 5'd18;
    assign _e_3886 = _e_3831;
    assign _e_9163 = _e_3831[36:32] == 5'd19;
    assign _e_3888 = _e_3831;
    assign _e_9165 = _e_3831[36:32] == 5'd20;
    assign _e_3890 = _e_3831;
    assign _e_9167 = _e_3831[36:32] == 5'd21;
    assign _e_3892 = _e_3831;
    assign _e_9169 = _e_3831[36:32] == 5'd22;
    assign _e_3894 = _e_3831;
    assign _e_9171 = _e_3831[36:32] == 5'd23;
    assign _e_3896 = _e_3831;
    assign _e_9173 = _e_3831[36:32] == 5'd24;
    always_comb begin
        priority casez ({_e_9123, _e_9125, _e_9127, _e_9131, _e_9133, _e_9135, _e_9137, _e_9139, _e_9141, _e_9143, _e_9145, _e_9147, _e_9149, _e_9151, _e_9153, _e_9155, _e_9157, _e_9159, _e_9161, _e_9163, _e_9165, _e_9167, _e_9169, _e_9171, _e_9173})
            25'b1????????????????????????: _e_3830 = _e_3836;
            25'b01???????????????????????: _e_3830 = _e_3840;
            25'b001??????????????????????: _e_3830 = _e_3844;
            25'b0001?????????????????????: _e_3830 = _e_3851;
            25'b00001????????????????????: _e_3830 = _e_3854;
            25'b000001???????????????????: _e_3830 = \alu_res ;
            25'b0000001??????????????????: _e_3830 = \lsu_res ;
            25'b00000001?????????????????: _e_3830 = \lsu2_res ;
            25'b000000001????????????????: _e_3830 = \gpi_res ;
            25'b0000000001???????????????: _e_3830 = \uart_in_res ;
            25'b00000000001??????????????: _e_3830 = \cmp_res ;
            25'b000000000001?????????????: _e_3830 = \cmpz_res ;
            25'b0000000000001????????????: _e_3830 = \lalu_res ;
            25'b00000000000001???????????: _e_3830 = \mul_res ;
            25'b000000000000001??????????: _e_3830 = _e_3875;
            25'b0000000000000001?????????: _e_3830 = _e_3878;
            25'b00000000000000001????????: _e_3830 = \spi_in_res ;
            25'b000000000000000001???????: _e_3830 = \div_res ;
            25'b0000000000000000001??????: _e_3830 = \xorshift_res ;
            25'b00000000000000000001?????: _e_3830 = \mac_res ;
            25'b000000000000000000001????: _e_3830 = \sel_res ;
            25'b0000000000000000000001???: _e_3830 = \mda_res ;
            25'b00000000000000000000001??: _e_3830 = \tanh_res ;
            25'b000000000000000000000001?: _e_3830 = \stack_res ;
            25'b0000000000000000000000001: _e_3830 = \bit_res ;
            25'b?: _e_3830 = 33'dx;
        endcase
    end
    assign _e_3899 = {1'd0, 32'bX};
    assign \bus0_val_opt  = _e_3826 ? _e_3830 : _e_3899;
    assign _e_3903 = \insn [48:0];
    assign _e_3902 = _e_3903[0];
    assign _e_3908 = \insn [48:0];
    assign _e_3907 = _e_3908[48:12];
    assign _e_3911 = _e_3907;
    assign __n5 = _e_3907[31:28];
    assign _e_9175 = _e_3907[36:32] == 5'd0;
    localparam[0:0] _e_9176 = 1;
    assign _e_9177 = _e_9175 && _e_9176;
    assign _e_3913 = \registry [543:512];
    assign _e_3912 = {1'd1, _e_3913};
    assign _e_3915 = _e_3907;
    assign _e_9179 = _e_3907[36:32] == 5'd3;
    assign _e_3917 = {22'b0, \pc_val };
    assign _e_3916 = {1'd1, _e_3917};
    assign _e_3919 = _e_3907;
    assign _e_9181 = _e_3907[36:32] == 5'd4;
    localparam[9:0] _e_3924 = 1;
    assign _e_3922 = \pc_val  + _e_3924;
    assign _e_3921 = {21'b0, _e_3922};
    assign _e_3920 = {1'd1, _e_3921};
    assign _e_3926 = _e_3907;
    assign v_n1 = _e_3907[31:0];
    assign _e_9183 = _e_3907[36:32] == 5'd5;
    localparam[0:0] _e_9184 = 1;
    assign _e_9185 = _e_9183 && _e_9184;
    assign _e_3927 = {1'd1, v_n1};
    assign _e_3929 = _e_3907;
    assign _e_9187 = _e_3907[36:32] == 5'd6;
    localparam[31:0] _e_3931 = 32'd0;
    assign _e_3930 = {1'd1, _e_3931};
    assign _e_3932 = _e_3907;
    assign _e_9189 = _e_3907[36:32] == 5'd1;
    assign _e_3934 = _e_3907;
    assign _e_9191 = _e_3907[36:32] == 5'd7;
    assign _e_3936 = _e_3907;
    assign _e_9193 = _e_3907[36:32] == 5'd8;
    assign _e_3938 = _e_3907;
    assign _e_9195 = _e_3907[36:32] == 5'd9;
    assign _e_3940 = _e_3907;
    assign _e_9197 = _e_3907[36:32] == 5'd10;
    assign _e_3942 = _e_3907;
    assign _e_9199 = _e_3907[36:32] == 5'd11;
    assign _e_3944 = _e_3907;
    assign _e_9201 = _e_3907[36:32] == 5'd12;
    assign _e_3946 = _e_3907;
    assign _e_9203 = _e_3907[36:32] == 5'd2;
    assign _e_3948 = _e_3907;
    assign _e_9205 = _e_3907[36:32] == 5'd13;
    assign _e_3950 = _e_3907;
    assign _e_9207 = _e_3907[36:32] == 5'd14;
    assign _e_3951 = {1'd1, \cc_res_lo };
    assign _e_3953 = _e_3907;
    assign _e_9209 = _e_3907[36:32] == 5'd15;
    assign _e_3954 = {1'd1, \cc_res_high };
    assign _e_3956 = _e_3907;
    assign _e_9211 = _e_3907[36:32] == 5'd16;
    assign _e_3958 = _e_3907;
    assign _e_9213 = _e_3907[36:32] == 5'd17;
    assign _e_3960 = _e_3907;
    assign _e_9215 = _e_3907[36:32] == 5'd18;
    assign _e_3962 = _e_3907;
    assign _e_9217 = _e_3907[36:32] == 5'd19;
    assign _e_3964 = _e_3907;
    assign _e_9219 = _e_3907[36:32] == 5'd20;
    assign _e_3966 = _e_3907;
    assign _e_9221 = _e_3907[36:32] == 5'd21;
    assign _e_3968 = _e_3907;
    assign _e_9223 = _e_3907[36:32] == 5'd22;
    assign _e_3970 = _e_3907;
    assign _e_9225 = _e_3907[36:32] == 5'd23;
    assign _e_3972 = _e_3907;
    assign _e_9227 = _e_3907[36:32] == 5'd24;
    always_comb begin
        priority casez ({_e_9177, _e_9179, _e_9181, _e_9185, _e_9187, _e_9189, _e_9191, _e_9193, _e_9195, _e_9197, _e_9199, _e_9201, _e_9203, _e_9205, _e_9207, _e_9209, _e_9211, _e_9213, _e_9215, _e_9217, _e_9219, _e_9221, _e_9223, _e_9225, _e_9227})
            25'b1????????????????????????: _e_3906 = _e_3912;
            25'b01???????????????????????: _e_3906 = _e_3916;
            25'b001??????????????????????: _e_3906 = _e_3920;
            25'b0001?????????????????????: _e_3906 = _e_3927;
            25'b00001????????????????????: _e_3906 = _e_3930;
            25'b000001???????????????????: _e_3906 = \alu_res ;
            25'b0000001??????????????????: _e_3906 = \lsu_res ;
            25'b00000001?????????????????: _e_3906 = \lsu2_res ;
            25'b000000001????????????????: _e_3906 = \gpi_res ;
            25'b0000000001???????????????: _e_3906 = \uart_in_res ;
            25'b00000000001??????????????: _e_3906 = \cmp_res ;
            25'b000000000001?????????????: _e_3906 = \cmpz_res ;
            25'b0000000000001????????????: _e_3906 = \lalu_res ;
            25'b00000000000001???????????: _e_3906 = \mul_res ;
            25'b000000000000001??????????: _e_3906 = _e_3951;
            25'b0000000000000001?????????: _e_3906 = _e_3954;
            25'b00000000000000001????????: _e_3906 = \spi_in_res ;
            25'b000000000000000001???????: _e_3906 = \div_res ;
            25'b0000000000000000001??????: _e_3906 = \xorshift_res ;
            25'b00000000000000000001?????: _e_3906 = \mac_res ;
            25'b000000000000000000001????: _e_3906 = \sel_res ;
            25'b0000000000000000000001???: _e_3906 = \mda_res ;
            25'b00000000000000000000001??: _e_3906 = \tanh_res ;
            25'b000000000000000000000001?: _e_3906 = \stack_res ;
            25'b0000000000000000000000001: _e_3906 = \bit_res ;
            25'b?: _e_3906 = 33'dx;
        endcase
    end
    assign _e_3975 = {1'd0, 32'bX};
    assign \bus1_val_opt  = _e_3902 ? _e_3906 : _e_3975;
    assign _e_3979 = \insn [97:49];
    assign _e_3978 = _e_3979[11:1];
    (* src = "src/tta.spade:522,14" *)
    \tta::tta::decode_move  decode_move_0(.dst_i(_e_3978), .v_i(\bus0_val_opt ), .output__(\m0 ));
    assign _e_3985 = \insn [48:0];
    assign _e_3984 = _e_3985[11:1];
    (* src = "src/tta.spade:523,14" *)
    \tta::tta::decode_move  decode_move_1(.dst_i(_e_3984), .v_i(\bus1_val_opt ), .output__(\m1 ));
    (* src = "src/tta.spade:527,17" *)
    \tta::regfile::route_rf_one  route_rf_one_0(.m_i(\m0 ), .output__(\rf_w0 ));
    (* src = "src/tta.spade:528,17" *)
    \tta::regfile::route_rf_one  route_rf_one_1(.m_i(\m1 ), .output__(\rf_w1 ));
    (* src = "src/tta.spade:530,20" *)
    \tta::alu::pick_alu_seta  pick_alu_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\alu_op_a ));
    (* src = "src/tta.spade:531,20" *)
    \tta::alu::pick_alu_trig  pick_alu_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\alu_trig ));
    (* src = "src/tta.spade:533,20" *)
    \tta::bit::pick_bit_seta  pick_bit_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\bit_op_a ));
    (* src = "src/tta.spade:534,20" *)
    \tta::bit::pick_bit_trig  pick_bit_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\bit_trig ));
    (* src = "src/tta.spade:536,21" *)
    \tta::lalu::pick_lalu_seta  pick_lalu_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lalu_op_a ));
    (* src = "src/tta.spade:537,21" *)
    \tta::lalu::pick_lalu_trig  pick_lalu_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lalu_trig ));
    (* src = "src/tta.spade:539,24" *)
    \tta::mul_shiftadd::pick_mul_seta  pick_mul_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mul_set_addr ));
    (* src = "src/tta.spade:540,20" *)
    \tta::mul_shiftadd::pick_mul_trig  pick_mul_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mul_trig ));
    (* src = "src/tta.spade:542,24" *)
    \tta::div_shiftsub::pick_div_seta  pick_div_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\div_set_addr ));
    (* src = "src/tta.spade:543,20" *)
    \tta::div_shiftsub::pick_div_trig  pick_div_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\div_trig ));
    (* src = "src/tta.spade:545,20" *)
    \tta::cmp::pick_cmp_seta  pick_cmp_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\cmp_op_a ));
    (* src = "src/tta.spade:546,20" *)
    \tta::cmp::pick_cmp_trig  pick_cmp_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\cmp_trig ));
    (* src = "src/tta.spade:548,21" *)
    \tta::cmpz::pick_cmpz_trig  pick_cmpz_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\cmpz_trig ));
    (* src = "src/tta.spade:550,25" *)
    \tta::pc::pick_pc_jump  pick_pc_jump_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\pc_jump_final ));
    (* src = "src/tta.spade:552,21" *)
    \tta::bt::pick_bt_target  pick_bt_target_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\bt_target ));
    (* src = "src/tta.spade:553,19" *)
    \tta::bt::pick_bt_trig  pick_bt_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\bt_trig ));
    (* src = "src/tta.spade:555,24" *)
    \tta::lsu::pick_lsu_seta  pick_lsu_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu_set_addr ));
    (* src = "src/tta.spade:556,25" *)
    \tta::lsu::pick_lsu_loadtrig  pick_lsu_loadtrig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu_load_trig ));
    (* src = "src/tta.spade:557,26" *)
    \tta::lsu::pick_lsu_storetrig  pick_lsu_storetrig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu_store_trig ));
    (* src = "src/tta.spade:559,25" *)
    \tta::lsu::pick_lsu2_seta  pick_lsu2_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu2_set_addr ));
    (* src = "src/tta.spade:560,26" *)
    \tta::lsu::pick_lsu2_loadtrig  pick_lsu2_loadtrig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu2_load_trig ));
    (* src = "src/tta.spade:561,27" *)
    \tta::lsu::pick_lsu2_storetrig  pick_lsu2_storetrig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu2_store_trig ));
    (* src = "src/tta.spade:563,25" *)
    \tta::xorshift::pick_xorshift_trig  pick_xorshift_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\xorshift_trig ));
    (* src = "src/tta.spade:565,24" *)
    \tta::mac::pick_mac_seta  pick_mac_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mac_set_addr ));
    (* src = "src/tta.spade:566,20" *)
    \tta::mac::pick_mac_trig  pick_mac_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mac_trig ));
    (* src = "src/tta.spade:567,21" *)
    \tta::mac::pick_mac_clear  pick_mac_clear_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mac_clear ));
    (* src = "src/tta.spade:569,20" *)
    \tta::sel::pick_sel_cond  pick_sel_cond_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\sel_cond ));
    (* src = "src/tta.spade:570,20" *)
    \tta::sel::pick_sel_seta  pick_sel_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\sel_seta ));
    (* src = "src/tta.spade:571,21" *)
    \tta::sel::pick_sel_trigb  pick_sel_trigb_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\sel_trigb ));
    (* src = "src/tta.spade:573,20" *)
    \tta::modadd::pick_base  pick_base_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mda_base ));
    (* src = "src/tta.spade:574,20" *)
    \tta::modadd::pick_mask  pick_mask_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mda_mask ));
    (* src = "src/tta.spade:575,19" *)
    \tta::modadd::pick_ptr  pick_ptr_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mda_ptr ));
    (* src = "src/tta.spade:576,20" *)
    \tta::modadd::pick_trig  pick_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mda_trig ));
    (* src = "src/tta.spade:578,21" *)
    \tta::tanh::pick_trig  pick_trig_1(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\tanh_trig ));
    (* src = "src/tta.spade:580,25" *)
    \tta::stack_lsu::pick_seta  pick_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\stack_setaddr ));
    (* src = "src/tta.spade:581,22" *)
    \tta::stack_lsu::pick_push_trig  pick_push_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\stack_push ));
    (* src = "src/tta.spade:582,21" *)
    \tta::stack_lsu::pick_pop_trig  pick_pop_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\stack_pop ));
    (* src = "src/tta.spade:584,20" *)
    \tta::gpo::pick_gpo16  pick_gpo16_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\gpo_trig ));
    (* src = "src/tta.spade:586,25" *)
    \tta::spi::pick_spi_out8  pick_spi_out8_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\spi_out8_trig ));
    (* src = "src/tta.spade:587,26" *)
    \tta::spi::pick_spi_inpop  pick_spi_inpop_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\spi_inpop_trig ));
    (* src = "src/tta.spade:589,26" *)
    \tta::uart_in::pick_uart_out8  pick_uart_out8_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\uart_out8_trig ));
    (* src = "src/tta.spade:590,27" *)
    \tta::uart_in::pick_uart_inpop  pick_uart_inpop_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\uart_inpop_trig ));
    assign \pc_jump_comb  = \pc_jump_final ;
    assign \rd0  = \registry [575:544];
    assign \rd1  = \registry [543:512];
    assign \r0  = \registry [511:480];
    assign \r1  = \registry [479:448];
    assign \r2  = \registry [447:416];
    assign \r3  = \registry [415:384];
    assign \r4  = \registry [383:352];
    assign \r5  = \registry [351:320];
    assign \r6  = \registry [319:288];
    assign \r7  = \registry [287:256];
    assign \r8  = \registry [255:224];
    assign \r9  = \registry [223:192];
    assign \r10  = \registry [191:160];
    assign \r11  = \registry [159:128];
    assign \r12  = \registry [127:96];
    assign \r13  = \registry [95:64];
    assign \r14  = \registry [63:32];
    assign \r15  = \registry [31:0];
    assign _e_4233 = {1'd1, \insn };
    assign _e_4219 = {\pc_val , \alu_op_a , \alu_trig , \alu_res , \pc_jump_final , \rf_w0 , \rf_w1 , \rd0 , \rd1 , \lsu_res , \lsu_set_addr , \lsu_store_trig , \lsu_load_trig , _e_4233, \gpo_res };
    assign output__ = _e_4219;
endmodule

module \tta::fifo::reset_fifo  (
        output[73:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::fifo::reset_fifo" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::fifo::reset_fifo );
        end
    end
    `endif
    (* src = "src/fifo.spade:14,15" *)
    logic[63:0] _e_4238;
    (* src = "src/fifo.spade:14,5" *)
    logic[73:0] _e_4237;
    localparam[7:0] _e_4239 = 0;
    localparam[7:0] _e_4240 = 0;
    localparam[7:0] _e_4241 = 0;
    localparam[7:0] _e_4242 = 0;
    localparam[7:0] _e_4243 = 0;
    localparam[7:0] _e_4244 = 0;
    localparam[7:0] _e_4245 = 0;
    localparam[7:0] _e_4246 = 0;
    assign _e_4238 = {_e_4246, _e_4245, _e_4244, _e_4243, _e_4242, _e_4241, _e_4240, _e_4239};
    localparam[2:0] _e_4247 = 0;
    localparam[2:0] _e_4248 = 0;
    localparam[3:0] _e_4249 = 0;
    assign _e_4237 = {_e_4238, _e_4247, _e_4248, _e_4249};
    assign output__ = _e_4237;
endmodule

module \tta::fifo::set_mem  (
        input[63:0] arr_i,
        input[2:0] idx_i,
        input[7:0] val_i,
        output[63:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::fifo::set_mem" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::fifo::set_mem );
        end
    end
    `endif
    logic[63:0] \arr ;
    assign \arr  = arr_i;
    logic[2:0] \idx ;
    assign \idx  = idx_i;
    logic[7:0] \val ;
    assign \val  = val_i;
    logic _e_9228;
    (* src = "src/fifo.spade:20,20" *)
    logic[7:0] _e_4256;
    (* src = "src/fifo.spade:20,28" *)
    logic[7:0] _e_4259;
    (* src = "src/fifo.spade:20,36" *)
    logic[7:0] _e_4262;
    (* src = "src/fifo.spade:20,44" *)
    logic[7:0] _e_4265;
    (* src = "src/fifo.spade:20,52" *)
    logic[7:0] _e_4268;
    (* src = "src/fifo.spade:20,60" *)
    logic[7:0] _e_4271;
    (* src = "src/fifo.spade:20,68" *)
    logic[7:0] _e_4274;
    (* src = "src/fifo.spade:20,14" *)
    logic[63:0] _e_4254;
    logic _e_9230;
    (* src = "src/fifo.spade:21,15" *)
    logic[7:0] _e_4279;
    (* src = "src/fifo.spade:21,28" *)
    logic[7:0] _e_4283;
    (* src = "src/fifo.spade:21,36" *)
    logic[7:0] _e_4286;
    (* src = "src/fifo.spade:21,44" *)
    logic[7:0] _e_4289;
    (* src = "src/fifo.spade:21,52" *)
    logic[7:0] _e_4292;
    (* src = "src/fifo.spade:21,60" *)
    logic[7:0] _e_4295;
    (* src = "src/fifo.spade:21,68" *)
    logic[7:0] _e_4298;
    (* src = "src/fifo.spade:21,14" *)
    logic[63:0] _e_4278;
    logic _e_9232;
    (* src = "src/fifo.spade:22,15" *)
    logic[7:0] _e_4303;
    (* src = "src/fifo.spade:22,23" *)
    logic[7:0] _e_4306;
    (* src = "src/fifo.spade:22,36" *)
    logic[7:0] _e_4310;
    (* src = "src/fifo.spade:22,44" *)
    logic[7:0] _e_4313;
    (* src = "src/fifo.spade:22,52" *)
    logic[7:0] _e_4316;
    (* src = "src/fifo.spade:22,60" *)
    logic[7:0] _e_4319;
    (* src = "src/fifo.spade:22,68" *)
    logic[7:0] _e_4322;
    (* src = "src/fifo.spade:22,14" *)
    logic[63:0] _e_4302;
    logic _e_9234;
    (* src = "src/fifo.spade:23,15" *)
    logic[7:0] _e_4327;
    (* src = "src/fifo.spade:23,23" *)
    logic[7:0] _e_4330;
    (* src = "src/fifo.spade:23,31" *)
    logic[7:0] _e_4333;
    (* src = "src/fifo.spade:23,44" *)
    logic[7:0] _e_4337;
    (* src = "src/fifo.spade:23,52" *)
    logic[7:0] _e_4340;
    (* src = "src/fifo.spade:23,60" *)
    logic[7:0] _e_4343;
    (* src = "src/fifo.spade:23,68" *)
    logic[7:0] _e_4346;
    (* src = "src/fifo.spade:23,14" *)
    logic[63:0] _e_4326;
    logic _e_9236;
    (* src = "src/fifo.spade:24,15" *)
    logic[7:0] _e_4351;
    (* src = "src/fifo.spade:24,23" *)
    logic[7:0] _e_4354;
    (* src = "src/fifo.spade:24,31" *)
    logic[7:0] _e_4357;
    (* src = "src/fifo.spade:24,39" *)
    logic[7:0] _e_4360;
    (* src = "src/fifo.spade:24,52" *)
    logic[7:0] _e_4364;
    (* src = "src/fifo.spade:24,60" *)
    logic[7:0] _e_4367;
    (* src = "src/fifo.spade:24,68" *)
    logic[7:0] _e_4370;
    (* src = "src/fifo.spade:24,14" *)
    logic[63:0] _e_4350;
    logic _e_9238;
    (* src = "src/fifo.spade:25,15" *)
    logic[7:0] _e_4375;
    (* src = "src/fifo.spade:25,23" *)
    logic[7:0] _e_4378;
    (* src = "src/fifo.spade:25,31" *)
    logic[7:0] _e_4381;
    (* src = "src/fifo.spade:25,39" *)
    logic[7:0] _e_4384;
    (* src = "src/fifo.spade:25,47" *)
    logic[7:0] _e_4387;
    (* src = "src/fifo.spade:25,60" *)
    logic[7:0] _e_4391;
    (* src = "src/fifo.spade:25,68" *)
    logic[7:0] _e_4394;
    (* src = "src/fifo.spade:25,14" *)
    logic[63:0] _e_4374;
    logic _e_9240;
    (* src = "src/fifo.spade:26,15" *)
    logic[7:0] _e_4399;
    (* src = "src/fifo.spade:26,23" *)
    logic[7:0] _e_4402;
    (* src = "src/fifo.spade:26,31" *)
    logic[7:0] _e_4405;
    (* src = "src/fifo.spade:26,39" *)
    logic[7:0] _e_4408;
    (* src = "src/fifo.spade:26,47" *)
    logic[7:0] _e_4411;
    (* src = "src/fifo.spade:26,55" *)
    logic[7:0] _e_4414;
    (* src = "src/fifo.spade:26,68" *)
    logic[7:0] _e_4418;
    (* src = "src/fifo.spade:26,14" *)
    logic[63:0] _e_4398;
    logic _e_9242;
    (* src = "src/fifo.spade:27,15" *)
    logic[7:0] _e_4423;
    (* src = "src/fifo.spade:27,23" *)
    logic[7:0] _e_4426;
    (* src = "src/fifo.spade:27,31" *)
    logic[7:0] _e_4429;
    (* src = "src/fifo.spade:27,39" *)
    logic[7:0] _e_4432;
    (* src = "src/fifo.spade:27,47" *)
    logic[7:0] _e_4435;
    (* src = "src/fifo.spade:27,55" *)
    logic[7:0] _e_4438;
    (* src = "src/fifo.spade:27,63" *)
    logic[7:0] _e_4441;
    (* src = "src/fifo.spade:27,14" *)
    logic[63:0] _e_4422;
    (* src = "src/fifo.spade:19,5" *)
    logic[63:0] _e_4251;
    localparam[2:0] _e_9229 = 0;
    assign _e_9228 = \idx  == _e_9229;
    localparam[2:0] _e_4258 = 1;
    assign _e_4256 = \arr [_e_4258 * 8+:8];
    localparam[2:0] _e_4261 = 2;
    assign _e_4259 = \arr [_e_4261 * 8+:8];
    localparam[2:0] _e_4264 = 3;
    assign _e_4262 = \arr [_e_4264 * 8+:8];
    localparam[2:0] _e_4267 = 4;
    assign _e_4265 = \arr [_e_4267 * 8+:8];
    localparam[2:0] _e_4270 = 5;
    assign _e_4268 = \arr [_e_4270 * 8+:8];
    localparam[2:0] _e_4273 = 6;
    assign _e_4271 = \arr [_e_4273 * 8+:8];
    localparam[2:0] _e_4276 = 7;
    assign _e_4274 = \arr [_e_4276 * 8+:8];
    assign _e_4254 = {_e_4274, _e_4271, _e_4268, _e_4265, _e_4262, _e_4259, _e_4256, \val };
    localparam[2:0] _e_9231 = 1;
    assign _e_9230 = \idx  == _e_9231;
    localparam[2:0] _e_4281 = 0;
    assign _e_4279 = \arr [_e_4281 * 8+:8];
    localparam[2:0] _e_4285 = 2;
    assign _e_4283 = \arr [_e_4285 * 8+:8];
    localparam[2:0] _e_4288 = 3;
    assign _e_4286 = \arr [_e_4288 * 8+:8];
    localparam[2:0] _e_4291 = 4;
    assign _e_4289 = \arr [_e_4291 * 8+:8];
    localparam[2:0] _e_4294 = 5;
    assign _e_4292 = \arr [_e_4294 * 8+:8];
    localparam[2:0] _e_4297 = 6;
    assign _e_4295 = \arr [_e_4297 * 8+:8];
    localparam[2:0] _e_4300 = 7;
    assign _e_4298 = \arr [_e_4300 * 8+:8];
    assign _e_4278 = {_e_4298, _e_4295, _e_4292, _e_4289, _e_4286, _e_4283, \val , _e_4279};
    localparam[2:0] _e_9233 = 2;
    assign _e_9232 = \idx  == _e_9233;
    localparam[2:0] _e_4305 = 0;
    assign _e_4303 = \arr [_e_4305 * 8+:8];
    localparam[2:0] _e_4308 = 1;
    assign _e_4306 = \arr [_e_4308 * 8+:8];
    localparam[2:0] _e_4312 = 3;
    assign _e_4310 = \arr [_e_4312 * 8+:8];
    localparam[2:0] _e_4315 = 4;
    assign _e_4313 = \arr [_e_4315 * 8+:8];
    localparam[2:0] _e_4318 = 5;
    assign _e_4316 = \arr [_e_4318 * 8+:8];
    localparam[2:0] _e_4321 = 6;
    assign _e_4319 = \arr [_e_4321 * 8+:8];
    localparam[2:0] _e_4324 = 7;
    assign _e_4322 = \arr [_e_4324 * 8+:8];
    assign _e_4302 = {_e_4322, _e_4319, _e_4316, _e_4313, _e_4310, \val , _e_4306, _e_4303};
    localparam[2:0] _e_9235 = 3;
    assign _e_9234 = \idx  == _e_9235;
    localparam[2:0] _e_4329 = 0;
    assign _e_4327 = \arr [_e_4329 * 8+:8];
    localparam[2:0] _e_4332 = 1;
    assign _e_4330 = \arr [_e_4332 * 8+:8];
    localparam[2:0] _e_4335 = 2;
    assign _e_4333 = \arr [_e_4335 * 8+:8];
    localparam[2:0] _e_4339 = 4;
    assign _e_4337 = \arr [_e_4339 * 8+:8];
    localparam[2:0] _e_4342 = 5;
    assign _e_4340 = \arr [_e_4342 * 8+:8];
    localparam[2:0] _e_4345 = 6;
    assign _e_4343 = \arr [_e_4345 * 8+:8];
    localparam[2:0] _e_4348 = 7;
    assign _e_4346 = \arr [_e_4348 * 8+:8];
    assign _e_4326 = {_e_4346, _e_4343, _e_4340, _e_4337, \val , _e_4333, _e_4330, _e_4327};
    localparam[2:0] _e_9237 = 4;
    assign _e_9236 = \idx  == _e_9237;
    localparam[2:0] _e_4353 = 0;
    assign _e_4351 = \arr [_e_4353 * 8+:8];
    localparam[2:0] _e_4356 = 1;
    assign _e_4354 = \arr [_e_4356 * 8+:8];
    localparam[2:0] _e_4359 = 2;
    assign _e_4357 = \arr [_e_4359 * 8+:8];
    localparam[2:0] _e_4362 = 3;
    assign _e_4360 = \arr [_e_4362 * 8+:8];
    localparam[2:0] _e_4366 = 5;
    assign _e_4364 = \arr [_e_4366 * 8+:8];
    localparam[2:0] _e_4369 = 6;
    assign _e_4367 = \arr [_e_4369 * 8+:8];
    localparam[2:0] _e_4372 = 7;
    assign _e_4370 = \arr [_e_4372 * 8+:8];
    assign _e_4350 = {_e_4370, _e_4367, _e_4364, \val , _e_4360, _e_4357, _e_4354, _e_4351};
    localparam[2:0] _e_9239 = 5;
    assign _e_9238 = \idx  == _e_9239;
    localparam[2:0] _e_4377 = 0;
    assign _e_4375 = \arr [_e_4377 * 8+:8];
    localparam[2:0] _e_4380 = 1;
    assign _e_4378 = \arr [_e_4380 * 8+:8];
    localparam[2:0] _e_4383 = 2;
    assign _e_4381 = \arr [_e_4383 * 8+:8];
    localparam[2:0] _e_4386 = 3;
    assign _e_4384 = \arr [_e_4386 * 8+:8];
    localparam[2:0] _e_4389 = 4;
    assign _e_4387 = \arr [_e_4389 * 8+:8];
    localparam[2:0] _e_4393 = 6;
    assign _e_4391 = \arr [_e_4393 * 8+:8];
    localparam[2:0] _e_4396 = 7;
    assign _e_4394 = \arr [_e_4396 * 8+:8];
    assign _e_4374 = {_e_4394, _e_4391, \val , _e_4387, _e_4384, _e_4381, _e_4378, _e_4375};
    localparam[2:0] _e_9241 = 6;
    assign _e_9240 = \idx  == _e_9241;
    localparam[2:0] _e_4401 = 0;
    assign _e_4399 = \arr [_e_4401 * 8+:8];
    localparam[2:0] _e_4404 = 1;
    assign _e_4402 = \arr [_e_4404 * 8+:8];
    localparam[2:0] _e_4407 = 2;
    assign _e_4405 = \arr [_e_4407 * 8+:8];
    localparam[2:0] _e_4410 = 3;
    assign _e_4408 = \arr [_e_4410 * 8+:8];
    localparam[2:0] _e_4413 = 4;
    assign _e_4411 = \arr [_e_4413 * 8+:8];
    localparam[2:0] _e_4416 = 5;
    assign _e_4414 = \arr [_e_4416 * 8+:8];
    localparam[2:0] _e_4420 = 7;
    assign _e_4418 = \arr [_e_4420 * 8+:8];
    assign _e_4398 = {_e_4418, \val , _e_4414, _e_4411, _e_4408, _e_4405, _e_4402, _e_4399};
    localparam[2:0] _e_9243 = 7;
    assign _e_9242 = \idx  == _e_9243;
    localparam[2:0] _e_4425 = 0;
    assign _e_4423 = \arr [_e_4425 * 8+:8];
    localparam[2:0] _e_4428 = 1;
    assign _e_4426 = \arr [_e_4428 * 8+:8];
    localparam[2:0] _e_4431 = 2;
    assign _e_4429 = \arr [_e_4431 * 8+:8];
    localparam[2:0] _e_4434 = 3;
    assign _e_4432 = \arr [_e_4434 * 8+:8];
    localparam[2:0] _e_4437 = 4;
    assign _e_4435 = \arr [_e_4437 * 8+:8];
    localparam[2:0] _e_4440 = 5;
    assign _e_4438 = \arr [_e_4440 * 8+:8];
    localparam[2:0] _e_4443 = 6;
    assign _e_4441 = \arr [_e_4443 * 8+:8];
    assign _e_4422 = {\val , _e_4441, _e_4438, _e_4435, _e_4432, _e_4429, _e_4426, _e_4423};
    always_comb begin
        priority casez ({_e_9228, _e_9230, _e_9232, _e_9234, _e_9236, _e_9238, _e_9240, _e_9242})
            8'b1???????: _e_4251 = _e_4254;
            8'b01??????: _e_4251 = _e_4278;
            8'b001?????: _e_4251 = _e_4302;
            8'b0001????: _e_4251 = _e_4326;
            8'b00001???: _e_4251 = _e_4350;
            8'b000001??: _e_4251 = _e_4374;
            8'b0000001?: _e_4251 = _e_4398;
            8'b00000001: _e_4251 = _e_4422;
            8'b?: _e_4251 = 64'dx;
        endcase
    end
    assign output__ = _e_4251;
endmodule

module \tta::fifo::fifo_u8  (
        input clk_i,
        input rst_i,
        input[8:0] push_i,
        input pop_i,
        output[14:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::fifo::fifo_u8" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::fifo::fifo_u8 );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[8:0] \push ;
    assign \push  = push_i;
    logic \pop ;
    assign \pop  = pop_i;
    (* src = "src/fifo.spade:45,38" *)
    logic[73:0] _e_4449;
    (* src = "src/fifo.spade:46,23" *)
    logic[3:0] _e_4452;
    (* src = "src/fifo.spade:46,23" *)
    logic \is_full ;
    (* src = "src/fifo.spade:47,24" *)
    logic[3:0] _e_4457;
    (* src = "src/fifo.spade:47,24" *)
    logic \is_empty ;
    (* src = "src/fifo.spade:52,13" *)
    logic[7:0] \_ ;
    logic _e_9245;
    logic _e_9247;
    (* src = "src/fifo.spade:52,24" *)
    logic _e_4466;
    (* src = "src/fifo.spade:52,24" *)
    logic _e_4465;
    logic _e_9249;
    (* src = "src/fifo.spade:51,23" *)
    logic \do_push ;
    (* src = "src/fifo.spade:57,29" *)
    logic _e_4474;
    (* src = "src/fifo.spade:57,22" *)
    logic \do_pop ;
    (* src = "src/fifo.spade:60,41" *)
    logic[2:0] _e_4482;
    (* src = "src/fifo.spade:60,41" *)
    logic[3:0] _e_4481;
    (* src = "src/fifo.spade:60,35" *)
    logic[2:0] _e_4480;
    (* src = "src/fifo.spade:60,63" *)
    logic[2:0] _e_4486;
    (* src = "src/fifo.spade:60,22" *)
    logic[2:0] \next_w ;
    (* src = "src/fifo.spade:61,41" *)
    logic[2:0] _e_4494;
    (* src = "src/fifo.spade:61,41" *)
    logic[3:0] _e_4493;
    (* src = "src/fifo.spade:61,35" *)
    logic[2:0] _e_4492;
    (* src = "src/fifo.spade:61,63" *)
    logic[2:0] _e_4498;
    (* src = "src/fifo.spade:61,22" *)
    logic[2:0] \next_r ;
    (* src = "src/fifo.spade:63,32" *)
    logic[1:0] _e_4502;
    (* src = "src/fifo.spade:64,13" *)
    logic[1:0] _e_4507;
    (* src = "src/fifo.spade:64,13" *)
    logic _e_4505;
    (* src = "src/fifo.spade:64,13" *)
    logic _e_4506;
    logic _e_9252;
    logic _e_9253;
    (* src = "src/fifo.spade:64,36" *)
    logic[3:0] _e_4510;
    (* src = "src/fifo.spade:64,36" *)
    logic[4:0] _e_4509;
    (* src = "src/fifo.spade:64,30" *)
    logic[3:0] _e_4508;
    (* src = "src/fifo.spade:65,13" *)
    logic[1:0] _e_4515;
    (* src = "src/fifo.spade:65,13" *)
    logic _e_4513;
    (* src = "src/fifo.spade:65,13" *)
    logic _e_4514;
    logic _e_9255;
    logic _e_9257;
    (* src = "src/fifo.spade:65,36" *)
    logic[3:0] _e_4518;
    (* src = "src/fifo.spade:65,36" *)
    logic[4:0] _e_4517;
    (* src = "src/fifo.spade:65,30" *)
    logic[3:0] _e_4516;
    (* src = "src/fifo.spade:66,13" *)
    logic[1:0] __n1;
    (* src = "src/fifo.spade:66,18" *)
    logic[3:0] _e_4522;
    (* src = "src/fifo.spade:63,26" *)
    logic[3:0] \next_count ;
    (* src = "src/fifo.spade:71,13" *)
    logic[7:0] \val ;
    logic _e_9260;
    logic _e_9262;
    (* src = "src/fifo.spade:71,47" *)
    logic[63:0] _e_4533;
    (* src = "src/fifo.spade:71,54" *)
    logic[2:0] _e_4535;
    (* src = "src/fifo.spade:71,39" *)
    logic[63:0] _e_4532;
    (* src = "src/fifo.spade:71,77" *)
    logic[63:0] _e_4539;
    (* src = "src/fifo.spade:71,26" *)
    logic[63:0] _e_4529;
    logic _e_9264;
    (* src = "src/fifo.spade:72,21" *)
    logic[63:0] _e_4542;
    (* src = "src/fifo.spade:70,24" *)
    logic[63:0] \next_mem ;
    (* src = "src/fifo.spade:75,9" *)
    logic[73:0] _e_4545;
    (* src = "src/fifo.spade:45,14" *)
    reg[73:0] \s ;
    (* src = "src/fifo.spade:79,17" *)
    logic[3:0] _e_4551;
    (* src = "src/fifo.spade:79,17" *)
    logic \empty ;
    (* src = "src/fifo.spade:80,17" *)
    logic[3:0] _e_4556;
    (* src = "src/fifo.spade:80,17" *)
    logic \full ;
    (* src = "src/fifo.spade:83,22" *)
    logic _e_4561;
    (* src = "src/fifo.spade:86,25" *)
    logic[2:0] _e_4565;
    (* src = "src/fifo.spade:87,13" *)
    logic[2:0] _e_4567;
    logic _e_9265;
    (* src = "src/fifo.spade:87,18" *)
    logic[63:0] _e_4569;
    (* src = "src/fifo.spade:87,18" *)
    logic[7:0] _e_4568;
    (* src = "src/fifo.spade:87,28" *)
    logic[2:0] _e_4572;
    logic _e_9267;
    (* src = "src/fifo.spade:87,33" *)
    logic[63:0] _e_4574;
    (* src = "src/fifo.spade:87,33" *)
    logic[7:0] _e_4573;
    (* src = "src/fifo.spade:87,43" *)
    logic[2:0] _e_4577;
    logic _e_9269;
    (* src = "src/fifo.spade:87,48" *)
    logic[63:0] _e_4579;
    (* src = "src/fifo.spade:87,48" *)
    logic[7:0] _e_4578;
    (* src = "src/fifo.spade:87,58" *)
    logic[2:0] _e_4582;
    logic _e_9271;
    (* src = "src/fifo.spade:87,63" *)
    logic[63:0] _e_4584;
    (* src = "src/fifo.spade:87,63" *)
    logic[7:0] _e_4583;
    (* src = "src/fifo.spade:88,13" *)
    logic[2:0] _e_4587;
    logic _e_9273;
    (* src = "src/fifo.spade:88,18" *)
    logic[63:0] _e_4589;
    (* src = "src/fifo.spade:88,18" *)
    logic[7:0] _e_4588;
    (* src = "src/fifo.spade:88,28" *)
    logic[2:0] _e_4592;
    logic _e_9275;
    (* src = "src/fifo.spade:88,33" *)
    logic[63:0] _e_4594;
    (* src = "src/fifo.spade:88,33" *)
    logic[7:0] _e_4593;
    (* src = "src/fifo.spade:88,43" *)
    logic[2:0] _e_4597;
    logic _e_9277;
    (* src = "src/fifo.spade:88,48" *)
    logic[63:0] _e_4599;
    (* src = "src/fifo.spade:88,48" *)
    logic[7:0] _e_4598;
    (* src = "src/fifo.spade:88,58" *)
    logic[2:0] _e_4602;
    logic _e_9279;
    (* src = "src/fifo.spade:88,63" *)
    logic[63:0] _e_4604;
    (* src = "src/fifo.spade:88,63" *)
    logic[7:0] _e_4603;
    (* src = "src/fifo.spade:86,19" *)
    logic[7:0] val_n1;
    (* src = "src/fifo.spade:90,9" *)
    logic[8:0] _e_4608;
    (* src = "src/fifo.spade:92,9" *)
    logic[8:0] _e_4611;
    (* src = "src/fifo.spade:83,19" *)
    logic[8:0] \out_val ;
    (* src = "src/fifo.spade:95,26" *)
    logic[3:0] _e_4616;
    (* src = "src/fifo.spade:95,5" *)
    logic[14:0] _e_4613;
    (* src = "src/fifo.spade:45,38" *)
    \tta::fifo::reset_fifo  reset_fifo_0(.output__(_e_4449));
    assign _e_4452 = \s [3:0];
    localparam[3:0] _e_4454 = 8;
    assign \is_full  = _e_4452 == _e_4454;
    assign _e_4457 = \s [3:0];
    localparam[3:0] _e_4459 = 0;
    assign \is_empty  = _e_4457 == _e_4459;
    assign \_  = \push [7:0];
    assign _e_9245 = \push [8] == 1'd1;
    localparam[0:0] _e_9246 = 1;
    assign _e_9247 = _e_9245 && _e_9246;
    assign _e_4466 = !\is_full ;
    assign _e_4465 = _e_4466 || \pop ;
    assign _e_9249 = \push [8] == 1'd0;
    localparam[0:0] _e_4470 = 0;
    always_comb begin
        priority casez ({_e_9247, _e_9249})
            2'b1?: \do_push  = _e_4465;
            2'b01: \do_push  = _e_4470;
            2'b?: \do_push  = 1'dx;
        endcase
    end
    assign _e_4474 = !\is_empty ;
    assign \do_pop  = \pop  && _e_4474;
    assign _e_4482 = \s [9:7];
    localparam[2:0] _e_4484 = 1;
    assign _e_4481 = _e_4482 + _e_4484;
    assign _e_4480 = _e_4481[2:0];
    assign _e_4486 = \s [9:7];
    assign \next_w  = \do_push  ? _e_4480 : _e_4486;
    assign _e_4494 = \s [6:4];
    localparam[2:0] _e_4496 = 1;
    assign _e_4493 = _e_4494 + _e_4496;
    assign _e_4492 = _e_4493[2:0];
    assign _e_4498 = \s [6:4];
    assign \next_r  = \do_pop  ? _e_4492 : _e_4498;
    assign _e_4502 = {\do_push , \do_pop };
    assign _e_4507 = _e_4502;
    assign _e_4505 = _e_4502[1];
    assign _e_4506 = _e_4502[0];
    assign _e_9252 = !_e_4506;
    assign _e_9253 = _e_4505 && _e_9252;
    assign _e_4510 = \s [3:0];
    localparam[3:0] _e_4512 = 1;
    assign _e_4509 = _e_4510 + _e_4512;
    assign _e_4508 = _e_4509[3:0];
    assign _e_4515 = _e_4502;
    assign _e_4513 = _e_4502[1];
    assign _e_4514 = _e_4502[0];
    assign _e_9255 = !_e_4513;
    assign _e_9257 = _e_9255 && _e_4514;
    assign _e_4518 = \s [3:0];
    localparam[3:0] _e_4520 = 1;
    assign _e_4517 = _e_4518 - _e_4520;
    assign _e_4516 = _e_4517[3:0];
    assign __n1 = _e_4502;
    localparam[0:0] _e_9258 = 1;
    assign _e_4522 = \s [3:0];
    always_comb begin
        priority casez ({_e_9253, _e_9257, _e_9258})
            3'b1??: \next_count  = _e_4508;
            3'b01?: \next_count  = _e_4516;
            3'b001: \next_count  = _e_4522;
            3'b?: \next_count  = 4'dx;
        endcase
    end
    assign \val  = \push [7:0];
    assign _e_9260 = \push [8] == 1'd1;
    localparam[0:0] _e_9261 = 1;
    assign _e_9262 = _e_9260 && _e_9261;
    assign _e_4533 = \s [73:10];
    assign _e_4535 = \s [9:7];
    (* src = "src/fifo.spade:71,39" *)
    \tta::fifo::set_mem  set_mem_0(.arr_i(_e_4533), .idx_i(_e_4535), .val_i(\val ), .output__(_e_4532));
    assign _e_4539 = \s [73:10];
    assign _e_4529 = \do_push  ? _e_4532 : _e_4539;
    assign _e_9264 = \push [8] == 1'd0;
    assign _e_4542 = \s [73:10];
    always_comb begin
        priority casez ({_e_9262, _e_9264})
            2'b1?: \next_mem  = _e_4529;
            2'b01: \next_mem  = _e_4542;
            2'b?: \next_mem  = 64'dx;
        endcase
    end
    assign _e_4545 = {\next_mem , \next_w , \next_r , \next_count };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s  <= _e_4449;
        end
        else begin
            \s  <= _e_4545;
        end
    end
    assign _e_4551 = \s [3:0];
    localparam[3:0] _e_4553 = 0;
    assign \empty  = _e_4551 == _e_4553;
    assign _e_4556 = \s [3:0];
    localparam[3:0] _e_4558 = 8;
    assign \full  = _e_4556 == _e_4558;
    assign _e_4561 = !\empty ;
    assign _e_4565 = \s [6:4];
    assign _e_4567 = _e_4565;
    localparam[2:0] _e_9266 = 0;
    assign _e_9265 = _e_4565 == _e_9266;
    assign _e_4569 = \s [73:10];
    localparam[2:0] _e_4571 = 0;
    assign _e_4568 = _e_4569[_e_4571 * 8+:8];
    assign _e_4572 = _e_4565;
    localparam[2:0] _e_9268 = 1;
    assign _e_9267 = _e_4565 == _e_9268;
    assign _e_4574 = \s [73:10];
    localparam[2:0] _e_4576 = 1;
    assign _e_4573 = _e_4574[_e_4576 * 8+:8];
    assign _e_4577 = _e_4565;
    localparam[2:0] _e_9270 = 2;
    assign _e_9269 = _e_4565 == _e_9270;
    assign _e_4579 = \s [73:10];
    localparam[2:0] _e_4581 = 2;
    assign _e_4578 = _e_4579[_e_4581 * 8+:8];
    assign _e_4582 = _e_4565;
    localparam[2:0] _e_9272 = 3;
    assign _e_9271 = _e_4565 == _e_9272;
    assign _e_4584 = \s [73:10];
    localparam[2:0] _e_4586 = 3;
    assign _e_4583 = _e_4584[_e_4586 * 8+:8];
    assign _e_4587 = _e_4565;
    localparam[2:0] _e_9274 = 4;
    assign _e_9273 = _e_4565 == _e_9274;
    assign _e_4589 = \s [73:10];
    localparam[2:0] _e_4591 = 4;
    assign _e_4588 = _e_4589[_e_4591 * 8+:8];
    assign _e_4592 = _e_4565;
    localparam[2:0] _e_9276 = 5;
    assign _e_9275 = _e_4565 == _e_9276;
    assign _e_4594 = \s [73:10];
    localparam[2:0] _e_4596 = 5;
    assign _e_4593 = _e_4594[_e_4596 * 8+:8];
    assign _e_4597 = _e_4565;
    localparam[2:0] _e_9278 = 6;
    assign _e_9277 = _e_4565 == _e_9278;
    assign _e_4599 = \s [73:10];
    localparam[2:0] _e_4601 = 6;
    assign _e_4598 = _e_4599[_e_4601 * 8+:8];
    assign _e_4602 = _e_4565;
    localparam[2:0] _e_9280 = 7;
    assign _e_9279 = _e_4565 == _e_9280;
    assign _e_4604 = \s [73:10];
    localparam[2:0] _e_4606 = 7;
    assign _e_4603 = _e_4604[_e_4606 * 8+:8];
    always_comb begin
        priority casez ({_e_9265, _e_9267, _e_9269, _e_9271, _e_9273, _e_9275, _e_9277, _e_9279})
            8'b1???????: val_n1 = _e_4568;
            8'b01??????: val_n1 = _e_4573;
            8'b001?????: val_n1 = _e_4578;
            8'b0001????: val_n1 = _e_4583;
            8'b00001???: val_n1 = _e_4588;
            8'b000001??: val_n1 = _e_4593;
            8'b0000001?: val_n1 = _e_4598;
            8'b00000001: val_n1 = _e_4603;
            8'b?: val_n1 = 8'dx;
        endcase
    end
    assign _e_4608 = {1'd1, val_n1};
    assign _e_4611 = {1'd0, 8'bX};
    assign \out_val  = _e_4561 ? _e_4608 : _e_4611;
    assign _e_4616 = \s [3:0];
    assign _e_4613 = {\full , \empty , _e_4616, \out_val };
    assign output__ = _e_4613;
endmodule

module \tta::lsu::lsu_fu  (
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input[32:0] set_addr_a_i,
        input[32:0] load_trig_i,
        input[32:0] store_trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lsu::lsu_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lsu::lsu_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_addr_a ;
    assign \set_addr_a  = set_addr_a_i;
    logic[32:0] \load_trig ;
    assign \load_trig  = load_trig_i;
    logic[32:0] \store_trig ;
    assign \store_trig  = store_trig_i;
    (* src = "src/lsu.spade:24,9" *)
    logic[31:0] \v ;
    logic _e_9282;
    logic _e_9284;
    logic _e_9286;
    (* src = "src/lsu.spade:23,47" *)
    logic[31:0] _e_4624;
    (* src = "src/lsu.spade:23,14" *)
    reg[31:0] \addr_a ;
    (* src = "src/lsu.spade:29,9" *)
    logic[31:0] \b ;
    logic _e_9288;
    logic _e_9290;
    (* src = "src/lsu.spade:29,20" *)
    logic[32:0] _e_4635;
    logic _e_9292;
    logic[32:0] _e_4639;
    (* src = "src/lsu.spade:28,31" *)
    logic[32:0] \addr_calc ;
    (* src = "src/lsu.spade:34,41" *)
    logic[31:0] \_ ;
    logic _e_9294;
    logic _e_9296;
    logic _e_9298;
    (* src = "src/lsu.spade:34,22" *)
    logic \wren ;
    (* src = "src/lsu.spade:35,36" *)
    logic[31:0] \x ;
    logic _e_9300;
    logic _e_9302;
    logic _e_9304;
    (* src = "src/lsu.spade:35,17" *)
    logic[31:0] \wdata ;
    (* src = "src/lsu.spade:36,56" *)
    logic[15:0] _e_4662;
    (* src = "src/lsu.spade:36,17" *)
    logic[31:0] \rdata ;
    (* src = "src/lsu.spade:39,55" *)
    logic[65:0] _e_4672;
    (* src = "src/lsu.spade:40,9" *)
    logic[65:0] _e_4678;
    (* src = "src/lsu.spade:40,9" *)
    logic[32:0] _e_4676;
    (* src = "src/lsu.spade:40,10" *)
    logic[31:0] __n1;
    (* src = "src/lsu.spade:40,9" *)
    logic[32:0] _e_4677;
    logic _e_9307;
    logic _e_9309;
    logic _e_9311;
    logic _e_9312;
    (* src = "src/lsu.spade:41,9" *)
    logic[65:0] _e_4683;
    (* src = "src/lsu.spade:41,9" *)
    logic[32:0] __n2;
    (* src = "src/lsu.spade:41,9" *)
    logic[32:0] _e_4682;
    (* src = "src/lsu.spade:41,13" *)
    logic[31:0] __n3;
    logic _e_9316;
    logic _e_9318;
    logic _e_9319;
    (* src = "src/lsu.spade:42,9" *)
    logic[65:0] _e_4687;
    (* src = "src/lsu.spade:42,9" *)
    logic[32:0] _e_4685;
    (* src = "src/lsu.spade:42,9" *)
    logic[32:0] _e_4686;
    logic _e_9322;
    logic _e_9324;
    logic _e_9325;
    (* src = "src/lsu.spade:39,49" *)
    logic _e_4671;
    (* src = "src/lsu.spade:39,14" *)
    reg \ld_ready ;
    (* src = "src/lsu.spade:45,19" *)
    logic[32:0] _e_4692;
    (* src = "src/lsu.spade:45,40" *)
    logic[32:0] _e_4695;
    (* src = "src/lsu.spade:45,5" *)
    logic[32:0] _e_4689;
    localparam[31:0] _e_4623 = 32'd0;
    assign \v  = \set_addr_a [31:0];
    assign _e_9282 = \set_addr_a [32] == 1'd1;
    localparam[0:0] _e_9283 = 1;
    assign _e_9284 = _e_9282 && _e_9283;
    assign _e_9286 = \set_addr_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9284, _e_9286})
            2'b1?: _e_4624 = \v ;
            2'b01: _e_4624 = \addr_a ;
            2'b?: _e_4624 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \addr_a  <= _e_4623;
        end
        else begin
            \addr_a  <= _e_4624;
        end
    end
    assign \b  = \load_trig [31:0];
    assign _e_9288 = \load_trig [32] == 1'd1;
    localparam[0:0] _e_9289 = 1;
    assign _e_9290 = _e_9288 && _e_9289;
    assign _e_4635 = \addr_a  + \b ;
    assign _e_9292 = \load_trig [32] == 1'd0;
    assign _e_4639 = {1'b0, \addr_a };
    always_comb begin
        priority casez ({_e_9290, _e_9292})
            2'b1?: \addr_calc  = _e_4635;
            2'b01: \addr_calc  = _e_4639;
            2'b?: \addr_calc  = 33'dx;
        endcase
    end
    assign \_  = \store_trig [31:0];
    assign _e_9294 = \store_trig [32] == 1'd1;
    localparam[0:0] _e_9295 = 1;
    assign _e_9296 = _e_9294 && _e_9295;
    localparam[0:0] _e_4646 = 1;
    assign _e_9298 = \store_trig [32] == 1'd0;
    localparam[0:0] _e_4648 = 0;
    always_comb begin
        priority casez ({_e_9296, _e_9298})
            2'b1?: \wren  = _e_4646;
            2'b01: \wren  = _e_4648;
            2'b?: \wren  = 1'dx;
        endcase
    end
    assign \x  = \store_trig [31:0];
    assign _e_9300 = \store_trig [32] == 1'd1;
    localparam[0:0] _e_9301 = 1;
    assign _e_9302 = _e_9300 && _e_9301;
    assign _e_9304 = \store_trig [32] == 1'd0;
    localparam[31:0] _e_4656 = 32'd0;
    always_comb begin
        priority casez ({_e_9302, _e_9304})
            2'b1?: \wdata  = \x ;
            2'b01: \wdata  = _e_4656;
            2'b?: \wdata  = 32'dx;
        endcase
    end
    localparam[0:0] _e_4661 = 1;
    assign _e_4662 = \addr_calc [15:0];
    (* src = "src/lsu.spade:36,17" *)
    \tta::sram::sram_512x32  sram_512x32_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .en_i(_e_4661), .addr_i(_e_4662), .we_i(\wren ), .wdata_i(\wdata ), .output__(\rdata ));
    localparam[0:0] _e_4670 = 0;
    assign _e_4672 = {\load_trig , \store_trig };
    assign _e_4678 = _e_4672;
    assign _e_4676 = _e_4672[65:33];
    assign __n1 = _e_4676[31:0];
    assign _e_4677 = _e_4672[32:0];
    assign _e_9307 = _e_4676[32] == 1'd1;
    localparam[0:0] _e_9308 = 1;
    assign _e_9309 = _e_9307 && _e_9308;
    assign _e_9311 = _e_4677[32] == 1'd0;
    assign _e_9312 = _e_9309 && _e_9311;
    localparam[0:0] _e_4679 = 1;
    assign _e_4683 = _e_4672;
    assign __n2 = _e_4672[65:33];
    assign _e_4682 = _e_4672[32:0];
    assign __n3 = _e_4682[31:0];
    localparam[0:0] _e_9314 = 1;
    assign _e_9316 = _e_4682[32] == 1'd1;
    localparam[0:0] _e_9317 = 1;
    assign _e_9318 = _e_9316 && _e_9317;
    assign _e_9319 = _e_9314 && _e_9318;
    localparam[0:0] _e_4684 = 0;
    assign _e_4687 = _e_4672;
    assign _e_4685 = _e_4672[65:33];
    assign _e_4686 = _e_4672[32:0];
    assign _e_9322 = _e_4685[32] == 1'd0;
    assign _e_9324 = _e_4686[32] == 1'd0;
    assign _e_9325 = _e_9322 && _e_9324;
    localparam[0:0] _e_4688 = 0;
    always_comb begin
        priority casez ({_e_9312, _e_9319, _e_9325})
            3'b1??: _e_4671 = _e_4679;
            3'b01?: _e_4671 = _e_4684;
            3'b001: _e_4671 = _e_4688;
            3'b?: _e_4671 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \ld_ready  <= _e_4670;
        end
        else begin
            \ld_ready  <= _e_4671;
        end
    end
    assign _e_4692 = {1'd1, \rdata };
    assign _e_4695 = {1'd0, 32'bX};
    assign _e_4689 = \ld_ready  ? _e_4692 : _e_4695;
    assign output__ = _e_4689;
endmodule

module \tta::lsu::pick_lsu_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lsu::pick_lsu_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lsu::pick_lsu_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/lsu.spade:54,9" *)
    logic[42:0] _e_4700;
    (* src = "src/lsu.spade:54,14" *)
    logic[31:0] \x ;
    logic _e_9327;
    logic _e_9329;
    logic _e_9331;
    logic _e_9332;
    (* src = "src/lsu.spade:54,35" *)
    logic[32:0] _e_4702;
    (* src = "src/lsu.spade:55,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:56,13" *)
    logic[42:0] _e_4708;
    (* src = "src/lsu.spade:56,18" *)
    logic[31:0] x_n1;
    logic _e_9335;
    logic _e_9337;
    logic _e_9339;
    logic _e_9340;
    (* src = "src/lsu.spade:56,39" *)
    logic[32:0] _e_4710;
    (* src = "src/lsu.spade:57,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:57,18" *)
    logic[32:0] _e_4713;
    (* src = "src/lsu.spade:55,14" *)
    logic[32:0] _e_4705;
    (* src = "src/lsu.spade:53,5" *)
    logic[32:0] _e_4697;
    assign _e_4700 = \m1 [42:0];
    assign \x  = _e_4700[36:5];
    assign _e_9327 = \m1 [43] == 1'd1;
    assign _e_9329 = _e_4700[42:37] == 6'd4;
    localparam[0:0] _e_9330 = 1;
    assign _e_9331 = _e_9329 && _e_9330;
    assign _e_9332 = _e_9327 && _e_9331;
    assign _e_4702 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9333 = 1;
    assign _e_4708 = \m0 [42:0];
    assign x_n1 = _e_4708[36:5];
    assign _e_9335 = \m0 [43] == 1'd1;
    assign _e_9337 = _e_4708[42:37] == 6'd4;
    localparam[0:0] _e_9338 = 1;
    assign _e_9339 = _e_9337 && _e_9338;
    assign _e_9340 = _e_9335 && _e_9339;
    assign _e_4710 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9341 = 1;
    assign _e_4713 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9340, _e_9341})
            2'b1?: _e_4705 = _e_4710;
            2'b01: _e_4705 = _e_4713;
            2'b?: _e_4705 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9332, _e_9333})
            2'b1?: _e_4697 = _e_4702;
            2'b01: _e_4697 = _e_4705;
            2'b?: _e_4697 = 33'dx;
        endcase
    end
    assign output__ = _e_4697;
endmodule

module \tta::lsu::pick_lsu_loadtrig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lsu::pick_lsu_loadtrig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lsu::pick_lsu_loadtrig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/lsu.spade:64,9" *)
    logic[42:0] _e_4718;
    (* src = "src/lsu.spade:64,14" *)
    logic[31:0] \x ;
    logic _e_9343;
    logic _e_9345;
    logic _e_9347;
    logic _e_9348;
    (* src = "src/lsu.spade:64,40" *)
    logic[32:0] _e_4720;
    (* src = "src/lsu.spade:65,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:66,13" *)
    logic[42:0] _e_4726;
    (* src = "src/lsu.spade:66,18" *)
    logic[31:0] x_n1;
    logic _e_9351;
    logic _e_9353;
    logic _e_9355;
    logic _e_9356;
    (* src = "src/lsu.spade:66,44" *)
    logic[32:0] _e_4728;
    (* src = "src/lsu.spade:67,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:67,18" *)
    logic[32:0] _e_4731;
    (* src = "src/lsu.spade:65,14" *)
    logic[32:0] _e_4723;
    (* src = "src/lsu.spade:63,5" *)
    logic[32:0] _e_4715;
    assign _e_4718 = \m1 [42:0];
    assign \x  = _e_4718[36:5];
    assign _e_9343 = \m1 [43] == 1'd1;
    assign _e_9345 = _e_4718[42:37] == 6'd5;
    localparam[0:0] _e_9346 = 1;
    assign _e_9347 = _e_9345 && _e_9346;
    assign _e_9348 = _e_9343 && _e_9347;
    assign _e_4720 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9349 = 1;
    assign _e_4726 = \m0 [42:0];
    assign x_n1 = _e_4726[36:5];
    assign _e_9351 = \m0 [43] == 1'd1;
    assign _e_9353 = _e_4726[42:37] == 6'd5;
    localparam[0:0] _e_9354 = 1;
    assign _e_9355 = _e_9353 && _e_9354;
    assign _e_9356 = _e_9351 && _e_9355;
    assign _e_4728 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9357 = 1;
    assign _e_4731 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9356, _e_9357})
            2'b1?: _e_4723 = _e_4728;
            2'b01: _e_4723 = _e_4731;
            2'b?: _e_4723 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9348, _e_9349})
            2'b1?: _e_4715 = _e_4720;
            2'b01: _e_4715 = _e_4723;
            2'b?: _e_4715 = 33'dx;
        endcase
    end
    assign output__ = _e_4715;
endmodule

module \tta::lsu::pick_lsu_storetrig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lsu::pick_lsu_storetrig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lsu::pick_lsu_storetrig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/lsu.spade:74,9" *)
    logic[42:0] _e_4736;
    (* src = "src/lsu.spade:74,14" *)
    logic[31:0] \x ;
    logic _e_9359;
    logic _e_9361;
    logic _e_9363;
    logic _e_9364;
    (* src = "src/lsu.spade:74,41" *)
    logic[32:0] _e_4738;
    (* src = "src/lsu.spade:75,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:76,13" *)
    logic[42:0] _e_4744;
    (* src = "src/lsu.spade:76,18" *)
    logic[31:0] x_n1;
    logic _e_9367;
    logic _e_9369;
    logic _e_9371;
    logic _e_9372;
    (* src = "src/lsu.spade:76,45" *)
    logic[32:0] _e_4746;
    (* src = "src/lsu.spade:77,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:77,18" *)
    logic[32:0] _e_4749;
    (* src = "src/lsu.spade:75,14" *)
    logic[32:0] _e_4741;
    (* src = "src/lsu.spade:73,5" *)
    logic[32:0] _e_4733;
    assign _e_4736 = \m1 [42:0];
    assign \x  = _e_4736[36:5];
    assign _e_9359 = \m1 [43] == 1'd1;
    assign _e_9361 = _e_4736[42:37] == 6'd6;
    localparam[0:0] _e_9362 = 1;
    assign _e_9363 = _e_9361 && _e_9362;
    assign _e_9364 = _e_9359 && _e_9363;
    assign _e_4738 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9365 = 1;
    assign _e_4744 = \m0 [42:0];
    assign x_n1 = _e_4744[36:5];
    assign _e_9367 = \m0 [43] == 1'd1;
    assign _e_9369 = _e_4744[42:37] == 6'd6;
    localparam[0:0] _e_9370 = 1;
    assign _e_9371 = _e_9369 && _e_9370;
    assign _e_9372 = _e_9367 && _e_9371;
    assign _e_4746 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9373 = 1;
    assign _e_4749 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9372, _e_9373})
            2'b1?: _e_4741 = _e_4746;
            2'b01: _e_4741 = _e_4749;
            2'b?: _e_4741 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9364, _e_9365})
            2'b1?: _e_4733 = _e_4738;
            2'b01: _e_4733 = _e_4741;
            2'b?: _e_4733 = 33'dx;
        endcase
    end
    assign output__ = _e_4733;
endmodule

module \tta::lsu::pick_lsu2_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lsu::pick_lsu2_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lsu::pick_lsu2_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/lsu.spade:85,9" *)
    logic[42:0] _e_4754;
    (* src = "src/lsu.spade:85,14" *)
    logic[31:0] \x ;
    logic _e_9375;
    logic _e_9377;
    logic _e_9379;
    logic _e_9380;
    (* src = "src/lsu.spade:85,36" *)
    logic[32:0] _e_4756;
    (* src = "src/lsu.spade:86,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:87,13" *)
    logic[42:0] _e_4762;
    (* src = "src/lsu.spade:87,18" *)
    logic[31:0] x_n1;
    logic _e_9383;
    logic _e_9385;
    logic _e_9387;
    logic _e_9388;
    (* src = "src/lsu.spade:87,40" *)
    logic[32:0] _e_4764;
    (* src = "src/lsu.spade:88,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:88,18" *)
    logic[32:0] _e_4767;
    (* src = "src/lsu.spade:86,14" *)
    logic[32:0] _e_4759;
    (* src = "src/lsu.spade:84,5" *)
    logic[32:0] _e_4751;
    assign _e_4754 = \m1 [42:0];
    assign \x  = _e_4754[36:5];
    assign _e_9375 = \m1 [43] == 1'd1;
    assign _e_9377 = _e_4754[42:37] == 6'd7;
    localparam[0:0] _e_9378 = 1;
    assign _e_9379 = _e_9377 && _e_9378;
    assign _e_9380 = _e_9375 && _e_9379;
    assign _e_4756 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9381 = 1;
    assign _e_4762 = \m0 [42:0];
    assign x_n1 = _e_4762[36:5];
    assign _e_9383 = \m0 [43] == 1'd1;
    assign _e_9385 = _e_4762[42:37] == 6'd7;
    localparam[0:0] _e_9386 = 1;
    assign _e_9387 = _e_9385 && _e_9386;
    assign _e_9388 = _e_9383 && _e_9387;
    assign _e_4764 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9389 = 1;
    assign _e_4767 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9388, _e_9389})
            2'b1?: _e_4759 = _e_4764;
            2'b01: _e_4759 = _e_4767;
            2'b?: _e_4759 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9380, _e_9381})
            2'b1?: _e_4751 = _e_4756;
            2'b01: _e_4751 = _e_4759;
            2'b?: _e_4751 = 33'dx;
        endcase
    end
    assign output__ = _e_4751;
endmodule

module \tta::lsu::pick_lsu2_loadtrig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lsu::pick_lsu2_loadtrig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lsu::pick_lsu2_loadtrig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/lsu.spade:95,9" *)
    logic[42:0] _e_4772;
    (* src = "src/lsu.spade:95,14" *)
    logic[31:0] \x ;
    logic _e_9391;
    logic _e_9393;
    logic _e_9395;
    logic _e_9396;
    (* src = "src/lsu.spade:95,41" *)
    logic[32:0] _e_4774;
    (* src = "src/lsu.spade:96,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:97,13" *)
    logic[42:0] _e_4780;
    (* src = "src/lsu.spade:97,18" *)
    logic[31:0] x_n1;
    logic _e_9399;
    logic _e_9401;
    logic _e_9403;
    logic _e_9404;
    (* src = "src/lsu.spade:97,45" *)
    logic[32:0] _e_4782;
    (* src = "src/lsu.spade:98,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:98,18" *)
    logic[32:0] _e_4785;
    (* src = "src/lsu.spade:96,14" *)
    logic[32:0] _e_4777;
    (* src = "src/lsu.spade:94,5" *)
    logic[32:0] _e_4769;
    assign _e_4772 = \m1 [42:0];
    assign \x  = _e_4772[36:5];
    assign _e_9391 = \m1 [43] == 1'd1;
    assign _e_9393 = _e_4772[42:37] == 6'd8;
    localparam[0:0] _e_9394 = 1;
    assign _e_9395 = _e_9393 && _e_9394;
    assign _e_9396 = _e_9391 && _e_9395;
    assign _e_4774 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9397 = 1;
    assign _e_4780 = \m0 [42:0];
    assign x_n1 = _e_4780[36:5];
    assign _e_9399 = \m0 [43] == 1'd1;
    assign _e_9401 = _e_4780[42:37] == 6'd8;
    localparam[0:0] _e_9402 = 1;
    assign _e_9403 = _e_9401 && _e_9402;
    assign _e_9404 = _e_9399 && _e_9403;
    assign _e_4782 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9405 = 1;
    assign _e_4785 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9404, _e_9405})
            2'b1?: _e_4777 = _e_4782;
            2'b01: _e_4777 = _e_4785;
            2'b?: _e_4777 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9396, _e_9397})
            2'b1?: _e_4769 = _e_4774;
            2'b01: _e_4769 = _e_4777;
            2'b?: _e_4769 = 33'dx;
        endcase
    end
    assign output__ = _e_4769;
endmodule

module \tta::lsu::pick_lsu2_storetrig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::lsu::pick_lsu2_storetrig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::lsu::pick_lsu2_storetrig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/lsu.spade:105,9" *)
    logic[42:0] _e_4790;
    (* src = "src/lsu.spade:105,14" *)
    logic[31:0] \x ;
    logic _e_9407;
    logic _e_9409;
    logic _e_9411;
    logic _e_9412;
    (* src = "src/lsu.spade:105,42" *)
    logic[32:0] _e_4792;
    (* src = "src/lsu.spade:106,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:107,13" *)
    logic[42:0] _e_4798;
    (* src = "src/lsu.spade:107,18" *)
    logic[31:0] x_n1;
    logic _e_9415;
    logic _e_9417;
    logic _e_9419;
    logic _e_9420;
    (* src = "src/lsu.spade:107,46" *)
    logic[32:0] _e_4800;
    (* src = "src/lsu.spade:108,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:108,18" *)
    logic[32:0] _e_4803;
    (* src = "src/lsu.spade:106,14" *)
    logic[32:0] _e_4795;
    (* src = "src/lsu.spade:104,5" *)
    logic[32:0] _e_4787;
    assign _e_4790 = \m1 [42:0];
    assign \x  = _e_4790[36:5];
    assign _e_9407 = \m1 [43] == 1'd1;
    assign _e_9409 = _e_4790[42:37] == 6'd9;
    localparam[0:0] _e_9410 = 1;
    assign _e_9411 = _e_9409 && _e_9410;
    assign _e_9412 = _e_9407 && _e_9411;
    assign _e_4792 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9413 = 1;
    assign _e_4798 = \m0 [42:0];
    assign x_n1 = _e_4798[36:5];
    assign _e_9415 = \m0 [43] == 1'd1;
    assign _e_9417 = _e_4798[42:37] == 6'd9;
    localparam[0:0] _e_9418 = 1;
    assign _e_9419 = _e_9417 && _e_9418;
    assign _e_9420 = _e_9415 && _e_9419;
    assign _e_4800 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9421 = 1;
    assign _e_4803 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9420, _e_9421})
            2'b1?: _e_4795 = _e_4800;
            2'b01: _e_4795 = _e_4803;
            2'b?: _e_4795 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9412, _e_9413})
            2'b1?: _e_4787 = _e_4792;
            2'b01: _e_4787 = _e_4795;
            2'b?: _e_4787 = 33'dx;
        endcase
    end
    assign output__ = _e_4787;
endmodule

module \tta::parallel_rx::parallel_boot  (
        input clk_i,
        input rst_i,
        input[7:0] data_in_i,
        input strobe_i,
        input clk_pin_i,
        output[8:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::parallel_rx::parallel_boot" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::parallel_rx::parallel_boot );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[7:0] \data_in ;
    assign \data_in  = data_in_i;
    logic \strobe ;
    assign \strobe  = strobe_i;
    logic \clk_pin ;
    assign \clk_pin  = clk_pin_i;
    (* src = "src/parallel_rx.spade:23,14" *)
    reg \clk_pin_s1 ;
    (* src = "src/parallel_rx.spade:24,14" *)
    reg \clk_pin_s2 ;
    (* src = "src/parallel_rx.spade:27,14" *)
    reg[7:0] \data_sync ;
    (* src = "src/parallel_rx.spade:28,14" *)
    reg \strobe_sync ;
    (* src = "src/parallel_rx.spade:31,40" *)
    logic[8:0] _e_4828;
    (* src = "src/parallel_rx.spade:32,9" *)
    logic[8:0] _e_4832;
    (* src = "src/parallel_rx.spade:31,14" *)
    reg[8:0] \rx ;
    (* src = "src/parallel_rx.spade:37,24" *)
    logic _e_4837;
    (* src = "src/parallel_rx.spade:37,23" *)
    logic _e_4836;
    (* src = "src/parallel_rx.spade:37,23" *)
    logic \rising_edge ;
    (* src = "src/parallel_rx.spade:40,8" *)
    logic _e_4842;
    (* src = "src/parallel_rx.spade:41,14" *)
    logic[7:0] _e_4847;
    (* src = "src/parallel_rx.spade:41,9" *)
    logic[8:0] _e_4846;
    (* src = "src/parallel_rx.spade:43,9" *)
    logic[8:0] _e_4850;
    (* src = "src/parallel_rx.spade:40,5" *)
    logic[8:0] _e_4841;
    localparam[0:0] _e_4808 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \clk_pin_s1  <= _e_4808;
        end
        else begin
            \clk_pin_s1  <= \clk_pin ;
        end
    end
    localparam[0:0] _e_4813 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \clk_pin_s2  <= _e_4813;
        end
        else begin
            \clk_pin_s2  <= \clk_pin_s1 ;
        end
    end
    localparam[7:0] _e_4818 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \data_sync  <= _e_4818;
        end
        else begin
            \data_sync  <= \data_in ;
        end
    end
    localparam[0:0] _e_4823 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \strobe_sync  <= _e_4823;
        end
        else begin
            \strobe_sync  <= \strobe ;
        end
    end
    localparam[0:0] _e_4829 = 0;
    localparam[7:0] _e_4830 = 0;
    assign _e_4828 = {_e_4829, _e_4830};
    assign _e_4832 = {\clk_pin_s2 , \data_sync };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx  <= _e_4828;
        end
        else begin
            \rx  <= _e_4832;
        end
    end
    assign _e_4837 = \rx [8];
    assign _e_4836 = !_e_4837;
    assign \rising_edge  = _e_4836 && \clk_pin_s2 ;
    assign _e_4842 = \rising_edge  && \strobe_sync ;
    assign _e_4847 = \rx [7:0];
    assign _e_4846 = {1'd1, _e_4847};
    assign _e_4850 = {1'd0, 8'bX};
    assign _e_4841 = _e_4842 ? _e_4846 : _e_4850;
    assign output__ = _e_4841;
endmodule

module \tta::sel::sel_fu  (
        input clk_i,
        input rst_i,
        input[1:0] set_cond_i,
        input[32:0] set_a_i,
        input[32:0] trig_b_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::sel::sel_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::sel::sel_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[1:0] \set_cond ;
    assign \set_cond  = set_cond_i;
    logic[32:0] \set_a ;
    assign \set_a  = set_a_i;
    logic[32:0] \trig_b ;
    assign \trig_b  = trig_b_i;
    (* src = "src/sel.spade:19,9" *)
    logic \c ;
    logic _e_9423;
    logic _e_9425;
    logic _e_9427;
    (* src = "src/sel.spade:18,45" *)
    logic _e_4856;
    (* src = "src/sel.spade:18,14" *)
    reg \cond ;
    (* src = "src/sel.spade:24,9" *)
    logic[31:0] \v ;
    logic _e_9429;
    logic _e_9431;
    logic _e_9433;
    (* src = "src/sel.spade:23,46" *)
    logic[31:0] _e_4867;
    (* src = "src/sel.spade:23,14" *)
    reg[31:0] \val_a ;
    (* src = "src/sel.spade:30,47" *)
    logic[32:0] _e_4877;
    (* src = "src/sel.spade:31,9" *)
    logic[31:0] \val_b ;
    logic _e_9435;
    logic _e_9437;
    (* src = "src/sel.spade:33,17" *)
    logic[32:0] _e_4886;
    (* src = "src/sel.spade:35,17" *)
    logic[32:0] _e_4889;
    (* src = "src/sel.spade:32,13" *)
    logic[32:0] _e_4883;
    logic _e_9439;
    (* src = "src/sel.spade:38,17" *)
    logic[32:0] _e_4892;
    (* src = "src/sel.spade:30,55" *)
    logic[32:0] _e_4878;
    (* src = "src/sel.spade:30,14" *)
    reg[32:0] \res ;
    localparam[0:0] _e_4855 = 0;
    assign \c  = \set_cond [0:0];
    assign _e_9423 = \set_cond [1] == 1'd1;
    localparam[0:0] _e_9424 = 1;
    assign _e_9425 = _e_9423 && _e_9424;
    assign _e_9427 = \set_cond [1] == 1'd0;
    always_comb begin
        priority casez ({_e_9425, _e_9427})
            2'b1?: _e_4856 = \c ;
            2'b01: _e_4856 = \cond ;
            2'b?: _e_4856 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \cond  <= _e_4855;
        end
        else begin
            \cond  <= _e_4856;
        end
    end
    localparam[31:0] _e_4866 = 32'd0;
    assign \v  = \set_a [31:0];
    assign _e_9429 = \set_a [32] == 1'd1;
    localparam[0:0] _e_9430 = 1;
    assign _e_9431 = _e_9429 && _e_9430;
    assign _e_9433 = \set_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9431, _e_9433})
            2'b1?: _e_4867 = \v ;
            2'b01: _e_4867 = \val_a ;
            2'b?: _e_4867 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \val_a  <= _e_4866;
        end
        else begin
            \val_a  <= _e_4867;
        end
    end
    assign _e_4877 = {1'd0, 32'bX};
    assign \val_b  = \trig_b [31:0];
    assign _e_9435 = \trig_b [32] == 1'd1;
    localparam[0:0] _e_9436 = 1;
    assign _e_9437 = _e_9435 && _e_9436;
    assign _e_4886 = {1'd1, \val_a };
    assign _e_4889 = {1'd1, \val_b };
    assign _e_4883 = \cond  ? _e_4886 : _e_4889;
    assign _e_9439 = \trig_b [32] == 1'd0;
    assign _e_4892 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9437, _e_9439})
            2'b1?: _e_4878 = _e_4883;
            2'b01: _e_4878 = _e_4892;
            2'b?: _e_4878 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_4877;
        end
        else begin
            \res  <= _e_4878;
        end
    end
    assign output__ = \res ;
endmodule

module \tta::sel::pick_sel_cond  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[1:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::sel::pick_sel_cond" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::sel::pick_sel_cond );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/sel.spade:48,9" *)
    logic[42:0] _e_4898;
    (* src = "src/sel.spade:48,14" *)
    logic \a ;
    logic _e_9441;
    logic _e_9443;
    logic _e_9445;
    logic _e_9446;
    (* src = "src/sel.spade:48,35" *)
    logic[1:0] _e_4900;
    (* src = "src/sel.spade:49,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:49,25" *)
    logic[42:0] _e_4906;
    (* src = "src/sel.spade:49,30" *)
    logic a_n1;
    logic _e_9449;
    logic _e_9451;
    logic _e_9453;
    logic _e_9454;
    (* src = "src/sel.spade:49,51" *)
    logic[1:0] _e_4908;
    (* src = "src/sel.spade:49,60" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:49,65" *)
    logic[1:0] _e_4911;
    (* src = "src/sel.spade:49,14" *)
    logic[1:0] _e_4903;
    (* src = "src/sel.spade:47,5" *)
    logic[1:0] _e_4895;
    assign _e_4898 = \m1 [42:0];
    assign \a  = _e_4898[36:36];
    assign _e_9441 = \m1 [43] == 1'd1;
    assign _e_9443 = _e_4898[42:37] == 6'd27;
    localparam[0:0] _e_9444 = 1;
    assign _e_9445 = _e_9443 && _e_9444;
    assign _e_9446 = _e_9441 && _e_9445;
    assign _e_4900 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9447 = 1;
    assign _e_4906 = \m0 [42:0];
    assign a_n1 = _e_4906[36:36];
    assign _e_9449 = \m0 [43] == 1'd1;
    assign _e_9451 = _e_4906[42:37] == 6'd27;
    localparam[0:0] _e_9452 = 1;
    assign _e_9453 = _e_9451 && _e_9452;
    assign _e_9454 = _e_9449 && _e_9453;
    assign _e_4908 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9455 = 1;
    assign _e_4911 = {1'd0, 1'bX};
    always_comb begin
        priority casez ({_e_9454, _e_9455})
            2'b1?: _e_4903 = _e_4908;
            2'b01: _e_4903 = _e_4911;
            2'b?: _e_4903 = 2'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9446, _e_9447})
            2'b1?: _e_4895 = _e_4900;
            2'b01: _e_4895 = _e_4903;
            2'b?: _e_4895 = 2'dx;
        endcase
    end
    assign output__ = _e_4895;
endmodule

module \tta::sel::pick_sel_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::sel::pick_sel_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::sel::pick_sel_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/sel.spade:55,9" *)
    logic[42:0] _e_4916;
    (* src = "src/sel.spade:55,14" *)
    logic[31:0] \a ;
    logic _e_9457;
    logic _e_9459;
    logic _e_9461;
    logic _e_9462;
    (* src = "src/sel.spade:55,35" *)
    logic[32:0] _e_4918;
    (* src = "src/sel.spade:56,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:56,25" *)
    logic[42:0] _e_4924;
    (* src = "src/sel.spade:56,30" *)
    logic[31:0] a_n1;
    logic _e_9465;
    logic _e_9467;
    logic _e_9469;
    logic _e_9470;
    (* src = "src/sel.spade:56,51" *)
    logic[32:0] _e_4926;
    (* src = "src/sel.spade:56,60" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:56,65" *)
    logic[32:0] _e_4929;
    (* src = "src/sel.spade:56,14" *)
    logic[32:0] _e_4921;
    (* src = "src/sel.spade:54,5" *)
    logic[32:0] _e_4913;
    assign _e_4916 = \m1 [42:0];
    assign \a  = _e_4916[36:5];
    assign _e_9457 = \m1 [43] == 1'd1;
    assign _e_9459 = _e_4916[42:37] == 6'd28;
    localparam[0:0] _e_9460 = 1;
    assign _e_9461 = _e_9459 && _e_9460;
    assign _e_9462 = _e_9457 && _e_9461;
    assign _e_4918 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9463 = 1;
    assign _e_4924 = \m0 [42:0];
    assign a_n1 = _e_4924[36:5];
    assign _e_9465 = \m0 [43] == 1'd1;
    assign _e_9467 = _e_4924[42:37] == 6'd28;
    localparam[0:0] _e_9468 = 1;
    assign _e_9469 = _e_9467 && _e_9468;
    assign _e_9470 = _e_9465 && _e_9469;
    assign _e_4926 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9471 = 1;
    assign _e_4929 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9470, _e_9471})
            2'b1?: _e_4921 = _e_4926;
            2'b01: _e_4921 = _e_4929;
            2'b?: _e_4921 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9462, _e_9463})
            2'b1?: _e_4913 = _e_4918;
            2'b01: _e_4913 = _e_4921;
            2'b?: _e_4913 = 33'dx;
        endcase
    end
    assign output__ = _e_4913;
endmodule

module \tta::sel::pick_sel_trigb  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::sel::pick_sel_trigb" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::sel::pick_sel_trigb );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/sel.spade:62,9" *)
    logic[42:0] _e_4934;
    (* src = "src/sel.spade:62,14" *)
    logic[31:0] \a ;
    logic _e_9473;
    logic _e_9475;
    logic _e_9477;
    logic _e_9478;
    (* src = "src/sel.spade:62,36" *)
    logic[32:0] _e_4936;
    (* src = "src/sel.spade:63,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:63,25" *)
    logic[42:0] _e_4942;
    (* src = "src/sel.spade:63,30" *)
    logic[31:0] a_n1;
    logic _e_9481;
    logic _e_9483;
    logic _e_9485;
    logic _e_9486;
    (* src = "src/sel.spade:63,52" *)
    logic[32:0] _e_4944;
    (* src = "src/sel.spade:63,61" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:63,66" *)
    logic[32:0] _e_4947;
    (* src = "src/sel.spade:63,14" *)
    logic[32:0] _e_4939;
    (* src = "src/sel.spade:61,5" *)
    logic[32:0] _e_4931;
    assign _e_4934 = \m1 [42:0];
    assign \a  = _e_4934[36:5];
    assign _e_9473 = \m1 [43] == 1'd1;
    assign _e_9475 = _e_4934[42:37] == 6'd29;
    localparam[0:0] _e_9476 = 1;
    assign _e_9477 = _e_9475 && _e_9476;
    assign _e_9478 = _e_9473 && _e_9477;
    assign _e_4936 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9479 = 1;
    assign _e_4942 = \m0 [42:0];
    assign a_n1 = _e_4942[36:5];
    assign _e_9481 = \m0 [43] == 1'd1;
    assign _e_9483 = _e_4942[42:37] == 6'd29;
    localparam[0:0] _e_9484 = 1;
    assign _e_9485 = _e_9483 && _e_9484;
    assign _e_9486 = _e_9481 && _e_9485;
    assign _e_4944 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9487 = 1;
    assign _e_4947 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9486, _e_9487})
            2'b1?: _e_4939 = _e_4944;
            2'b01: _e_4939 = _e_4947;
            2'b?: _e_4939 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9478, _e_9479})
            2'b1?: _e_4931 = _e_4936;
            2'b01: _e_4931 = _e_4939;
            2'b?: _e_4931 = 33'dx;
        endcase
    end
    assign output__ = _e_4931;
endmodule

module \tta::bootloader::reset_state  (
        output[120:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bootloader::reset_state" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bootloader::reset_state );
        end
    end
    `endif
    (* src = "src/bootloader.spade:61,11" *)
    logic[4:0] _e_4950;
    (* src = "src/bootloader.spade:61,5" *)
    logic[120:0] _e_4949;
    assign _e_4950 = {5'd0};
    localparam[15:0] _e_4951 = 0;
    localparam[15:0] _e_4952 = 0;
    localparam[9:0] _e_4953 = 0;
    localparam[9:0] _e_4954 = 0;
    localparam[31:0] _e_4955 = 32'd0;
    localparam[31:0] _e_4956 = 32'd0;
    assign _e_4949 = {_e_4950, _e_4951, _e_4952, _e_4953, _e_4954, _e_4955, _e_4956};
    assign output__ = _e_4949;
endmodule

module \tta::bootloader::bootloader  (
        input clk_i,
        input rst_i,
        input byte_valid_i,
        input[7:0] byte_i,
        output[88:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bootloader::bootloader" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bootloader::bootloader );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic \byte_valid ;
    assign \byte_valid  = byte_valid_i;
    logic[7:0] \byte ;
    assign \byte  = byte_i;
    (* src = "src/bootloader.spade:71,35" *)
    logic[120:0] _e_4961;
    (* src = "src/bootloader.spade:72,28" *)
    logic[4:0] _e_4966;
    (* src = "src/bootloader.spade:72,15" *)
    logic[5:0] _e_4964;
    (* src = "src/bootloader.spade:73,13" *)
    logic[5:0] _e_4970;
    (* src = "src/bootloader.spade:73,13" *)
    logic _e_4968;
    (* src = "src/bootloader.spade:73,13" *)
    logic[4:0] _e_4969;
    logic _e_9491;
    logic _e_9492;
    (* src = "src/bootloader.spade:73,37" *)
    logic _e_4972;
    (* src = "src/bootloader.spade:74,27" *)
    logic[4:0] _e_4977;
    (* src = "src/bootloader.spade:74,38" *)
    logic[15:0] _e_4978;
    (* src = "src/bootloader.spade:74,46" *)
    logic[15:0] _e_4980;
    (* src = "src/bootloader.spade:74,56" *)
    logic[9:0] _e_4982;
    (* src = "src/bootloader.spade:74,66" *)
    logic[9:0] _e_4984;
    (* src = "src/bootloader.spade:74,74" *)
    logic[31:0] _e_4986;
    (* src = "src/bootloader.spade:74,81" *)
    logic[31:0] _e_4988;
    (* src = "src/bootloader.spade:74,21" *)
    logic[120:0] _e_4976;
    (* src = "src/bootloader.spade:76,21" *)
    logic[120:0] _e_4991;
    (* src = "src/bootloader.spade:73,34" *)
    logic[120:0] _e_4971;
    (* src = "src/bootloader.spade:78,13" *)
    logic[5:0] _e_4994;
    (* src = "src/bootloader.spade:78,13" *)
    logic _e_4992;
    (* src = "src/bootloader.spade:78,13" *)
    logic[4:0] _e_4993;
    logic _e_9496;
    logic _e_9497;
    (* src = "src/bootloader.spade:78,37" *)
    logic _e_4996;
    (* src = "src/bootloader.spade:79,27" *)
    logic[4:0] _e_5001;
    (* src = "src/bootloader.spade:79,37" *)
    logic[15:0] _e_5002;
    (* src = "src/bootloader.spade:79,45" *)
    logic[15:0] _e_5004;
    (* src = "src/bootloader.spade:79,55" *)
    logic[9:0] _e_5006;
    (* src = "src/bootloader.spade:79,65" *)
    logic[9:0] _e_5008;
    (* src = "src/bootloader.spade:79,73" *)
    logic[31:0] _e_5010;
    (* src = "src/bootloader.spade:79,80" *)
    logic[31:0] _e_5012;
    (* src = "src/bootloader.spade:79,21" *)
    logic[120:0] _e_5000;
    (* src = "src/bootloader.spade:81,21" *)
    logic[120:0] _e_5015;
    (* src = "src/bootloader.spade:78,34" *)
    logic[120:0] _e_4995;
    (* src = "src/bootloader.spade:83,13" *)
    logic[5:0] _e_5018;
    (* src = "src/bootloader.spade:83,13" *)
    logic _e_5016;
    (* src = "src/bootloader.spade:83,13" *)
    logic[4:0] _e_5017;
    logic _e_9501;
    logic _e_9502;
    (* src = "src/bootloader.spade:83,39" *)
    logic[4:0] _e_5020;
    logic[15:0] _e_5021;
    (* src = "src/bootloader.spade:83,61" *)
    logic[15:0] _e_5023;
    (* src = "src/bootloader.spade:83,71" *)
    logic[9:0] _e_5025;
    (* src = "src/bootloader.spade:83,81" *)
    logic[9:0] _e_5027;
    (* src = "src/bootloader.spade:83,89" *)
    logic[31:0] _e_5029;
    (* src = "src/bootloader.spade:83,96" *)
    logic[31:0] _e_5031;
    (* src = "src/bootloader.spade:83,33" *)
    logic[120:0] _e_5019;
    (* src = "src/bootloader.spade:84,13" *)
    logic[5:0] _e_5035;
    (* src = "src/bootloader.spade:84,13" *)
    logic _e_5033;
    (* src = "src/bootloader.spade:84,13" *)
    logic[4:0] _e_5034;
    logic _e_9506;
    logic _e_9507;
    logic[15:0] _e_5039;
    (* src = "src/bootloader.spade:85,29" *)
    logic[15:0] _e_5038;
    (* src = "src/bootloader.spade:85,49" *)
    logic[15:0] _e_5042;
    (* src = "src/bootloader.spade:85,29" *)
    logic[15:0] \v ;
    (* src = "src/bootloader.spade:86,24" *)
    logic _e_5046;
    (* src = "src/bootloader.spade:87,31" *)
    logic[4:0] _e_5051;
    (* src = "src/bootloader.spade:87,39" *)
    logic[15:0] _e_5052;
    (* src = "src/bootloader.spade:87,49" *)
    logic[15:0] _e_5054;
    (* src = "src/bootloader.spade:87,59" *)
    logic[9:0] _e_5056;
    (* src = "src/bootloader.spade:87,69" *)
    logic[9:0] _e_5058;
    (* src = "src/bootloader.spade:87,77" *)
    logic[31:0] _e_5060;
    (* src = "src/bootloader.spade:87,84" *)
    logic[31:0] _e_5062;
    (* src = "src/bootloader.spade:87,25" *)
    logic[120:0] _e_5050;
    (* src = "src/bootloader.spade:89,25" *)
    logic[120:0] _e_5065;
    (* src = "src/bootloader.spade:86,21" *)
    logic[120:0] _e_5045;
    (* src = "src/bootloader.spade:92,13" *)
    logic[5:0] _e_5068;
    (* src = "src/bootloader.spade:92,13" *)
    logic _e_5066;
    (* src = "src/bootloader.spade:92,13" *)
    logic[4:0] _e_5067;
    logic _e_9511;
    logic _e_9512;
    (* src = "src/bootloader.spade:92,37" *)
    logic[4:0] _e_5070;
    (* src = "src/bootloader.spade:92,45" *)
    logic[15:0] _e_5071;
    logic[15:0] _e_5073;
    (* src = "src/bootloader.spade:92,65" *)
    logic[9:0] _e_5075;
    (* src = "src/bootloader.spade:92,75" *)
    logic[9:0] _e_5077;
    (* src = "src/bootloader.spade:92,83" *)
    logic[31:0] _e_5079;
    (* src = "src/bootloader.spade:92,90" *)
    logic[31:0] _e_5081;
    (* src = "src/bootloader.spade:92,31" *)
    logic[120:0] _e_5069;
    (* src = "src/bootloader.spade:93,13" *)
    logic[5:0] _e_5085;
    (* src = "src/bootloader.spade:93,13" *)
    logic _e_5083;
    (* src = "src/bootloader.spade:93,13" *)
    logic[4:0] _e_5084;
    logic _e_9516;
    logic _e_9517;
    logic[15:0] _e_5089;
    (* src = "src/bootloader.spade:94,29" *)
    logic[15:0] _e_5088;
    (* src = "src/bootloader.spade:94,49" *)
    logic[15:0] _e_5092;
    (* src = "src/bootloader.spade:94,29" *)
    logic[15:0] \n ;
    (* src = "src/bootloader.spade:95,40" *)
    logic _e_5096;
    (* src = "src/bootloader.spade:95,37" *)
    logic[15:0] \n_clamped ;
    (* src = "src/bootloader.spade:96,27" *)
    logic[4:0] _e_5105;
    (* src = "src/bootloader.spade:96,35" *)
    logic[15:0] _e_5106;
    (* src = "src/bootloader.spade:96,43" *)
    logic[15:0] _e_5108;
    (* src = "src/bootloader.spade:96,61" *)
    logic[9:0] _e_5110;
    (* src = "src/bootloader.spade:96,71" *)
    logic[9:0] _e_5112;
    (* src = "src/bootloader.spade:96,79" *)
    logic[31:0] _e_5114;
    (* src = "src/bootloader.spade:96,86" *)
    logic[31:0] _e_5116;
    (* src = "src/bootloader.spade:96,21" *)
    logic[120:0] _e_5104;
    (* src = "src/bootloader.spade:98,13" *)
    logic[5:0] _e_5120;
    (* src = "src/bootloader.spade:98,13" *)
    logic _e_5118;
    (* src = "src/bootloader.spade:98,13" *)
    logic[4:0] _e_5119;
    logic _e_9521;
    logic _e_9522;
    (* src = "src/bootloader.spade:98,37" *)
    logic[4:0] _e_5122;
    (* src = "src/bootloader.spade:98,45" *)
    logic[15:0] _e_5123;
    (* src = "src/bootloader.spade:98,53" *)
    logic[15:0] _e_5125;
    logic[9:0] _e_5127;
    (* src = "src/bootloader.spade:98,75" *)
    logic[9:0] _e_5129;
    (* src = "src/bootloader.spade:98,83" *)
    logic[31:0] _e_5131;
    (* src = "src/bootloader.spade:98,90" *)
    logic[31:0] _e_5133;
    (* src = "src/bootloader.spade:98,31" *)
    logic[120:0] _e_5121;
    (* src = "src/bootloader.spade:99,13" *)
    logic[5:0] _e_5137;
    (* src = "src/bootloader.spade:99,13" *)
    logic _e_5135;
    (* src = "src/bootloader.spade:99,13" *)
    logic[4:0] _e_5136;
    logic _e_9526;
    logic _e_9527;
    logic[9:0] _e_5141;
    (* src = "src/bootloader.spade:100,29" *)
    logic[9:0] _e_5140;
    (* src = "src/bootloader.spade:100,49" *)
    logic[9:0] _e_5144;
    (* src = "src/bootloader.spade:100,29" *)
    logic[9:0] \e ;
    (* src = "src/bootloader.spade:101,24" *)
    logic[15:0] _e_5149;
    (* src = "src/bootloader.spade:101,24" *)
    logic _e_5148;
    (* src = "src/bootloader.spade:102,31" *)
    logic[4:0] _e_5154;
    (* src = "src/bootloader.spade:102,41" *)
    logic[15:0] _e_5155;
    (* src = "src/bootloader.spade:102,49" *)
    logic[15:0] _e_5157;
    (* src = "src/bootloader.spade:102,59" *)
    logic[9:0] _e_5159;
    (* src = "src/bootloader.spade:102,69" *)
    logic[9:0] _e_5161;
    (* src = "src/bootloader.spade:102,77" *)
    logic[31:0] _e_5163;
    (* src = "src/bootloader.spade:102,84" *)
    logic[31:0] _e_5165;
    (* src = "src/bootloader.spade:102,25" *)
    logic[120:0] _e_5153;
    (* src = "src/bootloader.spade:104,31" *)
    logic[4:0] _e_5169;
    (* src = "src/bootloader.spade:104,42" *)
    logic[15:0] _e_5170;
    (* src = "src/bootloader.spade:104,50" *)
    logic[15:0] _e_5172;
    (* src = "src/bootloader.spade:104,60" *)
    logic[9:0] _e_5174;
    (* src = "src/bootloader.spade:104,70" *)
    logic[9:0] _e_5176;
    (* src = "src/bootloader.spade:104,78" *)
    logic[31:0] _e_5178;
    (* src = "src/bootloader.spade:104,85" *)
    logic[31:0] _e_5180;
    (* src = "src/bootloader.spade:104,25" *)
    logic[120:0] _e_5168;
    (* src = "src/bootloader.spade:101,21" *)
    logic[120:0] _e_5147;
    (* src = "src/bootloader.spade:109,13" *)
    logic[5:0] _e_5184;
    (* src = "src/bootloader.spade:109,13" *)
    logic _e_5182;
    (* src = "src/bootloader.spade:109,13" *)
    logic[4:0] _e_5183;
    logic _e_9531;
    logic _e_9532;
    (* src = "src/bootloader.spade:109,40" *)
    logic[4:0] _e_5186;
    (* src = "src/bootloader.spade:109,51" *)
    logic[15:0] _e_5187;
    (* src = "src/bootloader.spade:109,59" *)
    logic[15:0] _e_5189;
    (* src = "src/bootloader.spade:109,69" *)
    logic[9:0] _e_5191;
    (* src = "src/bootloader.spade:109,79" *)
    logic[9:0] _e_5193;
    logic[31:0] _e_5197;
    (* src = "src/bootloader.spade:109,115" *)
    logic[31:0] _e_5200;
    (* src = "src/bootloader.spade:109,114" *)
    logic[31:0] _e_5199;
    (* src = "src/bootloader.spade:109,93" *)
    logic[31:0] _e_5196;
    (* src = "src/bootloader.spade:109,87" *)
    logic[31:0] _e_5195;
    (* src = "src/bootloader.spade:109,137" *)
    logic[31:0] _e_5203;
    (* src = "src/bootloader.spade:109,34" *)
    logic[120:0] _e_5185;
    (* src = "src/bootloader.spade:110,13" *)
    logic[5:0] _e_5207;
    (* src = "src/bootloader.spade:110,13" *)
    logic _e_5205;
    (* src = "src/bootloader.spade:110,13" *)
    logic[4:0] _e_5206;
    logic _e_9536;
    logic _e_9537;
    (* src = "src/bootloader.spade:110,40" *)
    logic[4:0] _e_5209;
    (* src = "src/bootloader.spade:110,51" *)
    logic[15:0] _e_5210;
    (* src = "src/bootloader.spade:110,59" *)
    logic[15:0] _e_5212;
    (* src = "src/bootloader.spade:110,69" *)
    logic[9:0] _e_5214;
    (* src = "src/bootloader.spade:110,79" *)
    logic[9:0] _e_5216;
    logic[31:0] _e_5221;
    (* src = "src/bootloader.spade:110,93" *)
    logic[31:0] _e_5220;
    (* src = "src/bootloader.spade:110,115" *)
    logic[31:0] _e_5225;
    (* src = "src/bootloader.spade:110,114" *)
    logic[31:0] _e_5224;
    (* src = "src/bootloader.spade:110,93" *)
    logic[31:0] _e_5219;
    (* src = "src/bootloader.spade:110,87" *)
    logic[31:0] _e_5218;
    (* src = "src/bootloader.spade:110,137" *)
    logic[31:0] _e_5228;
    (* src = "src/bootloader.spade:110,34" *)
    logic[120:0] _e_5208;
    (* src = "src/bootloader.spade:111,13" *)
    logic[5:0] _e_5232;
    (* src = "src/bootloader.spade:111,13" *)
    logic _e_5230;
    (* src = "src/bootloader.spade:111,13" *)
    logic[4:0] _e_5231;
    logic _e_9541;
    logic _e_9542;
    (* src = "src/bootloader.spade:111,40" *)
    logic[4:0] _e_5234;
    (* src = "src/bootloader.spade:111,51" *)
    logic[15:0] _e_5235;
    (* src = "src/bootloader.spade:111,59" *)
    logic[15:0] _e_5237;
    (* src = "src/bootloader.spade:111,69" *)
    logic[9:0] _e_5239;
    (* src = "src/bootloader.spade:111,79" *)
    logic[9:0] _e_5241;
    logic[31:0] _e_5246;
    (* src = "src/bootloader.spade:111,93" *)
    logic[31:0] _e_5245;
    (* src = "src/bootloader.spade:111,115" *)
    logic[31:0] _e_5250;
    (* src = "src/bootloader.spade:111,114" *)
    logic[31:0] _e_5249;
    (* src = "src/bootloader.spade:111,93" *)
    logic[31:0] _e_5244;
    (* src = "src/bootloader.spade:111,87" *)
    logic[31:0] _e_5243;
    (* src = "src/bootloader.spade:111,137" *)
    logic[31:0] _e_5253;
    (* src = "src/bootloader.spade:111,34" *)
    logic[120:0] _e_5233;
    (* src = "src/bootloader.spade:112,13" *)
    logic[5:0] _e_5257;
    (* src = "src/bootloader.spade:112,13" *)
    logic _e_5255;
    (* src = "src/bootloader.spade:112,13" *)
    logic[4:0] _e_5256;
    logic _e_9546;
    logic _e_9547;
    (* src = "src/bootloader.spade:112,40" *)
    logic[4:0] _e_5259;
    (* src = "src/bootloader.spade:112,51" *)
    logic[15:0] _e_5260;
    (* src = "src/bootloader.spade:112,59" *)
    logic[15:0] _e_5262;
    (* src = "src/bootloader.spade:112,69" *)
    logic[9:0] _e_5264;
    (* src = "src/bootloader.spade:112,79" *)
    logic[9:0] _e_5266;
    logic[31:0] _e_5271;
    (* src = "src/bootloader.spade:112,93" *)
    logic[31:0] _e_5270;
    (* src = "src/bootloader.spade:112,115" *)
    logic[31:0] _e_5275;
    (* src = "src/bootloader.spade:112,114" *)
    logic[31:0] _e_5274;
    (* src = "src/bootloader.spade:112,93" *)
    logic[31:0] _e_5269;
    (* src = "src/bootloader.spade:112,87" *)
    logic[31:0] _e_5268;
    (* src = "src/bootloader.spade:112,137" *)
    logic[31:0] _e_5278;
    (* src = "src/bootloader.spade:112,34" *)
    logic[120:0] _e_5258;
    (* src = "src/bootloader.spade:115,13" *)
    logic[5:0] _e_5282;
    (* src = "src/bootloader.spade:115,13" *)
    logic _e_5280;
    (* src = "src/bootloader.spade:115,13" *)
    logic[4:0] _e_5281;
    logic _e_9551;
    logic _e_9552;
    (* src = "src/bootloader.spade:115,40" *)
    logic[4:0] _e_5284;
    (* src = "src/bootloader.spade:115,51" *)
    logic[15:0] _e_5285;
    (* src = "src/bootloader.spade:115,59" *)
    logic[15:0] _e_5287;
    (* src = "src/bootloader.spade:115,69" *)
    logic[9:0] _e_5289;
    (* src = "src/bootloader.spade:115,79" *)
    logic[9:0] _e_5291;
    (* src = "src/bootloader.spade:115,87" *)
    logic[31:0] _e_5293;
    logic[31:0] _e_5297;
    (* src = "src/bootloader.spade:115,123" *)
    logic[31:0] _e_5300;
    (* src = "src/bootloader.spade:115,122" *)
    logic[31:0] _e_5299;
    (* src = "src/bootloader.spade:115,100" *)
    logic[31:0] _e_5296;
    (* src = "src/bootloader.spade:115,94" *)
    logic[31:0] _e_5295;
    (* src = "src/bootloader.spade:115,34" *)
    logic[120:0] _e_5283;
    (* src = "src/bootloader.spade:116,13" *)
    logic[5:0] _e_5305;
    (* src = "src/bootloader.spade:116,13" *)
    logic _e_5303;
    (* src = "src/bootloader.spade:116,13" *)
    logic[4:0] _e_5304;
    logic _e_9556;
    logic _e_9557;
    (* src = "src/bootloader.spade:116,40" *)
    logic[4:0] _e_5307;
    (* src = "src/bootloader.spade:116,51" *)
    logic[15:0] _e_5308;
    (* src = "src/bootloader.spade:116,59" *)
    logic[15:0] _e_5310;
    (* src = "src/bootloader.spade:116,69" *)
    logic[9:0] _e_5312;
    (* src = "src/bootloader.spade:116,79" *)
    logic[9:0] _e_5314;
    (* src = "src/bootloader.spade:116,87" *)
    logic[31:0] _e_5316;
    logic[31:0] _e_5321;
    (* src = "src/bootloader.spade:116,100" *)
    logic[31:0] _e_5320;
    (* src = "src/bootloader.spade:116,123" *)
    logic[31:0] _e_5325;
    (* src = "src/bootloader.spade:116,122" *)
    logic[31:0] _e_5324;
    (* src = "src/bootloader.spade:116,100" *)
    logic[31:0] _e_5319;
    (* src = "src/bootloader.spade:116,94" *)
    logic[31:0] _e_5318;
    (* src = "src/bootloader.spade:116,34" *)
    logic[120:0] _e_5306;
    (* src = "src/bootloader.spade:117,13" *)
    logic[5:0] _e_5330;
    (* src = "src/bootloader.spade:117,13" *)
    logic _e_5328;
    (* src = "src/bootloader.spade:117,13" *)
    logic[4:0] _e_5329;
    logic _e_9561;
    logic _e_9562;
    (* src = "src/bootloader.spade:117,40" *)
    logic[4:0] _e_5332;
    (* src = "src/bootloader.spade:117,51" *)
    logic[15:0] _e_5333;
    (* src = "src/bootloader.spade:117,59" *)
    logic[15:0] _e_5335;
    (* src = "src/bootloader.spade:117,69" *)
    logic[9:0] _e_5337;
    (* src = "src/bootloader.spade:117,79" *)
    logic[9:0] _e_5339;
    (* src = "src/bootloader.spade:117,87" *)
    logic[31:0] _e_5341;
    logic[31:0] _e_5346;
    (* src = "src/bootloader.spade:117,100" *)
    logic[31:0] _e_5345;
    (* src = "src/bootloader.spade:117,123" *)
    logic[31:0] _e_5350;
    (* src = "src/bootloader.spade:117,122" *)
    logic[31:0] _e_5349;
    (* src = "src/bootloader.spade:117,100" *)
    logic[31:0] _e_5344;
    (* src = "src/bootloader.spade:117,94" *)
    logic[31:0] _e_5343;
    (* src = "src/bootloader.spade:117,34" *)
    logic[120:0] _e_5331;
    (* src = "src/bootloader.spade:118,13" *)
    logic[5:0] _e_5355;
    (* src = "src/bootloader.spade:118,13" *)
    logic _e_5353;
    (* src = "src/bootloader.spade:118,13" *)
    logic[4:0] _e_5354;
    logic _e_9566;
    logic _e_9567;
    (* src = "src/bootloader.spade:118,40" *)
    logic[4:0] _e_5357;
    (* src = "src/bootloader.spade:118,52" *)
    logic[15:0] _e_5358;
    (* src = "src/bootloader.spade:118,60" *)
    logic[15:0] _e_5360;
    (* src = "src/bootloader.spade:118,70" *)
    logic[9:0] _e_5362;
    (* src = "src/bootloader.spade:118,80" *)
    logic[9:0] _e_5364;
    (* src = "src/bootloader.spade:118,88" *)
    logic[31:0] _e_5366;
    logic[31:0] _e_5371;
    (* src = "src/bootloader.spade:118,101" *)
    logic[31:0] _e_5370;
    (* src = "src/bootloader.spade:118,123" *)
    logic[31:0] _e_5375;
    (* src = "src/bootloader.spade:118,122" *)
    logic[31:0] _e_5374;
    (* src = "src/bootloader.spade:118,101" *)
    logic[31:0] _e_5369;
    (* src = "src/bootloader.spade:118,95" *)
    logic[31:0] _e_5368;
    (* src = "src/bootloader.spade:118,34" *)
    logic[120:0] _e_5356;
    (* src = "src/bootloader.spade:122,13" *)
    logic[5:0] _e_5380;
    (* src = "src/bootloader.spade:122,13" *)
    logic \_ ;
    (* src = "src/bootloader.spade:122,13" *)
    logic[4:0] _e_5379;
    logic _e_9571;
    logic _e_9572;
    (* src = "src/bootloader.spade:123,34" *)
    logic[9:0] _e_5384;
    (* src = "src/bootloader.spade:123,34" *)
    logic[10:0] _e_5383;
    (* src = "src/bootloader.spade:123,28" *)
    logic[9:0] \pcw1 ;
    (* src = "src/bootloader.spade:124,34" *)
    logic[15:0] _e_5390;
    (* src = "src/bootloader.spade:124,34" *)
    logic[16:0] _e_5389;
    (* src = "src/bootloader.spade:124,28" *)
    logic[15:0] \n1 ;
    (* src = "src/bootloader.spade:125,31" *)
    logic _e_5395;
    (* src = "src/bootloader.spade:126,21" *)
    logic[4:0] _e_5399;
    (* src = "src/bootloader.spade:128,21" *)
    logic[4:0] _e_5401;
    (* src = "src/bootloader.spade:125,28" *)
    logic[4:0] \next ;
    (* src = "src/bootloader.spade:130,29" *)
    logic[15:0] _e_5405;
    (* src = "src/bootloader.spade:130,41" *)
    logic[9:0] _e_5408;
    (* src = "src/bootloader.spade:130,57" *)
    logic[31:0] _e_5411;
    (* src = "src/bootloader.spade:130,64" *)
    logic[31:0] _e_5413;
    (* src = "src/bootloader.spade:130,17" *)
    logic[120:0] _e_5403;
    (* src = "src/bootloader.spade:134,13" *)
    logic[5:0] _e_5417;
    (* src = "src/bootloader.spade:134,13" *)
    logic __n1;
    (* src = "src/bootloader.spade:134,13" *)
    logic[4:0] _e_5416;
    logic _e_9576;
    logic _e_9577;
    (* src = "src/bootloader.spade:137,13" *)
    logic[5:0] _e_5421;
    (* src = "src/bootloader.spade:137,13" *)
    logic _e_5419;
    (* src = "src/bootloader.spade:137,13" *)
    logic[4:0] __n2;
    logic _e_9579;
    logic _e_9581;
    (* src = "src/bootloader.spade:72,9" *)
    logic[120:0] _e_4963;
    (* src = "src/bootloader.spade:71,14" *)
    reg[120:0] \st ;
    (* src = "src/bootloader.spade:141,47" *)
    logic[4:0] _e_5424;
    (* src = "src/bootloader.spade:142,9" *)
    logic[4:0] _e_5426;
    logic _e_9583;
    (* src = "src/bootloader.spade:142,29" *)
    logic[9:0] _e_5429;
    (* src = "src/bootloader.spade:142,24" *)
    logic[10:0] _e_5428;
    (* src = "src/bootloader.spade:142,43" *)
    logic[31:0] _e_5432;
    (* src = "src/bootloader.spade:142,38" *)
    logic[32:0] _e_5431;
    (* src = "src/bootloader.spade:142,56" *)
    logic[31:0] _e_5435;
    (* src = "src/bootloader.spade:142,51" *)
    logic[32:0] _e_5434;
    (* src = "src/bootloader.spade:142,23" *)
    logic[76:0] _e_5427;
    (* src = "src/bootloader.spade:143,9" *)
    logic[4:0] __n3;
    (* src = "src/bootloader.spade:143,15" *)
    logic[10:0] _e_5439;
    (* src = "src/bootloader.spade:143,21" *)
    logic[32:0] _e_5440;
    (* src = "src/bootloader.spade:143,27" *)
    logic[32:0] _e_5441;
    (* src = "src/bootloader.spade:143,14" *)
    logic[76:0] _e_5438;
    (* src = "src/bootloader.spade:141,41" *)
    logic[76:0] _e_5445;
    (* src = "src/bootloader.spade:141,9" *)
    logic[10:0] \wr_addr ;
    (* src = "src/bootloader.spade:141,9" *)
    logic[32:0] \wr_slot0 ;
    (* src = "src/bootloader.spade:141,9" *)
    logic[32:0] \wr_slot1 ;
    (* src = "src/bootloader.spade:146,43" *)
    logic[4:0] _e_5447;
    (* src = "src/bootloader.spade:147,9" *)
    logic[4:0] _e_5449;
    logic _e_9586;
    (* src = "src/bootloader.spade:147,34" *)
    logic[9:0] _e_5453;
    (* src = "src/bootloader.spade:147,29" *)
    logic[10:0] _e_5452;
    (* src = "src/bootloader.spade:147,21" *)
    logic[11:0] _e_5450;
    (* src = "src/bootloader.spade:148,9" *)
    logic[4:0] __n4;
    (* src = "src/bootloader.spade:148,21" *)
    logic[10:0] _e_5458;
    (* src = "src/bootloader.spade:148,14" *)
    logic[11:0] _e_5456;
    (* src = "src/bootloader.spade:146,37" *)
    logic[11:0] _e_5461;
    (* src = "src/bootloader.spade:146,9" *)
    logic \boot_active ;
    (* src = "src/bootloader.spade:146,9" *)
    logic[10:0] \release_pc ;
    (* src = "src/bootloader.spade:151,5" *)
    logic[88:0] _e_5462;
    (* src = "src/bootloader.spade:71,35" *)
    \tta::bootloader::reset_state  reset_state_0(.output__(_e_4961));
    assign _e_4966 = \st [120:116];
    assign _e_4964 = {\byte_valid , _e_4966};
    assign _e_4970 = _e_4964;
    assign _e_4968 = _e_4964[5];
    assign _e_4969 = _e_4964[4:0];
    assign _e_9491 = _e_4969[4:0] == 5'd0;
    assign _e_9492 = _e_4968 && _e_9491;
    localparam[7:0] _e_4974 = 66;
    assign _e_4972 = \byte  == _e_4974;
    assign _e_4977 = {5'd1};
    assign _e_4978 = \st [115:100];
    assign _e_4980 = \st [99:84];
    assign _e_4982 = \st [83:74];
    assign _e_4984 = \st [73:64];
    assign _e_4986 = \st [63:32];
    assign _e_4988 = \st [31:0];
    assign _e_4976 = {_e_4977, _e_4978, _e_4980, _e_4982, _e_4984, _e_4986, _e_4988};
    (* src = "src/bootloader.spade:76,21" *)
    \tta::bootloader::reset_state  reset_state_1(.output__(_e_4991));
    assign _e_4971 = _e_4972 ? _e_4976 : _e_4991;
    assign _e_4994 = _e_4964;
    assign _e_4992 = _e_4964[5];
    assign _e_4993 = _e_4964[4:0];
    assign _e_9496 = _e_4993[4:0] == 5'd1;
    assign _e_9497 = _e_4992 && _e_9496;
    localparam[7:0] _e_4998 = 84;
    assign _e_4996 = \byte  == _e_4998;
    assign _e_5001 = {5'd2};
    assign _e_5002 = \st [115:100];
    assign _e_5004 = \st [99:84];
    assign _e_5006 = \st [83:74];
    assign _e_5008 = \st [73:64];
    assign _e_5010 = \st [63:32];
    assign _e_5012 = \st [31:0];
    assign _e_5000 = {_e_5001, _e_5002, _e_5004, _e_5006, _e_5008, _e_5010, _e_5012};
    (* src = "src/bootloader.spade:81,21" *)
    \tta::bootloader::reset_state  reset_state_2(.output__(_e_5015));
    assign _e_4995 = _e_4996 ? _e_5000 : _e_5015;
    assign _e_5018 = _e_4964;
    assign _e_5016 = _e_4964[5];
    assign _e_5017 = _e_4964[4:0];
    assign _e_9501 = _e_5017[4:0] == 5'd2;
    assign _e_9502 = _e_5016 && _e_9501;
    assign _e_5020 = {5'd3};
    assign _e_5021 = {8'b0, \byte };
    assign _e_5023 = \st [99:84];
    assign _e_5025 = \st [83:74];
    assign _e_5027 = \st [73:64];
    assign _e_5029 = \st [63:32];
    assign _e_5031 = \st [31:0];
    assign _e_5019 = {_e_5020, _e_5021, _e_5023, _e_5025, _e_5027, _e_5029, _e_5031};
    assign _e_5035 = _e_4964;
    assign _e_5033 = _e_4964[5];
    assign _e_5034 = _e_4964[4:0];
    assign _e_9506 = _e_5034[4:0] == 5'd3;
    assign _e_9507 = _e_5033 && _e_9506;
    assign _e_5039 = {8'b0, \byte };
    localparam[15:0] _e_5041 = 8;
    assign _e_5038 = _e_5039 << _e_5041;
    assign _e_5042 = \st [115:100];
    assign \v  = _e_5038 | _e_5042;
    localparam[15:0] _e_5048 = 1;
    assign _e_5046 = \v  == _e_5048;
    assign _e_5051 = {5'd4};
    assign _e_5052 = \v [15:0];
    assign _e_5054 = \st [99:84];
    assign _e_5056 = \st [83:74];
    assign _e_5058 = \st [73:64];
    assign _e_5060 = \st [63:32];
    assign _e_5062 = \st [31:0];
    assign _e_5050 = {_e_5051, _e_5052, _e_5054, _e_5056, _e_5058, _e_5060, _e_5062};
    (* src = "src/bootloader.spade:89,25" *)
    \tta::bootloader::reset_state  reset_state_3(.output__(_e_5065));
    assign _e_5045 = _e_5046 ? _e_5050 : _e_5065;
    assign _e_5068 = _e_4964;
    assign _e_5066 = _e_4964[5];
    assign _e_5067 = _e_4964[4:0];
    assign _e_9511 = _e_5067[4:0] == 5'd4;
    assign _e_9512 = _e_5066 && _e_9511;
    assign _e_5070 = {5'd5};
    assign _e_5071 = \st [115:100];
    assign _e_5073 = {8'b0, \byte };
    assign _e_5075 = \st [83:74];
    assign _e_5077 = \st [73:64];
    assign _e_5079 = \st [63:32];
    assign _e_5081 = \st [31:0];
    assign _e_5069 = {_e_5070, _e_5071, _e_5073, _e_5075, _e_5077, _e_5079, _e_5081};
    assign _e_5085 = _e_4964;
    assign _e_5083 = _e_4964[5];
    assign _e_5084 = _e_4964[4:0];
    assign _e_9516 = _e_5084[4:0] == 5'd5;
    assign _e_9517 = _e_5083 && _e_9516;
    assign _e_5089 = {8'b0, \byte };
    localparam[15:0] _e_5091 = 8;
    assign _e_5088 = _e_5089 << _e_5091;
    assign _e_5092 = \st [99:84];
    assign \n  = _e_5088 | _e_5092;
    localparam[15:0] _e_5098 = 1024;
    assign _e_5096 = \n  > _e_5098;
    localparam[15:0] _e_5100 = 1024;
    assign \n_clamped  = _e_5096 ? _e_5100 : \n ;
    assign _e_5105 = {5'd6};
    assign _e_5106 = \st [115:100];
    assign _e_5108 = \n_clamped [15:0];
    assign _e_5110 = \st [83:74];
    assign _e_5112 = \st [73:64];
    assign _e_5114 = \st [63:32];
    assign _e_5116 = \st [31:0];
    assign _e_5104 = {_e_5105, _e_5106, _e_5108, _e_5110, _e_5112, _e_5114, _e_5116};
    assign _e_5120 = _e_4964;
    assign _e_5118 = _e_4964[5];
    assign _e_5119 = _e_4964[4:0];
    assign _e_9521 = _e_5119[4:0] == 5'd6;
    assign _e_9522 = _e_5118 && _e_9521;
    assign _e_5122 = {5'd7};
    assign _e_5123 = \st [115:100];
    assign _e_5125 = \st [99:84];
    assign _e_5127 = {2'b0, \byte };
    assign _e_5129 = \st [73:64];
    assign _e_5131 = \st [63:32];
    assign _e_5133 = \st [31:0];
    assign _e_5121 = {_e_5122, _e_5123, _e_5125, _e_5127, _e_5129, _e_5131, _e_5133};
    assign _e_5137 = _e_4964;
    assign _e_5135 = _e_4964[5];
    assign _e_5136 = _e_4964[4:0];
    assign _e_9526 = _e_5136[4:0] == 5'd7;
    assign _e_9527 = _e_5135 && _e_9526;
    assign _e_5141 = {2'b0, \byte };
    localparam[9:0] _e_5143 = 8;
    assign _e_5140 = _e_5141 << _e_5143;
    assign _e_5144 = \st [83:74];
    assign \e  = _e_5140 | _e_5144;
    assign _e_5149 = \st [99:84];
    localparam[15:0] _e_5151 = 0;
    assign _e_5148 = _e_5149 == _e_5151;
    assign _e_5154 = {5'd17};
    assign _e_5155 = \st [115:100];
    assign _e_5157 = \st [99:84];
    assign _e_5159 = \e [9:0];
    assign _e_5161 = \st [73:64];
    assign _e_5163 = \st [63:32];
    assign _e_5165 = \st [31:0];
    assign _e_5153 = {_e_5154, _e_5155, _e_5157, _e_5159, _e_5161, _e_5163, _e_5165};
    assign _e_5169 = {5'd8};
    assign _e_5170 = \st [115:100];
    assign _e_5172 = \st [99:84];
    assign _e_5174 = \e [9:0];
    assign _e_5176 = \st [73:64];
    assign _e_5178 = \st [63:32];
    assign _e_5180 = \st [31:0];
    assign _e_5168 = {_e_5169, _e_5170, _e_5172, _e_5174, _e_5176, _e_5178, _e_5180};
    assign _e_5147 = _e_5148 ? _e_5153 : _e_5168;
    assign _e_5184 = _e_4964;
    assign _e_5182 = _e_4964[5];
    assign _e_5183 = _e_4964[4:0];
    assign _e_9531 = _e_5183[4:0] == 5'd8;
    assign _e_9532 = _e_5182 && _e_9531;
    assign _e_5186 = {5'd9};
    assign _e_5187 = \st [115:100];
    assign _e_5189 = \st [99:84];
    assign _e_5191 = \st [83:74];
    assign _e_5193 = \st [73:64];
    assign _e_5197 = {24'b0, \byte };
    assign _e_5200 = \st [63:32];
    localparam[31:0] _e_5202 = 32'd4294967040;
    assign _e_5199 = _e_5200 & _e_5202;
    assign _e_5196 = _e_5197 | _e_5199;
    assign _e_5195 = _e_5196[31:0];
    assign _e_5203 = \st [31:0];
    assign _e_5185 = {_e_5186, _e_5187, _e_5189, _e_5191, _e_5193, _e_5195, _e_5203};
    assign _e_5207 = _e_4964;
    assign _e_5205 = _e_4964[5];
    assign _e_5206 = _e_4964[4:0];
    assign _e_9536 = _e_5206[4:0] == 5'd9;
    assign _e_9537 = _e_5205 && _e_9536;
    assign _e_5209 = {5'd10};
    assign _e_5210 = \st [115:100];
    assign _e_5212 = \st [99:84];
    assign _e_5214 = \st [83:74];
    assign _e_5216 = \st [73:64];
    assign _e_5221 = {24'b0, \byte };
    localparam[31:0] _e_5223 = 32'd8;
    assign _e_5220 = _e_5221 << _e_5223;
    assign _e_5225 = \st [63:32];
    localparam[31:0] _e_5227 = 32'd4294902015;
    assign _e_5224 = _e_5225 & _e_5227;
    assign _e_5219 = _e_5220 | _e_5224;
    assign _e_5218 = _e_5219[31:0];
    assign _e_5228 = \st [31:0];
    assign _e_5208 = {_e_5209, _e_5210, _e_5212, _e_5214, _e_5216, _e_5218, _e_5228};
    assign _e_5232 = _e_4964;
    assign _e_5230 = _e_4964[5];
    assign _e_5231 = _e_4964[4:0];
    assign _e_9541 = _e_5231[4:0] == 5'd10;
    assign _e_9542 = _e_5230 && _e_9541;
    assign _e_5234 = {5'd11};
    assign _e_5235 = \st [115:100];
    assign _e_5237 = \st [99:84];
    assign _e_5239 = \st [83:74];
    assign _e_5241 = \st [73:64];
    assign _e_5246 = {24'b0, \byte };
    localparam[31:0] _e_5248 = 32'd16;
    assign _e_5245 = _e_5246 << _e_5248;
    assign _e_5250 = \st [63:32];
    localparam[31:0] _e_5252 = 32'd4278255615;
    assign _e_5249 = _e_5250 & _e_5252;
    assign _e_5244 = _e_5245 | _e_5249;
    assign _e_5243 = _e_5244[31:0];
    assign _e_5253 = \st [31:0];
    assign _e_5233 = {_e_5234, _e_5235, _e_5237, _e_5239, _e_5241, _e_5243, _e_5253};
    assign _e_5257 = _e_4964;
    assign _e_5255 = _e_4964[5];
    assign _e_5256 = _e_4964[4:0];
    assign _e_9546 = _e_5256[4:0] == 5'd11;
    assign _e_9547 = _e_5255 && _e_9546;
    assign _e_5259 = {5'd12};
    assign _e_5260 = \st [115:100];
    assign _e_5262 = \st [99:84];
    assign _e_5264 = \st [83:74];
    assign _e_5266 = \st [73:64];
    assign _e_5271 = {24'b0, \byte };
    localparam[31:0] _e_5273 = 32'd24;
    assign _e_5270 = _e_5271 << _e_5273;
    assign _e_5275 = \st [63:32];
    localparam[31:0] _e_5277 = 32'd16777215;
    assign _e_5274 = _e_5275 & _e_5277;
    assign _e_5269 = _e_5270 | _e_5274;
    assign _e_5268 = _e_5269[31:0];
    assign _e_5278 = \st [31:0];
    assign _e_5258 = {_e_5259, _e_5260, _e_5262, _e_5264, _e_5266, _e_5268, _e_5278};
    assign _e_5282 = _e_4964;
    assign _e_5280 = _e_4964[5];
    assign _e_5281 = _e_4964[4:0];
    assign _e_9551 = _e_5281[4:0] == 5'd12;
    assign _e_9552 = _e_5280 && _e_9551;
    assign _e_5284 = {5'd13};
    assign _e_5285 = \st [115:100];
    assign _e_5287 = \st [99:84];
    assign _e_5289 = \st [83:74];
    assign _e_5291 = \st [73:64];
    assign _e_5293 = \st [63:32];
    assign _e_5297 = {24'b0, \byte };
    assign _e_5300 = \st [31:0];
    localparam[31:0] _e_5302 = 32'd4294967040;
    assign _e_5299 = _e_5300 & _e_5302;
    assign _e_5296 = _e_5297 | _e_5299;
    assign _e_5295 = _e_5296[31:0];
    assign _e_5283 = {_e_5284, _e_5285, _e_5287, _e_5289, _e_5291, _e_5293, _e_5295};
    assign _e_5305 = _e_4964;
    assign _e_5303 = _e_4964[5];
    assign _e_5304 = _e_4964[4:0];
    assign _e_9556 = _e_5304[4:0] == 5'd13;
    assign _e_9557 = _e_5303 && _e_9556;
    assign _e_5307 = {5'd14};
    assign _e_5308 = \st [115:100];
    assign _e_5310 = \st [99:84];
    assign _e_5312 = \st [83:74];
    assign _e_5314 = \st [73:64];
    assign _e_5316 = \st [63:32];
    assign _e_5321 = {24'b0, \byte };
    localparam[31:0] _e_5323 = 32'd8;
    assign _e_5320 = _e_5321 << _e_5323;
    assign _e_5325 = \st [31:0];
    localparam[31:0] _e_5327 = 32'd4294902015;
    assign _e_5324 = _e_5325 & _e_5327;
    assign _e_5319 = _e_5320 | _e_5324;
    assign _e_5318 = _e_5319[31:0];
    assign _e_5306 = {_e_5307, _e_5308, _e_5310, _e_5312, _e_5314, _e_5316, _e_5318};
    assign _e_5330 = _e_4964;
    assign _e_5328 = _e_4964[5];
    assign _e_5329 = _e_4964[4:0];
    assign _e_9561 = _e_5329[4:0] == 5'd14;
    assign _e_9562 = _e_5328 && _e_9561;
    assign _e_5332 = {5'd15};
    assign _e_5333 = \st [115:100];
    assign _e_5335 = \st [99:84];
    assign _e_5337 = \st [83:74];
    assign _e_5339 = \st [73:64];
    assign _e_5341 = \st [63:32];
    assign _e_5346 = {24'b0, \byte };
    localparam[31:0] _e_5348 = 32'd16;
    assign _e_5345 = _e_5346 << _e_5348;
    assign _e_5350 = \st [31:0];
    localparam[31:0] _e_5352 = 32'd4278255615;
    assign _e_5349 = _e_5350 & _e_5352;
    assign _e_5344 = _e_5345 | _e_5349;
    assign _e_5343 = _e_5344[31:0];
    assign _e_5331 = {_e_5332, _e_5333, _e_5335, _e_5337, _e_5339, _e_5341, _e_5343};
    assign _e_5355 = _e_4964;
    assign _e_5353 = _e_4964[5];
    assign _e_5354 = _e_4964[4:0];
    assign _e_9566 = _e_5354[4:0] == 5'd15;
    assign _e_9567 = _e_5353 && _e_9566;
    assign _e_5357 = {5'd16};
    assign _e_5358 = \st [115:100];
    assign _e_5360 = \st [99:84];
    assign _e_5362 = \st [83:74];
    assign _e_5364 = \st [73:64];
    assign _e_5366 = \st [63:32];
    assign _e_5371 = {24'b0, \byte };
    localparam[31:0] _e_5373 = 32'd24;
    assign _e_5370 = _e_5371 << _e_5373;
    assign _e_5375 = \st [31:0];
    localparam[31:0] _e_5377 = 32'd16777215;
    assign _e_5374 = _e_5375 & _e_5377;
    assign _e_5369 = _e_5370 | _e_5374;
    assign _e_5368 = _e_5369[31:0];
    assign _e_5356 = {_e_5357, _e_5358, _e_5360, _e_5362, _e_5364, _e_5366, _e_5368};
    assign _e_5380 = _e_4964;
    assign \_  = _e_4964[5];
    assign _e_5379 = _e_4964[4:0];
    localparam[0:0] _e_9569 = 1;
    assign _e_9571 = _e_5379[4:0] == 5'd16;
    assign _e_9572 = _e_9569 && _e_9571;
    assign _e_5384 = \st [73:64];
    localparam[9:0] _e_5386 = 1;
    assign _e_5383 = _e_5384 + _e_5386;
    assign \pcw1  = _e_5383[9:0];
    assign _e_5390 = \st [99:84];
    localparam[15:0] _e_5392 = 1;
    assign _e_5389 = _e_5390 - _e_5392;
    assign \n1  = _e_5389[15:0];
    localparam[15:0] _e_5397 = 0;
    assign _e_5395 = \n1  == _e_5397;
    assign _e_5399 = {5'd17};
    assign _e_5401 = {5'd8};
    assign \next  = _e_5395 ? _e_5399 : _e_5401;
    assign _e_5405 = \st [115:100];
    assign _e_5408 = \st [83:74];
    assign _e_5411 = \st [63:32];
    assign _e_5413 = \st [31:0];
    assign _e_5403 = {\next , _e_5405, \n1 , _e_5408, \pcw1 , _e_5411, _e_5413};
    assign _e_5417 = _e_4964;
    assign __n1 = _e_4964[5];
    assign _e_5416 = _e_4964[4:0];
    localparam[0:0] _e_9574 = 1;
    assign _e_9576 = _e_5416[4:0] == 5'd17;
    assign _e_9577 = _e_9574 && _e_9576;
    assign _e_5421 = _e_4964;
    assign _e_5419 = _e_4964[5];
    assign __n2 = _e_4964[4:0];
    assign _e_9579 = !_e_5419;
    localparam[0:0] _e_9580 = 1;
    assign _e_9581 = _e_9579 && _e_9580;
    always_comb begin
        priority casez ({_e_9492, _e_9497, _e_9502, _e_9507, _e_9512, _e_9517, _e_9522, _e_9527, _e_9532, _e_9537, _e_9542, _e_9547, _e_9552, _e_9557, _e_9562, _e_9567, _e_9572, _e_9577, _e_9581})
            19'b1??????????????????: _e_4963 = _e_4971;
            19'b01?????????????????: _e_4963 = _e_4995;
            19'b001????????????????: _e_4963 = _e_5019;
            19'b0001???????????????: _e_4963 = _e_5045;
            19'b00001??????????????: _e_4963 = _e_5069;
            19'b000001?????????????: _e_4963 = _e_5104;
            19'b0000001????????????: _e_4963 = _e_5121;
            19'b00000001???????????: _e_4963 = _e_5147;
            19'b000000001??????????: _e_4963 = _e_5185;
            19'b0000000001?????????: _e_4963 = _e_5208;
            19'b00000000001????????: _e_4963 = _e_5233;
            19'b000000000001???????: _e_4963 = _e_5258;
            19'b0000000000001??????: _e_4963 = _e_5283;
            19'b00000000000001?????: _e_4963 = _e_5306;
            19'b000000000000001????: _e_4963 = _e_5331;
            19'b0000000000000001???: _e_4963 = _e_5356;
            19'b00000000000000001??: _e_4963 = _e_5403;
            19'b000000000000000001?: _e_4963 = \st ;
            19'b0000000000000000001: _e_4963 = \st ;
            19'b?: _e_4963 = 121'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \st  <= _e_4961;
        end
        else begin
            \st  <= _e_4963;
        end
    end
    assign _e_5424 = \st [120:116];
    assign _e_5426 = _e_5424;
    assign _e_9583 = _e_5424[4:0] == 5'd16;
    assign _e_5429 = \st [73:64];
    assign _e_5428 = {1'd1, _e_5429};
    assign _e_5432 = \st [63:32];
    assign _e_5431 = {1'd1, _e_5432};
    assign _e_5435 = \st [31:0];
    assign _e_5434 = {1'd1, _e_5435};
    assign _e_5427 = {_e_5428, _e_5431, _e_5434};
    assign __n3 = _e_5424;
    localparam[0:0] _e_9584 = 1;
    assign _e_5439 = {1'd0, 10'bX};
    assign _e_5440 = {1'd0, 32'bX};
    assign _e_5441 = {1'd0, 32'bX};
    assign _e_5438 = {_e_5439, _e_5440, _e_5441};
    always_comb begin
        priority casez ({_e_9583, _e_9584})
            2'b1?: _e_5445 = _e_5427;
            2'b01: _e_5445 = _e_5438;
            2'b?: _e_5445 = 77'dx;
        endcase
    end
    assign \wr_addr  = _e_5445[76:66];
    assign \wr_slot0  = _e_5445[65:33];
    assign \wr_slot1  = _e_5445[32:0];
    assign _e_5447 = \st [120:116];
    assign _e_5449 = _e_5447;
    assign _e_9586 = _e_5447[4:0] == 5'd17;
    localparam[0:0] _e_5451 = 0;
    assign _e_5453 = \st [83:74];
    assign _e_5452 = {1'd1, _e_5453};
    assign _e_5450 = {_e_5451, _e_5452};
    assign __n4 = _e_5447;
    localparam[0:0] _e_9587 = 1;
    localparam[0:0] _e_5457 = 1;
    assign _e_5458 = {1'd0, 10'bX};
    assign _e_5456 = {_e_5457, _e_5458};
    always_comb begin
        priority casez ({_e_9586, _e_9587})
            2'b1?: _e_5461 = _e_5450;
            2'b01: _e_5461 = _e_5456;
            2'b?: _e_5461 = 12'dx;
        endcase
    end
    assign \boot_active  = _e_5461[11];
    assign \release_pc  = _e_5461[10:0];
    assign _e_5462 = {\boot_active , \wr_addr , \wr_slot0 , \wr_slot1 , \release_pc };
    assign output__ = _e_5462;
endmodule

module \tta::bit::bit_fu  (
        input clk_i,
        input rst_i,
        input[32:0] set_op_a_i,
        input[35:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::bit_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::bit_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_op_a ;
    assign \set_op_a  = set_op_a_i;
    logic[35:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/bit.spade:20,9" *)
    logic[31:0] \v ;
    logic _e_9589;
    logic _e_9591;
    logic _e_9593;
    (* src = "src/bit.spade:19,45" *)
    logic[31:0] _e_5473;
    (* src = "src/bit.spade:19,14" *)
    reg[31:0] \op_a ;
    (* src = "src/bit.spade:26,9" *)
    logic[34:0] _e_5484;
    (* src = "src/bit.spade:26,14" *)
    logic[2:0] _e_5482;
    (* src = "src/bit.spade:26,14" *)
    logic[31:0] \_ ;
    logic _e_9595;
    logic _e_9598;
    logic _e_9600;
    logic _e_9601;
    (* src = "src/bit.spade:26,42" *)
    logic[31:0] _e_5487;
    (* src = "src/bit.spade:26,37" *)
    logic[32:0] _e_5486;
    (* src = "src/bit.spade:27,9" *)
    logic[34:0] _e_5491;
    (* src = "src/bit.spade:27,14" *)
    logic[2:0] _e_5489;
    (* src = "src/bit.spade:27,14" *)
    logic[31:0] __n1;
    logic _e_9603;
    logic _e_9606;
    logic _e_9608;
    logic _e_9609;
    (* src = "src/bit.spade:27,42" *)
    logic[31:0] _e_5494;
    (* src = "src/bit.spade:27,37" *)
    logic[32:0] _e_5493;
    (* src = "src/bit.spade:28,9" *)
    logic[34:0] _e_5498;
    (* src = "src/bit.spade:28,14" *)
    logic[2:0] _e_5496;
    (* src = "src/bit.spade:28,14" *)
    logic[31:0] __n2;
    logic _e_9611;
    logic _e_9614;
    logic _e_9616;
    logic _e_9617;
    (* src = "src/bit.spade:28,42" *)
    logic[31:0] _e_5501;
    (* src = "src/bit.spade:28,37" *)
    logic[32:0] _e_5500;
    (* src = "src/bit.spade:29,9" *)
    logic[34:0] _e_5505;
    (* src = "src/bit.spade:29,14" *)
    logic[2:0] _e_5503;
    (* src = "src/bit.spade:29,14" *)
    logic[31:0] __n3;
    logic _e_9619;
    logic _e_9622;
    logic _e_9624;
    logic _e_9625;
    (* src = "src/bit.spade:29,42" *)
    logic[31:0] _e_5508;
    (* src = "src/bit.spade:29,37" *)
    logic[32:0] _e_5507;
    (* src = "src/bit.spade:31,9" *)
    logic[34:0] _e_5512;
    (* src = "src/bit.spade:31,14" *)
    logic[2:0] _e_5510;
    (* src = "src/bit.spade:31,14" *)
    logic[31:0] \b ;
    logic _e_9627;
    logic _e_9630;
    logic _e_9632;
    logic _e_9633;
    (* src = "src/bit.spade:31,55" *)
    logic[31:0] _e_5519;
    (* src = "src/bit.spade:31,49" *)
    logic[31:0] _e_5517;
    (* src = "src/bit.spade:31,42" *)
    logic[31:0] _e_5515;
    (* src = "src/bit.spade:31,37" *)
    logic[32:0] _e_5514;
    (* src = "src/bit.spade:32,9" *)
    logic[34:0] _e_5524;
    (* src = "src/bit.spade:32,14" *)
    logic[2:0] _e_5522;
    (* src = "src/bit.spade:32,14" *)
    logic[31:0] b_n1;
    logic _e_9635;
    logic _e_9638;
    logic _e_9640;
    logic _e_9641;
    (* src = "src/bit.spade:32,56" *)
    logic[31:0] _e_5532;
    (* src = "src/bit.spade:32,50" *)
    logic[31:0] _e_5530;
    (* src = "src/bit.spade:32,49" *)
    logic[31:0] _e_5529;
    (* src = "src/bit.spade:32,42" *)
    logic[31:0] _e_5527;
    (* src = "src/bit.spade:32,37" *)
    logic[32:0] _e_5526;
    (* src = "src/bit.spade:36,9" *)
    logic[34:0] _e_5537;
    (* src = "src/bit.spade:36,14" *)
    logic[2:0] _e_5535;
    (* src = "src/bit.spade:36,14" *)
    logic[31:0] b_n2;
    logic _e_9643;
    logic _e_9646;
    logic _e_9648;
    logic _e_9649;
    (* src = "src/bit.spade:36,40" *)
    logic[31:0] _e_5540;
    (* src = "src/bit.spade:36,35" *)
    logic[32:0] _e_5539;
    (* src = "src/bit.spade:37,9" *)
    logic[34:0] _e_5545;
    (* src = "src/bit.spade:37,14" *)
    logic[2:0] _e_5543;
    (* src = "src/bit.spade:37,14" *)
    logic[31:0] b_n3;
    logic _e_9651;
    logic _e_9654;
    logic _e_9656;
    logic _e_9657;
    (* src = "src/bit.spade:37,40" *)
    logic[31:0] _e_5548;
    (* src = "src/bit.spade:37,35" *)
    logic[32:0] _e_5547;
    logic _e_9659;
    (* src = "src/bit.spade:39,17" *)
    logic[32:0] _e_5552;
    (* src = "src/bit.spade:25,36" *)
    logic[32:0] \result ;
    (* src = "src/bit.spade:43,51" *)
    logic[32:0] _e_5557;
    (* src = "src/bit.spade:43,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_5472 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_9589 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9590 = 1;
    assign _e_9591 = _e_9589 && _e_9590;
    assign _e_9593 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9591, _e_9593})
            2'b1?: _e_5473 = \v ;
            2'b01: _e_5473 = \op_a ;
            2'b?: _e_5473 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_5472;
        end
        else begin
            \op_a  <= _e_5473;
        end
    end
    assign _e_5484 = \trig [34:0];
    assign _e_5482 = _e_5484[34:32];
    assign \_  = _e_5484[31:0];
    assign _e_9595 = \trig [35] == 1'd1;
    assign _e_9598 = _e_5482[2:0] == 3'd0;
    localparam[0:0] _e_9599 = 1;
    assign _e_9600 = _e_9598 && _e_9599;
    assign _e_9601 = _e_9595 && _e_9600;
    (* src = "src/bit.spade:26,42" *)
    \tta::bit::clz32  clz32_0(.val_i(\op_a ), .output__(_e_5487));
    assign _e_5486 = {1'd1, _e_5487};
    assign _e_5491 = \trig [34:0];
    assign _e_5489 = _e_5491[34:32];
    assign __n1 = _e_5491[31:0];
    assign _e_9603 = \trig [35] == 1'd1;
    assign _e_9606 = _e_5489[2:0] == 3'd1;
    localparam[0:0] _e_9607 = 1;
    assign _e_9608 = _e_9606 && _e_9607;
    assign _e_9609 = _e_9603 && _e_9608;
    (* src = "src/bit.spade:27,42" *)
    \tta::bit::ctz32  ctz32_0(.val_i(\op_a ), .output__(_e_5494));
    assign _e_5493 = {1'd1, _e_5494};
    assign _e_5498 = \trig [34:0];
    assign _e_5496 = _e_5498[34:32];
    assign __n2 = _e_5498[31:0];
    assign _e_9611 = \trig [35] == 1'd1;
    assign _e_9614 = _e_5496[2:0] == 3'd2;
    localparam[0:0] _e_9615 = 1;
    assign _e_9616 = _e_9614 && _e_9615;
    assign _e_9617 = _e_9611 && _e_9616;
    (* src = "src/bit.spade:28,42" *)
    \tta::bit::popcnt32  popcnt32_0(.val_i(\op_a ), .output__(_e_5501));
    assign _e_5500 = {1'd1, _e_5501};
    assign _e_5505 = \trig [34:0];
    assign _e_5503 = _e_5505[34:32];
    assign __n3 = _e_5505[31:0];
    assign _e_9619 = \trig [35] == 1'd1;
    assign _e_9622 = _e_5503[2:0] == 3'd7;
    localparam[0:0] _e_9623 = 1;
    assign _e_9624 = _e_9622 && _e_9623;
    assign _e_9625 = _e_9619 && _e_9624;
    (* src = "src/bit.spade:29,42" *)
    \tta::bit::brev32  brev32_0(.val_i(\op_a ), .output__(_e_5508));
    assign _e_5507 = {1'd1, _e_5508};
    assign _e_5512 = \trig [34:0];
    assign _e_5510 = _e_5512[34:32];
    assign \b  = _e_5512[31:0];
    assign _e_9627 = \trig [35] == 1'd1;
    assign _e_9630 = _e_5510[2:0] == 3'd3;
    localparam[0:0] _e_9631 = 1;
    assign _e_9632 = _e_9630 && _e_9631;
    assign _e_9633 = _e_9627 && _e_9632;
    localparam[31:0] _e_5518 = 32'd1;
    localparam[31:0] _e_5521 = 32'd31;
    assign _e_5519 = \b  & _e_5521;
    assign _e_5517 = _e_5518 << _e_5519;
    assign _e_5515 = \op_a  | _e_5517;
    assign _e_5514 = {1'd1, _e_5515};
    assign _e_5524 = \trig [34:0];
    assign _e_5522 = _e_5524[34:32];
    assign b_n1 = _e_5524[31:0];
    assign _e_9635 = \trig [35] == 1'd1;
    assign _e_9638 = _e_5522[2:0] == 3'd4;
    localparam[0:0] _e_9639 = 1;
    assign _e_9640 = _e_9638 && _e_9639;
    assign _e_9641 = _e_9635 && _e_9640;
    localparam[31:0] _e_5531 = 32'd1;
    localparam[31:0] _e_5534 = 32'd31;
    assign _e_5532 = b_n1 & _e_5534;
    assign _e_5530 = _e_5531 << _e_5532;
    assign _e_5529 = ~_e_5530;
    assign _e_5527 = \op_a  & _e_5529;
    assign _e_5526 = {1'd1, _e_5527};
    assign _e_5537 = \trig [34:0];
    assign _e_5535 = _e_5537[34:32];
    assign b_n2 = _e_5537[31:0];
    assign _e_9643 = \trig [35] == 1'd1;
    assign _e_9646 = _e_5535[2:0] == 3'd5;
    localparam[0:0] _e_9647 = 1;
    assign _e_9648 = _e_9646 && _e_9647;
    assign _e_9649 = _e_9643 && _e_9648;
    (* src = "src/bit.spade:36,40" *)
    \tta::bit::bext32  bext32_0(.val_i(\op_a ), .ctrl_i(b_n2), .output__(_e_5540));
    assign _e_5539 = {1'd1, _e_5540};
    assign _e_5545 = \trig [34:0];
    assign _e_5543 = _e_5545[34:32];
    assign b_n3 = _e_5545[31:0];
    assign _e_9651 = \trig [35] == 1'd1;
    assign _e_9654 = _e_5543[2:0] == 3'd6;
    localparam[0:0] _e_9655 = 1;
    assign _e_9656 = _e_9654 && _e_9655;
    assign _e_9657 = _e_9651 && _e_9656;
    (* src = "src/bit.spade:37,40" *)
    \tta::bit::bins32  bins32_0(.val_i(\op_a ), .ctrl_i(b_n3), .output__(_e_5548));
    assign _e_5547 = {1'd1, _e_5548};
    assign _e_9659 = \trig [35] == 1'd0;
    assign _e_5552 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9601, _e_9609, _e_9617, _e_9625, _e_9633, _e_9641, _e_9649, _e_9657, _e_9659})
            9'b1????????: \result  = _e_5486;
            9'b01???????: \result  = _e_5493;
            9'b001??????: \result  = _e_5500;
            9'b0001?????: \result  = _e_5507;
            9'b00001????: \result  = _e_5514;
            9'b000001???: \result  = _e_5526;
            9'b0000001??: \result  = _e_5539;
            9'b00000001?: \result  = _e_5547;
            9'b000000001: \result  = _e_5552;
            9'b?: \result  = 33'dx;
        endcase
    end
    assign _e_5557 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_5557;
        end
        else begin
            \res_reg  <= \result ;
        end
    end
    assign output__ = \res_reg ;
endmodule

module \tta::bit::clz32  (
        input[31:0] val_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::clz32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::clz32 );
        end
    end
    `endif
    logic[31:0] \val ;
    assign \val  = val_i;
    (* src = "src/bit.spade:54,8" *)
    logic _e_5562;
    (* src = "src/bit.spade:58,27" *)
    logic[31:0] _e_5570;
    (* src = "src/bit.spade:58,27" *)
    logic _e_5569;
    (* src = "src/bit.spade:58,58" *)
    logic[31:0] _e_5577;
    (* src = "src/bit.spade:58,53" *)
    logic[63:0] _e_5575;
    (* src = "src/bit.spade:58,78" *)
    logic[63:0] _e_5581;
    (* src = "src/bit.spade:58,24" *)
    logic[63:0] _e_5586;
    (* src = "src/bit.spade:58,13" *)
    logic[31:0] \n1 ;
    (* src = "src/bit.spade:58,13" *)
    logic[31:0] \x1 ;
    (* src = "src/bit.spade:59,27" *)
    logic[31:0] _e_5589;
    (* src = "src/bit.spade:59,27" *)
    logic _e_5588;
    (* src = "src/bit.spade:59,59" *)
    logic[32:0] _e_5596;
    (* src = "src/bit.spade:59,53" *)
    logic[31:0] _e_5595;
    (* src = "src/bit.spade:59,66" *)
    logic[31:0] _e_5599;
    (* src = "src/bit.spade:59,52" *)
    logic[63:0] _e_5594;
    (* src = "src/bit.spade:59,84" *)
    logic[63:0] _e_5603;
    (* src = "src/bit.spade:59,24" *)
    logic[63:0] _e_5608;
    (* src = "src/bit.spade:59,13" *)
    logic[31:0] \n2 ;
    (* src = "src/bit.spade:59,13" *)
    logic[31:0] \x2 ;
    (* src = "src/bit.spade:60,27" *)
    logic[31:0] _e_5611;
    (* src = "src/bit.spade:60,27" *)
    logic _e_5610;
    (* src = "src/bit.spade:60,59" *)
    logic[32:0] _e_5618;
    (* src = "src/bit.spade:60,53" *)
    logic[31:0] _e_5617;
    (* src = "src/bit.spade:60,66" *)
    logic[31:0] _e_5621;
    (* src = "src/bit.spade:60,52" *)
    logic[63:0] _e_5616;
    (* src = "src/bit.spade:60,84" *)
    logic[63:0] _e_5625;
    (* src = "src/bit.spade:60,24" *)
    logic[63:0] _e_5630;
    (* src = "src/bit.spade:60,13" *)
    logic[31:0] \n3 ;
    (* src = "src/bit.spade:60,13" *)
    logic[31:0] \x3 ;
    (* src = "src/bit.spade:61,27" *)
    logic[31:0] _e_5633;
    (* src = "src/bit.spade:61,27" *)
    logic _e_5632;
    (* src = "src/bit.spade:61,59" *)
    logic[32:0] _e_5640;
    (* src = "src/bit.spade:61,53" *)
    logic[31:0] _e_5639;
    (* src = "src/bit.spade:61,66" *)
    logic[31:0] _e_5643;
    (* src = "src/bit.spade:61,52" *)
    logic[63:0] _e_5638;
    (* src = "src/bit.spade:61,84" *)
    logic[63:0] _e_5647;
    (* src = "src/bit.spade:61,24" *)
    logic[63:0] _e_5652;
    (* src = "src/bit.spade:61,13" *)
    logic[31:0] \n4 ;
    (* src = "src/bit.spade:61,13" *)
    logic[31:0] \x4 ;
    (* src = "src/bit.spade:62,21" *)
    logic[31:0] _e_5655;
    (* src = "src/bit.spade:62,21" *)
    logic _e_5654;
    (* src = "src/bit.spade:62,52" *)
    logic[32:0] _e_5661;
    (* src = "src/bit.spade:62,46" *)
    logic[31:0] _e_5660;
    (* src = "src/bit.spade:62,18" *)
    logic[31:0] \n5 ;
    (* src = "src/bit.spade:54,5" *)
    logic[31:0] _e_5561;
    localparam[31:0] _e_5564 = 32'd0;
    assign _e_5562 = \val  == _e_5564;
    localparam[31:0] _e_5566 = 32'd32;
    localparam[31:0] _e_5572 = 32'd4294901760;
    assign _e_5570 = \val  & _e_5572;
    localparam[31:0] _e_5573 = 32'd0;
    assign _e_5569 = _e_5570 == _e_5573;
    localparam[31:0] _e_5576 = 32'd16;
    localparam[31:0] _e_5579 = 32'd16;
    assign _e_5577 = \val  << _e_5579;
    assign _e_5575 = {_e_5576, _e_5577};
    localparam[31:0] _e_5582 = 32'd0;
    assign _e_5581 = {_e_5582, \val };
    assign _e_5586 = _e_5569 ? _e_5575 : _e_5581;
    assign \n1  = _e_5586[63:32];
    assign \x1  = _e_5586[31:0];
    localparam[31:0] _e_5591 = 32'd4278190080;
    assign _e_5589 = \x1  & _e_5591;
    localparam[31:0] _e_5592 = 32'd0;
    assign _e_5588 = _e_5589 == _e_5592;
    localparam[31:0] _e_5598 = 32'd8;
    assign _e_5596 = \n1  + _e_5598;
    assign _e_5595 = _e_5596[31:0];
    localparam[31:0] _e_5601 = 32'd8;
    assign _e_5599 = \x1  << _e_5601;
    assign _e_5594 = {_e_5595, _e_5599};
    assign _e_5603 = {\n1 , \x1 };
    assign _e_5608 = _e_5588 ? _e_5594 : _e_5603;
    assign \n2  = _e_5608[63:32];
    assign \x2  = _e_5608[31:0];
    localparam[31:0] _e_5613 = 32'd4026531840;
    assign _e_5611 = \x2  & _e_5613;
    localparam[31:0] _e_5614 = 32'd0;
    assign _e_5610 = _e_5611 == _e_5614;
    localparam[31:0] _e_5620 = 32'd4;
    assign _e_5618 = \n2  + _e_5620;
    assign _e_5617 = _e_5618[31:0];
    localparam[31:0] _e_5623 = 32'd4;
    assign _e_5621 = \x2  << _e_5623;
    assign _e_5616 = {_e_5617, _e_5621};
    assign _e_5625 = {\n2 , \x2 };
    assign _e_5630 = _e_5610 ? _e_5616 : _e_5625;
    assign \n3  = _e_5630[63:32];
    assign \x3  = _e_5630[31:0];
    localparam[31:0] _e_5635 = 32'd3221225472;
    assign _e_5633 = \x3  & _e_5635;
    localparam[31:0] _e_5636 = 32'd0;
    assign _e_5632 = _e_5633 == _e_5636;
    localparam[31:0] _e_5642 = 32'd2;
    assign _e_5640 = \n3  + _e_5642;
    assign _e_5639 = _e_5640[31:0];
    localparam[31:0] _e_5645 = 32'd2;
    assign _e_5643 = \x3  << _e_5645;
    assign _e_5638 = {_e_5639, _e_5643};
    assign _e_5647 = {\n3 , \x3 };
    assign _e_5652 = _e_5632 ? _e_5638 : _e_5647;
    assign \n4  = _e_5652[63:32];
    assign \x4  = _e_5652[31:0];
    localparam[31:0] _e_5657 = 32'd2147483648;
    assign _e_5655 = \x4  & _e_5657;
    localparam[31:0] _e_5658 = 32'd0;
    assign _e_5654 = _e_5655 == _e_5658;
    localparam[31:0] _e_5663 = 32'd1;
    assign _e_5661 = \n4  + _e_5663;
    assign _e_5660 = _e_5661[31:0];
    assign \n5  = _e_5654 ? _e_5660 : \n4 ;
    assign _e_5561 = _e_5562 ? _e_5566 : \n5 ;
    assign output__ = _e_5561;
endmodule

module \tta::bit::ctz32  (
        input[31:0] val_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::ctz32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::ctz32 );
        end
    end
    `endif
    logic[31:0] \val ;
    assign \val  = val_i;
    (* src = "src/bit.spade:69,11" *)
    logic[31:0] _e_5670;
    (* src = "src/bit.spade:69,5" *)
    logic[31:0] _e_5669;
    (* src = "src/bit.spade:69,11" *)
    \tta::bit::brev32  brev32_0(.val_i(\val ), .output__(_e_5670));
    (* src = "src/bit.spade:69,5" *)
    \tta::bit::clz32  clz32_0(.val_i(_e_5670), .output__(_e_5669));
    assign output__ = _e_5669;
endmodule

module \tta::bit::brev32  (
        input[31:0] val_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::brev32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::brev32 );
        end
    end
    `endif
    logic[31:0] \val ;
    assign \val  = val_i;
    (* src = "src/bit.spade:74,9" *)
    logic[31:0] \x ;
    (* src = "src/bit.spade:75,14" *)
    logic[31:0] _e_5677;
    (* src = "src/bit.spade:75,13" *)
    logic[31:0] _e_5676;
    (* src = "src/bit.spade:75,40" *)
    logic[31:0] _e_5682;
    (* src = "src/bit.spade:75,39" *)
    logic[31:0] _e_5681;
    (* src = "src/bit.spade:75,13" *)
    logic[31:0] x_n1;
    (* src = "src/bit.spade:76,14" *)
    logic[31:0] _e_5689;
    (* src = "src/bit.spade:76,13" *)
    logic[31:0] _e_5688;
    (* src = "src/bit.spade:76,40" *)
    logic[31:0] _e_5694;
    (* src = "src/bit.spade:76,39" *)
    logic[31:0] _e_5693;
    (* src = "src/bit.spade:76,13" *)
    logic[31:0] x_n2;
    (* src = "src/bit.spade:77,14" *)
    logic[31:0] _e_5701;
    (* src = "src/bit.spade:77,13" *)
    logic[31:0] _e_5700;
    (* src = "src/bit.spade:77,40" *)
    logic[31:0] _e_5706;
    (* src = "src/bit.spade:77,39" *)
    logic[31:0] _e_5705;
    (* src = "src/bit.spade:77,13" *)
    logic[31:0] x_n3;
    (* src = "src/bit.spade:78,14" *)
    logic[31:0] _e_5713;
    (* src = "src/bit.spade:78,13" *)
    logic[31:0] _e_5712;
    (* src = "src/bit.spade:78,40" *)
    logic[31:0] _e_5718;
    (* src = "src/bit.spade:78,39" *)
    logic[31:0] _e_5717;
    (* src = "src/bit.spade:78,13" *)
    logic[31:0] x_n4;
    (* src = "src/bit.spade:79,13" *)
    logic[31:0] _e_5724;
    (* src = "src/bit.spade:79,25" *)
    logic[31:0] _e_5727;
    (* src = "src/bit.spade:79,13" *)
    logic[31:0] x_n5;
    assign \x  = \val ;
    localparam[31:0] _e_5679 = 32'd1;
    assign _e_5677 = \x  >> _e_5679;
    localparam[31:0] _e_5680 = 32'd1431655765;
    assign _e_5676 = _e_5677 & _e_5680;
    localparam[31:0] _e_5684 = 32'd1431655765;
    assign _e_5682 = \x  & _e_5684;
    localparam[31:0] _e_5685 = 32'd1;
    assign _e_5681 = _e_5682 << _e_5685;
    assign x_n1 = _e_5676 | _e_5681;
    localparam[31:0] _e_5691 = 32'd2;
    assign _e_5689 = x_n1 >> _e_5691;
    localparam[31:0] _e_5692 = 32'd858993459;
    assign _e_5688 = _e_5689 & _e_5692;
    localparam[31:0] _e_5696 = 32'd858993459;
    assign _e_5694 = x_n1 & _e_5696;
    localparam[31:0] _e_5697 = 32'd2;
    assign _e_5693 = _e_5694 << _e_5697;
    assign x_n2 = _e_5688 | _e_5693;
    localparam[31:0] _e_5703 = 32'd4;
    assign _e_5701 = x_n2 >> _e_5703;
    localparam[31:0] _e_5704 = 32'd252645135;
    assign _e_5700 = _e_5701 & _e_5704;
    localparam[31:0] _e_5708 = 32'd252645135;
    assign _e_5706 = x_n2 & _e_5708;
    localparam[31:0] _e_5709 = 32'd4;
    assign _e_5705 = _e_5706 << _e_5709;
    assign x_n3 = _e_5700 | _e_5705;
    localparam[31:0] _e_5715 = 32'd8;
    assign _e_5713 = x_n3 >> _e_5715;
    localparam[31:0] _e_5716 = 32'd16711935;
    assign _e_5712 = _e_5713 & _e_5716;
    localparam[31:0] _e_5720 = 32'd16711935;
    assign _e_5718 = x_n3 & _e_5720;
    localparam[31:0] _e_5721 = 32'd8;
    assign _e_5717 = _e_5718 << _e_5721;
    assign x_n4 = _e_5712 | _e_5717;
    localparam[31:0] _e_5726 = 32'd16;
    assign _e_5724 = x_n4 >> _e_5726;
    localparam[31:0] _e_5729 = 32'd16;
    assign _e_5727 = x_n4 << _e_5729;
    assign x_n5 = _e_5724 | _e_5727;
    assign output__ = x_n5;
endmodule

module \tta::bit::popcnt32  (
        input[31:0] val_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::popcnt32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::popcnt32 );
        end
    end
    `endif
    logic[31:0] \val ;
    assign \val  = val_i;
    (* src = "src/bit.spade:85,9" *)
    logic[31:0] \x ;
    (* src = "src/bit.spade:86,18" *)
    logic[31:0] _e_5738;
    (* src = "src/bit.spade:86,17" *)
    logic[31:0] _e_5737;
    (* src = "src/bit.spade:86,13" *)
    logic[32:0] x_n1;
    (* src = "src/bit.spade:87,13" *)
    logic[32:0] _e_5744;
    (* src = "src/bit.spade:87,33" *)
    logic[32:0] _e_5748;
    (* src = "src/bit.spade:87,32" *)
    logic[32:0] _e_5747;
    (* src = "src/bit.spade:87,13" *)
    logic[33:0] x_n2;
    (* src = "src/bit.spade:88,18" *)
    logic[33:0] _e_5756;
    (* src = "src/bit.spade:88,13" *)
    logic[34:0] _e_5754;
    (* src = "src/bit.spade:88,13" *)
    logic[34:0] x_n3;
    (* src = "src/bit.spade:89,17" *)
    logic[34:0] _e_5763;
    (* src = "src/bit.spade:89,13" *)
    logic[35:0] x_n4;
    (* src = "src/bit.spade:90,17" *)
    logic[35:0] _e_5769;
    (* src = "src/bit.spade:90,13" *)
    logic[36:0] x_n5;
    (* src = "src/bit.spade:91,11" *)
    logic[36:0] _e_5774;
    (* src = "src/bit.spade:91,5" *)
    logic[31:0] _e_5773;
    assign \x  = \val ;
    localparam[31:0] _e_5740 = 32'd1;
    assign _e_5738 = \x  >> _e_5740;
    localparam[31:0] _e_5741 = 32'd1431655765;
    assign _e_5737 = _e_5738 & _e_5741;
    assign x_n1 = \x  - _e_5737;
    localparam[32:0] _e_5746 = 33'd858993459;
    assign _e_5744 = x_n1 & _e_5746;
    localparam[32:0] _e_5750 = 33'd2;
    assign _e_5748 = x_n1 >> _e_5750;
    localparam[32:0] _e_5751 = 33'd858993459;
    assign _e_5747 = _e_5748 & _e_5751;
    assign x_n2 = _e_5744 + _e_5747;
    localparam[33:0] _e_5758 = 34'd4;
    assign _e_5756 = x_n2 >> _e_5758;
    assign _e_5754 = x_n2 + _e_5756;
    localparam[34:0] _e_5759 = 35'd252645135;
    assign x_n3 = _e_5754 & _e_5759;
    localparam[34:0] _e_5765 = 35'd8;
    assign _e_5763 = x_n3 >> _e_5765;
    assign x_n4 = x_n3 + _e_5763;
    localparam[35:0] _e_5771 = 36'd16;
    assign _e_5769 = x_n4 >> _e_5771;
    assign x_n5 = x_n4 + _e_5769;
    localparam[36:0] _e_5776 = 37'd63;
    assign _e_5774 = x_n5 & _e_5776;
    assign _e_5773 = _e_5774[31:0];
    assign output__ = _e_5773;
endmodule

module \tta::bit::bext32  (
        input[31:0] val_i,
        input[31:0] ctrl_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::bext32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::bext32 );
        end
    end
    `endif
    logic[31:0] \val ;
    assign \val  = val_i;
    logic[31:0] \ctrl ;
    assign \ctrl  = ctrl_i;
    (* src = "src/bit.spade:97,15" *)
    logic[31:0] \lsb ;
    (* src = "src/bit.spade:98,25" *)
    logic[31:0] _e_5783;
    (* src = "src/bit.spade:98,25" *)
    logic[31:0] \width_minus_1 ;
    (* src = "src/bit.spade:104,19" *)
    logic _e_5789;
    (* src = "src/bit.spade:107,21" *)
    logic[32:0] _e_5799;
    (* src = "src/bit.spade:107,15" *)
    logic[32:0] _e_5797;
    (* src = "src/bit.spade:107,15" *)
    logic[33:0] _e_5796;
    (* src = "src/bit.spade:107,9" *)
    logic[31:0] _e_5795;
    (* src = "src/bit.spade:104,16" *)
    logic[31:0] \mask ;
    (* src = "src/bit.spade:110,5" *)
    logic[31:0] _e_5805;
    (* src = "src/bit.spade:110,5" *)
    logic[31:0] _e_5804;
    localparam[31:0] _e_5780 = 32'd31;
    assign \lsb  = \ctrl  & _e_5780;
    localparam[31:0] _e_5785 = 32'd5;
    assign _e_5783 = \ctrl  >> _e_5785;
    localparam[31:0] _e_5786 = 32'd31;
    assign \width_minus_1  = _e_5783 & _e_5786;
    localparam[31:0] _e_5791 = 32'd31;
    assign _e_5789 = \width_minus_1  == _e_5791;
    localparam[31:0] _e_5793 = 32'd4294967295;
    localparam[32:0] _e_5798 = 33'd1;
    localparam[31:0] _e_5801 = 32'd1;
    assign _e_5799 = \width_minus_1  + _e_5801;
    assign _e_5797 = _e_5798 << _e_5799;
    localparam[32:0] _e_5802 = 33'd1;
    assign _e_5796 = _e_5797 - _e_5802;
    assign _e_5795 = _e_5796[31:0];
    assign \mask  = _e_5789 ? _e_5793 : _e_5795;
    assign _e_5805 = \val  >> \lsb ;
    assign _e_5804 = _e_5805 & \mask ;
    assign output__ = _e_5804;
endmodule

module \tta::bit::bins32  (
        input[31:0] val_i,
        input[31:0] ctrl_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::bins32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::bins32 );
        end
    end
    `endif
    logic[31:0] \val ;
    assign \val  = val_i;
    logic[31:0] \ctrl ;
    assign \ctrl  = ctrl_i;
    (* src = "src/bit.spade:116,15" *)
    logic[31:0] \lsb ;
    (* src = "src/bit.spade:117,25" *)
    logic[31:0] _e_5815;
    (* src = "src/bit.spade:117,25" *)
    logic[31:0] \width_minus_1 ;
    (* src = "src/bit.spade:119,19" *)
    logic _e_5821;
    (* src = "src/bit.spade:122,21" *)
    logic[32:0] _e_5831;
    (* src = "src/bit.spade:122,15" *)
    logic[32:0] _e_5829;
    (* src = "src/bit.spade:122,15" *)
    logic[33:0] _e_5828;
    (* src = "src/bit.spade:122,9" *)
    logic[31:0] _e_5827;
    (* src = "src/bit.spade:119,16" *)
    logic[31:0] \mask ;
    (* src = "src/bit.spade:125,5" *)
    logic[31:0] _e_5837;
    (* src = "src/bit.spade:125,5" *)
    logic[31:0] _e_5836;
    localparam[31:0] _e_5812 = 32'd31;
    assign \lsb  = \ctrl  & _e_5812;
    localparam[31:0] _e_5817 = 32'd5;
    assign _e_5815 = \ctrl  >> _e_5817;
    localparam[31:0] _e_5818 = 32'd31;
    assign \width_minus_1  = _e_5815 & _e_5818;
    localparam[31:0] _e_5823 = 32'd31;
    assign _e_5821 = \width_minus_1  == _e_5823;
    localparam[31:0] _e_5825 = 32'd4294967295;
    localparam[32:0] _e_5830 = 33'd1;
    localparam[31:0] _e_5833 = 32'd1;
    assign _e_5831 = \width_minus_1  + _e_5833;
    assign _e_5829 = _e_5830 << _e_5831;
    localparam[32:0] _e_5834 = 33'd1;
    assign _e_5828 = _e_5829 - _e_5834;
    assign _e_5827 = _e_5828[31:0];
    assign \mask  = _e_5821 ? _e_5825 : _e_5827;
    assign _e_5837 = \val  & \mask ;
    assign _e_5836 = _e_5837 << \lsb ;
    assign output__ = _e_5836;
endmodule

module \tta::bit::pick_bit_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::pick_bit_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::pick_bit_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/bit.spade:133,9" *)
    logic[42:0] _e_5845;
    (* src = "src/bit.spade:133,14" *)
    logic[31:0] \x ;
    logic _e_9661;
    logic _e_9663;
    logic _e_9665;
    logic _e_9666;
    (* src = "src/bit.spade:133,35" *)
    logic[32:0] _e_5847;
    (* src = "src/bit.spade:134,9" *)
    logic[43:0] \_ ;
    (* src = "src/bit.spade:135,13" *)
    logic[42:0] _e_5853;
    (* src = "src/bit.spade:135,18" *)
    logic[31:0] x_n1;
    logic _e_9669;
    logic _e_9671;
    logic _e_9673;
    logic _e_9674;
    (* src = "src/bit.spade:135,39" *)
    logic[32:0] _e_5855;
    (* src = "src/bit.spade:136,13" *)
    logic[43:0] __n1;
    (* src = "src/bit.spade:136,18" *)
    logic[32:0] _e_5858;
    (* src = "src/bit.spade:134,14" *)
    logic[32:0] _e_5850;
    (* src = "src/bit.spade:132,5" *)
    logic[32:0] _e_5842;
    assign _e_5845 = \m1 [42:0];
    assign \x  = _e_5845[36:5];
    assign _e_9661 = \m1 [43] == 1'd1;
    assign _e_9663 = _e_5845[42:37] == 6'd39;
    localparam[0:0] _e_9664 = 1;
    assign _e_9665 = _e_9663 && _e_9664;
    assign _e_9666 = _e_9661 && _e_9665;
    assign _e_5847 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9667 = 1;
    assign _e_5853 = \m0 [42:0];
    assign x_n1 = _e_5853[36:5];
    assign _e_9669 = \m0 [43] == 1'd1;
    assign _e_9671 = _e_5853[42:37] == 6'd39;
    localparam[0:0] _e_9672 = 1;
    assign _e_9673 = _e_9671 && _e_9672;
    assign _e_9674 = _e_9669 && _e_9673;
    assign _e_5855 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9675 = 1;
    assign _e_5858 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9674, _e_9675})
            2'b1?: _e_5850 = _e_5855;
            2'b01: _e_5850 = _e_5858;
            2'b?: _e_5850 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9666, _e_9667})
            2'b1?: _e_5842 = _e_5847;
            2'b01: _e_5842 = _e_5850;
            2'b?: _e_5842 = 33'dx;
        endcase
    end
    assign output__ = _e_5842;
endmodule

module \tta::bit::pick_bit_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[35:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bit::pick_bit_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bit::pick_bit_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/bit.spade:142,9" *)
    logic[42:0] _e_5864;
    (* src = "src/bit.spade:142,14" *)
    logic[2:0] \op ;
    (* src = "src/bit.spade:142,14" *)
    logic[31:0] \x ;
    logic _e_9677;
    logic _e_9679;
    logic _e_9682;
    logic _e_9683;
    logic _e_9684;
    (* src = "src/bit.spade:142,44" *)
    logic[34:0] _e_5867;
    (* src = "src/bit.spade:142,39" *)
    logic[35:0] _e_5866;
    (* src = "src/bit.spade:143,9" *)
    logic[43:0] \_ ;
    (* src = "src/bit.spade:144,13" *)
    logic[42:0] _e_5875;
    (* src = "src/bit.spade:144,18" *)
    logic[2:0] op_n1;
    (* src = "src/bit.spade:144,18" *)
    logic[31:0] x_n1;
    logic _e_9687;
    logic _e_9689;
    logic _e_9692;
    logic _e_9693;
    logic _e_9694;
    (* src = "src/bit.spade:144,48" *)
    logic[34:0] _e_5878;
    (* src = "src/bit.spade:144,43" *)
    logic[35:0] _e_5877;
    (* src = "src/bit.spade:145,13" *)
    logic[43:0] __n1;
    (* src = "src/bit.spade:145,18" *)
    logic[35:0] _e_5882;
    (* src = "src/bit.spade:143,14" *)
    logic[35:0] _e_5871;
    (* src = "src/bit.spade:141,5" *)
    logic[35:0] _e_5860;
    assign _e_5864 = \m1 [42:0];
    assign \op  = _e_5864[36:34];
    assign \x  = _e_5864[33:2];
    assign _e_9677 = \m1 [43] == 1'd1;
    assign _e_9679 = _e_5864[42:37] == 6'd40;
    localparam[0:0] _e_9680 = 1;
    localparam[0:0] _e_9681 = 1;
    assign _e_9682 = _e_9679 && _e_9680;
    assign _e_9683 = _e_9682 && _e_9681;
    assign _e_9684 = _e_9677 && _e_9683;
    assign _e_5867 = {\op , \x };
    assign _e_5866 = {1'd1, _e_5867};
    assign \_  = \m1 ;
    localparam[0:0] _e_9685 = 1;
    assign _e_5875 = \m0 [42:0];
    assign op_n1 = _e_5875[36:34];
    assign x_n1 = _e_5875[33:2];
    assign _e_9687 = \m0 [43] == 1'd1;
    assign _e_9689 = _e_5875[42:37] == 6'd40;
    localparam[0:0] _e_9690 = 1;
    localparam[0:0] _e_9691 = 1;
    assign _e_9692 = _e_9689 && _e_9690;
    assign _e_9693 = _e_9692 && _e_9691;
    assign _e_9694 = _e_9687 && _e_9693;
    assign _e_5878 = {op_n1, x_n1};
    assign _e_5877 = {1'd1, _e_5878};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9695 = 1;
    assign _e_5882 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_9694, _e_9695})
            2'b1?: _e_5871 = _e_5877;
            2'b01: _e_5871 = _e_5882;
            2'b?: _e_5871 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9684, _e_9685})
            2'b1?: _e_5860 = _e_5866;
            2'b01: _e_5860 = _e_5871;
            2'b?: _e_5860 = 36'dx;
        endcase
    end
    assign output__ = _e_5860;
endmodule

module \tta::mac::mac_fu  (
        input clk_i,
        input rst_i,
        input[32:0] set_op_a_i,
        input[32:0] trig_i,
        input clr_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::mac::mac_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::mac::mac_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_op_a ;
    assign \set_op_a  = set_op_a_i;
    logic[32:0] \trig ;
    assign \trig  = trig_i;
    logic \clr ;
    assign \clr  = clr_i;
    (* src = "src/mac.spade:20,9" *)
    logic[31:0] \val ;
    logic _e_9697;
    logic _e_9699;
    logic _e_9701;
    (* src = "src/mac.spade:19,45" *)
    logic[31:0] _e_5888;
    (* src = "src/mac.spade:19,14" *)
    reg[31:0] \op_a ;
    (* src = "src/mac.spade:31,17" *)
    logic[31:0] \op_b ;
    logic _e_9703;
    logic _e_9705;
    (* src = "src/mac.spade:34,48" *)
    logic[63:0] _e_5911;
    (* src = "src/mac.spade:34,42" *)
    logic[31:0] \prod ;
    (* src = "src/mac.spade:35,27" *)
    logic[32:0] _e_5916;
    (* src = "src/mac.spade:35,21" *)
    logic[31:0] _e_5915;
    logic _e_9707;
    (* src = "src/mac.spade:30,13" *)
    logic[31:0] _e_5905;
    (* src = "src/mac.spade:27,9" *)
    logic[31:0] _e_5900;
    (* src = "src/mac.spade:26,14" *)
    reg[31:0] \acc ;
    (* src = "src/mac.spade:43,47" *)
    logic[32:0] _e_5924;
    (* src = "src/mac.spade:47,13" *)
    logic[32:0] _e_5929;
    (* src = "src/mac.spade:50,17" *)
    logic[31:0] op_b_n1;
    logic _e_9709;
    logic _e_9711;
    (* src = "src/mac.spade:52,48" *)
    logic[63:0] _e_5938;
    (* src = "src/mac.spade:52,42" *)
    logic[31:0] prod_n1;
    (* src = "src/mac.spade:53,32" *)
    logic[32:0] _e_5944;
    (* src = "src/mac.spade:53,26" *)
    logic[31:0] _e_5943;
    (* src = "src/mac.spade:53,21" *)
    logic[32:0] _e_5942;
    logic _e_9713;
    (* src = "src/mac.spade:55,25" *)
    logic[32:0] _e_5948;
    (* src = "src/mac.spade:49,13" *)
    logic[32:0] _e_5932;
    (* src = "src/mac.spade:44,9" *)
    logic[32:0] _e_5926;
    (* src = "src/mac.spade:43,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_5887 = 32'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9697 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9698 = 1;
    assign _e_9699 = _e_9697 && _e_9698;
    assign _e_9701 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9699, _e_9701})
            2'b1?: _e_5888 = \val ;
            2'b01: _e_5888 = \op_a ;
            2'b?: _e_5888 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_5887;
        end
        else begin
            \op_a  <= _e_5888;
        end
    end
    localparam[31:0] _e_5898 = 32'd0;
    localparam[31:0] _e_5903 = 32'd0;
    assign \op_b  = \trig [31:0];
    assign _e_9703 = \trig [32] == 1'd1;
    localparam[0:0] _e_9704 = 1;
    assign _e_9705 = _e_9703 && _e_9704;
    assign _e_5911 = \op_a  * \op_b ;
    assign \prod  = _e_5911[31:0];
    assign _e_5916 = \acc  + \prod ;
    assign _e_5915 = _e_5916[31:0];
    assign _e_9707 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9705, _e_9707})
            2'b1?: _e_5905 = _e_5915;
            2'b01: _e_5905 = \acc ;
            2'b?: _e_5905 = 32'dx;
        endcase
    end
    assign _e_5900 = \clr  ? _e_5903 : _e_5905;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \acc  <= _e_5898;
        end
        else begin
            \acc  <= _e_5900;
        end
    end
    assign _e_5924 = {1'd0, 32'bX};
    localparam[31:0] _e_5930 = 32'd0;
    assign _e_5929 = {1'd1, _e_5930};
    assign op_b_n1 = \trig [31:0];
    assign _e_9709 = \trig [32] == 1'd1;
    localparam[0:0] _e_9710 = 1;
    assign _e_9711 = _e_9709 && _e_9710;
    assign _e_5938 = \op_a  * op_b_n1;
    assign prod_n1 = _e_5938[31:0];
    assign _e_5944 = \acc  + prod_n1;
    assign _e_5943 = _e_5944[31:0];
    assign _e_5942 = {1'd1, _e_5943};
    assign _e_9713 = \trig [32] == 1'd0;
    assign _e_5948 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9711, _e_9713})
            2'b1?: _e_5932 = _e_5942;
            2'b01: _e_5932 = _e_5948;
            2'b?: _e_5932 = 33'dx;
        endcase
    end
    assign _e_5926 = \clr  ? _e_5929 : _e_5932;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_5924;
        end
        else begin
            \res  <= _e_5926;
        end
    end
    assign output__ = \res ;
endmodule

module \tta::mac::pick_mac_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::mac::pick_mac_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::mac::pick_mac_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/mac.spade:66,9" *)
    logic[42:0] _e_5954;
    (* src = "src/mac.spade:66,14" *)
    logic[31:0] \x ;
    logic _e_9715;
    logic _e_9717;
    logic _e_9719;
    logic _e_9720;
    (* src = "src/mac.spade:66,35" *)
    logic[32:0] _e_5956;
    (* src = "src/mac.spade:67,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:68,13" *)
    logic[42:0] _e_5962;
    (* src = "src/mac.spade:68,18" *)
    logic[31:0] x_n1;
    logic _e_9723;
    logic _e_9725;
    logic _e_9727;
    logic _e_9728;
    (* src = "src/mac.spade:68,39" *)
    logic[32:0] _e_5964;
    (* src = "src/mac.spade:69,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:69,18" *)
    logic[32:0] _e_5967;
    (* src = "src/mac.spade:67,14" *)
    logic[32:0] _e_5959;
    (* src = "src/mac.spade:65,5" *)
    logic[32:0] _e_5951;
    assign _e_5954 = \m1 [42:0];
    assign \x  = _e_5954[36:5];
    assign _e_9715 = \m1 [43] == 1'd1;
    assign _e_9717 = _e_5954[42:37] == 6'd24;
    localparam[0:0] _e_9718 = 1;
    assign _e_9719 = _e_9717 && _e_9718;
    assign _e_9720 = _e_9715 && _e_9719;
    assign _e_5956 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9721 = 1;
    assign _e_5962 = \m0 [42:0];
    assign x_n1 = _e_5962[36:5];
    assign _e_9723 = \m0 [43] == 1'd1;
    assign _e_9725 = _e_5962[42:37] == 6'd24;
    localparam[0:0] _e_9726 = 1;
    assign _e_9727 = _e_9725 && _e_9726;
    assign _e_9728 = _e_9723 && _e_9727;
    assign _e_5964 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9729 = 1;
    assign _e_5967 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9728, _e_9729})
            2'b1?: _e_5959 = _e_5964;
            2'b01: _e_5959 = _e_5967;
            2'b?: _e_5959 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9720, _e_9721})
            2'b1?: _e_5951 = _e_5956;
            2'b01: _e_5951 = _e_5959;
            2'b?: _e_5951 = 33'dx;
        endcase
    end
    assign output__ = _e_5951;
endmodule

module \tta::mac::pick_mac_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::mac::pick_mac_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::mac::pick_mac_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/mac.spade:76,9" *)
    logic[42:0] _e_5972;
    (* src = "src/mac.spade:76,14" *)
    logic[31:0] \x ;
    logic _e_9731;
    logic _e_9733;
    logic _e_9735;
    logic _e_9736;
    (* src = "src/mac.spade:76,35" *)
    logic[32:0] _e_5974;
    (* src = "src/mac.spade:77,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:78,13" *)
    logic[42:0] _e_5980;
    (* src = "src/mac.spade:78,18" *)
    logic[31:0] x_n1;
    logic _e_9739;
    logic _e_9741;
    logic _e_9743;
    logic _e_9744;
    (* src = "src/mac.spade:78,39" *)
    logic[32:0] _e_5982;
    (* src = "src/mac.spade:79,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:79,18" *)
    logic[32:0] _e_5985;
    (* src = "src/mac.spade:77,14" *)
    logic[32:0] _e_5977;
    (* src = "src/mac.spade:75,5" *)
    logic[32:0] _e_5969;
    assign _e_5972 = \m1 [42:0];
    assign \x  = _e_5972[36:5];
    assign _e_9731 = \m1 [43] == 1'd1;
    assign _e_9733 = _e_5972[42:37] == 6'd25;
    localparam[0:0] _e_9734 = 1;
    assign _e_9735 = _e_9733 && _e_9734;
    assign _e_9736 = _e_9731 && _e_9735;
    assign _e_5974 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9737 = 1;
    assign _e_5980 = \m0 [42:0];
    assign x_n1 = _e_5980[36:5];
    assign _e_9739 = \m0 [43] == 1'd1;
    assign _e_9741 = _e_5980[42:37] == 6'd25;
    localparam[0:0] _e_9742 = 1;
    assign _e_9743 = _e_9741 && _e_9742;
    assign _e_9744 = _e_9739 && _e_9743;
    assign _e_5982 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9745 = 1;
    assign _e_5985 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9744, _e_9745})
            2'b1?: _e_5977 = _e_5982;
            2'b01: _e_5977 = _e_5985;
            2'b?: _e_5977 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9736, _e_9737})
            2'b1?: _e_5969 = _e_5974;
            2'b01: _e_5969 = _e_5977;
            2'b?: _e_5969 = 33'dx;
        endcase
    end
    assign output__ = _e_5969;
endmodule

module \tta::mac::pick_mac_clear  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::mac::pick_mac_clear" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::mac::pick_mac_clear );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/mac.spade:86,9" *)
    logic[42:0] _e_5990;
    (* src = "src/mac.spade:86,14" *)
    logic \x ;
    logic _e_9747;
    logic _e_9749;
    logic _e_9751;
    logic _e_9752;
    (* src = "src/mac.spade:87,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:88,13" *)
    logic[42:0] _e_5997;
    (* src = "src/mac.spade:88,18" *)
    logic x_n1;
    logic _e_9755;
    logic _e_9757;
    logic _e_9759;
    logic _e_9760;
    (* src = "src/mac.spade:89,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:87,14" *)
    logic _e_5994;
    (* src = "src/mac.spade:85,5" *)
    logic _e_5987;
    assign _e_5990 = \m1 [42:0];
    assign \x  = _e_5990[36:36];
    assign _e_9747 = \m1 [43] == 1'd1;
    assign _e_9749 = _e_5990[42:37] == 6'd26;
    localparam[0:0] _e_9750 = 1;
    assign _e_9751 = _e_9749 && _e_9750;
    assign _e_9752 = _e_9747 && _e_9751;
    assign \_  = \m1 ;
    localparam[0:0] _e_9753 = 1;
    assign _e_5997 = \m0 [42:0];
    assign x_n1 = _e_5997[36:36];
    assign _e_9755 = \m0 [43] == 1'd1;
    assign _e_9757 = _e_5997[42:37] == 6'd26;
    localparam[0:0] _e_9758 = 1;
    assign _e_9759 = _e_9757 && _e_9758;
    assign _e_9760 = _e_9755 && _e_9759;
    assign __n1 = \m0 ;
    localparam[0:0] _e_9761 = 1;
    localparam[0:0] _e_6001 = 0;
    always_comb begin
        priority casez ({_e_9760, _e_9761})
            2'b1?: _e_5994 = x_n1;
            2'b01: _e_5994 = _e_6001;
            2'b?: _e_5994 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9752, _e_9753})
            2'b1?: _e_5987 = \x ;
            2'b01: _e_5987 = _e_5994;
            2'b?: _e_5987 = 1'dx;
        endcase
    end
    assign output__ = _e_5987;
endmodule

module \tta::cmpz::cmpz_fu  (
        input clk_i,
        input rst_i,
        input[35:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmpz::cmpz_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmpz::cmpz_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[35:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/cmpz.spade:28,9" *)
    logic[34:0] _e_6007;
    (* src = "src/cmpz.spade:28,14" *)
    logic[2:0] _e_6005;
    (* src = "src/cmpz.spade:28,14" *)
    logic[31:0] \b ;
    logic _e_9763;
    logic _e_9766;
    logic _e_9768;
    logic _e_9769;
    (* src = "src/cmpz.spade:28,49" *)
    logic _e_6011;
    (* src = "src/cmpz.spade:28,42" *)
    logic[31:0] _e_6010;
    (* src = "src/cmpz.spade:28,37" *)
    logic[32:0] _e_6009;
    (* src = "src/cmpz.spade:29,9" *)
    logic[34:0] _e_6016;
    (* src = "src/cmpz.spade:29,14" *)
    logic[2:0] _e_6014;
    (* src = "src/cmpz.spade:29,14" *)
    logic[31:0] b_n1;
    logic _e_9771;
    logic _e_9774;
    logic _e_9776;
    logic _e_9777;
    (* src = "src/cmpz.spade:29,49" *)
    logic _e_6020;
    (* src = "src/cmpz.spade:29,42" *)
    logic[31:0] _e_6019;
    (* src = "src/cmpz.spade:29,37" *)
    logic[32:0] _e_6018;
    (* src = "src/cmpz.spade:30,9" *)
    logic[34:0] _e_6025;
    (* src = "src/cmpz.spade:30,14" *)
    logic[2:0] _e_6023;
    (* src = "src/cmpz.spade:30,14" *)
    logic[31:0] b_n2;
    logic _e_9779;
    logic _e_9782;
    logic _e_9784;
    logic _e_9785;
    (* src = "src/cmpz.spade:30,49" *)
    logic _e_6030;
    (* src = "src/cmpz.spade:30,49" *)
    logic _e_6029;
    (* src = "src/cmpz.spade:30,42" *)
    logic[31:0] _e_6028;
    (* src = "src/cmpz.spade:30,37" *)
    logic[32:0] _e_6027;
    (* src = "src/cmpz.spade:31,9" *)
    logic[34:0] _e_6035;
    (* src = "src/cmpz.spade:31,14" *)
    logic[2:0] _e_6033;
    (* src = "src/cmpz.spade:31,14" *)
    logic[31:0] b_n3;
    logic _e_9787;
    logic _e_9790;
    logic _e_9792;
    logic _e_9793;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6041;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6040;
    (* src = "src/cmpz.spade:31,67" *)
    logic _e_6044;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6039;
    (* src = "src/cmpz.spade:31,42" *)
    logic[31:0] _e_6038;
    (* src = "src/cmpz.spade:31,37" *)
    logic[32:0] _e_6037;
    (* src = "src/cmpz.spade:32,9" *)
    logic[34:0] _e_6049;
    (* src = "src/cmpz.spade:32,14" *)
    logic[2:0] _e_6047;
    (* src = "src/cmpz.spade:32,14" *)
    logic[31:0] b_n4;
    logic _e_9795;
    logic _e_9798;
    logic _e_9800;
    logic _e_9801;
    (* src = "src/cmpz.spade:32,49" *)
    logic _e_6055;
    (* src = "src/cmpz.spade:32,49" *)
    logic _e_6054;
    (* src = "src/cmpz.spade:32,67" *)
    logic _e_6058;
    (* src = "src/cmpz.spade:32,49" *)
    logic _e_6053;
    (* src = "src/cmpz.spade:32,42" *)
    logic[31:0] _e_6052;
    (* src = "src/cmpz.spade:32,37" *)
    logic[32:0] _e_6051;
    (* src = "src/cmpz.spade:33,9" *)
    logic[34:0] _e_6063;
    (* src = "src/cmpz.spade:33,14" *)
    logic[2:0] _e_6061;
    (* src = "src/cmpz.spade:33,14" *)
    logic[31:0] b_n5;
    logic _e_9803;
    logic _e_9806;
    logic _e_9808;
    logic _e_9809;
    (* src = "src/cmpz.spade:33,49" *)
    logic _e_6068;
    (* src = "src/cmpz.spade:33,49" *)
    logic _e_6067;
    (* src = "src/cmpz.spade:33,42" *)
    logic[31:0] _e_6066;
    (* src = "src/cmpz.spade:33,37" *)
    logic[32:0] _e_6065;
    logic _e_9811;
    (* src = "src/cmpz.spade:34,37" *)
    logic[32:0] _e_6072;
    (* src = "src/cmpz.spade:27,36" *)
    logic[32:0] \result ;
    (* src = "src/cmpz.spade:38,51" *)
    logic[32:0] _e_6077;
    (* src = "src/cmpz.spade:38,14" *)
    reg[32:0] \res_reg ;
    assign _e_6007 = \trig [34:0];
    assign _e_6005 = _e_6007[34:32];
    assign \b  = _e_6007[31:0];
    assign _e_9763 = \trig [35] == 1'd1;
    assign _e_9766 = _e_6005[2:0] == 3'd0;
    localparam[0:0] _e_9767 = 1;
    assign _e_9768 = _e_9766 && _e_9767;
    assign _e_9769 = _e_9763 && _e_9768;
    localparam[31:0] _e_6013 = 32'd0;
    assign _e_6011 = \b  == _e_6013;
    (* src = "src/cmpz.spade:28,42" *)
    \tta::cmpz::to_u32  to_u32_0(.x_i(_e_6011), .output__(_e_6010));
    assign _e_6009 = {1'd1, _e_6010};
    assign _e_6016 = \trig [34:0];
    assign _e_6014 = _e_6016[34:32];
    assign b_n1 = _e_6016[31:0];
    assign _e_9771 = \trig [35] == 1'd1;
    assign _e_9774 = _e_6014[2:0] == 3'd1;
    localparam[0:0] _e_9775 = 1;
    assign _e_9776 = _e_9774 && _e_9775;
    assign _e_9777 = _e_9771 && _e_9776;
    localparam[31:0] _e_6022 = 32'd0;
    assign _e_6020 = b_n1 != _e_6022;
    (* src = "src/cmpz.spade:29,42" *)
    \tta::cmpz::to_u32  to_u32_1(.x_i(_e_6020), .output__(_e_6019));
    assign _e_6018 = {1'd1, _e_6019};
    assign _e_6025 = \trig [34:0];
    assign _e_6023 = _e_6025[34:32];
    assign b_n2 = _e_6025[31:0];
    assign _e_9779 = \trig [35] == 1'd1;
    assign _e_9782 = _e_6023[2:0] == 3'd2;
    localparam[0:0] _e_9783 = 1;
    assign _e_9784 = _e_9782 && _e_9783;
    assign _e_9785 = _e_9779 && _e_9784;
    (* src = "src/cmpz.spade:30,49" *)
    \tta::cmpz::msb1  msb1_0(.x_i(b_n2), .output__(_e_6030));
    localparam[0:0] _e_6032 = 1;
    assign _e_6029 = _e_6030 == _e_6032;
    (* src = "src/cmpz.spade:30,42" *)
    \tta::cmpz::to_u32  to_u32_2(.x_i(_e_6029), .output__(_e_6028));
    assign _e_6027 = {1'd1, _e_6028};
    assign _e_6035 = \trig [34:0];
    assign _e_6033 = _e_6035[34:32];
    assign b_n3 = _e_6035[31:0];
    assign _e_9787 = \trig [35] == 1'd1;
    assign _e_9790 = _e_6033[2:0] == 3'd3;
    localparam[0:0] _e_9791 = 1;
    assign _e_9792 = _e_9790 && _e_9791;
    assign _e_9793 = _e_9787 && _e_9792;
    (* src = "src/cmpz.spade:31,49" *)
    \tta::cmpz::msb1  msb1_1(.x_i(b_n3), .output__(_e_6041));
    localparam[0:0] _e_6043 = 1;
    assign _e_6040 = _e_6041 == _e_6043;
    localparam[31:0] _e_6046 = 32'd0;
    assign _e_6044 = b_n3 == _e_6046;
    assign _e_6039 = _e_6040 || _e_6044;
    (* src = "src/cmpz.spade:31,42" *)
    \tta::cmpz::to_u32  to_u32_3(.x_i(_e_6039), .output__(_e_6038));
    assign _e_6037 = {1'd1, _e_6038};
    assign _e_6049 = \trig [34:0];
    assign _e_6047 = _e_6049[34:32];
    assign b_n4 = _e_6049[31:0];
    assign _e_9795 = \trig [35] == 1'd1;
    assign _e_9798 = _e_6047[2:0] == 3'd4;
    localparam[0:0] _e_9799 = 1;
    assign _e_9800 = _e_9798 && _e_9799;
    assign _e_9801 = _e_9795 && _e_9800;
    (* src = "src/cmpz.spade:32,49" *)
    \tta::cmpz::msb1  msb1_2(.x_i(b_n4), .output__(_e_6055));
    localparam[0:0] _e_6057 = 1;
    assign _e_6054 = _e_6055 != _e_6057;
    localparam[31:0] _e_6060 = 32'd0;
    assign _e_6058 = b_n4 != _e_6060;
    assign _e_6053 = _e_6054 && _e_6058;
    (* src = "src/cmpz.spade:32,42" *)
    \tta::cmpz::to_u32  to_u32_4(.x_i(_e_6053), .output__(_e_6052));
    assign _e_6051 = {1'd1, _e_6052};
    assign _e_6063 = \trig [34:0];
    assign _e_6061 = _e_6063[34:32];
    assign b_n5 = _e_6063[31:0];
    assign _e_9803 = \trig [35] == 1'd1;
    assign _e_9806 = _e_6061[2:0] == 3'd5;
    localparam[0:0] _e_9807 = 1;
    assign _e_9808 = _e_9806 && _e_9807;
    assign _e_9809 = _e_9803 && _e_9808;
    (* src = "src/cmpz.spade:33,49" *)
    \tta::cmpz::msb1  msb1_3(.x_i(b_n5), .output__(_e_6068));
    localparam[0:0] _e_6070 = 1;
    assign _e_6067 = _e_6068 != _e_6070;
    (* src = "src/cmpz.spade:33,42" *)
    \tta::cmpz::to_u32  to_u32_5(.x_i(_e_6067), .output__(_e_6066));
    assign _e_6065 = {1'd1, _e_6066};
    assign _e_9811 = \trig [35] == 1'd0;
    assign _e_6072 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9769, _e_9777, _e_9785, _e_9793, _e_9801, _e_9809, _e_9811})
            7'b1??????: \result  = _e_6009;
            7'b01?????: \result  = _e_6018;
            7'b001????: \result  = _e_6027;
            7'b0001???: \result  = _e_6037;
            7'b00001??: \result  = _e_6051;
            7'b000001?: \result  = _e_6065;
            7'b0000001: \result  = _e_6072;
            7'b?: \result  = 33'dx;
        endcase
    end
    assign _e_6077 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_6077;
        end
        else begin
            \res_reg  <= \result ;
        end
    end
    assign output__ = \res_reg ;
endmodule

module \tta::cmpz::pick_cmpz_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[35:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmpz::pick_cmpz_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmpz::pick_cmpz_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/cmpz.spade:45,9" *)
    logic[42:0] _e_6085;
    (* src = "src/cmpz.spade:45,14" *)
    logic[2:0] \op ;
    (* src = "src/cmpz.spade:45,14" *)
    logic[31:0] \x ;
    logic _e_9813;
    logic _e_9815;
    logic _e_9818;
    logic _e_9819;
    logic _e_9820;
    (* src = "src/cmpz.spade:45,45" *)
    logic[34:0] _e_6088;
    (* src = "src/cmpz.spade:45,40" *)
    logic[35:0] _e_6087;
    (* src = "src/cmpz.spade:46,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmpz.spade:47,13" *)
    logic[42:0] _e_6096;
    (* src = "src/cmpz.spade:47,18" *)
    logic[2:0] op_n1;
    (* src = "src/cmpz.spade:47,18" *)
    logic[31:0] x_n1;
    logic _e_9823;
    logic _e_9825;
    logic _e_9828;
    logic _e_9829;
    logic _e_9830;
    (* src = "src/cmpz.spade:47,49" *)
    logic[34:0] _e_6099;
    (* src = "src/cmpz.spade:47,44" *)
    logic[35:0] _e_6098;
    (* src = "src/cmpz.spade:48,13" *)
    logic[43:0] __n1;
    (* src = "src/cmpz.spade:48,18" *)
    logic[35:0] _e_6103;
    (* src = "src/cmpz.spade:46,14" *)
    logic[35:0] _e_6092;
    (* src = "src/cmpz.spade:44,5" *)
    logic[35:0] _e_6081;
    assign _e_6085 = \m1 [42:0];
    assign \op  = _e_6085[36:34];
    assign \x  = _e_6085[33:2];
    assign _e_9813 = \m1 [43] == 1'd1;
    assign _e_9815 = _e_6085[42:37] == 6'd13;
    localparam[0:0] _e_9816 = 1;
    localparam[0:0] _e_9817 = 1;
    assign _e_9818 = _e_9815 && _e_9816;
    assign _e_9819 = _e_9818 && _e_9817;
    assign _e_9820 = _e_9813 && _e_9819;
    assign _e_6088 = {\op , \x };
    assign _e_6087 = {1'd1, _e_6088};
    assign \_  = \m1 ;
    localparam[0:0] _e_9821 = 1;
    assign _e_6096 = \m0 [42:0];
    assign op_n1 = _e_6096[36:34];
    assign x_n1 = _e_6096[33:2];
    assign _e_9823 = \m0 [43] == 1'd1;
    assign _e_9825 = _e_6096[42:37] == 6'd13;
    localparam[0:0] _e_9826 = 1;
    localparam[0:0] _e_9827 = 1;
    assign _e_9828 = _e_9825 && _e_9826;
    assign _e_9829 = _e_9828 && _e_9827;
    assign _e_9830 = _e_9823 && _e_9829;
    assign _e_6099 = {op_n1, x_n1};
    assign _e_6098 = {1'd1, _e_6099};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9831 = 1;
    assign _e_6103 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_9830, _e_9831})
            2'b1?: _e_6092 = _e_6098;
            2'b01: _e_6092 = _e_6103;
            2'b?: _e_6092 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9820, _e_9821})
            2'b1?: _e_6081 = _e_6087;
            2'b01: _e_6081 = _e_6092;
            2'b?: _e_6081 = 36'dx;
        endcase
    end
    assign output__ = _e_6081;
endmodule

module \tta::cmpz::msb1  (
        input[31:0] x_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmpz::msb1" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmpz::msb1 );
        end
    end
    `endif
    logic[31:0] \x ;
    assign \x  = x_i;
    (* src = "src/cmpz.spade:53,41" *)
    logic[31:0] _e_6107;
    (* src = "src/cmpz.spade:53,41" *)
    logic[31:0] _e_6106;
    (* src = "src/cmpz.spade:53,35" *)
    logic _e_6105;
    localparam[31:0] _e_6109 = 32'd31;
    assign _e_6107 = \x  >> _e_6109;
    localparam[31:0] _e_6110 = 32'd1;
    assign _e_6106 = _e_6107 & _e_6110;
    assign _e_6105 = _e_6106[0:0];
    assign output__ = _e_6105;
endmodule

module \tta::cmpz::to_u32  (
        input x_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cmpz::to_u32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cmpz::to_u32 );
        end
    end
    `endif
    logic \x ;
    assign \x  = x_i;
    (* src = "src/cmpz.spade:54,34" *)
    logic[31:0] _e_6112;
    localparam[31:0] _e_6115 = 32'd1;
    localparam[31:0] _e_6117 = 32'd0;
    assign _e_6112 = \x  ? _e_6115 : _e_6117;
    assign output__ = _e_6112;
endmodule

module \tta::div_shiftsub::reset_div  (
        output[134:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::div_shiftsub::reset_div" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::div_shiftsub::reset_div );
        end
    end
    `endif
    (* src = "src/div_shiftsub.spade:28,13" *)
    logic _e_6120;
    (* src = "src/div_shiftsub.spade:28,5" *)
    logic[134:0] _e_6119;
    assign _e_6120 = {1'd0};
    localparam[31:0] _e_6121 = 32'd0;
    localparam[31:0] _e_6122 = 32'd0;
    localparam[31:0] _e_6123 = 32'd0;
    localparam[31:0] _e_6124 = 32'd0;
    localparam[5:0] _e_6125 = 0;
    assign _e_6119 = {_e_6120, _e_6121, _e_6122, _e_6123, _e_6124, _e_6125};
    assign output__ = _e_6119;
endmodule

module \tta::div_shiftsub::div_shiftsub_fu  (
        input clk_i,
        input rst_i,
        input[32:0] set_op_a_i,
        input[32:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::div_shiftsub::div_shiftsub_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::div_shiftsub::div_shiftsub_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_op_a ;
    assign \set_op_a  = set_op_a_i;
    logic[32:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/div_shiftsub.spade:37,36" *)
    logic[134:0] _e_6130;
    (* src = "src/div_shiftsub.spade:37,57" *)
    logic _e_6132;
    (* src = "src/div_shiftsub.spade:38,9" *)
    logic _e_6134;
    logic _e_9833;
    (* src = "src/div_shiftsub.spade:41,17" *)
    logic[31:0] \val ;
    logic _e_9835;
    logic _e_9837;
    logic _e_9839;
    (* src = "src/div_shiftsub.spade:42,25" *)
    logic[31:0] _e_6142;
    (* src = "src/div_shiftsub.spade:40,33" *)
    logic[31:0] \next_dividend ;
    (* src = "src/div_shiftsub.spade:46,17" *)
    logic[31:0] \divisor ;
    logic _e_9841;
    logic _e_9843;
    (* src = "src/div_shiftsub.spade:46,42" *)
    logic _e_6150;
    (* src = "src/div_shiftsub.spade:46,34" *)
    logic[134:0] _e_6149;
    logic _e_9845;
    (* src = "src/div_shiftsub.spade:47,33" *)
    logic _e_6158;
    (* src = "src/div_shiftsub.spade:47,25" *)
    logic[134:0] _e_6157;
    (* src = "src/div_shiftsub.spade:45,13" *)
    logic[134:0] _e_6145;
    (* src = "src/div_shiftsub.spade:50,9" *)
    logic _e_6164;
    logic _e_9847;
    (* src = "src/div_shiftsub.spade:52,33" *)
    logic[31:0] _e_6167;
    (* src = "src/div_shiftsub.spade:52,32" *)
    logic[31:0] \msb_dividend ;
    (* src = "src/div_shiftsub.spade:53,32" *)
    logic[31:0] _e_6173;
    (* src = "src/div_shiftsub.spade:53,31" *)
    logic[31:0] _e_6172;
    (* src = "src/div_shiftsub.spade:53,31" *)
    logic[31:0] \rem_shifted ;
    (* src = "src/div_shiftsub.spade:54,31" *)
    logic[31:0] _e_6179;
    (* src = "src/div_shiftsub.spade:54,31" *)
    logic[31:0] \dvd_shifted ;
    (* src = "src/div_shiftsub.spade:57,42" *)
    logic[31:0] _e_6185;
    (* src = "src/div_shiftsub.spade:57,27" *)
    logic \can_sub ;
    (* src = "src/div_shiftsub.spade:61,38" *)
    logic[31:0] _e_6195;
    (* src = "src/div_shiftsub.spade:61,24" *)
    logic[32:0] _e_6193;
    (* src = "src/div_shiftsub.spade:61,18" *)
    logic[31:0] _e_6192;
    (* src = "src/div_shiftsub.spade:61,17" *)
    logic[63:0] _e_6191;
    (* src = "src/div_shiftsub.spade:63,17" *)
    logic[63:0] _e_6199;
    (* src = "src/div_shiftsub.spade:60,40" *)
    logic[63:0] _e_6204;
    (* src = "src/div_shiftsub.spade:60,17" *)
    logic[31:0] \next_rem ;
    (* src = "src/div_shiftsub.spade:60,17" *)
    logic[31:0] \quot_bit ;
    (* src = "src/div_shiftsub.spade:66,30" *)
    logic[31:0] _e_6207;
    (* src = "src/div_shiftsub.spade:66,29" *)
    logic[31:0] _e_6206;
    (* src = "src/div_shiftsub.spade:66,29" *)
    logic[31:0] \next_quot ;
    (* src = "src/div_shiftsub.spade:68,16" *)
    logic[5:0] _e_6214;
    (* src = "src/div_shiftsub.spade:68,16" *)
    logic _e_6213;
    (* src = "src/div_shiftsub.spade:70,17" *)
    logic[134:0] _e_6218;
    (* src = "src/div_shiftsub.spade:73,25" *)
    logic _e_6221;
    (* src = "src/div_shiftsub.spade:73,51" *)
    logic[31:0] _e_6223;
    (* src = "src/div_shiftsub.spade:73,89" *)
    logic[5:0] _e_6229;
    (* src = "src/div_shiftsub.spade:73,89" *)
    logic[6:0] _e_6228;
    (* src = "src/div_shiftsub.spade:73,83" *)
    logic[5:0] _e_6227;
    (* src = "src/div_shiftsub.spade:73,17" *)
    logic[134:0] _e_6220;
    (* src = "src/div_shiftsub.spade:68,13" *)
    logic[134:0] _e_6212;
    (* src = "src/div_shiftsub.spade:37,51" *)
    logic[134:0] _e_6131;
    (* src = "src/div_shiftsub.spade:37,14" *)
    reg[134:0] \r ;
    (* src = "src/div_shiftsub.spade:82,11" *)
    logic _e_6233;
    (* src = "src/div_shiftsub.spade:83,9" *)
    logic _e_6235;
    logic _e_9849;
    (* src = "src/div_shiftsub.spade:84,16" *)
    logic[5:0] _e_6239;
    (* src = "src/div_shiftsub.spade:84,16" *)
    logic _e_6238;
    (* src = "src/div_shiftsub.spade:86,37" *)
    logic[31:0] _e_6244;
    (* src = "src/div_shiftsub.spade:86,36" *)
    logic[31:0] msb_dividend_n1;
    (* src = "src/div_shiftsub.spade:87,36" *)
    logic[31:0] _e_6250;
    (* src = "src/div_shiftsub.spade:87,35" *)
    logic[31:0] _e_6249;
    (* src = "src/div_shiftsub.spade:87,35" *)
    logic[31:0] rem_shifted_n1;
    (* src = "src/div_shiftsub.spade:88,46" *)
    logic[31:0] _e_6257;
    (* src = "src/div_shiftsub.spade:88,31" *)
    logic can_sub_n1;
    (* src = "src/div_shiftsub.spade:89,32" *)
    logic[31:0] quot_bit_n1;
    (* src = "src/div_shiftsub.spade:91,23" *)
    logic[31:0] _e_6270;
    (* src = "src/div_shiftsub.spade:91,22" *)
    logic[31:0] _e_6269;
    (* src = "src/div_shiftsub.spade:91,22" *)
    logic[31:0] _e_6268;
    (* src = "src/div_shiftsub.spade:91,17" *)
    logic[32:0] _e_6267;
    (* src = "src/div_shiftsub.spade:93,17" *)
    logic[32:0] _e_6275;
    (* src = "src/div_shiftsub.spade:84,13" *)
    logic[32:0] _e_6237;
    (* src = "src/div_shiftsub.spade:96,9" *)
    logic \_ ;
    (* src = "src/div_shiftsub.spade:96,14" *)
    logic[32:0] _e_6277;
    (* src = "src/div_shiftsub.spade:82,5" *)
    logic[32:0] _e_6232;
    (* src = "src/div_shiftsub.spade:37,36" *)
    \tta::div_shiftsub::reset_div  reset_div_0(.output__(_e_6130));
    assign _e_6132 = \r [134];
    assign _e_6134 = _e_6132;
    assign _e_9833 = _e_6132 == 1'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9835 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9836 = 1;
    assign _e_9837 = _e_9835 && _e_9836;
    assign _e_9839 = \set_op_a [32] == 1'd0;
    assign _e_6142 = \r [133:102];
    always_comb begin
        priority casez ({_e_9837, _e_9839})
            2'b1?: \next_dividend  = \val ;
            2'b01: \next_dividend  = _e_6142;
            2'b?: \next_dividend  = 32'dx;
        endcase
    end
    assign \divisor  = \trig [31:0];
    assign _e_9841 = \trig [32] == 1'd1;
    localparam[0:0] _e_9842 = 1;
    assign _e_9843 = _e_9841 && _e_9842;
    assign _e_6150 = {1'd1};
    localparam[31:0] _e_6153 = 32'd0;
    localparam[31:0] _e_6154 = 32'd0;
    localparam[5:0] _e_6155 = 0;
    assign _e_6149 = {_e_6150, \next_dividend , \divisor , _e_6153, _e_6154, _e_6155};
    assign _e_9845 = \trig [32] == 1'd0;
    assign _e_6158 = {1'd0};
    localparam[31:0] _e_6160 = 32'd0;
    localparam[31:0] _e_6161 = 32'd0;
    localparam[31:0] _e_6162 = 32'd0;
    localparam[5:0] _e_6163 = 0;
    assign _e_6157 = {_e_6158, \next_dividend , _e_6160, _e_6161, _e_6162, _e_6163};
    always_comb begin
        priority casez ({_e_9843, _e_9845})
            2'b1?: _e_6145 = _e_6149;
            2'b01: _e_6145 = _e_6157;
            2'b?: _e_6145 = 135'dx;
        endcase
    end
    assign _e_6164 = _e_6132;
    assign _e_9847 = _e_6132 == 1'd1;
    assign _e_6167 = \r [133:102];
    localparam[31:0] _e_6169 = 32'd31;
    assign \msb_dividend  = _e_6167 >> _e_6169;
    assign _e_6173 = \r [69:38];
    localparam[31:0] _e_6175 = 32'd1;
    assign _e_6172 = _e_6173 << _e_6175;
    assign \rem_shifted  = _e_6172 | \msb_dividend ;
    assign _e_6179 = \r [133:102];
    localparam[31:0] _e_6181 = 32'd1;
    assign \dvd_shifted  = _e_6179 << _e_6181;
    assign _e_6185 = \r [101:70];
    assign \can_sub  = \rem_shifted  >= _e_6185;
    assign _e_6195 = \r [101:70];
    assign _e_6193 = \rem_shifted  - _e_6195;
    assign _e_6192 = _e_6193[31:0];
    localparam[31:0] _e_6197 = 32'd1;
    assign _e_6191 = {_e_6192, _e_6197};
    localparam[31:0] _e_6201 = 32'd0;
    assign _e_6199 = {\rem_shifted , _e_6201};
    assign _e_6204 = \can_sub  ? _e_6191 : _e_6199;
    assign \next_rem  = _e_6204[63:32];
    assign \quot_bit  = _e_6204[31:0];
    assign _e_6207 = \r [37:6];
    localparam[31:0] _e_6209 = 32'd1;
    assign _e_6206 = _e_6207 << _e_6209;
    assign \next_quot  = _e_6206 | \quot_bit ;
    assign _e_6214 = \r [5:0];
    localparam[5:0] _e_6216 = 31;
    assign _e_6213 = _e_6214 == _e_6216;
    (* src = "src/div_shiftsub.spade:70,17" *)
    \tta::div_shiftsub::reset_div  reset_div_1(.output__(_e_6218));
    assign _e_6221 = {1'd1};
    assign _e_6223 = \r [101:70];
    assign _e_6229 = \r [5:0];
    localparam[5:0] _e_6231 = 1;
    assign _e_6228 = _e_6229 + _e_6231;
    assign _e_6227 = _e_6228[5:0];
    assign _e_6220 = {_e_6221, \dvd_shifted , _e_6223, \next_rem , \next_quot , _e_6227};
    assign _e_6212 = _e_6213 ? _e_6218 : _e_6220;
    always_comb begin
        priority casez ({_e_9833, _e_9847})
            2'b1?: _e_6131 = _e_6145;
            2'b01: _e_6131 = _e_6212;
            2'b?: _e_6131 = 135'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_6130;
        end
        else begin
            \r  <= _e_6131;
        end
    end
    assign _e_6233 = \r [134];
    assign _e_6235 = _e_6233;
    assign _e_9849 = _e_6233 == 1'd1;
    assign _e_6239 = \r [5:0];
    localparam[5:0] _e_6241 = 31;
    assign _e_6238 = _e_6239 == _e_6241;
    assign _e_6244 = \r [133:102];
    localparam[31:0] _e_6246 = 32'd31;
    assign msb_dividend_n1 = _e_6244 >> _e_6246;
    assign _e_6250 = \r [69:38];
    localparam[31:0] _e_6252 = 32'd1;
    assign _e_6249 = _e_6250 << _e_6252;
    assign rem_shifted_n1 = _e_6249 | msb_dividend_n1;
    assign _e_6257 = \r [101:70];
    assign can_sub_n1 = rem_shifted_n1 >= _e_6257;
    localparam[31:0] _e_6263 = 32'd1;
    localparam[31:0] _e_6265 = 32'd0;
    assign quot_bit_n1 = can_sub_n1 ? _e_6263 : _e_6265;
    assign _e_6270 = \r [37:6];
    localparam[31:0] _e_6272 = 32'd1;
    assign _e_6269 = _e_6270 << _e_6272;
    assign _e_6268 = _e_6269 | quot_bit_n1;
    assign _e_6267 = {1'd1, _e_6268};
    assign _e_6275 = {1'd0, 32'bX};
    assign _e_6237 = _e_6238 ? _e_6267 : _e_6275;
    assign \_  = _e_6233;
    localparam[0:0] _e_9850 = 1;
    assign _e_6277 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9849, _e_9850})
            2'b1?: _e_6232 = _e_6237;
            2'b01: _e_6232 = _e_6277;
            2'b?: _e_6232 = 33'dx;
        endcase
    end
    assign output__ = _e_6232;
endmodule

module \tta::div_shiftsub::pick_div_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::div_shiftsub::pick_div_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::div_shiftsub::pick_div_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/div_shiftsub.spade:103,5" *)
    logic[42:0] _e_6282;
    (* src = "src/div_shiftsub.spade:103,10" *)
    logic[31:0] \x ;
    logic _e_9852;
    logic _e_9854;
    logic _e_9856;
    logic _e_9857;
    (* src = "src/div_shiftsub.spade:103,31" *)
    logic[32:0] _e_6284;
    (* src = "src/div_shiftsub.spade:104,5" *)
    logic[43:0] \_ ;
    (* src = "src/div_shiftsub.spade:104,21" *)
    logic[42:0] _e_6290;
    (* src = "src/div_shiftsub.spade:104,26" *)
    logic[31:0] x_n1;
    logic _e_9860;
    logic _e_9862;
    logic _e_9864;
    logic _e_9865;
    (* src = "src/div_shiftsub.spade:104,47" *)
    logic[32:0] _e_6292;
    (* src = "src/div_shiftsub.spade:104,56" *)
    logic[43:0] __n1;
    (* src = "src/div_shiftsub.spade:104,61" *)
    logic[32:0] _e_6295;
    (* src = "src/div_shiftsub.spade:104,10" *)
    logic[32:0] _e_6287;
    (* src = "src/div_shiftsub.spade:102,3" *)
    logic[32:0] _e_6279;
    assign _e_6282 = \m1 [42:0];
    assign \x  = _e_6282[36:5];
    assign _e_9852 = \m1 [43] == 1'd1;
    assign _e_9854 = _e_6282[42:37] == 6'd21;
    localparam[0:0] _e_9855 = 1;
    assign _e_9856 = _e_9854 && _e_9855;
    assign _e_9857 = _e_9852 && _e_9856;
    assign _e_6284 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9858 = 1;
    assign _e_6290 = \m0 [42:0];
    assign x_n1 = _e_6290[36:5];
    assign _e_9860 = \m0 [43] == 1'd1;
    assign _e_9862 = _e_6290[42:37] == 6'd21;
    localparam[0:0] _e_9863 = 1;
    assign _e_9864 = _e_9862 && _e_9863;
    assign _e_9865 = _e_9860 && _e_9864;
    assign _e_6292 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9866 = 1;
    assign _e_6295 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9865, _e_9866})
            2'b1?: _e_6287 = _e_6292;
            2'b01: _e_6287 = _e_6295;
            2'b?: _e_6287 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9857, _e_9858})
            2'b1?: _e_6279 = _e_6284;
            2'b01: _e_6279 = _e_6287;
            2'b?: _e_6279 = 33'dx;
        endcase
    end
    assign output__ = _e_6279;
endmodule

module \tta::div_shiftsub::pick_div_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::div_shiftsub::pick_div_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::div_shiftsub::pick_div_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/div_shiftsub.spade:110,5" *)
    logic[42:0] _e_6300;
    (* src = "src/div_shiftsub.spade:110,10" *)
    logic[31:0] \x ;
    logic _e_9868;
    logic _e_9870;
    logic _e_9872;
    logic _e_9873;
    (* src = "src/div_shiftsub.spade:110,31" *)
    logic[32:0] _e_6302;
    (* src = "src/div_shiftsub.spade:111,5" *)
    logic[43:0] \_ ;
    (* src = "src/div_shiftsub.spade:111,21" *)
    logic[42:0] _e_6308;
    (* src = "src/div_shiftsub.spade:111,26" *)
    logic[31:0] x_n1;
    logic _e_9876;
    logic _e_9878;
    logic _e_9880;
    logic _e_9881;
    (* src = "src/div_shiftsub.spade:111,47" *)
    logic[32:0] _e_6310;
    (* src = "src/div_shiftsub.spade:111,56" *)
    logic[43:0] __n1;
    (* src = "src/div_shiftsub.spade:111,61" *)
    logic[32:0] _e_6313;
    (* src = "src/div_shiftsub.spade:111,10" *)
    logic[32:0] _e_6305;
    (* src = "src/div_shiftsub.spade:109,3" *)
    logic[32:0] _e_6297;
    assign _e_6300 = \m1 [42:0];
    assign \x  = _e_6300[36:5];
    assign _e_9868 = \m1 [43] == 1'd1;
    assign _e_9870 = _e_6300[42:37] == 6'd22;
    localparam[0:0] _e_9871 = 1;
    assign _e_9872 = _e_9870 && _e_9871;
    assign _e_9873 = _e_9868 && _e_9872;
    assign _e_6302 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9874 = 1;
    assign _e_6308 = \m0 [42:0];
    assign x_n1 = _e_6308[36:5];
    assign _e_9876 = \m0 [43] == 1'd1;
    assign _e_9878 = _e_6308[42:37] == 6'd22;
    localparam[0:0] _e_9879 = 1;
    assign _e_9880 = _e_9878 && _e_9879;
    assign _e_9881 = _e_9876 && _e_9880;
    assign _e_6310 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9882 = 1;
    assign _e_6313 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9881, _e_9882})
            2'b1?: _e_6305 = _e_6310;
            2'b01: _e_6305 = _e_6313;
            2'b?: _e_6305 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9873, _e_9874})
            2'b1?: _e_6297 = _e_6302;
            2'b01: _e_6297 = _e_6305;
            2'b?: _e_6297 = 33'dx;
        endcase
    end
    assign output__ = _e_6297;
endmodule

module \tta::boot_imem_subsystem::boot_imem_sub  (
        `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input[8:0] rx_opt_i,
        input[9:0] fetch_pc_i,
        output[109:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::boot_imem_subsystem::boot_imem_sub" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::boot_imem_subsystem::boot_imem_sub );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[8:0] \rx_opt ;
    assign \rx_opt  = rx_opt_i;
    logic[9:0] \fetch_pc ;
    assign \fetch_pc  = fetch_pc_i;
    (* src = "src/boot_imem_subsystem.spade:35,7" *)
    logic[7:0] \b ;
    logic _e_9884;
    logic _e_9886;
    (* src = "src/boot_imem_subsystem.spade:35,18" *)
    logic[8:0] _e_6319;
    logic _e_9888;
    (* src = "src/boot_imem_subsystem.spade:36,18" *)
    logic[8:0] _e_6323;
    (* src = "src/boot_imem_subsystem.spade:34,5" *)
    logic[8:0] _e_6328;
    (* src = "src/boot_imem_subsystem.spade:33,7" *)
    logic \byte_valid ;
    (* src = "src/boot_imem_subsystem.spade:33,7" *)
    logic[7:0] \byte ;
    (* src = "src/boot_imem_subsystem.spade:41,12" *)
    logic[88:0] \bl ;
    (* src = "src/boot_imem_subsystem.spade:44,25" *)
    logic _e_6337;
    (* src = "src/boot_imem_subsystem.spade:44,18" *)
    logic \core_rst ;
    (* src = "src/boot_imem_subsystem.spade:47,43" *)
    logic _e_6344;
    (* src = "src/boot_imem_subsystem.spade:47,12" *)
    reg \boot_q ;
    (* src = "src/boot_imem_subsystem.spade:48,36" *)
    logic _e_6349;
    (* src = "src/boot_imem_subsystem.spade:48,35" *)
    logic _e_6348;
    (* src = "src/boot_imem_subsystem.spade:48,25" *)
    logic \boot_fall ;
    (* src = "src/boot_imem_subsystem.spade:51,23" *)
    logic[10:0] _e_6355;
    (* src = "src/boot_imem_subsystem.spade:51,11" *)
    logic[11:0] _e_6353;
    (* src = "src/boot_imem_subsystem.spade:52,7" *)
    logic[11:0] _e_6360;
    (* src = "src/boot_imem_subsystem.spade:52,7" *)
    logic _e_6357;
    (* src = "src/boot_imem_subsystem.spade:52,7" *)
    logic[10:0] _e_6359;
    (* src = "src/boot_imem_subsystem.spade:52,14" *)
    logic[9:0] \e ;
    logic _e_9892;
    logic _e_9894;
    logic _e_9895;
    (* src = "src/boot_imem_subsystem.spade:52,26" *)
    logic[10:0] _e_6361;
    (* src = "src/boot_imem_subsystem.spade:53,7" *)
    logic[11:0] \_ ;
    (* src = "src/boot_imem_subsystem.spade:53,27" *)
    logic[10:0] _e_6364;
    (* src = "src/boot_imem_subsystem.spade:51,5" *)
    logic[10:0] \pc_release ;
    (* src = "src/boot_imem_subsystem.spade:60,13" *)
    logic[97:0] _e_6369;
    logic _e_9898;
    (* src = "src/boot_imem_subsystem.spade:66,11" *)
    logic[10:0] _e_6379;
    (* src = "src/boot_imem_subsystem.spade:66,23" *)
    logic[32:0] _e_6381;
    (* src = "src/boot_imem_subsystem.spade:66,36" *)
    logic[32:0] _e_6383;
    (* src = "src/boot_imem_subsystem.spade:62,13" *)
    logic[98:0] _e_6373;
    (* src = "src/boot_imem_subsystem.spade:68,11" *)
    logic[98:0] _e_6386;
    (* src = "src/boot_imem_subsystem.spade:68,11" *)
    logic[97:0] \v ;
    logic _e_9900;
    logic _e_9902;
    (* src = "src/boot_imem_subsystem.spade:69,11" *)
    logic[98:0] _e_6388;
    logic _e_9904;
    (* src = "src/boot_imem_subsystem.spade:69,19" *)
    logic[97:0] _e_6389;
    (* src = "src/boot_imem_subsystem.spade:62,7" *)
    logic[97:0] _e_6372;
    (* src = "src/boot_imem_subsystem.spade:59,15" *)
    logic[97:0] \instr ;
    (* src = "src/boot_imem_subsystem.spade:74,3" *)
    logic[109:0] _e_6391;
    assign \b  = \rx_opt [7:0];
    assign _e_9884 = \rx_opt [8] == 1'd1;
    localparam[0:0] _e_9885 = 1;
    assign _e_9886 = _e_9884 && _e_9885;
    localparam[0:0] _e_6320 = 1;
    assign _e_6319 = {_e_6320, \b };
    assign _e_9888 = \rx_opt [8] == 1'd0;
    localparam[0:0] _e_6324 = 0;
    localparam[7:0] _e_6325 = 0;
    assign _e_6323 = {_e_6324, _e_6325};
    always_comb begin
        priority casez ({_e_9886, _e_9888})
            2'b1?: _e_6328 = _e_6319;
            2'b01: _e_6328 = _e_6323;
            2'b?: _e_6328 = 9'dx;
        endcase
    end
    assign \byte_valid  = _e_6328[8];
    assign \byte  = _e_6328[7:0];
    (* src = "src/boot_imem_subsystem.spade:41,12" *)
    \tta::bootloader::bootloader  bootloader_0(.clk_i(\clk ), .rst_i(\rst ), .byte_valid_i(\byte_valid ), .byte_i(\byte ), .output__(\bl ));
    assign _e_6337 = \bl [88];
    assign \core_rst  = \rst  || _e_6337;
    localparam[0:0] _e_6343 = 1;
    assign _e_6344 = \bl [88];
    always @(posedge \clk ) begin
        if (\rst ) begin
            \boot_q  <= _e_6343;
        end
        else begin
            \boot_q  <= _e_6344;
        end
    end
    assign _e_6349 = \bl [88];
    assign _e_6348 = !_e_6349;
    assign \boot_fall  = \boot_q  && _e_6348;
    assign _e_6355 = \bl [10:0];
    assign _e_6353 = {\boot_fall , _e_6355};
    assign _e_6360 = _e_6353;
    assign _e_6357 = _e_6353[11];
    assign _e_6359 = _e_6353[10:0];
    assign \e  = _e_6359[9:0];
    assign _e_9892 = _e_6359[10] == 1'd1;
    localparam[0:0] _e_9893 = 1;
    assign _e_9894 = _e_9892 && _e_9893;
    assign _e_9895 = _e_6357 && _e_9894;
    assign _e_6361 = {1'd1, \e };
    assign \_  = _e_6353;
    localparam[0:0] _e_9896 = 1;
    assign _e_6364 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_9895, _e_9896})
            2'b1?: \pc_release  = _e_6361;
            2'b01: \pc_release  = _e_6364;
            2'b?: \pc_release  = 11'dx;
        endcase
    end
    (* src = "src/boot_imem_subsystem.spade:60,13" *)
    \tta::boot_imem_subsystem::no_op  no_op_0(.output__(_e_6369));
    assign _e_9898 = !\boot_q ;
    assign _e_6379 = \bl [87:77];
    assign _e_6381 = \bl [76:44];
    assign _e_6383 = \bl [43:11];
    (* src = "src/boot_imem_subsystem.spade:62,13" *)
    \tta::imem::imem  imem_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .boot_mode_i(\boot_q ), .fetch_pc_i(\fetch_pc ), .wr_addr_i(_e_6379), .wr_slot0_i(_e_6381), .wr_slot1_i(_e_6383), .output__(_e_6373));
    assign _e_6386 = _e_6373;
    assign \v  = _e_6373[97:0];
    assign _e_9900 = _e_6373[98] == 1'd1;
    localparam[0:0] _e_9901 = 1;
    assign _e_9902 = _e_9900 && _e_9901;
    assign _e_6388 = _e_6373;
    assign _e_9904 = _e_6373[98] == 1'd0;
    (* src = "src/boot_imem_subsystem.spade:69,19" *)
    \tta::boot_imem_subsystem::no_op  no_op_1(.output__(_e_6389));
    always_comb begin
        priority casez ({_e_9902, _e_9904})
            2'b1?: _e_6372 = \v ;
            2'b01: _e_6372 = _e_6389;
            2'b?: _e_6372 = 98'dx;
        endcase
    end
    always_comb begin
        priority casez ({\boot_q , _e_9898})
            2'b1?: \instr  = _e_6369;
            2'b01: \instr  = _e_6372;
            2'b?: \instr  = 98'dx;
        endcase
    end
    assign _e_6391 = {\core_rst , \instr , \pc_release };
    assign output__ = _e_6391;
endmodule

module \tta::boot_imem_subsystem::no_op  (
        output[97:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::boot_imem_subsystem::no_op" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::boot_imem_subsystem::no_op );
        end
    end
    `endif
    (* src = "src/boot_imem_subsystem.spade:80,16" *)
    logic[36:0] _e_6398;
    (* src = "src/boot_imem_subsystem.spade:80,27" *)
    logic[10:0] _e_6399;
    (* src = "src/boot_imem_subsystem.spade:80,11" *)
    logic[48:0] _e_6397;
    (* src = "src/boot_imem_subsystem.spade:81,16" *)
    logic[36:0] _e_6402;
    (* src = "src/boot_imem_subsystem.spade:81,27" *)
    logic[10:0] _e_6403;
    (* src = "src/boot_imem_subsystem.spade:81,11" *)
    logic[48:0] _e_6401;
    (* src = "src/boot_imem_subsystem.spade:79,3" *)
    logic[97:0] _e_6396;
    assign _e_6398 = {5'd6, 32'bX};
    assign _e_6399 = {7'd2, 4'bX};
    localparam[0:0] _e_6400 = 0;
    assign _e_6397 = {_e_6398, _e_6399, _e_6400};
    assign _e_6402 = {5'd6, 32'bX};
    assign _e_6403 = {7'd2, 4'bX};
    localparam[0:0] _e_6404 = 0;
    assign _e_6401 = {_e_6402, _e_6403, _e_6404};
    assign _e_6396 = {_e_6397, _e_6401};
    assign output__ = _e_6396;
endmodule

module \tta::tanh::tanh_pwl_fu  (
        input clk_i,
        input rst_i,
        input[32:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::tanh::tanh_pwl_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::tanh::tanh_pwl_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/tanh.spade:18,47" *)
    logic[32:0] _e_6409;
    (* src = "src/tanh.spade:19,9" *)
    logic[31:0] \val_32 ;
    logic _e_9906;
    logic _e_9908;
    (* src = "src/tanh.spade:21,37" *)
    logic[15:0] \val_u16 ;
    (* src = "src/tanh.spade:22,30" *)
    logic[15:0] \x ;
    (* src = "src/tanh.spade:24,33" *)
    logic[16:0] \x_17 ;
    (* src = "src/tanh.spade:25,26" *)
    logic \is_neg ;
    (* src = "src/tanh.spade:28,53" *)
    logic[16:0] _e_6433;
    (* src = "src/tanh.spade:28,49" *)
    logic[17:0] _e_6431;
    (* src = "src/tanh.spade:28,73" *)
    logic[17:0] _e_6436;
    (* src = "src/tanh.spade:28,37" *)
    logic[17:0] \abs_x_18 ;
    (* src = "src/tanh.spade:29,34" *)
    logic[16:0] \abs_x ;
    (* src = "src/tanh.spade:34,37" *)
    logic _e_6443;
    (* src = "src/tanh.spade:44,43" *)
    logic[16:0] _e_6450;
    (* src = "src/tanh.spade:44,38" *)
    logic[17:0] \term1 ;
    (* src = "src/tanh.spade:45,21" *)
    logic[17:0] \term2 ;
    (* src = "src/tanh.spade:46,23" *)
    logic[18:0] _e_6457;
    (* src = "src/tanh.spade:46,17" *)
    logic[16:0] _e_6456;
    (* src = "src/tanh.spade:34,34" *)
    logic[16:0] \abs_y ;
    (* src = "src/tanh.spade:51,49" *)
    logic[16:0] _e_6466;
    (* src = "src/tanh.spade:51,45" *)
    logic[17:0] _e_6464;
    (* src = "src/tanh.spade:51,70" *)
    logic[17:0] _e_6469;
    (* src = "src/tanh.spade:51,33" *)
    logic[17:0] \y_18 ;
    (* src = "src/tanh.spade:55,33" *)
    logic[15:0] \y_16 ;
    (* src = "src/tanh.spade:59,34" *)
    logic[31:0] \y_i32 ;
    (* src = "src/tanh.spade:60,18" *)
    logic[31:0] _e_6479;
    (* src = "src/tanh.spade:60,13" *)
    logic[32:0] _e_6478;
    logic _e_9910;
    (* src = "src/tanh.spade:62,17" *)
    logic[32:0] _e_6482;
    (* src = "src/tanh.spade:18,55" *)
    logic[32:0] _e_6410;
    (* src = "src/tanh.spade:18,14" *)
    reg[32:0] \res ;
    assign _e_6409 = {1'd0, 32'bX};
    assign \val_32  = \trig [31:0];
    assign _e_9906 = \trig [32] == 1'd1;
    localparam[0:0] _e_9907 = 1;
    assign _e_9908 = _e_9906 && _e_9907;
    assign \val_u16  = \val_32 [15:0];
    (* src = "src/tanh.spade:22,30" *)
    \std::conv::impl_4::to_int[2155]  to_int_0(.self_i(\val_u16 ), .output__(\x ));
    assign \x_17  = {\x [15], \x };
    localparam[16:0] _e_6426 = 0;
    assign \is_neg  = $signed(\x_17 ) < $signed(_e_6426);
    localparam[16:0] _e_6432 = 0;
    assign _e_6433 = \x_17 ;
    assign _e_6431 = $signed(_e_6432) - $signed(_e_6433);
    assign _e_6436 = {\x_17 [16], \x_17 };
    assign \abs_x_18  = \is_neg  ? _e_6431 : _e_6436;
    assign \abs_x  = \abs_x_18 [16:0];
    localparam[16:0] _e_6445 = 16384;
    assign _e_6443 = $signed(\abs_x ) < $signed(_e_6445);
    localparam[16:0] _e_6452 = 1;
    assign _e_6450 = \abs_x  >> _e_6452;
    assign \term1  = {_e_6450[16], _e_6450};
    localparam[17:0] _e_6454 = 8192;
    assign \term2  = _e_6454;
    assign _e_6457 = $signed(\term1 ) + $signed(\term2 );
    assign _e_6456 = _e_6457[16:0];
    assign \abs_y  = _e_6443 ? \abs_x  : _e_6456;
    localparam[16:0] _e_6465 = 0;
    assign _e_6466 = \abs_y ;
    assign _e_6464 = $signed(_e_6465) - $signed(_e_6466);
    assign _e_6469 = {\abs_y [16], \abs_y };
    assign \y_18  = \is_neg  ? _e_6464 : _e_6469;
    assign \y_16  = \y_18 [15:0];
    assign \y_i32  = {{ 16 { \y_16 [15] }}, \y_16 };
    (* src = "src/tanh.spade:60,18" *)
    \std::conv::impl_3::to_uint[2154]  to_uint_0(.self_i(\y_i32 ), .output__(_e_6479));
    assign _e_6478 = {1'd1, _e_6479};
    assign _e_9910 = \trig [32] == 1'd0;
    assign _e_6482 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9908, _e_9910})
            2'b1?: _e_6410 = _e_6478;
            2'b01: _e_6410 = _e_6482;
            2'b?: _e_6410 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_6409;
        end
        else begin
            \res  <= _e_6410;
        end
    end
    assign output__ = \res ;
endmodule

module \tta::tanh::pick_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::tanh::pick_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::tanh::pick_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/tanh.spade:72,9" *)
    logic[42:0] _e_6488;
    (* src = "src/tanh.spade:72,14" *)
    logic[31:0] \a ;
    logic _e_9912;
    logic _e_9914;
    logic _e_9916;
    logic _e_9917;
    (* src = "src/tanh.spade:72,35" *)
    logic[32:0] _e_6490;
    (* src = "src/tanh.spade:73,9" *)
    logic[43:0] \_ ;
    (* src = "src/tanh.spade:73,25" *)
    logic[42:0] _e_6496;
    (* src = "src/tanh.spade:73,30" *)
    logic[31:0] a_n1;
    logic _e_9920;
    logic _e_9922;
    logic _e_9924;
    logic _e_9925;
    (* src = "src/tanh.spade:73,51" *)
    logic[32:0] _e_6498;
    (* src = "src/tanh.spade:73,60" *)
    logic[43:0] __n1;
    (* src = "src/tanh.spade:73,65" *)
    logic[32:0] _e_6501;
    (* src = "src/tanh.spade:73,14" *)
    logic[32:0] _e_6493;
    (* src = "src/tanh.spade:71,5" *)
    logic[32:0] _e_6485;
    assign _e_6488 = \m1 [42:0];
    assign \a  = _e_6488[36:5];
    assign _e_9912 = \m1 [43] == 1'd1;
    assign _e_9914 = _e_6488[42:37] == 6'd34;
    localparam[0:0] _e_9915 = 1;
    assign _e_9916 = _e_9914 && _e_9915;
    assign _e_9917 = _e_9912 && _e_9916;
    assign _e_6490 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9918 = 1;
    assign _e_6496 = \m0 [42:0];
    assign a_n1 = _e_6496[36:5];
    assign _e_9920 = \m0 [43] == 1'd1;
    assign _e_9922 = _e_6496[42:37] == 6'd34;
    localparam[0:0] _e_9923 = 1;
    assign _e_9924 = _e_9922 && _e_9923;
    assign _e_9925 = _e_9920 && _e_9924;
    assign _e_6498 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9926 = 1;
    assign _e_6501 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9925, _e_9926})
            2'b1?: _e_6493 = _e_6498;
            2'b01: _e_6493 = _e_6501;
            2'b?: _e_6493 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9917, _e_9918})
            2'b1?: _e_6485 = _e_6490;
            2'b01: _e_6485 = _e_6493;
            2'b?: _e_6485 = 33'dx;
        endcase
    end
    assign output__ = _e_6485;
endmodule

module \tta::cc::cc_fu  (
        input clk_i,
        input rst_i,
        output[63:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::cc::cc_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::cc::cc_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    (* src = "src/cc.spade:14,54" *)
    logic[51:0] _e_6508;
    (* src = "src/cc.spade:14,48" *)
    logic[50:0] _e_6507;
    (* src = "src/cc.spade:14,14" *)
    reg[50:0] \counter ;
    logic[63:0] \padded ;
    (* src = "src/cc.spade:17,37" *)
    logic[63:0] _e_6515;
    (* src = "src/cc.spade:17,31" *)
    logic[31:0] \cc_res_lo ;
    (* src = "src/cc.spade:18,39" *)
    logic[63:0] _e_6520;
    (* src = "src/cc.spade:18,33" *)
    logic[31:0] \cc_res_high ;
    (* src = "src/cc.spade:19,5" *)
    logic[63:0] _e_6524;
    localparam[50:0] _e_6506 = 51'd0;
    localparam[50:0] _e_6510 = 51'd1;
    assign _e_6508 = \counter  + _e_6510;
    assign _e_6507 = _e_6508[50:0];
    always @(posedge \clk ) begin
        if (\rst ) begin
            \counter  <= _e_6506;
        end
        else begin
            \counter  <= _e_6507;
        end
    end
    assign \padded  = {13'b0, \counter };
    localparam[63:0] _e_6517 = 64'd4294967295;
    assign _e_6515 = \padded  & _e_6517;
    assign \cc_res_lo  = _e_6515[31:0];
    localparam[63:0] _e_6522 = 64'd32;
    assign _e_6520 = \padded  >> _e_6522;
    assign \cc_res_high  = _e_6520[31:0];
    assign _e_6524 = {\cc_res_lo , \cc_res_high };
    assign output__ = _e_6524;
endmodule

module \tta::mul_shiftadd::reset_mul  (
        output[102:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::mul_shiftadd::reset_mul" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::mul_shiftadd::reset_mul );
        end
    end
    `endif
    (* src = "src/mul_shiftadd.spade:26,13" *)
    logic _e_6529;
    (* src = "src/mul_shiftadd.spade:26,5" *)
    logic[102:0] _e_6528;
    assign _e_6529 = {1'd0};
    localparam[31:0] _e_6530 = 32'd0;
    localparam[31:0] _e_6531 = 32'd0;
    localparam[31:0] _e_6532 = 32'd0;
    localparam[5:0] _e_6533 = 0;
    assign _e_6528 = {_e_6529, _e_6530, _e_6531, _e_6532, _e_6533};
    assign output__ = _e_6528;
endmodule

module \tta::mul_shiftadd::mul_shiftadd_fu  (
        input clk_i,
        input rst_i,
        input[32:0] set_op_a_i,
        input[32:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::mul_shiftadd::mul_shiftadd_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::mul_shiftadd::mul_shiftadd_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_op_a ;
    assign \set_op_a  = set_op_a_i;
    logic[32:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/mul_shiftadd.spade:35,36" *)
    logic[102:0] _e_6538;
    (* src = "src/mul_shiftadd.spade:35,57" *)
    logic _e_6540;
    (* src = "src/mul_shiftadd.spade:36,9" *)
    logic _e_6542;
    logic _e_9928;
    (* src = "src/mul_shiftadd.spade:39,17" *)
    logic[31:0] \val ;
    logic _e_9930;
    logic _e_9932;
    logic _e_9934;
    (* src = "src/mul_shiftadd.spade:40,25" *)
    logic[31:0] _e_6550;
    (* src = "src/mul_shiftadd.spade:38,26" *)
    logic[31:0] \next_a ;
    (* src = "src/mul_shiftadd.spade:46,17" *)
    logic[31:0] \val_b ;
    logic _e_9936;
    logic _e_9938;
    (* src = "src/mul_shiftadd.spade:46,40" *)
    logic _e_6558;
    (* src = "src/mul_shiftadd.spade:46,32" *)
    logic[102:0] _e_6557;
    logic _e_9940;
    (* src = "src/mul_shiftadd.spade:47,33" *)
    logic _e_6565;
    (* src = "src/mul_shiftadd.spade:47,25" *)
    logic[102:0] _e_6564;
    (* src = "src/mul_shiftadd.spade:45,13" *)
    logic[102:0] _e_6553;
    (* src = "src/mul_shiftadd.spade:50,9" *)
    logic _e_6570;
    logic _e_9942;
    (* src = "src/mul_shiftadd.spade:52,27" *)
    logic[31:0] _e_6574;
    (* src = "src/mul_shiftadd.spade:52,26" *)
    logic[31:0] _e_6573;
    (* src = "src/mul_shiftadd.spade:52,26" *)
    logic \do_add ;
    (* src = "src/mul_shiftadd.spade:53,46" *)
    logic[31:0] _e_6582;
    (* src = "src/mul_shiftadd.spade:53,34" *)
    logic[31:0] \current_addend ;
    (* src = "src/mul_shiftadd.spade:54,34" *)
    logic[31:0] _e_6589;
    (* src = "src/mul_shiftadd.spade:54,34" *)
    logic[32:0] _e_6588;
    (* src = "src/mul_shiftadd.spade:54,28" *)
    logic[31:0] \next_acc ;
    (* src = "src/mul_shiftadd.spade:56,26" *)
    logic[31:0] _e_6594;
    (* src = "src/mul_shiftadd.spade:56,26" *)
    logic[31:0] next_a_n1;
    (* src = "src/mul_shiftadd.spade:57,26" *)
    logic[31:0] _e_6599;
    (* src = "src/mul_shiftadd.spade:57,26" *)
    logic[31:0] \next_b ;
    (* src = "src/mul_shiftadd.spade:59,16" *)
    logic[5:0] _e_6605;
    (* src = "src/mul_shiftadd.spade:59,16" *)
    logic _e_6604;
    (* src = "src/mul_shiftadd.spade:61,17" *)
    logic[102:0] _e_6609;
    (* src = "src/mul_shiftadd.spade:63,25" *)
    logic _e_6612;
    (* src = "src/mul_shiftadd.spade:63,70" *)
    logic[5:0] _e_6618;
    (* src = "src/mul_shiftadd.spade:63,70" *)
    logic[6:0] _e_6617;
    (* src = "src/mul_shiftadd.spade:63,64" *)
    logic[5:0] _e_6616;
    (* src = "src/mul_shiftadd.spade:63,17" *)
    logic[102:0] _e_6611;
    (* src = "src/mul_shiftadd.spade:59,13" *)
    logic[102:0] _e_6603;
    (* src = "src/mul_shiftadd.spade:35,51" *)
    logic[102:0] _e_6539;
    (* src = "src/mul_shiftadd.spade:35,14" *)
    reg[102:0] \r ;
    (* src = "src/mul_shiftadd.spade:69,11" *)
    logic _e_6622;
    (* src = "src/mul_shiftadd.spade:70,9" *)
    logic _e_6624;
    logic _e_9944;
    (* src = "src/mul_shiftadd.spade:71,16" *)
    logic[5:0] _e_6628;
    (* src = "src/mul_shiftadd.spade:71,16" *)
    logic _e_6627;
    (* src = "src/mul_shiftadd.spade:73,31" *)
    logic[31:0] _e_6634;
    (* src = "src/mul_shiftadd.spade:73,30" *)
    logic[31:0] _e_6633;
    (* src = "src/mul_shiftadd.spade:73,30" *)
    logic do_add_n1;
    (* src = "src/mul_shiftadd.spade:74,50" *)
    logic[31:0] _e_6642;
    (* src = "src/mul_shiftadd.spade:74,38" *)
    logic[31:0] current_addend_n1;
    (* src = "src/mul_shiftadd.spade:75,28" *)
    logic[31:0] _e_6650;
    (* src = "src/mul_shiftadd.spade:75,28" *)
    logic[32:0] _e_6649;
    (* src = "src/mul_shiftadd.spade:75,22" *)
    logic[31:0] _e_6648;
    (* src = "src/mul_shiftadd.spade:75,17" *)
    logic[32:0] _e_6647;
    (* src = "src/mul_shiftadd.spade:77,17" *)
    logic[32:0] _e_6654;
    (* src = "src/mul_shiftadd.spade:71,13" *)
    logic[32:0] _e_6626;
    (* src = "src/mul_shiftadd.spade:80,9" *)
    logic \_ ;
    (* src = "src/mul_shiftadd.spade:80,14" *)
    logic[32:0] _e_6656;
    (* src = "src/mul_shiftadd.spade:69,5" *)
    logic[32:0] _e_6621;
    (* src = "src/mul_shiftadd.spade:35,36" *)
    \tta::mul_shiftadd::reset_mul  reset_mul_0(.output__(_e_6538));
    assign _e_6540 = \r [102];
    assign _e_6542 = _e_6540;
    assign _e_9928 = _e_6540 == 1'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9930 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9931 = 1;
    assign _e_9932 = _e_9930 && _e_9931;
    assign _e_9934 = \set_op_a [32] == 1'd0;
    assign _e_6550 = \r [101:70];
    always_comb begin
        priority casez ({_e_9932, _e_9934})
            2'b1?: \next_a  = \val ;
            2'b01: \next_a  = _e_6550;
            2'b?: \next_a  = 32'dx;
        endcase
    end
    assign \val_b  = \trig [31:0];
    assign _e_9936 = \trig [32] == 1'd1;
    localparam[0:0] _e_9937 = 1;
    assign _e_9938 = _e_9936 && _e_9937;
    assign _e_6558 = {1'd1};
    localparam[31:0] _e_6561 = 32'd0;
    localparam[5:0] _e_6562 = 0;
    assign _e_6557 = {_e_6558, \next_a , \val_b , _e_6561, _e_6562};
    assign _e_9940 = \trig [32] == 1'd0;
    assign _e_6565 = {1'd0};
    localparam[31:0] _e_6567 = 32'd0;
    localparam[31:0] _e_6568 = 32'd0;
    localparam[5:0] _e_6569 = 0;
    assign _e_6564 = {_e_6565, \next_a , _e_6567, _e_6568, _e_6569};
    always_comb begin
        priority casez ({_e_9938, _e_9940})
            2'b1?: _e_6553 = _e_6557;
            2'b01: _e_6553 = _e_6564;
            2'b?: _e_6553 = 103'dx;
        endcase
    end
    assign _e_6570 = _e_6540;
    assign _e_9942 = _e_6540 == 1'd1;
    assign _e_6574 = \r [69:38];
    localparam[31:0] _e_6576 = 32'd1;
    assign _e_6573 = _e_6574 & _e_6576;
    localparam[31:0] _e_6577 = 32'd1;
    assign \do_add  = _e_6573 == _e_6577;
    assign _e_6582 = \r [101:70];
    localparam[31:0] _e_6585 = 32'd0;
    assign \current_addend  = \do_add  ? _e_6582 : _e_6585;
    assign _e_6589 = \r [37:6];
    assign _e_6588 = _e_6589 + \current_addend ;
    assign \next_acc  = _e_6588[31:0];
    assign _e_6594 = \r [101:70];
    localparam[31:0] _e_6596 = 32'd1;
    assign next_a_n1 = _e_6594 << _e_6596;
    assign _e_6599 = \r [69:38];
    localparam[31:0] _e_6601 = 32'd1;
    assign \next_b  = _e_6599 >> _e_6601;
    assign _e_6605 = \r [5:0];
    localparam[5:0] _e_6607 = 31;
    assign _e_6604 = _e_6605 == _e_6607;
    (* src = "src/mul_shiftadd.spade:61,17" *)
    \tta::mul_shiftadd::reset_mul  reset_mul_1(.output__(_e_6609));
    assign _e_6612 = {1'd1};
    assign _e_6618 = \r [5:0];
    localparam[5:0] _e_6620 = 1;
    assign _e_6617 = _e_6618 + _e_6620;
    assign _e_6616 = _e_6617[5:0];
    assign _e_6611 = {_e_6612, next_a_n1, \next_b , \next_acc , _e_6616};
    assign _e_6603 = _e_6604 ? _e_6609 : _e_6611;
    always_comb begin
        priority casez ({_e_9928, _e_9942})
            2'b1?: _e_6539 = _e_6553;
            2'b01: _e_6539 = _e_6603;
            2'b?: _e_6539 = 103'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_6538;
        end
        else begin
            \r  <= _e_6539;
        end
    end
    assign _e_6622 = \r [102];
    assign _e_6624 = _e_6622;
    assign _e_9944 = _e_6622 == 1'd1;
    assign _e_6628 = \r [5:0];
    localparam[5:0] _e_6630 = 31;
    assign _e_6627 = _e_6628 == _e_6630;
    assign _e_6634 = \r [69:38];
    localparam[31:0] _e_6636 = 32'd1;
    assign _e_6633 = _e_6634 & _e_6636;
    localparam[31:0] _e_6637 = 32'd1;
    assign do_add_n1 = _e_6633 == _e_6637;
    assign _e_6642 = \r [101:70];
    localparam[31:0] _e_6645 = 32'd0;
    assign current_addend_n1 = do_add_n1 ? _e_6642 : _e_6645;
    assign _e_6650 = \r [37:6];
    assign _e_6649 = _e_6650 + current_addend_n1;
    assign _e_6648 = _e_6649[31:0];
    assign _e_6647 = {1'd1, _e_6648};
    assign _e_6654 = {1'd0, 32'bX};
    assign _e_6626 = _e_6627 ? _e_6647 : _e_6654;
    assign \_  = _e_6622;
    localparam[0:0] _e_9945 = 1;
    assign _e_6656 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9944, _e_9945})
            2'b1?: _e_6621 = _e_6626;
            2'b01: _e_6621 = _e_6656;
            2'b?: _e_6621 = 33'dx;
        endcase
    end
    assign output__ = _e_6621;
endmodule

module \tta::mul_shiftadd::pick_mul_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::mul_shiftadd::pick_mul_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::mul_shiftadd::pick_mul_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/mul_shiftadd.spade:89,5" *)
    logic[42:0] _e_6661;
    (* src = "src/mul_shiftadd.spade:89,10" *)
    logic[31:0] \x ;
    logic _e_9947;
    logic _e_9949;
    logic _e_9951;
    logic _e_9952;
    (* src = "src/mul_shiftadd.spade:89,31" *)
    logic[32:0] _e_6663;
    (* src = "src/mul_shiftadd.spade:90,5" *)
    logic[43:0] \_ ;
    (* src = "src/mul_shiftadd.spade:90,21" *)
    logic[42:0] _e_6669;
    (* src = "src/mul_shiftadd.spade:90,26" *)
    logic[31:0] x_n1;
    logic _e_9955;
    logic _e_9957;
    logic _e_9959;
    logic _e_9960;
    (* src = "src/mul_shiftadd.spade:90,47" *)
    logic[32:0] _e_6671;
    (* src = "src/mul_shiftadd.spade:90,56" *)
    logic[43:0] __n1;
    (* src = "src/mul_shiftadd.spade:90,61" *)
    logic[32:0] _e_6674;
    (* src = "src/mul_shiftadd.spade:90,10" *)
    logic[32:0] _e_6666;
    (* src = "src/mul_shiftadd.spade:88,3" *)
    logic[32:0] _e_6658;
    assign _e_6661 = \m1 [42:0];
    assign \x  = _e_6661[36:5];
    assign _e_9947 = \m1 [43] == 1'd1;
    assign _e_9949 = _e_6661[42:37] == 6'd16;
    localparam[0:0] _e_9950 = 1;
    assign _e_9951 = _e_9949 && _e_9950;
    assign _e_9952 = _e_9947 && _e_9951;
    assign _e_6663 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9953 = 1;
    assign _e_6669 = \m0 [42:0];
    assign x_n1 = _e_6669[36:5];
    assign _e_9955 = \m0 [43] == 1'd1;
    assign _e_9957 = _e_6669[42:37] == 6'd16;
    localparam[0:0] _e_9958 = 1;
    assign _e_9959 = _e_9957 && _e_9958;
    assign _e_9960 = _e_9955 && _e_9959;
    assign _e_6671 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9961 = 1;
    assign _e_6674 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9960, _e_9961})
            2'b1?: _e_6666 = _e_6671;
            2'b01: _e_6666 = _e_6674;
            2'b?: _e_6666 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9952, _e_9953})
            2'b1?: _e_6658 = _e_6663;
            2'b01: _e_6658 = _e_6666;
            2'b?: _e_6658 = 33'dx;
        endcase
    end
    assign output__ = _e_6658;
endmodule

module \tta::mul_shiftadd::pick_mul_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::mul_shiftadd::pick_mul_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::mul_shiftadd::pick_mul_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/mul_shiftadd.spade:96,5" *)
    logic[42:0] _e_6679;
    (* src = "src/mul_shiftadd.spade:96,10" *)
    logic[31:0] \x ;
    logic _e_9963;
    logic _e_9965;
    logic _e_9967;
    logic _e_9968;
    (* src = "src/mul_shiftadd.spade:96,31" *)
    logic[32:0] _e_6681;
    (* src = "src/mul_shiftadd.spade:97,5" *)
    logic[43:0] \_ ;
    (* src = "src/mul_shiftadd.spade:97,21" *)
    logic[42:0] _e_6687;
    (* src = "src/mul_shiftadd.spade:97,26" *)
    logic[31:0] x_n1;
    logic _e_9971;
    logic _e_9973;
    logic _e_9975;
    logic _e_9976;
    (* src = "src/mul_shiftadd.spade:97,47" *)
    logic[32:0] _e_6689;
    (* src = "src/mul_shiftadd.spade:97,56" *)
    logic[43:0] __n1;
    (* src = "src/mul_shiftadd.spade:97,61" *)
    logic[32:0] _e_6692;
    (* src = "src/mul_shiftadd.spade:97,10" *)
    logic[32:0] _e_6684;
    (* src = "src/mul_shiftadd.spade:95,3" *)
    logic[32:0] _e_6676;
    assign _e_6679 = \m1 [42:0];
    assign \x  = _e_6679[36:5];
    assign _e_9963 = \m1 [43] == 1'd1;
    assign _e_9965 = _e_6679[42:37] == 6'd17;
    localparam[0:0] _e_9966 = 1;
    assign _e_9967 = _e_9965 && _e_9966;
    assign _e_9968 = _e_9963 && _e_9967;
    assign _e_6681 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9969 = 1;
    assign _e_6687 = \m0 [42:0];
    assign x_n1 = _e_6687[36:5];
    assign _e_9971 = \m0 [43] == 1'd1;
    assign _e_9973 = _e_6687[42:37] == 6'd17;
    localparam[0:0] _e_9974 = 1;
    assign _e_9975 = _e_9973 && _e_9974;
    assign _e_9976 = _e_9971 && _e_9975;
    assign _e_6689 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9977 = 1;
    assign _e_6692 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9976, _e_9977})
            2'b1?: _e_6684 = _e_6689;
            2'b01: _e_6684 = _e_6692;
            2'b?: _e_6684 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9968, _e_9969})
            2'b1?: _e_6676 = _e_6681;
            2'b01: _e_6676 = _e_6684;
            2'b?: _e_6676 = 33'dx;
        endcase
    end
    assign output__ = _e_6676;
endmodule

module \tta::imem::decode_src_tok  (
        input[7:0] t_i,
        input[15:0] imm16_i,
        output[36:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::imem::decode_src_tok" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::imem::decode_src_tok );
        end
    end
    `endif
    logic[7:0] \t ;
    assign \t  = t_i;
    logic[15:0] \imm16 ;
    assign \imm16  = imm16_i;
    logic _e_9978;
    (* src = "src/imem.spade:28,17" *)
    logic[36:0] _e_6697;
    logic _e_9980;
    (* src = "src/imem.spade:29,17" *)
    logic[36:0] _e_6700;
    logic _e_9982;
    (* src = "src/imem.spade:30,17" *)
    logic[36:0] _e_6703;
    logic _e_9984;
    (* src = "src/imem.spade:31,17" *)
    logic[36:0] _e_6706;
    logic _e_9986;
    (* src = "src/imem.spade:32,17" *)
    logic[36:0] _e_6709;
    logic _e_9988;
    (* src = "src/imem.spade:33,17" *)
    logic[36:0] _e_6712;
    logic _e_9990;
    (* src = "src/imem.spade:34,17" *)
    logic[36:0] _e_6715;
    logic _e_9992;
    (* src = "src/imem.spade:35,17" *)
    logic[36:0] _e_6718;
    logic _e_9994;
    (* src = "src/imem.spade:37,17" *)
    logic[36:0] _e_6721;
    logic _e_9996;
    (* src = "src/imem.spade:38,17" *)
    logic[36:0] _e_6723;
    logic _e_9998;
    logic[31:0] _e_6726;
    (* src = "src/imem.spade:41,17" *)
    logic[36:0] _e_6725;
    logic _e_10000;
    (* src = "src/imem.spade:44,17" *)
    logic[36:0] _e_6729;
    logic _e_10002;
    (* src = "src/imem.spade:45,17" *)
    logic[36:0] _e_6731;
    logic _e_10004;
    (* src = "src/imem.spade:46,17" *)
    logic[36:0] _e_6733;
    logic _e_10006;
    (* src = "src/imem.spade:47,17" *)
    logic[36:0] _e_6735;
    logic _e_10008;
    (* src = "src/imem.spade:48,17" *)
    logic[36:0] _e_6737;
    logic _e_10010;
    (* src = "src/imem.spade:49,17" *)
    logic[36:0] _e_6739;
    logic _e_10012;
    (* src = "src/imem.spade:50,17" *)
    logic[36:0] _e_6741;
    logic _e_10014;
    (* src = "src/imem.spade:51,17" *)
    logic[36:0] _e_6743;
    logic _e_10016;
    (* src = "src/imem.spade:52,17" *)
    logic[36:0] _e_6745;
    logic _e_10018;
    (* src = "src/imem.spade:53,17" *)
    logic[36:0] _e_6747;
    logic _e_10020;
    (* src = "src/imem.spade:54,17" *)
    logic[36:0] _e_6749;
    logic _e_10022;
    (* src = "src/imem.spade:55,17" *)
    logic[36:0] _e_6751;
    logic _e_10024;
    (* src = "src/imem.spade:56,17" *)
    logic[36:0] _e_6753;
    logic _e_10026;
    (* src = "src/imem.spade:57,17" *)
    logic[36:0] _e_6755;
    logic _e_10028;
    (* src = "src/imem.spade:58,17" *)
    logic[36:0] _e_6757;
    logic _e_10030;
    (* src = "src/imem.spade:59,17" *)
    logic[36:0] _e_6759;
    logic _e_10032;
    (* src = "src/imem.spade:60,17" *)
    logic[36:0] _e_6761;
    logic _e_10034;
    (* src = "src/imem.spade:63,17" *)
    logic[36:0] _e_6763;
    logic _e_10036;
    (* src = "src/imem.spade:64,17" *)
    logic[36:0] _e_6765;
    logic _e_10038;
    (* src = "src/imem.spade:65,17" *)
    logic[36:0] _e_6767;
    logic _e_10040;
    (* src = "src/imem.spade:68,18" *)
    logic[36:0] _e_6769;
    logic _e_10042;
    (* src = "src/imem.spade:69,18" *)
    logic[36:0] _e_6772;
    logic _e_10044;
    (* src = "src/imem.spade:70,18" *)
    logic[36:0] _e_6775;
    logic _e_10046;
    (* src = "src/imem.spade:71,18" *)
    logic[36:0] _e_6778;
    logic _e_10048;
    (* src = "src/imem.spade:72,18" *)
    logic[36:0] _e_6781;
    logic _e_10050;
    (* src = "src/imem.spade:73,18" *)
    logic[36:0] _e_6784;
    logic _e_10052;
    (* src = "src/imem.spade:74,18" *)
    logic[36:0] _e_6787;
    logic _e_10054;
    (* src = "src/imem.spade:75,18" *)
    logic[36:0] _e_6790;
    logic _e_10056;
    (* src = "src/imem.spade:77,18" *)
    logic[36:0] _e_6793;
    (* src = "src/imem.spade:80,9" *)
    logic[7:0] \_ ;
    (* src = "src/imem.spade:80,14" *)
    logic[36:0] _e_6795;
    (* src = "src/imem.spade:26,5" *)
    logic[36:0] _e_6694;
    localparam[7:0] _e_9979 = 0;
    assign _e_9978 = \t  == _e_9979;
    localparam[3:0] _e_6698 = 0;
    assign _e_6697 = {5'd0, _e_6698, 28'bX};
    localparam[7:0] _e_9981 = 1;
    assign _e_9980 = \t  == _e_9981;
    localparam[3:0] _e_6701 = 1;
    assign _e_6700 = {5'd0, _e_6701, 28'bX};
    localparam[7:0] _e_9983 = 2;
    assign _e_9982 = \t  == _e_9983;
    localparam[3:0] _e_6704 = 2;
    assign _e_6703 = {5'd0, _e_6704, 28'bX};
    localparam[7:0] _e_9985 = 3;
    assign _e_9984 = \t  == _e_9985;
    localparam[3:0] _e_6707 = 3;
    assign _e_6706 = {5'd0, _e_6707, 28'bX};
    localparam[7:0] _e_9987 = 4;
    assign _e_9986 = \t  == _e_9987;
    localparam[3:0] _e_6710 = 4;
    assign _e_6709 = {5'd0, _e_6710, 28'bX};
    localparam[7:0] _e_9989 = 5;
    assign _e_9988 = \t  == _e_9989;
    localparam[3:0] _e_6713 = 5;
    assign _e_6712 = {5'd0, _e_6713, 28'bX};
    localparam[7:0] _e_9991 = 6;
    assign _e_9990 = \t  == _e_9991;
    localparam[3:0] _e_6716 = 6;
    assign _e_6715 = {5'd0, _e_6716, 28'bX};
    localparam[7:0] _e_9993 = 7;
    assign _e_9992 = \t  == _e_9993;
    localparam[3:0] _e_6719 = 7;
    assign _e_6718 = {5'd0, _e_6719, 28'bX};
    localparam[7:0] _e_9995 = 8;
    assign _e_9994 = \t  == _e_9995;
    assign _e_6721 = {5'd6, 32'bX};
    localparam[7:0] _e_9997 = 9;
    assign _e_9996 = \t  == _e_9997;
    assign _e_6723 = {5'd3, 32'bX};
    localparam[7:0] _e_9999 = 10;
    assign _e_9998 = \t  == _e_9999;
    assign _e_6726 = {16'b0, \imm16 };
    assign _e_6725 = {5'd5, _e_6726};
    localparam[7:0] _e_10001 = 11;
    assign _e_10000 = \t  == _e_10001;
    assign _e_6729 = {5'd1, 32'bX};
    localparam[7:0] _e_10003 = 12;
    assign _e_10002 = \t  == _e_10003;
    assign _e_6731 = {5'd7, 32'bX};
    localparam[7:0] _e_10005 = 13;
    assign _e_10004 = \t  == _e_10005;
    assign _e_6733 = {5'd11, 32'bX};
    localparam[7:0] _e_10007 = 14;
    assign _e_10006 = \t  == _e_10007;
    assign _e_6735 = {5'd12, 32'bX};
    localparam[7:0] _e_10009 = 15;
    assign _e_10008 = \t  == _e_10009;
    assign _e_6737 = {5'd2, 32'bX};
    localparam[7:0] _e_10011 = 16;
    assign _e_10010 = \t  == _e_10011;
    assign _e_6739 = {5'd13, 32'bX};
    localparam[7:0] _e_10013 = 17;
    assign _e_10012 = \t  == _e_10013;
    assign _e_6741 = {5'd14, 32'bX};
    localparam[7:0] _e_10015 = 18;
    assign _e_10014 = \t  == _e_10015;
    assign _e_6743 = {5'd15, 32'bX};
    localparam[7:0] _e_10017 = 19;
    assign _e_10016 = \t  == _e_10017;
    assign _e_6745 = {5'd18, 32'bX};
    localparam[7:0] _e_10019 = 20;
    assign _e_10018 = \t  == _e_10019;
    assign _e_6747 = {5'd20, 32'bX};
    localparam[7:0] _e_10021 = 21;
    assign _e_10020 = \t  == _e_10021;
    assign _e_6749 = {5'd21, 32'bX};
    localparam[7:0] _e_10023 = 22;
    assign _e_10022 = \t  == _e_10023;
    assign _e_6751 = {5'd22, 32'bX};
    localparam[7:0] _e_10025 = 23;
    assign _e_10024 = \t  == _e_10025;
    assign _e_6753 = {5'd17, 32'bX};
    localparam[7:0] _e_10027 = 24;
    assign _e_10026 = \t  == _e_10027;
    assign _e_6755 = {5'd19, 32'bX};
    localparam[7:0] _e_10029 = 25;
    assign _e_10028 = \t  == _e_10029;
    assign _e_6757 = {5'd23, 32'bX};
    localparam[7:0] _e_10031 = 26;
    assign _e_10030 = \t  == _e_10031;
    assign _e_6759 = {5'd8, 32'bX};
    localparam[7:0] _e_10033 = 27;
    assign _e_10032 = \t  == _e_10033;
    assign _e_6761 = {5'd24, 32'bX};
    localparam[7:0] _e_10035 = 60;
    assign _e_10034 = \t  == _e_10035;
    assign _e_6763 = {5'd9, 32'bX};
    localparam[7:0] _e_10037 = 61;
    assign _e_10036 = \t  == _e_10037;
    assign _e_6765 = {5'd10, 32'bX};
    localparam[7:0] _e_10039 = 62;
    assign _e_10038 = \t  == _e_10039;
    assign _e_6767 = {5'd16, 32'bX};
    localparam[7:0] _e_10041 = 100;
    assign _e_10040 = \t  == _e_10041;
    localparam[3:0] _e_6770 = 8;
    assign _e_6769 = {5'd0, _e_6770, 28'bX};
    localparam[7:0] _e_10043 = 101;
    assign _e_10042 = \t  == _e_10043;
    localparam[3:0] _e_6773 = 9;
    assign _e_6772 = {5'd0, _e_6773, 28'bX};
    localparam[7:0] _e_10045 = 102;
    assign _e_10044 = \t  == _e_10045;
    localparam[3:0] _e_6776 = 10;
    assign _e_6775 = {5'd0, _e_6776, 28'bX};
    localparam[7:0] _e_10047 = 103;
    assign _e_10046 = \t  == _e_10047;
    localparam[3:0] _e_6779 = 11;
    assign _e_6778 = {5'd0, _e_6779, 28'bX};
    localparam[7:0] _e_10049 = 104;
    assign _e_10048 = \t  == _e_10049;
    localparam[3:0] _e_6782 = 12;
    assign _e_6781 = {5'd0, _e_6782, 28'bX};
    localparam[7:0] _e_10051 = 105;
    assign _e_10050 = \t  == _e_10051;
    localparam[3:0] _e_6785 = 13;
    assign _e_6784 = {5'd0, _e_6785, 28'bX};
    localparam[7:0] _e_10053 = 106;
    assign _e_10052 = \t  == _e_10053;
    localparam[3:0] _e_6788 = 14;
    assign _e_6787 = {5'd0, _e_6788, 28'bX};
    localparam[7:0] _e_10055 = 107;
    assign _e_10054 = \t  == _e_10055;
    localparam[3:0] _e_6791 = 15;
    assign _e_6790 = {5'd0, _e_6791, 28'bX};
    localparam[7:0] _e_10057 = 110;
    assign _e_10056 = \t  == _e_10057;
    assign _e_6793 = {5'd4, 32'bX};
    assign \_  = \t ;
    localparam[0:0] _e_10058 = 1;
    assign _e_6795 = {5'd6, 32'bX};
    always_comb begin
        priority casez ({_e_9978, _e_9980, _e_9982, _e_9984, _e_9986, _e_9988, _e_9990, _e_9992, _e_9994, _e_9996, _e_9998, _e_10000, _e_10002, _e_10004, _e_10006, _e_10008, _e_10010, _e_10012, _e_10014, _e_10016, _e_10018, _e_10020, _e_10022, _e_10024, _e_10026, _e_10028, _e_10030, _e_10032, _e_10034, _e_10036, _e_10038, _e_10040, _e_10042, _e_10044, _e_10046, _e_10048, _e_10050, _e_10052, _e_10054, _e_10056, _e_10058})
            41'b1????????????????????????????????????????: _e_6694 = _e_6697;
            41'b01???????????????????????????????????????: _e_6694 = _e_6700;
            41'b001??????????????????????????????????????: _e_6694 = _e_6703;
            41'b0001?????????????????????????????????????: _e_6694 = _e_6706;
            41'b00001????????????????????????????????????: _e_6694 = _e_6709;
            41'b000001???????????????????????????????????: _e_6694 = _e_6712;
            41'b0000001??????????????????????????????????: _e_6694 = _e_6715;
            41'b00000001?????????????????????????????????: _e_6694 = _e_6718;
            41'b000000001????????????????????????????????: _e_6694 = _e_6721;
            41'b0000000001???????????????????????????????: _e_6694 = _e_6723;
            41'b00000000001??????????????????????????????: _e_6694 = _e_6725;
            41'b000000000001?????????????????????????????: _e_6694 = _e_6729;
            41'b0000000000001????????????????????????????: _e_6694 = _e_6731;
            41'b00000000000001???????????????????????????: _e_6694 = _e_6733;
            41'b000000000000001??????????????????????????: _e_6694 = _e_6735;
            41'b0000000000000001?????????????????????????: _e_6694 = _e_6737;
            41'b00000000000000001????????????????????????: _e_6694 = _e_6739;
            41'b000000000000000001???????????????????????: _e_6694 = _e_6741;
            41'b0000000000000000001??????????????????????: _e_6694 = _e_6743;
            41'b00000000000000000001?????????????????????: _e_6694 = _e_6745;
            41'b000000000000000000001????????????????????: _e_6694 = _e_6747;
            41'b0000000000000000000001???????????????????: _e_6694 = _e_6749;
            41'b00000000000000000000001??????????????????: _e_6694 = _e_6751;
            41'b000000000000000000000001?????????????????: _e_6694 = _e_6753;
            41'b0000000000000000000000001????????????????: _e_6694 = _e_6755;
            41'b00000000000000000000000001???????????????: _e_6694 = _e_6757;
            41'b000000000000000000000000001??????????????: _e_6694 = _e_6759;
            41'b0000000000000000000000000001?????????????: _e_6694 = _e_6761;
            41'b00000000000000000000000000001????????????: _e_6694 = _e_6763;
            41'b000000000000000000000000000001???????????: _e_6694 = _e_6765;
            41'b0000000000000000000000000000001??????????: _e_6694 = _e_6767;
            41'b00000000000000000000000000000001?????????: _e_6694 = _e_6769;
            41'b000000000000000000000000000000001????????: _e_6694 = _e_6772;
            41'b0000000000000000000000000000000001???????: _e_6694 = _e_6775;
            41'b00000000000000000000000000000000001??????: _e_6694 = _e_6778;
            41'b000000000000000000000000000000000001?????: _e_6694 = _e_6781;
            41'b0000000000000000000000000000000000001????: _e_6694 = _e_6784;
            41'b00000000000000000000000000000000000001???: _e_6694 = _e_6787;
            41'b000000000000000000000000000000000000001??: _e_6694 = _e_6790;
            41'b0000000000000000000000000000000000000001?: _e_6694 = _e_6793;
            41'b00000000000000000000000000000000000000001: _e_6694 = _e_6795;
            41'b?: _e_6694 = 37'dx;
        endcase
    end
    assign output__ = _e_6694;
endmodule

module \tta::imem::decode_dst_tok  (
        input[7:0] t_i,
        output[10:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::imem::decode_dst_tok" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::imem::decode_dst_tok );
        end
    end
    `endif
    logic[7:0] \t ;
    assign \t  = t_i;
    logic _e_10059;
    (* src = "src/imem.spade:87,17" *)
    logic[10:0] _e_6800;
    logic _e_10061;
    (* src = "src/imem.spade:88,17" *)
    logic[10:0] _e_6803;
    logic _e_10063;
    (* src = "src/imem.spade:89,17" *)
    logic[10:0] _e_6806;
    logic _e_10065;
    (* src = "src/imem.spade:90,17" *)
    logic[10:0] _e_6809;
    logic _e_10067;
    (* src = "src/imem.spade:91,17" *)
    logic[10:0] _e_6812;
    logic _e_10069;
    (* src = "src/imem.spade:92,17" *)
    logic[10:0] _e_6815;
    logic _e_10071;
    (* src = "src/imem.spade:93,17" *)
    logic[10:0] _e_6818;
    logic _e_10073;
    (* src = "src/imem.spade:94,17" *)
    logic[10:0] _e_6821;
    logic _e_10075;
    (* src = "src/imem.spade:98,17" *)
    logic[10:0] _e_6824;
    logic _e_10077;
    (* src = "src/imem.spade:99,17" *)
    logic[10:0] _e_6826;
    logic _e_10079;
    (* src = "src/imem.spade:102,17" *)
    logic[10:0] _e_6828;
    logic _e_10081;
    (* src = "src/imem.spade:103,17" *)
    logic[10:0] _e_6830;
    logic _e_10083;
    (* src = "src/imem.spade:104,17" *)
    logic[10:0] _e_6832;
    logic _e_10085;
    (* src = "src/imem.spade:105,17" *)
    logic[10:0] _e_6834;
    logic _e_10087;
    (* src = "src/imem.spade:106,17" *)
    logic[10:0] _e_6836;
    logic _e_10089;
    (* src = "src/imem.spade:107,17" *)
    logic[10:0] _e_6838;
    logic _e_10091;
    (* src = "src/imem.spade:108,17" *)
    logic[10:0] _e_6840;
    logic _e_10093;
    (* src = "src/imem.spade:109,17" *)
    logic[10:0] _e_6842;
    logic _e_10095;
    (* src = "src/imem.spade:110,17" *)
    logic[10:0] _e_6844;
    logic _e_10097;
    (* src = "src/imem.spade:111,17" *)
    logic[10:0] _e_6846;
    logic _e_10099;
    (* src = "src/imem.spade:114,17" *)
    logic[10:0] _e_6848;
    logic _e_10101;
    (* src = "src/imem.spade:115,17" *)
    logic[10:0] _e_6850;
    logic _e_10103;
    (* src = "src/imem.spade:116,17" *)
    logic[10:0] _e_6852;
    logic _e_10105;
    (* src = "src/imem.spade:119,17" *)
    logic[10:0] _e_6854;
    logic _e_10107;
    (* src = "src/imem.spade:120,17" *)
    logic[10:0] _e_6856;
    logic _e_10109;
    (* src = "src/imem.spade:121,17" *)
    logic[10:0] _e_6858;
    logic _e_10111;
    (* src = "src/imem.spade:122,17" *)
    logic[10:0] _e_6860;
    logic _e_10113;
    (* src = "src/imem.spade:123,17" *)
    logic[10:0] _e_6862;
    logic _e_10115;
    (* src = "src/imem.spade:124,17" *)
    logic[10:0] _e_6864;
    logic _e_10117;
    (* src = "src/imem.spade:127,17" *)
    logic[10:0] _e_6866;
    logic _e_10119;
    (* src = "src/imem.spade:130,17" *)
    logic[10:0] _e_6868;
    logic _e_10121;
    (* src = "src/imem.spade:133,17" *)
    logic[10:0] _e_6870;
    logic _e_10123;
    (* src = "src/imem.spade:134,17" *)
    logic[10:0] _e_6872;
    logic _e_10125;
    (* src = "src/imem.spade:135,17" *)
    logic[10:0] _e_6874;
    logic _e_10127;
    (* src = "src/imem.spade:136,17" *)
    logic[10:0] _e_6876;
    logic _e_10129;
    (* src = "src/imem.spade:137,17" *)
    logic[10:0] _e_6878;
    logic _e_10131;
    (* src = "src/imem.spade:138,17" *)
    logic[10:0] _e_6880;
    logic _e_10133;
    (* src = "src/imem.spade:141,17" *)
    logic[10:0] _e_6882;
    logic _e_10135;
    (* src = "src/imem.spade:142,17" *)
    logic[10:0] _e_6884;
    logic _e_10137;
    (* src = "src/imem.spade:143,17" *)
    logic[10:0] _e_6886;
    logic _e_10139;
    (* src = "src/imem.spade:146,17" *)
    logic[10:0] _e_6888;
    logic _e_10141;
    (* src = "src/imem.spade:147,17" *)
    logic[10:0] _e_6890;
    logic _e_10143;
    (* src = "src/imem.spade:150,17" *)
    logic[10:0] _e_6892;
    logic _e_10145;
    (* src = "src/imem.spade:151,17" *)
    logic[10:0] _e_6894;
    logic _e_10147;
    (* src = "src/imem.spade:154,17" *)
    logic[10:0] _e_6896;
    logic _e_10149;
    (* src = "src/imem.spade:155,17" *)
    logic[10:0] _e_6898;
    logic _e_10151;
    (* src = "src/imem.spade:156,17" *)
    logic[10:0] _e_6900;
    logic _e_10153;
    (* src = "src/imem.spade:157,17" *)
    logic[10:0] _e_6902;
    logic _e_10155;
    (* src = "src/imem.spade:158,17" *)
    logic[10:0] _e_6904;
    logic _e_10157;
    (* src = "src/imem.spade:159,17" *)
    logic[10:0] _e_6906;
    logic _e_10159;
    (* src = "src/imem.spade:160,17" *)
    logic[10:0] _e_6908;
    logic _e_10161;
    (* src = "src/imem.spade:163,17" *)
    logic[10:0] _e_6910;
    logic _e_10163;
    (* src = "src/imem.spade:164,17" *)
    logic[10:0] _e_6912;
    logic _e_10165;
    (* src = "src/imem.spade:167,17" *)
    logic[10:0] _e_6914;
    logic _e_10167;
    (* src = "src/imem.spade:168,17" *)
    logic[10:0] _e_6916;
    logic _e_10169;
    (* src = "src/imem.spade:169,17" *)
    logic[10:0] _e_6918;
    logic _e_10171;
    (* src = "src/imem.spade:172,17" *)
    logic[10:0] _e_6920;
    logic _e_10173;
    (* src = "src/imem.spade:173,17" *)
    logic[10:0] _e_6922;
    logic _e_10175;
    (* src = "src/imem.spade:174,17" *)
    logic[10:0] _e_6924;
    logic _e_10177;
    (* src = "src/imem.spade:176,17" *)
    logic[10:0] _e_6926;
    logic _e_10179;
    (* src = "src/imem.spade:179,17" *)
    logic[10:0] _e_6928;
    logic _e_10181;
    (* src = "src/imem.spade:180,17" *)
    logic[10:0] _e_6930;
    logic _e_10183;
    (* src = "src/imem.spade:183,17" *)
    logic[10:0] _e_6932;
    logic _e_10185;
    (* src = "src/imem.spade:184,17" *)
    logic[10:0] _e_6934;
    logic _e_10187;
    (* src = "src/imem.spade:185,17" *)
    logic[10:0] _e_6936;
    logic _e_10189;
    (* src = "src/imem.spade:186,17" *)
    logic[10:0] _e_6938;
    logic _e_10191;
    (* src = "src/imem.spade:189,17" *)
    logic[10:0] _e_6940;
    logic _e_10193;
    (* src = "src/imem.spade:190,17" *)
    logic[10:0] _e_6942;
    logic _e_10195;
    (* src = "src/imem.spade:191,17" *)
    logic[10:0] _e_6944;
    logic _e_10197;
    (* src = "src/imem.spade:192,17" *)
    logic[10:0] _e_6946;
    logic _e_10199;
    (* src = "src/imem.spade:195,17" *)
    logic[10:0] _e_6948;
    logic _e_10201;
    (* src = "src/imem.spade:196,17" *)
    logic[10:0] _e_6950;
    logic _e_10203;
    (* src = "src/imem.spade:197,17" *)
    logic[10:0] _e_6952;
    logic _e_10205;
    (* src = "src/imem.spade:200,17" *)
    logic[10:0] _e_6954;
    logic _e_10207;
    (* src = "src/imem.spade:201,17" *)
    logic[10:0] _e_6956;
    logic _e_10209;
    (* src = "src/imem.spade:202,17" *)
    logic[10:0] _e_6958;
    logic _e_10211;
    (* src = "src/imem.spade:205,17" *)
    logic[10:0] _e_6960;
    logic _e_10213;
    (* src = "src/imem.spade:208,17" *)
    logic[10:0] _e_6962;
    logic _e_10215;
    (* src = "src/imem.spade:210,17" *)
    logic[10:0] _e_6964;
    logic _e_10217;
    (* src = "src/imem.spade:211,17" *)
    logic[10:0] _e_6966;
    logic _e_10219;
    (* src = "src/imem.spade:214,17" *)
    logic[10:0] _e_6968;
    logic _e_10221;
    (* src = "src/imem.spade:215,17" *)
    logic[10:0] _e_6970;
    logic _e_10223;
    (* src = "src/imem.spade:216,17" *)
    logic[10:0] _e_6972;
    logic _e_10225;
    (* src = "src/imem.spade:218,18" *)
    logic[10:0] _e_6974;
    logic _e_10227;
    (* src = "src/imem.spade:219,18" *)
    logic[10:0] _e_6977;
    logic _e_10229;
    (* src = "src/imem.spade:220,18" *)
    logic[10:0] _e_6980;
    logic _e_10231;
    (* src = "src/imem.spade:221,18" *)
    logic[10:0] _e_6983;
    logic _e_10233;
    (* src = "src/imem.spade:222,18" *)
    logic[10:0] _e_6986;
    logic _e_10235;
    (* src = "src/imem.spade:223,18" *)
    logic[10:0] _e_6989;
    logic _e_10237;
    (* src = "src/imem.spade:224,18" *)
    logic[10:0] _e_6992;
    logic _e_10239;
    (* src = "src/imem.spade:225,18" *)
    logic[10:0] _e_6995;
    (* src = "src/imem.spade:228,9" *)
    logic[7:0] \_ ;
    (* src = "src/imem.spade:228,14" *)
    logic[10:0] _e_6998;
    (* src = "src/imem.spade:85,5" *)
    logic[10:0] _e_6797;
    localparam[7:0] _e_10060 = 0;
    assign _e_10059 = \t  == _e_10060;
    localparam[3:0] _e_6801 = 0;
    assign _e_6800 = {7'd0, _e_6801};
    localparam[7:0] _e_10062 = 1;
    assign _e_10061 = \t  == _e_10062;
    localparam[3:0] _e_6804 = 1;
    assign _e_6803 = {7'd0, _e_6804};
    localparam[7:0] _e_10064 = 2;
    assign _e_10063 = \t  == _e_10064;
    localparam[3:0] _e_6807 = 2;
    assign _e_6806 = {7'd0, _e_6807};
    localparam[7:0] _e_10066 = 3;
    assign _e_10065 = \t  == _e_10066;
    localparam[3:0] _e_6810 = 3;
    assign _e_6809 = {7'd0, _e_6810};
    localparam[7:0] _e_10068 = 4;
    assign _e_10067 = \t  == _e_10068;
    localparam[3:0] _e_6813 = 4;
    assign _e_6812 = {7'd0, _e_6813};
    localparam[7:0] _e_10070 = 5;
    assign _e_10069 = \t  == _e_10070;
    localparam[3:0] _e_6816 = 5;
    assign _e_6815 = {7'd0, _e_6816};
    localparam[7:0] _e_10072 = 6;
    assign _e_10071 = \t  == _e_10072;
    localparam[3:0] _e_6819 = 6;
    assign _e_6818 = {7'd0, _e_6819};
    localparam[7:0] _e_10074 = 7;
    assign _e_10073 = \t  == _e_10074;
    localparam[3:0] _e_6822 = 7;
    assign _e_6821 = {7'd0, _e_6822};
    localparam[7:0] _e_10076 = 8;
    assign _e_10075 = \t  == _e_10076;
    assign _e_6824 = {7'd31, 4'bX};
    localparam[7:0] _e_10078 = 9;
    assign _e_10077 = \t  == _e_10078;
    assign _e_6826 = {7'd32, 4'bX};
    localparam[7:0] _e_10080 = 10;
    assign _e_10079 = \t  == _e_10080;
    assign _e_6828 = {7'd1, 4'bX};
    localparam[7:0] _e_10082 = 11;
    assign _e_10081 = \t  == _e_10082;
    assign _e_6830 = {7'd2, 4'bX};
    localparam[7:0] _e_10084 = 12;
    assign _e_10083 = \t  == _e_10084;
    assign _e_6832 = {7'd3, 4'bX};
    localparam[7:0] _e_10086 = 13;
    assign _e_10085 = \t  == _e_10086;
    assign _e_6834 = {7'd4, 4'bX};
    localparam[7:0] _e_10088 = 14;
    assign _e_10087 = \t  == _e_10088;
    assign _e_6836 = {7'd5, 4'bX};
    localparam[7:0] _e_10090 = 15;
    assign _e_10089 = \t  == _e_10090;
    assign _e_6838 = {7'd8, 4'bX};
    localparam[7:0] _e_10092 = 16;
    assign _e_10091 = \t  == _e_10092;
    assign _e_6840 = {7'd9, 4'bX};
    localparam[7:0] _e_10094 = 17;
    assign _e_10093 = \t  == _e_10094;
    assign _e_6842 = {7'd10, 4'bX};
    localparam[7:0] _e_10096 = 18;
    assign _e_10095 = \t  == _e_10096;
    assign _e_6844 = {7'd11, 4'bX};
    localparam[7:0] _e_10098 = 19;
    assign _e_10097 = \t  == _e_10098;
    assign _e_6846 = {7'd12, 4'bX};
    localparam[7:0] _e_10100 = 20;
    assign _e_10099 = \t  == _e_10100;
    assign _e_6848 = {7'd33, 4'bX};
    localparam[7:0] _e_10102 = 21;
    assign _e_10101 = \t  == _e_10102;
    assign _e_6850 = {7'd34, 4'bX};
    localparam[7:0] _e_10104 = 22;
    assign _e_10103 = \t  == _e_10104;
    assign _e_6852 = {7'd35, 4'bX};
    localparam[7:0] _e_10106 = 23;
    assign _e_10105 = \t  == _e_10106;
    assign _e_6854 = {7'd41, 4'bX};
    localparam[7:0] _e_10108 = 24;
    assign _e_10107 = \t  == _e_10108;
    assign _e_6856 = {7'd42, 4'bX};
    localparam[7:0] _e_10110 = 25;
    assign _e_10109 = \t  == _e_10110;
    assign _e_6858 = {7'd43, 4'bX};
    localparam[7:0] _e_10112 = 26;
    assign _e_10111 = \t  == _e_10112;
    assign _e_6860 = {7'd44, 4'bX};
    localparam[7:0] _e_10114 = 27;
    assign _e_10113 = \t  == _e_10114;
    assign _e_6862 = {7'd45, 4'bX};
    localparam[7:0] _e_10116 = 28;
    assign _e_10115 = \t  == _e_10116;
    assign _e_6864 = {7'd46, 4'bX};
    localparam[7:0] _e_10118 = 29;
    assign _e_10117 = \t  == _e_10118;
    assign _e_6866 = {7'd57, 4'bX};
    localparam[7:0] _e_10120 = 30;
    assign _e_10119 = \t  == _e_10120;
    assign _e_6868 = {7'd30, 4'bX};
    localparam[7:0] _e_10122 = 31;
    assign _e_10121 = \t  == _e_10122;
    assign _e_6870 = {7'd47, 4'bX};
    localparam[7:0] _e_10124 = 32;
    assign _e_10123 = \t  == _e_10124;
    assign _e_6872 = {7'd48, 4'bX};
    localparam[7:0] _e_10126 = 33;
    assign _e_10125 = \t  == _e_10126;
    assign _e_6874 = {7'd49, 4'bX};
    localparam[7:0] _e_10128 = 34;
    assign _e_10127 = \t  == _e_10128;
    assign _e_6876 = {7'd50, 4'bX};
    localparam[7:0] _e_10130 = 35;
    assign _e_10129 = \t  == _e_10130;
    assign _e_6878 = {7'd51, 4'bX};
    localparam[7:0] _e_10132 = 36;
    assign _e_10131 = \t  == _e_10132;
    assign _e_6880 = {7'd52, 4'bX};
    localparam[7:0] _e_10134 = 37;
    assign _e_10133 = \t  == _e_10134;
    assign _e_6882 = {7'd27, 4'bX};
    localparam[7:0] _e_10136 = 38;
    assign _e_10135 = \t  == _e_10136;
    assign _e_6884 = {7'd28, 4'bX};
    localparam[7:0] _e_10138 = 39;
    assign _e_10137 = \t  == _e_10138;
    assign _e_6886 = {7'd29, 4'bX};
    localparam[7:0] _e_10140 = 40;
    assign _e_10139 = \t  == _e_10140;
    assign _e_6888 = {7'd53, 4'bX};
    localparam[7:0] _e_10142 = 41;
    assign _e_10141 = \t  == _e_10142;
    assign _e_6890 = {7'd54, 4'bX};
    localparam[7:0] _e_10144 = 42;
    assign _e_10143 = \t  == _e_10144;
    assign _e_6892 = {7'd55, 4'bX};
    localparam[7:0] _e_10146 = 43;
    assign _e_10145 = \t  == _e_10146;
    assign _e_6894 = {7'd56, 4'bX};
    localparam[7:0] _e_10148 = 44;
    assign _e_10147 = \t  == _e_10148;
    assign _e_6896 = {7'd19, 4'bX};
    localparam[7:0] _e_10150 = 45;
    assign _e_10149 = \t  == _e_10150;
    assign _e_6898 = {7'd20, 4'bX};
    localparam[7:0] _e_10152 = 46;
    assign _e_10151 = \t  == _e_10152;
    assign _e_6900 = {7'd21, 4'bX};
    localparam[7:0] _e_10154 = 47;
    assign _e_10153 = \t  == _e_10154;
    assign _e_6902 = {7'd22, 4'bX};
    localparam[7:0] _e_10156 = 48;
    assign _e_10155 = \t  == _e_10156;
    assign _e_6904 = {7'd24, 4'bX};
    localparam[7:0] _e_10158 = 49;
    assign _e_10157 = \t  == _e_10158;
    assign _e_6906 = {7'd25, 4'bX};
    localparam[7:0] _e_10160 = 50;
    assign _e_10159 = \t  == _e_10160;
    assign _e_6908 = {7'd26, 4'bX};
    localparam[7:0] _e_10162 = 51;
    assign _e_10161 = \t  == _e_10162;
    assign _e_6910 = {7'd13, 4'bX};
    localparam[7:0] _e_10164 = 52;
    assign _e_10163 = \t  == _e_10164;
    assign _e_6912 = {7'd14, 4'bX};
    localparam[7:0] _e_10166 = 53;
    assign _e_10165 = \t  == _e_10166;
    assign _e_6914 = {7'd58, 4'bX};
    localparam[7:0] _e_10168 = 54;
    assign _e_10167 = \t  == _e_10168;
    assign _e_6916 = {7'd59, 4'bX};
    localparam[7:0] _e_10170 = 55;
    assign _e_10169 = \t  == _e_10170;
    assign _e_6918 = {7'd60, 4'bX};
    localparam[7:0] _e_10172 = 56;
    assign _e_10171 = \t  == _e_10172;
    assign _e_6920 = {7'd61, 4'bX};
    localparam[7:0] _e_10174 = 57;
    assign _e_10173 = \t  == _e_10174;
    assign _e_6922 = {7'd62, 4'bX};
    localparam[7:0] _e_10176 = 58;
    assign _e_10175 = \t  == _e_10176;
    assign _e_6924 = {7'd63, 4'bX};
    localparam[7:0] _e_10178 = 59;
    assign _e_10177 = \t  == _e_10178;
    assign _e_6926 = {7'd68, 4'bX};
    localparam[7:0] _e_10180 = 60;
    assign _e_10179 = \t  == _e_10180;
    assign _e_6928 = {7'd39, 4'bX};
    localparam[7:0] _e_10182 = 61;
    assign _e_10181 = \t  == _e_10182;
    assign _e_6930 = {7'd72, 4'bX};
    localparam[7:0] _e_10184 = 62;
    assign _e_10183 = \t  == _e_10184;
    assign _e_6932 = {7'd64, 4'bX};
    localparam[7:0] _e_10186 = 63;
    assign _e_10185 = \t  == _e_10186;
    assign _e_6934 = {7'd65, 4'bX};
    localparam[7:0] _e_10188 = 64;
    assign _e_10187 = \t  == _e_10188;
    assign _e_6936 = {7'd66, 4'bX};
    localparam[7:0] _e_10190 = 65;
    assign _e_10189 = \t  == _e_10190;
    assign _e_6938 = {7'd67, 4'bX};
    localparam[7:0] _e_10192 = 66;
    assign _e_10191 = \t  == _e_10192;
    assign _e_6940 = {7'd15, 4'bX};
    localparam[7:0] _e_10194 = 67;
    assign _e_10193 = \t  == _e_10194;
    assign _e_6942 = {7'd16, 4'bX};
    localparam[7:0] _e_10196 = 68;
    assign _e_10195 = \t  == _e_10196;
    assign _e_6944 = {7'd17, 4'bX};
    localparam[7:0] _e_10198 = 69;
    assign _e_10197 = \t  == _e_10198;
    assign _e_6946 = {7'd18, 4'bX};
    localparam[7:0] _e_10200 = 70;
    assign _e_10199 = \t  == _e_10200;
    assign _e_6948 = {7'd69, 4'bX};
    localparam[7:0] _e_10202 = 71;
    assign _e_10201 = \t  == _e_10202;
    assign _e_6950 = {7'd70, 4'bX};
    localparam[7:0] _e_10204 = 72;
    assign _e_10203 = \t  == _e_10204;
    assign _e_6952 = {7'd71, 4'bX};
    localparam[7:0] _e_10206 = 73;
    assign _e_10205 = \t  == _e_10206;
    assign _e_6954 = {7'd36, 4'bX};
    localparam[7:0] _e_10208 = 74;
    assign _e_10207 = \t  == _e_10208;
    assign _e_6956 = {7'd37, 4'bX};
    localparam[7:0] _e_10210 = 75;
    assign _e_10209 = \t  == _e_10210;
    assign _e_6958 = {7'd38, 4'bX};
    localparam[7:0] _e_10212 = 76;
    assign _e_10211 = \t  == _e_10212;
    assign _e_6960 = {7'd73, 4'bX};
    localparam[7:0] _e_10214 = 77;
    assign _e_10213 = \t  == _e_10214;
    assign _e_6962 = {7'd6, 4'bX};
    localparam[7:0] _e_10216 = 78;
    assign _e_10215 = \t  == _e_10216;
    assign _e_6964 = {7'd74, 4'bX};
    localparam[7:0] _e_10218 = 79;
    assign _e_10217 = \t  == _e_10218;
    assign _e_6966 = {7'd75, 4'bX};
    localparam[7:0] _e_10220 = 80;
    assign _e_10219 = \t  == _e_10220;
    assign _e_6968 = {7'd7, 4'bX};
    localparam[7:0] _e_10222 = 81;
    assign _e_10221 = \t  == _e_10222;
    assign _e_6970 = {7'd23, 4'bX};
    localparam[7:0] _e_10224 = 82;
    assign _e_10223 = \t  == _e_10224;
    assign _e_6972 = {7'd40, 4'bX};
    localparam[7:0] _e_10226 = 100;
    assign _e_10225 = \t  == _e_10226;
    localparam[3:0] _e_6975 = 8;
    assign _e_6974 = {7'd0, _e_6975};
    localparam[7:0] _e_10228 = 101;
    assign _e_10227 = \t  == _e_10228;
    localparam[3:0] _e_6978 = 9;
    assign _e_6977 = {7'd0, _e_6978};
    localparam[7:0] _e_10230 = 102;
    assign _e_10229 = \t  == _e_10230;
    localparam[3:0] _e_6981 = 10;
    assign _e_6980 = {7'd0, _e_6981};
    localparam[7:0] _e_10232 = 103;
    assign _e_10231 = \t  == _e_10232;
    localparam[3:0] _e_6984 = 11;
    assign _e_6983 = {7'd0, _e_6984};
    localparam[7:0] _e_10234 = 104;
    assign _e_10233 = \t  == _e_10234;
    localparam[3:0] _e_6987 = 12;
    assign _e_6986 = {7'd0, _e_6987};
    localparam[7:0] _e_10236 = 105;
    assign _e_10235 = \t  == _e_10236;
    localparam[3:0] _e_6990 = 13;
    assign _e_6989 = {7'd0, _e_6990};
    localparam[7:0] _e_10238 = 106;
    assign _e_10237 = \t  == _e_10238;
    localparam[3:0] _e_6993 = 14;
    assign _e_6992 = {7'd0, _e_6993};
    localparam[7:0] _e_10240 = 107;
    assign _e_10239 = \t  == _e_10240;
    localparam[3:0] _e_6996 = 15;
    assign _e_6995 = {7'd0, _e_6996};
    assign \_  = \t ;
    localparam[0:0] _e_10241 = 1;
    assign _e_6998 = {7'd1, 4'bX};
    always_comb begin
        priority casez ({_e_10059, _e_10061, _e_10063, _e_10065, _e_10067, _e_10069, _e_10071, _e_10073, _e_10075, _e_10077, _e_10079, _e_10081, _e_10083, _e_10085, _e_10087, _e_10089, _e_10091, _e_10093, _e_10095, _e_10097, _e_10099, _e_10101, _e_10103, _e_10105, _e_10107, _e_10109, _e_10111, _e_10113, _e_10115, _e_10117, _e_10119, _e_10121, _e_10123, _e_10125, _e_10127, _e_10129, _e_10131, _e_10133, _e_10135, _e_10137, _e_10139, _e_10141, _e_10143, _e_10145, _e_10147, _e_10149, _e_10151, _e_10153, _e_10155, _e_10157, _e_10159, _e_10161, _e_10163, _e_10165, _e_10167, _e_10169, _e_10171, _e_10173, _e_10175, _e_10177, _e_10179, _e_10181, _e_10183, _e_10185, _e_10187, _e_10189, _e_10191, _e_10193, _e_10195, _e_10197, _e_10199, _e_10201, _e_10203, _e_10205, _e_10207, _e_10209, _e_10211, _e_10213, _e_10215, _e_10217, _e_10219, _e_10221, _e_10223, _e_10225, _e_10227, _e_10229, _e_10231, _e_10233, _e_10235, _e_10237, _e_10239, _e_10241})
            92'b1???????????????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6800;
            92'b01??????????????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6803;
            92'b001?????????????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6806;
            92'b0001????????????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6809;
            92'b00001???????????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6812;
            92'b000001??????????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6815;
            92'b0000001?????????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6818;
            92'b00000001????????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6821;
            92'b000000001???????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6824;
            92'b0000000001??????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6826;
            92'b00000000001?????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6828;
            92'b000000000001????????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6830;
            92'b0000000000001???????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6832;
            92'b00000000000001??????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6834;
            92'b000000000000001?????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6836;
            92'b0000000000000001????????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6838;
            92'b00000000000000001???????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6840;
            92'b000000000000000001??????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6842;
            92'b0000000000000000001?????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6844;
            92'b00000000000000000001????????????????????????????????????????????????????????????????????????: _e_6797 = _e_6846;
            92'b000000000000000000001???????????????????????????????????????????????????????????????????????: _e_6797 = _e_6848;
            92'b0000000000000000000001??????????????????????????????????????????????????????????????????????: _e_6797 = _e_6850;
            92'b00000000000000000000001?????????????????????????????????????????????????????????????????????: _e_6797 = _e_6852;
            92'b000000000000000000000001????????????????????????????????????????????????????????????????????: _e_6797 = _e_6854;
            92'b0000000000000000000000001???????????????????????????????????????????????????????????????????: _e_6797 = _e_6856;
            92'b00000000000000000000000001??????????????????????????????????????????????????????????????????: _e_6797 = _e_6858;
            92'b000000000000000000000000001?????????????????????????????????????????????????????????????????: _e_6797 = _e_6860;
            92'b0000000000000000000000000001????????????????????????????????????????????????????????????????: _e_6797 = _e_6862;
            92'b00000000000000000000000000001???????????????????????????????????????????????????????????????: _e_6797 = _e_6864;
            92'b000000000000000000000000000001??????????????????????????????????????????????????????????????: _e_6797 = _e_6866;
            92'b0000000000000000000000000000001?????????????????????????????????????????????????????????????: _e_6797 = _e_6868;
            92'b00000000000000000000000000000001????????????????????????????????????????????????????????????: _e_6797 = _e_6870;
            92'b000000000000000000000000000000001???????????????????????????????????????????????????????????: _e_6797 = _e_6872;
            92'b0000000000000000000000000000000001??????????????????????????????????????????????????????????: _e_6797 = _e_6874;
            92'b00000000000000000000000000000000001?????????????????????????????????????????????????????????: _e_6797 = _e_6876;
            92'b000000000000000000000000000000000001????????????????????????????????????????????????????????: _e_6797 = _e_6878;
            92'b0000000000000000000000000000000000001???????????????????????????????????????????????????????: _e_6797 = _e_6880;
            92'b00000000000000000000000000000000000001??????????????????????????????????????????????????????: _e_6797 = _e_6882;
            92'b000000000000000000000000000000000000001?????????????????????????????????????????????????????: _e_6797 = _e_6884;
            92'b0000000000000000000000000000000000000001????????????????????????????????????????????????????: _e_6797 = _e_6886;
            92'b00000000000000000000000000000000000000001???????????????????????????????????????????????????: _e_6797 = _e_6888;
            92'b000000000000000000000000000000000000000001??????????????????????????????????????????????????: _e_6797 = _e_6890;
            92'b0000000000000000000000000000000000000000001?????????????????????????????????????????????????: _e_6797 = _e_6892;
            92'b00000000000000000000000000000000000000000001????????????????????????????????????????????????: _e_6797 = _e_6894;
            92'b000000000000000000000000000000000000000000001???????????????????????????????????????????????: _e_6797 = _e_6896;
            92'b0000000000000000000000000000000000000000000001??????????????????????????????????????????????: _e_6797 = _e_6898;
            92'b00000000000000000000000000000000000000000000001?????????????????????????????????????????????: _e_6797 = _e_6900;
            92'b000000000000000000000000000000000000000000000001????????????????????????????????????????????: _e_6797 = _e_6902;
            92'b0000000000000000000000000000000000000000000000001???????????????????????????????????????????: _e_6797 = _e_6904;
            92'b00000000000000000000000000000000000000000000000001??????????????????????????????????????????: _e_6797 = _e_6906;
            92'b000000000000000000000000000000000000000000000000001?????????????????????????????????????????: _e_6797 = _e_6908;
            92'b0000000000000000000000000000000000000000000000000001????????????????????????????????????????: _e_6797 = _e_6910;
            92'b00000000000000000000000000000000000000000000000000001???????????????????????????????????????: _e_6797 = _e_6912;
            92'b000000000000000000000000000000000000000000000000000001??????????????????????????????????????: _e_6797 = _e_6914;
            92'b0000000000000000000000000000000000000000000000000000001?????????????????????????????????????: _e_6797 = _e_6916;
            92'b00000000000000000000000000000000000000000000000000000001????????????????????????????????????: _e_6797 = _e_6918;
            92'b000000000000000000000000000000000000000000000000000000001???????????????????????????????????: _e_6797 = _e_6920;
            92'b0000000000000000000000000000000000000000000000000000000001??????????????????????????????????: _e_6797 = _e_6922;
            92'b00000000000000000000000000000000000000000000000000000000001?????????????????????????????????: _e_6797 = _e_6924;
            92'b000000000000000000000000000000000000000000000000000000000001????????????????????????????????: _e_6797 = _e_6926;
            92'b0000000000000000000000000000000000000000000000000000000000001???????????????????????????????: _e_6797 = _e_6928;
            92'b00000000000000000000000000000000000000000000000000000000000001??????????????????????????????: _e_6797 = _e_6930;
            92'b000000000000000000000000000000000000000000000000000000000000001?????????????????????????????: _e_6797 = _e_6932;
            92'b0000000000000000000000000000000000000000000000000000000000000001????????????????????????????: _e_6797 = _e_6934;
            92'b00000000000000000000000000000000000000000000000000000000000000001???????????????????????????: _e_6797 = _e_6936;
            92'b000000000000000000000000000000000000000000000000000000000000000001??????????????????????????: _e_6797 = _e_6938;
            92'b0000000000000000000000000000000000000000000000000000000000000000001?????????????????????????: _e_6797 = _e_6940;
            92'b00000000000000000000000000000000000000000000000000000000000000000001????????????????????????: _e_6797 = _e_6942;
            92'b000000000000000000000000000000000000000000000000000000000000000000001???????????????????????: _e_6797 = _e_6944;
            92'b0000000000000000000000000000000000000000000000000000000000000000000001??????????????????????: _e_6797 = _e_6946;
            92'b00000000000000000000000000000000000000000000000000000000000000000000001?????????????????????: _e_6797 = _e_6948;
            92'b000000000000000000000000000000000000000000000000000000000000000000000001????????????????????: _e_6797 = _e_6950;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000001???????????????????: _e_6797 = _e_6952;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000001??????????????????: _e_6797 = _e_6954;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000001?????????????????: _e_6797 = _e_6956;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000001????????????????: _e_6797 = _e_6958;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000001???????????????: _e_6797 = _e_6960;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000001??????????????: _e_6797 = _e_6962;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000001?????????????: _e_6797 = _e_6964;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000001????????????: _e_6797 = _e_6966;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000000001???????????: _e_6797 = _e_6968;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000000001??????????: _e_6797 = _e_6970;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000000001?????????: _e_6797 = _e_6972;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000000000001????????: _e_6797 = _e_6974;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000001???????: _e_6797 = _e_6977;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000001??????: _e_6797 = _e_6980;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000001?????: _e_6797 = _e_6983;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000001????: _e_6797 = _e_6986;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001???: _e_6797 = _e_6989;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001??: _e_6797 = _e_6992;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001?: _e_6797 = _e_6995;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001: _e_6797 = _e_6998;
            92'b?: _e_6797 = 11'dx;
        endcase
    end
    assign output__ = _e_6797;
endmodule

module \tta::imem::decode_move  (
        input[31:0] mw_i,
        output[48:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::imem::decode_move" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::imem::decode_move );
        end
    end
    `endif
    logic[31:0] \mw ;
    assign \mw  = mw_i;
    (* src = "src/imem.spade:234,36" *)
    logic[31:0] _e_7002;
    (* src = "src/imem.spade:234,36" *)
    logic[31:0] _e_7001;
    (* src = "src/imem.spade:234,30" *)
    logic \guard_bit ;
    (* src = "src/imem.spade:235,23" *)
    logic \guard ;
    (* src = "src/imem.spade:237,34" *)
    logic[31:0] _e_7013;
    (* src = "src/imem.spade:237,34" *)
    logic[31:0] _e_7012;
    (* src = "src/imem.spade:237,28" *)
    logic[7:0] \src_tok ;
    (* src = "src/imem.spade:238,34" *)
    logic[31:0] _e_7020;
    (* src = "src/imem.spade:238,34" *)
    logic[31:0] _e_7019;
    (* src = "src/imem.spade:238,28" *)
    logic[7:0] \dst_tok ;
    (* src = "src/imem.spade:239,34" *)
    logic[31:0] _e_7026;
    (* src = "src/imem.spade:239,28" *)
    logic[15:0] \imm16 ;
    (* src = "src/imem.spade:241,15" *)
    logic[36:0] \src ;
    (* src = "src/imem.spade:242,15" *)
    logic[10:0] \dst ;
    (* src = "src/imem.spade:243,5" *)
    logic[48:0] _e_7037;
    localparam[31:0] _e_7004 = 32'd31;
    assign _e_7002 = \mw  >> _e_7004;
    localparam[31:0] _e_7005 = 32'd1;
    assign _e_7001 = _e_7002 & _e_7005;
    assign \guard_bit  = _e_7001[0:0];
    localparam[0:0] _e_7009 = 0;
    assign \guard  = \guard_bit  != _e_7009;
    localparam[31:0] _e_7015 = 32'd24;
    assign _e_7013 = \mw  >> _e_7015;
    localparam[31:0] _e_7016 = 32'd127;
    assign _e_7012 = _e_7013 & _e_7016;
    assign \src_tok  = _e_7012[7:0];
    localparam[31:0] _e_7022 = 32'd17;
    assign _e_7020 = \mw  >> _e_7022;
    localparam[31:0] _e_7023 = 32'd127;
    assign _e_7019 = _e_7020 & _e_7023;
    assign \dst_tok  = _e_7019[7:0];
    localparam[31:0] _e_7028 = 32'd65535;
    assign _e_7026 = \mw  & _e_7028;
    assign \imm16  = _e_7026[15:0];
    (* src = "src/imem.spade:241,15" *)
    \tta::imem::decode_src_tok  decode_src_tok_0(.t_i(\src_tok ), .imm16_i(\imm16 ), .output__(\src ));
    (* src = "src/imem.spade:242,15" *)
    \tta::imem::decode_dst_tok  decode_dst_tok_0(.t_i(\dst_tok ), .output__(\dst ));
    assign _e_7037 = {\src , \dst , \guard };
    assign output__ = _e_7037;
endmodule

module \tta::imem::zero32  (
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::imem::zero32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::imem::zero32 );
        end
    end
    `endif
    localparam[31:0] _e_7042 = 32'd0;
    assign output__ = _e_7042;
endmodule

module \tta::imem::imem  (
        `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input boot_mode_i,
        input[9:0] fetch_pc_i,
        input[10:0] wr_addr_i,
        input[32:0] wr_slot0_i,
        input[32:0] wr_slot1_i,
        output[98:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::imem::imem" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::imem::imem );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic \boot_mode ;
    assign \boot_mode  = boot_mode_i;
    logic[9:0] \fetch_pc ;
    assign \fetch_pc  = fetch_pc_i;
    logic[10:0] \wr_addr ;
    assign \wr_addr  = wr_addr_i;
    logic[32:0] \wr_slot0 ;
    assign \wr_slot0  = wr_slot0_i;
    logic[32:0] \wr_slot1 ;
    assign \wr_slot1  = wr_slot1_i;
    (* src = "src/imem.spade:266,9" *)
    logic[9:0] \addr ;
    logic _e_10243;
    logic _e_10245;
    (* src = "src/imem.spade:266,23" *)
    logic[10:0] _e_7048;
    logic _e_10247;
    (* src = "src/imem.spade:267,17" *)
    logic[10:0] _e_7052;
    (* src = "src/imem.spade:265,29" *)
    logic[10:0] _e_7057;
    (* src = "src/imem.spade:265,9" *)
    logic \wren ;
    (* src = "src/imem.spade:265,9" *)
    logic[9:0] \addr_calc ;
    (* src = "src/imem.spade:270,9" *)
    logic[31:0] \instr ;
    logic _e_10249;
    logic _e_10251;
    logic _e_10253;
    (* src = "src/imem.spade:269,18" *)
    logic[31:0] \wdata0 ;
    (* src = "src/imem.spade:274,9" *)
    logic[31:0] instr_n1;
    logic _e_10255;
    logic _e_10257;
    logic _e_10259;
    (* src = "src/imem.spade:273,18" *)
    logic[31:0] \wdata1 ;
    (* src = "src/imem.spade:278,33" *)
    logic[31:0] _e_7076;
    (* src = "src/imem.spade:278,14" *)
    reg[31:0] \rdata0 ;
    (* src = "src/imem.spade:279,33" *)
    logic[31:0] _e_7084;
    (* src = "src/imem.spade:279,14" *)
    reg[31:0] \rdata1 ;
    (* src = "src/imem.spade:283,9" *)
    logic[9:0] \_ ;
    logic _e_10261;
    logic _e_10263;
    (* src = "src/imem.spade:283,20" *)
    logic[98:0] _e_7094;
    logic _e_10265;
    (* src = "src/imem.spade:286,25" *)
    logic[98:0] _e_7100;
    logic _e_10267;
    (* src = "src/imem.spade:288,31" *)
    logic[48:0] \mv0 ;
    (* src = "src/imem.spade:289,31" *)
    logic[48:0] \mv1 ;
    (* src = "src/imem.spade:290,26" *)
    logic[97:0] _e_7110;
    (* src = "src/imem.spade:290,21" *)
    logic[98:0] _e_7109;
    (* src = "src/imem.spade:285,13" *)
    logic[98:0] _e_7097;
    (* src = "src/imem.spade:282,5" *)
    logic[98:0] _e_7090;
    assign \addr  = \wr_addr [9:0];
    assign _e_10243 = \wr_addr [10] == 1'd1;
    localparam[0:0] _e_10244 = 1;
    assign _e_10245 = _e_10243 && _e_10244;
    localparam[0:0] _e_7049 = 1;
    assign _e_7048 = {_e_7049, \addr };
    assign _e_10247 = \wr_addr [10] == 1'd0;
    localparam[0:0] _e_7053 = 0;
    assign _e_7052 = {_e_7053, \fetch_pc };
    always_comb begin
        priority casez ({_e_10245, _e_10247})
            2'b1?: _e_7057 = _e_7048;
            2'b01: _e_7057 = _e_7052;
            2'b?: _e_7057 = 11'dx;
        endcase
    end
    assign \wren  = _e_7057[10];
    assign \addr_calc  = _e_7057[9:0];
    assign \instr  = \wr_slot0 [31:0];
    assign _e_10249 = \wr_slot0 [32] == 1'd1;
    localparam[0:0] _e_10250 = 1;
    assign _e_10251 = _e_10249 && _e_10250;
    assign _e_10253 = \wr_slot0 [32] == 1'd0;
    localparam[31:0] _e_7064 = 32'd0;
    always_comb begin
        priority casez ({_e_10251, _e_10253})
            2'b1?: \wdata0  = \instr ;
            2'b01: \wdata0  = _e_7064;
            2'b?: \wdata0  = 32'dx;
        endcase
    end
    assign instr_n1 = \wr_slot1 [31:0];
    assign _e_10255 = \wr_slot1 [32] == 1'd1;
    localparam[0:0] _e_10256 = 1;
    assign _e_10257 = _e_10255 && _e_10256;
    assign _e_10259 = \wr_slot1 [32] == 1'd0;
    localparam[31:0] _e_7072 = 32'd0;
    always_comb begin
        priority casez ({_e_10257, _e_10259})
            2'b1?: \wdata1  = instr_n1;
            2'b01: \wdata1  = _e_7072;
            2'b?: \wdata1  = 32'dx;
        endcase
    end
    (* src = "src/imem.spade:278,33" *)
    \tta::sram::iram_1024x32  iram_1024x32_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .addr_i(\addr_calc ), .we_i(\wren ), .wdata_i(\wdata0 ), .output__(_e_7076));
    always @(posedge \clk ) begin
        \rdata0  <= _e_7076;
    end
    (* src = "src/imem.spade:279,33" *)
    \tta::sram::iram_1024x32  iram_1024x32_1(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .addr_i(\addr_calc ), .we_i(\wren ), .wdata_i(\wdata1 ), .output__(_e_7084));
    always @(posedge \clk ) begin
        \rdata1  <= _e_7084;
    end
    assign \_  = \wr_addr [9:0];
    assign _e_10261 = \wr_addr [10] == 1'd1;
    localparam[0:0] _e_10262 = 1;
    assign _e_10263 = _e_10261 && _e_10262;
    assign _e_7094 = {1'd0, 98'bX};
    assign _e_10265 = \wr_addr [10] == 1'd0;
    assign _e_7100 = {1'd0, 98'bX};
    assign _e_10267 = !\boot_mode ;
    (* src = "src/imem.spade:288,31" *)
    \tta::imem::decode_move  decode_move_0(.mw_i(\rdata0 ), .output__(\mv0 ));
    (* src = "src/imem.spade:289,31" *)
    \tta::imem::decode_move  decode_move_1(.mw_i(\rdata1 ), .output__(\mv1 ));
    assign _e_7110 = {\mv0 , \mv1 };
    assign _e_7109 = {1'd1, _e_7110};
    always_comb begin
        priority casez ({\boot_mode , _e_10267})
            2'b1?: _e_7097 = _e_7100;
            2'b01: _e_7097 = _e_7109;
            2'b?: _e_7097 = 99'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10263, _e_10265})
            2'b1?: _e_7090 = _e_7094;
            2'b01: _e_7090 = _e_7097;
            2'b?: _e_7090 = 99'dx;
        endcase
    end
    assign output__ = _e_7090;
endmodule

module \tta::spi_master::reset_spi  (
        output[14:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::spi_master::reset_spi" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::spi_master::reset_spi );
        end
    end
    `endif
    (* src = "src/spi_master.spade:28,9" *)
    logic _e_7115;
    (* src = "src/spi_master.spade:28,5" *)
    logic[14:0] _e_7114;
    assign _e_7115 = {1'd0};
    localparam[4:0] _e_7116 = 0;
    localparam[7:0] _e_7117 = 0;
    localparam[0:0] _e_7118 = 0;
    assign _e_7114 = {_e_7115, _e_7116, _e_7117, _e_7118};
    assign output__ = _e_7114;
endmodule

module \tta::spi_master::spi_master  (
        input clk_i,
        input rst_i,
        input tick_i,
        input miso_i,
        input[8:0] start_tx_i,
        output[11:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::spi_master::spi_master" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::spi_master::spi_master );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic \tick ;
    assign \tick  = tick_i;
    logic \miso ;
    assign \miso  = miso_i;
    logic[8:0] \start_tx ;
    assign \start_tx  = start_tx_i;
    (* src = "src/spi_master.spade:39,32" *)
    logic[14:0] _e_7123;
    (* src = "src/spi_master.spade:41,19" *)
    logic _e_7128;
    (* src = "src/spi_master.spade:42,17" *)
    logic _e_7130;
    logic _e_10269;
    (* src = "src/spi_master.spade:43,27" *)
    logic[8:0] _e_7133;
    (* src = "src/spi_master.spade:45,25" *)
    logic[8:0] _e_7136;
    (* src = "src/spi_master.spade:45,25" *)
    logic[7:0] \data ;
    logic _e_10271;
    logic _e_10273;
    (* src = "src/spi_master.spade:45,43" *)
    logic _e_7138;
    (* src = "src/spi_master.spade:45,39" *)
    logic[14:0] _e_7137;
    (* src = "src/spi_master.spade:46,25" *)
    logic[8:0] _e_7142;
    logic _e_10275;
    (* src = "src/spi_master.spade:43,21" *)
    logic[14:0] _e_7132;
    (* src = "src/spi_master.spade:49,17" *)
    logic _e_7144;
    logic _e_10277;
    (* src = "src/spi_master.spade:53,41" *)
    logic[4:0] _e_7148;
    (* src = "src/spi_master.spade:53,41" *)
    logic[5:0] _e_7147;
    (* src = "src/spi_master.spade:53,35" *)
    logic[4:0] \new_cnt ;
    (* src = "src/spi_master.spade:55,24" *)
    logic[4:0] _e_7154;
    (* src = "src/spi_master.spade:55,24" *)
    logic _e_7153;
    (* src = "src/spi_master.spade:58,29" *)
    logic _e_7159;
    (* src = "src/spi_master.spade:58,45" *)
    logic[7:0] _e_7161;
    (* src = "src/spi_master.spade:58,25" *)
    logic[14:0] _e_7158;
    (* src = "src/spi_master.spade:60,29" *)
    logic[4:0] _e_7166;
    (* src = "src/spi_master.spade:60,29" *)
    logic _e_7165;
    (* src = "src/spi_master.spade:63,29" *)
    logic _e_7172;
    (* src = "src/spi_master.spade:63,55" *)
    logic[7:0] _e_7174;
    (* src = "src/spi_master.spade:63,25" *)
    logic[14:0] _e_7171;
    (* src = "src/spi_master.spade:68,40" *)
    logic[7:0] _e_7181;
    (* src = "src/spi_master.spade:68,39" *)
    logic[7:0] _e_7180;
    (* src = "src/spi_master.spade:68,58" *)
    logic _e_7185;
    logic[7:0] _e_7184;
    (* src = "src/spi_master.spade:68,39" *)
    logic[7:0] \next_sh ;
    (* src = "src/spi_master.spade:69,29" *)
    logic _e_7189;
    (* src = "src/spi_master.spade:69,64" *)
    logic _e_7192;
    (* src = "src/spi_master.spade:69,25" *)
    logic[14:0] _e_7188;
    (* src = "src/spi_master.spade:60,26" *)
    logic[14:0] _e_7164;
    (* src = "src/spi_master.spade:55,21" *)
    logic[14:0] _e_7152;
    (* src = "src/spi_master.spade:41,13" *)
    logic[14:0] _e_7127;
    (* src = "src/spi_master.spade:40,9" *)
    logic[14:0] _e_7124;
    (* src = "src/spi_master.spade:39,14" *)
    reg[14:0] \r ;
    (* src = "src/spi_master.spade:81,20" *)
    logic _e_7197;
    (* src = "src/spi_master.spade:82,9" *)
    logic _e_7199;
    logic _e_10279;
    (* src = "src/spi_master.spade:83,9" *)
    logic _e_7201;
    logic _e_10281;
    (* src = "src/spi_master.spade:81,14" *)
    logic \cs ;
    (* src = "src/spi_master.spade:88,22" *)
    logic _e_7205;
    (* src = "src/spi_master.spade:89,9" *)
    logic _e_7207;
    logic _e_10283;
    (* src = "src/spi_master.spade:89,29" *)
    logic[4:0] _e_7210;
    (* src = "src/spi_master.spade:89,28" *)
    logic[4:0] _e_7209;
    (* src = "src/spi_master.spade:89,28" *)
    logic _e_7208;
    (* src = "src/spi_master.spade:90,9" *)
    logic _e_7214;
    logic _e_10285;
    (* src = "src/spi_master.spade:88,16" *)
    logic \sclk ;
    (* src = "src/spi_master.spade:96,23" *)
    logic[7:0] _e_7220;
    (* src = "src/spi_master.spade:96,22" *)
    logic[7:0] _e_7219;
    (* src = "src/spi_master.spade:96,22" *)
    logic _e_7218;
    (* src = "src/spi_master.spade:97,9" *)
    logic _e_7224;
    (* src = "src/spi_master.spade:98,9" *)
    logic _e_7226;
    logic _e_10287;
    (* src = "src/spi_master.spade:96,16" *)
    logic \mosi ;
    (* src = "src/spi_master.spade:103,30" *)
    logic[4:0] _e_7233;
    (* src = "src/spi_master.spade:103,29" *)
    logic _e_7232;
    (* src = "src/spi_master.spade:103,21" *)
    logic _e_7230;
    (* src = "src/spi_master.spade:106,14" *)
    logic[7:0] _e_7238;
    (* src = "src/spi_master.spade:106,9" *)
    logic[8:0] _e_7237;
    (* src = "src/spi_master.spade:108,9" *)
    logic[8:0] _e_7241;
    (* src = "src/spi_master.spade:103,18" *)
    logic[8:0] \rx_val ;
    (* src = "src/spi_master.spade:111,5" *)
    logic[11:0] _e_7243;
    (* src = "src/spi_master.spade:39,32" *)
    \tta::spi_master::reset_spi  reset_spi_0(.output__(_e_7123));
    assign _e_7128 = \r [14];
    assign _e_7130 = _e_7128;
    assign _e_10269 = _e_7128 == 1'd0;
    assign _e_7133 = \start_tx ;
    assign _e_7136 = _e_7133;
    assign \data  = _e_7133[7:0];
    assign _e_10271 = _e_7133[8] == 1'd1;
    localparam[0:0] _e_10272 = 1;
    assign _e_10273 = _e_10271 && _e_10272;
    assign _e_7138 = {1'd1};
    localparam[4:0] _e_7139 = 0;
    localparam[0:0] _e_7141 = 0;
    assign _e_7137 = {_e_7138, _e_7139, \data , _e_7141};
    assign _e_7142 = _e_7133;
    assign _e_10275 = _e_7133[8] == 1'd0;
    always_comb begin
        priority casez ({_e_10273, _e_10275})
            2'b1?: _e_7132 = _e_7137;
            2'b01: _e_7132 = \r ;
            2'b?: _e_7132 = 15'dx;
        endcase
    end
    assign _e_7144 = _e_7128;
    assign _e_10277 = _e_7128 == 1'd1;
    assign _e_7148 = \r [13:9];
    localparam[4:0] _e_7150 = 1;
    assign _e_7147 = _e_7148 + _e_7150;
    assign \new_cnt  = _e_7147[4:0];
    assign _e_7154 = \r [13:9];
    localparam[4:0] _e_7156 = 16;
    assign _e_7153 = _e_7154 == _e_7156;
    assign _e_7159 = {1'd0};
    localparam[4:0] _e_7160 = 0;
    assign _e_7161 = \r [8:1];
    localparam[0:0] _e_7163 = 0;
    assign _e_7158 = {_e_7159, _e_7160, _e_7161, _e_7163};
    localparam[4:0] _e_7168 = 2;
    assign _e_7166 = \new_cnt  % _e_7168;
    localparam[4:0] _e_7169 = 0;
    assign _e_7165 = _e_7166 != _e_7169;
    assign _e_7172 = {1'd1};
    assign _e_7174 = \r [8:1];
    assign _e_7171 = {_e_7172, \new_cnt , _e_7174, \miso };
    assign _e_7181 = \r [8:1];
    localparam[7:0] _e_7183 = 1;
    assign _e_7180 = _e_7181 << _e_7183;
    assign _e_7185 = \r [0];
    assign _e_7184 = {7'b0, _e_7185};
    assign \next_sh  = _e_7180 | _e_7184;
    assign _e_7189 = {1'd1};
    assign _e_7192 = \r [0];
    assign _e_7188 = {_e_7189, \new_cnt , \next_sh , _e_7192};
    assign _e_7164 = _e_7165 ? _e_7171 : _e_7188;
    assign _e_7152 = _e_7153 ? _e_7158 : _e_7164;
    always_comb begin
        priority casez ({_e_10269, _e_10277})
            2'b1?: _e_7127 = _e_7132;
            2'b01: _e_7127 = _e_7152;
            2'b?: _e_7127 = 15'dx;
        endcase
    end
    assign _e_7124 = \tick  ? _e_7127 : \r ;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_7123;
        end
        else begin
            \r  <= _e_7124;
        end
    end
    assign _e_7197 = \r [14];
    assign _e_7199 = _e_7197;
    assign _e_10279 = _e_7197 == 1'd0;
    localparam[0:0] _e_7200 = 1;
    assign _e_7201 = _e_7197;
    assign _e_10281 = _e_7197 == 1'd1;
    localparam[0:0] _e_7202 = 0;
    always_comb begin
        priority casez ({_e_10279, _e_10281})
            2'b1?: \cs  = _e_7200;
            2'b01: \cs  = _e_7202;
            2'b?: \cs  = 1'dx;
        endcase
    end
    assign _e_7205 = \r [14];
    assign _e_7207 = _e_7205;
    assign _e_10283 = _e_7205 == 1'd1;
    assign _e_7210 = \r [13:9];
    localparam[4:0] _e_7212 = 2;
    assign _e_7209 = _e_7210 % _e_7212;
    localparam[4:0] _e_7213 = 0;
    assign _e_7208 = _e_7209 != _e_7213;
    assign _e_7214 = _e_7205;
    assign _e_10285 = _e_7205 == 1'd0;
    localparam[0:0] _e_7215 = 0;
    always_comb begin
        priority casez ({_e_10283, _e_10285})
            2'b1?: \sclk  = _e_7208;
            2'b01: \sclk  = _e_7215;
            2'b?: \sclk  = 1'dx;
        endcase
    end
    assign _e_7220 = \r [8:1];
    localparam[7:0] _e_7222 = 7;
    assign _e_7219 = _e_7220 >> _e_7222;
    localparam[7:0] _e_7223 = 0;
    assign _e_7218 = _e_7219 != _e_7223;
    assign _e_7224 = _e_7218;
    localparam[0:0] _e_7225 = 1;
    assign _e_7226 = _e_7218;
    assign _e_10287 = !_e_7218;
    localparam[0:0] _e_7227 = 0;
    always_comb begin
        priority casez ({_e_7218, _e_10287})
            2'b1?: \mosi  = _e_7225;
            2'b01: \mosi  = _e_7227;
            2'b?: \mosi  = 1'dx;
        endcase
    end
    assign _e_7233 = \r [13:9];
    localparam[4:0] _e_7235 = 16;
    assign _e_7232 = _e_7233 == _e_7235;
    assign _e_7230 = \tick  && _e_7232;
    assign _e_7238 = \r [8:1];
    assign _e_7237 = {1'd1, _e_7238};
    assign _e_7241 = {1'd0, 8'bX};
    assign \rx_val  = _e_7230 ? _e_7237 : _e_7241;
    assign _e_7243 = {\cs , \sclk , \mosi , \rx_val };
    assign output__ = _e_7243;
endmodule

module \tta::regfile::regfile8_fu  (
        input clk_i,
        input rst_i,
        input[36:0] wr0_i,
        input[36:0] wr1_i,
        input[3:0] ra0_i,
        input[3:0] ra1_i,
        output[575:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::regfile::regfile8_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::regfile::regfile8_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[36:0] \wr0 ;
    assign \wr0  = wr0_i;
    logic[36:0] \wr1 ;
    assign \wr1  = wr1_i;
    logic[3:0] \ra0 ;
    assign \ra0  = ra0_i;
    logic[3:0] \ra1 ;
    assign \ra1  = ra1_i;
    (* src = "src/regfile.spade:43,43" *)
    logic[31:0] _e_7253;
    (* src = "src/regfile.spade:43,14" *)
    reg[31:0] \r0 ;
    (* src = "src/regfile.spade:44,43" *)
    logic[31:0] _e_7262;
    (* src = "src/regfile.spade:44,14" *)
    reg[31:0] \r1 ;
    (* src = "src/regfile.spade:45,43" *)
    logic[31:0] _e_7271;
    (* src = "src/regfile.spade:45,14" *)
    reg[31:0] \r2 ;
    (* src = "src/regfile.spade:46,43" *)
    logic[31:0] _e_7280;
    (* src = "src/regfile.spade:46,14" *)
    reg[31:0] \r3 ;
    (* src = "src/regfile.spade:47,43" *)
    logic[31:0] _e_7289;
    (* src = "src/regfile.spade:47,14" *)
    reg[31:0] \r4 ;
    (* src = "src/regfile.spade:48,43" *)
    logic[31:0] _e_7298;
    (* src = "src/regfile.spade:48,14" *)
    reg[31:0] \r5 ;
    (* src = "src/regfile.spade:49,43" *)
    logic[31:0] _e_7307;
    (* src = "src/regfile.spade:49,14" *)
    reg[31:0] \r6 ;
    (* src = "src/regfile.spade:50,43" *)
    logic[31:0] _e_7316;
    (* src = "src/regfile.spade:50,14" *)
    reg[31:0] \r7 ;
    (* src = "src/regfile.spade:52,43" *)
    logic[31:0] _e_7325;
    (* src = "src/regfile.spade:52,14" *)
    reg[31:0] \r8 ;
    (* src = "src/regfile.spade:53,43" *)
    logic[31:0] _e_7334;
    (* src = "src/regfile.spade:53,14" *)
    reg[31:0] \r9 ;
    (* src = "src/regfile.spade:54,44" *)
    logic[31:0] _e_7343;
    (* src = "src/regfile.spade:54,14" *)
    reg[31:0] \r10 ;
    (* src = "src/regfile.spade:55,44" *)
    logic[31:0] _e_7352;
    (* src = "src/regfile.spade:55,14" *)
    reg[31:0] \r11 ;
    (* src = "src/regfile.spade:56,44" *)
    logic[31:0] _e_7361;
    (* src = "src/regfile.spade:56,14" *)
    reg[31:0] \r12 ;
    (* src = "src/regfile.spade:57,44" *)
    logic[31:0] _e_7370;
    (* src = "src/regfile.spade:57,14" *)
    reg[31:0] \r13 ;
    (* src = "src/regfile.spade:58,44" *)
    logic[31:0] _e_7379;
    (* src = "src/regfile.spade:58,14" *)
    reg[31:0] \r14 ;
    (* src = "src/regfile.spade:59,44" *)
    logic[31:0] _e_7388;
    (* src = "src/regfile.spade:59,14" *)
    reg[31:0] \r15 ;
    logic _e_10288;
    logic _e_10290;
    logic _e_10292;
    logic _e_10294;
    logic _e_10296;
    logic _e_10298;
    logic _e_10300;
    logic _e_10302;
    logic _e_10304;
    logic _e_10306;
    logic _e_10308;
    logic _e_10310;
    logic _e_10312;
    logic _e_10314;
    logic _e_10316;
    (* src = "src/regfile.spade:78,29" *)
    logic[3:0] \_ ;
    (* src = "src/regfile.spade:62,25" *)
    logic[31:0] \rd0 ;
    logic _e_10319;
    logic _e_10321;
    logic _e_10323;
    logic _e_10325;
    logic _e_10327;
    logic _e_10329;
    logic _e_10331;
    logic _e_10333;
    logic _e_10335;
    logic _e_10337;
    logic _e_10339;
    logic _e_10341;
    logic _e_10343;
    logic _e_10345;
    logic _e_10347;
    (* src = "src/regfile.spade:97,29" *)
    logic[3:0] __n1;
    (* src = "src/regfile.spade:81,25" *)
    logic[31:0] \rd1 ;
    (* src = "src/regfile.spade:100,5" *)
    logic[575:0] _e_7463;
    localparam[31:0] _e_7252 = 32'd0;
    localparam[3:0] _e_7254 = 0;
    (* src = "src/regfile.spade:43,43" *)
    \tta::regfile::write_mux  write_mux_0(.my_idx_i(_e_7254), .cur_i(\r0 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7253));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r0  <= _e_7252;
        end
        else begin
            \r0  <= _e_7253;
        end
    end
    localparam[31:0] _e_7261 = 32'd0;
    localparam[3:0] _e_7263 = 1;
    (* src = "src/regfile.spade:44,43" *)
    \tta::regfile::write_mux  write_mux_1(.my_idx_i(_e_7263), .cur_i(\r1 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7262));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r1  <= _e_7261;
        end
        else begin
            \r1  <= _e_7262;
        end
    end
    localparam[31:0] _e_7270 = 32'd0;
    localparam[3:0] _e_7272 = 2;
    (* src = "src/regfile.spade:45,43" *)
    \tta::regfile::write_mux  write_mux_2(.my_idx_i(_e_7272), .cur_i(\r2 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7271));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r2  <= _e_7270;
        end
        else begin
            \r2  <= _e_7271;
        end
    end
    localparam[31:0] _e_7279 = 32'd0;
    localparam[3:0] _e_7281 = 3;
    (* src = "src/regfile.spade:46,43" *)
    \tta::regfile::write_mux  write_mux_3(.my_idx_i(_e_7281), .cur_i(\r3 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7280));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r3  <= _e_7279;
        end
        else begin
            \r3  <= _e_7280;
        end
    end
    localparam[31:0] _e_7288 = 32'd0;
    localparam[3:0] _e_7290 = 4;
    (* src = "src/regfile.spade:47,43" *)
    \tta::regfile::write_mux  write_mux_4(.my_idx_i(_e_7290), .cur_i(\r4 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7289));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r4  <= _e_7288;
        end
        else begin
            \r4  <= _e_7289;
        end
    end
    localparam[31:0] _e_7297 = 32'd0;
    localparam[3:0] _e_7299 = 5;
    (* src = "src/regfile.spade:48,43" *)
    \tta::regfile::write_mux  write_mux_5(.my_idx_i(_e_7299), .cur_i(\r5 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7298));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r5  <= _e_7297;
        end
        else begin
            \r5  <= _e_7298;
        end
    end
    localparam[31:0] _e_7306 = 32'd0;
    localparam[3:0] _e_7308 = 6;
    (* src = "src/regfile.spade:49,43" *)
    \tta::regfile::write_mux  write_mux_6(.my_idx_i(_e_7308), .cur_i(\r6 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7307));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r6  <= _e_7306;
        end
        else begin
            \r6  <= _e_7307;
        end
    end
    localparam[31:0] _e_7315 = 32'd0;
    localparam[3:0] _e_7317 = 7;
    (* src = "src/regfile.spade:50,43" *)
    \tta::regfile::write_mux  write_mux_7(.my_idx_i(_e_7317), .cur_i(\r7 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7316));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r7  <= _e_7315;
        end
        else begin
            \r7  <= _e_7316;
        end
    end
    localparam[31:0] _e_7324 = 32'd0;
    localparam[3:0] _e_7326 = 8;
    (* src = "src/regfile.spade:52,43" *)
    \tta::regfile::write_mux  write_mux_8(.my_idx_i(_e_7326), .cur_i(\r8 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7325));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r8  <= _e_7324;
        end
        else begin
            \r8  <= _e_7325;
        end
    end
    localparam[31:0] _e_7333 = 32'd0;
    localparam[3:0] _e_7335 = 9;
    (* src = "src/regfile.spade:53,43" *)
    \tta::regfile::write_mux  write_mux_9(.my_idx_i(_e_7335), .cur_i(\r9 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7334));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r9  <= _e_7333;
        end
        else begin
            \r9  <= _e_7334;
        end
    end
    localparam[31:0] _e_7342 = 32'd0;
    localparam[3:0] _e_7344 = 10;
    (* src = "src/regfile.spade:54,44" *)
    \tta::regfile::write_mux  write_mux_10(.my_idx_i(_e_7344), .cur_i(\r10 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7343));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r10  <= _e_7342;
        end
        else begin
            \r10  <= _e_7343;
        end
    end
    localparam[31:0] _e_7351 = 32'd0;
    localparam[3:0] _e_7353 = 11;
    (* src = "src/regfile.spade:55,44" *)
    \tta::regfile::write_mux  write_mux_11(.my_idx_i(_e_7353), .cur_i(\r11 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7352));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r11  <= _e_7351;
        end
        else begin
            \r11  <= _e_7352;
        end
    end
    localparam[31:0] _e_7360 = 32'd0;
    localparam[3:0] _e_7362 = 12;
    (* src = "src/regfile.spade:56,44" *)
    \tta::regfile::write_mux  write_mux_12(.my_idx_i(_e_7362), .cur_i(\r12 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7361));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r12  <= _e_7360;
        end
        else begin
            \r12  <= _e_7361;
        end
    end
    localparam[31:0] _e_7369 = 32'd0;
    localparam[3:0] _e_7371 = 13;
    (* src = "src/regfile.spade:57,44" *)
    \tta::regfile::write_mux  write_mux_13(.my_idx_i(_e_7371), .cur_i(\r13 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7370));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r13  <= _e_7369;
        end
        else begin
            \r13  <= _e_7370;
        end
    end
    localparam[31:0] _e_7378 = 32'd0;
    localparam[3:0] _e_7380 = 14;
    (* src = "src/regfile.spade:58,44" *)
    \tta::regfile::write_mux  write_mux_14(.my_idx_i(_e_7380), .cur_i(\r14 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7379));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r14  <= _e_7378;
        end
        else begin
            \r14  <= _e_7379;
        end
    end
    localparam[31:0] _e_7387 = 32'd0;
    localparam[3:0] _e_7389 = 15;
    (* src = "src/regfile.spade:59,44" *)
    \tta::regfile::write_mux  write_mux_15(.my_idx_i(_e_7389), .cur_i(\r15 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7388));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r15  <= _e_7387;
        end
        else begin
            \r15  <= _e_7388;
        end
    end
    localparam[3:0] _e_10289 = 0;
    assign _e_10288 = \ra0  == _e_10289;
    localparam[3:0] _e_10291 = 1;
    assign _e_10290 = \ra0  == _e_10291;
    localparam[3:0] _e_10293 = 2;
    assign _e_10292 = \ra0  == _e_10293;
    localparam[3:0] _e_10295 = 3;
    assign _e_10294 = \ra0  == _e_10295;
    localparam[3:0] _e_10297 = 4;
    assign _e_10296 = \ra0  == _e_10297;
    localparam[3:0] _e_10299 = 5;
    assign _e_10298 = \ra0  == _e_10299;
    localparam[3:0] _e_10301 = 6;
    assign _e_10300 = \ra0  == _e_10301;
    localparam[3:0] _e_10303 = 7;
    assign _e_10302 = \ra0  == _e_10303;
    localparam[3:0] _e_10305 = 8;
    assign _e_10304 = \ra0  == _e_10305;
    localparam[3:0] _e_10307 = 9;
    assign _e_10306 = \ra0  == _e_10307;
    localparam[3:0] _e_10309 = 10;
    assign _e_10308 = \ra0  == _e_10309;
    localparam[3:0] _e_10311 = 11;
    assign _e_10310 = \ra0  == _e_10311;
    localparam[3:0] _e_10313 = 12;
    assign _e_10312 = \ra0  == _e_10313;
    localparam[3:0] _e_10315 = 13;
    assign _e_10314 = \ra0  == _e_10315;
    localparam[3:0] _e_10317 = 14;
    assign _e_10316 = \ra0  == _e_10317;
    assign \_  = \ra0 ;
    localparam[0:0] _e_10318 = 1;
    always_comb begin
        priority casez ({_e_10288, _e_10290, _e_10292, _e_10294, _e_10296, _e_10298, _e_10300, _e_10302, _e_10304, _e_10306, _e_10308, _e_10310, _e_10312, _e_10314, _e_10316, _e_10318})
            16'b1???????????????: \rd0  = \r0 ;
            16'b01??????????????: \rd0  = \r1 ;
            16'b001?????????????: \rd0  = \r2 ;
            16'b0001????????????: \rd0  = \r3 ;
            16'b00001???????????: \rd0  = \r4 ;
            16'b000001??????????: \rd0  = \r5 ;
            16'b0000001?????????: \rd0  = \r6 ;
            16'b00000001????????: \rd0  = \r7 ;
            16'b000000001???????: \rd0  = \r8 ;
            16'b0000000001??????: \rd0  = \r9 ;
            16'b00000000001?????: \rd0  = \r10 ;
            16'b000000000001????: \rd0  = \r11 ;
            16'b0000000000001???: \rd0  = \r12 ;
            16'b00000000000001??: \rd0  = \r13 ;
            16'b000000000000001?: \rd0  = \r14 ;
            16'b0000000000000001: \rd0  = \r15 ;
            16'b?: \rd0  = 32'dx;
        endcase
    end
    localparam[3:0] _e_10320 = 0;
    assign _e_10319 = \ra1  == _e_10320;
    localparam[3:0] _e_10322 = 1;
    assign _e_10321 = \ra1  == _e_10322;
    localparam[3:0] _e_10324 = 2;
    assign _e_10323 = \ra1  == _e_10324;
    localparam[3:0] _e_10326 = 3;
    assign _e_10325 = \ra1  == _e_10326;
    localparam[3:0] _e_10328 = 4;
    assign _e_10327 = \ra1  == _e_10328;
    localparam[3:0] _e_10330 = 5;
    assign _e_10329 = \ra1  == _e_10330;
    localparam[3:0] _e_10332 = 6;
    assign _e_10331 = \ra1  == _e_10332;
    localparam[3:0] _e_10334 = 7;
    assign _e_10333 = \ra1  == _e_10334;
    localparam[3:0] _e_10336 = 8;
    assign _e_10335 = \ra1  == _e_10336;
    localparam[3:0] _e_10338 = 9;
    assign _e_10337 = \ra1  == _e_10338;
    localparam[3:0] _e_10340 = 10;
    assign _e_10339 = \ra1  == _e_10340;
    localparam[3:0] _e_10342 = 11;
    assign _e_10341 = \ra1  == _e_10342;
    localparam[3:0] _e_10344 = 12;
    assign _e_10343 = \ra1  == _e_10344;
    localparam[3:0] _e_10346 = 13;
    assign _e_10345 = \ra1  == _e_10346;
    localparam[3:0] _e_10348 = 14;
    assign _e_10347 = \ra1  == _e_10348;
    assign __n1 = \ra1 ;
    localparam[0:0] _e_10349 = 1;
    always_comb begin
        priority casez ({_e_10319, _e_10321, _e_10323, _e_10325, _e_10327, _e_10329, _e_10331, _e_10333, _e_10335, _e_10337, _e_10339, _e_10341, _e_10343, _e_10345, _e_10347, _e_10349})
            16'b1???????????????: \rd1  = \r0 ;
            16'b01??????????????: \rd1  = \r1 ;
            16'b001?????????????: \rd1  = \r2 ;
            16'b0001????????????: \rd1  = \r3 ;
            16'b00001???????????: \rd1  = \r4 ;
            16'b000001??????????: \rd1  = \r5 ;
            16'b0000001?????????: \rd1  = \r6 ;
            16'b00000001????????: \rd1  = \r7 ;
            16'b000000001???????: \rd1  = \r8 ;
            16'b0000000001??????: \rd1  = \r9 ;
            16'b00000000001?????: \rd1  = \r10 ;
            16'b000000000001????: \rd1  = \r11 ;
            16'b0000000000001???: \rd1  = \r12 ;
            16'b00000000000001??: \rd1  = \r13 ;
            16'b000000000000001?: \rd1  = \r14 ;
            16'b0000000000000001: \rd1  = \r15 ;
            16'b?: \rd1  = 32'dx;
        endcase
    end
    assign _e_7463 = {\rd0 , \rd1 , \r0 , \r1 , \r2 , \r3 , \r4 , \r5 , \r6 , \r7 , \r8 , \r9 , \r10 , \r11 , \r12 , \r13 , \r14 , \r15 };
    assign output__ = _e_7463;
endmodule

module \tta::regfile::route_rf_one  (
        input[43:0] m_i,
        output[36:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::regfile::route_rf_one" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::regfile::route_rf_one );
        end
    end
    `endif
    logic[43:0] \m ;
    assign \m  = m_i;
    (* src = "src/regfile.spade:106,9" *)
    logic[42:0] _e_7487;
    (* src = "src/regfile.spade:106,14" *)
    logic[3:0] \i ;
    (* src = "src/regfile.spade:106,14" *)
    logic[31:0] \x ;
    logic _e_10351;
    logic _e_10353;
    logic _e_10356;
    logic _e_10357;
    logic _e_10358;
    (* src = "src/regfile.spade:106,43" *)
    logic[35:0] _e_7490;
    (* src = "src/regfile.spade:106,38" *)
    logic[36:0] _e_7489;
    (* src = "src/regfile.spade:107,9" *)
    logic[43:0] \_ ;
    (* src = "src/regfile.spade:107,14" *)
    logic[36:0] _e_7494;
    (* src = "src/regfile.spade:105,5" *)
    logic[36:0] _e_7483;
    assign _e_7487 = \m [42:0];
    assign \i  = _e_7487[36:33];
    assign \x  = _e_7487[32:1];
    assign _e_10351 = \m [43] == 1'd1;
    assign _e_10353 = _e_7487[42:37] == 6'd0;
    localparam[0:0] _e_10354 = 1;
    localparam[0:0] _e_10355 = 1;
    assign _e_10356 = _e_10353 && _e_10354;
    assign _e_10357 = _e_10356 && _e_10355;
    assign _e_10358 = _e_10351 && _e_10357;
    assign _e_7490 = {\i , \x };
    assign _e_7489 = {1'd1, _e_7490};
    assign \_  = \m ;
    localparam[0:0] _e_10359 = 1;
    assign _e_7494 = {1'd0, 36'bX};
    always_comb begin
        priority casez ({_e_10358, _e_10359})
            2'b1?: _e_7483 = _e_7489;
            2'b01: _e_7483 = _e_7494;
            2'b?: _e_7483 = 37'dx;
        endcase
    end
    assign output__ = _e_7483;
endmodule

module \tta::regfile::write_mux  (
        input[3:0] my_idx_i,
        input[31:0] cur_i,
        input[36:0] w0_i,
        input[36:0] w1_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::regfile::write_mux" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::regfile::write_mux );
        end
    end
    `endif
    logic[3:0] \my_idx ;
    assign \my_idx  = my_idx_i;
    logic[31:0] \cur ;
    assign \cur  = cur_i;
    logic[36:0] \w0 ;
    assign \w0  = w0_i;
    logic[36:0] \w1 ;
    assign \w1  = w1_i;
    (* src = "src/regfile.spade:117,9" *)
    logic[35:0] _e_7500;
    (* src = "src/regfile.spade:117,14" *)
    logic[3:0] \idx ;
    (* src = "src/regfile.spade:117,14" *)
    logic[31:0] \v ;
    logic _e_10361;
    logic _e_10365;
    logic _e_10366;
    (* src = "src/regfile.spade:117,30" *)
    logic _e_7503;
    (* src = "src/regfile.spade:119,17" *)
    logic[35:0] _e_7513;
    (* src = "src/regfile.spade:119,22" *)
    logic[3:0] \idx0 ;
    (* src = "src/regfile.spade:119,22" *)
    logic[31:0] \v0 ;
    logic _e_10368;
    logic _e_10372;
    logic _e_10373;
    (* src = "src/regfile.spade:119,40" *)
    logic _e_7516;
    (* src = "src/regfile.spade:119,37" *)
    logic[31:0] _e_7515;
    logic _e_10375;
    (* src = "src/regfile.spade:118,13" *)
    logic[31:0] _e_7509;
    (* src = "src/regfile.spade:117,27" *)
    logic[31:0] _e_7502;
    logic _e_10377;
    (* src = "src/regfile.spade:124,13" *)
    logic[35:0] _e_7530;
    (* src = "src/regfile.spade:124,18" *)
    logic[3:0] idx0_n1;
    (* src = "src/regfile.spade:124,18" *)
    logic[31:0] v0_n1;
    logic _e_10379;
    logic _e_10383;
    logic _e_10384;
    (* src = "src/regfile.spade:124,36" *)
    logic _e_7533;
    (* src = "src/regfile.spade:124,33" *)
    logic[31:0] _e_7532;
    logic _e_10386;
    (* src = "src/regfile.spade:123,17" *)
    logic[31:0] _e_7526;
    (* src = "src/regfile.spade:116,5" *)
    logic[31:0] _e_7496;
    assign _e_7500 = \w1 [35:0];
    assign \idx  = _e_7500[35:32];
    assign \v  = _e_7500[31:0];
    assign _e_10361 = \w1 [36] == 1'd1;
    localparam[0:0] _e_10363 = 1;
    localparam[0:0] _e_10364 = 1;
    assign _e_10365 = _e_10363 && _e_10364;
    assign _e_10366 = _e_10361 && _e_10365;
    assign _e_7503 = \idx  == \my_idx ;
    assign _e_7513 = \w0 [35:0];
    assign \idx0  = _e_7513[35:32];
    assign \v0  = _e_7513[31:0];
    assign _e_10368 = \w0 [36] == 1'd1;
    localparam[0:0] _e_10370 = 1;
    localparam[0:0] _e_10371 = 1;
    assign _e_10372 = _e_10370 && _e_10371;
    assign _e_10373 = _e_10368 && _e_10372;
    assign _e_7516 = \idx0  == \my_idx ;
    assign _e_7515 = _e_7516 ? \v0  : \cur ;
    assign _e_10375 = \w0 [36] == 1'd0;
    always_comb begin
        priority casez ({_e_10373, _e_10375})
            2'b1?: _e_7509 = _e_7515;
            2'b01: _e_7509 = \cur ;
            2'b?: _e_7509 = 32'dx;
        endcase
    end
    assign _e_7502 = _e_7503 ? \v  : _e_7509;
    assign _e_10377 = \w1 [36] == 1'd0;
    assign _e_7530 = \w0 [35:0];
    assign idx0_n1 = _e_7530[35:32];
    assign v0_n1 = _e_7530[31:0];
    assign _e_10379 = \w0 [36] == 1'd1;
    localparam[0:0] _e_10381 = 1;
    localparam[0:0] _e_10382 = 1;
    assign _e_10383 = _e_10381 && _e_10382;
    assign _e_10384 = _e_10379 && _e_10383;
    assign _e_7533 = idx0_n1 == \my_idx ;
    assign _e_7532 = _e_7533 ? v0_n1 : \cur ;
    assign _e_10386 = \w0 [36] == 1'd0;
    always_comb begin
        priority casez ({_e_10384, _e_10386})
            2'b1?: _e_7526 = _e_7532;
            2'b01: _e_7526 = \cur ;
            2'b?: _e_7526 = 32'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10366, _e_10377})
            2'b1?: _e_7496 = _e_7502;
            2'b01: _e_7496 = _e_7526;
            2'b?: _e_7496 = 32'dx;
        endcase
    end
    assign output__ = _e_7496;
endmodule

module \tta::xorshift::next_xorshift32  (
        input[31:0] x_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::xorshift::next_xorshift32" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::xorshift::next_xorshift32 );
        end
    end
    `endif
    logic[31:0] \x ;
    assign \x  = x_i;
    (* src = "src/xorshift.spade:17,24" *)
    logic[31:0] _e_7546;
    (* src = "src/xorshift.spade:17,18" *)
    logic[31:0] _e_7545;
    (* src = "src/xorshift.spade:17,14" *)
    logic[31:0] \x1 ;
    (* src = "src/xorshift.spade:18,19" *)
    logic[31:0] _e_7552;
    (* src = "src/xorshift.spade:18,14" *)
    logic[31:0] \x2 ;
    (* src = "src/xorshift.spade:19,25" *)
    logic[31:0] _e_7559;
    (* src = "src/xorshift.spade:19,19" *)
    logic[31:0] _e_7558;
    (* src = "src/xorshift.spade:19,14" *)
    logic[31:0] \x3 ;
    localparam[31:0] _e_7548 = 32'd13;
    assign _e_7546 = \x  << _e_7548;
    assign _e_7545 = _e_7546[31:0];
    assign \x1  = \x  ^ _e_7545;
    localparam[31:0] _e_7554 = 32'd17;
    assign _e_7552 = \x1  >> _e_7554;
    assign \x2  = \x1  ^ _e_7552;
    localparam[31:0] _e_7561 = 32'd5;
    assign _e_7559 = \x2  << _e_7561;
    assign _e_7558 = _e_7559[31:0];
    assign \x3  = \x2  ^ _e_7558;
    assign output__ = \x3 ;
endmodule

module \tta::xorshift::xorshift_fu  (
        input clk_i,
        input rst_i,
        input[32:0] trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::xorshift::xorshift_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::xorshift::xorshift_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \trig ;
    assign \trig  = trig_i;
    (* src = "src/xorshift.spade:32,13" *)
    logic[31:0] \v ;
    logic _e_10388;
    logic _e_10390;
    (* src = "src/xorshift.spade:32,27" *)
    logic _e_7575;
    (* src = "src/xorshift.spade:32,24" *)
    logic[31:0] _e_7574;
    logic _e_10392;
    (* src = "src/xorshift.spade:31,20" *)
    logic[31:0] \base ;
    (* src = "src/xorshift.spade:37,9" *)
    logic[31:0] _e_7585;
    (* src = "src/xorshift.spade:29,14" *)
    reg[31:0] \state ;
    (* src = "src/xorshift.spade:42,47" *)
    logic[32:0] _e_7590;
    (* src = "src/xorshift.spade:44,13" *)
    logic[31:0] v_n1;
    logic _e_10394;
    logic _e_10396;
    (* src = "src/xorshift.spade:44,27" *)
    logic _e_7597;
    (* src = "src/xorshift.spade:44,24" *)
    logic[31:0] _e_7596;
    logic _e_10398;
    (* src = "src/xorshift.spade:43,20" *)
    logic[31:0] base_n1;
    (* src = "src/xorshift.spade:47,14" *)
    logic[31:0] _e_7608;
    (* src = "src/xorshift.spade:47,9" *)
    logic[32:0] _e_7607;
    (* src = "src/xorshift.spade:42,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_7568 = 32'd1;
    assign \v  = \trig [31:0];
    assign _e_10388 = \trig [32] == 1'd1;
    localparam[0:0] _e_10389 = 1;
    assign _e_10390 = _e_10388 && _e_10389;
    localparam[31:0] _e_7577 = 32'd0;
    assign _e_7575 = \v  == _e_7577;
    assign _e_7574 = _e_7575 ? \state  : \v ;
    assign _e_10392 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_10390, _e_10392})
            2'b1?: \base  = _e_7574;
            2'b01: \base  = \state ;
            2'b?: \base  = 32'dx;
        endcase
    end
    (* src = "src/xorshift.spade:37,9" *)
    \tta::xorshift::next_xorshift32  next_xorshift32_0(.x_i(\base ), .output__(_e_7585));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \state  <= _e_7568;
        end
        else begin
            \state  <= _e_7585;
        end
    end
    assign _e_7590 = {1'd0, 32'bX};
    assign v_n1 = \trig [31:0];
    assign _e_10394 = \trig [32] == 1'd1;
    localparam[0:0] _e_10395 = 1;
    assign _e_10396 = _e_10394 && _e_10395;
    localparam[31:0] _e_7599 = 32'd0;
    assign _e_7597 = v_n1 == _e_7599;
    assign _e_7596 = _e_7597 ? \state  : v_n1;
    assign _e_10398 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_10396, _e_10398})
            2'b1?: base_n1 = _e_7596;
            2'b01: base_n1 = \state ;
            2'b?: base_n1 = 32'dx;
        endcase
    end
    (* src = "src/xorshift.spade:47,14" *)
    \tta::xorshift::next_xorshift32  next_xorshift32_1(.x_i(base_n1), .output__(_e_7608));
    assign _e_7607 = {1'd1, _e_7608};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_7590;
        end
        else begin
            \res  <= _e_7607;
        end
    end
    assign output__ = \res ;
endmodule

module \tta::xorshift::pick_xorshift_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::xorshift::pick_xorshift_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::xorshift::pick_xorshift_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/xorshift.spade:57,9" *)
    logic[42:0] _e_7615;
    (* src = "src/xorshift.spade:57,14" *)
    logic[31:0] \x ;
    logic _e_10400;
    logic _e_10402;
    logic _e_10404;
    logic _e_10405;
    (* src = "src/xorshift.spade:57,40" *)
    logic[32:0] _e_7617;
    (* src = "src/xorshift.spade:58,9" *)
    logic[43:0] \_ ;
    (* src = "src/xorshift.spade:59,13" *)
    logic[42:0] _e_7623;
    (* src = "src/xorshift.spade:59,18" *)
    logic[31:0] x_n1;
    logic _e_10408;
    logic _e_10410;
    logic _e_10412;
    logic _e_10413;
    (* src = "src/xorshift.spade:59,44" *)
    logic[32:0] _e_7625;
    (* src = "src/xorshift.spade:60,13" *)
    logic[43:0] __n1;
    (* src = "src/xorshift.spade:60,18" *)
    logic[32:0] _e_7628;
    (* src = "src/xorshift.spade:58,14" *)
    logic[32:0] _e_7620;
    (* src = "src/xorshift.spade:56,5" *)
    logic[32:0] _e_7612;
    assign _e_7615 = \m1 [42:0];
    assign \x  = _e_7615[36:5];
    assign _e_10400 = \m1 [43] == 1'd1;
    assign _e_10402 = _e_7615[42:37] == 6'd23;
    localparam[0:0] _e_10403 = 1;
    assign _e_10404 = _e_10402 && _e_10403;
    assign _e_10405 = _e_10400 && _e_10404;
    assign _e_7617 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10406 = 1;
    assign _e_7623 = \m0 [42:0];
    assign x_n1 = _e_7623[36:5];
    assign _e_10408 = \m0 [43] == 1'd1;
    assign _e_10410 = _e_7623[42:37] == 6'd23;
    localparam[0:0] _e_10411 = 1;
    assign _e_10412 = _e_10410 && _e_10411;
    assign _e_10413 = _e_10408 && _e_10412;
    assign _e_7625 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10414 = 1;
    assign _e_7628 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10413, _e_10414})
            2'b1?: _e_7620 = _e_7625;
            2'b01: _e_7620 = _e_7628;
            2'b?: _e_7620 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10405, _e_10406})
            2'b1?: _e_7612 = _e_7617;
            2'b01: _e_7612 = _e_7620;
            2'b?: _e_7612 = 33'dx;
        endcase
    end
    assign output__ = _e_7612;
endmodule

module \tta::bt::bt_fu  (
        input clk_i,
        input rst_i,
        input[10:0] jump_to_i,
        input[32:0] condition_trig_i,
        output[10:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bt::bt_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bt::bt_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[10:0] \jump_to ;
    assign \jump_to  = jump_to_i;
    logic[32:0] \condition_trig ;
    assign \condition_trig  = condition_trig_i;
    (* src = "src/bt.spade:13,50" *)
    logic[10:0] _e_7633;
    (* src = "src/bt.spade:14,9" *)
    logic[9:0] \v ;
    logic _e_10416;
    logic _e_10418;
    (* src = "src/bt.spade:14,20" *)
    logic[10:0] _e_7638;
    logic _e_10420;
    (* src = "src/bt.spade:13,58" *)
    logic[10:0] _e_7634;
    (* src = "src/bt.spade:13,14" *)
    reg[10:0] \target ;
    (* src = "src/bt.spade:18,11" *)
    logic[43:0] _e_7643;
    (* src = "src/bt.spade:19,9" *)
    logic[43:0] _e_7650;
    (* src = "src/bt.spade:19,9" *)
    logic[10:0] _e_7647;
    (* src = "src/bt.spade:19,10" *)
    logic[9:0] v_n1;
    (* src = "src/bt.spade:19,9" *)
    logic[32:0] _e_7649;
    (* src = "src/bt.spade:19,19" *)
    logic[31:0] \c ;
    logic _e_10423;
    logic _e_10425;
    logic _e_10427;
    logic _e_10429;
    logic _e_10430;
    (* src = "src/bt.spade:20,16" *)
    logic _e_7653;
    (* src = "src/bt.spade:20,29" *)
    logic[10:0] _e_7656;
    (* src = "src/bt.spade:20,46" *)
    logic[10:0] _e_7659;
    (* src = "src/bt.spade:20,13" *)
    logic[10:0] _e_7652;
    (* src = "src/bt.spade:22,9" *)
    logic[43:0] _e_7662;
    (* src = "src/bt.spade:22,9" *)
    logic[10:0] \_ ;
    (* src = "src/bt.spade:22,9" *)
    logic[32:0] __n1;
    logic _e_10434;
    (* src = "src/bt.spade:22,19" *)
    logic[10:0] _e_7663;
    (* src = "src/bt.spade:18,5" *)
    logic[10:0] _e_7642;
    assign _e_7633 = {1'd0, 10'bX};
    assign \v  = \jump_to [9:0];
    assign _e_10416 = \jump_to [10] == 1'd1;
    localparam[0:0] _e_10417 = 1;
    assign _e_10418 = _e_10416 && _e_10417;
    assign _e_7638 = {1'd1, \v };
    assign _e_10420 = \jump_to [10] == 1'd0;
    always_comb begin
        priority casez ({_e_10418, _e_10420})
            2'b1?: _e_7634 = _e_7638;
            2'b01: _e_7634 = \target ;
            2'b?: _e_7634 = 11'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \target  <= _e_7633;
        end
        else begin
            \target  <= _e_7634;
        end
    end
    assign _e_7643 = {\target , \condition_trig };
    assign _e_7650 = _e_7643;
    assign _e_7647 = _e_7643[43:33];
    assign v_n1 = _e_7647[9:0];
    assign _e_7649 = _e_7643[32:0];
    assign \c  = _e_7649[31:0];
    assign _e_10423 = _e_7647[10] == 1'd1;
    localparam[0:0] _e_10424 = 1;
    assign _e_10425 = _e_10423 && _e_10424;
    assign _e_10427 = _e_7649[32] == 1'd1;
    localparam[0:0] _e_10428 = 1;
    assign _e_10429 = _e_10427 && _e_10428;
    assign _e_10430 = _e_10425 && _e_10429;
    (* src = "src/bt.spade:20,16" *)
    \tta::bt::to_bool  to_bool_0(.x_i(\c ), .output__(_e_7653));
    assign _e_7656 = {1'd1, v_n1};
    assign _e_7659 = {1'd0, 10'bX};
    assign _e_7652 = _e_7653 ? _e_7656 : _e_7659;
    assign _e_7662 = _e_7643;
    assign \_  = _e_7643[43:33];
    assign __n1 = _e_7643[32:0];
    localparam[0:0] _e_10432 = 1;
    localparam[0:0] _e_10433 = 1;
    assign _e_10434 = _e_10432 && _e_10433;
    assign _e_7663 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_10430, _e_10434})
            2'b1?: _e_7642 = _e_7652;
            2'b01: _e_7642 = _e_7663;
            2'b?: _e_7642 = 11'dx;
        endcase
    end
    assign output__ = _e_7642;
endmodule

module \tta::bt::to_bool  (
        input[31:0] x_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bt::to_bool" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bt::to_bool );
        end
    end
    `endif
    logic[31:0] \x ;
    assign \x  = x_i;
    (* src = "src/bt.spade:28,8" *)
    logic _e_7666;
    (* src = "src/bt.spade:28,5" *)
    logic _e_7665;
    localparam[31:0] _e_7668 = 32'd0;
    assign _e_7666 = \x  == _e_7668;
    localparam[0:0] _e_7670 = 0;
    localparam[0:0] _e_7672 = 1;
    assign _e_7665 = _e_7666 ? _e_7670 : _e_7672;
    assign output__ = _e_7665;
endmodule

module \tta::bt::pick_bt_target  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[10:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bt::pick_bt_target" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bt::pick_bt_target );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/bt.spade:39,9" *)
    logic[42:0] _e_7677;
    (* src = "src/bt.spade:39,14" *)
    logic[9:0] \a ;
    logic _e_10436;
    logic _e_10438;
    logic _e_10440;
    logic _e_10441;
    (* src = "src/bt.spade:39,36" *)
    logic[10:0] _e_7679;
    (* src = "src/bt.spade:40,9" *)
    logic[43:0] \_ ;
    (* src = "src/bt.spade:40,25" *)
    logic[42:0] _e_7685;
    (* src = "src/bt.spade:40,30" *)
    logic[9:0] a_n1;
    logic _e_10444;
    logic _e_10446;
    logic _e_10448;
    logic _e_10449;
    (* src = "src/bt.spade:40,52" *)
    logic[10:0] _e_7687;
    (* src = "src/bt.spade:40,61" *)
    logic[43:0] __n1;
    (* src = "src/bt.spade:40,66" *)
    logic[10:0] _e_7690;
    (* src = "src/bt.spade:40,14" *)
    logic[10:0] _e_7682;
    (* src = "src/bt.spade:38,5" *)
    logic[10:0] _e_7674;
    assign _e_7677 = \m1 [42:0];
    assign \a  = _e_7677[36:27];
    assign _e_10436 = \m1 [43] == 1'd1;
    assign _e_10438 = _e_7677[42:37] == 6'd18;
    localparam[0:0] _e_10439 = 1;
    assign _e_10440 = _e_10438 && _e_10439;
    assign _e_10441 = _e_10436 && _e_10440;
    assign _e_7679 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_10442 = 1;
    assign _e_7685 = \m0 [42:0];
    assign a_n1 = _e_7685[36:27];
    assign _e_10444 = \m0 [43] == 1'd1;
    assign _e_10446 = _e_7685[42:37] == 6'd18;
    localparam[0:0] _e_10447 = 1;
    assign _e_10448 = _e_10446 && _e_10447;
    assign _e_10449 = _e_10444 && _e_10448;
    assign _e_7687 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10450 = 1;
    assign _e_7690 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_10449, _e_10450})
            2'b1?: _e_7682 = _e_7687;
            2'b01: _e_7682 = _e_7690;
            2'b?: _e_7682 = 11'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10441, _e_10442})
            2'b1?: _e_7674 = _e_7679;
            2'b01: _e_7674 = _e_7682;
            2'b?: _e_7674 = 11'dx;
        endcase
    end
    assign output__ = _e_7674;
endmodule

module \tta::bt::pick_bt_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::bt::pick_bt_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::bt::pick_bt_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/bt.spade:46,9" *)
    logic[42:0] _e_7695;
    (* src = "src/bt.spade:46,14" *)
    logic[31:0] \a ;
    logic _e_10452;
    logic _e_10454;
    logic _e_10456;
    logic _e_10457;
    (* src = "src/bt.spade:46,34" *)
    logic[32:0] _e_7697;
    (* src = "src/bt.spade:47,9" *)
    logic[43:0] \_ ;
    (* src = "src/bt.spade:47,25" *)
    logic[42:0] _e_7703;
    (* src = "src/bt.spade:47,30" *)
    logic[31:0] a_n1;
    logic _e_10460;
    logic _e_10462;
    logic _e_10464;
    logic _e_10465;
    (* src = "src/bt.spade:47,50" *)
    logic[32:0] _e_7705;
    (* src = "src/bt.spade:47,59" *)
    logic[43:0] __n1;
    (* src = "src/bt.spade:47,64" *)
    logic[32:0] _e_7708;
    (* src = "src/bt.spade:47,14" *)
    logic[32:0] _e_7700;
    (* src = "src/bt.spade:45,5" *)
    logic[32:0] _e_7692;
    assign _e_7695 = \m1 [42:0];
    assign \a  = _e_7695[36:5];
    assign _e_10452 = \m1 [43] == 1'd1;
    assign _e_10454 = _e_7695[42:37] == 6'd19;
    localparam[0:0] _e_10455 = 1;
    assign _e_10456 = _e_10454 && _e_10455;
    assign _e_10457 = _e_10452 && _e_10456;
    assign _e_7697 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_10458 = 1;
    assign _e_7703 = \m0 [42:0];
    assign a_n1 = _e_7703[36:5];
    assign _e_10460 = \m0 [43] == 1'd1;
    assign _e_10462 = _e_7703[42:37] == 6'd19;
    localparam[0:0] _e_10463 = 1;
    assign _e_10464 = _e_10462 && _e_10463;
    assign _e_10465 = _e_10460 && _e_10464;
    assign _e_7705 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10466 = 1;
    assign _e_7708 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10465, _e_10466})
            2'b1?: _e_7700 = _e_7705;
            2'b01: _e_7700 = _e_7708;
            2'b?: _e_7700 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10457, _e_10458})
            2'b1?: _e_7692 = _e_7697;
            2'b01: _e_7692 = _e_7700;
            2'b?: _e_7692 = 33'dx;
        endcase
    end
    assign output__ = _e_7692;
endmodule

module \tta::stack_lsu::stack_lsu_fu  (
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
`endif
        input clk_i,
        input rst_i,
        input[32:0] set_sp_i,
        input pop_trig_i,
        input[32:0] push_trig_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::stack_lsu::stack_lsu_fu" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::stack_lsu::stack_lsu_fu );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \rst ;
    assign \rst  = rst_i;
    logic[32:0] \set_sp ;
    assign \set_sp  = set_sp_i;
    logic \pop_trig ;
    assign \pop_trig  = pop_trig_i;
    logic[32:0] \push_trig ;
    assign \push_trig  = push_trig_i;
    (* src = "src/stack_lsu.spade:24,13" *)
    logic[31:0] \val ;
    logic _e_10468;
    logic _e_10470;
    logic _e_10472;
    (* src = "src/stack_lsu.spade:26,38" *)
    logic[31:0] \_ ;
    logic _e_10474;
    logic _e_10476;
    logic _e_10478;
    (* src = "src/stack_lsu.spade:26,20" *)
    logic _e_7723;
    (* src = "src/stack_lsu.spade:27,27" *)
    logic[32:0] _e_7732;
    (* src = "src/stack_lsu.spade:27,21" *)
    logic[31:0] _e_7731;
    (* src = "src/stack_lsu.spade:29,27" *)
    logic[32:0] _e_7739;
    (* src = "src/stack_lsu.spade:29,21" *)
    logic[31:0] _e_7738;
    (* src = "src/stack_lsu.spade:28,24" *)
    logic[31:0] _e_7735;
    (* src = "src/stack_lsu.spade:26,17" *)
    logic[31:0] _e_7722;
    (* src = "src/stack_lsu.spade:23,9" *)
    logic[31:0] _e_7715;
    (* src = "src/stack_lsu.spade:22,14" *)
    reg[31:0] \sp ;
    (* src = "src/stack_lsu.spade:38,9" *)
    logic[31:0] val_n1;
    logic _e_10480;
    logic _e_10482;
    (* src = "src/stack_lsu.spade:39,43" *)
    logic[32:0] _e_7750;
    (* src = "src/stack_lsu.spade:39,37" *)
    logic[7:0] \trunc_sp ;
    (* src = "src/stack_lsu.spade:40,13" *)
    logic[40:0] _e_7754;
    logic _e_10484;
    (* src = "src/stack_lsu.spade:44,43" *)
    logic[32:0] _e_7761;
    (* src = "src/stack_lsu.spade:44,37" *)
    logic[7:0] trunc_sp_n1;
    (* src = "src/stack_lsu.spade:45,13" *)
    logic[40:0] _e_7765;
    (* src = "src/stack_lsu.spade:37,31" *)
    logic[40:0] _e_7772;
    (* src = "src/stack_lsu.spade:37,9" *)
    logic[7:0] \addr ;
    (* src = "src/stack_lsu.spade:37,9" *)
    logic \wren ;
    (* src = "src/stack_lsu.spade:37,9" *)
    logic[31:0] \wdata ;
    (* src = "src/stack_lsu.spade:49,17" *)
    logic[31:0] \rdata ;
    (* src = "src/stack_lsu.spade:52,9" *)
    logic[31:0] __n1;
    logic _e_10486;
    logic _e_10488;
    logic _e_10490;
    (* src = "src/stack_lsu.spade:51,62" *)
    logic _e_7786;
    (* src = "src/stack_lsu.spade:51,50" *)
    logic _e_7784;
    (* src = "src/stack_lsu.spade:51,14" *)
    reg \pop_valid ;
    (* src = "src/stack_lsu.spade:56,20" *)
    logic[32:0] _e_7796;
    (* src = "src/stack_lsu.spade:56,41" *)
    logic[32:0] _e_7799;
    (* src = "src/stack_lsu.spade:56,5" *)
    logic[32:0] _e_7793;
    localparam[31:0] _e_7713 = 32'd0;
    assign \val  = \set_sp [31:0];
    assign _e_10468 = \set_sp [32] == 1'd1;
    localparam[0:0] _e_10469 = 1;
    assign _e_10470 = _e_10468 && _e_10469;
    assign _e_10472 = \set_sp [32] == 1'd0;
    assign \_  = \push_trig [31:0];
    assign _e_10474 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10475 = 1;
    assign _e_10476 = _e_10474 && _e_10475;
    localparam[0:0] _e_7727 = 1;
    assign _e_10478 = \push_trig [32] == 1'd0;
    localparam[0:0] _e_7729 = 0;
    always_comb begin
        priority casez ({_e_10476, _e_10478})
            2'b1?: _e_7723 = _e_7727;
            2'b01: _e_7723 = _e_7729;
            2'b?: _e_7723 = 1'dx;
        endcase
    end
    localparam[31:0] _e_7734 = 32'd1;
    assign _e_7732 = \sp  - _e_7734;
    assign _e_7731 = _e_7732[31:0];
    localparam[31:0] _e_7741 = 32'd1;
    assign _e_7739 = \sp  + _e_7741;
    assign _e_7738 = _e_7739[31:0];
    assign _e_7735 = \pop_trig  ? _e_7738 : \sp ;
    assign _e_7722 = _e_7723 ? _e_7731 : _e_7735;
    always_comb begin
        priority casez ({_e_10470, _e_10472})
            2'b1?: _e_7715 = \val ;
            2'b01: _e_7715 = _e_7722;
            2'b?: _e_7715 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \sp  <= _e_7713;
        end
        else begin
            \sp  <= _e_7715;
        end
    end
    assign val_n1 = \push_trig [31:0];
    assign _e_10480 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10481 = 1;
    assign _e_10482 = _e_10480 && _e_10481;
    localparam[31:0] _e_7752 = 32'd1;
    assign _e_7750 = \sp  - _e_7752;
    assign \trunc_sp  = _e_7750[7:0];
    localparam[0:0] _e_7756 = 1;
    assign _e_7754 = {\trunc_sp , _e_7756, val_n1};
    assign _e_10484 = \push_trig [32] == 1'd0;
    localparam[31:0] _e_7763 = 32'd1;
    assign _e_7761 = \sp  - _e_7763;
    assign trunc_sp_n1 = _e_7761[7:0];
    localparam[0:0] _e_7767 = 0;
    localparam[31:0] _e_7768 = 32'd0;
    assign _e_7765 = {trunc_sp_n1, _e_7767, _e_7768};
    always_comb begin
        priority casez ({_e_10482, _e_10484})
            2'b1?: _e_7772 = _e_7754;
            2'b01: _e_7772 = _e_7765;
            2'b?: _e_7772 = 41'dx;
        endcase
    end
    assign \addr  = _e_7772[40:33];
    assign \wren  = _e_7772[32];
    assign \wdata  = _e_7772[31:0];
    (* src = "src/stack_lsu.spade:49,17" *)
    \tta::sram::stack_ram_256x32  stack_ram_256x32_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .word_idx_i(\addr ), .we_i(\wren ), .wdata_i(\wdata ), .output__(\rdata ));
    localparam[0:0] _e_7783 = 0;
    assign __n1 = \push_trig [31:0];
    assign _e_10486 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10487 = 1;
    assign _e_10488 = _e_10486 && _e_10487;
    localparam[0:0] _e_7790 = 0;
    assign _e_10490 = \push_trig [32] == 1'd0;
    localparam[0:0] _e_7792 = 1;
    always_comb begin
        priority casez ({_e_10488, _e_10490})
            2'b1?: _e_7786 = _e_7790;
            2'b01: _e_7786 = _e_7792;
            2'b?: _e_7786 = 1'dx;
        endcase
    end
    assign _e_7784 = \pop_trig  && _e_7786;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \pop_valid  <= _e_7783;
        end
        else begin
            \pop_valid  <= _e_7784;
        end
    end
    assign _e_7796 = {1'd1, \rdata };
    assign _e_7799 = {1'd0, 32'bX};
    assign _e_7793 = \pop_valid  ? _e_7796 : _e_7799;
    assign output__ = _e_7793;
endmodule

module \tta::stack_lsu::pick_seta  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::stack_lsu::pick_seta" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::stack_lsu::pick_seta );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/stack_lsu.spade:63,9" *)
    logic[42:0] _e_7804;
    (* src = "src/stack_lsu.spade:63,14" *)
    logic[31:0] \x ;
    logic _e_10492;
    logic _e_10494;
    logic _e_10496;
    logic _e_10497;
    (* src = "src/stack_lsu.spade:63,37" *)
    logic[32:0] _e_7806;
    (* src = "src/stack_lsu.spade:64,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:65,13" *)
    logic[42:0] _e_7812;
    (* src = "src/stack_lsu.spade:65,18" *)
    logic[31:0] x_n1;
    logic _e_10500;
    logic _e_10502;
    logic _e_10504;
    logic _e_10505;
    (* src = "src/stack_lsu.spade:65,41" *)
    logic[32:0] _e_7814;
    (* src = "src/stack_lsu.spade:66,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:66,18" *)
    logic[32:0] _e_7817;
    (* src = "src/stack_lsu.spade:64,14" *)
    logic[32:0] _e_7809;
    (* src = "src/stack_lsu.spade:62,5" *)
    logic[32:0] _e_7801;
    assign _e_7804 = \m1 [42:0];
    assign \x  = _e_7804[36:5];
    assign _e_10492 = \m1 [43] == 1'd1;
    assign _e_10494 = _e_7804[42:37] == 6'd35;
    localparam[0:0] _e_10495 = 1;
    assign _e_10496 = _e_10494 && _e_10495;
    assign _e_10497 = _e_10492 && _e_10496;
    assign _e_7806 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10498 = 1;
    assign _e_7812 = \m0 [42:0];
    assign x_n1 = _e_7812[36:5];
    assign _e_10500 = \m0 [43] == 1'd1;
    assign _e_10502 = _e_7812[42:37] == 6'd35;
    localparam[0:0] _e_10503 = 1;
    assign _e_10504 = _e_10502 && _e_10503;
    assign _e_10505 = _e_10500 && _e_10504;
    assign _e_7814 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10506 = 1;
    assign _e_7817 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10505, _e_10506})
            2'b1?: _e_7809 = _e_7814;
            2'b01: _e_7809 = _e_7817;
            2'b?: _e_7809 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10497, _e_10498})
            2'b1?: _e_7801 = _e_7806;
            2'b01: _e_7801 = _e_7809;
            2'b?: _e_7801 = 33'dx;
        endcase
    end
    assign output__ = _e_7801;
endmodule

module \tta::stack_lsu::pick_push_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output[32:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::stack_lsu::pick_push_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::stack_lsu::pick_push_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/stack_lsu.spade:73,9" *)
    logic[42:0] _e_7822;
    (* src = "src/stack_lsu.spade:73,14" *)
    logic[31:0] \x ;
    logic _e_10508;
    logic _e_10510;
    logic _e_10512;
    logic _e_10513;
    (* src = "src/stack_lsu.spade:73,42" *)
    logic[32:0] _e_7824;
    (* src = "src/stack_lsu.spade:74,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:75,13" *)
    logic[42:0] _e_7830;
    (* src = "src/stack_lsu.spade:75,18" *)
    logic[31:0] x_n1;
    logic _e_10516;
    logic _e_10518;
    logic _e_10520;
    logic _e_10521;
    (* src = "src/stack_lsu.spade:75,46" *)
    logic[32:0] _e_7832;
    (* src = "src/stack_lsu.spade:76,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:76,18" *)
    logic[32:0] _e_7835;
    (* src = "src/stack_lsu.spade:74,14" *)
    logic[32:0] _e_7827;
    (* src = "src/stack_lsu.spade:72,5" *)
    logic[32:0] _e_7819;
    assign _e_7822 = \m1 [42:0];
    assign \x  = _e_7822[36:5];
    assign _e_10508 = \m1 [43] == 1'd1;
    assign _e_10510 = _e_7822[42:37] == 6'd36;
    localparam[0:0] _e_10511 = 1;
    assign _e_10512 = _e_10510 && _e_10511;
    assign _e_10513 = _e_10508 && _e_10512;
    assign _e_7824 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10514 = 1;
    assign _e_7830 = \m0 [42:0];
    assign x_n1 = _e_7830[36:5];
    assign _e_10516 = \m0 [43] == 1'd1;
    assign _e_10518 = _e_7830[42:37] == 6'd36;
    localparam[0:0] _e_10519 = 1;
    assign _e_10520 = _e_10518 && _e_10519;
    assign _e_10521 = _e_10516 && _e_10520;
    assign _e_7832 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10522 = 1;
    assign _e_7835 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10521, _e_10522})
            2'b1?: _e_7827 = _e_7832;
            2'b01: _e_7827 = _e_7835;
            2'b?: _e_7827 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10513, _e_10514})
            2'b1?: _e_7819 = _e_7824;
            2'b01: _e_7819 = _e_7827;
            2'b?: _e_7819 = 33'dx;
        endcase
    end
    assign output__ = _e_7819;
endmodule

module \tta::stack_lsu::pick_pop_trig  (
        input[43:0] m0_i,
        input[43:0] m1_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::stack_lsu::pick_pop_trig" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::stack_lsu::pick_pop_trig );
        end
    end
    `endif
    logic[43:0] \m0 ;
    assign \m0  = m0_i;
    logic[43:0] \m1 ;
    assign \m1  = m1_i;
    (* src = "src/stack_lsu.spade:83,9" *)
    logic[42:0] _e_7839;
    logic _e_10524;
    logic _e_10526;
    logic _e_10527;
    (* src = "src/stack_lsu.spade:84,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:85,13" *)
    logic[42:0] _e_7845;
    logic _e_10530;
    logic _e_10532;
    logic _e_10533;
    (* src = "src/stack_lsu.spade:86,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:84,14" *)
    logic _e_7843;
    (* src = "src/stack_lsu.spade:82,5" *)
    logic _e_7837;
    assign _e_7839 = \m1 [42:0];
    assign _e_10524 = \m1 [43] == 1'd1;
    assign _e_10526 = _e_7839[42:37] == 6'd37;
    assign _e_10527 = _e_10524 && _e_10526;
    localparam[0:0] _e_7841 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_10528 = 1;
    assign _e_7845 = \m0 [42:0];
    assign _e_10530 = \m0 [43] == 1'd1;
    assign _e_10532 = _e_7845[42:37] == 6'd37;
    assign _e_10533 = _e_10530 && _e_10532;
    localparam[0:0] _e_7847 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_10534 = 1;
    localparam[0:0] _e_7849 = 0;
    always_comb begin
        priority casez ({_e_10533, _e_10534})
            2'b1?: _e_7843 = _e_7847;
            2'b01: _e_7843 = _e_7849;
            2'b?: _e_7843 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10527, _e_10528})
            2'b1?: _e_7837 = _e_7841;
            2'b01: _e_7837 = _e_7843;
            2'b?: _e_7837 = 1'dx;
        endcase
    end
    assign output__ = _e_7837;
endmodule

module \std::conv::impl_2::to_uint  (
        input self_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_2::to_uint" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_2::to_uint );
        end
    end
    `endif
    logic \self ;
    assign \self  = self_i;
    logic _e_501;
    assign _e_501 = \self ;
    assign output__ = _e_501;
endmodule

module \std::conv::impl_2::to_int  (
        input self_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_2::to_int" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_2::to_int );
        end
    end
    `endif
    logic \self ;
    assign \self  = self_i;
    logic _e_505;
    assign _e_505 = \self ;
    assign output__ = _e_505;
endmodule

module \std::conv::impl_5::to_be_bytes  (
        input[15:0] self_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_5::to_be_bytes" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_5::to_be_bytes );
        end
    end
    `endif
    logic[15:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:184,16" *)
    logic[15:0] _e_522;
    (* src = "<compiler dir>/stdlib/conv.spade:184,10" *)
    logic[7:0] _e_521;
    (* src = "<compiler dir>/stdlib/conv.spade:184,28" *)
    logic[7:0] _e_525;
    (* src = "<compiler dir>/stdlib/conv.spade:184,9" *)
    logic[15:0] _e_520;
    localparam[15:0] _e_524 = 8;
    assign _e_522 = \self  >> _e_524;
    assign _e_521 = _e_522[7:0];
    assign _e_525 = \self [7:0];
    assign _e_520 = {_e_525, _e_521};
    assign output__ = _e_520;
endmodule

module \std::conv::impl_5::to_le_bytes  (
        input[15:0] self_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_5::to_le_bytes" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_5::to_le_bytes );
        end
    end
    `endif
    logic[15:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:190,31" *)
    logic[15:0] _e_529;
    (* src = "<compiler dir>/stdlib/conv.spade:190,9" *)
    logic[15:0] _e_528;
    (* src = "<compiler dir>/stdlib/conv.spade:190,31" *)
    \std::conv::impl_5::to_be_bytes  to_be_bytes_0(.self_i(\self ), .output__(_e_529));
    (* src = "<compiler dir>/stdlib/conv.spade:190,9" *)
    \std::conv::flip_array[2156]  flip_array_0(.in_i(_e_529), .output__(_e_528));
    assign output__ = _e_528;
endmodule

module \std::conv::impl_6::to_be_bytes  (
        input[23:0] self_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_6::to_be_bytes" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_6::to_be_bytes );
        end
    end
    `endif
    logic[23:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:198,16" *)
    logic[23:0] _e_534;
    (* src = "<compiler dir>/stdlib/conv.spade:198,10" *)
    logic[7:0] _e_533;
    (* src = "<compiler dir>/stdlib/conv.spade:198,35" *)
    logic[23:0] _e_538;
    (* src = "<compiler dir>/stdlib/conv.spade:198,29" *)
    logic[7:0] _e_537;
    (* src = "<compiler dir>/stdlib/conv.spade:198,47" *)
    logic[7:0] _e_541;
    (* src = "<compiler dir>/stdlib/conv.spade:198,9" *)
    logic[23:0] _e_532;
    localparam[23:0] _e_536 = 16;
    assign _e_534 = \self  >> _e_536;
    assign _e_533 = _e_534[7:0];
    localparam[23:0] _e_540 = 8;
    assign _e_538 = \self  >> _e_540;
    assign _e_537 = _e_538[7:0];
    assign _e_541 = \self [7:0];
    assign _e_532 = {_e_541, _e_537, _e_533};
    assign output__ = _e_532;
endmodule

module \std::conv::impl_6::to_le_bytes  (
        input[23:0] self_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_6::to_le_bytes" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_6::to_le_bytes );
        end
    end
    `endif
    logic[23:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:204,31" *)
    logic[23:0] _e_545;
    (* src = "<compiler dir>/stdlib/conv.spade:204,9" *)
    logic[23:0] _e_544;
    (* src = "<compiler dir>/stdlib/conv.spade:204,31" *)
    \std::conv::impl_6::to_be_bytes  to_be_bytes_0(.self_i(\self ), .output__(_e_545));
    (* src = "<compiler dir>/stdlib/conv.spade:204,9" *)
    \std::conv::flip_array[2157]  flip_array_0(.in_i(_e_545), .output__(_e_544));
    assign output__ = _e_544;
endmodule

module \std::conv::impl_7::to_be_bytes  (
        input[31:0] self_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_7::to_be_bytes" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_7::to_be_bytes );
        end
    end
    `endif
    logic[31:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:212,16" *)
    logic[31:0] _e_550;
    (* src = "<compiler dir>/stdlib/conv.spade:212,10" *)
    logic[7:0] _e_549;
    (* src = "<compiler dir>/stdlib/conv.spade:212,35" *)
    logic[31:0] _e_554;
    (* src = "<compiler dir>/stdlib/conv.spade:212,29" *)
    logic[7:0] _e_553;
    (* src = "<compiler dir>/stdlib/conv.spade:212,54" *)
    logic[31:0] _e_558;
    (* src = "<compiler dir>/stdlib/conv.spade:212,48" *)
    logic[7:0] _e_557;
    (* src = "<compiler dir>/stdlib/conv.spade:212,66" *)
    logic[7:0] _e_561;
    (* src = "<compiler dir>/stdlib/conv.spade:212,9" *)
    logic[31:0] _e_548;
    localparam[31:0] _e_552 = 32'd24;
    assign _e_550 = \self  >> _e_552;
    assign _e_549 = _e_550[7:0];
    localparam[31:0] _e_556 = 32'd16;
    assign _e_554 = \self  >> _e_556;
    assign _e_553 = _e_554[7:0];
    localparam[31:0] _e_560 = 32'd8;
    assign _e_558 = \self  >> _e_560;
    assign _e_557 = _e_558[7:0];
    assign _e_561 = \self [7:0];
    assign _e_548 = {_e_561, _e_557, _e_553, _e_549};
    assign output__ = _e_548;
endmodule

module \std::conv::impl_7::to_le_bytes  (
        input[31:0] self_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_7::to_le_bytes" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_7::to_le_bytes );
        end
    end
    `endif
    logic[31:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:218,31" *)
    logic[31:0] _e_565;
    (* src = "<compiler dir>/stdlib/conv.spade:218,9" *)
    logic[31:0] _e_564;
    (* src = "<compiler dir>/stdlib/conv.spade:218,31" *)
    \std::conv::impl_7::to_be_bytes  to_be_bytes_0(.self_i(\self ), .output__(_e_565));
    (* src = "<compiler dir>/stdlib/conv.spade:218,9" *)
    \std::conv::flip_array[2158]  flip_array_0(.in_i(_e_565), .output__(_e_564));
    assign output__ = _e_564;
endmodule

module \std::cdc::sync2[2152]  (
        input clk_i,
        input in_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::cdc::sync2[2152]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::cdc::sync2[2152] );
        end
    end
    `endif
    logic \clk ;
    assign \clk  = clk_i;
    logic \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/cdc.spade:16,14" *)
    reg \sync1 ;
    (* src = "<compiler dir>/stdlib/cdc.spade:17,14" *)
    reg \sync2 ;
    always @(posedge \clk ) begin
        \sync1  <= \in ;
    end
    always @(posedge \clk ) begin
        \sync2  <= \sync1 ;
    end
    assign output__ = \sync2 ;
endmodule

module \std::conv::impl_4::to_int[2153]  (
        input[31:0] self_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_4::to_int[2153]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_4::to_int[2153] );
        end
    end
    `endif
    logic[31:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    logic[31:0] _e_514;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    \std::conv::uint_to_int[2159]  uint_to_int_0(.input_i(\self ), .output__(_e_514));
    assign output__ = _e_514;
endmodule

module \std::conv::impl_3::to_uint[2154]  (
        input[31:0] self_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_3::to_uint[2154]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_3::to_uint[2154] );
        end
    end
    `endif
    logic[31:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:153,9" *)
    logic[31:0] _e_508;
    (* src = "<compiler dir>/stdlib/conv.spade:153,9" *)
    \std::conv::int_to_uint[2160]  int_to_uint_0(.input_i(\self ), .output__(_e_508));
    assign output__ = _e_508;
endmodule

module \std::conv::impl_4::to_int[2155]  (
        input[15:0] self_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_4::to_int[2155]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_4::to_int[2155] );
        end
    end
    `endif
    logic[15:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    logic[15:0] _e_514;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    \std::conv::uint_to_int[2161]  uint_to_int_0(.input_i(\self ), .output__(_e_514));
    assign output__ = _e_514;
endmodule

module \std::conv::flip_array[2156]  (
        input[15:0] in_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2156]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2156] );
        end
    end
    `endif
    logic[15:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[15:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2162]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::flip_array[2157]  (
        input[23:0] in_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2157]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2157] );
        end
    end
    `endif
    logic[23:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[23:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2163]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::flip_array[2158]  (
        input[31:0] in_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2158]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2158] );
        end
    end
    `endif
    logic[31:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[31:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2164]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::uint_to_int[2159]  (
        input[31:0] input_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::uint_to_int[2159]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::uint_to_int[2159] );
        end
    end
    `endif
    logic[31:0] \input ;
    assign \input  = input_i;
    logic[31:0] _e_479;
    assign _e_479 = \input ;
    assign output__ = _e_479;
endmodule

module \std::conv::int_to_uint[2160]  (
        input[31:0] input_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::int_to_uint[2160]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::int_to_uint[2160] );
        end
    end
    `endif
    logic[31:0] \input ;
    assign \input  = input_i;
    logic[31:0] _e_483;
    assign _e_483 = \input ;
    assign output__ = _e_483;
endmodule

module \std::conv::uint_to_int[2161]  (
        input[15:0] input_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::uint_to_int[2161]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::uint_to_int[2161] );
        end
    end
    `endif
    logic[15:0] \input ;
    assign \input  = input_i;
    logic[15:0] _e_479;
    assign _e_479 = \input ;
    assign output__ = _e_479;
endmodule

module \std::conv::std::conv::flip_array::F[2162]  (
        input[15:0] in_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2162]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2162] );
        end
    end
    `endif
    logic[15:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    logic[7:0] _e_441;
    (* src = "<compiler dir>/stdlib/conv.spade:43,47" *)
    logic[7:0] _e_446;
    (* src = "<compiler dir>/stdlib/conv.spade:43,36" *)
    logic[7:0] _e_445;
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    logic[15:0] _e_440;
    assign _e_441 = \in [15-:8];
    assign _e_446 = \in [7-:8];
    (* src = "<compiler dir>/stdlib/conv.spade:43,36" *)
    \std::conv::flip_array[2165]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2166]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::std::conv::flip_array::F[2163]  (
        input[23:0] in_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2163]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2163] );
        end
    end
    `endif
    logic[23:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    logic[7:0] _e_441;
    (* src = "<compiler dir>/stdlib/conv.spade:43,47" *)
    logic[15:0] _e_446;
    (* src = "<compiler dir>/stdlib/conv.spade:43,36" *)
    logic[15:0] _e_445;
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    logic[23:0] _e_440;
    assign _e_441 = \in [23-:8];
    assign _e_446 = \in [15-:16];
    (* src = "<compiler dir>/stdlib/conv.spade:43,36" *)
    \std::conv::flip_array[2156]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2167]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::std::conv::flip_array::F[2164]  (
        input[31:0] in_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2164]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2164] );
        end
    end
    `endif
    logic[31:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    logic[7:0] _e_441;
    (* src = "<compiler dir>/stdlib/conv.spade:43,47" *)
    logic[23:0] _e_446;
    (* src = "<compiler dir>/stdlib/conv.spade:43,36" *)
    logic[23:0] _e_445;
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    logic[31:0] _e_440;
    assign _e_441 = \in [31-:8];
    assign _e_446 = \in [23-:24];
    (* src = "<compiler dir>/stdlib/conv.spade:43,36" *)
    \std::conv::flip_array[2157]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2168]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::flip_array[2165]  (
        input[7:0] in_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2165]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2165] );
        end
    end
    `endif
    logic[7:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[7:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2169]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::concat_arrays[2166]  (
        input[7:0] l_i,
        input[7:0] r_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2166]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2166] );
        end
    end
    `endif
    logic[7:0] \l ;
    assign \l  = l_i;
    logic[7:0] \r ;
    assign \r  = r_i;
    (* src = "<compiler dir>/stdlib/conv.spade:25,30" *)
    logic[15:0] _e_428;
    logic[15:0] _e_427;
    assign _e_428 = {\r , \l };
    assign _e_427 = _e_428;
    assign output__ = _e_427;
endmodule

module \std::conv::concat_arrays[2167]  (
        input[7:0] l_i,
        input[15:0] r_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2167]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2167] );
        end
    end
    `endif
    logic[7:0] \l ;
    assign \l  = l_i;
    logic[15:0] \r ;
    assign \r  = r_i;
    (* src = "<compiler dir>/stdlib/conv.spade:25,30" *)
    logic[23:0] _e_428;
    logic[23:0] _e_427;
    assign _e_428 = {\r , \l };
    assign _e_427 = _e_428;
    assign output__ = _e_427;
endmodule

module \std::conv::concat_arrays[2168]  (
        input[7:0] l_i,
        input[23:0] r_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2168]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2168] );
        end
    end
    `endif
    logic[7:0] \l ;
    assign \l  = l_i;
    logic[23:0] \r ;
    assign \r  = r_i;
    (* src = "<compiler dir>/stdlib/conv.spade:25,30" *)
    logic[31:0] _e_428;
    logic[31:0] _e_427;
    assign _e_428 = {\r , \l };
    assign _e_427 = _e_428;
    assign output__ = _e_427;
endmodule

module \std::conv::std::conv::flip_array::F[2169]  (
        input[7:0] in_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2169]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2169] );
        end
    end
    `endif
    logic[7:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    logic[7:0] _e_441;
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    logic[7:0] _e_440;
    assign _e_441 = \in ;
    
    (* src = "<compiler dir>/stdlib/conv.spade:43,36" *)
    \std::conv::flip_array[2170]  flip_array_0();
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2171]  concat_arrays_0(.l_i(_e_441), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::flip_array[2170]  (
        
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2170]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2170] );
        end
    end
    `endif
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::T[2172]  T_0();
endmodule

module \std::conv::concat_arrays[2171]  (
        input[7:0] l_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2171]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2171] );
        end
    end
    `endif
    logic[7:0] \l ;
    assign \l  = l_i;
    (* src = "<compiler dir>/stdlib/conv.spade:25,30" *)
    logic[7:0] _e_428;
    logic[7:0] _e_427;
    assign _e_428 = {\l };
    assign _e_427 = _e_428;
    assign output__ = _e_427;
endmodule

module \std::conv::std::conv::flip_array::T[2172]  (
        
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::T[2172]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::T[2172] );
        end
    end
    `endif
    
endmodule