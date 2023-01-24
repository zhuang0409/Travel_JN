function createStatMapRSA(foldername,level)
% create brains maps with all subjects for group-level statistics
% e.g.foldername='MDS_RN50';
% e.g.level='mds';

%% FOLDER
projectDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/';
dataDir = fullfile(projectDir, sprintf('RSA_%s',foldername));
resultsDir=[dataDir, '/Group'];
mkdir(resultsDir);

%subjects
subjectIDs = {'SUB01','SUB02','SUB03','SUB04','SUB05','SUB06','SUB07','SUB08','SUB09','SUB10','SUB11',...
              'SUB12','SUB13','SUB14','SUB15','SUB16','SUB17','SUB18','SUB19','SUB20','SUB21','SUB22','SUB23'};

nSubs = length(subjectIDs);
mask_fn = '/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz';

%% merge individual maps into group-level map for further statistics
alignedGroupMap = cell(length(subjectIDs),1);
for iSub = 1:nSubs
    individualMap = sprintf('%s_SS5_%s.nii.gz',level,subjectIDs{iSub});
    alignedGroupMap{iSub} = cosmo_fmri_dataset(fullfile(dataDir, individualMap), 'mask', mask_fn);
    
    % create maps based on different types of glm RSA analysis
    switch level % to determine which types of glm-rsa analysis
        case {'sub_RN50','basic_RN50','super_RN50','MDS_RN50'}
        % because the output of brain maps from 'sub_RN50','basic_RN50','super_RN50','MDS_RN50' are two rows results, targets are labeled as 1 and 2
        % the first row is the glm-rsa result of one level model regressing out visual control model
        % the second row is the glm-rsa result of visual control model regressing out one level model
            alignedGroupMap{iSub}.sa.targets = [1 2]';
            alignedGroupMap{iSub}.sa.chunks = zeros(2,1)+iSub;
            
        case {'levels_RN50'}
        % because the output of brain maps from 'levels_RN50' are four rows results, targets are labeled as 1,2,3, and 4
        % the first row is the glm-rsa result of superordinate model regressing out the other two and visual control model
        % the second row is the glm-rsa results of basic model regressing out the other two and visual control model
        % the third row is the glm-rsa results of subordinate model regressing out the other two and visual control model
        % the fourth row is the glm-rsa result of visual control model regressing out other three-level models
            alignedGroupMap{iSub}.sa.targets = [1 2 3 4]';
            alignedGroupMap{iSub}.sa.chunks = zeros(4,1)+iSub;
    
        case {'mds_sub_RN50','mds_basic_RN50','mds_super_RN50'}
        % because the output of brain maps from 'mds_sub_RN50','mds_basic_RN50','mds_super_RN50' are three rows results, targets are labeled as 1,2 and 3
        % the first row is the glm-rsa result of behavioral model (mds) regressing out one level model and visual control model
        % the second row is the glm-rsa result of one level model regressing out behavioral model (mds) and visual control model
        % the third row is the glm-rsa result of visual control model regressing out behavioral model (mds) and one level model
            alignedGroupMap{iSub}.sa.targets = [1 2 3]';
            alignedGroupMap{iSub}.sa.chunks = zeros(3,1)+iSub;
    end
end
% merge data into group-level map
dsGroup = cosmo_stack(alignedGroupMap);
dsGroup = cosmo_remove_useless_data(dsGroup);

%% save data
cosmo_map2fmri(dsGroup, fullfile(resultsDir, sprintf('GROUP_%s.nii.gz',level)));

%% split data according to different types of models
ds_sliced = cosmo_split(dsGroup, 'targets', 1);
switch level
    case {'sub_RN50','basic_RN50','super_RN50','MDS_RN50','mds_sub_RN50','mds_basic_RN50','mds_super_RN50'}
    % only save the glm-rsa result of one model regressing out visual control model as nifi brain map
        cosmo_map2fmri(ds_sliced{1},fullfile(resultsDir,sprintf('GROUP_%s.nii.gz',level)));
    case {'levels_RN50'}
        for i=1:3
            % one level model (superordinate/basic/sub) RegressingOut other two levels and visual control model
            % 1:superordinate;2:basic;3:sub
            % save brain map
            cosmo_map2fmri(ds_sliced{i},fullfile(resultsDir,sprintf('GROUP_%s%d.nii.gz',level(1:end-5),i)));
        end
end



