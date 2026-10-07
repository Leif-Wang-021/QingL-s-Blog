import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseDocument } from "yaml";
import { normalizeTags } from "./content-tags.js";

const root = fileURLToPath(new URL("../src/content/posts/", import.meta.url));
const allowed = new Set(["学习笔记", "文献阅读", "硬件项目", "软件项目"]);
const series = new Map();
const titles = new Set();
const errors = [];
let published = 0;
let drafts = 0;
function walk(directory) {
	return fs
		.readdirSync(directory, { withFileTypes: true })
		.flatMap((entry) =>
			entry.isDirectory()
				? walk(path.join(directory, entry.name))
				: /\.(md|mdx)$/.test(entry.name)
					? [path.join(directory, entry.name)]
					: [],
		);
}
function date(value) {
	if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value))
		return false;
	const timestamp = Date.parse(`${value}T00:00:00Z`);
	return (
		Number.isFinite(timestamp) &&
		new Date(timestamp).toISOString().slice(0, 10) === value
	);
}
for (const file of walk(root)) {
	const fail = (message) =>
		errors.push(`${path.relative(root, file)}：${message}`);
	const source = fs.readFileSync(file, "utf8").replace(/\r\n/g, "\n");
	const match = source.match(/^---\n([\s\S]*?)\n---(?:\n|$)/);
	if (!match) {
		fail("缺少 frontmatter");
		continue;
	}
	const document = parseDocument(match[1]);
	if (document.errors.length) {
		fail(`YAML 错误：${document.errors[0].message}`);
		continue;
	}
	const data = document.toJS();
	if (data?.draft === true) {
		drafts++;
		continue;
	}
	if (!data || typeof data !== "object" || Array.isArray(data)) {
		fail("frontmatter 必须是对象");
		continue;
	}
	published++;
	if (
		typeof data.title !== "string" ||
		!data.title.trim() ||
		data.title.length > 65
	)
		fail("标题需非空且不超过 65 字符");
	if (titles.has(data.title)) fail("标题重复");
	titles.add(data.title);
	if (typeof data.description !== "string" || !data.description.trim())
		fail("请填写文章摘要");
	if (!allowed.has(data.category))
		fail("分类须为学习笔记、文献阅读、硬件项目或软件项目");
	if (
		!date(data.published) ||
		(data.updated && (!date(data.updated) || data.updated < data.published))
	)
		fail("日期须为有效 YYYY-MM-DD，更新日期不得早于发布时间");
	if (
		!Array.isArray(data.tags) ||
		data.tags.length < 2 ||
		data.tags.length > 5 ||
		data.tags.some((tag) => typeof tag !== "string" || !tag.trim()) ||
		new Set(data.tags).size !== data.tags.length
	)
		fail("请使用 2–5 个非空且不重复的标签");
	if (
		Array.isArray(data.tags) &&
		data.tags.every((tag) => typeof tag === "string")
	) {
		try {
			const canonical = normalizeTags(data.tags);
			if (JSON.stringify(data.tags) !== JSON.stringify(canonical))
				fail(`标签名称或顺序不规范，建议：${canonical.join("、")}`);
		} catch (error) {
			fail(error.message);
		}
	}
	if (
		data.category === "软件项目" &&
		data.series &&
		data.seriesOrder === 1 &&
		data.title !== `${data.series}（01）：项目介绍`
	)
		fail("软件项目首次介绍标题应为“系列名（01）：项目介绍”");
	if (data.series) {
		if (typeof data.series !== "string" || data.series !== data.series.trim())
			fail("系列名需为无首尾空格的文本");
		if (!Number.isSafeInteger(data.seriesOrder) || data.seriesOrder < 1)
			fail("系列序号需为正整数");
		const group = series.get(data.series) ?? {
			category: data.category,
			orders: new Set(),
		};
		if (group.category !== data.category) fail("同一系列必须使用同一分类");
		if (group.orders.has(data.seriesOrder)) fail("系列内序号重复");
		group.orders.add(data.seriesOrder);
		series.set(data.series, group);
	} else if (data.seriesOrder !== undefined) fail("填写序号时也需填写系列名");
	const body = source
		.slice(match[0].length)
		.replace(/<!--[\s\S]*?-->/g, "")
		.replace(/^(`{3,}|~{3,})[^\n]*\n[\s\S]*?^\1\s*$/gm, "");
	if (/^#\s/m.test(body)) fail("正文从二级标题 ## 开始");
	if (/深度学习P\d|P\d\.企划说明/.test(body))
		fail("请使用自动系列导航，移除旧编号");
	for (const image of body.matchAll(/!\[[^\]]*\]\(([^\s)]+)(?:\s+[^)]*)?\)/g)) {
		const src = image[1];
		if (/^(https?:|\/|data:)/.test(src)) continue;
		if (!fs.existsSync(path.resolve(path.dirname(file), src)))
			fail(`图片不存在：${src}`);
	}
}
if (errors.length) {
	console.error(errors.join("\n"));
	process.exitCode = 1;
} else
	console.log(
		`内容检查通过：${published} 篇公开文章，${series.size} 个系列；跳过 ${drafts} 篇草稿。`,
	);
