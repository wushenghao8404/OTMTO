function [oa] = constructOA(dim)
% constructOA - Orthogonal Array
%
% Input:
% dim   - dimensionality of the task
% 
% Output:
% oa    - orthogonal array with size M * dim
M = 2^ceil(log2(dim+1));
N = M - 1;
u = log2(M);
L = zeros(M, N);
for a=1:M
    for j=1:u
        L(a, 2^(j-1)) = mod(floor((a-1)/(2^(u-j))), 2);
    end
end
for a=1:M
    for j=2:u
        b = 2^(j-1);
        for s=1:b-1
            L(a, b+s) = mod(L(a, b) + L(a, s), 2);
        end
    end
end
L(:, dim+1:end) = [];
oa = L;
end