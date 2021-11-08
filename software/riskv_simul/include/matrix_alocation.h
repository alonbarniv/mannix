 #ifndef MATRIX_ALLOCATION
 #define MATRIX_ALLOCATION

    
    //memory allocated

    char data[MANNIX_DATA_SIZE];  // we may use float for the first test inference

    //declare allocotors 
    Allocator_uint8 al[1];

    // allocate memory  - at byte granularity -- Works also for VS
    createAllocator_uint8(al, data, MANNIX_DATA_SIZE);
    
#endif