%% figure 5 to create RDMs and the corresponding MDSs
% codepath='H:\Travel\data\ExemData\progs\';
clc;clear;
labelfinal={'to ride a motorbike';'to ride a bike';'to swim front crawl';...
    'to swim backstroke';'to drink beer';'to drink water';'to eat an apple';...
    'to eat cake';'to clean windows';'to do the dishes';'to brush teeth';'to clean the face'};
fontSize=16;
projectDir = 'H:\Travel\data\ExemData\RSA\ROIs_based\data\';
fslist=dir([projectDir, '*.mat' ]);
rois='v1';% or 'lotc'
switch rois
    case 'lotc'
        l_ds=load([projectDir,fslist(1).name]);
        r_ds=load([projectDir,fslist(3).name]);
    case 'v1'
        l_ds=load([projectDir,fslist(2).name]);
        r_ds=load([projectDir,fslist(4).name]);
end
%% loop over subjects
for i=1:23
    ds_l=l_ds.ds_subj(i).samples;
    % left hemisphere
    % demean data
    ds_l_convert=ds_l-mean(ds_l,1);
    % squared euclidean distance
    ds_l_sq_vec(:,i)=cosmo_pdist(ds_l_convert,'squaredeuclidean');

    % right hemisphere
    ds_r=r_ds.ds_subj(i).samples;
    % center_data=true;
    ds_r_convert=ds_r-mean(ds_r,1);
    % squared euclidean distance
    ds_r_sq_vec(:,i)=cosmo_pdist(ds_r_convert,'squaredeuclidean');
end

% average across subjects
ds_l_sq=mean(ds_l_sq_vec,2);
ds_r_sq=mean(ds_r_sq_vec,2);
% average across hemisphere
ds_sq=(ds_l_sq+ds_r_sq)/2;

%% multiple-regression RSA
% the visual control model from RN50-1.
addpath('H:\EEGNet\results_ica\npy-matlab-master\npy-matlab');
modeldir='H:\Travel\data\Resnet50\outputs\';
matrixnames=dir([modeldir,'*.npy']);
data= readNPY([modeldir,matrixnames(1).name]);
modeldsm=squareform(VGG_reshape_to_fMRI(squeeze(data(1,:,:))));

%regress
X1=[modeldsm',ones(size(ds_sq))];
[b2,bint2,r1]=regress(ds_sq,X1);
% rescale residuals to 0-100
glm_rdm_sq=squareform(rescale(r1,0,100));

% RDM-visualization
figure;
imagesc(glm_rdm_sq);
% colorbar; cbh = colorbar;cbh.YTick = [0 100];
colormap(jet);axis square;
%set(gca, 'ytick', 1:6:72);set(gca,'yticklabel',labelfinal,'fontsize',fontSize);set(gca,'xticklabel','');
set(gca,'xticklabel','');set(gca,'yticklabel','');
set(gcf,'color','w');
%saveas([projectDir,sprintf('glm_rdm_sq_%s.mat',rois),gca]);

%% MDS-visualization
% color cfg.
colorcfg={[1,0,0],[1,0,0],[1,0,0],[1,0,0],...
    [0,0,1],[0,0,1],[0,0,1],[0,0,1],...
    [0,1,0],[0,1,0],[0,1,0],[0,1,0]};

colorfill={[1,0,0],[1,0,0],[1,1,1],[1,1,1],...
    [0,0,1],[0,0,1],[1,1,1],[1,1,1],...
    [0,1,0],[0,1,0],[1,1,1],[1,1,1]};

markercfg={'o','square','o','square','o','square','o','square','o','square','o','square'};

sz=50;% dots size
% mds
[coords_sq,stressVal_sq] =mdscale(glm_rdm_sq,2);
Y_sq= coords_sq;
% visualization
figure;
for k=1:12
    m=1+6*(k-1);
    n=6*k;
    scatter(Y_sq(m:n,1),Y_sq(m:n,2),sz,'MarkerEdgeColor',cell2mat(colorcfg(k)),...
         'MarkerFaceColor',cell2mat(colorfill(k)),'Marker',markercfg{k},...
         'LineWidth',1.5);
    hold on
end
axis square;
set(gcf,'color','w');
set(gca, 'yticklabel','');
set(gca, 'xticklabel','');
ylabel('Dimension 2','FontSize',fontSize);
xlabel('Dimension 1','FontSize',fontSize);
set(gcf,'color','w');
box on

