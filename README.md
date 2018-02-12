# Xilinx-7series-Design
Synthesis optimized Design for Xilinx 7 Series CLB resources
### Clocking in 7-series MMCM and PLL [up to 24 CMT tiles]
MMCM and PLL serves as a frequency synthesizer for a wide range of frequencies, jitter filter and deskew external or internal clocks. Dynamically change the clock output frequency, phase shift, and duty cycle of the mixed-mode clock manager (MMCM). MMCM has at total of 8 counters (dividers) with 4 caipable of dividing out an inverted clock (180-phase shift).
The MMCM supports fractional (non-integer) values for the CLKOUT0 and CLKFBOUT counters. fractional divide portion of the divider in 0.125(1/8) increments. Eg: FRAC(4) = 0.500. MMCM is just a PLL with a few extra cool features:

    • Direct HPC to BUFR or BUFIO using CLKOUT[0:3]
    • Inverted clock outputs (CLKOUT[0:3]B)
    • CLKOUT6
    • CLKOUT4_CASCADE
    • Fractional divide for CLKOUT0_DIVIDE_F
    • Fractional multiply for CLKFBOUT_MULT_F
    • Fine phase shifting
    • Dynamic phase shifting 

VCO operating frequency: *f-VCO = f-CLKIN x (M/D)*
Output frequency: *f-OUT = f-CLKIN x (M/(DxO))*
