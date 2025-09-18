package Money;
import java.sql.*;

public class DBCon {
 
	public static Connection getCon()
	{
		Connection con=null;
		try
		{
		Class.forName("oracle.jdbc.driver.OracleDriver");
	    con=DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
		}
		catch(Exception e)
		{
			System.out.println(e);
		}
		return con;
	}
	
}
