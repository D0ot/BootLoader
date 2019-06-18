SECTIONS
{
    /* jump to here to run */
    . = 0x7C00;
    .text :
    {
        *(.text)
    }
    
    .data :
    {
        *(.data)
    }

    .stack :
    {
        *(.stack)
    }

    allsize = ABSOLUTE(.);
    .mbrcheck : 
    {
        . = 0x7C00 + 512 - allsize - 2;
        boot.o(.mbrcheck)

    }

    .sector2 :
    {  
        *(.sector2)
        BYTE(0);
    }


    allsize2 = ABSOLUTE(.);
    .alignpadding :
    {
        
        . = 0x7C00 + 1024 -allsize2 - 4;
        LONG(0xDEADBEFF);
    }

    .sector3 :
    {
        *(.sector3)
        BYTE(0);
    }

    allsize3 = ABSOLUTE(.);
    .alignpadding2 :
    {
        . = 0x7C00 + 512 * 3 - allsize3 - 4;
        LONG(0xDEADBEFF);
    }

}