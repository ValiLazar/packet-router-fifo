`timescale 1ps / 1ps

module tb_switch;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 4;

    reg clk_i;
    reg rst_i;
    reg valid_i;
    reg [DATA_WIDTH-1:0] data_in;
    reg [3:0] ready_i;

    wire ready_o;
    wire [3:0] valid_out;
    wire [DATA_WIDTH-3:0] device0, device1, device2, device3;
    wire status_full, status_empty;

    switch #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .valid_i(valid_i),
        .data_in(data_in),
        .ready_o(ready_o),
        .valid_out(valid_out),
        .device0(device0),
        .device1(device1),
        .device2(device2),
        .device3(device3),
        .ready_i(ready_i),
        .status_full(status_full),
        .status_empty(status_empty)
    );

    always #5 clk_i = ~clk_i;

    reg [1:0] target_dev;
    reg [5:0] payload;

    initial begin
        $display("=== SWITCH TEST START ===");

        clk_i = 0;
        rst_i = 0;
        valid_i = 0;
        ready_i = 4'b1111; 
        data_in = 0;
        target_dev = 0;
        payload = 1;

        #20 rst_i = 1;

        repeat (8) begin
            @(posedge clk_i);

            if (ready_o && !status_full) begin
                valid_i = 1;
                data_in = {target_dev, payload};

                $display("[TX] Time=%0t  -> dev=%0d, payload=%0d",
                         $time, target_dev, payload);

                target_dev = target_dev + 1;
                payload = payload + 1;
            end else begin
                valid_i = 0;
            end
        end

        valid_i = 0;

        wait (status_empty);

        #50;
        $display("=== SWITCH TEST DONE ===");
        $stop;
    end

    always @(posedge clk_i) begin
        if (valid_out[0])
            $display("[RX] Time=%0t -> device0 <= %0d",$time,device0);
        if (valid_out[1])
            $display("[RX] Time=%0t -> device1 <= %0d",$time,device1);
        if (valid_out[2])
            $display("[RX] Time=%0t -> device2 <= %0d",$time,device2);
        if (valid_out[3])
            $display("[RX] Time=%0t -> device3 <= %0d",$time,device3);
    end

endmodule
