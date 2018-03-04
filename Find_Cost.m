function [ CostGraph ] = Find_Cost( Image, Image_width, Image_length, Image_dim )
% Calculate the cost graph

original_img = Image;
Image = double(Image);

Dlink5_Filter = [0 0 0; 1/sqrt(2) 0 0; 0 -1/sqrt(2) 0];
Dlink6_Filter = [0 0 0; 1/4 0 -1/4; 1/4 0 -1/4];
Dlink7_Filter = [0 0 0; 0 0 1/sqrt(2); 0 -1/sqrt(2) 0];
Dlink0_Filter = [0 1/4 1/4; 0 0 0; 0 -1/4 -1/4];

% 
% Dlink1_Filter = [0 1/sqrt(2) 0; 0 0 -1/sqrt(2) ; 0 0 0];
% Dlink2_Filter = [1/4 0 -1/4; 1/4 0 -1/4; 0 0 0];
% Dlink3_Filter = [0 1/sqrt(2) 0; -1/sqrt(2) 0 0 ; 0 0 0];
% Dlink4_Filter = [1/4 1/4 0; 0 0 0; -1/4 -1/4 0];

if Image_dim == 3
    CostGraph_padding = zeros(Image_width*3+2,Image_length*3+2,3);
    [width,length,~] = size(CostGraph_padding);
    
    Dlink5_rgb = zeros(Image_width,Image_length,3);
    Dlink6_rgb = zeros(Image_width,Image_length,3);
    Dlink7_rgb = zeros(Image_width,Image_length,3);
    Dlink0_rgb = zeros(Image_width,Image_length,3);
%     
%     Dlink1_i_rgb = zeros(Image_width,1,3);
%     Dlink1_j_rgb = zeros(1,Image_length,3);
%     Dlink2_rgb = zeros(1,Image_length,3);
%     Dlink3_i_rgb = zeros(Image_width,1,3);
%     Dlink3_j_rgb = zeros(1,Image_length,3);
%     Dlink4_rgb = zeros(Image_width,1,3);

    Dlink5_rgb(:,:,:) = abs(imfilter(Image(:,:,:),Dlink5_Filter));
    Dlink6_rgb(:,:,:) = abs(imfilter(Image(:,:,:),Dlink6_Filter));
    Dlink7_rgb(:,:,:) = abs(imfilter(Image(:,:,:),Dlink7_Filter));
    Dlink0_rgb(:,:,:) = abs(imfilter(Image(:,:,:),Dlink0_Filter));
    
%     Dlink1_i_rgb(:,:,:) = abs(imfilter(Image(:,Image_length,:),Dlink1_Filter));
%     Dlink1_j_rgb(:,:,:) = abs(imfilter(Image(1,:,:),Dlink1_Filter));
%     Dlink2_rgb(:,:,:) = abs(imfilter(Image(1,:,:),Dlink2_Filter));
%     Dlink3_i_rgb(:,:,:) = abs(imfilter(Image(:,1,:),Dlink3_Filter));
%     Dlink3_j_rgb(:,:,:) = abs(imfilter(Image(1,:,:),Dlink3_Filter));
%     Dlink4_rgb(:,:,:) = abs(imfilter(Image(:,1,:),Dlink4_Filter));
    
    Dlink5 = sqrt((Dlink5_rgb(:,:,1).^2+Dlink5_rgb(:,:,2).^2+Dlink5_rgb(:,:,3).^2)/3);
    Dlink6 = sqrt((Dlink6_rgb(:,:,1).^2+Dlink6_rgb(:,:,2).^2+Dlink6_rgb(:,:,3).^2)/3);
    Dlink7 = sqrt((Dlink7_rgb(:,:,1).^2+Dlink7_rgb(:,:,2).^2+Dlink7_rgb(:,:,3).^2)/3);
    Dlink0 = sqrt((Dlink0_rgb(:,:,1).^2+Dlink0_rgb(:,:,2).^2+Dlink0_rgb(:,:,3).^2)/3);
    
%     Dlink1_i = sqrt((Dlink1_i_rgb(:,:,1).^2+Dlink1_i_rgb(:,:,2).^2+Dlink1_i_rgb(:,:,3).^2)/3);
%     Dlink1_j = sqrt((Dlink1_j_rgb(:,:,1).^2+Dlink1_j_rgb(:,:,2).^2+Dlink1_j_rgb(:,:,3).^2)/3);
%     Dlink2 = sqrt((Dlink2_rgb(:,:,1).^2+Dlink2_rgb(:,:,2).^2+Dlink2_rgb(:,:,3).^2)/3);
%     Dlink3_i = sqrt((Dlink3_i_rgb(:,:,1).^2+Dlink3_i_rgb(:,:,2).^2+Dlink3_i_rgb(:,:,3).^2)/3);
%     Dlink3_j = sqrt((Dlink3_j_rgb(:,:,1).^2+Dlink3_j_rgb(:,:,2).^2+Dlink3_j_rgb(:,:,3).^2)/3);
%     Dlink4 = sqrt((Dlink4_rgb(:,:,1).^2+Dlink4_rgb(:,:,2).^2+Dlink4_rgb(:,:,3).^2)/3);
    
    maxD = max([max(Dlink5(:)) max(Dlink6(:)) max(Dlink7(:)) max(Dlink0(:))]);
    
    for i = 1:Image_width
        for j = 1:Image_length
            CostGraph_padding(3*i,3*j,:) = original_img(i,j,:);
            
            CostGraph_padding(3*i+1,3*j-1,:) = (maxD-Dlink5(i,j))*sqrt(2);
            CostGraph_padding(3*i+2,3*j-2,:) = CostGraph_padding(3*i+1,3*j-1,:);
            
            CostGraph_padding(3*i+1,3*j,:) = (maxD-Dlink6(i,j));
            CostGraph_padding(3*i+2,3*j,:) = CostGraph_padding(3*i+1,3*j,:);
            
            CostGraph_padding(3*i+1,3*j+1,:) = (maxD-Dlink7(i,j))*sqrt(2);
            CostGraph_padding(3*i+2,3*j+2,:) = CostGraph_padding(3*i+1,3*j+1,:);
            
            CostGraph_padding(3*i,3*j+1,:) = (maxD-Dlink0(i,j));
            CostGraph_padding(3*i,3*j+2,:) = CostGraph_padding(3*i,3*j+1,:);
        end
    end
    
%     for i = 1:Image_width
%         CostGraph_padding(3*i,2,:) = maxD-Dlink4(i);
%         CostGraph_padding(3*i-1,2,:) =  (maxD-Dlink3_i(i))*sqrt(2);
%         CostGraph_padding(3*i-1,3*Image_length+1,:) = (maxD-Dlink1_i(i))*sqrt(2);
%     end
%     
%     for j = 1:Image_length
%         CostGraph_padding(2,3*j-1,:) =  (maxD-Dlink3_j(j))*sqrt(2);
%         CostGraph_padding(2,3*j,:) =  maxD-Dlink2(j);
%         CostGraph_padding(2,3*j+1,:) =  (maxD-Dlink1_j(j))*sqrt(2);
%     end
    
%     CostGraph_padding(:,2:3,:) = 255;
%     CostGraph_padding(:,Image_length*3:Image_length*3+1,:) = 255;
%     CostGraph_padding(2:3,:,:) = 255;
%     CostGraph_padding(Image_width*3:Image_width*3+1,:,:) = 255;
    
%     CostGraph = CostGraph_padding(2:width-1,2:length-1,:);
    
    CostGraph = CostGraph_padding(2:width-1,2:length-1,:);
    
    CostGraph_Mid = ones(size(CostGraph))*255;
    CostGraph_Mid(3:end-2,3:end-2,:) = CostGraph(3:end-2,3:end-2,:);
    CostGraph = CostGraph_Mid;
    
else
    CostGraph_padding = zeros(Image_width*3+2,Image_length*3+2);
    [width,length] = size(CostGraph_padding);
    
    Dlink5 = abs(imfilter(Image,Dlink5_Filter));
    Dlink6 = abs(imfilter(Image,Dlink6_Filter));
    Dlink7 = abs(imfilter(Image,Dlink7_Filter));
    Dlink0 = abs(imfilter(Image,Dlink0_Filter));
    
%     Dlink1_i = abs(imfilter(Image(:,Image_length),Dlink1_Filter));
%     Dlink1_j = abs(imfilter(Image(1,:),Dlink1_Filter));
%     Dlink2 = abs(imfilter(Image(1,:),Dlink2_Filter));
%     Dlink3_i = abs(imfilter(Image(:,1),Dlink3_Filter));
%     Dlink3_j = abs(imfilter(Image(1,:),Dlink3_Filter));
%     Dlink4 = abs(imfilter(Image(:,1),Dlink4_Filter));
    
    maxD = max([max(Dlink5(:)) max(Dlink6(:)) max(Dlink7(:)) max(Dlink0(:))]);
    
    for i = 1:Image_width
        for j = 1:Image_length
            
            CostGraph_padding(3*i,3*j) = original_img(i,j);
            
            CostGraph_padding(3*i+1,3*j-1) = (maxD-Dlink5(i,j))*sqrt(2);
            CostGraph_padding(3*i+2,3*j-2) = CostGraph_padding(3*i+1,3*j-1);
            
            CostGraph_padding(3*i+1,3*j) = (maxD-Dlink6(i,j));
            CostGraph_padding(3*i+2,3*j) = CostGraph_padding(3*i+1,3*j);
            
            CostGraph_padding(3*i+1,3*j+1) = (maxD-Dlink7(i,j))*sqrt(2);
            CostGraph_padding(3*i+2,3*j+2) = CostGraph_padding(3*i+1,3*j+1);
            
            CostGraph_padding(3*i,3*j+1) = (maxD-Dlink0(i,j));
            CostGraph_padding(3*i,3*j+2) = CostGraph_padding(3*i,3*j+1);
        end
    end
    
%     for i = 1:Image_width
%         CostGraph_padding(3*i,2) =  (maxD-Dlink4(i));
%         CostGraph_padding(3*i-1,2) =  (maxD-Dlink3_i(i))*sqrt(2);
%         CostGraph_padding(3*i-1,3*Image_length+1) =  (maxD-Dlink1_i(i))*sqrt(2);
%     end
%     
%     for j = 1:Image_length
%         CostGraph_padding(2,3*j-1) =  (maxD-Dlink3_j(j))*sqrt(2);
%         CostGraph_padding(2,3*j) =  maxD-Dlink2(j);
%         CostGraph_padding(2,3*j+1) =  (maxD-Dlink1_j(j))*sqrt(2);
%     end   

%     CostGraph_padding(:,2:3) = 255;
%     CostGraph_padding(:,Image_length*3:Image_length*3+1) = 255;
%     CostGraph_padding(2:3,:) = 255;
%     CostGraph_padding(Image_width*3:Image_width*3+1,:) = 255;
    CostGraph = CostGraph_padding(2:width-1,2:length-1);
    
    CostGraph_Mid = ones(size(CostGraph))*255;
    CostGraph_Mid(3:end-2,3:end-2) = CostGraph(3:end-2,3:end-2);
    CostGraph = CostGraph_Mid;
end

%CostGraph = uint8(CostGraph);
%CostGraph = double(CostGraph);
end

