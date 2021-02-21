#include<stdio.h>
#define N 30
void add(int *X,int *Y,int *Z)
{
        for(int i=0;i<N;i++)
            for(int j=0;j<N;j++)
                    Z[i*N+j] = X[i*N+j]+Y[i*N+j];

}

__global__ void add_kernel(int *X,int *Y,int *Z)
{
        int i = threadIdx.x;
        int j = threadIdx.y;

        Z[i*N+j] = X[i*N+j]+Y[i*N+j];

}

int main()
{
        int X[N*N];
        int Y[N*N];

        for(int i=0;i<N;i++)
           for(int j=0;j<N;j++) {
                X[i*N+j]=-1;
                Y[i*N+j]= 1;
           }

        //Outout matrix
        int Z[N*N];

        int *d_X,*d_Y,*d_Z;
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        cudaMalloc((void**) &d_X, (N*N)*sizeof(int));
        cudaMalloc((void**) &d_Y, (N*N)*sizeof(int));
        cudaMalloc((void**) &d_Z, (N*N)*sizeof(int));

        cudaMemcpy(d_X, &X,(N*N)*sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_Y, &Y,(N*N)*sizeof(int), cudaMemcpyHostToDevice);


        dim3 dimGrid(13,13,1);
        dim3 dimBlock(22,22,1);
        cudaEventRecord(start);
        add_kernel<<<dimGrid, dimBlock>>>(d_X,d_Y,d_Z);
        cudaEventRecord(stop);
        //add(X, Y, Z);

        cudaMemcpy(&Z, d_Z,(N*N)*sizeof(int), cudaMemcpyDeviceToHost);
        cudaFree(d_X);
        cudaFree(d_Y);
        cudaFree(d_Z);
        cudaEventSynchronize(stop);
        float Timeused = 0;
        cudaEventElapsedTime(&Timeused, start, stop);
        for(int i=0;i<N;i++)
                for(int j=0;j<N;j++){
                printf("%d ",Z[i*N+j]);
	  }
                printf("\n");
                printf("Time used:%f ",Timeused);
                return -1;

}

