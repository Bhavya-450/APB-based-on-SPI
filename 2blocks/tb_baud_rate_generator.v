module tb_baud_rate_generator;
    // Inputs
    reg        PCLK;
    reg        PRESETn;
    reg  [1:0] spi_mode;
    reg        spiswai;
    reg  [2:0] sppr;
    reg  [2:0] spr;
    reg        cpol;
    reg        cpha;
    reg        ss;

    // Outputs
    wire       sclk;
    wire       flag_low;
    wire       flag_high;
    wire       flags_low;
    wire       flags_high;
    wire [7:0] BaudRateDivisor;

    // Instantiate the DUT
    baud_generator uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .spi_mode(spi_mode),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .cpol(cpol),
        .cpha(cpha),
        .ss(ss),
        .sclk(sclk),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .BaudRateDivisor(BaudRateDivisor)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;  // 100 MHz clock (10 ns period)

    // Stimulus
    initial begin
        // Initialize
        PRESETn     = 0;
        spi_mode    = 2'b00;
        spiswai     = 0;
        sppr        = 3'b001;
        spr         = 3'b010;
        cpol        = 0;
        cpha        = 0;
        ss          = 1;   // Not selected initially

        #20;
        PRESETn = 1;

        #20;
        ss = 0;  // Select slave to start clock

        // Let the clock run for a while
        #1000;

        // Change prescaler
        sppr = 3'b010;
        spr  = 3'b001;

        #1000;
        // Deselect slave
        ss = 1;
        #100;
        $stop;
    end
endmodule 
