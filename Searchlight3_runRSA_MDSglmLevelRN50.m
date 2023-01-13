function Searchlight3_runRSA_MDSglmLevelRN50(subjectID,level) 
% Run RSA with human-rating model and regressed out one of three taxonomic
% level and the visual control model
%% set path
addpath('/Users/zhuang/EEGNet/results_ica/npy-matlab-master/npy-matlab');
%set parameters
fprintf('Starting with subject %s\n', subjectID);
nRuns = 6;
smoothingVal = 0;

%% FOLDER
projectDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/UnSmoothed/';
targetDir = fullfile(projectDir, subjectID);
dataDir = fullfile(targetDir, 'results');
rsaDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/' ;
outputDir = fullfile(rsaDir, 'RSA_MDS_glmRN50');

%% load mask
standardDir = '/usr/local/fsl/data/standard';
mask_fn = fullfile(standardDir, 'MNI152_T1_2mm_brain_mask.nii.gz');

%% load human-rating model
load('humanRating_mds.mat');
mds_dsm=kron(dsm,ones(6,6));
% using RN_reshape_to_fMRI to keep the order of stimuli identically
mdsdsm=RN_reshape_to_fMRI(mds_dsm);

%% load the visual control model
modeldir='/Users/zhuang/Documents/MRI/Projects/Travel/data/Resnet50/outputs/';
matrixnames=dir([modeldir,'*.npy']);
data= readNPY([modeldir,matrixnames(1).name]);
modeldsm=squareform(RN_reshape_to_fMRI(squeeze(data(1,:,:))));

%% load one model of super/basic/sub
dsmdir='/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/progs/';
load([dsmdir,level '.mat']);

%% load data from different runs
ds = cell(nRuns,1);
for iRun = 1:nRuns
    data_fn = fullfile(dataDir, sprintf('t_Travel_run00%d_SS%d_aligned-subject-standard-2mm.nii.gz', iRun, smoothingVal));
    ds{iRun} = cosmo_fmri_dataset(data_fn, 'mask', mask_fn,'targets',1:72,'chunks',iRun);
end

dsGroup = cosmo_stack(ds);
dsGroup = cosmo_remove_useless_data(dsGroup);
dsGroup = cosmo_fx(dsGroup,@(x)mean(x,1), 'targets', 1);

%% Set measure for searchlight-RSA analysis
modelTypeToDSM{1}=mdsdsm;
modelTypeToDSM{2}=dsm;
modelTypeToDSM{3}=modeldsm;
% set the method for searchlight
measure = @cosmo_target_dsm_corr_measure;
measure_args = struct();
measure_args.glm_dsm = {modelTypeToDSM{1}, modelTypeToDSM{2}, modelTypeToDSM{3}};
measure_args.center_data = true;
measure_args.metric='squaredeuclidean';

%for the searchlight, define neighborhood for each feature (voxel).
nvoxels_per_searchlight=100;
%choose radius for searchlight, find neighborhoods
fprintf('Creating neighborhoods\n')
nbrhood = cosmo_spherical_neighborhood(dsGroup, 'count', nvoxels_per_searchlight);

%run searchlight
fprintf('Starting glm searchlight with size %g voxels per searchlight\n', nvoxels_per_searchlight)
glm_res = cosmo_searchlight(dsGroup, nbrhood, measure, measure_args);

%Save the data
fprintf('Saving files...\n');
cosmo_map2fmri(glm_res, fullfile(outputDir, sprintf('mds_%s_RN50_SS%d_%s.nii.gz', level, smoothingVal, subjectID)));
