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
% The purpose of this file is to demonstrate the relationship between 
% quality factor and the number of zeros per block; then, the number of 
% zeros per block is shown to affect sum squared error between the decompressed
% image and the original image

% Warning: This file would take a long time to run because it is
% computationally intensive
% Run each secton one by one
% Waterboat.jpg is a large file, and it takes more time to process
%%
clearvars -except input_img;
close all;
clc;

%% Demonstrating Effects of Quality Factor on Avg. Num of Zeroes Per Block

%name of image used by user 
image_name = 'Hummingbird.jpg';
%read image and store in MATLAB
input_img = imread(image_name);
%find size of image
[height, width, channel] = size(input_img);

%range of quality factor used in comparison of number of zeros
quality_factor = 5:5:100;

%no of blocks image is broken into [2^n*2^n]
%default value of n is taken as 3 that is number of blocks is 8*8
n = 3;

%initialize array to store the average number of zeros per block for
%different quality factor
all_avg_num_of_zeros_per_blk = zeros(1,length(quality_factor));

%for loop to go through quality factors one by one
for j = 1:length(quality_factor)
    
    %finding the average number of zeros per block
    %for the value of quality factor using DiscreteCosineTransform2D function
    [DCT_img, ~, new_width, new_height, new_channel, ~, ...
    ~, ~, ~, num_of_zeros, avg_num_of_zeros_per_blk, ~, ~] = ...
    DiscreteCosineTransform2D(input_img, n, quality_factor(j));

    %save values of avg_num_of_zeros_per_blk from above output that is 
    %average number of zeroes per block after
    %quantization for different values of quality factor into the array
    %initialized before
    all_avg_num_of_zeros_per_blk(j) = avg_num_of_zeros_per_blk;
    
end

%plot the average number of zeros per block vs the value of quality factor

%create new figure
figure(11);
plot(quality_factor, all_avg_num_of_zeros_per_blk, 'LineWidth',2);
grid on;
xlabel("Quality Factor");
ylabel(" Average Number of zeros per block");
title("Average Number of zeros per block vs Quality Factor");

%% Demonstrating Effects of n on Avg. Num of Zeroes Per Block

%name of image used by user
image_name = 'Hummingbird.jpg';
%read image and store in MATLAB
input_img = imread(image_name);
%size of the image
[height, width, channel] = size(input_img);

%defualt quality factor of 50 is used to compare the number of zeroes per
%block for different value of n
quality_factor = 50;

%different values of n are used that is number of blocks the image is broken
%into changes[2^n * 2^n]
n = 1:1:8;

%initialize matrix to store average number of zeros per block for
%different values of n
all_avg_num_of_zeros_per_blk = zeros(1,length(n));

%for loop to go through each value of n one by one
for j = 1:length(n)
    
    %calculate the average number of zeroes per block for the value of
    %n using DiscreteCosineTransform2D function 
    [DCT_img, ~, new_width, new_height, new_channel, ~, ...
    ~, ~, ~, num_of_zeros, avg_num_of_zeros_per_blk, ~, ~] = ...
    DiscreteCosineTransform2D(input_img, n(j), quality_factor);

    %save values of avg_num_of_zeros_per_blk that is average number of zeroes per block after
    %quantization for different values of n [blocks into which image is broken
    %into = 2^n *2^n] into the array initialized before
    all_avg_num_of_zeros_per_blk(j) = avg_num_of_zeros_per_blk;
    
end

%plot the average number of zeroes per block vs the value of n which shows
%us the number of blocks image is broken into [2^n * 2^n]

%create new figure
figure(12);
%the value of the average number of zeroes per block is plotted in the log
%scale
plot(n, log10(all_avg_num_of_zeros_per_blk), 'LineWidth',2);
grid on;
xlabel("n");
ylabel("Log-scale Average Number of zeros per block");
title("Log-scale Average Number of zeros per block vs n");

%% Demonstrating Effects of Avg. Num of Zeroes Per Block on SSE, MSE and PSNR

%name of image used by user
image_name = 'Hummingbird.jpg';
%read image and store value in MATLAB
input_img = imread(image_name);
%size of the image
[height, width, channel] = size(input_img);

%range of quality factors used in analysis
quality_factor = 5:5:100;
%range of n values used in analysis which defines the number of blocks
%image is broken into [2^n * 2^n]
n = 2:1:5;

%initialize an array which stores average number of zeroes per block firstly for different 
%values of n row wise and then for different values of quality factor
%column wise

%that is values in same row have same n value and different quality factor
%depending on the column in which they are

all_avg_num_of_zeros_per_blk = zeros(length(n),length(quality_factor));

%initialize matrix to store MSE[mean square error] value for different n values
%and different quality factor
all_MSE = zeros(length(n),length(quality_factor));

%initialize matrix to store PSNR[signal to noise ratio] value for different n values 
%and different quality factor
all_PSNR = zeros(length(n),length(quality_factor));

%initialize matrix to store SSE[sum squared error] value for different n values
%and different quality factor
all_SSE = zeros(length(n),length(quality_factor));

%if values exist in data files storing the average number of zeroes per
%block, MSE value and PSNR value
if isfile('all_avg_num_of_zeros_per_blk.mat') & ...
   isfile('all_PSNR.mat') & ...
   isfile('all_MSE.mat') & ...
   isfile('all_SSE.mat')

    %store the data in these data file into the matrix intialized before
    all_avg_num_of_zeros_per_blk = importdata('all_avg_num_of_zeros_per_blk.mat');
    all_PSNR = importdata('all_PSNR.mat');
    all_MSE = importdata('all_MSE.mat');
    all_SSE = importdata('all_SSE.mat');
else
    %if no data is present in these files calculate the values
    
    %for loop to go through different values of n one by one
    for i = 1:length(n)
        %for loop to go through different values of qualityfactor one by
        %one
        for j = 1:length(quality_factor)

            %calculating the new_height,new_width,new_channel and DCT image 
            %using DiscreteCosineTransform2D function
            %for further calculation of average number of zeros per block, mean square
            %error and peak signal to noise ratio 
            [DCT_img, ~, new_width, new_height, new_channel, ~, ...
            ~, ~, ~, num_of_zeros, avg_num_of_zeros_per_blk, ~, ~] = ...
            DiscreteCosineTransform2D(input_img, n(i), quality_factor(j));
            
            %taking the inverse DCT to get the decompressed
            %image[RGB_img]using InverseDiscreteCosineTransform2D function
            [~, RGB_img] = InverseDiscreteCosineTransform2D(DCT_img, n(i), ...
                quality_factor(j), new_width, new_height, new_channel);
            
            %calculating the value of mean square error 
            %mean square error[MSE] = (1/(no of pixels)) * (summation(original - decompressed)^2)
            SSE = sum(abs(RGB_img - imresize(input_img, ...
                [new_height, new_width])).^2, 'all');
            MSE = 1/(new_height*new_width*new_channel)*SSE;
            
            %calculating signal to noise ratio
            %PSNR = 20*log10(255 / square root of MSE)
            PSNR = 20 * log10(255/sqrt(MSE));

            %store value of SSE, MSE,PSNR and average number of zeros per block
            %into the matrix initalized before
            all_SSE(i, j) = SSE;
            all_MSE(i, j) = MSE;
            all_PSNR(i, j) = PSNR;
            all_avg_num_of_zeros_per_blk(i, j) = avg_num_of_zeros_per_blk;
        end
    end
end

%plot the mean square error vs the number of zeros per block

%to plot this graph for a different value of n just need to edit the plot
%line to include the index of n value for which plot is required

%create new figure
figure(13);
%plot for n = 3
plot(all_avg_num_of_zeros_per_blk(2,:), all_MSE(2,:), 'LineWidth',2);
grid on;
xlabel("Average Number of zeros per block");
ylabel("Mean Square Error");
title("Mean Square Error vs Average Number of zeros per block with n= 3");

%plotting the mean square error vs quality factor
%for different values of n

%create new figure
figure(14);
plot(quality_factor, all_MSE, 'LineWidth',2);
grid on;
xlabel("Quality Factor");
ylabel("Mean Square Error");
title("Mean Square Error vs Quality Factor");
legend('n=2', 'n=3', 'n=4', 'n=5');

%plotting the peak signal to noise ratio vs the average number of zeros
%per block

%to plot this graph for a different value of n just need to edit the plot
%line to include the index of n value for which plot is required

%create new figure
figure(15);
%plot for n = 3
plot(all_avg_num_of_zeros_per_blk(2,:), all_PSNR(2,:), 'LineWidth',2);
grid on;
xlabel("Average Number of zeros per block");
ylabel("Peak Signal-to-Noise Ratio (dB)");
title("Peak Signal-to-Noise Ratio vs Average Number of zeros per block with n =3");

%plotting the peak signal to ratio vs the quality factor 
%for different values of n 

%create new figure
figure(16);
plot(quality_factor, all_PSNR, 'LineWidth',2);
grid on;
xlabel("Quality Factor");
ylabel("Peak Signal-to-Noise Ratio (dB)");
title("Peak Signal-to-Noise Ratio vs Quality Factor");
legend('n=2', 'n=3', 'n=4', 'n=5');

%plotting the Sum Squared Error to Average Num of zeros per block
%for n = 3
figure(19);
plot(all_avg_num_of_zeros_per_blk(2,:), all_SSE(2,:), 'LineWidth',2);
grid on;
xlabel("Average Number of zeros per block");
ylabel("Sum Squared Error");
title("Sum Squared Error vs Average Number of zeros per block");

%plotting the Sum Squared Error to quality factors

figure(20);
semilogy(quality_factor, all_SSE', 'LineWidth',2);
grid on;
xlabel("Quality Factor");
ylabel("Sum Squared Error");
title("Sum Squared Error vs Quality Factor");
legend('n=2', 'n=3', 'n=4', 'n=5');