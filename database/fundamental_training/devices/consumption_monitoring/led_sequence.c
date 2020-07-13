#include "platform.h"

#define DELAY 0x160000

/* Time delay */
static void time_delay(unsigned int d)
{
    int i;
    for (i=0;i<DELAY;i++){
        __asm__("nop");
    }
}

/* Leds change */
static void led_change(uint8_t led_state)
{
    leds_off(LED_0 | LED_1 | LED_2);

    switch(led_state)
    {
        case 0:
        leds_on(LED_2);  // Green led on
        break;

        case 1:
        case 3:
        leds_on(LED_1); // Red led on
        break;

        case 2:
        leds_on(LED_0); // Orange led on
        break;
    }
}

int main()
{
    /* Init the platform */
    platform_init();

    uint8_t j = 0;
    while(1)
    {
        led_change(j);
        time_delay(DELAY);
        j = (j+1) % 4;
    }

    return 0;
}
