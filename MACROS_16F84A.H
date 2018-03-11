; MACROS_16F84A.H
;
; MyMACROs
; Copyright 2003 by José Fonte
; José Fonte | mike@nocturno.org | Nov.2003


;==================================
; MACROS
;==================================
;

;
; RP1 | RP0 | PAGE
; ----+-----+-----
;  x  |  0  |  0
;  x  |  1  |  1
;
; PIC16F84A is limited to 2 banks/pages [0,1]
; RP1 is not implemented

PAGE0	MACRO
		BCF	STATUS,RP0
		ENDM

PAGE1	MACRO
		BSF	STATUS,RP0
		ENDM
;==================================
