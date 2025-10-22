# FPU 64 bits

Augusto G Weber added 21/10/2025

Modificou para ter entrada e saída em 4 estágios de 16 bits por vez. 
Criou o my_fpu_double.vhd e my_fpu_double_TB.sv
Criou arquivo com UPF (fpu_double.upf)

Invocar simulações:
 - Simulação 64bits original: xrun -f xargs
 - Simulação 16bits: xrun -f xargs2
 - Simulação 16bits + UPF: xrun -f xargs2upf

----------------------------------------------------------------------------------------------------------------------

## Original

The following describes the IEEE-Standard-754 compliant, double-precision floating point unit, 
written in VHDL.  The module consists of the following files:

1.	fpu_double.vhd (top level)
2.	fpu_add.vhd
3.	fpu_sub.vhd
4.	fpu_mul.vhd
5.	fpu_div.vhd
6.	fpu_round.vhd
7.	fpu_exceptions.vhd
8.  fpupack.vhd
9.  comppack.vhd
	
And a testbench file is included, containing 50 test-case operations:
1.	fpu_double_TB.vhd

This unit has been extensively simulated, covering all 4 operations, rounding modes, exceptions
like underflow and overflow, and even the obscure corner cases, like when overflowing from 
denormalized to normalized, and vice-versa.  

The floating point unit supports denormalized numbers, 
4 operations (add, subtract, multiply, divide), and 4 rounding 
modes (nearest, zero, + inf, - inf).  The unit was synthesized with an 
estimated frequency of 185 MHz, for a Virtex5 target device.  The synthesis results 
are below.  fpu_double.vhd is the top-level module, and it contains the input 
and output signals from the unit.  

The input and output signals to the unit are the following:

1. clk  (global)
2. rst	(global)
2. enable   (set high, then low, to start operation)
3. rmode (rounding mode, 2 bits, 00 = nearest, 01 = zero,
			10 = pos inf, 11 = neg inf)
4. fpu_op (operation code, 3 bits, 000 = add, 001 = subtract,
			010 = multiply, 011 = divide, others are not used)
5. opa, opb (input operands, 64 bits, Big-endian order,
			bit 63 = sign, bits 62-52 exponent, bits 51-0 mantissa)
6. out_fp   (output from operation, 64 bits, Big-endian order,
			same ordering as inputs)
7. ready	(goes high when output is available)
8. underflow 
9. overflow
10. inexact
11. exception - see IEEE 754 definition
12. invalid   - see IEEE 754 definition

The unit was designed to be synchronous with one global clock, and all of the 
registers can be reset with an synchronous global reset. 
When the inputs signals (a and b operands, fpu operation code, rounding mode code) are 
available, set the enable input high, then set it low after 2 clock cycles.  When the 
operation is complete and the output is available, the ready signal will go high.  To start
the next operation, set the enable input high.

Each operation takes the following amount of clock cycles to complete:
1.	addition : 			20 clock cycles
2.	subtraction: 		21 clock cycles
3.	multiplication: 	24 clock cycles
4.	division:			71 clock cycles

This is longer than other floating point units, but supporting denormalized numbers 
requires more signals and logic levels to accommodate gradual underflow.  The supported 
clock speed of 185 MHz makes up for the large number of clock cycles required for each 
operation to complete.  If you have a lower clock speed, the code can be changed to 
reduce the number of registers and latency of each operation. I purposely increased the
number of logic levels to get the code to synthesize to a faster clock frequency, but of course,
this led to longer latency.  I guess it depends on your application what is more important.

The following output signals are also available: underflow, overflow, inexact, exception,
and invalid.  They are compliant with the IEEE-754 definition of each signal.  The unit
will handle QNaN and SNaN inputs per the standard. 

I'm planning on adding more operations, like square root, sin, cos, tan, etc.,
so check back for updates.

Multiply:  
The multiply module is written specifically for a Virtex5 target device.  The DSP48E slices
can perform a 25-bit by 18-bit Twos-complement multiply (24 by 17 unsigned multiply).  I broke up the multiply to 
fit these DSP48E slices.  The breakdown is similar to the design in Figure 4-15 of the
Xilinx User Guide Document, "Virtex-5 FPGA XtremeDSP Design Considerations", also known as UG193.
You can find this document at xilinx.com by searching for "UG193".
Depending on your device, the multiply can be changed to match the bit-widths of the available
multipliers.  A total of 9 DSP48E slices are used to do the 53-bit by 53-bit multiply of 2
floating point numbers.

If you have any questions, please email me at: davidklun@gmail.com

Thanks,
David Lundgren

