function TFCE_group(foldername,level)
%foldername='glmRN50';
%level='super';
nSub = 23;
%TFCE set parameters
opt = struct();
opt.cluster_stat = 'tfce';
opt.niter = 5000;        
opt.h0_mean = 0;
opt.dh = 0.1;
opt.nproc = 4;
%% FOLDER
pathDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/';
projectDir = fullfile(pathDir, sprintf('RSA_%s/Group/',foldername));
mkdir(projectDir);
%% load data and do TFCE statistics for group-level statistical analysis
ds = cosmo_fmri_dataset(fullfile(projectDir, sprintf('GROUP_%s.nii.gz',level)));
ds = cosmo_slice(ds, 1:nSub, 1);
ds.sa.targets = ones(nSub,1);
ds.sa.chunks = (1:nSub)';
ds = cosmo_remove_useless_data(ds);
nbrhood = cosmo_cluster_neighborhood(ds);
% run analysis with montercarlo
ds_z = cosmo_montecarlo_cluster_stat(ds, nbrhood, opt);
% save data
cosmo_map2fmri(ds_z, fullfile(projectDir, sprintf('TFCE_%s.nii.gz',level)));
%% make statistics maps (z>1.65)
[~,p,~,stats] = ttest(ds.samples);  %change   
ds.samples(end+1,:) = mean(ds.samples);
ds.samples(end+1,:) = stats.tstat; %t map 
k=nSub+1;
s=nSub+2;
ds.sa.targets(k:s,1) = 3;   
ds.sa.chunks(k:s,1) = nSub+1;   

dstarget = cosmo_slice(ds, length(ds.samples(:,1)), 1);
dstarget.samples(ds_z.samples<1.65)=0;
% save data
cosmo_map2fmri(dstarget,fullfile(projectDir,sprintf('TFCE_%s_statmap.nii.gz',level)));

