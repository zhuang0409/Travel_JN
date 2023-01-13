function createStatMapRSA(foldername,level)
% create brains maps with all subjects for group-level statistics
% foldername='MDS_RN50';
% level='mds';
%% FOLDER
projectDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/';
dataDir = fullfile(projectDir, sprintf('RSA_%s',foldername));
resultsDir=[dataDir, '/Group'];
mkdir(resultsDir);

%subjects
subjectIDs = {'SUB03_19980219SNFS','SUB04_19900101WALE','SUB05_19890101WANL','SUB06_19880720WAVI'...
    'SUB07_19960420WIST','SUB08_19980101THAE','SUB09_20200828NICA','SUB10_20200828LYXU'...
    'SUB11_19920409THZH','SUB12_19980908SABA','SUB13_19940216NARA','SUB14_19971002COCA'...
    'SUB15_19970428MIRU','SUB16_19891030CHZH','SUB17_19921010XIHA','SUB18_19921211ZUKA'...
    'SUB19_19970603JOBE','SUB20_19970125FIGI','SUB21_19940526MISC','SUB22_19891024ROPU'...
    'SUB23_19811010CHZW','SUB24_20200918ANIO','SUB25_20200923MICA'};

nSubs = length(subjectIDs);
mask_fn = '/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz';
alignedGroupMap = cell(length(subjectIDs),1);

%% create maps based on different types of glm RSA analysis
for iSub = 1:nSubs
    individualMap = sprintf('%s_SS5_%s.nii.gz',level,subjectIDs{iSub});
    alignedGroupMap{iSub} = cosmo_fmri_dataset(fullfile(dataDir, individualMap), 'mask', mask_fn);
    switch level
        case {'sub_RN50','basic_RN50','super_RN50','MDS_RN50'}
            alignedGroupMap{iSub}.sa.targets = [1 2]';
            alignedGroupMap{iSub}.sa.chunks = zeros(2,1)+iSub;
        case {'levels_RN50'}
            alignedGroupMap{iSub}.sa.targets = [1 2 3 4]';
            alignedGroupMap{iSub}.sa.chunks = zeros(4,1)+iSub;
        case {'mds_sub_RN50','mds_basic_RN50','mds_super_RN50'}
            alignedGroupMap{iSub}.sa.targets = [1 2 3]';
            alignedGroupMap{iSub}.sa.chunks = zeros(3,1)+iSub;
    end
end

dsGroup = cosmo_stack(alignedGroupMap);
dsGroup = cosmo_remove_useless_data(dsGroup);
%% save data
cosmo_map2fmri(dsGroup, fullfile(resultsDir, sprintf('GROUP_%s.nii.gz',level)));



