//-----------------------------code from internet--------------------------------- 
//https://blog.csdn.net/qq_40052606/article/details/123440113
//https://blog.csdn.net/sinolover/article/details/115229493
//https://blog.csdn.net/weixin_29752563/article/details/112641191
// ------------------------functon of dpv data transfer----------------------------
//http://t.zoukankan.com/-9-8-p-6306946.html
//https://zhuanlan.zhihu.com/p/404764885
#include <svdpi.h>
#include <stdio.h>
#include <stdint.h>
#include <vector>
#include <iostream>


// typedef short uint16_t;
// typedef char  uint8_t;
// typedef short U16;
// typedef int   U32;
//算法1
/*
extern U16 Can_FD_Analyzer::ComputeCrc15(std::vector<BitState> &bits, U32 num_bits)
{
    //X15 + X14 + X10 + X8 + X7 + X4 + X3 + X0.
    U16 crc_result = 0;
    for (U32 i = 0; i < num_bits; i++) {
        BitState next_bit = bits[i];
 
        //Exclusive or
        if ((crc_result & 0x4000) != 0) {
            next_bit = Invert(next_bit);    //if the msb of crc_result is zero, then next_bit is not inverted; otherwise, it is.
        }
        crc_result <<= 1;
 
        if (next_bit == mSettings->Recessive()) { //normally bit high.
            crc_result ^= 0x4599;
        }
    }

    return crc_result & 0x7FFF;
}
*/
 
// //算法2
// extern U16 Can_FD_Analyzer::MakeCRC15(std::vector<BitState> &bits, U32 num_bits)
// {
//     //X15 + X14 + X10 + X8 + X7 + X4 + X3 + X0.
//     U16 CRC[15] = { 0 };
//     for (U32 i = 0; i < num_bits; i++) {
//         U32 DoInvert = (bits[i] == mSettings->Recessive()) ^ CRC[14]; //XOR required?
//         CRC[14] = (CRC[13] ^ DoInvert); //14
//         CRC[13] = CRC[12];
//         CRC[12] = CRC[11];
//         CRC[11] = CRC[10];
//         CRC[10] = (CRC[9] ^ DoInvert); //10
//         CRC[9] = CRC[8];
//         CRC[8] = (CRC[7] ^ DoInvert); //8
//         CRC[7] = (CRC[6] ^ DoInvert); //7
//         CRC[6] = CRC[5];
//         CRC[5] = CRC[4];
//         CRC[4] = (CRC[3] ^ DoInvert); //4
//         CRC[3] = (CRC[2] ^ DoInvert); //3
//         CRC[2] = CRC[1];
//         CRC[1] = CRC[0];
//         CRC[0] = DoInvert;
//     }
 
//     U16 result = 0; // CRC Result
//     for (U32 i = 0; i < 15; i++) {
//         result = result | (CRC[i] << i);
//     }
//     return (U16)result;
// }

//method 3
// extern uint16_t can_crc_next(uint16_t crc, uint8_t data)
// {
//     uint8_t i, j;
 
//     crc ^= (uint16_t)data << 7;
 
//     for (i = 0; i < 8; i++) {
//         crc <<= 1;
//         if (crc & 0x8000) {
//             crc ^= 0xc599;
//         }
//     }
 
//     return crc & 0x7fff;
// }
// import "DPI-C"function bit[15:0] can_crc_next(input bit[15:0] crc,input bit[7:0] data);
extern int can_crc_next(svBitVecVal*crc, svBitVecVal*data)
// extern short can_crc_next(short crc, char data)
{
    char tem_data, i, j;
    int tem_crc;
    tem_data = *data;
    // for(i=0;i<8;i++){
    //     tem_data = svGetBitselBit(data,i);
    //     tem_data <<=1;
    // }
    tem_crc = *crc;
    // for(i=0;i<16;i++){
    //     tem_crc = svGetBitselBit(crc,i);
    //     tem_crc <<=1;
    // }
    unsigned int data0 = (unsigned int)tem_data;
    tem_crc ^= data0 << 7;
 
    for (i = 0; i < 8; i++) {
        tem_crc <<= 1;
        if (tem_crc & 0x8000) {
            tem_crc ^= 0xc599;
        }
    }
 
    return tem_crc & 0x7fff;
}
// int main()
// {
//     int i;
//     uint8_t data[] = {0x02, 0xAA, 0x80};
//     uint16_t crc;
 
//     crc = 0;
 
//     for (i = 0; i < sizeof(data); i++) {
//         crc = can_crc_next(crc, data[i]);
//     }
 
//     printf("%x\n", crc);
// }