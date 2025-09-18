<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PocketTrack - Monthly Report</title>

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
    .sidebar-header {
        padding: 0 25px;
        margin-bottom: 30px;
        text-align: center;
    }
    .sidebar-header h2 {
        color: yellow;
        margin: 0;
        font-size: 1.6rem;
        white-space: nowrap;
    }
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
    .header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 30px;
    }
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
    
    /* Table Styling */
    .table-responsive {
        overflow-x: auto;
    }
    table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
    }
    th, td {
        padding: 12px 15px;
        text-align: left;
    }
    th {
        background-color: rgba(255, 255, 255, 0.1);
        font-weight: 600;
        font-size: 0.9rem;
        text-transform: uppercase;
    }
    td {
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }
    tbody tr {
        transition: background-color 0.2s;
    }
    tbody tr:hover {
        background-color: rgba(255, 255, 255, 0.05);
    }

    /* Report Layout and Actions */
    .report-actions {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 20px;
    }
    .total {
        font-weight: bold;
        font-size: 1.2rem;
    }
    .btn {
        background: rgba(255, 255, 255, 0.15);
        color: #fff;
        padding: 10px 20px;
        border: 1px solid rgba(255,255,255,0.2);
        border-radius: 8px;
        text-decoration: none;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s ease;
    }
    .btn:hover {
        background: rgba(255, 255, 255, 0.25);
        transform: translateY(-2px);
    }
    .btn i { margin-right: 8px; }

    /* Chart Section */
    .chart-section {
        margin-top: 40px;
    }
    
    .empty-state {
        text-align: center; padding: 60px 20px;
    }
    .empty-state i { font-size: 3.5rem; margin-bottom: 20px; color: rgba(255, 255, 255, 0.8); }
    .empty-state h3 { font-size: 1.5rem; margin: 0 0 10px 0; }
    .empty-state p { margin: 0; color: rgba(255, 255, 255, 0.8); }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    /* Responsive */
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
        <div class="sidebar-header">
            <h2><i class="fas fa-wallet"></i> <span>Pocket Tracker</span></h2>
        </div>
        <ul class="nav-links">
            <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> <span>Dashboard</span></a></li>
            <li><a href="addExpenses.jsp"><i class="fas fa-plus-circle"></i> <span>Add Expense</span></a></li>
            <li><a href="report.jsp"><i class="fas fa-file-alt"></i> <span>Detailed Reports</span></a></li>
            <li><a href="mreports.jsp"><i class="fas fa-calendar-alt"></i> <span>Monthly Reports</span></a></li>
            <li><a href="monthcat.jsp" class="active"><i class="fas fa-chart-pie"></i> <span>Category Reports</span></a></li>
            <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> <span>Logout</span></a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <div class="main-content">
        <header class="header">
            <div>
                <h1>Monthly Category Report</h1>
                <p>An overview of your spending habits by category over time.</p>
            </div>
        </header>
        
        <div class="container">
        <%
            String user = (String) session.getAttribute("un");
            if (user == null) {
                response.sendRedirect("signin.html");
                return;
            }

            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            double total = 0.0;
            Map<String, Map<String, Double>> dataMap = new LinkedHashMap<>();
            String errorMessage = null;
            NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");
                
                String sql = "SELECT TO_CHAR(pdate,'Mon-YYYY') AS month_year, category, SUM(amount) AS total_amount " +
                             "FROM pexpenses WHERE uname=? " +
                             "GROUP BY TO_CHAR(pdate,'Mon-YYYY'), category " +
                             "ORDER BY MIN(pdate), category";

                ps = con.prepareStatement(sql);
                ps.setString(1, user);
                rs = ps.executeQuery();

                while(rs.next()){
                    String month = rs.getString("month_year");
                    String cat = rs.getString("category");
                    double amt = rs.getDouble("total_amount");
                    total += amt;

                    dataMap.putIfAbsent(month, new LinkedHashMap<>());
                    dataMap.get(month).put(cat, amt);
                }
            } catch (Exception e) {
                errorMessage = "Error connecting to the database. " + e.getMessage();
                e.printStackTrace();
            } finally {
                if(rs != null) try { rs.close(); } catch(Exception e) {}
                if(ps != null) try { ps.close(); } catch(Exception e) {}
                if(con != null) try { con.close(); } catch(Exception e) {}
            }

            if (errorMessage != null) {
        %>
            <div style="background-color: rgba(244, 67, 54, 0.7); color: #fff; padding: 15px; border-radius: 8px;"><%= errorMessage %></div>
        <%
            } else if (dataMap.isEmpty()) {
        %>
            <div class="empty-state">
                <i class="fas fa-search-dollar"></i>
                <h3>No Data Found</h3>
                <p>There are no expenses recorded to generate this report.</p>
            </div>
        <%
            } else {
        %>
            <!-- Table Section -->
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Month</th>
                            <th>Category</th>
                            <th>Total Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        for(String month : dataMap.keySet()){
                            for(String cat : dataMap.get(month).keySet()){
                    %>
                        <tr>
                            <td><%= month %></td>
                            <td><%= cat %></td>
                            <td><%= currencyFormatter.format(dataMap.get(month).get(cat)) %></td>
                        </tr>
                    <%    }
                        }
                    %>
                    </tbody>
                </table>
            </div>

            <div class="report-actions">
                <div class="total">Total Spent: <%= currencyFormatter.format(total) %></div>
                <div>
                    <a href="dashboard.jsp" class="btn"><i class="fas fa-arrow-left"></i> Back</a>
                    <button onclick="window.print()" class="btn"><i class="fas fa-print"></i> Print</button>
                </div>
            </div>

            <!-- Chart Section -->
            <div class="chart-section">
                <canvas id="expenseChart"></canvas>
            </div>
        <%
            }
        %>
        </div>
    </div>
    
    <% if (!dataMap.isEmpty()) { %>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const labels = [<% for(String month : dataMap.keySet()){ out.print("'" + month + "',"); } %>];
            const datasets = [];
            <%
                Set<String> categories = new LinkedHashSet<>();
                for(Map<String, Double> catMap : dataMap.values()){
                    categories.addAll(catMap.keySet());
                }

                String[] colors = {"#4a90e2", "#50e3c2", "#f5a623", "#bd10e0", "#e74c3c", "#9b59b6", "#34495e"};
                int colorIndex = 0;

                for(String cat : categories){
            %>
                    datasets.push({
                        label: '<%= cat %>',
                        data: [
                            <% for(String month : dataMap.keySet()){
                                out.print(dataMap.get(month).getOrDefault(cat, 0.0) + ",");
                            } %>
                        ],
                        borderColor: '<%= colors[colorIndex % colors.length] %>',
                        backgroundColor: '<%= colors[colorIndex % colors.length] %>33', // 33 for hex transparency
                        fill: true,
                        tension: 0.4,
                        borderWidth: 2
                    });
            <%
                    colorIndex++;
                }
            %>

            new Chart(document.getElementById('expenseChart'), {
                type: 'line',
                data: { labels: labels, datasets: datasets },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: { color: 'rgba(255,255,255,0.7)' },
                            grid: { color: 'rgba(255,255,255,0.1)' }
                        },
                        x: {
                            ticks: { color: 'rgba(255,255,255,0.7)' },
                            grid: { color: 'rgba(255,255,255,0.1)' }
                        }
                    },
                    plugins: { 
                        legend: { 
                            position: 'top',
                            labels: { color: '#fff' }
                        },
                        tooltip: {
                             backgroundColor: 'rgba(0, 0, 0, 0.8)',
                             titleColor: '#fff',
                             bodyColor: '#eee',
                             callbacks: {
                                label: function(context) {
                                    let label = context.dataset.label || '';
                                    if (label) { label += ': '; }
                                    if (context.parsed.y !== null) {
                                        label += new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(context.parsed.y);
                                    }
                                    return label;
                                }
                            }
                        }
                    }
                }
            });
        });
    </script>
    <% } %>
</body>
</html>
