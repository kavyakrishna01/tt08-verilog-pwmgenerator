module pwmgenerator
(
    input clk,                // 100MHz clock input
    input increase_duty,      // input to increase 10% duty cycle
    input decrease_duty,      // input to decrease 10% duty cycle
    output PWM_OUT            // 10MHz PWM output signal
);

    wire slow_clk_enable;     // slow clock enable signal for debouncing FFs
    reg [27:0] counter_debounce = 0; // counter for creating slow clock enable signals
    wire tmp1, tmp2, duty_inc; // temporary flip-flop signals for debouncing the increasing button
    wire tmp3, tmp4, duty_dec; // temporary flip-flop signals for debouncing the decreasing button
    reg [3:0] counter_PWM = 0; // counter for creating 10MHz PWM signal
    reg [3:0] DUTY_CYCLE = 5;  // initial duty cycle is 50%

    // Generate a slower clock signal for debouncing (4Hz)
    always @(posedge clk) begin
        if (counter_debounce >= 24999999) // Adjusted for a 4Hz signal based on a 100MHz clock
            counter_debounce <= 0;
        else
            counter_debounce <= counter_debounce + 1;
    end

    assign slow_clk_enable = (counter_debounce == 24999999); // This will be high for one clock cycle

    // Debouncing FFs for increasing button
    DFF_PWM PWM_DFF1 (.clk(clk), .en(slow_clk_enable), .D(increase_duty), .Q(tmp1));
    DFF_PWM PWM_DFF2 (.clk(clk), .en(slow_clk_enable), .D(tmp1), .Q(tmp2));
    assign duty_inc = tmp1 & (~tmp2) & slow_clk_enable;

    // Debouncing FFs for decreasing button
    DFF_PWM PWM_DFF3 (.clk(clk), .en(slow_clk_enable), .D(decrease_duty), .Q(tmp3));
    DFF_PWM PWM_DFF4 (.clk(clk), .en(slow_clk_enable), .D(tmp3), .Q(tmp4));
    assign duty_dec = tmp3 & (~tmp4) & slow_clk_enable;

    // Vary the duty cycle using the debounced buttons above
    always @(posedge clk) begin
        if (duty_inc && DUTY_CYCLE < 9)
            DUTY_CYCLE <= DUTY_CYCLE + 1; // increase duty cycle by 10%
        else if (duty_dec && DUTY_CYCLE > 1)
            DUTY_CYCLE <= DUTY_CYCLE - 1; // decrease duty cycle by 10%
    end

    // Create 10MHz PWM signal with variable duty cycle controlled by 2 buttons
    always @(posedge clk) begin
        if (counter_PWM >= 9)
            counter_PWM <= 0;
        else
            counter_PWM <= counter_PWM + 1;
    end

    assign PWM_OUT = (counter_PWM < DUTY_CYCLE);

endmodule

