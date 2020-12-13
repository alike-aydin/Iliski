# Iliski

`Iliski` is a software aiming to compute Transfer Functions (TFs) between two datasets.

- [Overview](#overview)
- [System Requirements](#system-requirements)
- [Installation Guide](#installation-guide)
- [Documentation & Demo](#documentation-demo)

## Overview
`Iliski` aims to compute TFs, as described in the pre-print available on BioRxiv (UPDATE LINK). 


## System Requirements
### Hardware Requirements
`Iliski` requires only a standard computer with enough RAM to support the in-memory operations.
### Software Requirements
This software has been compiled on Windows 10 Pro (v 18362.295) but should run on any of the Windows 10 or 7 operating systems.
It's been developed using Matlab 2018a and the following toolboxes :
+ MATLAB 
+ Global Optimization Toolbox
+ Signal Processing Toolbox
+ Optimization Toolbox
+ Curve Fitting Toolbox

Depending on your Matlab installation, see [Installation Guide](#installation-guide) below.
You may need a HDF5 file Viewer, downloadable on the HDF Group website [here](https://www.hdfgroup.org/downloads/hdfview).

## Installation Guide
The software is packaged to be used without having Matlab installed on your computer. 

+ Download here the HDF5 data files (too heavy to be be on GitLab) : [http://doi.org/10.5281/zenodo.3773863](http://doi.org/10.5281/zenodo.3773863) and after having installed Iliski, put them in the `ExampleData/` folder (where there are already some example files).
+ Go to the [GitLab repository](https://gitlab.com/AliK_A/iliski/) 
+ Download :
  + the repository [here](https://gitlab.com/AliK_A/iliski/-/archive/master/iliski-master.zip), if you **have the Matlab Runtime environnement** on your computer, and unzip it. 
    + Open `Iliski.mlapp` and have fun!
  + `Iliski_WebInstaller.exe`, if you **do not have the Matlab Runtime environnement** and run the file to install.
    + Run the file `Iliski.exe`and have fun!

Don't forget to install a HDF5 Viewer from [here](https://www.hdfgroup.org/downloads/hdfview).

## Documentation & Demo
The *User Manual* is in a separate file, at the root of the repository: [Iliski_UserManual.pdf](https://gitlab.com/AliK_A/iliski/-/raw/master/Iliski_User_Manual.pdf?inline=false). 



