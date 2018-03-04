function [ BluredImage, BluredCostGraph ] = Blurimage(image,width,length,dim,choice,costfunction)
%  Blur image using gaussian filter
if dim == 3
    BluredImage = zeros(width,length,3);
    switch choice
        case 'No Blur Effect'
            BluredImage = image;
        case 'Blur Sigma: 2'
            BluredImage(:,:,1) = imgaussfilt(image(:,:,1),2);
            BluredImage(:,:,2) = imgaussfilt(image(:,:,2),2);
            BluredImage(:,:,3) = imgaussfilt(image(:,:,3),2);    
        case 'Blur Sigma: 4'
            BluredImage(:,:,1) = imgaussfilt(image(:,:,1),4);
            BluredImage(:,:,2) = imgaussfilt(image(:,:,2),4);
            BluredImage(:,:,3) = imgaussfilt(image(:,:,3),4);
        case 'Blur Sigma: 8'
            BluredImage(:,:,1) = imgaussfilt(image(:,:,1),8);
            BluredImage(:,:,2) = imgaussfilt(image(:,:,2),8);
            BluredImage(:,:,3) = imgaussfilt(image(:,:,3),8);
    end
    BluredImage = uint8(BluredImage);
else
    BluredImage = zeros(width,length);
    switch choice
        case 'No Blur Effect'
            BluredImage = image;
        case 'Blur Sigma: 2'
            BluredImage = imgaussfilt(image,2);     
        case 'Blur Sigma: 4'
            BluredImage= imgaussfilt(image,4); 
        case 'Blur Sigma: 8'
            BluredImage = imgaussfilt(image,8); 
    end
    BluredImage = uint8(BluredImage);
end

switch costfunction
        case 1
            BluredCostGraph = Find_Cost(BluredImage,width,length,dim);
        case 2
            BluredCostGraph = Find_Cost2(BluredImage,width,length,dim);
end

end

