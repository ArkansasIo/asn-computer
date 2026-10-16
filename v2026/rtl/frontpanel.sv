module frontpanel (
    input  logic [15:0] address,
    input  logic [7:0] data,
    input  logic [15:0] switches,
    output logic [15:0] address_leds,
    output logic [7:0] data_leds,
    output logic [3:0] status_leds
);
    assign address_leds = address;
    assign data_leds = data;
    assign status_leds = 4'b0001;
endmodule
