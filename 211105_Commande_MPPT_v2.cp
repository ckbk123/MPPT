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


 unsigned char  mode =  2 ;







 signed char  sweep_iteration = 0;
 unsigned char  sweep_duty_cycle[3] = {0, 0, 0};

 signed long int  P_max_fast_gmppt = 0;
 unsigned char  D_max_fast_gmppt = 0;

 signed int  sweep_lower_bounds[3] = {350, 600, 835};
 signed int  sweep_upper_bounds[3] = {370, 640, 950};
 signed int  sweep_target[3] = {360, 620, 870};
 signed long int  max_power = 0;
 unsigned char  max_power_index = 0;

 signed long int  P_max_adaptive = 0;
 unsigned char  D_max_adaptive = 0;
 unsigned char  D_step = 0;
 unsigned char  speed_coeff = 0;

 unsigned char  oscillation_detect = 0;

void init();

void LED0_ON();
void LED0_OFF();
void LED1_ON();
void LED1_OFF();

void main() {

 init();

 while(1) {


 if (settled) {


 for (counter = 0; counter < 4; ++counter) {
 voltage_in += ADC_Read(0);

 }

 voltage_in >>= 2;



 for (counter = 0; counter < 8; ++counter) {
 current_in += ADC_Read(1);
 }

 current_in >>= 3;


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

 if (measured_power > P_max_fast_gmppt) {
 D_max_fast_gmppt = measured_power;
 D_max_fast_gmppt = D;
 }

 ++sweep_iteration;

 if (sweep_iteration < 3) {
 if (sweep_duty_cycle[sweep_iteration]) D = sweep_duty_cycle[sweep_iteration];
 }else {
 sweep_iteration = 0;

 D = D_max_fast_gmppt;


 last_voltage_in = 0;
 last_current_in = 0;
 last_voltage_out = 0;
 last_measured_power = 0;
 last_delta_power = 0;


 speed_coeff = 4;

 P_max_adaptive = 0;
 D_max_adaptive = 0;



 mode =  0 ;
 }
 }
 LED0_ON();
 LED1_OFF();
 break;
 case  0 :
 LED1_ON();
 LED0_OFF();

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
 if ( (last_delta_power >= 0 && delta_power <= 0) || (last_delta_power <= 0 && delta_power >= 0) ) {
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
 last_voltage_in = voltage_in;
 last_measured_power = measured_power;
 break;
 case  2 :

 if ((measured_power - P_max_adaptive) > 1000 || (measured_power - P_max_adaptive) > 1000) {
 mode =  1 ;
 P_max_adaptive = 0;
 P_max_fast_gmppt = 0;
 D_max_fast_gmppt = 0;
 }
 break;
 }


 if (D >  240 ) {
 D =  240 ;
 }else if (D <  20 ) {
 D =  20 ;
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








 T0CON = 0xC6;



 TRISA = 0xFF;
 PORTA = PORTA | 0x07;



 TRISB = TRISB & 0b11111000;
 PORTB = PORTB & 0b11111000;


 INTCON = ( 0x80  +  0x20 );






 PWM1_Init(10000);
 PWM1_Start();

}
void LED0_ON() {
 PORTB |=  0x01 ;
}
void LED0_OFF() {
 PORTB &= ~ 0x01 ;
}
void LED1_ON() {
 PORTB |=  0x02 ;
}
void LED1_OFF() {
 PORTB &= ~ 0x02 ;
}
