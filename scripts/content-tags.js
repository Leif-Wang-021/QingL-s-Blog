export const tagGroups = {
	领域: ["深度学习", "无线通信", "嵌入式开发", "鸿蒙应用", "可穿戴设备"],
	主题: [
		"神经网络",
		"通信 AI",
		"波束成形",
		"数据处理",
		"环境配置",
		"扫频",
		"超声波",
		"功率放大",
		"近眼显示",
		"漫画阅读",
		"轻小说阅读",
	],
	技术与工具: [
		"Python",
		"PyTorch",
		"张量",
		"WMMSE",
		"MATLAB",
		"STM32",
		"PWM",
		"COS",
		"树莓派",
		"Flutter",
		"HarmonyOS",
		"5G",
		"6G",
	],
};

export const tagAliases = {
	Tensor: ["张量"],
	tensor: ["张量"],
	pytorch: ["PyTorch"],
	通信AI: ["通信 AI"],
	"5G/6G": ["5G", "6G"],
	"加权 MMSE": ["WMMSE"],
	线性波束形成: ["波束成形"],
	波束形成: ["波束成形"],
	超声波屏蔽: ["超声波"],
	漫画: ["漫画阅读"],
	轻小说: ["轻小说阅读"],
	鸿蒙: ["HarmonyOS"],
};

const vocabulary = Object.values(tagGroups).flat();
export function normalizeTags(tags) {
	const canonical = [
		...new Set(
			tags
				.flatMap((tag) => tagAliases[tag.trim()] ?? [tag.trim()])
				.map(
					(tag) =>
						vocabulary.find(
							(known) => known.toLowerCase() === tag.toLowerCase(),
						) ?? tag,
				),
		),
	];
	const unknown = canonical.filter((tag) => !vocabulary.includes(tag));
	if (unknown.length)
		throw new Error(
			`未登记标签：${unknown.join("、")}。请在 scripts/content-tags.js 登记后使用。`,
		);
	return canonical.sort(
		(a, b) => vocabulary.indexOf(a) - vocabulary.indexOf(b),
	);
}
