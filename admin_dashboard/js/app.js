// Drift_Mind Main Application Controller
import { fetchUsersFromFirebase, toggleUserStatusInFirebase, deleteUserFromFirebase, formatAppName, msToReadableTime } from './firebase-service.js';
import { initDashboardCharts, initScreenTimeCharts, initAppUsageCharts, initSleepCharts, initNotificationCharts, updateChartsTheme } from './charts.js';

let state = {
  users: [],
  filteredUsers: [],
  currentView: 'dashboard',
  theme: 'dark',
  searchQuery: '',
  riskFilter: 'all',
  statusFilter: 'all',
  currentPage: 1,
  pageSize: 8
};

document.addEventListener('DOMContentLoaded', async () => {
  console.log("🚀 Initializing Drift_Mind Real Telemetry Admin Dashboard...");

  const savedTheme = localStorage.getItem('driftmind_theme') || 'dark';
  setTheme(savedTheme);

  setupNavigation();
  setupThemeToggle();
  setupModalHandlers();
  setupSearchAndFilters();

  if (window.lucide) {
    window.lucide.createIcons();
  }

  await loadUserData();
});

async function loadUserData() {
  state.users = await fetchUsersFromFirebase();
  state.filteredUsers = [...state.users];

  renderKPICards();
  renderUserTable();

  initDashboardCharts(state.users);
  initScreenTimeCharts();
  initAppUsageCharts();
  initSleepCharts();
  initNotificationCharts(state.users);

  renderHeatmaps();
}

function setupNavigation() {
  const navItems = document.querySelectorAll('.nav-item[data-view]');
  navItems.forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      const targetView = item.getAttribute('data-view');
      switchView(targetView);
    });
  });
}

export function switchView(viewName) {
  state.currentView = viewName;

  document.querySelectorAll('.nav-item[data-view]').forEach(nav => {
    if (nav.getAttribute('data-view') === viewName) {
      nav.classList.add('active');
    } else {
      nav.classList.remove('active');
    }
  });

  document.querySelectorAll('.page-view').forEach(view => {
    if (view.id === `view-${viewName}`) {
      view.classList.add('active');
    } else {
      view.classList.remove('active');
    }
  });

  if (window.lucide) {
    window.lucide.createIcons();
  }
}

function setupThemeToggle() {
  const themeBtn = document.getElementById('themeToggleBtn');
  if (themeBtn) {
    themeBtn.addEventListener('click', () => {
      const newTheme = state.theme === 'dark' ? 'light' : 'dark';
      setTheme(newTheme);
    });
  }
}

function setTheme(theme) {
  state.theme = theme;
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('driftmind_theme', theme);
  updateChartsTheme(theme === 'dark');

  const themeIcon = document.querySelector('#themeToggleBtn i');
  if (themeIcon) {
    themeIcon.setAttribute('data-lucide', theme === 'dark' ? 'sun' : 'moon');
    if (window.lucide) window.lucide.createIcons();
  }
}

function setupModalHandlers() {
  const profileModal = document.getElementById('userProfileModal');
  const closeProfileBtn = document.getElementById('closeProfileModal');
  if (closeProfileBtn && profileModal) {
    closeProfileBtn.addEventListener('click', () => profileModal.classList.remove('active'));
  }
}

function renderKPICards() {
  const totalUsers = state.users.length;
  const activeToday = state.users.filter(u => u.screenTimeHours > 0 || u.status === 'Active').length;
  const avgScreenTime = totalUsers > 0 
    ? (state.users.reduce((acc, u) => acc + (u.screenTimeHours || 0), 0) / totalUsers).toFixed(1)
    : '0.0';
  const avgSleep = totalUsers > 0
    ? (state.users.reduce((acc, u) => acc + (u.sleepHours || 0), 0) / totalUsers).toFixed(1)
    : '0.0';
  const totalUnlocks = state.users.reduce((acc, u) => acc + (u.unlockCount || 0), 0);
  const totalNotifications = state.users.reduce((acc, u) => acc + (u.notificationsCount || 0), 0);

  updateDOMText('kpi-total-users', totalUsers);
  updateDOMText('kpi-active-today', activeToday);
  updateDOMText('kpi-avg-screentime', `${avgScreenTime}h`);
  updateDOMText('kpi-avg-sleep', `${avgSleep}h`);
  updateDOMText('kpi-total-unlocks', totalUnlocks);
  updateDOMText('kpi-total-notifications', totalNotifications);
  updateDOMText('kpi-notif-total', totalNotifications);
  updateDOMText('kpi-notif-avg', totalUsers > 0 ? Math.round(totalNotifications / totalUsers) : 0);
}

function updateDOMText(id, text) {
  const el = document.getElementById(id);
  if (el) el.textContent = text;
}

function renderUserTable() {
  const tableBody = document.getElementById('userTableBody');
  if (!tableBody) return;

  if (state.filteredUsers.length === 0) {
    tableBody.innerHTML = `<tr><td colspan="9" style="text-align: center; padding: 40px; color: var(--text-muted);">No users in Firestore yet. Syncing real-time from mobile app...</td></tr>`;
    return;
  }

  const startIdx = (state.currentPage - 1) * state.pageSize;
  const pageUsers = state.filteredUsers.slice(startIdx, startIdx + state.pageSize);

  tableBody.innerHTML = pageUsers.map(user => `
    <tr>
      <td>
        <div class="user-profile-cell">
          <img src="${user.avatar}" class="table-avatar" alt="${user.name}">
          <div class="user-name-box">
            <span class="name">${user.name}</span>
            <span class="email">${user.email}</span>
          </div>
        </div>
      </td>
      <td><strong>${user.readableScreenTime}</strong> <span style="font-size:0.7rem; color:var(--text-muted);">(${user.screenTimeHours} hrs)</span></td>
      <td>${user.sleepHours} hrs</td>
      <td>${user.unlockCount}</td>
      <td>${user.notificationsCount}</td>
      <td><strong>${user.lifestyleScore}</strong>/100</td>
      <td><span class="badge-risk risk-${user.riskLevel}">${user.riskLevel}</span></td>
      <td><span style="color: ${user.status === 'Active' ? 'var(--accent-emerald)' : 'var(--accent-rose)'}; font-weight:600;">${user.status}</span></td>
      <td>
        <div class="action-menu">
          <button class="btn-icon-small" title="View Profile" onclick="window.viewUserProfile('${user.id}')"><i data-lucide="eye"></i></button>
          <button class="btn-icon-small" title="Toggle Status" onclick="window.toggleUserStatus('${user.id}')"><i data-lucide="user-x"></i></button>
          <button class="btn-icon-small" title="Delete User" onclick="window.deleteUser('${user.id}')"><i data-lucide="trash-2"></i></button>
        </div>
      </td>
    </tr>
  `).join('');

  if (window.lucide) window.lucide.createIcons();

  updateDOMText('tablePaginationInfo', `Showing ${startIdx + 1} to ${Math.min(startIdx + state.pageSize, state.filteredUsers.length)} of ${state.filteredUsers.length} users`);
}

function setupSearchAndFilters() {
  const searchInput = document.getElementById('globalSearchInput');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      state.searchQuery = e.target.value.toLowerCase();
      applyFilters();
    });
  }

  const riskFilter = document.getElementById('riskFilterSelect');
  if (riskFilter) {
    riskFilter.addEventListener('change', (e) => {
      state.riskFilter = e.target.value;
      applyFilters();
    });
  }

  const statusFilter = document.getElementById('statusFilterSelect');
  if (statusFilter) {
    statusFilter.addEventListener('change', (e) => {
      state.statusFilter = e.target.value;
      applyFilters();
    });
  }

  const exportBtn = document.getElementById('exportUsersBtn');
  if (exportBtn) {
    exportBtn.addEventListener('click', exportUsersCSV);
  }
}

function applyFilters() {
  state.filteredUsers = state.users.filter(u => {
    const matchesSearch = u.name.toLowerCase().includes(state.searchQuery) || u.email.toLowerCase().includes(state.searchQuery);
    const matchesRisk = state.riskFilter === 'all' || u.riskLevel === state.riskFilter;
    const matchesStatus = state.statusFilter === 'all' || u.status === state.statusFilter;
    return matchesSearch && matchesRisk && matchesStatus;
  });
  state.currentPage = 1;
  renderUserTable();
}

window.viewUserProfile = function(userId) {
  const user = state.users.find(u => u.id === userId);
  if (!user) return;

  const modal = document.getElementById('userProfileModal');
  const body = document.getElementById('userProfileModalBody');
  if (!modal || !body) return;

  const appEntries = Object.entries(user.appUsage || {}).sort((a, b) => b[1] - a[1]);

  body.innerHTML = `
    <div style="display: flex; gap: 20px; align-items: center; border-bottom: 1px solid var(--border-glass); padding-bottom: 20px;">
      <img src="${user.avatar}" style="width: 80px; height: 80px; border-radius: 50%; border: 2px solid var(--accent-cyan);">
      <div>
        <h2>${user.name}</h2>
        <p style="color: var(--text-secondary);">${user.email} • ID: ${user.id}</p>
        <div style="display: flex; gap: 10px; margin-top: 8px;">
          <span class="badge-risk risk-${user.riskLevel}">${user.riskLevel} Risk</span>
          <span class="brand-badge">${user.status}</span>
        </div>
      </div>
    </div>
    
    <div class="kpi-grid" style="margin-top: 10px;">
      <div class="glass-card kpi-card">
        <span class="kpi-label">Firestore Screen Time</span>
        <span class="kpi-value">${user.readableScreenTime}</span>
        <span style="font-size:0.75rem; color:var(--text-muted);">${user.screenTimeMs.toLocaleString()} ms (${user.screenTimeHours} hrs)</span>
      </div>
      <div class="glass-card kpi-card">
        <span class="kpi-label">Sleep Telemetry</span>
        <span class="kpi-value">${user.sleepHours} hrs</span>
      </div>
      <div class="glass-card kpi-card">
        <span class="kpi-label">Unlocks Today</span>
        <span class="kpi-value">${user.unlockCount}</span>
      </div>
      <div class="glass-card kpi-card">
        <span class="kpi-label">Lifestyle Score</span>
        <span class="kpi-value" style="color: var(--accent-cyan);">${user.lifestyleScore}/100</span>
      </div>
    </div>

    <div class="glass-card" style="margin-top: 10px;">
      <h3 style="margin-bottom: 12px;">Real Application Usage Breakdown</h3>
      ${appEntries.length === 0 
        ? '<p style="color: var(--text-muted); font-size:0.85rem;">No application usage records present in Firestore for this user yet.</p>'
        : `<ul style="list-style: none; display: flex; flex-direction: column; gap: 10px;">
            ${appEntries.map(([pkgKey, ms]) => `
              <li style="display: flex; justify-content: space-between; font-size: 0.85rem; border-bottom: 1px solid var(--border-glass); padding-bottom: 6px;">
                <span>${formatAppName(pkgKey)}</span>
                <span style="font-weight: 700; color: var(--accent-indigo);">${msToReadableTime(ms)} (${(ms || 0).toLocaleString()} ms)</span>
              </li>
            `).join('')}
          </ul>`
      }
    </div>
  `;

  modal.classList.add('active');
};

window.toggleUserStatus = async function(userId) {
  const user = state.users.find(u => u.id === userId);
  if (!user) return;
  const newStatus = await toggleUserStatusInFirebase(userId, user.status);
  user.status = newStatus;
  applyFilters();
};

window.deleteUser = async function(userId) {
  if (confirm("Are you sure you want to delete this user document from Firestore?")) {
    await deleteUserFromFirebase(userId);
    state.users = state.users.filter(u => u.id !== userId);
    applyFilters();
    renderKPICards();
  }
};

function exportUsersCSV() {
  const headers = ["User ID", "Name", "Email", "Screen Time (Ms)", "Screen Time (Hrs)", "Sleep (Hrs)", "Unlocks", "Notifications", "Lifestyle Score", "Risk Level", "Status"];
  const rows = state.filteredUsers.map(u => [
    u.id, u.name, u.email, u.screenTimeMs, u.screenTimeHours, u.sleepHours, u.unlockCount, u.notificationsCount, u.lifestyleScore, u.riskLevel, u.status
  ]);

  const csvContent = "data:text/csv;charset=utf-8," 
    + [headers.join(","), ...rows.map(e => e.join(","))].join("\n");

  const encodedUri = encodeURI(csvContent);
  const link = document.createElement("a");
  link.setAttribute("href", encodedUri);
  link.setAttribute("download", `driftmind_ms_users_export_${new Date().toISOString().slice(0, 10)}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

function renderHeatmaps() {
  document.querySelectorAll('.heatmap-matrix').forEach(matrix => {
    let cellsHTML = '';
    for (let i = 0; i < 24; i++) {
      const level = Math.floor(Math.random() * 4) + 1;
      cellsHTML += `<div class="heatmap-cell heat-level-${level}" title="Hour ${i}:00 - Activity Level ${level}"></div>`;
    }
    matrix.innerHTML = cellsHTML;
  });
}
