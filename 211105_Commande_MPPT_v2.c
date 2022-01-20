/**************************** CRITICAL WARNING ********************************/
// This code aint for actual deployment => test it with a battery emulator only
// otherwise it will charge and fry whatever supercap/batt u plug at the buck output

/*********************** A UTILISE SUR CARTE V3.2 *****************************/
/******           Mesure tension PV : tension_PV = 68.3*Vpv - 10.3    *********/
/******           Mesure courant PV : courant_PV = 805.7*Ipv - 38.2   *********/
/******           Mesure tension SC : tension_SC = 111*Vsc -0.28      *********/
/******************************************************************************/

#define BIT0         0x01
#define BIT1         0x02
#define BIT2         0x04
#define BIT3         0x08
#define BIT4         0x10
#define BIT5         0x20
#define BIT6         0x40
#define BIT7         0x80

// define some clear type of variable
#define UINT8        unsigned char
#define UINT16       unsigned int
#define UINT32       unsigned long int

#define INT8         signed char
#define INT16        signed int
#define INT32        signed long int

// quite a drastic MIN_PWM change: this is becuz we are supposing working with Lì-ion / LFP batteries
// which cannot be below 2V anyway and the max voltage we can reach is around 14V at best
// so we may never exceed the x8 gain => therefore D of 1/8 or below is useless
#define MIN_PWM      32                                  // set the mininum duty cycle possible. 5% is decent => around 25/255
#define MAX_PWM      230                                 // set the maximum duty cycle possible. 95% is decent => around 230/255

// here's 2 modes of operation that we wanna test: the fast GMPPT and P&O
#define MPPT_PO      0                 // basic P&O
#define FAST_GMPPT   1                 // turning GMPPT

// some definition necessary for P&O part
#define CURRENT_HYSTERESIS 1           // since current measurement is a bit noisy to need a small hystereris to ensure that we are not deciding too early
#define DELTA_D            1           // we would like to have a fine duty cycle change

// some security measures to make sure that we dont fry the output cap
#define MAX_VOLTAGE_OUT    550

// some definition necessary for Fast GMPP part
// this is designed for a case where 4 bypass diodes, with 3 accessible peak zones (becuz 1 is at 2.2V, not accessible using a buck for an output of 4.2V)
// so we need to tap into only 3 voltage values

//CARTE V3.2////////////////////////////////////////////
//Mesure tension PV : tension_PV = 68.3*Vpv - 10.3
//Mesure courant PV : courant_PV = 805.7*Ipv - 38.2
//Mesure tension SC : tension_SC = 111*Vsc -0.28
/////////////////////////////////////////////////////////

/******************************************************************************/
/************ INIT FUNCTION TO START TIMERS, ISRs, GPIOS, ETC *****************/
/******************************************************************************/

// datasheet link: https://ww1.microchip.com/downloads/en/DeviceDoc/30009605G.pdf

/****************************** SENSOR VARIABLES ******************************/
// measuring variables: voltage and current as measured at converter input and output
UINT16 voltage_in = 0;
UINT16 current_in = 0;
UINT16 voltage_out = 0;
// UINT16 current_out;         //THIS LINE JUST ANTICIPATE CURRENT OUTPUT MEASUREMENT

// the measured power. This version uses the input power but it would be better to use output power
UINT32 measured_power = 0;

// last measured variable: same as right above but measured during last cycle
UINT16 last_voltage_in = 0;
UINT16 last_current_in = 0;
UINT16 last_voltage_out = 0;
// UINT16 last_current_out;    //THIS LINE JUST ANTICIPATE CURRENT OUTPUT MEASUREMENT

// last measured power.
UINT32 last_measured_power = 0;

// take the difference between old and new power/voltage
INT16 delta_voltage = 0;
INT32 delta_power = 0;

/******************************** CONTROL VARIABLE ********************************/
// indicator: whether a measurement is done or not
UINT8 settled = 0;

// duty cycle to be sent
UINT16 D = 230;

// variables for P&O control
INT8 direction = 1;               // by default the direction is increasing D => basically decreasing voltage
UINT32 dynamic_hyst = 0;           // this is the dynamic hystereris to make sure that P&O is moving the right direction
/****************************** FUNCTIONAL VARIABLES ******************************/
// a variable to iterate 'for' loop (INSIDE INTERRUPT)
// PLZ DONT MIX UP THESE 2 VARIABLES OR CODE WILL BREAK
UINT8 counter = 0;
// a variable to iterate 'for' loop (OUTSIDE INTERRUPT)
UINT8 main_counter = 0;

// set default mode to P&O
UINT8 mode = MPPT_PO;

// The 3 voltage values that we need to aim for is 5.4V, 9.2V and 12.8V, converted over to as value is
// Values for 3.2 version board: 5.4V => 358, 9.2V => 618, 12.8V => 864
// so we'll use the same margins as MATLAB sim: 350-370, 600-640, 835-905. These values are also consistent with the voltage formula for V3.2 board
// note that there is an alternate version that gives 5.4V, 8.9V and 12.4V (probably more precise becuz this sweep is done with extra diode carac)
// the margins are also important: for the first 1, the duty cycle is based on delta_voltage>>2 so if u change the margin
// it may not converge at all.
UINT8 sweep_iteration = 0;               // this is to track which PP are we investigating during the sweep
UINT16 sweep_duty_cycle[3] = {100, 100, 100};        // random guess because the == 0 comparison is only worth while at startup but take up code during subsequent passes
UINT32 sweep_power[3] = {0, 0, 0};                  // the log of power points
UINT32 max_power = 0;                          // register the max amount of power
UINT8 max_power_index = 0;                    // the index of max power in the array of 3

/******************************* FUNCTION PROTOTYPE *******************************/
void init();

void main() {
    // call init function to initialize the necessary peripherals
    init();

    while(1) {
        // only if a measurement is made that we start doing these things
        if (settled) {
            // we detect which mode we are in and start doing calculations and things
            /************* measuring input voltage (PV voltage) ************/
            for (counter = 0; counter < 4; ++counter) {
               voltage_in += ADC_Read(0);
            }
            // divide voltage_in by 4 to take the average
            voltage_in >>= 2;

            /************* measuring input current (PV current) ************/
            for (counter = 0; counter < 8; ++counter) {
                current_in += ADC_Read(1);
            }
            // then divide current_in by 16 to take the average. Current is kinda jittery so that's why we make more measurements
            current_in >>= 3;

            /********** measuring out voltage (converter voltage) **********/
            for (counter = 0; counter < 4; ++counter) {
                  voltage_out += ADC_Read(2);
            }
            // again taking the average of signal (by 4)
            voltage_out >>= 2;

            // calculate the power as measured
            measured_power = (UINT32)voltage_in * (UINT32)current_in;

            // calculate the power and voltage delta => necessary to make decisions
            delta_power = (INT32)measured_power - (INT32)last_measured_power;
            delta_voltage = (INT16)voltage_in - (INT16)last_voltage_in;

            switch(mode) {
                case FAST_GMPPT: /******************************************/   /* THIS SECTION IS STILL OPTIMIZABLE */
                     // light up LED 1 to indicate we are on fast GMPPT (this may not be very visible tho...)

                     // basically there are 3 voltage zone that we want to reach and measure the power obtained
                     // since the output voltage might sway a bit (for batteries its between 3.2V - 4.2V)
                     // we therefore need to regulate a bit to reach the voltage zone
                     // apply for 1st sweep
                     if (sweep_iteration == 0 && (voltage_in < 350 || voltage_in > 370) ) {
                          PORTB &= ~BIT0; // clear LED0
                          PORTB |= BIT1; // turn on LED1
                          if (voltage_in < 360) {
                                  D = D - ((360 - voltage_in)>>3);
                          }else {
                                  D = D + ((voltage_in - 360)>>3);
                          }        
                     }else if (sweep_iteration == 0 && voltage_in >= 350 && voltage_in <= 370) {
                          sweep_duty_cycle[0] = D;                    // save the current duty cycle that has the correct voltage
                          sweep_power[0] = measured_power;     // log the power as measured
                          sweep_iteration = 1;                        // go to the next iteration
                          D = sweep_duty_cycle[1];                     // give the next duty cyce to find as well
                     }else if (sweep_iteration == 1 && (voltage_in < 600 || voltage_in > 640)) {
                          PORTB &= ~BIT1; // clear LED1
                          PORTB |= BIT0; // turn on LED0
                          if (voltage_in < 620) {
                                  D = D - ((620 - voltage_in)>>4);
                          }else {
                                  D = D + ((voltage_in - 620)>>4);
                          }
                     }else if (sweep_iteration == 1 && voltage_in >= 600 && voltage_in <= 640) {
                          sweep_duty_cycle[1] = D;                    // save the current duty cycle that has the correct voltage
                          sweep_power[1] = measured_power;     // log the power as measured
                          sweep_iteration = 2;                        // go to the next iteration
                          D = sweep_duty_cycle[2];                     // give the next duty cyce to find as well
                     }else if (sweep_iteration == 2 && (voltage_in < 835 || voltage_in > 905)) {
                          PORTB |= (BIT1 + BIT2);   // turn on both LEDs
                          
                          if (voltage_in < 870) {
                                  D = D - ((870 - voltage_in)>>5);
                          }else {
                                  D = D + ((voltage_in - 870)>>5);
                          }
                     }else if (sweep_iteration == 2 && voltage_in >= 835 && voltage_in <= 905) {
                          sweep_duty_cycle[2] = D;                    // save the current duty cycle that has the correct voltage
                          sweep_power[2] = measured_power;     // log the power as measured
                          sweep_iteration = 3;                        // reset sweep iteration but we jump state anyway so no prob here

                          // now we need to determine which peak to choose from
                          max_power = 0;
                          for (main_counter = 0; main_counter<3; ++main_counter) {
                          // basically find the index of the largest element in sweep_power array and store this index in max_power_index;
                              if (sweep_power[main_counter] > max_power) {
                                 max_power = sweep_power[main_counter];
                                 max_power_index = main_counter;
                              }
                          }
                          // then we just send the duty cycle that allowed us to have max_power
                          D = sweep_duty_cycle[max_power_index];
                          // we need an extra cycle so that when going back to regular P&O it doesnt immediately jump back to this GMPPT
                          sweep_iteration = 3;
                     }else if (sweep_iteration == 3) {
                          // reset sweep iteration, with no duty cycle change becuz we are going back to P&O
                          mode = MPPT_PO;
                          sweep_iteration = 0;
                     }
                break;
                case MPPT_PO:    /******************************************/
                     // light up LED 0 to indicate we are on P&O MPPT
                     PORTB &= ~BIT1; // clear LED1
                     PORTB |= BIT0; //  set LED0

                     // first comparison: if the delta power is bigger than 6.25% of the last measured power point, we need to change over to GMPPT
                     if ( abs(delta_power) > (last_measured_power>>4) ) {
                         mode = FAST_GMPPT;
                         D = sweep_duty_cycle[0];                // make it change to the first guess immediately
                         break;                                  // and just bail...
                     }else {
                         // simple P&O. Invert direction only when delta_power is negative
                         direction = (delta_power < 0) ? -direction : direction;
                         // change the duty cycle.
                         // why is this thing outside? well for the Perturb part
                         // because if we don't change D, we aint getting the direction to move toward
                         D = D + direction*DELTA_D;
                         // but like if D reaches MAX_PWM or MIN_PWM, we need to move it away from there a bit
                         if (D == MIN_PWM) {
                               D = MAX_PWM - 5;   // a bit far away
                         }else if (D == MAX_PWM) {
                               D = MIN_PWM + 5;
                         }
                     }
                break;
                case STEADY_STATE:
                
                break;
            }   
            /**** STORE NEW VALUES TO OLD ****/
            // store the new values as old values.
            // all calculations will be determined using the delta values and current measured values
            last_voltage_in = voltage_in;
            last_measured_power = measured_power;
            
            // we need to send the duty cycle after all of these calculations
            // we do it here becuz the interrupt loop is better timed
            if (D > MAX_PWM) {
                  D = MAX_PWM;
            }else if (D < MIN_PWM) {
                  D = MIN_PWM;
            }
            PWM1_Set_Duty(D);                   // send duty cycle
            
            T0CON |= BIT7;    // enable timer here
            // just send duty cycle so now we need some time to settle the new duty cycle
            settled = 0;
        }
    asm clrwdt;
    };
}

// there is a single global interrupt that we kinda have to detect which one that triggers it
// since we have only 1 interrupt used, its most likely Timer0
void interrupt() {
    /***** CLEAR FLAG + RESET TIMER *****/
    // clear Timer0 overflow flag
    INTCON &= ~BIT2;
    // disable timer
    T0CON &= ~BIT7;

    settled = 1;            // indicate that a measurement is done
}

// init function: start up things...
void init() {

    // Set internal oscillator to 8MHz
    // PIC18F1320 datasheet pg17
    // SCS = 1x : RC mode => internal oscillator block
    // main osc to 8MHz
    OSCCON = 0x72;

    //  8-bit timer. Timer is not ON here
    // prescaler determined by 3 LSBs: 2^(n+1)
    // datasheet pg 99
    // Timer0 clock source is Fosc/4 so 2MHz
    // Timer0 is basically to wait for PWM to settle
    // WARNING: INCORRECT VALUES, UNDERGOING TEST WITH SLOWER INTERRUPT TIME. The 6 behind is "Doubt X"
    // WAIT I SHOULD CONFIRM CLOCK SPEED HERE?? LIKE PLUG AN OSCILLOSCOPE IN AN START TO OBSERVE THE FREQUENCY OF THIS INTERRUPT TO BE SURE
    T0CON  = 0xC4;

    // TRIS decide the direction of each GPIO pin. All pin on port A set to IN (1 is IN, 0 is OUT)
    // check datasheet pg87
    TRISA = 0xFF;
    PORTA = PORTA | 0x07;

    // RB0 and RB1 connected to LEDs
    // RB2 connected to PWM control
    TRISB = TRISB & 0b11111000; // RB0, RB1 and RB2 as OUTPUT
    PORTB = PORTB & 0b11111000; // tie them down to 0

    // enable Global Interrupt flag and Timer0 (datasheet pg75)
    INTCON = (BIT7 + BIT5);

    // init PWM
    // check this link: https://download.mikroe.com/documents/compilers/mikroc/pic/help/pwm_library.htm for info
    // also check datasheet p119 for extra information
    // the PWM pins are P1A to P1D. We will be using P1A
    // this PWM is then filtered out to an analog level between 0 and 1V to drive LTC6992 which will generate a PWM signal of 100kHz
    PWM1_Init(10000);         // set PWM to 10kHz, but the REAL PWM is 100kHz
    PWM1_Start();             // start PWM

}
