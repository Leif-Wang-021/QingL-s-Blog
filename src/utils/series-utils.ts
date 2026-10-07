import { getSortedPosts } from "./content-utils";

export async function getSeriesList() {
	const posts = await getSortedPosts();
	const names = [
		...new Set(posts.map((post) => post.data.series).filter(Boolean)),
	];
	return names.map((name) => ({
		name,
		posts: posts
			.filter((post) => post.data.series === name)
			.sort(
				(a, b) =>
					(a.data.seriesOrder ?? Number.MAX_SAFE_INTEGER) -
					(b.data.seriesOrder ?? Number.MAX_SAFE_INTEGER),
			),
	}));
}

export function getSeriesAnchor(name: string) {
	return `series-${Array.from(name, (character) => character.codePointAt(0)?.toString(16)).join("-")}`;
}
