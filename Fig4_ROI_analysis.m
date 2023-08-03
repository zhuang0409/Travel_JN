% ROI-based RSA (partial correlation)
% set path
clc;clear;
addpath('/Users/zhuang/EEGNet/results_ica/npy-matlab-master/npy-matlab');
%% FOLDER
projectDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/ROIs_based/RSA_glm2models/';
mkdir (projectDir);
dataPath = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/ROIs_based/data/';
dsmdir='/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/progs/';
%% Load ROI
roisdir='/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/ROIs/10mm/';
rois=dir([roisdir, '*.nii.gz']);
smoothingVal=0;
% subjects
subjectIDs = {'SUB01','SUB02','SUB03','SUB04','SUB05','SUB06','SUB07','SUB08','SUB09','SUB10','SUB11',...
              'SUB12','SUB13','SUB14','SUB15','SUB16','SUB17','SUB18','SUB19','SUB20','SUB21','SUB22','SUB23'};

nsubjects=numel(subjectIDs);
levels=[{'super'} {'basic'} {'sub'}];

%% load the visual model
modeldir='/Users/zhuang/Documents/MRI/Projects/Travel/data/Resnet50/outputs/';
matrixnames=dir([modeldir,'*.npy']);
data= readNPY([modeldir,matrixnames(1).name]);
modeldsm=squareform(VGG_reshape_to_fMRI(squeeze(data(1,:,:))));

% places
load('places_last2nd.mat');
placesdsm=squareform(targetlayer_dsm);

%% run partial correlation separately one by one
for i=1:length(rois)
    % load data
    display(rois(i).name);
    partial_r=zeros(nsubjects,length(levels));
    for j=1:nsubjects
        subjectID=subjectIDs{j};
        display(subjectID);
        data_fn=fullfile([dataPath, 'ROI_' rois(i).name(1:end-7) '.mat' ]);
        load(data_fn);% ds_subj
        ds=ds_subj(:,:,j);
        % demean data
        ds_r=ds.samples-mean(ds.samples,1);
        ds_rdm=1-corr(ds_r');
        ds_rdm_vec=squareform(ds_rdm);
        % run parietal corr
        for k=1:3%super-1;basic-2;sub-3
            level=char(levels(k));
            load([dsmdir,level '.mat']);
            dsm_vec=squareform(dsm);
            X=[ds_rdm_vec' dsm_vec' modeldsm' placesdsm'];
            r=partialcorr(X,'type','Spearman');
            partial_r(j,k)=r(1,2);
        end
    end
        save ([projectDir, 'Demean_glmRSA_' rois(i).name(1:end-7) ], 'partial_r');
end
