function [out1,out2] = learngdm(varargin)
%LEARNGDM Gradient descent w/momentum weight/bias learning function.
%  
%  <a href="matlab:doc learngdm">learngdm</a> is the gradient descent with momentum weight/bias
%  learning function.
%  
%  <a href="matlab:doc learngdm">learngdm</a>(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%    W  - SxR weight matrix (or Sx1 bias vector).
%    P  - RxQ input vectors (or ones(1,Q)).
%    Z  - SxQ weighted input vectors.
%    N  - SxQ net input vectors.
%    A  - SxQ output vectors.
%    T  - SxQ layer target vectors.
%    E  - SxQ layer error vectors.
%    gW - SxR gradient with respect to performance.
%    gA - SxQ output gradient with respect to performance.
%    D  - SxS neuron distances.
%    LP - Learning parameters, none, LP = [].
%    LS - Learning state, initially should be = [].
%  and returns,
%    dW - SxR weight (or bias) change matrix.
%    LS - New learning state.
%
%  Learning occurs according to LEARNGDM's learning parameters,
%  shown here with their default values.
%    LP.lr - 0.01 - Learning rate
%    LP.mc - 0.9  - Momentum constant
%
%  <a href="matlab:doc learngdm">learngdm</a>(CODE) returns useful information for each CODE string:
%    'pnames'    - Returns names of learning parameters.
%    'pdefaults' - Returns default learning parameters.
%    'needg'     - Returns 1 if this function uses gW or gA.
%
%  Here we define a random gradient G for a weight going
%  to a layer with 3 neurons, from an input with 2 elements.
%  We also define a learning rate of 0.5 and momentum constant
%  of 0.8;
%
%    gW = rand(3,2);
%    lp.lr = 0.5;
%    lp.mc = 0.8;
%
%  <a href="matlab:doc learngdm">learngdm</a> only needs these values to calculate a weight
%  change. We will use the default initial learning state.
% 
%    ls = [];
%    [dW,ls] = <a href="matlab:doc learngdm">learngdm</a>([],[],[],[],[],[],[],gW,[],[],lp,ls)
%
%  See also LEARNGD, NEWFF, NEWCF, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2010 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Learning Functions.

  if nargin > 0
      [varargin{:}] = convertStringsToChars(varargin{:});
  end
  
  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info'
        out1 = INFO;
      case 'check_param'
        out1 = check_param(varargin{2});
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    [out1,out2] = apply(varargin{:});
  end
end

function sf = subfunctions
  sf.apply = @apply;
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnLearning(mfilename,'Gradient Descent with Momentum',...
    fcnversion,subfunctions,true,true,true,true, ...
    [ ...
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.01,...
    'Relative speed of learning.') ...
    nnetParamInfo('mc','Momentum Constant','nntype.real_0_to_1',0.9,...
    'Relative inertia in learning direction..') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [dw,ls] = apply(w,p,z,n,a,t,e,gW,gA,d,lp,ls)

  % Initial learning state
  if isempty(ls)
    ls.dw = lp.lr*gW;
  end
  
  % Gradient descent w/momentum rule
  if e(n+1)>1.04*e(n)
      lp.mc = 0.7*lp.mc;
  else
      dw = lp.mc*ls.dw + lp.lr*gW*a;
      lp.mc=1.05*lp.mc;
  end    
  % Next learning state
  ls.dw = dw;
       
end

