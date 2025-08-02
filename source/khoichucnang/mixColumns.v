module mixColumns(
    input  [127:0] state_in,
    output [127:0] state_out
);

    function [7:0] xtime;
        input [7:0] b;
        begin
            xtime = (b[7] == 1) ? ((b << 1) ^ 8'h1b) : (b << 1);
        end
    endfunction

    function [7:0] mul2;
        input [7:0] b;
        begin
            mul2 = xtime(b);
        end
    endfunction

    function [7:0] mul3;
        input [7:0] b;
        begin
            mul3 = xtime(b) ^ b;
        end
    endfunction

    integer i;
    reg [7:0] a[0:15];
    reg [7:0] r[0:15];

    always @(*) begin
        // Split state_in into 16 bytes
        for (i = 0; i < 16; i = i + 1)
            a[i] = state_in[127 - 8*i -: 8];

        for (i = 0; i < 4; i = i + 1) begin
            r[4*i+0] = mul2(a[4*i+0]) ^ mul3(a[4*i+1]) ^ a[4*i+2] ^ a[4*i+3];
            r[4*i+1] = a[4*i+0] ^ mul2(a[4*i+1]) ^ mul3(a[4*i+2]) ^ a[4*i+3];
            r[4*i+2] = a[4*i+0] ^ a[4*i+1] ^ mul2(a[4*i+2]) ^ mul3(a[4*i+3]);
            r[4*i+3] = mul3(a[4*i+0]) ^ a[4*i+1] ^ a[4*i+2] ^ mul2(a[4*i+3]);
        end
    end

    // Combine r[] back into 128-bit output
    generate
        genvar j;
        for (j = 0; j < 16; j = j + 1) begin : OUT_PACK
            assign state_out[127 - 8*j -: 8] = r[j];
        end
    endgenerate

endmodule
