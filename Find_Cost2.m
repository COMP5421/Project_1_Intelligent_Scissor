function [ CostGraph ] = Find_Cost2(Image, Image_width, Image_length, Image_dim )
%   Laplacian of Gaussian Filters
original_img = Image;

W_Z = 0.45;
W_G = 0.55;

if Image_dim == 3
    Image = rgb2gray(Image);
end

f_z = 1 - edge(Image, 'zerocross');

[G,~] = imgradient(double(Image));
maxG = max(max(G));
f_G = 1 - G/maxG;


CostGraph_padding = zeros(Image_width*3+2,Image_length*3+2,3);
[width,length,~] = size(CostGraph_padding);
for i = 1:Image_width
        for j = 1:Image_length
            CostGraph_padding(3*i,3*j,:) = original_img(i,j,:);
            
            CostGraph_padding(3*i+1,3*j-1,:) = W_Z*f_z(i,j) + W_G*f_G(i,j);
            CostGraph_padding(3*i+2,3*j-2,:) = CostGraph_padding(3*i+1,3*j-1,:);
            
            CostGraph_padding(3*i+1,3*j,:) = W_Z*f_z(i,j) + W_G*f_G(i,j)/sqrt(2);
            CostGraph_padding(3*i+2,3*j,:) = CostGraph_padding(3*i+1,3*j,:);
            
            CostGraph_padding(3*i+1,3*j+1,:) = CostGraph_padding(3*i+1,3*j-1,:);
            CostGraph_padding(3*i+2,3*j+2,:) = CostGraph_padding(3*i+1,3*j+1,:);
            
            CostGraph_padding(3*i,3*j+1,:) = CostGraph_padding(3*i+1,3*j,:);
            CostGraph_padding(3*i,3*j+2,:) = CostGraph_padding(3*i,3*j+1,:);
        end
end

CostGraph = CostGraph_padding(2:width-1,2:length-1,:);

CostGraph_Mid = ones(size(CostGraph))*255;
CostGraph_Mid(3:end-2,3:end-2,:) = CostGraph(3:end-2,3:end-2,:);
CostGraph = CostGraph_Mid;
end




