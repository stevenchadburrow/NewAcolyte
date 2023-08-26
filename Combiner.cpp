#include <stdio.h>
#include <stdlib.h>

int main(const int argc, const char **argv)
{
	if (argc < 4)
	{
		printf("Combines two 16K .bin files at the top of a single 128K .bin file\n");
		printf("Arguments: <input1.bin> <input2.bin> <output1.bin>\n");
	
		return 0;
	}

	FILE *input[2], *output;

	unsigned char buffer;

	input[0] = NULL;
	input[1] = NULL;

	for (int i=0; i<2; i++)
	{
		input[i] = fopen(argv[i+1], "rb");
		if (!input[i])
		{
			printf("Input Error\n");
		
			return 0;
		}
	}

	output = NULL;

	output = fopen(argv[3], "wb");
	if (!output)
	{
		printf("Output Error\n");

		return 0;
	}

	for (unsigned int i=0; i<16384; i++)
	{
		fscanf(input[0], "%c", &buffer);
		fprintf(output, "%c", buffer);
	}

	for (unsigned int i=16384; i<32768; i++)
	{
		fscanf(input[1], "%c", &buffer);
		fprintf(output, "%c", buffer);
	}

	for (unsigned int i=32768; i<131072; i++)
	{
		fprintf(output, "%c", 0x00);
	}

	for (int i=0; i<2; i++)
	{
		fclose(input[i]);
	}

	fclose(output);

	return 1;
}
