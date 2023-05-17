function [xt, yt, MTOP] = OT(ind1, ind2, taskid, MTOP)
% OT - Orthogonal Transfer
%
% Input:
% ind1   - individual solution of the source task
% ind2   - individual solution of the target task
% taskid - task ID used as input for function evaluation
% MTOP   - multi-task optimization problem instance
% 
% Output:
% xt     - transferred solution
% yt     - fitness of transferred solution
% MTOP   - updated MTOP instance
dim2 = length(ind2);
[oa] = constructOA(dim2);
M = size(oa, 1);
yb = 1e25;
xb = NaN(1,dim2);
xt = NaN(1, dim2);
fit = NaN(1, M);
for i=1:M
    x = ind1 .* (1 -oa(i,:)) + ind2 .* oa(i,:);
    [y, MTOP] = fitness(x, taskid, MTOP);
    fit(i) = y;
    if y < yb
        yb = y;
        xb = x;
    end
end
for d=1:dim2
    mf1 = mean(fit(oa(:,d) == 0));
    mf2 = mean(fit(oa(:,d) == 1));
    if mf1 < mf2
        xt(d) = ind1(d);
    else
        xt(d) = ind2(d);
    end
end

[yt, MTOP] = fitness(xt, taskid, MTOP); % fitness of exemplar

if yb < yt
    yt = yb;
    xt = xb;
end
end
