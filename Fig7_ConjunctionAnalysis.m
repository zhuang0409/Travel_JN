%% Conjunction maps
% to identify regions in which actions are jointly represented (a) at the 
% subordinate and basic level, and (b) at all three taxonomic levels, we 
% computed a conjunction analysis on the basis of the statistical maps of 
% RSA results with regressing out the visual model (the corresponding 
% results shown in Figure 6A). 

%% FOLDER
projectdir='G:\Travel\data\ExemData\RSA\RSA_glmRN50\Group\';
mask_fn = 'G:\Travel\data\ExemData\MNI152_T1_2mm_brain_mask.nii.gz';

%% read data of each level 
% maps after TFCE
% super
super_dsfn=fullfile(projectdir,sprintf('TFCE_super_RN50_statmap.nii.gz'));
ds_super = cosmo_fmri_dataset(super_dsfn,'mask',mask_fn);
% basic
basic_dsfn=fullfile(projectdir,sprintf('TFCE_basic_RN50_statmap.nii.gz'));
ds_basic = cosmo_fmri_dataset(basic_dsfn,'mask',mask_fn);
% sub
sub_dsfn=fullfile(projectdir,sprintf('TFCE_sub_RN50_statmap.nii.gz'));
ds_sub = cosmo_fmri_dataset(sub_dsfn,'mask',mask_fn);
%% conjunction
% Conjunctions were computed by outputting the minimum t value for each vertex of the input maps
% conjunct of sub and basic level: to get the min t between basic and sub
ds_conj_SubBasic=min(ds_basic.samples,ds_sub.samples);
% conjunct of three taxonomic level: to get the min t across super, basic, sub.
ds_conj=min(ds_basic.samples,ds_super.samples);
ds_conj_all=min(ds_conj,ds_sub.samples);
%% save maps
%  the conjunction of all three levels
conj_map.samples=ds_conj_all;
conj_map.a=ds_super.a;
conj_map.sa=ds_super.sa;
conj_map.fa=ds_super.fa;
%  the conjunction of subordinate and basic levels
conj_map_SubBasic.samples=ds_conj_SubBasic;
conj_map_SubBasic.a=ds_basic.a;
conj_map_SubBasic.sa=ds_basic.sa;
conj_map_SubBasic.fa=ds_basic.fa;

cosmo_map2fmri(conj_map, fullfile(projectdir, sprintf('GROUP_SuperBasicSub.nii.gz')));
cosmo_map2fmri(conj_map_SubBasic, fullfile(projectdir, sprintf('GROUP_BasicSub.nii.gz')));