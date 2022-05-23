function [Decompressed_img, RGB_img] = ...
    InverseDiscreteCosineTransform2D(DCT_img, n, quality_factor, new_width, new_height, new_channel) 

%   funtion name: InverseDiscreteCosineTransform2D
%
%   [Decompressed_img, RGB_img] = ...
%    InverseDiscreteCosineTransform2D(DCT_img, n, quality_factor, new_width, new_height, new_channel)
%
%   inputs:
%   DCT_img - is compressed image/coefficient block after applying the DCT and quantization
%   on original image
%   n - determines the number of blocks image is broken into [2^n * 2^n]
%   quality_factor - factor determining the amount of quantization image
%   goes through
%   new_width - new width of image
%   new_height - new height of image
%   new_channel - no. of channels in the image
%
%   outputs:
%   Decompressed_img - final decompressed image in YCbCr form
%   RGB_img - final decompressed image in RGB form
%
%   The function takes in the above inputs to decompress the compressed
%   image by multiplying the matrix by the quantization matrix and taking
%   inverse DCT to return to the user the decompressed image


%check inputs by user are valid
    %check if image input by user is valid
    if ~exist('DCT_img', 'var')
        %else display error message
       error('DCT image missing!'); 
    end
    
    %check n input
    if ~exist('n', 'var')
        %if not specified default value of n that is 8*8[2^n * 2^n] blocks is chosen
       n = 3;
    end
    
    %check quality factor input
    if ~exist('quality_factor', 'var')
        %if not specified default value of 50 is chosen
       quality_factor = 50;
    end
    
    DCT_img = cast(DCT_img, 'single');
    temp_reverted_img = zeros(size(DCT_img),'single');
    
    %find the quantization matrix for the quality factor and n
    [quantization_matrix_Y, quantization_matrix_CbCr] = quantization(quality_factor, n);
    
    %calculate the DCT matrix used in inverse DCT 
    DCT_matrix = zeros(2^n);
    for i = 0:2^n-1
       for j = 0:2^n-1
           %calling Tmatrix function to calculated value at specific row
           %and column value
           %store value in DCT_matrix 
          DCT_matrix(i+1,j+1) = Tmatrix(i, j, n); 
       end
    end
    
    %for loop going through the length of the new width in the increments
    %of the width of the block size chosen
    for x = 1:2^n:new_width
        %for loop going through the length of the new height in the
        %increments of the height of the block size chosen
        for y = 1:2^n:new_height
            %for loop going through the different channels one by one
            for ch = 1:new_channel
                % taking the values of the data in that channel
                segmented_DCT_img = DCT_img(y:y+2^n-1, x:x+2^n-1, ch);
                
                %step 1 for decompression the image is multiplied by the
                %quantization matrix it was divided by during the
                %quantization process
                
                %the value of quantization matrix used in quantization is different for
                %different channels and therefore the following if else
                %statements are included 
                
                %when channel = 1; that is Y component of image
                if ch == 1 
                    %multiplying value by its quantization matrix
                    temp_reverted_img(y:y+2^n-1, x:x+2^n-1, ch) = ...
                        segmented_DCT_img.*quantization_matrix_Y;
                else
                    %for other channel values; that is for Cb and Cr
                    %components
                    %multiplying value by its quantization matrix
                    temp_reverted_img(y:y+2^n-1, x:x+2^n-1, ch) = ...
                        segmented_DCT_img.*quantization_matrix_CbCr;
                end 
                
                %step 2 taking the inverse DCT of the matrix
                %inverse DCT = TMT' where T - DCT mtarix;T' - transpose of
                % DCT matrix and M is the matrix we get from the previous
                % process of reversing the quantization process.
                
                %128 is added back to values after taking inverse DCT such that the values range
                %from 0 to 255 instead of being centred at 0
                
                temp_reverted_img(y:y+2^n-1, x:x+2^n-1, ch) = ...
                    round(DCT_matrix' * temp_reverted_img(y:y+2^n-1, x:x+2^n-1, ch) * DCT_matrix) + 128;
            end
        end
    end
    
    %decompressed image
    Decompressed_img = cast(temp_reverted_img, 'uint8');
    
    %convert decompressed image to RGB form
    RGB_img = ycbcr2rgb(Decompressed_img);
    
    % RGB_img = Decompressed_img;
end

%function creating the element of the DCT matrix value at a specific row, column place
function T = Tmatrix(x, y, n)
    %function documentation:
    %inputs:
    %x - row
    %y - column 
    %n - determines no of blocks into which the matrix is broken into [2^n*2^n]
    n = 2^n;
    if x == 0
        T = 1/sqrt(n);
    else
        T = sqrt(2/n)*cos(((2*y+1)*x*pi)/(2*n));
    end
end

%function to create quantization matrix used in decompression
function [quantization_matrix_Y, quantization_matrix_CbCr] = quantization(quality_factor, n)

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
    
    %when n not equal to 3
    if n ~= 3
        %resize quantization matrix
       quantization_matrix_Y = imresize(quantization_matrix_Y, [2^n, 2^n], 'bilinear'); 
       quantization_matrix_CbCr = imresize(quantization_matrix_CbCr, [2^n, 2^n], 'bilinear');
    end
    
    %calculating the scaling factor
    %initialize scaling factor
    scaling_factor = 0;
    
    if (quality_factor < 50)
        %for quality factor less than 50 calculate scaling factor
        scaling_factor = floor(5000/quality_factor);
    else
        %other values of quality factor calculate scaling factor
        scaling_factor = 200 - 2*quality_factor;
    end
    
    %quantization matrix for the Y component
    quantization_matrix_Y = floor((scaling_factor*quantization_matrix_Y + 50) ./ 100);
    quantization_matrix_Y(quantization_matrix_Y < 1) = 1;
    quantization_matrix_Y(quantization_matrix_Y > 255 ) = 255;
    
    %quantization matrix for the Cb and Cr component
    quantization_matrix_CbCr = floor((scaling_factor*quantization_matrix_Y +50) ./ 100);
    quantization_matrix_CbCr(quantization_matrix_CbCr < 1) = 1;
    quantization_matrix_CbCr(quantization_matrix_CbCr > 255) = 255;
    
end