%% File Information 
% Project Title: Image Coding
% Group Number: Project Group 10
% Group Member: 
% 1) (Izaac) Chong Yen Juin
% 2) Ho Jun Ming
% 3) Nitya 
% File Author: (Izaac) Chong Yen Juin
% Checked: Nitya Yogendra Kaushik
% Date: 10th May 2022
%-----------------------------------------------------------------%

%% File Dependencies


%-----------------------------------------------------------------%
%% Demonstration
% The purpose of this file is to demonstrate the effects of compressing and 
% decompressing image using 2D Discrete Cosine Transform on 'Hummingbird.jpg' 
% and 'Waterboat.jpg' with different quality factors

% Waterboat.jpg is a large file, and it takes more time to process
%%
clearvars -except input_img;
close all;
clc;

%% Demonstrating Quality of Picture affected by quantizing high frequency components

%name of image used by user
image_name = 'Hummingbird.jpg';
%read image and store into matlab
input_img = imread(image_name);
%find size of the image 
[height, width, channel] = size(input_img);

%array of quality factor we will be using to compare effect of different
%quality factors on image
quality_factor = [5 10 50 80];

%for this comparison we have assumed a block size of 8*8[2^n * 2^n] thus n = 3
n = 3;

%display the inital image: HummingBird.jpg
title_str = sprintf("Original Image %s", image_name);

%create new figure
figure(1);
imshow(input_img, 'InitialMagnification', 'fit');
title(title_str);

%for loop going through each quality factor one by one
for j = 1:length(quality_factor)
    
    %finding the DCT of image for quality factor based on index of for loop
    %using DiscreteCosineTransform2D function
    [DCT_img, ycbcr_img, new_width, new_height, new_channel, ~, ...
        ~, ~, ~, ~, ~, ~, ~] = ...
    DiscreteCosineTransform2D(input_img, n, quality_factor(j));
    
    %taking out the Y,Cb,Cr components from the compressed image
    Y = round(DCT_img(:, :, 1));
    Cb = round(DCT_img(:, :, 2));
    Cr = round(DCT_img(:, :, 3));
    
    %taking the inverse DCT to get the decompressed image from the
    %compressed image form using InverseDiscreteCosineTransform2D function
    [Decompressed_YCBCR_img, RGB_img] = ...
        InverseDiscreteCosineTransform2D(DCT_img, n, quality_factor(j), ...
        new_width, new_height, new_channel);

    %final output image after decompression of compressed of original image
    title_str = "Decompressed RGB Image";
    title_str = sprintf("%s with Quality Factor = %d", ...
        title_str, quality_factor(j));
    
    %create new figure
    figure(2);
    %subplots: each subplot showing the output decompressed image for different quality factor
    subplot(2,2,j);
    imshow(RGB_img, 'InitialMagnification', 'fit');
    title(title_str);

end

%% Demonstrating Compression of Run Length Encoding
% Uncomment to see results, takes a long time to run
% %name of image used by user
% image_name = 'Hummingbird.jpg';
% %read image and store in matlab
% input_img = imread(image_name);
% %finding size of the image
% [height, width, channel] = size(input_img);
% 
% %range of quality factor used in analysis
% quality_factor = 5:5:100;
% %size of blocks used ranges from 4*4 to 256*256 - [2^n * 2^n]
% n = 2:1:8;
% 
% %initialize matrix to store length of run length code for different n value
% %and quality factor
% 
% %values in same row have same n value and in one column have same quality
% %factor
% %initialize matrix to store the length of run length code
% length_of_run_length_code = zeros(length(n), length(quality_factor));
% 
% %check if data present in length of run length code data file
% if isfile('length_of_run_length_code.mat') 
%     %if present store value in matrix initialized before
%     length_of_run_length_code = importdata('length_of_run_length_code.mat');
%     
% else
%     %if not calculate the value and store in matrix
%     %for loop going through values of n one by one
%     for i = 1:length(n)
%         %for loop for different values of quality factor
%         for j = 1:length(quality_factor)
%             
%             %find the length of run length code values of Y,Cb,Cr component for different
%             %n and quality factor values using DiscreteCosineTransform2D
%             %function
%             [~, ~, ~, ~, ~, ~, rle_Y, rle_Cb, rle_Cr, ~, ~, ~, ~] = ...
%             DiscreteCosineTransform2D(input_img, n(i), quality_factor(j));
%         
%             %total length = sum of length of Y,Cb,Cr components
%             %store value of sum in matrix initialized before
%             length_of_run_length_code(i, j) = length(rle_Y) + ...
%                 length(rle_Cb) + length(rle_Cr);
%         end
%     end
% end
% 
% %calculating ratio of length of run length code
% length_of_run_length_code_ratio = length_of_run_length_code/(height...
%     *width*channel);
% 
% %plotting the toal length of run length code length vs quality factor for
% %different values of n
% 
% %create new figure
% figure(17);
% plot(quality_factor, length_of_run_length_code, 'LineWidth',2);
% xlabel('Quality Factor');
% ylabel('Total length of the run length encoding code');
% legend('n=2', 'n=3', 'n=4', 'n=5', 'n=6', 'n=7', 'n=8');
% title('Total length of the run length encoding code vs Quality Factor');
% 
% %plotting the length of run length code ratio vs the quality factor for
% %different n values
% %to observe the compression it undergoes with the change in quality factor
% 
% %create new figure
% figure(18);
% plot(quality_factor, length_of_run_length_code_ratio, 'LineWidth',2);
% xlabel('Quality Factor');
% ylabel('Compression Ratio (%)');
% legend('n=2', 'n=3', 'n=4', 'n=5', 'n=6', 'n=7', 'n=8');
% title('Compression Ratio vs Quality Factor');

%% Demonstrating Compression by Huffman Coding & Entropies of Image

%name of image used by user
image_name = 'Hummingbird.jpg';
%read image and store in matlab
input_img = imread(image_name);
%finding size of the image
[height, width, channel] = size(input_img);

%range of quality factor used in analysis
quality_factor = 10:10:70;
%size of blocks used ranges from 4*4 to 256*256 - [2^n * 2^n]
n = 3;

% Initialization of variables
all_compression_ratio = zeros(length(n), length(quality_factor));
all_entropy_after_decompression = zeros(length(n), length(quality_factor));

% Entropy Before Compression
% Uses YCbCr instead because each channel is spectrally decorrelated from
% one another
Entropy_Before_Compression = entropy(rgb2ycbcr(input_img));
fprintf("The entropy before compression is %f bits/pixel\n", ...
    Entropy_Before_Compression);

%if data files exists
if isfile('all_compression_ratio.mat') & ...
   isfile('all_entropy_after_decompression.mat')

    %store the data in these data file into the matrix intialized before
    all_compression_ratio = importdata('all_compression_ratio.mat');
    all_entropy_after_decompression = importdata('all_entropy_after_decompression.mat');
    
else
%for loop going through each size of DCT blocks
    for i = 1:length(n)
        %for loop going through each quality factor one by one
        for j = 1:length(quality_factor)

            %finding the DCT of image for quality factor based on index of for loop
            %using DiscreteCosineTransform2D function
            [DCT_img, ycbcr_img, new_width, new_height, new_channel, ~, ...
                ~, ~, ~, ~, ~, ~, ~] = ...
            DiscreteCosineTransform2D(input_img, n(i), quality_factor(j));


            %taking the inverse DCT to get the decompressed image from the
            %compressed image form using InverseDiscreteCosineTransform2D function
            [Decompressed_YCBCR_img, RGB_img] = ...
                InverseDiscreteCosineTransform2D(DCT_img, n(i), quality_factor(j), ...
                new_width, new_height, new_channel);

            flatten_coeff_matrix = DCT_img(:);

            % Obtain all unique levels 
            pixels_level = unique(flatten_coeff_matrix);

            % Compute relative frequencies (probability) of those unique levels
            relative_frequency = histcounts(flatten_coeff_matrix,...
                length(pixels_level))/length(flatten_coeff_matrix);

            % compute a dictionary of unique levels to codes
            dict = huffmandict(pixels_level, relative_frequency);

            % Perform huffman coding 
            encoding_stream = huffmanenco(flatten_coeff_matrix, dict);

            % Calculate the bit length of the huffman coded image
            Huffman_Enco_Length = length(encoding_stream);

            % Calculate the entropy of the decompressed YCbCr image
            After_entropy = entropy(Decompressed_YCBCR_img(:));

            % Calculate the compession ratio of the image
            Compression_ratio = ...
                Huffman_Enco_Length/(new_width* new_height*new_channel*8);

            all_compression_ratio(i,j) = Compression_ratio;
            all_entropy_after_decompression(i,j) = After_entropy;
        end
    end
end
% plotting the compression ratio vs the quality factor for
% different n values
% to observe the compression ratio with the change in quality factor
%create new figure
figure(20);
plot(quality_factor, all_compression_ratio, 'LineWidth',2);
xlabel('Quality Factor');
ylabel('Compression Ratio (%)');
legend('n=3');
title('Compression Ratio vs Quality Factor using Huffman Coding');

% plotting the Entropy vs the quality factor for
% different n values
% to observe the Entropy with the change in quality factor
%create new figure
figure(21);
plot(quality_factor, all_entropy_after_decompression, 'LineWidth',2);
xlabel('Quality Factor');
ylabel('Entropy (bits/pixel)');
legend('n=3');
title('Entropy vs Quality Factor using Huffman Coding');