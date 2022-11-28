//generate txt.coe documents
//data rang from i to max_data
#include <stdio.h>
int main ()
{
    FILE *fid_write = fopen("text.coe","w");
    char T1[] = "memory_initialization_radix = 16;";
    char T2[] = "memory_initialization_vector = ";
    int i;
    int j = 5000; 
    char k[] = "4001e0000";
    int max_data = 4000;
    if (fid_write ==NULL)
    {
        return 0;
    } 
    fprintf(fid_write,"%s\n",T1);
    fprintf(fid_write,"%s\n",T2);
    // for (i=0;i<max_data;i++){
    //     j = j + j;
    //     if (i % 20 == 0)
    //     {
    //         fprintf(fid_write,"\n");
    //     }
    //     else 
    //     {
    //         fprintf(fid_write,"%d,",j);
    //     }
    // }
    for (i=0;i<max_data;i++){
 //       if (i < 1024 | i > 2048)
	if(i<0)
        {
            fprintf(fid_write,"%d,\n",i);
        }
        else 
        {
            fprintf(fid_write,"%s,\n",k);
        }
    }
	fprintf(fid_write,"%s",";");
    fclose(fid_write);
    return 1;
}
