//:
// \file
// \brief Example of loading an image, resampling + saving
// \author dac

#include <vcl_iostream.h>
#include <vxl_config.h> // for vxl_byte
#include <vil/vil_load.h>
#include <vil/vil_save.h>
#include <vil/vil_resample_bilin.h>
#include <vil/vil_resample_bicub.h>

int main(int argc, char** argv)
{
  if (argc!=5)
  {
    vcl_cout<<"vil_resample_image src_image dest_image n1 n2"<<vcl_endl;
    vcl_cout<<"Loads from src_image"<<vcl_endl;
    vcl_cout<<"resamples to size n1*n2"<<vcl_endl;
    vcl_cout<<"saves result to dest_image"<<vcl_endl;
    return 0;
  }

  vil_image_view<vxl_byte> src_im = vil_load(argv[1]);
  if (src_im.size()==0)
  {
    vcl_cout<<"Unable to load source image from "<<argv[1]<<vcl_endl;
    return 1;
  }

  vcl_cout<<"Loaded image of size "<<src_im.ni()<<" x "<<src_im.nj()<<vcl_endl;

  int n1= atoi (argv[3]);
  int n2= atoi (argv[4]);

  // rotate the image
  vil_image_view<vxl_byte> dest_im;
  //vil_resample_bilin( src_im, dest_im, n1, n2 );
  vil_resample_bicub( src_im, dest_im, n1, n2 );

  vcl_cout<<"src_im= "<<src_im<<vcl_endl;
  vcl_cout<<"dest_im= "<<dest_im<<vcl_endl;

  if (!vil_save(dest_im, argv[2]))
  {
    vcl_cerr<<"Unable to save result image to "<<argv[2]<<vcl_endl;
    return 1;
  }

  vcl_cout<<"Saved image to "<<argv[2]<<vcl_endl;

  return 0;
}
