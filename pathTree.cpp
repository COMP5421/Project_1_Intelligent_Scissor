#include <algorithm>
#include <cstring>
#include <vector>
#include <stdio.h>
#include <math.h>
#include "mex.h"

#define INITIAL  0
#define ACTIVE   1
#define EXPANDED 2

using namespace std;

struct imgNode
{
    int state;
    double totalcost;
    imgNode *prenode;
    int row, col;
};

bool comp(double val, imgNode const& node)
{
    return (node.totalcost>val);
}

void minPath(double costGraph[], double* out, int w, int h, int sx, int sy)
{
    vector<vector<imgNode> > allNode;

    for(int i = 0; i < h; i++)
    {
        allNode.push_back(vector<imgNode>());
        for(int j = 0; j < w; j++)
        {
            imgNode n;
            n.state = INITIAL;
            n.totalcost = 1e8;
            n.prenode = NULL;
            n.row = i;
            n.col = j;
            allNode[i].push_back(n);
        }
    }

    vector<imgNode> pq;
    imgNode seed;
    seed.row = sx;
    seed.col = sy;
    allNode[sx][sy].totalcost = 0;
    pq.push_back(seed);

    int num = 0;

    while(!pq.empty())
    {
        imgNode* min = &allNode[pq.front().row][pq.front().col];
        pq.erase(pq.begin());
        int x = min->row;
        int y = min->col;
        out[num] = double(x);
        out[num+w*h] = double(y);
        min->state = EXPANDED;
        vector<imgNode>::iterator it;

        if(y+1<w && allNode[x][y+1].state==INITIAL)
        {
            allNode[x][y+1].prenode = &allNode[x][y];
            allNode[x][y+1].totalcost = min->totalcost + costGraph[3*h*(3*y+2)+3*x+1];
            allNode[x][y+1].state = ACTIVE;
            it = upper_bound(pq.begin(), pq.end(), allNode[x][y+1].totalcost, comp);
            pq.insert(it, allNode[x][y+1]);
        }
        else if(y+1<w && allNode[x][y+1].state==ACTIVE)
            if(allNode[x][y+1].totalcost > min->totalcost + costGraph[3*h*(3*y+2)+3*x+1])
            {
                allNode[x][y+1].totalcost = min->totalcost + costGraph[3*h*(3*y+2)+3*x+1];
                allNode[x][y+1].prenode = &allNode[x][y];
                it = upper_bound(pq.begin(), pq.end(), allNode[x][y+1].totalcost, comp);
                for(it; it != pq.end(); it++)
                    if(it->row == x && it->col == y+1)
                        it->totalcost = allNode[x][y+1].totalcost;
            }
        
        if(y+1<w && x>0 && allNode[x-1][y+1].state==INITIAL)
        {
            allNode[x-1][y+1].prenode = &allNode[x][y];
            allNode[x-1][y+1].totalcost = min->totalcost + costGraph[3*h*(3*y+2)+3*x];
            allNode[x-1][y+1].state = ACTIVE;
            it = upper_bound(pq.begin(), pq.end(), allNode[x-1][y+1].totalcost, comp);
            pq.insert(it, allNode[x-1][y+1]);
        }
        else if(y+1<w && x>0 && allNode[x-1][y+1].state==ACTIVE)
            if(allNode[x-1][y+1].totalcost > min->totalcost + costGraph[3*h*(3*y+2)+3*x])
            {
                allNode[x-1][y+1].totalcost = min->totalcost + costGraph[3*h*(3*y+2)+3*x];
                allNode[x-1][y+1].prenode = &allNode[x][y];
                it = upper_bound(pq.begin(), pq.end(), allNode[x-1][y+1].totalcost, comp);
                for(it; it != pq.end(); it++)
                    if(it->row == x-1 && it->col == y+1)
                        it->totalcost = allNode[x-1][y+1].totalcost;
            }

        if(x>0 && allNode[x-1][y].state==INITIAL)
        {
            allNode[x-1][y].prenode = &allNode[x][y];
            allNode[x-1][y].totalcost = min->totalcost + costGraph[3*h*(3*y+1)+3*x];
            allNode[x-1][y].state = ACTIVE;
            it = upper_bound(pq.begin(), pq.end(), allNode[x-1][y].totalcost, comp);
            pq.insert(it, allNode[x-1][y]);
        }
        else if(x>0 && allNode[x-1][y].state==ACTIVE)
            if(allNode[x-1][y].totalcost > min->totalcost + costGraph[3*h*(3*y+1)+3*x])
            {
                allNode[x-1][y].totalcost = min->totalcost + costGraph[3*h*(3*y+1)+3*x];
                allNode[x-1][y].prenode = &allNode[x][y];
                it = upper_bound(pq.begin(), pq.end(), allNode[x-1][y].totalcost, comp);
                for(it; it != pq.end(); it++)
                    if(it->row == x-1 && it->col == y)
                        it->totalcost = allNode[x-1][y].totalcost;
            }

        if(y>0 && x>0 && allNode[x-1][y-1].state==INITIAL)
        {
            allNode[x-1][y-1].prenode = &allNode[x][y];
            allNode[x-1][y-1].totalcost = min->totalcost + costGraph[3*h*3*y+3*x];
            allNode[x-1][y-1].state = ACTIVE;
            it = upper_bound(pq.begin(), pq.end(), allNode[x-1][y-1].totalcost, comp);
            pq.insert(it, allNode[x-1][y-1]);
        }
        else if(y>0 && x>0 && allNode[x-1][y-1].state==ACTIVE)
            if(allNode[x-1][y-1].totalcost > min->totalcost + costGraph[3*h*3*y+3*x])
            {
                allNode[x-1][y-1].totalcost = min->totalcost + costGraph[3*h*3*y+3*x];
                allNode[x-1][y-1].prenode = &allNode[x][y];
                it = upper_bound(pq.begin(), pq.end(), allNode[x-1][y-1].totalcost, comp);
                for(it; it != pq.end(); it++)
                    if(it->row == x-1 && it->col == y-1)
                        it->totalcost = allNode[x-1][y-1].totalcost;
            }

        if(y>0 && allNode[x][y-1].state==INITIAL)
        {
            allNode[x][y-1].prenode = &allNode[x][y];
            allNode[x][y-1].totalcost = min->totalcost + costGraph[3*h*3*y+3*x+1];
            allNode[x][y-1].state = ACTIVE;
            it = upper_bound(pq.begin(), pq.end(), allNode[x][y-1].totalcost, comp);
            pq.insert(it, allNode[x][y-1]);
        }
        else if(y>0 && allNode[x][y-1].state==ACTIVE)
            if(allNode[x][y-1].totalcost > min->totalcost + costGraph[3*h*3*y+3*x+1])
            {
                allNode[x][y-1].totalcost = min->totalcost + costGraph[3*h*3*y+3*x+1];
                allNode[x][y-1].prenode = &allNode[x][y];
                it = upper_bound(pq.begin(), pq.end(), allNode[x][y-1].totalcost, comp);
                for(it; it != pq.end(); it++)
                    if(it->row == x && it->col == y-1)
                        it->totalcost = allNode[x][y-1].totalcost;
            }

        if(y>0 && x+1<h && allNode[x+1][y-1].state==INITIAL)
        {
            allNode[x+1][y-1].prenode = &allNode[x][y];
            allNode[x+1][y-1].totalcost = min->totalcost + costGraph[3*h*3*y+3*x+2];
            allNode[x+1][y-1].state = ACTIVE;
            it = upper_bound(pq.begin(), pq.end(), allNode[x+1][y-1].totalcost, comp);
            pq.insert(it, allNode[x+1][y-1]);
        }
        else if(y>0 && x+1<h && allNode[x+1][y-1].state==ACTIVE)
            if(allNode[x+1][y-1].totalcost > min->totalcost + costGraph[3*h*3*y+3*x+2])
            {
                allNode[x+1][y-1].totalcost = min->totalcost + costGraph[3*h*3*y+3*x+2];
                allNode[x+1][y-1].prenode = &allNode[x][y];
                it = upper_bound(pq.begin(), pq.end(), allNode[x+1][y-1].totalcost, comp);
                for(it; it != pq.end(); it++)
                    if(it->row == x+1 && it->col == y-1)
                        it->totalcost = allNode[x+1][y-1].totalcost;
            }

        if(x+1<h && allNode[x+1][y].state==INITIAL)
        {
            allNode[x+1][y].prenode = &allNode[x][y];
            allNode[x+1][y].totalcost = min->totalcost + costGraph[3*h*(3*y+1)+3*x+2];
            allNode[x+1][y].state = ACTIVE;
            it = upper_bound(pq.begin(), pq.end(), allNode[x+1][y].totalcost, comp);
            pq.insert(it, allNode[x+1][y]);
        }
        else if(x+1<h && allNode[x+1][y].state==ACTIVE)
            if(allNode[x+1][y].totalcost > min->totalcost + costGraph[3*h*(3*y+1)+3*x+2])
            {
                allNode[x+1][y].totalcost = min->totalcost + costGraph[3*h*(3*y+1)+3*x+2];
                allNode[x+1][y].prenode = &allNode[x][y];
                it = upper_bound(pq.begin(), pq.end(), allNode[x+1][y].totalcost, comp);
                for(it; it != pq.end(); it++)
                    if(it->row == x+1 && it->col == y)
                        it->totalcost = allNode[x+1][y].totalcost;
            }

        if(y+1<w && x+1<h && allNode[x+1][y+1].state==INITIAL)
        {
            allNode[x+1][y+1].prenode = &allNode[x][y];
            allNode[x+1][y+1].totalcost = min->totalcost + costGraph[3*h*(3*y+2)+3*x+2];
            allNode[x+1][y+1].state = ACTIVE;
            it = upper_bound(pq.begin(), pq.end(), allNode[x+1][y+1].totalcost, comp);
            pq.insert(it, allNode[x+1][y+1]);
        }
        else if(y+1<w && x+1<h && allNode[x+1][y+1].state==ACTIVE)
            if(allNode[x+1][y+1].totalcost > min->totalcost + costGraph[3*h*(3*y+2)+3*x+2])
            {
                allNode[x+1][y+1].totalcost = min->totalcost + costGraph[3*h*(3*y+2)+3*x+2];
                allNode[x+1][y+1].prenode = &allNode[x][y];
                it = upper_bound(pq.begin(), pq.end(), allNode[x+1][y+1].totalcost, comp);
                for(it; it != pq.end(); it++)
                    if(it->row == x+1 && it->col == y+1)
                        it->totalcost = allNode[x+1][y+1].totalcost;
            }
            
        num++;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    double* costGraph = mxGetPr(prhs[0]);
    int sx = (int)mxGetScalar(prhs[1]);
    int sy = (int)mxGetScalar(prhs[2]);
    const int* dim = mxGetDimensions(prhs[0]);
    int h = dim[0];
    int w = dim[1];
    int dims[2] = {h/3*w/3, 2};

    plhs[0] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    double *arr = (double*)malloc(w/3*h/3*2*sizeof(double));
    minPath(costGraph, arr, w/3, h/3, sx, sy);
    memcpy(mxGetPr(plhs[0]), arr, w/3*h/3*2*mxGetElementSize(plhs[0]));
    free(arr);
}