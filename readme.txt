%----------------------------------------%
Some files takes a long time to run;
The team had prepared six .mat files to reduce the run time


Task_Demonstrate_Compression.m demonstrates the compression effects,
compression ratio and entropy


Task_Demonstrate_Energy_Compactness.m demonstrates the energy compactness
of DCT coefficients and the Quantized Coefficient Matrices of three channels


Task_Demonstrate_MSE.m demonstrates the reconstruction errors in Sum Squared 
Error, Mean Squared Error and Peak Signal-to-Noise Ratio against quality factor and
number of DCT coefficients removed


Task_Demonstrate_Segmentation demonstrates the effects of varying size of the 
segmentation block and DCT block, it also shows Gibbs phenomena, visual artifacts

MATLAB dct2 function is not used here because of the limitation of choosing
a desirable "n" (Size of segmented block) for investigation

%----------------------------------------%
