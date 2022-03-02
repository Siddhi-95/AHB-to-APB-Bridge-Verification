# AHB-to-APB-Bridge-Verification

AHB-to-APB Bridge Verification using UVM Methodology.

The AHB to APB bridge is an AHB slave which works as an interface between the high speed AHB and the low performance APB buses.
DUT is AHB-to-APB Bridge which is AHB Slave and APB Master. We will use 1 AHB Master and 4 APB Slaves. Need to verify whether the data sent by the AHB Master has reached the APB slave and vice versa. 

Bridge will do the following:
Latches address and holds it valid throughout the transfer.
Decodes address and generates peripheral select. Only one select signal can be active during a transfer.
Drives data onto the APB for a write transfer.
Drives APB data onto system bus for a read transfer.
Generates PENABLE for the transfer.

