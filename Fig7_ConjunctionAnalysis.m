%% Conjunction maps
% to identify regions in which actions are jointly represented (a) at the 
% subordinate and basic level, and (b) at all three taxonomic levels, we 
% computed a conjunction analysis on the basis of the statistical maps of 
% glm-RSA results with one model regressing out the other two and the visual model
% (the corresponding results shown in Figure 6B). 

%% FOLDER
projectdir='G:\Travel\data\ExemData\RSA\RSA_glmRN50\Group\';
mask_fn = 'G:\Travel\data\ExemData\MNI152_T1_2mm_brain_mask.nii.gz';

%% load data 
% maps after TFCE statistics
% unique information at the superordinate level
super_dsfn=fullfile(projectdir,sprintf('TFCE_super_statmap.nii.gz'));
ds_super = cosmo_fmri_dataset(super_dsfn,'mask',mask_fn);

% unique information at the basic level
basic_dsfn=fullfile(projectdir,sprintf('TFCE_basic_statmap.nii.gz'));
ds_basic = cosmo_fmri_dataset(basic_dsfn,'mask',mask_fn);

% unique information at the subordinate level
sub_dsfn=fullfile(projectdir,sprintf('TFCE_sub_statmap.nii.gz'));
ds_sub = cosmo_fmri_dataset(sub_dsfn,'mask',mask_fn);

%% conjunction
% Conjunctions were computed by outputting the minimum t value for each vertex of the input maps
% conjunct of sub and basic level: to get the min t between basic and sub
ds_conj_SubBasic=min(ds_basic.samples,ds_sub.samples);

% conjunct of three taxonomic level: to get the min t across super, basic, sub.
ds_conj_all=min([ds_super.samples(:)';ds_basic.samples(:)';ds_sub.samples(:)']);

% binary data
ds_conj_all(ds_conj_all>0) = 1;
ds_conj_SubBasic(ds_conj_SubBasic>0) = 1;

%% save maps
%  the conjunction of all three levels
conj_map = cosmo_slice(ds_super, length(ds_super.samples(:,1)), 1);% get the data structure as ds_super
conj_map.samples=ds_conj_all;

%  the conjunction of subordinate and basic levels
conj_map_SubBasic = cosmo_slice(ds_basic, length(ds_basic.samples(:,1)), 1);% get the data structure as ds_basic
conj_map_SubBasic.samples=ds_conj_SubBasic;

cosmo_map2fmri(conj_map, fullfile(projectdir, sprintf('GROUP_SuperBasicSub.nii.gz')));
cosmo_map2fmri(conj_map_SubBasic, fullfile(projectdir, sprintf('GROUP_BasicSub.nii.gz')));

%% BrainNet viewer is used to visualize the brain maps
