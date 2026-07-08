import React from 'react';

const Pagination = ({ currentPage, totalPages, onPageChange }) => {
  if (totalPages <= 1) return null;

  const pages = [];
  const maxButtons = 5;
  let start = Math.max(0, currentPage - Math.floor(maxButtons / 2));
  let end = Math.min(totalPages - 1, start + maxButtons - 1);
  if (end - start < maxButtons - 1) {
    start = Math.max(0, end - maxButtons + 1);
  }
  for (let i = start; i <= end; i++) pages.push(i);

  return (
    <div className="pagination">
      <button disabled={currentPage === 0} onClick={() => onPageChange(0)}>« First</button>
      <button disabled={currentPage === 0} onClick={() => onPageChange(currentPage - 1)}>‹ Prev</button>
      {pages.map((p) => (
        <button
          key={p}
          className={p === currentPage ? 'active' : ''}
          onClick={() => onPageChange(p)}
        >
          {p + 1}
        </button>
      ))}
      <button disabled={currentPage >= totalPages - 1} onClick={() => onPageChange(currentPage + 1)}>Next ›</button>
      <button disabled={currentPage >= totalPages - 1} onClick={() => onPageChange(totalPages - 1)}>Last »</button>
      <span className="page-info">Page {currentPage + 1} of {totalPages}</span>
    </div>
  );
};

export default Pagination;