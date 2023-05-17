function [MTOP] = InstantiateMTOP(MTOP, runid)
MTOP.runid = runid;
MTOP.maxfes = MTOP.ntask * 1e5;
MTOP.ncheckpts = 100;
MTOP.recpts = ceil(linspace(1, MTOP.maxfes, MTOP.ncheckpts));
MTOP.checkptID = 1;
MTOP.fes = 0;
MTOP.gby(runid, :) = 1e25 * ones(1, MTOP.ntask);
MTOP.gbx(:, :, runid) = NaN(MTOP.ntask, MTOP.udim);
MTOP.evgby(MTOP.ntask*(runid-1)+1 : MTOP.ntask*(runid-1)+MTOP.ntask,:) = NaN(MTOP.ntask, MTOP.ncheckpts);
end