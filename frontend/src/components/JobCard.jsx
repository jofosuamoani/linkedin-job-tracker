import React from "react";
import PropTypes from "prop-types";
import styles from "../styles/JobCard.module.css";

function logoColor(company) {
	const hue = [...company].reduce((acc, ch) => acc + ch.charCodeAt(0), 0) % 360;
	return `hsl(${hue}, 55%, 40%)`;
}

// calculate and format the time passed
function timeAgo(dateStr) {
	const diff = Date.now() - new Date(dateStr).getTime();
	const hours = Math.floor(diff / (1000 * 60 * 60));
	if (hours < 24) return `${hours}h`;
	const days = Math.floor(hours / 24);
	if (days < 7) return `${days}d`;
	return `${Math.floor(days / 7)}w`;
}

export default function JobCard({ job, dateType }) {
	const applied = `Applied ${timeAgo(job.dateApplied)} ago${job.statusNote ? ` (${job.statusNote})` : ""}`;
	const posted = `Posted ${timeAgo(job.datePosted)} ago`;

	return (
		<li className={styles.card} aria-label={`${job.title} at ${job.company}`}>
			<div
				className={styles.logo}
				style={{ backgroundColor: logoColor(job.company) }}
				aria-hidden="true"
			>
				{job.logoText}
			</div>
			<div className={styles.details}>
				<span className={styles.title}>{job.title}</span>
				<span className={styles.meta}>
					{job.company} · {job.location} ({job.workType})
				</span>
				{dateType === "applied" && (
					<span className={styles.sub}>{applied}</span>
				)}
				{dateType === "posted" && <span className={styles.sub}>{posted}</span>}
			</div>
		</li>
	);
}

JobCard.propTypes = {
	job: PropTypes.shape({
		id: PropTypes.number.isRequired,
		title: PropTypes.string.isRequired,
		company: PropTypes.string.isRequired,
		location: PropTypes.string.isRequired,
		workType: PropTypes.string.isRequired,
		dateApplied: PropTypes.string.isRequired,
		datePosted: PropTypes.string.isRequired,
		statusNote: PropTypes.string,
		logoText: PropTypes.string.isRequired,
	}).isRequired,
	dateType: PropTypes.oneOf(["applied", "posted"]).isRequired,
};
