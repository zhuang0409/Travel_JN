%% convert the order of stimuli as the same with fMRI data
% due to the order of the stimuli of RN50-based RDM is different with the
% the neural RDM, we used this function to keep the order of stimuli consistently. 
function X_sorted=RN_reshape_to_fMRI(X)

orderOfActions=[1:1:54,61:1:66,55:1:60,67:1:72];

X_sorted=X(orderOfActions, orderOfActions);