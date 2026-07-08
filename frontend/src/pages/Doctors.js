import React, { useEffect, useState, useCallback } from 'react';
import { getDoctors, createDoctor, updateDoctor, deleteDoctor } from '../api/doctorApi';
import Pagination from '../components/Pagination';

const emptyForm = {
  name: '', specialization: '', email: '', phone: '',
  qualification: '', experienceYears: 0, consultationFee: 0, available: true,
};

const Doctors = () => {
  const [doctors, setDoctors] = useState([]);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [keyword, setKeyword] = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(emptyForm);
  const [formError, setFormError] = useState('');

  const fetchDoctors = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const res = await getDoctors(page, 10, 'name', 'asc', keyword);
      setDoctors(res.data.content);
      setTotalPages(res.data.totalPages);
    } catch (err) {
      setError('Failed to load doctors');
    } finally {
      setLoading(false);
    }
  }, [page, keyword]);

  useEffect(() => {
    fetchDoctors();
  }, [fetchDoctors]);

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    setPage(0);
    setKeyword(searchInput);
  };

  const openCreateModal = () => {
    setEditingId(null);
    setForm(emptyForm);
    setFormError('');
    setShowModal(true);
  };

  const openEditModal = (doc) => {
    setEditingId(doc.id);
    setForm({
      name: doc.name, specialization: doc.specialization, email: doc.email, phone: doc.phone,
      qualification: doc.qualification || '', experienceYears: doc.experienceYears || 0,
      consultationFee: doc.consultationFee || 0, available: doc.available,
    });
    setFormError('');
    setShowModal(true);
  };

  const handleFormChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({ ...prev, [name]: type === 'checkbox' ? checked : value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setFormError('');
    try {
      const payload = {
        ...form,
        experienceYears: Number(form.experienceYears),
        consultationFee: Number(form.consultationFee),
      };
      if (editingId) {
        await updateDoctor(editingId, payload);
      } else {
        await createDoctor(payload);
      }
      setShowModal(false);
      fetchDoctors();
    } catch (err) {
      setFormError(err.response?.data?.message || 'Failed to save doctor');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this doctor? This cannot be undone.')) return;
    try {
      await deleteDoctor(id);
      fetchDoctors();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to delete doctor');
    }
  };

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>Doctors</h1>
        <button className="btn-primary" onClick={openCreateModal}>+ Add Doctor</button>
      </div>

      <form className="search-bar" onSubmit={handleSearchSubmit}>
        <input
          type="text"
          placeholder="Search by name, specialization, email, or phone..."
          value={searchInput}
          onChange={(e) => setSearchInput(e.target.value)}
        />
        <button type="submit" className="btn-secondary">Search</button>
        {keyword && (
          <button type="button" className="btn-secondary" onClick={() => { setSearchInput(''); setKeyword(''); setPage(0); }}>
            Clear
          </button>
        )}
      </form>

      {error && <div className="alert alert-error">{error}</div>}

      {loading ? (
        <p>Loading...</p>
      ) : (
        <>
          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Name</th><th>Specialization</th><th>Email</th><th>Phone</th>
                  <th>Experience</th><th>Fee</th><th>Available</th><th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {doctors.length === 0 ? (
                  <tr><td colSpan="8" className="empty-row">No doctors found.</td></tr>
                ) : (
                  doctors.map((doc) => (
                    <tr key={doc.id}>
                      <td>{doc.name}</td>
                      <td>{doc.specialization}</td>
                      <td>{doc.email}</td>
                      <td>{doc.phone}</td>
                      <td>{doc.experienceYears} yrs</td>
                      <td>₹{doc.consultationFee}</td>
                      <td>
                        <span className={`badge ${doc.available ? 'badge-success' : 'badge-muted'}`}>
                          {doc.available ? 'Available' : 'Unavailable'}
                        </span>
                      </td>
                      <td className="actions">
                        <button className="btn-small" onClick={() => openEditModal(doc)}>Edit</button>
                        <button className="btn-small btn-danger" onClick={() => handleDelete(doc.id)}>Delete</button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
          <Pagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
        </>
      )}

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>{editingId ? 'Edit Doctor' : 'Add Doctor'}</h2>
            {formError && <div className="alert alert-error">{formError}</div>}
            <form onSubmit={handleSubmit}>
              <div className="form-row">
                <div className="form-group">
                  <label>Name</label>
                  <input name="name" value={form.name} onChange={handleFormChange} required />
                </div>
                <div className="form-group">
                  <label>Specialization</label>
                  <input name="specialization" value={form.specialization} onChange={handleFormChange} required />
                </div>
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Email</label>
                  <input type="email" name="email" value={form.email} onChange={handleFormChange} required />
                </div>
                <div className="form-group">
                  <label>Phone (10 digits)</label>
                  <input name="phone" value={form.phone} onChange={handleFormChange} required pattern="[0-9]{10}" />
                </div>
              </div>
              <div className="form-group">
                <label>Qualification</label>
                <input name="qualification" value={form.qualification} onChange={handleFormChange} />
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Experience (years)</label>
                  <input type="number" min="0" name="experienceYears" value={form.experienceYears} onChange={handleFormChange} />
                </div>
                <div className="form-group">
                  <label>Consultation Fee</label>
                  <input type="number" min="0" step="0.01" name="consultationFee" value={form.consultationFee} onChange={handleFormChange} />
                </div>
              </div>
              <div className="form-group checkbox-group">
                <label>
                  <input type="checkbox" name="available" checked={form.available} onChange={handleFormChange} />
                  {' '}Available for appointments
                </label>
              </div>
              <div className="modal-actions">
                <button type="button" className="btn-secondary" onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn-primary">{editingId ? 'Update' : 'Create'}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Doctors;