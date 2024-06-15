# fpga-based-filtering-of-images

This project implements hardware logic to perform 3x3 image filtering on a 64x64 image using VHDL. The design incorporates memory elements, compute units, and a VGA controller. Key components include RAM, ROM, registers, and a Multiplier-Accumulator (MAC) block optimized for efficient pixel normalization and image processing. The project explores methods to reduce execution time by exploiting overlap in successive filtering operations, culminating in the rapid display of filtered images on a VGA monitor.
