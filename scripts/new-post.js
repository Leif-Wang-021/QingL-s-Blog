import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { stringify } from "yaml";
import { normalizeTags } from "./content-tags.js";

const root = fileURLToPath(new URL("../src/content/posts/", import.meta.url));
const categories = {
	learning: "学习笔记",
	paper: "文献阅读",
	hardware: "硬件项目",
	software: "软件项目",
};
const outlines = {
	learning: ["学习背景", "核心概念", "示例与实践", "易错点与小结", "参考资料"],
	paper: [
		"文献与阅读目标",
		"问题背景",
		"方法与个人理解",
		"实验与复现记录",
		"局限与后续问题",
		"参考资料",
	],
	hardware: [
		"目标与当前阶段",
		"系统方案与参数",
		"实现过程",
		"测量与验证",
		"待解决问题",
		"参考资料",
	],
	software: [
		"项目定位与来源",
		"主要功能",
		"界面与使用",
		"下载与安装",
		"已知限制与反馈",
	],
};
const args = process.argv.slice(2).filter((arg) => arg !== "--");
if (!args.length || args.includes("--help")) {
	console.log(
		'用法：pnpm new-post <目录名> --type learning|paper|hardware|software --title "文章标题" --series "系列名" --order 1 --tags "标签1,标签2" [--dry-run]',
	);
	process.exit(args.length ? 0 : 1);
}
const directory = args.shift();
const options = {};
try {
	for (let i = 0; i < args.length; i++) {
		const name = args[i];
		if (name === "--dry-run") {
			options.dryRun = true;
			continue;
		}
		if (
			!["--type", "--title", "--series", "--order", "--tags"].includes(name) ||
			!args[i + 1] ||
			args[i + 1].startsWith("--")
		)
			throw new Error(`无效参数：${name}`);
		if (options[name]) throw new Error(`重复参数：${name}`);
		options[name] = args[++i];
	}
	const type = options["--type"] ?? "learning";
	if (!categories[type])
		throw new Error("请选择 learning、paper、hardware 或 software 模板。");
	const order = Number(options["--order"] ?? 1);
	if (!Number.isSafeInteger(order) || order < 1)
		throw new Error("系列序号必须是正整数。");
	if (/\.(md|mdx)$/i.test(directory))
		throw new Error(
			"请输入文章目录名，如 projects/my-project，图片放在同一目录。",
		);
	if (/[<>:"|?*]/.test(directory))
		throw new Error("目录名含 Windows 不支持的字符。");
	const target = path.resolve(root, directory, "index.md");
	const relative = path.relative(root, target);
	if (
		relative.startsWith("..") ||
		path.isAbsolute(relative) ||
		path.isAbsolute(directory)
	)
		throw new Error("文章目录必须位于 src/content/posts 内。");
	if (fs.existsSync(target)) throw new Error(`文章已存在：${target}`);
	const today = new Intl.DateTimeFormat("en-CA", {
		timeZone: "Asia/Shanghai",
		year: "numeric",
		month: "2-digit",
		day: "2-digit",
	}).format(new Date());
	const metadata = {
		title:
			options["--title"] ??
			(type === "software" && options["--series"] && order === 1
				? `${options["--series"]}（01）：项目介绍`
				: path.basename(directory)),
		published: today,
		description: "",
		image: "",
		tags: options["--tags"]
			? normalizeTags(options["--tags"].split(/[,，]/))
			: [],
		category: categories[type],
		series: options["--series"] ?? "",
		seriesOrder: options["--series"] ? order : undefined,
		draft: true,
		lang: "zh_CN",
	};
	const body = outlines[type]
		.map((heading) => `## ${heading}\n\n<!-- 在这里填写；完成后删除提示。 -->`)
		.join("\n\n");
	const content = `---\n${stringify(metadata)}---\n\n${body}\n\n## 更新记录\n\n- ${today}：首次发布（发布前填写完整并将 draft 改为 false）。\n`;
	if (options.dryRun) console.log(content);
	else {
		fs.mkdirSync(path.dirname(target), { recursive: true });
		fs.writeFileSync(target, content, { flag: "wx" });
		console.log(`已创建草稿：${target}`);
	}
} catch (error) {
	console.error(error.message);
	process.exitCode = 1;
}
