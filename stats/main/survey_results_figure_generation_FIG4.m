# -----------------
% Script to generate Main Figure 4 in the study (Human-Machine Survey Results)
# -----------------

# The code and data of this repository are intended to promote transparent and reproducible research
# of the paper "Decoding biological age from face photographs using deep learning"

# All the details about the project can be found at the following webpage:
# aim.hms.harvard.edu/FaceAge

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# AIM 2022


% load data for part 1 of survey
load('survey_results_pt1.mat');

%%% FIGURE 4A %%%
% survey-taker 6-month survival prediction AUC
%   auc6mo:  survey-takers 6mo survival prediction AUC
%   job: occupation of survey-taker (1=staff, 3=resident, 4=lay)
%
%create figure
h = figure;
hold on
%
% barplot of
bar([1:5],sort(auc6mo(job == 1)))
bar(6.2,mean(auc6mo(job == 1)))
bar([8:10],sort(auc6mo(job == 3)))
bar(11.2,mean(auc6mo(job == 3)))
bar([13:14],sort(auc6mo(job == 4)))
bar(15.2,mean(auc6mo(job == 4)))
%  standard deviation bars on performance for each occupation grouping
errorbar(15.2,mean(auc6mo(job == 4)),std(auc6mo(job == 4)),std(auc6mo(job == 4)))
errorbar(11.2,mean(auc6mo(job == 3)),std(auc6mo(job == 3)),std(auc6mo(job == 3)))
errorbar(6.2,mean(auc6mo(job == 1)),std(auc6mo(job == 1)),std(auc6mo(job == 1)))
% NOTE: 95%-CI on ROCs were computed with 'pROC' (v1.17) package on R3.6.3
% using DeLong test to query significant difference from random performance
%
% set y-axis range and plot title
ylim([0.5 0.7])
title('survey-takers predicting 6 month survival by occupation')
%%%

%%% FIGURE 4B %%%
% NOTE: Kaplan-Meier analysis performed using Python Lifelines 0.23.4
% see file 'stats/Survey_taker_6mo_surv_pred_KM_analysis.py' in AIM FaceAge 
% GitHub repository.
%%%


%%% FIGURE 4C %%%
% predicted age to 6-month survival correspondence AUC 
%   auc:  survey-takers age prediction AUC
%   fa_auc: FaceAge AUC
%   auc_combined:  survey-takers + FaceAge prediction combined AUC
%
% sort from lowest to highest performance
auc = sort(auc); 
ci = sort(ci); 
auc_combined = sort(auc_combined); 
ci_combined = sort(ci_combined);
%
%create figure
h = figure;
hold on
%
% all survey-takers
bar([1:2],[mean(auc), mean(auc_combined)])  %barplot
plot([1:2],[auc' auc_combined'],'-bo');  %overlay datapoints and trendline
% 5 highest performing
bar([4:5],[mean(auc(6:10)), mean(auc_combined(6:10))])
plot([4:5],[auc(6:10)' auc_combined(6:10)'],'-bo');
% 5 lowest performing
bar([7:8],[mean(auc(1:5)), mean(auc_combined(1:5))])
plot([7:8],[auc(1:5)' auc_combined(1:5)'],'-bo');
% FaceAge
bar(10,fa_auc)
%
% set y-axis range and plot title
ylim([0.5 0.62])
title('Age prediction correspondence with 6-month survival')
%
% STATS: (Paired, 2-sided) Wilcoxon Signed Rank Test [h0: medians same]
% Survey-takers vs (Survey-takers+FaceAge)
fprintf('FIGURE 4C - Age correspondence with 6 month survival \n')
fprintf('Survey-takers vs Combined \n')
fprintf('overall: ')
signrank(auc,auc_combined)
fprintf('highest: ')
signrank(auc(6:10),auc_combined(6:10))
fprintf('lowest: ')
signrank(auc(1:5),auc_combined(1:5))
% Survey-takers vs FaceAge
fprintf('Survey-takers vs FaceAge \n')
fprintf('overall: ')
signrank(auc,fa_auc)
fprintf('highest: ')
signrank(auc(6:10),fa_auc)
fprintf('lowest: ')
signrank(auc(1:5),fa_auc)
% (Survey-takers+FaceAge) vs FaceAge
fprintf('Combined vs FaceAge \n')
fprintf('overall: ')
signrank(auc_combined,fa_auc)
fprintf('highest: ')
signrank(auc_combined(6:10),fa_auc)
fprintf('lowest: ')
signrank(auc_combined(1:5),fa_auc)
%%%


%load data for part 2 of survey
load('survey_results_pt2.mat');

%%% FIGURE 4D %%%
% AUCs for survey takers' 6 mo survival predictions without clinical aid, 
% with clinical chart info, and with clinical info + FaceAge risk model
%
AUC = [auc' auc_clin' auc_fa_clin'];
% get group mean AUC, but only for physicians (staff (1) + residents (3))
AUCmean = [mean(auc(job == 1 | job == 3)) ...
     mean(auc_clin(job == 1 | job == 3))...
     mean(auc_fa_clin(job == 1 | job == 3))   fa_risk_auc];
% x-coordinates for plotting purposes
X = [ones(10,1), 2*ones(10,1), 3*ones(10,1)]
%
%create figure
h = figure;
hold on
%
% 6-month survival AUC by age prediction
bar(AUCmean)
k = 1; % staff physicians
indx = find(job == k);
for i=1:numel(find(job == k))
plot(X(indx(i),:),AUC(indx(i),:),'-rd');
end
k = 3; % resident physicians
indx = find(job == k);
for i=1:numel(find(job == k))
plot(X(indx(i),:),AUC(indx(i),:),'-gs');
end
%
% set y-axis range and plot title
ylim([0.5 0.85])
title('Survey Part 2 - AUC')
%
% STATS: (Paired, 2-sided) Wilcoxon Signed Rank Test [h0: medians same]
% Survey-takers survival predictions (no aid, clinical, clinical+FArisk)
% and FaceAge risk model (FArisk)
fprintf('FIGURE 4D - Assisted Survival Prediction of Physicians - AUC \n')
fprintf('Unassisted vs FaceAge risk model: ')
signrank(auc(job == 1 | job == 3), fa_risk_auc)
fprintf('Clinical chart info vs FaceAge risk model: ')
signrank(auc_clin(job == 1 | job == 3), fa_risk_auc)
fprintf('Clinical chart and FaceAge risk model vs FaceAge risk model: ')
signrank(auc_fa_clin(job == 1 | job == 3), fa_risk_auc)
fprintf('Unassisted vs clinical chart info: ')
signrank(auc(job == 1 | job == 3), auc_clin(job == 1 | job == 3))
fprintf('Unassisted vs clinical chart and FaceAge risk model: ')
signrank(auc(job == 1 | job == 3), auc_fa_clin(job == 1 | job == 3))
fprintf('clinical chart vs clinical chart and FaceAge risk model: ')
signrank(auc_clin(job == 1 | job == 3), auc_fa_clin(job == 1 | job == 3))
%
CI = [ci' ci_clin' ci_fa_clin'];
% get group mean CI, but only for physicians (staff (1) + residents (3))
CImean = [mean(ci(job == 1 | job == 3)) ...
     mean(ci_clin(job == 1 | job == 3))...
     mean(ci_fa_clin(job == 1 | job == 3))   fa_risk_ci];
% x-coordinates for plotting purposes
X = [ones(10,1), 2*ones(10,1), 3*ones(10,1)]
%
%create figure
h = figure;
hold on
%
% 6-month survival CI by age prediction
bar(CImean)
k = 1; % staff physicians
indx = find(job == k);
for i=1:numel(find(job == k))
plot(X(indx(i),:),CI(indx(i),:),'-rd');
end
k = 3; % resident physicians
indx = find(job == k);
for i=1:numel(find(job == k))
plot(X(indx(i),:),CI(indx(i),:),'-gs');
end
%
% set y-axis range and plot title
ylim([0.5 0.75])
title('Survey Part 2 - C-index')
%
% STATS: (Paired, 2-sided) Wilcoxon Signed Rank Test [h0: medians same]
% Survey-takers survival predictions (no aid, clinical, clinical+FArisk)
% and FaceAge risk model (FArisk)
fprintf('FIGURE 4D - Assisted Survival Prediction of Physicians - C-index \n')
fprintf('Unassisted vs FaceAge risk model: ')
signrank(ci(job == 1 | job == 3), fa_risk_ci)
fprintf('Clinical chart info vs FaceAge risk model: ')
signrank(ci_clin(job == 1 | job == 3), fa_risk_ci)
fprintf('Clinical chart and FaceAge risk model vs FaceAge risk model: ')
signrank(ci_fa_clin(job == 1 | job == 3), fa_risk_ci)
fprintf('Unassisted vs clinical chart info: ')
signrank(ci(job == 1 | job == 3), ci_clin(job == 1 | job == 3))
fprintf('Unassisted vs clinical chart and FaceAge risk model: ')
signrank(ci(job == 1 | job == 3), ci_fa_clin(job == 1 | job == 3))
fprintf('clinical chart vs clinical chart and FaceAge risk model: ')
signrank(ci_clin(job == 1 | job == 3), ci_fa_clin(job == 1 | job == 3))
%%%
