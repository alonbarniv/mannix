#include "../include/cnn_inc.h"


#define NUM_MAT 2

int main() {
    
#include "../include/matrix_alocation.h"
    Matrix_int8 fc_weight[NUM_MAT];

    creatMatrix_int8(8, 4, &fc_weight[0], (Allocator_int8*) al);
    creatMatrix_int8(3, 5, &fc_weight[1], (Allocator_int8*) al);

    int i,j,w;
    for (w=0;w<NUM_MAT;w++){
        for (i=0;i<fc_weight[w].rows;i++){
            printf(" [");
            for (j=0;j<fc_weight[w].cols;j++){
                printf("%d ", fc_weight[w].data[(i*fc_weight[w].cols)+j]);
            }
            printf("] \n");
        }
        printf("\n");
    }

    printMatrix_int8(&fc_weight[0]);
    //printf("TEST %d ", fc_weight[0].data[2]);
    return 0;
}