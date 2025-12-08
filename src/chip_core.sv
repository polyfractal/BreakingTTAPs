
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
    \std::cdc::sync2[2136]  sync2_0(.clk_i(\clk ), .in_i(\in ), .output__(_e_137));
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
    (* src = "src/sram.spade:50,35" *)
    logic[15:0] _e_1140;
    (* src = "src/sram.spade:50,29" *)
    logic[8:0] \word_idx ;
    (* src = "src/sram.spade:53,23" *)
    logic[7:0] \d0 ;
    (* src = "src/sram.spade:54,29" *)
    logic[31:0] _e_1148;
    (* src = "src/sram.spade:54,23" *)
    logic[7:0] \d1 ;
    (* src = "src/sram.spade:55,29" *)
    logic[31:0] _e_1153;
    (* src = "src/sram.spade:55,23" *)
    logic[7:0] \d2 ;
    (* src = "src/sram.spade:56,29" *)
    logic[31:0] _e_1158;
    (* src = "src/sram.spade:56,23" *)
    logic[7:0] \d3 ;
    (* src = "src/sram.spade:64,9" *)
    logic \cen ;
    (* src = "src/sram.spade:67,25" *)
    logic \gwen ;
    (* src = "src/sram.spade:68,25" *)
    logic[7:0] \wen ;
    (* src = "src/sram.spade:71,22" *)
    logic[7:0] _e_7793;
    (* src = "src/sram.spade:71,22" *)
    logic[7:0] _e_7794_mut;
    (* src = "src/sram.spade:71,22" *)
    logic[7:0] _e_1181;
    (* src = "src/sram.spade:71,22" *)
    logic[7:0] _e_1181_mut;
    (* src = "src/sram.spade:71,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:71,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:72,22" *)
    logic[7:0] _e_7795;
    (* src = "src/sram.spade:72,22" *)
    logic[7:0] _e_7796_mut;
    (* src = "src/sram.spade:72,22" *)
    logic[7:0] _e_1185;
    (* src = "src/sram.spade:72,22" *)
    logic[7:0] _e_1185_mut;
    (* src = "src/sram.spade:72,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:72,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:73,22" *)
    logic[7:0] _e_7797;
    (* src = "src/sram.spade:73,22" *)
    logic[7:0] _e_7798_mut;
    (* src = "src/sram.spade:73,22" *)
    logic[7:0] _e_1189;
    (* src = "src/sram.spade:73,22" *)
    logic[7:0] _e_1189_mut;
    (* src = "src/sram.spade:73,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:73,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:74,22" *)
    logic[7:0] _e_7799;
    (* src = "src/sram.spade:74,22" *)
    logic[7:0] _e_7800_mut;
    (* src = "src/sram.spade:74,22" *)
    logic[7:0] _e_1193;
    (* src = "src/sram.spade:74,22" *)
    logic[7:0] _e_1193_mut;
    (* src = "src/sram.spade:74,9" *)
    logic[7:0] \qr3 ;
    (* src = "src/sram.spade:74,9" *)
    logic[7:0] \qw3_mut ;
    logic[31:0] _e_1233;
    logic[31:0] _e_1237;
    (* src = "src/sram.spade:83,9" *)
    logic[31:0] _e_1236;
    (* src = "src/sram.spade:82,9" *)
    logic[31:0] _e_1232;
    logic[31:0] _e_1242;
    (* src = "src/sram.spade:84,9" *)
    logic[31:0] _e_1241;
    (* src = "src/sram.spade:82,9" *)
    logic[31:0] _e_1231;
    logic[31:0] _e_1247;
    (* src = "src/sram.spade:85,9" *)
    logic[31:0] _e_1246;
    (* src = "src/sram.spade:82,9" *)
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
    
    assign _e_7793 = _e_7794_mut;
    assign _e_1181 = {_e_7793};
    assign {_e_7794_mut} = _e_1181_mut;
    assign \qr0  = _e_1181[7:0];
    assign _e_1181_mut[7:0] = \qw0_mut ;
    
    assign _e_7795 = _e_7796_mut;
    assign _e_1185 = {_e_7795};
    assign {_e_7796_mut} = _e_1185_mut;
    assign \qr1  = _e_1185[7:0];
    assign _e_1185_mut[7:0] = \qw1_mut ;
    
    assign _e_7797 = _e_7798_mut;
    assign _e_1189 = {_e_7797};
    assign {_e_7798_mut} = _e_1189_mut;
    assign \qr2  = _e_1189[7:0];
    assign _e_1189_mut[7:0] = \qw2_mut ;
    
    assign _e_7799 = _e_7800_mut;
    assign _e_1193 = {_e_7799};
    assign {_e_7800_mut} = _e_1193_mut;
    assign \qr3  = _e_1193[7:0];
    assign _e_1193_mut[7:0] = \qw3_mut ;
    (* src = "src/sram.spade:75,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_0(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif
        .CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d0 ), .Q(\qw0_mut ));
    (* src = "src/sram.spade:76,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_1(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif
        .CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d1 ), .Q(\qw1_mut ));
    (* src = "src/sram.spade:77,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_2(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif
        .CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d2 ), .Q(\qw2_mut ));
    (* src = "src/sram.spade:78,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_3(
        `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif
        .CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d3 ), .Q(\qw3_mut ));
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
    (* src = "src/sram.spade:100,23" *)
    logic[7:0] \d0 ;
    (* src = "src/sram.spade:101,29" *)
    logic[31:0] _e_1258;
    (* src = "src/sram.spade:101,23" *)
    logic[7:0] \d1 ;
    (* src = "src/sram.spade:102,29" *)
    logic[31:0] _e_1263;
    (* src = "src/sram.spade:102,23" *)
    logic[7:0] \d2 ;
    (* src = "src/sram.spade:103,29" *)
    logic[31:0] _e_1268;
    (* src = "src/sram.spade:103,23" *)
    logic[7:0] \d3 ;
    (* src = "src/sram.spade:106,9" *)
    logic \cen ;
    (* src = "src/sram.spade:107,25" *)
    logic \gwen ;
    (* src = "src/sram.spade:108,25" *)
    logic[7:0] \wen ;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_7801;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_7802_mut;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_1291;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_1291_mut;
    (* src = "src/sram.spade:111,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:111,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_7803;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_7804_mut;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_1295;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_1295_mut;
    (* src = "src/sram.spade:112,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:112,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_7805;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_7806_mut;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_1299;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_1299_mut;
    (* src = "src/sram.spade:113,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:113,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:114,22" *)
    logic[7:0] _e_7807;
    (* src = "src/sram.spade:114,22" *)
    logic[7:0] _e_7808_mut;
    (* src = "src/sram.spade:114,22" *)
    logic[7:0] _e_1303;
    (* src = "src/sram.spade:114,22" *)
    logic[7:0] _e_1303_mut;
    (* src = "src/sram.spade:114,9" *)
    logic[7:0] \qr3 ;
    (* src = "src/sram.spade:114,9" *)
    logic[7:0] \qw3_mut ;
    logic[31:0] _e_1343;
    logic[31:0] _e_1347;
    (* src = "src/sram.spade:123,9" *)
    logic[31:0] _e_1346;
    (* src = "src/sram.spade:122,9" *)
    logic[31:0] _e_1342;
    logic[31:0] _e_1352;
    (* src = "src/sram.spade:124,9" *)
    logic[31:0] _e_1351;
    (* src = "src/sram.spade:122,9" *)
    logic[31:0] _e_1341;
    logic[31:0] _e_1357;
    (* src = "src/sram.spade:125,9" *)
    logic[31:0] _e_1356;
    (* src = "src/sram.spade:122,9" *)
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
    
    assign _e_7801 = _e_7802_mut;
    assign _e_1291 = {_e_7801};
    assign {_e_7802_mut} = _e_1291_mut;
    assign \qr0  = _e_1291[7:0];
    assign _e_1291_mut[7:0] = \qw0_mut ;
    
    assign _e_7803 = _e_7804_mut;
    assign _e_1295 = {_e_7803};
    assign {_e_7804_mut} = _e_1295_mut;
    assign \qr1  = _e_1295[7:0];
    assign _e_1295_mut[7:0] = \qw1_mut ;
    
    assign _e_7805 = _e_7806_mut;
    assign _e_1299 = {_e_7805};
    assign {_e_7806_mut} = _e_1299_mut;
    assign \qr2  = _e_1299[7:0];
    assign _e_1299_mut[7:0] = \qw2_mut ;
    
    assign _e_7807 = _e_7808_mut;
    assign _e_1303 = {_e_7807};
    assign {_e_7808_mut} = _e_1303_mut;
    assign \qr3  = _e_1303[7:0];
    assign _e_1303_mut[7:0] = \qw3_mut ;
    (* src = "src/sram.spade:115,13" *)
    gf180mcu_fd_ip_sram__sram256x8m8wm1 gf180mcu_fd_ip_sram__sram256x8m8wm1_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d0 ), .Q(\qw0_mut ));
    (* src = "src/sram.spade:116,13" *)
    gf180mcu_fd_ip_sram__sram256x8m8wm1 gf180mcu_fd_ip_sram__sram256x8m8wm1_1(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d1 ), .Q(\qw1_mut ));
    (* src = "src/sram.spade:117,13" *)
    gf180mcu_fd_ip_sram__sram256x8m8wm1 gf180mcu_fd_ip_sram__sram256x8m8wm1_2(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d2 ), .Q(\qw2_mut ));
    (* src = "src/sram.spade:118,13" *)
    gf180mcu_fd_ip_sram__sram256x8m8wm1 gf180mcu_fd_ip_sram__sram256x8m8wm1_3(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\word_idx ), .D(\d3 ), .Q(\qw3_mut ));
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
    (* src = "src/sram.spade:142,23" *)
    logic[7:0] \d0 ;
    (* src = "src/sram.spade:143,29" *)
    logic[31:0] _e_1368;
    (* src = "src/sram.spade:143,23" *)
    logic[7:0] \d1 ;
    (* src = "src/sram.spade:144,29" *)
    logic[31:0] _e_1373;
    (* src = "src/sram.spade:144,23" *)
    logic[7:0] \d2 ;
    (* src = "src/sram.spade:145,29" *)
    logic[31:0] _e_1378;
    (* src = "src/sram.spade:145,23" *)
    logic[7:0] \d3 ;
    (* src = "src/sram.spade:154,9" *)
    logic \cen ;
    (* src = "src/sram.spade:156,25" *)
    logic \gwen ;
    (* src = "src/sram.spade:157,25" *)
    logic[7:0] \wen ;
    (* src = "src/sram.spade:160,22" *)
    logic[7:0] _e_7809;
    (* src = "src/sram.spade:160,22" *)
    logic[7:0] _e_7810_mut;
    (* src = "src/sram.spade:160,22" *)
    logic[7:0] _e_1401;
    (* src = "src/sram.spade:160,22" *)
    logic[7:0] _e_1401_mut;
    (* src = "src/sram.spade:160,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:160,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:161,22" *)
    logic[7:0] _e_7811;
    (* src = "src/sram.spade:161,22" *)
    logic[7:0] _e_7812_mut;
    (* src = "src/sram.spade:161,22" *)
    logic[7:0] _e_1405;
    (* src = "src/sram.spade:161,22" *)
    logic[7:0] _e_1405_mut;
    (* src = "src/sram.spade:161,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:161,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:162,22" *)
    logic[7:0] _e_7813;
    (* src = "src/sram.spade:162,22" *)
    logic[7:0] _e_7814_mut;
    (* src = "src/sram.spade:162,22" *)
    logic[7:0] _e_1409;
    (* src = "src/sram.spade:162,22" *)
    logic[7:0] _e_1409_mut;
    (* src = "src/sram.spade:162,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:162,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_7815;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_7816_mut;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_1413;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_1413_mut;
    (* src = "src/sram.spade:163,9" *)
    logic[7:0] \qr3 ;
    (* src = "src/sram.spade:163,9" *)
    logic[7:0] \qw3_mut ;
    logic[31:0] _e_1453;
    logic[31:0] _e_1457;
    (* src = "src/sram.spade:172,9" *)
    logic[31:0] _e_1456;
    (* src = "src/sram.spade:171,9" *)
    logic[31:0] _e_1452;
    logic[31:0] _e_1462;
    (* src = "src/sram.spade:173,9" *)
    logic[31:0] _e_1461;
    (* src = "src/sram.spade:171,9" *)
    logic[31:0] _e_1451;
    logic[31:0] _e_1467;
    (* src = "src/sram.spade:174,9" *)
    logic[31:0] _e_1466;
    (* src = "src/sram.spade:171,9" *)
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
    
    assign _e_7809 = _e_7810_mut;
    assign _e_1401 = {_e_7809};
    assign {_e_7810_mut} = _e_1401_mut;
    assign \qr0  = _e_1401[7:0];
    assign _e_1401_mut[7:0] = \qw0_mut ;
    
    assign _e_7811 = _e_7812_mut;
    assign _e_1405 = {_e_7811};
    assign {_e_7812_mut} = _e_1405_mut;
    assign \qr1  = _e_1405[7:0];
    assign _e_1405_mut[7:0] = \qw1_mut ;
    
    assign _e_7813 = _e_7814_mut;
    assign _e_1409 = {_e_7813};
    assign {_e_7814_mut} = _e_1409_mut;
    assign \qr2  = _e_1409[7:0];
    assign _e_1409_mut[7:0] = \qw2_mut ;
    
    assign _e_7815 = _e_7816_mut;
    assign _e_1413 = {_e_7815};
    assign {_e_7816_mut} = _e_1413_mut;
    assign \qr3  = _e_1413[7:0];
    assign _e_1413_mut[7:0] = \qw3_mut ;
    (* src = "src/sram.spade:164,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\addr ), .D(\d0 ), .Q(\qw0_mut ));
    (* src = "src/sram.spade:165,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_1(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\addr ), .D(\d1 ), .Q(\qw1_mut ));
    (* src = "src/sram.spade:166,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_2(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\addr ), .D(\d2 ), .Q(\qw2_mut ));
    (* src = "src/sram.spade:167,13" *)
    gf180mcu_fd_ip_sram__sram512x8m8wm1 gf180mcu_fd_ip_sram__sram512x8m8wm1_3(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.CLK(\clk ), .CEN(\cen ), .GWEN(\gwen ), .WEN(\wen ), .A(\addr ), .D(\d3 ), .Q(\qw3_mut ));
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
    (* src = "src/sram.spade:186,26" *)
    logic[8:0] \index ;
    (* src = "src/sram.spade:187,28" *)
    logic _e_1478;
    (* src = "src/sram.spade:187,25" *)
    logic \bank ;
    (* src = "src/sram.spade:190,15" *)
    logic \en0 ;
    (* src = "src/sram.spade:191,15" *)
    logic \en1 ;
    (* src = "src/sram.spade:194,15" *)
    logic \we0 ;
    (* src = "src/sram.spade:195,15" *)
    logic \we1 ;
    (* src = "src/sram.spade:198,18" *)
    logic[31:0] \rdata0 ;
    (* src = "src/sram.spade:199,18" *)
    logic[31:0] \rdata1 ;
    (* src = "src/sram.spade:203,14" *)
    reg \bank_d ;
    (* src = "src/sram.spade:205,8" *)
    logic _e_1524;
    (* src = "src/sram.spade:205,5" *)
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
    (* src = "src/sram.spade:198,18" *)
    \tta::sram::iram_512x32  iram_512x32_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .en_i(\en0 ), .addr_i(\index ), .we_i(\we0 ), .wdata_i(\wdata ), .output__(\rdata0 ));
    (* src = "src/sram.spade:199,18" *)
    \tta::sram::iram_512x32  iram_512x32_1(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .en_i(\en1 ), .addr_i(\index ), .we_i(\we1 ), .wdata_i(\wdata ), .output__(\rdata1 ));
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
    (* src = "src/main.spade:77,24" *)
    logic[9:0] _e_7817;
    (* src = "src/main.spade:77,24" *)
    logic[9:0] _e_7818_mut;
    (* src = "src/main.spade:77,24" *)
    logic[9:0] _e_1535;
    (* src = "src/main.spade:77,24" *)
    logic[9:0] _e_1535_mut;
    (* src = "src/main.spade:77,9" *)
    logic[9:0] \pc_r ;
    (* src = "src/main.spade:77,9" *)
    logic[9:0] \pc_w_mut ;
    (* src = "src/main.spade:79,25" *)
    logic[8:0] \parallel_data ;
    (* src = "src/main.spade:83,28" *)
    logic[8:0] _e_7819;
    (* src = "src/main.spade:83,28" *)
    logic[8:0] _e_7820_mut;
    (* src = "src/main.spade:83,28" *)
    logic[8:0] _e_1547;
    (* src = "src/main.spade:83,28" *)
    logic[8:0] _e_1547_mut;
    (* src = "src/main.spade:83,9" *)
    logic[8:0] \mosi_r ;
    (* src = "src/main.spade:83,9" *)
    logic[8:0] \mosi_w_mut ;
    (* src = "src/main.spade:84,16" *)
    logic \tick ;
    (* src = "src/main.spade:85,20" *)
    logic[11:0] \spi_data ;
    (* src = "src/main.spade:86,17" *)
    logic _e_1561;
    (* src = "src/main.spade:87,21" *)
    logic _e_1565;
    (* src = "src/main.spade:87,20" *)
    logic \spi_busy ;
    (* src = "src/main.spade:89,34" *)
    logic[8:0] _e_7821;
    (* src = "src/main.spade:89,34" *)
    logic[8:0] _e_7822_mut;
    (* src = "src/main.spade:89,34" *)
    logic[8:0] _e_1571;
    (* src = "src/main.spade:89,34" *)
    logic[8:0] _e_1571_mut;
    (* src = "src/main.spade:89,9" *)
    logic[8:0] \uart_tx_r ;
    (* src = "src/main.spade:89,9" *)
    logic[8:0] \uart_tx_w_mut ;
    (* src = "src/main.spade:90,20" *)
    logic[10:0] \uart_out ;
    (* src = "src/main.spade:91,20" *)
    logic _e_1580;
    (* src = "src/main.spade:93,29" *)
    logic[109:0] \subsys ;
    (* src = "src/main.spade:101,56" *)
    logic[10:0] _e_1595;
    (* src = "src/main.spade:101,55" *)
    logic[11:0] _e_1594;
    (* src = "src/main.spade:102,7" *)
    logic[11:0] _e_1601;
    (* src = "src/main.spade:102,7" *)
    logic[10:0] _e_1599;
    (* src = "src/main.spade:102,8" *)
    logic[9:0] \v ;
    (* src = "src/main.spade:102,7" *)
    logic \_ ;
    logic _e_7825;
    logic _e_7827;
    logic _e_7829;
    (* src = "src/main.spade:103,7" *)
    logic[11:0] _e_1605;
    (* src = "src/main.spade:103,7" *)
    logic[10:0] _e_1603;
    (* src = "src/main.spade:103,7" *)
    logic _e_1604;
    logic _e_7832;
    logic _e_7834;
    (* src = "src/main.spade:104,7" *)
    logic[11:0] _e_1609;
    (* src = "src/main.spade:104,7" *)
    logic[10:0] __n1;
    (* src = "src/main.spade:104,7" *)
    logic __n2;
    logic _e_7838;
    (* src = "src/main.spade:101,49" *)
    logic _e_1593;
    (* src = "src/main.spade:101,14" *)
    reg \released ;
    (* src = "src/main.spade:108,15" *)
    logic[97:0] _e_1614;
    logic _e_7840;
    (* src = "src/main.spade:109,16" *)
    logic[97:0] _e_1617;
    (* src = "src/main.spade:107,17" *)
    logic[97:0] \instr ;
    (* src = "src/main.spade:115,9" *)
    logic _e_1621;
    (* src = "src/main.spade:119,9" *)
    logic[8:0] _e_1627;
    (* src = "src/main.spade:121,9" *)
    logic _e_1630;
    (* src = "src/main.spade:122,9" *)
    logic[8:0] _e_1632;
    (* src = "src/main.spade:113,19" *)
    logic[509:0] \tta_out ;
    (* src = "src/main.spade:126,18" *)
    logic[15:0] _e_1638;
    (* src = "src/main.spade:130,9" *)
    logic _e_1642;
    (* src = "src/main.spade:131,9" *)
    logic[9:0] _e_1644;
    (* src = "src/main.spade:132,9" *)
    logic[10:0] _e_1646;
    (* src = "src/main.spade:133,9" *)
    logic[98:0] _e_1648;
    (* src = "src/main.spade:134,9" *)
    logic[15:0] _e_1650;
    (* src = "src/main.spade:129,5" *)
    logic[136:0] _e_1641;
    
    assign _e_7817 = _e_7818_mut;
    assign _e_1535 = {_e_7817};
    assign {_e_7818_mut} = _e_1535_mut;
    assign \pc_r  = _e_1535[9:0];
    assign _e_1535_mut[9:0] = \pc_w_mut ;
    (* src = "src/main.spade:79,25" *)
    \tta::parallel_rx::parallel_boot  parallel_boot_0(.clk_i(\clk ), .rst_i(\rst ), .data_in_i(\parallel_in ), .strobe_i(\parallel_strobe ), .clk_pin_i(\parallel_clock ), .output__(\parallel_data ));
    
    assign _e_7819 = _e_7820_mut;
    assign _e_1547 = {_e_7819};
    assign {_e_7820_mut} = _e_1547_mut;
    assign \mosi_r  = _e_1547[8:0];
    assign _e_1547_mut[8:0] = \mosi_w_mut ;
    localparam[15:0] _e_1551 = 10;
    (* src = "src/main.spade:84,16" *)
    \tta::tick_generator  tick_generator_0(.clk_i(\clk ), .rst_i(\rst ), .period_i(_e_1551), .output__(\tick ));
    (* src = "src/main.spade:85,20" *)
    \tta::spi_master::spi_master  spi_master_0(.clk_i(\clk ), .rst_i(\rst ), .tick_i(\tick ), .miso_i(\miso ), .start_tx_i(\mosi_r ), .output__(\spi_data ));
    assign _e_1561 = \spi_data [9];
    assign \mosi_mut  = _e_1561;
    assign _e_1565 = \spi_data [11];
    assign \spi_busy  = !_e_1565;
    
    assign _e_7821 = _e_7822_mut;
    assign _e_1571 = {_e_7821};
    assign {_e_7822_mut} = _e_1571_mut;
    assign \uart_tx_r  = _e_1571[8:0];
    assign _e_1571_mut[8:0] = \uart_tx_w_mut ;
    (* src = "src/main.spade:90,20" *)
    \tta::uart::uart_fu  uart_fu_0(.clk_i(\clk ), .rst_i(\rst ), .tick16_i(\uart_tick16 ), .rx_in_i(\uart_rx ), .tx_data_i(\uart_tx_r ), .output__(\uart_out ));
    assign _e_1580 = \uart_out [10];
    assign \uart_tx_mut  = _e_1580;
    (* src = "src/main.spade:93,29" *)
    \tta::boot_imem_subsystem::boot_imem_sub  boot_imem_sub_0(
                `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif
.clk_i(\clk ), .rst_i(\rst ), .rx_opt_i(\parallel_data ), .fetch_pc_i(\pc_r ), .output__(\subsys ));
    localparam[0:0] _e_1592 = 0;
    assign _e_1595 = \subsys [10:0];
    assign _e_1594 = {_e_1595, \released };
    assign _e_1601 = _e_1594;
    assign _e_1599 = _e_1594[11:1];
    assign \v  = _e_1599[9:0];
    assign \_  = _e_1594[0];
    assign _e_7825 = _e_1599[10] == 1'd1;
    localparam[0:0] _e_7826 = 1;
    assign _e_7827 = _e_7825 && _e_7826;
    localparam[0:0] _e_7828 = 1;
    assign _e_7829 = _e_7827 && _e_7828;
    localparam[0:0] _e_1602 = 1;
    assign _e_1605 = _e_1594;
    assign _e_1603 = _e_1594[11:1];
    assign _e_1604 = _e_1594[0];
    assign _e_7832 = _e_1603[10] == 1'd0;
    assign _e_7834 = _e_7832 && _e_1604;
    localparam[0:0] _e_1606 = 1;
    assign _e_1609 = _e_1594;
    assign __n1 = _e_1594[11:1];
    assign __n2 = _e_1594[0];
    localparam[0:0] _e_7836 = 1;
    localparam[0:0] _e_7837 = 1;
    assign _e_7838 = _e_7836 && _e_7837;
    localparam[0:0] _e_1610 = 0;
    always_comb begin
        priority casez ({_e_7829, _e_7834, _e_7838})
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
    assign _e_7840 = !\released ;
    (* src = "src/main.spade:109,16" *)
    \tta::noop  noop_0(.output__(_e_1617));
    always_comb begin
        priority casez ({\released , _e_7840})
            2'b1?: \instr  = _e_1614;
            2'b01: \instr  = _e_1617;
            2'b?: \instr  = 98'dx;
        endcase
    end
    assign _e_1621 = !\released ;
    assign _e_1627 = \uart_out [9:1];
    assign _e_1630 = \uart_out [0];
    assign _e_1632 = \spi_data [8:0];
    (* src = "src/main.spade:113,19" *)
    \tta::tta::tta  tta_0(
                `ifdef USE_POWER_PINS
        .VDD  (VDD),
        .VSS  (VSS),
        `endif
.clk_i(\clk ), .rst_i(_e_1621), .insn_i(\instr ), .pc_w_o(\pc_w_mut ), .gpi16_i(\gpi16 ), .uart_rx_i(_e_1627), .uart_tx_o(\uart_tx_w_mut ), .uart_tx_busy_i(_e_1630), .spi_miso_i(_e_1632), .spi_mosi_o(\mosi_w_mut ), .spi_busy_i(\spi_busy ), .output__(\tta_out ));
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
    (* src = "src/main.spade:141,16" *)
    logic[36:0] _e_1655;
    (* src = "src/main.spade:141,27" *)
    logic[10:0] _e_1656;
    (* src = "src/main.spade:141,11" *)
    logic[48:0] _e_1654;
    (* src = "src/main.spade:142,16" *)
    logic[36:0] _e_1659;
    (* src = "src/main.spade:142,27" *)
    logic[10:0] _e_1660;
    (* src = "src/main.spade:142,11" *)
    logic[48:0] _e_1658;
    (* src = "src/main.spade:140,3" *)
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
    (* src = "src/main.spade:149,21" *)
    logic[16:0] _e_1670;
    (* src = "src/main.spade:149,12" *)
    logic _e_1668;
    (* src = "src/main.spade:149,51" *)
    logic[17:0] _e_1677;
    (* src = "src/main.spade:149,45" *)
    logic[16:0] _e_1676;
    (* src = "src/main.spade:149,9" *)
    logic[16:0] _e_1667;
    (* src = "src/main.spade:148,14" *)
    reg[16:0] \count ;
    (* src = "src/main.spade:151,5" *)
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
    logic _e_7842;
    (* src = "src/uart.spade:62,27" *)
    logic[8:0] _e_1713;
    (* src = "src/uart.spade:63,25" *)
    logic[8:0] _e_1716;
    (* src = "src/uart.spade:63,25" *)
    logic[7:0] \data ;
    logic _e_7844;
    logic _e_7846;
    (* src = "src/uart.spade:66,36" *)
    logic[1:0] _e_1719;
    (* src = "src/uart.spade:66,29" *)
    logic[17:0] _e_1718;
    (* src = "src/uart.spade:68,25" *)
    logic[8:0] _e_1723;
    logic _e_7848;
    (* src = "src/uart.spade:62,21" *)
    logic[17:0] _e_1712;
    (* src = "src/uart.spade:71,17" *)
    logic[1:0] _e_1725;
    logic _e_7850;
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
    logic _e_7852;
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
    logic _e_7854;
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
    logic _e_7856;
    (* src = "src/uart.spade:106,9" *)
    logic[1:0] _e_1810;
    logic _e_7858;
    (* src = "src/uart.spade:107,9" *)
    logic[1:0] _e_1812;
    logic _e_7860;
    (* src = "src/uart.spade:107,27" *)
    logic[7:0] _e_1815;
    (* src = "src/uart.spade:107,26" *)
    logic[7:0] _e_1814;
    (* src = "src/uart.spade:107,26" *)
    logic _e_1813;
    (* src = "src/uart.spade:108,9" *)
    logic[1:0] _e_1819;
    logic _e_7862;
    (* src = "src/uart.spade:104,18" *)
    logic \tx_out ;
    (* src = "src/uart.spade:111,25" *)
    logic[1:0] _e_1823;
    (* src = "src/uart.spade:112,9" *)
    logic[1:0] _e_1825;
    logic _e_7864;
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
    logic _e_7867;
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
    logic _e_7869;
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
    logic _e_7871;
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
    logic _e_7873;
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
    logic _e_7875;
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
    assign _e_7842 = _e_1708[1:0] == 2'd0;
    assign _e_1713 = \tx_data ;
    assign _e_1716 = _e_1713;
    assign \data  = _e_1713[7:0];
    assign _e_7844 = _e_1713[8] == 1'd1;
    localparam[0:0] _e_7845 = 1;
    assign _e_7846 = _e_7844 && _e_7845;
    assign _e_1719 = {2'd1};
    localparam[3:0] _e_1721 = 0;
    localparam[3:0] _e_1722 = 0;
    assign _e_1718 = {_e_1719, \data , _e_1721, _e_1722};
    assign _e_1723 = _e_1713;
    assign _e_7848 = _e_1713[8] == 1'd0;
    always_comb begin
        priority casez ({_e_7846, _e_7848})
            2'b1?: _e_1712 = _e_1718;
            2'b01: _e_1712 = \tx ;
            2'b?: _e_1712 = 18'dx;
        endcase
    end
    assign _e_1725 = _e_1708;
    assign _e_7850 = _e_1708[1:0] == 2'd1;
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
    assign _e_7852 = _e_1708[1:0] == 2'd2;
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
    assign _e_7854 = _e_1708[1:0] == 2'd3;
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
        priority casez ({_e_7842, _e_7850, _e_7852, _e_7854})
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
    assign _e_7856 = _e_1806[1:0] == 2'd0;
    localparam[0:0] _e_1809 = 1;
    assign _e_1810 = _e_1806;
    assign _e_7858 = _e_1806[1:0] == 2'd1;
    localparam[0:0] _e_1811 = 0;
    assign _e_1812 = _e_1806;
    assign _e_7860 = _e_1806[1:0] == 2'd2;
    assign _e_1815 = \tx [15:8];
    localparam[7:0] _e_1817 = 1;
    assign _e_1814 = _e_1815 & _e_1817;
    localparam[7:0] _e_1818 = 0;
    assign _e_1813 = _e_1814 != _e_1818;
    assign _e_1819 = _e_1806;
    assign _e_7862 = _e_1806[1:0] == 2'd3;
    localparam[0:0] _e_1820 = 1;
    always_comb begin
        priority casez ({_e_7856, _e_7858, _e_7860, _e_7862})
            4'b1???: \tx_out  = _e_1809;
            4'b01??: \tx_out  = _e_1811;
            4'b001?: \tx_out  = _e_1813;
            4'b0001: \tx_out  = _e_1820;
            4'b?: \tx_out  = 1'dx;
        endcase
    end
    assign _e_1823 = \tx [17:16];
    assign _e_1825 = _e_1823;
    assign _e_7864 = _e_1823[1:0] == 2'd0;
    localparam[0:0] _e_1826 = 0;
    assign \_  = _e_1823;
    localparam[0:0] _e_7865 = 1;
    localparam[0:0] _e_1828 = 1;
    always_comb begin
        priority casez ({_e_7864, _e_7865})
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
    assign _e_7867 = _e_1856[1:0] == 2'd0;
    assign _e_1861 = !\rxd ;
    assign _e_1865 = {2'd1};
    localparam[7:0] _e_1866 = 0;
    localparam[2:0] _e_1867 = 0;
    localparam[3:0] _e_1868 = 0;
    assign _e_1864 = {_e_1865, _e_1866, _e_1867, _e_1868};
    assign _e_1860 = _e_1861 ? _e_1864 : \rx ;
    assign _e_1871 = _e_1856;
    assign _e_7869 = _e_1856[1:0] == 2'd1;
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
    assign _e_7871 = _e_1856[1:0] == 2'd2;
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
    assign _e_7873 = _e_1856[1:0] == 2'd3;
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
        priority casez ({_e_7867, _e_7869, _e_7871, _e_7873})
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
    assign _e_7875 = _e_1993[1:0] == 2'd3;
    assign _e_1997 = \rx [3:0];
    localparam[3:0] _e_1999 = 15;
    assign _e_1996 = _e_1997 == _e_1999;
    assign __n1 = _e_1993;
    localparam[0:0] _e_7876 = 1;
    localparam[0:0] _e_2001 = 0;
    always_comb begin
        priority casez ({_e_7875, _e_7876})
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
    (* src = "src/alu.spade:23,9" *)
    logic[31:0] \v ;
    logic _e_7878;
    logic _e_7880;
    logic _e_7882;
    (* src = "src/alu.spade:22,45" *)
    logic[31:0] _e_2021;
    (* src = "src/alu.spade:22,14" *)
    reg[31:0] \op_a ;
    (* src = "src/alu.spade:30,9" *)
    logic[36:0] _e_2032;
    (* src = "src/alu.spade:30,14" *)
    logic[4:0] _e_2030;
    (* src = "src/alu.spade:30,14" *)
    logic[31:0] \b ;
    logic _e_7884;
    logic _e_7887;
    logic _e_7889;
    logic _e_7890;
    (* src = "src/alu.spade:30,45" *)
    logic[32:0] _e_2036;
    (* src = "src/alu.spade:30,39" *)
    logic[31:0] _e_2035;
    (* src = "src/alu.spade:30,34" *)
    logic[32:0] _e_2034;
    (* src = "src/alu.spade:31,9" *)
    logic[36:0] _e_2041;
    (* src = "src/alu.spade:31,14" *)
    logic[4:0] _e_2039;
    (* src = "src/alu.spade:31,14" *)
    logic[31:0] b_n1;
    logic _e_7892;
    logic _e_7895;
    logic _e_7897;
    logic _e_7898;
    (* src = "src/alu.spade:31,45" *)
    logic[32:0] _e_2045;
    (* src = "src/alu.spade:31,39" *)
    logic[31:0] _e_2044;
    (* src = "src/alu.spade:31,34" *)
    logic[32:0] _e_2043;
    (* src = "src/alu.spade:32,9" *)
    logic[36:0] _e_2050;
    (* src = "src/alu.spade:32,14" *)
    logic[4:0] _e_2048;
    (* src = "src/alu.spade:32,14" *)
    logic[31:0] b_n2;
    logic _e_7900;
    logic _e_7903;
    logic _e_7905;
    logic _e_7906;
    (* src = "src/alu.spade:32,39" *)
    logic[31:0] _e_2053;
    (* src = "src/alu.spade:32,34" *)
    logic[32:0] _e_2052;
    (* src = "src/alu.spade:33,9" *)
    logic[36:0] _e_2058;
    (* src = "src/alu.spade:33,14" *)
    logic[4:0] _e_2056;
    (* src = "src/alu.spade:33,14" *)
    logic[31:0] b_n3;
    logic _e_7908;
    logic _e_7911;
    logic _e_7913;
    logic _e_7914;
    (* src = "src/alu.spade:33,39" *)
    logic[31:0] _e_2061;
    (* src = "src/alu.spade:33,34" *)
    logic[32:0] _e_2060;
    (* src = "src/alu.spade:34,9" *)
    logic[36:0] _e_2066;
    (* src = "src/alu.spade:34,14" *)
    logic[4:0] _e_2064;
    (* src = "src/alu.spade:34,14" *)
    logic[31:0] b_n4;
    logic _e_7916;
    logic _e_7919;
    logic _e_7921;
    logic _e_7922;
    (* src = "src/alu.spade:34,40" *)
    logic[31:0] _e_2069;
    (* src = "src/alu.spade:34,35" *)
    logic[32:0] _e_2068;
    (* src = "src/alu.spade:35,9" *)
    logic[36:0] _e_2073;
    (* src = "src/alu.spade:35,14" *)
    logic[4:0] _e_2071;
    (* src = "src/alu.spade:35,14" *)
    logic[31:0] b_n5;
    logic _e_7924;
    logic _e_7927;
    logic _e_7929;
    logic _e_7930;
    (* src = "src/alu.spade:35,39" *)
    logic[31:0] _e_2076;
    (* src = "src/alu.spade:35,34" *)
    logic[32:0] _e_2075;
    (* src = "src/alu.spade:36,9" *)
    logic[36:0] _e_2081;
    (* src = "src/alu.spade:36,14" *)
    logic[4:0] _e_2079;
    (* src = "src/alu.spade:36,14" *)
    logic[31:0] b_n6;
    logic _e_7932;
    logic _e_7935;
    logic _e_7937;
    logic _e_7938;
    (* src = "src/alu.spade:36,45" *)
    logic[31:0] _e_2085;
    (* src = "src/alu.spade:36,39" *)
    logic[31:0] _e_2084;
    (* src = "src/alu.spade:36,34" *)
    logic[32:0] _e_2083;
    (* src = "src/alu.spade:37,9" *)
    logic[36:0] _e_2090;
    (* src = "src/alu.spade:37,14" *)
    logic[4:0] _e_2088;
    (* src = "src/alu.spade:37,14" *)
    logic[31:0] b_n7;
    logic _e_7940;
    logic _e_7943;
    logic _e_7945;
    logic _e_7946;
    (* src = "src/alu.spade:37,45" *)
    logic[31:0] _e_2094;
    (* src = "src/alu.spade:37,39" *)
    logic[31:0] _e_2093;
    (* src = "src/alu.spade:37,34" *)
    logic[32:0] _e_2092;
    (* src = "src/alu.spade:38,9" *)
    logic[36:0] _e_2099;
    (* src = "src/alu.spade:38,14" *)
    logic[4:0] _e_2097;
    (* src = "src/alu.spade:38,14" *)
    logic[31:0] b_n8;
    logic _e_7948;
    logic _e_7951;
    logic _e_7953;
    logic _e_7954;
    (* src = "src/alu.spade:38,40" *)
    logic[31:0] _e_2102;
    (* src = "src/alu.spade:38,35" *)
    logic[32:0] _e_2101;
    (* src = "src/alu.spade:39,9" *)
    logic[36:0] _e_2107;
    (* src = "src/alu.spade:39,14" *)
    logic[4:0] _e_2105;
    (* src = "src/alu.spade:39,14" *)
    logic[31:0] b_n9;
    logic _e_7956;
    logic _e_7959;
    logic _e_7961;
    logic _e_7962;
    (* src = "src/alu.spade:39,40" *)
    logic[31:0] _e_2110;
    (* src = "src/alu.spade:39,35" *)
    logic[32:0] _e_2109;
    (* src = "src/alu.spade:40,9" *)
    logic[36:0] _e_2115;
    (* src = "src/alu.spade:40,14" *)
    logic[4:0] _e_2113;
    (* src = "src/alu.spade:40,14" *)
    logic[31:0] b_n10;
    logic _e_7964;
    logic _e_7967;
    logic _e_7969;
    logic _e_7970;
    (* src = "src/alu.spade:40,40" *)
    logic[31:0] _e_2118;
    (* src = "src/alu.spade:40,35" *)
    logic[32:0] _e_2117;
    (* src = "src/alu.spade:43,9" *)
    logic[36:0] _e_2123;
    (* src = "src/alu.spade:43,14" *)
    logic[4:0] _e_2121;
    (* src = "src/alu.spade:43,14" *)
    logic[31:0] b_n11;
    logic _e_7972;
    logic _e_7975;
    logic _e_7977;
    logic _e_7978;
    (* src = "src/alu.spade:43,42" *)
    logic _e_2127;
    (* src = "src/alu.spade:43,39" *)
    logic[31:0] _e_2126;
    (* src = "src/alu.spade:43,34" *)
    logic[32:0] _e_2125;
    (* src = "src/alu.spade:44,9" *)
    logic[36:0] _e_2136;
    (* src = "src/alu.spade:44,14" *)
    logic[4:0] _e_2134;
    (* src = "src/alu.spade:44,14" *)
    logic[31:0] b_n12;
    logic _e_7980;
    logic _e_7983;
    logic _e_7985;
    logic _e_7986;
    (* src = "src/alu.spade:44,42" *)
    logic _e_2140;
    (* src = "src/alu.spade:44,39" *)
    logic[31:0] _e_2139;
    (* src = "src/alu.spade:44,34" *)
    logic[32:0] _e_2138;
    (* src = "src/alu.spade:47,9" *)
    logic[36:0] _e_2149;
    (* src = "src/alu.spade:47,14" *)
    logic[4:0] _e_2147;
    (* src = "src/alu.spade:47,14" *)
    logic[31:0] b_n13;
    logic _e_7988;
    logic _e_7991;
    logic _e_7993;
    logic _e_7994;
    (* src = "src/alu.spade:47,41" *)
    logic[31:0] _e_2152;
    (* src = "src/alu.spade:47,36" *)
    logic[32:0] _e_2151;
    (* src = "src/alu.spade:48,9" *)
    logic[36:0] _e_2157;
    (* src = "src/alu.spade:48,14" *)
    logic[4:0] _e_2155;
    (* src = "src/alu.spade:48,14" *)
    logic[31:0] b_n14;
    logic _e_7996;
    logic _e_7999;
    logic _e_8001;
    logic _e_8002;
    (* src = "src/alu.spade:48,41" *)
    logic[31:0] _e_2160;
    (* src = "src/alu.spade:48,36" *)
    logic[32:0] _e_2159;
    (* src = "src/alu.spade:51,9" *)
    logic[36:0] _e_2165;
    (* src = "src/alu.spade:51,14" *)
    logic[4:0] _e_2163;
    (* src = "src/alu.spade:51,14" *)
    logic[31:0] b_n15;
    logic _e_8004;
    logic _e_8007;
    logic _e_8009;
    logic _e_8010;
    (* src = "src/alu.spade:51,41" *)
    logic[31:0] _e_2168;
    (* src = "src/alu.spade:51,36" *)
    logic[32:0] _e_2167;
    (* src = "src/alu.spade:52,9" *)
    logic[36:0] _e_2173;
    (* src = "src/alu.spade:52,14" *)
    logic[4:0] _e_2171;
    (* src = "src/alu.spade:52,14" *)
    logic[31:0] b_n16;
    logic _e_8012;
    logic _e_8015;
    logic _e_8017;
    logic _e_8018;
    (* src = "src/alu.spade:52,41" *)
    logic[31:0] _e_2176;
    (* src = "src/alu.spade:52,36" *)
    logic[32:0] _e_2175;
    logic _e_8020;
    (* src = "src/alu.spade:54,17" *)
    logic[32:0] _e_2180;
    (* src = "src/alu.spade:28,36" *)
    logic[32:0] \result ;
    (* src = "src/alu.spade:58,51" *)
    logic[32:0] _e_2185;
    (* src = "src/alu.spade:58,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2020 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_7878 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_7879 = 1;
    assign _e_7880 = _e_7878 && _e_7879;
    assign _e_7882 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_7880, _e_7882})
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
    assign _e_7884 = \trig [37] == 1'd1;
    assign _e_7887 = _e_2030[4:0] == 5'd0;
    localparam[0:0] _e_7888 = 1;
    assign _e_7889 = _e_7887 && _e_7888;
    assign _e_7890 = _e_7884 && _e_7889;
    assign _e_2036 = \op_a  + \b ;
    assign _e_2035 = _e_2036[31:0];
    assign _e_2034 = {1'd1, _e_2035};
    assign _e_2041 = \trig [36:0];
    assign _e_2039 = _e_2041[36:32];
    assign b_n1 = _e_2041[31:0];
    assign _e_7892 = \trig [37] == 1'd1;
    assign _e_7895 = _e_2039[4:0] == 5'd1;
    localparam[0:0] _e_7896 = 1;
    assign _e_7897 = _e_7895 && _e_7896;
    assign _e_7898 = _e_7892 && _e_7897;
    assign _e_2045 = \op_a  - b_n1;
    assign _e_2044 = _e_2045[31:0];
    assign _e_2043 = {1'd1, _e_2044};
    assign _e_2050 = \trig [36:0];
    assign _e_2048 = _e_2050[36:32];
    assign b_n2 = _e_2050[31:0];
    assign _e_7900 = \trig [37] == 1'd1;
    assign _e_7903 = _e_2048[4:0] == 5'd2;
    localparam[0:0] _e_7904 = 1;
    assign _e_7905 = _e_7903 && _e_7904;
    assign _e_7906 = _e_7900 && _e_7905;
    assign _e_2053 = \op_a  & b_n2;
    assign _e_2052 = {1'd1, _e_2053};
    assign _e_2058 = \trig [36:0];
    assign _e_2056 = _e_2058[36:32];
    assign b_n3 = _e_2058[31:0];
    assign _e_7908 = \trig [37] == 1'd1;
    assign _e_7911 = _e_2056[4:0] == 5'd3;
    localparam[0:0] _e_7912 = 1;
    assign _e_7913 = _e_7911 && _e_7912;
    assign _e_7914 = _e_7908 && _e_7913;
    assign _e_2061 = \op_a  | b_n3;
    assign _e_2060 = {1'd1, _e_2061};
    assign _e_2066 = \trig [36:0];
    assign _e_2064 = _e_2066[36:32];
    assign b_n4 = _e_2066[31:0];
    assign _e_7916 = \trig [37] == 1'd1;
    assign _e_7919 = _e_2064[4:0] == 5'd4;
    localparam[0:0] _e_7920 = 1;
    assign _e_7921 = _e_7919 && _e_7920;
    assign _e_7922 = _e_7916 && _e_7921;
    assign _e_2069 = ~b_n4;
    assign _e_2068 = {1'd1, _e_2069};
    assign _e_2073 = \trig [36:0];
    assign _e_2071 = _e_2073[36:32];
    assign b_n5 = _e_2073[31:0];
    assign _e_7924 = \trig [37] == 1'd1;
    assign _e_7927 = _e_2071[4:0] == 5'd5;
    localparam[0:0] _e_7928 = 1;
    assign _e_7929 = _e_7927 && _e_7928;
    assign _e_7930 = _e_7924 && _e_7929;
    assign _e_2076 = \op_a  ^ b_n5;
    assign _e_2075 = {1'd1, _e_2076};
    assign _e_2081 = \trig [36:0];
    assign _e_2079 = _e_2081[36:32];
    assign b_n6 = _e_2081[31:0];
    assign _e_7932 = \trig [37] == 1'd1;
    assign _e_7935 = _e_2079[4:0] == 5'd6;
    localparam[0:0] _e_7936 = 1;
    assign _e_7937 = _e_7935 && _e_7936;
    assign _e_7938 = _e_7932 && _e_7937;
    assign _e_2085 = \op_a  << b_n6;
    assign _e_2084 = _e_2085[31:0];
    assign _e_2083 = {1'd1, _e_2084};
    assign _e_2090 = \trig [36:0];
    assign _e_2088 = _e_2090[36:32];
    assign b_n7 = _e_2090[31:0];
    assign _e_7940 = \trig [37] == 1'd1;
    assign _e_7943 = _e_2088[4:0] == 5'd7;
    localparam[0:0] _e_7944 = 1;
    assign _e_7945 = _e_7943 && _e_7944;
    assign _e_7946 = _e_7940 && _e_7945;
    assign _e_2094 = \op_a  >> b_n7;
    assign _e_2093 = _e_2094[31:0];
    assign _e_2092 = {1'd1, _e_2093};
    assign _e_2099 = \trig [36:0];
    assign _e_2097 = _e_2099[36:32];
    assign b_n8 = _e_2099[31:0];
    assign _e_7948 = \trig [37] == 1'd1;
    assign _e_7951 = _e_2097[4:0] == 5'd8;
    localparam[0:0] _e_7952 = 1;
    assign _e_7953 = _e_7951 && _e_7952;
    assign _e_7954 = _e_7948 && _e_7953;
    (* src = "src/alu.spade:38,40" *)
    \tta::alu::ashr32  ashr32_0(.x_i(\op_a ), .sh_i(b_n8), .output__(_e_2102));
    assign _e_2101 = {1'd1, _e_2102};
    assign _e_2107 = \trig [36:0];
    assign _e_2105 = _e_2107[36:32];
    assign b_n9 = _e_2107[31:0];
    assign _e_7956 = \trig [37] == 1'd1;
    assign _e_7959 = _e_2105[4:0] == 5'd9;
    localparam[0:0] _e_7960 = 1;
    assign _e_7961 = _e_7959 && _e_7960;
    assign _e_7962 = _e_7956 && _e_7961;
    (* src = "src/alu.spade:39,40" *)
    \tta::alu::rotl32  rotl32_0(.x_i(\op_a ), .sh32_i(b_n9), .output__(_e_2110));
    assign _e_2109 = {1'd1, _e_2110};
    assign _e_2115 = \trig [36:0];
    assign _e_2113 = _e_2115[36:32];
    assign b_n10 = _e_2115[31:0];
    assign _e_7964 = \trig [37] == 1'd1;
    assign _e_7967 = _e_2113[4:0] == 5'd10;
    localparam[0:0] _e_7968 = 1;
    assign _e_7969 = _e_7967 && _e_7968;
    assign _e_7970 = _e_7964 && _e_7969;
    (* src = "src/alu.spade:40,40" *)
    \tta::alu::rotr32  rotr32_0(.x_i(\op_a ), .sh32_i(b_n10), .output__(_e_2118));
    assign _e_2117 = {1'd1, _e_2118};
    assign _e_2123 = \trig [36:0];
    assign _e_2121 = _e_2123[36:32];
    assign b_n11 = _e_2123[31:0];
    assign _e_7972 = \trig [37] == 1'd1;
    assign _e_7975 = _e_2121[4:0] == 5'd11;
    localparam[0:0] _e_7976 = 1;
    assign _e_7977 = _e_7975 && _e_7976;
    assign _e_7978 = _e_7972 && _e_7977;
    assign _e_2127 = \op_a  < b_n11;
    assign _e_2126 = _e_2127 ? \op_a  : b_n11;
    assign _e_2125 = {1'd1, _e_2126};
    assign _e_2136 = \trig [36:0];
    assign _e_2134 = _e_2136[36:32];
    assign b_n12 = _e_2136[31:0];
    assign _e_7980 = \trig [37] == 1'd1;
    assign _e_7983 = _e_2134[4:0] == 5'd12;
    localparam[0:0] _e_7984 = 1;
    assign _e_7985 = _e_7983 && _e_7984;
    assign _e_7986 = _e_7980 && _e_7985;
    assign _e_2140 = \op_a  > b_n12;
    assign _e_2139 = _e_2140 ? \op_a  : b_n12;
    assign _e_2138 = {1'd1, _e_2139};
    assign _e_2149 = \trig [36:0];
    assign _e_2147 = _e_2149[36:32];
    assign b_n13 = _e_2149[31:0];
    assign _e_7988 = \trig [37] == 1'd1;
    assign _e_7991 = _e_2147[4:0] == 5'd13;
    localparam[0:0] _e_7992 = 1;
    assign _e_7993 = _e_7991 && _e_7992;
    assign _e_7994 = _e_7988 && _e_7993;
    (* src = "src/alu.spade:47,41" *)
    \tta::alu::sadd32  sadd32_0(.a_u_i(\op_a ), .b_u_i(b_n13), .output__(_e_2152));
    assign _e_2151 = {1'd1, _e_2152};
    assign _e_2157 = \trig [36:0];
    assign _e_2155 = _e_2157[36:32];
    assign b_n14 = _e_2157[31:0];
    assign _e_7996 = \trig [37] == 1'd1;
    assign _e_7999 = _e_2155[4:0] == 5'd14;
    localparam[0:0] _e_8000 = 1;
    assign _e_8001 = _e_7999 && _e_8000;
    assign _e_8002 = _e_7996 && _e_8001;
    (* src = "src/alu.spade:48,41" *)
    \tta::alu::ssub32  ssub32_0(.a_u_i(\op_a ), .b_u_i(b_n14), .output__(_e_2160));
    assign _e_2159 = {1'd1, _e_2160};
    assign _e_2165 = \trig [36:0];
    assign _e_2163 = _e_2165[36:32];
    assign b_n15 = _e_2165[31:0];
    assign _e_8004 = \trig [37] == 1'd1;
    assign _e_8007 = _e_2163[4:0] == 5'd15;
    localparam[0:0] _e_8008 = 1;
    assign _e_8009 = _e_8007 && _e_8008;
    assign _e_8010 = _e_8004 && _e_8009;
    (* src = "src/alu.spade:51,41" *)
    \tta::alu::uadd32  uadd32_0(.a_i(\op_a ), .b_i(b_n15), .output__(_e_2168));
    assign _e_2167 = {1'd1, _e_2168};
    assign _e_2173 = \trig [36:0];
    assign _e_2171 = _e_2173[36:32];
    assign b_n16 = _e_2173[31:0];
    assign _e_8012 = \trig [37] == 1'd1;
    assign _e_8015 = _e_2171[4:0] == 5'd16;
    localparam[0:0] _e_8016 = 1;
    assign _e_8017 = _e_8015 && _e_8016;
    assign _e_8018 = _e_8012 && _e_8017;
    (* src = "src/alu.spade:52,41" *)
    \tta::alu::usub32  usub32_0(.a_i(\op_a ), .b_i(b_n16), .output__(_e_2176));
    assign _e_2175 = {1'd1, _e_2176};
    assign _e_8020 = \trig [37] == 1'd0;
    assign _e_2180 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_7890, _e_7898, _e_7906, _e_7914, _e_7922, _e_7930, _e_7938, _e_7946, _e_7954, _e_7962, _e_7970, _e_7978, _e_7986, _e_7994, _e_8002, _e_8010, _e_8018, _e_8020})
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
    (* src = "src/alu.spade:69,25" *)
    logic[32:0] \sum ;
    (* src = "src/alu.spade:72,8" *)
    logic _e_2196;
    (* src = "src/alu.spade:75,9" *)
    logic[31:0] _e_2202;
    (* src = "src/alu.spade:72,5" *)
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
    (* src = "src/alu.spade:81,8" *)
    logic _e_2206;
    (* src = "src/alu.spade:84,15" *)
    logic[32:0] _e_2213;
    (* src = "src/alu.spade:84,9" *)
    logic[31:0] _e_2212;
    (* src = "src/alu.spade:81,5" *)
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
    (* src = "src/alu.spade:94,22" *)
    logic[31:0] \a ;
    (* src = "src/alu.spade:95,22" *)
    logic[31:0] \b ;
    (* src = "src/alu.spade:98,26" *)
    logic[32:0] \a_big ;
    (* src = "src/alu.spade:99,26" *)
    logic[32:0] \b_big ;
    (* src = "src/alu.spade:100,15" *)
    logic[33:0] \sum ;
    (* src = "src/alu.spade:105,8" *)
    logic _e_2234;
    (* src = "src/alu.spade:107,15" *)
    logic _e_2240;
    (* src = "src/alu.spade:111,28" *)
    logic[31:0] sum_n1;
    (* src = "src/alu.spade:112,9" *)
    logic[31:0] _e_2249;
    (* src = "src/alu.spade:107,12" *)
    logic[31:0] _e_2239;
    (* src = "src/alu.spade:105,5" *)
    logic[31:0] _e_2233;
    (* src = "src/alu.spade:94,22" *)
    \std::conv::impl_4::to_int[2137]  to_int_0(.self_i(\a_u ), .output__(\a ));
    (* src = "src/alu.spade:95,22" *)
    \std::conv::impl_4::to_int[2137]  to_int_1(.self_i(\b_u ), .output__(\b ));
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
    (* src = "src/alu.spade:112,9" *)
    \std::conv::impl_3::to_uint[2138]  to_uint_0(.self_i(sum_n1), .output__(_e_2249));
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
    (* src = "src/alu.spade:117,22" *)
    logic[31:0] \a ;
    (* src = "src/alu.spade:118,22" *)
    logic[31:0] \b ;
    (* src = "src/alu.spade:120,26" *)
    logic[32:0] \a_big ;
    (* src = "src/alu.spade:121,26" *)
    logic[32:0] \b_big ;
    (* src = "src/alu.spade:122,25" *)
    logic[33:0] \diff ;
    (* src = "src/alu.spade:124,8" *)
    logic _e_2269;
    (* src = "src/alu.spade:126,15" *)
    logic _e_2275;
    (* src = "src/alu.spade:129,35" *)
    logic[31:0] \trunc_diff ;
    (* src = "src/alu.spade:130,9" *)
    logic[31:0] _e_2284;
    (* src = "src/alu.spade:126,12" *)
    logic[31:0] _e_2274;
    (* src = "src/alu.spade:124,5" *)
    logic[31:0] _e_2268;
    (* src = "src/alu.spade:117,22" *)
    \std::conv::impl_4::to_int[2137]  to_int_0(.self_i(\a_u ), .output__(\a ));
    (* src = "src/alu.spade:118,22" *)
    \std::conv::impl_4::to_int[2137]  to_int_1(.self_i(\b_u ), .output__(\b ));
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
    (* src = "src/alu.spade:130,9" *)
    \std::conv::impl_3::to_uint[2138]  to_uint_0(.self_i(\trunc_diff ), .output__(_e_2284));
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
    (* src = "src/alu.spade:137,9" *)
    logic[31:0] \sh32 ;
    (* src = "src/alu.spade:138,29" *)
    logic[31:0] \logical ;
    (* src = "src/alu.spade:139,32" *)
    logic[31:0] _e_2294;
    (* src = "src/alu.spade:139,26" *)
    logic \sign1 ;
    logic[30:0] _e_2300;
    (* src = "src/alu.spade:140,30" *)
    logic[31:0] \signmask ;
    (* src = "src/alu.spade:141,33" *)
    logic _e_2304;
    (* src = "src/alu.spade:141,62" *)
    logic[32:0] _e_2312;
    (* src = "src/alu.spade:141,73" *)
    logic[32:0] _e_2315;
    (* src = "src/alu.spade:141,62" *)
    logic[32:0] _e_2311;
    (* src = "src/alu.spade:141,56" *)
    logic[31:0] _e_2310;
    (* src = "src/alu.spade:141,30" *)
    logic[31:0] \top_mask ;
    (* src = "src/alu.spade:142,26" *)
    logic[31:0] \fill ;
    (* src = "src/alu.spade:143,5" *)
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
    (* src = "src/alu.spade:147,6" *)
    logic _e_2328;
    (* src = "src/alu.spade:148,26" *)
    logic[31:0] \left ;
    (* src = "src/alu.spade:149,36" *)
    logic[32:0] _e_2339;
    (* src = "src/alu.spade:149,30" *)
    logic[31:0] \inverted ;
    (* src = "src/alu.spade:150,27" *)
    logic[31:0] \right ;
    (* src = "src/alu.spade:151,5" *)
    logic[31:0] _e_2347;
    (* src = "src/alu.spade:147,3" *)
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
    (* src = "src/alu.spade:156,6" *)
    logic _e_2352;
    (* src = "src/alu.spade:157,27" *)
    logic[31:0] \right ;
    (* src = "src/alu.spade:158,36" *)
    logic[32:0] _e_2363;
    (* src = "src/alu.spade:158,30" *)
    logic[31:0] \inverted ;
    (* src = "src/alu.spade:159,27" *)
    logic[31:0] \left ;
    (* src = "src/alu.spade:160,5" *)
    logic[31:0] _e_2371;
    (* src = "src/alu.spade:156,3" *)
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
    (* src = "src/alu.spade:166,9" *)
    logic[42:0] _e_2378;
    (* src = "src/alu.spade:166,14" *)
    logic[31:0] \x ;
    logic _e_8022;
    logic _e_8024;
    logic _e_8026;
    logic _e_8027;
    (* src = "src/alu.spade:166,35" *)
    logic[32:0] _e_2380;
    (* src = "src/alu.spade:167,9" *)
    logic[43:0] \_ ;
    (* src = "src/alu.spade:168,13" *)
    logic[42:0] _e_2386;
    (* src = "src/alu.spade:168,18" *)
    logic[31:0] x_n1;
    logic _e_8030;
    logic _e_8032;
    logic _e_8034;
    logic _e_8035;
    (* src = "src/alu.spade:168,39" *)
    logic[32:0] _e_2388;
    (* src = "src/alu.spade:169,13" *)
    logic[43:0] __n1;
    (* src = "src/alu.spade:169,18" *)
    logic[32:0] _e_2391;
    (* src = "src/alu.spade:167,14" *)
    logic[32:0] _e_2383;
    (* src = "src/alu.spade:165,5" *)
    logic[32:0] _e_2375;
    assign _e_2378 = \m1 [42:0];
    assign \x  = _e_2378[36:5];
    assign _e_8022 = \m1 [43] == 1'd1;
    assign _e_8024 = _e_2378[42:37] == 6'd1;
    localparam[0:0] _e_8025 = 1;
    assign _e_8026 = _e_8024 && _e_8025;
    assign _e_8027 = _e_8022 && _e_8026;
    assign _e_2380 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8028 = 1;
    assign _e_2386 = \m0 [42:0];
    assign x_n1 = _e_2386[36:5];
    assign _e_8030 = \m0 [43] == 1'd1;
    assign _e_8032 = _e_2386[42:37] == 6'd1;
    localparam[0:0] _e_8033 = 1;
    assign _e_8034 = _e_8032 && _e_8033;
    assign _e_8035 = _e_8030 && _e_8034;
    assign _e_2388 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8036 = 1;
    assign _e_2391 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8035, _e_8036})
            2'b1?: _e_2383 = _e_2388;
            2'b01: _e_2383 = _e_2391;
            2'b?: _e_2383 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8027, _e_8028})
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
    (* src = "src/alu.spade:175,9" *)
    logic[42:0] _e_2397;
    (* src = "src/alu.spade:175,14" *)
    logic[4:0] \op ;
    (* src = "src/alu.spade:175,14" *)
    logic[31:0] \x ;
    logic _e_8038;
    logic _e_8040;
    logic _e_8043;
    logic _e_8044;
    logic _e_8045;
    (* src = "src/alu.spade:175,44" *)
    logic[36:0] _e_2400;
    (* src = "src/alu.spade:175,39" *)
    logic[37:0] _e_2399;
    (* src = "src/alu.spade:176,9" *)
    logic[43:0] \_ ;
    (* src = "src/alu.spade:177,13" *)
    logic[42:0] _e_2408;
    (* src = "src/alu.spade:177,18" *)
    logic[4:0] op_n1;
    (* src = "src/alu.spade:177,18" *)
    logic[31:0] x_n1;
    logic _e_8048;
    logic _e_8050;
    logic _e_8053;
    logic _e_8054;
    logic _e_8055;
    (* src = "src/alu.spade:177,48" *)
    logic[36:0] _e_2411;
    (* src = "src/alu.spade:177,43" *)
    logic[37:0] _e_2410;
    (* src = "src/alu.spade:178,13" *)
    logic[43:0] __n1;
    (* src = "src/alu.spade:178,18" *)
    logic[37:0] _e_2415;
    (* src = "src/alu.spade:176,14" *)
    logic[37:0] _e_2404;
    (* src = "src/alu.spade:174,5" *)
    logic[37:0] _e_2393;
    assign _e_2397 = \m1 [42:0];
    assign \op  = _e_2397[36:32];
    assign \x  = _e_2397[31:0];
    assign _e_8038 = \m1 [43] == 1'd1;
    assign _e_8040 = _e_2397[42:37] == 6'd2;
    localparam[0:0] _e_8041 = 1;
    localparam[0:0] _e_8042 = 1;
    assign _e_8043 = _e_8040 && _e_8041;
    assign _e_8044 = _e_8043 && _e_8042;
    assign _e_8045 = _e_8038 && _e_8044;
    assign _e_2400 = {\op , \x };
    assign _e_2399 = {1'd1, _e_2400};
    assign \_  = \m1 ;
    localparam[0:0] _e_8046 = 1;
    assign _e_2408 = \m0 [42:0];
    assign op_n1 = _e_2408[36:32];
    assign x_n1 = _e_2408[31:0];
    assign _e_8048 = \m0 [43] == 1'd1;
    assign _e_8050 = _e_2408[42:37] == 6'd2;
    localparam[0:0] _e_8051 = 1;
    localparam[0:0] _e_8052 = 1;
    assign _e_8053 = _e_8050 && _e_8051;
    assign _e_8054 = _e_8053 && _e_8052;
    assign _e_8055 = _e_8048 && _e_8054;
    assign _e_2411 = {op_n1, x_n1};
    assign _e_2410 = {1'd1, _e_2411};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8056 = 1;
    assign _e_2415 = {1'd0, 37'bX};
    always_comb begin
        priority casez ({_e_8055, _e_8056})
            2'b1?: _e_2404 = _e_2410;
            2'b01: _e_2404 = _e_2415;
            2'b?: _e_2404 = 38'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8045, _e_8046})
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
    logic _e_8058;
    logic _e_8060;
    logic _e_8062;
    (* src = "src/modadd.spade:19,45" *)
    logic[31:0] _e_2421;
    (* src = "src/modadd.spade:19,14" *)
    reg[31:0] \base ;
    (* src = "src/modadd.spade:25,9" *)
    logic[31:0] v_n1;
    logic _e_8064;
    logic _e_8066;
    logic _e_8068;
    (* src = "src/modadd.spade:24,45" *)
    logic[31:0] _e_2432;
    (* src = "src/modadd.spade:24,14" *)
    reg[31:0] \mask ;
    (* src = "src/modadd.spade:34,13" *)
    logic[31:0] v_n2;
    logic _e_8070;
    logic _e_8072;
    logic _e_8074;
    (* src = "src/modadd.spade:33,27" *)
    logic[31:0] \current_ptr ;
    (* src = "src/modadd.spade:39,13" *)
    logic[31:0] \stride ;
    logic _e_8076;
    logic _e_8078;
    (* src = "src/modadd.spade:42,36" *)
    logic[32:0] _e_2459;
    (* src = "src/modadd.spade:42,30" *)
    logic[31:0] _e_2458;
    (* src = "src/modadd.spade:42,30" *)
    logic[31:0] \offset ;
    (* src = "src/modadd.spade:43,17" *)
    logic[31:0] _e_2464;
    logic _e_8080;
    (* src = "src/modadd.spade:38,9" *)
    logic[31:0] _e_2452;
    (* src = "src/modadd.spade:32,14" *)
    reg[31:0] \ptr ;
    (* src = "src/modadd.spade:51,47" *)
    logic[32:0] _e_2472;
    (* src = "src/modadd.spade:53,13" *)
    logic[31:0] v_n3;
    logic _e_8082;
    logic _e_8084;
    logic _e_8086;
    (* src = "src/modadd.spade:52,27" *)
    logic[31:0] current_ptr_n1;
    (* src = "src/modadd.spade:58,13" *)
    logic[31:0] stride_n1;
    logic _e_8088;
    logic _e_8090;
    (* src = "src/modadd.spade:59,36" *)
    logic[32:0] _e_2489;
    (* src = "src/modadd.spade:59,30" *)
    logic[31:0] _e_2488;
    (* src = "src/modadd.spade:59,30" *)
    logic[31:0] offset_n1;
    (* src = "src/modadd.spade:60,22" *)
    logic[31:0] _e_2495;
    (* src = "src/modadd.spade:60,17" *)
    logic[32:0] _e_2494;
    logic _e_8092;
    (* src = "src/modadd.spade:62,21" *)
    logic[32:0] _e_2499;
    (* src = "src/modadd.spade:57,9" *)
    logic[32:0] _e_2482;
    (* src = "src/modadd.spade:51,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_2420 = 32'd0;
    assign \v  = \set_base [31:0];
    assign _e_8058 = \set_base [32] == 1'd1;
    localparam[0:0] _e_8059 = 1;
    assign _e_8060 = _e_8058 && _e_8059;
    assign _e_8062 = \set_base [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8060, _e_8062})
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
    assign _e_8064 = \set_mask [32] == 1'd1;
    localparam[0:0] _e_8065 = 1;
    assign _e_8066 = _e_8064 && _e_8065;
    assign _e_8068 = \set_mask [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8066, _e_8068})
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
    assign _e_8070 = \set_ptr [32] == 1'd1;
    localparam[0:0] _e_8071 = 1;
    assign _e_8072 = _e_8070 && _e_8071;
    assign _e_8074 = \set_ptr [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8072, _e_8074})
            2'b1?: \current_ptr  = v_n2;
            2'b01: \current_ptr  = \ptr ;
            2'b?: \current_ptr  = 32'dx;
        endcase
    end
    assign \stride  = \trig_stride [31:0];
    assign _e_8076 = \trig_stride [32] == 1'd1;
    localparam[0:0] _e_8077 = 1;
    assign _e_8078 = _e_8076 && _e_8077;
    assign _e_2459 = \current_ptr  + \stride ;
    assign _e_2458 = _e_2459[31:0];
    assign \offset  = _e_2458 & \mask ;
    assign _e_2464 = \base  | \offset ;
    assign _e_8080 = \trig_stride [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8078, _e_8080})
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
    assign _e_8082 = \set_ptr [32] == 1'd1;
    localparam[0:0] _e_8083 = 1;
    assign _e_8084 = _e_8082 && _e_8083;
    assign _e_8086 = \set_ptr [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8084, _e_8086})
            2'b1?: current_ptr_n1 = v_n3;
            2'b01: current_ptr_n1 = \ptr ;
            2'b?: current_ptr_n1 = 32'dx;
        endcase
    end
    assign stride_n1 = \trig_stride [31:0];
    assign _e_8088 = \trig_stride [32] == 1'd1;
    localparam[0:0] _e_8089 = 1;
    assign _e_8090 = _e_8088 && _e_8089;
    assign _e_2489 = current_ptr_n1 + stride_n1;
    assign _e_2488 = _e_2489[31:0];
    assign offset_n1 = _e_2488 & \mask ;
    assign _e_2495 = \base  | offset_n1;
    assign _e_2494 = {1'd1, _e_2495};
    assign _e_8092 = \trig_stride [32] == 1'd0;
    assign _e_2499 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8090, _e_8092})
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
    logic _e_8094;
    logic _e_8096;
    logic _e_8098;
    logic _e_8099;
    (* src = "src/modadd.spade:71,35" *)
    logic[32:0] _e_2507;
    (* src = "src/modadd.spade:72,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:72,25" *)
    logic[42:0] _e_2513;
    (* src = "src/modadd.spade:72,30" *)
    logic[31:0] a_n1;
    logic _e_8102;
    logic _e_8104;
    logic _e_8106;
    logic _e_8107;
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
    assign _e_8094 = \m1 [43] == 1'd1;
    assign _e_8096 = _e_2505[42:37] == 6'd30;
    localparam[0:0] _e_8097 = 1;
    assign _e_8098 = _e_8096 && _e_8097;
    assign _e_8099 = _e_8094 && _e_8098;
    assign _e_2507 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8100 = 1;
    assign _e_2513 = \m0 [42:0];
    assign a_n1 = _e_2513[36:5];
    assign _e_8102 = \m0 [43] == 1'd1;
    assign _e_8104 = _e_2513[42:37] == 6'd30;
    localparam[0:0] _e_8105 = 1;
    assign _e_8106 = _e_8104 && _e_8105;
    assign _e_8107 = _e_8102 && _e_8106;
    assign _e_2515 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8108 = 1;
    assign _e_2518 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8107, _e_8108})
            2'b1?: _e_2510 = _e_2515;
            2'b01: _e_2510 = _e_2518;
            2'b?: _e_2510 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8099, _e_8100})
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
    logic _e_8110;
    logic _e_8112;
    logic _e_8114;
    logic _e_8115;
    (* src = "src/modadd.spade:78,35" *)
    logic[32:0] _e_2525;
    (* src = "src/modadd.spade:79,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:79,25" *)
    logic[42:0] _e_2531;
    (* src = "src/modadd.spade:79,30" *)
    logic[31:0] a_n1;
    logic _e_8118;
    logic _e_8120;
    logic _e_8122;
    logic _e_8123;
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
    assign _e_8110 = \m1 [43] == 1'd1;
    assign _e_8112 = _e_2523[42:37] == 6'd31;
    localparam[0:0] _e_8113 = 1;
    assign _e_8114 = _e_8112 && _e_8113;
    assign _e_8115 = _e_8110 && _e_8114;
    assign _e_2525 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8116 = 1;
    assign _e_2531 = \m0 [42:0];
    assign a_n1 = _e_2531[36:5];
    assign _e_8118 = \m0 [43] == 1'd1;
    assign _e_8120 = _e_2531[42:37] == 6'd31;
    localparam[0:0] _e_8121 = 1;
    assign _e_8122 = _e_8120 && _e_8121;
    assign _e_8123 = _e_8118 && _e_8122;
    assign _e_2533 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8124 = 1;
    assign _e_2536 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8123, _e_8124})
            2'b1?: _e_2528 = _e_2533;
            2'b01: _e_2528 = _e_2536;
            2'b?: _e_2528 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8115, _e_8116})
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
    logic _e_8126;
    logic _e_8128;
    logic _e_8130;
    logic _e_8131;
    (* src = "src/modadd.spade:85,34" *)
    logic[32:0] _e_2543;
    (* src = "src/modadd.spade:86,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:86,25" *)
    logic[42:0] _e_2549;
    (* src = "src/modadd.spade:86,30" *)
    logic[31:0] a_n1;
    logic _e_8134;
    logic _e_8136;
    logic _e_8138;
    logic _e_8139;
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
    assign _e_8126 = \m1 [43] == 1'd1;
    assign _e_8128 = _e_2541[42:37] == 6'd32;
    localparam[0:0] _e_8129 = 1;
    assign _e_8130 = _e_8128 && _e_8129;
    assign _e_8131 = _e_8126 && _e_8130;
    assign _e_2543 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8132 = 1;
    assign _e_2549 = \m0 [42:0];
    assign a_n1 = _e_2549[36:5];
    assign _e_8134 = \m0 [43] == 1'd1;
    assign _e_8136 = _e_2549[42:37] == 6'd32;
    localparam[0:0] _e_8137 = 1;
    assign _e_8138 = _e_8136 && _e_8137;
    assign _e_8139 = _e_8134 && _e_8138;
    assign _e_2551 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8140 = 1;
    assign _e_2554 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8139, _e_8140})
            2'b1?: _e_2546 = _e_2551;
            2'b01: _e_2546 = _e_2554;
            2'b?: _e_2546 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8131, _e_8132})
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
    logic _e_8142;
    logic _e_8144;
    logic _e_8146;
    logic _e_8147;
    (* src = "src/modadd.spade:92,35" *)
    logic[32:0] _e_2561;
    (* src = "src/modadd.spade:93,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:93,25" *)
    logic[42:0] _e_2567;
    (* src = "src/modadd.spade:93,30" *)
    logic[31:0] a_n1;
    logic _e_8150;
    logic _e_8152;
    logic _e_8154;
    logic _e_8155;
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
    assign _e_8142 = \m1 [43] == 1'd1;
    assign _e_8144 = _e_2559[42:37] == 6'd33;
    localparam[0:0] _e_8145 = 1;
    assign _e_8146 = _e_8144 && _e_8145;
    assign _e_8147 = _e_8142 && _e_8146;
    assign _e_2561 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8148 = 1;
    assign _e_2567 = \m0 [42:0];
    assign a_n1 = _e_2567[36:5];
    assign _e_8150 = \m0 [43] == 1'd1;
    assign _e_8152 = _e_2567[42:37] == 6'd33;
    localparam[0:0] _e_8153 = 1;
    assign _e_8154 = _e_8152 && _e_8153;
    assign _e_8155 = _e_8150 && _e_8154;
    assign _e_2569 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8156 = 1;
    assign _e_2572 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8155, _e_8156})
            2'b1?: _e_2564 = _e_2569;
            2'b01: _e_2564 = _e_2572;
            2'b?: _e_2564 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8147, _e_8148})
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
    (* src = "src/uart_in.spade:11,16" *)
    logic[14:0] \data ;
    (* src = "src/uart_in.spade:12,48" *)
    logic[32:0] _e_2583;
    (* src = "src/uart_in.spade:13,7" *)
    logic[31:0] \b ;
    logic _e_8158;
    logic _e_8160;
    logic[31:0] _e_2589;
    (* src = "src/uart_in.spade:13,18" *)
    logic[32:0] _e_2588;
    logic _e_8162;
    (* src = "src/uart_in.spade:14,15" *)
    logic[32:0] _e_2592;
    (* src = "src/uart_in.spade:12,56" *)
    logic[32:0] _e_2584;
    (* src = "src/uart_in.spade:12,14" *)
    reg[32:0] data_n1;
    (* src = "src/uart_in.spade:11,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\uart_byte ), .pop_i(\pop ), .output__(\data ));
    assign _e_2583 = {1'd0, 32'bX};
    assign \b  = data_n1[31:0];
    assign _e_8158 = data_n1[32] == 1'd1;
    localparam[0:0] _e_8159 = 1;
    assign _e_8160 = _e_8158 && _e_8159;
    assign _e_2589 = \b ;
    assign _e_2588 = {1'd1, _e_2589};
    assign _e_8162 = data_n1[32] == 1'd0;
    assign _e_2592 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8160, _e_8162})
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
    (* src = "src/uart_in.spade:33,65" *)
    logic _e_2599;
    (* src = "src/uart_in.spade:33,16" *)
    logic[14:0] \data ;
    (* src = "src/uart_in.spade:34,47" *)
    logic[8:0] _e_2605;
    (* src = "src/uart_in.spade:35,7" *)
    logic[7:0] \b ;
    logic _e_8164;
    logic _e_8166;
    (* src = "src/uart_in.spade:35,18" *)
    logic[8:0] _e_2610;
    logic _e_8168;
    (* src = "src/uart_in.spade:36,15" *)
    logic[8:0] _e_2613;
    (* src = "src/uart_in.spade:34,55" *)
    logic[8:0] _e_2606;
    (* src = "src/uart_in.spade:34,14" *)
    reg[8:0] data_n1;
    assign _e_2599 = !\uart_tx_busy ;
    (* src = "src/uart_in.spade:33,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\byte_to_write ), .pop_i(_e_2599), .output__(\data ));
    assign _e_2605 = {1'd0, 8'bX};
    assign \b  = data_n1[7:0];
    assign _e_8164 = data_n1[8] == 1'd1;
    localparam[0:0] _e_8165 = 1;
    assign _e_8166 = _e_8164 && _e_8165;
    assign _e_2610 = {1'd1, \b };
    assign _e_8168 = data_n1[8] == 1'd0;
    assign _e_2613 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8166, _e_8168})
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
    (* src = "src/uart_in.spade:45,9" *)
    logic[42:0] _e_2620;
    logic _e_8170;
    logic _e_8172;
    logic _e_8173;
    (* src = "src/uart_in.spade:46,9" *)
    logic[43:0] \_ ;
    (* src = "src/uart_in.spade:47,13" *)
    logic[42:0] _e_2626;
    logic _e_8176;
    logic _e_8178;
    logic _e_8179;
    (* src = "src/uart_in.spade:48,13" *)
    logic[43:0] __n1;
    (* src = "src/uart_in.spade:46,14" *)
    logic _e_2624;
    (* src = "src/uart_in.spade:44,5" *)
    logic _e_2618;
    assign _e_2620 = \m1 [42:0];
    assign _e_8170 = \m1 [43] == 1'd1;
    assign _e_8172 = _e_2620[42:37] == 6'd41;
    assign _e_8173 = _e_8170 && _e_8172;
    localparam[0:0] _e_2622 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_8174 = 1;
    assign _e_2626 = \m0 [42:0];
    assign _e_8176 = \m0 [43] == 1'd1;
    assign _e_8178 = _e_2626[42:37] == 6'd41;
    assign _e_8179 = _e_8176 && _e_8178;
    localparam[0:0] _e_2628 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_8180 = 1;
    localparam[0:0] _e_2630 = 0;
    always_comb begin
        priority casez ({_e_8179, _e_8180})
            2'b1?: _e_2624 = _e_2628;
            2'b01: _e_2624 = _e_2630;
            2'b?: _e_2624 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8173, _e_8174})
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
    (* src = "src/uart_in.spade:54,9" *)
    logic[42:0] _e_2635;
    (* src = "src/uart_in.spade:54,14" *)
    logic[7:0] \x ;
    logic _e_8182;
    logic _e_8184;
    logic _e_8186;
    logic _e_8187;
    (* src = "src/uart_in.spade:54,36" *)
    logic[8:0] _e_2637;
    (* src = "src/uart_in.spade:55,9" *)
    logic[43:0] \_ ;
    (* src = "src/uart_in.spade:56,13" *)
    logic[42:0] _e_2643;
    (* src = "src/uart_in.spade:56,18" *)
    logic[7:0] x_n1;
    logic _e_8190;
    logic _e_8192;
    logic _e_8194;
    logic _e_8195;
    (* src = "src/uart_in.spade:56,40" *)
    logic[8:0] _e_2645;
    (* src = "src/uart_in.spade:57,13" *)
    logic[43:0] __n1;
    (* src = "src/uart_in.spade:57,18" *)
    logic[8:0] _e_2648;
    (* src = "src/uart_in.spade:55,14" *)
    logic[8:0] _e_2640;
    (* src = "src/uart_in.spade:53,5" *)
    logic[8:0] _e_2632;
    assign _e_2635 = \m1 [42:0];
    assign \x  = _e_2635[36:29];
    assign _e_8182 = \m1 [43] == 1'd1;
    assign _e_8184 = _e_2635[42:37] == 6'd38;
    localparam[0:0] _e_8185 = 1;
    assign _e_8186 = _e_8184 && _e_8185;
    assign _e_8187 = _e_8182 && _e_8186;
    assign _e_2637 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8188 = 1;
    assign _e_2643 = \m0 [42:0];
    assign x_n1 = _e_2643[36:29];
    assign _e_8190 = \m0 [43] == 1'd1;
    assign _e_8192 = _e_2643[42:37] == 6'd38;
    localparam[0:0] _e_8193 = 1;
    assign _e_8194 = _e_8192 && _e_8193;
    assign _e_8195 = _e_8190 && _e_8194;
    assign _e_2645 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8196 = 1;
    assign _e_2648 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8195, _e_8196})
            2'b1?: _e_2640 = _e_2645;
            2'b01: _e_2640 = _e_2648;
            2'b?: _e_2640 = 9'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8187, _e_8188})
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
    (* src = "src/cmp.spade:25,9" *)
    logic[31:0] \v ;
    logic _e_8198;
    logic _e_8200;
    logic _e_8202;
    (* src = "src/cmp.spade:24,42" *)
    logic[31:0] _e_2654;
    (* src = "src/cmp.spade:24,14" *)
    reg[31:0] \a ;
    (* src = "src/cmp.spade:31,9" *)
    logic[34:0] _e_2665;
    (* src = "src/cmp.spade:31,14" *)
    logic[2:0] _e_2663;
    (* src = "src/cmp.spade:31,14" *)
    logic[31:0] \b ;
    logic _e_8204;
    logic _e_8207;
    logic _e_8209;
    logic _e_8210;
    (* src = "src/cmp.spade:31,45" *)
    logic _e_2669;
    (* src = "src/cmp.spade:31,38" *)
    logic[31:0] _e_2668;
    (* src = "src/cmp.spade:31,33" *)
    logic[32:0] _e_2667;
    (* src = "src/cmp.spade:32,9" *)
    logic[34:0] _e_2674;
    (* src = "src/cmp.spade:32,14" *)
    logic[2:0] _e_2672;
    (* src = "src/cmp.spade:32,14" *)
    logic[31:0] b_n1;
    logic _e_8212;
    logic _e_8215;
    logic _e_8217;
    logic _e_8218;
    (* src = "src/cmp.spade:32,46" *)
    logic _e_2678;
    (* src = "src/cmp.spade:32,39" *)
    logic[31:0] _e_2677;
    (* src = "src/cmp.spade:32,34" *)
    logic[32:0] _e_2676;
    (* src = "src/cmp.spade:33,9" *)
    logic[34:0] _e_2683;
    (* src = "src/cmp.spade:33,14" *)
    logic[2:0] _e_2681;
    (* src = "src/cmp.spade:33,14" *)
    logic[31:0] b_n2;
    logic _e_8220;
    logic _e_8223;
    logic _e_8225;
    logic _e_8226;
    (* src = "src/cmp.spade:33,46" *)
    logic _e_2687;
    (* src = "src/cmp.spade:33,39" *)
    logic[31:0] _e_2686;
    (* src = "src/cmp.spade:33,34" *)
    logic[32:0] _e_2685;
    (* src = "src/cmp.spade:34,9" *)
    logic[34:0] _e_2692;
    (* src = "src/cmp.spade:34,14" *)
    logic[2:0] _e_2690;
    (* src = "src/cmp.spade:34,14" *)
    logic[31:0] b_n3;
    logic _e_8228;
    logic _e_8231;
    logic _e_8233;
    logic _e_8234;
    (* src = "src/cmp.spade:34,47" *)
    logic _e_2697;
    (* src = "src/cmp.spade:34,66" *)
    logic _e_2700;
    (* src = "src/cmp.spade:34,47" *)
    logic _e_2696;
    (* src = "src/cmp.spade:34,40" *)
    logic[31:0] _e_2695;
    (* src = "src/cmp.spade:34,35" *)
    logic[32:0] _e_2694;
    (* src = "src/cmp.spade:35,9" *)
    logic[34:0] _e_2705;
    (* src = "src/cmp.spade:35,14" *)
    logic[2:0] _e_2703;
    (* src = "src/cmp.spade:35,14" *)
    logic[31:0] b_n4;
    logic _e_8236;
    logic _e_8239;
    logic _e_8241;
    logic _e_8242;
    (* src = "src/cmp.spade:35,46" *)
    logic _e_2709;
    (* src = "src/cmp.spade:35,39" *)
    logic[31:0] _e_2708;
    (* src = "src/cmp.spade:35,34" *)
    logic[32:0] _e_2707;
    (* src = "src/cmp.spade:36,9" *)
    logic[34:0] _e_2714;
    (* src = "src/cmp.spade:36,14" *)
    logic[2:0] _e_2712;
    (* src = "src/cmp.spade:36,14" *)
    logic[31:0] b_n5;
    logic _e_8244;
    logic _e_8247;
    logic _e_8249;
    logic _e_8250;
    (* src = "src/cmp.spade:36,46" *)
    logic _e_2719;
    (* src = "src/cmp.spade:36,57" *)
    logic _e_2722;
    (* src = "src/cmp.spade:36,46" *)
    logic _e_2718;
    (* src = "src/cmp.spade:36,39" *)
    logic[31:0] _e_2717;
    (* src = "src/cmp.spade:36,34" *)
    logic[32:0] _e_2716;
    logic _e_8252;
    (* src = "src/cmp.spade:37,34" *)
    logic[32:0] _e_2726;
    (* src = "src/cmp.spade:30,36" *)
    logic[32:0] \result ;
    (* src = "src/cmp.spade:41,51" *)
    logic[32:0] _e_2731;
    (* src = "src/cmp.spade:41,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2653 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_8198 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_8199 = 1;
    assign _e_8200 = _e_8198 && _e_8199;
    assign _e_8202 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8200, _e_8202})
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
    assign _e_8204 = \trig [35] == 1'd1;
    assign _e_8207 = _e_2663[2:0] == 3'd0;
    localparam[0:0] _e_8208 = 1;
    assign _e_8209 = _e_8207 && _e_8208;
    assign _e_8210 = _e_8204 && _e_8209;
    assign _e_2669 = \a  == \b ;
    (* src = "src/cmp.spade:31,38" *)
    \tta::cmp::to_u32  to_u32_0(.x_i(_e_2669), .output__(_e_2668));
    assign _e_2667 = {1'd1, _e_2668};
    assign _e_2674 = \trig [34:0];
    assign _e_2672 = _e_2674[34:32];
    assign b_n1 = _e_2674[31:0];
    assign _e_8212 = \trig [35] == 1'd1;
    assign _e_8215 = _e_2672[2:0] == 3'd1;
    localparam[0:0] _e_8216 = 1;
    assign _e_8217 = _e_8215 && _e_8216;
    assign _e_8218 = _e_8212 && _e_8217;
    assign _e_2678 = \a  != b_n1;
    (* src = "src/cmp.spade:32,39" *)
    \tta::cmp::to_u32  to_u32_1(.x_i(_e_2678), .output__(_e_2677));
    assign _e_2676 = {1'd1, _e_2677};
    assign _e_2683 = \trig [34:0];
    assign _e_2681 = _e_2683[34:32];
    assign b_n2 = _e_2683[31:0];
    assign _e_8220 = \trig [35] == 1'd1;
    assign _e_8223 = _e_2681[2:0] == 3'd2;
    localparam[0:0] _e_8224 = 1;
    assign _e_8225 = _e_8223 && _e_8224;
    assign _e_8226 = _e_8220 && _e_8225;
    (* src = "src/cmp.spade:33,46" *)
    \tta::cmp::signed_lt  signed_lt_0(.a_i(\a ), .b_i(b_n2), .output__(_e_2687));
    (* src = "src/cmp.spade:33,39" *)
    \tta::cmp::to_u32  to_u32_2(.x_i(_e_2687), .output__(_e_2686));
    assign _e_2685 = {1'd1, _e_2686};
    assign _e_2692 = \trig [34:0];
    assign _e_2690 = _e_2692[34:32];
    assign b_n3 = _e_2692[31:0];
    assign _e_8228 = \trig [35] == 1'd1;
    assign _e_8231 = _e_2690[2:0] == 3'd3;
    localparam[0:0] _e_8232 = 1;
    assign _e_8233 = _e_8231 && _e_8232;
    assign _e_8234 = _e_8228 && _e_8233;
    (* src = "src/cmp.spade:34,47" *)
    \tta::cmp::signed_lt  signed_lt_1(.a_i(\a ), .b_i(b_n3), .output__(_e_2697));
    assign _e_2700 = \a  == b_n3;
    assign _e_2696 = _e_2697 || _e_2700;
    (* src = "src/cmp.spade:34,40" *)
    \tta::cmp::to_u32  to_u32_3(.x_i(_e_2696), .output__(_e_2695));
    assign _e_2694 = {1'd1, _e_2695};
    assign _e_2705 = \trig [34:0];
    assign _e_2703 = _e_2705[34:32];
    assign b_n4 = _e_2705[31:0];
    assign _e_8236 = \trig [35] == 1'd1;
    assign _e_8239 = _e_2703[2:0] == 3'd4;
    localparam[0:0] _e_8240 = 1;
    assign _e_8241 = _e_8239 && _e_8240;
    assign _e_8242 = _e_8236 && _e_8241;
    assign _e_2709 = \a  < b_n4;
    (* src = "src/cmp.spade:35,39" *)
    \tta::cmp::to_u32  to_u32_4(.x_i(_e_2709), .output__(_e_2708));
    assign _e_2707 = {1'd1, _e_2708};
    assign _e_2714 = \trig [34:0];
    assign _e_2712 = _e_2714[34:32];
    assign b_n5 = _e_2714[31:0];
    assign _e_8244 = \trig [35] == 1'd1;
    assign _e_8247 = _e_2712[2:0] == 3'd5;
    localparam[0:0] _e_8248 = 1;
    assign _e_8249 = _e_8247 && _e_8248;
    assign _e_8250 = _e_8244 && _e_8249;
    assign _e_2719 = \a  < b_n5;
    assign _e_2722 = \a  == b_n5;
    assign _e_2718 = _e_2719 || _e_2722;
    (* src = "src/cmp.spade:36,39" *)
    \tta::cmp::to_u32  to_u32_5(.x_i(_e_2718), .output__(_e_2717));
    assign _e_2716 = {1'd1, _e_2717};
    assign _e_8252 = \trig [35] == 1'd0;
    assign _e_2726 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8210, _e_8218, _e_8226, _e_8234, _e_8242, _e_8250, _e_8252})
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
    (* src = "src/cmp.spade:48,9" *)
    logic[42:0] _e_2738;
    (* src = "src/cmp.spade:48,14" *)
    logic[31:0] \x ;
    logic _e_8254;
    logic _e_8256;
    logic _e_8258;
    logic _e_8259;
    (* src = "src/cmp.spade:48,35" *)
    logic[32:0] _e_2740;
    (* src = "src/cmp.spade:49,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmp.spade:50,13" *)
    logic[42:0] _e_2746;
    (* src = "src/cmp.spade:50,18" *)
    logic[31:0] x_n1;
    logic _e_8262;
    logic _e_8264;
    logic _e_8266;
    logic _e_8267;
    (* src = "src/cmp.spade:50,39" *)
    logic[32:0] _e_2748;
    (* src = "src/cmp.spade:51,13" *)
    logic[43:0] __n1;
    (* src = "src/cmp.spade:51,18" *)
    logic[32:0] _e_2751;
    (* src = "src/cmp.spade:49,14" *)
    logic[32:0] _e_2743;
    (* src = "src/cmp.spade:47,5" *)
    logic[32:0] _e_2735;
    assign _e_2738 = \m1 [42:0];
    assign \x  = _e_2738[36:5];
    assign _e_8254 = \m1 [43] == 1'd1;
    assign _e_8256 = _e_2738[42:37] == 6'd11;
    localparam[0:0] _e_8257 = 1;
    assign _e_8258 = _e_8256 && _e_8257;
    assign _e_8259 = _e_8254 && _e_8258;
    assign _e_2740 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8260 = 1;
    assign _e_2746 = \m0 [42:0];
    assign x_n1 = _e_2746[36:5];
    assign _e_8262 = \m0 [43] == 1'd1;
    assign _e_8264 = _e_2746[42:37] == 6'd11;
    localparam[0:0] _e_8265 = 1;
    assign _e_8266 = _e_8264 && _e_8265;
    assign _e_8267 = _e_8262 && _e_8266;
    assign _e_2748 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8268 = 1;
    assign _e_2751 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8267, _e_8268})
            2'b1?: _e_2743 = _e_2748;
            2'b01: _e_2743 = _e_2751;
            2'b?: _e_2743 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8259, _e_8260})
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
    (* src = "src/cmp.spade:57,9" *)
    logic[42:0] _e_2757;
    (* src = "src/cmp.spade:57,14" *)
    logic[2:0] \op ;
    (* src = "src/cmp.spade:57,14" *)
    logic[31:0] \x ;
    logic _e_8270;
    logic _e_8272;
    logic _e_8275;
    logic _e_8276;
    logic _e_8277;
    (* src = "src/cmp.spade:57,44" *)
    logic[34:0] _e_2760;
    (* src = "src/cmp.spade:57,39" *)
    logic[35:0] _e_2759;
    (* src = "src/cmp.spade:58,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmp.spade:59,13" *)
    logic[42:0] _e_2768;
    (* src = "src/cmp.spade:59,18" *)
    logic[2:0] op_n1;
    (* src = "src/cmp.spade:59,18" *)
    logic[31:0] x_n1;
    logic _e_8280;
    logic _e_8282;
    logic _e_8285;
    logic _e_8286;
    logic _e_8287;
    (* src = "src/cmp.spade:59,48" *)
    logic[34:0] _e_2771;
    (* src = "src/cmp.spade:59,43" *)
    logic[35:0] _e_2770;
    (* src = "src/cmp.spade:60,13" *)
    logic[43:0] __n1;
    (* src = "src/cmp.spade:60,18" *)
    logic[35:0] _e_2775;
    (* src = "src/cmp.spade:58,14" *)
    logic[35:0] _e_2764;
    (* src = "src/cmp.spade:56,5" *)
    logic[35:0] _e_2753;
    assign _e_2757 = \m1 [42:0];
    assign \op  = _e_2757[36:34];
    assign \x  = _e_2757[33:2];
    assign _e_8270 = \m1 [43] == 1'd1;
    assign _e_8272 = _e_2757[42:37] == 6'd12;
    localparam[0:0] _e_8273 = 1;
    localparam[0:0] _e_8274 = 1;
    assign _e_8275 = _e_8272 && _e_8273;
    assign _e_8276 = _e_8275 && _e_8274;
    assign _e_8277 = _e_8270 && _e_8276;
    assign _e_2760 = {\op , \x };
    assign _e_2759 = {1'd1, _e_2760};
    assign \_  = \m1 ;
    localparam[0:0] _e_8278 = 1;
    assign _e_2768 = \m0 [42:0];
    assign op_n1 = _e_2768[36:34];
    assign x_n1 = _e_2768[33:2];
    assign _e_8280 = \m0 [43] == 1'd1;
    assign _e_8282 = _e_2768[42:37] == 6'd12;
    localparam[0:0] _e_8283 = 1;
    localparam[0:0] _e_8284 = 1;
    assign _e_8285 = _e_8282 && _e_8283;
    assign _e_8286 = _e_8285 && _e_8284;
    assign _e_8287 = _e_8280 && _e_8286;
    assign _e_2771 = {op_n1, x_n1};
    assign _e_2770 = {1'd1, _e_2771};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8288 = 1;
    assign _e_2775 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_8287, _e_8288})
            2'b1?: _e_2764 = _e_2770;
            2'b01: _e_2764 = _e_2775;
            2'b?: _e_2764 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8277, _e_8278})
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
    (* src = "src/cmp.spade:67,5" *)
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
    (* src = "src/cmp.spade:76,29" *)
    logic[31:0] _e_2786;
    (* src = "src/cmp.spade:76,29" *)
    logic[31:0] _e_2785;
    (* src = "src/cmp.spade:76,23" *)
    logic \sa ;
    (* src = "src/cmp.spade:77,29" *)
    logic[31:0] _e_2793;
    (* src = "src/cmp.spade:77,29" *)
    logic[31:0] _e_2792;
    (* src = "src/cmp.spade:77,23" *)
    logic \sb ;
    (* src = "src/cmp.spade:78,8" *)
    logic _e_2799;
    (* src = "src/cmp.spade:79,9" *)
    logic _e_2803;
    (* src = "src/cmp.spade:81,9" *)
    logic _e_2807;
    (* src = "src/cmp.spade:78,5" *)
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
    (* src = "src/gpi.spade:9,12" *)
    reg[31:0] \s1 ;
    (* src = "src/gpi.spade:10,12" *)
    reg[31:0] \s2 ;
    (* src = "src/gpi.spade:11,3" *)
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
    logic _e_8291;
    logic _e_8293;
    logic _e_8295;
    (* src = "src/pc.spade:18,9" *)
    logic[21:0] _e_2842;
    (* src = "src/pc.spade:18,9" *)
    logic[10:0] _e_2839;
    (* src = "src/pc.spade:18,9" *)
    logic[10:0] _e_2841;
    (* src = "src/pc.spade:18,16" *)
    logic[9:0] \pc_target ;
    logic _e_8298;
    logic _e_8300;
    logic _e_8302;
    logic _e_8303;
    (* src = "src/pc.spade:19,9" *)
    logic[21:0] _e_2846;
    (* src = "src/pc.spade:19,9" *)
    logic[10:0] _e_2844;
    (* src = "src/pc.spade:19,9" *)
    logic[10:0] _e_2845;
    logic _e_8306;
    logic _e_8308;
    logic _e_8309;
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
    assign _e_8291 = _e_2835[10] == 1'd1;
    localparam[0:0] _e_8292 = 1;
    assign _e_8293 = _e_8291 && _e_8292;
    localparam[0:0] _e_8294 = 1;
    assign _e_8295 = _e_8293 && _e_8294;
    assign _e_2842 = _e_2830;
    assign _e_2839 = _e_2830[21:11];
    assign _e_2841 = _e_2830[10:0];
    assign \pc_target  = _e_2841[9:0];
    assign _e_8298 = _e_2839[10] == 1'd0;
    assign _e_8300 = _e_2841[10] == 1'd1;
    localparam[0:0] _e_8301 = 1;
    assign _e_8302 = _e_8300 && _e_8301;
    assign _e_8303 = _e_8298 && _e_8302;
    assign _e_2846 = _e_2830;
    assign _e_2844 = _e_2830[21:11];
    assign _e_2845 = _e_2830[10:0];
    assign _e_8306 = _e_2844[10] == 1'd0;
    assign _e_8308 = _e_2845[10] == 1'd0;
    assign _e_8309 = _e_8306 && _e_8308;
    localparam[9:0] _e_2850 = 1;
    assign _e_2848 = \pc  + _e_2850;
    assign _e_2847 = _e_2848[9:0];
    always_comb begin
        priority casez ({_e_8295, _e_8303, _e_8309})
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
    logic _e_8311;
    logic _e_8313;
    logic _e_8315;
    logic _e_8316;
    (* src = "src/pc.spade:27,34" *)
    logic[10:0] _e_2858;
    (* src = "src/pc.spade:28,9" *)
    logic[43:0] \_ ;
    (* src = "src/pc.spade:28,25" *)
    logic[42:0] _e_2864;
    (* src = "src/pc.spade:28,30" *)
    logic[9:0] a_n1;
    logic _e_8319;
    logic _e_8321;
    logic _e_8323;
    logic _e_8324;
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
    assign _e_8311 = \m1 [43] == 1'd1;
    assign _e_8313 = _e_2856[42:37] == 6'd3;
    localparam[0:0] _e_8314 = 1;
    assign _e_8315 = _e_8313 && _e_8314;
    assign _e_8316 = _e_8311 && _e_8315;
    assign _e_2858 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8317 = 1;
    assign _e_2864 = \m0 [42:0];
    assign a_n1 = _e_2864[36:27];
    assign _e_8319 = \m0 [43] == 1'd1;
    assign _e_8321 = _e_2864[42:37] == 6'd3;
    localparam[0:0] _e_8322 = 1;
    assign _e_8323 = _e_8321 && _e_8322;
    assign _e_8324 = _e_8319 && _e_8323;
    assign _e_2866 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8325 = 1;
    assign _e_2869 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_8324, _e_8325})
            2'b1?: _e_2861 = _e_2866;
            2'b01: _e_2861 = _e_2869;
            2'b?: _e_2861 = 11'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8316, _e_8317})
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
    (* src = "src/gpo.spade:11,7" *)
    logic[15:0] \v ;
    logic _e_8327;
    logic _e_8329;
    logic _e_8331;
    (* src = "src/gpo.spade:10,5" *)
    logic[15:0] _e_2875;
    (* src = "src/gpo.spade:9,12" *)
    reg[15:0] \outv ;
    localparam[15:0] _e_2874 = 0;
    assign \v  = \wr [15:0];
    assign _e_8327 = \wr [16] == 1'd1;
    localparam[0:0] _e_8328 = 1;
    assign _e_8329 = _e_8327 && _e_8328;
    assign _e_8331 = \wr [16] == 1'd0;
    always_comb begin
        priority casez ({_e_8329, _e_8331})
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
    (* src = "src/gpo.spade:21,9" *)
    logic[42:0] _e_2887;
    (* src = "src/gpo.spade:21,14" *)
    logic[15:0] \x ;
    logic _e_8333;
    logic _e_8335;
    logic _e_8337;
    logic _e_8338;
    (* src = "src/gpo.spade:21,34" *)
    logic[16:0] _e_2889;
    (* src = "src/gpo.spade:22,9" *)
    logic[43:0] \_ ;
    (* src = "src/gpo.spade:23,13" *)
    logic[42:0] _e_2895;
    (* src = "src/gpo.spade:23,18" *)
    logic[15:0] x_n1;
    logic _e_8341;
    logic _e_8343;
    logic _e_8345;
    logic _e_8346;
    (* src = "src/gpo.spade:23,38" *)
    logic[16:0] _e_2897;
    (* src = "src/gpo.spade:24,13" *)
    logic[43:0] __n1;
    (* src = "src/gpo.spade:24,18" *)
    logic[16:0] _e_2900;
    (* src = "src/gpo.spade:22,14" *)
    logic[16:0] _e_2892;
    (* src = "src/gpo.spade:20,5" *)
    logic[16:0] _e_2884;
    assign _e_2887 = \m1 [42:0];
    assign \x  = _e_2887[36:21];
    assign _e_8333 = \m1 [43] == 1'd1;
    assign _e_8335 = _e_2887[42:37] == 6'd10;
    localparam[0:0] _e_8336 = 1;
    assign _e_8337 = _e_8335 && _e_8336;
    assign _e_8338 = _e_8333 && _e_8337;
    assign _e_2889 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8339 = 1;
    assign _e_2895 = \m0 [42:0];
    assign x_n1 = _e_2895[36:21];
    assign _e_8341 = \m0 [43] == 1'd1;
    assign _e_8343 = _e_2895[42:37] == 6'd10;
    localparam[0:0] _e_8344 = 1;
    assign _e_8345 = _e_8343 && _e_8344;
    assign _e_8346 = _e_8341 && _e_8345;
    assign _e_2897 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8347 = 1;
    assign _e_2900 = {1'd0, 16'bX};
    always_comb begin
        priority casez ({_e_8346, _e_8347})
            2'b1?: _e_2892 = _e_2897;
            2'b01: _e_2892 = _e_2900;
            2'b?: _e_2892 = 17'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8338, _e_8339})
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
    (* src = "src/spi.spade:11,16" *)
    logic[14:0] \data ;
    (* src = "src/spi.spade:12,48" *)
    logic[32:0] _e_2911;
    (* src = "src/spi.spade:13,7" *)
    logic[31:0] \b ;
    logic _e_8349;
    logic _e_8351;
    logic[31:0] _e_2917;
    (* src = "src/spi.spade:13,18" *)
    logic[32:0] _e_2916;
    logic _e_8353;
    (* src = "src/spi.spade:14,15" *)
    logic[32:0] _e_2920;
    (* src = "src/spi.spade:12,56" *)
    logic[32:0] _e_2912;
    (* src = "src/spi.spade:12,14" *)
    reg[32:0] data_n1;
    (* src = "src/spi.spade:11,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\miso_byte ), .pop_i(\pop ), .output__(\data ));
    assign _e_2911 = {1'd0, 32'bX};
    assign \b  = data_n1[31:0];
    assign _e_8349 = data_n1[32] == 1'd1;
    localparam[0:0] _e_8350 = 1;
    assign _e_8351 = _e_8349 && _e_8350;
    assign _e_2917 = \b ;
    assign _e_2916 = {1'd1, _e_2917};
    assign _e_8353 = data_n1[32] == 1'd0;
    assign _e_2920 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8351, _e_8353})
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
    (* src = "src/spi.spade:31,65" *)
    logic _e_2927;
    (* src = "src/spi.spade:31,16" *)
    logic[14:0] \data ;
    (* src = "src/spi.spade:32,47" *)
    logic[8:0] _e_2933;
    (* src = "src/spi.spade:33,7" *)
    logic[7:0] \b ;
    logic _e_8355;
    logic _e_8357;
    (* src = "src/spi.spade:33,18" *)
    logic[8:0] _e_2938;
    logic _e_8359;
    (* src = "src/spi.spade:34,15" *)
    logic[8:0] _e_2941;
    (* src = "src/spi.spade:32,55" *)
    logic[8:0] _e_2934;
    (* src = "src/spi.spade:32,14" *)
    reg[8:0] data_n1;
    assign _e_2927 = !\spi_busy ;
    (* src = "src/spi.spade:31,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\byte_to_write ), .pop_i(_e_2927), .output__(\data ));
    assign _e_2933 = {1'd0, 8'bX};
    assign \b  = data_n1[7:0];
    assign _e_8355 = data_n1[8] == 1'd1;
    localparam[0:0] _e_8356 = 1;
    assign _e_8357 = _e_8355 && _e_8356;
    assign _e_2938 = {1'd1, \b };
    assign _e_8359 = data_n1[8] == 1'd0;
    assign _e_2941 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8357, _e_8359})
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
    (* src = "src/spi.spade:42,9" *)
    logic[42:0] _e_2948;
    logic _e_8361;
    logic _e_8363;
    logic _e_8364;
    (* src = "src/spi.spade:43,9" *)
    logic[43:0] \_ ;
    (* src = "src/spi.spade:44,13" *)
    logic[42:0] _e_2954;
    logic _e_8367;
    logic _e_8369;
    logic _e_8370;
    (* src = "src/spi.spade:45,13" *)
    logic[43:0] __n1;
    (* src = "src/spi.spade:43,14" *)
    logic _e_2952;
    (* src = "src/spi.spade:41,5" *)
    logic _e_2946;
    assign _e_2948 = \m1 [42:0];
    assign _e_8361 = \m1 [43] == 1'd1;
    assign _e_8363 = _e_2948[42:37] == 6'd42;
    assign _e_8364 = _e_8361 && _e_8363;
    localparam[0:0] _e_2950 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_8365 = 1;
    assign _e_2954 = \m0 [42:0];
    assign _e_8367 = \m0 [43] == 1'd1;
    assign _e_8369 = _e_2954[42:37] == 6'd42;
    assign _e_8370 = _e_8367 && _e_8369;
    localparam[0:0] _e_2956 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_8371 = 1;
    localparam[0:0] _e_2958 = 0;
    always_comb begin
        priority casez ({_e_8370, _e_8371})
            2'b1?: _e_2952 = _e_2956;
            2'b01: _e_2952 = _e_2958;
            2'b?: _e_2952 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8364, _e_8365})
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
    (* src = "src/spi.spade:51,9" *)
    logic[42:0] _e_2963;
    (* src = "src/spi.spade:51,14" *)
    logic[7:0] \x ;
    logic _e_8373;
    logic _e_8375;
    logic _e_8377;
    logic _e_8378;
    (* src = "src/spi.spade:51,35" *)
    logic[8:0] _e_2965;
    (* src = "src/spi.spade:52,9" *)
    logic[43:0] \_ ;
    (* src = "src/spi.spade:53,13" *)
    logic[42:0] _e_2971;
    (* src = "src/spi.spade:53,18" *)
    logic[7:0] x_n1;
    logic _e_8381;
    logic _e_8383;
    logic _e_8385;
    logic _e_8386;
    (* src = "src/spi.spade:53,39" *)
    logic[8:0] _e_2973;
    (* src = "src/spi.spade:54,13" *)
    logic[43:0] __n1;
    (* src = "src/spi.spade:54,18" *)
    logic[8:0] _e_2976;
    (* src = "src/spi.spade:52,14" *)
    logic[8:0] _e_2968;
    (* src = "src/spi.spade:50,5" *)
    logic[8:0] _e_2960;
    assign _e_2963 = \m1 [42:0];
    assign \x  = _e_2963[36:29];
    assign _e_8373 = \m1 [43] == 1'd1;
    assign _e_8375 = _e_2963[42:37] == 6'd20;
    localparam[0:0] _e_8376 = 1;
    assign _e_8377 = _e_8375 && _e_8376;
    assign _e_8378 = _e_8373 && _e_8377;
    assign _e_2965 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8379 = 1;
    assign _e_2971 = \m0 [42:0];
    assign x_n1 = _e_2971[36:29];
    assign _e_8381 = \m0 [43] == 1'd1;
    assign _e_8383 = _e_2971[42:37] == 6'd20;
    localparam[0:0] _e_8384 = 1;
    assign _e_8385 = _e_8383 && _e_8384;
    assign _e_8386 = _e_8381 && _e_8385;
    assign _e_2973 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8387 = 1;
    assign _e_2976 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8386, _e_8387})
            2'b1?: _e_2968 = _e_2973;
            2'b01: _e_2968 = _e_2976;
            2'b?: _e_2968 = 9'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8378, _e_8379})
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
    (* src = "src/lalu.spade:22,9" *)
    logic[31:0] \v ;
    logic _e_8389;
    logic _e_8391;
    logic _e_8393;
    (* src = "src/lalu.spade:21,45" *)
    logic[31:0] _e_2982;
    (* src = "src/lalu.spade:21,14" *)
    reg[31:0] \op_a ;
    (* src = "src/lalu.spade:28,9" *)
    logic[32:0] _e_2993;
    (* src = "src/lalu.spade:28,14" *)
    logic _e_2991;
    (* src = "src/lalu.spade:28,14" *)
    logic[31:0] \b ;
    logic _e_8395;
    logic _e_8398;
    logic _e_8400;
    logic _e_8401;
    (* src = "src/lalu.spade:28,46" *)
    logic[32:0] _e_2997;
    (* src = "src/lalu.spade:28,40" *)
    logic[31:0] _e_2996;
    (* src = "src/lalu.spade:28,35" *)
    logic[32:0] _e_2995;
    (* src = "src/lalu.spade:29,9" *)
    logic[32:0] _e_3002;
    (* src = "src/lalu.spade:29,14" *)
    logic _e_3000;
    (* src = "src/lalu.spade:29,14" *)
    logic[31:0] b_n1;
    logic _e_8403;
    logic _e_8406;
    logic _e_8408;
    logic _e_8409;
    (* src = "src/lalu.spade:29,46" *)
    logic[32:0] _e_3006;
    (* src = "src/lalu.spade:29,40" *)
    logic[31:0] _e_3005;
    (* src = "src/lalu.spade:29,35" *)
    logic[32:0] _e_3004;
    logic _e_8411;
    (* src = "src/lalu.spade:30,34" *)
    logic[32:0] _e_3010;
    (* src = "src/lalu.spade:27,36" *)
    logic[32:0] \result ;
    (* src = "src/lalu.spade:34,51" *)
    logic[32:0] _e_3015;
    (* src = "src/lalu.spade:34,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2981 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_8389 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_8390 = 1;
    assign _e_8391 = _e_8389 && _e_8390;
    assign _e_8393 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8391, _e_8393})
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
    assign _e_8395 = \trig [33] == 1'd1;
    assign _e_8398 = _e_2991 == 1'd0;
    localparam[0:0] _e_8399 = 1;
    assign _e_8400 = _e_8398 && _e_8399;
    assign _e_8401 = _e_8395 && _e_8400;
    assign _e_2997 = \op_a  + \b ;
    assign _e_2996 = _e_2997[31:0];
    assign _e_2995 = {1'd1, _e_2996};
    assign _e_3002 = \trig [32:0];
    assign _e_3000 = _e_3002[32];
    assign b_n1 = _e_3002[31:0];
    assign _e_8403 = \trig [33] == 1'd1;
    assign _e_8406 = _e_3000 == 1'd1;
    localparam[0:0] _e_8407 = 1;
    assign _e_8408 = _e_8406 && _e_8407;
    assign _e_8409 = _e_8403 && _e_8408;
    assign _e_3006 = \op_a  - b_n1;
    assign _e_3005 = _e_3006[31:0];
    assign _e_3004 = {1'd1, _e_3005};
    assign _e_8411 = \trig [33] == 1'd0;
    assign _e_3010 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8401, _e_8409, _e_8411})
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
    (* src = "src/lalu.spade:42,9" *)
    logic[42:0] _e_3022;
    (* src = "src/lalu.spade:42,14" *)
    logic[31:0] \x ;
    logic _e_8413;
    logic _e_8415;
    logic _e_8417;
    logic _e_8418;
    (* src = "src/lalu.spade:42,36" *)
    logic[32:0] _e_3024;
    (* src = "src/lalu.spade:43,9" *)
    logic[43:0] \_ ;
    (* src = "src/lalu.spade:44,13" *)
    logic[42:0] _e_3030;
    (* src = "src/lalu.spade:44,18" *)
    logic[31:0] x_n1;
    logic _e_8421;
    logic _e_8423;
    logic _e_8425;
    logic _e_8426;
    (* src = "src/lalu.spade:44,40" *)
    logic[32:0] _e_3032;
    (* src = "src/lalu.spade:45,13" *)
    logic[43:0] __n1;
    (* src = "src/lalu.spade:45,18" *)
    logic[32:0] _e_3035;
    (* src = "src/lalu.spade:43,14" *)
    logic[32:0] _e_3027;
    (* src = "src/lalu.spade:41,5" *)
    logic[32:0] _e_3019;
    assign _e_3022 = \m1 [42:0];
    assign \x  = _e_3022[36:5];
    assign _e_8413 = \m1 [43] == 1'd1;
    assign _e_8415 = _e_3022[42:37] == 6'd14;
    localparam[0:0] _e_8416 = 1;
    assign _e_8417 = _e_8415 && _e_8416;
    assign _e_8418 = _e_8413 && _e_8417;
    assign _e_3024 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8419 = 1;
    assign _e_3030 = \m0 [42:0];
    assign x_n1 = _e_3030[36:5];
    assign _e_8421 = \m0 [43] == 1'd1;
    assign _e_8423 = _e_3030[42:37] == 6'd14;
    localparam[0:0] _e_8424 = 1;
    assign _e_8425 = _e_8423 && _e_8424;
    assign _e_8426 = _e_8421 && _e_8425;
    assign _e_3032 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8427 = 1;
    assign _e_3035 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8426, _e_8427})
            2'b1?: _e_3027 = _e_3032;
            2'b01: _e_3027 = _e_3035;
            2'b?: _e_3027 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8418, _e_8419})
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
    (* src = "src/lalu.spade:51,9" *)
    logic[42:0] _e_3041;
    (* src = "src/lalu.spade:51,14" *)
    logic \op ;
    (* src = "src/lalu.spade:51,14" *)
    logic[31:0] \x ;
    logic _e_8429;
    logic _e_8431;
    logic _e_8434;
    logic _e_8435;
    logic _e_8436;
    (* src = "src/lalu.spade:51,45" *)
    logic[32:0] _e_3044;
    (* src = "src/lalu.spade:51,40" *)
    logic[33:0] _e_3043;
    (* src = "src/lalu.spade:52,9" *)
    logic[43:0] \_ ;
    (* src = "src/lalu.spade:53,13" *)
    logic[42:0] _e_3052;
    (* src = "src/lalu.spade:53,18" *)
    logic op_n1;
    (* src = "src/lalu.spade:53,18" *)
    logic[31:0] x_n1;
    logic _e_8439;
    logic _e_8441;
    logic _e_8444;
    logic _e_8445;
    logic _e_8446;
    (* src = "src/lalu.spade:53,49" *)
    logic[32:0] _e_3055;
    (* src = "src/lalu.spade:53,44" *)
    logic[33:0] _e_3054;
    (* src = "src/lalu.spade:54,13" *)
    logic[43:0] __n1;
    (* src = "src/lalu.spade:54,18" *)
    logic[33:0] _e_3059;
    (* src = "src/lalu.spade:52,14" *)
    logic[33:0] _e_3048;
    (* src = "src/lalu.spade:50,5" *)
    logic[33:0] _e_3037;
    assign _e_3041 = \m1 [42:0];
    assign \op  = _e_3041[36:36];
    assign \x  = _e_3041[35:4];
    assign _e_8429 = \m1 [43] == 1'd1;
    assign _e_8431 = _e_3041[42:37] == 6'd15;
    localparam[0:0] _e_8432 = 1;
    localparam[0:0] _e_8433 = 1;
    assign _e_8434 = _e_8431 && _e_8432;
    assign _e_8435 = _e_8434 && _e_8433;
    assign _e_8436 = _e_8429 && _e_8435;
    assign _e_3044 = {\op , \x };
    assign _e_3043 = {1'd1, _e_3044};
    assign \_  = \m1 ;
    localparam[0:0] _e_8437 = 1;
    assign _e_3052 = \m0 [42:0];
    assign op_n1 = _e_3052[36:36];
    assign x_n1 = _e_3052[35:4];
    assign _e_8439 = \m0 [43] == 1'd1;
    assign _e_8441 = _e_3052[42:37] == 6'd15;
    localparam[0:0] _e_8442 = 1;
    localparam[0:0] _e_8443 = 1;
    assign _e_8444 = _e_8441 && _e_8442;
    assign _e_8445 = _e_8444 && _e_8443;
    assign _e_8446 = _e_8439 && _e_8445;
    assign _e_3055 = {op_n1, x_n1};
    assign _e_3054 = {1'd1, _e_3055};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8447 = 1;
    assign _e_3059 = {1'd0, 33'bX};
    always_comb begin
        priority casez ({_e_8446, _e_8447})
            2'b1?: _e_3048 = _e_3054;
            2'b01: _e_3048 = _e_3059;
            2'b?: _e_3048 = 34'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8436, _e_8437})
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
    (* src = "src/tta.spade:197,11" *)
    logic[43:0] _e_3062;
    (* src = "src/tta.spade:198,9" *)
    logic[43:0] _e_3069;
    (* src = "src/tta.spade:198,9" *)
    logic[10:0] _e_3066;
    (* src = "src/tta.spade:198,10" *)
    logic[3:0] \i ;
    (* src = "src/tta.spade:198,9" *)
    logic[32:0] _e_3068;
    (* src = "src/tta.spade:198,32" *)
    logic[31:0] \x ;
    logic _e_8450;
    logic _e_8452;
    logic _e_8454;
    logic _e_8456;
    logic _e_8457;
    (* src = "src/tta.spade:198,49" *)
    logic[42:0] _e_3071;
    (* src = "src/tta.spade:198,44" *)
    logic[43:0] _e_3070;
    (* src = "src/tta.spade:200,9" *)
    logic[43:0] _e_3077;
    (* src = "src/tta.spade:200,9" *)
    logic[10:0] _e_3074;
    (* src = "src/tta.spade:200,9" *)
    logic[32:0] _e_3076;
    (* src = "src/tta.spade:200,32" *)
    logic[31:0] x_n1;
    logic _e_8460;
    logic _e_8462;
    logic _e_8464;
    logic _e_8465;
    (* src = "src/tta.spade:200,49" *)
    logic[42:0] _e_3079;
    (* src = "src/tta.spade:200,44" *)
    logic[43:0] _e_3078;
    (* src = "src/tta.spade:201,9" *)
    logic[43:0] _e_3084;
    (* src = "src/tta.spade:201,9" *)
    logic[10:0] _e_3081;
    (* src = "src/tta.spade:201,9" *)
    logic[32:0] _e_3083;
    (* src = "src/tta.spade:201,32" *)
    logic[31:0] x_n2;
    logic _e_8468;
    logic _e_8470;
    logic _e_8472;
    logic _e_8473;
    (* src = "src/tta.spade:201,63" *)
    logic[4:0] _e_3087;
    (* src = "src/tta.spade:201,49" *)
    logic[42:0] _e_3086;
    (* src = "src/tta.spade:201,44" *)
    logic[43:0] _e_3085;
    (* src = "src/tta.spade:202,9" *)
    logic[43:0] _e_3092;
    (* src = "src/tta.spade:202,9" *)
    logic[10:0] _e_3089;
    (* src = "src/tta.spade:202,9" *)
    logic[32:0] _e_3091;
    (* src = "src/tta.spade:202,32" *)
    logic[31:0] x_n3;
    logic _e_8476;
    logic _e_8478;
    logic _e_8480;
    logic _e_8481;
    (* src = "src/tta.spade:202,63" *)
    logic[4:0] _e_3095;
    (* src = "src/tta.spade:202,49" *)
    logic[42:0] _e_3094;
    (* src = "src/tta.spade:202,44" *)
    logic[43:0] _e_3093;
    (* src = "src/tta.spade:203,9" *)
    logic[43:0] _e_3100;
    (* src = "src/tta.spade:203,9" *)
    logic[10:0] _e_3097;
    (* src = "src/tta.spade:203,9" *)
    logic[32:0] _e_3099;
    (* src = "src/tta.spade:203,32" *)
    logic[31:0] x_n4;
    logic _e_8484;
    logic _e_8486;
    logic _e_8488;
    logic _e_8489;
    (* src = "src/tta.spade:203,63" *)
    logic[4:0] _e_3103;
    (* src = "src/tta.spade:203,49" *)
    logic[42:0] _e_3102;
    (* src = "src/tta.spade:203,44" *)
    logic[43:0] _e_3101;
    (* src = "src/tta.spade:204,9" *)
    logic[43:0] _e_3108;
    (* src = "src/tta.spade:204,9" *)
    logic[10:0] _e_3105;
    (* src = "src/tta.spade:204,9" *)
    logic[32:0] _e_3107;
    (* src = "src/tta.spade:204,32" *)
    logic[31:0] x_n5;
    logic _e_8492;
    logic _e_8494;
    logic _e_8496;
    logic _e_8497;
    (* src = "src/tta.spade:204,63" *)
    logic[4:0] _e_3111;
    (* src = "src/tta.spade:204,49" *)
    logic[42:0] _e_3110;
    (* src = "src/tta.spade:204,44" *)
    logic[43:0] _e_3109;
    (* src = "src/tta.spade:205,9" *)
    logic[43:0] _e_3116;
    (* src = "src/tta.spade:205,9" *)
    logic[10:0] _e_3113;
    (* src = "src/tta.spade:205,9" *)
    logic[32:0] _e_3115;
    (* src = "src/tta.spade:205,33" *)
    logic[31:0] x_n6;
    logic _e_8500;
    logic _e_8502;
    logic _e_8504;
    logic _e_8505;
    (* src = "src/tta.spade:205,64" *)
    logic[4:0] _e_3119;
    (* src = "src/tta.spade:205,50" *)
    logic[42:0] _e_3118;
    (* src = "src/tta.spade:205,45" *)
    logic[43:0] _e_3117;
    (* src = "src/tta.spade:206,9" *)
    logic[43:0] _e_3124;
    (* src = "src/tta.spade:206,9" *)
    logic[10:0] _e_3121;
    (* src = "src/tta.spade:206,9" *)
    logic[32:0] _e_3123;
    (* src = "src/tta.spade:206,33" *)
    logic[31:0] x_n7;
    logic _e_8508;
    logic _e_8510;
    logic _e_8512;
    logic _e_8513;
    (* src = "src/tta.spade:206,64" *)
    logic[4:0] _e_3127;
    (* src = "src/tta.spade:206,50" *)
    logic[42:0] _e_3126;
    (* src = "src/tta.spade:206,45" *)
    logic[43:0] _e_3125;
    (* src = "src/tta.spade:207,9" *)
    logic[43:0] _e_3132;
    (* src = "src/tta.spade:207,9" *)
    logic[10:0] _e_3129;
    (* src = "src/tta.spade:207,9" *)
    logic[32:0] _e_3131;
    (* src = "src/tta.spade:207,33" *)
    logic[31:0] x_n8;
    logic _e_8516;
    logic _e_8518;
    logic _e_8520;
    logic _e_8521;
    (* src = "src/tta.spade:207,64" *)
    logic[4:0] _e_3135;
    (* src = "src/tta.spade:207,50" *)
    logic[42:0] _e_3134;
    (* src = "src/tta.spade:207,45" *)
    logic[43:0] _e_3133;
    (* src = "src/tta.spade:208,9" *)
    logic[43:0] _e_3140;
    (* src = "src/tta.spade:208,9" *)
    logic[10:0] _e_3137;
    (* src = "src/tta.spade:208,9" *)
    logic[32:0] _e_3139;
    (* src = "src/tta.spade:208,34" *)
    logic[31:0] x_n9;
    logic _e_8524;
    logic _e_8526;
    logic _e_8528;
    logic _e_8529;
    (* src = "src/tta.spade:208,65" *)
    logic[4:0] _e_3143;
    (* src = "src/tta.spade:208,51" *)
    logic[42:0] _e_3142;
    (* src = "src/tta.spade:208,46" *)
    logic[43:0] _e_3141;
    (* src = "src/tta.spade:209,9" *)
    logic[43:0] _e_3148;
    (* src = "src/tta.spade:209,9" *)
    logic[10:0] _e_3145;
    (* src = "src/tta.spade:209,9" *)
    logic[32:0] _e_3147;
    (* src = "src/tta.spade:209,34" *)
    logic[31:0] x_n10;
    logic _e_8532;
    logic _e_8534;
    logic _e_8536;
    logic _e_8537;
    (* src = "src/tta.spade:209,65" *)
    logic[4:0] _e_3151;
    (* src = "src/tta.spade:209,51" *)
    logic[42:0] _e_3150;
    (* src = "src/tta.spade:209,46" *)
    logic[43:0] _e_3149;
    (* src = "src/tta.spade:210,9" *)
    logic[43:0] _e_3156;
    (* src = "src/tta.spade:210,9" *)
    logic[10:0] _e_3153;
    (* src = "src/tta.spade:210,9" *)
    logic[32:0] _e_3155;
    (* src = "src/tta.spade:210,34" *)
    logic[31:0] x_n11;
    logic _e_8540;
    logic _e_8542;
    logic _e_8544;
    logic _e_8545;
    (* src = "src/tta.spade:210,65" *)
    logic[4:0] _e_3159;
    (* src = "src/tta.spade:210,51" *)
    logic[42:0] _e_3158;
    (* src = "src/tta.spade:210,46" *)
    logic[43:0] _e_3157;
    (* src = "src/tta.spade:211,9" *)
    logic[43:0] _e_3164;
    (* src = "src/tta.spade:211,9" *)
    logic[10:0] _e_3161;
    (* src = "src/tta.spade:211,9" *)
    logic[32:0] _e_3163;
    (* src = "src/tta.spade:211,33" *)
    logic[31:0] x_n12;
    logic _e_8548;
    logic _e_8550;
    logic _e_8552;
    logic _e_8553;
    (* src = "src/tta.spade:211,64" *)
    logic[4:0] _e_3167;
    (* src = "src/tta.spade:211,50" *)
    logic[42:0] _e_3166;
    (* src = "src/tta.spade:211,45" *)
    logic[43:0] _e_3165;
    (* src = "src/tta.spade:212,9" *)
    logic[43:0] _e_3172;
    (* src = "src/tta.spade:212,9" *)
    logic[10:0] _e_3169;
    (* src = "src/tta.spade:212,9" *)
    logic[32:0] _e_3171;
    (* src = "src/tta.spade:212,33" *)
    logic[31:0] x_n13;
    logic _e_8556;
    logic _e_8558;
    logic _e_8560;
    logic _e_8561;
    (* src = "src/tta.spade:212,64" *)
    logic[4:0] _e_3175;
    (* src = "src/tta.spade:212,50" *)
    logic[42:0] _e_3174;
    (* src = "src/tta.spade:212,45" *)
    logic[43:0] _e_3173;
    (* src = "src/tta.spade:213,9" *)
    logic[43:0] _e_3180;
    (* src = "src/tta.spade:213,9" *)
    logic[10:0] _e_3177;
    (* src = "src/tta.spade:213,9" *)
    logic[32:0] _e_3179;
    (* src = "src/tta.spade:213,35" *)
    logic[31:0] x_n14;
    logic _e_8564;
    logic _e_8566;
    logic _e_8568;
    logic _e_8569;
    (* src = "src/tta.spade:213,66" *)
    logic[4:0] _e_3183;
    (* src = "src/tta.spade:213,52" *)
    logic[42:0] _e_3182;
    (* src = "src/tta.spade:213,47" *)
    logic[43:0] _e_3181;
    (* src = "src/tta.spade:214,9" *)
    logic[43:0] _e_3188;
    (* src = "src/tta.spade:214,9" *)
    logic[10:0] _e_3185;
    (* src = "src/tta.spade:214,9" *)
    logic[32:0] _e_3187;
    (* src = "src/tta.spade:214,35" *)
    logic[31:0] x_n15;
    logic _e_8572;
    logic _e_8574;
    logic _e_8576;
    logic _e_8577;
    (* src = "src/tta.spade:214,66" *)
    logic[4:0] _e_3191;
    (* src = "src/tta.spade:214,52" *)
    logic[42:0] _e_3190;
    (* src = "src/tta.spade:214,47" *)
    logic[43:0] _e_3189;
    (* src = "src/tta.spade:215,9" *)
    logic[43:0] _e_3196;
    (* src = "src/tta.spade:215,9" *)
    logic[10:0] _e_3193;
    (* src = "src/tta.spade:215,9" *)
    logic[32:0] _e_3195;
    (* src = "src/tta.spade:215,35" *)
    logic[31:0] x_n16;
    logic _e_8580;
    logic _e_8582;
    logic _e_8584;
    logic _e_8585;
    (* src = "src/tta.spade:215,66" *)
    logic[4:0] _e_3199;
    (* src = "src/tta.spade:215,52" *)
    logic[42:0] _e_3198;
    (* src = "src/tta.spade:215,47" *)
    logic[43:0] _e_3197;
    (* src = "src/tta.spade:216,9" *)
    logic[43:0] _e_3204;
    (* src = "src/tta.spade:216,9" *)
    logic[10:0] _e_3201;
    (* src = "src/tta.spade:216,9" *)
    logic[32:0] _e_3203;
    (* src = "src/tta.spade:216,35" *)
    logic[31:0] x_n17;
    logic _e_8588;
    logic _e_8590;
    logic _e_8592;
    logic _e_8593;
    (* src = "src/tta.spade:216,66" *)
    logic[4:0] _e_3207;
    (* src = "src/tta.spade:216,52" *)
    logic[42:0] _e_3206;
    (* src = "src/tta.spade:216,47" *)
    logic[43:0] _e_3205;
    (* src = "src/tta.spade:218,9" *)
    logic[43:0] _e_3212;
    (* src = "src/tta.spade:218,9" *)
    logic[10:0] _e_3209;
    (* src = "src/tta.spade:218,9" *)
    logic[32:0] _e_3211;
    (* src = "src/tta.spade:218,33" *)
    logic[31:0] x_n18;
    logic _e_8596;
    logic _e_8598;
    logic _e_8600;
    logic _e_8601;
    (* src = "src/tta.spade:218,64" *)
    logic[2:0] _e_3215;
    (* src = "src/tta.spade:218,50" *)
    logic[42:0] _e_3214;
    (* src = "src/tta.spade:218,45" *)
    logic[43:0] _e_3213;
    (* src = "src/tta.spade:219,9" *)
    logic[43:0] _e_3220;
    (* src = "src/tta.spade:219,9" *)
    logic[10:0] _e_3217;
    (* src = "src/tta.spade:219,9" *)
    logic[32:0] _e_3219;
    (* src = "src/tta.spade:219,33" *)
    logic[31:0] x_n19;
    logic _e_8604;
    logic _e_8606;
    logic _e_8608;
    logic _e_8609;
    (* src = "src/tta.spade:219,64" *)
    logic[2:0] _e_3223;
    (* src = "src/tta.spade:219,50" *)
    logic[42:0] _e_3222;
    (* src = "src/tta.spade:219,45" *)
    logic[43:0] _e_3221;
    (* src = "src/tta.spade:220,9" *)
    logic[43:0] _e_3228;
    (* src = "src/tta.spade:220,9" *)
    logic[10:0] _e_3225;
    (* src = "src/tta.spade:220,9" *)
    logic[32:0] _e_3227;
    (* src = "src/tta.spade:220,36" *)
    logic[31:0] x_n20;
    logic _e_8612;
    logic _e_8614;
    logic _e_8616;
    logic _e_8617;
    (* src = "src/tta.spade:220,67" *)
    logic[2:0] _e_3231;
    (* src = "src/tta.spade:220,53" *)
    logic[42:0] _e_3230;
    (* src = "src/tta.spade:220,48" *)
    logic[43:0] _e_3229;
    (* src = "src/tta.spade:221,9" *)
    logic[43:0] _e_3236;
    (* src = "src/tta.spade:221,9" *)
    logic[10:0] _e_3233;
    (* src = "src/tta.spade:221,9" *)
    logic[32:0] _e_3235;
    (* src = "src/tta.spade:221,34" *)
    logic[31:0] x_n21;
    logic _e_8620;
    logic _e_8622;
    logic _e_8624;
    logic _e_8625;
    (* src = "src/tta.spade:221,65" *)
    logic[2:0] _e_3239;
    (* src = "src/tta.spade:221,51" *)
    logic[42:0] _e_3238;
    (* src = "src/tta.spade:221,46" *)
    logic[43:0] _e_3237;
    (* src = "src/tta.spade:222,9" *)
    logic[43:0] _e_3244;
    (* src = "src/tta.spade:222,9" *)
    logic[10:0] _e_3241;
    (* src = "src/tta.spade:222,9" *)
    logic[32:0] _e_3243;
    (* src = "src/tta.spade:222,34" *)
    logic[31:0] x_n22;
    logic _e_8628;
    logic _e_8630;
    logic _e_8632;
    logic _e_8633;
    (* src = "src/tta.spade:222,65" *)
    logic[2:0] _e_3247;
    (* src = "src/tta.spade:222,51" *)
    logic[42:0] _e_3246;
    (* src = "src/tta.spade:222,46" *)
    logic[43:0] _e_3245;
    (* src = "src/tta.spade:223,9" *)
    logic[43:0] _e_3252;
    (* src = "src/tta.spade:223,9" *)
    logic[10:0] _e_3249;
    (* src = "src/tta.spade:223,9" *)
    logic[32:0] _e_3251;
    (* src = "src/tta.spade:223,34" *)
    logic[31:0] x_n23;
    logic _e_8636;
    logic _e_8638;
    logic _e_8640;
    logic _e_8641;
    (* src = "src/tta.spade:223,65" *)
    logic[2:0] _e_3255;
    (* src = "src/tta.spade:223,51" *)
    logic[42:0] _e_3254;
    (* src = "src/tta.spade:223,46" *)
    logic[43:0] _e_3253;
    (* src = "src/tta.spade:224,9" *)
    logic[43:0] _e_3260;
    (* src = "src/tta.spade:224,9" *)
    logic[10:0] _e_3257;
    (* src = "src/tta.spade:224,9" *)
    logic[32:0] _e_3259;
    (* src = "src/tta.spade:224,34" *)
    logic[31:0] x_n24;
    logic _e_8644;
    logic _e_8646;
    logic _e_8648;
    logic _e_8649;
    (* src = "src/tta.spade:224,65" *)
    logic[2:0] _e_3263;
    (* src = "src/tta.spade:224,51" *)
    logic[42:0] _e_3262;
    (* src = "src/tta.spade:224,46" *)
    logic[43:0] _e_3261;
    (* src = "src/tta.spade:225,9" *)
    logic[43:0] _e_3268;
    (* src = "src/tta.spade:225,9" *)
    logic[10:0] _e_3265;
    (* src = "src/tta.spade:225,9" *)
    logic[32:0] _e_3267;
    (* src = "src/tta.spade:225,34" *)
    logic[31:0] x_n25;
    logic _e_8652;
    logic _e_8654;
    logic _e_8656;
    logic _e_8657;
    (* src = "src/tta.spade:225,65" *)
    logic[2:0] _e_3271;
    (* src = "src/tta.spade:225,51" *)
    logic[42:0] _e_3270;
    (* src = "src/tta.spade:225,46" *)
    logic[43:0] _e_3269;
    (* src = "src/tta.spade:227,9" *)
    logic[43:0] _e_3276;
    (* src = "src/tta.spade:227,9" *)
    logic[10:0] _e_3273;
    (* src = "src/tta.spade:227,9" *)
    logic[32:0] _e_3275;
    (* src = "src/tta.spade:227,33" *)
    logic[31:0] x_n26;
    logic _e_8660;
    logic _e_8662;
    logic _e_8664;
    logic _e_8665;
    (* src = "src/tta.spade:227,50" *)
    logic[42:0] _e_3278;
    (* src = "src/tta.spade:227,45" *)
    logic[43:0] _e_3277;
    (* src = "src/tta.spade:228,9" *)
    logic[43:0] _e_3283;
    (* src = "src/tta.spade:228,9" *)
    logic[10:0] _e_3280;
    (* src = "src/tta.spade:228,9" *)
    logic[32:0] _e_3282;
    (* src = "src/tta.spade:228,33" *)
    logic[31:0] x_n27;
    logic _e_8668;
    logic _e_8670;
    logic _e_8672;
    logic _e_8673;
    (* src = "src/tta.spade:228,65" *)
    logic _e_3286;
    (* src = "src/tta.spade:228,50" *)
    logic[42:0] _e_3285;
    (* src = "src/tta.spade:228,45" *)
    logic[43:0] _e_3284;
    (* src = "src/tta.spade:229,9" *)
    logic[43:0] _e_3291;
    (* src = "src/tta.spade:229,9" *)
    logic[10:0] _e_3288;
    (* src = "src/tta.spade:229,9" *)
    logic[32:0] _e_3290;
    (* src = "src/tta.spade:229,33" *)
    logic[31:0] x_n28;
    logic _e_8676;
    logic _e_8678;
    logic _e_8680;
    logic _e_8681;
    (* src = "src/tta.spade:229,65" *)
    logic _e_3294;
    (* src = "src/tta.spade:229,50" *)
    logic[42:0] _e_3293;
    (* src = "src/tta.spade:229,45" *)
    logic[43:0] _e_3292;
    (* src = "src/tta.spade:231,9" *)
    logic[43:0] _e_3299;
    (* src = "src/tta.spade:231,9" *)
    logic[10:0] _e_3296;
    (* src = "src/tta.spade:231,9" *)
    logic[32:0] _e_3298;
    (* src = "src/tta.spade:231,32" *)
    logic[31:0] x_n29;
    logic _e_8684;
    logic _e_8686;
    logic _e_8688;
    logic _e_8689;
    (* src = "src/tta.spade:231,62" *)
    logic[9:0] _e_3302;
    (* src = "src/tta.spade:231,49" *)
    logic[42:0] _e_3301;
    (* src = "src/tta.spade:231,44" *)
    logic[43:0] _e_3300;
    (* src = "src/tta.spade:233,9" *)
    logic[43:0] _e_3307;
    (* src = "src/tta.spade:233,9" *)
    logic[10:0] _e_3304;
    (* src = "src/tta.spade:233,9" *)
    logic[32:0] _e_3306;
    (* src = "src/tta.spade:233,32" *)
    logic[31:0] x_n30;
    logic _e_8692;
    logic _e_8694;
    logic _e_8696;
    logic _e_8697;
    (* src = "src/tta.spade:233,64" *)
    logic[9:0] _e_3310;
    (* src = "src/tta.spade:233,49" *)
    logic[42:0] _e_3309;
    (* src = "src/tta.spade:233,44" *)
    logic[43:0] _e_3308;
    (* src = "src/tta.spade:234,9" *)
    logic[43:0] _e_3315;
    (* src = "src/tta.spade:234,9" *)
    logic[10:0] _e_3312;
    (* src = "src/tta.spade:234,9" *)
    logic[32:0] _e_3314;
    (* src = "src/tta.spade:234,32" *)
    logic[31:0] x_n31;
    logic _e_8700;
    logic _e_8702;
    logic _e_8704;
    logic _e_8705;
    (* src = "src/tta.spade:234,49" *)
    logic[42:0] _e_3317;
    (* src = "src/tta.spade:234,44" *)
    logic[43:0] _e_3316;
    (* src = "src/tta.spade:236,9" *)
    logic[43:0] _e_3322;
    (* src = "src/tta.spade:236,9" *)
    logic[10:0] _e_3319;
    (* src = "src/tta.spade:236,9" *)
    logic[32:0] _e_3321;
    (* src = "src/tta.spade:236,32" *)
    logic[31:0] x_n32;
    logic _e_8708;
    logic _e_8710;
    logic _e_8712;
    logic _e_8713;
    (* src = "src/tta.spade:236,49" *)
    logic[42:0] _e_3324;
    (* src = "src/tta.spade:236,44" *)
    logic[43:0] _e_3323;
    (* src = "src/tta.spade:237,9" *)
    logic[43:0] _e_3329;
    (* src = "src/tta.spade:237,9" *)
    logic[10:0] _e_3326;
    (* src = "src/tta.spade:237,9" *)
    logic[32:0] _e_3328;
    (* src = "src/tta.spade:237,32" *)
    logic[31:0] x_n33;
    logic _e_8716;
    logic _e_8718;
    logic _e_8720;
    logic _e_8721;
    (* src = "src/tta.spade:237,49" *)
    logic[42:0] _e_3331;
    (* src = "src/tta.spade:237,44" *)
    logic[43:0] _e_3330;
    (* src = "src/tta.spade:238,9" *)
    logic[43:0] _e_3336;
    (* src = "src/tta.spade:238,9" *)
    logic[10:0] _e_3333;
    (* src = "src/tta.spade:238,9" *)
    logic[32:0] _e_3335;
    (* src = "src/tta.spade:238,32" *)
    logic[31:0] x_n34;
    logic _e_8724;
    logic _e_8726;
    logic _e_8728;
    logic _e_8729;
    (* src = "src/tta.spade:238,49" *)
    logic[42:0] _e_3338;
    (* src = "src/tta.spade:238,44" *)
    logic[43:0] _e_3337;
    (* src = "src/tta.spade:240,9" *)
    logic[43:0] _e_3343;
    (* src = "src/tta.spade:240,9" *)
    logic[10:0] _e_3340;
    (* src = "src/tta.spade:240,9" *)
    logic[32:0] _e_3342;
    (* src = "src/tta.spade:240,33" *)
    logic[31:0] x_n35;
    logic _e_8732;
    logic _e_8734;
    logic _e_8736;
    logic _e_8737;
    (* src = "src/tta.spade:240,50" *)
    logic[42:0] _e_3345;
    (* src = "src/tta.spade:240,45" *)
    logic[43:0] _e_3344;
    (* src = "src/tta.spade:241,9" *)
    logic[43:0] _e_3350;
    (* src = "src/tta.spade:241,9" *)
    logic[10:0] _e_3347;
    (* src = "src/tta.spade:241,9" *)
    logic[32:0] _e_3349;
    (* src = "src/tta.spade:241,33" *)
    logic[31:0] x_n36;
    logic _e_8740;
    logic _e_8742;
    logic _e_8744;
    logic _e_8745;
    (* src = "src/tta.spade:241,50" *)
    logic[42:0] _e_3352;
    (* src = "src/tta.spade:241,45" *)
    logic[43:0] _e_3351;
    (* src = "src/tta.spade:242,9" *)
    logic[43:0] _e_3357;
    (* src = "src/tta.spade:242,9" *)
    logic[10:0] _e_3354;
    (* src = "src/tta.spade:242,9" *)
    logic[32:0] _e_3356;
    (* src = "src/tta.spade:242,33" *)
    logic[31:0] x_n37;
    logic _e_8748;
    logic _e_8750;
    logic _e_8752;
    logic _e_8753;
    (* src = "src/tta.spade:242,50" *)
    logic[42:0] _e_3359;
    (* src = "src/tta.spade:242,45" *)
    logic[43:0] _e_3358;
    (* src = "src/tta.spade:244,9" *)
    logic[43:0] _e_3364;
    (* src = "src/tta.spade:244,9" *)
    logic[10:0] _e_3361;
    (* src = "src/tta.spade:244,9" *)
    logic[32:0] _e_3363;
    (* src = "src/tta.spade:244,32" *)
    logic[31:0] x_n38;
    logic _e_8756;
    logic _e_8758;
    logic _e_8760;
    logic _e_8761;
    (* src = "src/tta.spade:244,62" *)
    logic[15:0] _e_3367;
    (* src = "src/tta.spade:244,49" *)
    logic[42:0] _e_3366;
    (* src = "src/tta.spade:244,44" *)
    logic[43:0] _e_3365;
    (* src = "src/tta.spade:246,9" *)
    logic[43:0] _e_3372;
    (* src = "src/tta.spade:246,9" *)
    logic[10:0] _e_3369;
    (* src = "src/tta.spade:246,9" *)
    logic[32:0] _e_3371;
    (* src = "src/tta.spade:246,32" *)
    logic[31:0] x_n39;
    logic _e_8764;
    logic _e_8766;
    logic _e_8768;
    logic _e_8769;
    (* src = "src/tta.spade:246,49" *)
    logic[42:0] _e_3374;
    (* src = "src/tta.spade:246,44" *)
    logic[43:0] _e_3373;
    (* src = "src/tta.spade:247,9" *)
    logic[43:0] _e_3379;
    (* src = "src/tta.spade:247,9" *)
    logic[10:0] _e_3376;
    (* src = "src/tta.spade:247,9" *)
    logic[32:0] _e_3378;
    (* src = "src/tta.spade:247,32" *)
    logic[31:0] x_n40;
    logic _e_8772;
    logic _e_8774;
    logic _e_8776;
    logic _e_8777;
    (* src = "src/tta.spade:247,63" *)
    logic[2:0] _e_3382;
    (* src = "src/tta.spade:247,49" *)
    logic[42:0] _e_3381;
    (* src = "src/tta.spade:247,44" *)
    logic[43:0] _e_3380;
    (* src = "src/tta.spade:248,9" *)
    logic[43:0] _e_3387;
    (* src = "src/tta.spade:248,9" *)
    logic[10:0] _e_3384;
    (* src = "src/tta.spade:248,9" *)
    logic[32:0] _e_3386;
    (* src = "src/tta.spade:248,32" *)
    logic[31:0] x_n41;
    logic _e_8780;
    logic _e_8782;
    logic _e_8784;
    logic _e_8785;
    (* src = "src/tta.spade:248,63" *)
    logic[2:0] _e_3390;
    (* src = "src/tta.spade:248,49" *)
    logic[42:0] _e_3389;
    (* src = "src/tta.spade:248,44" *)
    logic[43:0] _e_3388;
    (* src = "src/tta.spade:249,9" *)
    logic[43:0] _e_3395;
    (* src = "src/tta.spade:249,9" *)
    logic[10:0] _e_3392;
    (* src = "src/tta.spade:249,9" *)
    logic[32:0] _e_3394;
    (* src = "src/tta.spade:249,32" *)
    logic[31:0] x_n42;
    logic _e_8788;
    logic _e_8790;
    logic _e_8792;
    logic _e_8793;
    (* src = "src/tta.spade:249,63" *)
    logic[2:0] _e_3398;
    (* src = "src/tta.spade:249,49" *)
    logic[42:0] _e_3397;
    (* src = "src/tta.spade:249,44" *)
    logic[43:0] _e_3396;
    (* src = "src/tta.spade:250,9" *)
    logic[43:0] _e_3403;
    (* src = "src/tta.spade:250,9" *)
    logic[10:0] _e_3400;
    (* src = "src/tta.spade:250,9" *)
    logic[32:0] _e_3402;
    (* src = "src/tta.spade:250,32" *)
    logic[31:0] x_n43;
    logic _e_8796;
    logic _e_8798;
    logic _e_8800;
    logic _e_8801;
    (* src = "src/tta.spade:250,63" *)
    logic[2:0] _e_3406;
    (* src = "src/tta.spade:250,49" *)
    logic[42:0] _e_3405;
    (* src = "src/tta.spade:250,44" *)
    logic[43:0] _e_3404;
    (* src = "src/tta.spade:251,9" *)
    logic[43:0] _e_3411;
    (* src = "src/tta.spade:251,9" *)
    logic[10:0] _e_3408;
    (* src = "src/tta.spade:251,9" *)
    logic[32:0] _e_3410;
    (* src = "src/tta.spade:251,32" *)
    logic[31:0] x_n44;
    logic _e_8804;
    logic _e_8806;
    logic _e_8808;
    logic _e_8809;
    (* src = "src/tta.spade:251,63" *)
    logic[2:0] _e_3414;
    (* src = "src/tta.spade:251,49" *)
    logic[42:0] _e_3413;
    (* src = "src/tta.spade:251,44" *)
    logic[43:0] _e_3412;
    (* src = "src/tta.spade:252,9" *)
    logic[43:0] _e_3419;
    (* src = "src/tta.spade:252,9" *)
    logic[10:0] _e_3416;
    (* src = "src/tta.spade:252,9" *)
    logic[32:0] _e_3418;
    (* src = "src/tta.spade:252,32" *)
    logic[31:0] x_n45;
    logic _e_8812;
    logic _e_8814;
    logic _e_8816;
    logic _e_8817;
    (* src = "src/tta.spade:252,63" *)
    logic[2:0] _e_3422;
    (* src = "src/tta.spade:252,49" *)
    logic[42:0] _e_3421;
    (* src = "src/tta.spade:252,44" *)
    logic[43:0] _e_3420;
    (* src = "src/tta.spade:254,9" *)
    logic[43:0] _e_3427;
    (* src = "src/tta.spade:254,9" *)
    logic[10:0] _e_3424;
    (* src = "src/tta.spade:254,9" *)
    logic[32:0] _e_3426;
    (* src = "src/tta.spade:254,34" *)
    logic[31:0] x_n46;
    logic _e_8820;
    logic _e_8822;
    logic _e_8824;
    logic _e_8825;
    (* src = "src/tta.spade:254,66" *)
    logic[2:0] _e_3430;
    (* src = "src/tta.spade:254,51" *)
    logic[42:0] _e_3429;
    (* src = "src/tta.spade:254,46" *)
    logic[43:0] _e_3428;
    (* src = "src/tta.spade:255,9" *)
    logic[43:0] _e_3435;
    (* src = "src/tta.spade:255,9" *)
    logic[10:0] _e_3432;
    (* src = "src/tta.spade:255,9" *)
    logic[32:0] _e_3434;
    (* src = "src/tta.spade:255,34" *)
    logic[31:0] x_n47;
    logic _e_8828;
    logic _e_8830;
    logic _e_8832;
    logic _e_8833;
    (* src = "src/tta.spade:255,66" *)
    logic[2:0] _e_3438;
    (* src = "src/tta.spade:255,51" *)
    logic[42:0] _e_3437;
    (* src = "src/tta.spade:255,46" *)
    logic[43:0] _e_3436;
    (* src = "src/tta.spade:256,9" *)
    logic[43:0] _e_3443;
    (* src = "src/tta.spade:256,9" *)
    logic[10:0] _e_3440;
    (* src = "src/tta.spade:256,9" *)
    logic[32:0] _e_3442;
    (* src = "src/tta.spade:256,34" *)
    logic[31:0] x_n48;
    logic _e_8836;
    logic _e_8838;
    logic _e_8840;
    logic _e_8841;
    (* src = "src/tta.spade:256,66" *)
    logic[2:0] _e_3446;
    (* src = "src/tta.spade:256,51" *)
    logic[42:0] _e_3445;
    (* src = "src/tta.spade:256,46" *)
    logic[43:0] _e_3444;
    (* src = "src/tta.spade:257,9" *)
    logic[43:0] _e_3451;
    (* src = "src/tta.spade:257,9" *)
    logic[10:0] _e_3448;
    (* src = "src/tta.spade:257,9" *)
    logic[32:0] _e_3450;
    (* src = "src/tta.spade:257,34" *)
    logic[31:0] x_n49;
    logic _e_8844;
    logic _e_8846;
    logic _e_8848;
    logic _e_8849;
    (* src = "src/tta.spade:257,66" *)
    logic[2:0] _e_3454;
    (* src = "src/tta.spade:257,51" *)
    logic[42:0] _e_3453;
    (* src = "src/tta.spade:257,46" *)
    logic[43:0] _e_3452;
    (* src = "src/tta.spade:258,9" *)
    logic[43:0] _e_3459;
    (* src = "src/tta.spade:258,9" *)
    logic[10:0] _e_3456;
    (* src = "src/tta.spade:258,9" *)
    logic[32:0] _e_3458;
    (* src = "src/tta.spade:258,34" *)
    logic[31:0] x_n50;
    logic _e_8852;
    logic _e_8854;
    logic _e_8856;
    logic _e_8857;
    (* src = "src/tta.spade:258,66" *)
    logic[2:0] _e_3462;
    (* src = "src/tta.spade:258,51" *)
    logic[42:0] _e_3461;
    (* src = "src/tta.spade:258,46" *)
    logic[43:0] _e_3460;
    (* src = "src/tta.spade:259,9" *)
    logic[43:0] _e_3467;
    (* src = "src/tta.spade:259,9" *)
    logic[10:0] _e_3464;
    (* src = "src/tta.spade:259,9" *)
    logic[32:0] _e_3466;
    (* src = "src/tta.spade:259,35" *)
    logic[31:0] x_n51;
    logic _e_8860;
    logic _e_8862;
    logic _e_8864;
    logic _e_8865;
    (* src = "src/tta.spade:259,67" *)
    logic[2:0] _e_3470;
    (* src = "src/tta.spade:259,52" *)
    logic[42:0] _e_3469;
    (* src = "src/tta.spade:259,47" *)
    logic[43:0] _e_3468;
    (* src = "src/tta.spade:261,9" *)
    logic[43:0] _e_3475;
    (* src = "src/tta.spade:261,9" *)
    logic[10:0] _e_3472;
    (* src = "src/tta.spade:261,9" *)
    logic[32:0] _e_3474;
    (* src = "src/tta.spade:261,32" *)
    logic[31:0] x_n52;
    logic _e_8868;
    logic _e_8870;
    logic _e_8872;
    logic _e_8873;
    (* src = "src/tta.spade:261,49" *)
    logic[42:0] _e_3477;
    (* src = "src/tta.spade:261,44" *)
    logic[43:0] _e_3476;
    (* src = "src/tta.spade:262,9" *)
    logic[43:0] _e_3482;
    (* src = "src/tta.spade:262,9" *)
    logic[10:0] _e_3479;
    (* src = "src/tta.spade:262,9" *)
    logic[32:0] _e_3481;
    (* src = "src/tta.spade:262,32" *)
    logic[31:0] x_n53;
    logic _e_8876;
    logic _e_8878;
    logic _e_8880;
    logic _e_8881;
    (* src = "src/tta.spade:262,49" *)
    logic[42:0] _e_3484;
    (* src = "src/tta.spade:262,44" *)
    logic[43:0] _e_3483;
    (* src = "src/tta.spade:264,9" *)
    logic[43:0] _e_3489;
    (* src = "src/tta.spade:264,9" *)
    logic[10:0] _e_3486;
    (* src = "src/tta.spade:264,9" *)
    logic[32:0] _e_3488;
    (* src = "src/tta.spade:264,32" *)
    logic[31:0] x_n54;
    logic _e_8884;
    logic _e_8886;
    logic _e_8888;
    logic _e_8889;
    (* src = "src/tta.spade:264,49" *)
    logic[42:0] _e_3491;
    (* src = "src/tta.spade:264,44" *)
    logic[43:0] _e_3490;
    (* src = "src/tta.spade:265,9" *)
    logic[43:0] _e_3496;
    (* src = "src/tta.spade:265,9" *)
    logic[10:0] _e_3493;
    (* src = "src/tta.spade:265,9" *)
    logic[32:0] _e_3495;
    (* src = "src/tta.spade:265,32" *)
    logic[31:0] x_n55;
    logic _e_8892;
    logic _e_8894;
    logic _e_8896;
    logic _e_8897;
    (* src = "src/tta.spade:265,49" *)
    logic[42:0] _e_3498;
    (* src = "src/tta.spade:265,44" *)
    logic[43:0] _e_3497;
    (* src = "src/tta.spade:267,9" *)
    logic[43:0] _e_3503;
    (* src = "src/tta.spade:267,9" *)
    logic[10:0] _e_3500;
    (* src = "src/tta.spade:267,9" *)
    logic[32:0] _e_3502;
    (* src = "src/tta.spade:267,37" *)
    logic[31:0] x_n56;
    logic _e_8900;
    logic _e_8902;
    logic _e_8904;
    logic _e_8905;
    (* src = "src/tta.spade:267,54" *)
    logic[42:0] _e_3505;
    (* src = "src/tta.spade:267,49" *)
    logic[43:0] _e_3504;
    (* src = "src/tta.spade:269,9" *)
    logic[43:0] _e_3510;
    (* src = "src/tta.spade:269,9" *)
    logic[10:0] _e_3507;
    (* src = "src/tta.spade:269,9" *)
    logic[32:0] _e_3509;
    (* src = "src/tta.spade:269,27" *)
    logic[31:0] x_n57;
    logic _e_8908;
    logic _e_8910;
    logic _e_8912;
    logic _e_8913;
    (* src = "src/tta.spade:269,44" *)
    logic[42:0] _e_3512;
    (* src = "src/tta.spade:269,39" *)
    logic[43:0] _e_3511;
    (* src = "src/tta.spade:270,9" *)
    logic[43:0] _e_3517;
    (* src = "src/tta.spade:270,9" *)
    logic[10:0] _e_3514;
    (* src = "src/tta.spade:270,9" *)
    logic[32:0] _e_3516;
    (* src = "src/tta.spade:270,27" *)
    logic[31:0] x_n58;
    logic _e_8916;
    logic _e_8918;
    logic _e_8920;
    logic _e_8921;
    (* src = "src/tta.spade:270,44" *)
    logic[42:0] _e_3519;
    (* src = "src/tta.spade:270,39" *)
    logic[43:0] _e_3518;
    (* src = "src/tta.spade:271,9" *)
    logic[43:0] _e_3524;
    (* src = "src/tta.spade:271,9" *)
    logic[10:0] _e_3521;
    (* src = "src/tta.spade:271,9" *)
    logic[32:0] _e_3523;
    (* src = "src/tta.spade:271,27" *)
    logic[31:0] x_n59;
    logic _e_8924;
    logic _e_8926;
    logic _e_8928;
    logic _e_8929;
    (* src = "src/tta.spade:271,59" *)
    logic _e_3527;
    (* src = "src/tta.spade:271,44" *)
    logic[42:0] _e_3526;
    (* src = "src/tta.spade:271,39" *)
    logic[43:0] _e_3525;
    (* src = "src/tta.spade:273,9" *)
    logic[43:0] _e_3533;
    (* src = "src/tta.spade:273,9" *)
    logic[10:0] _e_3530;
    (* src = "src/tta.spade:273,9" *)
    logic[32:0] _e_3532;
    (* src = "src/tta.spade:273,26" *)
    logic[31:0] x_n60;
    logic _e_8932;
    logic _e_8934;
    logic _e_8936;
    logic _e_8937;
    (* src = "src/tta.spade:273,57" *)
    logic _e_3536;
    (* src = "src/tta.spade:273,43" *)
    logic[42:0] _e_3535;
    (* src = "src/tta.spade:273,38" *)
    logic[43:0] _e_3534;
    (* src = "src/tta.spade:274,9" *)
    logic[43:0] _e_3542;
    (* src = "src/tta.spade:274,9" *)
    logic[10:0] _e_3539;
    (* src = "src/tta.spade:274,9" *)
    logic[32:0] _e_3541;
    (* src = "src/tta.spade:274,27" *)
    logic[31:0] x_n61;
    logic _e_8940;
    logic _e_8942;
    logic _e_8944;
    logic _e_8945;
    (* src = "src/tta.spade:274,44" *)
    logic[42:0] _e_3544;
    (* src = "src/tta.spade:274,39" *)
    logic[43:0] _e_3543;
    (* src = "src/tta.spade:275,9" *)
    logic[43:0] _e_3549;
    (* src = "src/tta.spade:275,9" *)
    logic[10:0] _e_3546;
    (* src = "src/tta.spade:275,9" *)
    logic[32:0] _e_3548;
    (* src = "src/tta.spade:275,27" *)
    logic[31:0] x_n62;
    logic _e_8948;
    logic _e_8950;
    logic _e_8952;
    logic _e_8953;
    (* src = "src/tta.spade:275,44" *)
    logic[42:0] _e_3551;
    (* src = "src/tta.spade:275,39" *)
    logic[43:0] _e_3550;
    (* src = "src/tta.spade:277,9" *)
    logic[43:0] _e_3556;
    (* src = "src/tta.spade:277,9" *)
    logic[10:0] _e_3553;
    (* src = "src/tta.spade:277,9" *)
    logic[32:0] _e_3555;
    (* src = "src/tta.spade:277,26" *)
    logic[31:0] x_n63;
    logic _e_8956;
    logic _e_8958;
    logic _e_8960;
    logic _e_8961;
    (* src = "src/tta.spade:277,43" *)
    logic[42:0] _e_3558;
    (* src = "src/tta.spade:277,38" *)
    logic[43:0] _e_3557;
    (* src = "src/tta.spade:278,9" *)
    logic[43:0] _e_3563;
    (* src = "src/tta.spade:278,9" *)
    logic[10:0] _e_3560;
    (* src = "src/tta.spade:278,9" *)
    logic[32:0] _e_3562;
    (* src = "src/tta.spade:278,26" *)
    logic[31:0] x_n64;
    logic _e_8964;
    logic _e_8966;
    logic _e_8968;
    logic _e_8969;
    (* src = "src/tta.spade:278,43" *)
    logic[42:0] _e_3565;
    (* src = "src/tta.spade:278,38" *)
    logic[43:0] _e_3564;
    (* src = "src/tta.spade:279,9" *)
    logic[43:0] _e_3570;
    (* src = "src/tta.spade:279,9" *)
    logic[10:0] _e_3567;
    (* src = "src/tta.spade:279,9" *)
    logic[32:0] _e_3569;
    (* src = "src/tta.spade:279,25" *)
    logic[31:0] x_n65;
    logic _e_8972;
    logic _e_8974;
    logic _e_8976;
    logic _e_8977;
    (* src = "src/tta.spade:279,42" *)
    logic[42:0] _e_3572;
    (* src = "src/tta.spade:279,37" *)
    logic[43:0] _e_3571;
    (* src = "src/tta.spade:280,9" *)
    logic[43:0] _e_3577;
    (* src = "src/tta.spade:280,9" *)
    logic[10:0] _e_3574;
    (* src = "src/tta.spade:280,9" *)
    logic[32:0] _e_3576;
    (* src = "src/tta.spade:280,26" *)
    logic[31:0] x_n66;
    logic _e_8980;
    logic _e_8982;
    logic _e_8984;
    logic _e_8985;
    (* src = "src/tta.spade:280,43" *)
    logic[42:0] _e_3579;
    (* src = "src/tta.spade:280,38" *)
    logic[43:0] _e_3578;
    (* src = "src/tta.spade:282,9" *)
    logic[43:0] _e_3584;
    (* src = "src/tta.spade:282,9" *)
    logic[10:0] _e_3581;
    (* src = "src/tta.spade:282,9" *)
    logic[32:0] _e_3583;
    (* src = "src/tta.spade:282,26" *)
    logic[31:0] x_n67;
    logic _e_8988;
    logic _e_8990;
    logic _e_8992;
    logic _e_8993;
    (* src = "src/tta.spade:282,43" *)
    logic[42:0] _e_3586;
    (* src = "src/tta.spade:282,38" *)
    logic[43:0] _e_3585;
    (* src = "src/tta.spade:284,9" *)
    logic[43:0] _e_3591;
    (* src = "src/tta.spade:284,9" *)
    logic[10:0] _e_3588;
    (* src = "src/tta.spade:284,9" *)
    logic[32:0] _e_3590;
    (* src = "src/tta.spade:284,28" *)
    logic[31:0] x_n68;
    logic _e_8996;
    logic _e_8998;
    logic _e_9000;
    logic _e_9001;
    (* src = "src/tta.spade:284,45" *)
    logic[42:0] _e_3593;
    (* src = "src/tta.spade:284,40" *)
    logic[43:0] _e_3592;
    (* src = "src/tta.spade:285,9" *)
    logic[43:0] _e_3598;
    (* src = "src/tta.spade:285,9" *)
    logic[10:0] _e_3595;
    (* src = "src/tta.spade:285,9" *)
    logic[32:0] _e_3597;
    (* src = "src/tta.spade:285,33" *)
    logic[31:0] x_n69;
    logic _e_9004;
    logic _e_9006;
    logic _e_9008;
    logic _e_9009;
    (* src = "src/tta.spade:285,50" *)
    logic[42:0] _e_3600;
    (* src = "src/tta.spade:285,45" *)
    logic[43:0] _e_3599;
    (* src = "src/tta.spade:286,9" *)
    logic[43:0] _e_3605;
    (* src = "src/tta.spade:286,9" *)
    logic[10:0] _e_3602;
    (* src = "src/tta.spade:286,9" *)
    logic[32:0] _e_3604;
    (* src = "src/tta.spade:286,32" *)
    logic[31:0] x_n70;
    logic _e_9012;
    logic _e_9014;
    logic _e_9016;
    logic _e_9017;
    (* src = "src/tta.spade:286,49" *)
    logic[42:0] _e_3607;
    (* src = "src/tta.spade:286,44" *)
    logic[43:0] _e_3606;
    (* src = "src/tta.spade:288,9" *)
    logic[43:0] _e_3611;
    (* src = "src/tta.spade:288,9" *)
    logic[10:0] _e_3608;
    (* src = "src/tta.spade:288,9" *)
    logic[32:0] _e_3610;
    (* src = "src/tta.spade:288,32" *)
    logic[31:0] x_n71;
    logic _e_9020;
    logic _e_9022;
    logic _e_9024;
    logic _e_9025;
    (* src = "src/tta.spade:288,63" *)
    logic[7:0] _e_3614;
    (* src = "src/tta.spade:288,49" *)
    logic[42:0] _e_3613;
    (* src = "src/tta.spade:288,44" *)
    logic[43:0] _e_3612;
    (* src = "src/tta.spade:289,9" *)
    logic[43:0] _e_3619;
    (* src = "src/tta.spade:289,9" *)
    logic[10:0] _e_3616;
    (* src = "src/tta.spade:289,9" *)
    logic[32:0] _e_3618;
    (* src = "src/tta.spade:289,32" *)
    logic[31:0] x_n72;
    logic _e_9028;
    logic _e_9030;
    logic _e_9032;
    logic _e_9033;
    (* src = "src/tta.spade:289,49" *)
    logic[42:0] _e_3621;
    (* src = "src/tta.spade:289,44" *)
    logic[43:0] _e_3620;
    (* src = "src/tta.spade:291,9" *)
    logic[43:0] _e_3625;
    (* src = "src/tta.spade:291,9" *)
    logic[10:0] _e_3622;
    (* src = "src/tta.spade:291,9" *)
    logic[32:0] _e_3624;
    (* src = "src/tta.spade:291,33" *)
    logic[31:0] x_n73;
    logic _e_9036;
    logic _e_9038;
    logic _e_9040;
    logic _e_9041;
    (* src = "src/tta.spade:291,65" *)
    logic[7:0] _e_3628;
    (* src = "src/tta.spade:291,50" *)
    logic[42:0] _e_3627;
    (* src = "src/tta.spade:291,45" *)
    logic[43:0] _e_3626;
    (* src = "src/tta.spade:292,9" *)
    logic[43:0] _e_3633;
    (* src = "src/tta.spade:292,9" *)
    logic[10:0] _e_3630;
    (* src = "src/tta.spade:292,9" *)
    logic[32:0] _e_3632;
    (* src = "src/tta.spade:292,33" *)
    logic[31:0] x_n74;
    logic _e_9044;
    logic _e_9046;
    logic _e_9048;
    logic _e_9049;
    (* src = "src/tta.spade:292,50" *)
    logic[42:0] _e_3635;
    (* src = "src/tta.spade:292,45" *)
    logic[43:0] _e_3634;
    (* src = "src/tta.spade:294,9" *)
    logic[43:0] \_ ;
    (* src = "src/tta.spade:294,14" *)
    logic[43:0] _e_3637;
    (* src = "src/tta.spade:197,5" *)
    logic[43:0] _e_3061;
    assign _e_3062 = {\dst , \v };
    assign _e_3069 = _e_3062;
    assign _e_3066 = _e_3062[43:33];
    assign \i  = _e_3066[3:0];
    assign _e_3068 = _e_3062[32:0];
    assign \x  = _e_3068[31:0];
    assign _e_8450 = _e_3066[10:4] == 7'd0;
    localparam[0:0] _e_8451 = 1;
    assign _e_8452 = _e_8450 && _e_8451;
    assign _e_8454 = _e_3068[32] == 1'd1;
    localparam[0:0] _e_8455 = 1;
    assign _e_8456 = _e_8454 && _e_8455;
    assign _e_8457 = _e_8452 && _e_8456;
    assign _e_3071 = {6'd0, \i , \x , 1'bX};
    assign _e_3070 = {1'd1, _e_3071};
    assign _e_3077 = _e_3062;
    assign _e_3074 = _e_3062[43:33];
    assign _e_3076 = _e_3062[32:0];
    assign x_n1 = _e_3076[31:0];
    assign _e_8460 = _e_3074[10:4] == 7'd1;
    assign _e_8462 = _e_3076[32] == 1'd1;
    localparam[0:0] _e_8463 = 1;
    assign _e_8464 = _e_8462 && _e_8463;
    assign _e_8465 = _e_8460 && _e_8464;
    assign _e_3079 = {6'd1, x_n1, 5'bX};
    assign _e_3078 = {1'd1, _e_3079};
    assign _e_3084 = _e_3062;
    assign _e_3081 = _e_3062[43:33];
    assign _e_3083 = _e_3062[32:0];
    assign x_n2 = _e_3083[31:0];
    assign _e_8468 = _e_3081[10:4] == 7'd2;
    assign _e_8470 = _e_3083[32] == 1'd1;
    localparam[0:0] _e_8471 = 1;
    assign _e_8472 = _e_8470 && _e_8471;
    assign _e_8473 = _e_8468 && _e_8472;
    assign _e_3087 = {5'd0};
    assign _e_3086 = {6'd2, _e_3087, x_n2};
    assign _e_3085 = {1'd1, _e_3086};
    assign _e_3092 = _e_3062;
    assign _e_3089 = _e_3062[43:33];
    assign _e_3091 = _e_3062[32:0];
    assign x_n3 = _e_3091[31:0];
    assign _e_8476 = _e_3089[10:4] == 7'd3;
    assign _e_8478 = _e_3091[32] == 1'd1;
    localparam[0:0] _e_8479 = 1;
    assign _e_8480 = _e_8478 && _e_8479;
    assign _e_8481 = _e_8476 && _e_8480;
    assign _e_3095 = {5'd1};
    assign _e_3094 = {6'd2, _e_3095, x_n3};
    assign _e_3093 = {1'd1, _e_3094};
    assign _e_3100 = _e_3062;
    assign _e_3097 = _e_3062[43:33];
    assign _e_3099 = _e_3062[32:0];
    assign x_n4 = _e_3099[31:0];
    assign _e_8484 = _e_3097[10:4] == 7'd4;
    assign _e_8486 = _e_3099[32] == 1'd1;
    localparam[0:0] _e_8487 = 1;
    assign _e_8488 = _e_8486 && _e_8487;
    assign _e_8489 = _e_8484 && _e_8488;
    assign _e_3103 = {5'd2};
    assign _e_3102 = {6'd2, _e_3103, x_n4};
    assign _e_3101 = {1'd1, _e_3102};
    assign _e_3108 = _e_3062;
    assign _e_3105 = _e_3062[43:33];
    assign _e_3107 = _e_3062[32:0];
    assign x_n5 = _e_3107[31:0];
    assign _e_8492 = _e_3105[10:4] == 7'd5;
    assign _e_8494 = _e_3107[32] == 1'd1;
    localparam[0:0] _e_8495 = 1;
    assign _e_8496 = _e_8494 && _e_8495;
    assign _e_8497 = _e_8492 && _e_8496;
    assign _e_3111 = {5'd3};
    assign _e_3110 = {6'd2, _e_3111, x_n5};
    assign _e_3109 = {1'd1, _e_3110};
    assign _e_3116 = _e_3062;
    assign _e_3113 = _e_3062[43:33];
    assign _e_3115 = _e_3062[32:0];
    assign x_n6 = _e_3115[31:0];
    assign _e_8500 = _e_3113[10:4] == 7'd6;
    assign _e_8502 = _e_3115[32] == 1'd1;
    localparam[0:0] _e_8503 = 1;
    assign _e_8504 = _e_8502 && _e_8503;
    assign _e_8505 = _e_8500 && _e_8504;
    assign _e_3119 = {5'd4};
    assign _e_3118 = {6'd2, _e_3119, x_n6};
    assign _e_3117 = {1'd1, _e_3118};
    assign _e_3124 = _e_3062;
    assign _e_3121 = _e_3062[43:33];
    assign _e_3123 = _e_3062[32:0];
    assign x_n7 = _e_3123[31:0];
    assign _e_8508 = _e_3121[10:4] == 7'd8;
    assign _e_8510 = _e_3123[32] == 1'd1;
    localparam[0:0] _e_8511 = 1;
    assign _e_8512 = _e_8510 && _e_8511;
    assign _e_8513 = _e_8508 && _e_8512;
    assign _e_3127 = {5'd6};
    assign _e_3126 = {6'd2, _e_3127, x_n7};
    assign _e_3125 = {1'd1, _e_3126};
    assign _e_3132 = _e_3062;
    assign _e_3129 = _e_3062[43:33];
    assign _e_3131 = _e_3062[32:0];
    assign x_n8 = _e_3131[31:0];
    assign _e_8516 = _e_3129[10:4] == 7'd9;
    assign _e_8518 = _e_3131[32] == 1'd1;
    localparam[0:0] _e_8519 = 1;
    assign _e_8520 = _e_8518 && _e_8519;
    assign _e_8521 = _e_8516 && _e_8520;
    assign _e_3135 = {5'd7};
    assign _e_3134 = {6'd2, _e_3135, x_n8};
    assign _e_3133 = {1'd1, _e_3134};
    assign _e_3140 = _e_3062;
    assign _e_3137 = _e_3062[43:33];
    assign _e_3139 = _e_3062[32:0];
    assign x_n9 = _e_3139[31:0];
    assign _e_8524 = _e_3137[10:4] == 7'd10;
    assign _e_8526 = _e_3139[32] == 1'd1;
    localparam[0:0] _e_8527 = 1;
    assign _e_8528 = _e_8526 && _e_8527;
    assign _e_8529 = _e_8524 && _e_8528;
    assign _e_3143 = {5'd8};
    assign _e_3142 = {6'd2, _e_3143, x_n9};
    assign _e_3141 = {1'd1, _e_3142};
    assign _e_3148 = _e_3062;
    assign _e_3145 = _e_3062[43:33];
    assign _e_3147 = _e_3062[32:0];
    assign x_n10 = _e_3147[31:0];
    assign _e_8532 = _e_3145[10:4] == 7'd11;
    assign _e_8534 = _e_3147[32] == 1'd1;
    localparam[0:0] _e_8535 = 1;
    assign _e_8536 = _e_8534 && _e_8535;
    assign _e_8537 = _e_8532 && _e_8536;
    assign _e_3151 = {5'd9};
    assign _e_3150 = {6'd2, _e_3151, x_n10};
    assign _e_3149 = {1'd1, _e_3150};
    assign _e_3156 = _e_3062;
    assign _e_3153 = _e_3062[43:33];
    assign _e_3155 = _e_3062[32:0];
    assign x_n11 = _e_3155[31:0];
    assign _e_8540 = _e_3153[10:4] == 7'd12;
    assign _e_8542 = _e_3155[32] == 1'd1;
    localparam[0:0] _e_8543 = 1;
    assign _e_8544 = _e_8542 && _e_8543;
    assign _e_8545 = _e_8540 && _e_8544;
    assign _e_3159 = {5'd10};
    assign _e_3158 = {6'd2, _e_3159, x_n11};
    assign _e_3157 = {1'd1, _e_3158};
    assign _e_3164 = _e_3062;
    assign _e_3161 = _e_3062[43:33];
    assign _e_3163 = _e_3062[32:0];
    assign x_n12 = _e_3163[31:0];
    assign _e_8548 = _e_3161[10:4] == 7'd13;
    assign _e_8550 = _e_3163[32] == 1'd1;
    localparam[0:0] _e_8551 = 1;
    assign _e_8552 = _e_8550 && _e_8551;
    assign _e_8553 = _e_8548 && _e_8552;
    assign _e_3167 = {5'd11};
    assign _e_3166 = {6'd2, _e_3167, x_n12};
    assign _e_3165 = {1'd1, _e_3166};
    assign _e_3172 = _e_3062;
    assign _e_3169 = _e_3062[43:33];
    assign _e_3171 = _e_3062[32:0];
    assign x_n13 = _e_3171[31:0];
    assign _e_8556 = _e_3169[10:4] == 7'd14;
    assign _e_8558 = _e_3171[32] == 1'd1;
    localparam[0:0] _e_8559 = 1;
    assign _e_8560 = _e_8558 && _e_8559;
    assign _e_8561 = _e_8556 && _e_8560;
    assign _e_3175 = {5'd12};
    assign _e_3174 = {6'd2, _e_3175, x_n13};
    assign _e_3173 = {1'd1, _e_3174};
    assign _e_3180 = _e_3062;
    assign _e_3177 = _e_3062[43:33];
    assign _e_3179 = _e_3062[32:0];
    assign x_n14 = _e_3179[31:0];
    assign _e_8564 = _e_3177[10:4] == 7'd15;
    assign _e_8566 = _e_3179[32] == 1'd1;
    localparam[0:0] _e_8567 = 1;
    assign _e_8568 = _e_8566 && _e_8567;
    assign _e_8569 = _e_8564 && _e_8568;
    assign _e_3183 = {5'd13};
    assign _e_3182 = {6'd2, _e_3183, x_n14};
    assign _e_3181 = {1'd1, _e_3182};
    assign _e_3188 = _e_3062;
    assign _e_3185 = _e_3062[43:33];
    assign _e_3187 = _e_3062[32:0];
    assign x_n15 = _e_3187[31:0];
    assign _e_8572 = _e_3185[10:4] == 7'd16;
    assign _e_8574 = _e_3187[32] == 1'd1;
    localparam[0:0] _e_8575 = 1;
    assign _e_8576 = _e_8574 && _e_8575;
    assign _e_8577 = _e_8572 && _e_8576;
    assign _e_3191 = {5'd14};
    assign _e_3190 = {6'd2, _e_3191, x_n15};
    assign _e_3189 = {1'd1, _e_3190};
    assign _e_3196 = _e_3062;
    assign _e_3193 = _e_3062[43:33];
    assign _e_3195 = _e_3062[32:0];
    assign x_n16 = _e_3195[31:0];
    assign _e_8580 = _e_3193[10:4] == 7'd17;
    assign _e_8582 = _e_3195[32] == 1'd1;
    localparam[0:0] _e_8583 = 1;
    assign _e_8584 = _e_8582 && _e_8583;
    assign _e_8585 = _e_8580 && _e_8584;
    assign _e_3199 = {5'd15};
    assign _e_3198 = {6'd2, _e_3199, x_n16};
    assign _e_3197 = {1'd1, _e_3198};
    assign _e_3204 = _e_3062;
    assign _e_3201 = _e_3062[43:33];
    assign _e_3203 = _e_3062[32:0];
    assign x_n17 = _e_3203[31:0];
    assign _e_8588 = _e_3201[10:4] == 7'd18;
    assign _e_8590 = _e_3203[32] == 1'd1;
    localparam[0:0] _e_8591 = 1;
    assign _e_8592 = _e_8590 && _e_8591;
    assign _e_8593 = _e_8588 && _e_8592;
    assign _e_3207 = {5'd16};
    assign _e_3206 = {6'd2, _e_3207, x_n17};
    assign _e_3205 = {1'd1, _e_3206};
    assign _e_3212 = _e_3062;
    assign _e_3209 = _e_3062[43:33];
    assign _e_3211 = _e_3062[32:0];
    assign x_n18 = _e_3211[31:0];
    assign _e_8596 = _e_3209[10:4] == 7'd19;
    assign _e_8598 = _e_3211[32] == 1'd1;
    localparam[0:0] _e_8599 = 1;
    assign _e_8600 = _e_8598 && _e_8599;
    assign _e_8601 = _e_8596 && _e_8600;
    assign _e_3215 = {3'd0};
    assign _e_3214 = {6'd40, _e_3215, x_n18, 2'bX};
    assign _e_3213 = {1'd1, _e_3214};
    assign _e_3220 = _e_3062;
    assign _e_3217 = _e_3062[43:33];
    assign _e_3219 = _e_3062[32:0];
    assign x_n19 = _e_3219[31:0];
    assign _e_8604 = _e_3217[10:4] == 7'd20;
    assign _e_8606 = _e_3219[32] == 1'd1;
    localparam[0:0] _e_8607 = 1;
    assign _e_8608 = _e_8606 && _e_8607;
    assign _e_8609 = _e_8604 && _e_8608;
    assign _e_3223 = {3'd1};
    assign _e_3222 = {6'd40, _e_3223, x_n19, 2'bX};
    assign _e_3221 = {1'd1, _e_3222};
    assign _e_3228 = _e_3062;
    assign _e_3225 = _e_3062[43:33];
    assign _e_3227 = _e_3062[32:0];
    assign x_n20 = _e_3227[31:0];
    assign _e_8612 = _e_3225[10:4] == 7'd21;
    assign _e_8614 = _e_3227[32] == 1'd1;
    localparam[0:0] _e_8615 = 1;
    assign _e_8616 = _e_8614 && _e_8615;
    assign _e_8617 = _e_8612 && _e_8616;
    assign _e_3231 = {3'd2};
    assign _e_3230 = {6'd40, _e_3231, x_n20, 2'bX};
    assign _e_3229 = {1'd1, _e_3230};
    assign _e_3236 = _e_3062;
    assign _e_3233 = _e_3062[43:33];
    assign _e_3235 = _e_3062[32:0];
    assign x_n21 = _e_3235[31:0];
    assign _e_8620 = _e_3233[10:4] == 7'd22;
    assign _e_8622 = _e_3235[32] == 1'd1;
    localparam[0:0] _e_8623 = 1;
    assign _e_8624 = _e_8622 && _e_8623;
    assign _e_8625 = _e_8620 && _e_8624;
    assign _e_3239 = {3'd3};
    assign _e_3238 = {6'd40, _e_3239, x_n21, 2'bX};
    assign _e_3237 = {1'd1, _e_3238};
    assign _e_3244 = _e_3062;
    assign _e_3241 = _e_3062[43:33];
    assign _e_3243 = _e_3062[32:0];
    assign x_n22 = _e_3243[31:0];
    assign _e_8628 = _e_3241[10:4] == 7'd23;
    assign _e_8630 = _e_3243[32] == 1'd1;
    localparam[0:0] _e_8631 = 1;
    assign _e_8632 = _e_8630 && _e_8631;
    assign _e_8633 = _e_8628 && _e_8632;
    assign _e_3247 = {3'd4};
    assign _e_3246 = {6'd40, _e_3247, x_n22, 2'bX};
    assign _e_3245 = {1'd1, _e_3246};
    assign _e_3252 = _e_3062;
    assign _e_3249 = _e_3062[43:33];
    assign _e_3251 = _e_3062[32:0];
    assign x_n23 = _e_3251[31:0];
    assign _e_8636 = _e_3249[10:4] == 7'd24;
    assign _e_8638 = _e_3251[32] == 1'd1;
    localparam[0:0] _e_8639 = 1;
    assign _e_8640 = _e_8638 && _e_8639;
    assign _e_8641 = _e_8636 && _e_8640;
    assign _e_3255 = {3'd5};
    assign _e_3254 = {6'd40, _e_3255, x_n23, 2'bX};
    assign _e_3253 = {1'd1, _e_3254};
    assign _e_3260 = _e_3062;
    assign _e_3257 = _e_3062[43:33];
    assign _e_3259 = _e_3062[32:0];
    assign x_n24 = _e_3259[31:0];
    assign _e_8644 = _e_3257[10:4] == 7'd25;
    assign _e_8646 = _e_3259[32] == 1'd1;
    localparam[0:0] _e_8647 = 1;
    assign _e_8648 = _e_8646 && _e_8647;
    assign _e_8649 = _e_8644 && _e_8648;
    assign _e_3263 = {3'd6};
    assign _e_3262 = {6'd40, _e_3263, x_n24, 2'bX};
    assign _e_3261 = {1'd1, _e_3262};
    assign _e_3268 = _e_3062;
    assign _e_3265 = _e_3062[43:33];
    assign _e_3267 = _e_3062[32:0];
    assign x_n25 = _e_3267[31:0];
    assign _e_8652 = _e_3265[10:4] == 7'd26;
    assign _e_8654 = _e_3267[32] == 1'd1;
    localparam[0:0] _e_8655 = 1;
    assign _e_8656 = _e_8654 && _e_8655;
    assign _e_8657 = _e_8652 && _e_8656;
    assign _e_3271 = {3'd7};
    assign _e_3270 = {6'd40, _e_3271, x_n25, 2'bX};
    assign _e_3269 = {1'd1, _e_3270};
    assign _e_3276 = _e_3062;
    assign _e_3273 = _e_3062[43:33];
    assign _e_3275 = _e_3062[32:0];
    assign x_n26 = _e_3275[31:0];
    assign _e_8660 = _e_3273[10:4] == 7'd27;
    assign _e_8662 = _e_3275[32] == 1'd1;
    localparam[0:0] _e_8663 = 1;
    assign _e_8664 = _e_8662 && _e_8663;
    assign _e_8665 = _e_8660 && _e_8664;
    assign _e_3278 = {6'd14, x_n26, 5'bX};
    assign _e_3277 = {1'd1, _e_3278};
    assign _e_3283 = _e_3062;
    assign _e_3280 = _e_3062[43:33];
    assign _e_3282 = _e_3062[32:0];
    assign x_n27 = _e_3282[31:0];
    assign _e_8668 = _e_3280[10:4] == 7'd28;
    assign _e_8670 = _e_3282[32] == 1'd1;
    localparam[0:0] _e_8671 = 1;
    assign _e_8672 = _e_8670 && _e_8671;
    assign _e_8673 = _e_8668 && _e_8672;
    assign _e_3286 = {1'd0};
    assign _e_3285 = {6'd15, _e_3286, x_n27, 4'bX};
    assign _e_3284 = {1'd1, _e_3285};
    assign _e_3291 = _e_3062;
    assign _e_3288 = _e_3062[43:33];
    assign _e_3290 = _e_3062[32:0];
    assign x_n28 = _e_3290[31:0];
    assign _e_8676 = _e_3288[10:4] == 7'd29;
    assign _e_8678 = _e_3290[32] == 1'd1;
    localparam[0:0] _e_8679 = 1;
    assign _e_8680 = _e_8678 && _e_8679;
    assign _e_8681 = _e_8676 && _e_8680;
    assign _e_3294 = {1'd1};
    assign _e_3293 = {6'd15, _e_3294, x_n28, 4'bX};
    assign _e_3292 = {1'd1, _e_3293};
    assign _e_3299 = _e_3062;
    assign _e_3296 = _e_3062[43:33];
    assign _e_3298 = _e_3062[32:0];
    assign x_n29 = _e_3298[31:0];
    assign _e_8684 = _e_3296[10:4] == 7'd30;
    assign _e_8686 = _e_3298[32] == 1'd1;
    localparam[0:0] _e_8687 = 1;
    assign _e_8688 = _e_8686 && _e_8687;
    assign _e_8689 = _e_8684 && _e_8688;
    assign _e_3302 = x_n29[9:0];
    assign _e_3301 = {6'd3, _e_3302, 27'bX};
    assign _e_3300 = {1'd1, _e_3301};
    assign _e_3307 = _e_3062;
    assign _e_3304 = _e_3062[43:33];
    assign _e_3306 = _e_3062[32:0];
    assign x_n30 = _e_3306[31:0];
    assign _e_8692 = _e_3304[10:4] == 7'd31;
    assign _e_8694 = _e_3306[32] == 1'd1;
    localparam[0:0] _e_8695 = 1;
    assign _e_8696 = _e_8694 && _e_8695;
    assign _e_8697 = _e_8692 && _e_8696;
    assign _e_3310 = x_n30[9:0];
    assign _e_3309 = {6'd18, _e_3310, 27'bX};
    assign _e_3308 = {1'd1, _e_3309};
    assign _e_3315 = _e_3062;
    assign _e_3312 = _e_3062[43:33];
    assign _e_3314 = _e_3062[32:0];
    assign x_n31 = _e_3314[31:0];
    assign _e_8700 = _e_3312[10:4] == 7'd32;
    assign _e_8702 = _e_3314[32] == 1'd1;
    localparam[0:0] _e_8703 = 1;
    assign _e_8704 = _e_8702 && _e_8703;
    assign _e_8705 = _e_8700 && _e_8704;
    assign _e_3317 = {6'd19, x_n31, 5'bX};
    assign _e_3316 = {1'd1, _e_3317};
    assign _e_3322 = _e_3062;
    assign _e_3319 = _e_3062[43:33];
    assign _e_3321 = _e_3062[32:0];
    assign x_n32 = _e_3321[31:0];
    assign _e_8708 = _e_3319[10:4] == 7'd33;
    assign _e_8710 = _e_3321[32] == 1'd1;
    localparam[0:0] _e_8711 = 1;
    assign _e_8712 = _e_8710 && _e_8711;
    assign _e_8713 = _e_8708 && _e_8712;
    assign _e_3324 = {6'd4, x_n32, 5'bX};
    assign _e_3323 = {1'd1, _e_3324};
    assign _e_3329 = _e_3062;
    assign _e_3326 = _e_3062[43:33];
    assign _e_3328 = _e_3062[32:0];
    assign x_n33 = _e_3328[31:0];
    assign _e_8716 = _e_3326[10:4] == 7'd34;
    assign _e_8718 = _e_3328[32] == 1'd1;
    localparam[0:0] _e_8719 = 1;
    assign _e_8720 = _e_8718 && _e_8719;
    assign _e_8721 = _e_8716 && _e_8720;
    assign _e_3331 = {6'd5, x_n33, 5'bX};
    assign _e_3330 = {1'd1, _e_3331};
    assign _e_3336 = _e_3062;
    assign _e_3333 = _e_3062[43:33];
    assign _e_3335 = _e_3062[32:0];
    assign x_n34 = _e_3335[31:0];
    assign _e_8724 = _e_3333[10:4] == 7'd35;
    assign _e_8726 = _e_3335[32] == 1'd1;
    localparam[0:0] _e_8727 = 1;
    assign _e_8728 = _e_8726 && _e_8727;
    assign _e_8729 = _e_8724 && _e_8728;
    assign _e_3338 = {6'd6, x_n34, 5'bX};
    assign _e_3337 = {1'd1, _e_3338};
    assign _e_3343 = _e_3062;
    assign _e_3340 = _e_3062[43:33];
    assign _e_3342 = _e_3062[32:0];
    assign x_n35 = _e_3342[31:0];
    assign _e_8732 = _e_3340[10:4] == 7'd36;
    assign _e_8734 = _e_3342[32] == 1'd1;
    localparam[0:0] _e_8735 = 1;
    assign _e_8736 = _e_8734 && _e_8735;
    assign _e_8737 = _e_8732 && _e_8736;
    assign _e_3345 = {6'd7, x_n35, 5'bX};
    assign _e_3344 = {1'd1, _e_3345};
    assign _e_3350 = _e_3062;
    assign _e_3347 = _e_3062[43:33];
    assign _e_3349 = _e_3062[32:0];
    assign x_n36 = _e_3349[31:0];
    assign _e_8740 = _e_3347[10:4] == 7'd37;
    assign _e_8742 = _e_3349[32] == 1'd1;
    localparam[0:0] _e_8743 = 1;
    assign _e_8744 = _e_8742 && _e_8743;
    assign _e_8745 = _e_8740 && _e_8744;
    assign _e_3352 = {6'd8, x_n36, 5'bX};
    assign _e_3351 = {1'd1, _e_3352};
    assign _e_3357 = _e_3062;
    assign _e_3354 = _e_3062[43:33];
    assign _e_3356 = _e_3062[32:0];
    assign x_n37 = _e_3356[31:0];
    assign _e_8748 = _e_3354[10:4] == 7'd38;
    assign _e_8750 = _e_3356[32] == 1'd1;
    localparam[0:0] _e_8751 = 1;
    assign _e_8752 = _e_8750 && _e_8751;
    assign _e_8753 = _e_8748 && _e_8752;
    assign _e_3359 = {6'd9, x_n37, 5'bX};
    assign _e_3358 = {1'd1, _e_3359};
    assign _e_3364 = _e_3062;
    assign _e_3361 = _e_3062[43:33];
    assign _e_3363 = _e_3062[32:0];
    assign x_n38 = _e_3363[31:0];
    assign _e_8756 = _e_3361[10:4] == 7'd39;
    assign _e_8758 = _e_3363[32] == 1'd1;
    localparam[0:0] _e_8759 = 1;
    assign _e_8760 = _e_8758 && _e_8759;
    assign _e_8761 = _e_8756 && _e_8760;
    assign _e_3367 = x_n38[15:0];
    assign _e_3366 = {6'd10, _e_3367, 21'bX};
    assign _e_3365 = {1'd1, _e_3366};
    assign _e_3372 = _e_3062;
    assign _e_3369 = _e_3062[43:33];
    assign _e_3371 = _e_3062[32:0];
    assign x_n39 = _e_3371[31:0];
    assign _e_8764 = _e_3369[10:4] == 7'd40;
    assign _e_8766 = _e_3371[32] == 1'd1;
    localparam[0:0] _e_8767 = 1;
    assign _e_8768 = _e_8766 && _e_8767;
    assign _e_8769 = _e_8764 && _e_8768;
    assign _e_3374 = {6'd11, x_n39, 5'bX};
    assign _e_3373 = {1'd1, _e_3374};
    assign _e_3379 = _e_3062;
    assign _e_3376 = _e_3062[43:33];
    assign _e_3378 = _e_3062[32:0];
    assign x_n40 = _e_3378[31:0];
    assign _e_8772 = _e_3376[10:4] == 7'd41;
    assign _e_8774 = _e_3378[32] == 1'd1;
    localparam[0:0] _e_8775 = 1;
    assign _e_8776 = _e_8774 && _e_8775;
    assign _e_8777 = _e_8772 && _e_8776;
    assign _e_3382 = {3'd0};
    assign _e_3381 = {6'd12, _e_3382, x_n40, 2'bX};
    assign _e_3380 = {1'd1, _e_3381};
    assign _e_3387 = _e_3062;
    assign _e_3384 = _e_3062[43:33];
    assign _e_3386 = _e_3062[32:0];
    assign x_n41 = _e_3386[31:0];
    assign _e_8780 = _e_3384[10:4] == 7'd42;
    assign _e_8782 = _e_3386[32] == 1'd1;
    localparam[0:0] _e_8783 = 1;
    assign _e_8784 = _e_8782 && _e_8783;
    assign _e_8785 = _e_8780 && _e_8784;
    assign _e_3390 = {3'd1};
    assign _e_3389 = {6'd12, _e_3390, x_n41, 2'bX};
    assign _e_3388 = {1'd1, _e_3389};
    assign _e_3395 = _e_3062;
    assign _e_3392 = _e_3062[43:33];
    assign _e_3394 = _e_3062[32:0];
    assign x_n42 = _e_3394[31:0];
    assign _e_8788 = _e_3392[10:4] == 7'd43;
    assign _e_8790 = _e_3394[32] == 1'd1;
    localparam[0:0] _e_8791 = 1;
    assign _e_8792 = _e_8790 && _e_8791;
    assign _e_8793 = _e_8788 && _e_8792;
    assign _e_3398 = {3'd2};
    assign _e_3397 = {6'd12, _e_3398, x_n42, 2'bX};
    assign _e_3396 = {1'd1, _e_3397};
    assign _e_3403 = _e_3062;
    assign _e_3400 = _e_3062[43:33];
    assign _e_3402 = _e_3062[32:0];
    assign x_n43 = _e_3402[31:0];
    assign _e_8796 = _e_3400[10:4] == 7'd44;
    assign _e_8798 = _e_3402[32] == 1'd1;
    localparam[0:0] _e_8799 = 1;
    assign _e_8800 = _e_8798 && _e_8799;
    assign _e_8801 = _e_8796 && _e_8800;
    assign _e_3406 = {3'd3};
    assign _e_3405 = {6'd12, _e_3406, x_n43, 2'bX};
    assign _e_3404 = {1'd1, _e_3405};
    assign _e_3411 = _e_3062;
    assign _e_3408 = _e_3062[43:33];
    assign _e_3410 = _e_3062[32:0];
    assign x_n44 = _e_3410[31:0];
    assign _e_8804 = _e_3408[10:4] == 7'd45;
    assign _e_8806 = _e_3410[32] == 1'd1;
    localparam[0:0] _e_8807 = 1;
    assign _e_8808 = _e_8806 && _e_8807;
    assign _e_8809 = _e_8804 && _e_8808;
    assign _e_3414 = {3'd4};
    assign _e_3413 = {6'd12, _e_3414, x_n44, 2'bX};
    assign _e_3412 = {1'd1, _e_3413};
    assign _e_3419 = _e_3062;
    assign _e_3416 = _e_3062[43:33];
    assign _e_3418 = _e_3062[32:0];
    assign x_n45 = _e_3418[31:0];
    assign _e_8812 = _e_3416[10:4] == 7'd46;
    assign _e_8814 = _e_3418[32] == 1'd1;
    localparam[0:0] _e_8815 = 1;
    assign _e_8816 = _e_8814 && _e_8815;
    assign _e_8817 = _e_8812 && _e_8816;
    assign _e_3422 = {3'd5};
    assign _e_3421 = {6'd12, _e_3422, x_n45, 2'bX};
    assign _e_3420 = {1'd1, _e_3421};
    assign _e_3427 = _e_3062;
    assign _e_3424 = _e_3062[43:33];
    assign _e_3426 = _e_3062[32:0];
    assign x_n46 = _e_3426[31:0];
    assign _e_8820 = _e_3424[10:4] == 7'd47;
    assign _e_8822 = _e_3426[32] == 1'd1;
    localparam[0:0] _e_8823 = 1;
    assign _e_8824 = _e_8822 && _e_8823;
    assign _e_8825 = _e_8820 && _e_8824;
    assign _e_3430 = {3'd0};
    assign _e_3429 = {6'd13, _e_3430, x_n46, 2'bX};
    assign _e_3428 = {1'd1, _e_3429};
    assign _e_3435 = _e_3062;
    assign _e_3432 = _e_3062[43:33];
    assign _e_3434 = _e_3062[32:0];
    assign x_n47 = _e_3434[31:0];
    assign _e_8828 = _e_3432[10:4] == 7'd48;
    assign _e_8830 = _e_3434[32] == 1'd1;
    localparam[0:0] _e_8831 = 1;
    assign _e_8832 = _e_8830 && _e_8831;
    assign _e_8833 = _e_8828 && _e_8832;
    assign _e_3438 = {3'd1};
    assign _e_3437 = {6'd13, _e_3438, x_n47, 2'bX};
    assign _e_3436 = {1'd1, _e_3437};
    assign _e_3443 = _e_3062;
    assign _e_3440 = _e_3062[43:33];
    assign _e_3442 = _e_3062[32:0];
    assign x_n48 = _e_3442[31:0];
    assign _e_8836 = _e_3440[10:4] == 7'd49;
    assign _e_8838 = _e_3442[32] == 1'd1;
    localparam[0:0] _e_8839 = 1;
    assign _e_8840 = _e_8838 && _e_8839;
    assign _e_8841 = _e_8836 && _e_8840;
    assign _e_3446 = {3'd2};
    assign _e_3445 = {6'd13, _e_3446, x_n48, 2'bX};
    assign _e_3444 = {1'd1, _e_3445};
    assign _e_3451 = _e_3062;
    assign _e_3448 = _e_3062[43:33];
    assign _e_3450 = _e_3062[32:0];
    assign x_n49 = _e_3450[31:0];
    assign _e_8844 = _e_3448[10:4] == 7'd50;
    assign _e_8846 = _e_3450[32] == 1'd1;
    localparam[0:0] _e_8847 = 1;
    assign _e_8848 = _e_8846 && _e_8847;
    assign _e_8849 = _e_8844 && _e_8848;
    assign _e_3454 = {3'd3};
    assign _e_3453 = {6'd13, _e_3454, x_n49, 2'bX};
    assign _e_3452 = {1'd1, _e_3453};
    assign _e_3459 = _e_3062;
    assign _e_3456 = _e_3062[43:33];
    assign _e_3458 = _e_3062[32:0];
    assign x_n50 = _e_3458[31:0];
    assign _e_8852 = _e_3456[10:4] == 7'd51;
    assign _e_8854 = _e_3458[32] == 1'd1;
    localparam[0:0] _e_8855 = 1;
    assign _e_8856 = _e_8854 && _e_8855;
    assign _e_8857 = _e_8852 && _e_8856;
    assign _e_3462 = {3'd4};
    assign _e_3461 = {6'd13, _e_3462, x_n50, 2'bX};
    assign _e_3460 = {1'd1, _e_3461};
    assign _e_3467 = _e_3062;
    assign _e_3464 = _e_3062[43:33];
    assign _e_3466 = _e_3062[32:0];
    assign x_n51 = _e_3466[31:0];
    assign _e_8860 = _e_3464[10:4] == 7'd52;
    assign _e_8862 = _e_3466[32] == 1'd1;
    localparam[0:0] _e_8863 = 1;
    assign _e_8864 = _e_8862 && _e_8863;
    assign _e_8865 = _e_8860 && _e_8864;
    assign _e_3470 = {3'd5};
    assign _e_3469 = {6'd13, _e_3470, x_n51, 2'bX};
    assign _e_3468 = {1'd1, _e_3469};
    assign _e_3475 = _e_3062;
    assign _e_3472 = _e_3062[43:33];
    assign _e_3474 = _e_3062[32:0];
    assign x_n52 = _e_3474[31:0];
    assign _e_8868 = _e_3472[10:4] == 7'd53;
    assign _e_8870 = _e_3474[32] == 1'd1;
    localparam[0:0] _e_8871 = 1;
    assign _e_8872 = _e_8870 && _e_8871;
    assign _e_8873 = _e_8868 && _e_8872;
    assign _e_3477 = {6'd16, x_n52, 5'bX};
    assign _e_3476 = {1'd1, _e_3477};
    assign _e_3482 = _e_3062;
    assign _e_3479 = _e_3062[43:33];
    assign _e_3481 = _e_3062[32:0];
    assign x_n53 = _e_3481[31:0];
    assign _e_8876 = _e_3479[10:4] == 7'd54;
    assign _e_8878 = _e_3481[32] == 1'd1;
    localparam[0:0] _e_8879 = 1;
    assign _e_8880 = _e_8878 && _e_8879;
    assign _e_8881 = _e_8876 && _e_8880;
    assign _e_3484 = {6'd17, x_n53, 5'bX};
    assign _e_3483 = {1'd1, _e_3484};
    assign _e_3489 = _e_3062;
    assign _e_3486 = _e_3062[43:33];
    assign _e_3488 = _e_3062[32:0];
    assign x_n54 = _e_3488[31:0];
    assign _e_8884 = _e_3486[10:4] == 7'd55;
    assign _e_8886 = _e_3488[32] == 1'd1;
    localparam[0:0] _e_8887 = 1;
    assign _e_8888 = _e_8886 && _e_8887;
    assign _e_8889 = _e_8884 && _e_8888;
    assign _e_3491 = {6'd21, x_n54, 5'bX};
    assign _e_3490 = {1'd1, _e_3491};
    assign _e_3496 = _e_3062;
    assign _e_3493 = _e_3062[43:33];
    assign _e_3495 = _e_3062[32:0];
    assign x_n55 = _e_3495[31:0];
    assign _e_8892 = _e_3493[10:4] == 7'd56;
    assign _e_8894 = _e_3495[32] == 1'd1;
    localparam[0:0] _e_8895 = 1;
    assign _e_8896 = _e_8894 && _e_8895;
    assign _e_8897 = _e_8892 && _e_8896;
    assign _e_3498 = {6'd22, x_n55, 5'bX};
    assign _e_3497 = {1'd1, _e_3498};
    assign _e_3503 = _e_3062;
    assign _e_3500 = _e_3062[43:33];
    assign _e_3502 = _e_3062[32:0];
    assign x_n56 = _e_3502[31:0];
    assign _e_8900 = _e_3500[10:4] == 7'd57;
    assign _e_8902 = _e_3502[32] == 1'd1;
    localparam[0:0] _e_8903 = 1;
    assign _e_8904 = _e_8902 && _e_8903;
    assign _e_8905 = _e_8900 && _e_8904;
    assign _e_3505 = {6'd23, x_n56, 5'bX};
    assign _e_3504 = {1'd1, _e_3505};
    assign _e_3510 = _e_3062;
    assign _e_3507 = _e_3062[43:33];
    assign _e_3509 = _e_3062[32:0];
    assign x_n57 = _e_3509[31:0];
    assign _e_8908 = _e_3507[10:4] == 7'd58;
    assign _e_8910 = _e_3509[32] == 1'd1;
    localparam[0:0] _e_8911 = 1;
    assign _e_8912 = _e_8910 && _e_8911;
    assign _e_8913 = _e_8908 && _e_8912;
    assign _e_3512 = {6'd24, x_n57, 5'bX};
    assign _e_3511 = {1'd1, _e_3512};
    assign _e_3517 = _e_3062;
    assign _e_3514 = _e_3062[43:33];
    assign _e_3516 = _e_3062[32:0];
    assign x_n58 = _e_3516[31:0];
    assign _e_8916 = _e_3514[10:4] == 7'd59;
    assign _e_8918 = _e_3516[32] == 1'd1;
    localparam[0:0] _e_8919 = 1;
    assign _e_8920 = _e_8918 && _e_8919;
    assign _e_8921 = _e_8916 && _e_8920;
    assign _e_3519 = {6'd25, x_n58, 5'bX};
    assign _e_3518 = {1'd1, _e_3519};
    assign _e_3524 = _e_3062;
    assign _e_3521 = _e_3062[43:33];
    assign _e_3523 = _e_3062[32:0];
    assign x_n59 = _e_3523[31:0];
    assign _e_8924 = _e_3521[10:4] == 7'd60;
    assign _e_8926 = _e_3523[32] == 1'd1;
    localparam[0:0] _e_8927 = 1;
    assign _e_8928 = _e_8926 && _e_8927;
    assign _e_8929 = _e_8924 && _e_8928;
    localparam[31:0] _e_3529 = 32'd0;
    assign _e_3527 = x_n59 != _e_3529;
    assign _e_3526 = {6'd26, _e_3527, 36'bX};
    assign _e_3525 = {1'd1, _e_3526};
    assign _e_3533 = _e_3062;
    assign _e_3530 = _e_3062[43:33];
    assign _e_3532 = _e_3062[32:0];
    assign x_n60 = _e_3532[31:0];
    assign _e_8932 = _e_3530[10:4] == 7'd61;
    assign _e_8934 = _e_3532[32] == 1'd1;
    localparam[0:0] _e_8935 = 1;
    assign _e_8936 = _e_8934 && _e_8935;
    assign _e_8937 = _e_8932 && _e_8936;
    localparam[31:0] _e_3538 = 32'd0;
    assign _e_3536 = x_n60 != _e_3538;
    assign _e_3535 = {6'd27, _e_3536, 36'bX};
    assign _e_3534 = {1'd1, _e_3535};
    assign _e_3542 = _e_3062;
    assign _e_3539 = _e_3062[43:33];
    assign _e_3541 = _e_3062[32:0];
    assign x_n61 = _e_3541[31:0];
    assign _e_8940 = _e_3539[10:4] == 7'd62;
    assign _e_8942 = _e_3541[32] == 1'd1;
    localparam[0:0] _e_8943 = 1;
    assign _e_8944 = _e_8942 && _e_8943;
    assign _e_8945 = _e_8940 && _e_8944;
    assign _e_3544 = {6'd28, x_n61, 5'bX};
    assign _e_3543 = {1'd1, _e_3544};
    assign _e_3549 = _e_3062;
    assign _e_3546 = _e_3062[43:33];
    assign _e_3548 = _e_3062[32:0];
    assign x_n62 = _e_3548[31:0];
    assign _e_8948 = _e_3546[10:4] == 7'd63;
    assign _e_8950 = _e_3548[32] == 1'd1;
    localparam[0:0] _e_8951 = 1;
    assign _e_8952 = _e_8950 && _e_8951;
    assign _e_8953 = _e_8948 && _e_8952;
    assign _e_3551 = {6'd29, x_n62, 5'bX};
    assign _e_3550 = {1'd1, _e_3551};
    assign _e_3556 = _e_3062;
    assign _e_3553 = _e_3062[43:33];
    assign _e_3555 = _e_3062[32:0];
    assign x_n63 = _e_3555[31:0];
    assign _e_8956 = _e_3553[10:4] == 7'd64;
    assign _e_8958 = _e_3555[32] == 1'd1;
    localparam[0:0] _e_8959 = 1;
    assign _e_8960 = _e_8958 && _e_8959;
    assign _e_8961 = _e_8956 && _e_8960;
    assign _e_3558 = {6'd30, x_n63, 5'bX};
    assign _e_3557 = {1'd1, _e_3558};
    assign _e_3563 = _e_3062;
    assign _e_3560 = _e_3062[43:33];
    assign _e_3562 = _e_3062[32:0];
    assign x_n64 = _e_3562[31:0];
    assign _e_8964 = _e_3560[10:4] == 7'd65;
    assign _e_8966 = _e_3562[32] == 1'd1;
    localparam[0:0] _e_8967 = 1;
    assign _e_8968 = _e_8966 && _e_8967;
    assign _e_8969 = _e_8964 && _e_8968;
    assign _e_3565 = {6'd31, x_n64, 5'bX};
    assign _e_3564 = {1'd1, _e_3565};
    assign _e_3570 = _e_3062;
    assign _e_3567 = _e_3062[43:33];
    assign _e_3569 = _e_3062[32:0];
    assign x_n65 = _e_3569[31:0];
    assign _e_8972 = _e_3567[10:4] == 7'd66;
    assign _e_8974 = _e_3569[32] == 1'd1;
    localparam[0:0] _e_8975 = 1;
    assign _e_8976 = _e_8974 && _e_8975;
    assign _e_8977 = _e_8972 && _e_8976;
    assign _e_3572 = {6'd32, x_n65, 5'bX};
    assign _e_3571 = {1'd1, _e_3572};
    assign _e_3577 = _e_3062;
    assign _e_3574 = _e_3062[43:33];
    assign _e_3576 = _e_3062[32:0];
    assign x_n66 = _e_3576[31:0];
    assign _e_8980 = _e_3574[10:4] == 7'd67;
    assign _e_8982 = _e_3576[32] == 1'd1;
    localparam[0:0] _e_8983 = 1;
    assign _e_8984 = _e_8982 && _e_8983;
    assign _e_8985 = _e_8980 && _e_8984;
    assign _e_3579 = {6'd33, x_n66, 5'bX};
    assign _e_3578 = {1'd1, _e_3579};
    assign _e_3584 = _e_3062;
    assign _e_3581 = _e_3062[43:33];
    assign _e_3583 = _e_3062[32:0];
    assign x_n67 = _e_3583[31:0];
    assign _e_8988 = _e_3581[10:4] == 7'd68;
    assign _e_8990 = _e_3583[32] == 1'd1;
    localparam[0:0] _e_8991 = 1;
    assign _e_8992 = _e_8990 && _e_8991;
    assign _e_8993 = _e_8988 && _e_8992;
    assign _e_3586 = {6'd34, x_n67, 5'bX};
    assign _e_3585 = {1'd1, _e_3586};
    assign _e_3591 = _e_3062;
    assign _e_3588 = _e_3062[43:33];
    assign _e_3590 = _e_3062[32:0];
    assign x_n68 = _e_3590[31:0];
    assign _e_8996 = _e_3588[10:4] == 7'd69;
    assign _e_8998 = _e_3590[32] == 1'd1;
    localparam[0:0] _e_8999 = 1;
    assign _e_9000 = _e_8998 && _e_8999;
    assign _e_9001 = _e_8996 && _e_9000;
    assign _e_3593 = {6'd35, x_n68, 5'bX};
    assign _e_3592 = {1'd1, _e_3593};
    assign _e_3598 = _e_3062;
    assign _e_3595 = _e_3062[43:33];
    assign _e_3597 = _e_3062[32:0];
    assign x_n69 = _e_3597[31:0];
    assign _e_9004 = _e_3595[10:4] == 7'd70;
    assign _e_9006 = _e_3597[32] == 1'd1;
    localparam[0:0] _e_9007 = 1;
    assign _e_9008 = _e_9006 && _e_9007;
    assign _e_9009 = _e_9004 && _e_9008;
    assign _e_3600 = {6'd36, x_n69, 5'bX};
    assign _e_3599 = {1'd1, _e_3600};
    assign _e_3605 = _e_3062;
    assign _e_3602 = _e_3062[43:33];
    assign _e_3604 = _e_3062[32:0];
    assign x_n70 = _e_3604[31:0];
    assign _e_9012 = _e_3602[10:4] == 7'd71;
    assign _e_9014 = _e_3604[32] == 1'd1;
    localparam[0:0] _e_9015 = 1;
    assign _e_9016 = _e_9014 && _e_9015;
    assign _e_9017 = _e_9012 && _e_9016;
    assign _e_3607 = {6'd37, 37'bX};
    assign _e_3606 = {1'd1, _e_3607};
    assign _e_3611 = _e_3062;
    assign _e_3608 = _e_3062[43:33];
    assign _e_3610 = _e_3062[32:0];
    assign x_n71 = _e_3610[31:0];
    assign _e_9020 = _e_3608[10:4] == 7'd72;
    assign _e_9022 = _e_3610[32] == 1'd1;
    localparam[0:0] _e_9023 = 1;
    assign _e_9024 = _e_9022 && _e_9023;
    assign _e_9025 = _e_9020 && _e_9024;
    assign _e_3614 = x_n71[7:0];
    assign _e_3613 = {6'd20, _e_3614, 29'bX};
    assign _e_3612 = {1'd1, _e_3613};
    assign _e_3619 = _e_3062;
    assign _e_3616 = _e_3062[43:33];
    assign _e_3618 = _e_3062[32:0];
    assign x_n72 = _e_3618[31:0];
    assign _e_9028 = _e_3616[10:4] == 7'd75;
    assign _e_9030 = _e_3618[32] == 1'd1;
    localparam[0:0] _e_9031 = 1;
    assign _e_9032 = _e_9030 && _e_9031;
    assign _e_9033 = _e_9028 && _e_9032;
    assign _e_3621 = {6'd42, 37'bX};
    assign _e_3620 = {1'd1, _e_3621};
    assign _e_3625 = _e_3062;
    assign _e_3622 = _e_3062[43:33];
    assign _e_3624 = _e_3062[32:0];
    assign x_n73 = _e_3624[31:0];
    assign _e_9036 = _e_3622[10:4] == 7'd73;
    assign _e_9038 = _e_3624[32] == 1'd1;
    localparam[0:0] _e_9039 = 1;
    assign _e_9040 = _e_9038 && _e_9039;
    assign _e_9041 = _e_9036 && _e_9040;
    assign _e_3628 = x_n73[7:0];
    assign _e_3627 = {6'd38, _e_3628, 29'bX};
    assign _e_3626 = {1'd1, _e_3627};
    assign _e_3633 = _e_3062;
    assign _e_3630 = _e_3062[43:33];
    assign _e_3632 = _e_3062[32:0];
    assign x_n74 = _e_3632[31:0];
    assign _e_9044 = _e_3630[10:4] == 7'd74;
    assign _e_9046 = _e_3632[32] == 1'd1;
    localparam[0:0] _e_9047 = 1;
    assign _e_9048 = _e_9046 && _e_9047;
    assign _e_9049 = _e_9044 && _e_9048;
    assign _e_3635 = {6'd41, 37'bX};
    assign _e_3634 = {1'd1, _e_3635};
    assign \_  = _e_3062;
    localparam[0:0] _e_9050 = 1;
    assign _e_3637 = {1'd0, 43'bX};
    always_comb begin
        priority casez ({_e_8457, _e_8465, _e_8473, _e_8481, _e_8489, _e_8497, _e_8505, _e_8513, _e_8521, _e_8529, _e_8537, _e_8545, _e_8553, _e_8561, _e_8569, _e_8577, _e_8585, _e_8593, _e_8601, _e_8609, _e_8617, _e_8625, _e_8633, _e_8641, _e_8649, _e_8657, _e_8665, _e_8673, _e_8681, _e_8689, _e_8697, _e_8705, _e_8713, _e_8721, _e_8729, _e_8737, _e_8745, _e_8753, _e_8761, _e_8769, _e_8777, _e_8785, _e_8793, _e_8801, _e_8809, _e_8817, _e_8825, _e_8833, _e_8841, _e_8849, _e_8857, _e_8865, _e_8873, _e_8881, _e_8889, _e_8897, _e_8905, _e_8913, _e_8921, _e_8929, _e_8937, _e_8945, _e_8953, _e_8961, _e_8969, _e_8977, _e_8985, _e_8993, _e_9001, _e_9009, _e_9017, _e_9025, _e_9033, _e_9041, _e_9049, _e_9050})
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

module \tta::tta::empty_tick  (
        output[509:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "tta::tta::empty_tick" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \tta::tta::empty_tick );
        end
    end
    `endif
    (* src = "src/tta.spade:320,9" *)
    logic[32:0] _e_3641;
    (* src = "src/tta.spade:321,9" *)
    logic[37:0] _e_3642;
    (* src = "src/tta.spade:322,9" *)
    logic[32:0] _e_3643;
    (* src = "src/tta.spade:323,9" *)
    logic[10:0] _e_3644;
    (* src = "src/tta.spade:324,9" *)
    logic[36:0] _e_3645;
    (* src = "src/tta.spade:325,9" *)
    logic[36:0] _e_3646;
    (* src = "src/tta.spade:328,9" *)
    logic[32:0] _e_3649;
    (* src = "src/tta.spade:329,9" *)
    logic[32:0] _e_3650;
    (* src = "src/tta.spade:330,9" *)
    logic[32:0] _e_3651;
    (* src = "src/tta.spade:331,9" *)
    logic[32:0] _e_3652;
    (* src = "src/tta.spade:332,9" *)
    logic[98:0] _e_3653;
    (* src = "src/tta.spade:318,5" *)
    logic[509:0] _e_3639;
    localparam[9:0] _e_3640 = 0;
    assign _e_3641 = {1'd0, 32'bX};
    assign _e_3642 = {1'd0, 37'bX};
    assign _e_3643 = {1'd0, 32'bX};
    assign _e_3644 = {1'd0, 10'bX};
    assign _e_3645 = {1'd0, 36'bX};
    assign _e_3646 = {1'd0, 36'bX};
    localparam[31:0] _e_3647 = 32'd0;
    localparam[31:0] _e_3648 = 32'd0;
    assign _e_3649 = {1'd0, 32'bX};
    assign _e_3650 = {1'd0, 32'bX};
    assign _e_3651 = {1'd0, 32'bX};
    assign _e_3652 = {1'd0, 32'bX};
    assign _e_3653 = {1'd0, 98'bX};
    localparam[15:0] _e_3654 = 0;
    assign _e_3639 = {_e_3640, _e_3641, _e_3642, _e_3643, _e_3644, _e_3645, _e_3646, _e_3647, _e_3648, _e_3649, _e_3650, _e_3651, _e_3652, _e_3653, _e_3654};
    assign output__ = _e_3639;
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
    (* src = "src/tta.spade:361,38" *)
    logic[10:0] _e_9051;
    (* src = "src/tta.spade:361,38" *)
    logic[10:0] _e_9052_mut;
    (* src = "src/tta.spade:361,38" *)
    logic[10:0] _e_3659;
    (* src = "src/tta.spade:361,38" *)
    logic[10:0] _e_3659_mut;
    (* src = "src/tta.spade:361,9" *)
    logic[10:0] \bt_target_r ;
    (* src = "src/tta.spade:361,9" *)
    logic[10:0] \bt_target_w_mut ;
    (* src = "src/tta.spade:364,19" *)
    logic[9:0] \pc_val ;
    (* src = "src/tta.spade:369,19" *)
    logic[10:0] \bt_val ;
    (* src = "src/tta.spade:375,19" *)
    logic[32:0] \alu_res ;
    (* src = "src/tta.spade:380,19" *)
    logic[32:0] \bit_res ;
    (* src = "src/tta.spade:385,20" *)
    logic[32:0] \lalu_res ;
    (* src = "src/tta.spade:390,19" *)
    logic[32:0] \mul_res ;
    (* src = "src/tta.spade:395,19" *)
    logic[32:0] \div_res ;
    (* src = "src/tta.spade:400,19" *)
    logic[32:0] \cmp_res ;
    (* src = "src/tta.spade:404,20" *)
    logic[32:0] \cmpz_res ;
    (* src = "src/tta.spade:410,19" *)
    logic[32:0] \lsu_res ;
    (* src = "src/tta.spade:416,20" *)
    logic[32:0] \lsu2_res ;
    (* src = "src/tta.spade:420,20" *)
    logic[32:0] \tanh_res ;
    (* src = "src/tta.spade:423,36" *)
    logic[63:0] _e_3743;
    (* src = "src/tta.spade:423,9" *)
    logic[31:0] \cc_res_lo ;
    (* src = "src/tta.spade:423,9" *)
    logic[31:0] \cc_res_high ;
    (* src = "src/tta.spade:427,24" *)
    logic[32:0] \xorshift_res ;
    (* src = "src/tta.spade:433,19" *)
    logic[32:0] \mac_res ;
    (* src = "src/tta.spade:439,19" *)
    logic[32:0] \sel_res ;
    (* src = "src/tta.spade:446,19" *)
    logic[32:0] \mda_res ;
    (* src = "src/tta.spade:452,21" *)
    logic[32:0] \stack_res ;
    (* src = "src/tta.spade:456,19" *)
    logic[15:0] \gpo_res ;
    (* src = "src/tta.spade:459,19" *)
    logic[32:0] \gpi_res ;
    (* src = "src/tta.spade:463,23" *)
    logic[32:0] \uart_in_res ;
    (* src = "src/tta.spade:469,22" *)
    logic[32:0] \spi_in_res ;
    (* src = "src/tta.spade:475,30" *)
    logic[48:0] _e_3816;
    (* src = "src/tta.spade:475,30" *)
    logic[36:0] _e_3815;
    (* src = "src/tta.spade:475,47" *)
    logic[36:0] _e_3819;
    (* src = "src/tta.spade:475,47" *)
    logic[3:0] \i ;
    logic _e_9054;
    logic _e_9056;
    (* src = "src/tta.spade:475,74" *)
    logic[36:0] __n2;
    (* src = "src/tta.spade:475,24" *)
    logic[3:0] \ra0 ;
    (* src = "src/tta.spade:476,30" *)
    logic[48:0] _e_3826;
    (* src = "src/tta.spade:476,30" *)
    logic[36:0] _e_3825;
    (* src = "src/tta.spade:476,47" *)
    logic[36:0] _e_3829;
    (* src = "src/tta.spade:476,47" *)
    logic[3:0] i_n1;
    logic _e_9059;
    logic _e_9061;
    (* src = "src/tta.spade:476,74" *)
    logic[36:0] __n3;
    (* src = "src/tta.spade:476,24" *)
    logic[3:0] \ra1 ;
    (* src = "src/tta.spade:480,20" *)
    logic[63:0] \registry ;
    (* src = "src/tta.spade:485,12" *)
    logic[48:0] _e_3844;
    (* src = "src/tta.spade:485,12" *)
    logic _e_3843;
    (* src = "src/tta.spade:486,19" *)
    logic[48:0] _e_3849;
    (* src = "src/tta.spade:486,19" *)
    logic[36:0] _e_3848;
    (* src = "src/tta.spade:487,17" *)
    logic[36:0] _e_3852;
    (* src = "src/tta.spade:487,17" *)
    logic[3:0] __n4;
    logic _e_9064;
    logic _e_9066;
    (* src = "src/tta.spade:487,48" *)
    logic[31:0] _e_3854;
    (* src = "src/tta.spade:487,43" *)
    logic[32:0] _e_3853;
    (* src = "src/tta.spade:488,17" *)
    logic[36:0] _e_3856;
    logic _e_9068;
    logic[31:0] _e_3858;
    (* src = "src/tta.spade:488,33" *)
    logic[32:0] _e_3857;
    (* src = "src/tta.spade:489,17" *)
    logic[36:0] _e_3860;
    logic _e_9070;
    (* src = "src/tta.spade:489,44" *)
    logic[10:0] _e_3863;
    logic[31:0] _e_3862;
    (* src = "src/tta.spade:489,34" *)
    logic[32:0] _e_3861;
    (* src = "src/tta.spade:490,17" *)
    logic[36:0] _e_3867;
    (* src = "src/tta.spade:490,17" *)
    logic[31:0] \v ;
    logic _e_9072;
    logic _e_9074;
    (* src = "src/tta.spade:490,39" *)
    logic[32:0] _e_3868;
    (* src = "src/tta.spade:491,17" *)
    logic[36:0] _e_3870;
    logic _e_9076;
    (* src = "src/tta.spade:491,33" *)
    logic[32:0] _e_3871;
    (* src = "src/tta.spade:492,17" *)
    logic[36:0] _e_3873;
    logic _e_9078;
    (* src = "src/tta.spade:493,17" *)
    logic[36:0] _e_3875;
    logic _e_9080;
    (* src = "src/tta.spade:494,17" *)
    logic[36:0] _e_3877;
    logic _e_9082;
    (* src = "src/tta.spade:495,17" *)
    logic[36:0] _e_3879;
    logic _e_9084;
    (* src = "src/tta.spade:496,17" *)
    logic[36:0] _e_3881;
    logic _e_9086;
    (* src = "src/tta.spade:497,17" *)
    logic[36:0] _e_3883;
    logic _e_9088;
    (* src = "src/tta.spade:498,17" *)
    logic[36:0] _e_3885;
    logic _e_9090;
    (* src = "src/tta.spade:499,17" *)
    logic[36:0] _e_3887;
    logic _e_9092;
    (* src = "src/tta.spade:500,17" *)
    logic[36:0] _e_3889;
    logic _e_9094;
    (* src = "src/tta.spade:501,17" *)
    logic[36:0] _e_3891;
    logic _e_9096;
    (* src = "src/tta.spade:501,35" *)
    logic[32:0] _e_3892;
    (* src = "src/tta.spade:502,17" *)
    logic[36:0] _e_3894;
    logic _e_9098;
    (* src = "src/tta.spade:502,37" *)
    logic[32:0] _e_3895;
    (* src = "src/tta.spade:503,17" *)
    logic[36:0] _e_3897;
    logic _e_9100;
    (* src = "src/tta.spade:504,17" *)
    logic[36:0] _e_3899;
    logic _e_9102;
    (* src = "src/tta.spade:505,17" *)
    logic[36:0] _e_3901;
    logic _e_9104;
    (* src = "src/tta.spade:506,17" *)
    logic[36:0] _e_3903;
    logic _e_9106;
    (* src = "src/tta.spade:507,17" *)
    logic[36:0] _e_3905;
    logic _e_9108;
    (* src = "src/tta.spade:508,17" *)
    logic[36:0] _e_3907;
    logic _e_9110;
    (* src = "src/tta.spade:509,17" *)
    logic[36:0] _e_3909;
    logic _e_9112;
    (* src = "src/tta.spade:510,17" *)
    logic[36:0] _e_3911;
    logic _e_9114;
    (* src = "src/tta.spade:511,17" *)
    logic[36:0] _e_3913;
    logic _e_9116;
    (* src = "src/tta.spade:486,13" *)
    logic[32:0] _e_3847;
    (* src = "src/tta.spade:513,18" *)
    logic[32:0] _e_3916;
    (* src = "src/tta.spade:485,9" *)
    logic[32:0] \bus0_val_opt ;
    (* src = "src/tta.spade:516,12" *)
    logic[48:0] _e_3920;
    (* src = "src/tta.spade:516,12" *)
    logic _e_3919;
    (* src = "src/tta.spade:517,19" *)
    logic[48:0] _e_3925;
    (* src = "src/tta.spade:517,19" *)
    logic[36:0] _e_3924;
    (* src = "src/tta.spade:518,17" *)
    logic[36:0] _e_3928;
    (* src = "src/tta.spade:518,17" *)
    logic[3:0] __n5;
    logic _e_9118;
    logic _e_9120;
    (* src = "src/tta.spade:518,48" *)
    logic[31:0] _e_3930;
    (* src = "src/tta.spade:518,43" *)
    logic[32:0] _e_3929;
    (* src = "src/tta.spade:519,17" *)
    logic[36:0] _e_3932;
    logic _e_9122;
    logic[31:0] _e_3934;
    (* src = "src/tta.spade:519,33" *)
    logic[32:0] _e_3933;
    (* src = "src/tta.spade:520,17" *)
    logic[36:0] _e_3936;
    logic _e_9124;
    (* src = "src/tta.spade:520,44" *)
    logic[10:0] _e_3939;
    logic[31:0] _e_3938;
    (* src = "src/tta.spade:520,34" *)
    logic[32:0] _e_3937;
    (* src = "src/tta.spade:521,17" *)
    logic[36:0] _e_3943;
    (* src = "src/tta.spade:521,17" *)
    logic[31:0] v_n1;
    logic _e_9126;
    logic _e_9128;
    (* src = "src/tta.spade:521,39" *)
    logic[32:0] _e_3944;
    (* src = "src/tta.spade:522,17" *)
    logic[36:0] _e_3946;
    logic _e_9130;
    (* src = "src/tta.spade:522,33" *)
    logic[32:0] _e_3947;
    (* src = "src/tta.spade:523,17" *)
    logic[36:0] _e_3949;
    logic _e_9132;
    (* src = "src/tta.spade:524,17" *)
    logic[36:0] _e_3951;
    logic _e_9134;
    (* src = "src/tta.spade:525,17" *)
    logic[36:0] _e_3953;
    logic _e_9136;
    (* src = "src/tta.spade:526,17" *)
    logic[36:0] _e_3955;
    logic _e_9138;
    (* src = "src/tta.spade:527,17" *)
    logic[36:0] _e_3957;
    logic _e_9140;
    (* src = "src/tta.spade:528,17" *)
    logic[36:0] _e_3959;
    logic _e_9142;
    (* src = "src/tta.spade:529,17" *)
    logic[36:0] _e_3961;
    logic _e_9144;
    (* src = "src/tta.spade:530,17" *)
    logic[36:0] _e_3963;
    logic _e_9146;
    (* src = "src/tta.spade:531,17" *)
    logic[36:0] _e_3965;
    logic _e_9148;
    (* src = "src/tta.spade:532,17" *)
    logic[36:0] _e_3967;
    logic _e_9150;
    (* src = "src/tta.spade:532,35" *)
    logic[32:0] _e_3968;
    (* src = "src/tta.spade:533,17" *)
    logic[36:0] _e_3970;
    logic _e_9152;
    (* src = "src/tta.spade:533,37" *)
    logic[32:0] _e_3971;
    (* src = "src/tta.spade:534,17" *)
    logic[36:0] _e_3973;
    logic _e_9154;
    (* src = "src/tta.spade:535,17" *)
    logic[36:0] _e_3975;
    logic _e_9156;
    (* src = "src/tta.spade:536,17" *)
    logic[36:0] _e_3977;
    logic _e_9158;
    (* src = "src/tta.spade:537,17" *)
    logic[36:0] _e_3979;
    logic _e_9160;
    (* src = "src/tta.spade:538,17" *)
    logic[36:0] _e_3981;
    logic _e_9162;
    (* src = "src/tta.spade:539,17" *)
    logic[36:0] _e_3983;
    logic _e_9164;
    (* src = "src/tta.spade:540,17" *)
    logic[36:0] _e_3985;
    logic _e_9166;
    (* src = "src/tta.spade:541,17" *)
    logic[36:0] _e_3987;
    logic _e_9168;
    (* src = "src/tta.spade:542,17" *)
    logic[36:0] _e_3989;
    logic _e_9170;
    (* src = "src/tta.spade:517,13" *)
    logic[32:0] _e_3923;
    (* src = "src/tta.spade:544,18" *)
    logic[32:0] _e_3992;
    (* src = "src/tta.spade:516,9" *)
    logic[32:0] \bus1_val_opt ;
    (* src = "src/tta.spade:547,26" *)
    logic[48:0] _e_3996;
    (* src = "src/tta.spade:547,26" *)
    logic[10:0] _e_3995;
    (* src = "src/tta.spade:547,14" *)
    logic[43:0] \m0 ;
    (* src = "src/tta.spade:548,26" *)
    logic[48:0] _e_4002;
    (* src = "src/tta.spade:548,26" *)
    logic[10:0] _e_4001;
    (* src = "src/tta.spade:548,14" *)
    logic[43:0] \m1 ;
    (* src = "src/tta.spade:552,17" *)
    logic[36:0] \rf_w0 ;
    (* src = "src/tta.spade:553,17" *)
    logic[36:0] \rf_w1 ;
    (* src = "src/tta.spade:555,20" *)
    logic[32:0] \alu_op_a ;
    (* src = "src/tta.spade:556,20" *)
    logic[37:0] \alu_trig ;
    (* src = "src/tta.spade:558,20" *)
    logic[32:0] \bit_op_a ;
    (* src = "src/tta.spade:559,20" *)
    logic[35:0] \bit_trig ;
    (* src = "src/tta.spade:561,21" *)
    logic[32:0] \lalu_op_a ;
    (* src = "src/tta.spade:562,21" *)
    logic[33:0] \lalu_trig ;
    (* src = "src/tta.spade:564,24" *)
    logic[32:0] \mul_set_addr ;
    (* src = "src/tta.spade:565,20" *)
    logic[32:0] \mul_trig ;
    (* src = "src/tta.spade:567,24" *)
    logic[32:0] \div_set_addr ;
    (* src = "src/tta.spade:568,20" *)
    logic[32:0] \div_trig ;
    (* src = "src/tta.spade:570,20" *)
    logic[32:0] \cmp_op_a ;
    (* src = "src/tta.spade:571,20" *)
    logic[35:0] \cmp_trig ;
    (* src = "src/tta.spade:573,21" *)
    logic[35:0] \cmpz_trig ;
    (* src = "src/tta.spade:575,25" *)
    logic[10:0] \pc_jump_final ;
    (* src = "src/tta.spade:577,21" *)
    logic[10:0] \bt_target ;
    (* src = "src/tta.spade:578,19" *)
    logic[32:0] \bt_trig ;
    (* src = "src/tta.spade:580,24" *)
    logic[32:0] \lsu_set_addr ;
    (* src = "src/tta.spade:581,25" *)
    logic[32:0] \lsu_load_trig ;
    (* src = "src/tta.spade:582,26" *)
    logic[32:0] \lsu_store_trig ;
    (* src = "src/tta.spade:584,25" *)
    logic[32:0] \lsu2_set_addr ;
    (* src = "src/tta.spade:585,26" *)
    logic[32:0] \lsu2_load_trig ;
    (* src = "src/tta.spade:586,27" *)
    logic[32:0] \lsu2_store_trig ;
    (* src = "src/tta.spade:588,25" *)
    logic[32:0] \xorshift_trig ;
    (* src = "src/tta.spade:590,24" *)
    logic[32:0] \mac_set_addr ;
    (* src = "src/tta.spade:591,20" *)
    logic[32:0] \mac_trig ;
    (* src = "src/tta.spade:592,21" *)
    logic \mac_clear ;
    (* src = "src/tta.spade:594,20" *)
    logic[1:0] \sel_cond ;
    (* src = "src/tta.spade:595,20" *)
    logic[32:0] \sel_seta ;
    (* src = "src/tta.spade:596,21" *)
    logic[32:0] \sel_trigb ;
    (* src = "src/tta.spade:598,20" *)
    logic[32:0] \mda_base ;
    (* src = "src/tta.spade:599,20" *)
    logic[32:0] \mda_mask ;
    (* src = "src/tta.spade:600,19" *)
    logic[32:0] \mda_ptr ;
    (* src = "src/tta.spade:601,20" *)
    logic[32:0] \mda_trig ;
    (* src = "src/tta.spade:603,21" *)
    logic[32:0] \tanh_trig ;
    (* src = "src/tta.spade:605,25" *)
    logic[32:0] \stack_setaddr ;
    (* src = "src/tta.spade:606,22" *)
    logic[32:0] \stack_push ;
    (* src = "src/tta.spade:607,21" *)
    logic \stack_pop ;
    (* src = "src/tta.spade:609,20" *)
    logic[16:0] \gpo_trig ;
    (* src = "src/tta.spade:611,25" *)
    logic[8:0] \spi_out8_trig ;
    (* src = "src/tta.spade:612,26" *)
    logic \spi_inpop_trig ;
    (* src = "src/tta.spade:614,26" *)
    logic[8:0] \uart_out8_trig ;
    (* src = "src/tta.spade:615,27" *)
    logic \uart_inpop_trig ;
    (* src = "src/tta.spade:617,9" *)
    logic[10:0] \pc_jump_comb ;
    (* src = "src/tta.spade:618,24" *)
    logic[31:0] \rd0 ;
    (* src = "src/tta.spade:619,24" *)
    logic[31:0] \rd1 ;
    (* src = "src/tta.spade:635,9" *)
    logic[98:0] _e_4202;
    (* src = "src/tta.spade:621,5" *)
    logic[509:0] _e_4188;
    
    assign _e_9051 = _e_9052_mut;
    assign _e_3659 = {_e_9051};
    assign {_e_9052_mut} = _e_3659_mut;
    assign \bt_target_r  = _e_3659[10:0];
    assign _e_3659_mut[10:0] = \bt_target_w_mut ;
    (* src = "src/tta.spade:364,19" *)
    \tta::pc::pc_fu  pc_fu_0(.clk_i(\clk ), .rst_i(\rst ), .jump_to_i(\pc_jump_final ), .bt_i(\bt_target_r ), .output__(\pc_val ));
    assign \pc_w_mut  = \pc_val ;
    (* src = "src/tta.spade:369,19" *)
    \tta::bt::bt_fu  bt_fu_0(.clk_i(\clk ), .rst_i(\rst ), .jump_to_i(\bt_target ), .condition_trig_i(\bt_trig ), .output__(\bt_val ));
    assign \bt_target_w_mut  = \bt_val ;
    (* src = "src/tta.spade:375,19" *)
    \tta::alu::alu_fu  alu_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\alu_op_a ), .trig_i(\alu_trig ), .output__(\alu_res ));
    (* src = "src/tta.spade:380,19" *)
    \tta::bit::bit_fu  bit_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\bit_op_a ), .trig_i(\bit_trig ), .output__(\bit_res ));
    (* src = "src/tta.spade:385,20" *)
    \tta::lalu::lalu_fu  lalu_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\lalu_op_a ), .trig_i(\lalu_trig ), .output__(\lalu_res ));
    (* src = "src/tta.spade:390,19" *)
    \tta::mul_shiftadd::mul_shiftadd_fu  mul_shiftadd_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\mul_set_addr ), .trig_i(\mul_trig ), .output__(\mul_res ));
    (* src = "src/tta.spade:395,19" *)
    \tta::div_shiftsub::div_shiftsub_fu  div_shiftsub_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\div_set_addr ), .trig_i(\div_trig ), .output__(\div_res ));
    (* src = "src/tta.spade:400,19" *)
    \tta::cmp::cmp_fu  cmp_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\cmp_op_a ), .trig_i(\cmp_trig ), .output__(\cmp_res ));
    (* src = "src/tta.spade:404,20" *)
    \tta::cmpz::cmpz_fu  cmpz_fu_0(.clk_i(\clk ), .rst_i(\rst ), .trig_i(\cmpz_trig ), .output__(\cmpz_res ));
    (* src = "src/tta.spade:410,19" *)
    \tta::lsu::lsu_fu  lsu_fu_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .set_addr_a_i(\lsu_set_addr ), .load_trig_i(\lsu_load_trig ), .store_trig_i(\lsu_store_trig ), .output__(\lsu_res ));
    (* src = "src/tta.spade:416,20" *)
    \tta::lsu::lsu_fu  lsu_fu_1(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .set_addr_a_i(\lsu2_set_addr ), .load_trig_i(\lsu2_load_trig ), .store_trig_i(\lsu2_store_trig ), .output__(\lsu2_res ));
    (* src = "src/tta.spade:420,20" *)
    \tta::tanh::tanh_pwl_fu  tanh_pwl_fu_0(.clk_i(\clk ), .rst_i(\rst ), .trig_i(\tanh_trig ), .output__(\tanh_res ));
    (* src = "src/tta.spade:423,36" *)
    \tta::cc::cc_fu  cc_fu_0(.clk_i(\clk ), .rst_i(\rst ), .output__(_e_3743));
    assign \cc_res_lo  = _e_3743[63:32];
    assign \cc_res_high  = _e_3743[31:0];
    (* src = "src/tta.spade:427,24" *)
    \tta::xorshift::xorshift_fu  xorshift_fu_0(.clk_i(\clk ), .rst_i(\rst ), .trig_i(\xorshift_trig ), .output__(\xorshift_res ));
    (* src = "src/tta.spade:433,19" *)
    \tta::mac::mac_fu  mac_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_op_a_i(\mac_set_addr ), .trig_i(\mac_trig ), .clr_i(\mac_clear ), .output__(\mac_res ));
    (* src = "src/tta.spade:439,19" *)
    \tta::sel::sel_fu  sel_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_cond_i(\sel_cond ), .set_a_i(\sel_seta ), .trig_b_i(\sel_trigb ), .output__(\sel_res ));
    (* src = "src/tta.spade:446,19" *)
    \tta::modadd::modadd_fu  modadd_fu_0(.clk_i(\clk ), .rst_i(\rst ), .set_base_i(\mda_base ), .set_mask_i(\mda_mask ), .set_ptr_i(\mda_ptr ), .trig_stride_i(\mda_trig ), .output__(\mda_res ));
    (* src = "src/tta.spade:452,21" *)
    \tta::stack_lsu::stack_lsu_fu  stack_lsu_fu_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .set_sp_i(\stack_setaddr ), .pop_trig_i(\stack_pop ), .push_trig_i(\stack_push ), .output__(\stack_res ));
    (* src = "src/tta.spade:456,19" *)
    \tta::gpo::gpo16  gpo16_0(.clk_i(\clk ), .rst_i(\rst ), .wr_i(\gpo_trig ), .output__(\gpo_res ));
    (* src = "src/tta.spade:459,19" *)
    \tta::gpi::gpi16  gpi16_0(.clk_i(\clk ), .rst_i(\rst ), .pins_i(\gpi16 ), .output__(\gpi_res ));
    (* src = "src/tta.spade:463,23" *)
    \tta::uart_in::uart_in  uart_in_0(.clk_i(\clk ), .rst_i(\rst ), .uart_byte_i(\uart_rx ), .pop_i(\uart_inpop_trig ), .output__(\uart_in_res ));
    (* src = "src/tta.spade:465,13" *)
    \tta::uart_in::uart_out  uart_out_0(.clk_i(\clk ), .rst_i(\rst ), .byte_to_write_i(\uart_out8_trig ), .tx_o(\uart_tx_mut ), .uart_tx_busy_i(\uart_tx_busy ));
    (* src = "src/tta.spade:469,22" *)
    \tta::spi::spi_in  spi_in_0(.clk_i(\clk ), .rst_i(\rst ), .miso_byte_i(\spi_miso ), .pop_i(\spi_inpop_trig ), .output__(\spi_in_res ));
    (* src = "src/tta.spade:471,13" *)
    \tta::spi::spi_out8  spi_out8_0(.clk_i(\clk ), .rst_i(\rst ), .byte_to_write_i(\spi_out8_trig ), .mosi_o(\spi_mosi_mut ), .spi_busy_i(\spi_busy ));
    assign _e_3816 = \insn [97:49];
    assign _e_3815 = _e_3816[48:12];
    assign _e_3819 = _e_3815;
    assign \i  = _e_3815[31:28];
    assign _e_9054 = _e_3815[36:32] == 5'd0;
    localparam[0:0] _e_9055 = 1;
    assign _e_9056 = _e_9054 && _e_9055;
    assign __n2 = _e_3815;
    localparam[0:0] _e_9057 = 1;
    localparam[3:0] _e_3822 = 0;
    always_comb begin
        priority casez ({_e_9056, _e_9057})
            2'b1?: \ra0  = \i ;
            2'b01: \ra0  = _e_3822;
            2'b?: \ra0  = 4'dx;
        endcase
    end
    assign _e_3826 = \insn [48:0];
    assign _e_3825 = _e_3826[48:12];
    assign _e_3829 = _e_3825;
    assign i_n1 = _e_3825[31:28];
    assign _e_9059 = _e_3825[36:32] == 5'd0;
    localparam[0:0] _e_9060 = 1;
    assign _e_9061 = _e_9059 && _e_9060;
    assign __n3 = _e_3825;
    localparam[0:0] _e_9062 = 1;
    localparam[3:0] _e_3832 = 0;
    always_comb begin
        priority casez ({_e_9061, _e_9062})
            2'b1?: \ra1  = i_n1;
            2'b01: \ra1  = _e_3832;
            2'b?: \ra1  = 4'dx;
        endcase
    end
    (* src = "src/tta.spade:480,20" *)
    \tta::regfile::regfile8_fu  regfile8_fu_0(.clk_i(\clk ), .rst_i(\rst ), .wr0_i(\rf_w0 ), .wr1_i(\rf_w1 ), .ra0_i(\ra0 ), .ra1_i(\ra1 ), .output__(\registry ));
    assign _e_3844 = \insn [97:49];
    assign _e_3843 = _e_3844[0];
    assign _e_3849 = \insn [97:49];
    assign _e_3848 = _e_3849[48:12];
    assign _e_3852 = _e_3848;
    assign __n4 = _e_3848[31:28];
    assign _e_9064 = _e_3848[36:32] == 5'd0;
    localparam[0:0] _e_9065 = 1;
    assign _e_9066 = _e_9064 && _e_9065;
    assign _e_3854 = \registry [63:32];
    assign _e_3853 = {1'd1, _e_3854};
    assign _e_3856 = _e_3848;
    assign _e_9068 = _e_3848[36:32] == 5'd3;
    assign _e_3858 = {22'b0, \pc_val };
    assign _e_3857 = {1'd1, _e_3858};
    assign _e_3860 = _e_3848;
    assign _e_9070 = _e_3848[36:32] == 5'd4;
    localparam[9:0] _e_3865 = 1;
    assign _e_3863 = \pc_val  + _e_3865;
    assign _e_3862 = {21'b0, _e_3863};
    assign _e_3861 = {1'd1, _e_3862};
    assign _e_3867 = _e_3848;
    assign \v  = _e_3848[31:0];
    assign _e_9072 = _e_3848[36:32] == 5'd5;
    localparam[0:0] _e_9073 = 1;
    assign _e_9074 = _e_9072 && _e_9073;
    assign _e_3868 = {1'd1, \v };
    assign _e_3870 = _e_3848;
    assign _e_9076 = _e_3848[36:32] == 5'd6;
    localparam[31:0] _e_3872 = 32'd0;
    assign _e_3871 = {1'd1, _e_3872};
    assign _e_3873 = _e_3848;
    assign _e_9078 = _e_3848[36:32] == 5'd1;
    assign _e_3875 = _e_3848;
    assign _e_9080 = _e_3848[36:32] == 5'd7;
    assign _e_3877 = _e_3848;
    assign _e_9082 = _e_3848[36:32] == 5'd8;
    assign _e_3879 = _e_3848;
    assign _e_9084 = _e_3848[36:32] == 5'd9;
    assign _e_3881 = _e_3848;
    assign _e_9086 = _e_3848[36:32] == 5'd10;
    assign _e_3883 = _e_3848;
    assign _e_9088 = _e_3848[36:32] == 5'd11;
    assign _e_3885 = _e_3848;
    assign _e_9090 = _e_3848[36:32] == 5'd12;
    assign _e_3887 = _e_3848;
    assign _e_9092 = _e_3848[36:32] == 5'd2;
    assign _e_3889 = _e_3848;
    assign _e_9094 = _e_3848[36:32] == 5'd13;
    assign _e_3891 = _e_3848;
    assign _e_9096 = _e_3848[36:32] == 5'd14;
    assign _e_3892 = {1'd1, \cc_res_lo };
    assign _e_3894 = _e_3848;
    assign _e_9098 = _e_3848[36:32] == 5'd15;
    assign _e_3895 = {1'd1, \cc_res_high };
    assign _e_3897 = _e_3848;
    assign _e_9100 = _e_3848[36:32] == 5'd16;
    assign _e_3899 = _e_3848;
    assign _e_9102 = _e_3848[36:32] == 5'd17;
    assign _e_3901 = _e_3848;
    assign _e_9104 = _e_3848[36:32] == 5'd18;
    assign _e_3903 = _e_3848;
    assign _e_9106 = _e_3848[36:32] == 5'd19;
    assign _e_3905 = _e_3848;
    assign _e_9108 = _e_3848[36:32] == 5'd20;
    assign _e_3907 = _e_3848;
    assign _e_9110 = _e_3848[36:32] == 5'd21;
    assign _e_3909 = _e_3848;
    assign _e_9112 = _e_3848[36:32] == 5'd22;
    assign _e_3911 = _e_3848;
    assign _e_9114 = _e_3848[36:32] == 5'd23;
    assign _e_3913 = _e_3848;
    assign _e_9116 = _e_3848[36:32] == 5'd24;
    always_comb begin
        priority casez ({_e_9066, _e_9068, _e_9070, _e_9074, _e_9076, _e_9078, _e_9080, _e_9082, _e_9084, _e_9086, _e_9088, _e_9090, _e_9092, _e_9094, _e_9096, _e_9098, _e_9100, _e_9102, _e_9104, _e_9106, _e_9108, _e_9110, _e_9112, _e_9114, _e_9116})
            25'b1????????????????????????: _e_3847 = _e_3853;
            25'b01???????????????????????: _e_3847 = _e_3857;
            25'b001??????????????????????: _e_3847 = _e_3861;
            25'b0001?????????????????????: _e_3847 = _e_3868;
            25'b00001????????????????????: _e_3847 = _e_3871;
            25'b000001???????????????????: _e_3847 = \alu_res ;
            25'b0000001??????????????????: _e_3847 = \lsu_res ;
            25'b00000001?????????????????: _e_3847 = \lsu2_res ;
            25'b000000001????????????????: _e_3847 = \gpi_res ;
            25'b0000000001???????????????: _e_3847 = \uart_in_res ;
            25'b00000000001??????????????: _e_3847 = \cmp_res ;
            25'b000000000001?????????????: _e_3847 = \cmpz_res ;
            25'b0000000000001????????????: _e_3847 = \lalu_res ;
            25'b00000000000001???????????: _e_3847 = \mul_res ;
            25'b000000000000001??????????: _e_3847 = _e_3892;
            25'b0000000000000001?????????: _e_3847 = _e_3895;
            25'b00000000000000001????????: _e_3847 = \spi_in_res ;
            25'b000000000000000001???????: _e_3847 = \div_res ;
            25'b0000000000000000001??????: _e_3847 = \xorshift_res ;
            25'b00000000000000000001?????: _e_3847 = \mac_res ;
            25'b000000000000000000001????: _e_3847 = \sel_res ;
            25'b0000000000000000000001???: _e_3847 = \mda_res ;
            25'b00000000000000000000001??: _e_3847 = \tanh_res ;
            25'b000000000000000000000001?: _e_3847 = \stack_res ;
            25'b0000000000000000000000001: _e_3847 = \bit_res ;
            25'b?: _e_3847 = 33'dx;
        endcase
    end
    assign _e_3916 = {1'd0, 32'bX};
    assign \bus0_val_opt  = _e_3843 ? _e_3847 : _e_3916;
    assign _e_3920 = \insn [48:0];
    assign _e_3919 = _e_3920[0];
    assign _e_3925 = \insn [48:0];
    assign _e_3924 = _e_3925[48:12];
    assign _e_3928 = _e_3924;
    assign __n5 = _e_3924[31:28];
    assign _e_9118 = _e_3924[36:32] == 5'd0;
    localparam[0:0] _e_9119 = 1;
    assign _e_9120 = _e_9118 && _e_9119;
    assign _e_3930 = \registry [31:0];
    assign _e_3929 = {1'd1, _e_3930};
    assign _e_3932 = _e_3924;
    assign _e_9122 = _e_3924[36:32] == 5'd3;
    assign _e_3934 = {22'b0, \pc_val };
    assign _e_3933 = {1'd1, _e_3934};
    assign _e_3936 = _e_3924;
    assign _e_9124 = _e_3924[36:32] == 5'd4;
    localparam[9:0] _e_3941 = 1;
    assign _e_3939 = \pc_val  + _e_3941;
    assign _e_3938 = {21'b0, _e_3939};
    assign _e_3937 = {1'd1, _e_3938};
    assign _e_3943 = _e_3924;
    assign v_n1 = _e_3924[31:0];
    assign _e_9126 = _e_3924[36:32] == 5'd5;
    localparam[0:0] _e_9127 = 1;
    assign _e_9128 = _e_9126 && _e_9127;
    assign _e_3944 = {1'd1, v_n1};
    assign _e_3946 = _e_3924;
    assign _e_9130 = _e_3924[36:32] == 5'd6;
    localparam[31:0] _e_3948 = 32'd0;
    assign _e_3947 = {1'd1, _e_3948};
    assign _e_3949 = _e_3924;
    assign _e_9132 = _e_3924[36:32] == 5'd1;
    assign _e_3951 = _e_3924;
    assign _e_9134 = _e_3924[36:32] == 5'd7;
    assign _e_3953 = _e_3924;
    assign _e_9136 = _e_3924[36:32] == 5'd8;
    assign _e_3955 = _e_3924;
    assign _e_9138 = _e_3924[36:32] == 5'd9;
    assign _e_3957 = _e_3924;
    assign _e_9140 = _e_3924[36:32] == 5'd10;
    assign _e_3959 = _e_3924;
    assign _e_9142 = _e_3924[36:32] == 5'd11;
    assign _e_3961 = _e_3924;
    assign _e_9144 = _e_3924[36:32] == 5'd12;
    assign _e_3963 = _e_3924;
    assign _e_9146 = _e_3924[36:32] == 5'd2;
    assign _e_3965 = _e_3924;
    assign _e_9148 = _e_3924[36:32] == 5'd13;
    assign _e_3967 = _e_3924;
    assign _e_9150 = _e_3924[36:32] == 5'd14;
    assign _e_3968 = {1'd1, \cc_res_lo };
    assign _e_3970 = _e_3924;
    assign _e_9152 = _e_3924[36:32] == 5'd15;
    assign _e_3971 = {1'd1, \cc_res_high };
    assign _e_3973 = _e_3924;
    assign _e_9154 = _e_3924[36:32] == 5'd16;
    assign _e_3975 = _e_3924;
    assign _e_9156 = _e_3924[36:32] == 5'd17;
    assign _e_3977 = _e_3924;
    assign _e_9158 = _e_3924[36:32] == 5'd18;
    assign _e_3979 = _e_3924;
    assign _e_9160 = _e_3924[36:32] == 5'd19;
    assign _e_3981 = _e_3924;
    assign _e_9162 = _e_3924[36:32] == 5'd20;
    assign _e_3983 = _e_3924;
    assign _e_9164 = _e_3924[36:32] == 5'd21;
    assign _e_3985 = _e_3924;
    assign _e_9166 = _e_3924[36:32] == 5'd22;
    assign _e_3987 = _e_3924;
    assign _e_9168 = _e_3924[36:32] == 5'd23;
    assign _e_3989 = _e_3924;
    assign _e_9170 = _e_3924[36:32] == 5'd24;
    always_comb begin
        priority casez ({_e_9120, _e_9122, _e_9124, _e_9128, _e_9130, _e_9132, _e_9134, _e_9136, _e_9138, _e_9140, _e_9142, _e_9144, _e_9146, _e_9148, _e_9150, _e_9152, _e_9154, _e_9156, _e_9158, _e_9160, _e_9162, _e_9164, _e_9166, _e_9168, _e_9170})
            25'b1????????????????????????: _e_3923 = _e_3929;
            25'b01???????????????????????: _e_3923 = _e_3933;
            25'b001??????????????????????: _e_3923 = _e_3937;
            25'b0001?????????????????????: _e_3923 = _e_3944;
            25'b00001????????????????????: _e_3923 = _e_3947;
            25'b000001???????????????????: _e_3923 = \alu_res ;
            25'b0000001??????????????????: _e_3923 = \lsu_res ;
            25'b00000001?????????????????: _e_3923 = \lsu2_res ;
            25'b000000001????????????????: _e_3923 = \gpi_res ;
            25'b0000000001???????????????: _e_3923 = \uart_in_res ;
            25'b00000000001??????????????: _e_3923 = \cmp_res ;
            25'b000000000001?????????????: _e_3923 = \cmpz_res ;
            25'b0000000000001????????????: _e_3923 = \lalu_res ;
            25'b00000000000001???????????: _e_3923 = \mul_res ;
            25'b000000000000001??????????: _e_3923 = _e_3968;
            25'b0000000000000001?????????: _e_3923 = _e_3971;
            25'b00000000000000001????????: _e_3923 = \spi_in_res ;
            25'b000000000000000001???????: _e_3923 = \div_res ;
            25'b0000000000000000001??????: _e_3923 = \xorshift_res ;
            25'b00000000000000000001?????: _e_3923 = \mac_res ;
            25'b000000000000000000001????: _e_3923 = \sel_res ;
            25'b0000000000000000000001???: _e_3923 = \mda_res ;
            25'b00000000000000000000001??: _e_3923 = \tanh_res ;
            25'b000000000000000000000001?: _e_3923 = \stack_res ;
            25'b0000000000000000000000001: _e_3923 = \bit_res ;
            25'b?: _e_3923 = 33'dx;
        endcase
    end
    assign _e_3992 = {1'd0, 32'bX};
    assign \bus1_val_opt  = _e_3919 ? _e_3923 : _e_3992;
    assign _e_3996 = \insn [97:49];
    assign _e_3995 = _e_3996[11:1];
    (* src = "src/tta.spade:547,14" *)
    \tta::tta::decode_move  decode_move_0(.dst_i(_e_3995), .v_i(\bus0_val_opt ), .output__(\m0 ));
    assign _e_4002 = \insn [48:0];
    assign _e_4001 = _e_4002[11:1];
    (* src = "src/tta.spade:548,14" *)
    \tta::tta::decode_move  decode_move_1(.dst_i(_e_4001), .v_i(\bus1_val_opt ), .output__(\m1 ));
    (* src = "src/tta.spade:552,17" *)
    \tta::regfile::route_rf_one  route_rf_one_0(.m_i(\m0 ), .output__(\rf_w0 ));
    (* src = "src/tta.spade:553,17" *)
    \tta::regfile::route_rf_one  route_rf_one_1(.m_i(\m1 ), .output__(\rf_w1 ));
    (* src = "src/tta.spade:555,20" *)
    \tta::alu::pick_alu_seta  pick_alu_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\alu_op_a ));
    (* src = "src/tta.spade:556,20" *)
    \tta::alu::pick_alu_trig  pick_alu_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\alu_trig ));
    (* src = "src/tta.spade:558,20" *)
    \tta::bit::pick_bit_seta  pick_bit_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\bit_op_a ));
    (* src = "src/tta.spade:559,20" *)
    \tta::bit::pick_bit_trig  pick_bit_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\bit_trig ));
    (* src = "src/tta.spade:561,21" *)
    \tta::lalu::pick_lalu_seta  pick_lalu_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lalu_op_a ));
    (* src = "src/tta.spade:562,21" *)
    \tta::lalu::pick_lalu_trig  pick_lalu_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lalu_trig ));
    (* src = "src/tta.spade:564,24" *)
    \tta::mul_shiftadd::pick_mul_seta  pick_mul_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mul_set_addr ));
    (* src = "src/tta.spade:565,20" *)
    \tta::mul_shiftadd::pick_mul_trig  pick_mul_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mul_trig ));
    (* src = "src/tta.spade:567,24" *)
    \tta::div_shiftsub::pick_div_seta  pick_div_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\div_set_addr ));
    (* src = "src/tta.spade:568,20" *)
    \tta::div_shiftsub::pick_div_trig  pick_div_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\div_trig ));
    (* src = "src/tta.spade:570,20" *)
    \tta::cmp::pick_cmp_seta  pick_cmp_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\cmp_op_a ));
    (* src = "src/tta.spade:571,20" *)
    \tta::cmp::pick_cmp_trig  pick_cmp_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\cmp_trig ));
    (* src = "src/tta.spade:573,21" *)
    \tta::cmpz::pick_cmpz_trig  pick_cmpz_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\cmpz_trig ));
    (* src = "src/tta.spade:575,25" *)
    \tta::pc::pick_pc_jump  pick_pc_jump_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\pc_jump_final ));
    (* src = "src/tta.spade:577,21" *)
    \tta::bt::pick_bt_target  pick_bt_target_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\bt_target ));
    (* src = "src/tta.spade:578,19" *)
    \tta::bt::pick_bt_trig  pick_bt_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\bt_trig ));
    (* src = "src/tta.spade:580,24" *)
    \tta::lsu::pick_lsu_seta  pick_lsu_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu_set_addr ));
    (* src = "src/tta.spade:581,25" *)
    \tta::lsu::pick_lsu_loadtrig  pick_lsu_loadtrig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu_load_trig ));
    (* src = "src/tta.spade:582,26" *)
    \tta::lsu::pick_lsu_storetrig  pick_lsu_storetrig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu_store_trig ));
    (* src = "src/tta.spade:584,25" *)
    \tta::lsu::pick_lsu2_seta  pick_lsu2_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu2_set_addr ));
    (* src = "src/tta.spade:585,26" *)
    \tta::lsu::pick_lsu2_loadtrig  pick_lsu2_loadtrig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu2_load_trig ));
    (* src = "src/tta.spade:586,27" *)
    \tta::lsu::pick_lsu2_storetrig  pick_lsu2_storetrig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\lsu2_store_trig ));
    (* src = "src/tta.spade:588,25" *)
    \tta::xorshift::pick_xorshift_trig  pick_xorshift_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\xorshift_trig ));
    (* src = "src/tta.spade:590,24" *)
    \tta::mac::pick_mac_seta  pick_mac_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mac_set_addr ));
    (* src = "src/tta.spade:591,20" *)
    \tta::mac::pick_mac_trig  pick_mac_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mac_trig ));
    (* src = "src/tta.spade:592,21" *)
    \tta::mac::pick_mac_clear  pick_mac_clear_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mac_clear ));
    (* src = "src/tta.spade:594,20" *)
    \tta::sel::pick_sel_cond  pick_sel_cond_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\sel_cond ));
    (* src = "src/tta.spade:595,20" *)
    \tta::sel::pick_sel_seta  pick_sel_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\sel_seta ));
    (* src = "src/tta.spade:596,21" *)
    \tta::sel::pick_sel_trigb  pick_sel_trigb_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\sel_trigb ));
    (* src = "src/tta.spade:598,20" *)
    \tta::modadd::pick_base  pick_base_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mda_base ));
    (* src = "src/tta.spade:599,20" *)
    \tta::modadd::pick_mask  pick_mask_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mda_mask ));
    (* src = "src/tta.spade:600,19" *)
    \tta::modadd::pick_ptr  pick_ptr_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mda_ptr ));
    (* src = "src/tta.spade:601,20" *)
    \tta::modadd::pick_trig  pick_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\mda_trig ));
    (* src = "src/tta.spade:603,21" *)
    \tta::tanh::pick_trig  pick_trig_1(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\tanh_trig ));
    (* src = "src/tta.spade:605,25" *)
    \tta::stack_lsu::pick_seta  pick_seta_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\stack_setaddr ));
    (* src = "src/tta.spade:606,22" *)
    \tta::stack_lsu::pick_push_trig  pick_push_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\stack_push ));
    (* src = "src/tta.spade:607,21" *)
    \tta::stack_lsu::pick_pop_trig  pick_pop_trig_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\stack_pop ));
    (* src = "src/tta.spade:609,20" *)
    \tta::gpo::pick_gpo16  pick_gpo16_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\gpo_trig ));
    (* src = "src/tta.spade:611,25" *)
    \tta::spi::pick_spi_out8  pick_spi_out8_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\spi_out8_trig ));
    (* src = "src/tta.spade:612,26" *)
    \tta::spi::pick_spi_inpop  pick_spi_inpop_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\spi_inpop_trig ));
    (* src = "src/tta.spade:614,26" *)
    \tta::uart_in::pick_uart_out8  pick_uart_out8_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\uart_out8_trig ));
    (* src = "src/tta.spade:615,27" *)
    \tta::uart_in::pick_uart_inpop  pick_uart_inpop_0(.m0_i(\m0 ), .m1_i(\m1 ), .output__(\uart_inpop_trig ));
    assign \pc_jump_comb  = \pc_jump_final ;
    assign \rd0  = \registry [63:32];
    assign \rd1  = \registry [31:0];
    assign _e_4202 = {1'd1, \insn };
    assign _e_4188 = {\pc_val , \alu_op_a , \alu_trig , \alu_res , \pc_jump_final , \rf_w0 , \rf_w1 , \rd0 , \rd1 , \lsu_res , \lsu_set_addr , \lsu_store_trig , \lsu_load_trig , _e_4202, \gpo_res };
    assign output__ = _e_4188;
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
    logic[63:0] _e_4207;
    (* src = "src/fifo.spade:14,5" *)
    logic[73:0] _e_4206;
    localparam[7:0] _e_4208 = 0;
    localparam[7:0] _e_4209 = 0;
    localparam[7:0] _e_4210 = 0;
    localparam[7:0] _e_4211 = 0;
    localparam[7:0] _e_4212 = 0;
    localparam[7:0] _e_4213 = 0;
    localparam[7:0] _e_4214 = 0;
    localparam[7:0] _e_4215 = 0;
    assign _e_4207 = {_e_4215, _e_4214, _e_4213, _e_4212, _e_4211, _e_4210, _e_4209, _e_4208};
    localparam[2:0] _e_4216 = 0;
    localparam[2:0] _e_4217 = 0;
    localparam[3:0] _e_4218 = 0;
    assign _e_4206 = {_e_4207, _e_4216, _e_4217, _e_4218};
    assign output__ = _e_4206;
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
    logic _e_9171;
    (* src = "src/fifo.spade:20,20" *)
    logic[7:0] _e_4225;
    (* src = "src/fifo.spade:20,28" *)
    logic[7:0] _e_4228;
    (* src = "src/fifo.spade:20,36" *)
    logic[7:0] _e_4231;
    (* src = "src/fifo.spade:20,44" *)
    logic[7:0] _e_4234;
    (* src = "src/fifo.spade:20,52" *)
    logic[7:0] _e_4237;
    (* src = "src/fifo.spade:20,60" *)
    logic[7:0] _e_4240;
    (* src = "src/fifo.spade:20,68" *)
    logic[7:0] _e_4243;
    (* src = "src/fifo.spade:20,14" *)
    logic[63:0] _e_4223;
    logic _e_9173;
    (* src = "src/fifo.spade:21,15" *)
    logic[7:0] _e_4248;
    (* src = "src/fifo.spade:21,28" *)
    logic[7:0] _e_4252;
    (* src = "src/fifo.spade:21,36" *)
    logic[7:0] _e_4255;
    (* src = "src/fifo.spade:21,44" *)
    logic[7:0] _e_4258;
    (* src = "src/fifo.spade:21,52" *)
    logic[7:0] _e_4261;
    (* src = "src/fifo.spade:21,60" *)
    logic[7:0] _e_4264;
    (* src = "src/fifo.spade:21,68" *)
    logic[7:0] _e_4267;
    (* src = "src/fifo.spade:21,14" *)
    logic[63:0] _e_4247;
    logic _e_9175;
    (* src = "src/fifo.spade:22,15" *)
    logic[7:0] _e_4272;
    (* src = "src/fifo.spade:22,23" *)
    logic[7:0] _e_4275;
    (* src = "src/fifo.spade:22,36" *)
    logic[7:0] _e_4279;
    (* src = "src/fifo.spade:22,44" *)
    logic[7:0] _e_4282;
    (* src = "src/fifo.spade:22,52" *)
    logic[7:0] _e_4285;
    (* src = "src/fifo.spade:22,60" *)
    logic[7:0] _e_4288;
    (* src = "src/fifo.spade:22,68" *)
    logic[7:0] _e_4291;
    (* src = "src/fifo.spade:22,14" *)
    logic[63:0] _e_4271;
    logic _e_9177;
    (* src = "src/fifo.spade:23,15" *)
    logic[7:0] _e_4296;
    (* src = "src/fifo.spade:23,23" *)
    logic[7:0] _e_4299;
    (* src = "src/fifo.spade:23,31" *)
    logic[7:0] _e_4302;
    (* src = "src/fifo.spade:23,44" *)
    logic[7:0] _e_4306;
    (* src = "src/fifo.spade:23,52" *)
    logic[7:0] _e_4309;
    (* src = "src/fifo.spade:23,60" *)
    logic[7:0] _e_4312;
    (* src = "src/fifo.spade:23,68" *)
    logic[7:0] _e_4315;
    (* src = "src/fifo.spade:23,14" *)
    logic[63:0] _e_4295;
    logic _e_9179;
    (* src = "src/fifo.spade:24,15" *)
    logic[7:0] _e_4320;
    (* src = "src/fifo.spade:24,23" *)
    logic[7:0] _e_4323;
    (* src = "src/fifo.spade:24,31" *)
    logic[7:0] _e_4326;
    (* src = "src/fifo.spade:24,39" *)
    logic[7:0] _e_4329;
    (* src = "src/fifo.spade:24,52" *)
    logic[7:0] _e_4333;
    (* src = "src/fifo.spade:24,60" *)
    logic[7:0] _e_4336;
    (* src = "src/fifo.spade:24,68" *)
    logic[7:0] _e_4339;
    (* src = "src/fifo.spade:24,14" *)
    logic[63:0] _e_4319;
    logic _e_9181;
    (* src = "src/fifo.spade:25,15" *)
    logic[7:0] _e_4344;
    (* src = "src/fifo.spade:25,23" *)
    logic[7:0] _e_4347;
    (* src = "src/fifo.spade:25,31" *)
    logic[7:0] _e_4350;
    (* src = "src/fifo.spade:25,39" *)
    logic[7:0] _e_4353;
    (* src = "src/fifo.spade:25,47" *)
    logic[7:0] _e_4356;
    (* src = "src/fifo.spade:25,60" *)
    logic[7:0] _e_4360;
    (* src = "src/fifo.spade:25,68" *)
    logic[7:0] _e_4363;
    (* src = "src/fifo.spade:25,14" *)
    logic[63:0] _e_4343;
    logic _e_9183;
    (* src = "src/fifo.spade:26,15" *)
    logic[7:0] _e_4368;
    (* src = "src/fifo.spade:26,23" *)
    logic[7:0] _e_4371;
    (* src = "src/fifo.spade:26,31" *)
    logic[7:0] _e_4374;
    (* src = "src/fifo.spade:26,39" *)
    logic[7:0] _e_4377;
    (* src = "src/fifo.spade:26,47" *)
    logic[7:0] _e_4380;
    (* src = "src/fifo.spade:26,55" *)
    logic[7:0] _e_4383;
    (* src = "src/fifo.spade:26,68" *)
    logic[7:0] _e_4387;
    (* src = "src/fifo.spade:26,14" *)
    logic[63:0] _e_4367;
    logic _e_9185;
    (* src = "src/fifo.spade:27,15" *)
    logic[7:0] _e_4392;
    (* src = "src/fifo.spade:27,23" *)
    logic[7:0] _e_4395;
    (* src = "src/fifo.spade:27,31" *)
    logic[7:0] _e_4398;
    (* src = "src/fifo.spade:27,39" *)
    logic[7:0] _e_4401;
    (* src = "src/fifo.spade:27,47" *)
    logic[7:0] _e_4404;
    (* src = "src/fifo.spade:27,55" *)
    logic[7:0] _e_4407;
    (* src = "src/fifo.spade:27,63" *)
    logic[7:0] _e_4410;
    (* src = "src/fifo.spade:27,14" *)
    logic[63:0] _e_4391;
    (* src = "src/fifo.spade:19,5" *)
    logic[63:0] _e_4220;
    localparam[2:0] _e_9172 = 0;
    assign _e_9171 = \idx  == _e_9172;
    localparam[2:0] _e_4227 = 1;
    assign _e_4225 = \arr [_e_4227 * 8+:8];
    localparam[2:0] _e_4230 = 2;
    assign _e_4228 = \arr [_e_4230 * 8+:8];
    localparam[2:0] _e_4233 = 3;
    assign _e_4231 = \arr [_e_4233 * 8+:8];
    localparam[2:0] _e_4236 = 4;
    assign _e_4234 = \arr [_e_4236 * 8+:8];
    localparam[2:0] _e_4239 = 5;
    assign _e_4237 = \arr [_e_4239 * 8+:8];
    localparam[2:0] _e_4242 = 6;
    assign _e_4240 = \arr [_e_4242 * 8+:8];
    localparam[2:0] _e_4245 = 7;
    assign _e_4243 = \arr [_e_4245 * 8+:8];
    assign _e_4223 = {_e_4243, _e_4240, _e_4237, _e_4234, _e_4231, _e_4228, _e_4225, \val };
    localparam[2:0] _e_9174 = 1;
    assign _e_9173 = \idx  == _e_9174;
    localparam[2:0] _e_4250 = 0;
    assign _e_4248 = \arr [_e_4250 * 8+:8];
    localparam[2:0] _e_4254 = 2;
    assign _e_4252 = \arr [_e_4254 * 8+:8];
    localparam[2:0] _e_4257 = 3;
    assign _e_4255 = \arr [_e_4257 * 8+:8];
    localparam[2:0] _e_4260 = 4;
    assign _e_4258 = \arr [_e_4260 * 8+:8];
    localparam[2:0] _e_4263 = 5;
    assign _e_4261 = \arr [_e_4263 * 8+:8];
    localparam[2:0] _e_4266 = 6;
    assign _e_4264 = \arr [_e_4266 * 8+:8];
    localparam[2:0] _e_4269 = 7;
    assign _e_4267 = \arr [_e_4269 * 8+:8];
    assign _e_4247 = {_e_4267, _e_4264, _e_4261, _e_4258, _e_4255, _e_4252, \val , _e_4248};
    localparam[2:0] _e_9176 = 2;
    assign _e_9175 = \idx  == _e_9176;
    localparam[2:0] _e_4274 = 0;
    assign _e_4272 = \arr [_e_4274 * 8+:8];
    localparam[2:0] _e_4277 = 1;
    assign _e_4275 = \arr [_e_4277 * 8+:8];
    localparam[2:0] _e_4281 = 3;
    assign _e_4279 = \arr [_e_4281 * 8+:8];
    localparam[2:0] _e_4284 = 4;
    assign _e_4282 = \arr [_e_4284 * 8+:8];
    localparam[2:0] _e_4287 = 5;
    assign _e_4285 = \arr [_e_4287 * 8+:8];
    localparam[2:0] _e_4290 = 6;
    assign _e_4288 = \arr [_e_4290 * 8+:8];
    localparam[2:0] _e_4293 = 7;
    assign _e_4291 = \arr [_e_4293 * 8+:8];
    assign _e_4271 = {_e_4291, _e_4288, _e_4285, _e_4282, _e_4279, \val , _e_4275, _e_4272};
    localparam[2:0] _e_9178 = 3;
    assign _e_9177 = \idx  == _e_9178;
    localparam[2:0] _e_4298 = 0;
    assign _e_4296 = \arr [_e_4298 * 8+:8];
    localparam[2:0] _e_4301 = 1;
    assign _e_4299 = \arr [_e_4301 * 8+:8];
    localparam[2:0] _e_4304 = 2;
    assign _e_4302 = \arr [_e_4304 * 8+:8];
    localparam[2:0] _e_4308 = 4;
    assign _e_4306 = \arr [_e_4308 * 8+:8];
    localparam[2:0] _e_4311 = 5;
    assign _e_4309 = \arr [_e_4311 * 8+:8];
    localparam[2:0] _e_4314 = 6;
    assign _e_4312 = \arr [_e_4314 * 8+:8];
    localparam[2:0] _e_4317 = 7;
    assign _e_4315 = \arr [_e_4317 * 8+:8];
    assign _e_4295 = {_e_4315, _e_4312, _e_4309, _e_4306, \val , _e_4302, _e_4299, _e_4296};
    localparam[2:0] _e_9180 = 4;
    assign _e_9179 = \idx  == _e_9180;
    localparam[2:0] _e_4322 = 0;
    assign _e_4320 = \arr [_e_4322 * 8+:8];
    localparam[2:0] _e_4325 = 1;
    assign _e_4323 = \arr [_e_4325 * 8+:8];
    localparam[2:0] _e_4328 = 2;
    assign _e_4326 = \arr [_e_4328 * 8+:8];
    localparam[2:0] _e_4331 = 3;
    assign _e_4329 = \arr [_e_4331 * 8+:8];
    localparam[2:0] _e_4335 = 5;
    assign _e_4333 = \arr [_e_4335 * 8+:8];
    localparam[2:0] _e_4338 = 6;
    assign _e_4336 = \arr [_e_4338 * 8+:8];
    localparam[2:0] _e_4341 = 7;
    assign _e_4339 = \arr [_e_4341 * 8+:8];
    assign _e_4319 = {_e_4339, _e_4336, _e_4333, \val , _e_4329, _e_4326, _e_4323, _e_4320};
    localparam[2:0] _e_9182 = 5;
    assign _e_9181 = \idx  == _e_9182;
    localparam[2:0] _e_4346 = 0;
    assign _e_4344 = \arr [_e_4346 * 8+:8];
    localparam[2:0] _e_4349 = 1;
    assign _e_4347 = \arr [_e_4349 * 8+:8];
    localparam[2:0] _e_4352 = 2;
    assign _e_4350 = \arr [_e_4352 * 8+:8];
    localparam[2:0] _e_4355 = 3;
    assign _e_4353 = \arr [_e_4355 * 8+:8];
    localparam[2:0] _e_4358 = 4;
    assign _e_4356 = \arr [_e_4358 * 8+:8];
    localparam[2:0] _e_4362 = 6;
    assign _e_4360 = \arr [_e_4362 * 8+:8];
    localparam[2:0] _e_4365 = 7;
    assign _e_4363 = \arr [_e_4365 * 8+:8];
    assign _e_4343 = {_e_4363, _e_4360, \val , _e_4356, _e_4353, _e_4350, _e_4347, _e_4344};
    localparam[2:0] _e_9184 = 6;
    assign _e_9183 = \idx  == _e_9184;
    localparam[2:0] _e_4370 = 0;
    assign _e_4368 = \arr [_e_4370 * 8+:8];
    localparam[2:0] _e_4373 = 1;
    assign _e_4371 = \arr [_e_4373 * 8+:8];
    localparam[2:0] _e_4376 = 2;
    assign _e_4374 = \arr [_e_4376 * 8+:8];
    localparam[2:0] _e_4379 = 3;
    assign _e_4377 = \arr [_e_4379 * 8+:8];
    localparam[2:0] _e_4382 = 4;
    assign _e_4380 = \arr [_e_4382 * 8+:8];
    localparam[2:0] _e_4385 = 5;
    assign _e_4383 = \arr [_e_4385 * 8+:8];
    localparam[2:0] _e_4389 = 7;
    assign _e_4387 = \arr [_e_4389 * 8+:8];
    assign _e_4367 = {_e_4387, \val , _e_4383, _e_4380, _e_4377, _e_4374, _e_4371, _e_4368};
    localparam[2:0] _e_9186 = 7;
    assign _e_9185 = \idx  == _e_9186;
    localparam[2:0] _e_4394 = 0;
    assign _e_4392 = \arr [_e_4394 * 8+:8];
    localparam[2:0] _e_4397 = 1;
    assign _e_4395 = \arr [_e_4397 * 8+:8];
    localparam[2:0] _e_4400 = 2;
    assign _e_4398 = \arr [_e_4400 * 8+:8];
    localparam[2:0] _e_4403 = 3;
    assign _e_4401 = \arr [_e_4403 * 8+:8];
    localparam[2:0] _e_4406 = 4;
    assign _e_4404 = \arr [_e_4406 * 8+:8];
    localparam[2:0] _e_4409 = 5;
    assign _e_4407 = \arr [_e_4409 * 8+:8];
    localparam[2:0] _e_4412 = 6;
    assign _e_4410 = \arr [_e_4412 * 8+:8];
    assign _e_4391 = {\val , _e_4410, _e_4407, _e_4404, _e_4401, _e_4398, _e_4395, _e_4392};
    always_comb begin
        priority casez ({_e_9171, _e_9173, _e_9175, _e_9177, _e_9179, _e_9181, _e_9183, _e_9185})
            8'b1???????: _e_4220 = _e_4223;
            8'b01??????: _e_4220 = _e_4247;
            8'b001?????: _e_4220 = _e_4271;
            8'b0001????: _e_4220 = _e_4295;
            8'b00001???: _e_4220 = _e_4319;
            8'b000001??: _e_4220 = _e_4343;
            8'b0000001?: _e_4220 = _e_4367;
            8'b00000001: _e_4220 = _e_4391;
            8'b?: _e_4220 = 64'dx;
        endcase
    end
    assign output__ = _e_4220;
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
    logic[73:0] _e_4418;
    (* src = "src/fifo.spade:46,23" *)
    logic[3:0] _e_4421;
    (* src = "src/fifo.spade:46,23" *)
    logic \is_full ;
    (* src = "src/fifo.spade:47,24" *)
    logic[3:0] _e_4426;
    (* src = "src/fifo.spade:47,24" *)
    logic \is_empty ;
    (* src = "src/fifo.spade:52,13" *)
    logic[7:0] \_ ;
    logic _e_9188;
    logic _e_9190;
    (* src = "src/fifo.spade:52,24" *)
    logic _e_4435;
    (* src = "src/fifo.spade:52,24" *)
    logic _e_4434;
    logic _e_9192;
    (* src = "src/fifo.spade:51,23" *)
    logic \do_push ;
    (* src = "src/fifo.spade:57,29" *)
    logic _e_4443;
    (* src = "src/fifo.spade:57,22" *)
    logic \do_pop ;
    (* src = "src/fifo.spade:61,41" *)
    logic[2:0] _e_4451;
    (* src = "src/fifo.spade:61,41" *)
    logic[3:0] _e_4450;
    (* src = "src/fifo.spade:61,35" *)
    logic[2:0] _e_4449;
    (* src = "src/fifo.spade:61,63" *)
    logic[2:0] _e_4455;
    (* src = "src/fifo.spade:61,22" *)
    logic[2:0] \next_w ;
    (* src = "src/fifo.spade:62,41" *)
    logic[2:0] _e_4463;
    (* src = "src/fifo.spade:62,41" *)
    logic[3:0] _e_4462;
    (* src = "src/fifo.spade:62,35" *)
    logic[2:0] _e_4461;
    (* src = "src/fifo.spade:62,63" *)
    logic[2:0] _e_4467;
    (* src = "src/fifo.spade:62,22" *)
    logic[2:0] \next_r ;
    (* src = "src/fifo.spade:64,32" *)
    logic[1:0] _e_4471;
    (* src = "src/fifo.spade:65,13" *)
    logic[1:0] _e_4476;
    (* src = "src/fifo.spade:65,13" *)
    logic _e_4474;
    (* src = "src/fifo.spade:65,13" *)
    logic _e_4475;
    logic _e_9195;
    logic _e_9196;
    (* src = "src/fifo.spade:65,36" *)
    logic[3:0] _e_4479;
    (* src = "src/fifo.spade:65,36" *)
    logic[4:0] _e_4478;
    (* src = "src/fifo.spade:65,30" *)
    logic[3:0] _e_4477;
    (* src = "src/fifo.spade:66,13" *)
    logic[1:0] _e_4484;
    (* src = "src/fifo.spade:66,13" *)
    logic _e_4482;
    (* src = "src/fifo.spade:66,13" *)
    logic _e_4483;
    logic _e_9198;
    logic _e_9200;
    (* src = "src/fifo.spade:66,36" *)
    logic[3:0] _e_4487;
    (* src = "src/fifo.spade:66,36" *)
    logic[4:0] _e_4486;
    (* src = "src/fifo.spade:66,30" *)
    logic[3:0] _e_4485;
    (* src = "src/fifo.spade:67,13" *)
    logic[1:0] __n1;
    (* src = "src/fifo.spade:67,18" *)
    logic[3:0] _e_4491;
    (* src = "src/fifo.spade:64,26" *)
    logic[3:0] \next_count ;
    (* src = "src/fifo.spade:72,13" *)
    logic[7:0] \val ;
    logic _e_9203;
    logic _e_9205;
    (* src = "src/fifo.spade:72,47" *)
    logic[63:0] _e_4502;
    (* src = "src/fifo.spade:72,54" *)
    logic[2:0] _e_4504;
    (* src = "src/fifo.spade:72,39" *)
    logic[63:0] _e_4501;
    (* src = "src/fifo.spade:72,77" *)
    logic[63:0] _e_4508;
    (* src = "src/fifo.spade:72,26" *)
    logic[63:0] _e_4498;
    logic _e_9207;
    (* src = "src/fifo.spade:73,21" *)
    logic[63:0] _e_4511;
    (* src = "src/fifo.spade:71,24" *)
    logic[63:0] \next_mem ;
    (* src = "src/fifo.spade:76,9" *)
    logic[73:0] _e_4514;
    (* src = "src/fifo.spade:45,14" *)
    reg[73:0] \s ;
    (* src = "src/fifo.spade:80,17" *)
    logic[3:0] _e_4520;
    (* src = "src/fifo.spade:80,17" *)
    logic \empty ;
    (* src = "src/fifo.spade:81,17" *)
    logic[3:0] _e_4525;
    (* src = "src/fifo.spade:81,17" *)
    logic \full ;
    (* src = "src/fifo.spade:84,22" *)
    logic _e_4530;
    (* src = "src/fifo.spade:87,25" *)
    logic[2:0] _e_4534;
    (* src = "src/fifo.spade:88,13" *)
    logic[2:0] _e_4536;
    logic _e_9208;
    (* src = "src/fifo.spade:88,18" *)
    logic[63:0] _e_4538;
    (* src = "src/fifo.spade:88,18" *)
    logic[7:0] _e_4537;
    (* src = "src/fifo.spade:88,28" *)
    logic[2:0] _e_4541;
    logic _e_9210;
    (* src = "src/fifo.spade:88,33" *)
    logic[63:0] _e_4543;
    (* src = "src/fifo.spade:88,33" *)
    logic[7:0] _e_4542;
    (* src = "src/fifo.spade:88,43" *)
    logic[2:0] _e_4546;
    logic _e_9212;
    (* src = "src/fifo.spade:88,48" *)
    logic[63:0] _e_4548;
    (* src = "src/fifo.spade:88,48" *)
    logic[7:0] _e_4547;
    (* src = "src/fifo.spade:88,58" *)
    logic[2:0] _e_4551;
    logic _e_9214;
    (* src = "src/fifo.spade:88,63" *)
    logic[63:0] _e_4553;
    (* src = "src/fifo.spade:88,63" *)
    logic[7:0] _e_4552;
    (* src = "src/fifo.spade:89,13" *)
    logic[2:0] _e_4556;
    logic _e_9216;
    (* src = "src/fifo.spade:89,18" *)
    logic[63:0] _e_4558;
    (* src = "src/fifo.spade:89,18" *)
    logic[7:0] _e_4557;
    (* src = "src/fifo.spade:89,28" *)
    logic[2:0] _e_4561;
    logic _e_9218;
    (* src = "src/fifo.spade:89,33" *)
    logic[63:0] _e_4563;
    (* src = "src/fifo.spade:89,33" *)
    logic[7:0] _e_4562;
    (* src = "src/fifo.spade:89,43" *)
    logic[2:0] _e_4566;
    logic _e_9220;
    (* src = "src/fifo.spade:89,48" *)
    logic[63:0] _e_4568;
    (* src = "src/fifo.spade:89,48" *)
    logic[7:0] _e_4567;
    (* src = "src/fifo.spade:89,58" *)
    logic[2:0] _e_4571;
    logic _e_9222;
    (* src = "src/fifo.spade:89,63" *)
    logic[63:0] _e_4573;
    (* src = "src/fifo.spade:89,63" *)
    logic[7:0] _e_4572;
    (* src = "src/fifo.spade:87,19" *)
    logic[7:0] val_n1;
    (* src = "src/fifo.spade:91,9" *)
    logic[8:0] _e_4577;
    (* src = "src/fifo.spade:93,9" *)
    logic[8:0] _e_4580;
    (* src = "src/fifo.spade:84,19" *)
    logic[8:0] \out_val ;
    (* src = "src/fifo.spade:96,26" *)
    logic[3:0] _e_4585;
    (* src = "src/fifo.spade:96,5" *)
    logic[14:0] _e_4582;
    (* src = "src/fifo.spade:45,38" *)
    \tta::fifo::reset_fifo  reset_fifo_0(.output__(_e_4418));
    assign _e_4421 = \s [3:0];
    localparam[3:0] _e_4423 = 8;
    assign \is_full  = _e_4421 == _e_4423;
    assign _e_4426 = \s [3:0];
    localparam[3:0] _e_4428 = 0;
    assign \is_empty  = _e_4426 == _e_4428;
    assign \_  = \push [7:0];
    assign _e_9188 = \push [8] == 1'd1;
    localparam[0:0] _e_9189 = 1;
    assign _e_9190 = _e_9188 && _e_9189;
    assign _e_4435 = !\is_full ;
    assign _e_4434 = _e_4435 || \pop ;
    assign _e_9192 = \push [8] == 1'd0;
    localparam[0:0] _e_4439 = 0;
    always_comb begin
        priority casez ({_e_9190, _e_9192})
            2'b1?: \do_push  = _e_4434;
            2'b01: \do_push  = _e_4439;
            2'b?: \do_push  = 1'dx;
        endcase
    end
    assign _e_4443 = !\is_empty ;
    assign \do_pop  = \pop  && _e_4443;
    assign _e_4451 = \s [9:7];
    localparam[2:0] _e_4453 = 1;
    assign _e_4450 = _e_4451 + _e_4453;
    assign _e_4449 = _e_4450[2:0];
    assign _e_4455 = \s [9:7];
    assign \next_w  = \do_push  ? _e_4449 : _e_4455;
    assign _e_4463 = \s [6:4];
    localparam[2:0] _e_4465 = 1;
    assign _e_4462 = _e_4463 + _e_4465;
    assign _e_4461 = _e_4462[2:0];
    assign _e_4467 = \s [6:4];
    assign \next_r  = \do_pop  ? _e_4461 : _e_4467;
    assign _e_4471 = {\do_push , \do_pop };
    assign _e_4476 = _e_4471;
    assign _e_4474 = _e_4471[1];
    assign _e_4475 = _e_4471[0];
    assign _e_9195 = !_e_4475;
    assign _e_9196 = _e_4474 && _e_9195;
    assign _e_4479 = \s [3:0];
    localparam[3:0] _e_4481 = 1;
    assign _e_4478 = _e_4479 + _e_4481;
    assign _e_4477 = _e_4478[3:0];
    assign _e_4484 = _e_4471;
    assign _e_4482 = _e_4471[1];
    assign _e_4483 = _e_4471[0];
    assign _e_9198 = !_e_4482;
    assign _e_9200 = _e_9198 && _e_4483;
    assign _e_4487 = \s [3:0];
    localparam[3:0] _e_4489 = 1;
    assign _e_4486 = _e_4487 - _e_4489;
    assign _e_4485 = _e_4486[3:0];
    assign __n1 = _e_4471;
    localparam[0:0] _e_9201 = 1;
    assign _e_4491 = \s [3:0];
    always_comb begin
        priority casez ({_e_9196, _e_9200, _e_9201})
            3'b1??: \next_count  = _e_4477;
            3'b01?: \next_count  = _e_4485;
            3'b001: \next_count  = _e_4491;
            3'b?: \next_count  = 4'dx;
        endcase
    end
    assign \val  = \push [7:0];
    assign _e_9203 = \push [8] == 1'd1;
    localparam[0:0] _e_9204 = 1;
    assign _e_9205 = _e_9203 && _e_9204;
    assign _e_4502 = \s [73:10];
    assign _e_4504 = \s [9:7];
    (* src = "src/fifo.spade:72,39" *)
    \tta::fifo::set_mem  set_mem_0(.arr_i(_e_4502), .idx_i(_e_4504), .val_i(\val ), .output__(_e_4501));
    assign _e_4508 = \s [73:10];
    assign _e_4498 = \do_push  ? _e_4501 : _e_4508;
    assign _e_9207 = \push [8] == 1'd0;
    assign _e_4511 = \s [73:10];
    always_comb begin
        priority casez ({_e_9205, _e_9207})
            2'b1?: \next_mem  = _e_4498;
            2'b01: \next_mem  = _e_4511;
            2'b?: \next_mem  = 64'dx;
        endcase
    end
    assign _e_4514 = {\next_mem , \next_w , \next_r , \next_count };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s  <= _e_4418;
        end
        else begin
            \s  <= _e_4514;
        end
    end
    assign _e_4520 = \s [3:0];
    localparam[3:0] _e_4522 = 0;
    assign \empty  = _e_4520 == _e_4522;
    assign _e_4525 = \s [3:0];
    localparam[3:0] _e_4527 = 8;
    assign \full  = _e_4525 == _e_4527;
    assign _e_4530 = !\empty ;
    assign _e_4534 = \s [6:4];
    assign _e_4536 = _e_4534;
    localparam[2:0] _e_9209 = 0;
    assign _e_9208 = _e_4534 == _e_9209;
    assign _e_4538 = \s [73:10];
    localparam[2:0] _e_4540 = 0;
    assign _e_4537 = _e_4538[_e_4540 * 8+:8];
    assign _e_4541 = _e_4534;
    localparam[2:0] _e_9211 = 1;
    assign _e_9210 = _e_4534 == _e_9211;
    assign _e_4543 = \s [73:10];
    localparam[2:0] _e_4545 = 1;
    assign _e_4542 = _e_4543[_e_4545 * 8+:8];
    assign _e_4546 = _e_4534;
    localparam[2:0] _e_9213 = 2;
    assign _e_9212 = _e_4534 == _e_9213;
    assign _e_4548 = \s [73:10];
    localparam[2:0] _e_4550 = 2;
    assign _e_4547 = _e_4548[_e_4550 * 8+:8];
    assign _e_4551 = _e_4534;
    localparam[2:0] _e_9215 = 3;
    assign _e_9214 = _e_4534 == _e_9215;
    assign _e_4553 = \s [73:10];
    localparam[2:0] _e_4555 = 3;
    assign _e_4552 = _e_4553[_e_4555 * 8+:8];
    assign _e_4556 = _e_4534;
    localparam[2:0] _e_9217 = 4;
    assign _e_9216 = _e_4534 == _e_9217;
    assign _e_4558 = \s [73:10];
    localparam[2:0] _e_4560 = 4;
    assign _e_4557 = _e_4558[_e_4560 * 8+:8];
    assign _e_4561 = _e_4534;
    localparam[2:0] _e_9219 = 5;
    assign _e_9218 = _e_4534 == _e_9219;
    assign _e_4563 = \s [73:10];
    localparam[2:0] _e_4565 = 5;
    assign _e_4562 = _e_4563[_e_4565 * 8+:8];
    assign _e_4566 = _e_4534;
    localparam[2:0] _e_9221 = 6;
    assign _e_9220 = _e_4534 == _e_9221;
    assign _e_4568 = \s [73:10];
    localparam[2:0] _e_4570 = 6;
    assign _e_4567 = _e_4568[_e_4570 * 8+:8];
    assign _e_4571 = _e_4534;
    localparam[2:0] _e_9223 = 7;
    assign _e_9222 = _e_4534 == _e_9223;
    assign _e_4573 = \s [73:10];
    localparam[2:0] _e_4575 = 7;
    assign _e_4572 = _e_4573[_e_4575 * 8+:8];
    always_comb begin
        priority casez ({_e_9208, _e_9210, _e_9212, _e_9214, _e_9216, _e_9218, _e_9220, _e_9222})
            8'b1???????: val_n1 = _e_4537;
            8'b01??????: val_n1 = _e_4542;
            8'b001?????: val_n1 = _e_4547;
            8'b0001????: val_n1 = _e_4552;
            8'b00001???: val_n1 = _e_4557;
            8'b000001??: val_n1 = _e_4562;
            8'b0000001?: val_n1 = _e_4567;
            8'b00000001: val_n1 = _e_4572;
            8'b?: val_n1 = 8'dx;
        endcase
    end
    assign _e_4577 = {1'd1, val_n1};
    assign _e_4580 = {1'd0, 8'bX};
    assign \out_val  = _e_4530 ? _e_4577 : _e_4580;
    assign _e_4585 = \s [3:0];
    assign _e_4582 = {\full , \empty , _e_4585, \out_val };
    assign output__ = _e_4582;
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
    logic _e_9225;
    logic _e_9227;
    logic _e_9229;
    (* src = "src/lsu.spade:23,47" *)
    logic[31:0] _e_4593;
    (* src = "src/lsu.spade:23,14" *)
    reg[31:0] \addr_a ;
    (* src = "src/lsu.spade:29,9" *)
    logic[31:0] \b ;
    logic _e_9231;
    logic _e_9233;
    (* src = "src/lsu.spade:29,20" *)
    logic[32:0] _e_4604;
    logic _e_9235;
    logic[32:0] _e_4608;
    (* src = "src/lsu.spade:28,31" *)
    logic[32:0] \addr_calc ;
    (* src = "src/lsu.spade:34,41" *)
    logic[31:0] \_ ;
    logic _e_9237;
    logic _e_9239;
    logic _e_9241;
    (* src = "src/lsu.spade:34,22" *)
    logic \wren ;
    (* src = "src/lsu.spade:35,36" *)
    logic[31:0] \x ;
    logic _e_9243;
    logic _e_9245;
    logic _e_9247;
    (* src = "src/lsu.spade:35,17" *)
    logic[31:0] \wdata ;
    (* src = "src/lsu.spade:36,56" *)
    logic[15:0] _e_4631;
    (* src = "src/lsu.spade:36,17" *)
    logic[31:0] \rdata ;
    (* src = "src/lsu.spade:39,55" *)
    logic[65:0] _e_4641;
    (* src = "src/lsu.spade:40,9" *)
    logic[65:0] _e_4647;
    (* src = "src/lsu.spade:40,9" *)
    logic[32:0] _e_4645;
    (* src = "src/lsu.spade:40,10" *)
    logic[31:0] __n1;
    (* src = "src/lsu.spade:40,9" *)
    logic[32:0] _e_4646;
    logic _e_9250;
    logic _e_9252;
    logic _e_9254;
    logic _e_9255;
    (* src = "src/lsu.spade:41,9" *)
    logic[65:0] _e_4652;
    (* src = "src/lsu.spade:41,9" *)
    logic[32:0] __n2;
    (* src = "src/lsu.spade:41,9" *)
    logic[32:0] _e_4651;
    (* src = "src/lsu.spade:41,13" *)
    logic[31:0] __n3;
    logic _e_9259;
    logic _e_9261;
    logic _e_9262;
    (* src = "src/lsu.spade:42,9" *)
    logic[65:0] _e_4656;
    (* src = "src/lsu.spade:42,9" *)
    logic[32:0] _e_4654;
    (* src = "src/lsu.spade:42,9" *)
    logic[32:0] _e_4655;
    logic _e_9265;
    logic _e_9267;
    logic _e_9268;
    (* src = "src/lsu.spade:39,49" *)
    logic _e_4640;
    (* src = "src/lsu.spade:39,14" *)
    reg \ld_ready ;
    (* src = "src/lsu.spade:45,19" *)
    logic[32:0] _e_4661;
    (* src = "src/lsu.spade:45,40" *)
    logic[32:0] _e_4664;
    (* src = "src/lsu.spade:45,5" *)
    logic[32:0] _e_4658;
    localparam[31:0] _e_4592 = 32'd0;
    assign \v  = \set_addr_a [31:0];
    assign _e_9225 = \set_addr_a [32] == 1'd1;
    localparam[0:0] _e_9226 = 1;
    assign _e_9227 = _e_9225 && _e_9226;
    assign _e_9229 = \set_addr_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9227, _e_9229})
            2'b1?: _e_4593 = \v ;
            2'b01: _e_4593 = \addr_a ;
            2'b?: _e_4593 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \addr_a  <= _e_4592;
        end
        else begin
            \addr_a  <= _e_4593;
        end
    end
    assign \b  = \load_trig [31:0];
    assign _e_9231 = \load_trig [32] == 1'd1;
    localparam[0:0] _e_9232 = 1;
    assign _e_9233 = _e_9231 && _e_9232;
    assign _e_4604 = \addr_a  + \b ;
    assign _e_9235 = \load_trig [32] == 1'd0;
    assign _e_4608 = {1'b0, \addr_a };
    always_comb begin
        priority casez ({_e_9233, _e_9235})
            2'b1?: \addr_calc  = _e_4604;
            2'b01: \addr_calc  = _e_4608;
            2'b?: \addr_calc  = 33'dx;
        endcase
    end
    assign \_  = \store_trig [31:0];
    assign _e_9237 = \store_trig [32] == 1'd1;
    localparam[0:0] _e_9238 = 1;
    assign _e_9239 = _e_9237 && _e_9238;
    localparam[0:0] _e_4615 = 1;
    assign _e_9241 = \store_trig [32] == 1'd0;
    localparam[0:0] _e_4617 = 0;
    always_comb begin
        priority casez ({_e_9239, _e_9241})
            2'b1?: \wren  = _e_4615;
            2'b01: \wren  = _e_4617;
            2'b?: \wren  = 1'dx;
        endcase
    end
    assign \x  = \store_trig [31:0];
    assign _e_9243 = \store_trig [32] == 1'd1;
    localparam[0:0] _e_9244 = 1;
    assign _e_9245 = _e_9243 && _e_9244;
    assign _e_9247 = \store_trig [32] == 1'd0;
    localparam[31:0] _e_4625 = 32'd0;
    always_comb begin
        priority casez ({_e_9245, _e_9247})
            2'b1?: \wdata  = \x ;
            2'b01: \wdata  = _e_4625;
            2'b?: \wdata  = 32'dx;
        endcase
    end
    localparam[0:0] _e_4630 = 1;
    assign _e_4631 = \addr_calc [15:0];
    (* src = "src/lsu.spade:36,17" *)
    \tta::sram::sram_512x32  sram_512x32_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .en_i(_e_4630), .addr_i(_e_4631), .we_i(\wren ), .wdata_i(\wdata ), .output__(\rdata ));
    localparam[0:0] _e_4639 = 0;
    assign _e_4641 = {\load_trig , \store_trig };
    assign _e_4647 = _e_4641;
    assign _e_4645 = _e_4641[65:33];
    assign __n1 = _e_4645[31:0];
    assign _e_4646 = _e_4641[32:0];
    assign _e_9250 = _e_4645[32] == 1'd1;
    localparam[0:0] _e_9251 = 1;
    assign _e_9252 = _e_9250 && _e_9251;
    assign _e_9254 = _e_4646[32] == 1'd0;
    assign _e_9255 = _e_9252 && _e_9254;
    localparam[0:0] _e_4648 = 1;
    assign _e_4652 = _e_4641;
    assign __n2 = _e_4641[65:33];
    assign _e_4651 = _e_4641[32:0];
    assign __n3 = _e_4651[31:0];
    localparam[0:0] _e_9257 = 1;
    assign _e_9259 = _e_4651[32] == 1'd1;
    localparam[0:0] _e_9260 = 1;
    assign _e_9261 = _e_9259 && _e_9260;
    assign _e_9262 = _e_9257 && _e_9261;
    localparam[0:0] _e_4653 = 0;
    assign _e_4656 = _e_4641;
    assign _e_4654 = _e_4641[65:33];
    assign _e_4655 = _e_4641[32:0];
    assign _e_9265 = _e_4654[32] == 1'd0;
    assign _e_9267 = _e_4655[32] == 1'd0;
    assign _e_9268 = _e_9265 && _e_9267;
    localparam[0:0] _e_4657 = 0;
    always_comb begin
        priority casez ({_e_9255, _e_9262, _e_9268})
            3'b1??: _e_4640 = _e_4648;
            3'b01?: _e_4640 = _e_4653;
            3'b001: _e_4640 = _e_4657;
            3'b?: _e_4640 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \ld_ready  <= _e_4639;
        end
        else begin
            \ld_ready  <= _e_4640;
        end
    end
    assign _e_4661 = {1'd1, \rdata };
    assign _e_4664 = {1'd0, 32'bX};
    assign _e_4658 = \ld_ready  ? _e_4661 : _e_4664;
    assign output__ = _e_4658;
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
    (* src = "src/lsu.spade:53,9" *)
    logic[42:0] _e_4669;
    (* src = "src/lsu.spade:53,14" *)
    logic[31:0] \x ;
    logic _e_9270;
    logic _e_9272;
    logic _e_9274;
    logic _e_9275;
    (* src = "src/lsu.spade:53,35" *)
    logic[32:0] _e_4671;
    (* src = "src/lsu.spade:54,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:55,13" *)
    logic[42:0] _e_4677;
    (* src = "src/lsu.spade:55,18" *)
    logic[31:0] x_n1;
    logic _e_9278;
    logic _e_9280;
    logic _e_9282;
    logic _e_9283;
    (* src = "src/lsu.spade:55,39" *)
    logic[32:0] _e_4679;
    (* src = "src/lsu.spade:56,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:56,18" *)
    logic[32:0] _e_4682;
    (* src = "src/lsu.spade:54,14" *)
    logic[32:0] _e_4674;
    (* src = "src/lsu.spade:52,5" *)
    logic[32:0] _e_4666;
    assign _e_4669 = \m1 [42:0];
    assign \x  = _e_4669[36:5];
    assign _e_9270 = \m1 [43] == 1'd1;
    assign _e_9272 = _e_4669[42:37] == 6'd4;
    localparam[0:0] _e_9273 = 1;
    assign _e_9274 = _e_9272 && _e_9273;
    assign _e_9275 = _e_9270 && _e_9274;
    assign _e_4671 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9276 = 1;
    assign _e_4677 = \m0 [42:0];
    assign x_n1 = _e_4677[36:5];
    assign _e_9278 = \m0 [43] == 1'd1;
    assign _e_9280 = _e_4677[42:37] == 6'd4;
    localparam[0:0] _e_9281 = 1;
    assign _e_9282 = _e_9280 && _e_9281;
    assign _e_9283 = _e_9278 && _e_9282;
    assign _e_4679 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9284 = 1;
    assign _e_4682 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9283, _e_9284})
            2'b1?: _e_4674 = _e_4679;
            2'b01: _e_4674 = _e_4682;
            2'b?: _e_4674 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9275, _e_9276})
            2'b1?: _e_4666 = _e_4671;
            2'b01: _e_4666 = _e_4674;
            2'b?: _e_4666 = 33'dx;
        endcase
    end
    assign output__ = _e_4666;
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
    (* src = "src/lsu.spade:63,9" *)
    logic[42:0] _e_4687;
    (* src = "src/lsu.spade:63,14" *)
    logic[31:0] \x ;
    logic _e_9286;
    logic _e_9288;
    logic _e_9290;
    logic _e_9291;
    (* src = "src/lsu.spade:63,40" *)
    logic[32:0] _e_4689;
    (* src = "src/lsu.spade:64,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:65,13" *)
    logic[42:0] _e_4695;
    (* src = "src/lsu.spade:65,18" *)
    logic[31:0] x_n1;
    logic _e_9294;
    logic _e_9296;
    logic _e_9298;
    logic _e_9299;
    (* src = "src/lsu.spade:65,44" *)
    logic[32:0] _e_4697;
    (* src = "src/lsu.spade:66,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:66,18" *)
    logic[32:0] _e_4700;
    (* src = "src/lsu.spade:64,14" *)
    logic[32:0] _e_4692;
    (* src = "src/lsu.spade:62,5" *)
    logic[32:0] _e_4684;
    assign _e_4687 = \m1 [42:0];
    assign \x  = _e_4687[36:5];
    assign _e_9286 = \m1 [43] == 1'd1;
    assign _e_9288 = _e_4687[42:37] == 6'd5;
    localparam[0:0] _e_9289 = 1;
    assign _e_9290 = _e_9288 && _e_9289;
    assign _e_9291 = _e_9286 && _e_9290;
    assign _e_4689 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9292 = 1;
    assign _e_4695 = \m0 [42:0];
    assign x_n1 = _e_4695[36:5];
    assign _e_9294 = \m0 [43] == 1'd1;
    assign _e_9296 = _e_4695[42:37] == 6'd5;
    localparam[0:0] _e_9297 = 1;
    assign _e_9298 = _e_9296 && _e_9297;
    assign _e_9299 = _e_9294 && _e_9298;
    assign _e_4697 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9300 = 1;
    assign _e_4700 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9299, _e_9300})
            2'b1?: _e_4692 = _e_4697;
            2'b01: _e_4692 = _e_4700;
            2'b?: _e_4692 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9291, _e_9292})
            2'b1?: _e_4684 = _e_4689;
            2'b01: _e_4684 = _e_4692;
            2'b?: _e_4684 = 33'dx;
        endcase
    end
    assign output__ = _e_4684;
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
    (* src = "src/lsu.spade:73,9" *)
    logic[42:0] _e_4705;
    (* src = "src/lsu.spade:73,14" *)
    logic[31:0] \x ;
    logic _e_9302;
    logic _e_9304;
    logic _e_9306;
    logic _e_9307;
    (* src = "src/lsu.spade:73,41" *)
    logic[32:0] _e_4707;
    (* src = "src/lsu.spade:74,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:75,13" *)
    logic[42:0] _e_4713;
    (* src = "src/lsu.spade:75,18" *)
    logic[31:0] x_n1;
    logic _e_9310;
    logic _e_9312;
    logic _e_9314;
    logic _e_9315;
    (* src = "src/lsu.spade:75,45" *)
    logic[32:0] _e_4715;
    (* src = "src/lsu.spade:76,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:76,18" *)
    logic[32:0] _e_4718;
    (* src = "src/lsu.spade:74,14" *)
    logic[32:0] _e_4710;
    (* src = "src/lsu.spade:72,5" *)
    logic[32:0] _e_4702;
    assign _e_4705 = \m1 [42:0];
    assign \x  = _e_4705[36:5];
    assign _e_9302 = \m1 [43] == 1'd1;
    assign _e_9304 = _e_4705[42:37] == 6'd6;
    localparam[0:0] _e_9305 = 1;
    assign _e_9306 = _e_9304 && _e_9305;
    assign _e_9307 = _e_9302 && _e_9306;
    assign _e_4707 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9308 = 1;
    assign _e_4713 = \m0 [42:0];
    assign x_n1 = _e_4713[36:5];
    assign _e_9310 = \m0 [43] == 1'd1;
    assign _e_9312 = _e_4713[42:37] == 6'd6;
    localparam[0:0] _e_9313 = 1;
    assign _e_9314 = _e_9312 && _e_9313;
    assign _e_9315 = _e_9310 && _e_9314;
    assign _e_4715 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9316 = 1;
    assign _e_4718 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9315, _e_9316})
            2'b1?: _e_4710 = _e_4715;
            2'b01: _e_4710 = _e_4718;
            2'b?: _e_4710 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9307, _e_9308})
            2'b1?: _e_4702 = _e_4707;
            2'b01: _e_4702 = _e_4710;
            2'b?: _e_4702 = 33'dx;
        endcase
    end
    assign output__ = _e_4702;
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
    (* src = "src/lsu.spade:84,9" *)
    logic[42:0] _e_4723;
    (* src = "src/lsu.spade:84,14" *)
    logic[31:0] \x ;
    logic _e_9318;
    logic _e_9320;
    logic _e_9322;
    logic _e_9323;
    (* src = "src/lsu.spade:84,36" *)
    logic[32:0] _e_4725;
    (* src = "src/lsu.spade:85,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:86,13" *)
    logic[42:0] _e_4731;
    (* src = "src/lsu.spade:86,18" *)
    logic[31:0] x_n1;
    logic _e_9326;
    logic _e_9328;
    logic _e_9330;
    logic _e_9331;
    (* src = "src/lsu.spade:86,40" *)
    logic[32:0] _e_4733;
    (* src = "src/lsu.spade:87,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:87,18" *)
    logic[32:0] _e_4736;
    (* src = "src/lsu.spade:85,14" *)
    logic[32:0] _e_4728;
    (* src = "src/lsu.spade:83,5" *)
    logic[32:0] _e_4720;
    assign _e_4723 = \m1 [42:0];
    assign \x  = _e_4723[36:5];
    assign _e_9318 = \m1 [43] == 1'd1;
    assign _e_9320 = _e_4723[42:37] == 6'd7;
    localparam[0:0] _e_9321 = 1;
    assign _e_9322 = _e_9320 && _e_9321;
    assign _e_9323 = _e_9318 && _e_9322;
    assign _e_4725 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9324 = 1;
    assign _e_4731 = \m0 [42:0];
    assign x_n1 = _e_4731[36:5];
    assign _e_9326 = \m0 [43] == 1'd1;
    assign _e_9328 = _e_4731[42:37] == 6'd7;
    localparam[0:0] _e_9329 = 1;
    assign _e_9330 = _e_9328 && _e_9329;
    assign _e_9331 = _e_9326 && _e_9330;
    assign _e_4733 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9332 = 1;
    assign _e_4736 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9331, _e_9332})
            2'b1?: _e_4728 = _e_4733;
            2'b01: _e_4728 = _e_4736;
            2'b?: _e_4728 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9323, _e_9324})
            2'b1?: _e_4720 = _e_4725;
            2'b01: _e_4720 = _e_4728;
            2'b?: _e_4720 = 33'dx;
        endcase
    end
    assign output__ = _e_4720;
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
    (* src = "src/lsu.spade:94,9" *)
    logic[42:0] _e_4741;
    (* src = "src/lsu.spade:94,14" *)
    logic[31:0] \x ;
    logic _e_9334;
    logic _e_9336;
    logic _e_9338;
    logic _e_9339;
    (* src = "src/lsu.spade:94,41" *)
    logic[32:0] _e_4743;
    (* src = "src/lsu.spade:95,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:96,13" *)
    logic[42:0] _e_4749;
    (* src = "src/lsu.spade:96,18" *)
    logic[31:0] x_n1;
    logic _e_9342;
    logic _e_9344;
    logic _e_9346;
    logic _e_9347;
    (* src = "src/lsu.spade:96,45" *)
    logic[32:0] _e_4751;
    (* src = "src/lsu.spade:97,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:97,18" *)
    logic[32:0] _e_4754;
    (* src = "src/lsu.spade:95,14" *)
    logic[32:0] _e_4746;
    (* src = "src/lsu.spade:93,5" *)
    logic[32:0] _e_4738;
    assign _e_4741 = \m1 [42:0];
    assign \x  = _e_4741[36:5];
    assign _e_9334 = \m1 [43] == 1'd1;
    assign _e_9336 = _e_4741[42:37] == 6'd8;
    localparam[0:0] _e_9337 = 1;
    assign _e_9338 = _e_9336 && _e_9337;
    assign _e_9339 = _e_9334 && _e_9338;
    assign _e_4743 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9340 = 1;
    assign _e_4749 = \m0 [42:0];
    assign x_n1 = _e_4749[36:5];
    assign _e_9342 = \m0 [43] == 1'd1;
    assign _e_9344 = _e_4749[42:37] == 6'd8;
    localparam[0:0] _e_9345 = 1;
    assign _e_9346 = _e_9344 && _e_9345;
    assign _e_9347 = _e_9342 && _e_9346;
    assign _e_4751 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9348 = 1;
    assign _e_4754 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9347, _e_9348})
            2'b1?: _e_4746 = _e_4751;
            2'b01: _e_4746 = _e_4754;
            2'b?: _e_4746 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9339, _e_9340})
            2'b1?: _e_4738 = _e_4743;
            2'b01: _e_4738 = _e_4746;
            2'b?: _e_4738 = 33'dx;
        endcase
    end
    assign output__ = _e_4738;
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
    (* src = "src/lsu.spade:104,9" *)
    logic[42:0] _e_4759;
    (* src = "src/lsu.spade:104,14" *)
    logic[31:0] \x ;
    logic _e_9350;
    logic _e_9352;
    logic _e_9354;
    logic _e_9355;
    (* src = "src/lsu.spade:104,42" *)
    logic[32:0] _e_4761;
    (* src = "src/lsu.spade:105,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:106,13" *)
    logic[42:0] _e_4767;
    (* src = "src/lsu.spade:106,18" *)
    logic[31:0] x_n1;
    logic _e_9358;
    logic _e_9360;
    logic _e_9362;
    logic _e_9363;
    (* src = "src/lsu.spade:106,46" *)
    logic[32:0] _e_4769;
    (* src = "src/lsu.spade:107,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:107,18" *)
    logic[32:0] _e_4772;
    (* src = "src/lsu.spade:105,14" *)
    logic[32:0] _e_4764;
    (* src = "src/lsu.spade:103,5" *)
    logic[32:0] _e_4756;
    assign _e_4759 = \m1 [42:0];
    assign \x  = _e_4759[36:5];
    assign _e_9350 = \m1 [43] == 1'd1;
    assign _e_9352 = _e_4759[42:37] == 6'd9;
    localparam[0:0] _e_9353 = 1;
    assign _e_9354 = _e_9352 && _e_9353;
    assign _e_9355 = _e_9350 && _e_9354;
    assign _e_4761 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9356 = 1;
    assign _e_4767 = \m0 [42:0];
    assign x_n1 = _e_4767[36:5];
    assign _e_9358 = \m0 [43] == 1'd1;
    assign _e_9360 = _e_4767[42:37] == 6'd9;
    localparam[0:0] _e_9361 = 1;
    assign _e_9362 = _e_9360 && _e_9361;
    assign _e_9363 = _e_9358 && _e_9362;
    assign _e_4769 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9364 = 1;
    assign _e_4772 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9363, _e_9364})
            2'b1?: _e_4764 = _e_4769;
            2'b01: _e_4764 = _e_4772;
            2'b?: _e_4764 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9355, _e_9356})
            2'b1?: _e_4756 = _e_4761;
            2'b01: _e_4756 = _e_4764;
            2'b?: _e_4756 = 33'dx;
        endcase
    end
    assign output__ = _e_4756;
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
    (* src = "src/parallel_rx.spade:28,14" *)
    reg[7:0] \data_sync ;
    (* src = "src/parallel_rx.spade:29,14" *)
    reg \strobe_sync ;
    (* src = "src/parallel_rx.spade:32,40" *)
    logic[8:0] _e_4797;
    (* src = "src/parallel_rx.spade:33,9" *)
    logic[8:0] _e_4801;
    (* src = "src/parallel_rx.spade:32,14" *)
    reg[8:0] \rx ;
    (* src = "src/parallel_rx.spade:38,24" *)
    logic _e_4806;
    (* src = "src/parallel_rx.spade:38,23" *)
    logic _e_4805;
    (* src = "src/parallel_rx.spade:38,23" *)
    logic \rising_edge ;
    (* src = "src/parallel_rx.spade:41,8" *)
    logic _e_4811;
    (* src = "src/parallel_rx.spade:42,14" *)
    logic[7:0] _e_4816;
    (* src = "src/parallel_rx.spade:42,9" *)
    logic[8:0] _e_4815;
    (* src = "src/parallel_rx.spade:44,9" *)
    logic[8:0] _e_4819;
    (* src = "src/parallel_rx.spade:41,5" *)
    logic[8:0] _e_4810;
    localparam[0:0] _e_4777 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \clk_pin_s1  <= _e_4777;
        end
        else begin
            \clk_pin_s1  <= \clk_pin ;
        end
    end
    localparam[0:0] _e_4782 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \clk_pin_s2  <= _e_4782;
        end
        else begin
            \clk_pin_s2  <= \clk_pin_s1 ;
        end
    end
    localparam[7:0] _e_4787 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \data_sync  <= _e_4787;
        end
        else begin
            \data_sync  <= \data_in ;
        end
    end
    localparam[0:0] _e_4792 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \strobe_sync  <= _e_4792;
        end
        else begin
            \strobe_sync  <= \strobe ;
        end
    end
    localparam[0:0] _e_4798 = 0;
    localparam[7:0] _e_4799 = 0;
    assign _e_4797 = {_e_4798, _e_4799};
    assign _e_4801 = {\clk_pin_s2 , \data_sync };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx  <= _e_4797;
        end
        else begin
            \rx  <= _e_4801;
        end
    end
    assign _e_4806 = \rx [8];
    assign _e_4805 = !_e_4806;
    assign \rising_edge  = _e_4805 && \clk_pin_s2 ;
    assign _e_4811 = \rising_edge  && \strobe_sync ;
    assign _e_4816 = \rx [7:0];
    assign _e_4815 = {1'd1, _e_4816};
    assign _e_4819 = {1'd0, 8'bX};
    assign _e_4810 = _e_4811 ? _e_4815 : _e_4819;
    assign output__ = _e_4810;
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
    (* src = "src/sel.spade:21,9" *)
    logic \c ;
    logic _e_9366;
    logic _e_9368;
    logic _e_9370;
    (* src = "src/sel.spade:20,45" *)
    logic _e_4825;
    (* src = "src/sel.spade:20,14" *)
    reg \cond ;
    (* src = "src/sel.spade:27,9" *)
    logic[31:0] \v ;
    logic _e_9372;
    logic _e_9374;
    logic _e_9376;
    (* src = "src/sel.spade:26,46" *)
    logic[31:0] _e_4836;
    (* src = "src/sel.spade:26,14" *)
    reg[31:0] \val_a ;
    (* src = "src/sel.spade:34,47" *)
    logic[32:0] _e_4846;
    (* src = "src/sel.spade:35,9" *)
    logic[31:0] \val_b ;
    logic _e_9378;
    logic _e_9380;
    (* src = "src/sel.spade:37,17" *)
    logic[32:0] _e_4855;
    (* src = "src/sel.spade:39,17" *)
    logic[32:0] _e_4858;
    (* src = "src/sel.spade:36,13" *)
    logic[32:0] _e_4852;
    logic _e_9382;
    (* src = "src/sel.spade:42,17" *)
    logic[32:0] _e_4861;
    (* src = "src/sel.spade:34,55" *)
    logic[32:0] _e_4847;
    (* src = "src/sel.spade:34,14" *)
    reg[32:0] \res ;
    localparam[0:0] _e_4824 = 0;
    assign \c  = \set_cond [0:0];
    assign _e_9366 = \set_cond [1] == 1'd1;
    localparam[0:0] _e_9367 = 1;
    assign _e_9368 = _e_9366 && _e_9367;
    assign _e_9370 = \set_cond [1] == 1'd0;
    always_comb begin
        priority casez ({_e_9368, _e_9370})
            2'b1?: _e_4825 = \c ;
            2'b01: _e_4825 = \cond ;
            2'b?: _e_4825 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \cond  <= _e_4824;
        end
        else begin
            \cond  <= _e_4825;
        end
    end
    localparam[31:0] _e_4835 = 32'd0;
    assign \v  = \set_a [31:0];
    assign _e_9372 = \set_a [32] == 1'd1;
    localparam[0:0] _e_9373 = 1;
    assign _e_9374 = _e_9372 && _e_9373;
    assign _e_9376 = \set_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9374, _e_9376})
            2'b1?: _e_4836 = \v ;
            2'b01: _e_4836 = \val_a ;
            2'b?: _e_4836 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \val_a  <= _e_4835;
        end
        else begin
            \val_a  <= _e_4836;
        end
    end
    assign _e_4846 = {1'd0, 32'bX};
    assign \val_b  = \trig_b [31:0];
    assign _e_9378 = \trig_b [32] == 1'd1;
    localparam[0:0] _e_9379 = 1;
    assign _e_9380 = _e_9378 && _e_9379;
    assign _e_4855 = {1'd1, \val_a };
    assign _e_4858 = {1'd1, \val_b };
    assign _e_4852 = \cond  ? _e_4855 : _e_4858;
    assign _e_9382 = \trig_b [32] == 1'd0;
    assign _e_4861 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9380, _e_9382})
            2'b1?: _e_4847 = _e_4852;
            2'b01: _e_4847 = _e_4861;
            2'b?: _e_4847 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_4846;
        end
        else begin
            \res  <= _e_4847;
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
    (* src = "src/sel.spade:50,9" *)
    logic[42:0] _e_4867;
    (* src = "src/sel.spade:50,14" *)
    logic \a ;
    logic _e_9384;
    logic _e_9386;
    logic _e_9388;
    logic _e_9389;
    (* src = "src/sel.spade:50,35" *)
    logic[1:0] _e_4869;
    (* src = "src/sel.spade:51,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:51,25" *)
    logic[42:0] _e_4875;
    (* src = "src/sel.spade:51,30" *)
    logic a_n1;
    logic _e_9392;
    logic _e_9394;
    logic _e_9396;
    logic _e_9397;
    (* src = "src/sel.spade:51,51" *)
    logic[1:0] _e_4877;
    (* src = "src/sel.spade:51,60" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:51,65" *)
    logic[1:0] _e_4880;
    (* src = "src/sel.spade:51,14" *)
    logic[1:0] _e_4872;
    (* src = "src/sel.spade:49,5" *)
    logic[1:0] _e_4864;
    assign _e_4867 = \m1 [42:0];
    assign \a  = _e_4867[36:36];
    assign _e_9384 = \m1 [43] == 1'd1;
    assign _e_9386 = _e_4867[42:37] == 6'd27;
    localparam[0:0] _e_9387 = 1;
    assign _e_9388 = _e_9386 && _e_9387;
    assign _e_9389 = _e_9384 && _e_9388;
    assign _e_4869 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9390 = 1;
    assign _e_4875 = \m0 [42:0];
    assign a_n1 = _e_4875[36:36];
    assign _e_9392 = \m0 [43] == 1'd1;
    assign _e_9394 = _e_4875[42:37] == 6'd27;
    localparam[0:0] _e_9395 = 1;
    assign _e_9396 = _e_9394 && _e_9395;
    assign _e_9397 = _e_9392 && _e_9396;
    assign _e_4877 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9398 = 1;
    assign _e_4880 = {1'd0, 1'bX};
    always_comb begin
        priority casez ({_e_9397, _e_9398})
            2'b1?: _e_4872 = _e_4877;
            2'b01: _e_4872 = _e_4880;
            2'b?: _e_4872 = 2'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9389, _e_9390})
            2'b1?: _e_4864 = _e_4869;
            2'b01: _e_4864 = _e_4872;
            2'b?: _e_4864 = 2'dx;
        endcase
    end
    assign output__ = _e_4864;
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
    (* src = "src/sel.spade:57,9" *)
    logic[42:0] _e_4885;
    (* src = "src/sel.spade:57,14" *)
    logic[31:0] \a ;
    logic _e_9400;
    logic _e_9402;
    logic _e_9404;
    logic _e_9405;
    (* src = "src/sel.spade:57,35" *)
    logic[32:0] _e_4887;
    (* src = "src/sel.spade:58,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:58,25" *)
    logic[42:0] _e_4893;
    (* src = "src/sel.spade:58,30" *)
    logic[31:0] a_n1;
    logic _e_9408;
    logic _e_9410;
    logic _e_9412;
    logic _e_9413;
    (* src = "src/sel.spade:58,51" *)
    logic[32:0] _e_4895;
    (* src = "src/sel.spade:58,60" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:58,65" *)
    logic[32:0] _e_4898;
    (* src = "src/sel.spade:58,14" *)
    logic[32:0] _e_4890;
    (* src = "src/sel.spade:56,5" *)
    logic[32:0] _e_4882;
    assign _e_4885 = \m1 [42:0];
    assign \a  = _e_4885[36:5];
    assign _e_9400 = \m1 [43] == 1'd1;
    assign _e_9402 = _e_4885[42:37] == 6'd28;
    localparam[0:0] _e_9403 = 1;
    assign _e_9404 = _e_9402 && _e_9403;
    assign _e_9405 = _e_9400 && _e_9404;
    assign _e_4887 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9406 = 1;
    assign _e_4893 = \m0 [42:0];
    assign a_n1 = _e_4893[36:5];
    assign _e_9408 = \m0 [43] == 1'd1;
    assign _e_9410 = _e_4893[42:37] == 6'd28;
    localparam[0:0] _e_9411 = 1;
    assign _e_9412 = _e_9410 && _e_9411;
    assign _e_9413 = _e_9408 && _e_9412;
    assign _e_4895 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9414 = 1;
    assign _e_4898 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9413, _e_9414})
            2'b1?: _e_4890 = _e_4895;
            2'b01: _e_4890 = _e_4898;
            2'b?: _e_4890 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9405, _e_9406})
            2'b1?: _e_4882 = _e_4887;
            2'b01: _e_4882 = _e_4890;
            2'b?: _e_4882 = 33'dx;
        endcase
    end
    assign output__ = _e_4882;
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
    (* src = "src/sel.spade:64,9" *)
    logic[42:0] _e_4903;
    (* src = "src/sel.spade:64,14" *)
    logic[31:0] \a ;
    logic _e_9416;
    logic _e_9418;
    logic _e_9420;
    logic _e_9421;
    (* src = "src/sel.spade:64,36" *)
    logic[32:0] _e_4905;
    (* src = "src/sel.spade:65,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:65,25" *)
    logic[42:0] _e_4911;
    (* src = "src/sel.spade:65,30" *)
    logic[31:0] a_n1;
    logic _e_9424;
    logic _e_9426;
    logic _e_9428;
    logic _e_9429;
    (* src = "src/sel.spade:65,52" *)
    logic[32:0] _e_4913;
    (* src = "src/sel.spade:65,61" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:65,66" *)
    logic[32:0] _e_4916;
    (* src = "src/sel.spade:65,14" *)
    logic[32:0] _e_4908;
    (* src = "src/sel.spade:63,5" *)
    logic[32:0] _e_4900;
    assign _e_4903 = \m1 [42:0];
    assign \a  = _e_4903[36:5];
    assign _e_9416 = \m1 [43] == 1'd1;
    assign _e_9418 = _e_4903[42:37] == 6'd29;
    localparam[0:0] _e_9419 = 1;
    assign _e_9420 = _e_9418 && _e_9419;
    assign _e_9421 = _e_9416 && _e_9420;
    assign _e_4905 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9422 = 1;
    assign _e_4911 = \m0 [42:0];
    assign a_n1 = _e_4911[36:5];
    assign _e_9424 = \m0 [43] == 1'd1;
    assign _e_9426 = _e_4911[42:37] == 6'd29;
    localparam[0:0] _e_9427 = 1;
    assign _e_9428 = _e_9426 && _e_9427;
    assign _e_9429 = _e_9424 && _e_9428;
    assign _e_4913 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9430 = 1;
    assign _e_4916 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9429, _e_9430})
            2'b1?: _e_4908 = _e_4913;
            2'b01: _e_4908 = _e_4916;
            2'b?: _e_4908 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9421, _e_9422})
            2'b1?: _e_4900 = _e_4905;
            2'b01: _e_4900 = _e_4908;
            2'b?: _e_4900 = 33'dx;
        endcase
    end
    assign output__ = _e_4900;
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
    (* src = "src/bootloader.spade:64,11" *)
    logic[4:0] _e_4919;
    (* src = "src/bootloader.spade:64,5" *)
    logic[120:0] _e_4918;
    assign _e_4919 = {5'd0};
    localparam[15:0] _e_4920 = 0;
    localparam[15:0] _e_4921 = 0;
    localparam[9:0] _e_4922 = 0;
    localparam[9:0] _e_4923 = 0;
    localparam[31:0] _e_4924 = 32'd0;
    localparam[31:0] _e_4925 = 32'd0;
    assign _e_4918 = {_e_4919, _e_4920, _e_4921, _e_4922, _e_4923, _e_4924, _e_4925};
    assign output__ = _e_4918;
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
    (* src = "src/bootloader.spade:74,35" *)
    logic[120:0] _e_4930;
    (* src = "src/bootloader.spade:75,28" *)
    logic[4:0] _e_4935;
    (* src = "src/bootloader.spade:75,15" *)
    logic[5:0] _e_4933;
    (* src = "src/bootloader.spade:76,13" *)
    logic[5:0] _e_4939;
    (* src = "src/bootloader.spade:76,13" *)
    logic _e_4937;
    (* src = "src/bootloader.spade:76,13" *)
    logic[4:0] _e_4938;
    logic _e_9434;
    logic _e_9435;
    (* src = "src/bootloader.spade:76,37" *)
    logic _e_4941;
    (* src = "src/bootloader.spade:77,27" *)
    logic[4:0] _e_4946;
    (* src = "src/bootloader.spade:77,38" *)
    logic[15:0] _e_4947;
    (* src = "src/bootloader.spade:77,46" *)
    logic[15:0] _e_4949;
    (* src = "src/bootloader.spade:77,56" *)
    logic[9:0] _e_4951;
    (* src = "src/bootloader.spade:77,66" *)
    logic[9:0] _e_4953;
    (* src = "src/bootloader.spade:77,74" *)
    logic[31:0] _e_4955;
    (* src = "src/bootloader.spade:77,81" *)
    logic[31:0] _e_4957;
    (* src = "src/bootloader.spade:77,21" *)
    logic[120:0] _e_4945;
    (* src = "src/bootloader.spade:79,21" *)
    logic[120:0] _e_4960;
    (* src = "src/bootloader.spade:76,34" *)
    logic[120:0] _e_4940;
    (* src = "src/bootloader.spade:81,13" *)
    logic[5:0] _e_4963;
    (* src = "src/bootloader.spade:81,13" *)
    logic _e_4961;
    (* src = "src/bootloader.spade:81,13" *)
    logic[4:0] _e_4962;
    logic _e_9439;
    logic _e_9440;
    (* src = "src/bootloader.spade:81,37" *)
    logic _e_4965;
    (* src = "src/bootloader.spade:82,27" *)
    logic[4:0] _e_4970;
    (* src = "src/bootloader.spade:82,37" *)
    logic[15:0] _e_4971;
    (* src = "src/bootloader.spade:82,45" *)
    logic[15:0] _e_4973;
    (* src = "src/bootloader.spade:82,55" *)
    logic[9:0] _e_4975;
    (* src = "src/bootloader.spade:82,65" *)
    logic[9:0] _e_4977;
    (* src = "src/bootloader.spade:82,73" *)
    logic[31:0] _e_4979;
    (* src = "src/bootloader.spade:82,80" *)
    logic[31:0] _e_4981;
    (* src = "src/bootloader.spade:82,21" *)
    logic[120:0] _e_4969;
    (* src = "src/bootloader.spade:84,21" *)
    logic[120:0] _e_4984;
    (* src = "src/bootloader.spade:81,34" *)
    logic[120:0] _e_4964;
    (* src = "src/bootloader.spade:86,13" *)
    logic[5:0] _e_4987;
    (* src = "src/bootloader.spade:86,13" *)
    logic _e_4985;
    (* src = "src/bootloader.spade:86,13" *)
    logic[4:0] _e_4986;
    logic _e_9444;
    logic _e_9445;
    (* src = "src/bootloader.spade:86,39" *)
    logic[4:0] _e_4989;
    logic[15:0] _e_4990;
    (* src = "src/bootloader.spade:86,61" *)
    logic[15:0] _e_4992;
    (* src = "src/bootloader.spade:86,71" *)
    logic[9:0] _e_4994;
    (* src = "src/bootloader.spade:86,81" *)
    logic[9:0] _e_4996;
    (* src = "src/bootloader.spade:86,89" *)
    logic[31:0] _e_4998;
    (* src = "src/bootloader.spade:86,96" *)
    logic[31:0] _e_5000;
    (* src = "src/bootloader.spade:86,33" *)
    logic[120:0] _e_4988;
    (* src = "src/bootloader.spade:87,13" *)
    logic[5:0] _e_5004;
    (* src = "src/bootloader.spade:87,13" *)
    logic _e_5002;
    (* src = "src/bootloader.spade:87,13" *)
    logic[4:0] _e_5003;
    logic _e_9449;
    logic _e_9450;
    logic[15:0] _e_5008;
    (* src = "src/bootloader.spade:88,29" *)
    logic[15:0] _e_5007;
    (* src = "src/bootloader.spade:88,49" *)
    logic[15:0] _e_5011;
    (* src = "src/bootloader.spade:88,29" *)
    logic[15:0] \v ;
    (* src = "src/bootloader.spade:89,24" *)
    logic _e_5015;
    (* src = "src/bootloader.spade:90,31" *)
    logic[4:0] _e_5020;
    (* src = "src/bootloader.spade:90,39" *)
    logic[15:0] _e_5021;
    (* src = "src/bootloader.spade:90,49" *)
    logic[15:0] _e_5023;
    (* src = "src/bootloader.spade:90,59" *)
    logic[9:0] _e_5025;
    (* src = "src/bootloader.spade:90,69" *)
    logic[9:0] _e_5027;
    (* src = "src/bootloader.spade:90,77" *)
    logic[31:0] _e_5029;
    (* src = "src/bootloader.spade:90,84" *)
    logic[31:0] _e_5031;
    (* src = "src/bootloader.spade:90,25" *)
    logic[120:0] _e_5019;
    (* src = "src/bootloader.spade:92,25" *)
    logic[120:0] _e_5034;
    (* src = "src/bootloader.spade:89,21" *)
    logic[120:0] _e_5014;
    (* src = "src/bootloader.spade:95,13" *)
    logic[5:0] _e_5037;
    (* src = "src/bootloader.spade:95,13" *)
    logic _e_5035;
    (* src = "src/bootloader.spade:95,13" *)
    logic[4:0] _e_5036;
    logic _e_9454;
    logic _e_9455;
    (* src = "src/bootloader.spade:95,37" *)
    logic[4:0] _e_5039;
    (* src = "src/bootloader.spade:95,45" *)
    logic[15:0] _e_5040;
    logic[15:0] _e_5042;
    (* src = "src/bootloader.spade:95,65" *)
    logic[9:0] _e_5044;
    (* src = "src/bootloader.spade:95,75" *)
    logic[9:0] _e_5046;
    (* src = "src/bootloader.spade:95,83" *)
    logic[31:0] _e_5048;
    (* src = "src/bootloader.spade:95,90" *)
    logic[31:0] _e_5050;
    (* src = "src/bootloader.spade:95,31" *)
    logic[120:0] _e_5038;
    (* src = "src/bootloader.spade:96,13" *)
    logic[5:0] _e_5054;
    (* src = "src/bootloader.spade:96,13" *)
    logic _e_5052;
    (* src = "src/bootloader.spade:96,13" *)
    logic[4:0] _e_5053;
    logic _e_9459;
    logic _e_9460;
    logic[15:0] _e_5058;
    (* src = "src/bootloader.spade:97,29" *)
    logic[15:0] _e_5057;
    (* src = "src/bootloader.spade:97,49" *)
    logic[15:0] _e_5061;
    (* src = "src/bootloader.spade:97,29" *)
    logic[15:0] \n ;
    (* src = "src/bootloader.spade:98,40" *)
    logic _e_5065;
    (* src = "src/bootloader.spade:98,37" *)
    logic[15:0] \n_clamped ;
    (* src = "src/bootloader.spade:99,27" *)
    logic[4:0] _e_5074;
    (* src = "src/bootloader.spade:99,35" *)
    logic[15:0] _e_5075;
    (* src = "src/bootloader.spade:99,43" *)
    logic[15:0] _e_5077;
    (* src = "src/bootloader.spade:99,61" *)
    logic[9:0] _e_5079;
    (* src = "src/bootloader.spade:99,71" *)
    logic[9:0] _e_5081;
    (* src = "src/bootloader.spade:99,79" *)
    logic[31:0] _e_5083;
    (* src = "src/bootloader.spade:99,86" *)
    logic[31:0] _e_5085;
    (* src = "src/bootloader.spade:99,21" *)
    logic[120:0] _e_5073;
    (* src = "src/bootloader.spade:101,13" *)
    logic[5:0] _e_5089;
    (* src = "src/bootloader.spade:101,13" *)
    logic _e_5087;
    (* src = "src/bootloader.spade:101,13" *)
    logic[4:0] _e_5088;
    logic _e_9464;
    logic _e_9465;
    (* src = "src/bootloader.spade:101,37" *)
    logic[4:0] _e_5091;
    (* src = "src/bootloader.spade:101,45" *)
    logic[15:0] _e_5092;
    (* src = "src/bootloader.spade:101,53" *)
    logic[15:0] _e_5094;
    logic[9:0] _e_5096;
    (* src = "src/bootloader.spade:101,75" *)
    logic[9:0] _e_5098;
    (* src = "src/bootloader.spade:101,83" *)
    logic[31:0] _e_5100;
    (* src = "src/bootloader.spade:101,90" *)
    logic[31:0] _e_5102;
    (* src = "src/bootloader.spade:101,31" *)
    logic[120:0] _e_5090;
    (* src = "src/bootloader.spade:102,13" *)
    logic[5:0] _e_5106;
    (* src = "src/bootloader.spade:102,13" *)
    logic _e_5104;
    (* src = "src/bootloader.spade:102,13" *)
    logic[4:0] _e_5105;
    logic _e_9469;
    logic _e_9470;
    logic[9:0] _e_5110;
    (* src = "src/bootloader.spade:103,29" *)
    logic[9:0] _e_5109;
    (* src = "src/bootloader.spade:103,49" *)
    logic[9:0] _e_5113;
    (* src = "src/bootloader.spade:103,29" *)
    logic[9:0] \e ;
    (* src = "src/bootloader.spade:104,24" *)
    logic[15:0] _e_5118;
    (* src = "src/bootloader.spade:104,24" *)
    logic _e_5117;
    (* src = "src/bootloader.spade:105,31" *)
    logic[4:0] _e_5123;
    (* src = "src/bootloader.spade:105,41" *)
    logic[15:0] _e_5124;
    (* src = "src/bootloader.spade:105,49" *)
    logic[15:0] _e_5126;
    (* src = "src/bootloader.spade:105,59" *)
    logic[9:0] _e_5128;
    (* src = "src/bootloader.spade:105,69" *)
    logic[9:0] _e_5130;
    (* src = "src/bootloader.spade:105,77" *)
    logic[31:0] _e_5132;
    (* src = "src/bootloader.spade:105,84" *)
    logic[31:0] _e_5134;
    (* src = "src/bootloader.spade:105,25" *)
    logic[120:0] _e_5122;
    (* src = "src/bootloader.spade:107,31" *)
    logic[4:0] _e_5138;
    (* src = "src/bootloader.spade:107,42" *)
    logic[15:0] _e_5139;
    (* src = "src/bootloader.spade:107,50" *)
    logic[15:0] _e_5141;
    (* src = "src/bootloader.spade:107,60" *)
    logic[9:0] _e_5143;
    (* src = "src/bootloader.spade:107,70" *)
    logic[9:0] _e_5145;
    (* src = "src/bootloader.spade:107,78" *)
    logic[31:0] _e_5147;
    (* src = "src/bootloader.spade:107,85" *)
    logic[31:0] _e_5149;
    (* src = "src/bootloader.spade:107,25" *)
    logic[120:0] _e_5137;
    (* src = "src/bootloader.spade:104,21" *)
    logic[120:0] _e_5116;
    (* src = "src/bootloader.spade:112,13" *)
    logic[5:0] _e_5153;
    (* src = "src/bootloader.spade:112,13" *)
    logic _e_5151;
    (* src = "src/bootloader.spade:112,13" *)
    logic[4:0] _e_5152;
    logic _e_9474;
    logic _e_9475;
    (* src = "src/bootloader.spade:112,40" *)
    logic[4:0] _e_5155;
    (* src = "src/bootloader.spade:112,51" *)
    logic[15:0] _e_5156;
    (* src = "src/bootloader.spade:112,59" *)
    logic[15:0] _e_5158;
    (* src = "src/bootloader.spade:112,69" *)
    logic[9:0] _e_5160;
    (* src = "src/bootloader.spade:112,79" *)
    logic[9:0] _e_5162;
    logic[31:0] _e_5166;
    (* src = "src/bootloader.spade:112,112" *)
    logic[31:0] _e_5169;
    (* src = "src/bootloader.spade:112,111" *)
    logic[31:0] _e_5168;
    (* src = "src/bootloader.spade:112,93" *)
    logic[31:0] _e_5165;
    (* src = "src/bootloader.spade:112,87" *)
    logic[31:0] _e_5164;
    (* src = "src/bootloader.spade:112,134" *)
    logic[31:0] _e_5172;
    (* src = "src/bootloader.spade:112,34" *)
    logic[120:0] _e_5154;
    (* src = "src/bootloader.spade:113,13" *)
    logic[5:0] _e_5176;
    (* src = "src/bootloader.spade:113,13" *)
    logic _e_5174;
    (* src = "src/bootloader.spade:113,13" *)
    logic[4:0] _e_5175;
    logic _e_9479;
    logic _e_9480;
    (* src = "src/bootloader.spade:113,40" *)
    logic[4:0] _e_5178;
    (* src = "src/bootloader.spade:113,51" *)
    logic[15:0] _e_5179;
    (* src = "src/bootloader.spade:113,59" *)
    logic[15:0] _e_5181;
    (* src = "src/bootloader.spade:113,69" *)
    logic[9:0] _e_5183;
    (* src = "src/bootloader.spade:113,79" *)
    logic[9:0] _e_5185;
    logic[31:0] _e_5190;
    (* src = "src/bootloader.spade:113,93" *)
    logic[31:0] _e_5189;
    (* src = "src/bootloader.spade:113,115" *)
    logic[31:0] _e_5194;
    (* src = "src/bootloader.spade:113,114" *)
    logic[31:0] _e_5193;
    (* src = "src/bootloader.spade:113,93" *)
    logic[31:0] _e_5188;
    (* src = "src/bootloader.spade:113,87" *)
    logic[31:0] _e_5187;
    (* src = "src/bootloader.spade:113,137" *)
    logic[31:0] _e_5197;
    (* src = "src/bootloader.spade:113,34" *)
    logic[120:0] _e_5177;
    (* src = "src/bootloader.spade:114,13" *)
    logic[5:0] _e_5201;
    (* src = "src/bootloader.spade:114,13" *)
    logic _e_5199;
    (* src = "src/bootloader.spade:114,13" *)
    logic[4:0] _e_5200;
    logic _e_9484;
    logic _e_9485;
    (* src = "src/bootloader.spade:114,40" *)
    logic[4:0] _e_5203;
    (* src = "src/bootloader.spade:114,51" *)
    logic[15:0] _e_5204;
    (* src = "src/bootloader.spade:114,59" *)
    logic[15:0] _e_5206;
    (* src = "src/bootloader.spade:114,69" *)
    logic[9:0] _e_5208;
    (* src = "src/bootloader.spade:114,79" *)
    logic[9:0] _e_5210;
    logic[31:0] _e_5215;
    (* src = "src/bootloader.spade:114,93" *)
    logic[31:0] _e_5214;
    (* src = "src/bootloader.spade:114,115" *)
    logic[31:0] _e_5219;
    (* src = "src/bootloader.spade:114,114" *)
    logic[31:0] _e_5218;
    (* src = "src/bootloader.spade:114,93" *)
    logic[31:0] _e_5213;
    (* src = "src/bootloader.spade:114,87" *)
    logic[31:0] _e_5212;
    (* src = "src/bootloader.spade:114,137" *)
    logic[31:0] _e_5222;
    (* src = "src/bootloader.spade:114,34" *)
    logic[120:0] _e_5202;
    (* src = "src/bootloader.spade:115,13" *)
    logic[5:0] _e_5226;
    (* src = "src/bootloader.spade:115,13" *)
    logic _e_5224;
    (* src = "src/bootloader.spade:115,13" *)
    logic[4:0] _e_5225;
    logic _e_9489;
    logic _e_9490;
    (* src = "src/bootloader.spade:115,40" *)
    logic[4:0] _e_5228;
    (* src = "src/bootloader.spade:115,51" *)
    logic[15:0] _e_5229;
    (* src = "src/bootloader.spade:115,59" *)
    logic[15:0] _e_5231;
    (* src = "src/bootloader.spade:115,69" *)
    logic[9:0] _e_5233;
    (* src = "src/bootloader.spade:115,79" *)
    logic[9:0] _e_5235;
    logic[31:0] _e_5240;
    (* src = "src/bootloader.spade:115,93" *)
    logic[31:0] _e_5239;
    (* src = "src/bootloader.spade:115,115" *)
    logic[31:0] _e_5244;
    (* src = "src/bootloader.spade:115,114" *)
    logic[31:0] _e_5243;
    (* src = "src/bootloader.spade:115,93" *)
    logic[31:0] _e_5238;
    (* src = "src/bootloader.spade:115,87" *)
    logic[31:0] _e_5237;
    (* src = "src/bootloader.spade:115,137" *)
    logic[31:0] _e_5247;
    (* src = "src/bootloader.spade:115,34" *)
    logic[120:0] _e_5227;
    (* src = "src/bootloader.spade:118,13" *)
    logic[5:0] _e_5251;
    (* src = "src/bootloader.spade:118,13" *)
    logic _e_5249;
    (* src = "src/bootloader.spade:118,13" *)
    logic[4:0] _e_5250;
    logic _e_9494;
    logic _e_9495;
    (* src = "src/bootloader.spade:118,40" *)
    logic[4:0] _e_5253;
    (* src = "src/bootloader.spade:118,51" *)
    logic[15:0] _e_5254;
    (* src = "src/bootloader.spade:118,59" *)
    logic[15:0] _e_5256;
    (* src = "src/bootloader.spade:118,69" *)
    logic[9:0] _e_5258;
    (* src = "src/bootloader.spade:118,79" *)
    logic[9:0] _e_5260;
    (* src = "src/bootloader.spade:118,87" *)
    logic[31:0] _e_5262;
    logic[31:0] _e_5266;
    (* src = "src/bootloader.spade:118,119" *)
    logic[31:0] _e_5269;
    (* src = "src/bootloader.spade:118,118" *)
    logic[31:0] _e_5268;
    (* src = "src/bootloader.spade:118,100" *)
    logic[31:0] _e_5265;
    (* src = "src/bootloader.spade:118,94" *)
    logic[31:0] _e_5264;
    (* src = "src/bootloader.spade:118,34" *)
    logic[120:0] _e_5252;
    (* src = "src/bootloader.spade:119,13" *)
    logic[5:0] _e_5274;
    (* src = "src/bootloader.spade:119,13" *)
    logic _e_5272;
    (* src = "src/bootloader.spade:119,13" *)
    logic[4:0] _e_5273;
    logic _e_9499;
    logic _e_9500;
    (* src = "src/bootloader.spade:119,40" *)
    logic[4:0] _e_5276;
    (* src = "src/bootloader.spade:119,51" *)
    logic[15:0] _e_5277;
    (* src = "src/bootloader.spade:119,59" *)
    logic[15:0] _e_5279;
    (* src = "src/bootloader.spade:119,69" *)
    logic[9:0] _e_5281;
    (* src = "src/bootloader.spade:119,79" *)
    logic[9:0] _e_5283;
    (* src = "src/bootloader.spade:119,87" *)
    logic[31:0] _e_5285;
    logic[31:0] _e_5290;
    (* src = "src/bootloader.spade:119,100" *)
    logic[31:0] _e_5289;
    (* src = "src/bootloader.spade:119,122" *)
    logic[31:0] _e_5294;
    (* src = "src/bootloader.spade:119,121" *)
    logic[31:0] _e_5293;
    (* src = "src/bootloader.spade:119,100" *)
    logic[31:0] _e_5288;
    (* src = "src/bootloader.spade:119,94" *)
    logic[31:0] _e_5287;
    (* src = "src/bootloader.spade:119,34" *)
    logic[120:0] _e_5275;
    (* src = "src/bootloader.spade:120,13" *)
    logic[5:0] _e_5299;
    (* src = "src/bootloader.spade:120,13" *)
    logic _e_5297;
    (* src = "src/bootloader.spade:120,13" *)
    logic[4:0] _e_5298;
    logic _e_9504;
    logic _e_9505;
    (* src = "src/bootloader.spade:120,40" *)
    logic[4:0] _e_5301;
    (* src = "src/bootloader.spade:120,51" *)
    logic[15:0] _e_5302;
    (* src = "src/bootloader.spade:120,59" *)
    logic[15:0] _e_5304;
    (* src = "src/bootloader.spade:120,69" *)
    logic[9:0] _e_5306;
    (* src = "src/bootloader.spade:120,79" *)
    logic[9:0] _e_5308;
    (* src = "src/bootloader.spade:120,87" *)
    logic[31:0] _e_5310;
    logic[31:0] _e_5315;
    (* src = "src/bootloader.spade:120,100" *)
    logic[31:0] _e_5314;
    (* src = "src/bootloader.spade:120,122" *)
    logic[31:0] _e_5319;
    (* src = "src/bootloader.spade:120,121" *)
    logic[31:0] _e_5318;
    (* src = "src/bootloader.spade:120,100" *)
    logic[31:0] _e_5313;
    (* src = "src/bootloader.spade:120,94" *)
    logic[31:0] _e_5312;
    (* src = "src/bootloader.spade:120,34" *)
    logic[120:0] _e_5300;
    (* src = "src/bootloader.spade:121,13" *)
    logic[5:0] _e_5324;
    (* src = "src/bootloader.spade:121,13" *)
    logic _e_5322;
    (* src = "src/bootloader.spade:121,13" *)
    logic[4:0] _e_5323;
    logic _e_9509;
    logic _e_9510;
    (* src = "src/bootloader.spade:121,40" *)
    logic[4:0] _e_5326;
    (* src = "src/bootloader.spade:121,52" *)
    logic[15:0] _e_5327;
    (* src = "src/bootloader.spade:121,60" *)
    logic[15:0] _e_5329;
    (* src = "src/bootloader.spade:121,70" *)
    logic[9:0] _e_5331;
    (* src = "src/bootloader.spade:121,80" *)
    logic[9:0] _e_5333;
    (* src = "src/bootloader.spade:121,88" *)
    logic[31:0] _e_5335;
    logic[31:0] _e_5340;
    (* src = "src/bootloader.spade:121,101" *)
    logic[31:0] _e_5339;
    (* src = "src/bootloader.spade:121,123" *)
    logic[31:0] _e_5344;
    (* src = "src/bootloader.spade:121,122" *)
    logic[31:0] _e_5343;
    (* src = "src/bootloader.spade:121,101" *)
    logic[31:0] _e_5338;
    (* src = "src/bootloader.spade:121,95" *)
    logic[31:0] _e_5337;
    (* src = "src/bootloader.spade:121,34" *)
    logic[120:0] _e_5325;
    (* src = "src/bootloader.spade:125,13" *)
    logic[5:0] _e_5349;
    (* src = "src/bootloader.spade:125,13" *)
    logic \_ ;
    (* src = "src/bootloader.spade:125,13" *)
    logic[4:0] _e_5348;
    logic _e_9514;
    logic _e_9515;
    (* src = "src/bootloader.spade:126,34" *)
    logic[9:0] _e_5353;
    (* src = "src/bootloader.spade:126,34" *)
    logic[10:0] _e_5352;
    (* src = "src/bootloader.spade:126,28" *)
    logic[9:0] \pcw1 ;
    (* src = "src/bootloader.spade:127,34" *)
    logic[15:0] _e_5359;
    (* src = "src/bootloader.spade:127,34" *)
    logic[16:0] _e_5358;
    (* src = "src/bootloader.spade:127,28" *)
    logic[15:0] \n1 ;
    (* src = "src/bootloader.spade:128,31" *)
    logic _e_5364;
    (* src = "src/bootloader.spade:129,21" *)
    logic[4:0] _e_5368;
    (* src = "src/bootloader.spade:131,21" *)
    logic[4:0] _e_5370;
    (* src = "src/bootloader.spade:128,28" *)
    logic[4:0] \next ;
    (* src = "src/bootloader.spade:133,29" *)
    logic[15:0] _e_5374;
    (* src = "src/bootloader.spade:133,41" *)
    logic[9:0] _e_5377;
    (* src = "src/bootloader.spade:133,57" *)
    logic[31:0] _e_5380;
    (* src = "src/bootloader.spade:133,64" *)
    logic[31:0] _e_5382;
    (* src = "src/bootloader.spade:133,17" *)
    logic[120:0] _e_5372;
    (* src = "src/bootloader.spade:137,13" *)
    logic[5:0] _e_5386;
    (* src = "src/bootloader.spade:137,13" *)
    logic __n1;
    (* src = "src/bootloader.spade:137,13" *)
    logic[4:0] _e_5385;
    logic _e_9519;
    logic _e_9520;
    (* src = "src/bootloader.spade:140,13" *)
    logic[5:0] _e_5390;
    (* src = "src/bootloader.spade:140,13" *)
    logic _e_5388;
    (* src = "src/bootloader.spade:140,13" *)
    logic[4:0] __n2;
    logic _e_9522;
    logic _e_9524;
    (* src = "src/bootloader.spade:75,9" *)
    logic[120:0] _e_4932;
    (* src = "src/bootloader.spade:74,14" *)
    reg[120:0] \st ;
    (* src = "src/bootloader.spade:144,47" *)
    logic[4:0] _e_5393;
    (* src = "src/bootloader.spade:145,9" *)
    logic[4:0] _e_5395;
    logic _e_9526;
    (* src = "src/bootloader.spade:145,29" *)
    logic[9:0] _e_5398;
    (* src = "src/bootloader.spade:145,24" *)
    logic[10:0] _e_5397;
    (* src = "src/bootloader.spade:145,43" *)
    logic[31:0] _e_5401;
    (* src = "src/bootloader.spade:145,38" *)
    logic[32:0] _e_5400;
    (* src = "src/bootloader.spade:145,56" *)
    logic[31:0] _e_5404;
    (* src = "src/bootloader.spade:145,51" *)
    logic[32:0] _e_5403;
    (* src = "src/bootloader.spade:145,23" *)
    logic[76:0] _e_5396;
    (* src = "src/bootloader.spade:146,9" *)
    logic[4:0] __n3;
    (* src = "src/bootloader.spade:146,15" *)
    logic[10:0] _e_5408;
    (* src = "src/bootloader.spade:146,21" *)
    logic[32:0] _e_5409;
    (* src = "src/bootloader.spade:146,27" *)
    logic[32:0] _e_5410;
    (* src = "src/bootloader.spade:146,14" *)
    logic[76:0] _e_5407;
    (* src = "src/bootloader.spade:144,41" *)
    logic[76:0] _e_5414;
    (* src = "src/bootloader.spade:144,9" *)
    logic[10:0] \wr_addr ;
    (* src = "src/bootloader.spade:144,9" *)
    logic[32:0] \wr_slot0 ;
    (* src = "src/bootloader.spade:144,9" *)
    logic[32:0] \wr_slot1 ;
    (* src = "src/bootloader.spade:149,43" *)
    logic[4:0] _e_5416;
    (* src = "src/bootloader.spade:150,9" *)
    logic[4:0] _e_5418;
    logic _e_9529;
    (* src = "src/bootloader.spade:150,34" *)
    logic[9:0] _e_5422;
    (* src = "src/bootloader.spade:150,29" *)
    logic[10:0] _e_5421;
    (* src = "src/bootloader.spade:150,21" *)
    logic[11:0] _e_5419;
    (* src = "src/bootloader.spade:151,9" *)
    logic[4:0] __n4;
    (* src = "src/bootloader.spade:151,21" *)
    logic[10:0] _e_5427;
    (* src = "src/bootloader.spade:151,14" *)
    logic[11:0] _e_5425;
    (* src = "src/bootloader.spade:149,37" *)
    logic[11:0] _e_5430;
    (* src = "src/bootloader.spade:149,9" *)
    logic \boot_active ;
    (* src = "src/bootloader.spade:149,9" *)
    logic[10:0] \release_pc ;
    (* src = "src/bootloader.spade:154,5" *)
    logic[88:0] _e_5431;
    (* src = "src/bootloader.spade:74,35" *)
    \tta::bootloader::reset_state  reset_state_0(.output__(_e_4930));
    assign _e_4935 = \st [120:116];
    assign _e_4933 = {\byte_valid , _e_4935};
    assign _e_4939 = _e_4933;
    assign _e_4937 = _e_4933[5];
    assign _e_4938 = _e_4933[4:0];
    assign _e_9434 = _e_4938[4:0] == 5'd0;
    assign _e_9435 = _e_4937 && _e_9434;
    localparam[7:0] _e_4943 = 66;
    assign _e_4941 = \byte  == _e_4943;
    assign _e_4946 = {5'd1};
    assign _e_4947 = \st [115:100];
    assign _e_4949 = \st [99:84];
    assign _e_4951 = \st [83:74];
    assign _e_4953 = \st [73:64];
    assign _e_4955 = \st [63:32];
    assign _e_4957 = \st [31:0];
    assign _e_4945 = {_e_4946, _e_4947, _e_4949, _e_4951, _e_4953, _e_4955, _e_4957};
    (* src = "src/bootloader.spade:79,21" *)
    \tta::bootloader::reset_state  reset_state_1(.output__(_e_4960));
    assign _e_4940 = _e_4941 ? _e_4945 : _e_4960;
    assign _e_4963 = _e_4933;
    assign _e_4961 = _e_4933[5];
    assign _e_4962 = _e_4933[4:0];
    assign _e_9439 = _e_4962[4:0] == 5'd1;
    assign _e_9440 = _e_4961 && _e_9439;
    localparam[7:0] _e_4967 = 84;
    assign _e_4965 = \byte  == _e_4967;
    assign _e_4970 = {5'd2};
    assign _e_4971 = \st [115:100];
    assign _e_4973 = \st [99:84];
    assign _e_4975 = \st [83:74];
    assign _e_4977 = \st [73:64];
    assign _e_4979 = \st [63:32];
    assign _e_4981 = \st [31:0];
    assign _e_4969 = {_e_4970, _e_4971, _e_4973, _e_4975, _e_4977, _e_4979, _e_4981};
    (* src = "src/bootloader.spade:84,21" *)
    \tta::bootloader::reset_state  reset_state_2(.output__(_e_4984));
    assign _e_4964 = _e_4965 ? _e_4969 : _e_4984;
    assign _e_4987 = _e_4933;
    assign _e_4985 = _e_4933[5];
    assign _e_4986 = _e_4933[4:0];
    assign _e_9444 = _e_4986[4:0] == 5'd2;
    assign _e_9445 = _e_4985 && _e_9444;
    assign _e_4989 = {5'd3};
    assign _e_4990 = {8'b0, \byte };
    assign _e_4992 = \st [99:84];
    assign _e_4994 = \st [83:74];
    assign _e_4996 = \st [73:64];
    assign _e_4998 = \st [63:32];
    assign _e_5000 = \st [31:0];
    assign _e_4988 = {_e_4989, _e_4990, _e_4992, _e_4994, _e_4996, _e_4998, _e_5000};
    assign _e_5004 = _e_4933;
    assign _e_5002 = _e_4933[5];
    assign _e_5003 = _e_4933[4:0];
    assign _e_9449 = _e_5003[4:0] == 5'd3;
    assign _e_9450 = _e_5002 && _e_9449;
    assign _e_5008 = {8'b0, \byte };
    localparam[15:0] _e_5010 = 8;
    assign _e_5007 = _e_5008 << _e_5010;
    assign _e_5011 = \st [115:100];
    assign \v  = _e_5007 | _e_5011;
    localparam[15:0] _e_5017 = 1;
    assign _e_5015 = \v  == _e_5017;
    assign _e_5020 = {5'd4};
    assign _e_5021 = \v [15:0];
    assign _e_5023 = \st [99:84];
    assign _e_5025 = \st [83:74];
    assign _e_5027 = \st [73:64];
    assign _e_5029 = \st [63:32];
    assign _e_5031 = \st [31:0];
    assign _e_5019 = {_e_5020, _e_5021, _e_5023, _e_5025, _e_5027, _e_5029, _e_5031};
    (* src = "src/bootloader.spade:92,25" *)
    \tta::bootloader::reset_state  reset_state_3(.output__(_e_5034));
    assign _e_5014 = _e_5015 ? _e_5019 : _e_5034;
    assign _e_5037 = _e_4933;
    assign _e_5035 = _e_4933[5];
    assign _e_5036 = _e_4933[4:0];
    assign _e_9454 = _e_5036[4:0] == 5'd4;
    assign _e_9455 = _e_5035 && _e_9454;
    assign _e_5039 = {5'd5};
    assign _e_5040 = \st [115:100];
    assign _e_5042 = {8'b0, \byte };
    assign _e_5044 = \st [83:74];
    assign _e_5046 = \st [73:64];
    assign _e_5048 = \st [63:32];
    assign _e_5050 = \st [31:0];
    assign _e_5038 = {_e_5039, _e_5040, _e_5042, _e_5044, _e_5046, _e_5048, _e_5050};
    assign _e_5054 = _e_4933;
    assign _e_5052 = _e_4933[5];
    assign _e_5053 = _e_4933[4:0];
    assign _e_9459 = _e_5053[4:0] == 5'd5;
    assign _e_9460 = _e_5052 && _e_9459;
    assign _e_5058 = {8'b0, \byte };
    localparam[15:0] _e_5060 = 8;
    assign _e_5057 = _e_5058 << _e_5060;
    assign _e_5061 = \st [99:84];
    assign \n  = _e_5057 | _e_5061;
    localparam[15:0] _e_5067 = 1024;
    assign _e_5065 = \n  > _e_5067;
    localparam[15:0] _e_5069 = 1024;
    assign \n_clamped  = _e_5065 ? _e_5069 : \n ;
    assign _e_5074 = {5'd6};
    assign _e_5075 = \st [115:100];
    assign _e_5077 = \n_clamped [15:0];
    assign _e_5079 = \st [83:74];
    assign _e_5081 = \st [73:64];
    assign _e_5083 = \st [63:32];
    assign _e_5085 = \st [31:0];
    assign _e_5073 = {_e_5074, _e_5075, _e_5077, _e_5079, _e_5081, _e_5083, _e_5085};
    assign _e_5089 = _e_4933;
    assign _e_5087 = _e_4933[5];
    assign _e_5088 = _e_4933[4:0];
    assign _e_9464 = _e_5088[4:0] == 5'd6;
    assign _e_9465 = _e_5087 && _e_9464;
    assign _e_5091 = {5'd7};
    assign _e_5092 = \st [115:100];
    assign _e_5094 = \st [99:84];
    assign _e_5096 = {2'b0, \byte };
    assign _e_5098 = \st [73:64];
    assign _e_5100 = \st [63:32];
    assign _e_5102 = \st [31:0];
    assign _e_5090 = {_e_5091, _e_5092, _e_5094, _e_5096, _e_5098, _e_5100, _e_5102};
    assign _e_5106 = _e_4933;
    assign _e_5104 = _e_4933[5];
    assign _e_5105 = _e_4933[4:0];
    assign _e_9469 = _e_5105[4:0] == 5'd7;
    assign _e_9470 = _e_5104 && _e_9469;
    assign _e_5110 = {2'b0, \byte };
    localparam[9:0] _e_5112 = 8;
    assign _e_5109 = _e_5110 << _e_5112;
    assign _e_5113 = \st [83:74];
    assign \e  = _e_5109 | _e_5113;
    assign _e_5118 = \st [99:84];
    localparam[15:0] _e_5120 = 0;
    assign _e_5117 = _e_5118 == _e_5120;
    assign _e_5123 = {5'd17};
    assign _e_5124 = \st [115:100];
    assign _e_5126 = \st [99:84];
    assign _e_5128 = \e [9:0];
    assign _e_5130 = \st [73:64];
    assign _e_5132 = \st [63:32];
    assign _e_5134 = \st [31:0];
    assign _e_5122 = {_e_5123, _e_5124, _e_5126, _e_5128, _e_5130, _e_5132, _e_5134};
    assign _e_5138 = {5'd8};
    assign _e_5139 = \st [115:100];
    assign _e_5141 = \st [99:84];
    assign _e_5143 = \e [9:0];
    assign _e_5145 = \st [73:64];
    assign _e_5147 = \st [63:32];
    assign _e_5149 = \st [31:0];
    assign _e_5137 = {_e_5138, _e_5139, _e_5141, _e_5143, _e_5145, _e_5147, _e_5149};
    assign _e_5116 = _e_5117 ? _e_5122 : _e_5137;
    assign _e_5153 = _e_4933;
    assign _e_5151 = _e_4933[5];
    assign _e_5152 = _e_4933[4:0];
    assign _e_9474 = _e_5152[4:0] == 5'd8;
    assign _e_9475 = _e_5151 && _e_9474;
    assign _e_5155 = {5'd9};
    assign _e_5156 = \st [115:100];
    assign _e_5158 = \st [99:84];
    assign _e_5160 = \st [83:74];
    assign _e_5162 = \st [73:64];
    assign _e_5166 = {24'b0, \byte };
    assign _e_5169 = \st [63:32];
    localparam[31:0] _e_5171 = 32'd4294967040;
    assign _e_5168 = _e_5169 & _e_5171;
    assign _e_5165 = _e_5166 | _e_5168;
    assign _e_5164 = _e_5165[31:0];
    assign _e_5172 = \st [31:0];
    assign _e_5154 = {_e_5155, _e_5156, _e_5158, _e_5160, _e_5162, _e_5164, _e_5172};
    assign _e_5176 = _e_4933;
    assign _e_5174 = _e_4933[5];
    assign _e_5175 = _e_4933[4:0];
    assign _e_9479 = _e_5175[4:0] == 5'd9;
    assign _e_9480 = _e_5174 && _e_9479;
    assign _e_5178 = {5'd10};
    assign _e_5179 = \st [115:100];
    assign _e_5181 = \st [99:84];
    assign _e_5183 = \st [83:74];
    assign _e_5185 = \st [73:64];
    assign _e_5190 = {24'b0, \byte };
    localparam[31:0] _e_5192 = 32'd8;
    assign _e_5189 = _e_5190 << _e_5192;
    assign _e_5194 = \st [63:32];
    localparam[31:0] _e_5196 = 32'd4294902015;
    assign _e_5193 = _e_5194 & _e_5196;
    assign _e_5188 = _e_5189 | _e_5193;
    assign _e_5187 = _e_5188[31:0];
    assign _e_5197 = \st [31:0];
    assign _e_5177 = {_e_5178, _e_5179, _e_5181, _e_5183, _e_5185, _e_5187, _e_5197};
    assign _e_5201 = _e_4933;
    assign _e_5199 = _e_4933[5];
    assign _e_5200 = _e_4933[4:0];
    assign _e_9484 = _e_5200[4:0] == 5'd10;
    assign _e_9485 = _e_5199 && _e_9484;
    assign _e_5203 = {5'd11};
    assign _e_5204 = \st [115:100];
    assign _e_5206 = \st [99:84];
    assign _e_5208 = \st [83:74];
    assign _e_5210 = \st [73:64];
    assign _e_5215 = {24'b0, \byte };
    localparam[31:0] _e_5217 = 32'd16;
    assign _e_5214 = _e_5215 << _e_5217;
    assign _e_5219 = \st [63:32];
    localparam[31:0] _e_5221 = 32'd4278255615;
    assign _e_5218 = _e_5219 & _e_5221;
    assign _e_5213 = _e_5214 | _e_5218;
    assign _e_5212 = _e_5213[31:0];
    assign _e_5222 = \st [31:0];
    assign _e_5202 = {_e_5203, _e_5204, _e_5206, _e_5208, _e_5210, _e_5212, _e_5222};
    assign _e_5226 = _e_4933;
    assign _e_5224 = _e_4933[5];
    assign _e_5225 = _e_4933[4:0];
    assign _e_9489 = _e_5225[4:0] == 5'd11;
    assign _e_9490 = _e_5224 && _e_9489;
    assign _e_5228 = {5'd12};
    assign _e_5229 = \st [115:100];
    assign _e_5231 = \st [99:84];
    assign _e_5233 = \st [83:74];
    assign _e_5235 = \st [73:64];
    assign _e_5240 = {24'b0, \byte };
    localparam[31:0] _e_5242 = 32'd24;
    assign _e_5239 = _e_5240 << _e_5242;
    assign _e_5244 = \st [63:32];
    localparam[31:0] _e_5246 = 32'd16777215;
    assign _e_5243 = _e_5244 & _e_5246;
    assign _e_5238 = _e_5239 | _e_5243;
    assign _e_5237 = _e_5238[31:0];
    assign _e_5247 = \st [31:0];
    assign _e_5227 = {_e_5228, _e_5229, _e_5231, _e_5233, _e_5235, _e_5237, _e_5247};
    assign _e_5251 = _e_4933;
    assign _e_5249 = _e_4933[5];
    assign _e_5250 = _e_4933[4:0];
    assign _e_9494 = _e_5250[4:0] == 5'd12;
    assign _e_9495 = _e_5249 && _e_9494;
    assign _e_5253 = {5'd13};
    assign _e_5254 = \st [115:100];
    assign _e_5256 = \st [99:84];
    assign _e_5258 = \st [83:74];
    assign _e_5260 = \st [73:64];
    assign _e_5262 = \st [63:32];
    assign _e_5266 = {24'b0, \byte };
    assign _e_5269 = \st [31:0];
    localparam[31:0] _e_5271 = 32'd4294967040;
    assign _e_5268 = _e_5269 & _e_5271;
    assign _e_5265 = _e_5266 | _e_5268;
    assign _e_5264 = _e_5265[31:0];
    assign _e_5252 = {_e_5253, _e_5254, _e_5256, _e_5258, _e_5260, _e_5262, _e_5264};
    assign _e_5274 = _e_4933;
    assign _e_5272 = _e_4933[5];
    assign _e_5273 = _e_4933[4:0];
    assign _e_9499 = _e_5273[4:0] == 5'd13;
    assign _e_9500 = _e_5272 && _e_9499;
    assign _e_5276 = {5'd14};
    assign _e_5277 = \st [115:100];
    assign _e_5279 = \st [99:84];
    assign _e_5281 = \st [83:74];
    assign _e_5283 = \st [73:64];
    assign _e_5285 = \st [63:32];
    assign _e_5290 = {24'b0, \byte };
    localparam[31:0] _e_5292 = 32'd8;
    assign _e_5289 = _e_5290 << _e_5292;
    assign _e_5294 = \st [31:0];
    localparam[31:0] _e_5296 = 32'd4294902015;
    assign _e_5293 = _e_5294 & _e_5296;
    assign _e_5288 = _e_5289 | _e_5293;
    assign _e_5287 = _e_5288[31:0];
    assign _e_5275 = {_e_5276, _e_5277, _e_5279, _e_5281, _e_5283, _e_5285, _e_5287};
    assign _e_5299 = _e_4933;
    assign _e_5297 = _e_4933[5];
    assign _e_5298 = _e_4933[4:0];
    assign _e_9504 = _e_5298[4:0] == 5'd14;
    assign _e_9505 = _e_5297 && _e_9504;
    assign _e_5301 = {5'd15};
    assign _e_5302 = \st [115:100];
    assign _e_5304 = \st [99:84];
    assign _e_5306 = \st [83:74];
    assign _e_5308 = \st [73:64];
    assign _e_5310 = \st [63:32];
    assign _e_5315 = {24'b0, \byte };
    localparam[31:0] _e_5317 = 32'd16;
    assign _e_5314 = _e_5315 << _e_5317;
    assign _e_5319 = \st [31:0];
    localparam[31:0] _e_5321 = 32'd4278255615;
    assign _e_5318 = _e_5319 & _e_5321;
    assign _e_5313 = _e_5314 | _e_5318;
    assign _e_5312 = _e_5313[31:0];
    assign _e_5300 = {_e_5301, _e_5302, _e_5304, _e_5306, _e_5308, _e_5310, _e_5312};
    assign _e_5324 = _e_4933;
    assign _e_5322 = _e_4933[5];
    assign _e_5323 = _e_4933[4:0];
    assign _e_9509 = _e_5323[4:0] == 5'd15;
    assign _e_9510 = _e_5322 && _e_9509;
    assign _e_5326 = {5'd16};
    assign _e_5327 = \st [115:100];
    assign _e_5329 = \st [99:84];
    assign _e_5331 = \st [83:74];
    assign _e_5333 = \st [73:64];
    assign _e_5335 = \st [63:32];
    assign _e_5340 = {24'b0, \byte };
    localparam[31:0] _e_5342 = 32'd24;
    assign _e_5339 = _e_5340 << _e_5342;
    assign _e_5344 = \st [31:0];
    localparam[31:0] _e_5346 = 32'd16777215;
    assign _e_5343 = _e_5344 & _e_5346;
    assign _e_5338 = _e_5339 | _e_5343;
    assign _e_5337 = _e_5338[31:0];
    assign _e_5325 = {_e_5326, _e_5327, _e_5329, _e_5331, _e_5333, _e_5335, _e_5337};
    assign _e_5349 = _e_4933;
    assign \_  = _e_4933[5];
    assign _e_5348 = _e_4933[4:0];
    localparam[0:0] _e_9512 = 1;
    assign _e_9514 = _e_5348[4:0] == 5'd16;
    assign _e_9515 = _e_9512 && _e_9514;
    assign _e_5353 = \st [73:64];
    localparam[9:0] _e_5355 = 1;
    assign _e_5352 = _e_5353 + _e_5355;
    assign \pcw1  = _e_5352[9:0];
    assign _e_5359 = \st [99:84];
    localparam[15:0] _e_5361 = 1;
    assign _e_5358 = _e_5359 - _e_5361;
    assign \n1  = _e_5358[15:0];
    localparam[15:0] _e_5366 = 0;
    assign _e_5364 = \n1  == _e_5366;
    assign _e_5368 = {5'd17};
    assign _e_5370 = {5'd8};
    assign \next  = _e_5364 ? _e_5368 : _e_5370;
    assign _e_5374 = \st [115:100];
    assign _e_5377 = \st [83:74];
    assign _e_5380 = \st [63:32];
    assign _e_5382 = \st [31:0];
    assign _e_5372 = {\next , _e_5374, \n1 , _e_5377, \pcw1 , _e_5380, _e_5382};
    assign _e_5386 = _e_4933;
    assign __n1 = _e_4933[5];
    assign _e_5385 = _e_4933[4:0];
    localparam[0:0] _e_9517 = 1;
    assign _e_9519 = _e_5385[4:0] == 5'd17;
    assign _e_9520 = _e_9517 && _e_9519;
    assign _e_5390 = _e_4933;
    assign _e_5388 = _e_4933[5];
    assign __n2 = _e_4933[4:0];
    assign _e_9522 = !_e_5388;
    localparam[0:0] _e_9523 = 1;
    assign _e_9524 = _e_9522 && _e_9523;
    always_comb begin
        priority casez ({_e_9435, _e_9440, _e_9445, _e_9450, _e_9455, _e_9460, _e_9465, _e_9470, _e_9475, _e_9480, _e_9485, _e_9490, _e_9495, _e_9500, _e_9505, _e_9510, _e_9515, _e_9520, _e_9524})
            19'b1??????????????????: _e_4932 = _e_4940;
            19'b01?????????????????: _e_4932 = _e_4964;
            19'b001????????????????: _e_4932 = _e_4988;
            19'b0001???????????????: _e_4932 = _e_5014;
            19'b00001??????????????: _e_4932 = _e_5038;
            19'b000001?????????????: _e_4932 = _e_5073;
            19'b0000001????????????: _e_4932 = _e_5090;
            19'b00000001???????????: _e_4932 = _e_5116;
            19'b000000001??????????: _e_4932 = _e_5154;
            19'b0000000001?????????: _e_4932 = _e_5177;
            19'b00000000001????????: _e_4932 = _e_5202;
            19'b000000000001???????: _e_4932 = _e_5227;
            19'b0000000000001??????: _e_4932 = _e_5252;
            19'b00000000000001?????: _e_4932 = _e_5275;
            19'b000000000000001????: _e_4932 = _e_5300;
            19'b0000000000000001???: _e_4932 = _e_5325;
            19'b00000000000000001??: _e_4932 = _e_5372;
            19'b000000000000000001?: _e_4932 = \st ;
            19'b0000000000000000001: _e_4932 = \st ;
            19'b?: _e_4932 = 121'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \st  <= _e_4930;
        end
        else begin
            \st  <= _e_4932;
        end
    end
    assign _e_5393 = \st [120:116];
    assign _e_5395 = _e_5393;
    assign _e_9526 = _e_5393[4:0] == 5'd16;
    assign _e_5398 = \st [73:64];
    assign _e_5397 = {1'd1, _e_5398};
    assign _e_5401 = \st [63:32];
    assign _e_5400 = {1'd1, _e_5401};
    assign _e_5404 = \st [31:0];
    assign _e_5403 = {1'd1, _e_5404};
    assign _e_5396 = {_e_5397, _e_5400, _e_5403};
    assign __n3 = _e_5393;
    localparam[0:0] _e_9527 = 1;
    assign _e_5408 = {1'd0, 10'bX};
    assign _e_5409 = {1'd0, 32'bX};
    assign _e_5410 = {1'd0, 32'bX};
    assign _e_5407 = {_e_5408, _e_5409, _e_5410};
    always_comb begin
        priority casez ({_e_9526, _e_9527})
            2'b1?: _e_5414 = _e_5396;
            2'b01: _e_5414 = _e_5407;
            2'b?: _e_5414 = 77'dx;
        endcase
    end
    assign \wr_addr  = _e_5414[76:66];
    assign \wr_slot0  = _e_5414[65:33];
    assign \wr_slot1  = _e_5414[32:0];
    assign _e_5416 = \st [120:116];
    assign _e_5418 = _e_5416;
    assign _e_9529 = _e_5416[4:0] == 5'd17;
    localparam[0:0] _e_5420 = 0;
    assign _e_5422 = \st [83:74];
    assign _e_5421 = {1'd1, _e_5422};
    assign _e_5419 = {_e_5420, _e_5421};
    assign __n4 = _e_5416;
    localparam[0:0] _e_9530 = 1;
    localparam[0:0] _e_5426 = 1;
    assign _e_5427 = {1'd0, 10'bX};
    assign _e_5425 = {_e_5426, _e_5427};
    always_comb begin
        priority casez ({_e_9529, _e_9530})
            2'b1?: _e_5430 = _e_5419;
            2'b01: _e_5430 = _e_5425;
            2'b?: _e_5430 = 12'dx;
        endcase
    end
    assign \boot_active  = _e_5430[11];
    assign \release_pc  = _e_5430[10:0];
    assign _e_5431 = {\boot_active , \wr_addr , \wr_slot0 , \wr_slot1 , \release_pc };
    assign output__ = _e_5431;
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
    (* src = "src/bit.spade:19,9" *)
    logic[31:0] \v ;
    logic _e_9532;
    logic _e_9534;
    logic _e_9536;
    (* src = "src/bit.spade:18,45" *)
    logic[31:0] _e_5442;
    (* src = "src/bit.spade:18,14" *)
    reg[31:0] \op_a ;
    (* src = "src/bit.spade:25,9" *)
    logic[34:0] _e_5453;
    (* src = "src/bit.spade:25,14" *)
    logic[2:0] _e_5451;
    (* src = "src/bit.spade:25,14" *)
    logic[31:0] \_ ;
    logic _e_9538;
    logic _e_9541;
    logic _e_9543;
    logic _e_9544;
    (* src = "src/bit.spade:25,42" *)
    logic[31:0] _e_5456;
    (* src = "src/bit.spade:25,37" *)
    logic[32:0] _e_5455;
    (* src = "src/bit.spade:26,9" *)
    logic[34:0] _e_5460;
    (* src = "src/bit.spade:26,14" *)
    logic[2:0] _e_5458;
    (* src = "src/bit.spade:26,14" *)
    logic[31:0] __n1;
    logic _e_9546;
    logic _e_9549;
    logic _e_9551;
    logic _e_9552;
    (* src = "src/bit.spade:26,42" *)
    logic[31:0] _e_5463;
    (* src = "src/bit.spade:26,37" *)
    logic[32:0] _e_5462;
    (* src = "src/bit.spade:27,9" *)
    logic[34:0] _e_5467;
    (* src = "src/bit.spade:27,14" *)
    logic[2:0] _e_5465;
    (* src = "src/bit.spade:27,14" *)
    logic[31:0] __n2;
    logic _e_9554;
    logic _e_9557;
    logic _e_9559;
    logic _e_9560;
    (* src = "src/bit.spade:27,42" *)
    logic[31:0] _e_5470;
    (* src = "src/bit.spade:27,37" *)
    logic[32:0] _e_5469;
    (* src = "src/bit.spade:28,9" *)
    logic[34:0] _e_5474;
    (* src = "src/bit.spade:28,14" *)
    logic[2:0] _e_5472;
    (* src = "src/bit.spade:28,14" *)
    logic[31:0] __n3;
    logic _e_9562;
    logic _e_9565;
    logic _e_9567;
    logic _e_9568;
    (* src = "src/bit.spade:28,42" *)
    logic[31:0] _e_5477;
    (* src = "src/bit.spade:28,37" *)
    logic[32:0] _e_5476;
    (* src = "src/bit.spade:30,9" *)
    logic[34:0] _e_5481;
    (* src = "src/bit.spade:30,14" *)
    logic[2:0] _e_5479;
    (* src = "src/bit.spade:30,14" *)
    logic[31:0] \b ;
    logic _e_9570;
    logic _e_9573;
    logic _e_9575;
    logic _e_9576;
    (* src = "src/bit.spade:30,55" *)
    logic[31:0] _e_5488;
    (* src = "src/bit.spade:30,49" *)
    logic[31:0] _e_5486;
    (* src = "src/bit.spade:30,42" *)
    logic[31:0] _e_5484;
    (* src = "src/bit.spade:30,37" *)
    logic[32:0] _e_5483;
    (* src = "src/bit.spade:31,9" *)
    logic[34:0] _e_5493;
    (* src = "src/bit.spade:31,14" *)
    logic[2:0] _e_5491;
    (* src = "src/bit.spade:31,14" *)
    logic[31:0] b_n1;
    logic _e_9578;
    logic _e_9581;
    logic _e_9583;
    logic _e_9584;
    (* src = "src/bit.spade:31,56" *)
    logic[31:0] _e_5501;
    (* src = "src/bit.spade:31,50" *)
    logic[31:0] _e_5499;
    (* src = "src/bit.spade:31,49" *)
    logic[31:0] _e_5498;
    (* src = "src/bit.spade:31,42" *)
    logic[31:0] _e_5496;
    (* src = "src/bit.spade:31,37" *)
    logic[32:0] _e_5495;
    (* src = "src/bit.spade:35,9" *)
    logic[34:0] _e_5506;
    (* src = "src/bit.spade:35,14" *)
    logic[2:0] _e_5504;
    (* src = "src/bit.spade:35,14" *)
    logic[31:0] b_n2;
    logic _e_9586;
    logic _e_9589;
    logic _e_9591;
    logic _e_9592;
    (* src = "src/bit.spade:35,40" *)
    logic[31:0] _e_5509;
    (* src = "src/bit.spade:35,35" *)
    logic[32:0] _e_5508;
    (* src = "src/bit.spade:36,9" *)
    logic[34:0] _e_5514;
    (* src = "src/bit.spade:36,14" *)
    logic[2:0] _e_5512;
    (* src = "src/bit.spade:36,14" *)
    logic[31:0] b_n3;
    logic _e_9594;
    logic _e_9597;
    logic _e_9599;
    logic _e_9600;
    (* src = "src/bit.spade:36,40" *)
    logic[31:0] _e_5517;
    (* src = "src/bit.spade:36,35" *)
    logic[32:0] _e_5516;
    logic _e_9602;
    (* src = "src/bit.spade:38,17" *)
    logic[32:0] _e_5521;
    (* src = "src/bit.spade:24,36" *)
    logic[32:0] \result ;
    (* src = "src/bit.spade:42,51" *)
    logic[32:0] _e_5526;
    (* src = "src/bit.spade:42,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_5441 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_9532 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9533 = 1;
    assign _e_9534 = _e_9532 && _e_9533;
    assign _e_9536 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9534, _e_9536})
            2'b1?: _e_5442 = \v ;
            2'b01: _e_5442 = \op_a ;
            2'b?: _e_5442 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_5441;
        end
        else begin
            \op_a  <= _e_5442;
        end
    end
    assign _e_5453 = \trig [34:0];
    assign _e_5451 = _e_5453[34:32];
    assign \_  = _e_5453[31:0];
    assign _e_9538 = \trig [35] == 1'd1;
    assign _e_9541 = _e_5451[2:0] == 3'd0;
    localparam[0:0] _e_9542 = 1;
    assign _e_9543 = _e_9541 && _e_9542;
    assign _e_9544 = _e_9538 && _e_9543;
    (* src = "src/bit.spade:25,42" *)
    \tta::bit::clz32  clz32_0(.val_i(\op_a ), .output__(_e_5456));
    assign _e_5455 = {1'd1, _e_5456};
    assign _e_5460 = \trig [34:0];
    assign _e_5458 = _e_5460[34:32];
    assign __n1 = _e_5460[31:0];
    assign _e_9546 = \trig [35] == 1'd1;
    assign _e_9549 = _e_5458[2:0] == 3'd1;
    localparam[0:0] _e_9550 = 1;
    assign _e_9551 = _e_9549 && _e_9550;
    assign _e_9552 = _e_9546 && _e_9551;
    (* src = "src/bit.spade:26,42" *)
    \tta::bit::ctz32  ctz32_0(.val_i(\op_a ), .output__(_e_5463));
    assign _e_5462 = {1'd1, _e_5463};
    assign _e_5467 = \trig [34:0];
    assign _e_5465 = _e_5467[34:32];
    assign __n2 = _e_5467[31:0];
    assign _e_9554 = \trig [35] == 1'd1;
    assign _e_9557 = _e_5465[2:0] == 3'd2;
    localparam[0:0] _e_9558 = 1;
    assign _e_9559 = _e_9557 && _e_9558;
    assign _e_9560 = _e_9554 && _e_9559;
    (* src = "src/bit.spade:27,42" *)
    \tta::bit::popcnt32  popcnt32_0(.val_i(\op_a ), .output__(_e_5470));
    assign _e_5469 = {1'd1, _e_5470};
    assign _e_5474 = \trig [34:0];
    assign _e_5472 = _e_5474[34:32];
    assign __n3 = _e_5474[31:0];
    assign _e_9562 = \trig [35] == 1'd1;
    assign _e_9565 = _e_5472[2:0] == 3'd7;
    localparam[0:0] _e_9566 = 1;
    assign _e_9567 = _e_9565 && _e_9566;
    assign _e_9568 = _e_9562 && _e_9567;
    (* src = "src/bit.spade:28,42" *)
    \tta::bit::brev32  brev32_0(.val_i(\op_a ), .output__(_e_5477));
    assign _e_5476 = {1'd1, _e_5477};
    assign _e_5481 = \trig [34:0];
    assign _e_5479 = _e_5481[34:32];
    assign \b  = _e_5481[31:0];
    assign _e_9570 = \trig [35] == 1'd1;
    assign _e_9573 = _e_5479[2:0] == 3'd3;
    localparam[0:0] _e_9574 = 1;
    assign _e_9575 = _e_9573 && _e_9574;
    assign _e_9576 = _e_9570 && _e_9575;
    localparam[31:0] _e_5487 = 32'd1;
    localparam[31:0] _e_5490 = 32'd31;
    assign _e_5488 = \b  & _e_5490;
    assign _e_5486 = _e_5487 << _e_5488;
    assign _e_5484 = \op_a  | _e_5486;
    assign _e_5483 = {1'd1, _e_5484};
    assign _e_5493 = \trig [34:0];
    assign _e_5491 = _e_5493[34:32];
    assign b_n1 = _e_5493[31:0];
    assign _e_9578 = \trig [35] == 1'd1;
    assign _e_9581 = _e_5491[2:0] == 3'd4;
    localparam[0:0] _e_9582 = 1;
    assign _e_9583 = _e_9581 && _e_9582;
    assign _e_9584 = _e_9578 && _e_9583;
    localparam[31:0] _e_5500 = 32'd1;
    localparam[31:0] _e_5503 = 32'd31;
    assign _e_5501 = b_n1 & _e_5503;
    assign _e_5499 = _e_5500 << _e_5501;
    assign _e_5498 = ~_e_5499;
    assign _e_5496 = \op_a  & _e_5498;
    assign _e_5495 = {1'd1, _e_5496};
    assign _e_5506 = \trig [34:0];
    assign _e_5504 = _e_5506[34:32];
    assign b_n2 = _e_5506[31:0];
    assign _e_9586 = \trig [35] == 1'd1;
    assign _e_9589 = _e_5504[2:0] == 3'd5;
    localparam[0:0] _e_9590 = 1;
    assign _e_9591 = _e_9589 && _e_9590;
    assign _e_9592 = _e_9586 && _e_9591;
    (* src = "src/bit.spade:35,40" *)
    \tta::bit::bext32  bext32_0(.val_i(\op_a ), .ctrl_i(b_n2), .output__(_e_5509));
    assign _e_5508 = {1'd1, _e_5509};
    assign _e_5514 = \trig [34:0];
    assign _e_5512 = _e_5514[34:32];
    assign b_n3 = _e_5514[31:0];
    assign _e_9594 = \trig [35] == 1'd1;
    assign _e_9597 = _e_5512[2:0] == 3'd6;
    localparam[0:0] _e_9598 = 1;
    assign _e_9599 = _e_9597 && _e_9598;
    assign _e_9600 = _e_9594 && _e_9599;
    (* src = "src/bit.spade:36,40" *)
    \tta::bit::bins32  bins32_0(.val_i(\op_a ), .ctrl_i(b_n3), .output__(_e_5517));
    assign _e_5516 = {1'd1, _e_5517};
    assign _e_9602 = \trig [35] == 1'd0;
    assign _e_5521 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9544, _e_9552, _e_9560, _e_9568, _e_9576, _e_9584, _e_9592, _e_9600, _e_9602})
            9'b1????????: \result  = _e_5455;
            9'b01???????: \result  = _e_5462;
            9'b001??????: \result  = _e_5469;
            9'b0001?????: \result  = _e_5476;
            9'b00001????: \result  = _e_5483;
            9'b000001???: \result  = _e_5495;
            9'b0000001??: \result  = _e_5508;
            9'b00000001?: \result  = _e_5516;
            9'b000000001: \result  = _e_5521;
            9'b?: \result  = 33'dx;
        endcase
    end
    assign _e_5526 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_5526;
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
    (* src = "src/bit.spade:53,8" *)
    logic _e_5531;
    (* src = "src/bit.spade:57,27" *)
    logic[31:0] _e_5539;
    (* src = "src/bit.spade:57,27" *)
    logic _e_5538;
    (* src = "src/bit.spade:57,58" *)
    logic[31:0] _e_5546;
    (* src = "src/bit.spade:57,53" *)
    logic[63:0] _e_5544;
    (* src = "src/bit.spade:57,78" *)
    logic[63:0] _e_5550;
    (* src = "src/bit.spade:57,24" *)
    logic[63:0] _e_5555;
    (* src = "src/bit.spade:57,13" *)
    logic[31:0] \n1 ;
    (* src = "src/bit.spade:57,13" *)
    logic[31:0] \x1 ;
    (* src = "src/bit.spade:58,27" *)
    logic[31:0] _e_5558;
    (* src = "src/bit.spade:58,27" *)
    logic _e_5557;
    (* src = "src/bit.spade:58,59" *)
    logic[32:0] _e_5565;
    (* src = "src/bit.spade:58,53" *)
    logic[31:0] _e_5564;
    (* src = "src/bit.spade:58,66" *)
    logic[31:0] _e_5568;
    (* src = "src/bit.spade:58,52" *)
    logic[63:0] _e_5563;
    (* src = "src/bit.spade:58,84" *)
    logic[63:0] _e_5572;
    (* src = "src/bit.spade:58,24" *)
    logic[63:0] _e_5577;
    (* src = "src/bit.spade:58,13" *)
    logic[31:0] \n2 ;
    (* src = "src/bit.spade:58,13" *)
    logic[31:0] \x2 ;
    (* src = "src/bit.spade:59,27" *)
    logic[31:0] _e_5580;
    (* src = "src/bit.spade:59,27" *)
    logic _e_5579;
    (* src = "src/bit.spade:59,59" *)
    logic[32:0] _e_5587;
    (* src = "src/bit.spade:59,53" *)
    logic[31:0] _e_5586;
    (* src = "src/bit.spade:59,66" *)
    logic[31:0] _e_5590;
    (* src = "src/bit.spade:59,52" *)
    logic[63:0] _e_5585;
    (* src = "src/bit.spade:59,84" *)
    logic[63:0] _e_5594;
    (* src = "src/bit.spade:59,24" *)
    logic[63:0] _e_5599;
    (* src = "src/bit.spade:59,13" *)
    logic[31:0] \n3 ;
    (* src = "src/bit.spade:59,13" *)
    logic[31:0] \x3 ;
    (* src = "src/bit.spade:60,27" *)
    logic[31:0] _e_5602;
    (* src = "src/bit.spade:60,27" *)
    logic _e_5601;
    (* src = "src/bit.spade:60,59" *)
    logic[32:0] _e_5609;
    (* src = "src/bit.spade:60,53" *)
    logic[31:0] _e_5608;
    (* src = "src/bit.spade:60,66" *)
    logic[31:0] _e_5612;
    (* src = "src/bit.spade:60,52" *)
    logic[63:0] _e_5607;
    (* src = "src/bit.spade:60,84" *)
    logic[63:0] _e_5616;
    (* src = "src/bit.spade:60,24" *)
    logic[63:0] _e_5621;
    (* src = "src/bit.spade:60,13" *)
    logic[31:0] \n4 ;
    (* src = "src/bit.spade:60,13" *)
    logic[31:0] \x4 ;
    (* src = "src/bit.spade:61,21" *)
    logic[31:0] _e_5624;
    (* src = "src/bit.spade:61,21" *)
    logic _e_5623;
    (* src = "src/bit.spade:61,52" *)
    logic[32:0] _e_5630;
    (* src = "src/bit.spade:61,46" *)
    logic[31:0] _e_5629;
    (* src = "src/bit.spade:61,18" *)
    logic[31:0] \n5 ;
    (* src = "src/bit.spade:53,5" *)
    logic[31:0] _e_5530;
    localparam[31:0] _e_5533 = 32'd0;
    assign _e_5531 = \val  == _e_5533;
    localparam[31:0] _e_5535 = 32'd32;
    localparam[31:0] _e_5541 = 32'd4294901760;
    assign _e_5539 = \val  & _e_5541;
    localparam[31:0] _e_5542 = 32'd0;
    assign _e_5538 = _e_5539 == _e_5542;
    localparam[31:0] _e_5545 = 32'd16;
    localparam[31:0] _e_5548 = 32'd16;
    assign _e_5546 = \val  << _e_5548;
    assign _e_5544 = {_e_5545, _e_5546};
    localparam[31:0] _e_5551 = 32'd0;
    assign _e_5550 = {_e_5551, \val };
    assign _e_5555 = _e_5538 ? _e_5544 : _e_5550;
    assign \n1  = _e_5555[63:32];
    assign \x1  = _e_5555[31:0];
    localparam[31:0] _e_5560 = 32'd4278190080;
    assign _e_5558 = \x1  & _e_5560;
    localparam[31:0] _e_5561 = 32'd0;
    assign _e_5557 = _e_5558 == _e_5561;
    localparam[31:0] _e_5567 = 32'd8;
    assign _e_5565 = \n1  + _e_5567;
    assign _e_5564 = _e_5565[31:0];
    localparam[31:0] _e_5570 = 32'd8;
    assign _e_5568 = \x1  << _e_5570;
    assign _e_5563 = {_e_5564, _e_5568};
    assign _e_5572 = {\n1 , \x1 };
    assign _e_5577 = _e_5557 ? _e_5563 : _e_5572;
    assign \n2  = _e_5577[63:32];
    assign \x2  = _e_5577[31:0];
    localparam[31:0] _e_5582 = 32'd4026531840;
    assign _e_5580 = \x2  & _e_5582;
    localparam[31:0] _e_5583 = 32'd0;
    assign _e_5579 = _e_5580 == _e_5583;
    localparam[31:0] _e_5589 = 32'd4;
    assign _e_5587 = \n2  + _e_5589;
    assign _e_5586 = _e_5587[31:0];
    localparam[31:0] _e_5592 = 32'd4;
    assign _e_5590 = \x2  << _e_5592;
    assign _e_5585 = {_e_5586, _e_5590};
    assign _e_5594 = {\n2 , \x2 };
    assign _e_5599 = _e_5579 ? _e_5585 : _e_5594;
    assign \n3  = _e_5599[63:32];
    assign \x3  = _e_5599[31:0];
    localparam[31:0] _e_5604 = 32'd3221225472;
    assign _e_5602 = \x3  & _e_5604;
    localparam[31:0] _e_5605 = 32'd0;
    assign _e_5601 = _e_5602 == _e_5605;
    localparam[31:0] _e_5611 = 32'd2;
    assign _e_5609 = \n3  + _e_5611;
    assign _e_5608 = _e_5609[31:0];
    localparam[31:0] _e_5614 = 32'd2;
    assign _e_5612 = \x3  << _e_5614;
    assign _e_5607 = {_e_5608, _e_5612};
    assign _e_5616 = {\n3 , \x3 };
    assign _e_5621 = _e_5601 ? _e_5607 : _e_5616;
    assign \n4  = _e_5621[63:32];
    assign \x4  = _e_5621[31:0];
    localparam[31:0] _e_5626 = 32'd2147483648;
    assign _e_5624 = \x4  & _e_5626;
    localparam[31:0] _e_5627 = 32'd0;
    assign _e_5623 = _e_5624 == _e_5627;
    localparam[31:0] _e_5632 = 32'd1;
    assign _e_5630 = \n4  + _e_5632;
    assign _e_5629 = _e_5630[31:0];
    assign \n5  = _e_5623 ? _e_5629 : \n4 ;
    assign _e_5530 = _e_5531 ? _e_5535 : \n5 ;
    assign output__ = _e_5530;
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
    (* src = "src/bit.spade:68,11" *)
    logic[31:0] _e_5639;
    (* src = "src/bit.spade:68,5" *)
    logic[31:0] _e_5638;
    (* src = "src/bit.spade:68,11" *)
    \tta::bit::brev32  brev32_0(.val_i(\val ), .output__(_e_5639));
    (* src = "src/bit.spade:68,5" *)
    \tta::bit::clz32  clz32_0(.val_i(_e_5639), .output__(_e_5638));
    assign output__ = _e_5638;
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
    (* src = "src/bit.spade:73,9" *)
    logic[31:0] \x ;
    (* src = "src/bit.spade:74,14" *)
    logic[31:0] _e_5646;
    (* src = "src/bit.spade:74,13" *)
    logic[31:0] _e_5645;
    (* src = "src/bit.spade:74,40" *)
    logic[31:0] _e_5651;
    (* src = "src/bit.spade:74,39" *)
    logic[31:0] _e_5650;
    (* src = "src/bit.spade:74,13" *)
    logic[31:0] x_n1;
    (* src = "src/bit.spade:75,14" *)
    logic[31:0] _e_5658;
    (* src = "src/bit.spade:75,13" *)
    logic[31:0] _e_5657;
    (* src = "src/bit.spade:75,40" *)
    logic[31:0] _e_5663;
    (* src = "src/bit.spade:75,39" *)
    logic[31:0] _e_5662;
    (* src = "src/bit.spade:75,13" *)
    logic[31:0] x_n2;
    (* src = "src/bit.spade:76,14" *)
    logic[31:0] _e_5670;
    (* src = "src/bit.spade:76,13" *)
    logic[31:0] _e_5669;
    (* src = "src/bit.spade:76,40" *)
    logic[31:0] _e_5675;
    (* src = "src/bit.spade:76,39" *)
    logic[31:0] _e_5674;
    (* src = "src/bit.spade:76,13" *)
    logic[31:0] x_n3;
    (* src = "src/bit.spade:77,14" *)
    logic[31:0] _e_5682;
    (* src = "src/bit.spade:77,13" *)
    logic[31:0] _e_5681;
    (* src = "src/bit.spade:77,40" *)
    logic[31:0] _e_5687;
    (* src = "src/bit.spade:77,39" *)
    logic[31:0] _e_5686;
    (* src = "src/bit.spade:77,13" *)
    logic[31:0] x_n4;
    (* src = "src/bit.spade:78,13" *)
    logic[31:0] _e_5693;
    (* src = "src/bit.spade:78,25" *)
    logic[31:0] _e_5696;
    (* src = "src/bit.spade:78,13" *)
    logic[31:0] x_n5;
    assign \x  = \val ;
    localparam[31:0] _e_5648 = 32'd1;
    assign _e_5646 = \x  >> _e_5648;
    localparam[31:0] _e_5649 = 32'd1431655765;
    assign _e_5645 = _e_5646 & _e_5649;
    localparam[31:0] _e_5653 = 32'd1431655765;
    assign _e_5651 = \x  & _e_5653;
    localparam[31:0] _e_5654 = 32'd1;
    assign _e_5650 = _e_5651 << _e_5654;
    assign x_n1 = _e_5645 | _e_5650;
    localparam[31:0] _e_5660 = 32'd2;
    assign _e_5658 = x_n1 >> _e_5660;
    localparam[31:0] _e_5661 = 32'd858993459;
    assign _e_5657 = _e_5658 & _e_5661;
    localparam[31:0] _e_5665 = 32'd858993459;
    assign _e_5663 = x_n1 & _e_5665;
    localparam[31:0] _e_5666 = 32'd2;
    assign _e_5662 = _e_5663 << _e_5666;
    assign x_n2 = _e_5657 | _e_5662;
    localparam[31:0] _e_5672 = 32'd4;
    assign _e_5670 = x_n2 >> _e_5672;
    localparam[31:0] _e_5673 = 32'd252645135;
    assign _e_5669 = _e_5670 & _e_5673;
    localparam[31:0] _e_5677 = 32'd252645135;
    assign _e_5675 = x_n2 & _e_5677;
    localparam[31:0] _e_5678 = 32'd4;
    assign _e_5674 = _e_5675 << _e_5678;
    assign x_n3 = _e_5669 | _e_5674;
    localparam[31:0] _e_5684 = 32'd8;
    assign _e_5682 = x_n3 >> _e_5684;
    localparam[31:0] _e_5685 = 32'd16711935;
    assign _e_5681 = _e_5682 & _e_5685;
    localparam[31:0] _e_5689 = 32'd16711935;
    assign _e_5687 = x_n3 & _e_5689;
    localparam[31:0] _e_5690 = 32'd8;
    assign _e_5686 = _e_5687 << _e_5690;
    assign x_n4 = _e_5681 | _e_5686;
    localparam[31:0] _e_5695 = 32'd16;
    assign _e_5693 = x_n4 >> _e_5695;
    localparam[31:0] _e_5698 = 32'd16;
    assign _e_5696 = x_n4 << _e_5698;
    assign x_n5 = _e_5693 | _e_5696;
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
    (* src = "src/bit.spade:84,9" *)
    logic[31:0] \x ;
    (* src = "src/bit.spade:85,18" *)
    logic[31:0] _e_5707;
    (* src = "src/bit.spade:85,17" *)
    logic[31:0] _e_5706;
    (* src = "src/bit.spade:85,13" *)
    logic[32:0] x_n1;
    (* src = "src/bit.spade:86,13" *)
    logic[32:0] _e_5713;
    (* src = "src/bit.spade:86,33" *)
    logic[32:0] _e_5717;
    (* src = "src/bit.spade:86,32" *)
    logic[32:0] _e_5716;
    (* src = "src/bit.spade:86,13" *)
    logic[33:0] x_n2;
    (* src = "src/bit.spade:87,18" *)
    logic[33:0] _e_5725;
    (* src = "src/bit.spade:87,13" *)
    logic[34:0] _e_5723;
    (* src = "src/bit.spade:87,13" *)
    logic[34:0] x_n3;
    (* src = "src/bit.spade:88,17" *)
    logic[34:0] _e_5732;
    (* src = "src/bit.spade:88,13" *)
    logic[35:0] x_n4;
    (* src = "src/bit.spade:89,17" *)
    logic[35:0] _e_5738;
    (* src = "src/bit.spade:89,13" *)
    logic[36:0] x_n5;
    (* src = "src/bit.spade:90,11" *)
    logic[36:0] _e_5743;
    (* src = "src/bit.spade:90,5" *)
    logic[31:0] _e_5742;
    assign \x  = \val ;
    localparam[31:0] _e_5709 = 32'd1;
    assign _e_5707 = \x  >> _e_5709;
    localparam[31:0] _e_5710 = 32'd1431655765;
    assign _e_5706 = _e_5707 & _e_5710;
    assign x_n1 = \x  - _e_5706;
    localparam[32:0] _e_5715 = 33'd858993459;
    assign _e_5713 = x_n1 & _e_5715;
    localparam[32:0] _e_5719 = 33'd2;
    assign _e_5717 = x_n1 >> _e_5719;
    localparam[32:0] _e_5720 = 33'd858993459;
    assign _e_5716 = _e_5717 & _e_5720;
    assign x_n2 = _e_5713 + _e_5716;
    localparam[33:0] _e_5727 = 34'd4;
    assign _e_5725 = x_n2 >> _e_5727;
    assign _e_5723 = x_n2 + _e_5725;
    localparam[34:0] _e_5728 = 35'd252645135;
    assign x_n3 = _e_5723 & _e_5728;
    localparam[34:0] _e_5734 = 35'd8;
    assign _e_5732 = x_n3 >> _e_5734;
    assign x_n4 = x_n3 + _e_5732;
    localparam[35:0] _e_5740 = 36'd16;
    assign _e_5738 = x_n4 >> _e_5740;
    assign x_n5 = x_n4 + _e_5738;
    localparam[36:0] _e_5745 = 37'd63;
    assign _e_5743 = x_n5 & _e_5745;
    assign _e_5742 = _e_5743[31:0];
    assign output__ = _e_5742;
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
    (* src = "src/bit.spade:96,15" *)
    logic[31:0] \lsb ;
    (* src = "src/bit.spade:97,25" *)
    logic[31:0] _e_5752;
    (* src = "src/bit.spade:97,25" *)
    logic[31:0] \width_minus_1 ;
    (* src = "src/bit.spade:103,19" *)
    logic _e_5758;
    (* src = "src/bit.spade:106,21" *)
    logic[32:0] _e_5768;
    (* src = "src/bit.spade:106,15" *)
    logic[32:0] _e_5766;
    (* src = "src/bit.spade:106,15" *)
    logic[33:0] _e_5765;
    (* src = "src/bit.spade:106,9" *)
    logic[31:0] _e_5764;
    (* src = "src/bit.spade:103,16" *)
    logic[31:0] \mask ;
    (* src = "src/bit.spade:109,5" *)
    logic[31:0] _e_5774;
    (* src = "src/bit.spade:109,5" *)
    logic[31:0] _e_5773;
    localparam[31:0] _e_5749 = 32'd31;
    assign \lsb  = \ctrl  & _e_5749;
    localparam[31:0] _e_5754 = 32'd5;
    assign _e_5752 = \ctrl  >> _e_5754;
    localparam[31:0] _e_5755 = 32'd31;
    assign \width_minus_1  = _e_5752 & _e_5755;
    localparam[31:0] _e_5760 = 32'd31;
    assign _e_5758 = \width_minus_1  == _e_5760;
    localparam[31:0] _e_5762 = 32'd4294967295;
    localparam[32:0] _e_5767 = 33'd1;
    localparam[31:0] _e_5770 = 32'd1;
    assign _e_5768 = \width_minus_1  + _e_5770;
    assign _e_5766 = _e_5767 << _e_5768;
    localparam[32:0] _e_5771 = 33'd1;
    assign _e_5765 = _e_5766 - _e_5771;
    assign _e_5764 = _e_5765[31:0];
    assign \mask  = _e_5758 ? _e_5762 : _e_5764;
    assign _e_5774 = \val  >> \lsb ;
    assign _e_5773 = _e_5774 & \mask ;
    assign output__ = _e_5773;
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
    (* src = "src/bit.spade:115,15" *)
    logic[31:0] \lsb ;
    (* src = "src/bit.spade:116,25" *)
    logic[31:0] _e_5784;
    (* src = "src/bit.spade:116,25" *)
    logic[31:0] \width_minus_1 ;
    (* src = "src/bit.spade:118,19" *)
    logic _e_5790;
    (* src = "src/bit.spade:121,21" *)
    logic[32:0] _e_5800;
    (* src = "src/bit.spade:121,15" *)
    logic[32:0] _e_5798;
    (* src = "src/bit.spade:121,15" *)
    logic[33:0] _e_5797;
    (* src = "src/bit.spade:121,9" *)
    logic[31:0] _e_5796;
    (* src = "src/bit.spade:118,16" *)
    logic[31:0] \mask ;
    (* src = "src/bit.spade:124,5" *)
    logic[31:0] _e_5806;
    (* src = "src/bit.spade:124,5" *)
    logic[31:0] _e_5805;
    localparam[31:0] _e_5781 = 32'd31;
    assign \lsb  = \ctrl  & _e_5781;
    localparam[31:0] _e_5786 = 32'd5;
    assign _e_5784 = \ctrl  >> _e_5786;
    localparam[31:0] _e_5787 = 32'd31;
    assign \width_minus_1  = _e_5784 & _e_5787;
    localparam[31:0] _e_5792 = 32'd31;
    assign _e_5790 = \width_minus_1  == _e_5792;
    localparam[31:0] _e_5794 = 32'd4294967295;
    localparam[32:0] _e_5799 = 33'd1;
    localparam[31:0] _e_5802 = 32'd1;
    assign _e_5800 = \width_minus_1  + _e_5802;
    assign _e_5798 = _e_5799 << _e_5800;
    localparam[32:0] _e_5803 = 33'd1;
    assign _e_5797 = _e_5798 - _e_5803;
    assign _e_5796 = _e_5797[31:0];
    assign \mask  = _e_5790 ? _e_5794 : _e_5796;
    assign _e_5806 = \val  & \mask ;
    assign _e_5805 = _e_5806 << \lsb ;
    assign output__ = _e_5805;
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
    (* src = "src/bit.spade:129,9" *)
    logic[42:0] _e_5814;
    (* src = "src/bit.spade:129,14" *)
    logic[31:0] \x ;
    logic _e_9604;
    logic _e_9606;
    logic _e_9608;
    logic _e_9609;
    (* src = "src/bit.spade:129,35" *)
    logic[32:0] _e_5816;
    (* src = "src/bit.spade:130,9" *)
    logic[43:0] \_ ;
    (* src = "src/bit.spade:131,13" *)
    logic[42:0] _e_5822;
    (* src = "src/bit.spade:131,18" *)
    logic[31:0] x_n1;
    logic _e_9612;
    logic _e_9614;
    logic _e_9616;
    logic _e_9617;
    (* src = "src/bit.spade:131,39" *)
    logic[32:0] _e_5824;
    (* src = "src/bit.spade:132,13" *)
    logic[43:0] __n1;
    (* src = "src/bit.spade:132,18" *)
    logic[32:0] _e_5827;
    (* src = "src/bit.spade:130,14" *)
    logic[32:0] _e_5819;
    (* src = "src/bit.spade:128,5" *)
    logic[32:0] _e_5811;
    assign _e_5814 = \m1 [42:0];
    assign \x  = _e_5814[36:5];
    assign _e_9604 = \m1 [43] == 1'd1;
    assign _e_9606 = _e_5814[42:37] == 6'd39;
    localparam[0:0] _e_9607 = 1;
    assign _e_9608 = _e_9606 && _e_9607;
    assign _e_9609 = _e_9604 && _e_9608;
    assign _e_5816 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9610 = 1;
    assign _e_5822 = \m0 [42:0];
    assign x_n1 = _e_5822[36:5];
    assign _e_9612 = \m0 [43] == 1'd1;
    assign _e_9614 = _e_5822[42:37] == 6'd39;
    localparam[0:0] _e_9615 = 1;
    assign _e_9616 = _e_9614 && _e_9615;
    assign _e_9617 = _e_9612 && _e_9616;
    assign _e_5824 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9618 = 1;
    assign _e_5827 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9617, _e_9618})
            2'b1?: _e_5819 = _e_5824;
            2'b01: _e_5819 = _e_5827;
            2'b?: _e_5819 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9609, _e_9610})
            2'b1?: _e_5811 = _e_5816;
            2'b01: _e_5811 = _e_5819;
            2'b?: _e_5811 = 33'dx;
        endcase
    end
    assign output__ = _e_5811;
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
    (* src = "src/bit.spade:138,9" *)
    logic[42:0] _e_5833;
    (* src = "src/bit.spade:138,14" *)
    logic[2:0] \op ;
    (* src = "src/bit.spade:138,14" *)
    logic[31:0] \x ;
    logic _e_9620;
    logic _e_9622;
    logic _e_9625;
    logic _e_9626;
    logic _e_9627;
    (* src = "src/bit.spade:138,44" *)
    logic[34:0] _e_5836;
    (* src = "src/bit.spade:138,39" *)
    logic[35:0] _e_5835;
    (* src = "src/bit.spade:139,9" *)
    logic[43:0] \_ ;
    (* src = "src/bit.spade:140,13" *)
    logic[42:0] _e_5844;
    (* src = "src/bit.spade:140,18" *)
    logic[2:0] op_n1;
    (* src = "src/bit.spade:140,18" *)
    logic[31:0] x_n1;
    logic _e_9630;
    logic _e_9632;
    logic _e_9635;
    logic _e_9636;
    logic _e_9637;
    (* src = "src/bit.spade:140,48" *)
    logic[34:0] _e_5847;
    (* src = "src/bit.spade:140,43" *)
    logic[35:0] _e_5846;
    (* src = "src/bit.spade:141,13" *)
    logic[43:0] __n1;
    (* src = "src/bit.spade:141,18" *)
    logic[35:0] _e_5851;
    (* src = "src/bit.spade:139,14" *)
    logic[35:0] _e_5840;
    (* src = "src/bit.spade:137,5" *)
    logic[35:0] _e_5829;
    assign _e_5833 = \m1 [42:0];
    assign \op  = _e_5833[36:34];
    assign \x  = _e_5833[33:2];
    assign _e_9620 = \m1 [43] == 1'd1;
    assign _e_9622 = _e_5833[42:37] == 6'd40;
    localparam[0:0] _e_9623 = 1;
    localparam[0:0] _e_9624 = 1;
    assign _e_9625 = _e_9622 && _e_9623;
    assign _e_9626 = _e_9625 && _e_9624;
    assign _e_9627 = _e_9620 && _e_9626;
    assign _e_5836 = {\op , \x };
    assign _e_5835 = {1'd1, _e_5836};
    assign \_  = \m1 ;
    localparam[0:0] _e_9628 = 1;
    assign _e_5844 = \m0 [42:0];
    assign op_n1 = _e_5844[36:34];
    assign x_n1 = _e_5844[33:2];
    assign _e_9630 = \m0 [43] == 1'd1;
    assign _e_9632 = _e_5844[42:37] == 6'd40;
    localparam[0:0] _e_9633 = 1;
    localparam[0:0] _e_9634 = 1;
    assign _e_9635 = _e_9632 && _e_9633;
    assign _e_9636 = _e_9635 && _e_9634;
    assign _e_9637 = _e_9630 && _e_9636;
    assign _e_5847 = {op_n1, x_n1};
    assign _e_5846 = {1'd1, _e_5847};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9638 = 1;
    assign _e_5851 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_9637, _e_9638})
            2'b1?: _e_5840 = _e_5846;
            2'b01: _e_5840 = _e_5851;
            2'b?: _e_5840 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9627, _e_9628})
            2'b1?: _e_5829 = _e_5835;
            2'b01: _e_5829 = _e_5840;
            2'b?: _e_5829 = 36'dx;
        endcase
    end
    assign output__ = _e_5829;
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
    (* src = "src/mac.spade:21,9" *)
    logic[31:0] \val ;
    logic _e_9640;
    logic _e_9642;
    logic _e_9644;
    (* src = "src/mac.spade:20,45" *)
    logic[31:0] _e_5857;
    (* src = "src/mac.spade:20,14" *)
    reg[31:0] \op_a ;
    (* src = "src/mac.spade:33,17" *)
    logic[31:0] \op_b ;
    logic _e_9646;
    logic _e_9648;
    (* src = "src/mac.spade:36,48" *)
    logic[63:0] _e_5880;
    (* src = "src/mac.spade:36,42" *)
    logic[31:0] \prod ;
    (* src = "src/mac.spade:37,27" *)
    logic[32:0] _e_5885;
    (* src = "src/mac.spade:37,21" *)
    logic[31:0] _e_5884;
    logic _e_9650;
    (* src = "src/mac.spade:32,13" *)
    logic[31:0] _e_5874;
    (* src = "src/mac.spade:29,9" *)
    logic[31:0] _e_5869;
    (* src = "src/mac.spade:28,14" *)
    reg[31:0] \acc ;
    (* src = "src/mac.spade:46,47" *)
    logic[32:0] _e_5893;
    (* src = "src/mac.spade:50,13" *)
    logic[32:0] _e_5898;
    (* src = "src/mac.spade:53,17" *)
    logic[31:0] op_b_n1;
    logic _e_9652;
    logic _e_9654;
    (* src = "src/mac.spade:55,48" *)
    logic[63:0] _e_5907;
    (* src = "src/mac.spade:55,42" *)
    logic[31:0] prod_n1;
    (* src = "src/mac.spade:56,32" *)
    logic[32:0] _e_5913;
    (* src = "src/mac.spade:56,26" *)
    logic[31:0] _e_5912;
    (* src = "src/mac.spade:56,21" *)
    logic[32:0] _e_5911;
    logic _e_9656;
    (* src = "src/mac.spade:58,25" *)
    logic[32:0] _e_5917;
    (* src = "src/mac.spade:52,13" *)
    logic[32:0] _e_5901;
    (* src = "src/mac.spade:47,9" *)
    logic[32:0] _e_5895;
    (* src = "src/mac.spade:46,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_5856 = 32'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9640 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9641 = 1;
    assign _e_9642 = _e_9640 && _e_9641;
    assign _e_9644 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9642, _e_9644})
            2'b1?: _e_5857 = \val ;
            2'b01: _e_5857 = \op_a ;
            2'b?: _e_5857 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_5856;
        end
        else begin
            \op_a  <= _e_5857;
        end
    end
    localparam[31:0] _e_5867 = 32'd0;
    localparam[31:0] _e_5872 = 32'd0;
    assign \op_b  = \trig [31:0];
    assign _e_9646 = \trig [32] == 1'd1;
    localparam[0:0] _e_9647 = 1;
    assign _e_9648 = _e_9646 && _e_9647;
    assign _e_5880 = \op_a  * \op_b ;
    assign \prod  = _e_5880[31:0];
    assign _e_5885 = \acc  + \prod ;
    assign _e_5884 = _e_5885[31:0];
    assign _e_9650 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9648, _e_9650})
            2'b1?: _e_5874 = _e_5884;
            2'b01: _e_5874 = \acc ;
            2'b?: _e_5874 = 32'dx;
        endcase
    end
    assign _e_5869 = \clr  ? _e_5872 : _e_5874;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \acc  <= _e_5867;
        end
        else begin
            \acc  <= _e_5869;
        end
    end
    assign _e_5893 = {1'd0, 32'bX};
    localparam[31:0] _e_5899 = 32'd0;
    assign _e_5898 = {1'd1, _e_5899};
    assign op_b_n1 = \trig [31:0];
    assign _e_9652 = \trig [32] == 1'd1;
    localparam[0:0] _e_9653 = 1;
    assign _e_9654 = _e_9652 && _e_9653;
    assign _e_5907 = \op_a  * op_b_n1;
    assign prod_n1 = _e_5907[31:0];
    assign _e_5913 = \acc  + prod_n1;
    assign _e_5912 = _e_5913[31:0];
    assign _e_5911 = {1'd1, _e_5912};
    assign _e_9656 = \trig [32] == 1'd0;
    assign _e_5917 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9654, _e_9656})
            2'b1?: _e_5901 = _e_5911;
            2'b01: _e_5901 = _e_5917;
            2'b?: _e_5901 = 33'dx;
        endcase
    end
    assign _e_5895 = \clr  ? _e_5898 : _e_5901;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_5893;
        end
        else begin
            \res  <= _e_5895;
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
    (* src = "src/mac.spade:68,9" *)
    logic[42:0] _e_5923;
    (* src = "src/mac.spade:68,14" *)
    logic[31:0] \x ;
    logic _e_9658;
    logic _e_9660;
    logic _e_9662;
    logic _e_9663;
    (* src = "src/mac.spade:68,35" *)
    logic[32:0] _e_5925;
    (* src = "src/mac.spade:69,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:70,13" *)
    logic[42:0] _e_5931;
    (* src = "src/mac.spade:70,18" *)
    logic[31:0] x_n1;
    logic _e_9666;
    logic _e_9668;
    logic _e_9670;
    logic _e_9671;
    (* src = "src/mac.spade:70,39" *)
    logic[32:0] _e_5933;
    (* src = "src/mac.spade:71,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:71,18" *)
    logic[32:0] _e_5936;
    (* src = "src/mac.spade:69,14" *)
    logic[32:0] _e_5928;
    (* src = "src/mac.spade:67,5" *)
    logic[32:0] _e_5920;
    assign _e_5923 = \m1 [42:0];
    assign \x  = _e_5923[36:5];
    assign _e_9658 = \m1 [43] == 1'd1;
    assign _e_9660 = _e_5923[42:37] == 6'd24;
    localparam[0:0] _e_9661 = 1;
    assign _e_9662 = _e_9660 && _e_9661;
    assign _e_9663 = _e_9658 && _e_9662;
    assign _e_5925 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9664 = 1;
    assign _e_5931 = \m0 [42:0];
    assign x_n1 = _e_5931[36:5];
    assign _e_9666 = \m0 [43] == 1'd1;
    assign _e_9668 = _e_5931[42:37] == 6'd24;
    localparam[0:0] _e_9669 = 1;
    assign _e_9670 = _e_9668 && _e_9669;
    assign _e_9671 = _e_9666 && _e_9670;
    assign _e_5933 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9672 = 1;
    assign _e_5936 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9671, _e_9672})
            2'b1?: _e_5928 = _e_5933;
            2'b01: _e_5928 = _e_5936;
            2'b?: _e_5928 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9663, _e_9664})
            2'b1?: _e_5920 = _e_5925;
            2'b01: _e_5920 = _e_5928;
            2'b?: _e_5920 = 33'dx;
        endcase
    end
    assign output__ = _e_5920;
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
    (* src = "src/mac.spade:78,9" *)
    logic[42:0] _e_5941;
    (* src = "src/mac.spade:78,14" *)
    logic[31:0] \x ;
    logic _e_9674;
    logic _e_9676;
    logic _e_9678;
    logic _e_9679;
    (* src = "src/mac.spade:78,35" *)
    logic[32:0] _e_5943;
    (* src = "src/mac.spade:79,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:80,13" *)
    logic[42:0] _e_5949;
    (* src = "src/mac.spade:80,18" *)
    logic[31:0] x_n1;
    logic _e_9682;
    logic _e_9684;
    logic _e_9686;
    logic _e_9687;
    (* src = "src/mac.spade:80,39" *)
    logic[32:0] _e_5951;
    (* src = "src/mac.spade:81,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:81,18" *)
    logic[32:0] _e_5954;
    (* src = "src/mac.spade:79,14" *)
    logic[32:0] _e_5946;
    (* src = "src/mac.spade:77,5" *)
    logic[32:0] _e_5938;
    assign _e_5941 = \m1 [42:0];
    assign \x  = _e_5941[36:5];
    assign _e_9674 = \m1 [43] == 1'd1;
    assign _e_9676 = _e_5941[42:37] == 6'd25;
    localparam[0:0] _e_9677 = 1;
    assign _e_9678 = _e_9676 && _e_9677;
    assign _e_9679 = _e_9674 && _e_9678;
    assign _e_5943 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9680 = 1;
    assign _e_5949 = \m0 [42:0];
    assign x_n1 = _e_5949[36:5];
    assign _e_9682 = \m0 [43] == 1'd1;
    assign _e_9684 = _e_5949[42:37] == 6'd25;
    localparam[0:0] _e_9685 = 1;
    assign _e_9686 = _e_9684 && _e_9685;
    assign _e_9687 = _e_9682 && _e_9686;
    assign _e_5951 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9688 = 1;
    assign _e_5954 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9687, _e_9688})
            2'b1?: _e_5946 = _e_5951;
            2'b01: _e_5946 = _e_5954;
            2'b?: _e_5946 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9679, _e_9680})
            2'b1?: _e_5938 = _e_5943;
            2'b01: _e_5938 = _e_5946;
            2'b?: _e_5938 = 33'dx;
        endcase
    end
    assign output__ = _e_5938;
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
    (* src = "src/mac.spade:88,9" *)
    logic[42:0] _e_5959;
    (* src = "src/mac.spade:88,14" *)
    logic \x ;
    logic _e_9690;
    logic _e_9692;
    logic _e_9694;
    logic _e_9695;
    (* src = "src/mac.spade:89,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:90,13" *)
    logic[42:0] _e_5966;
    (* src = "src/mac.spade:90,18" *)
    logic x_n1;
    logic _e_9698;
    logic _e_9700;
    logic _e_9702;
    logic _e_9703;
    (* src = "src/mac.spade:91,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:89,14" *)
    logic _e_5963;
    (* src = "src/mac.spade:87,5" *)
    logic _e_5956;
    assign _e_5959 = \m1 [42:0];
    assign \x  = _e_5959[36:36];
    assign _e_9690 = \m1 [43] == 1'd1;
    assign _e_9692 = _e_5959[42:37] == 6'd26;
    localparam[0:0] _e_9693 = 1;
    assign _e_9694 = _e_9692 && _e_9693;
    assign _e_9695 = _e_9690 && _e_9694;
    assign \_  = \m1 ;
    localparam[0:0] _e_9696 = 1;
    assign _e_5966 = \m0 [42:0];
    assign x_n1 = _e_5966[36:36];
    assign _e_9698 = \m0 [43] == 1'd1;
    assign _e_9700 = _e_5966[42:37] == 6'd26;
    localparam[0:0] _e_9701 = 1;
    assign _e_9702 = _e_9700 && _e_9701;
    assign _e_9703 = _e_9698 && _e_9702;
    assign __n1 = \m0 ;
    localparam[0:0] _e_9704 = 1;
    localparam[0:0] _e_5970 = 0;
    always_comb begin
        priority casez ({_e_9703, _e_9704})
            2'b1?: _e_5963 = x_n1;
            2'b01: _e_5963 = _e_5970;
            2'b?: _e_5963 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9695, _e_9696})
            2'b1?: _e_5956 = \x ;
            2'b01: _e_5956 = _e_5963;
            2'b?: _e_5956 = 1'dx;
        endcase
    end
    assign output__ = _e_5956;
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
    logic[34:0] _e_5976;
    (* src = "src/cmpz.spade:28,14" *)
    logic[2:0] _e_5974;
    (* src = "src/cmpz.spade:28,14" *)
    logic[31:0] \b ;
    logic _e_9706;
    logic _e_9709;
    logic _e_9711;
    logic _e_9712;
    (* src = "src/cmpz.spade:28,47" *)
    logic _e_5980;
    (* src = "src/cmpz.spade:28,40" *)
    logic[31:0] _e_5979;
    (* src = "src/cmpz.spade:28,35" *)
    logic[32:0] _e_5978;
    (* src = "src/cmpz.spade:29,9" *)
    logic[34:0] _e_5985;
    (* src = "src/cmpz.spade:29,14" *)
    logic[2:0] _e_5983;
    (* src = "src/cmpz.spade:29,14" *)
    logic[31:0] b_n1;
    logic _e_9714;
    logic _e_9717;
    logic _e_9719;
    logic _e_9720;
    (* src = "src/cmpz.spade:29,48" *)
    logic _e_5989;
    (* src = "src/cmpz.spade:29,41" *)
    logic[31:0] _e_5988;
    (* src = "src/cmpz.spade:29,36" *)
    logic[32:0] _e_5987;
    (* src = "src/cmpz.spade:30,9" *)
    logic[34:0] _e_5994;
    (* src = "src/cmpz.spade:30,14" *)
    logic[2:0] _e_5992;
    (* src = "src/cmpz.spade:30,14" *)
    logic[31:0] b_n2;
    logic _e_9722;
    logic _e_9725;
    logic _e_9727;
    logic _e_9728;
    (* src = "src/cmpz.spade:30,48" *)
    logic _e_5999;
    (* src = "src/cmpz.spade:30,48" *)
    logic _e_5998;
    (* src = "src/cmpz.spade:30,41" *)
    logic[31:0] _e_5997;
    (* src = "src/cmpz.spade:30,36" *)
    logic[32:0] _e_5996;
    (* src = "src/cmpz.spade:31,9" *)
    logic[34:0] _e_6004;
    (* src = "src/cmpz.spade:31,14" *)
    logic[2:0] _e_6002;
    (* src = "src/cmpz.spade:31,14" *)
    logic[31:0] b_n3;
    logic _e_9730;
    logic _e_9733;
    logic _e_9735;
    logic _e_9736;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6010;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6009;
    (* src = "src/cmpz.spade:31,67" *)
    logic _e_6013;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_6008;
    (* src = "src/cmpz.spade:31,42" *)
    logic[31:0] _e_6007;
    (* src = "src/cmpz.spade:31,37" *)
    logic[32:0] _e_6006;
    (* src = "src/cmpz.spade:32,9" *)
    logic[34:0] _e_6018;
    (* src = "src/cmpz.spade:32,14" *)
    logic[2:0] _e_6016;
    (* src = "src/cmpz.spade:32,14" *)
    logic[31:0] b_n4;
    logic _e_9738;
    logic _e_9741;
    logic _e_9743;
    logic _e_9744;
    (* src = "src/cmpz.spade:32,48" *)
    logic _e_6024;
    (* src = "src/cmpz.spade:32,48" *)
    logic _e_6023;
    (* src = "src/cmpz.spade:32,66" *)
    logic _e_6027;
    (* src = "src/cmpz.spade:32,48" *)
    logic _e_6022;
    (* src = "src/cmpz.spade:32,41" *)
    logic[31:0] _e_6021;
    (* src = "src/cmpz.spade:32,36" *)
    logic[32:0] _e_6020;
    (* src = "src/cmpz.spade:33,9" *)
    logic[34:0] _e_6032;
    (* src = "src/cmpz.spade:33,14" *)
    logic[2:0] _e_6030;
    (* src = "src/cmpz.spade:33,14" *)
    logic[31:0] b_n5;
    logic _e_9746;
    logic _e_9749;
    logic _e_9751;
    logic _e_9752;
    (* src = "src/cmpz.spade:33,48" *)
    logic _e_6037;
    (* src = "src/cmpz.spade:33,48" *)
    logic _e_6036;
    (* src = "src/cmpz.spade:33,41" *)
    logic[31:0] _e_6035;
    (* src = "src/cmpz.spade:33,36" *)
    logic[32:0] _e_6034;
    logic _e_9754;
    (* src = "src/cmpz.spade:34,34" *)
    logic[32:0] _e_6041;
    (* src = "src/cmpz.spade:27,36" *)
    logic[32:0] \result ;
    (* src = "src/cmpz.spade:38,51" *)
    logic[32:0] _e_6046;
    (* src = "src/cmpz.spade:38,14" *)
    reg[32:0] \res_reg ;
    assign _e_5976 = \trig [34:0];
    assign _e_5974 = _e_5976[34:32];
    assign \b  = _e_5976[31:0];
    assign _e_9706 = \trig [35] == 1'd1;
    assign _e_9709 = _e_5974[2:0] == 3'd0;
    localparam[0:0] _e_9710 = 1;
    assign _e_9711 = _e_9709 && _e_9710;
    assign _e_9712 = _e_9706 && _e_9711;
    localparam[31:0] _e_5982 = 32'd0;
    assign _e_5980 = \b  == _e_5982;
    (* src = "src/cmpz.spade:28,40" *)
    \tta::cmpz::to_u32  to_u32_0(.x_i(_e_5980), .output__(_e_5979));
    assign _e_5978 = {1'd1, _e_5979};
    assign _e_5985 = \trig [34:0];
    assign _e_5983 = _e_5985[34:32];
    assign b_n1 = _e_5985[31:0];
    assign _e_9714 = \trig [35] == 1'd1;
    assign _e_9717 = _e_5983[2:0] == 3'd1;
    localparam[0:0] _e_9718 = 1;
    assign _e_9719 = _e_9717 && _e_9718;
    assign _e_9720 = _e_9714 && _e_9719;
    localparam[31:0] _e_5991 = 32'd0;
    assign _e_5989 = b_n1 != _e_5991;
    (* src = "src/cmpz.spade:29,41" *)
    \tta::cmpz::to_u32  to_u32_1(.x_i(_e_5989), .output__(_e_5988));
    assign _e_5987 = {1'd1, _e_5988};
    assign _e_5994 = \trig [34:0];
    assign _e_5992 = _e_5994[34:32];
    assign b_n2 = _e_5994[31:0];
    assign _e_9722 = \trig [35] == 1'd1;
    assign _e_9725 = _e_5992[2:0] == 3'd2;
    localparam[0:0] _e_9726 = 1;
    assign _e_9727 = _e_9725 && _e_9726;
    assign _e_9728 = _e_9722 && _e_9727;
    (* src = "src/cmpz.spade:30,48" *)
    \tta::cmpz::msb1  msb1_0(.x_i(b_n2), .output__(_e_5999));
    localparam[0:0] _e_6001 = 1;
    assign _e_5998 = _e_5999 == _e_6001;
    (* src = "src/cmpz.spade:30,41" *)
    \tta::cmpz::to_u32  to_u32_2(.x_i(_e_5998), .output__(_e_5997));
    assign _e_5996 = {1'd1, _e_5997};
    assign _e_6004 = \trig [34:0];
    assign _e_6002 = _e_6004[34:32];
    assign b_n3 = _e_6004[31:0];
    assign _e_9730 = \trig [35] == 1'd1;
    assign _e_9733 = _e_6002[2:0] == 3'd3;
    localparam[0:0] _e_9734 = 1;
    assign _e_9735 = _e_9733 && _e_9734;
    assign _e_9736 = _e_9730 && _e_9735;
    (* src = "src/cmpz.spade:31,49" *)
    \tta::cmpz::msb1  msb1_1(.x_i(b_n3), .output__(_e_6010));
    localparam[0:0] _e_6012 = 1;
    assign _e_6009 = _e_6010 == _e_6012;
    localparam[31:0] _e_6015 = 32'd0;
    assign _e_6013 = b_n3 == _e_6015;
    assign _e_6008 = _e_6009 || _e_6013;
    (* src = "src/cmpz.spade:31,42" *)
    \tta::cmpz::to_u32  to_u32_3(.x_i(_e_6008), .output__(_e_6007));
    assign _e_6006 = {1'd1, _e_6007};
    assign _e_6018 = \trig [34:0];
    assign _e_6016 = _e_6018[34:32];
    assign b_n4 = _e_6018[31:0];
    assign _e_9738 = \trig [35] == 1'd1;
    assign _e_9741 = _e_6016[2:0] == 3'd4;
    localparam[0:0] _e_9742 = 1;
    assign _e_9743 = _e_9741 && _e_9742;
    assign _e_9744 = _e_9738 && _e_9743;
    (* src = "src/cmpz.spade:32,48" *)
    \tta::cmpz::msb1  msb1_2(.x_i(b_n4), .output__(_e_6024));
    localparam[0:0] _e_6026 = 1;
    assign _e_6023 = _e_6024 != _e_6026;
    localparam[31:0] _e_6029 = 32'd0;
    assign _e_6027 = b_n4 != _e_6029;
    assign _e_6022 = _e_6023 && _e_6027;
    (* src = "src/cmpz.spade:32,41" *)
    \tta::cmpz::to_u32  to_u32_4(.x_i(_e_6022), .output__(_e_6021));
    assign _e_6020 = {1'd1, _e_6021};
    assign _e_6032 = \trig [34:0];
    assign _e_6030 = _e_6032[34:32];
    assign b_n5 = _e_6032[31:0];
    assign _e_9746 = \trig [35] == 1'd1;
    assign _e_9749 = _e_6030[2:0] == 3'd5;
    localparam[0:0] _e_9750 = 1;
    assign _e_9751 = _e_9749 && _e_9750;
    assign _e_9752 = _e_9746 && _e_9751;
    (* src = "src/cmpz.spade:33,48" *)
    \tta::cmpz::msb1  msb1_3(.x_i(b_n5), .output__(_e_6037));
    localparam[0:0] _e_6039 = 1;
    assign _e_6036 = _e_6037 != _e_6039;
    (* src = "src/cmpz.spade:33,41" *)
    \tta::cmpz::to_u32  to_u32_5(.x_i(_e_6036), .output__(_e_6035));
    assign _e_6034 = {1'd1, _e_6035};
    assign _e_9754 = \trig [35] == 1'd0;
    assign _e_6041 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9712, _e_9720, _e_9728, _e_9736, _e_9744, _e_9752, _e_9754})
            7'b1??????: \result  = _e_5978;
            7'b01?????: \result  = _e_5987;
            7'b001????: \result  = _e_5996;
            7'b0001???: \result  = _e_6006;
            7'b00001??: \result  = _e_6020;
            7'b000001?: \result  = _e_6034;
            7'b0000001: \result  = _e_6041;
            7'b?: \result  = 33'dx;
        endcase
    end
    assign _e_6046 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_6046;
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
    (* src = "src/cmpz.spade:44,9" *)
    logic[42:0] _e_6054;
    (* src = "src/cmpz.spade:44,14" *)
    logic[2:0] \op ;
    (* src = "src/cmpz.spade:44,14" *)
    logic[31:0] \x ;
    logic _e_9756;
    logic _e_9758;
    logic _e_9761;
    logic _e_9762;
    logic _e_9763;
    (* src = "src/cmpz.spade:44,45" *)
    logic[34:0] _e_6057;
    (* src = "src/cmpz.spade:44,40" *)
    logic[35:0] _e_6056;
    (* src = "src/cmpz.spade:45,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmpz.spade:46,13" *)
    logic[42:0] _e_6065;
    (* src = "src/cmpz.spade:46,18" *)
    logic[2:0] op_n1;
    (* src = "src/cmpz.spade:46,18" *)
    logic[31:0] x_n1;
    logic _e_9766;
    logic _e_9768;
    logic _e_9771;
    logic _e_9772;
    logic _e_9773;
    (* src = "src/cmpz.spade:46,49" *)
    logic[34:0] _e_6068;
    (* src = "src/cmpz.spade:46,44" *)
    logic[35:0] _e_6067;
    (* src = "src/cmpz.spade:47,13" *)
    logic[43:0] __n1;
    (* src = "src/cmpz.spade:47,18" *)
    logic[35:0] _e_6072;
    (* src = "src/cmpz.spade:45,14" *)
    logic[35:0] _e_6061;
    (* src = "src/cmpz.spade:43,5" *)
    logic[35:0] _e_6050;
    assign _e_6054 = \m1 [42:0];
    assign \op  = _e_6054[36:34];
    assign \x  = _e_6054[33:2];
    assign _e_9756 = \m1 [43] == 1'd1;
    assign _e_9758 = _e_6054[42:37] == 6'd13;
    localparam[0:0] _e_9759 = 1;
    localparam[0:0] _e_9760 = 1;
    assign _e_9761 = _e_9758 && _e_9759;
    assign _e_9762 = _e_9761 && _e_9760;
    assign _e_9763 = _e_9756 && _e_9762;
    assign _e_6057 = {\op , \x };
    assign _e_6056 = {1'd1, _e_6057};
    assign \_  = \m1 ;
    localparam[0:0] _e_9764 = 1;
    assign _e_6065 = \m0 [42:0];
    assign op_n1 = _e_6065[36:34];
    assign x_n1 = _e_6065[33:2];
    assign _e_9766 = \m0 [43] == 1'd1;
    assign _e_9768 = _e_6065[42:37] == 6'd13;
    localparam[0:0] _e_9769 = 1;
    localparam[0:0] _e_9770 = 1;
    assign _e_9771 = _e_9768 && _e_9769;
    assign _e_9772 = _e_9771 && _e_9770;
    assign _e_9773 = _e_9766 && _e_9772;
    assign _e_6068 = {op_n1, x_n1};
    assign _e_6067 = {1'd1, _e_6068};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9774 = 1;
    assign _e_6072 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_9773, _e_9774})
            2'b1?: _e_6061 = _e_6067;
            2'b01: _e_6061 = _e_6072;
            2'b?: _e_6061 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9763, _e_9764})
            2'b1?: _e_6050 = _e_6056;
            2'b01: _e_6050 = _e_6061;
            2'b?: _e_6050 = 36'dx;
        endcase
    end
    assign output__ = _e_6050;
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
    (* src = "src/cmpz.spade:52,41" *)
    logic[31:0] _e_6076;
    (* src = "src/cmpz.spade:52,41" *)
    logic[31:0] _e_6075;
    (* src = "src/cmpz.spade:52,35" *)
    logic _e_6074;
    localparam[31:0] _e_6078 = 32'd31;
    assign _e_6076 = \x  >> _e_6078;
    localparam[31:0] _e_6079 = 32'd1;
    assign _e_6075 = _e_6076 & _e_6079;
    assign _e_6074 = _e_6075[0:0];
    assign output__ = _e_6074;
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
    (* src = "src/cmpz.spade:53,34" *)
    logic[31:0] _e_6081;
    localparam[31:0] _e_6084 = 32'd1;
    localparam[31:0] _e_6086 = 32'd0;
    assign _e_6081 = \x  ? _e_6084 : _e_6086;
    assign output__ = _e_6081;
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
    (* src = "src/div_shiftsub.spade:18,13" *)
    logic _e_6089;
    (* src = "src/div_shiftsub.spade:18,5" *)
    logic[134:0] _e_6088;
    assign _e_6089 = {1'd0};
    localparam[31:0] _e_6090 = 32'd0;
    localparam[31:0] _e_6091 = 32'd0;
    localparam[31:0] _e_6092 = 32'd0;
    localparam[31:0] _e_6093 = 32'd0;
    localparam[5:0] _e_6094 = 0;
    assign _e_6088 = {_e_6089, _e_6090, _e_6091, _e_6092, _e_6093, _e_6094};
    assign output__ = _e_6088;
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
    (* src = "src/div_shiftsub.spade:28,36" *)
    logic[134:0] _e_6099;
    (* src = "src/div_shiftsub.spade:28,57" *)
    logic _e_6101;
    (* src = "src/div_shiftsub.spade:29,9" *)
    logic _e_6103;
    logic _e_9776;
    (* src = "src/div_shiftsub.spade:32,17" *)
    logic[31:0] \val ;
    logic _e_9778;
    logic _e_9780;
    logic _e_9782;
    (* src = "src/div_shiftsub.spade:33,25" *)
    logic[31:0] _e_6111;
    (* src = "src/div_shiftsub.spade:31,33" *)
    logic[31:0] \next_dividend ;
    (* src = "src/div_shiftsub.spade:37,17" *)
    logic[31:0] \divisor ;
    logic _e_9784;
    logic _e_9786;
    (* src = "src/div_shiftsub.spade:37,42" *)
    logic _e_6119;
    (* src = "src/div_shiftsub.spade:37,34" *)
    logic[134:0] _e_6118;
    logic _e_9788;
    (* src = "src/div_shiftsub.spade:38,33" *)
    logic _e_6127;
    (* src = "src/div_shiftsub.spade:38,25" *)
    logic[134:0] _e_6126;
    (* src = "src/div_shiftsub.spade:36,13" *)
    logic[134:0] _e_6114;
    (* src = "src/div_shiftsub.spade:41,9" *)
    logic _e_6133;
    logic _e_9790;
    (* src = "src/div_shiftsub.spade:44,33" *)
    logic[31:0] _e_6136;
    (* src = "src/div_shiftsub.spade:44,32" *)
    logic[31:0] \msb_dividend ;
    (* src = "src/div_shiftsub.spade:45,32" *)
    logic[31:0] _e_6142;
    (* src = "src/div_shiftsub.spade:45,31" *)
    logic[31:0] _e_6141;
    (* src = "src/div_shiftsub.spade:45,31" *)
    logic[31:0] \rem_shifted ;
    (* src = "src/div_shiftsub.spade:46,31" *)
    logic[31:0] _e_6148;
    (* src = "src/div_shiftsub.spade:46,31" *)
    logic[31:0] \dvd_shifted ;
    (* src = "src/div_shiftsub.spade:49,42" *)
    logic[31:0] _e_6154;
    (* src = "src/div_shiftsub.spade:49,27" *)
    logic \can_sub ;
    (* src = "src/div_shiftsub.spade:53,38" *)
    logic[31:0] _e_6164;
    (* src = "src/div_shiftsub.spade:53,24" *)
    logic[32:0] _e_6162;
    (* src = "src/div_shiftsub.spade:53,18" *)
    logic[31:0] _e_6161;
    (* src = "src/div_shiftsub.spade:53,17" *)
    logic[63:0] _e_6160;
    (* src = "src/div_shiftsub.spade:55,17" *)
    logic[63:0] _e_6168;
    (* src = "src/div_shiftsub.spade:52,40" *)
    logic[63:0] _e_6173;
    (* src = "src/div_shiftsub.spade:52,17" *)
    logic[31:0] \next_rem ;
    (* src = "src/div_shiftsub.spade:52,17" *)
    logic[31:0] \quot_bit ;
    (* src = "src/div_shiftsub.spade:58,30" *)
    logic[31:0] _e_6176;
    (* src = "src/div_shiftsub.spade:58,29" *)
    logic[31:0] _e_6175;
    (* src = "src/div_shiftsub.spade:58,29" *)
    logic[31:0] \next_quot ;
    (* src = "src/div_shiftsub.spade:60,16" *)
    logic[5:0] _e_6183;
    (* src = "src/div_shiftsub.spade:60,16" *)
    logic _e_6182;
    (* src = "src/div_shiftsub.spade:62,17" *)
    logic[134:0] _e_6187;
    (* src = "src/div_shiftsub.spade:65,25" *)
    logic _e_6190;
    (* src = "src/div_shiftsub.spade:65,51" *)
    logic[31:0] _e_6192;
    (* src = "src/div_shiftsub.spade:65,89" *)
    logic[5:0] _e_6198;
    (* src = "src/div_shiftsub.spade:65,89" *)
    logic[6:0] _e_6197;
    (* src = "src/div_shiftsub.spade:65,83" *)
    logic[5:0] _e_6196;
    (* src = "src/div_shiftsub.spade:65,17" *)
    logic[134:0] _e_6189;
    (* src = "src/div_shiftsub.spade:60,13" *)
    logic[134:0] _e_6181;
    (* src = "src/div_shiftsub.spade:28,51" *)
    logic[134:0] _e_6100;
    (* src = "src/div_shiftsub.spade:28,14" *)
    reg[134:0] \r ;
    (* src = "src/div_shiftsub.spade:74,11" *)
    logic _e_6202;
    (* src = "src/div_shiftsub.spade:75,9" *)
    logic _e_6204;
    logic _e_9792;
    (* src = "src/div_shiftsub.spade:76,16" *)
    logic[5:0] _e_6208;
    (* src = "src/div_shiftsub.spade:76,16" *)
    logic _e_6207;
    (* src = "src/div_shiftsub.spade:78,37" *)
    logic[31:0] _e_6213;
    (* src = "src/div_shiftsub.spade:78,36" *)
    logic[31:0] msb_dividend_n1;
    (* src = "src/div_shiftsub.spade:79,36" *)
    logic[31:0] _e_6219;
    (* src = "src/div_shiftsub.spade:79,35" *)
    logic[31:0] _e_6218;
    (* src = "src/div_shiftsub.spade:79,35" *)
    logic[31:0] rem_shifted_n1;
    (* src = "src/div_shiftsub.spade:80,46" *)
    logic[31:0] _e_6226;
    (* src = "src/div_shiftsub.spade:80,31" *)
    logic can_sub_n1;
    (* src = "src/div_shiftsub.spade:81,32" *)
    logic[31:0] quot_bit_n1;
    (* src = "src/div_shiftsub.spade:83,23" *)
    logic[31:0] _e_6239;
    (* src = "src/div_shiftsub.spade:83,22" *)
    logic[31:0] _e_6238;
    (* src = "src/div_shiftsub.spade:83,22" *)
    logic[31:0] _e_6237;
    (* src = "src/div_shiftsub.spade:83,17" *)
    logic[32:0] _e_6236;
    (* src = "src/div_shiftsub.spade:85,17" *)
    logic[32:0] _e_6244;
    (* src = "src/div_shiftsub.spade:76,13" *)
    logic[32:0] _e_6206;
    (* src = "src/div_shiftsub.spade:88,9" *)
    logic \_ ;
    (* src = "src/div_shiftsub.spade:88,14" *)
    logic[32:0] _e_6246;
    (* src = "src/div_shiftsub.spade:74,5" *)
    logic[32:0] _e_6201;
    (* src = "src/div_shiftsub.spade:28,36" *)
    \tta::div_shiftsub::reset_div  reset_div_0(.output__(_e_6099));
    assign _e_6101 = \r [134];
    assign _e_6103 = _e_6101;
    assign _e_9776 = _e_6101 == 1'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9778 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9779 = 1;
    assign _e_9780 = _e_9778 && _e_9779;
    assign _e_9782 = \set_op_a [32] == 1'd0;
    assign _e_6111 = \r [133:102];
    always_comb begin
        priority casez ({_e_9780, _e_9782})
            2'b1?: \next_dividend  = \val ;
            2'b01: \next_dividend  = _e_6111;
            2'b?: \next_dividend  = 32'dx;
        endcase
    end
    assign \divisor  = \trig [31:0];
    assign _e_9784 = \trig [32] == 1'd1;
    localparam[0:0] _e_9785 = 1;
    assign _e_9786 = _e_9784 && _e_9785;
    assign _e_6119 = {1'd1};
    localparam[31:0] _e_6122 = 32'd0;
    localparam[31:0] _e_6123 = 32'd0;
    localparam[5:0] _e_6124 = 0;
    assign _e_6118 = {_e_6119, \next_dividend , \divisor , _e_6122, _e_6123, _e_6124};
    assign _e_9788 = \trig [32] == 1'd0;
    assign _e_6127 = {1'd0};
    localparam[31:0] _e_6129 = 32'd0;
    localparam[31:0] _e_6130 = 32'd0;
    localparam[31:0] _e_6131 = 32'd0;
    localparam[5:0] _e_6132 = 0;
    assign _e_6126 = {_e_6127, \next_dividend , _e_6129, _e_6130, _e_6131, _e_6132};
    always_comb begin
        priority casez ({_e_9786, _e_9788})
            2'b1?: _e_6114 = _e_6118;
            2'b01: _e_6114 = _e_6126;
            2'b?: _e_6114 = 135'dx;
        endcase
    end
    assign _e_6133 = _e_6101;
    assign _e_9790 = _e_6101 == 1'd1;
    assign _e_6136 = \r [133:102];
    localparam[31:0] _e_6138 = 32'd31;
    assign \msb_dividend  = _e_6136 >> _e_6138;
    assign _e_6142 = \r [69:38];
    localparam[31:0] _e_6144 = 32'd1;
    assign _e_6141 = _e_6142 << _e_6144;
    assign \rem_shifted  = _e_6141 | \msb_dividend ;
    assign _e_6148 = \r [133:102];
    localparam[31:0] _e_6150 = 32'd1;
    assign \dvd_shifted  = _e_6148 << _e_6150;
    assign _e_6154 = \r [101:70];
    assign \can_sub  = \rem_shifted  >= _e_6154;
    assign _e_6164 = \r [101:70];
    assign _e_6162 = \rem_shifted  - _e_6164;
    assign _e_6161 = _e_6162[31:0];
    localparam[31:0] _e_6166 = 32'd1;
    assign _e_6160 = {_e_6161, _e_6166};
    localparam[31:0] _e_6170 = 32'd0;
    assign _e_6168 = {\rem_shifted , _e_6170};
    assign _e_6173 = \can_sub  ? _e_6160 : _e_6168;
    assign \next_rem  = _e_6173[63:32];
    assign \quot_bit  = _e_6173[31:0];
    assign _e_6176 = \r [37:6];
    localparam[31:0] _e_6178 = 32'd1;
    assign _e_6175 = _e_6176 << _e_6178;
    assign \next_quot  = _e_6175 | \quot_bit ;
    assign _e_6183 = \r [5:0];
    localparam[5:0] _e_6185 = 31;
    assign _e_6182 = _e_6183 == _e_6185;
    (* src = "src/div_shiftsub.spade:62,17" *)
    \tta::div_shiftsub::reset_div  reset_div_1(.output__(_e_6187));
    assign _e_6190 = {1'd1};
    assign _e_6192 = \r [101:70];
    assign _e_6198 = \r [5:0];
    localparam[5:0] _e_6200 = 1;
    assign _e_6197 = _e_6198 + _e_6200;
    assign _e_6196 = _e_6197[5:0];
    assign _e_6189 = {_e_6190, \dvd_shifted , _e_6192, \next_rem , \next_quot , _e_6196};
    assign _e_6181 = _e_6182 ? _e_6187 : _e_6189;
    always_comb begin
        priority casez ({_e_9776, _e_9790})
            2'b1?: _e_6100 = _e_6114;
            2'b01: _e_6100 = _e_6181;
            2'b?: _e_6100 = 135'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_6099;
        end
        else begin
            \r  <= _e_6100;
        end
    end
    assign _e_6202 = \r [134];
    assign _e_6204 = _e_6202;
    assign _e_9792 = _e_6202 == 1'd1;
    assign _e_6208 = \r [5:0];
    localparam[5:0] _e_6210 = 31;
    assign _e_6207 = _e_6208 == _e_6210;
    assign _e_6213 = \r [133:102];
    localparam[31:0] _e_6215 = 32'd31;
    assign msb_dividend_n1 = _e_6213 >> _e_6215;
    assign _e_6219 = \r [69:38];
    localparam[31:0] _e_6221 = 32'd1;
    assign _e_6218 = _e_6219 << _e_6221;
    assign rem_shifted_n1 = _e_6218 | msb_dividend_n1;
    assign _e_6226 = \r [101:70];
    assign can_sub_n1 = rem_shifted_n1 >= _e_6226;
    localparam[31:0] _e_6232 = 32'd1;
    localparam[31:0] _e_6234 = 32'd0;
    assign quot_bit_n1 = can_sub_n1 ? _e_6232 : _e_6234;
    assign _e_6239 = \r [37:6];
    localparam[31:0] _e_6241 = 32'd1;
    assign _e_6238 = _e_6239 << _e_6241;
    assign _e_6237 = _e_6238 | quot_bit_n1;
    assign _e_6236 = {1'd1, _e_6237};
    assign _e_6244 = {1'd0, 32'bX};
    assign _e_6206 = _e_6207 ? _e_6236 : _e_6244;
    assign \_  = _e_6202;
    localparam[0:0] _e_9793 = 1;
    assign _e_6246 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9792, _e_9793})
            2'b1?: _e_6201 = _e_6206;
            2'b01: _e_6201 = _e_6246;
            2'b?: _e_6201 = 33'dx;
        endcase
    end
    assign output__ = _e_6201;
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
    (* src = "src/div_shiftsub.spade:94,5" *)
    logic[42:0] _e_6251;
    (* src = "src/div_shiftsub.spade:94,10" *)
    logic[31:0] \x ;
    logic _e_9795;
    logic _e_9797;
    logic _e_9799;
    logic _e_9800;
    (* src = "src/div_shiftsub.spade:94,31" *)
    logic[32:0] _e_6253;
    (* src = "src/div_shiftsub.spade:95,5" *)
    logic[43:0] \_ ;
    (* src = "src/div_shiftsub.spade:95,21" *)
    logic[42:0] _e_6259;
    (* src = "src/div_shiftsub.spade:95,26" *)
    logic[31:0] x_n1;
    logic _e_9803;
    logic _e_9805;
    logic _e_9807;
    logic _e_9808;
    (* src = "src/div_shiftsub.spade:95,47" *)
    logic[32:0] _e_6261;
    (* src = "src/div_shiftsub.spade:95,56" *)
    logic[43:0] __n1;
    (* src = "src/div_shiftsub.spade:95,61" *)
    logic[32:0] _e_6264;
    (* src = "src/div_shiftsub.spade:95,10" *)
    logic[32:0] _e_6256;
    (* src = "src/div_shiftsub.spade:93,3" *)
    logic[32:0] _e_6248;
    assign _e_6251 = \m1 [42:0];
    assign \x  = _e_6251[36:5];
    assign _e_9795 = \m1 [43] == 1'd1;
    assign _e_9797 = _e_6251[42:37] == 6'd21;
    localparam[0:0] _e_9798 = 1;
    assign _e_9799 = _e_9797 && _e_9798;
    assign _e_9800 = _e_9795 && _e_9799;
    assign _e_6253 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9801 = 1;
    assign _e_6259 = \m0 [42:0];
    assign x_n1 = _e_6259[36:5];
    assign _e_9803 = \m0 [43] == 1'd1;
    assign _e_9805 = _e_6259[42:37] == 6'd21;
    localparam[0:0] _e_9806 = 1;
    assign _e_9807 = _e_9805 && _e_9806;
    assign _e_9808 = _e_9803 && _e_9807;
    assign _e_6261 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9809 = 1;
    assign _e_6264 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9808, _e_9809})
            2'b1?: _e_6256 = _e_6261;
            2'b01: _e_6256 = _e_6264;
            2'b?: _e_6256 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9800, _e_9801})
            2'b1?: _e_6248 = _e_6253;
            2'b01: _e_6248 = _e_6256;
            2'b?: _e_6248 = 33'dx;
        endcase
    end
    assign output__ = _e_6248;
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
    (* src = "src/div_shiftsub.spade:101,5" *)
    logic[42:0] _e_6269;
    (* src = "src/div_shiftsub.spade:101,10" *)
    logic[31:0] \x ;
    logic _e_9811;
    logic _e_9813;
    logic _e_9815;
    logic _e_9816;
    (* src = "src/div_shiftsub.spade:101,31" *)
    logic[32:0] _e_6271;
    (* src = "src/div_shiftsub.spade:102,5" *)
    logic[43:0] \_ ;
    (* src = "src/div_shiftsub.spade:102,21" *)
    logic[42:0] _e_6277;
    (* src = "src/div_shiftsub.spade:102,26" *)
    logic[31:0] x_n1;
    logic _e_9819;
    logic _e_9821;
    logic _e_9823;
    logic _e_9824;
    (* src = "src/div_shiftsub.spade:102,47" *)
    logic[32:0] _e_6279;
    (* src = "src/div_shiftsub.spade:102,56" *)
    logic[43:0] __n1;
    (* src = "src/div_shiftsub.spade:102,61" *)
    logic[32:0] _e_6282;
    (* src = "src/div_shiftsub.spade:102,10" *)
    logic[32:0] _e_6274;
    (* src = "src/div_shiftsub.spade:100,3" *)
    logic[32:0] _e_6266;
    assign _e_6269 = \m1 [42:0];
    assign \x  = _e_6269[36:5];
    assign _e_9811 = \m1 [43] == 1'd1;
    assign _e_9813 = _e_6269[42:37] == 6'd22;
    localparam[0:0] _e_9814 = 1;
    assign _e_9815 = _e_9813 && _e_9814;
    assign _e_9816 = _e_9811 && _e_9815;
    assign _e_6271 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9817 = 1;
    assign _e_6277 = \m0 [42:0];
    assign x_n1 = _e_6277[36:5];
    assign _e_9819 = \m0 [43] == 1'd1;
    assign _e_9821 = _e_6277[42:37] == 6'd22;
    localparam[0:0] _e_9822 = 1;
    assign _e_9823 = _e_9821 && _e_9822;
    assign _e_9824 = _e_9819 && _e_9823;
    assign _e_6279 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9825 = 1;
    assign _e_6282 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9824, _e_9825})
            2'b1?: _e_6274 = _e_6279;
            2'b01: _e_6274 = _e_6282;
            2'b?: _e_6274 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9816, _e_9817})
            2'b1?: _e_6266 = _e_6271;
            2'b01: _e_6266 = _e_6274;
            2'b?: _e_6266 = 33'dx;
        endcase
    end
    assign output__ = _e_6266;
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
    (* src = "src/boot_imem_subsystem.spade:34,7" *)
    logic[7:0] \b ;
    logic _e_9827;
    logic _e_9829;
    (* src = "src/boot_imem_subsystem.spade:34,18" *)
    logic[8:0] _e_6288;
    logic _e_9831;
    (* src = "src/boot_imem_subsystem.spade:35,18" *)
    logic[8:0] _e_6292;
    (* src = "src/boot_imem_subsystem.spade:33,5" *)
    logic[8:0] _e_6297;
    (* src = "src/boot_imem_subsystem.spade:32,7" *)
    logic \byte_valid ;
    (* src = "src/boot_imem_subsystem.spade:32,7" *)
    logic[7:0] \byte ;
    (* src = "src/boot_imem_subsystem.spade:40,12" *)
    logic[88:0] \bl ;
    (* src = "src/boot_imem_subsystem.spade:49,25" *)
    logic _e_6306;
    (* src = "src/boot_imem_subsystem.spade:49,18" *)
    logic \core_rst ;
    (* src = "src/boot_imem_subsystem.spade:52,43" *)
    logic _e_6313;
    (* src = "src/boot_imem_subsystem.spade:52,12" *)
    reg \boot_q ;
    (* src = "src/boot_imem_subsystem.spade:53,36" *)
    logic _e_6318;
    (* src = "src/boot_imem_subsystem.spade:53,35" *)
    logic _e_6317;
    (* src = "src/boot_imem_subsystem.spade:53,25" *)
    logic \boot_fall ;
    (* src = "src/boot_imem_subsystem.spade:56,23" *)
    logic[10:0] _e_6324;
    (* src = "src/boot_imem_subsystem.spade:56,11" *)
    logic[11:0] _e_6322;
    (* src = "src/boot_imem_subsystem.spade:57,7" *)
    logic[11:0] _e_6329;
    (* src = "src/boot_imem_subsystem.spade:57,7" *)
    logic _e_6326;
    (* src = "src/boot_imem_subsystem.spade:57,7" *)
    logic[10:0] _e_6328;
    (* src = "src/boot_imem_subsystem.spade:57,14" *)
    logic[9:0] \e ;
    logic _e_9835;
    logic _e_9837;
    logic _e_9838;
    (* src = "src/boot_imem_subsystem.spade:57,26" *)
    logic[10:0] _e_6330;
    (* src = "src/boot_imem_subsystem.spade:58,7" *)
    logic[11:0] \_ ;
    (* src = "src/boot_imem_subsystem.spade:58,27" *)
    logic[10:0] _e_6333;
    (* src = "src/boot_imem_subsystem.spade:56,5" *)
    logic[10:0] \pc_release ;
    (* src = "src/boot_imem_subsystem.spade:66,13" *)
    logic[97:0] _e_6338;
    logic _e_9841;
    (* src = "src/boot_imem_subsystem.spade:72,11" *)
    logic[10:0] _e_6348;
    (* src = "src/boot_imem_subsystem.spade:72,23" *)
    logic[32:0] _e_6350;
    (* src = "src/boot_imem_subsystem.spade:72,36" *)
    logic[32:0] _e_6352;
    (* src = "src/boot_imem_subsystem.spade:68,13" *)
    logic[98:0] _e_6342;
    (* src = "src/boot_imem_subsystem.spade:74,11" *)
    logic[98:0] _e_6355;
    (* src = "src/boot_imem_subsystem.spade:74,11" *)
    logic[97:0] \v ;
    logic _e_9843;
    logic _e_9845;
    (* src = "src/boot_imem_subsystem.spade:75,11" *)
    logic[98:0] _e_6357;
    logic _e_9847;
    (* src = "src/boot_imem_subsystem.spade:75,19" *)
    logic[97:0] _e_6358;
    (* src = "src/boot_imem_subsystem.spade:68,7" *)
    logic[97:0] _e_6341;
    (* src = "src/boot_imem_subsystem.spade:65,15" *)
    logic[97:0] \instr ;
    (* src = "src/boot_imem_subsystem.spade:80,3" *)
    logic[109:0] _e_6360;
    assign \b  = \rx_opt [7:0];
    assign _e_9827 = \rx_opt [8] == 1'd1;
    localparam[0:0] _e_9828 = 1;
    assign _e_9829 = _e_9827 && _e_9828;
    localparam[0:0] _e_6289 = 1;
    assign _e_6288 = {_e_6289, \b };
    assign _e_9831 = \rx_opt [8] == 1'd0;
    localparam[0:0] _e_6293 = 0;
    localparam[7:0] _e_6294 = 0;
    assign _e_6292 = {_e_6293, _e_6294};
    always_comb begin
        priority casez ({_e_9829, _e_9831})
            2'b1?: _e_6297 = _e_6288;
            2'b01: _e_6297 = _e_6292;
            2'b?: _e_6297 = 9'dx;
        endcase
    end
    assign \byte_valid  = _e_6297[8];
    assign \byte  = _e_6297[7:0];
    (* src = "src/boot_imem_subsystem.spade:40,12" *)
    \tta::bootloader::bootloader  bootloader_0(.clk_i(\clk ), .rst_i(\rst ), .byte_valid_i(\byte_valid ), .byte_i(\byte ), .output__(\bl ));
    assign _e_6306 = \bl [88];
    assign \core_rst  = \rst  || _e_6306;
    localparam[0:0] _e_6312 = 1;
    assign _e_6313 = \bl [88];
    always @(posedge \clk ) begin
        if (\rst ) begin
            \boot_q  <= _e_6312;
        end
        else begin
            \boot_q  <= _e_6313;
        end
    end
    assign _e_6318 = \bl [88];
    assign _e_6317 = !_e_6318;
    assign \boot_fall  = \boot_q  && _e_6317;
    assign _e_6324 = \bl [10:0];
    assign _e_6322 = {\boot_fall , _e_6324};
    assign _e_6329 = _e_6322;
    assign _e_6326 = _e_6322[11];
    assign _e_6328 = _e_6322[10:0];
    assign \e  = _e_6328[9:0];
    assign _e_9835 = _e_6328[10] == 1'd1;
    localparam[0:0] _e_9836 = 1;
    assign _e_9837 = _e_9835 && _e_9836;
    assign _e_9838 = _e_6326 && _e_9837;
    assign _e_6330 = {1'd1, \e };
    assign \_  = _e_6322;
    localparam[0:0] _e_9839 = 1;
    assign _e_6333 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_9838, _e_9839})
            2'b1?: \pc_release  = _e_6330;
            2'b01: \pc_release  = _e_6333;
            2'b?: \pc_release  = 11'dx;
        endcase
    end
    (* src = "src/boot_imem_subsystem.spade:66,13" *)
    \tta::boot_imem_subsystem::no_op  no_op_0(.output__(_e_6338));
    assign _e_9841 = !\boot_q ;
    assign _e_6348 = \bl [87:77];
    assign _e_6350 = \bl [76:44];
    assign _e_6352 = \bl [43:11];
    (* src = "src/boot_imem_subsystem.spade:68,13" *)
    \tta::imem::imem  imem_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .boot_mode_i(\boot_q ), .fetch_pc_i(\fetch_pc ), .wr_addr_i(_e_6348), .wr_slot0_i(_e_6350), .wr_slot1_i(_e_6352), .output__(_e_6342));
    assign _e_6355 = _e_6342;
    assign \v  = _e_6342[97:0];
    assign _e_9843 = _e_6342[98] == 1'd1;
    localparam[0:0] _e_9844 = 1;
    assign _e_9845 = _e_9843 && _e_9844;
    assign _e_6357 = _e_6342;
    assign _e_9847 = _e_6342[98] == 1'd0;
    (* src = "src/boot_imem_subsystem.spade:75,19" *)
    \tta::boot_imem_subsystem::no_op  no_op_1(.output__(_e_6358));
    always_comb begin
        priority casez ({_e_9845, _e_9847})
            2'b1?: _e_6341 = \v ;
            2'b01: _e_6341 = _e_6358;
            2'b?: _e_6341 = 98'dx;
        endcase
    end
    always_comb begin
        priority casez ({\boot_q , _e_9841})
            2'b1?: \instr  = _e_6338;
            2'b01: \instr  = _e_6341;
            2'b?: \instr  = 98'dx;
        endcase
    end
    assign _e_6360 = {\core_rst , \instr , \pc_release };
    assign output__ = _e_6360;
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
    (* src = "src/boot_imem_subsystem.spade:86,16" *)
    logic[36:0] _e_6367;
    (* src = "src/boot_imem_subsystem.spade:86,27" *)
    logic[10:0] _e_6368;
    (* src = "src/boot_imem_subsystem.spade:86,11" *)
    logic[48:0] _e_6366;
    (* src = "src/boot_imem_subsystem.spade:87,16" *)
    logic[36:0] _e_6371;
    (* src = "src/boot_imem_subsystem.spade:87,27" *)
    logic[10:0] _e_6372;
    (* src = "src/boot_imem_subsystem.spade:87,11" *)
    logic[48:0] _e_6370;
    (* src = "src/boot_imem_subsystem.spade:85,3" *)
    logic[97:0] _e_6365;
    assign _e_6367 = {5'd6, 32'bX};
    assign _e_6368 = {7'd2, 4'bX};
    localparam[0:0] _e_6369 = 0;
    assign _e_6366 = {_e_6367, _e_6368, _e_6369};
    assign _e_6371 = {5'd6, 32'bX};
    assign _e_6372 = {7'd2, 4'bX};
    localparam[0:0] _e_6373 = 0;
    assign _e_6370 = {_e_6371, _e_6372, _e_6373};
    assign _e_6365 = {_e_6366, _e_6370};
    assign output__ = _e_6365;
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
    (* src = "src/tanh.spade:17,47" *)
    logic[32:0] _e_6378;
    (* src = "src/tanh.spade:18,9" *)
    logic[31:0] \val_32 ;
    logic _e_9849;
    logic _e_9851;
    (* src = "src/tanh.spade:21,37" *)
    logic[15:0] \val_u16 ;
    (* src = "src/tanh.spade:22,30" *)
    logic[15:0] \x ;
    (* src = "src/tanh.spade:26,33" *)
    logic[16:0] \x_17 ;
    (* src = "src/tanh.spade:27,26" *)
    logic \is_neg ;
    (* src = "src/tanh.spade:32,53" *)
    logic[16:0] _e_6402;
    (* src = "src/tanh.spade:32,49" *)
    logic[17:0] _e_6400;
    (* src = "src/tanh.spade:32,73" *)
    logic[17:0] _e_6405;
    (* src = "src/tanh.spade:32,37" *)
    logic[17:0] \abs_x_18 ;
    (* src = "src/tanh.spade:35,34" *)
    logic[16:0] \abs_x ;
    (* src = "src/tanh.spade:40,37" *)
    logic _e_6412;
    (* src = "src/tanh.spade:50,43" *)
    logic[16:0] _e_6419;
    (* src = "src/tanh.spade:50,38" *)
    logic[17:0] \term1 ;
    (* src = "src/tanh.spade:51,21" *)
    logic[17:0] \term2 ;
    (* src = "src/tanh.spade:52,23" *)
    logic[18:0] _e_6426;
    (* src = "src/tanh.spade:52,17" *)
    logic[16:0] _e_6425;
    (* src = "src/tanh.spade:40,34" *)
    logic[16:0] \abs_y ;
    (* src = "src/tanh.spade:58,49" *)
    logic[16:0] _e_6435;
    (* src = "src/tanh.spade:58,45" *)
    logic[17:0] _e_6433;
    (* src = "src/tanh.spade:58,70" *)
    logic[17:0] _e_6438;
    (* src = "src/tanh.spade:58,33" *)
    logic[17:0] \y_18 ;
    (* src = "src/tanh.spade:62,33" *)
    logic[15:0] \y_16 ;
    (* src = "src/tanh.spade:67,34" *)
    logic[31:0] \y_i32 ;
    (* src = "src/tanh.spade:68,18" *)
    logic[31:0] _e_6448;
    (* src = "src/tanh.spade:68,13" *)
    logic[32:0] _e_6447;
    logic _e_9853;
    (* src = "src/tanh.spade:70,17" *)
    logic[32:0] _e_6451;
    (* src = "src/tanh.spade:17,55" *)
    logic[32:0] _e_6379;
    (* src = "src/tanh.spade:17,14" *)
    reg[32:0] \res ;
    assign _e_6378 = {1'd0, 32'bX};
    assign \val_32  = \trig [31:0];
    assign _e_9849 = \trig [32] == 1'd1;
    localparam[0:0] _e_9850 = 1;
    assign _e_9851 = _e_9849 && _e_9850;
    assign \val_u16  = \val_32 [15:0];
    (* src = "src/tanh.spade:22,30" *)
    \std::conv::impl_4::to_int[2139]  to_int_0(.self_i(\val_u16 ), .output__(\x ));
    assign \x_17  = {\x [15], \x };
    localparam[16:0] _e_6395 = 0;
    assign \is_neg  = $signed(\x_17 ) < $signed(_e_6395);
    localparam[16:0] _e_6401 = 0;
    assign _e_6402 = \x_17 ;
    assign _e_6400 = $signed(_e_6401) - $signed(_e_6402);
    assign _e_6405 = {\x_17 [16], \x_17 };
    assign \abs_x_18  = \is_neg  ? _e_6400 : _e_6405;
    assign \abs_x  = \abs_x_18 [16:0];
    localparam[16:0] _e_6414 = 16384;
    assign _e_6412 = $signed(\abs_x ) < $signed(_e_6414);
    localparam[16:0] _e_6421 = 1;
    assign _e_6419 = \abs_x  >> _e_6421;
    assign \term1  = {_e_6419[16], _e_6419};
    localparam[17:0] _e_6423 = 8192;
    assign \term2  = _e_6423;
    assign _e_6426 = $signed(\term1 ) + $signed(\term2 );
    assign _e_6425 = _e_6426[16:0];
    assign \abs_y  = _e_6412 ? \abs_x  : _e_6425;
    localparam[16:0] _e_6434 = 0;
    assign _e_6435 = \abs_y ;
    assign _e_6433 = $signed(_e_6434) - $signed(_e_6435);
    assign _e_6438 = {\abs_y [16], \abs_y };
    assign \y_18  = \is_neg  ? _e_6433 : _e_6438;
    assign \y_16  = \y_18 [15:0];
    assign \y_i32  = {{ 16 { \y_16 [15] }}, \y_16 };
    (* src = "src/tanh.spade:68,18" *)
    \std::conv::impl_3::to_uint[2138]  to_uint_0(.self_i(\y_i32 ), .output__(_e_6448));
    assign _e_6447 = {1'd1, _e_6448};
    assign _e_9853 = \trig [32] == 1'd0;
    assign _e_6451 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9851, _e_9853})
            2'b1?: _e_6379 = _e_6447;
            2'b01: _e_6379 = _e_6451;
            2'b?: _e_6379 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_6378;
        end
        else begin
            \res  <= _e_6379;
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
    (* src = "src/tanh.spade:78,9" *)
    logic[42:0] _e_6457;
    (* src = "src/tanh.spade:78,14" *)
    logic[31:0] \a ;
    logic _e_9855;
    logic _e_9857;
    logic _e_9859;
    logic _e_9860;
    (* src = "src/tanh.spade:78,35" *)
    logic[32:0] _e_6459;
    (* src = "src/tanh.spade:79,9" *)
    logic[43:0] \_ ;
    (* src = "src/tanh.spade:79,25" *)
    logic[42:0] _e_6465;
    (* src = "src/tanh.spade:79,30" *)
    logic[31:0] a_n1;
    logic _e_9863;
    logic _e_9865;
    logic _e_9867;
    logic _e_9868;
    (* src = "src/tanh.spade:79,51" *)
    logic[32:0] _e_6467;
    (* src = "src/tanh.spade:79,60" *)
    logic[43:0] __n1;
    (* src = "src/tanh.spade:79,65" *)
    logic[32:0] _e_6470;
    (* src = "src/tanh.spade:79,14" *)
    logic[32:0] _e_6462;
    (* src = "src/tanh.spade:77,5" *)
    logic[32:0] _e_6454;
    assign _e_6457 = \m1 [42:0];
    assign \a  = _e_6457[36:5];
    assign _e_9855 = \m1 [43] == 1'd1;
    assign _e_9857 = _e_6457[42:37] == 6'd34;
    localparam[0:0] _e_9858 = 1;
    assign _e_9859 = _e_9857 && _e_9858;
    assign _e_9860 = _e_9855 && _e_9859;
    assign _e_6459 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9861 = 1;
    assign _e_6465 = \m0 [42:0];
    assign a_n1 = _e_6465[36:5];
    assign _e_9863 = \m0 [43] == 1'd1;
    assign _e_9865 = _e_6465[42:37] == 6'd34;
    localparam[0:0] _e_9866 = 1;
    assign _e_9867 = _e_9865 && _e_9866;
    assign _e_9868 = _e_9863 && _e_9867;
    assign _e_6467 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9869 = 1;
    assign _e_6470 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9868, _e_9869})
            2'b1?: _e_6462 = _e_6467;
            2'b01: _e_6462 = _e_6470;
            2'b?: _e_6462 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9860, _e_9861})
            2'b1?: _e_6454 = _e_6459;
            2'b01: _e_6454 = _e_6462;
            2'b?: _e_6454 = 33'dx;
        endcase
    end
    assign output__ = _e_6454;
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
    (* src = "src/cc.spade:10,54" *)
    logic[51:0] _e_6477;
    (* src = "src/cc.spade:10,48" *)
    logic[50:0] _e_6476;
    (* src = "src/cc.spade:10,14" *)
    reg[50:0] \counter ;
    logic[63:0] \padded ;
    (* src = "src/cc.spade:13,37" *)
    logic[63:0] _e_6484;
    (* src = "src/cc.spade:13,31" *)
    logic[31:0] \cc_res_lo ;
    (* src = "src/cc.spade:14,39" *)
    logic[63:0] _e_6489;
    (* src = "src/cc.spade:14,33" *)
    logic[31:0] \cc_res_high ;
    (* src = "src/cc.spade:15,5" *)
    logic[63:0] _e_6493;
    localparam[50:0] _e_6475 = 51'd0;
    localparam[50:0] _e_6479 = 51'd1;
    assign _e_6477 = \counter  + _e_6479;
    assign _e_6476 = _e_6477[50:0];
    always @(posedge \clk ) begin
        if (\rst ) begin
            \counter  <= _e_6475;
        end
        else begin
            \counter  <= _e_6476;
        end
    end
    assign \padded  = {13'b0, \counter };
    localparam[63:0] _e_6486 = 64'd4294967295;
    assign _e_6484 = \padded  & _e_6486;
    assign \cc_res_lo  = _e_6484[31:0];
    localparam[63:0] _e_6491 = 64'd32;
    assign _e_6489 = \padded  >> _e_6491;
    assign \cc_res_high  = _e_6489[31:0];
    assign _e_6493 = {\cc_res_lo , \cc_res_high };
    assign output__ = _e_6493;
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
    (* src = "src/mul_shiftadd.spade:24,13" *)
    logic _e_6498;
    (* src = "src/mul_shiftadd.spade:24,5" *)
    logic[102:0] _e_6497;
    assign _e_6498 = {1'd0};
    localparam[31:0] _e_6499 = 32'd0;
    localparam[31:0] _e_6500 = 32'd0;
    localparam[31:0] _e_6501 = 32'd0;
    localparam[5:0] _e_6502 = 0;
    assign _e_6497 = {_e_6498, _e_6499, _e_6500, _e_6501, _e_6502};
    assign output__ = _e_6497;
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
    (* src = "src/mul_shiftadd.spade:33,36" *)
    logic[102:0] _e_6507;
    (* src = "src/mul_shiftadd.spade:33,57" *)
    logic _e_6509;
    (* src = "src/mul_shiftadd.spade:34,9" *)
    logic _e_6511;
    logic _e_9871;
    (* src = "src/mul_shiftadd.spade:37,17" *)
    logic[31:0] \val ;
    logic _e_9873;
    logic _e_9875;
    logic _e_9877;
    (* src = "src/mul_shiftadd.spade:38,25" *)
    logic[31:0] _e_6519;
    (* src = "src/mul_shiftadd.spade:36,26" *)
    logic[31:0] \next_a ;
    (* src = "src/mul_shiftadd.spade:44,17" *)
    logic[31:0] \val_b ;
    logic _e_9879;
    logic _e_9881;
    (* src = "src/mul_shiftadd.spade:44,40" *)
    logic _e_6527;
    (* src = "src/mul_shiftadd.spade:44,32" *)
    logic[102:0] _e_6526;
    logic _e_9883;
    (* src = "src/mul_shiftadd.spade:45,33" *)
    logic _e_6534;
    (* src = "src/mul_shiftadd.spade:45,25" *)
    logic[102:0] _e_6533;
    (* src = "src/mul_shiftadd.spade:43,13" *)
    logic[102:0] _e_6522;
    (* src = "src/mul_shiftadd.spade:48,9" *)
    logic _e_6539;
    logic _e_9885;
    (* src = "src/mul_shiftadd.spade:50,27" *)
    logic[31:0] _e_6543;
    (* src = "src/mul_shiftadd.spade:50,26" *)
    logic[31:0] _e_6542;
    (* src = "src/mul_shiftadd.spade:50,26" *)
    logic \do_add ;
    (* src = "src/mul_shiftadd.spade:51,46" *)
    logic[31:0] _e_6551;
    (* src = "src/mul_shiftadd.spade:51,34" *)
    logic[31:0] \current_addend ;
    (* src = "src/mul_shiftadd.spade:52,34" *)
    logic[31:0] _e_6558;
    (* src = "src/mul_shiftadd.spade:52,34" *)
    logic[32:0] _e_6557;
    (* src = "src/mul_shiftadd.spade:52,28" *)
    logic[31:0] \next_acc ;
    (* src = "src/mul_shiftadd.spade:55,26" *)
    logic[31:0] _e_6563;
    (* src = "src/mul_shiftadd.spade:55,26" *)
    logic[31:0] next_a_n1;
    (* src = "src/mul_shiftadd.spade:56,26" *)
    logic[31:0] _e_6568;
    (* src = "src/mul_shiftadd.spade:56,26" *)
    logic[31:0] \next_b ;
    (* src = "src/mul_shiftadd.spade:58,16" *)
    logic[5:0] _e_6574;
    (* src = "src/mul_shiftadd.spade:58,16" *)
    logic _e_6573;
    (* src = "src/mul_shiftadd.spade:60,17" *)
    logic[102:0] _e_6578;
    (* src = "src/mul_shiftadd.spade:62,25" *)
    logic _e_6581;
    (* src = "src/mul_shiftadd.spade:62,70" *)
    logic[5:0] _e_6587;
    (* src = "src/mul_shiftadd.spade:62,70" *)
    logic[6:0] _e_6586;
    (* src = "src/mul_shiftadd.spade:62,64" *)
    logic[5:0] _e_6585;
    (* src = "src/mul_shiftadd.spade:62,17" *)
    logic[102:0] _e_6580;
    (* src = "src/mul_shiftadd.spade:58,13" *)
    logic[102:0] _e_6572;
    (* src = "src/mul_shiftadd.spade:33,51" *)
    logic[102:0] _e_6508;
    (* src = "src/mul_shiftadd.spade:33,14" *)
    reg[102:0] \r ;
    (* src = "src/mul_shiftadd.spade:69,11" *)
    logic _e_6591;
    (* src = "src/mul_shiftadd.spade:70,9" *)
    logic _e_6593;
    logic _e_9887;
    (* src = "src/mul_shiftadd.spade:71,16" *)
    logic[5:0] _e_6597;
    (* src = "src/mul_shiftadd.spade:71,16" *)
    logic _e_6596;
    (* src = "src/mul_shiftadd.spade:73,31" *)
    logic[31:0] _e_6603;
    (* src = "src/mul_shiftadd.spade:73,30" *)
    logic[31:0] _e_6602;
    (* src = "src/mul_shiftadd.spade:73,30" *)
    logic do_add_n1;
    (* src = "src/mul_shiftadd.spade:74,50" *)
    logic[31:0] _e_6611;
    (* src = "src/mul_shiftadd.spade:74,38" *)
    logic[31:0] current_addend_n1;
    (* src = "src/mul_shiftadd.spade:75,28" *)
    logic[31:0] _e_6619;
    (* src = "src/mul_shiftadd.spade:75,28" *)
    logic[32:0] _e_6618;
    (* src = "src/mul_shiftadd.spade:75,22" *)
    logic[31:0] _e_6617;
    (* src = "src/mul_shiftadd.spade:75,17" *)
    logic[32:0] _e_6616;
    (* src = "src/mul_shiftadd.spade:77,17" *)
    logic[32:0] _e_6623;
    (* src = "src/mul_shiftadd.spade:71,13" *)
    logic[32:0] _e_6595;
    (* src = "src/mul_shiftadd.spade:80,9" *)
    logic \_ ;
    (* src = "src/mul_shiftadd.spade:80,14" *)
    logic[32:0] _e_6625;
    (* src = "src/mul_shiftadd.spade:69,5" *)
    logic[32:0] _e_6590;
    (* src = "src/mul_shiftadd.spade:33,36" *)
    \tta::mul_shiftadd::reset_mul  reset_mul_0(.output__(_e_6507));
    assign _e_6509 = \r [102];
    assign _e_6511 = _e_6509;
    assign _e_9871 = _e_6509 == 1'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9873 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9874 = 1;
    assign _e_9875 = _e_9873 && _e_9874;
    assign _e_9877 = \set_op_a [32] == 1'd0;
    assign _e_6519 = \r [101:70];
    always_comb begin
        priority casez ({_e_9875, _e_9877})
            2'b1?: \next_a  = \val ;
            2'b01: \next_a  = _e_6519;
            2'b?: \next_a  = 32'dx;
        endcase
    end
    assign \val_b  = \trig [31:0];
    assign _e_9879 = \trig [32] == 1'd1;
    localparam[0:0] _e_9880 = 1;
    assign _e_9881 = _e_9879 && _e_9880;
    assign _e_6527 = {1'd1};
    localparam[31:0] _e_6530 = 32'd0;
    localparam[5:0] _e_6531 = 0;
    assign _e_6526 = {_e_6527, \next_a , \val_b , _e_6530, _e_6531};
    assign _e_9883 = \trig [32] == 1'd0;
    assign _e_6534 = {1'd0};
    localparam[31:0] _e_6536 = 32'd0;
    localparam[31:0] _e_6537 = 32'd0;
    localparam[5:0] _e_6538 = 0;
    assign _e_6533 = {_e_6534, \next_a , _e_6536, _e_6537, _e_6538};
    always_comb begin
        priority casez ({_e_9881, _e_9883})
            2'b1?: _e_6522 = _e_6526;
            2'b01: _e_6522 = _e_6533;
            2'b?: _e_6522 = 103'dx;
        endcase
    end
    assign _e_6539 = _e_6509;
    assign _e_9885 = _e_6509 == 1'd1;
    assign _e_6543 = \r [69:38];
    localparam[31:0] _e_6545 = 32'd1;
    assign _e_6542 = _e_6543 & _e_6545;
    localparam[31:0] _e_6546 = 32'd1;
    assign \do_add  = _e_6542 == _e_6546;
    assign _e_6551 = \r [101:70];
    localparam[31:0] _e_6554 = 32'd0;
    assign \current_addend  = \do_add  ? _e_6551 : _e_6554;
    assign _e_6558 = \r [37:6];
    assign _e_6557 = _e_6558 + \current_addend ;
    assign \next_acc  = _e_6557[31:0];
    assign _e_6563 = \r [101:70];
    localparam[31:0] _e_6565 = 32'd1;
    assign next_a_n1 = _e_6563 << _e_6565;
    assign _e_6568 = \r [69:38];
    localparam[31:0] _e_6570 = 32'd1;
    assign \next_b  = _e_6568 >> _e_6570;
    assign _e_6574 = \r [5:0];
    localparam[5:0] _e_6576 = 31;
    assign _e_6573 = _e_6574 == _e_6576;
    (* src = "src/mul_shiftadd.spade:60,17" *)
    \tta::mul_shiftadd::reset_mul  reset_mul_1(.output__(_e_6578));
    assign _e_6581 = {1'd1};
    assign _e_6587 = \r [5:0];
    localparam[5:0] _e_6589 = 1;
    assign _e_6586 = _e_6587 + _e_6589;
    assign _e_6585 = _e_6586[5:0];
    assign _e_6580 = {_e_6581, next_a_n1, \next_b , \next_acc , _e_6585};
    assign _e_6572 = _e_6573 ? _e_6578 : _e_6580;
    always_comb begin
        priority casez ({_e_9871, _e_9885})
            2'b1?: _e_6508 = _e_6522;
            2'b01: _e_6508 = _e_6572;
            2'b?: _e_6508 = 103'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_6507;
        end
        else begin
            \r  <= _e_6508;
        end
    end
    assign _e_6591 = \r [102];
    assign _e_6593 = _e_6591;
    assign _e_9887 = _e_6591 == 1'd1;
    assign _e_6597 = \r [5:0];
    localparam[5:0] _e_6599 = 31;
    assign _e_6596 = _e_6597 == _e_6599;
    assign _e_6603 = \r [69:38];
    localparam[31:0] _e_6605 = 32'd1;
    assign _e_6602 = _e_6603 & _e_6605;
    localparam[31:0] _e_6606 = 32'd1;
    assign do_add_n1 = _e_6602 == _e_6606;
    assign _e_6611 = \r [101:70];
    localparam[31:0] _e_6614 = 32'd0;
    assign current_addend_n1 = do_add_n1 ? _e_6611 : _e_6614;
    assign _e_6619 = \r [37:6];
    assign _e_6618 = _e_6619 + current_addend_n1;
    assign _e_6617 = _e_6618[31:0];
    assign _e_6616 = {1'd1, _e_6617};
    assign _e_6623 = {1'd0, 32'bX};
    assign _e_6595 = _e_6596 ? _e_6616 : _e_6623;
    assign \_  = _e_6591;
    localparam[0:0] _e_9888 = 1;
    assign _e_6625 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9887, _e_9888})
            2'b1?: _e_6590 = _e_6595;
            2'b01: _e_6590 = _e_6625;
            2'b?: _e_6590 = 33'dx;
        endcase
    end
    assign output__ = _e_6590;
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
    (* src = "src/mul_shiftadd.spade:87,5" *)
    logic[42:0] _e_6630;
    (* src = "src/mul_shiftadd.spade:87,10" *)
    logic[31:0] \x ;
    logic _e_9890;
    logic _e_9892;
    logic _e_9894;
    logic _e_9895;
    (* src = "src/mul_shiftadd.spade:87,31" *)
    logic[32:0] _e_6632;
    (* src = "src/mul_shiftadd.spade:88,5" *)
    logic[43:0] \_ ;
    (* src = "src/mul_shiftadd.spade:88,21" *)
    logic[42:0] _e_6638;
    (* src = "src/mul_shiftadd.spade:88,26" *)
    logic[31:0] x_n1;
    logic _e_9898;
    logic _e_9900;
    logic _e_9902;
    logic _e_9903;
    (* src = "src/mul_shiftadd.spade:88,47" *)
    logic[32:0] _e_6640;
    (* src = "src/mul_shiftadd.spade:88,56" *)
    logic[43:0] __n1;
    (* src = "src/mul_shiftadd.spade:88,61" *)
    logic[32:0] _e_6643;
    (* src = "src/mul_shiftadd.spade:88,10" *)
    logic[32:0] _e_6635;
    (* src = "src/mul_shiftadd.spade:86,3" *)
    logic[32:0] _e_6627;
    assign _e_6630 = \m1 [42:0];
    assign \x  = _e_6630[36:5];
    assign _e_9890 = \m1 [43] == 1'd1;
    assign _e_9892 = _e_6630[42:37] == 6'd16;
    localparam[0:0] _e_9893 = 1;
    assign _e_9894 = _e_9892 && _e_9893;
    assign _e_9895 = _e_9890 && _e_9894;
    assign _e_6632 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9896 = 1;
    assign _e_6638 = \m0 [42:0];
    assign x_n1 = _e_6638[36:5];
    assign _e_9898 = \m0 [43] == 1'd1;
    assign _e_9900 = _e_6638[42:37] == 6'd16;
    localparam[0:0] _e_9901 = 1;
    assign _e_9902 = _e_9900 && _e_9901;
    assign _e_9903 = _e_9898 && _e_9902;
    assign _e_6640 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9904 = 1;
    assign _e_6643 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9903, _e_9904})
            2'b1?: _e_6635 = _e_6640;
            2'b01: _e_6635 = _e_6643;
            2'b?: _e_6635 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9895, _e_9896})
            2'b1?: _e_6627 = _e_6632;
            2'b01: _e_6627 = _e_6635;
            2'b?: _e_6627 = 33'dx;
        endcase
    end
    assign output__ = _e_6627;
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
    (* src = "src/mul_shiftadd.spade:94,5" *)
    logic[42:0] _e_6648;
    (* src = "src/mul_shiftadd.spade:94,10" *)
    logic[31:0] \x ;
    logic _e_9906;
    logic _e_9908;
    logic _e_9910;
    logic _e_9911;
    (* src = "src/mul_shiftadd.spade:94,31" *)
    logic[32:0] _e_6650;
    (* src = "src/mul_shiftadd.spade:95,5" *)
    logic[43:0] \_ ;
    (* src = "src/mul_shiftadd.spade:95,21" *)
    logic[42:0] _e_6656;
    (* src = "src/mul_shiftadd.spade:95,26" *)
    logic[31:0] x_n1;
    logic _e_9914;
    logic _e_9916;
    logic _e_9918;
    logic _e_9919;
    (* src = "src/mul_shiftadd.spade:95,47" *)
    logic[32:0] _e_6658;
    (* src = "src/mul_shiftadd.spade:95,56" *)
    logic[43:0] __n1;
    (* src = "src/mul_shiftadd.spade:95,61" *)
    logic[32:0] _e_6661;
    (* src = "src/mul_shiftadd.spade:95,10" *)
    logic[32:0] _e_6653;
    (* src = "src/mul_shiftadd.spade:93,3" *)
    logic[32:0] _e_6645;
    assign _e_6648 = \m1 [42:0];
    assign \x  = _e_6648[36:5];
    assign _e_9906 = \m1 [43] == 1'd1;
    assign _e_9908 = _e_6648[42:37] == 6'd17;
    localparam[0:0] _e_9909 = 1;
    assign _e_9910 = _e_9908 && _e_9909;
    assign _e_9911 = _e_9906 && _e_9910;
    assign _e_6650 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9912 = 1;
    assign _e_6656 = \m0 [42:0];
    assign x_n1 = _e_6656[36:5];
    assign _e_9914 = \m0 [43] == 1'd1;
    assign _e_9916 = _e_6656[42:37] == 6'd17;
    localparam[0:0] _e_9917 = 1;
    assign _e_9918 = _e_9916 && _e_9917;
    assign _e_9919 = _e_9914 && _e_9918;
    assign _e_6658 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9920 = 1;
    assign _e_6661 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9919, _e_9920})
            2'b1?: _e_6653 = _e_6658;
            2'b01: _e_6653 = _e_6661;
            2'b?: _e_6653 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9911, _e_9912})
            2'b1?: _e_6645 = _e_6650;
            2'b01: _e_6645 = _e_6653;
            2'b?: _e_6645 = 33'dx;
        endcase
    end
    assign output__ = _e_6645;
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
    logic _e_9921;
    (* src = "src/imem.spade:30,17" *)
    logic[36:0] _e_6666;
    logic _e_9923;
    (* src = "src/imem.spade:31,17" *)
    logic[36:0] _e_6669;
    logic _e_9925;
    (* src = "src/imem.spade:32,17" *)
    logic[36:0] _e_6672;
    logic _e_9927;
    (* src = "src/imem.spade:33,17" *)
    logic[36:0] _e_6675;
    logic _e_9929;
    (* src = "src/imem.spade:34,17" *)
    logic[36:0] _e_6678;
    logic _e_9931;
    (* src = "src/imem.spade:35,17" *)
    logic[36:0] _e_6681;
    logic _e_9933;
    (* src = "src/imem.spade:36,17" *)
    logic[36:0] _e_6684;
    logic _e_9935;
    (* src = "src/imem.spade:37,17" *)
    logic[36:0] _e_6687;
    logic _e_9937;
    (* src = "src/imem.spade:39,17" *)
    logic[36:0] _e_6690;
    logic _e_9939;
    (* src = "src/imem.spade:40,17" *)
    logic[36:0] _e_6692;
    logic _e_9941;
    logic[31:0] _e_6695;
    (* src = "src/imem.spade:43,17" *)
    logic[36:0] _e_6694;
    logic _e_9943;
    (* src = "src/imem.spade:46,17" *)
    logic[36:0] _e_6698;
    logic _e_9945;
    (* src = "src/imem.spade:47,17" *)
    logic[36:0] _e_6700;
    logic _e_9947;
    (* src = "src/imem.spade:48,17" *)
    logic[36:0] _e_6702;
    logic _e_9949;
    (* src = "src/imem.spade:49,17" *)
    logic[36:0] _e_6704;
    logic _e_9951;
    (* src = "src/imem.spade:50,17" *)
    logic[36:0] _e_6706;
    logic _e_9953;
    (* src = "src/imem.spade:51,17" *)
    logic[36:0] _e_6708;
    logic _e_9955;
    (* src = "src/imem.spade:52,17" *)
    logic[36:0] _e_6710;
    logic _e_9957;
    (* src = "src/imem.spade:53,17" *)
    logic[36:0] _e_6712;
    logic _e_9959;
    (* src = "src/imem.spade:54,17" *)
    logic[36:0] _e_6714;
    logic _e_9961;
    (* src = "src/imem.spade:55,17" *)
    logic[36:0] _e_6716;
    logic _e_9963;
    (* src = "src/imem.spade:56,17" *)
    logic[36:0] _e_6718;
    logic _e_9965;
    (* src = "src/imem.spade:57,17" *)
    logic[36:0] _e_6720;
    logic _e_9967;
    (* src = "src/imem.spade:58,17" *)
    logic[36:0] _e_6722;
    logic _e_9969;
    (* src = "src/imem.spade:59,17" *)
    logic[36:0] _e_6724;
    logic _e_9971;
    (* src = "src/imem.spade:60,17" *)
    logic[36:0] _e_6726;
    logic _e_9973;
    (* src = "src/imem.spade:61,17" *)
    logic[36:0] _e_6728;
    logic _e_9975;
    (* src = "src/imem.spade:62,17" *)
    logic[36:0] _e_6730;
    logic _e_9977;
    (* src = "src/imem.spade:65,17" *)
    logic[36:0] _e_6732;
    logic _e_9979;
    (* src = "src/imem.spade:66,17" *)
    logic[36:0] _e_6734;
    logic _e_9981;
    (* src = "src/imem.spade:67,17" *)
    logic[36:0] _e_6736;
    logic _e_9983;
    (* src = "src/imem.spade:70,18" *)
    logic[36:0] _e_6738;
    logic _e_9985;
    (* src = "src/imem.spade:71,18" *)
    logic[36:0] _e_6741;
    logic _e_9987;
    (* src = "src/imem.spade:72,18" *)
    logic[36:0] _e_6744;
    logic _e_9989;
    (* src = "src/imem.spade:73,18" *)
    logic[36:0] _e_6747;
    logic _e_9991;
    (* src = "src/imem.spade:74,18" *)
    logic[36:0] _e_6750;
    logic _e_9993;
    (* src = "src/imem.spade:75,18" *)
    logic[36:0] _e_6753;
    logic _e_9995;
    (* src = "src/imem.spade:76,18" *)
    logic[36:0] _e_6756;
    logic _e_9997;
    (* src = "src/imem.spade:77,18" *)
    logic[36:0] _e_6759;
    logic _e_9999;
    (* src = "src/imem.spade:79,18" *)
    logic[36:0] _e_6762;
    (* src = "src/imem.spade:82,9" *)
    logic[7:0] \_ ;
    (* src = "src/imem.spade:82,14" *)
    logic[36:0] _e_6764;
    (* src = "src/imem.spade:28,5" *)
    logic[36:0] _e_6663;
    localparam[7:0] _e_9922 = 0;
    assign _e_9921 = \t  == _e_9922;
    localparam[3:0] _e_6667 = 0;
    assign _e_6666 = {5'd0, _e_6667, 28'bX};
    localparam[7:0] _e_9924 = 1;
    assign _e_9923 = \t  == _e_9924;
    localparam[3:0] _e_6670 = 1;
    assign _e_6669 = {5'd0, _e_6670, 28'bX};
    localparam[7:0] _e_9926 = 2;
    assign _e_9925 = \t  == _e_9926;
    localparam[3:0] _e_6673 = 2;
    assign _e_6672 = {5'd0, _e_6673, 28'bX};
    localparam[7:0] _e_9928 = 3;
    assign _e_9927 = \t  == _e_9928;
    localparam[3:0] _e_6676 = 3;
    assign _e_6675 = {5'd0, _e_6676, 28'bX};
    localparam[7:0] _e_9930 = 4;
    assign _e_9929 = \t  == _e_9930;
    localparam[3:0] _e_6679 = 4;
    assign _e_6678 = {5'd0, _e_6679, 28'bX};
    localparam[7:0] _e_9932 = 5;
    assign _e_9931 = \t  == _e_9932;
    localparam[3:0] _e_6682 = 5;
    assign _e_6681 = {5'd0, _e_6682, 28'bX};
    localparam[7:0] _e_9934 = 6;
    assign _e_9933 = \t  == _e_9934;
    localparam[3:0] _e_6685 = 6;
    assign _e_6684 = {5'd0, _e_6685, 28'bX};
    localparam[7:0] _e_9936 = 7;
    assign _e_9935 = \t  == _e_9936;
    localparam[3:0] _e_6688 = 7;
    assign _e_6687 = {5'd0, _e_6688, 28'bX};
    localparam[7:0] _e_9938 = 8;
    assign _e_9937 = \t  == _e_9938;
    assign _e_6690 = {5'd6, 32'bX};
    localparam[7:0] _e_9940 = 9;
    assign _e_9939 = \t  == _e_9940;
    assign _e_6692 = {5'd3, 32'bX};
    localparam[7:0] _e_9942 = 10;
    assign _e_9941 = \t  == _e_9942;
    assign _e_6695 = {16'b0, \imm16 };
    assign _e_6694 = {5'd5, _e_6695};
    localparam[7:0] _e_9944 = 11;
    assign _e_9943 = \t  == _e_9944;
    assign _e_6698 = {5'd1, 32'bX};
    localparam[7:0] _e_9946 = 12;
    assign _e_9945 = \t  == _e_9946;
    assign _e_6700 = {5'd7, 32'bX};
    localparam[7:0] _e_9948 = 13;
    assign _e_9947 = \t  == _e_9948;
    assign _e_6702 = {5'd11, 32'bX};
    localparam[7:0] _e_9950 = 14;
    assign _e_9949 = \t  == _e_9950;
    assign _e_6704 = {5'd12, 32'bX};
    localparam[7:0] _e_9952 = 15;
    assign _e_9951 = \t  == _e_9952;
    assign _e_6706 = {5'd2, 32'bX};
    localparam[7:0] _e_9954 = 16;
    assign _e_9953 = \t  == _e_9954;
    assign _e_6708 = {5'd13, 32'bX};
    localparam[7:0] _e_9956 = 17;
    assign _e_9955 = \t  == _e_9956;
    assign _e_6710 = {5'd14, 32'bX};
    localparam[7:0] _e_9958 = 18;
    assign _e_9957 = \t  == _e_9958;
    assign _e_6712 = {5'd15, 32'bX};
    localparam[7:0] _e_9960 = 19;
    assign _e_9959 = \t  == _e_9960;
    assign _e_6714 = {5'd18, 32'bX};
    localparam[7:0] _e_9962 = 20;
    assign _e_9961 = \t  == _e_9962;
    assign _e_6716 = {5'd20, 32'bX};
    localparam[7:0] _e_9964 = 21;
    assign _e_9963 = \t  == _e_9964;
    assign _e_6718 = {5'd21, 32'bX};
    localparam[7:0] _e_9966 = 22;
    assign _e_9965 = \t  == _e_9966;
    assign _e_6720 = {5'd22, 32'bX};
    localparam[7:0] _e_9968 = 23;
    assign _e_9967 = \t  == _e_9968;
    assign _e_6722 = {5'd17, 32'bX};
    localparam[7:0] _e_9970 = 24;
    assign _e_9969 = \t  == _e_9970;
    assign _e_6724 = {5'd19, 32'bX};
    localparam[7:0] _e_9972 = 25;
    assign _e_9971 = \t  == _e_9972;
    assign _e_6726 = {5'd23, 32'bX};
    localparam[7:0] _e_9974 = 26;
    assign _e_9973 = \t  == _e_9974;
    assign _e_6728 = {5'd8, 32'bX};
    localparam[7:0] _e_9976 = 27;
    assign _e_9975 = \t  == _e_9976;
    assign _e_6730 = {5'd24, 32'bX};
    localparam[7:0] _e_9978 = 60;
    assign _e_9977 = \t  == _e_9978;
    assign _e_6732 = {5'd9, 32'bX};
    localparam[7:0] _e_9980 = 61;
    assign _e_9979 = \t  == _e_9980;
    assign _e_6734 = {5'd10, 32'bX};
    localparam[7:0] _e_9982 = 62;
    assign _e_9981 = \t  == _e_9982;
    assign _e_6736 = {5'd16, 32'bX};
    localparam[7:0] _e_9984 = 100;
    assign _e_9983 = \t  == _e_9984;
    localparam[3:0] _e_6739 = 8;
    assign _e_6738 = {5'd0, _e_6739, 28'bX};
    localparam[7:0] _e_9986 = 101;
    assign _e_9985 = \t  == _e_9986;
    localparam[3:0] _e_6742 = 9;
    assign _e_6741 = {5'd0, _e_6742, 28'bX};
    localparam[7:0] _e_9988 = 102;
    assign _e_9987 = \t  == _e_9988;
    localparam[3:0] _e_6745 = 10;
    assign _e_6744 = {5'd0, _e_6745, 28'bX};
    localparam[7:0] _e_9990 = 103;
    assign _e_9989 = \t  == _e_9990;
    localparam[3:0] _e_6748 = 11;
    assign _e_6747 = {5'd0, _e_6748, 28'bX};
    localparam[7:0] _e_9992 = 104;
    assign _e_9991 = \t  == _e_9992;
    localparam[3:0] _e_6751 = 12;
    assign _e_6750 = {5'd0, _e_6751, 28'bX};
    localparam[7:0] _e_9994 = 105;
    assign _e_9993 = \t  == _e_9994;
    localparam[3:0] _e_6754 = 13;
    assign _e_6753 = {5'd0, _e_6754, 28'bX};
    localparam[7:0] _e_9996 = 106;
    assign _e_9995 = \t  == _e_9996;
    localparam[3:0] _e_6757 = 14;
    assign _e_6756 = {5'd0, _e_6757, 28'bX};
    localparam[7:0] _e_9998 = 107;
    assign _e_9997 = \t  == _e_9998;
    localparam[3:0] _e_6760 = 15;
    assign _e_6759 = {5'd0, _e_6760, 28'bX};
    localparam[7:0] _e_10000 = 110;
    assign _e_9999 = \t  == _e_10000;
    assign _e_6762 = {5'd4, 32'bX};
    assign \_  = \t ;
    localparam[0:0] _e_10001 = 1;
    assign _e_6764 = {5'd6, 32'bX};
    always_comb begin
        priority casez ({_e_9921, _e_9923, _e_9925, _e_9927, _e_9929, _e_9931, _e_9933, _e_9935, _e_9937, _e_9939, _e_9941, _e_9943, _e_9945, _e_9947, _e_9949, _e_9951, _e_9953, _e_9955, _e_9957, _e_9959, _e_9961, _e_9963, _e_9965, _e_9967, _e_9969, _e_9971, _e_9973, _e_9975, _e_9977, _e_9979, _e_9981, _e_9983, _e_9985, _e_9987, _e_9989, _e_9991, _e_9993, _e_9995, _e_9997, _e_9999, _e_10001})
            41'b1????????????????????????????????????????: _e_6663 = _e_6666;
            41'b01???????????????????????????????????????: _e_6663 = _e_6669;
            41'b001??????????????????????????????????????: _e_6663 = _e_6672;
            41'b0001?????????????????????????????????????: _e_6663 = _e_6675;
            41'b00001????????????????????????????????????: _e_6663 = _e_6678;
            41'b000001???????????????????????????????????: _e_6663 = _e_6681;
            41'b0000001??????????????????????????????????: _e_6663 = _e_6684;
            41'b00000001?????????????????????????????????: _e_6663 = _e_6687;
            41'b000000001????????????????????????????????: _e_6663 = _e_6690;
            41'b0000000001???????????????????????????????: _e_6663 = _e_6692;
            41'b00000000001??????????????????????????????: _e_6663 = _e_6694;
            41'b000000000001?????????????????????????????: _e_6663 = _e_6698;
            41'b0000000000001????????????????????????????: _e_6663 = _e_6700;
            41'b00000000000001???????????????????????????: _e_6663 = _e_6702;
            41'b000000000000001??????????????????????????: _e_6663 = _e_6704;
            41'b0000000000000001?????????????????????????: _e_6663 = _e_6706;
            41'b00000000000000001????????????????????????: _e_6663 = _e_6708;
            41'b000000000000000001???????????????????????: _e_6663 = _e_6710;
            41'b0000000000000000001??????????????????????: _e_6663 = _e_6712;
            41'b00000000000000000001?????????????????????: _e_6663 = _e_6714;
            41'b000000000000000000001????????????????????: _e_6663 = _e_6716;
            41'b0000000000000000000001???????????????????: _e_6663 = _e_6718;
            41'b00000000000000000000001??????????????????: _e_6663 = _e_6720;
            41'b000000000000000000000001?????????????????: _e_6663 = _e_6722;
            41'b0000000000000000000000001????????????????: _e_6663 = _e_6724;
            41'b00000000000000000000000001???????????????: _e_6663 = _e_6726;
            41'b000000000000000000000000001??????????????: _e_6663 = _e_6728;
            41'b0000000000000000000000000001?????????????: _e_6663 = _e_6730;
            41'b00000000000000000000000000001????????????: _e_6663 = _e_6732;
            41'b000000000000000000000000000001???????????: _e_6663 = _e_6734;
            41'b0000000000000000000000000000001??????????: _e_6663 = _e_6736;
            41'b00000000000000000000000000000001?????????: _e_6663 = _e_6738;
            41'b000000000000000000000000000000001????????: _e_6663 = _e_6741;
            41'b0000000000000000000000000000000001???????: _e_6663 = _e_6744;
            41'b00000000000000000000000000000000001??????: _e_6663 = _e_6747;
            41'b000000000000000000000000000000000001?????: _e_6663 = _e_6750;
            41'b0000000000000000000000000000000000001????: _e_6663 = _e_6753;
            41'b00000000000000000000000000000000000001???: _e_6663 = _e_6756;
            41'b000000000000000000000000000000000000001??: _e_6663 = _e_6759;
            41'b0000000000000000000000000000000000000001?: _e_6663 = _e_6762;
            41'b00000000000000000000000000000000000000001: _e_6663 = _e_6764;
            41'b?: _e_6663 = 37'dx;
        endcase
    end
    assign output__ = _e_6663;
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
    logic _e_10002;
    (* src = "src/imem.spade:89,17" *)
    logic[10:0] _e_6769;
    logic _e_10004;
    (* src = "src/imem.spade:90,17" *)
    logic[10:0] _e_6772;
    logic _e_10006;
    (* src = "src/imem.spade:91,17" *)
    logic[10:0] _e_6775;
    logic _e_10008;
    (* src = "src/imem.spade:92,17" *)
    logic[10:0] _e_6778;
    logic _e_10010;
    (* src = "src/imem.spade:93,17" *)
    logic[10:0] _e_6781;
    logic _e_10012;
    (* src = "src/imem.spade:94,17" *)
    logic[10:0] _e_6784;
    logic _e_10014;
    (* src = "src/imem.spade:95,17" *)
    logic[10:0] _e_6787;
    logic _e_10016;
    (* src = "src/imem.spade:96,17" *)
    logic[10:0] _e_6790;
    logic _e_10018;
    (* src = "src/imem.spade:102,17" *)
    logic[10:0] _e_6793;
    logic _e_10020;
    (* src = "src/imem.spade:103,17" *)
    logic[10:0] _e_6795;
    logic _e_10022;
    (* src = "src/imem.spade:104,17" *)
    logic[10:0] _e_6797;
    logic _e_10024;
    (* src = "src/imem.spade:105,17" *)
    logic[10:0] _e_6799;
    logic _e_10026;
    (* src = "src/imem.spade:106,17" *)
    logic[10:0] _e_6801;
    logic _e_10028;
    (* src = "src/imem.spade:107,17" *)
    logic[10:0] _e_6803;
    logic _e_10030;
    (* src = "src/imem.spade:108,17" *)
    logic[10:0] _e_6805;
    logic _e_10032;
    (* src = "src/imem.spade:109,17" *)
    logic[10:0] _e_6807;
    logic _e_10034;
    (* src = "src/imem.spade:110,17" *)
    logic[10:0] _e_6809;
    logic _e_10036;
    (* src = "src/imem.spade:111,17" *)
    logic[10:0] _e_6811;
    logic _e_10038;
    (* src = "src/imem.spade:114,17" *)
    logic[10:0] _e_6813;
    logic _e_10040;
    (* src = "src/imem.spade:115,17" *)
    logic[10:0] _e_6815;
    logic _e_10042;
    (* src = "src/imem.spade:116,17" *)
    logic[10:0] _e_6817;
    logic _e_10044;
    (* src = "src/imem.spade:119,17" *)
    logic[10:0] _e_6819;
    logic _e_10046;
    (* src = "src/imem.spade:120,17" *)
    logic[10:0] _e_6821;
    logic _e_10048;
    (* src = "src/imem.spade:121,17" *)
    logic[10:0] _e_6823;
    logic _e_10050;
    (* src = "src/imem.spade:122,17" *)
    logic[10:0] _e_6825;
    logic _e_10052;
    (* src = "src/imem.spade:123,17" *)
    logic[10:0] _e_6827;
    logic _e_10054;
    (* src = "src/imem.spade:124,17" *)
    logic[10:0] _e_6829;
    logic _e_10056;
    (* src = "src/imem.spade:127,17" *)
    logic[10:0] _e_6831;
    logic _e_10058;
    (* src = "src/imem.spade:130,17" *)
    logic[10:0] _e_6833;
    logic _e_10060;
    (* src = "src/imem.spade:133,17" *)
    logic[10:0] _e_6835;
    logic _e_10062;
    (* src = "src/imem.spade:134,17" *)
    logic[10:0] _e_6837;
    logic _e_10064;
    (* src = "src/imem.spade:135,17" *)
    logic[10:0] _e_6839;
    logic _e_10066;
    (* src = "src/imem.spade:136,17" *)
    logic[10:0] _e_6841;
    logic _e_10068;
    (* src = "src/imem.spade:137,17" *)
    logic[10:0] _e_6843;
    logic _e_10070;
    (* src = "src/imem.spade:138,17" *)
    logic[10:0] _e_6845;
    logic _e_10072;
    (* src = "src/imem.spade:141,17" *)
    logic[10:0] _e_6847;
    logic _e_10074;
    (* src = "src/imem.spade:142,17" *)
    logic[10:0] _e_6849;
    logic _e_10076;
    (* src = "src/imem.spade:143,17" *)
    logic[10:0] _e_6851;
    logic _e_10078;
    (* src = "src/imem.spade:146,17" *)
    logic[10:0] _e_6853;
    logic _e_10080;
    (* src = "src/imem.spade:147,17" *)
    logic[10:0] _e_6855;
    logic _e_10082;
    (* src = "src/imem.spade:150,17" *)
    logic[10:0] _e_6857;
    logic _e_10084;
    (* src = "src/imem.spade:151,17" *)
    logic[10:0] _e_6859;
    logic _e_10086;
    (* src = "src/imem.spade:154,17" *)
    logic[10:0] _e_6861;
    logic _e_10088;
    (* src = "src/imem.spade:155,17" *)
    logic[10:0] _e_6863;
    logic _e_10090;
    (* src = "src/imem.spade:156,17" *)
    logic[10:0] _e_6865;
    logic _e_10092;
    (* src = "src/imem.spade:157,17" *)
    logic[10:0] _e_6867;
    logic _e_10094;
    (* src = "src/imem.spade:158,17" *)
    logic[10:0] _e_6869;
    logic _e_10096;
    (* src = "src/imem.spade:159,17" *)
    logic[10:0] _e_6871;
    logic _e_10098;
    (* src = "src/imem.spade:160,17" *)
    logic[10:0] _e_6873;
    logic _e_10100;
    (* src = "src/imem.spade:163,17" *)
    logic[10:0] _e_6875;
    logic _e_10102;
    (* src = "src/imem.spade:164,17" *)
    logic[10:0] _e_6877;
    logic _e_10104;
    (* src = "src/imem.spade:167,17" *)
    logic[10:0] _e_6879;
    logic _e_10106;
    (* src = "src/imem.spade:168,17" *)
    logic[10:0] _e_6881;
    logic _e_10108;
    (* src = "src/imem.spade:169,17" *)
    logic[10:0] _e_6883;
    logic _e_10110;
    (* src = "src/imem.spade:172,17" *)
    logic[10:0] _e_6885;
    logic _e_10112;
    (* src = "src/imem.spade:173,17" *)
    logic[10:0] _e_6887;
    logic _e_10114;
    (* src = "src/imem.spade:174,17" *)
    logic[10:0] _e_6889;
    logic _e_10116;
    (* src = "src/imem.spade:176,17" *)
    logic[10:0] _e_6891;
    logic _e_10118;
    (* src = "src/imem.spade:179,17" *)
    logic[10:0] _e_6893;
    logic _e_10120;
    (* src = "src/imem.spade:180,17" *)
    logic[10:0] _e_6895;
    logic _e_10122;
    (* src = "src/imem.spade:183,17" *)
    logic[10:0] _e_6897;
    logic _e_10124;
    (* src = "src/imem.spade:184,17" *)
    logic[10:0] _e_6899;
    logic _e_10126;
    (* src = "src/imem.spade:185,17" *)
    logic[10:0] _e_6901;
    logic _e_10128;
    (* src = "src/imem.spade:186,17" *)
    logic[10:0] _e_6903;
    logic _e_10130;
    (* src = "src/imem.spade:189,17" *)
    logic[10:0] _e_6905;
    logic _e_10132;
    (* src = "src/imem.spade:190,17" *)
    logic[10:0] _e_6907;
    logic _e_10134;
    (* src = "src/imem.spade:191,17" *)
    logic[10:0] _e_6909;
    logic _e_10136;
    (* src = "src/imem.spade:192,17" *)
    logic[10:0] _e_6911;
    logic _e_10138;
    (* src = "src/imem.spade:195,17" *)
    logic[10:0] _e_6913;
    logic _e_10140;
    (* src = "src/imem.spade:196,17" *)
    logic[10:0] _e_6915;
    logic _e_10142;
    (* src = "src/imem.spade:197,17" *)
    logic[10:0] _e_6917;
    logic _e_10144;
    (* src = "src/imem.spade:200,17" *)
    logic[10:0] _e_6919;
    logic _e_10146;
    (* src = "src/imem.spade:201,17" *)
    logic[10:0] _e_6921;
    logic _e_10148;
    (* src = "src/imem.spade:202,17" *)
    logic[10:0] _e_6923;
    logic _e_10150;
    (* src = "src/imem.spade:205,17" *)
    logic[10:0] _e_6925;
    logic _e_10152;
    (* src = "src/imem.spade:208,17" *)
    logic[10:0] _e_6927;
    logic _e_10154;
    (* src = "src/imem.spade:210,17" *)
    logic[10:0] _e_6929;
    logic _e_10156;
    (* src = "src/imem.spade:211,17" *)
    logic[10:0] _e_6931;
    logic _e_10158;
    (* src = "src/imem.spade:213,18" *)
    logic[10:0] _e_6933;
    logic _e_10160;
    (* src = "src/imem.spade:214,18" *)
    logic[10:0] _e_6936;
    logic _e_10162;
    (* src = "src/imem.spade:215,18" *)
    logic[10:0] _e_6939;
    logic _e_10164;
    (* src = "src/imem.spade:216,18" *)
    logic[10:0] _e_6942;
    logic _e_10166;
    (* src = "src/imem.spade:217,18" *)
    logic[10:0] _e_6945;
    logic _e_10168;
    (* src = "src/imem.spade:218,18" *)
    logic[10:0] _e_6948;
    logic _e_10170;
    (* src = "src/imem.spade:219,18" *)
    logic[10:0] _e_6951;
    logic _e_10172;
    (* src = "src/imem.spade:220,18" *)
    logic[10:0] _e_6954;
    (* src = "src/imem.spade:223,9" *)
    logic[7:0] \_ ;
    (* src = "src/imem.spade:223,14" *)
    logic[10:0] _e_6957;
    (* src = "src/imem.spade:87,5" *)
    logic[10:0] _e_6766;
    localparam[7:0] _e_10003 = 0;
    assign _e_10002 = \t  == _e_10003;
    localparam[3:0] _e_6770 = 0;
    assign _e_6769 = {7'd0, _e_6770};
    localparam[7:0] _e_10005 = 1;
    assign _e_10004 = \t  == _e_10005;
    localparam[3:0] _e_6773 = 1;
    assign _e_6772 = {7'd0, _e_6773};
    localparam[7:0] _e_10007 = 2;
    assign _e_10006 = \t  == _e_10007;
    localparam[3:0] _e_6776 = 2;
    assign _e_6775 = {7'd0, _e_6776};
    localparam[7:0] _e_10009 = 3;
    assign _e_10008 = \t  == _e_10009;
    localparam[3:0] _e_6779 = 3;
    assign _e_6778 = {7'd0, _e_6779};
    localparam[7:0] _e_10011 = 4;
    assign _e_10010 = \t  == _e_10011;
    localparam[3:0] _e_6782 = 4;
    assign _e_6781 = {7'd0, _e_6782};
    localparam[7:0] _e_10013 = 5;
    assign _e_10012 = \t  == _e_10013;
    localparam[3:0] _e_6785 = 5;
    assign _e_6784 = {7'd0, _e_6785};
    localparam[7:0] _e_10015 = 6;
    assign _e_10014 = \t  == _e_10015;
    localparam[3:0] _e_6788 = 6;
    assign _e_6787 = {7'd0, _e_6788};
    localparam[7:0] _e_10017 = 7;
    assign _e_10016 = \t  == _e_10017;
    localparam[3:0] _e_6791 = 7;
    assign _e_6790 = {7'd0, _e_6791};
    localparam[7:0] _e_10019 = 10;
    assign _e_10018 = \t  == _e_10019;
    assign _e_6793 = {7'd1, 4'bX};
    localparam[7:0] _e_10021 = 11;
    assign _e_10020 = \t  == _e_10021;
    assign _e_6795 = {7'd2, 4'bX};
    localparam[7:0] _e_10023 = 12;
    assign _e_10022 = \t  == _e_10023;
    assign _e_6797 = {7'd3, 4'bX};
    localparam[7:0] _e_10025 = 13;
    assign _e_10024 = \t  == _e_10025;
    assign _e_6799 = {7'd4, 4'bX};
    localparam[7:0] _e_10027 = 14;
    assign _e_10026 = \t  == _e_10027;
    assign _e_6801 = {7'd5, 4'bX};
    localparam[7:0] _e_10029 = 15;
    assign _e_10028 = \t  == _e_10029;
    assign _e_6803 = {7'd8, 4'bX};
    localparam[7:0] _e_10031 = 16;
    assign _e_10030 = \t  == _e_10031;
    assign _e_6805 = {7'd9, 4'bX};
    localparam[7:0] _e_10033 = 17;
    assign _e_10032 = \t  == _e_10033;
    assign _e_6807 = {7'd10, 4'bX};
    localparam[7:0] _e_10035 = 18;
    assign _e_10034 = \t  == _e_10035;
    assign _e_6809 = {7'd11, 4'bX};
    localparam[7:0] _e_10037 = 19;
    assign _e_10036 = \t  == _e_10037;
    assign _e_6811 = {7'd12, 4'bX};
    localparam[7:0] _e_10039 = 20;
    assign _e_10038 = \t  == _e_10039;
    assign _e_6813 = {7'd33, 4'bX};
    localparam[7:0] _e_10041 = 21;
    assign _e_10040 = \t  == _e_10041;
    assign _e_6815 = {7'd34, 4'bX};
    localparam[7:0] _e_10043 = 22;
    assign _e_10042 = \t  == _e_10043;
    assign _e_6817 = {7'd35, 4'bX};
    localparam[7:0] _e_10045 = 23;
    assign _e_10044 = \t  == _e_10045;
    assign _e_6819 = {7'd41, 4'bX};
    localparam[7:0] _e_10047 = 24;
    assign _e_10046 = \t  == _e_10047;
    assign _e_6821 = {7'd42, 4'bX};
    localparam[7:0] _e_10049 = 25;
    assign _e_10048 = \t  == _e_10049;
    assign _e_6823 = {7'd43, 4'bX};
    localparam[7:0] _e_10051 = 26;
    assign _e_10050 = \t  == _e_10051;
    assign _e_6825 = {7'd44, 4'bX};
    localparam[7:0] _e_10053 = 27;
    assign _e_10052 = \t  == _e_10053;
    assign _e_6827 = {7'd45, 4'bX};
    localparam[7:0] _e_10055 = 28;
    assign _e_10054 = \t  == _e_10055;
    assign _e_6829 = {7'd46, 4'bX};
    localparam[7:0] _e_10057 = 29;
    assign _e_10056 = \t  == _e_10057;
    assign _e_6831 = {7'd57, 4'bX};
    localparam[7:0] _e_10059 = 30;
    assign _e_10058 = \t  == _e_10059;
    assign _e_6833 = {7'd30, 4'bX};
    localparam[7:0] _e_10061 = 31;
    assign _e_10060 = \t  == _e_10061;
    assign _e_6835 = {7'd47, 4'bX};
    localparam[7:0] _e_10063 = 32;
    assign _e_10062 = \t  == _e_10063;
    assign _e_6837 = {7'd48, 4'bX};
    localparam[7:0] _e_10065 = 33;
    assign _e_10064 = \t  == _e_10065;
    assign _e_6839 = {7'd49, 4'bX};
    localparam[7:0] _e_10067 = 34;
    assign _e_10066 = \t  == _e_10067;
    assign _e_6841 = {7'd50, 4'bX};
    localparam[7:0] _e_10069 = 35;
    assign _e_10068 = \t  == _e_10069;
    assign _e_6843 = {7'd51, 4'bX};
    localparam[7:0] _e_10071 = 36;
    assign _e_10070 = \t  == _e_10071;
    assign _e_6845 = {7'd52, 4'bX};
    localparam[7:0] _e_10073 = 37;
    assign _e_10072 = \t  == _e_10073;
    assign _e_6847 = {7'd27, 4'bX};
    localparam[7:0] _e_10075 = 38;
    assign _e_10074 = \t  == _e_10075;
    assign _e_6849 = {7'd28, 4'bX};
    localparam[7:0] _e_10077 = 39;
    assign _e_10076 = \t  == _e_10077;
    assign _e_6851 = {7'd29, 4'bX};
    localparam[7:0] _e_10079 = 40;
    assign _e_10078 = \t  == _e_10079;
    assign _e_6853 = {7'd53, 4'bX};
    localparam[7:0] _e_10081 = 41;
    assign _e_10080 = \t  == _e_10081;
    assign _e_6855 = {7'd54, 4'bX};
    localparam[7:0] _e_10083 = 42;
    assign _e_10082 = \t  == _e_10083;
    assign _e_6857 = {7'd55, 4'bX};
    localparam[7:0] _e_10085 = 43;
    assign _e_10084 = \t  == _e_10085;
    assign _e_6859 = {7'd56, 4'bX};
    localparam[7:0] _e_10087 = 44;
    assign _e_10086 = \t  == _e_10087;
    assign _e_6861 = {7'd19, 4'bX};
    localparam[7:0] _e_10089 = 45;
    assign _e_10088 = \t  == _e_10089;
    assign _e_6863 = {7'd20, 4'bX};
    localparam[7:0] _e_10091 = 46;
    assign _e_10090 = \t  == _e_10091;
    assign _e_6865 = {7'd21, 4'bX};
    localparam[7:0] _e_10093 = 47;
    assign _e_10092 = \t  == _e_10093;
    assign _e_6867 = {7'd22, 4'bX};
    localparam[7:0] _e_10095 = 48;
    assign _e_10094 = \t  == _e_10095;
    assign _e_6869 = {7'd24, 4'bX};
    localparam[7:0] _e_10097 = 49;
    assign _e_10096 = \t  == _e_10097;
    assign _e_6871 = {7'd25, 4'bX};
    localparam[7:0] _e_10099 = 50;
    assign _e_10098 = \t  == _e_10099;
    assign _e_6873 = {7'd26, 4'bX};
    localparam[7:0] _e_10101 = 51;
    assign _e_10100 = \t  == _e_10101;
    assign _e_6875 = {7'd13, 4'bX};
    localparam[7:0] _e_10103 = 52;
    assign _e_10102 = \t  == _e_10103;
    assign _e_6877 = {7'd14, 4'bX};
    localparam[7:0] _e_10105 = 53;
    assign _e_10104 = \t  == _e_10105;
    assign _e_6879 = {7'd58, 4'bX};
    localparam[7:0] _e_10107 = 54;
    assign _e_10106 = \t  == _e_10107;
    assign _e_6881 = {7'd59, 4'bX};
    localparam[7:0] _e_10109 = 55;
    assign _e_10108 = \t  == _e_10109;
    assign _e_6883 = {7'd60, 4'bX};
    localparam[7:0] _e_10111 = 56;
    assign _e_10110 = \t  == _e_10111;
    assign _e_6885 = {7'd61, 4'bX};
    localparam[7:0] _e_10113 = 57;
    assign _e_10112 = \t  == _e_10113;
    assign _e_6887 = {7'd62, 4'bX};
    localparam[7:0] _e_10115 = 58;
    assign _e_10114 = \t  == _e_10115;
    assign _e_6889 = {7'd63, 4'bX};
    localparam[7:0] _e_10117 = 59;
    assign _e_10116 = \t  == _e_10117;
    assign _e_6891 = {7'd68, 4'bX};
    localparam[7:0] _e_10119 = 60;
    assign _e_10118 = \t  == _e_10119;
    assign _e_6893 = {7'd39, 4'bX};
    localparam[7:0] _e_10121 = 61;
    assign _e_10120 = \t  == _e_10121;
    assign _e_6895 = {7'd72, 4'bX};
    localparam[7:0] _e_10123 = 62;
    assign _e_10122 = \t  == _e_10123;
    assign _e_6897 = {7'd64, 4'bX};
    localparam[7:0] _e_10125 = 63;
    assign _e_10124 = \t  == _e_10125;
    assign _e_6899 = {7'd65, 4'bX};
    localparam[7:0] _e_10127 = 64;
    assign _e_10126 = \t  == _e_10127;
    assign _e_6901 = {7'd66, 4'bX};
    localparam[7:0] _e_10129 = 65;
    assign _e_10128 = \t  == _e_10129;
    assign _e_6903 = {7'd67, 4'bX};
    localparam[7:0] _e_10131 = 66;
    assign _e_10130 = \t  == _e_10131;
    assign _e_6905 = {7'd15, 4'bX};
    localparam[7:0] _e_10133 = 67;
    assign _e_10132 = \t  == _e_10133;
    assign _e_6907 = {7'd16, 4'bX};
    localparam[7:0] _e_10135 = 68;
    assign _e_10134 = \t  == _e_10135;
    assign _e_6909 = {7'd17, 4'bX};
    localparam[7:0] _e_10137 = 69;
    assign _e_10136 = \t  == _e_10137;
    assign _e_6911 = {7'd18, 4'bX};
    localparam[7:0] _e_10139 = 70;
    assign _e_10138 = \t  == _e_10139;
    assign _e_6913 = {7'd69, 4'bX};
    localparam[7:0] _e_10141 = 71;
    assign _e_10140 = \t  == _e_10141;
    assign _e_6915 = {7'd70, 4'bX};
    localparam[7:0] _e_10143 = 72;
    assign _e_10142 = \t  == _e_10143;
    assign _e_6917 = {7'd71, 4'bX};
    localparam[7:0] _e_10145 = 73;
    assign _e_10144 = \t  == _e_10145;
    assign _e_6919 = {7'd36, 4'bX};
    localparam[7:0] _e_10147 = 74;
    assign _e_10146 = \t  == _e_10147;
    assign _e_6921 = {7'd37, 4'bX};
    localparam[7:0] _e_10149 = 75;
    assign _e_10148 = \t  == _e_10149;
    assign _e_6923 = {7'd38, 4'bX};
    localparam[7:0] _e_10151 = 76;
    assign _e_10150 = \t  == _e_10151;
    assign _e_6925 = {7'd73, 4'bX};
    localparam[7:0] _e_10153 = 77;
    assign _e_10152 = \t  == _e_10153;
    assign _e_6927 = {7'd6, 4'bX};
    localparam[7:0] _e_10155 = 78;
    assign _e_10154 = \t  == _e_10155;
    assign _e_6929 = {7'd74, 4'bX};
    localparam[7:0] _e_10157 = 79;
    assign _e_10156 = \t  == _e_10157;
    assign _e_6931 = {7'd75, 4'bX};
    localparam[7:0] _e_10159 = 100;
    assign _e_10158 = \t  == _e_10159;
    localparam[3:0] _e_6934 = 8;
    assign _e_6933 = {7'd0, _e_6934};
    localparam[7:0] _e_10161 = 101;
    assign _e_10160 = \t  == _e_10161;
    localparam[3:0] _e_6937 = 9;
    assign _e_6936 = {7'd0, _e_6937};
    localparam[7:0] _e_10163 = 102;
    assign _e_10162 = \t  == _e_10163;
    localparam[3:0] _e_6940 = 10;
    assign _e_6939 = {7'd0, _e_6940};
    localparam[7:0] _e_10165 = 103;
    assign _e_10164 = \t  == _e_10165;
    localparam[3:0] _e_6943 = 11;
    assign _e_6942 = {7'd0, _e_6943};
    localparam[7:0] _e_10167 = 104;
    assign _e_10166 = \t  == _e_10167;
    localparam[3:0] _e_6946 = 12;
    assign _e_6945 = {7'd0, _e_6946};
    localparam[7:0] _e_10169 = 105;
    assign _e_10168 = \t  == _e_10169;
    localparam[3:0] _e_6949 = 13;
    assign _e_6948 = {7'd0, _e_6949};
    localparam[7:0] _e_10171 = 106;
    assign _e_10170 = \t  == _e_10171;
    localparam[3:0] _e_6952 = 14;
    assign _e_6951 = {7'd0, _e_6952};
    localparam[7:0] _e_10173 = 107;
    assign _e_10172 = \t  == _e_10173;
    localparam[3:0] _e_6955 = 15;
    assign _e_6954 = {7'd0, _e_6955};
    assign \_  = \t ;
    localparam[0:0] _e_10174 = 1;
    assign _e_6957 = {7'd1, 4'bX};
    always_comb begin
        priority casez ({_e_10002, _e_10004, _e_10006, _e_10008, _e_10010, _e_10012, _e_10014, _e_10016, _e_10018, _e_10020, _e_10022, _e_10024, _e_10026, _e_10028, _e_10030, _e_10032, _e_10034, _e_10036, _e_10038, _e_10040, _e_10042, _e_10044, _e_10046, _e_10048, _e_10050, _e_10052, _e_10054, _e_10056, _e_10058, _e_10060, _e_10062, _e_10064, _e_10066, _e_10068, _e_10070, _e_10072, _e_10074, _e_10076, _e_10078, _e_10080, _e_10082, _e_10084, _e_10086, _e_10088, _e_10090, _e_10092, _e_10094, _e_10096, _e_10098, _e_10100, _e_10102, _e_10104, _e_10106, _e_10108, _e_10110, _e_10112, _e_10114, _e_10116, _e_10118, _e_10120, _e_10122, _e_10124, _e_10126, _e_10128, _e_10130, _e_10132, _e_10134, _e_10136, _e_10138, _e_10140, _e_10142, _e_10144, _e_10146, _e_10148, _e_10150, _e_10152, _e_10154, _e_10156, _e_10158, _e_10160, _e_10162, _e_10164, _e_10166, _e_10168, _e_10170, _e_10172, _e_10174})
            87'b1??????????????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6769;
            87'b01?????????????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6772;
            87'b001????????????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6775;
            87'b0001???????????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6778;
            87'b00001??????????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6781;
            87'b000001?????????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6784;
            87'b0000001????????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6787;
            87'b00000001???????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6790;
            87'b000000001??????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6793;
            87'b0000000001?????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6795;
            87'b00000000001????????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6797;
            87'b000000000001???????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6799;
            87'b0000000000001??????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6801;
            87'b00000000000001?????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6803;
            87'b000000000000001????????????????????????????????????????????????????????????????????????: _e_6766 = _e_6805;
            87'b0000000000000001???????????????????????????????????????????????????????????????????????: _e_6766 = _e_6807;
            87'b00000000000000001??????????????????????????????????????????????????????????????????????: _e_6766 = _e_6809;
            87'b000000000000000001?????????????????????????????????????????????????????????????????????: _e_6766 = _e_6811;
            87'b0000000000000000001????????????????????????????????????????????????????????????????????: _e_6766 = _e_6813;
            87'b00000000000000000001???????????????????????????????????????????????????????????????????: _e_6766 = _e_6815;
            87'b000000000000000000001??????????????????????????????????????????????????????????????????: _e_6766 = _e_6817;
            87'b0000000000000000000001?????????????????????????????????????????????????????????????????: _e_6766 = _e_6819;
            87'b00000000000000000000001????????????????????????????????????????????????????????????????: _e_6766 = _e_6821;
            87'b000000000000000000000001???????????????????????????????????????????????????????????????: _e_6766 = _e_6823;
            87'b0000000000000000000000001??????????????????????????????????????????????????????????????: _e_6766 = _e_6825;
            87'b00000000000000000000000001?????????????????????????????????????????????????????????????: _e_6766 = _e_6827;
            87'b000000000000000000000000001????????????????????????????????????????????????????????????: _e_6766 = _e_6829;
            87'b0000000000000000000000000001???????????????????????????????????????????????????????????: _e_6766 = _e_6831;
            87'b00000000000000000000000000001??????????????????????????????????????????????????????????: _e_6766 = _e_6833;
            87'b000000000000000000000000000001?????????????????????????????????????????????????????????: _e_6766 = _e_6835;
            87'b0000000000000000000000000000001????????????????????????????????????????????????????????: _e_6766 = _e_6837;
            87'b00000000000000000000000000000001???????????????????????????????????????????????????????: _e_6766 = _e_6839;
            87'b000000000000000000000000000000001??????????????????????????????????????????????????????: _e_6766 = _e_6841;
            87'b0000000000000000000000000000000001?????????????????????????????????????????????????????: _e_6766 = _e_6843;
            87'b00000000000000000000000000000000001????????????????????????????????????????????????????: _e_6766 = _e_6845;
            87'b000000000000000000000000000000000001???????????????????????????????????????????????????: _e_6766 = _e_6847;
            87'b0000000000000000000000000000000000001??????????????????????????????????????????????????: _e_6766 = _e_6849;
            87'b00000000000000000000000000000000000001?????????????????????????????????????????????????: _e_6766 = _e_6851;
            87'b000000000000000000000000000000000000001????????????????????????????????????????????????: _e_6766 = _e_6853;
            87'b0000000000000000000000000000000000000001???????????????????????????????????????????????: _e_6766 = _e_6855;
            87'b00000000000000000000000000000000000000001??????????????????????????????????????????????: _e_6766 = _e_6857;
            87'b000000000000000000000000000000000000000001?????????????????????????????????????????????: _e_6766 = _e_6859;
            87'b0000000000000000000000000000000000000000001????????????????????????????????????????????: _e_6766 = _e_6861;
            87'b00000000000000000000000000000000000000000001???????????????????????????????????????????: _e_6766 = _e_6863;
            87'b000000000000000000000000000000000000000000001??????????????????????????????????????????: _e_6766 = _e_6865;
            87'b0000000000000000000000000000000000000000000001?????????????????????????????????????????: _e_6766 = _e_6867;
            87'b00000000000000000000000000000000000000000000001????????????????????????????????????????: _e_6766 = _e_6869;
            87'b000000000000000000000000000000000000000000000001???????????????????????????????????????: _e_6766 = _e_6871;
            87'b0000000000000000000000000000000000000000000000001??????????????????????????????????????: _e_6766 = _e_6873;
            87'b00000000000000000000000000000000000000000000000001?????????????????????????????????????: _e_6766 = _e_6875;
            87'b000000000000000000000000000000000000000000000000001????????????????????????????????????: _e_6766 = _e_6877;
            87'b0000000000000000000000000000000000000000000000000001???????????????????????????????????: _e_6766 = _e_6879;
            87'b00000000000000000000000000000000000000000000000000001??????????????????????????????????: _e_6766 = _e_6881;
            87'b000000000000000000000000000000000000000000000000000001?????????????????????????????????: _e_6766 = _e_6883;
            87'b0000000000000000000000000000000000000000000000000000001????????????????????????????????: _e_6766 = _e_6885;
            87'b00000000000000000000000000000000000000000000000000000001???????????????????????????????: _e_6766 = _e_6887;
            87'b000000000000000000000000000000000000000000000000000000001??????????????????????????????: _e_6766 = _e_6889;
            87'b0000000000000000000000000000000000000000000000000000000001?????????????????????????????: _e_6766 = _e_6891;
            87'b00000000000000000000000000000000000000000000000000000000001????????????????????????????: _e_6766 = _e_6893;
            87'b000000000000000000000000000000000000000000000000000000000001???????????????????????????: _e_6766 = _e_6895;
            87'b0000000000000000000000000000000000000000000000000000000000001??????????????????????????: _e_6766 = _e_6897;
            87'b00000000000000000000000000000000000000000000000000000000000001?????????????????????????: _e_6766 = _e_6899;
            87'b000000000000000000000000000000000000000000000000000000000000001????????????????????????: _e_6766 = _e_6901;
            87'b0000000000000000000000000000000000000000000000000000000000000001???????????????????????: _e_6766 = _e_6903;
            87'b00000000000000000000000000000000000000000000000000000000000000001??????????????????????: _e_6766 = _e_6905;
            87'b000000000000000000000000000000000000000000000000000000000000000001?????????????????????: _e_6766 = _e_6907;
            87'b0000000000000000000000000000000000000000000000000000000000000000001????????????????????: _e_6766 = _e_6909;
            87'b00000000000000000000000000000000000000000000000000000000000000000001???????????????????: _e_6766 = _e_6911;
            87'b000000000000000000000000000000000000000000000000000000000000000000001??????????????????: _e_6766 = _e_6913;
            87'b0000000000000000000000000000000000000000000000000000000000000000000001?????????????????: _e_6766 = _e_6915;
            87'b00000000000000000000000000000000000000000000000000000000000000000000001????????????????: _e_6766 = _e_6917;
            87'b000000000000000000000000000000000000000000000000000000000000000000000001???????????????: _e_6766 = _e_6919;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000001??????????????: _e_6766 = _e_6921;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000001?????????????: _e_6766 = _e_6923;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000001????????????: _e_6766 = _e_6925;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000000001???????????: _e_6766 = _e_6927;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000000001??????????: _e_6766 = _e_6929;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000000001?????????: _e_6766 = _e_6931;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000000000001????????: _e_6766 = _e_6933;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000000000001???????: _e_6766 = _e_6936;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000000000001??????: _e_6766 = _e_6939;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000000000000001?????: _e_6766 = _e_6942;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000000000000001????: _e_6766 = _e_6945;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000000000000001???: _e_6766 = _e_6948;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000001??: _e_6766 = _e_6951;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000001?: _e_6766 = _e_6954;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000001: _e_6766 = _e_6957;
            87'b?: _e_6766 = 11'dx;
        endcase
    end
    assign output__ = _e_6766;
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
    (* src = "src/imem.spade:228,36" *)
    logic[31:0] _e_6961;
    (* src = "src/imem.spade:228,36" *)
    logic[31:0] _e_6960;
    (* src = "src/imem.spade:228,30" *)
    logic \guard_bit ;
    (* src = "src/imem.spade:229,23" *)
    logic \guard ;
    (* src = "src/imem.spade:231,34" *)
    logic[31:0] _e_6972;
    (* src = "src/imem.spade:231,34" *)
    logic[31:0] _e_6971;
    (* src = "src/imem.spade:231,28" *)
    logic[7:0] \src_tok ;
    (* src = "src/imem.spade:232,34" *)
    logic[31:0] _e_6979;
    (* src = "src/imem.spade:232,34" *)
    logic[31:0] _e_6978;
    (* src = "src/imem.spade:232,28" *)
    logic[7:0] \dst_tok ;
    (* src = "src/imem.spade:233,34" *)
    logic[31:0] _e_6985;
    (* src = "src/imem.spade:233,28" *)
    logic[15:0] \imm16 ;
    (* src = "src/imem.spade:235,15" *)
    logic[36:0] \src ;
    (* src = "src/imem.spade:236,15" *)
    logic[10:0] \dst ;
    (* src = "src/imem.spade:237,5" *)
    logic[48:0] _e_6996;
    localparam[31:0] _e_6963 = 32'd31;
    assign _e_6961 = \mw  >> _e_6963;
    localparam[31:0] _e_6964 = 32'd1;
    assign _e_6960 = _e_6961 & _e_6964;
    assign \guard_bit  = _e_6960[0:0];
    localparam[0:0] _e_6968 = 0;
    assign \guard  = \guard_bit  != _e_6968;
    localparam[31:0] _e_6974 = 32'd24;
    assign _e_6972 = \mw  >> _e_6974;
    localparam[31:0] _e_6975 = 32'd127;
    assign _e_6971 = _e_6972 & _e_6975;
    assign \src_tok  = _e_6971[7:0];
    localparam[31:0] _e_6981 = 32'd17;
    assign _e_6979 = \mw  >> _e_6981;
    localparam[31:0] _e_6982 = 32'd127;
    assign _e_6978 = _e_6979 & _e_6982;
    assign \dst_tok  = _e_6978[7:0];
    localparam[31:0] _e_6987 = 32'd65535;
    assign _e_6985 = \mw  & _e_6987;
    assign \imm16  = _e_6985[15:0];
    (* src = "src/imem.spade:235,15" *)
    \tta::imem::decode_src_tok  decode_src_tok_0(.t_i(\src_tok ), .imm16_i(\imm16 ), .output__(\src ));
    (* src = "src/imem.spade:236,15" *)
    \tta::imem::decode_dst_tok  decode_dst_tok_0(.t_i(\dst_tok ), .output__(\dst ));
    assign _e_6996 = {\src , \dst , \guard };
    assign output__ = _e_6996;
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
    localparam[31:0] _e_7001 = 32'd0;
    assign output__ = _e_7001;
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
    logic _e_10176;
    logic _e_10178;
    (* src = "src/imem.spade:266,23" *)
    logic[10:0] _e_7007;
    logic _e_10180;
    (* src = "src/imem.spade:267,17" *)
    logic[10:0] _e_7011;
    (* src = "src/imem.spade:265,29" *)
    logic[10:0] _e_7016;
    (* src = "src/imem.spade:265,9" *)
    logic \wren ;
    (* src = "src/imem.spade:265,9" *)
    logic[9:0] \addr_calc ;
    (* src = "src/imem.spade:270,9" *)
    logic[31:0] \instr ;
    logic _e_10182;
    logic _e_10184;
    logic _e_10186;
    (* src = "src/imem.spade:269,18" *)
    logic[31:0] \wdata0 ;
    (* src = "src/imem.spade:274,9" *)
    logic[31:0] instr_n1;
    logic _e_10188;
    logic _e_10190;
    logic _e_10192;
    (* src = "src/imem.spade:273,18" *)
    logic[31:0] \wdata1 ;
    (* src = "src/imem.spade:278,33" *)
    logic[31:0] _e_7035;
    (* src = "src/imem.spade:278,14" *)
    reg[31:0] \rdata0 ;
    (* src = "src/imem.spade:279,33" *)
    logic[31:0] _e_7043;
    (* src = "src/imem.spade:279,14" *)
    reg[31:0] \rdata1 ;
    (* src = "src/imem.spade:283,9" *)
    logic[9:0] \_ ;
    logic _e_10194;
    logic _e_10196;
    (* src = "src/imem.spade:283,20" *)
    logic[98:0] _e_7053;
    logic _e_10198;
    (* src = "src/imem.spade:286,25" *)
    logic[98:0] _e_7059;
    logic _e_10200;
    (* src = "src/imem.spade:288,31" *)
    logic[48:0] \mv0 ;
    (* src = "src/imem.spade:289,31" *)
    logic[48:0] \mv1 ;
    (* src = "src/imem.spade:290,26" *)
    logic[97:0] _e_7069;
    (* src = "src/imem.spade:290,21" *)
    logic[98:0] _e_7068;
    (* src = "src/imem.spade:285,13" *)
    logic[98:0] _e_7056;
    (* src = "src/imem.spade:282,5" *)
    logic[98:0] _e_7049;
    assign \addr  = \wr_addr [9:0];
    assign _e_10176 = \wr_addr [10] == 1'd1;
    localparam[0:0] _e_10177 = 1;
    assign _e_10178 = _e_10176 && _e_10177;
    localparam[0:0] _e_7008 = 1;
    assign _e_7007 = {_e_7008, \addr };
    assign _e_10180 = \wr_addr [10] == 1'd0;
    localparam[0:0] _e_7012 = 0;
    assign _e_7011 = {_e_7012, \fetch_pc };
    always_comb begin
        priority casez ({_e_10178, _e_10180})
            2'b1?: _e_7016 = _e_7007;
            2'b01: _e_7016 = _e_7011;
            2'b?: _e_7016 = 11'dx;
        endcase
    end
    assign \wren  = _e_7016[10];
    assign \addr_calc  = _e_7016[9:0];
    assign \instr  = \wr_slot0 [31:0];
    assign _e_10182 = \wr_slot0 [32] == 1'd1;
    localparam[0:0] _e_10183 = 1;
    assign _e_10184 = _e_10182 && _e_10183;
    assign _e_10186 = \wr_slot0 [32] == 1'd0;
    localparam[31:0] _e_7023 = 32'd0;
    always_comb begin
        priority casez ({_e_10184, _e_10186})
            2'b1?: \wdata0  = \instr ;
            2'b01: \wdata0  = _e_7023;
            2'b?: \wdata0  = 32'dx;
        endcase
    end
    assign instr_n1 = \wr_slot1 [31:0];
    assign _e_10188 = \wr_slot1 [32] == 1'd1;
    localparam[0:0] _e_10189 = 1;
    assign _e_10190 = _e_10188 && _e_10189;
    assign _e_10192 = \wr_slot1 [32] == 1'd0;
    localparam[31:0] _e_7031 = 32'd0;
    always_comb begin
        priority casez ({_e_10190, _e_10192})
            2'b1?: \wdata1  = instr_n1;
            2'b01: \wdata1  = _e_7031;
            2'b?: \wdata1  = 32'dx;
        endcase
    end
    (* src = "src/imem.spade:278,33" *)
    \tta::sram::iram_1024x32  iram_1024x32_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .addr_i(\addr_calc ), .we_i(\wren ), .wdata_i(\wdata0 ), .output__(_e_7035));
    always @(posedge \clk ) begin
        \rdata0  <= _e_7035;
    end
    (* src = "src/imem.spade:279,33" *)
    \tta::sram::iram_1024x32  iram_1024x32_1(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .addr_i(\addr_calc ), .we_i(\wren ), .wdata_i(\wdata1 ), .output__(_e_7043));
    always @(posedge \clk ) begin
        \rdata1  <= _e_7043;
    end
    assign \_  = \wr_addr [9:0];
    assign _e_10194 = \wr_addr [10] == 1'd1;
    localparam[0:0] _e_10195 = 1;
    assign _e_10196 = _e_10194 && _e_10195;
    assign _e_7053 = {1'd0, 98'bX};
    assign _e_10198 = \wr_addr [10] == 1'd0;
    assign _e_7059 = {1'd0, 98'bX};
    assign _e_10200 = !\boot_mode ;
    (* src = "src/imem.spade:288,31" *)
    \tta::imem::decode_move  decode_move_0(.mw_i(\rdata0 ), .output__(\mv0 ));
    (* src = "src/imem.spade:289,31" *)
    \tta::imem::decode_move  decode_move_1(.mw_i(\rdata1 ), .output__(\mv1 ));
    assign _e_7069 = {\mv0 , \mv1 };
    assign _e_7068 = {1'd1, _e_7069};
    always_comb begin
        priority casez ({\boot_mode , _e_10200})
            2'b1?: _e_7056 = _e_7059;
            2'b01: _e_7056 = _e_7068;
            2'b?: _e_7056 = 99'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10196, _e_10198})
            2'b1?: _e_7049 = _e_7053;
            2'b01: _e_7049 = _e_7056;
            2'b?: _e_7049 = 99'dx;
        endcase
    end
    assign output__ = _e_7049;
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
    (* src = "src/spi_master.spade:26,9" *)
    logic _e_7074;
    (* src = "src/spi_master.spade:26,5" *)
    logic[14:0] _e_7073;
    assign _e_7074 = {1'd0};
    localparam[4:0] _e_7075 = 0;
    localparam[7:0] _e_7076 = 0;
    localparam[0:0] _e_7077 = 0;
    assign _e_7073 = {_e_7074, _e_7075, _e_7076, _e_7077};
    assign output__ = _e_7073;
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
    (* src = "src/spi_master.spade:37,32" *)
    logic[14:0] _e_7082;
    (* src = "src/spi_master.spade:39,19" *)
    logic _e_7087;
    (* src = "src/spi_master.spade:40,17" *)
    logic _e_7089;
    logic _e_10202;
    (* src = "src/spi_master.spade:41,27" *)
    logic[8:0] _e_7092;
    (* src = "src/spi_master.spade:43,25" *)
    logic[8:0] _e_7095;
    (* src = "src/spi_master.spade:43,25" *)
    logic[7:0] \data ;
    logic _e_10204;
    logic _e_10206;
    (* src = "src/spi_master.spade:43,43" *)
    logic _e_7097;
    (* src = "src/spi_master.spade:43,39" *)
    logic[14:0] _e_7096;
    (* src = "src/spi_master.spade:44,25" *)
    logic[8:0] _e_7101;
    logic _e_10208;
    (* src = "src/spi_master.spade:41,21" *)
    logic[14:0] _e_7091;
    (* src = "src/spi_master.spade:47,17" *)
    logic _e_7103;
    logic _e_10210;
    (* src = "src/spi_master.spade:51,41" *)
    logic[4:0] _e_7107;
    (* src = "src/spi_master.spade:51,41" *)
    logic[5:0] _e_7106;
    (* src = "src/spi_master.spade:51,35" *)
    logic[4:0] \new_cnt ;
    (* src = "src/spi_master.spade:53,24" *)
    logic[4:0] _e_7113;
    (* src = "src/spi_master.spade:53,24" *)
    logic _e_7112;
    (* src = "src/spi_master.spade:56,29" *)
    logic _e_7118;
    (* src = "src/spi_master.spade:56,45" *)
    logic[7:0] _e_7120;
    (* src = "src/spi_master.spade:56,25" *)
    logic[14:0] _e_7117;
    (* src = "src/spi_master.spade:58,29" *)
    logic[4:0] _e_7125;
    (* src = "src/spi_master.spade:58,29" *)
    logic _e_7124;
    (* src = "src/spi_master.spade:61,29" *)
    logic _e_7131;
    (* src = "src/spi_master.spade:61,55" *)
    logic[7:0] _e_7133;
    (* src = "src/spi_master.spade:61,25" *)
    logic[14:0] _e_7130;
    (* src = "src/spi_master.spade:66,40" *)
    logic[7:0] _e_7140;
    (* src = "src/spi_master.spade:66,39" *)
    logic[7:0] _e_7139;
    (* src = "src/spi_master.spade:66,58" *)
    logic _e_7144;
    logic[7:0] _e_7143;
    (* src = "src/spi_master.spade:66,39" *)
    logic[7:0] \next_sh ;
    (* src = "src/spi_master.spade:67,29" *)
    logic _e_7148;
    (* src = "src/spi_master.spade:67,64" *)
    logic _e_7151;
    (* src = "src/spi_master.spade:67,25" *)
    logic[14:0] _e_7147;
    (* src = "src/spi_master.spade:58,26" *)
    logic[14:0] _e_7123;
    (* src = "src/spi_master.spade:53,21" *)
    logic[14:0] _e_7111;
    (* src = "src/spi_master.spade:39,13" *)
    logic[14:0] _e_7086;
    (* src = "src/spi_master.spade:38,9" *)
    logic[14:0] _e_7083;
    (* src = "src/spi_master.spade:37,14" *)
    reg[14:0] \r ;
    (* src = "src/spi_master.spade:84,20" *)
    logic _e_7156;
    (* src = "src/spi_master.spade:85,9" *)
    logic _e_7158;
    logic _e_10212;
    (* src = "src/spi_master.spade:86,9" *)
    logic _e_7160;
    logic _e_10214;
    (* src = "src/spi_master.spade:84,14" *)
    logic \cs ;
    (* src = "src/spi_master.spade:91,22" *)
    logic _e_7164;
    (* src = "src/spi_master.spade:92,9" *)
    logic _e_7166;
    logic _e_10216;
    (* src = "src/spi_master.spade:92,29" *)
    logic[4:0] _e_7169;
    (* src = "src/spi_master.spade:92,28" *)
    logic[4:0] _e_7168;
    (* src = "src/spi_master.spade:92,28" *)
    logic _e_7167;
    (* src = "src/spi_master.spade:93,9" *)
    logic _e_7173;
    logic _e_10218;
    (* src = "src/spi_master.spade:91,16" *)
    logic \sclk ;
    (* src = "src/spi_master.spade:99,23" *)
    logic[7:0] _e_7179;
    (* src = "src/spi_master.spade:99,22" *)
    logic[7:0] _e_7178;
    (* src = "src/spi_master.spade:99,22" *)
    logic _e_7177;
    (* src = "src/spi_master.spade:100,9" *)
    logic _e_7183;
    (* src = "src/spi_master.spade:101,9" *)
    logic _e_7185;
    logic _e_10220;
    (* src = "src/spi_master.spade:99,16" *)
    logic \mosi ;
    (* src = "src/spi_master.spade:106,30" *)
    logic[4:0] _e_7192;
    (* src = "src/spi_master.spade:106,29" *)
    logic _e_7191;
    (* src = "src/spi_master.spade:106,21" *)
    logic _e_7189;
    (* src = "src/spi_master.spade:109,14" *)
    logic[7:0] _e_7197;
    (* src = "src/spi_master.spade:109,9" *)
    logic[8:0] _e_7196;
    (* src = "src/spi_master.spade:111,9" *)
    logic[8:0] _e_7200;
    (* src = "src/spi_master.spade:106,18" *)
    logic[8:0] \rx_val ;
    (* src = "src/spi_master.spade:114,5" *)
    logic[11:0] _e_7202;
    (* src = "src/spi_master.spade:37,32" *)
    \tta::spi_master::reset_spi  reset_spi_0(.output__(_e_7082));
    assign _e_7087 = \r [14];
    assign _e_7089 = _e_7087;
    assign _e_10202 = _e_7087 == 1'd0;
    assign _e_7092 = \start_tx ;
    assign _e_7095 = _e_7092;
    assign \data  = _e_7092[7:0];
    assign _e_10204 = _e_7092[8] == 1'd1;
    localparam[0:0] _e_10205 = 1;
    assign _e_10206 = _e_10204 && _e_10205;
    assign _e_7097 = {1'd1};
    localparam[4:0] _e_7098 = 0;
    localparam[0:0] _e_7100 = 0;
    assign _e_7096 = {_e_7097, _e_7098, \data , _e_7100};
    assign _e_7101 = _e_7092;
    assign _e_10208 = _e_7092[8] == 1'd0;
    always_comb begin
        priority casez ({_e_10206, _e_10208})
            2'b1?: _e_7091 = _e_7096;
            2'b01: _e_7091 = \r ;
            2'b?: _e_7091 = 15'dx;
        endcase
    end
    assign _e_7103 = _e_7087;
    assign _e_10210 = _e_7087 == 1'd1;
    assign _e_7107 = \r [13:9];
    localparam[4:0] _e_7109 = 1;
    assign _e_7106 = _e_7107 + _e_7109;
    assign \new_cnt  = _e_7106[4:0];
    assign _e_7113 = \r [13:9];
    localparam[4:0] _e_7115 = 16;
    assign _e_7112 = _e_7113 == _e_7115;
    assign _e_7118 = {1'd0};
    localparam[4:0] _e_7119 = 0;
    assign _e_7120 = \r [8:1];
    localparam[0:0] _e_7122 = 0;
    assign _e_7117 = {_e_7118, _e_7119, _e_7120, _e_7122};
    localparam[4:0] _e_7127 = 2;
    assign _e_7125 = \new_cnt  % _e_7127;
    localparam[4:0] _e_7128 = 0;
    assign _e_7124 = _e_7125 != _e_7128;
    assign _e_7131 = {1'd1};
    assign _e_7133 = \r [8:1];
    assign _e_7130 = {_e_7131, \new_cnt , _e_7133, \miso };
    assign _e_7140 = \r [8:1];
    localparam[7:0] _e_7142 = 1;
    assign _e_7139 = _e_7140 << _e_7142;
    assign _e_7144 = \r [0];
    assign _e_7143 = {7'b0, _e_7144};
    assign \next_sh  = _e_7139 | _e_7143;
    assign _e_7148 = {1'd1};
    assign _e_7151 = \r [0];
    assign _e_7147 = {_e_7148, \new_cnt , \next_sh , _e_7151};
    assign _e_7123 = _e_7124 ? _e_7130 : _e_7147;
    assign _e_7111 = _e_7112 ? _e_7117 : _e_7123;
    always_comb begin
        priority casez ({_e_10202, _e_10210})
            2'b1?: _e_7086 = _e_7091;
            2'b01: _e_7086 = _e_7111;
            2'b?: _e_7086 = 15'dx;
        endcase
    end
    assign _e_7083 = \tick  ? _e_7086 : \r ;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_7082;
        end
        else begin
            \r  <= _e_7083;
        end
    end
    assign _e_7156 = \r [14];
    assign _e_7158 = _e_7156;
    assign _e_10212 = _e_7156 == 1'd0;
    localparam[0:0] _e_7159 = 1;
    assign _e_7160 = _e_7156;
    assign _e_10214 = _e_7156 == 1'd1;
    localparam[0:0] _e_7161 = 0;
    always_comb begin
        priority casez ({_e_10212, _e_10214})
            2'b1?: \cs  = _e_7159;
            2'b01: \cs  = _e_7161;
            2'b?: \cs  = 1'dx;
        endcase
    end
    assign _e_7164 = \r [14];
    assign _e_7166 = _e_7164;
    assign _e_10216 = _e_7164 == 1'd1;
    assign _e_7169 = \r [13:9];
    localparam[4:0] _e_7171 = 2;
    assign _e_7168 = _e_7169 % _e_7171;
    localparam[4:0] _e_7172 = 0;
    assign _e_7167 = _e_7168 != _e_7172;
    assign _e_7173 = _e_7164;
    assign _e_10218 = _e_7164 == 1'd0;
    localparam[0:0] _e_7174 = 0;
    always_comb begin
        priority casez ({_e_10216, _e_10218})
            2'b1?: \sclk  = _e_7167;
            2'b01: \sclk  = _e_7174;
            2'b?: \sclk  = 1'dx;
        endcase
    end
    assign _e_7179 = \r [8:1];
    localparam[7:0] _e_7181 = 7;
    assign _e_7178 = _e_7179 >> _e_7181;
    localparam[7:0] _e_7182 = 0;
    assign _e_7177 = _e_7178 != _e_7182;
    assign _e_7183 = _e_7177;
    localparam[0:0] _e_7184 = 1;
    assign _e_7185 = _e_7177;
    assign _e_10220 = !_e_7177;
    localparam[0:0] _e_7186 = 0;
    always_comb begin
        priority casez ({_e_7177, _e_10220})
            2'b1?: \mosi  = _e_7184;
            2'b01: \mosi  = _e_7186;
            2'b?: \mosi  = 1'dx;
        endcase
    end
    assign _e_7192 = \r [13:9];
    localparam[4:0] _e_7194 = 16;
    assign _e_7191 = _e_7192 == _e_7194;
    assign _e_7189 = \tick  && _e_7191;
    assign _e_7197 = \r [8:1];
    assign _e_7196 = {1'd1, _e_7197};
    assign _e_7200 = {1'd0, 8'bX};
    assign \rx_val  = _e_7189 ? _e_7196 : _e_7200;
    assign _e_7202 = {\cs , \sclk , \mosi , \rx_val };
    assign output__ = _e_7202;
endmodule

module \tta::regfile::regfile8_fu  (
        input clk_i,
        input rst_i,
        input[36:0] wr0_i,
        input[36:0] wr1_i,
        input[3:0] ra0_i,
        input[3:0] ra1_i,
        output[63:0] output__
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
    (* src = "src/regfile.spade:26,43" *)
    logic[31:0] _e_7212;
    (* src = "src/regfile.spade:26,14" *)
    reg[31:0] \r0 ;
    (* src = "src/regfile.spade:27,43" *)
    logic[31:0] _e_7221;
    (* src = "src/regfile.spade:27,14" *)
    reg[31:0] \r1 ;
    (* src = "src/regfile.spade:28,43" *)
    logic[31:0] _e_7230;
    (* src = "src/regfile.spade:28,14" *)
    reg[31:0] \r2 ;
    (* src = "src/regfile.spade:29,43" *)
    logic[31:0] _e_7239;
    (* src = "src/regfile.spade:29,14" *)
    reg[31:0] \r3 ;
    (* src = "src/regfile.spade:30,43" *)
    logic[31:0] _e_7248;
    (* src = "src/regfile.spade:30,14" *)
    reg[31:0] \r4 ;
    (* src = "src/regfile.spade:31,43" *)
    logic[31:0] _e_7257;
    (* src = "src/regfile.spade:31,14" *)
    reg[31:0] \r5 ;
    (* src = "src/regfile.spade:32,43" *)
    logic[31:0] _e_7266;
    (* src = "src/regfile.spade:32,14" *)
    reg[31:0] \r6 ;
    (* src = "src/regfile.spade:33,43" *)
    logic[31:0] _e_7275;
    (* src = "src/regfile.spade:33,14" *)
    reg[31:0] \r7 ;
    (* src = "src/regfile.spade:35,43" *)
    logic[31:0] _e_7284;
    (* src = "src/regfile.spade:35,14" *)
    reg[31:0] \r8 ;
    (* src = "src/regfile.spade:36,43" *)
    logic[31:0] _e_7293;
    (* src = "src/regfile.spade:36,14" *)
    reg[31:0] \r9 ;
    (* src = "src/regfile.spade:37,44" *)
    logic[31:0] _e_7302;
    (* src = "src/regfile.spade:37,14" *)
    reg[31:0] \r10 ;
    (* src = "src/regfile.spade:38,44" *)
    logic[31:0] _e_7311;
    (* src = "src/regfile.spade:38,14" *)
    reg[31:0] \r11 ;
    (* src = "src/regfile.spade:39,44" *)
    logic[31:0] _e_7320;
    (* src = "src/regfile.spade:39,14" *)
    reg[31:0] \r12 ;
    (* src = "src/regfile.spade:40,44" *)
    logic[31:0] _e_7329;
    (* src = "src/regfile.spade:40,14" *)
    reg[31:0] \r13 ;
    (* src = "src/regfile.spade:41,44" *)
    logic[31:0] _e_7338;
    (* src = "src/regfile.spade:41,14" *)
    reg[31:0] \r14 ;
    (* src = "src/regfile.spade:42,44" *)
    logic[31:0] _e_7347;
    (* src = "src/regfile.spade:42,14" *)
    reg[31:0] \r15 ;
    logic _e_10221;
    logic _e_10223;
    logic _e_10225;
    logic _e_10227;
    logic _e_10229;
    logic _e_10231;
    logic _e_10233;
    logic _e_10235;
    logic _e_10237;
    logic _e_10239;
    logic _e_10241;
    logic _e_10243;
    logic _e_10245;
    logic _e_10247;
    logic _e_10249;
    (* src = "src/regfile.spade:61,29" *)
    logic[3:0] \_ ;
    (* src = "src/regfile.spade:45,25" *)
    logic[31:0] \rd0 ;
    logic _e_10252;
    logic _e_10254;
    logic _e_10256;
    logic _e_10258;
    logic _e_10260;
    logic _e_10262;
    logic _e_10264;
    logic _e_10266;
    logic _e_10268;
    logic _e_10270;
    logic _e_10272;
    logic _e_10274;
    logic _e_10276;
    logic _e_10278;
    logic _e_10280;
    (* src = "src/regfile.spade:80,29" *)
    logic[3:0] __n1;
    (* src = "src/regfile.spade:64,25" *)
    logic[31:0] \rd1 ;
    (* src = "src/regfile.spade:83,5" *)
    logic[63:0] _e_7422;
    localparam[31:0] _e_7211 = 32'd0;
    localparam[3:0] _e_7213 = 0;
    (* src = "src/regfile.spade:26,43" *)
    \tta::regfile::write_mux  write_mux_0(.my_idx_i(_e_7213), .cur_i(\r0 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7212));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r0  <= _e_7211;
        end
        else begin
            \r0  <= _e_7212;
        end
    end
    localparam[31:0] _e_7220 = 32'd0;
    localparam[3:0] _e_7222 = 1;
    (* src = "src/regfile.spade:27,43" *)
    \tta::regfile::write_mux  write_mux_1(.my_idx_i(_e_7222), .cur_i(\r1 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7221));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r1  <= _e_7220;
        end
        else begin
            \r1  <= _e_7221;
        end
    end
    localparam[31:0] _e_7229 = 32'd0;
    localparam[3:0] _e_7231 = 2;
    (* src = "src/regfile.spade:28,43" *)
    \tta::regfile::write_mux  write_mux_2(.my_idx_i(_e_7231), .cur_i(\r2 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7230));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r2  <= _e_7229;
        end
        else begin
            \r2  <= _e_7230;
        end
    end
    localparam[31:0] _e_7238 = 32'd0;
    localparam[3:0] _e_7240 = 3;
    (* src = "src/regfile.spade:29,43" *)
    \tta::regfile::write_mux  write_mux_3(.my_idx_i(_e_7240), .cur_i(\r3 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7239));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r3  <= _e_7238;
        end
        else begin
            \r3  <= _e_7239;
        end
    end
    localparam[31:0] _e_7247 = 32'd0;
    localparam[3:0] _e_7249 = 4;
    (* src = "src/regfile.spade:30,43" *)
    \tta::regfile::write_mux  write_mux_4(.my_idx_i(_e_7249), .cur_i(\r4 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7248));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r4  <= _e_7247;
        end
        else begin
            \r4  <= _e_7248;
        end
    end
    localparam[31:0] _e_7256 = 32'd0;
    localparam[3:0] _e_7258 = 5;
    (* src = "src/regfile.spade:31,43" *)
    \tta::regfile::write_mux  write_mux_5(.my_idx_i(_e_7258), .cur_i(\r5 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7257));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r5  <= _e_7256;
        end
        else begin
            \r5  <= _e_7257;
        end
    end
    localparam[31:0] _e_7265 = 32'd0;
    localparam[3:0] _e_7267 = 6;
    (* src = "src/regfile.spade:32,43" *)
    \tta::regfile::write_mux  write_mux_6(.my_idx_i(_e_7267), .cur_i(\r6 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7266));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r6  <= _e_7265;
        end
        else begin
            \r6  <= _e_7266;
        end
    end
    localparam[31:0] _e_7274 = 32'd0;
    localparam[3:0] _e_7276 = 7;
    (* src = "src/regfile.spade:33,43" *)
    \tta::regfile::write_mux  write_mux_7(.my_idx_i(_e_7276), .cur_i(\r7 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7275));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r7  <= _e_7274;
        end
        else begin
            \r7  <= _e_7275;
        end
    end
    localparam[31:0] _e_7283 = 32'd0;
    localparam[3:0] _e_7285 = 8;
    (* src = "src/regfile.spade:35,43" *)
    \tta::regfile::write_mux  write_mux_8(.my_idx_i(_e_7285), .cur_i(\r8 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7284));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r8  <= _e_7283;
        end
        else begin
            \r8  <= _e_7284;
        end
    end
    localparam[31:0] _e_7292 = 32'd0;
    localparam[3:0] _e_7294 = 9;
    (* src = "src/regfile.spade:36,43" *)
    \tta::regfile::write_mux  write_mux_9(.my_idx_i(_e_7294), .cur_i(\r9 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7293));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r9  <= _e_7292;
        end
        else begin
            \r9  <= _e_7293;
        end
    end
    localparam[31:0] _e_7301 = 32'd0;
    localparam[3:0] _e_7303 = 10;
    (* src = "src/regfile.spade:37,44" *)
    \tta::regfile::write_mux  write_mux_10(.my_idx_i(_e_7303), .cur_i(\r10 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7302));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r10  <= _e_7301;
        end
        else begin
            \r10  <= _e_7302;
        end
    end
    localparam[31:0] _e_7310 = 32'd0;
    localparam[3:0] _e_7312 = 11;
    (* src = "src/regfile.spade:38,44" *)
    \tta::regfile::write_mux  write_mux_11(.my_idx_i(_e_7312), .cur_i(\r11 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7311));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r11  <= _e_7310;
        end
        else begin
            \r11  <= _e_7311;
        end
    end
    localparam[31:0] _e_7319 = 32'd0;
    localparam[3:0] _e_7321 = 12;
    (* src = "src/regfile.spade:39,44" *)
    \tta::regfile::write_mux  write_mux_12(.my_idx_i(_e_7321), .cur_i(\r12 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7320));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r12  <= _e_7319;
        end
        else begin
            \r12  <= _e_7320;
        end
    end
    localparam[31:0] _e_7328 = 32'd0;
    localparam[3:0] _e_7330 = 13;
    (* src = "src/regfile.spade:40,44" *)
    \tta::regfile::write_mux  write_mux_13(.my_idx_i(_e_7330), .cur_i(\r13 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7329));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r13  <= _e_7328;
        end
        else begin
            \r13  <= _e_7329;
        end
    end
    localparam[31:0] _e_7337 = 32'd0;
    localparam[3:0] _e_7339 = 14;
    (* src = "src/regfile.spade:41,44" *)
    \tta::regfile::write_mux  write_mux_14(.my_idx_i(_e_7339), .cur_i(\r14 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7338));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r14  <= _e_7337;
        end
        else begin
            \r14  <= _e_7338;
        end
    end
    localparam[31:0] _e_7346 = 32'd0;
    localparam[3:0] _e_7348 = 15;
    (* src = "src/regfile.spade:42,44" *)
    \tta::regfile::write_mux  write_mux_15(.my_idx_i(_e_7348), .cur_i(\r15 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7347));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r15  <= _e_7346;
        end
        else begin
            \r15  <= _e_7347;
        end
    end
    localparam[3:0] _e_10222 = 0;
    assign _e_10221 = \ra0  == _e_10222;
    localparam[3:0] _e_10224 = 1;
    assign _e_10223 = \ra0  == _e_10224;
    localparam[3:0] _e_10226 = 2;
    assign _e_10225 = \ra0  == _e_10226;
    localparam[3:0] _e_10228 = 3;
    assign _e_10227 = \ra0  == _e_10228;
    localparam[3:0] _e_10230 = 4;
    assign _e_10229 = \ra0  == _e_10230;
    localparam[3:0] _e_10232 = 5;
    assign _e_10231 = \ra0  == _e_10232;
    localparam[3:0] _e_10234 = 6;
    assign _e_10233 = \ra0  == _e_10234;
    localparam[3:0] _e_10236 = 7;
    assign _e_10235 = \ra0  == _e_10236;
    localparam[3:0] _e_10238 = 8;
    assign _e_10237 = \ra0  == _e_10238;
    localparam[3:0] _e_10240 = 9;
    assign _e_10239 = \ra0  == _e_10240;
    localparam[3:0] _e_10242 = 10;
    assign _e_10241 = \ra0  == _e_10242;
    localparam[3:0] _e_10244 = 11;
    assign _e_10243 = \ra0  == _e_10244;
    localparam[3:0] _e_10246 = 12;
    assign _e_10245 = \ra0  == _e_10246;
    localparam[3:0] _e_10248 = 13;
    assign _e_10247 = \ra0  == _e_10248;
    localparam[3:0] _e_10250 = 14;
    assign _e_10249 = \ra0  == _e_10250;
    assign \_  = \ra0 ;
    localparam[0:0] _e_10251 = 1;
    always_comb begin
        priority casez ({_e_10221, _e_10223, _e_10225, _e_10227, _e_10229, _e_10231, _e_10233, _e_10235, _e_10237, _e_10239, _e_10241, _e_10243, _e_10245, _e_10247, _e_10249, _e_10251})
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
    localparam[3:0] _e_10253 = 0;
    assign _e_10252 = \ra1  == _e_10253;
    localparam[3:0] _e_10255 = 1;
    assign _e_10254 = \ra1  == _e_10255;
    localparam[3:0] _e_10257 = 2;
    assign _e_10256 = \ra1  == _e_10257;
    localparam[3:0] _e_10259 = 3;
    assign _e_10258 = \ra1  == _e_10259;
    localparam[3:0] _e_10261 = 4;
    assign _e_10260 = \ra1  == _e_10261;
    localparam[3:0] _e_10263 = 5;
    assign _e_10262 = \ra1  == _e_10263;
    localparam[3:0] _e_10265 = 6;
    assign _e_10264 = \ra1  == _e_10265;
    localparam[3:0] _e_10267 = 7;
    assign _e_10266 = \ra1  == _e_10267;
    localparam[3:0] _e_10269 = 8;
    assign _e_10268 = \ra1  == _e_10269;
    localparam[3:0] _e_10271 = 9;
    assign _e_10270 = \ra1  == _e_10271;
    localparam[3:0] _e_10273 = 10;
    assign _e_10272 = \ra1  == _e_10273;
    localparam[3:0] _e_10275 = 11;
    assign _e_10274 = \ra1  == _e_10275;
    localparam[3:0] _e_10277 = 12;
    assign _e_10276 = \ra1  == _e_10277;
    localparam[3:0] _e_10279 = 13;
    assign _e_10278 = \ra1  == _e_10279;
    localparam[3:0] _e_10281 = 14;
    assign _e_10280 = \ra1  == _e_10281;
    assign __n1 = \ra1 ;
    localparam[0:0] _e_10282 = 1;
    always_comb begin
        priority casez ({_e_10252, _e_10254, _e_10256, _e_10258, _e_10260, _e_10262, _e_10264, _e_10266, _e_10268, _e_10270, _e_10272, _e_10274, _e_10276, _e_10278, _e_10280, _e_10282})
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
    assign _e_7422 = {\rd0 , \rd1 };
    assign output__ = _e_7422;
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
    (* src = "src/regfile.spade:89,9" *)
    logic[42:0] _e_7430;
    (* src = "src/regfile.spade:89,14" *)
    logic[3:0] \i ;
    (* src = "src/regfile.spade:89,14" *)
    logic[31:0] \x ;
    logic _e_10284;
    logic _e_10286;
    logic _e_10289;
    logic _e_10290;
    logic _e_10291;
    (* src = "src/regfile.spade:89,43" *)
    logic[35:0] _e_7433;
    (* src = "src/regfile.spade:89,38" *)
    logic[36:0] _e_7432;
    (* src = "src/regfile.spade:90,9" *)
    logic[43:0] \_ ;
    (* src = "src/regfile.spade:90,14" *)
    logic[36:0] _e_7437;
    (* src = "src/regfile.spade:88,5" *)
    logic[36:0] _e_7426;
    assign _e_7430 = \m [42:0];
    assign \i  = _e_7430[36:33];
    assign \x  = _e_7430[32:1];
    assign _e_10284 = \m [43] == 1'd1;
    assign _e_10286 = _e_7430[42:37] == 6'd0;
    localparam[0:0] _e_10287 = 1;
    localparam[0:0] _e_10288 = 1;
    assign _e_10289 = _e_10286 && _e_10287;
    assign _e_10290 = _e_10289 && _e_10288;
    assign _e_10291 = _e_10284 && _e_10290;
    assign _e_7433 = {\i , \x };
    assign _e_7432 = {1'd1, _e_7433};
    assign \_  = \m ;
    localparam[0:0] _e_10292 = 1;
    assign _e_7437 = {1'd0, 36'bX};
    always_comb begin
        priority casez ({_e_10291, _e_10292})
            2'b1?: _e_7426 = _e_7432;
            2'b01: _e_7426 = _e_7437;
            2'b?: _e_7426 = 37'dx;
        endcase
    end
    assign output__ = _e_7426;
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
    (* src = "src/regfile.spade:100,9" *)
    logic[35:0] _e_7443;
    (* src = "src/regfile.spade:100,14" *)
    logic[3:0] \idx ;
    (* src = "src/regfile.spade:100,14" *)
    logic[31:0] \v ;
    logic _e_10294;
    logic _e_10298;
    logic _e_10299;
    (* src = "src/regfile.spade:100,30" *)
    logic _e_7446;
    (* src = "src/regfile.spade:102,17" *)
    logic[35:0] _e_7456;
    (* src = "src/regfile.spade:102,22" *)
    logic[3:0] \idx0 ;
    (* src = "src/regfile.spade:102,22" *)
    logic[31:0] \v0 ;
    logic _e_10301;
    logic _e_10305;
    logic _e_10306;
    (* src = "src/regfile.spade:102,40" *)
    logic _e_7459;
    (* src = "src/regfile.spade:102,37" *)
    logic[31:0] _e_7458;
    logic _e_10308;
    (* src = "src/regfile.spade:101,13" *)
    logic[31:0] _e_7452;
    (* src = "src/regfile.spade:100,27" *)
    logic[31:0] _e_7445;
    logic _e_10310;
    (* src = "src/regfile.spade:107,13" *)
    logic[35:0] _e_7473;
    (* src = "src/regfile.spade:107,18" *)
    logic[3:0] idx0_n1;
    (* src = "src/regfile.spade:107,18" *)
    logic[31:0] v0_n1;
    logic _e_10312;
    logic _e_10316;
    logic _e_10317;
    (* src = "src/regfile.spade:107,36" *)
    logic _e_7476;
    (* src = "src/regfile.spade:107,33" *)
    logic[31:0] _e_7475;
    logic _e_10319;
    (* src = "src/regfile.spade:106,17" *)
    logic[31:0] _e_7469;
    (* src = "src/regfile.spade:99,5" *)
    logic[31:0] _e_7439;
    assign _e_7443 = \w1 [35:0];
    assign \idx  = _e_7443[35:32];
    assign \v  = _e_7443[31:0];
    assign _e_10294 = \w1 [36] == 1'd1;
    localparam[0:0] _e_10296 = 1;
    localparam[0:0] _e_10297 = 1;
    assign _e_10298 = _e_10296 && _e_10297;
    assign _e_10299 = _e_10294 && _e_10298;
    assign _e_7446 = \idx  == \my_idx ;
    assign _e_7456 = \w0 [35:0];
    assign \idx0  = _e_7456[35:32];
    assign \v0  = _e_7456[31:0];
    assign _e_10301 = \w0 [36] == 1'd1;
    localparam[0:0] _e_10303 = 1;
    localparam[0:0] _e_10304 = 1;
    assign _e_10305 = _e_10303 && _e_10304;
    assign _e_10306 = _e_10301 && _e_10305;
    assign _e_7459 = \idx0  == \my_idx ;
    assign _e_7458 = _e_7459 ? \v0  : \cur ;
    assign _e_10308 = \w0 [36] == 1'd0;
    always_comb begin
        priority casez ({_e_10306, _e_10308})
            2'b1?: _e_7452 = _e_7458;
            2'b01: _e_7452 = \cur ;
            2'b?: _e_7452 = 32'dx;
        endcase
    end
    assign _e_7445 = _e_7446 ? \v  : _e_7452;
    assign _e_10310 = \w1 [36] == 1'd0;
    assign _e_7473 = \w0 [35:0];
    assign idx0_n1 = _e_7473[35:32];
    assign v0_n1 = _e_7473[31:0];
    assign _e_10312 = \w0 [36] == 1'd1;
    localparam[0:0] _e_10314 = 1;
    localparam[0:0] _e_10315 = 1;
    assign _e_10316 = _e_10314 && _e_10315;
    assign _e_10317 = _e_10312 && _e_10316;
    assign _e_7476 = idx0_n1 == \my_idx ;
    assign _e_7475 = _e_7476 ? v0_n1 : \cur ;
    assign _e_10319 = \w0 [36] == 1'd0;
    always_comb begin
        priority casez ({_e_10317, _e_10319})
            2'b1?: _e_7469 = _e_7475;
            2'b01: _e_7469 = \cur ;
            2'b?: _e_7469 = 32'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10299, _e_10310})
            2'b1?: _e_7439 = _e_7445;
            2'b01: _e_7439 = _e_7469;
            2'b?: _e_7439 = 32'dx;
        endcase
    end
    assign output__ = _e_7439;
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
    logic[31:0] _e_7489;
    (* src = "src/xorshift.spade:17,18" *)
    logic[31:0] _e_7488;
    (* src = "src/xorshift.spade:17,14" *)
    logic[31:0] \x1 ;
    (* src = "src/xorshift.spade:18,19" *)
    logic[31:0] _e_7495;
    (* src = "src/xorshift.spade:18,14" *)
    logic[31:0] \x2 ;
    (* src = "src/xorshift.spade:19,25" *)
    logic[31:0] _e_7502;
    (* src = "src/xorshift.spade:19,19" *)
    logic[31:0] _e_7501;
    (* src = "src/xorshift.spade:19,14" *)
    logic[31:0] \x3 ;
    localparam[31:0] _e_7491 = 32'd13;
    assign _e_7489 = \x  << _e_7491;
    assign _e_7488 = _e_7489[31:0];
    assign \x1  = \x  ^ _e_7488;
    localparam[31:0] _e_7497 = 32'd17;
    assign _e_7495 = \x1  >> _e_7497;
    assign \x2  = \x1  ^ _e_7495;
    localparam[31:0] _e_7504 = 32'd5;
    assign _e_7502 = \x2  << _e_7504;
    assign _e_7501 = _e_7502[31:0];
    assign \x3  = \x2  ^ _e_7501;
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
    logic _e_10321;
    logic _e_10323;
    (* src = "src/xorshift.spade:32,27" *)
    logic _e_7518;
    (* src = "src/xorshift.spade:32,24" *)
    logic[31:0] _e_7517;
    logic _e_10325;
    (* src = "src/xorshift.spade:31,20" *)
    logic[31:0] \base ;
    (* src = "src/xorshift.spade:37,9" *)
    logic[31:0] _e_7528;
    (* src = "src/xorshift.spade:29,14" *)
    reg[31:0] \state ;
    (* src = "src/xorshift.spade:42,47" *)
    logic[32:0] _e_7533;
    (* src = "src/xorshift.spade:44,13" *)
    logic[31:0] v_n1;
    logic _e_10327;
    logic _e_10329;
    (* src = "src/xorshift.spade:44,27" *)
    logic _e_7540;
    (* src = "src/xorshift.spade:44,24" *)
    logic[31:0] _e_7539;
    logic _e_10331;
    (* src = "src/xorshift.spade:43,20" *)
    logic[31:0] base_n1;
    (* src = "src/xorshift.spade:47,14" *)
    logic[31:0] _e_7551;
    (* src = "src/xorshift.spade:47,9" *)
    logic[32:0] _e_7550;
    (* src = "src/xorshift.spade:42,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_7511 = 32'd1;
    assign \v  = \trig [31:0];
    assign _e_10321 = \trig [32] == 1'd1;
    localparam[0:0] _e_10322 = 1;
    assign _e_10323 = _e_10321 && _e_10322;
    localparam[31:0] _e_7520 = 32'd0;
    assign _e_7518 = \v  == _e_7520;
    assign _e_7517 = _e_7518 ? \state  : \v ;
    assign _e_10325 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_10323, _e_10325})
            2'b1?: \base  = _e_7517;
            2'b01: \base  = \state ;
            2'b?: \base  = 32'dx;
        endcase
    end
    (* src = "src/xorshift.spade:37,9" *)
    \tta::xorshift::next_xorshift32  next_xorshift32_0(.x_i(\base ), .output__(_e_7528));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \state  <= _e_7511;
        end
        else begin
            \state  <= _e_7528;
        end
    end
    assign _e_7533 = {1'd0, 32'bX};
    assign v_n1 = \trig [31:0];
    assign _e_10327 = \trig [32] == 1'd1;
    localparam[0:0] _e_10328 = 1;
    assign _e_10329 = _e_10327 && _e_10328;
    localparam[31:0] _e_7542 = 32'd0;
    assign _e_7540 = v_n1 == _e_7542;
    assign _e_7539 = _e_7540 ? \state  : v_n1;
    assign _e_10331 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_10329, _e_10331})
            2'b1?: base_n1 = _e_7539;
            2'b01: base_n1 = \state ;
            2'b?: base_n1 = 32'dx;
        endcase
    end
    (* src = "src/xorshift.spade:47,14" *)
    \tta::xorshift::next_xorshift32  next_xorshift32_1(.x_i(base_n1), .output__(_e_7551));
    assign _e_7550 = {1'd1, _e_7551};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_7533;
        end
        else begin
            \res  <= _e_7550;
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
    (* src = "src/xorshift.spade:55,9" *)
    logic[42:0] _e_7558;
    (* src = "src/xorshift.spade:55,14" *)
    logic[31:0] \x ;
    logic _e_10333;
    logic _e_10335;
    logic _e_10337;
    logic _e_10338;
    (* src = "src/xorshift.spade:55,40" *)
    logic[32:0] _e_7560;
    (* src = "src/xorshift.spade:56,9" *)
    logic[43:0] \_ ;
    (* src = "src/xorshift.spade:57,13" *)
    logic[42:0] _e_7566;
    (* src = "src/xorshift.spade:57,18" *)
    logic[31:0] x_n1;
    logic _e_10341;
    logic _e_10343;
    logic _e_10345;
    logic _e_10346;
    (* src = "src/xorshift.spade:57,44" *)
    logic[32:0] _e_7568;
    (* src = "src/xorshift.spade:58,13" *)
    logic[43:0] __n1;
    (* src = "src/xorshift.spade:58,18" *)
    logic[32:0] _e_7571;
    (* src = "src/xorshift.spade:56,14" *)
    logic[32:0] _e_7563;
    (* src = "src/xorshift.spade:54,5" *)
    logic[32:0] _e_7555;
    assign _e_7558 = \m1 [42:0];
    assign \x  = _e_7558[36:5];
    assign _e_10333 = \m1 [43] == 1'd1;
    assign _e_10335 = _e_7558[42:37] == 6'd23;
    localparam[0:0] _e_10336 = 1;
    assign _e_10337 = _e_10335 && _e_10336;
    assign _e_10338 = _e_10333 && _e_10337;
    assign _e_7560 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10339 = 1;
    assign _e_7566 = \m0 [42:0];
    assign x_n1 = _e_7566[36:5];
    assign _e_10341 = \m0 [43] == 1'd1;
    assign _e_10343 = _e_7566[42:37] == 6'd23;
    localparam[0:0] _e_10344 = 1;
    assign _e_10345 = _e_10343 && _e_10344;
    assign _e_10346 = _e_10341 && _e_10345;
    assign _e_7568 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10347 = 1;
    assign _e_7571 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10346, _e_10347})
            2'b1?: _e_7563 = _e_7568;
            2'b01: _e_7563 = _e_7571;
            2'b?: _e_7563 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10338, _e_10339})
            2'b1?: _e_7555 = _e_7560;
            2'b01: _e_7555 = _e_7563;
            2'b?: _e_7555 = 33'dx;
        endcase
    end
    assign output__ = _e_7555;
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
    (* src = "src/bt.spade:12,50" *)
    logic[10:0] _e_7576;
    (* src = "src/bt.spade:13,9" *)
    logic[9:0] \v ;
    logic _e_10349;
    logic _e_10351;
    (* src = "src/bt.spade:13,20" *)
    logic[10:0] _e_7581;
    logic _e_10353;
    (* src = "src/bt.spade:12,58" *)
    logic[10:0] _e_7577;
    (* src = "src/bt.spade:12,14" *)
    reg[10:0] \target ;
    (* src = "src/bt.spade:16,11" *)
    logic[43:0] _e_7586;
    (* src = "src/bt.spade:17,9" *)
    logic[43:0] _e_7593;
    (* src = "src/bt.spade:17,9" *)
    logic[10:0] _e_7590;
    (* src = "src/bt.spade:17,10" *)
    logic[9:0] v_n1;
    (* src = "src/bt.spade:17,9" *)
    logic[32:0] _e_7592;
    (* src = "src/bt.spade:17,19" *)
    logic[31:0] \c ;
    logic _e_10356;
    logic _e_10358;
    logic _e_10360;
    logic _e_10362;
    logic _e_10363;
    (* src = "src/bt.spade:18,16" *)
    logic _e_7596;
    (* src = "src/bt.spade:18,29" *)
    logic[10:0] _e_7599;
    (* src = "src/bt.spade:18,46" *)
    logic[10:0] _e_7602;
    (* src = "src/bt.spade:18,13" *)
    logic[10:0] _e_7595;
    (* src = "src/bt.spade:20,9" *)
    logic[43:0] _e_7605;
    (* src = "src/bt.spade:20,9" *)
    logic[10:0] \_ ;
    (* src = "src/bt.spade:20,9" *)
    logic[32:0] __n1;
    logic _e_10367;
    (* src = "src/bt.spade:20,19" *)
    logic[10:0] _e_7606;
    (* src = "src/bt.spade:16,5" *)
    logic[10:0] _e_7585;
    assign _e_7576 = {1'd0, 10'bX};
    assign \v  = \jump_to [9:0];
    assign _e_10349 = \jump_to [10] == 1'd1;
    localparam[0:0] _e_10350 = 1;
    assign _e_10351 = _e_10349 && _e_10350;
    assign _e_7581 = {1'd1, \v };
    assign _e_10353 = \jump_to [10] == 1'd0;
    always_comb begin
        priority casez ({_e_10351, _e_10353})
            2'b1?: _e_7577 = _e_7581;
            2'b01: _e_7577 = \target ;
            2'b?: _e_7577 = 11'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \target  <= _e_7576;
        end
        else begin
            \target  <= _e_7577;
        end
    end
    assign _e_7586 = {\target , \condition_trig };
    assign _e_7593 = _e_7586;
    assign _e_7590 = _e_7586[43:33];
    assign v_n1 = _e_7590[9:0];
    assign _e_7592 = _e_7586[32:0];
    assign \c  = _e_7592[31:0];
    assign _e_10356 = _e_7590[10] == 1'd1;
    localparam[0:0] _e_10357 = 1;
    assign _e_10358 = _e_10356 && _e_10357;
    assign _e_10360 = _e_7592[32] == 1'd1;
    localparam[0:0] _e_10361 = 1;
    assign _e_10362 = _e_10360 && _e_10361;
    assign _e_10363 = _e_10358 && _e_10362;
    (* src = "src/bt.spade:18,16" *)
    \tta::bt::to_bool  to_bool_0(.x_i(\c ), .output__(_e_7596));
    assign _e_7599 = {1'd1, v_n1};
    assign _e_7602 = {1'd0, 10'bX};
    assign _e_7595 = _e_7596 ? _e_7599 : _e_7602;
    assign _e_7605 = _e_7586;
    assign \_  = _e_7586[43:33];
    assign __n1 = _e_7586[32:0];
    localparam[0:0] _e_10365 = 1;
    localparam[0:0] _e_10366 = 1;
    assign _e_10367 = _e_10365 && _e_10366;
    assign _e_7606 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_10363, _e_10367})
            2'b1?: _e_7585 = _e_7595;
            2'b01: _e_7585 = _e_7606;
            2'b?: _e_7585 = 11'dx;
        endcase
    end
    assign output__ = _e_7585;
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
    (* src = "src/bt.spade:26,8" *)
    logic _e_7609;
    (* src = "src/bt.spade:26,5" *)
    logic _e_7608;
    localparam[31:0] _e_7611 = 32'd0;
    assign _e_7609 = \x  == _e_7611;
    localparam[0:0] _e_7613 = 0;
    localparam[0:0] _e_7615 = 1;
    assign _e_7608 = _e_7609 ? _e_7613 : _e_7615;
    assign output__ = _e_7608;
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
    (* src = "src/bt.spade:37,9" *)
    logic[42:0] _e_7620;
    (* src = "src/bt.spade:37,14" *)
    logic[9:0] \a ;
    logic _e_10369;
    logic _e_10371;
    logic _e_10373;
    logic _e_10374;
    (* src = "src/bt.spade:37,36" *)
    logic[10:0] _e_7622;
    (* src = "src/bt.spade:38,9" *)
    logic[43:0] \_ ;
    (* src = "src/bt.spade:38,25" *)
    logic[42:0] _e_7628;
    (* src = "src/bt.spade:38,30" *)
    logic[9:0] a_n1;
    logic _e_10377;
    logic _e_10379;
    logic _e_10381;
    logic _e_10382;
    (* src = "src/bt.spade:38,52" *)
    logic[10:0] _e_7630;
    (* src = "src/bt.spade:38,61" *)
    logic[43:0] __n1;
    (* src = "src/bt.spade:38,66" *)
    logic[10:0] _e_7633;
    (* src = "src/bt.spade:38,14" *)
    logic[10:0] _e_7625;
    (* src = "src/bt.spade:36,5" *)
    logic[10:0] _e_7617;
    assign _e_7620 = \m1 [42:0];
    assign \a  = _e_7620[36:27];
    assign _e_10369 = \m1 [43] == 1'd1;
    assign _e_10371 = _e_7620[42:37] == 6'd18;
    localparam[0:0] _e_10372 = 1;
    assign _e_10373 = _e_10371 && _e_10372;
    assign _e_10374 = _e_10369 && _e_10373;
    assign _e_7622 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_10375 = 1;
    assign _e_7628 = \m0 [42:0];
    assign a_n1 = _e_7628[36:27];
    assign _e_10377 = \m0 [43] == 1'd1;
    assign _e_10379 = _e_7628[42:37] == 6'd18;
    localparam[0:0] _e_10380 = 1;
    assign _e_10381 = _e_10379 && _e_10380;
    assign _e_10382 = _e_10377 && _e_10381;
    assign _e_7630 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10383 = 1;
    assign _e_7633 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_10382, _e_10383})
            2'b1?: _e_7625 = _e_7630;
            2'b01: _e_7625 = _e_7633;
            2'b?: _e_7625 = 11'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10374, _e_10375})
            2'b1?: _e_7617 = _e_7622;
            2'b01: _e_7617 = _e_7625;
            2'b?: _e_7617 = 11'dx;
        endcase
    end
    assign output__ = _e_7617;
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
    (* src = "src/bt.spade:44,9" *)
    logic[42:0] _e_7638;
    (* src = "src/bt.spade:44,14" *)
    logic[31:0] \a ;
    logic _e_10385;
    logic _e_10387;
    logic _e_10389;
    logic _e_10390;
    (* src = "src/bt.spade:44,34" *)
    logic[32:0] _e_7640;
    (* src = "src/bt.spade:45,9" *)
    logic[43:0] \_ ;
    (* src = "src/bt.spade:45,25" *)
    logic[42:0] _e_7646;
    (* src = "src/bt.spade:45,30" *)
    logic[31:0] a_n1;
    logic _e_10393;
    logic _e_10395;
    logic _e_10397;
    logic _e_10398;
    (* src = "src/bt.spade:45,50" *)
    logic[32:0] _e_7648;
    (* src = "src/bt.spade:45,59" *)
    logic[43:0] __n1;
    (* src = "src/bt.spade:45,64" *)
    logic[32:0] _e_7651;
    (* src = "src/bt.spade:45,14" *)
    logic[32:0] _e_7643;
    (* src = "src/bt.spade:43,5" *)
    logic[32:0] _e_7635;
    assign _e_7638 = \m1 [42:0];
    assign \a  = _e_7638[36:5];
    assign _e_10385 = \m1 [43] == 1'd1;
    assign _e_10387 = _e_7638[42:37] == 6'd19;
    localparam[0:0] _e_10388 = 1;
    assign _e_10389 = _e_10387 && _e_10388;
    assign _e_10390 = _e_10385 && _e_10389;
    assign _e_7640 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_10391 = 1;
    assign _e_7646 = \m0 [42:0];
    assign a_n1 = _e_7646[36:5];
    assign _e_10393 = \m0 [43] == 1'd1;
    assign _e_10395 = _e_7646[42:37] == 6'd19;
    localparam[0:0] _e_10396 = 1;
    assign _e_10397 = _e_10395 && _e_10396;
    assign _e_10398 = _e_10393 && _e_10397;
    assign _e_7648 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10399 = 1;
    assign _e_7651 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10398, _e_10399})
            2'b1?: _e_7643 = _e_7648;
            2'b01: _e_7643 = _e_7651;
            2'b?: _e_7643 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10390, _e_10391})
            2'b1?: _e_7635 = _e_7640;
            2'b01: _e_7635 = _e_7643;
            2'b?: _e_7635 = 33'dx;
        endcase
    end
    assign output__ = _e_7635;
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
    (* src = "src/stack_lsu.spade:19,13" *)
    logic[31:0] \val ;
    logic _e_10401;
    logic _e_10403;
    logic _e_10405;
    (* src = "src/stack_lsu.spade:21,38" *)
    logic[31:0] \_ ;
    logic _e_10407;
    logic _e_10409;
    logic _e_10411;
    (* src = "src/stack_lsu.spade:21,20" *)
    logic _e_7666;
    (* src = "src/stack_lsu.spade:22,27" *)
    logic[32:0] _e_7675;
    (* src = "src/stack_lsu.spade:22,21" *)
    logic[31:0] _e_7674;
    (* src = "src/stack_lsu.spade:24,27" *)
    logic[32:0] _e_7682;
    (* src = "src/stack_lsu.spade:24,21" *)
    logic[31:0] _e_7681;
    (* src = "src/stack_lsu.spade:23,24" *)
    logic[31:0] _e_7678;
    (* src = "src/stack_lsu.spade:21,17" *)
    logic[31:0] _e_7665;
    (* src = "src/stack_lsu.spade:18,9" *)
    logic[31:0] _e_7658;
    (* src = "src/stack_lsu.spade:17,14" *)
    reg[31:0] \sp ;
    (* src = "src/stack_lsu.spade:34,9" *)
    logic[31:0] val_n1;
    logic _e_10413;
    logic _e_10415;
    (* src = "src/stack_lsu.spade:35,43" *)
    logic[32:0] _e_7693;
    (* src = "src/stack_lsu.spade:35,37" *)
    logic[7:0] \trunc_sp ;
    (* src = "src/stack_lsu.spade:36,13" *)
    logic[40:0] _e_7697;
    logic _e_10417;
    (* src = "src/stack_lsu.spade:40,43" *)
    logic[32:0] _e_7704;
    (* src = "src/stack_lsu.spade:40,37" *)
    logic[7:0] trunc_sp_n1;
    (* src = "src/stack_lsu.spade:41,13" *)
    logic[40:0] _e_7708;
    (* src = "src/stack_lsu.spade:33,31" *)
    logic[40:0] _e_7715;
    (* src = "src/stack_lsu.spade:33,9" *)
    logic[7:0] \addr ;
    (* src = "src/stack_lsu.spade:33,9" *)
    logic \wren ;
    (* src = "src/stack_lsu.spade:33,9" *)
    logic[31:0] \wdata ;
    (* src = "src/stack_lsu.spade:46,17" *)
    logic[31:0] \rdata ;
    (* src = "src/stack_lsu.spade:50,9" *)
    logic[31:0] __n1;
    logic _e_10419;
    logic _e_10421;
    logic _e_10423;
    (* src = "src/stack_lsu.spade:49,62" *)
    logic _e_7729;
    (* src = "src/stack_lsu.spade:49,50" *)
    logic _e_7727;
    (* src = "src/stack_lsu.spade:49,14" *)
    reg \pop_valid ;
    (* src = "src/stack_lsu.spade:54,20" *)
    logic[32:0] _e_7739;
    (* src = "src/stack_lsu.spade:54,41" *)
    logic[32:0] _e_7742;
    (* src = "src/stack_lsu.spade:54,5" *)
    logic[32:0] _e_7736;
    localparam[31:0] _e_7656 = 32'd0;
    assign \val  = \set_sp [31:0];
    assign _e_10401 = \set_sp [32] == 1'd1;
    localparam[0:0] _e_10402 = 1;
    assign _e_10403 = _e_10401 && _e_10402;
    assign _e_10405 = \set_sp [32] == 1'd0;
    assign \_  = \push_trig [31:0];
    assign _e_10407 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10408 = 1;
    assign _e_10409 = _e_10407 && _e_10408;
    localparam[0:0] _e_7670 = 1;
    assign _e_10411 = \push_trig [32] == 1'd0;
    localparam[0:0] _e_7672 = 0;
    always_comb begin
        priority casez ({_e_10409, _e_10411})
            2'b1?: _e_7666 = _e_7670;
            2'b01: _e_7666 = _e_7672;
            2'b?: _e_7666 = 1'dx;
        endcase
    end
    localparam[31:0] _e_7677 = 32'd1;
    assign _e_7675 = \sp  - _e_7677;
    assign _e_7674 = _e_7675[31:0];
    localparam[31:0] _e_7684 = 32'd1;
    assign _e_7682 = \sp  + _e_7684;
    assign _e_7681 = _e_7682[31:0];
    assign _e_7678 = \pop_trig  ? _e_7681 : \sp ;
    assign _e_7665 = _e_7666 ? _e_7674 : _e_7678;
    always_comb begin
        priority casez ({_e_10403, _e_10405})
            2'b1?: _e_7658 = \val ;
            2'b01: _e_7658 = _e_7665;
            2'b?: _e_7658 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \sp  <= _e_7656;
        end
        else begin
            \sp  <= _e_7658;
        end
    end
    assign val_n1 = \push_trig [31:0];
    assign _e_10413 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10414 = 1;
    assign _e_10415 = _e_10413 && _e_10414;
    localparam[31:0] _e_7695 = 32'd1;
    assign _e_7693 = \sp  - _e_7695;
    assign \trunc_sp  = _e_7693[7:0];
    localparam[0:0] _e_7699 = 1;
    assign _e_7697 = {\trunc_sp , _e_7699, val_n1};
    assign _e_10417 = \push_trig [32] == 1'd0;
    localparam[31:0] _e_7706 = 32'd1;
    assign _e_7704 = \sp  - _e_7706;
    assign trunc_sp_n1 = _e_7704[7:0];
    localparam[0:0] _e_7710 = 0;
    localparam[31:0] _e_7711 = 32'd0;
    assign _e_7708 = {trunc_sp_n1, _e_7710, _e_7711};
    always_comb begin
        priority casez ({_e_10415, _e_10417})
            2'b1?: _e_7715 = _e_7697;
            2'b01: _e_7715 = _e_7708;
            2'b?: _e_7715 = 41'dx;
        endcase
    end
    assign \addr  = _e_7715[40:33];
    assign \wren  = _e_7715[32];
    assign \wdata  = _e_7715[31:0];
    (* src = "src/stack_lsu.spade:46,17" *)
    \tta::sram::stack_ram_256x32  stack_ram_256x32_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif.clk_i(\clk ), .rst_i(\rst ), .word_idx_i(\addr ), .we_i(\wren ), .wdata_i(\wdata ), .output__(\rdata ));
    localparam[0:0] _e_7726 = 0;
    assign __n1 = \push_trig [31:0];
    assign _e_10419 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10420 = 1;
    assign _e_10421 = _e_10419 && _e_10420;
    localparam[0:0] _e_7733 = 0;
    assign _e_10423 = \push_trig [32] == 1'd0;
    localparam[0:0] _e_7735 = 1;
    always_comb begin
        priority casez ({_e_10421, _e_10423})
            2'b1?: _e_7729 = _e_7733;
            2'b01: _e_7729 = _e_7735;
            2'b?: _e_7729 = 1'dx;
        endcase
    end
    assign _e_7727 = \pop_trig  && _e_7729;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \pop_valid  <= _e_7726;
        end
        else begin
            \pop_valid  <= _e_7727;
        end
    end
    assign _e_7739 = {1'd1, \rdata };
    assign _e_7742 = {1'd0, 32'bX};
    assign _e_7736 = \pop_valid  ? _e_7739 : _e_7742;
    assign output__ = _e_7736;
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
    (* src = "src/stack_lsu.spade:59,9" *)
    logic[42:0] _e_7747;
    (* src = "src/stack_lsu.spade:59,14" *)
    logic[31:0] \x ;
    logic _e_10425;
    logic _e_10427;
    logic _e_10429;
    logic _e_10430;
    (* src = "src/stack_lsu.spade:59,37" *)
    logic[32:0] _e_7749;
    (* src = "src/stack_lsu.spade:60,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:61,13" *)
    logic[42:0] _e_7755;
    (* src = "src/stack_lsu.spade:61,18" *)
    logic[31:0] x_n1;
    logic _e_10433;
    logic _e_10435;
    logic _e_10437;
    logic _e_10438;
    (* src = "src/stack_lsu.spade:61,41" *)
    logic[32:0] _e_7757;
    (* src = "src/stack_lsu.spade:62,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:62,18" *)
    logic[32:0] _e_7760;
    (* src = "src/stack_lsu.spade:60,14" *)
    logic[32:0] _e_7752;
    (* src = "src/stack_lsu.spade:58,5" *)
    logic[32:0] _e_7744;
    assign _e_7747 = \m1 [42:0];
    assign \x  = _e_7747[36:5];
    assign _e_10425 = \m1 [43] == 1'd1;
    assign _e_10427 = _e_7747[42:37] == 6'd35;
    localparam[0:0] _e_10428 = 1;
    assign _e_10429 = _e_10427 && _e_10428;
    assign _e_10430 = _e_10425 && _e_10429;
    assign _e_7749 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10431 = 1;
    assign _e_7755 = \m0 [42:0];
    assign x_n1 = _e_7755[36:5];
    assign _e_10433 = \m0 [43] == 1'd1;
    assign _e_10435 = _e_7755[42:37] == 6'd35;
    localparam[0:0] _e_10436 = 1;
    assign _e_10437 = _e_10435 && _e_10436;
    assign _e_10438 = _e_10433 && _e_10437;
    assign _e_7757 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10439 = 1;
    assign _e_7760 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10438, _e_10439})
            2'b1?: _e_7752 = _e_7757;
            2'b01: _e_7752 = _e_7760;
            2'b?: _e_7752 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10430, _e_10431})
            2'b1?: _e_7744 = _e_7749;
            2'b01: _e_7744 = _e_7752;
            2'b?: _e_7744 = 33'dx;
        endcase
    end
    assign output__ = _e_7744;
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
    (* src = "src/stack_lsu.spade:69,9" *)
    logic[42:0] _e_7765;
    (* src = "src/stack_lsu.spade:69,14" *)
    logic[31:0] \x ;
    logic _e_10441;
    logic _e_10443;
    logic _e_10445;
    logic _e_10446;
    (* src = "src/stack_lsu.spade:69,42" *)
    logic[32:0] _e_7767;
    (* src = "src/stack_lsu.spade:70,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:71,13" *)
    logic[42:0] _e_7773;
    (* src = "src/stack_lsu.spade:71,18" *)
    logic[31:0] x_n1;
    logic _e_10449;
    logic _e_10451;
    logic _e_10453;
    logic _e_10454;
    (* src = "src/stack_lsu.spade:71,46" *)
    logic[32:0] _e_7775;
    (* src = "src/stack_lsu.spade:72,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:72,18" *)
    logic[32:0] _e_7778;
    (* src = "src/stack_lsu.spade:70,14" *)
    logic[32:0] _e_7770;
    (* src = "src/stack_lsu.spade:68,5" *)
    logic[32:0] _e_7762;
    assign _e_7765 = \m1 [42:0];
    assign \x  = _e_7765[36:5];
    assign _e_10441 = \m1 [43] == 1'd1;
    assign _e_10443 = _e_7765[42:37] == 6'd36;
    localparam[0:0] _e_10444 = 1;
    assign _e_10445 = _e_10443 && _e_10444;
    assign _e_10446 = _e_10441 && _e_10445;
    assign _e_7767 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10447 = 1;
    assign _e_7773 = \m0 [42:0];
    assign x_n1 = _e_7773[36:5];
    assign _e_10449 = \m0 [43] == 1'd1;
    assign _e_10451 = _e_7773[42:37] == 6'd36;
    localparam[0:0] _e_10452 = 1;
    assign _e_10453 = _e_10451 && _e_10452;
    assign _e_10454 = _e_10449 && _e_10453;
    assign _e_7775 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10455 = 1;
    assign _e_7778 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10454, _e_10455})
            2'b1?: _e_7770 = _e_7775;
            2'b01: _e_7770 = _e_7778;
            2'b?: _e_7770 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10446, _e_10447})
            2'b1?: _e_7762 = _e_7767;
            2'b01: _e_7762 = _e_7770;
            2'b?: _e_7762 = 33'dx;
        endcase
    end
    assign output__ = _e_7762;
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
    (* src = "src/stack_lsu.spade:79,9" *)
    logic[42:0] _e_7782;
    logic _e_10457;
    logic _e_10459;
    logic _e_10460;
    (* src = "src/stack_lsu.spade:80,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:81,13" *)
    logic[42:0] _e_7788;
    logic _e_10463;
    logic _e_10465;
    logic _e_10466;
    (* src = "src/stack_lsu.spade:82,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:80,14" *)
    logic _e_7786;
    (* src = "src/stack_lsu.spade:78,5" *)
    logic _e_7780;
    assign _e_7782 = \m1 [42:0];
    assign _e_10457 = \m1 [43] == 1'd1;
    assign _e_10459 = _e_7782[42:37] == 6'd37;
    assign _e_10460 = _e_10457 && _e_10459;
    localparam[0:0] _e_7784 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_10461 = 1;
    assign _e_7788 = \m0 [42:0];
    assign _e_10463 = \m0 [43] == 1'd1;
    assign _e_10465 = _e_7788[42:37] == 6'd37;
    assign _e_10466 = _e_10463 && _e_10465;
    localparam[0:0] _e_7790 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_10467 = 1;
    localparam[0:0] _e_7792 = 0;
    always_comb begin
        priority casez ({_e_10466, _e_10467})
            2'b1?: _e_7786 = _e_7790;
            2'b01: _e_7786 = _e_7792;
            2'b?: _e_7786 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10460, _e_10461})
            2'b1?: _e_7780 = _e_7784;
            2'b01: _e_7780 = _e_7786;
            2'b?: _e_7780 = 1'dx;
        endcase
    end
    assign output__ = _e_7780;
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
    \std::conv::flip_array[2140]  flip_array_0(.in_i(_e_529), .output__(_e_528));
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
    \std::conv::flip_array[2141]  flip_array_0(.in_i(_e_545), .output__(_e_544));
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
    \std::conv::flip_array[2142]  flip_array_0(.in_i(_e_565), .output__(_e_564));
    assign output__ = _e_564;
endmodule

module \std::cdc::sync2[2136]  (
        input clk_i,
        input in_i,
        output output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::cdc::sync2[2136]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::cdc::sync2[2136] );
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

module \std::conv::impl_4::to_int[2137]  (
        input[31:0] self_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_4::to_int[2137]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_4::to_int[2137] );
        end
    end
    `endif
    logic[31:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    logic[31:0] _e_514;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    \std::conv::uint_to_int[2143]  uint_to_int_0(.input_i(\self ), .output__(_e_514));
    assign output__ = _e_514;
endmodule

module \std::conv::impl_3::to_uint[2138]  (
        input[31:0] self_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_3::to_uint[2138]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_3::to_uint[2138] );
        end
    end
    `endif
    logic[31:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:153,9" *)
    logic[31:0] _e_508;
    (* src = "<compiler dir>/stdlib/conv.spade:153,9" *)
    \std::conv::int_to_uint[2144]  int_to_uint_0(.input_i(\self ), .output__(_e_508));
    assign output__ = _e_508;
endmodule

module \std::conv::impl_4::to_int[2139]  (
        input[15:0] self_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::impl_4::to_int[2139]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::impl_4::to_int[2139] );
        end
    end
    `endif
    logic[15:0] \self ;
    assign \self  = self_i;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    logic[15:0] _e_514;
    (* src = "<compiler dir>/stdlib/conv.spade:167,9" *)
    \std::conv::uint_to_int[2145]  uint_to_int_0(.input_i(\self ), .output__(_e_514));
    assign output__ = _e_514;
endmodule

module \std::conv::flip_array[2140]  (
        input[15:0] in_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2140]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2140] );
        end
    end
    `endif
    logic[15:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[15:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2146]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::flip_array[2141]  (
        input[23:0] in_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2141]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2141] );
        end
    end
    `endif
    logic[23:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[23:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2147]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::flip_array[2142]  (
        input[31:0] in_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2142]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2142] );
        end
    end
    `endif
    logic[31:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[31:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2148]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::uint_to_int[2143]  (
        input[31:0] input_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::uint_to_int[2143]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::uint_to_int[2143] );
        end
    end
    `endif
    logic[31:0] \input ;
    assign \input  = input_i;
    logic[31:0] _e_479;
    assign _e_479 = \input ;
    assign output__ = _e_479;
endmodule

module \std::conv::int_to_uint[2144]  (
        input[31:0] input_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::int_to_uint[2144]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::int_to_uint[2144] );
        end
    end
    `endif
    logic[31:0] \input ;
    assign \input  = input_i;
    logic[31:0] _e_483;
    assign _e_483 = \input ;
    assign output__ = _e_483;
endmodule

module \std::conv::uint_to_int[2145]  (
        input[15:0] input_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::uint_to_int[2145]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::uint_to_int[2145] );
        end
    end
    `endif
    logic[15:0] \input ;
    assign \input  = input_i;
    logic[15:0] _e_479;
    assign _e_479 = \input ;
    assign output__ = _e_479;
endmodule

module \std::conv::std::conv::flip_array::F[2146]  (
        input[15:0] in_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2146]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2146] );
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
    \std::conv::flip_array[2149]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2150]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::std::conv::flip_array::F[2147]  (
        input[23:0] in_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2147]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2147] );
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
    \std::conv::flip_array[2140]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2151]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::std::conv::flip_array::F[2148]  (
        input[31:0] in_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2148]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2148] );
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
    \std::conv::flip_array[2141]  flip_array_0(.in_i(_e_446), .output__(_e_445));
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2152]  concat_arrays_0(.l_i(_e_441), .r_i(_e_445), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::flip_array[2149]  (
        input[7:0] in_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2149]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2149] );
        end
    end
    `endif
    logic[7:0] \in ;
    assign \in  = in_i;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    logic[7:0] \result ;
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::F[2153]  F_0(.in_i(\in ), .output__(\result ));
    assign output__ = \result ;
endmodule

module \std::conv::concat_arrays[2150]  (
        input[7:0] l_i,
        input[7:0] r_i,
        output[15:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2150]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2150] );
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

module \std::conv::concat_arrays[2151]  (
        input[7:0] l_i,
        input[15:0] r_i,
        output[23:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2151]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2151] );
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

module \std::conv::concat_arrays[2152]  (
        input[7:0] l_i,
        input[23:0] r_i,
        output[31:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2152]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2152] );
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

module \std::conv::std::conv::flip_array::F[2153]  (
        input[7:0] in_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::F[2153]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::F[2153] );
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
    \std::conv::flip_array[2154]  flip_array_0();
    (* src = "<compiler dir>/stdlib/conv.spade:43,9" *)
    \std::conv::concat_arrays[2155]  concat_arrays_0(.l_i(_e_441), .output__(_e_440));
    assign output__ = _e_440;
endmodule

module \std::conv::flip_array[2154]  (
        
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::flip_array[2154]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::flip_array[2154] );
        end
    end
    `endif
    (* src = "<compiler dir>/stdlib/conv.spade:39,49" *)
    \std::conv::std::conv::flip_array::T[2156]  T_0();
endmodule

module \std::conv::concat_arrays[2155]  (
        input[7:0] l_i,
        output[7:0] output__
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::concat_arrays[2155]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::concat_arrays[2155] );
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

module \std::conv::std::conv::flip_array::T[2156]  (
        
    );
    `ifdef COCOTB_SIM
    string __top_module;
    string __vcd_file;
    initial begin
        if ($value$plusargs("TOP_MODULE=%s", __top_module) && __top_module == "std::conv::std::conv::flip_array::T[2156]" && $value$plusargs("VCD_FILENAME=%s", __vcd_file)) begin
            $dumpfile (__vcd_file);
            $dumpvars (0, \std::conv::std::conv::flip_array::T[2156] );
        end
    end
    `endif
    
endmodule