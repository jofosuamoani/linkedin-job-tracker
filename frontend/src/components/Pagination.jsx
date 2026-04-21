import React from "react";
import PropTypes from "prop-types";
import styles from "../styles/Pagination.module.css";

export default function Pagination({ page, totalPages, onPrev, onNext }) {
	return (
		<div
			className={styles.pagination}
			role="navigation"
			aria-label="Pagination"
		>
			<button
				className={styles.button}
				onClick={onPrev}
				disabled={page === 1}
				aria-label="Previous page"
			>
				Previous
			</button>
			<span className={styles.label} aria-current="page" aria-live="polite">
				{page} / {totalPages}
			</span>
			<button
				className={styles.button}
				onClick={onNext}
				disabled={page === totalPages}
				aria-label="Next page"
			>
				Next
			</button>
		</div>
	);
}

Pagination.propTypes = {
	page: PropTypes.number.isRequired,
	totalPages: PropTypes.number.isRequired,
	onPrev: PropTypes.func.isRequired,
	onNext: PropTypes.func.isRequired,
};
