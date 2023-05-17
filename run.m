%% Calling the solvers
% For large population sizes, consider using the Parallel Computing Toolbox of MATLAB.
% Else, the program can be slow.
function [  ] = run(benchmark_name,probid,nrun)

gv = load_global_variable();
if  strcmp(benchmark_name,'CEC17MTO')
    addpath(gv.problem_path);
    addpath([gv.problem_path '\BasicFunction']);
    MTOP = CEC17MTO_benchmark(probid);
    % algorithm parameter
    algparam.algname = 'OTMTDE';
    algparam.nrun = nrun;
    algparam.ps = 100 * MTOP.ntask; % population size for multitasking  
    algparam.savetmpfile = true;
else
    error('Unexpected benchmark name');
end

disp(benchmark_name); 

if ~exist([gv.project_path '/Data/' benchmark_name 'data/' algparam.algname],'dir')
    mkdir([gv.project_path '/Data/' benchmark_name 'data/' algparam.algname]);
end

data_MTDE = OTMTDE( MTOP, algparam );

save([gv.project_path '/Data/' benchmark_name 'data/' algparam.algname '/result_' algparam.algname '_p' num2str(probid) '.mat'],'data_MTDE');
	
end

