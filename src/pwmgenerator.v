module pwmgenerator (
    input clk,              // 100MHz clock input
    input increase_duty,    // input to increase 10% duty cycle
    input decrease_duty,    // input to decrease 10% duty cycle
    output PWM_OUT          // 10MHz PWM output signal
);
    // Parameters for flexibility
    parameter MAX_COUNT = 9;       // Max count value for 10MHz PWM signal
    parameter INITIAL_DUTY = 5;    // Initial duty cycle (50%)

    // Signal declarations
    reg [27:0] counter_debounce = 0; // Counter for creating slow clock enable signals
    reg [3:0] counter_PWM = 0;       // Counter for creating 10MHz PWM signal
    reg [3:0] DUTY_CYCLE = INITIAL_DUTY; // Duty cycle register

    wire slow_clk_enable;             // Slow clock enable signal for debouncing FFs
    wire duty_inc, duty_dec;          // Debounced signals for duty cycle adjustment

    // Debounce logic wires
    wire tmp1, tmp2, tmp3, tmp4;

    // Initialize signals to avoid unknown states
    initial begin
        DUTY_CYCLE = INITIAL_DUTY;
        counter_PWM = 0;
        counter_debounce = 0;
    end

    // Generate slow clock enable signal for debouncing (approx. 4Hz)
    always @(posedge clk) begin
        counter_debounce <= counter_debounce + 1;
        if (counter_debounce >= 25000000) // for FPGA implementation
            counter_debounce <= 0;
    end
    assign slow_clk_enable = (counter_debounce == 0);

    // Debouncing logic for increasing button
    DFF_PWM PWM_DFF1(clk, slow_clk_enable, increase_duty, tmp1);
    DFF_PWM PWM_DFF2(clk, slow_clk_enable, tmp1, tmp2);
    assign duty_inc = tmp1 & (~tmp2) & slow_clk_enable;

    // Debouncing logic for decreasing button
    DFF_PWM PWM_DFF3(clk, slow_clk_enable, decrease_duty, tmp3);
    DFF_PWM PWM_DFF4(clk, slow_clk_enable, tmp3, tmp4);
    assign duty_dec = tmp3 & (~tmp4) & slow_clk_enable;

    // Adjust the duty cycle using the debounced buttons
    always @(posedge clk) begin
        if (duty_inc && DUTY_CYCLE < MAX_COUNT)
            DUTY_CYCLE <= DUTY_CYCLE + 1; // Increase duty cycle by 10%
        else if (duty_dec && DUTY_CYCLE > 1)
            DUTY_CYCLE <= DUTY_CYCLE - 1; // Decrease duty cycle by 10%
    end

    // Generate 10MHz PWM signal with variable duty cycle
    always @(posedge clk) begin
        counter_PWM <= counter_PWM + 1;
        if (counter_PWM >= MAX_COUNT)
            counter_PWM <= 0;
    end
    assign PWM_OUT = (counter_PWM < DUTY_CYCLE) ? 1 : 0;

endmodule

