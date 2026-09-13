module tb_apb_slave_interface;

    // Testbench signals
    reg         PCLK;
    reg         PRESETn;
    reg  [2:0]  PADDR;
    reg         PWRITE;
    reg         PSEL;
    reg         PENABLE;
    reg  [7:0]  PWDATA;
    reg         ss;
    reg  [7:0]  miso_data;
    reg         receive_data;
    reg         tip;

    wire [7:0]  PRDATA;
    wire        mstr, cpol, cpha, lsbfe, spi_interrupt_request;
    wire [2:0]  spiswai, sppr, spr;
    wire        PREADY, PSLVERR;
    wire        send_data;
    wire [7:0]  mosi_data;
    wire        spi_mode;

    // DUT instantiation
    apb_slave_interface DUT (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .ss(ss),
        .miso_data(miso_data),
        .receive_data(receive_data),
        .tip(tip),
        .PRDATA(PRDATA),
        .mstr(mstr),
        .cpol(cpol),
        .cpha(cpha),
        .lsbfe(lsbfe),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .spi_interrupt_request(spi_interrupt_request),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .send_data(send_data),
        .mosi_data(mosi_data),
        .spi_mode(spi_mode)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK; // 100MHz clock

    // Test sequence
    initial begin
        $display("Starting APB Slave Interface Testbench...");

        // Initialize inputs
        PRESETn      = 0;
        PSEL         = 0;
        PENABLE      = 0;
        PWRITE       = 0;
        PADDR        = 3'b000;
        PWDATA       = 8'b0;
        miso_data    = 8'hA5;  // Example incoming MISO data
        receive_data = 0;
        ss           = 1;
        tip          = 0;

        // Apply reset
        #20 PRESETn = 1;

        // Write to mstr register (PADDR = 0)
        apb_write(3'b000, 8'b00000001); // Set mstr = 1

        // Write to SPI mode register (PADDR = 7)
        apb_write(3'b111, 8'b00000001); // Set spi_mode = 1

        // Write to MOSI data (PADDR = 6)
        apb_write(3'b110, 8'h3C); // mosi_data = 0x3C

        // Read back mstr register
        apb_read(3'b000);

        // Read back MOSI data
        apb_read(3'b110);

        // Read back miso_data through APB
        apb_read(3'b110);

        // Finish simulation
        #50;
        $display("Test complete.");
        $finish;
    end

    // APB write task
    task apb_write(input [2:0] addr, input [7:0] data);
        begin
            @(posedge PCLK);
            PSEL    = 1;
            PWRITE  = 1;
            PENABLE = 0;
            PADDR   = addr;
            PWDATA  = data;

            @(posedge PCLK);
            PENABLE = 1;

            @(posedge PCLK);
            PSEL    = 0;
            PENABLE = 0;
        end
    endtask

    // APB read task
    task apb_read(input [2:0] addr);
        begin
            @(posedge PCLK);
            PSEL    = 1;
            PWRITE  = 0;
            PENABLE = 0;
            PADDR   = addr;

            @(posedge PCLK);
            PENABLE = 1;

            @(posedge PCLK);
            $display("Read from addr %0d: Data = 0x%0h", addr, PRDATA);

            PSEL    = 0;
            PENABLE = 0;
        end
    endtask
endmodule

