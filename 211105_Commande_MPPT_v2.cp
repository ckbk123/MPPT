#line 1 "C:/Users/baokh/ownCloud/Partie algo/211105_Commande_MPPT_v2/211105_Commande_MPPT_v2.c"
#line 68 "C:/Users/baokh/ownCloud/Partie algo/211105_Commande_MPPT_v2/211105_Commande_MPPT_v2.c"
 signed int  voltage_in = 0;
 signed int  current_in = 0;
 signed int  voltage_out = 0;



 signed long int  measured_power = 0;


 signed int  last_voltage_in = 0;
 signed int  last_current_in = 0;
 signed int  last_voltage_out = 0;



 signed long int  last_measured_power = 0;
 signed long int  last_delta_power = 0;

 signed int  delta_voltage = 0;
 signed long int  delta_power = 0;



 unsigned char  settled = 0;


 unsigned int  D = 230;


 signed char  direction = 1;
 unsigned long int  dynamic_hyst = 0;



 unsigned char  counter = 0;

 unsigned char  main_counter = 0;


 unsigned char  mode =  0 ;







 unsigned char  sweep_iteration = 0;
 unsigned int  sweep_duty_cycle[3] = {0, 0, 0};
 unsigned long int  sweep_power[3] = {0, 0, 0};
 unsigned int  sweep_lower_bounds[3] = {350, 600, 835};
 unsigned int  sweep_upper_bounds[3] = {370, 640, 905};
 unsigned int  sweep_target[3] = {360, 620, 870};
 unsigned long int  max_power = 0;
 unsigned char  max_power_index = 0;

 unsigned long int  P_max_fast_gmppt = 0;
 unsigned char  D_max_fast_gmppt = 0;

 unsigned long int  P_max_adaptive = 0;
 unsigned char  D_max_adaptive = 0;
 unsigned char  D_step = 0;
 unsigned char  speed_coeff = 0;

 unsigned char  oscillation_detect = 0;

void init();

void main() {

 init();

 while(1) {

 if (settled) {


 for (counter = 0; counter < 4; ++counter) {
 voltage_in += ADC_Read(0);
 voltage_out += ADC_Read(2);
 }

 voltage_in >>= 2;
 voltage_out >>= 2;


 for (counter = 0; counter < 8; ++counter) {
 current_in += ADC_Read(1);
 }

 current_in >>= 3;


 voltage_out >>= 2;


 measured_power = ( signed long int )voltage_in * ( signed long int )current_in;

 switch(mode) {
 case  1 :






 if (sweep_iteration < 3 && (voltage_in < sweep_lower_bounds[sweep_iteration] || voltage_in > sweep_upper_bounds[sweep_iteration]) ) {
 if (voltage_in < sweep_target[sweep_iteration]) {
 D = D - ( (sweep_target[sweep_iteration] - voltage_in)>>(3+sweep_iteration) );
 }else {
 D = D + ( (voltage_in - sweep_target[sweep_iteration])>>(3+sweep_iteration) );
 }
 }else if (sweep_iteration < 3 && voltage_in >= sweep_lower_bounds[sweep_iteration] && voltage_in <= sweep_upper_bounds[sweep_iteration]) {
 sweep_duty_cycle[sweep_iteration] = D;
 sweep_power[sweep_iteration] = measured_power;
 ++sweep_iteration;
 if (sweep_iteration < 3) {
 D = sweep_duty_cycle[sweep_iteration];

 }else {

 max_power = 0;
 for (counter = 0; counter < 3; ++counter) {
 if (sweep_power[counter] > max_power) {
 max_power = sweep_power[counter];
 D = sweep_duty_cycle[counter];
 }
 }


 last_voltage_in = 0;
 last_current_in = 0;
 last_voltage_out = 0;
 last_measured_power = 0;
 last_delta_power = 0;

 speed_coeff = 4;

 P_max_adaptive = 0;
 D_max_adaptive = 0;
 }
 }
 break;
 case  0 :

 delta_power = measured_power - last_measured_power;
 delta_voltage = voltage_in - last_voltage_in;

 if (measured_power > P_max_adaptive) {
 D_max_adaptive = D;
 P_max_adaptive = measured_power;
 }





 if (voltage_in >= 680) {
 D_step = speed_coeff;
 }else if (voltage_in >= 470) {
 D_step = speed_coeff>>1;
 }else {
 D_step = speed_coeff>>4;
 }


 if (last_measured_power) {
 if ( (delta_power >= 0 && delta_voltage >= 0) || (delta_power <= 0 && delta_voltage <= 0) ) {
 D -= D_step;
 }else {
 D += D_step;
 }
 if (oscillation_detect <  4 ) {
 if (last_delta_power > 0 && delta_power < 0 || last_delta_power < 0 && delta_power > 0) {
 ++oscillation_detect;
 }else {
 oscillation_detect = 0;
 }
 }
 if (oscillation_detect ==  4  && speed_coeff > 0) {
 speed_coeff >>= 1;
 oscillation_detect = 0;
 }
 if (speed_coeff == 0) {
 mode =  2 ;
 oscillation_detect = 0;
 D = D_max_adaptive;
 }
 }

 last_delta_power = delta_power;
 break;
 case  2 :


 if ((measured_power - P_max_adaptive) > 6000 || (measured_power - P_max_adaptive) > 6000) {
 mode =  1 ;
 P_max_adaptive = 0;
 }
 break;
 }



 last_voltage_in = voltage_in;
 last_measured_power = measured_power;




 if (D >  230 ) {
 D =  230 ;
 }else if (D <  32 ) {
 D =  32 ;
 }
 PWM1_Set_Duty(D);

 T0CON |=  0x80 ;

 settled = 0;
 }
 asm clrwdt;
 };
}



void interrupt() {


 INTCON &= ~ 0x04 ;

 T0CON &= ~ 0x80 ;

 settled = 1;
}


void init() {





 OSCCON = 0x72;








 T0CON = 0xC4;



 TRISA = 0xFF;
 PORTA = PORTA | 0x07;



 TRISB = TRISB & 0b11111000;
 PORTB = PORTB & 0b11111000;


 INTCON = ( 0x80  +  0x20 );






 PWM1_Init(10000);
 PWM1_Start();

}
