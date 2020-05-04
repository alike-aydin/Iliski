
function [hrf,p] = computehrf(RT, duration, P)
% returns a hemodynamic response function
% FORMAT [hrf,p] = spm_hrf(RT,[p]);
% RT   - scan repeat time
% p    - parameters of the response function (two gamma functions)
%
%							defaults
%							(seconds)
%	p(1) - delay of response (relative to onset)	   6
%	p(2) - delay of undershoot (relative to onset)    16
%	p(3) - dispersion of response			   1
%	p(4) - dispersion of undershoot			   1
%	p(5) - ratio of response to undershoot		   6
%	p(6) - onset (seconds)				   0
%	p(7) - length of kernel (seconds)		  32
%
% hrf  - hemodynamic response function
% p    - parameters of the response function
%_______________________________________________________________________
% @(#)spm_hrf.m	2.8 Karl Friston 02/07/31

% global parameter
% -----------------------------------------------------------------------
% global defaults
% if ~isempty(defaults),
% 	fMRI_T = defaults.stats.fmri.t;
% else
% 	fMRI_T = 16;
% end

% default parameters
%-----------------------------------------------------------------------
p = [6 1 0 1]; 
if nargin > 2
      p = P;
end

% Check on parameters0.5      
% if p(1)<=0; p(1)=0.0001;end
% if p(2)<=0; p(2)=0.0001;
% elseif p(2)>6; p(2)=6; end
% if p(3)<2; p(3)=2;end
% if p(4)<=0; p(4)=0.0001;end

% modelled hemodynamic response function - {mixture of Gammas}
%-----------------------------------------------------------------------
% dt    = RT;
% u     = [0:(duration/dt)] - p(3)/dt;
% hrf   = spm_Gpdf(u,p(1)/p(2),dt/p(2));
% 
% hrf   = hrf([0:(duration/RT)] + 1);
% hrf   = hrf'/sum(hrf);
% hrf= hrf*p(4);
u = [0:RT:duration];
hrf = p(4)*((u.^(p(1)-1)*p(2).^(p(1)).*exp(-p(2)*u))/gamma(p(1)));
hrf = [zeros(1, round(p(3)/RT)) hrf(1:end-round(p(3)/RT))];




