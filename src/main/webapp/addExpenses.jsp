<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.Date" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PocketTrack - Add Expense</title>
  
  <!-- External Fonts and Icons -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #4facfe, #00f2fe);
      background-attachment: fixed;
      margin: 0;
      padding: 20px;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      color: #fff;
    }
    
    .container {
      background: rgba(0, 0, 0, 0.4);
      backdrop-filter: blur(10px);
      padding: 30px 40px;
      border-radius: 15px;
      box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.18);
      width: 100%;
      max-width: 450px;
      animation: fadeIn 1s ease-in-out;
    }
    
    h2 {
      text-align: center;
      margin-top: 0;
      margin-bottom: 25px;
      font-size: 2rem;
      font-weight: 600;
    }
    
    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .form-group {
      margin-bottom: 15px;
      position: relative;
    }
    
    .full-width {
        grid-column: 1 / -1;
    }

    label {
      font-weight: 600;
      display: block;
      margin-bottom: 8px;
      font-size: 0.9rem;
    }
    
    .input-wrapper {
        position: relative;
    }

    .input-wrapper i {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: rgba(255, 255, 255, 0.7);
    }
    
    input, select {
      width: 100%;
      padding: 12px 15px 12px 40px; /* Padding for icon */
      box-sizing: border-box;
      background: rgba(255, 255, 255, 0.1);
      border: 1px solid rgba(255, 255, 255, 0.2);
      border-radius: 8px;
      color: #fff;
      font-size: 1rem;
      transition: background-color 0.3s, border-color 0.3s;
    }
    
    select {
        padding-left: 15px; /* No icon for select */
        appearance: none;
        background-image: url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23ffffff%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E');
        background-repeat: no-repeat;
        background-position: right 15px top 50%;
        background-size: .65em auto;
    }

    input::placeholder {
        color: rgba(255, 255, 255, 0.6);
    }
    
    input:focus, select:focus {
        background-color: rgba(255, 255, 255, 0.2);
        border-color: rgba(255, 255, 255, 0.5);
        outline: none;
    }
    
    .btn-group {
        margin-top: 25px;
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    button {
      width: 100%;
      padding: 14px;
      border: none;
      font-weight: bold;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.3s ease;
      font-size: 1rem;
    }
    
    .btn-submit {
        background: yellow;
        color: #333;
    }
    .btn-submit:hover {
        background: #ffeb3b;
        transform: translateY(-2px);
    }
    
    .btn-back {
        background: rgba(255, 255, 255, 0.15);
        color: #fff;
    }
    .btn-back:hover {
        background: rgba(255, 255, 255, 0.25);
    }
    
    .message {
      text-align: center;
      margin-top: 20px;
      font-weight: bold;
      padding: 12px;
      border-radius: 8px;
      font-size: 0.95rem;
    }
    
    .select{
    color:black;
    }
    
    .message.success { background-color: rgba(76, 175, 80, 0.5); }
    .message.error { background-color: rgba(244, 67, 54, 0.5); }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
  </style>
</head>
<body>
  <div class="container">
    <h2><i class="fas fa-plus-circle"></i> Add New Expense</h2> 
    <form method="post" action="addExpenses.jsp">
      <div class="form-grid">
          <div class="form-group">
            <label for="amount">Amount</label>
            <div class="input-wrapper">
                <i class="fas fa-rupee-sign"></i>
                <input type="number" step="0.01" name="amount" required placeholder="0.00">
            </div>
          </div>

          <div class="form-group">
            <label for="qty">Quantity</label>
            <div class="input-wrapper">
                <i class="fas fa-hashtag"></i>
                <input type="text" name="qty" required placeholder="e.g., 1kg, 2 items">
            </div>
          </div>
      </div>
      
      <div class="form-group full-width">
        <label for="iname">Item / Service Name</label>
        <div class="input-wrapper">
            <i class="fas fa-tag"></i>
            <input type="text" name="iname" required placeholder="e.g., Coffee, Bus Ticket">
        </div>
      </div>

      <div class="form-grid">
          <div class="form-group">
            <label for="category">Category</label>
            <select class="select" name="category" required>
              <option value="Food">Food</option>
              <option value="Transport">Transport</option>
              <option value="Shopping">Shopping</option>
              <option value="Bills">Bills</option>
              <option value="Entertainment">Entertainment</option>
              <option value="Health">Health</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div class="form-group">
            <label for="pdate">Purchase Date</label>
            <div class="input-wrapper">
                <i class="fas fa-calendar"></i>
                <input type="date" name="pdate" required style="padding-left: 40px;" max="<%= new SimpleDateFormat("yyyy-MM-dd").format(new Date()) %>">
            </div>
          </div>
      </div>

      <div class="btn-group">
        <button type="submit" class="btn-submit">Add Expense</button>
      </div>
    </form>
    <form action="dashboard.jsp" class="btn-group"><button type="submit" class="btn-back">Back to Dashboard</button></form>
    
    <%
      String uname = (String) session.getAttribute("un");
      String amount = request.getParameter("amount");
      String iname = request.getParameter("iname");
      String qty = request.getParameter("qty");
      String category = request.getParameter("category");
      String pdate = request.getParameter("pdate");
      String message = "";
      String messageClass = "";

      if(uname != null && amount != null && iname != null && qty != null && category != null && pdate != null) {
        Connection con = null;
        PreparedStatement ps = null;
        try {
           Class.forName("oracle.jdbc.driver.OracleDriver");
           con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");
           ps = con.prepareStatement("INSERT INTO pexpenses (uname, amount, iname, qty, category, pdate) VALUES (?, ?, ?, ?, ?, ?)");
           ps.setString(1, uname);
           ps.setDouble(2, Double.parseDouble(amount));
           ps.setString(3, iname);
           ps.setString(4, qty);
           ps.setString(5, category);
           ps.setDate(6, java.sql.Date.valueOf(pdate));

           int i = ps.executeUpdate();
           if(i > 0) {
               message = "Expense Added Successfully!";
               messageClass = "success";
           } else {
               message = "Failed to Add Expense.";
               messageClass = "error";
           }
        } catch(Exception e) {
            message = "Error: " + e.getMessage();
            messageClass = "error";
            e.printStackTrace();
        } finally {
            try { if(ps != null) ps.close(); } catch(Exception e) {}
            try { if(con != null) con.close(); } catch(Exception e) {}
        }
    %>
        <div class="message <%= messageClass %>">
            <%= message %>
        </div>
    <%
      }
    %>
   
  </div>
</body>
</html>
