#include PacketDetectionUnit.h

// PacketDetectionUnit::clock:
// Inputs: int FIFO that represents 30 bits of encoded data from the FIFO the PDU is checking
// Outputs: bool if a packet is detected or not
bool RPL::PacketDetectionUnit::clock(int prev_word, int FIFO[30]) {

    int D29star = prev_word & 2; //Selects 2nd bit of the 32 bit input integer
    int D30star = prev_word & 1; //Selects 1st bit of the 32 bit input integer

    //Find the unencoded data by xoring sent data with D30star to recover d1, as according to Parity Encoding Equations.
    //Note: d[0] = 0 so that indexing will match Parity Encoding Equations when recomputing parity bits
    //          If thats a bad idea lmk
    int d[25] = {};
    d[0] = 0;
    for(int i = 1; i < 25; i++) {
        unencoded_data[i] = (FIFO[i-1] + D30star) % 2;
    }



    //Check that first 8 bits match
    //Iterate through first 8 bits, if any dont match preamble not detected. Otherwise, preamble detected.
    bool preamble_detected = true;
    for(int i = 0; i < 8; i++) {
        if( FIFO[i] != this.TLM[i])
            preamble_detected = false;
    }

    //Internally recompute parity bits
    //Since FIFO[30] is all 1s and zeros, I can add up all the bits according to the algorithm, then check if its even or odd to determine its parity
    //see Parity Encoding Equations for reference
    int D25_computed = (D29star + d[1] + d[2] + d[3] + d[5] + d[6] + d[10] + d[11] + d[12] + d[13] + d[14] + d[17] + d[18] + d[20] + d[23]) % 2;
    int D26_computed = (D30star + d[2] + d[3] + d[4] + d[6] + d[7] + d[11] + d[12] + d[13] + d[14] + d[15] + d[18] + d[19] + d[21] + d[24]) % 2;
    int D27_computed = (D29star + d[1] + d[3] + d[4] + d[5] + d[7] + d[8] + d[12] + d[13] + d[14] + d[15] + d[16] + d[19] + d[20] + d[22]) % 2;
    int D28_computed = (D30star + d[2] + d[4] + d[5] + d[6] + d[8] + d[9] + d[13] + d[14] + d[15] +d[16] + d[17] + d[20] + d[21] + d[23]) % 2;
    int D29_computed = (D30star + d[1] + d[3] + d[5] + d[6] + d[7] + d[9] + d[10] + d[14] + d[15] + d[16] + d[17] + d[18] + d[21] + d[22] + d[24]) % 2;
    int D30_computed = (D29star + d[3] + d[5] + d[6] + d[8] + d[9] + d[10] + d[11] + d[13] + d[15] + d[19] + d[22] + d[23] + d[24]) % 2;

    //Now Check computed parity bits match parity bits in FIFO
    //Note that FIFO is zero indexed while computed parity bits are 1 indexed so FIFO index will be one lower than parity bit name
    bool parity_matches = (D25_computed == FIFO[24]) & (D26_computed == FIFO[25]) & (D27_computed == FIFO[26]) & (D28_computed == FIFO[27]) & 
                                                    (D29_computed == FIFO[28]) & (D30_computed == FIFO[29]);
    
    return (parity_matches & preamble_detected);



    

}