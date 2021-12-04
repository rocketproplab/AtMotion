namespace RPL{
    struct FrameOutput {
        int inverted_signal;
        int signal;
    };
    class FrameProcessor{
        private:
        int state;
        public:
        void reset();
        struct FrameOutput clock(int data_point, long root_time, long phase_to_guess, long prn_state);
    };
}