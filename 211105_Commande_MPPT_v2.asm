
_main:

;211105_Commande_MPPT_v2.c,117 :: 		void main() {
;211105_Commande_MPPT_v2.c,119 :: 		init();
	CALL        _init+0, 0
;211105_Commande_MPPT_v2.c,121 :: 		while(1) {
L_main0:
;211105_Commande_MPPT_v2.c,123 :: 		if (settled) {
	MOVF        _settled+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main2
;211105_Commande_MPPT_v2.c,126 :: 		for (counter = 0; counter < 4; ++counter) {
	CLRF        _counter+0 
L_main3:
	MOVLW       4
	SUBWF       _counter+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main4
;211105_Commande_MPPT_v2.c,127 :: 		voltage_in += ADC_Read(0);
	CLRF        FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	MOVF        R0, 0 
	ADDWF       _voltage_in+0, 1 
	MOVF        R1, 0 
	ADDWFC      _voltage_in+1, 1 
;211105_Commande_MPPT_v2.c,126 :: 		for (counter = 0; counter < 4; ++counter) {
	INCF        _counter+0, 1 
;211105_Commande_MPPT_v2.c,128 :: 		}
	GOTO        L_main3
L_main4:
;211105_Commande_MPPT_v2.c,130 :: 		voltage_in >>= 2;
	RRCF        _voltage_in+1, 1 
	RRCF        _voltage_in+0, 1 
	BCF         _voltage_in+1, 7 
	RRCF        _voltage_in+1, 1 
	RRCF        _voltage_in+0, 1 
	BCF         _voltage_in+1, 7 
;211105_Commande_MPPT_v2.c,133 :: 		for (counter = 0; counter < 8; ++counter) {
	CLRF        _counter+0 
L_main6:
	MOVLW       8
	SUBWF       _counter+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main7
;211105_Commande_MPPT_v2.c,134 :: 		current_in += ADC_Read(1);
	MOVLW       1
	MOVWF       FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	MOVF        R0, 0 
	ADDWF       _current_in+0, 1 
	MOVF        R1, 0 
	ADDWFC      _current_in+1, 1 
;211105_Commande_MPPT_v2.c,133 :: 		for (counter = 0; counter < 8; ++counter) {
	INCF        _counter+0, 1 
;211105_Commande_MPPT_v2.c,135 :: 		}
	GOTO        L_main6
L_main7:
;211105_Commande_MPPT_v2.c,137 :: 		current_in >>= 3;
	RRCF        _current_in+1, 1 
	RRCF        _current_in+0, 1 
	BCF         _current_in+1, 7 
	RRCF        _current_in+1, 1 
	RRCF        _current_in+0, 1 
	BCF         _current_in+1, 7 
	RRCF        _current_in+1, 1 
	RRCF        _current_in+0, 1 
	BCF         _current_in+1, 7 
;211105_Commande_MPPT_v2.c,140 :: 		for (counter = 0; counter < 4; ++counter) {
	CLRF        _counter+0 
L_main9:
	MOVLW       4
	SUBWF       _counter+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main10
;211105_Commande_MPPT_v2.c,141 :: 		voltage_out += ADC_Read(2);
	MOVLW       2
	MOVWF       FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	MOVF        R0, 0 
	ADDWF       _voltage_out+0, 1 
	MOVF        R1, 0 
	ADDWFC      _voltage_out+1, 1 
;211105_Commande_MPPT_v2.c,140 :: 		for (counter = 0; counter < 4; ++counter) {
	INCF        _counter+0, 1 
;211105_Commande_MPPT_v2.c,142 :: 		}
	GOTO        L_main9
L_main10:
;211105_Commande_MPPT_v2.c,144 :: 		voltage_out >>= 2;
	RRCF        _voltage_out+1, 1 
	RRCF        _voltage_out+0, 1 
	BCF         _voltage_out+1, 7 
	RRCF        _voltage_out+1, 1 
	RRCF        _voltage_out+0, 1 
	BCF         _voltage_out+1, 7 
;211105_Commande_MPPT_v2.c,147 :: 		measured_power = (UINT32)voltage_in * (UINT32)current_in;
	MOVF        _voltage_in+0, 0 
	MOVWF       R4 
	MOVF        _voltage_in+1, 0 
	MOVWF       R5 
	MOVLW       0
	MOVWF       R6 
	MOVWF       R7 
	MOVF        _current_in+0, 0 
	MOVWF       R0 
	MOVF        _current_in+1, 0 
	MOVWF       R1 
	MOVLW       0
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
;211105_Commande_MPPT_v2.c,150 :: 		delta_power = (INT32)measured_power - (INT32)last_measured_power;
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
;211105_Commande_MPPT_v2.c,151 :: 		delta_voltage = (INT16)voltage_in - (INT16)last_voltage_in;
	MOVF        _last_voltage_in+0, 0 
	SUBWF       _voltage_in+0, 0 
	MOVWF       _delta_voltage+0 
	MOVF        _last_voltage_in+1, 0 
	SUBWFB      _voltage_in+1, 0 
	MOVWF       _delta_voltage+1 
;211105_Commande_MPPT_v2.c,153 :: 		switch(mode) {
	GOTO        L_main12
;211105_Commande_MPPT_v2.c,154 :: 		case MPPT_PO:    /******************************************/
L_main14:
;211105_Commande_MPPT_v2.c,156 :: 		PORTB &= ~BIT1; // clear LED1
	BCF         PORTB+0, 1 
;211105_Commande_MPPT_v2.c,157 :: 		PORTB |= BIT0; //  set LED0
	BSF         PORTB+0, 0 
;211105_Commande_MPPT_v2.c,160 :: 		if ( abs(delta_power) > (last_measured_power>>4) ) {
	MOVF        _delta_power+0, 0 
	MOVWF       FARG_abs_a+0 
	MOVF        _delta_power+1, 0 
	MOVWF       FARG_abs_a+1 
	CALL        _abs+0, 0
	MOVLW       4
	MOVWF       R2 
	MOVF        _last_measured_power+0, 0 
	MOVWF       R3 
	MOVF        _last_measured_power+1, 0 
	MOVWF       R4 
	MOVF        _last_measured_power+2, 0 
	MOVWF       R5 
	MOVF        _last_measured_power+3, 0 
	MOVWF       R6 
	MOVF        R2, 0 
L__main76:
	BZ          L__main77
	RRCF        R6, 1 
	RRCF        R5, 1 
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R6, 7 
	ADDLW       255
	GOTO        L__main76
L__main77:
	MOVLW       0
	BTFSC       R1, 7 
	MOVLW       255
	SUBWF       R6, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main78
	MOVLW       0
	BTFSC       R1, 7 
	MOVLW       255
	SUBWF       R5, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main78
	MOVF        R1, 0 
	SUBWF       R4, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main78
	MOVF        R0, 0 
	SUBWF       R3, 0 
L__main78:
	BTFSC       STATUS+0, 0 
	GOTO        L_main15
;211105_Commande_MPPT_v2.c,161 :: 		mode = FAST_GMPPT;
	MOVLW       1
	MOVWF       _mode+0 
;211105_Commande_MPPT_v2.c,162 :: 		D = sweep_duty_cycle[0];                // make it change to the first guess immediately
	MOVF        _sweep_duty_cycle+0, 0 
	MOVWF       _D+0 
	MOVF        _sweep_duty_cycle+1, 0 
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,163 :: 		break;                                  // and just bail...
	GOTO        L_main13
;211105_Commande_MPPT_v2.c,164 :: 		}else {
L_main15:
;211105_Commande_MPPT_v2.c,166 :: 		direction = (delta_power < 0) ? -direction : direction;
	MOVLW       128
	XORWF       _delta_power+3, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main79
	MOVLW       0
	SUBWF       _delta_power+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main79
	MOVLW       0
	SUBWF       _delta_power+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main79
	MOVLW       0
	SUBWF       _delta_power+0, 0 
L__main79:
	BTFSC       STATUS+0, 0 
	GOTO        L_main17
	MOVF        _direction+0, 0 
	SUBLW       0
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	GOTO        L_main18
L_main17:
	MOVF        _direction+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _direction+0, 7 
	MOVLW       255
	MOVWF       R1 
L_main18:
	MOVF        R0, 0 
	MOVWF       _direction+0 
;211105_Commande_MPPT_v2.c,170 :: 		D = D + direction*DELTA_D;
	MOVLW       0
	BTFSC       R0, 7 
	MOVLW       255
	MOVWF       R1 
	MOVF        R0, 0 
	ADDWF       _D+0, 0 
	MOVWF       R2 
	MOVF        R1, 0 
	ADDWFC      _D+1, 0 
	MOVWF       R3 
	MOVF        R2, 0 
	MOVWF       _D+0 
	MOVF        R3, 0 
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,172 :: 		if (D == MIN_PWM) {
	MOVLW       0
	XORWF       R3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main80
	MOVLW       25
	XORWF       R2, 0 
L__main80:
	BTFSS       STATUS+0, 2 
	GOTO        L_main19
;211105_Commande_MPPT_v2.c,173 :: 		D = MAX_PWM - 5;   // a bit far away
	MOVLW       225
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,174 :: 		}else if (D == MAX_PWM) {
	GOTO        L_main20
L_main19:
	MOVLW       0
	XORWF       _D+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main81
	MOVLW       230
	XORWF       _D+0, 0 
L__main81:
	BTFSS       STATUS+0, 2 
	GOTO        L_main21
;211105_Commande_MPPT_v2.c,175 :: 		D = MIN_PWM + 5;
	MOVLW       30
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,176 :: 		}
L_main21:
L_main20:
;211105_Commande_MPPT_v2.c,178 :: 		break;
	GOTO        L_main13
;211105_Commande_MPPT_v2.c,179 :: 		case FAST_GMPPT: /******************************************/   /* THIS SECTION IS STILL OPTIMIZABLE */
L_main22:
;211105_Commande_MPPT_v2.c,186 :: 		if (sweep_iteration == 0 && (voltage_in < 350 || voltage_in > 370) ) {
	MOVF        _sweep_iteration+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main27
	MOVLW       1
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main82
	MOVLW       94
	SUBWF       _voltage_in+0, 0 
L__main82:
	BTFSS       STATUS+0, 0 
	GOTO        L__main75
	MOVF        _voltage_in+1, 0 
	SUBLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L__main83
	MOVF        _voltage_in+0, 0 
	SUBLW       114
L__main83:
	BTFSS       STATUS+0, 0 
	GOTO        L__main75
	GOTO        L_main27
L__main75:
L__main74:
;211105_Commande_MPPT_v2.c,187 :: 		PORTB &= ~BIT0; // clear LED0
	BCF         PORTB+0, 0 
;211105_Commande_MPPT_v2.c,188 :: 		PORTB |= BIT1; // turn on LED1
	BSF         PORTB+0, 1 
;211105_Commande_MPPT_v2.c,189 :: 		if (voltage_in < 360) {
	MOVLW       1
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main84
	MOVLW       104
	SUBWF       _voltage_in+0, 0 
L__main84:
	BTFSC       STATUS+0, 0 
	GOTO        L_main28
;211105_Commande_MPPT_v2.c,190 :: 		D = D - ((360 - voltage_in)>>3);
	MOVF        _voltage_in+0, 0 
	SUBLW       104
	MOVWF       R3 
	MOVF        _voltage_in+1, 0 
	MOVWF       R4 
	MOVLW       1
	SUBFWB      R4, 1 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	MOVF        R0, 0 
	SUBWF       _D+0, 1 
	MOVF        R1, 0 
	SUBWFB      _D+1, 1 
;211105_Commande_MPPT_v2.c,191 :: 		}else {
	GOTO        L_main29
L_main28:
;211105_Commande_MPPT_v2.c,192 :: 		D = D + ((voltage_in - 360)>>3);
	MOVLW       104
	SUBWF       _voltage_in+0, 0 
	MOVWF       R3 
	MOVLW       1
	SUBWFB      _voltage_in+1, 0 
	MOVWF       R4 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	MOVF        R0, 0 
	ADDWF       _D+0, 1 
	MOVF        R1, 0 
	ADDWFC      _D+1, 1 
;211105_Commande_MPPT_v2.c,193 :: 		}
L_main29:
;211105_Commande_MPPT_v2.c,194 :: 		}else if (sweep_iteration == 0 && voltage_in >= 350 && voltage_in <= 370) {
	GOTO        L_main30
L_main27:
	MOVF        _sweep_iteration+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main33
	MOVLW       1
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main85
	MOVLW       94
	SUBWF       _voltage_in+0, 0 
L__main85:
	BTFSS       STATUS+0, 0 
	GOTO        L_main33
	MOVF        _voltage_in+1, 0 
	SUBLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L__main86
	MOVF        _voltage_in+0, 0 
	SUBLW       114
L__main86:
	BTFSS       STATUS+0, 0 
	GOTO        L_main33
L__main73:
;211105_Commande_MPPT_v2.c,195 :: 		sweep_duty_cycle[0] = D;                    // save the current duty cycle that has the correct voltage
	MOVF        _D+0, 0 
	MOVWF       _sweep_duty_cycle+0 
	MOVF        _D+1, 0 
	MOVWF       _sweep_duty_cycle+1 
;211105_Commande_MPPT_v2.c,196 :: 		sweep_power[0] = measured_power;     // log the power as measured
	MOVF        _measured_power+0, 0 
	MOVWF       _sweep_power+0 
	MOVF        _measured_power+1, 0 
	MOVWF       _sweep_power+1 
	MOVF        _measured_power+2, 0 
	MOVWF       _sweep_power+2 
	MOVF        _measured_power+3, 0 
	MOVWF       _sweep_power+3 
;211105_Commande_MPPT_v2.c,197 :: 		sweep_iteration = 1;                        // go to the next iteration
	MOVLW       1
	MOVWF       _sweep_iteration+0 
;211105_Commande_MPPT_v2.c,198 :: 		D = sweep_duty_cycle[1];                     // give the next duty cyce to find as well
	MOVF        _sweep_duty_cycle+2, 0 
	MOVWF       _D+0 
	MOVF        _sweep_duty_cycle+3, 0 
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,199 :: 		}else if (sweep_iteration == 1 && (voltage_in < 600 || voltage_in > 640)) {
	GOTO        L_main34
L_main33:
	MOVF        _sweep_iteration+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main39
	MOVLW       2
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main87
	MOVLW       88
	SUBWF       _voltage_in+0, 0 
L__main87:
	BTFSS       STATUS+0, 0 
	GOTO        L__main72
	MOVF        _voltage_in+1, 0 
	SUBLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L__main88
	MOVF        _voltage_in+0, 0 
	SUBLW       128
L__main88:
	BTFSS       STATUS+0, 0 
	GOTO        L__main72
	GOTO        L_main39
L__main72:
L__main71:
;211105_Commande_MPPT_v2.c,200 :: 		PORTB &= ~BIT1; // clear LED1
	BCF         PORTB+0, 1 
;211105_Commande_MPPT_v2.c,201 :: 		PORTB |= BIT0; // turn on LED0
	BSF         PORTB+0, 0 
;211105_Commande_MPPT_v2.c,202 :: 		if (voltage_in < 620) {
	MOVLW       2
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main89
	MOVLW       108
	SUBWF       _voltage_in+0, 0 
L__main89:
	BTFSC       STATUS+0, 0 
	GOTO        L_main40
;211105_Commande_MPPT_v2.c,203 :: 		D = D - ((620 - voltage_in)>>4);
	MOVF        _voltage_in+0, 0 
	SUBLW       108
	MOVWF       R3 
	MOVF        _voltage_in+1, 0 
	MOVWF       R4 
	MOVLW       2
	SUBFWB      R4, 1 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	MOVF        R0, 0 
	SUBWF       _D+0, 1 
	MOVF        R1, 0 
	SUBWFB      _D+1, 1 
;211105_Commande_MPPT_v2.c,204 :: 		}else {
	GOTO        L_main41
L_main40:
;211105_Commande_MPPT_v2.c,205 :: 		D = D + ((voltage_in - 620)>>4);
	MOVLW       108
	SUBWF       _voltage_in+0, 0 
	MOVWF       R3 
	MOVLW       2
	SUBWFB      _voltage_in+1, 0 
	MOVWF       R4 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	MOVF        R0, 0 
	ADDWF       _D+0, 1 
	MOVF        R1, 0 
	ADDWFC      _D+1, 1 
;211105_Commande_MPPT_v2.c,206 :: 		}
L_main41:
;211105_Commande_MPPT_v2.c,207 :: 		}else if (sweep_iteration == 1 && voltage_in >= 600 && voltage_in <= 640) {
	GOTO        L_main42
L_main39:
	MOVF        _sweep_iteration+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main45
	MOVLW       2
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main90
	MOVLW       88
	SUBWF       _voltage_in+0, 0 
L__main90:
	BTFSS       STATUS+0, 0 
	GOTO        L_main45
	MOVF        _voltage_in+1, 0 
	SUBLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L__main91
	MOVF        _voltage_in+0, 0 
	SUBLW       128
L__main91:
	BTFSS       STATUS+0, 0 
	GOTO        L_main45
L__main70:
;211105_Commande_MPPT_v2.c,208 :: 		sweep_duty_cycle[1] = D;                    // save the current duty cycle that has the correct voltage
	MOVF        _D+0, 0 
	MOVWF       _sweep_duty_cycle+2 
	MOVF        _D+1, 0 
	MOVWF       _sweep_duty_cycle+3 
;211105_Commande_MPPT_v2.c,209 :: 		sweep_power[1] = measured_power;     // log the power as measured
	MOVF        _measured_power+0, 0 
	MOVWF       _sweep_power+4 
	MOVF        _measured_power+1, 0 
	MOVWF       _sweep_power+5 
	MOVF        _measured_power+2, 0 
	MOVWF       _sweep_power+6 
	MOVF        _measured_power+3, 0 
	MOVWF       _sweep_power+7 
;211105_Commande_MPPT_v2.c,210 :: 		sweep_iteration = 2;                        // go to the next iteration
	MOVLW       2
	MOVWF       _sweep_iteration+0 
;211105_Commande_MPPT_v2.c,211 :: 		D = sweep_duty_cycle[2];                     // give the next duty cyce to find as well
	MOVF        _sweep_duty_cycle+4, 0 
	MOVWF       _D+0 
	MOVF        _sweep_duty_cycle+5, 0 
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,212 :: 		}else if (sweep_iteration == 2 && (voltage_in < 835 || voltage_in > 905)) {
	GOTO        L_main46
L_main45:
	MOVF        _sweep_iteration+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_main51
	MOVLW       3
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main92
	MOVLW       67
	SUBWF       _voltage_in+0, 0 
L__main92:
	BTFSS       STATUS+0, 0 
	GOTO        L__main69
	MOVF        _voltage_in+1, 0 
	SUBLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L__main93
	MOVF        _voltage_in+0, 0 
	SUBLW       137
L__main93:
	BTFSS       STATUS+0, 0 
	GOTO        L__main69
	GOTO        L_main51
L__main69:
L__main68:
;211105_Commande_MPPT_v2.c,213 :: 		PORTB |= (BIT1 + BIT2);   // turn on both LEDs
	MOVLW       6
	IORWF       PORTB+0, 1 
;211105_Commande_MPPT_v2.c,215 :: 		if (voltage_in < 870) {
	MOVLW       3
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main94
	MOVLW       102
	SUBWF       _voltage_in+0, 0 
L__main94:
	BTFSC       STATUS+0, 0 
	GOTO        L_main52
;211105_Commande_MPPT_v2.c,216 :: 		D = D - ((870 - voltage_in)>>5);
	MOVF        _voltage_in+0, 0 
	SUBLW       102
	MOVWF       R3 
	MOVF        _voltage_in+1, 0 
	MOVWF       R4 
	MOVLW       3
	SUBFWB      R4, 1 
	MOVLW       5
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main95:
	BZ          L__main96
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	ADDLW       255
	GOTO        L__main95
L__main96:
	MOVF        R0, 0 
	SUBWF       _D+0, 1 
	MOVF        R1, 0 
	SUBWFB      _D+1, 1 
;211105_Commande_MPPT_v2.c,217 :: 		}else {
	GOTO        L_main53
L_main52:
;211105_Commande_MPPT_v2.c,218 :: 		D = D + ((voltage_in - 870)>>5);
	MOVLW       102
	SUBWF       _voltage_in+0, 0 
	MOVWF       R3 
	MOVLW       3
	SUBWFB      _voltage_in+1, 0 
	MOVWF       R4 
	MOVLW       5
	MOVWF       R2 
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main97:
	BZ          L__main98
	RRCF        R1, 1 
	RRCF        R0, 1 
	BCF         R1, 7 
	ADDLW       255
	GOTO        L__main97
L__main98:
	MOVF        R0, 0 
	ADDWF       _D+0, 1 
	MOVF        R1, 0 
	ADDWFC      _D+1, 1 
;211105_Commande_MPPT_v2.c,219 :: 		}
L_main53:
;211105_Commande_MPPT_v2.c,220 :: 		}else if (sweep_iteration == 2 && voltage_in >= 835 && voltage_in <= 905) {
	GOTO        L_main54
L_main51:
	MOVF        _sweep_iteration+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_main57
	MOVLW       3
	SUBWF       _voltage_in+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main99
	MOVLW       67
	SUBWF       _voltage_in+0, 0 
L__main99:
	BTFSS       STATUS+0, 0 
	GOTO        L_main57
	MOVF        _voltage_in+1, 0 
	SUBLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L__main100
	MOVF        _voltage_in+0, 0 
	SUBLW       137
L__main100:
	BTFSS       STATUS+0, 0 
	GOTO        L_main57
L__main67:
;211105_Commande_MPPT_v2.c,221 :: 		sweep_duty_cycle[2] = D;                    // save the current duty cycle that has the correct voltage
	MOVF        _D+0, 0 
	MOVWF       _sweep_duty_cycle+4 
	MOVF        _D+1, 0 
	MOVWF       _sweep_duty_cycle+5 
;211105_Commande_MPPT_v2.c,222 :: 		sweep_power[2] = measured_power;     // log the power as measured
	MOVF        _measured_power+0, 0 
	MOVWF       _sweep_power+8 
	MOVF        _measured_power+1, 0 
	MOVWF       _sweep_power+9 
	MOVF        _measured_power+2, 0 
	MOVWF       _sweep_power+10 
	MOVF        _measured_power+3, 0 
	MOVWF       _sweep_power+11 
;211105_Commande_MPPT_v2.c,223 :: 		sweep_iteration = 3;                        // reset sweep iteration but we jump state anyway so no prob here
	MOVLW       3
	MOVWF       _sweep_iteration+0 
;211105_Commande_MPPT_v2.c,226 :: 		max_power = 0;
	CLRF        _max_power+0 
	CLRF        _max_power+1 
	CLRF        _max_power+2 
	CLRF        _max_power+3 
;211105_Commande_MPPT_v2.c,227 :: 		for (main_counter = 0; main_counter<3; ++main_counter) {
	CLRF        _main_counter+0 
L_main58:
	MOVLW       3
	SUBWF       _main_counter+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main59
;211105_Commande_MPPT_v2.c,229 :: 		if (sweep_power[main_counter] > max_power) {
	MOVF        _main_counter+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_power+0
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       hi_addr(_sweep_power+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVF        POSTINC0+0, 0 
	MOVWF       R3 
	MOVF        POSTINC0+0, 0 
	MOVWF       R4 
	MOVF        R4, 0 
	SUBWF       _max_power+3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main101
	MOVF        R3, 0 
	SUBWF       _max_power+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main101
	MOVF        R2, 0 
	SUBWF       _max_power+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main101
	MOVF        R1, 0 
	SUBWF       _max_power+0, 0 
L__main101:
	BTFSC       STATUS+0, 0 
	GOTO        L_main61
;211105_Commande_MPPT_v2.c,230 :: 		max_power = sweep_power[main_counter];
	MOVF        _main_counter+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_power+0
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       hi_addr(_sweep_power+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _max_power+0 
	MOVF        POSTINC0+0, 0 
	MOVWF       _max_power+1 
	MOVF        POSTINC0+0, 0 
	MOVWF       _max_power+2 
	MOVF        POSTINC0+0, 0 
	MOVWF       _max_power+3 
;211105_Commande_MPPT_v2.c,231 :: 		max_power_index = main_counter;
	MOVF        _main_counter+0, 0 
	MOVWF       _max_power_index+0 
;211105_Commande_MPPT_v2.c,232 :: 		}
L_main61:
;211105_Commande_MPPT_v2.c,227 :: 		for (main_counter = 0; main_counter<3; ++main_counter) {
	INCF        _main_counter+0, 1 
;211105_Commande_MPPT_v2.c,233 :: 		}
	GOTO        L_main58
L_main59:
;211105_Commande_MPPT_v2.c,235 :: 		D = sweep_duty_cycle[max_power_index];
	MOVF        _max_power_index+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _sweep_duty_cycle+0
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       hi_addr(_sweep_duty_cycle+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _D+0 
	MOVF        POSTINC0+0, 0 
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,237 :: 		sweep_iteration = 3;
	MOVLW       3
	MOVWF       _sweep_iteration+0 
;211105_Commande_MPPT_v2.c,238 :: 		}else if (sweep_iteration == 3) {
	GOTO        L_main62
L_main57:
	MOVF        _sweep_iteration+0, 0 
	XORLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L_main63
;211105_Commande_MPPT_v2.c,240 :: 		mode = MPPT_PO;
	CLRF        _mode+0 
;211105_Commande_MPPT_v2.c,241 :: 		sweep_iteration = 0;
	CLRF        _sweep_iteration+0 
;211105_Commande_MPPT_v2.c,242 :: 		}
L_main63:
L_main62:
L_main54:
L_main46:
L_main42:
L_main34:
L_main30:
;211105_Commande_MPPT_v2.c,243 :: 		break;
	GOTO        L_main13
;211105_Commande_MPPT_v2.c,244 :: 		}
L_main12:
	MOVF        _mode+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_main14
	MOVF        _mode+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_main22
L_main13:
;211105_Commande_MPPT_v2.c,248 :: 		last_voltage_in = voltage_in;
	MOVF        _voltage_in+0, 0 
	MOVWF       _last_voltage_in+0 
	MOVF        _voltage_in+1, 0 
	MOVWF       _last_voltage_in+1 
;211105_Commande_MPPT_v2.c,249 :: 		last_measured_power = measured_power;
	MOVF        _measured_power+0, 0 
	MOVWF       _last_measured_power+0 
	MOVF        _measured_power+1, 0 
	MOVWF       _last_measured_power+1 
	MOVF        _measured_power+2, 0 
	MOVWF       _last_measured_power+2 
	MOVF        _measured_power+3, 0 
	MOVWF       _last_measured_power+3 
;211105_Commande_MPPT_v2.c,253 :: 		if (D > MAX_PWM) {
	MOVLW       0
	MOVWF       R0 
	MOVF        _D+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main102
	MOVF        _D+0, 0 
	SUBLW       230
L__main102:
	BTFSC       STATUS+0, 0 
	GOTO        L_main64
;211105_Commande_MPPT_v2.c,254 :: 		D = MAX_PWM;
	MOVLW       230
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,255 :: 		}else if (D < MIN_PWM) {
	GOTO        L_main65
L_main64:
	MOVLW       0
	SUBWF       _D+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main103
	MOVLW       25
	SUBWF       _D+0, 0 
L__main103:
	BTFSC       STATUS+0, 0 
	GOTO        L_main66
;211105_Commande_MPPT_v2.c,256 :: 		D = MIN_PWM;
	MOVLW       25
	MOVWF       _D+0 
	MOVLW       0
	MOVWF       _D+1 
;211105_Commande_MPPT_v2.c,257 :: 		}
L_main66:
L_main65:
;211105_Commande_MPPT_v2.c,258 :: 		PWM1_Set_Duty(D);                   // send duty cycle
	MOVF        _D+0, 0 
	MOVWF       FARG_PWM1_Set_Duty_new_duty+0 
	CALL        _PWM1_Set_Duty+0, 0
;211105_Commande_MPPT_v2.c,260 :: 		T0CON |= BIT7;    // enable timer here
	BSF         T0CON+0, 7 
;211105_Commande_MPPT_v2.c,262 :: 		settled = 0;
	CLRF        _settled+0 
;211105_Commande_MPPT_v2.c,263 :: 		}
L_main2:
;211105_Commande_MPPT_v2.c,264 :: 		asm clrwdt;
	CLRWDT
;211105_Commande_MPPT_v2.c,265 :: 		};
	GOTO        L_main0
;211105_Commande_MPPT_v2.c,266 :: 		}
	GOTO        $+0
; end of _main

_interrupt:

;211105_Commande_MPPT_v2.c,270 :: 		void interrupt() {
;211105_Commande_MPPT_v2.c,273 :: 		INTCON &= ~BIT2;
	BCF         INTCON+0, 2 
;211105_Commande_MPPT_v2.c,275 :: 		T0CON &= ~BIT7;
	MOVLW       127
	ANDWF       T0CON+0, 1 
;211105_Commande_MPPT_v2.c,277 :: 		settled = 1;            // indicate that a measurement is done
	MOVLW       1
	MOVWF       _settled+0 
;211105_Commande_MPPT_v2.c,278 :: 		}
L__interrupt104:
	RETFIE      1
; end of _interrupt

_init:

;211105_Commande_MPPT_v2.c,281 :: 		void init() {
;211105_Commande_MPPT_v2.c,287 :: 		OSCCON = 0x72;
	MOVLW       114
	MOVWF       OSCCON+0 
;211105_Commande_MPPT_v2.c,296 :: 		T0CON  = 0xC4;
	MOVLW       196
	MOVWF       T0CON+0 
;211105_Commande_MPPT_v2.c,300 :: 		TRISA = 0xFF;
	MOVLW       255
	MOVWF       TRISA+0 
;211105_Commande_MPPT_v2.c,301 :: 		PORTA = PORTA | 0x07;
	MOVLW       7
	IORWF       PORTA+0, 1 
;211105_Commande_MPPT_v2.c,305 :: 		TRISB = TRISB & 0b11111000; // RB0, RB1 and RB2 as OUTPUT
	MOVLW       248
	ANDWF       TRISB+0, 1 
;211105_Commande_MPPT_v2.c,306 :: 		PORTB = PORTB & 0b11111000; // tie them down to 0
	MOVLW       248
	ANDWF       PORTB+0, 1 
;211105_Commande_MPPT_v2.c,309 :: 		INTCON = (BIT7 + BIT5);
	MOVLW       160
	MOVWF       INTCON+0 
;211105_Commande_MPPT_v2.c,316 :: 		PWM1_Init(10000);         // set PWM to 10kHz, but the REAL PWM is 100kHz
	BCF         T2CON+0, 0, 0
	BCF         T2CON+0, 1, 0
	MOVLW       199
	MOVWF       PR2+0, 0
	CALL        _PWM1_Init+0, 0
;211105_Commande_MPPT_v2.c,317 :: 		PWM1_Start();             // start PWM
	CALL        _PWM1_Start+0, 0
;211105_Commande_MPPT_v2.c,319 :: 		}
	RETURN      0
; end of _init
