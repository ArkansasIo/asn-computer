module s100_bridge #(parameter ADDR_WIDTH=24) (
    input logic clk,
    input logic reset_n,
    input logic [ADDR_WIDTH-1:0] cpu_addr,
    input logic [7:0] cpu_wdata,
    output logic [7:0] cpu_rdata,
    input logic cpu_wr,
    input logic cpu_rd,
    output logic [ADDR_WIDTH-1:0] s100_addr,
    inout wire [7:0] s100_data,
    output logic s100_wr_n,
    output logic s100_rd_n
);
    assign s100_addr = cpu_addr;
    assign s100_wr_n = ~(cpu_wr & reset_n);
    assign s100_rd_n = ~(cpu_rd & reset_n);
    assign s100_data = cpu_wr ? cpu_wdata : 8'bz;
    assign cpu_rdata = s100_data;
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            // bridge is held inactive during reset
        end
    end
endmodule
