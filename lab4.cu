#include<stdio.h>
#include<math.h>
#define N 8

//Interleave addressing kernael_version
__global__ void interleaved_reduce(int* d_in,int* d_out)
{
     int i= threadIdx.x;
    // int M= N/2;
    // for(int s=1; s<N; s=s<<1){
//            if(i<M) {
//              printf("stride = %d, thread %d, is active \n",s,i);
//              d_in[(2*s)*i]=d_in[(2*s)*i] + d_in[(2*s)*i+s];

//            }
 //           M= M/2;

   //  }
    // if(i == 0)
     //         d_out[0] = d_in[0];

         __shared__  int temp[N];
         int idx = threadIdx.x + blockIdx.x*blockDim.x;
         temp[i] = d_in[idx];
         for(int s=1; s<blockDim.x ; s=s<<1){
               if(i<blockDim.x){
                       printf("stride = %d, thread %d, is active \n",s,i);
                       temp[(2*s)*i] = temp[(s*2)*i] + temp[(2*s)*i+s];

               }
                __syncthreads();





         }
         if(i ==0)
                 d_out[blockIdx.x] = temp[0];
}

//Contiguous addressing kernel version
__global__ void contiguous_reduce(int* d_in,int* d_out)
{



           //  int i= threadIdx.x;
           //  int M= N/2;
           //  for(int s=M; s>0; s=s>>1){
        //       if(i<M) {
        //              printf("stride = %d, thread %d, is active \n",s,i);
        //               d_in[i]=d_in[i] + d_in[i+s];

        //               }
        //       M= M/2;
 // }
//           if(i == 0)
//               d_out[0] = d_in[0];

    //share memory
        __shared__ int temp[N];
	 int i  = threadIdx.x;
        int idx = threadIdx.x + blockIdx.x * blockDim.x;
        temp[i]=d_in[idx];
       __syncthreads();
        for(int s=blockDim.x; s>0;s=s>>1){
                if(i<s){
                        printf("stride = %d, thread %d, is active \n",s,i);
                        temp[i]=temp[i+s];

        }



        if(i==0)
            d_out[blockIdx.x] = temp[0];


        }
}

int main()
{

        int h_in[N];
        int h_out= 0;

        for(int i=0; i<N; i++){
                h_in[i] = i+1;

        int *d_in, *d_out;
        cudaEvent_t start,stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        cudaMalloc((void**) &d_in, N*sizeof(int));
        cudaMalloc((void**) &d_out, sizeof(int));
        cudaMemcpy(d_in, &h_in, N*sizeof(int), cudaMemcpyHostToDevice);
        //kernel call
        cudaEventRecord(start);
        //interleaved_reduce<<<1,1024>>>(d_in,d_out);
        contiguous_reduce<<<1,1024>>>(d_in, d_out);

        cudaEventRecord(stop);
        cudaMemcpy(&h_out, d_out, sizeof(int), cudaMemcpyDeviceToHost);
        cudaFree(d_in);
        cudaFree(d_out);

        cudaEventSynchronize(stop);
        float Timeused;
        cudaEventElapsedTime(&Timeused, start , stop);
        printf("Output: %d \n Time used: %f ", h_out, Timeused);




        return -1;

        }

