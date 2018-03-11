#Convert RS8000 for APRS

This is the assembly code for PIC16F84 which will convert the [Shipmate RS 8000](http://www.discriminator.nl/rs8000/index-en.html) Radio PLL for use in [APRS](https://en.wikipedia.org/wiki/Automatic_Packet_Reporting_System).

It was done in 2007.

## Solution
After an inital analisys it was verified that only 7 bits would change to synthesize two APRS frequencies, 144.8 and 144.85 MHz.

 * `PORTB` is then used to supply the needed bits.
 * `PORTA` is used to monitor PTT and channel changes.

The PIC is running a loop checking the inputs (PTT and Channel) and setting the corresponding PLL values.

### More info


	; PIC16F84A 4MHz
	; 
	; 
	;                      +-------  -------+  
	;                      |       \/       |
	;                RA2 --+ 1           18 +-- RA1           +----+
	;                      |                |                 |   _|_
	;                RA3 --+ 2*          17 +-- RA0     33pf ===  \_/
	;                      |                |                 |
	;         RA4/T0CLKI --+ 3           16 +-- OSC1/CLKIN ---+
	;                      |                |               [XXX] 4MHz xtal
	;              !MCLR --+ 4           15 +-- OSC2/CLKOUT --+
	;                      |                |                 |
	;                Vss --+ 5           14 +-- Vdd          === 33pf
	;                      |                |                _|_
	;                RB0 --+ 6          *13 +-- RB7          \_/
	;                      |                |
	;                RB1 --+ 7           12 +-- RB6
	;                      |                |
	;                RB2 --+ 8           11 +-- RB5
	;                      |                |
	;                RB3 --+ 9           10 +-- RB4
	;                      |  (PIC16F84A)   |
	;                      +----------------+
	;
	;
	; Outputs
	; 
	; RB0 1 2 3 4 5 6 7_ Channel indicator (Active Low)
	;   | | | | | | \___ M16
	;   | | | | |  \____ M8
	;   | | | |  \______ A64
	;   | | |  \________ A32
	;   | |  \__________ A16
	;   |  \____________ A8
	;    \______________ A4
	;
	;
	; Inputs 
	;
	; RA2 _ PTT (Active Low RX=1 TX=0)
	; RA1 _ Channel switch 


## TODO

 * Add schematic
 * Add screenshots?
