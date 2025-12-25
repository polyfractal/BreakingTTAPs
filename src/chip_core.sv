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
    \std::cdc::sync2[2159]  sync2_0(.clk_i(\clk ), .in_i(\in ), .output__(_e_137));
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
    logic[7:0] _e_7881;
    (* src = "src/sram.spade:66,22" *)
    logic[7:0] _e_7882_mut;
    (* src = "src/sram.spade:66,22" *)
    logic[7:0] _e_1181;
    (* src = "src/sram.spade:66,22" *)
    logic[7:0] _e_1181_mut;
    (* src = "src/sram.spade:66,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:66,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:67,22" *)
    logic[7:0] _e_7883;
    (* src = "src/sram.spade:67,22" *)
    logic[7:0] _e_7884_mut;
    (* src = "src/sram.spade:67,22" *)
    logic[7:0] _e_1185;
    (* src = "src/sram.spade:67,22" *)
    logic[7:0] _e_1185_mut;
    (* src = "src/sram.spade:67,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:67,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:68,22" *)
    logic[7:0] _e_7885;
    (* src = "src/sram.spade:68,22" *)
    logic[7:0] _e_7886_mut;
    (* src = "src/sram.spade:68,22" *)
    logic[7:0] _e_1189;
    (* src = "src/sram.spade:68,22" *)
    logic[7:0] _e_1189_mut;
    (* src = "src/sram.spade:68,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:68,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:69,22" *)
    logic[7:0] _e_7887;
    (* src = "src/sram.spade:69,22" *)
    logic[7:0] _e_7888_mut;
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
    
    assign _e_7881 = _e_7882_mut;
    assign _e_1181 = {_e_7881};
    assign {_e_7882_mut} = _e_1181_mut;
    assign \qr0  = _e_1181[7:0];
    assign _e_1181_mut[7:0] = \qw0_mut ;
    
    assign _e_7883 = _e_7884_mut;
    assign _e_1185 = {_e_7883};
    assign {_e_7884_mut} = _e_1185_mut;
    assign \qr1  = _e_1185[7:0];
    assign _e_1185_mut[7:0] = \qw1_mut ;
    
    assign _e_7885 = _e_7886_mut;
    assign _e_1189 = {_e_7885};
    assign {_e_7886_mut} = _e_1189_mut;
    assign \qr2  = _e_1189[7:0];
    assign _e_1189_mut[7:0] = \qw2_mut ;
    
    assign _e_7887 = _e_7888_mut;
    assign _e_1193 = {_e_7887};
    assign {_e_7888_mut} = _e_1193_mut;
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
    logic[7:0] _e_7889;
    (* src = "src/sram.spade:110,22" *)
    logic[7:0] _e_7890_mut;
    (* src = "src/sram.spade:110,22" *)
    logic[7:0] _e_1291;
    (* src = "src/sram.spade:110,22" *)
    logic[7:0] _e_1291_mut;
    (* src = "src/sram.spade:110,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:110,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_7891;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_7892_mut;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_1295;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_1295_mut;
    (* src = "src/sram.spade:111,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:111,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_7893;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_7894_mut;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_1299;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_1299_mut;
    (* src = "src/sram.spade:112,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:112,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_7895;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_7896_mut;
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
    
    assign _e_7889 = _e_7890_mut;
    assign _e_1291 = {_e_7889};
    assign {_e_7890_mut} = _e_1291_mut;
    assign \qr0  = _e_1291[7:0];
    assign _e_1291_mut[7:0] = \qw0_mut ;
    
    assign _e_7891 = _e_7892_mut;
    assign _e_1295 = {_e_7891};
    assign {_e_7892_mut} = _e_1295_mut;
    assign \qr1  = _e_1295[7:0];
    assign _e_1295_mut[7:0] = \qw1_mut ;
    
    assign _e_7893 = _e_7894_mut;
    assign _e_1299 = {_e_7893};
    assign {_e_7894_mut} = _e_1299_mut;
    assign \qr2  = _e_1299[7:0];
    assign _e_1299_mut[7:0] = \qw2_mut ;
    
    assign _e_7895 = _e_7896_mut;
    assign _e_1303 = {_e_7895};
    assign {_e_7896_mut} = _e_1303_mut;
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
    logic[7:0] _e_7897;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_7898_mut;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_1401;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_1401_mut;
    (* src = "src/sram.spade:163,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:163,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:164,22" *)
    logic[7:0] _e_7899;
    (* src = "src/sram.spade:164,22" *)
    logic[7:0] _e_7900_mut;
    (* src = "src/sram.spade:164,22" *)
    logic[7:0] _e_1405;
    (* src = "src/sram.spade:164,22" *)
    logic[7:0] _e_1405_mut;
    (* src = "src/sram.spade:164,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:164,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:165,22" *)
    logic[7:0] _e_7901;
    (* src = "src/sram.spade:165,22" *)
    logic[7:0] _e_7902_mut;
    (* src = "src/sram.spade:165,22" *)
    logic[7:0] _e_1409;
    (* src = "src/sram.spade:165,22" *)
    logic[7:0] _e_1409_mut;
    (* src = "src/sram.spade:165,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:165,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:166,22" *)
    logic[7:0] _e_7903;
    (* src = "src/sram.spade:166,22" *)
    logic[7:0] _e_7904_mut;
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
    
    assign _e_7897 = _e_7898_mut;
    assign _e_1401 = {_e_7897};
    assign {_e_7898_mut} = _e_1401_mut;
    assign \qr0  = _e_1401[7:0];
    assign _e_1401_mut[7:0] = \qw0_mut ;
    
    assign _e_7899 = _e_7900_mut;
    assign _e_1405 = {_e_7899};
    assign {_e_7900_mut} = _e_1405_mut;
    assign \qr1  = _e_1405[7:0];
    assign _e_1405_mut[7:0] = \qw1_mut ;
    
    assign _e_7901 = _e_7902_mut;
    assign _e_1409 = {_e_7901};
    assign {_e_7902_mut} = _e_1409_mut;
    assign \qr2  = _e_1409[7:0];
    assign _e_1409_mut[7:0] = \qw2_mut ;
    
    assign _e_7903 = _e_7904_mut;
    assign _e_1413 = {_e_7903};
    assign {_e_7904_mut} = _e_1413_mut;
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
    logic[9:0] _e_7905;
    (* src = "src/main.spade:72,24" *)
    logic[9:0] _e_7906_mut;
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
    logic[8:0] _e_7907;
    (* src = "src/main.spade:77,28" *)
    logic[8:0] _e_7908_mut;
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
    logic[8:0] _e_7909;
    (* src = "src/main.spade:83,34" *)
    logic[8:0] _e_7910_mut;
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
    logic _e_7913;
    logic _e_7915;
    logic _e_7917;
    (* src = "src/main.spade:96,7" *)
    logic[11:0] _e_1605;
    (* src = "src/main.spade:96,7" *)
    logic[10:0] _e_1603;
    (* src = "src/main.spade:96,7" *)
    logic _e_1604;
    logic _e_7920;
    logic _e_7922;
    (* src = "src/main.spade:97,7" *)
    logic[11:0] _e_1609;
    (* src = "src/main.spade:97,7" *)
    logic[10:0] __n1;
    (* src = "src/main.spade:97,7" *)
    logic __n2;
    logic _e_7926;
    (* src = "src/main.spade:94,49" *)
    logic _e_1593;
    (* src = "src/main.spade:94,14" *)
    reg \released ;
    (* src = "src/main.spade:101,15" *)
    logic[97:0] _e_1614;
    logic _e_7928;
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
    
    assign _e_7905 = _e_7906_mut;
    assign _e_1535 = {_e_7905};
    assign {_e_7906_mut} = _e_1535_mut;
    assign \pc_r  = _e_1535[9:0];
    assign _e_1535_mut[9:0] = \pc_w_mut ;
    (* src = "src/main.spade:73,25" *)
    \tta::parallel_rx::parallel_boot  parallel_boot_0(.clk_i(\clk ), .rst_i(\rst ), .data_in_i(\parallel_in ), .strobe_i(\parallel_strobe ), .clk_pin_i(\parallel_clock ), .output__(\parallel_data ));
    
    assign _e_7907 = _e_7908_mut;
    assign _e_1547 = {_e_7907};
    assign {_e_7908_mut} = _e_1547_mut;
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
    
    assign _e_7909 = _e_7910_mut;
    assign _e_1571 = {_e_7909};
    assign {_e_7910_mut} = _e_1571_mut;
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
    assign _e_7913 = _e_1599[10] == 1'd1;
    localparam[0:0] _e_7914 = 1;
    assign _e_7915 = _e_7913 && _e_7914;
    localparam[0:0] _e_7916 = 1;
    assign _e_7917 = _e_7915 && _e_7916;
    localparam[0:0] _e_1602 = 1;
    assign _e_1605 = _e_1594;
    assign _e_1603 = _e_1594[11:1];
    assign _e_1604 = _e_1594[0];
    assign _e_7920 = _e_1603[10] == 1'd0;
    assign _e_7922 = _e_7920 && _e_1604;
    localparam[0:0] _e_1606 = 1;
    assign _e_1609 = _e_1594;
    assign __n1 = _e_1594[11:1];
    assign __n2 = _e_1594[0];
    localparam[0:0] _e_7924 = 1;
    localparam[0:0] _e_7925 = 1;
    assign _e_7926 = _e_7924 && _e_7925;
    localparam[0:0] _e_1610 = 0;
    always_comb begin
        priority casez ({_e_7917, _e_7922, _e_7926})
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
    assign _e_7928 = !\released ;
    (* src = "src/main.spade:102,16" *)
    \tta::noop  noop_0(.output__(_e_1617));
    always_comb begin
        priority casez ({\released , _e_7928})
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
    logic _e_7930;
    (* src = "src/uart.spade:62,27" *)
    logic[8:0] _e_1713;
    (* src = "src/uart.spade:63,25" *)
    logic[8:0] _e_1716;
    (* src = "src/uart.spade:63,25" *)
    logic[7:0] \data ;
    logic _e_7932;
    logic _e_7934;
    (* src = "src/uart.spade:66,36" *)
    logic[1:0] _e_1719;
    (* src = "src/uart.spade:66,29" *)
    logic[17:0] _e_1718;
    (* src = "src/uart.spade:68,25" *)
    logic[8:0] _e_1723;
    logic _e_7936;
    (* src = "src/uart.spade:62,21" *)
    logic[17:0] _e_1712;
    (* src = "src/uart.spade:71,17" *)
    logic[1:0] _e_1725;
    logic _e_7938;
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
    logic _e_7940;
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
    logic _e_7942;
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
    logic _e_7944;
    (* src = "src/uart.spade:106,9" *)
    logic[1:0] _e_1810;
    logic _e_7946;
    (* src = "src/uart.spade:107,9" *)
    logic[1:0] _e_1812;
    logic _e_7948;
    (* src = "src/uart.spade:107,27" *)
    logic[7:0] _e_1815;
    (* src = "src/uart.spade:107,26" *)
    logic[7:0] _e_1814;
    (* src = "src/uart.spade:107,26" *)
    logic _e_1813;
    (* src = "src/uart.spade:108,9" *)
    logic[1:0] _e_1819;
    logic _e_7950;
    (* src = "src/uart.spade:104,18" *)
    logic \tx_out ;
    (* src = "src/uart.spade:111,25" *)
    logic[1:0] _e_1823;
    (* src = "src/uart.spade:112,9" *)
    logic[1:0] _e_1825;
    logic _e_7952;
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
    logic _e_7955;
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
    logic _e_7957;
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
    logic _e_7959;
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
    logic _e_7961;
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
    logic _e_7963;
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
    assign _e_7930 = _e_1708[1:0] == 2'd0;
    assign _e_1713 = \tx_data ;
    assign _e_1716 = _e_1713;
    assign \data  = _e_1713[7:0];
    assign _e_7932 = _e_1713[8] == 1'd1;
    localparam[0:0] _e_7933 = 1;
    assign _e_7934 = _e_7932 && _e_7933;
    assign _e_1719 = {2'd1};
    localparam[3:0] _e_1721 = 0;
    localparam[3:0] _e_1722 = 0;
    assign _e_1718 = {_e_1719, \data , _e_1721, _e_1722};
    assign _e_1723 = _e_1713;
    assign _e_7936 = _e_1713[8] == 1'd0;
    always_comb begin
        priority casez ({_e_7934, _e_7936})
            2'b1?: _e_1712 = _e_1718;
            2'b01: _e_1712 = \tx ;
            2'b?: _e_1712 = 18'dx;
        endcase
    end
    assign _e_1725 = _e_1708;
    assign _e_7938 = _e_1708[1:0] == 2'd1;
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
    assign _e_7940 = _e_1708[1:0] == 2'd2;
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
    assign _e_7942 = _e_1708[1:0] == 2'd3;
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
        priority casez ({_e_7930, _e_7938, _e_7940, _e_7942})
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
    assign _e_7944 = _e_1806[1:0] == 2'd0;
    localparam[0:0] _e_1809 = 1;
    assign _e_1810 = _e_1806;
    assign _e_7946 = _e_1806[1:0] == 2'd1;
    localparam[0:0] _e_1811 = 0;
    assign _e_1812 = _e_1806;
    assign _e_7948 = _e_1806[1:0] == 2'd2;
    assign _e_1815 = \tx [15:8];
    localparam[7:0] _e_1817 = 1;
    assign _e_1814 = _e_1815 & _e_1817;
    localparam[7:0] _e_1818 = 0;
    assign _e_1813 = _e_1814 != _e_1818;
    assign _e_1819 = _e_1806;
    assign _e_7950 = _e_1806[1:0] == 2'd3;
    localparam[0:0] _e_1820 = 1;
    always_comb begin
        priority casez ({_e_7944, _e_7946, _e_7948, _e_7950})
            4'b1???: \tx_out  = _e_1809;
            4'b01??: \tx_out  = _e_1811;
            4'b001?: \tx_out  = _e_1813;
            4'b0001: \tx_out  = _e_1820;
            4'b?: \tx_out  = 1'dx;
        endcase
    end
    assign _e_1823 = \tx [17:16];
    assign _e_1825 = _e_1823;
    assign _e_7952 = _e_1823[1:0] == 2'd0;
    localparam[0:0] _e_1826 = 0;
    assign \_  = _e_1823;
    localparam[0:0] _e_7953 = 1;
    localparam[0:0] _e_1828 = 1;
    always_comb begin
        priority casez ({_e_7952, _e_7953})
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
    assign _e_7955 = _e_1856[1:0] == 2'd0;
    assign _e_1861 = !\rxd ;
    assign _e_1865 = {2'd1};
    localparam[7:0] _e_1866 = 0;
    localparam[2:0] _e_1867 = 0;
    localparam[3:0] _e_1868 = 0;
    assign _e_1864 = {_e_1865, _e_1866, _e_1867, _e_1868};
    assign _e_1860 = _e_1861 ? _e_1864 : \rx ;
    assign _e_1871 = _e_1856;
    assign _e_7957 = _e_1856[1:0] == 2'd1;
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
    assign _e_7959 = _e_1856[1:0] == 2'd2;
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
    assign _e_7961 = _e_1856[1:0] == 2'd3;
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
        priority casez ({_e_7955, _e_7957, _e_7959, _e_7961})
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
    assign _e_7963 = _e_1993[1:0] == 2'd3;
    assign _e_1997 = \rx [3:0];
    localparam[3:0] _e_1999 = 15;
    assign _e_1996 = _e_1997 == _e_1999;
    assign __n1 = _e_1993;
    localparam[0:0] _e_7964 = 1;
    localparam[0:0] _e_2001 = 0;
    always_comb begin
        priority casez ({_e_7963, _e_7964})
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
    logic _e_7966;
    logic _e_7968;
    logic _e_7970;
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
    logic _e_7972;
    logic _e_7975;
    logic _e_7977;
    logic _e_7978;
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
    logic _e_7980;
    logic _e_7983;
    logic _e_7985;
    logic _e_7986;
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
    logic _e_7988;
    logic _e_7991;
    logic _e_7993;
    logic _e_7994;
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
    logic _e_7996;
    logic _e_7999;
    logic _e_8001;
    logic _e_8002;
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
    logic _e_8004;
    logic _e_8007;
    logic _e_8009;
    logic _e_8010;
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
    logic _e_8012;
    logic _e_8015;
    logic _e_8017;
    logic _e_8018;
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
    logic _e_8020;
    logic _e_8023;
    logic _e_8025;
    logic _e_8026;
    (* src = "src/alu.spade:37,55" *)
    logic[31:0] _e_2085;
    (* src = "src/alu.spade:37,55" *)
    logic[31:0] \sh ;
    (* src = "src/alu.spade:37,83" *)
    logic[31:0] _e_2091;
    (* src = "src/alu.spade:37,77" *)
    logic[31:0] _e_2090;
    (* src = "src/alu.spade:37,72" *)
    logic[32:0] _e_2089;
    (* src = "src/alu.spade:38,9" *)
    logic[36:0] _e_2096;
    (* src = "src/alu.spade:38,14" *)
    logic[4:0] _e_2094;
    (* src = "src/alu.spade:38,14" *)
    logic[31:0] b_n7;
    logic _e_8028;
    logic _e_8031;
    logic _e_8033;
    logic _e_8034;
    (* src = "src/alu.spade:38,55" *)
    logic[31:0] _e_2100;
    (* src = "src/alu.spade:38,55" *)
    logic[31:0] sh_n1;
    (* src = "src/alu.spade:38,83" *)
    logic[31:0] _e_2106;
    (* src = "src/alu.spade:38,77" *)
    logic[31:0] _e_2105;
    (* src = "src/alu.spade:38,72" *)
    logic[32:0] _e_2104;
    (* src = "src/alu.spade:39,9" *)
    logic[36:0] _e_2111;
    (* src = "src/alu.spade:39,14" *)
    logic[4:0] _e_2109;
    (* src = "src/alu.spade:39,14" *)
    logic[31:0] b_n8;
    logic _e_8036;
    logic _e_8039;
    logic _e_8041;
    logic _e_8042;
    (* src = "src/alu.spade:39,55" *)
    logic[4:0] sh_n2;
    (* src = "src/alu.spade:39,70" *)
    logic[31:0] _e_2118;
    (* src = "src/alu.spade:39,65" *)
    logic[32:0] _e_2117;
    (* src = "src/alu.spade:40,9" *)
    logic[36:0] _e_2123;
    (* src = "src/alu.spade:40,14" *)
    logic[4:0] _e_2121;
    (* src = "src/alu.spade:40,14" *)
    logic[31:0] b_n9;
    logic _e_8044;
    logic _e_8047;
    logic _e_8049;
    logic _e_8050;
    (* src = "src/alu.spade:40,55" *)
    logic[4:0] sh_n3;
    (* src = "src/alu.spade:40,70" *)
    logic[31:0] _e_2130;
    (* src = "src/alu.spade:40,65" *)
    logic[32:0] _e_2129;
    (* src = "src/alu.spade:41,9" *)
    logic[36:0] _e_2135;
    (* src = "src/alu.spade:41,14" *)
    logic[4:0] _e_2133;
    (* src = "src/alu.spade:41,14" *)
    logic[31:0] b_n10;
    logic _e_8052;
    logic _e_8055;
    logic _e_8057;
    logic _e_8058;
    (* src = "src/alu.spade:41,55" *)
    logic[4:0] sh_n4;
    (* src = "src/alu.spade:41,70" *)
    logic[31:0] _e_2142;
    (* src = "src/alu.spade:41,65" *)
    logic[32:0] _e_2141;
    (* src = "src/alu.spade:44,9" *)
    logic[36:0] _e_2147;
    (* src = "src/alu.spade:44,14" *)
    logic[4:0] _e_2145;
    (* src = "src/alu.spade:44,14" *)
    logic[31:0] b_n11;
    logic _e_8060;
    logic _e_8063;
    logic _e_8065;
    logic _e_8066;
    (* src = "src/alu.spade:44,42" *)
    logic _e_2151;
    (* src = "src/alu.spade:44,39" *)
    logic[31:0] _e_2150;
    (* src = "src/alu.spade:44,34" *)
    logic[32:0] _e_2149;
    (* src = "src/alu.spade:45,9" *)
    logic[36:0] _e_2160;
    (* src = "src/alu.spade:45,14" *)
    logic[4:0] _e_2158;
    (* src = "src/alu.spade:45,14" *)
    logic[31:0] b_n12;
    logic _e_8068;
    logic _e_8071;
    logic _e_8073;
    logic _e_8074;
    (* src = "src/alu.spade:45,42" *)
    logic _e_2164;
    (* src = "src/alu.spade:45,39" *)
    logic[31:0] _e_2163;
    (* src = "src/alu.spade:45,34" *)
    logic[32:0] _e_2162;
    (* src = "src/alu.spade:48,9" *)
    logic[36:0] _e_2173;
    (* src = "src/alu.spade:48,14" *)
    logic[4:0] _e_2171;
    (* src = "src/alu.spade:48,14" *)
    logic[31:0] b_n13;
    logic _e_8076;
    logic _e_8079;
    logic _e_8081;
    logic _e_8082;
    (* src = "src/alu.spade:48,41" *)
    logic[31:0] _e_2176;
    (* src = "src/alu.spade:48,36" *)
    logic[32:0] _e_2175;
    (* src = "src/alu.spade:49,9" *)
    logic[36:0] _e_2181;
    (* src = "src/alu.spade:49,14" *)
    logic[4:0] _e_2179;
    (* src = "src/alu.spade:49,14" *)
    logic[31:0] b_n14;
    logic _e_8084;
    logic _e_8087;
    logic _e_8089;
    logic _e_8090;
    (* src = "src/alu.spade:49,41" *)
    logic[31:0] _e_2184;
    (* src = "src/alu.spade:49,36" *)
    logic[32:0] _e_2183;
    (* src = "src/alu.spade:52,9" *)
    logic[36:0] _e_2189;
    (* src = "src/alu.spade:52,14" *)
    logic[4:0] _e_2187;
    (* src = "src/alu.spade:52,14" *)
    logic[31:0] b_n15;
    logic _e_8092;
    logic _e_8095;
    logic _e_8097;
    logic _e_8098;
    (* src = "src/alu.spade:52,41" *)
    logic[31:0] _e_2192;
    (* src = "src/alu.spade:52,36" *)
    logic[32:0] _e_2191;
    (* src = "src/alu.spade:53,9" *)
    logic[36:0] _e_2197;
    (* src = "src/alu.spade:53,14" *)
    logic[4:0] _e_2195;
    (* src = "src/alu.spade:53,14" *)
    logic[31:0] b_n16;
    logic _e_8100;
    logic _e_8103;
    logic _e_8105;
    logic _e_8106;
    (* src = "src/alu.spade:53,41" *)
    logic[31:0] _e_2200;
    (* src = "src/alu.spade:53,36" *)
    logic[32:0] _e_2199;
    logic _e_8108;
    (* src = "src/alu.spade:55,17" *)
    logic[32:0] _e_2204;
    (* src = "src/alu.spade:29,36" *)
    logic[32:0] \result ;
    (* src = "src/alu.spade:59,51" *)
    logic[32:0] _e_2209;
    (* src = "src/alu.spade:59,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2020 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_7966 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_7967 = 1;
    assign _e_7968 = _e_7966 && _e_7967;
    assign _e_7970 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_7968, _e_7970})
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
    assign _e_7972 = \trig [37] == 1'd1;
    assign _e_7975 = _e_2030[4:0] == 5'd0;
    localparam[0:0] _e_7976 = 1;
    assign _e_7977 = _e_7975 && _e_7976;
    assign _e_7978 = _e_7972 && _e_7977;
    assign _e_2036 = \op_a  + \b ;
    assign _e_2035 = _e_2036[31:0];
    assign _e_2034 = {1'd1, _e_2035};
    assign _e_2041 = \trig [36:0];
    assign _e_2039 = _e_2041[36:32];
    assign b_n1 = _e_2041[31:0];
    assign _e_7980 = \trig [37] == 1'd1;
    assign _e_7983 = _e_2039[4:0] == 5'd1;
    localparam[0:0] _e_7984 = 1;
    assign _e_7985 = _e_7983 && _e_7984;
    assign _e_7986 = _e_7980 && _e_7985;
    assign _e_2045 = \op_a  - b_n1;
    assign _e_2044 = _e_2045[31:0];
    assign _e_2043 = {1'd1, _e_2044};
    assign _e_2050 = \trig [36:0];
    assign _e_2048 = _e_2050[36:32];
    assign b_n2 = _e_2050[31:0];
    assign _e_7988 = \trig [37] == 1'd1;
    assign _e_7991 = _e_2048[4:0] == 5'd2;
    localparam[0:0] _e_7992 = 1;
    assign _e_7993 = _e_7991 && _e_7992;
    assign _e_7994 = _e_7988 && _e_7993;
    assign _e_2053 = \op_a  & b_n2;
    assign _e_2052 = {1'd1, _e_2053};
    assign _e_2058 = \trig [36:0];
    assign _e_2056 = _e_2058[36:32];
    assign b_n3 = _e_2058[31:0];
    assign _e_7996 = \trig [37] == 1'd1;
    assign _e_7999 = _e_2056[4:0] == 5'd3;
    localparam[0:0] _e_8000 = 1;
    assign _e_8001 = _e_7999 && _e_8000;
    assign _e_8002 = _e_7996 && _e_8001;
    assign _e_2061 = \op_a  | b_n3;
    assign _e_2060 = {1'd1, _e_2061};
    assign _e_2066 = \trig [36:0];
    assign _e_2064 = _e_2066[36:32];
    assign b_n4 = _e_2066[31:0];
    assign _e_8004 = \trig [37] == 1'd1;
    assign _e_8007 = _e_2064[4:0] == 5'd4;
    localparam[0:0] _e_8008 = 1;
    assign _e_8009 = _e_8007 && _e_8008;
    assign _e_8010 = _e_8004 && _e_8009;
    assign _e_2069 = ~b_n4;
    assign _e_2068 = {1'd1, _e_2069};
    assign _e_2073 = \trig [36:0];
    assign _e_2071 = _e_2073[36:32];
    assign b_n5 = _e_2073[31:0];
    assign _e_8012 = \trig [37] == 1'd1;
    assign _e_8015 = _e_2071[4:0] == 5'd5;
    localparam[0:0] _e_8016 = 1;
    assign _e_8017 = _e_8015 && _e_8016;
    assign _e_8018 = _e_8012 && _e_8017;
    assign _e_2076 = \op_a  ^ b_n5;
    assign _e_2075 = {1'd1, _e_2076};
    assign _e_2081 = \trig [36:0];
    assign _e_2079 = _e_2081[36:32];
    assign b_n6 = _e_2081[31:0];
    assign _e_8020 = \trig [37] == 1'd1;
    assign _e_8023 = _e_2079[4:0] == 5'd6;
    localparam[0:0] _e_8024 = 1;
    assign _e_8025 = _e_8023 && _e_8024;
    assign _e_8026 = _e_8020 && _e_8025;
    assign _e_2085 = b_n6[31:0];
    localparam[31:0] _e_2087 = 32'd31;
    assign \sh  = _e_2085 & _e_2087;
    assign _e_2091 = \op_a  << \sh ;
    assign _e_2090 = _e_2091[31:0];
    assign _e_2089 = {1'd1, _e_2090};
    assign _e_2096 = \trig [36:0];
    assign _e_2094 = _e_2096[36:32];
    assign b_n7 = _e_2096[31:0];
    assign _e_8028 = \trig [37] == 1'd1;
    assign _e_8031 = _e_2094[4:0] == 5'd7;
    localparam[0:0] _e_8032 = 1;
    assign _e_8033 = _e_8031 && _e_8032;
    assign _e_8034 = _e_8028 && _e_8033;
    assign _e_2100 = b_n7[31:0];
    localparam[31:0] _e_2102 = 32'd31;
    assign sh_n1 = _e_2100 & _e_2102;
    assign _e_2106 = \op_a  >> sh_n1;
    assign _e_2105 = _e_2106[31:0];
    assign _e_2104 = {1'd1, _e_2105};
    assign _e_2111 = \trig [36:0];
    assign _e_2109 = _e_2111[36:32];
    assign b_n8 = _e_2111[31:0];
    assign _e_8036 = \trig [37] == 1'd1;
    assign _e_8039 = _e_2109[4:0] == 5'd8;
    localparam[0:0] _e_8040 = 1;
    assign _e_8041 = _e_8039 && _e_8040;
    assign _e_8042 = _e_8036 && _e_8041;
    assign sh_n2 = b_n8[4:0];
    (* src = "src/alu.spade:39,70" *)
    \tta::alu::ashr32  ashr32_0(.x_i(\op_a ), .sh_i(sh_n2), .output__(_e_2118));
    assign _e_2117 = {1'd1, _e_2118};
    assign _e_2123 = \trig [36:0];
    assign _e_2121 = _e_2123[36:32];
    assign b_n9 = _e_2123[31:0];
    assign _e_8044 = \trig [37] == 1'd1;
    assign _e_8047 = _e_2121[4:0] == 5'd9;
    localparam[0:0] _e_8048 = 1;
    assign _e_8049 = _e_8047 && _e_8048;
    assign _e_8050 = _e_8044 && _e_8049;
    assign sh_n3 = b_n9[4:0];
    (* src = "src/alu.spade:40,70" *)
    \tta::alu::rotl32  rotl32_0(.x_i(\op_a ), .sh_i(sh_n3), .output__(_e_2130));
    assign _e_2129 = {1'd1, _e_2130};
    assign _e_2135 = \trig [36:0];
    assign _e_2133 = _e_2135[36:32];
    assign b_n10 = _e_2135[31:0];
    assign _e_8052 = \trig [37] == 1'd1;
    assign _e_8055 = _e_2133[4:0] == 5'd10;
    localparam[0:0] _e_8056 = 1;
    assign _e_8057 = _e_8055 && _e_8056;
    assign _e_8058 = _e_8052 && _e_8057;
    assign sh_n4 = b_n10[4:0];
    (* src = "src/alu.spade:41,70" *)
    \tta::alu::rotr32  rotr32_0(.x_i(\op_a ), .sh_i(sh_n4), .output__(_e_2142));
    assign _e_2141 = {1'd1, _e_2142};
    assign _e_2147 = \trig [36:0];
    assign _e_2145 = _e_2147[36:32];
    assign b_n11 = _e_2147[31:0];
    assign _e_8060 = \trig [37] == 1'd1;
    assign _e_8063 = _e_2145[4:0] == 5'd11;
    localparam[0:0] _e_8064 = 1;
    assign _e_8065 = _e_8063 && _e_8064;
    assign _e_8066 = _e_8060 && _e_8065;
    assign _e_2151 = \op_a  < b_n11;
    assign _e_2150 = _e_2151 ? \op_a  : b_n11;
    assign _e_2149 = {1'd1, _e_2150};
    assign _e_2160 = \trig [36:0];
    assign _e_2158 = _e_2160[36:32];
    assign b_n12 = _e_2160[31:0];
    assign _e_8068 = \trig [37] == 1'd1;
    assign _e_8071 = _e_2158[4:0] == 5'd12;
    localparam[0:0] _e_8072 = 1;
    assign _e_8073 = _e_8071 && _e_8072;
    assign _e_8074 = _e_8068 && _e_8073;
    assign _e_2164 = \op_a  > b_n12;
    assign _e_2163 = _e_2164 ? \op_a  : b_n12;
    assign _e_2162 = {1'd1, _e_2163};
    assign _e_2173 = \trig [36:0];
    assign _e_2171 = _e_2173[36:32];
    assign b_n13 = _e_2173[31:0];
    assign _e_8076 = \trig [37] == 1'd1;
    assign _e_8079 = _e_2171[4:0] == 5'd13;
    localparam[0:0] _e_8080 = 1;
    assign _e_8081 = _e_8079 && _e_8080;
    assign _e_8082 = _e_8076 && _e_8081;
    (* src = "src/alu.spade:48,41" *)
    \tta::alu::sadd32  sadd32_0(.a_u_i(\op_a ), .b_u_i(b_n13), .output__(_e_2176));
    assign _e_2175 = {1'd1, _e_2176};
    assign _e_2181 = \trig [36:0];
    assign _e_2179 = _e_2181[36:32];
    assign b_n14 = _e_2181[31:0];
    assign _e_8084 = \trig [37] == 1'd1;
    assign _e_8087 = _e_2179[4:0] == 5'd14;
    localparam[0:0] _e_8088 = 1;
    assign _e_8089 = _e_8087 && _e_8088;
    assign _e_8090 = _e_8084 && _e_8089;
    (* src = "src/alu.spade:49,41" *)
    \tta::alu::ssub32  ssub32_0(.a_u_i(\op_a ), .b_u_i(b_n14), .output__(_e_2184));
    assign _e_2183 = {1'd1, _e_2184};
    assign _e_2189 = \trig [36:0];
    assign _e_2187 = _e_2189[36:32];
    assign b_n15 = _e_2189[31:0];
    assign _e_8092 = \trig [37] == 1'd1;
    assign _e_8095 = _e_2187[4:0] == 5'd15;
    localparam[0:0] _e_8096 = 1;
    assign _e_8097 = _e_8095 && _e_8096;
    assign _e_8098 = _e_8092 && _e_8097;
    (* src = "src/alu.spade:52,41" *)
    \tta::alu::uadd32  uadd32_0(.a_i(\op_a ), .b_i(b_n15), .output__(_e_2192));
    assign _e_2191 = {1'd1, _e_2192};
    assign _e_2197 = \trig [36:0];
    assign _e_2195 = _e_2197[36:32];
    assign b_n16 = _e_2197[31:0];
    assign _e_8100 = \trig [37] == 1'd1;
    assign _e_8103 = _e_2195[4:0] == 5'd16;
    localparam[0:0] _e_8104 = 1;
    assign _e_8105 = _e_8103 && _e_8104;
    assign _e_8106 = _e_8100 && _e_8105;
    (* src = "src/alu.spade:53,41" *)
    \tta::alu::usub32  usub32_0(.a_i(\op_a ), .b_i(b_n16), .output__(_e_2200));
    assign _e_2199 = {1'd1, _e_2200};
    assign _e_8108 = \trig [37] == 1'd0;
    assign _e_2204 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_7978, _e_7986, _e_7994, _e_8002, _e_8010, _e_8018, _e_8026, _e_8034, _e_8042, _e_8050, _e_8058, _e_8066, _e_8074, _e_8082, _e_8090, _e_8098, _e_8106, _e_8108})
            18'b1?????????????????: \result  = _e_2034;
            18'b01????????????????: \result  = _e_2043;
            18'b001???????????????: \result  = _e_2052;
            18'b0001??????????????: \result  = _e_2060;
            18'b00001?????????????: \result  = _e_2068;
            18'b000001????????????: \result  = _e_2075;
            18'b0000001???????????: \result  = _e_2089;
            18'b00000001??????????: \result  = _e_2104;
            18'b000000001?????????: \result  = _e_2117;
            18'b0000000001????????: \result  = _e_2129;
            18'b00000000001???????: \result  = _e_2141;
            18'b000000000001??????: \result  = _e_2149;
            18'b0000000000001?????: \result  = _e_2162;
            18'b00000000000001????: \result  = _e_2175;
            18'b000000000000001???: \result  = _e_2183;
            18'b0000000000000001??: \result  = _e_2191;
            18'b00000000000000001?: \result  = _e_2199;
            18'b000000000000000001: \result  = _e_2204;
            18'b?: \result  = 33'dx;
        endcase
    end
    assign _e_2209 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_2209;
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
    logic[31:0] _e_2214;
    logic[31:0] _e_2216;
    (* src = "src/alu.spade:70,25" *)
    logic[32:0] \sum ;
    (* src = "src/alu.spade:73,8" *)
    logic _e_2220;
    (* src = "src/alu.spade:76,9" *)
    logic[31:0] _e_2226;
    (* src = "src/alu.spade:73,5" *)
    logic[31:0] _e_2219;
    assign _e_2214 = \a ;
    assign _e_2216 = \b ;
    assign \sum  = _e_2214 + _e_2216;
    localparam[32:0] _e_2222 = 33'd4294967295;
    assign _e_2220 = \sum  > _e_2222;
    localparam[31:0] _e_2224 = 32'd4294967295;
    assign _e_2226 = \sum [31:0];
    assign _e_2219 = _e_2220 ? _e_2224 : _e_2226;
    assign output__ = _e_2219;
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
    logic _e_2230;
    (* src = "src/alu.spade:85,15" *)
    logic[32:0] _e_2237;
    (* src = "src/alu.spade:85,9" *)
    logic[31:0] _e_2236;
    (* src = "src/alu.spade:82,5" *)
    logic[31:0] _e_2229;
    assign _e_2230 = \a  < \b ;
    localparam[31:0] _e_2234 = 32'd0;
    assign _e_2237 = \a  - \b ;
    assign _e_2236 = _e_2237[31:0];
    assign _e_2229 = _e_2230 ? _e_2234 : _e_2236;
    assign output__ = _e_2229;
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
    logic _e_2258;
    (* src = "src/alu.spade:108,15" *)
    logic _e_2264;
    (* src = "src/alu.spade:112,28" *)
    logic[31:0] sum_n1;
    (* src = "src/alu.spade:113,9" *)
    logic[31:0] _e_2273;
    (* src = "src/alu.spade:108,12" *)
    logic[31:0] _e_2263;
    (* src = "src/alu.spade:106,5" *)
    logic[31:0] _e_2257;
    (* src = "src/alu.spade:95,22" *)
    \std::conv::impl_4::to_int[2160]  to_int_0(.self_i(\a_u ), .output__(\a ));
    (* src = "src/alu.spade:96,22" *)
    \std::conv::impl_4::to_int[2160]  to_int_1(.self_i(\b_u ), .output__(\b ));
    assign \a_big  = {\a [31], \a };
    assign \b_big  = {\b [31], \b };
    assign \sum  = $signed(\a_big ) + $signed(\b_big );
    localparam[33:0] _e_2260 = 34'd2147483647;
    assign _e_2258 = $signed(\sum ) > $signed(_e_2260);
    localparam[31:0] _e_2262 = 32'd2147483647;
    localparam[33:0] _e_2266 = -34'd2147483648;
    assign _e_2264 = $signed(\sum ) < $signed(_e_2266);
    localparam[31:0] _e_2268 = 32'd2147483648;
    assign sum_n1 = \sum [31:0];
    (* src = "src/alu.spade:113,9" *)
    \std::conv::impl_3::to_uint[2161]  to_uint_0(.self_i(sum_n1), .output__(_e_2273));
    assign _e_2263 = _e_2264 ? _e_2268 : _e_2273;
    assign _e_2257 = _e_2258 ? _e_2262 : _e_2263;
    assign output__ = _e_2257;
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
    logic _e_2293;
    (* src = "src/alu.spade:127,15" *)
    logic _e_2299;
    (* src = "src/alu.spade:130,35" *)
    logic[31:0] \trunc_diff ;
    (* src = "src/alu.spade:131,9" *)
    logic[31:0] _e_2308;
    (* src = "src/alu.spade:127,12" *)
    logic[31:0] _e_2298;
    (* src = "src/alu.spade:125,5" *)
    logic[31:0] _e_2292;
    (* src = "src/alu.spade:118,22" *)
    \std::conv::impl_4::to_int[2160]  to_int_0(.self_i(\a_u ), .output__(\a ));
    (* src = "src/alu.spade:119,22" *)
    \std::conv::impl_4::to_int[2160]  to_int_1(.self_i(\b_u ), .output__(\b ));
    assign \a_big  = {\a [31], \a };
    assign \b_big  = {\b [31], \b };
    assign \diff  = $signed(\a_big ) - $signed(\b_big );
    localparam[33:0] _e_2295 = 34'd2147483647;
    assign _e_2293 = $signed(\diff ) > $signed(_e_2295);
    localparam[31:0] _e_2297 = 32'd2147483647;
    localparam[33:0] _e_2301 = -34'd2147483648;
    assign _e_2299 = $signed(\diff ) < $signed(_e_2301);
    localparam[31:0] _e_2303 = 32'd2147483648;
    assign \trunc_diff  = \diff [31:0];
    (* src = "src/alu.spade:131,9" *)
    \std::conv::impl_3::to_uint[2161]  to_uint_0(.self_i(\trunc_diff ), .output__(_e_2308));
    assign _e_2298 = _e_2299 ? _e_2303 : _e_2308;
    assign _e_2292 = _e_2293 ? _e_2297 : _e_2298;
    assign output__ = _e_2292;
endmodule

module \tta::alu::ashr32  (
        input[31:0] x_i,
        input[4:0] sh_i,
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
    logic[4:0] \sh ;
    assign \sh  = sh_i;
    logic[31:0] \sh32 ;
    (* src = "src/alu.spade:140,29" *)
    logic[31:0] \logical ;
    (* src = "src/alu.spade:141,32" *)
    logic[31:0] _e_2319;
    (* src = "src/alu.spade:141,26" *)
    logic \sign1 ;
    logic[30:0] _e_2325;
    (* src = "src/alu.spade:142,30" *)
    logic[31:0] \signmask ;
    (* src = "src/alu.spade:143,33" *)
    logic _e_2329;
    (* src = "src/alu.spade:143,62" *)
    logic[32:0] _e_2337;
    (* src = "src/alu.spade:143,73" *)
    logic[32:0] _e_2340;
    (* src = "src/alu.spade:143,62" *)
    logic[32:0] _e_2336;
    (* src = "src/alu.spade:143,56" *)
    logic[31:0] _e_2335;
    (* src = "src/alu.spade:143,30" *)
    logic[31:0] \top_mask ;
    (* src = "src/alu.spade:144,26" *)
    logic[31:0] \fill ;
    (* src = "src/alu.spade:145,5" *)
    logic[31:0] _e_2348;
    assign \sh32  = {27'b0, \sh };
    assign \logical  = \x  >> \sh32 ;
    localparam[31:0] _e_2321 = 32'd31;
    assign _e_2319 = \x  >> _e_2321;
    assign \sign1  = _e_2319[0:0];
    localparam[30:0] _e_2324 = 0;
    assign _e_2325 = {30'b0, \sign1 };
    assign \signmask  = _e_2324 - _e_2325;
    localparam[4:0] _e_2331 = 0;
    assign _e_2329 = \sh  == _e_2331;
    localparam[31:0] _e_2333 = 32'd0;
    localparam[31:0] _e_2338 = 32'd0;
    localparam[31:0] _e_2339 = 32'd1;
    assign _e_2337 = _e_2338 - _e_2339;
    localparam[31:0] _e_2341 = 32'd32;
    assign _e_2340 = _e_2341 - \sh32 ;
    assign _e_2336 = _e_2337 << _e_2340;
    assign _e_2335 = _e_2336[31:0];
    assign \top_mask  = _e_2329 ? _e_2333 : _e_2335;
    assign \fill  = \signmask  & \top_mask ;
    assign _e_2348 = \logical  | \fill ;
    assign output__ = _e_2348;
endmodule

module \tta::alu::rotl32  (
        input[31:0] x_i,
        input[4:0] sh_i,
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
    logic[4:0] \sh ;
    assign \sh  = sh_i;
    logic[31:0] \sh32 ;
    (* src = "src/alu.spade:151,6" *)
    logic _e_2356;
    (* src = "src/alu.spade:152,26" *)
    logic[31:0] \left ;
    (* src = "src/alu.spade:153,36" *)
    logic[32:0] _e_2367;
    (* src = "src/alu.spade:153,30" *)
    logic[31:0] \inverted ;
    (* src = "src/alu.spade:154,27" *)
    logic[31:0] \right ;
    (* src = "src/alu.spade:155,5" *)
    logic[31:0] _e_2375;
    (* src = "src/alu.spade:151,3" *)
    logic[31:0] _e_2355;
    assign \sh32  = {27'b0, \sh };
    localparam[4:0] _e_2358 = 0;
    assign _e_2356 = \sh  == _e_2358;
    assign \left  = \x  << \sh32 ;
    localparam[31:0] _e_2368 = 32'd32;
    assign _e_2367 = _e_2368 - \sh32 ;
    assign \inverted  = _e_2367[31:0];
    assign \right  = \x  >> \inverted ;
    assign _e_2375 = \left  | \right ;
    assign _e_2355 = _e_2356 ? \x  : _e_2375;
    assign output__ = _e_2355;
endmodule

module \tta::alu::rotr32  (
        input[31:0] x_i,
        input[4:0] sh_i,
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
    logic[4:0] \sh ;
    assign \sh  = sh_i;
    logic[31:0] \sh32 ;
    (* src = "src/alu.spade:162,6" *)
    logic _e_2383;
    (* src = "src/alu.spade:163,27" *)
    logic[31:0] \right ;
    (* src = "src/alu.spade:164,36" *)
    logic[32:0] _e_2394;
    (* src = "src/alu.spade:164,30" *)
    logic[31:0] \inverted ;
    (* src = "src/alu.spade:165,27" *)
    logic[31:0] \left ;
    (* src = "src/alu.spade:166,5" *)
    logic[31:0] _e_2402;
    (* src = "src/alu.spade:162,3" *)
    logic[31:0] _e_2382;
    assign \sh32  = {27'b0, \sh };
    localparam[4:0] _e_2385 = 0;
    assign _e_2383 = \sh  == _e_2385;
    assign \right  = \x  >> \sh32 ;
    localparam[31:0] _e_2395 = 32'd32;
    assign _e_2394 = _e_2395 - \sh32 ;
    assign \inverted  = _e_2394[31:0];
    assign \left  = \x  << \inverted ;
    assign _e_2402 = \right  | \left ;
    assign _e_2382 = _e_2383 ? \x  : _e_2402;
    assign output__ = _e_2382;
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
    (* src = "src/alu.spade:174,9" *)
    logic[42:0] _e_2409;
    (* src = "src/alu.spade:174,14" *)
    logic[31:0] \x ;
    logic _e_8110;
    logic _e_8112;
    logic _e_8114;
    logic _e_8115;
    (* src = "src/alu.spade:174,35" *)
    logic[32:0] _e_2411;
    (* src = "src/alu.spade:175,9" *)
    logic[43:0] \_ ;
    (* src = "src/alu.spade:176,13" *)
    logic[42:0] _e_2417;
    (* src = "src/alu.spade:176,18" *)
    logic[31:0] x_n1;
    logic _e_8118;
    logic _e_8120;
    logic _e_8122;
    logic _e_8123;
    (* src = "src/alu.spade:176,39" *)
    logic[32:0] _e_2419;
    (* src = "src/alu.spade:177,13" *)
    logic[43:0] __n1;
    (* src = "src/alu.spade:177,18" *)
    logic[32:0] _e_2422;
    (* src = "src/alu.spade:175,14" *)
    logic[32:0] _e_2414;
    (* src = "src/alu.spade:173,5" *)
    logic[32:0] _e_2406;
    assign _e_2409 = \m1 [42:0];
    assign \x  = _e_2409[36:5];
    assign _e_8110 = \m1 [43] == 1'd1;
    assign _e_8112 = _e_2409[42:37] == 6'd1;
    localparam[0:0] _e_8113 = 1;
    assign _e_8114 = _e_8112 && _e_8113;
    assign _e_8115 = _e_8110 && _e_8114;
    assign _e_2411 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8116 = 1;
    assign _e_2417 = \m0 [42:0];
    assign x_n1 = _e_2417[36:5];
    assign _e_8118 = \m0 [43] == 1'd1;
    assign _e_8120 = _e_2417[42:37] == 6'd1;
    localparam[0:0] _e_8121 = 1;
    assign _e_8122 = _e_8120 && _e_8121;
    assign _e_8123 = _e_8118 && _e_8122;
    assign _e_2419 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8124 = 1;
    assign _e_2422 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8123, _e_8124})
            2'b1?: _e_2414 = _e_2419;
            2'b01: _e_2414 = _e_2422;
            2'b?: _e_2414 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8115, _e_8116})
            2'b1?: _e_2406 = _e_2411;
            2'b01: _e_2406 = _e_2414;
            2'b?: _e_2406 = 33'dx;
        endcase
    end
    assign output__ = _e_2406;
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
    (* src = "src/alu.spade:183,9" *)
    logic[42:0] _e_2428;
    (* src = "src/alu.spade:183,14" *)
    logic[4:0] \op ;
    (* src = "src/alu.spade:183,14" *)
    logic[31:0] \x ;
    logic _e_8126;
    logic _e_8128;
    logic _e_8131;
    logic _e_8132;
    logic _e_8133;
    (* src = "src/alu.spade:183,44" *)
    logic[36:0] _e_2431;
    (* src = "src/alu.spade:183,39" *)
    logic[37:0] _e_2430;
    (* src = "src/alu.spade:184,9" *)
    logic[43:0] \_ ;
    (* src = "src/alu.spade:185,13" *)
    logic[42:0] _e_2439;
    (* src = "src/alu.spade:185,18" *)
    logic[4:0] op_n1;
    (* src = "src/alu.spade:185,18" *)
    logic[31:0] x_n1;
    logic _e_8136;
    logic _e_8138;
    logic _e_8141;
    logic _e_8142;
    logic _e_8143;
    (* src = "src/alu.spade:185,48" *)
    logic[36:0] _e_2442;
    (* src = "src/alu.spade:185,43" *)
    logic[37:0] _e_2441;
    (* src = "src/alu.spade:186,13" *)
    logic[43:0] __n1;
    (* src = "src/alu.spade:186,18" *)
    logic[37:0] _e_2446;
    (* src = "src/alu.spade:184,14" *)
    logic[37:0] _e_2435;
    (* src = "src/alu.spade:182,5" *)
    logic[37:0] _e_2424;
    assign _e_2428 = \m1 [42:0];
    assign \op  = _e_2428[36:32];
    assign \x  = _e_2428[31:0];
    assign _e_8126 = \m1 [43] == 1'd1;
    assign _e_8128 = _e_2428[42:37] == 6'd2;
    localparam[0:0] _e_8129 = 1;
    localparam[0:0] _e_8130 = 1;
    assign _e_8131 = _e_8128 && _e_8129;
    assign _e_8132 = _e_8131 && _e_8130;
    assign _e_8133 = _e_8126 && _e_8132;
    assign _e_2431 = {\op , \x };
    assign _e_2430 = {1'd1, _e_2431};
    assign \_  = \m1 ;
    localparam[0:0] _e_8134 = 1;
    assign _e_2439 = \m0 [42:0];
    assign op_n1 = _e_2439[36:32];
    assign x_n1 = _e_2439[31:0];
    assign _e_8136 = \m0 [43] == 1'd1;
    assign _e_8138 = _e_2439[42:37] == 6'd2;
    localparam[0:0] _e_8139 = 1;
    localparam[0:0] _e_8140 = 1;
    assign _e_8141 = _e_8138 && _e_8139;
    assign _e_8142 = _e_8141 && _e_8140;
    assign _e_8143 = _e_8136 && _e_8142;
    assign _e_2442 = {op_n1, x_n1};
    assign _e_2441 = {1'd1, _e_2442};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8144 = 1;
    assign _e_2446 = {1'd0, 37'bX};
    always_comb begin
        priority casez ({_e_8143, _e_8144})
            2'b1?: _e_2435 = _e_2441;
            2'b01: _e_2435 = _e_2446;
            2'b?: _e_2435 = 38'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8133, _e_8134})
            2'b1?: _e_2424 = _e_2430;
            2'b01: _e_2424 = _e_2435;
            2'b?: _e_2424 = 38'dx;
        endcase
    end
    assign output__ = _e_2424;
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
    logic _e_8146;
    logic _e_8148;
    logic _e_8150;
    (* src = "src/modadd.spade:19,45" *)
    logic[31:0] _e_2452;
    (* src = "src/modadd.spade:19,14" *)
    reg[31:0] \base ;
    (* src = "src/modadd.spade:25,9" *)
    logic[31:0] v_n1;
    logic _e_8152;
    logic _e_8154;
    logic _e_8156;
    (* src = "src/modadd.spade:24,45" *)
    logic[31:0] _e_2463;
    (* src = "src/modadd.spade:24,14" *)
    reg[31:0] \mask ;
    (* src = "src/modadd.spade:33,13" *)
    logic[31:0] v_n2;
    logic _e_8158;
    logic _e_8160;
    logic _e_8162;
    (* src = "src/modadd.spade:32,27" *)
    logic[31:0] \current_ptr ;
    (* src = "src/modadd.spade:38,13" *)
    logic[31:0] \stride ;
    logic _e_8164;
    logic _e_8166;
    (* src = "src/modadd.spade:41,36" *)
    logic[32:0] _e_2490;
    (* src = "src/modadd.spade:41,30" *)
    logic[31:0] _e_2489;
    (* src = "src/modadd.spade:41,30" *)
    logic[31:0] \offset ;
    (* src = "src/modadd.spade:42,17" *)
    logic[31:0] _e_2495;
    logic _e_8168;
    (* src = "src/modadd.spade:37,9" *)
    logic[31:0] _e_2483;
    (* src = "src/modadd.spade:31,14" *)
    reg[31:0] \ptr ;
    (* src = "src/modadd.spade:49,47" *)
    logic[32:0] _e_2503;
    (* src = "src/modadd.spade:51,13" *)
    logic[31:0] v_n3;
    logic _e_8170;
    logic _e_8172;
    logic _e_8174;
    (* src = "src/modadd.spade:50,27" *)
    logic[31:0] current_ptr_n1;
    (* src = "src/modadd.spade:56,13" *)
    logic[31:0] stride_n1;
    logic _e_8176;
    logic _e_8178;
    (* src = "src/modadd.spade:57,36" *)
    logic[32:0] _e_2520;
    (* src = "src/modadd.spade:57,30" *)
    logic[31:0] _e_2519;
    (* src = "src/modadd.spade:57,30" *)
    logic[31:0] offset_n1;
    (* src = "src/modadd.spade:58,22" *)
    logic[31:0] _e_2526;
    (* src = "src/modadd.spade:58,17" *)
    logic[32:0] _e_2525;
    logic _e_8180;
    (* src = "src/modadd.spade:60,21" *)
    logic[32:0] _e_2530;
    (* src = "src/modadd.spade:55,9" *)
    logic[32:0] _e_2513;
    (* src = "src/modadd.spade:49,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_2451 = 32'd0;
    assign \v  = \set_base [31:0];
    assign _e_8146 = \set_base [32] == 1'd1;
    localparam[0:0] _e_8147 = 1;
    assign _e_8148 = _e_8146 && _e_8147;
    assign _e_8150 = \set_base [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8148, _e_8150})
            2'b1?: _e_2452 = \v ;
            2'b01: _e_2452 = \base ;
            2'b?: _e_2452 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \base  <= _e_2451;
        end
        else begin
            \base  <= _e_2452;
        end
    end
    localparam[31:0] _e_2462 = 32'd0;
    assign v_n1 = \set_mask [31:0];
    assign _e_8152 = \set_mask [32] == 1'd1;
    localparam[0:0] _e_8153 = 1;
    assign _e_8154 = _e_8152 && _e_8153;
    assign _e_8156 = \set_mask [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8154, _e_8156})
            2'b1?: _e_2463 = v_n1;
            2'b01: _e_2463 = \mask ;
            2'b?: _e_2463 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \mask  <= _e_2462;
        end
        else begin
            \mask  <= _e_2463;
        end
    end
    localparam[31:0] _e_2473 = 32'd0;
    assign v_n2 = \set_ptr [31:0];
    assign _e_8158 = \set_ptr [32] == 1'd1;
    localparam[0:0] _e_8159 = 1;
    assign _e_8160 = _e_8158 && _e_8159;
    assign _e_8162 = \set_ptr [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8160, _e_8162})
            2'b1?: \current_ptr  = v_n2;
            2'b01: \current_ptr  = \ptr ;
            2'b?: \current_ptr  = 32'dx;
        endcase
    end
    assign \stride  = \trig_stride [31:0];
    assign _e_8164 = \trig_stride [32] == 1'd1;
    localparam[0:0] _e_8165 = 1;
    assign _e_8166 = _e_8164 && _e_8165;
    assign _e_2490 = \current_ptr  + \stride ;
    assign _e_2489 = _e_2490[31:0];
    assign \offset  = _e_2489 & \mask ;
    assign _e_2495 = \base  | \offset ;
    assign _e_8168 = \trig_stride [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8166, _e_8168})
            2'b1?: _e_2483 = _e_2495;
            2'b01: _e_2483 = \current_ptr ;
            2'b?: _e_2483 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \ptr  <= _e_2473;
        end
        else begin
            \ptr  <= _e_2483;
        end
    end
    assign _e_2503 = {1'd0, 32'bX};
    assign v_n3 = \set_ptr [31:0];
    assign _e_8170 = \set_ptr [32] == 1'd1;
    localparam[0:0] _e_8171 = 1;
    assign _e_8172 = _e_8170 && _e_8171;
    assign _e_8174 = \set_ptr [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8172, _e_8174})
            2'b1?: current_ptr_n1 = v_n3;
            2'b01: current_ptr_n1 = \ptr ;
            2'b?: current_ptr_n1 = 32'dx;
        endcase
    end
    assign stride_n1 = \trig_stride [31:0];
    assign _e_8176 = \trig_stride [32] == 1'd1;
    localparam[0:0] _e_8177 = 1;
    assign _e_8178 = _e_8176 && _e_8177;
    assign _e_2520 = current_ptr_n1 + stride_n1;
    assign _e_2519 = _e_2520[31:0];
    assign offset_n1 = _e_2519 & \mask ;
    assign _e_2526 = \base  | offset_n1;
    assign _e_2525 = {1'd1, _e_2526};
    assign _e_8180 = \trig_stride [32] == 1'd0;
    assign _e_2530 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8178, _e_8180})
            2'b1?: _e_2513 = _e_2525;
            2'b01: _e_2513 = _e_2530;
            2'b?: _e_2513 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_2503;
        end
        else begin
            \res  <= _e_2513;
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
    logic[42:0] _e_2536;
    (* src = "src/modadd.spade:71,14" *)
    logic[31:0] \a ;
    logic _e_8182;
    logic _e_8184;
    logic _e_8186;
    logic _e_8187;
    (* src = "src/modadd.spade:71,35" *)
    logic[32:0] _e_2538;
    (* src = "src/modadd.spade:72,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:72,25" *)
    logic[42:0] _e_2544;
    (* src = "src/modadd.spade:72,30" *)
    logic[31:0] a_n1;
    logic _e_8190;
    logic _e_8192;
    logic _e_8194;
    logic _e_8195;
    (* src = "src/modadd.spade:72,51" *)
    logic[32:0] _e_2546;
    (* src = "src/modadd.spade:72,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:72,65" *)
    logic[32:0] _e_2549;
    (* src = "src/modadd.spade:72,14" *)
    logic[32:0] _e_2541;
    (* src = "src/modadd.spade:70,5" *)
    logic[32:0] _e_2533;
    assign _e_2536 = \m1 [42:0];
    assign \a  = _e_2536[36:5];
    assign _e_8182 = \m1 [43] == 1'd1;
    assign _e_8184 = _e_2536[42:37] == 6'd30;
    localparam[0:0] _e_8185 = 1;
    assign _e_8186 = _e_8184 && _e_8185;
    assign _e_8187 = _e_8182 && _e_8186;
    assign _e_2538 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8188 = 1;
    assign _e_2544 = \m0 [42:0];
    assign a_n1 = _e_2544[36:5];
    assign _e_8190 = \m0 [43] == 1'd1;
    assign _e_8192 = _e_2544[42:37] == 6'd30;
    localparam[0:0] _e_8193 = 1;
    assign _e_8194 = _e_8192 && _e_8193;
    assign _e_8195 = _e_8190 && _e_8194;
    assign _e_2546 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8196 = 1;
    assign _e_2549 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8195, _e_8196})
            2'b1?: _e_2541 = _e_2546;
            2'b01: _e_2541 = _e_2549;
            2'b?: _e_2541 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8187, _e_8188})
            2'b1?: _e_2533 = _e_2538;
            2'b01: _e_2533 = _e_2541;
            2'b?: _e_2533 = 33'dx;
        endcase
    end
    assign output__ = _e_2533;
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
    logic[42:0] _e_2554;
    (* src = "src/modadd.spade:78,14" *)
    logic[31:0] \a ;
    logic _e_8198;
    logic _e_8200;
    logic _e_8202;
    logic _e_8203;
    (* src = "src/modadd.spade:78,35" *)
    logic[32:0] _e_2556;
    (* src = "src/modadd.spade:79,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:79,25" *)
    logic[42:0] _e_2562;
    (* src = "src/modadd.spade:79,30" *)
    logic[31:0] a_n1;
    logic _e_8206;
    logic _e_8208;
    logic _e_8210;
    logic _e_8211;
    (* src = "src/modadd.spade:79,51" *)
    logic[32:0] _e_2564;
    (* src = "src/modadd.spade:79,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:79,65" *)
    logic[32:0] _e_2567;
    (* src = "src/modadd.spade:79,14" *)
    logic[32:0] _e_2559;
    (* src = "src/modadd.spade:77,5" *)
    logic[32:0] _e_2551;
    assign _e_2554 = \m1 [42:0];
    assign \a  = _e_2554[36:5];
    assign _e_8198 = \m1 [43] == 1'd1;
    assign _e_8200 = _e_2554[42:37] == 6'd31;
    localparam[0:0] _e_8201 = 1;
    assign _e_8202 = _e_8200 && _e_8201;
    assign _e_8203 = _e_8198 && _e_8202;
    assign _e_2556 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8204 = 1;
    assign _e_2562 = \m0 [42:0];
    assign a_n1 = _e_2562[36:5];
    assign _e_8206 = \m0 [43] == 1'd1;
    assign _e_8208 = _e_2562[42:37] == 6'd31;
    localparam[0:0] _e_8209 = 1;
    assign _e_8210 = _e_8208 && _e_8209;
    assign _e_8211 = _e_8206 && _e_8210;
    assign _e_2564 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8212 = 1;
    assign _e_2567 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8211, _e_8212})
            2'b1?: _e_2559 = _e_2564;
            2'b01: _e_2559 = _e_2567;
            2'b?: _e_2559 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8203, _e_8204})
            2'b1?: _e_2551 = _e_2556;
            2'b01: _e_2551 = _e_2559;
            2'b?: _e_2551 = 33'dx;
        endcase
    end
    assign output__ = _e_2551;
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
    logic[42:0] _e_2572;
    (* src = "src/modadd.spade:85,14" *)
    logic[31:0] \a ;
    logic _e_8214;
    logic _e_8216;
    logic _e_8218;
    logic _e_8219;
    (* src = "src/modadd.spade:85,34" *)
    logic[32:0] _e_2574;
    (* src = "src/modadd.spade:86,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:86,25" *)
    logic[42:0] _e_2580;
    (* src = "src/modadd.spade:86,30" *)
    logic[31:0] a_n1;
    logic _e_8222;
    logic _e_8224;
    logic _e_8226;
    logic _e_8227;
    (* src = "src/modadd.spade:86,50" *)
    logic[32:0] _e_2582;
    (* src = "src/modadd.spade:86,59" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:86,64" *)
    logic[32:0] _e_2585;
    (* src = "src/modadd.spade:86,14" *)
    logic[32:0] _e_2577;
    (* src = "src/modadd.spade:84,5" *)
    logic[32:0] _e_2569;
    assign _e_2572 = \m1 [42:0];
    assign \a  = _e_2572[36:5];
    assign _e_8214 = \m1 [43] == 1'd1;
    assign _e_8216 = _e_2572[42:37] == 6'd32;
    localparam[0:0] _e_8217 = 1;
    assign _e_8218 = _e_8216 && _e_8217;
    assign _e_8219 = _e_8214 && _e_8218;
    assign _e_2574 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8220 = 1;
    assign _e_2580 = \m0 [42:0];
    assign a_n1 = _e_2580[36:5];
    assign _e_8222 = \m0 [43] == 1'd1;
    assign _e_8224 = _e_2580[42:37] == 6'd32;
    localparam[0:0] _e_8225 = 1;
    assign _e_8226 = _e_8224 && _e_8225;
    assign _e_8227 = _e_8222 && _e_8226;
    assign _e_2582 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8228 = 1;
    assign _e_2585 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8227, _e_8228})
            2'b1?: _e_2577 = _e_2582;
            2'b01: _e_2577 = _e_2585;
            2'b?: _e_2577 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8219, _e_8220})
            2'b1?: _e_2569 = _e_2574;
            2'b01: _e_2569 = _e_2577;
            2'b?: _e_2569 = 33'dx;
        endcase
    end
    assign output__ = _e_2569;
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
    logic[42:0] _e_2590;
    (* src = "src/modadd.spade:92,14" *)
    logic[31:0] \a ;
    logic _e_8230;
    logic _e_8232;
    logic _e_8234;
    logic _e_8235;
    (* src = "src/modadd.spade:92,35" *)
    logic[32:0] _e_2592;
    (* src = "src/modadd.spade:93,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:93,25" *)
    logic[42:0] _e_2598;
    (* src = "src/modadd.spade:93,30" *)
    logic[31:0] a_n1;
    logic _e_8238;
    logic _e_8240;
    logic _e_8242;
    logic _e_8243;
    (* src = "src/modadd.spade:93,51" *)
    logic[32:0] _e_2600;
    (* src = "src/modadd.spade:93,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:93,65" *)
    logic[32:0] _e_2603;
    (* src = "src/modadd.spade:93,14" *)
    logic[32:0] _e_2595;
    (* src = "src/modadd.spade:91,5" *)
    logic[32:0] _e_2587;
    assign _e_2590 = \m1 [42:0];
    assign \a  = _e_2590[36:5];
    assign _e_8230 = \m1 [43] == 1'd1;
    assign _e_8232 = _e_2590[42:37] == 6'd33;
    localparam[0:0] _e_8233 = 1;
    assign _e_8234 = _e_8232 && _e_8233;
    assign _e_8235 = _e_8230 && _e_8234;
    assign _e_2592 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8236 = 1;
    assign _e_2598 = \m0 [42:0];
    assign a_n1 = _e_2598[36:5];
    assign _e_8238 = \m0 [43] == 1'd1;
    assign _e_8240 = _e_2598[42:37] == 6'd33;
    localparam[0:0] _e_8241 = 1;
    assign _e_8242 = _e_8240 && _e_8241;
    assign _e_8243 = _e_8238 && _e_8242;
    assign _e_2600 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8244 = 1;
    assign _e_2603 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8243, _e_8244})
            2'b1?: _e_2595 = _e_2600;
            2'b01: _e_2595 = _e_2603;
            2'b?: _e_2595 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8235, _e_8236})
            2'b1?: _e_2587 = _e_2592;
            2'b01: _e_2587 = _e_2595;
            2'b?: _e_2587 = 33'dx;
        endcase
    end
    assign output__ = _e_2587;
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
    logic[32:0] _e_2614;
    (* src = "src/uart_in.spade:19,7" *)
    logic[31:0] \b ;
    logic _e_8246;
    logic _e_8248;
    logic[31:0] _e_2620;
    (* src = "src/uart_in.spade:19,18" *)
    logic[32:0] _e_2619;
    logic _e_8250;
    (* src = "src/uart_in.spade:20,15" *)
    logic[32:0] _e_2623;
    (* src = "src/uart_in.spade:18,56" *)
    logic[32:0] _e_2615;
    (* src = "src/uart_in.spade:18,14" *)
    reg[32:0] data_n1;
    (* src = "src/uart_in.spade:17,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\uart_byte ), .pop_i(\pop ), .output__(\data ));
    assign _e_2614 = {1'd0, 32'bX};
    assign \b  = data_n1[31:0];
    assign _e_8246 = data_n1[32] == 1'd1;
    localparam[0:0] _e_8247 = 1;
    assign _e_8248 = _e_8246 && _e_8247;
    assign _e_2620 = \b ;
    assign _e_2619 = {1'd1, _e_2620};
    assign _e_8250 = data_n1[32] == 1'd0;
    assign _e_2623 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8248, _e_8250})
            2'b1?: _e_2615 = _e_2619;
            2'b01: _e_2615 = _e_2623;
            2'b?: _e_2615 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2614;
        end
        else begin
            data_n1 <= _e_2615;
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
    logic _e_2630;
    (* src = "src/uart_in.spade:39,16" *)
    logic[14:0] \data ;
    (* src = "src/uart_in.spade:40,47" *)
    logic[8:0] _e_2636;
    (* src = "src/uart_in.spade:41,7" *)
    logic[7:0] \b ;
    logic _e_8252;
    logic _e_8254;
    (* src = "src/uart_in.spade:41,18" *)
    logic[8:0] _e_2641;
    logic _e_8256;
    (* src = "src/uart_in.spade:42,15" *)
    logic[8:0] _e_2644;
    (* src = "src/uart_in.spade:40,55" *)
    logic[8:0] _e_2637;
    (* src = "src/uart_in.spade:40,14" *)
    reg[8:0] data_n1;
    assign _e_2630 = !\uart_tx_busy ;
    (* src = "src/uart_in.spade:39,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\byte_to_write ), .pop_i(_e_2630), .output__(\data ));
    assign _e_2636 = {1'd0, 8'bX};
    assign \b  = data_n1[7:0];
    assign _e_8252 = data_n1[8] == 1'd1;
    localparam[0:0] _e_8253 = 1;
    assign _e_8254 = _e_8252 && _e_8253;
    assign _e_2641 = {1'd1, \b };
    assign _e_8256 = data_n1[8] == 1'd0;
    assign _e_2644 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8254, _e_8256})
            2'b1?: _e_2637 = _e_2641;
            2'b01: _e_2637 = _e_2644;
            2'b?: _e_2637 = 9'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2636;
        end
        else begin
            data_n1 <= _e_2637;
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
    logic[42:0] _e_2651;
    logic _e_8258;
    logic _e_8260;
    logic _e_8261;
    (* src = "src/uart_in.spade:53,9" *)
    logic[43:0] \_ ;
    (* src = "src/uart_in.spade:54,13" *)
    logic[42:0] _e_2657;
    logic _e_8264;
    logic _e_8266;
    logic _e_8267;
    (* src = "src/uart_in.spade:55,13" *)
    logic[43:0] __n1;
    (* src = "src/uart_in.spade:53,14" *)
    logic _e_2655;
    (* src = "src/uart_in.spade:51,5" *)
    logic _e_2649;
    assign _e_2651 = \m1 [42:0];
    assign _e_8258 = \m1 [43] == 1'd1;
    assign _e_8260 = _e_2651[42:37] == 6'd41;
    assign _e_8261 = _e_8258 && _e_8260;
    localparam[0:0] _e_2653 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_8262 = 1;
    assign _e_2657 = \m0 [42:0];
    assign _e_8264 = \m0 [43] == 1'd1;
    assign _e_8266 = _e_2657[42:37] == 6'd41;
    assign _e_8267 = _e_8264 && _e_8266;
    localparam[0:0] _e_2659 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_8268 = 1;
    localparam[0:0] _e_2661 = 0;
    always_comb begin
        priority casez ({_e_8267, _e_8268})
            2'b1?: _e_2655 = _e_2659;
            2'b01: _e_2655 = _e_2661;
            2'b?: _e_2655 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8261, _e_8262})
            2'b1?: _e_2649 = _e_2653;
            2'b01: _e_2649 = _e_2655;
            2'b?: _e_2649 = 1'dx;
        endcase
    end
    assign output__ = _e_2649;
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
    logic[42:0] _e_2666;
    (* src = "src/uart_in.spade:61,14" *)
    logic[7:0] \x ;
    logic _e_8270;
    logic _e_8272;
    logic _e_8274;
    logic _e_8275;
    (* src = "src/uart_in.spade:61,36" *)
    logic[8:0] _e_2668;
    (* src = "src/uart_in.spade:62,9" *)
    logic[43:0] \_ ;
    (* src = "src/uart_in.spade:63,13" *)
    logic[42:0] _e_2674;
    (* src = "src/uart_in.spade:63,18" *)
    logic[7:0] x_n1;
    logic _e_8278;
    logic _e_8280;
    logic _e_8282;
    logic _e_8283;
    (* src = "src/uart_in.spade:63,40" *)
    logic[8:0] _e_2676;
    (* src = "src/uart_in.spade:64,13" *)
    logic[43:0] __n1;
    (* src = "src/uart_in.spade:64,18" *)
    logic[8:0] _e_2679;
    (* src = "src/uart_in.spade:62,14" *)
    logic[8:0] _e_2671;
    (* src = "src/uart_in.spade:60,5" *)
    logic[8:0] _e_2663;
    assign _e_2666 = \m1 [42:0];
    assign \x  = _e_2666[36:29];
    assign _e_8270 = \m1 [43] == 1'd1;
    assign _e_8272 = _e_2666[42:37] == 6'd38;
    localparam[0:0] _e_8273 = 1;
    assign _e_8274 = _e_8272 && _e_8273;
    assign _e_8275 = _e_8270 && _e_8274;
    assign _e_2668 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8276 = 1;
    assign _e_2674 = \m0 [42:0];
    assign x_n1 = _e_2674[36:29];
    assign _e_8278 = \m0 [43] == 1'd1;
    assign _e_8280 = _e_2674[42:37] == 6'd38;
    localparam[0:0] _e_8281 = 1;
    assign _e_8282 = _e_8280 && _e_8281;
    assign _e_8283 = _e_8278 && _e_8282;
    assign _e_2676 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8284 = 1;
    assign _e_2679 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8283, _e_8284})
            2'b1?: _e_2671 = _e_2676;
            2'b01: _e_2671 = _e_2679;
            2'b?: _e_2671 = 9'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8275, _e_8276})
            2'b1?: _e_2663 = _e_2668;
            2'b01: _e_2663 = _e_2671;
            2'b?: _e_2663 = 9'dx;
        endcase
    end
    assign output__ = _e_2663;
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
    logic _e_8286;
    logic _e_8288;
    logic _e_8290;
    (* src = "src/cmp.spade:28,42" *)
    logic[31:0] _e_2685;
    (* src = "src/cmp.spade:28,14" *)
    reg[31:0] \a ;
    (* src = "src/cmp.spade:35,9" *)
    logic[34:0] _e_2696;
    (* src = "src/cmp.spade:35,14" *)
    logic[2:0] _e_2694;
    (* src = "src/cmp.spade:35,14" *)
    logic[31:0] \b ;
    logic _e_8292;
    logic _e_8295;
    logic _e_8297;
    logic _e_8298;
    (* src = "src/cmp.spade:35,47" *)
    logic _e_2700;
    (* src = "src/cmp.spade:35,40" *)
    logic[31:0] _e_2699;
    (* src = "src/cmp.spade:35,35" *)
    logic[32:0] _e_2698;
    (* src = "src/cmp.spade:36,9" *)
    logic[34:0] _e_2705;
    (* src = "src/cmp.spade:36,14" *)
    logic[2:0] _e_2703;
    (* src = "src/cmp.spade:36,14" *)
    logic[31:0] b_n1;
    logic _e_8300;
    logic _e_8303;
    logic _e_8305;
    logic _e_8306;
    (* src = "src/cmp.spade:36,47" *)
    logic _e_2709;
    (* src = "src/cmp.spade:36,40" *)
    logic[31:0] _e_2708;
    (* src = "src/cmp.spade:36,35" *)
    logic[32:0] _e_2707;
    (* src = "src/cmp.spade:37,9" *)
    logic[34:0] _e_2714;
    (* src = "src/cmp.spade:37,14" *)
    logic[2:0] _e_2712;
    (* src = "src/cmp.spade:37,14" *)
    logic[31:0] b_n2;
    logic _e_8308;
    logic _e_8311;
    logic _e_8313;
    logic _e_8314;
    (* src = "src/cmp.spade:37,47" *)
    logic _e_2718;
    (* src = "src/cmp.spade:37,40" *)
    logic[31:0] _e_2717;
    (* src = "src/cmp.spade:37,35" *)
    logic[32:0] _e_2716;
    (* src = "src/cmp.spade:38,9" *)
    logic[34:0] _e_2723;
    (* src = "src/cmp.spade:38,14" *)
    logic[2:0] _e_2721;
    (* src = "src/cmp.spade:38,14" *)
    logic[31:0] b_n3;
    logic _e_8316;
    logic _e_8319;
    logic _e_8321;
    logic _e_8322;
    (* src = "src/cmp.spade:38,47" *)
    logic _e_2728;
    (* src = "src/cmp.spade:38,66" *)
    logic _e_2731;
    (* src = "src/cmp.spade:38,47" *)
    logic _e_2727;
    (* src = "src/cmp.spade:38,40" *)
    logic[31:0] _e_2726;
    (* src = "src/cmp.spade:38,35" *)
    logic[32:0] _e_2725;
    (* src = "src/cmp.spade:39,9" *)
    logic[34:0] _e_2736;
    (* src = "src/cmp.spade:39,14" *)
    logic[2:0] _e_2734;
    (* src = "src/cmp.spade:39,14" *)
    logic[31:0] b_n4;
    logic _e_8324;
    logic _e_8327;
    logic _e_8329;
    logic _e_8330;
    (* src = "src/cmp.spade:39,47" *)
    logic _e_2740;
    (* src = "src/cmp.spade:39,40" *)
    logic[31:0] _e_2739;
    (* src = "src/cmp.spade:39,35" *)
    logic[32:0] _e_2738;
    (* src = "src/cmp.spade:40,9" *)
    logic[34:0] _e_2745;
    (* src = "src/cmp.spade:40,14" *)
    logic[2:0] _e_2743;
    (* src = "src/cmp.spade:40,14" *)
    logic[31:0] b_n5;
    logic _e_8332;
    logic _e_8335;
    logic _e_8337;
    logic _e_8338;
    (* src = "src/cmp.spade:40,47" *)
    logic _e_2750;
    (* src = "src/cmp.spade:40,58" *)
    logic _e_2753;
    (* src = "src/cmp.spade:40,47" *)
    logic _e_2749;
    (* src = "src/cmp.spade:40,40" *)
    logic[31:0] _e_2748;
    (* src = "src/cmp.spade:40,35" *)
    logic[32:0] _e_2747;
    logic _e_8340;
    (* src = "src/cmp.spade:41,35" *)
    logic[32:0] _e_2757;
    (* src = "src/cmp.spade:34,36" *)
    logic[32:0] \result ;
    (* src = "src/cmp.spade:45,51" *)
    logic[32:0] _e_2762;
    (* src = "src/cmp.spade:45,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2684 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_8286 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_8287 = 1;
    assign _e_8288 = _e_8286 && _e_8287;
    assign _e_8290 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8288, _e_8290})
            2'b1?: _e_2685 = \v ;
            2'b01: _e_2685 = \a ;
            2'b?: _e_2685 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \a  <= _e_2684;
        end
        else begin
            \a  <= _e_2685;
        end
    end
    assign _e_2696 = \trig [34:0];
    assign _e_2694 = _e_2696[34:32];
    assign \b  = _e_2696[31:0];
    assign _e_8292 = \trig [35] == 1'd1;
    assign _e_8295 = _e_2694[2:0] == 3'd0;
    localparam[0:0] _e_8296 = 1;
    assign _e_8297 = _e_8295 && _e_8296;
    assign _e_8298 = _e_8292 && _e_8297;
    assign _e_2700 = \a  == \b ;
    (* src = "src/cmp.spade:35,40" *)
    \tta::cmp::to_u32  to_u32_0(.x_i(_e_2700), .output__(_e_2699));
    assign _e_2698 = {1'd1, _e_2699};
    assign _e_2705 = \trig [34:0];
    assign _e_2703 = _e_2705[34:32];
    assign b_n1 = _e_2705[31:0];
    assign _e_8300 = \trig [35] == 1'd1;
    assign _e_8303 = _e_2703[2:0] == 3'd1;
    localparam[0:0] _e_8304 = 1;
    assign _e_8305 = _e_8303 && _e_8304;
    assign _e_8306 = _e_8300 && _e_8305;
    assign _e_2709 = \a  != b_n1;
    (* src = "src/cmp.spade:36,40" *)
    \tta::cmp::to_u32  to_u32_1(.x_i(_e_2709), .output__(_e_2708));
    assign _e_2707 = {1'd1, _e_2708};
    assign _e_2714 = \trig [34:0];
    assign _e_2712 = _e_2714[34:32];
    assign b_n2 = _e_2714[31:0];
    assign _e_8308 = \trig [35] == 1'd1;
    assign _e_8311 = _e_2712[2:0] == 3'd2;
    localparam[0:0] _e_8312 = 1;
    assign _e_8313 = _e_8311 && _e_8312;
    assign _e_8314 = _e_8308 && _e_8313;
    (* src = "src/cmp.spade:37,47" *)
    \tta::cmp::signed_lt  signed_lt_0(.a_i(\a ), .b_i(b_n2), .output__(_e_2718));
    (* src = "src/cmp.spade:37,40" *)
    \tta::cmp::to_u32  to_u32_2(.x_i(_e_2718), .output__(_e_2717));
    assign _e_2716 = {1'd1, _e_2717};
    assign _e_2723 = \trig [34:0];
    assign _e_2721 = _e_2723[34:32];
    assign b_n3 = _e_2723[31:0];
    assign _e_8316 = \trig [35] == 1'd1;
    assign _e_8319 = _e_2721[2:0] == 3'd3;
    localparam[0:0] _e_8320 = 1;
    assign _e_8321 = _e_8319 && _e_8320;
    assign _e_8322 = _e_8316 && _e_8321;
    (* src = "src/cmp.spade:38,47" *)
    \tta::cmp::signed_lt  signed_lt_1(.a_i(\a ), .b_i(b_n3), .output__(_e_2728));
    assign _e_2731 = \a  == b_n3;
    assign _e_2727 = _e_2728 || _e_2731;
    (* src = "src/cmp.spade:38,40" *)
    \tta::cmp::to_u32  to_u32_3(.x_i(_e_2727), .output__(_e_2726));
    assign _e_2725 = {1'd1, _e_2726};
    assign _e_2736 = \trig [34:0];
    assign _e_2734 = _e_2736[34:32];
    assign b_n4 = _e_2736[31:0];
    assign _e_8324 = \trig [35] == 1'd1;
    assign _e_8327 = _e_2734[2:0] == 3'd4;
    localparam[0:0] _e_8328 = 1;
    assign _e_8329 = _e_8327 && _e_8328;
    assign _e_8330 = _e_8324 && _e_8329;
    assign _e_2740 = \a  < b_n4;
    (* src = "src/cmp.spade:39,40" *)
    \tta::cmp::to_u32  to_u32_4(.x_i(_e_2740), .output__(_e_2739));
    assign _e_2738 = {1'd1, _e_2739};
    assign _e_2745 = \trig [34:0];
    assign _e_2743 = _e_2745[34:32];
    assign b_n5 = _e_2745[31:0];
    assign _e_8332 = \trig [35] == 1'd1;
    assign _e_8335 = _e_2743[2:0] == 3'd5;
    localparam[0:0] _e_8336 = 1;
    assign _e_8337 = _e_8335 && _e_8336;
    assign _e_8338 = _e_8332 && _e_8337;
    assign _e_2750 = \a  < b_n5;
    assign _e_2753 = \a  == b_n5;
    assign _e_2749 = _e_2750 || _e_2753;
    (* src = "src/cmp.spade:40,40" *)
    \tta::cmp::to_u32  to_u32_5(.x_i(_e_2749), .output__(_e_2748));
    assign _e_2747 = {1'd1, _e_2748};
    assign _e_8340 = \trig [35] == 1'd0;
    assign _e_2757 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8298, _e_8306, _e_8314, _e_8322, _e_8330, _e_8338, _e_8340})
            7'b1??????: \result  = _e_2698;
            7'b01?????: \result  = _e_2707;
            7'b001????: \result  = _e_2716;
            7'b0001???: \result  = _e_2725;
            7'b00001??: \result  = _e_2738;
            7'b000001?: \result  = _e_2747;
            7'b0000001: \result  = _e_2757;
            7'b?: \result  = 33'dx;
        endcase
    end
    assign _e_2762 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_2762;
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
    logic[42:0] _e_2769;
    (* src = "src/cmp.spade:53,14" *)
    logic[31:0] \x ;
    logic _e_8342;
    logic _e_8344;
    logic _e_8346;
    logic _e_8347;
    (* src = "src/cmp.spade:53,35" *)
    logic[32:0] _e_2771;
    (* src = "src/cmp.spade:54,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmp.spade:55,13" *)
    logic[42:0] _e_2777;
    (* src = "src/cmp.spade:55,18" *)
    logic[31:0] x_n1;
    logic _e_8350;
    logic _e_8352;
    logic _e_8354;
    logic _e_8355;
    (* src = "src/cmp.spade:55,39" *)
    logic[32:0] _e_2779;
    (* src = "src/cmp.spade:56,13" *)
    logic[43:0] __n1;
    (* src = "src/cmp.spade:56,18" *)
    logic[32:0] _e_2782;
    (* src = "src/cmp.spade:54,14" *)
    logic[32:0] _e_2774;
    (* src = "src/cmp.spade:52,5" *)
    logic[32:0] _e_2766;
    assign _e_2769 = \m1 [42:0];
    assign \x  = _e_2769[36:5];
    assign _e_8342 = \m1 [43] == 1'd1;
    assign _e_8344 = _e_2769[42:37] == 6'd11;
    localparam[0:0] _e_8345 = 1;
    assign _e_8346 = _e_8344 && _e_8345;
    assign _e_8347 = _e_8342 && _e_8346;
    assign _e_2771 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8348 = 1;
    assign _e_2777 = \m0 [42:0];
    assign x_n1 = _e_2777[36:5];
    assign _e_8350 = \m0 [43] == 1'd1;
    assign _e_8352 = _e_2777[42:37] == 6'd11;
    localparam[0:0] _e_8353 = 1;
    assign _e_8354 = _e_8352 && _e_8353;
    assign _e_8355 = _e_8350 && _e_8354;
    assign _e_2779 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8356 = 1;
    assign _e_2782 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8355, _e_8356})
            2'b1?: _e_2774 = _e_2779;
            2'b01: _e_2774 = _e_2782;
            2'b?: _e_2774 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8347, _e_8348})
            2'b1?: _e_2766 = _e_2771;
            2'b01: _e_2766 = _e_2774;
            2'b?: _e_2766 = 33'dx;
        endcase
    end
    assign output__ = _e_2766;
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
    logic[42:0] _e_2788;
    (* src = "src/cmp.spade:62,14" *)
    logic[2:0] \op ;
    (* src = "src/cmp.spade:62,14" *)
    logic[31:0] \x ;
    logic _e_8358;
    logic _e_8360;
    logic _e_8363;
    logic _e_8364;
    logic _e_8365;
    (* src = "src/cmp.spade:62,44" *)
    logic[34:0] _e_2791;
    (* src = "src/cmp.spade:62,39" *)
    logic[35:0] _e_2790;
    (* src = "src/cmp.spade:63,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmp.spade:64,13" *)
    logic[42:0] _e_2799;
    (* src = "src/cmp.spade:64,18" *)
    logic[2:0] op_n1;
    (* src = "src/cmp.spade:64,18" *)
    logic[31:0] x_n1;
    logic _e_8368;
    logic _e_8370;
    logic _e_8373;
    logic _e_8374;
    logic _e_8375;
    (* src = "src/cmp.spade:64,48" *)
    logic[34:0] _e_2802;
    (* src = "src/cmp.spade:64,43" *)
    logic[35:0] _e_2801;
    (* src = "src/cmp.spade:65,13" *)
    logic[43:0] __n1;
    (* src = "src/cmp.spade:65,18" *)
    logic[35:0] _e_2806;
    (* src = "src/cmp.spade:63,14" *)
    logic[35:0] _e_2795;
    (* src = "src/cmp.spade:61,5" *)
    logic[35:0] _e_2784;
    assign _e_2788 = \m1 [42:0];
    assign \op  = _e_2788[36:34];
    assign \x  = _e_2788[33:2];
    assign _e_8358 = \m1 [43] == 1'd1;
    assign _e_8360 = _e_2788[42:37] == 6'd12;
    localparam[0:0] _e_8361 = 1;
    localparam[0:0] _e_8362 = 1;
    assign _e_8363 = _e_8360 && _e_8361;
    assign _e_8364 = _e_8363 && _e_8362;
    assign _e_8365 = _e_8358 && _e_8364;
    assign _e_2791 = {\op , \x };
    assign _e_2790 = {1'd1, _e_2791};
    assign \_  = \m1 ;
    localparam[0:0] _e_8366 = 1;
    assign _e_2799 = \m0 [42:0];
    assign op_n1 = _e_2799[36:34];
    assign x_n1 = _e_2799[33:2];
    assign _e_8368 = \m0 [43] == 1'd1;
    assign _e_8370 = _e_2799[42:37] == 6'd12;
    localparam[0:0] _e_8371 = 1;
    localparam[0:0] _e_8372 = 1;
    assign _e_8373 = _e_8370 && _e_8371;
    assign _e_8374 = _e_8373 && _e_8372;
    assign _e_8375 = _e_8368 && _e_8374;
    assign _e_2802 = {op_n1, x_n1};
    assign _e_2801 = {1'd1, _e_2802};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8376 = 1;
    assign _e_2806 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_8375, _e_8376})
            2'b1?: _e_2795 = _e_2801;
            2'b01: _e_2795 = _e_2806;
            2'b?: _e_2795 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8365, _e_8366})
            2'b1?: _e_2784 = _e_2790;
            2'b01: _e_2784 = _e_2795;
            2'b?: _e_2784 = 36'dx;
        endcase
    end
    assign output__ = _e_2784;
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
    logic[31:0] _e_2808;
    localparam[31:0] _e_2811 = 32'd1;
    localparam[31:0] _e_2813 = 32'd0;
    assign _e_2808 = \x  ? _e_2811 : _e_2813;
    assign output__ = _e_2808;
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
    logic[31:0] _e_2817;
    (* src = "src/cmp.spade:81,29" *)
    logic[31:0] _e_2816;
    (* src = "src/cmp.spade:81,23" *)
    logic \sa ;
    (* src = "src/cmp.spade:82,29" *)
    logic[31:0] _e_2824;
    (* src = "src/cmp.spade:82,29" *)
    logic[31:0] _e_2823;
    (* src = "src/cmp.spade:82,23" *)
    logic \sb ;
    (* src = "src/cmp.spade:83,8" *)
    logic _e_2830;
    (* src = "src/cmp.spade:84,9" *)
    logic _e_2834;
    (* src = "src/cmp.spade:86,9" *)
    logic _e_2838;
    (* src = "src/cmp.spade:83,5" *)
    logic _e_2829;
    localparam[31:0] _e_2819 = 32'd31;
    assign _e_2817 = \a  >> _e_2819;
    localparam[31:0] _e_2820 = 32'd1;
    assign _e_2816 = _e_2817 & _e_2820;
    assign \sa  = _e_2816[0:0];
    localparam[31:0] _e_2826 = 32'd31;
    assign _e_2824 = \b  >> _e_2826;
    localparam[31:0] _e_2827 = 32'd1;
    assign _e_2823 = _e_2824 & _e_2827;
    assign \sb  = _e_2823[0:0];
    assign _e_2830 = \sa  != \sb ;
    localparam[0:0] _e_2836 = 1;
    assign _e_2834 = \sa  == _e_2836;
    assign _e_2838 = \a  < \b ;
    assign _e_2829 = _e_2830 ? _e_2834 : _e_2838;
    assign output__ = _e_2829;
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
    logic[31:0] _e_2846;
    (* src = "src/gpi.spade:15,12" *)
    reg[31:0] \s1 ;
    (* src = "src/gpi.spade:16,12" *)
    reg[31:0] \s2 ;
    (* src = "src/gpi.spade:17,3" *)
    logic[32:0] _e_2853;
    localparam[31:0] _e_2845 = 32'd0;
    assign _e_2846 = {16'b0, \pins };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s1  <= _e_2845;
        end
        else begin
            \s1  <= _e_2846;
        end
    end
    localparam[31:0] _e_2851 = 32'd0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s2  <= _e_2851;
        end
        else begin
            \s2  <= \s1 ;
        end
    end
    assign _e_2853 = {1'd1, \s2 };
    assign output__ = _e_2853;
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
    logic[21:0] _e_2861;
    (* src = "src/pc.spade:17,9" *)
    logic[21:0] _e_2868;
    (* src = "src/pc.spade:17,9" *)
    logic[10:0] _e_2866;
    (* src = "src/pc.spade:17,10" *)
    logic[9:0] \bt_target ;
    (* src = "src/pc.spade:17,9" *)
    logic[10:0] \_ ;
    logic _e_8379;
    logic _e_8381;
    logic _e_8383;
    (* src = "src/pc.spade:18,9" *)
    logic[21:0] _e_2873;
    (* src = "src/pc.spade:18,9" *)
    logic[10:0] _e_2870;
    (* src = "src/pc.spade:18,9" *)
    logic[10:0] _e_2872;
    (* src = "src/pc.spade:18,16" *)
    logic[9:0] \pc_target ;
    logic _e_8386;
    logic _e_8388;
    logic _e_8390;
    logic _e_8391;
    (* src = "src/pc.spade:19,9" *)
    logic[21:0] _e_2877;
    (* src = "src/pc.spade:19,9" *)
    logic[10:0] _e_2875;
    (* src = "src/pc.spade:19,9" *)
    logic[10:0] _e_2876;
    logic _e_8394;
    logic _e_8396;
    logic _e_8397;
    (* src = "src/pc.spade:19,42" *)
    logic[10:0] _e_2879;
    (* src = "src/pc.spade:19,36" *)
    logic[9:0] _e_2878;
    (* src = "src/pc.spade:16,43" *)
    logic[9:0] _e_2860;
    (* src = "src/pc.spade:16,14" *)
    reg[9:0] \pc ;
    localparam[9:0] _e_2859 = 0;
    assign _e_2861 = {\bt , \jump_to };
    assign _e_2868 = _e_2861;
    assign _e_2866 = _e_2861[21:11];
    assign \bt_target  = _e_2866[9:0];
    assign \_  = _e_2861[10:0];
    assign _e_8379 = _e_2866[10] == 1'd1;
    localparam[0:0] _e_8380 = 1;
    assign _e_8381 = _e_8379 && _e_8380;
    localparam[0:0] _e_8382 = 1;
    assign _e_8383 = _e_8381 && _e_8382;
    assign _e_2873 = _e_2861;
    assign _e_2870 = _e_2861[21:11];
    assign _e_2872 = _e_2861[10:0];
    assign \pc_target  = _e_2872[9:0];
    assign _e_8386 = _e_2870[10] == 1'd0;
    assign _e_8388 = _e_2872[10] == 1'd1;
    localparam[0:0] _e_8389 = 1;
    assign _e_8390 = _e_8388 && _e_8389;
    assign _e_8391 = _e_8386 && _e_8390;
    assign _e_2877 = _e_2861;
    assign _e_2875 = _e_2861[21:11];
    assign _e_2876 = _e_2861[10:0];
    assign _e_8394 = _e_2875[10] == 1'd0;
    assign _e_8396 = _e_2876[10] == 1'd0;
    assign _e_8397 = _e_8394 && _e_8396;
    localparam[9:0] _e_2881 = 1;
    assign _e_2879 = \pc  + _e_2881;
    assign _e_2878 = _e_2879[9:0];
    always_comb begin
        priority casez ({_e_8383, _e_8391, _e_8397})
            3'b1??: _e_2860 = \bt_target ;
            3'b01?: _e_2860 = \pc_target ;
            3'b001: _e_2860 = _e_2878;
            3'b?: _e_2860 = 10'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \pc  <= _e_2859;
        end
        else begin
            \pc  <= _e_2860;
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
    logic[42:0] _e_2887;
    (* src = "src/pc.spade:27,14" *)
    logic[9:0] \a ;
    logic _e_8399;
    logic _e_8401;
    logic _e_8403;
    logic _e_8404;
    (* src = "src/pc.spade:27,34" *)
    logic[10:0] _e_2889;
    (* src = "src/pc.spade:28,9" *)
    logic[43:0] \_ ;
    (* src = "src/pc.spade:28,25" *)
    logic[42:0] _e_2895;
    (* src = "src/pc.spade:28,30" *)
    logic[9:0] a_n1;
    logic _e_8407;
    logic _e_8409;
    logic _e_8411;
    logic _e_8412;
    (* src = "src/pc.spade:28,50" *)
    logic[10:0] _e_2897;
    (* src = "src/pc.spade:28,59" *)
    logic[43:0] __n1;
    (* src = "src/pc.spade:28,64" *)
    logic[10:0] _e_2900;
    (* src = "src/pc.spade:28,14" *)
    logic[10:0] _e_2892;
    (* src = "src/pc.spade:26,5" *)
    logic[10:0] _e_2884;
    assign _e_2887 = \m1 [42:0];
    assign \a  = _e_2887[36:27];
    assign _e_8399 = \m1 [43] == 1'd1;
    assign _e_8401 = _e_2887[42:37] == 6'd3;
    localparam[0:0] _e_8402 = 1;
    assign _e_8403 = _e_8401 && _e_8402;
    assign _e_8404 = _e_8399 && _e_8403;
    assign _e_2889 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8405 = 1;
    assign _e_2895 = \m0 [42:0];
    assign a_n1 = _e_2895[36:27];
    assign _e_8407 = \m0 [43] == 1'd1;
    assign _e_8409 = _e_2895[42:37] == 6'd3;
    localparam[0:0] _e_8410 = 1;
    assign _e_8411 = _e_8409 && _e_8410;
    assign _e_8412 = _e_8407 && _e_8411;
    assign _e_2897 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8413 = 1;
    assign _e_2900 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_8412, _e_8413})
            2'b1?: _e_2892 = _e_2897;
            2'b01: _e_2892 = _e_2900;
            2'b?: _e_2892 = 11'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8404, _e_8405})
            2'b1?: _e_2884 = _e_2889;
            2'b01: _e_2884 = _e_2892;
            2'b?: _e_2884 = 11'dx;
        endcase
    end
    assign output__ = _e_2884;
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
    logic _e_8415;
    logic _e_8417;
    logic _e_8419;
    (* src = "src/gpo.spade:16,5" *)
    logic[15:0] _e_2906;
    (* src = "src/gpo.spade:15,12" *)
    reg[15:0] \outv ;
    localparam[15:0] _e_2905 = 0;
    assign \v  = \wr [15:0];
    assign _e_8415 = \wr [16] == 1'd1;
    localparam[0:0] _e_8416 = 1;
    assign _e_8417 = _e_8415 && _e_8416;
    assign _e_8419 = \wr [16] == 1'd0;
    always_comb begin
        priority casez ({_e_8417, _e_8419})
            2'b1?: _e_2906 = \v ;
            2'b01: _e_2906 = \outv ;
            2'b?: _e_2906 = 16'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \outv  <= _e_2905;
        end
        else begin
            \outv  <= _e_2906;
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
    logic[42:0] _e_2918;
    (* src = "src/gpo.spade:27,14" *)
    logic[15:0] \x ;
    logic _e_8421;
    logic _e_8423;
    logic _e_8425;
    logic _e_8426;
    (* src = "src/gpo.spade:27,34" *)
    logic[16:0] _e_2920;
    (* src = "src/gpo.spade:28,9" *)
    logic[43:0] \_ ;
    (* src = "src/gpo.spade:29,13" *)
    logic[42:0] _e_2926;
    (* src = "src/gpo.spade:29,18" *)
    logic[15:0] x_n1;
    logic _e_8429;
    logic _e_8431;
    logic _e_8433;
    logic _e_8434;
    (* src = "src/gpo.spade:29,38" *)
    logic[16:0] _e_2928;
    (* src = "src/gpo.spade:30,13" *)
    logic[43:0] __n1;
    (* src = "src/gpo.spade:30,18" *)
    logic[16:0] _e_2931;
    (* src = "src/gpo.spade:28,14" *)
    logic[16:0] _e_2923;
    (* src = "src/gpo.spade:26,5" *)
    logic[16:0] _e_2915;
    assign _e_2918 = \m1 [42:0];
    assign \x  = _e_2918[36:21];
    assign _e_8421 = \m1 [43] == 1'd1;
    assign _e_8423 = _e_2918[42:37] == 6'd10;
    localparam[0:0] _e_8424 = 1;
    assign _e_8425 = _e_8423 && _e_8424;
    assign _e_8426 = _e_8421 && _e_8425;
    assign _e_2920 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8427 = 1;
    assign _e_2926 = \m0 [42:0];
    assign x_n1 = _e_2926[36:21];
    assign _e_8429 = \m0 [43] == 1'd1;
    assign _e_8431 = _e_2926[42:37] == 6'd10;
    localparam[0:0] _e_8432 = 1;
    assign _e_8433 = _e_8431 && _e_8432;
    assign _e_8434 = _e_8429 && _e_8433;
    assign _e_2928 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8435 = 1;
    assign _e_2931 = {1'd0, 16'bX};
    always_comb begin
        priority casez ({_e_8434, _e_8435})
            2'b1?: _e_2923 = _e_2928;
            2'b01: _e_2923 = _e_2931;
            2'b?: _e_2923 = 17'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8426, _e_8427})
            2'b1?: _e_2915 = _e_2920;
            2'b01: _e_2915 = _e_2923;
            2'b?: _e_2915 = 17'dx;
        endcase
    end
    assign output__ = _e_2915;
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
    logic[32:0] _e_2942;
    (* src = "src/spi.spade:19,7" *)
    logic[31:0] \b ;
    logic _e_8437;
    logic _e_8439;
    logic[31:0] _e_2948;
    (* src = "src/spi.spade:19,18" *)
    logic[32:0] _e_2947;
    logic _e_8441;
    (* src = "src/spi.spade:20,15" *)
    logic[32:0] _e_2951;
    (* src = "src/spi.spade:18,56" *)
    logic[32:0] _e_2943;
    (* src = "src/spi.spade:18,14" *)
    reg[32:0] data_n1;
    (* src = "src/spi.spade:17,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\miso_byte ), .pop_i(\pop ), .output__(\data ));
    assign _e_2942 = {1'd0, 32'bX};
    assign \b  = data_n1[31:0];
    assign _e_8437 = data_n1[32] == 1'd1;
    localparam[0:0] _e_8438 = 1;
    assign _e_8439 = _e_8437 && _e_8438;
    assign _e_2948 = \b ;
    assign _e_2947 = {1'd1, _e_2948};
    assign _e_8441 = data_n1[32] == 1'd0;
    assign _e_2951 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8439, _e_8441})
            2'b1?: _e_2943 = _e_2947;
            2'b01: _e_2943 = _e_2951;
            2'b?: _e_2943 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2942;
        end
        else begin
            data_n1 <= _e_2943;
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
    logic _e_2958;
    (* src = "src/spi.spade:44,16" *)
    logic[14:0] \data ;
    (* src = "src/spi.spade:45,47" *)
    logic[8:0] _e_2964;
    (* src = "src/spi.spade:46,7" *)
    logic[7:0] \b ;
    logic _e_8443;
    logic _e_8445;
    (* src = "src/spi.spade:46,18" *)
    logic[8:0] _e_2969;
    logic _e_8447;
    (* src = "src/spi.spade:47,15" *)
    logic[8:0] _e_2972;
    (* src = "src/spi.spade:45,55" *)
    logic[8:0] _e_2965;
    (* src = "src/spi.spade:45,14" *)
    reg[8:0] data_n1;
    assign _e_2958 = !\spi_busy ;
    (* src = "src/spi.spade:44,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\byte_to_write ), .pop_i(_e_2958), .output__(\data ));
    assign _e_2964 = {1'd0, 8'bX};
    assign \b  = data_n1[7:0];
    assign _e_8443 = data_n1[8] == 1'd1;
    localparam[0:0] _e_8444 = 1;
    assign _e_8445 = _e_8443 && _e_8444;
    assign _e_2969 = {1'd1, \b };
    assign _e_8447 = data_n1[8] == 1'd0;
    assign _e_2972 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8445, _e_8447})
            2'b1?: _e_2965 = _e_2969;
            2'b01: _e_2965 = _e_2972;
            2'b?: _e_2965 = 9'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2964;
        end
        else begin
            data_n1 <= _e_2965;
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
    logic[42:0] _e_2979;
    logic _e_8449;
    logic _e_8451;
    logic _e_8452;
    (* src = "src/spi.spade:58,9" *)
    logic[43:0] \_ ;
    (* src = "src/spi.spade:59,13" *)
    logic[42:0] _e_2985;
    logic _e_8455;
    logic _e_8457;
    logic _e_8458;
    (* src = "src/spi.spade:60,13" *)
    logic[43:0] __n1;
    (* src = "src/spi.spade:58,14" *)
    logic _e_2983;
    (* src = "src/spi.spade:56,5" *)
    logic _e_2977;
    assign _e_2979 = \m1 [42:0];
    assign _e_8449 = \m1 [43] == 1'd1;
    assign _e_8451 = _e_2979[42:37] == 6'd42;
    assign _e_8452 = _e_8449 && _e_8451;
    localparam[0:0] _e_2981 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_8453 = 1;
    assign _e_2985 = \m0 [42:0];
    assign _e_8455 = \m0 [43] == 1'd1;
    assign _e_8457 = _e_2985[42:37] == 6'd42;
    assign _e_8458 = _e_8455 && _e_8457;
    localparam[0:0] _e_2987 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_8459 = 1;
    localparam[0:0] _e_2989 = 0;
    always_comb begin
        priority casez ({_e_8458, _e_8459})
            2'b1?: _e_2983 = _e_2987;
            2'b01: _e_2983 = _e_2989;
            2'b?: _e_2983 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8452, _e_8453})
            2'b1?: _e_2977 = _e_2981;
            2'b01: _e_2977 = _e_2983;
            2'b?: _e_2977 = 1'dx;
        endcase
    end
    assign output__ = _e_2977;
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
    logic[42:0] _e_2994;
    (* src = "src/spi.spade:66,14" *)
    logic[7:0] \x ;
    logic _e_8461;
    logic _e_8463;
    logic _e_8465;
    logic _e_8466;
    (* src = "src/spi.spade:66,35" *)
    logic[8:0] _e_2996;
    (* src = "src/spi.spade:67,9" *)
    logic[43:0] \_ ;
    (* src = "src/spi.spade:68,13" *)
    logic[42:0] _e_3002;
    (* src = "src/spi.spade:68,18" *)
    logic[7:0] x_n1;
    logic _e_8469;
    logic _e_8471;
    logic _e_8473;
    logic _e_8474;
    (* src = "src/spi.spade:68,39" *)
    logic[8:0] _e_3004;
    (* src = "src/spi.spade:69,13" *)
    logic[43:0] __n1;
    (* src = "src/spi.spade:69,18" *)
    logic[8:0] _e_3007;
    (* src = "src/spi.spade:67,14" *)
    logic[8:0] _e_2999;
    (* src = "src/spi.spade:65,5" *)
    logic[8:0] _e_2991;
    assign _e_2994 = \m1 [42:0];
    assign \x  = _e_2994[36:29];
    assign _e_8461 = \m1 [43] == 1'd1;
    assign _e_8463 = _e_2994[42:37] == 6'd20;
    localparam[0:0] _e_8464 = 1;
    assign _e_8465 = _e_8463 && _e_8464;
    assign _e_8466 = _e_8461 && _e_8465;
    assign _e_2996 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8467 = 1;
    assign _e_3002 = \m0 [42:0];
    assign x_n1 = _e_3002[36:29];
    assign _e_8469 = \m0 [43] == 1'd1;
    assign _e_8471 = _e_3002[42:37] == 6'd20;
    localparam[0:0] _e_8472 = 1;
    assign _e_8473 = _e_8471 && _e_8472;
    assign _e_8474 = _e_8469 && _e_8473;
    assign _e_3004 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8475 = 1;
    assign _e_3007 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8474, _e_8475})
            2'b1?: _e_2999 = _e_3004;
            2'b01: _e_2999 = _e_3007;
            2'b?: _e_2999 = 9'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8466, _e_8467})
            2'b1?: _e_2991 = _e_2996;
            2'b01: _e_2991 = _e_2999;
            2'b?: _e_2991 = 9'dx;
        endcase
    end
    assign output__ = _e_2991;
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
    logic _e_8477;
    logic _e_8479;
    logic _e_8481;
    (* src = "src/lalu.spade:22,45" *)
    logic[31:0] _e_3013;
    (* src = "src/lalu.spade:22,14" *)
    reg[31:0] \op_a ;
    (* src = "src/lalu.spade:29,9" *)
    logic[32:0] _e_3024;
    (* src = "src/lalu.spade:29,14" *)
    logic _e_3022;
    (* src = "src/lalu.spade:29,14" *)
    logic[31:0] \b ;
    logic _e_8483;
    logic _e_8486;
    logic _e_8488;
    logic _e_8489;
    (* src = "src/lalu.spade:29,46" *)
    logic[32:0] _e_3028;
    (* src = "src/lalu.spade:29,40" *)
    logic[31:0] _e_3027;
    (* src = "src/lalu.spade:29,35" *)
    logic[32:0] _e_3026;
    (* src = "src/lalu.spade:30,9" *)
    logic[32:0] _e_3033;
    (* src = "src/lalu.spade:30,14" *)
    logic _e_3031;
    (* src = "src/lalu.spade:30,14" *)
    logic[31:0] b_n1;
    logic _e_8491;
    logic _e_8494;
    logic _e_8496;
    logic _e_8497;
    (* src = "src/lalu.spade:30,46" *)
    logic[32:0] _e_3037;
    (* src = "src/lalu.spade:30,40" *)
    logic[31:0] _e_3036;
    (* src = "src/lalu.spade:30,35" *)
    logic[32:0] _e_3035;
    logic _e_8499;
    (* src = "src/lalu.spade:31,34" *)
    logic[32:0] _e_3041;
    (* src = "src/lalu.spade:28,36" *)
    logic[32:0] \result ;
    (* src = "src/lalu.spade:35,51" *)
    logic[32:0] _e_3046;
    (* src = "src/lalu.spade:35,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_3012 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_8477 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_8478 = 1;
    assign _e_8479 = _e_8477 && _e_8478;
    assign _e_8481 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8479, _e_8481})
            2'b1?: _e_3013 = \v ;
            2'b01: _e_3013 = \op_a ;
            2'b?: _e_3013 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_3012;
        end
        else begin
            \op_a  <= _e_3013;
        end
    end
    assign _e_3024 = \trig [32:0];
    assign _e_3022 = _e_3024[32];
    assign \b  = _e_3024[31:0];
    assign _e_8483 = \trig [33] == 1'd1;
    assign _e_8486 = _e_3022 == 1'd0;
    localparam[0:0] _e_8487 = 1;
    assign _e_8488 = _e_8486 && _e_8487;
    assign _e_8489 = _e_8483 && _e_8488;
    assign _e_3028 = \op_a  + \b ;
    assign _e_3027 = _e_3028[31:0];
    assign _e_3026 = {1'd1, _e_3027};
    assign _e_3033 = \trig [32:0];
    assign _e_3031 = _e_3033[32];
    assign b_n1 = _e_3033[31:0];
    assign _e_8491 = \trig [33] == 1'd1;
    assign _e_8494 = _e_3031 == 1'd1;
    localparam[0:0] _e_8495 = 1;
    assign _e_8496 = _e_8494 && _e_8495;
    assign _e_8497 = _e_8491 && _e_8496;
    assign _e_3037 = \op_a  - b_n1;
    assign _e_3036 = _e_3037[31:0];
    assign _e_3035 = {1'd1, _e_3036};
    assign _e_8499 = \trig [33] == 1'd0;
    assign _e_3041 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8489, _e_8497, _e_8499})
            3'b1??: \result  = _e_3026;
            3'b01?: \result  = _e_3035;
            3'b001: \result  = _e_3041;
            3'b?: \result  = 33'dx;
        endcase
    end
    assign _e_3046 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_3046;
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
    logic[42:0] _e_3053;
    (* src = "src/lalu.spade:43,14" *)
    logic[31:0] \x ;
    logic _e_8501;
    logic _e_8503;
    logic _e_8505;
    logic _e_8506;
    (* src = "src/lalu.spade:43,36" *)
    logic[32:0] _e_3055;
    (* src = "src/lalu.spade:44,9" *)
    logic[43:0] \_ ;
    (* src = "src/lalu.spade:45,13" *)
    logic[42:0] _e_3061;
    (* src = "src/lalu.spade:45,18" *)
    logic[31:0] x_n1;
    logic _e_8509;
    logic _e_8511;
    logic _e_8513;
    logic _e_8514;
    (* src = "src/lalu.spade:45,40" *)
    logic[32:0] _e_3063;
    (* src = "src/lalu.spade:46,13" *)
    logic[43:0] __n1;
    (* src = "src/lalu.spade:46,18" *)
    logic[32:0] _e_3066;
    (* src = "src/lalu.spade:44,14" *)
    logic[32:0] _e_3058;
    (* src = "src/lalu.spade:42,5" *)
    logic[32:0] _e_3050;
    assign _e_3053 = \m1 [42:0];
    assign \x  = _e_3053[36:5];
    assign _e_8501 = \m1 [43] == 1'd1;
    assign _e_8503 = _e_3053[42:37] == 6'd14;
    localparam[0:0] _e_8504 = 1;
    assign _e_8505 = _e_8503 && _e_8504;
    assign _e_8506 = _e_8501 && _e_8505;
    assign _e_3055 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8507 = 1;
    assign _e_3061 = \m0 [42:0];
    assign x_n1 = _e_3061[36:5];
    assign _e_8509 = \m0 [43] == 1'd1;
    assign _e_8511 = _e_3061[42:37] == 6'd14;
    localparam[0:0] _e_8512 = 1;
    assign _e_8513 = _e_8511 && _e_8512;
    assign _e_8514 = _e_8509 && _e_8513;
    assign _e_3063 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8515 = 1;
    assign _e_3066 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8514, _e_8515})
            2'b1?: _e_3058 = _e_3063;
            2'b01: _e_3058 = _e_3066;
            2'b?: _e_3058 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8506, _e_8507})
            2'b1?: _e_3050 = _e_3055;
            2'b01: _e_3050 = _e_3058;
            2'b?: _e_3050 = 33'dx;
        endcase
    end
    assign output__ = _e_3050;
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
    logic[42:0] _e_3072;
    (* src = "src/lalu.spade:52,14" *)
    logic \op ;
    (* src = "src/lalu.spade:52,14" *)
    logic[31:0] \x ;
    logic _e_8517;
    logic _e_8519;
    logic _e_8522;
    logic _e_8523;
    logic _e_8524;
    (* src = "src/lalu.spade:52,45" *)
    logic[32:0] _e_3075;
    (* src = "src/lalu.spade:52,40" *)
    logic[33:0] _e_3074;
    (* src = "src/lalu.spade:53,9" *)
    logic[43:0] \_ ;
    (* src = "src/lalu.spade:54,13" *)
    logic[42:0] _e_3083;
    (* src = "src/lalu.spade:54,18" *)
    logic op_n1;
    (* src = "src/lalu.spade:54,18" *)
    logic[31:0] x_n1;
    logic _e_8527;
    logic _e_8529;
    logic _e_8532;
    logic _e_8533;
    logic _e_8534;
    (* src = "src/lalu.spade:54,49" *)
    logic[32:0] _e_3086;
    (* src = "src/lalu.spade:54,44" *)
    logic[33:0] _e_3085;
    (* src = "src/lalu.spade:55,13" *)
    logic[43:0] __n1;
    (* src = "src/lalu.spade:55,18" *)
    logic[33:0] _e_3090;
    (* src = "src/lalu.spade:53,14" *)
    logic[33:0] _e_3079;
    (* src = "src/lalu.spade:51,5" *)
    logic[33:0] _e_3068;
    assign _e_3072 = \m1 [42:0];
    assign \op  = _e_3072[36:36];
    assign \x  = _e_3072[35:4];
    assign _e_8517 = \m1 [43] == 1'd1;
    assign _e_8519 = _e_3072[42:37] == 6'd15;
    localparam[0:0] _e_8520 = 1;
    localparam[0:0] _e_8521 = 1;
    assign _e_8522 = _e_8519 && _e_8520;
    assign _e_8523 = _e_8522 && _e_8521;
    assign _e_8524 = _e_8517 && _e_8523;
    assign _e_3075 = {\op , \x };
    assign _e_3074 = {1'd1, _e_3075};
    assign \_  = \m1 ;
    localparam[0:0] _e_8525 = 1;
    assign _e_3083 = \m0 [42:0];
    assign op_n1 = _e_3083[36:36];
    assign x_n1 = _e_3083[35:4];
    assign _e_8527 = \m0 [43] == 1'd1;
    assign _e_8529 = _e_3083[42:37] == 6'd15;
    localparam[0:0] _e_8530 = 1;
    localparam[0:0] _e_8531 = 1;
    assign _e_8532 = _e_8529 && _e_8530;
    assign _e_8533 = _e_8532 && _e_8531;
    assign _e_8534 = _e_8527 && _e_8533;
    assign _e_3086 = {op_n1, x_n1};
    assign _e_3085 = {1'd1, _e_3086};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8535 = 1;
    assign _e_3090 = {1'd0, 33'bX};
    always_comb begin
        priority casez ({_e_8534, _e_8535})
            2'b1?: _e_3079 = _e_3085;
            2'b01: _e_3079 = _e_3090;
            2'b?: _e_3079 = 34'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8524, _e_8525})
            2'b1?: _e_3068 = _e_3074;
            2'b01: _e_3068 = _e_3079;
            2'b?: _e_3068 = 34'dx;
        endcase
    end
    assign output__ = _e_3068;
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
    logic[43:0] _e_3093;
    (* src = "src/tta.spade:197,9" *)
    logic[43:0] _e_3100;
    (* src = "src/tta.spade:197,9" *)
    logic[10:0] _e_3097;
    (* src = "src/tta.spade:197,10" *)
    logic[3:0] \i ;
    (* src = "src/tta.spade:197,9" *)
    logic[32:0] _e_3099;
    (* src = "src/tta.spade:197,32" *)
    logic[31:0] \x ;
    logic _e_8538;
    logic _e_8540;
    logic _e_8542;
    logic _e_8544;
    logic _e_8545;
    (* src = "src/tta.spade:197,49" *)
    logic[42:0] _e_3102;
    (* src = "src/tta.spade:197,44" *)
    logic[43:0] _e_3101;
    (* src = "src/tta.spade:199,9" *)
    logic[43:0] _e_3108;
    (* src = "src/tta.spade:199,9" *)
    logic[10:0] _e_3105;
    (* src = "src/tta.spade:199,9" *)
    logic[32:0] _e_3107;
    (* src = "src/tta.spade:199,32" *)
    logic[31:0] x_n1;
    logic _e_8548;
    logic _e_8550;
    logic _e_8552;
    logic _e_8553;
    (* src = "src/tta.spade:199,49" *)
    logic[42:0] _e_3110;
    (* src = "src/tta.spade:199,44" *)
    logic[43:0] _e_3109;
    (* src = "src/tta.spade:200,9" *)
    logic[43:0] _e_3115;
    (* src = "src/tta.spade:200,9" *)
    logic[10:0] _e_3112;
    (* src = "src/tta.spade:200,9" *)
    logic[32:0] _e_3114;
    (* src = "src/tta.spade:200,32" *)
    logic[31:0] x_n2;
    logic _e_8556;
    logic _e_8558;
    logic _e_8560;
    logic _e_8561;
    (* src = "src/tta.spade:200,63" *)
    logic[4:0] _e_3118;
    (* src = "src/tta.spade:200,49" *)
    logic[42:0] _e_3117;
    (* src = "src/tta.spade:200,44" *)
    logic[43:0] _e_3116;
    (* src = "src/tta.spade:201,9" *)
    logic[43:0] _e_3123;
    (* src = "src/tta.spade:201,9" *)
    logic[10:0] _e_3120;
    (* src = "src/tta.spade:201,9" *)
    logic[32:0] _e_3122;
    (* src = "src/tta.spade:201,32" *)
    logic[31:0] x_n3;
    logic _e_8564;
    logic _e_8566;
    logic _e_8568;
    logic _e_8569;
    (* src = "src/tta.spade:201,63" *)
    logic[4:0] _e_3126;
    (* src = "src/tta.spade:201,49" *)
    logic[42:0] _e_3125;
    (* src = "src/tta.spade:201,44" *)
    logic[43:0] _e_3124;
    (* src = "src/tta.spade:202,9" *)
    logic[43:0] _e_3131;
    (* src = "src/tta.spade:202,9" *)
    logic[10:0] _e_3128;
    (* src = "src/tta.spade:202,9" *)
    logic[32:0] _e_3130;
    (* src = "src/tta.spade:202,32" *)
    logic[31:0] x_n4;
    logic _e_8572;
    logic _e_8574;
    logic _e_8576;
    logic _e_8577;
    (* src = "src/tta.spade:202,63" *)
    logic[4:0] _e_3134;
    (* src = "src/tta.spade:202,49" *)
    logic[42:0] _e_3133;
    (* src = "src/tta.spade:202,44" *)
    logic[43:0] _e_3132;
    (* src = "src/tta.spade:203,9" *)
    logic[43:0] _e_3139;
    (* src = "src/tta.spade:203,9" *)
    logic[10:0] _e_3136;
    (* src = "src/tta.spade:203,9" *)
    logic[32:0] _e_3138;
    (* src = "src/tta.spade:203,32" *)
    logic[31:0] x_n5;
    logic _e_8580;
    logic _e_8582;
    logic _e_8584;
    logic _e_8585;
    (* src = "src/tta.spade:203,63" *)
    logic[4:0] _e_3142;
    (* src = "src/tta.spade:203,49" *)
    logic[42:0] _e_3141;
    (* src = "src/tta.spade:203,44" *)
    logic[43:0] _e_3140;
    (* src = "src/tta.spade:204,9" *)
    logic[43:0] _e_3147;
    (* src = "src/tta.spade:204,9" *)
    logic[10:0] _e_3144;
    (* src = "src/tta.spade:204,9" *)
    logic[32:0] _e_3146;
    (* src = "src/tta.spade:204,33" *)
    logic[31:0] x_n6;
    logic _e_8588;
    logic _e_8590;
    logic _e_8592;
    logic _e_8593;
    (* src = "src/tta.spade:204,64" *)
    logic[4:0] _e_3150;
    (* src = "src/tta.spade:204,50" *)
    logic[42:0] _e_3149;
    (* src = "src/tta.spade:204,45" *)
    logic[43:0] _e_3148;
    (* src = "src/tta.spade:205,9" *)
    logic[43:0] _e_3155;
    (* src = "src/tta.spade:205,9" *)
    logic[10:0] _e_3152;
    (* src = "src/tta.spade:205,9" *)
    logic[32:0] _e_3154;
    (* src = "src/tta.spade:205,33" *)
    logic[31:0] x_n7;
    logic _e_8596;
    logic _e_8598;
    logic _e_8600;
    logic _e_8601;
    (* src = "src/tta.spade:205,64" *)
    logic[4:0] _e_3158;
    (* src = "src/tta.spade:205,50" *)
    logic[42:0] _e_3157;
    (* src = "src/tta.spade:205,45" *)
    logic[43:0] _e_3156;
    (* src = "src/tta.spade:206,9" *)
    logic[43:0] _e_3163;
    (* src = "src/tta.spade:206,9" *)
    logic[10:0] _e_3160;
    (* src = "src/tta.spade:206,9" *)
    logic[32:0] _e_3162;
    (* src = "src/tta.spade:206,33" *)
    logic[31:0] x_n8;
    logic _e_8604;
    logic _e_8606;
    logic _e_8608;
    logic _e_8609;
    (* src = "src/tta.spade:206,64" *)
    logic[4:0] _e_3166;
    (* src = "src/tta.spade:206,50" *)
    logic[42:0] _e_3165;
    (* src = "src/tta.spade:206,45" *)
    logic[43:0] _e_3164;
    (* src = "src/tta.spade:207,9" *)
    logic[43:0] _e_3171;
    (* src = "src/tta.spade:207,9" *)
    logic[10:0] _e_3168;
    (* src = "src/tta.spade:207,9" *)
    logic[32:0] _e_3170;
    (* src = "src/tta.spade:207,34" *)
    logic[31:0] x_n9;
    logic _e_8612;
    logic _e_8614;
    logic _e_8616;
    logic _e_8617;
    (* src = "src/tta.spade:207,65" *)
    logic[4:0] _e_3174;
    (* src = "src/tta.spade:207,51" *)
    logic[42:0] _e_3173;
    (* src = "src/tta.spade:207,46" *)
    logic[43:0] _e_3172;
    (* src = "src/tta.spade:208,9" *)
    logic[43:0] _e_3179;
    (* src = "src/tta.spade:208,9" *)
    logic[10:0] _e_3176;
    (* src = "src/tta.spade:208,9" *)
    logic[32:0] _e_3178;
    (* src = "src/tta.spade:208,34" *)
    logic[31:0] x_n10;
    logic _e_8620;
    logic _e_8622;
    logic _e_8624;
    logic _e_8625;
    (* src = "src/tta.spade:208,65" *)
    logic[4:0] _e_3182;
    (* src = "src/tta.spade:208,51" *)
    logic[42:0] _e_3181;
    (* src = "src/tta.spade:208,46" *)
    logic[43:0] _e_3180;
    (* src = "src/tta.spade:209,9" *)
    logic[43:0] _e_3187;
    (* src = "src/tta.spade:209,9" *)
    logic[10:0] _e_3184;
    (* src = "src/tta.spade:209,9" *)
    logic[32:0] _e_3186;
    (* src = "src/tta.spade:209,34" *)
    logic[31:0] x_n11;
    logic _e_8628;
    logic _e_8630;
    logic _e_8632;
    logic _e_8633;
    (* src = "src/tta.spade:209,65" *)
    logic[4:0] _e_3190;
    (* src = "src/tta.spade:209,51" *)
    logic[42:0] _e_3189;
    (* src = "src/tta.spade:209,46" *)
    logic[43:0] _e_3188;
    (* src = "src/tta.spade:210,9" *)
    logic[43:0] _e_3195;
    (* src = "src/tta.spade:210,9" *)
    logic[10:0] _e_3192;
    (* src = "src/tta.spade:210,9" *)
    logic[32:0] _e_3194;
    (* src = "src/tta.spade:210,33" *)
    logic[31:0] x_n12;
    logic _e_8636;
    logic _e_8638;
    logic _e_8640;
    logic _e_8641;
    (* src = "src/tta.spade:210,64" *)
    logic[4:0] _e_3198;
    (* src = "src/tta.spade:210,50" *)
    logic[42:0] _e_3197;
    (* src = "src/tta.spade:210,45" *)
    logic[43:0] _e_3196;
    (* src = "src/tta.spade:211,9" *)
    logic[43:0] _e_3203;
    (* src = "src/tta.spade:211,9" *)
    logic[10:0] _e_3200;
    (* src = "src/tta.spade:211,9" *)
    logic[32:0] _e_3202;
    (* src = "src/tta.spade:211,33" *)
    logic[31:0] x_n13;
    logic _e_8644;
    logic _e_8646;
    logic _e_8648;
    logic _e_8649;
    (* src = "src/tta.spade:211,64" *)
    logic[4:0] _e_3206;
    (* src = "src/tta.spade:211,50" *)
    logic[42:0] _e_3205;
    (* src = "src/tta.spade:211,45" *)
    logic[43:0] _e_3204;
    (* src = "src/tta.spade:212,9" *)
    logic[43:0] _e_3211;
    (* src = "src/tta.spade:212,9" *)
    logic[10:0] _e_3208;
    (* src = "src/tta.spade:212,9" *)
    logic[32:0] _e_3210;
    (* src = "src/tta.spade:212,35" *)
    logic[31:0] x_n14;
    logic _e_8652;
    logic _e_8654;
    logic _e_8656;
    logic _e_8657;
    (* src = "src/tta.spade:212,66" *)
    logic[4:0] _e_3214;
    (* src = "src/tta.spade:212,52" *)
    logic[42:0] _e_3213;
    (* src = "src/tta.spade:212,47" *)
    logic[43:0] _e_3212;
    (* src = "src/tta.spade:213,9" *)
    logic[43:0] _e_3219;
    (* src = "src/tta.spade:213,9" *)
    logic[10:0] _e_3216;
    (* src = "src/tta.spade:213,9" *)
    logic[32:0] _e_3218;
    (* src = "src/tta.spade:213,35" *)
    logic[31:0] x_n15;
    logic _e_8660;
    logic _e_8662;
    logic _e_8664;
    logic _e_8665;
    (* src = "src/tta.spade:213,66" *)
    logic[4:0] _e_3222;
    (* src = "src/tta.spade:213,52" *)
    logic[42:0] _e_3221;
    (* src = "src/tta.spade:213,47" *)
    logic[43:0] _e_3220;
    (* src = "src/tta.spade:214,9" *)
    logic[43:0] _e_3227;
    (* src = "src/tta.spade:214,9" *)
    logic[10:0] _e_3224;
    (* src = "src/tta.spade:214,9" *)
    logic[32:0] _e_3226;
    (* src = "src/tta.spade:214,35" *)
    logic[31:0] x_n16;
    logic _e_8668;
    logic _e_8670;
    logic _e_8672;
    logic _e_8673;
    (* src = "src/tta.spade:214,66" *)
    logic[4:0] _e_3230;
    (* src = "src/tta.spade:214,52" *)
    logic[42:0] _e_3229;
    (* src = "src/tta.spade:214,47" *)
    logic[43:0] _e_3228;
    (* src = "src/tta.spade:215,9" *)
    logic[43:0] _e_3235;
    (* src = "src/tta.spade:215,9" *)
    logic[10:0] _e_3232;
    (* src = "src/tta.spade:215,9" *)
    logic[32:0] _e_3234;
    (* src = "src/tta.spade:215,35" *)
    logic[31:0] x_n17;
    logic _e_8676;
    logic _e_8678;
    logic _e_8680;
    logic _e_8681;
    (* src = "src/tta.spade:215,66" *)
    logic[4:0] _e_3238;
    (* src = "src/tta.spade:215,52" *)
    logic[42:0] _e_3237;
    (* src = "src/tta.spade:215,47" *)
    logic[43:0] _e_3236;
    (* src = "src/tta.spade:217,9" *)
    logic[43:0] _e_3243;
    (* src = "src/tta.spade:217,9" *)
    logic[10:0] _e_3240;
    (* src = "src/tta.spade:217,9" *)
    logic[32:0] _e_3242;
    (* src = "src/tta.spade:217,33" *)
    logic[31:0] x_n18;
    logic _e_8684;
    logic _e_8686;
    logic _e_8688;
    logic _e_8689;
    (* src = "src/tta.spade:217,64" *)
    logic[2:0] _e_3246;
    (* src = "src/tta.spade:217,50" *)
    logic[42:0] _e_3245;
    (* src = "src/tta.spade:217,45" *)
    logic[43:0] _e_3244;
    (* src = "src/tta.spade:218,9" *)
    logic[43:0] _e_3251;
    (* src = "src/tta.spade:218,9" *)
    logic[10:0] _e_3248;
    (* src = "src/tta.spade:218,9" *)
    logic[32:0] _e_3250;
    (* src = "src/tta.spade:218,33" *)
    logic[31:0] x_n19;
    logic _e_8692;
    logic _e_8694;
    logic _e_8696;
    logic _e_8697;
    (* src = "src/tta.spade:218,64" *)
    logic[2:0] _e_3254;
    (* src = "src/tta.spade:218,50" *)
    logic[42:0] _e_3253;
    (* src = "src/tta.spade:218,45" *)
    logic[43:0] _e_3252;
    (* src = "src/tta.spade:219,9" *)
    logic[43:0] _e_3259;
    (* src = "src/tta.spade:219,9" *)
    logic[10:0] _e_3256;
    (* src = "src/tta.spade:219,9" *)
    logic[32:0] _e_3258;
    (* src = "src/tta.spade:219,36" *)
    logic[31:0] x_n20;
    logic _e_8700;
    logic _e_8702;
    logic _e_8704;
    logic _e_8705;
    (* src = "src/tta.spade:219,67" *)
    logic[2:0] _e_3262;
    (* src = "src/tta.spade:219,53" *)
    logic[42:0] _e_3261;
    (* src = "src/tta.spade:219,48" *)
    logic[43:0] _e_3260;
    (* src = "src/tta.spade:220,9" *)
    logic[43:0] _e_3267;
    (* src = "src/tta.spade:220,9" *)
    logic[10:0] _e_3264;
    (* src = "src/tta.spade:220,9" *)
    logic[32:0] _e_3266;
    (* src = "src/tta.spade:220,34" *)
    logic[31:0] x_n21;
    logic _e_8708;
    logic _e_8710;
    logic _e_8712;
    logic _e_8713;
    (* src = "src/tta.spade:220,65" *)
    logic[2:0] _e_3270;
    (* src = "src/tta.spade:220,51" *)
    logic[42:0] _e_3269;
    (* src = "src/tta.spade:220,46" *)
    logic[43:0] _e_3268;
    (* src = "src/tta.spade:221,9" *)
    logic[43:0] _e_3275;
    (* src = "src/tta.spade:221,9" *)
    logic[10:0] _e_3272;
    (* src = "src/tta.spade:221,9" *)
    logic[32:0] _e_3274;
    (* src = "src/tta.spade:221,34" *)
    logic[31:0] x_n22;
    logic _e_8716;
    logic _e_8718;
    logic _e_8720;
    logic _e_8721;
    (* src = "src/tta.spade:221,65" *)
    logic[2:0] _e_3278;
    (* src = "src/tta.spade:221,51" *)
    logic[42:0] _e_3277;
    (* src = "src/tta.spade:221,46" *)
    logic[43:0] _e_3276;
    (* src = "src/tta.spade:222,9" *)
    logic[43:0] _e_3283;
    (* src = "src/tta.spade:222,9" *)
    logic[10:0] _e_3280;
    (* src = "src/tta.spade:222,9" *)
    logic[32:0] _e_3282;
    (* src = "src/tta.spade:222,34" *)
    logic[31:0] x_n23;
    logic _e_8724;
    logic _e_8726;
    logic _e_8728;
    logic _e_8729;
    (* src = "src/tta.spade:222,65" *)
    logic[2:0] _e_3286;
    (* src = "src/tta.spade:222,51" *)
    logic[42:0] _e_3285;
    (* src = "src/tta.spade:222,46" *)
    logic[43:0] _e_3284;
    (* src = "src/tta.spade:223,9" *)
    logic[43:0] _e_3291;
    (* src = "src/tta.spade:223,9" *)
    logic[10:0] _e_3288;
    (* src = "src/tta.spade:223,9" *)
    logic[32:0] _e_3290;
    (* src = "src/tta.spade:223,34" *)
    logic[31:0] x_n24;
    logic _e_8732;
    logic _e_8734;
    logic _e_8736;
    logic _e_8737;
    (* src = "src/tta.spade:223,65" *)
    logic[2:0] _e_3294;
    (* src = "src/tta.spade:223,51" *)
    logic[42:0] _e_3293;
    (* src = "src/tta.spade:223,46" *)
    logic[43:0] _e_3292;
    (* src = "src/tta.spade:224,9" *)
    logic[43:0] _e_3299;
    (* src = "src/tta.spade:224,9" *)
    logic[10:0] _e_3296;
    (* src = "src/tta.spade:224,9" *)
    logic[32:0] _e_3298;
    (* src = "src/tta.spade:224,34" *)
    logic[31:0] x_n25;
    logic _e_8740;
    logic _e_8742;
    logic _e_8744;
    logic _e_8745;
    (* src = "src/tta.spade:224,65" *)
    logic[2:0] _e_3302;
    (* src = "src/tta.spade:224,51" *)
    logic[42:0] _e_3301;
    (* src = "src/tta.spade:224,46" *)
    logic[43:0] _e_3300;
    (* src = "src/tta.spade:226,9" *)
    logic[43:0] _e_3307;
    (* src = "src/tta.spade:226,9" *)
    logic[10:0] _e_3304;
    (* src = "src/tta.spade:226,9" *)
    logic[32:0] _e_3306;
    (* src = "src/tta.spade:226,33" *)
    logic[31:0] x_n26;
    logic _e_8748;
    logic _e_8750;
    logic _e_8752;
    logic _e_8753;
    (* src = "src/tta.spade:226,50" *)
    logic[42:0] _e_3309;
    (* src = "src/tta.spade:226,45" *)
    logic[43:0] _e_3308;
    (* src = "src/tta.spade:227,9" *)
    logic[43:0] _e_3314;
    (* src = "src/tta.spade:227,9" *)
    logic[10:0] _e_3311;
    (* src = "src/tta.spade:227,9" *)
    logic[32:0] _e_3313;
    (* src = "src/tta.spade:227,33" *)
    logic[31:0] x_n27;
    logic _e_8756;
    logic _e_8758;
    logic _e_8760;
    logic _e_8761;
    (* src = "src/tta.spade:227,65" *)
    logic _e_3317;
    (* src = "src/tta.spade:227,50" *)
    logic[42:0] _e_3316;
    (* src = "src/tta.spade:227,45" *)
    logic[43:0] _e_3315;
    (* src = "src/tta.spade:228,9" *)
    logic[43:0] _e_3322;
    (* src = "src/tta.spade:228,9" *)
    logic[10:0] _e_3319;
    (* src = "src/tta.spade:228,9" *)
    logic[32:0] _e_3321;
    (* src = "src/tta.spade:228,33" *)
    logic[31:0] x_n28;
    logic _e_8764;
    logic _e_8766;
    logic _e_8768;
    logic _e_8769;
    (* src = "src/tta.spade:228,65" *)
    logic _e_3325;
    (* src = "src/tta.spade:228,50" *)
    logic[42:0] _e_3324;
    (* src = "src/tta.spade:228,45" *)
    logic[43:0] _e_3323;
    (* src = "src/tta.spade:230,9" *)
    logic[43:0] _e_3330;
    (* src = "src/tta.spade:230,9" *)
    logic[10:0] _e_3327;
    (* src = "src/tta.spade:230,9" *)
    logic[32:0] _e_3329;
    (* src = "src/tta.spade:230,32" *)
    logic[31:0] x_n29;
    logic _e_8772;
    logic _e_8774;
    logic _e_8776;
    logic _e_8777;
    (* src = "src/tta.spade:230,62" *)
    logic[9:0] _e_3333;
    (* src = "src/tta.spade:230,49" *)
    logic[42:0] _e_3332;
    (* src = "src/tta.spade:230,44" *)
    logic[43:0] _e_3331;
    (* src = "src/tta.spade:232,9" *)
    logic[43:0] _e_3338;
    (* src = "src/tta.spade:232,9" *)
    logic[10:0] _e_3335;
    (* src = "src/tta.spade:232,9" *)
    logic[32:0] _e_3337;
    (* src = "src/tta.spade:232,32" *)
    logic[31:0] x_n30;
    logic _e_8780;
    logic _e_8782;
    logic _e_8784;
    logic _e_8785;
    (* src = "src/tta.spade:232,64" *)
    logic[9:0] _e_3341;
    (* src = "src/tta.spade:232,49" *)
    logic[42:0] _e_3340;
    (* src = "src/tta.spade:232,44" *)
    logic[43:0] _e_3339;
    (* src = "src/tta.spade:233,9" *)
    logic[43:0] _e_3346;
    (* src = "src/tta.spade:233,9" *)
    logic[10:0] _e_3343;
    (* src = "src/tta.spade:233,9" *)
    logic[32:0] _e_3345;
    (* src = "src/tta.spade:233,32" *)
    logic[31:0] x_n31;
    logic _e_8788;
    logic _e_8790;
    logic _e_8792;
    logic _e_8793;
    (* src = "src/tta.spade:233,49" *)
    logic[42:0] _e_3348;
    (* src = "src/tta.spade:233,44" *)
    logic[43:0] _e_3347;
    (* src = "src/tta.spade:235,9" *)
    logic[43:0] _e_3353;
    (* src = "src/tta.spade:235,9" *)
    logic[10:0] _e_3350;
    (* src = "src/tta.spade:235,9" *)
    logic[32:0] _e_3352;
    (* src = "src/tta.spade:235,32" *)
    logic[31:0] x_n32;
    logic _e_8796;
    logic _e_8798;
    logic _e_8800;
    logic _e_8801;
    (* src = "src/tta.spade:235,49" *)
    logic[42:0] _e_3355;
    (* src = "src/tta.spade:235,44" *)
    logic[43:0] _e_3354;
    (* src = "src/tta.spade:236,9" *)
    logic[43:0] _e_3360;
    (* src = "src/tta.spade:236,9" *)
    logic[10:0] _e_3357;
    (* src = "src/tta.spade:236,9" *)
    logic[32:0] _e_3359;
    (* src = "src/tta.spade:236,32" *)
    logic[31:0] x_n33;
    logic _e_8804;
    logic _e_8806;
    logic _e_8808;
    logic _e_8809;
    (* src = "src/tta.spade:236,49" *)
    logic[42:0] _e_3362;
    (* src = "src/tta.spade:236,44" *)
    logic[43:0] _e_3361;
    (* src = "src/tta.spade:237,9" *)
    logic[43:0] _e_3367;
    (* src = "src/tta.spade:237,9" *)
    logic[10:0] _e_3364;
    (* src = "src/tta.spade:237,9" *)
    logic[32:0] _e_3366;
    (* src = "src/tta.spade:237,32" *)
    logic[31:0] x_n34;
    logic _e_8812;
    logic _e_8814;
    logic _e_8816;
    logic _e_8817;
    (* src = "src/tta.spade:237,49" *)
    logic[42:0] _e_3369;
    (* src = "src/tta.spade:237,44" *)
    logic[43:0] _e_3368;
    (* src = "src/tta.spade:239,9" *)
    logic[43:0] _e_3374;
    (* src = "src/tta.spade:239,9" *)
    logic[10:0] _e_3371;
    (* src = "src/tta.spade:239,9" *)
    logic[32:0] _e_3373;
    (* src = "src/tta.spade:239,33" *)
    logic[31:0] x_n35;
    logic _e_8820;
    logic _e_8822;
    logic _e_8824;
    logic _e_8825;
    (* src = "src/tta.spade:239,50" *)
    logic[42:0] _e_3376;
    (* src = "src/tta.spade:239,45" *)
    logic[43:0] _e_3375;
    (* src = "src/tta.spade:240,9" *)
    logic[43:0] _e_3381;
    (* src = "src/tta.spade:240,9" *)
    logic[10:0] _e_3378;
    (* src = "src/tta.spade:240,9" *)
    logic[32:0] _e_3380;
    (* src = "src/tta.spade:240,33" *)
    logic[31:0] x_n36;
    logic _e_8828;
    logic _e_8830;
    logic _e_8832;
    logic _e_8833;
    (* src = "src/tta.spade:240,50" *)
    logic[42:0] _e_3383;
    (* src = "src/tta.spade:240,45" *)
    logic[43:0] _e_3382;
    (* src = "src/tta.spade:241,9" *)
    logic[43:0] _e_3388;
    (* src = "src/tta.spade:241,9" *)
    logic[10:0] _e_3385;
    (* src = "src/tta.spade:241,9" *)
    logic[32:0] _e_3387;
    (* src = "src/tta.spade:241,33" *)
    logic[31:0] x_n37;
    logic _e_8836;
    logic _e_8838;
    logic _e_8840;
    logic _e_8841;
    (* src = "src/tta.spade:241,50" *)
    logic[42:0] _e_3390;
    (* src = "src/tta.spade:241,45" *)
    logic[43:0] _e_3389;
    (* src = "src/tta.spade:243,9" *)
    logic[43:0] _e_3395;
    (* src = "src/tta.spade:243,9" *)
    logic[10:0] _e_3392;
    (* src = "src/tta.spade:243,9" *)
    logic[32:0] _e_3394;
    (* src = "src/tta.spade:243,32" *)
    logic[31:0] x_n38;
    logic _e_8844;
    logic _e_8846;
    logic _e_8848;
    logic _e_8849;
    (* src = "src/tta.spade:243,62" *)
    logic[15:0] _e_3398;
    (* src = "src/tta.spade:243,49" *)
    logic[42:0] _e_3397;
    (* src = "src/tta.spade:243,44" *)
    logic[43:0] _e_3396;
    (* src = "src/tta.spade:245,9" *)
    logic[43:0] _e_3403;
    (* src = "src/tta.spade:245,9" *)
    logic[10:0] _e_3400;
    (* src = "src/tta.spade:245,9" *)
    logic[32:0] _e_3402;
    (* src = "src/tta.spade:245,32" *)
    logic[31:0] x_n39;
    logic _e_8852;
    logic _e_8854;
    logic _e_8856;
    logic _e_8857;
    (* src = "src/tta.spade:245,49" *)
    logic[42:0] _e_3405;
    (* src = "src/tta.spade:245,44" *)
    logic[43:0] _e_3404;
    (* src = "src/tta.spade:246,9" *)
    logic[43:0] _e_3410;
    (* src = "src/tta.spade:246,9" *)
    logic[10:0] _e_3407;
    (* src = "src/tta.spade:246,9" *)
    logic[32:0] _e_3409;
    (* src = "src/tta.spade:246,32" *)
    logic[31:0] x_n40;
    logic _e_8860;
    logic _e_8862;
    logic _e_8864;
    logic _e_8865;
    (* src = "src/tta.spade:246,63" *)
    logic[2:0] _e_3413;
    (* src = "src/tta.spade:246,49" *)
    logic[42:0] _e_3412;
    (* src = "src/tta.spade:246,44" *)
    logic[43:0] _e_3411;
    (* src = "src/tta.spade:247,9" *)
    logic[43:0] _e_3418;
    (* src = "src/tta.spade:247,9" *)
    logic[10:0] _e_3415;
    (* src = "src/tta.spade:247,9" *)
    logic[32:0] _e_3417;
    (* src = "src/tta.spade:247,32" *)
    logic[31:0] x_n41;
    logic _e_8868;
    logic _e_8870;
    logic _e_8872;
    logic _e_8873;
    (* src = "src/tta.spade:247,63" *)
    logic[2:0] _e_3421;
    (* src = "src/tta.spade:247,49" *)
    logic[42:0] _e_3420;
    (* src = "src/tta.spade:247,44" *)
    logic[43:0] _e_3419;
    (* src = "src/tta.spade:248,9" *)
    logic[43:0] _e_3426;
    (* src = "src/tta.spade:248,9" *)
    logic[10:0] _e_3423;
    (* src = "src/tta.spade:248,9" *)
    logic[32:0] _e_3425;
    (* src = "src/tta.spade:248,32" *)
    logic[31:0] x_n42;
    logic _e_8876;
    logic _e_8878;
    logic _e_8880;
    logic _e_8881;
    (* src = "src/tta.spade:248,63" *)
    logic[2:0] _e_3429;
    (* src = "src/tta.spade:248,49" *)
    logic[42:0] _e_3428;
    (* src = "src/tta.spade:248,44" *)
    logic[43:0] _e_3427;
    (* src = "src/tta.spade:249,9" *)
    logic[43:0] _e_3434;
    (* src = "src/tta.spade:249,9" *)
    logic[10:0] _e_3431;
    (* src = "src/tta.spade:249,9" *)
    logic[32:0] _e_3433;
    (* src = "src/tta.spade:249,32" *)
    logic[31:0] x_n43;
    logic _e_8884;
    logic _e_8886;
    logic _e_8888;
    logic _e_8889;
    (* src = "src/tta.spade:249,63" *)
    logic[2:0] _e_3437;
    (* src = "src/tta.spade:249,49" *)
    logic[42:0] _e_3436;
    (* src = "src/tta.spade:249,44" *)
    logic[43:0] _e_3435;
    (* src = "src/tta.spade:250,9" *)
    logic[43:0] _e_3442;
    (* src = "src/tta.spade:250,9" *)
    logic[10:0] _e_3439;
    (* src = "src/tta.spade:250,9" *)
    logic[32:0] _e_3441;
    (* src = "src/tta.spade:250,32" *)
    logic[31:0] x_n44;
    logic _e_8892;
    logic _e_8894;
    logic _e_8896;
    logic _e_8897;
    (* src = "src/tta.spade:250,63" *)
    logic[2:0] _e_3445;
    (* src = "src/tta.spade:250,49" *)
    logic[42:0] _e_3444;
    (* src = "src/tta.spade:250,44" *)
    logic[43:0] _e_3443;
    (* src = "src/tta.spade:251,9" *)
    logic[43:0] _e_3450;
    (* src = "src/tta.spade:251,9" *)
    logic[10:0] _e_3447;
    (* src = "src/tta.spade:251,9" *)
    logic[32:0] _e_3449;
    (* src = "src/tta.spade:251,32" *)
    logic[31:0] x_n45;
    logic _e_8900;
    logic _e_8902;
    logic _e_8904;
    logic _e_8905;
    (* src = "src/tta.spade:251,63" *)
    logic[2:0] _e_3453;
    (* src = "src/tta.spade:251,49" *)
    logic[42:0] _e_3452;
    (* src = "src/tta.spade:251,44" *)
    logic[43:0] _e_3451;
    (* src = "src/tta.spade:253,9" *)
    logic[43:0] _e_3458;
    (* src = "src/tta.spade:253,9" *)
    logic[10:0] _e_3455;
    (* src = "src/tta.spade:253,9" *)
    logic[32:0] _e_3457;
    (* src = "src/tta.spade:253,34" *)
    logic[31:0] x_n46;
    logic _e_8908;
    logic _e_8910;
    logic _e_8912;
    logic _e_8913;
    (* src = "src/tta.spade:253,66" *)
    logic[2:0] _e_3461;
    (* src = "src/tta.spade:253,51" *)
    logic[42:0] _e_3460;
    (* src = "src/tta.spade:253,46" *)
    logic[43:0] _e_3459;
    (* src = "src/tta.spade:254,9" *)
    logic[43:0] _e_3466;
    (* src = "src/tta.spade:254,9" *)
    logic[10:0] _e_3463;
    (* src = "src/tta.spade:254,9" *)
    logic[32:0] _e_3465;
    (* src = "src/tta.spade:254,34" *)
    logic[31:0] x_n47;
    logic _e_8916;
    logic _e_8918;
    logic _e_8920;
    logic _e_8921;
    (* src = "src/tta.spade:254,66" *)
    logic[2:0] _e_3469;
    (* src = "src/tta.spade:254,51" *)
    logic[42:0] _e_3468;
    (* src = "src/tta.spade:254,46" *)
    logic[43:0] _e_3467;
    (* src = "src/tta.spade:255,9" *)
    logic[43:0] _e_3474;
    (* src = "src/tta.spade:255,9" *)
    logic[10:0] _e_3471;
    (* src = "src/tta.spade:255,9" *)
    logic[32:0] _e_3473;
    (* src = "src/tta.spade:255,34" *)
    logic[31:0] x_n48;
    logic _e_8924;
    logic _e_8926;
    logic _e_8928;
    logic _e_8929;
    (* src = "src/tta.spade:255,66" *)
    logic[2:0] _e_3477;
    (* src = "src/tta.spade:255,51" *)
    logic[42:0] _e_3476;
    (* src = "src/tta.spade:255,46" *)
    logic[43:0] _e_3475;
    (* src = "src/tta.spade:256,9" *)
    logic[43:0] _e_3482;
    (* src = "src/tta.spade:256,9" *)
    logic[10:0] _e_3479;
    (* src = "src/tta.spade:256,9" *)
    logic[32:0] _e_3481;
    (* src = "src/tta.spade:256,34" *)
    logic[31:0] x_n49;
    logic _e_8932;
    logic _e_8934;
    logic _e_8936;
    logic _e_8937;
    (* src = "src/tta.spade:256,66" *)
    logic[2:0] _e_3485;
    (* src = "src/tta.spade:256,51" *)
    logic[42:0] _e_3484;
    (* src = "src/tta.spade:256,46" *)
    logic[43:0] _e_3483;
    (* src = "src/tta.spade:257,9" *)
    logic[43:0] _e_3490;
    (* src = "src/tta.spade:257,9" *)
    logic[10:0] _e_3487;
    (* src = "src/tta.spade:257,9" *)
    logic[32:0] _e_3489;
    (* src = "src/tta.spade:257,34" *)
    logic[31:0] x_n50;
    logic _e_8940;
    logic _e_8942;
    logic _e_8944;
    logic _e_8945;
    (* src = "src/tta.spade:257,66" *)
    logic[2:0] _e_3493;
    (* src = "src/tta.spade:257,51" *)
    logic[42:0] _e_3492;
    (* src = "src/tta.spade:257,46" *)
    logic[43:0] _e_3491;
    (* src = "src/tta.spade:258,9" *)
    logic[43:0] _e_3498;
    (* src = "src/tta.spade:258,9" *)
    logic[10:0] _e_3495;
    (* src = "src/tta.spade:258,9" *)
    logic[32:0] _e_3497;
    (* src = "src/tta.spade:258,35" *)
    logic[31:0] x_n51;
    logic _e_8948;
    logic _e_8950;
    logic _e_8952;
    logic _e_8953;
    (* src = "src/tta.spade:258,67" *)
    logic[2:0] _e_3501;
    (* src = "src/tta.spade:258,52" *)
    logic[42:0] _e_3500;
    (* src = "src/tta.spade:258,47" *)
    logic[43:0] _e_3499;
    (* src = "src/tta.spade:260,9" *)
    logic[43:0] _e_3506;
    (* src = "src/tta.spade:260,9" *)
    logic[10:0] _e_3503;
    (* src = "src/tta.spade:260,9" *)
    logic[32:0] _e_3505;
    (* src = "src/tta.spade:260,32" *)
    logic[31:0] x_n52;
    logic _e_8956;
    logic _e_8958;
    logic _e_8960;
    logic _e_8961;
    (* src = "src/tta.spade:260,49" *)
    logic[42:0] _e_3508;
    (* src = "src/tta.spade:260,44" *)
    logic[43:0] _e_3507;
    (* src = "src/tta.spade:261,9" *)
    logic[43:0] _e_3513;
    (* src = "src/tta.spade:261,9" *)
    logic[10:0] _e_3510;
    (* src = "src/tta.spade:261,9" *)
    logic[32:0] _e_3512;
    (* src = "src/tta.spade:261,32" *)
    logic[31:0] x_n53;
    logic _e_8964;
    logic _e_8966;
    logic _e_8968;
    logic _e_8969;
    (* src = "src/tta.spade:261,49" *)
    logic[42:0] _e_3515;
    (* src = "src/tta.spade:261,44" *)
    logic[43:0] _e_3514;
    (* src = "src/tta.spade:263,9" *)
    logic[43:0] _e_3520;
    (* src = "src/tta.spade:263,9" *)
    logic[10:0] _e_3517;
    (* src = "src/tta.spade:263,9" *)
    logic[32:0] _e_3519;
    (* src = "src/tta.spade:263,32" *)
    logic[31:0] x_n54;
    logic _e_8972;
    logic _e_8974;
    logic _e_8976;
    logic _e_8977;
    (* src = "src/tta.spade:263,49" *)
    logic[42:0] _e_3522;
    (* src = "src/tta.spade:263,44" *)
    logic[43:0] _e_3521;
    (* src = "src/tta.spade:264,9" *)
    logic[43:0] _e_3527;
    (* src = "src/tta.spade:264,9" *)
    logic[10:0] _e_3524;
    (* src = "src/tta.spade:264,9" *)
    logic[32:0] _e_3526;
    (* src = "src/tta.spade:264,32" *)
    logic[31:0] x_n55;
    logic _e_8980;
    logic _e_8982;
    logic _e_8984;
    logic _e_8985;
    (* src = "src/tta.spade:264,49" *)
    logic[42:0] _e_3529;
    (* src = "src/tta.spade:264,44" *)
    logic[43:0] _e_3528;
    (* src = "src/tta.spade:266,9" *)
    logic[43:0] _e_3534;
    (* src = "src/tta.spade:266,9" *)
    logic[10:0] _e_3531;
    (* src = "src/tta.spade:266,9" *)
    logic[32:0] _e_3533;
    (* src = "src/tta.spade:266,37" *)
    logic[31:0] x_n56;
    logic _e_8988;
    logic _e_8990;
    logic _e_8992;
    logic _e_8993;
    (* src = "src/tta.spade:266,54" *)
    logic[42:0] _e_3536;
    (* src = "src/tta.spade:266,49" *)
    logic[43:0] _e_3535;
    (* src = "src/tta.spade:268,9" *)
    logic[43:0] _e_3541;
    (* src = "src/tta.spade:268,9" *)
    logic[10:0] _e_3538;
    (* src = "src/tta.spade:268,9" *)
    logic[32:0] _e_3540;
    (* src = "src/tta.spade:268,27" *)
    logic[31:0] x_n57;
    logic _e_8996;
    logic _e_8998;
    logic _e_9000;
    logic _e_9001;
    (* src = "src/tta.spade:268,44" *)
    logic[42:0] _e_3543;
    (* src = "src/tta.spade:268,39" *)
    logic[43:0] _e_3542;
    (* src = "src/tta.spade:269,9" *)
    logic[43:0] _e_3548;
    (* src = "src/tta.spade:269,9" *)
    logic[10:0] _e_3545;
    (* src = "src/tta.spade:269,9" *)
    logic[32:0] _e_3547;
    (* src = "src/tta.spade:269,27" *)
    logic[31:0] x_n58;
    logic _e_9004;
    logic _e_9006;
    logic _e_9008;
    logic _e_9009;
    (* src = "src/tta.spade:269,44" *)
    logic[42:0] _e_3550;
    (* src = "src/tta.spade:269,39" *)
    logic[43:0] _e_3549;
    (* src = "src/tta.spade:270,9" *)
    logic[43:0] _e_3555;
    (* src = "src/tta.spade:270,9" *)
    logic[10:0] _e_3552;
    (* src = "src/tta.spade:270,9" *)
    logic[32:0] _e_3554;
    (* src = "src/tta.spade:270,27" *)
    logic[31:0] x_n59;
    logic _e_9012;
    logic _e_9014;
    logic _e_9016;
    logic _e_9017;
    (* src = "src/tta.spade:270,59" *)
    logic _e_3558;
    (* src = "src/tta.spade:270,44" *)
    logic[42:0] _e_3557;
    (* src = "src/tta.spade:270,39" *)
    logic[43:0] _e_3556;
    (* src = "src/tta.spade:272,9" *)
    logic[43:0] _e_3564;
    (* src = "src/tta.spade:272,9" *)
    logic[10:0] _e_3561;
    (* src = "src/tta.spade:272,9" *)
    logic[32:0] _e_3563;
    (* src = "src/tta.spade:272,26" *)
    logic[31:0] x_n60;
    logic _e_9020;
    logic _e_9022;
    logic _e_9024;
    logic _e_9025;
    (* src = "src/tta.spade:272,57" *)
    logic _e_3567;
    (* src = "src/tta.spade:272,43" *)
    logic[42:0] _e_3566;
    (* src = "src/tta.spade:272,38" *)
    logic[43:0] _e_3565;
    (* src = "src/tta.spade:273,9" *)
    logic[43:0] _e_3573;
    (* src = "src/tta.spade:273,9" *)
    logic[10:0] _e_3570;
    (* src = "src/tta.spade:273,9" *)
    logic[32:0] _e_3572;
    (* src = "src/tta.spade:273,27" *)
    logic[31:0] x_n61;
    logic _e_9028;
    logic _e_9030;
    logic _e_9032;
    logic _e_9033;
    (* src = "src/tta.spade:273,44" *)
    logic[42:0] _e_3575;
    (* src = "src/tta.spade:273,39" *)
    logic[43:0] _e_3574;
    (* src = "src/tta.spade:274,9" *)
    logic[43:0] _e_3580;
    (* src = "src/tta.spade:274,9" *)
    logic[10:0] _e_3577;
    (* src = "src/tta.spade:274,9" *)
    logic[32:0] _e_3579;
    (* src = "src/tta.spade:274,27" *)
    logic[31:0] x_n62;
    logic _e_9036;
    logic _e_9038;
    logic _e_9040;
    logic _e_9041;
    (* src = "src/tta.spade:274,44" *)
    logic[42:0] _e_3582;
    (* src = "src/tta.spade:274,39" *)
    logic[43:0] _e_3581;
    (* src = "src/tta.spade:276,9" *)
    logic[43:0] _e_3587;
    (* src = "src/tta.spade:276,9" *)
    logic[10:0] _e_3584;
    (* src = "src/tta.spade:276,9" *)
    logic[32:0] _e_3586;
    (* src = "src/tta.spade:276,26" *)
    logic[31:0] x_n63;
    logic _e_9044;
    logic _e_9046;
    logic _e_9048;
    logic _e_9049;
    (* src = "src/tta.spade:276,43" *)
    logic[42:0] _e_3589;
    (* src = "src/tta.spade:276,38" *)
    logic[43:0] _e_3588;
    (* src = "src/tta.spade:277,9" *)
    logic[43:0] _e_3594;
    (* src = "src/tta.spade:277,9" *)
    logic[10:0] _e_3591;
    (* src = "src/tta.spade:277,9" *)
    logic[32:0] _e_3593;
    (* src = "src/tta.spade:277,26" *)
    logic[31:0] x_n64;
    logic _e_9052;
    logic _e_9054;
    logic _e_9056;
    logic _e_9057;
    (* src = "src/tta.spade:277,43" *)
    logic[42:0] _e_3596;
    (* src = "src/tta.spade:277,38" *)
    logic[43:0] _e_3595;
    (* src = "src/tta.spade:278,9" *)
    logic[43:0] _e_3601;
    (* src = "src/tta.spade:278,9" *)
    logic[10:0] _e_3598;
    (* src = "src/tta.spade:278,9" *)
    logic[32:0] _e_3600;
    (* src = "src/tta.spade:278,25" *)
    logic[31:0] x_n65;
    logic _e_9060;
    logic _e_9062;
    logic _e_9064;
    logic _e_9065;
    (* src = "src/tta.spade:278,42" *)
    logic[42:0] _e_3603;
    (* src = "src/tta.spade:278,37" *)
    logic[43:0] _e_3602;
    (* src = "src/tta.spade:279,9" *)
    logic[43:0] _e_3608;
    (* src = "src/tta.spade:279,9" *)
    logic[10:0] _e_3605;
    (* src = "src/tta.spade:279,9" *)
    logic[32:0] _e_3607;
    (* src = "src/tta.spade:279,26" *)
    logic[31:0] x_n66;
    logic _e_9068;
    logic _e_9070;
    logic _e_9072;
    logic _e_9073;
    (* src = "src/tta.spade:279,43" *)
    logic[42:0] _e_3610;
    (* src = "src/tta.spade:279,38" *)
    logic[43:0] _e_3609;
    (* src = "src/tta.spade:281,9" *)
    logic[43:0] _e_3615;
    (* src = "src/tta.spade:281,9" *)
    logic[10:0] _e_3612;
    (* src = "src/tta.spade:281,9" *)
    logic[32:0] _e_3614;
    (* src = "src/tta.spade:281,26" *)
    logic[31:0] x_n67;
    logic _e_9076;
    logic _e_9078;
    logic _e_9080;
    logic _e_9081;
    (* src = "src/tta.spade:281,43" *)
    logic[42:0] _e_3617;
    (* src = "src/tta.spade:281,38" *)
    logic[43:0] _e_3616;
    (* src = "src/tta.spade:283,9" *)
    logic[43:0] _e_3622;
    (* src = "src/tta.spade:283,9" *)
    logic[10:0] _e_3619;
    (* src = "src/tta.spade:283,9" *)
    logic[32:0] _e_3621;
    (* src = "src/tta.spade:283,28" *)
    logic[31:0] x_n68;
    logic _e_9084;
    logic _e_9086;
    logic _e_9088;
    logic _e_9089;
    (* src = "src/tta.spade:283,45" *)
    logic[42:0] _e_3624;
    (* src = "src/tta.spade:283,40" *)
    logic[43:0] _e_3623;
    (* src = "src/tta.spade:284,9" *)
    logic[43:0] _e_3629;
    (* src = "src/tta.spade:284,9" *)
    logic[10:0] _e_3626;
    (* src = "src/tta.spade:284,9" *)
    logic[32:0] _e_3628;
    (* src = "src/tta.spade:284,33" *)
    logic[31:0] x_n69;
    logic _e_9092;
    logic _e_9094;
    logic _e_9096;
    logic _e_9097;
    (* src = "src/tta.spade:284,50" *)
    logic[42:0] _e_3631;
    (* src = "src/tta.spade:284,45" *)
    logic[43:0] _e_3630;
    (* src = "src/tta.spade:285,9" *)
    logic[43:0] _e_3636;
    (* src = "src/tta.spade:285,9" *)
    logic[10:0] _e_3633;
    (* src = "src/tta.spade:285,9" *)
    logic[32:0] _e_3635;
    (* src = "src/tta.spade:285,32" *)
    logic[31:0] x_n70;
    logic _e_9100;
    logic _e_9102;
    logic _e_9104;
    logic _e_9105;
    (* src = "src/tta.spade:285,49" *)
    logic[42:0] _e_3638;
    (* src = "src/tta.spade:285,44" *)
    logic[43:0] _e_3637;
    (* src = "src/tta.spade:287,9" *)
    logic[43:0] _e_3642;
    (* src = "src/tta.spade:287,9" *)
    logic[10:0] _e_3639;
    (* src = "src/tta.spade:287,9" *)
    logic[32:0] _e_3641;
    (* src = "src/tta.spade:287,32" *)
    logic[31:0] x_n71;
    logic _e_9108;
    logic _e_9110;
    logic _e_9112;
    logic _e_9113;
    (* src = "src/tta.spade:287,63" *)
    logic[7:0] _e_3645;
    (* src = "src/tta.spade:287,49" *)
    logic[42:0] _e_3644;
    (* src = "src/tta.spade:287,44" *)
    logic[43:0] _e_3643;
    (* src = "src/tta.spade:288,9" *)
    logic[43:0] _e_3650;
    (* src = "src/tta.spade:288,9" *)
    logic[10:0] _e_3647;
    (* src = "src/tta.spade:288,9" *)
    logic[32:0] _e_3649;
    (* src = "src/tta.spade:288,32" *)
    logic[31:0] x_n72;
    logic _e_9116;
    logic _e_9118;
    logic _e_9120;
    logic _e_9121;
    (* src = "src/tta.spade:288,49" *)
    logic[42:0] _e_3652;
    (* src = "src/tta.spade:288,44" *)
    logic[43:0] _e_3651;
    (* src = "src/tta.spade:290,9" *)
    logic[43:0] _e_3656;
    (* src = "src/tta.spade:290,9" *)
    logic[10:0] _e_3653;
    (* src = "src/tta.spade:290,9" *)
    logic[32:0] _e_3655;
    (* src = "src/tta.spade:290,33" *)
    logic[31:0] x_n73;
    logic _e_9124;
    logic _e_9126;
    logic _e_9128;
    logic _e_9129;
    (* src = "src/tta.spade:290,65" *)
    logic[7:0] _e_3659;
    (* src = "src/tta.spade:290,50" *)
    logic[42:0] _e_3658;
    (* src = "src/tta.spade:290,45" *)
    logic[43:0] _e_3657;
    (* src = "src/tta.spade:291,9" *)
    logic[43:0] _e_3664;
    (* src = "src/tta.spade:291,9" *)
    logic[10:0] _e_3661;
    (* src = "src/tta.spade:291,9" *)
    logic[32:0] _e_3663;
    (* src = "src/tta.spade:291,33" *)
    logic[31:0] x_n74;
    logic _e_9132;
    logic _e_9134;
    logic _e_9136;
    logic _e_9137;
    (* src = "src/tta.spade:291,50" *)
    logic[42:0] _e_3666;
    (* src = "src/tta.spade:291,45" *)
    logic[43:0] _e_3665;
    (* src = "src/tta.spade:293,9" *)
    logic[43:0] \_ ;
    (* src = "src/tta.spade:293,14" *)
    logic[43:0] _e_3668;
    (* src = "src/tta.spade:196,5" *)
    logic[43:0] _e_3092;
    assign _e_3093 = {\dst , \v };
    assign _e_3100 = _e_3093;
    assign _e_3097 = _e_3093[43:33];
    assign \i  = _e_3097[3:0];
    assign _e_3099 = _e_3093[32:0];
    assign \x  = _e_3099[31:0];
    assign _e_8538 = _e_3097[10:4] == 7'd0;
    localparam[0:0] _e_8539 = 1;
    assign _e_8540 = _e_8538 && _e_8539;
    assign _e_8542 = _e_3099[32] == 1'd1;
    localparam[0:0] _e_8543 = 1;
    assign _e_8544 = _e_8542 && _e_8543;
    assign _e_8545 = _e_8540 && _e_8544;
    assign _e_3102 = {6'd0, \i , \x , 1'bX};
    assign _e_3101 = {1'd1, _e_3102};
    assign _e_3108 = _e_3093;
    assign _e_3105 = _e_3093[43:33];
    assign _e_3107 = _e_3093[32:0];
    assign x_n1 = _e_3107[31:0];
    assign _e_8548 = _e_3105[10:4] == 7'd1;
    assign _e_8550 = _e_3107[32] == 1'd1;
    localparam[0:0] _e_8551 = 1;
    assign _e_8552 = _e_8550 && _e_8551;
    assign _e_8553 = _e_8548 && _e_8552;
    assign _e_3110 = {6'd1, x_n1, 5'bX};
    assign _e_3109 = {1'd1, _e_3110};
    assign _e_3115 = _e_3093;
    assign _e_3112 = _e_3093[43:33];
    assign _e_3114 = _e_3093[32:0];
    assign x_n2 = _e_3114[31:0];
    assign _e_8556 = _e_3112[10:4] == 7'd2;
    assign _e_8558 = _e_3114[32] == 1'd1;
    localparam[0:0] _e_8559 = 1;
    assign _e_8560 = _e_8558 && _e_8559;
    assign _e_8561 = _e_8556 && _e_8560;
    assign _e_3118 = {5'd0};
    assign _e_3117 = {6'd2, _e_3118, x_n2};
    assign _e_3116 = {1'd1, _e_3117};
    assign _e_3123 = _e_3093;
    assign _e_3120 = _e_3093[43:33];
    assign _e_3122 = _e_3093[32:0];
    assign x_n3 = _e_3122[31:0];
    assign _e_8564 = _e_3120[10:4] == 7'd3;
    assign _e_8566 = _e_3122[32] == 1'd1;
    localparam[0:0] _e_8567 = 1;
    assign _e_8568 = _e_8566 && _e_8567;
    assign _e_8569 = _e_8564 && _e_8568;
    assign _e_3126 = {5'd1};
    assign _e_3125 = {6'd2, _e_3126, x_n3};
    assign _e_3124 = {1'd1, _e_3125};
    assign _e_3131 = _e_3093;
    assign _e_3128 = _e_3093[43:33];
    assign _e_3130 = _e_3093[32:0];
    assign x_n4 = _e_3130[31:0];
    assign _e_8572 = _e_3128[10:4] == 7'd4;
    assign _e_8574 = _e_3130[32] == 1'd1;
    localparam[0:0] _e_8575 = 1;
    assign _e_8576 = _e_8574 && _e_8575;
    assign _e_8577 = _e_8572 && _e_8576;
    assign _e_3134 = {5'd2};
    assign _e_3133 = {6'd2, _e_3134, x_n4};
    assign _e_3132 = {1'd1, _e_3133};
    assign _e_3139 = _e_3093;
    assign _e_3136 = _e_3093[43:33];
    assign _e_3138 = _e_3093[32:0];
    assign x_n5 = _e_3138[31:0];
    assign _e_8580 = _e_3136[10:4] == 7'd5;
    assign _e_8582 = _e_3138[32] == 1'd1;
    localparam[0:0] _e_8583 = 1;
    assign _e_8584 = _e_8582 && _e_8583;
    assign _e_8585 = _e_8580 && _e_8584;
    assign _e_3142 = {5'd3};
    assign _e_3141 = {6'd2, _e_3142, x_n5};
    assign _e_3140 = {1'd1, _e_3141};
    assign _e_3147 = _e_3093;
    assign _e_3144 = _e_3093[43:33];
    assign _e_3146 = _e_3093[32:0];
    assign x_n6 = _e_3146[31:0];
    assign _e_8588 = _e_3144[10:4] == 7'd6;
    assign _e_8590 = _e_3146[32] == 1'd1;
    localparam[0:0] _e_8591 = 1;
    assign _e_8592 = _e_8590 && _e_8591;
    assign _e_8593 = _e_8588 && _e_8592;
    assign _e_3150 = {5'd4};
    assign _e_3149 = {6'd2, _e_3150, x_n6};
    assign _e_3148 = {1'd1, _e_3149};
    assign _e_3155 = _e_3093;
    assign _e_3152 = _e_3093[43:33];
    assign _e_3154 = _e_3093[32:0];
    assign x_n7 = _e_3154[31:0];
    assign _e_8596 = _e_3152[10:4] == 7'd8;
    assign _e_8598 = _e_3154[32] == 1'd1;
    localparam[0:0] _e_8599 = 1;
    assign _e_8600 = _e_8598 && _e_8599;
    assign _e_8601 = _e_8596 && _e_8600;
    assign _e_3158 = {5'd6};
    assign _e_3157 = {6'd2, _e_3158, x_n7};
    assign _e_3156 = {1'd1, _e_3157};
    assign _e_3163 = _e_3093;
    assign _e_3160 = _e_3093[43:33];
    assign _e_3162 = _e_3093[32:0];
    assign x_n8 = _e_3162[31:0];
    assign _e_8604 = _e_3160[10:4] == 7'd9;
    assign _e_8606 = _e_3162[32] == 1'd1;
    localparam[0:0] _e_8607 = 1;
    assign _e_8608 = _e_8606 && _e_8607;
    assign _e_8609 = _e_8604 && _e_8608;
    assign _e_3166 = {5'd7};
    assign _e_3165 = {6'd2, _e_3166, x_n8};
    assign _e_3164 = {1'd1, _e_3165};
    assign _e_3171 = _e_3093;
    assign _e_3168 = _e_3093[43:33];
    assign _e_3170 = _e_3093[32:0];
    assign x_n9 = _e_3170[31:0];
    assign _e_8612 = _e_3168[10:4] == 7'd10;
    assign _e_8614 = _e_3170[32] == 1'd1;
    localparam[0:0] _e_8615 = 1;
    assign _e_8616 = _e_8614 && _e_8615;
    assign _e_8617 = _e_8612 && _e_8616;
    assign _e_3174 = {5'd8};
    assign _e_3173 = {6'd2, _e_3174, x_n9};
    assign _e_3172 = {1'd1, _e_3173};
    assign _e_3179 = _e_3093;
    assign _e_3176 = _e_3093[43:33];
    assign _e_3178 = _e_3093[32:0];
    assign x_n10 = _e_3178[31:0];
    assign _e_8620 = _e_3176[10:4] == 7'd11;
    assign _e_8622 = _e_3178[32] == 1'd1;
    localparam[0:0] _e_8623 = 1;
    assign _e_8624 = _e_8622 && _e_8623;
    assign _e_8625 = _e_8620 && _e_8624;
    assign _e_3182 = {5'd9};
    assign _e_3181 = {6'd2, _e_3182, x_n10};
    assign _e_3180 = {1'd1, _e_3181};
    assign _e_3187 = _e_3093;
    assign _e_3184 = _e_3093[43:33];
    assign _e_3186 = _e_3093[32:0];
    assign x_n11 = _e_3186[31:0];
    assign _e_8628 = _e_3184[10:4] == 7'd12;
    assign _e_8630 = _e_3186[32] == 1'd1;
    localparam[0:0] _e_8631 = 1;
    assign _e_8632 = _e_8630 && _e_8631;
    assign _e_8633 = _e_8628 && _e_8632;
    assign _e_3190 = {5'd10};
    assign _e_3189 = {6'd2, _e_3190, x_n11};
    assign _e_3188 = {1'd1, _e_3189};
    assign _e_3195 = _e_3093;
    assign _e_3192 = _e_3093[43:33];
    assign _e_3194 = _e_3093[32:0];
    assign x_n12 = _e_3194[31:0];
    assign _e_8636 = _e_3192[10:4] == 7'd13;
    assign _e_8638 = _e_3194[32] == 1'd1;
    localparam[0:0] _e_8639 = 1;
    assign _e_8640 = _e_8638 && _e_8639;
    assign _e_8641 = _e_8636 && _e_8640;
    assign _e_3198 = {5'd11};
    assign _e_3197 = {6'd2, _e_3198, x_n12};
    assign _e_3196 = {1'd1, _e_3197};
    assign _e_3203 = _e_3093;
    assign _e_3200 = _e_3093[43:33];
    assign _e_3202 = _e_3093[32:0];
    assign x_n13 = _e_3202[31:0];
    assign _e_8644 = _e_3200[10:4] == 7'd14;
    assign _e_8646 = _e_3202[32] == 1'd1;
    localparam[0:0] _e_8647 = 1;
    assign _e_8648 = _e_8646 && _e_8647;
    assign _e_8649 = _e_8644 && _e_8648;
    assign _e_3206 = {5'd12};
    assign _e_3205 = {6'd2, _e_3206, x_n13};
    assign _e_3204 = {1'd1, _e_3205};
    assign _e_3211 = _e_3093;
    assign _e_3208 = _e_3093[43:33];
    assign _e_3210 = _e_3093[32:0];
    assign x_n14 = _e_3210[31:0];
    assign _e_8652 = _e_3208[10:4] == 7'd15;
    assign _e_8654 = _e_3210[32] == 1'd1;
    localparam[0:0] _e_8655 = 1;
    assign _e_8656 = _e_8654 && _e_8655;
    assign _e_8657 = _e_8652 && _e_8656;
    assign _e_3214 = {5'd13};
    assign _e_3213 = {6'd2, _e_3214, x_n14};
    assign _e_3212 = {1'd1, _e_3213};
    assign _e_3219 = _e_3093;
    assign _e_3216 = _e_3093[43:33];
    assign _e_3218 = _e_3093[32:0];
    assign x_n15 = _e_3218[31:0];
    assign _e_8660 = _e_3216[10:4] == 7'd16;
    assign _e_8662 = _e_3218[32] == 1'd1;
    localparam[0:0] _e_8663 = 1;
    assign _e_8664 = _e_8662 && _e_8663;
    assign _e_8665 = _e_8660 && _e_8664;
    assign _e_3222 = {5'd14};
    assign _e_3221 = {6'd2, _e_3222, x_n15};
    assign _e_3220 = {1'd1, _e_3221};
    assign _e_3227 = _e_3093;
    assign _e_3224 = _e_3093[43:33];
    assign _e_3226 = _e_3093[32:0];
    assign x_n16 = _e_3226[31:0];
    assign _e_8668 = _e_3224[10:4] == 7'd17;
    assign _e_8670 = _e_3226[32] == 1'd1;
    localparam[0:0] _e_8671 = 1;
    assign _e_8672 = _e_8670 && _e_8671;
    assign _e_8673 = _e_8668 && _e_8672;
    assign _e_3230 = {5'd15};
    assign _e_3229 = {6'd2, _e_3230, x_n16};
    assign _e_3228 = {1'd1, _e_3229};
    assign _e_3235 = _e_3093;
    assign _e_3232 = _e_3093[43:33];
    assign _e_3234 = _e_3093[32:0];
    assign x_n17 = _e_3234[31:0];
    assign _e_8676 = _e_3232[10:4] == 7'd18;
    assign _e_8678 = _e_3234[32] == 1'd1;
    localparam[0:0] _e_8679 = 1;
    assign _e_8680 = _e_8678 && _e_8679;
    assign _e_8681 = _e_8676 && _e_8680;
    assign _e_3238 = {5'd16};
    assign _e_3237 = {6'd2, _e_3238, x_n17};
    assign _e_3236 = {1'd1, _e_3237};
    assign _e_3243 = _e_3093;
    assign _e_3240 = _e_3093[43:33];
    assign _e_3242 = _e_3093[32:0];
    assign x_n18 = _e_3242[31:0];
    assign _e_8684 = _e_3240[10:4] == 7'd19;
    assign _e_8686 = _e_3242[32] == 1'd1;
    localparam[0:0] _e_8687 = 1;
    assign _e_8688 = _e_8686 && _e_8687;
    assign _e_8689 = _e_8684 && _e_8688;
    assign _e_3246 = {3'd0};
    assign _e_3245 = {6'd40, _e_3246, x_n18, 2'bX};
    assign _e_3244 = {1'd1, _e_3245};
    assign _e_3251 = _e_3093;
    assign _e_3248 = _e_3093[43:33];
    assign _e_3250 = _e_3093[32:0];
    assign x_n19 = _e_3250[31:0];
    assign _e_8692 = _e_3248[10:4] == 7'd20;
    assign _e_8694 = _e_3250[32] == 1'd1;
    localparam[0:0] _e_8695 = 1;
    assign _e_8696 = _e_8694 && _e_8695;
    assign _e_8697 = _e_8692 && _e_8696;
    assign _e_3254 = {3'd1};
    assign _e_3253 = {6'd40, _e_3254, x_n19, 2'bX};
    assign _e_3252 = {1'd1, _e_3253};
    assign _e_3259 = _e_3093;
    assign _e_3256 = _e_3093[43:33];
    assign _e_3258 = _e_3093[32:0];
    assign x_n20 = _e_3258[31:0];
    assign _e_8700 = _e_3256[10:4] == 7'd21;
    assign _e_8702 = _e_3258[32] == 1'd1;
    localparam[0:0] _e_8703 = 1;
    assign _e_8704 = _e_8702 && _e_8703;
    assign _e_8705 = _e_8700 && _e_8704;
    assign _e_3262 = {3'd2};
    assign _e_3261 = {6'd40, _e_3262, x_n20, 2'bX};
    assign _e_3260 = {1'd1, _e_3261};
    assign _e_3267 = _e_3093;
    assign _e_3264 = _e_3093[43:33];
    assign _e_3266 = _e_3093[32:0];
    assign x_n21 = _e_3266[31:0];
    assign _e_8708 = _e_3264[10:4] == 7'd22;
    assign _e_8710 = _e_3266[32] == 1'd1;
    localparam[0:0] _e_8711 = 1;
    assign _e_8712 = _e_8710 && _e_8711;
    assign _e_8713 = _e_8708 && _e_8712;
    assign _e_3270 = {3'd3};
    assign _e_3269 = {6'd40, _e_3270, x_n21, 2'bX};
    assign _e_3268 = {1'd1, _e_3269};
    assign _e_3275 = _e_3093;
    assign _e_3272 = _e_3093[43:33];
    assign _e_3274 = _e_3093[32:0];
    assign x_n22 = _e_3274[31:0];
    assign _e_8716 = _e_3272[10:4] == 7'd23;
    assign _e_8718 = _e_3274[32] == 1'd1;
    localparam[0:0] _e_8719 = 1;
    assign _e_8720 = _e_8718 && _e_8719;
    assign _e_8721 = _e_8716 && _e_8720;
    assign _e_3278 = {3'd4};
    assign _e_3277 = {6'd40, _e_3278, x_n22, 2'bX};
    assign _e_3276 = {1'd1, _e_3277};
    assign _e_3283 = _e_3093;
    assign _e_3280 = _e_3093[43:33];
    assign _e_3282 = _e_3093[32:0];
    assign x_n23 = _e_3282[31:0];
    assign _e_8724 = _e_3280[10:4] == 7'd24;
    assign _e_8726 = _e_3282[32] == 1'd1;
    localparam[0:0] _e_8727 = 1;
    assign _e_8728 = _e_8726 && _e_8727;
    assign _e_8729 = _e_8724 && _e_8728;
    assign _e_3286 = {3'd5};
    assign _e_3285 = {6'd40, _e_3286, x_n23, 2'bX};
    assign _e_3284 = {1'd1, _e_3285};
    assign _e_3291 = _e_3093;
    assign _e_3288 = _e_3093[43:33];
    assign _e_3290 = _e_3093[32:0];
    assign x_n24 = _e_3290[31:0];
    assign _e_8732 = _e_3288[10:4] == 7'd25;
    assign _e_8734 = _e_3290[32] == 1'd1;
    localparam[0:0] _e_8735 = 1;
    assign _e_8736 = _e_8734 && _e_8735;
    assign _e_8737 = _e_8732 && _e_8736;
    assign _e_3294 = {3'd6};
    assign _e_3293 = {6'd40, _e_3294, x_n24, 2'bX};
    assign _e_3292 = {1'd1, _e_3293};
    assign _e_3299 = _e_3093;
    assign _e_3296 = _e_3093[43:33];
    assign _e_3298 = _e_3093[32:0];
    assign x_n25 = _e_3298[31:0];
    assign _e_8740 = _e_3296[10:4] == 7'd26;
    assign _e_8742 = _e_3298[32] == 1'd1;
    localparam[0:0] _e_8743 = 1;
    assign _e_8744 = _e_8742 && _e_8743;
    assign _e_8745 = _e_8740 && _e_8744;
    assign _e_3302 = {3'd7};
    assign _e_3301 = {6'd40, _e_3302, x_n25, 2'bX};
    assign _e_3300 = {1'd1, _e_3301};
    assign _e_3307 = _e_3093;
    assign _e_3304 = _e_3093[43:33];
    assign _e_3306 = _e_3093[32:0];
    assign x_n26 = _e_3306[31:0];
    assign _e_8748 = _e_3304[10:4] == 7'd27;
    assign _e_8750 = _e_3306[32] == 1'd1;
    localparam[0:0] _e_8751 = 1;
    assign _e_8752 = _e_8750 && _e_8751;
    assign _e_8753 = _e_8748 && _e_8752;
    assign _e_3309 = {6'd14, x_n26, 5'bX};
    assign _e_3308 = {1'd1, _e_3309};
    assign _e_3314 = _e_3093;
    assign _e_3311 = _e_3093[43:33];
    assign _e_3313 = _e_3093[32:0];
    assign x_n27 = _e_3313[31:0];
    assign _e_8756 = _e_3311[10:4] == 7'd28;
    assign _e_8758 = _e_3313[32] == 1'd1;
    localparam[0:0] _e_8759 = 1;
    assign _e_8760 = _e_8758 && _e_8759;
    assign _e_8761 = _e_8756 && _e_8760;
    assign _e_3317 = {1'd0};
    assign _e_3316 = {6'd15, _e_3317, x_n27, 4'bX};
    assign _e_3315 = {1'd1, _e_3316};
    assign _e_3322 = _e_3093;
    assign _e_3319 = _e_3093[43:33];
    assign _e_3321 = _e_3093[32:0];
    assign x_n28 = _e_3321[31:0];
    assign _e_8764 = _e_3319[10:4] == 7'd29;
    assign _e_8766 = _e_3321[32] == 1'd1;
    localparam[0:0] _e_8767 = 1;
    assign _e_8768 = _e_8766 && _e_8767;
    assign _e_8769 = _e_8764 && _e_8768;
    assign _e_3325 = {1'd1};
    assign _e_3324 = {6'd15, _e_3325, x_n28, 4'bX};
    assign _e_3323 = {1'd1, _e_3324};
    assign _e_3330 = _e_3093;
    assign _e_3327 = _e_3093[43:33];
    assign _e_3329 = _e_3093[32:0];
    assign x_n29 = _e_3329[31:0];
    assign _e_8772 = _e_3327[10:4] == 7'd30;
    assign _e_8774 = _e_3329[32] == 1'd1;
    localparam[0:0] _e_8775 = 1;
    assign _e_8776 = _e_8774 && _e_8775;
    assign _e_8777 = _e_8772 && _e_8776;
    assign _e_3333 = x_n29[9:0];
    assign _e_3332 = {6'd3, _e_3333, 27'bX};
    assign _e_3331 = {1'd1, _e_3332};
    assign _e_3338 = _e_3093;
    assign _e_3335 = _e_3093[43:33];
    assign _e_3337 = _e_3093[32:0];
    assign x_n30 = _e_3337[31:0];
    assign _e_8780 = _e_3335[10:4] == 7'd31;
    assign _e_8782 = _e_3337[32] == 1'd1;
    localparam[0:0] _e_8783 = 1;
    assign _e_8784 = _e_8782 && _e_8783;
    assign _e_8785 = _e_8780 && _e_8784;
    assign _e_3341 = x_n30[9:0];
    assign _e_3340 = {6'd18, _e_3341, 27'bX};
    assign _e_3339 = {1'd1, _e_3340};
    assign _e_3346 = _e_3093;
    assign _e_3343 = _e_3093[43:33];
    assign _e_3345 = _e_3093[32:0];
    assign x_n31 = _e_3345[31:0];
    assign _e_8788 = _e_3343[10:4] == 7'd32;
    assign _e_8790 = _e_3345[32] == 1'd1;
    localparam[0:0] _e_8791 = 1;
    assign _e_8792 = _e_8790 && _e_8791;
    assign _e_8793 = _e_8788 && _e_8792;
    assign _e_3348 = {6'd19, x_n31, 5'bX};
    assign _e_3347 = {1'd1, _e_3348};
    assign _e_3353 = _e_3093;
    assign _e_3350 = _e_3093[43:33];
    assign _e_3352 = _e_3093[32:0];
    assign x_n32 = _e_3352[31:0];
    assign _e_8796 = _e_3350[10:4] == 7'd33;
    assign _e_8798 = _e_3352[32] == 1'd1;
    localparam[0:0] _e_8799 = 1;
    assign _e_8800 = _e_8798 && _e_8799;
    assign _e_8801 = _e_8796 && _e_8800;
    assign _e_3355 = {6'd4, x_n32, 5'bX};
    assign _e_3354 = {1'd1, _e_3355};
    assign _e_3360 = _e_3093;
    assign _e_3357 = _e_3093[43:33];
    assign _e_3359 = _e_3093[32:0];
    assign x_n33 = _e_3359[31:0];
    assign _e_8804 = _e_3357[10:4] == 7'd34;
    assign _e_8806 = _e_3359[32] == 1'd1;
    localparam[0:0] _e_8807 = 1;
    assign _e_8808 = _e_8806 && _e_8807;
    assign _e_8809 = _e_8804 && _e_8808;
    assign _e_3362 = {6'd5, x_n33, 5'bX};
    assign _e_3361 = {1'd1, _e_3362};
    assign _e_3367 = _e_3093;
    assign _e_3364 = _e_3093[43:33];
    assign _e_3366 = _e_3093[32:0];
    assign x_n34 = _e_3366[31:0];
    assign _e_8812 = _e_3364[10:4] == 7'd35;
    assign _e_8814 = _e_3366[32] == 1'd1;
    localparam[0:0] _e_8815 = 1;
    assign _e_8816 = _e_8814 && _e_8815;
    assign _e_8817 = _e_8812 && _e_8816;
    assign _e_3369 = {6'd6, x_n34, 5'bX};
    assign _e_3368 = {1'd1, _e_3369};
    assign _e_3374 = _e_3093;
    assign _e_3371 = _e_3093[43:33];
    assign _e_3373 = _e_3093[32:0];
    assign x_n35 = _e_3373[31:0];
    assign _e_8820 = _e_3371[10:4] == 7'd36;
    assign _e_8822 = _e_3373[32] == 1'd1;
    localparam[0:0] _e_8823 = 1;
    assign _e_8824 = _e_8822 && _e_8823;
    assign _e_8825 = _e_8820 && _e_8824;
    assign _e_3376 = {6'd7, x_n35, 5'bX};
    assign _e_3375 = {1'd1, _e_3376};
    assign _e_3381 = _e_3093;
    assign _e_3378 = _e_3093[43:33];
    assign _e_3380 = _e_3093[32:0];
    assign x_n36 = _e_3380[31:0];
    assign _e_8828 = _e_3378[10:4] == 7'd37;
    assign _e_8830 = _e_3380[32] == 1'd1;
    localparam[0:0] _e_8831 = 1;
    assign _e_8832 = _e_8830 && _e_8831;
    assign _e_8833 = _e_8828 && _e_8832;
    assign _e_3383 = {6'd8, x_n36, 5'bX};
    assign _e_3382 = {1'd1, _e_3383};
    assign _e_3388 = _e_3093;
    assign _e_3385 = _e_3093[43:33];
    assign _e_3387 = _e_3093[32:0];
    assign x_n37 = _e_3387[31:0];
    assign _e_8836 = _e_3385[10:4] == 7'd38;
    assign _e_8838 = _e_3387[32] == 1'd1;
    localparam[0:0] _e_8839 = 1;
    assign _e_8840 = _e_8838 && _e_8839;
    assign _e_8841 = _e_8836 && _e_8840;
    assign _e_3390 = {6'd9, x_n37, 5'bX};
    assign _e_3389 = {1'd1, _e_3390};
    assign _e_3395 = _e_3093;
    assign _e_3392 = _e_3093[43:33];
    assign _e_3394 = _e_3093[32:0];
    assign x_n38 = _e_3394[31:0];
    assign _e_8844 = _e_3392[10:4] == 7'd39;
    assign _e_8846 = _e_3394[32] == 1'd1;
    localparam[0:0] _e_8847 = 1;
    assign _e_8848 = _e_8846 && _e_8847;
    assign _e_8849 = _e_8844 && _e_8848;
    assign _e_3398 = x_n38[15:0];
    assign _e_3397 = {6'd10, _e_3398, 21'bX};
    assign _e_3396 = {1'd1, _e_3397};
    assign _e_3403 = _e_3093;
    assign _e_3400 = _e_3093[43:33];
    assign _e_3402 = _e_3093[32:0];
    assign x_n39 = _e_3402[31:0];
    assign _e_8852 = _e_3400[10:4] == 7'd40;
    assign _e_8854 = _e_3402[32] == 1'd1;
    localparam[0:0] _e_8855 = 1;
    assign _e_8856 = _e_8854 && _e_8855;
    assign _e_8857 = _e_8852 && _e_8856;
    assign _e_3405 = {6'd11, x_n39, 5'bX};
    assign _e_3404 = {1'd1, _e_3405};
    assign _e_3410 = _e_3093;
    assign _e_3407 = _e_3093[43:33];
    assign _e_3409 = _e_3093[32:0];
    assign x_n40 = _e_3409[31:0];
    assign _e_8860 = _e_3407[10:4] == 7'd41;
    assign _e_8862 = _e_3409[32] == 1'd1;
    localparam[0:0] _e_8863 = 1;
    assign _e_8864 = _e_8862 && _e_8863;
    assign _e_8865 = _e_8860 && _e_8864;
    assign _e_3413 = {3'd0};
    assign _e_3412 = {6'd12, _e_3413, x_n40, 2'bX};
    assign _e_3411 = {1'd1, _e_3412};
    assign _e_3418 = _e_3093;
    assign _e_3415 = _e_3093[43:33];
    assign _e_3417 = _e_3093[32:0];
    assign x_n41 = _e_3417[31:0];
    assign _e_8868 = _e_3415[10:4] == 7'd42;
    assign _e_8870 = _e_3417[32] == 1'd1;
    localparam[0:0] _e_8871 = 1;
    assign _e_8872 = _e_8870 && _e_8871;
    assign _e_8873 = _e_8868 && _e_8872;
    assign _e_3421 = {3'd1};
    assign _e_3420 = {6'd12, _e_3421, x_n41, 2'bX};
    assign _e_3419 = {1'd1, _e_3420};
    assign _e_3426 = _e_3093;
    assign _e_3423 = _e_3093[43:33];
    assign _e_3425 = _e_3093[32:0];
    assign x_n42 = _e_3425[31:0];
    assign _e_8876 = _e_3423[10:4] == 7'd43;
    assign _e_8878 = _e_3425[32] == 1'd1;
    localparam[0:0] _e_8879 = 1;
    assign _e_8880 = _e_8878 && _e_8879;
    assign _e_8881 = _e_8876 && _e_8880;
    assign _e_3429 = {3'd2};
    assign _e_3428 = {6'd12, _e_3429, x_n42, 2'bX};
    assign _e_3427 = {1'd1, _e_3428};
    assign _e_3434 = _e_3093;
    assign _e_3431 = _e_3093[43:33];
    assign _e_3433 = _e_3093[32:0];
    assign x_n43 = _e_3433[31:0];
    assign _e_8884 = _e_3431[10:4] == 7'd44;
    assign _e_8886 = _e_3433[32] == 1'd1;
    localparam[0:0] _e_8887 = 1;
    assign _e_8888 = _e_8886 && _e_8887;
    assign _e_8889 = _e_8884 && _e_8888;
    assign _e_3437 = {3'd3};
    assign _e_3436 = {6'd12, _e_3437, x_n43, 2'bX};
    assign _e_3435 = {1'd1, _e_3436};
    assign _e_3442 = _e_3093;
    assign _e_3439 = _e_3093[43:33];
    assign _e_3441 = _e_3093[32:0];
    assign x_n44 = _e_3441[31:0];
    assign _e_8892 = _e_3439[10:4] == 7'd45;
    assign _e_8894 = _e_3441[32] == 1'd1;
    localparam[0:0] _e_8895 = 1;
    assign _e_8896 = _e_8894 && _e_8895;
    assign _e_8897 = _e_8892 && _e_8896;
    assign _e_3445 = {3'd4};
    assign _e_3444 = {6'd12, _e_3445, x_n44, 2'bX};
    assign _e_3443 = {1'd1, _e_3444};
    assign _e_3450 = _e_3093;
    assign _e_3447 = _e_3093[43:33];
    assign _e_3449 = _e_3093[32:0];
    assign x_n45 = _e_3449[31:0];
    assign _e_8900 = _e_3447[10:4] == 7'd46;
    assign _e_8902 = _e_3449[32] == 1'd1;
    localparam[0:0] _e_8903 = 1;
    assign _e_8904 = _e_8902 && _e_8903;
    assign _e_8905 = _e_8900 && _e_8904;
    assign _e_3453 = {3'd5};
    assign _e_3452 = {6'd12, _e_3453, x_n45, 2'bX};
    assign _e_3451 = {1'd1, _e_3452};
    assign _e_3458 = _e_3093;
    assign _e_3455 = _e_3093[43:33];
    assign _e_3457 = _e_3093[32:0];
    assign x_n46 = _e_3457[31:0];
    assign _e_8908 = _e_3455[10:4] == 7'd47;
    assign _e_8910 = _e_3457[32] == 1'd1;
    localparam[0:0] _e_8911 = 1;
    assign _e_8912 = _e_8910 && _e_8911;
    assign _e_8913 = _e_8908 && _e_8912;
    assign _e_3461 = {3'd0};
    assign _e_3460 = {6'd13, _e_3461, x_n46, 2'bX};
    assign _e_3459 = {1'd1, _e_3460};
    assign _e_3466 = _e_3093;
    assign _e_3463 = _e_3093[43:33];
    assign _e_3465 = _e_3093[32:0];
    assign x_n47 = _e_3465[31:0];
    assign _e_8916 = _e_3463[10:4] == 7'd48;
    assign _e_8918 = _e_3465[32] == 1'd1;
    localparam[0:0] _e_8919 = 1;
    assign _e_8920 = _e_8918 && _e_8919;
    assign _e_8921 = _e_8916 && _e_8920;
    assign _e_3469 = {3'd1};
    assign _e_3468 = {6'd13, _e_3469, x_n47, 2'bX};
    assign _e_3467 = {1'd1, _e_3468};
    assign _e_3474 = _e_3093;
    assign _e_3471 = _e_3093[43:33];
    assign _e_3473 = _e_3093[32:0];
    assign x_n48 = _e_3473[31:0];
    assign _e_8924 = _e_3471[10:4] == 7'd49;
    assign _e_8926 = _e_3473[32] == 1'd1;
    localparam[0:0] _e_8927 = 1;
    assign _e_8928 = _e_8926 && _e_8927;
    assign _e_8929 = _e_8924 && _e_8928;
    assign _e_3477 = {3'd2};
    assign _e_3476 = {6'd13, _e_3477, x_n48, 2'bX};
    assign _e_3475 = {1'd1, _e_3476};
    assign _e_3482 = _e_3093;
    assign _e_3479 = _e_3093[43:33];
    assign _e_3481 = _e_3093[32:0];
    assign x_n49 = _e_3481[31:0];
    assign _e_8932 = _e_3479[10:4] == 7'd50;
    assign _e_8934 = _e_3481[32] == 1'd1;
    localparam[0:0] _e_8935 = 1;
    assign _e_8936 = _e_8934 && _e_8935;
    assign _e_8937 = _e_8932 && _e_8936;
    assign _e_3485 = {3'd3};
    assign _e_3484 = {6'd13, _e_3485, x_n49, 2'bX};
    assign _e_3483 = {1'd1, _e_3484};
    assign _e_3490 = _e_3093;
    assign _e_3487 = _e_3093[43:33];
    assign _e_3489 = _e_3093[32:0];
    assign x_n50 = _e_3489[31:0];
    assign _e_8940 = _e_3487[10:4] == 7'd51;
    assign _e_8942 = _e_3489[32] == 1'd1;
    localparam[0:0] _e_8943 = 1;
    assign _e_8944 = _e_8942 && _e_8943;
    assign _e_8945 = _e_8940 && _e_8944;
    assign _e_3493 = {3'd4};
    assign _e_3492 = {6'd13, _e_3493, x_n50, 2'bX};
    assign _e_3491 = {1'd1, _e_3492};
    assign _e_3498 = _e_3093;
    assign _e_3495 = _e_3093[43:33];
    assign _e_3497 = _e_3093[32:0];
    assign x_n51 = _e_3497[31:0];
    assign _e_8948 = _e_3495[10:4] == 7'd52;
    assign _e_8950 = _e_3497[32] == 1'd1;
    localparam[0:0] _e_8951 = 1;
    assign _e_8952 = _e_8950 && _e_8951;
    assign _e_8953 = _e_8948 && _e_8952;
    assign _e_3501 = {3'd5};
    assign _e_3500 = {6'd13, _e_3501, x_n51, 2'bX};
    assign _e_3499 = {1'd1, _e_3500};
    assign _e_3506 = _e_3093;
    assign _e_3503 = _e_3093[43:33];
    assign _e_3505 = _e_3093[32:0];
    assign x_n52 = _e_3505[31:0];
    assign _e_8956 = _e_3503[10:4] == 7'd53;
    assign _e_8958 = _e_3505[32] == 1'd1;
    localparam[0:0] _e_8959 = 1;
    assign _e_8960 = _e_8958 && _e_8959;
    assign _e_8961 = _e_8956 && _e_8960;
    assign _e_3508 = {6'd16, x_n52, 5'bX};
    assign _e_3507 = {1'd1, _e_3508};
    assign _e_3513 = _e_3093;
    assign _e_3510 = _e_3093[43:33];
    assign _e_3512 = _e_3093[32:0];
    assign x_n53 = _e_3512[31:0];
    assign _e_8964 = _e_3510[10:4] == 7'd54;
    assign _e_8966 = _e_3512[32] == 1'd1;
    localparam[0:0] _e_8967 = 1;
    assign _e_8968 = _e_8966 && _e_8967;
    assign _e_8969 = _e_8964 && _e_8968;
    assign _e_3515 = {6'd17, x_n53, 5'bX};
    assign _e_3514 = {1'd1, _e_3515};
    assign _e_3520 = _e_3093;
    assign _e_3517 = _e_3093[43:33];
    assign _e_3519 = _e_3093[32:0];
    assign x_n54 = _e_3519[31:0];
    assign _e_8972 = _e_3517[10:4] == 7'd55;
    assign _e_8974 = _e_3519[32] == 1'd1;
    localparam[0:0] _e_8975 = 1;
    assign _e_8976 = _e_8974 && _e_8975;
    assign _e_8977 = _e_8972 && _e_8976;
    assign _e_3522 = {6'd21, x_n54, 5'bX};
    assign _e_3521 = {1'd1, _e_3522};
    assign _e_3527 = _e_3093;
    assign _e_3524 = _e_3093[43:33];
    assign _e_3526 = _e_3093[32:0];
    assign x_n55 = _e_3526[31:0];
    assign _e_8980 = _e_3524[10:4] == 7'd56;
    assign _e_8982 = _e_3526[32] == 1'd1;
    localparam[0:0] _e_8983 = 1;
    assign _e_8984 = _e_8982 && _e_8983;
    assign _e_8985 = _e_8980 && _e_8984;
    assign _e_3529 = {6'd22, x_n55, 5'bX};
    assign _e_3528 = {1'd1, _e_3529};
    assign _e_3534 = _e_3093;
    assign _e_3531 = _e_3093[43:33];
    assign _e_3533 = _e_3093[32:0];
    assign x_n56 = _e_3533[31:0];
    assign _e_8988 = _e_3531[10:4] == 7'd57;
    assign _e_8990 = _e_3533[32] == 1'd1;
    localparam[0:0] _e_8991 = 1;
    assign _e_8992 = _e_8990 && _e_8991;
    assign _e_8993 = _e_8988 && _e_8992;
    assign _e_3536 = {6'd23, x_n56, 5'bX};
    assign _e_3535 = {1'd1, _e_3536};
    assign _e_3541 = _e_3093;
    assign _e_3538 = _e_3093[43:33];
    assign _e_3540 = _e_3093[32:0];
    assign x_n57 = _e_3540[31:0];
    assign _e_8996 = _e_3538[10:4] == 7'd58;
    assign _e_8998 = _e_3540[32] == 1'd1;
    localparam[0:0] _e_8999 = 1;
    assign _e_9000 = _e_8998 && _e_8999;
    assign _e_9001 = _e_8996 && _e_9000;
    assign _e_3543 = {6'd24, x_n57, 5'bX};
    assign _e_3542 = {1'd1, _e_3543};
    assign _e_3548 = _e_3093;
    assign _e_3545 = _e_3093[43:33];
    assign _e_3547 = _e_3093[32:0];
    assign x_n58 = _e_3547[31:0];
    assign _e_9004 = _e_3545[10:4] == 7'd59;
    assign _e_9006 = _e_3547[32] == 1'd1;
    localparam[0:0] _e_9007 = 1;
    assign _e_9008 = _e_9006 && _e_9007;
    assign _e_9009 = _e_9004 && _e_9008;
    assign _e_3550 = {6'd25, x_n58, 5'bX};
    assign _e_3549 = {1'd1, _e_3550};
    assign _e_3555 = _e_3093;
    assign _e_3552 = _e_3093[43:33];
    assign _e_3554 = _e_3093[32:0];
    assign x_n59 = _e_3554[31:0];
    assign _e_9012 = _e_3552[10:4] == 7'd60;
    assign _e_9014 = _e_3554[32] == 1'd1;
    localparam[0:0] _e_9015 = 1;
    assign _e_9016 = _e_9014 && _e_9015;
    assign _e_9017 = _e_9012 && _e_9016;
    localparam[31:0] _e_3560 = 32'd0;
    assign _e_3558 = x_n59 != _e_3560;
    assign _e_3557 = {6'd26, _e_3558, 36'bX};
    assign _e_3556 = {1'd1, _e_3557};
    assign _e_3564 = _e_3093;
    assign _e_3561 = _e_3093[43:33];
    assign _e_3563 = _e_3093[32:0];
    assign x_n60 = _e_3563[31:0];
    assign _e_9020 = _e_3561[10:4] == 7'd61;
    assign _e_9022 = _e_3563[32] == 1'd1;
    localparam[0:0] _e_9023 = 1;
    assign _e_9024 = _e_9022 && _e_9023;
    assign _e_9025 = _e_9020 && _e_9024;
    localparam[31:0] _e_3569 = 32'd0;
    assign _e_3567 = x_n60 != _e_3569;
    assign _e_3566 = {6'd27, _e_3567, 36'bX};
    assign _e_3565 = {1'd1, _e_3566};
    assign _e_3573 = _e_3093;
    assign _e_3570 = _e_3093[43:33];
    assign _e_3572 = _e_3093[32:0];
    assign x_n61 = _e_3572[31:0];
    assign _e_9028 = _e_3570[10:4] == 7'd62;
    assign _e_9030 = _e_3572[32] == 1'd1;
    localparam[0:0] _e_9031 = 1;
    assign _e_9032 = _e_9030 && _e_9031;
    assign _e_9033 = _e_9028 && _e_9032;
    assign _e_3575 = {6'd28, x_n61, 5'bX};
    assign _e_3574 = {1'd1, _e_3575};
    assign _e_3580 = _e_3093;
    assign _e_3577 = _e_3093[43:33];
    assign _e_3579 = _e_3093[32:0];
    assign x_n62 = _e_3579[31:0];
    assign _e_9036 = _e_3577[10:4] == 7'd63;
    assign _e_9038 = _e_3579[32] == 1'd1;
    localparam[0:0] _e_9039 = 1;
    assign _e_9040 = _e_9038 && _e_9039;
    assign _e_9041 = _e_9036 && _e_9040;
    assign _e_3582 = {6'd29, x_n62, 5'bX};
    assign _e_3581 = {1'd1, _e_3582};
    assign _e_3587 = _e_3093;
    assign _e_3584 = _e_3093[43:33];
    assign _e_3586 = _e_3093[32:0];
    assign x_n63 = _e_3586[31:0];
    assign _e_9044 = _e_3584[10:4] == 7'd64;
    assign _e_9046 = _e_3586[32] == 1'd1;
    localparam[0:0] _e_9047 = 1;
    assign _e_9048 = _e_9046 && _e_9047;
    assign _e_9049 = _e_9044 && _e_9048;
    assign _e_3589 = {6'd30, x_n63, 5'bX};
    assign _e_3588 = {1'd1, _e_3589};
    assign _e_3594 = _e_3093;
    assign _e_3591 = _e_3093[43:33];
    assign _e_3593 = _e_3093[32:0];
    assign x_n64 = _e_3593[31:0];
    assign _e_9052 = _e_3591[10:4] == 7'd65;
    assign _e_9054 = _e_3593[32] == 1'd1;
    localparam[0:0] _e_9055 = 1;
    assign _e_9056 = _e_9054 && _e_9055;
    assign _e_9057 = _e_9052 && _e_9056;
    assign _e_3596 = {6'd31, x_n64, 5'bX};
    assign _e_3595 = {1'd1, _e_3596};
    assign _e_3601 = _e_3093;
    assign _e_3598 = _e_3093[43:33];
    assign _e_3600 = _e_3093[32:0];
    assign x_n65 = _e_3600[31:0];
    assign _e_9060 = _e_3598[10:4] == 7'd66;
    assign _e_9062 = _e_3600[32] == 1'd1;
    localparam[0:0] _e_9063 = 1;
    assign _e_9064 = _e_9062 && _e_9063;
    assign _e_9065 = _e_9060 && _e_9064;
    assign _e_3603 = {6'd32, x_n65, 5'bX};
    assign _e_3602 = {1'd1, _e_3603};
    assign _e_3608 = _e_3093;
    assign _e_3605 = _e_3093[43:33];
    assign _e_3607 = _e_3093[32:0];
    assign x_n66 = _e_3607[31:0];
    assign _e_9068 = _e_3605[10:4] == 7'd67;
    assign _e_9070 = _e_3607[32] == 1'd1;
    localparam[0:0] _e_9071 = 1;
    assign _e_9072 = _e_9070 && _e_9071;
    assign _e_9073 = _e_9068 && _e_9072;
    assign _e_3610 = {6'd33, x_n66, 5'bX};
    assign _e_3609 = {1'd1, _e_3610};
    assign _e_3615 = _e_3093;
    assign _e_3612 = _e_3093[43:33];
    assign _e_3614 = _e_3093[32:0];
    assign x_n67 = _e_3614[31:0];
    assign _e_9076 = _e_3612[10:4] == 7'd68;
    assign _e_9078 = _e_3614[32] == 1'd1;
    localparam[0:0] _e_9079 = 1;
    assign _e_9080 = _e_9078 && _e_9079;
    assign _e_9081 = _e_9076 && _e_9080;
    assign _e_3617 = {6'd34, x_n67, 5'bX};
    assign _e_3616 = {1'd1, _e_3617};
    assign _e_3622 = _e_3093;
    assign _e_3619 = _e_3093[43:33];
    assign _e_3621 = _e_3093[32:0];
    assign x_n68 = _e_3621[31:0];
    assign _e_9084 = _e_3619[10:4] == 7'd69;
    assign _e_9086 = _e_3621[32] == 1'd1;
    localparam[0:0] _e_9087 = 1;
    assign _e_9088 = _e_9086 && _e_9087;
    assign _e_9089 = _e_9084 && _e_9088;
    assign _e_3624 = {6'd35, x_n68, 5'bX};
    assign _e_3623 = {1'd1, _e_3624};
    assign _e_3629 = _e_3093;
    assign _e_3626 = _e_3093[43:33];
    assign _e_3628 = _e_3093[32:0];
    assign x_n69 = _e_3628[31:0];
    assign _e_9092 = _e_3626[10:4] == 7'd70;
    assign _e_9094 = _e_3628[32] == 1'd1;
    localparam[0:0] _e_9095 = 1;
    assign _e_9096 = _e_9094 && _e_9095;
    assign _e_9097 = _e_9092 && _e_9096;
    assign _e_3631 = {6'd36, x_n69, 5'bX};
    assign _e_3630 = {1'd1, _e_3631};
    assign _e_3636 = _e_3093;
    assign _e_3633 = _e_3093[43:33];
    assign _e_3635 = _e_3093[32:0];
    assign x_n70 = _e_3635[31:0];
    assign _e_9100 = _e_3633[10:4] == 7'd71;
    assign _e_9102 = _e_3635[32] == 1'd1;
    localparam[0:0] _e_9103 = 1;
    assign _e_9104 = _e_9102 && _e_9103;
    assign _e_9105 = _e_9100 && _e_9104;
    assign _e_3638 = {6'd37, 37'bX};
    assign _e_3637 = {1'd1, _e_3638};
    assign _e_3642 = _e_3093;
    assign _e_3639 = _e_3093[43:33];
    assign _e_3641 = _e_3093[32:0];
    assign x_n71 = _e_3641[31:0];
    assign _e_9108 = _e_3639[10:4] == 7'd72;
    assign _e_9110 = _e_3641[32] == 1'd1;
    localparam[0:0] _e_9111 = 1;
    assign _e_9112 = _e_9110 && _e_9111;
    assign _e_9113 = _e_9108 && _e_9112;
    assign _e_3645 = x_n71[7:0];
    assign _e_3644 = {6'd20, _e_3645, 29'bX};
    assign _e_3643 = {1'd1, _e_3644};
    assign _e_3650 = _e_3093;
    assign _e_3647 = _e_3093[43:33];
    assign _e_3649 = _e_3093[32:0];
    assign x_n72 = _e_3649[31:0];
    assign _e_9116 = _e_3647[10:4] == 7'd75;
    assign _e_9118 = _e_3649[32] == 1'd1;
    localparam[0:0] _e_9119 = 1;
    assign _e_9120 = _e_9118 && _e_9119;
    assign _e_9121 = _e_9116 && _e_9120;
    assign _e_3652 = {6'd42, 37'bX};
    assign _e_3651 = {1'd1, _e_3652};
    assign _e_3656 = _e_3093;
    assign _e_3653 = _e_3093[43:33];
    assign _e_3655 = _e_3093[32:0];
    assign x_n73 = _e_3655[31:0];
    assign _e_9124 = _e_3653[10:4] == 7'd73;
    assign _e_9126 = _e_3655[32] == 1'd1;
    localparam[0:0] _e_9127 = 1;
    assign _e_9128 = _e_9126 && _e_9127;
    assign _e_9129 = _e_9124 && _e_9128;
    assign _e_3659 = x_n73[7:0];
    assign _e_3658 = {6'd38, _e_3659, 29'bX};
    assign _e_3657 = {1'd1, _e_3658};
    assign _e_3664 = _e_3093;
    assign _e_3661 = _e_3093[43:33];
    assign _e_3663 = _e_3093[32:0];
    assign x_n74 = _e_3663[31:0];
    assign _e_9132 = _e_3661[10:4] == 7'd74;
    assign _e_9134 = _e_3663[32] == 1'd1;
    localparam[0:0] _e_9135 = 1;
    assign _e_9136 = _e_9134 && _e_9135;
    assign _e_9137 = _e_9132 && _e_9136;
    assign _e_3666 = {6'd41, 37'bX};
    assign _e_3665 = {1'd1, _e_3666};
    assign \_  = _e_3093;
    localparam[0:0] _e_9138 = 1;
    assign _e_3668 = {1'd0, 43'bX};
    always_comb begin
        priority casez ({_e_8545, _e_8553, _e_8561, _e_8569, _e_8577, _e_8585, _e_8593, _e_8601, _e_8609, _e_8617, _e_8625, _e_8633, _e_8641, _e_8649, _e_8657, _e_8665, _e_8673, _e_8681, _e_8689, _e_8697, _e_8705, _e_8713, _e_8721, _e_8729, _e_8737, _e_8745, _e_8753, _e_8761, _e_8769, _e_8777, _e_8785, _e_8793, _e_8801, _e_8809, _e_8817, _e_8825, _e_8833, _e_8841, _e_8849, _e_8857, _e_8865, _e_8873, _e_8881, _e_8889, _e_8897, _e_8905, _e_8913, _e_8921, _e_8929, _e_8937, _e_8945, _e_8953, _e_8961, _e_8969, _e_8977, _e_8985, _e_8993, _e_9001, _e_9009, _e_9017, _e_9025, _e_9033, _e_9041, _e_9049, _e_9057, _e_9065, _e_9073, _e_9081, _e_9089, _e_9097, _e_9105, _e_9113, _e_9121, _e_9129, _e_9137, _e_9138})
            76'b1???????????????????????????????????????????????????????????????????????????: _e_3092 = _e_3101;
            76'b01??????????????????????????????????????????????????????????????????????????: _e_3092 = _e_3109;
            76'b001?????????????????????????????????????????????????????????????????????????: _e_3092 = _e_3116;
            76'b0001????????????????????????????????????????????????????????????????????????: _e_3092 = _e_3124;
            76'b00001???????????????????????????????????????????????????????????????????????: _e_3092 = _e_3132;
            76'b000001??????????????????????????????????????????????????????????????????????: _e_3092 = _e_3140;
            76'b0000001?????????????????????????????????????????????????????????????????????: _e_3092 = _e_3148;
            76'b00000001????????????????????????????????????????????????????????????????????: _e_3092 = _e_3156;
            76'b000000001???????????????????????????????????????????????????????????????????: _e_3092 = _e_3164;
            76'b0000000001??????????????????????????????????????????????????????????????????: _e_3092 = _e_3172;
            76'b00000000001?????????????????????????????????????????????????????????????????: _e_3092 = _e_3180;
            76'b000000000001????????????????????????????????????????????????????????????????: _e_3092 = _e_3188;
            76'b0000000000001???????????????????????????????????????????????????????????????: _e_3092 = _e_3196;
            76'b00000000000001??????????????????????????????????????????????????????????????: _e_3092 = _e_3204;
            76'b000000000000001?????????????????????????????????????????????????????????????: _e_3092 = _e_3212;
            76'b0000000000000001????????????????????????????????????????????????????????????: _e_3092 = _e_3220;
            76'b00000000000000001???????????????????????????????????????????????????????????: _e_3092 = _e_3228;
            76'b000000000000000001??????????????????????????????????????????????????????????: _e_3092 = _e_3236;
            76'b0000000000000000001?????????????????????????????????????????????????????????: _e_3092 = _e_3244;
            76'b00000000000000000001????????????????????????????????????????????????????????: _e_3092 = _e_3252;
            76'b000000000000000000001???????????????????????????????????????????????????????: _e_3092 = _e_3260;
            76'b0000000000000000000001??????????????????????????????????????????????????????: _e_3092 = _e_3268;
            76'b00000000000000000000001?????????????????????????????????????????????????????: _e_3092 = _e_3276;
            76'b000000000000000000000001????????????????????????????????????????????????????: _e_3092 = _e_3284;
            76'b0000000000000000000000001???????????????????????????????????????????????????: _e_3092 = _e_3292;
            76'b00000000000000000000000001??????????????????????????????????????????????????: _e_3092 = _e_3300;
            76'b000000000000000000000000001?????????????????????????????????????????????????: _e_3092 = _e_3308;
            76'b0000000000000000000000000001????????????????????????????????????????????????: _e_3092 = _e_3315;
            76'b00000000000000000000000000001???????????????????????????????????????????????: _e_3092 = _e_3323;
            76'b000000000000000000000000000001??????????????????????????????????????????????: _e_3092 = _e_3331;
            76'b0000000000000000000000000000001?????????????????????????????????????????????: _e_3092 = _e_3339;
            76'b00000000000000000000000000000001????????????????????????????????????????????: _e_3092 = _e_3347;
            76'b000000000000000000000000000000001???????????????????????????????????????????: _e_3092 = _e_3354;
            76'b0000000000000000000000000000000001??????????????????????????????????????????: _e_3092 = _e_3361;
            76'b00000000000000000000000000000000001?????????????????????????????????????????: _e_3092 = _e_3368;
            76'b000000000000000000000000000000000001????????????????????????????????????????: _e_3092 = _e_3375;
            76'b0000000000000000000000000000000000001???????????????????????????????????????: _e_3092 = _e_3382;
            76'b00000000000000000000000000000000000001??????????????????????????????????????: _e_3092 = _e_3389;
            76'b000000000000000000000000000000000000001?????????????????????????????????????: _e_3092 = _e_3396;
            76'b0000000000000000000000000000000000000001????????????????????????????????????: _e_3092 = _e_3404;
            76'b00000000000000000000000000000000000000001???????????????????????????????????: _e_3092 = _e_3411;
            76'b000000000000000000000000000000000000000001??????????????????????????????????: _e_3092 = _e_3419;
            76'b0000000000000000000000000000000000000000001?????????????????????????????????: _e_3092 = _e_3427;
            76'b00000000000000000000000000000000000000000001????????????????????????????????: _e_3092 = _e_3435;
            76'b000000000000000000000000000000000000000000001???????????????????????????????: _e_3092 = _e_3443;
            76'b0000000000000000000000000000000000000000000001??????????????????????????????: _e_3092 = _e_3451;
            76'b00000000000000000000000000000000000000000000001?????????????????????????????: _e_3092 = _e_3459;
            76'b000000000000000000000000000000000000000000000001????????????????????????????: _e_3092 = _e_3467;
            76'b0000000000000000000000000000000000000000000000001???????????????????????????: _e_3092 = _e_3475;
            76'b00000000000000000000000000000000000000000000000001??????????????????????????: _e_3092 = _e_3483;
            76'b000000000000000000000000000000000000000000000000001?????????????????????????: _e_3092 = _e_3491;
            76'b0000000000000000000000000000000000000000000000000001????????????????????????: _e_3092 = _e_3499;
            76'b00000000000000000000000000000000000000000000000000001???????????????????????: _e_3092 = _e_3507;
            76'b000000000000000000000000000000000000000000000000000001??????????????????????: _e_3092 = _e_3514;
            76'b0000000000000000000000000000000000000000000000000000001?????????????????????: _e_3092 = _e_3521;
            76'b00000000000000000000000000000000000000000000000000000001????????????????????: _e_3092 = _e_3528;
            76'b000000000000000000000000000000000000000000000000000000001???????????????????: _e_3092 = _e_3535;
            76'b0000000000000000000000000000000000000000000000000000000001??????????????????: _e_3092 = _e_3542;
            76'b00000000000000000000000000000000000000000000000000000000001?????????????????: _e_3092 = _e_3549;
            76'b000000000000000000000000000000000000000000000000000000000001????????????????: _e_3092 = _e_3556;
            76'b0000000000000000000000000000000000000000000000000000000000001???????????????: _e_3092 = _e_3565;
            76'b00000000000000000000000000000000000000000000000000000000000001??????????????: _e_3092 = _e_3574;
            76'b000000000000000000000000000000000000000000000000000000000000001?????????????: _e_3092 = _e_3581;
            76'b0000000000000000000000000000000000000000000000000000000000000001????????????: _e_3092 = _e_3588;
            76'b00000000000000000000000000000000000000000000000000000000000000001???????????: _e_3092 = _e_3595;
            76'b000000000000000000000000000000000000000000000000000000000000000001??????????: _e_3092 = _e_3602;
            76'b0000000000000000000000000000000000000000000000000000000000000000001?????????: _e_3092 = _e_3609;
            76'b00000000000000000000000000000000000000000000000000000000000000000001????????: _e_3092 = _e_3616;
            76'b000000000000000000000000000000000000000000000000000000000000000000001???????: _e_3092 = _e_3623;
            76'b0000000000000000000000000000000000000000000000000000000000000000000001??????: _e_3092 = _e_3630;
            76'b00000000000000000000000000000000000000000000000000000000000000000000001?????: _e_3092 = _e_3637;
            76'b000000000000000000000000000000000000000000000000000000000000000000000001????: _e_3092 = _e_3643;
            76'b0000000000000000000000000000000000000000000000000000000000000000000000001???: _e_3092 = _e_3651;
            76'b00000000000000000000000000000000000000000000000000000000000000000000000001??: _e_3092 = _e_3657;
            76'b000000000000000000000000000000000000000000000000000000000000000000000000001?: _e_3092 = _e_3665;
            76'b0000000000000000000000000000000000000000000000000000000000000000000000000001: _e_3092 = _e_3668;
            76'b?: _e_3092 = 44'dx;
        endcase
    end
    assign output__ = _e_3092;
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
    logic[10:0] _e_9139;
    (* src = "src/tta.spade:335,38" *)
    logic[10:0] _e_9140_mut;
    (* src = "src/tta.spade:335,38" *)
    logic[10:0] _e_3673;
    (* src = "src/tta.spade:335,38" *)
    logic[10:0] _e_3673_mut;
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
    logic[63:0] _e_3757;
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
    logic[48:0] _e_3830;
    (* src = "src/tta.spade:450,30" *)
    logic[36:0] _e_3829;
    (* src = "src/tta.spade:450,47" *)
    logic[36:0] _e_3833;
    (* src = "src/tta.spade:450,47" *)
    logic[3:0] \i ;
    logic _e_9142;
    logic _e_9144;
    (* src = "src/tta.spade:450,74" *)
    logic[36:0] __n2;
    (* src = "src/tta.spade:450,24" *)
    logic[3:0] \ra0 ;
    (* src = "src/tta.spade:451,30" *)
    logic[48:0] _e_3840;
    (* src = "src/tta.spade:451,30" *)
    logic[36:0] _e_3839;
    (* src = "src/tta.spade:451,47" *)
    logic[36:0] _e_3843;
    (* src = "src/tta.spade:451,47" *)
    logic[3:0] i_n1;
    logic _e_9147;
    logic _e_9149;
    (* src = "src/tta.spade:451,74" *)
    logic[36:0] __n3;
    (* src = "src/tta.spade:451,24" *)
    logic[3:0] \ra1 ;
    (* src = "src/tta.spade:455,20" *)
    logic[575:0] \registry ;
    (* src = "src/tta.spade:460,12" *)
    logic[48:0] _e_3858;
    (* src = "src/tta.spade:460,12" *)
    logic _e_3857;
    (* src = "src/tta.spade:461,19" *)
    logic[48:0] _e_3863;
    (* src = "src/tta.spade:461,19" *)
    logic[36:0] _e_3862;
    (* src = "src/tta.spade:462,17" *)
    logic[36:0] _e_3866;
    (* src = "src/tta.spade:462,17" *)
    logic[3:0] __n4;
    logic _e_9152;
    logic _e_9154;
    (* src = "src/tta.spade:462,48" *)
    logic[31:0] _e_3868;
    (* src = "src/tta.spade:462,43" *)
    logic[32:0] _e_3867;
    (* src = "src/tta.spade:463,17" *)
    logic[36:0] _e_3870;
    logic _e_9156;
    logic[31:0] _e_3872;
    (* src = "src/tta.spade:463,33" *)
    logic[32:0] _e_3871;
    (* src = "src/tta.spade:464,17" *)
    logic[36:0] _e_3874;
    logic _e_9158;
    (* src = "src/tta.spade:464,44" *)
    logic[10:0] _e_3877;
    logic[31:0] _e_3876;
    (* src = "src/tta.spade:464,34" *)
    logic[32:0] _e_3875;
    (* src = "src/tta.spade:465,17" *)
    logic[36:0] _e_3881;
    (* src = "src/tta.spade:465,17" *)
    logic[31:0] \v ;
    logic _e_9160;
    logic _e_9162;
    (* src = "src/tta.spade:465,39" *)
    logic[32:0] _e_3882;
    (* src = "src/tta.spade:466,17" *)
    logic[36:0] _e_3884;
    logic _e_9164;
    (* src = "src/tta.spade:466,33" *)
    logic[32:0] _e_3885;
    (* src = "src/tta.spade:467,17" *)
    logic[36:0] _e_3887;
    logic _e_9166;
    (* src = "src/tta.spade:468,17" *)
    logic[36:0] _e_3889;
    logic _e_9168;
    (* src = "src/tta.spade:469,17" *)
    logic[36:0] _e_3891;
    logic _e_9170;
    (* src = "src/tta.spade:470,17" *)
    logic[36:0] _e_3893;
    logic _e_9172;
    (* src = "src/tta.spade:471,17" *)
    logic[36:0] _e_3895;
    logic _e_9174;
    (* src = "src/tta.spade:472,17" *)
    logic[36:0] _e_3897;
    logic _e_9176;
    (* src = "src/tta.spade:473,17" *)
    logic[36:0] _e_3899;
    logic _e_9178;
    (* src = "src/tta.spade:474,17" *)
    logic[36:0] _e_3901;
    logic _e_9180;
    (* src = "src/tta.spade:475,17" *)
    logic[36:0] _e_3903;
    logic _e_9182;
    (* src = "src/tta.spade:476,17" *)
    logic[36:0] _e_3905;
    logic _e_9184;
    (* src = "src/tta.spade:476,35" *)
    logic[32:0] _e_3906;
    (* src = "src/tta.spade:477,17" *)
    logic[36:0] _e_3908;
    logic _e_9186;
    (* src = "src/tta.spade:477,37" *)
    logic[32:0] _e_3909;
    (* src = "src/tta.spade:478,17" *)
    logic[36:0] _e_3911;
    logic _e_9188;
    (* src = "src/tta.spade:479,17" *)
    logic[36:0] _e_3913;
    logic _e_9190;
    (* src = "src/tta.spade:480,17" *)
    logic[36:0] _e_3915;
    logic _e_9192;
    (* src = "src/tta.spade:481,17" *)
    logic[36:0] _e_3917;
    logic _e_9194;
    (* src = "src/tta.spade:482,17" *)
    logic[36:0] _e_3919;
    logic _e_9196;
    (* src = "src/tta.spade:483,17" *)
    logic[36:0] _e_3921;
    logic _e_9198;
    (* src = "src/tta.spade:484,17" *)
    logic[36:0] _e_3923;
    logic _e_9200;
    (* src = "src/tta.spade:485,17" *)
    logic[36:0] _e_3925;
    logic _e_9202;
    (* src = "src/tta.spade:486,17" *)
    logic[36:0] _e_3927;
    logic _e_9204;
    (* src = "src/tta.spade:461,13" *)
    logic[32:0] _e_3861;
    (* src = "src/tta.spade:488,18" *)
    logic[32:0] _e_3930;
    (* src = "src/tta.spade:460,9" *)
    logic[32:0] \bus0_val_opt ;
    (* src = "src/tta.spade:491,12" *)
    logic[48:0] _e_3934;
    (* src = "src/tta.spade:491,12" *)
    logic _e_3933;
    (* src = "src/tta.spade:492,19" *)
    logic[48:0] _e_3939;
    (* src = "src/tta.spade:492,19" *)
    logic[36:0] _e_3938;
    (* src = "src/tta.spade:493,17" *)
    logic[36:0] _e_3942;
    (* src = "src/tta.spade:493,17" *)
    logic[3:0] __n5;
    logic _e_9206;
    logic _e_9208;
    (* src = "src/tta.spade:493,48" *)
    logic[31:0] _e_3944;
    (* src = "src/tta.spade:493,43" *)
    logic[32:0] _e_3943;
    (* src = "src/tta.spade:494,17" *)
    logic[36:0] _e_3946;
    logic _e_9210;
    logic[31:0] _e_3948;
    (* src = "src/tta.spade:494,33" *)
    logic[32:0] _e_3947;
    (* src = "src/tta.spade:495,17" *)
    logic[36:0] _e_3950;
    logic _e_9212;
    (* src = "src/tta.spade:495,44" *)
    logic[10:0] _e_3953;
    logic[31:0] _e_3952;
    (* src = "src/tta.spade:495,34" *)
    logic[32:0] _e_3951;
    (* src = "src/tta.spade:496,17" *)
    logic[36:0] _e_3957;
    (* src = "src/tta.spade:496,17" *)
    logic[31:0] v_n1;
    logic _e_9214;
    logic _e_9216;
    (* src = "src/tta.spade:496,39" *)
    logic[32:0] _e_3958;
    (* src = "src/tta.spade:497,17" *)
    logic[36:0] _e_3960;
    logic _e_9218;
    (* src = "src/tta.spade:497,33" *)
    logic[32:0] _e_3961;
    (* src = "src/tta.spade:498,17" *)
    logic[36:0] _e_3963;
    logic _e_9220;
    (* src = "src/tta.spade:499,17" *)
    logic[36:0] _e_3965;
    logic _e_9222;
    (* src = "src/tta.spade:500,17" *)
    logic[36:0] _e_3967;
    logic _e_9224;
    (* src = "src/tta.spade:501,17" *)
    logic[36:0] _e_3969;
    logic _e_9226;
    (* src = "src/tta.spade:502,17" *)
    logic[36:0] _e_3971;
    logic _e_9228;
    (* src = "src/tta.spade:503,17" *)
    logic[36:0] _e_3973;
    logic _e_9230;
    (* src = "src/tta.spade:504,17" *)
    logic[36:0] _e_3975;
    logic _e_9232;
    (* src = "src/tta.spade:505,17" *)
    logic[36:0] _e_3977;
    logic _e_9234;
    (* src = "src/tta.spade:506,17" *)
    logic[36:0] _e_3979;
    logic _e_9236;
    (* src = "src/tta.spade:507,17" *)
    logic[36:0] _e_3981;
    logic _e_9238;
    (* src = "src/tta.spade:507,35" *)
    logic[32:0] _e_3982;
    (* src = "src/tta.spade:508,17" *)
    logic[36:0] _e_3984;
    logic _e_9240;
    (* src = "src/tta.spade:508,37" *)
    logic[32:0] _e_3985;
    (* src = "src/tta.spade:509,17" *)
    logic[36:0] _e_3987;
    logic _e_9242;
    (* src = "src/tta.spade:510,17" *)
    logic[36:0] _e_3989;
    logic _e_9244;
    (* src = "src/tta.spade:511,17" *)
    logic[36:0] _e_3991;
    logic _e_9246;
    (* src = "src/tta.spade:512,17" *)
    logic[36:0] _e_3993;
    logic _e_9248;
    (* src = "src/tta.spade:513,17" *)
    logic[36:0] _e_3995;
    logic _e_9250;
    (* src = "src/tta.spade:514,17" *)
    logic[36:0] _e_3997;
    logic _e_9252;
    (* src = "src/tta.spade:515,17" *)
    logic[36:0] _e_3999;
    logic _e_9254;
    (* src = "src/tta.spade:516,17" *)
    logic[36:0] _e_4001;
    logic _e_9256;
    (* src = "src/tta.spade:517,17" *)
    logic[36:0] _e_4003;
    logic _e_9258;
    (* src = "src/tta.spade:492,13" *)
    logic[32:0] _e_3937;
    (* src = "src/tta.spade:519,18" *)
    logic[32:0] _e_4006;
    (* src = "src/tta.spade:491,9" *)
    logic[32:0] \bus1_val_opt ;
    (* src = "src/tta.spade:522,26" *)
    logic[48:0] _e_4010;
    (* src = "src/tta.spade:522,26" *)
    logic[10:0] _e_4009;
    (* src = "src/tta.spade:522,14" *)
    logic[43:0] \m0 ;
    (* src = "src/tta.spade:523,26" *)
    logic[48:0] _e_4016;
    (* src = "src/tta.spade:523,26" *)
    logic[10:0] _e_4015;
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
    logic[98:0] _e_4264;
    (* src = "src/tta.spade:641,5" *)
    logic[509:0] _e_4250;
    
    assign _e_9139 = _e_9140_mut;
    assign _e_3673 = {_e_9139};
    assign {_e_9140_mut} = _e_3673_mut;
    assign \bt_target_r  = _e_3673[10:0];
    assign _e_3673_mut[10:0] = \bt_target_w_mut ;
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
    \tta::cc::cc_fu  cc_fu_0(.clk_i(\clk ), .rst_i(\rst ), .output__(_e_3757));
    assign \cc_res_lo  = _e_3757[63:32];
    assign \cc_res_high  = _e_3757[31:0];
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
    assign _e_3830 = \insn [97:49];
    assign _e_3829 = _e_3830[48:12];
    assign _e_3833 = _e_3829;
    assign \i  = _e_3829[31:28];
    assign _e_9142 = _e_3829[36:32] == 5'd0;
    localparam[0:0] _e_9143 = 1;
    assign _e_9144 = _e_9142 && _e_9143;
    assign __n2 = _e_3829;
    localparam[0:0] _e_9145 = 1;
    localparam[3:0] _e_3836 = 0;
    always_comb begin
        priority casez ({_e_9144, _e_9145})
            2'b1?: \ra0  = \i ;
            2'b01: \ra0  = _e_3836;
            2'b?: \ra0  = 4'dx;
        endcase
    end
    assign _e_3840 = \insn [48:0];
    assign _e_3839 = _e_3840[48:12];
    assign _e_3843 = _e_3839;
    assign i_n1 = _e_3839[31:28];
    assign _e_9147 = _e_3839[36:32] == 5'd0;
    localparam[0:0] _e_9148 = 1;
    assign _e_9149 = _e_9147 && _e_9148;
    assign __n3 = _e_3839;
    localparam[0:0] _e_9150 = 1;
    localparam[3:0] _e_3846 = 0;
    always_comb begin
        priority casez ({_e_9149, _e_9150})
            2'b1?: \ra1  = i_n1;
            2'b01: \ra1  = _e_3846;
            2'b?: \ra1  = 4'dx;
        endcase
    end
    (* src = "src/tta.spade:455,20" *)
    \tta::regfile::regfile8_fu  regfile8_fu_0(.clk_i(\clk ), .rst_i(\rst ), .wr0_i(\rf_w0 ), .wr1_i(\rf_w1 ), .ra0_i(\ra0 ), .ra1_i(\ra1 ), .output__(\registry ));
    assign _e_3858 = \insn [97:49];
    assign _e_3857 = _e_3858[0];
    assign _e_3863 = \insn [97:49];
    assign _e_3862 = _e_3863[48:12];
    assign _e_3866 = _e_3862;
    assign __n4 = _e_3862[31:28];
    assign _e_9152 = _e_3862[36:32] == 5'd0;
    localparam[0:0] _e_9153 = 1;
    assign _e_9154 = _e_9152 && _e_9153;
    assign _e_3868 = \registry [575:544];
    assign _e_3867 = {1'd1, _e_3868};
    assign _e_3870 = _e_3862;
    assign _e_9156 = _e_3862[36:32] == 5'd3;
    assign _e_3872 = {22'b0, \pc_val };
    assign _e_3871 = {1'd1, _e_3872};
    assign _e_3874 = _e_3862;
    assign _e_9158 = _e_3862[36:32] == 5'd4;
    localparam[9:0] _e_3879 = 1;
    assign _e_3877 = \pc_val  + _e_3879;
    assign _e_3876 = {21'b0, _e_3877};
    assign _e_3875 = {1'd1, _e_3876};
    assign _e_3881 = _e_3862;
    assign \v  = _e_3862[31:0];
    assign _e_9160 = _e_3862[36:32] == 5'd5;
    localparam[0:0] _e_9161 = 1;
    assign _e_9162 = _e_9160 && _e_9161;
    assign _e_3882 = {1'd1, \v };
    assign _e_3884 = _e_3862;
    assign _e_9164 = _e_3862[36:32] == 5'd6;
    localparam[31:0] _e_3886 = 32'd0;
    assign _e_3885 = {1'd1, _e_3886};
    assign _e_3887 = _e_3862;
    assign _e_9166 = _e_3862[36:32] == 5'd1;
    assign _e_3889 = _e_3862;
    assign _e_9168 = _e_3862[36:32] == 5'd7;
    assign _e_3891 = _e_3862;
    assign _e_9170 = _e_3862[36:32] == 5'd8;
    assign _e_3893 = _e_3862;
    assign _e_9172 = _e_3862[36:32] == 5'd9;
    assign _e_3895 = _e_3862;
    assign _e_9174 = _e_3862[36:32] == 5'd10;
    assign _e_3897 = _e_3862;
    assign _e_9176 = _e_3862[36:32] == 5'd11;
    assign _e_3899 = _e_3862;
    assign _e_9178 = _e_3862[36:32] == 5'd12;
    assign _e_3901 = _e_3862;
    assign _e_9180 = _e_3862[36:32] == 5'd2;
    assign _e_3903 = _e_3862;
    assign _e_9182 = _e_3862[36:32] == 5'd13;
    assign _e_3905 = _e_3862;
    assign _e_9184 = _e_3862[36:32] == 5'd14;
    assign _e_3906 = {1'd1, \cc_res_lo };
    assign _e_3908 = _e_3862;
    assign _e_9186 = _e_3862[36:32] == 5'd15;
    assign _e_3909 = {1'd1, \cc_res_high };
    assign _e_3911 = _e_3862;
    assign _e_9188 = _e_3862[36:32] == 5'd16;
    assign _e_3913 = _e_3862;
    assign _e_9190 = _e_3862[36:32] == 5'd17;
    assign _e_3915 = _e_3862;
    assign _e_9192 = _e_3862[36:32] == 5'd18;
    assign _e_3917 = _e_3862;
    assign _e_9194 = _e_3862[36:32] == 5'd19;
    assign _e_3919 = _e_3862;
    assign _e_9196 = _e_3862[36:32] == 5'd20;
    assign _e_3921 = _e_3862;
    assign _e_9198 = _e_3862[36:32] == 5'd21;
    assign _e_3923 = _e_3862;
    assign _e_9200 = _e_3862[36:32] == 5'd22;
    assign _e_3925 = _e_3862;
    assign _e_9202 = _e_3862[36:32] == 5'd23;
    assign _e_3927 = _e_3862;
    assign _e_9204 = _e_3862[36:32] == 5'd24;
    always_comb begin
        priority casez ({_e_9154, _e_9156, _e_9158, _e_9162, _e_9164, _e_9166, _e_9168, _e_9170, _e_9172, _e_9174, _e_9176, _e_9178, _e_9180, _e_9182, _e_9184, _e_9186, _e_9188, _e_9190, _e_9192, _e_9194, _e_9196, _e_9198, _e_9200, _e_9202, _e_9204})
            25'b1????????????????????????: _e_3861 = _e_3867;
            25'b01???????????????????????: _e_3861 = _e_3871;
            25'b001??????????????????????: _e_3861 = _e_3875;
            25'b0001?????????????????????: _e_3861 = _e_3882;
            25'b00001????????????????????: _e_3861 = _e_3885;
            25'b000001???????????????????: _e_3861 = \alu_res ;
            25'b0000001??????????????????: _e_3861 = \lsu_res ;
            25'b00000001?????????????????: _e_3861 = \lsu2_res ;
            25'b000000001????????????????: _e_3861 = \gpi_res ;
            25'b0000000001???????????????: _e_3861 = \uart_in_res ;
            25'b00000000001??????????????: _e_3861 = \cmp_res ;
            25'b000000000001?????????????: _e_3861 = \cmpz_res ;
            25'b0000000000001????????????: _e_3861 = \lalu_res ;
            25'b00000000000001???????????: _e_3861 = \mul_res ;
            25'b000000000000001??????????: _e_3861 = _e_3906;
            25'b0000000000000001?????????: _e_3861 = _e_3909;
            25'b00000000000000001????????: _e_3861 = \spi_in_res ;
            25'b000000000000000001???????: _e_3861 = \div_res ;
            25'b0000000000000000001??????: _e_3861 = \xorshift_res ;
            25'b00000000000000000001?????: _e_3861 = \mac_res ;
            25'b000000000000000000001????: _e_3861 = \sel_res ;
            25'b0000000000000000000001???: _e_3861 = \mda_res ;
            25'b00000000000000000000001??: _e_3861 = \tanh_res ;
            25'b000000000000000000000001?: _e_3861 = \stack_res ;
            25'b0000000000000000000000001: _e_3861 = \bit_res ;
            25'b?: _e_3861 = 33'dx;
        endcase
    end
    assign _e_3930 = {1'd0, 32'bX};
    assign \bus0_val_opt  = _e_3857 ? _e_3861 : _e_3930;
    assign _e_3934 = \insn [48:0];
    assign _e_3933 = _e_3934[0];
    assign _e_3939 = \insn [48:0];
    assign _e_3938 = _e_3939[48:12];
    assign _e_3942 = _e_3938;
    assign __n5 = _e_3938[31:28];
    assign _e_9206 = _e_3938[36:32] == 5'd0;
    localparam[0:0] _e_9207 = 1;
    assign _e_9208 = _e_9206 && _e_9207;
    assign _e_3944 = \registry [543:512];
    assign _e_3943 = {1'd1, _e_3944};
    assign _e_3946 = _e_3938;
    assign _e_9210 = _e_3938[36:32] == 5'd3;
    assign _e_3948 = {22'b0, \pc_val };
    assign _e_3947 = {1'd1, _e_3948};
    assign _e_3950 = _e_3938;
    assign _e_9212 = _e_3938[36:32] == 5'd4;
    localparam[9:0] _e_3955 = 1;
    assign _e_3953 = \pc_val  + _e_3955;
    assign _e_3952 = {21'b0, _e_3953};
    assign _e_3951 = {1'd1, _e_3952};
    assign _e_3957 = _e_3938;
    assign v_n1 = _e_3938[31:0];
    assign _e_9214 = _e_3938[36:32] == 5'd5;
    localparam[0:0] _e_9215 = 1;
    assign _e_9216 = _e_9214 && _e_9215;
    assign _e_3958 = {1'd1, v_n1};
    assign _e_3960 = _e_3938;
    assign _e_9218 = _e_3938[36:32] == 5'd6;
    localparam[31:0] _e_3962 = 32'd0;
    assign _e_3961 = {1'd1, _e_3962};
    assign _e_3963 = _e_3938;
    assign _e_9220 = _e_3938[36:32] == 5'd1;
    assign _e_3965 = _e_3938;
    assign _e_9222 = _e_3938[36:32] == 5'd7;
    assign _e_3967 = _e_3938;
    assign _e_9224 = _e_3938[36:32] == 5'd8;
    assign _e_3969 = _e_3938;
    assign _e_9226 = _e_3938[36:32] == 5'd9;
    assign _e_3971 = _e_3938;
    assign _e_9228 = _e_3938[36:32] == 5'd10;
    assign _e_3973 = _e_3938;
    assign _e_9230 = _e_3938[36:32] == 5'd11;
    assign _e_3975 = _e_3938;
    assign _e_9232 = _e_3938[36:32] == 5'd12;
    assign _e_3977 = _e_3938;
    assign _e_9234 = _e_3938[36:32] == 5'd2;
    assign _e_3979 = _e_3938;
    assign _e_9236 = _e_3938[36:32] == 5'd13;
    assign _e_3981 = _e_3938;
    assign _e_9238 = _e_3938[36:32] == 5'd14;
    assign _e_3982 = {1'd1, \cc_res_lo };
    assign _e_3984 = _e_3938;
    assign _e_9240 = _e_3938[36:32] == 5'd15;
    assign _e_3985 = {1'd1, \cc_res_high };
    assign _e_3987 = _e_3938;
    assign _e_9242 = _e_3938[36:32] == 5'd16;
    assign _e_3989 = _e_3938;
    assign _e_9244 = _e_3938[36:32] == 5'd17;
    assign _e_3991 = _e_3938;
    assign _e_9246 = _e_3938[36:32] == 5'd18;
    assign _e_3993 = _e_3938;
    assign _e_9248 = _e_3938[36:32] == 5'd19;
    assign _e_3995 = _e_3938;
    assign _e_9250 = _e_3938[36:32] == 5'd20;
    assign _e_3997 = _e_3938;
    assign _e_9252 = _e_3938[36:32] == 5'd21;
    assign _e_3999 = _e_3938;
    assign _e_9254 = _e_3938[36:32] == 5'd22;
    assign _e_4001 = _e_3938;
    assign _e_9256 = _e_3938[36:32] == 5'd23;
    assign _e_4003 = _e_3938;
    assign _e_9258 = _e_3938[36:32] == 5'd24;
    always_comb begin
        priority casez ({_e_9208, _e_9210, _e_9212, _e_9216, _e_9218, _e_9220, _e_9222, _e_9224, _e_9226, _e_9228, _e_9230, _e_9232, _e_9234, _e_9236, _e_9238, _e_9240, _e_9242, _e_9244, _e_9246, _e_9248, _e_9250, _e_9252, _e_9254, _e_9256, _e_9258})
            25'b1????????????????????????: _e_3937 = _e_3943;
            25'b01???????????????????????: _e_3937 = _e_3947;
            25'b001??????????????????????: _e_3937 = _e_3951;
            25'b0001?????????????????????: _e_3937 = _e_3958;
            25'b00001????????????????????: _e_3937 = _e_3961;
            25'b000001???????????????????: _e_3937 = \alu_res ;
            25'b0000001??????????????????: _e_3937 = \lsu_res ;
            25'b00000001?????????????????: _e_3937 = \lsu2_res ;
            25'b000000001????????????????: _e_3937 = \gpi_res ;
            25'b0000000001???????????????: _e_3937 = \uart_in_res ;
            25'b00000000001??????????????: _e_3937 = \cmp_res ;
            25'b000000000001?????????????: _e_3937 = \cmpz_res ;
            25'b0000000000001????????????: _e_3937 = \lalu_res ;
            25'b00000000000001???????????: _e_3937 = \mul_res ;
            25'b000000000000001??????????: _e_3937 = _e_3982;
            25'b0000000000000001?????????: _e_3937 = _e_3985;
            25'b00000000000000001????????: _e_3937 = \spi_in_res ;
            25'b000000000000000001???????: _e_3937 = \div_res ;
            25'b0000000000000000001??????: _e_3937 = \xorshift_res ;
            25'b00000000000000000001?????: _e_3937 = \mac_res ;
            25'b000000000000000000001????: _e_3937 = \sel_res ;
            25'b0000000000000000000001???: _e_3937 = \mda_res ;
            25'b00000000000000000000001??: _e_3937 = \tanh_res ;
            25'b000000000000000000000001?: _e_3937 = \stack_res ;
            25'b0000000000000000000000001: _e_3937 = \bit_res ;
            25'b?: _e_3937 = 33'dx;
        endcase
    end
    assign _e_4006 = {1'd0, 32'bX};
    assign \bus1_val_opt  = _e_3933 ? _e_3937 : _e_4006;
    assign _e_4010 = \insn [97:49];
    assign _e_4009 = _e_4010[11:1];
    (* src = "src/tta.spade:522,14" *)
    \tta::tta::decode_move  decode_move_0(.dst_i(_e_4009), .v_i(\bus0_val_opt ), .output__(\m0 ));
    assign _e_4016 = \insn [48:0];
    assign _e_4015 = _e_4016[11:1];
    (* src = "src/tta.spade:523,14" *)
    \tta::tta::decode_move  decode_move_1(.dst_i(_e_4015), .v_i(\bus1_val_opt ), .output__(\m1 ));
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
    assign _e_4264 = {1'd1, \insn };
    assign _e_4250 = {\pc_val , \alu_op_a , \alu_trig , \alu_res , \pc_jump_final , \rf_w0 , \rf_w1 , \rd0 , \rd1 , \lsu_res , \lsu_set_addr , \lsu_store_trig , \lsu_load_trig , _e_4264, \gpo_res };
    assign output__ = _e_4250;
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
    logic[63:0] _e_4269;
    (* src = "src/fifo.spade:14,5" *)
    logic[73:0] _e_4268;
    localparam[7:0] _e_4270 = 0;
    localparam[7:0] _e_4271 = 0;
    localparam[7:0] _e_4272 = 0;
    localparam[7:0] _e_4273 = 0;
    localparam[7:0] _e_4274 = 0;
    localparam[7:0] _e_4275 = 0;
    localparam[7:0] _e_4276 = 0;
    localparam[7:0] _e_4277 = 0;
    assign _e_4269 = {_e_4277, _e_4276, _e_4275, _e_4274, _e_4273, _e_4272, _e_4271, _e_4270};
    localparam[2:0] _e_4278 = 0;
    localparam[2:0] _e_4279 = 0;
    localparam[3:0] _e_4280 = 0;
    assign _e_4268 = {_e_4269, _e_4278, _e_4279, _e_4280};
    assign output__ = _e_4268;
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
    logic _e_9259;
    (* src = "src/fifo.spade:20,20" *)
    logic[7:0] _e_4287;
    (* src = "src/fifo.spade:20,28" *)
    logic[7:0] _e_4290;
    (* src = "src/fifo.spade:20,36" *)
    logic[7:0] _e_4293;
    (* src = "src/fifo.spade:20,44" *)
    logic[7:0] _e_4296;
    (* src = "src/fifo.spade:20,52" *)
    logic[7:0] _e_4299;
    (* src = "src/fifo.spade:20,60" *)
    logic[7:0] _e_4302;
    (* src = "src/fifo.spade:20,68" *)
    logic[7:0] _e_4305;
    (* src = "src/fifo.spade:20,14" *)
    logic[63:0] _e_4285;
    logic _e_9261;
    (* src = "src/fifo.spade:21,15" *)
    logic[7:0] _e_4310;
    (* src = "src/fifo.spade:21,28" *)
    logic[7:0] _e_4314;
    (* src = "src/fifo.spade:21,36" *)
    logic[7:0] _e_4317;
    (* src = "src/fifo.spade:21,44" *)
    logic[7:0] _e_4320;
    (* src = "src/fifo.spade:21,52" *)
    logic[7:0] _e_4323;
    (* src = "src/fifo.spade:21,60" *)
    logic[7:0] _e_4326;
    (* src = "src/fifo.spade:21,68" *)
    logic[7:0] _e_4329;
    (* src = "src/fifo.spade:21,14" *)
    logic[63:0] _e_4309;
    logic _e_9263;
    (* src = "src/fifo.spade:22,15" *)
    logic[7:0] _e_4334;
    (* src = "src/fifo.spade:22,23" *)
    logic[7:0] _e_4337;
    (* src = "src/fifo.spade:22,36" *)
    logic[7:0] _e_4341;
    (* src = "src/fifo.spade:22,44" *)
    logic[7:0] _e_4344;
    (* src = "src/fifo.spade:22,52" *)
    logic[7:0] _e_4347;
    (* src = "src/fifo.spade:22,60" *)
    logic[7:0] _e_4350;
    (* src = "src/fifo.spade:22,68" *)
    logic[7:0] _e_4353;
    (* src = "src/fifo.spade:22,14" *)
    logic[63:0] _e_4333;
    logic _e_9265;
    (* src = "src/fifo.spade:23,15" *)
    logic[7:0] _e_4358;
    (* src = "src/fifo.spade:23,23" *)
    logic[7:0] _e_4361;
    (* src = "src/fifo.spade:23,31" *)
    logic[7:0] _e_4364;
    (* src = "src/fifo.spade:23,44" *)
    logic[7:0] _e_4368;
    (* src = "src/fifo.spade:23,52" *)
    logic[7:0] _e_4371;
    (* src = "src/fifo.spade:23,60" *)
    logic[7:0] _e_4374;
    (* src = "src/fifo.spade:23,68" *)
    logic[7:0] _e_4377;
    (* src = "src/fifo.spade:23,14" *)
    logic[63:0] _e_4357;
    logic _e_9267;
    (* src = "src/fifo.spade:24,15" *)
    logic[7:0] _e_4382;
    (* src = "src/fifo.spade:24,23" *)
    logic[7:0] _e_4385;
    (* src = "src/fifo.spade:24,31" *)
    logic[7:0] _e_4388;
    (* src = "src/fifo.spade:24,39" *)
    logic[7:0] _e_4391;
    (* src = "src/fifo.spade:24,52" *)
    logic[7:0] _e_4395;
    (* src = "src/fifo.spade:24,60" *)
    logic[7:0] _e_4398;
    (* src = "src/fifo.spade:24,68" *)
    logic[7:0] _e_4401;
    (* src = "src/fifo.spade:24,14" *)
    logic[63:0] _e_4381;
    logic _e_9269;
    (* src = "src/fifo.spade:25,15" *)
    logic[7:0] _e_4406;
    (* src = "src/fifo.spade:25,23" *)
    logic[7:0] _e_4409;
    (* src = "src/fifo.spade:25,31" *)
    logic[7:0] _e_4412;
    (* src = "src/fifo.spade:25,39" *)
    logic[7:0] _e_4415;
    (* src = "src/fifo.spade:25,47" *)
    logic[7:0] _e_4418;
    (* src = "src/fifo.spade:25,60" *)
    logic[7:0] _e_4422;
    (* src = "src/fifo.spade:25,68" *)
    logic[7:0] _e_4425;
    (* src = "src/fifo.spade:25,14" *)
    logic[63:0] _e_4405;
    logic _e_9271;
    (* src = "src/fifo.spade:26,15" *)
    logic[7:0] _e_4430;
    (* src = "src/fifo.spade:26,23" *)
    logic[7:0] _e_4433;
    (* src = "src/fifo.spade:26,31" *)
    logic[7:0] _e_4436;
    (* src = "src/fifo.spade:26,39" *)
    logic[7:0] _e_4439;
    (* src = "src/fifo.spade:26,47" *)
    logic[7:0] _e_4442;
    (* src = "src/fifo.spade:26,55" *)
    logic[7:0] _e_4445;
    (* src = "src/fifo.spade:26,68" *)
    logic[7:0] _e_4449;
    (* src = "src/fifo.spade:26,14" *)
    logic[63:0] _e_4429;
    logic _e_9273;
    (* src = "src/fifo.spade:27,15" *)
    logic[7:0] _e_4454;
    (* src = "src/fifo.spade:27,23" *)
    logic[7:0] _e_4457;
    (* src = "src/fifo.spade:27,31" *)
    logic[7:0] _e_4460;
    (* src = "src/fifo.spade:27,39" *)
    logic[7:0] _e_4463;
    (* src = "src/fifo.spade:27,47" *)
    logic[7:0] _e_4466;
    (* src = "src/fifo.spade:27,55" *)
    logic[7:0] _e_4469;
    (* src = "src/fifo.spade:27,63" *)
    logic[7:0] _e_4472;
    (* src = "src/fifo.spade:27,14" *)
    logic[63:0] _e_4453;
    (* src = "src/fifo.spade:19,5" *)
    logic[63:0] _e_4282;
    localparam[2:0] _e_9260 = 0;
    assign _e_9259 = \idx  == _e_9260;
    localparam[2:0] _e_4289 = 1;
    assign _e_4287 = \arr [_e_4289 * 8+:8];
    localparam[2:0] _e_4292 = 2;
    assign _e_4290 = \arr [_e_4292 * 8+:8];
    localparam[2:0] _e_4295 = 3;
    assign _e_4293 = \arr [_e_4295 * 8+:8];
    localparam[2:0] _e_4298 = 4;
    assign _e_4296 = \arr [_e_4298 * 8+:8];
    localparam[2:0] _e_4301 = 5;
    assign _e_4299 = \arr [_e_4301 * 8+:8];
    localparam[2:0] _e_4304 = 6;
    assign _e_4302 = \arr [_e_4304 * 8+:8];
    localparam[2:0] _e_4307 = 7;
    assign _e_4305 = \arr [_e_4307 * 8+:8];
    assign _e_4285 = {_e_4305, _e_4302, _e_4299, _e_4296, _e_4293, _e_4290, _e_4287, \val };
    localparam[2:0] _e_9262 = 1;
    assign _e_9261 = \idx  == _e_9262;
    localparam[2:0] _e_4312 = 0;
    assign _e_4310 = \arr [_e_4312 * 8+:8];
    localparam[2:0] _e_4316 = 2;
    assign _e_4314 = \arr [_e_4316 * 8+:8];
    localparam[2:0] _e_4319 = 3;
    assign _e_4317 = \arr [_e_4319 * 8+:8];
    localparam[2:0] _e_4322 = 4;
    assign _e_4320 = \arr [_e_4322 * 8+:8];
    localparam[2:0] _e_4325 = 5;
    assign _e_4323 = \arr [_e_4325 * 8+:8];
    localparam[2:0] _e_4328 = 6;
    assign _e_4326 = \arr [_e_4328 * 8+:8];
    localparam[2:0] _e_4331 = 7;
    assign _e_4329 = \arr [_e_4331 * 8+:8];
    assign _e_4309 = {_e_4329, _e_4326, _e_4323, _e_4320, _e_4317, _e_4314, \val , _e_4310};
    localparam[2:0] _e_9264 = 2;
    assign _e_9263 = \idx  == _e_9264;
    localparam[2:0] _e_4336 = 0;
    assign _e_4334 = \arr [_e_4336 * 8+:8];
    localparam[2:0] _e_4339 = 1;
    assign _e_4337 = \arr [_e_4339 * 8+:8];
    localparam[2:0] _e_4343 = 3;
    assign _e_4341 = \arr [_e_4343 * 8+:8];
    localparam[2:0] _e_4346 = 4;
    assign _e_4344 = \arr [_e_4346 * 8+:8];
    localparam[2:0] _e_4349 = 5;
    assign _e_4347 = \arr [_e_4349 * 8+:8];
    localparam[2:0] _e_4352 = 6;
    assign _e_4350 = \arr [_e_4352 * 8+:8];
    localparam[2:0] _e_4355 = 7;
    assign _e_4353 = \arr [_e_4355 * 8+:8];
    assign _e_4333 = {_e_4353, _e_4350, _e_4347, _e_4344, _e_4341, \val , _e_4337, _e_4334};
    localparam[2:0] _e_9266 = 3;
    assign _e_9265 = \idx  == _e_9266;
    localparam[2:0] _e_4360 = 0;
    assign _e_4358 = \arr [_e_4360 * 8+:8];
    localparam[2:0] _e_4363 = 1;
    assign _e_4361 = \arr [_e_4363 * 8+:8];
    localparam[2:0] _e_4366 = 2;
    assign _e_4364 = \arr [_e_4366 * 8+:8];
    localparam[2:0] _e_4370 = 4;
    assign _e_4368 = \arr [_e_4370 * 8+:8];
    localparam[2:0] _e_4373 = 5;
    assign _e_4371 = \arr [_e_4373 * 8+:8];
    localparam[2:0] _e_4376 = 6;
    assign _e_4374 = \arr [_e_4376 * 8+:8];
    localparam[2:0] _e_4379 = 7;
    assign _e_4377 = \arr [_e_4379 * 8+:8];
    assign _e_4357 = {_e_4377, _e_4374, _e_4371, _e_4368, \val , _e_4364, _e_4361, _e_4358};
    localparam[2:0] _e_9268 = 4;
    assign _e_9267 = \idx  == _e_9268;
    localparam[2:0] _e_4384 = 0;
    assign _e_4382 = \arr [_e_4384 * 8+:8];
    localparam[2:0] _e_4387 = 1;
    assign _e_4385 = \arr [_e_4387 * 8+:8];
    localparam[2:0] _e_4390 = 2;
    assign _e_4388 = \arr [_e_4390 * 8+:8];
    localparam[2:0] _e_4393 = 3;
    assign _e_4391 = \arr [_e_4393 * 8+:8];
    localparam[2:0] _e_4397 = 5;
    assign _e_4395 = \arr [_e_4397 * 8+:8];
    localparam[2:0] _e_4400 = 6;
    assign _e_4398 = \arr [_e_4400 * 8+:8];
    localparam[2:0] _e_4403 = 7;
    assign _e_4401 = \arr [_e_4403 * 8+:8];
    assign _e_4381 = {_e_4401, _e_4398, _e_4395, \val , _e_4391, _e_4388, _e_4385, _e_4382};
    localparam[2:0] _e_9270 = 5;
    assign _e_9269 = \idx  == _e_9270;
    localparam[2:0] _e_4408 = 0;
    assign _e_4406 = \arr [_e_4408 * 8+:8];
    localparam[2:0] _e_4411 = 1;
    assign _e_4409 = \arr [_e_4411 * 8+:8];
    localparam[2:0] _e_4414 = 2;
    assign _e_4412 = \arr [_e_4414 * 8+:8];
    localparam[2:0] _e_4417 = 3;
    assign _e_4415 = \arr [_e_4417 * 8+:8];
    localparam[2:0] _e_4420 = 4;
    assign _e_4418 = \arr [_e_4420 * 8+:8];
    localparam[2:0] _e_4424 = 6;
    assign _e_4422 = \arr [_e_4424 * 8+:8];
    localparam[2:0] _e_4427 = 7;
    assign _e_4425 = \arr [_e_4427 * 8+:8];
    assign _e_4405 = {_e_4425, _e_4422, \val , _e_4418, _e_4415, _e_4412, _e_4409, _e_4406};
    localparam[2:0] _e_9272 = 6;
    assign _e_9271 = \idx  == _e_9272;
    localparam[2:0] _e_4432 = 0;
    assign _e_4430 = \arr [_e_4432 * 8+:8];
    localparam[2:0] _e_4435 = 1;
    assign _e_4433 = \arr [_e_4435 * 8+:8];
    localparam[2:0] _e_4438 = 2;
    assign _e_4436 = \arr [_e_4438 * 8+:8];
    localparam[2:0] _e_4441 = 3;
    assign _e_4439 = \arr [_e_4441 * 8+:8];
    localparam[2:0] _e_4444 = 4;
    assign _e_4442 = \arr [_e_4444 * 8+:8];
    localparam[2:0] _e_4447 = 5;
    assign _e_4445 = \arr [_e_4447 * 8+:8];
    localparam[2:0] _e_4451 = 7;
    assign _e_4449 = \arr [_e_4451 * 8+:8];
    assign _e_4429 = {_e_4449, \val , _e_4445, _e_4442, _e_4439, _e_4436, _e_4433, _e_4430};
    localparam[2:0] _e_9274 = 7;
    assign _e_9273 = \idx  == _e_9274;
    localparam[2:0] _e_4456 = 0;
    assign _e_4454 = \arr [_e_4456 * 8+:8];
    localparam[2:0] _e_4459 = 1;
    assign _e_4457 = \arr [_e_4459 * 8+:8];
    localparam[2:0] _e_4462 = 2;
    assign _e_4460 = \arr [_e_4462 * 8+:8];
    localparam[2:0] _e_4465 = 3;
    assign _e_4463 = \arr [_e_4465 * 8+:8];
    localparam[2:0] _e_4468 = 4;
    assign _e_4466 = \arr [_e_4468 * 8+:8];
    localparam[2:0] _e_4471 = 5;
    assign _e_4469 = \arr [_e_4471 * 8+:8];
    localparam[2:0] _e_4474 = 6;
    assign _e_4472 = \arr [_e_4474 * 8+:8];
    assign _e_4453 = {\val , _e_4472, _e_4469, _e_4466, _e_4463, _e_4460, _e_4457, _e_4454};
    always_comb begin
        priority casez ({_e_9259, _e_9261, _e_9263, _e_9265, _e_9267, _e_9269, _e_9271, _e_9273})
            8'b1???????: _e_4282 = _e_4285;
            8'b01??????: _e_4282 = _e_4309;
            8'b001?????: _e_4282 = _e_4333;
            8'b0001????: _e_4282 = _e_4357;
            8'b00001???: _e_4282 = _e_4381;
            8'b000001??: _e_4282 = _e_4405;
            8'b0000001?: _e_4282 = _e_4429;
            8'b00000001: _e_4282 = _e_4453;
            8'b?: _e_4282 = 64'dx;
        endcase
    end
    assign output__ = _e_4282;
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
    logic[73:0] _e_4480;
    (* src = "src/fifo.spade:46,23" *)
    logic[3:0] _e_4483;
    (* src = "src/fifo.spade:46,23" *)
    logic \is_full ;
    (* src = "src/fifo.spade:47,24" *)
    logic[3:0] _e_4488;
    (* src = "src/fifo.spade:47,24" *)
    logic \is_empty ;
    (* src = "src/fifo.spade:52,13" *)
    logic[7:0] \_ ;
    logic _e_9276;
    logic _e_9278;
    (* src = "src/fifo.spade:52,24" *)
    logic _e_4497;
    (* src = "src/fifo.spade:52,24" *)
    logic _e_4496;
    logic _e_9280;
    (* src = "src/fifo.spade:51,23" *)
    logic \do_push ;
    (* src = "src/fifo.spade:57,29" *)
    logic _e_4505;
    (* src = "src/fifo.spade:57,22" *)
    logic \do_pop ;
    (* src = "src/fifo.spade:60,41" *)
    logic[2:0] _e_4513;
    (* src = "src/fifo.spade:60,41" *)
    logic[3:0] _e_4512;
    (* src = "src/fifo.spade:60,35" *)
    logic[2:0] _e_4511;
    (* src = "src/fifo.spade:60,63" *)
    logic[2:0] _e_4517;
    (* src = "src/fifo.spade:60,22" *)
    logic[2:0] \next_w ;
    (* src = "src/fifo.spade:61,41" *)
    logic[2:0] _e_4525;
    (* src = "src/fifo.spade:61,41" *)
    logic[3:0] _e_4524;
    (* src = "src/fifo.spade:61,35" *)
    logic[2:0] _e_4523;
    (* src = "src/fifo.spade:61,63" *)
    logic[2:0] _e_4529;
    (* src = "src/fifo.spade:61,22" *)
    logic[2:0] \next_r ;
    (* src = "src/fifo.spade:63,32" *)
    logic[1:0] _e_4533;
    (* src = "src/fifo.spade:64,13" *)
    logic[1:0] _e_4538;
    (* src = "src/fifo.spade:64,13" *)
    logic _e_4536;
    (* src = "src/fifo.spade:64,13" *)
    logic _e_4537;
    logic _e_9283;
    logic _e_9284;
    (* src = "src/fifo.spade:64,36" *)
    logic[3:0] _e_4541;
    (* src = "src/fifo.spade:64,36" *)
    logic[4:0] _e_4540;
    (* src = "src/fifo.spade:64,30" *)
    logic[3:0] _e_4539;
    (* src = "src/fifo.spade:65,13" *)
    logic[1:0] _e_4546;
    (* src = "src/fifo.spade:65,13" *)
    logic _e_4544;
    (* src = "src/fifo.spade:65,13" *)
    logic _e_4545;
    logic _e_9286;
    logic _e_9288;
    (* src = "src/fifo.spade:65,36" *)
    logic[3:0] _e_4549;
    (* src = "src/fifo.spade:65,36" *)
    logic[4:0] _e_4548;
    (* src = "src/fifo.spade:65,30" *)
    logic[3:0] _e_4547;
    (* src = "src/fifo.spade:66,13" *)
    logic[1:0] __n1;
    (* src = "src/fifo.spade:66,18" *)
    logic[3:0] _e_4553;
    (* src = "src/fifo.spade:63,26" *)
    logic[3:0] \next_count ;
    (* src = "src/fifo.spade:71,13" *)
    logic[7:0] \val ;
    logic _e_9291;
    logic _e_9293;
    (* src = "src/fifo.spade:71,47" *)
    logic[63:0] _e_4564;
    (* src = "src/fifo.spade:71,54" *)
    logic[2:0] _e_4566;
    (* src = "src/fifo.spade:71,39" *)
    logic[63:0] _e_4563;
    (* src = "src/fifo.spade:71,77" *)
    logic[63:0] _e_4570;
    (* src = "src/fifo.spade:71,26" *)
    logic[63:0] _e_4560;
    logic _e_9295;
    (* src = "src/fifo.spade:72,21" *)
    logic[63:0] _e_4573;
    (* src = "src/fifo.spade:70,24" *)
    logic[63:0] \next_mem ;
    (* src = "src/fifo.spade:75,9" *)
    logic[73:0] _e_4576;
    (* src = "src/fifo.spade:45,14" *)
    reg[73:0] \s ;
    (* src = "src/fifo.spade:79,17" *)
    logic[3:0] _e_4582;
    (* src = "src/fifo.spade:79,17" *)
    logic \empty ;
    (* src = "src/fifo.spade:80,17" *)
    logic[3:0] _e_4587;
    (* src = "src/fifo.spade:80,17" *)
    logic \full ;
    (* src = "src/fifo.spade:83,22" *)
    logic _e_4592;
    (* src = "src/fifo.spade:86,25" *)
    logic[2:0] _e_4596;
    (* src = "src/fifo.spade:87,13" *)
    logic[2:0] _e_4598;
    logic _e_9296;
    (* src = "src/fifo.spade:87,18" *)
    logic[63:0] _e_4600;
    (* src = "src/fifo.spade:87,18" *)
    logic[7:0] _e_4599;
    (* src = "src/fifo.spade:87,28" *)
    logic[2:0] _e_4603;
    logic _e_9298;
    (* src = "src/fifo.spade:87,33" *)
    logic[63:0] _e_4605;
    (* src = "src/fifo.spade:87,33" *)
    logic[7:0] _e_4604;
    (* src = "src/fifo.spade:87,43" *)
    logic[2:0] _e_4608;
    logic _e_9300;
    (* src = "src/fifo.spade:87,48" *)
    logic[63:0] _e_4610;
    (* src = "src/fifo.spade:87,48" *)
    logic[7:0] _e_4609;
    (* src = "src/fifo.spade:87,58" *)
    logic[2:0] _e_4613;
    logic _e_9302;
    (* src = "src/fifo.spade:87,63" *)
    logic[63:0] _e_4615;
    (* src = "src/fifo.spade:87,63" *)
    logic[7:0] _e_4614;
    (* src = "src/fifo.spade:88,13" *)
    logic[2:0] _e_4618;
    logic _e_9304;
    (* src = "src/fifo.spade:88,18" *)
    logic[63:0] _e_4620;
    (* src = "src/fifo.spade:88,18" *)
    logic[7:0] _e_4619;
    (* src = "src/fifo.spade:88,28" *)
    logic[2:0] _e_4623;
    logic _e_9306;
    (* src = "src/fifo.spade:88,33" *)
    logic[63:0] _e_4625;
    (* src = "src/fifo.spade:88,33" *)
    logic[7:0] _e_4624;
    (* src = "src/fifo.spade:88,43" *)
    logic[2:0] _e_4628;
    logic _e_9308;
    (* src = "src/fifo.spade:88,48" *)
    logic[63:0] _e_4630;
    (* src = "src/fifo.spade:88,48" *)
    logic[7:0] _e_4629;
    (* src = "src/fifo.spade:88,58" *)
    logic[2:0] _e_4633;
    logic _e_9310;
    (* src = "src/fifo.spade:88,63" *)
    logic[63:0] _e_4635;
    (* src = "src/fifo.spade:88,63" *)
    logic[7:0] _e_4634;
    (* src = "src/fifo.spade:86,19" *)
    logic[7:0] val_n1;
    (* src = "src/fifo.spade:90,9" *)
    logic[8:0] _e_4639;
    (* src = "src/fifo.spade:92,9" *)
    logic[8:0] _e_4642;
    (* src = "src/fifo.spade:83,19" *)
    logic[8:0] \out_val ;
    (* src = "src/fifo.spade:95,26" *)
    logic[3:0] _e_4647;
    (* src = "src/fifo.spade:95,5" *)
    logic[14:0] _e_4644;
    (* src = "src/fifo.spade:45,38" *)
    \tta::fifo::reset_fifo  reset_fifo_0(.output__(_e_4480));
    assign _e_4483 = \s [3:0];
    localparam[3:0] _e_4485 = 8;
    assign \is_full  = _e_4483 == _e_4485;
    assign _e_4488 = \s [3:0];
    localparam[3:0] _e_4490 = 0;
    assign \is_empty  = _e_4488 == _e_4490;
    assign \_  = \push [7:0];
    assign _e_9276 = \push [8] == 1'd1;
    localparam[0:0] _e_9277 = 1;
    assign _e_9278 = _e_9276 && _e_9277;
    assign _e_4497 = !\is_full ;
    assign _e_4496 = _e_4497 || \pop ;
    assign _e_9280 = \push [8] == 1'd0;
    localparam[0:0] _e_4501 = 0;
    always_comb begin
        priority casez ({_e_9278, _e_9280})
            2'b1?: \do_push  = _e_4496;
            2'b01: \do_push  = _e_4501;
            2'b?: \do_push  = 1'dx;
        endcase
    end
    assign _e_4505 = !\is_empty ;
    assign \do_pop  = \pop  && _e_4505;
    assign _e_4513 = \s [9:7];
    localparam[2:0] _e_4515 = 1;
    assign _e_4512 = _e_4513 + _e_4515;
    assign _e_4511 = _e_4512[2:0];
    assign _e_4517 = \s [9:7];
    assign \next_w  = \do_push  ? _e_4511 : _e_4517;
    assign _e_4525 = \s [6:4];
    localparam[2:0] _e_4527 = 1;
    assign _e_4524 = _e_4525 + _e_4527;
    assign _e_4523 = _e_4524[2:0];
    assign _e_4529 = \s [6:4];
    assign \next_r  = \do_pop  ? _e_4523 : _e_4529;
    assign _e_4533 = {\do_push , \do_pop };
    assign _e_4538 = _e_4533;
    assign _e_4536 = _e_4533[1];
    assign _e_4537 = _e_4533[0];
    assign _e_9283 = !_e_4537;
    assign _e_9284 = _e_4536 && _e_9283;
    assign _e_4541 = \s [3:0];
    localparam[3:0] _e_4543 = 1;
    assign _e_4540 = _e_4541 + _e_4543;
    assign _e_4539 = _e_4540[3:0];
    assign _e_4546 = _e_4533;
    assign _e_4544 = _e_4533[1];
    assign _e_4545 = _e_4533[0];
    assign _e_9286 = !_e_4544;
    assign _e_9288 = _e_9286 && _e_4545;
    assign _e_4549 = \s [3:0];
    localparam[3:0] _e_4551 = 1;
    assign _e_4548 = _e_4549 - _e_4551;
    assign _e_4547 = _e_4548[3:0];
    assign __n1 = _e_4533;
    localparam[0:0] _e_9289 = 1;
    assign _e_4553 = \s [3:0];
    always_comb begin
        priority casez ({_e_9284, _e_9288, _e_9289})
            3'b1??: \next_count  = _e_4539;
            3'b01?: \next_count  = _e_4547;
            3'b001: \next_count  = _e_4553;
            3'b?: \next_count  = 4'dx;
        endcase
    end
    assign \val  = \push [7:0];
    assign _e_9291 = \push [8] == 1'd1;
    localparam[0:0] _e_9292 = 1;
    assign _e_9293 = _e_9291 && _e_9292;
    assign _e_4564 = \s [73:10];
    assign _e_4566 = \s [9:7];
    (* src = "src/fifo.spade:71,39" *)
    \tta::fifo::set_mem  set_mem_0(.arr_i(_e_4564), .idx_i(_e_4566), .val_i(\val ), .output__(_e_4563));
    assign _e_4570 = \s [73:10];
    assign _e_4560 = \do_push  ? _e_4563 : _e_4570;
    assign _e_9295 = \push [8] == 1'd0;
    assign _e_4573 = \s [73:10];
    always_comb begin
        priority casez ({_e_9293, _e_9295})
            2'b1?: \next_mem  = _e_4560;
            2'b01: \next_mem  = _e_4573;
            2'b?: \next_mem  = 64'dx;
        endcase
    end
    assign _e_4576 = {\next_mem , \next_w , \next_r , \next_count };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s  <= _e_4480;
        end
        else begin
            \s  <= _e_4576;
        end
    end
    assign _e_4582 = \s [3:0];
    localparam[3:0] _e_4584 = 0;
    assign \empty  = _e_4582 == _e_4584;
    assign _e_4587 = \s [3:0];
    localparam[3:0] _e_4589 = 8;
    assign \full  = _e_4587 == _e_4589;
    assign _e_4592 = !\empty ;
    assign _e_4596 = \s [6:4];
    assign _e_4598 = _e_4596;
    localparam[2:0] _e_9297 = 0;
    assign _e_9296 = _e_4596 == _e_9297;
    assign _e_4600 = \s [73:10];
    localparam[2:0] _e_4602 = 0;
    assign _e_4599 = _e_4600[_e_4602 * 8+:8];
    assign _e_4603 = _e_4596;
    localparam[2:0] _e_9299 = 1;
    assign _e_9298 = _e_4596 == _e_9299;
    assign _e_4605 = \s [73:10];
    localparam[2:0] _e_4607 = 1;
    assign _e_4604 = _e_4605[_e_4607 * 8+:8];
    assign _e_4608 = _e_4596;
    localparam[2:0] _e_9301 = 2;
    assign _e_9300 = _e_4596 == _e_9301;
    assign _e_4610 = \s [73:10];
    localparam[2:0] _e_4612 = 2;
    assign _e_4609 = _e_4610[_e_4612 * 8+:8];
    assign _e_4613 = _e_4596;
    localparam[2:0] _e_9303 = 3;
    assign _e_9302 = _e_4596 == _e_9303;
    assign _e_4615 = \s [73:10];
    localparam[2:0] _e_4617 = 3;
    assign _e_4614 = _e_4615[_e_4617 * 8+:8];
    assign _e_4618 = _e_4596;
    localparam[2:0] _e_9305 = 4;
    assign _e_9304 = _e_4596 == _e_9305;
    assign _e_4620 = \s [73:10];
    localparam[2:0] _e_4622 = 4;
    assign _e_4619 = _e_4620[_e_4622 * 8+:8];
    assign _e_4623 = _e_4596;
    localparam[2:0] _e_9307 = 5;
    assign _e_9306 = _e_4596 == _e_9307;
    assign _e_4625 = \s [73:10];
    localparam[2:0] _e_4627 = 5;
    assign _e_4624 = _e_4625[_e_4627 * 8+:8];
    assign _e_4628 = _e_4596;
    localparam[2:0] _e_9309 = 6;
    assign _e_9308 = _e_4596 == _e_9309;
    assign _e_4630 = \s [73:10];
    localparam[2:0] _e_4632 = 6;
    assign _e_4629 = _e_4630[_e_4632 * 8+:8];
    assign _e_4633 = _e_4596;
    localparam[2:0] _e_9311 = 7;
    assign _e_9310 = _e_4596 == _e_9311;
    assign _e_4635 = \s [73:10];
    localparam[2:0] _e_4637 = 7;
    assign _e_4634 = _e_4635[_e_4637 * 8+:8];
    always_comb begin
        priority casez ({_e_9296, _e_9298, _e_9300, _e_9302, _e_9304, _e_9306, _e_9308, _e_9310})
            8'b1???????: val_n1 = _e_4599;
            8'b01??????: val_n1 = _e_4604;
            8'b001?????: val_n1 = _e_4609;
            8'b0001????: val_n1 = _e_4614;
            8'b00001???: val_n1 = _e_4619;
            8'b000001??: val_n1 = _e_4624;
            8'b0000001?: val_n1 = _e_4629;
            8'b00000001: val_n1 = _e_4634;
            8'b?: val_n1 = 8'dx;
        endcase
    end
    assign _e_4639 = {1'd1, val_n1};
    assign _e_4642 = {1'd0, 8'bX};
    assign \out_val  = _e_4592 ? _e_4639 : _e_4642;
    assign _e_4647 = \s [3:0];
    assign _e_4644 = {\full , \empty , _e_4647, \out_val };
    assign output__ = _e_4644;
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
    logic _e_9313;
    logic _e_9315;
    logic _e_9317;
    (* src = "src/lsu.spade:23,47" *)
    logic[31:0] _e_4655;
    (* src = "src/lsu.spade:23,14" *)
    reg[31:0] \addr_a ;
    (* src = "src/lsu.spade:29,9" *)
    logic[31:0] \b ;
    logic _e_9319;
    logic _e_9321;
    (* src = "src/lsu.spade:29,20" *)
    logic[32:0] _e_4666;
    logic _e_9323;
    logic[32:0] _e_4670;
    (* src = "src/lsu.spade:28,31" *)
    logic[32:0] \addr_calc ;
    (* src = "src/lsu.spade:34,41" *)
    logic[31:0] \_ ;
    logic _e_9325;
    logic _e_9327;
    logic _e_9329;
    (* src = "src/lsu.spade:34,22" *)
    logic \wren ;
    (* src = "src/lsu.spade:35,36" *)
    logic[31:0] \x ;
    logic _e_9331;
    logic _e_9333;
    logic _e_9335;
    (* src = "src/lsu.spade:35,17" *)
    logic[31:0] \wdata ;
    (* src = "src/lsu.spade:36,56" *)
    logic[15:0] _e_4693;
    (* src = "src/lsu.spade:36,17" *)
    logic[31:0] \rdata ;
    (* src = "src/lsu.spade:39,55" *)
    logic[65:0] _e_4703;
    (* src = "src/lsu.spade:40,9" *)
    logic[65:0] _e_4709;
    (* src = "src/lsu.spade:40,9" *)
    logic[32:0] _e_4707;
    (* src = "src/lsu.spade:40,10" *)
    logic[31:0] __n1;
    (* src = "src/lsu.spade:40,9" *)
    logic[32:0] _e_4708;
    logic _e_9338;
    logic _e_9340;
    logic _e_9342;
    logic _e_9343;
    (* src = "src/lsu.spade:41,9" *)
    logic[65:0] _e_4714;
    (* src = "src/lsu.spade:41,9" *)
    logic[32:0] __n2;
    (* src = "src/lsu.spade:41,9" *)
    logic[32:0] _e_4713;
    (* src = "src/lsu.spade:41,13" *)
    logic[31:0] __n3;
    logic _e_9347;
    logic _e_9349;
    logic _e_9350;
    (* src = "src/lsu.spade:42,9" *)
    logic[65:0] _e_4718;
    (* src = "src/lsu.spade:42,9" *)
    logic[32:0] _e_4716;
    (* src = "src/lsu.spade:42,9" *)
    logic[32:0] _e_4717;
    logic _e_9353;
    logic _e_9355;
    logic _e_9356;
    (* src = "src/lsu.spade:39,49" *)
    logic _e_4702;
    (* src = "src/lsu.spade:39,14" *)
    reg \ld_ready ;
    (* src = "src/lsu.spade:45,19" *)
    logic[32:0] _e_4723;
    (* src = "src/lsu.spade:45,40" *)
    logic[32:0] _e_4726;
    (* src = "src/lsu.spade:45,5" *)
    logic[32:0] _e_4720;
    localparam[31:0] _e_4654 = 32'd0;
    assign \v  = \set_addr_a [31:0];
    assign _e_9313 = \set_addr_a [32] == 1'd1;
    localparam[0:0] _e_9314 = 1;
    assign _e_9315 = _e_9313 && _e_9314;
    assign _e_9317 = \set_addr_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9315, _e_9317})
            2'b1?: _e_4655 = \v ;
            2'b01: _e_4655 = \addr_a ;
            2'b?: _e_4655 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \addr_a  <= _e_4654;
        end
        else begin
            \addr_a  <= _e_4655;
        end
    end
    assign \b  = \load_trig [31:0];
    assign _e_9319 = \load_trig [32] == 1'd1;
    localparam[0:0] _e_9320 = 1;
    assign _e_9321 = _e_9319 && _e_9320;
    assign _e_4666 = \addr_a  + \b ;
    assign _e_9323 = \load_trig [32] == 1'd0;
    assign _e_4670 = {1'b0, \addr_a };
    always_comb begin
        priority casez ({_e_9321, _e_9323})
            2'b1?: \addr_calc  = _e_4666;
            2'b01: \addr_calc  = _e_4670;
            2'b?: \addr_calc  = 33'dx;
        endcase
    end
    assign \_  = \store_trig [31:0];
    assign _e_9325 = \store_trig [32] == 1'd1;
    localparam[0:0] _e_9326 = 1;
    assign _e_9327 = _e_9325 && _e_9326;
    localparam[0:0] _e_4677 = 1;
    assign _e_9329 = \store_trig [32] == 1'd0;
    localparam[0:0] _e_4679 = 0;
    always_comb begin
        priority casez ({_e_9327, _e_9329})
            2'b1?: \wren  = _e_4677;
            2'b01: \wren  = _e_4679;
            2'b?: \wren  = 1'dx;
        endcase
    end
    assign \x  = \store_trig [31:0];
    assign _e_9331 = \store_trig [32] == 1'd1;
    localparam[0:0] _e_9332 = 1;
    assign _e_9333 = _e_9331 && _e_9332;
    assign _e_9335 = \store_trig [32] == 1'd0;
    localparam[31:0] _e_4687 = 32'd0;
    always_comb begin
        priority casez ({_e_9333, _e_9335})
            2'b1?: \wdata  = \x ;
            2'b01: \wdata  = _e_4687;
            2'b?: \wdata  = 32'dx;
        endcase
    end
    localparam[0:0] _e_4692 = 1;
    assign _e_4693 = \addr_calc [15:0];
    (* src = "src/lsu.spade:36,17" *)
    \tta::sram::sram_512x32  sram_512x32_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .en_i(_e_4692), .addr_i(_e_4693), .we_i(\wren ), .wdata_i(\wdata ), .output__(\rdata ));
    localparam[0:0] _e_4701 = 0;
    assign _e_4703 = {\load_trig , \store_trig };
    assign _e_4709 = _e_4703;
    assign _e_4707 = _e_4703[65:33];
    assign __n1 = _e_4707[31:0];
    assign _e_4708 = _e_4703[32:0];
    assign _e_9338 = _e_4707[32] == 1'd1;
    localparam[0:0] _e_9339 = 1;
    assign _e_9340 = _e_9338 && _e_9339;
    assign _e_9342 = _e_4708[32] == 1'd0;
    assign _e_9343 = _e_9340 && _e_9342;
    localparam[0:0] _e_4710 = 1;
    assign _e_4714 = _e_4703;
    assign __n2 = _e_4703[65:33];
    assign _e_4713 = _e_4703[32:0];
    assign __n3 = _e_4713[31:0];
    localparam[0:0] _e_9345 = 1;
    assign _e_9347 = _e_4713[32] == 1'd1;
    localparam[0:0] _e_9348 = 1;
    assign _e_9349 = _e_9347 && _e_9348;
    assign _e_9350 = _e_9345 && _e_9349;
    localparam[0:0] _e_4715 = 0;
    assign _e_4718 = _e_4703;
    assign _e_4716 = _e_4703[65:33];
    assign _e_4717 = _e_4703[32:0];
    assign _e_9353 = _e_4716[32] == 1'd0;
    assign _e_9355 = _e_4717[32] == 1'd0;
    assign _e_9356 = _e_9353 && _e_9355;
    localparam[0:0] _e_4719 = 0;
    always_comb begin
        priority casez ({_e_9343, _e_9350, _e_9356})
            3'b1??: _e_4702 = _e_4710;
            3'b01?: _e_4702 = _e_4715;
            3'b001: _e_4702 = _e_4719;
            3'b?: _e_4702 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \ld_ready  <= _e_4701;
        end
        else begin
            \ld_ready  <= _e_4702;
        end
    end
    assign _e_4723 = {1'd1, \rdata };
    assign _e_4726 = {1'd0, 32'bX};
    assign _e_4720 = \ld_ready  ? _e_4723 : _e_4726;
    assign output__ = _e_4720;
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
    logic[42:0] _e_4731;
    (* src = "src/lsu.spade:54,14" *)
    logic[31:0] \x ;
    logic _e_9358;
    logic _e_9360;
    logic _e_9362;
    logic _e_9363;
    (* src = "src/lsu.spade:54,35" *)
    logic[32:0] _e_4733;
    (* src = "src/lsu.spade:55,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:56,13" *)
    logic[42:0] _e_4739;
    (* src = "src/lsu.spade:56,18" *)
    logic[31:0] x_n1;
    logic _e_9366;
    logic _e_9368;
    logic _e_9370;
    logic _e_9371;
    (* src = "src/lsu.spade:56,39" *)
    logic[32:0] _e_4741;
    (* src = "src/lsu.spade:57,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:57,18" *)
    logic[32:0] _e_4744;
    (* src = "src/lsu.spade:55,14" *)
    logic[32:0] _e_4736;
    (* src = "src/lsu.spade:53,5" *)
    logic[32:0] _e_4728;
    assign _e_4731 = \m1 [42:0];
    assign \x  = _e_4731[36:5];
    assign _e_9358 = \m1 [43] == 1'd1;
    assign _e_9360 = _e_4731[42:37] == 6'd4;
    localparam[0:0] _e_9361 = 1;
    assign _e_9362 = _e_9360 && _e_9361;
    assign _e_9363 = _e_9358 && _e_9362;
    assign _e_4733 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9364 = 1;
    assign _e_4739 = \m0 [42:0];
    assign x_n1 = _e_4739[36:5];
    assign _e_9366 = \m0 [43] == 1'd1;
    assign _e_9368 = _e_4739[42:37] == 6'd4;
    localparam[0:0] _e_9369 = 1;
    assign _e_9370 = _e_9368 && _e_9369;
    assign _e_9371 = _e_9366 && _e_9370;
    assign _e_4741 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9372 = 1;
    assign _e_4744 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9371, _e_9372})
            2'b1?: _e_4736 = _e_4741;
            2'b01: _e_4736 = _e_4744;
            2'b?: _e_4736 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9363, _e_9364})
            2'b1?: _e_4728 = _e_4733;
            2'b01: _e_4728 = _e_4736;
            2'b?: _e_4728 = 33'dx;
        endcase
    end
    assign output__ = _e_4728;
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
    logic[42:0] _e_4749;
    (* src = "src/lsu.spade:64,14" *)
    logic[31:0] \x ;
    logic _e_9374;
    logic _e_9376;
    logic _e_9378;
    logic _e_9379;
    (* src = "src/lsu.spade:64,40" *)
    logic[32:0] _e_4751;
    (* src = "src/lsu.spade:65,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:66,13" *)
    logic[42:0] _e_4757;
    (* src = "src/lsu.spade:66,18" *)
    logic[31:0] x_n1;
    logic _e_9382;
    logic _e_9384;
    logic _e_9386;
    logic _e_9387;
    (* src = "src/lsu.spade:66,44" *)
    logic[32:0] _e_4759;
    (* src = "src/lsu.spade:67,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:67,18" *)
    logic[32:0] _e_4762;
    (* src = "src/lsu.spade:65,14" *)
    logic[32:0] _e_4754;
    (* src = "src/lsu.spade:63,5" *)
    logic[32:0] _e_4746;
    assign _e_4749 = \m1 [42:0];
    assign \x  = _e_4749[36:5];
    assign _e_9374 = \m1 [43] == 1'd1;
    assign _e_9376 = _e_4749[42:37] == 6'd5;
    localparam[0:0] _e_9377 = 1;
    assign _e_9378 = _e_9376 && _e_9377;
    assign _e_9379 = _e_9374 && _e_9378;
    assign _e_4751 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9380 = 1;
    assign _e_4757 = \m0 [42:0];
    assign x_n1 = _e_4757[36:5];
    assign _e_9382 = \m0 [43] == 1'd1;
    assign _e_9384 = _e_4757[42:37] == 6'd5;
    localparam[0:0] _e_9385 = 1;
    assign _e_9386 = _e_9384 && _e_9385;
    assign _e_9387 = _e_9382 && _e_9386;
    assign _e_4759 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9388 = 1;
    assign _e_4762 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9387, _e_9388})
            2'b1?: _e_4754 = _e_4759;
            2'b01: _e_4754 = _e_4762;
            2'b?: _e_4754 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9379, _e_9380})
            2'b1?: _e_4746 = _e_4751;
            2'b01: _e_4746 = _e_4754;
            2'b?: _e_4746 = 33'dx;
        endcase
    end
    assign output__ = _e_4746;
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
    logic[42:0] _e_4767;
    (* src = "src/lsu.spade:74,14" *)
    logic[31:0] \x ;
    logic _e_9390;
    logic _e_9392;
    logic _e_9394;
    logic _e_9395;
    (* src = "src/lsu.spade:74,41" *)
    logic[32:0] _e_4769;
    (* src = "src/lsu.spade:75,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:76,13" *)
    logic[42:0] _e_4775;
    (* src = "src/lsu.spade:76,18" *)
    logic[31:0] x_n1;
    logic _e_9398;
    logic _e_9400;
    logic _e_9402;
    logic _e_9403;
    (* src = "src/lsu.spade:76,45" *)
    logic[32:0] _e_4777;
    (* src = "src/lsu.spade:77,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:77,18" *)
    logic[32:0] _e_4780;
    (* src = "src/lsu.spade:75,14" *)
    logic[32:0] _e_4772;
    (* src = "src/lsu.spade:73,5" *)
    logic[32:0] _e_4764;
    assign _e_4767 = \m1 [42:0];
    assign \x  = _e_4767[36:5];
    assign _e_9390 = \m1 [43] == 1'd1;
    assign _e_9392 = _e_4767[42:37] == 6'd6;
    localparam[0:0] _e_9393 = 1;
    assign _e_9394 = _e_9392 && _e_9393;
    assign _e_9395 = _e_9390 && _e_9394;
    assign _e_4769 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9396 = 1;
    assign _e_4775 = \m0 [42:0];
    assign x_n1 = _e_4775[36:5];
    assign _e_9398 = \m0 [43] == 1'd1;
    assign _e_9400 = _e_4775[42:37] == 6'd6;
    localparam[0:0] _e_9401 = 1;
    assign _e_9402 = _e_9400 && _e_9401;
    assign _e_9403 = _e_9398 && _e_9402;
    assign _e_4777 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9404 = 1;
    assign _e_4780 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9403, _e_9404})
            2'b1?: _e_4772 = _e_4777;
            2'b01: _e_4772 = _e_4780;
            2'b?: _e_4772 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9395, _e_9396})
            2'b1?: _e_4764 = _e_4769;
            2'b01: _e_4764 = _e_4772;
            2'b?: _e_4764 = 33'dx;
        endcase
    end
    assign output__ = _e_4764;
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
    logic[42:0] _e_4785;
    (* src = "src/lsu.spade:85,14" *)
    logic[31:0] \x ;
    logic _e_9406;
    logic _e_9408;
    logic _e_9410;
    logic _e_9411;
    (* src = "src/lsu.spade:85,36" *)
    logic[32:0] _e_4787;
    (* src = "src/lsu.spade:86,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:87,13" *)
    logic[42:0] _e_4793;
    (* src = "src/lsu.spade:87,18" *)
    logic[31:0] x_n1;
    logic _e_9414;
    logic _e_9416;
    logic _e_9418;
    logic _e_9419;
    (* src = "src/lsu.spade:87,40" *)
    logic[32:0] _e_4795;
    (* src = "src/lsu.spade:88,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:88,18" *)
    logic[32:0] _e_4798;
    (* src = "src/lsu.spade:86,14" *)
    logic[32:0] _e_4790;
    (* src = "src/lsu.spade:84,5" *)
    logic[32:0] _e_4782;
    assign _e_4785 = \m1 [42:0];
    assign \x  = _e_4785[36:5];
    assign _e_9406 = \m1 [43] == 1'd1;
    assign _e_9408 = _e_4785[42:37] == 6'd7;
    localparam[0:0] _e_9409 = 1;
    assign _e_9410 = _e_9408 && _e_9409;
    assign _e_9411 = _e_9406 && _e_9410;
    assign _e_4787 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9412 = 1;
    assign _e_4793 = \m0 [42:0];
    assign x_n1 = _e_4793[36:5];
    assign _e_9414 = \m0 [43] == 1'd1;
    assign _e_9416 = _e_4793[42:37] == 6'd7;
    localparam[0:0] _e_9417 = 1;
    assign _e_9418 = _e_9416 && _e_9417;
    assign _e_9419 = _e_9414 && _e_9418;
    assign _e_4795 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9420 = 1;
    assign _e_4798 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9419, _e_9420})
            2'b1?: _e_4790 = _e_4795;
            2'b01: _e_4790 = _e_4798;
            2'b?: _e_4790 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9411, _e_9412})
            2'b1?: _e_4782 = _e_4787;
            2'b01: _e_4782 = _e_4790;
            2'b?: _e_4782 = 33'dx;
        endcase
    end
    assign output__ = _e_4782;
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
    logic[42:0] _e_4803;
    (* src = "src/lsu.spade:95,14" *)
    logic[31:0] \x ;
    logic _e_9422;
    logic _e_9424;
    logic _e_9426;
    logic _e_9427;
    (* src = "src/lsu.spade:95,41" *)
    logic[32:0] _e_4805;
    (* src = "src/lsu.spade:96,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:97,13" *)
    logic[42:0] _e_4811;
    (* src = "src/lsu.spade:97,18" *)
    logic[31:0] x_n1;
    logic _e_9430;
    logic _e_9432;
    logic _e_9434;
    logic _e_9435;
    (* src = "src/lsu.spade:97,45" *)
    logic[32:0] _e_4813;
    (* src = "src/lsu.spade:98,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:98,18" *)
    logic[32:0] _e_4816;
    (* src = "src/lsu.spade:96,14" *)
    logic[32:0] _e_4808;
    (* src = "src/lsu.spade:94,5" *)
    logic[32:0] _e_4800;
    assign _e_4803 = \m1 [42:0];
    assign \x  = _e_4803[36:5];
    assign _e_9422 = \m1 [43] == 1'd1;
    assign _e_9424 = _e_4803[42:37] == 6'd8;
    localparam[0:0] _e_9425 = 1;
    assign _e_9426 = _e_9424 && _e_9425;
    assign _e_9427 = _e_9422 && _e_9426;
    assign _e_4805 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9428 = 1;
    assign _e_4811 = \m0 [42:0];
    assign x_n1 = _e_4811[36:5];
    assign _e_9430 = \m0 [43] == 1'd1;
    assign _e_9432 = _e_4811[42:37] == 6'd8;
    localparam[0:0] _e_9433 = 1;
    assign _e_9434 = _e_9432 && _e_9433;
    assign _e_9435 = _e_9430 && _e_9434;
    assign _e_4813 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9436 = 1;
    assign _e_4816 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9435, _e_9436})
            2'b1?: _e_4808 = _e_4813;
            2'b01: _e_4808 = _e_4816;
            2'b?: _e_4808 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9427, _e_9428})
            2'b1?: _e_4800 = _e_4805;
            2'b01: _e_4800 = _e_4808;
            2'b?: _e_4800 = 33'dx;
        endcase
    end
    assign output__ = _e_4800;
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
    logic[42:0] _e_4821;
    (* src = "src/lsu.spade:105,14" *)
    logic[31:0] \x ;
    logic _e_9438;
    logic _e_9440;
    logic _e_9442;
    logic _e_9443;
    (* src = "src/lsu.spade:105,42" *)
    logic[32:0] _e_4823;
    (* src = "src/lsu.spade:106,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:107,13" *)
    logic[42:0] _e_4829;
    (* src = "src/lsu.spade:107,18" *)
    logic[31:0] x_n1;
    logic _e_9446;
    logic _e_9448;
    logic _e_9450;
    logic _e_9451;
    (* src = "src/lsu.spade:107,46" *)
    logic[32:0] _e_4831;
    (* src = "src/lsu.spade:108,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:108,18" *)
    logic[32:0] _e_4834;
    (* src = "src/lsu.spade:106,14" *)
    logic[32:0] _e_4826;
    (* src = "src/lsu.spade:104,5" *)
    logic[32:0] _e_4818;
    assign _e_4821 = \m1 [42:0];
    assign \x  = _e_4821[36:5];
    assign _e_9438 = \m1 [43] == 1'd1;
    assign _e_9440 = _e_4821[42:37] == 6'd9;
    localparam[0:0] _e_9441 = 1;
    assign _e_9442 = _e_9440 && _e_9441;
    assign _e_9443 = _e_9438 && _e_9442;
    assign _e_4823 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9444 = 1;
    assign _e_4829 = \m0 [42:0];
    assign x_n1 = _e_4829[36:5];
    assign _e_9446 = \m0 [43] == 1'd1;
    assign _e_9448 = _e_4829[42:37] == 6'd9;
    localparam[0:0] _e_9449 = 1;
    assign _e_9450 = _e_9448 && _e_9449;
    assign _e_9451 = _e_9446 && _e_9450;
    assign _e_4831 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9452 = 1;
    assign _e_4834 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9451, _e_9452})
            2'b1?: _e_4826 = _e_4831;
            2'b01: _e_4826 = _e_4834;
            2'b?: _e_4826 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9443, _e_9444})
            2'b1?: _e_4818 = _e_4823;
            2'b01: _e_4818 = _e_4826;
            2'b?: _e_4818 = 33'dx;
        endcase
    end
    assign output__ = _e_4818;
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
    logic[8:0] _e_4859;
    (* src = "src/parallel_rx.spade:32,9" *)
    logic[8:0] _e_4863;
    (* src = "src/parallel_rx.spade:31,14" *)
    reg[8:0] \rx ;
    (* src = "src/parallel_rx.spade:37,24" *)
    logic _e_4868;
    (* src = "src/parallel_rx.spade:37,23" *)
    logic _e_4867;
    (* src = "src/parallel_rx.spade:37,23" *)
    logic \rising_edge ;
    (* src = "src/parallel_rx.spade:40,8" *)
    logic _e_4873;
    (* src = "src/parallel_rx.spade:41,14" *)
    logic[7:0] _e_4878;
    (* src = "src/parallel_rx.spade:41,9" *)
    logic[8:0] _e_4877;
    (* src = "src/parallel_rx.spade:43,9" *)
    logic[8:0] _e_4881;
    (* src = "src/parallel_rx.spade:40,5" *)
    logic[8:0] _e_4872;
    localparam[0:0] _e_4839 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \clk_pin_s1  <= _e_4839;
        end
        else begin
            \clk_pin_s1  <= \clk_pin ;
        end
    end
    localparam[0:0] _e_4844 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \clk_pin_s2  <= _e_4844;
        end
        else begin
            \clk_pin_s2  <= \clk_pin_s1 ;
        end
    end
    localparam[7:0] _e_4849 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \data_sync  <= _e_4849;
        end
        else begin
            \data_sync  <= \data_in ;
        end
    end
    localparam[0:0] _e_4854 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \strobe_sync  <= _e_4854;
        end
        else begin
            \strobe_sync  <= \strobe ;
        end
    end
    localparam[0:0] _e_4860 = 0;
    localparam[7:0] _e_4861 = 0;
    assign _e_4859 = {_e_4860, _e_4861};
    assign _e_4863 = {\clk_pin_s2 , \data_sync };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx  <= _e_4859;
        end
        else begin
            \rx  <= _e_4863;
        end
    end
    assign _e_4868 = \rx [8];
    assign _e_4867 = !_e_4868;
    assign \rising_edge  = _e_4867 && \clk_pin_s2 ;
    assign _e_4873 = \rising_edge  && \strobe_sync ;
    assign _e_4878 = \rx [7:0];
    assign _e_4877 = {1'd1, _e_4878};
    assign _e_4881 = {1'd0, 8'bX};
    assign _e_4872 = _e_4873 ? _e_4877 : _e_4881;
    assign output__ = _e_4872;
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
    logic _e_9454;
    logic _e_9456;
    logic _e_9458;
    (* src = "src/sel.spade:18,45" *)
    logic _e_4887;
    (* src = "src/sel.spade:18,14" *)
    reg \cond ;
    (* src = "src/sel.spade:24,9" *)
    logic[31:0] \v ;
    logic _e_9460;
    logic _e_9462;
    logic _e_9464;
    (* src = "src/sel.spade:23,46" *)
    logic[31:0] _e_4898;
    (* src = "src/sel.spade:23,14" *)
    reg[31:0] \val_a ;
    (* src = "src/sel.spade:30,47" *)
    logic[32:0] _e_4908;
    (* src = "src/sel.spade:31,9" *)
    logic[31:0] \val_b ;
    logic _e_9466;
    logic _e_9468;
    (* src = "src/sel.spade:33,17" *)
    logic[32:0] _e_4917;
    (* src = "src/sel.spade:35,17" *)
    logic[32:0] _e_4920;
    (* src = "src/sel.spade:32,13" *)
    logic[32:0] _e_4914;
    logic _e_9470;
    (* src = "src/sel.spade:38,17" *)
    logic[32:0] _e_4923;
    (* src = "src/sel.spade:30,55" *)
    logic[32:0] _e_4909;
    (* src = "src/sel.spade:30,14" *)
    reg[32:0] \res ;
    localparam[0:0] _e_4886 = 0;
    assign \c  = \set_cond [0:0];
    assign _e_9454 = \set_cond [1] == 1'd1;
    localparam[0:0] _e_9455 = 1;
    assign _e_9456 = _e_9454 && _e_9455;
    assign _e_9458 = \set_cond [1] == 1'd0;
    always_comb begin
        priority casez ({_e_9456, _e_9458})
            2'b1?: _e_4887 = \c ;
            2'b01: _e_4887 = \cond ;
            2'b?: _e_4887 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \cond  <= _e_4886;
        end
        else begin
            \cond  <= _e_4887;
        end
    end
    localparam[31:0] _e_4897 = 32'd0;
    assign \v  = \set_a [31:0];
    assign _e_9460 = \set_a [32] == 1'd1;
    localparam[0:0] _e_9461 = 1;
    assign _e_9462 = _e_9460 && _e_9461;
    assign _e_9464 = \set_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9462, _e_9464})
            2'b1?: _e_4898 = \v ;
            2'b01: _e_4898 = \val_a ;
            2'b?: _e_4898 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \val_a  <= _e_4897;
        end
        else begin
            \val_a  <= _e_4898;
        end
    end
    assign _e_4908 = {1'd0, 32'bX};
    assign \val_b  = \trig_b [31:0];
    assign _e_9466 = \trig_b [32] == 1'd1;
    localparam[0:0] _e_9467 = 1;
    assign _e_9468 = _e_9466 && _e_9467;
    assign _e_4917 = {1'd1, \val_a };
    assign _e_4920 = {1'd1, \val_b };
    assign _e_4914 = \cond  ? _e_4917 : _e_4920;
    assign _e_9470 = \trig_b [32] == 1'd0;
    assign _e_4923 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9468, _e_9470})
            2'b1?: _e_4909 = _e_4914;
            2'b01: _e_4909 = _e_4923;
            2'b?: _e_4909 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_4908;
        end
        else begin
            \res  <= _e_4909;
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
    logic[42:0] _e_4929;
    (* src = "src/sel.spade:48,14" *)
    logic \a ;
    logic _e_9472;
    logic _e_9474;
    logic _e_9476;
    logic _e_9477;
    (* src = "src/sel.spade:48,35" *)
    logic[1:0] _e_4931;
    (* src = "src/sel.spade:49,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:49,25" *)
    logic[42:0] _e_4937;
    (* src = "src/sel.spade:49,30" *)
    logic a_n1;
    logic _e_9480;
    logic _e_9482;
    logic _e_9484;
    logic _e_9485;
    (* src = "src/sel.spade:49,51" *)
    logic[1:0] _e_4939;
    (* src = "src/sel.spade:49,60" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:49,65" *)
    logic[1:0] _e_4942;
    (* src = "src/sel.spade:49,14" *)
    logic[1:0] _e_4934;
    (* src = "src/sel.spade:47,5" *)
    logic[1:0] _e_4926;
    assign _e_4929 = \m1 [42:0];
    assign \a  = _e_4929[36:36];
    assign _e_9472 = \m1 [43] == 1'd1;
    assign _e_9474 = _e_4929[42:37] == 6'd27;
    localparam[0:0] _e_9475 = 1;
    assign _e_9476 = _e_9474 && _e_9475;
    assign _e_9477 = _e_9472 && _e_9476;
    assign _e_4931 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9478 = 1;
    assign _e_4937 = \m0 [42:0];
    assign a_n1 = _e_4937[36:36];
    assign _e_9480 = \m0 [43] == 1'd1;
    assign _e_9482 = _e_4937[42:37] == 6'd27;
    localparam[0:0] _e_9483 = 1;
    assign _e_9484 = _e_9482 && _e_9483;
    assign _e_9485 = _e_9480 && _e_9484;
    assign _e_4939 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9486 = 1;
    assign _e_4942 = {1'd0, 1'bX};
    always_comb begin
        priority casez ({_e_9485, _e_9486})
            2'b1?: _e_4934 = _e_4939;
            2'b01: _e_4934 = _e_4942;
            2'b?: _e_4934 = 2'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9477, _e_9478})
            2'b1?: _e_4926 = _e_4931;
            2'b01: _e_4926 = _e_4934;
            2'b?: _e_4926 = 2'dx;
        endcase
    end
    assign output__ = _e_4926;
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
    logic[42:0] _e_4947;
    (* src = "src/sel.spade:55,14" *)
    logic[31:0] \a ;
    logic _e_9488;
    logic _e_9490;
    logic _e_9492;
    logic _e_9493;
    (* src = "src/sel.spade:55,35" *)
    logic[32:0] _e_4949;
    (* src = "src/sel.spade:56,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:56,25" *)
    logic[42:0] _e_4955;
    (* src = "src/sel.spade:56,30" *)
    logic[31:0] a_n1;
    logic _e_9496;
    logic _e_9498;
    logic _e_9500;
    logic _e_9501;
    (* src = "src/sel.spade:56,51" *)
    logic[32:0] _e_4957;
    (* src = "src/sel.spade:56,60" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:56,65" *)
    logic[32:0] _e_4960;
    (* src = "src/sel.spade:56,14" *)
    logic[32:0] _e_4952;
    (* src = "src/sel.spade:54,5" *)
    logic[32:0] _e_4944;
    assign _e_4947 = \m1 [42:0];
    assign \a  = _e_4947[36:5];
    assign _e_9488 = \m1 [43] == 1'd1;
    assign _e_9490 = _e_4947[42:37] == 6'd28;
    localparam[0:0] _e_9491 = 1;
    assign _e_9492 = _e_9490 && _e_9491;
    assign _e_9493 = _e_9488 && _e_9492;
    assign _e_4949 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9494 = 1;
    assign _e_4955 = \m0 [42:0];
    assign a_n1 = _e_4955[36:5];
    assign _e_9496 = \m0 [43] == 1'd1;
    assign _e_9498 = _e_4955[42:37] == 6'd28;
    localparam[0:0] _e_9499 = 1;
    assign _e_9500 = _e_9498 && _e_9499;
    assign _e_9501 = _e_9496 && _e_9500;
    assign _e_4957 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9502 = 1;
    assign _e_4960 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9501, _e_9502})
            2'b1?: _e_4952 = _e_4957;
            2'b01: _e_4952 = _e_4960;
            2'b?: _e_4952 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9493, _e_9494})
            2'b1?: _e_4944 = _e_4949;
            2'b01: _e_4944 = _e_4952;
            2'b?: _e_4944 = 33'dx;
        endcase
    end
    assign output__ = _e_4944;
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
    logic[42:0] _e_4965;
    (* src = "src/sel.spade:62,14" *)
    logic[31:0] \a ;
    logic _e_9504;
    logic _e_9506;
    logic _e_9508;
    logic _e_9509;
    (* src = "src/sel.spade:62,36" *)
    logic[32:0] _e_4967;
    (* src = "src/sel.spade:63,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:63,25" *)
    logic[42:0] _e_4973;
    (* src = "src/sel.spade:63,30" *)
    logic[31:0] a_n1;
    logic _e_9512;
    logic _e_9514;
    logic _e_9516;
    logic _e_9517;
    (* src = "src/sel.spade:63,52" *)
    logic[32:0] _e_4975;
    (* src = "src/sel.spade:63,61" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:63,66" *)
    logic[32:0] _e_4978;
    (* src = "src/sel.spade:63,14" *)
    logic[32:0] _e_4970;
    (* src = "src/sel.spade:61,5" *)
    logic[32:0] _e_4962;
    assign _e_4965 = \m1 [42:0];
    assign \a  = _e_4965[36:5];
    assign _e_9504 = \m1 [43] == 1'd1;
    assign _e_9506 = _e_4965[42:37] == 6'd29;
    localparam[0:0] _e_9507 = 1;
    assign _e_9508 = _e_9506 && _e_9507;
    assign _e_9509 = _e_9504 && _e_9508;
    assign _e_4967 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9510 = 1;
    assign _e_4973 = \m0 [42:0];
    assign a_n1 = _e_4973[36:5];
    assign _e_9512 = \m0 [43] == 1'd1;
    assign _e_9514 = _e_4973[42:37] == 6'd29;
    localparam[0:0] _e_9515 = 1;
    assign _e_9516 = _e_9514 && _e_9515;
    assign _e_9517 = _e_9512 && _e_9516;
    assign _e_4975 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9518 = 1;
    assign _e_4978 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9517, _e_9518})
            2'b1?: _e_4970 = _e_4975;
            2'b01: _e_4970 = _e_4978;
            2'b?: _e_4970 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9509, _e_9510})
            2'b1?: _e_4962 = _e_4967;
            2'b01: _e_4962 = _e_4970;
            2'b?: _e_4962 = 33'dx;
        endcase
    end
    assign output__ = _e_4962;
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
    logic[4:0] _e_4981;
    (* src = "src/bootloader.spade:61,5" *)
    logic[120:0] _e_4980;
    assign _e_4981 = {5'd0};
    localparam[15:0] _e_4982 = 0;
    localparam[15:0] _e_4983 = 0;
    localparam[9:0] _e_4984 = 0;
    localparam[9:0] _e_4985 = 0;
    localparam[31:0] _e_4986 = 32'd0;
    localparam[31:0] _e_4987 = 32'd0;
    assign _e_4980 = {_e_4981, _e_4982, _e_4983, _e_4984, _e_4985, _e_4986, _e_4987};
    assign output__ = _e_4980;
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
    logic[120:0] _e_4992;
    (* src = "src/bootloader.spade:72,28" *)
    logic[4:0] _e_4997;
    (* src = "src/bootloader.spade:72,15" *)
    logic[5:0] _e_4995;
    (* src = "src/bootloader.spade:73,13" *)
    logic[5:0] _e_5001;
    (* src = "src/bootloader.spade:73,13" *)
    logic _e_4999;
    (* src = "src/bootloader.spade:73,13" *)
    logic[4:0] _e_5000;
    logic _e_9522;
    logic _e_9523;
    (* src = "src/bootloader.spade:73,37" *)
    logic _e_5003;
    (* src = "src/bootloader.spade:74,27" *)
    logic[4:0] _e_5008;
    (* src = "src/bootloader.spade:74,38" *)
    logic[15:0] _e_5009;
    (* src = "src/bootloader.spade:74,46" *)
    logic[15:0] _e_5011;
    (* src = "src/bootloader.spade:74,56" *)
    logic[9:0] _e_5013;
    (* src = "src/bootloader.spade:74,66" *)
    logic[9:0] _e_5015;
    (* src = "src/bootloader.spade:74,74" *)
    logic[31:0] _e_5017;
    (* src = "src/bootloader.spade:74,81" *)
    logic[31:0] _e_5019;
    (* src = "src/bootloader.spade:74,21" *)
    logic[120:0] _e_5007;
    (* src = "src/bootloader.spade:76,21" *)
    logic[120:0] _e_5022;
    (* src = "src/bootloader.spade:73,34" *)
    logic[120:0] _e_5002;
    (* src = "src/bootloader.spade:78,13" *)
    logic[5:0] _e_5025;
    (* src = "src/bootloader.spade:78,13" *)
    logic _e_5023;
    (* src = "src/bootloader.spade:78,13" *)
    logic[4:0] _e_5024;
    logic _e_9527;
    logic _e_9528;
    (* src = "src/bootloader.spade:78,37" *)
    logic _e_5027;
    (* src = "src/bootloader.spade:79,27" *)
    logic[4:0] _e_5032;
    (* src = "src/bootloader.spade:79,37" *)
    logic[15:0] _e_5033;
    (* src = "src/bootloader.spade:79,45" *)
    logic[15:0] _e_5035;
    (* src = "src/bootloader.spade:79,55" *)
    logic[9:0] _e_5037;
    (* src = "src/bootloader.spade:79,65" *)
    logic[9:0] _e_5039;
    (* src = "src/bootloader.spade:79,73" *)
    logic[31:0] _e_5041;
    (* src = "src/bootloader.spade:79,80" *)
    logic[31:0] _e_5043;
    (* src = "src/bootloader.spade:79,21" *)
    logic[120:0] _e_5031;
    (* src = "src/bootloader.spade:81,21" *)
    logic[120:0] _e_5046;
    (* src = "src/bootloader.spade:78,34" *)
    logic[120:0] _e_5026;
    (* src = "src/bootloader.spade:83,13" *)
    logic[5:0] _e_5049;
    (* src = "src/bootloader.spade:83,13" *)
    logic _e_5047;
    (* src = "src/bootloader.spade:83,13" *)
    logic[4:0] _e_5048;
    logic _e_9532;
    logic _e_9533;
    (* src = "src/bootloader.spade:83,39" *)
    logic[4:0] _e_5051;
    logic[15:0] _e_5052;
    (* src = "src/bootloader.spade:83,61" *)
    logic[15:0] _e_5054;
    (* src = "src/bootloader.spade:83,71" *)
    logic[9:0] _e_5056;
    (* src = "src/bootloader.spade:83,81" *)
    logic[9:0] _e_5058;
    (* src = "src/bootloader.spade:83,89" *)
    logic[31:0] _e_5060;
    (* src = "src/bootloader.spade:83,96" *)
    logic[31:0] _e_5062;
    (* src = "src/bootloader.spade:83,33" *)
    logic[120:0] _e_5050;
    (* src = "src/bootloader.spade:84,13" *)
    logic[5:0] _e_5066;
    (* src = "src/bootloader.spade:84,13" *)
    logic _e_5064;
    (* src = "src/bootloader.spade:84,13" *)
    logic[4:0] _e_5065;
    logic _e_9537;
    logic _e_9538;
    logic[15:0] _e_5070;
    (* src = "src/bootloader.spade:85,29" *)
    logic[15:0] _e_5069;
    (* src = "src/bootloader.spade:85,49" *)
    logic[15:0] _e_5073;
    (* src = "src/bootloader.spade:85,29" *)
    logic[15:0] \v ;
    (* src = "src/bootloader.spade:86,24" *)
    logic _e_5077;
    (* src = "src/bootloader.spade:87,31" *)
    logic[4:0] _e_5082;
    (* src = "src/bootloader.spade:87,39" *)
    logic[15:0] _e_5083;
    (* src = "src/bootloader.spade:87,49" *)
    logic[15:0] _e_5085;
    (* src = "src/bootloader.spade:87,59" *)
    logic[9:0] _e_5087;
    (* src = "src/bootloader.spade:87,69" *)
    logic[9:0] _e_5089;
    (* src = "src/bootloader.spade:87,77" *)
    logic[31:0] _e_5091;
    (* src = "src/bootloader.spade:87,84" *)
    logic[31:0] _e_5093;
    (* src = "src/bootloader.spade:87,25" *)
    logic[120:0] _e_5081;
    (* src = "src/bootloader.spade:89,25" *)
    logic[120:0] _e_5096;
    (* src = "src/bootloader.spade:86,21" *)
    logic[120:0] _e_5076;
    (* src = "src/bootloader.spade:92,13" *)
    logic[5:0] _e_5099;
    (* src = "src/bootloader.spade:92,13" *)
    logic _e_5097;
    (* src = "src/bootloader.spade:92,13" *)
    logic[4:0] _e_5098;
    logic _e_9542;
    logic _e_9543;
    (* src = "src/bootloader.spade:92,37" *)
    logic[4:0] _e_5101;
    (* src = "src/bootloader.spade:92,45" *)
    logic[15:0] _e_5102;
    logic[15:0] _e_5104;
    (* src = "src/bootloader.spade:92,65" *)
    logic[9:0] _e_5106;
    (* src = "src/bootloader.spade:92,75" *)
    logic[9:0] _e_5108;
    (* src = "src/bootloader.spade:92,83" *)
    logic[31:0] _e_5110;
    (* src = "src/bootloader.spade:92,90" *)
    logic[31:0] _e_5112;
    (* src = "src/bootloader.spade:92,31" *)
    logic[120:0] _e_5100;
    (* src = "src/bootloader.spade:93,13" *)
    logic[5:0] _e_5116;
    (* src = "src/bootloader.spade:93,13" *)
    logic _e_5114;
    (* src = "src/bootloader.spade:93,13" *)
    logic[4:0] _e_5115;
    logic _e_9547;
    logic _e_9548;
    logic[15:0] _e_5120;
    (* src = "src/bootloader.spade:94,29" *)
    logic[15:0] _e_5119;
    (* src = "src/bootloader.spade:94,49" *)
    logic[15:0] _e_5123;
    (* src = "src/bootloader.spade:94,29" *)
    logic[15:0] \n ;
    (* src = "src/bootloader.spade:95,40" *)
    logic _e_5127;
    (* src = "src/bootloader.spade:95,37" *)
    logic[15:0] \n_clamped ;
    (* src = "src/bootloader.spade:96,27" *)
    logic[4:0] _e_5136;
    (* src = "src/bootloader.spade:96,35" *)
    logic[15:0] _e_5137;
    (* src = "src/bootloader.spade:96,43" *)
    logic[15:0] _e_5139;
    (* src = "src/bootloader.spade:96,61" *)
    logic[9:0] _e_5141;
    (* src = "src/bootloader.spade:96,71" *)
    logic[9:0] _e_5143;
    (* src = "src/bootloader.spade:96,79" *)
    logic[31:0] _e_5145;
    (* src = "src/bootloader.spade:96,86" *)
    logic[31:0] _e_5147;
    (* src = "src/bootloader.spade:96,21" *)
    logic[120:0] _e_5135;
    (* src = "src/bootloader.spade:98,13" *)
    logic[5:0] _e_5151;
    (* src = "src/bootloader.spade:98,13" *)
    logic _e_5149;
    (* src = "src/bootloader.spade:98,13" *)
    logic[4:0] _e_5150;
    logic _e_9552;
    logic _e_9553;
    (* src = "src/bootloader.spade:98,37" *)
    logic[4:0] _e_5153;
    (* src = "src/bootloader.spade:98,45" *)
    logic[15:0] _e_5154;
    (* src = "src/bootloader.spade:98,53" *)
    logic[15:0] _e_5156;
    logic[9:0] _e_5158;
    (* src = "src/bootloader.spade:98,75" *)
    logic[9:0] _e_5160;
    (* src = "src/bootloader.spade:98,83" *)
    logic[31:0] _e_5162;
    (* src = "src/bootloader.spade:98,90" *)
    logic[31:0] _e_5164;
    (* src = "src/bootloader.spade:98,31" *)
    logic[120:0] _e_5152;
    (* src = "src/bootloader.spade:99,13" *)
    logic[5:0] _e_5168;
    (* src = "src/bootloader.spade:99,13" *)
    logic _e_5166;
    (* src = "src/bootloader.spade:99,13" *)
    logic[4:0] _e_5167;
    logic _e_9557;
    logic _e_9558;
    logic[9:0] _e_5172;
    (* src = "src/bootloader.spade:100,29" *)
    logic[9:0] _e_5171;
    (* src = "src/bootloader.spade:100,49" *)
    logic[9:0] _e_5175;
    (* src = "src/bootloader.spade:100,29" *)
    logic[9:0] \e ;
    (* src = "src/bootloader.spade:101,24" *)
    logic[15:0] _e_5180;
    (* src = "src/bootloader.spade:101,24" *)
    logic _e_5179;
    (* src = "src/bootloader.spade:102,31" *)
    logic[4:0] _e_5185;
    (* src = "src/bootloader.spade:102,41" *)
    logic[15:0] _e_5186;
    (* src = "src/bootloader.spade:102,49" *)
    logic[15:0] _e_5188;
    (* src = "src/bootloader.spade:102,59" *)
    logic[9:0] _e_5190;
    (* src = "src/bootloader.spade:102,69" *)
    logic[9:0] _e_5192;
    (* src = "src/bootloader.spade:102,77" *)
    logic[31:0] _e_5194;
    (* src = "src/bootloader.spade:102,84" *)
    logic[31:0] _e_5196;
    (* src = "src/bootloader.spade:102,25" *)
    logic[120:0] _e_5184;
    (* src = "src/bootloader.spade:104,31" *)
    logic[4:0] _e_5200;
    (* src = "src/bootloader.spade:104,42" *)
    logic[15:0] _e_5201;
    (* src = "src/bootloader.spade:104,50" *)
    logic[15:0] _e_5203;
    (* src = "src/bootloader.spade:104,60" *)
    logic[9:0] _e_5205;
    (* src = "src/bootloader.spade:104,70" *)
    logic[9:0] _e_5207;
    (* src = "src/bootloader.spade:104,78" *)
    logic[31:0] _e_5209;
    (* src = "src/bootloader.spade:104,85" *)
    logic[31:0] _e_5211;
    (* src = "src/bootloader.spade:104,25" *)
    logic[120:0] _e_5199;
    (* src = "src/bootloader.spade:101,21" *)
    logic[120:0] _e_5178;
    (* src = "src/bootloader.spade:109,13" *)
    logic[5:0] _e_5215;
    (* src = "src/bootloader.spade:109,13" *)
    logic _e_5213;
    (* src = "src/bootloader.spade:109,13" *)
    logic[4:0] _e_5214;
    logic _e_9562;
    logic _e_9563;
    (* src = "src/bootloader.spade:109,40" *)
    logic[4:0] _e_5217;
    (* src = "src/bootloader.spade:109,51" *)
    logic[15:0] _e_5218;
    (* src = "src/bootloader.spade:109,59" *)
    logic[15:0] _e_5220;
    (* src = "src/bootloader.spade:109,69" *)
    logic[9:0] _e_5222;
    (* src = "src/bootloader.spade:109,79" *)
    logic[9:0] _e_5224;
    logic[31:0] _e_5228;
    (* src = "src/bootloader.spade:109,115" *)
    logic[31:0] _e_5231;
    (* src = "src/bootloader.spade:109,114" *)
    logic[31:0] _e_5230;
    (* src = "src/bootloader.spade:109,93" *)
    logic[31:0] _e_5227;
    (* src = "src/bootloader.spade:109,87" *)
    logic[31:0] _e_5226;
    (* src = "src/bootloader.spade:109,137" *)
    logic[31:0] _e_5234;
    (* src = "src/bootloader.spade:109,34" *)
    logic[120:0] _e_5216;
    (* src = "src/bootloader.spade:110,13" *)
    logic[5:0] _e_5238;
    (* src = "src/bootloader.spade:110,13" *)
    logic _e_5236;
    (* src = "src/bootloader.spade:110,13" *)
    logic[4:0] _e_5237;
    logic _e_9567;
    logic _e_9568;
    (* src = "src/bootloader.spade:110,40" *)
    logic[4:0] _e_5240;
    (* src = "src/bootloader.spade:110,51" *)
    logic[15:0] _e_5241;
    (* src = "src/bootloader.spade:110,59" *)
    logic[15:0] _e_5243;
    (* src = "src/bootloader.spade:110,69" *)
    logic[9:0] _e_5245;
    (* src = "src/bootloader.spade:110,79" *)
    logic[9:0] _e_5247;
    logic[31:0] _e_5252;
    (* src = "src/bootloader.spade:110,93" *)
    logic[31:0] _e_5251;
    (* src = "src/bootloader.spade:110,115" *)
    logic[31:0] _e_5256;
    (* src = "src/bootloader.spade:110,114" *)
    logic[31:0] _e_5255;
    (* src = "src/bootloader.spade:110,93" *)
    logic[31:0] _e_5250;
    (* src = "src/bootloader.spade:110,87" *)
    logic[31:0] _e_5249;
    (* src = "src/bootloader.spade:110,137" *)
    logic[31:0] _e_5259;
    (* src = "src/bootloader.spade:110,34" *)
    logic[120:0] _e_5239;
    (* src = "src/bootloader.spade:111,13" *)
    logic[5:0] _e_5263;
    (* src = "src/bootloader.spade:111,13" *)
    logic _e_5261;
    (* src = "src/bootloader.spade:111,13" *)
    logic[4:0] _e_5262;
    logic _e_9572;
    logic _e_9573;
    (* src = "src/bootloader.spade:111,40" *)
    logic[4:0] _e_5265;
    (* src = "src/bootloader.spade:111,51" *)
    logic[15:0] _e_5266;
    (* src = "src/bootloader.spade:111,59" *)
    logic[15:0] _e_5268;
    (* src = "src/bootloader.spade:111,69" *)
    logic[9:0] _e_5270;
    (* src = "src/bootloader.spade:111,79" *)
    logic[9:0] _e_5272;
    logic[31:0] _e_5277;
    (* src = "src/bootloader.spade:111,93" *)
    logic[31:0] _e_5276;
    (* src = "src/bootloader.spade:111,115" *)
    logic[31:0] _e_5281;
    (* src = "src/bootloader.spade:111,114" *)
    logic[31:0] _e_5280;
    (* src = "src/bootloader.spade:111,93" *)
    logic[31:0] _e_5275;
    (* src = "src/bootloader.spade:111,87" *)
    logic[31:0] _e_5274;
    (* src = "src/bootloader.spade:111,137" *)
    logic[31:0] _e_5284;
    (* src = "src/bootloader.spade:111,34" *)
    logic[120:0] _e_5264;
    (* src = "src/bootloader.spade:112,13" *)
    logic[5:0] _e_5288;
    (* src = "src/bootloader.spade:112,13" *)
    logic _e_5286;
    (* src = "src/bootloader.spade:112,13" *)
    logic[4:0] _e_5287;
    logic _e_9577;
    logic _e_9578;
    (* src = "src/bootloader.spade:112,40" *)
    logic[4:0] _e_5290;
    (* src = "src/bootloader.spade:112,51" *)
    logic[15:0] _e_5291;
    (* src = "src/bootloader.spade:112,59" *)
    logic[15:0] _e_5293;
    (* src = "src/bootloader.spade:112,69" *)
    logic[9:0] _e_5295;
    (* src = "src/bootloader.spade:112,79" *)
    logic[9:0] _e_5297;
    logic[31:0] _e_5302;
    (* src = "src/bootloader.spade:112,93" *)
    logic[31:0] _e_5301;
    (* src = "src/bootloader.spade:112,115" *)
    logic[31:0] _e_5306;
    (* src = "src/bootloader.spade:112,114" *)
    logic[31:0] _e_5305;
    (* src = "src/bootloader.spade:112,93" *)
    logic[31:0] _e_5300;
    (* src = "src/bootloader.spade:112,87" *)
    logic[31:0] _e_5299;
    (* src = "src/bootloader.spade:112,137" *)
    logic[31:0] _e_5309;
    (* src = "src/bootloader.spade:112,34" *)
    logic[120:0] _e_5289;
    (* src = "src/bootloader.spade:115,13" *)
    logic[5:0] _e_5313;
    (* src = "src/bootloader.spade:115,13" *)
    logic _e_5311;
    (* src = "src/bootloader.spade:115,13" *)
    logic[4:0] _e_5312;
    logic _e_9582;
    logic _e_9583;
    (* src = "src/bootloader.spade:115,40" *)
    logic[4:0] _e_5315;
    (* src = "src/bootloader.spade:115,51" *)
    logic[15:0] _e_5316;
    (* src = "src/bootloader.spade:115,59" *)
    logic[15:0] _e_5318;
    (* src = "src/bootloader.spade:115,69" *)
    logic[9:0] _e_5320;
    (* src = "src/bootloader.spade:115,79" *)
    logic[9:0] _e_5322;
    (* src = "src/bootloader.spade:115,87" *)
    logic[31:0] _e_5324;
    logic[31:0] _e_5328;
    (* src = "src/bootloader.spade:115,123" *)
    logic[31:0] _e_5331;
    (* src = "src/bootloader.spade:115,122" *)
    logic[31:0] _e_5330;
    (* src = "src/bootloader.spade:115,100" *)
    logic[31:0] _e_5327;
    (* src = "src/bootloader.spade:115,94" *)
    logic[31:0] _e_5326;
    (* src = "src/bootloader.spade:115,34" *)
    logic[120:0] _e_5314;
    (* src = "src/bootloader.spade:116,13" *)
    logic[5:0] _e_5336;
    (* src = "src/bootloader.spade:116,13" *)
    logic _e_5334;
    (* src = "src/bootloader.spade:116,13" *)
    logic[4:0] _e_5335;
    logic _e_9587;
    logic _e_9588;
    (* src = "src/bootloader.spade:116,40" *)
    logic[4:0] _e_5338;
    (* src = "src/bootloader.spade:116,51" *)
    logic[15:0] _e_5339;
    (* src = "src/bootloader.spade:116,59" *)
    logic[15:0] _e_5341;
    (* src = "src/bootloader.spade:116,69" *)
    logic[9:0] _e_5343;
    (* src = "src/bootloader.spade:116,79" *)
    logic[9:0] _e_5345;
    (* src = "src/bootloader.spade:116,87" *)
    logic[31:0] _e_5347;
    logic[31:0] _e_5352;
    (* src = "src/bootloader.spade:116,100" *)
    logic[31:0] _e_5351;
    (* src = "src/bootloader.spade:116,123" *)
    logic[31:0] _e_5356;
    (* src = "src/bootloader.spade:116,122" *)
    logic[31:0] _e_5355;
    (* src = "src/bootloader.spade:116,100" *)
    logic[31:0] _e_5350;
    (* src = "src/bootloader.spade:116,94" *)
    logic[31:0] _e_5349;
    (* src = "src/bootloader.spade:116,34" *)
    logic[120:0] _e_5337;
    (* src = "src/bootloader.spade:117,13" *)
    logic[5:0] _e_5361;
    (* src = "src/bootloader.spade:117,13" *)
    logic _e_5359;
    (* src = "src/bootloader.spade:117,13" *)
    logic[4:0] _e_5360;
    logic _e_9592;
    logic _e_9593;
    (* src = "src/bootloader.spade:117,40" *)
    logic[4:0] _e_5363;
    (* src = "src/bootloader.spade:117,51" *)
    logic[15:0] _e_5364;
    (* src = "src/bootloader.spade:117,59" *)
    logic[15:0] _e_5366;
    (* src = "src/bootloader.spade:117,69" *)
    logic[9:0] _e_5368;
    (* src = "src/bootloader.spade:117,79" *)
    logic[9:0] _e_5370;
    (* src = "src/bootloader.spade:117,87" *)
    logic[31:0] _e_5372;
    logic[31:0] _e_5377;
    (* src = "src/bootloader.spade:117,100" *)
    logic[31:0] _e_5376;
    (* src = "src/bootloader.spade:117,123" *)
    logic[31:0] _e_5381;
    (* src = "src/bootloader.spade:117,122" *)
    logic[31:0] _e_5380;
    (* src = "src/bootloader.spade:117,100" *)
    logic[31:0] _e_5375;
    (* src = "src/bootloader.spade:117,94" *)
    logic[31:0] _e_5374;
    (* src = "src/bootloader.spade:117,34" *)
    logic[120:0] _e_5362;
    (* src = "src/bootloader.spade:118,13" *)
    logic[5:0] _e_5386;
    (* src = "src/bootloader.spade:118,13" *)
    logic _e_5384;
    (* src = "src/bootloader.spade:118,13" *)
    logic[4:0] _e_5385;
    logic _e_9597;
    logic _e_9598;
    (* src = "src/bootloader.spade:118,40" *)
    logic[4:0] _e_5388;
    (* src = "src/bootloader.spade:118,52" *)
    logic[15:0] _e_5389;
    (* src = "src/bootloader.spade:118,60" *)
    logic[15:0] _e_5391;
    (* src = "src/bootloader.spade:118,70" *)
    logic[9:0] _e_5393;
    (* src = "src/bootloader.spade:118,80" *)
    logic[9:0] _e_5395;
    (* src = "src/bootloader.spade:118,88" *)
    logic[31:0] _e_5397;
    logic[31:0] _e_5402;
    (* src = "src/bootloader.spade:118,101" *)
    logic[31:0] _e_5401;
    (* src = "src/bootloader.spade:118,123" *)
    logic[31:0] _e_5406;
    (* src = "src/bootloader.spade:118,122" *)
    logic[31:0] _e_5405;
    (* src = "src/bootloader.spade:118,101" *)
    logic[31:0] _e_5400;
    (* src = "src/bootloader.spade:118,95" *)
    logic[31:0] _e_5399;
    (* src = "src/bootloader.spade:118,34" *)
    logic[120:0] _e_5387;
    (* src = "src/bootloader.spade:122,13" *)
    logic[5:0] _e_5411;
    (* src = "src/bootloader.spade:122,13" *)
    logic \_ ;
    (* src = "src/bootloader.spade:122,13" *)
    logic[4:0] _e_5410;
    logic _e_9602;
    logic _e_9603;
    (* src = "src/bootloader.spade:123,34" *)
    logic[9:0] _e_5415;
    (* src = "src/bootloader.spade:123,34" *)
    logic[10:0] _e_5414;
    (* src = "src/bootloader.spade:123,28" *)
    logic[9:0] \pcw1 ;
    (* src = "src/bootloader.spade:124,34" *)
    logic[15:0] _e_5421;
    (* src = "src/bootloader.spade:124,34" *)
    logic[16:0] _e_5420;
    (* src = "src/bootloader.spade:124,28" *)
    logic[15:0] \n1 ;
    (* src = "src/bootloader.spade:125,31" *)
    logic _e_5426;
    (* src = "src/bootloader.spade:126,21" *)
    logic[4:0] _e_5430;
    (* src = "src/bootloader.spade:128,21" *)
    logic[4:0] _e_5432;
    (* src = "src/bootloader.spade:125,28" *)
    logic[4:0] \next ;
    (* src = "src/bootloader.spade:130,29" *)
    logic[15:0] _e_5436;
    (* src = "src/bootloader.spade:130,41" *)
    logic[9:0] _e_5439;
    (* src = "src/bootloader.spade:130,57" *)
    logic[31:0] _e_5442;
    (* src = "src/bootloader.spade:130,64" *)
    logic[31:0] _e_5444;
    (* src = "src/bootloader.spade:130,17" *)
    logic[120:0] _e_5434;
    (* src = "src/bootloader.spade:134,13" *)
    logic[5:0] _e_5448;
    (* src = "src/bootloader.spade:134,13" *)
    logic __n1;
    (* src = "src/bootloader.spade:134,13" *)
    logic[4:0] _e_5447;
    logic _e_9607;
    logic _e_9608;
    (* src = "src/bootloader.spade:137,13" *)
    logic[5:0] _e_5452;
    (* src = "src/bootloader.spade:137,13" *)
    logic _e_5450;
    (* src = "src/bootloader.spade:137,13" *)
    logic[4:0] __n2;
    logic _e_9610;
    logic _e_9612;
    (* src = "src/bootloader.spade:72,9" *)
    logic[120:0] _e_4994;
    (* src = "src/bootloader.spade:71,14" *)
    reg[120:0] \st ;
    (* src = "src/bootloader.spade:141,47" *)
    logic[4:0] _e_5455;
    (* src = "src/bootloader.spade:142,9" *)
    logic[4:0] _e_5457;
    logic _e_9614;
    (* src = "src/bootloader.spade:142,29" *)
    logic[9:0] _e_5460;
    (* src = "src/bootloader.spade:142,24" *)
    logic[10:0] _e_5459;
    (* src = "src/bootloader.spade:142,43" *)
    logic[31:0] _e_5463;
    (* src = "src/bootloader.spade:142,38" *)
    logic[32:0] _e_5462;
    (* src = "src/bootloader.spade:142,56" *)
    logic[31:0] _e_5466;
    (* src = "src/bootloader.spade:142,51" *)
    logic[32:0] _e_5465;
    (* src = "src/bootloader.spade:142,23" *)
    logic[76:0] _e_5458;
    (* src = "src/bootloader.spade:143,9" *)
    logic[4:0] __n3;
    (* src = "src/bootloader.spade:143,15" *)
    logic[10:0] _e_5470;
    (* src = "src/bootloader.spade:143,21" *)
    logic[32:0] _e_5471;
    (* src = "src/bootloader.spade:143,27" *)
    logic[32:0] _e_5472;
    (* src = "src/bootloader.spade:143,14" *)
    logic[76:0] _e_5469;
    (* src = "src/bootloader.spade:141,41" *)
    logic[76:0] _e_5476;
    (* src = "src/bootloader.spade:141,9" *)
    logic[10:0] \wr_addr ;
    (* src = "src/bootloader.spade:141,9" *)
    logic[32:0] \wr_slot0 ;
    (* src = "src/bootloader.spade:141,9" *)
    logic[32:0] \wr_slot1 ;
    (* src = "src/bootloader.spade:146,43" *)
    logic[4:0] _e_5478;
    (* src = "src/bootloader.spade:147,9" *)
    logic[4:0] _e_5480;
    logic _e_9617;
    (* src = "src/bootloader.spade:147,34" *)
    logic[9:0] _e_5484;
    (* src = "src/bootloader.spade:147,29" *)
    logic[10:0] _e_5483;
    (* src = "src/bootloader.spade:147,21" *)
    logic[11:0] _e_5481;
    (* src = "src/bootloader.spade:148,9" *)
    logic[4:0] __n4;
    (* src = "src/bootloader.spade:148,21" *)
    logic[10:0] _e_5489;
    (* src = "src/bootloader.spade:148,14" *)
    logic[11:0] _e_5487;
    (* src = "src/bootloader.spade:146,37" *)
    logic[11:0] _e_5492;
    (* src = "src/bootloader.spade:146,9" *)
    logic \boot_active ;
    (* src = "src/bootloader.spade:146,9" *)
    logic[10:0] \release_pc ;
    (* src = "src/bootloader.spade:151,5" *)
    logic[88:0] _e_5493;
    (* src = "src/bootloader.spade:71,35" *)
    \tta::bootloader::reset_state  reset_state_0(.output__(_e_4992));
    assign _e_4997 = \st [120:116];
    assign _e_4995 = {\byte_valid , _e_4997};
    assign _e_5001 = _e_4995;
    assign _e_4999 = _e_4995[5];
    assign _e_5000 = _e_4995[4:0];
    assign _e_9522 = _e_5000[4:0] == 5'd0;
    assign _e_9523 = _e_4999 && _e_9522;
    localparam[7:0] _e_5005 = 66;
    assign _e_5003 = \byte  == _e_5005;
    assign _e_5008 = {5'd1};
    assign _e_5009 = \st [115:100];
    assign _e_5011 = \st [99:84];
    assign _e_5013 = \st [83:74];
    assign _e_5015 = \st [73:64];
    assign _e_5017 = \st [63:32];
    assign _e_5019 = \st [31:0];
    assign _e_5007 = {_e_5008, _e_5009, _e_5011, _e_5013, _e_5015, _e_5017, _e_5019};
    (* src = "src/bootloader.spade:76,21" *)
    \tta::bootloader::reset_state  reset_state_1(.output__(_e_5022));
    assign _e_5002 = _e_5003 ? _e_5007 : _e_5022;
    assign _e_5025 = _e_4995;
    assign _e_5023 = _e_4995[5];
    assign _e_5024 = _e_4995[4:0];
    assign _e_9527 = _e_5024[4:0] == 5'd1;
    assign _e_9528 = _e_5023 && _e_9527;
    localparam[7:0] _e_5029 = 84;
    assign _e_5027 = \byte  == _e_5029;
    assign _e_5032 = {5'd2};
    assign _e_5033 = \st [115:100];
    assign _e_5035 = \st [99:84];
    assign _e_5037 = \st [83:74];
    assign _e_5039 = \st [73:64];
    assign _e_5041 = \st [63:32];
    assign _e_5043 = \st [31:0];
    assign _e_5031 = {_e_5032, _e_5033, _e_5035, _e_5037, _e_5039, _e_5041, _e_5043};
    (* src = "src/bootloader.spade:81,21" *)
    \tta::bootloader::reset_state  reset_state_2(.output__(_e_5046));
    assign _e_5026 = _e_5027 ? _e_5031 : _e_5046;
    assign _e_5049 = _e_4995;
    assign _e_5047 = _e_4995[5];
    assign _e_5048 = _e_4995[4:0];
    assign _e_9532 = _e_5048[4:0] == 5'd2;
    assign _e_9533 = _e_5047 && _e_9532;
    assign _e_5051 = {5'd3};
    assign _e_5052 = {8'b0, \byte };
    assign _e_5054 = \st [99:84];
    assign _e_5056 = \st [83:74];
    assign _e_5058 = \st [73:64];
    assign _e_5060 = \st [63:32];
    assign _e_5062 = \st [31:0];
    assign _e_5050 = {_e_5051, _e_5052, _e_5054, _e_5056, _e_5058, _e_5060, _e_5062};
    assign _e_5066 = _e_4995;
    assign _e_5064 = _e_4995[5];
    assign _e_5065 = _e_4995[4:0];
    assign _e_9537 = _e_5065[4:0] == 5'd3;
    assign _e_9538 = _e_5064 && _e_9537;
    assign _e_5070 = {8'b0, \byte };
    localparam[15:0] _e_5072 = 8;
    assign _e_5069 = _e_5070 << _e_5072;
    assign _e_5073 = \st [115:100];
    assign \v  = _e_5069 | _e_5073;
    localparam[15:0] _e_5079 = 1;
    assign _e_5077 = \v  == _e_5079;
    assign _e_5082 = {5'd4};
    assign _e_5083 = \v [15:0];
    assign _e_5085 = \st [99:84];
    assign _e_5087 = \st [83:74];
    assign _e_5089 = \st [73:64];
    assign _e_5091 = \st [63:32];
    assign _e_5093 = \st [31:0];
    assign _e_5081 = {_e_5082, _e_5083, _e_5085, _e_5087, _e_5089, _e_5091, _e_5093};
    (* src = "src/bootloader.spade:89,25" *)
    \tta::bootloader::reset_state  reset_state_3(.output__(_e_5096));
    assign _e_5076 = _e_5077 ? _e_5081 : _e_5096;
    assign _e_5099 = _e_4995;
    assign _e_5097 = _e_4995[5];
    assign _e_5098 = _e_4995[4:0];
    assign _e_9542 = _e_5098[4:0] == 5'd4;
    assign _e_9543 = _e_5097 && _e_9542;
    assign _e_5101 = {5'd5};
    assign _e_5102 = \st [115:100];
    assign _e_5104 = {8'b0, \byte };
    assign _e_5106 = \st [83:74];
    assign _e_5108 = \st [73:64];
    assign _e_5110 = \st [63:32];
    assign _e_5112 = \st [31:0];
    assign _e_5100 = {_e_5101, _e_5102, _e_5104, _e_5106, _e_5108, _e_5110, _e_5112};
    assign _e_5116 = _e_4995;
    assign _e_5114 = _e_4995[5];
    assign _e_5115 = _e_4995[4:0];
    assign _e_9547 = _e_5115[4:0] == 5'd5;
    assign _e_9548 = _e_5114 && _e_9547;
    assign _e_5120 = {8'b0, \byte };
    localparam[15:0] _e_5122 = 8;
    assign _e_5119 = _e_5120 << _e_5122;
    assign _e_5123 = \st [99:84];
    assign \n  = _e_5119 | _e_5123;
    localparam[15:0] _e_5129 = 1024;
    assign _e_5127 = \n  > _e_5129;
    localparam[15:0] _e_5131 = 1024;
    assign \n_clamped  = _e_5127 ? _e_5131 : \n ;
    assign _e_5136 = {5'd6};
    assign _e_5137 = \st [115:100];
    assign _e_5139 = \n_clamped [15:0];
    assign _e_5141 = \st [83:74];
    assign _e_5143 = \st [73:64];
    assign _e_5145 = \st [63:32];
    assign _e_5147 = \st [31:0];
    assign _e_5135 = {_e_5136, _e_5137, _e_5139, _e_5141, _e_5143, _e_5145, _e_5147};
    assign _e_5151 = _e_4995;
    assign _e_5149 = _e_4995[5];
    assign _e_5150 = _e_4995[4:0];
    assign _e_9552 = _e_5150[4:0] == 5'd6;
    assign _e_9553 = _e_5149 && _e_9552;
    assign _e_5153 = {5'd7};
    assign _e_5154 = \st [115:100];
    assign _e_5156 = \st [99:84];
    assign _e_5158 = {2'b0, \byte };
    assign _e_5160 = \st [73:64];
    assign _e_5162 = \st [63:32];
    assign _e_5164 = \st [31:0];
    assign _e_5152 = {_e_5153, _e_5154, _e_5156, _e_5158, _e_5160, _e_5162, _e_5164};
    assign _e_5168 = _e_4995;
    assign _e_5166 = _e_4995[5];
    assign _e_5167 = _e_4995[4:0];
    assign _e_9557 = _e_5167[4:0] == 5'd7;
    assign _e_9558 = _e_5166 && _e_9557;
    assign _e_5172 = {2'b0, \byte };
    localparam[9:0] _e_5174 = 8;
    assign _e_5171 = _e_5172 << _e_5174;
    assign _e_5175 = \st [83:74];
    assign \e  = _e_5171 | _e_5175;
    assign _e_5180 = \st [99:84];
    localparam[15:0] _e_5182 = 0;
    assign _e_5179 = _e_5180 == _e_5182;
    assign _e_5185 = {5'd17};
    assign _e_5186 = \st [115:100];
    assign _e_5188 = \st [99:84];
    assign _e_5190 = \e [9:0];
    assign _e_5192 = \st [73:64];
    assign _e_5194 = \st [63:32];
    assign _e_5196 = \st [31:0];
    assign _e_5184 = {_e_5185, _e_5186, _e_5188, _e_5190, _e_5192, _e_5194, _e_5196};
    assign _e_5200 = {5'd8};
    assign _e_5201 = \st [115:100];
    assign _e_5203 = \st [99:84];
    assign _e_5205 = \e [9:0];
    assign _e_5207 = \st [73:64];
    assign _e_5209 = \st [63:32];
    assign _e_5211 = \st [31:0];
    assign _e_5199 = {_e_5200, _e_5201, _e_5203, _e_5205, _e_5207, _e_5209, _e_5211};
    assign _e_5178 = _e_5179 ? _e_5184 : _e_5199;
    assign _e_5215 = _e_4995;
    assign _e_5213 = _e_4995[5];
    assign _e_5214 = _e_4995[4:0];
    assign _e_9562 = _e_5214[4:0] == 5'd8;
    assign _e_9563 = _e_5213 && _e_9562;
    assign _e_5217 = {5'd9};
    assign _e_5218 = \st [115:100];
    assign _e_5220 = \st [99:84];
    assign _e_5222 = \st [83:74];
    assign _e_5224 = \st [73:64];
    assign _e_5228 = {24'b0, \byte };
    assign _e_5231 = \st [63:32];
    localparam[31:0] _e_5233 = 32'd4294967040;
    assign _e_5230 = _e_5231 & _e_5233;
    assign _e_5227 = _e_5228 | _e_5230;
    assign _e_5226 = _e_5227[31:0];
    assign _e_5234 = \st [31:0];
    assign _e_5216 = {_e_5217, _e_5218, _e_5220, _e_5222, _e_5224, _e_5226, _e_5234};
    assign _e_5238 = _e_4995;
    assign _e_5236 = _e_4995[5];
    assign _e_5237 = _e_4995[4:0];
    assign _e_9567 = _e_5237[4:0] == 5'd9;
    assign _e_9568 = _e_5236 && _e_9567;
    assign _e_5240 = {5'd10};
    assign _e_5241 = \st [115:100];
    assign _e_5243 = \st [99:84];
    assign _e_5245 = \st [83:74];
    assign _e_5247 = \st [73:64];
    assign _e_5252 = {24'b0, \byte };
    localparam[31:0] _e_5254 = 32'd8;
    assign _e_5251 = _e_5252 << _e_5254;
    assign _e_5256 = \st [63:32];
    localparam[31:0] _e_5258 = 32'd4294902015;
    assign _e_5255 = _e_5256 & _e_5258;
    assign _e_5250 = _e_5251 | _e_5255;
    assign _e_5249 = _e_5250[31:0];
    assign _e_5259 = \st [31:0];
    assign _e_5239 = {_e_5240, _e_5241, _e_5243, _e_5245, _e_5247, _e_5249, _e_5259};
    assign _e_5263 = _e_4995;
    assign _e_5261 = _e_4995[5];
    assign _e_5262 = _e_4995[4:0];
    assign _e_9572 = _e_5262[4:0] == 5'd10;
    assign _e_9573 = _e_5261 && _e_9572;
    assign _e_5265 = {5'd11};
    assign _e_5266 = \st [115:100];
    assign _e_5268 = \st [99:84];
    assign _e_5270 = \st [83:74];
    assign _e_5272 = \st [73:64];
    assign _e_5277 = {24'b0, \byte };
    localparam[31:0] _e_5279 = 32'd16;
    assign _e_5276 = _e_5277 << _e_5279;
    assign _e_5281 = \st [63:32];
    localparam[31:0] _e_5283 = 32'd4278255615;
    assign _e_5280 = _e_5281 & _e_5283;
    assign _e_5275 = _e_5276 | _e_5280;
    assign _e_5274 = _e_5275[31:0];
    assign _e_5284 = \st [31:0];
    assign _e_5264 = {_e_5265, _e_5266, _e_5268, _e_5270, _e_5272, _e_5274, _e_5284};
    assign _e_5288 = _e_4995;
    assign _e_5286 = _e_4995[5];
    assign _e_5287 = _e_4995[4:0];
    assign _e_9577 = _e_5287[4:0] == 5'd11;
    assign _e_9578 = _e_5286 && _e_9577;
    assign _e_5290 = {5'd12};
    assign _e_5291 = \st [115:100];
    assign _e_5293 = \st [99:84];
    assign _e_5295 = \st [83:74];
    assign _e_5297 = \st [73:64];
    assign _e_5302 = {24'b0, \byte };
    localparam[31:0] _e_5304 = 32'd24;
    assign _e_5301 = _e_5302 << _e_5304;
    assign _e_5306 = \st [63:32];
    localparam[31:0] _e_5308 = 32'd16777215;
    assign _e_5305 = _e_5306 & _e_5308;
    assign _e_5300 = _e_5301 | _e_5305;
    assign _e_5299 = _e_5300[31:0];
    assign _e_5309 = \st [31:0];
    assign _e_5289 = {_e_5290, _e_5291, _e_5293, _e_5295, _e_5297, _e_5299, _e_5309};
    assign _e_5313 = _e_4995;
    assign _e_5311 = _e_4995[5];
    assign _e_5312 = _e_4995[4:0];
    assign _e_9582 = _e_5312[4:0] == 5'd12;
    assign _e_9583 = _e_5311 && _e_9582;
    assign _e_5315 = {5'd13};
    assign _e_5316 = \st [115:100];
    assign _e_5318 = \st [99:84];
    assign _e_5320 = \st [83:74];
    assign _e_5322 = \st [73:64];
    assign _e_5324 = \st [63:32];
    assign _e_5328 = {24'b0, \byte };
    assign _e_5331 = \st [31:0];
    localparam[31:0] _e_5333 = 32'd4294967040;
    assign _e_5330 = _e_5331 & _e_5333;
    assign _e_5327 = _e_5328 | _e_5330;
    assign _e_5326 = _e_5327[31:0];
    assign _e_5314 = {_e_5315, _e_5316, _e_5318, _e_5320, _e_5322, _e_5324, _e_5326};
    assign _e_5336 = _e_4995;
    assign _e_5334 = _e_4995[5];
    assign _e_5335 = _e_4995[4:0];
    assign _e_9587 = _e_5335[4:0] == 5'd13;
    assign _e_9588 = _e_5334 && _e_9587;
    assign _e_5338 = {5'd14};
    assign _e_5339 = \st [115:100];
    assign _e_5341 = \st [99:84];
    assign _e_5343 = \st [83:74];
    assign _e_5345 = \st [73:64];
    assign _e_5347 = \st [63:32];
    assign _e_5352 = {24'b0, \byte };
    localparam[31:0] _e_5354 = 32'd8;
    assign _e_5351 = _e_5352 << _e_5354;
    assign _e_5356 = \st [31:0];
    localparam[31:0] _e_5358 = 32'd4294902015;
    assign _e_5355 = _e_5356 & _e_5358;
    assign _e_5350 = _e_5351 | _e_5355;
    assign _e_5349 = _e_5350[31:0];
    assign _e_5337 = {_e_5338, _e_5339, _e_5341, _e_5343, _e_5345, _e_5347, _e_5349};
    assign _e_5361 = _e_4995;
    assign _e_5359 = _e_4995[5];
    assign _e_5360 = _e_4995[4:0];
    assign _e_9592 = _e_5360[4:0] == 5'd14;
    assign _e_9593 = _e_5359 && _e_9592;
    assign _e_5363 = {5'd15};
    assign _e_5364 = \st [115:100];
    assign _e_5366 = \st [99:84];
    assign _e_5368 = \st [83:74];
    assign _e_5370 = \st [73:64];
    assign _e_5372 = \st [63:32];
    assign _e_5377 = {24'b0, \byte };
    localparam[31:0] _e_5379 = 32'd16;
    assign _e_5376 = _e_5377 << _e_5379;
    assign _e_5381 = \st [31:0];
    localparam[31:0] _e_5383 = 32'd4278255615;
    assign _e_5380 = _e_5381 & _e_5383;
    assign _e_5375 = _e_5376 | _e_5380;
    assign _e_5374 = _e_5375[31:0];
    assign _e_5362 = {_e_5363, _e_5364, _e_5366, _e_5368, _e_5370, _e_5372, _e_5374};
    assign _e_5386 = _e_4995;
    assign _e_5384 = _e_4995[5];
    assign _e_5385 = _e_4995[4:0];
    assign _e_9597 = _e_5385[4:0] == 5'd15;
    assign _e_9598 = _e_5384 && _e_9597;
    assign _e_5388 = {5'd16};
    assign _e_5389 = \st [115:100];
    assign _e_5391 = \st [99:84];
    assign _e_5393 = \st [83:74];
    assign _e_5395 = \st [73:64];
    assign _e_5397 = \st [63:32];
    assign _e_5402 = {24'b0, \byte };
    localparam[31:0] _e_5404 = 32'd24;
    assign _e_5401 = _e_5402 << _e_5404;
    assign _e_5406 = \st [31:0];
    localparam[31:0] _e_5408 = 32'd16777215;
    assign _e_5405 = _e_5406 & _e_5408;
    assign _e_5400 = _e_5401 | _e_5405;
    assign _e_5399 = _e_5400[31:0];
    assign _e_5387 = {_e_5388, _e_5389, _e_5391, _e_5393, _e_5395, _e_5397, _e_5399};
    assign _e_5411 = _e_4995;
    assign \_  = _e_4995[5];
    assign _e_5410 = _e_4995[4:0];
    localparam[0:0] _e_9600 = 1;
    assign _e_9602 = _e_5410[4:0] == 5'd16;
    assign _e_9603 = _e_9600 && _e_9602;
    assign _e_5415 = \st [73:64];
    localparam[9:0] _e_5417 = 1;
    assign _e_5414 = _e_5415 + _e_5417;
    assign \pcw1  = _e_5414[9:0];
    assign _e_5421 = \st [99:84];
    localparam[15:0] _e_5423 = 1;
    assign _e_5420 = _e_5421 - _e_5423;
    assign \n1  = _e_5420[15:0];
    localparam[15:0] _e_5428 = 0;
    assign _e_5426 = \n1  == _e_5428;
    assign _e_5430 = {5'd17};
    assign _e_5432 = {5'd8};
    assign \next  = _e_5426 ? _e_5430 : _e_5432;
    assign _e_5436 = \st [115:100];
    assign _e_5439 = \st [83:74];
    assign _e_5442 = \st [63:32];
    assign _e_5444 = \st [31:0];
    assign _e_5434 = {\next , _e_5436, \n1 , _e_5439, \pcw1 , _e_5442, _e_5444};
    assign _e_5448 = _e_4995;
    assign __n1 = _e_4995[5];
    assign _e_5447 = _e_4995[4:0];
    localparam[0:0] _e_9605 = 1;
    assign _e_9607 = _e_5447[4:0] == 5'd17;
    assign _e_9608 = _e_9605 && _e_9607;
    assign _e_5452 = _e_4995;
    assign _e_5450 = _e_4995[5];
    assign __n2 = _e_4995[4:0];
    assign _e_9610 = !_e_5450;
    localparam[0:0] _e_9611 = 1;
    assign _e_9612 = _e_9610 && _e_9611;
    always_comb begin
        priority casez ({_e_9523, _e_9528, _e_9533, _e_9538, _e_9543, _e_9548, _e_9553, _e_9558, _e_9563, _e_9568, _e_9573, _e_9578, _e_9583, _e_9588, _e_9593, _e_9598, _e_9603, _e_9608, _e_9612})
            19'b1??????????????????: _e_4994 = _e_5002;
            19'b01?????????????????: _e_4994 = _e_5026;
            19'b001????????????????: _e_4994 = _e_5050;
            19'b0001???????????????: _e_4994 = _e_5076;
            19'b00001??????????????: _e_4994 = _e_5100;
            19'b000001?????????????: _e_4994 = _e_5135;
            19'b0000001????????????: _e_4994 = _e_5152;
            19'b00000001???????????: _e_4994 = _e_5178;
            19'b000000001??????????: _e_4994 = _e_5216;
            19'b0000000001?????????: _e_4994 = _e_5239;
            19'b00000000001????????: _e_4994 = _e_5264;
            19'b000000000001???????: _e_4994 = _e_5289;
            19'b0000000000001??????: _e_4994 = _e_5314;
            19'b00000000000001?????: _e_4994 = _e_5337;
            19'b000000000000001????: _e_4994 = _e_5362;
            19'b0000000000000001???: _e_4994 = _e_5387;
            19'b00000000000000001??: _e_4994 = _e_5434;
            19'b000000000000000001?: _e_4994 = \st ;
            19'b0000000000000000001: _e_4994 = \st ;
            19'b?: _e_4994 = 121'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \st  <= _e_4992;
        end
        else begin
            \st  <= _e_4994;
        end
    end
    assign _e_5455 = \st [120:116];
    assign _e_5457 = _e_5455;
    assign _e_9614 = _e_5455[4:0] == 5'd16;
    assign _e_5460 = \st [73:64];
    assign _e_5459 = {1'd1, _e_5460};
    assign _e_5463 = \st [63:32];
    assign _e_5462 = {1'd1, _e_5463};
    assign _e_5466 = \st [31:0];
    assign _e_5465 = {1'd1, _e_5466};
    assign _e_5458 = {_e_5459, _e_5462, _e_5465};
    assign __n3 = _e_5455;
    localparam[0:0] _e_9615 = 1;
    assign _e_5470 = {1'd0, 10'bX};
    assign _e_5471 = {1'd0, 32'bX};
    assign _e_5472 = {1'd0, 32'bX};
    assign _e_5469 = {_e_5470, _e_5471, _e_5472};
    always_comb begin
        priority casez ({_e_9614, _e_9615})
            2'b1?: _e_5476 = _e_5458;
            2'b01: _e_5476 = _e_5469;
            2'b?: _e_5476 = 77'dx;
        endcase
    end
    assign \wr_addr  = _e_5476[76:66];
    assign \wr_slot0  = _e_5476[65:33];
    assign \wr_slot1  = _e_5476[32:0];
    assign _e_5478 = \st [120:116];
    assign _e_5480 = _e_5478;
    assign _e_9617 = _e_5478[4:0] == 5'd17;
    localparam[0:0] _e_5482 = 0;
    assign _e_5484 = \st [83:74];
    assign _e_5483 = {1'd1, _e_5484};
    assign _e_5481 = {_e_5482, _e_5483};
    assign __n4 = _e_5478;
    localparam[0:0] _e_9618 = 1;
    localparam[0:0] _e_5488 = 1;
    assign _e_5489 = {1'd0, 10'bX};
    assign _e_5487 = {_e_5488, _e_5489};
    always_comb begin
        priority casez ({_e_9617, _e_9618})
            2'b1?: _e_5492 = _e_5481;
            2'b01: _e_5492 = _e_5487;
            2'b?: _e_5492 = 12'dx;
        endcase
    end
    assign \boot_active  = _e_5492[11];
    assign \release_pc  = _e_5492[10:0];
    assign _e_5493 = {\boot_active , \wr_addr , \wr_slot0 , \wr_slot1 , \release_pc };
    assign output__ = _e_5493;
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
    logic _e_9620;
    logic _e_9622;
    logic _e_9624;
    (* src = "src/bit.spade:19,45" *)
    logic[31:0] _e_5504;
    (* src = "src/bit.spade:19,14" *)
    reg[31:0] \op_a ;
    (* src = "src/bit.spade:26,9" *)
    logic[34:0] _e_5515;
    (* src = "src/bit.spade:26,14" *)
    logic[2:0] _e_5513;
    (* src = "src/bit.spade:26,14" *)
    logic[31:0] \_ ;
    logic _e_9626;
    logic _e_9629;
    logic _e_9631;
    logic _e_9632;
    (* src = "src/bit.spade:26,42" *)
    logic[31:0] _e_5518;
    (* src = "src/bit.spade:26,37" *)
    logic[32:0] _e_5517;
    (* src = "src/bit.spade:27,9" *)
    logic[34:0] _e_5522;
    (* src = "src/bit.spade:27,14" *)
    logic[2:0] _e_5520;
    (* src = "src/bit.spade:27,14" *)
    logic[31:0] __n1;
    logic _e_9634;
    logic _e_9637;
    logic _e_9639;
    logic _e_9640;
    (* src = "src/bit.spade:27,42" *)
    logic[31:0] _e_5525;
    (* src = "src/bit.spade:27,37" *)
    logic[32:0] _e_5524;
    (* src = "src/bit.spade:28,9" *)
    logic[34:0] _e_5529;
    (* src = "src/bit.spade:28,14" *)
    logic[2:0] _e_5527;
    (* src = "src/bit.spade:28,14" *)
    logic[31:0] __n2;
    logic _e_9642;
    logic _e_9645;
    logic _e_9647;
    logic _e_9648;
    (* src = "src/bit.spade:28,42" *)
    logic[31:0] _e_5532;
    (* src = "src/bit.spade:28,37" *)
    logic[32:0] _e_5531;
    (* src = "src/bit.spade:29,9" *)
    logic[34:0] _e_5536;
    (* src = "src/bit.spade:29,14" *)
    logic[2:0] _e_5534;
    (* src = "src/bit.spade:29,14" *)
    logic[31:0] __n3;
    logic _e_9650;
    logic _e_9653;
    logic _e_9655;
    logic _e_9656;
    (* src = "src/bit.spade:29,42" *)
    logic[31:0] _e_5539;
    (* src = "src/bit.spade:29,37" *)
    logic[32:0] _e_5538;
    (* src = "src/bit.spade:31,9" *)
    logic[34:0] _e_5543;
    (* src = "src/bit.spade:31,14" *)
    logic[2:0] _e_5541;
    (* src = "src/bit.spade:31,14" *)
    logic[31:0] \b ;
    logic _e_9658;
    logic _e_9661;
    logic _e_9663;
    logic _e_9664;
    (* src = "src/bit.spade:31,55" *)
    logic[31:0] _e_5550;
    (* src = "src/bit.spade:31,49" *)
    logic[31:0] _e_5548;
    (* src = "src/bit.spade:31,42" *)
    logic[31:0] _e_5546;
    (* src = "src/bit.spade:31,37" *)
    logic[32:0] _e_5545;
    (* src = "src/bit.spade:32,9" *)
    logic[34:0] _e_5555;
    (* src = "src/bit.spade:32,14" *)
    logic[2:0] _e_5553;
    (* src = "src/bit.spade:32,14" *)
    logic[31:0] b_n1;
    logic _e_9666;
    logic _e_9669;
    logic _e_9671;
    logic _e_9672;
    (* src = "src/bit.spade:32,56" *)
    logic[31:0] _e_5563;
    (* src = "src/bit.spade:32,50" *)
    logic[31:0] _e_5561;
    (* src = "src/bit.spade:32,49" *)
    logic[31:0] _e_5560;
    (* src = "src/bit.spade:32,42" *)
    logic[31:0] _e_5558;
    (* src = "src/bit.spade:32,37" *)
    logic[32:0] _e_5557;
    (* src = "src/bit.spade:36,9" *)
    logic[34:0] _e_5568;
    (* src = "src/bit.spade:36,14" *)
    logic[2:0] _e_5566;
    (* src = "src/bit.spade:36,14" *)
    logic[31:0] b_n2;
    logic _e_9674;
    logic _e_9677;
    logic _e_9679;
    logic _e_9680;
    (* src = "src/bit.spade:36,40" *)
    logic[31:0] _e_5571;
    (* src = "src/bit.spade:36,35" *)
    logic[32:0] _e_5570;
    (* src = "src/bit.spade:37,9" *)
    logic[34:0] _e_5576;
    (* src = "src/bit.spade:37,14" *)
    logic[2:0] _e_5574;
    (* src = "src/bit.spade:37,14" *)
    logic[31:0] b_n3;
    logic _e_9682;
    logic _e_9685;
    logic _e_9687;
    logic _e_9688;
    (* src = "src/bit.spade:37,40" *)
    logic[31:0] _e_5579;
    (* src = "src/bit.spade:37,35" *)
    logic[32:0] _e_5578;
    logic _e_9690;
    (* src = "src/bit.spade:39,17" *)
    logic[32:0] _e_5583;
    (* src = "src/bit.spade:25,36" *)
    logic[32:0] \result ;
    (* src = "src/bit.spade:43,51" *)
    logic[32:0] _e_5588;
    (* src = "src/bit.spade:43,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_5503 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_9620 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9621 = 1;
    assign _e_9622 = _e_9620 && _e_9621;
    assign _e_9624 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9622, _e_9624})
            2'b1?: _e_5504 = \v ;
            2'b01: _e_5504 = \op_a ;
            2'b?: _e_5504 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_5503;
        end
        else begin
            \op_a  <= _e_5504;
        end
    end
    assign _e_5515 = \trig [34:0];
    assign _e_5513 = _e_5515[34:32];
    assign \_  = _e_5515[31:0];
    assign _e_9626 = \trig [35] == 1'd1;
    assign _e_9629 = _e_5513[2:0] == 3'd0;
    localparam[0:0] _e_9630 = 1;
    assign _e_9631 = _e_9629 && _e_9630;
    assign _e_9632 = _e_9626 && _e_9631;
    (* src = "src/bit.spade:26,42" *)
    \tta::bit::clz32  clz32_0(.val_i(\op_a ), .output__(_e_5518));
    assign _e_5517 = {1'd1, _e_5518};
    assign _e_5522 = \trig [34:0];
    assign _e_5520 = _e_5522[34:32];
    assign __n1 = _e_5522[31:0];
    assign _e_9634 = \trig [35] == 1'd1;
    assign _e_9637 = _e_5520[2:0] == 3'd1;
    localparam[0:0] _e_9638 = 1;
    assign _e_9639 = _e_9637 && _e_9638;
    assign _e_9640 = _e_9634 && _e_9639;
    (* src = "src/bit.spade:27,42" *)
    \tta::bit::ctz32  ctz32_0(.val_i(\op_a ), .output__(_e_5525));
    assign _e_5524 = {1'd1, _e_5525};
    assign _e_5529 = \trig [34:0];
    assign _e_5527 = _e_5529[34:32];
    assign __n2 = _e_5529[31:0];
    assign _e_9642 = \trig [35] == 1'd1;
    assign _e_9645 = _e_5527[2:0] == 3'd2;
    localparam[0:0] _e_9646 = 1;
    assign _e_9647 = _e_9645 && _e_9646;
    assign _e_9648 = _e_9642 && _e_9647;
    (* src = "src/bit.spade:28,42" *)
    \tta::bit::popcnt32  popcnt32_0(.val_i(\op_a ), .output__(_e_5532));
    assign _e_5531 = {1'd1, _e_5532};
    assign _e_5536 = \trig [34:0];
    assign _e_5534 = _e_5536[34:32];
    assign __n3 = _e_5536[31:0];
    assign _e_9650 = \trig [35] == 1'd1;
    assign _e_9653 = _e_5534[2:0] == 3'd7;
    localparam[0:0] _e_9654 = 1;
    assign _e_9655 = _e_9653 && _e_9654;
    assign _e_9656 = _e_9650 && _e_9655;
    (* src = "src/bit.spade:29,42" *)
    \tta::bit::brev32  brev32_0(.val_i(\op_a ), .output__(_e_5539));
    assign _e_5538 = {1'd1, _e_5539};
    assign _e_5543 = \trig [34:0];
    assign _e_5541 = _e_5543[34:32];
    assign \b  = _e_5543[31:0];
    assign _e_9658 = \trig [35] == 1'd1;
    assign _e_9661 = _e_5541[2:0] == 3'd3;
    localparam[0:0] _e_9662 = 1;
    assign _e_9663 = _e_9661 && _e_9662;
    assign _e_9664 = _e_9658 && _e_9663;
    localparam[31:0] _e_5549 = 32'd1;
    localparam[31:0] _e_5552 = 32'd31;
    assign _e_5550 = \b  & _e_5552;
    assign _e_5548 = _e_5549 << _e_5550;
    assign _e_5546 = \op_a  | _e_5548;
    assign _e_5545 = {1'd1, _e_5546};
    assign _e_5555 = \trig [34:0];
    assign _e_5553 = _e_5555[34:32];
    assign b_n1 = _e_5555[31:0];
    assign _e_9666 = \trig [35] == 1'd1;
    assign _e_9669 = _e_5553[2:0] == 3'd4;
    localparam[0:0] _e_9670 = 1;
    assign _e_9671 = _e_9669 && _e_9670;
    assign _e_9672 = _e_9666 && _e_9671;
    localparam[31:0] _e_5562 = 32'd1;
    localparam[31:0] _e_5565 = 32'd31;
    assign _e_5563 = b_n1 & _e_5565;
    assign _e_5561 = _e_5562 << _e_5563;
    assign _e_5560 = ~_e_5561;
    assign _e_5558 = \op_a  & _e_5560;
    assign _e_5557 = {1'd1, _e_5558};
    assign _e_5568 = \trig [34:0];
    assign _e_5566 = _e_5568[34:32];
    assign b_n2 = _e_5568[31:0];
    assign _e_9674 = \trig [35] == 1'd1;
    assign _e_9677 = _e_5566[2:0] == 3'd5;
    localparam[0:0] _e_9678 = 1;
    assign _e_9679 = _e_9677 && _e_9678;
    assign _e_9680 = _e_9674 && _e_9679;
    (* src = "src/bit.spade:36,40" *)
    \tta::bit::bext32  bext32_0(.val_i(\op_a ), .ctrl_i(b_n2), .output__(_e_5571));
    assign _e_5570 = {1'd1, _e_5571};
    assign _e_5576 = \trig [34:0];
    assign _e_5574 = _e_5576[34:32];
    assign b_n3 = _e_5576[31:0];
    assign _e_9682 = \trig [35] == 1'd1;
    assign _e_9685 = _e_5574[2:0] == 3'd6;
    localparam[0:0] _e_9686 = 1;
    assign _e_9687 = _e_9685 && _e_9686;
    assign _e_9688 = _e_9682 && _e_9687;
    (* src = "src/bit.spade:37,40" *)
    \tta::bit::bins32  bins32_0(.val_i(\op_a ), .ctrl_i(b_n3), .output__(_e_5579));
    assign _e_5578 = {1'd1, _e_5579};
    assign _e_9690 = \trig [35] == 1'd0;
    assign _e_5583 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9632, _e_9640, _e_9648, _e_9656, _e_9664, _e_9672, _e_9680, _e_9688, _e_9690})
            9'b1????????: \result  = _e_5517;
            9'b01???????: \result  = _e_5524;
            9'b001??????: \result  = _e_5531;
            9'b0001?????: \result  = _e_5538;
            9'b00001????: \result  = _e_5545;
            9'b000001???: \result  = _e_5557;
            9'b0000001??: \result  = _e_5570;
            9'b00000001?: \result  = _e_5578;
            9'b000000001: \result  = _e_5583;
            9'b?: \result  = 33'dx;
        endcase
    end
    assign _e_5588 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_5588;
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
    logic _e_5593;
    (* src = "src/bit.spade:58,27" *)
    logic[31:0] _e_5601;
    (* src = "src/bit.spade:58,27" *)
    logic _e_5600;
    (* src = "src/bit.spade:58,58" *)
    logic[31:0] _e_5608;
    (* src = "src/bit.spade:58,53" *)
    logic[63:0] _e_5606;
    (* src = "src/bit.spade:58,78" *)
    logic[63:0] _e_5612;
    (* src = "src/bit.spade:58,24" *)
    logic[63:0] _e_5617;
    (* src = "src/bit.spade:58,13" *)
    logic[31:0] \n1 ;
    (* src = "src/bit.spade:58,13" *)
    logic[31:0] \x1 ;
    (* src = "src/bit.spade:59,27" *)
    logic[31:0] _e_5620;
    (* src = "src/bit.spade:59,27" *)
    logic _e_5619;
    (* src = "src/bit.spade:59,59" *)
    logic[32:0] _e_5627;
    (* src = "src/bit.spade:59,53" *)
    logic[31:0] _e_5626;
    (* src = "src/bit.spade:59,66" *)
    logic[31:0] _e_5630;
    (* src = "src/bit.spade:59,52" *)
    logic[63:0] _e_5625;
    (* src = "src/bit.spade:59,84" *)
    logic[63:0] _e_5634;
    (* src = "src/bit.spade:59,24" *)
    logic[63:0] _e_5639;
    (* src = "src/bit.spade:59,13" *)
    logic[31:0] \n2 ;
    (* src = "src/bit.spade:59,13" *)
    logic[31:0] \x2 ;
    (* src = "src/bit.spade:60,27" *)
    logic[31:0] _e_5642;
    (* src = "src/bit.spade:60,27" *)
    logic _e_5641;
    (* src = "src/bit.spade:60,59" *)
    logic[32:0] _e_5649;
    (* src = "src/bit.spade:60,53" *)
    logic[31:0] _e_5648;
    (* src = "src/bit.spade:60,66" *)
    logic[31:0] _e_5652;
    (* src = "src/bit.spade:60,52" *)
    logic[63:0] _e_5647;
    (* src = "src/bit.spade:60,84" *)
    logic[63:0] _e_5656;
    (* src = "src/bit.spade:60,24" *)
    logic[63:0] _e_5661;
    (* src = "src/bit.spade:60,13" *)
    logic[31:0] \n3 ;
    (* src = "src/bit.spade:60,13" *)
    logic[31:0] \x3 ;
    (* src = "src/bit.spade:61,27" *)
    logic[31:0] _e_5664;
    (* src = "src/bit.spade:61,27" *)
    logic _e_5663;
    (* src = "src/bit.spade:61,59" *)
    logic[32:0] _e_5671;
    (* src = "src/bit.spade:61,53" *)
    logic[31:0] _e_5670;
    (* src = "src/bit.spade:61,66" *)
    logic[31:0] _e_5674;
    (* src = "src/bit.spade:61,52" *)
    logic[63:0] _e_5669;
    (* src = "src/bit.spade:61,84" *)
    logic[63:0] _e_5678;
    (* src = "src/bit.spade:61,24" *)
    logic[63:0] _e_5683;
    (* src = "src/bit.spade:61,13" *)
    logic[31:0] \n4 ;
    (* src = "src/bit.spade:61,13" *)
    logic[31:0] \x4 ;
    (* src = "src/bit.spade:62,21" *)
    logic[31:0] _e_5686;
    (* src = "src/bit.spade:62,21" *)
    logic _e_5685;
    (* src = "src/bit.spade:62,52" *)
    logic[32:0] _e_5692;
    (* src = "src/bit.spade:62,46" *)
    logic[31:0] _e_5691;
    (* src = "src/bit.spade:62,18" *)
    logic[31:0] \n5 ;
    (* src = "src/bit.spade:54,5" *)
    logic[31:0] _e_5592;
    localparam[31:0] _e_5595 = 32'd0;
    assign _e_5593 = \val  == _e_5595;
    localparam[31:0] _e_5597 = 32'd32;
    localparam[31:0] _e_5603 = 32'd4294901760;
    assign _e_5601 = \val  & _e_5603;
    localparam[31:0] _e_5604 = 32'd0;
    assign _e_5600 = _e_5601 == _e_5604;
    localparam[31:0] _e_5607 = 32'd16;
    localparam[31:0] _e_5610 = 32'd16;
    assign _e_5608 = \val  << _e_5610;
    assign _e_5606 = {_e_5607, _e_5608};
    localparam[31:0] _e_5613 = 32'd0;
    assign _e_5612 = {_e_5613, \val };
    assign _e_5617 = _e_5600 ? _e_5606 : _e_5612;
    assign \n1  = _e_5617[63:32];
    assign \x1  = _e_5617[31:0];
    localparam[31:0] _e_5622 = 32'd4278190080;
    assign _e_5620 = \x1  & _e_5622;
    localparam[31:0] _e_5623 = 32'd0;
    assign _e_5619 = _e_5620 == _e_5623;
    localparam[31:0] _e_5629 = 32'd8;
    assign _e_5627 = \n1  + _e_5629;
    assign _e_5626 = _e_5627[31:0];
    localparam[31:0] _e_5632 = 32'd8;
    assign _e_5630 = \x1  << _e_5632;
    assign _e_5625 = {_e_5626, _e_5630};
    assign _e_5634 = {\n1 , \x1 };
    assign _e_5639 = _e_5619 ? _e_5625 : _e_5634;
    assign \n2  = _e_5639[63:32];
    assign \x2  = _e_5639[31:0];
    localparam[31:0] _e_5644 = 32'd4026531840;
    assign _e_5642 = \x2  & _e_5644;
    localparam[31:0] _e_5645 = 32'd0;
    assign _e_5641 = _e_5642 == _e_5645;
    localparam[31:0] _e_5651 = 32'd4;
    assign _e_5649 = \n2  + _e_5651;
    assign _e_5648 = _e_5649[31:0];
    localparam[31:0] _e_5654 = 32'd4;
    assign _e_5652 = \x2  << _e_5654;
    assign _e_5647 = {_e_5648, _e_5652};
    assign _e_5656 = {\n2 , \x2 };
    assign _e_5661 = _e_5641 ? _e_5647 : _e_5656;
    assign \n3  = _e_5661[63:32];
    assign \x3  = _e_5661[31:0];
    localparam[31:0] _e_5666 = 32'd3221225472;
    assign _e_5664 = \x3  & _e_5666;
    localparam[31:0] _e_5667 = 32'd0;
    assign _e_5663 = _e_5664 == _e_5667;
    localparam[31:0] _e_5673 = 32'd2;
    assign _e_5671 = \n3  + _e_5673;
    assign _e_5670 = _e_5671[31:0];
    localparam[31:0] _e_5676 = 32'd2;
    assign _e_5674 = \x3  << _e_5676;
    assign _e_5669 = {_e_5670, _e_5674};
    assign _e_5678 = {\n3 , \x3 };
    assign _e_5683 = _e_5663 ? _e_5669 : _e_5678;
    assign \n4  = _e_5683[63:32];
    assign \x4  = _e_5683[31:0];
    localparam[31:0] _e_5688 = 32'd2147483648;
    assign _e_5686 = \x4  & _e_5688;
    localparam[31:0] _e_5689 = 32'd0;
    assign _e_5685 = _e_5686 == _e_5689;
    localparam[31:0] _e_5694 = 32'd1;
    assign _e_5692 = \n4  + _e_5694;
    assign _e_5691 = _e_5692[31:0];
    assign \n5  = _e_5685 ? _e_5691 : \n4 ;
    assign _e_5592 = _e_5593 ? _e_5597 : \n5 ;
    assign output__ = _e_5592;
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
    logic[31:0] _e_5701;
    (* src = "src/bit.spade:69,5" *)
    logic[31:0] _e_5700;
    (* src = "src/bit.spade:69,11" *)
    \tta::bit::brev32  brev32_0(.val_i(\val ), .output__(_e_5701));
    (* src = "src/bit.spade:69,5" *)
    \tta::bit::clz32  clz32_0(.val_i(_e_5701), .output__(_e_5700));
    assign output__ = _e_5700;
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
    logic[31:0] _e_5708;
    (* src = "src/bit.spade:75,13" *)
    logic[31:0] _e_5707;
    (* src = "src/bit.spade:75,40" *)
    logic[31:0] _e_5713;
    (* src = "src/bit.spade:75,39" *)
    logic[31:0] _e_5712;
    (* src = "src/bit.spade:75,13" *)
    logic[31:0] x_n1;
    (* src = "src/bit.spade:76,14" *)
    logic[31:0] _e_5720;
    (* src = "src/bit.spade:76,13" *)
    logic[31:0] _e_5719;
    (* src = "src/bit.spade:76,40" *)
    logic[31:0] _e_5725;
    (* src = "src/bit.spade:76,39" *)
    logic[31:0] _e_5724;
    (* src = "src/bit.spade:76,13" *)
    logic[31:0] x_n2;
    (* src = "src/bit.spade:77,14" *)
    logic[31:0] _e_5732;
    (* src = "src/bit.spade:77,13" *)
    logic[31:0] _e_5731;
    (* src = "src/bit.spade:77,40" *)
    logic[31:0] _e_5737;
    (* src = "src/bit.spade:77,39" *)
    logic[31:0] _e_5736;
    (* src = "src/bit.spade:77,13" *)
    logic[31:0] x_n3;
    (* src = "src/bit.spade:78,14" *)
    logic[31:0] _e_5744;
    (* src = "src/bit.spade:78,13" *)
    logic[31:0] _e_5743;
    (* src = "src/bit.spade:78,40" *)
    logic[31:0] _e_5749;
    (* src = "src/bit.spade:78,39" *)
    logic[31:0] _e_5748;
    (* src = "src/bit.spade:78,13" *)
    logic[31:0] x_n4;
    (* src = "src/bit.spade:79,13" *)
    logic[31:0] _e_5755;
    (* src = "src/bit.spade:79,25" *)
    logic[31:0] _e_5758;
    (* src = "src/bit.spade:79,13" *)
    logic[31:0] x_n5;
    assign \x  = \val ;
    localparam[31:0] _e_5710 = 32'd1;
    assign _e_5708 = \x  >> _e_5710;
    localparam[31:0] _e_5711 = 32'd1431655765;
    assign _e_5707 = _e_5708 & _e_5711;
    localparam[31:0] _e_5715 = 32'd1431655765;
    assign _e_5713 = \x  & _e_5715;
    localparam[31:0] _e_5716 = 32'd1;
    assign _e_5712 = _e_5713 << _e_5716;
    assign x_n1 = _e_5707 | _e_5712;
    localparam[31:0] _e_5722 = 32'd2;
    assign _e_5720 = x_n1 >> _e_5722;
    localparam[31:0] _e_5723 = 32'd858993459;
    assign _e_5719 = _e_5720 & _e_5723;
    localparam[31:0] _e_5727 = 32'd858993459;
    assign _e_5725 = x_n1 & _e_5727;
    localparam[31:0] _e_5728 = 32'd2;
    assign _e_5724 = _e_5725 << _e_5728;
    assign x_n2 = _e_5719 | _e_5724;
    localparam[31:0] _e_5734 = 32'd4;
    assign _e_5732 = x_n2 >> _e_5734;
    localparam[31:0] _e_5735 = 32'd252645135;
    assign _e_5731 = _e_5732 & _e_5735;
    localparam[31:0] _e_5739 = 32'd252645135;
    assign _e_5737 = x_n2 & _e_5739;
    localparam[31:0] _e_5740 = 32'd4;
    assign _e_5736 = _e_5737 << _e_5740;
    assign x_n3 = _e_5731 | _e_5736;
    localparam[31:0] _e_5746 = 32'd8;
    assign _e_5744 = x_n3 >> _e_5746;
    localparam[31:0] _e_5747 = 32'd16711935;
    assign _e_5743 = _e_5744 & _e_5747;
    localparam[31:0] _e_5751 = 32'd16711935;
    assign _e_5749 = x_n3 & _e_5751;
    localparam[31:0] _e_5752 = 32'd8;
    assign _e_5748 = _e_5749 << _e_5752;
    assign x_n4 = _e_5743 | _e_5748;
    localparam[31:0] _e_5757 = 32'd16;
    assign _e_5755 = x_n4 >> _e_5757;
    localparam[31:0] _e_5760 = 32'd16;
    assign _e_5758 = x_n4 << _e_5760;
    assign x_n5 = _e_5755 | _e_5758;
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
    logic[31:0] _e_5769;
    (* src = "src/bit.spade:86,17" *)
    logic[31:0] _e_5768;
    (* src = "src/bit.spade:86,13" *)
    logic[32:0] x_n1;
    (* src = "src/bit.spade:87,13" *)
    logic[32:0] _e_5775;
    (* src = "src/bit.spade:87,33" *)
    logic[32:0] _e_5779;
    (* src = "src/bit.spade:87,32" *)
    logic[32:0] _e_5778;
    (* src = "src/bit.spade:87,13" *)
    logic[33:0] x_n2;
    (* src = "src/bit.spade:88,18" *)
    logic[33:0] _e_5787;
    (* src = "src/bit.spade:88,13" *)
    logic[34:0] _e_5785;
    (* src = "src/bit.spade:88,13" *)
    logic[34:0] x_n3;
    (* src = "src/bit.spade:89,17" *)
    logic[34:0] _e_5794;
    (* src = "src/bit.spade:89,13" *)
    logic[35:0] x_n4;
    (* src = "src/bit.spade:90,17" *)
    logic[35:0] _e_5800;
    (* src = "src/bit.spade:90,13" *)
    logic[36:0] x_n5;
    (* src = "src/bit.spade:91,11" *)
    logic[36:0] _e_5805;
    (* src = "src/bit.spade:91,5" *)
    logic[31:0] _e_5804;
    assign \x  = \val ;
    localparam[31:0] _e_5771 = 32'd1;
    assign _e_5769 = \x  >> _e_5771;
    localparam[31:0] _e_5772 = 32'd1431655765;
    assign _e_5768 = _e_5769 & _e_5772;
    assign x_n1 = \x  - _e_5768;
    localparam[32:0] _e_5777 = 33'd858993459;
    assign _e_5775 = x_n1 & _e_5777;
    localparam[32:0] _e_5781 = 33'd2;
    assign _e_5779 = x_n1 >> _e_5781;
    localparam[32:0] _e_5782 = 33'd858993459;
    assign _e_5778 = _e_5779 & _e_5782;
    assign x_n2 = _e_5775 + _e_5778;
    localparam[33:0] _e_5789 = 34'd4;
    assign _e_5787 = x_n2 >> _e_5789;
    assign _e_5785 = x_n2 + _e_5787;
    localparam[34:0] _e_5790 = 35'd252645135;
    assign x_n3 = _e_5785 & _e_5790;
    localparam[34:0] _e_5796 = 35'd8;
    assign _e_5794 = x_n3 >> _e_5796;
    assign x_n4 = x_n3 + _e_5794;
    localparam[35:0] _e_5802 = 36'd16;
    assign _e_5800 = x_n4 >> _e_5802;
    assign x_n5 = x_n4 + _e_5800;
    localparam[36:0] _e_5807 = 37'd63;
    assign _e_5805 = x_n5 & _e_5807;
    assign _e_5804 = _e_5805[31:0];
    assign output__ = _e_5804;
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
    logic[31:0] _e_5814;
    (* src = "src/bit.spade:98,25" *)
    logic[31:0] \width_minus_1 ;
    (* src = "src/bit.spade:104,19" *)
    logic _e_5820;
    (* src = "src/bit.spade:107,21" *)
    logic[32:0] _e_5830;
    (* src = "src/bit.spade:107,15" *)
    logic[32:0] _e_5828;
    (* src = "src/bit.spade:107,15" *)
    logic[33:0] _e_5827;
    (* src = "src/bit.spade:107,9" *)
    logic[31:0] _e_5826;
    (* src = "src/bit.spade:104,16" *)
    logic[31:0] \mask ;
    (* src = "src/bit.spade:110,5" *)
    logic[31:0] _e_5836;
    (* src = "src/bit.spade:110,5" *)
    logic[31:0] _e_5835;
    localparam[31:0] _e_5811 = 32'd31;
    assign \lsb  = \ctrl  & _e_5811;
    localparam[31:0] _e_5816 = 32'd5;
    assign _e_5814 = \ctrl  >> _e_5816;
    localparam[31:0] _e_5817 = 32'd31;
    assign \width_minus_1  = _e_5814 & _e_5817;
    localparam[31:0] _e_5822 = 32'd31;
    assign _e_5820 = \width_minus_1  == _e_5822;
    localparam[31:0] _e_5824 = 32'd4294967295;
    localparam[32:0] _e_5829 = 33'd1;
    localparam[31:0] _e_5832 = 32'd1;
    assign _e_5830 = \width_minus_1  + _e_5832;
    assign _e_5828 = _e_5829 << _e_5830;
    localparam[32:0] _e_5833 = 33'd1;
    assign _e_5827 = _e_5828 - _e_5833;
    assign _e_5826 = _e_5827[31:0];
    assign \mask  = _e_5820 ? _e_5824 : _e_5826;
    assign _e_5836 = \val  >> \lsb ;
    assign _e_5835 = _e_5836 & \mask ;
    assign output__ = _e_5835;
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
    logic[31:0] _e_5846;
    (* src = "src/bit.spade:117,25" *)
    logic[31:0] \width_minus_1 ;
    (* src = "src/bit.spade:119,19" *)
    logic _e_5852;
    (* src = "src/bit.spade:122,21" *)
    logic[32:0] _e_5862;
    (* src = "src/bit.spade:122,15" *)
    logic[32:0] _e_5860;
    (* src = "src/bit.spade:122,15" *)
    logic[33:0] _e_5859;
    (* src = "src/bit.spade:122,9" *)
    logic[31:0] _e_5858;
    (* src = "src/bit.spade:119,16" *)
    logic[31:0] \mask ;
    (* src = "src/bit.spade:125,5" *)
    logic[31:0] _e_5868;
    (* src = "src/bit.spade:125,5" *)
    logic[31:0] _e_5867;
    localparam[31:0] _e_5843 = 32'd31;
    assign \lsb  = \ctrl  & _e_5843;
    localparam[31:0] _e_5848 = 32'd5;
    assign _e_5846 = \ctrl  >> _e_5848;
    localparam[31:0] _e_5849 = 32'd31;
    assign \width_minus_1  = _e_5846 & _e_5849;
    localparam[31:0] _e_5854 = 32'd31;
    assign _e_5852 = \width_minus_1  == _e_5854;
    localparam[31:0] _e_5856 = 32'd4294967295;
    localparam[32:0] _e_5861 = 33'd1;
    localparam[31:0] _e_5864 = 32'd1;
    assign _e_5862 = \width_minus_1  + _e_5864;
    assign _e_5860 = _e_5861 << _e_5862;
    localparam[32:0] _e_5865 = 33'd1;
    assign _e_5859 = _e_5860 - _e_5865;
    assign _e_5858 = _e_5859[31:0];
    assign \mask  = _e_5852 ? _e_5856 : _e_5858;
    assign _e_5868 = \val  & \mask ;
    assign _e_5867 = _e_5868 << \lsb ;
    assign output__ = _e_5867;
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
    logic[42:0] _e_5876;
    (* src = "src/bit.spade:133,14" *)
    logic[31:0] \x ;
    logic _e_9692;
    logic _e_9694;
    logic _e_9696;
    logic _e_9697;
    (* src = "src/bit.spade:133,35" *)
    logic[32:0] _e_5878;
    (* src = "src/bit.spade:134,9" *)
    logic[43:0] \_ ;
    (* src = "src/bit.spade:135,13" *)
    logic[42:0] _e_5884;
    (* src = "src/bit.spade:135,18" *)
    logic[31:0] x_n1;
    logic _e_9700;
    logic _e_9702;
    logic _e_9704;
    logic _e_9705;
    (* src = "src/bit.spade:135,39" *)
    logic[32:0] _e_5886;
    (* src = "src/bit.spade:136,13" *)
    logic[43:0] __n1;
    (* src = "src/bit.spade:136,18" *)
    logic[32:0] _e_5889;
    (* src = "src/bit.spade:134,14" *)
    logic[32:0] _e_5881;
    (* src = "src/bit.spade:132,5" *)
    logic[32:0] _e_5873;
    assign _e_5876 = \m1 [42:0];
    assign \x  = _e_5876[36:5];
    assign _e_9692 = \m1 [43] == 1'd1;
    assign _e_9694 = _e_5876[42:37] == 6'd39;
    localparam[0:0] _e_9695 = 1;
    assign _e_9696 = _e_9694 && _e_9695;
    assign _e_9697 = _e_9692 && _e_9696;
    assign _e_5878 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9698 = 1;
    assign _e_5884 = \m0 [42:0];
    assign x_n1 = _e_5884[36:5];
    assign _e_9700 = \m0 [43] == 1'd1;
    assign _e_9702 = _e_5884[42:37] == 6'd39;
    localparam[0:0] _e_9703 = 1;
    assign _e_9704 = _e_9702 && _e_9703;
    assign _e_9705 = _e_9700 && _e_9704;
    assign _e_5886 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9706 = 1;
    assign _e_5889 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9705, _e_9706})
            2'b1?: _e_5881 = _e_5886;
            2'b01: _e_5881 = _e_5889;
            2'b?: _e_5881 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9697, _e_9698})
            2'b1?: _e_5873 = _e_5878;
            2'b01: _e_5873 = _e_5881;
            2'b?: _e_5873 = 33'dx;
        endcase
    end
    assign output__ = _e_5873;
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
    logic[42:0] _e_5895;
    (* src = "src/bit.spade:142,14" *)
    logic[2:0] \op ;
    (* src = "src/bit.spade:142,14" *)
    logic[31:0] \x ;
    logic _e_9708;
    logic _e_9710;
    logic _e_9713;
    logic _e_9714;
    logic _e_9715;
    (* src = "src/bit.spade:142,44" *)
    logic[34:0] _e_5898;
    (* src = "src/bit.spade:142,39" *)
    logic[35:0] _e_5897;
    (* src = "src/bit.spade:143,9" *)
    logic[43:0] \_ ;
    (* src = "src/bit.spade:144,13" *)
    logic[42:0] _e_5906;
    (* src = "src/bit.spade:144,18" *)
    logic[2:0] op_n1;
    (* src = "src/bit.spade:144,18" *)
    logic[31:0] x_n1;
    logic _e_9718;
    logic _e_9720;
    logic _e_9723;
    logic _e_9724;
    logic _e_9725;
    (* src = "src/bit.spade:144,48" *)
    logic[34:0] _e_5909;
    (* src = "src/bit.spade:144,43" *)
    logic[35:0] _e_5908;
    (* src = "src/bit.spade:145,13" *)
    logic[43:0] __n1;
    (* src = "src/bit.spade:145,18" *)
    logic[35:0] _e_5913;
    (* src = "src/bit.spade:143,14" *)
    logic[35:0] _e_5902;
    (* src = "src/bit.spade:141,5" *)
    logic[35:0] _e_5891;
    assign _e_5895 = \m1 [42:0];
    assign \op  = _e_5895[36:34];
    assign \x  = _e_5895[33:2];
    assign _e_9708 = \m1 [43] == 1'd1;
    assign _e_9710 = _e_5895[42:37] == 6'd40;
    localparam[0:0] _e_9711 = 1;
    localparam[0:0] _e_9712 = 1;
    assign _e_9713 = _e_9710 && _e_9711;
    assign _e_9714 = _e_9713 && _e_9712;
    assign _e_9715 = _e_9708 && _e_9714;
    assign _e_5898 = {\op , \x };
    assign _e_5897 = {1'd1, _e_5898};
    assign \_  = \m1 ;
    localparam[0:0] _e_9716 = 1;
    assign _e_5906 = \m0 [42:0];
    assign op_n1 = _e_5906[36:34];
    assign x_n1 = _e_5906[33:2];
    assign _e_9718 = \m0 [43] == 1'd1;
    assign _e_9720 = _e_5906[42:37] == 6'd40;
    localparam[0:0] _e_9721 = 1;
    localparam[0:0] _e_9722 = 1;
    assign _e_9723 = _e_9720 && _e_9721;
    assign _e_9724 = _e_9723 && _e_9722;
    assign _e_9725 = _e_9718 && _e_9724;
    assign _e_5909 = {op_n1, x_n1};
    assign _e_5908 = {1'd1, _e_5909};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9726 = 1;
    assign _e_5913 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_9725, _e_9726})
            2'b1?: _e_5902 = _e_5908;
            2'b01: _e_5902 = _e_5913;
            2'b?: _e_5902 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9715, _e_9716})
            2'b1?: _e_5891 = _e_5897;
            2'b01: _e_5891 = _e_5902;
            2'b?: _e_5891 = 36'dx;
        endcase
    end
    assign output__ = _e_5891;
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
    logic _e_9728;
    logic _e_9730;
    logic _e_9732;
    (* src = "src/mac.spade:19,45" *)
    logic[31:0] _e_5919;
    (* src = "src/mac.spade:19,14" *)
    reg[31:0] \op_a ;
    (* src = "src/mac.spade:31,17" *)
    logic[31:0] \op_b ;
    logic _e_9734;
    logic _e_9736;
    (* src = "src/mac.spade:34,48" *)
    logic[63:0] _e_5942;
    (* src = "src/mac.spade:34,42" *)
    logic[31:0] \prod ;
    (* src = "src/mac.spade:35,27" *)
    logic[32:0] _e_5947;
    (* src = "src/mac.spade:35,21" *)
    logic[31:0] _e_5946;
    logic _e_9738;
    (* src = "src/mac.spade:30,13" *)
    logic[31:0] _e_5936;
    (* src = "src/mac.spade:27,9" *)
    logic[31:0] _e_5931;
    (* src = "src/mac.spade:26,14" *)
    reg[31:0] \acc ;
    (* src = "src/mac.spade:43,47" *)
    logic[32:0] _e_5955;
    (* src = "src/mac.spade:47,13" *)
    logic[32:0] _e_5960;
    (* src = "src/mac.spade:50,17" *)
    logic[31:0] op_b_n1;
    logic _e_9740;
    logic _e_9742;
    (* src = "src/mac.spade:52,48" *)
    logic[63:0] _e_5969;
    (* src = "src/mac.spade:52,42" *)
    logic[31:0] prod_n1;
    (* src = "src/mac.spade:53,32" *)
    logic[32:0] _e_5975;
    (* src = "src/mac.spade:53,26" *)
    logic[31:0] _e_5974;
    (* src = "src/mac.spade:53,21" *)
    logic[32:0] _e_5973;
    logic _e_9744;
    (* src = "src/mac.spade:55,25" *)
    logic[32:0] _e_5979;
    (* src = "src/mac.spade:49,13" *)
    logic[32:0] _e_5963;
    (* src = "src/mac.spade:44,9" *)
    logic[32:0] _e_5957;
    (* src = "src/mac.spade:43,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_5918 = 32'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9728 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9729 = 1;
    assign _e_9730 = _e_9728 && _e_9729;
    assign _e_9732 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9730, _e_9732})
            2'b1?: _e_5919 = \val ;
            2'b01: _e_5919 = \op_a ;
            2'b?: _e_5919 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_5918;
        end
        else begin
            \op_a  <= _e_5919;
        end
    end
    localparam[31:0] _e_5929 = 32'd0;
    localparam[31:0] _e_5934 = 32'd0;
    assign \op_b  = \trig [31:0];
    assign _e_9734 = \trig [32] == 1'd1;
    localparam[0:0] _e_9735 = 1;
    assign _e_9736 = _e_9734 && _e_9735;
    assign _e_5942 = \op_a  * \op_b ;
    assign \prod  = _e_5942[31:0];
    assign _e_5947 = \acc  + \prod ;
    assign _e_5946 = _e_5947[31:0];
    assign _e_9738 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9736, _e_9738})
            2'b1?: _e_5936 = _e_5946;
            2'b01: _e_5936 = \acc ;
            2'b?: _e_5936 = 32'dx;
        endcase
    end
    assign _e_5931 = \clr  ? _e_5934 : _e_5936;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \acc  <= _e_5929;
        end
        else begin
            \acc  <= _e_5931;
        end
    end
    assign _e_5955 = {1'd0, 32'bX};
    localparam[31:0] _e_5961 = 32'd0;
    assign _e_5960 = {1'd1, _e_5961};
    assign op_b_n1 = \trig [31:0];
    assign _e_9740 = \trig [32] == 1'd1;
    localparam[0:0] _e_9741 = 1;
    assign _e_9742 = _e_9740 && _e_9741;
    assign _e_5969 = \op_a  * op_b_n1;
    assign prod_n1 = _e_5969[31:0];
    assign _e_5975 = \acc  + prod_n1;
    assign _e_5974 = _e_5975[31:0];
    assign _e_5973 = {1'd1, _e_5974};
    assign _e_9744 = \trig [32] == 1'd0;
    assign _e_5979 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9742, _e_9744})
            2'b1?: _e_5963 = _e_5973;
            2'b01: _e_5963 = _e_5979;
            2'b?: _e_5963 = 33'dx;
        endcase
    end
    assign _e_5957 = \clr  ? _e_5960 : _e_5963;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_5955;
        end
        else begin
            \res  <= _e_5957;
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
    logic[42:0] _e_5985;
    (* src = "src/mac.spade:66,14" *)
    logic[31:0] \x ;
    logic _e_9746;
    logic _e_9748;
    logic _e_9750;
    logic _e_9751;
    (* src = "src/mac.spade:66,35" *)
    logic[32:0] _e_5987;
    (* src = "src/mac.spade:67,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:68,13" *)
    logic[42:0] _e_5993;
    (* src = "src/mac.spade:68,18" *)
    logic[31:0] x_n1;
    logic _e_9754;
    logic _e_9756;
    logic _e_9758;
    logic _e_9759;
    (* src = "src/mac.spade:68,39" *)
    logic[32:0] _e_5995;
    (* src = "src/mac.spade:69,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:69,18" *)
    logic[32:0] _e_5998;
    (* src = "src/mac.spade:67,14" *)
    logic[32:0] _e_5990;
    (* src = "src/mac.spade:65,5" *)
    logic[32:0] _e_5982;
    assign _e_5985 = \m1 [42:0];
    assign \x  = _e_5985[36:5];
    assign _e_9746 = \m1 [43] == 1'd1;
    assign _e_9748 = _e_5985[42:37] == 6'd24;
    localparam[0:0] _e_9749 = 1;
    assign _e_9750 = _e_9748 && _e_9749;
    assign _e_9751 = _e_9746 && _e_9750;
    assign _e_5987 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9752 = 1;
    assign _e_5993 = \m0 [42:0];
    assign x_n1 = _e_5993[36:5];
    assign _e_9754 = \m0 [43] == 1'd1;
    assign _e_9756 = _e_5993[42:37] == 6'd24;
    localparam[0:0] _e_9757 = 1;
    assign _e_9758 = _e_9756 && _e_9757;
    assign _e_9759 = _e_9754 && _e_9758;
    assign _e_5995 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9760 = 1;
    assign _e_5998 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9759, _e_9760})
            2'b1?: _e_5990 = _e_5995;
            2'b01: _e_5990 = _e_5998;
            2'b?: _e_5990 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9751, _e_9752})
            2'b1?: _e_5982 = _e_5987;
            2'b01: _e_5982 = _e_5990;
            2'b?: _e_5982 = 33'dx;
        endcase
    end
    assign output__ = _e_5982;
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
    logic[42:0] _e_6003;
    (* src = "src/mac.spade:76,14" *)
    logic[31:0] \x ;
    logic _e_9762;
    logic _e_9764;
    logic _e_9766;
    logic _e_9767;
    (* src = "src/mac.spade:76,35" *)
    logic[32:0] _e_6005;
    (* src = "src/mac.spade:77,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:78,13" *)
    logic[42:0] _e_6011;
    (* src = "src/mac.spade:78,18" *)
    logic[31:0] x_n1;
    logic _e_9770;
    logic _e_9772;
    logic _e_9774;
    logic _e_9775;
    (* src = "src/mac.spade:78,39" *)
    logic[32:0] _e_6013;
    (* src = "src/mac.spade:79,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:79,18" *)
    logic[32:0] _e_6016;
    (* src = "src/mac.spade:77,14" *)
    logic[32:0] _e_6008;
    (* src = "src/mac.spade:75,5" *)
    logic[32:0] _e_6000;
    assign _e_6003 = \m1 [42:0];
    assign \x  = _e_6003[36:5];
    assign _e_9762 = \m1 [43] == 1'd1;
    assign _e_9764 = _e_6003[42:37] == 6'd25;
    localparam[0:0] _e_9765 = 1;
    assign _e_9766 = _e_9764 && _e_9765;
    assign _e_9767 = _e_9762 && _e_9766;
    assign _e_6005 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9768 = 1;
    assign _e_6011 = \m0 [42:0];
    assign x_n1 = _e_6011[36:5];
    assign _e_9770 = \m0 [43] == 1'd1;
    assign _e_9772 = _e_6011[42:37] == 6'd25;
    localparam[0:0] _e_9773 = 1;
    assign _e_9774 = _e_9772 && _e_9773;
    assign _e_9775 = _e_9770 && _e_9774;
    assign _e_6013 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9776 = 1;
    assign _e_6016 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9775, _e_9776})
            2'b1?: _e_6008 = _e_6013;
            2'b01: _e_6008 = _e_6016;
            2'b?: _e_6008 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9767, _e_9768})
            2'b1?: _e_6000 = _e_6005;
            2'b01: _e_6000 = _e_6008;
            2'b?: _e_6000 = 33'dx;
        endcase
    end
    assign output__ = _e_6000;
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
    logic[42:0] _e_6021;
    (* src = "src/mac.spade:86,14" *)
    logic \x ;
    logic _e_9778;
    logic _e_9780;
    logic _e_9782;
    logic _e_9783;
    (* src = "src/mac.spade:87,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:88,13" *)
    logic[42:0] _e_6028;
    (* src = "src/mac.spade:88,18" *)
    logic x_n1;
    logic _e_9786;
    logic _e_9788;
    logic _e_9790;
    logic _e_9791;
    (* src = "src/mac.spade:89,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:87,14" *)
    logic _e_6025;
    (* src = "src/mac.spade:85,5" *)
    logic _e_6018;
    assign _e_6021 = \m1 [42:0];
    assign \x  = _e_6021[36:36];
    assign _e_9778 = \m1 [43] == 1'd1;
    assign _e_9780 = _e_6021[42:37] == 6'd26;
    localparam[0:0] _e_9781 = 1;
    assign _e_9782 = _e_9780 && _e_9781;
    assign _e_9783 = _e_9778 && _e_9782;
    assign \_  = \m1 ;
    localparam[0:0] _e_9784 = 1;
    assign _e_6028 = \m0 [42:0];
    assign x_n1 = _e_6028[36:36];
    assign _e_9786 = \m0 [43] == 1'd1;
    assign _e_9788 = _e_6028[42:37] == 6'd26;
    localparam[0:0] _e_9789 = 1;
    assign _e_9790 = _e_9788 && _e_9789;
    assign _e_9791 = _e_9786 && _e_9790;
    assign __n1 = \m0 ;
    localparam[0:0] _e_9792 = 1;
    localparam[0:0] _e_6032 = 0;
    always_comb begin
        priority casez ({_e_9791, _e_9792})
            2'b1?: _e_6025 = x_n1;
            2'b01: _e_6025 = _e_6032;
            2'b?: _e_6025 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9783, _e_9784})
            2'b1?: _e_6018 = \x ;
            2'b01: _e_6018 = _e_6025;
            2'b?: _e_6018 = 1'dx;
        endcase
    end
    assign output__ = _e_6018;
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
    logic[34:0] _e_6038;
    (* src = "src/cmpz.spade:28,14" *)
    logic[2:0] _e_6036;
    (* src = "src/cmpz.spade:28,14" *)
    logic[31:0] \b ;
    logic _e_9794;
    logic _e_9797;
    logic _e_9799;
    logic _e_9800;
    (* src = "src/cmpz.spade:28,49" *)
    logic _e_6042;
    (* src = "src/cmpz.spade:28,42" *)
    logic[31:0] _e_6041;
    (* src = "src/cmpz.spade:28,37" *)
    logic[32:0] _e_6040;
    (* src = "src/cmpz.spade:29,9" *)
    logic[34:0] _e_6047;
    (* src = "src/cmpz.spade:29,14" *)
    logic[2:0] _e_6045;
    (* src = "src/cmpz.spade:29,14" *)
    logic[31:0] b_n1;
    logic _e_9802;
    logic _e_9805;
    logic _e_9807;
    logic _e_9808;
    (* src = "src/cmpz.spade:29,49" *)
    logic _e_6051;
    (* src = "src/cmpz.spade:29,42" *)
    logic[31:0] _e_6050;
    (* src = "src/cmpz.spade:29,37" *)
    logic[32:0] _e_6049;
    (* src = "src/cmpz.spade:30,9" *)
    logic[34:0] _e_6056;
    (* src = "src/cmpz.spade:30,14" *)
    logic[2:0] _e_6054;
    (* src = "src/cmpz.spade:30,14" *)
    logic[31:0] b_n2;
    logic _e_9810;
    logic _e_9813;
    logic _e_9815;
    logic _e_9816;
    (* src = "src/cmpz.spade:30,49" *)
    logic _e_6061;
    (* src = "src/cmpz.spade:30,49" *)
    logic _e_6060;
    (* src = "src/cmpz.spade:30,42" *)
    logic[31:0] _e_6059;
    (* src = "src/cmpz.spade:30,37" *)
    logic[32:0] _e_6058;
    (* src = "src/cmpz.spade:31,9" *)
    logic[34:0] _e_6066;
    (* src = "src/cmpz.spade:31,14" *)
    logic[2:0] _e_6064;
    (* src = "src/cmpz.spade:31,14" *)
    logic[31:0] b_n3;
    logic _e_9818;
    logic _e_9821;
    logic _e_9823;
    logic _e_9824;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6072;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6071;
    (* src = "src/cmpz.spade:31,67" *)
    logic _e_6075;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6070;
    (* src = "src/cmpz.spade:31,42" *)
    logic[31:0] _e_6069;
    (* src = "src/cmpz.spade:31,37" *)
    logic[32:0] _e_6068;
    (* src = "src/cmpz.spade:32,9" *)
    logic[34:0] _e_6080;
    (* src = "src/cmpz.spade:32,14" *)
    logic[2:0] _e_6078;
    (* src = "src/cmpz.spade:32,14" *)
    logic[31:0] b_n4;
    logic _e_9826;
    logic _e_9829;
    logic _e_9831;
    logic _e_9832;
    (* src = "src/cmpz.spade:32,49" *)
    logic _e_6086;
    (* src = "src/cmpz.spade:32,49" *)
    logic _e_6085;
    (* src = "src/cmpz.spade:32,67" *)
    logic _e_6089;
    (* src = "src/cmpz.spade:32,49" *)
    logic _e_6084;
    (* src = "src/cmpz.spade:32,42" *)
    logic[31:0] _e_6083;
    (* src = "src/cmpz.spade:32,37" *)
    logic[32:0] _e_6082;
    (* src = "src/cmpz.spade:33,9" *)
    logic[34:0] _e_6094;
    (* src = "src/cmpz.spade:33,14" *)
    logic[2:0] _e_6092;
    (* src = "src/cmpz.spade:33,14" *)
    logic[31:0] b_n5;
    logic _e_9834;
    logic _e_9837;
    logic _e_9839;
    logic _e_9840;
    (* src = "src/cmpz.spade:33,49" *)
    logic _e_6099;
    (* src = "src/cmpz.spade:33,49" *)
    logic _e_6098;
    (* src = "src/cmpz.spade:33,42" *)
    logic[31:0] _e_6097;
    (* src = "src/cmpz.spade:33,37" *)
    logic[32:0] _e_6096;
    logic _e_9842;
    (* src = "src/cmpz.spade:34,37" *)
    logic[32:0] _e_6103;
    (* src = "src/cmpz.spade:27,36" *)
    logic[32:0] \result ;
    (* src = "src/cmpz.spade:38,51" *)
    logic[32:0] _e_6108;
    (* src = "src/cmpz.spade:38,14" *)
    reg[32:0] \res_reg ;
    assign _e_6038 = \trig [34:0];
    assign _e_6036 = _e_6038[34:32];
    assign \b  = _e_6038[31:0];
    assign _e_9794 = \trig [35] == 1'd1;
    assign _e_9797 = _e_6036[2:0] == 3'd0;
    localparam[0:0] _e_9798 = 1;
    assign _e_9799 = _e_9797 && _e_9798;
    assign _e_9800 = _e_9794 && _e_9799;
    localparam[31:0] _e_6044 = 32'd0;
    assign _e_6042 = \b  == _e_6044;
    (* src = "src/cmpz.spade:28,42" *)
    \tta::cmpz::to_u32  to_u32_0(.x_i(_e_6042), .output__(_e_6041));
    assign _e_6040 = {1'd1, _e_6041};
    assign _e_6047 = \trig [34:0];
    assign _e_6045 = _e_6047[34:32];
    assign b_n1 = _e_6047[31:0];
    assign _e_9802 = \trig [35] == 1'd1;
    assign _e_9805 = _e_6045[2:0] == 3'd1;
    localparam[0:0] _e_9806 = 1;
    assign _e_9807 = _e_9805 && _e_9806;
    assign _e_9808 = _e_9802 && _e_9807;
    localparam[31:0] _e_6053 = 32'd0;
    assign _e_6051 = b_n1 != _e_6053;
    (* src = "src/cmpz.spade:29,42" *)
    \tta::cmpz::to_u32  to_u32_1(.x_i(_e_6051), .output__(_e_6050));
    assign _e_6049 = {1'd1, _e_6050};
    assign _e_6056 = \trig [34:0];
    assign _e_6054 = _e_6056[34:32];
    assign b_n2 = _e_6056[31:0];
    assign _e_9810 = \trig [35] == 1'd1;
    assign _e_9813 = _e_6054[2:0] == 3'd2;
    localparam[0:0] _e_9814 = 1;
    assign _e_9815 = _e_9813 && _e_9814;
    assign _e_9816 = _e_9810 && _e_9815;
    (* src = "src/cmpz.spade:30,49" *)
    \tta::cmpz::msb1  msb1_0(.x_i(b_n2), .output__(_e_6061));
    localparam[0:0] _e_6063 = 1;
    assign _e_6060 = _e_6061 == _e_6063;
    (* src = "src/cmpz.spade:30,42" *)
    \tta::cmpz::to_u32  to_u32_2(.x_i(_e_6060), .output__(_e_6059));
    assign _e_6058 = {1'd1, _e_6059};
    assign _e_6066 = \trig [34:0];
    assign _e_6064 = _e_6066[34:32];
    assign b_n3 = _e_6066[31:0];
    assign _e_9818 = \trig [35] == 1'd1;
    assign _e_9821 = _e_6064[2:0] == 3'd3;
    localparam[0:0] _e_9822 = 1;
    assign _e_9823 = _e_9821 && _e_9822;
    assign _e_9824 = _e_9818 && _e_9823;
    (* src = "src/cmpz.spade:31,49" *)
    \tta::cmpz::msb1  msb1_1(.x_i(b_n3), .output__(_e_6072));
    localparam[0:0] _e_6074 = 1;
    assign _e_6071 = _e_6072 == _e_6074;
    localparam[31:0] _e_6077 = 32'd0;
    assign _e_6075 = b_n3 == _e_6077;
    assign _e_6070 = _e_6071 || _e_6075;
    (* src = "src/cmpz.spade:31,42" *)
    \tta::cmpz::to_u32  to_u32_3(.x_i(_e_6070), .output__(_e_6069));
    assign _e_6068 = {1'd1, _e_6069};
    assign _e_6080 = \trig [34:0];
    assign _e_6078 = _e_6080[34:32];
    assign b_n4 = _e_6080[31:0];
    assign _e_9826 = \trig [35] == 1'd1;
    assign _e_9829 = _e_6078[2:0] == 3'd4;
    localparam[0:0] _e_9830 = 1;
    assign _e_9831 = _e_9829 && _e_9830;
    assign _e_9832 = _e_9826 && _e_9831;
    (* src = "src/cmpz.spade:32,49" *)
    \tta::cmpz::msb1  msb1_2(.x_i(b_n4), .output__(_e_6086));
    localparam[0:0] _e_6088 = 1;
    assign _e_6085 = _e_6086 != _e_6088;
    localparam[31:0] _e_6091 = 32'd0;
    assign _e_6089 = b_n4 != _e_6091;
    assign _e_6084 = _e_6085 && _e_6089;
    (* src = "src/cmpz.spade:32,42" *)
    \tta::cmpz::to_u32  to_u32_4(.x_i(_e_6084), .output__(_e_6083));
    assign _e_6082 = {1'd1, _e_6083};
    assign _e_6094 = \trig [34:0];
    assign _e_6092 = _e_6094[34:32];
    assign b_n5 = _e_6094[31:0];
    assign _e_9834 = \trig [35] == 1'd1;
    assign _e_9837 = _e_6092[2:0] == 3'd5;
    localparam[0:0] _e_9838 = 1;
    assign _e_9839 = _e_9837 && _e_9838;
    assign _e_9840 = _e_9834 && _e_9839;
    (* src = "src/cmpz.spade:33,49" *)
    \tta::cmpz::msb1  msb1_3(.x_i(b_n5), .output__(_e_6099));
    localparam[0:0] _e_6101 = 1;
    assign _e_6098 = _e_6099 != _e_6101;
    (* src = "src/cmpz.spade:33,42" *)
    \tta::cmpz::to_u32  to_u32_5(.x_i(_e_6098), .output__(_e_6097));
    assign _e_6096 = {1'd1, _e_6097};
    assign _e_9842 = \trig [35] == 1'd0;
    assign _e_6103 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9800, _e_9808, _e_9816, _e_9824, _e_9832, _e_9840, _e_9842})
            7'b1??????: \result  = _e_6040;
            7'b01?????: \result  = _e_6049;
            7'b001????: \result  = _e_6058;
            7'b0001???: \result  = _e_6068;
            7'b00001??: \result  = _e_6082;
            7'b000001?: \result  = _e_6096;
            7'b0000001: \result  = _e_6103;
            7'b?: \result  = 33'dx;
        endcase
    end
    assign _e_6108 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_6108;
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
    logic[42:0] _e_6116;
    (* src = "src/cmpz.spade:45,14" *)
    logic[2:0] \op ;
    (* src = "src/cmpz.spade:45,14" *)
    logic[31:0] \x ;
    logic _e_9844;
    logic _e_9846;
    logic _e_9849;
    logic _e_9850;
    logic _e_9851;
    (* src = "src/cmpz.spade:45,45" *)
    logic[34:0] _e_6119;
    (* src = "src/cmpz.spade:45,40" *)
    logic[35:0] _e_6118;
    (* src = "src/cmpz.spade:46,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmpz.spade:47,13" *)
    logic[42:0] _e_6127;
    (* src = "src/cmpz.spade:47,18" *)
    logic[2:0] op_n1;
    (* src = "src/cmpz.spade:47,18" *)
    logic[31:0] x_n1;
    logic _e_9854;
    logic _e_9856;
    logic _e_9859;
    logic _e_9860;
    logic _e_9861;
    (* src = "src/cmpz.spade:47,49" *)
    logic[34:0] _e_6130;
    (* src = "src/cmpz.spade:47,44" *)
    logic[35:0] _e_6129;
    (* src = "src/cmpz.spade:48,13" *)
    logic[43:0] __n1;
    (* src = "src/cmpz.spade:48,18" *)
    logic[35:0] _e_6134;
    (* src = "src/cmpz.spade:46,14" *)
    logic[35:0] _e_6123;
    (* src = "src/cmpz.spade:44,5" *)
    logic[35:0] _e_6112;
    assign _e_6116 = \m1 [42:0];
    assign \op  = _e_6116[36:34];
    assign \x  = _e_6116[33:2];
    assign _e_9844 = \m1 [43] == 1'd1;
    assign _e_9846 = _e_6116[42:37] == 6'd13;
    localparam[0:0] _e_9847 = 1;
    localparam[0:0] _e_9848 = 1;
    assign _e_9849 = _e_9846 && _e_9847;
    assign _e_9850 = _e_9849 && _e_9848;
    assign _e_9851 = _e_9844 && _e_9850;
    assign _e_6119 = {\op , \x };
    assign _e_6118 = {1'd1, _e_6119};
    assign \_  = \m1 ;
    localparam[0:0] _e_9852 = 1;
    assign _e_6127 = \m0 [42:0];
    assign op_n1 = _e_6127[36:34];
    assign x_n1 = _e_6127[33:2];
    assign _e_9854 = \m0 [43] == 1'd1;
    assign _e_9856 = _e_6127[42:37] == 6'd13;
    localparam[0:0] _e_9857 = 1;
    localparam[0:0] _e_9858 = 1;
    assign _e_9859 = _e_9856 && _e_9857;
    assign _e_9860 = _e_9859 && _e_9858;
    assign _e_9861 = _e_9854 && _e_9860;
    assign _e_6130 = {op_n1, x_n1};
    assign _e_6129 = {1'd1, _e_6130};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9862 = 1;
    assign _e_6134 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_9861, _e_9862})
            2'b1?: _e_6123 = _e_6129;
            2'b01: _e_6123 = _e_6134;
            2'b?: _e_6123 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9851, _e_9852})
            2'b1?: _e_6112 = _e_6118;
            2'b01: _e_6112 = _e_6123;
            2'b?: _e_6112 = 36'dx;
        endcase
    end
    assign output__ = _e_6112;
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
    logic[31:0] _e_6138;
    (* src = "src/cmpz.spade:53,41" *)
    logic[31:0] _e_6137;
    (* src = "src/cmpz.spade:53,35" *)
    logic _e_6136;
    localparam[31:0] _e_6140 = 32'd31;
    assign _e_6138 = \x  >> _e_6140;
    localparam[31:0] _e_6141 = 32'd1;
    assign _e_6137 = _e_6138 & _e_6141;
    assign _e_6136 = _e_6137[0:0];
    assign output__ = _e_6136;
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
    logic[31:0] _e_6143;
    localparam[31:0] _e_6146 = 32'd1;
    localparam[31:0] _e_6148 = 32'd0;
    assign _e_6143 = \x  ? _e_6146 : _e_6148;
    assign output__ = _e_6143;
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
    logic _e_6151;
    (* src = "src/div_shiftsub.spade:28,5" *)
    logic[134:0] _e_6150;
    assign _e_6151 = {1'd0};
    localparam[31:0] _e_6152 = 32'd0;
    localparam[31:0] _e_6153 = 32'd0;
    localparam[31:0] _e_6154 = 32'd0;
    localparam[31:0] _e_6155 = 32'd0;
    localparam[5:0] _e_6156 = 0;
    assign _e_6150 = {_e_6151, _e_6152, _e_6153, _e_6154, _e_6155, _e_6156};
    assign output__ = _e_6150;
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
    logic[134:0] _e_6161;
    (* src = "src/div_shiftsub.spade:37,57" *)
    logic _e_6163;
    (* src = "src/div_shiftsub.spade:38,9" *)
    logic _e_6165;
    logic _e_9864;
    (* src = "src/div_shiftsub.spade:41,17" *)
    logic[31:0] \val ;
    logic _e_9866;
    logic _e_9868;
    logic _e_9870;
    (* src = "src/div_shiftsub.spade:42,25" *)
    logic[31:0] _e_6173;
    (* src = "src/div_shiftsub.spade:40,33" *)
    logic[31:0] \next_dividend ;
    (* src = "src/div_shiftsub.spade:46,17" *)
    logic[31:0] \divisor ;
    logic _e_9872;
    logic _e_9874;
    (* src = "src/div_shiftsub.spade:46,42" *)
    logic _e_6181;
    (* src = "src/div_shiftsub.spade:46,34" *)
    logic[134:0] _e_6180;
    logic _e_9876;
    (* src = "src/div_shiftsub.spade:47,33" *)
    logic _e_6189;
    (* src = "src/div_shiftsub.spade:47,25" *)
    logic[134:0] _e_6188;
    (* src = "src/div_shiftsub.spade:45,13" *)
    logic[134:0] _e_6176;
    (* src = "src/div_shiftsub.spade:50,9" *)
    logic _e_6195;
    logic _e_9878;
    (* src = "src/div_shiftsub.spade:52,33" *)
    logic[31:0] _e_6198;
    (* src = "src/div_shiftsub.spade:52,32" *)
    logic[31:0] \msb_dividend ;
    (* src = "src/div_shiftsub.spade:53,32" *)
    logic[31:0] _e_6204;
    (* src = "src/div_shiftsub.spade:53,31" *)
    logic[31:0] _e_6203;
    (* src = "src/div_shiftsub.spade:53,31" *)
    logic[31:0] \rem_shifted ;
    (* src = "src/div_shiftsub.spade:54,31" *)
    logic[31:0] _e_6210;
    (* src = "src/div_shiftsub.spade:54,31" *)
    logic[31:0] \dvd_shifted ;
    (* src = "src/div_shiftsub.spade:57,42" *)
    logic[31:0] _e_6216;
    (* src = "src/div_shiftsub.spade:57,27" *)
    logic \can_sub ;
    (* src = "src/div_shiftsub.spade:61,38" *)
    logic[31:0] _e_6226;
    (* src = "src/div_shiftsub.spade:61,24" *)
    logic[32:0] _e_6224;
    (* src = "src/div_shiftsub.spade:61,18" *)
    logic[31:0] _e_6223;
    (* src = "src/div_shiftsub.spade:61,17" *)
    logic[63:0] _e_6222;
    (* src = "src/div_shiftsub.spade:63,17" *)
    logic[63:0] _e_6230;
    (* src = "src/div_shiftsub.spade:60,40" *)
    logic[63:0] _e_6235;
    (* src = "src/div_shiftsub.spade:60,17" *)
    logic[31:0] \next_rem ;
    (* src = "src/div_shiftsub.spade:60,17" *)
    logic[31:0] \quot_bit ;
    (* src = "src/div_shiftsub.spade:66,30" *)
    logic[31:0] _e_6238;
    (* src = "src/div_shiftsub.spade:66,29" *)
    logic[31:0] _e_6237;
    (* src = "src/div_shiftsub.spade:66,29" *)
    logic[31:0] \next_quot ;
    (* src = "src/div_shiftsub.spade:68,16" *)
    logic[5:0] _e_6245;
    (* src = "src/div_shiftsub.spade:68,16" *)
    logic _e_6244;
    (* src = "src/div_shiftsub.spade:70,17" *)
    logic[134:0] _e_6249;
    (* src = "src/div_shiftsub.spade:73,25" *)
    logic _e_6252;
    (* src = "src/div_shiftsub.spade:73,51" *)
    logic[31:0] _e_6254;
    (* src = "src/div_shiftsub.spade:73,89" *)
    logic[5:0] _e_6260;
    (* src = "src/div_shiftsub.spade:73,89" *)
    logic[6:0] _e_6259;
    (* src = "src/div_shiftsub.spade:73,83" *)
    logic[5:0] _e_6258;
    (* src = "src/div_shiftsub.spade:73,17" *)
    logic[134:0] _e_6251;
    (* src = "src/div_shiftsub.spade:68,13" *)
    logic[134:0] _e_6243;
    (* src = "src/div_shiftsub.spade:37,51" *)
    logic[134:0] _e_6162;
    (* src = "src/div_shiftsub.spade:37,14" *)
    reg[134:0] \r ;
    (* src = "src/div_shiftsub.spade:82,11" *)
    logic _e_6264;
    (* src = "src/div_shiftsub.spade:83,9" *)
    logic _e_6266;
    logic _e_9880;
    (* src = "src/div_shiftsub.spade:84,16" *)
    logic[5:0] _e_6270;
    (* src = "src/div_shiftsub.spade:84,16" *)
    logic _e_6269;
    (* src = "src/div_shiftsub.spade:86,37" *)
    logic[31:0] _e_6275;
    (* src = "src/div_shiftsub.spade:86,36" *)
    logic[31:0] msb_dividend_n1;
    (* src = "src/div_shiftsub.spade:87,36" *)
    logic[31:0] _e_6281;
    (* src = "src/div_shiftsub.spade:87,35" *)
    logic[31:0] _e_6280;
    (* src = "src/div_shiftsub.spade:87,35" *)
    logic[31:0] rem_shifted_n1;
    (* src = "src/div_shiftsub.spade:88,46" *)
    logic[31:0] _e_6288;
    (* src = "src/div_shiftsub.spade:88,31" *)
    logic can_sub_n1;
    (* src = "src/div_shiftsub.spade:89,32" *)
    logic[31:0] quot_bit_n1;
    (* src = "src/div_shiftsub.spade:91,23" *)
    logic[31:0] _e_6301;
    (* src = "src/div_shiftsub.spade:91,22" *)
    logic[31:0] _e_6300;
    (* src = "src/div_shiftsub.spade:91,22" *)
    logic[31:0] _e_6299;
    (* src = "src/div_shiftsub.spade:91,17" *)
    logic[32:0] _e_6298;
    (* src = "src/div_shiftsub.spade:93,17" *)
    logic[32:0] _e_6306;
    (* src = "src/div_shiftsub.spade:84,13" *)
    logic[32:0] _e_6268;
    (* src = "src/div_shiftsub.spade:96,9" *)
    logic \_ ;
    (* src = "src/div_shiftsub.spade:96,14" *)
    logic[32:0] _e_6308;
    (* src = "src/div_shiftsub.spade:82,5" *)
    logic[32:0] _e_6263;
    (* src = "src/div_shiftsub.spade:37,36" *)
    \tta::div_shiftsub::reset_div  reset_div_0(.output__(_e_6161));
    assign _e_6163 = \r [134];
    assign _e_6165 = _e_6163;
    assign _e_9864 = _e_6163 == 1'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9866 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9867 = 1;
    assign _e_9868 = _e_9866 && _e_9867;
    assign _e_9870 = \set_op_a [32] == 1'd0;
    assign _e_6173 = \r [133:102];
    always_comb begin
        priority casez ({_e_9868, _e_9870})
            2'b1?: \next_dividend  = \val ;
            2'b01: \next_dividend  = _e_6173;
            2'b?: \next_dividend  = 32'dx;
        endcase
    end
    assign \divisor  = \trig [31:0];
    assign _e_9872 = \trig [32] == 1'd1;
    localparam[0:0] _e_9873 = 1;
    assign _e_9874 = _e_9872 && _e_9873;
    assign _e_6181 = {1'd1};
    localparam[31:0] _e_6184 = 32'd0;
    localparam[31:0] _e_6185 = 32'd0;
    localparam[5:0] _e_6186 = 0;
    assign _e_6180 = {_e_6181, \next_dividend , \divisor , _e_6184, _e_6185, _e_6186};
    assign _e_9876 = \trig [32] == 1'd0;
    assign _e_6189 = {1'd0};
    localparam[31:0] _e_6191 = 32'd0;
    localparam[31:0] _e_6192 = 32'd0;
    localparam[31:0] _e_6193 = 32'd0;
    localparam[5:0] _e_6194 = 0;
    assign _e_6188 = {_e_6189, \next_dividend , _e_6191, _e_6192, _e_6193, _e_6194};
    always_comb begin
        priority casez ({_e_9874, _e_9876})
            2'b1?: _e_6176 = _e_6180;
            2'b01: _e_6176 = _e_6188;
            2'b?: _e_6176 = 135'dx;
        endcase
    end
    assign _e_6195 = _e_6163;
    assign _e_9878 = _e_6163 == 1'd1;
    assign _e_6198 = \r [133:102];
    localparam[31:0] _e_6200 = 32'd31;
    assign \msb_dividend  = _e_6198 >> _e_6200;
    assign _e_6204 = \r [69:38];
    localparam[31:0] _e_6206 = 32'd1;
    assign _e_6203 = _e_6204 << _e_6206;
    assign \rem_shifted  = _e_6203 | \msb_dividend ;
    assign _e_6210 = \r [133:102];
    localparam[31:0] _e_6212 = 32'd1;
    assign \dvd_shifted  = _e_6210 << _e_6212;
    assign _e_6216 = \r [101:70];
    assign \can_sub  = \rem_shifted  >= _e_6216;
    assign _e_6226 = \r [101:70];
    assign _e_6224 = \rem_shifted  - _e_6226;
    assign _e_6223 = _e_6224[31:0];
    localparam[31:0] _e_6228 = 32'd1;
    assign _e_6222 = {_e_6223, _e_6228};
    localparam[31:0] _e_6232 = 32'd0;
    assign _e_6230 = {\rem_shifted , _e_6232};
    assign _e_6235 = \can_sub  ? _e_6222 : _e_6230;
    assign \next_rem  = _e_6235[63:32];
    assign \quot_bit  = _e_6235[31:0];
    assign _e_6238 = \r [37:6];
    localparam[31:0] _e_6240 = 32'd1;
    assign _e_6237 = _e_6238 << _e_6240;
    assign \next_quot  = _e_6237 | \quot_bit ;
    assign _e_6245 = \r [5:0];
    localparam[5:0] _e_6247 = 31;
    assign _e_6244 = _e_6245 == _e_6247;
    (* src = "src/div_shiftsub.spade:70,17" *)
    \tta::div_shiftsub::reset_div  reset_div_1(.output__(_e_6249));
    assign _e_6252 = {1'd1};
    assign _e_6254 = \r [101:70];
    assign _e_6260 = \r [5:0];
    localparam[5:0] _e_6262 = 1;
    assign _e_6259 = _e_6260 + _e_6262;
    assign _e_6258 = _e_6259[5:0];
    assign _e_6251 = {_e_6252, \dvd_shifted , _e_6254, \next_rem , \next_quot , _e_6258};
    assign _e_6243 = _e_6244 ? _e_6249 : _e_6251;
    always_comb begin
        priority casez ({_e_9864, _e_9878})
            2'b1?: _e_6162 = _e_6176;
            2'b01: _e_6162 = _e_6243;
            2'b?: _e_6162 = 135'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_6161;
        end
        else begin
            \r  <= _e_6162;
        end
    end
    assign _e_6264 = \r [134];
    assign _e_6266 = _e_6264;
    assign _e_9880 = _e_6264 == 1'd1;
    assign _e_6270 = \r [5:0];
    localparam[5:0] _e_6272 = 31;
    assign _e_6269 = _e_6270 == _e_6272;
    assign _e_6275 = \r [133:102];
    localparam[31:0] _e_6277 = 32'd31;
    assign msb_dividend_n1 = _e_6275 >> _e_6277;
    assign _e_6281 = \r [69:38];
    localparam[31:0] _e_6283 = 32'd1;
    assign _e_6280 = _e_6281 << _e_6283;
    assign rem_shifted_n1 = _e_6280 | msb_dividend_n1;
    assign _e_6288 = \r [101:70];
    assign can_sub_n1 = rem_shifted_n1 >= _e_6288;
    localparam[31:0] _e_6294 = 32'd1;
    localparam[31:0] _e_6296 = 32'd0;
    assign quot_bit_n1 = can_sub_n1 ? _e_6294 : _e_6296;
    assign _e_6301 = \r [37:6];
    localparam[31:0] _e_6303 = 32'd1;
    assign _e_6300 = _e_6301 << _e_6303;
    assign _e_6299 = _e_6300 | quot_bit_n1;
    assign _e_6298 = {1'd1, _e_6299};
    assign _e_6306 = {1'd0, 32'bX};
    assign _e_6268 = _e_6269 ? _e_6298 : _e_6306;
    assign \_  = _e_6264;
    localparam[0:0] _e_9881 = 1;
    assign _e_6308 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9880, _e_9881})
            2'b1?: _e_6263 = _e_6268;
            2'b01: _e_6263 = _e_6308;
            2'b?: _e_6263 = 33'dx;
        endcase
    end
    assign output__ = _e_6263;
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
    logic[42:0] _e_6313;
    (* src = "src/div_shiftsub.spade:103,10" *)
    logic[31:0] \x ;
    logic _e_9883;
    logic _e_9885;
    logic _e_9887;
    logic _e_9888;
    (* src = "src/div_shiftsub.spade:103,31" *)
    logic[32:0] _e_6315;
    (* src = "src/div_shiftsub.spade:104,5" *)
    logic[43:0] \_ ;
    (* src = "src/div_shiftsub.spade:104,21" *)
    logic[42:0] _e_6321;
    (* src = "src/div_shiftsub.spade:104,26" *)
    logic[31:0] x_n1;
    logic _e_9891;
    logic _e_9893;
    logic _e_9895;
    logic _e_9896;
    (* src = "src/div_shiftsub.spade:104,47" *)
    logic[32:0] _e_6323;
    (* src = "src/div_shiftsub.spade:104,56" *)
    logic[43:0] __n1;
    (* src = "src/div_shiftsub.spade:104,61" *)
    logic[32:0] _e_6326;
    (* src = "src/div_shiftsub.spade:104,10" *)
    logic[32:0] _e_6318;
    (* src = "src/div_shiftsub.spade:102,3" *)
    logic[32:0] _e_6310;
    assign _e_6313 = \m1 [42:0];
    assign \x  = _e_6313[36:5];
    assign _e_9883 = \m1 [43] == 1'd1;
    assign _e_9885 = _e_6313[42:37] == 6'd21;
    localparam[0:0] _e_9886 = 1;
    assign _e_9887 = _e_9885 && _e_9886;
    assign _e_9888 = _e_9883 && _e_9887;
    assign _e_6315 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9889 = 1;
    assign _e_6321 = \m0 [42:0];
    assign x_n1 = _e_6321[36:5];
    assign _e_9891 = \m0 [43] == 1'd1;
    assign _e_9893 = _e_6321[42:37] == 6'd21;
    localparam[0:0] _e_9894 = 1;
    assign _e_9895 = _e_9893 && _e_9894;
    assign _e_9896 = _e_9891 && _e_9895;
    assign _e_6323 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9897 = 1;
    assign _e_6326 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9896, _e_9897})
            2'b1?: _e_6318 = _e_6323;
            2'b01: _e_6318 = _e_6326;
            2'b?: _e_6318 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9888, _e_9889})
            2'b1?: _e_6310 = _e_6315;
            2'b01: _e_6310 = _e_6318;
            2'b?: _e_6310 = 33'dx;
        endcase
    end
    assign output__ = _e_6310;
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
    logic[42:0] _e_6331;
    (* src = "src/div_shiftsub.spade:110,10" *)
    logic[31:0] \x ;
    logic _e_9899;
    logic _e_9901;
    logic _e_9903;
    logic _e_9904;
    (* src = "src/div_shiftsub.spade:110,31" *)
    logic[32:0] _e_6333;
    (* src = "src/div_shiftsub.spade:111,5" *)
    logic[43:0] \_ ;
    (* src = "src/div_shiftsub.spade:111,21" *)
    logic[42:0] _e_6339;
    (* src = "src/div_shiftsub.spade:111,26" *)
    logic[31:0] x_n1;
    logic _e_9907;
    logic _e_9909;
    logic _e_9911;
    logic _e_9912;
    (* src = "src/div_shiftsub.spade:111,47" *)
    logic[32:0] _e_6341;
    (* src = "src/div_shiftsub.spade:111,56" *)
    logic[43:0] __n1;
    (* src = "src/div_shiftsub.spade:111,61" *)
    logic[32:0] _e_6344;
    (* src = "src/div_shiftsub.spade:111,10" *)
    logic[32:0] _e_6336;
    (* src = "src/div_shiftsub.spade:109,3" *)
    logic[32:0] _e_6328;
    assign _e_6331 = \m1 [42:0];
    assign \x  = _e_6331[36:5];
    assign _e_9899 = \m1 [43] == 1'd1;
    assign _e_9901 = _e_6331[42:37] == 6'd22;
    localparam[0:0] _e_9902 = 1;
    assign _e_9903 = _e_9901 && _e_9902;
    assign _e_9904 = _e_9899 && _e_9903;
    assign _e_6333 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9905 = 1;
    assign _e_6339 = \m0 [42:0];
    assign x_n1 = _e_6339[36:5];
    assign _e_9907 = \m0 [43] == 1'd1;
    assign _e_9909 = _e_6339[42:37] == 6'd22;
    localparam[0:0] _e_9910 = 1;
    assign _e_9911 = _e_9909 && _e_9910;
    assign _e_9912 = _e_9907 && _e_9911;
    assign _e_6341 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9913 = 1;
    assign _e_6344 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9912, _e_9913})
            2'b1?: _e_6336 = _e_6341;
            2'b01: _e_6336 = _e_6344;
            2'b?: _e_6336 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9904, _e_9905})
            2'b1?: _e_6328 = _e_6333;
            2'b01: _e_6328 = _e_6336;
            2'b?: _e_6328 = 33'dx;
        endcase
    end
    assign output__ = _e_6328;
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
    logic _e_9915;
    logic _e_9917;
    (* src = "src/boot_imem_subsystem.spade:35,18" *)
    logic[8:0] _e_6350;
    logic _e_9919;
    (* src = "src/boot_imem_subsystem.spade:36,18" *)
    logic[8:0] _e_6354;
    (* src = "src/boot_imem_subsystem.spade:34,5" *)
    logic[8:0] _e_6359;
    (* src = "src/boot_imem_subsystem.spade:33,7" *)
    logic \byte_valid ;
    (* src = "src/boot_imem_subsystem.spade:33,7" *)
    logic[7:0] \byte ;
    (* src = "src/boot_imem_subsystem.spade:41,12" *)
    logic[88:0] \bl ;
    (* src = "src/boot_imem_subsystem.spade:44,25" *)
    logic _e_6368;
    (* src = "src/boot_imem_subsystem.spade:44,18" *)
    logic \core_rst ;
    (* src = "src/boot_imem_subsystem.spade:47,43" *)
    logic _e_6375;
    (* src = "src/boot_imem_subsystem.spade:47,12" *)
    reg \boot_q ;
    (* src = "src/boot_imem_subsystem.spade:48,36" *)
    logic _e_6380;
    (* src = "src/boot_imem_subsystem.spade:48,35" *)
    logic _e_6379;
    (* src = "src/boot_imem_subsystem.spade:48,25" *)
    logic \boot_fall ;
    (* src = "src/boot_imem_subsystem.spade:51,23" *)
    logic[10:0] _e_6386;
    (* src = "src/boot_imem_subsystem.spade:51,11" *)
    logic[11:0] _e_6384;
    (* src = "src/boot_imem_subsystem.spade:52,7" *)
    logic[11:0] _e_6391;
    (* src = "src/boot_imem_subsystem.spade:52,7" *)
    logic _e_6388;
    (* src = "src/boot_imem_subsystem.spade:52,7" *)
    logic[10:0] _e_6390;
    (* src = "src/boot_imem_subsystem.spade:52,14" *)
    logic[9:0] \e ;
    logic _e_9923;
    logic _e_9925;
    logic _e_9926;
    (* src = "src/boot_imem_subsystem.spade:52,26" *)
    logic[10:0] _e_6392;
    (* src = "src/boot_imem_subsystem.spade:53,7" *)
    logic[11:0] \_ ;
    (* src = "src/boot_imem_subsystem.spade:53,27" *)
    logic[10:0] _e_6395;
    (* src = "src/boot_imem_subsystem.spade:51,5" *)
    logic[10:0] \pc_release ;
    (* src = "src/boot_imem_subsystem.spade:60,13" *)
    logic[97:0] _e_6400;
    logic _e_9929;
    (* src = "src/boot_imem_subsystem.spade:66,11" *)
    logic[10:0] _e_6410;
    (* src = "src/boot_imem_subsystem.spade:66,23" *)
    logic[32:0] _e_6412;
    (* src = "src/boot_imem_subsystem.spade:66,36" *)
    logic[32:0] _e_6414;
    (* src = "src/boot_imem_subsystem.spade:62,13" *)
    logic[98:0] _e_6404;
    (* src = "src/boot_imem_subsystem.spade:68,11" *)
    logic[98:0] _e_6417;
    (* src = "src/boot_imem_subsystem.spade:68,11" *)
    logic[97:0] \v ;
    logic _e_9931;
    logic _e_9933;
    (* src = "src/boot_imem_subsystem.spade:69,11" *)
    logic[98:0] _e_6419;
    logic _e_9935;
    (* src = "src/boot_imem_subsystem.spade:69,19" *)
    logic[97:0] _e_6420;
    (* src = "src/boot_imem_subsystem.spade:62,7" *)
    logic[97:0] _e_6403;
    (* src = "src/boot_imem_subsystem.spade:59,15" *)
    logic[97:0] \instr ;
    (* src = "src/boot_imem_subsystem.spade:74,3" *)
    logic[109:0] _e_6422;
    assign \b  = \rx_opt [7:0];
    assign _e_9915 = \rx_opt [8] == 1'd1;
    localparam[0:0] _e_9916 = 1;
    assign _e_9917 = _e_9915 && _e_9916;
    localparam[0:0] _e_6351 = 1;
    assign _e_6350 = {_e_6351, \b };
    assign _e_9919 = \rx_opt [8] == 1'd0;
    localparam[0:0] _e_6355 = 0;
    localparam[7:0] _e_6356 = 0;
    assign _e_6354 = {_e_6355, _e_6356};
    always_comb begin
        priority casez ({_e_9917, _e_9919})
            2'b1?: _e_6359 = _e_6350;
            2'b01: _e_6359 = _e_6354;
            2'b?: _e_6359 = 9'dx;
        endcase
    end
    assign \byte_valid  = _e_6359[8];
    assign \byte  = _e_6359[7:0];
    (* src = "src/boot_imem_subsystem.spade:41,12" *)
    \tta::bootloader::bootloader  bootloader_0(.clk_i(\clk ), .rst_i(\rst ), .byte_valid_i(\byte_valid ), .byte_i(\byte ), .output__(\bl ));
    assign _e_6368 = \bl [88];
    assign \core_rst  = \rst  || _e_6368;
    localparam[0:0] _e_6374 = 1;
    assign _e_6375 = \bl [88];
    always @(posedge \clk ) begin
        if (\rst ) begin
            \boot_q  <= _e_6374;
        end
        else begin
            \boot_q  <= _e_6375;
        end
    end
    assign _e_6380 = \bl [88];
    assign _e_6379 = !_e_6380;
    assign \boot_fall  = \boot_q  && _e_6379;
    assign _e_6386 = \bl [10:0];
    assign _e_6384 = {\boot_fall , _e_6386};
    assign _e_6391 = _e_6384;
    assign _e_6388 = _e_6384[11];
    assign _e_6390 = _e_6384[10:0];
    assign \e  = _e_6390[9:0];
    assign _e_9923 = _e_6390[10] == 1'd1;
    localparam[0:0] _e_9924 = 1;
    assign _e_9925 = _e_9923 && _e_9924;
    assign _e_9926 = _e_6388 && _e_9925;
    assign _e_6392 = {1'd1, \e };
    assign \_  = _e_6384;
    localparam[0:0] _e_9927 = 1;
    assign _e_6395 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_9926, _e_9927})
            2'b1?: \pc_release  = _e_6392;
            2'b01: \pc_release  = _e_6395;
            2'b?: \pc_release  = 11'dx;
        endcase
    end
    (* src = "src/boot_imem_subsystem.spade:60,13" *)
    \tta::boot_imem_subsystem::no_op  no_op_0(.output__(_e_6400));
    assign _e_9929 = !\boot_q ;
    assign _e_6410 = \bl [87:77];
    assign _e_6412 = \bl [76:44];
    assign _e_6414 = \bl [43:11];
    (* src = "src/boot_imem_subsystem.spade:62,13" *)
    \tta::imem::imem  imem_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .boot_mode_i(\boot_q ), .fetch_pc_i(\fetch_pc ), .wr_addr_i(_e_6410), .wr_slot0_i(_e_6412), .wr_slot1_i(_e_6414), .output__(_e_6404));
    assign _e_6417 = _e_6404;
    assign \v  = _e_6404[97:0];
    assign _e_9931 = _e_6404[98] == 1'd1;
    localparam[0:0] _e_9932 = 1;
    assign _e_9933 = _e_9931 && _e_9932;
    assign _e_6419 = _e_6404;
    assign _e_9935 = _e_6404[98] == 1'd0;
    (* src = "src/boot_imem_subsystem.spade:69,19" *)
    \tta::boot_imem_subsystem::no_op  no_op_1(.output__(_e_6420));
    always_comb begin
        priority casez ({_e_9933, _e_9935})
            2'b1?: _e_6403 = \v ;
            2'b01: _e_6403 = _e_6420;
            2'b?: _e_6403 = 98'dx;
        endcase
    end
    always_comb begin
        priority casez ({\boot_q , _e_9929})
            2'b1?: \instr  = _e_6400;
            2'b01: \instr  = _e_6403;
            2'b?: \instr  = 98'dx;
        endcase
    end
    assign _e_6422 = {\core_rst , \instr , \pc_release };
    assign output__ = _e_6422;
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
    logic[36:0] _e_6429;
    (* src = "src/boot_imem_subsystem.spade:80,27" *)
    logic[10:0] _e_6430;
    (* src = "src/boot_imem_subsystem.spade:80,11" *)
    logic[48:0] _e_6428;
    (* src = "src/boot_imem_subsystem.spade:81,16" *)
    logic[36:0] _e_6433;
    (* src = "src/boot_imem_subsystem.spade:81,27" *)
    logic[10:0] _e_6434;
    (* src = "src/boot_imem_subsystem.spade:81,11" *)
    logic[48:0] _e_6432;
    (* src = "src/boot_imem_subsystem.spade:79,3" *)
    logic[97:0] _e_6427;
    assign _e_6429 = {5'd6, 32'bX};
    assign _e_6430 = {7'd2, 4'bX};
    localparam[0:0] _e_6431 = 0;
    assign _e_6428 = {_e_6429, _e_6430, _e_6431};
    assign _e_6433 = {5'd6, 32'bX};
    assign _e_6434 = {7'd2, 4'bX};
    localparam[0:0] _e_6435 = 0;
    assign _e_6432 = {_e_6433, _e_6434, _e_6435};
    assign _e_6427 = {_e_6428, _e_6432};
    assign output__ = _e_6427;
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
    logic[32:0] _e_6440;
    (* src = "src/tanh.spade:19,9" *)
    logic[31:0] \val_32 ;
    logic _e_9937;
    logic _e_9939;
    (* src = "src/tanh.spade:21,37" *)
    logic[15:0] \val_u16 ;
    (* src = "src/tanh.spade:22,30" *)
    logic[15:0] \x ;
    (* src = "src/tanh.spade:24,33" *)
    logic[16:0] \x_17 ;
    (* src = "src/tanh.spade:25,26" *)
    logic \is_neg ;
    (* src = "src/tanh.spade:28,53" *)
    logic[16:0] _e_6464;
    (* src = "src/tanh.spade:28,49" *)
    logic[17:0] _e_6462;
    (* src = "src/tanh.spade:28,73" *)
    logic[17:0] _e_6467;
    (* src = "src/tanh.spade:28,37" *)
    logic[17:0] \abs_x_18 ;
    (* src = "src/tanh.spade:29,34" *)
    logic[16:0] \abs_x ;
    (* src = "src/tanh.spade:34,37" *)
    logic _e_6474;
    (* src = "src/tanh.spade:44,43" *)
    logic[16:0] _e_6481;
    (* src = "src/tanh.spade:44,38" *)
    logic[17:0] \term1 ;
    (* src = "src/tanh.spade:45,21" *)
    logic[17:0] \term2 ;
    (* src = "src/tanh.spade:46,23" *)
    logic[18:0] _e_6488;
    (* src = "src/tanh.spade:46,17" *)
    logic[16:0] _e_6487;
    (* src = "src/tanh.spade:34,34" *)
    logic[16:0] \abs_y ;
    (* src = "src/tanh.spade:51,49" *)
    logic[16:0] _e_6497;
    (* src = "src/tanh.spade:51,45" *)
    logic[17:0] _e_6495;
    (* src = "src/tanh.spade:51,70" *)
    logic[17:0] _e_6500;
    (* src = "src/tanh.spade:51,33" *)
    logic[17:0] \y_18 ;
    (* src = "src/tanh.spade:55,33" *)
    logic[15:0] \y_16 ;
    (* src = "src/tanh.spade:59,34" *)
    logic[31:0] \y_i32 ;
    (* src = "src/tanh.spade:60,18" *)
    logic[31:0] _e_6510;
    (* src = "src/tanh.spade:60,13" *)
    logic[32:0] _e_6509;
    logic _e_9941;
    (* src = "src/tanh.spade:62,17" *)
    logic[32:0] _e_6513;
    (* src = "src/tanh.spade:18,55" *)
    logic[32:0] _e_6441;
    (* src = "src/tanh.spade:18,14" *)
    reg[32:0] \res ;
    assign _e_6440 = {1'd0, 32'bX};
    assign \val_32  = \trig [31:0];
    assign _e_9937 = \trig [32] == 1'd1;
    localparam[0:0] _e_9938 = 1;
    assign _e_9939 = _e_9937 && _e_9938;
    assign \val_u16  = \val_32 [15:0];
    (* src = "src/tanh.spade:22,30" *)
    \std::conv::impl_4::to_int[2162]  to_int_0(.self_i(\val_u16 ), .output__(\x ));
    assign \x_17  = {\x [15], \x };
    localparam[16:0] _e_6457 = 0;
    assign \is_neg  = $signed(\x_17 ) < $signed(_e_6457);
    localparam[16:0] _e_6463 = 0;
    assign _e_6464 = \x_17 ;
    assign _e_6462 = $signed(_e_6463) - $signed(_e_6464);
    assign _e_6467 = {\x_17 [16], \x_17 };
    assign \abs_x_18  = \is_neg  ? _e_6462 : _e_6467;
    assign \abs_x  = \abs_x_18 [16:0];
    localparam[16:0] _e_6476 = 16384;
    assign _e_6474 = $signed(\abs_x ) < $signed(_e_6476);
    localparam[16:0] _e_6483 = 1;
    assign _e_6481 = \abs_x  >> _e_6483;
    assign \term1  = {_e_6481[16], _e_6481};
    localparam[17:0] _e_6485 = 8192;
    assign \term2  = _e_6485;
    assign _e_6488 = $signed(\term1 ) + $signed(\term2 );
    assign _e_6487 = _e_6488[16:0];
    assign \abs_y  = _e_6474 ? \abs_x  : _e_6487;
    localparam[16:0] _e_6496 = 0;
    assign _e_6497 = \abs_y ;
    assign _e_6495 = $signed(_e_6496) - $signed(_e_6497);
    assign _e_6500 = {\abs_y [16], \abs_y };
    assign \y_18  = \is_neg  ? _e_6495 : _e_6500;
    assign \y_16  = \y_18 [15:0];
    assign \y_i32  = {{ 16 { \y_16 [15] }}, \y_16 };
    (* src = "src/tanh.spade:60,18" *)
    \std::conv::impl_3::to_uint[2161]  to_uint_0(.self_i(\y_i32 ), .output__(_e_6510));
    assign _e_6509 = {1'd1, _e_6510};
    assign _e_9941 = \trig [32] == 1'd0;
    assign _e_6513 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9939, _e_9941})
            2'b1?: _e_6441 = _e_6509;
            2'b01: _e_6441 = _e_6513;
            2'b?: _e_6441 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_6440;
        end
        else begin
            \res  <= _e_6441;
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
    logic[42:0] _e_6519;
    (* src = "src/tanh.spade:72,14" *)
    logic[31:0] \a ;
    logic _e_9943;
    logic _e_9945;
    logic _e_9947;
    logic _e_9948;
    (* src = "src/tanh.spade:72,35" *)
    logic[32:0] _e_6521;
    (* src = "src/tanh.spade:73,9" *)
    logic[43:0] \_ ;
    (* src = "src/tanh.spade:73,25" *)
    logic[42:0] _e_6527;
    (* src = "src/tanh.spade:73,30" *)
    logic[31:0] a_n1;
    logic _e_9951;
    logic _e_9953;
    logic _e_9955;
    logic _e_9956;
    (* src = "src/tanh.spade:73,51" *)
    logic[32:0] _e_6529;
    (* src = "src/tanh.spade:73,60" *)
    logic[43:0] __n1;
    (* src = "src/tanh.spade:73,65" *)
    logic[32:0] _e_6532;
    (* src = "src/tanh.spade:73,14" *)
    logic[32:0] _e_6524;
    (* src = "src/tanh.spade:71,5" *)
    logic[32:0] _e_6516;
    assign _e_6519 = \m1 [42:0];
    assign \a  = _e_6519[36:5];
    assign _e_9943 = \m1 [43] == 1'd1;
    assign _e_9945 = _e_6519[42:37] == 6'd34;
    localparam[0:0] _e_9946 = 1;
    assign _e_9947 = _e_9945 && _e_9946;
    assign _e_9948 = _e_9943 && _e_9947;
    assign _e_6521 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9949 = 1;
    assign _e_6527 = \m0 [42:0];
    assign a_n1 = _e_6527[36:5];
    assign _e_9951 = \m0 [43] == 1'd1;
    assign _e_9953 = _e_6527[42:37] == 6'd34;
    localparam[0:0] _e_9954 = 1;
    assign _e_9955 = _e_9953 && _e_9954;
    assign _e_9956 = _e_9951 && _e_9955;
    assign _e_6529 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9957 = 1;
    assign _e_6532 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9956, _e_9957})
            2'b1?: _e_6524 = _e_6529;
            2'b01: _e_6524 = _e_6532;
            2'b?: _e_6524 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9948, _e_9949})
            2'b1?: _e_6516 = _e_6521;
            2'b01: _e_6516 = _e_6524;
            2'b?: _e_6516 = 33'dx;
        endcase
    end
    assign output__ = _e_6516;
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
    logic[51:0] _e_6539;
    (* src = "src/cc.spade:14,48" *)
    logic[50:0] _e_6538;
    (* src = "src/cc.spade:14,14" *)
    reg[50:0] \counter ;
    logic[63:0] \padded ;
    (* src = "src/cc.spade:17,37" *)
    logic[63:0] _e_6546;
    (* src = "src/cc.spade:17,31" *)
    logic[31:0] \cc_res_lo ;
    (* src = "src/cc.spade:18,39" *)
    logic[63:0] _e_6551;
    (* src = "src/cc.spade:18,33" *)
    logic[31:0] \cc_res_high ;
    (* src = "src/cc.spade:19,5" *)
    logic[63:0] _e_6555;
    localparam[50:0] _e_6537 = 51'd0;
    localparam[50:0] _e_6541 = 51'd1;
    assign _e_6539 = \counter  + _e_6541;
    assign _e_6538 = _e_6539[50:0];
    always @(posedge \clk ) begin
        if (\rst ) begin
            \counter  <= _e_6537;
        end
        else begin
            \counter  <= _e_6538;
        end
    end
    assign \padded  = {13'b0, \counter };
    localparam[63:0] _e_6548 = 64'd4294967295;
    assign _e_6546 = \padded  & _e_6548;
    assign \cc_res_lo  = _e_6546[31:0];
    localparam[63:0] _e_6553 = 64'd32;
    assign _e_6551 = \padded  >> _e_6553;
    assign \cc_res_high  = _e_6551[31:0];
    assign _e_6555 = {\cc_res_lo , \cc_res_high };
    assign output__ = _e_6555;
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
    logic _e_6560;
    (* src = "src/mul_shiftadd.spade:26,5" *)
    logic[102:0] _e_6559;
    assign _e_6560 = {1'd0};
    localparam[31:0] _e_6561 = 32'd0;
    localparam[31:0] _e_6562 = 32'd0;
    localparam[31:0] _e_6563 = 32'd0;
    localparam[5:0] _e_6564 = 0;
    assign _e_6559 = {_e_6560, _e_6561, _e_6562, _e_6563, _e_6564};
    assign output__ = _e_6559;
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
    logic[102:0] _e_6569;
    (* src = "src/mul_shiftadd.spade:35,57" *)
    logic _e_6571;
    (* src = "src/mul_shiftadd.spade:36,9" *)
    logic _e_6573;
    logic _e_9959;
    (* src = "src/mul_shiftadd.spade:39,17" *)
    logic[31:0] \val ;
    logic _e_9961;
    logic _e_9963;
    logic _e_9965;
    (* src = "src/mul_shiftadd.spade:40,25" *)
    logic[31:0] _e_6581;
    (* src = "src/mul_shiftadd.spade:38,26" *)
    logic[31:0] \next_a ;
    (* src = "src/mul_shiftadd.spade:46,17" *)
    logic[31:0] \val_b ;
    logic _e_9967;
    logic _e_9969;
    (* src = "src/mul_shiftadd.spade:46,40" *)
    logic _e_6589;
    (* src = "src/mul_shiftadd.spade:46,32" *)
    logic[102:0] _e_6588;
    logic _e_9971;
    (* src = "src/mul_shiftadd.spade:47,33" *)
    logic _e_6596;
    (* src = "src/mul_shiftadd.spade:47,25" *)
    logic[102:0] _e_6595;
    (* src = "src/mul_shiftadd.spade:45,13" *)
    logic[102:0] _e_6584;
    (* src = "src/mul_shiftadd.spade:50,9" *)
    logic _e_6601;
    logic _e_9973;
    (* src = "src/mul_shiftadd.spade:52,27" *)
    logic[31:0] _e_6605;
    (* src = "src/mul_shiftadd.spade:52,26" *)
    logic[31:0] _e_6604;
    (* src = "src/mul_shiftadd.spade:52,26" *)
    logic \do_add ;
    (* src = "src/mul_shiftadd.spade:53,46" *)
    logic[31:0] _e_6613;
    (* src = "src/mul_shiftadd.spade:53,34" *)
    logic[31:0] \current_addend ;
    (* src = "src/mul_shiftadd.spade:54,34" *)
    logic[31:0] _e_6620;
    (* src = "src/mul_shiftadd.spade:54,34" *)
    logic[32:0] _e_6619;
    (* src = "src/mul_shiftadd.spade:54,28" *)
    logic[31:0] \next_acc ;
    (* src = "src/mul_shiftadd.spade:56,26" *)
    logic[31:0] _e_6625;
    (* src = "src/mul_shiftadd.spade:56,26" *)
    logic[31:0] next_a_n1;
    (* src = "src/mul_shiftadd.spade:57,26" *)
    logic[31:0] _e_6630;
    (* src = "src/mul_shiftadd.spade:57,26" *)
    logic[31:0] \next_b ;
    (* src = "src/mul_shiftadd.spade:59,16" *)
    logic[5:0] _e_6636;
    (* src = "src/mul_shiftadd.spade:59,16" *)
    logic _e_6635;
    (* src = "src/mul_shiftadd.spade:61,17" *)
    logic[102:0] _e_6640;
    (* src = "src/mul_shiftadd.spade:63,25" *)
    logic _e_6643;
    (* src = "src/mul_shiftadd.spade:63,70" *)
    logic[5:0] _e_6649;
    (* src = "src/mul_shiftadd.spade:63,70" *)
    logic[6:0] _e_6648;
    (* src = "src/mul_shiftadd.spade:63,64" *)
    logic[5:0] _e_6647;
    (* src = "src/mul_shiftadd.spade:63,17" *)
    logic[102:0] _e_6642;
    (* src = "src/mul_shiftadd.spade:59,13" *)
    logic[102:0] _e_6634;
    (* src = "src/mul_shiftadd.spade:35,51" *)
    logic[102:0] _e_6570;
    (* src = "src/mul_shiftadd.spade:35,14" *)
    reg[102:0] \r ;
    (* src = "src/mul_shiftadd.spade:69,11" *)
    logic _e_6653;
    (* src = "src/mul_shiftadd.spade:70,9" *)
    logic _e_6655;
    logic _e_9975;
    (* src = "src/mul_shiftadd.spade:71,16" *)
    logic[5:0] _e_6659;
    (* src = "src/mul_shiftadd.spade:71,16" *)
    logic _e_6658;
    (* src = "src/mul_shiftadd.spade:73,31" *)
    logic[31:0] _e_6665;
    (* src = "src/mul_shiftadd.spade:73,30" *)
    logic[31:0] _e_6664;
    (* src = "src/mul_shiftadd.spade:73,30" *)
    logic do_add_n1;
    (* src = "src/mul_shiftadd.spade:74,50" *)
    logic[31:0] _e_6673;
    (* src = "src/mul_shiftadd.spade:74,38" *)
    logic[31:0] current_addend_n1;
    (* src = "src/mul_shiftadd.spade:75,28" *)
    logic[31:0] _e_6681;
    (* src = "src/mul_shiftadd.spade:75,28" *)
    logic[32:0] _e_6680;
    (* src = "src/mul_shiftadd.spade:75,22" *)
    logic[31:0] _e_6679;
    (* src = "src/mul_shiftadd.spade:75,17" *)
    logic[32:0] _e_6678;
    (* src = "src/mul_shiftadd.spade:77,17" *)
    logic[32:0] _e_6685;
    (* src = "src/mul_shiftadd.spade:71,13" *)
    logic[32:0] _e_6657;
    (* src = "src/mul_shiftadd.spade:80,9" *)
    logic \_ ;
    (* src = "src/mul_shiftadd.spade:80,14" *)
    logic[32:0] _e_6687;
    (* src = "src/mul_shiftadd.spade:69,5" *)
    logic[32:0] _e_6652;
    (* src = "src/mul_shiftadd.spade:35,36" *)
    \tta::mul_shiftadd::reset_mul  reset_mul_0(.output__(_e_6569));
    assign _e_6571 = \r [102];
    assign _e_6573 = _e_6571;
    assign _e_9959 = _e_6571 == 1'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9961 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9962 = 1;
    assign _e_9963 = _e_9961 && _e_9962;
    assign _e_9965 = \set_op_a [32] == 1'd0;
    assign _e_6581 = \r [101:70];
    always_comb begin
        priority casez ({_e_9963, _e_9965})
            2'b1?: \next_a  = \val ;
            2'b01: \next_a  = _e_6581;
            2'b?: \next_a  = 32'dx;
        endcase
    end
    assign \val_b  = \trig [31:0];
    assign _e_9967 = \trig [32] == 1'd1;
    localparam[0:0] _e_9968 = 1;
    assign _e_9969 = _e_9967 && _e_9968;
    assign _e_6589 = {1'd1};
    localparam[31:0] _e_6592 = 32'd0;
    localparam[5:0] _e_6593 = 0;
    assign _e_6588 = {_e_6589, \next_a , \val_b , _e_6592, _e_6593};
    assign _e_9971 = \trig [32] == 1'd0;
    assign _e_6596 = {1'd0};
    localparam[31:0] _e_6598 = 32'd0;
    localparam[31:0] _e_6599 = 32'd0;
    localparam[5:0] _e_6600 = 0;
    assign _e_6595 = {_e_6596, \next_a , _e_6598, _e_6599, _e_6600};
    always_comb begin
        priority casez ({_e_9969, _e_9971})
            2'b1?: _e_6584 = _e_6588;
            2'b01: _e_6584 = _e_6595;
            2'b?: _e_6584 = 103'dx;
        endcase
    end
    assign _e_6601 = _e_6571;
    assign _e_9973 = _e_6571 == 1'd1;
    assign _e_6605 = \r [69:38];
    localparam[31:0] _e_6607 = 32'd1;
    assign _e_6604 = _e_6605 & _e_6607;
    localparam[31:0] _e_6608 = 32'd1;
    assign \do_add  = _e_6604 == _e_6608;
    assign _e_6613 = \r [101:70];
    localparam[31:0] _e_6616 = 32'd0;
    assign \current_addend  = \do_add  ? _e_6613 : _e_6616;
    assign _e_6620 = \r [37:6];
    assign _e_6619 = _e_6620 + \current_addend ;
    assign \next_acc  = _e_6619[31:0];
    assign _e_6625 = \r [101:70];
    localparam[31:0] _e_6627 = 32'd1;
    assign next_a_n1 = _e_6625 << _e_6627;
    assign _e_6630 = \r [69:38];
    localparam[31:0] _e_6632 = 32'd1;
    assign \next_b  = _e_6630 >> _e_6632;
    assign _e_6636 = \r [5:0];
    localparam[5:0] _e_6638 = 31;
    assign _e_6635 = _e_6636 == _e_6638;
    (* src = "src/mul_shiftadd.spade:61,17" *)
    \tta::mul_shiftadd::reset_mul  reset_mul_1(.output__(_e_6640));
    assign _e_6643 = {1'd1};
    assign _e_6649 = \r [5:0];
    localparam[5:0] _e_6651 = 1;
    assign _e_6648 = _e_6649 + _e_6651;
    assign _e_6647 = _e_6648[5:0];
    assign _e_6642 = {_e_6643, next_a_n1, \next_b , \next_acc , _e_6647};
    assign _e_6634 = _e_6635 ? _e_6640 : _e_6642;
    always_comb begin
        priority casez ({_e_9959, _e_9973})
            2'b1?: _e_6570 = _e_6584;
            2'b01: _e_6570 = _e_6634;
            2'b?: _e_6570 = 103'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_6569;
        end
        else begin
            \r  <= _e_6570;
        end
    end
    assign _e_6653 = \r [102];
    assign _e_6655 = _e_6653;
    assign _e_9975 = _e_6653 == 1'd1;
    assign _e_6659 = \r [5:0];
    localparam[5:0] _e_6661 = 31;
    assign _e_6658 = _e_6659 == _e_6661;
    assign _e_6665 = \r [69:38];
    localparam[31:0] _e_6667 = 32'd1;
    assign _e_6664 = _e_6665 & _e_6667;
    localparam[31:0] _e_6668 = 32'd1;
    assign do_add_n1 = _e_6664 == _e_6668;
    assign _e_6673 = \r [101:70];
    localparam[31:0] _e_6676 = 32'd0;
    assign current_addend_n1 = do_add_n1 ? _e_6673 : _e_6676;
    assign _e_6681 = \r [37:6];
    assign _e_6680 = _e_6681 + current_addend_n1;
    assign _e_6679 = _e_6680[31:0];
    assign _e_6678 = {1'd1, _e_6679};
    assign _e_6685 = {1'd0, 32'bX};
    assign _e_6657 = _e_6658 ? _e_6678 : _e_6685;
    assign \_  = _e_6653;
    localparam[0:0] _e_9976 = 1;
    assign _e_6687 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9975, _e_9976})
            2'b1?: _e_6652 = _e_6657;
            2'b01: _e_6652 = _e_6687;
            2'b?: _e_6652 = 33'dx;
        endcase
    end
    assign output__ = _e_6652;
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
    logic[42:0] _e_6692;
    (* src = "src/mul_shiftadd.spade:89,10" *)
    logic[31:0] \x ;
    logic _e_9978;
    logic _e_9980;
    logic _e_9982;
    logic _e_9983;
    (* src = "src/mul_shiftadd.spade:89,31" *)
    logic[32:0] _e_6694;
    (* src = "src/mul_shiftadd.spade:90,5" *)
    logic[43:0] \_ ;
    (* src = "src/mul_shiftadd.spade:90,21" *)
    logic[42:0] _e_6700;
    (* src = "src/mul_shiftadd.spade:90,26" *)
    logic[31:0] x_n1;
    logic _e_9986;
    logic _e_9988;
    logic _e_9990;
    logic _e_9991;
    (* src = "src/mul_shiftadd.spade:90,47" *)
    logic[32:0] _e_6702;
    (* src = "src/mul_shiftadd.spade:90,56" *)
    logic[43:0] __n1;
    (* src = "src/mul_shiftadd.spade:90,61" *)
    logic[32:0] _e_6705;
    (* src = "src/mul_shiftadd.spade:90,10" *)
    logic[32:0] _e_6697;
    (* src = "src/mul_shiftadd.spade:88,3" *)
    logic[32:0] _e_6689;
    assign _e_6692 = \m1 [42:0];
    assign \x  = _e_6692[36:5];
    assign _e_9978 = \m1 [43] == 1'd1;
    assign _e_9980 = _e_6692[42:37] == 6'd16;
    localparam[0:0] _e_9981 = 1;
    assign _e_9982 = _e_9980 && _e_9981;
    assign _e_9983 = _e_9978 && _e_9982;
    assign _e_6694 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9984 = 1;
    assign _e_6700 = \m0 [42:0];
    assign x_n1 = _e_6700[36:5];
    assign _e_9986 = \m0 [43] == 1'd1;
    assign _e_9988 = _e_6700[42:37] == 6'd16;
    localparam[0:0] _e_9989 = 1;
    assign _e_9990 = _e_9988 && _e_9989;
    assign _e_9991 = _e_9986 && _e_9990;
    assign _e_6702 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9992 = 1;
    assign _e_6705 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9991, _e_9992})
            2'b1?: _e_6697 = _e_6702;
            2'b01: _e_6697 = _e_6705;
            2'b?: _e_6697 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9983, _e_9984})
            2'b1?: _e_6689 = _e_6694;
            2'b01: _e_6689 = _e_6697;
            2'b?: _e_6689 = 33'dx;
        endcase
    end
    assign output__ = _e_6689;
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
    logic[42:0] _e_6710;
    (* src = "src/mul_shiftadd.spade:96,10" *)
    logic[31:0] \x ;
    logic _e_9994;
    logic _e_9996;
    logic _e_9998;
    logic _e_9999;
    (* src = "src/mul_shiftadd.spade:96,31" *)
    logic[32:0] _e_6712;
    (* src = "src/mul_shiftadd.spade:97,5" *)
    logic[43:0] \_ ;
    (* src = "src/mul_shiftadd.spade:97,21" *)
    logic[42:0] _e_6718;
    (* src = "src/mul_shiftadd.spade:97,26" *)
    logic[31:0] x_n1;
    logic _e_10002;
    logic _e_10004;
    logic _e_10006;
    logic _e_10007;
    (* src = "src/mul_shiftadd.spade:97,47" *)
    logic[32:0] _e_6720;
    (* src = "src/mul_shiftadd.spade:97,56" *)
    logic[43:0] __n1;
    (* src = "src/mul_shiftadd.spade:97,61" *)
    logic[32:0] _e_6723;
    (* src = "src/mul_shiftadd.spade:97,10" *)
    logic[32:0] _e_6715;
    (* src = "src/mul_shiftadd.spade:95,3" *)
    logic[32:0] _e_6707;
    assign _e_6710 = \m1 [42:0];
    assign \x  = _e_6710[36:5];
    assign _e_9994 = \m1 [43] == 1'd1;
    assign _e_9996 = _e_6710[42:37] == 6'd17;
    localparam[0:0] _e_9997 = 1;
    assign _e_9998 = _e_9996 && _e_9997;
    assign _e_9999 = _e_9994 && _e_9998;
    assign _e_6712 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10000 = 1;
    assign _e_6718 = \m0 [42:0];
    assign x_n1 = _e_6718[36:5];
    assign _e_10002 = \m0 [43] == 1'd1;
    assign _e_10004 = _e_6718[42:37] == 6'd17;
    localparam[0:0] _e_10005 = 1;
    assign _e_10006 = _e_10004 && _e_10005;
    assign _e_10007 = _e_10002 && _e_10006;
    assign _e_6720 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10008 = 1;
    assign _e_6723 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10007, _e_10008})
            2'b1?: _e_6715 = _e_6720;
            2'b01: _e_6715 = _e_6723;
            2'b?: _e_6715 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9999, _e_10000})
            2'b1?: _e_6707 = _e_6712;
            2'b01: _e_6707 = _e_6715;
            2'b?: _e_6707 = 33'dx;
        endcase
    end
    assign output__ = _e_6707;
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
    logic _e_10009;
    (* src = "src/imem.spade:28,17" *)
    logic[36:0] _e_6728;
    logic _e_10011;
    (* src = "src/imem.spade:29,17" *)
    logic[36:0] _e_6731;
    logic _e_10013;
    (* src = "src/imem.spade:30,17" *)
    logic[36:0] _e_6734;
    logic _e_10015;
    (* src = "src/imem.spade:31,17" *)
    logic[36:0] _e_6737;
    logic _e_10017;
    (* src = "src/imem.spade:32,17" *)
    logic[36:0] _e_6740;
    logic _e_10019;
    (* src = "src/imem.spade:33,17" *)
    logic[36:0] _e_6743;
    logic _e_10021;
    (* src = "src/imem.spade:34,17" *)
    logic[36:0] _e_6746;
    logic _e_10023;
    (* src = "src/imem.spade:35,17" *)
    logic[36:0] _e_6749;
    logic _e_10025;
    (* src = "src/imem.spade:37,17" *)
    logic[36:0] _e_6752;
    logic _e_10027;
    (* src = "src/imem.spade:38,17" *)
    logic[36:0] _e_6754;
    logic _e_10029;
    logic[31:0] _e_6757;
    (* src = "src/imem.spade:41,17" *)
    logic[36:0] _e_6756;
    logic _e_10031;
    (* src = "src/imem.spade:44,17" *)
    logic[36:0] _e_6760;
    logic _e_10033;
    (* src = "src/imem.spade:45,17" *)
    logic[36:0] _e_6762;
    logic _e_10035;
    (* src = "src/imem.spade:46,17" *)
    logic[36:0] _e_6764;
    logic _e_10037;
    (* src = "src/imem.spade:47,17" *)
    logic[36:0] _e_6766;
    logic _e_10039;
    (* src = "src/imem.spade:48,17" *)
    logic[36:0] _e_6768;
    logic _e_10041;
    (* src = "src/imem.spade:49,17" *)
    logic[36:0] _e_6770;
    logic _e_10043;
    (* src = "src/imem.spade:50,17" *)
    logic[36:0] _e_6772;
    logic _e_10045;
    (* src = "src/imem.spade:51,17" *)
    logic[36:0] _e_6774;
    logic _e_10047;
    (* src = "src/imem.spade:52,17" *)
    logic[36:0] _e_6776;
    logic _e_10049;
    (* src = "src/imem.spade:53,17" *)
    logic[36:0] _e_6778;
    logic _e_10051;
    (* src = "src/imem.spade:54,17" *)
    logic[36:0] _e_6780;
    logic _e_10053;
    (* src = "src/imem.spade:55,17" *)
    logic[36:0] _e_6782;
    logic _e_10055;
    (* src = "src/imem.spade:56,17" *)
    logic[36:0] _e_6784;
    logic _e_10057;
    (* src = "src/imem.spade:57,17" *)
    logic[36:0] _e_6786;
    logic _e_10059;
    (* src = "src/imem.spade:58,17" *)
    logic[36:0] _e_6788;
    logic _e_10061;
    (* src = "src/imem.spade:59,17" *)
    logic[36:0] _e_6790;
    logic _e_10063;
    (* src = "src/imem.spade:60,17" *)
    logic[36:0] _e_6792;
    logic _e_10065;
    (* src = "src/imem.spade:63,17" *)
    logic[36:0] _e_6794;
    logic _e_10067;
    (* src = "src/imem.spade:64,17" *)
    logic[36:0] _e_6796;
    logic _e_10069;
    (* src = "src/imem.spade:65,17" *)
    logic[36:0] _e_6798;
    logic _e_10071;
    (* src = "src/imem.spade:68,18" *)
    logic[36:0] _e_6800;
    logic _e_10073;
    (* src = "src/imem.spade:69,18" *)
    logic[36:0] _e_6803;
    logic _e_10075;
    (* src = "src/imem.spade:70,18" *)
    logic[36:0] _e_6806;
    logic _e_10077;
    (* src = "src/imem.spade:71,18" *)
    logic[36:0] _e_6809;
    logic _e_10079;
    (* src = "src/imem.spade:72,18" *)
    logic[36:0] _e_6812;
    logic _e_10081;
    (* src = "src/imem.spade:73,18" *)
    logic[36:0] _e_6815;
    logic _e_10083;
    (* src = "src/imem.spade:74,18" *)
    logic[36:0] _e_6818;
    logic _e_10085;
    (* src = "src/imem.spade:75,18" *)
    logic[36:0] _e_6821;
    logic _e_10087;
    (* src = "src/imem.spade:77,18" *)
    logic[36:0] _e_6824;
    (* src = "src/imem.spade:80,9" *)
    logic[7:0] \_ ;
    (* src = "src/imem.spade:80,14" *)
    logic[36:0] _e_6826;
    (* src = "src/imem.spade:26,5" *)
    logic[36:0] _e_6725;
    localparam[7:0] _e_10010 = 0;
    assign _e_10009 = \t  == _e_10010;
    localparam[3:0] _e_6729 = 0;
    assign _e_6728 = {5'd0, _e_6729, 28'bX};
    localparam[7:0] _e_10012 = 1;
    assign _e_10011 = \t  == _e_10012;
    localparam[3:0] _e_6732 = 1;
    assign _e_6731 = {5'd0, _e_6732, 28'bX};
    localparam[7:0] _e_10014 = 2;
    assign _e_10013 = \t  == _e_10014;
    localparam[3:0] _e_6735 = 2;
    assign _e_6734 = {5'd0, _e_6735, 28'bX};
    localparam[7:0] _e_10016 = 3;
    assign _e_10015 = \t  == _e_10016;
    localparam[3:0] _e_6738 = 3;
    assign _e_6737 = {5'd0, _e_6738, 28'bX};
    localparam[7:0] _e_10018 = 4;
    assign _e_10017 = \t  == _e_10018;
    localparam[3:0] _e_6741 = 4;
    assign _e_6740 = {5'd0, _e_6741, 28'bX};
    localparam[7:0] _e_10020 = 5;
    assign _e_10019 = \t  == _e_10020;
    localparam[3:0] _e_6744 = 5;
    assign _e_6743 = {5'd0, _e_6744, 28'bX};
    localparam[7:0] _e_10022 = 6;
    assign _e_10021 = \t  == _e_10022;
    localparam[3:0] _e_6747 = 6;
    assign _e_6746 = {5'd0, _e_6747, 28'bX};
    localparam[7:0] _e_10024 = 7;
    assign _e_10023 = \t  == _e_10024;
    localparam[3:0] _e_6750 = 7;
    assign _e_6749 = {5'd0, _e_6750, 28'bX};
    localparam[7:0] _e_10026 = 8;
    assign _e_10025 = \t  == _e_10026;
    assign _e_6752 = {5'd6, 32'bX};
    localparam[7:0] _e_10028 = 9;
    assign _e_10027 = \t  == _e_10028;
    assign _e_6754 = {5'd3, 32'bX};
    localparam[7:0] _e_10030 = 10;
    assign _e_10029 = \t  == _e_10030;
    assign _e_6757 = {16'b0, \imm16 };
    assign _e_6756 = {5'd5, _e_6757};
    localparam[7:0] _e_10032 = 11;
    assign _e_10031 = \t  == _e_10032;
    assign _e_6760 = {5'd1, 32'bX};
    localparam[7:0] _e_10034 = 12;
    assign _e_10033 = \t  == _e_10034;
    assign _e_6762 = {5'd7, 32'bX};
    localparam[7:0] _e_10036 = 13;
    assign _e_10035 = \t  == _e_10036;
    assign _e_6764 = {5'd11, 32'bX};
    localparam[7:0] _e_10038 = 14;
    assign _e_10037 = \t  == _e_10038;
    assign _e_6766 = {5'd12, 32'bX};
    localparam[7:0] _e_10040 = 15;
    assign _e_10039 = \t  == _e_10040;
    assign _e_6768 = {5'd2, 32'bX};
    localparam[7:0] _e_10042 = 16;
    assign _e_10041 = \t  == _e_10042;
    assign _e_6770 = {5'd13, 32'bX};
    localparam[7:0] _e_10044 = 17;
    assign _e_10043 = \t  == _e_10044;
    assign _e_6772 = {5'd14, 32'bX};
    localparam[7:0] _e_10046 = 18;
    assign _e_10045 = \t  == _e_10046;
    assign _e_6774 = {5'd15, 32'bX};
    localparam[7:0] _e_10048 = 19;
    assign _e_10047 = \t  == _e_10048;
    assign _e_6776 = {5'd18, 32'bX};
    localparam[7:0] _e_10050 = 20;
    assign _e_10049 = \t  == _e_10050;
    assign _e_6778 = {5'd20, 32'bX};
    localparam[7:0] _e_10052 = 21;
    assign _e_10051 = \t  == _e_10052;
    assign _e_6780 = {5'd21, 32'bX};
    localparam[7:0] _e_10054 = 22;
    assign _e_10053 = \t  == _e_10054;
    assign _e_6782 = {5'd22, 32'bX};
    localparam[7:0] _e_10056 = 23;
    assign _e_10055 = \t  == _e_10056;
    assign _e_6784 = {5'd17, 32'bX};
    localparam[7:0] _e_10058 = 24;
    assign _e_10057 = \t  == _e_10058;
    assign _e_6786 = {5'd19, 32'bX};
    localparam[7:0] _e_10060 = 25;
    assign _e_10059 = \t  == _e_10060;
    assign _e_6788 = {5'd23, 32'bX};
    localparam[7:0] _e_10062 = 26;
    assign _e_10061 = \t  == _e_10062;
    assign _e_6790 = {5'd8, 32'bX};
    localparam[7:0] _e_10064 = 27;
    assign _e_10063 = \t  == _e_10064;
    assign _e_6792 = {5'd24, 32'bX};
    localparam[7:0] _e_10066 = 60;
    assign _e_10065 = \t  == _e_10066;
    assign _e_6794 = {5'd9, 32'bX};
    localparam[7:0] _e_10068 = 61;
    assign _e_10067 = \t  == _e_10068;
    assign _e_6796 = {5'd10, 32'bX};
    localparam[7:0] _e_10070 = 62;
    assign _e_10069 = \t  == _e_10070;
    assign _e_6798 = {5'd16, 32'bX};
    localparam[7:0] _e_10072 = 100;
    assign _e_10071 = \t  == _e_10072;
    localparam[3:0] _e_6801 = 8;
    assign _e_6800 = {5'd0, _e_6801, 28'bX};
    localparam[7:0] _e_10074 = 101;
    assign _e_10073 = \t  == _e_10074;
    localparam[3:0] _e_6804 = 9;
    assign _e_6803 = {5'd0, _e_6804, 28'bX};
    localparam[7:0] _e_10076 = 102;
    assign _e_10075 = \t  == _e_10076;
    localparam[3:0] _e_6807 = 10;
    assign _e_6806 = {5'd0, _e_6807, 28'bX};
    localparam[7:0] _e_10078 = 103;
    assign _e_10077 = \t  == _e_10078;
    localparam[3:0] _e_6810 = 11;
    assign _e_6809 = {5'd0, _e_6810, 28'bX};
    localparam[7:0] _e_10080 = 104;
    assign _e_10079 = \t  == _e_10080;
    localparam[3:0] _e_6813 = 12;
    assign _e_6812 = {5'd0, _e_6813, 28'bX};
    localparam[7:0] _e_10082 = 105;
    assign _e_10081 = \t  == _e_10082;
    localparam[3:0] _e_6816 = 13;
    assign _e_6815 = {5'd0, _e_6816, 28'bX};
    localparam[7:0] _e_10084 = 106;
    assign _e_10083 = \t  == _e_10084;
    localparam[3:0] _e_6819 = 14;
    assign _e_6818 = {5'd0, _e_6819, 28'bX};
    localparam[7:0] _e_10086 = 107;
    assign _e_10085 = \t  == _e_10086;
    localparam[3:0] _e_6822 = 15;
    assign _e_6821 = {5'd0, _e_6822, 28'bX};
    localparam[7:0] _e_10088 = 110;
    assign _e_10087 = \t  == _e_10088;
    assign _e_6824 = {5'd4, 32'bX};
    assign \_  = \t ;
    localparam[0:0] _e_10089 = 1;
    assign _e_6826 = {5'd6, 32'bX};
    always_comb begin
        priority casez ({_e_10009, _e_10011, _e_10013, _e_10015, _e_10017, _e_10019, _e_10021, _e_10023, _e_10025, _e_10027, _e_10029, _e_10031, _e_10033, _e_10035, _e_10037, _e_10039, _e_10041, _e_10043, _e_10045, _e_10047, _e_10049, _e_10051, _e_10053, _e_10055, _e_10057, _e_10059, _e_10061, _e_10063, _e_10065, _e_10067, _e_10069, _e_10071, _e_10073, _e_10075, _e_10077, _e_10079, _e_10081, _e_10083, _e_10085, _e_10087, _e_10089})
            41'b1????????????????????????????????????????: _e_6725 = _e_6728;
            41'b01???????????????????????????????????????: _e_6725 = _e_6731;
            41'b001??????????????????????????????????????: _e_6725 = _e_6734;
            41'b0001?????????????????????????????????????: _e_6725 = _e_6737;
            41'b00001????????????????????????????????????: _e_6725 = _e_6740;
            41'b000001???????????????????????????????????: _e_6725 = _e_6743;
            41'b0000001??????????????????????????????????: _e_6725 = _e_6746;
            41'b00000001?????????????????????????????????: _e_6725 = _e_6749;
            41'b000000001????????????????????????????????: _e_6725 = _e_6752;
            41'b0000000001???????????????????????????????: _e_6725 = _e_6754;
            41'b00000000001??????????????????????????????: _e_6725 = _e_6756;
            41'b000000000001?????????????????????????????: _e_6725 = _e_6760;
            41'b0000000000001????????????????????????????: _e_6725 = _e_6762;
            41'b00000000000001???????????????????????????: _e_6725 = _e_6764;
            41'b000000000000001??????????????????????????: _e_6725 = _e_6766;
            41'b0000000000000001?????????????????????????: _e_6725 = _e_6768;
            41'b00000000000000001????????????????????????: _e_6725 = _e_6770;
            41'b000000000000000001???????????????????????: _e_6725 = _e_6772;
            41'b0000000000000000001??????????????????????: _e_6725 = _e_6774;
            41'b00000000000000000001?????????????????????: _e_6725 = _e_6776;
            41'b000000000000000000001????????????????????: _e_6725 = _e_6778;
            41'b0000000000000000000001???????????????????: _e_6725 = _e_6780;
            41'b00000000000000000000001??????????????????: _e_6725 = _e_6782;
            41'b000000000000000000000001?????????????????: _e_6725 = _e_6784;
            41'b0000000000000000000000001????????????????: _e_6725 = _e_6786;
            41'b00000000000000000000000001???????????????: _e_6725 = _e_6788;
            41'b000000000000000000000000001??????????????: _e_6725 = _e_6790;
            41'b0000000000000000000000000001?????????????: _e_6725 = _e_6792;
            41'b00000000000000000000000000001????????????: _e_6725 = _e_6794;
            41'b000000000000000000000000000001???????????: _e_6725 = _e_6796;
            41'b0000000000000000000000000000001??????????: _e_6725 = _e_6798;
            41'b00000000000000000000000000000001?????????: _e_6725 = _e_6800;
            41'b000000000000000000000000000000001????????: _e_6725 = _e_6803;
            41'b0000000000000000000000000000000001???????: _e_6725 = _e_6806;
            41'b00000000000000000000000000000000001??????: _e_6725 = _e_6809;
            41'b000000000000000000000000000000000001?????: _e_6725 = _e_6812;
            41'b0000000000000000000000000000000000001????: _e_6725 = _e_6815;
            41'b00000000000000000000000000000000000001???: _e_6725 = _e_6818;
            41'b000000000000000000000000000000000000001??: _e_6725 = _e_6821;
            41'b0000000000000000000000000000000000000001?: _e_6725 = _e_6824;
            41'b00000000000000000000000000000000000000001: _e_6725 = _e_6826;
            41'b?: _e_6725 = 37'dx;
        endcase
    end
    assign output__ = _e_6725;
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
    logic _e_10090;
    (* src = "src/imem.spade:87,17" *)
    logic[10:0] _e_6831;
    logic _e_10092;
    (* src = "src/imem.spade:88,17" *)
    logic[10:0] _e_6834;
    logic _e_10094;
    (* src = "src/imem.spade:89,17" *)
    logic[10:0] _e_6837;
    logic _e_10096;
    (* src = "src/imem.spade:90,17" *)
    logic[10:0] _e_6840;
    logic _e_10098;
    (* src = "src/imem.spade:91,17" *)
    logic[10:0] _e_6843;
    logic _e_10100;
    (* src = "src/imem.spade:92,17" *)
    logic[10:0] _e_6846;
    logic _e_10102;
    (* src = "src/imem.spade:93,17" *)
    logic[10:0] _e_6849;
    logic _e_10104;
    (* src = "src/imem.spade:94,17" *)
    logic[10:0] _e_6852;
    logic _e_10106;
    (* src = "src/imem.spade:98,17" *)
    logic[10:0] _e_6855;
    logic _e_10108;
    (* src = "src/imem.spade:99,17" *)
    logic[10:0] _e_6857;
    logic _e_10110;
    (* src = "src/imem.spade:102,17" *)
    logic[10:0] _e_6859;
    logic _e_10112;
    (* src = "src/imem.spade:103,17" *)
    logic[10:0] _e_6861;
    logic _e_10114;
    (* src = "src/imem.spade:104,17" *)
    logic[10:0] _e_6863;
    logic _e_10116;
    (* src = "src/imem.spade:105,17" *)
    logic[10:0] _e_6865;
    logic _e_10118;
    (* src = "src/imem.spade:106,17" *)
    logic[10:0] _e_6867;
    logic _e_10120;
    (* src = "src/imem.spade:107,17" *)
    logic[10:0] _e_6869;
    logic _e_10122;
    (* src = "src/imem.spade:108,17" *)
    logic[10:0] _e_6871;
    logic _e_10124;
    (* src = "src/imem.spade:109,17" *)
    logic[10:0] _e_6873;
    logic _e_10126;
    (* src = "src/imem.spade:110,17" *)
    logic[10:0] _e_6875;
    logic _e_10128;
    (* src = "src/imem.spade:111,17" *)
    logic[10:0] _e_6877;
    logic _e_10130;
    (* src = "src/imem.spade:114,17" *)
    logic[10:0] _e_6879;
    logic _e_10132;
    (* src = "src/imem.spade:115,17" *)
    logic[10:0] _e_6881;
    logic _e_10134;
    (* src = "src/imem.spade:116,17" *)
    logic[10:0] _e_6883;
    logic _e_10136;
    (* src = "src/imem.spade:119,17" *)
    logic[10:0] _e_6885;
    logic _e_10138;
    (* src = "src/imem.spade:120,17" *)
    logic[10:0] _e_6887;
    logic _e_10140;
    (* src = "src/imem.spade:121,17" *)
    logic[10:0] _e_6889;
    logic _e_10142;
    (* src = "src/imem.spade:122,17" *)
    logic[10:0] _e_6891;
    logic _e_10144;
    (* src = "src/imem.spade:123,17" *)
    logic[10:0] _e_6893;
    logic _e_10146;
    (* src = "src/imem.spade:124,17" *)
    logic[10:0] _e_6895;
    logic _e_10148;
    (* src = "src/imem.spade:127,17" *)
    logic[10:0] _e_6897;
    logic _e_10150;
    (* src = "src/imem.spade:130,17" *)
    logic[10:0] _e_6899;
    logic _e_10152;
    (* src = "src/imem.spade:133,17" *)
    logic[10:0] _e_6901;
    logic _e_10154;
    (* src = "src/imem.spade:134,17" *)
    logic[10:0] _e_6903;
    logic _e_10156;
    (* src = "src/imem.spade:135,17" *)
    logic[10:0] _e_6905;
    logic _e_10158;
    (* src = "src/imem.spade:136,17" *)
    logic[10:0] _e_6907;
    logic _e_10160;
    (* src = "src/imem.spade:137,17" *)
    logic[10:0] _e_6909;
    logic _e_10162;
    (* src = "src/imem.spade:138,17" *)
    logic[10:0] _e_6911;
    logic _e_10164;
    (* src = "src/imem.spade:141,17" *)
    logic[10:0] _e_6913;
    logic _e_10166;
    (* src = "src/imem.spade:142,17" *)
    logic[10:0] _e_6915;
    logic _e_10168;
    (* src = "src/imem.spade:143,17" *)
    logic[10:0] _e_6917;
    logic _e_10170;
    (* src = "src/imem.spade:146,17" *)
    logic[10:0] _e_6919;
    logic _e_10172;
    (* src = "src/imem.spade:147,17" *)
    logic[10:0] _e_6921;
    logic _e_10174;
    (* src = "src/imem.spade:150,17" *)
    logic[10:0] _e_6923;
    logic _e_10176;
    (* src = "src/imem.spade:151,17" *)
    logic[10:0] _e_6925;
    logic _e_10178;
    (* src = "src/imem.spade:154,17" *)
    logic[10:0] _e_6927;
    logic _e_10180;
    (* src = "src/imem.spade:155,17" *)
    logic[10:0] _e_6929;
    logic _e_10182;
    (* src = "src/imem.spade:156,17" *)
    logic[10:0] _e_6931;
    logic _e_10184;
    (* src = "src/imem.spade:157,17" *)
    logic[10:0] _e_6933;
    logic _e_10186;
    (* src = "src/imem.spade:158,17" *)
    logic[10:0] _e_6935;
    logic _e_10188;
    (* src = "src/imem.spade:159,17" *)
    logic[10:0] _e_6937;
    logic _e_10190;
    (* src = "src/imem.spade:160,17" *)
    logic[10:0] _e_6939;
    logic _e_10192;
    (* src = "src/imem.spade:163,17" *)
    logic[10:0] _e_6941;
    logic _e_10194;
    (* src = "src/imem.spade:164,17" *)
    logic[10:0] _e_6943;
    logic _e_10196;
    (* src = "src/imem.spade:167,17" *)
    logic[10:0] _e_6945;
    logic _e_10198;
    (* src = "src/imem.spade:168,17" *)
    logic[10:0] _e_6947;
    logic _e_10200;
    (* src = "src/imem.spade:169,17" *)
    logic[10:0] _e_6949;
    logic _e_10202;
    (* src = "src/imem.spade:172,17" *)
    logic[10:0] _e_6951;
    logic _e_10204;
    (* src = "src/imem.spade:173,17" *)
    logic[10:0] _e_6953;
    logic _e_10206;
    (* src = "src/imem.spade:174,17" *)
    logic[10:0] _e_6955;
    logic _e_10208;
    (* src = "src/imem.spade:176,17" *)
    logic[10:0] _e_6957;
    logic _e_10210;
    (* src = "src/imem.spade:179,17" *)
    logic[10:0] _e_6959;
    logic _e_10212;
    (* src = "src/imem.spade:180,17" *)
    logic[10:0] _e_6961;
    logic _e_10214;
    (* src = "src/imem.spade:183,17" *)
    logic[10:0] _e_6963;
    logic _e_10216;
    (* src = "src/imem.spade:184,17" *)
    logic[10:0] _e_6965;
    logic _e_10218;
    (* src = "src/imem.spade:185,17" *)
    logic[10:0] _e_6967;
    logic _e_10220;
    (* src = "src/imem.spade:186,17" *)
    logic[10:0] _e_6969;
    logic _e_10222;
    (* src = "src/imem.spade:189,17" *)
    logic[10:0] _e_6971;
    logic _e_10224;
    (* src = "src/imem.spade:190,17" *)
    logic[10:0] _e_6973;
    logic _e_10226;
    (* src = "src/imem.spade:191,17" *)
    logic[10:0] _e_6975;
    logic _e_10228;
    (* src = "src/imem.spade:192,17" *)
    logic[10:0] _e_6977;
    logic _e_10230;
    (* src = "src/imem.spade:195,17" *)
    logic[10:0] _e_6979;
    logic _e_10232;
    (* src = "src/imem.spade:196,17" *)
    logic[10:0] _e_6981;
    logic _e_10234;
    (* src = "src/imem.spade:197,17" *)
    logic[10:0] _e_6983;
    logic _e_10236;
    (* src = "src/imem.spade:200,17" *)
    logic[10:0] _e_6985;
    logic _e_10238;
    (* src = "src/imem.spade:201,17" *)
    logic[10:0] _e_6987;
    logic _e_10240;
    (* src = "src/imem.spade:202,17" *)
    logic[10:0] _e_6989;
    logic _e_10242;
    (* src = "src/imem.spade:205,17" *)
    logic[10:0] _e_6991;
    logic _e_10244;
    (* src = "src/imem.spade:208,17" *)
    logic[10:0] _e_6993;
    logic _e_10246;
    (* src = "src/imem.spade:210,17" *)
    logic[10:0] _e_6995;
    logic _e_10248;
    (* src = "src/imem.spade:211,17" *)
    logic[10:0] _e_6997;
    logic _e_10250;
    (* src = "src/imem.spade:214,17" *)
    logic[10:0] _e_6999;
    logic _e_10252;
    (* src = "src/imem.spade:215,17" *)
    logic[10:0] _e_7001;
    logic _e_10254;
    (* src = "src/imem.spade:216,17" *)
    logic[10:0] _e_7003;
    logic _e_10256;
    (* src = "src/imem.spade:218,18" *)
    logic[10:0] _e_7005;
    logic _e_10258;
    (* src = "src/imem.spade:219,18" *)
    logic[10:0] _e_7008;
    logic _e_10260;
    (* src = "src/imem.spade:220,18" *)
    logic[10:0] _e_7011;
    logic _e_10262;
    (* src = "src/imem.spade:221,18" *)
    logic[10:0] _e_7014;
    logic _e_10264;
    (* src = "src/imem.spade:222,18" *)
    logic[10:0] _e_7017;
    logic _e_10266;
    (* src = "src/imem.spade:223,18" *)
    logic[10:0] _e_7020;
    logic _e_10268;
    (* src = "src/imem.spade:224,18" *)
    logic[10:0] _e_7023;
    logic _e_10270;
    (* src = "src/imem.spade:225,18" *)
    logic[10:0] _e_7026;
    (* src = "src/imem.spade:228,9" *)
    logic[7:0] \_ ;
    (* src = "src/imem.spade:228,14" *)
    logic[10:0] _e_7029;
    (* src = "src/imem.spade:85,5" *)
    logic[10:0] _e_6828;
    localparam[7:0] _e_10091 = 0;
    assign _e_10090 = \t  == _e_10091;
    localparam[3:0] _e_6832 = 0;
    assign _e_6831 = {7'd0, _e_6832};
    localparam[7:0] _e_10093 = 1;
    assign _e_10092 = \t  == _e_10093;
    localparam[3:0] _e_6835 = 1;
    assign _e_6834 = {7'd0, _e_6835};
    localparam[7:0] _e_10095 = 2;
    assign _e_10094 = \t  == _e_10095;
    localparam[3:0] _e_6838 = 2;
    assign _e_6837 = {7'd0, _e_6838};
    localparam[7:0] _e_10097 = 3;
    assign _e_10096 = \t  == _e_10097;
    localparam[3:0] _e_6841 = 3;
    assign _e_6840 = {7'd0, _e_6841};
    localparam[7:0] _e_10099 = 4;
    assign _e_10098 = \t  == _e_10099;
    localparam[3:0] _e_6844 = 4;
    assign _e_6843 = {7'd0, _e_6844};
    localparam[7:0] _e_10101 = 5;
    assign _e_10100 = \t  == _e_10101;
    localparam[3:0] _e_6847 = 5;
    assign _e_6846 = {7'd0, _e_6847};
    localparam[7:0] _e_10103 = 6;
    assign _e_10102 = \t  == _e_10103;
    localparam[3:0] _e_6850 = 6;
    assign _e_6849 = {7'd0, _e_6850};
    localparam[7:0] _e_10105 = 7;
    assign _e_10104 = \t  == _e_10105;
    localparam[3:0] _e_6853 = 7;
    assign _e_6852 = {7'd0, _e_6853};
    localparam[7:0] _e_10107 = 8;
    assign _e_10106 = \t  == _e_10107;
    assign _e_6855 = {7'd31, 4'bX};
    localparam[7:0] _e_10109 = 9;
    assign _e_10108 = \t  == _e_10109;
    assign _e_6857 = {7'd32, 4'bX};
    localparam[7:0] _e_10111 = 10;
    assign _e_10110 = \t  == _e_10111;
    assign _e_6859 = {7'd1, 4'bX};
    localparam[7:0] _e_10113 = 11;
    assign _e_10112 = \t  == _e_10113;
    assign _e_6861 = {7'd2, 4'bX};
    localparam[7:0] _e_10115 = 12;
    assign _e_10114 = \t  == _e_10115;
    assign _e_6863 = {7'd3, 4'bX};
    localparam[7:0] _e_10117 = 13;
    assign _e_10116 = \t  == _e_10117;
    assign _e_6865 = {7'd4, 4'bX};
    localparam[7:0] _e_10119 = 14;
    assign _e_10118 = \t  == _e_10119;
    assign _e_6867 = {7'd5, 4'bX};
    localparam[7:0] _e_10121 = 15;
    assign _e_10120 = \t  == _e_10121;
    assign _e_6869 = {7'd8, 4'bX};
    localparam[7:0] _e_10123 = 16;
    assign _e_10122 = \t  == _e_10123;
    assign _e_6871 = {7'd9, 4'bX};
    localparam[7:0] _e_10125 = 17;
    assign _e_10124 = \t  == _e_10125;
    assign _e_6873 = {7'd10, 4'bX};
    localparam[7:0] _e_10127 = 18;
    assign _e_10126 = \t  == _e_10127;
    assign _e_6875 = {7'd11, 4'bX};
    localparam[7:0] _e_10129 = 19;
    assign _e_10128 = \t  == _e_10129;
    assign _e_6877 = {7'd12, 4'bX};
    localparam[7:0] _e_10131 = 20;
    assign _e_10130 = \t  == _e_10131;
    assign _e_6879 = {7'd33, 4'bX};
    localparam[7:0] _e_10133 = 21;
    assign _e_10132 = \t  == _e_10133;
    assign _e_6881 = {7'd34, 4'bX};
    localparam[7:0] _e_10135 = 22;
    assign _e_10134 = \t  == _e_10135;
    assign _e_6883 = {7'd35, 4'bX};
    localparam[7:0] _e_10137 = 23;
    assign _e_10136 = \t  == _e_10137;
    assign _e_6885 = {7'd41, 4'bX};
    localparam[7:0] _e_10139 = 24;
    assign _e_10138 = \t  == _e_10139;
    assign _e_6887 = {7'd42, 4'bX};
    localparam[7:0] _e_10141 = 25;
    assign _e_10140 = \t  == _e_10141;
    assign _e_6889 = {7'd43, 4'bX};
    localparam[7:0] _e_10143 = 26;
    assign _e_10142 = \t  == _e_10143;
    assign _e_6891 = {7'd44, 4'bX};
    localparam[7:0] _e_10145 = 27;
    assign _e_10144 = \t  == _e_10145;
    assign _e_6893 = {7'd45, 4'bX};
    localparam[7:0] _e_10147 = 28;
    assign _e_10146 = \t  == _e_10147;
    assign _e_6895 = {7'd46, 4'bX};
    localparam[7:0] _e_10149 = 29;
    assign _e_10148 = \t  == _e_10149;
    assign _e_6897 = {7'd57, 4'bX};
    localparam[7:0] _e_10151 = 30;
    assign _e_10150 = \t  == _e_10151;
    assign _e_6899 = {7'd30, 4'bX};
    localparam[7:0] _e_10153 = 31;
    assign _e_10152 = \t  == _e_10153;
    assign _e_6901 = {7'd47, 4'bX};
    localparam[7:0] _e_10155 = 32;
    assign _e_10154 = \t  == _e_10155;
    assign _e_6903 = {7'd48, 4'bX};
    localparam[7:0] _e_10157 = 33;
    assign _e_10156 = \t  == _e_10157;
    assign _e_6905 = {7'd49, 4'bX};
    localparam[7:0] _e_10159 = 34;
    assign _e_10158 = \t  == _e_10159;
    assign _e_6907 = {7'd50, 4'bX};
    localparam[7:0] _e_10161 = 35;
    assign _e_10160 = \t  == _e_10161;
    assign _e_6909 = {7'd51, 4'bX};
    localparam[7:0] _e_10163 = 36;
    assign _e_10162 = \t  == _e_10163;
    assign _e_6911 = {7'd52, 4'bX};
    localparam[7:0] _e_10165 = 37;
    assign _e_10164 = \t  == _e_10165;
    assign _e_6913 = {7'd27, 4'bX};
    localparam[7:0] _e_10167 = 38;
    assign _e_10166 = \t  == _e_10167;
    assign _e_6915 = {7'd28, 4'bX};
    localparam[7:0] _e_10169 = 39;
    assign _e_10168 = \t  == _e_10169;
    assign _e_6917 = {7'd29, 4'bX};
    localparam[7:0] _e_10171 = 40;
    assign _e_10170 = \t  == _e_10171;
    assign _e_6919 = {7'd53, 4'bX};
    localparam[7:0] _e_10173 = 41;
    assign _e_10172 = \t  == _e_10173;
    assign _e_6921 = {7'd54, 4'bX};
    localparam[7:0] _e_10175 = 42;
    assign _e_10174 = \t  == _e_10175;
    assign _e_6923 = {7'd55, 4'bX};
    localparam[7:0] _e_10177 = 43;
    assign _e_10176 = \t  == _e_10177;
    assign _e_6925 = {7'd56, 4'bX};
    localparam[7:0] _e_10179 = 44;
    assign _e_10178 = \t  == _e_10179;
    assign _e_6927 = {7'd19, 4'bX};
    localparam[7:0] _e_10181 = 45;
    assign _e_10180 = \t  == _e_10181;
    assign _e_6929 = {7'd20, 4'bX};
    localparam[7:0] _e_10183 = 46;
    assign _e_10182 = \t  == _e_10183;
    assign _e_6931 = {7'd21, 4'bX};
    localparam[7:0] _e_10185 = 47;
    assign _e_10184 = \t  == _e_10185;
    assign _e_6933 = {7'd22, 4'bX};
    localparam[7:0] _e_10187 = 48;
    assign _e_10186 = \t  == _e_10187;
    assign _e_6935 = {7'd24, 4'bX};
    localparam[7:0] _e_10189 = 49;
    assign _e_10188 = \t  == _e_10189;
    assign _e_6937 = {7'd25, 4'bX};
    localparam[7:0] _e_10191 = 50;
    assign _e_10190 = \t  == _e_10191;
    assign _e_6939 = {7'd26, 4'bX};
    localparam[7:0] _e_10193 = 51;
    assign _e_10192 = \t  == _e_10193;
    assign _e_6941 = {7'd13, 4'bX};
    localparam[7:0] _e_10195 = 52;
    assign _e_10194 = \t  == _e_10195;
    assign _e_6943 = {7'd14, 4'bX};
    localparam[7:0] _e_10197 = 53;
    assign _e_10196 = \t  == _e_10197;
    assign _e_6945 = {7'd58, 4'bX};
    localparam[7:0] _e_10199 = 54;
    assign _e_10198 = \t  == _e_10199;
    assign _e_6947 = {7'd59, 4'bX};
    localparam[7:0] _e_10201 = 55;
    assign _e_10200 = \t  == _e_10201;
    assign _e_6949 = {7'd60, 4'bX};
    localparam[7:0] _e_10203 = 56;
    assign _e_10202 = \t  == _e_10203;
    assign _e_6951 = {7'd61, 4'bX};
    localparam[7:0] _e_10205 = 57;
    assign _e_10204 = \t  == _e_10205;
    assign _e_6953 = {7'd62, 4'bX};
    localparam[7:0] _e_10207 = 58;
    assign _e_10206 = \t  == _e_10207;
    assign _e_6955 = {7'd63, 4'bX};
    localparam[7:0] _e_10209 = 59;
    assign _e_10208 = \t  == _e_10209;
    assign _e_6957 = {7'd68, 4'bX};
    localparam[7:0] _e_10211 = 60;
    assign _e_10210 = \t  == _e_10211;
    assign _e_6959 = {7'd39, 4'bX};
    localparam[7:0] _e_10213 = 61;
    assign _e_10212 = \t  == _e_10213;
    assign _e_6961 = {7'd72, 4'bX};
    localparam[7:0] _e_10215 = 62;
    assign _e_10214 = \t  == _e_10215;
    assign _e_6963 = {7'd64, 4'bX};
    localparam[7:0] _e_10217 = 63;
    assign _e_10216 = \t  == _e_10217;
    assign _e_6965 = {7'd65, 4'bX};
    localparam[7:0] _e_10219 = 64;
    assign _e_10218 = \t  == _e_10219;
    assign _e_6967 = {7'd66, 4'bX};
    localparam[7:0] _e_10221 = 65;
    assign _e_10220 = \t  == _e_10221;
    assign _e_6969 = {7'd67, 4'bX};
    localparam[7:0] _e_10223 = 66;
    assign _e_10222 = \t  == _e_10223;
    assign _e_6971 = {7'd15, 4'bX};
    localparam[7:0] _e_10225 = 67;
    assign _e_10224 = \t  == _e_10225;
    assign _e_6973 = {7'd16, 4'bX};
    localparam[7:0] _e_10227 = 68;
    assign _e_10226 = \t  == _e_10227;
    assign _e_6975 = {7'd17, 4'bX};
    localparam[7:0] _e_10229 = 69;
    assign _e_10228 = \t  == _e_10229;
    assign _e_6977 = {7'd18, 4'bX};
    localparam[7:0] _e_10231 = 70;
    assign _e_10230 = \t  == _e_10231;
    assign _e_6979 = {7'd69, 4'bX};
    localparam[7:0] _e_10233 = 71;
    assign _e_10232 = \t  == _e_10233;
    assign _e_6981 = {7'd70, 4'bX};
    localparam[7:0] _e_10235 = 72;
    assign _e_10234 = \t  == _e_10235;
    assign _e_6983 = {7'd71, 4'bX};
    localparam[7:0] _e_10237 = 73;
    assign _e_10236 = \t  == _e_10237;
    assign _e_6985 = {7'd36, 4'bX};
    localparam[7:0] _e_10239 = 74;
    assign _e_10238 = \t  == _e_10239;
    assign _e_6987 = {7'd37, 4'bX};
    localparam[7:0] _e_10241 = 75;
    assign _e_10240 = \t  == _e_10241;
    assign _e_6989 = {7'd38, 4'bX};
    localparam[7:0] _e_10243 = 76;
    assign _e_10242 = \t  == _e_10243;
    assign _e_6991 = {7'd73, 4'bX};
    localparam[7:0] _e_10245 = 77;
    assign _e_10244 = \t  == _e_10245;
    assign _e_6993 = {7'd6, 4'bX};
    localparam[7:0] _e_10247 = 78;
    assign _e_10246 = \t  == _e_10247;
    assign _e_6995 = {7'd74, 4'bX};
    localparam[7:0] _e_10249 = 79;
    assign _e_10248 = \t  == _e_10249;
    assign _e_6997 = {7'd75, 4'bX};
    localparam[7:0] _e_10251 = 80;
    assign _e_10250 = \t  == _e_10251;
    assign _e_6999 = {7'd7, 4'bX};
    localparam[7:0] _e_10253 = 81;
    assign _e_10252 = \t  == _e_10253;
    assign _e_7001 = {7'd23, 4'bX};
    localparam[7:0] _e_10255 = 82;
    assign _e_10254 = \t  == _e_10255;
    assign _e_7003 = {7'd40, 4'bX};
    localparam[7:0] _e_10257 = 100;
    assign _e_10256 = \t  == _e_10257;
    localparam[3:0] _e_7006 = 8;
    assign _e_7005 = {7'd0, _e_7006};
    localparam[7:0] _e_10259 = 101;
    assign _e_10258 = \t  == _e_10259;
    localparam[3:0] _e_7009 = 9;
    assign _e_7008 = {7'd0, _e_7009};
    localparam[7:0] _e_10261 = 102;
    assign _e_10260 = \t  == _e_10261;
    localparam[3:0] _e_7012 = 10;
    assign _e_7011 = {7'd0, _e_7012};
    localparam[7:0] _e_10263 = 103;
    assign _e_10262 = \t  == _e_10263;
    localparam[3:0] _e_7015 = 11;
    assign _e_7014 = {7'd0, _e_7015};
    localparam[7:0] _e_10265 = 104;
    assign _e_10264 = \t  == _e_10265;
    localparam[3:0] _e_7018 = 12;
    assign _e_7017 = {7'd0, _e_7018};
    localparam[7:0] _e_10267 = 105;
    assign _e_10266 = \t  == _e_10267;
    localparam[3:0] _e_7021 = 13;
    assign _e_7020 = {7'd0, _e_7021};
    localparam[7:0] _e_10269 = 106;
    assign _e_10268 = \t  == _e_10269;
    localparam[3:0] _e_7024 = 14;
    assign _e_7023 = {7'd0, _e_7024};
    localparam[7:0] _e_10271 = 107;
    assign _e_10270 = \t  == _e_10271;
    localparam[3:0] _e_7027 = 15;
    assign _e_7026 = {7'd0, _e_7027};
    assign \_  = \t ;
    localparam[0:0] _e_10272 = 1;
    assign _e_7029 = {7'd1, 4'bX};
    always_comb begin
        priority casez ({_e_10090, _e_10092, _e_10094, _e_10096, _e_10098, _e_10100, _e_10102, _e_10104, _e_10106, _e_10108, _e_10110, _e_10112, _e_10114, _e_10116, _e_10118, _e_10120, _e_10122, _e_10124, _e_10126, _e_10128, _e_10130, _e_10132, _e_10134, _e_10136, _e_10138, _e_10140, _e_10142, _e_10144, _e_10146, _e_10148, _e_10150, _e_10152, _e_10154, _e_10156, _e_10158, _e_10160, _e_10162, _e_10164, _e_10166, _e_10168, _e_10170, _e_10172, _e_10174, _e_10176, _e_10178, _e_10180, _e_10182, _e_10184, _e_10186, _e_10188, _e_10190, _e_10192, _e_10194, _e_10196, _e_10198, _e_10200, _e_10202, _e_10204, _e_10206, _e_10208, _e_10210, _e_10212, _e_10214, _e_10216, _e_10218, _e_10220, _e_10222, _e_10224, _e_10226, _e_10228, _e_10230, _e_10232, _e_10234, _e_10236, _e_10238, _e_10240, _e_10242, _e_10244, _e_10246, _e_10248, _e_10250, _e_10252, _e_10254, _e_10256, _e_10258, _e_10260, _e_10262, _e_10264, _e_10266, _e_10268, _e_10270, _e_10272})
            92'b1???????????????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6831;
            92'b01??????????????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6834;
            92'b001?????????????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6837;
            92'b0001????????????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6840;
            92'b00001???????????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6843;
            92'b000001??????????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6846;
            92'b0000001?????????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6849;
            92'b00000001????????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6852;
            92'b000000001???????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6855;
            92'b0000000001??????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6857;
            92'b00000000001?????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6859;
            92'b000000000001????????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6861;
            92'b0000000000001???????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6863;
            92'b00000000000001??????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6865;
            92'b000000000000001?????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6867;
            92'b0000000000000001????????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6869;
            92'b00000000000000001???????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6871;
            92'b000000000000000001??????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6873;
            92'b0000000000000000001?????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6875;
            92'b00000000000000000001????????????????????????????????????????????????????????????????????????: _e_6828 = _e_6877;
            92'b000000000000000000001???????????????????????????????????????????????????????????????????????: _e_6828 = _e_6879;
            92'b0000000000000000000001??????????????????????????????????????????????????????????????????????: _e_6828 = _e_6881;
            92'b00000000000000000000001?????????????????????????????????????????????????????????????????????: _e_6828 = _e_6883;
            92'b000000000000000000000001????????????????????????????????????????????????????????????????????: _e_6828 = _e_6885;
            92'b0000000000000000000000001???????????????????????????????????????????????????????????????????: _e_6828 = _e_6887;
            92'b00000000000000000000000001??????????????????????????????????????????????????????????????????: _e_6828 = _e_6889;
            92'b000000000000000000000000001?????????????????????????????????????????????????????????????????: _e_6828 = _e_6891;
            92'b0000000000000000000000000001????????????????????????????????????????????????????????????????: _e_6828 = _e_6893;
            92'b00000000000000000000000000001???????????????????????????????????????????????????????????????: _e_6828 = _e_6895;
            92'b000000000000000000000000000001??????????????????????????????????????????????????????????????: _e_6828 = _e_6897;
            92'b0000000000000000000000000000001?????????????????????????????????????????????????????????????: _e_6828 = _e_6899;
            92'b00000000000000000000000000000001????????????????????????????????????????????????????????????: _e_6828 = _e_6901;
            92'b000000000000000000000000000000001???????????????????????????????????????????????????????????: _e_6828 = _e_6903;
            92'b0000000000000000000000000000000001??????????????????????????????????????????????????????????: _e_6828 = _e_6905;
            92'b00000000000000000000000000000000001?????????????????????????????????????????????????????????: _e_6828 = _e_6907;
            92'b000000000000000000000000000000000001????????????????????????????????????????????????????????: _e_6828 = _e_6909;
            92'b0000000000000000000000000000000000001???????????????????????????????????????????????????????: _e_6828 = _e_6911;
            92'b00000000000000000000000000000000000001??????????????????????????????????????????????????????: _e_6828 = _e_6913;
            92'b000000000000000000000000000000000000001?????????????????????????????????????????????????????: _e_6828 = _e_6915;
            92'b0000000000000000000000000000000000000001????????????????????????????????????????????????????: _e_6828 = _e_6917;
            92'b00000000000000000000000000000000000000001???????????????????????????????????????????????????: _e_6828 = _e_6919;
            92'b000000000000000000000000000000000000000001??????????????????????????????????????????????????: _e_6828 = _e_6921;
            92'b0000000000000000000000000000000000000000001?????????????????????????????????????????????????: _e_6828 = _e_6923;
            92'b00000000000000000000000000000000000000000001????????????????????????????????????????????????: _e_6828 = _e_6925;
            92'b000000000000000000000000000000000000000000001???????????????????????????????????????????????: _e_6828 = _e_6927;
            92'b0000000000000000000000000000000000000000000001??????????????????????????????????????????????: _e_6828 = _e_6929;
            92'b00000000000000000000000000000000000000000000001?????????????????????????????????????????????: _e_6828 = _e_6931;
            92'b000000000000000000000000000000000000000000000001????????????????????????????????????????????: _e_6828 = _e_6933;
            92'b0000000000000000000000000000000000000000000000001???????????????????????????????????????????: _e_6828 = _e_6935;
            92'b00000000000000000000000000000000000000000000000001??????????????????????????????????????????: _e_6828 = _e_6937;
            92'b000000000000000000000000000000000000000000000000001?????????????????????????????????????????: _e_6828 = _e_6939;
            92'b0000000000000000000000000000000000000000000000000001????????????????????????????????????????: _e_6828 = _e_6941;
            92'b00000000000000000000000000000000000000000000000000001???????????????????????????????????????: _e_6828 = _e_6943;
            92'b000000000000000000000000000000000000000000000000000001??????????????????????????????????????: _e_6828 = _e_6945;
            92'b0000000000000000000000000000000000000000000000000000001?????????????????????????????????????: _e_6828 = _e_6947;
            92'b00000000000000000000000000000000000000000000000000000001????????????????????????????????????: _e_6828 = _e_6949;
            92'b000000000000000000000000000000000000000000000000000000001???????????????????????????????????: _e_6828 = _e_6951;
            92'b0000000000000000000000000000000000000000000000000000000001??????????????????????????????????: _e_6828 = _e_6953;
            92'b00000000000000000000000000000000000000000000000000000000001?????????????????????????????????: _e_6828 = _e_6955;
            92'b000000000000000000000000000000000000000000000000000000000001????????????????????????????????: _e_6828 = _e_6957;
            92'b0000000000000000000000000000000000000000000000000000000000001???????????????????????????????: _e_6828 = _e_6959;
            92'b00000000000000000000000000000000000000000000000000000000000001??????????????????????????????: _e_6828 = _e_6961;
            92'b000000000000000000000000000000000000000000000000000000000000001?????????????????????????????: _e_6828 = _e_6963;
            92'b0000000000000000000000000000000000000000000000000000000000000001????????????????????????????: _e_6828 = _e_6965;
            92'b00000000000000000000000000000000000000000000000000000000000000001???????????????????????????: _e_6828 = _e_6967;
            92'b000000000000000000000000000000000000000000000000000000000000000001??????????????????????????: _e_6828 = _e_6969;
            92'b0000000000000000000000000000000000000000000000000000000000000000001?????????????????????????: _e_6828 = _e_6971;
            92'b00000000000000000000000000000000000000000000000000000000000000000001????????????????????????: _e_6828 = _e_6973;
            92'b000000000000000000000000000000000000000000000000000000000000000000001???????????????????????: _e_6828 = _e_6975;
            92'b0000000000000000000000000000000000000000000000000000000000000000000001??????????????????????: _e_6828 = _e_6977;
            92'b00000000000000000000000000000000000000000000000000000000000000000000001?????????????????????: _e_6828 = _e_6979;
            92'b000000000000000000000000000000000000000000000000000000000000000000000001????????????????????: _e_6828 = _e_6981;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000001???????????????????: _e_6828 = _e_6983;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000001??????????????????: _e_6828 = _e_6985;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000001?????????????????: _e_6828 = _e_6987;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000001????????????????: _e_6828 = _e_6989;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000001???????????????: _e_6828 = _e_6991;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000001??????????????: _e_6828 = _e_6993;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000001?????????????: _e_6828 = _e_6995;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000001????????????: _e_6828 = _e_6997;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000000001???????????: _e_6828 = _e_6999;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000000001??????????: _e_6828 = _e_7001;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000000001?????????: _e_6828 = _e_7003;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000000000001????????: _e_6828 = _e_7005;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000001???????: _e_6828 = _e_7008;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000001??????: _e_6828 = _e_7011;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000001?????: _e_6828 = _e_7014;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000001????: _e_6828 = _e_7017;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001???: _e_6828 = _e_7020;
            92'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001??: _e_6828 = _e_7023;
            92'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001?: _e_6828 = _e_7026;
            92'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001: _e_6828 = _e_7029;
            92'b?: _e_6828 = 11'dx;
        endcase
    end
    assign output__ = _e_6828;
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
    logic[31:0] _e_7033;
    (* src = "src/imem.spade:234,36" *)
    logic[31:0] _e_7032;
    (* src = "src/imem.spade:234,30" *)
    logic \guard_bit ;
    (* src = "src/imem.spade:235,23" *)
    logic \guard ;
    (* src = "src/imem.spade:237,34" *)
    logic[31:0] _e_7044;
    (* src = "src/imem.spade:237,34" *)
    logic[31:0] _e_7043;
    (* src = "src/imem.spade:237,28" *)
    logic[7:0] \src_tok ;
    (* src = "src/imem.spade:238,34" *)
    logic[31:0] _e_7051;
    (* src = "src/imem.spade:238,34" *)
    logic[31:0] _e_7050;
    (* src = "src/imem.spade:238,28" *)
    logic[7:0] \dst_tok ;
    (* src = "src/imem.spade:239,34" *)
    logic[31:0] _e_7057;
    (* src = "src/imem.spade:239,28" *)
    logic[15:0] \imm16 ;
    (* src = "src/imem.spade:241,15" *)
    logic[36:0] \src ;
    (* src = "src/imem.spade:242,15" *)
    logic[10:0] \dst ;
    (* src = "src/imem.spade:243,5" *)
    logic[48:0] _e_7068;
    localparam[31:0] _e_7035 = 32'd31;
    assign _e_7033 = \mw  >> _e_7035;
    localparam[31:0] _e_7036 = 32'd1;
    assign _e_7032 = _e_7033 & _e_7036;
    assign \guard_bit  = _e_7032[0:0];
    localparam[0:0] _e_7040 = 0;
    assign \guard  = \guard_bit  != _e_7040;
    localparam[31:0] _e_7046 = 32'd24;
    assign _e_7044 = \mw  >> _e_7046;
    localparam[31:0] _e_7047 = 32'd127;
    assign _e_7043 = _e_7044 & _e_7047;
    assign \src_tok  = _e_7043[7:0];
    localparam[31:0] _e_7053 = 32'd17;
    assign _e_7051 = \mw  >> _e_7053;
    localparam[31:0] _e_7054 = 32'd127;
    assign _e_7050 = _e_7051 & _e_7054;
    assign \dst_tok  = _e_7050[7:0];
    localparam[31:0] _e_7059 = 32'd65535;
    assign _e_7057 = \mw  & _e_7059;
    assign \imm16  = _e_7057[15:0];
    (* src = "src/imem.spade:241,15" *)
    \tta::imem::decode_src_tok  decode_src_tok_0(.t_i(\src_tok ), .imm16_i(\imm16 ), .output__(\src ));
    (* src = "src/imem.spade:242,15" *)
    \tta::imem::decode_dst_tok  decode_dst_tok_0(.t_i(\dst_tok ), .output__(\dst ));
    assign _e_7068 = {\src , \dst , \guard };
    assign output__ = _e_7068;
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
    localparam[31:0] _e_7073 = 32'd0;
    assign output__ = _e_7073;
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
    logic _e_10274;
    logic _e_10276;
    (* src = "src/imem.spade:266,23" *)
    logic[10:0] _e_7079;
    logic _e_10278;
    (* src = "src/imem.spade:267,17" *)
    logic[10:0] _e_7083;
    (* src = "src/imem.spade:265,29" *)
    logic[10:0] _e_7088;
    (* src = "src/imem.spade:265,9" *)
    logic \wren ;
    (* src = "src/imem.spade:265,9" *)
    logic[9:0] \addr_calc ;
    (* src = "src/imem.spade:270,9" *)
    logic[31:0] \instr ;
    logic _e_10280;
    logic _e_10282;
    logic _e_10284;
    (* src = "src/imem.spade:269,18" *)
    logic[31:0] \wdata0 ;
    (* src = "src/imem.spade:274,9" *)
    logic[31:0] instr_n1;
    logic _e_10286;
    logic _e_10288;
    logic _e_10290;
    (* src = "src/imem.spade:273,18" *)
    logic[31:0] \wdata1 ;
    (* src = "src/imem.spade:278,33" *)
    logic[31:0] _e_7107;
    (* src = "src/imem.spade:278,14" *)
    reg[31:0] \rdata0 ;
    (* src = "src/imem.spade:279,33" *)
    logic[31:0] _e_7115;
    (* src = "src/imem.spade:279,14" *)
    reg[31:0] \rdata1 ;
    (* src = "src/imem.spade:283,9" *)
    logic[9:0] \_ ;
    logic _e_10292;
    logic _e_10294;
    (* src = "src/imem.spade:283,20" *)
    logic[98:0] _e_7125;
    logic _e_10296;
    (* src = "src/imem.spade:286,25" *)
    logic[98:0] _e_7131;
    logic _e_10298;
    (* src = "src/imem.spade:288,31" *)
    logic[48:0] \mv0 ;
    (* src = "src/imem.spade:289,31" *)
    logic[48:0] \mv1 ;
    (* src = "src/imem.spade:290,26" *)
    logic[97:0] _e_7141;
    (* src = "src/imem.spade:290,21" *)
    logic[98:0] _e_7140;
    (* src = "src/imem.spade:285,13" *)
    logic[98:0] _e_7128;
    (* src = "src/imem.spade:282,5" *)
    logic[98:0] _e_7121;
    assign \addr  = \wr_addr [9:0];
    assign _e_10274 = \wr_addr [10] == 1'd1;
    localparam[0:0] _e_10275 = 1;
    assign _e_10276 = _e_10274 && _e_10275;
    localparam[0:0] _e_7080 = 1;
    assign _e_7079 = {_e_7080, \addr };
    assign _e_10278 = \wr_addr [10] == 1'd0;
    localparam[0:0] _e_7084 = 0;
    assign _e_7083 = {_e_7084, \fetch_pc };
    always_comb begin
        priority casez ({_e_10276, _e_10278})
            2'b1?: _e_7088 = _e_7079;
            2'b01: _e_7088 = _e_7083;
            2'b?: _e_7088 = 11'dx;
        endcase
    end
    assign \wren  = _e_7088[10];
    assign \addr_calc  = _e_7088[9:0];
    assign \instr  = \wr_slot0 [31:0];
    assign _e_10280 = \wr_slot0 [32] == 1'd1;
    localparam[0:0] _e_10281 = 1;
    assign _e_10282 = _e_10280 && _e_10281;
    assign _e_10284 = \wr_slot0 [32] == 1'd0;
    localparam[31:0] _e_7095 = 32'd0;
    always_comb begin
        priority casez ({_e_10282, _e_10284})
            2'b1?: \wdata0  = \instr ;
            2'b01: \wdata0  = _e_7095;
            2'b?: \wdata0  = 32'dx;
        endcase
    end
    assign instr_n1 = \wr_slot1 [31:0];
    assign _e_10286 = \wr_slot1 [32] == 1'd1;
    localparam[0:0] _e_10287 = 1;
    assign _e_10288 = _e_10286 && _e_10287;
    assign _e_10290 = \wr_slot1 [32] == 1'd0;
    localparam[31:0] _e_7103 = 32'd0;
    always_comb begin
        priority casez ({_e_10288, _e_10290})
            2'b1?: \wdata1  = instr_n1;
            2'b01: \wdata1  = _e_7103;
            2'b?: \wdata1  = 32'dx;
        endcase
    end
    (* src = "src/imem.spade:278,33" *)
    \tta::sram::iram_1024x32  iram_1024x32_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .addr_i(\addr_calc ), .we_i(\wren ), .wdata_i(\wdata0 ), .output__(_e_7107));
    always @(posedge \clk ) begin
        \rdata0  <= _e_7107;
    end
    (* src = "src/imem.spade:279,33" *)
    \tta::sram::iram_1024x32  iram_1024x32_1(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .addr_i(\addr_calc ), .we_i(\wren ), .wdata_i(\wdata1 ), .output__(_e_7115));
    always @(posedge \clk ) begin
        \rdata1  <= _e_7115;
    end
    assign \_  = \wr_addr [9:0];
    assign _e_10292 = \wr_addr [10] == 1'd1;
    localparam[0:0] _e_10293 = 1;
    assign _e_10294 = _e_10292 && _e_10293;
    assign _e_7125 = {1'd0, 98'bX};
    assign _e_10296 = \wr_addr [10] == 1'd0;
    assign _e_7131 = {1'd0, 98'bX};
    assign _e_10298 = !\boot_mode ;
    (* src = "src/imem.spade:288,31" *)
    \tta::imem::decode_move  decode_move_0(.mw_i(\rdata0 ), .output__(\mv0 ));
    (* src = "src/imem.spade:289,31" *)
    \tta::imem::decode_move  decode_move_1(.mw_i(\rdata1 ), .output__(\mv1 ));
    assign _e_7141 = {\mv0 , \mv1 };
    assign _e_7140 = {1'd1, _e_7141};
    always_comb begin
        priority casez ({\boot_mode , _e_10298})
            2'b1?: _e_7128 = _e_7131;
            2'b01: _e_7128 = _e_7140;
            2'b?: _e_7128 = 99'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10294, _e_10296})
            2'b1?: _e_7121 = _e_7125;
            2'b01: _e_7121 = _e_7128;
            2'b?: _e_7121 = 99'dx;
        endcase
    end
    assign output__ = _e_7121;
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
    logic _e_7146;
    (* src = "src/spi_master.spade:28,5" *)
    logic[14:0] _e_7145;
    assign _e_7146 = {1'd0};
    localparam[4:0] _e_7147 = 0;
    localparam[7:0] _e_7148 = 0;
    localparam[0:0] _e_7149 = 0;
    assign _e_7145 = {_e_7146, _e_7147, _e_7148, _e_7149};
    assign output__ = _e_7145;
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
    logic[14:0] _e_7154;
    (* src = "src/spi_master.spade:41,19" *)
    logic _e_7159;
    (* src = "src/spi_master.spade:42,17" *)
    logic _e_7161;
    logic _e_10300;
    (* src = "src/spi_master.spade:43,27" *)
    logic[8:0] _e_7164;
    (* src = "src/spi_master.spade:45,25" *)
    logic[8:0] _e_7167;
    (* src = "src/spi_master.spade:45,25" *)
    logic[7:0] \data ;
    logic _e_10302;
    logic _e_10304;
    (* src = "src/spi_master.spade:45,43" *)
    logic _e_7169;
    (* src = "src/spi_master.spade:45,39" *)
    logic[14:0] _e_7168;
    (* src = "src/spi_master.spade:46,25" *)
    logic[8:0] _e_7173;
    logic _e_10306;
    (* src = "src/spi_master.spade:43,21" *)
    logic[14:0] _e_7163;
    (* src = "src/spi_master.spade:49,17" *)
    logic _e_7175;
    logic _e_10308;
    (* src = "src/spi_master.spade:53,41" *)
    logic[4:0] _e_7179;
    (* src = "src/spi_master.spade:53,41" *)
    logic[5:0] _e_7178;
    (* src = "src/spi_master.spade:53,35" *)
    logic[4:0] \new_cnt ;
    (* src = "src/spi_master.spade:55,24" *)
    logic[4:0] _e_7185;
    (* src = "src/spi_master.spade:55,24" *)
    logic _e_7184;
    (* src = "src/spi_master.spade:58,29" *)
    logic _e_7190;
    (* src = "src/spi_master.spade:58,45" *)
    logic[7:0] _e_7192;
    (* src = "src/spi_master.spade:58,25" *)
    logic[14:0] _e_7189;
    (* src = "src/spi_master.spade:60,29" *)
    logic[4:0] _e_7197;
    (* src = "src/spi_master.spade:60,29" *)
    logic _e_7196;
    (* src = "src/spi_master.spade:63,29" *)
    logic _e_7203;
    (* src = "src/spi_master.spade:63,55" *)
    logic[7:0] _e_7205;
    (* src = "src/spi_master.spade:63,25" *)
    logic[14:0] _e_7202;
    (* src = "src/spi_master.spade:68,40" *)
    logic[7:0] _e_7212;
    (* src = "src/spi_master.spade:68,39" *)
    logic[7:0] _e_7211;
    (* src = "src/spi_master.spade:68,58" *)
    logic _e_7216;
    logic[7:0] _e_7215;
    (* src = "src/spi_master.spade:68,39" *)
    logic[7:0] \next_sh ;
    (* src = "src/spi_master.spade:69,29" *)
    logic _e_7220;
    (* src = "src/spi_master.spade:69,64" *)
    logic _e_7223;
    (* src = "src/spi_master.spade:69,25" *)
    logic[14:0] _e_7219;
    (* src = "src/spi_master.spade:60,26" *)
    logic[14:0] _e_7195;
    (* src = "src/spi_master.spade:55,21" *)
    logic[14:0] _e_7183;
    (* src = "src/spi_master.spade:41,13" *)
    logic[14:0] _e_7158;
    (* src = "src/spi_master.spade:40,9" *)
    logic[14:0] _e_7155;
    (* src = "src/spi_master.spade:39,14" *)
    reg[14:0] \r ;
    (* src = "src/spi_master.spade:81,20" *)
    logic _e_7228;
    (* src = "src/spi_master.spade:82,9" *)
    logic _e_7230;
    logic _e_10310;
    (* src = "src/spi_master.spade:83,9" *)
    logic _e_7232;
    logic _e_10312;
    (* src = "src/spi_master.spade:81,14" *)
    logic \cs ;
    (* src = "src/spi_master.spade:88,22" *)
    logic _e_7236;
    (* src = "src/spi_master.spade:89,9" *)
    logic _e_7238;
    logic _e_10314;
    (* src = "src/spi_master.spade:89,29" *)
    logic[4:0] _e_7241;
    (* src = "src/spi_master.spade:89,28" *)
    logic[4:0] _e_7240;
    (* src = "src/spi_master.spade:89,28" *)
    logic _e_7239;
    (* src = "src/spi_master.spade:90,9" *)
    logic _e_7245;
    logic _e_10316;
    (* src = "src/spi_master.spade:88,16" *)
    logic \sclk ;
    (* src = "src/spi_master.spade:96,23" *)
    logic[7:0] _e_7251;
    (* src = "src/spi_master.spade:96,22" *)
    logic[7:0] _e_7250;
    (* src = "src/spi_master.spade:96,22" *)
    logic _e_7249;
    (* src = "src/spi_master.spade:97,9" *)
    logic _e_7255;
    (* src = "src/spi_master.spade:98,9" *)
    logic _e_7257;
    logic _e_10318;
    (* src = "src/spi_master.spade:96,16" *)
    logic \mosi ;
    (* src = "src/spi_master.spade:103,30" *)
    logic[4:0] _e_7264;
    (* src = "src/spi_master.spade:103,29" *)
    logic _e_7263;
    (* src = "src/spi_master.spade:103,21" *)
    logic _e_7261;
    (* src = "src/spi_master.spade:106,14" *)
    logic[7:0] _e_7269;
    (* src = "src/spi_master.spade:106,9" *)
    logic[8:0] _e_7268;
    (* src = "src/spi_master.spade:108,9" *)
    logic[8:0] _e_7272;
    (* src = "src/spi_master.spade:103,18" *)
    logic[8:0] \rx_val ;
    (* src = "src/spi_master.spade:111,5" *)
    logic[11:0] _e_7274;
    (* src = "src/spi_master.spade:39,32" *)
    \tta::spi_master::reset_spi  reset_spi_0(.output__(_e_7154));
    assign _e_7159 = \r [14];
    assign _e_7161 = _e_7159;
    assign _e_10300 = _e_7159 == 1'd0;
    assign _e_7164 = \start_tx ;
    assign _e_7167 = _e_7164;
    assign \data  = _e_7164[7:0];
    assign _e_10302 = _e_7164[8] == 1'd1;
    localparam[0:0] _e_10303 = 1;
    assign _e_10304 = _e_10302 && _e_10303;
    assign _e_7169 = {1'd1};
    localparam[4:0] _e_7170 = 0;
    localparam[0:0] _e_7172 = 0;
    assign _e_7168 = {_e_7169, _e_7170, \data , _e_7172};
    assign _e_7173 = _e_7164;
    assign _e_10306 = _e_7164[8] == 1'd0;
    always_comb begin
        priority casez ({_e_10304, _e_10306})
            2'b1?: _e_7163 = _e_7168;
            2'b01: _e_7163 = \r ;
            2'b?: _e_7163 = 15'dx;
        endcase
    end
    assign _e_7175 = _e_7159;
    assign _e_10308 = _e_7159 == 1'd1;
    assign _e_7179 = \r [13:9];
    localparam[4:0] _e_7181 = 1;
    assign _e_7178 = _e_7179 + _e_7181;
    assign \new_cnt  = _e_7178[4:0];
    assign _e_7185 = \r [13:9];
    localparam[4:0] _e_7187 = 16;
    assign _e_7184 = _e_7185 == _e_7187;
    assign _e_7190 = {1'd0};
    localparam[4:0] _e_7191 = 0;
    assign _e_7192 = \r [8:1];
    localparam[0:0] _e_7194 = 0;
    assign _e_7189 = {_e_7190, _e_7191, _e_7192, _e_7194};
    localparam[4:0] _e_7199 = 2;
    assign _e_7197 = \new_cnt  % _e_7199;
    localparam[4:0] _e_7200 = 0;
    assign _e_7196 = _e_7197 != _e_7200;
    assign _e_7203 = {1'd1};
    assign _e_7205 = \r [8:1];
    assign _e_7202 = {_e_7203, \new_cnt , _e_7205, \miso };
    assign _e_7212 = \r [8:1];
    localparam[7:0] _e_7214 = 1;
    assign _e_7211 = _e_7212 << _e_7214;
    assign _e_7216 = \r [0];
    assign _e_7215 = {7'b0, _e_7216};
    assign \next_sh  = _e_7211 | _e_7215;
    assign _e_7220 = {1'd1};
    assign _e_7223 = \r [0];
    assign _e_7219 = {_e_7220, \new_cnt , \next_sh , _e_7223};
    assign _e_7195 = _e_7196 ? _e_7202 : _e_7219;
    assign _e_7183 = _e_7184 ? _e_7189 : _e_7195;
    always_comb begin
        priority casez ({_e_10300, _e_10308})
            2'b1?: _e_7158 = _e_7163;
            2'b01: _e_7158 = _e_7183;
            2'b?: _e_7158 = 15'dx;
        endcase
    end
    assign _e_7155 = \tick  ? _e_7158 : \r ;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_7154;
        end
        else begin
            \r  <= _e_7155;
        end
    end
    assign _e_7228 = \r [14];
    assign _e_7230 = _e_7228;
    assign _e_10310 = _e_7228 == 1'd0;
    localparam[0:0] _e_7231 = 1;
    assign _e_7232 = _e_7228;
    assign _e_10312 = _e_7228 == 1'd1;
    localparam[0:0] _e_7233 = 0;
    always_comb begin
        priority casez ({_e_10310, _e_10312})
            2'b1?: \cs  = _e_7231;
            2'b01: \cs  = _e_7233;
            2'b?: \cs  = 1'dx;
        endcase
    end
    assign _e_7236 = \r [14];
    assign _e_7238 = _e_7236;
    assign _e_10314 = _e_7236 == 1'd1;
    assign _e_7241 = \r [13:9];
    localparam[4:0] _e_7243 = 2;
    assign _e_7240 = _e_7241 % _e_7243;
    localparam[4:0] _e_7244 = 0;
    assign _e_7239 = _e_7240 != _e_7244;
    assign _e_7245 = _e_7236;
    assign _e_10316 = _e_7236 == 1'd0;
    localparam[0:0] _e_7246 = 0;
    always_comb begin
        priority casez ({_e_10314, _e_10316})
            2'b1?: \sclk  = _e_7239;
            2'b01: \sclk  = _e_7246;
            2'b?: \sclk  = 1'dx;
        endcase
    end
    assign _e_7251 = \r [8:1];
    localparam[7:0] _e_7253 = 7;
    assign _e_7250 = _e_7251 >> _e_7253;
    localparam[7:0] _e_7254 = 0;
    assign _e_7249 = _e_7250 != _e_7254;
    assign _e_7255 = _e_7249;
    localparam[0:0] _e_7256 = 1;
    assign _e_7257 = _e_7249;
    assign _e_10318 = !_e_7249;
    localparam[0:0] _e_7258 = 0;
    always_comb begin
        priority casez ({_e_7249, _e_10318})
            2'b1?: \mosi  = _e_7256;
            2'b01: \mosi  = _e_7258;
            2'b?: \mosi  = 1'dx;
        endcase
    end
    assign _e_7264 = \r [13:9];
    localparam[4:0] _e_7266 = 16;
    assign _e_7263 = _e_7264 == _e_7266;
    assign _e_7261 = \tick  && _e_7263;
    assign _e_7269 = \r [8:1];
    assign _e_7268 = {1'd1, _e_7269};
    assign _e_7272 = {1'd0, 8'bX};
    assign \rx_val  = _e_7261 ? _e_7268 : _e_7272;
    assign _e_7274 = {\cs , \sclk , \mosi , \rx_val };
    assign output__ = _e_7274;
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
    logic[31:0] _e_7284;
    (* src = "src/regfile.spade:43,14" *)
    reg[31:0] \r0 ;
    (* src = "src/regfile.spade:44,43" *)
    logic[31:0] _e_7293;
    (* src = "src/regfile.spade:44,14" *)
    reg[31:0] \r1 ;
    (* src = "src/regfile.spade:45,43" *)
    logic[31:0] _e_7302;
    (* src = "src/regfile.spade:45,14" *)
    reg[31:0] \r2 ;
    (* src = "src/regfile.spade:46,43" *)
    logic[31:0] _e_7311;
    (* src = "src/regfile.spade:46,14" *)
    reg[31:0] \r3 ;
    (* src = "src/regfile.spade:47,43" *)
    logic[31:0] _e_7320;
    (* src = "src/regfile.spade:47,14" *)
    reg[31:0] \r4 ;
    (* src = "src/regfile.spade:48,43" *)
    logic[31:0] _e_7329;
    (* src = "src/regfile.spade:48,14" *)
    reg[31:0] \r5 ;
    (* src = "src/regfile.spade:49,43" *)
    logic[31:0] _e_7338;
    (* src = "src/regfile.spade:49,14" *)
    reg[31:0] \r6 ;
    (* src = "src/regfile.spade:50,43" *)
    logic[31:0] _e_7347;
    (* src = "src/regfile.spade:50,14" *)
    reg[31:0] \r7 ;
    (* src = "src/regfile.spade:52,43" *)
    logic[31:0] _e_7356;
    (* src = "src/regfile.spade:52,14" *)
    reg[31:0] \r8 ;
    (* src = "src/regfile.spade:53,43" *)
    logic[31:0] _e_7365;
    (* src = "src/regfile.spade:53,14" *)
    reg[31:0] \r9 ;
    (* src = "src/regfile.spade:54,44" *)
    logic[31:0] _e_7374;
    (* src = "src/regfile.spade:54,14" *)
    reg[31:0] \r10 ;
    (* src = "src/regfile.spade:55,44" *)
    logic[31:0] _e_7383;
    (* src = "src/regfile.spade:55,14" *)
    reg[31:0] \r11 ;
    (* src = "src/regfile.spade:56,44" *)
    logic[31:0] _e_7392;
    (* src = "src/regfile.spade:56,14" *)
    reg[31:0] \r12 ;
    (* src = "src/regfile.spade:57,44" *)
    logic[31:0] _e_7401;
    (* src = "src/regfile.spade:57,14" *)
    reg[31:0] \r13 ;
    (* src = "src/regfile.spade:58,44" *)
    logic[31:0] _e_7410;
    (* src = "src/regfile.spade:58,14" *)
    reg[31:0] \r14 ;
    (* src = "src/regfile.spade:59,44" *)
    logic[31:0] _e_7419;
    (* src = "src/regfile.spade:59,14" *)
    reg[31:0] \r15 ;
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
    (* src = "src/regfile.spade:78,29" *)
    logic[3:0] \_ ;
    (* src = "src/regfile.spade:62,25" *)
    logic[31:0] \rd0 ;
    logic _e_10350;
    logic _e_10352;
    logic _e_10354;
    logic _e_10356;
    logic _e_10358;
    logic _e_10360;
    logic _e_10362;
    logic _e_10364;
    logic _e_10366;
    logic _e_10368;
    logic _e_10370;
    logic _e_10372;
    logic _e_10374;
    logic _e_10376;
    logic _e_10378;
    (* src = "src/regfile.spade:97,29" *)
    logic[3:0] __n1;
    (* src = "src/regfile.spade:81,25" *)
    logic[31:0] \rd1 ;
    (* src = "src/regfile.spade:100,5" *)
    logic[575:0] _e_7494;
    localparam[31:0] _e_7283 = 32'd0;
    localparam[3:0] _e_7285 = 0;
    (* src = "src/regfile.spade:43,43" *)
    \tta::regfile::write_mux  write_mux_0(.my_idx_i(_e_7285), .cur_i(\r0 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7284));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r0  <= _e_7283;
        end
        else begin
            \r0  <= _e_7284;
        end
    end
    localparam[31:0] _e_7292 = 32'd0;
    localparam[3:0] _e_7294 = 1;
    (* src = "src/regfile.spade:44,43" *)
    \tta::regfile::write_mux  write_mux_1(.my_idx_i(_e_7294), .cur_i(\r1 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7293));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r1  <= _e_7292;
        end
        else begin
            \r1  <= _e_7293;
        end
    end
    localparam[31:0] _e_7301 = 32'd0;
    localparam[3:0] _e_7303 = 2;
    (* src = "src/regfile.spade:45,43" *)
    \tta::regfile::write_mux  write_mux_2(.my_idx_i(_e_7303), .cur_i(\r2 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7302));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r2  <= _e_7301;
        end
        else begin
            \r2  <= _e_7302;
        end
    end
    localparam[31:0] _e_7310 = 32'd0;
    localparam[3:0] _e_7312 = 3;
    (* src = "src/regfile.spade:46,43" *)
    \tta::regfile::write_mux  write_mux_3(.my_idx_i(_e_7312), .cur_i(\r3 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7311));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r3  <= _e_7310;
        end
        else begin
            \r3  <= _e_7311;
        end
    end
    localparam[31:0] _e_7319 = 32'd0;
    localparam[3:0] _e_7321 = 4;
    (* src = "src/regfile.spade:47,43" *)
    \tta::regfile::write_mux  write_mux_4(.my_idx_i(_e_7321), .cur_i(\r4 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7320));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r4  <= _e_7319;
        end
        else begin
            \r4  <= _e_7320;
        end
    end
    localparam[31:0] _e_7328 = 32'd0;
    localparam[3:0] _e_7330 = 5;
    (* src = "src/regfile.spade:48,43" *)
    \tta::regfile::write_mux  write_mux_5(.my_idx_i(_e_7330), .cur_i(\r5 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7329));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r5  <= _e_7328;
        end
        else begin
            \r5  <= _e_7329;
        end
    end
    localparam[31:0] _e_7337 = 32'd0;
    localparam[3:0] _e_7339 = 6;
    (* src = "src/regfile.spade:49,43" *)
    \tta::regfile::write_mux  write_mux_6(.my_idx_i(_e_7339), .cur_i(\r6 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7338));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r6  <= _e_7337;
        end
        else begin
            \r6  <= _e_7338;
        end
    end
    localparam[31:0] _e_7346 = 32'd0;
    localparam[3:0] _e_7348 = 7;
    (* src = "src/regfile.spade:50,43" *)
    \tta::regfile::write_mux  write_mux_7(.my_idx_i(_e_7348), .cur_i(\r7 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7347));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r7  <= _e_7346;
        end
        else begin
            \r7  <= _e_7347;
        end
    end
    localparam[31:0] _e_7355 = 32'd0;
    localparam[3:0] _e_7357 = 8;
    (* src = "src/regfile.spade:52,43" *)
    \tta::regfile::write_mux  write_mux_8(.my_idx_i(_e_7357), .cur_i(\r8 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7356));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r8  <= _e_7355;
        end
        else begin
            \r8  <= _e_7356;
        end
    end
    localparam[31:0] _e_7364 = 32'd0;
    localparam[3:0] _e_7366 = 9;
    (* src = "src/regfile.spade:53,43" *)
    \tta::regfile::write_mux  write_mux_9(.my_idx_i(_e_7366), .cur_i(\r9 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7365));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r9  <= _e_7364;
        end
        else begin
            \r9  <= _e_7365;
        end
    end
    localparam[31:0] _e_7373 = 32'd0;
    localparam[3:0] _e_7375 = 10;
    (* src = "src/regfile.spade:54,44" *)
    \tta::regfile::write_mux  write_mux_10(.my_idx_i(_e_7375), .cur_i(\r10 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7374));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r10  <= _e_7373;
        end
        else begin
            \r10  <= _e_7374;
        end
    end
    localparam[31:0] _e_7382 = 32'd0;
    localparam[3:0] _e_7384 = 11;
    (* src = "src/regfile.spade:55,44" *)
    \tta::regfile::write_mux  write_mux_11(.my_idx_i(_e_7384), .cur_i(\r11 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7383));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r11  <= _e_7382;
        end
        else begin
            \r11  <= _e_7383;
        end
    end
    localparam[31:0] _e_7391 = 32'd0;
    localparam[3:0] _e_7393 = 12;
    (* src = "src/regfile.spade:56,44" *)
    \tta::regfile::write_mux  write_mux_12(.my_idx_i(_e_7393), .cur_i(\r12 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7392));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r12  <= _e_7391;
        end
        else begin
            \r12  <= _e_7392;
        end
    end
    localparam[31:0] _e_7400 = 32'd0;
    localparam[3:0] _e_7402 = 13;
    (* src = "src/regfile.spade:57,44" *)
    \tta::regfile::write_mux  write_mux_13(.my_idx_i(_e_7402), .cur_i(\r13 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7401));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r13  <= _e_7400;
        end
        else begin
            \r13  <= _e_7401;
        end
    end
    localparam[31:0] _e_7409 = 32'd0;
    localparam[3:0] _e_7411 = 14;
    (* src = "src/regfile.spade:58,44" *)
    \tta::regfile::write_mux  write_mux_14(.my_idx_i(_e_7411), .cur_i(\r14 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7410));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r14  <= _e_7409;
        end
        else begin
            \r14  <= _e_7410;
        end
    end
    localparam[31:0] _e_7418 = 32'd0;
    localparam[3:0] _e_7420 = 15;
    (* src = "src/regfile.spade:59,44" *)
    \tta::regfile::write_mux  write_mux_15(.my_idx_i(_e_7420), .cur_i(\r15 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7419));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r15  <= _e_7418;
        end
        else begin
            \r15  <= _e_7419;
        end
    end
    localparam[3:0] _e_10320 = 0;
    assign _e_10319 = \ra0  == _e_10320;
    localparam[3:0] _e_10322 = 1;
    assign _e_10321 = \ra0  == _e_10322;
    localparam[3:0] _e_10324 = 2;
    assign _e_10323 = \ra0  == _e_10324;
    localparam[3:0] _e_10326 = 3;
    assign _e_10325 = \ra0  == _e_10326;
    localparam[3:0] _e_10328 = 4;
    assign _e_10327 = \ra0  == _e_10328;
    localparam[3:0] _e_10330 = 5;
    assign _e_10329 = \ra0  == _e_10330;
    localparam[3:0] _e_10332 = 6;
    assign _e_10331 = \ra0  == _e_10332;
    localparam[3:0] _e_10334 = 7;
    assign _e_10333 = \ra0  == _e_10334;
    localparam[3:0] _e_10336 = 8;
    assign _e_10335 = \ra0  == _e_10336;
    localparam[3:0] _e_10338 = 9;
    assign _e_10337 = \ra0  == _e_10338;
    localparam[3:0] _e_10340 = 10;
    assign _e_10339 = \ra0  == _e_10340;
    localparam[3:0] _e_10342 = 11;
    assign _e_10341 = \ra0  == _e_10342;
    localparam[3:0] _e_10344 = 12;
    assign _e_10343 = \ra0  == _e_10344;
    localparam[3:0] _e_10346 = 13;
    assign _e_10345 = \ra0  == _e_10346;
    localparam[3:0] _e_10348 = 14;
    assign _e_10347 = \ra0  == _e_10348;
    assign \_  = \ra0 ;
    localparam[0:0] _e_10349 = 1;
    always_comb begin
        priority casez ({_e_10319, _e_10321, _e_10323, _e_10325, _e_10327, _e_10329, _e_10331, _e_10333, _e_10335, _e_10337, _e_10339, _e_10341, _e_10343, _e_10345, _e_10347, _e_10349})
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
    localparam[3:0] _e_10351 = 0;
    assign _e_10350 = \ra1  == _e_10351;
    localparam[3:0] _e_10353 = 1;
    assign _e_10352 = \ra1  == _e_10353;
    localparam[3:0] _e_10355 = 2;
    assign _e_10354 = \ra1  == _e_10355;
    localparam[3:0] _e_10357 = 3;
    assign _e_10356 = \ra1  == _e_10357;
    localparam[3:0] _e_10359 = 4;
    assign _e_10358 = \ra1  == _e_10359;
    localparam[3:0] _e_10361 = 5;
    assign _e_10360 = \ra1  == _e_10361;
    localparam[3:0] _e_10363 = 6;
    assign _e_10362 = \ra1  == _e_10363;
    localparam[3:0] _e_10365 = 7;
    assign _e_10364 = \ra1  == _e_10365;
    localparam[3:0] _e_10367 = 8;
    assign _e_10366 = \ra1  == _e_10367;
    localparam[3:0] _e_10369 = 9;
    assign _e_10368 = \ra1  == _e_10369;
    localparam[3:0] _e_10371 = 10;
    assign _e_10370 = \ra1  == _e_10371;
    localparam[3:0] _e_10373 = 11;
    assign _e_10372 = \ra1  == _e_10373;
    localparam[3:0] _e_10375 = 12;
    assign _e_10374 = \ra1  == _e_10375;
    localparam[3:0] _e_10377 = 13;
    assign _e_10376 = \ra1  == _e_10377;
    localparam[3:0] _e_10379 = 14;
    assign _e_10378 = \ra1  == _e_10379;
    assign __n1 = \ra1 ;
    localparam[0:0] _e_10380 = 1;
    always_comb begin
        priority casez ({_e_10350, _e_10352, _e_10354, _e_10356, _e_10358, _e_10360, _e_10362, _e_10364, _e_10366, _e_10368, _e_10370, _e_10372, _e_10374, _e_10376, _e_10378, _e_10380})
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
    assign _e_7494 = {\rd0 , \rd1 , \r0 , \r1 , \r2 , \r3 , \r4 , \r5 , \r6 , \r7 , \r8 , \r9 , \r10 , \r11 , \r12 , \r13 , \r14 , \r15 };
    assign output__ = _e_7494;
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
    logic[42:0] _e_7518;
    (* src = "src/regfile.spade:106,14" *)
    logic[3:0] \i ;
    (* src = "src/regfile.spade:106,14" *)
    logic[31:0] \x ;
    logic _e_10382;
    logic _e_10384;
    logic _e_10387;
    logic _e_10388;
    logic _e_10389;
    (* src = "src/regfile.spade:106,43" *)
    logic[35:0] _e_7521;
    (* src = "src/regfile.spade:106,38" *)
    logic[36:0] _e_7520;
    (* src = "src/regfile.spade:107,9" *)
    logic[43:0] \_ ;
    (* src = "src/regfile.spade:107,14" *)
    logic[36:0] _e_7525;
    (* src = "src/regfile.spade:105,5" *)
    logic[36:0] _e_7514;
    assign _e_7518 = \m [42:0];
    assign \i  = _e_7518[36:33];
    assign \x  = _e_7518[32:1];
    assign _e_10382 = \m [43] == 1'd1;
    assign _e_10384 = _e_7518[42:37] == 6'd0;
    localparam[0:0] _e_10385 = 1;
    localparam[0:0] _e_10386 = 1;
    assign _e_10387 = _e_10384 && _e_10385;
    assign _e_10388 = _e_10387 && _e_10386;
    assign _e_10389 = _e_10382 && _e_10388;
    assign _e_7521 = {\i , \x };
    assign _e_7520 = {1'd1, _e_7521};
    assign \_  = \m ;
    localparam[0:0] _e_10390 = 1;
    assign _e_7525 = {1'd0, 36'bX};
    always_comb begin
        priority casez ({_e_10389, _e_10390})
            2'b1?: _e_7514 = _e_7520;
            2'b01: _e_7514 = _e_7525;
            2'b?: _e_7514 = 37'dx;
        endcase
    end
    assign output__ = _e_7514;
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
    logic[35:0] _e_7531;
    (* src = "src/regfile.spade:117,14" *)
    logic[3:0] \idx ;
    (* src = "src/regfile.spade:117,14" *)
    logic[31:0] \v ;
    logic _e_10392;
    logic _e_10396;
    logic _e_10397;
    (* src = "src/regfile.spade:117,30" *)
    logic _e_7534;
    (* src = "src/regfile.spade:119,17" *)
    logic[35:0] _e_7544;
    (* src = "src/regfile.spade:119,22" *)
    logic[3:0] \idx0 ;
    (* src = "src/regfile.spade:119,22" *)
    logic[31:0] \v0 ;
    logic _e_10399;
    logic _e_10403;
    logic _e_10404;
    (* src = "src/regfile.spade:119,40" *)
    logic _e_7547;
    (* src = "src/regfile.spade:119,37" *)
    logic[31:0] _e_7546;
    logic _e_10406;
    (* src = "src/regfile.spade:118,13" *)
    logic[31:0] _e_7540;
    (* src = "src/regfile.spade:117,27" *)
    logic[31:0] _e_7533;
    logic _e_10408;
    (* src = "src/regfile.spade:124,13" *)
    logic[35:0] _e_7561;
    (* src = "src/regfile.spade:124,18" *)
    logic[3:0] idx0_n1;
    (* src = "src/regfile.spade:124,18" *)
    logic[31:0] v0_n1;
    logic _e_10410;
    logic _e_10414;
    logic _e_10415;
    (* src = "src/regfile.spade:124,36" *)
    logic _e_7564;
    (* src = "src/regfile.spade:124,33" *)
    logic[31:0] _e_7563;
    logic _e_10417;
    (* src = "src/regfile.spade:123,17" *)
    logic[31:0] _e_7557;
    (* src = "src/regfile.spade:116,5" *)
    logic[31:0] _e_7527;
    assign _e_7531 = \w1 [35:0];
    assign \idx  = _e_7531[35:32];
    assign \v  = _e_7531[31:0];
    assign _e_10392 = \w1 [36] == 1'd1;
    localparam[0:0] _e_10394 = 1;
    localparam[0:0] _e_10395 = 1;
    assign _e_10396 = _e_10394 && _e_10395;
    assign _e_10397 = _e_10392 && _e_10396;
    assign _e_7534 = \idx  == \my_idx ;
    assign _e_7544 = \w0 [35:0];
    assign \idx0  = _e_7544[35:32];
    assign \v0  = _e_7544[31:0];
    assign _e_10399 = \w0 [36] == 1'd1;
    localparam[0:0] _e_10401 = 1;
    localparam[0:0] _e_10402 = 1;
    assign _e_10403 = _e_10401 && _e_10402;
    assign _e_10404 = _e_10399 && _e_10403;
    assign _e_7547 = \idx0  == \my_idx ;
    assign _e_7546 = _e_7547 ? \v0  : \cur ;
    assign _e_10406 = \w0 [36] == 1'd0;
    always_comb begin
        priority casez ({_e_10404, _e_10406})
            2'b1?: _e_7540 = _e_7546;
            2'b01: _e_7540 = \cur ;
            2'b?: _e_7540 = 32'dx;
        endcase
    end
    assign _e_7533 = _e_7534 ? \v  : _e_7540;
    assign _e_10408 = \w1 [36] == 1'd0;
    assign _e_7561 = \w0 [35:0];
    assign idx0_n1 = _e_7561[35:32];
    assign v0_n1 = _e_7561[31:0];
    assign _e_10410 = \w0 [36] == 1'd1;
    localparam[0:0] _e_10412 = 1;
    localparam[0:0] _e_10413 = 1;
    assign _e_10414 = _e_10412 && _e_10413;
    assign _e_10415 = _e_10410 && _e_10414;
    assign _e_7564 = idx0_n1 == \my_idx ;
    assign _e_7563 = _e_7564 ? v0_n1 : \cur ;
    assign _e_10417 = \w0 [36] == 1'd0;
    always_comb begin
        priority casez ({_e_10415, _e_10417})
            2'b1?: _e_7557 = _e_7563;
            2'b01: _e_7557 = \cur ;
            2'b?: _e_7557 = 32'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10397, _e_10408})
            2'b1?: _e_7527 = _e_7533;
            2'b01: _e_7527 = _e_7557;
            2'b?: _e_7527 = 32'dx;
        endcase
    end
    assign output__ = _e_7527;
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
    logic[31:0] _e_7577;
    (* src = "src/xorshift.spade:17,18" *)
    logic[31:0] _e_7576;
    (* src = "src/xorshift.spade:17,14" *)
    logic[31:0] \x1 ;
    (* src = "src/xorshift.spade:18,19" *)
    logic[31:0] _e_7583;
    (* src = "src/xorshift.spade:18,14" *)
    logic[31:0] \x2 ;
    (* src = "src/xorshift.spade:19,25" *)
    logic[31:0] _e_7590;
    (* src = "src/xorshift.spade:19,19" *)
    logic[31:0] _e_7589;
    (* src = "src/xorshift.spade:19,14" *)
    logic[31:0] \x3 ;
    localparam[31:0] _e_7579 = 32'd13;
    assign _e_7577 = \x  << _e_7579;
    assign _e_7576 = _e_7577[31:0];
    assign \x1  = \x  ^ _e_7576;
    localparam[31:0] _e_7585 = 32'd17;
    assign _e_7583 = \x1  >> _e_7585;
    assign \x2  = \x1  ^ _e_7583;
    localparam[31:0] _e_7592 = 32'd5;
    assign _e_7590 = \x2  << _e_7592;
    assign _e_7589 = _e_7590[31:0];
    assign \x3  = \x2  ^ _e_7589;
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
    logic _e_10419;
    logic _e_10421;
    (* src = "src/xorshift.spade:32,27" *)
    logic _e_7606;
    (* src = "src/xorshift.spade:32,24" *)
    logic[31:0] _e_7605;
    logic _e_10423;
    (* src = "src/xorshift.spade:31,20" *)
    logic[31:0] \base ;
    (* src = "src/xorshift.spade:37,9" *)
    logic[31:0] _e_7616;
    (* src = "src/xorshift.spade:29,14" *)
    reg[31:0] \state ;
    (* src = "src/xorshift.spade:42,47" *)
    logic[32:0] _e_7621;
    (* src = "src/xorshift.spade:44,13" *)
    logic[31:0] v_n1;
    logic _e_10425;
    logic _e_10427;
    (* src = "src/xorshift.spade:44,27" *)
    logic _e_7628;
    (* src = "src/xorshift.spade:44,24" *)
    logic[31:0] _e_7627;
    logic _e_10429;
    (* src = "src/xorshift.spade:43,20" *)
    logic[31:0] base_n1;
    (* src = "src/xorshift.spade:47,14" *)
    logic[31:0] _e_7639;
    (* src = "src/xorshift.spade:47,9" *)
    logic[32:0] _e_7638;
    (* src = "src/xorshift.spade:42,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_7599 = 32'd1;
    assign \v  = \trig [31:0];
    assign _e_10419 = \trig [32] == 1'd1;
    localparam[0:0] _e_10420 = 1;
    assign _e_10421 = _e_10419 && _e_10420;
    localparam[31:0] _e_7608 = 32'd0;
    assign _e_7606 = \v  == _e_7608;
    assign _e_7605 = _e_7606 ? \state  : \v ;
    assign _e_10423 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_10421, _e_10423})
            2'b1?: \base  = _e_7605;
            2'b01: \base  = \state ;
            2'b?: \base  = 32'dx;
        endcase
    end
    (* src = "src/xorshift.spade:37,9" *)
    \tta::xorshift::next_xorshift32  next_xorshift32_0(.x_i(\base ), .output__(_e_7616));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \state  <= _e_7599;
        end
        else begin
            \state  <= _e_7616;
        end
    end
    assign _e_7621 = {1'd0, 32'bX};
    assign v_n1 = \trig [31:0];
    assign _e_10425 = \trig [32] == 1'd1;
    localparam[0:0] _e_10426 = 1;
    assign _e_10427 = _e_10425 && _e_10426;
    localparam[31:0] _e_7630 = 32'd0;
    assign _e_7628 = v_n1 == _e_7630;
    assign _e_7627 = _e_7628 ? \state  : v_n1;
    assign _e_10429 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_10427, _e_10429})
            2'b1?: base_n1 = _e_7627;
            2'b01: base_n1 = \state ;
            2'b?: base_n1 = 32'dx;
        endcase
    end
    (* src = "src/xorshift.spade:47,14" *)
    \tta::xorshift::next_xorshift32  next_xorshift32_1(.x_i(base_n1), .output__(_e_7639));
    assign _e_7638 = {1'd1, _e_7639};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_7621;
        end
        else begin
            \res  <= _e_7638;
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
    logic[42:0] _e_7646;
    (* src = "src/xorshift.spade:57,14" *)
    logic[31:0] \x ;
    logic _e_10431;
    logic _e_10433;
    logic _e_10435;
    logic _e_10436;
    (* src = "src/xorshift.spade:57,40" *)
    logic[32:0] _e_7648;
    (* src = "src/xorshift.spade:58,9" *)
    logic[43:0] \_ ;
    (* src = "src/xorshift.spade:59,13" *)
    logic[42:0] _e_7654;
    (* src = "src/xorshift.spade:59,18" *)
    logic[31:0] x_n1;
    logic _e_10439;
    logic _e_10441;
    logic _e_10443;
    logic _e_10444;
    (* src = "src/xorshift.spade:59,44" *)
    logic[32:0] _e_7656;
    (* src = "src/xorshift.spade:60,13" *)
    logic[43:0] __n1;
    (* src = "src/xorshift.spade:60,18" *)
    logic[32:0] _e_7659;
    (* src = "src/xorshift.spade:58,14" *)
    logic[32:0] _e_7651;
    (* src = "src/xorshift.spade:56,5" *)
    logic[32:0] _e_7643;
    assign _e_7646 = \m1 [42:0];
    assign \x  = _e_7646[36:5];
    assign _e_10431 = \m1 [43] == 1'd1;
    assign _e_10433 = _e_7646[42:37] == 6'd23;
    localparam[0:0] _e_10434 = 1;
    assign _e_10435 = _e_10433 && _e_10434;
    assign _e_10436 = _e_10431 && _e_10435;
    assign _e_7648 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10437 = 1;
    assign _e_7654 = \m0 [42:0];
    assign x_n1 = _e_7654[36:5];
    assign _e_10439 = \m0 [43] == 1'd1;
    assign _e_10441 = _e_7654[42:37] == 6'd23;
    localparam[0:0] _e_10442 = 1;
    assign _e_10443 = _e_10441 && _e_10442;
    assign _e_10444 = _e_10439 && _e_10443;
    assign _e_7656 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10445 = 1;
    assign _e_7659 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10444, _e_10445})
            2'b1?: _e_7651 = _e_7656;
            2'b01: _e_7651 = _e_7659;
            2'b?: _e_7651 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10436, _e_10437})
            2'b1?: _e_7643 = _e_7648;
            2'b01: _e_7643 = _e_7651;
            2'b?: _e_7643 = 33'dx;
        endcase
    end
    assign output__ = _e_7643;
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
    logic[10:0] _e_7664;
    (* src = "src/bt.spade:14,9" *)
    logic[9:0] \v ;
    logic _e_10447;
    logic _e_10449;
    (* src = "src/bt.spade:14,20" *)
    logic[10:0] _e_7669;
    logic _e_10451;
    (* src = "src/bt.spade:13,58" *)
    logic[10:0] _e_7665;
    (* src = "src/bt.spade:13,14" *)
    reg[10:0] \target ;
    (* src = "src/bt.spade:18,11" *)
    logic[43:0] _e_7674;
    (* src = "src/bt.spade:19,9" *)
    logic[43:0] _e_7681;
    (* src = "src/bt.spade:19,9" *)
    logic[10:0] _e_7678;
    (* src = "src/bt.spade:19,10" *)
    logic[9:0] v_n1;
    (* src = "src/bt.spade:19,9" *)
    logic[32:0] _e_7680;
    (* src = "src/bt.spade:19,19" *)
    logic[31:0] \c ;
    logic _e_10454;
    logic _e_10456;
    logic _e_10458;
    logic _e_10460;
    logic _e_10461;
    (* src = "src/bt.spade:20,16" *)
    logic _e_7684;
    (* src = "src/bt.spade:20,29" *)
    logic[10:0] _e_7687;
    (* src = "src/bt.spade:20,46" *)
    logic[10:0] _e_7690;
    (* src = "src/bt.spade:20,13" *)
    logic[10:0] _e_7683;
    (* src = "src/bt.spade:22,9" *)
    logic[43:0] _e_7693;
    (* src = "src/bt.spade:22,9" *)
    logic[10:0] \_ ;
    (* src = "src/bt.spade:22,9" *)
    logic[32:0] __n1;
    logic _e_10465;
    (* src = "src/bt.spade:22,19" *)
    logic[10:0] _e_7694;
    (* src = "src/bt.spade:18,5" *)
    logic[10:0] _e_7673;
    assign _e_7664 = {1'd0, 10'bX};
    assign \v  = \jump_to [9:0];
    assign _e_10447 = \jump_to [10] == 1'd1;
    localparam[0:0] _e_10448 = 1;
    assign _e_10449 = _e_10447 && _e_10448;
    assign _e_7669 = {1'd1, \v };
    assign _e_10451 = \jump_to [10] == 1'd0;
    always_comb begin
        priority casez ({_e_10449, _e_10451})
            2'b1?: _e_7665 = _e_7669;
            2'b01: _e_7665 = \target ;
            2'b?: _e_7665 = 11'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \target  <= _e_7664;
        end
        else begin
            \target  <= _e_7665;
        end
    end
    assign _e_7674 = {\target , \condition_trig };
    assign _e_7681 = _e_7674;
    assign _e_7678 = _e_7674[43:33];
    assign v_n1 = _e_7678[9:0];
    assign _e_7680 = _e_7674[32:0];
    assign \c  = _e_7680[31:0];
    assign _e_10454 = _e_7678[10] == 1'd1;
    localparam[0:0] _e_10455 = 1;
    assign _e_10456 = _e_10454 && _e_10455;
    assign _e_10458 = _e_7680[32] == 1'd1;
    localparam[0:0] _e_10459 = 1;
    assign _e_10460 = _e_10458 && _e_10459;
    assign _e_10461 = _e_10456 && _e_10460;
    (* src = "src/bt.spade:20,16" *)
    \tta::bt::to_bool  to_bool_0(.x_i(\c ), .output__(_e_7684));
    assign _e_7687 = {1'd1, v_n1};
    assign _e_7690 = {1'd0, 10'bX};
    assign _e_7683 = _e_7684 ? _e_7687 : _e_7690;
    assign _e_7693 = _e_7674;
    assign \_  = _e_7674[43:33];
    assign __n1 = _e_7674[32:0];
    localparam[0:0] _e_10463 = 1;
    localparam[0:0] _e_10464 = 1;
    assign _e_10465 = _e_10463 && _e_10464;
    assign _e_7694 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_10461, _e_10465})
            2'b1?: _e_7673 = _e_7683;
            2'b01: _e_7673 = _e_7694;
            2'b?: _e_7673 = 11'dx;
        endcase
    end
    assign output__ = _e_7673;
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
    logic _e_7697;
    (* src = "src/bt.spade:28,5" *)
    logic _e_7696;
    localparam[31:0] _e_7699 = 32'd0;
    assign _e_7697 = \x  == _e_7699;
    localparam[0:0] _e_7701 = 0;
    localparam[0:0] _e_7703 = 1;
    assign _e_7696 = _e_7697 ? _e_7701 : _e_7703;
    assign output__ = _e_7696;
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
    logic[42:0] _e_7708;
    (* src = "src/bt.spade:39,14" *)
    logic[9:0] \a ;
    logic _e_10467;
    logic _e_10469;
    logic _e_10471;
    logic _e_10472;
    (* src = "src/bt.spade:39,36" *)
    logic[10:0] _e_7710;
    (* src = "src/bt.spade:40,9" *)
    logic[43:0] \_ ;
    (* src = "src/bt.spade:40,25" *)
    logic[42:0] _e_7716;
    (* src = "src/bt.spade:40,30" *)
    logic[9:0] a_n1;
    logic _e_10475;
    logic _e_10477;
    logic _e_10479;
    logic _e_10480;
    (* src = "src/bt.spade:40,52" *)
    logic[10:0] _e_7718;
    (* src = "src/bt.spade:40,61" *)
    logic[43:0] __n1;
    (* src = "src/bt.spade:40,66" *)
    logic[10:0] _e_7721;
    (* src = "src/bt.spade:40,14" *)
    logic[10:0] _e_7713;
    (* src = "src/bt.spade:38,5" *)
    logic[10:0] _e_7705;
    assign _e_7708 = \m1 [42:0];
    assign \a  = _e_7708[36:27];
    assign _e_10467 = \m1 [43] == 1'd1;
    assign _e_10469 = _e_7708[42:37] == 6'd18;
    localparam[0:0] _e_10470 = 1;
    assign _e_10471 = _e_10469 && _e_10470;
    assign _e_10472 = _e_10467 && _e_10471;
    assign _e_7710 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_10473 = 1;
    assign _e_7716 = \m0 [42:0];
    assign a_n1 = _e_7716[36:27];
    assign _e_10475 = \m0 [43] == 1'd1;
    assign _e_10477 = _e_7716[42:37] == 6'd18;
    localparam[0:0] _e_10478 = 1;
    assign _e_10479 = _e_10477 && _e_10478;
    assign _e_10480 = _e_10475 && _e_10479;
    assign _e_7718 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10481 = 1;
    assign _e_7721 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_10480, _e_10481})
            2'b1?: _e_7713 = _e_7718;
            2'b01: _e_7713 = _e_7721;
            2'b?: _e_7713 = 11'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10472, _e_10473})
            2'b1?: _e_7705 = _e_7710;
            2'b01: _e_7705 = _e_7713;
            2'b?: _e_7705 = 11'dx;
        endcase
    end
    assign output__ = _e_7705;
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
    logic[42:0] _e_7726;
    (* src = "src/bt.spade:46,14" *)
    logic[31:0] \a ;
    logic _e_10483;
    logic _e_10485;
    logic _e_10487;
    logic _e_10488;
    (* src = "src/bt.spade:46,34" *)
    logic[32:0] _e_7728;
    (* src = "src/bt.spade:47,9" *)
    logic[43:0] \_ ;
    (* src = "src/bt.spade:47,25" *)
    logic[42:0] _e_7734;
    (* src = "src/bt.spade:47,30" *)
    logic[31:0] a_n1;
    logic _e_10491;
    logic _e_10493;
    logic _e_10495;
    logic _e_10496;
    (* src = "src/bt.spade:47,50" *)
    logic[32:0] _e_7736;
    (* src = "src/bt.spade:47,59" *)
    logic[43:0] __n1;
    (* src = "src/bt.spade:47,64" *)
    logic[32:0] _e_7739;
    (* src = "src/bt.spade:47,14" *)
    logic[32:0] _e_7731;
    (* src = "src/bt.spade:45,5" *)
    logic[32:0] _e_7723;
    assign _e_7726 = \m1 [42:0];
    assign \a  = _e_7726[36:5];
    assign _e_10483 = \m1 [43] == 1'd1;
    assign _e_10485 = _e_7726[42:37] == 6'd19;
    localparam[0:0] _e_10486 = 1;
    assign _e_10487 = _e_10485 && _e_10486;
    assign _e_10488 = _e_10483 && _e_10487;
    assign _e_7728 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_10489 = 1;
    assign _e_7734 = \m0 [42:0];
    assign a_n1 = _e_7734[36:5];
    assign _e_10491 = \m0 [43] == 1'd1;
    assign _e_10493 = _e_7734[42:37] == 6'd19;
    localparam[0:0] _e_10494 = 1;
    assign _e_10495 = _e_10493 && _e_10494;
    assign _e_10496 = _e_10491 && _e_10495;
    assign _e_7736 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10497 = 1;
    assign _e_7739 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10496, _e_10497})
            2'b1?: _e_7731 = _e_7736;
            2'b01: _e_7731 = _e_7739;
            2'b?: _e_7731 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10488, _e_10489})
            2'b1?: _e_7723 = _e_7728;
            2'b01: _e_7723 = _e_7731;
            2'b?: _e_7723 = 33'dx;
        endcase
    end
    assign output__ = _e_7723;
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
    logic _e_10499;
    logic _e_10501;
    logic _e_10503;
    (* src = "src/stack_lsu.spade:26,38" *)
    logic[31:0] \_ ;
    logic _e_10505;
    logic _e_10507;
    logic _e_10509;
    (* src = "src/stack_lsu.spade:26,20" *)
    logic _e_7754;
    (* src = "src/stack_lsu.spade:27,27" *)
    logic[32:0] _e_7763;
    (* src = "src/stack_lsu.spade:27,21" *)
    logic[31:0] _e_7762;
    (* src = "src/stack_lsu.spade:29,27" *)
    logic[32:0] _e_7770;
    (* src = "src/stack_lsu.spade:29,21" *)
    logic[31:0] _e_7769;
    (* src = "src/stack_lsu.spade:28,24" *)
    logic[31:0] _e_7766;
    (* src = "src/stack_lsu.spade:26,17" *)
    logic[31:0] _e_7753;
    (* src = "src/stack_lsu.spade:23,9" *)
    logic[31:0] _e_7746;
    (* src = "src/stack_lsu.spade:22,14" *)
    reg[31:0] \sp ;
    (* src = "src/stack_lsu.spade:38,9" *)
    logic[31:0] val_n1;
    logic _e_10511;
    logic _e_10513;
    (* src = "src/stack_lsu.spade:39,43" *)
    logic[32:0] _e_7781;
    (* src = "src/stack_lsu.spade:39,37" *)
    logic[7:0] \trunc_sp ;
    (* src = "src/stack_lsu.spade:40,13" *)
    logic[40:0] _e_7785;
    logic _e_10515;
    (* src = "src/stack_lsu.spade:44,43" *)
    logic[32:0] _e_7792;
    (* src = "src/stack_lsu.spade:44,37" *)
    logic[7:0] trunc_sp_n1;
    (* src = "src/stack_lsu.spade:45,13" *)
    logic[40:0] _e_7796;
    (* src = "src/stack_lsu.spade:37,31" *)
    logic[40:0] _e_7803;
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
    logic _e_10517;
    logic _e_10519;
    logic _e_10521;
    (* src = "src/stack_lsu.spade:51,62" *)
    logic _e_7817;
    (* src = "src/stack_lsu.spade:51,50" *)
    logic _e_7815;
    (* src = "src/stack_lsu.spade:51,14" *)
    reg \pop_valid ;
    (* src = "src/stack_lsu.spade:56,20" *)
    logic[32:0] _e_7827;
    (* src = "src/stack_lsu.spade:56,41" *)
    logic[32:0] _e_7830;
    (* src = "src/stack_lsu.spade:56,5" *)
    logic[32:0] _e_7824;
    localparam[31:0] _e_7744 = 32'd0;
    assign \val  = \set_sp [31:0];
    assign _e_10499 = \set_sp [32] == 1'd1;
    localparam[0:0] _e_10500 = 1;
    assign _e_10501 = _e_10499 && _e_10500;
    assign _e_10503 = \set_sp [32] == 1'd0;
    assign \_  = \push_trig [31:0];
    assign _e_10505 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10506 = 1;
    assign _e_10507 = _e_10505 && _e_10506;
    localparam[0:0] _e_7758 = 1;
    assign _e_10509 = \push_trig [32] == 1'd0;
    localparam[0:0] _e_7760 = 0;
    always_comb begin
        priority casez ({_e_10507, _e_10509})
            2'b1?: _e_7754 = _e_7758;
            2'b01: _e_7754 = _e_7760;
            2'b?: _e_7754 = 1'dx;
        endcase
    end
    localparam[31:0] _e_7765 = 32'd1;
    assign _e_7763 = \sp  - _e_7765;
    assign _e_7762 = _e_7763[31:0];
    localparam[31:0] _e_7772 = 32'd1;
    assign _e_7770 = \sp  + _e_7772;
    assign _e_7769 = _e_7770[31:0];
    assign _e_7766 = \pop_trig  ? _e_7769 : \sp ;
    assign _e_7753 = _e_7754 ? _e_7762 : _e_7766;
    always_comb begin
        priority casez ({_e_10501, _e_10503})
            2'b1?: _e_7746 = \val ;
            2'b01: _e_7746 = _e_7753;
            2'b?: _e_7746 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \sp  <= _e_7744;
        end
        else begin
            \sp  <= _e_7746;
        end
    end
    assign val_n1 = \push_trig [31:0];
    assign _e_10511 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10512 = 1;
    assign _e_10513 = _e_10511 && _e_10512;
    localparam[31:0] _e_7783 = 32'd1;
    assign _e_7781 = \sp  - _e_7783;
    assign \trunc_sp  = _e_7781[7:0];
    localparam[0:0] _e_7787 = 1;
    assign _e_7785 = {\trunc_sp , _e_7787, val_n1};
    assign _e_10515 = \push_trig [32] == 1'd0;
    localparam[31:0] _e_7794 = 32'd1;
    assign _e_7792 = \sp  - _e_7794;
    assign trunc_sp_n1 = _e_7792[7:0];
    localparam[0:0] _e_7798 = 0;
    localparam[31:0] _e_7799 = 32'd0;
    assign _e_7796 = {trunc_sp_n1, _e_7798, _e_7799};
    always_comb begin
        priority casez ({_e_10513, _e_10515})
            2'b1?: _e_7803 = _e_7785;
            2'b01: _e_7803 = _e_7796;
            2'b?: _e_7803 = 41'dx;
        endcase
    end
    assign \addr  = _e_7803[40:33];
    assign \wren  = _e_7803[32];
    assign \wdata  = _e_7803[31:0];
    (* src = "src/stack_lsu.spade:49,17" *)
    \tta::sram::stack_ram_256x32  stack_ram_256x32_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif.clk_i(\clk ), .rst_i(\rst ), .word_idx_i(\addr ), .we_i(\wren ), .wdata_i(\wdata ), .output__(\rdata ));
    localparam[0:0] _e_7814 = 0;
    assign __n1 = \push_trig [31:0];
    assign _e_10517 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10518 = 1;
    assign _e_10519 = _e_10517 && _e_10518;
    localparam[0:0] _e_7821 = 0;
    assign _e_10521 = \push_trig [32] == 1'd0;
    localparam[0:0] _e_7823 = 1;
    always_comb begin
        priority casez ({_e_10519, _e_10521})
            2'b1?: _e_7817 = _e_7821;
            2'b01: _e_7817 = _e_7823;
            2'b?: _e_7817 = 1'dx;
        endcase
    end
    assign _e_7815 = \pop_trig  && _e_7817;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \pop_valid  <= _e_7814;
        end
        else begin
            \pop_valid  <= _e_7815;
        end
    end
    assign _e_7827 = {1'd1, \rdata };
    assign _e_7830 = {1'd0, 32'bX};
    assign _e_7824 = \pop_valid  ? _e_7827 : _e_7830;
    assign output__ = _e_7824;
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
    logic[42:0] _e_7835;
    (* src = "src/stack_lsu.spade:63,14" *)
    logic[31:0] \x ;
    logic _e_10523;
    logic _e_10525;
    logic _e_10527;
    logic _e_10528;
    (* src = "src/stack_lsu.spade:63,37" *)
    logic[32:0] _e_7837;
    (* src = "src/stack_lsu.spade:64,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:65,13" *)
    logic[42:0] _e_7843;
    (* src = "src/stack_lsu.spade:65,18" *)
    logic[31:0] x_n1;
    logic _e_10531;
    logic _e_10533;
    logic _e_10535;
    logic _e_10536;
    (* src = "src/stack_lsu.spade:65,41" *)
    logic[32:0] _e_7845;
    (* src = "src/stack_lsu.spade:66,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:66,18" *)
    logic[32:0] _e_7848;
    (* src = "src/stack_lsu.spade:64,14" *)
    logic[32:0] _e_7840;
    (* src = "src/stack_lsu.spade:62,5" *)
    logic[32:0] _e_7832;
    assign _e_7835 = \m1 [42:0];
    assign \x  = _e_7835[36:5];
    assign _e_10523 = \m1 [43] == 1'd1;
    assign _e_10525 = _e_7835[42:37] == 6'd35;
    localparam[0:0] _e_10526 = 1;
    assign _e_10527 = _e_10525 && _e_10526;
    assign _e_10528 = _e_10523 && _e_10527;
    assign _e_7837 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10529 = 1;
    assign _e_7843 = \m0 [42:0];
    assign x_n1 = _e_7843[36:5];
    assign _e_10531 = \m0 [43] == 1'd1;
    assign _e_10533 = _e_7843[42:37] == 6'd35;
    localparam[0:0] _e_10534 = 1;
    assign _e_10535 = _e_10533 && _e_10534;
    assign _e_10536 = _e_10531 && _e_10535;
    assign _e_7845 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10537 = 1;
    assign _e_7848 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10536, _e_10537})
            2'b1?: _e_7840 = _e_7845;
            2'b01: _e_7840 = _e_7848;
            2'b?: _e_7840 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10528, _e_10529})
            2'b1?: _e_7832 = _e_7837;
            2'b01: _e_7832 = _e_7840;
            2'b?: _e_7832 = 33'dx;
        endcase
    end
    assign output__ = _e_7832;
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
    logic[42:0] _e_7853;
    (* src = "src/stack_lsu.spade:73,14" *)
    logic[31:0] \x ;
    logic _e_10539;
    logic _e_10541;
    logic _e_10543;
    logic _e_10544;
    (* src = "src/stack_lsu.spade:73,42" *)
    logic[32:0] _e_7855;
    (* src = "src/stack_lsu.spade:74,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:75,13" *)
    logic[42:0] _e_7861;
    (* src = "src/stack_lsu.spade:75,18" *)
    logic[31:0] x_n1;
    logic _e_10547;
    logic _e_10549;
    logic _e_10551;
    logic _e_10552;
    (* src = "src/stack_lsu.spade:75,46" *)
    logic[32:0] _e_7863;
    (* src = "src/stack_lsu.spade:76,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:76,18" *)
    logic[32:0] _e_7866;
    (* src = "src/stack_lsu.spade:74,14" *)
    logic[32:0] _e_7858;
    (* src = "src/stack_lsu.spade:72,5" *)
    logic[32:0] _e_7850;
    assign _e_7853 = \m1 [42:0];
    assign \x  = _e_7853[36:5];
    assign _e_10539 = \m1 [43] == 1'd1;
    assign _e_10541 = _e_7853[42:37] == 6'd36;
    localparam[0:0] _e_10542 = 1;
    assign _e_10543 = _e_10541 && _e_10542;
    assign _e_10544 = _e_10539 && _e_10543;
    assign _e_7855 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10545 = 1;
    assign _e_7861 = \m0 [42:0];
    assign x_n1 = _e_7861[36:5];
    assign _e_10547 = \m0 [43] == 1'd1;
    assign _e_10549 = _e_7861[42:37] == 6'd36;
    localparam[0:0] _e_10550 = 1;
    assign _e_10551 = _e_10549 && _e_10550;
    assign _e_10552 = _e_10547 && _e_10551;
    assign _e_7863 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10553 = 1;
    assign _e_7866 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10552, _e_10553})
            2'b1?: _e_7858 = _e_7863;
            2'b01: _e_7858 = _e_7866;
            2'b?: _e_7858 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10544, _e_10545})
            2'b1?: _e_7850 = _e_7855;
            2'b01: _e_7850 = _e_7858;
            2'b?: _e_7850 = 33'dx;
        endcase
    end
    assign output__ = _e_7850;
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
    logic[42:0] _e_7870;
    logic _e_10555;
    logic _e_10557;
    logic _e_10558;
    (* src = "src/stack_lsu.spade:84,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:85,13" *)
    logic[42:0] _e_7876;
    logic _e_10561;
    logic _e_10563;
    logic _e_10564;
    (* src = "src/stack_lsu.spade:86,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:84,14" *)
    logic _e_7874;
    (* src = "src/stack_lsu.spade:82,5" *)
    logic _e_7868;
    assign _e_7870 = \m1 [42:0];
    assign _e_10555 = \m1 [43] == 1'd1;
    assign _e_10557 = _e_7870[42:37] == 6'd37;
    assign _e_10558 = _e_10555 && _e_10557;
    localparam[0:0] _e_7872 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_10559 = 1;
    assign _e_7876 = \m0 [42:0];
    assign _e_10561 = \m0 [43] == 1'd1;
    assign _e_10563 = _e_7876[42:37] == 6'd37;
    assign _e_10564 = _e_10561 && _e_10563;
    localparam[0:0] _e_7878 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_10565 = 1;
    localparam[0:0] _e_7880 = 0;
    always_comb begin
        priority casez ({_e_10564, _e_10565})
            2'b1?: _e_7874 = _e_7878;
            2'b01: _e_7874 = _e_7880;
            2'b?: _e_7874 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10558, _e_10559})
            2'b1?: _e_7868 = _e_7872;
            2'b01: _e_7868 = _e_7874;
            2'b?: _e_7868 = 1'dx;
        endcase
    end
    assign output__ = _e_7868;
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
    \std::conv::flip_array[2163]  flip_array_0(.in_i(_e_529), .output__(_e_528));
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
    \std::conv::flip_array[2164]  flip_array_0(.in_i(_e_545), .output__(_e_544));
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
    \std::conv::flip_array[2165]  flip_array_0(.in_i(_e_565), .output__(_e_564));
    assign output__ = _e_564;
endmodule

module \std::cdc::sync2[2159]  (
        input clk_i,
        input in_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::cdc::sync2[2159]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::cdc::sync2[2159] );
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

module \std::conv::impl_4::to_int[2160]  (
        input[31:0] self_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_4::to_int[2160]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_4::to_int[2160] );
        end
    end
    `endif
    logic[31:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    logic[31:0] _e_514;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    \std::conv::uint_to_int[2166]  uint_to_int_0(.input_i(\self ), .output__(_e_514));
    assign output__ = _e_514;
endmodule

module \std::conv::impl_3::to_uint[2161]  (
        input[31:0] self_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_3::to_uint[2161]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_3::to_uint[2161] );
        end
    end
    `endif
    logic[31:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:153,9" *)
    logic[31:0] _e_508;
    (* src = "<compiler dir>/stdlib/conv.spade:153,9" *)
    \std::conv::int_to_uint[2167]  int_to_uint_0(.input_i(\self ), .output__(_e_508));
    assign output__ = _e_508;
endmodule

module \std::conv::impl_4::to_int[2162]  (
        input[15:0] self_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_4::to_int[2162]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_4::to_int[2162] );
        end
    end
    `endif
    logic[15:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    logic[15:0] _e_514;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    \std::conv::uint_to_int[2168]  uint_to_int_0(.input_i(\self ), .output__(_e_514));
    assign output__ = _e_514;
endmodule

module \std::conv::flip_array[2163]  (
        input[15:0] in_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2163]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2163] );
        end
    end
    `endif
    logic[15:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[15:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2169]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::flip_array[2164]  (
        input[23:0] in_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2164]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2164] );
        end
    end
    `endif
    logic[23:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[23:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2170]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::flip_array[2165]  (
        input[31:0] in_i,
        output[31:0] output__
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
    logic[31:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[31:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2171]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::uint_to_int[2166]  (
        input[31:0] input_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::uint_to_int[2166]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::uint_to_int[2166] );
        end
    end
    `endif
    logic[31:0] \input ;
    assign \input  = input_i;
    logic[31:0] _e_479;
    assign _e_479 = \input ;
    assign output__ = _e_479;
endmodule

module \std::conv::int_to_uint[2167]  (
        input[31:0] input_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::int_to_uint[2167]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::int_to_uint[2167] );
        end
    end
    `endif
    logic[31:0] \input ;
    assign \input  = input_i;
    logic[31:0] _e_483;
    assign _e_483 = \input ;
    assign output__ = _e_483;
endmodule

module \std::conv::uint_to_int[2168]  (
        input[15:0] input_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::uint_to_int[2168]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::uint_to_int[2168] );
        end
    end
    `endif
    logic[15:0] \input ;
    assign \input  = input_i;
    logic[15:0] _e_479;
    assign _e_479 = \input ;
    assign output__ = _e_479;
endmodule

module \std::conv::std::conv::flip_array::F[2169]  (
        input[15:0] in_i,
        output[15:0] output__
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
    \std::conv::flip_array[2172]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2173]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::std::conv::flip_array::F[2170]  (
        input[23:0] in_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2170]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2170] );
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
    \std::conv::flip_array[2163]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2174]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::std::conv::flip_array::F[2171]  (
        input[31:0] in_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2171]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2171] );
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
    \std::conv::flip_array[2164]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2175]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::flip_array[2172]  (
        input[7:0] in_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2172]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2172] );
        end
    end
    `endif
    logic[7:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[7:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2176]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::concat_arrays[2173]  (
        input[7:0] l_i,
        input[7:0] r_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2173]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2173] );
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

module \std::conv::concat_arrays[2174]  (
        input[7:0] l_i,
        input[15:0] r_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2174]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2174] );
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

module \std::conv::concat_arrays[2175]  (
        input[7:0] l_i,
        input[23:0] r_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2175]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2175] );
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

module \std::conv::std::conv::flip_array::F[2176]  (
        input[7:0] in_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2176]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2176] );
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
    \std::conv::flip_array[2177]  flip_array_0();
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2178]  concat_arrays_0(.l_i(_e_441), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::flip_array[2177]  (
        
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2177]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2177] );
        end
    end
    `endif
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::T[2179]  T_0();
endmodule

module \std::conv::concat_arrays[2178]  (
        input[7:0] l_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2178]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2178] );
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

module \std::conv::std::conv::flip_array::T[2179]  (
        
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::T[2179]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::T[2179] );
        end
    end
    `endif
    
endmodule