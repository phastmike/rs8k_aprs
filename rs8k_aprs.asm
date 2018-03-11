;
; ENG: Mar. 2018: Code for PIC16Fxx
; The goal is to convert this Marine VHF radio to APRS frequencies.
; Frequencies are 144.800 and 144.850 MHz.
; 
; To program the APRS frequencies, only 7 bits change so we will use
; PORTB. PORTA will be used to monitor PTT and Channel changes.
;
; -------------------------------------------------------------------
;
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
;
;  
; 07/Mar/07 : Initial version
;
; CT1ENQ
;
; ***************************************************************************

	;PROCESSOR PIC16F84A
	list	p=16F84A
	#include <p16F84A.inc>			; this is where all registers and bits are defined
	#include "macros_16F84A.h"	   ; this is where i keep my F84A MACROs

	__CONFIG _CP_OFF & _XT_OSC & _PWRTE_ON & _WDT_OFF
    ;__config _hs_osc & _wdt_off & _pwrte_on & _cp_off 

	errorlevel      -302    		;Eliminate bank warning


; CONSTANTS ***********************************************************************

	OPTION_VAL	EQU 0x80	; Value for OPTION_REG
	INTCON_VAL	EQU 0x00	; Value for INTCON
	CH1_RX		EQU 0xA7	; PORTB value for RX on 144,800 MHz (0x80 + 0x27) 0x80=LED OFF
	CH1_TX		EQU 0xD5	; PORTB value for TX em 144,800 MHz (0x80 + 0x55) 0x80=LED OFF

	;CH1_RX   	EQU 0xC0
	;CH2_RX		EQU 0x36

	CH2_RX		EQU 0X28	; PORTB value for RX on 144,850 MHz
	CH2_TX		EQU 0X56	; PORTB value for TX on 144,850 MHz

; VARIABLES ***********************************************************************


   CBLOCK  0x0C    		;Store variables above control registers

  	channel
  	tx_temp
  	tx
  	w_temp					; variable used for context saving 
 	status_temp				; variable used for context saving 

   ENDC

;ORG 000H	;program code to start at 000H
;**********************************************************************
	ORG   0x000           ; processor reset vector
	goto  main            ; go to beginning of program


	ORG   0x004           ; interrupt vector location
	movwf	w_temp          ; save off current W register contents
	movf	STATUS,w        ; move status register into W register
	movwf	status_temp     ; save off contents of STATUS register


; isr code can go here or be located as a call subroutine elsewhere


	movf  status_temp,w   ; retrieve copy of STATUS register
	movwf	STATUS          ; restore pre-isr STATUS register contents
	swapf w_temp,f
	swapf w_temp,w        ; restore pre-isr W register contents
	retfie                ; return from interrupt

; **********************************************************************
; MAIN CODE
; **********************************************************************

main

; remaining code goes here

	PAGE1

; Initialize Registers

	MOVLW OPTION_VAL
	MOVWF OPTION_REG
	MOVLW INTCON_VAL
	MOVWF INTCON
; --------------------

	CLRF TRISA		; make all Port bits outputs
	CLRF TRISB

;  BSF TRISA,1		; 2 input pins TX & CH Selector
;	BSF TRISA,2
	
	MOVLW 0x06		; Same as before but pin change at same time
	MOVWF TRISA		; 00000110  1=input 0=output

	PAGE0

; Start of channel processing
; Check which is the selected channel then check the TX status. Repeat this procedure.

  ;CLRF PORTB ; For debug

; Main loop for TX/RX and CH1/CH2 Seection

MAIN_LOOP
    BTFSS PORTA,1	; If ChannelSelector=0 Then Channel=Ch.1
    GOTO CH_IS_1
    GOTO CH_IS_2	; Else Channel=Ch.2

CH_IS_1
	BTFSS PORTA,2	; If PTT=0 Then TX
	GOTO CH1_IS_TX	;
	GOTO CH1_IS_RX	; Else RX

CH_IS_2
	BTFSS PORTA,2	; If PTT=0 Then TX
	GOTO CH2_IS_TX	;
	GOTO CH2_IS_RX	; Else RX

CH1_IS_RX
    CALL SET_CH1_RX
    GOTO MAIN_LOOP

CH1_IS_TX
    CALL SET_CH1_TX
    GOTO MAIN_LOOP
 
CH2_IS_RX
    CALL SET_CH2_RX
    GOTO MAIN_LOOP

CH2_IS_TX
    CALL SET_CH2_TX
    GOTO MAIN_LOOP

    
; Sub-routines to put the word in PORTB for S187 PLL
; **********************************************************************
SET_CH1_RX
    MOVLW CH1_RX	; 144,800 RX (0x80+0x27)
	MOVWF PORTB
	RETURN

SET_CH1_TX	
	MOVLW CH1_TX	; 144,800 TX (0x80+0x55)
	MOVWF PORTB
	RETURN
    
SET_CH2_RX
	MOVLW CH2_RX	; 144,850 RX 0x28
	MOVWF PORTB
	RETURN

SET_CH2_TX	
	MOVLW CH2_TX	; 144,850 TX 0x56
	MOVWF PORTB
	RETURN

; ************************************************************************
	END                     ; directive 'end of program'
