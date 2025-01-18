module encryptRound(in,key,out);
input [127:0] in;
output [127:0] out;
input [127:0] key;
logic [127:0] afterSubBytes;
logic [127:0] afterShiftRows;
logic [127:0] afterMixColumns;
logic [127:0] afterAddroundKey;

subBytes s(in,afterSubBytes);
shiftRows r(afterSubBytes,afterShiftRows);
mixColumns m(afterShiftRows,afterMixColumns);
addRoundKey b(afterMixColumns,out,key);
		
endmodule