module PWM (
    input wire clk,
    input wire rst_n,
    input wire [31:0] duty_cycle, // duty cycle final = duty_cycle / period
    input wire [31:0] period, // pwm_freq = clk_freq / period
    output reg pwm_out
);

reg [31:0] counter;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter <= 32'b0;
        pwm_out <= 1'b0;
    end else begin
        if(counter < duty_cycle) begin
            pwm_out <= 1'b1;
        end else begin
            pwm_out <= 1'b0;
        end
        if(counter == period - 1) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
end
    
endmodule