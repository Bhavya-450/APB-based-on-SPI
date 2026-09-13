module apb_slave_interface (
    input         PCLK,
    input         PRESETn,
    input  [2:0]  PADDR,
    input         PWRITE,
    input         PSEL,
    input         PENABLE,
    input  [7:0]  PWDATA,
    input         ss,
    input  [7:0]  miso_data,
    input         receive_data,
    input         tip,

    output reg [7:0] PRDATA,
    output reg       mstr,
    output reg       cpol,
    output reg       cpha,
    output reg       lsbfe,
    output reg [2:0] spiswai,
    output reg [2:0] sppr,
    output reg [2:0] spr,
    output reg       spi_interrupt_request,
    output reg       PREADY,
    output reg       PSLVERR,
    output reg       send_data,
    output reg [7:0] mosi_data,
    output reg       spi_mode
);

    // Internal registers
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Reset all outputs
            PRDATA  <= 8'd0;
            mstr    <= 1'b0;
            cpol    <= 1'b0;
            cpha    <= 1'b0;
            lsbfe   <= 1'b0;
            spiswai <= 3'd0;
            sppr    <= 3'd0;
            spr     <= 3'd0;
            spi_interrupt_request <= 1'b0;
            PREADY  <= 1'b0;
            PSLVERR <= 1'b0;
            send_data <= 1'b0;
            mosi_data <= 8'd0;
            spi_mode  <= 1'b0;
        end else if (PSEL && PENABLE) begin
            PREADY <= 1'b1;
            if (PWRITE) begin
                case (PADDR)
                    3'h0: mstr    <= PWDATA[0];
                    3'h1: {cpol, cpha} <= PWDATA[1:0];
                    3'h2: lsbfe   <= PWDATA[0];
                    3'h3: spiswai <= PWDATA[2:0];
                    3'h4: begin sppr <= PWDATA[2:0]; spr <= PWDATA[5:3]; end
                    3'h5: send_data <= PWDATA[0];
                    3'h6: mosi_data <= PWDATA;
                    3'h7: spi_mode  <= PWDATA[0];
                    default: PSLVERR <= 1'b1;
                endcase
            end else begin
                case (PADDR)
                    3'h0: PRDATA <= {7'd0, mstr};
                    3'h1: PRDATA <= {6'd0, cpol, cpha};
                    3'h2: PRDATA <= {7'd0, lsbfe};
                    3'h3: PRDATA <= {5'd0, spiswai};
                    3'h4: PRDATA <= {2'd0, spr, sppr};
                    3'h5: PRDATA <= {7'd0, send_data};
                    3'h6: PRDATA <= miso_data;
                    3'h7: PRDATA <= {7'd0, spi_mode};
                    default: PSLVERR <= 1'b1;
                endcase
            end
        end else begin
            PREADY <= 1'b0;
        end
    end

endmodule

    
    
