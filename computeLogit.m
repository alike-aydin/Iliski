function [logit, p] = computeLogit(dt, duration, P)
%
%
%

time = 0:dt:duration;

p = [3 7 1 2 0.3 0.3];
if nargin > 2
    p = P;
end

% Constraints: uncomment below
% if p(2)<p(1)
%     p(1)=1;
%     p(2)=2;
% end

e1 = (time - p(1))/p(3);
e2 = (time - p(2))/p(4);

logit = p(5)*(1./(1+exp(-e1))) - p(6)*(1./(1+exp(-e2)));
