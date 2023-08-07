%% VIF: Variance inflation factor
%% cite: https://de.mathworks.com/matlabcentral/fileexchange/60551-vif-x
%VIFs are also the diagonal elements of the inverse of the correlation matrix [1], a convenient result that eliminates the need to set up the various regressions
%[1] Belsley, D. A., E. Kuh, and R. E. Welsch. Regression Diagnostics. Hoboken, NJ: John Wiley & Sons, 1980.

clc;clear;
%% load data of modes from three taxonomic levels
super=load('super.mat');
basic=load('basic.mat');
sub=load('sub.mat');

x=reshape(super.dsm,[5184,1]);
y=reshape(basic.dsm,[5184,1]);
z=reshape(sub.dsm,[5184,1]);

%% VIFs: three taxonomic levels, the visual model and place RDM
% places
load('places_last2nd.mat');
placesdsm=targetlayer_dsm;
places=reshape(placesdsm,[5184,1]);

% addpath('/Users/zhuang/EEGNet/results_ica/npy-matlab-master/npy-matlab');
modeldir='G:\Travel\data\Resnet50\outputs\';
matrixnames=dir([modeldir,'*.npy']);
data= readNPY([modeldir,matrixnames(1).name]);
modeldsm=VGG_reshape_to_fMRI(squeeze(data(1,:,:)));
modelds=reshape(modeldsm,[5184,1]);

T_levels=[x, y, z, modelds places];h_levels=corrcoef(T_levels);vif_levels=diag(inv(h_levels));

%% VIFs: behavioral rdm, one of three taxonomic levels, the visual model and place RDM..
load('MDS.mat');

humanRDM=VGG_reshape_to_fMRI(kron(matrix,ones(6,6)));
h=reshape(humanRDM,[5184,1]);
%z-sub
t1=[h z modelds, places];r1=corrcoef(t1);vif1_mds=diag(inv(r1));
%y-basic
t2=[h y modelds, places];r2=corrcoef(t2);vif2_mds=diag(inv(r2));
%x-super
t3=[h x modelds, places];r3=corrcoef(t3);vif3_mds=diag(inv(r3));
