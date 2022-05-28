Some concerns about this design:
The memory used in testing is probably not representative of memory used in a final design, so things will need to be changed to work with the RISC V core.
Once you have a working memory, you will need to implement address overflow protection in the MEM_WRITE functionality of the cache.
Also, if you move forward with using a Direct Mapped Cache (which you shouldn't because this is not a good architecture), I believe the design will need to be improved by implementing logic to read/write lines via a state machine instead of dedicated IO lines.
Also, I think the number of clock cycles required for many of the operations can be reduced via an improved FSM in the controller.

I have included a file with an L2 cache given by Max Apodaca that should serve this design better.