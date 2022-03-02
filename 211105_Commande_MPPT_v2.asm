
_main:

;211105_Commande_MPPT_v2.c,142 :: 		void main() {
;211105_Commande_MPPT_v2.c,144 :: 		init();
	CALL        _init+0, 0
;211105_Commande_MPPT_v2.c,146 :: 		while(1) {
L_main0:
;211105_Commande_MPPT_v2.c,149 :: 		if (settled) {
	MOVF        _settled+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main2
;211105_Commande_MPPT_v2.c,151 :: 		voltage_in = 0;
	CLRF        _voltage_in+0 
	CLRF        _voltage_in+1 
;211105_Commande_MPPT_v2.c,152 :: 		voltage_out = 0;
	CLRF        _voltage_out+0 
	CLRF        _voltage_out+1 
;211105_Commande_MPPT_v2.c,153 :: 		current_in = 0;
	CLRF        _current_in+0 
	CLRF        _current_in+1 
;211105_Commande_MPPT_v2.c,156 :: 		for (counter = 0; counter < 8; ++counter) {
	CLRF        _counter+0 
L_main3:
	MOVLW       8
	SUBWF       _counter+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main4
;211105_Commande_MPPT_v2.c,157 :: 		voltage_in += ADC_Read(0);
	CLRF        FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	MOVF        R0, 0 
	ADDWF       _voltage_in+0, 1 
	MOVF        R1, 0 
	ADDWFC      _voltage_in+1, 1 
;211105_Commande_MPPT_v2.c,156 :: 		for (counter = 0; counter < 8; ++counter) {
	INCF        _counter+0, 1 
;211105_Commande_MPPT_v2.c,159 :: 		}
	GOTO        L_main3
L_main4:
;211105_Commande_MPPT_v2.c,161 :: 		voltage_in >>= 3;
	MOVLW       3
	MOVWF       R0 
	MOVF        R0, 0 
L__main73:
	BZ          L__main74
	RRCF        _voltage_in+1, 1 
	RRCF        _voltage_in+0, 1 
	BCF         _voltage_in+1, 7 
	BTFSC       _voltage_in+1, 6 
	BSF         _voltage_in+1, 7 
	ADDLW       255
	GOTO        L__main73
L__main74:
;211105_Commande_MPPT_v2.c,165 :: 		for (counter = 0; counter < 16; ++counter) {
	CLRF        _counter+0 
L_main6:
	MOVLW       16
	SUBWF       _counter+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main7
;211105_Commande_MPPT_v2.c,166 :: 		current_in += ADC_Read(1);
	MOVLW       1
	MOVWF       FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	MOVF        R0, 0 
	ADDWF       _current_in+0, 1 
	MOVF        R1, 0 
	ADDWFC      _current_in+1, 1 
;211105_Commande_MPPT_v2.c,165 :: 		for (counter = 0; counter < 16; ++counter) {
	INCF        _counter+0, 1 
;211105_Commande_MPPT_v2.c,167 :: 		}
	GOTO        L_main6
L_main7:
;211105_Commande_MPPT_v2.c,169 :: 		current_in >>= 4;
	MOVLW       4
	MOVWF       R0 
	MOVF        R0, 0 
L__main75:
	BZ          L__main76
	RRCF        _current_in+1, 1 
	RRCF        _current_in+0, 1 
	BCF         _current_in+1, 7 
	BTFSC       _current_in+1, 6 
	BSF         _current_in+1, 7 
	ADDLW       255
	GOTO        L__main75
L__main76:
;211105_Commande_MPPT_v2.c,171 :: 		switch(mode) {
	GOTO        L_main9
;211105_Commande_MPPT_v2.c,172 :: 		case FAST_GMPPT:  /* THIS SECTION IS STILL OPTIMIZABLE */
L_main11:
;211105_Commande_MPPT_v2.c,178 :: 		if (sweep_iteration < 3 && (voltage_in < sweep_lower_bounds[sweep_iteration] || voltage_in > sweep_upper_bounds[sweep_iteration]) ) {
	MOVLW       128
	XORWF       _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       3
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main16
	MOVF        _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_lower_bounds+0
	ADDWF       R0, 0 
	MOVWF       FSR2L 
	MOVLW       hi_addr(_sweep_lower_bounds+0)
	ADDWFC      R1, 0 
	MOVWF       FSR2H 
	MOVFF       FSR2L, FSR0L
	MOVFF       FSR2H, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       R2, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main77
	MOVF        R1, 0 
	SUBWF       _voltage_in+0, 0 
L__main77:
	BTFSS       STATUS+0, 0 
	GOTO        L__main72
	MOVF        _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_upper_bounds+0
	ADDWF       R0, 0 
	MOVWF       FSR2L 
	MOVLW       hi_addr(_sweep_upper_bounds+0)
	ADDWFC      R1, 0 
	MOVWF       FSR2H 
	MOVFF       FSR2L, FSR0L
	MOVFF       FSR2H, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main78
	MOVF        _voltage_in+0, 0 
	SUBWF       R1, 0 
L__main78:
	BTFSS       STATUS+0, 0 
	GOTO        L__main72
	GOTO        L_main16
L__main72:
L__main71:
;211105_Commande_MPPT_v2.c,179 :: 		if (voltage_in < sweep_target[sweep_iteration]) {
	MOVF        _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_target+0
	ADDWF       R0, 0 
	MOVWF       FSR2L 
	MOVLW       hi_addr(_sweep_target+0)
	ADDWFC      R1, 0 
	MOVWF       FSR2H 
	MOVFF       FSR2L, FSR0L
	MOVFF       FSR2H, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       R2, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main79
	MOVF        R1, 0 
	SUBWF       _voltage_in+0, 0 
L__main79:
	BTFSC       STATUS+0, 0 
	GOTO        L_main17
;211105_Commande_MPPT_v2.c,180 :: 		D = D - ( (sweep_target[sweep_iteration] - voltage_in)>>(1+sweep_iteration) );
	MOVF        _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_target+0
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       hi_addr(_sweep_target+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        _voltage_in+0, 0 
	SUBWF       POSTINC0+0, 0 
	MOVWF       R3 
	MOVF        _voltage_in+1, 0 
	SUBWFB      POSTINC0+0, 0 
	MOVWF       R4 
	MOVF        _sweep_iteration+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main80:
	BZ          L__main81
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	BTFSC       R1, 6 
	BSF         R1, 7 
	ADDLW       255
	GOTO        L__main80
L__main81:
	MOVF        R0, 0 
	SUBWF       _D+0, 1 
	MOVF        R1, 0 
	SUBWFB      _D+1, 1 
;211105_Commande_MPPT_v2.c,181 :: 		}else {
	GOTO        L_main18
L_main17:
;211105_Commande_MPPT_v2.c,182 :: 		D = D + ( (voltage_in - sweep_target[sweep_iteration])>>(1+sweep_iteration) );
	MOVF        _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_target+0
	ADDWF       R0, 0 
	MOVWF       FSR2L 
	MOVLW       hi_addr(_sweep_target+0)
	ADDWFC      R1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	SUBWF       _voltage_in+0, 0 
	MOVWF       R3 
	MOVF        POSTINC2+0, 0 
	SUBWFB      _voltage_in+1, 0 
	MOVWF       R4 
	MOVF        _sweep_iteration+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main82:
	BZ          L__main83
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	BTFSC       R1, 6 
	BSF         R1, 7 
	ADDLW       255
	GOTO        L__main82
L__main83:
	MOVF        R0, 0 
	ADDWF       _D+0, 1 
	MOVF        R1, 0 
	ADDWFC      _D+1, 1 
;211105_Commande_MPPT_v2.c,183 :: 		}
L_main18:
;211105_Commande_MPPT_v2.c,184 :: 		}else if (sweep_iteration < 3 && voltage_in >= sweep_lower_bounds[sweep_iteration] && voltage_in <= sweep_upper_bounds[sweep_iteration]) {
	GOTO        L_main19
L_main16:
	MOVLW       128
	XORWF       _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       3
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main22
	MOVF        _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_lower_bounds+0
	ADDWF       R0, 0 
	MOVWF       FSR2L 
	MOVLW       hi_addr(_sweep_lower_bounds+0)
	ADDWFC      R1, 0 
	MOVWF       FSR2H 
	MOVFF       FSR2L, FSR0L
	MOVFF       FSR2H, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       R2, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main84
	MOVF        R1, 0 
	SUBWF       _voltage_in+0, 0 
L__main84:
	BTFSS       STATUS+0, 0 
	GOTO        L_main22
	MOVF        _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_upper_bounds+0
	ADDWF       R0, 0 
	MOVWF       FSR2L 
	MOVLW       hi_addr(_sweep_upper_bounds+0)
	ADDWFC      R1, 0 
	MOVWF       FSR2H 
	MOVFF       FSR2L, FSR0L
	MOVFF       FSR2H, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main85
	MOVF        _voltage_in+0, 0 
	SUBWF       R1, 0 
L__main85:
	BTFSS       STATUS+0, 0 
	GOTO        L_main22
L__main70:
;211105_Commande_MPPT_v2.c,185 :: 		sweep_duty_cycle[sweep_iteration] = D;                   // save the current duty cycle that has the correct voltage
	MOVLW       _sweep_duty_cycle+0
	MOVWF       FSR1L 
	MOVLW       hi_addr(_sweep_duty_cycle+0)
	MOVWF       FSR1H 
	MOVF        _sweep_iteration+0, 0 
	ADDWF       FSR1L, 1 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _D+0, 0 
	MOVWF       POSTINC1+0 
;211105_Commande_MPPT_v2.c,188 :: 		measured_power = (INT32)voltage_in * (INT32)current_in;
	MOVF        _voltage_in+0, 0 
	MOVWF       R4 
	MOVF        _voltage_in+1, 0 
	MOVWF       R5 
	MOVLW       0
	BTFSC       _voltage_in+1, 7 
	MOVLW       255
	MOVWF       R6 
	MOVWF       R7 
	MOVF        _current_in+0, 0 
	MOVWF       R0 
	MOVF        _current_in+1, 0 
	MOVWF       R1 
	MOVLW       0
	BTFSC       _current_in+1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	CALL        _Mul_32x32_U+0, 0
	MOVF        R0, 0 
	MOVWF       _measured_power+0 
	MOVF        R1, 0 
	MOVWF       _measured_power+1 
	MOVF        R2, 0 
	MOVWF       _measured_power+2 
	MOVF        R3, 0 
	MOVWF       _measured_power+3 
;211105_Commande_MPPT_v2.c,190 :: 		if (measured_power > P_max_fast_gmppt) {
	MOVLW       128
	XORWF       _P_max_fast_gmppt+3, 0 
	MOVWF       R4 
	MOVLW       128
	XORWF       R3, 0 
	SUBWF       R4, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main86
	MOVF        R2, 0 
	SUBWF       _P_max_fast_gmppt+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main86
	MOVF        R1, 0 
	SUBWF       _P_max_fast_gmppt+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main86
	MOVF        R0, 0 
	SUBWF       _P_max_fast_gmppt+0, 0 
L__main86:
	BTFSC       STATUS+0, 0 
	GOTO        L_main23
;211105_Commande_MPPT_v2.c,191 :: 		P_max_fast_gmppt = measured_power;
	MOVF        _measured_power+0, 0 
	MOVWF       _P_max_fast_gmppt+0 
	MOVF        _measured_power+1, 0 
	MOVWF       _P_max_fast_gmppt+1 
	MOVF        _measured_power+2, 0 
	MOVWF       _P_max_fast_gmppt+2 
	MOVF        _measured_power+3, 0 
	MOVWF       _P_max_fast_gmppt+3 
;211105_Commande_MPPT_v2.c,192 :: 		D_max_fast_gmppt = D;
	MOVF        _D+0, 0 
	MOVWF       _D_max_fast_gmppt+0 
;211105_Commande_MPPT_v2.c,193 :: 		}
L_main23:
;211105_Commande_MPPT_v2.c,195 :: 		++sweep_iteration;                                       // go to the next iteration
	INCF        _sweep_iteration+0, 1 
;211105_Commande_MPPT_v2.c,197 :: 		if (sweep_iteration < 3) {
	MOVLW       128
	XORWF       _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       3
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main24
;211105_Commande_MPPT_v2.c,198 :: 		if (sweep_duty_cycle[sweep_iteration]) D = sweep_duty_cycle[sweep_iteration];       // only assign new D if it is different from 0
	MOVLW       _sweep_duty_cycle+0
	MOVWF       FSR0L 
	MOVLW       hi_addr(_sweep_duty_cycle+0)
	MOVWF       FSR0H 
	MOVF        _sweep_iteration+0, 0 
	ADDWF       FSR0L, 1 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main25
	MOVLW       _sweep_duty_cycle+0
	MOVWF       FSR0L 
	MOVLW       hi_addr(_sweep_duty_cycle+0)
	MOVWF       FSR0H 
	MOVF        _sweep_iteration+0, 0 
	ADDWF       FSR0L, 1 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
	MOVLW       0
	MOVWF       _D+1 
L_main25:
;211105_Commande_MPPT_v2.c,199 :: 		}else { // getting here means that we have already logged the measured power for sweep 0, 1, 2
	GOTO        L_main26
L_main24:
;211105_Commande_MPPT_v2.c,200 :: 		sweep_iteration = 0;
	CLRF        _sweep_iteration+0 
;211105_Commande_MPPT_v2.c,202 :: 		D = D_max_fast_gmppt;
	MOVF        _D_max_fast_gmppt+0, 0 
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,205 :: 		last_voltage_in = 0;
	CLRF        _last_voltage_in+0 
	CLRF        _last_voltage_in+1 
;211105_Commande_MPPT_v2.c,206 :: 		last_current_in = 0;
	CLRF        _last_current_in+0 
	CLRF        _last_current_in+1 
;211105_Commande_MPPT_v2.c,207 :: 		last_voltage_out = 0;
	CLRF        _last_voltage_out+0 
	CLRF        _last_voltage_out+1 
;211105_Commande_MPPT_v2.c,208 :: 		last_measured_power = 0;
	CLRF        _last_measured_power+0 
	CLRF        _last_measured_power+1 
	CLRF        _last_measured_power+2 
	CLRF        _last_measured_power+3 
;211105_Commande_MPPT_v2.c,209 :: 		last_delta_power = 0;
	CLRF        _last_delta_power+0 
	CLRF        _last_delta_power+1 
	CLRF        _last_delta_power+2 
	CLRF        _last_delta_power+3 
;211105_Commande_MPPT_v2.c,212 :: 		speed_coeff = 4;
	MOVLW       4
	MOVWF       _speed_coeff+0 
;211105_Commande_MPPT_v2.c,214 :: 		P_max_adaptive = 0;
	CLRF        _P_max_adaptive+0 
	CLRF        _P_max_adaptive+1 
	CLRF        _P_max_adaptive+2 
	CLRF        _P_max_adaptive+3 
;211105_Commande_MPPT_v2.c,215 :: 		D_max_adaptive = 0;
	CLRF        _D_max_adaptive+0 
;211105_Commande_MPPT_v2.c,218 :: 		mode = ADAPTIVE_PO;
	CLRF        _mode+0 
;211105_Commande_MPPT_v2.c,219 :: 		}
L_main26:
;211105_Commande_MPPT_v2.c,220 :: 		}
L_main22:
L_main19:
;211105_Commande_MPPT_v2.c,221 :: 		break;
	GOTO        L_main10
;211105_Commande_MPPT_v2.c,222 :: 		case ADAPTIVE_PO:    /******************************************/
L_main27:
;211105_Commande_MPPT_v2.c,224 :: 		measured_power = (INT32)voltage_in * (INT32)current_in;
	MOVF        _voltage_in+0, 0 
	MOVWF       R4 
	MOVF        _voltage_in+1, 0 
	MOVWF       R5 
	MOVLW       0
	BTFSC       _voltage_in+1, 7 
	MOVLW       255
	MOVWF       R6 
	MOVWF       R7 
	MOVF        _current_in+0, 0 
	MOVWF       R0 
	MOVF        _current_in+1, 0 
	MOVWF       R1 
	MOVLW       0
	BTFSC       _current_in+1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	CALL        _Mul_32x32_U+0, 0
	MOVF        R0, 0 
	MOVWF       _measured_power+0 
	MOVF        R1, 0 
	MOVWF       _measured_power+1 
	MOVF        R2, 0 
	MOVWF       _measured_power+2 
	MOVF        R3, 0 
	MOVWF       _measured_power+3 
;211105_Commande_MPPT_v2.c,226 :: 		delta_power = measured_power - last_measured_power;
	MOVF        R0, 0 
	MOVWF       _delta_power+0 
	MOVF        R1, 0 
	MOVWF       _delta_power+1 
	MOVF        R2, 0 
	MOVWF       _delta_power+2 
	MOVF        R3, 0 
	MOVWF       _delta_power+3 
	MOVF        _last_measured_power+0, 0 
	SUBWF       _delta_power+0, 1 
	MOVF        _last_measured_power+1, 0 
	SUBWFB      _delta_power+1, 1 
	MOVF        _last_measured_power+2, 0 
	SUBWFB      _delta_power+2, 1 
	MOVF        _last_measured_power+3, 0 
	SUBWFB      _delta_power+3, 1 
;211105_Commande_MPPT_v2.c,227 :: 		delta_voltage = voltage_in - last_voltage_in;
	MOVF        _last_voltage_in+0, 0 
	SUBWF       _voltage_in+0, 0 
	MOVWF       _delta_voltage+0 
	MOVF        _last_voltage_in+1, 0 
	SUBWFB      _voltage_in+1, 0 
	MOVWF       _delta_voltage+1 
;211105_Commande_MPPT_v2.c,229 :: 		if (measured_power > P_max_adaptive) {
	MOVLW       128
	XORWF       _P_max_adaptive+3, 0 
	MOVWF       R4 
	MOVLW       128
	XORWF       R3, 0 
	SUBWF       R4, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main87
	MOVF        R2, 0 
	SUBWF       _P_max_adaptive+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main87
	MOVF        R1, 0 
	SUBWF       _P_max_adaptive+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main87
	MOVF        R0, 0 
	SUBWF       _P_max_adaptive+0, 0 
L__main87:
	BTFSC       STATUS+0, 0 
	GOTO        L_main28
;211105_Commande_MPPT_v2.c,230 :: 		D_max_adaptive = D;
	MOVF        _D+0, 0 
	MOVWF       _D_max_adaptive+0 
;211105_Commande_MPPT_v2.c,231 :: 		P_max_adaptive = measured_power;
	MOVF        _measured_power+0, 0 
	MOVWF       _P_max_adaptive+0 
	MOVF        _measured_power+1, 0 
	MOVWF       _P_max_adaptive+1 
	MOVF        _measured_power+2, 0 
	MOVWF       _P_max_adaptive+2 
	MOVF        _measured_power+3, 0 
	MOVWF       _P_max_adaptive+3 
;211105_Commande_MPPT_v2.c,232 :: 		}
L_main28:
;211105_Commande_MPPT_v2.c,238 :: 		if (voltage_in >= 680) {
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       2
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main88
	MOVLW       168
	SUBWF       _voltage_in+0, 0 
L__main88:
	BTFSS       STATUS+0, 0 
	GOTO        L_main29
;211105_Commande_MPPT_v2.c,239 :: 		D_step = speed_coeff;
	MOVF        _speed_coeff+0, 0 
	MOVWF       _D_step+0 
;211105_Commande_MPPT_v2.c,240 :: 		}else if (voltage_in >= 470) {
	GOTO        L_main30
L_main29:
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       1
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main89
	MOVLW       214
	SUBWF       _voltage_in+0, 0 
L__main89:
	BTFSS       STATUS+0, 0 
	GOTO        L_main31
;211105_Commande_MPPT_v2.c,241 :: 		D_step = speed_coeff<<1;
	MOVF        _speed_coeff+0, 0 
	MOVWF       _D_step+0 
	RLCF        _D_step+0, 1 
	BCF         _D_step+0, 0 
;211105_Commande_MPPT_v2.c,242 :: 		}else {
	GOTO        L_main32
L_main31:
;211105_Commande_MPPT_v2.c,243 :: 		D_step = speed_coeff<<2;
	MOVF        _speed_coeff+0, 0 
	MOVWF       _D_step+0 
	RLCF        _D_step+0, 1 
	BCF         _D_step+0, 0 
	RLCF        _D_step+0, 1 
	BCF         _D_step+0, 0 
;211105_Commande_MPPT_v2.c,244 :: 		}
L_main32:
L_main30:
;211105_Commande_MPPT_v2.c,247 :: 		if (last_measured_power) {
	MOVF        _last_measured_power+0, 0 
	IORWF       _last_measured_power+1, 0 
	IORWF       _last_measured_power+2, 0 
	IORWF       _last_measured_power+3, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_main33
;211105_Commande_MPPT_v2.c,248 :: 		if ( (delta_power >= 0 && delta_voltage >= 0) || (delta_power <= 0 && delta_voltage <= 0) ) {
	MOVLW       128
	XORWF       _delta_power+3, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main90
	MOVLW       0
	SUBWF       _delta_power+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main90
	MOVLW       0
	SUBWF       _delta_power+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main90
	MOVLW       0
	SUBWF       _delta_power+0, 0 
L__main90:
	BTFSS       STATUS+0, 0 
	GOTO        L__main69
	MOVLW       128
	XORWF       _delta_voltage+1, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main91
	MOVLW       0
	SUBWF       _delta_voltage+0, 0 
L__main91:
	BTFSS       STATUS+0, 0 
	GOTO        L__main69
	GOTO        L__main67
L__main69:
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       _delta_power+3, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main92
	MOVF        _delta_power+2, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main92
	MOVF        _delta_power+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main92
	MOVF        _delta_power+0, 0 
	SUBLW       0
L__main92:
	BTFSS       STATUS+0, 0 
	GOTO        L__main68
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       _delta_voltage+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main93
	MOVF        _delta_voltage+0, 0 
	SUBLW       0
L__main93:
	BTFSS       STATUS+0, 0 
	GOTO        L__main68
	GOTO        L__main67
L__main68:
	GOTO        L_main40
L__main67:
;211105_Commande_MPPT_v2.c,249 :: 		D -= D_step;
	MOVF        _D_step+0, 0 
	SUBWF       _D+0, 1 
	MOVLW       0
	SUBWFB      _D+1, 1 
;211105_Commande_MPPT_v2.c,250 :: 		}else {
	GOTO        L_main41
L_main40:
;211105_Commande_MPPT_v2.c,251 :: 		D += D_step;
	MOVF        _D_step+0, 0 
	ADDWF       _D+0, 1 
	MOVLW       0
	ADDWFC      _D+1, 1 
;211105_Commande_MPPT_v2.c,252 :: 		}
L_main41:
;211105_Commande_MPPT_v2.c,253 :: 		if (oscillation_detect < OSCILLATION_MAX) {
	MOVLW       3
	SUBWF       _oscillation_detect+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main42
;211105_Commande_MPPT_v2.c,254 :: 		if ( (last_delta_power >= 0 && delta_power <= 0) || (last_delta_power <= 0 && delta_power >= 0) ) {
	MOVLW       128
	XORWF       _last_delta_power+3, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main94
	MOVLW       0
	SUBWF       _last_delta_power+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main94
	MOVLW       0
	SUBWF       _last_delta_power+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main94
	MOVLW       0
	SUBWF       _last_delta_power+0, 0 
L__main94:
	BTFSS       STATUS+0, 0 
	GOTO        L__main66
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       _delta_power+3, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main95
	MOVF        _delta_power+2, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main95
	MOVF        _delta_power+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main95
	MOVF        _delta_power+0, 0 
	SUBLW       0
L__main95:
	BTFSS       STATUS+0, 0 
	GOTO        L__main66
	GOTO        L__main64
L__main66:
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       _last_delta_power+3, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main96
	MOVF        _last_delta_power+2, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main96
	MOVF        _last_delta_power+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main96
	MOVF        _last_delta_power+0, 0 
	SUBLW       0
L__main96:
	BTFSS       STATUS+0, 0 
	GOTO        L__main65
	MOVLW       128
	XORWF       _delta_power+3, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main97
	MOVLW       0
	SUBWF       _delta_power+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main97
	MOVLW       0
	SUBWF       _delta_power+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main97
	MOVLW       0
	SUBWF       _delta_power+0, 0 
L__main97:
	BTFSS       STATUS+0, 0 
	GOTO        L__main65
	GOTO        L__main64
L__main65:
	GOTO        L_main49
L__main64:
;211105_Commande_MPPT_v2.c,255 :: 		++oscillation_detect;                // increment the oscillation detect counter
	INCF        _oscillation_detect+0, 1 
;211105_Commande_MPPT_v2.c,256 :: 		}else {
	GOTO        L_main50
L_main49:
;211105_Commande_MPPT_v2.c,257 :: 		oscillation_detect = 0;              // any interruption means we need to reset this counter
	CLRF        _oscillation_detect+0 
;211105_Commande_MPPT_v2.c,258 :: 		}
L_main50:
;211105_Commande_MPPT_v2.c,259 :: 		}
L_main42:
;211105_Commande_MPPT_v2.c,260 :: 		if (oscillation_detect == OSCILLATION_MAX && speed_coeff > 1) {
	MOVF        _oscillation_detect+0, 0 
	XORLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L_main53
	MOVF        _speed_coeff+0, 0 
	SUBLW       1
	BTFSC       STATUS+0, 0 
	GOTO        L_main53
L__main63:
;211105_Commande_MPPT_v2.c,261 :: 		speed_coeff >>= 1;
	RRCF        _speed_coeff+0, 1 
	BCF         _speed_coeff+0, 7 
;211105_Commande_MPPT_v2.c,262 :: 		oscillation_detect = 0;
	CLRF        _oscillation_detect+0 
;211105_Commande_MPPT_v2.c,263 :: 		}
L_main53:
;211105_Commande_MPPT_v2.c,264 :: 		if (speed_coeff == 1) {
	MOVF        _speed_coeff+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main54
;211105_Commande_MPPT_v2.c,265 :: 		mode = STEADY_STATE;                   // if speed_coeff becomes 1 it means that we should go into steady state, its ok we aint losing much
	MOVLW       2
	MOVWF       _mode+0 
;211105_Commande_MPPT_v2.c,266 :: 		oscillation_detect = 0;
	CLRF        _oscillation_detect+0 
;211105_Commande_MPPT_v2.c,267 :: 		D = D_max_adaptive;
	MOVF        _D_max_adaptive+0, 0 
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,268 :: 		}
L_main54:
;211105_Commande_MPPT_v2.c,269 :: 		}
L_main33:
;211105_Commande_MPPT_v2.c,272 :: 		last_delta_power = delta_power;
	MOVF        _delta_power+0, 0 
	MOVWF       _last_delta_power+0 
	MOVF        _delta_power+1, 0 
	MOVWF       _last_delta_power+1 
	MOVF        _delta_power+2, 0 
	MOVWF       _last_delta_power+2 
	MOVF        _delta_power+3, 0 
	MOVWF       _last_delta_power+3 
;211105_Commande_MPPT_v2.c,273 :: 		last_voltage_in = voltage_in;
	MOVF        _voltage_in+0, 0 
	MOVWF       _last_voltage_in+0 
	MOVF        _voltage_in+1, 0 
	MOVWF       _last_voltage_in+1 
;211105_Commande_MPPT_v2.c,274 :: 		last_measured_power = measured_power;
	MOVF        _measured_power+0, 0 
	MOVWF       _last_measured_power+0 
	MOVF        _measured_power+1, 0 
	MOVWF       _last_measured_power+1 
	MOVF        _measured_power+2, 0 
	MOVWF       _last_measured_power+2 
	MOVF        _measured_power+3, 0 
	MOVWF       _last_measured_power+3 
;211105_Commande_MPPT_v2.c,275 :: 		break;
	GOTO        L_main10
;211105_Commande_MPPT_v2.c,276 :: 		case STEADY_STATE:
L_main55:
;211105_Commande_MPPT_v2.c,278 :: 		measured_power = (INT32)voltage_in * (INT32)current_in;
	MOVF        _voltage_in+0, 0 
	MOVWF       R4 
	MOVF        _voltage_in+1, 0 
	MOVWF       R5 
	MOVLW       0
	BTFSC       _voltage_in+1, 7 
	MOVLW       255
	MOVWF       R6 
	MOVWF       R7 
	MOVF        _current_in+0, 0 
	MOVWF       R0 
	MOVF        _current_in+1, 0 
	MOVWF       R1 
	MOVLW       0
	BTFSC       _current_in+1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	CALL        _Mul_32x32_U+0, 0
	MOVF        R0, 0 
	MOVWF       _measured_power+0 
	MOVF        R1, 0 
	MOVWF       _measured_power+1 
	MOVF        R2, 0 
	MOVWF       _measured_power+2 
	MOVF        R3, 0 
	MOVWF       _measured_power+3 
;211105_Commande_MPPT_v2.c,280 :: 		if ((measured_power - P_max_adaptive) > (measured_power>>4) || (P_max_adaptive - measured_power) > (measured_power>>4)) {
	MOVF        R0, 0 
	MOVWF       R9 
	MOVF        R1, 0 
	MOVWF       R10 
	MOVF        R2, 0 
	MOVWF       R11 
	MOVF        R3, 0 
	MOVWF       R12 
	MOVF        _P_max_adaptive+0, 0 
	SUBWF       R9, 1 
	MOVF        _P_max_adaptive+1, 0 
	SUBWFB      R10, 1 
	MOVF        _P_max_adaptive+2, 0 
	SUBWFB      R11, 1 
	MOVF        _P_max_adaptive+3, 0 
	SUBWFB      R12, 1 
	MOVLW       4
	MOVWF       R8 
	MOVF        R0, 0 
	MOVWF       R4 
	MOVF        R1, 0 
	MOVWF       R5 
	MOVF        R2, 0 
	MOVWF       R6 
	MOVF        R3, 0 
	MOVWF       R7 
	MOVF        R8, 0 
L__main98:
	BZ          L__main99
	RRCF        R7, 1 
	RRCF        R6, 1 
	RRCF        R5, 1 
	RRCF        R4, 1 
	BCF         R7, 7 
	BTFSC       R7, 6 
	BSF         R7, 7 
	ADDLW       255
	GOTO        L__main98
L__main99:
	MOVLW       128
	XORWF       R7, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       R12, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main100
	MOVF        R11, 0 
	SUBWF       R6, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main100
	MOVF        R10, 0 
	SUBWF       R5, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main100
	MOVF        R9, 0 
	SUBWF       R4, 0 
L__main100:
	BTFSS       STATUS+0, 0 
	GOTO        L__main62
	MOVF        _P_max_adaptive+0, 0 
	MOVWF       R5 
	MOVF        _P_max_adaptive+1, 0 
	MOVWF       R6 
	MOVF        _P_max_adaptive+2, 0 
	MOVWF       R7 
	MOVF        _P_max_adaptive+3, 0 
	MOVWF       R8 
	MOVF        _measured_power+0, 0 
	SUBWF       R5, 1 
	MOVF        _measured_power+1, 0 
	SUBWFB      R6, 1 
	MOVF        _measured_power+2, 0 
	SUBWFB      R7, 1 
	MOVF        _measured_power+3, 0 
	SUBWFB      R8, 1 
	MOVLW       4
	MOVWF       R0 
	MOVF        _measured_power+0, 0 
	MOVWF       R1 
	MOVF        _measured_power+1, 0 
	MOVWF       R2 
	MOVF        _measured_power+2, 0 
	MOVWF       R3 
	MOVF        _measured_power+3, 0 
	MOVWF       R4 
	MOVF        R0, 0 
L__main101:
	BZ          L__main102
	RRCF        R4, 1 
	RRCF        R3, 1 
	RRCF        R2, 1 
	RRCF        R1, 1 
	BCF         R4, 7 
	BTFSC       R4, 6 
	BSF         R4, 7 
	ADDLW       255
	GOTO        L__main101
L__main102:
	MOVLW       128
	XORWF       R4, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       R8, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main103
	MOVF        R7, 0 
	SUBWF       R3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main103
	MOVF        R6, 0 
	SUBWF       R2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main103
	MOVF        R5, 0 
	SUBWF       R1, 0 
L__main103:
	BTFSS       STATUS+0, 0 
	GOTO        L__main62
	GOTO        L_main58
L__main62:
;211105_Commande_MPPT_v2.c,281 :: 		mode = FAST_GMPPT;
	MOVLW       1
	MOVWF       _mode+0 
;211105_Commande_MPPT_v2.c,282 :: 		P_max_adaptive = 0;                // reset P_max_adaptive
	CLRF        _P_max_adaptive+0 
	CLRF        _P_max_adaptive+1 
	CLRF        _P_max_adaptive+2 
	CLRF        _P_max_adaptive+3 
;211105_Commande_MPPT_v2.c,283 :: 		P_max_fast_gmppt = 0;              // register the max power obtained during the sweep
	CLRF        _P_max_fast_gmppt+0 
	CLRF        _P_max_fast_gmppt+1 
	CLRF        _P_max_fast_gmppt+2 
	CLRF        _P_max_fast_gmppt+3 
;211105_Commande_MPPT_v2.c,284 :: 		D_max_fast_gmppt = 0;
	CLRF        _D_max_fast_gmppt+0 
;211105_Commande_MPPT_v2.c,286 :: 		D = sweep_duty_cycle[sweep_iteration];
	MOVLW       _sweep_duty_cycle+0
	MOVWF       FSR0L 
	MOVLW       hi_addr(_sweep_duty_cycle+0)
	MOVWF       FSR0H 
	MOVF        _sweep_iteration+0, 0 
	ADDWF       FSR0L, 1 
	MOVLW       0
	BTFSC       _sweep_iteration+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,287 :: 		}
L_main58:
;211105_Commande_MPPT_v2.c,288 :: 		break;
	GOTO        L_main10
;211105_Commande_MPPT_v2.c,289 :: 		}
L_main9:
	MOVF        _mode+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_main11
	MOVF        _mode+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_main27
	MOVF        _mode+0, 0 
	XORLW       2
	BTFSC       STATUS+0, 2 
	GOTO        L_main55
L_main10:
;211105_Commande_MPPT_v2.c,292 :: 		if (D > MAX_PWM) {
	MOVLW       0
	MOVWF       R0 
	MOVF        _D+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main104
	MOVF        _D+0, 0 
	SUBLW       240
L__main104:
	BTFSC       STATUS+0, 0 
	GOTO        L_main59
;211105_Commande_MPPT_v2.c,293 :: 		D = MAX_PWM;
	MOVLW       240
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,294 :: 		}else if (D < MIN_PWM) {
	GOTO        L_main60
L_main59:
	MOVLW       0
	SUBWF       _D+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main105
	MOVLW       20
	SUBWF       _D+0, 0 
L__main105:
	BTFSC       STATUS+0, 0 
	GOTO        L_main61
;211105_Commande_MPPT_v2.c,295 :: 		D = MIN_PWM;
	MOVLW       20
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,296 :: 		}
L_main61:
L_main60:
;211105_Commande_MPPT_v2.c,297 :: 		PWM1_Set_Duty(D);                   // send duty cycle
	MOVF        _D+0, 0 
	MOVWF       FARG_PWM1_Set_Duty_new_duty+0 
	CALL        _PWM1_Set_Duty+0, 0
;211105_Commande_MPPT_v2.c,299 :: 		T0CON |= BIT7;    // enable timer here
	BSF         T0CON+0, 7 
;211105_Commande_MPPT_v2.c,301 :: 		settled = 0;
	CLRF        _settled+0 
;211105_Commande_MPPT_v2.c,302 :: 		}
L_main2:
;211105_Commande_MPPT_v2.c,303 :: 		asm clrwdt;
	CLRWDT
;211105_Commande_MPPT_v2.c,304 :: 		};
	GOTO        L_main0
;211105_Commande_MPPT_v2.c,305 :: 		}
	GOTO        $+0
; end of _main

_interrupt:

;211105_Commande_MPPT_v2.c,309 :: 		void interrupt() {
;211105_Commande_MPPT_v2.c,312 :: 		INTCON &= ~BIT2;
	BCF         INTCON+0, 2 
;211105_Commande_MPPT_v2.c,314 :: 		T0CON &= ~BIT7;
	MOVLW       127
	ANDWF       T0CON+0, 1 
;211105_Commande_MPPT_v2.c,316 :: 		settled = 1;            // indicate that a measurement is done
	MOVLW       1
	MOVWF       _settled+0 
;211105_Commande_MPPT_v2.c,317 :: 		}
L__interrupt106:
	RETFIE      1
; end of _interrupt

_init:

;211105_Commande_MPPT_v2.c,320 :: 		void init() {
;211105_Commande_MPPT_v2.c,326 :: 		OSCCON = 0x72;
	MOVLW       114
	MOVWF       OSCCON+0 
;211105_Commande_MPPT_v2.c,335 :: 		T0CON  = 0xC5;
	MOVLW       197
	MOVWF       T0CON+0 
;211105_Commande_MPPT_v2.c,339 :: 		TRISA = 0xFF;
	MOVLW       255
	MOVWF       TRISA+0 
;211105_Commande_MPPT_v2.c,340 :: 		PORTA = PORTA | 0x07;
	MOVLW       7
	IORWF       PORTA+0, 1 
;211105_Commande_MPPT_v2.c,344 :: 		TRISB = TRISB & 0b11111000; // RB0, RB1 and RB2 as OUTPUT
	MOVLW       248
	ANDWF       TRISB+0, 1 
;211105_Commande_MPPT_v2.c,345 :: 		PORTB = PORTB & 0b11111000; // tie them down to 0
	MOVLW       248
	ANDWF       PORTB+0, 1 
;211105_Commande_MPPT_v2.c,348 :: 		INTCON = (BIT7 + BIT5);
	MOVLW       160
	MOVWF       INTCON+0 
;211105_Commande_MPPT_v2.c,355 :: 		PWM1_Init(10000);         // set PWM to 10kHz, but the REAL PWM is 100kHz
	BCF         T2CON+0, 0, 0
	BCF         T2CON+0, 1, 0
	MOVLW       199
	MOVWF       PR2+0, 0
	CALL        _PWM1_Init+0, 0
;211105_Commande_MPPT_v2.c,356 :: 		PWM1_Start();             // start PWM
	CALL        _PWM1_Start+0, 0
;211105_Commande_MPPT_v2.c,358 :: 		}
	RETURN      0
; end of _init

_LED0_ON:

;211105_Commande_MPPT_v2.c,359 :: 		void LED0_ON() {
;211105_Commande_MPPT_v2.c,360 :: 		PORTB |= BIT0; // turn on LED0
	BSF         PORTB+0, 0 
;211105_Commande_MPPT_v2.c,361 :: 		}
	RETURN      0
; end of _LED0_ON

_LED0_OFF:

;211105_Commande_MPPT_v2.c,362 :: 		void LED0_OFF() {
;211105_Commande_MPPT_v2.c,363 :: 		PORTB &= ~BIT0; // clear LED0
	BCF         PORTB+0, 0 
;211105_Commande_MPPT_v2.c,364 :: 		}
	RETURN      0
; end of _LED0_OFF

_LED1_ON:

;211105_Commande_MPPT_v2.c,365 :: 		void LED1_ON() {
;211105_Commande_MPPT_v2.c,366 :: 		PORTB |= BIT1; // turn on LED1
	BSF         PORTB+0, 1 
;211105_Commande_MPPT_v2.c,367 :: 		}
	RETURN      0
; end of _LED1_ON

_LED1_OFF:

;211105_Commande_MPPT_v2.c,368 :: 		void LED1_OFF() {
;211105_Commande_MPPT_v2.c,369 :: 		PORTB &= ~BIT1; // clear LED1
	BCF         PORTB+0, 1 
;211105_Commande_MPPT_v2.c,370 :: 		}
	RETURN      0
; end of _LED1_OFF
