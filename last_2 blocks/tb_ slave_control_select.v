module tb_slave_control_select;
    reg        PCLK;
    reg        PRESETn;
    reg        mstr;
    reg        spiswai;
    reg [1:0]  spi_mode;
    reg        send_data;
    reg [7:0]  BaudRateDivisor;

    wire       receive_data;
    wire       ss;
    wire       tip;

    spi_slave_control_select uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .mstr(mstr),
        .spiswai(spiswai),
        .spi_mode(spi_mode),
        .send_data(send_data),
        .BaudRateDivisor(BaudRateDivisor),
        .receive_data(receive_data),
        .ss(ss),
        .tip(tip)
    );

    // Clock generation
    always #5 PCLK = ~PCLK;

    initial begin
        // Initialize
        PCLK            = 0;
        PRESETn         = 1;
        mstr            = 0;
        spiswai         = 0;
        spi_mode        = 2'b00;
        send_data       = 0;
        BaudRateDivisor = 8'd4;

        #20 PRESETn = 1;

        #10 mstr = 1;
        #10 send_data = 1;

        #200 send_data = 1;

        #100 $finish;
    end
endmodule
