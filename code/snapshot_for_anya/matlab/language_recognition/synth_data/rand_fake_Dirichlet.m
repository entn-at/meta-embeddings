function R = rand_fake_Dirichlet(alpha,m,n)
% This is no longer Dirichlet. I replaced it with a faster ad-hoc
% distribution.
%
% Generates m-by-n matrix of n samples from m-category Dirichlet, with
% concentration parameter: alpha > 0.

    if nargin==0
        test_this();
        return;
    end

    %R = reshape(randgamma(alpha,1,m*n),m,n);
    R = exp(alpha*randn(m,n).^2);
    R = bsxfun(@rdivide,R,sum(R,1));


end


function E = app_exp(X)
  XX = X.^2/2;
  XXX = XX.*X/3;
  XXXX = XXX.*X/4;
  E = XXXX+ XXX + XX + X+1;
    
end

function test_this()

    close all;
    m = 400;
    %alpha = 1/(2*m);
    alpha = 2;
    
    n = 5000;
    R = rand_fake_Dirichlet(alpha,m,n);
    maxR = max(R,[],1);
    hist(maxR,100);

%      n = 50;
%      R = randDirichlet(alpha,m,n);
%      hist(R(:),100);
end

