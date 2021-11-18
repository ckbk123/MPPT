#line 1 "C:/Users/baokh/ownCloud/Partie algo/211105_Commande_MPPT_v2/211105_Commande_MPPT_v2.c"
#line 61 "C:/Users/baokh/ownCloud/Partie algo/211105_Commande_MPPT_v2/211105_Commande_MPPT_v2.c"
 unsigned int  voltage_in = 0;
 unsigned int  current_in = 0;
 unsigned int  voltage_out = 0;



 unsigned long int  measured_power = 0;


 unsigned int  last_voltage_in = 0;
 unsigned int  last_current_in = 0;
 unsigned int  last_voltage_out = 0;



 unsigned long int  last_measured_power = 0;


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
 unsigned int  sweep_duty_cycle[3] = {100, 100, 100};
 unsigned long int  sweep_power[3] = {0, 0, 0};
 unsigned long int  max_power = 0;
 unsigned char  max_power_index = 0;


void init();

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


 for (counter = 0; counter < 4; ++counter) {
 voltage_out += ADC_Read(2);
 }

 voltage_out >>= 2;


 measured_power = ( unsigned long int )voltage_in * ( unsigned long int )current_in;


 delta_power = ( signed long int )measured_power - ( signed long int )last_measured_power;
 delta_voltage = ( signed int )voltage_in - ( signed int )last_voltage_in;

 switch(mode) {
 case  0 :

 PORTB &= ~ 0x02 ;
 PORTB |=  0x01 ;


 direction = (delta_power < 0) ? -direction : direction;
#line 181 "C:/Users/baokh/ownCloud/Partie algo/211105_Commande_MPPT_v2/211105_Commande_MPPT_v2.c"
 D = D + direction* 1 ;

 if (D ==  25 ) {
 D =  230  - 5;
 }else if (D ==  230 ) {
 D =  25  + 5;
 }

 break;
 case  1 :






 if (sweep_iteration == 0 && (voltage_in < 350 || voltage_in > 370) ) {
 PORTB &= ~ 0x01 ;
 PORTB |=  0x02 ;
 if (voltage_in < 360) {
 D = D - ((360 - voltage_in)>>3);
 }else {
 D = D + ((voltage_in - 360)>>3);
 }
 }else if (sweep_iteration == 0 && voltage_in >= 350 && voltage_in <= 370) {
 sweep_duty_cycle[0] = D;
 sweep_power[0] = voltage_in*current_in;
 sweep_iteration = 1;
 D = sweep_duty_cycle[1];
 }else if (sweep_iteration == 1 && (voltage_in < 600 || voltage_in > 640)) {
 PORTB &= ~ 0x02 ;
 PORTB |=  0x01 ;
 if (voltage_in < 620) {
 D = D - ((620 - voltage_in)>>4);
 }else {
 D = D + ((voltage_in - 620)>>4);
 }
 }else if (sweep_iteration == 1 && voltage_in >= 600 && voltage_in <= 640) {
 sweep_duty_cycle[1] = D;
 sweep_power[1] = voltage_in*current_in;
 sweep_iteration = 2;
 D = sweep_duty_cycle[2];
 }else if (sweep_iteration == 2 && (voltage_in < 835 || voltage_in > 905)) {
 PORTB |= ( 0x02  +  0x04 );

 if (voltage_in < 870) {
 D = D - ((870 - voltage_in)>>5);
 }else {
 D = D + ((voltage_in - 870)>>5);
 }
 }else if (sweep_iteration == 2 && voltage_in >= 835 && voltage_in <= 905) {
 sweep_duty_cycle[2] = D;
 sweep_power[2] = voltage_in*current_in;
 sweep_iteration = 3;


 max_power = 0;
 for (main_counter = 0; main_counter<3; ++main_counter) {

 if (sweep_power[main_counter] > max_power) {
 max_power = sweep_power[main_counter];
 max_power_index = main_counter;
 }
 }

 D = sweep_duty_cycle[max_power_index];

 sweep_iteration = 0;

 mode =  0 ;
 }
 break;
 }



 last_voltage_in = voltage_in;
 last_measured_power = measured_power;



 if (D >  230 ) {
 D =  230 ;
 }else if (D <  25 ) {
 D =  25 ;
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
