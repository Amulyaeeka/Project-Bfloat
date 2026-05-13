module bfloat16_tb;

    reg [15:0] a, b;
    reg op;
    wire [15:0] result;

    bfloat_16 uut(a, b, op, result);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, bfloat16_tb);

        // Example values
        a = 16'b0_00000101_0100000; // ~5
        b = 16'b0_00000010_1000000; // ~3

        op = 0; // addition
        #10;

        op = 1; // subtraction
        #10;

        $finish;
    end

    initial begin
  $monitor("Time=%0t a=%b b=%b result=%b", $time ,a ,b ,result);
 end

endmodule