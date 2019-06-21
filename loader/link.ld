SECTIONS
{
    /* boot will jump to here to run */
    . = 0x8200;

    .predata :
    {
        loader.o(.header)
        loader.o(.predata)
        BYTE(0xCC)
        BYTE(0xCC)
    }

    .text :
    {
        loader.o(.text)
    }

    .data :
    {
        loader.o(.text)
    }

    allsize = .;
    .padding :
    {
        . = 0x8200 + 512 - allsize - 2;
        BYTE(0xCC)
        BYTE(0xCC)
    }

}

