    Title: raspberry pi timer
    Date: 2016-10-07T23:10:58
    Tags: Raspberry

树莓派的计时器
<!-- more -->

        与Gpio控制器类似,计时器也有一个地址.在这里计时器的地址是20003000(十六进制).
    树莓派没有板载的电源所以不加电的时候时间就不准.因此我们只能依靠这个计时器来计时.
    计时器本身有64位,与其搭配的还有32位的控制字,4个32位的比较寄存器.计时器是只读的.
        计时器每一μs加1.每次加完都会将低32位与比较寄存器比较.如果和任何一个匹配上了,
    就根据所匹配的寄存器对控制/或者叫状态寄存器进行更新.


