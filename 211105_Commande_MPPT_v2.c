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
#define ADAPTIVE_PO      0                 // basic P&O
#define FAST_GMPPT   1                 // turning GMPPT
#define STEADY_STATE 2

// some definition necessary for P&O part
#define CURRENT_HYSTERESIS 1           // since current measurement is a bit noisy to need a small hystereris to ensure that we are not deciding too early
#define DELTA_D            1           // we would like to have a fine duty cycle change

// some security measures to make sure that we dont fry the output cap
#define MAX_VOLTAGE_OUT    550

// this determines how many cycles we will observe before declaring that the system enter oscillation
#define OSCILLATION_MAX 4

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
INT16 voltage_in = 0;
INT16 current_in = 0;
INT16 voltage_out = 0;
// UINT16 current_out;         //THIS LINE JUST ANTICIPATE CURRENT OUTPUT MEASUREMENT

// the measured power. This version uses the input power but it would be better to use output power
INT32 measured_power = 0;

// last measured variable: same as right above but measured during last cycle
INT16 last_voltage_in = 0;
INT16 last_current_in = 0;
INT16 last_voltage_out = 0;
// UINT16 last_current_out;    //THIS LINE JUST ANTICIPATE CURRENT OUTPUT MEASUREMENT

// last measured power.
INT32 last_measured_power = 0;
INT32 last_delta_power = 0;
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
UINT8 mode = STEADY_STATE;

// The 3 voltage values that we need to aim for is 5.4V, 9.2V and 12.8V, converted over to as value is
// Values for 3.2 version board: 5.4V => 358, 9.2V => 618, 12.8V => 864
// so we'll use the same margins as MATLAB sim: 350-370, 600-640, 835-905. These values are also consistent with the voltage formula for V3.2 board
// note that there is an alternate version that gives 5.4V, 8.9V and 12.4V (probably more precise becuz this sweep is done with extra diode carac)
// the margins are also important: for the first 1, the duty cycle is based on delta_voltage>>2 so if u change the margin
// it may not converge at all.
UINT8 sweep_iteration = 0;               // this is to track which PP are we investigating during the sweep
UINT8 sweep_duty_cycle[3] = {0, 0, 0};        // random guess because the == 0 comparison is only worth while at startup but take up code during subsequent passes
                                              // this array is necessary because it serves as a great starting point for the next iteration
UINT32 P_max_fast_gmppt = 0;                  // max power that we measured during fast GMPPT
UINT8 D_max_fast_gmppt = 0;                   // the duty cycle that gives P_max_fast_gmppt

UINT16 sweep_lower_bounds[3] = {350, 600, 835};      // store the lower bounds for the sweep iterations
UINT16 sweep_upper_bounds[3] = {370, 640, 905};
UINT16 sweep_target[3] = {360, 620, 870};
UINT32 max_power = 0;                          // register the max amount of power
UINT8 max_power_index = 0;                    // the index of max power in the array of 3

UINT32 P_max_adaptive = 0;
UINT8 D_max_adaptive = 0;
UINT8 D_step = 0;
UINT8 speed_coeff = 0;

UINT8 oscillation_detect = 0;
/******************************* FUNCTION PROTOTYPE *******************************/
void init();

void LED1_ON();
void LED1_OFF();
void LED2_ON();
void LED2_OFF();

void main() {
    // call init function to initialize the necessary peripherals
    init();

    while(1) {
        // only if a measurement is made that we start doing these things
        if (settled) {
            // we detect which mode we are in and start doing calculations and things
            /************* measuring input voltage and output voltage (PV voltage + Vbat) ************/
            for (counter = 0; counter < 4; ++counter) {
               voltage_in += ADC_Read(0);
               voltage_out += ADC_Read(2);
            }
            // divide voltage_in by 4 to take the average
            voltage_in >>= 2;
            voltage_out >>= 2;

            /************* measuring input current (PV current) ************/
            for (counter = 0; counter < 8; ++counter) {
                current_in += ADC_Read(1);
            }
            // then divide current_in by 16 to take the average. Current is kinda jittery so that's why we make more measurements
            current_in >>= 3;

            // again taking the average of signal (by 4)
            voltage_out >>= 2;

            // calculate the power as measured
            measured_power = (INT32)voltage_in * (INT32)current_in;

            switch(mode) {
                case FAST_GMPPT: /******************************************/   /* THIS SECTION IS STILL OPTIMIZABLE */
                     // light up LED 1 to indicate we are on fast GMPPT (this may not be very visible tho...)

                     // basically there are 3 voltage zone that we want to reach and measure the power obtained
                     // since the output voltage might sway a bit (for batteries its between 3.2V - 4.2V)
                     // we therefore need to regulate a bit to reach the voltage zone
                     // apply for 1st sweep
                     if (sweep_iteration < 3 && (voltage_in < sweep_lower_bounds[sweep_iteration] || voltage_in > sweep_upper_bounds[sweep_iteration]) ) {
                          if (voltage_in < sweep_target[sweep_iteration]) {
                              D = D - ( (sweep_target[sweep_iteration] - voltage_in)>>(3+sweep_iteration) );
                          }else {
                              D = D + ( (voltage_in - sweep_target[sweep_iteration])>>(3+sweep_iteration) );
                          }        
                     }else if (sweep_iteration < 3 && voltage_in >= sweep_lower_bounds[sweep_iteration] && voltage_in <= sweep_upper_bounds[sweep_iteration]) {
                          sweep_duty_cycle[sweep_iteration] = D;                   // save the current duty cycle that has the correct voltage
                          if (measured_power > P_max_fast_gmppt) {
                             D_max_fast_gmppt = measured_power;
                             D_max_fast_gmppt = D;
                          }

                          ++sweep_iteration;                                       // go to the next iteration
                          if (sweep_iteration < 3) {
                              D = sweep_duty_cycle[sweep_iteration];
                          }else { // getting here means that we have already logged the measured power for sweep 0, 1, 2
                               // we're done sweeping, assign the duty cycle that gives max power
                               D = D_max_fast_gmppt;
                               // this is point of the loop, we should have the duty cycle that will give us the max between the 3 points we checked
                               // clear all of the last measured points to be sure...
                               last_voltage_in = 0;
                               last_current_in = 0;
                               last_voltage_out = 0;
                               last_measured_power = 0;
                               last_delta_power = 0;
                               
                               // init speed coeff at 4
                               speed_coeff = 4;
                               // reset the P max adaptive and D max adaptive
                               P_max_adaptive = 0;
                               D_max_adaptive = 0;
                          }
                     }
                break;
                case ADAPTIVE_PO:    /******************************************/
                     // calculate the delta voltage and delta power
                     delta_power = measured_power - last_measured_power;
                     delta_voltage = voltage_in - last_voltage_in;
                     // during adaptive P&O, we also need to track the duty cycle that yields the max power
                     if (measured_power > P_max_adaptive) {
                        D_max_adaptive = D;
                        P_max_adaptive = measured_power;
                     }

                     // we will first divide the accessible zones to have a different duty cycle step
                     // 680 above we do D_step 1, 470 above 2, otherwise 4 (for anything below)
                     // we take these values because it is easier on the µC, MATLAB code used 1,3,5
                     // this should gives approximately 0.1-0.2V variation per step
                     if (voltage_in >= 680) {
                        D_step = speed_coeff;
                     }else if (voltage_in >= 470) {
                        D_step = speed_coeff>>1;
                     }else {
                        D_step = speed_coeff>>4;
                     }

                     // this section only makes sens if we last_measured_power
                     if (last_measured_power) {
                       if ( (delta_power >= 0 && delta_voltage >= 0) || (delta_power <= 0 && delta_voltage <= 0) ) {
                          D -= D_step;
                       }else {
                          D += D_step;
                       }
                       if (oscillation_detect < OSCILLATION_MAX) {
                          if ( (last_delta_power >= 0 && delta_power <= 0) || (last_delta_power <= 0 && delta_power >= 0) ) {
                             ++oscillation_detect;                // increment the oscillation detect counter
                          }else {
                             oscillation_detect = 0;              // any interruption means we need to reset this counter
                          }
                       }
                       if (oscillation_detect == OSCILLATION_MAX && speed_coeff > 0) {
                          speed_coeff >>= 1;
                          oscillation_detect = 0;
                       }
                       if (speed_coeff == 0) {
                          mode = STEADY_STATE;                   // if speed_coeff becomes 0 it means that we should go into steady state
                          oscillation_detect = 0;
                          D = D_max_adaptive;
                       }
                     }

                     // store the last power delta
                     last_delta_power = delta_power;
                     last_voltage_in = voltage_in;
                     last_measured_power = measured_power;
                break;
                case STEADY_STATE:
                     // at entry, there should a one cycle where D is at D_max_adaptive already
                     
                     if ((measured_power - P_max_adaptive) > 1000 || (measured_power - P_max_adaptive) > 1000) {
                        mode = FAST_GMPPT;
                        P_max_adaptive = 0;                // reset P_max_adaptive
                        P_max_fast_gmppt = 0;              // register the max power obtained during the sweep
                        D_max_fast_gmppt = 0;
                     }
                break;
            }
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
    // 0xC5 gives 8ms approx
    // 0xC6 gives 16ms approx
    T0CON  = 0xC6;

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

