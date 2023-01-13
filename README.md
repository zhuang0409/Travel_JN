# Travel_JN
Here are the models and codes for the paper of The representation of observed actions at the subordinate, basic and superordinate level.



## Models:

  sub.mat: the model of the subordinate level, 

  basic.mat: the model of the basic level, 

  super.mat: the model of the superordinate level,

  humanRating_mds: the model obtained from human-rating experiment.


## Steps of programming

ROI-based analysis:

Fig4_ROI_analysis.m

Searchlight-based analysis:
Step1. RSA searchlight analysis - searchlight1_xx.m/searchlight2_xx.m/searchlight3_xx.m
Step2. Searchlight4_smoothdata.sh - smoothing data
Step3. Searchlight5_createStatMapRSA.m - to create maps for statistics
Step4. Searchlight6_TFCE_group.m - to make the statistic
Step5. Fig7_ConjunctionAnalysis.m - to compute the conjunction analysis

Additionally, 

vif.m: VIF analysis; 

Fig5_plot_rdm_mds.m: to visualize the regressed LOTC/V1 rdm and the corresponding mds; 

Fig2_plot_rdm_mds_histogram_of_human_rating_model.m: to visualze the rdm, mds, and histogram of human-rating results.

RN_reshape_to_fMRI.m: to change the order of stimuli with the neural conditions.Due to the order of the stimuli of RN50-based RDM is different with the the neural RDM, we used this function to keep the order of stimuli consistently. 

rotateXLabels.m: to rotate x axis labels.
