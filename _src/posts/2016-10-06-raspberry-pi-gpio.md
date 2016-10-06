    Title: Raspberry Pi GPIO
    Date: 2016-10-06T21:30:40
    Tags: Raspberry


树莓派的GPIO,摘自《BCM2835 ARM Peripherals》

<!-- more -->

    一共有54个通用的I/O线,分成两组.在BCM上所有的pin至少有两个可选的函数.
    可选函数通常是一个外围的io线和另一条独立的线用于控制io的电压.电压控制的线路可能出现在任意一组控制线.
    GPIO有三条专用控制线,这些线通过专用的状态寄存器触发.
    GPIO有41个寄存器,所有的寄存器都可以认为是32位的.
