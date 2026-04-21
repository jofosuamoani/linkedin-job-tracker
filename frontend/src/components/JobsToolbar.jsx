import React from "react";
import PropTypes from "prop-types";
import styles from "../styles/JobsToolbar.module.css";

export default function JobsToolbar({
	dateType,
	setDateType,
	range,
	setRange,
	sort,
	setSort,
}) {
	return (
		<div className={styles.toolbar}>
			<label>
				<span className={styles.visuallyHidden}>Date type</span>
				<select
					className={styles.select}
					value={dateType}
					onChange={(e) => setDateType(e.target.value)}
				>
					<option value="applied">Date applied</option>
					<option value="posted">Date posted</option>
				</select>
			</label>
			<label>
				<span className={styles.visuallyHidden}>Date range</span>
				<select
					className={styles.select}
					value={range}
					onChange={(e) => setRange(e.target.value)}
				>
					<option value="24h">Past 24 hours</option>
					<option value="week">Past week</option>
					<option value="all">All time</option>
				</select>
			</label>
			<label>
				<span className={styles.visuallyHidden}>Sort order</span>
				<select
					className={styles.select}
					value={sort}
					onChange={(e) => setSort(e.target.value)}
				>
					<option value="newest">Sort by: Newest first</option>
					<option value="oldest">Sort by: Oldest first</option>
				</select>
			</label>
		</div>
	);
}

JobsToolbar.propTypes = {
	dateType: PropTypes.oneOf(["applied", "posted"]).isRequired,
	setDateType: PropTypes.func.isRequired,
	range: PropTypes.oneOf(["24h", "week", "all"]).isRequired,
	setRange: PropTypes.func.isRequired,
	sort: PropTypes.oneOf(["newest", "oldest"]).isRequired,
	setSort: PropTypes.func.isRequired,
};
