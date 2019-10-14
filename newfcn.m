function perf = sse(net,varargin)
%SSE Sum squared error performance function.
%
% <a href="matlab:doc sse">sse</a>(net,targets,outputs,errorWeights,...parameters...) calculates a
% network performance given targets, outputs, error weights and parameters
% as the sum of squared errors.
%
% Only the first three arguments are required.  The default error weight
% is {1}, which weights the importance of all targets equally.
%
% Parameters are supplied as parameter name and value pairs:
%
% 'regularization' - a fraction between 0 (the default) and 1 indicating
%    the proportion of performance attributed to weight/bias values. The
%    larger this value the network will be penalized for large weights,
%    and the more likely the network function will avoid overfitting.
%
% 'normalization' - this can be 'none' (the default), or 'standard', which
%   results in outputs and targets being normalized to [-1, +1], and
%   therefore errors in the range [-2, +2), or 'percent' which normalizes
%   outputs and targets to [-0.5, 0.5] and errors to [-1, 1].
%
% Here a network's performance with 0.1 regularization is calculated.
%
%   perf = <a href="matlab:doc sse">sse</a>(net,targets,outputs,{1},'regularization',0.1)
%
% To setup a network to us the same performance measure during training:
%
%   net.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> = '<a href="matlab:doc sse">sse</a>';
%   net.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.regularization">regularization</a> = 0.1;
%   net.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.normalization">normalization</a> = 'none';
%
% See also MSE, MAE, SAE.

% Copyright 1992-2012 The MathWorks, Inc.

% Function Info
if nargin > 0
    net = convertStringsToChars(net);
end

persistent INFO;
if isempty(INFO), INFO = nnModuleInfo(mfilename); end
if nargin == 0, perf = INFO; return; end

% NNET Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(net) && strcmp(net,'info')
  perf = INFO; return
elseif ischar(net) || ~(isa(net,'network') || isstruct(net))
  perf = nnet7.performance_fcn(mfilename,net,varargin{:}); return
end

% Arguments
param = nn_modular_fcn.parameter_defaults(mfilename);
[args,param,nargs] = nnparam.extract_param(varargin,param);
if (nargs < 2), error(message('nnet:Args:NotEnough')); end
t = args{1};
y = args{2};
if nargs < 3, ew = {1}; else ew = varargin{3}; end
net.performParam = param;
net.performFcn = mfilename;

% Apply
perf = nncalc.perform(net,t,y,ew,param);
