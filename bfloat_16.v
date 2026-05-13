module bfloat_16 (
    input  [15:0] a,
    input  [15:0] b,
    input         op,   // 0 = add, 1 = subtract (a - b)
    output [15:0] result
);

    // Extract fields
    wire sign_a = a[15];
    wire sign_b = op ? ~b[15] : b[15];  // flip sign if subtraction

    wire [7:0] exp_a = a[14:7]+ 8'b01111111;
    wire [7:0] exp_b = b[14:7]+ 8'b01111111;

    // Add guard bits (2 bits)
    wire [9:0] mant_a = {1'b1, a[6:0], 2'b00};
    wire [9:0] mant_b = {1'b1, b[6:0], 2'b00};

    // Compare magnitudes
    wire a_gt_b = (exp_a > exp_b) || ((exp_a == exp_b) && (mant_a > mant_b));

    wire [7:0] exp_large = a_gt_b ? exp_a : exp_b;
    wire [7:0] exp_small = a_gt_b ? exp_b : exp_a;

    wire [9:0] mant_large = a_gt_b ? mant_a : mant_b;
    wire [9:0] mant_small = a_gt_b ? mant_b : mant_a;

    wire sign_large = a_gt_b ? sign_a : sign_b;
    wire sign_small = a_gt_b ? sign_b : sign_a;

    // Align mantissas
    wire [7:0] exp_diff = exp_large - exp_small;
    wire [9:0] mant_small_shifted = mant_small >> exp_diff;

    // Add/Sub
    reg [10:0] mant_sum;
    reg result_sign;

    always_comb begin
        if (sign_large == sign_small) begin
            mant_sum = mant_large + mant_small_shifted;
            result_sign = sign_large;
        end else begin
            mant_sum = mant_large - mant_small_shifted;
            result_sign = sign_large;
        end
    end

    // Normalize
    reg [9:0] mant_norm;
    reg [7:0] exp_norm;

    integer i;

    always_comb begin
        mant_norm = mant_sum[9:0];
        exp_norm = exp_large;

        // Right normalization (overflow)
        if (mant_sum[10]) begin
            mant_norm = mant_sum[10:1];
            exp_norm = exp_large + 1;
        end
        else begin
            // Left normalization (IMPORTANT FIX)
            for (i = 0; i < 10; i = i + 1) begin
                if (mant_norm[9] == 0 && exp_norm > 0) begin
                    mant_norm = mant_norm << 1;
                    exp_norm = exp_norm - 1;
                end
            end
        end
    end

wire [7:0] exp_out = exp_norm - 8'b01111111;
    // Pack result (truncate guard bits)
    assign result = {result_sign, exp_out, mant_norm[8:2]};

endmodule
