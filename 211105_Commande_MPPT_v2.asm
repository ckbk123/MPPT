
_main:

;211105_Commande_MPPT_v2.c,141 :: 		void main() {
;211105_Commande_MPPT_v2.c,143 :: 		init();
	CALL        _init+0, 0
;211105_Commande_MPPT_v2.c,145 :: 		while(1) {
L_main0:
;211105_Commande_MPPT_v2.c,148 :: 		if (settled) {
	MOVF        _settled+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main2
;211105_Commande_MPPT_v2.c,151 :: 		for (counter = 0; counter < 4; ++counter) {
	CLRF        _counter+0 
L_main3:
	MOVLW       4
	SUBWF       _counter+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main4
;211105_Commande_MPPT_v2.c,152 :: 		voltage_in += ADC_Read(0);
	CLRF        FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	MOVF        R0, 0 
	ADDWF       _voltage_in+0, 1 
	MOVF        R1, 0 
	ADDWFC      _voltage_in+1, 1 
;211105_Commande_MPPT_v2.c,151 :: 		for (counter = 0; counter < 4; ++counter) {
	INCF        _counter+0, 1 
;211105_Commande_MPPT_v2.c,154 :: 		}
	GOTO        L_main3
L_main4:
;211105_Commande_MPPT_v2.c,156 :: 		voltage_in >>= 2;
	RRCF        _voltage_in+1, 1 
	RRCF        _voltage_in+0, 1 
	BCF         _voltage_in+1, 7 
	BTFSC       _voltage_in+1, 6 
	BSF         _voltage_in+1, 7 
	RRCF        _voltage_in+1, 1 
	RRCF        _voltage_in+0, 1 
	BCF         _voltage_in+1, 7 
	BTFSC       _voltage_in+1, 6 
	BSF         _voltage_in+1, 7 
;211105_Commande_MPPT_v2.c,160 :: 		for (counter = 0; counter < 8; ++counter) {
	CLRF        _counter+0 
L_main6:
	MOVLW       8
	SUBWF       _counter+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main7
;211105_Commande_MPPT_v2.c,161 :: 		current_in += ADC_Read(1);
	MOVLW       1
	MOVWF       FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	MOVF        R0, 0 
	ADDWF       _current_in+0, 1 
	MOVF        R1, 0 
	ADDWFC      _current_in+1, 1 
;211105_Commande_MPPT_v2.c,160 :: 		for (counter = 0; counter < 8; ++counter) {
	INCF        _counter+0, 1 
;211105_Commande_MPPT_v2.c,162 :: 		}
	GOTO        L_main6
L_main7:
;211105_Commande_MPPT_v2.c,164 :: 		current_in >>= 3;
	MOVLW       3
	MOVWF       R2 
	MOVF        _current_in+0, 0 
	MOVWF       R0 
	MOVF        _current_in+1, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main73:
	BZ          L__main74
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	BTFSC       R1, 6 
	BSF         R1, 7 
	ADDLW       255
	GOTO        L__main73
L__main74:
	MOVF        R0, 0 
	MOVWF       _current_in+0 
	MOVF        R1, 0 
	MOVWF       _current_in+1 
;211105_Commande_MPPT_v2.c,167 :: 		measured_power = (INT32)voltage_in * (INT32)current_in;
	MOVF        _voltage_in+0, 0 
	MOVWF       R4 
	MOVF        _voltage_in+1, 0 
	MOVWF       R5 
	MOVLW       0
	BTFSC       _voltage_in+1, 7 
	MOVLW       255
	MOVWF       R6 
	MOVWF       R7 
	MOVLW       0
	BTFSC       R1, 7 
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
;211105_Commande_MPPT_v2.c,169 :: 		switch(mode) {
	GOTO        L_main9
;211105_Commande_MPPT_v2.c,170 :: 		case FAST_GMPPT:  /* THIS SECTION IS STILL OPTIMIZABLE */
L_main11:
;211105_Commande_MPPT_v2.c,176 :: 		if (sweep_iteration < 3 && (voltage_in < sweep_lower_bounds[sweep_iteration] || voltage_in > sweep_upper_bounds[sweep_iteration]) ) {
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
	GOTO        L__main75
	MOVF        R1, 0 
	SUBWF       _voltage_in+0, 0 
L__main75:
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
	GOTO        L__main76
	MOVF        _voltage_in+0, 0 
	SUBWF       R1, 0 
L__main76:
	BTFSS       STATUS+0, 0 
	GOTO        L__main72
	GOTO        L_main16
L__main72:
L__main71:
;211105_Commande_MPPT_v2.c,177 :: 		if (voltage_in < sweep_target[sweep_iteration]) {
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
	GOTO        L__main77
	MOVF        R1, 0 
	SUBWF       _voltage_in+0, 0 
L__main77:
	BTFSC       STATUS+0, 0 
	GOTO        L_main17
;211105_Commande_MPPT_v2.c,178 :: 		D = D - ( (sweep_target[sweep_iteration] - voltage_in)>>(3+sweep_iteration) );
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
	ADDLW       3
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
L__main78:
	BZ          L__main79
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	BTFSC       R1, 6 
	BSF         R1, 7 
	ADDLW       255
	GOTO        L__main78
L__main79:
	MOVF        R0, 0 
	SUBWF       _D+0, 1 
	MOVF        R1, 0 
	SUBWFB      _D+1, 1 
;211105_Commande_MPPT_v2.c,179 :: 		}else {
	GOTO        L_main18
L_main17:
;211105_Commande_MPPT_v2.c,180 :: 		D = D + ( (voltage_in - sweep_target[sweep_iteration])>>(3+sweep_iteration) );
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
	ADDLW       3
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
	ADDWF       _D+0, 1 
	MOVF        R1, 0 
	ADDWFC      _D+1, 1 
;211105_Commande_MPPT_v2.c,181 :: 		}
L_main18:
;211105_Commande_MPPT_v2.c,182 :: 		}else if (sweep_iteration < 3 && voltage_in >= sweep_lower_bounds[sweep_iteration] && voltage_in <= sweep_upper_bounds[sweep_iteration]) {
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
	GOTO        L__main82
	MOVF        R1, 0 
	SUBWF       _voltage_in+0, 0 
L__main82:
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
	GOTO        L__main83
	MOVF        _voltage_in+0, 0 
	SUBWF       R1, 0 
L__main83:
	BTFSS       STATUS+0, 0 
	GOTO        L_main22
L__main70:
;211105_Commande_MPPT_v2.c,183 :: 		sweep_duty_cycle[sweep_iteration] = D;                   // save the current duty cycle that has the correct voltage
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
;211105_Commande_MPPT_v2.c,185 :: 		if (measured_power > P_max_fast_gmppt) {
	MOVLW       128
	XORWF       _P_max_fast_gmppt+3, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       _measured_power+3, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main84
	MOVF        _measured_power+2, 0 
	SUBWF       _P_max_fast_gmppt+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main84
	MOVF        _measured_power+1, 0 
	SUBWF       _P_max_fast_gmppt+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main84
	MOVF        _measured_power+0, 0 
	SUBWF       _P_max_fast_gmppt+0, 0 
L__main84:
	BTFSC       STATUS+0, 0 
	GOTO        L_main23
;211105_Commande_MPPT_v2.c,186 :: 		D_max_fast_gmppt = measured_power;
	MOVF        _measured_power+0, 0 
	MOVWF       _D_max_fast_gmppt+0 
;211105_Commande_MPPT_v2.c,187 :: 		D_max_fast_gmppt = D;
	MOVF        _D+0, 0 
	MOVWF       _D_max_fast_gmppt+0 
;211105_Commande_MPPT_v2.c,188 :: 		}
L_main23:
;211105_Commande_MPPT_v2.c,190 :: 		++sweep_iteration;                                       // go to the next iteration
	INCF        _sweep_iteration+0, 1 
;211105_Commande_MPPT_v2.c,192 :: 		if (sweep_iteration < 3) {
	MOVLW       128
	XORWF       _sweep_iteration+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       3
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main24
;211105_Commande_MPPT_v2.c,193 :: 		if (sweep_duty_cycle[sweep_iteration]) D = sweep_duty_cycle[sweep_iteration];       // only assign new D if it is different from 0
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
;211105_Commande_MPPT_v2.c,194 :: 		}else { // getting here means that we have already logged the measured power for sweep 0, 1, 2
	GOTO        L_main26
L_main24:
;211105_Commande_MPPT_v2.c,195 :: 		sweep_iteration = 0;
	CLRF        _sweep_iteration+0 
;211105_Commande_MPPT_v2.c,197 :: 		D = D_max_fast_gmppt;
	MOVF        _D_max_fast_gmppt+0, 0 
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,200 :: 		last_voltage_in = 0;
	CLRF        _last_voltage_in+0 
	CLRF        _last_voltage_in+1 
;211105_Commande_MPPT_v2.c,201 :: 		last_current_in = 0;
	CLRF        _last_current_in+0 
	CLRF        _last_current_in+1 
;211105_Commande_MPPT_v2.c,202 :: 		last_voltage_out = 0;
	CLRF        _last_voltage_out+0 
	CLRF        _last_voltage_out+1 
;211105_Commande_MPPT_v2.c,203 :: 		last_measured_power = 0;
	CLRF        _last_measured_power+0 
	CLRF        _last_measured_power+1 
	CLRF        _last_measured_power+2 
	CLRF        _last_measured_power+3 
;211105_Commande_MPPT_v2.c,204 :: 		last_delta_power = 0;
	CLRF        _last_delta_power+0 
	CLRF        _last_delta_power+1 
	CLRF        _last_delta_power+2 
	CLRF        _last_delta_power+3 
;211105_Commande_MPPT_v2.c,207 :: 		speed_coeff = 4;
	MOVLW       4
	MOVWF       _speed_coeff+0 
;211105_Commande_MPPT_v2.c,209 :: 		P_max_adaptive = 0;
	CLRF        _P_max_adaptive+0 
	CLRF        _P_max_adaptive+1 
	CLRF        _P_max_adaptive+2 
	CLRF        _P_max_adaptive+3 
;211105_Commande_MPPT_v2.c,210 :: 		D_max_adaptive = 0;
	CLRF        _D_max_adaptive+0 
;211105_Commande_MPPT_v2.c,214 :: 		mode = ADAPTIVE_PO;
	CLRF        _mode+0 
;211105_Commande_MPPT_v2.c,215 :: 		}
L_main26:
;211105_Commande_MPPT_v2.c,216 :: 		}
L_main22:
L_main19:
;211105_Commande_MPPT_v2.c,217 :: 		LED0_ON();
	CALL        _LED0_ON+0, 0
;211105_Commande_MPPT_v2.c,218 :: 		LED1_OFF();
	CALL        _LED1_OFF+0, 0
;211105_Commande_MPPT_v2.c,219 :: 		break;
	GOTO        L_main10
;211105_Commande_MPPT_v2.c,220 :: 		case ADAPTIVE_PO:    /******************************************/
L_main27:
;211105_Commande_MPPT_v2.c,221 :: 		LED1_ON();
	CALL        _LED1_ON+0, 0
;211105_Commande_MPPT_v2.c,222 :: 		LED0_OFF();
	CALL        _LED0_OFF+0, 0
;211105_Commande_MPPT_v2.c,224 :: 		delta_power = measured_power - last_measured_power;
	MOVF        _measured_power+0, 0 
	MOVWF       _delta_power+0 
	MOVF        _measured_power+1, 0 
	MOVWF       _delta_power+1 
	MOVF        _measured_power+2, 0 
	MOVWF       _delta_power+2 
	MOVF        _measured_power+3, 0 
	MOVWF       _delta_power+3 
	MOVF        _last_measured_power+0, 0 
	SUBWF       _delta_power+0, 1 
	MOVF        _last_measured_power+1, 0 
	SUBWFB      _delta_power+1, 1 
	MOVF        _last_measured_power+2, 0 
	SUBWFB      _delta_power+2, 1 
	MOVF        _last_measured_power+3, 0 
	SUBWFB      _delta_power+3, 1 
;211105_Commande_MPPT_v2.c,225 :: 		delta_voltage = voltage_in - last_voltage_in;
	MOVF        _last_voltage_in+0, 0 
	SUBWF       _voltage_in+0, 0 
	MOVWF       _delta_voltage+0 
	MOVF        _last_voltage_in+1, 0 
	SUBWFB      _voltage_in+1, 0 
	MOVWF       _delta_voltage+1 
;211105_Commande_MPPT_v2.c,227 :: 		if (measured_power > P_max_adaptive) {
	MOVLW       128
	XORWF       _P_max_adaptive+3, 0 
	MOVWF       R0 
	MOVLW       128
	XORWF       _measured_power+3, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main85
	MOVF        _measured_power+2, 0 
	SUBWF       _P_max_adaptive+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main85
	MOVF        _measured_power+1, 0 
	SUBWF       _P_max_adaptive+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main85
	MOVF        _measured_power+0, 0 
	SUBWF       _P_max_adaptive+0, 0 
L__main85:
	BTFSC       STATUS+0, 0 
	GOTO        L_main28
;211105_Commande_MPPT_v2.c,228 :: 		D_max_adaptive = D;
	MOVF        _D+0, 0 
	MOVWF       _D_max_adaptive+0 
;211105_Commande_MPPT_v2.c,229 :: 		P_max_adaptive = measured_power;
	MOVF        _measured_power+0, 0 
	MOVWF       _P_max_adaptive+0 
	MOVF        _measured_power+1, 0 
	MOVWF       _P_max_adaptive+1 
	MOVF        _measured_power+2, 0 
	MOVWF       _P_max_adaptive+2 
	MOVF        _measured_power+3, 0 
	MOVWF       _P_max_adaptive+3 
;211105_Commande_MPPT_v2.c,230 :: 		}
L_main28:
;211105_Commande_MPPT_v2.c,236 :: 		if (voltage_in >= 680) {
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       2
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main86
	MOVLW       168
	SUBWF       _voltage_in+0, 0 
L__main86:
	BTFSS       STATUS+0, 0 
	GOTO        L_main29
;211105_Commande_MPPT_v2.c,237 :: 		D_step = speed_coeff;
	MOVF        _speed_coeff+0, 0 
	MOVWF       _D_step+0 
;211105_Commande_MPPT_v2.c,238 :: 		}else if (voltage_in >= 470) {
	GOTO        L_main30
L_main29:
	MOVLW       128
	XORWF       _voltage_in+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       1
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main87
	MOVLW       214
	SUBWF       _voltage_in+0, 0 
L__main87:
	BTFSS       STATUS+0, 0 
	GOTO        L_main31
;211105_Commande_MPPT_v2.c,239 :: 		D_step = speed_coeff>>1;
	MOVF        _speed_coeff+0, 0 
	MOVWF       _D_step+0 
	RRCF        _D_step+0, 1 
	BCF         _D_step+0, 7 
;211105_Commande_MPPT_v2.c,240 :: 		}else {
	GOTO        L_main32
L_main31:
;211105_Commande_MPPT_v2.c,241 :: 		D_step = speed_coeff>>4;
	MOVF        _speed_coeff+0, 0 
	MOVWF       _D_step+0 
	RRCF        _D_step+0, 1 
	BCF         _D_step+0, 7 
	RRCF        _D_step+0, 1 
	BCF         _D_step+0, 7 
	RRCF        _D_step+0, 1 
	BCF         _D_step+0, 7 
	RRCF        _D_step+0, 1 
	BCF         _D_step+0, 7 
;211105_Commande_MPPT_v2.c,242 :: 		}
L_main32:
L_main30:
;211105_Commande_MPPT_v2.c,245 :: 		if (last_measured_power) {
	MOVF        _last_measured_power+0, 0 
	IORWF       _last_measured_power+1, 0 
	IORWF       _last_measured_power+2, 0 
	IORWF       _last_measured_power+3, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_main33
;211105_Commande_MPPT_v2.c,246 :: 		if ( (delta_power >= 0 && delta_voltage >= 0) || (delta_power <= 0 && delta_voltage <= 0) ) {
	MOVLW       128
	XORWF       _delta_power+3, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main88
	MOVLW       0
	SUBWF       _delta_power+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main88
	MOVLW       0
	SUBWF       _delta_power+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main88
	MOVLW       0
	SUBWF       _delta_power+0, 0 
L__main88:
	BTFSS       STATUS+0, 0 
	GOTO        L__main69
	MOVLW       128
	XORWF       _delta_voltage+1, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main89
	MOVLW       0
	SUBWF       _delta_voltage+0, 0 
L__main89:
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
	GOTO        L__main90
	MOVF        _delta_power+2, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main90
	MOVF        _delta_power+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main90
	MOVF        _delta_power+0, 0 
	SUBLW       0
L__main90:
	BTFSS       STATUS+0, 0 
	GOTO        L__main68
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       _delta_voltage+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main91
	MOVF        _delta_voltage+0, 0 
	SUBLW       0
L__main91:
	BTFSS       STATUS+0, 0 
	GOTO        L__main68
	GOTO        L__main67
L__main68:
	GOTO        L_main40
L__main67:
;211105_Commande_MPPT_v2.c,247 :: 		D -= D_step;
	MOVF        _D_step+0, 0 
	SUBWF       _D+0, 1 
	MOVLW       0
	SUBWFB      _D+1, 1 
;211105_Commande_MPPT_v2.c,248 :: 		}else {
	GOTO        L_main41
L_main40:
;211105_Commande_MPPT_v2.c,249 :: 		D += D_step;
	MOVF        _D_step+0, 0 
	ADDWF       _D+0, 1 
	MOVLW       0
	ADDWFC      _D+1, 1 
;211105_Commande_MPPT_v2.c,250 :: 		}
L_main41:
;211105_Commande_MPPT_v2.c,251 :: 		if (oscillation_detect < OSCILLATION_MAX) {
	MOVLW       4
	SUBWF       _oscillation_detect+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main42
;211105_Commande_MPPT_v2.c,252 :: 		if ( (last_delta_power >= 0 && delta_power <= 0) || (last_delta_power <= 0 && delta_power >= 0) ) {
	MOVLW       128
	XORWF       _last_delta_power+3, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main92
	MOVLW       0
	SUBWF       _last_delta_power+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main92
	MOVLW       0
	SUBWF       _last_delta_power+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main92
	MOVLW       0
	SUBWF       _last_delta_power+0, 0 
L__main92:
	BTFSS       STATUS+0, 0 
	GOTO        L__main66
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       _delta_power+3, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main93
	MOVF        _delta_power+2, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main93
	MOVF        _delta_power+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main93
	MOVF        _delta_power+0, 0 
	SUBLW       0
L__main93:
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
	GOTO        L__main94
	MOVF        _last_delta_power+2, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main94
	MOVF        _last_delta_power+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main94
	MOVF        _last_delta_power+0, 0 
	SUBLW       0
L__main94:
	BTFSS       STATUS+0, 0 
	GOTO        L__main65
	MOVLW       128
	XORWF       _delta_power+3, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main95
	MOVLW       0
	SUBWF       _delta_power+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main95
	MOVLW       0
	SUBWF       _delta_power+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main95
	MOVLW       0
	SUBWF       _delta_power+0, 0 
L__main95:
	BTFSS       STATUS+0, 0 
	GOTO        L__main65
	GOTO        L__main64
L__main65:
	GOTO        L_main49
L__main64:
;211105_Commande_MPPT_v2.c,253 :: 		++oscillation_detect;                // increment the oscillation detect counter
	INCF        _oscillation_detect+0, 1 
;211105_Commande_MPPT_v2.c,254 :: 		}else {
	GOTO        L_main50
L_main49:
;211105_Commande_MPPT_v2.c,255 :: 		oscillation_detect = 0;              // any interruption means we need to reset this counter
	CLRF        _oscillation_detect+0 
;211105_Commande_MPPT_v2.c,256 :: 		}
L_main50:
;211105_Commande_MPPT_v2.c,257 :: 		}
L_main42:
;211105_Commande_MPPT_v2.c,258 :: 		if (oscillation_detect == OSCILLATION_MAX && speed_coeff > 0) {
	MOVF        _oscillation_detect+0, 0 
	XORLW       4
	BTFSS       STATUS+0, 2 
	GOTO        L_main53
	MOVF        _speed_coeff+0, 0 
	SUBLW       0
	BTFSC       STATUS+0, 0 
	GOTO        L_main53
L__main63:
;211105_Commande_MPPT_v2.c,259 :: 		speed_coeff >>= 1;
	RRCF        _speed_coeff+0, 1 
	BCF         _speed_coeff+0, 7 
;211105_Commande_MPPT_v2.c,260 :: 		oscillation_detect = 0;
	CLRF        _oscillation_detect+0 
;211105_Commande_MPPT_v2.c,261 :: 		}
L_main53:
;211105_Commande_MPPT_v2.c,262 :: 		if (speed_coeff == 0) {
	MOVF        _speed_coeff+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main54
;211105_Commande_MPPT_v2.c,263 :: 		mode = STEADY_STATE;                   // if speed_coeff becomes 0 it means that we should go into steady state
	MOVLW       2
	MOVWF       _mode+0 
;211105_Commande_MPPT_v2.c,264 :: 		oscillation_detect = 0;
	CLRF        _oscillation_detect+0 
;211105_Commande_MPPT_v2.c,265 :: 		D = D_max_adaptive;
	MOVF        _D_max_adaptive+0, 0 
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,266 :: 		}
L_main54:
;211105_Commande_MPPT_v2.c,267 :: 		}
L_main33:
;211105_Commande_MPPT_v2.c,270 :: 		last_delta_power = delta_power;
	MOVF        _delta_power+0, 0 
	MOVWF       _last_delta_power+0 
	MOVF        _delta_power+1, 0 
	MOVWF       _last_delta_power+1 
	MOVF        _delta_power+2, 0 
	MOVWF       _last_delta_power+2 
	MOVF        _delta_power+3, 0 
	MOVWF       _last_delta_power+3 
;211105_Commande_MPPT_v2.c,271 :: 		last_voltage_in = voltage_in;
	MOVF        _voltage_in+0, 0 
	MOVWF       _last_voltage_in+0 
	MOVF        _voltage_in+1, 0 
	MOVWF       _last_voltage_in+1 
;211105_Commande_MPPT_v2.c,272 :: 		last_measured_power = measured_power;
	MOVF        _measured_power+0, 0 
	MOVWF       _last_measured_power+0 
	MOVF        _measured_power+1, 0 
	MOVWF       _last_measured_power+1 
	MOVF        _measured_power+2, 0 
	MOVWF       _last_measured_power+2 
	MOVF        _measured_power+3, 0 
	MOVWF       _last_measured_power+3 
;211105_Commande_MPPT_v2.c,273 :: 		break;
	GOTO        L_main10
;211105_Commande_MPPT_v2.c,274 :: 		case STEADY_STATE:
L_main55:
;211105_Commande_MPPT_v2.c,276 :: 		if ((measured_power - P_max_adaptive) > 1000 || (measured_power - P_max_adaptive) > 1000) {
	MOVF        _measured_power+0, 0 
	MOVWF       R1 
	MOVF        _measured_power+1, 0 
	MOVWF       R2 
	MOVF        _measured_power+2, 0 
	MOVWF       R3 
	MOVF        _measured_power+3, 0 
	MOVWF       R4 
	MOVF        _P_max_adaptive+0, 0 
	SUBWF       R1, 1 
	MOVF        _P_max_adaptive+1, 0 
	SUBWFB      R2, 1 
	MOVF        _P_max_adaptive+2, 0 
	SUBWFB      R3, 1 
	MOVF        _P_max_adaptive+3, 0 
	SUBWFB      R4, 1 
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       R4, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main96
	MOVF        R3, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main96
	MOVF        R2, 0 
	SUBLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L__main96
	MOVF        R1, 0 
	SUBLW       232
L__main96:
	BTFSS       STATUS+0, 0 
	GOTO        L__main62
	MOVF        _measured_power+0, 0 
	MOVWF       R1 
	MOVF        _measured_power+1, 0 
	MOVWF       R2 
	MOVF        _measured_power+2, 0 
	MOVWF       R3 
	MOVF        _measured_power+3, 0 
	MOVWF       R4 
	MOVF        _P_max_adaptive+0, 0 
	SUBWF       R1, 1 
	MOVF        _P_max_adaptive+1, 0 
	SUBWFB      R2, 1 
	MOVF        _P_max_adaptive+2, 0 
	SUBWFB      R3, 1 
	MOVF        _P_max_adaptive+3, 0 
	SUBWFB      R4, 1 
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       R4, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main97
	MOVF        R3, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__main97
	MOVF        R2, 0 
	SUBLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L__main97
	MOVF        R1, 0 
	SUBLW       232
L__main97:
	BTFSS       STATUS+0, 0 
	GOTO        L__main62
	GOTO        L_main58
L__main62:
;211105_Commande_MPPT_v2.c,277 :: 		mode = FAST_GMPPT;
	MOVLW       1
	MOVWF       _mode+0 
;211105_Commande_MPPT_v2.c,278 :: 		P_max_adaptive = 0;                // reset P_max_adaptive
	CLRF        _P_max_adaptive+0 
	CLRF        _P_max_adaptive+1 
	CLRF        _P_max_adaptive+2 
	CLRF        _P_max_adaptive+3 
;211105_Commande_MPPT_v2.c,279 :: 		P_max_fast_gmppt = 0;              // register the max power obtained during the sweep
	CLRF        _P_max_fast_gmppt+0 
	CLRF        _P_max_fast_gmppt+1 
	CLRF        _P_max_fast_gmppt+2 
	CLRF        _P_max_fast_gmppt+3 
;211105_Commande_MPPT_v2.c,280 :: 		D_max_fast_gmppt = 0;
	CLRF        _D_max_fast_gmppt+0 
;211105_Commande_MPPT_v2.c,281 :: 		}
L_main58:
;211105_Commande_MPPT_v2.c,282 :: 		break;
	GOTO        L_main10
;211105_Commande_MPPT_v2.c,283 :: 		}
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
;211105_Commande_MPPT_v2.c,286 :: 		if (D > MAX_PWM) {
	MOVLW       0
	MOVWF       R0 
	MOVF        _D+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main98
	MOVF        _D+0, 0 
	SUBLW       240
L__main98:
	BTFSC       STATUS+0, 0 
	GOTO        L_main59
;211105_Commande_MPPT_v2.c,287 :: 		D = MAX_PWM;
	MOVLW       240
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,288 :: 		}else if (D < MIN_PWM) {
	GOTO        L_main60
L_main59:
	MOVLW       0
	SUBWF       _D+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main99
	MOVLW       20
	SUBWF       _D+0, 0 
L__main99:
	BTFSC       STATUS+0, 0 
	GOTO        L_main61
;211105_Commande_MPPT_v2.c,289 :: 		D = MIN_PWM;
	MOVLW       20
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,290 :: 		}
L_main61:
L_main60:
;211105_Commande_MPPT_v2.c,291 :: 		PWM1_Set_Duty(D);                   // send duty cycle
	MOVF        _D+0, 0 
	MOVWF       FARG_PWM1_Set_Duty_new_duty+0 
	CALL        _PWM1_Set_Duty+0, 0
;211105_Commande_MPPT_v2.c,293 :: 		T0CON |= BIT7;    // enable timer here
	BSF         T0CON+0, 7 
;211105_Commande_MPPT_v2.c,295 :: 		settled = 0;
	CLRF        _settled+0 
;211105_Commande_MPPT_v2.c,296 :: 		}
L_main2:
;211105_Commande_MPPT_v2.c,297 :: 		asm clrwdt;
	CLRWDT
;211105_Commande_MPPT_v2.c,298 :: 		};
	GOTO        L_main0
;211105_Commande_MPPT_v2.c,299 :: 		}
	GOTO        $+0
; end of _main

_interrupt:

;211105_Commande_MPPT_v2.c,303 :: 		void interrupt() {
;211105_Commande_MPPT_v2.c,306 :: 		INTCON &= ~BIT2;
	BCF         INTCON+0, 2 
;211105_Commande_MPPT_v2.c,308 :: 		T0CON &= ~BIT7;
	MOVLW       127
	ANDWF       T0CON+0, 1 
;211105_Commande_MPPT_v2.c,310 :: 		settled = 1;            // indicate that a measurement is done
	MOVLW       1
	MOVWF       _settled+0 
;211105_Commande_MPPT_v2.c,311 :: 		}
L__interrupt100:
	RETFIE      1
; end of _interrupt

_init:

;211105_Commande_MPPT_v2.c,314 :: 		void init() {
;211105_Commande_MPPT_v2.c,320 :: 		OSCCON = 0x72;
	MOVLW       114
	MOVWF       OSCCON+0 
;211105_Commande_MPPT_v2.c,329 :: 		T0CON  = 0xC6;
	MOVLW       198
	MOVWF       T0CON+0 
;211105_Commande_MPPT_v2.c,333 :: 		TRISA = 0xFF;
	MOVLW       255
	MOVWF       TRISA+0 
;211105_Commande_MPPT_v2.c,334 :: 		PORTA = PORTA | 0x07;
	MOVLW       7
	IORWF       PORTA+0, 1 
;211105_Commande_MPPT_v2.c,338 :: 		TRISB = TRISB & 0b11111000; // RB0, RB1 and RB2 as OUTPUT
	MOVLW       248
	ANDWF       TRISB+0, 1 
;211105_Commande_MPPT_v2.c,339 :: 		PORTB = PORTB & 0b11111000; // tie them down to 0
	MOVLW       248
	ANDWF       PORTB+0, 1 
;211105_Commande_MPPT_v2.c,342 :: 		INTCON = (BIT7 + BIT5);
	MOVLW       160
	MOVWF       INTCON+0 
;211105_Commande_MPPT_v2.c,349 :: 		PWM1_Init(10000);         // set PWM to 10kHz, but the REAL PWM is 100kHz
	BCF         T2CON+0, 0, 0
	BCF         T2CON+0, 1, 0
	MOVLW       199
	MOVWF       PR2+0, 0
	CALL        _PWM1_Init+0, 0
;211105_Commande_MPPT_v2.c,350 :: 		PWM1_Start();             // start PWM
	CALL        _PWM1_Start+0, 0
;211105_Commande_MPPT_v2.c,352 :: 		}
	RETURN      0
; end of _init

_LED0_ON:

;211105_Commande_MPPT_v2.c,353 :: 		void LED0_ON() {
;211105_Commande_MPPT_v2.c,354 :: 		PORTB |= BIT0; // turn on LED0
	BSF         PORTB+0, 0 
;211105_Commande_MPPT_v2.c,355 :: 		}
	RETURN      0
; end of _LED0_ON

_LED0_OFF:

;211105_Commande_MPPT_v2.c,356 :: 		void LED0_OFF() {
;211105_Commande_MPPT_v2.c,357 :: 		PORTB &= ~BIT0; // clear LED0
	BCF         PORTB+0, 0 
;211105_Commande_MPPT_v2.c,358 :: 		}
	RETURN      0
; end of _LED0_OFF

_LED1_ON:

;211105_Commande_MPPT_v2.c,359 :: 		void LED1_ON() {
;211105_Commande_MPPT_v2.c,360 :: 		PORTB |= BIT1; // turn on LED1
	BSF         PORTB+0, 1 
;211105_Commande_MPPT_v2.c,361 :: 		}
	RETURN      0
; end of _LED1_ON

_LED1_OFF:

;211105_Commande_MPPT_v2.c,362 :: 		void LED1_OFF() {
;211105_Commande_MPPT_v2.c,363 :: 		PORTB &= ~BIT1; // clear LED1
	BCF         PORTB+0, 1 
;211105_Commande_MPPT_v2.c,364 :: 		}
	RETURN      0
; end of _LED1_OFF
