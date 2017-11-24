function HTPLDA = create_HTPLDA_extractor(F,nu,W)

    if nargin==0
        test_this();
        return;
    end

    [rdim,zdim] = size(F);
    assert(rdim>zdim);
    nu_prime = nu + rdim - zdim;
    
    if ~exist('W','var') || isempty(W)
        W = speye(rdim);
    end
    
    E = F.'*W*F;
    G = W - W*F*(E\F.')*W;

    SGME = create_SGME_calculator(E);
    
    V = SGME.V;  % E = VDV'
    VFW = V.'*F.'*W;
    
    HTPLDA.extractSGMEs = @extractSGMEs;
    HTPLDA.SGME = SGME;
    HTPLDA.plot_database = @plot_database;
    
    
    function [A,b] = extractSGMEs(R)
        q = sum(R.*(G*R),1);
        b = nu_prime./(nu+q);
        A = bsxfun(@times,b,VFW*R);
    end
    
    matlab_colours = {'r','g','b','m','c','k',':r',':g',':b',':m',':c',':k'}; 
    tikz_colours = {'red','green','blue','magenta','cyan','black','red, dotted','green, dotted','blue, dotted','magenta, dotted','cyan, dotted','black, dotted'}; 


    function plot_database(R,labels,Z)
        assert(max(labels) <= length(matlab_colours),'not enough colours to plot all speakers');
        [A,b] = extractSGMEs(R);
        %SGME.plotAll(A,b,matlab_colours(labels), tikz_colours(labels));
        SGME.plotAll(A,b,matlab_colours(labels), []);
        if exist('Z','var') && ~isempty(Z)
            for i=1:size(Z,2)
                plot(Z(1,i),Z(2,i),[matlab_colours{i},'*']);
            end
        end
            
    end
    

end

function test_this()

    zdim = 2;
    xdim = 20;      %required: xdim > zdim
    nu = 3;         %required: nu >= 1, integer, DF
    fscal = 3;      %increase fscal to move speakers apart
    
    F = randn(xdim,zdim)*fscal;

    
    HTPLDA = create_HTPLDA_extractor(F,nu);
    SGME = HTPLDA.SGME;
    
    %labels = [1,2,2];
    %[R,Z,precisions] = sample_HTPLDA_database(nu,F,labels);
    
    
    n = 30;
    m = 5;
    %prior = create_PYCRP(0,[],m,n);
    prior = create_PYCRP([],0,m,n);
    [R,Z,precisions,labels] = sample_HTPLDA_database(nu,F,prior,n);
    fprintf('there are %i speakers\n',max(labels));
    
    [A,b] = HTPLDA.extractSGMEs(R);
    
    rotate = true;
    [Ap,Bp] = SGME.SGME2GME(A,b,rotate);

    close all;
    figure;hold;
    plotGaussian(zeros(zdim,1),eye(zdim),'black, dashed','k--');
    
    %matlab_colours = {'b','r','r'};
    %tikz_colours = {'blue','red','red'};
    %SGME.plotAll(A,b,matlab_colours, tikz_colours, rotate);
    
    
    HTPLDA.plot_database(R,labels,Z);
    axis('square');axis('equal');
    
    
    
    %[precisions;b]
    
    %[plain_GME_log_expectations(Ap,Bp);SGME.log_expectations(A,b)]
    
    
    
end

