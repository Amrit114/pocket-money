<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat, java.text.SimpleDateFormat, java.util.Locale" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Pocket Tracker - Dashboard</title>

<!-- External Fonts and Icons -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- Chart.js Library -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    /* CSS Variables for easy theme management */
    :root {
        --sidebar-bg: rgba(15, 23, 42, 0.9);
        --main-bg: linear-gradient(135deg, #4facfe, #00f2fe);
        --card-bg: rgba(0, 0, 0, 0.3);
        --card-border: rgba(255, 255, 255, 0.1);
        --text-light: #f8fafc;
        --text-muted: #cbd5e1;
        --accent-color: #facc15; /* Yellow */
        --accent-hover: rgba(250, 204, 21, 0.2);
    }

    /* General Body Styles */
    body {
        margin: 0;
        font-family: 'Segoe UI', sans-serif;
        background: var(--main-bg);
        background-attachment: fixed;
        color: var(--text-light);
        display: flex;
        transition: padding-left 0.3s ease;
    }

    /* Modern Sidebar */
    .sidebar {
        width: 250px;
        background: var(--sidebar-bg);
        backdrop-filter: blur(10px);
        height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        border-right: 1px solid var(--card-border);
        display: flex;
        flex-direction: column;
        transition: width 0.3s ease;
        z-index: 100;
        overflow-x: hidden;
    }
    
    .sidebar-content {
        display: flex;
        flex-direction: column;
        height: 100%;
        padding: 25px 0;
    }

    .sidebar-header {
        padding: 0 25px;
        margin-bottom: 35px;
        text-align: center;
    }
    .sidebar-header h2 {
        color: var(--text-light);
        margin: 0;
        font-size: 1.7rem;
        white-space: nowrap;
        font-weight: 700;
    }
     .sidebar-header h2 i {
        color: var(--accent-color);
     }
    
    .nav-links { list-style: none; padding: 0; margin: 0; flex-grow: 1; }
    .nav-links a {
        display: flex;
        align-items: center;
        padding: 16px 30px;
        margin: 5px 15px;
        color: var(--text-muted);
        text-decoration: none;
        font-weight: 600;
        white-space: nowrap;
        border-radius: 8px;
        transition: background-color 0.2s, color 0.2s;
    }
    .nav-links a.active, .nav-links a:hover {
        background: var(--accent-hover);
        color: var(--accent-color);
    }
    .nav-links a i {
        margin-right: 18px;
        width: 22px;
        text-align: center;
        font-size: 1.2rem;
    }

    .sidebar-footer { padding: 20px 30px; border-top: 1px solid var(--card-border); white-space: nowrap; }
    .user-profile { display: flex; align-items: center; }
    .user-profile i { font-size: 2rem; margin-right: 15px; color: var(--accent-color); }
    .user-profile div { line-height: 1.3; }
    .user-profile strong { display: block; font-weight: 700; color: var(--text-light); }
    .user-profile a { color: var(--text-muted); text-decoration: none; font-size: 0.9rem; }
    .user-profile a:hover { text-decoration: underline; }

    /* Main Content Area */
    .main-content {
        margin-left: 250px;
        flex-grow: 1;
        padding: 40px;
        transition: margin-left 0.3s ease;
        animation: fadeIn 1s ease-in-out;
    }
    
    .header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 30px; }
    .header-title h1 { margin: 0; font-size: 2.8rem; font-weight: 700; text-shadow: 0 2px 4px rgba(0,0,0,0.2); }
    .header-title p { margin: 5px 0 0; font-size: 1.1rem; color: var(--text-muted); }
    .header-date { font-size: 1rem; font-weight: 600; background: var(--card-bg); padding: 10px 20px; border-radius: 8px; border: 1px solid var(--card-border); }

    /* Key Metrics Cards */
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 30px; margin-bottom: 30px;}
    .stat-card {
        background: var(--card-bg);
        border: 1px solid var(--card-border);
        padding: 25px;
        border-radius: 15px;
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.15);
        display: flex;
        align-items: center;
        gap: 20px;
        transition: transform 0.3s, box-shadow 0.3s;
    }
    .stat-card:hover { transform: translateY(-5px); box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.2); }
    .stat-card .icon-container {font-size: 24px; min-width: 60px; height: 60px; border-radius: 50%; color: #fff; display: flex; align-items: center; justify-content: center;}
    .icon-total { background: linear-gradient(45deg, #3785e7, #64b5f6); }
    .icon-today { background: linear-gradient(45deg, #43cea2, #185a9d); }
    .icon-category { background: linear-gradient(45deg, #ff9a44, #fc6076); }
    .stat-card-info h3 {margin: 0; font-size: 1rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase;}
    .stat-card-info p { margin: 8px 0 0; font-size: 2rem; font-weight: 700; color: var(--text-light);}
    
    /* Main Dashboard Layout */
    .dashboard-grid { display: grid; grid-template-columns: 2fr 1.5fr; gap: 30px; }
    .chart-container, .recent-transactions { background: var(--card-bg); border: 1px solid var(--card-border); padding: 30px; border-radius: 15px; box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.15); }
    .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
    .panel-header h2 { margin: 0; font-size: 1.5rem; font-weight: 600; }
    .panel-header a { color: var(--accent-color); text-decoration: none; font-weight: 600; }
    .panel-header a:hover { text-decoration: underline; }
    
    /* Transactions List */
    .transactions-list { list-style: none; padding: 0; margin: 0; max-height: 400px; overflow-y: auto; }
    .transaction-item { display: flex; align-items: center; padding: 18px 5px; border-bottom: 1px solid var(--card-border); }
    .transaction-item:last-child { border-bottom: none; }
    .transaction-icon { font-size: 1.1rem; width: 45px; height: 45px; border-radius: 12px; display: flex; align-items: center; justify-content: center; background-color: rgba(255,255,255,0.05); }
    .transaction-details { flex-grow: 1; margin-left: 18px; }
    .transaction-details strong { display: block; font-size: 1rem; font-weight: 600; }
    .transaction-details span { font-size: 0.9rem; color: var(--text-muted); }
    .transaction-amount { font-weight: 700; font-size: 1.1rem; color: #ff7675; white-space: nowrap;}
    
    /* Empty States */
    .empty-state { text-align: center; padding: 60px; }
    .empty-state i { font-size: 3.5rem; margin-bottom: 20px; color: var(--accent-color); }
    .empty-state p { font-size: 1.2rem; margin: 0 0 20px 0; color: var(--text-muted); }
    .empty-state .btn { background: var(--accent-color); color: #333; font-weight: bold; padding: 12px 30px; border-radius: 25px; text-decoration: none; display: inline-block; transition: transform 0.3s; }
    .empty-state .btn:hover { transform: scale(1.05); }

    @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    
    /* Responsive Design */
    @media (max-width: 1200px) { .dashboard-grid { grid-template-columns: 1fr; } }
    @media (max-width: 768px) {
        body { flex-direction: column; }
        .sidebar { width: 100%; height: auto; position: relative; box-shadow: none; border-right: none; border-bottom: 1px solid var(--card-border); }
        .main-content { margin-left: 0; padding: 20px; }
        .header-title h1 { font-size: 2rem; }
    }
</style>

</head>
<body>

<%
    // --- User Session Check ---
    String username = (String) session.getAttribute("un");
    if (username == null) {
        response.sendRedirect("signin.html");
        return;
    }

    // --- Database Variables & Data ---
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    double totalExpenses = 0.0, todayTotal = 0.0;
    Map<String, Double> categoryMap = new LinkedHashMap<>();
    List<Map<String, Object>> recentTransactions = new ArrayList<>();
    String errorMessage = null;

    // --- Formatters & Helpers ---
    java.util.Date currentDate = new java.util.Date();
    java.sql.Date todaySQL = new java.sql.Date(currentDate.getTime());
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat sdfHeader = new SimpleDateFormat("EEEE, MMMM dd, yyyy");
    
    // Helper for category icons
    Map<String, String> categoryIcons = new HashMap<>();
    categoryIcons.put("Food", "fa-utensils");
    categoryIcons.put("Transport", "fa-bus");
    categoryIcons.put("Shopping", "fa-shopping-bag");
    categoryIcons.put("Bills", "fa-file-invoice-dollar");
    categoryIcons.put("Entertainment", "fa-film");
    categoryIcons.put("Health", "fa-heartbeat");
    categoryIcons.put("Other", "fa-receipt");
    String defaultIcon = "fa-dollar-sign";


    try {
        // --- Database Connection ---
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");
        
        String sql = "SELECT amount, category, pdate, iname FROM pexpenses WHERE uname = ? ORDER BY pdate DESC";
        ps = con.prepareStatement(sql);
        ps.setString(1, username);
        rs = ps.executeQuery();

        int transactionCount = 0;
        while(rs.next()){
            double amount = rs.getDouble("amount");
            String category = rs.getString("category");
            
            totalExpenses += amount;
            if(todaySQL.equals(rs.getDate("pdate"))) todayTotal += amount;
            categoryMap.put(category, categoryMap.getOrDefault(category, 0.0) + amount);

            if (transactionCount < 5) {
                Map<String, Object> transaction = new HashMap<>();
                transaction.put("category", category);
                transaction.put("iname", rs.getString("iname"));
                transaction.put("amount", amount);
                transaction.put("date", rs.getDate("pdate"));
                recentTransactions.add(transaction);
                transactionCount++;
            }
        }
    } catch(Exception e) {
        errorMessage = "Error connecting to the database. Please try again later.";
        e.printStackTrace();
    } finally {
        try { if(rs != null) rs.close(); } catch(SQLException e){}
        try { if(ps != null) ps.close(); } catch(SQLException e){}
        try { if(con != null) con.close(); } catch(SQLException e){}
    }
%>

<!-- Sidebar Navigation -->
<aside class="sidebar">
    <div class="sidebar-content">
        <div class="sidebar-header">
            <h2><i class="fas fa-wallet"></i> <span>PocketTrack</span></h2>
        </div>
        <ul class="nav-links">
            <li><a href="dashboard.jsp" class="active"><i class="fas fa-tachometer-alt"></i> <span>Dashboard</span></a></li>
            <li><a href="addExpenses.jsp"><i class="fas fa-plus-circle"></i> <span>Add Expense</span></a></li>
            <li><a href="report.jsp"><i class="fas fa-file-alt"></i> <span>Detailed Report</span></a></li>
            <li><a href="mreports.jsp"><i class="fas fa-calendar-alt"></i> <span>Monthly Report</span></a></li>
            <li><a href="monthcat.jsp"><i class="fas fa-chart-pie"></i> <span>Category Report</span></a></li>
        </ul>
        <div class="sidebar-footer">
            <div class="user-profile">
                <i class="fas fa-user-circle"></i>
                <div>
                    <strong><%= username %></strong>
                    <a href="logout.jsp">Sign Out</a>
                </div>
            </div>
        </div>
    </div>
</aside>

<!-- Main Content -->
<main class="main-content">
    <header class="header">
        <div class="header-title">
            <h1>Welcome Back!</h1>
            <p>Here's your financial summary.</p>
        </div>
        <div class="header-date">
             <i class="fas fa-calendar-alt"></i> <%= sdfHeader.format(currentDate) %>
        </div>
    </header>

    <% if (errorMessage != null) { %>
        <div style="background-color: rgba(244, 67, 54, 0.7); backdrop-filter: blur(5px); border: 1px solid rgba(255,255,255,0.2); color: #fff; padding: 15px; margin-bottom: 20px; border-radius: 8px;">
            <strong><i class="fas fa-exclamation-triangle"></i> Error:</strong> <%= errorMessage %>
        </div>
    <% } %>

    <!-- Statistics Cards -->
    <div class="stats-grid">
        <div class="stat-card"><div class="icon-container icon-total"><i class="fas fa-coins"></i></div><div class="stat-card-info"><h3>Total Spent</h3><p><%= currencyFormatter.format(totalExpenses) %></p></div></div>
        <div class="stat-card"><div class="icon-container icon-today"><i class="fas fa-calendar-day"></i></div><div class="stat-card-info"><h3>Today's Spending</h3><p><%= currencyFormatter.format(todayTotal) %></p></div></div>
        <div class="stat-card"><div class="icon-container icon-category"><i class="fas fa-tags"></i></div><div class="stat-card-info"><h3>Categories Used</h3><p><%= categoryMap.size() %></p></div></div>
    </div>

    <!-- Main Dashboard Grid -->
    <div class="dashboard-grid">
        <!-- Chart Section -->
        <div class="chart-container">
            <div class="panel-header">
                <h2>Expense Breakdown</h2>
                <a href="monthcat.jsp">View Details <i class="fas fa-arrow-right"></i></a>
            </div>
            <% if (!categoryMap.isEmpty()) { %>
                <canvas id="categoryPieChart" style="max-height: 400px;"></canvas>
            <% } else { %>
                <div class="empty-state">
                    <i class="fas fa-chart-pie"></i>
                    <p>Add your first expense to see your spending breakdown!</p>
                    <a href="addExpenses.jsp" class="btn">Add Expense</a>
                </div>
            <% } %>
        </div>

        <!-- Recent Transactions Section -->
        <div class="recent-transactions">
            <div class="panel-header">
                <h2>Recent Transactions</h2>
                <a href="report.jsp">View All <i class="fas fa-arrow-right"></i></a>
            </div>
            <% if (recentTransactions.isEmpty()) { %>
                 <div class="empty-state" style="padding: 40px 20px;">
                    <i class="fas fa-receipt"></i>
                    <p>Your latest transactions will appear here.</p>
                </div>
            <% } else { %>
            <ul class="transactions-list">
                <% for (Map<String, Object> txn : recentTransactions) { 
                    String category = (String) txn.get("category");
                    String iconClass = categoryIcons.getOrDefault(category, defaultIcon);
                %>
                <li class="transaction-item">
                    <div class="transaction-icon" title="<%= category %>"><i class="fas <%= iconClass %>"></i></div>
                    <div class="transaction-details">
                        <strong><%= txn.get("iname") %></strong>
                        <span><%= sdf.format((java.util.Date) txn.get("date")) %></span>
                    </div>
                    <div class="transaction-amount">
                        -<%= currencyFormatter.format(txn.get("amount")) %>
                    </div>
                </li>
                <% } %>
            </ul>
            <% } %>
        </div>
    </div>
</main>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        <% if (!categoryMap.isEmpty()) { %>
        const ctx = document.getElementById('categoryPieChart').getContext('2d');
        
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: [<% for (String key : categoryMap.keySet()) { out.print("'" + key + "',"); } %>],
                datasets: [{
                    label: 'Expenses',
                    data: [<% for (Double val : categoryMap.values()) { out.print(val + ","); } %>],
                    backgroundColor: ['#4a90e2', '#50e3c2', '#f5a623', '#bd10e0', '#e74c3c', '#9b59b6', '#34495e', '#f1c40f'],
                    borderColor: 'rgba(15, 23, 42, 0.5)',
                    borderWidth: 3,
                    hoverOffset: 15
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            color: '#fff',
                            font: { family: 'Segoe UI', size: 14 },
                            boxWidth: 20,
                            padding: 20
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        callbacks: {
                            label: function(context) {
                                let label = context.label || '';
                                if (label) { label += ': '; }
                                if (context.parsed !== null) {
                                    label += new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(context.parsed);
                                }
                                return label;
                            }
                        }
                    }
                },
                cutout: '65%'
            }
        });
        <% } %>
    });
</script>
</body>
</html>

