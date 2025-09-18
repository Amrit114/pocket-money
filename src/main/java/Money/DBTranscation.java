package Money;
import java.sql.*;
public class DBTranscation {
 
	public int inData(RegData ob) {
		int res=0;
    	try {
    	Connection con=DBCon.getCon();
    	PreparedStatement ps=con.prepareStatement("insert into pocketusers values(?,?,?)");
    	ps.setString(1, ob.getUname());
    	ps.setString(2, ob.getEmail());
    	ps.setString(3, ob.getUpass());
    	 res=ps.executeUpdate();
    	}
    	catch(Exception e)
    	{
    		System.out.println(e);
    	}
    	return res;

	}
	public int checkData(RegData ob) {
		int res=0;
    	try {
    	Connection con=DBCon.getCon();
    	PreparedStatement ps=con.prepareStatement("select uname,upass from pocketusers where uname=? and upass=?");
    	ps.setString(1, ob.getUname());
    	ps.setString(2, ob.getUpass());
    	   ResultSet 	 rs=ps.executeQuery();
    	   if(rs.next()) {
    		   res=1;
    		   con.close();
    	   }
    	}
    	catch(Exception e)
    	{
    		System.out.println(e);
    	}
    	return res;
	}
	public int viewData() {
		return 1;
	}
	
}
