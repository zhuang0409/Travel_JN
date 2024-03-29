function Searchlight2_runRSA_glmlevelsRN50(subjectID) 
% We run RSA separately for each taxonomic level, we obtained regression coefficients 
% for the respective taxonomic level in a general linear model that included 
% the respective model RDM (e.g. the subordinate level), the model RDMs 
% corresponding to the other two taxonomic levels (e.g. the basic and the 
% superordinate level) and the ResNet50_conv1 control model. 

%% add path
addpath('/Users/zhuang/EEGNet/results_ica/npy-matlab-master/npy-matlab');

%set parameters
fprintf('Starting with subject %s\n', subjectID);
nRuns = 6;
smoothingVal = 0;

%% Folder
projectDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/UnSmoothed/';
targetDir = fullfile(projectDir, subjectID);
dataDir = fullfile(targetDir, 'results');
rsaDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/' ;
outputDir = fullfile(rsaDir, 'RSA_glmlevelsRN50');

%% load mask
standardDir = '/usr/local/fsl/data/standard';
mask_fn = fullfile(standardDir, 'MNI152_T1_2mm_brain_mask.nii.gz');

%% load the visual model
modeldir='/Users/zhuang/Documents/MRI/Projects/Travel/data/Resnet50/outputs/';
matrixnames=dir([modeldir,'*.npy']);
data= readNPY([modeldir,matrixnames(1).name]);
% using RN_reshape_to_fMRI to keep the order of stimuli identically
modeldsm=squareform(RN_reshape_to_fMRI(squeeze(data(1,:,:))));

%% place RDM
load('places_last2nd.mat');
placesdsm=targetlayer_dsm;

%% load models of super/basic/sub
dsmdir='/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/progs/';
super=load([dsmdir,'super.mat']);
dsmdir='/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/progs/';
basic=load([dsmdir,'basic.mat']);
dsmdir='/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/progs/';
sub=load([dsmdir,'sub.mat']);

%% load data from different runs
ds = cell(nRuns,1);
for iRun = 1:nRuns
    data_fn = fullfile(dataDir, sprintf('t_Travel_run00%d_SS%d_aligned-subject-standard-2mm.nii.gz', iRun, smoothingVal));
    ds{iRun} = cosmo_fmri_dataset(data_fn, 'mask', mask_fn,'targets',1:72,'chunks',iRun);
end

% average data across runs
dsGroup = cosmo_stack(ds);
dsGroup = cosmo_remove_useless_data(dsGroup);
dsGroup = cosmo_fx(dsGroup,@(x)mean(x,1), 'targets', 1);

%% Set measure for searchlight-RSA analysis
% load model RDMs: 
% 1: superordinate model RDM 2: basic model 3: subordinate model 4: visual control model
modelTypeToDSM{1}=super.dsm;
modelTypeToDSM{2}=basic.dsm;
modelTypeToDSM{3}=sub.dsm;
modelTypeToDSM{4}=modeldsm;
modelTypeToDSM{5}=placesdsm; % place RDM

% set the method for searchlight
measure = @cosmo_target_dsm_corr_measure;
measure_args = struct();
measure_args.glm_dsm = {modelTypeToDSM{1}, modelTypeToDSM{2}, modelTypeToDSM{3}, modelTypeToDSM{4}, modelTypeToDSM{5}};
measure_args.center_data = true;
measure_args.metric='squaredeuclidean';

% for the searchlight, define neighborhood for each feature (voxel).
nvoxels_per_searchlight=100;
fprintf('Creating neighborhoods\n')
nbrhood = cosmo_spherical_neighborhood(dsGroup, 'count', nvoxels_per_searchlight);

%% run searchlight
fprintf('Starting glm searchlight with size %g voxels per searchlight\n', nvoxels_per_searchlight)
% get four rows glm-rsa results for different models
% (unique information from superordinate-1st row, basic-2nd row, sub-3rd row, visual control model-4th row).
glm_res = cosmo_searchlight(dsGroup, nbrhood, measure, measure_args);

%Save the data
fprintf('Saving files...\n');
cosmo_map2fmri(glm_res, fullfile(outputDir, sprintf('levels_RN50_SS%d_%s.nii.gz', smoothingVal, subjectID)));
