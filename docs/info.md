<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The buttons are debounced using a slow clock enable signal. When the increase duty button is pressed, the duty cycle increases by ten per cent. Similarly, pressing the decrease duty button reduces the duty cycle by ten per cent. The pwm out signal is set high when counter PWM is less than duty cycle and low otherwise, producing the desired pwm waveform.

## How to test

Generate a 10 M Hz PWM signal from a 100 M Hz clock with an initial 50 per cent duty cycle, where the duty cycle increases or decreases by 10 per cent on increase duty or decrease duty button presses, outputing the signal as PWM OUT.



## External hardware


push buttons, pwm load

