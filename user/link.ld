SECTIONS
{
    . = 0;
    .header :
    {
        user.o(.header)
    }

    .text :
    {
        user.o(.text)
    }

    .data :
    {
        user.o(.data)
    }

}