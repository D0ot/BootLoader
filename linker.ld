SECTIONS
{
    /* jump to here to run */
    . = 0x7C00;
    .text :
    {
        boot.o(.text)
    }
    
    .data :
    {
        boot.o(.data)
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
        boot.o(.stack)
        BYTE(0);
    }


    allsize2 = ABSOLUTE(.);
    .alignpadding :
    {
        
        . = 0x7C00 + 1024 - allsize2 - 4;
        LONG(0xDEADBEFF);
    }

    .sector3 :
    {
        boot.o(.heap)
        BYTE(0xFF);
    }

}