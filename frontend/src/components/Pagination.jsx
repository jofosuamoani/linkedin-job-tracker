import React from "react";
import PropTypes from "prop-types";
import styles from "../styles/Pagination.module.css";

export default function Pagination({ page, totalPages, onPrev, onNext }) {
	return (
		<div className={styles.pagination}>
			<button className={styles.button} onClick={onPrev} disabled={page === 1}>
				Previous
			</button>
			<span className={styles.label}>
				{page} / {totalPages}
			</span>
			<button className={styles.button} onClick={onNext} disabled={page === totalPages}>
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
