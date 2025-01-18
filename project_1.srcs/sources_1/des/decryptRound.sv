module decryptRound(in,key,out);
input [127:0] in;
output [127:0] out;
input [127:0] key;
logic [127:0] afterSubBytes;
logic [127:0] afterShiftRows;
logic [127:0] afterMixColumns;
logic [127:0] afterAddroundKey;

inverseShiftRows r(in,afterShiftRows);
inverseSubBytes s(afterShiftRows,afterSubBytes);
addRoundKey b(afterSubBytes,afterAddroundKey,key);
inverseMixColumns m(afterAddroundKey,out);
		
endmodule