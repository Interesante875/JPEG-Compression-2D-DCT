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
% The purpose of this file is to demonstrate the DCT respresentation of
% images and the energy compactness of luminance and chrominance components


%% Energy Compactness and DCT respresentation of image
clearvars -except input_img;
close all;
clc;

%name of inital image used by user
image_name = 'Hummingbird.jpg';
%read image and store in matlab
input_img = imread(image_name);
%size of the image
[height, width, channel] = size(input_img);

%quality factor used in quantization - Q50
quality_factor = 50;
% no of blocks into which image is broken into[2^n * 2^n]
n = 3;

%calculating compressed form of image,total energy and splitted energy using
%DiscreteCosineTransform2D function
[DCT_img, ~, new_width, new_height, new_channel, ~, ...
    ~, ~, ~, ~, ~, total_energy, splitted_energy] = ...
    DiscreteCosineTransform2D(input_img, n, quality_factor);

%create new figure
figure(9);

%subplot 1: plotting the distribution of total energy in image
subplot(2,2,1);
imshow(10*log(total_energy./max(max(total_energy))), []);
colormap parula;
colorbar;
title("Total Energy (dB) of the 2D DCT basis");

%subplot 2: plotting the energy distribution of the Luminance component(Y)
%of image
%Y component of energy distribution is in the channel 1 of the splitted energy values
subplot(2,2,2);
imshow(10*log(splitted_energy(:, :, 1)./max(max(splitted_energy(:, :, 1)))), []);
colormap parula;
colorbar;
title("Luminance Component Energy (dB) of the 2D DCT basis");

%subplot 3: plotting the energy distribution of the Cb(blue chroma)
%component of image
%Cb component of energy distribution is in the channel 2 of the splitted energy values
subplot(2,2,3);
imshow(10*log(splitted_energy(:, :, 2)./max(max(splitted_energy(:, :, 2)))), []);
colormap parula;
colorbar;
title("Blue Chrominance Energy (dB) of the 2D DCT basis");

%subplot 4: plotting the energy distribution of the Cr(red chroma)
%component of image
%Cr component of energy distribution is in the channel 3 of the splitted energy values
subplot(2,2,4);
imshow(10*log(splitted_energy(:, :, 3)./max(max(splitted_energy(:, :, 3)))), []);
colormap parula;
colorbar;
title("Red Chrominance Energy (dB) of the 2D DCT basis");


Y = DCT_img(:, :, 1); %Y compoment of DCT of the image
Cb = DCT_img(:, :, 2); % Cb component of DCT of the image
Cr = DCT_img(:, :, 3); %Cr component of DCT of the image

%create new figure
figure(10);

%first subplot to plot the Y component of DCT_image
subplot(2,2,1);
imshow(Y, []);
title("DCT: Y-component");
%second subplot to plot the Cb component of DCT_image
subplot(2,2,2);
imshow(Cb, []);
title("DCT: Cb-component");
%third subplot to plot the Cr component of DCT_image
subplot(2,2,3);
imshow(Cr, []);
title("DCT: Cr-component");
%fourth subplot to plot the initial input image
subplot(2,2,4);
imshow(input_img);
title("Original image");
