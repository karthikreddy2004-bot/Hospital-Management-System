import React, { useEffect, useState, useCallback } from 'react';
import { getAppointments, createAppointment, updateAppointment, deleteAppointment } from '../api/appointmentApi';
import { getDoctors } from '../api/doctorApi';
import { getPatients } from '../api/patientApi';
import Pagination from '../components/Pagination';

const emptyForm = {
  patientId: '', doctorId: '', appointmentDate: '', appointmentTime: '',
  reason: '', status: 'SCHEDULED',
};

const STATUS_OPTIONS = ['SCHEDULED', 'COMPLETED', 'CANCELLED'];

const Appointments = () => {
  const [appointments, setAppointments] = useState([]);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [keyword, setKeyword] = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [doctorOptions, setDoctorOptions] = useState([]);
  const [patientOptions, setPatientOptions] = useState([]);

  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(emptyForm);
  const [formError, setFormError] = useState('');

  const fetchAppointments = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const res = await getAppointments(page, 10, 'appointmentDate', 'desc', keyword);
      setAppointments(res.data.content);
      setTotalPages(res.data.totalPages);
    } catch (err) {
      setError('Failed to load appointments');
    } finally {
      setLoading(false);
    }
  }, [page, keyword]);

  useEffect(() => {
    fetchAppointments();
  }, [fetchAppointments]);

  const loadDropdownOptions = async () => {
    try {
      const [docsRes, patsRes] = await Promise.all([
        getDoctors(0, 100, 'name', 'asc', ''),
        getPatients(0, 100, 'name', 'asc', ''),
      ]);
      setDoctorOptions(docsRes.data.content);
      setPatientOptions(patsRes.data.content);
    } catch (err) {
      setFormError('Failed to load doctors/patients list');
    }
  };

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    setPage(0);
    setKeyword(searchInput);
  };

  const openCreateModal = async () => {
    setEditingId(null);
    setForm(emptyForm);
    setFormError('');
    await loadDropdownOptions();
    setShowModal(true);
  };

  const openEditModal = async (appt) => {
    setEditingId(appt.id);
    setForm({
      patientId: appt.patientId, doctorId: appt.doctorId,
      appointmentDate: appt.appointmentDate, appointmentTime: appt.appointmentTime,
      reason: appt.reason || '', status: appt.status,
    });
    setFormError('');
    await loadDropdownOptions();
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
      const payload = {
        ...form,
        patientId: Number(form.patientId),
        doctorId: Number(form.doctorId),
        appointmentTime: form.appointmentTime.length === 5 ? `${form.appointmentTime}:00` : form.appointmentTime,
      };
      if (editingId) {
        await updateAppointment(editingId, payload);
      } else {
        await createAppointment(payload);
      }
      setShowModal(false);
      fetchAppointments();
    } catch (err) {
      setFormError(err.response?.data?.message || 'Failed to save appointment');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this appointment? This cannot be undone.')) return;
    try {
      await deleteAppointment(id);
      fetchAppointments();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to delete appointment');
    }
  };

  const statusBadgeClass = (status) => {
    if (status === 'COMPLETED') return 'badge-success';
    if (status === 'CANCELLED') return 'badge-danger';
    return 'badge-info';
  };

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>Appointments</h1>
        <button className="btn-primary" onClick={openCreateModal}>+ New Appointment</button>
      </div>

      <form className="search-bar" onSubmit={handleSearchSubmit}>
        <input
          type="text"
          placeholder="Search by patient, doctor, status, or reason..."
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
                <tr><th>Patient</th><th>Doctor</th><th>Date</th><th>Time</th><th>Status</th><th>Reason</th><th>Actions</th></tr>
              </thead>
              <tbody>
                {appointments.length === 0 ? (
                  <tr><td colSpan="7" className="empty-row">No appointments found.</td></tr>
                ) : (
                  appointments.map((a) => (
                    <tr key={a.id}>
                      <td>{a.patientName}</td>
                      <td>{a.doctorName} <span className="muted">({a.doctorSpecialization})</span></td>
                      <td>{a.appointmentDate}</td>
                      <td>{a.appointmentTime}</td>
                      <td><span className={`badge ${statusBadgeClass(a.status)}`}>{a.status}</span></td>
                      <td>{a.reason || '-'}</td>
                      <td className="actions">
                        <button className="btn-small" onClick={() => openEditModal(a)}>Edit</button>
                        <button className="btn-small btn-danger" onClick={() => handleDelete(a.id)}>Delete</button>
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
            <h2>{editingId ? 'Edit Appointment' : 'New Appointment'}</h2>
            {formError && <div className="alert alert-error">{formError}</div>}
            <form onSubmit={handleSubmit}>
              <div className="form-row">
                <div className="form-group">
                  <label>Patient</label>
                  <select name="patientId" value={form.patientId} onChange={handleFormChange} required>
                    <option value="">Select patient</option>
                    {patientOptions.map((p) => (
                      <option key={p.id} value={p.id}>{p.name} ({p.phone})</option>
                    ))}
                  </select>
                </div>
                <div className="form-group">
                  <label>Doctor</label>
                  <select name="doctorId" value={form.doctorId} onChange={handleFormChange} required>
                    <option value="">Select doctor</option>
                    {doctorOptions.map((d) => (
                      <option key={d.id} value={d.id}>{d.name} ({d.specialization})</option>
                    ))}
                  </select>
                </div>
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Date</label>
                  <input type="date" name="appointmentDate" value={form.appointmentDate} onChange={handleFormChange} required />
                </div>
                <div className="form-group">
                  <label>Time</label>
                  <input type="time" name="appointmentTime" value={form.appointmentTime?.slice(0, 5)} onChange={handleFormChange} required />
                </div>
              </div>
              <div className="form-group">
                <label>Reason</label>
                <input name="reason" value={form.reason} onChange={handleFormChange} placeholder="e.g. Routine checkup" />
              </div>
              {editingId && (
                <div className="form-group">
                  <label>Status</label>
                  <select name="status" value={form.status} onChange={handleFormChange}>
                    {STATUS_OPTIONS.map((s) => <option key={s} value={s}>{s}</option>)}
                  </select>
                </div>
              )}
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

export default Appointments;