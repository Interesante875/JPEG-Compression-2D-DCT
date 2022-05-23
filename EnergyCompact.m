function [Total_Energy] = EnergyCompact(DCT_img, n) 
%   funtion name: EnergyCompact
%   [Total_Energy] = EnergyCompact(DCT_img, n)
%
%   inputs:
%   DCT_img - image/coefficient block after DCT compression 
%   n - determines the no of blocks image is broken into [2^n * 2^n]
%
%   outputs:
%   Total_Energy - total energy of image after compression
%
%   The function calculates the total energy of the image after compression
%   by taking in the inputs specified above and applying the formula below

    Total_Energy = (abs(DCT_img)).^2;
    
end

