module servo #(
    parameter CLK_FREQ = 25_000_000, // 25 MHz
    parameter PERIOD = 500_000 // 50 Hz (1/50s = 20ms, 25MHz / 50Hz = 500000 cycles)
) (
    input wire clk,
    input wire rst_n,
    output wire servo_out
);

localparam ONESECOND = CLK_FREQ;
localparam FIVESECONDS = 5 * ONESECOND;

localparam [31:0] DUTY_MIN = PERIOD/20; // 1 segundo / 1000 = 1ms
localparam [31:0] DUTY_MAX = PERIOD/10; // 2 segundos / 1000 = 2ms

localparam EXC_MIN = 1'b0;
localparam EXC_MAX = 1'b1;

reg estado;

reg [31:0] current_duty; // Inicia com 1ms
reg [31:0] timer = 0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        estado <= EXC_MIN; // Estado inicial
        current_duty <= DUTY_MIN;
        timer <= 0;
    end else begin
        case(estado)
            EXC_MIN: begin
                timer <= timer + 1;
                if(timer >= FIVESECONDS - 1) begin
                    estado <= EXC_MAX; 
                    current_duty <= DUTY_MAX; // 10% do período
                    timer <= 0; // Reseta o timer
                end
            end
            EXC_MAX: begin
                timer <= timer + 1;
                if(timer >= FIVESECONDS - 1) begin
                    estado <= EXC_MIN;
                    current_duty <= DUTY_MIN; // 5% do período
                    timer <= 0; // Reseta o timer
                end
            end
            default: begin
                estado <= EXC_MIN; // Reseta para o estado mínimo
                current_duty <= DUTY_MIN; // Reseta o duty cycle
                timer <= 0;
            end
        endcase
    end
end

// Instanciamento do PWM
PWM pwm_inst(
    .clk(clk),
    .rst_n(rst_n),
    .duty_cycle(current_duty), // duty cycle final = current_duty / period
    .period(PERIOD), // pwm_freq = clk_freq / period
    .pwm_out(servo_out)
);

endmodule