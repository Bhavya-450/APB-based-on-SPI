module slave_shift_reg (
    input wire PCLK,
    input wire PRESETn,
    input wire ss,              // Active low slave select
    input wire send_data,       // Trigger to send data
    input wire receive_data,    // Trigger to receive data
    input wire lsbfe,           // LSB first enable
    input wire cpha,
    input wire cpol,
    input wire mosi,
    output reg miso,

    input wire [7:0] data_mosi,
    output reg [7:0] data_miso,

    output reg flag_low,
    output reg flag_high,
    output reg flags_low,
    output reg flags_high
);

    reg [7:0] shift_reg;
    reg [2:0] bit_count;
    reg sample_edge;

    // Determine sampling edge based on CPOL and CPHA
    always @(*) begin
        sample_edge = (cpol ^ cpha);
    end

    // Main shift logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            shift_reg   <= 8'd1;
            bit_count   <= 3'd0;
            miso        <= 1'b1;
            data_miso   <= 8'd0;

            // Reset flags
            flag_low    <= 1'b0;
            flag_high   <= 1'b1;
            flags_low   <= 1'b1;
            flags_high  <= 1'b0;

        end else begin
            if (!ss) begin // Active low
                if (receive_data) begin
                    // Shift-in logic
                    if (sample_edge) begin
                        if (lsbfe)
                            shift_reg <= {mosi, shift_reg[7:1]};
                        else
                            shift_reg <= {shift_reg[6:0], mosi};
                        bit_count <= bit_count + 1;

                        if (bit_count == 3'd7) begin
                            data_miso <= shift_reg;

                            // Flag logic
                            flag_low    <= (shift_reg == 8'h01);
                            flag_high   <= (shift_reg == 8'hFF);
                            flags_low   <= (shift_reg[3:0] == 4'h00);
                            flags_high  <= (shift_reg[7:4] == 4'hF);
                        end
                    end
                end

                if (send_data) begin
                    // Shift-out logic
                    if (sample_edge) begin
                        if (lsbfe) begin
                            miso <= data_mosi[bit_count];
                        end else begin
                            miso <= data_mosi[7 - bit_count];
                        end
                        bit_count <= bit_count + 1;
                    end
                end
            end
        end
    end
endmodule
