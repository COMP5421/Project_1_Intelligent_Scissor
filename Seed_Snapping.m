function [ seedx, seedy ] = Seed_Snapping( image,width,length,dim, x, y )
%  Find closest edge point
if dim == 3
    image = rgb2gray(image);
end
edgegraph = edge(image,'Canny');

seedx = x; 
seedy = y;
if edgegraph(x, y) == 1
    return
else
    i = 0;
    while 1
        i = i + 1;
        NE_x = x - i; NE_y = y + i;
        E_x = x; E_y = y + i;
        SE_x = x + i; SE_y = y + i;
        S_x = x + i; S_y = y;
        SW_x = x + i; SW_y = y - i;
        W_x = x; W_y = y - i;
        NW_x = x - i; NW_y = y - i;
        N_x = x - i; N_y = y;
        if (NE_x > 0)&&(NE_y < length)
            if edgegraph(NE_x, NE_y) == 1
                seedx = NE_x; 
                seedy = NE_y;
                return
            end
        end
        
        if E_y < length
            if edgegraph(E_x, E_y) == 1
                seedx = E_x; 
                seedy = E_y;
                return
            end
        end
        
        if (SE_x < width)&&(SE_y < length)
            if edgegraph(SE_x, SE_y) == 1
                seedx = SE_x; 
                seedy = SE_y;
                return
            end
        end
        
        if S_x < width
            if edgegraph(S_x, S_y) == 1
                seedx = S_x; 
                seedy = S_y;
                return
            end
        end
        
        if (SW_x < width)&&(SW_y > 0)
            if edgegraph(SW_x, SW_y) == 1
                seedx = SW_x; 
                seedy = SW_y;
                return
            end
        end
        
        if W_y > 0
            if edgegraph(W_x, W_y) == 1
                seedx = W_x; 
                seedy = W_y;
                return
            end
        end
        
        if (NW_x > 0)&&(NW_y > 0)
            if edgegraph(NW_x, NW_y) == 1
                seedx = NW_x; 
                seedy = NW_y;
                return
            end
        end
        
        if N_x > 0
            if edgegraph(N_x, N_y) == 1
                seedx = N_x; 
                seedy = N_y;
                return
            end
        end
        
        if i > 3000
                seedx = x; 
                seedy = y;
                return
        end
    end
end
end

