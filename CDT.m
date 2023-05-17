function [xt, yt, MTOP] = CDT(pop1, pop2, taskid, MTOP)
% CDT - Cross-Dimensional Transfer
%
% Input:
% pop1   - population of the source task
% pop2   - population of the target task
% taskid - task ID used as input for function evaluation
% MTOP   - multi-task optimization problem instance
% 
% Output:
% xt     - transferred solution
% yt     - fitness of transferred solution
% MTOP   - updated MTOP instance
dim = size(pop1.pop, 2);
m1 = mean(pop1.pop, 1);
s1 = std(pop1.pop, 1);
m2 = mean(pop2.pop, 1);
s2 = std(pop2.pop, 1);
for d=1:dim
    wsd = zeros(1, dim);
    for j=1:dim
        wsd(j) = sqrt((m2(d)-m1(j))^2 + (s2(d)-s1(j))^2);
    end
    pr = 1 ./ (wsd + 1e-6);
    pr = pr / sum(pr);
    pr = cumsum(pr);
    seld = find(rand() <= pr);
    seld = seld(1);
    xt(d) = randn().* s1(seld) + m1(seld);
    xt(d) = max(0, min(1, xt(d)));
end
[yt, MTOP] = fitness(xt, taskid, MTOP);
end
