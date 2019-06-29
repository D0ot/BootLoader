SECTIONS
{


    .data :
    {
        user.o(.header)
        user.o(.data)
    }

    .text :
    {
        user.o(.text)
        . = ALIGN(512);
    }

    __program_size = 1;
    

}