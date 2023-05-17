function [y, MTOP] = fitness(x, taskid, MTOP)
    runid = MTOP.runid;
    ntask = MTOP.ntask;
    task = MTOP.Tasks(taskid);
    udim = MTOP.udim;
    dim = task.dim;
    vars = (task.Ub(1:dim) - task.Lb(1:dim)).*x(1:dim) + task.Lb(1:dim); % decoding
    y=task.fnc(vars);
    MTOP.fes=MTOP.fes+1;
    if MTOP.fes <= MTOP.maxfes
        if y < MTOP.gby(runid, taskid)
            MTOP.gby(runid, taskid) = y;
            MTOP.gbx(taskid, : , runid) = [x zeros(1, udim - length(x))];
        end
        if MTOP.fes == MTOP.recpts(MTOP.checkptID)
            begini = ntask*(runid-1)+1;
            endi = ntask*(runid-1)+ntask;
            MTOP.evgby(begini : endi, MTOP.checkptID)=MTOP.gby(runid, :)';
            MTOP.checkptID = MTOP.checkptID + 1;
        end
    end
end