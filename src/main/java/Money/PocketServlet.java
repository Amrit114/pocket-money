package Money;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet implementation class PocketServlet
 */
@WebServlet("/PocketServlet")
public class PocketServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public PocketServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String btn=request.getParameter("b");
		java.io.PrintWriter out=response.getWriter();
		RegData ob=new RegData();
		if(btn.equals("Sign In")) {
			ob.setUname(request.getParameter("username"));
			ob.setUpass(request.getParameter("password"));
			ob.setEmail("");
			 if(new DBTranscation().checkData(ob)==1) {
				 HttpSession session=request.getSession();
				   session.setAttribute("un", request.getParameter("username"));	
				 response.sendRedirect("dashboard.jsp");
	            }
			 else
				 out.println("invalid username");

		}
		  
		if(btn.equals("Register")) {
			
			ob.setUname(request.getParameter("username"));
			ob.setEmail(request.getParameter("email"));
			ob.setUpass(request.getParameter("password"));
            if(new DBTranscation().inData(ob)==1) {
            	response.sendRedirect("signin.html");
            }
		}
	}

}
