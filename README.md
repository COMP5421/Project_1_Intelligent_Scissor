# Project_1_Intelligent_Scissor
This intelligent scissor allows a user to cut an object out of one image and paste it into another, and it helps the user trace the object by providing a "live wire" that automatically snaps to and wraps around the object of interest.

Run `UI.m` with MATLAB to start the program, MATLAB Runtime (Version# `9.1` or above) may be needed. <br />
Windows users may also run the program directly via `UI.exe`.

To use the minPath & pathTree function, first compile the source code with `mex`. Depends on your system, you may need `minGW` (for Windows).

    mex minPath.cpp
    mex pathTree.cpp

The input and output data type is `double` by default, notice the indexs of (seed_X, seed_Y) start from `zero` and that of [arr] start from `(1, 1)`. Please also pay attention that [arr1] stores the index of current pixel node's parent, while [arr2] saves the coordinates of image nodes in the sequence of their being extracted from queue.

    [arr1] = minPath(costGraph, seed_X, seed_Y)
    [arr2] = pathTree(costGraph, seed_X, seed_Y)
