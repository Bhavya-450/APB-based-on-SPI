module tb_spi_slave_shiftreg;
    // Clock and Reset
    reg PCLK;
    reg PRESETn;

    // SPI control
    reg ss;
    reg send_data;
    reg receive_data;
    reg lsbfe;
    reg cpha;
    reg cpol;
    reg mosi;
    wire miso;

    // Data and flags
    reg  [7:0] data_mosi;
    wire [7:0] data_miso;
    wire flag_low, flag_high, flags_low, flags_high;

    // DUT Instantiation
    spi_slave_shiftreg DUT (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .receive_data(receive_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .mosi(mosi),
        .miso(miso),
        .data_mosi(data_mosi),
        .data_miso(data_miso),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;  // 100MHz clock

    // Task to simulate 8-bit MOSI transmission
    task send_byte(input [7:0] byte_val);
        integer i;
        begin
            data_mosi = byte_val;
            receive_data = 1;
            for (i = 7; i >= 0; i = i - 1) begin
                mosi = byte_val[i];
                @(posedge PCLK);
            end
            receive_data = 0;
        end
    endtask

    // Simulation
    initial begin
        // Init
        PRESETn = 0;
        ss = 1; send_data = 0; receive_data = 0;
        lsbfe = 0; cpha = 0; cpol = 0;
        mosi = 0;
        #20;

        PRESETn = 1;
        #10;

        // Select slave
        ss = 0;

        // Case 1: Send 0x00
        $display("Sending 0x00...");
        send_byte(8'h00);
        #10;

        // Case 2: Send 0xFF
        $display("Sending 0xFF...");
        send_byte(8'hFF);
        #10;

        // Case 3: Send 0xF0
        $display("Sending 0xF0...");
        send_byte(8'hF0);
        #10;

        // Case 4: Send 0x0F
        $display("Sending 0x0F...");
        send_byte(8'h0F);
        #10;

        // Deassert slave select
        ss = 1;
        // Wait and finish
        #50;
        $display("Test completed.");
        $finish;
    end
endmodule
