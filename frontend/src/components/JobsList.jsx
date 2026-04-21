import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import JobCard from "./JobCard";
import Pagination from "./Pagination";
import styles from "../styles/JobsList.module.css";

// time in milliseconds
const RANGE_MS = { "24h": 24 * 60 * 60 * 1000, week: 7 * 24 * 60 * 60 * 1000 };
const PAGE_SIZE = 10;

export default function JobsList({ jobs, dateType, range, sort }) {
	const [page, setPage] = useState(1);

	// reset page whenever filter or sort is changed
	useEffect(() => {
		setPage(1);
	}, [dateType, range, sort]);

	const cutoff = range === "all" ? null : Date.now() - RANGE_MS[range];

	const filtered = jobs.filter((job) => {
		if (cutoff === null) return true;
		const date = new Date(
			dateType === "applied" ? job.dateApplied : job.datePosted,
		).getTime();
		return date >= cutoff;
	});

	const sorted = [...filtered].sort((a, b) => {
		const dateA = new Date(
			dateType === "applied" ? a.dateApplied : a.datePosted,
		).getTime();
		const dateB = new Date(
			dateType === "applied" ? b.dateApplied : b.datePosted,
		).getTime();
		return sort === "newest" ? dateB - dateA : dateA - dateB;
	});

	const totalPages = Math.ceil(sorted.length / PAGE_SIZE);
	// slice the sorted results to only show the current page's jobs
	const paginated = sorted.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

	return sorted.length === 0 ? (
		<div className={styles.emptyState}>
			<span className={styles.emptyTitle}>No jobs here</span>
			<span className={styles.emptySubtitle}>
				Find jobs to save. When you do, they'll appear here to help you stay
				organized.
			</span>
		</div>
	) : (
		<>
			<div className={styles.listHeader}>
				<span className={styles.listHeaderJob}>Jobs</span>
			</div>
			<ul aria-label="Job listings">
				{paginated.map((job) => (
					<JobCard key={job.id} job={job} dateType={dateType} />
				))}
			</ul>
			{totalPages > 1 && (
				<Pagination
					page={page}
					totalPages={totalPages}
					onPrev={() => setPage((p) => p - 1)}
					onNext={() => setPage((p) => p + 1)}
				/>
			)}
		</>
	);
}

JobsList.propTypes = {
	jobs: PropTypes.arrayOf(PropTypes.object).isRequired,
	dateType: PropTypes.oneOf(["applied", "posted"]).isRequired,
	range: PropTypes.oneOf(["24h", "week", "all"]).isRequired,
	sort: PropTypes.oneOf(["newest", "oldest"]).isRequired,
};
