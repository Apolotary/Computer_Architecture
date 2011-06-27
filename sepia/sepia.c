#include <stdio.h>
#include <stdint.h>
#include <math.h>

struct bmp_header
{
	uint8_t signature[2];
	uint32_t file_size;
	uint16_t reserved[2];
	uint32_t pixel_array_offset;
}__attribute__((packed));

struct bmp_dib_header
{
	uint32_t dib_header_size;
	int32_t image_width;
	int32_t image_height;
	uint16_t planes;
	uint16_t bit_per_pixel;
	uint32_t compression;
	uint32_t image_size;
	int32_t x_pixels_per_meters;
	int32_t y_pixels_per_meters;
	uint32_t colors_count;
	uint32_t important_colors_count;
}__attribute__((packed));

struct bmp_header 	  src_bmp_header;
struct bmp_dib_header src_dib_header;

int main(int argc, char **argv)
{
	int shift, padding, i, j, tmp;
	
	uint8_t red, green, blue;
	
	FILE *src, *dst;
	
	if ( argc == 3 )
	{
		src = fopen(argv[1], "r");
		dst = fopen(argv[2], "w");
		
		fread(&src_bmp_header, sizeof(src_bmp_header), 1, src);
		fread(&src_dib_header, sizeof(src_dib_header), 1, src);
		
		fwrite(&src_bmp_header, sizeof(src_bmp_header), 1, dst);
		fwrite(&src_dib_header, sizeof(src_dib_header), 1, dst);
		
		shift = src_bmp_header.pixel_array_offset - 
				sizeof(src_bmp_header) - 
				src_dib_header.dib_header_size;
				
		while(shift--)
		{
			fputc(fgetc(src), dst);
		}
		
		shift = ((int) ceil(src_dib_header.image_width * src_dib_header.bit_per_pixel / 32.0)) * 4;
		
		shift -= src_dib_header.image_width * 3;
		
		for (i = 0; i < src_dib_header.image_height; ++i)
		{
			padding = shift;
			
			for (j = 0; j < src_dib_header.image_width; ++j)
			{
				blue = fgetc(src);
				green = fgetc(src);
				red = fgetc(src);
				
				uint32_t red2    = (0.393 * red + 0.769 * green + 0.189 * blue);
				uint32_t green2  = (0.349 * red + 0.686 * green + 0.168 * blue);
				uint32_t blue2   = (0.272 * red + 0.534 * green + 0.131 * blue);
                
                if (red2 > 255)
                {
                    red2 = 255;
                }
                if (green2 > 255)
                {
                    green2 = 255;
                }
                if (blue2 > 255)
                {
                    blue2 = 255;
                }
                
                uint8_t red3 = red2;
                uint8_t green3 = green2;
                uint8_t blue3 = blue2;
				
				fputc(blue3, dst);
				fputc(green3, dst);
				fputc(red3, dst);
			}
			
			while (padding--)
			{
				fputc(fgetc(src), dst);
			}
		}
		
		while ((tmp = fgetc(src)) != EOF)
		{
			fputc(tmp, dst);
		}
		
		fclose(src);
		fclose(dst);
		
		return 0;
	}
	else
	{
		perror("Not all arguments were specified.");
		
		return 1;
	}
}