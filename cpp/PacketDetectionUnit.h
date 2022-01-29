namespace RPL {

    class PacketDetectionUnit{

        private:
            int TLM[8] = {1, 0, 0, 0, 1, 0, 1, 1}; //in big endian form
        public:
            bool clock(int prev_word, int FIFO[30]);
    };
}