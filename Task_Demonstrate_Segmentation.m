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
% The purpose of this file is to demonstrate the effects of 'n' on image
% coding 2D Discrete Cosine Transform on 'Hummingbird.jpg' 
% and 'Waterboat.jpg' with different sizes of DCT matrix
% Overall, there is a trade-off between computation time and the blockiness
% of the decompressed image
% Waterboat.jpg is a large file, and it takes more time to process

%% Visual Artifacts - Blockiness as n increases
clearvars -except input_img;
close all;
clc;

%name of inital image used by user
image_name = 'Hummingbird.jpg';
%read image and storing in matlab
input_img = imread(image_name);
%find size of the image
[height, width, channel] = size(input_img);

%quality factors used by us
%using 5 gives us lower quality in comparison to using 50 as quality factor
quality_factor = [5 50];

%value of n that defines the block size used [2^n * 2^n]
%therefore the block size used ranges from [8*8,32*32,64*64,128*128,256*256]
n = [3, 5, 6, 7, 8];

%display initial image before compression 
title_str = sprintf("Original Image %s", image_name);
figure(1);
imshow(input_img, 'InitialMagnification', 'fit');
title(title_str);

%for loop to go through each value of n one by one
for j = 1:length(n)
    
    %for quality factor = 5
    %calculating compressed image by using DiscreteCosineTransform2D function.
    [DCT_img_lower_quality, ~, new_width, new_height, new_channel, ~, ...
        ~, ~, ~, ~, ~, ~, ~] = ...
    DiscreteCosineTransform2D(input_img, n(j), quality_factor(1));
    %getting the decmopressed image using InverseDiscreteCosineTransform2D
    %function.
    [~, RGB_img_lower_quality] = ...
        InverseDiscreteCosineTransform2D(DCT_img_lower_quality, ...
        n(j), quality_factor(1), new_width, new_height, new_channel);
    
    
    %for quality factor = 50
    %calculating compressed image using DiscreteCosineTransform2D function.
    [DCT_img_higher_quality, ~, new_width, new_height, new_channel, ~, ...
        ~, ~, ~, ~, ~, ~, ~] = ...
    DiscreteCosineTransform2D(input_img, n(j), quality_factor(2));
    %getting the decmopressed image using InverseDiscreteCosineTransform2D function
    [~, RGB_img_higher_quality] = ...
        InverseDiscreteCosineTransform2D(DCT_img_higher_quality, ...
        n(j), quality_factor(2), new_width, new_height, new_channel);
    
    %displaying different figures showing effect of change of quality factor for
    %different n value
    title_str = "Decompressed RGB Image";
    title_str = sprintf("%s with n = %d; QF_{left}=5, QF_{right}=50 ", ...
        title_str, n(j));
    %create new figure for each n value and display image comparison of
    %decompressed image after initial compression
    figure(2 + j);
    montage({RGB_img_lower_quality, RGB_img_higher_quality});
    title(title_str);
end


%% relationship between n and time

%name of image used by user
image_name = 'Hummingbird.jpg';
%read image and store in MATLAB
input_img = imread(image_name);
%find size of the image
[height, width, channel] = size(input_img);

%quality factor used in quantization of image for compression
quality_factor = 50;
%range of n values used which defines the no of blocks image is broken into [2^n *2^n]
%thus number of blocks = [8*8,32*32,64*64,128*128,256*256]
n = [3, 4, 6, 8];

%initialize the array storing the time taken by different n values for the full process of compression
%followed by decompression
time_taken = zeros(1, length(n));

%for loop going through each n value one by one so we can compare the time
%taken 
for j = 1:length(n)
    
    %start timer
    tStart = tic;
    
    %using the DiscreteCosineTransform2D function to do the compression of
    %image
    [DCT_img, ~, new_width, new_height, new_channel, ~, ...
        ~, ~, ~, ~, ~, ~, ~] = ...
    DiscreteCosineTransform2D(input_img, n(j), quality_factor);

    %using the InverseDiscreteCosineTransform2D function for decompression
    %of compressed image
    [~, RGB_img] = ...
        InverseDiscreteCosineTransform2D(DCT_img, n(j), quality_factor, ...
        new_width, new_height, new_channel);
    %this completes the process
    
    %read the timer and save value in array intialized before
    time_taken(j) = toc(tStart);
end

%plot the time taken for the entire process for different n values vs the width of DCT matrix[2^n]
%create new figure
figure(8);
plot(2.^(n), time_taken, 'LineWidth', 2);
title("Time taken to compute DCT and iDCT for QF=50");
xlabel("width of DCT matrix, 2^n (pixel)");
ylabel("Time taken (s)");