function [quantization_matrix_Y, quantization_matrix_CbCr] = quantization(quality_factor, n) 

% function name: quantization
%
% [quantization_matrix_Y, quantization_matrix_CbCr] = quantization(quality_factor, n)
%
% inputs:
% quality_factor - quality factor is factor which determines the amount of elements elemenated during the quantization process 
% n - n defines the number of blocks the image is broken into [2^n * 2^n]
%
% outputs:
% quantization_matrix_Y - is the quantization matrix used for the
% quantization process of the Y component of the DCT
% quantization_matrix_CbCr - is the quantization matrix used for the
% quantization process of the Cb and Cr component of the DCT
%
% the function generates the quantization matrix required by the Y,Cb and
% CR components of the DCT of the inital image for the quantization process
% by taking input of the quality factor and n from the user

    %default value of quantization matrix for 8*8 blocks and Y component.
    %quantization matrix for quality factor of 50
    quantization_matrix_Y = [16 11 10 16 24 40 51 61;...
        12 12 14 19 26 58 60 55;...
        14 13 16 24 40 57 69 56;...
        14 17 22 29 51 87 80 62;...
        18 22 37 56 68 109 103 77;...
        24 35 55 64 81 104 103 92;...
        49 64 78 77 103 121 120 101;...
        72 92 95 98 112 100 103 99];
    
    %default value of quantization matrix for 8*8 blocks and Cb,Cr
    %component.
    %quantization matrix for the quality factor of 50
    quantization_matrix_CbCr = [17 18 24 47 99 99 99 99;
        18 21 26 66 99 99 99 99;
        24 26 56 99 99 99 99 99;
        47 66 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99];
    
    %the above matrix is for 8*8 blocks that is n = 3 for the other values
    %of n use imresize to resize the matrix to the size we require based on
    %the value of n [2^n * 2^n]
    
    %if n is not equal to 3
    if n ~= 3
        %resize the matrix
       quantization_matrix_Y = imresize(quantization_matrix_Y, [2^n, 2^n], 'bilinear'); 
       quantization_matrix_CbCr = imresize(quantization_matrix_CbCr, [2^n, 2^n], 'bilinear');
    end
    
    %calculate the scaling factor
    
    %initialize scaling factor
    scaling_factor = 0;
    
    if (quality_factor < 50)
        %for quality factor less than 50 calculate scaling factor
        scaling_factor = 5000/quality_factor;
    else
        %for other values of quality factor calculate scaling factor
        scaling_factor = 200 - 2*quality_factor;
    end

    %quantization matrix for the Y component
    quantization_matrix_Y = floor((scaling_factor*quantization_matrix_Y + 50) ./ 100);
    quantization_matrix_Y(quantization_matrix_Y == 0) = 1;
    quantization_matrix_Y(quantization_matrix_Y > 255 ) = 255;
    
    %quantization matrix for the Cb and Cr component
    quantization_matrix_CbCr = floor((scaling_factor*quantization_matrix_Y + 50) ./ 100);
    quantization_matrix_CbCr(quantization_matrix_CbCr == 0) = 1;
    quantization_matrix_CbCr(quantization_matrix_CbCr > 255) = 255;
end
