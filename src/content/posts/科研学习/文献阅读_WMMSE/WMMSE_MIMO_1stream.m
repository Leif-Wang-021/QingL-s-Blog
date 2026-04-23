function result = WMMSE_MIMO_1stream(H, P, noiseVar, alpha, opts)
%WMMSE_MIMO_1stream  WMMSE for a single-stream MIMO interference channel.
%
%   H is a K x K cell array. H{r,t} is the channel from transmitter t to
%   receiver r, sized Nr x Nt. Each transmitter serves one receiver.
%
%   The function solves the single-stream version of the WMMSE iterations
%   described in the paper and is sufficient for the convergence and SNR
%   sweep figures in Section V.

    if nargin == 0
        K = 3;
        Nt = 2;
        Nr = 2;
        H = randomChannelCell(K, Nr, Nt);
        P = 10;
        noiseVar = 1;
        alpha = ones(K, 1);
        opts = struct();
        opts.maxIter = 20;
        opts.tol = 1e-8;
        opts.verbose = true;
        result = WMMSE_MIMO_1stream(H, P, noiseVar, alpha, opts);
        fprintf('Demo finished. Final weighted sum-rate = %.8f bit/s/Hz\n', result.sumRateBit);
        return;
    end

    if nargin < 4
        error('WMMSE_MIMO_1stream requires H, P, noiseVar, and alpha.');
    end

    if nargin < 5
        opts = struct();
    end

    if numel(opts) > 1
        if isfield(opts, 'initBeamformers')
            initAll = {opts.initBeamformers};
            opts = opts(1);
            opts.initBeamformers = initAll(:);
        else
            opts = opts(1);
        end
    end

    opts = applyDefaults(opts);

    [K, Hdim] = size(H);
    if K ~= Hdim
        error('H must be a K x K cell array.');
    end

    [Nr, Nt] = validateChannelDimensions(H);
    P = expandToVector(P, K, 'P');
    noiseVar = expandToVector(noiseVar, K, 'noiseVar');
    alpha = expandToVector(alpha, K, 'alpha');

    v = initializeBeamformers(K, Nt, P, opts);
    history.sumRateNat = zeros(opts.maxIter + 1, 1);
    history.sumRateBit = zeros(opts.maxIter + 1, 1);
    history.metric = zeros(opts.maxIter + 1, 1);

    [u, w, rateNat] = updateReceiverAndWeight(H, v, noiseVar);
    history.sumRateNat(1) = sum(alpha .* rateNat);
    history.sumRateBit(1) = history.sumRateNat(1) / log(2);
    history.metric(1) = sum(log(w));

    prevMetric = history.metric(1);
    finalIter = 1;

    for iter = 1:opts.maxIter
        v = updateTransmitters(H, u, w, alpha, P);
        [u, w, rateNat] = updateReceiverAndWeight(H, v, noiseVar);
        finalIter = finalIter + 1;
        history.sumRateNat(finalIter) = sum(alpha .* rateNat);
        history.sumRateBit(finalIter) = history.sumRateNat(finalIter) / log(2);
        history.metric(finalIter) = sum(log(w));

        if opts.verbose
            fprintf('Iter %3d: weighted sum-rate = %.8f bits/s/Hz\n', iter, history.sumRateBit(finalIter));
        end

        if isfinite(prevMetric) && abs(history.metric(finalIter) - prevMetric) <= opts.tol
            break;
        end

        prevMetric = history.metric(finalIter);
    end

    history.sumRateNat = history.sumRateNat(1:finalIter);
    history.sumRateBit = history.sumRateBit(1:finalIter);
    history.metric = history.metric(1:finalIter);
    % 记录初始化点对应的迭代 0，便于和论文横轴直接对齐。
    history.iter = (0:finalIter-1).';

    result.v = v;
    result.u = u;
    result.w = w;
    result.rateNat = rateNat;
    result.rateBit = rateNat / log(2);
    result.sumRateNat = sum(alpha .* rateNat);
    result.sumRateBit = result.sumRateNat / log(2);
    result.history = history;
    result.Nt = Nt;
    result.Nr = Nr;
end

function opts = applyDefaults(opts)
    if ~isfield(opts, 'maxIter') || builtin('isempty', opts.maxIter)
        opts.maxIter = 200;
    end
    if ~isfield(opts, 'tol') || builtin('isempty', opts.tol)
        opts.tol = 1e-6;
    end
    if ~isfield(opts, 'verbose') || builtin('isempty', opts.verbose)
        opts.verbose = false;
    end
    if ~isfield(opts, 'initBeamformers')
        opts.initBeamformers = [];
    end
end

function [Nr, Nt] = validateChannelDimensions(H)
    sample = H{1, 1};
    [Nr, Nt] = size(sample);
    for r = 1:size(H, 1)
        for t = 1:size(H, 2)
            current = H{r, t};
            if ~isequal(size(current), [Nr, Nt])
                error('All channel matrices must have the same size.');
            end
        end
    end
end

function x = expandToVector(x, K, name)
    if isscalar(x)
        x = repmat(x, K, 1);
        return;
    end

    x = x(:);
    if numel(x) ~= K
        error('%s must be a scalar or a %d x 1 vector.', name, K);
    end
end

function v = initializeBeamformers(K, Nt, P, opts)
    if builtin('isempty', opts.initBeamformers)
        v = cell(K, 1);
        for k = 1:K
            direction = randn(Nt, 1) + 1j * randn(Nt, 1);
            direction = direction / norm(direction);
            v{k} = sqrt(P(k)) * direction;
        end
    else
        v = opts.initBeamformers;
    end
end

function [u, w, rateNat] = updateReceiverAndWeight(H, v, noiseVar)
    K = numel(v);
    u = cell(K, 1);
    w = zeros(K, 1);
    rateNat = zeros(K, 1);

    for k = 1:K
        [J, desired] = totalCovariance(H, v, k, noiseVar(k));
        u{k} = J \ desired;
        e = 1 - real(desired' * (J \ desired));
        e = max(e, eps);
        w(k) = 1 / e;
        rateNat(k) = log(1 / e);
    end
end

function v = updateTransmitters(H, u, w, alpha, P)
    K = numel(u);
    v = cell(K, 1);

    for t = 1:K
        sampleChannel = H{1, t};
        Nt = size(sampleChannel, 2);
        A = zeros(Nt, Nt);
        b = zeros(Nt, 1);

        for r = 1:K
            Hrt = H{r, t};
            A = A + alpha(r) * (Hrt' * (u{r} * w(r) * u{r}') * Hrt);
            if r == t
                b = alpha(r) * (Hrt' * u{r} * w(r));
            end
        end

        v{t} = solvePowerConstrainedVector(A, b, P(t));
    end
end

function x = solvePowerConstrainedVector(A, b, powerBudget)
    if powerBudget <= 0
        x = zeros(size(b));
        return;
    end

    eyeMat = eye(size(A));
    x0 = (A + 1e-12 * eyeMat) \ b;
    if real(x0' * x0) <= powerBudget
        x = x0;
        return;
    end

    lowerBound = 0;
    upperBound = max(1, norm(b) / sqrt(powerBudget));
    while real(((A + upperBound * eyeMat) \ b)' * ((A + upperBound * eyeMat) \ b)) > powerBudget
        upperBound = 2 * upperBound;
        if upperBound > 1e12
            break;
        end
    end

    for iter = 1:60
        midpoint = 0.5 * (lowerBound + upperBound);
        xMid = (A + midpoint * eyeMat) \ b;
        if real(xMid' * xMid) > powerBudget
            lowerBound = midpoint;
        else
            upperBound = midpoint;
        end
    end
    x = (A + upperBound * eyeMat) \ b;
end

function [J, desired] = totalCovariance(H, v, k, noisePow)
    [Nr, ~] = size(H{1, 1});
    J = noisePow * eye(Nr);
    for j = 1:numel(v)
        Hj = H{k, j};
        J = J + Hj * (v{j} * v{j}') * Hj';
    end
    desired = H{k, k} * v{k};
end

function H = randomChannelCell(K, Nr, Nt)
    H = cell(K, K);
    for r = 1:K
        for t = 1:K
            H{r, t} = (randn(Nr, Nt) + 1j * randn(Nr, Nt)) / sqrt(2);
        end
    end
end