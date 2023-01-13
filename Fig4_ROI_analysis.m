% ROI-based RSA (partial correlation)
% set path
clc;clear;
addpath('H:\EEGNet\results_ica\npy-matlab-master\npy-matlab');
%% FOLDER
projectDir = 'H:\Travel\data\ExemData\RSA\ROIs_based\RSA_glm\';
mkdir (projectDir);
dataPath = 'H:\Travel\data\ExemData\RSA\ROIs_based\data\';
dsmdir='H:\Travel\data\ExemData\progs\';
%% Load ROI
roisdir='H:\Travel\data\ExemData\ROIs\10mm\';
rois=dir([roisdir, '*.nii.gz']);
smoothingVal=0;
% subjects
subjectIDs = {'SUB03_19980219SNFS','SUB04_19900101WALE','SUB05_19890101WANL','SUB06_19880720WAVI'...
              'SUB07_19960420WIST','SUB08_19980101THAE','SUB09_20200828NICA','SUB10_20200828LYXU'...
              'SUB11_19920409THZH','SUB12_19980908SABA','SUB13_19940216NARA','SUB14_19971002COCA'...
              'SUB15_19970428MIRU','SUB16_19891030CHZH','SUB17_19921010XIHA','SUB18_19921211ZUKA'...
              'SUB19_19970603JOBE','SUB20_19970125FIGI','SUB21_19940526MISC','SUB22_19891024ROPU'...
              'SUB23_19811010CHZW','SUB24_20200918ANIO','SUB25_20200923MICA'};

nsubjects=numel(subjectIDs);
levels=[{'super'} {'basic'} {'sub'}];

%% load the visual model
modeldir='H:\Travel\data\Resnet50\outputs\';
matrixnames=dir([modeldir,'*.npy']);
data= readNPY([modeldir,matrixnames(1).name]);
modeldsm=squareform(VGG_reshape_to_fMRI(squeeze(data(1,:,:))));

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
            X=[ds_rdm_vec' dsm_vec' modeldsm'];
            r=partialcorr(X,'type','Spearman');
            partial_r(j,k)=r(1,2);
        end
    end
        save ([projectDir, 'Demean_glmRSA_' rois(i).name(1:end-7) ], 'partial_r');
end
