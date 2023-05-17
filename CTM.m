function [ xm ] = CTM( pop1, pop2 )
% CTM - Cross Task Mapping
%
% Input:
% pop1   - population of the source task
% pop2   - population of the target task
% 
% Output:
% xm     - mapped global best solution
maxinfe = 250; % default setting = 250
infe = 0;
inps = 25;     % default setting = 25
inlb = 0.0;
inub = 1.0;
F = 0.5;
Cr = 0.9;
topn = 5;     % default setting = 5
[~, si1] = sort(pop1.fit);
spop1 = pop1.pop(si1, :);
ctr1 = mean(spop1, 1);
gbx1 = spop1(1, :);
[~, si2] = sort(pop2.fit);
spop2 = pop2.pop(si2, :);
ctr2 = mean(spop2, 1);
dim2 = size(spop2, 2);

fvec1 = zeros(1, topn);
for i=1:topn
    fvec1(i) = pdist2(spop1(i, :), gbx1);
end

rad1 = 0;
for i=1:size(spop1, 1)
    rad1 = rad1 + pdist2(ctr1, spop1(i,:));
end
rad1 = rad1 / size(spop1, 1);
rad2 = 0;
for i=1:size(spop2, 1)
    rad2 = rad2 + pdist2(ctr2, spop2(i,:));
end
rad2 = rad2 / size(spop2, 1);

fvec1 = fvec1 / rad1 * rad2;
inpop = spop2(1:inps, :);
infit = zeros(1, inps);
for i=1:inps
    infit(i) = internal_fitness(inpop(i, :), spop2, fvec1);
end
[ingby, mi] = min(infit);
ingbx = inpop(mi, :);
infe = infe + inps;
while infe < maxinfe
    invpop = zeros(inps,dim2);
    inupop = zeros(inps,dim2);
    inufit = zeros(1,inps);
    for i=1:inps
        % generate random vector index
        ro =randperm(inps);
        ro(ro == i) = [];
        r1 = ro(1);
        r2 = ro(2);

        % mutation
        invpop(i,:)=ingbx+F*(inpop(r1,:)-inpop(r2,:));  

        % crossover
        drnd = randi(dim2);
        for d=1:dim2
            if d==drnd|| rand()<Cr
                inupop(i,d)=invpop(i,d);
            else
                inupop(i,d)=inpop(i,d);
            end
        end

        % constrain handling
        inupop(i,:)=min(max(inupop(i,:),inlb),inub);

        % evaluation
        inufit(i)=internal_fitness(inupop(i,:), spop2, fvec1);
        infe=infe+1;

        % selection
        if inufit(i)<infit(i)
            inpop(i,:)=inupop(i,:);
            inpop(i)=inufit(i);
            if inufit(i)<ingby
                ingby=inufit(i);
                ingbx=inupop(i,:);
            end
        end 
   end
end
xm = ingbx; % mapped global best of target task
end

function [ y ] = internal_fitness( x, pop, fv1 )
    fv2 = zeros(1, length(fv1));
    for i=1:length(fv1)
        fv2(i) = pdist2(pop(i, :), x);
    end
    y = sum((fv1 - fv2).^2);
end
