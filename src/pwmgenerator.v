module pwmgenerator
(
    input clk,                // 100MHz clock input
    input increase_duty,      // input to increase 10% duty cycle
    input decrease_duty,      // input to decrease 10% duty cycle
    output PWM_OUT            // 10MHz PWM output signal
);

    reg [27:0] counter_debounce = 0;   // Counter for generating slow clock enable signals
    wire slow_clk_enable;              // Slow clock enable signal for debouncing FFs
    reg [3:0] DUTY_CYCLE = 5;          // Initial duty cycle is 50%
    reg [3:0] counter_PWM = 0;         // Counter for creating 10MHz PWM signal

    // Debounced signals
    reg tmp1 = 0, tmp2 = 0, duty_inc = 0;
    reg tmp3 = 0, tmp4 = 0, duty_dec = 0;

    // Generate a slower clock signal for debouncing (4Hz)
    always @(posedge clk) begin
        if (counter_debounce >= 24999999)  // Adjusted for a 4Hz signal based on a 100MHz clock
            counter_debounce <= 0;
        else
            counter_debounce <= counter_debounce + 1;
    end

    assign slow_clk_enable = (counter_debounce == 0); // Slow clock enable signal is high for one cycle

    // Debouncing logic for increasing duty cycle
    always @(posedge clk) begin
        if (slow_clk_enable) begin
            tmp1 <= increase_duty;
            tmp2 <= tmp1;
        end
    end

    assign duty_inc = tmp1 & (~tmp2) & slow_clk_enable;

    // Debouncing logic for decreasing duty cycle
    always @(posedge clk) begin
        if (slow_clk_enable) begin
            tmp3 <= decrease_duty;
            tmp4 <= tmp3;
        end
    end

    assign duty_dec = tmp3 & (~tmp4) & slow_clk_enable;

    // Vary the duty cycle using the debounced buttons
    always @(posedge clk) begin
        if (duty_inc && DUTY_CYCLE < 9)
            DUTY_CYCLE <= DUTY_CYCLE + 1;  // Increase duty cycle by 10%
        else if (duty_dec && DUTY_CYCLE > 1)
            DUTY_CYCLE <= DUTY_CYCLE - 1;  // Decrease duty cycle by 10%
    end

    // Create 10MHz PWM signal with variable duty cycle controlled by the buttons
    always @(posedge clk) begin
        if (counter_PWM >= 9)
            counter_PWM <= 0;
        else
            counter_PWM <= counter_PWM + 1;
    end

    assign PWM_OUT = (counter_PWM < DUTY_CYCLE);

endmodule
