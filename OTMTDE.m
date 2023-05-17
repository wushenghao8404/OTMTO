function [ data_MTDE ] = OTMTDE( MTOP, algparam )
% implementation of OTMTO for MTOP, reference: "Orthogonal Transfer for Multitask 
% Optimization", in IEEE TRANSACTIONS ON EVOLUTIONARY COMPUTATION

gv = load_global_variable();  % defined function to add path variable and some global setting such as number of runs
udim = MTOP.udim;
ntask = MTOP.ntask;
lb = MTOP.ulb;
ub = MTOP.uub;
nrun = algparam.nrun;
RunTime=zeros(nrun,1);
ps = algparam.ps;

for run=1:nrun
    [MTOP] = InstantiateMTOP(MTOP, run);
    tic
	disp(['run ' num2str(run)]);
    subps = ceil(ps/ntask)*ones(1,ntask);
    F = 0.5*ones(1,ntask);
    Cr = 0.6*ones(1,ntask);
    gby = 1e25*ones(1,ntask);
    gbx = ones(ntask,udim);
    
    % paramter setting for OTMTDE
    alpha = 0.9;
    pot = 0.5 * ones(ntask);
    pcdt = 0.5 * ones(ntask);

    gen = 1;
    
    for i=1:ntask
        lpop(i).pop = rand(subps(i),udim)*(ub-lb)+lb;
        lpop(i).fit = zeros(1,subps(i));
        for j=1:subps(i)
            [lpop(i).fit(j), MTOP] = fitness(lpop(i).pop(j, :), i, MTOP);
        end

        [gby(i),gbi] = min(lpop(i).fit);
        gbx(i,:) = lpop(i).pop(gbi,:);
    end
    
    while MTOP.fes<MTOP.maxfes
        disp([algparam.algname ' gen ' num2str(gen) ' fes ' num2str(MTOP.fes) ' afv ' num2str(mean(MTOP.gby(run, :)))]);

        for i=1:ntask
            % intra-task evolution
            vpop = zeros(subps(i),udim);
            upop = zeros(subps(i),udim);
            ufit = zeros(1,subps(i));

            for j=1:subps(i)
                % generate random vector index
                ro =randperm(subps(i));
                ro(ro == j) = [];
                r1 = ro(1);
                r2 = ro(2);
                r3 = ro(3);

                % mutation
                vpop(j,:)=lpop(i).pop(r1,:)+F(i)*(lpop(i).pop(r2,:)-lpop(i).pop(r3,:));  

                % crossover
                drnd = randi(udim);
                for d=1:udim
                    if d==drnd|| rand()<Cr(i)
                        upop(j,d)=vpop(j,d);
                    else
                        upop(j,d)=lpop(i).pop(j,d);
                    end
                end

                % constrain handling
                upop(j,:)=min(max(upop(j,:),lb),ub);
            end

            for j=1:subps(i)
                % evaluation
                [ufit(j), MTOP] = fitness(upop(j,:), i, MTOP);

                % update gbest
                if ufit(j) < gby(i)
                    gbx(i,:) = upop(j,:);
                    gby(i) = ufit(j);
                end

            end

            % selection
            mpop = [lpop(i).pop ; upop];
            mfit = [lpop(i).fit ufit];
            [~, si] = sort(mfit);
            lpop(i).pop = mpop(si(1:subps(i)), :);
            lpop(i).fit = mfit(si(1:subps(i)));
            [~, mi] = min(lpop(i).fit);
            if lpop(i).fit(mi) < gby(i)
                gbx(i,:) = lpop(i).pop(mi, :);
                gby(i) = lpop(i).fit(mi);
            end

            % source task selection
            si = randperm(ntask);
            si(si == i) = [];
            si = si(1);
            i1 = randi(subps(i));
            i2 = randi(subps(i));
            while i2 == i1
               i2 = randi(subps(i));
            end

            % ot
            if rand() < pot(i, si)

                % CTM
                [ mgbx ] = CTM( lpop(si), lpop(i) );

                % OT
                [xot, yot, MTOP] = OT(mgbx, lpop(i).pop(i1,:), i, MTOP);

                % calculate OT reward
                reward = 0;
                if yot < lpop(i).fit(i1)
                   lpop(i).pop(i1, :) = xot;
                   lpop(i).fit(i1) = yot;
                   reward = 1;
                end

                % update OT probability parameter
                pot(i, si) = alpha * pot(i, si) + (1 - alpha) * reward;
            end

            % cdt
            if rand() < pcdt(i, si)
                % CDT
                [xcdt, ycdt, MTOP] = CDT(lpop(si), lpop(i), i, MTOP);

                % calculate CDT reward
                reward = 0;
                if ycdt < lpop(i).fit(i2)
                   lpop(i).pop(i2, :) = xcdt;
                   lpop(i).fit(i2) = ycdt;
                   reward = 1;
                end

                % update CDT probability parameter
                pcdt(i, si) = alpha * pcdt(i, si) + (1 - alpha) * reward;
            end
        end
        gen=gen+1;
    end
    used_time=toc;
    RunTime(run)=used_time;
    gby = MTOP.gby(run, :);
    disp(used_time);
    disp(gby);
end

data_MTDE.evgby=MTOP.evgby;
data_MTDE.gby=MTOP.gby;
data_MTDE.gbx=MTOP.gbx;
data_MTDE.RunTime=RunTime;
end



