module pwmgenerator
(
    input clk,                // 100MHz clock input
    input increase_duty,      // input to increase 10% duty cycle
    input decrease_duty,      // input to decrease 10% duty cycle
    output PWM_OUT            // 10MHz PWM output signal
);

    reg [27:0] counter_debounce = 0;   // Counter for generating slow clock enable signals
    reg [3:0] DUTY_CYCLE = 5;          // Initial duty cycle is 50%
    reg [3:0] counter_PWM = 0;         // Counter for creating 10MHz PWM signal

    // Generate a slower clock signal for debouncing (4Hz)
    always @(posedge clk) begin
        if (counter_debounce >= 24999999)  // Adjusted for a 4Hz signal based on a 100MHz clock
            counter_debounce <= 0;
        else
            counter_debounce <= counter_debounce + 1;
    end

    wire slow_clk_enable = (counter_debounce == 0); // Slow clock enable signal is high for one cycle

    // Debouncing logic for increasing duty cycle
    reg increase_debounced = 0;
    reg decrease_debounced = 0;

    always @(posedge clk) begin
        if (slow_clk_enable) begin
            increase_debounced <= increase_duty;
            decrease_debounced <= decrease_duty;
        end
    end

    // Vary the duty cycle using the debounced buttons
    always @(posedge clk) begin
        if (increase_debounced && DUTY_CYCLE < 9)
            DUTY_CYCLE <= DUTY_CYCLE + 1;  // Increase duty cycle by 10%
        else if (decrease_debounced && DUTY_CYCLE > 1)
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

