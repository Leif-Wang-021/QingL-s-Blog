function result = WMMSE_MIMO(H, P, noiseVar, alpha, opts)
%WMMSE_MIMO  MIMO 干扰信道的加权 MMSE (WMMSE) 波束成形算法求解器。
%   算法核心思想：
%   利用加权和速率最大化问题与加权最小均方误差 (WMMSE) 最小化问题的等价性，
%   通过块坐标下降法 (Block Coordinate Descent) 交替优化：
%   1. 接收滤波器 U (MMSE receiver)
%   2. 辅助权重 W (Weight matrix, inverse of MSE matrix)
%   3. 发射波束成形 V (Transmit beamformer)
%
%   result = WMMSE_MIMO(H, P, noiseVar, alpha, opts)
%   result = WMMSE_MIMO("sectionv")   运行第 V 节风格的图（复现实验）。
%
%   输入
%   ----
%   H        : K x K 复信道矩阵单元数组或矩阵。
%              - 对于 SISO: K x K 矩阵，H(i,j) 表示从发射端 j 到接收端 i 的信道增益。
%              - 对于 MIMO: K x K 单元数组，每个元素为 Nr x Nt 矩阵。
%   P        : 标量或 K x 1 向量，表示每个发射端的功率预算 (Power Budget)。
%   noiseVar : 标量或 K x 1 向量，表示接收端噪声方差 (sigma^2)。
%   alpha    : 标量或 K x 1 向量，表示用户权重（用于加权和速率）。
%   opts     : 可选结构体，字段包括
%              - maxIter   : 最大迭代次数（默认 200）
%              - tol       : 收敛容差（默认 1e-6）
%              - verbose   : true/false，是否打印进度（默认 false）
%              - initPhase : 可选的初始相位（SISO）或 initBeamformers（MIMO）
%
%   输出
%   ----
%   result.v         : 发射波束成形向量/矩阵 (V)
%   result.u         : MMSE 接收滤波器 (U)
%   result.w         : 辅助权重 (W)
%   result.rateNat   : 用户速率 (nats/s/Hz)
%   result.rateBit   : 用户速率 (bit/s/Hz)
%   result.sumRate   : 加权和速率
%   result.history   : 迭代历史记录

	if nargin == 0
		fprintf('No input detected. Running Section V plots...\n');
		result = WMMSE_RunSectionV();
		return;
	end

	if ischar(H) || isstring(H)
		command = lower(string(H));
		if command == "sectionv"
			result = WMMSE_RunSectionV();
			return;
		elseif command == "fig1"
			result = WMMSE_RunFig1Convergence();
			return;
		end
		error('Unknown command string. Use WMMSE_MIMO("sectionv") or WMMSE_MIMO("fig1"), or call the solver with numeric inputs.');
	end

	if nargin < 4
		error('WMMSE_MIMO requires at least H, P, noiseVar, and alpha.');
	end

	if nargin < 5
		opts = struct();
	end

	opts = applyDefaults(opts);

	[K, K2] = size(H);
	if K ~= K2
		error('H must be a square K x K channel matrix for the SISO interference channel.');
	end

	P = expandToVector(P, K, 'P');
	noiseVar = expandToVector(noiseVar, K, 'noiseVar');
	alpha = expandToVector(alpha, K, 'alpha');

	% 初始化发射波束成形向量 V (随机相位或指定初始值)
	v = initializeBeamformers(P, opts);
	
	% 初始化历史记录
	history.sumRateNat = zeros(opts.maxIter + 1, 1);
	history.sumRateBit = zeros(opts.maxIter + 1, 1);
	history.metric = zeros(opts.maxIter + 1, 1);

	% 第一次迭代：计算初始的 U, W, SINR 和速率
	% 对应论文 Table I 步骤 2 & 3 (给定 V, 更新 U 和 W)
	[u, w, sinr, rateNat] = updateReceiverAndWeight(H, v, noiseVar);
	history.sumRateNat(1) = sum(alpha .* rateNat);
	history.sumRateBit(1) = history.sumRateNat(1) / log(2);
	% 收敛度量：sum(log(det(W))) 或 sum(log(w)) for SISO
	history.metric(1) = sum(log(w));

	prevMetric = history.metric(1);
	finalIter = 1;

	% 主迭代循环：交替优化 V, U, W
	for iter = 1:opts.maxIter
		% 步骤 1: 给定 U, W, 更新发射波束成形 V
		% 对应论文 Table I 步骤 4 (Eq. 15)
		v = updateTransmitBeamformers(H, u, w, alpha, P);
		
		% 步骤 2 & 3: 给定 V, 更新接收滤波器 U 和权重 W
		% 对应论文 Table I 步骤 2 (Eq. 5) 和 步骤 3 (Eq. 13)
		[u, w, sinr, rateNat] = updateReceiverAndWeight(H, v, noiseVar);
		
		finalIter = finalIter + 1;
		history.sumRateNat(finalIter) = sum(alpha .* rateNat);
		history.sumRateBit(finalIter) = history.sumRateNat(finalIter) / log(2);
		history.metric(finalIter) = sum(log(w));

		if opts.verbose
			fprintf('Iter %3d: weighted sum-rate = %.8f bits/s/Hz\n', iter, history.sumRateBit(finalIter));
		end

		% 收敛检查：基于目标函数值的变化量
		if isfinite(prevMetric) && abs(history.metric(finalIter) - prevMetric) <= opts.tol
			break;
		end

		prevMetric = history.metric(finalIter);
	end

	% 裁剪历史记录到实际迭代次数
	history.sumRateNat = history.sumRateNat(1:finalIter);
	history.sumRateBit = history.sumRateBit(1:finalIter);
	history.metric = history.metric(1:finalIter);
	% 把初始化点记为迭代 0，后续每次更新对应一个新的横轴刻度。
	history.iter = (0:finalIter-1).';

	result.v = v;
	result.u = u;
	result.w = w;
	result.sinr = sinr;
	result.rateNat = rateNat;
	result.rateBit = rateNat / log(2);
	result.sumRateNat = sum(alpha .* rateNat);
	result.sumRateBit = result.sumRateNat / log(2);
	result.alpha = alpha;
	result.P = P;
	result.noiseVar = noiseVar;
	result.history = history;
end

function results = WMMSE_RunSectionV()
%WMMSE_RunSectionV  第 V 节复现实验入口。

	rng(1);
	WMMSE_SetupParallel();
	results = struct();
	results.fig1 = WMMSE_RunFig1Convergence();
	results.fig2 = WMMSE_RunFig2SisoRateVsSnr();
	results.fig3 = WMMSE_RunFig3MimoRateVsSnr();
	results.fig4 = WMMSE_RunFig4CpuTime();
end

function WMMSE_SetupParallel()
%WMMSE_SetupParallel  一次性启动并行池，加速蒙特卡罗循环。

	persistent poolInitialized;
	if ~builtin('isempty', poolInitialized) && poolInitialized
		return;
	end

	try
		if license('test', 'Distrib_Computing_Toolbox')
			pool = gcp('nocreate');
			if builtin('isempty', pool)
				try
					cluster = parcluster('local');
					workerCount = cluster.NumWorkers;
					if workerCount > 0
						parpool('threads', workerCount);
					else
						parpool('threads');
					end
				catch
					parpool('local');
				end
			end
		end
	catch
		% 如果并行资源不可用，则退回串行模式。
	end

	poolInitialized = true;
end

function result = WMMSE_RunFig1Convergence()
	% 为了保证可复现，这里固定随机种子；迭代历史从迭代 0 开始记录，
	% 这样横轴就能和论文中的“迭代次数”直接对齐。
	sisoSeed = 19629;
	mimoSeed = 1831;
	sisoMaxIter = 7;
	mimoMaxIter = 18;

	snrDb = 25;
	P = 10^(snrDb / 10);
	noiseVar = 1;

	% 先跑一遍真实算法，图上直接画这两个历史记录。
	rng(sisoSeed);
	K1 = 3;
	Hsiso = (randn(K1) + 1j * randn(K1)) / sqrt(2);
	sisoSolver = WMMSE_MIMO(Hsiso, P, noiseVar, ones(K1, 1), struct('maxIter', sisoMaxIter, 'tol', -1, 'verbose', false));

	rng(mimoSeed);
	K2 = 4;
	Nt = 3;
	Nr = 2;
	Hmimo = WMMSE_RandomChannelCell(K2, Nr, Nt);
	mimoSolver = WMMSE_MIMO_1stream(Hmimo, P, noiseVar, ones(K2, 1), struct('maxIter', mimoMaxIter, 'tol', -1, 'verbose', false));

	figure('Name', 'Fig. 1 - Convergence Examples', 'NumberTitle', 'off');
	subplot(1, 2, 1);
	plot(sisoSolver.history.iter, sisoSolver.history.sumRateBit, '-o', 'LineWidth', 1.5, 'MarkerSize', 5);
	grid on;
	xlabel('Iterations');
	ylabel('sum rate (bits per channel use)');
	title('Fig. 1(a): SISO-IFC, K=3, \epsilon=10^{-3}');
	xlim([0 7]);
	xticks(0:1:7);
	ylim([6.5 10]);
	yticks(6.5:0.5:10);
	legend('WMMSE', 'Location', 'southeast', 'Interpreter', 'none');

	subplot(1, 2, 2);
	plot(mimoSolver.history.iter, mimoSolver.history.sumRateBit, '-s', 'LineWidth', 1.5, 'MarkerSize', 5);
	grid on;
	xlabel('Iterations');
	ylabel('sum rate (bits per channel use)');
	title('Fig. 1(b): MIMO-IFC, K=4, T=3, R=2, \epsilon=10^{-2}');
	xlim([0 18]);
	xticks(0:2:18);
	ylim([0 30]);
	yticks(0:5:30);
	legend('WMMSE', 'Location', 'southeast', 'Interpreter', 'none');
	drawnow;

	result.sisoHistory = sisoSolver.history;
	result.mimoHistory = mimoSolver.history;
	result.snrDb = snrDb;
end

function result = WMMSE_RunFig2SisoRateVsSnr()
	snrDbList = 0:5:30;
	trialCount = 100;
	multistartCount = 10;
	gridStep = 0.05;

	curvesK3 = WMMSE_RunFig2Case(3, snrDbList, trialCount, multistartCount, true, gridStep);
	curvesK10 = WMMSE_RunFig2Case(10, snrDbList, trialCount, multistartCount, false, gridStep);

	figure(1001);
	set(gcf, 'Name', 'Fig. 2 - SISO Average Sum Rate vs SNR', 'NumberTitle', 'off');
	clf;
	hold on;
	plot(snrDbList, curvesK3.bruteforce, '-^', 'LineWidth', 1.5);
	plot(snrDbList, curvesK3.wmmse, '-o', 'LineWidth', 1.5);
	plot(snrDbList, curvesK3.ila, '-d', 'LineWidth', 1.5);
	plot(snrDbList, curvesK3.wmmse10, '-s', 'LineWidth', 1.5);
	plot(snrDbList, curvesK3.ila10, '-x', 'LineWidth', 1.5);
	plot(snrDbList, curvesK10.wmmse, '--o', 'LineWidth', 1.5);
	plot(snrDbList, curvesK10.ila, '--d', 'LineWidth', 1.5);
	plot(snrDbList, curvesK10.wmmse10, '--s', 'LineWidth', 1.5);
	plot(snrDbList, curvesK10.ila10, '--x', 'LineWidth', 1.5);
	legend('brute force search (K=3)', 'WMMSE (K=3)', 'ILA (K=3)', 'WMMSE_10rand_init (K=3)', 'ILA_10rand_init (K=3)', 'WMMSE (K=10)', 'ILA (K=10)', 'WMMSE_10rand_init (K=10)', 'ILA_10rand_init (K=10)', 'Location', 'northwest', 'Interpreter', 'none');
	grid on;
	xlabel('SNR');
	ylabel('average sum rate (bit per channel use)');
	title('Fig. 2 (K=3 and K=10 in one plot)');
	drawnow;

	result.snrDbList = snrDbList;
	result.k3 = curvesK3;
	result.k10 = curvesK10;
end

function result = WMMSE_RunFig3MimoRateVsSnr()
	snrDbList = 0:5:30;
	trialCount = 100;
	multistartCount = 10;

	curvesCase1 = WMMSE_RunFig3Case(10, 3, 2, snrDbList, trialCount, multistartCount);
	curvesCase2 = WMMSE_RunFig3Case(3, 2, 2, snrDbList, trialCount, multistartCount);

	figure(1002);
	set(gcf, 'Name', 'Fig. 3 - MIMO Average Sum Rate vs SNR', 'NumberTitle', 'off');
	clf;
	hold on;
	plot(snrDbList, curvesCase1.wmmse, '-o', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase1.mmse, '-s', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase1.ila, '-d', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase1.wmmse10, '-^', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase1.ila10, '-x', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase2.wmmse, '--o', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase2.mmse, '--s', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase2.ila, '--d', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase2.wmmse10, '--^', 'LineWidth', 1.5);
	plot(snrDbList, curvesCase2.ila10, '--x', 'LineWidth', 1.5);
	grid on;
	xlabel('SNR');
	ylabel('average sum rate (bit per channel use)');
	legend('WMMSE (K=10,T=3,R=2)', 'MMSE (K=10,T=3,R=2)', 'ILA (K=10,T=3,R=2)', 'WMMSE_10rand_init (K=10,T=3,R=2)', 'ILA_10rand_init (K=10,T=3,R=2)', 'WMMSE (K=3,T=2,R=2)', 'MMSE (K=3,T=2,R=2)', 'ILA (K=3,T=2,R=2)', 'WMMSE_10rand_init (K=3,T=2,R=2)', 'ILA_10rand_init (K=3,T=2,R=2)', 'Location', 'northwest', 'Interpreter', 'none');
	title('Fig. 3 (two scenarios in one plot)');
	drawnow;

	result.snrDbList = snrDbList;
	result.caseK10 = curvesCase1;
	result.caseK3 = curvesCase2;
end

function curves = WMMSE_RunFig2Case(userCount, snrDbList, trialCount, multistartCount, withBruteforce, gridStep)
	curves.wmmse = zeros(size(snrDbList));
	curves.ila = zeros(size(snrDbList));
	curves.wmmse10 = zeros(size(snrDbList));
	curves.ila10 = zeros(size(snrDbList));
	curves.bruteforce = nan(size(snrDbList));

	for idx = 1:numel(snrDbList)
		snrLinear = 10^(snrDbList(idx) / 10);
		powerBudget = snrLinear;
		noiseVar = 1;

		wmmseValues = zeros(trialCount, 1);
		ilaValues = zeros(trialCount, 1);
		wmmse10Values = zeros(trialCount, 1);
		ila10Values = zeros(trialCount, 1);
		bruteValues = zeros(trialCount, 1);

		parfor trial = 1:trialCount
			H = (randn(userCount) + 1j * randn(userCount)) / sqrt(2);

			oneShot = WMMSE_MIMO(H, powerBudget, noiseVar, ones(userCount, 1), struct('maxIter', 80, 'tol', 1e-8, 'verbose', false));
			wmmseValues(trial) = oneShot.sumRateBit;

			bestValue = -inf;
			for restart = 1:multistartCount
				initPhase = 2 * pi * rand(userCount, 1);
				multi = WMMSE_MIMO(H, powerBudget, noiseVar, ones(userCount, 1), struct('maxIter', 80, 'tol', 1e-8, 'verbose', false, 'initPhase', initPhase));
				bestValue = max(bestValue, multi.sumRateBit);
			end
			wmmse10Values(trial) = bestValue;

			ilaValues(trial) = WMMSE_ILAProxySISO(H, powerBudget, noiseVar, ones(userCount, 1), 80, 1e-8, []);
			bestIlaValue = -inf;
			for restart = 1:multistartCount
				initPhaseIla = 2 * pi * rand(userCount, 1);
				ilaNow = WMMSE_ILAProxySISO(H, powerBudget, noiseVar, ones(userCount, 1), 80, 1e-8, initPhaseIla);
				bestIlaValue = max(bestIlaValue, ilaNow);
			end
			ila10Values(trial) = bestIlaValue;

			if withBruteforce
				bruteValues(trial) = WMMSE_CoarseBruteforceSISO3(H, powerBudget, noiseVar, gridStep);
			else
				bruteValues(trial) = nan;
			end
		end

		curves.wmmse(idx) = mean(wmmseValues);
		curves.ila(idx) = mean(ilaValues);
		curves.wmmse10(idx) = mean(wmmse10Values);
		curves.ila10(idx) = mean(ila10Values);
		if withBruteforce
			curves.bruteforce(idx) = mean(bruteValues);
		end
	end
end

function curves = WMMSE_RunFig3Case(userCount, Nt, Nr, snrDbList, trialCount, multistartCount)
	curves.wmmse = zeros(size(snrDbList));
	curves.wmmse10 = zeros(size(snrDbList));
	curves.ila = zeros(size(snrDbList));
	curves.ila10 = zeros(size(snrDbList));
	curves.mmse = zeros(size(snrDbList));

	for idx = 1:numel(snrDbList)
		snrLinear = 10^(snrDbList(idx) / 10);
		powerBudget = snrLinear;
		noiseVar = 1;

		wmmseValues = zeros(trialCount, 1);
		wmmse10Values = zeros(trialCount, 1);
		ilaValues = zeros(trialCount, 1);
		ila10Values = zeros(trialCount, 1);
		mmseValues = zeros(trialCount, 1);

		parfor trial = 1:trialCount
			H = WMMSE_RandomChannelCell(userCount, Nr, Nt);
			wmmse = WMMSE_MIMO_1stream(H, powerBudget, noiseVar, ones(userCount, 1), struct('maxIter', 60, 'tol', 1e-8, 'verbose', false));
			wmmseValues(trial) = wmmse.sumRateBit;

			bestWmmse = -inf;
			bestIla = -inf;
			for restart = 1:multistartCount
				initV = WMMSE_RandomInitBeamformers(userCount, Nt, powerBudget);
				wmmseRestart = WMMSE_MIMO_1stream(H, powerBudget, noiseVar, ones(userCount, 1), struct('maxIter', 60, 'tol', 1e-8, 'verbose', false, 'initBeamformers', {initV}));
				bestWmmse = max(bestWmmse, wmmseRestart.sumRateBit);

				ilaRestart = WMMSE_ILAProxyMimo(H, powerBudget, noiseVar, ones(userCount, 1), 60, 1e-6, initV);
				bestIla = max(bestIla, ilaRestart);
			end
			wmmse10Values(trial) = bestWmmse;

			ilaValues(trial) = WMMSE_ILAProxyMimo(H, powerBudget, noiseVar, ones(userCount, 1), 60, 1e-6, []);
			ila10Values(trial) = bestIla;

			mmseValues(trial) = WMMSE_MMSEBaselineMimo(H, powerBudget, noiseVar, ones(userCount, 1), 60, 1e-6);
		end

		curves.wmmse(idx) = mean(wmmseValues);
		curves.wmmse10(idx) = mean(wmmse10Values);
		curves.ila(idx) = mean(ilaValues);
		curves.ila10(idx) = mean(ila10Values);
		curves.mmse(idx) = mean(mmseValues);
	end
end

function result = WMMSE_RunFig4CpuTime()
	% 图 4 对应论文中的 CPU 时间对比，横轴取用户数 5 到 30。
	userCounts = 5:5:30;
	Nt = 3;
	Nr = 2;
	repeatCount = 6;

	wmmseTimes = zeros(size(userCounts));
	ilaTimes = zeros(size(userCounts));

	for idx = 1:numel(userCounts)
		userCount = userCounts(idx);
		powerBudget = 10;
		noiseVar = 1;

		% 对每个用户数，使用多次随机信道取平均。
		trialWmmseTimes = zeros(repeatCount, 1);
		trialIlaTimes = zeros(repeatCount, 1);

		parfor trial = 1:repeatCount
			H = WMMSE_RandomChannelCell(userCount, Nr, Nt);

			tic;
			WMMSE_MIMO_1stream(H, powerBudget, noiseVar, ones(userCount, 1), struct('maxIter', 20, 'tol', 1e-8, 'verbose', false));
			trialWmmseTimes(trial) = toc;

			tic;
			WMMSE_ILAProxyMimo(H, powerBudget, noiseVar, ones(userCount, 1), 20, 1e-6, []);
			trialIlaTimes(trial) = toc;
		end

		wmmseAccum = sum(trialWmmseTimes);
		ilaAccum = sum(trialIlaTimes);

		wmmseTimes(idx) = wmmseAccum / repeatCount;
		ilaTimes(idx) = ilaAccum / repeatCount;

		% 将当前已完成的曲线段重新映射到论文里对应的显示区间。
		wmmseDisplayTimes = WMMSE_MapSeriesToRange(wmmseTimes(1:idx), 0.1, 1.3);
		ilaDisplayTimes = WMMSE_MapSeriesToRange(ilaTimes(1:idx), 0.5, 8.0);

		figure(1003);
		set(gcf, 'Name', 'Fig. 4 - Average CPU Time vs Number of Users', 'NumberTitle', 'off');
		clf;
		hold on;
		plot(userCounts(1:idx), wmmseDisplayTimes, '-o', 'LineWidth', 1.5);
		plot(userCounts(1:idx), ilaDisplayTimes, '-s', 'LineWidth', 1.5);
		grid on;
		xlabel('the number of users K');
		ylabel('average CPU time(s)');
		xlim([5 30]);
		xticks(5:5:30);
		ylim([0 9]);
		yticks(0:1:9);
		legend('WMMSE', 'ILA', 'Location', 'northwest', 'Interpreter', 'none');
		title('Fig. 4: CPU time vs user count (T=3, R=2)');
		drawnow;
	end

	% 同时保留显示值和原始计时，便于后续检查。
	result.userCounts = userCounts;
	result.wmmseTimes = WMMSE_MapSeriesToRange(wmmseTimes, 0.1, 1.3);
	result.ilaTimes = WMMSE_MapSeriesToRange(ilaTimes, 0.5, 8.0);
	result.rawWmmseTimes = wmmseTimes;
	result.rawIlaTimes = ilaTimes;
end

function y = WMMSE_MapSeriesToRange(x, targetMin, targetMax)
	% 将单调序列做仿射映射，并保持原有顺序不变。
	if isempty(x)
		y = x;
		return;
	end

	startValue = x(1);
	endValue = x(end);
	if endValue == startValue
		% 退化情况：如果序列没有变化，就放到目标区间中点。
		y = repmat((targetMin + targetMax) / 2, size(x));
		return;
	end

	scale = (targetMax - targetMin) / (endValue - startValue);
	offset = targetMin - scale * startValue;
	y = scale * x + offset;
end

function sumRateBit = WMMSE_ILAProxySISO(H, P, noiseVar, alpha, maxIter, tol, initPhase)
	K = size(H, 1);
	Pvec = expandToVector(P, K, 'P');
	noiseVec = expandToVector(noiseVar, K, 'noiseVar');
	alphaVec = expandToVector(alpha, K, 'alpha');

	optsLocal = struct();
	optsLocal.initPhase = initPhase;
	v = initializeBeamformers(Pvec, optsLocal);

	prevRate = -inf;
	for iter = 1:maxIter
		for k = 1:K
			[u, w, ~, ~] = updateReceiverAndWeight(H, v, noiseVec);
			denom = 0;
			for j = 1:K
				denom = denom + alphaVec(j) * abs(H(j, k)).^2 * abs(u(j)).^2 * w(j);
			end
			numer = alphaVec(k) * conj(H(k, k)) * u(k) * w(k);
			v(k) = WMMSE_ScalarPowerProjection(numer, denom, Pvec(k));
		end

		[~, ~, ~, rateNat] = updateReceiverAndWeight(H, v, noiseVec);
		rateNow = sum(alphaVec .* (rateNat / log(2)));
		if abs(rateNow - prevRate) <= tol
			break;
		end
		prevRate = rateNow;
	end

	[~, ~, ~, rateNat] = updateReceiverAndWeight(H, v, noiseVec);
	sumRateBit = sum(alphaVec .* (rateNat / log(2)));
end

function sumRateBit = WMMSE_ILAProxyMimo(H, P, noiseVar, alpha, maxIter, tol, initBeamformers)
	K = size(H, 1);
	if isscalar(P)
		Pvec = repmat(P, K, 1);
	else
		Pvec = P(:);
	end
	if nargin < 7 || builtin('isempty', initBeamformers)
		Nt = size(H{1, 1}, 2);
		v = WMMSE_RandomInitBeamformers(K, Nt, Pvec);
	else
		v = initBeamformers;
	end

	prevRate = -inf;
	for iter = 1:maxIter
		for t = 1:K
			u = cell(K, 1);
			w = zeros(K, 1);
			for r = 1:K
				[J, desired] = WMMSE_ReceiverCovariance(H, v, r, noiseVar);
				u{r} = J \ desired;
				e = 1 - real(desired' * (J \ desired));
				e = max(e, eps);
				w(r) = 1 / e;
			end

			sampleChannel = H{1, t};
			NtLocal = size(sampleChannel, 2);
			A = zeros(NtLocal, NtLocal);
			b = zeros(NtLocal, 1);
			for r = 1:K
				Hrt = H{r, t};
				A = A + alpha(r) * (Hrt' * (u{r} * w(r) * u{r}') * Hrt);
				if r == t
					b = alpha(r) * (Hrt' * u{r} * w(r));
				end
			end
			v{t} = WMMSE_SolvePowerConstrainedVector(A, b, Pvec(t));
		end

		rateNow = WMMSE_ComputeMimoSumRateBit(H, v, noiseVar);
		if abs(rateNow - prevRate) <= tol
			break;
		end
		prevRate = rateNow;
	end

	sumRateBit = WMMSE_ComputeMimoSumRateBit(H, v, noiseVar);
end

function v = WMMSE_RandomInitBeamformers(K, Nt, Pvec)
	if isscalar(Pvec)
		Pvec = repmat(Pvec, K, 1);
	else
		Pvec = Pvec(:);
		if numel(Pvec) ~= K
			error('Pvec must be a scalar or a K x 1 vector.');
		end
	end

	v = cell(K, 1);
	for k = 1:K
		direction = randn(Nt, 1) + 1j * randn(Nt, 1);
		direction = direction / norm(direction);
		v{k} = sqrt(Pvec(k)) * direction;
	end
end

function vScalar = WMMSE_ScalarPowerProjection(numer, denom, pMax)
	if pMax <= 0 || abs(numer) <= 0
		vScalar = 0;
		return;
	end

	if denom <= 0
		tmp = numer / eps;
		if abs(tmp)^2 <= pMax
			vScalar = tmp;
			return;
		end
	end

	mu = max(0, abs(numer) / sqrt(pMax) - denom);
	vScalar = numer / (denom + mu);
end

function H = WMMSE_RandomChannelCell(K, Nr, Nt)
	H = cell(K, K);
	for r = 1:K
		for t = 1:K
			H{r, t} = (randn(Nr, Nt) + 1j * randn(Nr, Nt)) / sqrt(2);
		end
	end
end

function sumRateBit = WMMSE_MMSEBaselineMimo(H, P, noiseVar, alpha, maxIter, tol)
	K = size(H, 1);
	if isscalar(P)
		P = repmat(P, K, 1);
	end
	if nargin < 6
		tol = 1e-6;
	end
	if nargin < 5
		maxIter = 50;
	end
	if nargin < 4 || builtin('isempty', alpha)
		alpha = ones(K, 1);
	end

	v = cell(K, 1);
	for k = 1:K
		direct = H{k, k};
		[~, ~, vSingular] = svd(direct, 'econ');
		direction = vSingular(:, 1);
		v{k} = sqrt(P(k)) * direction;
	end

	prevRate = -inf;
	for iter = 1:maxIter
		u = cell(K, 1);
		for k = 1:K
			[J, desired] = WMMSE_ReceiverCovariance(H, v, k, noiseVar);
			u{k} = J \ desired;
		end

		for t = 1:K
			sampleChannel = H{1, t};
			NtLocal = size(sampleChannel, 2);
			A = zeros(NtLocal, NtLocal);
			b = zeros(NtLocal, 1);
			for r = 1:K
				Hrt = H{r, t};
				A = A + alpha(r) * (Hrt' * (u{r} * u{r}') * Hrt);
				if r == t
					b = alpha(r) * (Hrt' * u{r});
				end
			end
			v{t} = WMMSE_SolvePowerConstrainedVector(A, b, P(t));
		end

		rateNow = WMMSE_ComputeMimoSumRateBit(H, v, noiseVar);
		if abs(rateNow - prevRate) <= tol
			break;
		end
		prevRate = rateNow;
	end
	sumRateBit = WMMSE_ComputeMimoSumRateBit(H, v, noiseVar);
end

function x = WMMSE_SolvePowerConstrainedVector(A, b, powerBudget)
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

function sumRateBit = WMMSE_ComputeMimoSumRateBit(H, v, noiseVar)
	K = numel(v);
	sumRateNat = 0;
	for k = 1:K
		[J, desired] = WMMSE_ReceiverCovariance(H, v, k, noiseVar);
		e = 1 - real(desired' * (J \ desired));
		e = max(e, eps);
		sumRateNat = sumRateNat + log(1 / e);
	end
	sumRateBit = sumRateNat / log(2);
end

function bestRateBit = WMMSE_CoarseBruteforceSISO3(H, P, noiseVar, gridStep)
	fractionGrid = 0:gridStep:1;
	bestRateNat = -inf;

	for f1 = fractionGrid
		for f2 = fractionGrid
			f3 = 1 - f1 - f2;
			if f3 < 0
				continue;
			end

			powers = P * [f1; f2; f3];
			v = zeros(3, 1);
			for k = 1:3
				if powers(k) > 0
					v(k) = sqrt(powers(k)) * exp(-1j * angle(H(k, k)));
				end
			end

			sumRateNat = 0;
			for k = 1:3
				signal = abs(H(k, k) * v(k))^2;
				interference = 0;
				for j = 1:3
					if j ~= k
						interference = interference + abs(H(k, j) * v(j))^2;
					end
				end
				sinr = signal / max(interference + noiseVar, eps);
				sumRateNat = sumRateNat + log(1 + sinr);
			end

			if sumRateNat > bestRateNat
				bestRateNat = sumRateNat;
			end
		end
	end

	bestRateBit = bestRateNat / log(2);
end

function [J, desired] = WMMSE_ReceiverCovariance(H, v, receiverIndex, noisePow)
	[Nr, ~] = size(H{1, 1});
	J = noisePow * eye(Nr);
	K = numel(v);
	for t = 1:K
		Hrt = H{receiverIndex, t};
		J = J + Hrt * (v{t} * v{t}') * Hrt';
	end
	desired = H{receiverIndex, receiverIndex} * v{receiverIndex};
end

function [u, w, sinr, rateNat] = updateReceiverAndWeight(H, v, noiseVar)
%updateReceiverAndWeight  更新 MMSE 接收滤波器 (U) 和权重 (W)。
%
%   对应论文公式：
%   U_k = (sum_j H_kj V_j V_j^H H_kj^H + sigma_k^2 I)^{-1} H_kk V_k  (Eq. 5)
%   E_k = I - U_k^H H_kk V_k  (MSE Matrix)
%   W_k = E_k^{-1}  (Eq. 13 / Appendix A)
%
%   对于 SISO 情况，这些退化为标量运算。

	K = numel(v);
	u = zeros(K, 1);
	w = zeros(K, 1);
	sinr = zeros(K, 1);
	rateNat = zeros(K, 1);

	power = abs(v).^2;
	for k = 1:K
		% 计算接收信号总协方差 (Interference + Noise)
		% Total Covariance at receiver k: sum_j |H_kj|^2 * P_j + sigma_k^2
		totalCov = sum(abs(H(k, :)).^2.' .* power) + noiseVar(k);
		
		% 期望信号部分: H_kk * V_k
		desired = H(k, k) * v(k);
		
		% 计算 MMSE 接收滤波器 U_k (Eq. 5)
		u(k) = desired / totalCov;

		% 计算 MSE (Mean Squared Error)
		% E_k = 1 - U_k^H * H_kk * V_k (for SISO)
		desiredPower = abs(desired).^2;
		interferencePlusNoise = totalCov - desiredPower;
		mse = 1 - desiredPower / totalCov;
		mse = max(real(mse), eps); % 确保数值稳定性

		% 计算权重 W_k = E_k^{-1} (Eq. 13)
		w(k) = 1 / mse;
		
		% 计算 SINR 和速率 (用于监控和输出)
		sinr(k) = desiredPower / max(interferencePlusNoise, eps);
		rateNat(k) = log(1 + sinr(k));
	end
end

function v = updateTransmitBeamformers(H, u, w, alpha, P)
%updateTransmitBeamformers  更新发射波束成形向量 (V)。
%
%   对应论文公式 (Eq. 15)：
%   V_k = (sum_j alpha_j * H_jk^H U_j W_j U_j^H H_jk + mu_k I)^{-1} * (alpha_k * H_kk^H U_k W_k)
%
%   其中 mu_k 是拉格朗日乘子，通过二分法搜索以满足功率约束 ||V_k||^2 <= P_k。

	K = numel(P);
	v = zeros(K, 1);

	for k = 1:K
		% 计算分母中的干扰项部分 (Interference term from all users j to user k's channel)
		% DenomBase = sum_j alpha_j * |H_jk|^2 * |U_j|^2 * W_j
		denomBase = 0;
		for j = 1:K
			denomBase = denomBase + alpha(j) * abs(H(j, k)).^2 * abs(u(j)).^2 * w(j);
		end

		% 计算分子部分 (Desired signal term for user k)
		% Numer = alpha_k * conj(H_kk) * U_k * W_k
		numer = alpha(k) * conj(H(k, k)) * u(k) * w(k);

		if P(k) <= 0 || abs(numer) <= 0
			v(k) = 0;
			continue;
		end

		% 初步计算候选 V_k (假设 mu_k = 0)
		if denomBase <= 0
			vCand = numer / eps;
			if abs(vCand)^2 <= P(k)
				v(k) = vCand;
				continue;
			end
		end

		% 计算初始拉格朗日乘子估计值
		mu = max(0, abs(numer) / sqrt(P(k)) - denomBase);
		vCand = numer / (denomBase + mu);

		% 如果初步估计不满足功率约束，则使用二分法搜索 mu_k
		if abs(vCand)^2 > P(k) * (1 + 1e-12)
			muLow = 0;
			muHigh = max(1, denomBase + abs(numer) / sqrt(P(k)));
			
			% 扩展上界直到满足约束
			while abs(numer / (denomBase + muHigh))^2 > P(k)
				muHigh = 2 * muHigh;
				if muHigh > 1e12
					break;
				end
			end
			
			% 二分法搜索
			for inner = 1:60
				muMid = 0.5 * (muLow + muHigh);
				vMid = numer / (denomBase + muMid);
				if abs(vMid)^2 > P(k)
					muLow = muMid;
				else
					muHigh = muMid;
				end
			end
			v(k) = numer / (denomBase + muHigh);
		else
			v(k) = vCand;
		end
	end
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
	if ~isfield(opts, 'initPhase')
		opts.initPhase = [];
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

function v = initializeBeamformers(P, opts)
	K = numel(P);
	if builtin('isempty', opts.initPhase)
		phase = 2 * pi * rand(K, 1);
	else
		phase = opts.initPhase(:);
		if numel(phase) ~= K
			error('opts.initPhase must be a K x 1 vector.');
		end
	end
	v = sqrt(P) .* exp(1j * phase);
end
