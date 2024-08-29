module DFF_PWM (
    input clk,
    input en,
    input D,
    output reg Q
);

    always @(posedge clk) begin
        if (en) // slow clock enable signal
            Q <= D;
    end

endmodule
