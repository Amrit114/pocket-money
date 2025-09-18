<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PocketTrack - Detailed Report</title>

<!-- External Fonts and Icons -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- Chart.js Library -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    /* General Body Styles */
    body {
        margin: 0;
        font-family: 'Segoe UI', sans-serif;
        background: linear-gradient(135deg, #4facfe, #00f2fe);
        background-attachment: fixed;
        color: #fff;
        display: flex;
    }

    /* Sidebar (Consistent with Dashboard) */
    .sidebar {
        width: 240px;
        background: rgba(0, 0, 0, 0.9);
        height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        box-shadow: 2px 0 10px rgba(0, 0, 0, 0.5);
        display: flex;
        flex-direction: column;
        padding: 20px 0;
        transition: width 0.3s ease;
        z-index: 100;
        overflow-x: hidden;
    }
    .sidebar-header { padding: 0 25px; margin-bottom: 30px; text-align: center; }
    .sidebar-header h2 { color: yellow; margin: 0; font-size: 1.6rem; white-space: nowrap; }
    .nav-links { list-style: none; padding: 0; margin: 0; flex-grow: 1; }
    .nav-links a { display: flex; align-items: center; padding: 15px 25px; color: #fff; text-decoration: none; font-weight: bold; transition: background-color 0.3s; white-space: nowrap; }
    .nav-links a.active, .nav-links a:hover { background: rgba(255, 255, 0, 0.2); }
    .nav-links a i { margin-right: 15px; width: 20px; text-align: center; font-size: 1.1rem; }

    /* Main Content Area */
    .main-content {
        margin-left: 240px;
        flex-grow: 1;
        padding: 30px;
        transition: margin-left 0.3s ease;
        animation: fadeIn 1s ease-in-out;
    }
    .header { margin-bottom: 30px; }
    .header h1 { margin: 0; font-size: 2.5rem; font-weight: 700; }
    .header p { margin: 5px 0 0; color: rgba(255, 255, 255, 0.9); font-size: 1.2rem; }

    /* Glassmorphism Container */
    .container {
        background: rgba(0, 0, 0, 0.4);
        backdrop-filter: blur(10px);
        padding: 30px;
        border-radius: 15px;
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.2);
        border: 1px solid rgba(255, 255, 255, 0.18);
    }
    
    /* Filter Controls */
    .filter-controls {
        display: flex;
        gap: 20px;
        margin-bottom: 30px;
        align-items: center;
        flex-wrap: wrap;
    }
    .filter-group {
        display: flex;
        flex-direction: column;
    }
    .filter-group label {
        font-size: 0.9rem;
        margin-bottom: 5px;
        font-weight: 600;
    }
    .filter-group input {
        background: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        color: #fff;
        padding: 8px 12px;
        border-radius: 6px;
        font-family: 'Segoe UI', sans-serif;
    }
    .search-bar { flex-grow: 1; }
    
    /* Table Styling */
    .table-responsive { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    th, td { padding: 12px 15px; text-align: left; }
    th { background-color: rgba(255, 255, 255, 0.1); font-weight: 600; font-size: 0.9rem; text-transform: uppercase; cursor: pointer; }
    th .sort-icon { margin-left: 5px; opacity: 0.5; }
    td { border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
    tbody tr:hover { background-color: rgba(255, 255, 255, 0.05); }

    /* Report Layout and Actions */
    .report-layout { display: grid; grid-template-columns: 2fr 1fr; gap: 30px; }
    .report-actions { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; flex-wrap: wrap; }
    .total { font-weight: bold; font-size: 1.2rem; }
    .btn { background: rgba(255, 255, 255, 0.15); color: #fff; padding: 10px 20px; border: 1px solid rgba(255,255,255,0.2); border-radius: 8px; text-decoration: none; cursor: pointer; font-weight: 600; transition: all 0.3s ease; }
    .btn:hover { background: rgba(255, 255, 255, 0.25); transform: translateY(-2px); }
    .btn i { margin-right: 8px; }

    /* Chart Section */
    .chart-section h3 { margin-top: 0; font-size: 1.5rem; text-align: center; margin-bottom: 20px; }
    
    .empty-state { text-align: center; padding: 60px 20px; }
    .empty-state i { font-size: 3.5rem; margin-bottom: 20px; color: rgba(255, 255, 255, 0.8); }
    .empty-state h3 { font-size: 1.5rem; margin: 0 0 10px 0; }
    .empty-state p { margin: 0; color: rgba(255, 255, 255, 0.8); }

    @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    
    /* Responsive */
    @media (max-width: 1024px) {
        .report-layout { grid-template-columns: 1fr; }
    }
    @media (max-width: 768px) {
        body { flex-direction: column; }
        .sidebar { width: 100%; height: auto; position: relative; }
        .main-content { margin-left: 0; padding: 20px; }
        .header h1 { font-size: 2rem; }
    }
</style>
<link rel="stylesheet" href="style.css">
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header"><h2><i class="fas fa-wallet"></i> <span>Pocket Tracker</span></h2></div>
        <ul class="nav-links">
            <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> <span>Dashboard</span></a></li>
            <li><a href="addExpenses.jsp"><i class="fas fa-plus-circle"></i> <span>Add Expense</span></a></li>
            <li><a href="report.jsp" class="active"><i class="fas fa-file-alt"></i> <span>Detailed Reports</span></a></li>
            <li><a href="mreports.jsp"><i class="fas fa-calendar-alt"></i> <span>Monthly Reports</span></a></li>
            <li><a href="monthcat.jsp"><i class="fas fa-chart-pie"></i> <span>Category Reports</span></a></li>
            <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> <span>Logout</span></a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <div class="main-content">
        <header class="header">
            <div>
                <h1>Detailed Expense Report</h1>
                <p>A complete list of all your recorded transactions.</p>
            </div>
        </header>
        
        <div class="container">
        <%
            String username = (String) session.getAttribute("un");
            if(username == null){
                response.sendRedirect("signin.html");
                return;
            }

            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            List<Map<String, Object>> transactions = new ArrayList<>();
            String errorMessage = null;

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
                String sql = "SELECT pdate, iname, qty, category, amount FROM pexpenses WHERE uname=? ORDER BY pdate DESC";
                ps = con.prepareStatement(sql);
                ps.setString(1, username);
                rs = ps.executeQuery();
                
                while(rs.next()){
                    Map<String, Object> row = new HashMap<>();
                    row.put("pdate", rs.getDate("pdate"));
                    row.put("iname", rs.getString("iname"));
                    row.put("qty", rs.getString("qty"));
                    row.put("category", rs.getString("category"));
                    row.put("amount", rs.getDouble("amount"));
                    transactions.add(row);
                }
            } catch(Exception e){
                errorMessage = "Error connecting to the database. " + e.getMessage();
                e.printStackTrace();
            } finally {
                try { if(rs!=null) rs.close(); } catch(Exception e){}
                try { if(ps!=null) ps.close(); } catch(Exception e){}
                try { if(con!=null) con.close(); } catch(Exception e){}
            }
            
            if (errorMessage != null) {
        %>
            <div style="background-color: rgba(244, 67, 54, 0.7); color: #fff; padding: 15px; border-radius: 8px;"><%= errorMessage %></div>
        <%
            } else if (transactions.isEmpty()) {
        %>
            <div class="empty-state">
                <i class="fas fa-folder-open"></i>
                <h3>No Expenses Found</h3>
                <p>You haven't added any expenses yet. Get started by adding one!</p>
            </div>
        <%
            } else {
        %>
            <!-- Filter Controls -->
            <div class="filter-controls">
                <div class="filter-group search-bar">
                    <label for="search-input">Search by Item Name</label>
                    <input type="text" id="search-input" placeholder="e.g., Coffee, Ticket...">
                </div>
                <div class="filter-group">
                    <label for="start-date">Start Date</label>
                    <input type="date" id="start-date">
                </div>
                <div class="filter-group">
                    <label for="end-date">End Date</label>
                    <input type="date" id="end-date">
                </div>
                 <div class="filter-group" style="margin-top:20px;">
                    <button id="clear-filters" class="btn"><i class="fas fa-times"></i> Clear</button>
                </div>
            </div>

            <div class="report-layout">
                <!-- Table -->
                <div class="table-section">
                    <div class="table-responsive">
                        <table id="report-table">
                            <thead>
                                <tr>
                                    <th data-sort="date">Date <i class="fas fa-sort sort-icon"></i></th>
                                    <th data-sort="item">Item <i class="fas fa-sort sort-icon"></i></th>
                                    <th>Qty</th>
                                    <th data-sort="category">Category <i class="fas fa-sort sort-icon"></i></th>
                                    <th data-sort="amount">Amount <i class="fas fa-sort sort-icon"></i></th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
                                for (Map<String, Object> row : transactions) {
                                    java.util.Date pdate = (java.util.Date)row.get("pdate");
                            %>
                                <tr data-date="<%= new SimpleDateFormat("yyyy-MM-dd").format(pdate) %>">
                                    <td><%= new SimpleDateFormat("dd-MMM-yyyy").format(pdate) %></td>
                                    <td><%= row.get("iname") %></td>
                                    <td><%= row.get("qty") %></td>
                                    <td><%= row.get("category") %></td>
                                    <td data-amount="<%= row.get("amount") %>"><%= currencyFormatter.format(row.get("amount")) %></td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>

                    <div class="report-actions">
                         <div id="total-spent" class="total"></div>
                         <div>
                            <a href="dashboard.jsp" class="btn"><i class="fas fa-arrow-left"></i> Back</a>
                            <button onclick="window.print()" class="btn"><i class="fas fa-print"></i> Print</button>
                         </div>
                    </div>
                </div>

                <!-- Chart -->
                <div class="chart-section">
                    <h3>Category Breakdown</h3>
                    <canvas id="expenseChart"></canvas>
                </div>
            </div>
        <%
            }
        %>
        </div>
    </div>

    <% if (!transactions.isEmpty()) { %>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const tableRows = document.querySelectorAll("#report-table tbody tr");
            let expenseChart;

            // --- UTILITY FUNCTIONS ---
            const currencyFormatter = new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' });

            function updateReport(visibleRows) {
                let total = 0;
                const categoryMap = new Map();

                visibleRows.forEach(row => {
                    const amount = parseFloat(row.querySelector('[data-amount]').dataset.amount);
                    total += amount;
                    const category = row.cells[3].textContent;
                    categoryMap.set(category, (categoryMap.get(category) || 0) + amount);
                });

                document.getElementById('total-spent').textContent = `Total Spent: ${currencyFormatter.format(total)}`;
                updateChart(categoryMap);
            }

            function updateChart(categoryMap) {
                const sortedCategories = new Map([...categoryMap.entries()].sort((a, b) => b[1] - a[1]));
                const labels = [...sortedCategories.keys()];
                const data = [...sortedCategories.values()];

                if (expenseChart) {
                    expenseChart.data.labels = labels;
                    expenseChart.data.datasets[0].data = data;
                    expenseChart.update();
                } else {
                    const ctx = document.getElementById('expenseChart').getContext('2d');
                    expenseChart = new Chart(ctx, {
                        type: 'doughnut',
                        data: {
                            labels: labels,
                            datasets: [{
                                label: 'Total Spent',
                                data: data,
                                backgroundColor: ['#4a90e2', '#50e3c2', '#f5a623', '#bd10e0', '#e74c3c', '#9b59b6', '#34495e'],
                                borderColor: 'rgba(0, 0, 0, 0.4)',
                                borderWidth: 2,
                                hoverOffset: 4
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: { position: 'bottom', labels: { color: '#fff' } },
                                tooltip: {
                                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                                    callbacks: {
                                        label: (context) => `${context.label}: ${currencyFormatter.format(context.raw)}`
                                    }
                                }
                            }
                        }
                    });
                }
            }
            
            // --- FILTERING LOGIC ---
            function applyFilters() {
                const searchTerm = document.getElementById('search-input').value.toLowerCase();
                const startDate = document.getElementById('start-date').value;
                const endDate = document.getElementById('end-date').value;
                const visibleRows = [];

                tableRows.forEach(row => {
                    const itemName = row.cells[1].textContent.toLowerCase();
                    const rowDate = row.dataset.date;
                    
                    const matchesSearch = itemName.includes(searchTerm);
                    const matchesStartDate = !startDate || rowDate >= startDate;
                    const matchesEndDate = !endDate || rowDate <= endDate;

                    if (matchesSearch && matchesStartDate && matchesEndDate) {
                        row.style.display = '';
                        visibleRows.push(row);
                    } else {
                        row.style.display = 'none';
                    }
                });
                updateReport(visibleRows);
            }

            ['search-input', 'start-date', 'end-date'].forEach(id => {
                document.getElementById(id).addEventListener('input', applyFilters);
            });

            document.getElementById('clear-filters').addEventListener('click', () => {
                 document.getElementById('search-input').value = '';
                 document.getElementById('start-date').value = '';
                 document.getElementById('end-date').value = '';
                 applyFilters();
            });

            // --- SORTING LOGIC ---
            document.querySelectorAll("#report-table thead th[data-sort]").forEach(header => {
                header.addEventListener("click", () => {
                    const tbody = document.querySelector("#report-table tbody");
                    const sortKey = header.dataset.sort;
                    const sortDir = header.dataset.sortDir === 'asc' ? 'desc' : 'asc';
                    header.dataset.sortDir = sortDir;
                    
                    const rowsArray = Array.from(tbody.rows);

                    rowsArray.sort((a, b) => {
                        let valA, valB;
                        if (sortKey === 'amount') {
                            valA = parseFloat(a.querySelector('[data-amount]').dataset.amount);
                            valB = parseFloat(b.querySelector('[data-amount]').dataset.amount);
                        } else if (sortKey === 'date') {
                            valA = new Date(a.dataset.date);
                            valB = new Date(b.dataset.date);
                        } else { // item, category
                           valA = a.cells[sortKey === 'item' ? 1 : 3].textContent.toLowerCase();
                           valB = b.cells[sortKey === 'item' ? 1 : 3].textContent.toLowerCase();
                        }
                        return (valA < valB ? -1 : 1) * (sortDir === 'asc' ? 1 : -1);
                    });
                    
                    rowsArray.forEach(row => tbody.appendChild(row));
                });
            });

            // --- INITIAL LOAD ---
            updateReport(Array.from(tableRows));
        });
    </script>
    <% } %>
</body>
</html>

