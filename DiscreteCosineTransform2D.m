function [DCT_img, ycbcr_img, new_width, new_height, new_channel, zigzagstream, ...
    rle_Y, rle_Cb, rle_Cr, num_of_zeros, avg_num_of_zeros_per_blk, total_energy, splitted_energy] = ...
    DiscreteCosineTransform2D(input_img, n, quality_factor)

%   function name: DiscreteCosineTransform2D
%
%   [DCT_img, ycbcr_img, new_width, new_height, new_channel, zigzagstream, ...
%   rle_Y, rle_Cb, rle_Cr, num_of_zeros, avg_num_of_zeros_per_blk, total_energy, splitted_energy] = ...
%   DiscreteCosineTransform2D(input_img, n, quality_factor)
%
%     inputs:
%     input_img - image on which we want to apply discrete cosine 
%     transform,quantization and run length coding to compress
%     n - it defines the number of blocks into which image matrixes are broken into [2^n * 2^n] 
%     quality factor - it defines the amount of quantization the image goes
%     through after the discrete cosine transform for further compression
%
%     outputs:
%     DCT_img - it is the image/coefficient block after applying the DCT in
%     the YCbCr form
%     ycbcr_img - It is the initial image in YCbCr form 
%     new_width - new width of image so that it can be divisible by the number of
%     blocks
%     new_height - new height of image so that it can be divisible by the number
%     of blocks
%     new_channel - number of channels in the output image which is same as
%     the number of channel in the input
%     zigzagstream - data grouped into a single stream such that it can
%     undergo further compression by run length or huffman encoding
%     rle_Y - output of runlength coding on the Y component of zigzagstream
%     rle_Cb - output of runlength coding on the Cb component of zigzagstream 
%     rle_Cr - output of runlength coding on the Cr component  of zigzagstream 
%     num_of_zeros - it is the number of zeros in DCT coeffecients matrix after quantization
%     avg_num_of_zeros_per_blk - average of number of zeros per block
%     total_energy - total energy of the image that is sum of energy in all channels 
%     splitted_energy - energy of image in each individual channel is
%     grouped seperately 
%
%     The above function compresses the input image on the basis of the n and quality
%     factor value selected by the user. The image is compressed by DCT followed by quantization
%     and then run length coding to give us the above specified outputs

%check inputs are valid
%check if input image is valid 
    if ~exist('input_img', 'var')
        %if not display error message
       error('Input image missing!'); 
    end
    
%check if n value has been specified by the user    
    if ~exist('n', 'var')
        %if not value is set as 3 that is we take default 8*8 blocks
       n = 3;
    end
    
%check if quality factor specified by user    
    if ~exist('quality_factor', 'var')
        %if not we use a default factor of 50
       quality_factor = 50;
    end
    
    % First step - color space conversion
    % converting from RGB channel to Y-CB-CR channel
    
    %finding the size that is height width and channel of image using
    %inbuilt function of size
    [height, width, channel] = size(input_img);
    
    if channel == 3
        %if it consists of 3 channels that is it is in RGB format convert
        %it into YCbCr form
        ycbcr_img = rgb2ycbcr(input_img);
    else
        %else no conversion required
        ycbcr_img = input_img;
    end
    
    % Second step - resizing
    % If the image does not match the size of the DCT matrix
    % It will have to be resize to match the filter size
    % must be divisible by the filter size
    [height, width, channel] = size(ycbcr_img);
    
    
    % If the size of the DCT matrix is larger than the size of the image
    % Output error, it is too large
    if 2^n > height || 2^n > width
        msg = sprintf("2^n, n = %d (%d) greater than height = %d or width = %d", ...
            n, 2^n, height, width);
       error(msg);
    end
    
    h = height;
    w = width;
    c = channel;
    
    % recalculate the new height and width
    if mod(height, 2^n) ~= 0
        remainder_height = mod(height, 2^n);
        h = height - remainder_height;
    end
    if mod(width, 2^n) ~= 0
        remainder_width = mod(width, 2^n);
        w = width - remainder_width;
    end
    
    resize_img = [];
    
    %resize the image based on new height and new width
    new_height = h;
    new_width = w;
    new_channel = c;
    resize_img = imresize(ycbcr_img, [new_height, new_width]);
    
    % In normal JPEG compression scheme, chroma subsampling is used here
    % Since it is not a requirement in the project, we have decided to 
    % omit the more complicated approach, and use a simpler one
    %     resampler = vision.ChromaResampler;
    %     [Cb_subsample, Cr_subsample] = resampler(resize_img(:, :, 2), resize_img(:, :, 3));
    %     resize_img(:, :, 2) = imresize(Cb_subsample, size(resize_img(:, :, 2)), 'bicubic');
    %     resize_img(:, :, 3) = imresize(Cr_subsample, size(resize_img(:, :, 3)), 'bicubic');
    
    % Subsampling Cb and Cr channel
    resize_img(:,:, 2:3) = 8.*round(resize_img(:,:, 2:3)/8);
    
    % cast to single type for calculation
    resize_img = cast(resize_img, 'single');
    
    % Third step - 2D Discrete Cosine Transform
    
    % 3.1 - constructing the DCT matrix
    
    % constructing the DCT matrix using Tmatrix function
    %initialize DCT_matrix
    DCT_matrix = zeros(2^n);
    
    %with which the inital matrix of value is multiplied to find the DCT 
    %DCT of img  = TMT' ; where M is the initial matrix and T is DCT matrix
    
    for i = 0:2^n-1
       for j = 0:2^n-1
           %finding the value of DCT matrix at specific position using
           %Tmatrix function and storing in matrix initialized before
           DCT_matrix(i+1,j+1) = Tmatrix(i, j, n); 
       end
    end
    
    temp_DCT_img = zeros(size(resize_img),'single');
    
    %finiding the matrix used in quantization using the function
    %quantization
    %The quantization matrix used for the Cb,Cr component is the same
    [quantization_matrix_Y, quantization_matrix_CbCr] = quantization(quality_factor, n);
    
    %initialize matrix to store zigzagstream, total energy and splitted
    %energy
    zigzagstream = zeros(3, new_height*new_width, 'single');
    total_energy = zeros(2^n, 2^n);
    splitted_energy = zeros(2^n, 2^n, new_channel);
    
    count = 0;
    
    %for loop going through the length of the new width in the increments
    %of the width of the block size chosen
    for x = 1:2^n:new_width
        %for loop going through the length of the new height in the
        %increments of the height of the block size chosen
        for y = 1:2^n:new_height
            %for loop going through the different channels one by one
            for ch = 1:new_channel
                %for the channel value : the magnitude of value ranges from
                %0 to 255
                %value is subtracted by 128 such that the values are now
                %centered at 0
                segmented_img = resize_img(y:y+2^n-1, x:x+2^n-1, ch) - 128;
                %finding the DCT coeffecients using the DCT matrix
                % coeffecients = TMT' where T - DCT mtarix;T' - transpose of
                % DCT matrix and M is the initial matrix
                temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch) = DCT_matrix * segmented_img * DCT_matrix';
                
                %total energy is found using the EnergyCompact function
                %energy values for all channels is added to get the final
                %total energy
                total_energy = total_energy + EnergyCompact(temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch), n);
                
                
                %the value of quantization matrix used in quantization is different for
                %different channels and therefore the following if else
                %statements are included 
                
                %when channel = 1; that is Y component of image
                if ch == 1 
                    %splitted energy is energy of that particular channel
                    %only
                    % EnergyCompact function is used to calculate this
                    % energy value 
                    splitted_energy(:, :, ch) = splitted_energy(:, :, ch) + ...
                        EnergyCompact(temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch), n);
                    
                    %quantization of matrix is done after the matrix of DCT
                    %coeffecients is found
                    %quantization is done by didviding the matrix by the
                    %quantization matrix and rounding off to the nearest
                    %integer
                    temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch) = ...
                        round(temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch)./quantization_matrix_Y);
                    
                else
                    %for other channel values; that is for Cb and Cr
                    %components
                    
                    %splitted energy is energy of that particular channel
                    %only
                    % EnergyCompact function is used to calculate this
                    % energy value
                    splitted_energy(:, :, ch) = splitted_energy(:, :, ch) + ...
                        EnergyCompact(temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch), n);
                    
                    %quantization of matrix is done after the matrix of DCT
                    %coeffecients is found
                    %quantization is done by dividing the matrix by the
                    %quantization matrix and rounding off to the nearest
                    %integer
                    temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch) = ...
                        round(temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch)./quantization_matrix_CbCr);
                    
                end 
                
                %zigzagscan function is applied on the data to get
                %a single stream of data
                zigzagstream(ch, 1+count*((2^n)^2):((2^n)^2)+count*((2^n)^2)) = ...
                    zigzagscan(temp_DCT_img(y:y+2^n-1, x:x+2^n-1, ch), n);
                
                
            end
            %increment the count
            count = count + 1;
        end
    end
    
    DCT_img = cast(temp_DCT_img, 'int32');
    
    %number of zeros in DCT coeffecients matrix after quantization
    num_of_zeros = sum(~DCT_img(:));
    
    %calculating average number of zeros per block which is total no of zeros divided by
    %number of blocks
    avg_num_of_zeros_per_blk = num_of_zeros/(3*count);
    
    %applying run length coding on the zigzagstream of data to further
    %compress the data
    
    %Y components of output from run length coding
    rle_Y = cast(runlengthencoding(zigzagstream(1, :)), 'int32');
    %Cb components of output from run length coding
    rle_Cb = cast(runlengthencoding(zigzagstream(2, :)), 'int32');
    %Cr components of output from run length coding
    rle_Cr = cast(runlengthencoding(zigzagstream(3, :)), 'int32');
    
end

%function creating the element of the DCT matrix value at a specific row, column place
function T = Tmatrix(x, y, n)
    %function documentation:
    %inputs:
    %x - row
    %y - column 
    %n - no of blocks into which the matrix is broken into [2^n*2^n]
    n = 2^n;
    if x == 0
        T = 1/sqrt(n);
    else
        T = sqrt(2/n)*cos(((2*y+1)*x*pi)/(2*n));
    end
end

%function to create quantization matrix used in quantization process of
%compression
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
    
    %if value of n is not 3
    if n ~= 3
        %resize the quantization matrix
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
    quantization_matrix_CbCr = floor((scaling_factor*quantization_matrix_Y + 50) ./ 100);
    quantization_matrix_CbCr(quantization_matrix_CbCr < 1) = 1;
    quantization_matrix_CbCr(quantization_matrix_CbCr > 255) = 255;
    
end

%NOT IN SCOPE OF PROJECT
%function of the zigzagscan is to put the value of data in matrix into one single array
%This is done so that the data can undergo further compression by run
%length coding and huffman encoding

% Reference
% https://stackoverflow.com/questions/3024939/matrix-zigzag-reordering
function zigzag_stream = zigzagscan(matrix, n)
    %Matrix is created of values counting from 1 to 2^n*2^n and 
    %reshaped into a matrix of 2^n by 2^n from a single array of values
    index_matrix = reshape(1:1:2^n*2^n, [2^n, 2^n]);
    %flipping this matrix and finding the diagonals is followed by flipping this 
    %matrix again to get a new index matrix
    index_matrix = fliplr(spdiags(fliplr(index_matrix)));
    index_matrix(:, 1:2:end) = index_matrix(end:-1:1, 1:2:end);
    %convert the 2D index_matrix into linear form that is single row matrix
    linear_index = index_matrix(find(index_matrix > 0));
    %get stream of data by taking the matrix value at given indexes of
    %linear_index
    zigzag_stream = matrix(linear_index);
end

%NOT IN SCOPE OF PROJECT
%function to apply run length coding on quantized image to further compress
%the image
%after zigzag scan to further compress the data runlength coding is used
function rle = runlengthencoding(stream)
    %run length coding works on the basis of grouping together same
    %consecutive values into one group
    curr_val = 0;
    prev_val = -9999;
    %initializing output array
    rle = [];
    %initial count
    count = 0;
    %for loop to go through all values of the data one by one
    for i = 1:length(stream)
        %store the value at current index as curr_value
        curr_val = stream(i);
        %check if current value is not same as previous value
        if curr_val ~= prev_val
            %set count back to one 
            count = 1;
            %if not store the value 
            rle  = [rle, 1, curr_val];
        else
            %if the value is the same as previous increment the count by 1
            count = count + 1;
            rle(end-1) = count;
        end
        %store the current value as previous value for next loop
        prev_val = curr_val;
    end
end
