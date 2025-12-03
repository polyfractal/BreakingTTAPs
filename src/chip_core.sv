
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
    logic[7:0] _e_7779;
    (* src = "src/sram.spade:71,22" *)
    logic[7:0] _e_7780_mut;
    (* src = "src/sram.spade:71,22" *)
    logic[7:0] _e_1181;
    (* src = "src/sram.spade:71,22" *)
    logic[7:0] _e_1181_mut;
    (* src = "src/sram.spade:71,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:71,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:72,22" *)
    logic[7:0] _e_7781;
    (* src = "src/sram.spade:72,22" *)
    logic[7:0] _e_7782_mut;
    (* src = "src/sram.spade:72,22" *)
    logic[7:0] _e_1185;
    (* src = "src/sram.spade:72,22" *)
    logic[7:0] _e_1185_mut;
    (* src = "src/sram.spade:72,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:72,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:73,22" *)
    logic[7:0] _e_7783;
    (* src = "src/sram.spade:73,22" *)
    logic[7:0] _e_7784_mut;
    (* src = "src/sram.spade:73,22" *)
    logic[7:0] _e_1189;
    (* src = "src/sram.spade:73,22" *)
    logic[7:0] _e_1189_mut;
    (* src = "src/sram.spade:73,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:73,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:74,22" *)
    logic[7:0] _e_7785;
    (* src = "src/sram.spade:74,22" *)
    logic[7:0] _e_7786_mut;
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
    
    assign _e_7779 = _e_7780_mut;
    assign _e_1181 = {_e_7779};
    assign {_e_7780_mut} = _e_1181_mut;
    assign \qr0  = _e_1181[7:0];
    assign _e_1181_mut[7:0] = \qw0_mut ;
    
    assign _e_7781 = _e_7782_mut;
    assign _e_1185 = {_e_7781};
    assign {_e_7782_mut} = _e_1185_mut;
    assign \qr1  = _e_1185[7:0];
    assign _e_1185_mut[7:0] = \qw1_mut ;
    
    assign _e_7783 = _e_7784_mut;
    assign _e_1189 = {_e_7783};
    assign {_e_7784_mut} = _e_1189_mut;
    assign \qr2  = _e_1189[7:0];
    assign _e_1189_mut[7:0] = \qw2_mut ;
    
    assign _e_7785 = _e_7786_mut;
    assign _e_1193 = {_e_7785};
    assign {_e_7786_mut} = _e_1193_mut;
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
    logic[7:0] _e_7787;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_7788_mut;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_1291;
    (* src = "src/sram.spade:111,22" *)
    logic[7:0] _e_1291_mut;
    (* src = "src/sram.spade:111,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:111,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_7789;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_7790_mut;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_1295;
    (* src = "src/sram.spade:112,22" *)
    logic[7:0] _e_1295_mut;
    (* src = "src/sram.spade:112,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:112,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_7791;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_7792_mut;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_1299;
    (* src = "src/sram.spade:113,22" *)
    logic[7:0] _e_1299_mut;
    (* src = "src/sram.spade:113,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:113,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:114,22" *)
    logic[7:0] _e_7793;
    (* src = "src/sram.spade:114,22" *)
    logic[7:0] _e_7794_mut;
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
    
    assign _e_7787 = _e_7788_mut;
    assign _e_1291 = {_e_7787};
    assign {_e_7788_mut} = _e_1291_mut;
    assign \qr0  = _e_1291[7:0];
    assign _e_1291_mut[7:0] = \qw0_mut ;
    
    assign _e_7789 = _e_7790_mut;
    assign _e_1295 = {_e_7789};
    assign {_e_7790_mut} = _e_1295_mut;
    assign \qr1  = _e_1295[7:0];
    assign _e_1295_mut[7:0] = \qw1_mut ;
    
    assign _e_7791 = _e_7792_mut;
    assign _e_1299 = {_e_7791};
    assign {_e_7792_mut} = _e_1299_mut;
    assign \qr2  = _e_1299[7:0];
    assign _e_1299_mut[7:0] = \qw2_mut ;
    
    assign _e_7793 = _e_7794_mut;
    assign _e_1303 = {_e_7793};
    assign {_e_7794_mut} = _e_1303_mut;
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
    logic[7:0] _e_7795;
    (* src = "src/sram.spade:160,22" *)
    logic[7:0] _e_7796_mut;
    (* src = "src/sram.spade:160,22" *)
    logic[7:0] _e_1401;
    (* src = "src/sram.spade:160,22" *)
    logic[7:0] _e_1401_mut;
    (* src = "src/sram.spade:160,9" *)
    logic[7:0] \qr0 ;
    (* src = "src/sram.spade:160,9" *)
    logic[7:0] \qw0_mut ;
    (* src = "src/sram.spade:161,22" *)
    logic[7:0] _e_7797;
    (* src = "src/sram.spade:161,22" *)
    logic[7:0] _e_7798_mut;
    (* src = "src/sram.spade:161,22" *)
    logic[7:0] _e_1405;
    (* src = "src/sram.spade:161,22" *)
    logic[7:0] _e_1405_mut;
    (* src = "src/sram.spade:161,9" *)
    logic[7:0] \qr1 ;
    (* src = "src/sram.spade:161,9" *)
    logic[7:0] \qw1_mut ;
    (* src = "src/sram.spade:162,22" *)
    logic[7:0] _e_7799;
    (* src = "src/sram.spade:162,22" *)
    logic[7:0] _e_7800_mut;
    (* src = "src/sram.spade:162,22" *)
    logic[7:0] _e_1409;
    (* src = "src/sram.spade:162,22" *)
    logic[7:0] _e_1409_mut;
    (* src = "src/sram.spade:162,9" *)
    logic[7:0] \qr2 ;
    (* src = "src/sram.spade:162,9" *)
    logic[7:0] \qw2_mut ;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_7801;
    (* src = "src/sram.spade:163,22" *)
    logic[7:0] _e_7802_mut;
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
    
    assign _e_7795 = _e_7796_mut;
    assign _e_1401 = {_e_7795};
    assign {_e_7796_mut} = _e_1401_mut;
    assign \qr0  = _e_1401[7:0];
    assign _e_1401_mut[7:0] = \qw0_mut ;
    
    assign _e_7797 = _e_7798_mut;
    assign _e_1405 = {_e_7797};
    assign {_e_7798_mut} = _e_1405_mut;
    assign \qr1  = _e_1405[7:0];
    assign _e_1405_mut[7:0] = \qw1_mut ;
    
    assign _e_7799 = _e_7800_mut;
    assign _e_1409 = {_e_7799};
    assign {_e_7800_mut} = _e_1409_mut;
    assign \qr2  = _e_1409[7:0];
    assign _e_1409_mut[7:0] = \qw2_mut ;
    
    assign _e_7801 = _e_7802_mut;
    assign _e_1413 = {_e_7801};
    assign {_e_7802_mut} = _e_1413_mut;
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
        input parallel_clock_i
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
    logic[9:0] _e_7803;
    (* src = "src/main.spade:77,24" *)
    logic[9:0] _e_7804_mut;
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
    logic[8:0] _e_7805;
    (* src = "src/main.spade:83,28" *)
    logic[8:0] _e_7806_mut;
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
    logic[8:0] _e_7807;
    (* src = "src/main.spade:89,34" *)
    logic[8:0] _e_7808_mut;
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
    logic _e_7811;
    logic _e_7813;
    logic _e_7815;
    (* src = "src/main.spade:103,7" *)
    logic[11:0] _e_1605;
    (* src = "src/main.spade:103,7" *)
    logic[10:0] _e_1603;
    (* src = "src/main.spade:103,7" *)
    logic _e_1604;
    logic _e_7818;
    logic _e_7820;
    (* src = "src/main.spade:104,7" *)
    logic[11:0] _e_1609;
    (* src = "src/main.spade:104,7" *)
    logic[10:0] __n1;
    (* src = "src/main.spade:104,7" *)
    logic __n2;
    logic _e_7824;
    (* src = "src/main.spade:101,49" *)
    logic _e_1593;
    (* src = "src/main.spade:101,14" *)
    reg \released ;
    (* src = "src/main.spade:108,15" *)
    logic[97:0] _e_1614;
    logic _e_7826;
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
    logic[410:0] \tta_out ;
    (* src = "src/main.spade:126,18" *)
    logic[15:0] _e_1638;
    
    assign _e_7803 = _e_7804_mut;
    assign _e_1535 = {_e_7803};
    assign {_e_7804_mut} = _e_1535_mut;
    assign \pc_r  = _e_1535[9:0];
    assign _e_1535_mut[9:0] = \pc_w_mut ;
    (* src = "src/main.spade:79,25" *)
    \tta::parallel_rx::parallel_boot  parallel_boot_0(.clk_i(\clk ), .rst_i(\rst ), .data_in_i(\parallel_in ), .strobe_i(\parallel_strobe ), .clk_pin_i(\parallel_clock ), .output__(\parallel_data ));
    
    assign _e_7805 = _e_7806_mut;
    assign _e_1547 = {_e_7805};
    assign {_e_7806_mut} = _e_1547_mut;
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
    
    assign _e_7807 = _e_7808_mut;
    assign _e_1571 = {_e_7807};
    assign {_e_7808_mut} = _e_1571_mut;
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
    assign _e_7811 = _e_1599[10] == 1'd1;
    localparam[0:0] _e_7812 = 1;
    assign _e_7813 = _e_7811 && _e_7812;
    localparam[0:0] _e_7814 = 1;
    assign _e_7815 = _e_7813 && _e_7814;
    localparam[0:0] _e_1602 = 1;
    assign _e_1605 = _e_1594;
    assign _e_1603 = _e_1594[11:1];
    assign _e_1604 = _e_1594[0];
    assign _e_7818 = _e_1603[10] == 1'd0;
    assign _e_7820 = _e_7818 && _e_1604;
    localparam[0:0] _e_1606 = 1;
    assign _e_1609 = _e_1594;
    assign __n1 = _e_1594[11:1];
    assign __n2 = _e_1594[0];
    localparam[0:0] _e_7822 = 1;
    localparam[0:0] _e_7823 = 1;
    assign _e_7824 = _e_7822 && _e_7823;
    localparam[0:0] _e_1610 = 0;
    always_comb begin
        priority casez ({_e_7815, _e_7820, _e_7824})
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
    assign _e_7826 = !\released ;
    (* src = "src/main.spade:109,16" *)
    \tta::noop  noop_0(.output__(_e_1617));
    always_comb begin
        priority casez ({\released , _e_7826})
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
    logic[36:0] _e_1644;
    (* src = "src/main.spade:141,27" *)
    logic[10:0] _e_1645;
    (* src = "src/main.spade:141,11" *)
    logic[48:0] _e_1643;
    (* src = "src/main.spade:142,16" *)
    logic[36:0] _e_1648;
    (* src = "src/main.spade:142,27" *)
    logic[10:0] _e_1649;
    (* src = "src/main.spade:142,11" *)
    logic[48:0] _e_1647;
    (* src = "src/main.spade:140,3" *)
    logic[97:0] _e_1642;
    assign _e_1644 = {5'd6, 32'bX};
    assign _e_1645 = {7'd2, 4'bX};
    localparam[0:0] _e_1646 = 0;
    assign _e_1643 = {_e_1644, _e_1645, _e_1646};
    assign _e_1648 = {5'd6, 32'bX};
    assign _e_1649 = {7'd2, 4'bX};
    localparam[0:0] _e_1650 = 0;
    assign _e_1647 = {_e_1648, _e_1649, _e_1650};
    assign _e_1642 = {_e_1643, _e_1647};
    assign output__ = _e_1642;
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
    logic[16:0] _e_1659;
    (* src = "src/main.spade:149,12" *)
    logic _e_1657;
    (* src = "src/main.spade:149,51" *)
    logic[17:0] _e_1666;
    (* src = "src/main.spade:149,45" *)
    logic[16:0] _e_1665;
    (* src = "src/main.spade:149,9" *)
    logic[16:0] _e_1656;
    (* src = "src/main.spade:148,14" *)
    reg[16:0] \count ;
    (* src = "src/main.spade:151,5" *)
    logic _e_1669;
    localparam[16:0] _e_1655 = 0;
    localparam[15:0] _e_1661 = 1;
    assign _e_1659 = \period  - _e_1661;
    assign _e_1657 = \count  == _e_1659;
    localparam[16:0] _e_1663 = 0;
    localparam[16:0] _e_1668 = 1;
    assign _e_1666 = \count  + _e_1668;
    assign _e_1665 = _e_1666[16:0];
    assign _e_1656 = _e_1657 ? _e_1663 : _e_1665;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \count  <= _e_1655;
        end
        else begin
            \count  <= _e_1656;
        end
    end
    localparam[16:0] _e_1671 = 0;
    assign _e_1669 = \count  == _e_1671;
    assign output__ = _e_1669;
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
    logic[1:0] _e_1677;
    (* src = "src/uart.spade:54,36" *)
    logic[17:0] _e_1676;
    (* src = "src/uart.spade:57,35" *)
    logic[3:0] _e_1687;
    (* src = "src/uart.spade:57,35" *)
    logic[4:0] _e_1686;
    (* src = "src/uart.spade:57,29" *)
    logic[3:0] \next_tick ;
    (* src = "src/uart.spade:58,29" *)
    logic[3:0] _e_1692;
    (* src = "src/uart.spade:58,29" *)
    logic \baud_tick ;
    (* src = "src/uart.spade:60,19" *)
    logic[1:0] _e_1697;
    (* src = "src/uart.spade:61,17" *)
    logic[1:0] _e_1699;
    logic _e_7828;
    (* src = "src/uart.spade:62,27" *)
    logic[8:0] _e_1702;
    (* src = "src/uart.spade:63,25" *)
    logic[8:0] _e_1705;
    (* src = "src/uart.spade:63,25" *)
    logic[7:0] \data ;
    logic _e_7830;
    logic _e_7832;
    (* src = "src/uart.spade:66,36" *)
    logic[1:0] _e_1708;
    (* src = "src/uart.spade:66,29" *)
    logic[17:0] _e_1707;
    (* src = "src/uart.spade:68,25" *)
    logic[8:0] _e_1712;
    logic _e_7834;
    (* src = "src/uart.spade:62,21" *)
    logic[17:0] _e_1701;
    (* src = "src/uart.spade:71,17" *)
    logic[1:0] _e_1714;
    logic _e_7836;
    (* src = "src/uart.spade:73,32" *)
    logic[1:0] _e_1720;
    (* src = "src/uart.spade:73,47" *)
    logic[7:0] _e_1721;
    (* src = "src/uart.spade:73,25" *)
    logic[17:0] _e_1719;
    (* src = "src/uart.spade:75,32" *)
    logic[1:0] _e_1727;
    (* src = "src/uart.spade:75,42" *)
    logic[7:0] _e_1729;
    (* src = "src/uart.spade:75,49" *)
    logic[3:0] _e_1731;
    (* src = "src/uart.spade:75,25" *)
    logic[17:0] _e_1726;
    (* src = "src/uart.spade:72,21" *)
    logic[17:0] _e_1716;
    (* src = "src/uart.spade:78,17" *)
    logic[1:0] _e_1734;
    logic _e_7838;
    (* src = "src/uart.spade:81,28" *)
    logic[3:0] _e_1741;
    (* src = "src/uart.spade:81,28" *)
    logic _e_1740;
    (* src = "src/uart.spade:82,36" *)
    logic[1:0] _e_1746;
    (* src = "src/uart.spade:82,51" *)
    logic[7:0] _e_1747;
    (* src = "src/uart.spade:82,29" *)
    logic[17:0] _e_1745;
    (* src = "src/uart.spade:84,36" *)
    logic[1:0] _e_1753;
    (* src = "src/uart.spade:84,51" *)
    logic[7:0] _e_1755;
    (* src = "src/uart.spade:84,51" *)
    logic[7:0] _e_1754;
    (* src = "src/uart.spade:84,69" *)
    logic[3:0] _e_1760;
    (* src = "src/uart.spade:84,69" *)
    logic[4:0] _e_1759;
    (* src = "src/uart.spade:84,63" *)
    logic[3:0] _e_1758;
    (* src = "src/uart.spade:84,29" *)
    logic[17:0] _e_1752;
    (* src = "src/uart.spade:81,25" *)
    logic[17:0] _e_1739;
    (* src = "src/uart.spade:87,32" *)
    logic[1:0] _e_1766;
    (* src = "src/uart.spade:87,42" *)
    logic[7:0] _e_1768;
    (* src = "src/uart.spade:87,49" *)
    logic[3:0] _e_1770;
    (* src = "src/uart.spade:87,25" *)
    logic[17:0] _e_1765;
    (* src = "src/uart.spade:79,21" *)
    logic[17:0] _e_1736;
    (* src = "src/uart.spade:90,17" *)
    logic[1:0] _e_1773;
    logic _e_7840;
    (* src = "src/uart.spade:92,32" *)
    logic[1:0] _e_1779;
    (* src = "src/uart.spade:92,25" *)
    logic[17:0] _e_1778;
    (* src = "src/uart.spade:94,32" *)
    logic[1:0] _e_1785;
    (* src = "src/uart.spade:94,42" *)
    logic[7:0] _e_1787;
    (* src = "src/uart.spade:94,49" *)
    logic[3:0] _e_1789;
    (* src = "src/uart.spade:94,25" *)
    logic[17:0] _e_1784;
    (* src = "src/uart.spade:91,21" *)
    logic[17:0] _e_1775;
    (* src = "src/uart.spade:60,13" *)
    logic[17:0] _e_1696;
    (* src = "src/uart.spade:56,9" *)
    logic[17:0] _e_1682;
    (* src = "src/uart.spade:54,14" *)
    reg[17:0] \tx ;
    (* src = "src/uart.spade:104,24" *)
    logic[1:0] _e_1795;
    (* src = "src/uart.spade:105,9" *)
    logic[1:0] _e_1797;
    logic _e_7842;
    (* src = "src/uart.spade:106,9" *)
    logic[1:0] _e_1799;
    logic _e_7844;
    (* src = "src/uart.spade:107,9" *)
    logic[1:0] _e_1801;
    logic _e_7846;
    (* src = "src/uart.spade:107,27" *)
    logic[7:0] _e_1804;
    (* src = "src/uart.spade:107,26" *)
    logic[7:0] _e_1803;
    (* src = "src/uart.spade:107,26" *)
    logic _e_1802;
    (* src = "src/uart.spade:108,9" *)
    logic[1:0] _e_1808;
    logic _e_7848;
    (* src = "src/uart.spade:104,18" *)
    logic \tx_out ;
    (* src = "src/uart.spade:111,25" *)
    logic[1:0] _e_1812;
    (* src = "src/uart.spade:112,9" *)
    logic[1:0] _e_1814;
    logic _e_7850;
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
    logic[1:0] _e_1836;
    (* src = "src/uart.spade:124,36" *)
    logic[16:0] _e_1835;
    (* src = "src/uart.spade:126,19" *)
    logic[1:0] _e_1845;
    (* src = "src/uart.spade:127,17" *)
    logic[1:0] _e_1847;
    logic _e_7853;
    (* src = "src/uart.spade:128,24" *)
    logic _e_1850;
    (* src = "src/uart.spade:129,32" *)
    logic[1:0] _e_1854;
    (* src = "src/uart.spade:129,25" *)
    logic[16:0] _e_1853;
    (* src = "src/uart.spade:128,21" *)
    logic[16:0] _e_1849;
    (* src = "src/uart.spade:134,17" *)
    logic[1:0] _e_1860;
    logic _e_7855;
    (* src = "src/uart.spade:135,24" *)
    logic[3:0] _e_1864;
    (* src = "src/uart.spade:135,24" *)
    logic _e_1863;
    (* src = "src/uart.spade:136,28" *)
    logic _e_1869;
    (* src = "src/uart.spade:137,36" *)
    logic[1:0] _e_1873;
    (* src = "src/uart.spade:137,29" *)
    logic[16:0] _e_1872;
    (* src = "src/uart.spade:139,36" *)
    logic[1:0] _e_1879;
    (* src = "src/uart.spade:139,29" *)
    logic[16:0] _e_1878;
    (* src = "src/uart.spade:136,25" *)
    logic[16:0] _e_1868;
    (* src = "src/uart.spade:142,32" *)
    logic[1:0] _e_1885;
    (* src = "src/uart.spade:142,42" *)
    logic[7:0] _e_1887;
    (* src = "src/uart.spade:142,49" *)
    logic[2:0] _e_1889;
    (* src = "src/uart.spade:142,67" *)
    logic[3:0] _e_1893;
    (* src = "src/uart.spade:142,67" *)
    logic[4:0] _e_1892;
    (* src = "src/uart.spade:142,61" *)
    logic[3:0] _e_1891;
    (* src = "src/uart.spade:142,25" *)
    logic[16:0] _e_1884;
    (* src = "src/uart.spade:135,21" *)
    logic[16:0] _e_1862;
    (* src = "src/uart.spade:145,17" *)
    logic[1:0] _e_1896;
    logic _e_7857;
    (* src = "src/uart.spade:146,24" *)
    logic[3:0] _e_1900;
    (* src = "src/uart.spade:146,24" *)
    logic _e_1899;
    (* src = "src/uart.spade:150,40" *)
    logic[7:0] _e_1906;
    (* src = "src/uart.spade:150,39" *)
    logic[7:0] _e_1905;
    (* src = "src/uart.spade:150,54" *)
    logic[7:0] _e_1909;
    (* src = "src/uart.spade:150,39" *)
    logic[7:0] \next_sh ;
    (* src = "src/uart.spade:152,28" *)
    logic[2:0] _e_1918;
    (* src = "src/uart.spade:152,28" *)
    logic _e_1917;
    (* src = "src/uart.spade:153,36" *)
    logic[1:0] _e_1923;
    (* src = "src/uart.spade:153,29" *)
    logic[16:0] _e_1922;
    (* src = "src/uart.spade:155,36" *)
    logic[1:0] _e_1929;
    (* src = "src/uart.spade:155,66" *)
    logic[2:0] _e_1933;
    (* src = "src/uart.spade:155,66" *)
    logic[3:0] _e_1932;
    (* src = "src/uart.spade:155,60" *)
    logic[2:0] _e_1931;
    (* src = "src/uart.spade:155,29" *)
    logic[16:0] _e_1928;
    (* src = "src/uart.spade:152,25" *)
    logic[16:0] _e_1916;
    (* src = "src/uart.spade:158,32" *)
    logic[1:0] _e_1939;
    (* src = "src/uart.spade:158,42" *)
    logic[7:0] _e_1941;
    (* src = "src/uart.spade:158,49" *)
    logic[2:0] _e_1943;
    (* src = "src/uart.spade:158,67" *)
    logic[3:0] _e_1947;
    (* src = "src/uart.spade:158,67" *)
    logic[4:0] _e_1946;
    (* src = "src/uart.spade:158,61" *)
    logic[3:0] _e_1945;
    (* src = "src/uart.spade:158,25" *)
    logic[16:0] _e_1938;
    (* src = "src/uart.spade:146,21" *)
    logic[16:0] _e_1898;
    (* src = "src/uart.spade:161,17" *)
    logic[1:0] _e_1950;
    logic _e_7859;
    (* src = "src/uart.spade:162,24" *)
    logic[3:0] _e_1954;
    (* src = "src/uart.spade:162,24" *)
    logic _e_1953;
    (* src = "src/uart.spade:164,32" *)
    logic[1:0] _e_1959;
    (* src = "src/uart.spade:164,47" *)
    logic[7:0] _e_1960;
    (* src = "src/uart.spade:164,25" *)
    logic[16:0] _e_1958;
    (* src = "src/uart.spade:166,32" *)
    logic[1:0] _e_1966;
    (* src = "src/uart.spade:166,42" *)
    logic[7:0] _e_1968;
    (* src = "src/uart.spade:166,49" *)
    logic[2:0] _e_1970;
    (* src = "src/uart.spade:166,67" *)
    logic[3:0] _e_1974;
    (* src = "src/uart.spade:166,67" *)
    logic[4:0] _e_1973;
    (* src = "src/uart.spade:166,61" *)
    logic[3:0] _e_1972;
    (* src = "src/uart.spade:166,25" *)
    logic[16:0] _e_1965;
    (* src = "src/uart.spade:162,21" *)
    logic[16:0] _e_1952;
    (* src = "src/uart.spade:126,13" *)
    logic[16:0] _e_1844;
    (* src = "src/uart.spade:125,9" *)
    logic[16:0] _e_1841;
    (* src = "src/uart.spade:124,14" *)
    reg[16:0] \rx ;
    (* src = "src/uart.spade:177,36" *)
    logic[1:0] _e_1982;
    (* src = "src/uart.spade:178,9" *)
    logic[1:0] _e_1984;
    logic _e_7861;
    (* src = "src/uart.spade:178,26" *)
    logic[3:0] _e_1986;
    (* src = "src/uart.spade:178,26" *)
    logic _e_1985;
    (* src = "src/uart.spade:179,9" *)
    logic[1:0] __n1;
    (* src = "src/uart.spade:177,30" *)
    logic _e_1981;
    (* src = "src/uart.spade:177,20" *)
    logic \rx_valid ;
    (* src = "src/uart.spade:182,38" *)
    logic[7:0] _e_1996;
    (* src = "src/uart.spade:182,33" *)
    logic[8:0] _e_1995;
    (* src = "src/uart.spade:182,54" *)
    logic[8:0] _e_1999;
    (* src = "src/uart.spade:182,19" *)
    logic[8:0] \rx_data ;
    (* src = "src/uart.spade:184,5" *)
    logic[10:0] _e_2001;
    assign _e_1677 = {2'd0};
    localparam[7:0] _e_1678 = 0;
    localparam[3:0] _e_1679 = 0;
    localparam[3:0] _e_1680 = 0;
    assign _e_1676 = {_e_1677, _e_1678, _e_1679, _e_1680};
    assign _e_1687 = \tx [3:0];
    localparam[3:0] _e_1689 = 1;
    assign _e_1686 = _e_1687 + _e_1689;
    assign \next_tick  = _e_1686[3:0];
    assign _e_1692 = \tx [3:0];
    localparam[3:0] _e_1694 = 15;
    assign \baud_tick  = _e_1692 == _e_1694;
    assign _e_1697 = \tx [17:16];
    assign _e_1699 = _e_1697;
    assign _e_7828 = _e_1697[1:0] == 2'd0;
    assign _e_1702 = \tx_data ;
    assign _e_1705 = _e_1702;
    assign \data  = _e_1702[7:0];
    assign _e_7830 = _e_1702[8] == 1'd1;
    localparam[0:0] _e_7831 = 1;
    assign _e_7832 = _e_7830 && _e_7831;
    assign _e_1708 = {2'd1};
    localparam[3:0] _e_1710 = 0;
    localparam[3:0] _e_1711 = 0;
    assign _e_1707 = {_e_1708, \data , _e_1710, _e_1711};
    assign _e_1712 = _e_1702;
    assign _e_7834 = _e_1702[8] == 1'd0;
    always_comb begin
        priority casez ({_e_7832, _e_7834})
            2'b1?: _e_1701 = _e_1707;
            2'b01: _e_1701 = \tx ;
            2'b?: _e_1701 = 18'dx;
        endcase
    end
    assign _e_1714 = _e_1697;
    assign _e_7836 = _e_1697[1:0] == 2'd1;
    assign _e_1720 = {2'd2};
    assign _e_1721 = \tx [15:8];
    localparam[3:0] _e_1723 = 0;
    localparam[3:0] _e_1724 = 0;
    assign _e_1719 = {_e_1720, _e_1721, _e_1723, _e_1724};
    assign _e_1727 = \tx [17:16];
    assign _e_1729 = \tx [15:8];
    assign _e_1731 = \tx [7:4];
    assign _e_1726 = {_e_1727, _e_1729, _e_1731, \next_tick };
    assign _e_1716 = \baud_tick  ? _e_1719 : _e_1726;
    assign _e_1734 = _e_1697;
    assign _e_7838 = _e_1697[1:0] == 2'd2;
    assign _e_1741 = \tx [7:4];
    localparam[3:0] _e_1743 = 7;
    assign _e_1740 = _e_1741 == _e_1743;
    assign _e_1746 = {2'd3};
    assign _e_1747 = \tx [15:8];
    localparam[3:0] _e_1749 = 0;
    localparam[3:0] _e_1750 = 0;
    assign _e_1745 = {_e_1746, _e_1747, _e_1749, _e_1750};
    assign _e_1753 = {2'd2};
    assign _e_1755 = \tx [15:8];
    localparam[7:0] _e_1757 = 1;
    assign _e_1754 = _e_1755 >> _e_1757;
    assign _e_1760 = \tx [7:4];
    localparam[3:0] _e_1762 = 1;
    assign _e_1759 = _e_1760 + _e_1762;
    assign _e_1758 = _e_1759[3:0];
    localparam[3:0] _e_1763 = 0;
    assign _e_1752 = {_e_1753, _e_1754, _e_1758, _e_1763};
    assign _e_1739 = _e_1740 ? _e_1745 : _e_1752;
    assign _e_1766 = \tx [17:16];
    assign _e_1768 = \tx [15:8];
    assign _e_1770 = \tx [7:4];
    assign _e_1765 = {_e_1766, _e_1768, _e_1770, \next_tick };
    assign _e_1736 = \baud_tick  ? _e_1739 : _e_1765;
    assign _e_1773 = _e_1697;
    assign _e_7840 = _e_1697[1:0] == 2'd3;
    assign _e_1779 = {2'd0};
    localparam[7:0] _e_1780 = 0;
    localparam[3:0] _e_1781 = 0;
    localparam[3:0] _e_1782 = 0;
    assign _e_1778 = {_e_1779, _e_1780, _e_1781, _e_1782};
    assign _e_1785 = \tx [17:16];
    assign _e_1787 = \tx [15:8];
    assign _e_1789 = \tx [7:4];
    assign _e_1784 = {_e_1785, _e_1787, _e_1789, \next_tick };
    assign _e_1775 = \baud_tick  ? _e_1778 : _e_1784;
    always_comb begin
        priority casez ({_e_7828, _e_7836, _e_7838, _e_7840})
            4'b1???: _e_1696 = _e_1701;
            4'b01??: _e_1696 = _e_1716;
            4'b001?: _e_1696 = _e_1736;
            4'b0001: _e_1696 = _e_1775;
            4'b?: _e_1696 = 18'dx;
        endcase
    end
    assign _e_1682 = \tick16  ? _e_1696 : \tx ;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \tx  <= _e_1676;
        end
        else begin
            \tx  <= _e_1682;
        end
    end
    assign _e_1795 = \tx [17:16];
    assign _e_1797 = _e_1795;
    assign _e_7842 = _e_1795[1:0] == 2'd0;
    localparam[0:0] _e_1798 = 1;
    assign _e_1799 = _e_1795;
    assign _e_7844 = _e_1795[1:0] == 2'd1;
    localparam[0:0] _e_1800 = 0;
    assign _e_1801 = _e_1795;
    assign _e_7846 = _e_1795[1:0] == 2'd2;
    assign _e_1804 = \tx [15:8];
    localparam[7:0] _e_1806 = 1;
    assign _e_1803 = _e_1804 & _e_1806;
    localparam[7:0] _e_1807 = 0;
    assign _e_1802 = _e_1803 != _e_1807;
    assign _e_1808 = _e_1795;
    assign _e_7848 = _e_1795[1:0] == 2'd3;
    localparam[0:0] _e_1809 = 1;
    always_comb begin
        priority casez ({_e_7842, _e_7844, _e_7846, _e_7848})
            4'b1???: \tx_out  = _e_1798;
            4'b01??: \tx_out  = _e_1800;
            4'b001?: \tx_out  = _e_1802;
            4'b0001: \tx_out  = _e_1809;
            4'b?: \tx_out  = 1'dx;
        endcase
    end
    assign _e_1812 = \tx [17:16];
    assign _e_1814 = _e_1812;
    assign _e_7850 = _e_1812[1:0] == 2'd0;
    localparam[0:0] _e_1815 = 0;
    assign \_  = _e_1812;
    localparam[0:0] _e_7851 = 1;
    localparam[0:0] _e_1817 = 1;
    always_comb begin
        priority casez ({_e_7850, _e_7851})
            2'b1?: \tx_busy  = _e_1815;
            2'b01: \tx_busy  = _e_1817;
            2'b?: \tx_busy  = 1'dx;
        endcase
    end
    localparam[0:0] _e_1822 = 1;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx_sync1  <= _e_1822;
        end
        else begin
            \rx_sync1  <= \rx_in ;
        end
    end
    localparam[0:0] _e_1828 = 1;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx_sync2  <= _e_1828;
        end
        else begin
            \rx_sync2  <= \rx_sync1 ;
        end
    end
    assign \rxd  = \rx_sync2 ;
    assign _e_1836 = {2'd0};
    localparam[7:0] _e_1837 = 0;
    localparam[2:0] _e_1838 = 0;
    localparam[3:0] _e_1839 = 0;
    assign _e_1835 = {_e_1836, _e_1837, _e_1838, _e_1839};
    assign _e_1845 = \rx [16:15];
    assign _e_1847 = _e_1845;
    assign _e_7853 = _e_1845[1:0] == 2'd0;
    assign _e_1850 = !\rxd ;
    assign _e_1854 = {2'd1};
    localparam[7:0] _e_1855 = 0;
    localparam[2:0] _e_1856 = 0;
    localparam[3:0] _e_1857 = 0;
    assign _e_1853 = {_e_1854, _e_1855, _e_1856, _e_1857};
    assign _e_1849 = _e_1850 ? _e_1853 : \rx ;
    assign _e_1860 = _e_1845;
    assign _e_7855 = _e_1845[1:0] == 2'd1;
    assign _e_1864 = \rx [3:0];
    localparam[3:0] _e_1866 = 7;
    assign _e_1863 = _e_1864 == _e_1866;
    assign _e_1869 = !\rxd ;
    assign _e_1873 = {2'd2};
    localparam[7:0] _e_1874 = 0;
    localparam[2:0] _e_1875 = 0;
    localparam[3:0] _e_1876 = 0;
    assign _e_1872 = {_e_1873, _e_1874, _e_1875, _e_1876};
    assign _e_1879 = {2'd0};
    localparam[7:0] _e_1880 = 0;
    localparam[2:0] _e_1881 = 0;
    localparam[3:0] _e_1882 = 0;
    assign _e_1878 = {_e_1879, _e_1880, _e_1881, _e_1882};
    assign _e_1868 = _e_1869 ? _e_1872 : _e_1878;
    assign _e_1885 = \rx [16:15];
    assign _e_1887 = \rx [14:7];
    assign _e_1889 = \rx [6:4];
    assign _e_1893 = \rx [3:0];
    localparam[3:0] _e_1895 = 1;
    assign _e_1892 = _e_1893 + _e_1895;
    assign _e_1891 = _e_1892[3:0];
    assign _e_1884 = {_e_1885, _e_1887, _e_1889, _e_1891};
    assign _e_1862 = _e_1863 ? _e_1868 : _e_1884;
    assign _e_1896 = _e_1845;
    assign _e_7857 = _e_1845[1:0] == 2'd2;
    assign _e_1900 = \rx [3:0];
    localparam[3:0] _e_1902 = 15;
    assign _e_1899 = _e_1900 == _e_1902;
    assign _e_1906 = \rx [14:7];
    localparam[7:0] _e_1908 = 1;
    assign _e_1905 = _e_1906 >> _e_1908;
    localparam[7:0] _e_1912 = 128;
    localparam[7:0] _e_1914 = 0;
    assign _e_1909 = \rxd  ? _e_1912 : _e_1914;
    assign \next_sh  = _e_1905 | _e_1909;
    assign _e_1918 = \rx [6:4];
    localparam[2:0] _e_1920 = 7;
    assign _e_1917 = _e_1918 == _e_1920;
    assign _e_1923 = {2'd3};
    localparam[2:0] _e_1925 = 0;
    localparam[3:0] _e_1926 = 0;
    assign _e_1922 = {_e_1923, \next_sh , _e_1925, _e_1926};
    assign _e_1929 = {2'd2};
    assign _e_1933 = \rx [6:4];
    localparam[2:0] _e_1935 = 1;
    assign _e_1932 = _e_1933 + _e_1935;
    assign _e_1931 = _e_1932[2:0];
    localparam[3:0] _e_1936 = 0;
    assign _e_1928 = {_e_1929, \next_sh , _e_1931, _e_1936};
    assign _e_1916 = _e_1917 ? _e_1922 : _e_1928;
    assign _e_1939 = \rx [16:15];
    assign _e_1941 = \rx [14:7];
    assign _e_1943 = \rx [6:4];
    assign _e_1947 = \rx [3:0];
    localparam[3:0] _e_1949 = 1;
    assign _e_1946 = _e_1947 + _e_1949;
    assign _e_1945 = _e_1946[3:0];
    assign _e_1938 = {_e_1939, _e_1941, _e_1943, _e_1945};
    assign _e_1898 = _e_1899 ? _e_1916 : _e_1938;
    assign _e_1950 = _e_1845;
    assign _e_7859 = _e_1845[1:0] == 2'd3;
    assign _e_1954 = \rx [3:0];
    localparam[3:0] _e_1956 = 15;
    assign _e_1953 = _e_1954 == _e_1956;
    assign _e_1959 = {2'd0};
    assign _e_1960 = \rx [14:7];
    localparam[2:0] _e_1962 = 0;
    localparam[3:0] _e_1963 = 0;
    assign _e_1958 = {_e_1959, _e_1960, _e_1962, _e_1963};
    assign _e_1966 = \rx [16:15];
    assign _e_1968 = \rx [14:7];
    assign _e_1970 = \rx [6:4];
    assign _e_1974 = \rx [3:0];
    localparam[3:0] _e_1976 = 1;
    assign _e_1973 = _e_1974 + _e_1976;
    assign _e_1972 = _e_1973[3:0];
    assign _e_1965 = {_e_1966, _e_1968, _e_1970, _e_1972};
    assign _e_1952 = _e_1953 ? _e_1958 : _e_1965;
    always_comb begin
        priority casez ({_e_7853, _e_7855, _e_7857, _e_7859})
            4'b1???: _e_1844 = _e_1849;
            4'b01??: _e_1844 = _e_1862;
            4'b001?: _e_1844 = _e_1898;
            4'b0001: _e_1844 = _e_1952;
            4'b?: _e_1844 = 17'dx;
        endcase
    end
    assign _e_1841 = \tick16  ? _e_1844 : \rx ;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx  <= _e_1835;
        end
        else begin
            \rx  <= _e_1841;
        end
    end
    assign _e_1982 = \rx [16:15];
    assign _e_1984 = _e_1982;
    assign _e_7861 = _e_1982[1:0] == 2'd3;
    assign _e_1986 = \rx [3:0];
    localparam[3:0] _e_1988 = 15;
    assign _e_1985 = _e_1986 == _e_1988;
    assign __n1 = _e_1982;
    localparam[0:0] _e_7862 = 1;
    localparam[0:0] _e_1990 = 0;
    always_comb begin
        priority casez ({_e_7861, _e_7862})
            2'b1?: _e_1981 = _e_1985;
            2'b01: _e_1981 = _e_1990;
            2'b?: _e_1981 = 1'dx;
        endcase
    end
    assign \rx_valid  = \tick16  && _e_1981;
    assign _e_1996 = \rx [14:7];
    assign _e_1995 = {1'd1, _e_1996};
    assign _e_1999 = {1'd0, 8'bX};
    assign \rx_data  = \rx_valid  ? _e_1995 : _e_1999;
    assign _e_2001 = {\tx_out , \rx_data , \tx_busy };
    assign output__ = _e_2001;
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
    logic _e_7864;
    logic _e_7866;
    logic _e_7868;
    (* src = "src/alu.spade:22,45" *)
    logic[31:0] _e_2010;
    (* src = "src/alu.spade:22,14" *)
    reg[31:0] \op_a ;
    (* src = "src/alu.spade:30,9" *)
    logic[36:0] _e_2021;
    (* src = "src/alu.spade:30,14" *)
    logic[4:0] _e_2019;
    (* src = "src/alu.spade:30,14" *)
    logic[31:0] \b ;
    logic _e_7870;
    logic _e_7873;
    logic _e_7875;
    logic _e_7876;
    (* src = "src/alu.spade:30,45" *)
    logic[32:0] _e_2025;
    (* src = "src/alu.spade:30,39" *)
    logic[31:0] _e_2024;
    (* src = "src/alu.spade:30,34" *)
    logic[32:0] _e_2023;
    (* src = "src/alu.spade:31,9" *)
    logic[36:0] _e_2030;
    (* src = "src/alu.spade:31,14" *)
    logic[4:0] _e_2028;
    (* src = "src/alu.spade:31,14" *)
    logic[31:0] b_n1;
    logic _e_7878;
    logic _e_7881;
    logic _e_7883;
    logic _e_7884;
    (* src = "src/alu.spade:31,45" *)
    logic[32:0] _e_2034;
    (* src = "src/alu.spade:31,39" *)
    logic[31:0] _e_2033;
    (* src = "src/alu.spade:31,34" *)
    logic[32:0] _e_2032;
    (* src = "src/alu.spade:32,9" *)
    logic[36:0] _e_2039;
    (* src = "src/alu.spade:32,14" *)
    logic[4:0] _e_2037;
    (* src = "src/alu.spade:32,14" *)
    logic[31:0] b_n2;
    logic _e_7886;
    logic _e_7889;
    logic _e_7891;
    logic _e_7892;
    (* src = "src/alu.spade:32,39" *)
    logic[31:0] _e_2042;
    (* src = "src/alu.spade:32,34" *)
    logic[32:0] _e_2041;
    (* src = "src/alu.spade:33,9" *)
    logic[36:0] _e_2047;
    (* src = "src/alu.spade:33,14" *)
    logic[4:0] _e_2045;
    (* src = "src/alu.spade:33,14" *)
    logic[31:0] b_n3;
    logic _e_7894;
    logic _e_7897;
    logic _e_7899;
    logic _e_7900;
    (* src = "src/alu.spade:33,39" *)
    logic[31:0] _e_2050;
    (* src = "src/alu.spade:33,34" *)
    logic[32:0] _e_2049;
    (* src = "src/alu.spade:34,9" *)
    logic[36:0] _e_2055;
    (* src = "src/alu.spade:34,14" *)
    logic[4:0] _e_2053;
    (* src = "src/alu.spade:34,14" *)
    logic[31:0] b_n4;
    logic _e_7902;
    logic _e_7905;
    logic _e_7907;
    logic _e_7908;
    (* src = "src/alu.spade:34,40" *)
    logic[31:0] _e_2058;
    (* src = "src/alu.spade:34,35" *)
    logic[32:0] _e_2057;
    (* src = "src/alu.spade:35,9" *)
    logic[36:0] _e_2062;
    (* src = "src/alu.spade:35,14" *)
    logic[4:0] _e_2060;
    (* src = "src/alu.spade:35,14" *)
    logic[31:0] b_n5;
    logic _e_7910;
    logic _e_7913;
    logic _e_7915;
    logic _e_7916;
    (* src = "src/alu.spade:35,39" *)
    logic[31:0] _e_2065;
    (* src = "src/alu.spade:35,34" *)
    logic[32:0] _e_2064;
    (* src = "src/alu.spade:36,9" *)
    logic[36:0] _e_2070;
    (* src = "src/alu.spade:36,14" *)
    logic[4:0] _e_2068;
    (* src = "src/alu.spade:36,14" *)
    logic[31:0] b_n6;
    logic _e_7918;
    logic _e_7921;
    logic _e_7923;
    logic _e_7924;
    (* src = "src/alu.spade:36,45" *)
    logic[31:0] _e_2074;
    (* src = "src/alu.spade:36,39" *)
    logic[31:0] _e_2073;
    (* src = "src/alu.spade:36,34" *)
    logic[32:0] _e_2072;
    (* src = "src/alu.spade:37,9" *)
    logic[36:0] _e_2079;
    (* src = "src/alu.spade:37,14" *)
    logic[4:0] _e_2077;
    (* src = "src/alu.spade:37,14" *)
    logic[31:0] b_n7;
    logic _e_7926;
    logic _e_7929;
    logic _e_7931;
    logic _e_7932;
    (* src = "src/alu.spade:37,45" *)
    logic[31:0] _e_2083;
    (* src = "src/alu.spade:37,39" *)
    logic[31:0] _e_2082;
    (* src = "src/alu.spade:37,34" *)
    logic[32:0] _e_2081;
    (* src = "src/alu.spade:38,9" *)
    logic[36:0] _e_2088;
    (* src = "src/alu.spade:38,14" *)
    logic[4:0] _e_2086;
    (* src = "src/alu.spade:38,14" *)
    logic[31:0] b_n8;
    logic _e_7934;
    logic _e_7937;
    logic _e_7939;
    logic _e_7940;
    (* src = "src/alu.spade:38,40" *)
    logic[31:0] _e_2091;
    (* src = "src/alu.spade:38,35" *)
    logic[32:0] _e_2090;
    (* src = "src/alu.spade:39,9" *)
    logic[36:0] _e_2096;
    (* src = "src/alu.spade:39,14" *)
    logic[4:0] _e_2094;
    (* src = "src/alu.spade:39,14" *)
    logic[31:0] b_n9;
    logic _e_7942;
    logic _e_7945;
    logic _e_7947;
    logic _e_7948;
    (* src = "src/alu.spade:39,40" *)
    logic[31:0] _e_2099;
    (* src = "src/alu.spade:39,35" *)
    logic[32:0] _e_2098;
    (* src = "src/alu.spade:40,9" *)
    logic[36:0] _e_2104;
    (* src = "src/alu.spade:40,14" *)
    logic[4:0] _e_2102;
    (* src = "src/alu.spade:40,14" *)
    logic[31:0] b_n10;
    logic _e_7950;
    logic _e_7953;
    logic _e_7955;
    logic _e_7956;
    (* src = "src/alu.spade:40,40" *)
    logic[31:0] _e_2107;
    (* src = "src/alu.spade:40,35" *)
    logic[32:0] _e_2106;
    (* src = "src/alu.spade:43,9" *)
    logic[36:0] _e_2112;
    (* src = "src/alu.spade:43,14" *)
    logic[4:0] _e_2110;
    (* src = "src/alu.spade:43,14" *)
    logic[31:0] b_n11;
    logic _e_7958;
    logic _e_7961;
    logic _e_7963;
    logic _e_7964;
    (* src = "src/alu.spade:43,42" *)
    logic _e_2116;
    (* src = "src/alu.spade:43,39" *)
    logic[31:0] _e_2115;
    (* src = "src/alu.spade:43,34" *)
    logic[32:0] _e_2114;
    (* src = "src/alu.spade:44,9" *)
    logic[36:0] _e_2125;
    (* src = "src/alu.spade:44,14" *)
    logic[4:0] _e_2123;
    (* src = "src/alu.spade:44,14" *)
    logic[31:0] b_n12;
    logic _e_7966;
    logic _e_7969;
    logic _e_7971;
    logic _e_7972;
    (* src = "src/alu.spade:44,42" *)
    logic _e_2129;
    (* src = "src/alu.spade:44,39" *)
    logic[31:0] _e_2128;
    (* src = "src/alu.spade:44,34" *)
    logic[32:0] _e_2127;
    (* src = "src/alu.spade:47,9" *)
    logic[36:0] _e_2138;
    (* src = "src/alu.spade:47,14" *)
    logic[4:0] _e_2136;
    (* src = "src/alu.spade:47,14" *)
    logic[31:0] b_n13;
    logic _e_7974;
    logic _e_7977;
    logic _e_7979;
    logic _e_7980;
    (* src = "src/alu.spade:47,41" *)
    logic[31:0] _e_2141;
    (* src = "src/alu.spade:47,36" *)
    logic[32:0] _e_2140;
    (* src = "src/alu.spade:48,9" *)
    logic[36:0] _e_2146;
    (* src = "src/alu.spade:48,14" *)
    logic[4:0] _e_2144;
    (* src = "src/alu.spade:48,14" *)
    logic[31:0] b_n14;
    logic _e_7982;
    logic _e_7985;
    logic _e_7987;
    logic _e_7988;
    (* src = "src/alu.spade:48,41" *)
    logic[31:0] _e_2149;
    (* src = "src/alu.spade:48,36" *)
    logic[32:0] _e_2148;
    (* src = "src/alu.spade:51,9" *)
    logic[36:0] _e_2154;
    (* src = "src/alu.spade:51,14" *)
    logic[4:0] _e_2152;
    (* src = "src/alu.spade:51,14" *)
    logic[31:0] b_n15;
    logic _e_7990;
    logic _e_7993;
    logic _e_7995;
    logic _e_7996;
    (* src = "src/alu.spade:51,41" *)
    logic[31:0] _e_2157;
    (* src = "src/alu.spade:51,36" *)
    logic[32:0] _e_2156;
    (* src = "src/alu.spade:52,9" *)
    logic[36:0] _e_2162;
    (* src = "src/alu.spade:52,14" *)
    logic[4:0] _e_2160;
    (* src = "src/alu.spade:52,14" *)
    logic[31:0] b_n16;
    logic _e_7998;
    logic _e_8001;
    logic _e_8003;
    logic _e_8004;
    (* src = "src/alu.spade:52,41" *)
    logic[31:0] _e_2165;
    (* src = "src/alu.spade:52,36" *)
    logic[32:0] _e_2164;
    logic _e_8006;
    (* src = "src/alu.spade:54,17" *)
    logic[32:0] _e_2169;
    (* src = "src/alu.spade:28,36" *)
    logic[32:0] \result ;
    (* src = "src/alu.spade:58,51" *)
    logic[32:0] _e_2174;
    (* src = "src/alu.spade:58,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2009 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_7864 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_7865 = 1;
    assign _e_7866 = _e_7864 && _e_7865;
    assign _e_7868 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_7866, _e_7868})
            2'b1?: _e_2010 = \v ;
            2'b01: _e_2010 = \op_a ;
            2'b?: _e_2010 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_2009;
        end
        else begin
            \op_a  <= _e_2010;
        end
    end
    assign _e_2021 = \trig [36:0];
    assign _e_2019 = _e_2021[36:32];
    assign \b  = _e_2021[31:0];
    assign _e_7870 = \trig [37] == 1'd1;
    assign _e_7873 = _e_2019[4:0] == 5'd0;
    localparam[0:0] _e_7874 = 1;
    assign _e_7875 = _e_7873 && _e_7874;
    assign _e_7876 = _e_7870 && _e_7875;
    assign _e_2025 = \op_a  + \b ;
    assign _e_2024 = _e_2025[31:0];
    assign _e_2023 = {1'd1, _e_2024};
    assign _e_2030 = \trig [36:0];
    assign _e_2028 = _e_2030[36:32];
    assign b_n1 = _e_2030[31:0];
    assign _e_7878 = \trig [37] == 1'd1;
    assign _e_7881 = _e_2028[4:0] == 5'd1;
    localparam[0:0] _e_7882 = 1;
    assign _e_7883 = _e_7881 && _e_7882;
    assign _e_7884 = _e_7878 && _e_7883;
    assign _e_2034 = \op_a  - b_n1;
    assign _e_2033 = _e_2034[31:0];
    assign _e_2032 = {1'd1, _e_2033};
    assign _e_2039 = \trig [36:0];
    assign _e_2037 = _e_2039[36:32];
    assign b_n2 = _e_2039[31:0];
    assign _e_7886 = \trig [37] == 1'd1;
    assign _e_7889 = _e_2037[4:0] == 5'd2;
    localparam[0:0] _e_7890 = 1;
    assign _e_7891 = _e_7889 && _e_7890;
    assign _e_7892 = _e_7886 && _e_7891;
    assign _e_2042 = \op_a  & b_n2;
    assign _e_2041 = {1'd1, _e_2042};
    assign _e_2047 = \trig [36:0];
    assign _e_2045 = _e_2047[36:32];
    assign b_n3 = _e_2047[31:0];
    assign _e_7894 = \trig [37] == 1'd1;
    assign _e_7897 = _e_2045[4:0] == 5'd3;
    localparam[0:0] _e_7898 = 1;
    assign _e_7899 = _e_7897 && _e_7898;
    assign _e_7900 = _e_7894 && _e_7899;
    assign _e_2050 = \op_a  | b_n3;
    assign _e_2049 = {1'd1, _e_2050};
    assign _e_2055 = \trig [36:0];
    assign _e_2053 = _e_2055[36:32];
    assign b_n4 = _e_2055[31:0];
    assign _e_7902 = \trig [37] == 1'd1;
    assign _e_7905 = _e_2053[4:0] == 5'd4;
    localparam[0:0] _e_7906 = 1;
    assign _e_7907 = _e_7905 && _e_7906;
    assign _e_7908 = _e_7902 && _e_7907;
    assign _e_2058 = ~b_n4;
    assign _e_2057 = {1'd1, _e_2058};
    assign _e_2062 = \trig [36:0];
    assign _e_2060 = _e_2062[36:32];
    assign b_n5 = _e_2062[31:0];
    assign _e_7910 = \trig [37] == 1'd1;
    assign _e_7913 = _e_2060[4:0] == 5'd5;
    localparam[0:0] _e_7914 = 1;
    assign _e_7915 = _e_7913 && _e_7914;
    assign _e_7916 = _e_7910 && _e_7915;
    assign _e_2065 = \op_a  ^ b_n5;
    assign _e_2064 = {1'd1, _e_2065};
    assign _e_2070 = \trig [36:0];
    assign _e_2068 = _e_2070[36:32];
    assign b_n6 = _e_2070[31:0];
    assign _e_7918 = \trig [37] == 1'd1;
    assign _e_7921 = _e_2068[4:0] == 5'd6;
    localparam[0:0] _e_7922 = 1;
    assign _e_7923 = _e_7921 && _e_7922;
    assign _e_7924 = _e_7918 && _e_7923;
    assign _e_2074 = \op_a  << b_n6;
    assign _e_2073 = _e_2074[31:0];
    assign _e_2072 = {1'd1, _e_2073};
    assign _e_2079 = \trig [36:0];
    assign _e_2077 = _e_2079[36:32];
    assign b_n7 = _e_2079[31:0];
    assign _e_7926 = \trig [37] == 1'd1;
    assign _e_7929 = _e_2077[4:0] == 5'd7;
    localparam[0:0] _e_7930 = 1;
    assign _e_7931 = _e_7929 && _e_7930;
    assign _e_7932 = _e_7926 && _e_7931;
    assign _e_2083 = \op_a  >> b_n7;
    assign _e_2082 = _e_2083[31:0];
    assign _e_2081 = {1'd1, _e_2082};
    assign _e_2088 = \trig [36:0];
    assign _e_2086 = _e_2088[36:32];
    assign b_n8 = _e_2088[31:0];
    assign _e_7934 = \trig [37] == 1'd1;
    assign _e_7937 = _e_2086[4:0] == 5'd8;
    localparam[0:0] _e_7938 = 1;
    assign _e_7939 = _e_7937 && _e_7938;
    assign _e_7940 = _e_7934 && _e_7939;
    (* src = "src/alu.spade:38,40" *)
    \tta::alu::ashr32  ashr32_0(.x_i(\op_a ), .sh_i(b_n8), .output__(_e_2091));
    assign _e_2090 = {1'd1, _e_2091};
    assign _e_2096 = \trig [36:0];
    assign _e_2094 = _e_2096[36:32];
    assign b_n9 = _e_2096[31:0];
    assign _e_7942 = \trig [37] == 1'd1;
    assign _e_7945 = _e_2094[4:0] == 5'd9;
    localparam[0:0] _e_7946 = 1;
    assign _e_7947 = _e_7945 && _e_7946;
    assign _e_7948 = _e_7942 && _e_7947;
    (* src = "src/alu.spade:39,40" *)
    \tta::alu::rotl32  rotl32_0(.x_i(\op_a ), .sh32_i(b_n9), .output__(_e_2099));
    assign _e_2098 = {1'd1, _e_2099};
    assign _e_2104 = \trig [36:0];
    assign _e_2102 = _e_2104[36:32];
    assign b_n10 = _e_2104[31:0];
    assign _e_7950 = \trig [37] == 1'd1;
    assign _e_7953 = _e_2102[4:0] == 5'd10;
    localparam[0:0] _e_7954 = 1;
    assign _e_7955 = _e_7953 && _e_7954;
    assign _e_7956 = _e_7950 && _e_7955;
    (* src = "src/alu.spade:40,40" *)
    \tta::alu::rotr32  rotr32_0(.x_i(\op_a ), .sh32_i(b_n10), .output__(_e_2107));
    assign _e_2106 = {1'd1, _e_2107};
    assign _e_2112 = \trig [36:0];
    assign _e_2110 = _e_2112[36:32];
    assign b_n11 = _e_2112[31:0];
    assign _e_7958 = \trig [37] == 1'd1;
    assign _e_7961 = _e_2110[4:0] == 5'd11;
    localparam[0:0] _e_7962 = 1;
    assign _e_7963 = _e_7961 && _e_7962;
    assign _e_7964 = _e_7958 && _e_7963;
    assign _e_2116 = \op_a  < b_n11;
    assign _e_2115 = _e_2116 ? \op_a  : b_n11;
    assign _e_2114 = {1'd1, _e_2115};
    assign _e_2125 = \trig [36:0];
    assign _e_2123 = _e_2125[36:32];
    assign b_n12 = _e_2125[31:0];
    assign _e_7966 = \trig [37] == 1'd1;
    assign _e_7969 = _e_2123[4:0] == 5'd12;
    localparam[0:0] _e_7970 = 1;
    assign _e_7971 = _e_7969 && _e_7970;
    assign _e_7972 = _e_7966 && _e_7971;
    assign _e_2129 = \op_a  > b_n12;
    assign _e_2128 = _e_2129 ? \op_a  : b_n12;
    assign _e_2127 = {1'd1, _e_2128};
    assign _e_2138 = \trig [36:0];
    assign _e_2136 = _e_2138[36:32];
    assign b_n13 = _e_2138[31:0];
    assign _e_7974 = \trig [37] == 1'd1;
    assign _e_7977 = _e_2136[4:0] == 5'd13;
    localparam[0:0] _e_7978 = 1;
    assign _e_7979 = _e_7977 && _e_7978;
    assign _e_7980 = _e_7974 && _e_7979;
    (* src = "src/alu.spade:47,41" *)
    \tta::alu::sadd32  sadd32_0(.a_u_i(\op_a ), .b_u_i(b_n13), .output__(_e_2141));
    assign _e_2140 = {1'd1, _e_2141};
    assign _e_2146 = \trig [36:0];
    assign _e_2144 = _e_2146[36:32];
    assign b_n14 = _e_2146[31:0];
    assign _e_7982 = \trig [37] == 1'd1;
    assign _e_7985 = _e_2144[4:0] == 5'd14;
    localparam[0:0] _e_7986 = 1;
    assign _e_7987 = _e_7985 && _e_7986;
    assign _e_7988 = _e_7982 && _e_7987;
    (* src = "src/alu.spade:48,41" *)
    \tta::alu::ssub32  ssub32_0(.a_u_i(\op_a ), .b_u_i(b_n14), .output__(_e_2149));
    assign _e_2148 = {1'd1, _e_2149};
    assign _e_2154 = \trig [36:0];
    assign _e_2152 = _e_2154[36:32];
    assign b_n15 = _e_2154[31:0];
    assign _e_7990 = \trig [37] == 1'd1;
    assign _e_7993 = _e_2152[4:0] == 5'd15;
    localparam[0:0] _e_7994 = 1;
    assign _e_7995 = _e_7993 && _e_7994;
    assign _e_7996 = _e_7990 && _e_7995;
    (* src = "src/alu.spade:51,41" *)
    \tta::alu::uadd32  uadd32_0(.a_i(\op_a ), .b_i(b_n15), .output__(_e_2157));
    assign _e_2156 = {1'd1, _e_2157};
    assign _e_2162 = \trig [36:0];
    assign _e_2160 = _e_2162[36:32];
    assign b_n16 = _e_2162[31:0];
    assign _e_7998 = \trig [37] == 1'd1;
    assign _e_8001 = _e_2160[4:0] == 5'd16;
    localparam[0:0] _e_8002 = 1;
    assign _e_8003 = _e_8001 && _e_8002;
    assign _e_8004 = _e_7998 && _e_8003;
    (* src = "src/alu.spade:52,41" *)
    \tta::alu::usub32  usub32_0(.a_i(\op_a ), .b_i(b_n16), .output__(_e_2165));
    assign _e_2164 = {1'd1, _e_2165};
    assign _e_8006 = \trig [37] == 1'd0;
    assign _e_2169 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_7876, _e_7884, _e_7892, _e_7900, _e_7908, _e_7916, _e_7924, _e_7932, _e_7940, _e_7948, _e_7956, _e_7964, _e_7972, _e_7980, _e_7988, _e_7996, _e_8004, _e_8006})
            18'b1?????????????????: \result  = _e_2023;
            18'b01????????????????: \result  = _e_2032;
            18'b001???????????????: \result  = _e_2041;
            18'b0001??????????????: \result  = _e_2049;
            18'b00001?????????????: \result  = _e_2057;
            18'b000001????????????: \result  = _e_2064;
            18'b0000001???????????: \result  = _e_2072;
            18'b00000001??????????: \result  = _e_2081;
            18'b000000001?????????: \result  = _e_2090;
            18'b0000000001????????: \result  = _e_2098;
            18'b00000000001???????: \result  = _e_2106;
            18'b000000000001??????: \result  = _e_2114;
            18'b0000000000001?????: \result  = _e_2127;
            18'b00000000000001????: \result  = _e_2140;
            18'b000000000000001???: \result  = _e_2148;
            18'b0000000000000001??: \result  = _e_2156;
            18'b00000000000000001?: \result  = _e_2164;
            18'b000000000000000001: \result  = _e_2169;
            18'b?: \result  = 33'dx;
        endcase
    end
    assign _e_2174 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_2174;
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
    logic[31:0] _e_2179;
    logic[31:0] _e_2181;
    (* src = "src/alu.spade:69,25" *)
    logic[32:0] \sum ;
    (* src = "src/alu.spade:72,8" *)
    logic _e_2185;
    (* src = "src/alu.spade:75,9" *)
    logic[31:0] _e_2191;
    (* src = "src/alu.spade:72,5" *)
    logic[31:0] _e_2184;
    assign _e_2179 = \a ;
    assign _e_2181 = \b ;
    assign \sum  = _e_2179 + _e_2181;
    localparam[32:0] _e_2187 = 33'd4294967295;
    assign _e_2185 = \sum  > _e_2187;
    localparam[31:0] _e_2189 = 32'd4294967295;
    assign _e_2191 = \sum [31:0];
    assign _e_2184 = _e_2185 ? _e_2189 : _e_2191;
    assign output__ = _e_2184;
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
    logic _e_2195;
    (* src = "src/alu.spade:84,15" *)
    logic[32:0] _e_2202;
    (* src = "src/alu.spade:84,9" *)
    logic[31:0] _e_2201;
    (* src = "src/alu.spade:81,5" *)
    logic[31:0] _e_2194;
    assign _e_2195 = \a  < \b ;
    localparam[31:0] _e_2199 = 32'd0;
    assign _e_2202 = \a  - \b ;
    assign _e_2201 = _e_2202[31:0];
    assign _e_2194 = _e_2195 ? _e_2199 : _e_2201;
    assign output__ = _e_2194;
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
    logic _e_2223;
    (* src = "src/alu.spade:107,15" *)
    logic _e_2229;
    (* src = "src/alu.spade:111,28" *)
    logic[31:0] sum_n1;
    (* src = "src/alu.spade:112,9" *)
    logic[31:0] _e_2238;
    (* src = "src/alu.spade:107,12" *)
    logic[31:0] _e_2228;
    (* src = "src/alu.spade:105,5" *)
    logic[31:0] _e_2222;
    (* src = "src/alu.spade:94,22" *)
    \std::conv::impl_4::to_int[2137]  to_int_0(.self_i(\a_u ), .output__(\a ));
    (* src = "src/alu.spade:95,22" *)
    \std::conv::impl_4::to_int[2137]  to_int_1(.self_i(\b_u ), .output__(\b ));
    assign \a_big  = {\a [31], \a };
    assign \b_big  = {\b [31], \b };
    assign \sum  = $signed(\a_big ) + $signed(\b_big );
    localparam[33:0] _e_2225 = 34'd2147483647;
    assign _e_2223 = $signed(\sum ) > $signed(_e_2225);
    localparam[31:0] _e_2227 = 32'd2147483647;
    localparam[33:0] _e_2231 = -34'd2147483648;
    assign _e_2229 = $signed(\sum ) < $signed(_e_2231);
    localparam[31:0] _e_2233 = 32'd2147483648;
    assign sum_n1 = \sum [31:0];
    (* src = "src/alu.spade:112,9" *)
    \std::conv::impl_3::to_uint[2138]  to_uint_0(.self_i(sum_n1), .output__(_e_2238));
    assign _e_2228 = _e_2229 ? _e_2233 : _e_2238;
    assign _e_2222 = _e_2223 ? _e_2227 : _e_2228;
    assign output__ = _e_2222;
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
    logic _e_2258;
    (* src = "src/alu.spade:126,15" *)
    logic _e_2264;
    (* src = "src/alu.spade:129,35" *)
    logic[31:0] \trunc_diff ;
    (* src = "src/alu.spade:130,9" *)
    logic[31:0] _e_2273;
    (* src = "src/alu.spade:126,12" *)
    logic[31:0] _e_2263;
    (* src = "src/alu.spade:124,5" *)
    logic[31:0] _e_2257;
    (* src = "src/alu.spade:117,22" *)
    \std::conv::impl_4::to_int[2137]  to_int_0(.self_i(\a_u ), .output__(\a ));
    (* src = "src/alu.spade:118,22" *)
    \std::conv::impl_4::to_int[2137]  to_int_1(.self_i(\b_u ), .output__(\b ));
    assign \a_big  = {\a [31], \a };
    assign \b_big  = {\b [31], \b };
    assign \diff  = $signed(\a_big ) - $signed(\b_big );
    localparam[33:0] _e_2260 = 34'd2147483647;
    assign _e_2258 = $signed(\diff ) > $signed(_e_2260);
    localparam[31:0] _e_2262 = 32'd2147483647;
    localparam[33:0] _e_2266 = -34'd2147483648;
    assign _e_2264 = $signed(\diff ) < $signed(_e_2266);
    localparam[31:0] _e_2268 = 32'd2147483648;
    assign \trunc_diff  = \diff [31:0];
    (* src = "src/alu.spade:130,9" *)
    \std::conv::impl_3::to_uint[2138]  to_uint_0(.self_i(\trunc_diff ), .output__(_e_2273));
    assign _e_2263 = _e_2264 ? _e_2268 : _e_2273;
    assign _e_2257 = _e_2258 ? _e_2262 : _e_2263;
    assign output__ = _e_2257;
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
    logic[31:0] _e_2283;
    (* src = "src/alu.spade:139,26" *)
    logic \sign1 ;
    logic[30:0] _e_2289;
    (* src = "src/alu.spade:140,30" *)
    logic[31:0] \signmask ;
    (* src = "src/alu.spade:141,33" *)
    logic _e_2293;
    (* src = "src/alu.spade:141,62" *)
    logic[32:0] _e_2301;
    (* src = "src/alu.spade:141,73" *)
    logic[32:0] _e_2304;
    (* src = "src/alu.spade:141,62" *)
    logic[32:0] _e_2300;
    (* src = "src/alu.spade:141,56" *)
    logic[31:0] _e_2299;
    (* src = "src/alu.spade:141,30" *)
    logic[31:0] \top_mask ;
    (* src = "src/alu.spade:142,26" *)
    logic[31:0] \fill ;
    (* src = "src/alu.spade:143,5" *)
    logic[31:0] _e_2312;
    assign \sh32  = \sh ;
    assign \logical  = \x  >> \sh32 ;
    localparam[31:0] _e_2285 = 32'd31;
    assign _e_2283 = \x  >> _e_2285;
    assign \sign1  = _e_2283[0:0];
    localparam[30:0] _e_2288 = 0;
    assign _e_2289 = {30'b0, \sign1 };
    assign \signmask  = _e_2288 - _e_2289;
    localparam[31:0] _e_2295 = 32'd0;
    assign _e_2293 = \sh  == _e_2295;
    localparam[31:0] _e_2297 = 32'd0;
    localparam[31:0] _e_2302 = 32'd0;
    localparam[31:0] _e_2303 = 32'd1;
    assign _e_2301 = _e_2302 - _e_2303;
    localparam[31:0] _e_2305 = 32'd32;
    assign _e_2304 = _e_2305 - \sh ;
    assign _e_2300 = _e_2301 << _e_2304;
    assign _e_2299 = _e_2300[31:0];
    assign \top_mask  = _e_2293 ? _e_2297 : _e_2299;
    assign \fill  = \signmask  & \top_mask ;
    assign _e_2312 = \logical  | \fill ;
    assign output__ = _e_2312;
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
    logic _e_2317;
    (* src = "src/alu.spade:148,26" *)
    logic[31:0] \left ;
    (* src = "src/alu.spade:149,36" *)
    logic[32:0] _e_2328;
    (* src = "src/alu.spade:149,30" *)
    logic[31:0] \inverted ;
    (* src = "src/alu.spade:150,27" *)
    logic[31:0] \right ;
    (* src = "src/alu.spade:151,5" *)
    logic[31:0] _e_2336;
    (* src = "src/alu.spade:147,3" *)
    logic[31:0] _e_2316;
    localparam[31:0] _e_2319 = 32'd0;
    assign _e_2317 = \sh32  == _e_2319;
    assign \left  = \x  << \sh32 ;
    localparam[31:0] _e_2329 = 32'd32;
    assign _e_2328 = _e_2329 - \sh32 ;
    assign \inverted  = _e_2328[31:0];
    assign \right  = \x  >> \inverted ;
    assign _e_2336 = \left  | \right ;
    assign _e_2316 = _e_2317 ? \x  : _e_2336;
    assign output__ = _e_2316;
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
    logic _e_2341;
    (* src = "src/alu.spade:157,27" *)
    logic[31:0] \right ;
    (* src = "src/alu.spade:158,36" *)
    logic[32:0] _e_2352;
    (* src = "src/alu.spade:158,30" *)
    logic[31:0] \inverted ;
    (* src = "src/alu.spade:159,27" *)
    logic[31:0] \left ;
    (* src = "src/alu.spade:160,5" *)
    logic[31:0] _e_2360;
    (* src = "src/alu.spade:156,3" *)
    logic[31:0] _e_2340;
    localparam[31:0] _e_2343 = 32'd0;
    assign _e_2341 = \sh32  == _e_2343;
    assign \right  = \x  >> \sh32 ;
    localparam[31:0] _e_2353 = 32'd32;
    assign _e_2352 = _e_2353 - \sh32 ;
    assign \inverted  = _e_2352[31:0];
    assign \left  = \x  << \inverted ;
    assign _e_2360 = \right  | \left ;
    assign _e_2340 = _e_2341 ? \x  : _e_2360;
    assign output__ = _e_2340;
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
    logic[42:0] _e_2367;
    (* src = "src/alu.spade:166,14" *)
    logic[31:0] \x ;
    logic _e_8008;
    logic _e_8010;
    logic _e_8012;
    logic _e_8013;
    (* src = "src/alu.spade:166,35" *)
    logic[32:0] _e_2369;
    (* src = "src/alu.spade:167,9" *)
    logic[43:0] \_ ;
    (* src = "src/alu.spade:168,13" *)
    logic[42:0] _e_2375;
    (* src = "src/alu.spade:168,18" *)
    logic[31:0] x_n1;
    logic _e_8016;
    logic _e_8018;
    logic _e_8020;
    logic _e_8021;
    (* src = "src/alu.spade:168,39" *)
    logic[32:0] _e_2377;
    (* src = "src/alu.spade:169,13" *)
    logic[43:0] __n1;
    (* src = "src/alu.spade:169,18" *)
    logic[32:0] _e_2380;
    (* src = "src/alu.spade:167,14" *)
    logic[32:0] _e_2372;
    (* src = "src/alu.spade:165,5" *)
    logic[32:0] _e_2364;
    assign _e_2367 = \m1 [42:0];
    assign \x  = _e_2367[36:5];
    assign _e_8008 = \m1 [43] == 1'd1;
    assign _e_8010 = _e_2367[42:37] == 6'd1;
    localparam[0:0] _e_8011 = 1;
    assign _e_8012 = _e_8010 && _e_8011;
    assign _e_8013 = _e_8008 && _e_8012;
    assign _e_2369 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8014 = 1;
    assign _e_2375 = \m0 [42:0];
    assign x_n1 = _e_2375[36:5];
    assign _e_8016 = \m0 [43] == 1'd1;
    assign _e_8018 = _e_2375[42:37] == 6'd1;
    localparam[0:0] _e_8019 = 1;
    assign _e_8020 = _e_8018 && _e_8019;
    assign _e_8021 = _e_8016 && _e_8020;
    assign _e_2377 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8022 = 1;
    assign _e_2380 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8021, _e_8022})
            2'b1?: _e_2372 = _e_2377;
            2'b01: _e_2372 = _e_2380;
            2'b?: _e_2372 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8013, _e_8014})
            2'b1?: _e_2364 = _e_2369;
            2'b01: _e_2364 = _e_2372;
            2'b?: _e_2364 = 33'dx;
        endcase
    end
    assign output__ = _e_2364;
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
    logic[42:0] _e_2386;
    (* src = "src/alu.spade:175,14" *)
    logic[4:0] \op ;
    (* src = "src/alu.spade:175,14" *)
    logic[31:0] \x ;
    logic _e_8024;
    logic _e_8026;
    logic _e_8029;
    logic _e_8030;
    logic _e_8031;
    (* src = "src/alu.spade:175,44" *)
    logic[36:0] _e_2389;
    (* src = "src/alu.spade:175,39" *)
    logic[37:0] _e_2388;
    (* src = "src/alu.spade:176,9" *)
    logic[43:0] \_ ;
    (* src = "src/alu.spade:177,13" *)
    logic[42:0] _e_2397;
    (* src = "src/alu.spade:177,18" *)
    logic[4:0] op_n1;
    (* src = "src/alu.spade:177,18" *)
    logic[31:0] x_n1;
    logic _e_8034;
    logic _e_8036;
    logic _e_8039;
    logic _e_8040;
    logic _e_8041;
    (* src = "src/alu.spade:177,48" *)
    logic[36:0] _e_2400;
    (* src = "src/alu.spade:177,43" *)
    logic[37:0] _e_2399;
    (* src = "src/alu.spade:178,13" *)
    logic[43:0] __n1;
    (* src = "src/alu.spade:178,18" *)
    logic[37:0] _e_2404;
    (* src = "src/alu.spade:176,14" *)
    logic[37:0] _e_2393;
    (* src = "src/alu.spade:174,5" *)
    logic[37:0] _e_2382;
    assign _e_2386 = \m1 [42:0];
    assign \op  = _e_2386[36:32];
    assign \x  = _e_2386[31:0];
    assign _e_8024 = \m1 [43] == 1'd1;
    assign _e_8026 = _e_2386[42:37] == 6'd2;
    localparam[0:0] _e_8027 = 1;
    localparam[0:0] _e_8028 = 1;
    assign _e_8029 = _e_8026 && _e_8027;
    assign _e_8030 = _e_8029 && _e_8028;
    assign _e_8031 = _e_8024 && _e_8030;
    assign _e_2389 = {\op , \x };
    assign _e_2388 = {1'd1, _e_2389};
    assign \_  = \m1 ;
    localparam[0:0] _e_8032 = 1;
    assign _e_2397 = \m0 [42:0];
    assign op_n1 = _e_2397[36:32];
    assign x_n1 = _e_2397[31:0];
    assign _e_8034 = \m0 [43] == 1'd1;
    assign _e_8036 = _e_2397[42:37] == 6'd2;
    localparam[0:0] _e_8037 = 1;
    localparam[0:0] _e_8038 = 1;
    assign _e_8039 = _e_8036 && _e_8037;
    assign _e_8040 = _e_8039 && _e_8038;
    assign _e_8041 = _e_8034 && _e_8040;
    assign _e_2400 = {op_n1, x_n1};
    assign _e_2399 = {1'd1, _e_2400};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8042 = 1;
    assign _e_2404 = {1'd0, 37'bX};
    always_comb begin
        priority casez ({_e_8041, _e_8042})
            2'b1?: _e_2393 = _e_2399;
            2'b01: _e_2393 = _e_2404;
            2'b?: _e_2393 = 38'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8031, _e_8032})
            2'b1?: _e_2382 = _e_2388;
            2'b01: _e_2382 = _e_2393;
            2'b?: _e_2382 = 38'dx;
        endcase
    end
    assign output__ = _e_2382;
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
    logic _e_8044;
    logic _e_8046;
    logic _e_8048;
    (* src = "src/modadd.spade:19,45" *)
    logic[31:0] _e_2410;
    (* src = "src/modadd.spade:19,14" *)
    reg[31:0] \base ;
    (* src = "src/modadd.spade:25,9" *)
    logic[31:0] v_n1;
    logic _e_8050;
    logic _e_8052;
    logic _e_8054;
    (* src = "src/modadd.spade:24,45" *)
    logic[31:0] _e_2421;
    (* src = "src/modadd.spade:24,14" *)
    reg[31:0] \mask ;
    (* src = "src/modadd.spade:34,13" *)
    logic[31:0] v_n2;
    logic _e_8056;
    logic _e_8058;
    logic _e_8060;
    (* src = "src/modadd.spade:33,27" *)
    logic[31:0] \current_ptr ;
    (* src = "src/modadd.spade:39,13" *)
    logic[31:0] \stride ;
    logic _e_8062;
    logic _e_8064;
    (* src = "src/modadd.spade:42,36" *)
    logic[32:0] _e_2448;
    (* src = "src/modadd.spade:42,30" *)
    logic[31:0] _e_2447;
    (* src = "src/modadd.spade:42,30" *)
    logic[31:0] \offset ;
    (* src = "src/modadd.spade:43,17" *)
    logic[31:0] _e_2453;
    logic _e_8066;
    (* src = "src/modadd.spade:38,9" *)
    logic[31:0] _e_2441;
    (* src = "src/modadd.spade:32,14" *)
    reg[31:0] \ptr ;
    (* src = "src/modadd.spade:51,47" *)
    logic[32:0] _e_2461;
    (* src = "src/modadd.spade:53,13" *)
    logic[31:0] v_n3;
    logic _e_8068;
    logic _e_8070;
    logic _e_8072;
    (* src = "src/modadd.spade:52,27" *)
    logic[31:0] current_ptr_n1;
    (* src = "src/modadd.spade:58,13" *)
    logic[31:0] stride_n1;
    logic _e_8074;
    logic _e_8076;
    (* src = "src/modadd.spade:59,36" *)
    logic[32:0] _e_2478;
    (* src = "src/modadd.spade:59,30" *)
    logic[31:0] _e_2477;
    (* src = "src/modadd.spade:59,30" *)
    logic[31:0] offset_n1;
    (* src = "src/modadd.spade:60,22" *)
    logic[31:0] _e_2484;
    (* src = "src/modadd.spade:60,17" *)
    logic[32:0] _e_2483;
    logic _e_8078;
    (* src = "src/modadd.spade:62,21" *)
    logic[32:0] _e_2488;
    (* src = "src/modadd.spade:57,9" *)
    logic[32:0] _e_2471;
    (* src = "src/modadd.spade:51,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_2409 = 32'd0;
    assign \v  = \set_base [31:0];
    assign _e_8044 = \set_base [32] == 1'd1;
    localparam[0:0] _e_8045 = 1;
    assign _e_8046 = _e_8044 && _e_8045;
    assign _e_8048 = \set_base [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8046, _e_8048})
            2'b1?: _e_2410 = \v ;
            2'b01: _e_2410 = \base ;
            2'b?: _e_2410 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \base  <= _e_2409;
        end
        else begin
            \base  <= _e_2410;
        end
    end
    localparam[31:0] _e_2420 = 32'd0;
    assign v_n1 = \set_mask [31:0];
    assign _e_8050 = \set_mask [32] == 1'd1;
    localparam[0:0] _e_8051 = 1;
    assign _e_8052 = _e_8050 && _e_8051;
    assign _e_8054 = \set_mask [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8052, _e_8054})
            2'b1?: _e_2421 = v_n1;
            2'b01: _e_2421 = \mask ;
            2'b?: _e_2421 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \mask  <= _e_2420;
        end
        else begin
            \mask  <= _e_2421;
        end
    end
    localparam[31:0] _e_2431 = 32'd0;
    assign v_n2 = \set_ptr [31:0];
    assign _e_8056 = \set_ptr [32] == 1'd1;
    localparam[0:0] _e_8057 = 1;
    assign _e_8058 = _e_8056 && _e_8057;
    assign _e_8060 = \set_ptr [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8058, _e_8060})
            2'b1?: \current_ptr  = v_n2;
            2'b01: \current_ptr  = \ptr ;
            2'b?: \current_ptr  = 32'dx;
        endcase
    end
    assign \stride  = \trig_stride [31:0];
    assign _e_8062 = \trig_stride [32] == 1'd1;
    localparam[0:0] _e_8063 = 1;
    assign _e_8064 = _e_8062 && _e_8063;
    assign _e_2448 = \current_ptr  + \stride ;
    assign _e_2447 = _e_2448[31:0];
    assign \offset  = _e_2447 & \mask ;
    assign _e_2453 = \base  | \offset ;
    assign _e_8066 = \trig_stride [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8064, _e_8066})
            2'b1?: _e_2441 = _e_2453;
            2'b01: _e_2441 = \current_ptr ;
            2'b?: _e_2441 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \ptr  <= _e_2431;
        end
        else begin
            \ptr  <= _e_2441;
        end
    end
    assign _e_2461 = {1'd0, 32'bX};
    assign v_n3 = \set_ptr [31:0];
    assign _e_8068 = \set_ptr [32] == 1'd1;
    localparam[0:0] _e_8069 = 1;
    assign _e_8070 = _e_8068 && _e_8069;
    assign _e_8072 = \set_ptr [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8070, _e_8072})
            2'b1?: current_ptr_n1 = v_n3;
            2'b01: current_ptr_n1 = \ptr ;
            2'b?: current_ptr_n1 = 32'dx;
        endcase
    end
    assign stride_n1 = \trig_stride [31:0];
    assign _e_8074 = \trig_stride [32] == 1'd1;
    localparam[0:0] _e_8075 = 1;
    assign _e_8076 = _e_8074 && _e_8075;
    assign _e_2478 = current_ptr_n1 + stride_n1;
    assign _e_2477 = _e_2478[31:0];
    assign offset_n1 = _e_2477 & \mask ;
    assign _e_2484 = \base  | offset_n1;
    assign _e_2483 = {1'd1, _e_2484};
    assign _e_8078 = \trig_stride [32] == 1'd0;
    assign _e_2488 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8076, _e_8078})
            2'b1?: _e_2471 = _e_2483;
            2'b01: _e_2471 = _e_2488;
            2'b?: _e_2471 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_2461;
        end
        else begin
            \res  <= _e_2471;
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
    logic[42:0] _e_2494;
    (* src = "src/modadd.spade:71,14" *)
    logic[31:0] \a ;
    logic _e_8080;
    logic _e_8082;
    logic _e_8084;
    logic _e_8085;
    (* src = "src/modadd.spade:71,35" *)
    logic[32:0] _e_2496;
    (* src = "src/modadd.spade:72,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:72,25" *)
    logic[42:0] _e_2502;
    (* src = "src/modadd.spade:72,30" *)
    logic[31:0] a_n1;
    logic _e_8088;
    logic _e_8090;
    logic _e_8092;
    logic _e_8093;
    (* src = "src/modadd.spade:72,51" *)
    logic[32:0] _e_2504;
    (* src = "src/modadd.spade:72,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:72,65" *)
    logic[32:0] _e_2507;
    (* src = "src/modadd.spade:72,14" *)
    logic[32:0] _e_2499;
    (* src = "src/modadd.spade:70,5" *)
    logic[32:0] _e_2491;
    assign _e_2494 = \m1 [42:0];
    assign \a  = _e_2494[36:5];
    assign _e_8080 = \m1 [43] == 1'd1;
    assign _e_8082 = _e_2494[42:37] == 6'd30;
    localparam[0:0] _e_8083 = 1;
    assign _e_8084 = _e_8082 && _e_8083;
    assign _e_8085 = _e_8080 && _e_8084;
    assign _e_2496 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8086 = 1;
    assign _e_2502 = \m0 [42:0];
    assign a_n1 = _e_2502[36:5];
    assign _e_8088 = \m0 [43] == 1'd1;
    assign _e_8090 = _e_2502[42:37] == 6'd30;
    localparam[0:0] _e_8091 = 1;
    assign _e_8092 = _e_8090 && _e_8091;
    assign _e_8093 = _e_8088 && _e_8092;
    assign _e_2504 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8094 = 1;
    assign _e_2507 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8093, _e_8094})
            2'b1?: _e_2499 = _e_2504;
            2'b01: _e_2499 = _e_2507;
            2'b?: _e_2499 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8085, _e_8086})
            2'b1?: _e_2491 = _e_2496;
            2'b01: _e_2491 = _e_2499;
            2'b?: _e_2491 = 33'dx;
        endcase
    end
    assign output__ = _e_2491;
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
    logic[42:0] _e_2512;
    (* src = "src/modadd.spade:78,14" *)
    logic[31:0] \a ;
    logic _e_8096;
    logic _e_8098;
    logic _e_8100;
    logic _e_8101;
    (* src = "src/modadd.spade:78,35" *)
    logic[32:0] _e_2514;
    (* src = "src/modadd.spade:79,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:79,25" *)
    logic[42:0] _e_2520;
    (* src = "src/modadd.spade:79,30" *)
    logic[31:0] a_n1;
    logic _e_8104;
    logic _e_8106;
    logic _e_8108;
    logic _e_8109;
    (* src = "src/modadd.spade:79,51" *)
    logic[32:0] _e_2522;
    (* src = "src/modadd.spade:79,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:79,65" *)
    logic[32:0] _e_2525;
    (* src = "src/modadd.spade:79,14" *)
    logic[32:0] _e_2517;
    (* src = "src/modadd.spade:77,5" *)
    logic[32:0] _e_2509;
    assign _e_2512 = \m1 [42:0];
    assign \a  = _e_2512[36:5];
    assign _e_8096 = \m1 [43] == 1'd1;
    assign _e_8098 = _e_2512[42:37] == 6'd31;
    localparam[0:0] _e_8099 = 1;
    assign _e_8100 = _e_8098 && _e_8099;
    assign _e_8101 = _e_8096 && _e_8100;
    assign _e_2514 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8102 = 1;
    assign _e_2520 = \m0 [42:0];
    assign a_n1 = _e_2520[36:5];
    assign _e_8104 = \m0 [43] == 1'd1;
    assign _e_8106 = _e_2520[42:37] == 6'd31;
    localparam[0:0] _e_8107 = 1;
    assign _e_8108 = _e_8106 && _e_8107;
    assign _e_8109 = _e_8104 && _e_8108;
    assign _e_2522 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8110 = 1;
    assign _e_2525 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8109, _e_8110})
            2'b1?: _e_2517 = _e_2522;
            2'b01: _e_2517 = _e_2525;
            2'b?: _e_2517 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8101, _e_8102})
            2'b1?: _e_2509 = _e_2514;
            2'b01: _e_2509 = _e_2517;
            2'b?: _e_2509 = 33'dx;
        endcase
    end
    assign output__ = _e_2509;
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
    logic[42:0] _e_2530;
    (* src = "src/modadd.spade:85,14" *)
    logic[31:0] \a ;
    logic _e_8112;
    logic _e_8114;
    logic _e_8116;
    logic _e_8117;
    (* src = "src/modadd.spade:85,34" *)
    logic[32:0] _e_2532;
    (* src = "src/modadd.spade:86,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:86,25" *)
    logic[42:0] _e_2538;
    (* src = "src/modadd.spade:86,30" *)
    logic[31:0] a_n1;
    logic _e_8120;
    logic _e_8122;
    logic _e_8124;
    logic _e_8125;
    (* src = "src/modadd.spade:86,50" *)
    logic[32:0] _e_2540;
    (* src = "src/modadd.spade:86,59" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:86,64" *)
    logic[32:0] _e_2543;
    (* src = "src/modadd.spade:86,14" *)
    logic[32:0] _e_2535;
    (* src = "src/modadd.spade:84,5" *)
    logic[32:0] _e_2527;
    assign _e_2530 = \m1 [42:0];
    assign \a  = _e_2530[36:5];
    assign _e_8112 = \m1 [43] == 1'd1;
    assign _e_8114 = _e_2530[42:37] == 6'd32;
    localparam[0:0] _e_8115 = 1;
    assign _e_8116 = _e_8114 && _e_8115;
    assign _e_8117 = _e_8112 && _e_8116;
    assign _e_2532 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8118 = 1;
    assign _e_2538 = \m0 [42:0];
    assign a_n1 = _e_2538[36:5];
    assign _e_8120 = \m0 [43] == 1'd1;
    assign _e_8122 = _e_2538[42:37] == 6'd32;
    localparam[0:0] _e_8123 = 1;
    assign _e_8124 = _e_8122 && _e_8123;
    assign _e_8125 = _e_8120 && _e_8124;
    assign _e_2540 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8126 = 1;
    assign _e_2543 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8125, _e_8126})
            2'b1?: _e_2535 = _e_2540;
            2'b01: _e_2535 = _e_2543;
            2'b?: _e_2535 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8117, _e_8118})
            2'b1?: _e_2527 = _e_2532;
            2'b01: _e_2527 = _e_2535;
            2'b?: _e_2527 = 33'dx;
        endcase
    end
    assign output__ = _e_2527;
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
    logic[42:0] _e_2548;
    (* src = "src/modadd.spade:92,14" *)
    logic[31:0] \a ;
    logic _e_8128;
    logic _e_8130;
    logic _e_8132;
    logic _e_8133;
    (* src = "src/modadd.spade:92,35" *)
    logic[32:0] _e_2550;
    (* src = "src/modadd.spade:93,9" *)
    logic[43:0] \_ ;
    (* src = "src/modadd.spade:93,25" *)
    logic[42:0] _e_2556;
    (* src = "src/modadd.spade:93,30" *)
    logic[31:0] a_n1;
    logic _e_8136;
    logic _e_8138;
    logic _e_8140;
    logic _e_8141;
    (* src = "src/modadd.spade:93,51" *)
    logic[32:0] _e_2558;
    (* src = "src/modadd.spade:93,60" *)
    logic[43:0] __n1;
    (* src = "src/modadd.spade:93,65" *)
    logic[32:0] _e_2561;
    (* src = "src/modadd.spade:93,14" *)
    logic[32:0] _e_2553;
    (* src = "src/modadd.spade:91,5" *)
    logic[32:0] _e_2545;
    assign _e_2548 = \m1 [42:0];
    assign \a  = _e_2548[36:5];
    assign _e_8128 = \m1 [43] == 1'd1;
    assign _e_8130 = _e_2548[42:37] == 6'd33;
    localparam[0:0] _e_8131 = 1;
    assign _e_8132 = _e_8130 && _e_8131;
    assign _e_8133 = _e_8128 && _e_8132;
    assign _e_2550 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8134 = 1;
    assign _e_2556 = \m0 [42:0];
    assign a_n1 = _e_2556[36:5];
    assign _e_8136 = \m0 [43] == 1'd1;
    assign _e_8138 = _e_2556[42:37] == 6'd33;
    localparam[0:0] _e_8139 = 1;
    assign _e_8140 = _e_8138 && _e_8139;
    assign _e_8141 = _e_8136 && _e_8140;
    assign _e_2558 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8142 = 1;
    assign _e_2561 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8141, _e_8142})
            2'b1?: _e_2553 = _e_2558;
            2'b01: _e_2553 = _e_2561;
            2'b?: _e_2553 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8133, _e_8134})
            2'b1?: _e_2545 = _e_2550;
            2'b01: _e_2545 = _e_2553;
            2'b?: _e_2545 = 33'dx;
        endcase
    end
    assign output__ = _e_2545;
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
    logic[32:0] _e_2572;
    (* src = "src/uart_in.spade:13,7" *)
    logic[31:0] \b ;
    logic _e_8144;
    logic _e_8146;
    logic[31:0] _e_2578;
    (* src = "src/uart_in.spade:13,18" *)
    logic[32:0] _e_2577;
    logic _e_8148;
    (* src = "src/uart_in.spade:14,15" *)
    logic[32:0] _e_2581;
    (* src = "src/uart_in.spade:12,56" *)
    logic[32:0] _e_2573;
    (* src = "src/uart_in.spade:12,14" *)
    reg[32:0] data_n1;
    (* src = "src/uart_in.spade:11,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\uart_byte ), .pop_i(\pop ), .output__(\data ));
    assign _e_2572 = {1'd0, 32'bX};
    assign \b  = data_n1[31:0];
    assign _e_8144 = data_n1[32] == 1'd1;
    localparam[0:0] _e_8145 = 1;
    assign _e_8146 = _e_8144 && _e_8145;
    assign _e_2578 = \b ;
    assign _e_2577 = {1'd1, _e_2578};
    assign _e_8148 = data_n1[32] == 1'd0;
    assign _e_2581 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8146, _e_8148})
            2'b1?: _e_2573 = _e_2577;
            2'b01: _e_2573 = _e_2581;
            2'b?: _e_2573 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2572;
        end
        else begin
            data_n1 <= _e_2573;
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
    logic _e_2588;
    (* src = "src/uart_in.spade:33,16" *)
    logic[14:0] \data ;
    (* src = "src/uart_in.spade:34,47" *)
    logic[8:0] _e_2594;
    (* src = "src/uart_in.spade:35,7" *)
    logic[7:0] \b ;
    logic _e_8150;
    logic _e_8152;
    (* src = "src/uart_in.spade:35,18" *)
    logic[8:0] _e_2599;
    logic _e_8154;
    (* src = "src/uart_in.spade:36,15" *)
    logic[8:0] _e_2602;
    (* src = "src/uart_in.spade:34,55" *)
    logic[8:0] _e_2595;
    (* src = "src/uart_in.spade:34,14" *)
    reg[8:0] data_n1;
    assign _e_2588 = !\uart_tx_busy ;
    (* src = "src/uart_in.spade:33,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\byte_to_write ), .pop_i(_e_2588), .output__(\data ));
    assign _e_2594 = {1'd0, 8'bX};
    assign \b  = data_n1[7:0];
    assign _e_8150 = data_n1[8] == 1'd1;
    localparam[0:0] _e_8151 = 1;
    assign _e_8152 = _e_8150 && _e_8151;
    assign _e_2599 = {1'd1, \b };
    assign _e_8154 = data_n1[8] == 1'd0;
    assign _e_2602 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8152, _e_8154})
            2'b1?: _e_2595 = _e_2599;
            2'b01: _e_2595 = _e_2602;
            2'b?: _e_2595 = 9'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2594;
        end
        else begin
            data_n1 <= _e_2595;
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
    logic[42:0] _e_2609;
    logic _e_8156;
    logic _e_8158;
    logic _e_8159;
    (* src = "src/uart_in.spade:46,9" *)
    logic[43:0] \_ ;
    (* src = "src/uart_in.spade:47,13" *)
    logic[42:0] _e_2615;
    logic _e_8162;
    logic _e_8164;
    logic _e_8165;
    (* src = "src/uart_in.spade:48,13" *)
    logic[43:0] __n1;
    (* src = "src/uart_in.spade:46,14" *)
    logic _e_2613;
    (* src = "src/uart_in.spade:44,5" *)
    logic _e_2607;
    assign _e_2609 = \m1 [42:0];
    assign _e_8156 = \m1 [43] == 1'd1;
    assign _e_8158 = _e_2609[42:37] == 6'd41;
    assign _e_8159 = _e_8156 && _e_8158;
    localparam[0:0] _e_2611 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_8160 = 1;
    assign _e_2615 = \m0 [42:0];
    assign _e_8162 = \m0 [43] == 1'd1;
    assign _e_8164 = _e_2615[42:37] == 6'd41;
    assign _e_8165 = _e_8162 && _e_8164;
    localparam[0:0] _e_2617 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_8166 = 1;
    localparam[0:0] _e_2619 = 0;
    always_comb begin
        priority casez ({_e_8165, _e_8166})
            2'b1?: _e_2613 = _e_2617;
            2'b01: _e_2613 = _e_2619;
            2'b?: _e_2613 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8159, _e_8160})
            2'b1?: _e_2607 = _e_2611;
            2'b01: _e_2607 = _e_2613;
            2'b?: _e_2607 = 1'dx;
        endcase
    end
    assign output__ = _e_2607;
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
    logic[42:0] _e_2624;
    (* src = "src/uart_in.spade:54,14" *)
    logic[7:0] \x ;
    logic _e_8168;
    logic _e_8170;
    logic _e_8172;
    logic _e_8173;
    (* src = "src/uart_in.spade:54,36" *)
    logic[8:0] _e_2626;
    (* src = "src/uart_in.spade:55,9" *)
    logic[43:0] \_ ;
    (* src = "src/uart_in.spade:56,13" *)
    logic[42:0] _e_2632;
    (* src = "src/uart_in.spade:56,18" *)
    logic[7:0] x_n1;
    logic _e_8176;
    logic _e_8178;
    logic _e_8180;
    logic _e_8181;
    (* src = "src/uart_in.spade:56,40" *)
    logic[8:0] _e_2634;
    (* src = "src/uart_in.spade:57,13" *)
    logic[43:0] __n1;
    (* src = "src/uart_in.spade:57,18" *)
    logic[8:0] _e_2637;
    (* src = "src/uart_in.spade:55,14" *)
    logic[8:0] _e_2629;
    (* src = "src/uart_in.spade:53,5" *)
    logic[8:0] _e_2621;
    assign _e_2624 = \m1 [42:0];
    assign \x  = _e_2624[36:29];
    assign _e_8168 = \m1 [43] == 1'd1;
    assign _e_8170 = _e_2624[42:37] == 6'd38;
    localparam[0:0] _e_8171 = 1;
    assign _e_8172 = _e_8170 && _e_8171;
    assign _e_8173 = _e_8168 && _e_8172;
    assign _e_2626 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8174 = 1;
    assign _e_2632 = \m0 [42:0];
    assign x_n1 = _e_2632[36:29];
    assign _e_8176 = \m0 [43] == 1'd1;
    assign _e_8178 = _e_2632[42:37] == 6'd38;
    localparam[0:0] _e_8179 = 1;
    assign _e_8180 = _e_8178 && _e_8179;
    assign _e_8181 = _e_8176 && _e_8180;
    assign _e_2634 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8182 = 1;
    assign _e_2637 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8181, _e_8182})
            2'b1?: _e_2629 = _e_2634;
            2'b01: _e_2629 = _e_2637;
            2'b?: _e_2629 = 9'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8173, _e_8174})
            2'b1?: _e_2621 = _e_2626;
            2'b01: _e_2621 = _e_2629;
            2'b?: _e_2621 = 9'dx;
        endcase
    end
    assign output__ = _e_2621;
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
    logic _e_8184;
    logic _e_8186;
    logic _e_8188;
    (* src = "src/cmp.spade:24,42" *)
    logic[31:0] _e_2643;
    (* src = "src/cmp.spade:24,14" *)
    reg[31:0] \a ;
    (* src = "src/cmp.spade:31,9" *)
    logic[34:0] _e_2654;
    (* src = "src/cmp.spade:31,14" *)
    logic[2:0] _e_2652;
    (* src = "src/cmp.spade:31,14" *)
    logic[31:0] \b ;
    logic _e_8190;
    logic _e_8193;
    logic _e_8195;
    logic _e_8196;
    (* src = "src/cmp.spade:31,45" *)
    logic _e_2658;
    (* src = "src/cmp.spade:31,38" *)
    logic[31:0] _e_2657;
    (* src = "src/cmp.spade:31,33" *)
    logic[32:0] _e_2656;
    (* src = "src/cmp.spade:32,9" *)
    logic[34:0] _e_2663;
    (* src = "src/cmp.spade:32,14" *)
    logic[2:0] _e_2661;
    (* src = "src/cmp.spade:32,14" *)
    logic[31:0] b_n1;
    logic _e_8198;
    logic _e_8201;
    logic _e_8203;
    logic _e_8204;
    (* src = "src/cmp.spade:32,46" *)
    logic _e_2667;
    (* src = "src/cmp.spade:32,39" *)
    logic[31:0] _e_2666;
    (* src = "src/cmp.spade:32,34" *)
    logic[32:0] _e_2665;
    (* src = "src/cmp.spade:33,9" *)
    logic[34:0] _e_2672;
    (* src = "src/cmp.spade:33,14" *)
    logic[2:0] _e_2670;
    (* src = "src/cmp.spade:33,14" *)
    logic[31:0] b_n2;
    logic _e_8206;
    logic _e_8209;
    logic _e_8211;
    logic _e_8212;
    (* src = "src/cmp.spade:33,46" *)
    logic _e_2676;
    (* src = "src/cmp.spade:33,39" *)
    logic[31:0] _e_2675;
    (* src = "src/cmp.spade:33,34" *)
    logic[32:0] _e_2674;
    (* src = "src/cmp.spade:34,9" *)
    logic[34:0] _e_2681;
    (* src = "src/cmp.spade:34,14" *)
    logic[2:0] _e_2679;
    (* src = "src/cmp.spade:34,14" *)
    logic[31:0] b_n3;
    logic _e_8214;
    logic _e_8217;
    logic _e_8219;
    logic _e_8220;
    (* src = "src/cmp.spade:34,47" *)
    logic _e_2686;
    (* src = "src/cmp.spade:34,66" *)
    logic _e_2689;
    (* src = "src/cmp.spade:34,47" *)
    logic _e_2685;
    (* src = "src/cmp.spade:34,40" *)
    logic[31:0] _e_2684;
    (* src = "src/cmp.spade:34,35" *)
    logic[32:0] _e_2683;
    (* src = "src/cmp.spade:35,9" *)
    logic[34:0] _e_2694;
    (* src = "src/cmp.spade:35,14" *)
    logic[2:0] _e_2692;
    (* src = "src/cmp.spade:35,14" *)
    logic[31:0] b_n4;
    logic _e_8222;
    logic _e_8225;
    logic _e_8227;
    logic _e_8228;
    (* src = "src/cmp.spade:35,46" *)
    logic _e_2698;
    (* src = "src/cmp.spade:35,39" *)
    logic[31:0] _e_2697;
    (* src = "src/cmp.spade:35,34" *)
    logic[32:0] _e_2696;
    (* src = "src/cmp.spade:36,9" *)
    logic[34:0] _e_2703;
    (* src = "src/cmp.spade:36,14" *)
    logic[2:0] _e_2701;
    (* src = "src/cmp.spade:36,14" *)
    logic[31:0] b_n5;
    logic _e_8230;
    logic _e_8233;
    logic _e_8235;
    logic _e_8236;
    (* src = "src/cmp.spade:36,46" *)
    logic _e_2708;
    (* src = "src/cmp.spade:36,57" *)
    logic _e_2711;
    (* src = "src/cmp.spade:36,46" *)
    logic _e_2707;
    (* src = "src/cmp.spade:36,39" *)
    logic[31:0] _e_2706;
    (* src = "src/cmp.spade:36,34" *)
    logic[32:0] _e_2705;
    logic _e_8238;
    (* src = "src/cmp.spade:37,34" *)
    logic[32:0] _e_2715;
    (* src = "src/cmp.spade:30,36" *)
    logic[32:0] \result ;
    (* src = "src/cmp.spade:41,51" *)
    logic[32:0] _e_2720;
    (* src = "src/cmp.spade:41,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2642 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_8184 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_8185 = 1;
    assign _e_8186 = _e_8184 && _e_8185;
    assign _e_8188 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8186, _e_8188})
            2'b1?: _e_2643 = \v ;
            2'b01: _e_2643 = \a ;
            2'b?: _e_2643 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \a  <= _e_2642;
        end
        else begin
            \a  <= _e_2643;
        end
    end
    assign _e_2654 = \trig [34:0];
    assign _e_2652 = _e_2654[34:32];
    assign \b  = _e_2654[31:0];
    assign _e_8190 = \trig [35] == 1'd1;
    assign _e_8193 = _e_2652[2:0] == 3'd0;
    localparam[0:0] _e_8194 = 1;
    assign _e_8195 = _e_8193 && _e_8194;
    assign _e_8196 = _e_8190 && _e_8195;
    assign _e_2658 = \a  == \b ;
    (* src = "src/cmp.spade:31,38" *)
    \tta::cmp::to_u32  to_u32_0(.x_i(_e_2658), .output__(_e_2657));
    assign _e_2656 = {1'd1, _e_2657};
    assign _e_2663 = \trig [34:0];
    assign _e_2661 = _e_2663[34:32];
    assign b_n1 = _e_2663[31:0];
    assign _e_8198 = \trig [35] == 1'd1;
    assign _e_8201 = _e_2661[2:0] == 3'd1;
    localparam[0:0] _e_8202 = 1;
    assign _e_8203 = _e_8201 && _e_8202;
    assign _e_8204 = _e_8198 && _e_8203;
    assign _e_2667 = \a  != b_n1;
    (* src = "src/cmp.spade:32,39" *)
    \tta::cmp::to_u32  to_u32_1(.x_i(_e_2667), .output__(_e_2666));
    assign _e_2665 = {1'd1, _e_2666};
    assign _e_2672 = \trig [34:0];
    assign _e_2670 = _e_2672[34:32];
    assign b_n2 = _e_2672[31:0];
    assign _e_8206 = \trig [35] == 1'd1;
    assign _e_8209 = _e_2670[2:0] == 3'd2;
    localparam[0:0] _e_8210 = 1;
    assign _e_8211 = _e_8209 && _e_8210;
    assign _e_8212 = _e_8206 && _e_8211;
    (* src = "src/cmp.spade:33,46" *)
    \tta::cmp::signed_lt  signed_lt_0(.a_i(\a ), .b_i(b_n2), .output__(_e_2676));
    (* src = "src/cmp.spade:33,39" *)
    \tta::cmp::to_u32  to_u32_2(.x_i(_e_2676), .output__(_e_2675));
    assign _e_2674 = {1'd1, _e_2675};
    assign _e_2681 = \trig [34:0];
    assign _e_2679 = _e_2681[34:32];
    assign b_n3 = _e_2681[31:0];
    assign _e_8214 = \trig [35] == 1'd1;
    assign _e_8217 = _e_2679[2:0] == 3'd3;
    localparam[0:0] _e_8218 = 1;
    assign _e_8219 = _e_8217 && _e_8218;
    assign _e_8220 = _e_8214 && _e_8219;
    (* src = "src/cmp.spade:34,47" *)
    \tta::cmp::signed_lt  signed_lt_1(.a_i(\a ), .b_i(b_n3), .output__(_e_2686));
    assign _e_2689 = \a  == b_n3;
    assign _e_2685 = _e_2686 || _e_2689;
    (* src = "src/cmp.spade:34,40" *)
    \tta::cmp::to_u32  to_u32_3(.x_i(_e_2685), .output__(_e_2684));
    assign _e_2683 = {1'd1, _e_2684};
    assign _e_2694 = \trig [34:0];
    assign _e_2692 = _e_2694[34:32];
    assign b_n4 = _e_2694[31:0];
    assign _e_8222 = \trig [35] == 1'd1;
    assign _e_8225 = _e_2692[2:0] == 3'd4;
    localparam[0:0] _e_8226 = 1;
    assign _e_8227 = _e_8225 && _e_8226;
    assign _e_8228 = _e_8222 && _e_8227;
    assign _e_2698 = \a  < b_n4;
    (* src = "src/cmp.spade:35,39" *)
    \tta::cmp::to_u32  to_u32_4(.x_i(_e_2698), .output__(_e_2697));
    assign _e_2696 = {1'd1, _e_2697};
    assign _e_2703 = \trig [34:0];
    assign _e_2701 = _e_2703[34:32];
    assign b_n5 = _e_2703[31:0];
    assign _e_8230 = \trig [35] == 1'd1;
    assign _e_8233 = _e_2701[2:0] == 3'd5;
    localparam[0:0] _e_8234 = 1;
    assign _e_8235 = _e_8233 && _e_8234;
    assign _e_8236 = _e_8230 && _e_8235;
    assign _e_2708 = \a  < b_n5;
    assign _e_2711 = \a  == b_n5;
    assign _e_2707 = _e_2708 || _e_2711;
    (* src = "src/cmp.spade:36,39" *)
    \tta::cmp::to_u32  to_u32_5(.x_i(_e_2707), .output__(_e_2706));
    assign _e_2705 = {1'd1, _e_2706};
    assign _e_8238 = \trig [35] == 1'd0;
    assign _e_2715 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8196, _e_8204, _e_8212, _e_8220, _e_8228, _e_8236, _e_8238})
            7'b1??????: \result  = _e_2656;
            7'b01?????: \result  = _e_2665;
            7'b001????: \result  = _e_2674;
            7'b0001???: \result  = _e_2683;
            7'b00001??: \result  = _e_2696;
            7'b000001?: \result  = _e_2705;
            7'b0000001: \result  = _e_2715;
            7'b?: \result  = 33'dx;
        endcase
    end
    assign _e_2720 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_2720;
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
    logic[42:0] _e_2727;
    (* src = "src/cmp.spade:48,14" *)
    logic[31:0] \x ;
    logic _e_8240;
    logic _e_8242;
    logic _e_8244;
    logic _e_8245;
    (* src = "src/cmp.spade:48,35" *)
    logic[32:0] _e_2729;
    (* src = "src/cmp.spade:49,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmp.spade:50,13" *)
    logic[42:0] _e_2735;
    (* src = "src/cmp.spade:50,18" *)
    logic[31:0] x_n1;
    logic _e_8248;
    logic _e_8250;
    logic _e_8252;
    logic _e_8253;
    (* src = "src/cmp.spade:50,39" *)
    logic[32:0] _e_2737;
    (* src = "src/cmp.spade:51,13" *)
    logic[43:0] __n1;
    (* src = "src/cmp.spade:51,18" *)
    logic[32:0] _e_2740;
    (* src = "src/cmp.spade:49,14" *)
    logic[32:0] _e_2732;
    (* src = "src/cmp.spade:47,5" *)
    logic[32:0] _e_2724;
    assign _e_2727 = \m1 [42:0];
    assign \x  = _e_2727[36:5];
    assign _e_8240 = \m1 [43] == 1'd1;
    assign _e_8242 = _e_2727[42:37] == 6'd11;
    localparam[0:0] _e_8243 = 1;
    assign _e_8244 = _e_8242 && _e_8243;
    assign _e_8245 = _e_8240 && _e_8244;
    assign _e_2729 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8246 = 1;
    assign _e_2735 = \m0 [42:0];
    assign x_n1 = _e_2735[36:5];
    assign _e_8248 = \m0 [43] == 1'd1;
    assign _e_8250 = _e_2735[42:37] == 6'd11;
    localparam[0:0] _e_8251 = 1;
    assign _e_8252 = _e_8250 && _e_8251;
    assign _e_8253 = _e_8248 && _e_8252;
    assign _e_2737 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8254 = 1;
    assign _e_2740 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8253, _e_8254})
            2'b1?: _e_2732 = _e_2737;
            2'b01: _e_2732 = _e_2740;
            2'b?: _e_2732 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8245, _e_8246})
            2'b1?: _e_2724 = _e_2729;
            2'b01: _e_2724 = _e_2732;
            2'b?: _e_2724 = 33'dx;
        endcase
    end
    assign output__ = _e_2724;
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
    logic[42:0] _e_2746;
    (* src = "src/cmp.spade:57,14" *)
    logic[2:0] \op ;
    (* src = "src/cmp.spade:57,14" *)
    logic[31:0] \x ;
    logic _e_8256;
    logic _e_8258;
    logic _e_8261;
    logic _e_8262;
    logic _e_8263;
    (* src = "src/cmp.spade:57,44" *)
    logic[34:0] _e_2749;
    (* src = "src/cmp.spade:57,39" *)
    logic[35:0] _e_2748;
    (* src = "src/cmp.spade:58,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmp.spade:59,13" *)
    logic[42:0] _e_2757;
    (* src = "src/cmp.spade:59,18" *)
    logic[2:0] op_n1;
    (* src = "src/cmp.spade:59,18" *)
    logic[31:0] x_n1;
    logic _e_8266;
    logic _e_8268;
    logic _e_8271;
    logic _e_8272;
    logic _e_8273;
    (* src = "src/cmp.spade:59,48" *)
    logic[34:0] _e_2760;
    (* src = "src/cmp.spade:59,43" *)
    logic[35:0] _e_2759;
    (* src = "src/cmp.spade:60,13" *)
    logic[43:0] __n1;
    (* src = "src/cmp.spade:60,18" *)
    logic[35:0] _e_2764;
    (* src = "src/cmp.spade:58,14" *)
    logic[35:0] _e_2753;
    (* src = "src/cmp.spade:56,5" *)
    logic[35:0] _e_2742;
    assign _e_2746 = \m1 [42:0];
    assign \op  = _e_2746[36:34];
    assign \x  = _e_2746[33:2];
    assign _e_8256 = \m1 [43] == 1'd1;
    assign _e_8258 = _e_2746[42:37] == 6'd12;
    localparam[0:0] _e_8259 = 1;
    localparam[0:0] _e_8260 = 1;
    assign _e_8261 = _e_8258 && _e_8259;
    assign _e_8262 = _e_8261 && _e_8260;
    assign _e_8263 = _e_8256 && _e_8262;
    assign _e_2749 = {\op , \x };
    assign _e_2748 = {1'd1, _e_2749};
    assign \_  = \m1 ;
    localparam[0:0] _e_8264 = 1;
    assign _e_2757 = \m0 [42:0];
    assign op_n1 = _e_2757[36:34];
    assign x_n1 = _e_2757[33:2];
    assign _e_8266 = \m0 [43] == 1'd1;
    assign _e_8268 = _e_2757[42:37] == 6'd12;
    localparam[0:0] _e_8269 = 1;
    localparam[0:0] _e_8270 = 1;
    assign _e_8271 = _e_8268 && _e_8269;
    assign _e_8272 = _e_8271 && _e_8270;
    assign _e_8273 = _e_8266 && _e_8272;
    assign _e_2760 = {op_n1, x_n1};
    assign _e_2759 = {1'd1, _e_2760};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8274 = 1;
    assign _e_2764 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_8273, _e_8274})
            2'b1?: _e_2753 = _e_2759;
            2'b01: _e_2753 = _e_2764;
            2'b?: _e_2753 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8263, _e_8264})
            2'b1?: _e_2742 = _e_2748;
            2'b01: _e_2742 = _e_2753;
            2'b?: _e_2742 = 36'dx;
        endcase
    end
    assign output__ = _e_2742;
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
    logic[31:0] _e_2766;
    localparam[31:0] _e_2769 = 32'd1;
    localparam[31:0] _e_2771 = 32'd0;
    assign _e_2766 = \x  ? _e_2769 : _e_2771;
    assign output__ = _e_2766;
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
    logic[31:0] _e_2775;
    (* src = "src/cmp.spade:76,29" *)
    logic[31:0] _e_2774;
    (* src = "src/cmp.spade:76,23" *)
    logic \sa ;
    (* src = "src/cmp.spade:77,29" *)
    logic[31:0] _e_2782;
    (* src = "src/cmp.spade:77,29" *)
    logic[31:0] _e_2781;
    (* src = "src/cmp.spade:77,23" *)
    logic \sb ;
    (* src = "src/cmp.spade:78,8" *)
    logic _e_2788;
    (* src = "src/cmp.spade:79,9" *)
    logic _e_2792;
    (* src = "src/cmp.spade:81,9" *)
    logic _e_2796;
    (* src = "src/cmp.spade:78,5" *)
    logic _e_2787;
    localparam[31:0] _e_2777 = 32'd31;
    assign _e_2775 = \a  >> _e_2777;
    localparam[31:0] _e_2778 = 32'd1;
    assign _e_2774 = _e_2775 & _e_2778;
    assign \sa  = _e_2774[0:0];
    localparam[31:0] _e_2784 = 32'd31;
    assign _e_2782 = \b  >> _e_2784;
    localparam[31:0] _e_2785 = 32'd1;
    assign _e_2781 = _e_2782 & _e_2785;
    assign \sb  = _e_2781[0:0];
    assign _e_2788 = \sa  != \sb ;
    localparam[0:0] _e_2794 = 1;
    assign _e_2792 = \sa  == _e_2794;
    assign _e_2796 = \a  < \b ;
    assign _e_2787 = _e_2788 ? _e_2792 : _e_2796;
    assign output__ = _e_2787;
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
    logic[31:0] _e_2804;
    (* src = "src/gpi.spade:9,12" *)
    reg[31:0] \s1 ;
    (* src = "src/gpi.spade:10,12" *)
    reg[31:0] \s2 ;
    (* src = "src/gpi.spade:11,3" *)
    logic[32:0] _e_2811;
    localparam[31:0] _e_2803 = 32'd0;
    assign _e_2804 = {16'b0, \pins };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s1  <= _e_2803;
        end
        else begin
            \s1  <= _e_2804;
        end
    end
    localparam[31:0] _e_2809 = 32'd0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s2  <= _e_2809;
        end
        else begin
            \s2  <= \s1 ;
        end
    end
    assign _e_2811 = {1'd1, \s2 };
    assign output__ = _e_2811;
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
    logic[21:0] _e_2819;
    (* src = "src/pc.spade:17,9" *)
    logic[21:0] _e_2826;
    (* src = "src/pc.spade:17,9" *)
    logic[10:0] _e_2824;
    (* src = "src/pc.spade:17,10" *)
    logic[9:0] \bt_target ;
    (* src = "src/pc.spade:17,9" *)
    logic[10:0] \_ ;
    logic _e_8277;
    logic _e_8279;
    logic _e_8281;
    (* src = "src/pc.spade:18,9" *)
    logic[21:0] _e_2831;
    (* src = "src/pc.spade:18,9" *)
    logic[10:0] _e_2828;
    (* src = "src/pc.spade:18,9" *)
    logic[10:0] _e_2830;
    (* src = "src/pc.spade:18,16" *)
    logic[9:0] \pc_target ;
    logic _e_8284;
    logic _e_8286;
    logic _e_8288;
    logic _e_8289;
    (* src = "src/pc.spade:19,9" *)
    logic[21:0] _e_2835;
    (* src = "src/pc.spade:19,9" *)
    logic[10:0] _e_2833;
    (* src = "src/pc.spade:19,9" *)
    logic[10:0] _e_2834;
    logic _e_8292;
    logic _e_8294;
    logic _e_8295;
    (* src = "src/pc.spade:19,42" *)
    logic[10:0] _e_2837;
    (* src = "src/pc.spade:19,36" *)
    logic[9:0] _e_2836;
    (* src = "src/pc.spade:16,43" *)
    logic[9:0] _e_2818;
    (* src = "src/pc.spade:16,14" *)
    reg[9:0] \pc ;
    localparam[9:0] _e_2817 = 0;
    assign _e_2819 = {\bt , \jump_to };
    assign _e_2826 = _e_2819;
    assign _e_2824 = _e_2819[21:11];
    assign \bt_target  = _e_2824[9:0];
    assign \_  = _e_2819[10:0];
    assign _e_8277 = _e_2824[10] == 1'd1;
    localparam[0:0] _e_8278 = 1;
    assign _e_8279 = _e_8277 && _e_8278;
    localparam[0:0] _e_8280 = 1;
    assign _e_8281 = _e_8279 && _e_8280;
    assign _e_2831 = _e_2819;
    assign _e_2828 = _e_2819[21:11];
    assign _e_2830 = _e_2819[10:0];
    assign \pc_target  = _e_2830[9:0];
    assign _e_8284 = _e_2828[10] == 1'd0;
    assign _e_8286 = _e_2830[10] == 1'd1;
    localparam[0:0] _e_8287 = 1;
    assign _e_8288 = _e_8286 && _e_8287;
    assign _e_8289 = _e_8284 && _e_8288;
    assign _e_2835 = _e_2819;
    assign _e_2833 = _e_2819[21:11];
    assign _e_2834 = _e_2819[10:0];
    assign _e_8292 = _e_2833[10] == 1'd0;
    assign _e_8294 = _e_2834[10] == 1'd0;
    assign _e_8295 = _e_8292 && _e_8294;
    localparam[9:0] _e_2839 = 1;
    assign _e_2837 = \pc  + _e_2839;
    assign _e_2836 = _e_2837[9:0];
    always_comb begin
        priority casez ({_e_8281, _e_8289, _e_8295})
            3'b1??: _e_2818 = \bt_target ;
            3'b01?: _e_2818 = \pc_target ;
            3'b001: _e_2818 = _e_2836;
            3'b?: _e_2818 = 10'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \pc  <= _e_2817;
        end
        else begin
            \pc  <= _e_2818;
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
    logic[42:0] _e_2845;
    (* src = "src/pc.spade:27,14" *)
    logic[9:0] \a ;
    logic _e_8297;
    logic _e_8299;
    logic _e_8301;
    logic _e_8302;
    (* src = "src/pc.spade:27,34" *)
    logic[10:0] _e_2847;
    (* src = "src/pc.spade:28,9" *)
    logic[43:0] \_ ;
    (* src = "src/pc.spade:28,25" *)
    logic[42:0] _e_2853;
    (* src = "src/pc.spade:28,30" *)
    logic[9:0] a_n1;
    logic _e_8305;
    logic _e_8307;
    logic _e_8309;
    logic _e_8310;
    (* src = "src/pc.spade:28,50" *)
    logic[10:0] _e_2855;
    (* src = "src/pc.spade:28,59" *)
    logic[43:0] __n1;
    (* src = "src/pc.spade:28,64" *)
    logic[10:0] _e_2858;
    (* src = "src/pc.spade:28,14" *)
    logic[10:0] _e_2850;
    (* src = "src/pc.spade:26,5" *)
    logic[10:0] _e_2842;
    assign _e_2845 = \m1 [42:0];
    assign \a  = _e_2845[36:27];
    assign _e_8297 = \m1 [43] == 1'd1;
    assign _e_8299 = _e_2845[42:37] == 6'd3;
    localparam[0:0] _e_8300 = 1;
    assign _e_8301 = _e_8299 && _e_8300;
    assign _e_8302 = _e_8297 && _e_8301;
    assign _e_2847 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_8303 = 1;
    assign _e_2853 = \m0 [42:0];
    assign a_n1 = _e_2853[36:27];
    assign _e_8305 = \m0 [43] == 1'd1;
    assign _e_8307 = _e_2853[42:37] == 6'd3;
    localparam[0:0] _e_8308 = 1;
    assign _e_8309 = _e_8307 && _e_8308;
    assign _e_8310 = _e_8305 && _e_8309;
    assign _e_2855 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8311 = 1;
    assign _e_2858 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_8310, _e_8311})
            2'b1?: _e_2850 = _e_2855;
            2'b01: _e_2850 = _e_2858;
            2'b?: _e_2850 = 11'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8302, _e_8303})
            2'b1?: _e_2842 = _e_2847;
            2'b01: _e_2842 = _e_2850;
            2'b?: _e_2842 = 11'dx;
        endcase
    end
    assign output__ = _e_2842;
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
    logic _e_8313;
    logic _e_8315;
    logic _e_8317;
    (* src = "src/gpo.spade:10,5" *)
    logic[15:0] _e_2864;
    (* src = "src/gpo.spade:9,12" *)
    reg[15:0] \outv ;
    localparam[15:0] _e_2863 = 0;
    assign \v  = \wr [15:0];
    assign _e_8313 = \wr [16] == 1'd1;
    localparam[0:0] _e_8314 = 1;
    assign _e_8315 = _e_8313 && _e_8314;
    assign _e_8317 = \wr [16] == 1'd0;
    always_comb begin
        priority casez ({_e_8315, _e_8317})
            2'b1?: _e_2864 = \v ;
            2'b01: _e_2864 = \outv ;
            2'b?: _e_2864 = 16'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \outv  <= _e_2863;
        end
        else begin
            \outv  <= _e_2864;
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
    logic[42:0] _e_2876;
    (* src = "src/gpo.spade:21,14" *)
    logic[15:0] \x ;
    logic _e_8319;
    logic _e_8321;
    logic _e_8323;
    logic _e_8324;
    (* src = "src/gpo.spade:21,34" *)
    logic[16:0] _e_2878;
    (* src = "src/gpo.spade:22,9" *)
    logic[43:0] \_ ;
    (* src = "src/gpo.spade:23,13" *)
    logic[42:0] _e_2884;
    (* src = "src/gpo.spade:23,18" *)
    logic[15:0] x_n1;
    logic _e_8327;
    logic _e_8329;
    logic _e_8331;
    logic _e_8332;
    (* src = "src/gpo.spade:23,38" *)
    logic[16:0] _e_2886;
    (* src = "src/gpo.spade:24,13" *)
    logic[43:0] __n1;
    (* src = "src/gpo.spade:24,18" *)
    logic[16:0] _e_2889;
    (* src = "src/gpo.spade:22,14" *)
    logic[16:0] _e_2881;
    (* src = "src/gpo.spade:20,5" *)
    logic[16:0] _e_2873;
    assign _e_2876 = \m1 [42:0];
    assign \x  = _e_2876[36:21];
    assign _e_8319 = \m1 [43] == 1'd1;
    assign _e_8321 = _e_2876[42:37] == 6'd10;
    localparam[0:0] _e_8322 = 1;
    assign _e_8323 = _e_8321 && _e_8322;
    assign _e_8324 = _e_8319 && _e_8323;
    assign _e_2878 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8325 = 1;
    assign _e_2884 = \m0 [42:0];
    assign x_n1 = _e_2884[36:21];
    assign _e_8327 = \m0 [43] == 1'd1;
    assign _e_8329 = _e_2884[42:37] == 6'd10;
    localparam[0:0] _e_8330 = 1;
    assign _e_8331 = _e_8329 && _e_8330;
    assign _e_8332 = _e_8327 && _e_8331;
    assign _e_2886 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8333 = 1;
    assign _e_2889 = {1'd0, 16'bX};
    always_comb begin
        priority casez ({_e_8332, _e_8333})
            2'b1?: _e_2881 = _e_2886;
            2'b01: _e_2881 = _e_2889;
            2'b?: _e_2881 = 17'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8324, _e_8325})
            2'b1?: _e_2873 = _e_2878;
            2'b01: _e_2873 = _e_2881;
            2'b?: _e_2873 = 17'dx;
        endcase
    end
    assign output__ = _e_2873;
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
    logic[32:0] _e_2900;
    (* src = "src/spi.spade:13,7" *)
    logic[31:0] \b ;
    logic _e_8335;
    logic _e_8337;
    logic[31:0] _e_2906;
    (* src = "src/spi.spade:13,18" *)
    logic[32:0] _e_2905;
    logic _e_8339;
    (* src = "src/spi.spade:14,15" *)
    logic[32:0] _e_2909;
    (* src = "src/spi.spade:12,56" *)
    logic[32:0] _e_2901;
    (* src = "src/spi.spade:12,14" *)
    reg[32:0] data_n1;
    (* src = "src/spi.spade:11,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\miso_byte ), .pop_i(\pop ), .output__(\data ));
    assign _e_2900 = {1'd0, 32'bX};
    assign \b  = data_n1[31:0];
    assign _e_8335 = data_n1[32] == 1'd1;
    localparam[0:0] _e_8336 = 1;
    assign _e_8337 = _e_8335 && _e_8336;
    assign _e_2906 = \b ;
    assign _e_2905 = {1'd1, _e_2906};
    assign _e_8339 = data_n1[32] == 1'd0;
    assign _e_2909 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8337, _e_8339})
            2'b1?: _e_2901 = _e_2905;
            2'b01: _e_2901 = _e_2909;
            2'b?: _e_2901 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2900;
        end
        else begin
            data_n1 <= _e_2901;
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
    logic _e_2916;
    (* src = "src/spi.spade:31,16" *)
    logic[14:0] \data ;
    (* src = "src/spi.spade:32,47" *)
    logic[8:0] _e_2922;
    (* src = "src/spi.spade:33,7" *)
    logic[7:0] \b ;
    logic _e_8341;
    logic _e_8343;
    (* src = "src/spi.spade:33,18" *)
    logic[8:0] _e_2927;
    logic _e_8345;
    (* src = "src/spi.spade:34,15" *)
    logic[8:0] _e_2930;
    (* src = "src/spi.spade:32,55" *)
    logic[8:0] _e_2923;
    (* src = "src/spi.spade:32,14" *)
    reg[8:0] data_n1;
    assign _e_2916 = !\spi_busy ;
    (* src = "src/spi.spade:31,16" *)
    \tta::fifo::fifo_u8  fifo_u8_0(.clk_i(\clk ), .rst_i(\rst ), .push_i(\byte_to_write ), .pop_i(_e_2916), .output__(\data ));
    assign _e_2922 = {1'd0, 8'bX};
    assign \b  = data_n1[7:0];
    assign _e_8341 = data_n1[8] == 1'd1;
    localparam[0:0] _e_8342 = 1;
    assign _e_8343 = _e_8341 && _e_8342;
    assign _e_2927 = {1'd1, \b };
    assign _e_8345 = data_n1[8] == 1'd0;
    assign _e_2930 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8343, _e_8345})
            2'b1?: _e_2923 = _e_2927;
            2'b01: _e_2923 = _e_2930;
            2'b?: _e_2923 = 9'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            data_n1 <= _e_2922;
        end
        else begin
            data_n1 <= _e_2923;
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
    logic[42:0] _e_2937;
    logic _e_8347;
    logic _e_8349;
    logic _e_8350;
    (* src = "src/spi.spade:43,9" *)
    logic[43:0] \_ ;
    (* src = "src/spi.spade:44,13" *)
    logic[42:0] _e_2943;
    logic _e_8353;
    logic _e_8355;
    logic _e_8356;
    (* src = "src/spi.spade:45,13" *)
    logic[43:0] __n1;
    (* src = "src/spi.spade:43,14" *)
    logic _e_2941;
    (* src = "src/spi.spade:41,5" *)
    logic _e_2935;
    assign _e_2937 = \m1 [42:0];
    assign _e_8347 = \m1 [43] == 1'd1;
    assign _e_8349 = _e_2937[42:37] == 6'd42;
    assign _e_8350 = _e_8347 && _e_8349;
    localparam[0:0] _e_2939 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_8351 = 1;
    assign _e_2943 = \m0 [42:0];
    assign _e_8353 = \m0 [43] == 1'd1;
    assign _e_8355 = _e_2943[42:37] == 6'd42;
    assign _e_8356 = _e_8353 && _e_8355;
    localparam[0:0] _e_2945 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_8357 = 1;
    localparam[0:0] _e_2947 = 0;
    always_comb begin
        priority casez ({_e_8356, _e_8357})
            2'b1?: _e_2941 = _e_2945;
            2'b01: _e_2941 = _e_2947;
            2'b?: _e_2941 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8350, _e_8351})
            2'b1?: _e_2935 = _e_2939;
            2'b01: _e_2935 = _e_2941;
            2'b?: _e_2935 = 1'dx;
        endcase
    end
    assign output__ = _e_2935;
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
    logic[42:0] _e_2952;
    (* src = "src/spi.spade:51,14" *)
    logic[7:0] \x ;
    logic _e_8359;
    logic _e_8361;
    logic _e_8363;
    logic _e_8364;
    (* src = "src/spi.spade:51,35" *)
    logic[8:0] _e_2954;
    (* src = "src/spi.spade:52,9" *)
    logic[43:0] \_ ;
    (* src = "src/spi.spade:53,13" *)
    logic[42:0] _e_2960;
    (* src = "src/spi.spade:53,18" *)
    logic[7:0] x_n1;
    logic _e_8367;
    logic _e_8369;
    logic _e_8371;
    logic _e_8372;
    (* src = "src/spi.spade:53,39" *)
    logic[8:0] _e_2962;
    (* src = "src/spi.spade:54,13" *)
    logic[43:0] __n1;
    (* src = "src/spi.spade:54,18" *)
    logic[8:0] _e_2965;
    (* src = "src/spi.spade:52,14" *)
    logic[8:0] _e_2957;
    (* src = "src/spi.spade:50,5" *)
    logic[8:0] _e_2949;
    assign _e_2952 = \m1 [42:0];
    assign \x  = _e_2952[36:29];
    assign _e_8359 = \m1 [43] == 1'd1;
    assign _e_8361 = _e_2952[42:37] == 6'd20;
    localparam[0:0] _e_8362 = 1;
    assign _e_8363 = _e_8361 && _e_8362;
    assign _e_8364 = _e_8359 && _e_8363;
    assign _e_2954 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8365 = 1;
    assign _e_2960 = \m0 [42:0];
    assign x_n1 = _e_2960[36:29];
    assign _e_8367 = \m0 [43] == 1'd1;
    assign _e_8369 = _e_2960[42:37] == 6'd20;
    localparam[0:0] _e_8370 = 1;
    assign _e_8371 = _e_8369 && _e_8370;
    assign _e_8372 = _e_8367 && _e_8371;
    assign _e_2962 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8373 = 1;
    assign _e_2965 = {1'd0, 8'bX};
    always_comb begin
        priority casez ({_e_8372, _e_8373})
            2'b1?: _e_2957 = _e_2962;
            2'b01: _e_2957 = _e_2965;
            2'b?: _e_2957 = 9'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8364, _e_8365})
            2'b1?: _e_2949 = _e_2954;
            2'b01: _e_2949 = _e_2957;
            2'b?: _e_2949 = 9'dx;
        endcase
    end
    assign output__ = _e_2949;
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
    logic _e_8375;
    logic _e_8377;
    logic _e_8379;
    (* src = "src/lalu.spade:21,45" *)
    logic[31:0] _e_2971;
    (* src = "src/lalu.spade:21,14" *)
    reg[31:0] \op_a ;
    (* src = "src/lalu.spade:28,9" *)
    logic[32:0] _e_2982;
    (* src = "src/lalu.spade:28,14" *)
    logic _e_2980;
    (* src = "src/lalu.spade:28,14" *)
    logic[31:0] \b ;
    logic _e_8381;
    logic _e_8384;
    logic _e_8386;
    logic _e_8387;
    (* src = "src/lalu.spade:28,46" *)
    logic[32:0] _e_2986;
    (* src = "src/lalu.spade:28,40" *)
    logic[31:0] _e_2985;
    (* src = "src/lalu.spade:28,35" *)
    logic[32:0] _e_2984;
    (* src = "src/lalu.spade:29,9" *)
    logic[32:0] _e_2991;
    (* src = "src/lalu.spade:29,14" *)
    logic _e_2989;
    (* src = "src/lalu.spade:29,14" *)
    logic[31:0] b_n1;
    logic _e_8389;
    logic _e_8392;
    logic _e_8394;
    logic _e_8395;
    (* src = "src/lalu.spade:29,46" *)
    logic[32:0] _e_2995;
    (* src = "src/lalu.spade:29,40" *)
    logic[31:0] _e_2994;
    (* src = "src/lalu.spade:29,35" *)
    logic[32:0] _e_2993;
    logic _e_8397;
    (* src = "src/lalu.spade:30,34" *)
    logic[32:0] _e_2999;
    (* src = "src/lalu.spade:27,36" *)
    logic[32:0] \result ;
    (* src = "src/lalu.spade:34,51" *)
    logic[32:0] _e_3004;
    (* src = "src/lalu.spade:34,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_2970 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_8375 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_8376 = 1;
    assign _e_8377 = _e_8375 && _e_8376;
    assign _e_8379 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_8377, _e_8379})
            2'b1?: _e_2971 = \v ;
            2'b01: _e_2971 = \op_a ;
            2'b?: _e_2971 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_2970;
        end
        else begin
            \op_a  <= _e_2971;
        end
    end
    assign _e_2982 = \trig [32:0];
    assign _e_2980 = _e_2982[32];
    assign \b  = _e_2982[31:0];
    assign _e_8381 = \trig [33] == 1'd1;
    assign _e_8384 = _e_2980 == 1'd0;
    localparam[0:0] _e_8385 = 1;
    assign _e_8386 = _e_8384 && _e_8385;
    assign _e_8387 = _e_8381 && _e_8386;
    assign _e_2986 = \op_a  + \b ;
    assign _e_2985 = _e_2986[31:0];
    assign _e_2984 = {1'd1, _e_2985};
    assign _e_2991 = \trig [32:0];
    assign _e_2989 = _e_2991[32];
    assign b_n1 = _e_2991[31:0];
    assign _e_8389 = \trig [33] == 1'd1;
    assign _e_8392 = _e_2989 == 1'd1;
    localparam[0:0] _e_8393 = 1;
    assign _e_8394 = _e_8392 && _e_8393;
    assign _e_8395 = _e_8389 && _e_8394;
    assign _e_2995 = \op_a  - b_n1;
    assign _e_2994 = _e_2995[31:0];
    assign _e_2993 = {1'd1, _e_2994};
    assign _e_8397 = \trig [33] == 1'd0;
    assign _e_2999 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8387, _e_8395, _e_8397})
            3'b1??: \result  = _e_2984;
            3'b01?: \result  = _e_2993;
            3'b001: \result  = _e_2999;
            3'b?: \result  = 33'dx;
        endcase
    end
    assign _e_3004 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_3004;
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
    logic[42:0] _e_3011;
    (* src = "src/lalu.spade:42,14" *)
    logic[31:0] \x ;
    logic _e_8399;
    logic _e_8401;
    logic _e_8403;
    logic _e_8404;
    (* src = "src/lalu.spade:42,36" *)
    logic[32:0] _e_3013;
    (* src = "src/lalu.spade:43,9" *)
    logic[43:0] \_ ;
    (* src = "src/lalu.spade:44,13" *)
    logic[42:0] _e_3019;
    (* src = "src/lalu.spade:44,18" *)
    logic[31:0] x_n1;
    logic _e_8407;
    logic _e_8409;
    logic _e_8411;
    logic _e_8412;
    (* src = "src/lalu.spade:44,40" *)
    logic[32:0] _e_3021;
    (* src = "src/lalu.spade:45,13" *)
    logic[43:0] __n1;
    (* src = "src/lalu.spade:45,18" *)
    logic[32:0] _e_3024;
    (* src = "src/lalu.spade:43,14" *)
    logic[32:0] _e_3016;
    (* src = "src/lalu.spade:41,5" *)
    logic[32:0] _e_3008;
    assign _e_3011 = \m1 [42:0];
    assign \x  = _e_3011[36:5];
    assign _e_8399 = \m1 [43] == 1'd1;
    assign _e_8401 = _e_3011[42:37] == 6'd14;
    localparam[0:0] _e_8402 = 1;
    assign _e_8403 = _e_8401 && _e_8402;
    assign _e_8404 = _e_8399 && _e_8403;
    assign _e_3013 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_8405 = 1;
    assign _e_3019 = \m0 [42:0];
    assign x_n1 = _e_3019[36:5];
    assign _e_8407 = \m0 [43] == 1'd1;
    assign _e_8409 = _e_3019[42:37] == 6'd14;
    localparam[0:0] _e_8410 = 1;
    assign _e_8411 = _e_8409 && _e_8410;
    assign _e_8412 = _e_8407 && _e_8411;
    assign _e_3021 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8413 = 1;
    assign _e_3024 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_8412, _e_8413})
            2'b1?: _e_3016 = _e_3021;
            2'b01: _e_3016 = _e_3024;
            2'b?: _e_3016 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8404, _e_8405})
            2'b1?: _e_3008 = _e_3013;
            2'b01: _e_3008 = _e_3016;
            2'b?: _e_3008 = 33'dx;
        endcase
    end
    assign output__ = _e_3008;
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
    logic[42:0] _e_3030;
    (* src = "src/lalu.spade:51,14" *)
    logic \op ;
    (* src = "src/lalu.spade:51,14" *)
    logic[31:0] \x ;
    logic _e_8415;
    logic _e_8417;
    logic _e_8420;
    logic _e_8421;
    logic _e_8422;
    (* src = "src/lalu.spade:51,45" *)
    logic[32:0] _e_3033;
    (* src = "src/lalu.spade:51,40" *)
    logic[33:0] _e_3032;
    (* src = "src/lalu.spade:52,9" *)
    logic[43:0] \_ ;
    (* src = "src/lalu.spade:53,13" *)
    logic[42:0] _e_3041;
    (* src = "src/lalu.spade:53,18" *)
    logic op_n1;
    (* src = "src/lalu.spade:53,18" *)
    logic[31:0] x_n1;
    logic _e_8425;
    logic _e_8427;
    logic _e_8430;
    logic _e_8431;
    logic _e_8432;
    (* src = "src/lalu.spade:53,49" *)
    logic[32:0] _e_3044;
    (* src = "src/lalu.spade:53,44" *)
    logic[33:0] _e_3043;
    (* src = "src/lalu.spade:54,13" *)
    logic[43:0] __n1;
    (* src = "src/lalu.spade:54,18" *)
    logic[33:0] _e_3048;
    (* src = "src/lalu.spade:52,14" *)
    logic[33:0] _e_3037;
    (* src = "src/lalu.spade:50,5" *)
    logic[33:0] _e_3026;
    assign _e_3030 = \m1 [42:0];
    assign \op  = _e_3030[36:36];
    assign \x  = _e_3030[35:4];
    assign _e_8415 = \m1 [43] == 1'd1;
    assign _e_8417 = _e_3030[42:37] == 6'd15;
    localparam[0:0] _e_8418 = 1;
    localparam[0:0] _e_8419 = 1;
    assign _e_8420 = _e_8417 && _e_8418;
    assign _e_8421 = _e_8420 && _e_8419;
    assign _e_8422 = _e_8415 && _e_8421;
    assign _e_3033 = {\op , \x };
    assign _e_3032 = {1'd1, _e_3033};
    assign \_  = \m1 ;
    localparam[0:0] _e_8423 = 1;
    assign _e_3041 = \m0 [42:0];
    assign op_n1 = _e_3041[36:36];
    assign x_n1 = _e_3041[35:4];
    assign _e_8425 = \m0 [43] == 1'd1;
    assign _e_8427 = _e_3041[42:37] == 6'd15;
    localparam[0:0] _e_8428 = 1;
    localparam[0:0] _e_8429 = 1;
    assign _e_8430 = _e_8427 && _e_8428;
    assign _e_8431 = _e_8430 && _e_8429;
    assign _e_8432 = _e_8425 && _e_8431;
    assign _e_3044 = {op_n1, x_n1};
    assign _e_3043 = {1'd1, _e_3044};
    assign __n1 = \m0 ;
    localparam[0:0] _e_8433 = 1;
    assign _e_3048 = {1'd0, 33'bX};
    always_comb begin
        priority casez ({_e_8432, _e_8433})
            2'b1?: _e_3037 = _e_3043;
            2'b01: _e_3037 = _e_3048;
            2'b?: _e_3037 = 34'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_8422, _e_8423})
            2'b1?: _e_3026 = _e_3032;
            2'b01: _e_3026 = _e_3037;
            2'b?: _e_3026 = 34'dx;
        endcase
    end
    assign output__ = _e_3026;
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
    logic[43:0] _e_3051;
    (* src = "src/tta.spade:198,9" *)
    logic[43:0] _e_3058;
    (* src = "src/tta.spade:198,9" *)
    logic[10:0] _e_3055;
    (* src = "src/tta.spade:198,10" *)
    logic[3:0] \i ;
    (* src = "src/tta.spade:198,9" *)
    logic[32:0] _e_3057;
    (* src = "src/tta.spade:198,32" *)
    logic[31:0] \x ;
    logic _e_8436;
    logic _e_8438;
    logic _e_8440;
    logic _e_8442;
    logic _e_8443;
    (* src = "src/tta.spade:198,49" *)
    logic[42:0] _e_3060;
    (* src = "src/tta.spade:198,44" *)
    logic[43:0] _e_3059;
    (* src = "src/tta.spade:200,9" *)
    logic[43:0] _e_3066;
    (* src = "src/tta.spade:200,9" *)
    logic[10:0] _e_3063;
    (* src = "src/tta.spade:200,9" *)
    logic[32:0] _e_3065;
    (* src = "src/tta.spade:200,32" *)
    logic[31:0] x_n1;
    logic _e_8446;
    logic _e_8448;
    logic _e_8450;
    logic _e_8451;
    (* src = "src/tta.spade:200,49" *)
    logic[42:0] _e_3068;
    (* src = "src/tta.spade:200,44" *)
    logic[43:0] _e_3067;
    (* src = "src/tta.spade:201,9" *)
    logic[43:0] _e_3073;
    (* src = "src/tta.spade:201,9" *)
    logic[10:0] _e_3070;
    (* src = "src/tta.spade:201,9" *)
    logic[32:0] _e_3072;
    (* src = "src/tta.spade:201,32" *)
    logic[31:0] x_n2;
    logic _e_8454;
    logic _e_8456;
    logic _e_8458;
    logic _e_8459;
    (* src = "src/tta.spade:201,63" *)
    logic[4:0] _e_3076;
    (* src = "src/tta.spade:201,49" *)
    logic[42:0] _e_3075;
    (* src = "src/tta.spade:201,44" *)
    logic[43:0] _e_3074;
    (* src = "src/tta.spade:202,9" *)
    logic[43:0] _e_3081;
    (* src = "src/tta.spade:202,9" *)
    logic[10:0] _e_3078;
    (* src = "src/tta.spade:202,9" *)
    logic[32:0] _e_3080;
    (* src = "src/tta.spade:202,32" *)
    logic[31:0] x_n3;
    logic _e_8462;
    logic _e_8464;
    logic _e_8466;
    logic _e_8467;
    (* src = "src/tta.spade:202,63" *)
    logic[4:0] _e_3084;
    (* src = "src/tta.spade:202,49" *)
    logic[42:0] _e_3083;
    (* src = "src/tta.spade:202,44" *)
    logic[43:0] _e_3082;
    (* src = "src/tta.spade:203,9" *)
    logic[43:0] _e_3089;
    (* src = "src/tta.spade:203,9" *)
    logic[10:0] _e_3086;
    (* src = "src/tta.spade:203,9" *)
    logic[32:0] _e_3088;
    (* src = "src/tta.spade:203,32" *)
    logic[31:0] x_n4;
    logic _e_8470;
    logic _e_8472;
    logic _e_8474;
    logic _e_8475;
    (* src = "src/tta.spade:203,63" *)
    logic[4:0] _e_3092;
    (* src = "src/tta.spade:203,49" *)
    logic[42:0] _e_3091;
    (* src = "src/tta.spade:203,44" *)
    logic[43:0] _e_3090;
    (* src = "src/tta.spade:204,9" *)
    logic[43:0] _e_3097;
    (* src = "src/tta.spade:204,9" *)
    logic[10:0] _e_3094;
    (* src = "src/tta.spade:204,9" *)
    logic[32:0] _e_3096;
    (* src = "src/tta.spade:204,32" *)
    logic[31:0] x_n5;
    logic _e_8478;
    logic _e_8480;
    logic _e_8482;
    logic _e_8483;
    (* src = "src/tta.spade:204,63" *)
    logic[4:0] _e_3100;
    (* src = "src/tta.spade:204,49" *)
    logic[42:0] _e_3099;
    (* src = "src/tta.spade:204,44" *)
    logic[43:0] _e_3098;
    (* src = "src/tta.spade:205,9" *)
    logic[43:0] _e_3105;
    (* src = "src/tta.spade:205,9" *)
    logic[10:0] _e_3102;
    (* src = "src/tta.spade:205,9" *)
    logic[32:0] _e_3104;
    (* src = "src/tta.spade:205,33" *)
    logic[31:0] x_n6;
    logic _e_8486;
    logic _e_8488;
    logic _e_8490;
    logic _e_8491;
    (* src = "src/tta.spade:205,64" *)
    logic[4:0] _e_3108;
    (* src = "src/tta.spade:205,50" *)
    logic[42:0] _e_3107;
    (* src = "src/tta.spade:205,45" *)
    logic[43:0] _e_3106;
    (* src = "src/tta.spade:206,9" *)
    logic[43:0] _e_3113;
    (* src = "src/tta.spade:206,9" *)
    logic[10:0] _e_3110;
    (* src = "src/tta.spade:206,9" *)
    logic[32:0] _e_3112;
    (* src = "src/tta.spade:206,33" *)
    logic[31:0] x_n7;
    logic _e_8494;
    logic _e_8496;
    logic _e_8498;
    logic _e_8499;
    (* src = "src/tta.spade:206,64" *)
    logic[4:0] _e_3116;
    (* src = "src/tta.spade:206,50" *)
    logic[42:0] _e_3115;
    (* src = "src/tta.spade:206,45" *)
    logic[43:0] _e_3114;
    (* src = "src/tta.spade:207,9" *)
    logic[43:0] _e_3121;
    (* src = "src/tta.spade:207,9" *)
    logic[10:0] _e_3118;
    (* src = "src/tta.spade:207,9" *)
    logic[32:0] _e_3120;
    (* src = "src/tta.spade:207,33" *)
    logic[31:0] x_n8;
    logic _e_8502;
    logic _e_8504;
    logic _e_8506;
    logic _e_8507;
    (* src = "src/tta.spade:207,64" *)
    logic[4:0] _e_3124;
    (* src = "src/tta.spade:207,50" *)
    logic[42:0] _e_3123;
    (* src = "src/tta.spade:207,45" *)
    logic[43:0] _e_3122;
    (* src = "src/tta.spade:208,9" *)
    logic[43:0] _e_3129;
    (* src = "src/tta.spade:208,9" *)
    logic[10:0] _e_3126;
    (* src = "src/tta.spade:208,9" *)
    logic[32:0] _e_3128;
    (* src = "src/tta.spade:208,34" *)
    logic[31:0] x_n9;
    logic _e_8510;
    logic _e_8512;
    logic _e_8514;
    logic _e_8515;
    (* src = "src/tta.spade:208,65" *)
    logic[4:0] _e_3132;
    (* src = "src/tta.spade:208,51" *)
    logic[42:0] _e_3131;
    (* src = "src/tta.spade:208,46" *)
    logic[43:0] _e_3130;
    (* src = "src/tta.spade:209,9" *)
    logic[43:0] _e_3137;
    (* src = "src/tta.spade:209,9" *)
    logic[10:0] _e_3134;
    (* src = "src/tta.spade:209,9" *)
    logic[32:0] _e_3136;
    (* src = "src/tta.spade:209,34" *)
    logic[31:0] x_n10;
    logic _e_8518;
    logic _e_8520;
    logic _e_8522;
    logic _e_8523;
    (* src = "src/tta.spade:209,65" *)
    logic[4:0] _e_3140;
    (* src = "src/tta.spade:209,51" *)
    logic[42:0] _e_3139;
    (* src = "src/tta.spade:209,46" *)
    logic[43:0] _e_3138;
    (* src = "src/tta.spade:210,9" *)
    logic[43:0] _e_3145;
    (* src = "src/tta.spade:210,9" *)
    logic[10:0] _e_3142;
    (* src = "src/tta.spade:210,9" *)
    logic[32:0] _e_3144;
    (* src = "src/tta.spade:210,34" *)
    logic[31:0] x_n11;
    logic _e_8526;
    logic _e_8528;
    logic _e_8530;
    logic _e_8531;
    (* src = "src/tta.spade:210,65" *)
    logic[4:0] _e_3148;
    (* src = "src/tta.spade:210,51" *)
    logic[42:0] _e_3147;
    (* src = "src/tta.spade:210,46" *)
    logic[43:0] _e_3146;
    (* src = "src/tta.spade:211,9" *)
    logic[43:0] _e_3153;
    (* src = "src/tta.spade:211,9" *)
    logic[10:0] _e_3150;
    (* src = "src/tta.spade:211,9" *)
    logic[32:0] _e_3152;
    (* src = "src/tta.spade:211,33" *)
    logic[31:0] x_n12;
    logic _e_8534;
    logic _e_8536;
    logic _e_8538;
    logic _e_8539;
    (* src = "src/tta.spade:211,64" *)
    logic[4:0] _e_3156;
    (* src = "src/tta.spade:211,50" *)
    logic[42:0] _e_3155;
    (* src = "src/tta.spade:211,45" *)
    logic[43:0] _e_3154;
    (* src = "src/tta.spade:212,9" *)
    logic[43:0] _e_3161;
    (* src = "src/tta.spade:212,9" *)
    logic[10:0] _e_3158;
    (* src = "src/tta.spade:212,9" *)
    logic[32:0] _e_3160;
    (* src = "src/tta.spade:212,33" *)
    logic[31:0] x_n13;
    logic _e_8542;
    logic _e_8544;
    logic _e_8546;
    logic _e_8547;
    (* src = "src/tta.spade:212,64" *)
    logic[4:0] _e_3164;
    (* src = "src/tta.spade:212,50" *)
    logic[42:0] _e_3163;
    (* src = "src/tta.spade:212,45" *)
    logic[43:0] _e_3162;
    (* src = "src/tta.spade:213,9" *)
    logic[43:0] _e_3169;
    (* src = "src/tta.spade:213,9" *)
    logic[10:0] _e_3166;
    (* src = "src/tta.spade:213,9" *)
    logic[32:0] _e_3168;
    (* src = "src/tta.spade:213,35" *)
    logic[31:0] x_n14;
    logic _e_8550;
    logic _e_8552;
    logic _e_8554;
    logic _e_8555;
    (* src = "src/tta.spade:213,66" *)
    logic[4:0] _e_3172;
    (* src = "src/tta.spade:213,52" *)
    logic[42:0] _e_3171;
    (* src = "src/tta.spade:213,47" *)
    logic[43:0] _e_3170;
    (* src = "src/tta.spade:214,9" *)
    logic[43:0] _e_3177;
    (* src = "src/tta.spade:214,9" *)
    logic[10:0] _e_3174;
    (* src = "src/tta.spade:214,9" *)
    logic[32:0] _e_3176;
    (* src = "src/tta.spade:214,35" *)
    logic[31:0] x_n15;
    logic _e_8558;
    logic _e_8560;
    logic _e_8562;
    logic _e_8563;
    (* src = "src/tta.spade:214,66" *)
    logic[4:0] _e_3180;
    (* src = "src/tta.spade:214,52" *)
    logic[42:0] _e_3179;
    (* src = "src/tta.spade:214,47" *)
    logic[43:0] _e_3178;
    (* src = "src/tta.spade:215,9" *)
    logic[43:0] _e_3185;
    (* src = "src/tta.spade:215,9" *)
    logic[10:0] _e_3182;
    (* src = "src/tta.spade:215,9" *)
    logic[32:0] _e_3184;
    (* src = "src/tta.spade:215,35" *)
    logic[31:0] x_n16;
    logic _e_8566;
    logic _e_8568;
    logic _e_8570;
    logic _e_8571;
    (* src = "src/tta.spade:215,66" *)
    logic[4:0] _e_3188;
    (* src = "src/tta.spade:215,52" *)
    logic[42:0] _e_3187;
    (* src = "src/tta.spade:215,47" *)
    logic[43:0] _e_3186;
    (* src = "src/tta.spade:216,9" *)
    logic[43:0] _e_3193;
    (* src = "src/tta.spade:216,9" *)
    logic[10:0] _e_3190;
    (* src = "src/tta.spade:216,9" *)
    logic[32:0] _e_3192;
    (* src = "src/tta.spade:216,35" *)
    logic[31:0] x_n17;
    logic _e_8574;
    logic _e_8576;
    logic _e_8578;
    logic _e_8579;
    (* src = "src/tta.spade:216,66" *)
    logic[4:0] _e_3196;
    (* src = "src/tta.spade:216,52" *)
    logic[42:0] _e_3195;
    (* src = "src/tta.spade:216,47" *)
    logic[43:0] _e_3194;
    (* src = "src/tta.spade:218,9" *)
    logic[43:0] _e_3201;
    (* src = "src/tta.spade:218,9" *)
    logic[10:0] _e_3198;
    (* src = "src/tta.spade:218,9" *)
    logic[32:0] _e_3200;
    (* src = "src/tta.spade:218,33" *)
    logic[31:0] x_n18;
    logic _e_8582;
    logic _e_8584;
    logic _e_8586;
    logic _e_8587;
    (* src = "src/tta.spade:218,64" *)
    logic[2:0] _e_3204;
    (* src = "src/tta.spade:218,50" *)
    logic[42:0] _e_3203;
    (* src = "src/tta.spade:218,45" *)
    logic[43:0] _e_3202;
    (* src = "src/tta.spade:219,9" *)
    logic[43:0] _e_3209;
    (* src = "src/tta.spade:219,9" *)
    logic[10:0] _e_3206;
    (* src = "src/tta.spade:219,9" *)
    logic[32:0] _e_3208;
    (* src = "src/tta.spade:219,33" *)
    logic[31:0] x_n19;
    logic _e_8590;
    logic _e_8592;
    logic _e_8594;
    logic _e_8595;
    (* src = "src/tta.spade:219,64" *)
    logic[2:0] _e_3212;
    (* src = "src/tta.spade:219,50" *)
    logic[42:0] _e_3211;
    (* src = "src/tta.spade:219,45" *)
    logic[43:0] _e_3210;
    (* src = "src/tta.spade:220,9" *)
    logic[43:0] _e_3217;
    (* src = "src/tta.spade:220,9" *)
    logic[10:0] _e_3214;
    (* src = "src/tta.spade:220,9" *)
    logic[32:0] _e_3216;
    (* src = "src/tta.spade:220,36" *)
    logic[31:0] x_n20;
    logic _e_8598;
    logic _e_8600;
    logic _e_8602;
    logic _e_8603;
    (* src = "src/tta.spade:220,67" *)
    logic[2:0] _e_3220;
    (* src = "src/tta.spade:220,53" *)
    logic[42:0] _e_3219;
    (* src = "src/tta.spade:220,48" *)
    logic[43:0] _e_3218;
    (* src = "src/tta.spade:221,9" *)
    logic[43:0] _e_3225;
    (* src = "src/tta.spade:221,9" *)
    logic[10:0] _e_3222;
    (* src = "src/tta.spade:221,9" *)
    logic[32:0] _e_3224;
    (* src = "src/tta.spade:221,34" *)
    logic[31:0] x_n21;
    logic _e_8606;
    logic _e_8608;
    logic _e_8610;
    logic _e_8611;
    (* src = "src/tta.spade:221,65" *)
    logic[2:0] _e_3228;
    (* src = "src/tta.spade:221,51" *)
    logic[42:0] _e_3227;
    (* src = "src/tta.spade:221,46" *)
    logic[43:0] _e_3226;
    (* src = "src/tta.spade:222,9" *)
    logic[43:0] _e_3233;
    (* src = "src/tta.spade:222,9" *)
    logic[10:0] _e_3230;
    (* src = "src/tta.spade:222,9" *)
    logic[32:0] _e_3232;
    (* src = "src/tta.spade:222,34" *)
    logic[31:0] x_n22;
    logic _e_8614;
    logic _e_8616;
    logic _e_8618;
    logic _e_8619;
    (* src = "src/tta.spade:222,65" *)
    logic[2:0] _e_3236;
    (* src = "src/tta.spade:222,51" *)
    logic[42:0] _e_3235;
    (* src = "src/tta.spade:222,46" *)
    logic[43:0] _e_3234;
    (* src = "src/tta.spade:223,9" *)
    logic[43:0] _e_3241;
    (* src = "src/tta.spade:223,9" *)
    logic[10:0] _e_3238;
    (* src = "src/tta.spade:223,9" *)
    logic[32:0] _e_3240;
    (* src = "src/tta.spade:223,34" *)
    logic[31:0] x_n23;
    logic _e_8622;
    logic _e_8624;
    logic _e_8626;
    logic _e_8627;
    (* src = "src/tta.spade:223,65" *)
    logic[2:0] _e_3244;
    (* src = "src/tta.spade:223,51" *)
    logic[42:0] _e_3243;
    (* src = "src/tta.spade:223,46" *)
    logic[43:0] _e_3242;
    (* src = "src/tta.spade:224,9" *)
    logic[43:0] _e_3249;
    (* src = "src/tta.spade:224,9" *)
    logic[10:0] _e_3246;
    (* src = "src/tta.spade:224,9" *)
    logic[32:0] _e_3248;
    (* src = "src/tta.spade:224,34" *)
    logic[31:0] x_n24;
    logic _e_8630;
    logic _e_8632;
    logic _e_8634;
    logic _e_8635;
    (* src = "src/tta.spade:224,65" *)
    logic[2:0] _e_3252;
    (* src = "src/tta.spade:224,51" *)
    logic[42:0] _e_3251;
    (* src = "src/tta.spade:224,46" *)
    logic[43:0] _e_3250;
    (* src = "src/tta.spade:225,9" *)
    logic[43:0] _e_3257;
    (* src = "src/tta.spade:225,9" *)
    logic[10:0] _e_3254;
    (* src = "src/tta.spade:225,9" *)
    logic[32:0] _e_3256;
    (* src = "src/tta.spade:225,34" *)
    logic[31:0] x_n25;
    logic _e_8638;
    logic _e_8640;
    logic _e_8642;
    logic _e_8643;
    (* src = "src/tta.spade:225,65" *)
    logic[2:0] _e_3260;
    (* src = "src/tta.spade:225,51" *)
    logic[42:0] _e_3259;
    (* src = "src/tta.spade:225,46" *)
    logic[43:0] _e_3258;
    (* src = "src/tta.spade:227,9" *)
    logic[43:0] _e_3265;
    (* src = "src/tta.spade:227,9" *)
    logic[10:0] _e_3262;
    (* src = "src/tta.spade:227,9" *)
    logic[32:0] _e_3264;
    (* src = "src/tta.spade:227,33" *)
    logic[31:0] x_n26;
    logic _e_8646;
    logic _e_8648;
    logic _e_8650;
    logic _e_8651;
    (* src = "src/tta.spade:227,50" *)
    logic[42:0] _e_3267;
    (* src = "src/tta.spade:227,45" *)
    logic[43:0] _e_3266;
    (* src = "src/tta.spade:228,9" *)
    logic[43:0] _e_3272;
    (* src = "src/tta.spade:228,9" *)
    logic[10:0] _e_3269;
    (* src = "src/tta.spade:228,9" *)
    logic[32:0] _e_3271;
    (* src = "src/tta.spade:228,33" *)
    logic[31:0] x_n27;
    logic _e_8654;
    logic _e_8656;
    logic _e_8658;
    logic _e_8659;
    (* src = "src/tta.spade:228,65" *)
    logic _e_3275;
    (* src = "src/tta.spade:228,50" *)
    logic[42:0] _e_3274;
    (* src = "src/tta.spade:228,45" *)
    logic[43:0] _e_3273;
    (* src = "src/tta.spade:229,9" *)
    logic[43:0] _e_3280;
    (* src = "src/tta.spade:229,9" *)
    logic[10:0] _e_3277;
    (* src = "src/tta.spade:229,9" *)
    logic[32:0] _e_3279;
    (* src = "src/tta.spade:229,33" *)
    logic[31:0] x_n28;
    logic _e_8662;
    logic _e_8664;
    logic _e_8666;
    logic _e_8667;
    (* src = "src/tta.spade:229,65" *)
    logic _e_3283;
    (* src = "src/tta.spade:229,50" *)
    logic[42:0] _e_3282;
    (* src = "src/tta.spade:229,45" *)
    logic[43:0] _e_3281;
    (* src = "src/tta.spade:231,9" *)
    logic[43:0] _e_3288;
    (* src = "src/tta.spade:231,9" *)
    logic[10:0] _e_3285;
    (* src = "src/tta.spade:231,9" *)
    logic[32:0] _e_3287;
    (* src = "src/tta.spade:231,32" *)
    logic[31:0] x_n29;
    logic _e_8670;
    logic _e_8672;
    logic _e_8674;
    logic _e_8675;
    (* src = "src/tta.spade:231,62" *)
    logic[9:0] _e_3291;
    (* src = "src/tta.spade:231,49" *)
    logic[42:0] _e_3290;
    (* src = "src/tta.spade:231,44" *)
    logic[43:0] _e_3289;
    (* src = "src/tta.spade:233,9" *)
    logic[43:0] _e_3296;
    (* src = "src/tta.spade:233,9" *)
    logic[10:0] _e_3293;
    (* src = "src/tta.spade:233,9" *)
    logic[32:0] _e_3295;
    (* src = "src/tta.spade:233,32" *)
    logic[31:0] x_n30;
    logic _e_8678;
    logic _e_8680;
    logic _e_8682;
    logic _e_8683;
    (* src = "src/tta.spade:233,64" *)
    logic[9:0] _e_3299;
    (* src = "src/tta.spade:233,49" *)
    logic[42:0] _e_3298;
    (* src = "src/tta.spade:233,44" *)
    logic[43:0] _e_3297;
    (* src = "src/tta.spade:234,9" *)
    logic[43:0] _e_3304;
    (* src = "src/tta.spade:234,9" *)
    logic[10:0] _e_3301;
    (* src = "src/tta.spade:234,9" *)
    logic[32:0] _e_3303;
    (* src = "src/tta.spade:234,32" *)
    logic[31:0] x_n31;
    logic _e_8686;
    logic _e_8688;
    logic _e_8690;
    logic _e_8691;
    (* src = "src/tta.spade:234,49" *)
    logic[42:0] _e_3306;
    (* src = "src/tta.spade:234,44" *)
    logic[43:0] _e_3305;
    (* src = "src/tta.spade:236,9" *)
    logic[43:0] _e_3311;
    (* src = "src/tta.spade:236,9" *)
    logic[10:0] _e_3308;
    (* src = "src/tta.spade:236,9" *)
    logic[32:0] _e_3310;
    (* src = "src/tta.spade:236,32" *)
    logic[31:0] x_n32;
    logic _e_8694;
    logic _e_8696;
    logic _e_8698;
    logic _e_8699;
    (* src = "src/tta.spade:236,49" *)
    logic[42:0] _e_3313;
    (* src = "src/tta.spade:236,44" *)
    logic[43:0] _e_3312;
    (* src = "src/tta.spade:237,9" *)
    logic[43:0] _e_3318;
    (* src = "src/tta.spade:237,9" *)
    logic[10:0] _e_3315;
    (* src = "src/tta.spade:237,9" *)
    logic[32:0] _e_3317;
    (* src = "src/tta.spade:237,32" *)
    logic[31:0] x_n33;
    logic _e_8702;
    logic _e_8704;
    logic _e_8706;
    logic _e_8707;
    (* src = "src/tta.spade:237,49" *)
    logic[42:0] _e_3320;
    (* src = "src/tta.spade:237,44" *)
    logic[43:0] _e_3319;
    (* src = "src/tta.spade:238,9" *)
    logic[43:0] _e_3325;
    (* src = "src/tta.spade:238,9" *)
    logic[10:0] _e_3322;
    (* src = "src/tta.spade:238,9" *)
    logic[32:0] _e_3324;
    (* src = "src/tta.spade:238,32" *)
    logic[31:0] x_n34;
    logic _e_8710;
    logic _e_8712;
    logic _e_8714;
    logic _e_8715;
    (* src = "src/tta.spade:238,49" *)
    logic[42:0] _e_3327;
    (* src = "src/tta.spade:238,44" *)
    logic[43:0] _e_3326;
    (* src = "src/tta.spade:240,9" *)
    logic[43:0] _e_3332;
    (* src = "src/tta.spade:240,9" *)
    logic[10:0] _e_3329;
    (* src = "src/tta.spade:240,9" *)
    logic[32:0] _e_3331;
    (* src = "src/tta.spade:240,33" *)
    logic[31:0] x_n35;
    logic _e_8718;
    logic _e_8720;
    logic _e_8722;
    logic _e_8723;
    (* src = "src/tta.spade:240,50" *)
    logic[42:0] _e_3334;
    (* src = "src/tta.spade:240,45" *)
    logic[43:0] _e_3333;
    (* src = "src/tta.spade:241,9" *)
    logic[43:0] _e_3339;
    (* src = "src/tta.spade:241,9" *)
    logic[10:0] _e_3336;
    (* src = "src/tta.spade:241,9" *)
    logic[32:0] _e_3338;
    (* src = "src/tta.spade:241,33" *)
    logic[31:0] x_n36;
    logic _e_8726;
    logic _e_8728;
    logic _e_8730;
    logic _e_8731;
    (* src = "src/tta.spade:241,50" *)
    logic[42:0] _e_3341;
    (* src = "src/tta.spade:241,45" *)
    logic[43:0] _e_3340;
    (* src = "src/tta.spade:242,9" *)
    logic[43:0] _e_3346;
    (* src = "src/tta.spade:242,9" *)
    logic[10:0] _e_3343;
    (* src = "src/tta.spade:242,9" *)
    logic[32:0] _e_3345;
    (* src = "src/tta.spade:242,33" *)
    logic[31:0] x_n37;
    logic _e_8734;
    logic _e_8736;
    logic _e_8738;
    logic _e_8739;
    (* src = "src/tta.spade:242,50" *)
    logic[42:0] _e_3348;
    (* src = "src/tta.spade:242,45" *)
    logic[43:0] _e_3347;
    (* src = "src/tta.spade:244,9" *)
    logic[43:0] _e_3353;
    (* src = "src/tta.spade:244,9" *)
    logic[10:0] _e_3350;
    (* src = "src/tta.spade:244,9" *)
    logic[32:0] _e_3352;
    (* src = "src/tta.spade:244,32" *)
    logic[31:0] x_n38;
    logic _e_8742;
    logic _e_8744;
    logic _e_8746;
    logic _e_8747;
    (* src = "src/tta.spade:244,62" *)
    logic[15:0] _e_3356;
    (* src = "src/tta.spade:244,49" *)
    logic[42:0] _e_3355;
    (* src = "src/tta.spade:244,44" *)
    logic[43:0] _e_3354;
    (* src = "src/tta.spade:246,9" *)
    logic[43:0] _e_3361;
    (* src = "src/tta.spade:246,9" *)
    logic[10:0] _e_3358;
    (* src = "src/tta.spade:246,9" *)
    logic[32:0] _e_3360;
    (* src = "src/tta.spade:246,32" *)
    logic[31:0] x_n39;
    logic _e_8750;
    logic _e_8752;
    logic _e_8754;
    logic _e_8755;
    (* src = "src/tta.spade:246,49" *)
    logic[42:0] _e_3363;
    (* src = "src/tta.spade:246,44" *)
    logic[43:0] _e_3362;
    (* src = "src/tta.spade:247,9" *)
    logic[43:0] _e_3368;
    (* src = "src/tta.spade:247,9" *)
    logic[10:0] _e_3365;
    (* src = "src/tta.spade:247,9" *)
    logic[32:0] _e_3367;
    (* src = "src/tta.spade:247,32" *)
    logic[31:0] x_n40;
    logic _e_8758;
    logic _e_8760;
    logic _e_8762;
    logic _e_8763;
    (* src = "src/tta.spade:247,63" *)
    logic[2:0] _e_3371;
    (* src = "src/tta.spade:247,49" *)
    logic[42:0] _e_3370;
    (* src = "src/tta.spade:247,44" *)
    logic[43:0] _e_3369;
    (* src = "src/tta.spade:248,9" *)
    logic[43:0] _e_3376;
    (* src = "src/tta.spade:248,9" *)
    logic[10:0] _e_3373;
    (* src = "src/tta.spade:248,9" *)
    logic[32:0] _e_3375;
    (* src = "src/tta.spade:248,32" *)
    logic[31:0] x_n41;
    logic _e_8766;
    logic _e_8768;
    logic _e_8770;
    logic _e_8771;
    (* src = "src/tta.spade:248,63" *)
    logic[2:0] _e_3379;
    (* src = "src/tta.spade:248,49" *)
    logic[42:0] _e_3378;
    (* src = "src/tta.spade:248,44" *)
    logic[43:0] _e_3377;
    (* src = "src/tta.spade:249,9" *)
    logic[43:0] _e_3384;
    (* src = "src/tta.spade:249,9" *)
    logic[10:0] _e_3381;
    (* src = "src/tta.spade:249,9" *)
    logic[32:0] _e_3383;
    (* src = "src/tta.spade:249,32" *)
    logic[31:0] x_n42;
    logic _e_8774;
    logic _e_8776;
    logic _e_8778;
    logic _e_8779;
    (* src = "src/tta.spade:249,63" *)
    logic[2:0] _e_3387;
    (* src = "src/tta.spade:249,49" *)
    logic[42:0] _e_3386;
    (* src = "src/tta.spade:249,44" *)
    logic[43:0] _e_3385;
    (* src = "src/tta.spade:250,9" *)
    logic[43:0] _e_3392;
    (* src = "src/tta.spade:250,9" *)
    logic[10:0] _e_3389;
    (* src = "src/tta.spade:250,9" *)
    logic[32:0] _e_3391;
    (* src = "src/tta.spade:250,32" *)
    logic[31:0] x_n43;
    logic _e_8782;
    logic _e_8784;
    logic _e_8786;
    logic _e_8787;
    (* src = "src/tta.spade:250,63" *)
    logic[2:0] _e_3395;
    (* src = "src/tta.spade:250,49" *)
    logic[42:0] _e_3394;
    (* src = "src/tta.spade:250,44" *)
    logic[43:0] _e_3393;
    (* src = "src/tta.spade:251,9" *)
    logic[43:0] _e_3400;
    (* src = "src/tta.spade:251,9" *)
    logic[10:0] _e_3397;
    (* src = "src/tta.spade:251,9" *)
    logic[32:0] _e_3399;
    (* src = "src/tta.spade:251,32" *)
    logic[31:0] x_n44;
    logic _e_8790;
    logic _e_8792;
    logic _e_8794;
    logic _e_8795;
    (* src = "src/tta.spade:251,63" *)
    logic[2:0] _e_3403;
    (* src = "src/tta.spade:251,49" *)
    logic[42:0] _e_3402;
    (* src = "src/tta.spade:251,44" *)
    logic[43:0] _e_3401;
    (* src = "src/tta.spade:252,9" *)
    logic[43:0] _e_3408;
    (* src = "src/tta.spade:252,9" *)
    logic[10:0] _e_3405;
    (* src = "src/tta.spade:252,9" *)
    logic[32:0] _e_3407;
    (* src = "src/tta.spade:252,32" *)
    logic[31:0] x_n45;
    logic _e_8798;
    logic _e_8800;
    logic _e_8802;
    logic _e_8803;
    (* src = "src/tta.spade:252,63" *)
    logic[2:0] _e_3411;
    (* src = "src/tta.spade:252,49" *)
    logic[42:0] _e_3410;
    (* src = "src/tta.spade:252,44" *)
    logic[43:0] _e_3409;
    (* src = "src/tta.spade:254,9" *)
    logic[43:0] _e_3416;
    (* src = "src/tta.spade:254,9" *)
    logic[10:0] _e_3413;
    (* src = "src/tta.spade:254,9" *)
    logic[32:0] _e_3415;
    (* src = "src/tta.spade:254,34" *)
    logic[31:0] x_n46;
    logic _e_8806;
    logic _e_8808;
    logic _e_8810;
    logic _e_8811;
    (* src = "src/tta.spade:254,66" *)
    logic[2:0] _e_3419;
    (* src = "src/tta.spade:254,51" *)
    logic[42:0] _e_3418;
    (* src = "src/tta.spade:254,46" *)
    logic[43:0] _e_3417;
    (* src = "src/tta.spade:255,9" *)
    logic[43:0] _e_3424;
    (* src = "src/tta.spade:255,9" *)
    logic[10:0] _e_3421;
    (* src = "src/tta.spade:255,9" *)
    logic[32:0] _e_3423;
    (* src = "src/tta.spade:255,34" *)
    logic[31:0] x_n47;
    logic _e_8814;
    logic _e_8816;
    logic _e_8818;
    logic _e_8819;
    (* src = "src/tta.spade:255,66" *)
    logic[2:0] _e_3427;
    (* src = "src/tta.spade:255,51" *)
    logic[42:0] _e_3426;
    (* src = "src/tta.spade:255,46" *)
    logic[43:0] _e_3425;
    (* src = "src/tta.spade:256,9" *)
    logic[43:0] _e_3432;
    (* src = "src/tta.spade:256,9" *)
    logic[10:0] _e_3429;
    (* src = "src/tta.spade:256,9" *)
    logic[32:0] _e_3431;
    (* src = "src/tta.spade:256,34" *)
    logic[31:0] x_n48;
    logic _e_8822;
    logic _e_8824;
    logic _e_8826;
    logic _e_8827;
    (* src = "src/tta.spade:256,66" *)
    logic[2:0] _e_3435;
    (* src = "src/tta.spade:256,51" *)
    logic[42:0] _e_3434;
    (* src = "src/tta.spade:256,46" *)
    logic[43:0] _e_3433;
    (* src = "src/tta.spade:257,9" *)
    logic[43:0] _e_3440;
    (* src = "src/tta.spade:257,9" *)
    logic[10:0] _e_3437;
    (* src = "src/tta.spade:257,9" *)
    logic[32:0] _e_3439;
    (* src = "src/tta.spade:257,34" *)
    logic[31:0] x_n49;
    logic _e_8830;
    logic _e_8832;
    logic _e_8834;
    logic _e_8835;
    (* src = "src/tta.spade:257,66" *)
    logic[2:0] _e_3443;
    (* src = "src/tta.spade:257,51" *)
    logic[42:0] _e_3442;
    (* src = "src/tta.spade:257,46" *)
    logic[43:0] _e_3441;
    (* src = "src/tta.spade:258,9" *)
    logic[43:0] _e_3448;
    (* src = "src/tta.spade:258,9" *)
    logic[10:0] _e_3445;
    (* src = "src/tta.spade:258,9" *)
    logic[32:0] _e_3447;
    (* src = "src/tta.spade:258,34" *)
    logic[31:0] x_n50;
    logic _e_8838;
    logic _e_8840;
    logic _e_8842;
    logic _e_8843;
    (* src = "src/tta.spade:258,66" *)
    logic[2:0] _e_3451;
    (* src = "src/tta.spade:258,51" *)
    logic[42:0] _e_3450;
    (* src = "src/tta.spade:258,46" *)
    logic[43:0] _e_3449;
    (* src = "src/tta.spade:259,9" *)
    logic[43:0] _e_3456;
    (* src = "src/tta.spade:259,9" *)
    logic[10:0] _e_3453;
    (* src = "src/tta.spade:259,9" *)
    logic[32:0] _e_3455;
    (* src = "src/tta.spade:259,35" *)
    logic[31:0] x_n51;
    logic _e_8846;
    logic _e_8848;
    logic _e_8850;
    logic _e_8851;
    (* src = "src/tta.spade:259,67" *)
    logic[2:0] _e_3459;
    (* src = "src/tta.spade:259,52" *)
    logic[42:0] _e_3458;
    (* src = "src/tta.spade:259,47" *)
    logic[43:0] _e_3457;
    (* src = "src/tta.spade:261,9" *)
    logic[43:0] _e_3464;
    (* src = "src/tta.spade:261,9" *)
    logic[10:0] _e_3461;
    (* src = "src/tta.spade:261,9" *)
    logic[32:0] _e_3463;
    (* src = "src/tta.spade:261,32" *)
    logic[31:0] x_n52;
    logic _e_8854;
    logic _e_8856;
    logic _e_8858;
    logic _e_8859;
    (* src = "src/tta.spade:261,49" *)
    logic[42:0] _e_3466;
    (* src = "src/tta.spade:261,44" *)
    logic[43:0] _e_3465;
    (* src = "src/tta.spade:262,9" *)
    logic[43:0] _e_3471;
    (* src = "src/tta.spade:262,9" *)
    logic[10:0] _e_3468;
    (* src = "src/tta.spade:262,9" *)
    logic[32:0] _e_3470;
    (* src = "src/tta.spade:262,32" *)
    logic[31:0] x_n53;
    logic _e_8862;
    logic _e_8864;
    logic _e_8866;
    logic _e_8867;
    (* src = "src/tta.spade:262,49" *)
    logic[42:0] _e_3473;
    (* src = "src/tta.spade:262,44" *)
    logic[43:0] _e_3472;
    (* src = "src/tta.spade:264,9" *)
    logic[43:0] _e_3478;
    (* src = "src/tta.spade:264,9" *)
    logic[10:0] _e_3475;
    (* src = "src/tta.spade:264,9" *)
    logic[32:0] _e_3477;
    (* src = "src/tta.spade:264,32" *)
    logic[31:0] x_n54;
    logic _e_8870;
    logic _e_8872;
    logic _e_8874;
    logic _e_8875;
    (* src = "src/tta.spade:264,49" *)
    logic[42:0] _e_3480;
    (* src = "src/tta.spade:264,44" *)
    logic[43:0] _e_3479;
    (* src = "src/tta.spade:265,9" *)
    logic[43:0] _e_3485;
    (* src = "src/tta.spade:265,9" *)
    logic[10:0] _e_3482;
    (* src = "src/tta.spade:265,9" *)
    logic[32:0] _e_3484;
    (* src = "src/tta.spade:265,32" *)
    logic[31:0] x_n55;
    logic _e_8878;
    logic _e_8880;
    logic _e_8882;
    logic _e_8883;
    (* src = "src/tta.spade:265,49" *)
    logic[42:0] _e_3487;
    (* src = "src/tta.spade:265,44" *)
    logic[43:0] _e_3486;
    (* src = "src/tta.spade:267,9" *)
    logic[43:0] _e_3492;
    (* src = "src/tta.spade:267,9" *)
    logic[10:0] _e_3489;
    (* src = "src/tta.spade:267,9" *)
    logic[32:0] _e_3491;
    (* src = "src/tta.spade:267,37" *)
    logic[31:0] x_n56;
    logic _e_8886;
    logic _e_8888;
    logic _e_8890;
    logic _e_8891;
    (* src = "src/tta.spade:267,54" *)
    logic[42:0] _e_3494;
    (* src = "src/tta.spade:267,49" *)
    logic[43:0] _e_3493;
    (* src = "src/tta.spade:269,9" *)
    logic[43:0] _e_3499;
    (* src = "src/tta.spade:269,9" *)
    logic[10:0] _e_3496;
    (* src = "src/tta.spade:269,9" *)
    logic[32:0] _e_3498;
    (* src = "src/tta.spade:269,27" *)
    logic[31:0] x_n57;
    logic _e_8894;
    logic _e_8896;
    logic _e_8898;
    logic _e_8899;
    (* src = "src/tta.spade:269,44" *)
    logic[42:0] _e_3501;
    (* src = "src/tta.spade:269,39" *)
    logic[43:0] _e_3500;
    (* src = "src/tta.spade:270,9" *)
    logic[43:0] _e_3506;
    (* src = "src/tta.spade:270,9" *)
    logic[10:0] _e_3503;
    (* src = "src/tta.spade:270,9" *)
    logic[32:0] _e_3505;
    (* src = "src/tta.spade:270,27" *)
    logic[31:0] x_n58;
    logic _e_8902;
    logic _e_8904;
    logic _e_8906;
    logic _e_8907;
    (* src = "src/tta.spade:270,44" *)
    logic[42:0] _e_3508;
    (* src = "src/tta.spade:270,39" *)
    logic[43:0] _e_3507;
    (* src = "src/tta.spade:271,9" *)
    logic[43:0] _e_3513;
    (* src = "src/tta.spade:271,9" *)
    logic[10:0] _e_3510;
    (* src = "src/tta.spade:271,9" *)
    logic[32:0] _e_3512;
    (* src = "src/tta.spade:271,27" *)
    logic[31:0] x_n59;
    logic _e_8910;
    logic _e_8912;
    logic _e_8914;
    logic _e_8915;
    (* src = "src/tta.spade:271,59" *)
    logic _e_3516;
    (* src = "src/tta.spade:271,44" *)
    logic[42:0] _e_3515;
    (* src = "src/tta.spade:271,39" *)
    logic[43:0] _e_3514;
    (* src = "src/tta.spade:273,9" *)
    logic[43:0] _e_3522;
    (* src = "src/tta.spade:273,9" *)
    logic[10:0] _e_3519;
    (* src = "src/tta.spade:273,9" *)
    logic[32:0] _e_3521;
    (* src = "src/tta.spade:273,26" *)
    logic[31:0] x_n60;
    logic _e_8918;
    logic _e_8920;
    logic _e_8922;
    logic _e_8923;
    (* src = "src/tta.spade:273,57" *)
    logic _e_3525;
    (* src = "src/tta.spade:273,43" *)
    logic[42:0] _e_3524;
    (* src = "src/tta.spade:273,38" *)
    logic[43:0] _e_3523;
    (* src = "src/tta.spade:274,9" *)
    logic[43:0] _e_3531;
    (* src = "src/tta.spade:274,9" *)
    logic[10:0] _e_3528;
    (* src = "src/tta.spade:274,9" *)
    logic[32:0] _e_3530;
    (* src = "src/tta.spade:274,27" *)
    logic[31:0] x_n61;
    logic _e_8926;
    logic _e_8928;
    logic _e_8930;
    logic _e_8931;
    (* src = "src/tta.spade:274,44" *)
    logic[42:0] _e_3533;
    (* src = "src/tta.spade:274,39" *)
    logic[43:0] _e_3532;
    (* src = "src/tta.spade:275,9" *)
    logic[43:0] _e_3538;
    (* src = "src/tta.spade:275,9" *)
    logic[10:0] _e_3535;
    (* src = "src/tta.spade:275,9" *)
    logic[32:0] _e_3537;
    (* src = "src/tta.spade:275,27" *)
    logic[31:0] x_n62;
    logic _e_8934;
    logic _e_8936;
    logic _e_8938;
    logic _e_8939;
    (* src = "src/tta.spade:275,44" *)
    logic[42:0] _e_3540;
    (* src = "src/tta.spade:275,39" *)
    logic[43:0] _e_3539;
    (* src = "src/tta.spade:277,9" *)
    logic[43:0] _e_3545;
    (* src = "src/tta.spade:277,9" *)
    logic[10:0] _e_3542;
    (* src = "src/tta.spade:277,9" *)
    logic[32:0] _e_3544;
    (* src = "src/tta.spade:277,26" *)
    logic[31:0] x_n63;
    logic _e_8942;
    logic _e_8944;
    logic _e_8946;
    logic _e_8947;
    (* src = "src/tta.spade:277,43" *)
    logic[42:0] _e_3547;
    (* src = "src/tta.spade:277,38" *)
    logic[43:0] _e_3546;
    (* src = "src/tta.spade:278,9" *)
    logic[43:0] _e_3552;
    (* src = "src/tta.spade:278,9" *)
    logic[10:0] _e_3549;
    (* src = "src/tta.spade:278,9" *)
    logic[32:0] _e_3551;
    (* src = "src/tta.spade:278,26" *)
    logic[31:0] x_n64;
    logic _e_8950;
    logic _e_8952;
    logic _e_8954;
    logic _e_8955;
    (* src = "src/tta.spade:278,43" *)
    logic[42:0] _e_3554;
    (* src = "src/tta.spade:278,38" *)
    logic[43:0] _e_3553;
    (* src = "src/tta.spade:279,9" *)
    logic[43:0] _e_3559;
    (* src = "src/tta.spade:279,9" *)
    logic[10:0] _e_3556;
    (* src = "src/tta.spade:279,9" *)
    logic[32:0] _e_3558;
    (* src = "src/tta.spade:279,25" *)
    logic[31:0] x_n65;
    logic _e_8958;
    logic _e_8960;
    logic _e_8962;
    logic _e_8963;
    (* src = "src/tta.spade:279,42" *)
    logic[42:0] _e_3561;
    (* src = "src/tta.spade:279,37" *)
    logic[43:0] _e_3560;
    (* src = "src/tta.spade:280,9" *)
    logic[43:0] _e_3566;
    (* src = "src/tta.spade:280,9" *)
    logic[10:0] _e_3563;
    (* src = "src/tta.spade:280,9" *)
    logic[32:0] _e_3565;
    (* src = "src/tta.spade:280,26" *)
    logic[31:0] x_n66;
    logic _e_8966;
    logic _e_8968;
    logic _e_8970;
    logic _e_8971;
    (* src = "src/tta.spade:280,43" *)
    logic[42:0] _e_3568;
    (* src = "src/tta.spade:280,38" *)
    logic[43:0] _e_3567;
    (* src = "src/tta.spade:282,9" *)
    logic[43:0] _e_3573;
    (* src = "src/tta.spade:282,9" *)
    logic[10:0] _e_3570;
    (* src = "src/tta.spade:282,9" *)
    logic[32:0] _e_3572;
    (* src = "src/tta.spade:282,26" *)
    logic[31:0] x_n67;
    logic _e_8974;
    logic _e_8976;
    logic _e_8978;
    logic _e_8979;
    (* src = "src/tta.spade:282,43" *)
    logic[42:0] _e_3575;
    (* src = "src/tta.spade:282,38" *)
    logic[43:0] _e_3574;
    (* src = "src/tta.spade:284,9" *)
    logic[43:0] _e_3580;
    (* src = "src/tta.spade:284,9" *)
    logic[10:0] _e_3577;
    (* src = "src/tta.spade:284,9" *)
    logic[32:0] _e_3579;
    (* src = "src/tta.spade:284,28" *)
    logic[31:0] x_n68;
    logic _e_8982;
    logic _e_8984;
    logic _e_8986;
    logic _e_8987;
    (* src = "src/tta.spade:284,45" *)
    logic[42:0] _e_3582;
    (* src = "src/tta.spade:284,40" *)
    logic[43:0] _e_3581;
    (* src = "src/tta.spade:285,9" *)
    logic[43:0] _e_3587;
    (* src = "src/tta.spade:285,9" *)
    logic[10:0] _e_3584;
    (* src = "src/tta.spade:285,9" *)
    logic[32:0] _e_3586;
    (* src = "src/tta.spade:285,33" *)
    logic[31:0] x_n69;
    logic _e_8990;
    logic _e_8992;
    logic _e_8994;
    logic _e_8995;
    (* src = "src/tta.spade:285,50" *)
    logic[42:0] _e_3589;
    (* src = "src/tta.spade:285,45" *)
    logic[43:0] _e_3588;
    (* src = "src/tta.spade:286,9" *)
    logic[43:0] _e_3594;
    (* src = "src/tta.spade:286,9" *)
    logic[10:0] _e_3591;
    (* src = "src/tta.spade:286,9" *)
    logic[32:0] _e_3593;
    (* src = "src/tta.spade:286,32" *)
    logic[31:0] x_n70;
    logic _e_8998;
    logic _e_9000;
    logic _e_9002;
    logic _e_9003;
    (* src = "src/tta.spade:286,49" *)
    logic[42:0] _e_3596;
    (* src = "src/tta.spade:286,44" *)
    logic[43:0] _e_3595;
    (* src = "src/tta.spade:288,9" *)
    logic[43:0] _e_3600;
    (* src = "src/tta.spade:288,9" *)
    logic[10:0] _e_3597;
    (* src = "src/tta.spade:288,9" *)
    logic[32:0] _e_3599;
    (* src = "src/tta.spade:288,32" *)
    logic[31:0] x_n71;
    logic _e_9006;
    logic _e_9008;
    logic _e_9010;
    logic _e_9011;
    (* src = "src/tta.spade:288,63" *)
    logic[7:0] _e_3603;
    (* src = "src/tta.spade:288,49" *)
    logic[42:0] _e_3602;
    (* src = "src/tta.spade:288,44" *)
    logic[43:0] _e_3601;
    (* src = "src/tta.spade:289,9" *)
    logic[43:0] _e_3608;
    (* src = "src/tta.spade:289,9" *)
    logic[10:0] _e_3605;
    (* src = "src/tta.spade:289,9" *)
    logic[32:0] _e_3607;
    (* src = "src/tta.spade:289,32" *)
    logic[31:0] x_n72;
    logic _e_9014;
    logic _e_9016;
    logic _e_9018;
    logic _e_9019;
    (* src = "src/tta.spade:289,49" *)
    logic[42:0] _e_3610;
    (* src = "src/tta.spade:289,44" *)
    logic[43:0] _e_3609;
    (* src = "src/tta.spade:291,9" *)
    logic[43:0] _e_3614;
    (* src = "src/tta.spade:291,9" *)
    logic[10:0] _e_3611;
    (* src = "src/tta.spade:291,9" *)
    logic[32:0] _e_3613;
    (* src = "src/tta.spade:291,33" *)
    logic[31:0] x_n73;
    logic _e_9022;
    logic _e_9024;
    logic _e_9026;
    logic _e_9027;
    (* src = "src/tta.spade:291,65" *)
    logic[7:0] _e_3617;
    (* src = "src/tta.spade:291,50" *)
    logic[42:0] _e_3616;
    (* src = "src/tta.spade:291,45" *)
    logic[43:0] _e_3615;
    (* src = "src/tta.spade:292,9" *)
    logic[43:0] _e_3622;
    (* src = "src/tta.spade:292,9" *)
    logic[10:0] _e_3619;
    (* src = "src/tta.spade:292,9" *)
    logic[32:0] _e_3621;
    (* src = "src/tta.spade:292,33" *)
    logic[31:0] x_n74;
    logic _e_9030;
    logic _e_9032;
    logic _e_9034;
    logic _e_9035;
    (* src = "src/tta.spade:292,50" *)
    logic[42:0] _e_3624;
    (* src = "src/tta.spade:292,45" *)
    logic[43:0] _e_3623;
    (* src = "src/tta.spade:294,9" *)
    logic[43:0] \_ ;
    (* src = "src/tta.spade:294,14" *)
    logic[43:0] _e_3626;
    (* src = "src/tta.spade:197,5" *)
    logic[43:0] _e_3050;
    assign _e_3051 = {\dst , \v };
    assign _e_3058 = _e_3051;
    assign _e_3055 = _e_3051[43:33];
    assign \i  = _e_3055[3:0];
    assign _e_3057 = _e_3051[32:0];
    assign \x  = _e_3057[31:0];
    assign _e_8436 = _e_3055[10:4] == 7'd0;
    localparam[0:0] _e_8437 = 1;
    assign _e_8438 = _e_8436 && _e_8437;
    assign _e_8440 = _e_3057[32] == 1'd1;
    localparam[0:0] _e_8441 = 1;
    assign _e_8442 = _e_8440 && _e_8441;
    assign _e_8443 = _e_8438 && _e_8442;
    assign _e_3060 = {6'd0, \i , \x , 1'bX};
    assign _e_3059 = {1'd1, _e_3060};
    assign _e_3066 = _e_3051;
    assign _e_3063 = _e_3051[43:33];
    assign _e_3065 = _e_3051[32:0];
    assign x_n1 = _e_3065[31:0];
    assign _e_8446 = _e_3063[10:4] == 7'd1;
    assign _e_8448 = _e_3065[32] == 1'd1;
    localparam[0:0] _e_8449 = 1;
    assign _e_8450 = _e_8448 && _e_8449;
    assign _e_8451 = _e_8446 && _e_8450;
    assign _e_3068 = {6'd1, x_n1, 5'bX};
    assign _e_3067 = {1'd1, _e_3068};
    assign _e_3073 = _e_3051;
    assign _e_3070 = _e_3051[43:33];
    assign _e_3072 = _e_3051[32:0];
    assign x_n2 = _e_3072[31:0];
    assign _e_8454 = _e_3070[10:4] == 7'd2;
    assign _e_8456 = _e_3072[32] == 1'd1;
    localparam[0:0] _e_8457 = 1;
    assign _e_8458 = _e_8456 && _e_8457;
    assign _e_8459 = _e_8454 && _e_8458;
    assign _e_3076 = {5'd0};
    assign _e_3075 = {6'd2, _e_3076, x_n2};
    assign _e_3074 = {1'd1, _e_3075};
    assign _e_3081 = _e_3051;
    assign _e_3078 = _e_3051[43:33];
    assign _e_3080 = _e_3051[32:0];
    assign x_n3 = _e_3080[31:0];
    assign _e_8462 = _e_3078[10:4] == 7'd3;
    assign _e_8464 = _e_3080[32] == 1'd1;
    localparam[0:0] _e_8465 = 1;
    assign _e_8466 = _e_8464 && _e_8465;
    assign _e_8467 = _e_8462 && _e_8466;
    assign _e_3084 = {5'd1};
    assign _e_3083 = {6'd2, _e_3084, x_n3};
    assign _e_3082 = {1'd1, _e_3083};
    assign _e_3089 = _e_3051;
    assign _e_3086 = _e_3051[43:33];
    assign _e_3088 = _e_3051[32:0];
    assign x_n4 = _e_3088[31:0];
    assign _e_8470 = _e_3086[10:4] == 7'd4;
    assign _e_8472 = _e_3088[32] == 1'd1;
    localparam[0:0] _e_8473 = 1;
    assign _e_8474 = _e_8472 && _e_8473;
    assign _e_8475 = _e_8470 && _e_8474;
    assign _e_3092 = {5'd2};
    assign _e_3091 = {6'd2, _e_3092, x_n4};
    assign _e_3090 = {1'd1, _e_3091};
    assign _e_3097 = _e_3051;
    assign _e_3094 = _e_3051[43:33];
    assign _e_3096 = _e_3051[32:0];
    assign x_n5 = _e_3096[31:0];
    assign _e_8478 = _e_3094[10:4] == 7'd5;
    assign _e_8480 = _e_3096[32] == 1'd1;
    localparam[0:0] _e_8481 = 1;
    assign _e_8482 = _e_8480 && _e_8481;
    assign _e_8483 = _e_8478 && _e_8482;
    assign _e_3100 = {5'd3};
    assign _e_3099 = {6'd2, _e_3100, x_n5};
    assign _e_3098 = {1'd1, _e_3099};
    assign _e_3105 = _e_3051;
    assign _e_3102 = _e_3051[43:33];
    assign _e_3104 = _e_3051[32:0];
    assign x_n6 = _e_3104[31:0];
    assign _e_8486 = _e_3102[10:4] == 7'd6;
    assign _e_8488 = _e_3104[32] == 1'd1;
    localparam[0:0] _e_8489 = 1;
    assign _e_8490 = _e_8488 && _e_8489;
    assign _e_8491 = _e_8486 && _e_8490;
    assign _e_3108 = {5'd4};
    assign _e_3107 = {6'd2, _e_3108, x_n6};
    assign _e_3106 = {1'd1, _e_3107};
    assign _e_3113 = _e_3051;
    assign _e_3110 = _e_3051[43:33];
    assign _e_3112 = _e_3051[32:0];
    assign x_n7 = _e_3112[31:0];
    assign _e_8494 = _e_3110[10:4] == 7'd8;
    assign _e_8496 = _e_3112[32] == 1'd1;
    localparam[0:0] _e_8497 = 1;
    assign _e_8498 = _e_8496 && _e_8497;
    assign _e_8499 = _e_8494 && _e_8498;
    assign _e_3116 = {5'd6};
    assign _e_3115 = {6'd2, _e_3116, x_n7};
    assign _e_3114 = {1'd1, _e_3115};
    assign _e_3121 = _e_3051;
    assign _e_3118 = _e_3051[43:33];
    assign _e_3120 = _e_3051[32:0];
    assign x_n8 = _e_3120[31:0];
    assign _e_8502 = _e_3118[10:4] == 7'd9;
    assign _e_8504 = _e_3120[32] == 1'd1;
    localparam[0:0] _e_8505 = 1;
    assign _e_8506 = _e_8504 && _e_8505;
    assign _e_8507 = _e_8502 && _e_8506;
    assign _e_3124 = {5'd7};
    assign _e_3123 = {6'd2, _e_3124, x_n8};
    assign _e_3122 = {1'd1, _e_3123};
    assign _e_3129 = _e_3051;
    assign _e_3126 = _e_3051[43:33];
    assign _e_3128 = _e_3051[32:0];
    assign x_n9 = _e_3128[31:0];
    assign _e_8510 = _e_3126[10:4] == 7'd10;
    assign _e_8512 = _e_3128[32] == 1'd1;
    localparam[0:0] _e_8513 = 1;
    assign _e_8514 = _e_8512 && _e_8513;
    assign _e_8515 = _e_8510 && _e_8514;
    assign _e_3132 = {5'd8};
    assign _e_3131 = {6'd2, _e_3132, x_n9};
    assign _e_3130 = {1'd1, _e_3131};
    assign _e_3137 = _e_3051;
    assign _e_3134 = _e_3051[43:33];
    assign _e_3136 = _e_3051[32:0];
    assign x_n10 = _e_3136[31:0];
    assign _e_8518 = _e_3134[10:4] == 7'd11;
    assign _e_8520 = _e_3136[32] == 1'd1;
    localparam[0:0] _e_8521 = 1;
    assign _e_8522 = _e_8520 && _e_8521;
    assign _e_8523 = _e_8518 && _e_8522;
    assign _e_3140 = {5'd9};
    assign _e_3139 = {6'd2, _e_3140, x_n10};
    assign _e_3138 = {1'd1, _e_3139};
    assign _e_3145 = _e_3051;
    assign _e_3142 = _e_3051[43:33];
    assign _e_3144 = _e_3051[32:0];
    assign x_n11 = _e_3144[31:0];
    assign _e_8526 = _e_3142[10:4] == 7'd12;
    assign _e_8528 = _e_3144[32] == 1'd1;
    localparam[0:0] _e_8529 = 1;
    assign _e_8530 = _e_8528 && _e_8529;
    assign _e_8531 = _e_8526 && _e_8530;
    assign _e_3148 = {5'd10};
    assign _e_3147 = {6'd2, _e_3148, x_n11};
    assign _e_3146 = {1'd1, _e_3147};
    assign _e_3153 = _e_3051;
    assign _e_3150 = _e_3051[43:33];
    assign _e_3152 = _e_3051[32:0];
    assign x_n12 = _e_3152[31:0];
    assign _e_8534 = _e_3150[10:4] == 7'd13;
    assign _e_8536 = _e_3152[32] == 1'd1;
    localparam[0:0] _e_8537 = 1;
    assign _e_8538 = _e_8536 && _e_8537;
    assign _e_8539 = _e_8534 && _e_8538;
    assign _e_3156 = {5'd11};
    assign _e_3155 = {6'd2, _e_3156, x_n12};
    assign _e_3154 = {1'd1, _e_3155};
    assign _e_3161 = _e_3051;
    assign _e_3158 = _e_3051[43:33];
    assign _e_3160 = _e_3051[32:0];
    assign x_n13 = _e_3160[31:0];
    assign _e_8542 = _e_3158[10:4] == 7'd14;
    assign _e_8544 = _e_3160[32] == 1'd1;
    localparam[0:0] _e_8545 = 1;
    assign _e_8546 = _e_8544 && _e_8545;
    assign _e_8547 = _e_8542 && _e_8546;
    assign _e_3164 = {5'd12};
    assign _e_3163 = {6'd2, _e_3164, x_n13};
    assign _e_3162 = {1'd1, _e_3163};
    assign _e_3169 = _e_3051;
    assign _e_3166 = _e_3051[43:33];
    assign _e_3168 = _e_3051[32:0];
    assign x_n14 = _e_3168[31:0];
    assign _e_8550 = _e_3166[10:4] == 7'd15;
    assign _e_8552 = _e_3168[32] == 1'd1;
    localparam[0:0] _e_8553 = 1;
    assign _e_8554 = _e_8552 && _e_8553;
    assign _e_8555 = _e_8550 && _e_8554;
    assign _e_3172 = {5'd13};
    assign _e_3171 = {6'd2, _e_3172, x_n14};
    assign _e_3170 = {1'd1, _e_3171};
    assign _e_3177 = _e_3051;
    assign _e_3174 = _e_3051[43:33];
    assign _e_3176 = _e_3051[32:0];
    assign x_n15 = _e_3176[31:0];
    assign _e_8558 = _e_3174[10:4] == 7'd16;
    assign _e_8560 = _e_3176[32] == 1'd1;
    localparam[0:0] _e_8561 = 1;
    assign _e_8562 = _e_8560 && _e_8561;
    assign _e_8563 = _e_8558 && _e_8562;
    assign _e_3180 = {5'd14};
    assign _e_3179 = {6'd2, _e_3180, x_n15};
    assign _e_3178 = {1'd1, _e_3179};
    assign _e_3185 = _e_3051;
    assign _e_3182 = _e_3051[43:33];
    assign _e_3184 = _e_3051[32:0];
    assign x_n16 = _e_3184[31:0];
    assign _e_8566 = _e_3182[10:4] == 7'd17;
    assign _e_8568 = _e_3184[32] == 1'd1;
    localparam[0:0] _e_8569 = 1;
    assign _e_8570 = _e_8568 && _e_8569;
    assign _e_8571 = _e_8566 && _e_8570;
    assign _e_3188 = {5'd15};
    assign _e_3187 = {6'd2, _e_3188, x_n16};
    assign _e_3186 = {1'd1, _e_3187};
    assign _e_3193 = _e_3051;
    assign _e_3190 = _e_3051[43:33];
    assign _e_3192 = _e_3051[32:0];
    assign x_n17 = _e_3192[31:0];
    assign _e_8574 = _e_3190[10:4] == 7'd18;
    assign _e_8576 = _e_3192[32] == 1'd1;
    localparam[0:0] _e_8577 = 1;
    assign _e_8578 = _e_8576 && _e_8577;
    assign _e_8579 = _e_8574 && _e_8578;
    assign _e_3196 = {5'd16};
    assign _e_3195 = {6'd2, _e_3196, x_n17};
    assign _e_3194 = {1'd1, _e_3195};
    assign _e_3201 = _e_3051;
    assign _e_3198 = _e_3051[43:33];
    assign _e_3200 = _e_3051[32:0];
    assign x_n18 = _e_3200[31:0];
    assign _e_8582 = _e_3198[10:4] == 7'd19;
    assign _e_8584 = _e_3200[32] == 1'd1;
    localparam[0:0] _e_8585 = 1;
    assign _e_8586 = _e_8584 && _e_8585;
    assign _e_8587 = _e_8582 && _e_8586;
    assign _e_3204 = {3'd0};
    assign _e_3203 = {6'd40, _e_3204, x_n18, 2'bX};
    assign _e_3202 = {1'd1, _e_3203};
    assign _e_3209 = _e_3051;
    assign _e_3206 = _e_3051[43:33];
    assign _e_3208 = _e_3051[32:0];
    assign x_n19 = _e_3208[31:0];
    assign _e_8590 = _e_3206[10:4] == 7'd20;
    assign _e_8592 = _e_3208[32] == 1'd1;
    localparam[0:0] _e_8593 = 1;
    assign _e_8594 = _e_8592 && _e_8593;
    assign _e_8595 = _e_8590 && _e_8594;
    assign _e_3212 = {3'd1};
    assign _e_3211 = {6'd40, _e_3212, x_n19, 2'bX};
    assign _e_3210 = {1'd1, _e_3211};
    assign _e_3217 = _e_3051;
    assign _e_3214 = _e_3051[43:33];
    assign _e_3216 = _e_3051[32:0];
    assign x_n20 = _e_3216[31:0];
    assign _e_8598 = _e_3214[10:4] == 7'd21;
    assign _e_8600 = _e_3216[32] == 1'd1;
    localparam[0:0] _e_8601 = 1;
    assign _e_8602 = _e_8600 && _e_8601;
    assign _e_8603 = _e_8598 && _e_8602;
    assign _e_3220 = {3'd2};
    assign _e_3219 = {6'd40, _e_3220, x_n20, 2'bX};
    assign _e_3218 = {1'd1, _e_3219};
    assign _e_3225 = _e_3051;
    assign _e_3222 = _e_3051[43:33];
    assign _e_3224 = _e_3051[32:0];
    assign x_n21 = _e_3224[31:0];
    assign _e_8606 = _e_3222[10:4] == 7'd22;
    assign _e_8608 = _e_3224[32] == 1'd1;
    localparam[0:0] _e_8609 = 1;
    assign _e_8610 = _e_8608 && _e_8609;
    assign _e_8611 = _e_8606 && _e_8610;
    assign _e_3228 = {3'd3};
    assign _e_3227 = {6'd40, _e_3228, x_n21, 2'bX};
    assign _e_3226 = {1'd1, _e_3227};
    assign _e_3233 = _e_3051;
    assign _e_3230 = _e_3051[43:33];
    assign _e_3232 = _e_3051[32:0];
    assign x_n22 = _e_3232[31:0];
    assign _e_8614 = _e_3230[10:4] == 7'd23;
    assign _e_8616 = _e_3232[32] == 1'd1;
    localparam[0:0] _e_8617 = 1;
    assign _e_8618 = _e_8616 && _e_8617;
    assign _e_8619 = _e_8614 && _e_8618;
    assign _e_3236 = {3'd4};
    assign _e_3235 = {6'd40, _e_3236, x_n22, 2'bX};
    assign _e_3234 = {1'd1, _e_3235};
    assign _e_3241 = _e_3051;
    assign _e_3238 = _e_3051[43:33];
    assign _e_3240 = _e_3051[32:0];
    assign x_n23 = _e_3240[31:0];
    assign _e_8622 = _e_3238[10:4] == 7'd24;
    assign _e_8624 = _e_3240[32] == 1'd1;
    localparam[0:0] _e_8625 = 1;
    assign _e_8626 = _e_8624 && _e_8625;
    assign _e_8627 = _e_8622 && _e_8626;
    assign _e_3244 = {3'd5};
    assign _e_3243 = {6'd40, _e_3244, x_n23, 2'bX};
    assign _e_3242 = {1'd1, _e_3243};
    assign _e_3249 = _e_3051;
    assign _e_3246 = _e_3051[43:33];
    assign _e_3248 = _e_3051[32:0];
    assign x_n24 = _e_3248[31:0];
    assign _e_8630 = _e_3246[10:4] == 7'd25;
    assign _e_8632 = _e_3248[32] == 1'd1;
    localparam[0:0] _e_8633 = 1;
    assign _e_8634 = _e_8632 && _e_8633;
    assign _e_8635 = _e_8630 && _e_8634;
    assign _e_3252 = {3'd6};
    assign _e_3251 = {6'd40, _e_3252, x_n24, 2'bX};
    assign _e_3250 = {1'd1, _e_3251};
    assign _e_3257 = _e_3051;
    assign _e_3254 = _e_3051[43:33];
    assign _e_3256 = _e_3051[32:0];
    assign x_n25 = _e_3256[31:0];
    assign _e_8638 = _e_3254[10:4] == 7'd26;
    assign _e_8640 = _e_3256[32] == 1'd1;
    localparam[0:0] _e_8641 = 1;
    assign _e_8642 = _e_8640 && _e_8641;
    assign _e_8643 = _e_8638 && _e_8642;
    assign _e_3260 = {3'd7};
    assign _e_3259 = {6'd40, _e_3260, x_n25, 2'bX};
    assign _e_3258 = {1'd1, _e_3259};
    assign _e_3265 = _e_3051;
    assign _e_3262 = _e_3051[43:33];
    assign _e_3264 = _e_3051[32:0];
    assign x_n26 = _e_3264[31:0];
    assign _e_8646 = _e_3262[10:4] == 7'd27;
    assign _e_8648 = _e_3264[32] == 1'd1;
    localparam[0:0] _e_8649 = 1;
    assign _e_8650 = _e_8648 && _e_8649;
    assign _e_8651 = _e_8646 && _e_8650;
    assign _e_3267 = {6'd14, x_n26, 5'bX};
    assign _e_3266 = {1'd1, _e_3267};
    assign _e_3272 = _e_3051;
    assign _e_3269 = _e_3051[43:33];
    assign _e_3271 = _e_3051[32:0];
    assign x_n27 = _e_3271[31:0];
    assign _e_8654 = _e_3269[10:4] == 7'd28;
    assign _e_8656 = _e_3271[32] == 1'd1;
    localparam[0:0] _e_8657 = 1;
    assign _e_8658 = _e_8656 && _e_8657;
    assign _e_8659 = _e_8654 && _e_8658;
    assign _e_3275 = {1'd0};
    assign _e_3274 = {6'd15, _e_3275, x_n27, 4'bX};
    assign _e_3273 = {1'd1, _e_3274};
    assign _e_3280 = _e_3051;
    assign _e_3277 = _e_3051[43:33];
    assign _e_3279 = _e_3051[32:0];
    assign x_n28 = _e_3279[31:0];
    assign _e_8662 = _e_3277[10:4] == 7'd29;
    assign _e_8664 = _e_3279[32] == 1'd1;
    localparam[0:0] _e_8665 = 1;
    assign _e_8666 = _e_8664 && _e_8665;
    assign _e_8667 = _e_8662 && _e_8666;
    assign _e_3283 = {1'd1};
    assign _e_3282 = {6'd15, _e_3283, x_n28, 4'bX};
    assign _e_3281 = {1'd1, _e_3282};
    assign _e_3288 = _e_3051;
    assign _e_3285 = _e_3051[43:33];
    assign _e_3287 = _e_3051[32:0];
    assign x_n29 = _e_3287[31:0];
    assign _e_8670 = _e_3285[10:4] == 7'd30;
    assign _e_8672 = _e_3287[32] == 1'd1;
    localparam[0:0] _e_8673 = 1;
    assign _e_8674 = _e_8672 && _e_8673;
    assign _e_8675 = _e_8670 && _e_8674;
    assign _e_3291 = x_n29[9:0];
    assign _e_3290 = {6'd3, _e_3291, 27'bX};
    assign _e_3289 = {1'd1, _e_3290};
    assign _e_3296 = _e_3051;
    assign _e_3293 = _e_3051[43:33];
    assign _e_3295 = _e_3051[32:0];
    assign x_n30 = _e_3295[31:0];
    assign _e_8678 = _e_3293[10:4] == 7'd31;
    assign _e_8680 = _e_3295[32] == 1'd1;
    localparam[0:0] _e_8681 = 1;
    assign _e_8682 = _e_8680 && _e_8681;
    assign _e_8683 = _e_8678 && _e_8682;
    assign _e_3299 = x_n30[9:0];
    assign _e_3298 = {6'd18, _e_3299, 27'bX};
    assign _e_3297 = {1'd1, _e_3298};
    assign _e_3304 = _e_3051;
    assign _e_3301 = _e_3051[43:33];
    assign _e_3303 = _e_3051[32:0];
    assign x_n31 = _e_3303[31:0];
    assign _e_8686 = _e_3301[10:4] == 7'd32;
    assign _e_8688 = _e_3303[32] == 1'd1;
    localparam[0:0] _e_8689 = 1;
    assign _e_8690 = _e_8688 && _e_8689;
    assign _e_8691 = _e_8686 && _e_8690;
    assign _e_3306 = {6'd19, x_n31, 5'bX};
    assign _e_3305 = {1'd1, _e_3306};
    assign _e_3311 = _e_3051;
    assign _e_3308 = _e_3051[43:33];
    assign _e_3310 = _e_3051[32:0];
    assign x_n32 = _e_3310[31:0];
    assign _e_8694 = _e_3308[10:4] == 7'd33;
    assign _e_8696 = _e_3310[32] == 1'd1;
    localparam[0:0] _e_8697 = 1;
    assign _e_8698 = _e_8696 && _e_8697;
    assign _e_8699 = _e_8694 && _e_8698;
    assign _e_3313 = {6'd4, x_n32, 5'bX};
    assign _e_3312 = {1'd1, _e_3313};
    assign _e_3318 = _e_3051;
    assign _e_3315 = _e_3051[43:33];
    assign _e_3317 = _e_3051[32:0];
    assign x_n33 = _e_3317[31:0];
    assign _e_8702 = _e_3315[10:4] == 7'd34;
    assign _e_8704 = _e_3317[32] == 1'd1;
    localparam[0:0] _e_8705 = 1;
    assign _e_8706 = _e_8704 && _e_8705;
    assign _e_8707 = _e_8702 && _e_8706;
    assign _e_3320 = {6'd5, x_n33, 5'bX};
    assign _e_3319 = {1'd1, _e_3320};
    assign _e_3325 = _e_3051;
    assign _e_3322 = _e_3051[43:33];
    assign _e_3324 = _e_3051[32:0];
    assign x_n34 = _e_3324[31:0];
    assign _e_8710 = _e_3322[10:4] == 7'd35;
    assign _e_8712 = _e_3324[32] == 1'd1;
    localparam[0:0] _e_8713 = 1;
    assign _e_8714 = _e_8712 && _e_8713;
    assign _e_8715 = _e_8710 && _e_8714;
    assign _e_3327 = {6'd6, x_n34, 5'bX};
    assign _e_3326 = {1'd1, _e_3327};
    assign _e_3332 = _e_3051;
    assign _e_3329 = _e_3051[43:33];
    assign _e_3331 = _e_3051[32:0];
    assign x_n35 = _e_3331[31:0];
    assign _e_8718 = _e_3329[10:4] == 7'd36;
    assign _e_8720 = _e_3331[32] == 1'd1;
    localparam[0:0] _e_8721 = 1;
    assign _e_8722 = _e_8720 && _e_8721;
    assign _e_8723 = _e_8718 && _e_8722;
    assign _e_3334 = {6'd7, x_n35, 5'bX};
    assign _e_3333 = {1'd1, _e_3334};
    assign _e_3339 = _e_3051;
    assign _e_3336 = _e_3051[43:33];
    assign _e_3338 = _e_3051[32:0];
    assign x_n36 = _e_3338[31:0];
    assign _e_8726 = _e_3336[10:4] == 7'd37;
    assign _e_8728 = _e_3338[32] == 1'd1;
    localparam[0:0] _e_8729 = 1;
    assign _e_8730 = _e_8728 && _e_8729;
    assign _e_8731 = _e_8726 && _e_8730;
    assign _e_3341 = {6'd8, x_n36, 5'bX};
    assign _e_3340 = {1'd1, _e_3341};
    assign _e_3346 = _e_3051;
    assign _e_3343 = _e_3051[43:33];
    assign _e_3345 = _e_3051[32:0];
    assign x_n37 = _e_3345[31:0];
    assign _e_8734 = _e_3343[10:4] == 7'd38;
    assign _e_8736 = _e_3345[32] == 1'd1;
    localparam[0:0] _e_8737 = 1;
    assign _e_8738 = _e_8736 && _e_8737;
    assign _e_8739 = _e_8734 && _e_8738;
    assign _e_3348 = {6'd9, x_n37, 5'bX};
    assign _e_3347 = {1'd1, _e_3348};
    assign _e_3353 = _e_3051;
    assign _e_3350 = _e_3051[43:33];
    assign _e_3352 = _e_3051[32:0];
    assign x_n38 = _e_3352[31:0];
    assign _e_8742 = _e_3350[10:4] == 7'd39;
    assign _e_8744 = _e_3352[32] == 1'd1;
    localparam[0:0] _e_8745 = 1;
    assign _e_8746 = _e_8744 && _e_8745;
    assign _e_8747 = _e_8742 && _e_8746;
    assign _e_3356 = x_n38[15:0];
    assign _e_3355 = {6'd10, _e_3356, 21'bX};
    assign _e_3354 = {1'd1, _e_3355};
    assign _e_3361 = _e_3051;
    assign _e_3358 = _e_3051[43:33];
    assign _e_3360 = _e_3051[32:0];
    assign x_n39 = _e_3360[31:0];
    assign _e_8750 = _e_3358[10:4] == 7'd40;
    assign _e_8752 = _e_3360[32] == 1'd1;
    localparam[0:0] _e_8753 = 1;
    assign _e_8754 = _e_8752 && _e_8753;
    assign _e_8755 = _e_8750 && _e_8754;
    assign _e_3363 = {6'd11, x_n39, 5'bX};
    assign _e_3362 = {1'd1, _e_3363};
    assign _e_3368 = _e_3051;
    assign _e_3365 = _e_3051[43:33];
    assign _e_3367 = _e_3051[32:0];
    assign x_n40 = _e_3367[31:0];
    assign _e_8758 = _e_3365[10:4] == 7'd41;
    assign _e_8760 = _e_3367[32] == 1'd1;
    localparam[0:0] _e_8761 = 1;
    assign _e_8762 = _e_8760 && _e_8761;
    assign _e_8763 = _e_8758 && _e_8762;
    assign _e_3371 = {3'd0};
    assign _e_3370 = {6'd12, _e_3371, x_n40, 2'bX};
    assign _e_3369 = {1'd1, _e_3370};
    assign _e_3376 = _e_3051;
    assign _e_3373 = _e_3051[43:33];
    assign _e_3375 = _e_3051[32:0];
    assign x_n41 = _e_3375[31:0];
    assign _e_8766 = _e_3373[10:4] == 7'd42;
    assign _e_8768 = _e_3375[32] == 1'd1;
    localparam[0:0] _e_8769 = 1;
    assign _e_8770 = _e_8768 && _e_8769;
    assign _e_8771 = _e_8766 && _e_8770;
    assign _e_3379 = {3'd1};
    assign _e_3378 = {6'd12, _e_3379, x_n41, 2'bX};
    assign _e_3377 = {1'd1, _e_3378};
    assign _e_3384 = _e_3051;
    assign _e_3381 = _e_3051[43:33];
    assign _e_3383 = _e_3051[32:0];
    assign x_n42 = _e_3383[31:0];
    assign _e_8774 = _e_3381[10:4] == 7'd43;
    assign _e_8776 = _e_3383[32] == 1'd1;
    localparam[0:0] _e_8777 = 1;
    assign _e_8778 = _e_8776 && _e_8777;
    assign _e_8779 = _e_8774 && _e_8778;
    assign _e_3387 = {3'd2};
    assign _e_3386 = {6'd12, _e_3387, x_n42, 2'bX};
    assign _e_3385 = {1'd1, _e_3386};
    assign _e_3392 = _e_3051;
    assign _e_3389 = _e_3051[43:33];
    assign _e_3391 = _e_3051[32:0];
    assign x_n43 = _e_3391[31:0];
    assign _e_8782 = _e_3389[10:4] == 7'd44;
    assign _e_8784 = _e_3391[32] == 1'd1;
    localparam[0:0] _e_8785 = 1;
    assign _e_8786 = _e_8784 && _e_8785;
    assign _e_8787 = _e_8782 && _e_8786;
    assign _e_3395 = {3'd3};
    assign _e_3394 = {6'd12, _e_3395, x_n43, 2'bX};
    assign _e_3393 = {1'd1, _e_3394};
    assign _e_3400 = _e_3051;
    assign _e_3397 = _e_3051[43:33];
    assign _e_3399 = _e_3051[32:0];
    assign x_n44 = _e_3399[31:0];
    assign _e_8790 = _e_3397[10:4] == 7'd45;
    assign _e_8792 = _e_3399[32] == 1'd1;
    localparam[0:0] _e_8793 = 1;
    assign _e_8794 = _e_8792 && _e_8793;
    assign _e_8795 = _e_8790 && _e_8794;
    assign _e_3403 = {3'd4};
    assign _e_3402 = {6'd12, _e_3403, x_n44, 2'bX};
    assign _e_3401 = {1'd1, _e_3402};
    assign _e_3408 = _e_3051;
    assign _e_3405 = _e_3051[43:33];
    assign _e_3407 = _e_3051[32:0];
    assign x_n45 = _e_3407[31:0];
    assign _e_8798 = _e_3405[10:4] == 7'd46;
    assign _e_8800 = _e_3407[32] == 1'd1;
    localparam[0:0] _e_8801 = 1;
    assign _e_8802 = _e_8800 && _e_8801;
    assign _e_8803 = _e_8798 && _e_8802;
    assign _e_3411 = {3'd5};
    assign _e_3410 = {6'd12, _e_3411, x_n45, 2'bX};
    assign _e_3409 = {1'd1, _e_3410};
    assign _e_3416 = _e_3051;
    assign _e_3413 = _e_3051[43:33];
    assign _e_3415 = _e_3051[32:0];
    assign x_n46 = _e_3415[31:0];
    assign _e_8806 = _e_3413[10:4] == 7'd47;
    assign _e_8808 = _e_3415[32] == 1'd1;
    localparam[0:0] _e_8809 = 1;
    assign _e_8810 = _e_8808 && _e_8809;
    assign _e_8811 = _e_8806 && _e_8810;
    assign _e_3419 = {3'd0};
    assign _e_3418 = {6'd13, _e_3419, x_n46, 2'bX};
    assign _e_3417 = {1'd1, _e_3418};
    assign _e_3424 = _e_3051;
    assign _e_3421 = _e_3051[43:33];
    assign _e_3423 = _e_3051[32:0];
    assign x_n47 = _e_3423[31:0];
    assign _e_8814 = _e_3421[10:4] == 7'd48;
    assign _e_8816 = _e_3423[32] == 1'd1;
    localparam[0:0] _e_8817 = 1;
    assign _e_8818 = _e_8816 && _e_8817;
    assign _e_8819 = _e_8814 && _e_8818;
    assign _e_3427 = {3'd1};
    assign _e_3426 = {6'd13, _e_3427, x_n47, 2'bX};
    assign _e_3425 = {1'd1, _e_3426};
    assign _e_3432 = _e_3051;
    assign _e_3429 = _e_3051[43:33];
    assign _e_3431 = _e_3051[32:0];
    assign x_n48 = _e_3431[31:0];
    assign _e_8822 = _e_3429[10:4] == 7'd49;
    assign _e_8824 = _e_3431[32] == 1'd1;
    localparam[0:0] _e_8825 = 1;
    assign _e_8826 = _e_8824 && _e_8825;
    assign _e_8827 = _e_8822 && _e_8826;
    assign _e_3435 = {3'd2};
    assign _e_3434 = {6'd13, _e_3435, x_n48, 2'bX};
    assign _e_3433 = {1'd1, _e_3434};
    assign _e_3440 = _e_3051;
    assign _e_3437 = _e_3051[43:33];
    assign _e_3439 = _e_3051[32:0];
    assign x_n49 = _e_3439[31:0];
    assign _e_8830 = _e_3437[10:4] == 7'd50;
    assign _e_8832 = _e_3439[32] == 1'd1;
    localparam[0:0] _e_8833 = 1;
    assign _e_8834 = _e_8832 && _e_8833;
    assign _e_8835 = _e_8830 && _e_8834;
    assign _e_3443 = {3'd3};
    assign _e_3442 = {6'd13, _e_3443, x_n49, 2'bX};
    assign _e_3441 = {1'd1, _e_3442};
    assign _e_3448 = _e_3051;
    assign _e_3445 = _e_3051[43:33];
    assign _e_3447 = _e_3051[32:0];
    assign x_n50 = _e_3447[31:0];
    assign _e_8838 = _e_3445[10:4] == 7'd51;
    assign _e_8840 = _e_3447[32] == 1'd1;
    localparam[0:0] _e_8841 = 1;
    assign _e_8842 = _e_8840 && _e_8841;
    assign _e_8843 = _e_8838 && _e_8842;
    assign _e_3451 = {3'd4};
    assign _e_3450 = {6'd13, _e_3451, x_n50, 2'bX};
    assign _e_3449 = {1'd1, _e_3450};
    assign _e_3456 = _e_3051;
    assign _e_3453 = _e_3051[43:33];
    assign _e_3455 = _e_3051[32:0];
    assign x_n51 = _e_3455[31:0];
    assign _e_8846 = _e_3453[10:4] == 7'd52;
    assign _e_8848 = _e_3455[32] == 1'd1;
    localparam[0:0] _e_8849 = 1;
    assign _e_8850 = _e_8848 && _e_8849;
    assign _e_8851 = _e_8846 && _e_8850;
    assign _e_3459 = {3'd5};
    assign _e_3458 = {6'd13, _e_3459, x_n51, 2'bX};
    assign _e_3457 = {1'd1, _e_3458};
    assign _e_3464 = _e_3051;
    assign _e_3461 = _e_3051[43:33];
    assign _e_3463 = _e_3051[32:0];
    assign x_n52 = _e_3463[31:0];
    assign _e_8854 = _e_3461[10:4] == 7'd53;
    assign _e_8856 = _e_3463[32] == 1'd1;
    localparam[0:0] _e_8857 = 1;
    assign _e_8858 = _e_8856 && _e_8857;
    assign _e_8859 = _e_8854 && _e_8858;
    assign _e_3466 = {6'd16, x_n52, 5'bX};
    assign _e_3465 = {1'd1, _e_3466};
    assign _e_3471 = _e_3051;
    assign _e_3468 = _e_3051[43:33];
    assign _e_3470 = _e_3051[32:0];
    assign x_n53 = _e_3470[31:0];
    assign _e_8862 = _e_3468[10:4] == 7'd54;
    assign _e_8864 = _e_3470[32] == 1'd1;
    localparam[0:0] _e_8865 = 1;
    assign _e_8866 = _e_8864 && _e_8865;
    assign _e_8867 = _e_8862 && _e_8866;
    assign _e_3473 = {6'd17, x_n53, 5'bX};
    assign _e_3472 = {1'd1, _e_3473};
    assign _e_3478 = _e_3051;
    assign _e_3475 = _e_3051[43:33];
    assign _e_3477 = _e_3051[32:0];
    assign x_n54 = _e_3477[31:0];
    assign _e_8870 = _e_3475[10:4] == 7'd55;
    assign _e_8872 = _e_3477[32] == 1'd1;
    localparam[0:0] _e_8873 = 1;
    assign _e_8874 = _e_8872 && _e_8873;
    assign _e_8875 = _e_8870 && _e_8874;
    assign _e_3480 = {6'd21, x_n54, 5'bX};
    assign _e_3479 = {1'd1, _e_3480};
    assign _e_3485 = _e_3051;
    assign _e_3482 = _e_3051[43:33];
    assign _e_3484 = _e_3051[32:0];
    assign x_n55 = _e_3484[31:0];
    assign _e_8878 = _e_3482[10:4] == 7'd56;
    assign _e_8880 = _e_3484[32] == 1'd1;
    localparam[0:0] _e_8881 = 1;
    assign _e_8882 = _e_8880 && _e_8881;
    assign _e_8883 = _e_8878 && _e_8882;
    assign _e_3487 = {6'd22, x_n55, 5'bX};
    assign _e_3486 = {1'd1, _e_3487};
    assign _e_3492 = _e_3051;
    assign _e_3489 = _e_3051[43:33];
    assign _e_3491 = _e_3051[32:0];
    assign x_n56 = _e_3491[31:0];
    assign _e_8886 = _e_3489[10:4] == 7'd57;
    assign _e_8888 = _e_3491[32] == 1'd1;
    localparam[0:0] _e_8889 = 1;
    assign _e_8890 = _e_8888 && _e_8889;
    assign _e_8891 = _e_8886 && _e_8890;
    assign _e_3494 = {6'd23, x_n56, 5'bX};
    assign _e_3493 = {1'd1, _e_3494};
    assign _e_3499 = _e_3051;
    assign _e_3496 = _e_3051[43:33];
    assign _e_3498 = _e_3051[32:0];
    assign x_n57 = _e_3498[31:0];
    assign _e_8894 = _e_3496[10:4] == 7'd58;
    assign _e_8896 = _e_3498[32] == 1'd1;
    localparam[0:0] _e_8897 = 1;
    assign _e_8898 = _e_8896 && _e_8897;
    assign _e_8899 = _e_8894 && _e_8898;
    assign _e_3501 = {6'd24, x_n57, 5'bX};
    assign _e_3500 = {1'd1, _e_3501};
    assign _e_3506 = _e_3051;
    assign _e_3503 = _e_3051[43:33];
    assign _e_3505 = _e_3051[32:0];
    assign x_n58 = _e_3505[31:0];
    assign _e_8902 = _e_3503[10:4] == 7'd59;
    assign _e_8904 = _e_3505[32] == 1'd1;
    localparam[0:0] _e_8905 = 1;
    assign _e_8906 = _e_8904 && _e_8905;
    assign _e_8907 = _e_8902 && _e_8906;
    assign _e_3508 = {6'd25, x_n58, 5'bX};
    assign _e_3507 = {1'd1, _e_3508};
    assign _e_3513 = _e_3051;
    assign _e_3510 = _e_3051[43:33];
    assign _e_3512 = _e_3051[32:0];
    assign x_n59 = _e_3512[31:0];
    assign _e_8910 = _e_3510[10:4] == 7'd60;
    assign _e_8912 = _e_3512[32] == 1'd1;
    localparam[0:0] _e_8913 = 1;
    assign _e_8914 = _e_8912 && _e_8913;
    assign _e_8915 = _e_8910 && _e_8914;
    localparam[31:0] _e_3518 = 32'd0;
    assign _e_3516 = x_n59 != _e_3518;
    assign _e_3515 = {6'd26, _e_3516, 36'bX};
    assign _e_3514 = {1'd1, _e_3515};
    assign _e_3522 = _e_3051;
    assign _e_3519 = _e_3051[43:33];
    assign _e_3521 = _e_3051[32:0];
    assign x_n60 = _e_3521[31:0];
    assign _e_8918 = _e_3519[10:4] == 7'd61;
    assign _e_8920 = _e_3521[32] == 1'd1;
    localparam[0:0] _e_8921 = 1;
    assign _e_8922 = _e_8920 && _e_8921;
    assign _e_8923 = _e_8918 && _e_8922;
    localparam[31:0] _e_3527 = 32'd0;
    assign _e_3525 = x_n60 != _e_3527;
    assign _e_3524 = {6'd27, _e_3525, 36'bX};
    assign _e_3523 = {1'd1, _e_3524};
    assign _e_3531 = _e_3051;
    assign _e_3528 = _e_3051[43:33];
    assign _e_3530 = _e_3051[32:0];
    assign x_n61 = _e_3530[31:0];
    assign _e_8926 = _e_3528[10:4] == 7'd62;
    assign _e_8928 = _e_3530[32] == 1'd1;
    localparam[0:0] _e_8929 = 1;
    assign _e_8930 = _e_8928 && _e_8929;
    assign _e_8931 = _e_8926 && _e_8930;
    assign _e_3533 = {6'd28, x_n61, 5'bX};
    assign _e_3532 = {1'd1, _e_3533};
    assign _e_3538 = _e_3051;
    assign _e_3535 = _e_3051[43:33];
    assign _e_3537 = _e_3051[32:0];
    assign x_n62 = _e_3537[31:0];
    assign _e_8934 = _e_3535[10:4] == 7'd63;
    assign _e_8936 = _e_3537[32] == 1'd1;
    localparam[0:0] _e_8937 = 1;
    assign _e_8938 = _e_8936 && _e_8937;
    assign _e_8939 = _e_8934 && _e_8938;
    assign _e_3540 = {6'd29, x_n62, 5'bX};
    assign _e_3539 = {1'd1, _e_3540};
    assign _e_3545 = _e_3051;
    assign _e_3542 = _e_3051[43:33];
    assign _e_3544 = _e_3051[32:0];
    assign x_n63 = _e_3544[31:0];
    assign _e_8942 = _e_3542[10:4] == 7'd64;
    assign _e_8944 = _e_3544[32] == 1'd1;
    localparam[0:0] _e_8945 = 1;
    assign _e_8946 = _e_8944 && _e_8945;
    assign _e_8947 = _e_8942 && _e_8946;
    assign _e_3547 = {6'd30, x_n63, 5'bX};
    assign _e_3546 = {1'd1, _e_3547};
    assign _e_3552 = _e_3051;
    assign _e_3549 = _e_3051[43:33];
    assign _e_3551 = _e_3051[32:0];
    assign x_n64 = _e_3551[31:0];
    assign _e_8950 = _e_3549[10:4] == 7'd65;
    assign _e_8952 = _e_3551[32] == 1'd1;
    localparam[0:0] _e_8953 = 1;
    assign _e_8954 = _e_8952 && _e_8953;
    assign _e_8955 = _e_8950 && _e_8954;
    assign _e_3554 = {6'd31, x_n64, 5'bX};
    assign _e_3553 = {1'd1, _e_3554};
    assign _e_3559 = _e_3051;
    assign _e_3556 = _e_3051[43:33];
    assign _e_3558 = _e_3051[32:0];
    assign x_n65 = _e_3558[31:0];
    assign _e_8958 = _e_3556[10:4] == 7'd66;
    assign _e_8960 = _e_3558[32] == 1'd1;
    localparam[0:0] _e_8961 = 1;
    assign _e_8962 = _e_8960 && _e_8961;
    assign _e_8963 = _e_8958 && _e_8962;
    assign _e_3561 = {6'd32, x_n65, 5'bX};
    assign _e_3560 = {1'd1, _e_3561};
    assign _e_3566 = _e_3051;
    assign _e_3563 = _e_3051[43:33];
    assign _e_3565 = _e_3051[32:0];
    assign x_n66 = _e_3565[31:0];
    assign _e_8966 = _e_3563[10:4] == 7'd67;
    assign _e_8968 = _e_3565[32] == 1'd1;
    localparam[0:0] _e_8969 = 1;
    assign _e_8970 = _e_8968 && _e_8969;
    assign _e_8971 = _e_8966 && _e_8970;
    assign _e_3568 = {6'd33, x_n66, 5'bX};
    assign _e_3567 = {1'd1, _e_3568};
    assign _e_3573 = _e_3051;
    assign _e_3570 = _e_3051[43:33];
    assign _e_3572 = _e_3051[32:0];
    assign x_n67 = _e_3572[31:0];
    assign _e_8974 = _e_3570[10:4] == 7'd68;
    assign _e_8976 = _e_3572[32] == 1'd1;
    localparam[0:0] _e_8977 = 1;
    assign _e_8978 = _e_8976 && _e_8977;
    assign _e_8979 = _e_8974 && _e_8978;
    assign _e_3575 = {6'd34, x_n67, 5'bX};
    assign _e_3574 = {1'd1, _e_3575};
    assign _e_3580 = _e_3051;
    assign _e_3577 = _e_3051[43:33];
    assign _e_3579 = _e_3051[32:0];
    assign x_n68 = _e_3579[31:0];
    assign _e_8982 = _e_3577[10:4] == 7'd69;
    assign _e_8984 = _e_3579[32] == 1'd1;
    localparam[0:0] _e_8985 = 1;
    assign _e_8986 = _e_8984 && _e_8985;
    assign _e_8987 = _e_8982 && _e_8986;
    assign _e_3582 = {6'd35, x_n68, 5'bX};
    assign _e_3581 = {1'd1, _e_3582};
    assign _e_3587 = _e_3051;
    assign _e_3584 = _e_3051[43:33];
    assign _e_3586 = _e_3051[32:0];
    assign x_n69 = _e_3586[31:0];
    assign _e_8990 = _e_3584[10:4] == 7'd70;
    assign _e_8992 = _e_3586[32] == 1'd1;
    localparam[0:0] _e_8993 = 1;
    assign _e_8994 = _e_8992 && _e_8993;
    assign _e_8995 = _e_8990 && _e_8994;
    assign _e_3589 = {6'd36, x_n69, 5'bX};
    assign _e_3588 = {1'd1, _e_3589};
    assign _e_3594 = _e_3051;
    assign _e_3591 = _e_3051[43:33];
    assign _e_3593 = _e_3051[32:0];
    assign x_n70 = _e_3593[31:0];
    assign _e_8998 = _e_3591[10:4] == 7'd71;
    assign _e_9000 = _e_3593[32] == 1'd1;
    localparam[0:0] _e_9001 = 1;
    assign _e_9002 = _e_9000 && _e_9001;
    assign _e_9003 = _e_8998 && _e_9002;
    assign _e_3596 = {6'd37, 37'bX};
    assign _e_3595 = {1'd1, _e_3596};
    assign _e_3600 = _e_3051;
    assign _e_3597 = _e_3051[43:33];
    assign _e_3599 = _e_3051[32:0];
    assign x_n71 = _e_3599[31:0];
    assign _e_9006 = _e_3597[10:4] == 7'd72;
    assign _e_9008 = _e_3599[32] == 1'd1;
    localparam[0:0] _e_9009 = 1;
    assign _e_9010 = _e_9008 && _e_9009;
    assign _e_9011 = _e_9006 && _e_9010;
    assign _e_3603 = x_n71[7:0];
    assign _e_3602 = {6'd20, _e_3603, 29'bX};
    assign _e_3601 = {1'd1, _e_3602};
    assign _e_3608 = _e_3051;
    assign _e_3605 = _e_3051[43:33];
    assign _e_3607 = _e_3051[32:0];
    assign x_n72 = _e_3607[31:0];
    assign _e_9014 = _e_3605[10:4] == 7'd75;
    assign _e_9016 = _e_3607[32] == 1'd1;
    localparam[0:0] _e_9017 = 1;
    assign _e_9018 = _e_9016 && _e_9017;
    assign _e_9019 = _e_9014 && _e_9018;
    assign _e_3610 = {6'd42, 37'bX};
    assign _e_3609 = {1'd1, _e_3610};
    assign _e_3614 = _e_3051;
    assign _e_3611 = _e_3051[43:33];
    assign _e_3613 = _e_3051[32:0];
    assign x_n73 = _e_3613[31:0];
    assign _e_9022 = _e_3611[10:4] == 7'd73;
    assign _e_9024 = _e_3613[32] == 1'd1;
    localparam[0:0] _e_9025 = 1;
    assign _e_9026 = _e_9024 && _e_9025;
    assign _e_9027 = _e_9022 && _e_9026;
    assign _e_3617 = x_n73[7:0];
    assign _e_3616 = {6'd38, _e_3617, 29'bX};
    assign _e_3615 = {1'd1, _e_3616};
    assign _e_3622 = _e_3051;
    assign _e_3619 = _e_3051[43:33];
    assign _e_3621 = _e_3051[32:0];
    assign x_n74 = _e_3621[31:0];
    assign _e_9030 = _e_3619[10:4] == 7'd74;
    assign _e_9032 = _e_3621[32] == 1'd1;
    localparam[0:0] _e_9033 = 1;
    assign _e_9034 = _e_9032 && _e_9033;
    assign _e_9035 = _e_9030 && _e_9034;
    assign _e_3624 = {6'd41, 37'bX};
    assign _e_3623 = {1'd1, _e_3624};
    assign \_  = _e_3051;
    localparam[0:0] _e_9036 = 1;
    assign _e_3626 = {1'd0, 43'bX};
    always_comb begin
        priority casez ({_e_8443, _e_8451, _e_8459, _e_8467, _e_8475, _e_8483, _e_8491, _e_8499, _e_8507, _e_8515, _e_8523, _e_8531, _e_8539, _e_8547, _e_8555, _e_8563, _e_8571, _e_8579, _e_8587, _e_8595, _e_8603, _e_8611, _e_8619, _e_8627, _e_8635, _e_8643, _e_8651, _e_8659, _e_8667, _e_8675, _e_8683, _e_8691, _e_8699, _e_8707, _e_8715, _e_8723, _e_8731, _e_8739, _e_8747, _e_8755, _e_8763, _e_8771, _e_8779, _e_8787, _e_8795, _e_8803, _e_8811, _e_8819, _e_8827, _e_8835, _e_8843, _e_8851, _e_8859, _e_8867, _e_8875, _e_8883, _e_8891, _e_8899, _e_8907, _e_8915, _e_8923, _e_8931, _e_8939, _e_8947, _e_8955, _e_8963, _e_8971, _e_8979, _e_8987, _e_8995, _e_9003, _e_9011, _e_9019, _e_9027, _e_9035, _e_9036})
            76'b1???????????????????????????????????????????????????????????????????????????: _e_3050 = _e_3059;
            76'b01??????????????????????????????????????????????????????????????????????????: _e_3050 = _e_3067;
            76'b001?????????????????????????????????????????????????????????????????????????: _e_3050 = _e_3074;
            76'b0001????????????????????????????????????????????????????????????????????????: _e_3050 = _e_3082;
            76'b00001???????????????????????????????????????????????????????????????????????: _e_3050 = _e_3090;
            76'b000001??????????????????????????????????????????????????????????????????????: _e_3050 = _e_3098;
            76'b0000001?????????????????????????????????????????????????????????????????????: _e_3050 = _e_3106;
            76'b00000001????????????????????????????????????????????????????????????????????: _e_3050 = _e_3114;
            76'b000000001???????????????????????????????????????????????????????????????????: _e_3050 = _e_3122;
            76'b0000000001??????????????????????????????????????????????????????????????????: _e_3050 = _e_3130;
            76'b00000000001?????????????????????????????????????????????????????????????????: _e_3050 = _e_3138;
            76'b000000000001????????????????????????????????????????????????????????????????: _e_3050 = _e_3146;
            76'b0000000000001???????????????????????????????????????????????????????????????: _e_3050 = _e_3154;
            76'b00000000000001??????????????????????????????????????????????????????????????: _e_3050 = _e_3162;
            76'b000000000000001?????????????????????????????????????????????????????????????: _e_3050 = _e_3170;
            76'b0000000000000001????????????????????????????????????????????????????????????: _e_3050 = _e_3178;
            76'b00000000000000001???????????????????????????????????????????????????????????: _e_3050 = _e_3186;
            76'b000000000000000001??????????????????????????????????????????????????????????: _e_3050 = _e_3194;
            76'b0000000000000000001?????????????????????????????????????????????????????????: _e_3050 = _e_3202;
            76'b00000000000000000001????????????????????????????????????????????????????????: _e_3050 = _e_3210;
            76'b000000000000000000001???????????????????????????????????????????????????????: _e_3050 = _e_3218;
            76'b0000000000000000000001??????????????????????????????????????????????????????: _e_3050 = _e_3226;
            76'b00000000000000000000001?????????????????????????????????????????????????????: _e_3050 = _e_3234;
            76'b000000000000000000000001????????????????????????????????????????????????????: _e_3050 = _e_3242;
            76'b0000000000000000000000001???????????????????????????????????????????????????: _e_3050 = _e_3250;
            76'b00000000000000000000000001??????????????????????????????????????????????????: _e_3050 = _e_3258;
            76'b000000000000000000000000001?????????????????????????????????????????????????: _e_3050 = _e_3266;
            76'b0000000000000000000000000001????????????????????????????????????????????????: _e_3050 = _e_3273;
            76'b00000000000000000000000000001???????????????????????????????????????????????: _e_3050 = _e_3281;
            76'b000000000000000000000000000001??????????????????????????????????????????????: _e_3050 = _e_3289;
            76'b0000000000000000000000000000001?????????????????????????????????????????????: _e_3050 = _e_3297;
            76'b00000000000000000000000000000001????????????????????????????????????????????: _e_3050 = _e_3305;
            76'b000000000000000000000000000000001???????????????????????????????????????????: _e_3050 = _e_3312;
            76'b0000000000000000000000000000000001??????????????????????????????????????????: _e_3050 = _e_3319;
            76'b00000000000000000000000000000000001?????????????????????????????????????????: _e_3050 = _e_3326;
            76'b000000000000000000000000000000000001????????????????????????????????????????: _e_3050 = _e_3333;
            76'b0000000000000000000000000000000000001???????????????????????????????????????: _e_3050 = _e_3340;
            76'b00000000000000000000000000000000000001??????????????????????????????????????: _e_3050 = _e_3347;
            76'b000000000000000000000000000000000000001?????????????????????????????????????: _e_3050 = _e_3354;
            76'b0000000000000000000000000000000000000001????????????????????????????????????: _e_3050 = _e_3362;
            76'b00000000000000000000000000000000000000001???????????????????????????????????: _e_3050 = _e_3369;
            76'b000000000000000000000000000000000000000001??????????????????????????????????: _e_3050 = _e_3377;
            76'b0000000000000000000000000000000000000000001?????????????????????????????????: _e_3050 = _e_3385;
            76'b00000000000000000000000000000000000000000001????????????????????????????????: _e_3050 = _e_3393;
            76'b000000000000000000000000000000000000000000001???????????????????????????????: _e_3050 = _e_3401;
            76'b0000000000000000000000000000000000000000000001??????????????????????????????: _e_3050 = _e_3409;
            76'b00000000000000000000000000000000000000000000001?????????????????????????????: _e_3050 = _e_3417;
            76'b000000000000000000000000000000000000000000000001????????????????????????????: _e_3050 = _e_3425;
            76'b0000000000000000000000000000000000000000000000001???????????????????????????: _e_3050 = _e_3433;
            76'b00000000000000000000000000000000000000000000000001??????????????????????????: _e_3050 = _e_3441;
            76'b000000000000000000000000000000000000000000000000001?????????????????????????: _e_3050 = _e_3449;
            76'b0000000000000000000000000000000000000000000000000001????????????????????????: _e_3050 = _e_3457;
            76'b00000000000000000000000000000000000000000000000000001???????????????????????: _e_3050 = _e_3465;
            76'b000000000000000000000000000000000000000000000000000001??????????????????????: _e_3050 = _e_3472;
            76'b0000000000000000000000000000000000000000000000000000001?????????????????????: _e_3050 = _e_3479;
            76'b00000000000000000000000000000000000000000000000000000001????????????????????: _e_3050 = _e_3486;
            76'b000000000000000000000000000000000000000000000000000000001???????????????????: _e_3050 = _e_3493;
            76'b0000000000000000000000000000000000000000000000000000000001??????????????????: _e_3050 = _e_3500;
            76'b00000000000000000000000000000000000000000000000000000000001?????????????????: _e_3050 = _e_3507;
            76'b000000000000000000000000000000000000000000000000000000000001????????????????: _e_3050 = _e_3514;
            76'b0000000000000000000000000000000000000000000000000000000000001???????????????: _e_3050 = _e_3523;
            76'b00000000000000000000000000000000000000000000000000000000000001??????????????: _e_3050 = _e_3532;
            76'b000000000000000000000000000000000000000000000000000000000000001?????????????: _e_3050 = _e_3539;
            76'b0000000000000000000000000000000000000000000000000000000000000001????????????: _e_3050 = _e_3546;
            76'b00000000000000000000000000000000000000000000000000000000000000001???????????: _e_3050 = _e_3553;
            76'b000000000000000000000000000000000000000000000000000000000000000001??????????: _e_3050 = _e_3560;
            76'b0000000000000000000000000000000000000000000000000000000000000000001?????????: _e_3050 = _e_3567;
            76'b00000000000000000000000000000000000000000000000000000000000000000001????????: _e_3050 = _e_3574;
            76'b000000000000000000000000000000000000000000000000000000000000000000001???????: _e_3050 = _e_3581;
            76'b0000000000000000000000000000000000000000000000000000000000000000000001??????: _e_3050 = _e_3588;
            76'b00000000000000000000000000000000000000000000000000000000000000000000001?????: _e_3050 = _e_3595;
            76'b000000000000000000000000000000000000000000000000000000000000000000000001????: _e_3050 = _e_3601;
            76'b0000000000000000000000000000000000000000000000000000000000000000000000001???: _e_3050 = _e_3609;
            76'b00000000000000000000000000000000000000000000000000000000000000000000000001??: _e_3050 = _e_3615;
            76'b000000000000000000000000000000000000000000000000000000000000000000000000001?: _e_3050 = _e_3623;
            76'b0000000000000000000000000000000000000000000000000000000000000000000000000001: _e_3050 = _e_3626;
            76'b?: _e_3050 = 44'dx;
        endcase
    end
    assign output__ = _e_3050;
endmodule

module \tta::tta::empty_tick  (
        output[410:0] output__
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
    logic[32:0] _e_3630;
    (* src = "src/tta.spade:321,9" *)
    logic[37:0] _e_3631;
    (* src = "src/tta.spade:322,9" *)
    logic[32:0] _e_3632;
    (* src = "src/tta.spade:323,9" *)
    logic[10:0] _e_3633;
    (* src = "src/tta.spade:324,9" *)
    logic[36:0] _e_3634;
    (* src = "src/tta.spade:325,9" *)
    logic[36:0] _e_3635;
    (* src = "src/tta.spade:328,9" *)
    logic[32:0] _e_3638;
    (* src = "src/tta.spade:329,9" *)
    logic[32:0] _e_3639;
    (* src = "src/tta.spade:330,9" *)
    logic[32:0] _e_3640;
    (* src = "src/tta.spade:331,9" *)
    logic[32:0] _e_3641;
    (* src = "src/tta.spade:318,5" *)
    logic[410:0] _e_3628;
    localparam[9:0] _e_3629 = 0;
    assign _e_3630 = {1'd0, 32'bX};
    assign _e_3631 = {1'd0, 37'bX};
    assign _e_3632 = {1'd0, 32'bX};
    assign _e_3633 = {1'd0, 10'bX};
    assign _e_3634 = {1'd0, 36'bX};
    assign _e_3635 = {1'd0, 36'bX};
    localparam[31:0] _e_3636 = 32'd0;
    localparam[31:0] _e_3637 = 32'd0;
    assign _e_3638 = {1'd0, 32'bX};
    assign _e_3639 = {1'd0, 32'bX};
    assign _e_3640 = {1'd0, 32'bX};
    assign _e_3641 = {1'd0, 32'bX};
    localparam[15:0] _e_3642 = 0;
    assign _e_3628 = {_e_3629, _e_3630, _e_3631, _e_3632, _e_3633, _e_3634, _e_3635, _e_3636, _e_3637, _e_3638, _e_3639, _e_3640, _e_3641, _e_3642};
    assign output__ = _e_3628;
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
        output[410:0] output__
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
    logic[10:0] _e_9037;
    (* src = "src/tta.spade:361,38" *)
    logic[10:0] _e_9038_mut;
    (* src = "src/tta.spade:361,38" *)
    logic[10:0] _e_3647;
    (* src = "src/tta.spade:361,38" *)
    logic[10:0] _e_3647_mut;
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
    logic[63:0] _e_3731;
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
    logic[48:0] _e_3804;
    (* src = "src/tta.spade:475,30" *)
    logic[36:0] _e_3803;
    (* src = "src/tta.spade:475,47" *)
    logic[36:0] _e_3807;
    (* src = "src/tta.spade:475,47" *)
    logic[3:0] \i ;
    logic _e_9040;
    logic _e_9042;
    (* src = "src/tta.spade:475,74" *)
    logic[36:0] __n2;
    (* src = "src/tta.spade:475,24" *)
    logic[3:0] \ra0 ;
    (* src = "src/tta.spade:476,30" *)
    logic[48:0] _e_3814;
    (* src = "src/tta.spade:476,30" *)
    logic[36:0] _e_3813;
    (* src = "src/tta.spade:476,47" *)
    logic[36:0] _e_3817;
    (* src = "src/tta.spade:476,47" *)
    logic[3:0] i_n1;
    logic _e_9045;
    logic _e_9047;
    (* src = "src/tta.spade:476,74" *)
    logic[36:0] __n3;
    (* src = "src/tta.spade:476,24" *)
    logic[3:0] \ra1 ;
    (* src = "src/tta.spade:480,20" *)
    logic[63:0] \registry ;
    (* src = "src/tta.spade:485,12" *)
    logic[48:0] _e_3832;
    (* src = "src/tta.spade:485,12" *)
    logic _e_3831;
    (* src = "src/tta.spade:486,19" *)
    logic[48:0] _e_3837;
    (* src = "src/tta.spade:486,19" *)
    logic[36:0] _e_3836;
    (* src = "src/tta.spade:487,17" *)
    logic[36:0] _e_3840;
    (* src = "src/tta.spade:487,17" *)
    logic[3:0] __n4;
    logic _e_9050;
    logic _e_9052;
    (* src = "src/tta.spade:487,48" *)
    logic[31:0] _e_3842;
    (* src = "src/tta.spade:487,43" *)
    logic[32:0] _e_3841;
    (* src = "src/tta.spade:488,17" *)
    logic[36:0] _e_3844;
    logic _e_9054;
    logic[31:0] _e_3846;
    (* src = "src/tta.spade:488,33" *)
    logic[32:0] _e_3845;
    (* src = "src/tta.spade:489,17" *)
    logic[36:0] _e_3848;
    logic _e_9056;
    (* src = "src/tta.spade:489,44" *)
    logic[10:0] _e_3851;
    logic[31:0] _e_3850;
    (* src = "src/tta.spade:489,34" *)
    logic[32:0] _e_3849;
    (* src = "src/tta.spade:490,17" *)
    logic[36:0] _e_3855;
    (* src = "src/tta.spade:490,17" *)
    logic[31:0] \v ;
    logic _e_9058;
    logic _e_9060;
    (* src = "src/tta.spade:490,39" *)
    logic[32:0] _e_3856;
    (* src = "src/tta.spade:491,17" *)
    logic[36:0] _e_3858;
    logic _e_9062;
    (* src = "src/tta.spade:491,33" *)
    logic[32:0] _e_3859;
    (* src = "src/tta.spade:492,17" *)
    logic[36:0] _e_3861;
    logic _e_9064;
    (* src = "src/tta.spade:493,17" *)
    logic[36:0] _e_3863;
    logic _e_9066;
    (* src = "src/tta.spade:494,17" *)
    logic[36:0] _e_3865;
    logic _e_9068;
    (* src = "src/tta.spade:495,17" *)
    logic[36:0] _e_3867;
    logic _e_9070;
    (* src = "src/tta.spade:496,17" *)
    logic[36:0] _e_3869;
    logic _e_9072;
    (* src = "src/tta.spade:497,17" *)
    logic[36:0] _e_3871;
    logic _e_9074;
    (* src = "src/tta.spade:498,17" *)
    logic[36:0] _e_3873;
    logic _e_9076;
    (* src = "src/tta.spade:499,17" *)
    logic[36:0] _e_3875;
    logic _e_9078;
    (* src = "src/tta.spade:500,17" *)
    logic[36:0] _e_3877;
    logic _e_9080;
    (* src = "src/tta.spade:501,17" *)
    logic[36:0] _e_3879;
    logic _e_9082;
    (* src = "src/tta.spade:501,35" *)
    logic[32:0] _e_3880;
    (* src = "src/tta.spade:502,17" *)
    logic[36:0] _e_3882;
    logic _e_9084;
    (* src = "src/tta.spade:502,37" *)
    logic[32:0] _e_3883;
    (* src = "src/tta.spade:503,17" *)
    logic[36:0] _e_3885;
    logic _e_9086;
    (* src = "src/tta.spade:504,17" *)
    logic[36:0] _e_3887;
    logic _e_9088;
    (* src = "src/tta.spade:505,17" *)
    logic[36:0] _e_3889;
    logic _e_9090;
    (* src = "src/tta.spade:506,17" *)
    logic[36:0] _e_3891;
    logic _e_9092;
    (* src = "src/tta.spade:507,17" *)
    logic[36:0] _e_3893;
    logic _e_9094;
    (* src = "src/tta.spade:508,17" *)
    logic[36:0] _e_3895;
    logic _e_9096;
    (* src = "src/tta.spade:509,17" *)
    logic[36:0] _e_3897;
    logic _e_9098;
    (* src = "src/tta.spade:510,17" *)
    logic[36:0] _e_3899;
    logic _e_9100;
    (* src = "src/tta.spade:511,17" *)
    logic[36:0] _e_3901;
    logic _e_9102;
    (* src = "src/tta.spade:486,13" *)
    logic[32:0] _e_3835;
    (* src = "src/tta.spade:513,18" *)
    logic[32:0] _e_3904;
    (* src = "src/tta.spade:485,9" *)
    logic[32:0] \bus0_val_opt ;
    (* src = "src/tta.spade:516,12" *)
    logic[48:0] _e_3908;
    (* src = "src/tta.spade:516,12" *)
    logic _e_3907;
    (* src = "src/tta.spade:517,19" *)
    logic[48:0] _e_3913;
    (* src = "src/tta.spade:517,19" *)
    logic[36:0] _e_3912;
    (* src = "src/tta.spade:518,17" *)
    logic[36:0] _e_3916;
    (* src = "src/tta.spade:518,17" *)
    logic[3:0] __n5;
    logic _e_9104;
    logic _e_9106;
    (* src = "src/tta.spade:518,48" *)
    logic[31:0] _e_3918;
    (* src = "src/tta.spade:518,43" *)
    logic[32:0] _e_3917;
    (* src = "src/tta.spade:519,17" *)
    logic[36:0] _e_3920;
    logic _e_9108;
    logic[31:0] _e_3922;
    (* src = "src/tta.spade:519,33" *)
    logic[32:0] _e_3921;
    (* src = "src/tta.spade:520,17" *)
    logic[36:0] _e_3924;
    logic _e_9110;
    (* src = "src/tta.spade:520,44" *)
    logic[10:0] _e_3927;
    logic[31:0] _e_3926;
    (* src = "src/tta.spade:520,34" *)
    logic[32:0] _e_3925;
    (* src = "src/tta.spade:521,17" *)
    logic[36:0] _e_3931;
    (* src = "src/tta.spade:521,17" *)
    logic[31:0] v_n1;
    logic _e_9112;
    logic _e_9114;
    (* src = "src/tta.spade:521,39" *)
    logic[32:0] _e_3932;
    (* src = "src/tta.spade:522,17" *)
    logic[36:0] _e_3934;
    logic _e_9116;
    (* src = "src/tta.spade:522,33" *)
    logic[32:0] _e_3935;
    (* src = "src/tta.spade:523,17" *)
    logic[36:0] _e_3937;
    logic _e_9118;
    (* src = "src/tta.spade:524,17" *)
    logic[36:0] _e_3939;
    logic _e_9120;
    (* src = "src/tta.spade:525,17" *)
    logic[36:0] _e_3941;
    logic _e_9122;
    (* src = "src/tta.spade:526,17" *)
    logic[36:0] _e_3943;
    logic _e_9124;
    (* src = "src/tta.spade:527,17" *)
    logic[36:0] _e_3945;
    logic _e_9126;
    (* src = "src/tta.spade:528,17" *)
    logic[36:0] _e_3947;
    logic _e_9128;
    (* src = "src/tta.spade:529,17" *)
    logic[36:0] _e_3949;
    logic _e_9130;
    (* src = "src/tta.spade:530,17" *)
    logic[36:0] _e_3951;
    logic _e_9132;
    (* src = "src/tta.spade:531,17" *)
    logic[36:0] _e_3953;
    logic _e_9134;
    (* src = "src/tta.spade:532,17" *)
    logic[36:0] _e_3955;
    logic _e_9136;
    (* src = "src/tta.spade:532,35" *)
    logic[32:0] _e_3956;
    (* src = "src/tta.spade:533,17" *)
    logic[36:0] _e_3958;
    logic _e_9138;
    (* src = "src/tta.spade:533,37" *)
    logic[32:0] _e_3959;
    (* src = "src/tta.spade:534,17" *)
    logic[36:0] _e_3961;
    logic _e_9140;
    (* src = "src/tta.spade:535,17" *)
    logic[36:0] _e_3963;
    logic _e_9142;
    (* src = "src/tta.spade:536,17" *)
    logic[36:0] _e_3965;
    logic _e_9144;
    (* src = "src/tta.spade:537,17" *)
    logic[36:0] _e_3967;
    logic _e_9146;
    (* src = "src/tta.spade:538,17" *)
    logic[36:0] _e_3969;
    logic _e_9148;
    (* src = "src/tta.spade:539,17" *)
    logic[36:0] _e_3971;
    logic _e_9150;
    (* src = "src/tta.spade:540,17" *)
    logic[36:0] _e_3973;
    logic _e_9152;
    (* src = "src/tta.spade:541,17" *)
    logic[36:0] _e_3975;
    logic _e_9154;
    (* src = "src/tta.spade:542,17" *)
    logic[36:0] _e_3977;
    logic _e_9156;
    (* src = "src/tta.spade:517,13" *)
    logic[32:0] _e_3911;
    (* src = "src/tta.spade:544,18" *)
    logic[32:0] _e_3980;
    (* src = "src/tta.spade:516,9" *)
    logic[32:0] \bus1_val_opt ;
    (* src = "src/tta.spade:547,26" *)
    logic[48:0] _e_3984;
    (* src = "src/tta.spade:547,26" *)
    logic[10:0] _e_3983;
    (* src = "src/tta.spade:547,14" *)
    logic[43:0] \m0 ;
    (* src = "src/tta.spade:548,26" *)
    logic[48:0] _e_3990;
    (* src = "src/tta.spade:548,26" *)
    logic[10:0] _e_3989;
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
    (* src = "src/tta.spade:621,5" *)
    logic[410:0] _e_4176;
    
    assign _e_9037 = _e_9038_mut;
    assign _e_3647 = {_e_9037};
    assign {_e_9038_mut} = _e_3647_mut;
    assign \bt_target_r  = _e_3647[10:0];
    assign _e_3647_mut[10:0] = \bt_target_w_mut ;
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
    \tta::cc::cc_fu  cc_fu_0(.clk_i(\clk ), .rst_i(\rst ), .output__(_e_3731));
    assign \cc_res_lo  = _e_3731[63:32];
    assign \cc_res_high  = _e_3731[31:0];
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
    assign _e_3804 = \insn [97:49];
    assign _e_3803 = _e_3804[48:12];
    assign _e_3807 = _e_3803;
    assign \i  = _e_3803[31:28];
    assign _e_9040 = _e_3803[36:32] == 5'd0;
    localparam[0:0] _e_9041 = 1;
    assign _e_9042 = _e_9040 && _e_9041;
    assign __n2 = _e_3803;
    localparam[0:0] _e_9043 = 1;
    localparam[3:0] _e_3810 = 0;
    always_comb begin
        priority casez ({_e_9042, _e_9043})
            2'b1?: \ra0  = \i ;
            2'b01: \ra0  = _e_3810;
            2'b?: \ra0  = 4'dx;
        endcase
    end
    assign _e_3814 = \insn [48:0];
    assign _e_3813 = _e_3814[48:12];
    assign _e_3817 = _e_3813;
    assign i_n1 = _e_3813[31:28];
    assign _e_9045 = _e_3813[36:32] == 5'd0;
    localparam[0:0] _e_9046 = 1;
    assign _e_9047 = _e_9045 && _e_9046;
    assign __n3 = _e_3813;
    localparam[0:0] _e_9048 = 1;
    localparam[3:0] _e_3820 = 0;
    always_comb begin
        priority casez ({_e_9047, _e_9048})
            2'b1?: \ra1  = i_n1;
            2'b01: \ra1  = _e_3820;
            2'b?: \ra1  = 4'dx;
        endcase
    end
    (* src = "src/tta.spade:480,20" *)
    \tta::regfile::regfile8_fu  regfile8_fu_0(.clk_i(\clk ), .rst_i(\rst ), .wr0_i(\rf_w0 ), .wr1_i(\rf_w1 ), .ra0_i(\ra0 ), .ra1_i(\ra1 ), .output__(\registry ));
    assign _e_3832 = \insn [97:49];
    assign _e_3831 = _e_3832[0];
    assign _e_3837 = \insn [97:49];
    assign _e_3836 = _e_3837[48:12];
    assign _e_3840 = _e_3836;
    assign __n4 = _e_3836[31:28];
    assign _e_9050 = _e_3836[36:32] == 5'd0;
    localparam[0:0] _e_9051 = 1;
    assign _e_9052 = _e_9050 && _e_9051;
    assign _e_3842 = \registry [63:32];
    assign _e_3841 = {1'd1, _e_3842};
    assign _e_3844 = _e_3836;
    assign _e_9054 = _e_3836[36:32] == 5'd3;
    assign _e_3846 = {22'b0, \pc_val };
    assign _e_3845 = {1'd1, _e_3846};
    assign _e_3848 = _e_3836;
    assign _e_9056 = _e_3836[36:32] == 5'd4;
    localparam[9:0] _e_3853 = 1;
    assign _e_3851 = \pc_val  + _e_3853;
    assign _e_3850 = {21'b0, _e_3851};
    assign _e_3849 = {1'd1, _e_3850};
    assign _e_3855 = _e_3836;
    assign \v  = _e_3836[31:0];
    assign _e_9058 = _e_3836[36:32] == 5'd5;
    localparam[0:0] _e_9059 = 1;
    assign _e_9060 = _e_9058 && _e_9059;
    assign _e_3856 = {1'd1, \v };
    assign _e_3858 = _e_3836;
    assign _e_9062 = _e_3836[36:32] == 5'd6;
    localparam[31:0] _e_3860 = 32'd0;
    assign _e_3859 = {1'd1, _e_3860};
    assign _e_3861 = _e_3836;
    assign _e_9064 = _e_3836[36:32] == 5'd1;
    assign _e_3863 = _e_3836;
    assign _e_9066 = _e_3836[36:32] == 5'd7;
    assign _e_3865 = _e_3836;
    assign _e_9068 = _e_3836[36:32] == 5'd8;
    assign _e_3867 = _e_3836;
    assign _e_9070 = _e_3836[36:32] == 5'd9;
    assign _e_3869 = _e_3836;
    assign _e_9072 = _e_3836[36:32] == 5'd10;
    assign _e_3871 = _e_3836;
    assign _e_9074 = _e_3836[36:32] == 5'd11;
    assign _e_3873 = _e_3836;
    assign _e_9076 = _e_3836[36:32] == 5'd12;
    assign _e_3875 = _e_3836;
    assign _e_9078 = _e_3836[36:32] == 5'd2;
    assign _e_3877 = _e_3836;
    assign _e_9080 = _e_3836[36:32] == 5'd13;
    assign _e_3879 = _e_3836;
    assign _e_9082 = _e_3836[36:32] == 5'd14;
    assign _e_3880 = {1'd1, \cc_res_lo };
    assign _e_3882 = _e_3836;
    assign _e_9084 = _e_3836[36:32] == 5'd15;
    assign _e_3883 = {1'd1, \cc_res_high };
    assign _e_3885 = _e_3836;
    assign _e_9086 = _e_3836[36:32] == 5'd16;
    assign _e_3887 = _e_3836;
    assign _e_9088 = _e_3836[36:32] == 5'd17;
    assign _e_3889 = _e_3836;
    assign _e_9090 = _e_3836[36:32] == 5'd18;
    assign _e_3891 = _e_3836;
    assign _e_9092 = _e_3836[36:32] == 5'd19;
    assign _e_3893 = _e_3836;
    assign _e_9094 = _e_3836[36:32] == 5'd20;
    assign _e_3895 = _e_3836;
    assign _e_9096 = _e_3836[36:32] == 5'd21;
    assign _e_3897 = _e_3836;
    assign _e_9098 = _e_3836[36:32] == 5'd22;
    assign _e_3899 = _e_3836;
    assign _e_9100 = _e_3836[36:32] == 5'd23;
    assign _e_3901 = _e_3836;
    assign _e_9102 = _e_3836[36:32] == 5'd24;
    always_comb begin
        priority casez ({_e_9052, _e_9054, _e_9056, _e_9060, _e_9062, _e_9064, _e_9066, _e_9068, _e_9070, _e_9072, _e_9074, _e_9076, _e_9078, _e_9080, _e_9082, _e_9084, _e_9086, _e_9088, _e_9090, _e_9092, _e_9094, _e_9096, _e_9098, _e_9100, _e_9102})
            25'b1????????????????????????: _e_3835 = _e_3841;
            25'b01???????????????????????: _e_3835 = _e_3845;
            25'b001??????????????????????: _e_3835 = _e_3849;
            25'b0001?????????????????????: _e_3835 = _e_3856;
            25'b00001????????????????????: _e_3835 = _e_3859;
            25'b000001???????????????????: _e_3835 = \alu_res ;
            25'b0000001??????????????????: _e_3835 = \lsu_res ;
            25'b00000001?????????????????: _e_3835 = \lsu2_res ;
            25'b000000001????????????????: _e_3835 = \gpi_res ;
            25'b0000000001???????????????: _e_3835 = \uart_in_res ;
            25'b00000000001??????????????: _e_3835 = \cmp_res ;
            25'b000000000001?????????????: _e_3835 = \cmpz_res ;
            25'b0000000000001????????????: _e_3835 = \lalu_res ;
            25'b00000000000001???????????: _e_3835 = \mul_res ;
            25'b000000000000001??????????: _e_3835 = _e_3880;
            25'b0000000000000001?????????: _e_3835 = _e_3883;
            25'b00000000000000001????????: _e_3835 = \spi_in_res ;
            25'b000000000000000001???????: _e_3835 = \div_res ;
            25'b0000000000000000001??????: _e_3835 = \xorshift_res ;
            25'b00000000000000000001?????: _e_3835 = \mac_res ;
            25'b000000000000000000001????: _e_3835 = \sel_res ;
            25'b0000000000000000000001???: _e_3835 = \mda_res ;
            25'b00000000000000000000001??: _e_3835 = \tanh_res ;
            25'b000000000000000000000001?: _e_3835 = \stack_res ;
            25'b0000000000000000000000001: _e_3835 = \bit_res ;
            25'b?: _e_3835 = 33'dx;
        endcase
    end
    assign _e_3904 = {1'd0, 32'bX};
    assign \bus0_val_opt  = _e_3831 ? _e_3835 : _e_3904;
    assign _e_3908 = \insn [48:0];
    assign _e_3907 = _e_3908[0];
    assign _e_3913 = \insn [48:0];
    assign _e_3912 = _e_3913[48:12];
    assign _e_3916 = _e_3912;
    assign __n5 = _e_3912[31:28];
    assign _e_9104 = _e_3912[36:32] == 5'd0;
    localparam[0:0] _e_9105 = 1;
    assign _e_9106 = _e_9104 && _e_9105;
    assign _e_3918 = \registry [31:0];
    assign _e_3917 = {1'd1, _e_3918};
    assign _e_3920 = _e_3912;
    assign _e_9108 = _e_3912[36:32] == 5'd3;
    assign _e_3922 = {22'b0, \pc_val };
    assign _e_3921 = {1'd1, _e_3922};
    assign _e_3924 = _e_3912;
    assign _e_9110 = _e_3912[36:32] == 5'd4;
    localparam[9:0] _e_3929 = 1;
    assign _e_3927 = \pc_val  + _e_3929;
    assign _e_3926 = {21'b0, _e_3927};
    assign _e_3925 = {1'd1, _e_3926};
    assign _e_3931 = _e_3912;
    assign v_n1 = _e_3912[31:0];
    assign _e_9112 = _e_3912[36:32] == 5'd5;
    localparam[0:0] _e_9113 = 1;
    assign _e_9114 = _e_9112 && _e_9113;
    assign _e_3932 = {1'd1, v_n1};
    assign _e_3934 = _e_3912;
    assign _e_9116 = _e_3912[36:32] == 5'd6;
    localparam[31:0] _e_3936 = 32'd0;
    assign _e_3935 = {1'd1, _e_3936};
    assign _e_3937 = _e_3912;
    assign _e_9118 = _e_3912[36:32] == 5'd1;
    assign _e_3939 = _e_3912;
    assign _e_9120 = _e_3912[36:32] == 5'd7;
    assign _e_3941 = _e_3912;
    assign _e_9122 = _e_3912[36:32] == 5'd8;
    assign _e_3943 = _e_3912;
    assign _e_9124 = _e_3912[36:32] == 5'd9;
    assign _e_3945 = _e_3912;
    assign _e_9126 = _e_3912[36:32] == 5'd10;
    assign _e_3947 = _e_3912;
    assign _e_9128 = _e_3912[36:32] == 5'd11;
    assign _e_3949 = _e_3912;
    assign _e_9130 = _e_3912[36:32] == 5'd12;
    assign _e_3951 = _e_3912;
    assign _e_9132 = _e_3912[36:32] == 5'd2;
    assign _e_3953 = _e_3912;
    assign _e_9134 = _e_3912[36:32] == 5'd13;
    assign _e_3955 = _e_3912;
    assign _e_9136 = _e_3912[36:32] == 5'd14;
    assign _e_3956 = {1'd1, \cc_res_lo };
    assign _e_3958 = _e_3912;
    assign _e_9138 = _e_3912[36:32] == 5'd15;
    assign _e_3959 = {1'd1, \cc_res_high };
    assign _e_3961 = _e_3912;
    assign _e_9140 = _e_3912[36:32] == 5'd16;
    assign _e_3963 = _e_3912;
    assign _e_9142 = _e_3912[36:32] == 5'd17;
    assign _e_3965 = _e_3912;
    assign _e_9144 = _e_3912[36:32] == 5'd18;
    assign _e_3967 = _e_3912;
    assign _e_9146 = _e_3912[36:32] == 5'd19;
    assign _e_3969 = _e_3912;
    assign _e_9148 = _e_3912[36:32] == 5'd20;
    assign _e_3971 = _e_3912;
    assign _e_9150 = _e_3912[36:32] == 5'd21;
    assign _e_3973 = _e_3912;
    assign _e_9152 = _e_3912[36:32] == 5'd22;
    assign _e_3975 = _e_3912;
    assign _e_9154 = _e_3912[36:32] == 5'd23;
    assign _e_3977 = _e_3912;
    assign _e_9156 = _e_3912[36:32] == 5'd24;
    always_comb begin
        priority casez ({_e_9106, _e_9108, _e_9110, _e_9114, _e_9116, _e_9118, _e_9120, _e_9122, _e_9124, _e_9126, _e_9128, _e_9130, _e_9132, _e_9134, _e_9136, _e_9138, _e_9140, _e_9142, _e_9144, _e_9146, _e_9148, _e_9150, _e_9152, _e_9154, _e_9156})
            25'b1????????????????????????: _e_3911 = _e_3917;
            25'b01???????????????????????: _e_3911 = _e_3921;
            25'b001??????????????????????: _e_3911 = _e_3925;
            25'b0001?????????????????????: _e_3911 = _e_3932;
            25'b00001????????????????????: _e_3911 = _e_3935;
            25'b000001???????????????????: _e_3911 = \alu_res ;
            25'b0000001??????????????????: _e_3911 = \lsu_res ;
            25'b00000001?????????????????: _e_3911 = \lsu2_res ;
            25'b000000001????????????????: _e_3911 = \gpi_res ;
            25'b0000000001???????????????: _e_3911 = \uart_in_res ;
            25'b00000000001??????????????: _e_3911 = \cmp_res ;
            25'b000000000001?????????????: _e_3911 = \cmpz_res ;
            25'b0000000000001????????????: _e_3911 = \lalu_res ;
            25'b00000000000001???????????: _e_3911 = \mul_res ;
            25'b000000000000001??????????: _e_3911 = _e_3956;
            25'b0000000000000001?????????: _e_3911 = _e_3959;
            25'b00000000000000001????????: _e_3911 = \spi_in_res ;
            25'b000000000000000001???????: _e_3911 = \div_res ;
            25'b0000000000000000001??????: _e_3911 = \xorshift_res ;
            25'b00000000000000000001?????: _e_3911 = \mac_res ;
            25'b000000000000000000001????: _e_3911 = \sel_res ;
            25'b0000000000000000000001???: _e_3911 = \mda_res ;
            25'b00000000000000000000001??: _e_3911 = \tanh_res ;
            25'b000000000000000000000001?: _e_3911 = \stack_res ;
            25'b0000000000000000000000001: _e_3911 = \bit_res ;
            25'b?: _e_3911 = 33'dx;
        endcase
    end
    assign _e_3980 = {1'd0, 32'bX};
    assign \bus1_val_opt  = _e_3907 ? _e_3911 : _e_3980;
    assign _e_3984 = \insn [97:49];
    assign _e_3983 = _e_3984[11:1];
    (* src = "src/tta.spade:547,14" *)
    \tta::tta::decode_move  decode_move_0(.dst_i(_e_3983), .v_i(\bus0_val_opt ), .output__(\m0 ));
    assign _e_3990 = \insn [48:0];
    assign _e_3989 = _e_3990[11:1];
    (* src = "src/tta.spade:548,14" *)
    \tta::tta::decode_move  decode_move_1(.dst_i(_e_3989), .v_i(\bus1_val_opt ), .output__(\m1 ));
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
    assign _e_4176 = {\pc_val , \alu_op_a , \alu_trig , \alu_res , \pc_jump_final , \rf_w0 , \rf_w1 , \rd0 , \rd1 , \lsu_res , \lsu_set_addr , \lsu_store_trig , \lsu_load_trig , \gpo_res };
    assign output__ = _e_4176;
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
    logic[63:0] _e_4193;
    (* src = "src/fifo.spade:14,5" *)
    logic[73:0] _e_4192;
    localparam[7:0] _e_4194 = 0;
    localparam[7:0] _e_4195 = 0;
    localparam[7:0] _e_4196 = 0;
    localparam[7:0] _e_4197 = 0;
    localparam[7:0] _e_4198 = 0;
    localparam[7:0] _e_4199 = 0;
    localparam[7:0] _e_4200 = 0;
    localparam[7:0] _e_4201 = 0;
    assign _e_4193 = {_e_4201, _e_4200, _e_4199, _e_4198, _e_4197, _e_4196, _e_4195, _e_4194};
    localparam[2:0] _e_4202 = 0;
    localparam[2:0] _e_4203 = 0;
    localparam[3:0] _e_4204 = 0;
    assign _e_4192 = {_e_4193, _e_4202, _e_4203, _e_4204};
    assign output__ = _e_4192;
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
    logic _e_9157;
    (* src = "src/fifo.spade:20,20" *)
    logic[7:0] _e_4211;
    (* src = "src/fifo.spade:20,28" *)
    logic[7:0] _e_4214;
    (* src = "src/fifo.spade:20,36" *)
    logic[7:0] _e_4217;
    (* src = "src/fifo.spade:20,44" *)
    logic[7:0] _e_4220;
    (* src = "src/fifo.spade:20,52" *)
    logic[7:0] _e_4223;
    (* src = "src/fifo.spade:20,60" *)
    logic[7:0] _e_4226;
    (* src = "src/fifo.spade:20,68" *)
    logic[7:0] _e_4229;
    (* src = "src/fifo.spade:20,14" *)
    logic[63:0] _e_4209;
    logic _e_9159;
    (* src = "src/fifo.spade:21,15" *)
    logic[7:0] _e_4234;
    (* src = "src/fifo.spade:21,28" *)
    logic[7:0] _e_4238;
    (* src = "src/fifo.spade:21,36" *)
    logic[7:0] _e_4241;
    (* src = "src/fifo.spade:21,44" *)
    logic[7:0] _e_4244;
    (* src = "src/fifo.spade:21,52" *)
    logic[7:0] _e_4247;
    (* src = "src/fifo.spade:21,60" *)
    logic[7:0] _e_4250;
    (* src = "src/fifo.spade:21,68" *)
    logic[7:0] _e_4253;
    (* src = "src/fifo.spade:21,14" *)
    logic[63:0] _e_4233;
    logic _e_9161;
    (* src = "src/fifo.spade:22,15" *)
    logic[7:0] _e_4258;
    (* src = "src/fifo.spade:22,23" *)
    logic[7:0] _e_4261;
    (* src = "src/fifo.spade:22,36" *)
    logic[7:0] _e_4265;
    (* src = "src/fifo.spade:22,44" *)
    logic[7:0] _e_4268;
    (* src = "src/fifo.spade:22,52" *)
    logic[7:0] _e_4271;
    (* src = "src/fifo.spade:22,60" *)
    logic[7:0] _e_4274;
    (* src = "src/fifo.spade:22,68" *)
    logic[7:0] _e_4277;
    (* src = "src/fifo.spade:22,14" *)
    logic[63:0] _e_4257;
    logic _e_9163;
    (* src = "src/fifo.spade:23,15" *)
    logic[7:0] _e_4282;
    (* src = "src/fifo.spade:23,23" *)
    logic[7:0] _e_4285;
    (* src = "src/fifo.spade:23,31" *)
    logic[7:0] _e_4288;
    (* src = "src/fifo.spade:23,44" *)
    logic[7:0] _e_4292;
    (* src = "src/fifo.spade:23,52" *)
    logic[7:0] _e_4295;
    (* src = "src/fifo.spade:23,60" *)
    logic[7:0] _e_4298;
    (* src = "src/fifo.spade:23,68" *)
    logic[7:0] _e_4301;
    (* src = "src/fifo.spade:23,14" *)
    logic[63:0] _e_4281;
    logic _e_9165;
    (* src = "src/fifo.spade:24,15" *)
    logic[7:0] _e_4306;
    (* src = "src/fifo.spade:24,23" *)
    logic[7:0] _e_4309;
    (* src = "src/fifo.spade:24,31" *)
    logic[7:0] _e_4312;
    (* src = "src/fifo.spade:24,39" *)
    logic[7:0] _e_4315;
    (* src = "src/fifo.spade:24,52" *)
    logic[7:0] _e_4319;
    (* src = "src/fifo.spade:24,60" *)
    logic[7:0] _e_4322;
    (* src = "src/fifo.spade:24,68" *)
    logic[7:0] _e_4325;
    (* src = "src/fifo.spade:24,14" *)
    logic[63:0] _e_4305;
    logic _e_9167;
    (* src = "src/fifo.spade:25,15" *)
    logic[7:0] _e_4330;
    (* src = "src/fifo.spade:25,23" *)
    logic[7:0] _e_4333;
    (* src = "src/fifo.spade:25,31" *)
    logic[7:0] _e_4336;
    (* src = "src/fifo.spade:25,39" *)
    logic[7:0] _e_4339;
    (* src = "src/fifo.spade:25,47" *)
    logic[7:0] _e_4342;
    (* src = "src/fifo.spade:25,60" *)
    logic[7:0] _e_4346;
    (* src = "src/fifo.spade:25,68" *)
    logic[7:0] _e_4349;
    (* src = "src/fifo.spade:25,14" *)
    logic[63:0] _e_4329;
    logic _e_9169;
    (* src = "src/fifo.spade:26,15" *)
    logic[7:0] _e_4354;
    (* src = "src/fifo.spade:26,23" *)
    logic[7:0] _e_4357;
    (* src = "src/fifo.spade:26,31" *)
    logic[7:0] _e_4360;
    (* src = "src/fifo.spade:26,39" *)
    logic[7:0] _e_4363;
    (* src = "src/fifo.spade:26,47" *)
    logic[7:0] _e_4366;
    (* src = "src/fifo.spade:26,55" *)
    logic[7:0] _e_4369;
    (* src = "src/fifo.spade:26,68" *)
    logic[7:0] _e_4373;
    (* src = "src/fifo.spade:26,14" *)
    logic[63:0] _e_4353;
    logic _e_9171;
    (* src = "src/fifo.spade:27,15" *)
    logic[7:0] _e_4378;
    (* src = "src/fifo.spade:27,23" *)
    logic[7:0] _e_4381;
    (* src = "src/fifo.spade:27,31" *)
    logic[7:0] _e_4384;
    (* src = "src/fifo.spade:27,39" *)
    logic[7:0] _e_4387;
    (* src = "src/fifo.spade:27,47" *)
    logic[7:0] _e_4390;
    (* src = "src/fifo.spade:27,55" *)
    logic[7:0] _e_4393;
    (* src = "src/fifo.spade:27,63" *)
    logic[7:0] _e_4396;
    (* src = "src/fifo.spade:27,14" *)
    logic[63:0] _e_4377;
    (* src = "src/fifo.spade:19,5" *)
    logic[63:0] _e_4206;
    localparam[2:0] _e_9158 = 0;
    assign _e_9157 = \idx  == _e_9158;
    localparam[2:0] _e_4213 = 1;
    assign _e_4211 = \arr [_e_4213 * 8+:8];
    localparam[2:0] _e_4216 = 2;
    assign _e_4214 = \arr [_e_4216 * 8+:8];
    localparam[2:0] _e_4219 = 3;
    assign _e_4217 = \arr [_e_4219 * 8+:8];
    localparam[2:0] _e_4222 = 4;
    assign _e_4220 = \arr [_e_4222 * 8+:8];
    localparam[2:0] _e_4225 = 5;
    assign _e_4223 = \arr [_e_4225 * 8+:8];
    localparam[2:0] _e_4228 = 6;
    assign _e_4226 = \arr [_e_4228 * 8+:8];
    localparam[2:0] _e_4231 = 7;
    assign _e_4229 = \arr [_e_4231 * 8+:8];
    assign _e_4209 = {_e_4229, _e_4226, _e_4223, _e_4220, _e_4217, _e_4214, _e_4211, \val };
    localparam[2:0] _e_9160 = 1;
    assign _e_9159 = \idx  == _e_9160;
    localparam[2:0] _e_4236 = 0;
    assign _e_4234 = \arr [_e_4236 * 8+:8];
    localparam[2:0] _e_4240 = 2;
    assign _e_4238 = \arr [_e_4240 * 8+:8];
    localparam[2:0] _e_4243 = 3;
    assign _e_4241 = \arr [_e_4243 * 8+:8];
    localparam[2:0] _e_4246 = 4;
    assign _e_4244 = \arr [_e_4246 * 8+:8];
    localparam[2:0] _e_4249 = 5;
    assign _e_4247 = \arr [_e_4249 * 8+:8];
    localparam[2:0] _e_4252 = 6;
    assign _e_4250 = \arr [_e_4252 * 8+:8];
    localparam[2:0] _e_4255 = 7;
    assign _e_4253 = \arr [_e_4255 * 8+:8];
    assign _e_4233 = {_e_4253, _e_4250, _e_4247, _e_4244, _e_4241, _e_4238, \val , _e_4234};
    localparam[2:0] _e_9162 = 2;
    assign _e_9161 = \idx  == _e_9162;
    localparam[2:0] _e_4260 = 0;
    assign _e_4258 = \arr [_e_4260 * 8+:8];
    localparam[2:0] _e_4263 = 1;
    assign _e_4261 = \arr [_e_4263 * 8+:8];
    localparam[2:0] _e_4267 = 3;
    assign _e_4265 = \arr [_e_4267 * 8+:8];
    localparam[2:0] _e_4270 = 4;
    assign _e_4268 = \arr [_e_4270 * 8+:8];
    localparam[2:0] _e_4273 = 5;
    assign _e_4271 = \arr [_e_4273 * 8+:8];
    localparam[2:0] _e_4276 = 6;
    assign _e_4274 = \arr [_e_4276 * 8+:8];
    localparam[2:0] _e_4279 = 7;
    assign _e_4277 = \arr [_e_4279 * 8+:8];
    assign _e_4257 = {_e_4277, _e_4274, _e_4271, _e_4268, _e_4265, \val , _e_4261, _e_4258};
    localparam[2:0] _e_9164 = 3;
    assign _e_9163 = \idx  == _e_9164;
    localparam[2:0] _e_4284 = 0;
    assign _e_4282 = \arr [_e_4284 * 8+:8];
    localparam[2:0] _e_4287 = 1;
    assign _e_4285 = \arr [_e_4287 * 8+:8];
    localparam[2:0] _e_4290 = 2;
    assign _e_4288 = \arr [_e_4290 * 8+:8];
    localparam[2:0] _e_4294 = 4;
    assign _e_4292 = \arr [_e_4294 * 8+:8];
    localparam[2:0] _e_4297 = 5;
    assign _e_4295 = \arr [_e_4297 * 8+:8];
    localparam[2:0] _e_4300 = 6;
    assign _e_4298 = \arr [_e_4300 * 8+:8];
    localparam[2:0] _e_4303 = 7;
    assign _e_4301 = \arr [_e_4303 * 8+:8];
    assign _e_4281 = {_e_4301, _e_4298, _e_4295, _e_4292, \val , _e_4288, _e_4285, _e_4282};
    localparam[2:0] _e_9166 = 4;
    assign _e_9165 = \idx  == _e_9166;
    localparam[2:0] _e_4308 = 0;
    assign _e_4306 = \arr [_e_4308 * 8+:8];
    localparam[2:0] _e_4311 = 1;
    assign _e_4309 = \arr [_e_4311 * 8+:8];
    localparam[2:0] _e_4314 = 2;
    assign _e_4312 = \arr [_e_4314 * 8+:8];
    localparam[2:0] _e_4317 = 3;
    assign _e_4315 = \arr [_e_4317 * 8+:8];
    localparam[2:0] _e_4321 = 5;
    assign _e_4319 = \arr [_e_4321 * 8+:8];
    localparam[2:0] _e_4324 = 6;
    assign _e_4322 = \arr [_e_4324 * 8+:8];
    localparam[2:0] _e_4327 = 7;
    assign _e_4325 = \arr [_e_4327 * 8+:8];
    assign _e_4305 = {_e_4325, _e_4322, _e_4319, \val , _e_4315, _e_4312, _e_4309, _e_4306};
    localparam[2:0] _e_9168 = 5;
    assign _e_9167 = \idx  == _e_9168;
    localparam[2:0] _e_4332 = 0;
    assign _e_4330 = \arr [_e_4332 * 8+:8];
    localparam[2:0] _e_4335 = 1;
    assign _e_4333 = \arr [_e_4335 * 8+:8];
    localparam[2:0] _e_4338 = 2;
    assign _e_4336 = \arr [_e_4338 * 8+:8];
    localparam[2:0] _e_4341 = 3;
    assign _e_4339 = \arr [_e_4341 * 8+:8];
    localparam[2:0] _e_4344 = 4;
    assign _e_4342 = \arr [_e_4344 * 8+:8];
    localparam[2:0] _e_4348 = 6;
    assign _e_4346 = \arr [_e_4348 * 8+:8];
    localparam[2:0] _e_4351 = 7;
    assign _e_4349 = \arr [_e_4351 * 8+:8];
    assign _e_4329 = {_e_4349, _e_4346, \val , _e_4342, _e_4339, _e_4336, _e_4333, _e_4330};
    localparam[2:0] _e_9170 = 6;
    assign _e_9169 = \idx  == _e_9170;
    localparam[2:0] _e_4356 = 0;
    assign _e_4354 = \arr [_e_4356 * 8+:8];
    localparam[2:0] _e_4359 = 1;
    assign _e_4357 = \arr [_e_4359 * 8+:8];
    localparam[2:0] _e_4362 = 2;
    assign _e_4360 = \arr [_e_4362 * 8+:8];
    localparam[2:0] _e_4365 = 3;
    assign _e_4363 = \arr [_e_4365 * 8+:8];
    localparam[2:0] _e_4368 = 4;
    assign _e_4366 = \arr [_e_4368 * 8+:8];
    localparam[2:0] _e_4371 = 5;
    assign _e_4369 = \arr [_e_4371 * 8+:8];
    localparam[2:0] _e_4375 = 7;
    assign _e_4373 = \arr [_e_4375 * 8+:8];
    assign _e_4353 = {_e_4373, \val , _e_4369, _e_4366, _e_4363, _e_4360, _e_4357, _e_4354};
    localparam[2:0] _e_9172 = 7;
    assign _e_9171 = \idx  == _e_9172;
    localparam[2:0] _e_4380 = 0;
    assign _e_4378 = \arr [_e_4380 * 8+:8];
    localparam[2:0] _e_4383 = 1;
    assign _e_4381 = \arr [_e_4383 * 8+:8];
    localparam[2:0] _e_4386 = 2;
    assign _e_4384 = \arr [_e_4386 * 8+:8];
    localparam[2:0] _e_4389 = 3;
    assign _e_4387 = \arr [_e_4389 * 8+:8];
    localparam[2:0] _e_4392 = 4;
    assign _e_4390 = \arr [_e_4392 * 8+:8];
    localparam[2:0] _e_4395 = 5;
    assign _e_4393 = \arr [_e_4395 * 8+:8];
    localparam[2:0] _e_4398 = 6;
    assign _e_4396 = \arr [_e_4398 * 8+:8];
    assign _e_4377 = {\val , _e_4396, _e_4393, _e_4390, _e_4387, _e_4384, _e_4381, _e_4378};
    always_comb begin
        priority casez ({_e_9157, _e_9159, _e_9161, _e_9163, _e_9165, _e_9167, _e_9169, _e_9171})
            8'b1???????: _e_4206 = _e_4209;
            8'b01??????: _e_4206 = _e_4233;
            8'b001?????: _e_4206 = _e_4257;
            8'b0001????: _e_4206 = _e_4281;
            8'b00001???: _e_4206 = _e_4305;
            8'b000001??: _e_4206 = _e_4329;
            8'b0000001?: _e_4206 = _e_4353;
            8'b00000001: _e_4206 = _e_4377;
            8'b?: _e_4206 = 64'dx;
        endcase
    end
    assign output__ = _e_4206;
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
    logic[73:0] _e_4404;
    (* src = "src/fifo.spade:46,23" *)
    logic[3:0] _e_4407;
    (* src = "src/fifo.spade:46,23" *)
    logic \is_full ;
    (* src = "src/fifo.spade:47,24" *)
    logic[3:0] _e_4412;
    (* src = "src/fifo.spade:47,24" *)
    logic \is_empty ;
    (* src = "src/fifo.spade:52,13" *)
    logic[7:0] \_ ;
    logic _e_9174;
    logic _e_9176;
    (* src = "src/fifo.spade:52,24" *)
    logic _e_4421;
    (* src = "src/fifo.spade:52,24" *)
    logic _e_4420;
    logic _e_9178;
    (* src = "src/fifo.spade:51,23" *)
    logic \do_push ;
    (* src = "src/fifo.spade:57,29" *)
    logic _e_4429;
    (* src = "src/fifo.spade:57,22" *)
    logic \do_pop ;
    (* src = "src/fifo.spade:61,41" *)
    logic[2:0] _e_4437;
    (* src = "src/fifo.spade:61,41" *)
    logic[3:0] _e_4436;
    (* src = "src/fifo.spade:61,35" *)
    logic[2:0] _e_4435;
    (* src = "src/fifo.spade:61,63" *)
    logic[2:0] _e_4441;
    (* src = "src/fifo.spade:61,22" *)
    logic[2:0] \next_w ;
    (* src = "src/fifo.spade:62,41" *)
    logic[2:0] _e_4449;
    (* src = "src/fifo.spade:62,41" *)
    logic[3:0] _e_4448;
    (* src = "src/fifo.spade:62,35" *)
    logic[2:0] _e_4447;
    (* src = "src/fifo.spade:62,63" *)
    logic[2:0] _e_4453;
    (* src = "src/fifo.spade:62,22" *)
    logic[2:0] \next_r ;
    (* src = "src/fifo.spade:64,32" *)
    logic[1:0] _e_4457;
    (* src = "src/fifo.spade:65,13" *)
    logic[1:0] _e_4462;
    (* src = "src/fifo.spade:65,13" *)
    logic _e_4460;
    (* src = "src/fifo.spade:65,13" *)
    logic _e_4461;
    logic _e_9181;
    logic _e_9182;
    (* src = "src/fifo.spade:65,36" *)
    logic[3:0] _e_4465;
    (* src = "src/fifo.spade:65,36" *)
    logic[4:0] _e_4464;
    (* src = "src/fifo.spade:65,30" *)
    logic[3:0] _e_4463;
    (* src = "src/fifo.spade:66,13" *)
    logic[1:0] _e_4470;
    (* src = "src/fifo.spade:66,13" *)
    logic _e_4468;
    (* src = "src/fifo.spade:66,13" *)
    logic _e_4469;
    logic _e_9184;
    logic _e_9186;
    (* src = "src/fifo.spade:66,36" *)
    logic[3:0] _e_4473;
    (* src = "src/fifo.spade:66,36" *)
    logic[4:0] _e_4472;
    (* src = "src/fifo.spade:66,30" *)
    logic[3:0] _e_4471;
    (* src = "src/fifo.spade:67,13" *)
    logic[1:0] __n1;
    (* src = "src/fifo.spade:67,18" *)
    logic[3:0] _e_4477;
    (* src = "src/fifo.spade:64,26" *)
    logic[3:0] \next_count ;
    (* src = "src/fifo.spade:72,13" *)
    logic[7:0] \val ;
    logic _e_9189;
    logic _e_9191;
    (* src = "src/fifo.spade:72,47" *)
    logic[63:0] _e_4488;
    (* src = "src/fifo.spade:72,54" *)
    logic[2:0] _e_4490;
    (* src = "src/fifo.spade:72,39" *)
    logic[63:0] _e_4487;
    (* src = "src/fifo.spade:72,77" *)
    logic[63:0] _e_4494;
    (* src = "src/fifo.spade:72,26" *)
    logic[63:0] _e_4484;
    logic _e_9193;
    (* src = "src/fifo.spade:73,21" *)
    logic[63:0] _e_4497;
    (* src = "src/fifo.spade:71,24" *)
    logic[63:0] \next_mem ;
    (* src = "src/fifo.spade:76,9" *)
    logic[73:0] _e_4500;
    (* src = "src/fifo.spade:45,14" *)
    reg[73:0] \s ;
    (* src = "src/fifo.spade:80,17" *)
    logic[3:0] _e_4506;
    (* src = "src/fifo.spade:80,17" *)
    logic \empty ;
    (* src = "src/fifo.spade:81,17" *)
    logic[3:0] _e_4511;
    (* src = "src/fifo.spade:81,17" *)
    logic \full ;
    (* src = "src/fifo.spade:84,22" *)
    logic _e_4516;
    (* src = "src/fifo.spade:87,25" *)
    logic[2:0] _e_4520;
    (* src = "src/fifo.spade:88,13" *)
    logic[2:0] _e_4522;
    logic _e_9194;
    (* src = "src/fifo.spade:88,18" *)
    logic[63:0] _e_4524;
    (* src = "src/fifo.spade:88,18" *)
    logic[7:0] _e_4523;
    (* src = "src/fifo.spade:88,28" *)
    logic[2:0] _e_4527;
    logic _e_9196;
    (* src = "src/fifo.spade:88,33" *)
    logic[63:0] _e_4529;
    (* src = "src/fifo.spade:88,33" *)
    logic[7:0] _e_4528;
    (* src = "src/fifo.spade:88,43" *)
    logic[2:0] _e_4532;
    logic _e_9198;
    (* src = "src/fifo.spade:88,48" *)
    logic[63:0] _e_4534;
    (* src = "src/fifo.spade:88,48" *)
    logic[7:0] _e_4533;
    (* src = "src/fifo.spade:88,58" *)
    logic[2:0] _e_4537;
    logic _e_9200;
    (* src = "src/fifo.spade:88,63" *)
    logic[63:0] _e_4539;
    (* src = "src/fifo.spade:88,63" *)
    logic[7:0] _e_4538;
    (* src = "src/fifo.spade:89,13" *)
    logic[2:0] _e_4542;
    logic _e_9202;
    (* src = "src/fifo.spade:89,18" *)
    logic[63:0] _e_4544;
    (* src = "src/fifo.spade:89,18" *)
    logic[7:0] _e_4543;
    (* src = "src/fifo.spade:89,28" *)
    logic[2:0] _e_4547;
    logic _e_9204;
    (* src = "src/fifo.spade:89,33" *)
    logic[63:0] _e_4549;
    (* src = "src/fifo.spade:89,33" *)
    logic[7:0] _e_4548;
    (* src = "src/fifo.spade:89,43" *)
    logic[2:0] _e_4552;
    logic _e_9206;
    (* src = "src/fifo.spade:89,48" *)
    logic[63:0] _e_4554;
    (* src = "src/fifo.spade:89,48" *)
    logic[7:0] _e_4553;
    (* src = "src/fifo.spade:89,58" *)
    logic[2:0] _e_4557;
    logic _e_9208;
    (* src = "src/fifo.spade:89,63" *)
    logic[63:0] _e_4559;
    (* src = "src/fifo.spade:89,63" *)
    logic[7:0] _e_4558;
    (* src = "src/fifo.spade:87,19" *)
    logic[7:0] val_n1;
    (* src = "src/fifo.spade:91,9" *)
    logic[8:0] _e_4563;
    (* src = "src/fifo.spade:93,9" *)
    logic[8:0] _e_4566;
    (* src = "src/fifo.spade:84,19" *)
    logic[8:0] \out_val ;
    (* src = "src/fifo.spade:96,26" *)
    logic[3:0] _e_4571;
    (* src = "src/fifo.spade:96,5" *)
    logic[14:0] _e_4568;
    (* src = "src/fifo.spade:45,38" *)
    \tta::fifo::reset_fifo  reset_fifo_0(.output__(_e_4404));
    assign _e_4407 = \s [3:0];
    localparam[3:0] _e_4409 = 8;
    assign \is_full  = _e_4407 == _e_4409;
    assign _e_4412 = \s [3:0];
    localparam[3:0] _e_4414 = 0;
    assign \is_empty  = _e_4412 == _e_4414;
    assign \_  = \push [7:0];
    assign _e_9174 = \push [8] == 1'd1;
    localparam[0:0] _e_9175 = 1;
    assign _e_9176 = _e_9174 && _e_9175;
    assign _e_4421 = !\is_full ;
    assign _e_4420 = _e_4421 || \pop ;
    assign _e_9178 = \push [8] == 1'd0;
    localparam[0:0] _e_4425 = 0;
    always_comb begin
        priority casez ({_e_9176, _e_9178})
            2'b1?: \do_push  = _e_4420;
            2'b01: \do_push  = _e_4425;
            2'b?: \do_push  = 1'dx;
        endcase
    end
    assign _e_4429 = !\is_empty ;
    assign \do_pop  = \pop  && _e_4429;
    assign _e_4437 = \s [9:7];
    localparam[2:0] _e_4439 = 1;
    assign _e_4436 = _e_4437 + _e_4439;
    assign _e_4435 = _e_4436[2:0];
    assign _e_4441 = \s [9:7];
    assign \next_w  = \do_push  ? _e_4435 : _e_4441;
    assign _e_4449 = \s [6:4];
    localparam[2:0] _e_4451 = 1;
    assign _e_4448 = _e_4449 + _e_4451;
    assign _e_4447 = _e_4448[2:0];
    assign _e_4453 = \s [6:4];
    assign \next_r  = \do_pop  ? _e_4447 : _e_4453;
    assign _e_4457 = {\do_push , \do_pop };
    assign _e_4462 = _e_4457;
    assign _e_4460 = _e_4457[1];
    assign _e_4461 = _e_4457[0];
    assign _e_9181 = !_e_4461;
    assign _e_9182 = _e_4460 && _e_9181;
    assign _e_4465 = \s [3:0];
    localparam[3:0] _e_4467 = 1;
    assign _e_4464 = _e_4465 + _e_4467;
    assign _e_4463 = _e_4464[3:0];
    assign _e_4470 = _e_4457;
    assign _e_4468 = _e_4457[1];
    assign _e_4469 = _e_4457[0];
    assign _e_9184 = !_e_4468;
    assign _e_9186 = _e_9184 && _e_4469;
    assign _e_4473 = \s [3:0];
    localparam[3:0] _e_4475 = 1;
    assign _e_4472 = _e_4473 - _e_4475;
    assign _e_4471 = _e_4472[3:0];
    assign __n1 = _e_4457;
    localparam[0:0] _e_9187 = 1;
    assign _e_4477 = \s [3:0];
    always_comb begin
        priority casez ({_e_9182, _e_9186, _e_9187})
            3'b1??: \next_count  = _e_4463;
            3'b01?: \next_count  = _e_4471;
            3'b001: \next_count  = _e_4477;
            3'b?: \next_count  = 4'dx;
        endcase
    end
    assign \val  = \push [7:0];
    assign _e_9189 = \push [8] == 1'd1;
    localparam[0:0] _e_9190 = 1;
    assign _e_9191 = _e_9189 && _e_9190;
    assign _e_4488 = \s [73:10];
    assign _e_4490 = \s [9:7];
    (* src = "src/fifo.spade:72,39" *)
    \tta::fifo::set_mem  set_mem_0(.arr_i(_e_4488), .idx_i(_e_4490), .val_i(\val ), .output__(_e_4487));
    assign _e_4494 = \s [73:10];
    assign _e_4484 = \do_push  ? _e_4487 : _e_4494;
    assign _e_9193 = \push [8] == 1'd0;
    assign _e_4497 = \s [73:10];
    always_comb begin
        priority casez ({_e_9191, _e_9193})
            2'b1?: \next_mem  = _e_4484;
            2'b01: \next_mem  = _e_4497;
            2'b?: \next_mem  = 64'dx;
        endcase
    end
    assign _e_4500 = {\next_mem , \next_w , \next_r , \next_count };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \s  <= _e_4404;
        end
        else begin
            \s  <= _e_4500;
        end
    end
    assign _e_4506 = \s [3:0];
    localparam[3:0] _e_4508 = 0;
    assign \empty  = _e_4506 == _e_4508;
    assign _e_4511 = \s [3:0];
    localparam[3:0] _e_4513 = 8;
    assign \full  = _e_4511 == _e_4513;
    assign _e_4516 = !\empty ;
    assign _e_4520 = \s [6:4];
    assign _e_4522 = _e_4520;
    localparam[2:0] _e_9195 = 0;
    assign _e_9194 = _e_4520 == _e_9195;
    assign _e_4524 = \s [73:10];
    localparam[2:0] _e_4526 = 0;
    assign _e_4523 = _e_4524[_e_4526 * 8+:8];
    assign _e_4527 = _e_4520;
    localparam[2:0] _e_9197 = 1;
    assign _e_9196 = _e_4520 == _e_9197;
    assign _e_4529 = \s [73:10];
    localparam[2:0] _e_4531 = 1;
    assign _e_4528 = _e_4529[_e_4531 * 8+:8];
    assign _e_4532 = _e_4520;
    localparam[2:0] _e_9199 = 2;
    assign _e_9198 = _e_4520 == _e_9199;
    assign _e_4534 = \s [73:10];
    localparam[2:0] _e_4536 = 2;
    assign _e_4533 = _e_4534[_e_4536 * 8+:8];
    assign _e_4537 = _e_4520;
    localparam[2:0] _e_9201 = 3;
    assign _e_9200 = _e_4520 == _e_9201;
    assign _e_4539 = \s [73:10];
    localparam[2:0] _e_4541 = 3;
    assign _e_4538 = _e_4539[_e_4541 * 8+:8];
    assign _e_4542 = _e_4520;
    localparam[2:0] _e_9203 = 4;
    assign _e_9202 = _e_4520 == _e_9203;
    assign _e_4544 = \s [73:10];
    localparam[2:0] _e_4546 = 4;
    assign _e_4543 = _e_4544[_e_4546 * 8+:8];
    assign _e_4547 = _e_4520;
    localparam[2:0] _e_9205 = 5;
    assign _e_9204 = _e_4520 == _e_9205;
    assign _e_4549 = \s [73:10];
    localparam[2:0] _e_4551 = 5;
    assign _e_4548 = _e_4549[_e_4551 * 8+:8];
    assign _e_4552 = _e_4520;
    localparam[2:0] _e_9207 = 6;
    assign _e_9206 = _e_4520 == _e_9207;
    assign _e_4554 = \s [73:10];
    localparam[2:0] _e_4556 = 6;
    assign _e_4553 = _e_4554[_e_4556 * 8+:8];
    assign _e_4557 = _e_4520;
    localparam[2:0] _e_9209 = 7;
    assign _e_9208 = _e_4520 == _e_9209;
    assign _e_4559 = \s [73:10];
    localparam[2:0] _e_4561 = 7;
    assign _e_4558 = _e_4559[_e_4561 * 8+:8];
    always_comb begin
        priority casez ({_e_9194, _e_9196, _e_9198, _e_9200, _e_9202, _e_9204, _e_9206, _e_9208})
            8'b1???????: val_n1 = _e_4523;
            8'b01??????: val_n1 = _e_4528;
            8'b001?????: val_n1 = _e_4533;
            8'b0001????: val_n1 = _e_4538;
            8'b00001???: val_n1 = _e_4543;
            8'b000001??: val_n1 = _e_4548;
            8'b0000001?: val_n1 = _e_4553;
            8'b00000001: val_n1 = _e_4558;
            8'b?: val_n1 = 8'dx;
        endcase
    end
    assign _e_4563 = {1'd1, val_n1};
    assign _e_4566 = {1'd0, 8'bX};
    assign \out_val  = _e_4516 ? _e_4563 : _e_4566;
    assign _e_4571 = \s [3:0];
    assign _e_4568 = {\full , \empty , _e_4571, \out_val };
    assign output__ = _e_4568;
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
    logic _e_9211;
    logic _e_9213;
    logic _e_9215;
    (* src = "src/lsu.spade:23,47" *)
    logic[31:0] _e_4579;
    (* src = "src/lsu.spade:23,14" *)
    reg[31:0] \addr_a ;
    (* src = "src/lsu.spade:29,9" *)
    logic[31:0] \b ;
    logic _e_9217;
    logic _e_9219;
    (* src = "src/lsu.spade:29,20" *)
    logic[32:0] _e_4590;
    logic _e_9221;
    logic[32:0] _e_4594;
    (* src = "src/lsu.spade:28,31" *)
    logic[32:0] \addr_calc ;
    (* src = "src/lsu.spade:34,41" *)
    logic[31:0] \_ ;
    logic _e_9223;
    logic _e_9225;
    logic _e_9227;
    (* src = "src/lsu.spade:34,22" *)
    logic \wren ;
    (* src = "src/lsu.spade:35,36" *)
    logic[31:0] \x ;
    logic _e_9229;
    logic _e_9231;
    logic _e_9233;
    (* src = "src/lsu.spade:35,17" *)
    logic[31:0] \wdata ;
    (* src = "src/lsu.spade:36,56" *)
    logic[15:0] _e_4617;
    (* src = "src/lsu.spade:36,17" *)
    logic[31:0] \rdata ;
    (* src = "src/lsu.spade:39,55" *)
    logic[65:0] _e_4627;
    (* src = "src/lsu.spade:40,9" *)
    logic[65:0] _e_4633;
    (* src = "src/lsu.spade:40,9" *)
    logic[32:0] _e_4631;
    (* src = "src/lsu.spade:40,10" *)
    logic[31:0] __n1;
    (* src = "src/lsu.spade:40,9" *)
    logic[32:0] _e_4632;
    logic _e_9236;
    logic _e_9238;
    logic _e_9240;
    logic _e_9241;
    (* src = "src/lsu.spade:41,9" *)
    logic[65:0] _e_4638;
    (* src = "src/lsu.spade:41,9" *)
    logic[32:0] __n2;
    (* src = "src/lsu.spade:41,9" *)
    logic[32:0] _e_4637;
    (* src = "src/lsu.spade:41,13" *)
    logic[31:0] __n3;
    logic _e_9245;
    logic _e_9247;
    logic _e_9248;
    (* src = "src/lsu.spade:42,9" *)
    logic[65:0] _e_4642;
    (* src = "src/lsu.spade:42,9" *)
    logic[32:0] _e_4640;
    (* src = "src/lsu.spade:42,9" *)
    logic[32:0] _e_4641;
    logic _e_9251;
    logic _e_9253;
    logic _e_9254;
    (* src = "src/lsu.spade:39,49" *)
    logic _e_4626;
    (* src = "src/lsu.spade:39,14" *)
    reg \ld_ready ;
    (* src = "src/lsu.spade:45,19" *)
    logic[32:0] _e_4647;
    (* src = "src/lsu.spade:45,40" *)
    logic[32:0] _e_4650;
    (* src = "src/lsu.spade:45,5" *)
    logic[32:0] _e_4644;
    localparam[31:0] _e_4578 = 32'd0;
    assign \v  = \set_addr_a [31:0];
    assign _e_9211 = \set_addr_a [32] == 1'd1;
    localparam[0:0] _e_9212 = 1;
    assign _e_9213 = _e_9211 && _e_9212;
    assign _e_9215 = \set_addr_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9213, _e_9215})
            2'b1?: _e_4579 = \v ;
            2'b01: _e_4579 = \addr_a ;
            2'b?: _e_4579 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \addr_a  <= _e_4578;
        end
        else begin
            \addr_a  <= _e_4579;
        end
    end
    assign \b  = \load_trig [31:0];
    assign _e_9217 = \load_trig [32] == 1'd1;
    localparam[0:0] _e_9218 = 1;
    assign _e_9219 = _e_9217 && _e_9218;
    assign _e_4590 = \addr_a  + \b ;
    assign _e_9221 = \load_trig [32] == 1'd0;
    assign _e_4594 = {1'b0, \addr_a };
    always_comb begin
        priority casez ({_e_9219, _e_9221})
            2'b1?: \addr_calc  = _e_4590;
            2'b01: \addr_calc  = _e_4594;
            2'b?: \addr_calc  = 33'dx;
        endcase
    end
    assign \_  = \store_trig [31:0];
    assign _e_9223 = \store_trig [32] == 1'd1;
    localparam[0:0] _e_9224 = 1;
    assign _e_9225 = _e_9223 && _e_9224;
    localparam[0:0] _e_4601 = 1;
    assign _e_9227 = \store_trig [32] == 1'd0;
    localparam[0:0] _e_4603 = 0;
    always_comb begin
        priority casez ({_e_9225, _e_9227})
            2'b1?: \wren  = _e_4601;
            2'b01: \wren  = _e_4603;
            2'b?: \wren  = 1'dx;
        endcase
    end
    assign \x  = \store_trig [31:0];
    assign _e_9229 = \store_trig [32] == 1'd1;
    localparam[0:0] _e_9230 = 1;
    assign _e_9231 = _e_9229 && _e_9230;
    assign _e_9233 = \store_trig [32] == 1'd0;
    localparam[31:0] _e_4611 = 32'd0;
    always_comb begin
        priority casez ({_e_9231, _e_9233})
            2'b1?: \wdata  = \x ;
            2'b01: \wdata  = _e_4611;
            2'b?: \wdata  = 32'dx;
        endcase
    end
    localparam[0:0] _e_4616 = 1;
    assign _e_4617 = \addr_calc [15:0];
    (* src = "src/lsu.spade:36,17" *)
    \tta::sram::sram_512x32  sram_512x32_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .en_i(_e_4616), .addr_i(_e_4617), .we_i(\wren ), .wdata_i(\wdata ), .output__(\rdata ));
    localparam[0:0] _e_4625 = 0;
    assign _e_4627 = {\load_trig , \store_trig };
    assign _e_4633 = _e_4627;
    assign _e_4631 = _e_4627[65:33];
    assign __n1 = _e_4631[31:0];
    assign _e_4632 = _e_4627[32:0];
    assign _e_9236 = _e_4631[32] == 1'd1;
    localparam[0:0] _e_9237 = 1;
    assign _e_9238 = _e_9236 && _e_9237;
    assign _e_9240 = _e_4632[32] == 1'd0;
    assign _e_9241 = _e_9238 && _e_9240;
    localparam[0:0] _e_4634 = 1;
    assign _e_4638 = _e_4627;
    assign __n2 = _e_4627[65:33];
    assign _e_4637 = _e_4627[32:0];
    assign __n3 = _e_4637[31:0];
    localparam[0:0] _e_9243 = 1;
    assign _e_9245 = _e_4637[32] == 1'd1;
    localparam[0:0] _e_9246 = 1;
    assign _e_9247 = _e_9245 && _e_9246;
    assign _e_9248 = _e_9243 && _e_9247;
    localparam[0:0] _e_4639 = 0;
    assign _e_4642 = _e_4627;
    assign _e_4640 = _e_4627[65:33];
    assign _e_4641 = _e_4627[32:0];
    assign _e_9251 = _e_4640[32] == 1'd0;
    assign _e_9253 = _e_4641[32] == 1'd0;
    assign _e_9254 = _e_9251 && _e_9253;
    localparam[0:0] _e_4643 = 0;
    always_comb begin
        priority casez ({_e_9241, _e_9248, _e_9254})
            3'b1??: _e_4626 = _e_4634;
            3'b01?: _e_4626 = _e_4639;
            3'b001: _e_4626 = _e_4643;
            3'b?: _e_4626 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \ld_ready  <= _e_4625;
        end
        else begin
            \ld_ready  <= _e_4626;
        end
    end
    assign _e_4647 = {1'd1, \rdata };
    assign _e_4650 = {1'd0, 32'bX};
    assign _e_4644 = \ld_ready  ? _e_4647 : _e_4650;
    assign output__ = _e_4644;
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
    logic[42:0] _e_4655;
    (* src = "src/lsu.spade:53,14" *)
    logic[31:0] \x ;
    logic _e_9256;
    logic _e_9258;
    logic _e_9260;
    logic _e_9261;
    (* src = "src/lsu.spade:53,35" *)
    logic[32:0] _e_4657;
    (* src = "src/lsu.spade:54,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:55,13" *)
    logic[42:0] _e_4663;
    (* src = "src/lsu.spade:55,18" *)
    logic[31:0] x_n1;
    logic _e_9264;
    logic _e_9266;
    logic _e_9268;
    logic _e_9269;
    (* src = "src/lsu.spade:55,39" *)
    logic[32:0] _e_4665;
    (* src = "src/lsu.spade:56,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:56,18" *)
    logic[32:0] _e_4668;
    (* src = "src/lsu.spade:54,14" *)
    logic[32:0] _e_4660;
    (* src = "src/lsu.spade:52,5" *)
    logic[32:0] _e_4652;
    assign _e_4655 = \m1 [42:0];
    assign \x  = _e_4655[36:5];
    assign _e_9256 = \m1 [43] == 1'd1;
    assign _e_9258 = _e_4655[42:37] == 6'd4;
    localparam[0:0] _e_9259 = 1;
    assign _e_9260 = _e_9258 && _e_9259;
    assign _e_9261 = _e_9256 && _e_9260;
    assign _e_4657 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9262 = 1;
    assign _e_4663 = \m0 [42:0];
    assign x_n1 = _e_4663[36:5];
    assign _e_9264 = \m0 [43] == 1'd1;
    assign _e_9266 = _e_4663[42:37] == 6'd4;
    localparam[0:0] _e_9267 = 1;
    assign _e_9268 = _e_9266 && _e_9267;
    assign _e_9269 = _e_9264 && _e_9268;
    assign _e_4665 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9270 = 1;
    assign _e_4668 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9269, _e_9270})
            2'b1?: _e_4660 = _e_4665;
            2'b01: _e_4660 = _e_4668;
            2'b?: _e_4660 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9261, _e_9262})
            2'b1?: _e_4652 = _e_4657;
            2'b01: _e_4652 = _e_4660;
            2'b?: _e_4652 = 33'dx;
        endcase
    end
    assign output__ = _e_4652;
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
    logic[42:0] _e_4673;
    (* src = "src/lsu.spade:63,14" *)
    logic[31:0] \x ;
    logic _e_9272;
    logic _e_9274;
    logic _e_9276;
    logic _e_9277;
    (* src = "src/lsu.spade:63,40" *)
    logic[32:0] _e_4675;
    (* src = "src/lsu.spade:64,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:65,13" *)
    logic[42:0] _e_4681;
    (* src = "src/lsu.spade:65,18" *)
    logic[31:0] x_n1;
    logic _e_9280;
    logic _e_9282;
    logic _e_9284;
    logic _e_9285;
    (* src = "src/lsu.spade:65,44" *)
    logic[32:0] _e_4683;
    (* src = "src/lsu.spade:66,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:66,18" *)
    logic[32:0] _e_4686;
    (* src = "src/lsu.spade:64,14" *)
    logic[32:0] _e_4678;
    (* src = "src/lsu.spade:62,5" *)
    logic[32:0] _e_4670;
    assign _e_4673 = \m1 [42:0];
    assign \x  = _e_4673[36:5];
    assign _e_9272 = \m1 [43] == 1'd1;
    assign _e_9274 = _e_4673[42:37] == 6'd5;
    localparam[0:0] _e_9275 = 1;
    assign _e_9276 = _e_9274 && _e_9275;
    assign _e_9277 = _e_9272 && _e_9276;
    assign _e_4675 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9278 = 1;
    assign _e_4681 = \m0 [42:0];
    assign x_n1 = _e_4681[36:5];
    assign _e_9280 = \m0 [43] == 1'd1;
    assign _e_9282 = _e_4681[42:37] == 6'd5;
    localparam[0:0] _e_9283 = 1;
    assign _e_9284 = _e_9282 && _e_9283;
    assign _e_9285 = _e_9280 && _e_9284;
    assign _e_4683 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9286 = 1;
    assign _e_4686 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9285, _e_9286})
            2'b1?: _e_4678 = _e_4683;
            2'b01: _e_4678 = _e_4686;
            2'b?: _e_4678 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9277, _e_9278})
            2'b1?: _e_4670 = _e_4675;
            2'b01: _e_4670 = _e_4678;
            2'b?: _e_4670 = 33'dx;
        endcase
    end
    assign output__ = _e_4670;
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
    logic[42:0] _e_4691;
    (* src = "src/lsu.spade:73,14" *)
    logic[31:0] \x ;
    logic _e_9288;
    logic _e_9290;
    logic _e_9292;
    logic _e_9293;
    (* src = "src/lsu.spade:73,41" *)
    logic[32:0] _e_4693;
    (* src = "src/lsu.spade:74,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:75,13" *)
    logic[42:0] _e_4699;
    (* src = "src/lsu.spade:75,18" *)
    logic[31:0] x_n1;
    logic _e_9296;
    logic _e_9298;
    logic _e_9300;
    logic _e_9301;
    (* src = "src/lsu.spade:75,45" *)
    logic[32:0] _e_4701;
    (* src = "src/lsu.spade:76,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:76,18" *)
    logic[32:0] _e_4704;
    (* src = "src/lsu.spade:74,14" *)
    logic[32:0] _e_4696;
    (* src = "src/lsu.spade:72,5" *)
    logic[32:0] _e_4688;
    assign _e_4691 = \m1 [42:0];
    assign \x  = _e_4691[36:5];
    assign _e_9288 = \m1 [43] == 1'd1;
    assign _e_9290 = _e_4691[42:37] == 6'd6;
    localparam[0:0] _e_9291 = 1;
    assign _e_9292 = _e_9290 && _e_9291;
    assign _e_9293 = _e_9288 && _e_9292;
    assign _e_4693 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9294 = 1;
    assign _e_4699 = \m0 [42:0];
    assign x_n1 = _e_4699[36:5];
    assign _e_9296 = \m0 [43] == 1'd1;
    assign _e_9298 = _e_4699[42:37] == 6'd6;
    localparam[0:0] _e_9299 = 1;
    assign _e_9300 = _e_9298 && _e_9299;
    assign _e_9301 = _e_9296 && _e_9300;
    assign _e_4701 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9302 = 1;
    assign _e_4704 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9301, _e_9302})
            2'b1?: _e_4696 = _e_4701;
            2'b01: _e_4696 = _e_4704;
            2'b?: _e_4696 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9293, _e_9294})
            2'b1?: _e_4688 = _e_4693;
            2'b01: _e_4688 = _e_4696;
            2'b?: _e_4688 = 33'dx;
        endcase
    end
    assign output__ = _e_4688;
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
    logic[42:0] _e_4709;
    (* src = "src/lsu.spade:84,14" *)
    logic[31:0] \x ;
    logic _e_9304;
    logic _e_9306;
    logic _e_9308;
    logic _e_9309;
    (* src = "src/lsu.spade:84,36" *)
    logic[32:0] _e_4711;
    (* src = "src/lsu.spade:85,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:86,13" *)
    logic[42:0] _e_4717;
    (* src = "src/lsu.spade:86,18" *)
    logic[31:0] x_n1;
    logic _e_9312;
    logic _e_9314;
    logic _e_9316;
    logic _e_9317;
    (* src = "src/lsu.spade:86,40" *)
    logic[32:0] _e_4719;
    (* src = "src/lsu.spade:87,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:87,18" *)
    logic[32:0] _e_4722;
    (* src = "src/lsu.spade:85,14" *)
    logic[32:0] _e_4714;
    (* src = "src/lsu.spade:83,5" *)
    logic[32:0] _e_4706;
    assign _e_4709 = \m1 [42:0];
    assign \x  = _e_4709[36:5];
    assign _e_9304 = \m1 [43] == 1'd1;
    assign _e_9306 = _e_4709[42:37] == 6'd7;
    localparam[0:0] _e_9307 = 1;
    assign _e_9308 = _e_9306 && _e_9307;
    assign _e_9309 = _e_9304 && _e_9308;
    assign _e_4711 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9310 = 1;
    assign _e_4717 = \m0 [42:0];
    assign x_n1 = _e_4717[36:5];
    assign _e_9312 = \m0 [43] == 1'd1;
    assign _e_9314 = _e_4717[42:37] == 6'd7;
    localparam[0:0] _e_9315 = 1;
    assign _e_9316 = _e_9314 && _e_9315;
    assign _e_9317 = _e_9312 && _e_9316;
    assign _e_4719 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9318 = 1;
    assign _e_4722 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9317, _e_9318})
            2'b1?: _e_4714 = _e_4719;
            2'b01: _e_4714 = _e_4722;
            2'b?: _e_4714 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9309, _e_9310})
            2'b1?: _e_4706 = _e_4711;
            2'b01: _e_4706 = _e_4714;
            2'b?: _e_4706 = 33'dx;
        endcase
    end
    assign output__ = _e_4706;
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
    logic[42:0] _e_4727;
    (* src = "src/lsu.spade:94,14" *)
    logic[31:0] \x ;
    logic _e_9320;
    logic _e_9322;
    logic _e_9324;
    logic _e_9325;
    (* src = "src/lsu.spade:94,41" *)
    logic[32:0] _e_4729;
    (* src = "src/lsu.spade:95,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:96,13" *)
    logic[42:0] _e_4735;
    (* src = "src/lsu.spade:96,18" *)
    logic[31:0] x_n1;
    logic _e_9328;
    logic _e_9330;
    logic _e_9332;
    logic _e_9333;
    (* src = "src/lsu.spade:96,45" *)
    logic[32:0] _e_4737;
    (* src = "src/lsu.spade:97,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:97,18" *)
    logic[32:0] _e_4740;
    (* src = "src/lsu.spade:95,14" *)
    logic[32:0] _e_4732;
    (* src = "src/lsu.spade:93,5" *)
    logic[32:0] _e_4724;
    assign _e_4727 = \m1 [42:0];
    assign \x  = _e_4727[36:5];
    assign _e_9320 = \m1 [43] == 1'd1;
    assign _e_9322 = _e_4727[42:37] == 6'd8;
    localparam[0:0] _e_9323 = 1;
    assign _e_9324 = _e_9322 && _e_9323;
    assign _e_9325 = _e_9320 && _e_9324;
    assign _e_4729 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9326 = 1;
    assign _e_4735 = \m0 [42:0];
    assign x_n1 = _e_4735[36:5];
    assign _e_9328 = \m0 [43] == 1'd1;
    assign _e_9330 = _e_4735[42:37] == 6'd8;
    localparam[0:0] _e_9331 = 1;
    assign _e_9332 = _e_9330 && _e_9331;
    assign _e_9333 = _e_9328 && _e_9332;
    assign _e_4737 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9334 = 1;
    assign _e_4740 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9333, _e_9334})
            2'b1?: _e_4732 = _e_4737;
            2'b01: _e_4732 = _e_4740;
            2'b?: _e_4732 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9325, _e_9326})
            2'b1?: _e_4724 = _e_4729;
            2'b01: _e_4724 = _e_4732;
            2'b?: _e_4724 = 33'dx;
        endcase
    end
    assign output__ = _e_4724;
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
    logic[42:0] _e_4745;
    (* src = "src/lsu.spade:104,14" *)
    logic[31:0] \x ;
    logic _e_9336;
    logic _e_9338;
    logic _e_9340;
    logic _e_9341;
    (* src = "src/lsu.spade:104,42" *)
    logic[32:0] _e_4747;
    (* src = "src/lsu.spade:105,9" *)
    logic[43:0] \_ ;
    (* src = "src/lsu.spade:106,13" *)
    logic[42:0] _e_4753;
    (* src = "src/lsu.spade:106,18" *)
    logic[31:0] x_n1;
    logic _e_9344;
    logic _e_9346;
    logic _e_9348;
    logic _e_9349;
    (* src = "src/lsu.spade:106,46" *)
    logic[32:0] _e_4755;
    (* src = "src/lsu.spade:107,13" *)
    logic[43:0] __n1;
    (* src = "src/lsu.spade:107,18" *)
    logic[32:0] _e_4758;
    (* src = "src/lsu.spade:105,14" *)
    logic[32:0] _e_4750;
    (* src = "src/lsu.spade:103,5" *)
    logic[32:0] _e_4742;
    assign _e_4745 = \m1 [42:0];
    assign \x  = _e_4745[36:5];
    assign _e_9336 = \m1 [43] == 1'd1;
    assign _e_9338 = _e_4745[42:37] == 6'd9;
    localparam[0:0] _e_9339 = 1;
    assign _e_9340 = _e_9338 && _e_9339;
    assign _e_9341 = _e_9336 && _e_9340;
    assign _e_4747 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9342 = 1;
    assign _e_4753 = \m0 [42:0];
    assign x_n1 = _e_4753[36:5];
    assign _e_9344 = \m0 [43] == 1'd1;
    assign _e_9346 = _e_4753[42:37] == 6'd9;
    localparam[0:0] _e_9347 = 1;
    assign _e_9348 = _e_9346 && _e_9347;
    assign _e_9349 = _e_9344 && _e_9348;
    assign _e_4755 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9350 = 1;
    assign _e_4758 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9349, _e_9350})
            2'b1?: _e_4750 = _e_4755;
            2'b01: _e_4750 = _e_4758;
            2'b?: _e_4750 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9341, _e_9342})
            2'b1?: _e_4742 = _e_4747;
            2'b01: _e_4742 = _e_4750;
            2'b?: _e_4742 = 33'dx;
        endcase
    end
    assign output__ = _e_4742;
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
    logic[8:0] _e_4783;
    (* src = "src/parallel_rx.spade:33,9" *)
    logic[8:0] _e_4787;
    (* src = "src/parallel_rx.spade:32,14" *)
    reg[8:0] \rx ;
    (* src = "src/parallel_rx.spade:38,24" *)
    logic _e_4792;
    (* src = "src/parallel_rx.spade:38,23" *)
    logic _e_4791;
    (* src = "src/parallel_rx.spade:38,23" *)
    logic \rising_edge ;
    (* src = "src/parallel_rx.spade:41,8" *)
    logic _e_4797;
    (* src = "src/parallel_rx.spade:42,14" *)
    logic[7:0] _e_4802;
    (* src = "src/parallel_rx.spade:42,9" *)
    logic[8:0] _e_4801;
    (* src = "src/parallel_rx.spade:44,9" *)
    logic[8:0] _e_4805;
    (* src = "src/parallel_rx.spade:41,5" *)
    logic[8:0] _e_4796;
    localparam[0:0] _e_4763 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \clk_pin_s1  <= _e_4763;
        end
        else begin
            \clk_pin_s1  <= \clk_pin ;
        end
    end
    localparam[0:0] _e_4768 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \clk_pin_s2  <= _e_4768;
        end
        else begin
            \clk_pin_s2  <= \clk_pin_s1 ;
        end
    end
    localparam[7:0] _e_4773 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \data_sync  <= _e_4773;
        end
        else begin
            \data_sync  <= \data_in ;
        end
    end
    localparam[0:0] _e_4778 = 0;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \strobe_sync  <= _e_4778;
        end
        else begin
            \strobe_sync  <= \strobe ;
        end
    end
    localparam[0:0] _e_4784 = 0;
    localparam[7:0] _e_4785 = 0;
    assign _e_4783 = {_e_4784, _e_4785};
    assign _e_4787 = {\clk_pin_s2 , \data_sync };
    always @(posedge \clk ) begin
        if (\rst ) begin
            \rx  <= _e_4783;
        end
        else begin
            \rx  <= _e_4787;
        end
    end
    assign _e_4792 = \rx [8];
    assign _e_4791 = !_e_4792;
    assign \rising_edge  = _e_4791 && \clk_pin_s2 ;
    assign _e_4797 = \rising_edge  && \strobe_sync ;
    assign _e_4802 = \rx [7:0];
    assign _e_4801 = {1'd1, _e_4802};
    assign _e_4805 = {1'd0, 8'bX};
    assign _e_4796 = _e_4797 ? _e_4801 : _e_4805;
    assign output__ = _e_4796;
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
    logic _e_9352;
    logic _e_9354;
    logic _e_9356;
    (* src = "src/sel.spade:20,45" *)
    logic _e_4811;
    (* src = "src/sel.spade:20,14" *)
    reg \cond ;
    (* src = "src/sel.spade:27,9" *)
    logic[31:0] \v ;
    logic _e_9358;
    logic _e_9360;
    logic _e_9362;
    (* src = "src/sel.spade:26,46" *)
    logic[31:0] _e_4822;
    (* src = "src/sel.spade:26,14" *)
    reg[31:0] \val_a ;
    (* src = "src/sel.spade:34,47" *)
    logic[32:0] _e_4832;
    (* src = "src/sel.spade:35,9" *)
    logic[31:0] \val_b ;
    logic _e_9364;
    logic _e_9366;
    (* src = "src/sel.spade:37,17" *)
    logic[32:0] _e_4841;
    (* src = "src/sel.spade:39,17" *)
    logic[32:0] _e_4844;
    (* src = "src/sel.spade:36,13" *)
    logic[32:0] _e_4838;
    logic _e_9368;
    (* src = "src/sel.spade:42,17" *)
    logic[32:0] _e_4847;
    (* src = "src/sel.spade:34,55" *)
    logic[32:0] _e_4833;
    (* src = "src/sel.spade:34,14" *)
    reg[32:0] \res ;
    localparam[0:0] _e_4810 = 0;
    assign \c  = \set_cond [0:0];
    assign _e_9352 = \set_cond [1] == 1'd1;
    localparam[0:0] _e_9353 = 1;
    assign _e_9354 = _e_9352 && _e_9353;
    assign _e_9356 = \set_cond [1] == 1'd0;
    always_comb begin
        priority casez ({_e_9354, _e_9356})
            2'b1?: _e_4811 = \c ;
            2'b01: _e_4811 = \cond ;
            2'b?: _e_4811 = 1'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \cond  <= _e_4810;
        end
        else begin
            \cond  <= _e_4811;
        end
    end
    localparam[31:0] _e_4821 = 32'd0;
    assign \v  = \set_a [31:0];
    assign _e_9358 = \set_a [32] == 1'd1;
    localparam[0:0] _e_9359 = 1;
    assign _e_9360 = _e_9358 && _e_9359;
    assign _e_9362 = \set_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9360, _e_9362})
            2'b1?: _e_4822 = \v ;
            2'b01: _e_4822 = \val_a ;
            2'b?: _e_4822 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \val_a  <= _e_4821;
        end
        else begin
            \val_a  <= _e_4822;
        end
    end
    assign _e_4832 = {1'd0, 32'bX};
    assign \val_b  = \trig_b [31:0];
    assign _e_9364 = \trig_b [32] == 1'd1;
    localparam[0:0] _e_9365 = 1;
    assign _e_9366 = _e_9364 && _e_9365;
    assign _e_4841 = {1'd1, \val_a };
    assign _e_4844 = {1'd1, \val_b };
    assign _e_4838 = \cond  ? _e_4841 : _e_4844;
    assign _e_9368 = \trig_b [32] == 1'd0;
    assign _e_4847 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9366, _e_9368})
            2'b1?: _e_4833 = _e_4838;
            2'b01: _e_4833 = _e_4847;
            2'b?: _e_4833 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_4832;
        end
        else begin
            \res  <= _e_4833;
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
    logic[42:0] _e_4853;
    (* src = "src/sel.spade:50,14" *)
    logic \a ;
    logic _e_9370;
    logic _e_9372;
    logic _e_9374;
    logic _e_9375;
    (* src = "src/sel.spade:50,35" *)
    logic[1:0] _e_4855;
    (* src = "src/sel.spade:51,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:51,25" *)
    logic[42:0] _e_4861;
    (* src = "src/sel.spade:51,30" *)
    logic a_n1;
    logic _e_9378;
    logic _e_9380;
    logic _e_9382;
    logic _e_9383;
    (* src = "src/sel.spade:51,51" *)
    logic[1:0] _e_4863;
    (* src = "src/sel.spade:51,60" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:51,65" *)
    logic[1:0] _e_4866;
    (* src = "src/sel.spade:51,14" *)
    logic[1:0] _e_4858;
    (* src = "src/sel.spade:49,5" *)
    logic[1:0] _e_4850;
    assign _e_4853 = \m1 [42:0];
    assign \a  = _e_4853[36:36];
    assign _e_9370 = \m1 [43] == 1'd1;
    assign _e_9372 = _e_4853[42:37] == 6'd27;
    localparam[0:0] _e_9373 = 1;
    assign _e_9374 = _e_9372 && _e_9373;
    assign _e_9375 = _e_9370 && _e_9374;
    assign _e_4855 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9376 = 1;
    assign _e_4861 = \m0 [42:0];
    assign a_n1 = _e_4861[36:36];
    assign _e_9378 = \m0 [43] == 1'd1;
    assign _e_9380 = _e_4861[42:37] == 6'd27;
    localparam[0:0] _e_9381 = 1;
    assign _e_9382 = _e_9380 && _e_9381;
    assign _e_9383 = _e_9378 && _e_9382;
    assign _e_4863 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9384 = 1;
    assign _e_4866 = {1'd0, 1'bX};
    always_comb begin
        priority casez ({_e_9383, _e_9384})
            2'b1?: _e_4858 = _e_4863;
            2'b01: _e_4858 = _e_4866;
            2'b?: _e_4858 = 2'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9375, _e_9376})
            2'b1?: _e_4850 = _e_4855;
            2'b01: _e_4850 = _e_4858;
            2'b?: _e_4850 = 2'dx;
        endcase
    end
    assign output__ = _e_4850;
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
    logic[42:0] _e_4871;
    (* src = "src/sel.spade:57,14" *)
    logic[31:0] \a ;
    logic _e_9386;
    logic _e_9388;
    logic _e_9390;
    logic _e_9391;
    (* src = "src/sel.spade:57,35" *)
    logic[32:0] _e_4873;
    (* src = "src/sel.spade:58,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:58,25" *)
    logic[42:0] _e_4879;
    (* src = "src/sel.spade:58,30" *)
    logic[31:0] a_n1;
    logic _e_9394;
    logic _e_9396;
    logic _e_9398;
    logic _e_9399;
    (* src = "src/sel.spade:58,51" *)
    logic[32:0] _e_4881;
    (* src = "src/sel.spade:58,60" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:58,65" *)
    logic[32:0] _e_4884;
    (* src = "src/sel.spade:58,14" *)
    logic[32:0] _e_4876;
    (* src = "src/sel.spade:56,5" *)
    logic[32:0] _e_4868;
    assign _e_4871 = \m1 [42:0];
    assign \a  = _e_4871[36:5];
    assign _e_9386 = \m1 [43] == 1'd1;
    assign _e_9388 = _e_4871[42:37] == 6'd28;
    localparam[0:0] _e_9389 = 1;
    assign _e_9390 = _e_9388 && _e_9389;
    assign _e_9391 = _e_9386 && _e_9390;
    assign _e_4873 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9392 = 1;
    assign _e_4879 = \m0 [42:0];
    assign a_n1 = _e_4879[36:5];
    assign _e_9394 = \m0 [43] == 1'd1;
    assign _e_9396 = _e_4879[42:37] == 6'd28;
    localparam[0:0] _e_9397 = 1;
    assign _e_9398 = _e_9396 && _e_9397;
    assign _e_9399 = _e_9394 && _e_9398;
    assign _e_4881 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9400 = 1;
    assign _e_4884 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9399, _e_9400})
            2'b1?: _e_4876 = _e_4881;
            2'b01: _e_4876 = _e_4884;
            2'b?: _e_4876 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9391, _e_9392})
            2'b1?: _e_4868 = _e_4873;
            2'b01: _e_4868 = _e_4876;
            2'b?: _e_4868 = 33'dx;
        endcase
    end
    assign output__ = _e_4868;
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
    logic[42:0] _e_4889;
    (* src = "src/sel.spade:64,14" *)
    logic[31:0] \a ;
    logic _e_9402;
    logic _e_9404;
    logic _e_9406;
    logic _e_9407;
    (* src = "src/sel.spade:64,36" *)
    logic[32:0] _e_4891;
    (* src = "src/sel.spade:65,9" *)
    logic[43:0] \_ ;
    (* src = "src/sel.spade:65,25" *)
    logic[42:0] _e_4897;
    (* src = "src/sel.spade:65,30" *)
    logic[31:0] a_n1;
    logic _e_9410;
    logic _e_9412;
    logic _e_9414;
    logic _e_9415;
    (* src = "src/sel.spade:65,52" *)
    logic[32:0] _e_4899;
    (* src = "src/sel.spade:65,61" *)
    logic[43:0] __n1;
    (* src = "src/sel.spade:65,66" *)
    logic[32:0] _e_4902;
    (* src = "src/sel.spade:65,14" *)
    logic[32:0] _e_4894;
    (* src = "src/sel.spade:63,5" *)
    logic[32:0] _e_4886;
    assign _e_4889 = \m1 [42:0];
    assign \a  = _e_4889[36:5];
    assign _e_9402 = \m1 [43] == 1'd1;
    assign _e_9404 = _e_4889[42:37] == 6'd29;
    localparam[0:0] _e_9405 = 1;
    assign _e_9406 = _e_9404 && _e_9405;
    assign _e_9407 = _e_9402 && _e_9406;
    assign _e_4891 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9408 = 1;
    assign _e_4897 = \m0 [42:0];
    assign a_n1 = _e_4897[36:5];
    assign _e_9410 = \m0 [43] == 1'd1;
    assign _e_9412 = _e_4897[42:37] == 6'd29;
    localparam[0:0] _e_9413 = 1;
    assign _e_9414 = _e_9412 && _e_9413;
    assign _e_9415 = _e_9410 && _e_9414;
    assign _e_4899 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9416 = 1;
    assign _e_4902 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9415, _e_9416})
            2'b1?: _e_4894 = _e_4899;
            2'b01: _e_4894 = _e_4902;
            2'b?: _e_4894 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9407, _e_9408})
            2'b1?: _e_4886 = _e_4891;
            2'b01: _e_4886 = _e_4894;
            2'b?: _e_4886 = 33'dx;
        endcase
    end
    assign output__ = _e_4886;
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
    logic[4:0] _e_4905;
    (* src = "src/bootloader.spade:64,5" *)
    logic[120:0] _e_4904;
    assign _e_4905 = {5'd0};
    localparam[15:0] _e_4906 = 0;
    localparam[15:0] _e_4907 = 0;
    localparam[9:0] _e_4908 = 0;
    localparam[9:0] _e_4909 = 0;
    localparam[31:0] _e_4910 = 32'd0;
    localparam[31:0] _e_4911 = 32'd0;
    assign _e_4904 = {_e_4905, _e_4906, _e_4907, _e_4908, _e_4909, _e_4910, _e_4911};
    assign output__ = _e_4904;
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
    logic[120:0] _e_4916;
    (* src = "src/bootloader.spade:75,28" *)
    logic[4:0] _e_4921;
    (* src = "src/bootloader.spade:75,15" *)
    logic[5:0] _e_4919;
    (* src = "src/bootloader.spade:76,13" *)
    logic[5:0] _e_4925;
    (* src = "src/bootloader.spade:76,13" *)
    logic _e_4923;
    (* src = "src/bootloader.spade:76,13" *)
    logic[4:0] _e_4924;
    logic _e_9420;
    logic _e_9421;
    (* src = "src/bootloader.spade:76,37" *)
    logic _e_4927;
    (* src = "src/bootloader.spade:77,27" *)
    logic[4:0] _e_4932;
    (* src = "src/bootloader.spade:77,38" *)
    logic[15:0] _e_4933;
    (* src = "src/bootloader.spade:77,46" *)
    logic[15:0] _e_4935;
    (* src = "src/bootloader.spade:77,56" *)
    logic[9:0] _e_4937;
    (* src = "src/bootloader.spade:77,66" *)
    logic[9:0] _e_4939;
    (* src = "src/bootloader.spade:77,74" *)
    logic[31:0] _e_4941;
    (* src = "src/bootloader.spade:77,81" *)
    logic[31:0] _e_4943;
    (* src = "src/bootloader.spade:77,21" *)
    logic[120:0] _e_4931;
    (* src = "src/bootloader.spade:79,21" *)
    logic[120:0] _e_4946;
    (* src = "src/bootloader.spade:76,34" *)
    logic[120:0] _e_4926;
    (* src = "src/bootloader.spade:81,13" *)
    logic[5:0] _e_4949;
    (* src = "src/bootloader.spade:81,13" *)
    logic _e_4947;
    (* src = "src/bootloader.spade:81,13" *)
    logic[4:0] _e_4948;
    logic _e_9425;
    logic _e_9426;
    (* src = "src/bootloader.spade:81,37" *)
    logic _e_4951;
    (* src = "src/bootloader.spade:82,27" *)
    logic[4:0] _e_4956;
    (* src = "src/bootloader.spade:82,37" *)
    logic[15:0] _e_4957;
    (* src = "src/bootloader.spade:82,45" *)
    logic[15:0] _e_4959;
    (* src = "src/bootloader.spade:82,55" *)
    logic[9:0] _e_4961;
    (* src = "src/bootloader.spade:82,65" *)
    logic[9:0] _e_4963;
    (* src = "src/bootloader.spade:82,73" *)
    logic[31:0] _e_4965;
    (* src = "src/bootloader.spade:82,80" *)
    logic[31:0] _e_4967;
    (* src = "src/bootloader.spade:82,21" *)
    logic[120:0] _e_4955;
    (* src = "src/bootloader.spade:84,21" *)
    logic[120:0] _e_4970;
    (* src = "src/bootloader.spade:81,34" *)
    logic[120:0] _e_4950;
    (* src = "src/bootloader.spade:86,13" *)
    logic[5:0] _e_4973;
    (* src = "src/bootloader.spade:86,13" *)
    logic _e_4971;
    (* src = "src/bootloader.spade:86,13" *)
    logic[4:0] _e_4972;
    logic _e_9430;
    logic _e_9431;
    (* src = "src/bootloader.spade:86,39" *)
    logic[4:0] _e_4975;
    logic[15:0] _e_4976;
    (* src = "src/bootloader.spade:86,61" *)
    logic[15:0] _e_4978;
    (* src = "src/bootloader.spade:86,71" *)
    logic[9:0] _e_4980;
    (* src = "src/bootloader.spade:86,81" *)
    logic[9:0] _e_4982;
    (* src = "src/bootloader.spade:86,89" *)
    logic[31:0] _e_4984;
    (* src = "src/bootloader.spade:86,96" *)
    logic[31:0] _e_4986;
    (* src = "src/bootloader.spade:86,33" *)
    logic[120:0] _e_4974;
    (* src = "src/bootloader.spade:87,13" *)
    logic[5:0] _e_4990;
    (* src = "src/bootloader.spade:87,13" *)
    logic _e_4988;
    (* src = "src/bootloader.spade:87,13" *)
    logic[4:0] _e_4989;
    logic _e_9435;
    logic _e_9436;
    logic[15:0] _e_4994;
    (* src = "src/bootloader.spade:88,29" *)
    logic[15:0] _e_4993;
    (* src = "src/bootloader.spade:88,49" *)
    logic[15:0] _e_4997;
    (* src = "src/bootloader.spade:88,29" *)
    logic[15:0] \v ;
    (* src = "src/bootloader.spade:89,24" *)
    logic _e_5001;
    (* src = "src/bootloader.spade:90,31" *)
    logic[4:0] _e_5006;
    (* src = "src/bootloader.spade:90,39" *)
    logic[15:0] _e_5007;
    (* src = "src/bootloader.spade:90,49" *)
    logic[15:0] _e_5009;
    (* src = "src/bootloader.spade:90,59" *)
    logic[9:0] _e_5011;
    (* src = "src/bootloader.spade:90,69" *)
    logic[9:0] _e_5013;
    (* src = "src/bootloader.spade:90,77" *)
    logic[31:0] _e_5015;
    (* src = "src/bootloader.spade:90,84" *)
    logic[31:0] _e_5017;
    (* src = "src/bootloader.spade:90,25" *)
    logic[120:0] _e_5005;
    (* src = "src/bootloader.spade:92,25" *)
    logic[120:0] _e_5020;
    (* src = "src/bootloader.spade:89,21" *)
    logic[120:0] _e_5000;
    (* src = "src/bootloader.spade:95,13" *)
    logic[5:0] _e_5023;
    (* src = "src/bootloader.spade:95,13" *)
    logic _e_5021;
    (* src = "src/bootloader.spade:95,13" *)
    logic[4:0] _e_5022;
    logic _e_9440;
    logic _e_9441;
    (* src = "src/bootloader.spade:95,37" *)
    logic[4:0] _e_5025;
    (* src = "src/bootloader.spade:95,45" *)
    logic[15:0] _e_5026;
    logic[15:0] _e_5028;
    (* src = "src/bootloader.spade:95,65" *)
    logic[9:0] _e_5030;
    (* src = "src/bootloader.spade:95,75" *)
    logic[9:0] _e_5032;
    (* src = "src/bootloader.spade:95,83" *)
    logic[31:0] _e_5034;
    (* src = "src/bootloader.spade:95,90" *)
    logic[31:0] _e_5036;
    (* src = "src/bootloader.spade:95,31" *)
    logic[120:0] _e_5024;
    (* src = "src/bootloader.spade:96,13" *)
    logic[5:0] _e_5040;
    (* src = "src/bootloader.spade:96,13" *)
    logic _e_5038;
    (* src = "src/bootloader.spade:96,13" *)
    logic[4:0] _e_5039;
    logic _e_9445;
    logic _e_9446;
    logic[15:0] _e_5044;
    (* src = "src/bootloader.spade:97,29" *)
    logic[15:0] _e_5043;
    (* src = "src/bootloader.spade:97,49" *)
    logic[15:0] _e_5047;
    (* src = "src/bootloader.spade:97,29" *)
    logic[15:0] \n ;
    (* src = "src/bootloader.spade:98,40" *)
    logic _e_5051;
    (* src = "src/bootloader.spade:98,37" *)
    logic[15:0] \n_clamped ;
    (* src = "src/bootloader.spade:99,27" *)
    logic[4:0] _e_5060;
    (* src = "src/bootloader.spade:99,35" *)
    logic[15:0] _e_5061;
    (* src = "src/bootloader.spade:99,43" *)
    logic[15:0] _e_5063;
    (* src = "src/bootloader.spade:99,61" *)
    logic[9:0] _e_5065;
    (* src = "src/bootloader.spade:99,71" *)
    logic[9:0] _e_5067;
    (* src = "src/bootloader.spade:99,79" *)
    logic[31:0] _e_5069;
    (* src = "src/bootloader.spade:99,86" *)
    logic[31:0] _e_5071;
    (* src = "src/bootloader.spade:99,21" *)
    logic[120:0] _e_5059;
    (* src = "src/bootloader.spade:101,13" *)
    logic[5:0] _e_5075;
    (* src = "src/bootloader.spade:101,13" *)
    logic _e_5073;
    (* src = "src/bootloader.spade:101,13" *)
    logic[4:0] _e_5074;
    logic _e_9450;
    logic _e_9451;
    (* src = "src/bootloader.spade:101,37" *)
    logic[4:0] _e_5077;
    (* src = "src/bootloader.spade:101,45" *)
    logic[15:0] _e_5078;
    (* src = "src/bootloader.spade:101,53" *)
    logic[15:0] _e_5080;
    logic[9:0] _e_5082;
    (* src = "src/bootloader.spade:101,75" *)
    logic[9:0] _e_5084;
    (* src = "src/bootloader.spade:101,83" *)
    logic[31:0] _e_5086;
    (* src = "src/bootloader.spade:101,90" *)
    logic[31:0] _e_5088;
    (* src = "src/bootloader.spade:101,31" *)
    logic[120:0] _e_5076;
    (* src = "src/bootloader.spade:102,13" *)
    logic[5:0] _e_5092;
    (* src = "src/bootloader.spade:102,13" *)
    logic _e_5090;
    (* src = "src/bootloader.spade:102,13" *)
    logic[4:0] _e_5091;
    logic _e_9455;
    logic _e_9456;
    logic[9:0] _e_5096;
    (* src = "src/bootloader.spade:103,29" *)
    logic[9:0] _e_5095;
    (* src = "src/bootloader.spade:103,49" *)
    logic[9:0] _e_5099;
    (* src = "src/bootloader.spade:103,29" *)
    logic[9:0] \e ;
    (* src = "src/bootloader.spade:104,24" *)
    logic[15:0] _e_5104;
    (* src = "src/bootloader.spade:104,24" *)
    logic _e_5103;
    (* src = "src/bootloader.spade:105,31" *)
    logic[4:0] _e_5109;
    (* src = "src/bootloader.spade:105,41" *)
    logic[15:0] _e_5110;
    (* src = "src/bootloader.spade:105,49" *)
    logic[15:0] _e_5112;
    (* src = "src/bootloader.spade:105,59" *)
    logic[9:0] _e_5114;
    (* src = "src/bootloader.spade:105,69" *)
    logic[9:0] _e_5116;
    (* src = "src/bootloader.spade:105,77" *)
    logic[31:0] _e_5118;
    (* src = "src/bootloader.spade:105,84" *)
    logic[31:0] _e_5120;
    (* src = "src/bootloader.spade:105,25" *)
    logic[120:0] _e_5108;
    (* src = "src/bootloader.spade:107,31" *)
    logic[4:0] _e_5124;
    (* src = "src/bootloader.spade:107,42" *)
    logic[15:0] _e_5125;
    (* src = "src/bootloader.spade:107,50" *)
    logic[15:0] _e_5127;
    (* src = "src/bootloader.spade:107,60" *)
    logic[9:0] _e_5129;
    (* src = "src/bootloader.spade:107,70" *)
    logic[9:0] _e_5131;
    (* src = "src/bootloader.spade:107,78" *)
    logic[31:0] _e_5133;
    (* src = "src/bootloader.spade:107,85" *)
    logic[31:0] _e_5135;
    (* src = "src/bootloader.spade:107,25" *)
    logic[120:0] _e_5123;
    (* src = "src/bootloader.spade:104,21" *)
    logic[120:0] _e_5102;
    (* src = "src/bootloader.spade:112,13" *)
    logic[5:0] _e_5139;
    (* src = "src/bootloader.spade:112,13" *)
    logic _e_5137;
    (* src = "src/bootloader.spade:112,13" *)
    logic[4:0] _e_5138;
    logic _e_9460;
    logic _e_9461;
    (* src = "src/bootloader.spade:112,40" *)
    logic[4:0] _e_5141;
    (* src = "src/bootloader.spade:112,51" *)
    logic[15:0] _e_5142;
    (* src = "src/bootloader.spade:112,59" *)
    logic[15:0] _e_5144;
    (* src = "src/bootloader.spade:112,69" *)
    logic[9:0] _e_5146;
    (* src = "src/bootloader.spade:112,79" *)
    logic[9:0] _e_5148;
    logic[31:0] _e_5152;
    (* src = "src/bootloader.spade:112,112" *)
    logic[31:0] _e_5155;
    (* src = "src/bootloader.spade:112,111" *)
    logic[31:0] _e_5154;
    (* src = "src/bootloader.spade:112,93" *)
    logic[31:0] _e_5151;
    (* src = "src/bootloader.spade:112,87" *)
    logic[31:0] _e_5150;
    (* src = "src/bootloader.spade:112,134" *)
    logic[31:0] _e_5158;
    (* src = "src/bootloader.spade:112,34" *)
    logic[120:0] _e_5140;
    (* src = "src/bootloader.spade:113,13" *)
    logic[5:0] _e_5162;
    (* src = "src/bootloader.spade:113,13" *)
    logic _e_5160;
    (* src = "src/bootloader.spade:113,13" *)
    logic[4:0] _e_5161;
    logic _e_9465;
    logic _e_9466;
    (* src = "src/bootloader.spade:113,40" *)
    logic[4:0] _e_5164;
    (* src = "src/bootloader.spade:113,51" *)
    logic[15:0] _e_5165;
    (* src = "src/bootloader.spade:113,59" *)
    logic[15:0] _e_5167;
    (* src = "src/bootloader.spade:113,69" *)
    logic[9:0] _e_5169;
    (* src = "src/bootloader.spade:113,79" *)
    logic[9:0] _e_5171;
    logic[31:0] _e_5176;
    (* src = "src/bootloader.spade:113,93" *)
    logic[31:0] _e_5175;
    (* src = "src/bootloader.spade:113,115" *)
    logic[31:0] _e_5180;
    (* src = "src/bootloader.spade:113,114" *)
    logic[31:0] _e_5179;
    (* src = "src/bootloader.spade:113,93" *)
    logic[31:0] _e_5174;
    (* src = "src/bootloader.spade:113,87" *)
    logic[31:0] _e_5173;
    (* src = "src/bootloader.spade:113,137" *)
    logic[31:0] _e_5183;
    (* src = "src/bootloader.spade:113,34" *)
    logic[120:0] _e_5163;
    (* src = "src/bootloader.spade:114,13" *)
    logic[5:0] _e_5187;
    (* src = "src/bootloader.spade:114,13" *)
    logic _e_5185;
    (* src = "src/bootloader.spade:114,13" *)
    logic[4:0] _e_5186;
    logic _e_9470;
    logic _e_9471;
    (* src = "src/bootloader.spade:114,40" *)
    logic[4:0] _e_5189;
    (* src = "src/bootloader.spade:114,51" *)
    logic[15:0] _e_5190;
    (* src = "src/bootloader.spade:114,59" *)
    logic[15:0] _e_5192;
    (* src = "src/bootloader.spade:114,69" *)
    logic[9:0] _e_5194;
    (* src = "src/bootloader.spade:114,79" *)
    logic[9:0] _e_5196;
    logic[31:0] _e_5201;
    (* src = "src/bootloader.spade:114,93" *)
    logic[31:0] _e_5200;
    (* src = "src/bootloader.spade:114,115" *)
    logic[31:0] _e_5205;
    (* src = "src/bootloader.spade:114,114" *)
    logic[31:0] _e_5204;
    (* src = "src/bootloader.spade:114,93" *)
    logic[31:0] _e_5199;
    (* src = "src/bootloader.spade:114,87" *)
    logic[31:0] _e_5198;
    (* src = "src/bootloader.spade:114,137" *)
    logic[31:0] _e_5208;
    (* src = "src/bootloader.spade:114,34" *)
    logic[120:0] _e_5188;
    (* src = "src/bootloader.spade:115,13" *)
    logic[5:0] _e_5212;
    (* src = "src/bootloader.spade:115,13" *)
    logic _e_5210;
    (* src = "src/bootloader.spade:115,13" *)
    logic[4:0] _e_5211;
    logic _e_9475;
    logic _e_9476;
    (* src = "src/bootloader.spade:115,40" *)
    logic[4:0] _e_5214;
    (* src = "src/bootloader.spade:115,51" *)
    logic[15:0] _e_5215;
    (* src = "src/bootloader.spade:115,59" *)
    logic[15:0] _e_5217;
    (* src = "src/bootloader.spade:115,69" *)
    logic[9:0] _e_5219;
    (* src = "src/bootloader.spade:115,79" *)
    logic[9:0] _e_5221;
    logic[31:0] _e_5226;
    (* src = "src/bootloader.spade:115,93" *)
    logic[31:0] _e_5225;
    (* src = "src/bootloader.spade:115,115" *)
    logic[31:0] _e_5230;
    (* src = "src/bootloader.spade:115,114" *)
    logic[31:0] _e_5229;
    (* src = "src/bootloader.spade:115,93" *)
    logic[31:0] _e_5224;
    (* src = "src/bootloader.spade:115,87" *)
    logic[31:0] _e_5223;
    (* src = "src/bootloader.spade:115,137" *)
    logic[31:0] _e_5233;
    (* src = "src/bootloader.spade:115,34" *)
    logic[120:0] _e_5213;
    (* src = "src/bootloader.spade:118,13" *)
    logic[5:0] _e_5237;
    (* src = "src/bootloader.spade:118,13" *)
    logic _e_5235;
    (* src = "src/bootloader.spade:118,13" *)
    logic[4:0] _e_5236;
    logic _e_9480;
    logic _e_9481;
    (* src = "src/bootloader.spade:118,40" *)
    logic[4:0] _e_5239;
    (* src = "src/bootloader.spade:118,51" *)
    logic[15:0] _e_5240;
    (* src = "src/bootloader.spade:118,59" *)
    logic[15:0] _e_5242;
    (* src = "src/bootloader.spade:118,69" *)
    logic[9:0] _e_5244;
    (* src = "src/bootloader.spade:118,79" *)
    logic[9:0] _e_5246;
    (* src = "src/bootloader.spade:118,87" *)
    logic[31:0] _e_5248;
    logic[31:0] _e_5252;
    (* src = "src/bootloader.spade:118,119" *)
    logic[31:0] _e_5255;
    (* src = "src/bootloader.spade:118,118" *)
    logic[31:0] _e_5254;
    (* src = "src/bootloader.spade:118,100" *)
    logic[31:0] _e_5251;
    (* src = "src/bootloader.spade:118,94" *)
    logic[31:0] _e_5250;
    (* src = "src/bootloader.spade:118,34" *)
    logic[120:0] _e_5238;
    (* src = "src/bootloader.spade:119,13" *)
    logic[5:0] _e_5260;
    (* src = "src/bootloader.spade:119,13" *)
    logic _e_5258;
    (* src = "src/bootloader.spade:119,13" *)
    logic[4:0] _e_5259;
    logic _e_9485;
    logic _e_9486;
    (* src = "src/bootloader.spade:119,40" *)
    logic[4:0] _e_5262;
    (* src = "src/bootloader.spade:119,51" *)
    logic[15:0] _e_5263;
    (* src = "src/bootloader.spade:119,59" *)
    logic[15:0] _e_5265;
    (* src = "src/bootloader.spade:119,69" *)
    logic[9:0] _e_5267;
    (* src = "src/bootloader.spade:119,79" *)
    logic[9:0] _e_5269;
    (* src = "src/bootloader.spade:119,87" *)
    logic[31:0] _e_5271;
    logic[31:0] _e_5276;
    (* src = "src/bootloader.spade:119,100" *)
    logic[31:0] _e_5275;
    (* src = "src/bootloader.spade:119,122" *)
    logic[31:0] _e_5280;
    (* src = "src/bootloader.spade:119,121" *)
    logic[31:0] _e_5279;
    (* src = "src/bootloader.spade:119,100" *)
    logic[31:0] _e_5274;
    (* src = "src/bootloader.spade:119,94" *)
    logic[31:0] _e_5273;
    (* src = "src/bootloader.spade:119,34" *)
    logic[120:0] _e_5261;
    (* src = "src/bootloader.spade:120,13" *)
    logic[5:0] _e_5285;
    (* src = "src/bootloader.spade:120,13" *)
    logic _e_5283;
    (* src = "src/bootloader.spade:120,13" *)
    logic[4:0] _e_5284;
    logic _e_9490;
    logic _e_9491;
    (* src = "src/bootloader.spade:120,40" *)
    logic[4:0] _e_5287;
    (* src = "src/bootloader.spade:120,51" *)
    logic[15:0] _e_5288;
    (* src = "src/bootloader.spade:120,59" *)
    logic[15:0] _e_5290;
    (* src = "src/bootloader.spade:120,69" *)
    logic[9:0] _e_5292;
    (* src = "src/bootloader.spade:120,79" *)
    logic[9:0] _e_5294;
    (* src = "src/bootloader.spade:120,87" *)
    logic[31:0] _e_5296;
    logic[31:0] _e_5301;
    (* src = "src/bootloader.spade:120,100" *)
    logic[31:0] _e_5300;
    (* src = "src/bootloader.spade:120,122" *)
    logic[31:0] _e_5305;
    (* src = "src/bootloader.spade:120,121" *)
    logic[31:0] _e_5304;
    (* src = "src/bootloader.spade:120,100" *)
    logic[31:0] _e_5299;
    (* src = "src/bootloader.spade:120,94" *)
    logic[31:0] _e_5298;
    (* src = "src/bootloader.spade:120,34" *)
    logic[120:0] _e_5286;
    (* src = "src/bootloader.spade:121,13" *)
    logic[5:0] _e_5310;
    (* src = "src/bootloader.spade:121,13" *)
    logic _e_5308;
    (* src = "src/bootloader.spade:121,13" *)
    logic[4:0] _e_5309;
    logic _e_9495;
    logic _e_9496;
    (* src = "src/bootloader.spade:121,40" *)
    logic[4:0] _e_5312;
    (* src = "src/bootloader.spade:121,52" *)
    logic[15:0] _e_5313;
    (* src = "src/bootloader.spade:121,60" *)
    logic[15:0] _e_5315;
    (* src = "src/bootloader.spade:121,70" *)
    logic[9:0] _e_5317;
    (* src = "src/bootloader.spade:121,80" *)
    logic[9:0] _e_5319;
    (* src = "src/bootloader.spade:121,88" *)
    logic[31:0] _e_5321;
    logic[31:0] _e_5326;
    (* src = "src/bootloader.spade:121,101" *)
    logic[31:0] _e_5325;
    (* src = "src/bootloader.spade:121,123" *)
    logic[31:0] _e_5330;
    (* src = "src/bootloader.spade:121,122" *)
    logic[31:0] _e_5329;
    (* src = "src/bootloader.spade:121,101" *)
    logic[31:0] _e_5324;
    (* src = "src/bootloader.spade:121,95" *)
    logic[31:0] _e_5323;
    (* src = "src/bootloader.spade:121,34" *)
    logic[120:0] _e_5311;
    (* src = "src/bootloader.spade:125,13" *)
    logic[5:0] _e_5335;
    (* src = "src/bootloader.spade:125,13" *)
    logic \_ ;
    (* src = "src/bootloader.spade:125,13" *)
    logic[4:0] _e_5334;
    logic _e_9500;
    logic _e_9501;
    (* src = "src/bootloader.spade:126,34" *)
    logic[9:0] _e_5339;
    (* src = "src/bootloader.spade:126,34" *)
    logic[10:0] _e_5338;
    (* src = "src/bootloader.spade:126,28" *)
    logic[9:0] \pcw1 ;
    (* src = "src/bootloader.spade:127,34" *)
    logic[15:0] _e_5345;
    (* src = "src/bootloader.spade:127,34" *)
    logic[16:0] _e_5344;
    (* src = "src/bootloader.spade:127,28" *)
    logic[15:0] \n1 ;
    (* src = "src/bootloader.spade:128,31" *)
    logic _e_5350;
    (* src = "src/bootloader.spade:129,21" *)
    logic[4:0] _e_5354;
    (* src = "src/bootloader.spade:131,21" *)
    logic[4:0] _e_5356;
    (* src = "src/bootloader.spade:128,28" *)
    logic[4:0] \next ;
    (* src = "src/bootloader.spade:133,29" *)
    logic[15:0] _e_5360;
    (* src = "src/bootloader.spade:133,41" *)
    logic[9:0] _e_5363;
    (* src = "src/bootloader.spade:133,57" *)
    logic[31:0] _e_5366;
    (* src = "src/bootloader.spade:133,64" *)
    logic[31:0] _e_5368;
    (* src = "src/bootloader.spade:133,17" *)
    logic[120:0] _e_5358;
    (* src = "src/bootloader.spade:137,13" *)
    logic[5:0] _e_5372;
    (* src = "src/bootloader.spade:137,13" *)
    logic __n1;
    (* src = "src/bootloader.spade:137,13" *)
    logic[4:0] _e_5371;
    logic _e_9505;
    logic _e_9506;
    (* src = "src/bootloader.spade:140,13" *)
    logic[5:0] _e_5376;
    (* src = "src/bootloader.spade:140,13" *)
    logic _e_5374;
    (* src = "src/bootloader.spade:140,13" *)
    logic[4:0] __n2;
    logic _e_9508;
    logic _e_9510;
    (* src = "src/bootloader.spade:75,9" *)
    logic[120:0] _e_4918;
    (* src = "src/bootloader.spade:74,14" *)
    reg[120:0] \st ;
    (* src = "src/bootloader.spade:144,47" *)
    logic[4:0] _e_5379;
    (* src = "src/bootloader.spade:145,9" *)
    logic[4:0] _e_5381;
    logic _e_9512;
    (* src = "src/bootloader.spade:145,29" *)
    logic[9:0] _e_5384;
    (* src = "src/bootloader.spade:145,24" *)
    logic[10:0] _e_5383;
    (* src = "src/bootloader.spade:145,43" *)
    logic[31:0] _e_5387;
    (* src = "src/bootloader.spade:145,38" *)
    logic[32:0] _e_5386;
    (* src = "src/bootloader.spade:145,56" *)
    logic[31:0] _e_5390;
    (* src = "src/bootloader.spade:145,51" *)
    logic[32:0] _e_5389;
    (* src = "src/bootloader.spade:145,23" *)
    logic[76:0] _e_5382;
    (* src = "src/bootloader.spade:146,9" *)
    logic[4:0] __n3;
    (* src = "src/bootloader.spade:146,15" *)
    logic[10:0] _e_5394;
    (* src = "src/bootloader.spade:146,21" *)
    logic[32:0] _e_5395;
    (* src = "src/bootloader.spade:146,27" *)
    logic[32:0] _e_5396;
    (* src = "src/bootloader.spade:146,14" *)
    logic[76:0] _e_5393;
    (* src = "src/bootloader.spade:144,41" *)
    logic[76:0] _e_5400;
    (* src = "src/bootloader.spade:144,9" *)
    logic[10:0] \wr_addr ;
    (* src = "src/bootloader.spade:144,9" *)
    logic[32:0] \wr_slot0 ;
    (* src = "src/bootloader.spade:144,9" *)
    logic[32:0] \wr_slot1 ;
    (* src = "src/bootloader.spade:149,43" *)
    logic[4:0] _e_5402;
    (* src = "src/bootloader.spade:150,9" *)
    logic[4:0] _e_5404;
    logic _e_9515;
    (* src = "src/bootloader.spade:150,34" *)
    logic[9:0] _e_5408;
    (* src = "src/bootloader.spade:150,29" *)
    logic[10:0] _e_5407;
    (* src = "src/bootloader.spade:150,21" *)
    logic[11:0] _e_5405;
    (* src = "src/bootloader.spade:151,9" *)
    logic[4:0] __n4;
    (* src = "src/bootloader.spade:151,21" *)
    logic[10:0] _e_5413;
    (* src = "src/bootloader.spade:151,14" *)
    logic[11:0] _e_5411;
    (* src = "src/bootloader.spade:149,37" *)
    logic[11:0] _e_5416;
    (* src = "src/bootloader.spade:149,9" *)
    logic \boot_active ;
    (* src = "src/bootloader.spade:149,9" *)
    logic[10:0] \release_pc ;
    (* src = "src/bootloader.spade:154,5" *)
    logic[88:0] _e_5417;
    (* src = "src/bootloader.spade:74,35" *)
    \tta::bootloader::reset_state  reset_state_0(.output__(_e_4916));
    assign _e_4921 = \st [120:116];
    assign _e_4919 = {\byte_valid , _e_4921};
    assign _e_4925 = _e_4919;
    assign _e_4923 = _e_4919[5];
    assign _e_4924 = _e_4919[4:0];
    assign _e_9420 = _e_4924[4:0] == 5'd0;
    assign _e_9421 = _e_4923 && _e_9420;
    localparam[7:0] _e_4929 = 66;
    assign _e_4927 = \byte  == _e_4929;
    assign _e_4932 = {5'd1};
    assign _e_4933 = \st [115:100];
    assign _e_4935 = \st [99:84];
    assign _e_4937 = \st [83:74];
    assign _e_4939 = \st [73:64];
    assign _e_4941 = \st [63:32];
    assign _e_4943 = \st [31:0];
    assign _e_4931 = {_e_4932, _e_4933, _e_4935, _e_4937, _e_4939, _e_4941, _e_4943};
    (* src = "src/bootloader.spade:79,21" *)
    \tta::bootloader::reset_state  reset_state_1(.output__(_e_4946));
    assign _e_4926 = _e_4927 ? _e_4931 : _e_4946;
    assign _e_4949 = _e_4919;
    assign _e_4947 = _e_4919[5];
    assign _e_4948 = _e_4919[4:0];
    assign _e_9425 = _e_4948[4:0] == 5'd1;
    assign _e_9426 = _e_4947 && _e_9425;
    localparam[7:0] _e_4953 = 84;
    assign _e_4951 = \byte  == _e_4953;
    assign _e_4956 = {5'd2};
    assign _e_4957 = \st [115:100];
    assign _e_4959 = \st [99:84];
    assign _e_4961 = \st [83:74];
    assign _e_4963 = \st [73:64];
    assign _e_4965 = \st [63:32];
    assign _e_4967 = \st [31:0];
    assign _e_4955 = {_e_4956, _e_4957, _e_4959, _e_4961, _e_4963, _e_4965, _e_4967};
    (* src = "src/bootloader.spade:84,21" *)
    \tta::bootloader::reset_state  reset_state_2(.output__(_e_4970));
    assign _e_4950 = _e_4951 ? _e_4955 : _e_4970;
    assign _e_4973 = _e_4919;
    assign _e_4971 = _e_4919[5];
    assign _e_4972 = _e_4919[4:0];
    assign _e_9430 = _e_4972[4:0] == 5'd2;
    assign _e_9431 = _e_4971 && _e_9430;
    assign _e_4975 = {5'd3};
    assign _e_4976 = {8'b0, \byte };
    assign _e_4978 = \st [99:84];
    assign _e_4980 = \st [83:74];
    assign _e_4982 = \st [73:64];
    assign _e_4984 = \st [63:32];
    assign _e_4986 = \st [31:0];
    assign _e_4974 = {_e_4975, _e_4976, _e_4978, _e_4980, _e_4982, _e_4984, _e_4986};
    assign _e_4990 = _e_4919;
    assign _e_4988 = _e_4919[5];
    assign _e_4989 = _e_4919[4:0];
    assign _e_9435 = _e_4989[4:0] == 5'd3;
    assign _e_9436 = _e_4988 && _e_9435;
    assign _e_4994 = {8'b0, \byte };
    localparam[15:0] _e_4996 = 8;
    assign _e_4993 = _e_4994 << _e_4996;
    assign _e_4997 = \st [115:100];
    assign \v  = _e_4993 | _e_4997;
    localparam[15:0] _e_5003 = 1;
    assign _e_5001 = \v  == _e_5003;
    assign _e_5006 = {5'd4};
    assign _e_5007 = \v [15:0];
    assign _e_5009 = \st [99:84];
    assign _e_5011 = \st [83:74];
    assign _e_5013 = \st [73:64];
    assign _e_5015 = \st [63:32];
    assign _e_5017 = \st [31:0];
    assign _e_5005 = {_e_5006, _e_5007, _e_5009, _e_5011, _e_5013, _e_5015, _e_5017};
    (* src = "src/bootloader.spade:92,25" *)
    \tta::bootloader::reset_state  reset_state_3(.output__(_e_5020));
    assign _e_5000 = _e_5001 ? _e_5005 : _e_5020;
    assign _e_5023 = _e_4919;
    assign _e_5021 = _e_4919[5];
    assign _e_5022 = _e_4919[4:0];
    assign _e_9440 = _e_5022[4:0] == 5'd4;
    assign _e_9441 = _e_5021 && _e_9440;
    assign _e_5025 = {5'd5};
    assign _e_5026 = \st [115:100];
    assign _e_5028 = {8'b0, \byte };
    assign _e_5030 = \st [83:74];
    assign _e_5032 = \st [73:64];
    assign _e_5034 = \st [63:32];
    assign _e_5036 = \st [31:0];
    assign _e_5024 = {_e_5025, _e_5026, _e_5028, _e_5030, _e_5032, _e_5034, _e_5036};
    assign _e_5040 = _e_4919;
    assign _e_5038 = _e_4919[5];
    assign _e_5039 = _e_4919[4:0];
    assign _e_9445 = _e_5039[4:0] == 5'd5;
    assign _e_9446 = _e_5038 && _e_9445;
    assign _e_5044 = {8'b0, \byte };
    localparam[15:0] _e_5046 = 8;
    assign _e_5043 = _e_5044 << _e_5046;
    assign _e_5047 = \st [99:84];
    assign \n  = _e_5043 | _e_5047;
    localparam[15:0] _e_5053 = 512;
    assign _e_5051 = \n  > _e_5053;
    localparam[15:0] _e_5055 = 512;
    assign \n_clamped  = _e_5051 ? _e_5055 : \n ;
    assign _e_5060 = {5'd6};
    assign _e_5061 = \st [115:100];
    assign _e_5063 = \n_clamped [15:0];
    assign _e_5065 = \st [83:74];
    assign _e_5067 = \st [73:64];
    assign _e_5069 = \st [63:32];
    assign _e_5071 = \st [31:0];
    assign _e_5059 = {_e_5060, _e_5061, _e_5063, _e_5065, _e_5067, _e_5069, _e_5071};
    assign _e_5075 = _e_4919;
    assign _e_5073 = _e_4919[5];
    assign _e_5074 = _e_4919[4:0];
    assign _e_9450 = _e_5074[4:0] == 5'd6;
    assign _e_9451 = _e_5073 && _e_9450;
    assign _e_5077 = {5'd7};
    assign _e_5078 = \st [115:100];
    assign _e_5080 = \st [99:84];
    assign _e_5082 = {2'b0, \byte };
    assign _e_5084 = \st [73:64];
    assign _e_5086 = \st [63:32];
    assign _e_5088 = \st [31:0];
    assign _e_5076 = {_e_5077, _e_5078, _e_5080, _e_5082, _e_5084, _e_5086, _e_5088};
    assign _e_5092 = _e_4919;
    assign _e_5090 = _e_4919[5];
    assign _e_5091 = _e_4919[4:0];
    assign _e_9455 = _e_5091[4:0] == 5'd7;
    assign _e_9456 = _e_5090 && _e_9455;
    assign _e_5096 = {2'b0, \byte };
    localparam[9:0] _e_5098 = 8;
    assign _e_5095 = _e_5096 << _e_5098;
    assign _e_5099 = \st [83:74];
    assign \e  = _e_5095 | _e_5099;
    assign _e_5104 = \st [99:84];
    localparam[15:0] _e_5106 = 0;
    assign _e_5103 = _e_5104 == _e_5106;
    assign _e_5109 = {5'd17};
    assign _e_5110 = \st [115:100];
    assign _e_5112 = \st [99:84];
    assign _e_5114 = \e [9:0];
    assign _e_5116 = \st [73:64];
    assign _e_5118 = \st [63:32];
    assign _e_5120 = \st [31:0];
    assign _e_5108 = {_e_5109, _e_5110, _e_5112, _e_5114, _e_5116, _e_5118, _e_5120};
    assign _e_5124 = {5'd8};
    assign _e_5125 = \st [115:100];
    assign _e_5127 = \st [99:84];
    assign _e_5129 = \e [9:0];
    assign _e_5131 = \st [73:64];
    assign _e_5133 = \st [63:32];
    assign _e_5135 = \st [31:0];
    assign _e_5123 = {_e_5124, _e_5125, _e_5127, _e_5129, _e_5131, _e_5133, _e_5135};
    assign _e_5102 = _e_5103 ? _e_5108 : _e_5123;
    assign _e_5139 = _e_4919;
    assign _e_5137 = _e_4919[5];
    assign _e_5138 = _e_4919[4:0];
    assign _e_9460 = _e_5138[4:0] == 5'd8;
    assign _e_9461 = _e_5137 && _e_9460;
    assign _e_5141 = {5'd9};
    assign _e_5142 = \st [115:100];
    assign _e_5144 = \st [99:84];
    assign _e_5146 = \st [83:74];
    assign _e_5148 = \st [73:64];
    assign _e_5152 = {24'b0, \byte };
    assign _e_5155 = \st [63:32];
    localparam[31:0] _e_5157 = 32'd4294967040;
    assign _e_5154 = _e_5155 & _e_5157;
    assign _e_5151 = _e_5152 | _e_5154;
    assign _e_5150 = _e_5151[31:0];
    assign _e_5158 = \st [31:0];
    assign _e_5140 = {_e_5141, _e_5142, _e_5144, _e_5146, _e_5148, _e_5150, _e_5158};
    assign _e_5162 = _e_4919;
    assign _e_5160 = _e_4919[5];
    assign _e_5161 = _e_4919[4:0];
    assign _e_9465 = _e_5161[4:0] == 5'd9;
    assign _e_9466 = _e_5160 && _e_9465;
    assign _e_5164 = {5'd10};
    assign _e_5165 = \st [115:100];
    assign _e_5167 = \st [99:84];
    assign _e_5169 = \st [83:74];
    assign _e_5171 = \st [73:64];
    assign _e_5176 = {24'b0, \byte };
    localparam[31:0] _e_5178 = 32'd8;
    assign _e_5175 = _e_5176 << _e_5178;
    assign _e_5180 = \st [63:32];
    localparam[31:0] _e_5182 = 32'd4294902015;
    assign _e_5179 = _e_5180 & _e_5182;
    assign _e_5174 = _e_5175 | _e_5179;
    assign _e_5173 = _e_5174[31:0];
    assign _e_5183 = \st [31:0];
    assign _e_5163 = {_e_5164, _e_5165, _e_5167, _e_5169, _e_5171, _e_5173, _e_5183};
    assign _e_5187 = _e_4919;
    assign _e_5185 = _e_4919[5];
    assign _e_5186 = _e_4919[4:0];
    assign _e_9470 = _e_5186[4:0] == 5'd10;
    assign _e_9471 = _e_5185 && _e_9470;
    assign _e_5189 = {5'd11};
    assign _e_5190 = \st [115:100];
    assign _e_5192 = \st [99:84];
    assign _e_5194 = \st [83:74];
    assign _e_5196 = \st [73:64];
    assign _e_5201 = {24'b0, \byte };
    localparam[31:0] _e_5203 = 32'd16;
    assign _e_5200 = _e_5201 << _e_5203;
    assign _e_5205 = \st [63:32];
    localparam[31:0] _e_5207 = 32'd4278255615;
    assign _e_5204 = _e_5205 & _e_5207;
    assign _e_5199 = _e_5200 | _e_5204;
    assign _e_5198 = _e_5199[31:0];
    assign _e_5208 = \st [31:0];
    assign _e_5188 = {_e_5189, _e_5190, _e_5192, _e_5194, _e_5196, _e_5198, _e_5208};
    assign _e_5212 = _e_4919;
    assign _e_5210 = _e_4919[5];
    assign _e_5211 = _e_4919[4:0];
    assign _e_9475 = _e_5211[4:0] == 5'd11;
    assign _e_9476 = _e_5210 && _e_9475;
    assign _e_5214 = {5'd12};
    assign _e_5215 = \st [115:100];
    assign _e_5217 = \st [99:84];
    assign _e_5219 = \st [83:74];
    assign _e_5221 = \st [73:64];
    assign _e_5226 = {24'b0, \byte };
    localparam[31:0] _e_5228 = 32'd24;
    assign _e_5225 = _e_5226 << _e_5228;
    assign _e_5230 = \st [63:32];
    localparam[31:0] _e_5232 = 32'd16777215;
    assign _e_5229 = _e_5230 & _e_5232;
    assign _e_5224 = _e_5225 | _e_5229;
    assign _e_5223 = _e_5224[31:0];
    assign _e_5233 = \st [31:0];
    assign _e_5213 = {_e_5214, _e_5215, _e_5217, _e_5219, _e_5221, _e_5223, _e_5233};
    assign _e_5237 = _e_4919;
    assign _e_5235 = _e_4919[5];
    assign _e_5236 = _e_4919[4:0];
    assign _e_9480 = _e_5236[4:0] == 5'd12;
    assign _e_9481 = _e_5235 && _e_9480;
    assign _e_5239 = {5'd13};
    assign _e_5240 = \st [115:100];
    assign _e_5242 = \st [99:84];
    assign _e_5244 = \st [83:74];
    assign _e_5246 = \st [73:64];
    assign _e_5248 = \st [63:32];
    assign _e_5252 = {24'b0, \byte };
    assign _e_5255 = \st [31:0];
    localparam[31:0] _e_5257 = 32'd4294967040;
    assign _e_5254 = _e_5255 & _e_5257;
    assign _e_5251 = _e_5252 | _e_5254;
    assign _e_5250 = _e_5251[31:0];
    assign _e_5238 = {_e_5239, _e_5240, _e_5242, _e_5244, _e_5246, _e_5248, _e_5250};
    assign _e_5260 = _e_4919;
    assign _e_5258 = _e_4919[5];
    assign _e_5259 = _e_4919[4:0];
    assign _e_9485 = _e_5259[4:0] == 5'd13;
    assign _e_9486 = _e_5258 && _e_9485;
    assign _e_5262 = {5'd14};
    assign _e_5263 = \st [115:100];
    assign _e_5265 = \st [99:84];
    assign _e_5267 = \st [83:74];
    assign _e_5269 = \st [73:64];
    assign _e_5271 = \st [63:32];
    assign _e_5276 = {24'b0, \byte };
    localparam[31:0] _e_5278 = 32'd8;
    assign _e_5275 = _e_5276 << _e_5278;
    assign _e_5280 = \st [31:0];
    localparam[31:0] _e_5282 = 32'd4294902015;
    assign _e_5279 = _e_5280 & _e_5282;
    assign _e_5274 = _e_5275 | _e_5279;
    assign _e_5273 = _e_5274[31:0];
    assign _e_5261 = {_e_5262, _e_5263, _e_5265, _e_5267, _e_5269, _e_5271, _e_5273};
    assign _e_5285 = _e_4919;
    assign _e_5283 = _e_4919[5];
    assign _e_5284 = _e_4919[4:0];
    assign _e_9490 = _e_5284[4:0] == 5'd14;
    assign _e_9491 = _e_5283 && _e_9490;
    assign _e_5287 = {5'd15};
    assign _e_5288 = \st [115:100];
    assign _e_5290 = \st [99:84];
    assign _e_5292 = \st [83:74];
    assign _e_5294 = \st [73:64];
    assign _e_5296 = \st [63:32];
    assign _e_5301 = {24'b0, \byte };
    localparam[31:0] _e_5303 = 32'd16;
    assign _e_5300 = _e_5301 << _e_5303;
    assign _e_5305 = \st [31:0];
    localparam[31:0] _e_5307 = 32'd4278255615;
    assign _e_5304 = _e_5305 & _e_5307;
    assign _e_5299 = _e_5300 | _e_5304;
    assign _e_5298 = _e_5299[31:0];
    assign _e_5286 = {_e_5287, _e_5288, _e_5290, _e_5292, _e_5294, _e_5296, _e_5298};
    assign _e_5310 = _e_4919;
    assign _e_5308 = _e_4919[5];
    assign _e_5309 = _e_4919[4:0];
    assign _e_9495 = _e_5309[4:0] == 5'd15;
    assign _e_9496 = _e_5308 && _e_9495;
    assign _e_5312 = {5'd16};
    assign _e_5313 = \st [115:100];
    assign _e_5315 = \st [99:84];
    assign _e_5317 = \st [83:74];
    assign _e_5319 = \st [73:64];
    assign _e_5321 = \st [63:32];
    assign _e_5326 = {24'b0, \byte };
    localparam[31:0] _e_5328 = 32'd24;
    assign _e_5325 = _e_5326 << _e_5328;
    assign _e_5330 = \st [31:0];
    localparam[31:0] _e_5332 = 32'd16777215;
    assign _e_5329 = _e_5330 & _e_5332;
    assign _e_5324 = _e_5325 | _e_5329;
    assign _e_5323 = _e_5324[31:0];
    assign _e_5311 = {_e_5312, _e_5313, _e_5315, _e_5317, _e_5319, _e_5321, _e_5323};
    assign _e_5335 = _e_4919;
    assign \_  = _e_4919[5];
    assign _e_5334 = _e_4919[4:0];
    localparam[0:0] _e_9498 = 1;
    assign _e_9500 = _e_5334[4:0] == 5'd16;
    assign _e_9501 = _e_9498 && _e_9500;
    assign _e_5339 = \st [73:64];
    localparam[9:0] _e_5341 = 1;
    assign _e_5338 = _e_5339 + _e_5341;
    assign \pcw1  = _e_5338[9:0];
    assign _e_5345 = \st [99:84];
    localparam[15:0] _e_5347 = 1;
    assign _e_5344 = _e_5345 - _e_5347;
    assign \n1  = _e_5344[15:0];
    localparam[15:0] _e_5352 = 0;
    assign _e_5350 = \n1  == _e_5352;
    assign _e_5354 = {5'd17};
    assign _e_5356 = {5'd8};
    assign \next  = _e_5350 ? _e_5354 : _e_5356;
    assign _e_5360 = \st [115:100];
    assign _e_5363 = \st [83:74];
    assign _e_5366 = \st [63:32];
    assign _e_5368 = \st [31:0];
    assign _e_5358 = {\next , _e_5360, \n1 , _e_5363, \pcw1 , _e_5366, _e_5368};
    assign _e_5372 = _e_4919;
    assign __n1 = _e_4919[5];
    assign _e_5371 = _e_4919[4:0];
    localparam[0:0] _e_9503 = 1;
    assign _e_9505 = _e_5371[4:0] == 5'd17;
    assign _e_9506 = _e_9503 && _e_9505;
    assign _e_5376 = _e_4919;
    assign _e_5374 = _e_4919[5];
    assign __n2 = _e_4919[4:0];
    assign _e_9508 = !_e_5374;
    localparam[0:0] _e_9509 = 1;
    assign _e_9510 = _e_9508 && _e_9509;
    always_comb begin
        priority casez ({_e_9421, _e_9426, _e_9431, _e_9436, _e_9441, _e_9446, _e_9451, _e_9456, _e_9461, _e_9466, _e_9471, _e_9476, _e_9481, _e_9486, _e_9491, _e_9496, _e_9501, _e_9506, _e_9510})
            19'b1??????????????????: _e_4918 = _e_4926;
            19'b01?????????????????: _e_4918 = _e_4950;
            19'b001????????????????: _e_4918 = _e_4974;
            19'b0001???????????????: _e_4918 = _e_5000;
            19'b00001??????????????: _e_4918 = _e_5024;
            19'b000001?????????????: _e_4918 = _e_5059;
            19'b0000001????????????: _e_4918 = _e_5076;
            19'b00000001???????????: _e_4918 = _e_5102;
            19'b000000001??????????: _e_4918 = _e_5140;
            19'b0000000001?????????: _e_4918 = _e_5163;
            19'b00000000001????????: _e_4918 = _e_5188;
            19'b000000000001???????: _e_4918 = _e_5213;
            19'b0000000000001??????: _e_4918 = _e_5238;
            19'b00000000000001?????: _e_4918 = _e_5261;
            19'b000000000000001????: _e_4918 = _e_5286;
            19'b0000000000000001???: _e_4918 = _e_5311;
            19'b00000000000000001??: _e_4918 = _e_5358;
            19'b000000000000000001?: _e_4918 = \st ;
            19'b0000000000000000001: _e_4918 = \st ;
            19'b?: _e_4918 = 121'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \st  <= _e_4916;
        end
        else begin
            \st  <= _e_4918;
        end
    end
    assign _e_5379 = \st [120:116];
    assign _e_5381 = _e_5379;
    assign _e_9512 = _e_5379[4:0] == 5'd16;
    assign _e_5384 = \st [73:64];
    assign _e_5383 = {1'd1, _e_5384};
    assign _e_5387 = \st [63:32];
    assign _e_5386 = {1'd1, _e_5387};
    assign _e_5390 = \st [31:0];
    assign _e_5389 = {1'd1, _e_5390};
    assign _e_5382 = {_e_5383, _e_5386, _e_5389};
    assign __n3 = _e_5379;
    localparam[0:0] _e_9513 = 1;
    assign _e_5394 = {1'd0, 10'bX};
    assign _e_5395 = {1'd0, 32'bX};
    assign _e_5396 = {1'd0, 32'bX};
    assign _e_5393 = {_e_5394, _e_5395, _e_5396};
    always_comb begin
        priority casez ({_e_9512, _e_9513})
            2'b1?: _e_5400 = _e_5382;
            2'b01: _e_5400 = _e_5393;
            2'b?: _e_5400 = 77'dx;
        endcase
    end
    assign \wr_addr  = _e_5400[76:66];
    assign \wr_slot0  = _e_5400[65:33];
    assign \wr_slot1  = _e_5400[32:0];
    assign _e_5402 = \st [120:116];
    assign _e_5404 = _e_5402;
    assign _e_9515 = _e_5402[4:0] == 5'd17;
    localparam[0:0] _e_5406 = 0;
    assign _e_5408 = \st [83:74];
    assign _e_5407 = {1'd1, _e_5408};
    assign _e_5405 = {_e_5406, _e_5407};
    assign __n4 = _e_5402;
    localparam[0:0] _e_9516 = 1;
    localparam[0:0] _e_5412 = 1;
    assign _e_5413 = {1'd0, 10'bX};
    assign _e_5411 = {_e_5412, _e_5413};
    always_comb begin
        priority casez ({_e_9515, _e_9516})
            2'b1?: _e_5416 = _e_5405;
            2'b01: _e_5416 = _e_5411;
            2'b?: _e_5416 = 12'dx;
        endcase
    end
    assign \boot_active  = _e_5416[11];
    assign \release_pc  = _e_5416[10:0];
    assign _e_5417 = {\boot_active , \wr_addr , \wr_slot0 , \wr_slot1 , \release_pc };
    assign output__ = _e_5417;
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
    logic _e_9518;
    logic _e_9520;
    logic _e_9522;
    (* src = "src/bit.spade:18,45" *)
    logic[31:0] _e_5428;
    (* src = "src/bit.spade:18,14" *)
    reg[31:0] \op_a ;
    (* src = "src/bit.spade:25,9" *)
    logic[34:0] _e_5439;
    (* src = "src/bit.spade:25,14" *)
    logic[2:0] _e_5437;
    (* src = "src/bit.spade:25,14" *)
    logic[31:0] \_ ;
    logic _e_9524;
    logic _e_9527;
    logic _e_9529;
    logic _e_9530;
    (* src = "src/bit.spade:25,42" *)
    logic[31:0] _e_5442;
    (* src = "src/bit.spade:25,37" *)
    logic[32:0] _e_5441;
    (* src = "src/bit.spade:26,9" *)
    logic[34:0] _e_5446;
    (* src = "src/bit.spade:26,14" *)
    logic[2:0] _e_5444;
    (* src = "src/bit.spade:26,14" *)
    logic[31:0] __n1;
    logic _e_9532;
    logic _e_9535;
    logic _e_9537;
    logic _e_9538;
    (* src = "src/bit.spade:26,42" *)
    logic[31:0] _e_5449;
    (* src = "src/bit.spade:26,37" *)
    logic[32:0] _e_5448;
    (* src = "src/bit.spade:27,9" *)
    logic[34:0] _e_5453;
    (* src = "src/bit.spade:27,14" *)
    logic[2:0] _e_5451;
    (* src = "src/bit.spade:27,14" *)
    logic[31:0] __n2;
    logic _e_9540;
    logic _e_9543;
    logic _e_9545;
    logic _e_9546;
    (* src = "src/bit.spade:27,42" *)
    logic[31:0] _e_5456;
    (* src = "src/bit.spade:27,37" *)
    logic[32:0] _e_5455;
    (* src = "src/bit.spade:28,9" *)
    logic[34:0] _e_5460;
    (* src = "src/bit.spade:28,14" *)
    logic[2:0] _e_5458;
    (* src = "src/bit.spade:28,14" *)
    logic[31:0] __n3;
    logic _e_9548;
    logic _e_9551;
    logic _e_9553;
    logic _e_9554;
    (* src = "src/bit.spade:28,42" *)
    logic[31:0] _e_5463;
    (* src = "src/bit.spade:28,37" *)
    logic[32:0] _e_5462;
    (* src = "src/bit.spade:30,9" *)
    logic[34:0] _e_5467;
    (* src = "src/bit.spade:30,14" *)
    logic[2:0] _e_5465;
    (* src = "src/bit.spade:30,14" *)
    logic[31:0] \b ;
    logic _e_9556;
    logic _e_9559;
    logic _e_9561;
    logic _e_9562;
    (* src = "src/bit.spade:30,55" *)
    logic[31:0] _e_5474;
    (* src = "src/bit.spade:30,49" *)
    logic[31:0] _e_5472;
    (* src = "src/bit.spade:30,42" *)
    logic[31:0] _e_5470;
    (* src = "src/bit.spade:30,37" *)
    logic[32:0] _e_5469;
    (* src = "src/bit.spade:31,9" *)
    logic[34:0] _e_5479;
    (* src = "src/bit.spade:31,14" *)
    logic[2:0] _e_5477;
    (* src = "src/bit.spade:31,14" *)
    logic[31:0] b_n1;
    logic _e_9564;
    logic _e_9567;
    logic _e_9569;
    logic _e_9570;
    (* src = "src/bit.spade:31,56" *)
    logic[31:0] _e_5487;
    (* src = "src/bit.spade:31,50" *)
    logic[31:0] _e_5485;
    (* src = "src/bit.spade:31,49" *)
    logic[31:0] _e_5484;
    (* src = "src/bit.spade:31,42" *)
    logic[31:0] _e_5482;
    (* src = "src/bit.spade:31,37" *)
    logic[32:0] _e_5481;
    (* src = "src/bit.spade:35,9" *)
    logic[34:0] _e_5492;
    (* src = "src/bit.spade:35,14" *)
    logic[2:0] _e_5490;
    (* src = "src/bit.spade:35,14" *)
    logic[31:0] b_n2;
    logic _e_9572;
    logic _e_9575;
    logic _e_9577;
    logic _e_9578;
    (* src = "src/bit.spade:35,40" *)
    logic[31:0] _e_5495;
    (* src = "src/bit.spade:35,35" *)
    logic[32:0] _e_5494;
    (* src = "src/bit.spade:36,9" *)
    logic[34:0] _e_5500;
    (* src = "src/bit.spade:36,14" *)
    logic[2:0] _e_5498;
    (* src = "src/bit.spade:36,14" *)
    logic[31:0] b_n3;
    logic _e_9580;
    logic _e_9583;
    logic _e_9585;
    logic _e_9586;
    (* src = "src/bit.spade:36,40" *)
    logic[31:0] _e_5503;
    (* src = "src/bit.spade:36,35" *)
    logic[32:0] _e_5502;
    logic _e_9588;
    (* src = "src/bit.spade:38,17" *)
    logic[32:0] _e_5507;
    (* src = "src/bit.spade:24,36" *)
    logic[32:0] \result ;
    (* src = "src/bit.spade:42,51" *)
    logic[32:0] _e_5512;
    (* src = "src/bit.spade:42,14" *)
    reg[32:0] \res_reg ;
    localparam[31:0] _e_5427 = 32'd0;
    assign \v  = \set_op_a [31:0];
    assign _e_9518 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9519 = 1;
    assign _e_9520 = _e_9518 && _e_9519;
    assign _e_9522 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9520, _e_9522})
            2'b1?: _e_5428 = \v ;
            2'b01: _e_5428 = \op_a ;
            2'b?: _e_5428 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_5427;
        end
        else begin
            \op_a  <= _e_5428;
        end
    end
    assign _e_5439 = \trig [34:0];
    assign _e_5437 = _e_5439[34:32];
    assign \_  = _e_5439[31:0];
    assign _e_9524 = \trig [35] == 1'd1;
    assign _e_9527 = _e_5437[2:0] == 3'd0;
    localparam[0:0] _e_9528 = 1;
    assign _e_9529 = _e_9527 && _e_9528;
    assign _e_9530 = _e_9524 && _e_9529;
    (* src = "src/bit.spade:25,42" *)
    \tta::bit::clz32  clz32_0(.val_i(\op_a ), .output__(_e_5442));
    assign _e_5441 = {1'd1, _e_5442};
    assign _e_5446 = \trig [34:0];
    assign _e_5444 = _e_5446[34:32];
    assign __n1 = _e_5446[31:0];
    assign _e_9532 = \trig [35] == 1'd1;
    assign _e_9535 = _e_5444[2:0] == 3'd1;
    localparam[0:0] _e_9536 = 1;
    assign _e_9537 = _e_9535 && _e_9536;
    assign _e_9538 = _e_9532 && _e_9537;
    (* src = "src/bit.spade:26,42" *)
    \tta::bit::ctz32  ctz32_0(.val_i(\op_a ), .output__(_e_5449));
    assign _e_5448 = {1'd1, _e_5449};
    assign _e_5453 = \trig [34:0];
    assign _e_5451 = _e_5453[34:32];
    assign __n2 = _e_5453[31:0];
    assign _e_9540 = \trig [35] == 1'd1;
    assign _e_9543 = _e_5451[2:0] == 3'd2;
    localparam[0:0] _e_9544 = 1;
    assign _e_9545 = _e_9543 && _e_9544;
    assign _e_9546 = _e_9540 && _e_9545;
    (* src = "src/bit.spade:27,42" *)
    \tta::bit::popcnt32  popcnt32_0(.val_i(\op_a ), .output__(_e_5456));
    assign _e_5455 = {1'd1, _e_5456};
    assign _e_5460 = \trig [34:0];
    assign _e_5458 = _e_5460[34:32];
    assign __n3 = _e_5460[31:0];
    assign _e_9548 = \trig [35] == 1'd1;
    assign _e_9551 = _e_5458[2:0] == 3'd7;
    localparam[0:0] _e_9552 = 1;
    assign _e_9553 = _e_9551 && _e_9552;
    assign _e_9554 = _e_9548 && _e_9553;
    (* src = "src/bit.spade:28,42" *)
    \tta::bit::brev32  brev32_0(.val_i(\op_a ), .output__(_e_5463));
    assign _e_5462 = {1'd1, _e_5463};
    assign _e_5467 = \trig [34:0];
    assign _e_5465 = _e_5467[34:32];
    assign \b  = _e_5467[31:0];
    assign _e_9556 = \trig [35] == 1'd1;
    assign _e_9559 = _e_5465[2:0] == 3'd3;
    localparam[0:0] _e_9560 = 1;
    assign _e_9561 = _e_9559 && _e_9560;
    assign _e_9562 = _e_9556 && _e_9561;
    localparam[31:0] _e_5473 = 32'd1;
    localparam[31:0] _e_5476 = 32'd31;
    assign _e_5474 = \b  & _e_5476;
    assign _e_5472 = _e_5473 << _e_5474;
    assign _e_5470 = \op_a  | _e_5472;
    assign _e_5469 = {1'd1, _e_5470};
    assign _e_5479 = \trig [34:0];
    assign _e_5477 = _e_5479[34:32];
    assign b_n1 = _e_5479[31:0];
    assign _e_9564 = \trig [35] == 1'd1;
    assign _e_9567 = _e_5477[2:0] == 3'd4;
    localparam[0:0] _e_9568 = 1;
    assign _e_9569 = _e_9567 && _e_9568;
    assign _e_9570 = _e_9564 && _e_9569;
    localparam[31:0] _e_5486 = 32'd1;
    localparam[31:0] _e_5489 = 32'd31;
    assign _e_5487 = b_n1 & _e_5489;
    assign _e_5485 = _e_5486 << _e_5487;
    assign _e_5484 = ~_e_5485;
    assign _e_5482 = \op_a  & _e_5484;
    assign _e_5481 = {1'd1, _e_5482};
    assign _e_5492 = \trig [34:0];
    assign _e_5490 = _e_5492[34:32];
    assign b_n2 = _e_5492[31:0];
    assign _e_9572 = \trig [35] == 1'd1;
    assign _e_9575 = _e_5490[2:0] == 3'd5;
    localparam[0:0] _e_9576 = 1;
    assign _e_9577 = _e_9575 && _e_9576;
    assign _e_9578 = _e_9572 && _e_9577;
    (* src = "src/bit.spade:35,40" *)
    \tta::bit::bext32  bext32_0(.val_i(\op_a ), .ctrl_i(b_n2), .output__(_e_5495));
    assign _e_5494 = {1'd1, _e_5495};
    assign _e_5500 = \trig [34:0];
    assign _e_5498 = _e_5500[34:32];
    assign b_n3 = _e_5500[31:0];
    assign _e_9580 = \trig [35] == 1'd1;
    assign _e_9583 = _e_5498[2:0] == 3'd6;
    localparam[0:0] _e_9584 = 1;
    assign _e_9585 = _e_9583 && _e_9584;
    assign _e_9586 = _e_9580 && _e_9585;
    (* src = "src/bit.spade:36,40" *)
    \tta::bit::bins32  bins32_0(.val_i(\op_a ), .ctrl_i(b_n3), .output__(_e_5503));
    assign _e_5502 = {1'd1, _e_5503};
    assign _e_9588 = \trig [35] == 1'd0;
    assign _e_5507 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9530, _e_9538, _e_9546, _e_9554, _e_9562, _e_9570, _e_9578, _e_9586, _e_9588})
            9'b1????????: \result  = _e_5441;
            9'b01???????: \result  = _e_5448;
            9'b001??????: \result  = _e_5455;
            9'b0001?????: \result  = _e_5462;
            9'b00001????: \result  = _e_5469;
            9'b000001???: \result  = _e_5481;
            9'b0000001??: \result  = _e_5494;
            9'b00000001?: \result  = _e_5502;
            9'b000000001: \result  = _e_5507;
            9'b?: \result  = 33'dx;
        endcase
    end
    assign _e_5512 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_5512;
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
    logic _e_5517;
    (* src = "src/bit.spade:57,27" *)
    logic[31:0] _e_5525;
    (* src = "src/bit.spade:57,27" *)
    logic _e_5524;
    (* src = "src/bit.spade:57,58" *)
    logic[31:0] _e_5532;
    (* src = "src/bit.spade:57,53" *)
    logic[63:0] _e_5530;
    (* src = "src/bit.spade:57,78" *)
    logic[63:0] _e_5536;
    (* src = "src/bit.spade:57,24" *)
    logic[63:0] _e_5541;
    (* src = "src/bit.spade:57,13" *)
    logic[31:0] \n1 ;
    (* src = "src/bit.spade:57,13" *)
    logic[31:0] \x1 ;
    (* src = "src/bit.spade:58,27" *)
    logic[31:0] _e_5544;
    (* src = "src/bit.spade:58,27" *)
    logic _e_5543;
    (* src = "src/bit.spade:58,59" *)
    logic[32:0] _e_5551;
    (* src = "src/bit.spade:58,53" *)
    logic[31:0] _e_5550;
    (* src = "src/bit.spade:58,66" *)
    logic[31:0] _e_5554;
    (* src = "src/bit.spade:58,52" *)
    logic[63:0] _e_5549;
    (* src = "src/bit.spade:58,84" *)
    logic[63:0] _e_5558;
    (* src = "src/bit.spade:58,24" *)
    logic[63:0] _e_5563;
    (* src = "src/bit.spade:58,13" *)
    logic[31:0] \n2 ;
    (* src = "src/bit.spade:58,13" *)
    logic[31:0] \x2 ;
    (* src = "src/bit.spade:59,27" *)
    logic[31:0] _e_5566;
    (* src = "src/bit.spade:59,27" *)
    logic _e_5565;
    (* src = "src/bit.spade:59,59" *)
    logic[32:0] _e_5573;
    (* src = "src/bit.spade:59,53" *)
    logic[31:0] _e_5572;
    (* src = "src/bit.spade:59,66" *)
    logic[31:0] _e_5576;
    (* src = "src/bit.spade:59,52" *)
    logic[63:0] _e_5571;
    (* src = "src/bit.spade:59,84" *)
    logic[63:0] _e_5580;
    (* src = "src/bit.spade:59,24" *)
    logic[63:0] _e_5585;
    (* src = "src/bit.spade:59,13" *)
    logic[31:0] \n3 ;
    (* src = "src/bit.spade:59,13" *)
    logic[31:0] \x3 ;
    (* src = "src/bit.spade:60,27" *)
    logic[31:0] _e_5588;
    (* src = "src/bit.spade:60,27" *)
    logic _e_5587;
    (* src = "src/bit.spade:60,59" *)
    logic[32:0] _e_5595;
    (* src = "src/bit.spade:60,53" *)
    logic[31:0] _e_5594;
    (* src = "src/bit.spade:60,66" *)
    logic[31:0] _e_5598;
    (* src = "src/bit.spade:60,52" *)
    logic[63:0] _e_5593;
    (* src = "src/bit.spade:60,84" *)
    logic[63:0] _e_5602;
    (* src = "src/bit.spade:60,24" *)
    logic[63:0] _e_5607;
    (* src = "src/bit.spade:60,13" *)
    logic[31:0] \n4 ;
    (* src = "src/bit.spade:60,13" *)
    logic[31:0] \x4 ;
    (* src = "src/bit.spade:61,21" *)
    logic[31:0] _e_5610;
    (* src = "src/bit.spade:61,21" *)
    logic _e_5609;
    (* src = "src/bit.spade:61,52" *)
    logic[32:0] _e_5616;
    (* src = "src/bit.spade:61,46" *)
    logic[31:0] _e_5615;
    (* src = "src/bit.spade:61,18" *)
    logic[31:0] \n5 ;
    (* src = "src/bit.spade:53,5" *)
    logic[31:0] _e_5516;
    localparam[31:0] _e_5519 = 32'd0;
    assign _e_5517 = \val  == _e_5519;
    localparam[31:0] _e_5521 = 32'd32;
    localparam[31:0] _e_5527 = 32'd4294901760;
    assign _e_5525 = \val  & _e_5527;
    localparam[31:0] _e_5528 = 32'd0;
    assign _e_5524 = _e_5525 == _e_5528;
    localparam[31:0] _e_5531 = 32'd16;
    localparam[31:0] _e_5534 = 32'd16;
    assign _e_5532 = \val  << _e_5534;
    assign _e_5530 = {_e_5531, _e_5532};
    localparam[31:0] _e_5537 = 32'd0;
    assign _e_5536 = {_e_5537, \val };
    assign _e_5541 = _e_5524 ? _e_5530 : _e_5536;
    assign \n1  = _e_5541[63:32];
    assign \x1  = _e_5541[31:0];
    localparam[31:0] _e_5546 = 32'd4278190080;
    assign _e_5544 = \x1  & _e_5546;
    localparam[31:0] _e_5547 = 32'd0;
    assign _e_5543 = _e_5544 == _e_5547;
    localparam[31:0] _e_5553 = 32'd8;
    assign _e_5551 = \n1  + _e_5553;
    assign _e_5550 = _e_5551[31:0];
    localparam[31:0] _e_5556 = 32'd8;
    assign _e_5554 = \x1  << _e_5556;
    assign _e_5549 = {_e_5550, _e_5554};
    assign _e_5558 = {\n1 , \x1 };
    assign _e_5563 = _e_5543 ? _e_5549 : _e_5558;
    assign \n2  = _e_5563[63:32];
    assign \x2  = _e_5563[31:0];
    localparam[31:0] _e_5568 = 32'd4026531840;
    assign _e_5566 = \x2  & _e_5568;
    localparam[31:0] _e_5569 = 32'd0;
    assign _e_5565 = _e_5566 == _e_5569;
    localparam[31:0] _e_5575 = 32'd4;
    assign _e_5573 = \n2  + _e_5575;
    assign _e_5572 = _e_5573[31:0];
    localparam[31:0] _e_5578 = 32'd4;
    assign _e_5576 = \x2  << _e_5578;
    assign _e_5571 = {_e_5572, _e_5576};
    assign _e_5580 = {\n2 , \x2 };
    assign _e_5585 = _e_5565 ? _e_5571 : _e_5580;
    assign \n3  = _e_5585[63:32];
    assign \x3  = _e_5585[31:0];
    localparam[31:0] _e_5590 = 32'd3221225472;
    assign _e_5588 = \x3  & _e_5590;
    localparam[31:0] _e_5591 = 32'd0;
    assign _e_5587 = _e_5588 == _e_5591;
    localparam[31:0] _e_5597 = 32'd2;
    assign _e_5595 = \n3  + _e_5597;
    assign _e_5594 = _e_5595[31:0];
    localparam[31:0] _e_5600 = 32'd2;
    assign _e_5598 = \x3  << _e_5600;
    assign _e_5593 = {_e_5594, _e_5598};
    assign _e_5602 = {\n3 , \x3 };
    assign _e_5607 = _e_5587 ? _e_5593 : _e_5602;
    assign \n4  = _e_5607[63:32];
    assign \x4  = _e_5607[31:0];
    localparam[31:0] _e_5612 = 32'd2147483648;
    assign _e_5610 = \x4  & _e_5612;
    localparam[31:0] _e_5613 = 32'd0;
    assign _e_5609 = _e_5610 == _e_5613;
    localparam[31:0] _e_5618 = 32'd1;
    assign _e_5616 = \n4  + _e_5618;
    assign _e_5615 = _e_5616[31:0];
    assign \n5  = _e_5609 ? _e_5615 : \n4 ;
    assign _e_5516 = _e_5517 ? _e_5521 : \n5 ;
    assign output__ = _e_5516;
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
    logic[31:0] _e_5625;
    (* src = "src/bit.spade:68,5" *)
    logic[31:0] _e_5624;
    (* src = "src/bit.spade:68,11" *)
    \tta::bit::brev32  brev32_0(.val_i(\val ), .output__(_e_5625));
    (* src = "src/bit.spade:68,5" *)
    \tta::bit::clz32  clz32_0(.val_i(_e_5625), .output__(_e_5624));
    assign output__ = _e_5624;
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
    logic[31:0] _e_5632;
    (* src = "src/bit.spade:74,13" *)
    logic[31:0] _e_5631;
    (* src = "src/bit.spade:74,40" *)
    logic[31:0] _e_5637;
    (* src = "src/bit.spade:74,39" *)
    logic[31:0] _e_5636;
    (* src = "src/bit.spade:74,13" *)
    logic[31:0] x_n1;
    (* src = "src/bit.spade:75,14" *)
    logic[31:0] _e_5644;
    (* src = "src/bit.spade:75,13" *)
    logic[31:0] _e_5643;
    (* src = "src/bit.spade:75,40" *)
    logic[31:0] _e_5649;
    (* src = "src/bit.spade:75,39" *)
    logic[31:0] _e_5648;
    (* src = "src/bit.spade:75,13" *)
    logic[31:0] x_n2;
    (* src = "src/bit.spade:76,14" *)
    logic[31:0] _e_5656;
    (* src = "src/bit.spade:76,13" *)
    logic[31:0] _e_5655;
    (* src = "src/bit.spade:76,40" *)
    logic[31:0] _e_5661;
    (* src = "src/bit.spade:76,39" *)
    logic[31:0] _e_5660;
    (* src = "src/bit.spade:76,13" *)
    logic[31:0] x_n3;
    (* src = "src/bit.spade:77,14" *)
    logic[31:0] _e_5668;
    (* src = "src/bit.spade:77,13" *)
    logic[31:0] _e_5667;
    (* src = "src/bit.spade:77,40" *)
    logic[31:0] _e_5673;
    (* src = "src/bit.spade:77,39" *)
    logic[31:0] _e_5672;
    (* src = "src/bit.spade:77,13" *)
    logic[31:0] x_n4;
    (* src = "src/bit.spade:78,13" *)
    logic[31:0] _e_5679;
    (* src = "src/bit.spade:78,25" *)
    logic[31:0] _e_5682;
    (* src = "src/bit.spade:78,13" *)
    logic[31:0] x_n5;
    assign \x  = \val ;
    localparam[31:0] _e_5634 = 32'd1;
    assign _e_5632 = \x  >> _e_5634;
    localparam[31:0] _e_5635 = 32'd1431655765;
    assign _e_5631 = _e_5632 & _e_5635;
    localparam[31:0] _e_5639 = 32'd1431655765;
    assign _e_5637 = \x  & _e_5639;
    localparam[31:0] _e_5640 = 32'd1;
    assign _e_5636 = _e_5637 << _e_5640;
    assign x_n1 = _e_5631 | _e_5636;
    localparam[31:0] _e_5646 = 32'd2;
    assign _e_5644 = x_n1 >> _e_5646;
    localparam[31:0] _e_5647 = 32'd858993459;
    assign _e_5643 = _e_5644 & _e_5647;
    localparam[31:0] _e_5651 = 32'd858993459;
    assign _e_5649 = x_n1 & _e_5651;
    localparam[31:0] _e_5652 = 32'd2;
    assign _e_5648 = _e_5649 << _e_5652;
    assign x_n2 = _e_5643 | _e_5648;
    localparam[31:0] _e_5658 = 32'd4;
    assign _e_5656 = x_n2 >> _e_5658;
    localparam[31:0] _e_5659 = 32'd252645135;
    assign _e_5655 = _e_5656 & _e_5659;
    localparam[31:0] _e_5663 = 32'd252645135;
    assign _e_5661 = x_n2 & _e_5663;
    localparam[31:0] _e_5664 = 32'd4;
    assign _e_5660 = _e_5661 << _e_5664;
    assign x_n3 = _e_5655 | _e_5660;
    localparam[31:0] _e_5670 = 32'd8;
    assign _e_5668 = x_n3 >> _e_5670;
    localparam[31:0] _e_5671 = 32'd16711935;
    assign _e_5667 = _e_5668 & _e_5671;
    localparam[31:0] _e_5675 = 32'd16711935;
    assign _e_5673 = x_n3 & _e_5675;
    localparam[31:0] _e_5676 = 32'd8;
    assign _e_5672 = _e_5673 << _e_5676;
    assign x_n4 = _e_5667 | _e_5672;
    localparam[31:0] _e_5681 = 32'd16;
    assign _e_5679 = x_n4 >> _e_5681;
    localparam[31:0] _e_5684 = 32'd16;
    assign _e_5682 = x_n4 << _e_5684;
    assign x_n5 = _e_5679 | _e_5682;
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
    logic[31:0] _e_5693;
    (* src = "src/bit.spade:85,17" *)
    logic[31:0] _e_5692;
    (* src = "src/bit.spade:85,13" *)
    logic[32:0] x_n1;
    (* src = "src/bit.spade:86,13" *)
    logic[32:0] _e_5699;
    (* src = "src/bit.spade:86,33" *)
    logic[32:0] _e_5703;
    (* src = "src/bit.spade:86,32" *)
    logic[32:0] _e_5702;
    (* src = "src/bit.spade:86,13" *)
    logic[33:0] x_n2;
    (* src = "src/bit.spade:87,18" *)
    logic[33:0] _e_5711;
    (* src = "src/bit.spade:87,13" *)
    logic[34:0] _e_5709;
    (* src = "src/bit.spade:87,13" *)
    logic[34:0] x_n3;
    (* src = "src/bit.spade:88,17" *)
    logic[34:0] _e_5718;
    (* src = "src/bit.spade:88,13" *)
    logic[35:0] x_n4;
    (* src = "src/bit.spade:89,17" *)
    logic[35:0] _e_5724;
    (* src = "src/bit.spade:89,13" *)
    logic[36:0] x_n5;
    (* src = "src/bit.spade:90,11" *)
    logic[36:0] _e_5729;
    (* src = "src/bit.spade:90,5" *)
    logic[31:0] _e_5728;
    assign \x  = \val ;
    localparam[31:0] _e_5695 = 32'd1;
    assign _e_5693 = \x  >> _e_5695;
    localparam[31:0] _e_5696 = 32'd1431655765;
    assign _e_5692 = _e_5693 & _e_5696;
    assign x_n1 = \x  - _e_5692;
    localparam[32:0] _e_5701 = 33'd858993459;
    assign _e_5699 = x_n1 & _e_5701;
    localparam[32:0] _e_5705 = 33'd2;
    assign _e_5703 = x_n1 >> _e_5705;
    localparam[32:0] _e_5706 = 33'd858993459;
    assign _e_5702 = _e_5703 & _e_5706;
    assign x_n2 = _e_5699 + _e_5702;
    localparam[33:0] _e_5713 = 34'd4;
    assign _e_5711 = x_n2 >> _e_5713;
    assign _e_5709 = x_n2 + _e_5711;
    localparam[34:0] _e_5714 = 35'd252645135;
    assign x_n3 = _e_5709 & _e_5714;
    localparam[34:0] _e_5720 = 35'd8;
    assign _e_5718 = x_n3 >> _e_5720;
    assign x_n4 = x_n3 + _e_5718;
    localparam[35:0] _e_5726 = 36'd16;
    assign _e_5724 = x_n4 >> _e_5726;
    assign x_n5 = x_n4 + _e_5724;
    localparam[36:0] _e_5731 = 37'd63;
    assign _e_5729 = x_n5 & _e_5731;
    assign _e_5728 = _e_5729[31:0];
    assign output__ = _e_5728;
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
    logic[31:0] _e_5738;
    (* src = "src/bit.spade:97,25" *)
    logic[31:0] \width_minus_1 ;
    (* src = "src/bit.spade:103,19" *)
    logic _e_5744;
    (* src = "src/bit.spade:106,21" *)
    logic[32:0] _e_5754;
    (* src = "src/bit.spade:106,15" *)
    logic[32:0] _e_5752;
    (* src = "src/bit.spade:106,15" *)
    logic[33:0] _e_5751;
    (* src = "src/bit.spade:106,9" *)
    logic[31:0] _e_5750;
    (* src = "src/bit.spade:103,16" *)
    logic[31:0] \mask ;
    (* src = "src/bit.spade:109,5" *)
    logic[31:0] _e_5760;
    (* src = "src/bit.spade:109,5" *)
    logic[31:0] _e_5759;
    localparam[31:0] _e_5735 = 32'd31;
    assign \lsb  = \ctrl  & _e_5735;
    localparam[31:0] _e_5740 = 32'd5;
    assign _e_5738 = \ctrl  >> _e_5740;
    localparam[31:0] _e_5741 = 32'd31;
    assign \width_minus_1  = _e_5738 & _e_5741;
    localparam[31:0] _e_5746 = 32'd31;
    assign _e_5744 = \width_minus_1  == _e_5746;
    localparam[31:0] _e_5748 = 32'd4294967295;
    localparam[32:0] _e_5753 = 33'd1;
    localparam[31:0] _e_5756 = 32'd1;
    assign _e_5754 = \width_minus_1  + _e_5756;
    assign _e_5752 = _e_5753 << _e_5754;
    localparam[32:0] _e_5757 = 33'd1;
    assign _e_5751 = _e_5752 - _e_5757;
    assign _e_5750 = _e_5751[31:0];
    assign \mask  = _e_5744 ? _e_5748 : _e_5750;
    assign _e_5760 = \val  >> \lsb ;
    assign _e_5759 = _e_5760 & \mask ;
    assign output__ = _e_5759;
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
    logic[31:0] _e_5770;
    (* src = "src/bit.spade:116,25" *)
    logic[31:0] \width_minus_1 ;
    (* src = "src/bit.spade:118,19" *)
    logic _e_5776;
    (* src = "src/bit.spade:121,21" *)
    logic[32:0] _e_5786;
    (* src = "src/bit.spade:121,15" *)
    logic[32:0] _e_5784;
    (* src = "src/bit.spade:121,15" *)
    logic[33:0] _e_5783;
    (* src = "src/bit.spade:121,9" *)
    logic[31:0] _e_5782;
    (* src = "src/bit.spade:118,16" *)
    logic[31:0] \mask ;
    (* src = "src/bit.spade:124,5" *)
    logic[31:0] _e_5792;
    (* src = "src/bit.spade:124,5" *)
    logic[31:0] _e_5791;
    localparam[31:0] _e_5767 = 32'd31;
    assign \lsb  = \ctrl  & _e_5767;
    localparam[31:0] _e_5772 = 32'd5;
    assign _e_5770 = \ctrl  >> _e_5772;
    localparam[31:0] _e_5773 = 32'd31;
    assign \width_minus_1  = _e_5770 & _e_5773;
    localparam[31:0] _e_5778 = 32'd31;
    assign _e_5776 = \width_minus_1  == _e_5778;
    localparam[31:0] _e_5780 = 32'd4294967295;
    localparam[32:0] _e_5785 = 33'd1;
    localparam[31:0] _e_5788 = 32'd1;
    assign _e_5786 = \width_minus_1  + _e_5788;
    assign _e_5784 = _e_5785 << _e_5786;
    localparam[32:0] _e_5789 = 33'd1;
    assign _e_5783 = _e_5784 - _e_5789;
    assign _e_5782 = _e_5783[31:0];
    assign \mask  = _e_5776 ? _e_5780 : _e_5782;
    assign _e_5792 = \val  & \mask ;
    assign _e_5791 = _e_5792 << \lsb ;
    assign output__ = _e_5791;
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
    logic[42:0] _e_5800;
    (* src = "src/bit.spade:129,14" *)
    logic[31:0] \x ;
    logic _e_9590;
    logic _e_9592;
    logic _e_9594;
    logic _e_9595;
    (* src = "src/bit.spade:129,35" *)
    logic[32:0] _e_5802;
    (* src = "src/bit.spade:130,9" *)
    logic[43:0] \_ ;
    (* src = "src/bit.spade:131,13" *)
    logic[42:0] _e_5808;
    (* src = "src/bit.spade:131,18" *)
    logic[31:0] x_n1;
    logic _e_9598;
    logic _e_9600;
    logic _e_9602;
    logic _e_9603;
    (* src = "src/bit.spade:131,39" *)
    logic[32:0] _e_5810;
    (* src = "src/bit.spade:132,13" *)
    logic[43:0] __n1;
    (* src = "src/bit.spade:132,18" *)
    logic[32:0] _e_5813;
    (* src = "src/bit.spade:130,14" *)
    logic[32:0] _e_5805;
    (* src = "src/bit.spade:128,5" *)
    logic[32:0] _e_5797;
    assign _e_5800 = \m1 [42:0];
    assign \x  = _e_5800[36:5];
    assign _e_9590 = \m1 [43] == 1'd1;
    assign _e_9592 = _e_5800[42:37] == 6'd39;
    localparam[0:0] _e_9593 = 1;
    assign _e_9594 = _e_9592 && _e_9593;
    assign _e_9595 = _e_9590 && _e_9594;
    assign _e_5802 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9596 = 1;
    assign _e_5808 = \m0 [42:0];
    assign x_n1 = _e_5808[36:5];
    assign _e_9598 = \m0 [43] == 1'd1;
    assign _e_9600 = _e_5808[42:37] == 6'd39;
    localparam[0:0] _e_9601 = 1;
    assign _e_9602 = _e_9600 && _e_9601;
    assign _e_9603 = _e_9598 && _e_9602;
    assign _e_5810 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9604 = 1;
    assign _e_5813 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9603, _e_9604})
            2'b1?: _e_5805 = _e_5810;
            2'b01: _e_5805 = _e_5813;
            2'b?: _e_5805 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9595, _e_9596})
            2'b1?: _e_5797 = _e_5802;
            2'b01: _e_5797 = _e_5805;
            2'b?: _e_5797 = 33'dx;
        endcase
    end
    assign output__ = _e_5797;
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
    logic[42:0] _e_5819;
    (* src = "src/bit.spade:138,14" *)
    logic[2:0] \op ;
    (* src = "src/bit.spade:138,14" *)
    logic[31:0] \x ;
    logic _e_9606;
    logic _e_9608;
    logic _e_9611;
    logic _e_9612;
    logic _e_9613;
    (* src = "src/bit.spade:138,44" *)
    logic[34:0] _e_5822;
    (* src = "src/bit.spade:138,39" *)
    logic[35:0] _e_5821;
    (* src = "src/bit.spade:139,9" *)
    logic[43:0] \_ ;
    (* src = "src/bit.spade:140,13" *)
    logic[42:0] _e_5830;
    (* src = "src/bit.spade:140,18" *)
    logic[2:0] op_n1;
    (* src = "src/bit.spade:140,18" *)
    logic[31:0] x_n1;
    logic _e_9616;
    logic _e_9618;
    logic _e_9621;
    logic _e_9622;
    logic _e_9623;
    (* src = "src/bit.spade:140,48" *)
    logic[34:0] _e_5833;
    (* src = "src/bit.spade:140,43" *)
    logic[35:0] _e_5832;
    (* src = "src/bit.spade:141,13" *)
    logic[43:0] __n1;
    (* src = "src/bit.spade:141,18" *)
    logic[35:0] _e_5837;
    (* src = "src/bit.spade:139,14" *)
    logic[35:0] _e_5826;
    (* src = "src/bit.spade:137,5" *)
    logic[35:0] _e_5815;
    assign _e_5819 = \m1 [42:0];
    assign \op  = _e_5819[36:34];
    assign \x  = _e_5819[33:2];
    assign _e_9606 = \m1 [43] == 1'd1;
    assign _e_9608 = _e_5819[42:37] == 6'd40;
    localparam[0:0] _e_9609 = 1;
    localparam[0:0] _e_9610 = 1;
    assign _e_9611 = _e_9608 && _e_9609;
    assign _e_9612 = _e_9611 && _e_9610;
    assign _e_9613 = _e_9606 && _e_9612;
    assign _e_5822 = {\op , \x };
    assign _e_5821 = {1'd1, _e_5822};
    assign \_  = \m1 ;
    localparam[0:0] _e_9614 = 1;
    assign _e_5830 = \m0 [42:0];
    assign op_n1 = _e_5830[36:34];
    assign x_n1 = _e_5830[33:2];
    assign _e_9616 = \m0 [43] == 1'd1;
    assign _e_9618 = _e_5830[42:37] == 6'd40;
    localparam[0:0] _e_9619 = 1;
    localparam[0:0] _e_9620 = 1;
    assign _e_9621 = _e_9618 && _e_9619;
    assign _e_9622 = _e_9621 && _e_9620;
    assign _e_9623 = _e_9616 && _e_9622;
    assign _e_5833 = {op_n1, x_n1};
    assign _e_5832 = {1'd1, _e_5833};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9624 = 1;
    assign _e_5837 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_9623, _e_9624})
            2'b1?: _e_5826 = _e_5832;
            2'b01: _e_5826 = _e_5837;
            2'b?: _e_5826 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9613, _e_9614})
            2'b1?: _e_5815 = _e_5821;
            2'b01: _e_5815 = _e_5826;
            2'b?: _e_5815 = 36'dx;
        endcase
    end
    assign output__ = _e_5815;
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
    logic _e_9626;
    logic _e_9628;
    logic _e_9630;
    (* src = "src/mac.spade:20,45" *)
    logic[31:0] _e_5843;
    (* src = "src/mac.spade:20,14" *)
    reg[31:0] \op_a ;
    (* src = "src/mac.spade:33,17" *)
    logic[31:0] \op_b ;
    logic _e_9632;
    logic _e_9634;
    (* src = "src/mac.spade:36,48" *)
    logic[63:0] _e_5866;
    (* src = "src/mac.spade:36,42" *)
    logic[31:0] \prod ;
    (* src = "src/mac.spade:37,27" *)
    logic[32:0] _e_5871;
    (* src = "src/mac.spade:37,21" *)
    logic[31:0] _e_5870;
    logic _e_9636;
    (* src = "src/mac.spade:32,13" *)
    logic[31:0] _e_5860;
    (* src = "src/mac.spade:29,9" *)
    logic[31:0] _e_5855;
    (* src = "src/mac.spade:28,14" *)
    reg[31:0] \acc ;
    (* src = "src/mac.spade:46,47" *)
    logic[32:0] _e_5879;
    (* src = "src/mac.spade:50,13" *)
    logic[32:0] _e_5884;
    (* src = "src/mac.spade:53,17" *)
    logic[31:0] op_b_n1;
    logic _e_9638;
    logic _e_9640;
    (* src = "src/mac.spade:55,48" *)
    logic[63:0] _e_5893;
    (* src = "src/mac.spade:55,42" *)
    logic[31:0] prod_n1;
    (* src = "src/mac.spade:56,32" *)
    logic[32:0] _e_5899;
    (* src = "src/mac.spade:56,26" *)
    logic[31:0] _e_5898;
    (* src = "src/mac.spade:56,21" *)
    logic[32:0] _e_5897;
    logic _e_9642;
    (* src = "src/mac.spade:58,25" *)
    logic[32:0] _e_5903;
    (* src = "src/mac.spade:52,13" *)
    logic[32:0] _e_5887;
    (* src = "src/mac.spade:47,9" *)
    logic[32:0] _e_5881;
    (* src = "src/mac.spade:46,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_5842 = 32'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9626 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9627 = 1;
    assign _e_9628 = _e_9626 && _e_9627;
    assign _e_9630 = \set_op_a [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9628, _e_9630})
            2'b1?: _e_5843 = \val ;
            2'b01: _e_5843 = \op_a ;
            2'b?: _e_5843 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \op_a  <= _e_5842;
        end
        else begin
            \op_a  <= _e_5843;
        end
    end
    localparam[31:0] _e_5853 = 32'd0;
    localparam[31:0] _e_5858 = 32'd0;
    assign \op_b  = \trig [31:0];
    assign _e_9632 = \trig [32] == 1'd1;
    localparam[0:0] _e_9633 = 1;
    assign _e_9634 = _e_9632 && _e_9633;
    assign _e_5866 = \op_a  * \op_b ;
    assign \prod  = _e_5866[31:0];
    assign _e_5871 = \acc  + \prod ;
    assign _e_5870 = _e_5871[31:0];
    assign _e_9636 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_9634, _e_9636})
            2'b1?: _e_5860 = _e_5870;
            2'b01: _e_5860 = \acc ;
            2'b?: _e_5860 = 32'dx;
        endcase
    end
    assign _e_5855 = \clr  ? _e_5858 : _e_5860;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \acc  <= _e_5853;
        end
        else begin
            \acc  <= _e_5855;
        end
    end
    assign _e_5879 = {1'd0, 32'bX};
    localparam[31:0] _e_5885 = 32'd0;
    assign _e_5884 = {1'd1, _e_5885};
    assign op_b_n1 = \trig [31:0];
    assign _e_9638 = \trig [32] == 1'd1;
    localparam[0:0] _e_9639 = 1;
    assign _e_9640 = _e_9638 && _e_9639;
    assign _e_5893 = \op_a  * op_b_n1;
    assign prod_n1 = _e_5893[31:0];
    assign _e_5899 = \acc  + prod_n1;
    assign _e_5898 = _e_5899[31:0];
    assign _e_5897 = {1'd1, _e_5898};
    assign _e_9642 = \trig [32] == 1'd0;
    assign _e_5903 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9640, _e_9642})
            2'b1?: _e_5887 = _e_5897;
            2'b01: _e_5887 = _e_5903;
            2'b?: _e_5887 = 33'dx;
        endcase
    end
    assign _e_5881 = \clr  ? _e_5884 : _e_5887;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_5879;
        end
        else begin
            \res  <= _e_5881;
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
    logic[42:0] _e_5909;
    (* src = "src/mac.spade:68,14" *)
    logic[31:0] \x ;
    logic _e_9644;
    logic _e_9646;
    logic _e_9648;
    logic _e_9649;
    (* src = "src/mac.spade:68,35" *)
    logic[32:0] _e_5911;
    (* src = "src/mac.spade:69,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:70,13" *)
    logic[42:0] _e_5917;
    (* src = "src/mac.spade:70,18" *)
    logic[31:0] x_n1;
    logic _e_9652;
    logic _e_9654;
    logic _e_9656;
    logic _e_9657;
    (* src = "src/mac.spade:70,39" *)
    logic[32:0] _e_5919;
    (* src = "src/mac.spade:71,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:71,18" *)
    logic[32:0] _e_5922;
    (* src = "src/mac.spade:69,14" *)
    logic[32:0] _e_5914;
    (* src = "src/mac.spade:67,5" *)
    logic[32:0] _e_5906;
    assign _e_5909 = \m1 [42:0];
    assign \x  = _e_5909[36:5];
    assign _e_9644 = \m1 [43] == 1'd1;
    assign _e_9646 = _e_5909[42:37] == 6'd24;
    localparam[0:0] _e_9647 = 1;
    assign _e_9648 = _e_9646 && _e_9647;
    assign _e_9649 = _e_9644 && _e_9648;
    assign _e_5911 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9650 = 1;
    assign _e_5917 = \m0 [42:0];
    assign x_n1 = _e_5917[36:5];
    assign _e_9652 = \m0 [43] == 1'd1;
    assign _e_9654 = _e_5917[42:37] == 6'd24;
    localparam[0:0] _e_9655 = 1;
    assign _e_9656 = _e_9654 && _e_9655;
    assign _e_9657 = _e_9652 && _e_9656;
    assign _e_5919 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9658 = 1;
    assign _e_5922 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9657, _e_9658})
            2'b1?: _e_5914 = _e_5919;
            2'b01: _e_5914 = _e_5922;
            2'b?: _e_5914 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9649, _e_9650})
            2'b1?: _e_5906 = _e_5911;
            2'b01: _e_5906 = _e_5914;
            2'b?: _e_5906 = 33'dx;
        endcase
    end
    assign output__ = _e_5906;
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
    logic[42:0] _e_5927;
    (* src = "src/mac.spade:78,14" *)
    logic[31:0] \x ;
    logic _e_9660;
    logic _e_9662;
    logic _e_9664;
    logic _e_9665;
    (* src = "src/mac.spade:78,35" *)
    logic[32:0] _e_5929;
    (* src = "src/mac.spade:79,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:80,13" *)
    logic[42:0] _e_5935;
    (* src = "src/mac.spade:80,18" *)
    logic[31:0] x_n1;
    logic _e_9668;
    logic _e_9670;
    logic _e_9672;
    logic _e_9673;
    (* src = "src/mac.spade:80,39" *)
    logic[32:0] _e_5937;
    (* src = "src/mac.spade:81,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:81,18" *)
    logic[32:0] _e_5940;
    (* src = "src/mac.spade:79,14" *)
    logic[32:0] _e_5932;
    (* src = "src/mac.spade:77,5" *)
    logic[32:0] _e_5924;
    assign _e_5927 = \m1 [42:0];
    assign \x  = _e_5927[36:5];
    assign _e_9660 = \m1 [43] == 1'd1;
    assign _e_9662 = _e_5927[42:37] == 6'd25;
    localparam[0:0] _e_9663 = 1;
    assign _e_9664 = _e_9662 && _e_9663;
    assign _e_9665 = _e_9660 && _e_9664;
    assign _e_5929 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9666 = 1;
    assign _e_5935 = \m0 [42:0];
    assign x_n1 = _e_5935[36:5];
    assign _e_9668 = \m0 [43] == 1'd1;
    assign _e_9670 = _e_5935[42:37] == 6'd25;
    localparam[0:0] _e_9671 = 1;
    assign _e_9672 = _e_9670 && _e_9671;
    assign _e_9673 = _e_9668 && _e_9672;
    assign _e_5937 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9674 = 1;
    assign _e_5940 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9673, _e_9674})
            2'b1?: _e_5932 = _e_5937;
            2'b01: _e_5932 = _e_5940;
            2'b?: _e_5932 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9665, _e_9666})
            2'b1?: _e_5924 = _e_5929;
            2'b01: _e_5924 = _e_5932;
            2'b?: _e_5924 = 33'dx;
        endcase
    end
    assign output__ = _e_5924;
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
    logic[42:0] _e_5945;
    (* src = "src/mac.spade:88,14" *)
    logic \x ;
    logic _e_9676;
    logic _e_9678;
    logic _e_9680;
    logic _e_9681;
    (* src = "src/mac.spade:89,9" *)
    logic[43:0] \_ ;
    (* src = "src/mac.spade:90,13" *)
    logic[42:0] _e_5952;
    (* src = "src/mac.spade:90,18" *)
    logic x_n1;
    logic _e_9684;
    logic _e_9686;
    logic _e_9688;
    logic _e_9689;
    (* src = "src/mac.spade:91,13" *)
    logic[43:0] __n1;
    (* src = "src/mac.spade:89,14" *)
    logic _e_5949;
    (* src = "src/mac.spade:87,5" *)
    logic _e_5942;
    assign _e_5945 = \m1 [42:0];
    assign \x  = _e_5945[36:36];
    assign _e_9676 = \m1 [43] == 1'd1;
    assign _e_9678 = _e_5945[42:37] == 6'd26;
    localparam[0:0] _e_9679 = 1;
    assign _e_9680 = _e_9678 && _e_9679;
    assign _e_9681 = _e_9676 && _e_9680;
    assign \_  = \m1 ;
    localparam[0:0] _e_9682 = 1;
    assign _e_5952 = \m0 [42:0];
    assign x_n1 = _e_5952[36:36];
    assign _e_9684 = \m0 [43] == 1'd1;
    assign _e_9686 = _e_5952[42:37] == 6'd26;
    localparam[0:0] _e_9687 = 1;
    assign _e_9688 = _e_9686 && _e_9687;
    assign _e_9689 = _e_9684 && _e_9688;
    assign __n1 = \m0 ;
    localparam[0:0] _e_9690 = 1;
    localparam[0:0] _e_5956 = 0;
    always_comb begin
        priority casez ({_e_9689, _e_9690})
            2'b1?: _e_5949 = x_n1;
            2'b01: _e_5949 = _e_5956;
            2'b?: _e_5949 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9681, _e_9682})
            2'b1?: _e_5942 = \x ;
            2'b01: _e_5942 = _e_5949;
            2'b?: _e_5942 = 1'dx;
        endcase
    end
    assign output__ = _e_5942;
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
    logic[34:0] _e_5962;
    (* src = "src/cmpz.spade:28,14" *)
    logic[2:0] _e_5960;
    (* src = "src/cmpz.spade:28,14" *)
    logic[31:0] \b ;
    logic _e_9692;
    logic _e_9695;
    logic _e_9697;
    logic _e_9698;
    (* src = "src/cmpz.spade:28,47" *)
    logic _e_5966;
    (* src = "src/cmpz.spade:28,40" *)
    logic[31:0] _e_5965;
    (* src = "src/cmpz.spade:28,35" *)
    logic[32:0] _e_5964;
    (* src = "src/cmpz.spade:29,9" *)
    logic[34:0] _e_5971;
    (* src = "src/cmpz.spade:29,14" *)
    logic[2:0] _e_5969;
    (* src = "src/cmpz.spade:29,14" *)
    logic[31:0] b_n1;
    logic _e_9700;
    logic _e_9703;
    logic _e_9705;
    logic _e_9706;
    (* src = "src/cmpz.spade:29,48" *)
    logic _e_5975;
    (* src = "src/cmpz.spade:29,41" *)
    logic[31:0] _e_5974;
    (* src = "src/cmpz.spade:29,36" *)
    logic[32:0] _e_5973;
    (* src = "src/cmpz.spade:30,9" *)
    logic[34:0] _e_5980;
    (* src = "src/cmpz.spade:30,14" *)
    logic[2:0] _e_5978;
    (* src = "src/cmpz.spade:30,14" *)
    logic[31:0] b_n2;
    logic _e_9708;
    logic _e_9711;
    logic _e_9713;
    logic _e_9714;
    (* src = "src/cmpz.spade:30,48" *)
    logic _e_5985;
    (* src = "src/cmpz.spade:30,48" *)
    logic _e_5984;
    (* src = "src/cmpz.spade:30,41" *)
    logic[31:0] _e_5983;
    (* src = "src/cmpz.spade:30,36" *)
    logic[32:0] _e_5982;
    (* src = "src/cmpz.spade:31,9" *)
    logic[34:0] _e_5990;
    (* src = "src/cmpz.spade:31,14" *)
    logic[2:0] _e_5988;
    (* src = "src/cmpz.spade:31,14" *)
    logic[31:0] b_n3;
    logic _e_9716;
    logic _e_9719;
    logic _e_9721;
    logic _e_9722;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_5996;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_5995;
    (* src = "src/cmpz.spade:31,67" *)
    logic _e_5999;
    (* src = "src/cmpz.spade:31,49" *)
    logic _e_5994;
    (* src = "src/cmpz.spade:31,42" *)
    logic[31:0] _e_5993;
    (* src = "src/cmpz.spade:31,37" *)
    logic[32:0] _e_5992;
    (* src = "src/cmpz.spade:32,9" *)
    logic[34:0] _e_6004;
    (* src = "src/cmpz.spade:32,14" *)
    logic[2:0] _e_6002;
    (* src = "src/cmpz.spade:32,14" *)
    logic[31:0] b_n4;
    logic _e_9724;
    logic _e_9727;
    logic _e_9729;
    logic _e_9730;
    (* src = "src/cmpz.spade:32,48" *)
    logic _e_6010;
    (* src = "src/cmpz.spade:32,48" *)
    logic _e_6009;
    (* src = "src/cmpz.spade:32,66" *)
    logic _e_6013;
    (* src = "src/cmpz.spade:32,48" *)
    logic _e_6008;
    (* src = "src/cmpz.spade:32,41" *)
    logic[31:0] _e_6007;
    (* src = "src/cmpz.spade:32,36" *)
    logic[32:0] _e_6006;
    (* src = "src/cmpz.spade:33,9" *)
    logic[34:0] _e_6018;
    (* src = "src/cmpz.spade:33,14" *)
    logic[2:0] _e_6016;
    (* src = "src/cmpz.spade:33,14" *)
    logic[31:0] b_n5;
    logic _e_9732;
    logic _e_9735;
    logic _e_9737;
    logic _e_9738;
    (* src = "src/cmpz.spade:33,48" *)
    logic _e_6023;
    (* src = "src/cmpz.spade:33,48" *)
    logic _e_6022;
    (* src = "src/cmpz.spade:33,41" *)
    logic[31:0] _e_6021;
    (* src = "src/cmpz.spade:33,36" *)
    logic[32:0] _e_6020;
    logic _e_9740;
    (* src = "src/cmpz.spade:34,34" *)
    logic[32:0] _e_6027;
    (* src = "src/cmpz.spade:27,36" *)
    logic[32:0] \result ;
    (* src = "src/cmpz.spade:38,51" *)
    logic[32:0] _e_6032;
    (* src = "src/cmpz.spade:38,14" *)
    reg[32:0] \res_reg ;
    assign _e_5962 = \trig [34:0];
    assign _e_5960 = _e_5962[34:32];
    assign \b  = _e_5962[31:0];
    assign _e_9692 = \trig [35] == 1'd1;
    assign _e_9695 = _e_5960[2:0] == 3'd0;
    localparam[0:0] _e_9696 = 1;
    assign _e_9697 = _e_9695 && _e_9696;
    assign _e_9698 = _e_9692 && _e_9697;
    localparam[31:0] _e_5968 = 32'd0;
    assign _e_5966 = \b  == _e_5968;
    (* src = "src/cmpz.spade:28,40" *)
    \tta::cmpz::to_u32  to_u32_0(.x_i(_e_5966), .output__(_e_5965));
    assign _e_5964 = {1'd1, _e_5965};
    assign _e_5971 = \trig [34:0];
    assign _e_5969 = _e_5971[34:32];
    assign b_n1 = _e_5971[31:0];
    assign _e_9700 = \trig [35] == 1'd1;
    assign _e_9703 = _e_5969[2:0] == 3'd1;
    localparam[0:0] _e_9704 = 1;
    assign _e_9705 = _e_9703 && _e_9704;
    assign _e_9706 = _e_9700 && _e_9705;
    localparam[31:0] _e_5977 = 32'd0;
    assign _e_5975 = b_n1 != _e_5977;
    (* src = "src/cmpz.spade:29,41" *)
    \tta::cmpz::to_u32  to_u32_1(.x_i(_e_5975), .output__(_e_5974));
    assign _e_5973 = {1'd1, _e_5974};
    assign _e_5980 = \trig [34:0];
    assign _e_5978 = _e_5980[34:32];
    assign b_n2 = _e_5980[31:0];
    assign _e_9708 = \trig [35] == 1'd1;
    assign _e_9711 = _e_5978[2:0] == 3'd2;
    localparam[0:0] _e_9712 = 1;
    assign _e_9713 = _e_9711 && _e_9712;
    assign _e_9714 = _e_9708 && _e_9713;
    (* src = "src/cmpz.spade:30,48" *)
    \tta::cmpz::msb1  msb1_0(.x_i(b_n2), .output__(_e_5985));
    localparam[0:0] _e_5987 = 1;
    assign _e_5984 = _e_5985 == _e_5987;
    (* src = "src/cmpz.spade:30,41" *)
    \tta::cmpz::to_u32  to_u32_2(.x_i(_e_5984), .output__(_e_5983));
    assign _e_5982 = {1'd1, _e_5983};
    assign _e_5990 = \trig [34:0];
    assign _e_5988 = _e_5990[34:32];
    assign b_n3 = _e_5990[31:0];
    assign _e_9716 = \trig [35] == 1'd1;
    assign _e_9719 = _e_5988[2:0] == 3'd3;
    localparam[0:0] _e_9720 = 1;
    assign _e_9721 = _e_9719 && _e_9720;
    assign _e_9722 = _e_9716 && _e_9721;
    (* src = "src/cmpz.spade:31,49" *)
    \tta::cmpz::msb1  msb1_1(.x_i(b_n3), .output__(_e_5996));
    localparam[0:0] _e_5998 = 1;
    assign _e_5995 = _e_5996 == _e_5998;
    localparam[31:0] _e_6001 = 32'd0;
    assign _e_5999 = b_n3 == _e_6001;
    assign _e_5994 = _e_5995 || _e_5999;
    (* src = "src/cmpz.spade:31,42" *)
    \tta::cmpz::to_u32  to_u32_3(.x_i(_e_5994), .output__(_e_5993));
    assign _e_5992 = {1'd1, _e_5993};
    assign _e_6004 = \trig [34:0];
    assign _e_6002 = _e_6004[34:32];
    assign b_n4 = _e_6004[31:0];
    assign _e_9724 = \trig [35] == 1'd1;
    assign _e_9727 = _e_6002[2:0] == 3'd4;
    localparam[0:0] _e_9728 = 1;
    assign _e_9729 = _e_9727 && _e_9728;
    assign _e_9730 = _e_9724 && _e_9729;
    (* src = "src/cmpz.spade:32,48" *)
    \tta::cmpz::msb1  msb1_2(.x_i(b_n4), .output__(_e_6010));
    localparam[0:0] _e_6012 = 1;
    assign _e_6009 = _e_6010 != _e_6012;
    localparam[31:0] _e_6015 = 32'd0;
    assign _e_6013 = b_n4 != _e_6015;
    assign _e_6008 = _e_6009 && _e_6013;
    (* src = "src/cmpz.spade:32,41" *)
    \tta::cmpz::to_u32  to_u32_4(.x_i(_e_6008), .output__(_e_6007));
    assign _e_6006 = {1'd1, _e_6007};
    assign _e_6018 = \trig [34:0];
    assign _e_6016 = _e_6018[34:32];
    assign b_n5 = _e_6018[31:0];
    assign _e_9732 = \trig [35] == 1'd1;
    assign _e_9735 = _e_6016[2:0] == 3'd5;
    localparam[0:0] _e_9736 = 1;
    assign _e_9737 = _e_9735 && _e_9736;
    assign _e_9738 = _e_9732 && _e_9737;
    (* src = "src/cmpz.spade:33,48" *)
    \tta::cmpz::msb1  msb1_3(.x_i(b_n5), .output__(_e_6023));
    localparam[0:0] _e_6025 = 1;
    assign _e_6022 = _e_6023 != _e_6025;
    (* src = "src/cmpz.spade:33,41" *)
    \tta::cmpz::to_u32  to_u32_5(.x_i(_e_6022), .output__(_e_6021));
    assign _e_6020 = {1'd1, _e_6021};
    assign _e_9740 = \trig [35] == 1'd0;
    assign _e_6027 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9698, _e_9706, _e_9714, _e_9722, _e_9730, _e_9738, _e_9740})
            7'b1??????: \result  = _e_5964;
            7'b01?????: \result  = _e_5973;
            7'b001????: \result  = _e_5982;
            7'b0001???: \result  = _e_5992;
            7'b00001??: \result  = _e_6006;
            7'b000001?: \result  = _e_6020;
            7'b0000001: \result  = _e_6027;
            7'b?: \result  = 33'dx;
        endcase
    end
    assign _e_6032 = {1'd0, 32'bX};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res_reg  <= _e_6032;
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
    logic[42:0] _e_6040;
    (* src = "src/cmpz.spade:44,14" *)
    logic[2:0] \op ;
    (* src = "src/cmpz.spade:44,14" *)
    logic[31:0] \x ;
    logic _e_9742;
    logic _e_9744;
    logic _e_9747;
    logic _e_9748;
    logic _e_9749;
    (* src = "src/cmpz.spade:44,45" *)
    logic[34:0] _e_6043;
    (* src = "src/cmpz.spade:44,40" *)
    logic[35:0] _e_6042;
    (* src = "src/cmpz.spade:45,9" *)
    logic[43:0] \_ ;
    (* src = "src/cmpz.spade:46,13" *)
    logic[42:0] _e_6051;
    (* src = "src/cmpz.spade:46,18" *)
    logic[2:0] op_n1;
    (* src = "src/cmpz.spade:46,18" *)
    logic[31:0] x_n1;
    logic _e_9752;
    logic _e_9754;
    logic _e_9757;
    logic _e_9758;
    logic _e_9759;
    (* src = "src/cmpz.spade:46,49" *)
    logic[34:0] _e_6054;
    (* src = "src/cmpz.spade:46,44" *)
    logic[35:0] _e_6053;
    (* src = "src/cmpz.spade:47,13" *)
    logic[43:0] __n1;
    (* src = "src/cmpz.spade:47,18" *)
    logic[35:0] _e_6058;
    (* src = "src/cmpz.spade:45,14" *)
    logic[35:0] _e_6047;
    (* src = "src/cmpz.spade:43,5" *)
    logic[35:0] _e_6036;
    assign _e_6040 = \m1 [42:0];
    assign \op  = _e_6040[36:34];
    assign \x  = _e_6040[33:2];
    assign _e_9742 = \m1 [43] == 1'd1;
    assign _e_9744 = _e_6040[42:37] == 6'd13;
    localparam[0:0] _e_9745 = 1;
    localparam[0:0] _e_9746 = 1;
    assign _e_9747 = _e_9744 && _e_9745;
    assign _e_9748 = _e_9747 && _e_9746;
    assign _e_9749 = _e_9742 && _e_9748;
    assign _e_6043 = {\op , \x };
    assign _e_6042 = {1'd1, _e_6043};
    assign \_  = \m1 ;
    localparam[0:0] _e_9750 = 1;
    assign _e_6051 = \m0 [42:0];
    assign op_n1 = _e_6051[36:34];
    assign x_n1 = _e_6051[33:2];
    assign _e_9752 = \m0 [43] == 1'd1;
    assign _e_9754 = _e_6051[42:37] == 6'd13;
    localparam[0:0] _e_9755 = 1;
    localparam[0:0] _e_9756 = 1;
    assign _e_9757 = _e_9754 && _e_9755;
    assign _e_9758 = _e_9757 && _e_9756;
    assign _e_9759 = _e_9752 && _e_9758;
    assign _e_6054 = {op_n1, x_n1};
    assign _e_6053 = {1'd1, _e_6054};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9760 = 1;
    assign _e_6058 = {1'd0, 35'bX};
    always_comb begin
        priority casez ({_e_9759, _e_9760})
            2'b1?: _e_6047 = _e_6053;
            2'b01: _e_6047 = _e_6058;
            2'b?: _e_6047 = 36'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9749, _e_9750})
            2'b1?: _e_6036 = _e_6042;
            2'b01: _e_6036 = _e_6047;
            2'b?: _e_6036 = 36'dx;
        endcase
    end
    assign output__ = _e_6036;
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
    logic[31:0] _e_6062;
    (* src = "src/cmpz.spade:52,41" *)
    logic[31:0] _e_6061;
    (* src = "src/cmpz.spade:52,35" *)
    logic _e_6060;
    localparam[31:0] _e_6064 = 32'd31;
    assign _e_6062 = \x  >> _e_6064;
    localparam[31:0] _e_6065 = 32'd1;
    assign _e_6061 = _e_6062 & _e_6065;
    assign _e_6060 = _e_6061[0:0];
    assign output__ = _e_6060;
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
    logic[31:0] _e_6067;
    localparam[31:0] _e_6070 = 32'd1;
    localparam[31:0] _e_6072 = 32'd0;
    assign _e_6067 = \x  ? _e_6070 : _e_6072;
    assign output__ = _e_6067;
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
    logic _e_6075;
    (* src = "src/div_shiftsub.spade:18,5" *)
    logic[134:0] _e_6074;
    assign _e_6075 = {1'd0};
    localparam[31:0] _e_6076 = 32'd0;
    localparam[31:0] _e_6077 = 32'd0;
    localparam[31:0] _e_6078 = 32'd0;
    localparam[31:0] _e_6079 = 32'd0;
    localparam[5:0] _e_6080 = 0;
    assign _e_6074 = {_e_6075, _e_6076, _e_6077, _e_6078, _e_6079, _e_6080};
    assign output__ = _e_6074;
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
    logic[134:0] _e_6085;
    (* src = "src/div_shiftsub.spade:28,57" *)
    logic _e_6087;
    (* src = "src/div_shiftsub.spade:29,9" *)
    logic _e_6089;
    logic _e_9762;
    (* src = "src/div_shiftsub.spade:32,17" *)
    logic[31:0] \val ;
    logic _e_9764;
    logic _e_9766;
    logic _e_9768;
    (* src = "src/div_shiftsub.spade:33,25" *)
    logic[31:0] _e_6097;
    (* src = "src/div_shiftsub.spade:31,33" *)
    logic[31:0] \next_dividend ;
    (* src = "src/div_shiftsub.spade:37,17" *)
    logic[31:0] \divisor ;
    logic _e_9770;
    logic _e_9772;
    (* src = "src/div_shiftsub.spade:37,42" *)
    logic _e_6105;
    (* src = "src/div_shiftsub.spade:37,34" *)
    logic[134:0] _e_6104;
    logic _e_9774;
    (* src = "src/div_shiftsub.spade:38,33" *)
    logic _e_6113;
    (* src = "src/div_shiftsub.spade:38,25" *)
    logic[134:0] _e_6112;
    (* src = "src/div_shiftsub.spade:36,13" *)
    logic[134:0] _e_6100;
    (* src = "src/div_shiftsub.spade:41,9" *)
    logic _e_6119;
    logic _e_9776;
    (* src = "src/div_shiftsub.spade:44,33" *)
    logic[31:0] _e_6122;
    (* src = "src/div_shiftsub.spade:44,32" *)
    logic[31:0] \msb_dividend ;
    (* src = "src/div_shiftsub.spade:45,32" *)
    logic[31:0] _e_6128;
    (* src = "src/div_shiftsub.spade:45,31" *)
    logic[31:0] _e_6127;
    (* src = "src/div_shiftsub.spade:45,31" *)
    logic[31:0] \rem_shifted ;
    (* src = "src/div_shiftsub.spade:46,31" *)
    logic[31:0] _e_6134;
    (* src = "src/div_shiftsub.spade:46,31" *)
    logic[31:0] \dvd_shifted ;
    (* src = "src/div_shiftsub.spade:49,42" *)
    logic[31:0] _e_6140;
    (* src = "src/div_shiftsub.spade:49,27" *)
    logic \can_sub ;
    (* src = "src/div_shiftsub.spade:53,38" *)
    logic[31:0] _e_6150;
    (* src = "src/div_shiftsub.spade:53,24" *)
    logic[32:0] _e_6148;
    (* src = "src/div_shiftsub.spade:53,18" *)
    logic[31:0] _e_6147;
    (* src = "src/div_shiftsub.spade:53,17" *)
    logic[63:0] _e_6146;
    (* src = "src/div_shiftsub.spade:55,17" *)
    logic[63:0] _e_6154;
    (* src = "src/div_shiftsub.spade:52,40" *)
    logic[63:0] _e_6159;
    (* src = "src/div_shiftsub.spade:52,17" *)
    logic[31:0] \next_rem ;
    (* src = "src/div_shiftsub.spade:52,17" *)
    logic[31:0] \quot_bit ;
    (* src = "src/div_shiftsub.spade:58,30" *)
    logic[31:0] _e_6162;
    (* src = "src/div_shiftsub.spade:58,29" *)
    logic[31:0] _e_6161;
    (* src = "src/div_shiftsub.spade:58,29" *)
    logic[31:0] \next_quot ;
    (* src = "src/div_shiftsub.spade:60,16" *)
    logic[5:0] _e_6169;
    (* src = "src/div_shiftsub.spade:60,16" *)
    logic _e_6168;
    (* src = "src/div_shiftsub.spade:62,17" *)
    logic[134:0] _e_6173;
    (* src = "src/div_shiftsub.spade:65,25" *)
    logic _e_6176;
    (* src = "src/div_shiftsub.spade:65,51" *)
    logic[31:0] _e_6178;
    (* src = "src/div_shiftsub.spade:65,89" *)
    logic[5:0] _e_6184;
    (* src = "src/div_shiftsub.spade:65,89" *)
    logic[6:0] _e_6183;
    (* src = "src/div_shiftsub.spade:65,83" *)
    logic[5:0] _e_6182;
    (* src = "src/div_shiftsub.spade:65,17" *)
    logic[134:0] _e_6175;
    (* src = "src/div_shiftsub.spade:60,13" *)
    logic[134:0] _e_6167;
    (* src = "src/div_shiftsub.spade:28,51" *)
    logic[134:0] _e_6086;
    (* src = "src/div_shiftsub.spade:28,14" *)
    reg[134:0] \r ;
    (* src = "src/div_shiftsub.spade:74,11" *)
    logic _e_6188;
    (* src = "src/div_shiftsub.spade:75,9" *)
    logic _e_6190;
    logic _e_9778;
    (* src = "src/div_shiftsub.spade:76,16" *)
    logic[5:0] _e_6194;
    (* src = "src/div_shiftsub.spade:76,16" *)
    logic _e_6193;
    (* src = "src/div_shiftsub.spade:78,37" *)
    logic[31:0] _e_6199;
    (* src = "src/div_shiftsub.spade:78,36" *)
    logic[31:0] msb_dividend_n1;
    (* src = "src/div_shiftsub.spade:79,36" *)
    logic[31:0] _e_6205;
    (* src = "src/div_shiftsub.spade:79,35" *)
    logic[31:0] _e_6204;
    (* src = "src/div_shiftsub.spade:79,35" *)
    logic[31:0] rem_shifted_n1;
    (* src = "src/div_shiftsub.spade:80,46" *)
    logic[31:0] _e_6212;
    (* src = "src/div_shiftsub.spade:80,31" *)
    logic can_sub_n1;
    (* src = "src/div_shiftsub.spade:81,32" *)
    logic[31:0] quot_bit_n1;
    (* src = "src/div_shiftsub.spade:83,23" *)
    logic[31:0] _e_6225;
    (* src = "src/div_shiftsub.spade:83,22" *)
    logic[31:0] _e_6224;
    (* src = "src/div_shiftsub.spade:83,22" *)
    logic[31:0] _e_6223;
    (* src = "src/div_shiftsub.spade:83,17" *)
    logic[32:0] _e_6222;
    (* src = "src/div_shiftsub.spade:85,17" *)
    logic[32:0] _e_6230;
    (* src = "src/div_shiftsub.spade:76,13" *)
    logic[32:0] _e_6192;
    (* src = "src/div_shiftsub.spade:88,9" *)
    logic \_ ;
    (* src = "src/div_shiftsub.spade:88,14" *)
    logic[32:0] _e_6232;
    (* src = "src/div_shiftsub.spade:74,5" *)
    logic[32:0] _e_6187;
    (* src = "src/div_shiftsub.spade:28,36" *)
    \tta::div_shiftsub::reset_div  reset_div_0(.output__(_e_6085));
    assign _e_6087 = \r [134];
    assign _e_6089 = _e_6087;
    assign _e_9762 = _e_6087 == 1'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9764 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9765 = 1;
    assign _e_9766 = _e_9764 && _e_9765;
    assign _e_9768 = \set_op_a [32] == 1'd0;
    assign _e_6097 = \r [133:102];
    always_comb begin
        priority casez ({_e_9766, _e_9768})
            2'b1?: \next_dividend  = \val ;
            2'b01: \next_dividend  = _e_6097;
            2'b?: \next_dividend  = 32'dx;
        endcase
    end
    assign \divisor  = \trig [31:0];
    assign _e_9770 = \trig [32] == 1'd1;
    localparam[0:0] _e_9771 = 1;
    assign _e_9772 = _e_9770 && _e_9771;
    assign _e_6105 = {1'd1};
    localparam[31:0] _e_6108 = 32'd0;
    localparam[31:0] _e_6109 = 32'd0;
    localparam[5:0] _e_6110 = 0;
    assign _e_6104 = {_e_6105, \next_dividend , \divisor , _e_6108, _e_6109, _e_6110};
    assign _e_9774 = \trig [32] == 1'd0;
    assign _e_6113 = {1'd0};
    localparam[31:0] _e_6115 = 32'd0;
    localparam[31:0] _e_6116 = 32'd0;
    localparam[31:0] _e_6117 = 32'd0;
    localparam[5:0] _e_6118 = 0;
    assign _e_6112 = {_e_6113, \next_dividend , _e_6115, _e_6116, _e_6117, _e_6118};
    always_comb begin
        priority casez ({_e_9772, _e_9774})
            2'b1?: _e_6100 = _e_6104;
            2'b01: _e_6100 = _e_6112;
            2'b?: _e_6100 = 135'dx;
        endcase
    end
    assign _e_6119 = _e_6087;
    assign _e_9776 = _e_6087 == 1'd1;
    assign _e_6122 = \r [133:102];
    localparam[31:0] _e_6124 = 32'd31;
    assign \msb_dividend  = _e_6122 >> _e_6124;
    assign _e_6128 = \r [69:38];
    localparam[31:0] _e_6130 = 32'd1;
    assign _e_6127 = _e_6128 << _e_6130;
    assign \rem_shifted  = _e_6127 | \msb_dividend ;
    assign _e_6134 = \r [133:102];
    localparam[31:0] _e_6136 = 32'd1;
    assign \dvd_shifted  = _e_6134 << _e_6136;
    assign _e_6140 = \r [101:70];
    assign \can_sub  = \rem_shifted  >= _e_6140;
    assign _e_6150 = \r [101:70];
    assign _e_6148 = \rem_shifted  - _e_6150;
    assign _e_6147 = _e_6148[31:0];
    localparam[31:0] _e_6152 = 32'd1;
    assign _e_6146 = {_e_6147, _e_6152};
    localparam[31:0] _e_6156 = 32'd0;
    assign _e_6154 = {\rem_shifted , _e_6156};
    assign _e_6159 = \can_sub  ? _e_6146 : _e_6154;
    assign \next_rem  = _e_6159[63:32];
    assign \quot_bit  = _e_6159[31:0];
    assign _e_6162 = \r [37:6];
    localparam[31:0] _e_6164 = 32'd1;
    assign _e_6161 = _e_6162 << _e_6164;
    assign \next_quot  = _e_6161 | \quot_bit ;
    assign _e_6169 = \r [5:0];
    localparam[5:0] _e_6171 = 31;
    assign _e_6168 = _e_6169 == _e_6171;
    (* src = "src/div_shiftsub.spade:62,17" *)
    \tta::div_shiftsub::reset_div  reset_div_1(.output__(_e_6173));
    assign _e_6176 = {1'd1};
    assign _e_6178 = \r [101:70];
    assign _e_6184 = \r [5:0];
    localparam[5:0] _e_6186 = 1;
    assign _e_6183 = _e_6184 + _e_6186;
    assign _e_6182 = _e_6183[5:0];
    assign _e_6175 = {_e_6176, \dvd_shifted , _e_6178, \next_rem , \next_quot , _e_6182};
    assign _e_6167 = _e_6168 ? _e_6173 : _e_6175;
    always_comb begin
        priority casez ({_e_9762, _e_9776})
            2'b1?: _e_6086 = _e_6100;
            2'b01: _e_6086 = _e_6167;
            2'b?: _e_6086 = 135'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_6085;
        end
        else begin
            \r  <= _e_6086;
        end
    end
    assign _e_6188 = \r [134];
    assign _e_6190 = _e_6188;
    assign _e_9778 = _e_6188 == 1'd1;
    assign _e_6194 = \r [5:0];
    localparam[5:0] _e_6196 = 31;
    assign _e_6193 = _e_6194 == _e_6196;
    assign _e_6199 = \r [133:102];
    localparam[31:0] _e_6201 = 32'd31;
    assign msb_dividend_n1 = _e_6199 >> _e_6201;
    assign _e_6205 = \r [69:38];
    localparam[31:0] _e_6207 = 32'd1;
    assign _e_6204 = _e_6205 << _e_6207;
    assign rem_shifted_n1 = _e_6204 | msb_dividend_n1;
    assign _e_6212 = \r [101:70];
    assign can_sub_n1 = rem_shifted_n1 >= _e_6212;
    localparam[31:0] _e_6218 = 32'd1;
    localparam[31:0] _e_6220 = 32'd0;
    assign quot_bit_n1 = can_sub_n1 ? _e_6218 : _e_6220;
    assign _e_6225 = \r [37:6];
    localparam[31:0] _e_6227 = 32'd1;
    assign _e_6224 = _e_6225 << _e_6227;
    assign _e_6223 = _e_6224 | quot_bit_n1;
    assign _e_6222 = {1'd1, _e_6223};
    assign _e_6230 = {1'd0, 32'bX};
    assign _e_6192 = _e_6193 ? _e_6222 : _e_6230;
    assign \_  = _e_6188;
    localparam[0:0] _e_9779 = 1;
    assign _e_6232 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9778, _e_9779})
            2'b1?: _e_6187 = _e_6192;
            2'b01: _e_6187 = _e_6232;
            2'b?: _e_6187 = 33'dx;
        endcase
    end
    assign output__ = _e_6187;
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
    logic[42:0] _e_6237;
    (* src = "src/div_shiftsub.spade:94,10" *)
    logic[31:0] \x ;
    logic _e_9781;
    logic _e_9783;
    logic _e_9785;
    logic _e_9786;
    (* src = "src/div_shiftsub.spade:94,31" *)
    logic[32:0] _e_6239;
    (* src = "src/div_shiftsub.spade:95,5" *)
    logic[43:0] \_ ;
    (* src = "src/div_shiftsub.spade:95,21" *)
    logic[42:0] _e_6245;
    (* src = "src/div_shiftsub.spade:95,26" *)
    logic[31:0] x_n1;
    logic _e_9789;
    logic _e_9791;
    logic _e_9793;
    logic _e_9794;
    (* src = "src/div_shiftsub.spade:95,47" *)
    logic[32:0] _e_6247;
    (* src = "src/div_shiftsub.spade:95,56" *)
    logic[43:0] __n1;
    (* src = "src/div_shiftsub.spade:95,61" *)
    logic[32:0] _e_6250;
    (* src = "src/div_shiftsub.spade:95,10" *)
    logic[32:0] _e_6242;
    (* src = "src/div_shiftsub.spade:93,3" *)
    logic[32:0] _e_6234;
    assign _e_6237 = \m1 [42:0];
    assign \x  = _e_6237[36:5];
    assign _e_9781 = \m1 [43] == 1'd1;
    assign _e_9783 = _e_6237[42:37] == 6'd21;
    localparam[0:0] _e_9784 = 1;
    assign _e_9785 = _e_9783 && _e_9784;
    assign _e_9786 = _e_9781 && _e_9785;
    assign _e_6239 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9787 = 1;
    assign _e_6245 = \m0 [42:0];
    assign x_n1 = _e_6245[36:5];
    assign _e_9789 = \m0 [43] == 1'd1;
    assign _e_9791 = _e_6245[42:37] == 6'd21;
    localparam[0:0] _e_9792 = 1;
    assign _e_9793 = _e_9791 && _e_9792;
    assign _e_9794 = _e_9789 && _e_9793;
    assign _e_6247 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9795 = 1;
    assign _e_6250 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9794, _e_9795})
            2'b1?: _e_6242 = _e_6247;
            2'b01: _e_6242 = _e_6250;
            2'b?: _e_6242 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9786, _e_9787})
            2'b1?: _e_6234 = _e_6239;
            2'b01: _e_6234 = _e_6242;
            2'b?: _e_6234 = 33'dx;
        endcase
    end
    assign output__ = _e_6234;
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
    logic[42:0] _e_6255;
    (* src = "src/div_shiftsub.spade:101,10" *)
    logic[31:0] \x ;
    logic _e_9797;
    logic _e_9799;
    logic _e_9801;
    logic _e_9802;
    (* src = "src/div_shiftsub.spade:101,31" *)
    logic[32:0] _e_6257;
    (* src = "src/div_shiftsub.spade:102,5" *)
    logic[43:0] \_ ;
    (* src = "src/div_shiftsub.spade:102,21" *)
    logic[42:0] _e_6263;
    (* src = "src/div_shiftsub.spade:102,26" *)
    logic[31:0] x_n1;
    logic _e_9805;
    logic _e_9807;
    logic _e_9809;
    logic _e_9810;
    (* src = "src/div_shiftsub.spade:102,47" *)
    logic[32:0] _e_6265;
    (* src = "src/div_shiftsub.spade:102,56" *)
    logic[43:0] __n1;
    (* src = "src/div_shiftsub.spade:102,61" *)
    logic[32:0] _e_6268;
    (* src = "src/div_shiftsub.spade:102,10" *)
    logic[32:0] _e_6260;
    (* src = "src/div_shiftsub.spade:100,3" *)
    logic[32:0] _e_6252;
    assign _e_6255 = \m1 [42:0];
    assign \x  = _e_6255[36:5];
    assign _e_9797 = \m1 [43] == 1'd1;
    assign _e_9799 = _e_6255[42:37] == 6'd22;
    localparam[0:0] _e_9800 = 1;
    assign _e_9801 = _e_9799 && _e_9800;
    assign _e_9802 = _e_9797 && _e_9801;
    assign _e_6257 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9803 = 1;
    assign _e_6263 = \m0 [42:0];
    assign x_n1 = _e_6263[36:5];
    assign _e_9805 = \m0 [43] == 1'd1;
    assign _e_9807 = _e_6263[42:37] == 6'd22;
    localparam[0:0] _e_9808 = 1;
    assign _e_9809 = _e_9807 && _e_9808;
    assign _e_9810 = _e_9805 && _e_9809;
    assign _e_6265 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9811 = 1;
    assign _e_6268 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9810, _e_9811})
            2'b1?: _e_6260 = _e_6265;
            2'b01: _e_6260 = _e_6268;
            2'b?: _e_6260 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9802, _e_9803})
            2'b1?: _e_6252 = _e_6257;
            2'b01: _e_6252 = _e_6260;
            2'b?: _e_6252 = 33'dx;
        endcase
    end
    assign output__ = _e_6252;
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
    logic _e_9813;
    logic _e_9815;
    (* src = "src/boot_imem_subsystem.spade:34,18" *)
    logic[8:0] _e_6274;
    logic _e_9817;
    (* src = "src/boot_imem_subsystem.spade:35,18" *)
    logic[8:0] _e_6278;
    (* src = "src/boot_imem_subsystem.spade:33,5" *)
    logic[8:0] _e_6283;
    (* src = "src/boot_imem_subsystem.spade:32,7" *)
    logic \byte_valid ;
    (* src = "src/boot_imem_subsystem.spade:32,7" *)
    logic[7:0] \byte ;
    (* src = "src/boot_imem_subsystem.spade:40,12" *)
    logic[88:0] \bl ;
    (* src = "src/boot_imem_subsystem.spade:49,25" *)
    logic _e_6292;
    (* src = "src/boot_imem_subsystem.spade:49,18" *)
    logic \core_rst ;
    (* src = "src/boot_imem_subsystem.spade:52,43" *)
    logic _e_6299;
    (* src = "src/boot_imem_subsystem.spade:52,12" *)
    reg \boot_q ;
    (* src = "src/boot_imem_subsystem.spade:53,36" *)
    logic _e_6304;
    (* src = "src/boot_imem_subsystem.spade:53,35" *)
    logic _e_6303;
    (* src = "src/boot_imem_subsystem.spade:53,25" *)
    logic \boot_fall ;
    (* src = "src/boot_imem_subsystem.spade:56,23" *)
    logic[10:0] _e_6310;
    (* src = "src/boot_imem_subsystem.spade:56,11" *)
    logic[11:0] _e_6308;
    (* src = "src/boot_imem_subsystem.spade:57,7" *)
    logic[11:0] _e_6315;
    (* src = "src/boot_imem_subsystem.spade:57,7" *)
    logic _e_6312;
    (* src = "src/boot_imem_subsystem.spade:57,7" *)
    logic[10:0] _e_6314;
    (* src = "src/boot_imem_subsystem.spade:57,14" *)
    logic[9:0] \e ;
    logic _e_9821;
    logic _e_9823;
    logic _e_9824;
    (* src = "src/boot_imem_subsystem.spade:57,26" *)
    logic[10:0] _e_6316;
    (* src = "src/boot_imem_subsystem.spade:58,7" *)
    logic[11:0] \_ ;
    (* src = "src/boot_imem_subsystem.spade:58,27" *)
    logic[10:0] _e_6319;
    (* src = "src/boot_imem_subsystem.spade:56,5" *)
    logic[10:0] \pc_release ;
    (* src = "src/boot_imem_subsystem.spade:66,13" *)
    logic[97:0] _e_6324;
    logic _e_9827;
    (* src = "src/boot_imem_subsystem.spade:72,11" *)
    logic[10:0] _e_6334;
    (* src = "src/boot_imem_subsystem.spade:72,23" *)
    logic[32:0] _e_6336;
    (* src = "src/boot_imem_subsystem.spade:72,36" *)
    logic[32:0] _e_6338;
    (* src = "src/boot_imem_subsystem.spade:68,13" *)
    logic[98:0] _e_6328;
    (* src = "src/boot_imem_subsystem.spade:74,11" *)
    logic[98:0] _e_6341;
    (* src = "src/boot_imem_subsystem.spade:74,11" *)
    logic[97:0] \v ;
    logic _e_9829;
    logic _e_9831;
    (* src = "src/boot_imem_subsystem.spade:75,11" *)
    logic[98:0] _e_6343;
    logic _e_9833;
    (* src = "src/boot_imem_subsystem.spade:75,19" *)
    logic[97:0] _e_6344;
    (* src = "src/boot_imem_subsystem.spade:68,7" *)
    logic[97:0] _e_6327;
    (* src = "src/boot_imem_subsystem.spade:65,15" *)
    logic[97:0] \instr ;
    (* src = "src/boot_imem_subsystem.spade:80,3" *)
    logic[109:0] _e_6346;
    assign \b  = \rx_opt [7:0];
    assign _e_9813 = \rx_opt [8] == 1'd1;
    localparam[0:0] _e_9814 = 1;
    assign _e_9815 = _e_9813 && _e_9814;
    localparam[0:0] _e_6275 = 1;
    assign _e_6274 = {_e_6275, \b };
    assign _e_9817 = \rx_opt [8] == 1'd0;
    localparam[0:0] _e_6279 = 0;
    localparam[7:0] _e_6280 = 0;
    assign _e_6278 = {_e_6279, _e_6280};
    always_comb begin
        priority casez ({_e_9815, _e_9817})
            2'b1?: _e_6283 = _e_6274;
            2'b01: _e_6283 = _e_6278;
            2'b?: _e_6283 = 9'dx;
        endcase
    end
    assign \byte_valid  = _e_6283[8];
    assign \byte  = _e_6283[7:0];
    (* src = "src/boot_imem_subsystem.spade:40,12" *)
    \tta::bootloader::bootloader  bootloader_0(.clk_i(\clk ), .rst_i(\rst ), .byte_valid_i(\byte_valid ), .byte_i(\byte ), .output__(\bl ));
    assign _e_6292 = \bl [88];
    assign \core_rst  = \rst  || _e_6292;
    localparam[0:0] _e_6298 = 1;
    assign _e_6299 = \bl [88];
    always @(posedge \clk ) begin
        if (\rst ) begin
            \boot_q  <= _e_6298;
        end
        else begin
            \boot_q  <= _e_6299;
        end
    end
    assign _e_6304 = \bl [88];
    assign _e_6303 = !_e_6304;
    assign \boot_fall  = \boot_q  && _e_6303;
    assign _e_6310 = \bl [10:0];
    assign _e_6308 = {\boot_fall , _e_6310};
    assign _e_6315 = _e_6308;
    assign _e_6312 = _e_6308[11];
    assign _e_6314 = _e_6308[10:0];
    assign \e  = _e_6314[9:0];
    assign _e_9821 = _e_6314[10] == 1'd1;
    localparam[0:0] _e_9822 = 1;
    assign _e_9823 = _e_9821 && _e_9822;
    assign _e_9824 = _e_6312 && _e_9823;
    assign _e_6316 = {1'd1, \e };
    assign \_  = _e_6308;
    localparam[0:0] _e_9825 = 1;
    assign _e_6319 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_9824, _e_9825})
            2'b1?: \pc_release  = _e_6316;
            2'b01: \pc_release  = _e_6319;
            2'b?: \pc_release  = 11'dx;
        endcase
    end
    (* src = "src/boot_imem_subsystem.spade:66,13" *)
    \tta::boot_imem_subsystem::no_op  no_op_0(.output__(_e_6324));
    assign _e_9827 = !\boot_q ;
    assign _e_6334 = \bl [87:77];
    assign _e_6336 = \bl [76:44];
    assign _e_6338 = \bl [43:11];
    (* src = "src/boot_imem_subsystem.spade:68,13" *)
    \tta::imem::imem  imem_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .boot_mode_i(\boot_q ), .fetch_pc_i(\fetch_pc ), .wr_addr_i(_e_6334), .wr_slot0_i(_e_6336), .wr_slot1_i(_e_6338), .output__(_e_6328));
    assign _e_6341 = _e_6328;
    assign \v  = _e_6328[97:0];
    assign _e_9829 = _e_6328[98] == 1'd1;
    localparam[0:0] _e_9830 = 1;
    assign _e_9831 = _e_9829 && _e_9830;
    assign _e_6343 = _e_6328;
    assign _e_9833 = _e_6328[98] == 1'd0;
    (* src = "src/boot_imem_subsystem.spade:75,19" *)
    \tta::boot_imem_subsystem::no_op  no_op_1(.output__(_e_6344));
    always_comb begin
        priority casez ({_e_9831, _e_9833})
            2'b1?: _e_6327 = \v ;
            2'b01: _e_6327 = _e_6344;
            2'b?: _e_6327 = 98'dx;
        endcase
    end
    always_comb begin
        priority casez ({\boot_q , _e_9827})
            2'b1?: \instr  = _e_6324;
            2'b01: \instr  = _e_6327;
            2'b?: \instr  = 98'dx;
        endcase
    end
    assign _e_6346 = {\core_rst , \instr , \pc_release };
    assign output__ = _e_6346;
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
    logic[36:0] _e_6353;
    (* src = "src/boot_imem_subsystem.spade:86,27" *)
    logic[10:0] _e_6354;
    (* src = "src/boot_imem_subsystem.spade:86,11" *)
    logic[48:0] _e_6352;
    (* src = "src/boot_imem_subsystem.spade:87,16" *)
    logic[36:0] _e_6357;
    (* src = "src/boot_imem_subsystem.spade:87,27" *)
    logic[10:0] _e_6358;
    (* src = "src/boot_imem_subsystem.spade:87,11" *)
    logic[48:0] _e_6356;
    (* src = "src/boot_imem_subsystem.spade:85,3" *)
    logic[97:0] _e_6351;
    assign _e_6353 = {5'd6, 32'bX};
    assign _e_6354 = {7'd2, 4'bX};
    localparam[0:0] _e_6355 = 0;
    assign _e_6352 = {_e_6353, _e_6354, _e_6355};
    assign _e_6357 = {5'd6, 32'bX};
    assign _e_6358 = {7'd2, 4'bX};
    localparam[0:0] _e_6359 = 0;
    assign _e_6356 = {_e_6357, _e_6358, _e_6359};
    assign _e_6351 = {_e_6352, _e_6356};
    assign output__ = _e_6351;
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
    logic[32:0] _e_6364;
    (* src = "src/tanh.spade:18,9" *)
    logic[31:0] \val_32 ;
    logic _e_9835;
    logic _e_9837;
    (* src = "src/tanh.spade:21,37" *)
    logic[15:0] \val_u16 ;
    (* src = "src/tanh.spade:22,30" *)
    logic[15:0] \x ;
    (* src = "src/tanh.spade:26,33" *)
    logic[16:0] \x_17 ;
    (* src = "src/tanh.spade:27,26" *)
    logic \is_neg ;
    (* src = "src/tanh.spade:32,53" *)
    logic[16:0] _e_6388;
    (* src = "src/tanh.spade:32,49" *)
    logic[17:0] _e_6386;
    (* src = "src/tanh.spade:32,73" *)
    logic[17:0] _e_6391;
    (* src = "src/tanh.spade:32,37" *)
    logic[17:0] \abs_x_18 ;
    (* src = "src/tanh.spade:35,34" *)
    logic[16:0] \abs_x ;
    (* src = "src/tanh.spade:40,37" *)
    logic _e_6398;
    (* src = "src/tanh.spade:50,43" *)
    logic[16:0] _e_6405;
    (* src = "src/tanh.spade:50,38" *)
    logic[17:0] \term1 ;
    (* src = "src/tanh.spade:51,21" *)
    logic[17:0] \term2 ;
    (* src = "src/tanh.spade:52,23" *)
    logic[18:0] _e_6412;
    (* src = "src/tanh.spade:52,17" *)
    logic[16:0] _e_6411;
    (* src = "src/tanh.spade:40,34" *)
    logic[16:0] \abs_y ;
    (* src = "src/tanh.spade:58,49" *)
    logic[16:0] _e_6421;
    (* src = "src/tanh.spade:58,45" *)
    logic[17:0] _e_6419;
    (* src = "src/tanh.spade:58,70" *)
    logic[17:0] _e_6424;
    (* src = "src/tanh.spade:58,33" *)
    logic[17:0] \y_18 ;
    (* src = "src/tanh.spade:62,33" *)
    logic[15:0] \y_16 ;
    (* src = "src/tanh.spade:67,34" *)
    logic[31:0] \y_i32 ;
    (* src = "src/tanh.spade:68,18" *)
    logic[31:0] _e_6434;
    (* src = "src/tanh.spade:68,13" *)
    logic[32:0] _e_6433;
    logic _e_9839;
    (* src = "src/tanh.spade:70,17" *)
    logic[32:0] _e_6437;
    (* src = "src/tanh.spade:17,55" *)
    logic[32:0] _e_6365;
    (* src = "src/tanh.spade:17,14" *)
    reg[32:0] \res ;
    assign _e_6364 = {1'd0, 32'bX};
    assign \val_32  = \trig [31:0];
    assign _e_9835 = \trig [32] == 1'd1;
    localparam[0:0] _e_9836 = 1;
    assign _e_9837 = _e_9835 && _e_9836;
    assign \val_u16  = \val_32 [15:0];
    (* src = "src/tanh.spade:22,30" *)
    \std::conv::impl_4::to_int[2139]  to_int_0(.self_i(\val_u16 ), .output__(\x ));
    assign \x_17  = {\x [15], \x };
    localparam[16:0] _e_6381 = 0;
    assign \is_neg  = $signed(\x_17 ) < $signed(_e_6381);
    localparam[16:0] _e_6387 = 0;
    assign _e_6388 = \x_17 ;
    assign _e_6386 = $signed(_e_6387) - $signed(_e_6388);
    assign _e_6391 = {\x_17 [16], \x_17 };
    assign \abs_x_18  = \is_neg  ? _e_6386 : _e_6391;
    assign \abs_x  = \abs_x_18 [16:0];
    localparam[16:0] _e_6400 = 16384;
    assign _e_6398 = $signed(\abs_x ) < $signed(_e_6400);
    localparam[16:0] _e_6407 = 1;
    assign _e_6405 = \abs_x  >> _e_6407;
    assign \term1  = {_e_6405[16], _e_6405};
    localparam[17:0] _e_6409 = 8192;
    assign \term2  = _e_6409;
    assign _e_6412 = $signed(\term1 ) + $signed(\term2 );
    assign _e_6411 = _e_6412[16:0];
    assign \abs_y  = _e_6398 ? \abs_x  : _e_6411;
    localparam[16:0] _e_6420 = 0;
    assign _e_6421 = \abs_y ;
    assign _e_6419 = $signed(_e_6420) - $signed(_e_6421);
    assign _e_6424 = {\abs_y [16], \abs_y };
    assign \y_18  = \is_neg  ? _e_6419 : _e_6424;
    assign \y_16  = \y_18 [15:0];
    assign \y_i32  = {{ 16 { \y_16 [15] }}, \y_16 };
    (* src = "src/tanh.spade:68,18" *)
    \std::conv::impl_3::to_uint[2138]  to_uint_0(.self_i(\y_i32 ), .output__(_e_6434));
    assign _e_6433 = {1'd1, _e_6434};
    assign _e_9839 = \trig [32] == 1'd0;
    assign _e_6437 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9837, _e_9839})
            2'b1?: _e_6365 = _e_6433;
            2'b01: _e_6365 = _e_6437;
            2'b?: _e_6365 = 33'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_6364;
        end
        else begin
            \res  <= _e_6365;
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
    logic[42:0] _e_6443;
    (* src = "src/tanh.spade:78,14" *)
    logic[31:0] \a ;
    logic _e_9841;
    logic _e_9843;
    logic _e_9845;
    logic _e_9846;
    (* src = "src/tanh.spade:78,35" *)
    logic[32:0] _e_6445;
    (* src = "src/tanh.spade:79,9" *)
    logic[43:0] \_ ;
    (* src = "src/tanh.spade:79,25" *)
    logic[42:0] _e_6451;
    (* src = "src/tanh.spade:79,30" *)
    logic[31:0] a_n1;
    logic _e_9849;
    logic _e_9851;
    logic _e_9853;
    logic _e_9854;
    (* src = "src/tanh.spade:79,51" *)
    logic[32:0] _e_6453;
    (* src = "src/tanh.spade:79,60" *)
    logic[43:0] __n1;
    (* src = "src/tanh.spade:79,65" *)
    logic[32:0] _e_6456;
    (* src = "src/tanh.spade:79,14" *)
    logic[32:0] _e_6448;
    (* src = "src/tanh.spade:77,5" *)
    logic[32:0] _e_6440;
    assign _e_6443 = \m1 [42:0];
    assign \a  = _e_6443[36:5];
    assign _e_9841 = \m1 [43] == 1'd1;
    assign _e_9843 = _e_6443[42:37] == 6'd34;
    localparam[0:0] _e_9844 = 1;
    assign _e_9845 = _e_9843 && _e_9844;
    assign _e_9846 = _e_9841 && _e_9845;
    assign _e_6445 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_9847 = 1;
    assign _e_6451 = \m0 [42:0];
    assign a_n1 = _e_6451[36:5];
    assign _e_9849 = \m0 [43] == 1'd1;
    assign _e_9851 = _e_6451[42:37] == 6'd34;
    localparam[0:0] _e_9852 = 1;
    assign _e_9853 = _e_9851 && _e_9852;
    assign _e_9854 = _e_9849 && _e_9853;
    assign _e_6453 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9855 = 1;
    assign _e_6456 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9854, _e_9855})
            2'b1?: _e_6448 = _e_6453;
            2'b01: _e_6448 = _e_6456;
            2'b?: _e_6448 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9846, _e_9847})
            2'b1?: _e_6440 = _e_6445;
            2'b01: _e_6440 = _e_6448;
            2'b?: _e_6440 = 33'dx;
        endcase
    end
    assign output__ = _e_6440;
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
    logic[51:0] _e_6463;
    (* src = "src/cc.spade:10,48" *)
    logic[50:0] _e_6462;
    (* src = "src/cc.spade:10,14" *)
    reg[50:0] \counter ;
    logic[63:0] \padded ;
    (* src = "src/cc.spade:13,37" *)
    logic[63:0] _e_6470;
    (* src = "src/cc.spade:13,31" *)
    logic[31:0] \cc_res_lo ;
    (* src = "src/cc.spade:14,39" *)
    logic[63:0] _e_6475;
    (* src = "src/cc.spade:14,33" *)
    logic[31:0] \cc_res_high ;
    (* src = "src/cc.spade:15,5" *)
    logic[63:0] _e_6479;
    localparam[50:0] _e_6461 = 51'd0;
    localparam[50:0] _e_6465 = 51'd1;
    assign _e_6463 = \counter  + _e_6465;
    assign _e_6462 = _e_6463[50:0];
    always @(posedge \clk ) begin
        if (\rst ) begin
            \counter  <= _e_6461;
        end
        else begin
            \counter  <= _e_6462;
        end
    end
    assign \padded  = {13'b0, \counter };
    localparam[63:0] _e_6472 = 64'd4294967295;
    assign _e_6470 = \padded  & _e_6472;
    assign \cc_res_lo  = _e_6470[31:0];
    localparam[63:0] _e_6477 = 64'd32;
    assign _e_6475 = \padded  >> _e_6477;
    assign \cc_res_high  = _e_6475[31:0];
    assign _e_6479 = {\cc_res_lo , \cc_res_high };
    assign output__ = _e_6479;
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
    logic _e_6484;
    (* src = "src/mul_shiftadd.spade:24,5" *)
    logic[102:0] _e_6483;
    assign _e_6484 = {1'd0};
    localparam[31:0] _e_6485 = 32'd0;
    localparam[31:0] _e_6486 = 32'd0;
    localparam[31:0] _e_6487 = 32'd0;
    localparam[5:0] _e_6488 = 0;
    assign _e_6483 = {_e_6484, _e_6485, _e_6486, _e_6487, _e_6488};
    assign output__ = _e_6483;
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
    logic[102:0] _e_6493;
    (* src = "src/mul_shiftadd.spade:33,57" *)
    logic _e_6495;
    (* src = "src/mul_shiftadd.spade:34,9" *)
    logic _e_6497;
    logic _e_9857;
    (* src = "src/mul_shiftadd.spade:37,17" *)
    logic[31:0] \val ;
    logic _e_9859;
    logic _e_9861;
    logic _e_9863;
    (* src = "src/mul_shiftadd.spade:38,25" *)
    logic[31:0] _e_6505;
    (* src = "src/mul_shiftadd.spade:36,26" *)
    logic[31:0] \next_a ;
    (* src = "src/mul_shiftadd.spade:44,17" *)
    logic[31:0] \val_b ;
    logic _e_9865;
    logic _e_9867;
    (* src = "src/mul_shiftadd.spade:44,40" *)
    logic _e_6513;
    (* src = "src/mul_shiftadd.spade:44,32" *)
    logic[102:0] _e_6512;
    logic _e_9869;
    (* src = "src/mul_shiftadd.spade:45,33" *)
    logic _e_6520;
    (* src = "src/mul_shiftadd.spade:45,25" *)
    logic[102:0] _e_6519;
    (* src = "src/mul_shiftadd.spade:43,13" *)
    logic[102:0] _e_6508;
    (* src = "src/mul_shiftadd.spade:48,9" *)
    logic _e_6525;
    logic _e_9871;
    (* src = "src/mul_shiftadd.spade:50,27" *)
    logic[31:0] _e_6529;
    (* src = "src/mul_shiftadd.spade:50,26" *)
    logic[31:0] _e_6528;
    (* src = "src/mul_shiftadd.spade:50,26" *)
    logic \do_add ;
    (* src = "src/mul_shiftadd.spade:51,46" *)
    logic[31:0] _e_6537;
    (* src = "src/mul_shiftadd.spade:51,34" *)
    logic[31:0] \current_addend ;
    (* src = "src/mul_shiftadd.spade:52,34" *)
    logic[31:0] _e_6544;
    (* src = "src/mul_shiftadd.spade:52,34" *)
    logic[32:0] _e_6543;
    (* src = "src/mul_shiftadd.spade:52,28" *)
    logic[31:0] \next_acc ;
    (* src = "src/mul_shiftadd.spade:55,26" *)
    logic[31:0] _e_6549;
    (* src = "src/mul_shiftadd.spade:55,26" *)
    logic[31:0] next_a_n1;
    (* src = "src/mul_shiftadd.spade:56,26" *)
    logic[31:0] _e_6554;
    (* src = "src/mul_shiftadd.spade:56,26" *)
    logic[31:0] \next_b ;
    (* src = "src/mul_shiftadd.spade:58,16" *)
    logic[5:0] _e_6560;
    (* src = "src/mul_shiftadd.spade:58,16" *)
    logic _e_6559;
    (* src = "src/mul_shiftadd.spade:60,17" *)
    logic[102:0] _e_6564;
    (* src = "src/mul_shiftadd.spade:62,25" *)
    logic _e_6567;
    (* src = "src/mul_shiftadd.spade:62,70" *)
    logic[5:0] _e_6573;
    (* src = "src/mul_shiftadd.spade:62,70" *)
    logic[6:0] _e_6572;
    (* src = "src/mul_shiftadd.spade:62,64" *)
    logic[5:0] _e_6571;
    (* src = "src/mul_shiftadd.spade:62,17" *)
    logic[102:0] _e_6566;
    (* src = "src/mul_shiftadd.spade:58,13" *)
    logic[102:0] _e_6558;
    (* src = "src/mul_shiftadd.spade:33,51" *)
    logic[102:0] _e_6494;
    (* src = "src/mul_shiftadd.spade:33,14" *)
    reg[102:0] \r ;
    (* src = "src/mul_shiftadd.spade:69,11" *)
    logic _e_6577;
    (* src = "src/mul_shiftadd.spade:70,9" *)
    logic _e_6579;
    logic _e_9873;
    (* src = "src/mul_shiftadd.spade:71,16" *)
    logic[5:0] _e_6583;
    (* src = "src/mul_shiftadd.spade:71,16" *)
    logic _e_6582;
    (* src = "src/mul_shiftadd.spade:73,31" *)
    logic[31:0] _e_6589;
    (* src = "src/mul_shiftadd.spade:73,30" *)
    logic[31:0] _e_6588;
    (* src = "src/mul_shiftadd.spade:73,30" *)
    logic do_add_n1;
    (* src = "src/mul_shiftadd.spade:74,50" *)
    logic[31:0] _e_6597;
    (* src = "src/mul_shiftadd.spade:74,38" *)
    logic[31:0] current_addend_n1;
    (* src = "src/mul_shiftadd.spade:75,28" *)
    logic[31:0] _e_6605;
    (* src = "src/mul_shiftadd.spade:75,28" *)
    logic[32:0] _e_6604;
    (* src = "src/mul_shiftadd.spade:75,22" *)
    logic[31:0] _e_6603;
    (* src = "src/mul_shiftadd.spade:75,17" *)
    logic[32:0] _e_6602;
    (* src = "src/mul_shiftadd.spade:77,17" *)
    logic[32:0] _e_6609;
    (* src = "src/mul_shiftadd.spade:71,13" *)
    logic[32:0] _e_6581;
    (* src = "src/mul_shiftadd.spade:80,9" *)
    logic \_ ;
    (* src = "src/mul_shiftadd.spade:80,14" *)
    logic[32:0] _e_6611;
    (* src = "src/mul_shiftadd.spade:69,5" *)
    logic[32:0] _e_6576;
    (* src = "src/mul_shiftadd.spade:33,36" *)
    \tta::mul_shiftadd::reset_mul  reset_mul_0(.output__(_e_6493));
    assign _e_6495 = \r [102];
    assign _e_6497 = _e_6495;
    assign _e_9857 = _e_6495 == 1'd0;
    assign \val  = \set_op_a [31:0];
    assign _e_9859 = \set_op_a [32] == 1'd1;
    localparam[0:0] _e_9860 = 1;
    assign _e_9861 = _e_9859 && _e_9860;
    assign _e_9863 = \set_op_a [32] == 1'd0;
    assign _e_6505 = \r [101:70];
    always_comb begin
        priority casez ({_e_9861, _e_9863})
            2'b1?: \next_a  = \val ;
            2'b01: \next_a  = _e_6505;
            2'b?: \next_a  = 32'dx;
        endcase
    end
    assign \val_b  = \trig [31:0];
    assign _e_9865 = \trig [32] == 1'd1;
    localparam[0:0] _e_9866 = 1;
    assign _e_9867 = _e_9865 && _e_9866;
    assign _e_6513 = {1'd1};
    localparam[31:0] _e_6516 = 32'd0;
    localparam[5:0] _e_6517 = 0;
    assign _e_6512 = {_e_6513, \next_a , \val_b , _e_6516, _e_6517};
    assign _e_9869 = \trig [32] == 1'd0;
    assign _e_6520 = {1'd0};
    localparam[31:0] _e_6522 = 32'd0;
    localparam[31:0] _e_6523 = 32'd0;
    localparam[5:0] _e_6524 = 0;
    assign _e_6519 = {_e_6520, \next_a , _e_6522, _e_6523, _e_6524};
    always_comb begin
        priority casez ({_e_9867, _e_9869})
            2'b1?: _e_6508 = _e_6512;
            2'b01: _e_6508 = _e_6519;
            2'b?: _e_6508 = 103'dx;
        endcase
    end
    assign _e_6525 = _e_6495;
    assign _e_9871 = _e_6495 == 1'd1;
    assign _e_6529 = \r [69:38];
    localparam[31:0] _e_6531 = 32'd1;
    assign _e_6528 = _e_6529 & _e_6531;
    localparam[31:0] _e_6532 = 32'd1;
    assign \do_add  = _e_6528 == _e_6532;
    assign _e_6537 = \r [101:70];
    localparam[31:0] _e_6540 = 32'd0;
    assign \current_addend  = \do_add  ? _e_6537 : _e_6540;
    assign _e_6544 = \r [37:6];
    assign _e_6543 = _e_6544 + \current_addend ;
    assign \next_acc  = _e_6543[31:0];
    assign _e_6549 = \r [101:70];
    localparam[31:0] _e_6551 = 32'd1;
    assign next_a_n1 = _e_6549 << _e_6551;
    assign _e_6554 = \r [69:38];
    localparam[31:0] _e_6556 = 32'd1;
    assign \next_b  = _e_6554 >> _e_6556;
    assign _e_6560 = \r [5:0];
    localparam[5:0] _e_6562 = 31;
    assign _e_6559 = _e_6560 == _e_6562;
    (* src = "src/mul_shiftadd.spade:60,17" *)
    \tta::mul_shiftadd::reset_mul  reset_mul_1(.output__(_e_6564));
    assign _e_6567 = {1'd1};
    assign _e_6573 = \r [5:0];
    localparam[5:0] _e_6575 = 1;
    assign _e_6572 = _e_6573 + _e_6575;
    assign _e_6571 = _e_6572[5:0];
    assign _e_6566 = {_e_6567, next_a_n1, \next_b , \next_acc , _e_6571};
    assign _e_6558 = _e_6559 ? _e_6564 : _e_6566;
    always_comb begin
        priority casez ({_e_9857, _e_9871})
            2'b1?: _e_6494 = _e_6508;
            2'b01: _e_6494 = _e_6558;
            2'b?: _e_6494 = 103'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_6493;
        end
        else begin
            \r  <= _e_6494;
        end
    end
    assign _e_6577 = \r [102];
    assign _e_6579 = _e_6577;
    assign _e_9873 = _e_6577 == 1'd1;
    assign _e_6583 = \r [5:0];
    localparam[5:0] _e_6585 = 31;
    assign _e_6582 = _e_6583 == _e_6585;
    assign _e_6589 = \r [69:38];
    localparam[31:0] _e_6591 = 32'd1;
    assign _e_6588 = _e_6589 & _e_6591;
    localparam[31:0] _e_6592 = 32'd1;
    assign do_add_n1 = _e_6588 == _e_6592;
    assign _e_6597 = \r [101:70];
    localparam[31:0] _e_6600 = 32'd0;
    assign current_addend_n1 = do_add_n1 ? _e_6597 : _e_6600;
    assign _e_6605 = \r [37:6];
    assign _e_6604 = _e_6605 + current_addend_n1;
    assign _e_6603 = _e_6604[31:0];
    assign _e_6602 = {1'd1, _e_6603};
    assign _e_6609 = {1'd0, 32'bX};
    assign _e_6581 = _e_6582 ? _e_6602 : _e_6609;
    assign \_  = _e_6577;
    localparam[0:0] _e_9874 = 1;
    assign _e_6611 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9873, _e_9874})
            2'b1?: _e_6576 = _e_6581;
            2'b01: _e_6576 = _e_6611;
            2'b?: _e_6576 = 33'dx;
        endcase
    end
    assign output__ = _e_6576;
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
    logic[42:0] _e_6616;
    (* src = "src/mul_shiftadd.spade:87,10" *)
    logic[31:0] \x ;
    logic _e_9876;
    logic _e_9878;
    logic _e_9880;
    logic _e_9881;
    (* src = "src/mul_shiftadd.spade:87,31" *)
    logic[32:0] _e_6618;
    (* src = "src/mul_shiftadd.spade:88,5" *)
    logic[43:0] \_ ;
    (* src = "src/mul_shiftadd.spade:88,21" *)
    logic[42:0] _e_6624;
    (* src = "src/mul_shiftadd.spade:88,26" *)
    logic[31:0] x_n1;
    logic _e_9884;
    logic _e_9886;
    logic _e_9888;
    logic _e_9889;
    (* src = "src/mul_shiftadd.spade:88,47" *)
    logic[32:0] _e_6626;
    (* src = "src/mul_shiftadd.spade:88,56" *)
    logic[43:0] __n1;
    (* src = "src/mul_shiftadd.spade:88,61" *)
    logic[32:0] _e_6629;
    (* src = "src/mul_shiftadd.spade:88,10" *)
    logic[32:0] _e_6621;
    (* src = "src/mul_shiftadd.spade:86,3" *)
    logic[32:0] _e_6613;
    assign _e_6616 = \m1 [42:0];
    assign \x  = _e_6616[36:5];
    assign _e_9876 = \m1 [43] == 1'd1;
    assign _e_9878 = _e_6616[42:37] == 6'd16;
    localparam[0:0] _e_9879 = 1;
    assign _e_9880 = _e_9878 && _e_9879;
    assign _e_9881 = _e_9876 && _e_9880;
    assign _e_6618 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9882 = 1;
    assign _e_6624 = \m0 [42:0];
    assign x_n1 = _e_6624[36:5];
    assign _e_9884 = \m0 [43] == 1'd1;
    assign _e_9886 = _e_6624[42:37] == 6'd16;
    localparam[0:0] _e_9887 = 1;
    assign _e_9888 = _e_9886 && _e_9887;
    assign _e_9889 = _e_9884 && _e_9888;
    assign _e_6626 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9890 = 1;
    assign _e_6629 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9889, _e_9890})
            2'b1?: _e_6621 = _e_6626;
            2'b01: _e_6621 = _e_6629;
            2'b?: _e_6621 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9881, _e_9882})
            2'b1?: _e_6613 = _e_6618;
            2'b01: _e_6613 = _e_6621;
            2'b?: _e_6613 = 33'dx;
        endcase
    end
    assign output__ = _e_6613;
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
    logic[42:0] _e_6634;
    (* src = "src/mul_shiftadd.spade:94,10" *)
    logic[31:0] \x ;
    logic _e_9892;
    logic _e_9894;
    logic _e_9896;
    logic _e_9897;
    (* src = "src/mul_shiftadd.spade:94,31" *)
    logic[32:0] _e_6636;
    (* src = "src/mul_shiftadd.spade:95,5" *)
    logic[43:0] \_ ;
    (* src = "src/mul_shiftadd.spade:95,21" *)
    logic[42:0] _e_6642;
    (* src = "src/mul_shiftadd.spade:95,26" *)
    logic[31:0] x_n1;
    logic _e_9900;
    logic _e_9902;
    logic _e_9904;
    logic _e_9905;
    (* src = "src/mul_shiftadd.spade:95,47" *)
    logic[32:0] _e_6644;
    (* src = "src/mul_shiftadd.spade:95,56" *)
    logic[43:0] __n1;
    (* src = "src/mul_shiftadd.spade:95,61" *)
    logic[32:0] _e_6647;
    (* src = "src/mul_shiftadd.spade:95,10" *)
    logic[32:0] _e_6639;
    (* src = "src/mul_shiftadd.spade:93,3" *)
    logic[32:0] _e_6631;
    assign _e_6634 = \m1 [42:0];
    assign \x  = _e_6634[36:5];
    assign _e_9892 = \m1 [43] == 1'd1;
    assign _e_9894 = _e_6634[42:37] == 6'd17;
    localparam[0:0] _e_9895 = 1;
    assign _e_9896 = _e_9894 && _e_9895;
    assign _e_9897 = _e_9892 && _e_9896;
    assign _e_6636 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_9898 = 1;
    assign _e_6642 = \m0 [42:0];
    assign x_n1 = _e_6642[36:5];
    assign _e_9900 = \m0 [43] == 1'd1;
    assign _e_9902 = _e_6642[42:37] == 6'd17;
    localparam[0:0] _e_9903 = 1;
    assign _e_9904 = _e_9902 && _e_9903;
    assign _e_9905 = _e_9900 && _e_9904;
    assign _e_6644 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_9906 = 1;
    assign _e_6647 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_9905, _e_9906})
            2'b1?: _e_6639 = _e_6644;
            2'b01: _e_6639 = _e_6647;
            2'b?: _e_6639 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_9897, _e_9898})
            2'b1?: _e_6631 = _e_6636;
            2'b01: _e_6631 = _e_6639;
            2'b?: _e_6631 = 33'dx;
        endcase
    end
    assign output__ = _e_6631;
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
    logic _e_9907;
    (* src = "src/imem.spade:30,17" *)
    logic[36:0] _e_6652;
    logic _e_9909;
    (* src = "src/imem.spade:31,17" *)
    logic[36:0] _e_6655;
    logic _e_9911;
    (* src = "src/imem.spade:32,17" *)
    logic[36:0] _e_6658;
    logic _e_9913;
    (* src = "src/imem.spade:33,17" *)
    logic[36:0] _e_6661;
    logic _e_9915;
    (* src = "src/imem.spade:34,17" *)
    logic[36:0] _e_6664;
    logic _e_9917;
    (* src = "src/imem.spade:35,17" *)
    logic[36:0] _e_6667;
    logic _e_9919;
    (* src = "src/imem.spade:36,17" *)
    logic[36:0] _e_6670;
    logic _e_9921;
    (* src = "src/imem.spade:37,17" *)
    logic[36:0] _e_6673;
    logic _e_9923;
    (* src = "src/imem.spade:39,17" *)
    logic[36:0] _e_6676;
    logic _e_9925;
    (* src = "src/imem.spade:40,17" *)
    logic[36:0] _e_6678;
    logic _e_9927;
    logic[31:0] _e_6681;
    (* src = "src/imem.spade:43,17" *)
    logic[36:0] _e_6680;
    logic _e_9929;
    (* src = "src/imem.spade:46,17" *)
    logic[36:0] _e_6684;
    logic _e_9931;
    (* src = "src/imem.spade:47,17" *)
    logic[36:0] _e_6686;
    logic _e_9933;
    (* src = "src/imem.spade:48,17" *)
    logic[36:0] _e_6688;
    logic _e_9935;
    (* src = "src/imem.spade:49,17" *)
    logic[36:0] _e_6690;
    logic _e_9937;
    (* src = "src/imem.spade:50,17" *)
    logic[36:0] _e_6692;
    logic _e_9939;
    (* src = "src/imem.spade:51,17" *)
    logic[36:0] _e_6694;
    logic _e_9941;
    (* src = "src/imem.spade:52,17" *)
    logic[36:0] _e_6696;
    logic _e_9943;
    (* src = "src/imem.spade:53,17" *)
    logic[36:0] _e_6698;
    logic _e_9945;
    (* src = "src/imem.spade:54,17" *)
    logic[36:0] _e_6700;
    logic _e_9947;
    (* src = "src/imem.spade:55,17" *)
    logic[36:0] _e_6702;
    logic _e_9949;
    (* src = "src/imem.spade:56,17" *)
    logic[36:0] _e_6704;
    logic _e_9951;
    (* src = "src/imem.spade:57,17" *)
    logic[36:0] _e_6706;
    logic _e_9953;
    (* src = "src/imem.spade:58,17" *)
    logic[36:0] _e_6708;
    logic _e_9955;
    (* src = "src/imem.spade:59,17" *)
    logic[36:0] _e_6710;
    logic _e_9957;
    (* src = "src/imem.spade:60,17" *)
    logic[36:0] _e_6712;
    logic _e_9959;
    (* src = "src/imem.spade:61,17" *)
    logic[36:0] _e_6714;
    logic _e_9961;
    (* src = "src/imem.spade:62,17" *)
    logic[36:0] _e_6716;
    logic _e_9963;
    (* src = "src/imem.spade:65,17" *)
    logic[36:0] _e_6718;
    logic _e_9965;
    (* src = "src/imem.spade:66,17" *)
    logic[36:0] _e_6720;
    logic _e_9967;
    (* src = "src/imem.spade:67,17" *)
    logic[36:0] _e_6722;
    logic _e_9969;
    (* src = "src/imem.spade:70,18" *)
    logic[36:0] _e_6724;
    logic _e_9971;
    (* src = "src/imem.spade:71,18" *)
    logic[36:0] _e_6727;
    logic _e_9973;
    (* src = "src/imem.spade:72,18" *)
    logic[36:0] _e_6730;
    logic _e_9975;
    (* src = "src/imem.spade:73,18" *)
    logic[36:0] _e_6733;
    logic _e_9977;
    (* src = "src/imem.spade:74,18" *)
    logic[36:0] _e_6736;
    logic _e_9979;
    (* src = "src/imem.spade:75,18" *)
    logic[36:0] _e_6739;
    logic _e_9981;
    (* src = "src/imem.spade:76,18" *)
    logic[36:0] _e_6742;
    logic _e_9983;
    (* src = "src/imem.spade:77,18" *)
    logic[36:0] _e_6745;
    logic _e_9985;
    (* src = "src/imem.spade:79,18" *)
    logic[36:0] _e_6748;
    (* src = "src/imem.spade:82,9" *)
    logic[7:0] \_ ;
    (* src = "src/imem.spade:82,14" *)
    logic[36:0] _e_6750;
    (* src = "src/imem.spade:28,5" *)
    logic[36:0] _e_6649;
    localparam[7:0] _e_9908 = 0;
    assign _e_9907 = \t  == _e_9908;
    localparam[3:0] _e_6653 = 0;
    assign _e_6652 = {5'd0, _e_6653, 28'bX};
    localparam[7:0] _e_9910 = 1;
    assign _e_9909 = \t  == _e_9910;
    localparam[3:0] _e_6656 = 1;
    assign _e_6655 = {5'd0, _e_6656, 28'bX};
    localparam[7:0] _e_9912 = 2;
    assign _e_9911 = \t  == _e_9912;
    localparam[3:0] _e_6659 = 2;
    assign _e_6658 = {5'd0, _e_6659, 28'bX};
    localparam[7:0] _e_9914 = 3;
    assign _e_9913 = \t  == _e_9914;
    localparam[3:0] _e_6662 = 3;
    assign _e_6661 = {5'd0, _e_6662, 28'bX};
    localparam[7:0] _e_9916 = 4;
    assign _e_9915 = \t  == _e_9916;
    localparam[3:0] _e_6665 = 4;
    assign _e_6664 = {5'd0, _e_6665, 28'bX};
    localparam[7:0] _e_9918 = 5;
    assign _e_9917 = \t  == _e_9918;
    localparam[3:0] _e_6668 = 5;
    assign _e_6667 = {5'd0, _e_6668, 28'bX};
    localparam[7:0] _e_9920 = 6;
    assign _e_9919 = \t  == _e_9920;
    localparam[3:0] _e_6671 = 6;
    assign _e_6670 = {5'd0, _e_6671, 28'bX};
    localparam[7:0] _e_9922 = 7;
    assign _e_9921 = \t  == _e_9922;
    localparam[3:0] _e_6674 = 7;
    assign _e_6673 = {5'd0, _e_6674, 28'bX};
    localparam[7:0] _e_9924 = 8;
    assign _e_9923 = \t  == _e_9924;
    assign _e_6676 = {5'd6, 32'bX};
    localparam[7:0] _e_9926 = 9;
    assign _e_9925 = \t  == _e_9926;
    assign _e_6678 = {5'd3, 32'bX};
    localparam[7:0] _e_9928 = 10;
    assign _e_9927 = \t  == _e_9928;
    assign _e_6681 = {16'b0, \imm16 };
    assign _e_6680 = {5'd5, _e_6681};
    localparam[7:0] _e_9930 = 11;
    assign _e_9929 = \t  == _e_9930;
    assign _e_6684 = {5'd1, 32'bX};
    localparam[7:0] _e_9932 = 12;
    assign _e_9931 = \t  == _e_9932;
    assign _e_6686 = {5'd7, 32'bX};
    localparam[7:0] _e_9934 = 13;
    assign _e_9933 = \t  == _e_9934;
    assign _e_6688 = {5'd11, 32'bX};
    localparam[7:0] _e_9936 = 14;
    assign _e_9935 = \t  == _e_9936;
    assign _e_6690 = {5'd12, 32'bX};
    localparam[7:0] _e_9938 = 15;
    assign _e_9937 = \t  == _e_9938;
    assign _e_6692 = {5'd2, 32'bX};
    localparam[7:0] _e_9940 = 16;
    assign _e_9939 = \t  == _e_9940;
    assign _e_6694 = {5'd13, 32'bX};
    localparam[7:0] _e_9942 = 17;
    assign _e_9941 = \t  == _e_9942;
    assign _e_6696 = {5'd14, 32'bX};
    localparam[7:0] _e_9944 = 18;
    assign _e_9943 = \t  == _e_9944;
    assign _e_6698 = {5'd15, 32'bX};
    localparam[7:0] _e_9946 = 19;
    assign _e_9945 = \t  == _e_9946;
    assign _e_6700 = {5'd18, 32'bX};
    localparam[7:0] _e_9948 = 20;
    assign _e_9947 = \t  == _e_9948;
    assign _e_6702 = {5'd20, 32'bX};
    localparam[7:0] _e_9950 = 21;
    assign _e_9949 = \t  == _e_9950;
    assign _e_6704 = {5'd21, 32'bX};
    localparam[7:0] _e_9952 = 22;
    assign _e_9951 = \t  == _e_9952;
    assign _e_6706 = {5'd22, 32'bX};
    localparam[7:0] _e_9954 = 23;
    assign _e_9953 = \t  == _e_9954;
    assign _e_6708 = {5'd17, 32'bX};
    localparam[7:0] _e_9956 = 24;
    assign _e_9955 = \t  == _e_9956;
    assign _e_6710 = {5'd19, 32'bX};
    localparam[7:0] _e_9958 = 25;
    assign _e_9957 = \t  == _e_9958;
    assign _e_6712 = {5'd23, 32'bX};
    localparam[7:0] _e_9960 = 26;
    assign _e_9959 = \t  == _e_9960;
    assign _e_6714 = {5'd8, 32'bX};
    localparam[7:0] _e_9962 = 27;
    assign _e_9961 = \t  == _e_9962;
    assign _e_6716 = {5'd24, 32'bX};
    localparam[7:0] _e_9964 = 60;
    assign _e_9963 = \t  == _e_9964;
    assign _e_6718 = {5'd9, 32'bX};
    localparam[7:0] _e_9966 = 61;
    assign _e_9965 = \t  == _e_9966;
    assign _e_6720 = {5'd10, 32'bX};
    localparam[7:0] _e_9968 = 62;
    assign _e_9967 = \t  == _e_9968;
    assign _e_6722 = {5'd16, 32'bX};
    localparam[7:0] _e_9970 = 100;
    assign _e_9969 = \t  == _e_9970;
    localparam[3:0] _e_6725 = 8;
    assign _e_6724 = {5'd0, _e_6725, 28'bX};
    localparam[7:0] _e_9972 = 101;
    assign _e_9971 = \t  == _e_9972;
    localparam[3:0] _e_6728 = 9;
    assign _e_6727 = {5'd0, _e_6728, 28'bX};
    localparam[7:0] _e_9974 = 102;
    assign _e_9973 = \t  == _e_9974;
    localparam[3:0] _e_6731 = 10;
    assign _e_6730 = {5'd0, _e_6731, 28'bX};
    localparam[7:0] _e_9976 = 103;
    assign _e_9975 = \t  == _e_9976;
    localparam[3:0] _e_6734 = 11;
    assign _e_6733 = {5'd0, _e_6734, 28'bX};
    localparam[7:0] _e_9978 = 104;
    assign _e_9977 = \t  == _e_9978;
    localparam[3:0] _e_6737 = 12;
    assign _e_6736 = {5'd0, _e_6737, 28'bX};
    localparam[7:0] _e_9980 = 105;
    assign _e_9979 = \t  == _e_9980;
    localparam[3:0] _e_6740 = 13;
    assign _e_6739 = {5'd0, _e_6740, 28'bX};
    localparam[7:0] _e_9982 = 106;
    assign _e_9981 = \t  == _e_9982;
    localparam[3:0] _e_6743 = 14;
    assign _e_6742 = {5'd0, _e_6743, 28'bX};
    localparam[7:0] _e_9984 = 107;
    assign _e_9983 = \t  == _e_9984;
    localparam[3:0] _e_6746 = 15;
    assign _e_6745 = {5'd0, _e_6746, 28'bX};
    localparam[7:0] _e_9986 = 110;
    assign _e_9985 = \t  == _e_9986;
    assign _e_6748 = {5'd4, 32'bX};
    assign \_  = \t ;
    localparam[0:0] _e_9987 = 1;
    assign _e_6750 = {5'd6, 32'bX};
    always_comb begin
        priority casez ({_e_9907, _e_9909, _e_9911, _e_9913, _e_9915, _e_9917, _e_9919, _e_9921, _e_9923, _e_9925, _e_9927, _e_9929, _e_9931, _e_9933, _e_9935, _e_9937, _e_9939, _e_9941, _e_9943, _e_9945, _e_9947, _e_9949, _e_9951, _e_9953, _e_9955, _e_9957, _e_9959, _e_9961, _e_9963, _e_9965, _e_9967, _e_9969, _e_9971, _e_9973, _e_9975, _e_9977, _e_9979, _e_9981, _e_9983, _e_9985, _e_9987})
            41'b1????????????????????????????????????????: _e_6649 = _e_6652;
            41'b01???????????????????????????????????????: _e_6649 = _e_6655;
            41'b001??????????????????????????????????????: _e_6649 = _e_6658;
            41'b0001?????????????????????????????????????: _e_6649 = _e_6661;
            41'b00001????????????????????????????????????: _e_6649 = _e_6664;
            41'b000001???????????????????????????????????: _e_6649 = _e_6667;
            41'b0000001??????????????????????????????????: _e_6649 = _e_6670;
            41'b00000001?????????????????????????????????: _e_6649 = _e_6673;
            41'b000000001????????????????????????????????: _e_6649 = _e_6676;
            41'b0000000001???????????????????????????????: _e_6649 = _e_6678;
            41'b00000000001??????????????????????????????: _e_6649 = _e_6680;
            41'b000000000001?????????????????????????????: _e_6649 = _e_6684;
            41'b0000000000001????????????????????????????: _e_6649 = _e_6686;
            41'b00000000000001???????????????????????????: _e_6649 = _e_6688;
            41'b000000000000001??????????????????????????: _e_6649 = _e_6690;
            41'b0000000000000001?????????????????????????: _e_6649 = _e_6692;
            41'b00000000000000001????????????????????????: _e_6649 = _e_6694;
            41'b000000000000000001???????????????????????: _e_6649 = _e_6696;
            41'b0000000000000000001??????????????????????: _e_6649 = _e_6698;
            41'b00000000000000000001?????????????????????: _e_6649 = _e_6700;
            41'b000000000000000000001????????????????????: _e_6649 = _e_6702;
            41'b0000000000000000000001???????????????????: _e_6649 = _e_6704;
            41'b00000000000000000000001??????????????????: _e_6649 = _e_6706;
            41'b000000000000000000000001?????????????????: _e_6649 = _e_6708;
            41'b0000000000000000000000001????????????????: _e_6649 = _e_6710;
            41'b00000000000000000000000001???????????????: _e_6649 = _e_6712;
            41'b000000000000000000000000001??????????????: _e_6649 = _e_6714;
            41'b0000000000000000000000000001?????????????: _e_6649 = _e_6716;
            41'b00000000000000000000000000001????????????: _e_6649 = _e_6718;
            41'b000000000000000000000000000001???????????: _e_6649 = _e_6720;
            41'b0000000000000000000000000000001??????????: _e_6649 = _e_6722;
            41'b00000000000000000000000000000001?????????: _e_6649 = _e_6724;
            41'b000000000000000000000000000000001????????: _e_6649 = _e_6727;
            41'b0000000000000000000000000000000001???????: _e_6649 = _e_6730;
            41'b00000000000000000000000000000000001??????: _e_6649 = _e_6733;
            41'b000000000000000000000000000000000001?????: _e_6649 = _e_6736;
            41'b0000000000000000000000000000000000001????: _e_6649 = _e_6739;
            41'b00000000000000000000000000000000000001???: _e_6649 = _e_6742;
            41'b000000000000000000000000000000000000001??: _e_6649 = _e_6745;
            41'b0000000000000000000000000000000000000001?: _e_6649 = _e_6748;
            41'b00000000000000000000000000000000000000001: _e_6649 = _e_6750;
            41'b?: _e_6649 = 37'dx;
        endcase
    end
    assign output__ = _e_6649;
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
    logic _e_9988;
    (* src = "src/imem.spade:89,17" *)
    logic[10:0] _e_6755;
    logic _e_9990;
    (* src = "src/imem.spade:90,17" *)
    logic[10:0] _e_6758;
    logic _e_9992;
    (* src = "src/imem.spade:91,17" *)
    logic[10:0] _e_6761;
    logic _e_9994;
    (* src = "src/imem.spade:92,17" *)
    logic[10:0] _e_6764;
    logic _e_9996;
    (* src = "src/imem.spade:93,17" *)
    logic[10:0] _e_6767;
    logic _e_9998;
    (* src = "src/imem.spade:94,17" *)
    logic[10:0] _e_6770;
    logic _e_10000;
    (* src = "src/imem.spade:95,17" *)
    logic[10:0] _e_6773;
    logic _e_10002;
    (* src = "src/imem.spade:96,17" *)
    logic[10:0] _e_6776;
    logic _e_10004;
    (* src = "src/imem.spade:102,17" *)
    logic[10:0] _e_6779;
    logic _e_10006;
    (* src = "src/imem.spade:103,17" *)
    logic[10:0] _e_6781;
    logic _e_10008;
    (* src = "src/imem.spade:104,17" *)
    logic[10:0] _e_6783;
    logic _e_10010;
    (* src = "src/imem.spade:105,17" *)
    logic[10:0] _e_6785;
    logic _e_10012;
    (* src = "src/imem.spade:106,17" *)
    logic[10:0] _e_6787;
    logic _e_10014;
    (* src = "src/imem.spade:107,17" *)
    logic[10:0] _e_6789;
    logic _e_10016;
    (* src = "src/imem.spade:108,17" *)
    logic[10:0] _e_6791;
    logic _e_10018;
    (* src = "src/imem.spade:109,17" *)
    logic[10:0] _e_6793;
    logic _e_10020;
    (* src = "src/imem.spade:110,17" *)
    logic[10:0] _e_6795;
    logic _e_10022;
    (* src = "src/imem.spade:111,17" *)
    logic[10:0] _e_6797;
    logic _e_10024;
    (* src = "src/imem.spade:114,17" *)
    logic[10:0] _e_6799;
    logic _e_10026;
    (* src = "src/imem.spade:115,17" *)
    logic[10:0] _e_6801;
    logic _e_10028;
    (* src = "src/imem.spade:116,17" *)
    logic[10:0] _e_6803;
    logic _e_10030;
    (* src = "src/imem.spade:119,17" *)
    logic[10:0] _e_6805;
    logic _e_10032;
    (* src = "src/imem.spade:120,17" *)
    logic[10:0] _e_6807;
    logic _e_10034;
    (* src = "src/imem.spade:121,17" *)
    logic[10:0] _e_6809;
    logic _e_10036;
    (* src = "src/imem.spade:122,17" *)
    logic[10:0] _e_6811;
    logic _e_10038;
    (* src = "src/imem.spade:123,17" *)
    logic[10:0] _e_6813;
    logic _e_10040;
    (* src = "src/imem.spade:124,17" *)
    logic[10:0] _e_6815;
    logic _e_10042;
    (* src = "src/imem.spade:127,17" *)
    logic[10:0] _e_6817;
    logic _e_10044;
    (* src = "src/imem.spade:130,17" *)
    logic[10:0] _e_6819;
    logic _e_10046;
    (* src = "src/imem.spade:133,17" *)
    logic[10:0] _e_6821;
    logic _e_10048;
    (* src = "src/imem.spade:134,17" *)
    logic[10:0] _e_6823;
    logic _e_10050;
    (* src = "src/imem.spade:135,17" *)
    logic[10:0] _e_6825;
    logic _e_10052;
    (* src = "src/imem.spade:136,17" *)
    logic[10:0] _e_6827;
    logic _e_10054;
    (* src = "src/imem.spade:137,17" *)
    logic[10:0] _e_6829;
    logic _e_10056;
    (* src = "src/imem.spade:138,17" *)
    logic[10:0] _e_6831;
    logic _e_10058;
    (* src = "src/imem.spade:141,17" *)
    logic[10:0] _e_6833;
    logic _e_10060;
    (* src = "src/imem.spade:142,17" *)
    logic[10:0] _e_6835;
    logic _e_10062;
    (* src = "src/imem.spade:143,17" *)
    logic[10:0] _e_6837;
    logic _e_10064;
    (* src = "src/imem.spade:146,17" *)
    logic[10:0] _e_6839;
    logic _e_10066;
    (* src = "src/imem.spade:147,17" *)
    logic[10:0] _e_6841;
    logic _e_10068;
    (* src = "src/imem.spade:150,17" *)
    logic[10:0] _e_6843;
    logic _e_10070;
    (* src = "src/imem.spade:151,17" *)
    logic[10:0] _e_6845;
    logic _e_10072;
    (* src = "src/imem.spade:154,17" *)
    logic[10:0] _e_6847;
    logic _e_10074;
    (* src = "src/imem.spade:155,17" *)
    logic[10:0] _e_6849;
    logic _e_10076;
    (* src = "src/imem.spade:156,17" *)
    logic[10:0] _e_6851;
    logic _e_10078;
    (* src = "src/imem.spade:157,17" *)
    logic[10:0] _e_6853;
    logic _e_10080;
    (* src = "src/imem.spade:158,17" *)
    logic[10:0] _e_6855;
    logic _e_10082;
    (* src = "src/imem.spade:159,17" *)
    logic[10:0] _e_6857;
    logic _e_10084;
    (* src = "src/imem.spade:160,17" *)
    logic[10:0] _e_6859;
    logic _e_10086;
    (* src = "src/imem.spade:163,17" *)
    logic[10:0] _e_6861;
    logic _e_10088;
    (* src = "src/imem.spade:164,17" *)
    logic[10:0] _e_6863;
    logic _e_10090;
    (* src = "src/imem.spade:167,17" *)
    logic[10:0] _e_6865;
    logic _e_10092;
    (* src = "src/imem.spade:168,17" *)
    logic[10:0] _e_6867;
    logic _e_10094;
    (* src = "src/imem.spade:169,17" *)
    logic[10:0] _e_6869;
    logic _e_10096;
    (* src = "src/imem.spade:172,17" *)
    logic[10:0] _e_6871;
    logic _e_10098;
    (* src = "src/imem.spade:173,17" *)
    logic[10:0] _e_6873;
    logic _e_10100;
    (* src = "src/imem.spade:174,17" *)
    logic[10:0] _e_6875;
    logic _e_10102;
    (* src = "src/imem.spade:176,17" *)
    logic[10:0] _e_6877;
    logic _e_10104;
    (* src = "src/imem.spade:179,17" *)
    logic[10:0] _e_6879;
    logic _e_10106;
    (* src = "src/imem.spade:180,17" *)
    logic[10:0] _e_6881;
    logic _e_10108;
    (* src = "src/imem.spade:183,17" *)
    logic[10:0] _e_6883;
    logic _e_10110;
    (* src = "src/imem.spade:184,17" *)
    logic[10:0] _e_6885;
    logic _e_10112;
    (* src = "src/imem.spade:185,17" *)
    logic[10:0] _e_6887;
    logic _e_10114;
    (* src = "src/imem.spade:186,17" *)
    logic[10:0] _e_6889;
    logic _e_10116;
    (* src = "src/imem.spade:189,17" *)
    logic[10:0] _e_6891;
    logic _e_10118;
    (* src = "src/imem.spade:190,17" *)
    logic[10:0] _e_6893;
    logic _e_10120;
    (* src = "src/imem.spade:191,17" *)
    logic[10:0] _e_6895;
    logic _e_10122;
    (* src = "src/imem.spade:192,17" *)
    logic[10:0] _e_6897;
    logic _e_10124;
    (* src = "src/imem.spade:195,17" *)
    logic[10:0] _e_6899;
    logic _e_10126;
    (* src = "src/imem.spade:196,17" *)
    logic[10:0] _e_6901;
    logic _e_10128;
    (* src = "src/imem.spade:197,17" *)
    logic[10:0] _e_6903;
    logic _e_10130;
    (* src = "src/imem.spade:200,17" *)
    logic[10:0] _e_6905;
    logic _e_10132;
    (* src = "src/imem.spade:201,17" *)
    logic[10:0] _e_6907;
    logic _e_10134;
    (* src = "src/imem.spade:202,17" *)
    logic[10:0] _e_6909;
    logic _e_10136;
    (* src = "src/imem.spade:205,17" *)
    logic[10:0] _e_6911;
    logic _e_10138;
    (* src = "src/imem.spade:208,17" *)
    logic[10:0] _e_6913;
    logic _e_10140;
    (* src = "src/imem.spade:210,17" *)
    logic[10:0] _e_6915;
    logic _e_10142;
    (* src = "src/imem.spade:211,17" *)
    logic[10:0] _e_6917;
    logic _e_10144;
    (* src = "src/imem.spade:213,18" *)
    logic[10:0] _e_6919;
    logic _e_10146;
    (* src = "src/imem.spade:214,18" *)
    logic[10:0] _e_6922;
    logic _e_10148;
    (* src = "src/imem.spade:215,18" *)
    logic[10:0] _e_6925;
    logic _e_10150;
    (* src = "src/imem.spade:216,18" *)
    logic[10:0] _e_6928;
    logic _e_10152;
    (* src = "src/imem.spade:217,18" *)
    logic[10:0] _e_6931;
    logic _e_10154;
    (* src = "src/imem.spade:218,18" *)
    logic[10:0] _e_6934;
    logic _e_10156;
    (* src = "src/imem.spade:219,18" *)
    logic[10:0] _e_6937;
    logic _e_10158;
    (* src = "src/imem.spade:220,18" *)
    logic[10:0] _e_6940;
    (* src = "src/imem.spade:223,9" *)
    logic[7:0] \_ ;
    (* src = "src/imem.spade:223,14" *)
    logic[10:0] _e_6943;
    (* src = "src/imem.spade:87,5" *)
    logic[10:0] _e_6752;
    localparam[7:0] _e_9989 = 0;
    assign _e_9988 = \t  == _e_9989;
    localparam[3:0] _e_6756 = 0;
    assign _e_6755 = {7'd0, _e_6756};
    localparam[7:0] _e_9991 = 1;
    assign _e_9990 = \t  == _e_9991;
    localparam[3:0] _e_6759 = 1;
    assign _e_6758 = {7'd0, _e_6759};
    localparam[7:0] _e_9993 = 2;
    assign _e_9992 = \t  == _e_9993;
    localparam[3:0] _e_6762 = 2;
    assign _e_6761 = {7'd0, _e_6762};
    localparam[7:0] _e_9995 = 3;
    assign _e_9994 = \t  == _e_9995;
    localparam[3:0] _e_6765 = 3;
    assign _e_6764 = {7'd0, _e_6765};
    localparam[7:0] _e_9997 = 4;
    assign _e_9996 = \t  == _e_9997;
    localparam[3:0] _e_6768 = 4;
    assign _e_6767 = {7'd0, _e_6768};
    localparam[7:0] _e_9999 = 5;
    assign _e_9998 = \t  == _e_9999;
    localparam[3:0] _e_6771 = 5;
    assign _e_6770 = {7'd0, _e_6771};
    localparam[7:0] _e_10001 = 6;
    assign _e_10000 = \t  == _e_10001;
    localparam[3:0] _e_6774 = 6;
    assign _e_6773 = {7'd0, _e_6774};
    localparam[7:0] _e_10003 = 7;
    assign _e_10002 = \t  == _e_10003;
    localparam[3:0] _e_6777 = 7;
    assign _e_6776 = {7'd0, _e_6777};
    localparam[7:0] _e_10005 = 10;
    assign _e_10004 = \t  == _e_10005;
    assign _e_6779 = {7'd1, 4'bX};
    localparam[7:0] _e_10007 = 11;
    assign _e_10006 = \t  == _e_10007;
    assign _e_6781 = {7'd2, 4'bX};
    localparam[7:0] _e_10009 = 12;
    assign _e_10008 = \t  == _e_10009;
    assign _e_6783 = {7'd3, 4'bX};
    localparam[7:0] _e_10011 = 13;
    assign _e_10010 = \t  == _e_10011;
    assign _e_6785 = {7'd4, 4'bX};
    localparam[7:0] _e_10013 = 14;
    assign _e_10012 = \t  == _e_10013;
    assign _e_6787 = {7'd5, 4'bX};
    localparam[7:0] _e_10015 = 15;
    assign _e_10014 = \t  == _e_10015;
    assign _e_6789 = {7'd8, 4'bX};
    localparam[7:0] _e_10017 = 16;
    assign _e_10016 = \t  == _e_10017;
    assign _e_6791 = {7'd9, 4'bX};
    localparam[7:0] _e_10019 = 17;
    assign _e_10018 = \t  == _e_10019;
    assign _e_6793 = {7'd10, 4'bX};
    localparam[7:0] _e_10021 = 18;
    assign _e_10020 = \t  == _e_10021;
    assign _e_6795 = {7'd11, 4'bX};
    localparam[7:0] _e_10023 = 19;
    assign _e_10022 = \t  == _e_10023;
    assign _e_6797 = {7'd12, 4'bX};
    localparam[7:0] _e_10025 = 20;
    assign _e_10024 = \t  == _e_10025;
    assign _e_6799 = {7'd33, 4'bX};
    localparam[7:0] _e_10027 = 21;
    assign _e_10026 = \t  == _e_10027;
    assign _e_6801 = {7'd34, 4'bX};
    localparam[7:0] _e_10029 = 22;
    assign _e_10028 = \t  == _e_10029;
    assign _e_6803 = {7'd35, 4'bX};
    localparam[7:0] _e_10031 = 23;
    assign _e_10030 = \t  == _e_10031;
    assign _e_6805 = {7'd41, 4'bX};
    localparam[7:0] _e_10033 = 24;
    assign _e_10032 = \t  == _e_10033;
    assign _e_6807 = {7'd42, 4'bX};
    localparam[7:0] _e_10035 = 25;
    assign _e_10034 = \t  == _e_10035;
    assign _e_6809 = {7'd43, 4'bX};
    localparam[7:0] _e_10037 = 26;
    assign _e_10036 = \t  == _e_10037;
    assign _e_6811 = {7'd44, 4'bX};
    localparam[7:0] _e_10039 = 27;
    assign _e_10038 = \t  == _e_10039;
    assign _e_6813 = {7'd45, 4'bX};
    localparam[7:0] _e_10041 = 28;
    assign _e_10040 = \t  == _e_10041;
    assign _e_6815 = {7'd46, 4'bX};
    localparam[7:0] _e_10043 = 29;
    assign _e_10042 = \t  == _e_10043;
    assign _e_6817 = {7'd57, 4'bX};
    localparam[7:0] _e_10045 = 30;
    assign _e_10044 = \t  == _e_10045;
    assign _e_6819 = {7'd30, 4'bX};
    localparam[7:0] _e_10047 = 31;
    assign _e_10046 = \t  == _e_10047;
    assign _e_6821 = {7'd47, 4'bX};
    localparam[7:0] _e_10049 = 32;
    assign _e_10048 = \t  == _e_10049;
    assign _e_6823 = {7'd48, 4'bX};
    localparam[7:0] _e_10051 = 33;
    assign _e_10050 = \t  == _e_10051;
    assign _e_6825 = {7'd49, 4'bX};
    localparam[7:0] _e_10053 = 34;
    assign _e_10052 = \t  == _e_10053;
    assign _e_6827 = {7'd50, 4'bX};
    localparam[7:0] _e_10055 = 35;
    assign _e_10054 = \t  == _e_10055;
    assign _e_6829 = {7'd51, 4'bX};
    localparam[7:0] _e_10057 = 36;
    assign _e_10056 = \t  == _e_10057;
    assign _e_6831 = {7'd52, 4'bX};
    localparam[7:0] _e_10059 = 37;
    assign _e_10058 = \t  == _e_10059;
    assign _e_6833 = {7'd27, 4'bX};
    localparam[7:0] _e_10061 = 38;
    assign _e_10060 = \t  == _e_10061;
    assign _e_6835 = {7'd28, 4'bX};
    localparam[7:0] _e_10063 = 39;
    assign _e_10062 = \t  == _e_10063;
    assign _e_6837 = {7'd29, 4'bX};
    localparam[7:0] _e_10065 = 40;
    assign _e_10064 = \t  == _e_10065;
    assign _e_6839 = {7'd53, 4'bX};
    localparam[7:0] _e_10067 = 41;
    assign _e_10066 = \t  == _e_10067;
    assign _e_6841 = {7'd54, 4'bX};
    localparam[7:0] _e_10069 = 42;
    assign _e_10068 = \t  == _e_10069;
    assign _e_6843 = {7'd55, 4'bX};
    localparam[7:0] _e_10071 = 43;
    assign _e_10070 = \t  == _e_10071;
    assign _e_6845 = {7'd56, 4'bX};
    localparam[7:0] _e_10073 = 44;
    assign _e_10072 = \t  == _e_10073;
    assign _e_6847 = {7'd19, 4'bX};
    localparam[7:0] _e_10075 = 45;
    assign _e_10074 = \t  == _e_10075;
    assign _e_6849 = {7'd20, 4'bX};
    localparam[7:0] _e_10077 = 46;
    assign _e_10076 = \t  == _e_10077;
    assign _e_6851 = {7'd21, 4'bX};
    localparam[7:0] _e_10079 = 47;
    assign _e_10078 = \t  == _e_10079;
    assign _e_6853 = {7'd22, 4'bX};
    localparam[7:0] _e_10081 = 48;
    assign _e_10080 = \t  == _e_10081;
    assign _e_6855 = {7'd24, 4'bX};
    localparam[7:0] _e_10083 = 49;
    assign _e_10082 = \t  == _e_10083;
    assign _e_6857 = {7'd25, 4'bX};
    localparam[7:0] _e_10085 = 50;
    assign _e_10084 = \t  == _e_10085;
    assign _e_6859 = {7'd26, 4'bX};
    localparam[7:0] _e_10087 = 51;
    assign _e_10086 = \t  == _e_10087;
    assign _e_6861 = {7'd13, 4'bX};
    localparam[7:0] _e_10089 = 52;
    assign _e_10088 = \t  == _e_10089;
    assign _e_6863 = {7'd14, 4'bX};
    localparam[7:0] _e_10091 = 53;
    assign _e_10090 = \t  == _e_10091;
    assign _e_6865 = {7'd58, 4'bX};
    localparam[7:0] _e_10093 = 54;
    assign _e_10092 = \t  == _e_10093;
    assign _e_6867 = {7'd59, 4'bX};
    localparam[7:0] _e_10095 = 55;
    assign _e_10094 = \t  == _e_10095;
    assign _e_6869 = {7'd60, 4'bX};
    localparam[7:0] _e_10097 = 56;
    assign _e_10096 = \t  == _e_10097;
    assign _e_6871 = {7'd61, 4'bX};
    localparam[7:0] _e_10099 = 57;
    assign _e_10098 = \t  == _e_10099;
    assign _e_6873 = {7'd62, 4'bX};
    localparam[7:0] _e_10101 = 58;
    assign _e_10100 = \t  == _e_10101;
    assign _e_6875 = {7'd63, 4'bX};
    localparam[7:0] _e_10103 = 59;
    assign _e_10102 = \t  == _e_10103;
    assign _e_6877 = {7'd68, 4'bX};
    localparam[7:0] _e_10105 = 60;
    assign _e_10104 = \t  == _e_10105;
    assign _e_6879 = {7'd39, 4'bX};
    localparam[7:0] _e_10107 = 61;
    assign _e_10106 = \t  == _e_10107;
    assign _e_6881 = {7'd72, 4'bX};
    localparam[7:0] _e_10109 = 62;
    assign _e_10108 = \t  == _e_10109;
    assign _e_6883 = {7'd64, 4'bX};
    localparam[7:0] _e_10111 = 63;
    assign _e_10110 = \t  == _e_10111;
    assign _e_6885 = {7'd65, 4'bX};
    localparam[7:0] _e_10113 = 64;
    assign _e_10112 = \t  == _e_10113;
    assign _e_6887 = {7'd66, 4'bX};
    localparam[7:0] _e_10115 = 65;
    assign _e_10114 = \t  == _e_10115;
    assign _e_6889 = {7'd67, 4'bX};
    localparam[7:0] _e_10117 = 66;
    assign _e_10116 = \t  == _e_10117;
    assign _e_6891 = {7'd15, 4'bX};
    localparam[7:0] _e_10119 = 67;
    assign _e_10118 = \t  == _e_10119;
    assign _e_6893 = {7'd16, 4'bX};
    localparam[7:0] _e_10121 = 68;
    assign _e_10120 = \t  == _e_10121;
    assign _e_6895 = {7'd17, 4'bX};
    localparam[7:0] _e_10123 = 69;
    assign _e_10122 = \t  == _e_10123;
    assign _e_6897 = {7'd18, 4'bX};
    localparam[7:0] _e_10125 = 70;
    assign _e_10124 = \t  == _e_10125;
    assign _e_6899 = {7'd69, 4'bX};
    localparam[7:0] _e_10127 = 71;
    assign _e_10126 = \t  == _e_10127;
    assign _e_6901 = {7'd70, 4'bX};
    localparam[7:0] _e_10129 = 72;
    assign _e_10128 = \t  == _e_10129;
    assign _e_6903 = {7'd71, 4'bX};
    localparam[7:0] _e_10131 = 73;
    assign _e_10130 = \t  == _e_10131;
    assign _e_6905 = {7'd36, 4'bX};
    localparam[7:0] _e_10133 = 74;
    assign _e_10132 = \t  == _e_10133;
    assign _e_6907 = {7'd37, 4'bX};
    localparam[7:0] _e_10135 = 75;
    assign _e_10134 = \t  == _e_10135;
    assign _e_6909 = {7'd38, 4'bX};
    localparam[7:0] _e_10137 = 76;
    assign _e_10136 = \t  == _e_10137;
    assign _e_6911 = {7'd73, 4'bX};
    localparam[7:0] _e_10139 = 77;
    assign _e_10138 = \t  == _e_10139;
    assign _e_6913 = {7'd6, 4'bX};
    localparam[7:0] _e_10141 = 78;
    assign _e_10140 = \t  == _e_10141;
    assign _e_6915 = {7'd74, 4'bX};
    localparam[7:0] _e_10143 = 79;
    assign _e_10142 = \t  == _e_10143;
    assign _e_6917 = {7'd75, 4'bX};
    localparam[7:0] _e_10145 = 100;
    assign _e_10144 = \t  == _e_10145;
    localparam[3:0] _e_6920 = 8;
    assign _e_6919 = {7'd0, _e_6920};
    localparam[7:0] _e_10147 = 101;
    assign _e_10146 = \t  == _e_10147;
    localparam[3:0] _e_6923 = 9;
    assign _e_6922 = {7'd0, _e_6923};
    localparam[7:0] _e_10149 = 102;
    assign _e_10148 = \t  == _e_10149;
    localparam[3:0] _e_6926 = 10;
    assign _e_6925 = {7'd0, _e_6926};
    localparam[7:0] _e_10151 = 103;
    assign _e_10150 = \t  == _e_10151;
    localparam[3:0] _e_6929 = 11;
    assign _e_6928 = {7'd0, _e_6929};
    localparam[7:0] _e_10153 = 104;
    assign _e_10152 = \t  == _e_10153;
    localparam[3:0] _e_6932 = 12;
    assign _e_6931 = {7'd0, _e_6932};
    localparam[7:0] _e_10155 = 105;
    assign _e_10154 = \t  == _e_10155;
    localparam[3:0] _e_6935 = 13;
    assign _e_6934 = {7'd0, _e_6935};
    localparam[7:0] _e_10157 = 106;
    assign _e_10156 = \t  == _e_10157;
    localparam[3:0] _e_6938 = 14;
    assign _e_6937 = {7'd0, _e_6938};
    localparam[7:0] _e_10159 = 107;
    assign _e_10158 = \t  == _e_10159;
    localparam[3:0] _e_6941 = 15;
    assign _e_6940 = {7'd0, _e_6941};
    assign \_  = \t ;
    localparam[0:0] _e_10160 = 1;
    assign _e_6943 = {7'd1, 4'bX};
    always_comb begin
        priority casez ({_e_9988, _e_9990, _e_9992, _e_9994, _e_9996, _e_9998, _e_10000, _e_10002, _e_10004, _e_10006, _e_10008, _e_10010, _e_10012, _e_10014, _e_10016, _e_10018, _e_10020, _e_10022, _e_10024, _e_10026, _e_10028, _e_10030, _e_10032, _e_10034, _e_10036, _e_10038, _e_10040, _e_10042, _e_10044, _e_10046, _e_10048, _e_10050, _e_10052, _e_10054, _e_10056, _e_10058, _e_10060, _e_10062, _e_10064, _e_10066, _e_10068, _e_10070, _e_10072, _e_10074, _e_10076, _e_10078, _e_10080, _e_10082, _e_10084, _e_10086, _e_10088, _e_10090, _e_10092, _e_10094, _e_10096, _e_10098, _e_10100, _e_10102, _e_10104, _e_10106, _e_10108, _e_10110, _e_10112, _e_10114, _e_10116, _e_10118, _e_10120, _e_10122, _e_10124, _e_10126, _e_10128, _e_10130, _e_10132, _e_10134, _e_10136, _e_10138, _e_10140, _e_10142, _e_10144, _e_10146, _e_10148, _e_10150, _e_10152, _e_10154, _e_10156, _e_10158, _e_10160})
            87'b1??????????????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6755;
            87'b01?????????????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6758;
            87'b001????????????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6761;
            87'b0001???????????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6764;
            87'b00001??????????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6767;
            87'b000001?????????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6770;
            87'b0000001????????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6773;
            87'b00000001???????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6776;
            87'b000000001??????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6779;
            87'b0000000001?????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6781;
            87'b00000000001????????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6783;
            87'b000000000001???????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6785;
            87'b0000000000001??????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6787;
            87'b00000000000001?????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6789;
            87'b000000000000001????????????????????????????????????????????????????????????????????????: _e_6752 = _e_6791;
            87'b0000000000000001???????????????????????????????????????????????????????????????????????: _e_6752 = _e_6793;
            87'b00000000000000001??????????????????????????????????????????????????????????????????????: _e_6752 = _e_6795;
            87'b000000000000000001?????????????????????????????????????????????????????????????????????: _e_6752 = _e_6797;
            87'b0000000000000000001????????????????????????????????????????????????????????????????????: _e_6752 = _e_6799;
            87'b00000000000000000001???????????????????????????????????????????????????????????????????: _e_6752 = _e_6801;
            87'b000000000000000000001??????????????????????????????????????????????????????????????????: _e_6752 = _e_6803;
            87'b0000000000000000000001?????????????????????????????????????????????????????????????????: _e_6752 = _e_6805;
            87'b00000000000000000000001????????????????????????????????????????????????????????????????: _e_6752 = _e_6807;
            87'b000000000000000000000001???????????????????????????????????????????????????????????????: _e_6752 = _e_6809;
            87'b0000000000000000000000001??????????????????????????????????????????????????????????????: _e_6752 = _e_6811;
            87'b00000000000000000000000001?????????????????????????????????????????????????????????????: _e_6752 = _e_6813;
            87'b000000000000000000000000001????????????????????????????????????????????????????????????: _e_6752 = _e_6815;
            87'b0000000000000000000000000001???????????????????????????????????????????????????????????: _e_6752 = _e_6817;
            87'b00000000000000000000000000001??????????????????????????????????????????????????????????: _e_6752 = _e_6819;
            87'b000000000000000000000000000001?????????????????????????????????????????????????????????: _e_6752 = _e_6821;
            87'b0000000000000000000000000000001????????????????????????????????????????????????????????: _e_6752 = _e_6823;
            87'b00000000000000000000000000000001???????????????????????????????????????????????????????: _e_6752 = _e_6825;
            87'b000000000000000000000000000000001??????????????????????????????????????????????????????: _e_6752 = _e_6827;
            87'b0000000000000000000000000000000001?????????????????????????????????????????????????????: _e_6752 = _e_6829;
            87'b00000000000000000000000000000000001????????????????????????????????????????????????????: _e_6752 = _e_6831;
            87'b000000000000000000000000000000000001???????????????????????????????????????????????????: _e_6752 = _e_6833;
            87'b0000000000000000000000000000000000001??????????????????????????????????????????????????: _e_6752 = _e_6835;
            87'b00000000000000000000000000000000000001?????????????????????????????????????????????????: _e_6752 = _e_6837;
            87'b000000000000000000000000000000000000001????????????????????????????????????????????????: _e_6752 = _e_6839;
            87'b0000000000000000000000000000000000000001???????????????????????????????????????????????: _e_6752 = _e_6841;
            87'b00000000000000000000000000000000000000001??????????????????????????????????????????????: _e_6752 = _e_6843;
            87'b000000000000000000000000000000000000000001?????????????????????????????????????????????: _e_6752 = _e_6845;
            87'b0000000000000000000000000000000000000000001????????????????????????????????????????????: _e_6752 = _e_6847;
            87'b00000000000000000000000000000000000000000001???????????????????????????????????????????: _e_6752 = _e_6849;
            87'b000000000000000000000000000000000000000000001??????????????????????????????????????????: _e_6752 = _e_6851;
            87'b0000000000000000000000000000000000000000000001?????????????????????????????????????????: _e_6752 = _e_6853;
            87'b00000000000000000000000000000000000000000000001????????????????????????????????????????: _e_6752 = _e_6855;
            87'b000000000000000000000000000000000000000000000001???????????????????????????????????????: _e_6752 = _e_6857;
            87'b0000000000000000000000000000000000000000000000001??????????????????????????????????????: _e_6752 = _e_6859;
            87'b00000000000000000000000000000000000000000000000001?????????????????????????????????????: _e_6752 = _e_6861;
            87'b000000000000000000000000000000000000000000000000001????????????????????????????????????: _e_6752 = _e_6863;
            87'b0000000000000000000000000000000000000000000000000001???????????????????????????????????: _e_6752 = _e_6865;
            87'b00000000000000000000000000000000000000000000000000001??????????????????????????????????: _e_6752 = _e_6867;
            87'b000000000000000000000000000000000000000000000000000001?????????????????????????????????: _e_6752 = _e_6869;
            87'b0000000000000000000000000000000000000000000000000000001????????????????????????????????: _e_6752 = _e_6871;
            87'b00000000000000000000000000000000000000000000000000000001???????????????????????????????: _e_6752 = _e_6873;
            87'b000000000000000000000000000000000000000000000000000000001??????????????????????????????: _e_6752 = _e_6875;
            87'b0000000000000000000000000000000000000000000000000000000001?????????????????????????????: _e_6752 = _e_6877;
            87'b00000000000000000000000000000000000000000000000000000000001????????????????????????????: _e_6752 = _e_6879;
            87'b000000000000000000000000000000000000000000000000000000000001???????????????????????????: _e_6752 = _e_6881;
            87'b0000000000000000000000000000000000000000000000000000000000001??????????????????????????: _e_6752 = _e_6883;
            87'b00000000000000000000000000000000000000000000000000000000000001?????????????????????????: _e_6752 = _e_6885;
            87'b000000000000000000000000000000000000000000000000000000000000001????????????????????????: _e_6752 = _e_6887;
            87'b0000000000000000000000000000000000000000000000000000000000000001???????????????????????: _e_6752 = _e_6889;
            87'b00000000000000000000000000000000000000000000000000000000000000001??????????????????????: _e_6752 = _e_6891;
            87'b000000000000000000000000000000000000000000000000000000000000000001?????????????????????: _e_6752 = _e_6893;
            87'b0000000000000000000000000000000000000000000000000000000000000000001????????????????????: _e_6752 = _e_6895;
            87'b00000000000000000000000000000000000000000000000000000000000000000001???????????????????: _e_6752 = _e_6897;
            87'b000000000000000000000000000000000000000000000000000000000000000000001??????????????????: _e_6752 = _e_6899;
            87'b0000000000000000000000000000000000000000000000000000000000000000000001?????????????????: _e_6752 = _e_6901;
            87'b00000000000000000000000000000000000000000000000000000000000000000000001????????????????: _e_6752 = _e_6903;
            87'b000000000000000000000000000000000000000000000000000000000000000000000001???????????????: _e_6752 = _e_6905;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000001??????????????: _e_6752 = _e_6907;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000001?????????????: _e_6752 = _e_6909;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000001????????????: _e_6752 = _e_6911;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000000001???????????: _e_6752 = _e_6913;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000000001??????????: _e_6752 = _e_6915;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000000001?????????: _e_6752 = _e_6917;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000000000001????????: _e_6752 = _e_6919;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000000000001???????: _e_6752 = _e_6922;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000000000001??????: _e_6752 = _e_6925;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000000000000001?????: _e_6752 = _e_6928;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000000000000001????: _e_6752 = _e_6931;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000000000000001???: _e_6752 = _e_6934;
            87'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000001??: _e_6752 = _e_6937;
            87'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000001?: _e_6752 = _e_6940;
            87'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000001: _e_6752 = _e_6943;
            87'b?: _e_6752 = 11'dx;
        endcase
    end
    assign output__ = _e_6752;
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
    logic[31:0] _e_6947;
    (* src = "src/imem.spade:228,36" *)
    logic[31:0] _e_6946;
    (* src = "src/imem.spade:228,30" *)
    logic \guard_bit ;
    (* src = "src/imem.spade:229,23" *)
    logic \guard ;
    (* src = "src/imem.spade:231,34" *)
    logic[31:0] _e_6958;
    (* src = "src/imem.spade:231,34" *)
    logic[31:0] _e_6957;
    (* src = "src/imem.spade:231,28" *)
    logic[7:0] \src_tok ;
    (* src = "src/imem.spade:232,34" *)
    logic[31:0] _e_6965;
    (* src = "src/imem.spade:232,34" *)
    logic[31:0] _e_6964;
    (* src = "src/imem.spade:232,28" *)
    logic[7:0] \dst_tok ;
    (* src = "src/imem.spade:233,34" *)
    logic[31:0] _e_6971;
    (* src = "src/imem.spade:233,28" *)
    logic[15:0] \imm16 ;
    (* src = "src/imem.spade:235,15" *)
    logic[36:0] \src ;
    (* src = "src/imem.spade:236,15" *)
    logic[10:0] \dst ;
    (* src = "src/imem.spade:237,5" *)
    logic[48:0] _e_6982;
    localparam[31:0] _e_6949 = 32'd31;
    assign _e_6947 = \mw  >> _e_6949;
    localparam[31:0] _e_6950 = 32'd1;
    assign _e_6946 = _e_6947 & _e_6950;
    assign \guard_bit  = _e_6946[0:0];
    localparam[0:0] _e_6954 = 0;
    assign \guard  = \guard_bit  != _e_6954;
    localparam[31:0] _e_6960 = 32'd24;
    assign _e_6958 = \mw  >> _e_6960;
    localparam[31:0] _e_6961 = 32'd127;
    assign _e_6957 = _e_6958 & _e_6961;
    assign \src_tok  = _e_6957[7:0];
    localparam[31:0] _e_6967 = 32'd17;
    assign _e_6965 = \mw  >> _e_6967;
    localparam[31:0] _e_6968 = 32'd127;
    assign _e_6964 = _e_6965 & _e_6968;
    assign \dst_tok  = _e_6964[7:0];
    localparam[31:0] _e_6973 = 32'd65535;
    assign _e_6971 = \mw  & _e_6973;
    assign \imm16  = _e_6971[15:0];
    (* src = "src/imem.spade:235,15" *)
    \tta::imem::decode_src_tok  decode_src_tok_0(.t_i(\src_tok ), .imm16_i(\imm16 ), .output__(\src ));
    (* src = "src/imem.spade:236,15" *)
    \tta::imem::decode_dst_tok  decode_dst_tok_0(.t_i(\dst_tok ), .output__(\dst ));
    assign _e_6982 = {\src , \dst , \guard };
    assign output__ = _e_6982;
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
    localparam[31:0] _e_6987 = 32'd0;
    assign output__ = _e_6987;
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
    logic _e_10162;
    logic _e_10164;
    (* src = "src/imem.spade:266,23" *)
    logic[10:0] _e_6993;
    logic _e_10166;
    (* src = "src/imem.spade:267,17" *)
    logic[10:0] _e_6997;
    (* src = "src/imem.spade:265,29" *)
    logic[10:0] _e_7002;
    (* src = "src/imem.spade:265,9" *)
    logic \wren ;
    (* src = "src/imem.spade:265,9" *)
    logic[9:0] \addr_calc ;
    (* src = "src/imem.spade:270,9" *)
    logic[31:0] \instr ;
    logic _e_10168;
    logic _e_10170;
    logic _e_10172;
    (* src = "src/imem.spade:269,18" *)
    logic[31:0] \wdata0 ;
    (* src = "src/imem.spade:274,9" *)
    logic[31:0] instr_n1;
    logic _e_10174;
    logic _e_10176;
    logic _e_10178;
    (* src = "src/imem.spade:273,18" *)
    logic[31:0] \wdata1 ;
    (* src = "src/imem.spade:278,33" *)
    logic[31:0] _e_7021;
    (* src = "src/imem.spade:278,14" *)
    reg[31:0] \rdata0 ;
    (* src = "src/imem.spade:279,33" *)
    logic[31:0] _e_7029;
    (* src = "src/imem.spade:279,14" *)
    reg[31:0] \rdata1 ;
    (* src = "src/imem.spade:283,9" *)
    logic[9:0] \_ ;
    logic _e_10180;
    logic _e_10182;
    (* src = "src/imem.spade:283,20" *)
    logic[98:0] _e_7039;
    logic _e_10184;
    (* src = "src/imem.spade:286,25" *)
    logic[98:0] _e_7045;
    logic _e_10186;
    (* src = "src/imem.spade:288,31" *)
    logic[48:0] \mv0 ;
    (* src = "src/imem.spade:289,31" *)
    logic[48:0] \mv1 ;
    (* src = "src/imem.spade:290,26" *)
    logic[97:0] _e_7055;
    (* src = "src/imem.spade:290,21" *)
    logic[98:0] _e_7054;
    (* src = "src/imem.spade:285,13" *)
    logic[98:0] _e_7042;
    (* src = "src/imem.spade:282,5" *)
    logic[98:0] _e_7035;
    assign \addr  = \wr_addr [9:0];
    assign _e_10162 = \wr_addr [10] == 1'd1;
    localparam[0:0] _e_10163 = 1;
    assign _e_10164 = _e_10162 && _e_10163;
    localparam[0:0] _e_6994 = 1;
    assign _e_6993 = {_e_6994, \addr };
    assign _e_10166 = \wr_addr [10] == 1'd0;
    localparam[0:0] _e_6998 = 0;
    assign _e_6997 = {_e_6998, \fetch_pc };
    always_comb begin
        priority casez ({_e_10164, _e_10166})
            2'b1?: _e_7002 = _e_6993;
            2'b01: _e_7002 = _e_6997;
            2'b?: _e_7002 = 11'dx;
        endcase
    end
    assign \wren  = _e_7002[10];
    assign \addr_calc  = _e_7002[9:0];
    assign \instr  = \wr_slot0 [31:0];
    assign _e_10168 = \wr_slot0 [32] == 1'd1;
    localparam[0:0] _e_10169 = 1;
    assign _e_10170 = _e_10168 && _e_10169;
    assign _e_10172 = \wr_slot0 [32] == 1'd0;
    localparam[31:0] _e_7009 = 32'd0;
    always_comb begin
        priority casez ({_e_10170, _e_10172})
            2'b1?: \wdata0  = \instr ;
            2'b01: \wdata0  = _e_7009;
            2'b?: \wdata0  = 32'dx;
        endcase
    end
    assign instr_n1 = \wr_slot1 [31:0];
    assign _e_10174 = \wr_slot1 [32] == 1'd1;
    localparam[0:0] _e_10175 = 1;
    assign _e_10176 = _e_10174 && _e_10175;
    assign _e_10178 = \wr_slot1 [32] == 1'd0;
    localparam[31:0] _e_7017 = 32'd0;
    always_comb begin
        priority casez ({_e_10176, _e_10178})
            2'b1?: \wdata1  = instr_n1;
            2'b01: \wdata1  = _e_7017;
            2'b?: \wdata1  = 32'dx;
        endcase
    end
    (* src = "src/imem.spade:278,33" *)
    \tta::sram::iram_1024x32  iram_1024x32_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .addr_i(\addr_calc ), .we_i(\wren ), .wdata_i(\wdata0 ), .output__(_e_7021));
    always @(posedge \clk ) begin
        \rdata0  <= _e_7021;
    end
    (* src = "src/imem.spade:279,33" *)
    \tta::sram::iram_1024x32  iram_1024x32_1(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .addr_i(\addr_calc ), .we_i(\wren ), .wdata_i(\wdata1 ), .output__(_e_7029));
    always @(posedge \clk ) begin
        \rdata1  <= _e_7029;
    end
    assign \_  = \wr_addr [9:0];
    assign _e_10180 = \wr_addr [10] == 1'd1;
    localparam[0:0] _e_10181 = 1;
    assign _e_10182 = _e_10180 && _e_10181;
    assign _e_7039 = {1'd0, 98'bX};
    assign _e_10184 = \wr_addr [10] == 1'd0;
    assign _e_7045 = {1'd0, 98'bX};
    assign _e_10186 = !\boot_mode ;
    (* src = "src/imem.spade:288,31" *)
    \tta::imem::decode_move  decode_move_0(.mw_i(\rdata0 ), .output__(\mv0 ));
    (* src = "src/imem.spade:289,31" *)
    \tta::imem::decode_move  decode_move_1(.mw_i(\rdata1 ), .output__(\mv1 ));
    assign _e_7055 = {\mv0 , \mv1 };
    assign _e_7054 = {1'd1, _e_7055};
    always_comb begin
        priority casez ({\boot_mode , _e_10186})
            2'b1?: _e_7042 = _e_7045;
            2'b01: _e_7042 = _e_7054;
            2'b?: _e_7042 = 99'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10182, _e_10184})
            2'b1?: _e_7035 = _e_7039;
            2'b01: _e_7035 = _e_7042;
            2'b?: _e_7035 = 99'dx;
        endcase
    end
    assign output__ = _e_7035;
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
    logic _e_7060;
    (* src = "src/spi_master.spade:26,5" *)
    logic[14:0] _e_7059;
    assign _e_7060 = {1'd0};
    localparam[4:0] _e_7061 = 0;
    localparam[7:0] _e_7062 = 0;
    localparam[0:0] _e_7063 = 0;
    assign _e_7059 = {_e_7060, _e_7061, _e_7062, _e_7063};
    assign output__ = _e_7059;
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
    logic[14:0] _e_7068;
    (* src = "src/spi_master.spade:39,19" *)
    logic _e_7073;
    (* src = "src/spi_master.spade:40,17" *)
    logic _e_7075;
    logic _e_10188;
    (* src = "src/spi_master.spade:41,27" *)
    logic[8:0] _e_7078;
    (* src = "src/spi_master.spade:43,25" *)
    logic[8:0] _e_7081;
    (* src = "src/spi_master.spade:43,25" *)
    logic[7:0] \data ;
    logic _e_10190;
    logic _e_10192;
    (* src = "src/spi_master.spade:43,43" *)
    logic _e_7083;
    (* src = "src/spi_master.spade:43,39" *)
    logic[14:0] _e_7082;
    (* src = "src/spi_master.spade:44,25" *)
    logic[8:0] _e_7087;
    logic _e_10194;
    (* src = "src/spi_master.spade:41,21" *)
    logic[14:0] _e_7077;
    (* src = "src/spi_master.spade:47,17" *)
    logic _e_7089;
    logic _e_10196;
    (* src = "src/spi_master.spade:51,41" *)
    logic[4:0] _e_7093;
    (* src = "src/spi_master.spade:51,41" *)
    logic[5:0] _e_7092;
    (* src = "src/spi_master.spade:51,35" *)
    logic[4:0] \new_cnt ;
    (* src = "src/spi_master.spade:53,24" *)
    logic[4:0] _e_7099;
    (* src = "src/spi_master.spade:53,24" *)
    logic _e_7098;
    (* src = "src/spi_master.spade:56,29" *)
    logic _e_7104;
    (* src = "src/spi_master.spade:56,45" *)
    logic[7:0] _e_7106;
    (* src = "src/spi_master.spade:56,25" *)
    logic[14:0] _e_7103;
    (* src = "src/spi_master.spade:58,29" *)
    logic[4:0] _e_7111;
    (* src = "src/spi_master.spade:58,29" *)
    logic _e_7110;
    (* src = "src/spi_master.spade:61,29" *)
    logic _e_7117;
    (* src = "src/spi_master.spade:61,55" *)
    logic[7:0] _e_7119;
    (* src = "src/spi_master.spade:61,25" *)
    logic[14:0] _e_7116;
    (* src = "src/spi_master.spade:66,40" *)
    logic[7:0] _e_7126;
    (* src = "src/spi_master.spade:66,39" *)
    logic[7:0] _e_7125;
    (* src = "src/spi_master.spade:66,58" *)
    logic _e_7130;
    logic[7:0] _e_7129;
    (* src = "src/spi_master.spade:66,39" *)
    logic[7:0] \next_sh ;
    (* src = "src/spi_master.spade:67,29" *)
    logic _e_7134;
    (* src = "src/spi_master.spade:67,64" *)
    logic _e_7137;
    (* src = "src/spi_master.spade:67,25" *)
    logic[14:0] _e_7133;
    (* src = "src/spi_master.spade:58,26" *)
    logic[14:0] _e_7109;
    (* src = "src/spi_master.spade:53,21" *)
    logic[14:0] _e_7097;
    (* src = "src/spi_master.spade:39,13" *)
    logic[14:0] _e_7072;
    (* src = "src/spi_master.spade:38,9" *)
    logic[14:0] _e_7069;
    (* src = "src/spi_master.spade:37,14" *)
    reg[14:0] \r ;
    (* src = "src/spi_master.spade:84,20" *)
    logic _e_7142;
    (* src = "src/spi_master.spade:85,9" *)
    logic _e_7144;
    logic _e_10198;
    (* src = "src/spi_master.spade:86,9" *)
    logic _e_7146;
    logic _e_10200;
    (* src = "src/spi_master.spade:84,14" *)
    logic \cs ;
    (* src = "src/spi_master.spade:91,22" *)
    logic _e_7150;
    (* src = "src/spi_master.spade:92,9" *)
    logic _e_7152;
    logic _e_10202;
    (* src = "src/spi_master.spade:92,29" *)
    logic[4:0] _e_7155;
    (* src = "src/spi_master.spade:92,28" *)
    logic[4:0] _e_7154;
    (* src = "src/spi_master.spade:92,28" *)
    logic _e_7153;
    (* src = "src/spi_master.spade:93,9" *)
    logic _e_7159;
    logic _e_10204;
    (* src = "src/spi_master.spade:91,16" *)
    logic \sclk ;
    (* src = "src/spi_master.spade:99,23" *)
    logic[7:0] _e_7165;
    (* src = "src/spi_master.spade:99,22" *)
    logic[7:0] _e_7164;
    (* src = "src/spi_master.spade:99,22" *)
    logic _e_7163;
    (* src = "src/spi_master.spade:100,9" *)
    logic _e_7169;
    (* src = "src/spi_master.spade:101,9" *)
    logic _e_7171;
    logic _e_10206;
    (* src = "src/spi_master.spade:99,16" *)
    logic \mosi ;
    (* src = "src/spi_master.spade:106,30" *)
    logic[4:0] _e_7178;
    (* src = "src/spi_master.spade:106,29" *)
    logic _e_7177;
    (* src = "src/spi_master.spade:106,21" *)
    logic _e_7175;
    (* src = "src/spi_master.spade:109,14" *)
    logic[7:0] _e_7183;
    (* src = "src/spi_master.spade:109,9" *)
    logic[8:0] _e_7182;
    (* src = "src/spi_master.spade:111,9" *)
    logic[8:0] _e_7186;
    (* src = "src/spi_master.spade:106,18" *)
    logic[8:0] \rx_val ;
    (* src = "src/spi_master.spade:114,5" *)
    logic[11:0] _e_7188;
    (* src = "src/spi_master.spade:37,32" *)
    \tta::spi_master::reset_spi  reset_spi_0(.output__(_e_7068));
    assign _e_7073 = \r [14];
    assign _e_7075 = _e_7073;
    assign _e_10188 = _e_7073 == 1'd0;
    assign _e_7078 = \start_tx ;
    assign _e_7081 = _e_7078;
    assign \data  = _e_7078[7:0];
    assign _e_10190 = _e_7078[8] == 1'd1;
    localparam[0:0] _e_10191 = 1;
    assign _e_10192 = _e_10190 && _e_10191;
    assign _e_7083 = {1'd1};
    localparam[4:0] _e_7084 = 0;
    localparam[0:0] _e_7086 = 0;
    assign _e_7082 = {_e_7083, _e_7084, \data , _e_7086};
    assign _e_7087 = _e_7078;
    assign _e_10194 = _e_7078[8] == 1'd0;
    always_comb begin
        priority casez ({_e_10192, _e_10194})
            2'b1?: _e_7077 = _e_7082;
            2'b01: _e_7077 = \r ;
            2'b?: _e_7077 = 15'dx;
        endcase
    end
    assign _e_7089 = _e_7073;
    assign _e_10196 = _e_7073 == 1'd1;
    assign _e_7093 = \r [13:9];
    localparam[4:0] _e_7095 = 1;
    assign _e_7092 = _e_7093 + _e_7095;
    assign \new_cnt  = _e_7092[4:0];
    assign _e_7099 = \r [13:9];
    localparam[4:0] _e_7101 = 16;
    assign _e_7098 = _e_7099 == _e_7101;
    assign _e_7104 = {1'd0};
    localparam[4:0] _e_7105 = 0;
    assign _e_7106 = \r [8:1];
    localparam[0:0] _e_7108 = 0;
    assign _e_7103 = {_e_7104, _e_7105, _e_7106, _e_7108};
    localparam[4:0] _e_7113 = 2;
    assign _e_7111 = \new_cnt  % _e_7113;
    localparam[4:0] _e_7114 = 0;
    assign _e_7110 = _e_7111 != _e_7114;
    assign _e_7117 = {1'd1};
    assign _e_7119 = \r [8:1];
    assign _e_7116 = {_e_7117, \new_cnt , _e_7119, \miso };
    assign _e_7126 = \r [8:1];
    localparam[7:0] _e_7128 = 1;
    assign _e_7125 = _e_7126 << _e_7128;
    assign _e_7130 = \r [0];
    assign _e_7129 = {7'b0, _e_7130};
    assign \next_sh  = _e_7125 | _e_7129;
    assign _e_7134 = {1'd1};
    assign _e_7137 = \r [0];
    assign _e_7133 = {_e_7134, \new_cnt , \next_sh , _e_7137};
    assign _e_7109 = _e_7110 ? _e_7116 : _e_7133;
    assign _e_7097 = _e_7098 ? _e_7103 : _e_7109;
    always_comb begin
        priority casez ({_e_10188, _e_10196})
            2'b1?: _e_7072 = _e_7077;
            2'b01: _e_7072 = _e_7097;
            2'b?: _e_7072 = 15'dx;
        endcase
    end
    assign _e_7069 = \tick  ? _e_7072 : \r ;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r  <= _e_7068;
        end
        else begin
            \r  <= _e_7069;
        end
    end
    assign _e_7142 = \r [14];
    assign _e_7144 = _e_7142;
    assign _e_10198 = _e_7142 == 1'd0;
    localparam[0:0] _e_7145 = 1;
    assign _e_7146 = _e_7142;
    assign _e_10200 = _e_7142 == 1'd1;
    localparam[0:0] _e_7147 = 0;
    always_comb begin
        priority casez ({_e_10198, _e_10200})
            2'b1?: \cs  = _e_7145;
            2'b01: \cs  = _e_7147;
            2'b?: \cs  = 1'dx;
        endcase
    end
    assign _e_7150 = \r [14];
    assign _e_7152 = _e_7150;
    assign _e_10202 = _e_7150 == 1'd1;
    assign _e_7155 = \r [13:9];
    localparam[4:0] _e_7157 = 2;
    assign _e_7154 = _e_7155 % _e_7157;
    localparam[4:0] _e_7158 = 0;
    assign _e_7153 = _e_7154 != _e_7158;
    assign _e_7159 = _e_7150;
    assign _e_10204 = _e_7150 == 1'd0;
    localparam[0:0] _e_7160 = 0;
    always_comb begin
        priority casez ({_e_10202, _e_10204})
            2'b1?: \sclk  = _e_7153;
            2'b01: \sclk  = _e_7160;
            2'b?: \sclk  = 1'dx;
        endcase
    end
    assign _e_7165 = \r [8:1];
    localparam[7:0] _e_7167 = 7;
    assign _e_7164 = _e_7165 >> _e_7167;
    localparam[7:0] _e_7168 = 0;
    assign _e_7163 = _e_7164 != _e_7168;
    assign _e_7169 = _e_7163;
    localparam[0:0] _e_7170 = 1;
    assign _e_7171 = _e_7163;
    assign _e_10206 = !_e_7163;
    localparam[0:0] _e_7172 = 0;
    always_comb begin
        priority casez ({_e_7163, _e_10206})
            2'b1?: \mosi  = _e_7170;
            2'b01: \mosi  = _e_7172;
            2'b?: \mosi  = 1'dx;
        endcase
    end
    assign _e_7178 = \r [13:9];
    localparam[4:0] _e_7180 = 16;
    assign _e_7177 = _e_7178 == _e_7180;
    assign _e_7175 = \tick  && _e_7177;
    assign _e_7183 = \r [8:1];
    assign _e_7182 = {1'd1, _e_7183};
    assign _e_7186 = {1'd0, 8'bX};
    assign \rx_val  = _e_7175 ? _e_7182 : _e_7186;
    assign _e_7188 = {\cs , \sclk , \mosi , \rx_val };
    assign output__ = _e_7188;
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
    logic[31:0] _e_7198;
    (* src = "src/regfile.spade:26,14" *)
    reg[31:0] \r0 ;
    (* src = "src/regfile.spade:27,43" *)
    logic[31:0] _e_7207;
    (* src = "src/regfile.spade:27,14" *)
    reg[31:0] \r1 ;
    (* src = "src/regfile.spade:28,43" *)
    logic[31:0] _e_7216;
    (* src = "src/regfile.spade:28,14" *)
    reg[31:0] \r2 ;
    (* src = "src/regfile.spade:29,43" *)
    logic[31:0] _e_7225;
    (* src = "src/regfile.spade:29,14" *)
    reg[31:0] \r3 ;
    (* src = "src/regfile.spade:30,43" *)
    logic[31:0] _e_7234;
    (* src = "src/regfile.spade:30,14" *)
    reg[31:0] \r4 ;
    (* src = "src/regfile.spade:31,43" *)
    logic[31:0] _e_7243;
    (* src = "src/regfile.spade:31,14" *)
    reg[31:0] \r5 ;
    (* src = "src/regfile.spade:32,43" *)
    logic[31:0] _e_7252;
    (* src = "src/regfile.spade:32,14" *)
    reg[31:0] \r6 ;
    (* src = "src/regfile.spade:33,43" *)
    logic[31:0] _e_7261;
    (* src = "src/regfile.spade:33,14" *)
    reg[31:0] \r7 ;
    (* src = "src/regfile.spade:35,43" *)
    logic[31:0] _e_7270;
    (* src = "src/regfile.spade:35,14" *)
    reg[31:0] \r8 ;
    (* src = "src/regfile.spade:36,43" *)
    logic[31:0] _e_7279;
    (* src = "src/regfile.spade:36,14" *)
    reg[31:0] \r9 ;
    (* src = "src/regfile.spade:37,44" *)
    logic[31:0] _e_7288;
    (* src = "src/regfile.spade:37,14" *)
    reg[31:0] \r10 ;
    (* src = "src/regfile.spade:38,44" *)
    logic[31:0] _e_7297;
    (* src = "src/regfile.spade:38,14" *)
    reg[31:0] \r11 ;
    (* src = "src/regfile.spade:39,44" *)
    logic[31:0] _e_7306;
    (* src = "src/regfile.spade:39,14" *)
    reg[31:0] \r12 ;
    (* src = "src/regfile.spade:40,44" *)
    logic[31:0] _e_7315;
    (* src = "src/regfile.spade:40,14" *)
    reg[31:0] \r13 ;
    (* src = "src/regfile.spade:41,44" *)
    logic[31:0] _e_7324;
    (* src = "src/regfile.spade:41,14" *)
    reg[31:0] \r14 ;
    (* src = "src/regfile.spade:42,44" *)
    logic[31:0] _e_7333;
    (* src = "src/regfile.spade:42,14" *)
    reg[31:0] \r15 ;
    logic _e_10207;
    logic _e_10209;
    logic _e_10211;
    logic _e_10213;
    logic _e_10215;
    logic _e_10217;
    logic _e_10219;
    logic _e_10221;
    logic _e_10223;
    logic _e_10225;
    logic _e_10227;
    logic _e_10229;
    logic _e_10231;
    logic _e_10233;
    logic _e_10235;
    (* src = "src/regfile.spade:61,29" *)
    logic[3:0] \_ ;
    (* src = "src/regfile.spade:45,25" *)
    logic[31:0] \rd0 ;
    logic _e_10238;
    logic _e_10240;
    logic _e_10242;
    logic _e_10244;
    logic _e_10246;
    logic _e_10248;
    logic _e_10250;
    logic _e_10252;
    logic _e_10254;
    logic _e_10256;
    logic _e_10258;
    logic _e_10260;
    logic _e_10262;
    logic _e_10264;
    logic _e_10266;
    (* src = "src/regfile.spade:80,29" *)
    logic[3:0] __n1;
    (* src = "src/regfile.spade:64,25" *)
    logic[31:0] \rd1 ;
    (* src = "src/regfile.spade:83,5" *)
    logic[63:0] _e_7408;
    localparam[31:0] _e_7197 = 32'd0;
    localparam[3:0] _e_7199 = 0;
    (* src = "src/regfile.spade:26,43" *)
    \tta::regfile::write_mux  write_mux_0(.my_idx_i(_e_7199), .cur_i(\r0 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7198));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r0  <= _e_7197;
        end
        else begin
            \r0  <= _e_7198;
        end
    end
    localparam[31:0] _e_7206 = 32'd0;
    localparam[3:0] _e_7208 = 1;
    (* src = "src/regfile.spade:27,43" *)
    \tta::regfile::write_mux  write_mux_1(.my_idx_i(_e_7208), .cur_i(\r1 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7207));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r1  <= _e_7206;
        end
        else begin
            \r1  <= _e_7207;
        end
    end
    localparam[31:0] _e_7215 = 32'd0;
    localparam[3:0] _e_7217 = 2;
    (* src = "src/regfile.spade:28,43" *)
    \tta::regfile::write_mux  write_mux_2(.my_idx_i(_e_7217), .cur_i(\r2 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7216));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r2  <= _e_7215;
        end
        else begin
            \r2  <= _e_7216;
        end
    end
    localparam[31:0] _e_7224 = 32'd0;
    localparam[3:0] _e_7226 = 3;
    (* src = "src/regfile.spade:29,43" *)
    \tta::regfile::write_mux  write_mux_3(.my_idx_i(_e_7226), .cur_i(\r3 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7225));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r3  <= _e_7224;
        end
        else begin
            \r3  <= _e_7225;
        end
    end
    localparam[31:0] _e_7233 = 32'd0;
    localparam[3:0] _e_7235 = 4;
    (* src = "src/regfile.spade:30,43" *)
    \tta::regfile::write_mux  write_mux_4(.my_idx_i(_e_7235), .cur_i(\r4 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7234));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r4  <= _e_7233;
        end
        else begin
            \r4  <= _e_7234;
        end
    end
    localparam[31:0] _e_7242 = 32'd0;
    localparam[3:0] _e_7244 = 5;
    (* src = "src/regfile.spade:31,43" *)
    \tta::regfile::write_mux  write_mux_5(.my_idx_i(_e_7244), .cur_i(\r5 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7243));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r5  <= _e_7242;
        end
        else begin
            \r5  <= _e_7243;
        end
    end
    localparam[31:0] _e_7251 = 32'd0;
    localparam[3:0] _e_7253 = 6;
    (* src = "src/regfile.spade:32,43" *)
    \tta::regfile::write_mux  write_mux_6(.my_idx_i(_e_7253), .cur_i(\r6 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7252));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r6  <= _e_7251;
        end
        else begin
            \r6  <= _e_7252;
        end
    end
    localparam[31:0] _e_7260 = 32'd0;
    localparam[3:0] _e_7262 = 7;
    (* src = "src/regfile.spade:33,43" *)
    \tta::regfile::write_mux  write_mux_7(.my_idx_i(_e_7262), .cur_i(\r7 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7261));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r7  <= _e_7260;
        end
        else begin
            \r7  <= _e_7261;
        end
    end
    localparam[31:0] _e_7269 = 32'd0;
    localparam[3:0] _e_7271 = 8;
    (* src = "src/regfile.spade:35,43" *)
    \tta::regfile::write_mux  write_mux_8(.my_idx_i(_e_7271), .cur_i(\r8 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7270));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r8  <= _e_7269;
        end
        else begin
            \r8  <= _e_7270;
        end
    end
    localparam[31:0] _e_7278 = 32'd0;
    localparam[3:0] _e_7280 = 9;
    (* src = "src/regfile.spade:36,43" *)
    \tta::regfile::write_mux  write_mux_9(.my_idx_i(_e_7280), .cur_i(\r9 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7279));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r9  <= _e_7278;
        end
        else begin
            \r9  <= _e_7279;
        end
    end
    localparam[31:0] _e_7287 = 32'd0;
    localparam[3:0] _e_7289 = 10;
    (* src = "src/regfile.spade:37,44" *)
    \tta::regfile::write_mux  write_mux_10(.my_idx_i(_e_7289), .cur_i(\r10 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7288));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r10  <= _e_7287;
        end
        else begin
            \r10  <= _e_7288;
        end
    end
    localparam[31:0] _e_7296 = 32'd0;
    localparam[3:0] _e_7298 = 11;
    (* src = "src/regfile.spade:38,44" *)
    \tta::regfile::write_mux  write_mux_11(.my_idx_i(_e_7298), .cur_i(\r11 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7297));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r11  <= _e_7296;
        end
        else begin
            \r11  <= _e_7297;
        end
    end
    localparam[31:0] _e_7305 = 32'd0;
    localparam[3:0] _e_7307 = 12;
    (* src = "src/regfile.spade:39,44" *)
    \tta::regfile::write_mux  write_mux_12(.my_idx_i(_e_7307), .cur_i(\r12 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7306));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r12  <= _e_7305;
        end
        else begin
            \r12  <= _e_7306;
        end
    end
    localparam[31:0] _e_7314 = 32'd0;
    localparam[3:0] _e_7316 = 13;
    (* src = "src/regfile.spade:40,44" *)
    \tta::regfile::write_mux  write_mux_13(.my_idx_i(_e_7316), .cur_i(\r13 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7315));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r13  <= _e_7314;
        end
        else begin
            \r13  <= _e_7315;
        end
    end
    localparam[31:0] _e_7323 = 32'd0;
    localparam[3:0] _e_7325 = 14;
    (* src = "src/regfile.spade:41,44" *)
    \tta::regfile::write_mux  write_mux_14(.my_idx_i(_e_7325), .cur_i(\r14 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7324));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r14  <= _e_7323;
        end
        else begin
            \r14  <= _e_7324;
        end
    end
    localparam[31:0] _e_7332 = 32'd0;
    localparam[3:0] _e_7334 = 15;
    (* src = "src/regfile.spade:42,44" *)
    \tta::regfile::write_mux  write_mux_15(.my_idx_i(_e_7334), .cur_i(\r15 ), .w0_i(\wr0 ), .w1_i(\wr1 ), .output__(_e_7333));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \r15  <= _e_7332;
        end
        else begin
            \r15  <= _e_7333;
        end
    end
    localparam[3:0] _e_10208 = 0;
    assign _e_10207 = \ra0  == _e_10208;
    localparam[3:0] _e_10210 = 1;
    assign _e_10209 = \ra0  == _e_10210;
    localparam[3:0] _e_10212 = 2;
    assign _e_10211 = \ra0  == _e_10212;
    localparam[3:0] _e_10214 = 3;
    assign _e_10213 = \ra0  == _e_10214;
    localparam[3:0] _e_10216 = 4;
    assign _e_10215 = \ra0  == _e_10216;
    localparam[3:0] _e_10218 = 5;
    assign _e_10217 = \ra0  == _e_10218;
    localparam[3:0] _e_10220 = 6;
    assign _e_10219 = \ra0  == _e_10220;
    localparam[3:0] _e_10222 = 7;
    assign _e_10221 = \ra0  == _e_10222;
    localparam[3:0] _e_10224 = 8;
    assign _e_10223 = \ra0  == _e_10224;
    localparam[3:0] _e_10226 = 9;
    assign _e_10225 = \ra0  == _e_10226;
    localparam[3:0] _e_10228 = 10;
    assign _e_10227 = \ra0  == _e_10228;
    localparam[3:0] _e_10230 = 11;
    assign _e_10229 = \ra0  == _e_10230;
    localparam[3:0] _e_10232 = 12;
    assign _e_10231 = \ra0  == _e_10232;
    localparam[3:0] _e_10234 = 13;
    assign _e_10233 = \ra0  == _e_10234;
    localparam[3:0] _e_10236 = 14;
    assign _e_10235 = \ra0  == _e_10236;
    assign \_  = \ra0 ;
    localparam[0:0] _e_10237 = 1;
    always_comb begin
        priority casez ({_e_10207, _e_10209, _e_10211, _e_10213, _e_10215, _e_10217, _e_10219, _e_10221, _e_10223, _e_10225, _e_10227, _e_10229, _e_10231, _e_10233, _e_10235, _e_10237})
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
    localparam[3:0] _e_10239 = 0;
    assign _e_10238 = \ra1  == _e_10239;
    localparam[3:0] _e_10241 = 1;
    assign _e_10240 = \ra1  == _e_10241;
    localparam[3:0] _e_10243 = 2;
    assign _e_10242 = \ra1  == _e_10243;
    localparam[3:0] _e_10245 = 3;
    assign _e_10244 = \ra1  == _e_10245;
    localparam[3:0] _e_10247 = 4;
    assign _e_10246 = \ra1  == _e_10247;
    localparam[3:0] _e_10249 = 5;
    assign _e_10248 = \ra1  == _e_10249;
    localparam[3:0] _e_10251 = 6;
    assign _e_10250 = \ra1  == _e_10251;
    localparam[3:0] _e_10253 = 7;
    assign _e_10252 = \ra1  == _e_10253;
    localparam[3:0] _e_10255 = 8;
    assign _e_10254 = \ra1  == _e_10255;
    localparam[3:0] _e_10257 = 9;
    assign _e_10256 = \ra1  == _e_10257;
    localparam[3:0] _e_10259 = 10;
    assign _e_10258 = \ra1  == _e_10259;
    localparam[3:0] _e_10261 = 11;
    assign _e_10260 = \ra1  == _e_10261;
    localparam[3:0] _e_10263 = 12;
    assign _e_10262 = \ra1  == _e_10263;
    localparam[3:0] _e_10265 = 13;
    assign _e_10264 = \ra1  == _e_10265;
    localparam[3:0] _e_10267 = 14;
    assign _e_10266 = \ra1  == _e_10267;
    assign __n1 = \ra1 ;
    localparam[0:0] _e_10268 = 1;
    always_comb begin
        priority casez ({_e_10238, _e_10240, _e_10242, _e_10244, _e_10246, _e_10248, _e_10250, _e_10252, _e_10254, _e_10256, _e_10258, _e_10260, _e_10262, _e_10264, _e_10266, _e_10268})
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
    assign _e_7408 = {\rd0 , \rd1 };
    assign output__ = _e_7408;
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
    logic[42:0] _e_7416;
    (* src = "src/regfile.spade:89,14" *)
    logic[3:0] \i ;
    (* src = "src/regfile.spade:89,14" *)
    logic[31:0] \x ;
    logic _e_10270;
    logic _e_10272;
    logic _e_10275;
    logic _e_10276;
    logic _e_10277;
    (* src = "src/regfile.spade:89,43" *)
    logic[35:0] _e_7419;
    (* src = "src/regfile.spade:89,38" *)
    logic[36:0] _e_7418;
    (* src = "src/regfile.spade:90,9" *)
    logic[43:0] \_ ;
    (* src = "src/regfile.spade:90,14" *)
    logic[36:0] _e_7423;
    (* src = "src/regfile.spade:88,5" *)
    logic[36:0] _e_7412;
    assign _e_7416 = \m [42:0];
    assign \i  = _e_7416[36:33];
    assign \x  = _e_7416[32:1];
    assign _e_10270 = \m [43] == 1'd1;
    assign _e_10272 = _e_7416[42:37] == 6'd0;
    localparam[0:0] _e_10273 = 1;
    localparam[0:0] _e_10274 = 1;
    assign _e_10275 = _e_10272 && _e_10273;
    assign _e_10276 = _e_10275 && _e_10274;
    assign _e_10277 = _e_10270 && _e_10276;
    assign _e_7419 = {\i , \x };
    assign _e_7418 = {1'd1, _e_7419};
    assign \_  = \m ;
    localparam[0:0] _e_10278 = 1;
    assign _e_7423 = {1'd0, 36'bX};
    always_comb begin
        priority casez ({_e_10277, _e_10278})
            2'b1?: _e_7412 = _e_7418;
            2'b01: _e_7412 = _e_7423;
            2'b?: _e_7412 = 37'dx;
        endcase
    end
    assign output__ = _e_7412;
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
    logic[35:0] _e_7429;
    (* src = "src/regfile.spade:100,14" *)
    logic[3:0] \idx ;
    (* src = "src/regfile.spade:100,14" *)
    logic[31:0] \v ;
    logic _e_10280;
    logic _e_10284;
    logic _e_10285;
    (* src = "src/regfile.spade:100,30" *)
    logic _e_7432;
    (* src = "src/regfile.spade:102,17" *)
    logic[35:0] _e_7442;
    (* src = "src/regfile.spade:102,22" *)
    logic[3:0] \idx0 ;
    (* src = "src/regfile.spade:102,22" *)
    logic[31:0] \v0 ;
    logic _e_10287;
    logic _e_10291;
    logic _e_10292;
    (* src = "src/regfile.spade:102,40" *)
    logic _e_7445;
    (* src = "src/regfile.spade:102,37" *)
    logic[31:0] _e_7444;
    logic _e_10294;
    (* src = "src/regfile.spade:101,13" *)
    logic[31:0] _e_7438;
    (* src = "src/regfile.spade:100,27" *)
    logic[31:0] _e_7431;
    logic _e_10296;
    (* src = "src/regfile.spade:107,13" *)
    logic[35:0] _e_7459;
    (* src = "src/regfile.spade:107,18" *)
    logic[3:0] idx0_n1;
    (* src = "src/regfile.spade:107,18" *)
    logic[31:0] v0_n1;
    logic _e_10298;
    logic _e_10302;
    logic _e_10303;
    (* src = "src/regfile.spade:107,36" *)
    logic _e_7462;
    (* src = "src/regfile.spade:107,33" *)
    logic[31:0] _e_7461;
    logic _e_10305;
    (* src = "src/regfile.spade:106,17" *)
    logic[31:0] _e_7455;
    (* src = "src/regfile.spade:99,5" *)
    logic[31:0] _e_7425;
    assign _e_7429 = \w1 [35:0];
    assign \idx  = _e_7429[35:32];
    assign \v  = _e_7429[31:0];
    assign _e_10280 = \w1 [36] == 1'd1;
    localparam[0:0] _e_10282 = 1;
    localparam[0:0] _e_10283 = 1;
    assign _e_10284 = _e_10282 && _e_10283;
    assign _e_10285 = _e_10280 && _e_10284;
    assign _e_7432 = \idx  == \my_idx ;
    assign _e_7442 = \w0 [35:0];
    assign \idx0  = _e_7442[35:32];
    assign \v0  = _e_7442[31:0];
    assign _e_10287 = \w0 [36] == 1'd1;
    localparam[0:0] _e_10289 = 1;
    localparam[0:0] _e_10290 = 1;
    assign _e_10291 = _e_10289 && _e_10290;
    assign _e_10292 = _e_10287 && _e_10291;
    assign _e_7445 = \idx0  == \my_idx ;
    assign _e_7444 = _e_7445 ? \v0  : \cur ;
    assign _e_10294 = \w0 [36] == 1'd0;
    always_comb begin
        priority casez ({_e_10292, _e_10294})
            2'b1?: _e_7438 = _e_7444;
            2'b01: _e_7438 = \cur ;
            2'b?: _e_7438 = 32'dx;
        endcase
    end
    assign _e_7431 = _e_7432 ? \v  : _e_7438;
    assign _e_10296 = \w1 [36] == 1'd0;
    assign _e_7459 = \w0 [35:0];
    assign idx0_n1 = _e_7459[35:32];
    assign v0_n1 = _e_7459[31:0];
    assign _e_10298 = \w0 [36] == 1'd1;
    localparam[0:0] _e_10300 = 1;
    localparam[0:0] _e_10301 = 1;
    assign _e_10302 = _e_10300 && _e_10301;
    assign _e_10303 = _e_10298 && _e_10302;
    assign _e_7462 = idx0_n1 == \my_idx ;
    assign _e_7461 = _e_7462 ? v0_n1 : \cur ;
    assign _e_10305 = \w0 [36] == 1'd0;
    always_comb begin
        priority casez ({_e_10303, _e_10305})
            2'b1?: _e_7455 = _e_7461;
            2'b01: _e_7455 = \cur ;
            2'b?: _e_7455 = 32'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10285, _e_10296})
            2'b1?: _e_7425 = _e_7431;
            2'b01: _e_7425 = _e_7455;
            2'b?: _e_7425 = 32'dx;
        endcase
    end
    assign output__ = _e_7425;
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
    logic[31:0] _e_7475;
    (* src = "src/xorshift.spade:17,18" *)
    logic[31:0] _e_7474;
    (* src = "src/xorshift.spade:17,14" *)
    logic[31:0] \x1 ;
    (* src = "src/xorshift.spade:18,19" *)
    logic[31:0] _e_7481;
    (* src = "src/xorshift.spade:18,14" *)
    logic[31:0] \x2 ;
    (* src = "src/xorshift.spade:19,25" *)
    logic[31:0] _e_7488;
    (* src = "src/xorshift.spade:19,19" *)
    logic[31:0] _e_7487;
    (* src = "src/xorshift.spade:19,14" *)
    logic[31:0] \x3 ;
    localparam[31:0] _e_7477 = 32'd13;
    assign _e_7475 = \x  << _e_7477;
    assign _e_7474 = _e_7475[31:0];
    assign \x1  = \x  ^ _e_7474;
    localparam[31:0] _e_7483 = 32'd17;
    assign _e_7481 = \x1  >> _e_7483;
    assign \x2  = \x1  ^ _e_7481;
    localparam[31:0] _e_7490 = 32'd5;
    assign _e_7488 = \x2  << _e_7490;
    assign _e_7487 = _e_7488[31:0];
    assign \x3  = \x2  ^ _e_7487;
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
    logic _e_10307;
    logic _e_10309;
    (* src = "src/xorshift.spade:32,27" *)
    logic _e_7504;
    (* src = "src/xorshift.spade:32,24" *)
    logic[31:0] _e_7503;
    logic _e_10311;
    (* src = "src/xorshift.spade:31,20" *)
    logic[31:0] \base ;
    (* src = "src/xorshift.spade:37,9" *)
    logic[31:0] _e_7514;
    (* src = "src/xorshift.spade:29,14" *)
    reg[31:0] \state ;
    (* src = "src/xorshift.spade:42,47" *)
    logic[32:0] _e_7519;
    (* src = "src/xorshift.spade:44,13" *)
    logic[31:0] v_n1;
    logic _e_10313;
    logic _e_10315;
    (* src = "src/xorshift.spade:44,27" *)
    logic _e_7526;
    (* src = "src/xorshift.spade:44,24" *)
    logic[31:0] _e_7525;
    logic _e_10317;
    (* src = "src/xorshift.spade:43,20" *)
    logic[31:0] base_n1;
    (* src = "src/xorshift.spade:47,14" *)
    logic[31:0] _e_7537;
    (* src = "src/xorshift.spade:47,9" *)
    logic[32:0] _e_7536;
    (* src = "src/xorshift.spade:42,14" *)
    reg[32:0] \res ;
    localparam[31:0] _e_7497 = 32'd1;
    assign \v  = \trig [31:0];
    assign _e_10307 = \trig [32] == 1'd1;
    localparam[0:0] _e_10308 = 1;
    assign _e_10309 = _e_10307 && _e_10308;
    localparam[31:0] _e_7506 = 32'd0;
    assign _e_7504 = \v  == _e_7506;
    assign _e_7503 = _e_7504 ? \state  : \v ;
    assign _e_10311 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_10309, _e_10311})
            2'b1?: \base  = _e_7503;
            2'b01: \base  = \state ;
            2'b?: \base  = 32'dx;
        endcase
    end
    (* src = "src/xorshift.spade:37,9" *)
    \tta::xorshift::next_xorshift32  next_xorshift32_0(.x_i(\base ), .output__(_e_7514));
    always @(posedge \clk ) begin
        if (\rst ) begin
            \state  <= _e_7497;
        end
        else begin
            \state  <= _e_7514;
        end
    end
    assign _e_7519 = {1'd0, 32'bX};
    assign v_n1 = \trig [31:0];
    assign _e_10313 = \trig [32] == 1'd1;
    localparam[0:0] _e_10314 = 1;
    assign _e_10315 = _e_10313 && _e_10314;
    localparam[31:0] _e_7528 = 32'd0;
    assign _e_7526 = v_n1 == _e_7528;
    assign _e_7525 = _e_7526 ? \state  : v_n1;
    assign _e_10317 = \trig [32] == 1'd0;
    always_comb begin
        priority casez ({_e_10315, _e_10317})
            2'b1?: base_n1 = _e_7525;
            2'b01: base_n1 = \state ;
            2'b?: base_n1 = 32'dx;
        endcase
    end
    (* src = "src/xorshift.spade:47,14" *)
    \tta::xorshift::next_xorshift32  next_xorshift32_1(.x_i(base_n1), .output__(_e_7537));
    assign _e_7536 = {1'd1, _e_7537};
    always @(posedge \clk ) begin
        if (\rst ) begin
            \res  <= _e_7519;
        end
        else begin
            \res  <= _e_7536;
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
    logic[42:0] _e_7544;
    (* src = "src/xorshift.spade:55,14" *)
    logic[31:0] \x ;
    logic _e_10319;
    logic _e_10321;
    logic _e_10323;
    logic _e_10324;
    (* src = "src/xorshift.spade:55,40" *)
    logic[32:0] _e_7546;
    (* src = "src/xorshift.spade:56,9" *)
    logic[43:0] \_ ;
    (* src = "src/xorshift.spade:57,13" *)
    logic[42:0] _e_7552;
    (* src = "src/xorshift.spade:57,18" *)
    logic[31:0] x_n1;
    logic _e_10327;
    logic _e_10329;
    logic _e_10331;
    logic _e_10332;
    (* src = "src/xorshift.spade:57,44" *)
    logic[32:0] _e_7554;
    (* src = "src/xorshift.spade:58,13" *)
    logic[43:0] __n1;
    (* src = "src/xorshift.spade:58,18" *)
    logic[32:0] _e_7557;
    (* src = "src/xorshift.spade:56,14" *)
    logic[32:0] _e_7549;
    (* src = "src/xorshift.spade:54,5" *)
    logic[32:0] _e_7541;
    assign _e_7544 = \m1 [42:0];
    assign \x  = _e_7544[36:5];
    assign _e_10319 = \m1 [43] == 1'd1;
    assign _e_10321 = _e_7544[42:37] == 6'd23;
    localparam[0:0] _e_10322 = 1;
    assign _e_10323 = _e_10321 && _e_10322;
    assign _e_10324 = _e_10319 && _e_10323;
    assign _e_7546 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10325 = 1;
    assign _e_7552 = \m0 [42:0];
    assign x_n1 = _e_7552[36:5];
    assign _e_10327 = \m0 [43] == 1'd1;
    assign _e_10329 = _e_7552[42:37] == 6'd23;
    localparam[0:0] _e_10330 = 1;
    assign _e_10331 = _e_10329 && _e_10330;
    assign _e_10332 = _e_10327 && _e_10331;
    assign _e_7554 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10333 = 1;
    assign _e_7557 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10332, _e_10333})
            2'b1?: _e_7549 = _e_7554;
            2'b01: _e_7549 = _e_7557;
            2'b?: _e_7549 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10324, _e_10325})
            2'b1?: _e_7541 = _e_7546;
            2'b01: _e_7541 = _e_7549;
            2'b?: _e_7541 = 33'dx;
        endcase
    end
    assign output__ = _e_7541;
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
    logic[10:0] _e_7562;
    (* src = "src/bt.spade:13,9" *)
    logic[9:0] \v ;
    logic _e_10335;
    logic _e_10337;
    (* src = "src/bt.spade:13,20" *)
    logic[10:0] _e_7567;
    logic _e_10339;
    (* src = "src/bt.spade:12,58" *)
    logic[10:0] _e_7563;
    (* src = "src/bt.spade:12,14" *)
    reg[10:0] \target ;
    (* src = "src/bt.spade:16,11" *)
    logic[43:0] _e_7572;
    (* src = "src/bt.spade:17,9" *)
    logic[43:0] _e_7579;
    (* src = "src/bt.spade:17,9" *)
    logic[10:0] _e_7576;
    (* src = "src/bt.spade:17,10" *)
    logic[9:0] v_n1;
    (* src = "src/bt.spade:17,9" *)
    logic[32:0] _e_7578;
    (* src = "src/bt.spade:17,19" *)
    logic[31:0] \c ;
    logic _e_10342;
    logic _e_10344;
    logic _e_10346;
    logic _e_10348;
    logic _e_10349;
    (* src = "src/bt.spade:18,16" *)
    logic _e_7582;
    (* src = "src/bt.spade:18,29" *)
    logic[10:0] _e_7585;
    (* src = "src/bt.spade:18,46" *)
    logic[10:0] _e_7588;
    (* src = "src/bt.spade:18,13" *)
    logic[10:0] _e_7581;
    (* src = "src/bt.spade:20,9" *)
    logic[43:0] _e_7591;
    (* src = "src/bt.spade:20,9" *)
    logic[10:0] \_ ;
    (* src = "src/bt.spade:20,9" *)
    logic[32:0] __n1;
    logic _e_10353;
    (* src = "src/bt.spade:20,19" *)
    logic[10:0] _e_7592;
    (* src = "src/bt.spade:16,5" *)
    logic[10:0] _e_7571;
    assign _e_7562 = {1'd0, 10'bX};
    assign \v  = \jump_to [9:0];
    assign _e_10335 = \jump_to [10] == 1'd1;
    localparam[0:0] _e_10336 = 1;
    assign _e_10337 = _e_10335 && _e_10336;
    assign _e_7567 = {1'd1, \v };
    assign _e_10339 = \jump_to [10] == 1'd0;
    always_comb begin
        priority casez ({_e_10337, _e_10339})
            2'b1?: _e_7563 = _e_7567;
            2'b01: _e_7563 = \target ;
            2'b?: _e_7563 = 11'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \target  <= _e_7562;
        end
        else begin
            \target  <= _e_7563;
        end
    end
    assign _e_7572 = {\target , \condition_trig };
    assign _e_7579 = _e_7572;
    assign _e_7576 = _e_7572[43:33];
    assign v_n1 = _e_7576[9:0];
    assign _e_7578 = _e_7572[32:0];
    assign \c  = _e_7578[31:0];
    assign _e_10342 = _e_7576[10] == 1'd1;
    localparam[0:0] _e_10343 = 1;
    assign _e_10344 = _e_10342 && _e_10343;
    assign _e_10346 = _e_7578[32] == 1'd1;
    localparam[0:0] _e_10347 = 1;
    assign _e_10348 = _e_10346 && _e_10347;
    assign _e_10349 = _e_10344 && _e_10348;
    (* src = "src/bt.spade:18,16" *)
    \tta::bt::to_bool  to_bool_0(.x_i(\c ), .output__(_e_7582));
    assign _e_7585 = {1'd1, v_n1};
    assign _e_7588 = {1'd0, 10'bX};
    assign _e_7581 = _e_7582 ? _e_7585 : _e_7588;
    assign _e_7591 = _e_7572;
    assign \_  = _e_7572[43:33];
    assign __n1 = _e_7572[32:0];
    localparam[0:0] _e_10351 = 1;
    localparam[0:0] _e_10352 = 1;
    assign _e_10353 = _e_10351 && _e_10352;
    assign _e_7592 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_10349, _e_10353})
            2'b1?: _e_7571 = _e_7581;
            2'b01: _e_7571 = _e_7592;
            2'b?: _e_7571 = 11'dx;
        endcase
    end
    assign output__ = _e_7571;
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
    logic _e_7595;
    (* src = "src/bt.spade:26,5" *)
    logic _e_7594;
    localparam[31:0] _e_7597 = 32'd0;
    assign _e_7595 = \x  == _e_7597;
    localparam[0:0] _e_7599 = 0;
    localparam[0:0] _e_7601 = 1;
    assign _e_7594 = _e_7595 ? _e_7599 : _e_7601;
    assign output__ = _e_7594;
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
    logic[42:0] _e_7606;
    (* src = "src/bt.spade:37,14" *)
    logic[9:0] \a ;
    logic _e_10355;
    logic _e_10357;
    logic _e_10359;
    logic _e_10360;
    (* src = "src/bt.spade:37,36" *)
    logic[10:0] _e_7608;
    (* src = "src/bt.spade:38,9" *)
    logic[43:0] \_ ;
    (* src = "src/bt.spade:38,25" *)
    logic[42:0] _e_7614;
    (* src = "src/bt.spade:38,30" *)
    logic[9:0] a_n1;
    logic _e_10363;
    logic _e_10365;
    logic _e_10367;
    logic _e_10368;
    (* src = "src/bt.spade:38,52" *)
    logic[10:0] _e_7616;
    (* src = "src/bt.spade:38,61" *)
    logic[43:0] __n1;
    (* src = "src/bt.spade:38,66" *)
    logic[10:0] _e_7619;
    (* src = "src/bt.spade:38,14" *)
    logic[10:0] _e_7611;
    (* src = "src/bt.spade:36,5" *)
    logic[10:0] _e_7603;
    assign _e_7606 = \m1 [42:0];
    assign \a  = _e_7606[36:27];
    assign _e_10355 = \m1 [43] == 1'd1;
    assign _e_10357 = _e_7606[42:37] == 6'd18;
    localparam[0:0] _e_10358 = 1;
    assign _e_10359 = _e_10357 && _e_10358;
    assign _e_10360 = _e_10355 && _e_10359;
    assign _e_7608 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_10361 = 1;
    assign _e_7614 = \m0 [42:0];
    assign a_n1 = _e_7614[36:27];
    assign _e_10363 = \m0 [43] == 1'd1;
    assign _e_10365 = _e_7614[42:37] == 6'd18;
    localparam[0:0] _e_10366 = 1;
    assign _e_10367 = _e_10365 && _e_10366;
    assign _e_10368 = _e_10363 && _e_10367;
    assign _e_7616 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10369 = 1;
    assign _e_7619 = {1'd0, 10'bX};
    always_comb begin
        priority casez ({_e_10368, _e_10369})
            2'b1?: _e_7611 = _e_7616;
            2'b01: _e_7611 = _e_7619;
            2'b?: _e_7611 = 11'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10360, _e_10361})
            2'b1?: _e_7603 = _e_7608;
            2'b01: _e_7603 = _e_7611;
            2'b?: _e_7603 = 11'dx;
        endcase
    end
    assign output__ = _e_7603;
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
    logic[42:0] _e_7624;
    (* src = "src/bt.spade:44,14" *)
    logic[31:0] \a ;
    logic _e_10371;
    logic _e_10373;
    logic _e_10375;
    logic _e_10376;
    (* src = "src/bt.spade:44,34" *)
    logic[32:0] _e_7626;
    (* src = "src/bt.spade:45,9" *)
    logic[43:0] \_ ;
    (* src = "src/bt.spade:45,25" *)
    logic[42:0] _e_7632;
    (* src = "src/bt.spade:45,30" *)
    logic[31:0] a_n1;
    logic _e_10379;
    logic _e_10381;
    logic _e_10383;
    logic _e_10384;
    (* src = "src/bt.spade:45,50" *)
    logic[32:0] _e_7634;
    (* src = "src/bt.spade:45,59" *)
    logic[43:0] __n1;
    (* src = "src/bt.spade:45,64" *)
    logic[32:0] _e_7637;
    (* src = "src/bt.spade:45,14" *)
    logic[32:0] _e_7629;
    (* src = "src/bt.spade:43,5" *)
    logic[32:0] _e_7621;
    assign _e_7624 = \m1 [42:0];
    assign \a  = _e_7624[36:5];
    assign _e_10371 = \m1 [43] == 1'd1;
    assign _e_10373 = _e_7624[42:37] == 6'd19;
    localparam[0:0] _e_10374 = 1;
    assign _e_10375 = _e_10373 && _e_10374;
    assign _e_10376 = _e_10371 && _e_10375;
    assign _e_7626 = {1'd1, \a };
    assign \_  = \m1 ;
    localparam[0:0] _e_10377 = 1;
    assign _e_7632 = \m0 [42:0];
    assign a_n1 = _e_7632[36:5];
    assign _e_10379 = \m0 [43] == 1'd1;
    assign _e_10381 = _e_7632[42:37] == 6'd19;
    localparam[0:0] _e_10382 = 1;
    assign _e_10383 = _e_10381 && _e_10382;
    assign _e_10384 = _e_10379 && _e_10383;
    assign _e_7634 = {1'd1, a_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10385 = 1;
    assign _e_7637 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10384, _e_10385})
            2'b1?: _e_7629 = _e_7634;
            2'b01: _e_7629 = _e_7637;
            2'b?: _e_7629 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10376, _e_10377})
            2'b1?: _e_7621 = _e_7626;
            2'b01: _e_7621 = _e_7629;
            2'b?: _e_7621 = 33'dx;
        endcase
    end
    assign output__ = _e_7621;
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
    logic _e_10387;
    logic _e_10389;
    logic _e_10391;
    (* src = "src/stack_lsu.spade:21,38" *)
    logic[31:0] \_ ;
    logic _e_10393;
    logic _e_10395;
    logic _e_10397;
    (* src = "src/stack_lsu.spade:21,20" *)
    logic _e_7652;
    (* src = "src/stack_lsu.spade:22,27" *)
    logic[32:0] _e_7661;
    (* src = "src/stack_lsu.spade:22,21" *)
    logic[31:0] _e_7660;
    (* src = "src/stack_lsu.spade:24,27" *)
    logic[32:0] _e_7668;
    (* src = "src/stack_lsu.spade:24,21" *)
    logic[31:0] _e_7667;
    (* src = "src/stack_lsu.spade:23,24" *)
    logic[31:0] _e_7664;
    (* src = "src/stack_lsu.spade:21,17" *)
    logic[31:0] _e_7651;
    (* src = "src/stack_lsu.spade:18,9" *)
    logic[31:0] _e_7644;
    (* src = "src/stack_lsu.spade:17,14" *)
    reg[31:0] \sp ;
    (* src = "src/stack_lsu.spade:34,9" *)
    logic[31:0] val_n1;
    logic _e_10399;
    logic _e_10401;
    (* src = "src/stack_lsu.spade:35,43" *)
    logic[32:0] _e_7679;
    (* src = "src/stack_lsu.spade:35,37" *)
    logic[7:0] \trunc_sp ;
    (* src = "src/stack_lsu.spade:36,13" *)
    logic[40:0] _e_7683;
    logic _e_10403;
    (* src = "src/stack_lsu.spade:40,43" *)
    logic[32:0] _e_7690;
    (* src = "src/stack_lsu.spade:40,37" *)
    logic[7:0] trunc_sp_n1;
    (* src = "src/stack_lsu.spade:41,13" *)
    logic[40:0] _e_7694;
    (* src = "src/stack_lsu.spade:33,31" *)
    logic[40:0] _e_7701;
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
    logic _e_10405;
    logic _e_10407;
    logic _e_10409;
    (* src = "src/stack_lsu.spade:49,62" *)
    logic _e_7715;
    (* src = "src/stack_lsu.spade:49,50" *)
    logic _e_7713;
    (* src = "src/stack_lsu.spade:49,14" *)
    reg \pop_valid ;
    (* src = "src/stack_lsu.spade:54,20" *)
    logic[32:0] _e_7725;
    (* src = "src/stack_lsu.spade:54,41" *)
    logic[32:0] _e_7728;
    (* src = "src/stack_lsu.spade:54,5" *)
    logic[32:0] _e_7722;
    localparam[31:0] _e_7642 = 32'd0;
    assign \val  = \set_sp [31:0];
    assign _e_10387 = \set_sp [32] == 1'd1;
    localparam[0:0] _e_10388 = 1;
    assign _e_10389 = _e_10387 && _e_10388;
    assign _e_10391 = \set_sp [32] == 1'd0;
    assign \_  = \push_trig [31:0];
    assign _e_10393 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10394 = 1;
    assign _e_10395 = _e_10393 && _e_10394;
    localparam[0:0] _e_7656 = 1;
    assign _e_10397 = \push_trig [32] == 1'd0;
    localparam[0:0] _e_7658 = 0;
    always_comb begin
        priority casez ({_e_10395, _e_10397})
            2'b1?: _e_7652 = _e_7656;
            2'b01: _e_7652 = _e_7658;
            2'b?: _e_7652 = 1'dx;
        endcase
    end
    localparam[31:0] _e_7663 = 32'd1;
    assign _e_7661 = \sp  - _e_7663;
    assign _e_7660 = _e_7661[31:0];
    localparam[31:0] _e_7670 = 32'd1;
    assign _e_7668 = \sp  + _e_7670;
    assign _e_7667 = _e_7668[31:0];
    assign _e_7664 = \pop_trig  ? _e_7667 : \sp ;
    assign _e_7651 = _e_7652 ? _e_7660 : _e_7664;
    always_comb begin
        priority casez ({_e_10389, _e_10391})
            2'b1?: _e_7644 = \val ;
            2'b01: _e_7644 = _e_7651;
            2'b?: _e_7644 = 32'dx;
        endcase
    end
    always @(posedge \clk ) begin
        if (\rst ) begin
            \sp  <= _e_7642;
        end
        else begin
            \sp  <= _e_7644;
        end
    end
    assign val_n1 = \push_trig [31:0];
    assign _e_10399 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10400 = 1;
    assign _e_10401 = _e_10399 && _e_10400;
    localparam[31:0] _e_7681 = 32'd1;
    assign _e_7679 = \sp  - _e_7681;
    assign \trunc_sp  = _e_7679[7:0];
    localparam[0:0] _e_7685 = 1;
    assign _e_7683 = {\trunc_sp , _e_7685, val_n1};
    assign _e_10403 = \push_trig [32] == 1'd0;
    localparam[31:0] _e_7692 = 32'd1;
    assign _e_7690 = \sp  - _e_7692;
    assign trunc_sp_n1 = _e_7690[7:0];
    localparam[0:0] _e_7696 = 0;
    localparam[31:0] _e_7697 = 32'd0;
    assign _e_7694 = {trunc_sp_n1, _e_7696, _e_7697};
    always_comb begin
        priority casez ({_e_10401, _e_10403})
            2'b1?: _e_7701 = _e_7683;
            2'b01: _e_7701 = _e_7694;
            2'b?: _e_7701 = 41'dx;
        endcase
    end
    assign \addr  = _e_7701[40:33];
    assign \wren  = _e_7701[32];
    assign \wdata  = _e_7701[31:0];
    (* src = "src/stack_lsu.spade:46,17" *)
    \tta::sram::stack_ram_256x32  stack_ram_256x32_0(
`ifdef USE_POWER_PINS
.VDD  (VDD),
.VSS  (VSS),
`endif
.clk_i(\clk ), .rst_i(\rst ), .word_idx_i(\addr ), .we_i(\wren ), .wdata_i(\wdata ), .output__(\rdata ));
    localparam[0:0] _e_7712 = 0;
    assign __n1 = \push_trig [31:0];
    assign _e_10405 = \push_trig [32] == 1'd1;
    localparam[0:0] _e_10406 = 1;
    assign _e_10407 = _e_10405 && _e_10406;
    localparam[0:0] _e_7719 = 0;
    assign _e_10409 = \push_trig [32] == 1'd0;
    localparam[0:0] _e_7721 = 1;
    always_comb begin
        priority casez ({_e_10407, _e_10409})
            2'b1?: _e_7715 = _e_7719;
            2'b01: _e_7715 = _e_7721;
            2'b?: _e_7715 = 1'dx;
        endcase
    end
    assign _e_7713 = \pop_trig  && _e_7715;
    always @(posedge \clk ) begin
        if (\rst ) begin
            \pop_valid  <= _e_7712;
        end
        else begin
            \pop_valid  <= _e_7713;
        end
    end
    assign _e_7725 = {1'd1, \rdata };
    assign _e_7728 = {1'd0, 32'bX};
    assign _e_7722 = \pop_valid  ? _e_7725 : _e_7728;
    assign output__ = _e_7722;
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
    logic[42:0] _e_7733;
    (* src = "src/stack_lsu.spade:59,14" *)
    logic[31:0] \x ;
    logic _e_10411;
    logic _e_10413;
    logic _e_10415;
    logic _e_10416;
    (* src = "src/stack_lsu.spade:59,37" *)
    logic[32:0] _e_7735;
    (* src = "src/stack_lsu.spade:60,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:61,13" *)
    logic[42:0] _e_7741;
    (* src = "src/stack_lsu.spade:61,18" *)
    logic[31:0] x_n1;
    logic _e_10419;
    logic _e_10421;
    logic _e_10423;
    logic _e_10424;
    (* src = "src/stack_lsu.spade:61,41" *)
    logic[32:0] _e_7743;
    (* src = "src/stack_lsu.spade:62,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:62,18" *)
    logic[32:0] _e_7746;
    (* src = "src/stack_lsu.spade:60,14" *)
    logic[32:0] _e_7738;
    (* src = "src/stack_lsu.spade:58,5" *)
    logic[32:0] _e_7730;
    assign _e_7733 = \m1 [42:0];
    assign \x  = _e_7733[36:5];
    assign _e_10411 = \m1 [43] == 1'd1;
    assign _e_10413 = _e_7733[42:37] == 6'd35;
    localparam[0:0] _e_10414 = 1;
    assign _e_10415 = _e_10413 && _e_10414;
    assign _e_10416 = _e_10411 && _e_10415;
    assign _e_7735 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10417 = 1;
    assign _e_7741 = \m0 [42:0];
    assign x_n1 = _e_7741[36:5];
    assign _e_10419 = \m0 [43] == 1'd1;
    assign _e_10421 = _e_7741[42:37] == 6'd35;
    localparam[0:0] _e_10422 = 1;
    assign _e_10423 = _e_10421 && _e_10422;
    assign _e_10424 = _e_10419 && _e_10423;
    assign _e_7743 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10425 = 1;
    assign _e_7746 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10424, _e_10425})
            2'b1?: _e_7738 = _e_7743;
            2'b01: _e_7738 = _e_7746;
            2'b?: _e_7738 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10416, _e_10417})
            2'b1?: _e_7730 = _e_7735;
            2'b01: _e_7730 = _e_7738;
            2'b?: _e_7730 = 33'dx;
        endcase
    end
    assign output__ = _e_7730;
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
    logic[42:0] _e_7751;
    (* src = "src/stack_lsu.spade:69,14" *)
    logic[31:0] \x ;
    logic _e_10427;
    logic _e_10429;
    logic _e_10431;
    logic _e_10432;
    (* src = "src/stack_lsu.spade:69,42" *)
    logic[32:0] _e_7753;
    (* src = "src/stack_lsu.spade:70,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:71,13" *)
    logic[42:0] _e_7759;
    (* src = "src/stack_lsu.spade:71,18" *)
    logic[31:0] x_n1;
    logic _e_10435;
    logic _e_10437;
    logic _e_10439;
    logic _e_10440;
    (* src = "src/stack_lsu.spade:71,46" *)
    logic[32:0] _e_7761;
    (* src = "src/stack_lsu.spade:72,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:72,18" *)
    logic[32:0] _e_7764;
    (* src = "src/stack_lsu.spade:70,14" *)
    logic[32:0] _e_7756;
    (* src = "src/stack_lsu.spade:68,5" *)
    logic[32:0] _e_7748;
    assign _e_7751 = \m1 [42:0];
    assign \x  = _e_7751[36:5];
    assign _e_10427 = \m1 [43] == 1'd1;
    assign _e_10429 = _e_7751[42:37] == 6'd36;
    localparam[0:0] _e_10430 = 1;
    assign _e_10431 = _e_10429 && _e_10430;
    assign _e_10432 = _e_10427 && _e_10431;
    assign _e_7753 = {1'd1, \x };
    assign \_  = \m1 ;
    localparam[0:0] _e_10433 = 1;
    assign _e_7759 = \m0 [42:0];
    assign x_n1 = _e_7759[36:5];
    assign _e_10435 = \m0 [43] == 1'd1;
    assign _e_10437 = _e_7759[42:37] == 6'd36;
    localparam[0:0] _e_10438 = 1;
    assign _e_10439 = _e_10437 && _e_10438;
    assign _e_10440 = _e_10435 && _e_10439;
    assign _e_7761 = {1'd1, x_n1};
    assign __n1 = \m0 ;
    localparam[0:0] _e_10441 = 1;
    assign _e_7764 = {1'd0, 32'bX};
    always_comb begin
        priority casez ({_e_10440, _e_10441})
            2'b1?: _e_7756 = _e_7761;
            2'b01: _e_7756 = _e_7764;
            2'b?: _e_7756 = 33'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10432, _e_10433})
            2'b1?: _e_7748 = _e_7753;
            2'b01: _e_7748 = _e_7756;
            2'b?: _e_7748 = 33'dx;
        endcase
    end
    assign output__ = _e_7748;
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
    logic[42:0] _e_7768;
    logic _e_10443;
    logic _e_10445;
    logic _e_10446;
    (* src = "src/stack_lsu.spade:80,9" *)
    logic[43:0] \_ ;
    (* src = "src/stack_lsu.spade:81,13" *)
    logic[42:0] _e_7774;
    logic _e_10449;
    logic _e_10451;
    logic _e_10452;
    (* src = "src/stack_lsu.spade:82,13" *)
    logic[43:0] __n1;
    (* src = "src/stack_lsu.spade:80,14" *)
    logic _e_7772;
    (* src = "src/stack_lsu.spade:78,5" *)
    logic _e_7766;
    assign _e_7768 = \m1 [42:0];
    assign _e_10443 = \m1 [43] == 1'd1;
    assign _e_10445 = _e_7768[42:37] == 6'd37;
    assign _e_10446 = _e_10443 && _e_10445;
    localparam[0:0] _e_7770 = 1;
    assign \_  = \m1 ;
    localparam[0:0] _e_10447 = 1;
    assign _e_7774 = \m0 [42:0];
    assign _e_10449 = \m0 [43] == 1'd1;
    assign _e_10451 = _e_7774[42:37] == 6'd37;
    assign _e_10452 = _e_10449 && _e_10451;
    localparam[0:0] _e_7776 = 1;
    assign __n1 = \m0 ;
    localparam[0:0] _e_10453 = 1;
    localparam[0:0] _e_7778 = 0;
    always_comb begin
        priority casez ({_e_10452, _e_10453})
            2'b1?: _e_7772 = _e_7776;
            2'b01: _e_7772 = _e_7778;
            2'b?: _e_7772 = 1'dx;
        endcase
    end
    always_comb begin
        priority casez ({_e_10446, _e_10447})
            2'b1?: _e_7766 = _e_7770;
            2'b01: _e_7766 = _e_7772;
            2'b?: _e_7766 = 1'dx;
        endcase
    end
    assign output__ = _e_7766;
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