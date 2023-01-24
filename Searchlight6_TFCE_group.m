function TFCE_group(foldername,level)
% TFCE_group('levels_RN50','levels1')
%e.g.foldername='levels_RN50';
%e.g.level='levels1'; glm-rsa results of superordinate model regressing out the other two models and visual control model
%e.g.level='levels2'; glm-rsa results of basic model regressing out the other two models and visual control model
%e.g.level='levels3'; glm-rsa results of sub model regressing out the other two models and visual control model

%% FOLDER
pathDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/';
projectDir = fullfile(pathDir, sprintf('RSA_%s/Group/',foldername));
mkdir(projectDir);

%% load numbers of subjects
nSub = 23;

%% load data and do TFCE statistics for group-level statistical analysis
ds = cosmo_fmri_dataset(fullfile(projectDir, sprintf('GROUP_%s.nii.gz',level)));
ds = cosmo_slice(ds, 1:nSub, 1);
ds.sa.targets = ones(nSub,1);
ds.sa.chunks = (1:nSub)';
ds = cosmo_remove_useless_data(ds);
nbrhood = cosmo_cluster_neighborhood(ds);

%TFCE set parameters
opt = struct();
opt.cluster_stat = 'tfce';
opt.niter = 5000;        
opt.h0_mean = 0;
opt.dh = 0.1;
opt.nproc = 4;

% run analysis with montercarlo
ds_z = cosmo_montecarlo_cluster_stat(ds, nbrhood, opt);

% save data
cosmo_map2fmri(ds_z, fullfile(projectDir, sprintf('TFCE_%s.nii.gz',level)));

%% make statistics maps (z>1.65)
dstarget = cosmo_slice(ds, length(ds.samples(:,1)), 1);% get the data structure as ds
dstarget.samples(ds_z.samples<1.65)=0;
% save data
cosmo_map2fmri(dstarget,fullfile(projectDir,sprintf('TFCE_%s_statmap.nii.gz',level)));

