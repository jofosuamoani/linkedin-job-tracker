import React, { useState, useEffect } from "react";
import { appliedJobs } from "./data/jobs";
import styles from "./styles/App.module.css";
import JobsToolbar from "./components/JobsToolbar";
import JobsList from "./components/JobsList";

function App() {
	const [jobs, setJobs] = useState([]);
	const [loading, setLoading] = useState(false);
	const [error, setError] = useState(null);
	const [dateType, setDateType] = useState(
		localStorage.getItem("dateType") ?? "applied",
	);
	const [range, setRange] = useState(localStorage.getItem("range") ?? "24h");
	const [sort, setSort] = useState(localStorage.getItem("sort") ?? "newest");

	// this is where data fetching from API would be done
	useEffect(() => {
		try {
			setLoading(true);
			setJobs(appliedJobs);
		} catch (e) {
			setError("Failed to load jobs. Please try again.");
		} finally {
			setLoading(false);
		}
	}, []);

	useEffect(() => {
		localStorage.setItem("dateType", dateType);
	}, [dateType]);
	useEffect(() => {
		localStorage.setItem("range", range);
	}, [range]);
	useEffect(() => {
		localStorage.setItem("sort", sort);
	}, [sort]);

	return (
		<div>
			<header className={styles.header}>
				<span className={styles.title}>Job tracker</span>
			</header>
			<main>
				{loading ? (
					<div className={styles.loading}>Loading jobs...</div>
				) : error ? (
					<div className={styles.error}>{error}</div>
				) : (
					<>
						<JobsToolbar
							dateType={dateType}
							setDateType={setDateType}
							range={range}
							setRange={setRange}
							sort={sort}
							setSort={setSort}
						/>
						<JobsList
							jobs={jobs}
							dateType={dateType}
							range={range}
							sort={sort}
						/>
					</>
				)}
			</main>
		</div>
	);
}

export default App;
