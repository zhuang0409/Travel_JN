%% Figure2. 
% plot RDM of human-rating model; 
% plot MDS of human-rating model; 
% Plot histgram of human-rating model
clc;clear;
%% load data; get dsm.mat
load('humanRating_mds.mat');
% label
nameVec={'to ride a motorbike';'to ride a bike';'to swim front crawl';...
    'to swim backstroke';'to drink beer';'to drink water';'to eat an apple';...
    'to eat cake';'to clean windows';'to brush teeth';'to do the dishes';'to clean the face'};

%% plot dendrogram
%% Hierarchical cluster analysis
figure
tree = linkage(dsm,'average');
H=dendrogram(tree,0,'ColorThreshold',0.176);
hylab =  ylabel('Average Distance');

for i = 1 : length(H)
    set(H(i), 'linewidth', 1.5);
end

orderOfactions = str2num(get(gca, 'xticklabel'));
set(gcf,'color','w');
fontSize=18;
set(gca, 'xticklabel', nameVec(orderOfactions),'Fontsize',fontSize);
rotateXLabels(gca, 45);
hleg=legend([H(1), H(3), H(6)],'locomotion','ingestion','cleaning','Fontsize',fontSize);
set(gca,'linewidth', 1.5)
set(gcf,'position',[0,0,1150,950])

%% plot RDM
figure;
X_sorted=dsm(orderOfactions, orderOfactions);
X_sorted=rescale(X_sorted,0,1);
f=imagesc(X_sorted);
yticks(1:1:12);
set(gca, 'xticklabel', '');
set(gca, 'yticklabel', nameVec(orderOfactions),'Fontsize',fontSize);
set(gcf,'color','w');
pbaspect([1 1 1]);
c=colorbar;
c.Label.String='Dissimilarity';
c.Label.FontSize=fontSize;
set(gcf,'position',[0,0,1500,850]);
axis square;

%% Multidimensional scaling analysis
figure;
y=cmdscale(dsm,2);
All = cmdscale(dsm);
plot(All(:,1),All(:,2),'.','LineWidth',1);
text(All(1:4,1),All(1:4,2),nameVec(1:4),'fontsize', fontSize,'color','r');
text(All(5:8,1),All(5:8,2),nameVec(5:8),'fontsize', fontSize,'color','b');
text(All(9:12,1),All(9:12,2),nameVec(9:12),'fontsize', fontSize,'color','g');
set(gca, 'xticklabel', '');
set(gca, 'yticklabel', '');
set(gcf,'color','w');
pbaspect([1 1 1]);
set(gca,'linewidth', 1.5);
set(gcf,'position',[0,0,900,850]);   