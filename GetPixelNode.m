function [ PixelNode ] = GetPixelNode( Image, Image_width, Image_length, Image_dim)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if Image_dim == 3
    PixelNode = zeros(Image_width*3,Image_length*3,3);
    PixelNode = uint8(PixelNode);
    for i = 1:Image_width
        for j = 1:Image_length
            PixelNode(3*i-1,3*j-1,:) = Image(i,j,:);
        end
    end  
else
    PixelNode = zeros(Image_width*3,Image_length*3);
    PixelNode = uint8(PixelNode);
    for i = 1:Image_width
        for j = 1:Image_length
            PixelNode(3*i-1,3*j-1) = Image(i,j);
        end
    end
end

PixelNode = uint8(PixelNode);
end

