
module tb_SPI_MODULE;
    // Clock and reset
    reg PCLK;
    reg PRESETn;
    
    // APB Interface signals
    reg [2:0] PADDR;
    reg PWRITE;
    reg PSEL;
    reg PENABLE;
    reg [7:0] PWDATA;
    wire [7:0] PRDATA;
    wire PREADY;
    wire PSLVERR;
    
    // SPI Interface signals
    reg mosi;
    wire miso;
    reg ss;
    wire sclk;
    
    // Interrupt
    wire spi_interrupt_request;
    
    // Instantiate DUT
    SPI_TOP_module uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .mosi(mosi),
        .miso(miso),
        .ss(ss),
        .sclk(sclk),
        .spi_interrupt_request(spi_interrupt_request)
    );
    
    // Clock generation (50 MHz)
    initial begin
        PCLK = 0;
        forever #10 PCLK = ~PCLK; // 20ns period = 50MHz
    end
    
    // Main test sequence
    initial begin
        // Initialize inputs
        PRESETn = 0;
        PADDR = 0;
        PWRITE = 0;
        PSEL = 0;
        PENABLE = 0;
        PWDATA = 0;
        mosi = 0;
        ss = 1; // Slave not selected
        
        // Apply reset
        #100;
        PRESETn = 1;
        #100;
        
        // Test Case 1: APB Register Configuration
        $display("Test Case 1: APB Register Configuration");
        apb_write(3'h1, 8'b00000011); // Set CPOL=1, CPHA=1
        apb_write(3'h2, 8'b00000001); // Set LSB first
        apb_write(3'h4, 8'b00101000); // SPPR=2, SPR=5 (Baud rate setting)
        apb_write(3'h7, 8'b00000001); // Enable SPI mode
        
        // Verify configuration reads back correctly
        apb_read(3'h1); // Should return 00000011
        apb_read(3'h4); // Should return 00101000
        
        // Test Case 2: SPI Data Transmission
        $display("\nTest Case 2: SPI Data Transmission");
        
        // Prepare data to send
        apb_write(3'h6, 8'b10101010); // MOSI data
        
        // Trigger transmission
        apb_write(3'h5, 8'b00000001); // Set send_data
        
        // SPI transaction
        ss = 0; // Select slave
        #100;
        
        // Simulate master sending data (0x55)
        spi_transfer(8'b01010101);
        
        ss = 1; // Deselect slave
        #200;
        
        // Read received data
        apb_read(3'h6); // Should show received data (0x55)
        
        // Test Case 3: Interrupt Test
        $display("\nTest Case 3: Interrupt Test");
        // (Add test for interrupt conditions)
        
        #500;
        $display("All tests completed");
        $finish;
    end
    
    // Task for APB write
    task apb_write;
        input [2:0] addr;
        input [7:0] data;
        begin
            @(posedge PCLK);
            PSEL = 1;
            PENABLE = 0;
            PADDR = addr;
            PWRITE = 1;
            PWDATA = data;
            @(posedge PCLK);
            PENABLE = 1;
            @(posedge PCLK);
            while (!PREADY) @(posedge PCLK);
            PSEL = 0;
            PENABLE = 0;
            $display("APB Write: Addr=0x%h, Data=0x%h", addr, data);
        end
    endtask
    
    // Task for APB read
    task apb_read;
        input [2:0] addr;
        begin
            @(posedge PCLK);
            PSEL = 1;
            PENABLE = 0;
            PADDR = addr;
            PWRITE = 0;
            @(posedge PCLK);
            PENABLE = 1;
            @(posedge PCLK);
            while (!PREADY) @(posedge PCLK);
            $display("APB Read: Addr=0x%h, Data=0x%h", addr, PRDATA);
            PSEL = 0;
            PENABLE = 0;
        end
    endtask
    
    // Task for SPI transfer
    task spi_transfer;
        input [7:0] data;
        integer i;
        begin
            for (i = 0; i < 8; i = i + 1) begin
                // Sample on falling edge (for CPOL=1, CPHA=1)
                @(negedge sclk);
                mosi = data[7-i]; // MSB first
                #5; // Small delay for setup
            end
            $display("SPI Master Sent: 0x%h", data);
        end
    endtask
    
    // Monitor important signals
    initial begin
        $monitor("TIME=%0t SS=%b SCLK=%b MOSI=%b MISO=%b IRQ=%b", 
                 $time, ss, sclk, mosi, miso, spi_interrupt_request);
    end
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("spi_slave_tb.vcd");
        $dumpvars(0, tb_SPL_TOP_module);
    end
endmodule
