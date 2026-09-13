module SPI_TOP_module(
// SPI Slave Top Module

    // APB Interface
    input         PCLK,
    input         PRESETn,
    input  [2:0]  PADDR,
    input         PWRITE,
    input         PSEL,
    input         PENABLE,
    input  [7:0]  PWDATA,
    output [7:0]  PRDATA,
    output        PREADY,
    output        PSLVERR,
    
    // SPI Interface
    input         mosi,
    output        miso,
    input         ss,
    output        sclk,
    
    // Interrupt
    output        spi_interrupt_request
);

    // Internal signals
    wire [7:0]  BaudRateDivisor;
    wire [7:0]  mosi_data;
    wire [7:0]  miso_data;
    wire        send_data;
    wire        receive_data;
    wire        tip;
    wire        cpol, cpha, lsbfe;
    wire [2:0]  spiswai, sppr, spr;
    wire [1:0]  spi_mode;
    wire        flag_low, flag_high, flags_low, flags_high;
    wire        mstr;

    // Baud Rate Generator Instance
    baudrate_generator  u_baud_gen  (
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

    // APB Slave Interface Instance
    apb_slave_interface u_apb_slave   (
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
        .spi_mode(spi_mode),
        .mstr(mstr)
    );

    // Slave Shift Register Instance
 slave_shift_reg  (
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
        .data_mosi(mosi_data),
        .data_miso(miso_data),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high)
    );
    

    // SPI Slave Control Instance
    slave_control_select  (
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

endmodule
