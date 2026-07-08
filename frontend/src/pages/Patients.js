import React, { useEffect, useState, useCallback } from 'react';
import { getPatients, createPatient, updatePatient, deletePatient } from '../api/patientApi';
import Pagination from '../components/Pagination';

const emptyForm = { name: '', age: '', gender: '', email: '', phone: '', address: '' };

const Patients = () => {
  const [patients, setPatients] = useState([]);
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

  const fetchPatients = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const res = await getPatients(page, 10, 'name', 'asc', keyword);
      setPatients(res.data.content);
      setTotalPages(res.data.totalPages);
    } catch (err) {
      setError('Failed to load patients');
    } finally {
      setLoading(false);
    }
  }, [page, keyword]);

  useEffect(() => {
    fetchPatients();
  }, [fetchPatients]);

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

  const openEditModal = (p) => {
    setEditingId(p.id);
    setForm({
      name: p.name, age: p.age || '', gender: p.gender || '',
      email: p.email || '', phone: p.phone, address: p.address || '',
    });
    setFormError('');
    setShowModal(true);
  };

  const handleFormChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setFormError('');
    try {
      const payload = { ...form, age: form.age ? Number(form.age) : null };
      if (editingId) {
        await updatePatient(editingId, payload);
      } else {
        await createPatient(payload);
      }
      setShowModal(false);
      fetchPatients();
    } catch (err) {
      setFormError(err.response?.data?.message || 'Failed to save patient');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this patient? This cannot be undone.')) return;
    try {
      await deletePatient(id);
      fetchPatients();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to delete patient');
    }
  };

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>Patients</h1>
        <button className="btn-primary" onClick={openCreateModal}>+ Add Patient</button>
      </div>

      <form className="search-bar" onSubmit={handleSearchSubmit}>
        <input
          type="text"
          placeholder="Search by name, phone, or email..."
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
                <tr><th>Name</th><th>Age</th><th>Gender</th><th>Phone</th><th>Email</th><th>Address</th><th>Actions</th></tr>
              </thead>
              <tbody>
                {patients.length === 0 ? (
                  <tr><td colSpan="7" className="empty-row">No patients found.</td></tr>
                ) : (
                  patients.map((p) => (
                    <tr key={p.id}>
                      <td>{p.name}</td>
                      <td>{p.age || '-'}</td>
                      <td>{p.gender || '-'}</td>
                      <td>{p.phone}</td>
                      <td>{p.email || '-'}</td>
                      <td>{p.address || '-'}</td>
                      <td className="actions">
                        <button className="btn-small" onClick={() => openEditModal(p)}>Edit</button>
                        <button className="btn-small btn-danger" onClick={() => handleDelete(p.id)}>Delete</button>
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
            <h2>{editingId ? 'Edit Patient' : 'Add Patient'}</h2>
            {formError && <div className="alert alert-error">{formError}</div>}
            <form onSubmit={handleSubmit}>
              <div className="form-row">
                <div className="form-group">
                  <label>Name</label>
                  <input name="name" value={form.name} onChange={handleFormChange} required />
                </div>
                <div className="form-group">
                  <label>Age</label>
                  <input type="number" min="0" name="age" value={form.age} onChange={handleFormChange} />
                </div>
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Gender</label>
                  <select name="gender" value={form.gender} onChange={handleFormChange}>
                    <option value="">Select</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Other">Other</option>
                  </select>
                </div>
                <div className="form-group">
                  <label>Phone</label>
                  <input name="phone" value={form.phone} onChange={handleFormChange} required />
                </div>
              </div>
              <div className="form-group">
                <label>Email</label>
                <input type="email" name="email" value={form.email} onChange={handleFormChange} />
              </div>
              <div className="form-group">
                <label>Address</label>
                <input name="address" value={form.address} onChange={handleFormChange} />
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

export default Patients;