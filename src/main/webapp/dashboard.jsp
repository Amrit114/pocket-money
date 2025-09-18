<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat, java.util.Locale" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Pocket Tracker - Dashboard</title>

<!-- External Fonts and Icons -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- Chart.js Library -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<link rel="stylesheet" href="style.css">
</head>
<body>

<%
    // --- User Session Check ---
    String username = (String) session.getAttribute("un");
    if (username == null) {
        response.sendRedirect("signin.html");
        return;
    }

    // --- Database Variables ---
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    // --- Data Variables ---
    double totalExpenses = 0.0;
    double todayTotal = 0.0;
    Map<String, Double> categoryMap = new LinkedHashMap<>(); // Use LinkedHashMap to maintain order
    String errorMessage = null;

    // --- Date and Currency Formatting ---
    java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("en", "IN")); // Example: Rupees

    try {
        // --- Database Connection ---
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");
        
        // --- SQL Query to Fetch Expenses ---
        String sql = "SELECT amount, category, pdate FROM pexpenses WHERE uname = ? ORDER BY pdate DESC";
        ps = con.prepareStatement(sql);
        ps.setString(1, username);
        rs = ps.executeQuery();

        // --- Process Query Results ---
        while(rs.next()){
            double amount = rs.getDouble("amount");
            totalExpenses += amount;

            // Check if the expense was made today
            if(today.equals(rs.getDate("pdate"))){
                todayTotal += amount;
            }

            // Aggregate expenses by category
            String category = rs.getString("category");
            categoryMap.put(category, categoryMap.getOrDefault(category, 0.0) + amount);
        }
    } catch(Exception e) {
        errorMessage = "Error connecting to the database. Please try again later.";
        e.printStackTrace(); // Log error to server console
    } finally {
        // --- Close Database Resources ---
        try { if(rs != null) rs.close(); } catch(SQLException e){}
        try { if(ps != null) ps.close(); } catch(SQLException e){}
        try { if(con != null) con.close(); } catch(SQLException e){}
    }
%>

<!-- Sidebar Navigation -->
<aside class="sidebar">
    <div class="sidebar-header">
        <h2><i class="fas fa-wallet"></i>Pocket Tracker</h2>
    </div>
    <ul class="nav-links">
        <li><a href="dashboard.jsp" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
        <li><a href="addExpenses.jsp"><i class="fas fa-plus-circle"></i> Add Expense</a></li>
        <li><a href="report.jsp"><i class="fas fa-file-alt"></i> Detailed Reports</a></li>
        <li><a href="mreports.jsp"><i class="fas fa-calendar-alt"></i> Monthly Reports</a></li>
        <li><a href="monthcat.jsp"><i class="fas fa-chart-pie"></i> Category Reports</a></li>
        <li class="logout-link"><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
    </ul>
</aside>

<!-- Main Content -->
<main class="main-content">
    <header class="header">
        <h1>Dashboard</h1>
        <p>Welcome back, <%= username %>! Here's your financial summary.</p>
    </header>

    <% if (errorMessage != null) { %>
        <div style="background-color: rgba(244, 67, 54, 0.7); backdrop-filter: blur(5px); border-left: 6px solid #f44336; color: #fff; padding: 15px; margin-bottom: 20px; border-radius: 8px;">
            <strong>Error:</strong> <%= errorMessage %>
        </div>
    <% } %>

    <!-- Statistics Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="icon-container icon-total"><i class="fas fa-coins"></i></div>
            <div class="stat-card-info">
                <h3>Total Spent</h3>
                <p><%= currencyFormatter.format(totalExpenses) %></p>
            </div>
        </div>
        <div class="stat-card">
            <div class="icon-container icon-today"><i class="fas fa-calendar-day"></i></div>
            <div class="stat-card-info">
                <h3>Today's Spending</h3>
                <p><%= currencyFormatter.format(todayTotal) %></p>
            </div>
        </div>
        <div class="stat-card">
            <div class="icon-container icon-category"><i class="fas fa-tags"></i></div>
            <div class="stat-card-info">
                <h3>Categories Used</h3>
                <p><%= categoryMap.size() %></p>
            </div>
        </div>
    </div>

    <!-- Chart Section -->
    <div class="chart-container">
        <h2>Expense Breakdown by Category</h2>
        <% if (!categoryMap.isEmpty()) { %>
            <canvas id="categoryPieChart" height="120"></canvas>
        <% } else { %>
            <div class="empty-state">
                <i class="fas fa-chart-pie"></i>
                <p>No expense data found. Add your first expense to see a breakdown!</p>
            </div>
        <% } %>
    </div>
</main>

<% if (!categoryMap.isEmpty()) { %>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // --- Prepare data for the chart ---
        const categoryLabels = [<% for (String key : categoryMap.keySet()) { out.print("'" + key + "',"); } %>];
        const categoryAmounts = [<% for (Double val : categoryMap.values()) { out.print(val + ","); } %>];

        const ctx = document.getElementById('categoryPieChart').getContext('2d');
        
        // --- Create the Chart.js Pie Chart ---
        new Chart(ctx, {
            type: 'doughnut', // Doughnut is a modern alternative to Pie
            data: {
                labels: categoryLabels,
                datasets: [{
                    label: 'Expenses',
                    data: categoryAmounts,
                    backgroundColor: [
                        'rgba(74, 144, 226, 0.8)', 'rgba(80, 227, 194, 0.8)', 'rgba(245, 166, 35, 0.8)', 'rgba(189, 16, 224, 0.8)',
                        'rgba(231, 76, 60, 0.8)', 'rgba(155, 89, 182, 0.8)', 'rgba(52, 73, 94, 0.8)', 'rgba(241, 196, 15, 0.8)'
                    ],
                    borderColor: 'rgba(255, 255, 255, 0.1)',
                    borderWidth: 4,
                    hoverOffset: 15
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            color: '#fff',
                            font: {
                                family: 'Poppins',
                                size: 14
                            },
                            boxWidth: 20,
                            padding: 20
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.7)',
                        titleColor: '#fff',
                        bodyColor: '#eee',
                        borderColor: 'rgba(255, 255, 255, 0.2)',
                        borderWidth: 1,
                        callbacks: {
                            label: function(context) {
                                let label = context.label || '';
                                if (label) {
                                    label += ': ';
                                }
                                if (context.parsed !== null) {
                                    // Format tooltip value as currency
                                    label += new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(context.parsed);
                                }
                                return label;
                            }
                        },
                        bodyFont: {
                            family: 'Poppins'
                        },
                        titleFont: {
                            family: 'Poppins'
                        }
                    }
                },
                cutout: '65%' // Creates the doughnut hole
            }
        });
    });
</script>
<% } %>

</body>
</html>

