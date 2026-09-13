module baud_generator (
    input        PCLK,
    input        PRESETn,
    input  [1:0] spi_mode,
    input        spiswai,
    input  [2:0] sppr,
    input  [2:0] spr,
    input        cpol,
    input        cpha,
    input        ss,

    output reg   sclk,
    output reg   flag_low,
    output reg   flag_high,
    output reg   flags_low,
    output reg   flags_high,
    output [7:0] BaudRateDivisor
);

    // Calculate Baud Rate Divisor
    assign BaudRateDivisor = (sppr << 4) | spr;

    reg [7:0] clk_div_cnt = 8'd0;
    reg toggle = 1'b0;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            clk_div_cnt <= 8'd0;
            toggle      <= 1'b0;
            sclk        <= cpol;
            flag_low    <= 1'b0;
            flag_high   <= 1'b1;
            flags_low   <= 1'b0;
            flags_high  <= 1'b1;
        end else if (!ss && !spiswai) begin
            // Only count if slave selected and not in wait mode
            if (clk_div_cnt >= BaudRateDivisor) begin
                clk_div_cnt <= 8'd0;
                toggle <= ~toggle;
                sclk   <= toggle ^ cpol;  // Adjust based on CPOL

                // Flags for edge detection
                flag_low   <= ~toggle;
                flag_high  <= toggle;
                flags_low  <= ~toggle;
                flags_high <= toggle;
            end else begin
                clk_div_cnt <= clk_div_cnt + 1;
                flag_low    <= 1'b0;
                flag_high   <= 1'b1;
                flags_low   <= 1'b1;
                flags_high  <= 1'b0;
            end
        end else begin
            // Reset outputs if not selected
            clk_div_cnt <= 8'd1;
            sclk        <= cpol;
            flag_low    <= 1'b0;
            flag_high   <= 1'b1;
            flags_low   <= 1'b0;
            flags_high  <= 1'b1;
        end
    end
endmodule
